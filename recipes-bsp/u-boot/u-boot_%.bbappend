FILESEXTRAPATHS_prepend := "${THISDIR}/files/:"

# Use newer version of U-Boot to allow UART work at uboot
SRCREV = "a705ebc81b7f91bbd0ef7c634284208342901149"

PV = "v2017.01+git${SRCPV}"

# Remove the patches added in meta-raspberry. These are already contained in the newer version of U-Boot
# This is an ugly hack, however this becomes obsolete over time when/if yocto updates U-Boot in their morty branch
do_patch_prepend() {
    src_uri = str(bb.data.getVar('SRC_URI', d, 1))
    src_uri = src_uri.replace("file://0001-arm-add-save_boot_params-for-ARM1176.patch", "")
    src_uri = src_uri.replace("file://0002-rpi-passthrough-of-the-firmware-provided-FDT-blob.patch", "")
    src_uri = src_uri.replace("file://0003-Include-lowlevel_init.o-for-rpi2.patch", "")
    bb.data.setVar('SRC_URI', src_uri, d)
}
