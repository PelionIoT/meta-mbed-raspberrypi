FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

SRC_URI_append = " file://defconfig file://crontab "

do_install_append() {
    # Install start-up script for cron
    mkdir -p ${D}${sysconfdir}/cron/crontabs
    install -p -m 755 ${WORKDIR}/crontab ${D}${sysconfdir}/cron/crontabs/root

    install -d ${D}${sysconfdir}/rc0.d
    install -d ${D}${sysconfdir}/rc1.d
    install -d ${D}${sysconfdir}/rc2.d
    install -d ${D}${sysconfdir}/rc3.d
    install -d ${D}${sysconfdir}/rc4.d
    install -d ${D}${sysconfdir}/rc5.d
    install -d ${D}${sysconfdir}/rc6.d

    ln -sf ../init.d/busybox-cron      ${D}${sysconfdir}/rc0.d/K60busybox-cron
    ln -sf ../init.d/busybox-cron      ${D}${sysconfdir}/rc1.d/K60busybox-cron
    ln -sf ../init.d/busybox-cron      ${D}${sysconfdir}/rc2.d/S90busybox-cron
    ln -sf ../init.d/busybox-cron      ${D}${sysconfdir}/rc3.d/S90busybox-cron
    ln -sf ../init.d/busybox-cron      ${D}${sysconfdir}/rc4.d/S90busybox-cron
    ln -sf ../init.d/busybox-cron      ${D}${sysconfdir}/rc5.d/S90busybox-cron
    ln -sf ../init.d/busybox-cron      ${D}${sysconfdir}/rc6.d/K60busybox-cron
}
