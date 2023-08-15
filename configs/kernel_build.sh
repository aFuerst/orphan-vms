#!/bin/bash
set -em


BUILDROOT=true
while [[ $# -gt 0 ]]; do
  case $1 in
    --no-buildroot)
      BUILDROOT=false
      shift
    ;;
    *)
        echo "Unknown argument $1"
        exit 1
      ;;
  esac
done

if [[ $BUILDROOT == true ]]; then
    echo "buildroot"
    cust_bins_dir="../syscall-tester"
    pushd $cust_bins_dir > /dev/null
    make clean && make
    popd > /dev/null

    buildroot_dir="../buildroot"
    cp "./buildroot_config" "$buildroot_dir/.config"
    pushd $buildroot_dir > /dev/null
    make -j `nproc` -s
    popd > /dev/null
fi

echo "linux"
linux_dir="../linux"
cp "./linux_config" "$linux_dir/.config"
pushd $linux_dir > /dev/null
make -j `nproc` KCFLAGS='-Wno-error=unused-function -Wno-error=unused-variable' -s
popd > /dev/null

user="root"
home="/root"

artifacts_dir="$linux_dir/cust_artifacts"
mkdir -p $artifacts_dir
cp "$linux_dir/arch/x86_64/boot/bzImage" $artifacts_dir
cp "$linux_dir/arch/x86/boot/compressed/vmlinux.bin" $artifacts_dir
cp "$linux_dir/arch/x86/boot/compressed/vmlinux" $artifacts_dir

# lpbb23 oqv22 oqv20 oqv206 oqv205
for host in lpbb21 lpbb26 ; do
    scp $artifacts_dir/* $user@$host:$home/google
done
