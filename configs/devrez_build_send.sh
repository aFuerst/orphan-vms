#!/bin/bash
set -em

set="1"
vfio="CONFIG_VFIO_CONTAINER=$set CONFIG_VFIO=$set CONFIG_VFIO_PCI=$set CONFIG_VFIO_IOMMU_TYPE1=$set \
    CONFIG_VFIO_PCI_MMAP=$set CONFIG_VFIO_PCI_INTX=$set \
    CONFIG_VFIO_VIRQFD=$set CONFIG_VFIO_PCI_CORE=$set \
    CONFIG_VFIO_PCI_IGD=$set CONFIG_VFIO_PCI_VGA=$set CONFIG_VFIO_MDEV=$set"
vfio=""
linux_dir="/usr/local/google/home/fuersta/linux"
cp Gconfig.vfio $linux_dir
pushd $linux_dir > /dev/null 
gbuild TARGET_STATIC_DEFAULT=y CONFIG=dbg $vfio EXTRA_PREDICATES='nonmodular vmtest' -s
popd > /dev/null

konjurer_cli $linux_dir/pkgs/LATEST.tar.xz ikbe1