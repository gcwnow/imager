#!/bin/sh
set -e
. ./partition_layout.sh

u32_le() {
  printf '%08X' "$1" | rev | fold -b -w2 | rev | xargs printf '\\x%s'
}

add_partition() {
  # Bootable flag: not needed for Linux.
  S="$S"'\0'
  # First sector CHS: unused.
  S="$S"'\0\0\0'
  # Partition type
  S="$S"'\x'"$1"
  # Last sector CHS: unused.
  S="$S"'\0\0\0'
  # First sector LBA, little endian.
  S="$S$(u32_le "$2")"
  # Size in sectors, little endian.
  S="$S$(u32_le "$3")"
}

echo "Creating master boot record..."

# Jump to start of boot loader in sector 1.
S='\x80\0\0\x10'"$(printf '\\0%.0s' $(seq $((0x1BE - 4))))"
add_partition 0B "$SYSTEM_START" $((DATA_START - SYSTEM_START))
add_partition 83 "$DATA_START" $((800 * 1024 * 2))
add_partition 0 0 0
add_partition 0 0 0
S="$S"'\x55\xAA'

mkdir -p images
/bin/echo -e -n "$S" > images/mbr.bin

