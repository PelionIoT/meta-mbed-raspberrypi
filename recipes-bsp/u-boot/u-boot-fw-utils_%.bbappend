FILESEXTRAPATHS_prepend := "${THISDIR}/files/:"

SRC_URI_append = " file://fw_env.config "
SRCREV = "a705ebc81b7f91bbd0ef7c634284208342901149"

PV = "v2017.01+git${SRCPV}"


do_set_configuration() {
	mv ${WORKDIR}/fw_env.config ${WORKDIR}/git/tools/env
}

addtask set_configuration before do_configure after do_patch
