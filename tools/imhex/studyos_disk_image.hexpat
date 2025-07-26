//
// StudyOS - Playground OS for x86, assembly and OS topics
//
// Author: Andreas Schmidt (a.v.schmidt81@googlemail.com)
//
// ImHex Pattern File for Study OS Disk Image
//
// This file expects the following partition layout
//   MBR: Bootsector with Stage 1 Bootloader
//   Partition 1: Stage 2 Bootloader Partition (Raw Format without FAT)
//   Partition 2: FAT12 Filesystem Partition

#pragma author Andreas Schmidt
#pragma description StudyOS Disk Image

import hex.core;
import std.io;
import type.guid;

#include "/home/andreas/OpenSource/StudyOS/tools/imhex/mbr.hexpat"
#include "/home/andreas/OpenSource/StudyOS/tools/imhex/vbr.hexpat"

// Get current selection in Hex Editor
hex::core::Selection sel = hex::core::get_selection();
// Use selection as Start-Address for MBR
u64 mbrStart = sel.address;

MASTER_BOOT_RECORD mbr @ mbrStart;

// Determine second partition start
u64 entry2Start = mbr.entry2.lbaStart * 512;
VOLUMNE_BOOT_RECORD bootRecord1 @ entry2Start;