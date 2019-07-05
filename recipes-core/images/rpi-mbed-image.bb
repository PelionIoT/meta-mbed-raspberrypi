# Base this image on rpi-basic-image
include recipes-core/images/rpi-mbed-core-image.bb

LICENSE = "Apache-2.0"

MACHINE = "raspberrypi3"

# Include modules in rootfs
IMAGE_INSTALL += " init-bluetooth "

IMAGE_INSTALL_append = "${@bb.utils.contains('DISTRO_FEATURES', 'systemd', ' rfkill-unblock', '', d)}"
IMAGE_INSTALL_remove = "${@bb.utils.contains('DISTRO_FEATURES', 'systemd', 'init-bluetooth', '', d)}"
