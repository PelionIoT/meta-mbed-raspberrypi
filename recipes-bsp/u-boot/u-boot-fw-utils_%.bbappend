FILESEXTRAPATHS_prepend := "${THISDIR}/files/:"

SRC_URI_append = " file://fw_env.config "

do_set_configuration() {
	mv ${WORKDIR}/fw_env.config ${WORKDIR}/git/tools/env
}

addtask set_configuration before do_configure after do_patch
