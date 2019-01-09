# Base this image on rpi-basic-image
include recipes-core/images/core-image-minimal.bb
include recipes-core/mount-dirs/mount-dirs.bb

LICENSE = "Apache-2.0"

MACHINE = "raspberrypi3"

# Include modules in rootfs
IMAGE_INSTALL += " \
	u-boot-fw-utils \
	util-linux-agetty \
	util-linux \
	rng-tools \
	logrotate \
	kernel-modules \
	e2fsprogs \
	init-bluetooth"

