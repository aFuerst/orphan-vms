#!/bin/bash

# https://github.com/cloud-hypervisor/cloud-hypervisor/blob/main/docs/building.md
# https://github.com/cloud-hypervisor/cloud-hypervisor/blob/main/docs/gdb.md

vmm_dir="/usr/local/google/home/fuersta/cloud-hypervisor"
pushd $vmm_dir > /dev/null
cargo build --release --target=x86_64-unknown-linux-musl --all --features guest_debug
popd > /dev/null