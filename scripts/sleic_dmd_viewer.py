#!/usr/bin/env python3
"""
SLEIC DMD graphics viewer -- IO Moon, Bike Race and Sleic Pin-Ball
==================================================================

All three SLEIC machines drive the same panel: 128x32 dots, two bitplanes,
16 bytes per row per plane, MSB = leftmost pixel, a set bit is lit, and no
machine inverts -- the firmware ANDs, ORs and copies these bytes and never NOTs
or XORs them.  Plane 0 is the MSB plane on all three, so the displayed level is

    level = 2 * plane0_bit + plane1_bit          (0 off .. 3 full bright)

(`sleic_build_dmd_frame` in `pinmame/src/wpc/sleic.c`, and its field-weighting
comment, is the authority; IO Moon's plane-0 weight is the PIC16C57's 200:30
row-hold ratio, finding F13.)

What differs between the machines is not the frame format but **how the graphics
are stored in ROM and how you find them**:

IO Moon and Bike Race -- header records
---------------------------------------
Both store images as a 6-byte header followed by whole bitplanes:

    word 0   rows
    word 1   bytes per row
    word 2   rows * bytes per row   (= one plane's size in bytes)
    then `planes` planes of that size, plane 0 first

IO Moon uses **2 planes** per record; Bike Race uses **3** -- plane 0, plane 1
and a mask.  Both facts are measured here rather than assumed: walking every
header in each ROM and asking whether a 2-plane or a 3-plane successor lands on
another valid header gives 393:0 for IO Moon's ROM2 and 145:89 / 89:55 the other
way for Bike Race's ROM 05 / ROM 06.

    NOTE on the record header.  `asm/bikerace-2026-09/reports/v41_sprite_table.md`
    describes Bike Race's header as "W (word), 1 (word), H (word)", with
    ceil(W/8)*H bytes per plane.  That reading fits only the 8-pixel-wide
    sprites, where bytes-per-row happens to be 1 and rows*1 happens to equal H.
    It is refuted by any wider record: `bkcpu06.bin` at 0x0636 reads
    `17 00 02 00 2E 00` (word 1 = 2, not 1) and at 0x1206 reads
    `20 00 11 00 20 02` (32 rows x 17 bytes = 0x220), and both decode to clean
    artwork only under the (rows, bytesPerRow, planeSize) reading -- which is
    also byte-for-byte the same header IO Moon uses (`20 00 10 00 00 02` =
    32 rows x 16 bytes, 0x200 per plane).  One format, three machines.

Sleic Pin-Ball -- no headers at all
-----------------------------------
`sp03-1_1.rom` (the 80188 code ROM, the machine's only ROM that holds graphics)
contains **zero** records in that format.  Its 80188 blits straight out of the
code segment with the source address as an immediate, so the images are raw,
unheadered bitmaps and the *code* is the index.  Two idioms:

  * an inline blit -- `mov si,IMM / mov di,IMM / mov cx,ROWS / push cx / push di
    / mov cx,BPR / ...` -- names a bitmap, its geometry and where on the panel it
    lands.  A second `mov al,cs:[si+200h]` in the loop means the record carries a
    second plane at +0x200, exactly like IO Moon's flat pair;
  * a call to one of five shared "column strip" blitters, where `si` names a word
    table (count, then one CS pointer per 8-pixel column) and the callee's own
    `mov cx,ROWS` gives the strip height.  That is how Pin-Ball composes text.

`--blits` lists both; `--index` renders both.  Source addresses are CS-relative
and CS is taken to be the 64 KB block the code itself sits in (file 0x00000 =
E000, file 0x10000 = F000 -- `sp03` loads at 0xE0000, see SLEIC_ROMSTART4).

Cross-checking against the emulator
-----------------------------------
`pinmame/build-probe/sdl3pinmame` with `SLEIC_DMD_DUMP=<prefix>` writes one
128x32 P5 PGM per submitted frame (levels 0/85/170/255).  `--locate FILE.pgm`
takes such a frame and finds its bitplanes in the ROM, which is how the
Pin-Ball frame at `sp03:0x19943` and Bike Race's font records were confirmed.

Requires nothing but the standard library (PNG output included).
"""

import argparse
import os
import struct
import sys
import zlib

DMD_W = 128
DMD_H = 32

# Same palette as dmd_viewer.py, so PNGs from the two scripts look alike.
DMD_COLORS = [(0x00, 0x00, 0x00), (0x55, 0x22, 0x00), (0xAA, 0x44, 0x00), (0xFF, 0x66, 0x00)]
ASCII_RAMP = " .:#"

# Header-record plausibility bounds.  32x16 is a full panel frame; 34 bytes per
# row leaves room for the 17-byte-wide records Bike Race really uses, and 64 rows
# for the taller-than-panel strips (IO Moon's scrolling credits are 55 rows).
MAX_ROWS = 64
MAX_BPR = 34
MIN_PLANE = 4


# ---------------------------------------------------------------------------
# decoding
# ---------------------------------------------------------------------------

def unpack_plane(data, rows, bpr):
    """One bitplane -> rows x (bpr*8) list of 0/1.  MSB = leftmost pixel."""
    out = []
    for y in range(rows):
        row = data[y * bpr:(y + 1) * bpr]
        if len(row) < bpr:
            row = row + bytes(bpr - len(row))
        line = []
        for b in row:
            for k in range(8):
                line.append(1 if b & (0x80 >> k) else 0)
        out.append(line)
    return out


def levels_from_planes(p0, p1, rows, bpr):
    """level = 2*plane0 + plane1 -- the panel's weighting on all three machines."""
    a = unpack_plane(p0, rows, bpr)
    b = unpack_plane(p1, rows, bpr) if p1 is not None else None
    out = []
    for y in range(rows):
        if b is None:
            out.append([3 * v for v in a[y]])
        else:
            out.append([2 * a[y][x] + b[y][x] for x in range(bpr * 8)])
    return out


def render_ascii(levels, ramp=ASCII_RAMP, border=True):
    w = len(levels[0]) if levels else 0
    lines = []
    if border:
        lines.append("+" + "-" * w + "+")
    for row in levels:
        body = "".join(ramp[v] for v in row)
        lines.append(("|" + body + "|") if border else body)
    if border:
        lines.append("+" + "-" * w + "+")
    return "\n".join(lines)


def write_png(path, levels, scale=4, gap=1):
    """Indexed-colour PNG with the dot-matrix gap, no third-party modules."""
    h = len(levels)
    w = len(levels[0]) if h else 0
    ow, oh = w * scale, h * scale
    rows = []
    for y in range(oh):
        sy = y // scale
        blank_y = (y % scale) >= (scale - gap) if gap > 0 else False
        line = bytearray(ow)
        if not blank_y:
            src = levels[sy]
            for x in range(ow):
                if gap > 0 and (x % scale) >= (scale - gap):
                    continue
                line[x] = src[x // scale]
        rows.append(bytes(line))

    def chunk(tag, payload):
        return (struct.pack(">I", len(payload)) + tag + payload
                + struct.pack(">I", zlib.crc32(tag + payload) & 0xFFFFFFFF))

    raw = b"".join(b"\x00" + r for r in rows)
    png = b"\x89PNG\r\n\x1a\n"
    png += chunk(b"IHDR", struct.pack(">IIBBBBB", ow, oh, 8, 3, 0, 0, 0))
    png += chunk(b"PLTE", b"".join(bytes(c) for c in DMD_COLORS))
    png += chunk(b"IDAT", zlib.compress(raw, 9))
    png += chunk(b"IEND", b"")
    with open(path, "wb") as f:
        f.write(png)


# ---------------------------------------------------------------------------
# locator 1: header records  (IO Moon, Bike Race)
# ---------------------------------------------------------------------------

def parse_header(data, off):
    """(rows, bpr, planeSize) if a valid record header stands at `off`, else None."""
    if off + 6 > len(data):
        return None
    rows, bpr, size = struct.unpack("<HHH", data[off:off + 6])
    if not (1 <= rows <= MAX_ROWS and 1 <= bpr <= MAX_BPR):
        return None
    if size != rows * bpr or size < MIN_PLANE:
        return None
    return rows, bpr, size


def scan_records(data, planes, lo=0, hi=None, min_lit=1):
    """Every offset in [lo,hi) carrying a valid header.  This is what finds IO
    Moon's ~400 animation frames -- they are not one contiguous chain."""
    hi = len(data) if hi is None else min(hi, len(data))
    out = []
    off = lo
    while off < hi:
        hdr = parse_header(data, off)
        if hdr:
            rows, bpr, size = hdr
            end = off + 6 + planes * size
            if end <= len(data):
                lit = sum(bin(b).count("1") for b in data[off + 6:off + 6 + planes * size])
                if lit >= min_lit:
                    out.append({"offset": off, "rows": rows, "bpr": bpr,
                                "size": size, "planes": planes, "kind": "record",
                                "lit": lit})
        off += 1
    return out


def chain_records(data, start, planes, limit=4096):
    """Walk records back-to-back from `start`.  Bike Race's sprite/font tables are
    laid out this way (ROM 05: 131 records from 0; ROM 06: 54)."""
    out = []
    off = start
    while len(out) < limit:
        hdr = parse_header(data, off)
        if not hdr:
            break
        rows, bpr, size = hdr
        if off + 6 + planes * size > len(data):
            break
        out.append({"offset": off, "rows": rows, "bpr": bpr, "size": size,
                    "planes": planes, "kind": "record",
                    "lit": sum(bin(b).count("1")
                               for b in data[off + 6:off + 6 + planes * size])})
        off += 6 + planes * size
    return out


def record_levels(data, rec, plane_pages=False):
    """Levels for a record.  `plane_pages` renders each plane as its own 1-bit
    image instead of combining them -- the right view for IO Moon's ROM1 static
    screens, whose two 512-byte halves are the English and Spanish bitmaps rather
    than two bitplanes (docs/dmd_graphics.md)."""
    o, rows, bpr, size = rec["offset"] + 6, rec["rows"], rec["bpr"], rec["size"]
    planes = [data[o + i * size:o + (i + 1) * size] for i in range(rec["planes"])]
    if plane_pages:
        return [levels_from_planes(p, None, rows, bpr) for p in planes]
    p1 = planes[1] if len(planes) > 1 else None
    return [levels_from_planes(planes[0], p1, rows, bpr)]


# ---------------------------------------------------------------------------
# locator 2: 80188 blit immediates  (Sleic Pin-Ball)
# ---------------------------------------------------------------------------

def _cs_base(code_off):
    """CS for code at `code_off`: the 64 KB block it sits in.  sp03 loads at
    0xE0000, so file 0x00000.. is segment E000 and file 0x10000.. is F000."""
    return code_off & ~0xFFFF


def scan_blits(data):
    """`mov si,IMM16 / mov di,IMM16` sites, classified by what follows."""
    inline, strip = [], []
    i = 0
    n = len(data)
    while i < n - 8:
        if data[i] != 0xBE or data[i + 3] != 0xBF:
            i += 1
            continue
        si = data[i + 1] | (data[i + 2] << 8)
        di = data[i + 4] | (data[i + 5] << 8)
        tail = data[i + 6:i + 46]
        base = _cs_base(i)
        if (len(tail) > 8 and tail[0] == 0xB9 and tail[2] == 0 and tail[3] == 0x51
                and tail[4] == 0x57 and tail[5] == 0xB9 and tail[7] == 0):
            rows, bpr = tail[1], tail[6]
            # `mov al,cs:[si+200h]` inside the loop = a second plane at +0x200
            planes = 2 if b"\x2e\x8a\x84\x00\x02" in tail else 1
            if rows and bpr:
                inline.append({"kind": "blit", "code": i, "offset": base + si,
                               "si": si, "di": di, "rows": rows, "bpr": bpr,
                               "size": rows * bpr, "planes": planes,
                               "stride": 0x200, "base": base})
        elif len(tail) > 3 and tail[0] == 0xE8:
            rel = struct.unpack("<h", bytes(tail[1:3]))[0]
            callee = i + 9 + rel
            strip.append({"kind": "strip", "code": i, "si": si, "di": di,
                          "callee": callee, "base": base})
        i += 1
    return inline, strip


def strip_blitter_info(data, callee):
    """(rows, table_in_rom) for a column-strip blitter.  The height is the
    callee's own `mov cx,IMM16`; a `mov ax,1000h / mov ds,ax` in it means the
    pointer table is read from segment 0x1000, which on Pin-Ball is the 28C64A
    NVRAM (SLEIC1_NVRAM_BASE) and so is not in this ROM at all."""
    if not (0 <= callee < len(data) - 48):
        return None
    win = data[callee:callee + 48]
    if win[:5] != b"\xb8\x00\x60\x8e\xc0":          # mov ax,6000h / mov es,ax
        return None
    table_in_rom = b"\xb8\x00\x10\x8e\xd8" not in win  # mov ax,1000h / mov ds,ax
    rows = None
    for j in range(5, len(win) - 2):
        if win[j] == 0xB9 and win[j + 2] == 0:
            rows = win[j + 1]
            break
    if not rows:
        return None
    return rows, table_in_rom


def decode_strip_table(data, base, si, rows, max_cols=160):
    """Compose one column-strip blit: word count, then one CS pointer per
    8-pixel column, each pointing at `rows` bytes.  Single plane."""
    o = base + si
    if o + 2 > len(data):
        return None
    count = struct.unpack("<H", data[o:o + 2])[0]
    if not (1 <= count <= max_cols):
        return None
    ptrs = []
    for c in range(count):
        p = o + 2 + 2 * c
        if p + 2 > len(data):
            return None
        ptrs.append(struct.unpack("<H", data[p:p + 2])[0])
    img = [[0] * (count * 8) for _ in range(rows)]
    for c, p in enumerate(ptrs):
        s = data[base + p:base + p + rows]
        if len(s) < rows:
            return None
        for y in range(rows):
            for k in range(8):
                if s[y] & (0x80 >> k):
                    img[y][c * 8 + k] = 3
    return img


def blit_levels(data, item, plane_pages=False):
    if item["kind"] == "strip":
        img = decode_strip_table(data, item["base"], item["si"], item["rows"])
        return [img] if img else []
    o, rows, bpr = item["offset"], item["rows"], item["bpr"]
    p0 = data[o:o + rows * bpr]
    if item["planes"] < 2:
        return [levels_from_planes(p0, None, rows, bpr)]
    p1 = data[o + item["stride"]:o + item["stride"] + rows * bpr]
    if plane_pages:
        return [levels_from_planes(p0, None, rows, bpr),
                levels_from_planes(p1, None, rows, bpr)]
    return [levels_from_planes(p0, p1, rows, bpr)]


PANEL_BASE = 0x410       # 0x60410, the panel buffer's first byte
PANEL_STRIDE = 0x20      # bytes per panel row
PANEL_FIELD2 = 0x800     # second raster field / plane 1


def compose_panel(data, items):
    """Replay a run of Pin-Ball blits into the panel buffer and decode it as the
    I8039 raster would -- plane 0 at 0x60410 + row*0x20, plane 1 at +0x800.

    Screens are composed, not stored: a Pin-Ball screen is three or four blits
    in a row, each with its own `di`.  Which blits belong together is read off
    their *code adjacency*, which is a heuristic, not a fact from the firmware --
    it is right for the straight-line `mov si / mov di / call` runs that draw the
    attract and message screens, and it will over- or under-group anything drawn
    through a branch."""
    buf = bytearray(0x2000)
    for it in items:
        di = it["di"]
        if it["kind"] == "strip":
            img = decode_strip_table(data, it["base"], it["si"], it["rows"])
            if img is None:
                continue
            for c in range(len(img[0]) // 8):
                for y in range(it["rows"]):
                    b = 0
                    for k in range(8):
                        if img[y][c * 8 + k]:
                            b |= 0x80 >> k
                    q = di + y * PANEL_STRIDE + c
                    if q < len(buf):
                        buf[q] = b
        else:
            src = it["offset"]
            for pl in range(it["planes"]):
                so = src + pl * it.get("stride", 0x200)
                do = di + pl * PANEL_FIELD2
                for y in range(it["rows"]):
                    for c in range(it["bpr"]):
                        q = do + y * PANEL_STRIDE + c
                        if q < len(buf):
                            buf[q] = data[so + y * it["bpr"] + c]
    p0 = bytearray()
    p1 = bytearray()
    for y in range(DMD_H):
        r = PANEL_BASE + y * PANEL_STRIDE
        p0 += buf[r:r + DMD_W // 8]
        p1 += buf[r + PANEL_FIELD2:r + PANEL_FIELD2 + DMD_W // 8]
    return levels_from_planes(bytes(p0), bytes(p1), DMD_H, DMD_W // 8)


def sleicpin_index(data):
    """Everything sp03's code points at, as one list."""
    inline, strip = scan_blits(data)
    out = list(inline)
    for s in strip:
        info = strip_blitter_info(data, s["callee"])
        if not info:
            continue
        rows, in_rom = info
        item = dict(s, rows=rows, table_in_rom=in_rom)
        if not in_rom:
            item["note"] = "table in segment 1000 (NVRAM), not in this ROM"
            out.append(item)
            continue
        img = decode_strip_table(data, s["base"], s["si"], rows)
        if img is None:
            continue
        item["offset"] = s["base"] + s["si"]
        item["cols"] = len(img[0]) // 8
        out.append(item)
    out.sort(key=lambda d: d["code"])
    for i, d in enumerate(out):
        d["index"] = i
    return out


# ---------------------------------------------------------------------------
# locator 3: find a PinMAME SLEIC_DMD_DUMP frame in a ROM
# ---------------------------------------------------------------------------

def read_pgm(path):
    d = open(path, "rb").read()
    toks, i = [], 0
    while len(toks) < 4:
        while i < len(d) and d[i:i + 1].isspace():
            i += 1
        if d[i:i + 1] == b"#":
            while d[i:i + 1] != b"\n":
                i += 1
            continue
        j = i
        while j < len(d) and not d[j:j + 1].isspace():
            j += 1
        toks.append(d[i:j])
        i = j
    i += 1
    if toks[0] != b"P5":
        raise ValueError("not a binary PGM (P5)")
    w, h = int(toks[1]), int(toks[2])
    return w, h, d[i:i + w * h]


def pgm_planes(w, h, px):
    """A SLEIC_DMD_DUMP frame back into its two bitplanes (levels 0/85/170/255)."""
    lut = {0: 0, 85: 1, 170: 2, 255: 3}
    p0, p1 = bytearray(), bytearray()
    for y in range(h):
        for cb in range(w // 8):
            b0 = b1 = 0
            for k in range(8):
                v = lut.get(px[y * w + cb * 8 + k], 0)
                if v & 2:
                    b0 |= 0x80 >> k
                if v & 1:
                    b1 |= 0x80 >> k
            p0.append(b0)
            p1.append(b1)
    return bytes(p0), bytes(p1), w // 8


def locate_frame(roms, pgm_path, min_rows=4):
    w, h, px = read_pgm(pgm_path)
    p0, p1, bpr = pgm_planes(w, h, px)
    print(f"{pgm_path}: {w}x{h}")
    found = False
    for name, data in roms:
        for label, plane in (("plane 0", p0), ("plane 1", p1)):
            for start in range(h - min_rows + 1):
                run = plane[start * bpr:(start + min_rows) * bpr]
                if run.count(0) > len(run) - 4:
                    continue
                pos = data.find(run)
                if pos < 0:
                    continue
                # grow the match upward/downward to report the whole frame
                top = start
                while top > 0 and data[pos - bpr:pos] == plane[(top - 1) * bpr:top * bpr]:
                    pos -= bpr
                    top -= 1
                print(f"  {os.path.basename(name)}: {label} rows {top}.. "
                      f"at 0x{pos:05X} (frame row 0 would be 0x{pos - top * bpr:05X})")
                found = True
                break
    if not found:
        print("  no bitplane run located in any ROM given")


# ---------------------------------------------------------------------------
# machines
# ---------------------------------------------------------------------------

MACHINES = {
    # planes per record; where the graphics are; how to find them
    "iomoon": {
        "planes": 2,
        "locator": "records",
        "help": "V1 3_02.bin (ROM2, animation frames) or the concatenated "
                "ROM2+ROM1 image dmd_viewer.py takes",
    },
    "bikerace": {
        "planes": 3,
        "locator": "records",
        "help": "bkcpu05.bin (font + the larger sprite bank) and bkcpu06.bin",
    },
    "sleicpin": {
        "planes": 2,
        "locator": "blits",
        "help": "sp03-1_1.rom -- the 80188 code ROM, which is also the only "
                "place Pin-Ball's graphics live",
    },
}


def guess_machine(paths):
    names = " ".join(os.path.basename(p).lower() for p in paths)
    if "bkcpu" in names or "bk0" in names:
        return "bikerace"
    if names.startswith("sp0") or "sp01" in names or "sp03" in names:
        return "sleicpin"
    if "v1 3" in names or "iomoon" in names or "io_moon" in names:
        return "iomoon"
    return None


def build_index(machine, roms, args):
    """[(rom_name, data, item)] for every image the locator finds."""
    spec = MACHINES[machine]
    out = []
    for name, data in roms:
        if spec["locator"] == "blits":
            items = sleicpin_index(data)
        elif args.chain is not None:
            items = chain_records(data, args.chain, spec["planes"])
        else:
            items = scan_records(data, spec["planes"], lo=args.lo,
                                 hi=args.hi, min_lit=args.min_lit)
        for it in items:
            out.append((name, data, it))
    for i, (_, _, it) in enumerate(out):
        it["index"] = i
    return out


def describe(item):
    if item["kind"] == "strip":
        note = item.get("note", "")
        cols = item.get("cols")
        geom = f"{item['rows']}r x {cols} cols" if cols else f"{item['rows']}r x ?"
        src = (f"table 0x{item['offset']:05X}" if "offset" in item
               else f"si=0x{item['si']:04X}")
        return (f"strip  code 0x{item['code']:05X}  {src}  "
                f"{geom}  {_panel(item['di'])}  {note}".rstrip())
    if item["kind"] == "blit":
        return (f"blit   code 0x{item['code']:05X}  src 0x{item['offset']:05X}  "
                f"{item['rows']}r x {item['bpr']}B  {item['planes']} plane(s)  "
                f"{_panel(item['di'])}")
    return (f"record 0x{item['offset']:05X}  {item['rows']}r x {item['bpr']}B "
            f"({item['bpr'] * 8}px)  {item['planes']} planes  "
            f"plane={item['size']}B  lit={item['lit']}")


def panel_pos(di):
    """Panel destination of a Pin-Ball blit: 0x60410 + row*0x20 + column byte."""
    if di < 0x410:
        return None
    off = di - 0x410
    plane = 1 if off >= 0x800 else 0
    off &= 0x7FF
    return plane, off // 0x20, off % 0x20


def _panel(di):
    pos = panel_pos(di)
    if not pos:
        return f"di=0x{di:04X}"
    return f"panel plane{pos[0]} row {pos[1]:2d} col {pos[2]:2d}"


def main():
    ap = argparse.ArgumentParser(
        description="DMD graphics viewer for IO Moon, Bike Race and Sleic Pin-Ball",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples
  # Bike Race: the font and sprite table, then one glyph
  %(prog)s -m bikerace -r bkcpu05.bin --chain 0 --index
  %(prog)s -m bikerace -r bkcpu05.bin --chain 0 --show 40

  # Bike Race: everything in ROM 06, and the 32x17 bike at 0x1206
  %(prog)s -m bikerace -r bkcpu06.bin --index
  %(prog)s -m bikerace -r bkcpu06.bin --offset 0x1206 --header

  # Sleic Pin-Ball: what the code blits, then the title screen
  %(prog)s -m sleicpin -r sp03-1_1.rom --blits
  %(prog)s -m sleicpin -r sp03-1_1.rom --offset 0x19943 --rows 32 --bpr 16 \
                          --planes 2 --plane-stride 0x200
  %(prog)s -m sleicpin -r sp03-1_1.rom --compose 34      whole composed screen

  # IO Moon: the animation frames (same 400 dmd_viewer.py finds)
  %(prog)s -m iomoon -r "V1 3_02.bin" --index
  %(prog)s -m iomoon -r "V1 3_02.bin" --show 12 --png frame12.png

  # cross-check: where does a PinMAME SLEIC_DMD_DUMP frame live in the ROM?
  %(prog)s -r sp03-1_1.rom --locate /tmp/dmd/f.00615.pgm
        """)
    ap.add_argument("-r", "--rom", action="append", required=True, metavar="FILE",
                    help="ROM image; repeat for several (Bike Race has two "
                         "graphics ROMs)")
    ap.add_argument("-m", "--machine", choices=sorted(MACHINES),
                    help="which machine (guessed from the filename if omitted)")

    act = ap.add_mutually_exclusive_group(required=True)
    act.add_argument("--index", action="store_true",
                     help="list every image the locator finds")
    act.add_argument("--blits", action="store_true",
                     help="Sleic Pin-Ball: list the 80188 blit sites")
    act.add_argument("--show", type=int, metavar="N",
                     help="render image N from --index")
    act.add_argument("--offset", metavar="ADDR",
                     help="render at an explicit ROM offset")
    act.add_argument("--export-all", metavar="DIR",
                     help="write every image found as a PNG")
    act.add_argument("--compose", type=int, metavar="N",
                     help="Sleic Pin-Ball: replay blit N and the code-adjacent "
                          "ones after it into the panel buffer, giving the whole "
                          "composed screen")
    act.add_argument("--locate", metavar="FILE.pgm",
                     help="find a PinMAME SLEIC_DMD_DUMP frame's bitplanes in "
                          "the ROM(s)")

    ap.add_argument("--rows", type=int, help="--offset: rows (else from a header)")
    ap.add_argument("--bpr", type=int, help="--offset: bytes per row")
    ap.add_argument("--planes", type=int, help="--offset: planes")
    ap.add_argument("--plane-stride", type=lambda s: int(s, 0), default=None,
                    help="--offset: bytes between planes (default: contiguous; "
                         "0x200 for Pin-Ball's and IO Moon's flat pairs)")
    ap.add_argument("--header", action="store_true",
                    help="--offset: the 6-byte record header stands at ADDR")

    ap.add_argument("--chain", type=lambda s: int(s, 0), default=None, metavar="ADDR",
                    help="records: walk back-to-back from ADDR instead of "
                         "scanning the whole ROM")
    ap.add_argument("--lo", type=lambda s: int(s, 0), default=0,
                    help="records: start of the scan range")
    ap.add_argument("--hi", type=lambda s: int(s, 0), default=None,
                    help="records: end of the scan range")
    ap.add_argument("--compose-window", type=lambda s: int(s, 0), default=0x40,
                    metavar="N",
                    help="--compose: how many bytes of code may separate two "
                         "blits of the same screen (default 0x40)")
    ap.add_argument("--min-lit", type=int, default=32,
                    help="records: drop candidates with fewer lit dots "
                         "(default 32; 0 keeps everything)")

    ap.add_argument("--pages", action="store_true",
                    help="render each plane as its own 1-bit image instead of "
                         "combining them (IO Moon ROM1 static screens are an "
                         "English/Spanish pair, not two bitplanes)")
    ap.add_argument("--png", metavar="FILE", help="write a PNG instead of ASCII")
    ap.add_argument("--chars", default=ASCII_RAMP,
                    help=f"ASCII ramp for levels 0-3 (default {ASCII_RAMP!r})")
    ap.add_argument("--dot-scale", type=int, default=4, help="PNG dot size")
    ap.add_argument("--dot-gap", type=int, default=1, help="PNG gap between dots")
    args = ap.parse_args()

    roms = []
    for p in args.rom:
        if not os.path.exists(p):
            sys.exit(f"ROM not found: {p}")
        roms.append((p, open(p, "rb").read()))

    if args.locate:
        locate_frame(roms, args.locate)
        return

    machine = args.machine or guess_machine(args.rom)
    if not machine:
        sys.exit("cannot guess the machine from these filenames -- pass -m")
    print(f"machine: {machine}  ({MACHINES[machine]['help']})", file=sys.stderr)

    if len(args.chars) < 4:
        sys.exit("--chars needs four characters")

    # --offset renders one image without consulting a locator
    if args.offset:
        off = int(args.offset, 0)
        name, data = roms[0]
        if args.header:
            hdr = parse_header(data, off)
            if not hdr:
                sys.exit(f"no record header at 0x{off:05X}: "
                         f"{data[off:off+6].hex(' ')}")
            rows, bpr, size = hdr
            planes = args.planes or MACHINES[machine]["planes"]
            rec = {"offset": off, "rows": rows, "bpr": bpr, "size": size,
                   "planes": planes, "kind": "record", "lit": 0}
            imgs = record_levels(data, rec, plane_pages=args.pages)
            print(f"{os.path.basename(name)} 0x{off:05X}: header {rows}r x {bpr}B, "
                  f"{planes} planes")
        else:
            rows = args.rows or DMD_H
            bpr = args.bpr or DMD_W // 8
            planes = args.planes if args.planes is not None else 2
            stride = args.plane_stride
            if stride is None:
                stride = rows * bpr
            item = {"kind": "blit", "code": 0, "offset": off, "si": 0, "di": 0,
                    "rows": rows, "bpr": bpr, "size": rows * bpr,
                    "planes": planes, "stride": stride, "base": 0}
            imgs = blit_levels(data, item, plane_pages=args.pages)
            print(f"{os.path.basename(name)} 0x{off:05X}: {rows}r x {bpr}B, "
                  f"{planes} plane(s), stride 0x{stride:X}")
        for i, img in enumerate(imgs):
            if args.png:
                path = args.png if len(imgs) == 1 else f"{args.png}.{i}.png"
                write_png(path, img, args.dot_scale, args.dot_gap)
                print(f"wrote {path}")
            else:
                if len(imgs) > 1:
                    print(f"[plane {i}]")
                print(render_ascii(img, args.chars))
        return

    if args.blits:
        if MACHINES[machine]["locator"] != "blits":
            sys.exit("--blits only applies to sleicpin")
        for name, data in roms:
            inline, strip = scan_blits(data)
            print(f"\n{os.path.basename(name)}: {len(inline)} inline blits, "
                  f"{len(strip)} strip-blitter calls")
            for b in inline:
                print(f"  code 0x{b['code']:05X}  src 0x{b['offset']:05X}  "
                      f"{b['rows']:2d}r x {b['bpr']:2d}B  {b['planes']} plane(s)  "
                      f"{_panel(b['di'])}")
            seen = {}
            for s in strip:
                seen.setdefault(s["callee"], []).append(s)
            for callee, sites in sorted(seen.items()):
                info = strip_blitter_info(data, callee)
                if info:
                    rows, in_rom = info
                    note = "table in CS" if in_rom else "table in segment 1000 (NVRAM)"
                    print(f"  strip blitter 0x{callee:05X}: {rows} rows/strip, "
                          f"{note}, {len(sites)} call sites")
                else:
                    print(f"  strip blitter 0x{callee:05X}: not recognised, "
                          f"{len(sites)} call sites")
        return

    index = build_index(machine, roms, args)

    if args.index:
        for name, _, it in index:
            print(f"{it['index']:5d}  {os.path.basename(name):16s}  {describe(it)}")
        print(f"\n{len(index)} images")
        return

    if args.show is not None:
        if not (0 <= args.show < len(index)):
            sys.exit(f"index {args.show} out of range (0-{len(index) - 1})")
        name, data, it = index[args.show]
        print(f"{os.path.basename(name)}  {describe(it)}")
        imgs = (record_levels(data, it, args.pages) if it["kind"] == "record"
                else blit_levels(data, it, args.pages))
        for i, img in enumerate(imgs):
            if args.png:
                path = args.png if len(imgs) == 1 else f"{args.png}.{i}.png"
                write_png(path, img, args.dot_scale, args.dot_gap)
                print(f"wrote {path}")
            else:
                if len(imgs) > 1:
                    print(f"[plane {i}]")
                print(render_ascii(img, args.chars))
        return

    if args.compose is not None:
        if MACHINES[machine]["locator"] != "blits":
            sys.exit("--compose only applies to sleicpin")
        if not (0 <= args.compose < len(index)):
            sys.exit(f"index {args.compose} out of range (0-{len(index) - 1})")
        name, data, first = index[args.compose]
        group = [first]
        prev = first["code"]
        for _, _, it in index[args.compose + 1:]:
            if it["code"] - prev > args.compose_window:
                break
            group.append(it)
            prev = it["code"]
        print(f"{os.path.basename(name)}  composed from {len(group)} blit(s):")
        for it in group:
            print(f"   {describe(it)}")
        img = compose_panel(data, group)
        if args.png:
            write_png(args.png, img, args.dot_scale, args.dot_gap)
            print(f"wrote {args.png}")
        else:
            print(render_ascii(img, args.chars))
        return

    if args.export_all:
        os.makedirs(args.export_all, exist_ok=True)
        n = 0
        for name, data, it in index:
            imgs = (record_levels(data, it, args.pages) if it["kind"] == "record"
                    else blit_levels(data, it, args.pages))
            stem = os.path.splitext(os.path.basename(name))[0].replace(" ", "_")
            for i, img in enumerate(imgs):
                off = it.get("offset", it.get("code", 0))
                suffix = f"_p{i}" if len(imgs) > 1 else ""
                path = os.path.join(
                    args.export_all,
                    f"{stem}_{it['index']:04d}_{it['kind']}_0x{off:05X}{suffix}.png")
                write_png(path, img, args.dot_scale, args.dot_gap)
                n += 1
        print(f"wrote {n} PNGs to {args.export_all}/")
        return


if __name__ == "__main__":
    main()
