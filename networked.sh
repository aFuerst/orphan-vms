#!/bin/bash
# Run with sudo


kernel_img="../linux/arch/x86_64/boot/bzImage"
kernel_img="../buildroot/output/images/bzImage"
# qemu-system-x86_64 \
../qemu/build/x86_64-softmmu/qemu-system-x86_64 \
	--enable-kvm -nographic \
	-kernel $kernel_img \
	-cpu host \
	-smp 1 \
	-append "console=ttyS0 ignore_loglevel earlyprintk=serial,ttyS0,115200" \
	-object memory-backend-memfd,id=md1,size=4G,prealloc=on,prealloc-threads=4 \
	-machine memory-backend=md1 \
	-net nic -net user
	# -netdev user,id=mynet0,net=192.168.76.0/24,dhcpstart=192.168.76.9
	# -net nic -net user
	# -netdev tap,id=tap0 -device e1000,netdev=tap0
	# -nic user,model=virtio-net-pci
