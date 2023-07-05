#!/bin/bash
set -em

linux_dir="/usr/local/google/home/fuersta/linux"
cp Gconfig.* $linux_dir
pushd $linux_dir > /dev/null 
gbuild TARGET_STATIC_DEFAULT=y CONFIG=smp EXTRA_PREDICATES='nonmodular' -s
gbuild -s
popd > /dev/null

memmap='memmap=64G!8G'
isolcpus="isolcpus=nohz,domain,managed_irq,24-47"
append_cmd="$memmap $isolcpus"
# konjurer_cli -append_cmdline="$append_cmd" $linux_dir/pkgs/LATEST.tar.xz oqv205 &
# append_cmd="$isolcpus"
konjurer_cli -append_cmdline="$append_cmd" $linux_dir/pkgs/LATEST.tar.xz oqv143 &
# append_cmd="$memmap"
konjurer_cli -append_cmdline="$append_cmd" $linux_dir/pkgs/LATEST.tar.xz oqv144 &

wait $(jobs -p)