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

    mov edi, [ebp + 8]                                              /* Get the pDriver pointer from parameter stack into EDI */
    mov ecx, [ebp + 12]                                             /* Get the videoMemoryAdr from parameter stack into ECX */
    mov edx, [ebp + 16]                                             /* Get the videoMemoryOffset from parameter stack into EDX */

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
    mov esi, [ebp + 8]
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
 * Sets the cursor position to provided column and row
 *
 * void vidSetCursor(VIDEO_TEXTMODE_DRIVER* pDriver, uint8_t row, uint8_t col);
 *
 *    Parameters:
 *      EBP + 8:  pDriver
 *      EBP + 12: row
 *      EBP + 16: col
 *
 *    Returns:
 *      -
 *
 */
.code32
.section .text.vidSetCursor,"ax",@progbits
.global vidSetCursor
vidSetCursor:
    push ebp
    mov ebp, esp

    push ecx
    push esi

    /* Get pointer to VIDEO_DRIVER struct into ESI */
    mov esi, [ebp + 8]

    /* Get the row parameter and set it as new row value in driver struct */
    mov ecx, [ebp + 12]
    mov BYTE PTR [esi + VIDEO_TEXTMODE_DRV_CURSOR_ROW_OFFSET], cl

    /* Get the col parameter and set it as new col value in driver struct */
    mov ecx, [ebp + 16]
    mov BYTE PTR [esi + VIDEO_TEXTMODE_DRV_CURSOR_COL_OFFSET], cl

    pop esi
    pop ecx

    leave
    ret


/*
 * Scrolls the screen by the number of rows provided as parameter
 *
 * void vidScrollDown(VIDEO_TEXTMODE_DRIVER* pDriver, uint8_t rowCount);
 *
 *    Parameters:
 *      EBP + 8:  pDriver
 *      EBP + 12: rowCount
 *
 *    Returns:
 *      -
 *
 */
.code32
.section .text.vidScrollDown,"ax",@progbits
.global vidScrollDown
vidScrollDown:
    push ebp
    mov ebp, esp

    push ebx
    push ecx
    push edx
    push edi
    push esi

    /* Get the video memory address from driver struct */
    mov ebx, [ebp + 8]
    mov edi, [ebx + VIDEO_TEXTMODE_DRV_VIDMEM_ADR_OFFSET]
    /* Set ESI and EDI to video memory address */
    mov esi, edi

    /* Get rowCount parameter into EAX */
    xor eax, eax
    mov eax, [ebp + 12]
    /* Calculate the offset in the source buffer by the number of
     * lines we will scroll */
    xor edx, edx
    mov edx, SCREEN_COL_COUNT
    /* EAX = rowCount * SCREEN_COL_COUNT */
    mul edx
    /* Save eax for late reuse */
    push eax
    /* Multiply EAX by 2 because of two bytes per char on screen */
    shl eax, 1
    /* Adjust pointer to source buffer area */
    add esi, eax
    /* Restore EAX in ECX ==> ECX = rowCount * SCREEN_COL_COUNT */
    pop ecx

    /* Calculate scroll loop count */
    xor eax, eax
    mov eax, SCREEN_ROW_COUNT * SCREEN_COL_COUNT
    /* loopCount = (SCREEN_COL_COUNT * SCREEN_ROW_COUNT) - (SCREEN_COL_COUNT * rowCount) */
    sub eax, ecx


scrollLoop_vidScrollDown:
    /* Could be optimized by 4-Byte read/writes */
    mov dx, WORD PTR [esi]
    mov [edi], dx
    add esi, 2
    add edi, 2
    dec eax
    jnz scrollLoop_vidScrollDown

    /* Clear last line on screen with space char */
clearLoop_vidScrollDown:

    pop esi
    pop edi
    pop edx
    pop ecx
    pop ebx

    leave
    ret


/*
 * Updates the cursor position based on the character
 *
 * Hereby, usual escape characters like \r \n etc. will modify the cusor position
 *
 * void vidUpdateCursor(VIDEO_TEXTMODE_DRIVER* pDriver, char c);
 *
 *    Parameters:
 *      EBP + 8:  pDriver
 *      EBP + 12: c
 *
 *    Returns:
 *      -
 *
 */
.code32
.section .text.vidUpdateCursor,"ax",@progbits
.global vidUpdateCursor
vidUpdateCursor:
    push ebp
    mov ebp, esp

    push ebx
    push ecx
    push edi
    push esi

    xor ebx, ebx

    /* Get the video memory address from driver struct */
    mov esi, [ebp + 8]
    /* Get the character to check for escape characters */
    mov cl, [ebp + 12]

    /* Check for "New Line" ==> need to set col to 0 and row to row + 1 */
    cmp cl, '\n'
    jnz .return_vidUpdateCursor

    /* Get the col parameter and set it to 0 */
    mov BYTE PTR [esi + VIDEO_TEXTMODE_DRV_CURSOR_COL_OFFSET], 0
    /* Get the row parameter and incremenmt it by 1 */
    mov bl, BYTE PTR [esi + VIDEO_TEXTMODE_DRV_CURSOR_ROW_OFFSET]
    inc bl
    mov BYTE PTR [esi + VIDEO_TEXTMODE_DRV_CURSOR_ROW_OFFSET], bl

    jmp .updateDone_vidUpdateCursor

.return_vidUpdateCursor:
    /* Check for "Return" and set col to 0 */
    cmp cl, '\r'
    jnz .tab_vidUpdateCursor
    /* Get the col parameter and set it to 0 */
    mov BYTE PTR [esi + VIDEO_TEXTMODE_DRV_CURSOR_COL_OFFSET], 0

    jmp .updateDone_vidUpdateCursor

.tab_vidUpdateCursor:
    cmp cl, '\t'
    jnz .anyChar_vidUpdateCursor
    /* Get the row parameter and set it as new row value in driver struct */
    mov bl, BYTE PTR [esi + VIDEO_TEXTMODE_DRV_CURSOR_ROW_OFFSET]
    add bl, 4
    mov BYTE PTR [esi + VIDEO_TEXTMODE_DRV_CURSOR_ROW_OFFSET], bl

    jmp .updateDone_vidUpdateCursor

.anyChar_vidUpdateCursor:
    /* Handle "else" branch for any other character */
    /* For this, we increment the col and handle the wrap of the line */
    mov bl, BYTE PTR [esi + VIDEO_TEXTMODE_DRV_CURSOR_COL_OFFSET]
    inc ebx
    cmp bl, 79
    jg .handleWrap_vidUpdateCursor
    mov BYTE PTR [esi + VIDEO_TEXTMODE_DRV_CURSOR_COL_OFFSET], bl
    jmp .updateDone_vidUpdateCursor

.handleWrap_vidUpdateCursor:
    mov bl, 0
    mov BYTE PTR [esi + VIDEO_TEXTMODE_DRV_CURSOR_COL_OFFSET], bl
    mov bl, BYTE PTR [esi + VIDEO_TEXTMODE_DRV_CURSOR_ROW_OFFSET]
    inc bl
    mov BYTE PTR [esi + VIDEO_TEXTMODE_DRV_CURSOR_ROW_OFFSET], bl

.updateDone_vidUpdateCursor:

    pop esi
    pop edi
    pop ecx
    pop ebx

    leave
    ret

/*
 * Outputs a char at current cursor position
 *
 * void vidOutputChar(VIDEO_TEXTMODE_DRIVER* pDriver, char c);
 *
 *    Parameters:
 *      EBP + 8:  pDriver
 *      EBP + 12: c
 *
 *    Returns:
 *      -
 *
 */
.code32
.section .text.vidOutputChar,"ax",@progbits
.global vidOutputChar
vidOutputChar:
    push ebp
    mov ebp, esp

    push ebx
    push ecx
    push edi
    push esi

    /* Get the video memory address from driver struct */
    mov esi, [ebp + 8]
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

    /* Get the char to print */
    mov cl, BYTE PTR [ebp + 12]
    cmp cl, 31
    jle .updateCursor_vidOutputChar

.output_vidOutputChar:
    /* Move character and color info as word into video memory */
    mov [edi], cx

.updateCursor_vidOutputChar:
    /* Update cursor position for character output */
    push ecx
    push esi
    call vidUpdateCursor
    add esp, 8

    pop esi
    pop edi
    pop ecx
    pop ebx

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
    mov edi, [ebp + 8]
    /* Get the pointer to the string */
    mov esi, [ebp + 12]
    /* Get first char */
    mov cl, [esi]

.printLoop_vidOutputString:
    push ecx
    push edi
    call vidOutputChar
    add esp, 8

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
