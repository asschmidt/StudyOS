/*
 * BIOS Standard IO Functions
 * The functions in this module use the BIOS to provide standard io functionality
 * like screen outputs
 *
 * Only usable in Real-Mode
 *
 */
.intel_syntax noprefix

/* Include the BIOS defines */
.include "bios_defines.asm"


/*
 * Clears the screen by scrolling all lines via BIOS INT 10h
 *
 * void ioClearScreen();
 *
 * Parameters:
 *    -
 *
 * Returns:
 *    -
 *
 */
.code16
.section .text.biosClearScreen,"ax",@progbits
.global biosClearScreen
biosClearScreen:
    push ax                                 /* Save register we will modify */
    push bx
    push cx
    push dx

    mov ah, 0x06                            /* BIOS functio to scroll */
    mov al, 0x00                            /* Scroll complete screen */
     /* Set background color to black and foregound color to light gray */
    mov bh, (COLOR_BLACK << 8) | COLOR_LIGHTGRAY
    mov ch, SCREEN_ROW_TOP_LEFT             /* Row of top left corner of the scroll window */
    mov cl, SCREEN_COL_TOP_LEFT             /* Column of top left corner of the scroll window */
    mov dh, SCREEN_ROW_LOWER_RIGHT          /* Row of the lower right corner of the scroll window */
    mov dl, SCREEN_COL_LOWER_RIGHT          /* Column of the lower right corner of the scroll window */

    int 0x10                                /* Call the BIOS function */

    pop dx                                  /* Restore register */
    pop cx
    pop bx
    pop ax

    ret


/*
 * Sets the cursor position via BIOS INT 10h
 *
 * void biosSetCursor(int row, int col);
 *
 * Parameters:
 *    BP + 6: col
 *    BP + 4: row
 *
 * Returns:
 *    -
 *
 */
.code16
.section .text.biosSetCursor,"ax",@progbits
.global biosSetCursor
biosSetCursor:
    push bp                                 /* Setup stack frame */
    mov bp, sp

    push ax                                 /* Save register we will modify */
    push bx
    push cx

    mov ah, 0x02                            /* Functio number 01 to set cursor position */
    mov bh, 0x00                            /* Set Page to 0 */
    mov dh, BYTE PTR [bp + 6]               /* Get col argument from stack */
    mov dl, BYTE PTR [bp + 4]               /* Get row argument from stack */

    int 0x10                                /* Call BIOS function */

    pop cx                                  /* Restore register */
    pop bx
    pop ax

    leave                                   /* Restore frame pointer */
    ret                                     /* Pop return address */


/*
 * Outputs a single charater via BIOS INT 10h
 *
 * void biosPutChar(char a);
 *
 * Parameters:
 *    AL: Char to output
 *
 * Return:
 *    -
 *
 */
.code16
.section .text.biosPutChar,"ax",@progbits
.global biosPutChar
biosPutChar:
    push ax
    push bx
    mov ah, byte ptr 0x0E
    mov bh, byte ptr 0x00
    mov bl, byte ptr 0x07
    int 0x10
    pop bx
    pop ax
    ret

/*
 * Outputs a Null-Terminated String via BIOS INT 10h
 *
 * void biosPutString(char* string);
 *
 * Parameters:
 *    SI: Pointer to Null-Terminated string
 *
 * Returns:
 *    -
 *
 */
.code16
.section .text.biosPutString,"ax",@progbits
.global biosPutString
biosPutString:
    push si
    push ax
    push bx

.loop:
    lodsb
    or al, al
    jz .done

    mov ah, byte ptr 0x0E
    mov bh, byte ptr 0x00
    int 0x10

    jmp .loop

.done:
    pop bx
    pop ax
    pop si
    ret

