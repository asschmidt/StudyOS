/*
 * Protected-Mode Handling for Stage 2 Bootloader
 * This module provides the functionality to setup a temporary GDT and
 * switches to Protected Mode
 *
 * The temporary GDT is used to get into Protected Mode while considering the
 * segement:offset address from Stage 1 and Stage 2 Bootloader
 */

.intel_syntax noprefix

/* Include Commond and BIOS defines */
#include "common_defines.asm"
#include "bios_defines.asm"
/* Include PIC defines */
#include "pm_pic_defines.asm"
/* Include IDT Defines */
#include "pm_idt_defines.asm"

/*
 * External Symbols
 */
.extern gdtCodeTemp                         /* Symbol for the Code-Segement Entry in temporary GDT */
.extern gdtDataTemp                         /* Symbol for the Data-Segement Entry in temporary GDT */
.extern gdtStartTemp                        /* Symbol for Start of the temporary GDT */
.extern gdtDescriptorTemp                   /* Symbol for the descriptor of the temporary GDT */

/* Constants */
/* Code Segment Selector */
#define CODE_SEG    0x08
/* Data Segment Selector */
#define DATA_SEG    0x10

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

    /* pmPrepareGDT(&gdtStartTemp, &gdtEndTemp, &_boot_stage2_segment, &gdtDescriptorTemp); */
    push OFFSET gdtDescriptorTemp
    push OFFSET _boot_stage2_segment
    push OFFSET gdtEndTemp
    push OFFSET gdtStartTemp
    call pmPrepareGDT
    add sp, 8

    /* The GDT must be loaded with the ES segment due to the fact that CS and DS are
     * having different segement addresse (because of .data and .rodata section placement)
     * gdtDescriptorTemp is located in .bss segement which has a different segment address
     */
    lgdt [es:gdtDescriptorTemp]				/* Load the GDT */

    mov eax, cr0                            /* Get the current CR0 value */
    or eax, 0x01                            /* Set Bit 0 to switch to PM */
    mov cr0, eax                            /* Set new CR0 value */

    jmp CODE_SEG:pmInit                     /* Call into PM function (32 Bit) (CODE_SEG) */


.code32
.section .text
.align 8
.global pmInit
pmInit:
	/* Initialize all segment selectors with the data segement from temporary GDT */
    mov ax, DATA_SEG                        /* DATA_SEG */
    mov ds, ax
    mov ss, ax
    mov es, ax
    mov fs, ax
    mov gs, ax

    /* Initialize the stack pointer to the original stack memory but using the GDT segments */
    /* In Real-Mode, the stack segment is located at 0x7800:0000. To use the same physical memory
     * in Protected-Mode, we need to consider the Data-Segement Offset in GDT (which is 0x7E00)
     * To calculate the stack pointer for the use with the GDT data segment, but using same memory
     * as we had in Real-Mode, we must peform the following calculation
     * StackPointer = ((_boot_stack_segment * 16) + _boot_stack_start_offset) - _boot_stage2_segment
     */
    xor eax, eax
    mov eax, OFFSET _boot_stack_segment
    /* (_boot_stack_segment * 16) */
    shl eax, 4

    mov ebx, OFFSET _boot_stack_start_offset
    /* Add _boot_stack_start_offset to prepared segment address */
    add eax, ebx

    mov ebx, OFFSET _boot_stage2_segment
    /* _boot_stage2_segment * 16 */
    shl ebx, 4
    /* Substract _boot_stage2_segment from linear address of boot stack */
    sub eax, ebx

    /* Set the Base-Pointer and Stack-Pointer to calculated address */
    mov ebp, eax
    mov esp, ebp

    /* pmPutString(&PM_MESSAGE, videoMemoryOffset); */
    /* EBX still holds the calculated segment address */
    push ebx                                /* Offset parameter for Video Memory based on temp. GDT. */
    push OFFSET PM_MESSAGE                  /* Pointer to string */
    call pmPutString
    add esp, 8

    /* pmPrepareIDT(&idtDescriptorTemp, &idtTemp, IDT_ENTRY_COUNT, &_boot_stage2_segment); */
    push OFFSET _boot_stage2_segment
    push IDT_ENTRY_COUNT                    /* IDT_ENTRY_COUNT */
    push OFFSET idtTemp
    push OFFSET idtDescriptorTemp
    call pmPrepareIDT
    add esp, 16

    /* Load the IDTR with the prepared descriptor */
    xor eax, eax
    lea eax, idtDescriptorTemp
    lidt [eax]

	/* Enable all interrupts */
    sti

    /* Initialize the IDT Entries for 0x32...0xFF */
    /* for (i=0xFF; i>0x31; i--) */
    mov ecx, 0xFF
.initIDTLoop_pmInit:

    /* pmSetupIDTEntry(&idtTemp, i, &pmDefaultISR, 0x8F, CODE_SEG); */
    push CODE_SEG                           /* CODE_SEG */
    push IDT_TYPE_ATTRIB_INT32              /* IDT_TYPE_ATTRIB_INT32 */
    push OFFSET pmDefaultISR
    push ecx
    push OFFSET idtTemp
    call pmSetupIDTEntry
    add esp, 20

    dec ecx
    cmp ecx, 0x31
    jne .initIDTLoop_pmInit

    /* Remap the PIC with the correct offset */
    /* pmPICRemap(PIC1_OFFSET, PIC2_OFFSET); */
    push PIC2_OFFSET                        /* Offset for PIC2 --> IRQ 8..15 -> IDT: 0x28...0x2F (PIC2_OFFSET) */
    push PIC1_OFFSET                        /* Offset for PIC1 --> IRQ 0..7  -> IDT: 0x20...0x27 (PIC1_OFFSET) */
    call pmPICRemap
    add esp, 8

    /* Mask out Timer Interrupt */
    /* pmPICSetMask(0x00); */
    push 0x00
    call pmPICSetMask
    add esp, 4

.nopLoop_pmInit:
    nop
    jmp .nopLoop_pmInit

.section .rodata
PM_MESSAGE: .asciz "Switched to Protected Mode"
