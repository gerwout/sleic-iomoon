#!/usr/bin/env python3
"""orphanz80.py -- recover routines that no control-flow edge reaches.

After the direct call graph (growz80.py) and the five `JP (HL)` dispatches
(jumptabz80.py) have converged, about 6.5 KiB of non-0xFF content is still
undecoded.  Most of it is genuinely data -- the dispatch tables and the
sixteen data blocks at 38CC-4FD4 -- but roughly 300 bytes of it, spread over
a dozen small gaps, are unmistakably code: short routines that sit
immediately after a decoded region's terminating `RET`, decode cleanly, and
end in a `RET` of their own -- but that nothing in the ROM calls, jumps to,
or lists in a dispatch table.  The `IN A,($04) / BIT 7,A / ... / JP $0400`
fragment at 2E3F is the clearest example.  They read as code the assembler
laid down next to its neighbours and that later revisions stopped calling.

This is the weakest of the three discovery channels -- it asserts nothing
about control flow -- so, like the 80188 baseline's prologue scanner, it is
kept in its own script and its contribution is reported separately.  It is
made as conservative as the evidence allows:

  * Only a *gap between two decoded code regions* is considered.  Anything
    beyond the last decoded region is not, so the ROM's trailing data is
    never touched.
  * A gap any of whose bytes is the target of a data reference (dasmxx's
    `Ptr` and `Imm` cross-references, plus the references of gaps accepted
    earlier in this same run) holds a **table**, and is skipped whole --
    unless those references pin the table's extent exactly (see the comment
    on the contiguous-run test below).  That is what correctly keeps the
    byte tables at 05B6, 1218, 2000, 37E2 and 3830 out.  Gaps are examined
    in descending address order so that a routine's own `LD A,($3382)`-style
    references are already known by the time the gap holding that table is
    judged.
  * Leading 0xFF filler is skipped, then the gap must decode with no `???`
    and land exactly on a boundary -- see terminates() for the two accepted
    shapes and why landing exactly is what makes them safe.  A byte table
    that happens to decode without `???` (1218 is a run of `LD r,r'`) fails
    this even before the data-reference test above, because it runs past the
    end of the gap without ever terminating.

    python3 orphanz80.py            # print new entry points
    python3 orphanz80.py --detail   # ... and why each gap was accepted or not
"""
import os
import re
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import growz80                                           # noqa: E402

MIN_INSNS = 3

# dasmxx -x dump: "3381: Ptr    @ 3404" / "1218: Imm    @ 0DE7  (label)".
# Only Ptr and Imm mark a *data* address; Call/Jump mark code and IO marks
# an I/O port number, which is not a memory address at all.
XREF_DATA = re.compile(r"^([0-9A-F]+):\s+(Ptr|Imm)\s+@")
# Operands that name a memory address: "($C074)", "#$2F01", "A, ($3382)".
OPERAND_ADDR = re.compile(r"[#(]\$([0-9A-F]{4})\)?")


def load_data_refs(rom):
    """Every address the current listing references as data.

    dasmxx registers an `Imm` cross-reference for *every* 16-bit immediate,
    so plain numeric constants (`LD BC,#$03E8` = 1000, `LD HL,#$00C8` = 200)
    show up alongside real table addresses.  A reference whose target byte
    is unprogrammed EPROM (0xFF) therefore cannot be a table and is dropped
    -- without that filter the single spurious "reference" to 00C8 hid the
    two `OUT ($81),A` routines at 0100 and 010B behind it.
    """
    refs = set()
    for line in open(growz80.LST):
        m = XREF_DATA.match(line)
        if m:
            a = int(m.group(1), 16)
            if a < len(rom) and rom[a] != 0xFF:
                refs.add(a)
    return refs


def terminates(insns, end):
    """(ok, why): does the gap decode as a self-contained piece of code?

    Two acceptable shapes, both of which have to decode with no `???`:

      * it reaches an unconditional terminator inside the gap.  At least
        MIN_INSNS instructions are required, *unless* the terminator lands
        exactly on the gap's end -- a gap whose entire content is one `RET`
        is the tail of a routine whose body was absorbed into the previous
        region, and is not a coincidence;
      * it runs to the gap's end exactly, with no terminator: a fragment
        that falls through into the region that follows (27DB is one).

    Landing exactly on the boundary is what makes both cases safe: a byte
    table decoded as instructions would have to end its last instruction on
    precisely the right byte to be mistaken for either.
    """
    n = 0
    for addr, byts, mnem, ops in insns:
        if addr >= end:
            break
        if mnem == "???":
            return False, "undecodable byte at %04X" % addr
        n += 1
        nxt = addr + len(byts)
        if nxt > end:
            return False, "last instruction straddles the end of the gap"
        unconditional = not growz80.is_conditional(ops)
        if unconditional and (mnem in growz80.TERMINATORS
                              or mnem in ("JP", "JR")):
            if n < MIN_INSNS and nxt != end:
                return False, "only %d instruction(s) before the terminator" % n
            return True, "%d instructions, ends %s at %04X" % (n, mnem, addr)
        if nxt == end:
            return True, ("%d instructions, falls through into the next "
                          "region at %04X" % (n, end))
    return False, "no terminator decoded"


def main():
    detail = "--detail" in sys.argv
    _entries, regions, _diag = growz80.build_regions()
    rom = open(growz80.ROM, "rb").read()
    refs = load_data_refs(rom)

    gaps = [(regions[i][1], regions[i + 1][0])
            for i in range(len(regions) - 1)
            if regions[i + 1][0] > regions[i][1]]

    accepted, notes = [], []
    for start, end in sorted(gaps, reverse=True):
        inside = sorted(r for r in refs if start <= r < end)
        cur = start
        if inside:
            # A referenced address inside the gap means a table is in there
            # and the gap is not code -- with one exception that is decided
            # by the references themselves, not by a guess: when they form a
            # *contiguous run of at least two* addresses and nothing above it
            # is referenced, the table's extent is known exactly (it is that
            # run) and whatever follows it may still be code.  That is the
            # 337B-3382 byte table, one entry per routine of the nine-routine
            # family at 3383/339E/33AF/.../3415, with the family's [0] member
            # sitting immediately behind it.  A gap whose references are a
            # lone address (2000, the 256-entry command table's base) or a
            # scattered set (1218, 05B6) says nothing about where the table
            # ends, so it is skipped whole.
            run = inside[-1] - inside[0] + 1 == len(inside) and len(inside) >= 2
            if not run:
                notes.append((start, end, "skipped: data-referenced (%s)"
                              % ", ".join("%04X" % r for r in inside)))
                continue
            cur = inside[-1] + 1
        filler = cur
        while cur < end and rom[cur] == 0xFF:
            cur += 1
        if cur >= end:
            notes.append((start, end, "skipped: nothing left after the "
                                      "table/filler at %04X" % filler))
            continue
        insns = growz80.disasm_window(cur, end - cur)
        ok, why = terminates(insns, end)
        notes.append((start, end, ("accepted at %04X: " % cur) + why
                      if ok else "skipped: " + why))
        if not ok:
            continue
        accepted.append((cur, start, end))
        # A routine accepted here may itself point at a table sitting in a
        # lower gap; make those references visible before that gap is judged.
        # Same 0xFF filter as load_data_refs(): `LD HL,#$003C` is the number
        # 60, not a pointer to unprogrammed EPROM at 003C.
        for _a, _b, _m, ops in insns:
            for m in OPERAND_ADDR.finditer(ops):
                a = int(m.group(1), 16)
                if a < len(rom) and rom[a] != 0xFF:
                    refs.add(a)

    if detail:
        for start, end, why in sorted(notes):
            print("# gap %04X-%04X  %s" % (start, end, why))

    for cur, start, end in sorted(accepted):
        print("%04X  sub_%04X  # orphan routine in the %04X-%04X gap "
              "(no call/jump/table edge reaches it)" % (cur, cur, start, end))


if __name__ == "__main__":
    main()
