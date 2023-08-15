#!/bin/bash
set -em

MACHINE=""
while [[ $# -gt 0 ]]; do
  case $1 in
    -m|--machine)
      MACHINE="$2"
      shift
      shift
      ;;

    *)
        echo "Unknown argument $1"
        exit 1
      ;;
  esac
done

linux_dir="../linux"
modules_dir="$linux_dir/cust_modules"
cp Gconfig.* $linux_dir
pushd $linux_dir > /dev/null 
gbuild TARGET_STATIC_DEFAULT=y INSTALL_MOD_STRIP=1 INSTALL_MOD_PATH=$modules_dir CONFIG=smp EXTRA_PREDICATES='nonmodular' KCFLAGS='-Wno-error=unused-function -Wno-error=unused-variable' -s modules
gbuild TARGET_STATIC_DEFAULT=y INSTALL_MOD_STRIP=1 INSTALL_MOD_PATH=$modules_dir CONFIG=smp EXTRA_PREDICATES='nonmodular' KCFLAGS='-Wno-error=unused-function -Wno-error=unused-variable' -s modules_install
popd > /dev/null

module_src="$modules_dir/lib/modules/6.4.0-smp-DEV/kernel/arch/x86/kvm/vmx/no_kvm.ko"
module_target="/lib/modules/6.4.0-smp-DEV/kernel/arch/x86/kvm/vmx/no_kvm.ko"
if [[ -n "$MACHINE" ]]; then
    scp $module_src $user@$MACHINE:$module_target
    scp $modules_dir/lib/modules/6.4.0-smp-DEV/modules.* $user@$MACHINE:/lib/modules/6.4.0-smp-DEV/
else
    # lpbb23 lpbb27 lpbb25 oqv22 oqv20 oqv206 oqv205
    for host in lpbb27 lpbb25; do
        scp $module_src $user@$host:$module_target
        scp $modules_dir/lib/modules/6.4.0-smp-DEV/modules.* $user@$host:/lib/modules/6.4.0-smp-DEV/
    done
fi
