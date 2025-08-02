/*
 * Common defines for data structures and addresses not related to any mode
 * e.g. Real Mode or Protected Mode
 *
 */
#ifndef _COMMON_DEFINES_ASM_
#define _COMMON_DEFINES_ASM_

.intel_syntax noprefix

/* Sector size in Bytes */
#define DEFAULT_SECTOR_SIZE             512

#define STACK_PATTERN                   0xCDCD
#define STACK_END_PATTERN               0xABAB

/* Interrupt Descriptor Table Data */
#define IDT_ENTRY_SIZE                  8
#define IDT_ENTRY_COUNT                 256

/* Offset of the Partition Table in the MBR */
#define MBR_PART_TABLE_OFFSET           0x1BE

/* Address of the Video Memory for Text-Display */
#define VIDEO_MEMORY                    0xB8000

/*
 * Partition Table Entry Structure
 * Stored in the boot sector of a disc to specify the disk/partition layout
 *
 * struct {
 *   uint8_t driveAttributes;           // 1 Byte
 *   uint8_t chsPartitionStart[3];      // 3 Byte
 *   uint8_t partType;                  // 1 Byte
 *   uint8_t chsPartitionEnd[3];        // 3 Byte
 *   uint32_t lbaStart;                 // 4 Byte
 *   uint32_t numOfSectors;             // 4 Byte
 * };                                   // 16 Byte
 *
 */
#define PART_TABLE_ENTRY_SIZE                         16
#define PART_TABLE_ENTRY_DRIVE_ATTRIBUTES_OFFSET      0
#define PART_TABLE_ENTRY_CHS_PART_START_OFFSET        1
#define PART_TABLE_ENTRY_PART_TYPE_OFFSET             4
#define PART_TABLE_ENTRY_CHS_PART_END_OFFSET          5
#define PART_TABLE_ENTRY_LBA_START_OFFSET             8
#define PART_TABLE_ENTRY_NUM_SECTORS_OFFSET           12


#endif
