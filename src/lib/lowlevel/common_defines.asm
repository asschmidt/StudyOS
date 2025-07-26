/*
 * Common defines for data structures and addresses not related to any mode
 * e.g. Real Mode or Protected Mode
 *
 */

.intel_syntax noprefix

/* Sector size in Bytes */
.set DEFAULT_SECTOR_SIZE,                           512

.set IDT_ENTRY_SIZE,                                8
.set IDT_ENTRY_COUNT,                               256

/* Offset of the Partition Table in the MBR */
.set MBR_PART_TABLE_OFFSET,                         0x1BE

/* Address of the Video Memory for Text-Display */
.set VIDEO_MEMORY,                                  0xB8000

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
.set PART_TABLE_ENTRY_SIZE,                         16
.set PART_TABLE_ENTRY_DRIVE_ATTRIBUTES_OFFSET,      0
.set PART_TABLE_ENTRY_CHS_PART_START_OFFSET,        1
.set PART_TABLE_ENTRY_PART_TYPE_OFFSET,             4
.set PART_TABLE_ENTRY_CHS_PART_END_OFFSET,          5
.set PART_TABLE_ENTRY_LBA_START_OFFSET,             8
.set PART_TABLE_ENTRY_NUM_SECTORS_OFFSET,           12



