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

#pragma pack(push, 1)

typedef struct _DISK_INFO
{
    uint16_t cylinder;
    uint8_t sectors;
    uint8_t heads;
} DISK_INFO_STRUCT;

#pragma pack(pop)


#endif
