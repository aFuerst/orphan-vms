#!/bin/bash
# Run with sudo

DEBUG_VMM=false
DEBUG_KERNEL=false
LOG_FILE="./ch.log"
VERBOSITY="-v"
ADD_DISK=false
while [[ $# -gt 0 ]]; do
  case $1 in
    --kernel)
      DEBUG_KERNEL=true
      shift
      ;;
    --vmm)
      DEBUG_VMM=true
      shift
      ;;
    --log-file)
      LOG_FILE="$2"
	  VERBOSITY="-v -v"
      shift
	  shift
      ;;
	--disk)
      ADD_DISK=true
	  shift
      ;;
    *)
      shift
      ;;
  esac
done

sock="/tmp/cloud-hypervisor.sock"
gdb_sock="/tmp/ch-gdb.sock"
if [[ -e "$sock" ]]; then
	rm -f $sock
fi
if [[ -e "$gdb_sock" ]]; then
	rm -f $gdb_sock
fi

kernel_img="../../linux/arch/x86/boot/compressed/vmlinux.bin"
if [[ ! -f "$kernel_img" ]]; then
kernel_img="./google/vmlinux.bin"
fi

cloud_hype="../../cloud-hypervisor/target/debug/cloud-hypervisor" # /x86_64-unknown-linux-musl/release
if [[ ! -f "$cloud_hype" ]]; then
cloud_hype="./google/bin/cloud-hypervisor"
fi

gdb=""
if [[ $DEBUG_KERNEL == true ]]; then
	gdb="--gdb path=$gdb_sock"
fi

disk=""
if [[ $ADD_DISK == true ]]; then
	dname="../../qemu/test-disk.img"
	if [[ ! -f "$dname" ]]; then
		../../qemu/build/qemu-img create $dname 10g
	fi
	disk="--disk path=$dname"
fi

cmd="$cloud_hype"
console="hvc0"
dis_cons=""
if [[ $DEBUG_VMM == true ]]; then
	cmd="gdbserver /tmp/vmm-gdb.sock $cloud_hype"
	# break spawn_virtio_thread
	# set pagination off
	# set non-stop on
	# target remote /tmp/vmm-gdb.sock
fi

$cmd \
	--api-socket $sock \
	--log-file "$LOG_FILE" $VERBOSITY \
	--kernel $kernel_img \
	--cmdline "console=$console ignore_loglevel earlyprintk=serial,$console,115200 strict-devmem=0" \
	--cpus boot=8 \
	--memory size=4G,prefault=true \
	$dis_cons \
	$disk \
	$gdb
	# --cpus boot=4,affinity=[0@[2]] \
	# --balloon size=2G,deflate_on_oom=on,free_page_reporting=on \
	# --net "tap=,mac=,ip=,mask="

# accessible via  'ch-remote --api-socket /tmp/cloud-hypervisor.sock shutdown-vmm'