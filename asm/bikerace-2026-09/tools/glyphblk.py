#!/usr/bin/env python3
"""glyphblk.py -- locate the DMD text blocks and report the code entry points
that fall inside them.

Bike Race stores its on-screen text as indices into the DMD font, not as
ASCII: every byte of a message is in 0x00-0x2F, and F6284 indexes the block
with `IMUL BX, BX, 0x2E`, i.e. 46-byte records -- the same record size IO
Moon uses for its service-menu tree.

grow.py's pushptr channel seeds a code entry point for every far pointer it
sees pushed, and cannot tell a pointer-to-text from a pointer-to-routine.
The text then decodes as garbage, and because 0x0F is a common glyph index
it decodes as a dense run of `POP CS` -- an instruction that exists on the
8086/80188 but not on any CPU capstone or ndisasm knows, which is what the
cross-verifier reports.

A block is accepted here only if it is at least MIN_RUN bytes long and every
single byte of it is <= 0x2F.  That is a much stronger test than "looks like
text": real code in this ROM never manages more than a few dozen consecutive
bytes under 0x30.

Containment alone is still not enough to condemn an entry, because a block
runs up to the first byte over 0x2F and a routine whose own first opcode is
low-valued (PUSH DS = 0x1E, for instance) sits on that boundary: both F0000
and F5000 do.  So an entry is only reported if at least RECORD bytes *from
the entry onwards* are still inside the block -- one whole 46-byte text
record.  Real code never gets that far.

    python3 glyphblk.py            # print blocks and the entries inside them
    python3 glyphblk.py --notcode  # print those entries in notcode.txt format
"""
import os, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import grow

MAX_GLYPH = 0x2F
MIN_RUN = 0x100
RECORD = 0x2E     # the table's own record stride, from IMUL BX, BX, 0x2E


def blocks():
    rom = open(grow.ROM, "rb").read()
    out, start = [], None
    for i, b in enumerate(rom):
        if b <= MAX_GLYPH:
            if start is None:
                start = i
        else:
            if start is not None and i - start >= MIN_RUN:
                out.append((start + grow.ROM1_BASE, i + grow.ROM1_BASE))
            start = None
    if start is not None and len(rom) - start >= MIN_RUN:
        out.append((start + grow.ROM1_BASE, len(rom) + grow.ROM1_BASE))
    return out


def main():
    blks = blocks()
    entries = grow.parse_entries()
    inside = []
    for lo, hi in blks:
        hits = [(a, lbl) for a, _seg, lbl in entries if lo <= a and a + RECORD <= hi]
        if hits:
            inside.append((lo, hi, hits))
    if "--notcode" in sys.argv:
        for lo, hi, hits in inside:
            for a, _lbl in hits:
                print("%05X  # inside the %d-byte all-glyph text block "
                      "%05X-%05X (every byte <= 0x2F)" % (a, hi - lo, lo, hi - 1))
        return
    print("all-glyph blocks of >= %d bytes:" % MIN_RUN)
    for lo, hi in blks:
        n = sum(1 for _lo, _hi, _h in inside if _lo == lo)
        print("  %05X-%05X  %5d bytes   %s"
              % (lo, hi - 1, hi - lo,
                 "%d code entries inside" % len(dict(
                     (a, l) for _l, _h, hs in inside if _l == lo for a, l in hs))
                 if n else ""))

main()
