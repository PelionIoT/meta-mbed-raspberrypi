# Base this image on rpi-basic-image
include recipes-core/images/rpi-hwup-image.bb
include recipes-core/mount-images/mount-images.bb

LICENSE = "Apache-2.0"

MACHINE = "raspberrypi3"

# Include modules in rootfs
IMAGE_INSTALL += " \
	u-boot-fw-utils \
	util-linux-agetty \
	util-linux \
	rng-tools \
	logrotate \
	e2fsprogs"

