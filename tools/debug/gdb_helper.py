import struct
import gdb

CODE_SEGMENT_BASE = 0x7E00
DATA_SEGMENT_BASE = 0x7E00

def getPhysicalEIP():
    currentEIP = int(gdb.parse_and_eval("$eip"))
    physicalEIP = currentEIP + CODE_SEGMENT_BASE

    return physicalEIP


def getPhysicalESP():
    currentESP = int(gdb.parse_and_eval("$esp"))
    physicalESP = currentESP + DATA_SEGMENT_BASE

    return physicalESP

class GetEIP(gdb.Command):

    def __init__(self):
        super(GetEIP, self).__init__("getEIP", gdb.COMMAND_SUPPORT, gdb.COMPLETE_NONE, True)

    def invoke(self, argument, from_tty):
        if argument and argument == 'phy':
            eip = getPhysicalEIP()
            eipString = "EIP: 0x{0:x}\n".format(eip)
            gdb.write(eipString)

        return

class GetESP(gdb.Command):

    def __init__(self):
        super(GetESP, self).__init__("getESP", gdb.COMMAND_SUPPORT, gdb.COMPLETE_NONE, True)

    def invoke(self, argument, from_tty):
        if argument and argument == 'phy':
            esp = getPhysicalESP()
            espString = "ESP: 0x{0:x}\n".format(esp)
            gdb.write(espString)

        return


class DisassembleEIP(gdb.Command):
    def __init__(self):
        super(DisassembleEIP, self).__init__("eip_disas", gdb.COMMAND_SUPPORT, gdb.COMPLETE_NONE, True)

    def invoke(self, argument, from_tty):

        if argument and argument == 'phy':
            eip = getPhysicalEIP()

            cmdString = "disassemble {0},{1}".format(eip, eip+20)
            disassembly = gdb.execute(cmdString, False, True)

            gdb.write(disassembly)

        return


class DumpStack(gdb.Command):
    def __init__(self):
        super(DumpStack, self).__init__("dumpStack", gdb.COMMAND_SUPPORT, gdb.COMPLETE_NONE, True)

    def invoke(self, argument, from_tty):

        if argument and argument == 'phy':
            esp = getPhysicalESP()

            # Get the inferior.
            try:
                inferior = gdb.selected_inferior()
            except RuntimeError:
                return
            if not inferior or not inferior.is_valid():
                return

            startAddress = esp - 100
            endAddress = esp

            for adr in range(startAddress, endAddress, 4):
                m = inferior.read_memory(adr, 4)
                memVal = str(m.tobytes().hex())

                dataString = "0x{0:08x}: {1}\n".format(adr, memVal)
                gdb.write(dataString)

        return

GetEIP()
GetESP()
DisassembleEIP()
DumpStack()