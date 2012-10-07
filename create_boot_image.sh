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
cp temp/bootsector.bin images/boot.bin
cat uboot-stage1.bin >> images/boot.bin
cat temp/bootsector.bin >> images/boot.bin
cat uboot-stage1.bin >> images/boot.bin
dd if=/dev/zero bs=512 count=1 >> images/boot.bin
cat uboot-stage2.bin >> images/boot.bin
SIZE=$(stat -c %s images/boot.bin)
dd if=/dev/zero bs=512 count=$((${KERNEL_START} - ${SIZE} / 512)) >> images/boot.bin
