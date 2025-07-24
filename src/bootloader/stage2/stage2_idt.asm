/*
 * Temporary Interrupt Descriptor Table
 * Temporary IDT for Stage 2 Bootloader. This IDT is used during Stage 2
 * execution to provide basic interrupt handling for drivers like Floppy
 * Disk and basic error handling
 *
 */


.intel_syntax noprefix

.code32
.section .text.pmDefaultISR,"ax",@progbits
.global pmDefaultISR
pmDefaultISR:
    pushad
    cld

    call pmPICReadISR
    cmp eax, 0x00
    jz .noPICInterrupt

    push eax
    call pmPICSendEOI
    add esp, 4

	/* Hack to test Keyboard Interrupt */
    /*in al, 0x60*/

.noPICInterrupt:
    /* Here we could call a C-Interrupt Handler */
    /*call interrupt_handler */
    popad
    iret

.section .bss

.global idtTemp
idtTemp:
    .space (8 * 256)

.global idtDescriptorTemp
idtDescriptorTemp:
    .word 0
    .long 0

