"""
Assembler File

Authors:    Jason Chen, Kanad Panini Telang

Date Created:   11.29.23
Date Updated:   11.29.23
"""

def instr_to_asm(inst):
    asm = ""
    match inst[0]:
        case "li":
            asm = li(inst)
        case "simals" | "simahs" | "simsls" | "simshs" | "slmals" | "slmahs" | "slmsls" | "slmshs":
            asm = r4(inst)
        case "nop" | "shrhi" | "au" | "cnt1h" | "ahs" | "or" | "bcw" | "maxws" | "minws" | "mlhu" | "mlhss" | "and" | "invb" | "rotw" | "sfwu" | "sfhs":
            asm = r3(inst)
        case _:raise Exception("no no no, not today c:")
    return asm
#*******************************************************

#*******************************************************
#   Load Instruction
def li(ins):
    opcode = "0"
    index = int(ins[2])
    immediate = int(ins[3])
    rd = int(ins[1])

    if(index > 7 or index < 0): raise Exception("index out of range")
    if(immediate > 2**16 or immediate < 0): raise Exception("immediate out of range")
    if(rd > 31 or rd < 0): raise Exception("register not found")

    return opcode + format(index, '03b') + format(immediate, '016b') + format(rd, '05b')
#*******************************************************

#*******************************************************
#   R4 Instruction
def r4(inst):
    if(len(inst) != 5): raise Exception("instruction format error")

    opcode = "10"
    rd = int(inst[1])
    rs1 = int(inst[2])
    rs2 = int(inst[3])
    rs3 = int(inst[4])
    if(rd > 31 or rd < 0 or rs1 > 31 or rs1 < 0 or rs2 > 31 or rs2 < 0 or rs3 > 31 or rs3 < 0): raise Exception("register not found")

    match inst[0]:
        case "simals": opcode += "000"
        case "simsls": opcode += "001"
        case "simahs": opcode += "010"
        case "simshs": opcode += "011"
        case "slmals": opcode += "100"
        case "slmahs": opcode += "101"
        case "slmsls": opcode += "110"
        case "slmshs": opcode += "111"
        case _: raise Exception("no instruction named ", inst[0])

    return opcode + format(rs3, '05b') + format(rs2, '05b') + format(rs1, '05b') + format(rd, '05b')

#*******************************************************

#*******************************************************
#   R3 Instruction
def r3(inst):
    opcode = "11"

    op = inst[0]
    two = ["cnt1h", "bcw", "invb"]
    three = ["shrhi", "au", "ahs", "or", "maxws", "minws",
             "mlhu", "mlhss", "and", "rotw", "sfwu", "sfhs"]
    
    if((op == "nop" and len(inst) != 1) or (op in three and len(inst) != 4) or (op in two and len(inst) != 3)): raise Exception("instruction format error")
    
    match op:
        case "nop": return opcode + format(0, '023b')
        case "shrhi": opcode += "00000001"
        case "au": opcode += "00000010"
        case "cnt1h": opcode += "00000011"
        case "ahs": opcode += "00000100"
        case "or": opcode += "00000101"
        case "bcw": opcode += "00000110"
        case "maxws": opcode += "00000111"
        case "minws": opcode += "00001000"
        case "mlhu": opcode += "00001001"
        case "mlhss": opcode += "00001010"
        case "and": opcode += "00001011"
        case "invb": opcode += "00001100"
        case "rotw": opcode += "00001101"
        case "sfwu": opcode += "00001110"
        case "sfhs": opcode += "00001111"
        case _: raise Exception("instruction not found")

    if(op in three and len(inst) == 4):
        rs2 = int(inst[3])
        if(rs2 > 31 or rs2 < 0): raise Exception("register not found")
        opcode += format(rs2, '05b')
    else:
        opcode += format(0, '05b')

    rs1 = int(inst[2])
    rd = int(inst[1])
    if(rd > 31 or rd < 0 or rs1 > 31 or rs1 < 0): raise Exception("register not found")

    return opcode + format(rs1, '05b') + format(rd, '05b')

#*******************************************************

#*******************************************************
#   Main
filein = open("instructions.txt","r")
fileout = open("asmcode.txt", "w")
instr = []
asm = []

for line in filein:
    newline1 = line.replace("$", "")
    newline2 = newline1.replace(",", "")
    instr.append(newline2.split())

for i in instr:
    opcode = instr_to_asm(i)
    fileout.write(opcode + "\n")
    asm.append(opcode)

filein.close()
fileout.close()
print("Conversion Successful")