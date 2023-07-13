#!/bin/bash
set -em

linux_dir="/usr/local/google/home/fuersta/linux"
cp Gconfig.* $linux_dir
pushd $linux_dir > /dev/null 
gbuild TARGET_STATIC_DEFAULT=y CONFIG=smp EXTRA_PREDICATES='nonmodular' -s
popd > /dev/null

deploy_test() {
    host=$1
    sleep $(shuf -i 1-20 -n 1)

    memmap='memmap=64G!8G'
    cpus="24-47"
    isolcpus="isolcpus=nohz,domain,managed_irq,$cpus"
    nohz="nohz=on nohz_full=$cpus"
    mmu="intel_iommu=on iommu.passthrough=1"
    append_cmd="$memmap $isolcpus"
    log="/tmp/deploy_$host"
    konjurer_cli -append_cmdline="$append_cmd" $linux_dir/pkgs/LATEST.tar.xz $host > "$log.stdout" 2> "$log.stderr"
    if [[ $? != 0 ]]; then
        echo "konjurer deploy failed, logs at $log"
        return;
    fi
    ver=$(ssh root@$host -C "uname -r")
    if [[ $ver != "6.4.0-smp-DEV" ]]; then
        echo "konjurer deploy wrong uname, logs at $log.stdout $log.stderr"
    fi
}

set +e
deploy_test "oqv205" &
# deploy_test "oqv143" &
deploy_test "oqv144" &

wait $(jobs -p)