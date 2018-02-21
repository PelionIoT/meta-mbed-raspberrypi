#This different start_getty script is used to replace the getty with agetty

FILESEXTRAPATHS_prepend := "${THISDIR}/files/:"
SRC_URI_append = " file://start_getty "
