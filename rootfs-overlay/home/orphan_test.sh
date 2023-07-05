#!/bin/bash
set -em

# prepare cpuset
cpusets=/dev/cpuset
# rm -rf $cpusets
if ! mountpoint -q  $cpusets; then
	mkdir -p $cpusets
	mount -t cgroup -o cpuset cpuset "$cpusets"
fi
ch_set="$cpusets/cloudhyp"
if [[ -d "$ch_set" ]]; then
	rmdir "$ch_set"
fi
mkdir -p "$ch_set"
# assign one CPU per vCPU, plus an extra for other VMM activity
echo "4-7" > "$ch_set/cpuset.cpus"
# set exclusive access to those cores
echo 1 > "$ch_set/cpuset.cpu_exclusive"
# don't care about memory, just allow to all nodes
cat "$cpusets/cpuset.mems" > "$ch_set/cpuset.mems"
echo $$ > "$ch_set/tasks"

python3 burn_cpu.py -p 4
# pid=$!

# trap ctrl_c INT
# function ctrl_c() {
#     kill -SIGINT $pid
# }


# wait $(jobs -p)
# ./pintest -p 7 &
