# Base this image on rpi-basic-image
include recipes-core/images/core-image-minimal.bb

LICENSE = "Apache-2.0"

MACHINE = "raspberrypi3"

# Include modules in rootfs
IMAGE_INSTALL += " \
        ldd \
        u-boot-fw-utils \
        logrotate \
        util-linux-agetty \
        util-linux \
        rng-tools \
        e2fsprogs \
        kernel-modules"

create_mnt_dirs() {
   mkdir -p ${IMAGE_ROOTFS}/mnt/flags
   mkdir -p ${IMAGE_ROOTFS}/mnt/config
   mkdir -p ${IMAGE_ROOTFS}/mnt/cache
   mkdir -p ${IMAGE_ROOTFS}/mnt/root
}

ROOTFS_POSTPROCESS_COMMAND += "create_mnt_dirs;"

#Required for libglib read-only filesystem support
DEPENDS += " qemuwrapper-cross "

IMAGE_FEATURES += " read-only-rootfs "
