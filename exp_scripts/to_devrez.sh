#!/bin/sh

user="root"
host="ikbe1"
home="/user/fuersta"

cloud_hyp="../../cloud-hypervisor/target/x86_64-unknown-linux-musl/release/cloud-hypervisor"
ch_remote="../../cloud-hypervisor/target/x86_64-unknown-linux-musl/release/ch-remote"
qemu="../../qemu/build/x86_64-softmmu/qemu-system-x86_64"

bin="/root/google/bin"
scp $cloud_hyp $user@$host:$bin/cloud-hypervisor
scp $ch_remote $user@$host:$bin/ch-remote
scp $qemu $user@$host:$bin/qemu-system-x86_64

kernel_img="../../linux/arch/x86_64/boot/bzImage"
kernel_compress="../../linux/arch/x86/boot/compressed/vmlinux.bin"
scp -r $kernel_img $user@$host:/root/google
scp -r $kernel_compress $user@$host:/root/google

scp -r . $user@$host:/root/google