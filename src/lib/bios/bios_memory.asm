/*
 * BIOS Memory Module
 * This module provides functions to handle and initialize memory areas
 *
 * Only usable in Real-Mode
 *
 */
.intel_syntax noprefix

/*
 * Initialize the stack memory with a pattern
 *
 * Parameter:
 *   AX: Pattern to fill memory with
 *	 BX: Stack segment to use
 *   CX: Size of stack area in bytes
 *
 * Returns:
 *   -
 */
.code16
.section .text.memInitStack,"ax",@progbits
.global memInitStack
memInitStack:
    push di
    push es

    /* Set the extra segment register to use with the specified stack segment */
    mov bx, OFFSET _boot_stack_segment
    mov es, bx

    /* Get the current stack pointer. This is where the stack init starts to avoid overwriting
     * already stored values on the stack
     * We need to subtract 2 byte, because the x86 uses full-decending stack and therefore the
     * SP still points to the last written memory address
     */
    mov di, sp
    sub di, 2

.stackInitLoop_memInitStack:
    mov es:[di], ax					    /* Store data in Stack (0xCDCD) */
    sub di, 2						    /* Decrement the write pointer */
    sub cx, 2						    /* Decrement the write counter */
    jnz .stackInitLoop_memInitStack     /* If still bytes to write, go back to loop */

    pop es
    pop di

    ret

