#!/bin/bash

source ./partition_layout.sh

cp images/boot.bin images/sd_image.bin
dd if=images/kernel.bin of=images/sd_image.bin seek=${KERNEL_START}
dd if=images/data.bin of=images/sd_image.bin seek=${DATA_START}
