#!/usr/bin/env python3
"""
SLEIC bitmap font-table finder and text-string extractor
==========================================================

Locates bitmap **font tables** in the ROMs of the three SLEIC pinball machines
(Sleic Pin-Ball, Bike Race, IO Moon), renders every glyph it finds as ASCII,
infers the index scheme, reports the code and data that reach the table - and,
having found a table, locates **every text string that draws from it**:
address (CPU and file), raw bytes, decoded text, byte/character length, which
face it uses and how that was determined, and the call sites that draw it
where those are findable.  See "Text-string cross-reference" below.

Usage:
    python3 scripts/find_font_tables.py <rom>[@org] ...
    python3 scripts/find_font_tables.py <rom>... --font <addr>   # one face, full string list

    python3 scripts/find_font_tables.py roms/related-machines/sleic-pin-ball/sp03-1_1.rom
    python3 scripts/find_font_tables.py "roms/1.3 IPDB latest/V1 3_01.bin"
    python3 scripts/find_font_tables.py roms/related-machines/bike-race/bkcpu0{4,5,6}.bin

Give every ROM of a machine on one command line: each table is cross-referenced
against *all* of them, which is what finds the pointers in the code ROM that
reach a font living on a graphics ROM, and what lets a Bike Race call site name
a string that lives in the graphics ROM rather than the code ROM it is in.
`--font <addr>` (a file offset, or any window's CPU-visible address, exactly as
printed under `FACE n`) narrows the whole report to one face and its full,
un-truncated string inventory - "given a font table, which strings use it".

`@org` overrides the flat address the image is mapped at. Without it the org is
taken from the 80188 reset vector (an image whose last 16 bytes start with `EA`
is a code ROM and sits at the top of the 1 MB space, so a 128 KB chip is at
`0xE0000` and a 512 KB chip at `0x80000`), and for a ROM with no reset vector
the org is **inferred from the far pointers in the other images**: the candidate
64 KB base whose pointers land on the most table-entry boundaries wins. That is
how `bkcpu05.bin` is placed at `0x40000` and `bkcpu06.bin` at `0x20000` without
being told.

What it looks for
-----------------

Two storage layouts, both of which really occur in this family:

* **packed** - a contiguous run of fixed-size cells, `height` bytes per glyph,
  one byte (8 px) per row, MSB leftmost, nothing between glyphs. No header
  anywhere, so the geometry has to be discovered. Sleic Pin-Ball's two faces are
  stored this way. The scan tries every cell height 5..26 and every phase, and
  scores each run of cells on glyph-likeness: ink density, a contiguous column
  footprint, ink in (nearly) every row, a blank margin column shared by every
  cell in the run, a small spread of glyph widths, and single-connected ink.
  Runs shorter than `--min-glyphs` are dropped, overlapping runs are resolved in
  favour of the higher score.

* **header3** - the self-describing entry format documented in
  `docs/dmd_graphics.md`: a 6-byte header `[height, 0x00, width, 0x00,
  len16_lo, len16_hi]` where `width` is **bytes** per row and `len16 ==
  height*width`, followed by three blocks of `len16` bytes (plane 0, plane 1,
  mask). Entry stride is `6 + 3*len16` and varies from entry to entry, so the
  table is a chain, not an array. Bike Race and IO Moon store every face this
  way. The scanner walks the chain from each valid header, then cuts the chain
  into **faces** - maximal runs of entries that share one `(height, width)`. A
  face is what has a fixed stride and can be indexed, and it is what this script
  reports.

Both scans are structural. Neither is told a height, a width, a glyph count or
an address.

Index scheme
------------

For every face the script fits an index scheme by measurement, not assumption.
It counts the enclosed holes of each glyph (Euler number: `8` and `B` have two,
`0 4 6 9 A D O P Q R` have one, everything else in this character set has none),
finds the blank cell, measures each glyph's ink width, and then scores every
possible anchor for four candidate layouts:

    digits, space, letters      digits, space, letters without Ñ
    digits only                 letters only

The winning fit is reported as, e.g., `index 0-9 = '0'-'9', 10 = space,
11.. = 'A'..'Z' with 'Ñ' at 25`, with a word saying how much weight it carries.

The `Ñ` question is decided **on pixels, not on holes**, and it is scored inside
the fit rather than reported after it: `Ñ` is its own `N` with a tilde added, so
the two bitmaps agree to within a few pixels over a 0-2 row shift, where an `O`
in the same position would not.  Hole counting cannot answer it - Pin-Ball's
8-row `Ñ` closes a counter and reads topologically as an `O` - and a layout that
fails the pixel test is penalised whichever way it guessed.  The numbers behind
the verdict are printed under the scheme line, together with the hole count of
the glyph after the candidate, which is `O` and should have one.

Usage cross-reference
---------------------

For each face, in every supplied image:

* **code that indexes it** - every 16-bit occurrence of the face's base offset
  is re-decoded with capstone (`CS_ARCH_X86`, `CS_MODE_16`) at the four possible
  instruction starts before it, and kept only if a real instruction frames it,
  which rejects the coincidental byte pairs. The following dozen instructions
  are then searched for the face's stride, so `mov si,<base>` ... `mul dx` with
  `dx = stride` is reported as `base + stride*index` at a named address.
* **data that points into it** - near 16-bit pointers whose value lands exactly
  on a glyph boundary, and far 32-bit pointers whose `(seg<<4)+off` lands exactly
  on an entry boundary. Consecutive near pointers are grouped into string
  records and **decoded to text** through the fitted index scheme, which is what
  turns a pointer array into `RECORD JUGADOR` on the screen.
* **indirection through a pointer pool** - when a far pointer to the face is
  itself only data, the pool slot's own address is looked up the same way, so
  `les si,[0x52eb]` call sites are reported for a face the code never names
  directly.
* **every text string that uses the face** - see the next section.

Text-string cross-reference
----------------------------

Two different record encodings exist and this script handles both, since which
one a machine uses decides where the font comes from.

**Sleic Pin-Ball** stores a string as a **`word` count followed by that many
`word` glyph pointers**, each an absolute offset within segment `F000` landing
directly on a cell of one packed face - so the face is implied by where the
pointers land, and no separate lookup is needed.  `xref_near_pointers` finds
every occurrence of a face's cell addresses as 16-bit words, extending the
search a good way past the face's own rendered `count` (the packed scan's tail
is fuzzy - see Limits - and real records reach into the punctuation past the
alphabet, capped at the next face's base so two faces' cells are never
confused), and `group_pointer_records` turns consecutive hits into records,
decoded through the fitted scheme with unmapped indices shown as `<n>`.  A
record's own stored count word is cross-checked against the number of
pointers found, and shown as `count=N` when they agree, `no count word`
otherwise (usually a record's front is clipped by a neighbouring face).

**Bike Race and IO Moon** store a string as **`[length byte][glyph index
bytes]`** - indices, not pointers, one byte per glyph, `length` doubling as
the on-screen character count - found by `scan_length_prefixed_strings`, whose
gate (every byte a known code, length 4-40, letters at least 60% of the body)
is unchanged from before this cross-reference was added, because it already
reproduces three independently-known answers exactly: `bkcpu05.bin` decodes
to the three records `PRIMERA PARTIDA` / `SEGUNDA PARTIDA` / `INSCRIPCION`,
`bkcpu04.bin` yields 133 records including `AK.SCHWANT`, `W.RAINEY` and
`E.LAWSON` letter-for-letter, and IO Moon's `V1 3_01.bin` yields 375 - the
reference counts this scan is checked against.  (An earlier pass's count of
185 for `bkcpu04.bin` is not reproduced by any gate this script tried that
also reproduces the three verified answers above; 133 is the settled figure.)
`--allow-unmapped N` widens the gate to admit up to `N` codes outside the
known alphabet per record, shown as `<n>`; at the default of 0 every accepted
record already decodes in full, so raising it only ever adds records - mostly
noise from graphics data (see Limits), occasionally a real record with a
not-yet-identified punctuation or digit code.

Unlike Pin-Ball, **the record does not name its own font** - a shared drawer
routine does, from a dispatch argument at its call site.  `find_text_drawer`
locates the routine by its prologue's exact bytes (`push bp; mov bp,sp; push
es; les si,[bp+0xa]; mov di,[bp+8]; mov bx,[bp+6]`, identical in Bike Race's
parent set at `F000:06C5` and IO Moon at `F000:0701`, and confirmed against
`docs/press_start_patch.md` and `scripts/io_moon_press_start_patch.py`, which
call IO Moon's copy `CALL FAR F000:0701(attr, position, seg, off)`).
`parse_text_drawer_dispatch` recovers its `cmp bx,imm / jne / jmp` case chain,
and `_case_pool_slot` reads the `les`/`lds` each case's block issues before
drawing - the same pointer-pool slot the face cross-reference above already
resolves to a `Face`, which is how a case is matched to a font without
guessing at what the bits of `attr` mean.  Both machines' dispatch tables have
the same shape: `attr` bit 4 clear selects the 9-row face, set selects the
12-row face, and the default (no explicit case matches) is the 9-row face -
recovered from the ROM, not assumed, and it is what turns `attr=0x21` at a
real Bike Race call site into `FACE at file 0x002B2` in the output.

`find_text_drawer_call_sites` then finds every `CALL FAR <drawer>` preceded
immediately by four push-immediate instructions (`PUSH seg; PUSH off; PUSH
position; PUSH attr`) by exact byte pattern - a full disassembly cannot be
trusted over this ROM family (see the `ndisasm` caveat below) - and resolves
the pushed `seg:off` to a record found by the scan above.  Only a
compile-time-constant string pointer is found this way; a call that builds
its pointer at runtime (a RAM buffer, a score readout) pushes a register or a
memory operand and is invisible to it.  When exactly one face is named across
a record's call sites, that is reported as the font, with the call site's
address, `attr` and DMD position; when call sites disagree, or point at a
case whose face could not be resolved, or none are found at all, the record
is `font: undetermined` - and if some *other* far pointer (a lookup table, or
a call this pattern misses) still names the record's address, that is
reported too, as weaker evidence that the string is live rather than an
explanation of its font.  This is deliberately conservative: **undetermined
is reported rather than guessed**.

In practice this resolves 7 of Bike Race's 133 `bkcpu04.bin` records to a
named face by an exact, traced call site (all seven land on the default case,
`attr=0x21`, and the trace is fully reproducible - address, pushed operands
and the pool-slot `les` are all printed); a further 86 are at least named by
some far pointer, unresolved to a specific font. IO Moon resolves **none** of
its 375 by call site - every one of its compile-time-constant `CALL FAR
F000:0701` sites pushes RAM segment `0x413C`, not a ROM address, which is
exactly what F14 predicts: IO Moon's menu and prompt text is reached through
the 46-byte menu-record table's own pointer field, not a literal push per
string - but 273 of the 375 (73%) are still named by a far pointer somewhere
in the ROM, so the great majority are demonstrably live text, just not
traceable to a face by this method. A translator changing IO Moon's UI text
should expect to find the record by its decoded string (this script's output)
and confirm the face by eye on real hardware or in the debugger, not from
this script's font column.

What it finds on each machine
-----------------------------

Every address below is what the script prints, not what it was told.

**Sleic Pin-Ball** - `sp03-1_1.rom`, 128 KB, org `0xE0000` from the reset
vector.  Two packed faces, both one byte (8 px) per row:

    F000:83D9  10 rows, stride 10   ink 7 px wide x 10 rows, column 7 blank
    F000:85EB   8 rows, stride  8   ink 7 px wide x  7 rows, columns 7 and row 7 blank

Both index `0-9 = '0'-'9'`, `10 = space`, `11.. = 'A'..'Z'` with `Ñ` at 25, so
the glyph code *is* the index; punctuation runs on from 38.  `mov si,0x83D9`
appears at 12 sites and `mov si,0x85EB` at 11, and two of each are followed by
the stride: `F000:0C7A`/`F000:0E8D` load `dx = 0xA` and `mul`/`imul` it, which
is `base + 10*index`.  The string records are a `word count` followed by that
many word glyph pointers - 13 of them into the 10-row face, 160 into the 8-row,
173 in total - and they decode straight to Spanish, address and character
count both matching the record's own stored count word: `F000:5308` =
`RECORD JUGADOR` (10-row), `F000:5326` = `NOMBRE<46>` (8-row, ":" - a glyph
past the fitted alphabet, shown as `<46>` rather than guessed), `F000:533E` =
` <50> CONTINUAS <51>` (10-row, `¿ ... ?` with the bracketing marks unmapped
and, tellingly, at two *different* indices either side, and a leading blank
cell the fit's alphabet does not cover), `F000:0B28` = `  <47> LOTERIA <47>`
(10-row, `- LOTERIA -` with the same bracketing mark both sides and a second
leading blank cell - the field is evidently padded for centring on the DMD).

**Bike Race** - `bkcpu04.bin` (code, org `0xE0000`), `bkcpu05.bin` and
`bkcpu06.bin` (graphics, org inferred as `0x40000` and `0x20000`).  **The code
ROM holds no font.**  Both graphics ROMs open with a chained table:

    bkcpu05 0x00000, 131 entries   (8,1) x23 | (9,1) x52 | (12,1) x53 | (15,1) x2
    bkcpu06 0x00000,  54 entries   (8,1) x11 | (18,1) x21 | (23,2) x21

`(9,1)` at `4000:02B2` and `(12,1)` at `4000:0966` are the two text faces, both
fitting `0-9`, space, `A..Ñ..Z` with the code equal to the face index - and
since they begin at chain entries 23 and 75, the **table** index is
`code + 23` and `code + 75`.  The code reaches each face through one far
pointer in `bkcpu04`: `F000:06C1` (h=9) is loaded by `les si,[0x6c1]` at five
sites from `F000:0715`, `F000:06BD` (h=12) at three from `F000:0763`.  Two more
chains hold artwork in the same format: `bkcpu05 0x030EE` (ten 18x16 cells) and
`bkcpu06 0x1CC92` (37 24x24 cells, which the render shows to be one sprite
walked one pixel to the right per entry - a constant-geometry run that is not a
font, and the fit says so).

`bkcpu04.bin` also holds 133 `[length][glyph code]` string records (0x0087D-
0x14165) - rider names (`AK.SCHWANT`, `W.RAINEY`, `E.LAWSON`) and UI prompts
(`ATENCION`, `IMPOSIBLE SEGUIR`) - drawn through a shared far-call routine at
`F000:06C5` (the parent set; V4.1's chip is at `F000:0682` instead, per
`asm/bikerace-2026-09/tools/strptr.py`, and is not what this ROM's own drawer
is found at).  7 of the 133 trace to a named face by an exact call site (all
`attr=0x21`, all the default dispatch case, all naming the 9-row face);
86 more are at least referenced by some other far pointer.  `bkcpu05.bin`
holds exactly the three service-menu titles this cross-reference was checked
against: `PRIMERA PARTIDA`, `SEGUNDA PARTIDA`, `INSCRIPCION`.  `bkcpu06.bin`
"finds" 2 records reading `DBBNNN` - a coincidence in the sprite-strip bitmap
data at `0x2FB`/`0x553`, not real text (see Limits).

**IO Moon** - `V1 3_01.bin`, 512 KB, org `0x80000` from the reset vector, and a
second window at `0x00000` the script discovers from the pointers themselves
(F1's LMCS mapping of the low quarter).  One 225-entry chain at file `0x20000`,
cut into eight faces, plus a separate ten-entry chain at `0x29B34`:

    face          file      CPU         pool slot   loaded by
    (8,1)  x23    0x20000   2000:0000   -           (reached some other way)
    (9,1)  x52    0x202B2   2000:02B2   CS:052EB    F000:0751 +4 more
    (12,1) x53    0x20966   2000:0966   CS:052E7    F000:079F +2 more
    (8,1)  x11    0x2127E   2000:127E   CS:0531B    F000:0D94 +2 more
    (18,1) x21    0x213C8   2000:13C8   CS:052EF    F000:0B3F +5 more
    (23,2) x21    0x218B4   2000:18B4   CS:05313    F000:0B8D
    (12,1) x21    0x22484   2000:2484   CS:052DB    F000:0BDD +8 more
    (16,1) x20    0x227F6   2000:27F6   CS:052E3    -
    (21,2) x10    0x29B34   2000:9B34   CS:05327    F000:3171 +3 more

The `(9,1)` and `(12,1)` faces fit `0-9`, space, `A..Ñ..Z` confidently and sit
at chain entries 23 and 75 - the same two offsets Bike Race uses, in a table
with the same shape.  The `(21,2)` face at `0x29B34` is a clean 16x21 digit set
in a chain of its own, outside the walked table `docs/dmd_graphics.md`
describes.

`V1 3_01.bin` also holds 375 `[length][glyph code]` string records (0x017A8-
0x59526) - the service-menu tree: `- ADJUSTMENT -`, `SOUND/VIDEO`, `TECHNICAL`,
`CUSTOM MESSAGE`, `LOWEST SCORE`, `EXTRA BALLS`, and so on, consistent with
F14's 38-record menu.  The same drawer routine exists, at `F000:0701`, with
the same dispatch shape and the same two pool slots (`CS:052EB` 9-row,
`CS:052E7` 12-row), but **none** of the 375 resolve to a named face by call
site: every compile-time-constant call this script finds pushes RAM segment
`0x413C`, not a ROM address - the menu text is reached through the menu-record
table (F14), not a literal push per string.  273 of the 375 (73%) are still
named by some far pointer elsewhere in the ROM, so most are demonstrably live,
just not traceable to a face this way.

Limits
------

* A face whose glyphs are **not** a fixed-stride array of MSB-first rows is not
  found: proportional-width fonts, column-major fonts, compressed fonts.  IO
  Moon's in-play score digits (`CS:052BB`, stride `0x6C`, two 54-byte halves per
  digit, three planes each, `docs/dmd_graphics.md`) are packed but not in this
  scanner's packed layout, and it does not find them.
* The packed scan needs `--min-glyphs` cells in a run and an alphabet fit of at
  least `--min-fit`.  A packed face of ten digits and nothing else scores around
  5-6 where a full alphabet scores 12, so it sits right at the default
  threshold; lower `--min-fit` and read the renders if one is expected.
* The **ends of a packed run are fuzzy**.  The start is pinned hard, by the
  index anchor; the tail is punctuation that the run test cannot always defend,
  so a glyph count may be a few short.  Both Pin-Ball faces are reported as 50
  cells where the table actually runs to the next face's base, 53.
* Character identity comes from hole counts, widths and the `N`/`Ñ` pixel test,
  not from reading the pixels as a human would.  It pins `0 4 6 8 9 A B D O P Q
  R` firmly and treats the 0-hole majority as interchangeable, so a scheme that
  agreed on every hole count but permuted `C`, `E` and `F` would be accepted.
  **The render is the evidence**; the fitted labels are a hypothesis printed
  above it, and the confidence word on the scheme line says how much weight it
  carries.
* A **shaded** face defeats the fit.  IO Moon's `(23,2)` price digits draw a
  bright outline in plane 0 and the fill in plane 1, so plane 0 alone is hollow
  and its hole counts are meaningless; the script tries plane 0 OR plane 1 as
  well and still scores it "weak".  The face, its geometry and its pointer are
  right; only the labels are guesses.
* A **constant-geometry run is not necessarily a font.**  `bkcpu06 0x1CC92` is
  37 frames of one sprite.  The scan reports it, the fit refuses to label it,
  and the render settles it.
* The org of a graphics ROM is inferred from pointer hits, and a ROM given on
  its own has no pointers to infer from.  Pass `@org` when the answer matters.
* The code cross-reference validates instruction framing but does not prove the
  instruction is reached; an immediate inside a data block that happens to
  decode as `mov si,<base>` is listed like any other.  Occurrence counts are
  given so a single dubious hit is visible as such.  A face that begins at
  offset 0 of its chip attracts coincidental far-pointer hits, because the
  four zero-ish bytes that encode it are a common byte pattern.
* `[length][glyph code]` records are recognised by byte shape alone, so short
  ones are noisy and records under four characters are not reported.  Applied
  to a pure graphics ROM this occasionally finds a coincidence: `bkcpu06.bin`
  "finds" two identical records reading `DBBNNN` at `0x2FB`/`0x553`, which is a
  repeating bitmap pattern in the sprite-strip artwork, not text - visible as
  such because it is short, all-consonant and duplicated verbatim.
* The scan is a **greedy left-to-right sweep with no knowledge of true record
  boundaries**, so it can occasionally misalign across two adjacent records
  and print a garbled hybrid of both - `bkcpu04.bin`'s `F000:3953` decodes to
  `O - AJUSTE -BSONIDO/VIDE`, which is the tail of one title fused to the head
  of the next.  The individual real titles (`- SONIDO -`, `SOUND/VIDEO`-style
  strings) are elsewhere in the same run; read the surrounding records if one
  looks fused.
* **Call-site resolution only ever finds a compile-time-constant string
  pointer** - four push-immediate instructions immediately before `CALL FAR
  <drawer>`.  A call that composes its pointer at runtime (register or memory
  operand) is invisible to it, which is why IO Moon's static menu text - all
  reached through a record table, per F14 - resolves to a face zero times out
  of 375 even though most of it is demonstrably live (named by *some* far
  pointer).  Do not read "font: undetermined" as "this string is unused."
* **Translating a `[length][glyph code]` record**: the length byte counts
  glyph bytes 1:1 with on-screen characters, there is no terminator, and
  records sit back-to-back with no slack - so a same-length or *shorter*
  translation (pad with trailing spaces, as several original records already
  do, e.g. `CRABY  `, `W.RAINEY `) is a same-address byte patch, lowering the
  length byte if needed; a *longer* one overflows into the next record and
  needs the string relocated to free space with every reference that names
  its old address - the call sites this script finds, and any pointer-table
  entry it can only report as "referenced," not resolved - repointed at the
  new one, which is a ROM-wide patch, not a byte-level edit.
* Sleic Pin-Ball's pointer-record scan searches past a face's own rendered
  `count` for the punctuation its tail is under-reported for (see the packed-
  run fuzzy-tail limit above), capped at the next face's base so the two
  faces' cells cannot be confused with each other; a record that reaches
  *past* both known faces (into whatever data follows the second one) is not
  extended further and will still come up short.

Dependencies: numpy, capstone (`pip install numpy capstone`). capstone is only
needed for the code cross-reference; without it the rest still runs.
"""

import argparse
import os
import re
import sys

import numpy as np

try:
    from capstone import Cs, CS_ARCH_X86, CS_MODE_16
    _HAVE_CAPSTONE = True
except ImportError:                                            # pragma: no cover
    _HAVE_CAPSTONE = False


# --------------------------------------------------------------------------
# The SLEIC character set.  Ñ sits between N and O; this is the order the
# machines' own glyph codes use (docs/dmd_graphics.md, "Custom Text Encoding").
# --------------------------------------------------------------------------

DIGITS = "0123456789"
LETTERS_ENYE = "ABCDEFGHIJKLMNÑOPQRSTUVWXYZ"
LETTERS_PLAIN = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"

# Enclosed holes each character has in a 5x7-ish bitmap face.  A tuple is a
# tolerance: '4' may be drawn open or closed, 'G' may have a closed tail.
HOLES = {
    '0': (1,), '1': (0,), '2': (0,), '3': (0,), '4': (0, 1), '5': (0,),
    '6': (1,), '7': (0,), '8': (2,), '9': (1,),
    'A': (1,), 'B': (2,), 'C': (0,), 'D': (1,), 'E': (0,), 'F': (0,),
    'G': (0, 1), 'H': (0,), 'I': (0,), 'J': (0,), 'K': (0,), 'L': (0,),
    'M': (0,), 'N': (0,), 'Ñ': (0,), 'O': (1,), 'P': (1,), 'Q': (1,),
    'R': (1,), 'S': (0,), 'T': (0,), 'U': (0,), 'V': (0,), 'W': (0,),
    'X': (0,), 'Y': (0,), 'Z': (0,),
}
NARROW = set("1I")          # expected to be clearly narrower than the face
WIDE = set("MW")            # expected to be as wide as the face gets

# The glyph-code encoding Bike Race and IO Moon use in their string records.
CODE_TO_CHAR = {0x0A: ' '}
for _i, _c in enumerate(LETTERS_ENYE):
    CODE_TO_CHAR[0x0B + _i] = _c
CODE_TO_CHAR.update({0x26: '+', 0x28: '(', 0x29: ')', 0x2A: '/', 0x2B: ',',
                     0x2C: '.', 0x2D: ';', 0x2E: ':', 0x2F: '-'})


# --------------------------------------------------------------------------
# ROM image
# --------------------------------------------------------------------------

class Rom(object):
    """One ROM image plus the flat address it is mapped at."""

    def __init__(self, path, org=None):
        self.path = path
        self.name = os.path.basename(path)
        with open(path, 'rb') as fh:
            self.data = fh.read()
        self.a = np.frombuffer(self.data, dtype=np.uint8)
        self.org, self.org_why = self._auto_org() if org is None \
            else (org, "given on the command line")
        # 64 KB-aligned flat bases this image is *also* visible at.  A SLEIC
        # code ROM larger than 256 KB is mapped twice (F1: UMCS over the whole
        # chip, LMCS over its low quarter), and the second window is where the
        # font pointers point.  Filled in by find_windows().
        self.alt_orgs = []

    def _auto_org(self):
        """A 80188 code ROM carries `EA off seg` at flat 0xFFFF0 - the reset
        vector - so its own last 16 bytes pin where the image is mapped."""
        if len(self.data) >= 16 and self.data[-16] == 0xEA:
            org = 0x100000 - len(self.data)
            return org, "80188 reset vector (EA) at image end"
        return 0, "no reset vector; org unknown, file offsets used"

    def windows(self):
        return [self.org] + self.alt_orgs

    def flat(self, off, org=None):
        return (self.org if org is None else org) + off

    def seg_off(self, off, org=None):
        """Render a flat address the way the listings do, on a 64 KB segment
        base, so `0xF83D9` prints as `F000:83D9`."""
        f = self.flat(off, org)
        seg = (f >> 16) << 12
        return "%04X:%04X" % (seg, f - (seg << 4))

    def words(self):
        """Every 16-bit LE word at every byte position."""
        if not hasattr(self, '_w'):
            a = self.a.astype(np.uint32)
            self._w = a[:-1] | (a[1:] << 8)
        return self._w

    def far_pointers(self):
        """Positions and targets of the far pointers whose segment is 64 KB
        aligned.  Every segment register this family loads is (`0x2000`,
        `0x5000`, `0xF000`, ...), so this keeps the real pointers and throws
        away the four-byte coincidences, which otherwise swamp the count."""
        if not hasattr(self, '_fp'):
            w = self.words()
            off, seg = w[:-2], w[2:]
            m = np.flatnonzero(seg % 0x1000 == 0)
            self._fp = (m, (seg[m].astype(np.int64) << 4)
                        + off[m].astype(np.int64))
        return self._fp


# --------------------------------------------------------------------------
# Bitmap primitives.  A glyph is a list of `h` ints, each holding `8*w` bits,
# MSB = leftmost pixel.
# --------------------------------------------------------------------------

def glyph_rows(data, off, h, w):
    rows = []
    for r in range(h):
        v = 0
        for b in range(w):
            v = (v << 8) | data[off + r * w + b]
        rows.append(v)
    return rows


def render_rows(rows, w):
    bits = 8 * w
    return ["".join('#' if (v >> (bits - 1 - c)) & 1 else '.' for c in range(bits))
            for v in rows]


def ink_count(rows):
    return sum(bin(v).count('1') for v in rows)


def col_footprint(rows):
    v = 0
    for r in rows:
        v |= r
    return v


def ink_bbox(rows, w):
    bits = 8 * w
    fp = col_footprint(rows)
    if fp == 0:
        return None
    left = bits - fp.bit_length()
    right = bits - 1
    while right >= 0 and not (fp >> (bits - 1 - right)) & 1:
        right -= 1
    top = next(i for i, v in enumerate(rows) if v)
    bot = len(rows) - 1 - next(i for i, v in enumerate(reversed(rows)) if v)
    return left, right, top, bot


def _grid(rows, w):
    bits = 8 * w
    return [[(v >> (bits - 1 - c)) & 1 for c in range(bits)] for v in rows]


def count_components(rows, w, target=1):
    """8-connected components of `target` pixels."""
    g = _grid(rows, w)
    hgt, wid = len(g), len(g[0])
    seen = [[False] * wid for _ in range(hgt)]
    n = 0
    for y in range(hgt):
        for x in range(wid):
            if g[y][x] == target and not seen[y][x]:
                n += 1
                st = [(y, x)]
                seen[y][x] = True
                while st:
                    cy, cx = st.pop()
                    for dy in (-1, 0, 1):
                        for dx in (-1, 0, 1):
                            ny, nx = cy + dy, cx + dx
                            if 0 <= ny < hgt and 0 <= nx < wid \
                                    and g[ny][nx] == target and not seen[ny][nx]:
                                seen[ny][nx] = True
                                st.append((ny, nx))
    return n


def count_holes(rows, w):
    """Background regions with no path to the border (4-connected), i.e. the
    counters of 0, 8, A, B, D, O, P, Q, R."""
    g = _grid(rows, w)
    hgt, wid = len(g), len(g[0])
    seen = [[False] * wid for _ in range(hgt)]
    st = []
    for y in range(hgt):
        for x in (0, wid - 1):
            if not g[y][x] and not seen[y][x]:
                seen[y][x] = True
                st.append((y, x))
    for x in range(wid):
        for y in (0, hgt - 1):
            if not g[y][x] and not seen[y][x]:
                seen[y][x] = True
                st.append((y, x))
    while st:
        cy, cx = st.pop()
        for dy, dx in ((1, 0), (-1, 0), (0, 1), (0, -1)):
            ny, nx = cy + dy, cx + dx
            if 0 <= ny < hgt and 0 <= nx < wid and not g[ny][nx] and not seen[ny][nx]:
                seen[ny][nx] = True
                st.append((ny, nx))
    holes = 0
    for y in range(hgt):
        for x in range(wid):
            if not g[y][x] and not seen[y][x]:
                holes += 1
                st = [(y, x)]
                seen[y][x] = True
                while st:
                    cy, cx = st.pop()
                    for dy, dx in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                        ny, nx = cy + dy, cx + dx
                        if 0 <= ny < hgt and 0 <= nx < wid \
                                and not g[ny][nx] and not seen[ny][nx]:
                            seen[ny][nx] = True
                            st.append((ny, nx))
    return holes


def hamming(a, b):
    return sum(bin(x ^ y).count('1') for x, y in zip(a, b))


# --------------------------------------------------------------------------
# A face: a fixed-stride, fixed-geometry run of glyph cells.
# --------------------------------------------------------------------------

class Face(object):
    def __init__(self, rom, layout, base, stride, h, w, count, dataoff=0,
                 planes=1, score=0.0, evidence=""):
        self.rom = rom
        self.layout = layout          # 'packed' | 'header3'
        self.base = base              # file offset of glyph 0's cell
        self.stride = stride          # bytes from one cell to the next
        self.h = h                    # rows
        self.w = w                    # bytes per row
        self.count = count            # cells in the run
        self.dataoff = dataoff        # bitmap offset inside the cell
        self.planes = planes
        self.score = score
        self.evidence = evidence
        self.fit = 0.0
        self.plane_mode = 'p0'
        self.scheme = None
        self._cache = {}

    @property
    def end(self):
        return self.base + self.count * self.stride

    def rows(self, i):
        if i not in self._cache:
            off = self.base + i * self.stride + self.dataoff
            r = glyph_rows(self.rom.data, off, self.h, self.w)
            if self.plane_mode == 'p0|p1' and self.planes > 1:
                r1 = glyph_rows(self.rom.data, off + self.h * self.w,
                                self.h, self.w)
                r = [x | y for x, y in zip(r, r1)]
            self._cache[i] = r
        return self._cache[i]

    def set_plane_mode(self, mode):
        self.plane_mode = mode
        self._cache = {}

    def cell_offset(self, i):
        return self.base + i * self.stride

    def addrs(self):
        """The face base as every window of its image sees it."""
        return [self.rom.seg_off(self.base, o) for o in self.rom.windows()]

    def geometry(self):
        return "%d rows x %d px, %d byte%s/row, stride %d, %d glyphs" % (
            self.h, 8 * self.w, self.w, "" if self.w == 1 else "s",
            self.stride, self.count)


# --------------------------------------------------------------------------
# Scan 1: packed runs of fixed-size cells (Sleic Pin-Ball)
# --------------------------------------------------------------------------

_POP = np.array([bin(i).count('1') for i in range(256)], dtype=np.int32)


def _rowwords(a, w):
    """Row words for a given bytes-per-row, at every byte position."""
    if w == 1:
        return a.astype(np.int32)
    out = a[:len(a) - w + 1].astype(np.int32)
    for b in range(1, w):
        out = (out << 8) | a[b:len(a) - w + 1 + b].astype(np.int32)
    return out


def _popcount(x):
    return _POP[x & 0xFF] + _POP[(x >> 8) & 0xFF]


def _blocks(flag, gap_tol):
    """Start/end of the True blocks of `flag`, merging blocks separated by at
    most `gap_tol` False cells."""
    d = np.diff(np.concatenate(([0], flag.view(np.int8), [0])))
    s = np.flatnonzero(d == 1)
    e = np.flatnonzero(d == -1)
    if len(s) == 0:
        return s, e
    keep_s, keep_e = [s[0]], []
    for i in range(1, len(s)):
        if s[i] - e[i - 1] <= gap_tol:
            continue
        keep_e.append(e[i - 1])
        keep_s.append(s[i])
    keep_e.append(e[-1])
    return np.array(keep_s), np.array(keep_e)


def scan_packed(rom, hmin=5, hmax=26, widths=(1, 2), min_glyphs=16, gap_tol=1,
                max_blank_run=4, max_extend=24):
    """Find runs of glyph-like fixed-size cells with no header of any kind."""
    a = rom.a
    cands = []
    for w in widths:
        rw = _rowwords(a, w)
        bits = 8 * w
        for h in range(hmin, hmax + 1):
            cell = h * w
            for phase in range(cell):
                n = (len(rw) - phase) // cell
                if n < min_glyphs:
                    continue
                c = rw[phase:phase + n * cell:w].reshape(n, h)
                ink = _popcount(c).sum(1)
                orv = np.bitwise_or.reduce(c, axis=1)
                nz = (c != 0).sum(1)
                width = _popcount(orv)
                lowbit = orv & -orv
                contig = (orv != 0) & (((orv + lowbit) & (orv + lowbit - 1)) == 0)

                blank = ink == 0
                strong = ((ink >= max(4, int(0.16 * h * bits)))
                          & (ink <= int(0.75 * h * bits))
                          & contig & (width >= 3) & (width <= bits)
                          & (nz >= h - 2) & (c[:, 0] != 0))
                if strong.sum() < min_glyphs:
                    continue
                # small marks - punctuation - that may trail a face
                weak = (~strong) & (~blank) & (ink > 0) \
                    & (ink <= int(0.5 * h * bits))

                # a long stretch of empty cells is padding, not a space
                short_blank = blank.copy()
                bs, be = _blocks(blank, 0)
                for s0, e0 in zip(bs, be):
                    if e0 - s0 > max_blank_run:
                        short_blank[s0:e0] = False

                seed = strong | short_blank
                for s, e in zip(*_blocks(seed, gap_tol)):
                    while s < e and not strong[s]:
                        s += 1
                    while e > s and not strong[e - 1]:
                        e -= 1
                    if int(strong[s:e].sum()) < min_glyphs:
                        continue
                    cand = _score_packed_run(rom, c, orv, ink, width, strong,
                                             weak, blank, int(s), int(e), h, w,
                                             phase, cell, max_extend)
                    if cand:
                        cands.append(cand)
    return cands


def _margin_window(gi, orv, bits):
    """Longest run of the given cells whose combined column footprint still
    leaves one column blank.  `last[b]` is the most recent cell that used
    column b, so the window ending at r may start no earlier than
    min(last) + 1."""
    last = [-1] * bits
    best = (0, 0)
    for r in range(len(gi)):
        v = int(orv[gi[r]])
        for b in range(bits):
            if (v >> b) & 1:
                last[b] = r
        lo = min(last) + 1
        if r - lo + 1 > best[1] - best[0]:
            best = (lo, r + 1)
    return gi[best[0]:best[1]]


def _score_packed_run(rom, c, orv, ink, width, strong, weak, blank, s, e, h, w,
                      phase, cell, max_extend):
    bits = 8 * w
    gi = np.flatnonzero(strong[s:e]) + s
    # A font keeps a blank margin column that *every* glyph respects, so cut the
    # block down to the longest window whose glyphs share one.  This is what
    # separates a face from the graphics that happen to sit next to it.
    gi = _margin_window(gi, orv, bits)
    if len(gi) < 4:
        return None
    wid = width[gi]
    if wid.std() > 1.8:                  # a real face keeps one cell width
        keep = np.abs(wid - np.median(wid)) <= 2
        gi = gi[keep]
        if len(gi) < 4 or width[gi].std() > 1.8:
            return None
    s, e = int(gi[0]), int(gi[-1]) + 1
    union = int(np.bitwise_or.reduce(orv[gi]))
    margin = bits - int(_popcount(np.array([union]))[0])
    if margin == 0:
        return None
    sample = gi[::max(1, len(gi) // 12)][:12]
    comps = [count_components(list(map(int, c[i])), w) for i in sample]
    conn = sum(1 for x in comps if x == 1) / float(len(comps))
    if conn < 0.75:      # a glyph is one connected shape; noise often is not
        return None
    dens = float(ink[gi].mean()) / (h * bits)
    nstrong = len(gi)
    # extend over trailing small marks that stay inside the face's own columns
    grown = 0
    n = len(orv)
    while grown < max_extend and e < n and (weak[e] or blank[e]) \
            and (int(orv[e]) & ~union) == 0:
        e += 1
        grown += 1
    while e > s and blank[e - 1]:
        e -= 1
        grown -= 1
    score = nstrong * conn * (1.0 + 0.25 * min(margin, 3))
    base = phase + s * cell
    ev = ("strong glyphs %d/%d, single-component %d%%, %d blank margin column%s, "
          "mean ink %.0f%%%s" % (nstrong, e - s, round(100 * conn), margin,
                                 "" if margin == 1 else "s", 100 * dens,
                                 "" if not grown else
                                 ", %d trailing cell(s) added by extension" % grown))
    return Face(rom, 'packed', base, cell, h, w, e - s, score=score, evidence=ev)


def rank_packed(cands, min_fit=5.0, overlap=0.5):
    """Rank packed candidates by structure *and* by how well an alphabet fits
    them - which is what picks the true cell height out of the harmonics that
    slice the same bytes into more, smaller cells - then re-base each survivor
    on the anchor the fit found and drop the overlapping losers."""
    scored = []
    for f in cands:
        sch = fit_scheme(f)
        f.score = f.score * (1.0 + sch.score / 4.0)
        f.fit = sch.score
        if sch.score >= min_fit and sch.anchor > 0 and sch.kind != 'none':
            f.base += sch.anchor * f.stride
            f.count -= sch.anchor
            f.evidence += ("; re-based %d cell(s) forward onto the index "
                           "anchor the alphabet fit found" % sch.anchor)
            f._cache = {}
            sch = fit_scheme(f)
        f.scheme = sch
        scored.append(f)
    keep = [f for f in scored if f.fit >= min_fit]
    kept = _dedupe(keep, overlap)
    # a face cannot run into the next one
    for f in kept:
        nxt = [g.base for g in kept if g is not f and f.base < g.base < f.end]
        if nxt:
            f.count = (min(nxt) - f.base) // f.stride
            f.evidence += "; clipped where the next face begins"
    return kept, len(scored) - len(keep)


def _dedupe(cands, overlap=0.5):
    out = []
    for f in sorted(cands, key=lambda x: -x.score):
        clash = False
        for k in out:
            lo = max(f.base, k.base)
            hi = min(f.end, k.end)
            if hi > lo and (hi - lo) > overlap * min(f.end - f.base, k.end - k.base):
                clash = True
                break
        if not clash:
            out.append(f)
    return out


# --------------------------------------------------------------------------
# Scan 2: the self-describing `[h,0,w,0,len16]` + 3 planes chain
# (Bike Race, IO Moon)
# --------------------------------------------------------------------------

def _is_header(d, off, hmax=48, wmax=32):
    if off + 6 > len(d):
        return None
    h, z1, w, z2 = d[off], d[off + 1], d[off + 2], d[off + 3]
    ln = d[off + 4] | (d[off + 5] << 8)
    if z1 or z2 or not (1 <= h <= hmax) or not (1 <= w <= wmax):
        return None
    if ln != h * w or off + 6 + 3 * ln > len(d):
        return None
    return h, w, ln


def walk_header3(d, off, hmax=48, wmax=32):
    ents = []
    while True:
        hd = _is_header(d, off, hmax, wmax)
        if hd is None:
            return ents, off
        h, w, ln = hd
        ents.append((off, h, w, ln))
        off += 6 + 3 * ln


def scan_header3(rom, min_chain=6, min_glyphs=6):
    """Walk every header chain, then cut each chain into constant-geometry
    faces - the runs that have a fixed stride and can be indexed."""
    d = rom.data
    faces = []
    tables = []
    off = 0
    covered = 0
    while off < len(d) - 6:
        if off < covered or _is_header(d, off) is None:
            off += 1
            continue
        ents, end = walk_header3(d, off)
        if len(ents) < min_chain:
            off += 1
            continue
        covered = end
        tables.append((off, end, ents))
        off = end
    for tstart, tend, ents in tables:
        run = []
        prev = None
        for i, (o, h, w, ln) in enumerate(ents + [(None, None, None, None)]):
            if (h, w) != prev:
                if run and len(run) >= min_glyphs:
                    faces.append(_face_from_run(rom, ents, run, tstart, len(ents)))
                run = []
                prev = (h, w)
            if o is not None:
                run.append(i)
    return faces, tables


def _face_from_run(rom, ents, run, tstart, ntotal):
    o, h, w, ln = ents[run[0]]
    stride = 6 + 3 * ln
    ev = ("chained entries %d..%d of the %d-entry table at 0x%05X; "
          "header [%d,0,%d,0,%d]" % (run[0], run[-1], ntotal, tstart, h, w, ln))
    return Face(rom, 'header3', o, stride, h, w, len(run), dataoff=6, planes=3,
                score=float(len(run)), evidence=ev)


# --------------------------------------------------------------------------
# Index-scheme inference
# --------------------------------------------------------------------------

class Scheme(object):
    def __init__(self, kind, anchor, labels, score, notes):
        self.kind = kind          # 'digits+space+alpha' etc.
        self.anchor = anchor      # index of the first labelled glyph
        self.labels = labels      # {index: character}
        self.score = score
        self.notes = notes

    def summary(self, face):
        if not self.labels:
            return "no scheme fitted"
        a = self.anchor
        if self.kind.startswith('digits'):
            bits = ["index %d-%d = '0'-'9'" % (a, a + 9)]
            sp = [i for i, c in self.labels.items() if c == ' ']
            if sp:
                bits.append("%d = space" % sp[0])
            al = [i for i, c in sorted(self.labels.items()) if c == 'A']
            if al:
                bits.append("%d.. = 'A'.." % al[0])
                ny = [i for i, c in self.labels.items() if c == 'Ñ']
                bits.append("'Ñ' at %d" % ny[0] if ny
                            else "no 'Ñ' (plain A-Z)")
            if a == 0:
                bits.append("glyph code == index")
            else:
                bits.append("glyph code == index - %d" % a)
            return ", ".join(bits)
        return "index %d.. = '%s'.." % (a, self.labels[a])


def _layouts(n):
    """Candidate index layouts, with the shortest claim first so a face that
    only shows ten digits is reported as ten digits, not as the truncated head
    of an alphabet.  The second number is the coverage a layout needs before it
    may be chosen at all."""
    out = [('digits', DIGITS, 10)]
    for letters, tag in ((LETTERS_ENYE, 'enye'), (LETTERS_PLAIN, 'plain')):
        out.append(('digits+space+alpha(%s)' % tag, DIGITS + ' ' + letters, 20))
    out.append(('alpha(enye)', LETTERS_ENYE, 20))
    return out


def _pair_similarity(face, i, j):
    """Best pixel agreement of two glyphs over a 0-2 row vertical shift.  A
    real `Ñ` is its own `N` with a tilde added, so it scores very high; an `O`
    against an `N` does not."""
    if max(i, j) >= face.count or min(i, j) < 0:
        return 0.0, 0
    ri, rj = face.rows(i), face.rows(j)
    tot = face.h * 8 * face.w
    best = (0.0, 0)
    for s in (0, 1, 2):
        a = ri[:face.h - s]
        b = rj[s:]
        agree = 1.0 - hamming(a, b) / float(tot)
        if agree > best[0]:
            best = (agree, s)
    return best


def fit_scheme(face, min_cover=10):
    feats = []
    for i in range(face.count):
        rows = face.rows(i)
        ink = ink_count(rows)
        bb = ink_bbox(rows, face.w)
        feats.append(dict(ink=ink, holes=count_holes(rows, face.w) if ink else 0,
                          width=0 if bb is None else bb[1] - bb[0] + 1))
    widths = [f['width'] for f in feats if f['ink']]
    if not widths:
        return Scheme('none', 0, {}, 0.0, [])
    wmax = max(widths)
    wmed = sorted(widths)[len(widths) // 2]

    best = None
    for kind, seq, need in _layouts(face.count):
        for anchor in range(0, face.count):
            cover = min(len(seq), face.count - anchor)
            if cover < max(min_cover, need):
                continue
            sc = 0.0
            for k in range(cover):
                ch = seq[k]
                f = feats[anchor + k]
                if ch == ' ':
                    sc += 5.0 if f['ink'] == 0 else -10.0
                    continue
                if f['ink'] == 0:
                    sc -= 10.0
                    continue
                exp = HOLES[ch]
                if f['holes'] in exp:
                    sc += 3.0 if max(exp) else 0.6
                else:
                    sc -= 2.5
                if ch in NARROW:
                    sc += 1.5 if f['width'] <= 0.75 * wmed else -1.5
                elif ch in WIDE:
                    sc += 1.0 if f['width'] >= wmax - 1 else -1.0
            sc = sc / cover * min(cover, len(seq)) ** 0.5
            if kind.startswith('alpha'):
                sc *= 0.75      # no digit run and no space: weakest evidence
            # `Ñ` or no `Ñ` is settled on pixels, not on hole counts: an 8-row
            # `Ñ` can close a counter and then reads topologically as an `O`.
            npos = seq.find('N')
            if npos >= 0 and anchor + npos + 1 < face.count and cover > npos + 1:
                agree = _pair_similarity(face, anchor + npos, anchor + npos + 1)[0]
                twin = agree >= 0.85
                sc += 3.0 if twin == ('Ñ' in seq) else -3.0
            if best is None or sc > best[0]:
                best = (sc, kind, anchor, seq, cover)
    if best is None:
        return Scheme('none', 0, {}, 0.0, [])
    sc, kind, anchor, seq, cover = best
    labels = {anchor + k: seq[k] for k in range(cover)}
    notes = _enye_evidence(face, labels)
    return Scheme(kind, anchor, labels, sc, notes)


def _enye_evidence(face, labels):
    """Settle `Ñ` after `N` by measurement: the candidate must have no holes,
    be a near-copy of N, and be followed by a 1-hole glyph (O)."""
    inv = {}
    for i, c in labels.items():
        inv.setdefault(c, i)
    if 'N' not in inv:
        return []
    n = inv['N']
    cand = n + 1
    if cand >= face.count:
        return []
    agree, shift = _pair_similarity(face, n, cand)
    topink = bin(face.rows(cand)[0]).count('1') - bin(face.rows(n)[0]).count('1')
    nxt = count_holes(face.rows(cand + 1), face.w) if cand + 1 < face.count else None
    twin = agree >= 0.85
    verdict = "yes" if twin else "no - the glyph after 'N' is not a copy of it"
    return ["'Ñ' after 'N': %s - glyph %d is %.0f%% pixel-identical to "
            "glyph %d ('N') at a %d-row shift, with %+d ink pixel(s) in its top "
            "row, and glyph %d has %s enclosed hole(s) (1 = 'O')"
            % (verdict, cand, 100 * agree, n, shift, topink, cand + 1, nxt)]


# --------------------------------------------------------------------------
# Rendering
# --------------------------------------------------------------------------

def render_face(face, per_line=16, indent="    "):
    lines = []
    labels = face.scheme.labels if face.scheme else {}
    for start in range(0, face.count, per_line):
        cnt = min(per_line, face.count - start)
        idxs = range(start, start + cnt)
        bits = 8 * face.w
        head = " ".join(("%-*s" % (bits, "%d:%s" % (i, labels.get(i, '?'))))
                        for i in idxs)
        lines.append(indent + head)
        grids = [render_rows(face.rows(i), face.w) for i in idxs]
        for r in range(face.h):
            lines.append(indent + " ".join(g[r] for g in grids))
        lines.append("")
    return "\n".join(lines)


# --------------------------------------------------------------------------
# Cross-reference: code
# --------------------------------------------------------------------------

def _record_credible(rec):
    """A run of consecutive near pointers is a string record if it is long
    enough, and either carries its own count word or spells something with
    letters in it.  Short runs of small values are ordinary data."""
    if rec['n'] < 4:
        return False
    if rec['has_count']:
        return True
    return sum(1 for c in rec['text'] if c.isalpha()) >= 3


def _md():
    md = Cs(CS_ARCH_X86, CS_MODE_16)
    md.detail = False
    return md


def find_word_refs(rom, value, limit=64):
    """Every 16-bit occurrence of `value` that a real instruction frames."""
    if not _HAVE_CAPSTONE or value > 0xFFFF:
        return []
    md = _md()
    needle = bytes([value & 0xFF, (value >> 8) & 0xFF])
    txt = "0x%x" % value
    out = []
    pos = rom.data.find(needle)
    while pos >= 0 and len(out) < limit:
        for back in range(1, 6):
            s = pos - back
            if s < 0:
                continue
            try:
                ins = next(md.disasm(rom.data[s:s + back + 8], rom.flat(s), 1))
            except StopIteration:
                continue
            if ins.size >= back + 2 and txt in ins.op_str:
                out.append((s, ins.size, "%s %s" % (ins.mnemonic, ins.op_str)))
                break
        pos = rom.data.find(needle, pos + 1)
    return out


def _window_disasm(rom, off, count=14):
    md = _md()
    out = []
    for ins in md.disasm(rom.data[off:off + 60], rom.flat(off)):
        out.append(ins)
        if len(out) >= count:
            break
    return out


def xref_code(rom, face, limit=40):
    """base references, and the stride multiply that follows them."""
    hits = []
    for base_seg_off in _segment_offsets(rom, face.base):
        for off, size, text in find_word_refs(rom, base_seg_off, limit):
            note = ""
            for ins in _window_disasm(rom, off + size, 14):
                if ins.mnemonic.startswith(('mul', 'imul')):
                    note = "%s at %s" % (ins.mnemonic + ' ' + ins.op_str,
                                         rom.seg_off(ins.address - rom.org))
                    break
                m = re.search(r'0x([0-9a-f]+)\s*$', ins.op_str)
                if m and int(m.group(1), 16) == face.stride:
                    note = "stride %d in `%s %s` at %s" % (
                        face.stride, ins.mnemonic, ins.op_str,
                        rom.seg_off(ins.address - rom.org))
            hits.append((off, text, note))
    return hits


def _segment_offsets(rom, off):
    """The 16-bit offsets this file offset can be addressed by: one per 64 KB
    aligned segment base that can reach it, in every window the image is
    mapped at.  (The convention the SLEIC code uses is CS = F000, ES = 6000,
    a font segment of 2000 or 4000, ...)"""
    out = []
    for org in rom.windows():
        flat = rom.flat(off, org)
        for seg in (((flat >> 16) - 1) << 12, (flat >> 16) << 12):
            if seg < 0:
                continue
            v = flat - (seg << 4)
            if 0 <= v <= 0xFFFF:
                out.append(v)
    return sorted(set(out))


# --------------------------------------------------------------------------
# Cross-reference: data pointers
# --------------------------------------------------------------------------

def _pointer_index_cap(face, other_faces, extra=128):
    """How far past the *rendered* face.count a pointer is still credited to
    this face.  The alphabet fit pins the face's start hard but its tail is
    punctuation the run-scorer cannot always defend (see the packed-scan
    "fuzzy tail" limit), and real string records reach into it - Sleic
    Pin-Ball's '?' / '-quote' glyphs sit past index 37.  So the *pointer*
    search range is extended well past face.count, capped only by where the
    next face in the same image begins (never claim another face's cells) and
    by the 16-bit offset ceiling, which the caller re-checks anyway."""
    cap = face.count + extra
    nxt = min((f.base for f in other_faces
              if f is not face and f.rom is face.rom and f.base > face.base),
             default=None)
    if nxt is not None:
        cap = min(cap, (nxt - face.base) // face.stride)
    return max(cap, face.count)


def xref_near_pointers(host, face, other_faces=()):
    """16-bit pointers in `host` landing exactly on a glyph boundary."""
    res = []
    cap = _pointer_index_cap(face, other_faces)
    for base_off in _segment_offsets(face.rom, face.base):
        targets = np.arange(cap, dtype=np.int64) * face.stride + base_off
        targets = targets[targets <= 0xFFFF]
        if len(targets) < face.count:
            continue
        w = host.words()
        mask = np.isin(w, targets)
        idx = np.flatnonzero(mask)
        if len(idx) < 3:
            continue
        res.append((base_off, idx))
    return res


def group_pointer_records(host, face, base_off, idx, min_len=3):
    """Consecutive 16-bit pointers = one string record.  Returns dicts, not
    tuples, so the report can print address/byte/font detail uniformly with
    the length-prefixed records (see StringRecord-shaped dicts below)."""
    recs = []
    run = []
    for p in idx:
        if run and p == run[-1] + 2:
            run.append(p)
        else:
            if len(run) >= min_len:
                recs.append(run)
            run = [p]
    if len(run) >= min_len:
        recs.append(run)
    out = []
    labels = face.scheme.labels if face.scheme else {}
    for run in recs:
        text = ""
        for p in run:
            v = int(host.words()[p])
            gi = (v - base_off) // face.stride
            text += labels.get(gi, '<%d>' % gi)
        has_count = run[0] >= 2
        cnt = int(host.words()[run[0] - 2]) if has_count else -1
        rec_off = run[0] - 2 if has_count and cnt == len(run) else run[0]
        rec_end = run[-1] + 2
        out.append(dict(
            off=rec_off, cpu=host.seg_off(rec_off), n=len(run), cnt=cnt,
            has_count=has_count and cnt == len(run), text=text,
            raw=host.data[rec_off:rec_end], byte_len=rec_end - rec_off,
            char_len=len(run),
            font_reason="implied by where its %d pointer%s land: every one "
                        "resolves to a cell inside this face (base 0x%05X, "
                        "stride %d, file 0x%05X-0x%05X)"
                        % (len(run), "" if len(run) == 1 else "s", face.base,
                           face.stride, face.base, face.end - 1)))
    out.sort(key=lambda r: (not r['has_count'], -r['n']))
    return out


def xref_far_pointers(host, face, entry_offsets, skip_ranges=()):
    """Far pointers whose (seg<<4)+off lands on an entry boundary."""
    flats = np.array(sorted(face.rom.flat(o, org)
                            for o in entry_offsets
                            for org in face.rom.windows()), dtype=np.int64)
    flats = flats[flats >= 0x1000]        # flat 0 is padding, not a pointer
    if not len(flats):
        return []
    pos, tgt = host.far_pointers()
    hit = np.flatnonzero(np.isin(tgt, flats))
    out = []
    for k in hit:
        p = int(pos[k])
        if any(lo <= p < hi for lo, hi in skip_ranges):
            continue          # inside artwork: a coincidence, not a pointer
        off = int(host.words()[p])
        seg = int(host.words()[p + 2])
        out.append((p, seg, off, (seg << 4) + off))
    return out


# --------------------------------------------------------------------------
# `[length][glyph codes]` string records (Bike Race, IO Moon)
# --------------------------------------------------------------------------

def scan_length_prefixed_strings(rom, min_len=4, max_len=40, allow_unmapped=0):
    """`[length][glyph code]` records - Bike Race's and IO Moon's encoding for
    everything that is not drawn through the pointer-array form.  `length`
    counts glyph codes one byte each, so it is also the on-screen character
    count; there is no terminator and no padding beyond whatever the ROM's
    author put there, so a record occupies exactly `1 + length` bytes with
    nothing to spare.

    The gate - every byte a known code, at least `min_len` of them, and
    letters at least 60% of the body (or 3, whichever is more) - is the one
    this scan has always used; kept as the default because it reproduces
    three independently-known answers exactly: bkcpu05's three records decode
    verbatim to PRIMERA PARTIDA / SEGUNDA PARTIDA / INSCRIPCION, bkcpu04's 133
    records include AK.SCHWANT, W.RAINEY and E.LAWSON letter-for-letter, and
    IO Moon's V1 3_01.bin yields 375 - the reference counts this tool is
    checked against (see the module docstring's Text-string cross-reference
    section).  `allow_unmapped` widens the gate to admit up to that many
    bytes outside `CODE_TO_CHAR` per record, shown as `<n>` rather than
    dropping the record; at the default of 0 every accepted record already
    decodes with every byte mapped, so raising it only ever adds records, it
    never changes the 133/3/375 baseline."""
    d = rom.data
    out = []
    i = 0
    n = len(d)
    while i < n - 1:
        ln = d[i]
        if min_len <= ln <= max_len and i + 1 + ln <= n:
            body = d[i + 1:i + 1 + ln]
            unmapped = sum(1 for c in body if c not in CODE_TO_CHAR)
            if unmapped <= allow_unmapped and all(c <= 0x40 for c in body):
                letters = sum(1 for c in body if 0x0B <= c <= 0x25)
                if letters >= max(3, int(0.6 * ln)) and body[0] != 0x0A:
                    text = "".join(CODE_TO_CHAR.get(c, '<%d>' % c) for c in body)
                    out.append(dict(off=i, cpu=rom.seg_off(i), ln=ln, body=bytes(body),
                                    raw=d[i:i + 1 + ln], text=text, byte_len=1 + ln,
                                    char_len=ln, unmapped=unmapped,
                                    call_sites=[], font=None,
                                    font_reason="undetermined - the record does not "
                                                "carry its own font; see the call-site "
                                                "search below"))
                    i += 1 + ln
                    continue
        i += 1
    return out


# --------------------------------------------------------------------------
# The `[length][glyph code]` text drawer: one shared far-call routine per
# code ROM, `CALL FAR <drawer>(far string ptr, DMD position, dispatch attr)`.
# Its `attr` argument - not the record - is what says which face draws a
# given record, so this locates the routine, recovers its dispatch table,
# matches each case to a Face by the pointer-pool slot the case loads, and
# then finds the call sites that name a record with a compile-time-constant
# address.
# --------------------------------------------------------------------------

# push bp; mov bp,sp; push es; les si,[bp+0xa]; mov di,[bp+8]; mov bx,[bp+6] -
# byte-identical in bkcpu04 (CS:06C5) and IO Moon's V1 3_01.bin (CS:0701);
# found by this prologue rather than by address, since Bike Race's parent and
# V4.1 chip sets do not agree on one (asm/bikerace-2026-09/tools/strptr.py).
_TEXT_DRAWER_PROLOGUE = bytes.fromhex('558bec06c4760a8b7e088b5e06')


def find_text_drawer(rom):
    """The four-argument text-drawer routine, by its prologue's exact bytes.
    Confirmed against docs/press_start_patch.md and
    scripts/io_moon_press_start_patch.py, which call IO Moon's copy
    (`CALL FAR F000:0701`) with exactly this stack layout: `PUSH seg; PUSH
    off` (the far string pointer), `PUSH position`, `PUSH attr`."""
    pos = rom.data.find(_TEXT_DRAWER_PROLOGUE)
    if pos < 0:
        return None
    dup = rom.data.find(_TEXT_DRAWER_PROLOGUE, pos + 1)
    return dict(off=pos, flat=rom.flat(pos), cpu=rom.seg_off(pos), ambiguous=dup >= 0)


def parse_text_drawer_dispatch(rom, drawer, window=400):
    """The `attr` argument (the drawer's `bx`) selects a case through an
    inline `cmp bx,imm / jne +3 / jmp <case>` chain ending in one
    unconditional `jmp <default>`.  Returns `[(imm_or_None, target_flat),
    ...]`, `None` marking the default (no explicit `cmp` matched)."""
    if not _HAVE_CAPSTONE:
        return []
    md = _md()
    cases = []
    pending = None
    for ins in md.disasm(rom.data[drawer['off']:drawer['off'] + window], drawer['flat']):
        if ins.mnemonic == 'nop':
            continue
        if ins.mnemonic == 'cmp' and ins.op_str.startswith('bx, '):
            try:
                pending = int(ins.op_str.split(',')[1].strip(), 0)
            except ValueError:
                pending = None
            continue
        if ins.mnemonic in ('jne', 'jnz'):
            continue
        if ins.mnemonic == 'jmp':
            try:
                tgt = int(ins.op_str, 0)
            except ValueError:
                break
            cases.append((pending, tgt))
            if pending is None:      # the unconditional default jmp ends the table
                break
            pending = None
            continue
        if pending is None and cases:
            break
    return cases


def _case_pool_slot(rom, target_flat, window=40):
    """The `les`/`lds` a dispatch case's block issues before drawing, which
    names the pointer-pool slot for the face it uses - the same slot
    `xref_far_pointers` already resolves to a Face for the code
    cross-reference printed above each face."""
    if not _HAVE_CAPSTONE:
        return None
    off = target_flat - rom.org
    for ins in _window_disasm(rom, off, 10):
        if ins.mnemonic in ('les', 'lds'):
            m = re.search(r'0x([0-9a-f]+)\]', ins.op_str)
            if m:
                return int(m.group(1), 16)
    return None


def find_text_drawer_call_sites(rom, drawer, drawer_seg=0xF000):
    """Every `CALL FAR <drawer>` preceded immediately by four push-immediate
    instructions - `PUSH seg; PUSH off; PUSH position; PUSH attr`, byte
    pattern only, no full disassembly (this ROM family mis-decodes as a
    flat linear sweep - see the module's ndisasm caveat).  A call that builds
    its string pointer at runtime (a RAM buffer, a score readout) pushes a
    register or a memory operand instead and is invisible to this scan; it
    is not claimed as a miss, just not found."""
    drawer_off = drawer['flat'] - (drawer_seg << 4)
    needle = bytes([0x9A]) + drawer_off.to_bytes(2, 'little') + drawer_seg.to_bytes(2, 'little')
    sites = []
    pos = rom.data.find(needle)
    while pos >= 0:
        sites.append(pos)
        pos = rom.data.find(needle, pos + 1)
    return sites


def _preceding_immediate_pushes(rom, callpos, n=4):
    if not _HAVE_CAPSTONE:
        return None
    md = _md()
    for total in range(2 * n, 3 * n + 1):
        start = callpos - total
        if start < 0:
            continue
        try:
            ins_list = list(md.disasm(rom.data[start:callpos], rom.flat(start)))
        except Exception:
            continue
        if len(ins_list) != n or sum(i.size for i in ins_list) != total:
            continue
        if not all(i.mnemonic == 'push' and re.match(r'^0x[0-9a-f]+$', i.op_str)
                  for i in ins_list):
            continue
        return [int(i.op_str, 16) for i in ins_list]
    return None


def _resolve_flat(flat, roms):
    """Which ROM (and file offset) a flat address falls in, checking every
    window each image is mapped at."""
    for r in roms:
        for org in r.windows():
            if org <= flat < org + len(r.data):
                return r, flat - org
    return None, None


def analyze_text_drawer_strings(roms, all_faces, entry_offsets, args):
    """Run the whole drawer/dispatch/call-site pipeline over every supplied
    ROM.  Mutates each length-prefixed record in place with `call_sites`,
    `font` and `font_reason`, and returns `{rom.name: drawer-info-or-None}`
    for the report header."""
    records = {}
    for rom in roms:
        records[rom.name] = scan_length_prefixed_strings(
            rom, allow_unmapped=args.allow_unmapped)
    by_off = {(r.name, rec['off']): rec for r in roms for rec in records[r.name]}
    faces_by_rom = {name: all_faces[name][0] for name in all_faces}

    drawers = {}
    for rom in roms:
        drawer = find_text_drawer(rom)
        if drawer is None:
            continue
        cases = parse_text_drawer_dispatch(rom, drawer)
        skip = [(t[0], t[1]) for t in entry_offsets.get('chains:' + rom.name, ())]
        slot_face = {}
        for faces in faces_by_rom.values():
            for face in faces:
                for p, seg, off, flat in xref_far_pointers(
                        rom, face, [face.cell_offset(0)], skip):
                    for slot in _segment_offsets(rom, p):
                        slot_face[slot] = face
        case_face = {}
        for attr, tgt in cases:
            slot = _case_pool_slot(rom, tgt)
            case_face[attr] = dict(face=slot_face.get(slot), slot=slot, target=tgt)
        default = case_face.get(None)

        sites = find_text_drawer_call_sites(rom, drawer)
        resolved = 0
        for callpos in sites:
            pushes = _preceding_immediate_pushes(rom, callpos)
            if not pushes:
                continue
            seg, offv, posv, attrv = pushes
            trom, toff = _resolve_flat((seg << 4) + offv, roms)
            if trom is None:
                continue
            rec = by_off.get((trom.name, toff))
            if rec is None:
                continue
            resolved += 1
            case = case_face.get(attrv, default)
            rec['call_sites'].append(dict(
                cpu=rom.seg_off(callpos), off=callpos, attr=attrv, position=posv,
                face=case['face'] if case else None,
                explicit=attrv in case_face))

        for rec in records[rom.name]:
            faces_seen = {cs['face'] for cs in rec['call_sites'] if cs['face']}
            if len(faces_seen) == 1:
                cs = rec['call_sites'][0]
                rec['font'] = next(iter(faces_seen))
                rec['font_reason'] = (
                    "call site %s pushes attr=0x%02X (%s dispatch case), whose "
                    "block loads this face's pointer-pool slot"
                    % (cs['cpu'], cs['attr'],
                       "an explicit" if cs['explicit'] else "the default"))
            elif len(faces_seen) > 1:
                rec['font'] = None
                rec['font_reason'] = ("undetermined - call sites disagree on attr "
                                      "(%s)" % ", ".join(
                                          "0x%02X" % cs['attr']
                                          for cs in rec['call_sites']))
            elif rec['call_sites']:
                rec['font'] = None
                rec['font_reason'] = ("undetermined - %d call site(s) found, but "
                                      "the dispatch case's face could not be "
                                      "resolved" % len(rec['call_sites']))
            # else: leave the "no call site found" reason scan_ set

        drawers[rom.name] = dict(info=drawer, cases=cases, case_face=case_face,
                                 call_sites=len(sites), resolved=resolved)

    # A record with no resolved call site may still be live code: something
    # may hold a raw far pointer to it (a lookup table, or a call this
    # scanner's push-immediate pattern does not match) without our being able
    # to say which font draws it.  That is a different, weaker claim than a
    # resolved font, so it only fills in when nothing else has already
    # explained the record - it never overrides a resolved font.
    for owner in roms:
        for rec in records[owner.name]:
            if rec['font'] is not None or rec['call_sites']:
                continue
            flats = {owner.flat(rec['off'], o) for o in owner.windows()}
            hit = None
            for host in roms:
                pos, tgt = host.far_pointers()
                m = np.flatnonzero(np.isin(tgt, np.array(sorted(flats),
                                                          dtype=np.int64)))
                if len(m):
                    hit = (host, int(pos[m[0]]))
                    break
            if hit:
                host, p = hit
                rec['font_reason'] = (
                    "undetermined - no draw call was matched, but a far "
                    "pointer to this record sits at %s in %s (a table entry, "
                    "or a call this scan's push-immediate pattern misses)"
                    % (host.seg_off(p), host.name))
    return records, drawers


# --------------------------------------------------------------------------
# org inference for a ROM with no reset vector
# --------------------------------------------------------------------------

def find_windows(rom, hosts, entry_offsets, min_hits=8):
    """64 KB bases, other than the primary one, at which this image's entry
    boundaries are the target of aligned far pointers.  This is how the second
    window of a doubly-mapped ROM is discovered rather than assumed."""
    if not entry_offsets:
        return []
    ent = np.array(sorted(entry_offsets), dtype=np.int64)
    out = []
    for org in range(0, 0x100000, 0x10000):
        if org == rom.org or org + len(rom.data) > 0x100000:
            continue
        tgt = ent + org
        tgt = tgt[tgt >= 0x1000]
        if not len(tgt):
            continue
        hit = np.zeros(len(tgt), dtype=bool)
        for h in hosts:
            hit |= np.isin(tgt, h.far_pointers()[1])
        n = int(hit.sum())
        if n >= min_hits:
            out.append((org, n))
    out.sort(key=lambda x: -x[1])
    return out


def infer_org(rom, others, entry_offsets):
    """Pick the 64 KB base at which the *most distinct* entry boundaries of this
    image are pointed at by a far pointer in one of the other images.  Distinct
    targets, not hit counts: a byte pattern that happens to be a common
    constant would otherwise win on volume alone."""
    if not entry_offsets or not others:
        return None
    ent = np.array(sorted(entry_offsets), dtype=np.int64)
    best = None
    for org in range(0, 0x100000, 0x10000):
        if org + len(rom.data) > 0x100000:
            break
        tgt = ent + org
        tgt = tgt[tgt >= 0x1000]         # nothing points artwork at the IVT
        if not len(tgt):
            continue
        hit = np.zeros(len(tgt), dtype=bool)
        for o in others:
            hit |= np.isin(tgt, o.far_pointers()[1])
        n = int(hit.sum())
        if best is None or n > best[1]:
            best = (org, n)
    if best and best[1] >= 4:
        return best
    return None


# --------------------------------------------------------------------------
# Report
# --------------------------------------------------------------------------

def hr(ch='=', n=78):
    return ch * n


def report(roms, args):
    all_faces = {}
    entry_offsets = {}

    for rom in roms:
        faces, tables = scan_header3(rom, min_glyphs=args.min_header_glyphs)
        ents = set()
        for _, _, e in tables:
            ents.update(o for o, _, _, _ in e)
        entry_offsets[rom.name] = ents
        entry_offsets['chains:' + rom.name] = [(t[0], t[1]) for t in tables]
        packed = []
        weak = 0
        if args.layout in ('auto', 'packed'):
            raw = scan_packed(rom, hmin=args.min_height, hmax=args.max_height,
                              widths=tuple(args.widths),
                              min_glyphs=args.min_glyphs)
            # drop packed hits that are just a re-reading of a chained table
            raw = [f for f in raw
                   if not any(t[0] <= f.base < t[1] for t in tables)]
            packed, weak = rank_packed(raw, min_fit=args.min_fit)
        if args.layout == 'header3':
            packed = []
        if args.layout == 'packed':
            faces = []
        all_faces[rom.name] = (faces + packed, tables, weak)

    # ROMs with no reset vector: infer the org from everyone else's pointers
    for rom in roms:
        if rom.org == 0 and entry_offsets[rom.name]:
            others = [r for r in roms if r is not rom]
            got = infer_org(rom, others, entry_offsets[rom.name])
            if got:
                rom.org = got[0]
                rom.org_why = ("inferred: with this base, %d distinct entry "
                               "boundaries are the target of a 64 KB-aligned "
                               "far pointer in the other image(s)" % got[1])
    # A code ROM can be mapped twice - IO Moon's ROM1 is, by UMCS over the whole
    # chip and LMCS over its low quarter (F1) - and the font pointers use the
    # second window.  Look for it wherever the primary org came from the reset
    # vector; a graphics ROM behind one chip-select line has only the one.
    for rom in roms:
        if not rom.org_why.startswith('80188 reset vector'):
            continue
        extra = find_windows(rom, roms, entry_offsets[rom.name])[:1]
        rom.alt_orgs = [o for o, _ in extra]
        rom.alt_why = extra

    # fit every face's scheme up front, so both the code below and the text-
    # drawer analysis (which needs a settled face list to match dispatch
    # cases against) see the final face set
    for rom in roms:
        faces, tables, weak = all_faces[rom.name]
        for face in faces:
            if face.scheme is None:
                face.scheme = fit_scheme(face)
            if face.planes > 1 and face.scheme.score < 5.0:
                # a shaded face draws a bright outline in plane 0 and its fill
                # in plane 1, so plane 0 alone is hollow and reads as holes
                face.set_plane_mode('p0|p1')
                alt = fit_scheme(face)
                if alt.score > face.scheme.score:
                    face.scheme = alt
                    face.evidence += ("; glyphs read as plane 0 OR plane 1, "
                                      "which fits better than plane 0 alone "
                                      "(%.1f against %.1f) - a shaded face"
                                      % (alt.score, face.fit))
                else:
                    face.set_plane_mode('p0')

    text_records, drawers = ({r.name: [] for r in roms}, {}) if not args.strings \
        else analyze_text_drawer_strings(roms, all_faces, entry_offsets, args)
    face_records = {}
    for rname, recs in text_records.items():
        for rec in recs:
            if rec['font'] is not None:
                face_records.setdefault(id(rec['font']), []).append(rec)

    font_filter = None
    if args.font is not None:
        want = int(args.font, 0)
        cands = [f for faces, _, _ in all_faces.values() for f in faces
                 if want == f.base or any(f.rom.flat(f.base, o) == want
                                          for o in f.rom.windows())]
        if not cands:
            print("--font 0x%X matches no face found in these ROMs" % want,
                  file=sys.stderr)
        else:
            font_filter = cands[0]

    for rom in roms:
        faces, tables, weak = all_faces[rom.name]
        if font_filter is not None and font_filter.rom is not rom:
            continue
        print(hr())
        print("%s  (%d bytes)" % (rom.name, len(rom.data)))
        print("  org 0x%05X - %s" % (rom.org, rom.org_why))
        for o, n in getattr(rom, 'alt_why', []):
            print("  also mapped at 0x%05X - %d entry boundaries there are the "
                  "target of an aligned far pointer" % (o, n))
        if tables:
            print("  header chains: " + ", ".join(
                "0x%05X-0x%05X (%d entries)" % (t[0], t[1], len(t[2]))
                for t in tables[:6]))
        print(hr())
        if weak and font_filter is None:
            print("  %d packed run%s scored below --min-fit %.1f and were "
                  "dropped as noise" % (weak, "" if weak == 1 else "s",
                                        args.min_fit))
        if not faces:
            print("  no font table found\n")
        sorted_faces = sorted(faces, key=lambda f: f.base)
        for k, face in enumerate(sorted_faces, 1):
            if font_filter is not None and face is not font_filter:
                continue
            print_face(k, face, roms, entry_offsets, args, sorted_faces,
                      face_records.get(id(face), []))

        if args.strings and font_filter is None:
            drawer = drawers.get(rom.name)
            if drawer:
                print("  [length][glyph code] text drawer: %s (%s), %d "
                      "dispatch case%s, %d CALL FAR site%s found, %d resolved "
                      "to a record found in these ROMs"
                      % (drawer['info']['cpu'], rom.name,
                         len(drawer['cases']),
                         "" if len(drawer['cases']) == 1 else "s",
                         drawer['call_sites'],
                         "" if drawer['call_sites'] == 1 else "s",
                         drawer['resolved']))
                for attr, case in sorted(drawer['case_face'].items(),
                                         key=lambda kv: (kv[0] is None, kv[0])):
                    tag = "default" if attr is None else "attr=0x%02X" % attr
                    face_desc = ("FACE at file 0x%05X" % case['face'].base
                                if case['face'] else "no face resolved")
                    print("    %-12s -> target 0x%05X, pool slot %s -> %s"
                          % (tag, case['target'],
                             "0x%04X" % case['slot'] if case['slot'] is not None
                             else "?", face_desc))
            recs = text_records.get(rom.name, [])
            undetermined = [r for r in recs if r['font'] is None]
            if recs:
                print("  [length][glyph code] string records in %s: %d found "
                      "(0x%05X-0x%05X), %d with a font resolved by a call "
                      "site, %d undetermined"
                      % (rom.name, len(recs), recs[0]['off'], recs[-1]['off'],
                         len(recs) - len(undetermined), len(undetermined)))
            if undetermined:
                print("  ... records with no font resolved:")
                for rec in undetermined[:args.max_strings]:
                    print("    %s  file 0x%05X  %2d bytes/%2d chars  \"%s\""
                          % (rec['cpu'], rec['off'], rec['byte_len'],
                             rec['char_len'], rec['text']))
                    print("        raw: %s" % rec['raw'].hex())
                    print("        font: %s" % rec['font_reason'])
                if len(undetermined) > args.max_strings:
                    print("    ... %d more" % (len(undetermined) - args.max_strings))
            if recs:
                print("")


def print_face(k, face, roms, entry_offsets, args, other_faces=(), face_records=()):
    rom = face.rom
    print("FACE %d  [%s]  %s" % (k, face.layout, face.geometry()))
    a = face.addrs()
    print("  file 0x%05X-0x%05X   CPU %s%s"
          % (face.base, face.end - 1, a[0],
             "" if len(a) == 1 else "  (second window: %s)" % ", ".join(a[1:])))
    print("  %s" % face.evidence)
    sch = face.scheme
    core = [i for i, c in sch.labels.items() if c != ' '] or range(face.count)
    bb = [ink_bbox(face.rows(i), face.w) for i in core]
    bb = [b for b in bb if b]
    if bb:
        print("  ink of the %s glyphs measures %d px wide x %d rows (columns "
              "%d-%d, rows %d-%d of the cell)"
              % ("labelled" if sch.labels else "run's",
                 max(b[1] for b in bb) - min(b[0] for b in bb) + 1,
                 max(b[3] for b in bb) - min(b[2] for b in bb) + 1,
                 min(b[0] for b in bb), max(b[1] for b in bb),
                 min(b[2] for b in bb), max(b[3] for b in bb)))
    conf = ("confident" if sch.score >= 8 else
            "plausible" if sch.score >= 5 else
            "weak - read the glyphs below, not this line")
    print("  index scheme: %s   [fit %.1f, %s, %s]"
          % (sch.summary(face), sch.score, sch.kind, conf))
    for note in sch.notes:
        print("    %s" % note)
    if sch.score < 5.0:
        print("    no alphabet fits this run: it is a constant-geometry run of "
              "cells, which may be a sprite strip rather than a font")
    if args.render != 'none':
        print("")
        print(render_face(face, per_line=args.per_line))

    # --- code that indexes it
    for host in roms:
        hits = xref_code(host, face) if host is rom or face.rom.org else []
        if hits:
            print("  code in %s that names the base (%d site%s):"
                  % (host.name, len(hits), "" if len(hits) == 1 else "s"))
            for off, text, note in hits[:args.max_refs]:
                print("    %s  %-28s %s" % (host.seg_off(off), text, note))
            if len(hits) > args.max_refs:
                print("    ... %d more" % (len(hits) - args.max_refs))

    # --- near pointers -> string records (Sleic Pin-Ball's word-count +
    # word-glyph-pointer encoding: see scan_pointer_string_records's docstring)
    limit = None if args.font is not None else args.max_refs
    for host in roms:
        for base_off, idx in xref_near_pointers(host, face, other_faces):
            recs = [r for r in group_pointer_records(host, face, base_off, idx)
                    if _record_credible(r)]
            if not recs:
                continue
            print("  string records of near pointers into this face, in %s "
                  "(%d word%s in the image land on a glyph boundary):"
                  % (host.name, len(idx), "" if len(idx) == 1 else "s"))
            shown = recs if limit is None else recs[:limit]
            for r in shown:
                tag = "count=%d" % r['cnt'] if r['has_count'] else "no count word"
                print("    %s  file 0x%05X  %-14s %2d ptr%s  %2d bytes/%2d chars  \"%s\""
                      % (r['cpu'], r['off'], tag, r['n'],
                         " " if r['n'] == 1 else "s", r['byte_len'], r['char_len'],
                         r['text']))
                print("        raw: %s" % r['raw'].hex())
                print("        font: %s" % r['font_reason'])
            if limit is not None and len(recs) > limit:
                print("    ... %d more records" % (len(recs) - limit))

    # --- far pointers, and the code that loads the pool slot they sit in
    for host in roms:
        skip = [(t[0], t[1]) for t in entry_offsets.get('chains:' + host.name, ())]
        hits = xref_far_pointers(host, face, [face.cell_offset(0)], skip)
        hits = [h for h in hits if not any(lo <= h[0] < hi for lo, hi in skip)]
        if not hits:
            continue
        print("  far pointer%s to this face's first entry in %s:"
              % ("" if len(hits) == 1 else "s", host.name))
        for p, seg, off, flat in hits[:args.max_refs]:
            print("    %s  ->  %04X:%04X" % (host.seg_off(p), seg, off))
            for slot in _segment_offsets(host, p):
                for off2, size, text in find_word_refs(host, slot, 24):
                    if "[0x%x]" % slot not in text \
                            or text.split()[0] not in ('les', 'lds', 'mov',
                                                       'lea', 'push'):
                        continue
                    print("        the slot is loaded at %s by `%s`"
                          % (host.seg_off(off2), text))
        if len(hits) > args.max_refs:
            print("    ... %d more" % (len(hits) - args.max_refs))

    # --- [length][glyph code] records this face draws (Bike Race, IO Moon):
    # the record does not name its own font, the call site's `attr` does -
    # see analyze_text_drawer_strings
    if face_records:
        print("  [length][glyph code] string records drawn with this face "
              "(%d found):" % len(face_records))
        shown = face_records if args.font is not None else face_records[:args.max_refs]
        for rec in shown:
            print("    %s  file 0x%05X  %2d bytes/%2d chars  \"%s\""
                  % (rec['cpu'], rec['off'], rec['byte_len'], rec['char_len'],
                     rec['text']))
            print("        raw: %s" % rec['raw'].hex())
            print("        font: %s" % rec['font_reason'])
            for cs in rec['call_sites']:
                print("        drawn at %s  push seg:off (string), 0x%04X "
                      "(position), 0x%02X (attr)"
                      % (cs['cpu'], cs['position'], cs['attr']))
        if args.font is None and len(face_records) > args.max_refs:
            print("    ... %d more" % (len(face_records) - args.max_refs))
    print("")


# --------------------------------------------------------------------------

def main(argv=None):
    ap = argparse.ArgumentParser(
        description="Find bitmap font tables in SLEIC pinball ROMs.",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="ROM arguments may carry a mapping base: rom.bin@0x40000")
    ap.add_argument('roms', nargs='+', help="ROM image(s), optionally path@org")
    ap.add_argument('--layout', choices=('auto', 'packed', 'header3'),
                    default='auto')
    ap.add_argument('--min-height', type=int, default=5)
    ap.add_argument('--max-height', type=int, default=26)
    ap.add_argument('--widths', default='1,2',
                    help="bytes per row to try in the packed scan (default 1,2)")
    ap.add_argument('--min-glyphs', type=int, default=16,
                    help="shortest packed run to report (default 16)")
    ap.add_argument('--min-fit', type=float, default=5.0,
                    help="lowest alphabet-fit score a packed run may have "
                         "(default 5.0; the real faces score 12, noise under 4)")
    ap.add_argument('--min-header-glyphs', type=int, default=6,
                    help="shortest constant-geometry run in a chain (default 6)")
    ap.add_argument('--render', choices=('all', 'none'), default='all')
    ap.add_argument('--per-line', type=int, default=16)
    ap.add_argument('--max-refs', type=int, default=16)
    ap.add_argument('--max-strings', type=int, default=12)
    ap.add_argument('--no-strings', dest='strings', action='store_false')
    ap.add_argument('--allow-unmapped', type=int, default=0, metavar='N',
                    help="accept [length][glyph code] records with up to N "
                         "codes outside the known alphabet, shown as <n> "
                         "(default 0: every accepted record already decodes "
                         "in full - see scan_length_prefixed_strings)")
    ap.add_argument('--font', metavar='ADDR',
                    help="list only the face at this file offset (or any "
                         "window's CPU-visible address), with its full "
                         "string inventory un-truncated - 'given a font "
                         "table, which strings use it'")
    args = ap.parse_args(argv)
    args.widths = [int(x) for x in args.widths.split(',')]

    roms = []
    for spec in args.roms:
        org = None
        path = spec
        if '@' in spec:
            path, o = spec.rsplit('@', 1)
            org = int(o, 0)
        if not os.path.exists(path):
            ap.error("no such file: %s" % path)
        roms.append(Rom(path, org))

    if not _HAVE_CAPSTONE:
        print("note: capstone is not installed; the code cross-reference is off",
              file=sys.stderr)
    report(roms, args)
    return 0


if __name__ == '__main__':
    sys.exit(main())
