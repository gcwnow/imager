#!/bin/bash

source ./partition_layout.sh

echo "Creating master boot record..."
mkdir -p images
./genmbr.py > images/mbr.bin <<EOF
${SYSTEM_START},$((${SYSTEM_END} - ${SYSTEM_START})),0b
${DATA_START},$((800 * 1024 * 2)),83
EOF
