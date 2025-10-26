/*
 * Driver defines for low-level video driver
 *
 */
#ifndef _VIDEO_DEFINES_ASM_
#define _VIDEO_DEFINES_ASM_

.intel_syntax noprefix

/* Address of the Video Memory for Text-Display */
#define VIDEO_MEMORY                    0xB8000


/*
 * VGA Color Defines
 *
 */
#define COLOR_BLACK                   0x0
#define COLOR_BLUE                    0x1
#define COLOR_GREEN                   0x2
#define COLOR_CYAN                    0x3
#define COLOR_RED                     0x4
#define COLOR_MAGENTA                 0x5
#define COLOR_BROWN                   0x6
#define COLOR_LIGHTGRAY               0x7
#define COLOR_DARKGRAY                0x8
#define COLOR_LIGHTBLUE               0x9
#define COLOR_LIGHTGREEN              0xA
#define COLOR_LIGHTCYAN               0xB
#define COLOR_LIGHTRED                0xC
#define COLOR_LIGHTMAGENTA            0xD
#define COLOR_YELLOW                  0xE
#define COLOR_WHITE                   0xF

/*
 * Screen coordinates in VGA text mode 80x25
 *
 */
#define SCREEN_COL_COUNT              80
#define SCREEN_ROW_COUNT              25

#define SCREEN_ROW_TOP_LEFT           0
#define SCREEN_COL_TOP_LEFT           0
#define SCREEN_ROW_LOWER_RIGHT        SCREEN_ROW_COUNT - 1
#define SCREEN_COL_LOWER_RIGHT        SCREEN_COL_COUNT - 1


/*
 *
 * typedef struct _VIDEO_TEXTMODE_DRIVER {
 *      uint32_t videoMemoryBaseAdr;             // 4 Byte
 *      int32_t videoMemoryOffset;               // 4 Byte
 *      uint32_t videoMemoryAdr;                 // 4 Byte
 *
 *      uint8_t cursorCol;                       // 1 Byte
 *      uint8_t cursorRow;                       // 1 Byte
 *      uint16_ reserve1;                        // 2 Byte
 *
 * } VIDEO_TEXTMODE_DRIVER;
 *
 */

#define VIDEO_TEXTMODE_DRV_SIZE                      16
#define VIDEO_TEXTMODE_DRV_VIDMEM_BASEADR_OFFSET     0
#define VIDEO_TEXTMODE_DRV_VIDMEM_OFF_OFFSET         4
#define VIDEO_TEXTMODE_DRV_VIDMEM_ADR_OFFSET         8
#define VIDEO_TEXTMODE_DRV_CURSOR_COL_OFFSET         12
#define VIDEO_TEXTMODE_DRV_CURSOR_ROW_OFFSET         13
#define VIDEO_TEXTMODE_DRV_COLOR_FORGROUND_OFFSET    14
#define VIDEO_TEXTMODE_DRV_COLOR_BACKGROUND_OFFSET   15

#endif