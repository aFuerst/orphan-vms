#!/bin/bash
set -em

linux_dir="/usr/local/google/home/fuersta/linux"
cp Gconfig.* $linux_dir
pushd $linux_dir > /dev/null 
gbuild TARGET_STATIC_DEFAULT=y CONFIG=dbg EXTRA_PREDICATES='nonmodular vmtest' -s
popd > /dev/null

memmap="memmap=16G!8G"
append_cmd="ignore_loglevel $memmap"
konjurer_cli -append_cmdline="$append_cmd" $linux_dir/pkgs/LATEST.tar.xz lpbb9