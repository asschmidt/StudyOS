/*
 * General Purpose I/O Module
 *
 * This module provides functions to read/write ports on a x86
 *
 */
.intel_syntax noprefix

/*
 * Writes a byte to the specified output port
 *
 * void pmPortOutByte(uint16_t port, uint8_t value);
 *
 * Parameters:
 *    EBP + 8:  port
 *    EBP + 12: value
 *
 * Returns:
 *    -
 *
 */
.code32
.section .text.pmPortOutByte,"ax",@progbits
.global pmPortOutByte
pmPortOutByte:
    push ebp
    mov ebp, esp

    push eax
    push edx

    /* Get byte value to write to output port from parameter stack */
    mov eax, [ebp + 12]
    and eax, 0x000000FF

    /* Get port address from parameter stack */
    mov edx, [ebp + 8]
    and edx, 0x0000FFFF

    /* Write to output port */
    out dx, al

    pop edx
    pop eax

    leave
    ret

/*
 * Reads a byte from the specified output port
 *
 * uint8_t pmPortInByte(uint16_t port);
 *
 * Parameters:
 *    EBP + 8:  port
 *
 * Returns:
 *    AL: Read byte value
 *
 */
.code32
.section .text.pmPortInByte,"ax",@progbits
.global pmPortInByte
pmPortInByte:
    push ebp
    mov ebp, esp

    push edx

    /* Get port address from parameter stack */
    mov edx, [ebp + 8]
    and edx, 0x0000FFFF

    /* Read byte from port */
    in al, dx

    pop edx

    leave
    ret


/*
 * Waits 1-4µs
 *
 * Waits non-deterministic 1-4µs by probing an unused port. Linux Kernel uses port
 * 0x80 for this simple wait.
 *
 * void pmPortWait();
 *
 * Parameters:
 *    -
 *
 * Returns:
 *    -
 *
 */
.code32
.section .text.pmPortWait,"ax",@progbits
.global pmPortWait
pmPortWait:
    push ebp
    mov ebp, esp

    push eax
    push edx

    xor eax, eax
    xor edx, edx

    mov dx, 0x80

    out dx, al

    pop edx
    pop eax

    leave
    ret
