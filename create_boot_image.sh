#!/bin/bash

source ./partition_layout.sh

echo "Creating boot sector..."
mkdir -p temp
./genmbr.py > temp/bootsector.bin <<EOF
${KERNEL_START},$((${KERNEL_END} - ${KERNEL_START})),0b
${DATA_START},$((800 * 1024 * 2)),83
EOF

echo "Creating boot image..."
mkdir -p images
dd if=/dev/zero of=images/boot.bin bs=512 count=${KERNEL_START} status=noxfer
dd seek=0  if=temp/bootsector.bin of=images/boot.bin conv=notrunc bs=512 status=noxfer
dd seek=16 if=temp/bootsector.bin of=images/boot.bin conv=notrunc bs=512 status=noxfer
dd seek=1  if=ubiboot.bin of=images/boot.bin conv=notrunc bs=512 status=noxfer
dd seek=17 if=ubiboot.bin of=images/boot.bin conv=notrunc bs=512 status=noxfer
