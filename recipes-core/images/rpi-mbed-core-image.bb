# Base this image on rpi-basic-image
include recipes-core/images/core-image-minimal.bb
include recipes-core/mount-dirs/mount-dirs.bb

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
