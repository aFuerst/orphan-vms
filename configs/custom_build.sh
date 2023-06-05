#!/bin/bash

linux_dir="/usr/local/google/home/fuersta/linux"
cp "./linux_config" "$linux_dir/.config"
pushd $linux_dir > /dev/null
make -j `nproc` -s
popd > /dev/null

