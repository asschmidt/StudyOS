/*
 * Programmable Interrupt Controller Module
 * Provides functions to configure the PIC
 *
 */

.intel_syntax noprefix

/* IO Port Address for PIC1 */
#define PIC1_IO_ADDR        0x20
/* IO Port Address for PIC2 */
#define PIC2_IO_ADDR        0xA0

/* IO Port Address for PIC1 Command Register */
#define PIC1_CMD_REG        PIC1_IO_ADDR
/* IO Port Address for PIC1 Data Register */
#define PIC1_DATA_REG       PIC1_IO_ADDR + 1

/* IO Port Address for PIC2 Command Register */
#define PIC2_CMD_REG        PIC2_IO_ADDR
/* IO Port Address for PIC2 Data Register */
#define PIC2_DATA_REG       PIC2_IO_ADDR + 1


/* PIC Commands */
/* End of Interrupt Command */
#define PIC_EOI             0x20
/* OCW3 irq ready next CMD read */
#define PIC_READ_IRR        0x0a
/* OCW3 irq service next CMD read */
#define PIC_READ_ISR        0x0b

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


/* Default Offsets for PIC1 and PIC2 */
#define PIC1_OFFSET         0x20
#define PIC2_OFFSET         0x28

