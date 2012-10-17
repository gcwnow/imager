#!/bin/bash

ROOTFS=../buildroot/output/images/rootfs.squashfs

# Currently everything runs as root, but that is going to change.
USER_UID=0
USER_GID=0

echo "Checking how to get superuser privileges..."
if (( $UID == 0 ))
then
	echo "running as root"
	SU_CMD="sh -c"
else
	echo -n "sudo: "
	if which sudo
	then
		SU_CMD="sudo sh -c"
	else
		echo 'using "su"'
		SU_CMD="su -c"
	fi
fi
echo

SIZE=$(stat -c %s ${ROOTFS})
if test -e apps/*
then
	for app in apps/*
	do
		SIZE=$((${SIZE} + $(stat -c %s ${app})))
	done
fi
echo "Total data size: ${SIZE} bytes"
echo

# Pick a partition size that is large enough to contain all files but not much
# larger so the image stays small.
IMAGE_SIZE=$((8 + ${SIZE} / (960*1024)))

echo "Creating data partition of ${IMAGE_SIZE} MB..."
mkdir -p images
dd if=/dev/zero of=images/data.bin bs=1M count=${IMAGE_SIZE}
/sbin/mkfs.ext4 -m3 -O ^huge_file -F images/data.bin
echo

echo "Populating data partition..."
echo "(this step needs superuser privileges)"
mkdir mnt
$SU_CMD "
	mount images/data.bin mnt -o loop &&
	install -m 644 -o 0 -g 0 ${ROOTFS} mnt/rootfs.bin &&
	install -m 755 -o ${USER_UID} -g ${USER_GID} -d mnt/apps/ &&
	if test -e apps/*
	then
		install -m 644 -o ${USER_UID} -g ${USER_GID} -t mnt/apps/ apps/*
	fi &&
	install -m 755 -o 0 -g 0 -d mnt/local/etc/init.d &&
	install -m 755 -o 0 -g 0 resize_data_part.target-sh mnt/local/etc/init.d/S00resize &&
	umount mnt
	"
rmdir mnt
