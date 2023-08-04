#!/bin/bash
# Run with sudo

kernel_img="../../linux/cust_artifacts/bzImage"
if [[ ! -f "$kernel_img" ]]; then
	kernel_img="./bzImage"
fi
# kernel_img="../buildroot/output/images/bzImage"

#qemu-system-x86_64 \
../../qemu/build/x86_64-softmmu/qemu-system-x86_64 \
	--enable-kvm -nographic \
	-kernel $kernel_img \
	-cpu host \
	-smp 4 \
	-append "console=ttyS0 ignore_loglevel earlyprintk=serial,ttyS0,115200 clocksource=kvm-clock" \
	-object memory-backend-memfd,id=md1,size=4G,prealloc=on,prealloc-threads=4 \
	-machine memory-backend=md1 \
	-net none \
	-virtfs local,path=/tmp/vmfs,mount_tag=host0,security_model=passthrough,id=host0 \
	-gdb tcp::1234
