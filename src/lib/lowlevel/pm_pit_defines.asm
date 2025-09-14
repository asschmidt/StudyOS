/*
 * Programmable Interval Timer Module
 * Provides constants and defines for use with the PIT
 *
 */

.intel_syntax noprefix


/* PIT Oscillator Frequency = 1193182 Hz = 1.193182 MHz */
#define PIT_FREQUENCY           1193182
/* PIT Max frequency devider */
#define PIT_MAX_DIV             0x10000
/* PIT Min Frequency 18 Hz */
#define PIT_MIN_FREQ            18

/* Channel 0 Data Port Register (read/write) */
#define PIT_CH0_DATA_REG        0x40
/* Channel 1 Data Port Register (read/write) */
#define PIT_CH1_DATA_REG        0x41
/* Channel 2 Data Port Register (read/write) */
#define PIT_CH2_DATA_REG        0x42
/* Mode/Command Register (write only) */
#define PIT_MODE_CMD_REG        0x43

/* Defines of Mode/Command Register */
#define CMD_SEL_CHANNEL_0       (0x00 << 6)
#define CMD_SEL_CHANNEL_1       (0x01 << 6)
#define CMD_SEL_CHANNEL_2       (0x02 << 6)
#define CMD_SEL_READ_BACK       (0x03 << 6)

#define CMD_ACCESS_MODE_LATCH   (0x00 << 4)
#define CMD_ACCESS_MODE_LO      (0x01 << 4)
#define CMD_ACCESS_MODE_HI      (0x02 << 4)
#define CMD_ACCESS_MODE_LOHI    (0x03 << 4)

/* Interrupt on Terminal Count */
#define CMD_OP_MODE_0           (0x00 << 1)
/* Hardware Re-triggerable one-shot */
#define CMD_OP_MODE_1           (0x01 << 1)
/* Rate Generator */
#define CMD_OP_MODE_2           (0x02 << 1)
/* Square Wave Generator */
#define CMD_OP_MODE_3           (0x03 << 1)
/* Software triggered Strobe */
#define CMD_OP_MODE_4           (0x04 << 1)
/* Hardware triggered Strobe */
#define CMD_OP_MODE_5           (0x05 << 1)

#define CMD_BIN_MODE            (0x00 << 0)
#define CMD_BCD_MODE            (0x01 << 0)

/* PIT Data struct definition */
/* struct PIT_DATA
 *  {
 *       uint16_t PIT_reloadValue;       // 2 Byte
 *       uint32_t irq0Frequency;         // 4 Byte
 *       uint32_t irq0Milliseconds;      // 4 Byte
 *  };
 */
#define PIT_DATA_SIZE                   10
#define PIT_DATA_RELOAD_VALUE_OFF       0
#define PIT_DATA_IRQ0_FREQ_OFF          2
#define PIT_DATA_IRQ0_MS_OFF            6

