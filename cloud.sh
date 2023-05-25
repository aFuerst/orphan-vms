#!/bin/bash
# Run with sudo

kernel_img="../linux/arch/x86/boot/compressed/vmlinux.bin"
../cloud-hypervisor/target/x86_64-unknown-linux-musl/release/cloud-hypervisor \
	--api-socket /tmp/cloud-hypervisor.sock \
	--kernel $kernel_img \
	--cmdline "console=hvc0 ignore_loglevel earlyprintk=serial,hvc0,115200 clocksource=tsc" \
	--cpus boot=4 \
	--memory size=4G \
	--net "tap=,mac=,ip=,mask="

# accessible on  sudo curl --unix-socket /tmp/cloud-hypervisor.sock -i -X PUT "http://localhost/api/v1/vmm.shutdown"