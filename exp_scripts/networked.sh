#!/bin/bash
# Run with sudo

kernel_img="../../linux/arch/x86_64/boot/bzImage"
if [[ ! -f "$kernel_img" ]]; then
	kernel_img="./bzImage"
fi
# kernel_img="../buildroot/output/images/bzImage"

# qemu-system-x86_64 \
../../qemu/build/x86_64-softmmu/qemu-system-x86_64 \
	--enable-kvm -nographic \
	-kernel $kernel_img \
	-cpu host \
	-smp 4 \
	-append "console=ttyS0 ignore_loglevel earlyprintk=serial,ttyS0,115200" \
	-object memory-backend-memfd,id=md1,size=4G,prealloc=on,prealloc-threads=4 \
	-machine memory-backend=md1 \
	-gdb tcp::1234 \
	-nic tap
	# -nic user,ipv6=off,model=e1000,mac=52:54:98:76:54:32
	# -device e1000,netdev=net0 \
	# -netdev user,id=net0,hostfwd=tcp::5555-:22
	
	# -net nic -net user
	# -netdev user,id=mynet0,net=192.168.76.0/24,dhcpstart=192.168.76.9
	# -netdev tap,id=tap0 -device e1000,netdev=tap0
	# -nic user,model=virtio-net-pci
