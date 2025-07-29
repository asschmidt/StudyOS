//
// StudyOS - Playground OS for x86, assembly and OS topics
//
// Author: Andreas Schmidt (a.v.schmidt81@googlemail.com)
//
// ImHex Pattern File for BDA Memory Dump
//
// This file expects the following fiel format
//   HexDump in Bin Format from Address 0x400 with 256 Bytes

#pragma once
#pragma author Andreas Schmidt
#pragma description MBR

import hex.core;
import std.io;
import type.guid;

//
// Enumeration to indicate Installed/Not Installed Flags
//
enum INSTALLED : u8
{
    NOT_INSTALLED       = 0x00,         // Equipment is not installed
    INSTALLED           = 0x01          // Equipment is installed
};

enum ON_OFF_FLAG : u8
{
    OFF                 = 0x00,         // Keyboard indicator is OFF
    ON                  = 0x01          // Keyboard indicator is ON
};

enum KEY_PRESS_FLAG : u8
{
    NOT_PRESSED         = 0x00,         // Key is not pressed
    PRESSED             = 0x01          // Key is pressed
};

// 
// Enumeration for possible Video Modes in BDA
enum VIDEO_MODE : u8
{
    EGA                 = 0x00,         // EGA or better
    COLOR_40_25         = 0x01,         // Color with 40x25
    COLOR_80_25         = 0x02,         // Color with 80x25
    MONOCHROME_80_25    = 0x03          // Monochrome Display with 80x25
};

enum NUM_LPT_PORTS : u8
{
    NO_LPT_PORT         = 0x00,         // No installed LPT Port
    ONE_LPT_PORT        = 0x01,         // 1 installed LPT Port
    TWO_LPT_PORTS       = 0x02,         // 2 installed LPT Ports
    THREE_LPT_PORTS     = 0x03          // 3 installed LPT Ports
};

enum NUM_COM_PORTS : u8
{
    NO_COM_PORT         = 0x00,         // No COM Port installed
    ONE_COM_PORT        = 0x01,         // 1 COM Port installed
    TWO_COM_PORTS       = 0x02,         // 2 COM Ports installed
    THREE_COM_PORTS     = 0x03,         // 3 COM Ports installed
    FOUR_COM_PORTS      = 0x04          // 4 COM Ports installed
};

enum NUM_FLOPPY_DRIVES : u8
{
    ONE_FLOPPY_DRIVE    = 0x00,         // 1 Floppy Drive installed
    TWO_FLOPPY_DRIVES   = 0x01,         // 2 Floppy Drives installed
    THREE_FLOPPY_DRIVES = 0x02,         // 3 Floppy Drives installed
    FOUR_FLOPPY_DRIVES  = 0x03          // 4 Floppy Drives installed
};

//
// Bitfield to decode the Equipment Word of PDA
//
bitfield EQUIPMENT_WORD
{
    NUM_LPT_PORTS parallelPorts     : 2;      // Number of installed Parallel-Ports
    res1                            : 2;      // Reserved Bits
    NUM_COM_PORTS serialPorts       : 3;      // Number of installed Serial Ports
    res2                            : 1;      // Reserved Bit
    NUM_FLOPPY_DRIVES floppyDrives  : 2;      // Number of installed Floppy Drives
    VIDEO_MODE videoMode            : 2;      // Best supported Video Mode
    res3                            : 1;      // Reserved Bit
    INSTALLED ps2Mouse              : 1;      // Flag to indicate installed PS/2 Mouse
    INSTALLED mathCo                : 1;      // Flag to indicate installed Math Co-Processor
    INSTALLED bootFloppy            : 1;      // Flag to indicate installed Boot Floppy
};

bitfield KEYBOARD_SHIFT_FLAGS1
{
    ON_OFF_FLAG insertOnOff         : 1;      // Indicates whether Insert Key is on/off
    ON_OFF_FLAG capsLockOnOff       : 1;      // Indicates wheter Caps Lock is on/off
    ON_OFF_FLAG numLockOnOff        : 1;      // Indicates whether NumLock is on/off
    ON_OFF_FLAG scrollLockOnOff     : 1;      // Indicates whether ScrollLock is on/off
    KEY_PRESS_FLAG altKeyPressed    : 1;      // Indicates whether Alt Key is pressed
    KEY_PRESS_FLAG ctrlKeyPressed   : 1;      // Indicates whether Ctrl Key is pressed
    KEY_PRESS_FLAG leftShiftPressed : 1;      // Indicates whether Left Shift Key is pressed
    KEY_PRESS_FLAG rightShiftPressed: 1;      // Indicates whether Right Shift Key is pressed
};

bitfield KEYBOARD_SHIFT_FLAGS2
{
    KEY_PRESS_FLAG insertPressed    : 1;      // Indicates whether Insert Key is pressed
    KEY_PRESS_FLAG capsLockPressed  : 1;      // Indicates wheter Caps Lock is pressed
    KEY_PRESS_FLAG numLockPressed   : 1;      // Indicates whether NumLock is pressed
    KEY_PRESS_FLAG scrollLockPressed: 1;      // Indicates whether ScrollLock is pressed
    KEY_PRESS_FLAG pausePressed     : 1;      // Indicates whether Pause Key is pressed
    KEY_PRESS_FLAG sysRegPressed    : 1;      // Indicates whether SysReg Key is pressed
    KEY_PRESS_FLAG leftAltPressed   : 1;      // Indicates whether Left Alt Key is pressed
    KEY_PRESS_FLAG rightAltPressed  : 1;      // Indicates whether Right Alt Key is pressed
};

//
// Structure of the BDA
//
struct BDA
{
    u16 baseAdrCOM1;                    // I/O Base Address for COM Port 1
    u16 baseAdrCOM2;                    // I/O Base Address for COM Port 2
    u16 baseAdrCOM3;                    // I/O Base Address for COM Port 3
    u16 baseAdrCOM4;                    // I/O Base Address for COM Port 4

    u16 baseAdrLPT1;                    // I/O Base Address for LPT Port 1
    u16 baseAdrLPT2;                    // I/O Base Address for LPT Port 2
    u16 baseAdrLPT3;                    // I/O Base Address for LPT Port 3
    u16 baseAdrLPT4;                    // I/O Base Address for LPT Port 4

    EQUIPMENT_WORD equipmentWord;       // Bit-coded Equipment Word with detected HW

    u8 interruptFlag;                   // Interrupt flag - Manufacturing test  
    u16 memSize;                        // Memory Size in KiB
    u16 errorCodeATPlus;                // Error codes for AT+; Adapter memory size for PC and XT 

    KEYBOARD_SHIFT_FLAGS1 shiftFlags1;  // Keyboard flags about Lock Keys and Alt/Ctrl/Shift pressed
    KEYBOARD_SHIFT_FLAGS2 shiftFlags2;  // Keyboard flags about special keys pressed
    u8 altNumPad;

    u16 ptrNextCharKeyboardBuf;
    u16 ptrLastCharKeyboardBuf;
    u8 keyboardBuffer[32];

    u8 floppyCalibrationStatus;
    u8 floppyMotorStatus;
    u8 floppyMotorTimeout;
    u8 floppyDiskDriveStatus;

    u8 hdfdStatusRegister0;
    u8 hdfdStatusRegister1;
    u8 hdfdStatusRegister2;

    u8 floppyCylinderNo;
    u8 floppyHeadNo;
    u8 floppySecNo;
    u8 floppyBytesWritten;
    
    u8 activeVideoMode;
    u16 numTextColsPerRow;
    u16 videoPageSize;
    u16 offsetActiveVideoPage;
    
    u16 curserPosPage0;
    u16 curserPosPage1;
    u16 curserPosPage2;
    u16 curserPosPage3;
    u16 curserPosPage4;
    u16 curserPosPage5;
    u16 curserPosPage6;
    u16 curserPosPage7;
    u16 cursorShape;
    
    u8 activeVideoPage;
    u16 ioAdrVideoAdapter;
    u8 videoInternalModeReg;
    u8 colorPalette;
    u16 adapterROMOffset;
    u16 adapterROMSegment;
    
    u8 lastInterrupt;
    u32 counterInt1Ah;
    u8 timer24HourFlag;
    
    u8 keyboardCtrlBreakFlag;
    u16 softResetFlag;

    u8 statusHardDiskOp;
    u8 numHDD;
    u8 hddControlByte;
    u8 ioAdrOffsetHDD;
    
    u8 timeoutLPT1;
    u8 timeoutLPT2;
    u8 timeoutLPT3;
    u8 timeoutLPT4;
    
    u8 timeoutCOM1;
    u8 timeoutCOM2;
    u8 timeoutCOM3;
    u8 timeoutCOM4;
    
    u16 startAdrKeyboardBuf;
    u16 endAdrKeyboardBuf;
    
    u8 numVideoRows;
    
    u16 numScanlinePerChar;
    u8 videoAdapterOptions;
    u8 videoAdapterSwitches;
    
    u8 vgaFlags1;
    u8 vgaFlags2;
    
    u8 floppyDiskConfigData;
    
    u8 hddControllerStatus;
    u8 hddDriveError;
    u8 hddTaskCompleteFlag;
    
    u8 floppyDriveInfo;
    
    u8 mediaStateDisk0;
    u8 mediaStateDisk1;
    
    u8 opStateDisk0;
    u8 opStateDisk1;
    
    u8 currentCylinderDisk0;
    u8 currentCylinderDisk1;
    
    u8 keyboardFlags3;
    u8 keyboardFlags4;
    
    u32 segmentOffsetUserWaitPointer;
    
    u32 userWaitCount;
    u8 userWaitFlag;
    
    u8 lanBytes[7];
    
    u32 segmentOffsetVideoControlBlock;
    
    u8 res[68];
    
    u8 intraAppArea[16];
};


BDA biosDataArea @ 0x00;