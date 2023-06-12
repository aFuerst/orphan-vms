#!/bin/bash
# read a byte from every 4K page of visible memory
set -em

MEM_KB=$(grep MemTotal /proc/meminfo | awk '{print $2}')
for (( block = 0; block < $MEM_KB; block += 4 ))
do
    addr=$(( block*1024 ))
    hexdump -s $addr /dev/mem -n 1 > /dev/null
done
