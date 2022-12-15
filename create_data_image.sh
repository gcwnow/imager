#!/usr/bin/env bash

set -euo pipefail

echo "Gathering applications..."
mapfile -d $'\0' APPS < <(find apps/ -maxdepth 1 -type f -name '*.opk' -print0)
if (( ${#APPS[@]} )); then
	echo "${#APPS[@]} applications"
	du -Lhc "${APPS[@]}"
	APPS_SIZE="$(du -Lbc apps/*.opk | tail -1 | cut -f1)"
else
	echo "No application found in apps/*.opk"
	APPS_SIZE=0
fi
echo

echo "Preparing data for the data partition..."
rm -rf tmp-data
mkdir tmp-data
install -m 755 -d tmp-data/apps
if (( ${#APPS[@]} )); then
	install -m 644 -t tmp-data/apps/ "${APPS[@]}"
fi
install -m 755 -d tmp-data/local/etc/init.d
install -m 755 resize_data_part.target-sh tmp-data/local/etc/init.d/S00resize

# Pick a partition size that is large enough to contain all files but not much
# larger so the image stays small.
IMAGE_SIZE=$((8 + APPS_SIZE / (920*1024)))

echo "Creating data partition of ${IMAGE_SIZE} MB..."
mkdir -p images
dd if=/dev/zero of=images/data.bin bs=1M count=${IMAGE_SIZE}
MKE2FS_CONFIG=mke2fs.conf /sbin/mke2fs -t od-data \
  -d tmp-data -F images/data.bin
rm -rf tmp-data
