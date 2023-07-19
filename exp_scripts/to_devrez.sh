#!/bin/sh

user="root"
home="/root"

for host in oqv143 oqv142 oqv205; do
    scp *.sh $user@$host:$home
    ssh $user@$host -C "echo \"alias vmkill=\\\"ch-remote --api-socket /tmp/cloud-hypervisor.sock shutdown-vmm\\\"\" >> $home/.bashrc"
    ssh $user@$host -C "echo \"alias ge=\\\"gcontain enter /\\\"\" >> $home/.bashrc"
done
# dname="../../qemu/test-disk.img"
# if [[ -f "$dname" ]]; then
#     scp $dname $user@$host:$home
# fi
