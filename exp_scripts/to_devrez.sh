#!/bin/sh

user="root"
host="ikbe1"
home="/user/fuersta"

kernel_img="../../linux/arch/x86_64/boot/bzImage"

kernel_compress="../../linux/arch/x86/boot/compressed/vmlinux.bin"
cloud_hyp="../../cloud-hypervisor/target/x86_64-unknown-linux-musl/release/cloud-hypervisor"
qemu="../../qemu/build/x86_64-softmmu/qemu-system-x86_64"

scripts="."
bins="$scripts/bins"
mkdir -p $bins

cp $kernel_img $bins/bzImage
cp $kernel_compress $bins/vmlinux.bin
cp $cloud_hyp $bins/cloud-hypervisor
cp $qemu $bins/qemu-system-x86_64

scp -r $scripts $user@$host:$home
