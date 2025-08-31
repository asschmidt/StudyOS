/*
 * IDT Defines and definitions
 *
 *
 */
.intel_syntax noprefix


/* Gate Types for a IDT Entry */
/* Task Gate */
#define GT_TASK                 0x05
/* 16-Bit Interrupt Gate */
#define GT_INT16                0x06
/* 16-Bit Trap Gate */
#define GT_TRAP16               0x07
/* 32-Bit Interrupt Gate */
#define GT_INT32                0x0E
/* 32-Bit Trap Gate */
#define GT_TRAP32               0x0F


/* CPU Privilige Levels */
/* Ring 0 */
#define DPL_RING0               0x00
/* Ring 1 */
#define DPL_RING1               0x01
/* Ring 2 */
#define DPL_RING2               0x02
/* Ring 3 */
#define DPL_RING3               0x03

/* IDT Entry Present Flag */
#define IDT_ENTRY_PRESENT       0x01
#define IDT_ENTRY_NOT_PRESENT   0x00


/* Default Type Attributes for a IDT Entry */
#define IDT_TYPE_ATTRIB_INT32  (IDT_ENTRY_PRESENT << 7) | (DPL_RING0 << 6) | (GT_INT32)
#define IDT_TYPE_ATTRIB_TRAP32 (IDT_ENTRY_PRESENT << 7) | (DPL_RING0 << 6) | (GT_TRAP32)
#define IDT_TYPE_ATTRIB_TASK   (IDT_ENTRY_PRESENT << 7) | (DPL_RING0 << 6) | (GT_TASK)

