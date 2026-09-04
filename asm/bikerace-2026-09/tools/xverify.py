#!/usr/bin/env python3
"""xverify.py -- cross-verification of a dasmxx baseline disassembly.

Compares a dasmxx listing against independent decoders over every *code*
region named in the dasmxx command file that produced the listing. No
second-opinion decoder ever sees the listing; each re-decodes the same
region of the same ROM image from scratch, so agreement is real
triangulation, not one tool checking its own homework.

Two architectures are supported, each with its own decoder set:

    --arch x86   dasmx86  vs  capstone (16-bit mode)  vs  ndisasm -b16
    --arch z80   dasmz80  vs  unidasm -arch z80

Comparison key per instruction: (address, instruction length, canonical
mnemonic). Operand text is deliberately NOT compared -- the tools format
operands too differently (register names, `word ptr` vs nothing, `{label}`
annotations, immediate radix) for that to be a meaningful check.
Canonicalisation strips a leading segment-override/rep/lock prefix token (if
the decoder folded it into the mnemonic text) and applies a small, justified
per-architecture ALIAS table for same-opcode spelling differences (jz/je,
lcall/call, ...); see reports/xverify_80188.md and reports/xverify_z80.md
for the per-entry justification.

Unlike this baseline's earlier capstone-only crosscheck.py (now folded into
this tool), a dasmxx instruction with no counterpart at the same address in
another decoder's decode of the same bytes is not silently skipped -- it is
counted and reported as a desync, and any nonzero skip count fails the run.
Likewise an address where another decoder decoded an instruction that dasmxx
did not (i.e. it drew a boundary dasmxx didn't) is counted as an "extra" and
also fails the run.

Usage:
    python3 xverify.py --arch x86 \\
        --regions asm/baseline-2026-09/iomoon_80188.cmd \\
        --lst     asm/baseline-2026-09/iomoon_80188.lst \\
        --bin     "roms/1.3 IPDB latest/V1 3_01.bin" \\
        --base    0x80000

    python3 xverify.py --arch z80 \\
        --regions asm/baseline-2026-09/iomoon_z80.cmd \\
        --lst     asm/baseline-2026-09/iomoon_z80.lst \\
        --bin     "roms/1.3 IPDB latest/V1 3_05.bin" \\
        --base    0x0

Exit status 0 means every code region agrees across every decoder, with zero
skips and zero extras. Exit status 1 means at least one region disagreed or
desynchronised; the offending addresses are printed by name.
"""
import argparse
import re
import subprocess
import sys
from collections import Counter

import os
import tempfile

try:
    from capstone import Cs, CS_ARCH_X86, CS_MODE_16
except ImportError:                                     # pragma: no cover
    Cs = None                                           # only --arch x86 needs it

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
# These are x86 prefixes; the Z80 has no instruction prefix that any decoder
# folds into the mnemonic text, so main() swaps in an empty set for --arch z80
# rather than leaving x86 tokens in play against Z80 mnemonics.
PREFIX_TOKENS_X86 = {"lock", "rep", "repe", "repz", "repne", "repnz",
                     "cs", "ds", "es", "ss", "fs", "gs"}
PREFIX_TOKENS_Z80 = set()

# Set by main() before any comparison runs.
PREFIX_TOKENS = PREFIX_TOKENS_X86

# variant spelling (lower-case) -> canonical spelling (dasmxx's own, lower-
# cased). Every entry exists because a real instance was observed to differ
# during this baseline's verification; see reports/xverify_80188.md for the
# opcode-level justification of each one. This is deliberately NOT a
# generic x86-mnemonic-alias table -- an alias that isn't needed to explain
# an observed difference does not belong here.
ALIAS_X86 = {
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


# The Z80 equivalent -- deliberately empty. Over the 4760 instructions of the
# Z80 baseline, dasmz80 and unidasm spell every mnemonic identically, so no
# alias is *needed* to explain an observed difference, and by the same rule
# that governs ALIAS_X86 above none is added. Leaving the table here (rather
# than special-casing its absence) keeps canon() single-path and gives a
# future disagreement somewhere obvious to be recorded.
ALIAS_Z80 = {}

# Set by main() before any comparison runs.
ALIAS = ALIAS_X86


def canon(text):
    """First non-prefix token of an instruction's mnemonic(+operand) text,
    lower-cased and passed through the active architecture's ALIAS."""
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
                # dasmxx accepts "bADDR" and "bADDR,N"; the count only bounds the
                # dump, it does not change where the data span starts.
                boundaries.append((int(rest.split(",")[0], 16), "data", None))
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

# dasmx86 prints two different line shapes at this indentation:
#
#   an instruction row:   D0022:    9A B9 00 00 D0             CALL     0D000:000B9 {boot_pcs_and_queue_init}
#   a data byte-dump row: C0000:    DB      FF, FF, FF, ...      ................
#
# They are NOT safely distinguishable by running one shared regex and then
# checking "is the mnemonic field == DB": `D` and `B` are themselves valid
# hex digits, so LST_LINE_RE's byte-list group `(?:[0-9A-F]{2} )+` happily
# eats "DB " as if it were one raw instruction byte, leaving group(3) to
# land on the pseudo-op's first *value* (e.g. "FF,") instead of on the
# literal string "DB" -- so `mnem == "DB"` never fires. This was a real,
# confirmed bug (see reports/xverify_80188.md): harmless only because every
# DB row in this baseline sits inside a 'b'-opened span that
# parse_cmd_regions() already excludes from the regions list, so the
# mis-parsed entries just never get looked up. Fixed by recognising the
# byte-dump row's own distinct, unambiguous shape (comma-separated values,
# not dasm86's usual single-space-separated instruction byte list) BEFORE
# ever trying the instruction regex, instead of trying to tell the two
# apart after the fact.
#
# The discriminator is dasmxx's own fixed-width pseudo-op field: every data
# row is printed with `printf("DB      ")` -- literally DB followed by six
# spaces (dasmxx.c lines 917/986/1214/1282) -- whereas an instruction whose
# first raw byte happens to be 0xDB prints it in the byte list, so exactly
# one space follows. Matching `DB` + whitespace alone is NOT enough, and on
# the Z80 that is not a theoretical worry: `DB nn` is `IN A,(nn)`, so a
# whitespace-only test silently dropped all 36 `IN A,(port)` instructions in
# the Z80 listing (they then surfaced as unidasm "extras", which is how this
# was caught).
LST_DB_LINE_RE = re.compile(r"^\s{4}[0-9A-F]+:\s{4}DB {6}")
LST_LINE_RE = re.compile(
    r"^\s{4}([0-9A-F]+):\s{4}((?:[0-9A-F]{2} )+)\s*(\S+)\s*(.*?)\s*$")


def parse_lst(lst_path):
    """addr -> (bytes:list[str-hex], mnemonic:str, operands:str)."""
    insns = {}
    with open(lst_path) as fh:
        for lineno, raw in enumerate(fh, 1):
            line = raw.rstrip("\n")
            if LST_DB_LINE_RE.match(line):
                continue  # byte-dump / data line, not an instruction
            m = LST_LINE_RE.match(line)
            if not m:
                continue
            mnem = m.group(3)
            if mnem == "DB":
                continue  # defense in depth; LST_DB_LINE_RE above should
                          # already have caught every real DB row
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


# ---------------------------------------------------------------------------
# unidasm decode (the --arch z80 second opinion)
# ---------------------------------------------------------------------------

# unidasm prints "0400: f3        di" / "0403: 31 ff c7  ld   sp,$C7FF":
# lower-case address, colon, the raw bytes space-separated, then the
# instruction text.
UNIDASM_LINE_RE = re.compile(
    r"^([0-9a-f]+): ((?:[0-9a-f]{2} )*[0-9a-f]{2})\s+(.*?)\s*$")


def unidasm_decode(blob, addr, end, unidasm_bin="unidasm", arch="z80"):
    """Run unidasm over one region's raw bytes.

    unidasm reads a file rather than stdin, so the region's bytes are written
    to a temporary file; `-basepc` then makes its printed addresses line up
    with the listing's directly. It decodes whole instructions, so the last
    one can reach past `-count` bytes -- anything at or beyond `end` is
    dropped, exactly as the dasmxx side drops an instruction that straddles
    the region boundary.
    """
    with tempfile.NamedTemporaryFile(suffix=".bin", delete=False) as fh:
        fh.write(blob)
        name = fh.name
    try:
        res = subprocess.run(
            [unidasm_bin, name, "-arch", arch,
             "-basepc", "0x%X" % addr, "-count", "%d" % len(blob)],
            capture_output=True)
        if res.returncode != 0:
            raise RuntimeError("unidasm failed (exit %d) at region %05X: %s"
                                % (res.returncode, addr,
                                   res.stderr[-500:].decode("latin1")))
        out = {}
        for lineno, raw in enumerate(
                res.stdout.decode("latin1").splitlines(), 1):
            if not raw.strip():
                continue
            m = UNIDASM_LINE_RE.match(raw)
            if not m:
                raise RuntimeError(
                    "unidasm: unparsed output line at region %05X:%d: %r"
                    % (addr, lineno, raw))
            a = int(m.group(1), 16)
            if a >= end:
                continue
            out[a] = (len(m.group(2).split()), canon(m.group(3)))
        return out
    finally:
        os.unlink(name)


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


# First opcode byte of every 80186-only encoding (absent on the plain
# 8086/8088 the 8086-era x86 instruction set otherwise targets). Ported
# verbatim from this baseline's earlier crosscheck.py, which counted these
# per full rebuild so a future baseline drift (a region gaining/losing an
# 80186-only instruction) would be caught automatically rather than only
# once, by hand, in reports/186scan.md (Task 3's one-time snapshot). Folding
# crosscheck.py into xverify.py without carrying this over would have quietly
# dropped that self-check from tools/rebuild.sh's pipeline.
ONLY186_FIRST = {0x60, 0x61, 0x62, 0x68, 0x69, 0x6A, 0x6B,
                 0x6C, 0x6D, 0x6E, 0x6F, 0xC0, 0xC1, 0xC8, 0xC9}
# ---------------------------------------------------------------------------
# Comparison
# ---------------------------------------------------------------------------

class Decoder:
    """One second-opinion decoder.

    `decode(rom, base, start, end, gaps)` returns {addr: (length, canonical
    mnemonic)} for the code region [start, end).  `known_gap(byts)`, when
    present, marks an instruction this decoder is known to be unable to
    decode; those addresses are excluded from its comparison and counted
    separately instead of being reported as disagreements.
    """

    def __init__(self, name, decode, known_gap=None):
        self.name = name
        self.decode = decode
        self.known_gap = known_gap


class Stats:
    def __init__(self, names):
        self.names = names
        self.compared = 0
        self.skip = {n: [] for n in names}       # dasmxx addr the decoder did not produce
        self.extra = {n: [] for n in names}      # decoder addr absent from dasmxx
        self.mismatch = {n: [] for n in names}   # (addr, kind) the two disagree on
        self.pairs = {n: Counter() for n in names}
        self.known_gap = {n: [] for n in names}  # excluded; see Decoder.known_gap
        self.only186 = Counter()  # (first byte hex, dasmxx mnemonic) -> occurrences

    def failed(self):
        return any(self.skip[n] or self.extra[n] or self.mismatch[n]
                   for n in self.names)


def verify_region(rom, base, start, end, dasm_insns, decoders, stats,
                  count186):
    decoded, gapsets = {}, {}
    for d in decoders:
        gaps = sorted(
            addr for addr, (byts, mnem, ops) in dasm_insns.items()
            if start <= addr < end and d.known_gap and d.known_gap(byts))
        gapsets[d.name] = set(gaps)
        decoded[d.name] = d.decode(rom, base, start, end, gaps)

    region_dasm_addrs = set()
    for addr, (byts, mnem, ops) in sorted(dasm_insns.items()):
        if not (start <= addr < end):
            continue
        if addr + len(byts) > end:
            continue  # instruction straddles the region boundary; not this region's to judge
        region_dasm_addrs.add(addr)
        stats.compared += 1
        d_len, d_mn = len(byts), canon(mnem + " " + ops)

        if count186 and byts and int(byts[0], 16) in ONLY186_FIRST:
            stats.only186[(byts[0], mnem)] += 1

        for d in decoders:
            if addr in gapsets[d.name]:
                stats.known_gap[d.name].append(addr)
                continue
            got = decoded[d.name].get(addr)
            if got is None:
                stats.skip[d.name].append(addr)
                continue
            g_len, g_mn = got
            if g_len != d_len or g_mn != d_mn:
                stats.mismatch[d.name].append(
                    (addr, "len" if g_len != d_len else "mnem"))
                stats.pairs[d.name][(d_mn, g_mn)] += 1

    for d in decoders:
        for addr in decoded[d.name]:
            if start <= addr < end and addr not in region_dasm_addrs:
                stats.extra[d.name].append(addr)


def build_decoders(arch, args):
    """The second-opinion decoders for one architecture."""
    if arch == "x86":
        if Cs is None:
            print("xverify.py: --arch x86 needs the 'capstone' python module "
                  "(pip install capstone)", file=sys.stderr)
            sys.exit(2)
        return [
            Decoder("capstone",
                    lambda rom, base, start, end, gaps:
                        capstone_decode(rom[start - base:end - base], start)),
            Decoder("ndisasm",
                    lambda rom, base, start, end, gaps:
                        ndisasm_decode_region(rom, base, start, end, gaps,
                                              args.ndisasm),
                    known_gap=is_ndisasm_known_gap),
        ]
    return [
        Decoder("unidasm",
                lambda rom, base, start, end, gaps:
                    unidasm_decode(rom[start - base:end - base], start, end,
                                   args.unidasm)),
    ]


def main():
    global ALIAS, PREFIX_TOKENS
    ap = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    ap.add_argument("--arch", required=True, choices=["x86", "z80"],
                     help="x86: dasmx86 vs capstone vs ndisasm.  "
                          "z80: dasmz80 vs unidasm -arch z80")
    ap.add_argument("--regions", required=True, metavar="CMDFILE",
                     help="dasmxx command file (region source of truth)")
    ap.add_argument("--lst", required=True, metavar="LSTFILE",
                     help="dasmxx listing produced from CMDFILE")
    ap.add_argument("--bin", required=True, metavar="ROM",
                     help="raw ROM image the listing was disassembled from")
    ap.add_argument("--base", required=True,
                     help="flat address of file offset 0, e.g. 0x80000")
    ap.add_argument("--ndisasm", default="ndisasm",
                     help="ndisasm binary to invoke (--arch x86 only)")
    ap.add_argument("--unidasm", default="unidasm",
                     help="unidasm binary to invoke (--arch z80 only)")
    ap.add_argument("--max-examples", type=int, default=25,
                     help="max disagreement/skip/extra examples to print per category")
    args = ap.parse_args()

    dasm = "dasmx86" if args.arch == "x86" else "dasmz80"
    ALIAS = ALIAS_X86 if args.arch == "x86" else ALIAS_Z80
    PREFIX_TOKENS = (PREFIX_TOKENS_X86 if args.arch == "x86"
                     else PREFIX_TOKENS_Z80)
    afmt = "%05X" if args.arch == "x86" else "%04X"

    base = int(args.base, 0)
    regions = parse_cmd_regions(args.regions)
    dasm_insns = parse_lst(args.lst)
    with open(args.bin, "rb") as fh:
        rom = fh.read()

    decoders = build_decoders(args.arch, args)
    stats = Stats([d.name for d in decoders])
    for start, end, _label in regions:
        verify_region(rom, base, start, end, dasm_insns, decoders, stats,
                      count186=(args.arch == "x86"))

    code_bytes = sum(e - s for s, e, _ in regions)
    print("regions: %d   code bytes: %d" % (len(regions), code_bytes))
    print("instructions compared: %d" % stats.compared)
    print()
    for d in decoders:
        print("%s addr missing from %s decode (skip_%s): %d"
              % (dasm, d.name, d.name, len(stats.skip[d.name])))
    for d in decoders:
        print("%s addr with no %s counterpart (extra_%s): %d"
              % (d.name, dasm, d.name, len(stats.extra[d.name])))
    for d in decoders:
        print("%s vs %s disagreements (length or mnemonic): %d"
              % (dasm, d.name, len(stats.mismatch[d.name])))
    for d in decoders:
        if d.known_gap:
            print("excluded from the %s comparison -- confirmed %s decoder "
                  "gap, see is_%s_known_gap: %d"
                  % (d.name, d.name, d.name, len(stats.known_gap[d.name])))

    def show(title, addrs):
        if not addrs:
            return
        print("\n%s (%d, first %d):" % (title, len(addrs), args.max_examples))
        for addr in addrs[:args.max_examples]:
            print("  " + afmt % addr)

    for d in decoders:
        show("skip_" + d.name, stats.skip[d.name])
    for d in decoders:
        show("extra_" + d.name, stats.extra[d.name])
    for d in decoders:
        if d.known_gap:
            show("%s_known_gap (FF /2 or /4, register operand -- see "
                 "docstring)" % d.name, stats.known_gap[d.name])

    def show_mismatch(title, mismatches):
        if not mismatches:
            return
        print("\n%s (%d, first %d):" % (title, len(mismatches), args.max_examples))
        for addr, kind in mismatches[:args.max_examples]:
            byts, mnem, ops = dasm_insns[addr]
            print(("  " + afmt + "  %-4s  %s=%-8s %-20s  bytes=%s")
                  % (addr, kind, dasm, mnem, ops, " ".join(byts)))

    for d in decoders:
        show_mismatch("%s vs %s disagreements" % (dasm, d.name),
                      stats.mismatch[d.name])

    for d in decoders:
        if stats.pairs[d.name]:
            print("\n%s/%s mnemonic pairs seen in disagreements:" % (dasm, d.name),
                  sorted(stats.pairs[d.name].items(), key=lambda kv: -kv[1]))

    if args.arch == "x86":
        print("\n80186-only encodings inside decoded code:")
        for (op, mnem), n in sorted(stats.only186.items()):
            print("  %-4s %-8s %d" % (op, mnem, n))

    if stats.failed():
        print("\nFAIL: cross-verification found disagreements or desyncs "
              "(see addresses above)")
        return 1
    print("\nOK: %s and %s agree on every instruction in every region; "
          "zero skips, zero extras"
          % (dasm, " and ".join(d.name for d in decoders)))
    return 0


if __name__ == "__main__":
    sys.exit(main())
