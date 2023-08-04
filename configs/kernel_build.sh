#!/bin/bash
set -em


NO_BUILDTOOR=false
while [[ $# -gt 0 ]]; do
  case $1 in
	--no-buildroot)
		NO_BUILDTOOR=true
		shift
	;;
	*)
        echo "Unknown argument $1"
        exit 1
      ;;
  esac
done

if [[ $NO_BUILDTOOR == true ]]; then
    echo "buildroot"
    buildroot_dir="/usr/local/google/home/fuersta/buildroot"
    cp "./buildroot_config" "$buildroot_dir/.config"
    pushd $buildroot_dir > /dev/null
    make -j `nproc` -s
    popd > /dev/null
fi

echo "linux"
linux_dir="/usr/local/google/home/fuersta/linux"
cp "./linux_config" "$linux_dir/.config"
pushd $linux_dir > /dev/null
make -j `nproc` KCFLAGS="-Wno-error=unused-function" -s
popd > /dev/null

user="root"
home="/root"

artifacts_dir="$linux_dir/cust_artifacts"
mkdir -p $artifacts_dir
cp "$linux_dir/arch/x86_64/boot/bzImage" $artifacts_dir
cp "$linux_dir/arch/x86/boot/compressed/vmlinux.bin" $artifacts_dir
cp "$linux_dir/arch/x86/boot/compressed/vmlinux" $artifacts_dir

for host in oqv22 oqv20 oqv206 oqv205; do
    scp $artifacts_dir/* $user@$host:$home/google
done
