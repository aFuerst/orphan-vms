#!/bin/bash
# Run with sudo

sock="/tmp/cloud-hypervisor.sock"

if [[ -f "$sock" ]]; then
	rm -f $sock
fi

kernel_img="../linux/arch/x86/boot/compressed/vmlinux.bin"
if [[ ! -f "$kernel_img" ]]; then
kernel_img="./bins/vmlinux.bin"
fi

cloud_hype="../cloud-hypervisor/target/x86_64-unknown-linux-musl/release/cloud-hypervisor"
if [[ ! -f "$cloud_hype" ]]; then
cloud_hype="./bins/cloud-hypervisor"
fi

$cloud_hype \
	--api-socket $sock \
	--kernel $kernel_img \
	--cmdline "console=hvc0 ignore_loglevel earlyprintk=serial,hvc0,115200 clocksource=tsc" \
	--cpus boot=4 \
	--memory size=4G,prefault=true \
	--net "tap=,mac=,ip=,mask="

# accessible on  sudo curl --unix-socket /tmp/cloud-hypervisor.sock -i -X PUT "http://localhost/api/v1/vmm.shutdown"