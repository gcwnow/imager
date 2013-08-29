#!/bin/bash

source ./partition_layout.sh

source ./su_command.sh

echo "Checking presence of kernel files..."
if test -f vmlinuz.bin
then
	SIZE=$(stat -Lc %s vmlinuz.bin)
	echo "vmlinuz.bin: $((${SIZE} / 1024)) kB"
else
	echo "missing main kernel: vmlinuz.bin"
	exit 1
fi
if test -f vmlinuz.bak
then
	SIZE=$(stat -Lc %s vmlinuz.bak)
	echo "vmlinuz.bak: $((${SIZE} / 1024)) kB"
else
	echo "missing fallback kernel: vmlinuz.bak"
	exit 1
fi

echo "Creating system partition..."
echo "(please ignore the warning about not having enough clusters for FAT32)"
IMAGE_SIZE=$((${SYSTEM_END} - ${SYSTEM_START}))
mkdir -p images
dd if=/dev/zero of=images/system.bin bs=512 count=${IMAGE_SIZE} status=noxfer
/sbin/mkdosfs -s 8 -F 32 images/system.bin
echo

echo "Populating data partition..."
echo "(this step needs superuser privileges)"
mkdir mnt
${SU_CMD} "
	mount images/system.bin mnt -o loop &&
	cp vmlinuz.bin mnt/ &&
	( sha1sum mnt/vmlinuz.bin | cut -d' ' -f1 > mnt/vmlinuz.bin.sha1 ) &&
	cp vmlinuz.bak mnt/ &&
	( sha1sum mnt/vmlinuz.bak | cut -d' ' -f1 > mnt/vmlinuz.bak.sha1 ) &&
	umount mnt
	"
rmdir mnt
