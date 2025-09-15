/*
 * System Timer with fixed intervall and global counter
 *
 */

.intel_syntax noprefix

#include "pm_idt_defines.asm"
#include "pm_pit_defines.asm"
#include "pm_timer_defines.asm"


.section .bss
/* struct PIT_DATA SYS_TIMER_PIT_DATA; */
SYS_TIMER_PIT_DATA:     .space PIT_DATA_SIZE
/* uint32_t GLOBAL_TICK; */
GLOBAL_TICK:            .space 4

/*
 * Initializes the System Timer
 *
 * void pmTimerInitialize();
 *
 * Parameters:
 *    -
 *
 * Returns:
 *    -
 *
 */
.code32
.section .text.pmTimerInitialize,"ax",@progbits
.global pmTimerInitialize
pmTimerInitialize:
    push ebp
    mov ebp, esp

    /* Disable the PIT interrupt */
    call pmTimerDisable

    /* Initialize the PIT with the default system frequency */
    /* pmPITInitialize(&SYS_TIMER_PIT_DATA, SYSTEM_TIMER_FREQUENCY); */
    push SYSTEM_TIMER_FREQUENCY
    push OFFSET SYS_TIMER_PIT_DATA
    call pmPITInitialize
    add esp, 8

    /* Init the global tick counter */
    push eax
    lea eax, GLOBAL_TICK
    mov DWORD PTR [eax], 0
    pop eax

    leave
    ret


/*
 * Enables the System Timer
 *
 * void pmTimerEnable();
 *
 * Parameters:
 *    -
 *
 * Returns:
 *    -
 *
 */
.code32
.section .text.pmTimerEnable,"ax",@progbits
.global pmTimerEnable
pmTimerEnable:
    push ebp
    mov ebp, esp

    /* Un-Mask Timer Interrupt */
    /* pmPICUnmaskIRQ(0x00); */
    push 0x00
    call pmPICUnmaskIRQ
    add esp, 4

    leave
    ret

/*
 * Disables the System Timer
 *
 * void pmTimerDisable();
 *
 * Parameters:
 *    -
 *
 * Returns:
 *    -
 *
 */
.code32
.section .text.pmTimerDisable,"ax",@progbits
.global pmTimerDisable
pmTimerDisable:
    push ebp
    mov ebp, esp

    /* Mask out Timer Interrupt */
    /* pmPICMaskIRQ(0x00); */
    push 0x00
    call pmPICMaskIRQ
    add esp, 4

    leave
    ret

/*
 * Returns the current global tick count of the System Timer
 *
 * uint32_t pmTimerGetTick();
 *
 * Parameters:
 *    -
 *
 * Returns:
 *    EAX: Global Tick-Count
 *
 */
.code32
.section .text.pmTimerGetTick,"ax",@progbits
.global pmTimerGetTick
pmTimerGetTick:
    push ebp
    mov ebp, esp

    push esi

    lea esi, GLOBAL_TICK
    mov eax, DWORD PTR [esi]

    pop esi

    leave
    ret


/*
 * Performs a busy-wait with the System-Timer
 *
 * void pmTimerBusyWait(uint32_t milli);
 *
 * Parameters:
 *    EBP + 8: milliseconds to wait
 *
 * Returns:
 *    -
 *
 */
.code32
.section .text.pmTimerBusyWait,"ax",@progbits
.global pmTimerBusyWait
pmTimerBusyWait:
    push ebp
    mov ebp, esp

    push esi

    /* Get milliseconds from parameter stack */
    mov esi, DWORD PTR [ebp + 8]
    /* Get current tick count */
    /* eax = pmTimerGetTick(); */
    call pmTimerGetTick
    /* Tick count till wait over = currentTick + milli */
    add esi, eax

.waitLoop_pmTimerBusyWait:
    /* Get current tick count */
    /* eax = pmTimerGetTick(); */
    call pmTimerGetTick
    cmp eax, esi
    jl .waitLoop_pmTimerBusyWait

    xor eax, eax

    pop esi

    leave
    ret

/*
 * ISR for System Timer
 *
 * The ISR increments a global tick-counter which represents the number of
 * milliseconds since the start of the timer
 *
 * Parameters:
 *    -
 *
 * Returns:
 *    -
 *
 */
.code32
.section .text.pmTimerISR,"ax",@progbits
.global pmTimerISR
pmTimerISR:
    pushad
    cld

    call pmPICReadISR
    cmp eax, 0x00
    jz .noPICInterrupt

    push eax
    call pmPICSendEOI
    add esp, 4

    /* Increment global counter */
    lea eax, GLOBAL_TICK
    mov ecx, DWORD PTR [eax]
    add ecx, 1
    mov DWORD PTR [eax], ecx

.noPICInterrupt:
    /* Here we could call a C-Interrupt Handler */
    /*call interrupt_handler */
    popad
    iret