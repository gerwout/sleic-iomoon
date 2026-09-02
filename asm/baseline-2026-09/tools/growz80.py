#!/usr/bin/env python3
"""growz80.py -- iterative code-region growth driver for the IO Moon Z80 baseline.

The Z80 counterpart of grow.py.  The disassembler is always dasmz80 (dasmxx);
this script only orchestrates it and parses its output:

  1. read the seed entry points from `entries_z80.txt`
  2. for every entry, run dasmz80 over a generous window starting at the
     entry and parse the resulting listing to find where the routine ends
     (linear sweep, extended over forward branches, terminated by the first
     RET/RETI/RETN/unconditional-JP/unconditional-JR that nothing branches
     past)
  3. merge the resulting spans into code regions
  4. emit the master command file and run dasmz80 -x over the whole ROM
  5. parse the listing for CALL/JP/JR targets that fall outside the known
     regions and report them as candidates for the next round

Differences from the 80188 side, all of them simplifications:

  * The Z80 has a flat 16-bit address space and no segmentation, so there is
    no `g` (segment base) command and no per-region CS column in
    `entries_z80.txt`.
  * ROM address == file offset (the 27C256 at IC5 is selected from `0x0000`),
    so the `>` file-offset command is only ever emitted once, as `>0`.

One Z80-specific hazard the 80188 side does not have: the unprogrammed-EPROM
filler byte `0xFF` decodes as a *valid* instruction, `RST $38`, which is a
call and therefore falls through.  A linear sweep that runs off the end of a
routine into filler would otherwise never terminate and would swallow the
whole rest of the ROM.  compute_extent() therefore stops at a run of
FILLER_RUN or more consecutive `RST $38` bytes and records a note; see the
README's "Filler" note for why that is safe here (the ROM contains no real
`RST` instruction at all).

Usage:
    python3 growz80.py candidates      # steps 1-5, print new call/jmp targets
    python3 growz80.py add <tag>       # ... and append them to entries_z80.txt
    python3 growz80.py emit            # steps 1-4, write iomoon_z80.cmd/.lst
    python3 growz80.py extent <hex>    # show the computed extent of one entry
"""
import os
import re
import subprocess
import sys
import tempfile

HERE = os.path.dirname(os.path.abspath(__file__))
BASE = os.path.abspath(os.path.join(HERE, ".."))
REPO = os.path.abspath(os.path.join(BASE, "..", ".."))
ROM = os.path.join(REPO, "roms", "1.3 IPDB latest", "V1 3_05.bin")
# Path written into the committed command file: repository-relative, so the
# file is portable.  dasmxx resolves it against the process CWD, so run
# dasmz80 from the repository root.
ROM_REL = "roms/1.3 IPDB latest/V1 3_05.bin"
DASM = os.path.expanduser("~/iomoon/tools/dasmxx/src/dasmz80")

CODE_LO = 0x0000             # the Z80 sees the 27C256 from address 0
CODE_HI = 0x8000             # ... to 0x7FFF (32 KiB), exclusive end

ENTRIES = os.path.join(BASE, "entries_z80.txt")
LABELS = os.path.join(BASE, "labels_z80.txt")
CMD = os.path.join(BASE, "iomoon_z80.cmd")
LST = os.path.join(BASE, "iomoon_z80.lst")

MAX_WINDOW = 0x1000          # biggest routine we will chase in one sweep
FILLER_RUN = 4               # consecutive `RST $38` (0xFF) bytes = EPROM filler

# Instructions after which control does not fall through.  `JP`/`JR` only
# count when unconditional, which is decided in compute_extent() by looking
# for a condition code in the operand field, not here.
TERMINATORS = ("RET", "RETI", "RETN")

LINE_RE = re.compile(
    r"^\s{4}([0-9A-F]+):\s{4}((?:[0-9A-F]{2} )+)\s*(\S+)\s*(.*?)\s*$")
# A target printed as a bare hex address.  dasmz80 prints `$XXXX`; it prints
# a *label* instead whenever one is declared at that address, which is why
# extent windows are disassembled with no labels at all (see disasm_window).
TARGET_RE = re.compile(r"\$([0-9A-F]{4})$")


def parse_labels():
    """labels_z80.txt: '<hex> <label> # note' -- hand-given names that
    override the generated ones, so a rebuild from the seed keeps them."""
    names = {}
    if not os.path.exists(LABELS):
        return names
    for raw in open(LABELS):
        line = raw.split("#")[0].strip()
        if not line:
            continue
        parts = line.split(None, 1)
        if len(parts) == 2:
            names[int(parts[0], 16)] = parts[1].strip()
    return names


def parse_entries():
    """entries_z80.txt: '<hex> <label> # note'."""
    names = parse_labels()
    out = []
    with open(ENTRIES) as fh:
        for raw in fh:
            line = raw.split("#")[0].strip()
            if not line:
                continue
            parts = line.split(None, 1)
            addr = int(parts[0], 16)
            label = parts[1].strip() if len(parts) > 1 else "sub_%04X" % addr
            out.append((addr, names.get(addr, label)))
    out.sort()
    # Same address may be named twice (seed + a later discovery round); keep
    # the first, which is the hand-written one.
    seen, uniq = set(), []
    for addr, label in out:
        if addr in seen:
            continue
        seen.add(addr)
        uniq.append((addr, label))
    return uniq


def run_dasm(cmdlines, xref=False):
    with tempfile.NamedTemporaryFile("w", suffix=".dz80", delete=False) as fh:
        fh.write("\n".join(cmdlines) + "\n")
        name = fh.name
    try:
        args = [DASM]
        if xref:
            args.append("-x")
        args.append(name)
        res = subprocess.run(args, capture_output=True, text=True, cwd=REPO)
        if res.returncode != 0:
            raise RuntimeError(
                "dasmz80 failed (exit %d) on:\n%s\n%s"
                % (res.returncode, "\n".join(cmdlines[:8]), res.stderr[-500:]))
        return res.stdout
    finally:
        os.unlink(name)


def disasm_window(start, length):
    """Return [(addr, bytes, mnemonic, operands)] for one window.

    No labels are declared, so every branch target in the result is printed
    as a bare `$XXXX` number and TARGET_RE can read it back.
    """
    txt = run_dasm([
        "f%s" % ROM_REL,
        ">%X" % start,
        "c%X" % start,
        "e%X" % (start + length),
    ])
    insns = []
    for line in txt.splitlines():
        m = LINE_RE.match(line)
        if m:
            insns.append((int(m.group(1), 16), m.group(2).split(),
                          m.group(3), m.group(4)))
    return insns


def is_conditional(ops):
    """True if a JP/JR/CALL/RET operand field carries a condition code.

    dasmz80 prints the condition first and comma-separated: `JP NZ, $007C`,
    `JR C, $1234`, `CALL Z, $0500`, `RET NC`.  An unconditional form has no
    comma and no condition token.
    """
    first = ops.split(",")[0].strip().upper()
    return first in ("Z", "NZ", "C", "NC", "PO", "PE", "P", "M")


def branch_target(mnem, ops):
    """Address a *conditional* JP/JR (or a DJNZ) transfers to, or None.

    Only conditional transfers count as "still the same routine".  Their
    target is where execution may resume after the fall-through path, so the
    sweep must not stop before it.  An *unconditional* JP/JR is handled the
    other way round -- it ends the region, and the target is picked up as a
    separate entry through the `Jump` cross-references in dasmz80's -x dump.
    Extending the region across it instead (which is what the 80188 side's
    grow.py does for `JMP`) swallows everything between the jump and its
    target: on this ROM the very first instruction pair, `JP 0400` at the
    reset vector, would otherwise absorb the whole 0x0012-0x03FF filler-and-
    vector area into one bogus "code" region.

    `JP (HL)` / `JP (IX)` / `JP (IY)` return None either way: the target is
    computed at run time, so the sweep cannot follow it.
    """
    if mnem == "DJNZ" or (mnem in ("JP", "JR") and is_conditional(ops)):
        m = TARGET_RE.search(ops)
        return int(m.group(1), 16) if m else None
    return None


def compute_extent(start, window=MAX_WINDOW):
    """Linear sweep from `start`, extended over forward branches, until a
    terminator that no in-region branch jumps past.  Returns (end, notes)."""
    # dasmxx errors out if a code region's end lands exactly on EOF, so stop
    # one byte short of the top of the ROM image.
    window = min(window, CODE_HI - 1 - start)
    insns = disasm_window(start, window)
    reach = start
    notes = []
    filler = 0
    for addr, byts, mnem, ops in insns:
        nxt = addr + len(byts)

        # Unprogrammed EPROM: 0xFF decodes as RST $38, which falls through,
        # so without this the sweep would run to the window cap.
        if byts == ["FF"]:
            filler += 1
            if filler >= FILLER_RUN and addr + 1 - filler > reach:
                notes.append("stopped on %d-byte 0xFF filler at %04X"
                             % (filler, addr + 1 - filler))
                return addr + 1 - filler, notes
            continue
        filler = 0

        tgt = branch_target(mnem, ops)
        if tgt is not None and start <= tgt < start + window and tgt > reach:
            reach = tgt

        terminates = (mnem in TERMINATORS and not is_conditional(ops)) or \
                     (mnem in ("JP", "JR") and not is_conditional(ops))
        if terminates and nxt > reach:
            return nxt, notes

        if mnem == "???":
            notes.append("undecodable byte at %04X" % addr)
    notes.append("no terminator within %X bytes" % window)
    return start + window, notes


def merge(spans):
    """spans: [(start, end)] -> non-overlapping, sorted list."""
    spans = sorted(spans)
    out = []
    for s, e in spans:
        if out and s <= out[-1][1]:
            out[-1][1] = max(out[-1][1], e)
        else:
            out.append([s, e])
    return out


def build_regions():
    entries = parse_entries()
    spans, diag = [], []
    for addr, label in entries:
        end, notes = compute_extent(addr)
        spans.append((addr, end))
        diag.append((addr, label, end, notes))
    return entries, merge(spans), diag


def emit_cmd(entries, regions):
    lines = [
        "# IO Moon (SLEIC, 1994) -- Z80 I/O CPU ROM, V1.3 set chip 05 (IC5).",
        "# Generated by asm/baseline-2026-09/tools/growz80.py -- do not hand-edit;",
        "# edit asm/baseline-2026-09/entries_z80.txt and re-run instead.",
        "#",
        "# The Z80 address space is flat and the 27C256 is selected from 0x0000,",
        "# so listing address == ROM file offset throughout.",
        "#",
        "# Run dasmz80 from the repository root: the input path below is",
        "# resolved against the current working directory.",
        "f%s" % ROM_REL,
        ">0",
    ]
    cur = CODE_LO
    for start, end in regions:
        if start > cur:
            lines.append("b%X" % cur)
        head = [l for a, l in entries if a == start]
        for addr, label in entries:
            if start < addr < end:
                lines.append("l%X\t%s" % (addr, label))
        lines.append("c%X\t%s" % (start, head[0] if head else
                                  "code_%04X" % start))
        cur = end
    if cur < CODE_HI:
        lines.append("b%X" % cur)
    lines.append("e%X" % CODE_HI)
    with open(CMD, "w") as fh:
        fh.write("\n".join(lines) + "\n")
    return lines


def listing(with_xref=True):
    return run_dasm(open(CMD).read().splitlines(), xref=with_xref)


XREF_HEAD = re.compile(r"^([0-9A-F]+):\s+(Jump|Call)\s+@ ([0-9A-F]+)")
XREF_CONT = re.compile(r"^\s+(Jump|Call)\s+@ ([0-9A-F]+)")


def candidates(regions, txt):
    """Targets of CALL/JP/JR instructions inside decoded regions that do not
    themselves land inside a decoded region.

    The target list comes from dasmz80's own -x cross-reference dump, which
    records every X_JMP/X_CALL reference regardless of whether the listing
    printed the target as a number or as a label.  X_IO references (the port
    numbers of `IN A,(n)` / `OUT (n),A`) are printed as "IO" and are
    deliberately not matched here -- an I/O port is not a code address.
    """
    inside = lambda a: any(s <= a < e for s, e in regions)

    insns = {}
    for line in txt.splitlines():
        m = LINE_RE.match(line)
        if m:
            insns[int(m.group(1), 16)] = (m.group(2).split(), m.group(3),
                                          m.group(4))

    found = {}
    tgt = None
    for line in txt.splitlines():
        m = XREF_HEAD.match(line)
        if m:
            tgt, kind, src = int(m.group(1), 16), m.group(2), int(m.group(3), 16)
        else:
            m = XREF_CONT.match(line)
            if not m or tgt is None:
                continue
            kind, src = m.group(1), int(m.group(2), 16)
        if inside(tgt) or not inside(src):
            continue
        byts, mnem, ops = insns.get(src, ([], "?", ""))
        flag = "" if CODE_LO <= tgt < CODE_HI else "OUT-OF-ROM"
        found.setdefault(tgt, []).append((src, mnem, ops, flag))
    return found


def main():
    cmdname = sys.argv[1] if len(sys.argv) > 1 else "candidates"
    if cmdname == "extent":
        a = int(sys.argv[2], 16)
        end, notes = compute_extent(a)
        print("%04X..%04X  (%d bytes)  %s" % (a, end, end - a, "; ".join(notes)))
        return
    entries, regions, diag = build_regions()
    emit_cmd(entries, regions)
    if cmdname == "emit":
        txt = listing(with_xref=True)
        with open(LST, "w") as fh:
            fh.write(txt)
        cov = sum(e - s for s, e in regions)
        print("regions: %d   code bytes: %d (%.1f%% of the %d-byte ROM)"
              % (len(regions), cov, 100.0 * cov / (CODE_HI - CODE_LO),
                 CODE_HI - CODE_LO))
        for addr, label, end, notes in diag:
            if notes:
                print("  note %04X %-28s %s" % (addr, label, "; ".join(notes)))
        return
    txt = listing(with_xref=True)
    found = candidates(regions, txt)
    print("regions: %d   code bytes: %d" %
          (len(regions), sum(e - s for s, e in regions)))
    print("new targets: %d" % len(found))
    for tgt in sorted(found):
        refs = found[tgt]
        print("  %04X %-11s refs=%-4d  first: %04X %s %s"
              % (tgt, refs[0][3], len(refs), refs[0][0], refs[0][1], refs[0][2]))
    if cmdname == "add" and found:
        with open(ENTRIES, "a") as fh:
            fh.write("\n# --- round %s: %d targets reached by CALL/JP/JR from"
                     " already-decoded code\n" % (sys.argv[2], len(found)))
            for tgt in sorted(found):
                if not (CODE_LO <= tgt < CODE_HI):
                    continue
                refs = found[tgt]
                fh.write("%04X  sub_%04X  # %s from %04X%s\n"
                         % (tgt, tgt, refs[0][1], refs[0][0],
                            "" if len(refs) == 1 else
                            " (+%d more)" % (len(refs) - 1)))
        print("appended to entries_z80.txt")


if __name__ == "__main__":
    main()
