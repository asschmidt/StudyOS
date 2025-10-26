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
#define pDriver             8
#define videoMemoryAdr      12
#define videoMemoryOffset   16

.code32
.section .text.vidInitializeTextMode,"ax",@progbits
.global vidInitializeTextMode
vidInitializeTextMode:
    push ebp
    mov ebp, esp

    push edi
    push ecx
    push edx

    mov edi, [ebp + pDriver]                                        /* Get the pDriver pointer from parameter stack into EDI */
    mov ecx, [ebp + videoMemoryAdr]                                 /* Get the videoMemoryAdr from parameter stack into ECX */
    mov edx, [ebp + videoMemoryOffset]                              /* Get the videoMemoryOffset from parameter stack into EDX */

    /* Prepare the pDriver struct */
    mov [edi + VIDEO_TEXTMODE_DRV_VIDMEM_BASEADR_OFFSET], ecx       /* VIDEO_TEXTMODE_DRV_VIDMEM_BASEADR_OFFSET */
    mov [edi + VIDEO_TEXTMODE_DRV_VIDMEM_OFF_OFFSET], edx           /* VIDEO_TEXTMODE_DRV_VIDMEM_OFF_OFFSET */

    /* Calculate the final Video Memory Address and store it in the struct */
    add ecx, edx
    mov [edi + VIDEO_TEXTMODE_DRV_VIDMEM_ADR_OFFSET], ecx           /* VIDEO_TEXTMODE_DRV_VIDMEM_ADR_OFFSET */

    /* Initialize cursor position to (0,0) by writing 0x00 as 16 Bit value */
    xor eax, eax
    mov [edi + VIDEO_TEXTMODE_DRV_CURSOR_COL_OFFSET], ax

    /* Initialize the defult colors */
    mov ah, COLOR_BLACK                                             /* COLOR_BLACK */
    mov al, COLOR_LIGHTGRAY                                         /* COLOR_LIGHTGRAY */
    mov [edi + VIDEO_TEXTMODE_DRV_COLOR_FORGROUND_OFFSET], al       /* VIDEO_TEXTMODE_DRV_COLOR_FORGROUND_OFFSET */
    mov [edi + VIDEO_TEXTMODE_DRV_COLOR_BACKGROUND_OFFSET], ah      /* VIDEO_TEXTMODE_DRV_COLOR_BACKGROUND_OFFSET */

    pop edx
    pop ecx
    pop edi

    leave
    ret


/*
 * Clears the screen
 *
 * void vidClearScreen(VIDEO_TEXTMODE_DRIVER* pDriver);
 *
 *    Parameters:
 *      EBP + 8:  pDriver
 *
 *    Returns:
 *      -
 *
 */
#define pDriver             8

.code32
.section .text.vidClearScreen,"ax",@progbits
.global vidClearScreen
vidClearScreen:
    push ebp
    mov ebp, esp

    push ecx
    push edi
    push esi

    /* Get the video memory address from driver struct */
    mov esi, [ebp + pDriver]
    mov edi, [esi + VIDEO_TEXTMODE_DRV_VIDMEM_ADR_OFFSET]

    /* Get Color info */
    mov ch, [esi + VIDEO_TEXTMODE_DRV_COLOR_BACKGROUND_OFFSET]
    or ch, [esi + VIDEO_TEXTMODE_DRV_COLOR_FORGROUND_OFFSET]

    /* Set space as char */
    mov cl, 0x20
    xor eax, eax

.clearLoop_vidClearScreen:
    mov [edi], cx                                   /* Move character and color info as word into video memory */
    add edi, 2                                      /* Increment the pointer to video memory to the next word */
    inc eax
    cmp eax, SCREEN_COL_COUNT * SCREEN_ROW_COUNT    /* Check for NULL string termination */
    jl .clearLoop_vidClearScreen

    pop esi
    pop edi
    pop ecx

    leave
    ret


/*
 * Outputs a string at current cursor position
 *
 * void vidOutputString(VIDEO_TEXTMODE_DRIVER* pDriver, char* string);
 *
 *    Parameters:
 *      EBP + 8:  pDriver
 *      EBP + 12: string
 *
 *    Returns:
 *      -
 *
 */
#define pDriver             8
#define string              12

.code32
.section .text.vidOutputString,"ax",@progbits
.global vidOutputString
vidOutputString:
    push ebp
    mov ebp, esp

    push ebx
    push ecx
    push edi
    push esi

    /* Get the video memory address from driver struct */
    mov esi, [ebp + pDriver]
    mov edi, [esi + VIDEO_TEXTMODE_DRV_VIDMEM_ADR_OFFSET]

    /* Get the current cursor position to calculate correct memory offset in video memory */
    xor eax, eax
    xor ebx, ebx
    xor ecx, ecx
    /* BX now contains the column and row value of the cursor */
    mov ebx, [esi + VIDEO_TEXTMODE_DRV_CURSOR_COL_OFFSET]
    /* AL now contains the row position */
    mov al, bh
    /* AX = row position * col count */
    mov cl, SCREEN_COL_COUNT
    mul cl
    /* AX = AX + col position */
    xor ecx, ecx
    mov cl, bl
    add ax, cx
    /* Multiply the result by 2 because each char on screen has 2 byte (char & color) */
    shl ax, 1
    /* Add offset to video memory address */
    add edi, eax

    /* Get Color info */
    mov ch, [esi + VIDEO_TEXTMODE_DRV_COLOR_BACKGROUND_OFFSET]
    or ch, [esi + VIDEO_TEXTMODE_DRV_COLOR_FORGROUND_OFFSET]

    /* Get the pointer to the string */
    mov esi, [ebp + string]
    /* Get first char */
    mov cl, [esi]

.printLoop_vidOutputString:
    mov [edi], cx                               /* Move character and color info as word into video memory */
    add edi, 2                                  /* Increment the pointer to video memory to the next word */
    inc esi                                     /* Increment the pointer to the string to get next character */
    mov cl, [esi]                               /* Get character from string */
    cmp cl, 0                                   /* Check for NULL string termination */
    jnz .printLoop_vidOutputString

    pop esi
    pop edi
    pop ecx
    pop ebx

    leave
    ret
