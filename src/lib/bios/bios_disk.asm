/*
 * BIOS Disk Access
 * This module provides functions to interact with a disk using BIOS interrupts
 *
 * Only usable in Real-Mode
 *
 */
.intel_syntax noprefix

/* Include BIOS defines */
#include "bios_defines.asm"

/*
 * Read Disk information like Cylinder, Sector and Head count via BIOS INT 13h
 *
 * Parameter:
 *   DL: Disk number
 *	 DI: Pointer to DISK_INFO struct
 *   SI: Pointer to Error Message
 *
 * Returns:
 *   AL: 0 if successfull
 *		 1 if error occured
 */
.code16
.section .text.biosDiskGetInfo,"ax",@progbits
.global biosDiskGetInfo
biosDiskGetInfo:
    push bx                                     /* Save all register which we modify */
    push cx
    push dx
    push es                                     /* We save ES because it is modified */
    push di

    /* AH = status  (see INT 13,STATUS)
       BL = CMOS drive type e.g. 04 - 3Ť 1.44Mb
       CH = cylinders (0-1023 dec. see below)
       CL = sectors per track	(see below)
       DH = number of sides (0 based)
       DL = number of drives attached
       ES:DI = pointer to 11 byte Disk Base Table (DBT)
       CF = 0 if successful
          = 1 if error
    */
    mov ah, 0x08                                /* Function to get Disk Info */
    int 0x13
    jnc .readSuccess_biosDiskGetInfo            /* If reading was successfull, continue with the function */
    call biosFloppyError                        /* If the disk info throws an error, we call the error handler */

.readSuccess_biosDiskGetInfo:
    pop di
    pop es                                      /* Restore the original ES value */

    xor ax, ax                                  /* Clear AX register, we use it for the results */

    /*
     * CX Value
     * 15              7                 0
     * |-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|
     *  C C C C C C C C C C|S S S S S S S|
     *
    */
    push cx								        /* Save CX value to start bit-extraction for sector count etc. */
    and cl, 0x3F                                /* Remove top 2 bits of lower CX value (sector cound) */
    mov [di + DISK_INFO_SECTORS_OFFSET], cl     /* Store the sector count */
    pop cx                                      /* Restore the original CX value to start extraction of cylinder count */
    push cx                                     /* Save it again on the stack to have the value available after bit extraction */

    mov al, ch                                  /* Store bit 8:15 of cylinder count (which are the lower 8 bits of the original value) */
    and cx, 0x00C0						        /* Clear out alls bits but 7:6 */
    shr cx, 6							        /* Shift the bits 7:6 to the beginning */
    mov ah, cl                                  /* Store bis 7:6 as highest bits of cylinder count in ah ==> ax = [7:6][15:8] */

    inc ax                                      /* Increment cylinder number (cylinders are zero based) */
    mov [di + DISK_INFO_CYLINDER_OFFSET], ax	/* store the cylinder number in struct DISK_INFO */
    pop cx								        /* Restore the original value from BIOS interrupt to get sector number */

    inc dh                                      /* Increment the number of sides (which is zero based) */
    mov [di + DISK_INFO_HEADS_OFFSET], dh       /* Store it as head count */

.readDone_biosDiskGetInfo:
    pop dx                                      /* Restore all register we modified */
    pop cx
    pop bx
    ret


/*
 * Converts a LBA address to a CHS address
 *
 * Parameters:
 *   AX: LBA address
 *   DI: Pointer to DISK_INFO struct
 *
 * Returns:
 *   CX: Cylinder count
 *   DH: Head count
 *   DL: Sector count
 */
.code16
.section .text.diskConvToCHS,"ax",@progbits
.global diskConvToCHS
diskConvToCHS:
    push ax                                     /* Save AX register */
    push bx                                     /* Save BX register */

    mov bx, [di + DISK_INFO_SECTORS_OFFSET]		/* Sectors per head */
    xor bh, bh							        /* Clear bx */
    xor dx, dx                                  /* Clear DX register dx = 0 */
    div bx                                      /* ax = LBA / SectorsPerTrack */
                                                /* dx = LBA % SectorsPerTrack */

    inc dx                                      /* dx = (LBA % SectorsPerTrack + 1) = sector */
    mov cx, dx                                  /* cx = sector (temporarily) */


    mov bx, [di + DISK_INFO_HEADS_OFFSET]	    /* Total number of heads */
    xor dx, dx                                  /* dx = 0 */
                                                /* ax still has the result of (LBA / SectorsPerTrack) */
    div bx                                      /* ax = (LBA / SectorsPerTrack) / Heads = cylinder */
                                                /* dx = (LBA / SectorsPerTrack) % Heads = head */

    mov dh, dl                                  /* dh = head */
    mov dl, cl							        /* dl = sector */
    mov cx, ax							        /* cx = cylinder */

    pop bx
    pop ax
    ret


/*
 * Reads sectors from a disk via BIOS INT 10h
 *
 *  Parameters:
 *   AH: Drive number
 *   CX: Cylinder numer (zero based)
 *   DH: Head number (zero based)
 *   DL: Sector number (one based)
 *   SI: Pointer to error message for failed disk read
 *
 *   ES:BS: Memory address where to store read data
 */
.code16
.section .text.biosDiskReadSector,"ax",@progbits
.global biosDiskReadSector
biosDiskReadSector:
    push ax                                     /* save registers we will modify */
    push bx
    push cx
    push dx
    push di
    push si

    mov si, cx							        /* Store cylinder number in SI */
    and ch, 0xff						        /* Mask out the higher 8 bit of cylinder */

    mov cl, dl							        /* Store sector numbner in cl */
    shr si, 2							        /* Shift cylinder no by 2 to the right */
    and si, 0x00c0						        /* Get the bits 6 and 7 from cylinder */
    push ax								        /* Save ax for temporary use */
    mov ax, si							        /* Get the cylinder number (only bit 6 and 7) into ax */
    or cl, al							        /* Set bits 6 and 7 in cl according to ax */
    pop ax								        /* Restore old value of ax */

    mov dl, ah							        /* Store drive number in dl */
    mov ah, 0x02
    mov al, 1							        /* Number of sectors to read */
    mov di, 3                                   /* Retry count */

.readRetry_biosDiskReadSector:
    pusha                                       /* Save all registers, we don't know what bios modifies */
    stc                                         /* Set carry flag, some BIOS'es don't set it */
    int 0x13                                    /* Carry flag cleared = success */
    jnc .readDone_biosDiskReadSector            /* Jump if carry not set */

    /* Read failed */
    popa
    call biosDiskReset

    dec di
    test di, di
    jnz .readRetry_biosDiskReadSector

.readFailed_biosDiskReadSector:
    /* all attempts are exhausted */
    call biosFloppyError

.readDone_biosDiskReadSector:
    popa

    pop si
    pop di
    pop dx
    pop cx
    pop bx
    pop ax                                      /* restore registers modified */
    ret


/*
 * Resets disk controller via BIOS INT 10h
 *
 * Parameters:
 *   DL: drive number
 *
 * Returns:
 *   AL: 0 if reset was successfull
 *       1 if an error occured
 */
.code16
.section .text.biosDiskReset,"ax",@progbits
.global biosDiskReset
biosDiskReset:
    pusha                                       /* Save register */
    mov ah, 0                                   /* We want to call the reset of the Floppy Controller */
    stc                                         /* Set the carry flag, if the reset was successfull, it will be set to 0 */
    int 0x13                                    /* Reset Floppy Controller */
    jc .resetFailed_biosDiskReset               /* If reset has failed, set error */
    xor al, al                                  /* Clear AL register to signal reset was successfull */
    jmp .resetDone_biosDiskReset                /* Leave the function */

.resetFailed_biosDiskReset:
    mov al, 1                                   /* In case of error, set the error return code */

.resetDone_biosDiskReset:
    popa                                        /* Restore register */
    ret

/*
 * Floppy Error handlers
 * Uses biosPutString to show an error message
 *
 * Parameter:
 *   SI: Pointer to error message
 *
*/
.code16
.section .text.biosFloppyError,"ax",@progbits
.global biosFloppyError
biosFloppyError:
    call biosPutString                          /* Show the failed message */
    mov ah, 0
    int 0x16                                    /* Wait for keypress */
    jmp 0x0FFFF:0                               /* Jump to beginning of BIOS, should reboot */

