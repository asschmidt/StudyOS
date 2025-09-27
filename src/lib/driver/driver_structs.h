/*
 * Driver Structs Module
 *
 * This module provides structure definitions for lib_driver to help debugging
 *
 */

#ifndef _DRIVER_H
#define _DRIVER_H


#include <stddef.h>
#include <stdint.h>

#pragma pack(push, 1)

typedef struct _VIDEO_TEXTMODE_DRIVER {
    int32_t videoMemoryBaseAdr;             // 4 Byte
    int32_t videoMemoryOffset;              // 4 Byte
    int32_t videoMemoryAdr;                 // 4 Byte
} VIDEO_TEXTMODE_DRIVER;

#pragma pack(pop)

#endif
