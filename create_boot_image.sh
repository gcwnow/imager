#!/bin/bash

# Partition start sectors.
KERNEL_START=8192
DATA_START=32768

echo "Creating boot sector..."
mkdir -p temp
./genmbr.py > temp/bootsector.bin <<EOF
${KERNEL_START},$((${DATA_START} - ${KERNEL_START})),f0
${DATA_START},$((800 * 1024 * 2)),83
EOF

echo "Creating boot image..."
mkdir -p images
dd if=/dev/zero of=images/boot.bin bs=512 count=${KERNEL_START} status=noxfer
dd seek=0  if=temp/bootsector.bin of=images/boot.bin conv=notrunc bs=512 status=noxfer
dd seek=16 if=temp/bootsector.bin of=images/boot.bin conv=notrunc bs=512 status=noxfer
dd seek=1  if=uboot-stage1.bin of=images/boot.bin conv=notrunc bs=512 status=noxfer
dd seek=17 if=uboot-stage1.bin of=images/boot.bin conv=notrunc bs=512 status=noxfer
dd seek=33 if=uboot-stage2.bin of=images/boot.bin conv=notrunc bs=512 status=noxfer
