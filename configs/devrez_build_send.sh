#!/bin/bash

linux_dir="/usr/local/google/home/fuersta/linux"
pushd $linux_dir > /dev/null
gbuild TARGET_STATIC_DEFAULT=y CONFIG=dbg EXTRA_PREDICATES='nonmodular vmtest'
ex=$?
popd > /dev/null

if [ $ex -ne 0 ]; then
    echo "Build failed"
    exit $ex
fi

konjurer_cli $linux_dir/pkgs/LATEST.tar.xz ikbe1