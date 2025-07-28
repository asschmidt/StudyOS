# BIOS Data Area (BDA)
The following BDA table is copied from https://web.archive.org/web/20221127214951/https://www.bioscentral.com/misc/bda.htm

| Offset Hex  | Offset Dec | BIOS Service |	Field Size | Function                                                                       |
| ----------- | ---------- | ------------ | ---------- | ------------------------------------------------------------------------------ |
| 00h 	      | 0 	       | Int 14h      | 2 bytes    | Base I/O address for serial port 1 (communications port 1 - COM 1)             |
| 02h         | 2          | Int 14h      | 2 bytes    | Base I/O address for serial port 2 (communications port 2 - COM 2)             |
| 04h 	      | 4          | Int 14h      | 2 bytes    | Base I/O address for serial port 3 (communications port 3 - COM 3)             |
| 06h 	      | 6 	       | Int 14h      | 2 bytes    | Base I/O address for serial port 4 (communications port 4 - COM 4)             |
| 08h 	      | 8 	       | Int 17h      | 2 bytes    | Base I/O address for parallel port 1 (printer port 1 - LPT 1)                  |
| 0Ah 	      | 10 	       | Int 17h 	  | 2 bytes    | Base I/O address for parallel port 2 (printer port 2 - LPT 2)                  |
| 0Ch 	      | 12 	       | Int 17h 	  | 2 bytes    | Base I/O address for parallel port 3 (printer port 3 - LPT 3)                  |
| 0Eh 	      | 14 	       | POST 	      | 2 bytes    | Base I/O address for parallel port 4 (printer port 4 - LPT 4)                  |
| 10h 	      | 16 	       | Int 11h 	  | 2 bytes    | **Equipment Word**                                                             |
|             |            |              |            |    Bits 15-14 indicate the number of parallel ports installed                  |
|             |            |              |            |    00b = 1 parallel port                                                       |
|             |            |              |            |    01b = 2 parallel ports                                                      |
|             |            |              |            |    03b = 3 parallel ports                                                      |
|             |            |              |            |    Bits 13-12 are reserved                                                     |
|             |            |              |            |    Bits 11-9 indicate the number of serial ports installed                     |
|             |            |              |            |    000b = none                                                                 |
|             |            |              |            |    001b = 1 serial port                                                        |
|             |            |              |            |    002b = 2 serial ports                                                       |
|             |            |              |            |    003b = 3 serial ports                                                       |
|             |            |              |            |    004b = 4 serial ports                                                       |
|             |            |              |            |    Bit 8 is reserved                                                           |
|             |            |              |            |    Bit 7-6 indicate the number of floppy drives installed                      |
|             |            |              |            |    0b = 1 floppy drive                                                         |
|             |            |              |            |    1b = 2 floppy drives                                                        |
|             |            |              |            |    Bits 5-4 indicate the video mode                                            |
|             |            |              |            |    00b = EGA or later                                                          |
|             |            |              |            |    01b = color 40x25                                                           |
|             |            |              |            |    10b = color 80x25                                                           |
|             |            |              |            |    11b = monochrome 80x25                                                      |
|             |            |              |            |    Bit 3 is reserved                                                           |
|             |            |              |            |    Bit 2 indicates if a PS/2 mouse is installed                                |
|             |            |              |            |    0b = not installed                                                          |
|             |            |              |            |    1b = installed                                                              |
|             |            |              |            |    Bit 1 indicated if a math coprocessor is installed                          |
|             |            |              |            |    0b = not installedinstalled                                                 |
|             |            |              |            |    1b = installed                                                              |
|             |            |              |            |    Bit 0 indicated if a boot floppy is installed                               |
|             |            |              |            |    0b = not installed                                                          |
|             |            |              |            |   1b = installed                                                               |
| 12h 	      | 18         | POST 	      | 1 byte 	    | Interrupt flag - Manufacturing test                                           |
| 13h 	      | 19 	       | Int 12h 	  | 2 bytes     | Memory size in Kb                                                             |
| 15h 	      | 21 	       |              | 2 bytes     | Error codes for AT+; Adapter memory size for PC and XT                        |
| 17h         | 22         | Int 16h      | 1 byte      | Keyboard shift flags 1
                                                            Bit 7 indicates if Insert is on or off
                                                            0b = Insert off
                                                            1b = Insert on
                                                            Bit 6 indicates if CapsLock is on or off
                                                            0b = CapsLock off
                                                            1b - CapsLock on
                                                            Bit 5 indicates if NumLock is on or off
                                                            0b = NumLock off
                                                            1b = NumLock on
                                                            Bit 4 indicates if ScrollLock is on or off
                                                            0b = ScrollLock off
                                                            1b = ScrollLock on
                                                            Bit 3 indicates if the Alt key is up or down
                                                            0b = Alt key is up
                                                            1b = Alt key is down
                                                            Bit 2 indicates if the Control key is up or down
                                                            0b = Control key is up
                                                            1b = Control key is down
                                                            Bit 1 indicates if the Left Shift key is up or down
                                                            0b = Left Shift key is up
                                                            1b = Left Shift key is down
                                                            Bit 0 indicates if the Right Shift key is up or down
                                                            0b = Right Shift key is up
                                                            1b = Right Shift key is down                                                |
| 18h 	23 	Int 16h 	1 byte 	Keyboard shift flags 2
                        Bit 7 indicates if the Insert key is up or down
                        0b = Insert key is up
                        1b = Insert key is down
                        Bit 6 indicates if the CapsLock key is up or down
                        0b = CapsLock is key is up
                        1b = CapsLock key is down
                        Bit 5 indicates if the NumLock key is up or down
                        0b = NumLock key is up
                        1b = Numlock key is down
                        Bit 4 indicates if the ScrollLock key is up or down
                        0b = ScrollLock key is up
                        1b = ScrollLock key is down
                        Bit 3 indicates if the Pause key is active or inactive
                        0b = pause key is inactive
                        1b = Pause key is active
                        Bit 2 indicates if the SysReg key is up or down
                        0b = SysReg key is up
                        1b = SysReg key is down
                        Bit 1 indicates if the Left Alt key is up or down
                        0b = Left Alt key is up
                        1b = Left Alt key is down
                        Bit 0 indicates if the Right Alt key is up or down
                        0b = Right Alt key is up
                        1b = Right Alt key is down
| 19h 	24 	Int 09h 	1 byte 	Alt Numpad work area
| 1Ah 	26 	Int 16h 	2 bytes 	Pointer to the address of the next character in the keyboard buffer
| 1Ch 	28 	Int 16h 	2 bytes 	Pointer to the address of the last character in he keyboard buffer
| 1Eh 	60 	Int 16h 	32 bytes 	Keyboard buffer
| 3Eh 	61 	Int 13h 	1 byte 	Floppy disk drive calibration status
                        Bits 7-4 are reserved
                        Bit 3 = floppy drive 3 (PC, XT)
                        Bit 2 = floppy drive 2 (PC, XT)
                        Bit 1 = floppy drive 1
                        Bit 0 = floppy drive 0
                        0b indicates not calibrated
                        1b indicates calibrated
| 3Fh 	62 	Int 13h 	1 byte 	Floppy disk drive motor status
                        Bit 7 indicates current operation
                        0b = read or verify operation
                        1b = write or format operation
                        Bit 6 is not used
                        Bit 5-4 indicates drive select
                        00b = Drive 0
                        01b = Drive 1
                        10b = Drive 2 (PC, XT)
                        11b = Drive 4 (PC, XT)
                        Bit 3 indicates drive 3 motor
                        0b = motor off
                        1b = motor on
                        Bit 2 indicates drive 2 motor
                        0b = motor off
                        1b = motor on
                        Bit 1 indicates drive 0 motor
                        0b = motor off
                        1b = motor on
                        0b = motor off
                        1b = motor on
| 40h 	63 	Int 13h 	1 byte 	Floppy disk drive motor time-out
| 41h 	64 	Int 13h 	1 byte 	Floppy disk drive status
                        Bit 7 indicates drive ready status
                        0b = drive ready
                        1b = drive not ready (time out)
                        Bit 6 indicates seek status
                        0b = no seek error detected
                        1b = indicates a seek error was detected
                        Bit 5 indicates floppy disk controller test
                        0b = floppy disk controller passed
                        1b = floppy disk controller failed
                        Bit 4-0 error codes
                        00000b = no errors
                        00001b = illegal function requested
                        00010b = address mark not found
                        00011b = write protect error
                        00100b = sector not found
                        00110b = diskette change line active
                        01000b = DMA overrun
                        01001b = DMA boundary error
                        01100b = unknown media type
                        10000b = CRC error during read
| 42h 	65 	Int 13h 	1 byte 	Hard disk and floppy controller status register 0
                        Bit 7-6 indicate the interrupt code
                        00b = command completed normally
                        01b = command terminated abnormally
                        10b = abnormal termination, ready line on, or diskette changed
                        11b = seek command not completed
                        Bit 5 indicated seek command
                        0b = seek command not completed
                        1b = seek command completed
                        Bit 4 indicated drive fault
                        0b = no drive fault
                        1b = drive fault
                        Bit 3 indicates drive ready
                        0b = drive ready
                        1b = drive not ready
                        Bit 2 indicates head state when interrupt occurred
                        00b = drive 0
                        01b = drive 1
                        10b = drive 2 (PC, XT)
                        11b = drive 3 (PC, XT)
                        Bit 1-0 indicates drive select
                        00b = drive 0
                        01b = drive 1
                        10b = drive 2 (PC, XT)
                        11b = drive 3 (PC, XT)
| 43h 	66 	Int 13h 	1 byte 	Floppy drive controller status register 1
                        Bit 7-0 indicates no error
                        Bit 7, 1b = indicates attempted access beyond last cylinder
                        Bit 6, 0b = not used
                        Bit 5, 1b = CRC error during read
                        Bit 4, 1b = DMA overrun
                        Bit 3, 0b = not used
                        Bit 2, 1b = Sector not found or reading diskette ID failed
                        Bit 1, 1b = medium write protected
                        Bit 0, 1b = missing address mark
44h 	67 	Int 13h 	1 byte 	Floppy drive controller status register 2
                        Bit 7, 0b = not used
                        Bit 6, 1b = deleted data address mark
                        Bit 5, 1b = CRC error detected
                        Bit 4, 1b = wrong cylinder
                        Bit 3, 1b = condition of equal during verify
                        Bit 2, 1b = sector not found during verify
                        Bit 1, 1b = bad cylinder
                        Bit 0, 1b = address mark not found during read
45h 	68 	Int 13h 	1 byte 	Floppy disk controller: cylinder number
46h 	69 	Int 13h 	1 byte 	Floppy disk controller: head number
47h 	70 	Int 13h 	1 byte 	Floppy disk controller: sector number
48h 	71 	  	1 byte 	Floppy disk controller: number of byte written
49h 	72 	Int 10h 	1 byte 	Active video mode setting
4Ah 	74 	Int 10h 	2 bytes 	Number of textcolumns per row for the active video mode
4Ch 	76 	Int 10h 	2 bytes 	Size of active video in page bytes
4Eh 	78 	Int 10h 	2 bytes 	Offset address of the active video page relative to the start of video RAM
50h 	80 	Int 10h 	2 bytes 	Cursor position for video page 0
52h 	82 	Int 10h 	2 bytes 	Cursor position for video page 1
54h 	84 	Int 10h 	2 bytes 	Cursor position for video page 2
56h 	86 	Int 10h 	2 bytes 	Cursor position for video page 3
58h 	88 	Int 10h 	2 bytes 	Cursor position for video page 4
5Ah 	90 	Int 10h 	2 bytes 	Cursor position for video page 5
5Ch 	92 	Int 10h 	2 bytes 	Cursor position for video page 6
5Eh 	94 	Int 10h 	2 bytes 	Cursor position for video page 7
60h 	96 	Int 10h 	2 bytes 	Cursor shape
62h 	97 	Int 10h 	1 byte 	Active video page
63h 	99 	Int 10h 	2 bytes 	I/O port address for the video display adapter
65h 	100 	Int 10h 	1 byte 	Video display adapter internal mode register
                        Bit 7, 0b = not used
                        Bit 6, 0b = not used
                        Bit 5
                        0b = attribute bit controls background intensity
                        1b = attribute bit controls blinking
                        Bit 4, 1b = mode 6 graphics operation
                        Bit 3 indicates video signal
                        0b = video signal disabled
                        1b = video signal enabled
                        Bit 2 indicates color operation
                        0b = color operation
                        1b = monochrome operation
                        Bit 1, 1b = mode 4/5 graphics operation
                        Bit 0, 1b = mode 2/3 test operation
66h 	101 	Int 10h 	1 byte 	Color palette
                        Bit 7, 0b = not used
                        Bit 6, 0b = not used
                        Bit 5 indicates mode 5 foreground colors
                        0b = green/red/yellow
                        1b = cyan/magenta/white
                        Bit 4 indicates background color
                        0b = normal background color
                        1b = intensified background color
                        Bit 3 indicates intensified border color (mode 2) and background color (mode 5)
                        Bit 2 indicates red
                        Bit 1 indicates green
                        Bit 0 indicates blue
67h 	103 	  	2 bytes 	Adapter ROM offset address
69h 	106 	  	2 bytes 	Adapter ROM segment address
6Bh 	107 	  	1 byte 	Last interrupt (not PC)
                        Bit 7 indicates IRQ 7 hardware interrupt
                        0b = did not occur
                        01 = did occur
                        Bit 6 indicates IRQ 6 hardware interrupt
                        0b = did not occur
                        01 = did occur
                        Bit 5 indicates IRQ 5 hardware interrupt
                        0b = did not occur
                        01 = did occur
                        Bit 4 indicates IRQ 4 hardware interrupt
                        0b = did not occur
                        01 = did occur
                        Bit 3 indicates IRQ 3 hardware interrupt
                        0b = did not occur
                        01 = did occur
                        Bit 2 indicates IRQ 2 hardware interrupt
                        0b = did not occur
                        01 = did occur
                        Bit 1 indicates IRQ 1 hardware interrupt
                        0b = did not occur
                        01 = did occur
                        Bit 0 indicates IRQ 0 hardware interrupt
                        0b = did not occur
                        01 = did occur
6Ch 	111 	Int 1Ah 	4 bytes 	Counter for Interrupt 1Ah
70c 	112 	Int 1Ah 	1 byte 	Timer 24 hour flag
71h 	113 	Int 16h 	1 byte 	Keyboard Ctrl-Break flag
72h 	115 	POST 	2 bytes 	Soft reset flag
74h 	116 	Int 13h 	1 byte 	Status of last hard disk operation
                        00h = no errors
                        01h = invalid function requested
                        02h = address mark not found
                        04h = sector not found
                        05h = reset failed
                        06h = removable media changed
                        07h = drive parameter activity failed
                        08h = DMA overrun
                        09h = DMA boundary overrun
                        0Ah = bad sector flag detected
                        0Bh = bad track detected
                        0Dh = invalid number of sectors on format
                        0Eh = control data address mark detected
                        0Fh = DMA arbitration level out of range
                        10h = uncorrectable ECC or CRC error
                        11h = ECC corrected data error
                        20h = general controller failure
                        40h = seek operation failed
                        80h = timeout
                        AAh = drive not ready
                        BBh = undefined error occurred
                        CCh = write fault on selected drive
                        E0h = status error or error register is zero
                        FFh = sense operation failed
75h 	117 	Int 13h 	1 byte 	Number of hard disk drives
76h 	118 	Int 13h 	1 byte 	Hard disk control byte
                        Bit 7
                        0b = enables retries on disk error
                        1b = disables retries on disk error
                        Bit 6
                        0b = enables reties on disk error
                        1b = enables reties on disk error
                        Bit 5, 0b = not used
                        Bit 4, 0b = not used
                        Bit 3
                        0b = drive has less than 8 heads
                        1b = drive has more than 8 heads
                        Bit 2, 0b = not used
                        Bit 1, 0b = not used
                        Bit 0, 0b = not used
77h 	119 	Int 13h 	1 byte 	Offset address of hard disk I/O port (XT)
78h 	120 	Int 17h 	1 byte 	Parallel port 1 timeout
79h 	121 	Int 17h 	1 byte 	Parallel port 2 timeout
7Ah 	122 	Int 17h 	1 byte 	Parallel port 3 timeout
7Bh 	123 	  	1 byte 	Parallel port 4 timeout (PC, XT) support for virtual DMA services (VDS)
                        Bit 7, 0b = not used
                        Bit 6, 0b = not used
                        Bit 5 indicates virtual DMA services
                        0b = not supported
                        1b = supported
                        Bit 4, 0b = not used
                        Bit 3 indicates chaining on interrupt 4Bh
                        0b = not required
                        1b = required
                        Bit 2, 0b = not used
                        Bit 1, 0b = not used
                        Bit 0, 0b = not used
7Ch 	124 	Int 14h 	1 byte 	Serial port 1 timeout
7Dh 	125 	Int 14h 	1 byte 	Serial port 2 timeout
7Eh 	126 	Int 14h 	1 byte 	Serial port 3 timeout
7Fh 	127 	Int 14h 	1 byte 	Serial port 4 timeout
80h 	129 	Int 16h 	2 bytes 	Starting address of keyboard buffer
82h 	131 	Int 16h 	2 bytes 	Ending address of keyboard buffer
84h 	132 	Int 10h 	1 byte 	Number of video rows (minus 1)
85h 	134 	Int 10h 	2 bytes 	Number of scan lines per character
87h 	135 	Int 10h 	1 byte 	Video display adapter options
                        Bit 7 indicates bit 7 of the last video mode
                        0b = clear display buffer when setting mode
                        1b = do not clear the display buffer
                        Bit 6-4 indicates the amount of memory on the video display adapter
                        000b = 64Kb
                        001b = 128Kb
                        010b = 192Kb
                        011b = 256Kb
                        100b = 512Kb
                        110 = 1024Kb or more
                        Bit 3 indicates video subsystem
                        0b = not active
                        1b = active
                        Bit 2 is reserved
                        Bit 1 indicates monitor type
                        0b = color
                        1b = monochrome
                        Bit 0 indicates alphanumeric cursor emulation
                        0b = disabled
                        1b = enabled
88h 	136 	Int 10h 	1 byte 	Video display adapter switches
                        Bit 7 indicates state of feature connector line 1
                        Bit 6 indicates state of feature connector line 0
                        Bit 5-4 not used
                        Bit 3-0 indicate adapter type switch settings
                        0000b = MDA/color 40x25
                        0001b = MDA/color 80x25
                        0010b = MDA/high-resolution 80x25
                        0011b = MDA/high-resolution enhanced
                        0100b = CGA 40x25/monochrome
                        0101b = CGA 80x25/monochrome
                        0110b = color 40x25/MDA
                        0111b = color 80x25/MDA
                        1000b = high-resolution 80x25/MDA
                        1001b = high-resolution enhanced/MDA
                        1010b = monochrome/CGA 40x25
                        1011b = monochrome/CGA 80x25
89h 	137 	Int 10h 	1 byte 	VGA video flags 1
                        Bit 7 and 4 indicate scanline mode
                        00b = 350-line mode
                        01b = 400-line mode
                        10b = 200-line mode
                        Bit 6 indicates display switch
                        0b = disabled
                        1b = enabled
                        Bit 5 is reserved
                        Bit 3 indicates default palette loading
                        0b = disabled
                        1b= enabled
                        Bit 2 indicates monitor type
                        0b = color
                        1b = monochrome
                        Bit 1 indicates gray scale summing
                        0b = disabled
                        1b = enabled
                        Bit 0 indicates VGA active state
                        0b = VGA inactive
                        1b = VGA active
8Ah 	138 	Int 10h 	1 byte 	VGA video flags 2
8Bh 	139 	Int 13h 	1 byte 	Floppy disk configuration data
                        Bit 7-6 indicate last data sent to the controller
                        00b = 500 Kbit/sec/sec
                        01b = 300 Kbit/sec
                        10b = 250 Kbit/sec
                        11b = rate not set or 1 Mbit/sec
                        Bit 5-4 indicate last drive steprate sent to the controller
                        00b = 8ms
                        01b = 7ms
                        10b = 6ms
                        11b = 5ms
                        Bit 3-2 indicate data rate, set at start of operation (Bits 7-6)
                        Bit 1-0 not used
8Ch 	140 	Int 13h 	1 byte 	Hard disk drive controller status
                        Bit 7 indicates controller state
                        0b = controller not busy
                        1b = controller busy
                        Bit 6 indicates drive ready state
                        0b = drive selected not ready
                        1b = drive selected ready
                        Bit 5 indicates write fault
                        0b = write fault did not occur
                        1b = write error occurred
                        Bit 4 indicates seek state
                        0b = drive selected seeking
                        1b = drive selected seek complete
                        Bit 3 indicates data request
                        0b = data request is inactive
                        1b = data request is active
                        Bit 2 indicates data correction
                        0b = data not corrected
                        1b = data corrected
                        Bit 1 indicates index pulse state
                        0b = index pulse inactive
                        1b = index pulse active
                        Bit 0 indicates error
                        0b = no error
                        1b = error in previous command
8Dh 	141 	Int 13h 	1 byte 	Hard disk drive error
                        Bit 7 indicates bad sector
                        0b = not used
                        1b = bad sector detected
                        Bit 6 indicated ECC error
                        0b = not used
                        1b = uncorrectable ECC error occurred
                        Bit 5 indicates media state
                        0b = not used
                        1b = media changed
                        Bit 4 indicates sector state
                        0b = not used
                        1b = ID or target sector not found
                        Bit 3 indicates media change request state
                        0b = not used
                        1b = media change requested
                        Bit 2 indicates command state
                        0b = not used
                        1b = command aborted
                        Bit 1 indicates drive track error
                        0b = not used
                        1b = track 0 not found
                        Bit 0 indicates address mark
                        0b = not used
                        1b = address mark not found
8Eh 	142 	Int 13h 	1 byte 	Hard disk drive task complete flag
8Fh 	143 	Int 13h 	1 byte 	Floppy disk drive information
                        Bit 7 not used
                        Bit 6 indicates drive 1 type determination
                        0b = not determined
                        1b = determined
                        Bit 5 indicates drive 1 multirate status
                        0b = no
                        1b = yes
                        Bit 4 indicates diskette 1 change line detection
                        0b = no
                        1b = yes
                        Bit 3 not used
                        Bit 2 indicates drive 0 type determination
                        0b = not determined
                        1b = determined
                        Bit 1 indicates drive 0 multirate status
                        0b = no
                        1b = yes
                        Bit 0 indicates diskette 0 change line detection
                        0b = no
                        1b = yes
90h 	144 	Int 13h 	1 byte 	Diskette 0 media state
                        Bit 7-6 indicate transfer rate
                        00b = 500 Kbit/sec
                        01b = 300 Kbit/sec
                        10b = 250 Kbit/sec
                        11b = 1 Mbit/sec
                        Bit 5 indicates double stepping
                        0b = not required
                        1b = required
                        Bit 4 indicates media in floppy drive
                        0b = unknown media
                        1b = known media
                        Bit 3 not used
                        Bit 2-0 indicates last access
                        000b = trying 360k media in 360K drive
                        001b = trying 360K media in 1.2M drive
                        010b = trying 1.2M media in 1.2M drive
                        011b = known 360K media on 360K drive
                        100b = known 360K media in 1.2M drive
                        101b = known 1.2M media in 1.2M drive
                        110b = not used
                        111b = 720K media in 720K drive or 1.44M media in 1.44M drive
91h 	145 	Int 13h 	1 byte 	Diskette 1 media state
                        Bit 7-6 indicate transfer rate
                        00b = 500 Kbit/sec
                        01b = 300 Kbit/sec
                        10b = 250 Kbit/sec
                        11b = 1 Mbit/sec
                        Bit 5 indicates double stepping
                        0b = not required
                        1b = required
                        Bit 4 indicates media in floppy drive
                        0b = unknown media
                        1b = known media
                        Bit 3 not used
                        Bit 2-0 indicates last access
                        000b = trying 360k media in 360K drive
                        001b = trying 360K media in 1.2M drive
                        010b = trying 1.2M media in 1.2M drive
                        011b = known 360K media on 360K drive
                        100b = known 360K media in 1.2M drive
                        101b = known 1.2M media in 1.2M drive
                        110b = not used
                        111b = 720K media in 720K drive or 1.44M media in 1.44M drive
92h 	146 	Int 13h 	1 byte 	Diskette 0 operational starting state
                        Bit 7 indicates data transfer rate
                        00b = 500 Kbit/sec
                        01b = 300 Kbit/sec
                        10b = 250 Kbit/sec
                        11b = 1 Mbit/sec
                        Bits 5-3 not used
                        Bit 2 indicates drive determination
                        0b = drive type not determined
                        1b = drive type determined
                        Bit 1 indicates drive multirate status
                        0b = drive is not multirate
                        1b = drive is multirate
                        Bit 0 indicates change line detection
                        0b = no change line detection
                        1b = change line detection
93h 	147 	Int 13h 	1 byte 	Diskette 1 operational starting status
                        Bit 7 indicates data transfer rate
                        00b = 500 Kbit/sec
                        01b = 300 Kbit/sec
                        10b = 250 Kbit/sec
                        11b = 1 Mbit/sec
                        Bits 5-3 not used
                        Bit 2 indicates drive determination
                        0b = drive type not determined
                        1b = drive type determined
                        Bit 1 indicates drive multirate status
                        0b = drive is not multirate
                        1b = drive is multirate
                        Bit 0 indicates change line detection
                        0b = no change line detection
                        1b = change line detection
94h 	148 	Int 13h 	1 byte 	Diskette 0 current cylinder
95h 	149 	Int 13h 	1 byte 	Diskette 1 current cylinder
96h 	150 	Int 16h 	1 byte 	Keyboard status flags 3
                        Bit 7, 1b = reading two byte keyboard ID in progress
                        Bit 6, 1b = last code was first ID character
                        Bit 5, 1b = forced Numlock on
                        Bit 4 indicates presence of 101/102 key keyboard
                        0b = present
                        1b = not present
                        Bit 3 indicates right alt key active
                        0b = not active
                        1b = active
                        Bit 2 indicates right control key active
                        0b = not active
                        1b = active
                        Bit 1, 1b = last scancode was E0h
                        Bit 0, 1b = last scancode was E1h
97h 	151 	Int 16h 	1 byte 	Keyboard status flags 4
                        Bit 7, 1b = keyboard transmit error
                        Bit 6, 1b = LED update in progress
                        Bit 5, 1b = re-send code received
                        Bit 4, 1b = acknowledge code received
                        Bit 3, 1b = reserved
                        Bit 2 indicates CapsLock LED state
                        0b = CapsLock LED off
                        1b = CapsLock LED on
                        Bit 1 indicates NumLock LED state
                        0b = NumLock LED off
                        1b = NumLock LED on
                        Bit 0 indicates ScrollLock LED state
                        0b = ScrollLock LED off
                        1b = ScrollLock LED on
98h 	155 	  	4 bytes 	Segment:Offset address of user wait flag pointer
9Ch 	159 	  	4 bytes 	User wait count
A0h 	160 	  	1 byte 	User wait flag
                        Bit 7, 1b = wait time has elapsed
                        Bit 6-1 not used
                        Bit 0 indicates wait progress
                        0b = no wait in progress
                        1b = wait in progress
A1h 	167 	  	7 bytes 	Local area network (LAN) bytes
A8h 	171 	  	4 bytes 	Segment:Offset address of video parameter control block
ACh 	239 	  	68 bytes 	Reserved
F0h 	255 	  	16 bytes 	Intra-applications communications area