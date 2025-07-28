//
// StudyOS - Playground OS for x86, assembly and OS topics
//
// Author: Andreas Schmidt (a.v.schmidt81@googlemail.com)
//
// ImHex Pattern File for BDA Memory Dump
//
// This file expects the following partition layout
//   HexDump in Bin Format from Address 0x400 with 255 Bytes

#pragma once
#pragma author Andreas Schmidt
#pragma description MBR

import hex.core;
import std.io;
import type.guid;

enum INSTALLED : u8
{
    NOT_INSTALLED = 0x00,
    INSTALLED     = 0x01
};

enum VIDEO_MODE : u8
{
    EGA                 = 0x00,
    COLOR_40_25         = 0x01,
    COLOR_80_25         = 0x02,
    MONOCHROME_80_25    = 0x03
};

bitfield EQUIPMENT_WORD
{
    unsigned parallelPorts    : 2;
    res1                      : 2;
    unsigned serialPorts      : 3;
    res2                      : 1;
    unsigned floppyDrives     : 2;
    VIDEO_MODE videoMode      : 2;
    res3                      : 1;
    INSTALLED ps2Mouse        : 1;
    INSTALLED mathCo          : 1;
    INSTALLED bootFloppy      : 1;
};

struct BDA
{
    u16 baseAdrCOM1;
    u16 baseAdrCOM2;
    u16 baseAdrCOM3;
    u16 baseAdrCOM4;

    u16 baseAdrLPT1;
    u16 baseAdrLPT2;
    u16 baseAdrLPT3;
    u16 baseAdrLPT4;

    EQUIPMENT_WORD equipmentWord;

    u8 interruptFlag;
    u16 memSize;
    u16 errorCodeATPlus;
    u8 shiftFlags1;
    u8 shiftFlags2;
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