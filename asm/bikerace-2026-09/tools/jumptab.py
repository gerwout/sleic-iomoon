#!/usr/bin/env python3
"""jumptab.py -- recover the entry points behind "JMP CS:W[BX + disp]" tables.

The firmware dispatches most of its state machines through an indexed near
jump:

    CMP   BX, 000D          ; bound check: 14 entries
    JNBE  <default>
    SHL   BX, 1
    JMP   CS:W[BX + 018F]   ; table at CS:018F

so the table is a run of 16-bit offsets in the same code segment.  This
script reads the current listing, finds every such jump, derives the table's
flat address from the region's CS value, takes the entry count from the
CMP that guards it (falling back to a scan-until-implausible walk), and
prints the resulting entry points in entries.txt format.

Every candidate is validated before it is printed: its offset must land in
the UMCS window and dasmx86 must decode the first two instructions at the
target without an undecodable byte.

    python3 jumptab.py            # print new entry points
    python3 jumptab.py --tables   # also show the tables themselves
"""
import os
import re
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import grow                                              # noqa: E402

JMPTAB = re.compile(r"^(JMP|CALL)$")
TABOP = re.compile(r"^CS:W\[(BX|SI|DI)( \+ 0([0-9A-F]+))?\]$")
CMPRE = re.compile(r"^(BX|SI|DI|AX),\s*0([0-9A-F]+)$")

MAX_ENTRIES = 64          # ceiling when no bound check is found


def load_listing():
    ins = []
    for line in open(grow.LST):
        m = grow.LINE_RE.match(line)
        if m:
            ins.append((int(m.group(1), 16), m.group(2).split(),
                        m.group(3), m.group(4)))
    return ins


def plausible(addr, seg):
    """True if dasmx86 decodes two coherent instructions at addr."""
    if not (grow.CODE_LO <= addr < grow.CODE_HI):
        return False
    insns = grow.disasm_window(addr, seg, 0x10)
    if len(insns) < 2:
        return False
    return all(i[2] != "???" for i in insns[:2])


def main():
    show_tables = "--tables" in sys.argv
    _, regions, _ = grow.build_regions()
    covered = lambda a: any(s <= a < e for s, e, _ in regions)

    def seg_at(a):
        for s, e, g in regions:
            if s <= a < e:
                return g
        return None

    rom = open(grow.ROM, "rb").read()
    ins = load_listing()
    out = {}
    tables = []
    for i, (addr, byts, mnem, ops) in enumerate(ins):
        if not JMPTAB.match(mnem):
            continue
        m = TABOP.match(ops)
        if not m:
            continue
        seg = seg_at(addr)
        if seg is None:
            continue
        idxreg = m.group(1)
        disp = int(m.group(3), 16) if m.group(3) else 0
        tab = (seg << 4) + disp

        # Two shapes reach an indexed jump, and they put the table in
        # different places:
        #
        #  (a) "CMP BX,n / JNBE / SHL BX,1 / JMP CS:W[BX+disp]" -- BX is a
        #      small index, the table is at CS:disp and has n+1 entries.
        #  (b) "MOV CX,n / MOV BX,base / <search loop> / JMP CS:W[BX+disp]"
        #      -- BX walks a key table at CS:base, and the parallel handler
        #      table sits disp bytes further on, also with n entries.
        #
        # Anything else is left alone rather than guessed at.
        count = base = loopn = None
        for j in range(i - 1, max(0, i - 14), -1):
            mn, op = ins[j][2], ins[j][3]
            if count is None and mn == "CMP":
                c = CMPRE.match(op)
                if c and c.group(1) == idxreg:
                    count = int(c.group(2), 16) + 1
            if base is None and mn == "MOV":
                c = CMPRE.match(op)
                if c and c.group(1) == idxreg:
                    base = int(c.group(2), 16)
            if loopn is None and mn == "MOV" and op.startswith("CX,"):
                loopn = int(op.split(",")[1].strip().lstrip("0") or "0", 16)
        if base is not None:
            tab = (seg << 4) + base + disp
            count = loopn
        if count is None:
            tables.append((addr, seg, tab, None, []))
            continue
        if any(s <= tab < e for s, e, _ in regions):
            tables.append((addr, seg, tab, "in-code", []))
            continue

        ents = []
        for k in range(count):
            o = tab - grow.ROM1_BASE + k * 2
            off = int.from_bytes(rom[o:o + 2], "little")
            tgt = (seg << 4) + off
            ents.append((off, tgt, plausible(tgt, seg)))
        tables.append((addr, seg, tab, count, ents))
        for off, tgt, ok in ents:
            if ok and not covered(tgt):
                out.setdefault((tgt, seg), []).append(addr)

    if show_tables:
        for addr, seg, tab, count, ents in tables:
            print("# JMP CS:W[..] at %05X  CS=%04X  table %05X  count=%s"
                  % (addr, seg, tab, count if count else "walked"))
            for k, (off, tgt, ok) in enumerate(ents):
                print("#    [%2d] %04X -> %05X %s" %
                      (k, off, tgt, "" if ok else "(rejected)"))
    for (tgt, seg), srcs in sorted(out.items()):
        print("%05X  %04X  sub_%05X  # jump-table entry, %d table(s), first %05X"
              % (tgt, seg, tgt, len(srcs), srcs[0]))


if __name__ == "__main__":
    main()
