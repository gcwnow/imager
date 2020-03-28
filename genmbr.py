#!/usr/bin/env python3

import os
import struct
import sys

def writeU32LE(out, value):
	out.write(struct.pack('<I', value))

def writeMBR(out, partitions):
	partitions = list(partitions)
	if len(partitions) > 4:
		raise ValueError('Too many partitions (%d)' % len(partitions))
	while len(partitions) < 4:
		partitions.append((0, 0, 0))

	# Jump to start of boot loader in sector 1.
	out.write(b'\x80\0\0\x10')
	out.write(b'\0' * (0x1BE - 4))

	for start, size, typ in partitions:
		# Bootable flag: not needed for Linux.
		out.write(b'\0')
		# First sector CHS: unused.
		out.write(b'\0\0\0')
		# Partition type.
		out.write(bytes([typ]))
		# Last sector CHS: unused.
		out.write(b'\0\0\0')
		# First sector LBA, little endian.
		writeU32LE(out, start)
		# Size in sectors, little endian.
		writeU32LE(out, size)
	out.write(b'\x55\xAA')

def readSpec(inp):
	for line in inp.readlines():
		parts = line.split(',')
		yield (int(parts[0]), int(parts[1]), int(parts[2], 16))

if __name__ == '__main__':
	spec = readSpec(sys.stdin)
	with os.fdopen(sys.stdout.fileno(), 'wb', closefd=False) as out:
		writeMBR(out, spec)
		out.flush()
