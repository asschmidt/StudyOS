/*
 * Standard IO Functions for Protected Mode
 *
 * This Module provides functions for standard IO like print strings etc. which can be used
 * in Protected Mode
 *
 *
 */
.intel_syntax noprefix

/* Include Common and BIOS defines */
#include "common_defines.asm"
#include "bios_defines.asm"

/*
 * Prints a string by directly writing to Video Memory
 *
 * void pmPutString(char* pString, int videoMemoryOffset);
 *
 * Parameters:
 *    EBP + 8:  pString
 *    EBP + 12: Offset address for Video Memory (due to GDT offset)
 *
 * Returns:
 *    -
 *
 */
 .code32
.section .text.pmPutString,"ax",@progbits
.global pmPutString
pmPutString:
    push ebp                                    /* Prepare Stack Frame */
    mov ebp, esp

    push eax
    push ebx
    push ecx

    mov eax, [ebp + 8]                          /* Get the string pointer */
    mov ecx, [ebp + 12]							/* Get the offset */

    mov ebx, VIDEO_MEMORY                       /* Address of Video Memory we will write to (VIDEO_MEMORY) */
    sub ebx, ecx								/* Substract the offset from video memory */

    mov ch, COLOR_BLACK | COLOR_LIGHTGRAY       /* Set the color (background=BLACK, foreground=LIGHT_GRAY) */
    mov cl, [eax]                               /* Get a character from the string */

.printLoop_pmPutString:
    mov [ebx], cx                               /* Move character and color info as word into video memory */
    add ebx, 2                                  /* Increment the pointer to video memory to the next word */
    inc eax                                     /* Increment the pointer to the string to get next character */
    mov cl, [eax]                               /* Get character from string */
    cmp cl, 0                                   /* Check for NULL string termination */
    jnz .printLoop_pmPutString

    pop ecx
    pop ebx
    pop eax

    leave
    ret

