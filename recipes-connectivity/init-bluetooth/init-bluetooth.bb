DESCRIPTION = "InitV startup script for RPI3 Bluetooth."

LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${WORKDIR}/LICENSE;md5=1dece7821bf3fd70fe1309eaa37d52a2"

FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

SRC_URI = "file://init-bt.sh file://LICENSE"

# Initialization script depends on hciconfig and hciattach
# from Bluez library. 
RDEPENDS_${PN} = " bluez5"

do_install() {
    install -d "${D}${sysconfdir}/init.d"
    install -m 0755 ${WORKDIR}/init-bt.sh ${D}${sysconfdir}/init.d/

    install -d ${D}${sysconfdir}/rc2.d
    install -d ${D}${sysconfdir}/rc3.d
    install -d ${D}${sysconfdir}/rc4.d
    install -d ${D}${sysconfdir}/rc5.d

    ln -sf ../init.d/init-bt.sh  ${D}${sysconfdir}/rc2.d/S28init-bt.sh
    ln -sf ../init.d/init-bt.sh  ${D}${sysconfdir}/rc3.d/S28init-bt.sh
    ln -sf ../init.d/init-bt.sh  ${D}${sysconfdir}/rc4.d/S28init-bt.sh
    ln -sf ../init.d/init-bt.sh  ${D}${sysconfdir}/rc5.d/S28init-bt.sh
}
