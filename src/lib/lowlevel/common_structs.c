/*
 * Common Structs Module
 *
 * This module only provides dummy variables (put in a separate section in ELF binary) to
 * provide symbol and type information for the Debugger
 *
 */
#include "common_structs.h"

PART_TABLE_ENTRY gPartTableEntry __attribute__ ((section (".debug_helper"))) = {0};

GDT_DESC gGDTDesc __attribute__ ((section (".debug_helper"))) = {0};
GDT_ENTRY gGDTEntry __attribute__ ((section (".debug_helper"))) = {0};

IDT_DESC gIDTDesc __attribute__ ((section (".debug_helper"))) = {0};
IDT_ENTRY gIDTEntry __attribute__ ((section (".debug_helper"))) = {0};