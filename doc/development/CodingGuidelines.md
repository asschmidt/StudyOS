# Coding Guidelines
This document is a loosly coupled collection of rules and guidelines used for coding in StudyOS.

## Assembly
The project uses only the GNU Assembler and not any other assembler like NASM or YASM. The reason behind this decision is, that I just wanted to use the complete GNU toolchain without a special assembler. I know, the GNU Assembler is missing some cool and convinient features NASM provides, but it still gets the job perfectly done and is 100% compatible witht the GNU C Compiler ;-)

### Intel Syntax
In many projects where the GNU Assembler is used, the AT & T syntax is used. To be honest, I'm not very fimilar with this syntax and I personally don't like it. Therefore I decided to explicitly activate the Intel-Syntax for each assembly source file. Every assembly source file must have the following assembly directive at the beginning

`.intel_syntax noprefix`

### Labels inside a function
If local labels inside an assembly functions are used, they must be prefixed with a period and suffixed by an underscore followed by the function name. This ensures unique labels across different functions and indicates a local label compared to a public/global label.

The following code snippet shows an example

```
    mov di, sp
    sub di, 2

.stackInitLoop_memInitStack:
    mov es:[di], ax                     /* Store data in Stack */
    sub di, 2                           /* Decrement the write pointer */
    sub cx, 2                           /* Decrement the write counter */
    jnz .stackInitLoop_memInitStack     /* If still bytes to write, go back to loop */

```

### Structure of a Function
If a function is written in assembly, the functions must include a couple of settings with assembly directives and a comment header.

For each function it must be specified, whether the function is a 16 Bit or a 32 Bit function. This must be specified for each function, even if all functions in an assembly file are for the same code model.

For Real-Mode functions:
`.code16`

For Protected-Mode functions:
`.code32`

Additionally, each function must get its own `.text` section. This concept is the same if the GNU Compiler gets the command line option `-ffunction-sections`. This is helpfuil in using the _"Garbage Collection for Sections"_ during the link process where the linker can remove unused functions.

The general syntax to specify a section for a function is the following
`.section .text.<FunctionName>,"ax",@progbits`

The last mandatory directive is to make the function name label global. This is done with the `.global` directive

`.global <FunctionName>`

The next line after the `.global` directive is the function label itself

`<FunctionName>:`

The following code snippet shows a complete function header including the comment header describing the calling convention and the parameter/return values

```
/*
 * Prints a string by directly writing to Video Memory
 *
 * void pmPutString(char* pString, int videoMemoryOffset);
 *
 * Parameters:
 *    EBP + 8:  pString
 *    EBP + 12: Offset address for Video Memory (due to GDT offset)
 *
 * Returns:
 *    -
 *
 */
.code32
.section .text.pmPutString,"ax",@progbits
.global pmPutString
pmPutString:
```

### Calling Convention
All functions written in assembly should follow the `cdecl` calling convetion. Functions used in the very early beginning of the boot process (e.g. Stage 1 Bootloader) might use different or customized calling conventions.

If the `cdecl` calling convention is used, the comment header of the function should also show the prototype declaration of the function in C-Syntax. The following example comment header shows the C declaration of the function prototype `void pmPortOutByte(uint16_t port, uint8_t value);`

```
/*
 * Writes a byte to the specified output port
 *
 * void pmPortOutByte(uint16_t port, uint8_t value);
 *
 * Parameters:
 *    BP + 8:  port
 *    BP + 12: value
 *
 * Returns:
 *    -
 *
 */
```

The `cdecl` calling convention is descibed in detail in the [System V Application Binary Interface (ABI) i386](https://www.sco.com/developers/devspecs/abi386-4.pdf) in chapter _Function Calling Sequence_

#### Processor Register
The following registers and their corresponding usage are defined in the calling convetion

| Register       | Usage                                        |
| -------------- | -------------------------------------------- |
| `eax` / `ax`   | Return value                                 |
| `edx` / `dx`   | Dividend register (devide operations)        |
| `ecx` / `cx`   | Count register (shift and string operations) |
| `ebx` / `bx`   | Local register variable                      |
| `ebp` / `bp`   | Stack frame pointer (optional)               |
| `esi` / `si`   | Local register variable                      |
| `edi` / `di`   | Local register variable                      |
| `esp` / `sp`   | Stack pointer                                |

#### Stack Frame

Arguments are pushed onto the stack in reverse order. That is, the rightmost argument in C call syntax is pushed first on the stack.

The following stack frame setup is used for the calling convention in Protected-Mode (32 Bit Mode). For StudyOS, the Stack Frame Pointer is always used.

| Position      | Contents               | Frame    |
| ------------- | ---------------------- | -------- |
| `4n + 8(ebp)` | argument word n        | Previous |
|               | . . .                  |          |
| `8(ebp)`      | argument word 0        | Previous |
| ------------- | ---------------------- | -------- |
| `4(ebp)`      | return address         | Current  |
| `0(ebp)`      | previous `ebp` (opt.)  | Current  |
| `-4(ebp)`     | unspecified            | Current  |
|               | . . .                  | Current  |
| `0(esp)`      | variable size          | Current  |

> [!NOTE]
> If the processor is in Real-Mode, only 16 Bit register are used and therefore, the size of the arguments on the stack differs from the above one. If the processor is in Real-Mode, each parameter is only 16 Bit (2 Byte) in size

| Position      | Contents               | Frame    |
| ------------- | ---------------------- | -------- |
| `2n + 4(bp)`  | argument word n        | Previous |
|               | . . .                  |          |
| `4(bp)`       | argument word 0        | Previous |
| ------------- | ---------------------- | -------- |
| `2(bp)`       | return address         | Current  |
| `0(bp)`       | previous `bp` (opt.)   | Current  |
| `-2(bp)`      | unspecified            | Current  |
|               | . . .                  | Current  |
| `0(sp)`       | variable size          | Current  |

## Linker
All software components in StudyOS use a Linker Script to define the memory sections and symbols.

### Linker Symbols
Inside the Linker Script there are two different symbols (not from technical point of view, but from programmers point of view).

The first type of symbols are symbols and constants which are intented to be used only inside the Linker Script. These symbols shall be written in capital letters.

```
/*
 * Defines the linear address and size of the Stack for Stage1 Bootloader.
 *
 * Remark: This is an address > than 16 Bit and must be recalculated in segement/
 * offset pair for usage in the bootloader code. The Linker can handle the adress
 * calculations for the stack with more than 16 Bit.
 */
BOOT_STACK_ADR      = 0x7FC00;
BOOT_STACK_SIZE     = 1K;

/*
 * Define the offset for the stack segment (Offset 0x400 = 1 KiB --> Last address in Stack)
 * and calculate the corresponding segment for the physical address of the stack
 * based on the chosen offset
 */
BOOT_STACK_OFFSET   = 0x0;
BOOT_STACK_SEGMENT  = (BOOT_STACK_ADR - BOOT_STACK_OFFSET) / 16;
```

If a symbol planned to be used in other modules (e.g. assembler and C/C++ source files), it shall be written in small letters and it should have an underscore `_` as prefix.

```
/* Define the size of the Stack used by the Stage1 Bootloader */
_boot_stack_offset  = BOOT_STACK_OFFSET;
_boot_stack_segment = BOOT_STACK_SEGMENT;
_boot_stack_size    = BOOT_STACK_SIZE;
```