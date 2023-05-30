#!/bin/bash
# Run with sudo

#if [[ ! -f "$kernel_img" ]]; then
#	cp ../linux/arch/x86_64/boot/$kernel_img .
#fi

#rootfs="rootfs.ext4"
#if [[ ! -f "$rootfs" ]]; then
#	cp ../buildroot/output/images/$rootfs .
#fi

#initrd="initrd.img"
#if [[ ! -f "$initrd" ]]; then
#	mkinitramfs -o $initrd
#fi	

kernel_img="../linux/arch/x86_64/boot/bzImage"
kernel_img="./bins/bzImage"
# kernel_img="../buildroot/output/images/bzImage"
#qemu-system-x86_64 \
../../qemu/build/x86_64-softmmu/qemu-system-x86_64 \
	--enable-kvm -nographic \
	-kernel $kernel_img \
	-cpu host \
	-smp 1 \
	-append "console=ttyS0 ignore_loglevel earlyprintk=serial,ttyS0,115200 clocksource=tsc" \
	-object memory-backend-memfd,id=md1,size=4G,prealloc=on,prealloc-threads=4 \
	-machine memory-backend=md1

`	# -overcommit mem-lock=on \
	# -kvmclock \
