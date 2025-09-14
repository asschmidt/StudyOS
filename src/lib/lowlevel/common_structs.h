/*
 * Common Structs Module
 *
 * This module only provides structure definitions for lib lowlevel to help debugging
 *
 */

#ifndef _COMMON_STRUCTS_H_
#define _COMMON_STRUCTS_H_

#include <stddef.h>
#include <stdint.h>

#pragma pack(push, 1)

typedef struct _PART_TABLE_ENTRY {
    uint8_t driveAttributes;            // 1 Byte
    uint8_t chsPartitionStart[3];       // 3 Byte
    uint8_t partType;                   // 1 Byte
    uint8_t chsPartitionEnd[3];         // 3 Byte
    uint32_t lbaStart;                  // 4 Byte
    uint32_t numOfSectors;              // 4 Byte
} PART_TABLE_ENTRY;

typedef struct _GDT_DESC {
    uint16_t limit;                     // 2 Byte - Size of the Table
    uint32_t startAddress;              // 4 Byte - Start address of the table
} GDT_DESC;

typedef struct _GDT_ENTRY {
    uint16_t limit_low;
    uint16_t base_low;
    uint8_t access;
    uint8_t flags;
    uint8_t byte1;
    uint8_t byte2;

} GDT_ENTRY;

typedef struct _IDT_DESC {
    uint16_t size;
    uint32_t startAddress;
} IDT_DESC;

typedef struct _IDT_ENTRY {
   uint16_t offset_1;                   // 2 Byte - offset bits 0..15
   uint16_t selector;                   // 2 Byte - a code segment selector in GDT or LDT
   uint8_t  zero;                       // 1 Byte - unused, set to 0
   uint8_t  type_attributes;            // 1 Byte - Gate type, dpl, and p fields
   uint16_t offset_2;                   // 2 Byte - offset bits 16..31
} IDT_ENTRY;                            // 8 Byte

typedef struct _PIT_DATA {
    uint16_t PIT_reloadValue;           // 2 Byte
    uint32_t irq0Frequency;             // 4 Byte
    uint32_t irq0Milliseconds;          // 4 Byte
} PIT_DATA;

#pragma pack(pop)

#endif