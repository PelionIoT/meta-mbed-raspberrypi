setenv sd_device                        0;
setenv flag_part_no                     2;
setenv part_five                        5;
setenv part_six                         6;
setenv root_part_no          ${part_five};
setenv dtb_file_path /boot/bbb-nohdmi.dtb;
setenv img_file_path      /usr/src/uImage;
setenv env_file_path       /boot/uEnv.txt;
setenv rootfs_type                   ext4;
setenv debug_prefix         "[boot.scr] ";

# load bootargs from previous stage bootloader
fdt addr ${fdt_addr} && fdt get value bootargs /chosen bootargs;

# check which partition to boot into
setenv flag_part ${sd_device}:${flag_part_no};
echo ${debug_prefix}"Detecting boot flags in mmc ${flag_part}...";
if test -e mmc ${flag_part} /five; then
    echo ${debug_prefix}"found boot flag for partition "${part_five};
    setenv root_part_no ${part_five};
elif test -e mmc ${flag_part} /six; then
    echo ${debug_prefix}"found boot flag for partition "${part_six};
    setenv root_part_no ${part_six};
else
    echo "${debug_prefix}Warning: No boot flags found, booting into default partition: ${root_part_no}"
fi;

# allow behaviour to be changed by the updated image
setenv boot_part ${sd_device}:${root_part_no};
echo ${debug_prefix}"Detecting ${env_file_path} in mmc ${boot_part}...";
if test -e mmc ${boot_part} ${env_file_path}; then
    echo ${debug_prefix}"Importing Environemnts from ${env_file_path}";
    load mmc ${boot_part} ${kernel_addr_r} ${env_file_path};
    env import -t ${kernel_addr_r} ${filesize};
fi;

# boot into partition
echo ${debug_prefix}"Booting into partition mmc ${boot_part}...";
if test -e mmc ${boot_part} ${img_file_path}; then
    load mmc ${boot_part} ${kernel_addr_r} ${img_file_path};
    setenv bootargs "${bootargs} root=/dev/mmcblk${sd_device}p${root_part_no} rootfstype=${rootfs_type}";
    echo "bootargs=${bootargs}"
    bootm ${kernel_addr_r} - ${fdt_addr};
else
    echo ${debug_prefix}"${img_file_path} not found in mmc ${boot_part}";
    echo ${debug_prefix}"fail to boot";
fi;
