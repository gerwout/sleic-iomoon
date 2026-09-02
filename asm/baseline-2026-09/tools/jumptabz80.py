#!/usr/bin/env python3
"""jumptabz80.py -- recover the entry points behind the Z80 ROM's `JP (HL)`
dispatches.

The direct CALL/JP/JR call graph reaches only about a tenth of this ROM,
because almost every state machine in it is entered through `JP (HL)`.  There
are exactly two shapes, and this script handles both.  Every `JP (HL)` in the
listing must match one of them; one that matches neither is reported (and
makes the script exit nonzero) rather than being ignored, so a shape this
script does not understand cannot silently cost coverage.

**Shape A -- indexed word table.**

    LD   HL, #$2000        ; table base, taken from this immediate
    LD   D, #$00
    LD   E, A
    SLA  E                 ; index*2, carry out of bit 7 ...
    JP   NC, $16EE
    LD   D, #$01           ; ... folded into D, so the index is a full 9 bits
    ADD  HL, DE
    LD   E, (HL)
    INC  HL
    LD   D, (HL)
    EX   DE, HL
    JP   (HL)

  The entry count comes from the code, never from a guess:

    * a preceding `CP #$nn` that guards the index gives `nn + 1` entries
      (the two sites that have one wrap the index with
      `CP #$nn / JP C,+ / XOR A / JP ++ / INC A`, so the index runs 0..nn);
    * otherwise, the `SLA E` + `LD D,#$01` carry fold above proves the
      offset is 9 bits wide, i.e. a full 256-entry table.

  A shape-A jump with neither is reported unbounded and contributes no
  entries.

**Shape B -- dispatch through a RAM pointer variable.**

    LD   HL, ($C0E5)
    JP   (HL)

  The variable is a state pointer: each handler stores the *next* handler's
  address into it before returning (`LD HL,#$2F01 / LD ($C0E5),HL`).  The
  entry points are therefore every 16-bit immediate the ROM ever stores into
  that variable, recovered by scanning the raw image for the two-instruction
  byte sequence `21 lo hi  22 <var-lo> <var-hi>`.  The scan is over the whole
  ROM rather than over decoded regions only, so a store sitting in
  not-yet-decoded code still contributes -- which is what makes the channel
  converge.

Every recovered target is validated before it is printed: it must lie inside
the ROM and dasmz80 must decode two coherent instructions there.

    python3 jumptabz80.py            # print new entry points
    python3 jumptabz80.py --tables   # also show the tables themselves
"""
import os
import re
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import growz80                                           # noqa: E402

# `LD HL, #$XXXX`  (immediate)  vs  `LD HL, ($XXXX)`  (from memory)
LD_HL_IMM = re.compile(r"^HL,\s*#\$([0-9A-F]{4})$")
LD_HL_MEM = re.compile(r"^HL,\s*\(\$([0-9A-F]{4})\)$")
CP_IMM = re.compile(r"^A?,?\s*#?\$?([0-9A-F]{2})$")

# The four instructions that turn HL (= table base + index*2) into the target
# address.  They are always contiguous and always immediately before JP (HL).
FETCH = [("LD", "E, (HL)"), ("INC", "HL"), ("LD", "D, (HL)"), ("EX", "DE, HL")]

LOOKBACK = 40             # instructions of context searched before a JP (HL)


def load_listing():
    ins = []
    for line in open(growz80.LST):
        m = growz80.LINE_RE.match(line)
        if m:
            ins.append((int(m.group(1), 16), m.group(2).split(),
                        m.group(3), m.group(4)))
    return ins


def context_before(addr, floor):
    """The instruction stream from `floor` up to (not including) `addr`,
    re-decoded with **no labels declared**.

    The committed listing cannot be used for this: it declares labels, so
    dasmz80 prints `LD HL, ___BDATA_0021` where the table base belongs, and
    the scanner would silently fall back to some earlier routine's
    `LD HL,#$xxxx` -- which is exactly what happened at the 382F dispatch
    (it picked up 37A9's table base 37E2 instead of its own 3830).
    Re-decoding the enclosing region label-free makes every immediate
    numeric again.
    """
    ins = [i for i in growz80.disasm_window(floor, addr - floor + 4)
           if i[0] < addr]
    return ins[-LOOKBACK:]


def plausible(addr):
    """True if dasmz80 decodes two coherent instructions at addr."""
    if not (growz80.CODE_LO <= addr < growz80.CODE_HI - 1):
        return False
    insns = growz80.disasm_window(addr, 0x10)
    if len(insns) < 2:
        return False
    # A run of 0xFF (RST $38) decodes "fine" but is unprogrammed EPROM, not
    # a routine, so reject it explicitly.
    if insns[0][1] == ["FF"]:
        return False
    return all(i[2] != "???" for i in insns[:2])


def scan_pointer_stores(rom, var):
    """Every `LD HL,#imm ; LD (var),HL` in the raw image -> [(site, imm)]."""
    out = []
    for a in range(len(rom) - 6):
        if (rom[a] == 0x21 and rom[a + 3] == 0x22
                and rom[a + 4] | (rom[a + 5] << 8) == var):
            out.append((a, rom[a + 1] | (rom[a + 2] << 8)))
    return out


def main():
    show_tables = "--tables" in sys.argv
    ins = load_listing()
    rom = open(growz80.ROM, "rb").read()
    entries, regions, _diag = growz80.build_regions()
    covered = lambda a: any(s <= a < e for s, e in regions)

    def floor_for(a):
        """Where the backward search must stop: the start of the routine the
        dispatch belongs to, approximated by the nearest entry point at or
        below it, and never earlier than its enclosing region."""
        region = max((s for s, e in regions if s <= a < e), default=a)
        entry = max((ea for ea, _l in entries if region <= ea <= a),
                    default=region)
        return entry

    tables = []          # (site, kind, detail, count, [(idx, target, ok)])
    unmatched = []
    out = {}

    for i, (addr, byts, mnem, ops) in enumerate(ins):
        if mnem != "JP" or ops != "(HL)":
            continue

        window = context_before(addr, floor_for(addr))

        # --- shape B: LD HL,(var) immediately before the JP (HL) ----------
        if window and window[-1][2] == "LD":
            m = LD_HL_MEM.match(window[-1][3])
            if m:
                var = int(m.group(1), 16)
                stores = scan_pointer_stores(rom, var)
                ents = []
                for k, (site, imm) in enumerate(stores):
                    ents.append((site, imm, plausible(imm)))
                tables.append((addr, "B", "$%04X" % var, len(stores), ents))
                for site, imm, ok in ents:
                    if ok and not covered(imm):
                        out.setdefault(imm, []).append(addr)
                continue

        # --- shape A: indexed word table ---------------------------------
        tail = [(m, o) for _a, _b, m, o in window[-4:]]
        if tail != FETCH:
            unmatched.append(addr)
            continue
        base = count = None
        wide = False
        for _a, _b, m, o in reversed(window[:-4]):
            if base is None and m == "LD":
                mm = LD_HL_IMM.match(o)
                if mm:
                    base = int(mm.group(1), 16)
            if m == "LD" and o.replace(" ", "") == "D,#$01":
                wide = True          # the SLA-carry fold: 9-bit offset
            if count is None and m == "CP":
                mm = CP_IMM.match(o.replace(" ", ""))
                if mm:
                    count = int(mm.group(1), 16) + 1
        if base is None:
            unmatched.append(addr)
            continue
        if count is None:
            count = 256 if wide else None
        if count is None:
            tables.append((addr, "A", "$%04X" % base, None, []))
            continue

        ents = []
        for k in range(count):
            o = base + k * 2
            tgt = rom[o] | (rom[o + 1] << 8)
            ents.append((k, tgt, plausible(tgt)))
        tables.append((addr, "A", "$%04X" % base, count, ents))
        for _k, tgt, ok in ents:
            if ok and not covered(tgt):
                out.setdefault(tgt, []).append(addr)

    if show_tables:
        for site, kind, detail, count, ents in tables:
            print("# %s dispatch at %04X  %s  count=%s"
                  % ("indexed table" if kind == "A" else "RAM pointer",
                     site, detail, count if count is not None else "UNBOUNDED"))
            for k, tgt, ok in ents:
                print("#    [%s] -> %04X %s"
                      % ("%3d" % k if kind == "A" else "store@%04X" % k,
                         tgt, "" if ok else "(rejected)"))
        if unmatched:
            print("# JP (HL) sites matching neither shape: %s"
                  % ", ".join("%04X" % a for a in unmatched))

    for tgt, srcs in sorted(out.items()):
        print("%04X  sub_%04X  # dispatch-table entry, %d site(s), first %04X"
              % (tgt, tgt, len(srcs), srcs[0]))

    return 1 if unmatched else 0


if __name__ == "__main__":
    sys.exit(main())
