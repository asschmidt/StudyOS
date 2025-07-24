//
// StudyOS - Playground OS for x86, assembly and OS topics
//
// Author: Andreas Schmidt (a.v.schmidt81@googlemail.com)
//
// ImHex Pattern File for Volume Boot Record and FAT12 Information
//

#pragma once
#pragma author Andreas Schmidt
#pragma description VBR and FAT12 for StudyOS

import hex.core;
import std.io;
import type.guid;

//
// Enumerations
//

enum MEDIA_DESCRIPTOR_TYPE : u8 {
    EIGHT_INCH_SINGLE_SIDED         = 0xE5,
    FIVE_INC_DOUBLE_SIDED           = 0xED,
    NON_STANDARD_CUSTOM_PART        = 0xEE,
    NON_STANDARD_SUPER_FLOPPY       = 0xEF,
    THREE_INCH_DOUBLE_SIDED         = 0xF0,
    DOUBLE_DENSITY                  = 0xF4,
    FIXED_DISK                      = 0xF5
};


//
// Structure for the BIOS Parameter Block
//
struct BIOS_PARAMETER_BLOCK {
    u8 shortJump[3];                            // EB 3C 90 --> JMP SHORT 3C NOP
    char oemIdent[8];                           // OEM Identifier
    u16 bytesPerSectors;                        // Number of Bytes per Sector
    u8 sectorsPerCluster;                       // Number of Sectors per Cluster
    u16 reservedSectors;                        // Number of Reserved Sectors
    u8 fatCount;                                // Number of FATs on the media (usually this is 2)
    u16 rootEntryCounter;                       // Number of Root-Directory Entries in the FAT
    u16 totalSectors;                           // Total Sectors in logical volume
    MEDIA_DESCRIPTOR_TYPE mediaDescriptorType;  // Media Descriptor Byte of the partition
    u16 sectorsPerFAT;                          // Number of Sectors per FAT (FAT12/FAT16 only)
    u16 sectorsPerTrack;                        // Number of Sectors per Track
    u16 heads;                                  // Number of Heads for the media
    u32 hiddenSectors;                          // Number of hidden Sectors in the partition
    u32 largeSectorCount;                       // Large sector count
};

//
// Structure for the Volume Boot Record (VBR)
// This is the first sector of a parition and contains the BIOS Parameter Block (BPB)
// and in most cases file-system related information (e.g. FAT data)
//
struct VOLUMNE_BOOT_RECORD {
    BIOS_PARAMETER_BLOCK bpl;                   // BIOS Parameter Block of the VBR
};