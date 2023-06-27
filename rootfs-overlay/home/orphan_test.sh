#!/bin/bash
set -em



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

# python3 burn_cpu.py -p 1 &
# pid=$!

# echo $pid > "$ch_set/tasks"
