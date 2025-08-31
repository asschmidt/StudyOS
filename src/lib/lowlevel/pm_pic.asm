/*
 * Programmable Interrupt Controller Module
 * Provides functions to configure the PIC
 *
 */

.intel_syntax noprefix

/* IO Port Address for PIC1 */
#define PIC1_IO_ADDR       0x20
/* IO Port Address for PIC2 */
#define PIC2_IO_ADDR       0xA0

/* IO Port Address for PIC1 Command Register */
#define PIC1_CMD_REG       PIC1_IO_ADDR
/* IO Port Address for PIC1 Data Register */
#define PIC1_DATA_REG      PIC1_IO_ADDR + 1

/* IO Port Address for PIC2 Command Register */
#define PIC2_CMD_REG       PIC2_IO_ADDR
/* IO Port Address for PIC2 Data Register */
#define PIC2_DATA_REG      PIC2_IO_ADDR + 1


/* PIC Commands */
/* End of Interrupt Command */
#define PIC_EOI            0x20
/* OCW3 irq ready next CMD read */
#define PIC_READ_IRR       0x0a
/* OCW3 irq service next CMD read */
#define PIC_READ_ISR       0x0b

/* PIC onfigure Bit Values */
/* Indicates that ICW4 will be present */
#define ICW1_ICW4 	        0x01
/* Single (cascade) mode */
#define ICW1_SINGLE 	    0x02
/* Call address interval 4 (8) */
#define ICW1_INTERVAL4  	0x04
/* Level triggered (edge) mode */
#define ICW1_LEVEL  	    0x08
/* Initialization - required! */
#define ICW1_INIT           0x10

/* 8086/88 (MCS-80/85) mode */
#define ICW4_8086 	        0x01
/* Auto (normal) EOI */
#define ICW4_AUTO 	        0x02
/* Buffered mode/slave */
#define ICW4_BUF_SLAVE  	0x08
/* Buffered mode/master */
#define ICW4_BUF_MASTER 	0x0C
/* Special fully nested (not) */
#define ICW4_SFNM           0x10

#define CASCADE_IRQ         2


/*
 * Sends an "End of Interrupt" to the corresponding PIC
 *
 * void pmPICSendEOI(uint8_t irg);
 *
 * Parameters:
 *    EBP + 8:  irq
 *
 * Returns:
 *    -
 *
 */
.code32
.section .text.pmPICSendEOI,"ax",@progbits
.global pmPICSendEOI
pmPICSendEOI:
    push ebp
    mov ebp, esp

    /* Get IRQ number from parameter stack */
    mov eax, [ebp + 8]
    /* Check if IRQ is less than 8. In that case we only need to handle PIC1 */
    cmp eax, 8
    jl .handlePIC1_pmPICSendEOI

.handlePIC2_pmPICSendEOI:
    push PIC_EOI                /* PIC_EOI */
    push PIC2_CMD_REG           /* PIC2_CMD_REG */
    call pmPortOutByte
    add esp, 8

.handlePIC1_pmPICSendEOI:
    push PIC_EOI                /* PIC_EOI */
    push PIC1_CMD_REG           /* PIC1_CMD_REG */
    call pmPortOutByte
    add esp, 8

    leave
    ret


/*
 * Remaps the PIC interrupts by an offset
 *
 * void pmPICRemap(int32_t offset1, int32 offset2);
 *
 * Parameters:
 *    EBP + 8:  offset1
 *    EBP + 12: offset2
 *
 * Returns:
 *    -
 *
 */
.code32
.section .text.pmPICRemap,"ax",@progbits
.global pmPICRemap
pmPICRemap:
    push ebp
    mov ebp, esp

    push edi
    push esi

    /* Get offset1 from parameter stack */
    mov edi, [ebp + 8]
    /* Get offset2 from parameter stack */
    mov esi, [ebp + 12]

    /* Start Initialization in Cascade Mode */
    push ICW1_INIT | ICW1_ICW4              /* ICW1_INIT | ICW1_ICW4 */
    push PIC1_CMD_REG                       /* PIC1_CMD_REG */
    call pmPortOutByte
    add esp, 8
    call pmPortWait

    push ICW1_INIT | ICW1_ICW4              /* ICW1_INIT | ICW1_ICW4 */
    push PIC2_CMD_REG                       /* PIC2_CMD_REG */
    call pmPortOutByte
    add esp, 8
    call pmPortWait

    /* Set Offset for Master PIC (PIC1) */
    push edi
    push PIC1_DATA_REG                      /* PIC1_DATA_REG */
    call pmPortOutByte
    add esp, 8
    call pmPortWait

    /* Set Offset for Slave PIC (PIC2) */
    push esi
    push PIC2_DATA_REG                      /* PIC2_DATA_REG */
    call pmPortOutByte
    add esp, 8
    call pmPortWait

    /* Tell Master PIC about the cascade IRQ 2 */
    push 1 << CASCADE_IRQ                   /* 1 << CASCADE_IRQ */
    push PIC1_DATA_REG                      /* PIC1_DATA_REG */
    call pmPortOutByte
    add esp, 8
    call pmPortWait

    /* Tell Slave PIC about cascade identity 0000 0010 */
    push CASCADE_IRQ                        /* CASCADE_IRQ */
    push PIC2_DATA_REG                      /* PIC2_DATA_REG */
    call pmPortOutByte
    add esp, 8
    call pmPortWait

    /* Tell Master PIC to use 8086 Mode */
    push ICW4_8086                          /* ICW4_8086 */
    push PIC1_DATA_REG                      /* PIC1_DATA_REG */
    call pmPortOutByte
    add esp, 8
    call pmPortWait

    /* Tell Slave PIC to use 8086 Mode */
    push ICW4_8086                          /* ICW4_8086 */
    push PIC2_DATA_REG                      /* PIC2_DATA_REG */
    call pmPortOutByte
    add esp, 8
    call pmPortWait

    /* Unmask Master PIC */
    push 0x00
    push PIC1_DATA_REG                      /* PIC1_DATA_REG */
    call pmPortOutByte
    add esp, 8
    call pmPortWait

    /* Unmask Slave PIC */
    push 0x00
    push PIC2_DATA_REG                      /* PIC2_DATA_REG */
    call pmPortOutByte
    add esp, 8
    call pmPortWait

    pop esi
    pop edi

    leave
    ret

/*
 * Reads an IRQ register from Master and Slave PIC
 *
 * uint16_t pmPICReadIRQReg(uint8_t ocw3);
 *
 * Parameters:
 *    EBP + 8:  ocw3
 *
 * Returns:
 *    16 Bit value of PIC1 and PIC2 IRQ register
 *
 */
.code32
.section .text.pmPICReadIRQReg,"ax",@progbits
.global pmPICReadIRQReg
pmPICReadIRQReg:
    push ebp
    mov ebp, esp

    push edi
    push esi

    /* Get ocw3 value from parameter stack */
    mov edi, [ebp + 8]

    /* Send OCW3 value to PIC1 */
    push edi
    push PIC1_CMD_REG                       /* PIC1_CMD_REG */
    call pmPortOutByte
    add esp, 8

    /* Send OCW3 value to PIC2 */
    push edi
    push PIC2_CMD_REG                       /* PIC2_CMD_REG */
    call pmPortOutByte
    add esp, 8

    /* Clear EAX register for return value */
    xor eax, eax

    /* Read command register from PIC1 containing the requested register value */
    push PIC1_CMD_REG                       /* PIC1_CMD_REG */
    call pmPortInByte
    add esp, 4

    /* Get the return value into esi */
    mov esi, eax

    /* Clear EAX register for return value */
    xor eax, eax

    /* Read command register from PIC2containing the requested register value */
    push PIC2_CMD_REG                       /* PIC2_CMD_REG */
    call pmPortInByte
    add esp, 4

    /* Move the PIC2 register value to upper 8 Bits */
    shl eax, 8
    /* Combine PIC1 and PIC2 value in EAX */
    or eax, esi

    pop esi
    pop edi

    leave
    ret

/*
 * Reads IRR register from Master and Slave PIC
 *
 * uint16_t pmPICReadIRR(void);
 *
 * Parameters:
 *    -
 *
 * Returns:
 *    16 Bit value of PIC1 and PIC2 IRR register
 *
 */
.code32
.section .text.pmPICReadIRR,"ax",@progbits
.global pmPICReadIRR
pmPICReadIRR:
    push ebp
    mov ebp, esp

    push PIC_READ_IRR                       /* PIC_READ_IRR */
    call pmPICReadIRQReg
    add esp, 4

    leave
    ret


/*
 * Reads ISR register from Master and Slave PIC
 *
 * uint16_t pmPICReadISR(void);
 *
 * Parameters:
 *    -
 *
 * Returns:
 *    16 Bit value of PIC1 and PIC2 IRR register
 *
 */
.code32
.section .text.pmPICReadISR,"ax",@progbits
.global pmPICReadISR
pmPICReadISR:
    push ebp
    mov ebp, esp

    push PIC_READ_ISR                       /* PIC_READ_ISR */
    call pmPICReadIRQReg
    add esp, 4

    leave
    ret


/*
 * Masks out the provided IRQ for Master and Slave PIC
 *
 * void pmPICSetMask(uint8_t irqLine);
 *
 * Parameters:
 *    EBP + 8:  ocwirqLine
 *
 * Returns:
 *    -
 *
 */
.code32
.section .text.pmPICSetMask,"ax",@progbits
.global pmPICSetMask
pmPICSetMask:
    push ebp
    mov ebp, esp

    push edi
    push esi
    push ecx

    /* Get IRQ Line from parameter stack */
    mov edi, [ebp + 8]
    cmp edi, 8
    /* If the IRQ Line is less than 8, we only mask on PIC1 */
    jl .maskPIC1_pmPICSetMask
    /* Otherwise we mask on PIC2 by using the PIC2 Data Register and correcting the IRQ Line for PIC2 */
    mov esi, PIC2_DATA_REG                  /* PIC2_DATA_REG */
    sub edi, 8
    jmp .maskWrite_pmPICSetMask

.maskPIC1_pmPICSetMask:
    mov esi, PIC1_DATA_REG                  /* PIC1_DATA_REG */

.maskWrite_pmPICSetMask:

    /* Read the current Mask Register Value */
    push esi
    call pmPortInByte
    add esp, 4

    /* mask = oldMask | (1 << irqLine) */
    mov ecx, edi
    mov edi, 1
    shl edi, cl
    or eax, edi

    /* Write Mask value to PIC */
    push eax
    push esi
    /* pmPortOutByte(picPort, maskValue); */
    call pmPortOutByte
    add esp, 8

    pop ecx
    pop esi
    pop edi

    leave
    ret



/*
 * Disables PIC1 and PIC2 by masking all interrupts
 *
 * void pmPICDisable(void);
 *
 * Parameters:
 *    -
 *
 * Returns:
 *    -
 *
 */
.code32
.section .text.pmPICDisable,"ax",@progbits
.global pmPICDisable
pmPICDisable:
    push ebp
    mov ebp, esp

    push 0xFF
    push PIC1_DATA_REG                      /* PIC1_DATA_REG */
    call pmPortOutByte
    add esp, 8

    push 0xFF
    push PIC2_DATA_REG                      /* PIC2_DATA_REG */
    call pmPortOutByte
    add esp, 8

    leave
    ret
