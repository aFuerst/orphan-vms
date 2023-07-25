#!/bin/bash
set -em

linux_dir="/usr/local/google/home/fuersta/linux"
cp Gconfig.* $linux_dir
pushd $linux_dir > /dev/null 
gbuild TARGET_STATIC_DEFAULT=y CONFIG=smp EXTRA_PREDICATES='nonmodular' -s
popd > /dev/null

deploy_test() {
    host=$1
    append_cmd=$2

    log="/tmp/deploy_$host"
    #  -client=ssh -ssh_direct
    konjurer_cli -client=ssh -ssh_direct --ssh_direct=true -append_cmdline="$append_cmd" $linux_dir/pkgs/LATEST.tar.xz $host > "$log.stdout" 2> "$log.stderr"
    if [[ $? != 0 ]]; then
        echo "konjurer deploy failed, logs at $log; rebooting" # 
        # ssh root@$host "echo 'test' > /dev/null; shutdown -r now &"
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
# deploy_test "oqv205" "$append_cmd" &
sleep $(shuf -i 1-20 -n 1)
# deploy_test "oqv143" "$append_cmd" &
sleep $(shuf -i 1-20 -n 1)
deploy_test "oqv142" "$append_cmd" &

wait $(jobs -p)
