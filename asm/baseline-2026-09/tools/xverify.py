#!/usr/bin/env python3
"""xverify.py -- three-way cross-verification of an x86 baseline disassembly.

Compares a dasmxx (`dasmx86`) listing against two independent decoders --
capstone and ndisasm -- over every *code* region named in the dasmxx command
file that produced the listing. Neither capstone nor ndisasm ever sees the
listing; both re-decode the same region of the same ROM image from scratch,
so agreement of all three is real triangulation, not one tool checking its
own homework.

Comparison key per instruction: (address, instruction length, canonical
mnemonic). Operand text is deliberately NOT compared -- the three tools
format operands too differently (register names, `word ptr` vs nothing,
`{label}` annotations, immediate radix) for that to be a meaningful check.
Canonicalisation strips a leading segment-override/rep/lock prefix token (if
the decoder folded it into the mnemonic text) and applies a small, justified
ALIAS table for same-opcode spelling differences (jz/je, lcall/call, ...);
see reports/xverify_80188.md for the per-entry justification.

Unlike this baseline's earlier capstone-only crosscheck.py (now folded into
this tool), a dasmxx instruction with no counterpart at the same address in
capstone's or ndisasm's decode of the same bytes is not silently skipped --
it is counted and reported as a desync, and any nonzero skip count fails
the run. Likewise an address where capstone or ndisasm decoded an
instruction that dasmxx did not (i.e. the other decoder drew a boundary
dasmxx didn't) is counted as an "extra" and also fails the run.

Usage:
    python3 xverify.py --arch x86 \\
        --regions asm/baseline-2026-09/iomoon_80188.cmd \\
        --lst     asm/baseline-2026-09/iomoon_80188.lst \\
        --bin     "roms/1.3 IPDB latest/V1 3_01.bin" \\
        --base    0x80000

Exit status 0 means every code region agrees across all three decoders,
with zero skips and zero extras. Exit status 1 means at least one region
disagreed or desynchronised; the offending addresses are printed by name.
"""
import argparse
import re
import subprocess
import sys
from collections import Counter

try:
    from capstone import Cs, CS_ARCH_X86, CS_MODE_16
except ImportError:
    print("xverify.py: the 'capstone' python module is required "
          "(pip install capstone)", file=sys.stderr)
    sys.exit(2)

# ---------------------------------------------------------------------------
# Mnemonic canonicalisation
# ---------------------------------------------------------------------------

# A decoder sometimes folds a segment-override / REP / LOCK prefix into the
# front of its mnemonic text (ndisasm: "cs lodsw"; capstone: "rep movsw").
# Strip a run of these before taking the real mnemonic, so all three
# decoders are compared on the same word regardless of where each one draws
# the prefix/mnemonic boundary. dasmxx never does this (its own mnemonic
# field is already bare -- see reports/xverify_80188.md), so stripping is a
# no-op there; applying it uniformly keeps the logic single-path.
PREFIX_TOKENS = {"lock", "rep", "repe", "repz", "repne", "repnz",
                  "cs", "ds", "es", "ss", "fs", "gs"}

# variant spelling (lower-case) -> canonical spelling (dasmxx's own, lower-
# cased). Every entry exists because a real instance was observed to differ
# during this baseline's verification; see reports/xverify_80188.md for the
# opcode-level justification of each one. This is deliberately NOT a
# generic x86-mnemonic-alias table -- an alias that isn't needed to explain
# an observed difference does not belong here.
ALIAS = {
    "lcall": "call",   # capstone's name for far CALL (9A, or FF /3 through memory); dasmxx and ndisasm both say call
    "ljmp":  "jmp",    # capstone's name for far JMP (EA, or FF /5 through memory); dasmxx and ndisasm both say jmp
    "ret":   "retn",   # capstone's and ndisasm's name for near RET (C2/C3); dasmxx says retn
    "cwde":  "cbw",    # capstone's 32-bit name for opcode 0x98 even in 16-bit mode; dasmxx/ndisasm say cbw
    "cdq":   "cwd",    # capstone's 32-bit name for opcode 0x99 even in 16-bit mode; dasmxx/ndisasm say cwd
    "jc":    "jb",     # ndisasm's name for opcode 0x72 (jump-if-carry == jump-if-below)
    "jna":   "jbe",    # ndisasm's name for opcode 0x76 (jump-if-not-above == jump-if-below-or-equal)
    "jz":    "je",     # ndisasm's name for opcode 0x74 (jump-if-zero == jump-if-equal)
    "jnz":   "jne",    # ndisasm's name for opcode 0x75
    "jng":   "jle",    # ndisasm's name for opcode 0x7E (jump-if-not-greater == jump-if-less-or-equal)
    "jae":   "jnb",    # capstone's name for opcode 0x73 (jump-if-above-or-equal == jump-if-not-below)
    "jnc":   "jnb",    # ndisasm's name for the same opcode 0x73 (jump-if-not-carry == jump-if-not-below)
    "ja":    "jnbe",   # capstone's AND ndisasm's name for opcode 0x77 (jump-if-above == jump-if-not-below-or-equal)
    "jge":   "jnl",    # capstone's name for opcode 0x7D (jump-if-greater-or-equal == jump-if-not-less)
    "jg":    "jnle",   # capstone's AND ndisasm's name for opcode 0x7F (jump-if-greater == jump-if-not-less-or-equal)
}


def canon(text):
    """First non-prefix token of an instruction's mnemonic(+operand) text,
    lower-cased and passed through ALIAS."""
    tokens = text.split()
    i = 0
    while i < len(tokens) and tokens[i].lower() in PREFIX_TOKENS:
        i += 1
    mnem = tokens[i].lower() if i < len(tokens) else ""
    return ALIAS.get(mnem, mnem)


# ---------------------------------------------------------------------------
# dasmxx command-file parsing -- code regions
# ---------------------------------------------------------------------------

def parse_cmd_regions(cmd_path):
    """Parse a dasmxx command file into (start, end, label) code regions.

    Only 'b' (byte/data dump) and 'c' (code) directives introduce address
    boundaries; 'g' (segment paragraph) and 'l' (in-region label) do not,
    and are irrelevant here besides -- x86 instruction *decoding* (length,
    mnemonic) does not depend on the segment a region runs under, only
    near-branch operand *text* would, and operand text is out of scope (see
    module docstring). The span from one boundary to the next (or to the
    final 'e' terminator) inherits the kind of directive that opened it.
    """
    boundaries = []  # (addr, kind, label) in file order
    with open(cmd_path) as fh:
        for raw in fh:
            line = raw.rstrip("\n")
            if not line or line.startswith("#"):
                continue
            tag, rest = line[0], line[1:]
            if tag in ("f", ">", "g", "l"):
                continue  # rom path / file-offset echo / segment / in-region label
            elif tag == "b":
                boundaries.append((int(rest, 16), "data", None))
            elif tag == "c":
                parts = rest.split("\t", 1)
                addr = int(parts[0], 16)
                label = parts[1] if len(parts) > 1 else "code_%05X" % addr
                boundaries.append((addr, "code", label))
            elif tag == "e":
                boundaries.append((int(rest, 16), "end", None))
            else:
                raise ValueError("%s: unrecognised directive: %r"
                                  % (cmd_path, line))

    if not boundaries:
        raise ValueError("%s: no directives found" % cmd_path)
    addrs = [a for a, _, _ in boundaries]
    if addrs != sorted(addrs):
        raise ValueError("%s: boundary addresses are not in non-decreasing "
                          "order -- command file is not well-formed" % cmd_path)

    regions = []
    for i in range(len(boundaries) - 1):
        start, kind, label = boundaries[i]
        end, _, _ = boundaries[i + 1]
        if kind == "code" and end > start:
            regions.append((start, end, label))
    return regions


# ---------------------------------------------------------------------------
# dasmxx listing parsing
# ---------------------------------------------------------------------------

# Matches a dasmx86 listing instruction line, e.g.:
#     D0000:    FA                         CLI
#     D0022:    9A B9 00 00 D0             CALL     0D000:000B9 {boot_pcs_and_queue_init}
LST_LINE_RE = re.compile(
    r"^\s{4}([0-9A-F]+):\s{4}((?:[0-9A-F]{2} )+)\s*(\S+)\s*(.*?)\s*$")


def parse_lst(lst_path):
    """addr -> (bytes:list[str-hex], mnemonic:str, operands:str)."""
    insns = {}
    with open(lst_path) as fh:
        for lineno, raw in enumerate(fh, 1):
            line = raw.rstrip("\n")
            m = LST_LINE_RE.match(line)
            if not m:
                continue
            mnem = m.group(3)
            if mnem == "DB":
                continue  # byte-dump / data line, not an instruction
            addr = int(m.group(1), 16)
            byts = m.group(2).split()
            ops = m.group(4)
            if addr in insns:
                raise ValueError("%s:%d: duplicate instruction address %05X"
                                  % (lst_path, lineno, addr))
            insns[addr] = (byts, mnem, ops)
    return insns


# ---------------------------------------------------------------------------
# capstone decode
# ---------------------------------------------------------------------------

def capstone_decode(blob, addr):
    md = Cs(CS_ARCH_X86, CS_MODE_16)
    md.skipdata = True
    return {i.address: (i.size, canon(i.mnemonic + " " + i.op_str))
            for i in md.disasm(blob, addr)}


# ---------------------------------------------------------------------------
# ndisasm decode
# ---------------------------------------------------------------------------

NDISASM_LINE_RE = re.compile(
    r"^([0-9A-Fa-f]{8})\s+([0-9A-Fa-f]+)\s+(.*)$")


def ndisasm_decode(blob, addr, ndisasm_bin="ndisasm"):
    """Run ndisasm over one region's raw bytes with -o<origin> so its
    printed addresses line up with dasmxx's flat addresses directly."""
    res = subprocess.run(
        [ndisasm_bin, "-b16", "-o", "0x%X" % addr, "-"],
        input=blob, capture_output=True)
    if res.returncode != 0:
        raise RuntimeError("ndisasm failed (exit %d) at region %05X: %s"
                            % (res.returncode, addr, res.stderr[-500:].decode(
                                "latin1")))
    out = {}
    for lineno, raw in enumerate(res.stdout.decode("latin1").splitlines(), 1):
        if not raw.strip():
            continue
        m = NDISASM_LINE_RE.match(raw)
        if not m:
            raise RuntimeError(
                "ndisasm: unparsed output line at region %05X:%d: %r"
                % (addr, lineno, raw))
        a = int(m.group(1), 16)
        length = len(m.group(2)) // 2
        out[a] = (length, canon(m.group(3)))
    return out


# ---------------------------------------------------------------------------
# A confirmed ndisasm 3.01 decoder gap
# ---------------------------------------------------------------------------

def is_ndisasm_known_gap(byts):
    """True if `byts` (a dasmxx instruction's raw hex-byte strings) is one
    of the two register-direct FF-group encodings ndisasm 3.01 cannot
    decode: FF /2 (CALL r/m16, mod=11 i.e. register operand) and FF /4
    (JMP r/m16, mod=11). Both are ordinary, common 8086 encodings --
    dasmxx and capstone both decode them correctly, agreeing with each
    other -- but ndisasm has no table entry for the *register*-operand form
    of this opcode group (its *memory*-operand form, e.g. `FF 16 xx xx` =
    `call [xx xx]`, decodes fine), and instead emits two bogus one-byte
    `db` lines and loses cursor sync for a few bytes afterward.

    Confirmed independent of this ROM by exhaustively probing `FF C0`..
    `FF FF` through ndisasm directly (see reports/xverify_80188.md); only
    reg field 2 and 4 with mod=11 fail, every other reg field (0 INC, 1
    DEC, 6 PUSH) and every mod!=11 (memory) form of reg 2/4 decodes fine.
    """
    if len(byts) != 2 or byts[0] != "FF":
        return False
    modrm = int(byts[1], 16)
    return (modrm & 0xC0) == 0xC0 and ((modrm >> 3) & 7) in (2, 4)


# ---------------------------------------------------------------------------
# Three-way comparison
# ---------------------------------------------------------------------------

class Stats:
    def __init__(self):
        self.compared = 0
        self.skip_capstone = []   # dasmxx addr with no capstone counterpart
        self.skip_ndisasm = []    # dasmxx addr with no ndisasm counterpart
        self.extra_capstone = []  # capstone addr inside a region, absent from dasmxx
        self.extra_ndisasm = []   # ndisasm addr inside a region, absent from dasmxx
        self.mismatch_capstone = []  # (addr, kind) dasmxx vs capstone disagree
        self.mismatch_ndisasm = []   # (addr, kind) dasmxx vs ndisasm disagree
        self.ndisasm_known_gap = []  # addr excluded from the ndisasm comparison; see is_ndisasm_known_gap
        self.pairs_capstone = Counter()
        self.pairs_ndisasm = Counter()

    def failed(self):
        return bool(self.skip_capstone or self.skip_ndisasm
                    or self.extra_capstone or self.extra_ndisasm
                    or self.mismatch_capstone or self.mismatch_ndisasm)


def ndisasm_decode_region(rom, base, start, end, gaps, ndisasm_bin):
    """Decode [start, end) with ndisasm, skipping over each known-gap
    address (exactly 2 bytes each -- see is_ndisasm_known_gap) by decoding
    the bytes around it as separate ndisasm invocations, each freshly
    originated at an address dasmxx (cross-checked by capstone) already
    established is a real instruction boundary. Feeding the gap bytes to
    ndisasm at all desyncs its cursor for a few bytes afterward, which would
    otherwise misreport every following instruction in the region as a
    disagreement instead of just the one address ndisasm actually can't
    decode.
    """
    nd = {}
    cursor = start
    for gap in gaps:
        if gap > cursor:
            nd.update(ndisasm_decode(rom[cursor - base:gap - base], cursor,
                                      ndisasm_bin))
        cursor = gap + 2  # both known-gap encodings are exactly 2 bytes
    if cursor < end:
        nd.update(ndisasm_decode(rom[cursor - base:end - base], cursor,
                                  ndisasm_bin))
    return nd


def verify_region(rom, base, start, end, dasm_insns, ndisasm_bin, stats):
    blob = rom[start - base:end - base]
    cap = capstone_decode(blob, start)

    gaps = sorted(
        addr for addr, (byts, mnem, ops) in dasm_insns.items()
        if start <= addr < end and is_ndisasm_known_gap(byts))
    gapset = set(gaps)
    nd = ndisasm_decode_region(rom, base, start, end, gaps, ndisasm_bin)

    region_dasm_addrs = set()
    for addr, (byts, mnem, ops) in sorted(dasm_insns.items()):
        if not (start <= addr < end):
            continue
        if addr + len(byts) > end:
            continue  # instruction straddles the region boundary; not this region's to judge
        region_dasm_addrs.add(addr)
        stats.compared += 1
        d_len, d_mn = len(byts), canon(mnem + " " + ops)

        c = cap.get(addr)
        if c is None:
            stats.skip_capstone.append(addr)
        else:
            c_len, c_mn = c
            if c_len != d_len or c_mn != d_mn:
                stats.mismatch_capstone.append((addr, "len" if c_len != d_len else "mnem"))
                stats.pairs_capstone[(d_mn, c_mn)] += 1

        if addr in gapset:
            stats.ndisasm_known_gap.append(addr)
            continue

        n = nd.get(addr)
        if n is None:
            stats.skip_ndisasm.append(addr)
        else:
            n_len, n_mn = n
            if n_len != d_len or n_mn != d_mn:
                stats.mismatch_ndisasm.append((addr, "len" if n_len != d_len else "mnem"))
                stats.pairs_ndisasm[(d_mn, n_mn)] += 1

    for addr in cap:
        if start <= addr < end and addr not in region_dasm_addrs:
            stats.extra_capstone.append(addr)
    for addr in nd:
        if start <= addr < end and addr not in region_dasm_addrs:
            stats.extra_ndisasm.append(addr)


def main():
    ap = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    ap.add_argument("--arch", required=True, choices=["x86"],
                     help="only x86 (dasmx86/capstone-x86/ndisasm) is implemented")
    ap.add_argument("--regions", required=True, metavar="CMDFILE",
                     help="dasmxx command file (region source of truth)")
    ap.add_argument("--lst", required=True, metavar="LSTFILE",
                     help="dasmx86 listing produced from CMDFILE")
    ap.add_argument("--bin", required=True, metavar="ROM",
                     help="raw ROM image the listing was disassembled from")
    ap.add_argument("--base", required=True,
                     help="flat address of file offset 0, e.g. 0x80000")
    ap.add_argument("--ndisasm", default="ndisasm",
                     help="ndisasm binary to invoke (default: ndisasm on PATH)")
    ap.add_argument("--max-examples", type=int, default=25,
                     help="max disagreement/skip/extra examples to print per category")
    args = ap.parse_args()

    base = int(args.base, 0)
    regions = parse_cmd_regions(args.regions)
    dasm_insns = parse_lst(args.lst)
    with open(args.bin, "rb") as fh:
        rom = fh.read()

    stats = Stats()
    for start, end, _label in regions:
        verify_region(rom, base, start, end, dasm_insns, args.ndisasm, stats)

    code_bytes = sum(e - s for s, e, _ in regions)
    print("regions: %d   code bytes: %d" % (len(regions), code_bytes))
    print("instructions compared: %d" % stats.compared)
    print()
    print("dasmx86 addr missing from capstone decode (skip_capstone): %d"
          % len(stats.skip_capstone))
    print("dasmx86 addr missing from ndisasm  decode (skip_ndisasm) : %d"
          % len(stats.skip_ndisasm))
    print("capstone addr with no dasmx86 counterpart (extra_capstone): %d"
          % len(stats.extra_capstone))
    print("ndisasm  addr with no dasmx86 counterpart (extra_ndisasm) : %d"
          % len(stats.extra_ndisasm))
    print("dasmx86 vs capstone disagreements (length or mnemonic): %d"
          % len(stats.mismatch_capstone))
    print("dasmx86 vs ndisasm  disagreements (length or mnemonic): %d"
          % len(stats.mismatch_ndisasm))
    print("excluded from the ndisasm comparison -- confirmed ndisasm 3.01 "
          "decoder gap, see is_ndisasm_known_gap: %d"
          % len(stats.ndisasm_known_gap))

    def show(title, addrs):
        if not addrs:
            return
        print("\n%s (%d, first %d):" % (title, len(addrs), args.max_examples))
        for addr in addrs[:args.max_examples]:
            print("  %05X" % addr)

    show("skip_capstone", stats.skip_capstone)
    show("skip_ndisasm", stats.skip_ndisasm)
    show("extra_capstone", stats.extra_capstone)
    show("extra_ndisasm", stats.extra_ndisasm)
    show("ndisasm_known_gap (FF /2 or /4, register operand -- see docstring)",
         stats.ndisasm_known_gap)

    def show_mismatch(title, mismatches):
        if not mismatches:
            return
        print("\n%s (%d, first %d):" % (title, len(mismatches), args.max_examples))
        for addr, kind in mismatches[:args.max_examples]:
            byts, mnem, ops = dasm_insns[addr]
            print("  %05X  %-4s  dasmx86=%-8s %-20s  bytes=%s"
                  % (addr, kind, mnem, ops, " ".join(byts)))

    show_mismatch("dasmx86 vs capstone disagreements", stats.mismatch_capstone)
    show_mismatch("dasmx86 vs ndisasm disagreements", stats.mismatch_ndisasm)

    if stats.pairs_capstone:
        print("\ndasmx86/capstone mnemonic pairs seen in disagreements:",
              sorted(stats.pairs_capstone.items(), key=lambda kv: -kv[1]))
    if stats.pairs_ndisasm:
        print("dasmx86/ndisasm mnemonic pairs seen in disagreements:",
              sorted(stats.pairs_ndisasm.items(), key=lambda kv: -kv[1]))

    if stats.failed():
        print("\nFAIL: cross-verification found disagreements or desyncs "
              "(see addresses above)")
        return 1
    print("\nOK: dasmx86, capstone and ndisasm agree on every instruction "
          "in every region; zero skips, zero extras")
    return 0


if __name__ == "__main__":
    sys.exit(main())
