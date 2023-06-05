#!/bin/bash
# Run with sudo

kernel_img="../../linux/arch/x86_64/boot/bzImage"
if [[ ! -f "$kernel_img" ]]; then
	kernel_img="./bzImage"
fi

path_to_initramfs=/usr/local/google/home/fuersta/.qemu-dev-tools/LATEST.cpio.gz

#qemu-system-x86_64 \
../../qemu/build/x86_64-softmmu/qemu-system-x86_64 \
	--enable-kvm -nographic \
	-kernel $kernel_img \
	-initrd "$path_to_initramfs" \
	-cpu host \
	-smp 4 \
	-append "console=ttyS0 ignore_loglevel earlyprintk=serial,ttyS0,115200 clocksource=kvm-clock" \
	-object memory-backend-memfd,id=md1,size=4G,prealloc=on,prealloc-threads=4 \
	-machine memory-backend=md1 \
	-nic none \
	-gdb tcp::1234
