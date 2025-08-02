/*
 * Protected-Mode Handling for Stage 2 Bootloader
 * This module provides the functionality to setup a temporary GDT and
 * switches to Protected Mode
 *
 * The temporary GDT is used to get into Protected Mode while considering the
 * segement:offset address from Stage 1 and Stage 2 Bootloader
 */

.intel_syntax noprefix

#include "common_defines.asm"
/* Include BIOS defines */
#include "bios_defines.asm"

/*
 * External Symbols
 */
.extern gdtCodeTemp                         /* Symbol for the Code-Segement Entry in temporary GDT */
.extern gdtDataTemp                         /* Symbol for the Data-Segement Entry in temporary GDT */
.extern gdtStartTemp                        /* Symbol for Start of the temporary GDT */
.extern gdtDescriptorTemp                   /* Symbol for the descriptor of the temporary GDT */

/* Constants */
.set CODE_SEG, 0x08
.set DATA_SEG, 0x10

.code16
.section .text
.align 8
.global pmSwitch
pmSwitch:
    /* Hack to activate A20 address line */
    /* TODO: Need to provide a clean solution */
	mov ax, 0x2401
	int 0x15

    /* Disable all interrupts */
	cli

    /* Push parameter onto stack */
    push OFFSET gdtDescriptorTemp
    push OFFSET _boot_stage2_segment
    push OFFSET gdtEndTemp
    push OFFSET gdtStartTemp

    /* pmPrepareGDT(gdtStartTemp, gdtEndTemp, _boot_stage2_segment, &gdtDescriptorTemp); */
    call pmPrepareGDT

    /* Clean up the parameter stack */
    add sp, 8

    /* The GDT must be loaded with the ES segment due to the fact that CS and DS are
     * having different segement addresse (because of .data and .rodata section placement)
     * gdtDescriptorTemp is located in .bss segement which has a different segment address
     */
    lgdt [es:gdtDescriptorTemp]				/* Load the GDT */

    mov eax, cr0                            /* Get the current CR0 value */
    or eax, 0x01                            /* Set Bit 0 to switch to PM */
    mov cr0, eax                            /* Set new CR0 value */

    jmp CODE_SEG:pmInit                     /* Call into PM function (32 Bit) */


.code32
.section .text
.align 8
.global pmInit
pmInit:
	/* Initialize all segment selectors with the data segement from temporary GDT */
    mov ax, DATA_SEG
    mov ds, ax
    mov ss, ax
    mov es, ax
    mov fs, ax
    mov gs, ax

    /* Initialize the stack pointer to the original stack memory but using the GDT segments */
    /* In Real-Mode, the stack segment is located at 0x7800:0000. To use the same physical memory
     * in Protected-Mode, we need to consider the Data-Segement Offset in GDT (which is 0x7E00)
     * To calculate the stack pointer for the use with the GDT data segment but using same memory
     * as we had in Real-Mode, we must peform the following calculation
     * StackPointer = ((_boot_stack_segment * 16) + _boot_stack_start_offset) - _boot_stage2_segment
     */
    xor eax, eax
    mov eax, OFFSET _boot_stack_segment
    shl eax, 4

    mov ebx, OFFSET _boot_stack_start_offset
    add eax, ebx

    /* Subtract the Data Segment offset used in temporary GDT */
    mov ebx, OFFSET _boot_stage2_segment
    shl ebx, 4
    sub eax, ebx

    mov ebp, eax
    mov esp, ebp

    /* Offset parameter for Video Memory based on temp. GDT */
    /* EBX still holds the calculated segment address */
    push ebx
    push OFFSET PM_MESSAGE                  /* Pointer to string */

    call pmPutString
    add esp, 8

    push OFFSET _boot_stage2_segment
    push IDT_ENTRY_COUNT
    push OFFSET idtTemp
    push OFFSET idtDescriptorTemp

    /* pmPrepareIDT(&idtDescriptorTemp, &idtTemp, IDT_ENTRY_COUNT, _boot_stage2_segment); */
    call pmPrepareIDT
    /* Clean-up stack */
    add esp, 16

    /* Load the IDTR with the prepared descriptor */
    xor eax, eax
    lea eax, idtDescriptorTemp
    lidt [eax]

	/* Enable all interrupts */
    sti

    mov ecx, 255
.initIDTLoop:
    push CODE_SEG
    push 0x8E
    push OFFSET pmDefaultISR
    push ecx
    push OFFSET idtTemp

    /* pmSetupIDTEntry(&idtTemp, 0x21, &pmDefaultISR, 0x8F, CODE_SEG); */
    call pmSetupIDTEntry
    /* Clean-up stack */
    add esp, 20

    dec ecx
    cmp ecx, 0x19
    jne .initIDTLoop

    /* Remap the PIC with the correct offset */
    push 0x28
    push 0x20
    /* pmPICRemap(0x20, 0x28); */
    call pmPICRemap
    add esp, 8

    /* Mask out Timer Interrupt */
    push 0x00
    call pmPICSetMask
    add esp, 4

.nopLoop:
    nop
    jmp .nopLoop

.section .rodata
PM_MESSAGE: .asciz "Switched to Protected Mode"
