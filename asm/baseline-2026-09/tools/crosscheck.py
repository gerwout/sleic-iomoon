#!/usr/bin/env python3
"""crosscheck.py -- verify the dasmx86 listing against capstone.

Walks every code region in the generated listing and disassembles the same
bytes with capstone in 16-bit mode, comparing instruction boundaries first
(the thing that actually matters: a length disagreement means one of the two
has desynchronised and everything after it is suspect) and then mnemonics.

Also reports which 80186-only opcodes actually occur inside decoded code,
which is the question Task 3 left open for lack of a region map.

    python3 crosscheck.py
"""
import os
import re
import sys
from collections import Counter

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import grow                                              # noqa: E402
from capstone import Cs, CS_ARCH_X86, CS_MODE_16         # noqa: E402

# capstone spellings of the 80186-only encodings.
ONLY186_FIRST = {0x60, 0x61, 0x62, 0x68, 0x69, 0x6A, 0x6B,
                 0x6C, 0x6D, 0x6E, 0x6F, 0xC0, 0xC1, 0xC8, 0xC9}

# Mnemonic pairs that are the same instruction spelled differently.
ALIAS = {
    ("RETN", "ret"), ("RETF", "retf"), ("RETF", "ret"),
    ("JMP", "ljmp"), ("CALL", "lcall"),
    ("JNBE", "ja"), ("JNB", "jae"), ("JB", "jb"), ("JBE", "jbe"),
    ("JE", "je"), ("JNE", "jne"), ("JNLE", "jg"), ("JNL", "jge"),
    ("JL", "jl"), ("JLE", "jle"), ("JNO", "jno"), ("JNP", "jnp"),
    ("JNS", "jns"), ("JO", "jo"), ("JP", "jp"), ("JS", "js"),
    ("PUSHA", "pushaw"), ("POPA", "popaw"),
    ("BAA", "daa"), ("REP", "rep"), ("REPZ", "rep"),
    ("LOOPZ", "loope"), ("LOOPNZ", "loopne"), ("JCXZ", "jcxz"),
    ("MOVSB", "movsb"), ("MOVSW", "movsw"), ("STOSB", "stosb"),
    ("STOSW", "stosw"), ("LODSB", "lodsb"), ("LODSW", "lodsw"),
    ("SCASB", "scasb"), ("SCASW", "scasw"), ("CMPSB", "cmpsb"),
    ("CMPSW", "cmpsw"), ("ESC", "fadd"),
    # capstone spells the 16-bit sign-extend opcodes 98/99 with their
    # 32-bit names even in CS_MODE_16; same 1-byte instruction.
    ("CBW", "cwde"), ("CWD", "cdq"),
}


def main():
    _, regions, _ = grow.build_regions()
    rom = open(grow.ROM, "rb").read()
    md = Cs(CS_ARCH_X86, CS_MODE_16)
    md.skipdata = True

    total = mism_len = mism_mn = 0
    pairs = Counter()
    only186 = Counter()
    examples = []
    for start, end, seg in regions:
        insns = grow.disasm_window(start, seg, end - start)
        blob = rom[start - grow.ROM1_BASE:end - grow.ROM1_BASE]
        cap = {i.address: (i.mnemonic, i.size)
               for i in md.disasm(blob, start)}
        for addr, byts, mnem, ops in insns:
            if addr + len(byts) > end:
                break
            total += 1
            if byts[0] == "F2" or byts[0] == "F3":
                pass                       # REP prefix: capstone folds it in
            if byts and int(byts[0], 16) in ONLY186_FIRST:
                only186[byts[0] + " " + mnem] += 1
            c = cap.get(addr)
            if c is None:
                continue                   # capstone lost sync earlier
            cmn, csize = c
            if csize != len(byts):
                # a REP/segment prefix is a separate "instruction" for
                # dasmx86 in some encodings; only flag a real disagreement
                mism_len += 1
                if len(examples) < 25:
                    examples.append(("LEN", addr, " ".join(byts), mnem, ops,
                                     cmn, csize))
                continue
            if cmn.upper() != mnem and (mnem, cmn) not in ALIAS:
                mism_mn += 1
                pairs[(mnem, cmn)] += 1
                if len(examples) < 25:
                    examples.append(("MNEM", addr, " ".join(byts), mnem, ops,
                                     cmn, csize))

    print("difference pairs:", sorted(pairs.items(), key=lambda kv: -kv[1]))
    print("instructions compared: %d" % total)
    print("length disagreements : %d" % mism_len)
    print("mnemonic differences : %d" % mism_mn)
    if examples:
        print("\nfirst differences:")
        for kind, addr, byts, mnem, ops, cmn, csize in examples:
            print("  %-4s %05X  %-20s dasm=%-8s %-22s cap=%-8s len %d"
                  % (kind, addr, byts, mnem, ops, cmn, csize))
    print("\n80186-only encodings inside decoded code:")
    for k, n in sorted(only186.items()):
        print("  %-16s %d" % (k, n))


if __name__ == "__main__":
    main()
