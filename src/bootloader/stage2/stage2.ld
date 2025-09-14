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
 * 0x07C00 	 0x07DFF 	512 bytes 	OS BootSector Stage 1
 * 0x07E00   0x0FDFF    32 KiB      OS Bootloader Stage 2
 * 0x0FE00   0x11DFF    8 KiB       .bss for Bootloader Stage 2
 * 0x11E00   0x7CFFF    428,5 KiB   Reserved Memory
 * 0x7F000   0x7FFFF    4 KiB       Stack Memory Stage 2
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
DUMMY_ADDRESS               = 0x00100000;


/******************************************************************************
 * Common Settings for Bootloader
 *****************************************************************************/

/*
 * Defines the memory address for the Stage2 bootloader. The Stage1
 * bootloader will load the binary of the Stage2 bootloader into this
 * memory address and jumps to this address to execute Stage2
 */
STAGE2_ADR              = 0x7E00;
STAGE2_SIZE             = 32K;
STAGE2_OFFSET           = 0x0;
STAGE2_SEGMENT          = (STAGE2_ADR - STAGE2_OFFSET) / 16;

/*
 * Defines the start address and size for the RAM used by the Stage2
 * Bootloader. This covers the .bss section The .data section contains
 * initialized variables and must be loaded into memory. Therefore the
 * .data section must reside in the bootloader binary
 */
STAGE2_RAM_ADR          = STAGE2_ADR + STAGE2_SIZE;
STAGE2_RAM_SIZE         = 8K;
STAGE2_RAM_OFFSET       = 0x0;
STAGE2_RAM_SEGMENT      = (STAGE2_RAM_ADR - STAGE2_RAM_OFFSET) / 16;

/*
 * Defines the address (offset and segment) and size of the Stack for Stage2
 * Bootloader.
 * Remark: This is an address > than 16 Bit and must be recalculated in segement/
 * offset pair for usage in the bootloader code. The Linker can handle the adress
 * calculations for the stack with more than 16 Bit.
 */
STAGE2_STACK_ADR        = 0x7F000;
STAGE2_STACK_SIZE       = 4K;
STAGE2_STACK_OFFSET     = 0x0;
STAGE2_STACK_SEGMENT    = (STAGE2_STACK_ADR - STAGE2_STACK_OFFSET) / 16;


MEMORY
{
    /* Memory Areas for Stage 2 RAM */
    STAGE2_RAM (rw)	    : ORIGIN = STAGE2_RAM_ADR,                  LENGTH = STAGE2_RAM_SIZE
    STAGE2_RAM_VMA (rw)	: ORIGIN = STAGE2_OFFSET + STAGE2_SIZE,     LENGTH = STAGE2_RAM_SIZE

    /* Memory Area for Stage 2 Stack */
    STAGE2_STACK(rw)    : ORIGIN = STAGE2_STACK_ADR                 LENGTH = STAGE2_STACK_SIZE

    /* Memory Area for Stage 2 Bootloader */
    STAGE2 (rx)         : ORIGIN = STAGE2_ADR                       LENGTH = STAGE2_SIZE
    STAGE2_VMA (rwx)    : ORIGIN = STAGE2_OFFSET                    LENGTH = STAGE2_SIZE

    /* Dummy Memory region to store sections not part of the final binary */
    /* The address space of this region doesn't really matter, we should
       just move it our of the way from everything else */
    DUMMY (rwx)                 : ORIGIN = DUMMY_ADDRESS,                   LENGTH = 10M
}

/* Define the addresses (segment + offset) for the Stage 2 Bootloader */
_stage2_offset         = STAGE2_OFFSET;
_stage2_segment        = STAGE2_SEGMENT;
_stage2_length         = STAGE2_SIZE;

/* Define the size of the Stack used by the Stage 2 Bootloader */
_stage2_ram_offset     = STAGE2_RAM_OFFSET;
_stage2_ram_segment    = STAGE2_RAM_SEGMENT;
_stage2_ram_size       = STAGE2_RAM_SIZE;

/* Define the size of the Stack used by the Stage 2 Bootloader */
_stage2_stack_offset   = STAGE2_STACK_OFFSET;
_stage2_stack_segment  = STAGE2_STACK_SEGMENT;
_stage2_stack_size     = STAGE2_STACK_SIZE;

SECTIONS
{
	.text :
   	{
        . = ALIGN(4);

    	*(.text);
        *(.text.*);

        . = ALIGN(4);
   	} > STAGE2_VMA AT> STAGE2

	.rodata :
   	{
        . = ALIGN(4);
    	KEEP(*(.rodata));
        . = ALIGN(4);

	} > STAGE2_VMA AT> STAGE2

	.data :
   	{
        . = ALIGN(4);
        /* Symbol for the start of the data section */
   		_data_start = .;

    	KEEP(*(.data));

        /* Symbol to mark the end of the data section */
    	_data_end = .;
        . = ALIGN(4);

	} > STAGE2_VMA AT> STAGE2

    .gdt :
   	{
        . = ALIGN(4);
    	KEEP(*(.gdt));
        . = ALIGN(4);

	} > STAGE2_VMA AT> STAGE2

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
	} > STAGE2_RAM_VMA AT> STAGE2_RAM

    /*
     * Calculate the start for the .stack section based on the RAM memory size and the
     * configured stack size. The .stack section is moved to the end of the RAM region
     */
    _stage2_stack_section_start = ALIGN(ORIGIN(STAGE2_STACK) + LENGTH(STAGE2_STACK) - _stage2_stack_size, 4);
    .stack _stage2_stack_section_start :
    {
        _stage2_stack_end  = .;

        /* The fill-bytes are not stored in the binary */
        FILL(0xCD);

        . = ORIGIN(STAGE2_STACK) + LENGTH(STAGE2_STACK) - 1;

        /*
         * This start symbol represents the linera address of the last usable stack address.
         * Therefore this symbol cannot directly be used for stack handling of the processor
         * because the stack area is put and the end of the conventional address space which
         * cannot be addressed by a single 16 bit address
         */
        _stage2_stack_start = .;

    } > STAGE2_STACK

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

    _stage2_stack_start_offset = STAGE2_STACK_OFFSET + STAGE2_STACK_SIZE;

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