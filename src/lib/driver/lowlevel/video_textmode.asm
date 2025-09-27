/*
 * Implementation of low-level VGA Textmode Video Driver
 *
 */

.intel_syntax noprefix

#include "video_defines.asm"

/*
 * Initializes the VGA Textmode 80x25
 *
 * void vidInitializeTextMode(VIDEO_TEXTMODE_DRIVER* pDriver, uint32_t videoMemoryAdr, uint32_t videoMemoryOffset);
 *
 *    Parameters:
 *      EBP + 8:  pDriver
 *      EBP + 12: videoMemoryAdr
 *      EBP + 16: videoMemoryOffset
 *
 *    Returns:
 *      -
 *
 */
.code32
.section .text.vidInitializeTextMode,"ax",@progbits
.global vidInitializeTextMode
vidInitializeTextMode:
    push ebp
    mov ebp, esp

    push edi
    push ecx
    push edx

    mov edi, [ebp + 8]                      /* Get the pDriver pointer from paranmeter stack into EDI */
    mov ecx, [ebp + 12]                     /* Get the videoMemoryAdr from parameter stack into ECX */
    mov edx, [ebp + 16]                     /* Get the videoMemoryOffset from parameter stack into EDX */

    /* Prepare the pDriver struct */
    mov [edi + VIDEO_TEXTMODE_DRV_VIDMEM_BASEADR_OFFSET], ecx       /* VIDEO_TEXTMODE_DRV_VIDMEM_BASEADR_OFFSET */
    mov [edi + VIDEO_TEXTMODE_DRV_VIDMEM_OFF_OFFSET], edx           /* VIDEO_TEXTMODE_DRV_VIDMEM_OFF_OFFSET */

    /* Calculate the final Video Memory Address and store it in the struct */
    add ecx, edx
    mov [edi + VIDEO_TEXTMODE_DRV_VIDMEM_ADR_OFFSET], ecx           /* VIDEO_TEXTMODE_DRV_VIDMEM_ADR_OFFSET */


    pop edx
    pop ecx
    pop edi

    leave
    ret


