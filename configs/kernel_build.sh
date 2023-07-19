#!/bin/bash
set -em

echo "buildroot"
buildroot_dir="/usr/local/google/home/fuersta/buildroot"
cp "./buildroot_config" "$buildroot_dir/.config"
pushd $buildroot_dir > /dev/null
make -j `nproc` -s
popd > /dev/null

echo "linux"
linux_dir="/usr/local/google/home/fuersta/linux"
cp "./linux_config" "$linux_dir/.config"
pushd $linux_dir > /dev/null
make -j `nproc` -s
popd > /dev/null

user="root"
home="/root"

artifacts_dir="$linux_dir/cust_artifacts"
mkdir -p $artifacts_dir
cp "$linux_dir/arch/x86_64/boot/bzImage" $artifacts_dir
cp "$linux_dir/arch/x86/boot/compressed/vmlinux.bin" $artifacts_dir
cp "$linux_dir/arch/x86/boot/compressed/vmlinux" $artifacts_dir

for host in oqv143 oqv142 oqv205; do
    scp $artifacts_dir/* $user@$host:$home/google
done
