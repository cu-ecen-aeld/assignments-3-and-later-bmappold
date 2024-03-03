#!/bin/bash
# Script outline to install and build kernel.
# Author: Siddhant Jajoo.

set -e
set -u

OUTDIR=/tmp/aeld
KERNEL_REPO=git://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-stable.git
KERNEL_VERSION=v5.1.10
BUSYBOX_VERSION=1_33_1
FINDER_APP_DIR=$(realpath $(dirname $0))
ARCH=arm64
CROSS_COMPILE=aarch64-none-linux-gnu-

if [ $# -lt 1 ]
then
	echo "Using default directory ${OUTDIR} for output"
else
	OUTDIR=$1
	echo "Using passed directory ${OUTDIR} for output"
fi

mkdir -p ${OUTDIR}

cd "$OUTDIR"
if [ ! -d "${OUTDIR}/linux-stable" ]; then
    #Clone only if the repository does not exist.
	echo "CLONING GIT LINUX STABLE VERSION ${KERNEL_VERSION} IN ${OUTDIR}"
	git clone ${KERNEL_REPO} --depth 1 --single-branch --branch ${KERNEL_VERSION}
fi
if [ ! -e ${OUTDIR}/linux-stable/arch/${ARCH}/boot/Image ]; then
    cd linux-stable
    echo "Checking out version ${KERNEL_VERSION}"
    git checkout ${KERNEL_VERSION}

    # TODO: Add your kernel build steps here
    make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} mrproper
    echo "TEST 2"    
    #cp /boot/config-$(uname -r) .config #learned from Ubuntu Wiki
    make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} defconfig #from lecture video 
    echo "TEST 3"
    make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} -j$(nproc) all
    echo "TEST 4"
    # do I need to add modules here? skipping per instructions
    # make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} modules
    echo "TEST 5"
    make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} dtbs
    echo "TEST 6"     
fi
cp ${OUTDIR}/linux-stable/arch/${ARCH}/boot/Image ${OUTDIR} #copy the boot image to OUTDIR


echo "Adding the Image in outdir"

echo "Creating the staging directory for the root filesystem"
cd "$OUTDIR"
if [ -d "${OUTDIR}/rootfs" ]
then
	echo "Deleting rootfs directory at ${OUTDIR}/rootfs and starting over"
    sudo rm  -rf ${OUTDIR}/rootfs
fi

# TODO: Create necessary base directories
mkdir -p ${OUTDIR}/rootfs
cd ${OUTDIR}/rootfs
echo "TEST 7"
mkdir -pv bin, dev, etc, home, lib, lib64, proc, sbin, sys, tmp, usr/bin, usr/lib, usr/sbin, var/log

cd "$OUTDIR"
if [ ! -d "${OUTDIR}/busybox" ]
then
git clone git://busybox.net/busybox.git
    cd busybox
    git checkout ${BUSYBOX_VERSION}
    # TODO:  Configure busybox
    echo "TEST 8"
    pwd
    make distclean
    echo "TEST 9"
    make defconfig
    echo "TEST 10"
else
    cd busybox
    echo "TEST 11"
fi

# TODO: Make and install busybox
echo "TEST 12"
make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE}
echo "TEST 13"
make CONFIG_PREFIX=${OUTDIR}/rootfs ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} install
echo "TEST 14"

echo "Library dependencies"
${CROSS_COMPILE}readelf -a bin/busybox | grep "program interpreter"
${CROSS_COMPILE}readelf -a bin/busybox | grep "Shared library"

# TODO: Add library dependencies to rootfs
echo "TEST 15"
SYSROOT_DIR=$(realpath $(${CROSS_COMPILE}gcc --print-sysroot))
#found from Linux Root Filesystems lecture 10:00
echo "TEST 16"
cp ${SYSROOT_DIR}/lib/ld-linux-aarch64.so.1 ${OUTDIR}/rootfs/lib
echo "TEST 17"
cp ${SYSROOT_DIR}/lib64/libc.so.6 ${OUTDIR}/rootfs/lib64
echo "TEST 18"
cp ${SYSROOT_DIR}/lib64/libm.so.6 ${OUTDIR}/rootfs/lib64
echo "TEST 19"
cp ${SYSROOT_DIR}/lib64/libresolv.so.2 ${OUTDIR}/rootfs/lib64

# TODO: Make device nodes
echo "TEST 20"
sudo mknod -m 666 dev/null c 1 3 
sudo mknod -m 666 dev/vonsole c 5 1 

# TODO: Clean and build the writer utility
echo "TEST 21"
cd ${FINDER_APP_DIR}
make clean
make CROSS_COMPILE=${CROSS_COMPILE}
cp ${FINDER_APP_DIR}/writer ${OUTDIR}/rootfs/home

# TODO: Copy the finder related scripts and executables to the /home directory
# on the target rootfs
echo "TEST 22"
cp ${FINDER_APP_DIR}/finder.sh ${OUTDIR}/rootfs/home
cp ${FINDER_APP_DIR}/conf/username.txt ${OUTDIR}/rootfs/home
cp ${FINDER_APP_DIR}/conf/assignment.txt ${OUTDIR}/rootfs/home
cp ${FINDER_APP_DIR}/finder-test.sh ${OUTDIR}/rootfs/home
cp ${FINDER_APP_DIR}/autorun-qemu.sh ${OUTDIR}/rootfs/home

# TODO: Chown the root directory
echo "TEST 23"
sudo chown -R root:root ${OUTDIR}/rootfs

# TODO: Create initramfs.cpio.gz
echo "TEST 24"
cd ${OUTDIR}/rootfs
find . | cpio -H newc -ov --owner root:root > ${OUTDIR}/initramfs.cpio
echo "TEST 25"
cd ../
pwd
gzip -f initramfs.cpio
