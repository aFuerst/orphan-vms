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
host="ikbe1"
home="/root"

scp "../../linux/arch/x86_64/boot/bzImage" $user@$host:$home/google
scp "../../linux/arch/x86/boot/compressed/vmlinux.bin" $user@$host:$home/google
scp "../../linux/arch/x86/boot/compressed/vmlinux" $user@$host:$home/google