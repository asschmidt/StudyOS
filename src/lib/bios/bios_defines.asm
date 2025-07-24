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
.set DISK_INFO_STRUCT_SIZE,         4
.set DISK_INFO_CYLINDER_OFFSET,     0
.set DISK_INFO_SECTORS_OFFSET,      2
.set DISK_INFO_HEADS_OFFSET,        3

/*
 * BIOS Color Defines
 *
 */
.set COLOR_BLACK,                   0x0
.set COLOR_BLUE,                    0x1
.set COLOR_GREEN,                   0x2
.set COLOR_CYAN,                    0x3
.set COLOR_RED,                     0x4
.set COLOR_MAGENTA,                 0x5
.set COLOR_BROWN,                   0x6
.set COLOR_LIGHTGRAY,               0x7
.set COLOR_DARKGRAY,                0x8
.set COLOR_LIGHTBLUE,               0x9
.set COLOR_LIGHTGREEN,              0xA
.set COLOR_LIGHTCYAN,               0xB
.set COLOR_LIGHTRED,                0xC
.set COLOR_LIGHTMAGENTA,            0xD
.set COLOR_YELLOW,                  0xE
.set COLOR_WHITE,                   0xF

/*
 * Screen coordinates in text mode 80x25
 *
 */
.set SCREEN_ROW_TOP_LEFT,           0
.set SCREEN_COL_TOP_LEFT,           0
.set SCREEN_ROW_LOWER_RIGHT,        24
.set SCREEN_COL_LOWER_RIGHT,        79

