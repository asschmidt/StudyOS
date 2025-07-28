# Stage 1 Bootloader
In this document, the Stage 1 Bootloader for StudyOS is described. Hereby, a couple of background information are provided. However, it is assumed that the following topics are more or less known
 * Real-Mode and Protected-Mode
 * x86 Segmented Memory with Segment-Register

## PC Startup
After a reset or power-cycle, the i8086 processor starts the execution always on a specific address. This is, written as linear address, the address `0xFFFF0` which is the same address as the address `0xFFFF:0x00000`. This segment address is loaded in the Code-Segment register and the Instruction Pointer whereby the `CS` register (Code Segment) is loaded with `0xFFFF` and the `IP` register (Instruction Pointer) is loaded with `0x0000`.

You can easily prove that both addresses are the same, by calculating for example the linear address of `0xFFFF:0x0000` with the following calculation:

LinearAddress = (Segment-Address * 16) + Offset

Hereby, the Segment-Address is the value in the `CS` register and the offset is the value in the `IP` register. Putting those numbers in, we get

LinearAddress = (0xFFFF * 16) + 0x0000 = 0xFFFF0 + 0x0000 = 0xFFFF0

Looking at a standard memory map of a PC, we can clearly see, that the address where the processor starts the execution is located in the "Motherboard BIOS" section.

![PC Memory Map](../../images/PC_Memory_Map.png)

> [!TIP]
> The address `0xFFFF0` is also the same address where GDB pops up when we start a debugging session with QEmu and Eclipse. See [Eclipse Setup](../../tools/Eclipse.md)

The BIOS code, which is executed directly after a reset or power-cycle, usually initializes some hardware and peripherals and starts loading the Master Boot Records from the devices in the search list of the BIOS until a valid boosector is found.

> [!NOTE]
> The described boot process with the initialization by the BIOS is super simplified and only valid for an old/non-modern PC. Modern BIOSes do much more, switch to Protected-Mode and back to Real-Mode and so on. For our purposes, we just look at the simplest one where the BIOS runs in Real-Mode, does some HW stuff and loads our bootsector and starts the execution of the bootsector code.



![PC Memory Map](../../images/Stage1_Memory_Map.png)


