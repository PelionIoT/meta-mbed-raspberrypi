inherit image_types

# Create an image that contains following partitions:
# Boot: Raspberry Pi bootloaders, u-boot and other mandatory booting software
# Bootflags: Flags used by the u-boot script
# Rootfilesystem 1: Linux rootfilesystem 1. Two partitions exist for the firmware update that switches between partitions
# Rootfilesystem 2: Linux rootfilesystem 2.
# Config: Mbed Edge and Cloud Client configuration files
# Cache: Temporary cache for the downloaded firmware image. Should be large enough to contain a tar.bz2 compressed rootfilesystem

# This image depends on the rootfs image
IMAGE_TYPEDEP_mbed-sdimg = "rpi-sdimg"

# Set kernel and boot loader
IMAGE_BOOTLOADER ?= "bcm2835-bootfiles"

# Set initramfs extension
KERNEL_INITRAMFS ?= "-initramfs"

# Kernel image name
SDIMG_KERNELIMAGE_raspberrypi  ?= "kernel.img"
SDIMG_KERNELIMAGE_raspberrypi2 ?= "kernel7.img"
SDIMG_KERNELIMAGE_raspberrypi3-64 ?= "kernel8.img"

# Boot partition volume id
BOOTDD_VOLUME_ID ?= "${MACHINE}"

# Boot partition size [in KiB] (will be rounded up to IMAGE_ROOTFS_ALIGNMENT)
BOOT_SPACE ?= "40960"

# Size of other non-rootfilesystem partitions
BOOTFLAGS_SIZE="20480"
CONFIG_SIZE="40960"
CACHE_SIZE="$(expr ${ROOTFS_SIZE} + ${ROOTFS_SIZE} / 2)"

# Set alignment to 4MB [in KiB]
IMAGE_ROOTFS_ALIGNMENT = "4096"

# Use an uncompressed ext3 by default as rootfs
SDIMG_ROOTFS_TYPE ?= "ext3"
SDIMG_ROOTFS = "${IMGDEPLOYDIR}/${IMAGE_LINK_NAME}.${SDIMG_ROOTFS_TYPE}"

do_image_mbed_sdimg[depends] = " \
			parted-native:do_populate_sysroot \
			mtools-native:do_populate_sysroot \
			dosfstools-native:do_populate_sysroot \
			e2fsprogs-native:do_populate_sysroot \
			virtual/kernel:do_deploy \
			${IMAGE_BOOTLOADER}:do_deploy \
			${@bb.utils.contains('RPI_USE_U_BOOT', '1', 'u-boot:do_deploy', '',d)} \
			"

# SD card image name
SDIMG = "${IMGDEPLOYDIR}/${IMAGE_NAME}.rootfs.rpi-sdimg"

# Compression method to apply to SDIMG after it has been created. Supported
# compression formats are "gzip", "bzip2" or "xz". The original .rpi-sdimg file
# is kept and a new compressed file is created if one of these compression
# formats is chosen. If SDIMG_COMPRESSION is set to any other value it is
# silently ignored.
#SDIMG_COMPRESSION ?= ""

# Additional files and/or directories to be copied into the vfat partition from the IMAGE_ROOTFS.
FATPAYLOAD ?= ""

# SD card vfat partition image name
SDIMG_VFAT = "${IMAGE_NAME}.vfat"
SDIMG_LINK_VFAT = "${IMGDEPLOYDIR}/${IMAGE_LINK_NAME}.vfat"

def split_overlays(d, out, ver=None):
    dts = d.getVar("KERNEL_DEVICETREE")
    if out:
        overlays = oe.utils.str_filter_out('\S+\-overlay\.dtb$', dts, d)
        overlays = oe.utils.str_filter_out('\S+\.dtbo$', overlays, d)
    else:
        overlays = oe.utils.str_filter('\S+\-overlay\.dtb$', dts, d) + \
                   " " + oe.utils.str_filter('\S+\.dtbo$', dts, d)

    return overlays

IMAGE_CMD_mbed-sdimg () {

	# Align partitions
	BOOT_SPACE_ALIGNED=$(expr ${BOOT_SPACE} + ${IMAGE_ROOTFS_ALIGNMENT} - 1)
	BOOT_SPACE_ALIGNED=$(expr ${BOOT_SPACE_ALIGNED} - ${BOOT_SPACE_ALIGNED} % ${IMAGE_ROOTFS_ALIGNMENT})
	SDIMG_SIZE=$(expr ${IMAGE_ROOTFS_ALIGNMENT} + ${BOOT_SPACE_ALIGNED} + ${ROOTFS_SIZE} + ${ROOTFS_SIZE} + ${BOOTFLAGS_SIZE} + ${CONFIG_SIZE} + ${CACHE_SIZE})

	echo "Creating filesystem with Boot partition ${BOOT_SPACE_ALIGNED} KiB and RootFS $ROOTFS_SIZE KiB"

	# Check if we are building with device tree support
	DTS="${KERNEL_DEVICETREE}"

	# Initialize sdcard image file
	dd if=/dev/zero of=${SDIMG} bs=1024 count=0 seek=${SDIMG_SIZE}

	# Create partition table
	parted -s ${SDIMG} mklabel msdos
	# Create boot partition and mark it as bootable
	parted -s ${SDIMG} unit KiB mkpart primary fat32 ${IMAGE_ROOTFS_ALIGNMENT} $(expr ${BOOT_SPACE_ALIGNED} \+ ${IMAGE_ROOTFS_ALIGNMENT})
	parted -s ${SDIMG} set 1 boot on

	#Calculate aligned addresses for additional partitions
	BOOTFLAGSSTART=$(expr ${BOOT_SPACE_ALIGNED} \+ ${IMAGE_ROOTFS_ALIGNMENT} \+ 1)
	BOOTFLAGSSTART=$(expr ${BOOTFLAGSSTART} - ${BOOTFLAGSSTART} % ${IMAGE_ROOTFS_ALIGNMENT})
	BOOTFLAGSEND=$(expr ${BOOTFLAGSSTART} \+ ${BOOTFLAGS_SIZE})

	RFS1START=$(expr ${BOOTFLAGSEND} \+ ${IMAGE_ROOTFS_ALIGNMENT})
	RFS1START=$(expr ${RFS1START} - ${RFS1START} % ${IMAGE_ROOTFS_ALIGNMENT})
	RFS1END=$(expr ${RFS1START} \+ ${ROOTFS_SIZE})

	RFS2START=$(expr $RFS1END \+ ${IMAGE_ROOTFS_ALIGNMENT})
	RFS2START=$(expr ${RFS2START} - ${RFS2START} % ${IMAGE_ROOTFS_ALIGNMENT})
	RFS2END=$(expr ${RFS2START} \+ ${ROOTFS_SIZE})

	CONFIGSTART=$(expr $RFS2END \+ ${IMAGE_ROOTFS_ALIGNMENT})
	CONFIGSTART=$(expr ${CONFIGSTART} - ${CONFIGSTART} % ${IMAGE_ROOTFS_ALIGNMENT})
	CONFIGEND=$(expr ${CONFIGSTART} \+ ${CONFIG_SIZE})

	CACHESTART=$(expr $CONFIGEND \+ ${IMAGE_ROOTFS_ALIGNMENT})
	CACHESTART=$(expr ${CACHESTART} - ${CACHESTART} % ${IMAGE_ROOTFS_ALIGNMENT})
	CACHEEND="-1s"

	#Create additional partitions
	parted -s ${SDIMG} -- unit KiB mkpart primary ext2 ${BOOTFLAGSSTART} ${BOOTFLAGSEND}
	parted ${SDIMG} print

	parted -s ${SDIMG} -- unit KiB mkpart extended $(expr ${RFS1START} \- ${IMAGE_ROOTFS_ALIGNMENT}) -1s
	parted ${SDIMG} print

	parted -s ${SDIMG} -- unit KiB mkpart logical ext2 $(expr ${RFS1START}) ${RFS1END}
	parted ${SDIMG} print

	parted -s ${SDIMG} -- unit KiB mkpart logical ext2 ${RFS2START} ${RFS2END}
	parted ${SDIMG} print

	parted -s ${SDIMG} -- unit KiB mkpart logical ext2 ${CONFIGSTART} ${CONFIGEND}
	parted ${SDIMG} print

	parted -s ${SDIMG} -- unit KiB mkpart logical ext2 ${CACHESTART} ${CACHEEND}
	parted ${SDIMG} print

	# Create a vfat image with boot files
	BOOT_BLOCKS=$(LC_ALL=C parted -s ${SDIMG} unit b print | awk '/ 1 / { print substr($4, 1, length($4 -1)) / 512 /2 }')
	rm -f ${WORKDIR}/boot.img
	mkfs.vfat -n "${BOOTDD_VOLUME_ID}" -S 512 -C ${WORKDIR}/boot.img $BOOT_BLOCKS
	mcopy -i ${WORKDIR}/boot.img -s ${DEPLOY_DIR_IMAGE}/bcm2835-bootfiles/* ::/
	if test -n "${DTS}"; then
		# Device Tree Overlays are assumed to be suffixed by '-overlay.dtb' (4.1.x) or by '.dtbo' (4.4.9+) string and will be put in a dedicated folder
		DT_OVERLAYS="${@split_overlays(d, 0)}"
		DT_ROOT="${@split_overlays(d, 1)}"

		# Copy board device trees to root folder
		for DTB in ${DT_ROOT}; do
			DTB_BASE_NAME=`basename ${DTB} .dtb`

			mcopy -i ${WORKDIR}/boot.img -s ${DEPLOY_DIR_IMAGE}/${KERNEL_IMAGETYPE}-${DTB_BASE_NAME}.dtb ::${DTB_BASE_NAME}.dtb
		done

		# Copy device tree overlays to dedicated folder
		mmd -i ${WORKDIR}/boot.img overlays
		for DTB in ${DT_OVERLAYS}; do
				DTB_EXT=${DTB##*.}
				DTB_BASE_NAME=`basename ${DTB} ."${DTB_EXT}"`

			mcopy -i ${WORKDIR}/boot.img -s ${DEPLOY_DIR_IMAGE}/${KERNEL_IMAGETYPE}-${DTB_BASE_NAME}.${DTB_EXT} ::overlays/${DTB_BASE_NAME}.${DTB_EXT}
		done
	fi
	if [ "${RPI_USE_U_BOOT}" = "1" ]; then
		mcopy -i ${WORKDIR}/boot.img -s ${DEPLOY_DIR_IMAGE}/u-boot.bin ::${SDIMG_KERNELIMAGE}
		mcopy -i ${WORKDIR}/boot.img -s ${DEPLOY_DIR_IMAGE}/boot.scr ::boot.scr
		mcopy -i ${WORKDIR}/boot.img -s ${DEPLOY_DIR_IMAGE}/${KERNEL_IMAGETYPE}-${MACHINE}.bin ::${KERNEL_IMAGETYPE}
	else
		mcopy -i ${WORKDIR}/boot.img -s ${DEPLOY_DIR_IMAGE}/${KERNEL_IMAGETYPE}${KERNEL_INITRAMFS}-${MACHINE}.bin ::${SDIMG_KERNELIMAGE}
	fi

	if [ -n ${FATPAYLOAD} ] ; then
		echo "Copying payload into VFAT"
		for entry in ${FATPAYLOAD} ; do
				# add the || true to stop aborting on vfat issues like not supporting .~lock files
				mcopy -i ${WORKDIR}/boot.img -s -v ${IMAGE_ROOTFS}$entry :: || true
		done
	fi

	# Add stamp file
	echo "${IMAGE_NAME}" > ${WORKDIR}/image-version-info
	mcopy -i ${WORKDIR}/boot.img -v ${WORKDIR}/image-version-info ::

        # Deploy vfat partition (for u-boot case only)
        if [ "${RPI_USE_U_BOOT}" = "1" ]; then
                cp ${WORKDIR}/boot.img ${IMGDEPLOYDIR}/${SDIMG_VFAT}
                ln -sf ${SDIMG_VFAT} ${SDIMG_LINK_VFAT}
        fi

	# Burn Partitions
	dd if=${WORKDIR}/boot.img of=${SDIMG} conv=notrunc seek=1 bs=$(expr ${IMAGE_ROOTFS_ALIGNMENT} \* 1024)
	# If SDIMG_ROOTFS_TYPE is a .xz file use xzcat
	if echo "${SDIMG_ROOTFS_TYPE}" | egrep -q "*\.xz"
	then
		xzcat ${SDIMG_ROOTFS} | dd of=${SDIMG} conv=notrunc seek=1 bs=$(expr 1024 \* ${RFS1START})
		xzcat ${SDIMG_ROOTFS} | dd of=${SDIMG} conv=notrunc seek=1 bs=$(expr 1024 \* ${RFS2START})
	else
		#Add label to rootfs partition
		tune2fs -L rootfs1 ${SDIMG_ROOTFS}
		dd if=${SDIMG_ROOTFS} of=${SDIMG} conv=notrunc seek=1 bs=$(expr 1024 \* ${RFS1START})
		tune2fs -L rootfs2 ${SDIMG_ROOTFS}
		dd if=${SDIMG_ROOTFS} of=${SDIMG} conv=notrunc seek=1 bs=$(expr 1024 \* ${RFS2START})
		#Reset the label back to empty
		tune2fs -L "" ${SDIMG_ROOTFS}

		#create empty BOOTFLAGS partition
		dd if=/dev/zero of=${IMGDEPLOYDIR}/bootflags.ext3 seek=${BOOTFLAGS_SIZE} count=0 bs=1k
		mkfs.ext3 -L bootflags -F $extra_imagecmd ${IMGDEPLOYDIR}/bootflags.ext3
		dd if=${IMGDEPLOYDIR}/bootflags.ext3 of=${SDIMG} conv=notrunc seek=1 bs=$(expr 1024 \* ${BOOTFLAGSSTART})

		#create empty CONFIG partition
		dd if=/dev/zero of=${IMGDEPLOYDIR}/config.ext3 seek=${CONFIG_SIZE} count=0 bs=1k
		mkfs.ext3 -L config -F $extra_imagecmd ${IMGDEPLOYDIR}/config.ext3
		dd if=${IMGDEPLOYDIR}/config.ext3 of=${SDIMG} conv=notrunc seek=1 bs=$(expr 1024 \* ${CONFIGSTART})

		#create empty CACHE partition
		dd if=/dev/zero of=${IMGDEPLOYDIR}/cache.ext3 seek=$(expr ${SDIMG_SIZE} \- ${CACHESTART}) count=0 bs=1k
		mkfs.ext3 -L "cache" -F $extra_imagecmd ${IMGDEPLOYDIR}/cache.ext3
		dd if=${IMGDEPLOYDIR}/cache.ext3 of=${SDIMG} conv=notrunc seek=1 bs=$(expr 1024 \* ${CACHESTART})
	fi

	# Optionally apply compression
	case "${SDIMG_COMPRESSION}" in
	"gzip")
		gzip -k9 "${SDIMG}"
		;;
	"bzip2")
		bzip2 -k9 "${SDIMG}"
		;;
	"xz")
		xz -k "${SDIMG}"
		;;
	esac
}

ROOTFS_POSTPROCESS_COMMAND += " rpi_generate_sysctl_config ; "

rpi_generate_sysctl_config() {
	# systemd sysctl config
	test -d ${IMAGE_ROOTFS}${sysconfdir}/sysctl.d && \
		echo "kernel.core_uses_pid = 1" >> ${IMAGE_ROOTFS}${sysconfdir}/sysctl.d/rpi-vm.conf && \
		echo "kernel.core_pattern = /var/log/core" >> ${IMAGE_ROOTFS}${sysconfdir}/sysctl.d/rpi-vm.conf && \
		echo "vm.min_free_kbytes = 8192" > ${IMAGE_ROOTFS}${sysconfdir}/sysctl.d/rpi-vm.conf

	# sysv sysctl config
	IMAGE_SYSCTL_CONF="${IMAGE_ROOTFS}${sysconfdir}/sysctl.conf"
	test -e ${IMAGE_ROOTFS}${sysconfdir}/sysctl.conf && \
		sed -e "/kernel.core_uses_pid/d" -i ${IMAGE_SYSCTL_CONF}
		echo "" >> ${IMAGE_SYSCTL_CONF} && echo "kernel.core_uses_pid = 1" >> ${IMAGE_SYSCTL_CONF}

	test -e ${IMAGE_ROOTFS}${sysconfdir}/sysctl.conf && \
		sed -e "/kernel.core_pattern/d" -i ${IMAGE_SYSCTL_CONF} && \
		sed -e "/vm.min_free_kbytes/d" -i ${IMAGE_SYSCTL_CONF}

	echo "" >> ${IMAGE_SYSCTL_CONF} && echo "kernel.core_pattern = /var/log/core" >> ${IMAGE_SYSCTL_CONF}
	echo "" >> ${IMAGE_SYSCTL_CONF} && echo "vm.min_free_kbytes = 8192" >> ${IMAGE_SYSCTL_CONF}
}
