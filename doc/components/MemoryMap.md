# Memory Map


| Start Address | End Address | Size      | Description                              | Remark                             |
| --------------| ----------- | --------- | ---------------------------------------- | ---------------------------------- |
| 0x00000000    | 0x000003FF  | 1 KiB     | Real Mode IVT (Interrupt Vector Table)   | Unusable in Real Mode              |
| 0x00000400    | 0x000004FF  | 256 Byte  | BDA (BIOS data area)                     | Unusable in Real Mode              |
| 0x00000500    | 0x00007BFF  | 29,75 KiB | Conventional memory                      | Usable Memory                      |
| 0x00007C00    | 0x00007DFF  | 512 Byte  | Boot Sector                              | Usable Memory                      |
| 0x00007E00    | 0x0007FFFF  | 480,5 KiB | Conventional memory                      | Usable Memory                      |
| 0x00080000    | 0x0009FFFF  | 1287 KiB  | EBDA (Extended BIOS Data Area)           | Partially used by the EBDA         |
| 0x000A0000    | 0x000BFFFF  | 128 KiB   | Video display memory (Hardware mapped)   |                                    |
| 0x000C0000    | 0x000C7FFF  | 32 KiB    | Video BIOS                               | ROM and Hardware Mapped/Shadow RAM |
| 0x000C8000    | 0x000EFFFF  | 160 KiB   | BIOS Expansions                          | ROM and Hardware Mapped/Shadow RAM |
| 0x000F0000    | 0x000FFFFF  | 64 KiB    | Motherboard BIOS                         | ROM and Hardware Mapped/Shadow RAM |