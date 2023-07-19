#!/bin/bash
set -em 

DEBUG_VMM=false
gdb=""
vmm_gdb_sock="/tmp/vmm-gdb.sock"
LOG_FILE="./ch.log"
VERBOSITY="-v"
disk=""
kernel_img="./google/vmlinux.bin"
cloud_hype="./google/bin/cloud-hypervisor"
cmd="$cloud_hype"
VFIO_NET=false
VRAM=false
CORE=24
DISABLE_EXITS="--disable-exits"
APIC=""
CPU_CNT="1"
while [[ $# -gt 0 ]]; do
  case $1 in
	--cpus)
		CPU_CNT="$2"
	    shift
		shift
	  ;;
    --no-apic)
	    APIC="noapic nolapic acpi=off nolapic_timer"
		shift
	  ;;
	--exits)
		DISABLE_EXITS=""
		shift
	  ;;
  	--core)
		CORE="$2"
		shift
		shift
	  ;;
    --strace)
	  cmd="strace $cloud_hype"
      shift
      ;;
    --kernel)
		gdb_sock="/tmp/ch-gdb.sock"
		if [[ -e "$gdb_sock" ]]; then
			rm -f $gdb_sock
		fi
		gdb="--gdb path=$gdb_sock"
      shift
      ;;
    --vmm)
		cmd="gdbserver localhost:2345 $cloud_hype"
		if [[ -e "$vmm_gdb_sock" ]]; then
			rm -f $vmm_gdb_sock
		fi
		# break spawn_virtio_thread
		# set pagination off
		# set non-stop on
		# target remote :2345
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
	  ;;
	--vram)
  	  VRAM=true
  	  shift
  	  ;;
	*)
        echo "Unknown argument $1"
        exit 1
      ;;
  esac
done

sock="/tmp/cloud-hypervisor.sock"
if [[ -e "$sock" ]]; then
	rm -f $sock
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

CPUS=""
if [ "$CPU_CNT" == "1" ]; then
	CPUS="--cpus boot=1,affinity=[0@[$CORE]]"
elif [ "$CPU_CNT" == "2" ]; then
	CPUS="--cpus boot=2,affinity=[0@[$CORE],1@[$(($CORE+1))]]"
else 
	echo "Can only support 1 or 2 cores"
	exit 1
fi

# # prepare cpuset
# cpusets=/dev/cpuset
# if ! mountpoint -q  $cpusets; then
# 	mkdir -p $cpusets
# 	mount -t cgroup -o cpuset cpuset "$cpusets"
# fi
# ch_set="$cpusets/cloudhyp"
# if [[ -f "$ch_set" ]]; then
# 	rm -f "$ch_set"
# fi
# mkdir -p "$ch_set"
# # assign one CPU per vCPU, plus an extra for other VMM activity
# echo "23-24" > "$ch_set/cpuset.cpus"
# # set exclusive access to those cores
# echo "1" > "$ch_set/cpuset.cpu_exclusive"
# # don't care about memory, just allow to all nodes
# cat "$cpusets/cpuset.mems" > "$ch_set/cpuset.mems"
# # this shell and and subtasks will be inside cpuset
# echo $$ > "$ch_set/tasks"

balloon="--balloon size=2G,deflate_on_oom=on,free_page_reporting=on"
balloon=""

mem_mnt=""
mem_size="4G"
if [[ $VRAM == true ]]; then
	mem_mnt="/tmp/vmram"
	if ! mountpoint -q $mem_mnt; then
		mkdir -p $mem_mnt
		mount -t tmpfs -o size=16G vmram $mem_mnt
	fi
else
	mem_mnt="/pmems/mnt"
	pmem="/mnt/devtmpfs/pmem0"
	if [[ -f $pmem ]]; then
		echo "pmem device not found"
		exit 1
	fi
	if ! mountpoint -q $mem_mnt; then
		mkfs.ext4 -F -m 0 -O ^has_journal /mnt/devtmpfs/pmem0
		mkdir -p $mem_mnt
		mount -o dax=always /mnt/devtmpfs/pmem0 $mem_mnt
	fi

fi

memmap="$mem_mnt/vmmem"
if [[ -f $memmap ]]; then
	rm $memmap
fi
fallocate --length $mem_size $memmap

$cmd \
	--api-socket $sock \
	--log-file "$LOG_FILE" $VERBOSITY \
	--kernel $kernel_img \
	--cmdline "\"console=hvc0 ignore_loglevel earlyprintk=serial,hvc0,115200 strict-devmem=0 nokaslr $APIC\"" \
	$CPUS \
	--memory size=0 \
	--memory-zone id=mem0,size=$mem_size,file=$memmap,shared=on \
	$balloon \
	$disk \
	$vfio_net \
	$DISABLE_EXITS \
	$gdb
	# --net "tap=,mac=,ip=,mask="

# accessible via  'ch-remote --api-socket /tmp/cloud-hypervisor.sock shutdown-vmm'