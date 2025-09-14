/*
 * Stage 2 Bootloader
 * This Stage 2 Bootloader is loaded by the Stage 1 Bootloader from the bootloader
 * partition of the disk. This Stage 2 bootloader is responsible for loading the
 * setting up the GDT, switching to protected mode and loading the kerkel
 *
 */
.intel_syntax noprefix

/*
 * External Symbols from Linker File
 */
.extern _boot_stage2_offset             /* Offset Address of the Stage 2 Bootloader Code */
.extern _boot_stage2_segment            /* Segement Address of the Stage 2 Bootloader Code + Data */
.extern _boot_stage2_length             /* Length of the Stage 2 Bootloader Code Segment */

.extern _boot_stack_segment             /* Segment Address for the Bootloader Stage 2 Stack Memory */
.extern _boot_stack_start_offset        /* Offset Address for the Bootloader Stage 2 Stack Memory */
.extern _boot_stack_size                /* Size of the Stack Memory Segment for Stage 2 Bootloader */

.extern _boot_ram_segment               /* Segment Address for the Bootloader Stage 2 RAM */
.extern _boot_ram_offset                /* Offset Address for the Bootloader Stage 2 RAM */
.extern _boot_ram_size                  /* Size of the RAM Segment for Stage 2 Bootloader */

/*
 * Start of the Stage 2 execution
 * The following code is 16 Bit
*/
.code16
.section .text
.globl stage2Start
stage2Start:
	xor ax, ax	            		    /* Zero out AX register */

    mov ax, OFFSET _boot_ram_segment    /* Get the segment for the RAM of bootloader stage 2 */
    mov es, ax              		    /* Initialize the Extra Segement to _boot_ram_segment */

	mov ax, OFFSET _boot_stage2_segment /* Get the segment for the bootloader stage 2 */
	mov ds, ax              		    /* Initialize the DataSegement to _boot_stage2_segment */

    mov ax, OFFSET _boot_stack_segment  /* Initialize AX to the Stack Segment */
    mov ss, ax              		    /* Initialize the Stack Segement to _boot_stack_segment */

    /* At this point we have the following segment configuration
     *
     * CS: 0x07E0 (_boot_stage2_segment)
     * ES: 0x7D00 (_boot_ram_segment)
     * DS: 0x07E0 (_boot_stage2_segment)
     * SS: 0x7F00 (_boot_stack_segment)
     */

	/* Initialize the Stack Pointer */
    mov sp, OFFSET _boot_stack_start_offset
    mov bp, sp              		    /* Initialize the Base Pointer used in Stack Frames */
    push bp                 		    /* We save BP with the original SP value on stack */

    /* biosClearScreen(); */
    call biosClearScreen                /* Clear the screeen */

    /* biosSetCursor(0, 0); */
    push 0                              /* Column idx for biosSetCursor */
    push 0                              /* Row idx for biosSetCursor */
    call biosSetCursor
    add sp, 4

    /* biosPutString(&MSG_LOADINGG); */
    push OFFSET MSG_LOADING
    call biosPutString
    add sp, 2

    call pmSwitch

stage2Done:
    jmp $

.halt:
    cli
    hlt


.section .rodata
MSG_LOADING: .asciz  "Starting Stage 2...\r\n"
