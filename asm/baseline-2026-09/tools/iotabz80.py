#!/usr/bin/env python3
"""iotabz80.py -- enumerate the Z80 ROM's complete I/O surface.

Two passes, and the second is the one that makes the enumeration a *claim*
rather than a list:

  1. **Every I/O instruction in the decoded listing**, grouped by port.  The
     port number is taken from the instruction's own raw bytes (`D3 nn` =
     `OUT (nn),A`, `DB nn` = `IN A,(nn)`), not from the operand text, and
     the `ED`-prefixed register-indirect forms (`IN r,(C)` / `OUT (C),r`,
     `ED 40+8r` / `ED 41+8r`) and the block forms (`INI`/`IND`/`OUTI`/
     `OUTD` and their repeating variants) are recognised separately, because
     their port comes from register C at run time and so is not a constant
     this static pass can name.  Each site is attributed to the routine it
     sits in: the nearest entry point at or below it.

  2. **Every byte in the whole ROM that could be an I/O opcode**, decoded or
     not.  Any `D3`/`DB`/`ED 4x` byte outside a decoded code region is
     listed, with the data span it falls in, so "the surface is complete" is
     checkable instead of assumed: each hit has to be explainable as a byte
     of a known table rather than as a missed instruction.  Bytes inside a
     region that are not instruction starts (an operand, or a data byte that
     happens to equal D3) are correctly not counted, because pass 2 tests
     membership of the listing's instruction-start set, not raw position.
     This pass is a report, not a gate -- the gate is xverify.py -- so it
     does not by itself decide the exit status.

    python3 iotabz80.py             # port summary + unaccounted-for scan
    python3 iotabz80.py --sites     # ... plus every site, one per line
    python3 iotabz80.py --markdown  # the README's port table
"""
import os
import sys
from collections import defaultdict

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import growz80                                           # noqa: E402

BLOCK_IO = {0xA2: "INI", 0xA3: "OUTI", 0xAA: "IND", 0xAB: "OUTD",
            0xB2: "INIR", 0xB3: "OTIR", 0xBA: "INDR", 0xBB: "OTDR"}


def load_listing():
    ins = []
    for line in open(growz80.LST):
        m = growz80.LINE_RE.match(line)
        if m:
            ins.append((int(m.group(1), 16), [int(b, 16) for b in
                                              m.group(2).split()],
                        m.group(3), m.group(4)))
    return ins


def classify(byts):
    """(kind, port) for an I/O instruction, or None.

    kind is "in"/"out"; port is an int for the immediate forms and None for
    the forms whose port is register C at run time.
    """
    if byts[0] == 0xDB and len(byts) == 2:
        return "in", byts[1]
    if byts[0] == 0xD3 and len(byts) == 2:
        return "out", byts[1]
    if byts[0] == 0xED and len(byts) == 2:
        b = byts[1]
        if b in BLOCK_IO:
            return ("in" if BLOCK_IO[b][1] == "N" else "out"), None
        if (b & 0xC7) == 0x40:
            return "in", None            # IN r,(C)
        if (b & 0xC7) == 0x41:
            return "out", None           # OUT (C),r
    return None


def main():
    want_sites = "--sites" in sys.argv
    markdown = "--markdown" in sys.argv
    entries, regions, _diag = growz80.build_regions()
    ins = load_listing()
    starts = {a for a, _b, _m, _o in ins}

    def routine_of(addr):
        cands = [(ea, lab) for ea, lab in entries if ea <= addr]
        return cands[-1][1] if cands else "?"

    sites = []
    for addr, byts, mnem, ops in ins:
        c = classify(byts)
        if c:
            kind, port = c
            sites.append((addr, kind, port, mnem, ops, routine_of(addr)))

    byport = defaultdict(list)
    for addr, kind, port, mnem, ops, rout in sites:
        byport[(kind, port)].append((addr, rout, mnem, ops))

    # --- pass 2: nothing missed outside the decoded regions ---------------
    rom = open(growz80.ROM, "rb").read()
    inside = lambda a: any(s <= a < e for s, e in regions)
    unaccounted = []
    for a in range(len(rom) - 1):
        if rom[a] in (0xD3, 0xDB) or (rom[a] == 0xED
                                      and ((rom[a + 1] & 0xC7) in (0x40, 0x41)
                                           or rom[a + 1] in BLOCK_IO)):
            if inside(a) and a in starts:
                continue                      # counted above
            if inside(a):
                continue                      # not an instruction start: operand/data byte
            unaccounted.append(a)

    if markdown:
        print("| port | dir | sites | addresses |")
        print("|---|---|---|---|")
        for (kind, port) in sorted(byport,
                                   key=lambda k: (k[0], -1 if k[1] is None
                                                  else k[1])):
            addrs = byport[(kind, port)]
            print("| `%s` | %s | %d | %s |"
                  % ("(C)" if port is None else "0x%02X" % port,
                     kind.upper(), len(addrs),
                     ", ".join("%04X" % a for a, _r, _m, _o in addrs)))
        return

    print("I/O instructions in decoded code: %d" % len(sites))
    for (kind, port) in sorted(byport,
                               key=lambda k: (k[0], -1 if k[1] is None
                                              else k[1])):
        addrs = byport[(kind, port)]
        print("  %-3s port %-4s  %3d site(s)  routines: %s"
              % (kind.upper(), "(C)" if port is None else "%02X" % port,
                 len(addrs),
                 ", ".join(sorted({r for _a, r, _m, _o in addrs}))))

    if want_sites:
        print("\nevery site:")
        for addr, kind, port, mnem, ops, rout in sites:
            print("  %04X  %-3s %-4s  %-4s %-14s  in %s"
                  % (addr, kind.upper(),
                     "(C)" if port is None else "%02X" % port,
                     mnem, ops, rout))

    print("\nwhole-ROM scan for I/O opcodes outside the decoded regions: %d"
          % len(unaccounted))
    gaps = [(regions[i][1], regions[i + 1][0])
            for i in range(len(regions) - 1)] + [(regions[-1][1],
                                                  growz80.CODE_HI)]
    for a in unaccounted:
        span = next(("%04X-%04X" % (s, e) for s, e in gaps if s <= a < e),
                    "before the first region")
        print("  %04X  %02X %02X   in data span %s"
              % (a, rom[a], rom[a + 1], span))
    return 0


if __name__ == "__main__":
    sys.exit(main())
