#!/bin/sh

user="root"
host="ikbe1"
home="/root"

cloud_hyp="../../cloud-hypervisor/target/x86_64-unknown-linux-musl/release/cloud-hypervisor"
ch_remote="../../cloud-hypervisor/target/x86_64-unknown-linux-musl/release/ch-remote"
qemu="../../qemu/build/x86_64-softmmu/qemu-system-x86_64"

bin="$home/google/bin"
scp $cloud_hyp $user@$host:$bin/cloud-hypervisor
scp $ch_remote $user@$host:$bin/ch-remote
scp $qemu $user@$host:$bin/qemu-system-x86_64

kernel_img="../../linux/arch/x86_64/boot/bzImage"
kernel_dbg="../../linux/scripts/gdb"
kernel_vmlinux="../../linux/vmlinux"
kernel_compress="../../linux/arch/x86/boot/compressed/vmlinux.bin"
scp $kernel_img $user@$host:$home/google
scp $kernel_compress $user@$host:$home/google
scp -r $kernel_dbg $user@$host:$home/google/gdb/scripts/gdb
scp $kernel_vmlinux $user@$host:$home/google/gdb

scp *.sh $user@$host:$home
