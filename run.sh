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

# empty current trace buffer
#sh -c "> /sys/kernel/tracing/events/trace"

# grow buffer to hold more info
#old_cpu_buff_size=$(cat /sys/kernel/tracing/buffer_size_kb)
#echo 5000 > /sys/kernel/tracing/buffer_size_kb

# enable tracing KVM VM exits
#echo 1 > "/sys/kernel/tracing/events/kvm/kvm_exit/enable"
kernel_img="../linux/arch/x86_64/boot/bzImage"
kernel_img="../buildroot/output/images/bzImage"
#qemu-system-x86_64 \
../qemu/build/x86_64-softmmu/qemu-system-x86_64 \
	--enable-kvm -nographic \
	-kernel $kernel_img \
	-cpu host \
	-smp 4 \
	-append "console=ttyS0 ignore_loglevel earlyprintk=serial,ttyS0,115200" \
	-object memory-backend-memfd,id=md1,size=4G,prealloc=on \
	-machine memory-backend=md1
#-initrd $initrd
	#-append "root=/dev/vda console=ttyS0" \
	#-object memory-backend-ram,id=pc.ram,size=3G,x-use-canonical-path-for-ramblock-id=off,prealloc=on \
	#-net nic,model=virtio \
	#-machine memory-backend=pc.ram \
	
	#-net user,hostfwd=tcp::10022-:22

	#-monitor telnet:127.0.0.1:1234,server,nowait \
	#-drive format=raw,file=$rootfs,if=virtio \
	
# disable KVM VM exits
#echo 0 > "/sys/kernel/tracing/events/kvm/kvm_exit/enable"
# save trace data
#cp /sys/kernel/tracing/trace trace.out
# resize buffer
#echo $old_cpu_buff_size
#echo $old_cpu_buff_size > /sys/kernel/tracing/buffer_size_kb
