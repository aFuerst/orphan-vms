#!/bin/bash
set -em

MACHINE=""
NO_MODULE=""
linux_dir="../linux"
cp Gconfig.* $linux_dir

while [[ $# -gt 0 ]]; do
  case $1 in
    -m|--machine)
      MACHINE="$2"
      shift
      shift
      ;;
    --no-module)
        # build orphan vm module directly into kernel
        echo "here"
        NO_MODULE="CONFIG_ORPHAN_VM=y"
        sed -i -e 's/CONFIG_ORPHAN_VM=m/CONFIG_ORPHAN_VM=y/g' "$linux_dir/Gconfig.rando"
        shift
        ;;
    *)
        echo "Unknown argument $1"
        exit 1
      ;;
  esac
done

pushd $linux_dir > /dev/null 
gbuild TARGET_STATIC_DEFAULT=y CONFIG=smp $CONFIG_ORPHAN_VM EXTRA_PREDICATES='nonmodular' KCFLAGS='-Wno-error=unused-function -Wno-error=unused-variable' -s
popd > /dev/null

deploy_test() {
    host=$1
    append_cmd=$2

    echo "Deploying to $host"
    log="/tmp/deploy_$host"
    #  -client=ssh -ssh_direct
    konjurer_cli -client=ssh -ssh_direct --ssh_direct=true -append_cmdline="$append_cmd" $linux_dir/pkgs/LATEST.tar.xz $host > "$log.stdout" 2> "$log.stderr"
    if [[ $? != 0 ]]; then
        echo "konjurer deploy failed, logs at $log; rebooting" # 
        # megapede power --power_backend_type POWER_BACKEND_TYPE_NEMORA cycle "$host.prod.google.com"
        ssh root@$host "echo 'test' > /dev/null; shutdown -r now &"
        return;
    fi
    ver=$(ssh root@$host -C "uname -r")
    if [[ $ver != "6.4.0-smp-DEV" ]]; then
        echo "konjurer deploy wrong uname, logs at $log.stdout $log.stderr"
    fi
}

# isolcpus="isolcpus=nohz,domain,managed_irq,$isolated_cpus"
# nohz="nohz=on nohz_full=$isolated_cpus"
# mmu="intel_iommu=on iommu.passthrough=1"
# append_cmd="$memmap $isolcpus"

memmap='memmap=64G!8G'
isolated_cpus="24,25,26,27"
# https://access.redhat.com/solutions/5919411
a1="nmi_watchdog=0  mce=off irqaffinity=0-12"
states="skew_tick=1 intel_pstate=disable intel_idle.max_cstate=0 processor.max_cstate=0 tsc=relxiable"
rcu="rcu_nocbs=$isolated_cpus rcu_nocb_poll"
disables="nosoftlockup nowatchdog nomce numa_balancing=disable transparent_hugepage=never"
isolcpus="isolcpus=nohz,domain,managed_irq,$isolated_cpus"
nohz="nohz=on nohz_full=$isolated_cpus"
# apic="nolapic" # noapic nolapic acpi=off

append_cmd="$memmap $isolcpus $rcu $disables $a1 $states $nohz"

set +e
if [[ -n "$MACHINE" ]]; then
    deploy_test "$MACHINE" "$append_cmd" &
else
    #  lpbb23 lpbb27 lpbb25 oqv22 oqv20 oqv206 oqv205
    for host in lpbb27 lpbb25; do
        deploy_test $host "$append_cmd" &
        # sleep $(shuf -i 1-20 -n 1)
    done
    # deploy_test "oqv205" "$append_cmd" &
    # sleep $(shuf -i 1-20 -n 1)
    # deploy_test "oqv22" "$append_cmd" &
    # sleep $(shuf -i 1-20 -n 1)
    # deploy_test "oqv206" "$append_cmd" &
    # sleep $(shuf -i 1-20 -n 1)
    # deploy_test "oqv20" "$append_cmd" &
fi

wait $(jobs -p)
