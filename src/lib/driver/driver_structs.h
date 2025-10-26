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
    uint32_t videoMemoryBaseAdr;            // 4 Byte
    int32_t videoMemoryOffset;              // 4 Byte
    uint32_t videoMemoryAdr;                // 4 Byte

    uint8_t cursorCol;                      // 1 Byte
    uint8_t cursorRow;                      // 1 Byte
    uint8_t colorForeground;                // 1 Byte
    uint8_t colorBackground;                // 1 Byte
} VIDEO_TEXTMODE_DRIVER;

#pragma pack(pop)

#endif
