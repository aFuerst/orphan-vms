#!/bin/sh

user="root"
home="/root"

# oqv205 oqv22 oqv20 oqv206  
for host in lpbb26 lpbb23 lpbb21; do
    scp *.sh $user@$host:$home
    scp ../syscall-tester/pintest $user@$host:$home/google/bin
    scp ../syscall-tester/cpuid $user@$host:$home/google/bin
    scp ../syscall-tester/timer_exiter $user@$host:$home/google/bin
    ssh $user@$host -C "echo \"alias vmkill=\\\"ch-remote --api-socket /tmp/cloud-hypervisor.sock shutdown-vmm\\\"\" >> $home/.bashrc"
    ssh $user@$host -C "echo \"alias ge=\\\"gcontain enter /\\\"\" >> $home/.bashrc"
done
# dname="../../qemu/test-disk.img"
# if [[ -f "$dname" ]]; then
#     scp $dname $user@$host:$home
# fi
