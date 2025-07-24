/*
 * Temporary Global Descriptor Table
 * Temporary GDT for Stage 2 Bootloader. This GDT uses the Stage 2
 * Code- and Data-Segements as Base-Address to allow a switch to PM
 * using the current code segement and offset
 *
 */


.intel_syntax noprefix

/* The GDT uses an own section in ELF binary */
.section .gdt,"a",@progbits

/* Start Symbol of the GDT */
.global gdtStartTemp
gdtStartTemp:

/* Mandatory Null Descriptor for the first GDT Entry */
.global gdtNullTemp
gdtNullTemp:
    .word 0x0000
    .word 0x0000
    .word 0x0000
    .word 0x0000

/*
 * Code Segment Descriptor
 *
 * Base = 0x00007E00
 * Limit = 0xFFFFF
 * Access Byte: Present = 1, Privilege = 00, Descriptor Type = 1,
 *              Code = 1, Conforming = 0, Readable = 1, Accessed = 0
 *
 * Flags: Granularity = 1, 32-Bit Default = 1, Long Mode = 0, AVL = 0
 *
 */
.global gdtCodeTemp
gdtCodeTemp:
    .word 0xffff
    .word 0x7e00
    .word 0x9a00
    .word 0x00cf

/*
 * Data Segment Descriptor
 *
 * Base = 0x00007E00
 * Limit = 0xFFFFF
 * Access Byte: Present = 1, Privilege = 00, Descriptor Type = 1,
 *              Code = 0, Expand Down = 0, Writeable = 1, Accessed = 0
 *
 * Flags: Granularity = 1, 32-Bit Default = 1, Long Mode = 0, AVL = 0
 *
 */
.global gdtDataTemp
gdtDataTemp:
    .word 0xffff
    .word 0x7e00
    .word 0x9200
    .word 0x00cf

.global gdtEndTemp
gdtEndTemp:


/*
 * GDT Descriptor as global variable in BSS segement.
 * The size and the linear address of the GDT are calculated at runtime during
 * initialization of Protected Mode
 */
.section .bss
.global gdtDescriptorTemp
gdtDescriptorTemp:
    /* Size of the GDT, must be always less one */
    .word 0
    /* Start address of the GDT */
    .long 0


