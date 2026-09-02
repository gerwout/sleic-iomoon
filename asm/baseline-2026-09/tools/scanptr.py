#!/usr/bin/env python3
"""scanptr.py -- find code entry points that the CALL/JMP call graph misses.

grow.py follows direct CALL/JMP edges only.  Two constructs in this ROM hide
code behind an indirect edge:

  1. "PUSH <seg>; PUSH <off>" pairs -- a far function pointer built on the
     stack and later invoked with "CALL W[BP+n]" (opcode FF /3).  Only pairs
     whose segment is one of the CS values already seen in real code, and
     whose flat target is not already in a region, are reported.

  2. "MOV W[10F6], imm16" and "MOV W[10F8], imm16" -- two animation
     dispatch variables in work RAM.  F000:1303 does "MOV AX,[10F6];
     JMP AX", and the handlers it reaches do the same with [10F8], so
     every immediate stored to either is an entry point in segment F000.
     The scan is a raw byte search over ROM1 for C7 06 F6 10 <imm16> /
     C7 06 F8 10 <imm16> so that stores from not-yet-decoded code are
     found too; each hit is verified by decoding the target before use.

Both are heuristics: every address they produce must still be checked by
decoding it (grow.py's extent pass will flag an incoherent one with a
"no terminator" or "undecodable byte" note).

  3. A routine prologue signature, for code that none of the above reaches.
     Segment F000 holds a large family of near-identical animation routines
     that open "CLI / PUSH DS / MOV AX,4000 / MOV DS,AX"; some are reached
     only from data the baseline has not decoded.  This scan reports that
     7-byte sequence wherever it appears in a not-yet-decoded part of the
     UMCS window, and only there.  Being a signature match it is the
     weakest of the three: each hit must be read before it is believed
     (grow.py's extent pass flags an incoherent one).

    python3 scanptr.py pushptr     # scan 1, needs an up-to-date .lst
    python3 scanptr.py dispatch    # scan 2
    python3 scanptr.py prologue    # scan 3
"""
import os
import re
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import grow                                              # noqa: E402

# CS values observed in real, decoded code.
KNOWN_SEGS = {0xD000, 0xD2F2, 0xD72A, 0xDD25, 0xE326, 0xF000, 0xFFF0, 0xFFFF}

DISPATCH_VARS = [bytes.fromhex("c706f610"),    # MOV W[10F6], imm16
                 bytes.fromhex("c706f810")]    # MOV W[10F8], imm16
DISPATCH_SEG = 0xF000

# CLI / PUSH DS / MOV AX,4000 / MOV DS,AX
PROLOGUE = bytes.fromhex("fa1eb800408ed8")


def regions():
    _, regs, _ = grow.build_regions()
    return regs


def inside(regs, a):
    return any(s <= a < e for s, e, _ in regs)


def pushptr():
    regs = regions()
    txt = open(grow.LST).read()
    ins = []
    for line in txt.splitlines():
        m = grow.LINE_RE.match(line)
        if m:
            ins.append((int(m.group(1), 16), m.group(3), m.group(4)))
    out = {}
    for (a1, m1, o1), (a2, m2, o2) in zip(ins, ins[1:]):
        if m1 != "PUSH" or m2 != "PUSH":
            continue
        v1 = re.match(r"^0([0-9A-F]{1,5})$", o1)
        v2 = re.match(r"^0([0-9A-F]{1,5})$", o2)
        if not v1 or not v2:
            continue
        seg, off = int(v1.group(1), 16), int(v2.group(1), 16)
        if seg not in KNOWN_SEGS:
            continue
        lin = (seg << 4) + off
        if grow.CODE_LO <= lin < grow.CODE_HI and not inside(regs, lin):
            out.setdefault((lin, seg), []).append(a1)
    return out


def dispatch():
    regs = regions()
    data = open(grow.ROM, "rb").read()
    out = {}
    for var in DISPATCH_VARS:
        i = data.find(var)
        while i >= 0:
            imm = int.from_bytes(data[i + 4:i + 6], "little")
            lin = (DISPATCH_SEG << 4) + imm
            if grow.CODE_LO <= lin < grow.CODE_HI and not inside(regs, lin):
                out.setdefault((lin, DISPATCH_SEG), []).append(i + grow.ROM1_BASE)
            i = data.find(var, i + 1)
    return out


def prologue():
    regs = regions()
    data = open(grow.ROM, "rb").read()
    out = {}
    i = data.find(PROLOGUE)
    while i >= 0:
        lin = i + grow.ROM1_BASE
        if grow.CODE_LO <= lin < grow.CODE_HI and not inside(regs, lin):
            seg = 0xF000 if lin >= 0xF0000 else (lin >> 4) & 0xF000
            out.setdefault((lin, seg), []).append(lin)
        i = data.find(PROLOGUE, i + 1)
    return out


if __name__ == "__main__":
    which = sys.argv[1] if len(sys.argv) > 1 else "pushptr"
    found = {"pushptr": pushptr, "dispatch": dispatch,
             "prologue": prologue}[which]()
    for (lin, seg), srcs in sorted(found.items()):
        print("%05X  %04X  sub_%05X  # %s, %d site(s), first %05X"
              % (lin, seg, lin, which, len(srcs), srcs[0]))
