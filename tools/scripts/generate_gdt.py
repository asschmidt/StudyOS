import ctypes
c_uint8 = ctypes.c_uint8

class GDTFlags_bits(ctypes.BigEndianStructure):
    _fields_ = [
            ("Unused", c_uint8, 4),
            ("G", c_uint8, 1),
            ("DB", c_uint8, 1),
            ("L", c_uint8, 1),
            ("Reserved", c_uint8, 1),
        ]

class GDTFlags(ctypes.Union):
    _fields_ = [("b", GDTFlags_bits),
                ("asbyte", c_uint8)]



class GDTAccessByte_bits(ctypes.BigEndianStructure):
    _fields_ = [
            ("P", c_uint8, 1),
            ("DPL", c_uint8, 2),
            ("S", c_uint8, 1),
            ("E", c_uint8, 1),
            ("DC", c_uint8, 1),
            ("RW", c_uint8, 1),
            ("A", c_uint8, 1),
        ]


class GDTAccessByte(ctypes.Union):
    _fields_ = [("b", GDTAccessByte_bits),
                ("asbyte", c_uint8)]

class GDTEntry:
    def __init__(self):
        self.Base = 0x00
        self.Limit = 0x00
        self.AccessByte = GDTAccessByte()
        self.Flags = GDTFlags()

        self.DW0 = 0x00     # Bits 0..15   - Limit 0..15
        self.DW1 = 0x00     # Bits 16..31  - Base 0..15
        self.DW2 = 0x00     # Bits 32..47  - Base 16..23, Access Byte 0..7
        self.DW3 = 0x00     # Bits 48..63  - Limit 16..19, Flags 0..3, Base 24..31

    def encode(self):
        self.DW0 = self.Limit & 0x0000FFFF
        self.DW1 = self.Base  & 0x0000FFFF
        self.DW2 = (self.Base & 0x00FF0000 >> 16 ) | (self.AccessByte.asbyte << 8)
        self.DW3 = (self.Limit & 0x000F0000 >> 16) | ((self.Flags.asbyte & 0x0F) << 4) | ((self.Base & 0xFF000000 >> 24) << 8)



code_entry = GDTEntry()
code_entry.Base = 0x00007E00
code_entry.Limit = 0xFFFFF
code_entry.AccessByte.b.P = 1
code_entry.AccessByte.b.DPL = 0
code_entry.AccessByte.b.S = 1
code_entry.AccessByte.b.E = 1
code_entry.AccessByte.b.DC = 0
code_entry.AccessByte.b.RW = 1
code_entry.AccessByte.b.A = 0

code_entry.Flags.b.G = 1
code_entry.Flags.b.DB = 1
code_entry.Flags.b.L = 0
code_entry.Flags.b.Reserved = 0

code_entry.encode()

#print("AccessByte: 0x{:02x}".format(code_entry.AccessByte.asbyte))
#print("Flags:      0x{:02x}".format(code_entry.Flags.asbyte))

print("gdt_code:")
print(".word 0x{:04x}".format(code_entry.DW0))
print(".word 0x{:04x}".format(code_entry.DW1))
print(".word 0x{:04x}".format(code_entry.DW2))
print(".word 0x{:04x}".format(code_entry.DW3))


data_entry = GDTEntry()
data_entry.Base = 0x00007E00
data_entry.Limit = 0xFFFFF
data_entry.AccessByte.b.P = 1
data_entry.AccessByte.b.DPL = 0
data_entry.AccessByte.b.S = 1
data_entry.AccessByte.b.E = 0
data_entry.AccessByte.b.DC = 0
data_entry.AccessByte.b.RW = 1
data_entry.AccessByte.b.A = 0

data_entry.Flags.b.G = 1
data_entry.Flags.b.DB = 1
data_entry.Flags.b.L = 0
data_entry.Flags.b.Reserved = 0

data_entry.encode()

#print("AccessByte: 0x{:02x}".format(data_entry.AccessByte.asbyte))
#print("Flags:      0x{:02x}".format(data_entry.Flags.asbyte))

print("gdt_data:")
print(".word 0x{:04x}".format(data_entry.DW0))
print(".word 0x{:04x}".format(data_entry.DW1))
print(".word 0x{:04x}".format(data_entry.DW2))
print(".word 0x{:04x}".format(data_entry.DW3))