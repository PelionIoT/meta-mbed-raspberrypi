DESCRIPTION = "Mount dir generation recipe."
LICENSE = "Apache-2.0"

create_mnt_dirs() {
   mkdir -p ${IMAGE_ROOTFS}/mnt/flags
   mkdir -p ${IMAGE_ROOTFS}/mnt/config
   mkdir -p ${IMAGE_ROOTFS}/mnt/cache
   mkdir -p ${IMAGE_ROOTFS}/mnt/root
}

ROOTFS_POSTPROCESS_COMMAND += "create_mnt_dirs;"
