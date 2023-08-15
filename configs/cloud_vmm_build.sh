#!/bin/bash
set -em

# https://github.com/cloud-hypervisor/cloud-hypervisor/blob/main/docs/building.md
# https://github.com/cloud-hypervisor/cloud-hypervisor/blob/main/docs/gdb.md

vmm_dir="../cloud-hypervisor-orphan"
pushd $vmm_dir > /dev/null
#  --release --target=x86_64-unknown-linux-musl
cargo build --all --features guest_debug --target=x86_64-unknown-linux-musl --release
# sudo setcap cap_net_admin+ep ./target/debug/cloud-hypervisor
popd > /dev/null


virtiofs_dir="../virtiofsd"
virtiofsd="$virtiofs_dir/target/release/virtiofsd"
pushd $virtiofs_dir > /dev/null
cargo build --release
# sudo setcap cap_sys_admin+epi $virtiofsd
popd > /dev/null
./copy_shared_lib $virtiofsd virtiofsd_lib/
cp $virtiofsd virtiofsd_lib/

cloud_hyp="$vmm_dir/target/x86_64-unknown-linux-musl/release/cloud-hypervisor"
ch_remote="$vmm_dir/target/x86_64-unknown-linux-musl/release/ch-remote"

bin="/root/google/bin"
user="root"
# oqv22 oqv20 oqv206 lpbb23 oqv205
for host in lpbb25  lpbb27; do
    scp $ch_remote $user@$host:$bin
    scp $cloud_hyp $user@$host:$bin
    scp -r virtiofsd_lib/ $user@$host:$bin
    scp virtiofsd $user@$host:$bin
done

rm -r virtiofsd_lib/
