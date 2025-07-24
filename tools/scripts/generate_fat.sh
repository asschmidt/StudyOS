#!/bin/bash

#
# Script to generate a FAT file system on the file-system partition
# of the floppy image
#
# REMARK: This scripts needs to be run as root and assumes a file image
# with two partitions whereby the first partition is the bootloader
# partition and the second one is the partition with the file system
#
# Usage: generate_fat.sh [Image Filename]
#

# Setup the loop device with the provided image file name
IMAGE_FILE=$1
LODEVICE=$(sudo losetup --partscan --show --find ${IMAGE_FILE})
echo "Using Loop-Device ${LODEVICE}"

# Create the FAT file system
mkfs.fat -n "LROS" -v -M 0xF0 -i DEADBEEF -D 0 -F 12 ${LODEVICE}p2
#mkfs.fat -n "LROS" -v -M 0xF0 -i DEADBEEF -D 0 -F 12 $IMAGE_FILE

# Remove the loop device
losetup -d $LODEVICE