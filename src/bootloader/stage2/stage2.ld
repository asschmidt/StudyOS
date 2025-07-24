/*
 * Linker File for Stage2 Bootloader
 *
 * The Stage 1 Bootloader loads the Stage 2 Bootloader to a specific address in memory
 * Therefore the memory maps for Stage 1 and Stage 2 must be aligned and consistent to
 * avoid issues
 *
 * Memory Map during startup
 * -------------------------------------------------------
 * Start     End        Size        Usage
 * 0x00500   0x074FF    28 KiB      .bss for Bootloader Stage 1 + 2
 * 0x07500   0x07BFF    1792 Bytes  Reserved Memory
 * 0x07C00 	 0x07DFF 	512 bytes 	OS BootSector Stage 1
 * 0x07E00   0x17DFF    64 KiB      OS Bootloader Stage 2
 * 0x17E00   0x77FFF    384,5 KiB   Reserved Memory
 * 0x78000   0x7FBFF    31 KiB      Stack Memory Stage 2
 * 0x7FC00   0x7FFFF    1 KiB       Stack Memory Stage 1 + 2
 *
 *
*/

ENTRY(stage2Start)

/******************************************************************************
 * Common Settings for Linker
 *****************************************************************************/

/*
 * Define a fictive memory address used for the Dummy area for linker sections
 * which are not used for the binary but helpful for debugging etc.
 * The chosen address is the end of the addressable memory space for x86 in
 * real mode (= 1MB)
 */
DUMMY_ADDRESS       = 0x00100000;


/******************************************************************************
 * Common Settings for Bootloader
 *****************************************************************************/

/*
 * Defines the start address and size of the Stage 1 bootloader
 * These values are pre-defined by the BIOS and cannot be changed
 */
BOOT_ADDRESS        = 0x7C00;
BOOTLOADER_LENGTH   = 440;

/*
 * Defines the memory address for the Stage2 bootloader. The Stage1
 * bootloader will load the binary of the Stage2 bootloader into this
 * memory address and jumps to this address to execute Stage2
 */
BOOTLOADER_STAGE2_ADR     = 0x7E00;
BOOTLOADER_STAGE2_OFFSET  = 0x0;
BOOTLOADER_STAGE2_SEGMENT = (BOOTLOADER_STAGE2_ADR - BOOTLOADER_STAGE2_OFFSET) / 16;
BOOTLOADER_STAGE2_LENGHT  = 64K;

/*
 * Defines the start address and size for the RAM used by the Stage2
 * Bootloader. This covers the .bss section The .data section contains
 * initialized variables and must be loaded into memory. Therefore the
 * .data section must reside in the bootloader binary
 */
BOOT_RAM_ADR        = 0x0500;
BOOT_RAM_SIZE       = 28K;

/*
 * Defines the address (offset and segment) and size of the Stack for Stage2
 * Bootloader.
 * Remark: This is an address > than 16 Bit and must be recalculated in segement/
 * offset pair for usage in the bootloader code. The Linker can handle the adress
 * calculations for the stack with more than 16 Bit.
 */
BOOT_STACK_ADR      = 0x78000;
BOOT_STACK_SIZE     = 32K;

/*
 * Define the offset for the stack segment (Offset 0x400 = 1 KiB --> Last address in Stack)
 * and calculate the corresponding segment for the physical address of the stack
 * based on the chosen offset
 */
BOOT_STACK_OFFSET   = 0x0;
BOOT_STACK_SEGMENT  = (BOOT_STACK_ADR - BOOT_STACK_OFFSET) / 16;

MEMORY
{
    /* Memory Areas for Stage1 Bootloader */
    BOOTLOADER_RAM (rw)	        : ORIGIN = BOOT_RAM_ADR,            LENGTH = BOOT_RAM_SIZE
    BOOTLOADER (rx) 	        : ORIGIN = BOOT_ADDRESS, 	        LENGTH = BOOTLOADER_LENGTH
    BOOTLOADER_STACK(rw)        : ORIGIN = BOOT_STACK_ADR           LENGTH = BOOT_STACK_SIZE

    /* Memory Area for Stage2 Bootloader */
    BOOTLOADER_STAGE2 (rx)      : ORIGIN = BOOTLOADER_STAGE2_ADR    LENGTH = BOOTLOADER_STAGE2_LENGHT
    /* Memory Area for Stage2 Bootloader providing the offset as origin */
    BOOTLOADER_STAGE2_EXE (rwx) : ORIGIN = BOOTLOADER_STAGE2_OFFSET LENGTH = BOOTLOADER_STAGE2_LENGHT

    /* Dummy Memory region to store sections not part of the final binary */
    /* The address space of this region doesn't really matter, we should
       just move it our of the way from everything else */
    DUMMY (rwx)                 : ORIGIN = DUMMY_ADDRESS,           LENGTH = 10M
}

/* Define the size of the Stack used by the Stage2 Bootloader */
_boot_stack_offset  = BOOT_STACK_OFFSET;
_boot_stack_segment = BOOT_STACK_SEGMENT;
_boot_stack_size    = BOOT_STACK_SIZE;

/* Symbols used in Stage2 Bootloader to setup the complete RAM area */
_ram_start        = ORIGIN(BOOTLOADER_RAM);
_ram_size	      = LENGTH(BOOTLOADER_RAM);

/* Define the addresses (segment + offset) for the Stage2 Bootloader */
_boot_stage2_offset  = BOOTLOADER_STAGE2_OFFSET;
_boot_stage2_segment = BOOTLOADER_STAGE2_SEGMENT;
_boot_stage2_length  = BOOTLOADER_STAGE2_LENGHT;


SECTIONS
{
	.text :
   	{
        . = ALIGN(4);

    	*(.text);
        *(.text.*);

        . = ALIGN(4);
   	} > BOOTLOADER_STAGE2_EXE AT > BOOTLOADER_STAGE2

	.rodata :
   	{
        . = ALIGN(4);
    	KEEP(*(.rodata));
        . = ALIGN(4);

	} > BOOTLOADER_STAGE2_EXE AT > BOOTLOADER_STAGE2

	.data :
   	{
        . = ALIGN(4);
        /* Symbol for the start of the data section */
   		_data_start = .;

    	KEEP(*(.data));

        /* Symbol to mark the end of the data section */
    	_data_end = .;
        . = ALIGN(4);

	} > BOOTLOADER_STAGE2_EXE AT > BOOTLOADER_STAGE2

    .gdt :
   	{
        . = ALIGN(4);
    	KEEP(*(.gdt));
        . = ALIGN(4);

	} > BOOTLOADER_STAGE2_EXE AT > BOOTLOADER_STAGE2

	.bss :
   	{
        . = ALIGN(4);

        /* Symbol to mark the start of the .bss section */
   		_bss_start = .;

    	/*
         * Insert all .bss input sections
         * Hereby, only space is reserved and no actual data is stored in the ELF
         * binary for this section.
         */
    	KEEP(*(.bss));

        /* Symbol to mark the end of the .bss section */
    	_bss_end = .;

        . = ALIGN(4);
	} > BOOTLOADER_RAM

    /*
     * Calculate the start for the .stack section based on the RAM memory size and the
     * configured stack size. The .stack section is moved to the end of the RAM region
     */
    _stack_section_start = ALIGN(ORIGIN(BOOTLOADER_STACK) + LENGTH(BOOTLOADER_STACK) - _boot_stack_size, 4);
    .stack _stack_section_start :
    {
        _boot_stack_end  = .;

        /* The fill-bytes are not stored in the binary */
        FILL(0xCD);

        . = ORIGIN(BOOTLOADER_STACK) + LENGTH(BOOTLOADER_STACK) - 1;

        /*
         * This start symbol represents the linera address of the last usable stack address.
         * Therefore this symbol cannot directly be used for stack handling of the processor
         * because the stack area is put and the end of the conventional address space which
         * cannot be addressed by a single 16 bit address
         */
        _boot_stack_start = .;

    } > BOOTLOADER_STACK

    /*
     * Calculate the start offset address of the stack
     * This considers the segment:offset addressing scheme by using the start offset
     * and the size of the stack to calulcate the last usable stack address
     *
     * This value is used to initialize the Stack Pointer. Due to the fact that the x86 uses
     * a full-decending stack, the stack pointer is at first decreased and then the data is
     * stored. Therefore the SP will be initialized with a value which one address step
     * outside the valid stack memory
     */

    _boot_stack_start_offset = BOOT_STACK_OFFSET + BOOT_STACK_SIZE;

	/* Helper Sections not relevant for the final binary, but helpful for debugging */
    .offsets :
    {
        *(.offsets);
    } > DUMMY

    .debug_helper :
    {
        KEEP(*(.debug_helper));
    } > DUMMY


    /* We move all unecessary sections into a dummy memory region */
    .interp         : { *(.interp) } > DUMMY
    .note.gnu.build-id  : { *(.note.gnu.build-id) } > DUMMY
    .hash           : { *(.hash) } > DUMMY
    .gnu.hash       : { *(.gnu.hash) } > DUMMY
    .dynsym         : { *(.dynsym) } > DUMMY
    .dynstr         : { *(.dynstr) } > DUMMY
    .gnu.version    : { *(.gnu.version) } > DUMMY
    .gnu.version_d  : { *(.gnu.version_d) } > DUMMY
    .gnu.version_r  : { *(.gnu.version_r) } > DUMMY

    .dynamic        : { *(.dynamic) } > DUMMY
    .got            : { *(.got) *(.igot) }  > DUMMY
    .got.plt        : { *(.got.plt) *(.igot.plt) } > DUMMY

    .plt            : { *(.plt) *(.iplt) } > DUMMY
    .plt.got        : { *(.plt.got) } > DUMMY
    .plt.sec        : { *(.plt.sec) } > DUMMY

    .data.rel.ro    :
    {
        *(.data.rel.ro.local* .gnu.linkonce.d.rel.ro.local.*)
        *(.data.rel.ro .data.rel.ro.* .gnu.linkonce.d.rel.ro.*)
    } > DUMMY

    .dynbss         : { *(.dynbss) } > DUMMY

	/DISCARD/ :
	{
		*(.eh_frame);
        *(.note.*);
        /*(.interp);
        *(.dynsym);
        *(.dynstr);
        *(.hash);
        *(.gnu.hash);
        *(.dynamic);
        *(.plt);
        *(.iplt);
        *(.plt.got)
        *(.plt.sec);*/
	}
}