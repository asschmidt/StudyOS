/*
 * Memory Module
 *
 * This module provides functions to manupuilate  memory areas including copy,
 * move, set etc.
 *
 */

.intel_syntax noprefix

/*
 * Byte-wise copy of a memory area
 *
 * void* envMemCopy(uint8_t* pDst, uint8_t* pSrc, uint32_t n);
 *
 * Parameters:
 *    BP + 8:  pDst
 *    BP + 12: pSrc
 *    BP + 16: n
 *
 * Returns:
 *    EAX: Pointer to destination memory
 *
 */
.code32
.section .text.envMemCopy,"ax",@progbits
.global envMemCopy
envMemCopy:
    push ebp
    mov ebp, esp

    pushf
    push edi
    push esi
    push ecx

    /* Get Destination pointer from parameter stack */
    mov edi, [ebp + 8]
    /* Get Source pointer from parameter stack */
    mov esi, [ebp + 12]
    /* Get number of bytes to copy from paramter stack */
    mov ecx, [ebp + 16]
    /* Clear direction flag to automatically increment ESI and EDI */
    cld
    rep movsb

    /* Set the return value to destination pointer */
    mov eax, [ebp + 8]

    pop ecx
    pop esi
    pop edi
    popf

    leave
    ret

/*
 * Byte-wise setting a memory area to a specific value
 *
 * void* envMemSet(uint8_t* pDst, uint8_t value, uint32_t size);
 *
 * Parameters:
 *    BP + 8:  pDst
 *    BP + 12: value
 *    BP + 16: size
 *
 * Returns:
 *    EAX: Pointer to destination memory
 *
 */
.code32
.section .text.envMemSet,"ax",@progbits
.global envMemSet
envMemSet:
    push ebp
    mov ebp, esp

    pushf
    push edi
    push ecx

    /* Get destination pointer from parameter stack */
    mov edi, [ebp + 8]
    /* Get byte value from parameter stack */
    mov al, [ebp + 12]
    /* Get the size of memory area from stack */
    mov ecx, [ebp + 16]
    /* Set direction flag to 'increment' */
    cld
    rep stosb

    /* Set the return value to destination pointer */
    mov eax, [ebp + 8]

    pop ecx
    pop edi
    popf

    leave
    ret

