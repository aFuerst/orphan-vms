#!/bin/bash

if [[ `sysctl -b alex.orphaned_vm` == 0 ]]; then
    echo "enabling"
    modprobe no_kvm
    sleep 1
    sysctl -q -w alex.orphaned_vm=1
else
    echo "disabling"
    sysctl -q -w alex.orphaned_vm=0
    sleep 1
    modprobe -r no_kvm
fi
