#!/bin/bash
set -em

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

kernel_img="../../linux/cust_artifacts/vmlinux.bin"
if [[ ! -f "$kernel_img" ]]; then
kernel_img="./google/vmlinux.bin"
fi

cloud_hype="../../cloud-hypervisor/target/x86_64-unknown-linux-musl/release/cloud-hypervisor"
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
if [[ $DEBUG_VMM == true ]]; then
	cmd="gdbserver :2345 $cloud_hype"
	# break spawn_virtio_thread
	# set pagination off
	# set non-stop on
	# target remote /tmp/vmm-gdb.sock
fi

mem_mnt="/tmp/rammnt"
if ! mountpoint -q $mem_mnt; then
	mkdir -p $mem_mnt
	sudo mount -t tmpfs -o size=10G vmramdisk $mem_mnt
fi
memmap="$mem_mnt/vmmem"
mem_size="4G"
if [[ ! -f $memmap ]]; then
	fallocate --length $mem_size $memmap
fi

$cmd \
	--api-socket $sock \
	--log-file "$LOG_FILE" $VERBOSITY \
	--kernel $kernel_img \
	--cmdline "console=$console ignore_loglevel earlyprintk=serial,$console,115200 strict-devmem=0 isolcpus=nohz,managed_irq,domain,4-7" \
	--cpus boot=8,affinity=[0@[2],1@[3],2@[4],3@[5],4@[6],5@[7],6@[8],7@[9]] \
	--memory size=0 \
	--memory-zone id=mem0,size=$mem_size,file=$memmap,shared=on \
	$disk \
	$gdb
	# --cpus boot=4,affinity=[0@[2]] \
	# --balloon size=2G,deflate_on_oom=on,free_page_reporting=on \
	# --net "tap=,mac=,ip=,mask="

# accessible via  'ch-remote --api-socket /tmp/cloud-hypervisor.sock shutdown-vmm'