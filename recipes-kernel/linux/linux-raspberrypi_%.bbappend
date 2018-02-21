
# CMDLINE for raspberrypi (change the partition number)
CMDLINE = "dwc_otg.lpm_enable=0 console=serial0,115200 root=/dev/mmcblk0p5 rootfstype=ext4 rootwait"

# Add the kernel debugger over console kernel command line option if enabled
CMDLINE_append = ' ${@base_conditional("ENABLE_KGDB", "1", "kgdboc=serial0,115200", "", d)}'

# Add the uImage kernel to the root file system
do_install_append() {
    install -d ${D}/usr/src
    install -m 0600 ${WORKDIR}/linux-raspberrypi3-standard-build/arch/arm/boot/uImage ${D}/usr/src/uImage
}

FILES_kernel-base += " \
    /usr \
    /usr/src \
    /usr/src/uImage \
    "
