#!/usr/bin/env python3
"""grow.py -- iterative code-region growth driver for the IO Moon 80188 baseline.

The disassembler is always dasmx86 (dasmxx).  This script only orchestrates
it and parses its output:

  1. read the seed entry points from `entries.txt`
  2. for every entry, run dasmx86 over a generous window starting at the
     entry and parse the resulting listing to find where the routine ends
     (linear sweep, extended over forward branches, terminated by the first
     RET/RETF/IRET/unconditional-JMP that nothing branches past)
  3. merge the resulting spans into code regions
  4. emit the master command file and run dasmx86 -x over the whole
     CPU-visible ROM window
  5. parse the listing for CALL/JMP targets that fall outside the known
     regions and report them as candidates for the next round

Addresses everywhere are FLAT 80188 addresses.  ROM1 sits at 0x80000-0xFFFFF
(file offset = linear - 0x80000); the 80188 only decodes 0xC0000-0xFFFFF of
it through UMCS, and that is the window the baseline listing covers.

Usage:
    python3 grow.py candidates      # steps 1-5, print new call/jmp targets
    python3 grow.py emit            # steps 1-4, write iomoon_80188.cmd/.lst
    python3 grow.py extent <hex>    # show the computed extent of one entry
"""
import os
import re
import subprocess
import sys
import tempfile

HERE = os.path.dirname(os.path.abspath(__file__))
BASE = os.path.abspath(os.path.join(HERE, ".."))
REPO = os.path.abspath(os.path.join(BASE, "..", ".."))
# --- Bike Race parameterisation ------------------------------------------
# Which of the two Bike Race 80188 code ROMs this run analyses is chosen by
# BK_SET: "parent" (bkcpu04, the working 1992/94 set) or "v41" (bk04, V4.1).
# Everything else follows from it.  Both chips are 128 KB and both are mapped
# by UMCS over 0xE0000-0xFFFFF, so file offset = linear - 0xE0000.
SET = os.environ.get("BK_SET", "v41")
_ROMS = {
    "parent": ("roms/related-machines/bike-race/bkcpu04.bin", "bkcpu04"),
    "v41":    ("roms/related-machines/bike-race/v4.1/bk04.bin", "bk04"),
}
if SET not in _ROMS:
    raise SystemExit("BK_SET must be one of %s" % ", ".join(sorted(_ROMS)))
ROM_REL, STEM = _ROMS[SET]
ROM = os.path.join(REPO, *ROM_REL.split("/"))
DASM = os.environ.get("BK_DASM", "/code/dasmxx/src/dasmx86")

ROM1_BASE = 0xE0000          # flat address of the code ROM's file offset 0
CODE_LO = 0xE0000            # UMCS window, start
CODE_HI = 0x100000           # UMCS window, end (exclusive)

BASE = os.path.join(BASE, SET)
ENTRIES = os.path.join(BASE, "entries.txt")
LABELS = os.path.join(BASE, "labels.txt")
# Addresses proven NOT to be code, so that a discovery channel which seeds
# them (pushptr cannot tell a far string pointer from a far code pointer)
# does not keep re-adding them on every pass.  See tools/strptr.py.
NOTCODE = os.path.join(BASE, "notcode.txt")
# Spans of DATA that sit INSIDE a code region -- far pointers the code loads out
# of its own code segment with LES.  Carved out so they are dumped as bytes
# rather than decoded; left as code they are the only thing the cross-verifier
# can still disagree about.  Lines: "<lo> <hi> # why".
CSDATA = os.path.join(BASE, "csdata.txt")
CMD = os.path.join(BASE, "%s.cmd" % STEM)
LST = os.path.join(BASE, "%s.lst" % STEM)

MAX_WINDOW = 0x3000          # biggest routine we will chase in one sweep

# Instructions after which control does not fall through.
TERMINATORS = ("RETN", "RETF", "IRET", "JMP")
# Instructions whose target continues the *same* routine.
BRANCHES = ("JMP", "JO", "JNO", "JB", "JNB", "JE", "JNE", "JBE", "JNBE",
            "JS", "JNS", "JP", "JNP", "JL", "JNL", "JLE", "JNLE",
            "LOOP", "LOOPZ", "LOOPNZ", "JCXZ")

LINE_RE = re.compile(
    r"^\s{4}([0-9A-F]+):\s{4}((?:[0-9A-F]{2} )+)\s*(\S+)\s*(.*?)\s*$")


def parse_labels():
    """labels.txt: '<linear-hex> <label> # note' -- hand-given names that
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


def parse_notcode():
    """notcode.txt: one linear hex address per line, optionally '# why'."""
    out = set()
    if not os.path.exists(NOTCODE):
        return out
    for raw in open(NOTCODE):
        line = raw.split("#")[0].strip()
        if line:
            out.add(int(line.split()[0], 16))
    return out


def parse_csdata():
    """csdata.txt: '<lo-hex> <hi-hex> # why' -- half-open [lo, hi) data spans."""
    out = []
    if not os.path.exists(CSDATA):
        return out
    for raw in open(CSDATA):
        line = raw.split("#")[0].strip()
        if line:
            lo, hi = line.split()[:2]
            out.append((int(lo, 16), int(hi, 16)))
    return sorted(out)


def parse_entries():
    """entries.txt: '<linear-hex> <segment-hex> <label> # note'."""
    names = parse_labels()
    excluded = parse_notcode()
    out = []
    with open(ENTRIES) as fh:
        for raw in fh:
            line = raw.split("#")[0].strip()
            if not line:
                continue
            parts = line.split(None, 2)
            addr = int(parts[0], 16)
            if addr in excluded:
                continue
            seg = int(parts[1], 16)
            label = parts[2].strip() if len(parts) > 2 else "sub_%05X" % addr
            out.append((addr, seg, names.get(addr, label)))
    out.sort()
    return out


def run_dasm(cmdlines, xref=False):
    with tempfile.NamedTemporaryFile("w", suffix=".dx86", delete=False) as fh:
        fh.write("\n".join(cmdlines) + "\n")
        name = fh.name
    try:
        args = [DASM]
        if xref:
            args.append("-x")
        args.append(name)
        res = subprocess.run(args, capture_output=True, text=True)
        if res.returncode != 0:
            raise RuntimeError(
                "dasmx86 failed (exit %d) on:\n%s\n%s"
                % (res.returncode, "\n".join(cmdlines[:8]), res.stderr[-500:]))
        return res.stdout
    finally:
        os.unlink(name)


def disasm_window(start, seg, length):
    """Return [(addr, bytes, mnemonic, operands)] for one linear window."""
    txt = run_dasm([
        "f%s" % ROM,
        ">%X" % (start - ROM1_BASE),
        "g%X" % (seg << 4),
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


def branch_target(mnem, ops):
    """Flat target of a near branch, or None."""
    if mnem not in BRANCHES:
        return None
    if ":" in ops:          # far jump - leaves the routine
        return None
    m = re.match(r"^0([0-9A-F]+)$", ops.strip())
    if not m:
        return None         # register/indirect
    return int(m.group(1), 16)


def compute_extent(start, seg, window=MAX_WINDOW):
    """Linear sweep from `start`, extended over forward branches, until a
    terminator that no in-region branch jumps past.  Returns (end, notes)."""
    # dasmxx errors out if a code region's end lands exactly on EOF, so
    # stop one byte short of the top of the ROM image.
    window = min(window, CODE_HI - 1 - start)
    insns = disasm_window(start, seg, window)
    reach = start
    notes = []
    for i, (addr, byts, mnem, ops) in enumerate(insns):
        nxt = addr + len(byts)
        tgt = branch_target(mnem, ops)
        if tgt is not None and start <= tgt < start + window and tgt > reach:
            reach = tgt
        if mnem in TERMINATORS or (mnem == "JMP" and ":" in ops):
            if nxt > reach:
                return nxt, notes
        if mnem == "???":
            notes.append("undecodable byte at %05X" % addr)
    notes.append("no terminator within %X bytes" % window)
    return start + window, notes


def merge(spans):
    """spans: [(start, end, seg)] -> non-overlapping, segment-tagged list.

    Two spans are merged only when they carry the same CS value; when spans
    from different segments overlap, the earlier one is truncated at the
    later one's start so the 'g' command always describes the code that
    follows it.
    """
    spans = sorted(spans)
    out = []
    for s, e, seg in spans:
        if out and seg == out[-1][2] and s <= out[-1][1]:
            out[-1][1] = max(out[-1][1], e)
        elif out and s < out[-1][1]:
            if s > out[-1][0]:
                out[-1][1] = s
                out.append([s, e, seg])
            else:                       # identical start, different CS
                out.append([s, e, seg])
        else:
            out.append([s, e, seg])
    return out


def build_regions():
    entries = parse_entries()
    spans = []
    diag = []
    for addr, seg, label in entries:
        end, notes = compute_extent(addr, seg)
        spans.append((addr, end, seg))
        diag.append((addr, seg, label, end, notes))
    return entries, merge(spans), diag


def emit_cmd(entries, regions):
    csdata = parse_csdata()
    lines = []
    lines.append("# Bike Race (SLEIC) -- 80188 game/sound ROM, %s set" % SET)
    lines.append("# Generated by asm/bikerace-2026-09/tools/grow.py -- do not hand-edit;")
    lines.append("# edit asm/bikerace-2026-09/%s/entries.txt and re-run instead." % SET)
    lines.append("#")
    lines.append("# Listing addresses are FLAT 80188 addresses.  The 128 KB code ROM is")
    lines.append("# mapped by UMCS over 0xE0000-0xFFFFF (file offset = linear - 0xE0000),")
    lines.append("# and that whole window is what is listed.")
    lines.append("#")
    lines.append("# Run dasmx86 from the repository root: the input path below is")
    lines.append("# resolved against the current working directory.")
    lines.append("f%s" % ROM_REL)
    lines.append(">%X" % (CODE_LO - ROM1_BASE))
    cur = CODE_LO
    for start, end, seg in regions:
        if start > cur:
            lines.append("b%X" % cur)
        lines.append("g%X" % (seg << 4))
        head = [l for a, s, l in entries if a == start]
        for addr, esg, label in entries:
            if start < addr < end:
                lines.append("l%X\t%s" % (addr, label))
        # Split the region around any data span that falls inside it.
        pos = start
        first = True
        for dlo, dhi in csdata:
            if not (start <= dlo < end):
                continue
            if pos < dlo:
                lines.append("c%X\t%s" % (pos, (head[0] if head else
                                                "code_%05X" % start) if first
                                          else "code_%05X" % pos))
                first = False
            lines.append("b%X,%d" % (dlo, min(dhi, end) - dlo))
            lines.append("g%X" % (seg << 4))
            pos = min(dhi, end)
        if pos < end:
            lines.append("c%X\t%s" % (pos, (head[0] if head else
                                             "code_%05X" % start) if first
                                       else "code_%05X" % pos))
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
    """Targets of CALL/JMP instructions inside decoded regions that do not
    themselves land inside a decoded region.

    The target list comes from dasmx86's own -x cross-reference dump, which
    records every X_CALL/X_JMP reference regardless of whether the listing
    printed the target as a number or as a label.  The listing is used only
    to recover the CS value each target runs under: explicit in the operand
    of a far CALL/JMP (opcode 9A/EA), inherited from the referring region
    otherwise.
    """
    inside = lambda a: any(s <= a < e for s, e, _ in regions)

    def seg_at(a):
        for s, e, g in regions:
            if s <= a < e:
                return g
        return (a >> 4) & 0xF000

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
        if byts and byts[0] in ("9A", "EA"):
            seg = int(byts[4] + byts[3], 16)
        else:
            seg = seg_at(src)
        flag = "" if CODE_LO <= tgt < CODE_HI else "OUT-OF-ROM"
        found.setdefault((tgt, seg), []).append((src, mnem, ops, flag))
    return found


def main():
    cmdname = sys.argv[1] if len(sys.argv) > 1 else "candidates"
    if cmdname == "extent":
        a = int(sys.argv[2], 16)
        seg = int(sys.argv[3], 16) if len(sys.argv) > 3 else (a >> 4) & 0xF000
        end, notes = compute_extent(a, seg)
        print("%05X..%05X  (%d bytes)  %s" % (a, end, end - a, "; ".join(notes)))
        return
    entries, regions, diag = build_regions()
    emit_cmd(entries, regions)
    if cmdname == "emit":
        txt = listing(with_xref=True)
        with open(LST, "w") as fh:
            fh.write(txt)
        cov = sum(e - s for s, e, _ in regions)
        print("regions: %d   code bytes: %d (%.1f%% of the %d-byte UMCS window)"
              % (len(regions), cov, 100.0 * cov / (CODE_HI - CODE_LO),
                 CODE_HI - CODE_LO))
        for addr, seg, label, end, notes in diag:
            if notes:
                print("  note %05X %-28s %s" % (addr, label, "; ".join(notes)))
        return
    txt = listing(with_xref=True)
    found = candidates(regions, txt)
    print("regions: %d   code bytes: %d" %
          (len(regions), sum(e - s for s, e, _ in regions)))
    print("new targets: %d" % len(found))
    for tgt, seg in sorted(found):
        refs = found[(tgt, seg)]
        flag = refs[0][3]
        print("  %05X CS=%04X %-11s refs=%-4d  first: %05X %s %s"
              % (tgt, seg, flag, len(refs), refs[0][0], refs[0][1], refs[0][2]))
    if cmdname == "add" and found:
        with open(ENTRIES, "a") as fh:
            fh.write("\n# --- round %s: %d targets reached by CALL/JMP from"
                     " already-decoded code\n" % (sys.argv[2], len(found)))
            for tgt, seg in sorted(found):
                if not (CODE_LO <= tgt < CODE_HI):
                    continue
                refs = found[(tgt, seg)]
                fh.write("%05X  %04X  sub_%05X  # %s from %05X%s\n"
                         % (tgt, seg, tgt, refs[0][1], refs[0][0],
                            "" if len(refs) == 1 else
                            " (+%d more)" % (len(refs) - 1)))
        print("appended to entries.txt")


if __name__ == "__main__":
    main()
