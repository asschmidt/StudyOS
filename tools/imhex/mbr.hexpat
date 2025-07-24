//
// StudyOS - Playground OS for x86, assembly and OS topics
//
// Author: Andreas Schmidt (a.v.schmidt81@googlemail.com)
//
// ImHex Pattern File for Bootsector and FAT12 Information
//
// This file expects the following partition layout
//   MBR: Bootsector with Stage 1 Bootloader
//   Partition 1: Stage 2 Bootloader Partition (Raw Format without FAT)
//   Partition 2: FAT12 Filesystem Partition

#pragma once
#pragma author Andreas Schmidt
#pragma description MBR

import hex.core;
import std.io;
import type.guid;

//
// Enumerations
//

//
// Boot Indicator Enumeration
// Specifies whether the medium is bootable or not
//
enum BOOT_INDICATOR : u8 {
    NoneBoot = 0x00,        // None bootable disk
    Bootable = 0x80         // Bootable disk
};

//
// System-ID Enumeration
// Specifies the System (e.g. FAT12 or FAT16) of the disk
// IDs based on https://aeb.win.tue.nl/partitions/partition_types-1.html
//
enum SYSTEM_ID : u8 {
    Empty       = 0x00,     // No System ID specified
    DOS_FAT12   = 0x01,     // DOS 12 Bit FAT
    DOS_FAT16   = 0x04      // DOS 16 Bit FAT
};

//
// Bitfield definition for CHS Address information
//
bitfield CHS {
    head       : 8;         // Head Number (zero based)
    sector     : 6;         // Sector Number (one based)
    cylinder   : 10;        // Cylinder number (zero based)
};

//
// Union for CHS Bitfield and single-byte data
//
union CHS_ADDRESS {
    u8 adr[3];              // Single Byte value for CHS filed
    CHS chs;                // Bit-Field decoding of CHS field
};

//
// Structure for the Boot-Code of the Bootsector
//
struct BOOT_SECTOR_CODE {
    u8 code[440];           // Byte Array of the Boot-Code
};

//
// Helper Functions
//
namespace format {

    //
    // Format the CHS Address based on the single-byte values
    //
    fn formatCHS(CHS_ADDRESS chsAddress) {
        u32 adrResult = 0x0;

        adrResult = (chsAddress.adr[2] << 16) | (chsAddress.adr[1] << 8) | chsAddress.adr[0];
        return adrResult;
    };
}

//
// Structure for a Partition Table Entry
// The Partition Table in the Bootsector consists of 4 Partition Table Entries
//
struct PARTITION_TABLE_ENTRY {
    BOOT_INDICATOR bootIndicator;               // Boot Indicator for bootable disk
    CHS_ADDRESS chsAddressOfStart;              // CHS Address for the Start of the Partition
    SYSTEM_ID systemID;                         // System-ID of the Partition
    CHS_ADDRESS chsAddressOfEnd;                // CHS Address for the End of the Partition
    u32 lbaStart;                               // LBA Address for the Start of the Parition
    u32 numberOfSectors;                        // Number of Sectors in the Partition
};

//
// Structure for the Master Boot Record (MBR)
// This is the first sector of a disk (not partition!)
//
struct MASTER_BOOT_RECORD {
    BOOT_SECTOR_CODE code;                      // 440 Byte of Bootsector Code
    u32 diskID;                                 // Unique Disk ID
    u16 reserved;                               // Reserved bytes - Should be 0x0000
    PARTITION_TABLE_ENTRY entry1;               // First Entry in Partition Table
    PARTITION_TABLE_ENTRY entry2;               // Second Entry in Partition Table
    PARTITION_TABLE_ENTRY entry3;               // Third Entry in Partition Table
    PARTITION_TABLE_ENTRY entry4;               // Fourth Entry in Partition Table
    u16 signature;                              // MBR Signature - Should be 0x55 0xAA
};