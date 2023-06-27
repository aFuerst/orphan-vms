#!/bin/bash
# Run with sudo
set -em 

DEBUG_VMM=false
DEBUG_KERNEL=false
LOG_FILE="./ch.log"
VERBOSITY="-v"
disk=""

VFIO_NET=false
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
		dname="./test-disk.img"
		if [[ ! -f "$dname" ]]; then
			echo "disk is missing"
			exit 0
		fi
		disk="--disk path=$dname"
	  shift
      ;;
	--vfio-net)
	  VFIO_NET=true
	  shift
	  ;;\
    *)
      shift
      ;;
  esac
done

sock="/tmp/cloud-hypervisor.sock"
if [[ -e "$sock" ]]; then
	rm -f $sock
fi

kernel_img="./google/vmlinux.bin"
cloud_hype="./google/bin/cloud-hypervisor"

gdb=""
if [[ $DEBUG_KERNEL == true ]]; then
	gdb_sock="/tmp/ch-gdb.sock"
	if [[ -e "$gdb_sock" ]]; then
		rm -f $gdb_sock
	fi
	gdb="--gdb path=$gdb_sock"
fi

vfio_net=""
if [[ $VFIO_NET == true ]]; then
	# lspci | grep Ethernet
	# lspci -v -s 0000:18:00.0
	# vfio network devices on devrez
	# 0000:18:00.0 Ethernet controller: Google, Inc. Device 001d (rev 04)
	# 0000:18:00.1 Ethernet controller: Google, Inc. Device 002d
	# 0000:18:00.2 Ethernet controller: Google, Inc. Device 002d
	# 0000:18:00.3 Ethernet controller: Google, Inc. Device 002d
	# enable vfio
	echo 1 > /sys/module/vfio_iommu_type1/parameters/allow_unsafe_interrupts
	device="0000:18:00.3"
	vendor_id=$(lspci -n -s $device | cut -d' ' -f 3 | cut -d':' -f 1)
	product_id=$(lspci -n -s $device | cut -d' ' -f 3 | cut -d':' -f 2)
	unbind="/sys/bus/pci/devices/$device/driver/unbind"
	if [[ -e $unbind ]]; then
		echo $device > $unbind
	fi
	echo $vendor_id $product_id > /sys/bus/pci/drivers/vfio-pci/new_id
	vfio_net="--device path=/sys/bus/pci/devices/$device/"
fi

cmd="$cloud_hype"
vmm_gdb_sock="/tmp/vmm-gdb.sock"
console="hvc0"
dis_cons=""
if [[ $DEBUG_VMM == true ]]; then
	cmd="gdbserver localhost:2345 $cloud_hype"
	if [[ -e "$vmm_gdb_sock" ]]; then
	rm -f $vmm_gdb_sock
	fi
	# console="ttyS0"
	# dis_cons="--serial tty --console off"

	# break spawn_virtio_thread
	# set pagination off
	# set non-stop on
	# target remote :2345
fi

# prepare cpuset
cpusets=/dev/cpuset
if [[ ! -f "$cpusets" ]]; then
	mkdir -p $cpusets
	mount -t cgroup -o cpuset cpuset "$cpusets"
fi
ch_set="$cpusets/cloudhyp"
if [[ -f "$ch_set" ]]; then
	rm -f "$ch_set"
fi
mkdir -p "$ch_set"
# assign one CPU per vCPU, plus an extra for other VMM activity
echo "2-3" > "$ch_set/cpuset.cpus"
# set exclusive access to those cores
echo 1 > "$ch_set/cpuset.cpu_exclusive"
# don't care about memory, just allow to all nodes
cat "$cpusets/cpuset.mems" > "$ch_set/cpuset.mems"
# this shell and and subtasks will be inside cpuset
echo $$ > "$ch_set/tasks"

balloon="--balloon size=2G,deflate_on_oom=on,free_page_reporting=on"
balloon=""

memmap="/pmems/mnt/vmmem"
rm -f $memmap
mem_size="4G"
fallocate --length $mem_size $memmap

$cmd \
	--api-socket $sock \
	--log-file "$LOG_FILE" $VERBOSITY \
	--kernel $kernel_img \
	--cmdline "\"console=$console ignore_loglevel earlyprintk=serial,$console,115200 strict-devmem=0\"" \
	--cpus boot=1,affinity=[0@[3]] \
	--memory size=0 \
	--memory-zone id=mem0,size=$mem_size,file=$memmap,prefault=on \
	$balloon \
	$dis_cons \
	$disk \
	$vfio_net \
	$gdb
	# --net "tap=,mac=,ip=,mask="

# accessible via  'ch-remote --api-socket /tmp/cloud-hypervisor.sock shutdown-vmm'