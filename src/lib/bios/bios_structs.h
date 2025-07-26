/*
 * BIOS Structs Module
 *
 * This module only provides structure definitions for lib bios to help debugging
 *
 */

#ifndef _BIOS_STRUCTS_H_
#define _BIOS_STRUCTS_H_

#include <stddef.h>
#include <stdint.h>

/*
 * Disk Info Struct contains information from BIOS about
 * the a disk in a drive
 */
#pragma pack(push, 1)
typedef struct _DISK_INFO
{
    uint16_t cylinder;          // Number of Cylinder on Disk
    uint8_t sectors;            // Number of Sectors per Cylinder
    uint8_t heads;              // Number of Heads
} DISK_INFO_STRUCT;
#pragma pack(pop)


#endif
