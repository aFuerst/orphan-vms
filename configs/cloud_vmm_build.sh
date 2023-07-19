#!/bin/bash
set -em


# https://github.com/cloud-hypervisor/cloud-hypervisor/blob/main/docs/building.md
# https://github.com/cloud-hypervisor/cloud-hypervisor/blob/main/docs/gdb.md

vmm_dir="/usr/local/google/home/fuersta/cloud-hypervisor"
pushd $vmm_dir > /dev/null
#  --release --target=x86_64-unknown-linux-musl
cargo build --all --features guest_debug --target=x86_64-unknown-linux-musl --release
# sudo setcap cap_net_admin+ep ./target/debug/cloud-hypervisor
popd > /dev/null


cloud_hyp="../../cloud-hypervisor/target/x86_64-unknown-linux-musl/release/cloud-hypervisor"
ch_remote="../../cloud-hypervisor/target/x86_64-unknown-linux-musl/release/ch-remote"

bin="/root/google/bin"
user="root"
for host in oqv143 oqv142 oqv205; do
    scp $ch_remote $user@$host:$bin
    scp $cloud_hyp $user@$host:$bin
done
