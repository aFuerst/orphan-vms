#!/bin/bash
set -em

rust-gdb ../../cloud-hypervisor/target/debug/cloud-hypervisor -x vmm-local.gdb