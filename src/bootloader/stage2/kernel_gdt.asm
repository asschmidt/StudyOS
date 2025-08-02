/*
 * Kernel Global Descriptor Table
 * GDT for Kernel.
 *
 */


.intel_syntax noprefix

/* Include BIOS Defines */
#include "bios_defines.asm"

/* The GDT uses an own section in ELF binary */
.section .gdt,"a",@progbits

/* Start Symbol of the GDT */
.global gdtStartKernel
gdtStartKernel:

/* Mandatory Null Descriptor for the first GDT Entry */
.global gdtNullKernel
gdtNullKernel:
    .word 0x0000
    .word 0x0000
    .word 0x0000
    .word 0x0000

/*
 * Code Segment Descriptor
 *
 * Base = 0x00000000
 * Limit = 0xFFFFF
 * Access Byte: Present = 1, Privilege = 00, Descriptor Type = 1,
 *              Code = 1, Conforming = 0, Readable = 1, Accessed = 0
 *
 * Flags: Granularity = 1, 32-Bit Default = 1, Long Mode = 0, AVL = 0
 *
 */
.global gdtCodeKernel
gdtCodeKernel:
    .word 0xffff
    .word 0x0000
    .word 0x9a00
    .word 0x00cf

/*
 * Data Segment Descriptor
 *
 * Base = 0x00000000
 * Limit = 0xFFFFF
 * Access Byte: Present = 1, Privilege = 00, Descriptor Type = 1,
 *              Code = 0, Expand Down = 0, Writeable = 1, Accessed = 0
 *
 * Flags: Granularity = 1, 32-Bit Default = 1, Long Mode = 0, AVL = 0
 *
 */
.global gdtDataKernel
gdtDataKernel:
    .word 0xffff
    .word 0x0000
    .word 0x9200
    .word 0x00cf

.global gdtEndKernel
gdtEndKernel:


.section .bss

/*
 * GDT Descriptor as global variable in BSS segement.
 * The size and the linear address of the GDT are calculated at runtime during
 * initialization of Protected Mode
 */
.global gdtDescriptorKernel
gdtDescriptorKernel:
    /* Size of the GDT, must be always less one */
    .word 0
    /* Start address of the GDT */
    .long 0


