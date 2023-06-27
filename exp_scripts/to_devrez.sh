#!/bin/sh

user="root"
host="lpbb9"
home="/root"

scp *.sh $user@$host:$home

# dname="../../qemu/test-disk.img"
# if [[ -f "$dname" ]]; then
#     scp $dname $user@$host:$home
# fi
