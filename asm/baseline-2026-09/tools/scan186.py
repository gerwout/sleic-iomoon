#!/usr/bin/env python3
"""Decode 80188 code regions with capstone (16-bit mode, which covers 186
instructions) and report any 186-only instructions the firmware uses.

Usage:
    python3 scan186.py <romfile> <hex-base-offset> <hex-size>

<hex-base-offset>/<hex-size> select the file window to scan; printed
addresses are in file-offset numbering (see note below).

Note on capstone address semantics: md.disasm(data[base:base+size], base)
does NOT mean insn.address starts at `base`+0 -- capstone uses the second
argument as the *address of the first decoded byte*, so insn.address values
already come out as base, base+1, ... in the *file-offset* numbering. This
matches the brief's original snippet.
"""
import sys, capstone

ONLY186 = {"pusha", "popa", "pushaw", "popaw", "bound", "enter", "leave",
           "insb", "insw", "outsb", "outsw"}
# Note: capstone 5.0.7's 16-bit-mode mnemonics are actually "pushaw"/"popaw"
# (not the brief's "pusha"/"popa" -- verified against a synthetic 0x60/0x61
# test); both spellings are kept here so the scanner is not silently blind
# to PUSHA/POPA on a capstone build/version that uses the other spelling.
# push imm (6A/68), imul r,r/m,imm (6B/69), and C0/C1 shift/rotate-by-imm8
# group are 186-only *encodings* of otherwise-186-and-earlier mnemonics
# (push, imul, shl/shr/sar/rol/ror/rcl/rcr), so they must be recognised by
# opcode byte, not by mnemonic.
ONLY186_FIRST_BYTE = (0x6A, 0x68, 0x6B, 0x69, 0xC0, 0xC1)

md = capstone.Cs(capstone.CS_ARCH_X86, capstone.CS_MODE_16)
# IMPORTANT: capstone's disasm() generator stops dead at the first byte
# sequence it cannot decode as a valid instruction, and does NOT resync
# by skipping a byte and retrying -- verified: without skipdata the brief's
# original snippet decoded only 26 instructions (44 bytes) of a 0x30000-byte
# region before silently truncating, making its "TOTAL 0" meaningless (it
# never scanned 99.9% of the window). skipdata makes capstone emit a
# 1-byte ".byte 0xXX" pseudo-insn for anything undecodable and keep going,
# which is required to cover the whole requested window.
md.skipdata = True
data = open(sys.argv[1], "rb").read()
base = int(sys.argv[2], 16)          # file offset of region start
size = int(sys.argv[3], 16)

hits = []
for insn in md.disasm(data[base:base + size], base):
    # A single instruction can only match ONE of these two conditions in
    # practice (no ONLY186 mnemonic's encoding starts with a byte in
    # ONLY186_FIRST_BYTE), but use elif anyway so a hit is never appended
    # twice regardless of mnemonic/opcode overlap.
    if insn.mnemonic in ONLY186:
        hits.append((insn.address, insn.mnemonic, insn.op_str, insn.bytes.hex()))
    elif insn.bytes[0] in ONLY186_FIRST_BYTE:
        hits.append((insn.address, insn.mnemonic, insn.op_str, insn.bytes.hex()))

for a, m, o, b in hits:
    print("%06X: %-6s %-20s ; bytes=%s" % (a, m, o, b))
print("TOTAL", len(hits))
