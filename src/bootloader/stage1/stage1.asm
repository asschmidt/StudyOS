/*
 * Bootsector Bootloader
 *
 * This Stage 1 of the Bootloader is loaded automatically by the BIOS
 * to the address 0x0000:0x7C00
 *
 * The main task of this bootloader stage is to setup the stack and
 * load Stage 2 of the Bootloader from the bootloader partition
 *
 * REMARK: The partition table, which must be part of the first sector,
 * is created by file system tool and therefore our bootsector stage1
 * bootloader must not contain any hard-coded partition table and
 * signature bytes
*/
.intel_syntax noprefix

#include "common_defines.asm"
#include "bios_defines.asm"

/*
 * External Symbols from Linker File
 */
.extern _mbr_address                    /* Memory adddress of MBR loaded into RAM by the BIOS */
.extern _boot_stage2_offset             /* Offset Address of the Stage 2 Bootloader Code */
.extern _boot_stage2_segment            /* Segement Address of the Stage 2 Bootloader Code + Data */
.extern _boot_stage2_length             /* Length of the Stage 2 Bootloader Code Segment */

.extern _boot_stack_segment             /* Segment Address for the Bootloader Stage 2 Stack Memory */
.extern _boot_stack_start_offset        /* Offset Address for the Bootloader Stage 2 Stack Memory */
.extern _boot_stack_size                /* Size of the Stack Memory Segment for Stage 2 Bootloader */

/*
 * Start of the Stage 1 execution
 * The following code is 16 Bit
*/
.code16
.section .text
.global stage1Start
stage1Start:
    cli		                		    /* Disable all interrupts */
    xor ax, ax	            		    /* Zero out AX register */
    mov ds, ax              		    /* Initialize the DataSegement to 0 */
    mov es, ax              		    /* Initialize the Extra Segement to 0 */

    mov ax, OFFSET _boot_stack_segment  /* Initialize AX to the Stack Segment */
    mov ss, ax              		    /* Initialize the Stack Segement to _boot_stack_segment */

    mov sp, OFFSET _boot_stack_start_offset	/* Initialize the Stack Pointer */
    mov bp, sp              		    /* Initialize the Base Pointer used in Stack Frames */
    push bp                 		    /* We save BP with the original SP value on stack */

    jmp 0:stage1Main          		    /* Far jump to main to set CS (Code Segement) register */

stage1Main:
    sti			            		    /* Enable all interrupts */
    mov [BOOT_DRV], dl	    		    /* remember the boot device */

    /* Initialize Stack Area for Stack-Monitoring*/
    mov ax, 0xCDCD					    /* Pattern used to initialize the RAM Stack */
    mov bx, OFFSET _boot_stack_segment  /* Get the stack segement to use it with the ES register */
    mov cx, OFFSET _boot_stack_size	    /* Get the size of the Stack memory */

    /* AX=Pattern, BX=Segment, CX=Size of stack */
    call memInitStack

    mov si, OFFSET MSG_REAL_MODE

    /* SI=Pointer to String */
    call biosPutString                      /* Print a Loading... message to screen */

    /* Read the Disk Information */
    mov dl, BYTE PTR [BOOT_DRV]         /* Get the drive we booted from */
    mov di, OFFSET DISK_INFO            /* Get a pointer to the global variable DISK_INFO */
    mov si, OFFSET MSG_READ_FAILED      /* Pointer to error message in case of disk issues */

    /* DL=Disk Number, DI=Pointer to DISK_INFO struct, SI=Pointer to Error Message */
    call biosDiskGetInfo                    /* Read disk info and populate global DISK_INFO structure */

    /* Get the first partition table entry to get CHS addresses for reading */
    /* Get the size of the struct */
    mov cx, PART_TABLE_ENTRY_SIZE
    /* Get the address of global partition table entry 1 struct */
    mov di, OFFSET PART_TAB_ENTRY1
    /* Get the address of first partition table entry in MBR */
    mov si, OFFSET _mbr_address + MBR_PART_TABLE_OFFSET

.partTabCopyLoop_stage1Main:
    lodsw							    /* Load the first 2 byte of the Partition Table from MBR*/
    stosw							    /* Store it in the global structure */
    sub cx, 2						    /* Decrement the read counter by 2 bytes */
    jnz .partTabCopyLoop_stage1Main     /* If still bytes to copy, go back to loop */

    /* Determine the parition and sector information to load Stage2 bootloader */
    mov di, OFFSET DISK_INFO
    /* Starting with first sector from partition table */
    mov ax, [PART_TAB_ENTRY1 + PART_TABLE_ENTRY_LBA_START_OFFSET]

    /* Count of sectors to read */
    mov si, OFFSET _boot_stage2_max_sector_count

    /* Destination address to store the "boot partition sectors" which contain Stage2 bootloader */
    mov bx, OFFSET _boot_stage2_segment /* Setup the ES segement for Stage 2 */
    mov es, bx
    mov bx, OFFSET _boot_stage2_offset	/* Setup the Offset for Stage 2 */

.stage2LoadLoop_stage1Main:
    /* AX=LBA Address, DI=Pointer to DISK_INFO structure */
    call diskConvToCHS          		/* We get CX = Cylinder, DH = Head, DL = Sector */

    push ax                             /* Save AX (contains current LBA) bevor reading the sector */
    mov ah, [BOOT_DRV]					/* Set boot drive number as parameter */

    /* CX=Cylinder, DH=Head, DL=Sector, AH=Drive Number, ES:BX=Buffer to store data */
    /* ES=0 - still set to zero as we did it during initialization */
    call biosDiskReadSector				/* Read from disk */
    pop ax                              /* Restore original AX (LBA) */

    dec si								/* Decrement the sector read counter */
    inc ax								/* Increment the sector address (LBA) -> next read */
    add bx, DEFAULT_SECTOR_SIZE 		/* Increment the pointer to the memory buffer by the sector size */
    jnc .stage2CheckNextLoad_stage1Main /* If we didn't get an overflow, loop again */

    /* If we got an overflow, we need to switch the segment */
.stage2UpdateSeg_stage1Main:
    mov bx, OFFSET _boot_stage2_offset	/* If we got an overflow, load the offset for Stage2 again */
    push ax								/* We use AX to modify ES, therefore save the current value */
    mov ax, es							/* Get the current segment */
    add ax, 0x1000						/* Increment the segment address to switch to next segment 0x1000 = next 64kb */
    mov es, ax							/* Set the new segment */
    pop ax								/* Restore old AX value */

.stage2CheckNextLoad_stage1Main:
    test si, si							/* Check for zero of our sector read counter */
    jnz .stage2LoadLoop_stage1Main		/* Loop till we read all sectors */

.stage2LoadDone_stage1Main:
    mov ax, 0                           /* */
    mov es, ax                          /* Reset the ES segement to 0 */
    jmp _boot_stage2_segment:0          /* Use stage 2 segement as new code segement */


/*
 * Error handlers
*/
.halt:
    cli                     		    /* Disable interrupts, this way CPU can't get out of "halt" state */
    hlt


/*
 * Variables in .data section (initialized data)
*/
.section .data
BOOT_DRV:               .word    0      /* Used to store the boot device */

/*
 * Constants and Strings in .rodata section
*/
.section .rodata
MSG_REAL_MODE:          .asciz "Entered Real-Mode\r\n"
MSG_READ_FAILED:        .asciz "Loading of Stage 2 failed\r\n"

/*
 * Variables in .bss section (unintialized)
*/
.section .bss

/*
 * Reserve space for a DISC_INFO_STRUCT
 *
*/
DISK_INFO:              .space DISK_INFO_STRUCT_SIZE
PART_TAB_ENTRY1:        .space PART_TABLE_ENTRY_SIZE
PART_TAB_ENTRY2:        .space PART_TABLE_ENTRY_SIZE
PART_TAB_ENTRY3:        .space PART_TABLE_ENTRY_SIZE
PART_TAB_ENTRY4:        .space PART_TABLE_ENTRY_SIZE
