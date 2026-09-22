#!/usr/bin/env python3
"""
SLEIC bitmap font-table finder
==============================

Locates bitmap **font tables** in the ROMs of the three SLEIC pinball machines
(Sleic Pin-Ball, Bike Race, IO Moon), renders every glyph it finds as ASCII,
infers the index scheme, and reports the code and data that reach the table.

Usage:
    python3 scripts/find_font_tables.py <rom>[@org] ...

    python3 scripts/find_font_tables.py roms/related-machines/sleic-pin-ball/sp03-1_1.rom
    python3 scripts/find_font_tables.py "roms/1.3 IPDB latest/V1 3_01.bin"
    python3 scripts/find_font_tables.py roms/related-machines/bike-race/bkcpu0{4,5,6}.bin

Give every ROM of a machine on one command line: each table is cross-referenced
against *all* of them, which is what finds the pointers in the code ROM that
reach a font living on a graphics ROM.

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
* **`[length][glyph codes]` string records** - a separate scan of each image for
  the length-prefixed string form Bike Race and IO Moon use, decoded with
  `0x0A` = space, `0x0B..0x25` = `A..Z` with `Ñ` after `N`.

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
many word glyph pointers - 13 of them into the 10-row face, 160 into the 8-row -
and they decode straight to Spanish: `F000:5308` = `RECORD JUGADOR`,
`F000:0B44` = `SI DAS A LA BOLA`, `F000:0BCB` = ` ? BOLA EXTRA ?` (the `?` is a glyph the fit does not label).

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
  ones are noisy and records under four characters are not reported.

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
    start, n, cnt, text = rec
    if n < 4:
        return False
    if cnt == n:
        return True
    return sum(1 for c in text if c.isalpha()) >= 3


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

def xref_near_pointers(host, face):
    """16-bit pointers in `host` landing exactly on a glyph boundary."""
    res = []
    for base_off in _segment_offsets(face.rom, face.base):
        targets = np.arange(face.count, dtype=np.int64) * face.stride + base_off
        if targets[-1] > 0xFFFF:
            continue
        w = host.words()
        mask = np.isin(w, targets)
        idx = np.flatnonzero(mask)
        if len(idx) < 3:
            continue
        res.append((base_off, idx))
    return res


def group_pointer_records(host, face, base_off, idx, min_len=3):
    """Consecutive 16-bit pointers = one string record."""
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
            text += labels.get(gi, '?')
        cnt = int(host.words()[run[0] - 2]) if run[0] >= 2 else -1
        out.append((run[0], len(run), cnt, text))
    out.sort(key=lambda r: (r[2] != r[1], -r[1]))
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

def scan_length_prefixed_strings(rom, min_len=4, max_len=40):
    d = rom.data
    out = []
    i = 0
    n = len(d)
    while i < n - 1:
        ln = d[i]
        if min_len <= ln <= max_len and i + 1 + ln <= n:
            body = d[i + 1:i + 1 + ln]
            if all(c in CODE_TO_CHAR for c in body):
                letters = sum(1 for c in body if 0x0B <= c <= 0x25)
                if letters >= max(3, int(0.6 * ln)) and body[0] != 0x0A:
                    out.append((i, ln, "".join(CODE_TO_CHAR[c] for c in body)))
                    i += 1 + ln
                    continue
        i += 1
    return out


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

    for rom in roms:
        faces, tables, weak = all_faces[rom.name]
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
        if weak:
            print("  %d packed run%s scored below --min-fit %.1f and were "
                  "dropped as noise" % (weak, "" if weak == 1 else "s",
                                        args.min_fit))
        if not faces:
            print("  no font table found\n")
        for k, face in enumerate(sorted(faces, key=lambda f: f.base), 1):
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
            print_face(k, face, roms, entry_offsets, args)

        if args.strings:
            recs = scan_length_prefixed_strings(rom)
            if recs:
                print("  [length][glyph code] string records: %d found "
                      "(0x%05X-0x%05X)" % (len(recs), recs[0][0], recs[-1][0]))
                for off, ln, txt in recs[:args.max_strings]:
                    print("    %s  len=%-3d %s" % (rom.seg_off(off), ln, txt))
                if len(recs) > args.max_strings:
                    print("    ... %d more" % (len(recs) - args.max_strings))
                print("")


def print_face(k, face, roms, entry_offsets, args):
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

    # --- near pointers -> string records
    for host in roms:
        for base_off, idx in xref_near_pointers(host, face):
            recs = [r for r in group_pointer_records(host, face, base_off, idx)
                    if _record_credible(r)]
            if not recs:
                continue
            print("  string records of near pointers into this face, in %s "
                  "(%d word%s in the image land on a glyph boundary):"
                  % (host.name, len(idx), "" if len(idx) == 1 else "s"))
            for start, n, cnt, text in recs[:args.max_refs]:
                tag = "count=%d" % cnt if cnt == n else "no count word"
                print("    %s  %-14s %2d pointers  \"%s\""
                      % (host.seg_off(start - 2), tag, n, text))
            if len(recs) > args.max_refs:
                print("    ... %d more records" % (len(recs) - args.max_refs))

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
