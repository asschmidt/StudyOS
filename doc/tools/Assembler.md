# Assembler
Beside most of the other OS-related open source projects, I'm using the GNU Assembler instead of NASM oder YASM. The reason for this is, that I just wanted to play around with the GNU Assembler and sticking just to the GNU toolchain. I know, that usually the GNU Assembler is used to assemble compiler generated assembler code and therefore is missing some convinient features. Anyway, I tried to use some nice features from the GNU Toolchain to add some features to the assemble-process.

## GNU Preprocessor for Assembler
The GNU Assembler doesn't have a preprocessor like the C-Compiler. But lukily, it is possible to use the GNU Pre-Processor to pre-process assembler files. But why?

Well, according to good programming practices, you should not use _magic numbers_ inside your code. This is also valid for assembler code. So if we want to use some special constant addresses, special values etc. you usually declare a kind of constant and use a symbolic name in your code.

This works also in principle with the GNU Assembler. You can define a symbol with a value and use it like a constant in your code.

```asm
.set MY_CONSTANT,  100
.set ANOTHER_CONSTANT, 0xB000


mov ax, MY_CONSTANT
```

Combined with the possibility of using include-files with the GNU Assembler, it is possible to collect common constants in a separate file and include them in any assembler file you need those constants.

```asm
.include "bios_defines.asm"
```

On drawback with this approach is, that the assembler is generating for each `.asm` file all the symbols which are included in the include file. Hereby is doesn't matter whether the symbols are used or not. Later, during the linking process, you get a binary with many duplicated symbols. Technically it seems not to be an issue, but this blows up the symbol table and makes the analysis and debugging of symbols tables a little harder.

To overcome this limitation, we can use the GNU Pre-Processor to pre-process the assembler files and use typical `#include` and `#define` directives. The GNU Pre-Processor can process any text-file as input and with some additional commandline parameters, we can instruct the preprocessor to preserve comments and spaces for the generated output file. This behaviour is important, because we want to use our source level debugging based on the original code we wrote. Normally, the pre-processor would remove all comments and uncessary spaces and blank lines. This would make source level debugging not that nice.

The following settings are important to use the GNU Pre-Processor for assembler files

| Commandline Argument | Description                   |
| -------------------- | ------------------------------|
| `-P`                 | Prevent the generation of linemarkers in the output file             |
| `-CC`                | Do not discard the comments                                          |
| `-traditional-cpp`   | Use the traditional mode to preserve the whitespaces and blank lines |

With these settings, the generated output file looks nearly exactly the same as the input file. The only difference is, that we have possbily the include file content inserted (depends on what has been defined in the include file) and the symbol names are replaced/expanded with the defined macros.

With the settings mentiond above, we can use most features from the GNU Pre-Processor. Mostly this will cover the `#include` and `#define` directives and conditional compilation with `#ifdef....#else....#endif` sections.

The following code snippets show an example for an assembler include file and the use of it

```c
#ifndef _BIOS_DEFINES_ASM_
#define _BIOS_DEFINES_ASM_

/*
 * Common defines for BIOS information and data structures
 *
 */

.intel_syntax noprefix

/*
 * Disk Info Structure
 * Used by to store disc information retrieved from BIOS INT 13h - Function 08h
 *
 * struct {
 *   uint16_t cylinder;     // 2 Byte
 *   uint8_t  sectors;      // 1 Byte
 *   uint8_t  heads;        // 1 Byte
 * };                       // 4 Byte
 *
 */
#define DISK_INFO_STRUCT_SIZE         4
#define DISK_INFO_CYLINDER_OFFSET     0
#define DISK_INFO_SECTORS_OFFSET      2
#define DISK_INFO_HEADS_OFFSET        3


#endif
```

An the assembler source file which uses the include file might look like this

```c
.intel_syntax noprefix

#include "bios_defines.asm"
.
.
.
/*
 * Reserve space for a DISC_INFO_STRUCT
 *
*/
DISK_INFO:              .space DISK_INFO_STRUCT_SIZE
PART_TAB_ENTRY1:        .space PART_TABLE_ENTRY_SIZE
PART_TAB_ENTRY2:        .space PART_TABLE_ENTRY_SIZE
PART_TAB_ENTRY3:        .space PART_TABLE_ENTRY_SIZE
PART_TAB_ENTRY4:        .space PART_TABLE_ENTRY_SIZE
```
