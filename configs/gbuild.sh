#!/bin/bash

linux_dir="/usr/local/google/home/fuersta/linux"
pushd $linux_dir > /dev/null
gbuild TARGET_STATIC_DEFAULT=y CONFIG=dbg EXTRA_PREDICATES='nonmodular vmtest'
popd > /dev/null
