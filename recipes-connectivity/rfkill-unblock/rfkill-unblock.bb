DESCRIPTION="rfkill-unblock"

LICENSE="Apache-2.0"
LIC_FILES_CHKSUM = "file://${WORKDIR}/LICENSE;md5=1dece7821bf3fd70fe1309eaa37d52a2"

FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

inherit systemd

RDEPENDS_${PN} = " rfkill"

SRC_URI="file://LICENSE file://rfkill-unblock.service"

do_install() {
    install -d ${D}${systemd_unitdir}/system/
    install -m 0644 ${WORKDIR}/rfkill-unblock.service ${D}${systemd_unitdir}/system/
}

SYSTEMD_SERVICE_${PN} = "rfkill-unblock.service"
