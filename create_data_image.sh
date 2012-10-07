#!/bin/bash

ROOTFS=../buildroot/output/images/rootfs.squashfs
mkdir -p apps

SIZE=$(stat -c %s ${ROOTFS})
for app in apps/*
do
	SIZE=$((${SIZE} + $(stat -c %s ${app})))
done
echo "Total data size: ${SIZE} bytes"

# Pick a partition size that is large enough to contain all files but not much
# larger so the image stays small.
IMAGE_SIZE=$((8 + ${SIZE} / (960*1024)))

echo "Creating data partition of ${IMAGE_SIZE} MB..."
mkdir -p images
dd if=/dev/zero of=images/data.bin bs=1M count=${IMAGE_SIZE}
/sbin/mkfs.ext4 -m3 -O ^huge_file -F images/data.bin

echo "Populating data partition..."
echo "(this step needs superuser privileges for mounting the data partition)"
mkdir mnt
sudo mount images/data.bin mnt -o loop
cp ${ROOTFS} mnt/rootfs.bin
cp -r apps mnt/
mkdir -p mnt/local/etc/init.d
cp resize_data_part.target-sh mnt/local/etc/init.d/S00resize
chmod a+x mnt/local/etc/init.d/S00resize
sudo umount mnt
rmdir mnt
