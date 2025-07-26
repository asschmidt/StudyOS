/*
 * Functions used to prepare GDT and use it in Protected Mode
 *
 *
 */
.intel_syntax noprefix

/*
 * Prepares the GDT Descriptor to initialize GDT via lgdt instruction
 *
 * void pmPrepareGDT(short gdtStartAddr, short gdtEndAddr, short segmentAdr, short* pGDTDesc);
 *
 *    Parameters:
 *      BP + 4:  gdtStartAddr
 *      BP + 6:  gdtEndAddr
 *      BP + 8:  segmentAddr
 *      BP + 10: pGDTDesc
 *
 *    Returns:
 *      -
 *
 */
.code16
.section .text.pmPrepareGDT,"ax",@progbits
.global pmPrepareGDT
pmPrepareGDT:
    push bp                                 /* Prepare Stack Frame */
    mov bp, sp

    push ax
    push bx
    push di

    mov ax, [bp + 6]                        /* Get gdtEndAddress from Parameter Stack */
    mov bx, [bp + 4]                        /* Get gdtStartAddress from Parameter Stack */
    sub ax, bx                              /* size = endAddress - stardAddress */
    dec ax                                  /* size = size - 1 */

    mov di, [bp + 10]                       /* Get pGDTDesc */
    mov es:[di], ax                         /* pGDTDesc->size = ax*/


    mov ax, [bp + 4]                        /* Get gdtStartAddress from Parameter Stack */
    mov bx, [bp + 8]                        /* Get segmentAddress from Parameter Stack */
    shl bx, 4                               /* segment = segmentAddress * 16 */
    add ax, bx                              /* linearAddress = segment + offset */

    mov di, [bp + 10]                       /* Get pGDTDesc */
    mov es:[di + 2], ax                     /* pGDTDesc->linearAddress = ax */

    pop di
    pop bx
    pop ax

    leave
    ret

/*
 * Loads a new GDT and flushes the segment register
 *
 * void pmReloadGDT(unsigned int* pGDTDesc);
 *
 * Parameters:
 *    EBP + 4: pGDTDesc
 *
 * Returns:
 *    -
 *
 */
.code32
.section .text.pmReloadGDT,"ax",@progbits
.global pmReloadGDT
pmReloadGDT:
    ret
