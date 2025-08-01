#!/bin/bash

#
# Scripts to generate the Floppy disk image including a partition table
# with the following layout
#
# Bootloader Partition: Sector 1 - 65 kiB
# File System Partition: 64 kiB - End of Disk
#
# Commandline Parameter: generate_floppy.sh [Image-Filename]
#
# Currently we have 2880 Sectors, each 512 Byte ==> 1474560 Byte -> 1,44 MiB
# Sector 1: Bootsector
# Sector 257: Start of File-System Partition

echo "Generating Image-File with 1,44 MiB"
dd if=/dev/zero of=$1 bs=512 count=2880 >/dev/null

echo "Creating Partition Table"
parted -s $1 mktable msdos
echo "Creating Bootloader Stage 2 Partition"
parted -s $1 -- mkpart primary fat16 1s 256s
echo "Creating Kernel & FAT12 Filesystem Partition"
parted -s $1 -- mkpart primary fat16 257s -1s
#parted -s $1 set on boot 0
fdisk -lu $1