/*
 * Common defines for BIOS information and data structures
 *
 */
#ifndef _BIOS_DEFINES_ASM_
#define _BIOS_DEFINES_ASM_

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

/*
 * BIOS Color Defines
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
 * Screen coordinates in text mode 80x25
 *
 */
#define SCREEN_ROW_TOP_LEFT           0
#define SCREEN_COL_TOP_LEFT           0
#define SCREEN_ROW_LOWER_RIGHT        24
#define SCREEN_COL_LOWER_RIGHT        79

#endif
