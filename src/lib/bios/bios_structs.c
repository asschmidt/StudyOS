/*
 * BIOS Structs Module
 *
 * This module only provides dummy variables (put in a separate section in ELF binary) to
 * provide symbol and type information for the Debugger
 *
 */
#include "bios_structs.h"

// Global Disk-Info Struct Variable to generate Debug-Symbols which can be used in Debugger
DISK_INFO_STRUCT gDiskInfoStruct __attribute__ ((section (".debug_helper"))) = {0};
