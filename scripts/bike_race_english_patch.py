#!/usr/bin/env python3
"""
Sleic Bike Race (V4.1, free play + PRESS START) - ENGLISH patch
================================================================

Translates the free-play + PRESS START Bike Race set from Spanish to English.
Three chips change; the other four (01, 02, 03, 07) stay the V4.1 set's own.

    chip 04  bk04f.bin  -> bk04e.bin   the 185 menu/message strings, YES/NO,
                                       and the attract "CREDITOS nn" screen
                                       replaced by the Freeplay screen
    chip 05  bkcpu05.bin -> bk05e.bin  the 52 full-screen and sprite texts, the
                                       staff-credits roll, the new Freeplay
                                       screen, and the seven font strings this
                                       ROM holds itself
    chip 06  bkcpu06.bin -> bk06e.bin  the two "UNO" frames -> "ONE"

Usage:
    python3 scripts/bike_race_english_patch.py [--out DIR]
            [--bk04 bk04f.bin] [--bk05 bkcpu05.bin] [--bk06 bkcpu06.bin]

Inputs default to the archived images; each is checked by CRC32 first.
The translation itself lives in `translations/bike-race-en/`: `art/` holds
one PNG per graphics record, `strings_bk04.tsv` the chip-04 text.

Text
----
Bike Race draws text through `F000:0682` from `[length][glyph code...]`
records (0-9 digits, 10 space, 11.. A-Z with N-tilde at 25, punctuation from
0x26) at a fixed 16-column position chosen by the caller, one 8 px cell per
character; the drawer never centres anything itself.  So:

* English no longer than the Spanish is written in place and space-padded to
  exactly the Spanish length -- left, right or centred as the table says --
  which repaints exactly the cells the Spanish did.  Nothing else moves.
* English that is longer is written to free space at `F000:A100` and every
  reference to the Spanish record is repointed: far pointers stored as data
  (the 46-byte menu records at `F000:30DA`, the switch-name table) and
  `PUSH F000 / PUSH off` pairs in code.  Every repointed site is listed.
  Only list items and stand-alone lines are lengthened, never a label that
  has a value drawn after it.

YES / NO
--------
`SI`/`NO` at `F000:390C`/`390F` are not referenced by pointer: three routines
(`F65B5`, `F689B`, `F6D31`, the BOLAS EXTRA page's display and toggle) copy
their bytes one at a time into the value buffer `[0116:00A6]`.  The YES
branches of the first two copy four bytes (`390C`-`390F`), so `03 'Y' 'E' 'S'`
there is enough.  The NO branches, and the third routine's YES branch (which
copies three bytes and borrows the NO branch's tail), are rewritten in place
as four immediate stores, so the buffer always holds a full three-character
value and a NO after a YES leaves no stray letter.  The value column moves
from 14 to 13 (record 7, line 2) and the label shrinks to fit.

Freeplay
--------
With the free-play patch the credit count is always 1, so the attract's
"CREDITOS" box and its "01" are meaningless.  The box's loader `F000:2461`
reads its record from the slot `CS:0FD6` and chains `F000:0BF8`, which draws
the two credit digits; it is pointed at a new slot holding the Freeplay
record and chained straight to `F000:2CB6`, the generic end-of-screen step
the other loaders use.  The coin screen "INTRODUZCA MONEDAS" (record 210) is
translated but cannot appear on a free-play machine: only START with zero
credits draws it.

Graphics
--------
Each art PNG replaces the record at the offset in its name, at the same size.
Full-screen records are two planes (level = 2*p0 + p1); the small sprites
171-176 carry a third, mask plane, which is kept as it is.
"""

import argparse
import hashlib
import os
import re
import struct
import sys
import zlib

import numpy as np
from PIL import Image

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(HERE)
ROMS = os.path.join(REPO, 'roms', 'related-machines', 'bike-race')
TRANS = os.path.join(REPO, 'translations', 'bike-race-en')

CRC_BK04F = 0x7626564e    # V4.1 + free play + PRESS START
CRC_BK05 = 0x072ce879
CRC_BK06 = 0x9db436d4

BK04_BASE = 0xE0000       # chip 04 is linear 0xE0000-0xFFFFF
F000 = 0x10000            # file offset of segment F000
BK05_BASE = 0x40000       # chip 05 at MCS2
BK06_BASE = 0x20000       # chip 06 at MCS1

CAVE_SLOT = 0x1A000       # F000:A000  the Freeplay far pointer
CAVE_TEXT = 0x1A100       # F000:A100  relocated strings
CAVE_END = 0x1F000
FREEPLAY_OFF = 0x1C000    # chip 05 file offset of the new record

GLYPH = {str(i): i for i in range(10)}
GLYPH[' '] = 10
for _i, _c in enumerate('ABCDEFGHIJKLMNÑOPQRSTUVWXYZ'):
    GLYPH[_c] = 11 + _i
GLYPH.update({'+': 0x26, '(': 0x28, ')': 0x29, '/': 0x2a, ',': 0x2b, '.': 0x2c,
              ';': 0x2d, ':': 0x2e, '-': 0x2f})


def enc(text):
    return bytes(GLYPH[c] for c in text)


def crc(b):
    return zlib.crc32(b) & 0xFFFFFFFF


def need(data, off, expect, what):
    got = bytes(data[off:off + len(expect)])
    if got != expect:
        sys.exit('%s: expected %s at 0x%05X, found %s' % (what, expect.hex(), off, got.hex()))


def pad(text, width, align):
    n = width - len(text)
    if align == 'r':
        return ' ' * n + text
    if align == 'c':
        return ' ' * (n // 2) + text + ' ' * (n - n // 2)
    return text + ' ' * n


# ---------------------------------------------------------------------------
# graphics
# ---------------------------------------------------------------------------

def load_levels(path):
    a = np.array(Image.open(path).convert('RGB'))[:, :, 0].astype(int)
    return np.select([a < 40, a < 120, a < 200], [0, 1, 2], 3).astype(np.uint8)


def planes(lv):
    p0 = np.packbits((lv >> 1) & 1, axis=1).tobytes()
    p1 = np.packbits(lv & 1, axis=1).tobytes()
    return p0, p1


def put_record(rom, off, lv, name):
    rows, bpr, size = struct.unpack('<HHH', rom[off:off + 6])
    if size != rows * bpr or lv.shape != (rows, bpr * 8):
        sys.exit('%s: art is %dx%d, record 0x%05X is %dx%d' %
                 (name, lv.shape[1], lv.shape[0], off, bpr * 8, rows))
    p0, p1 = planes(lv)
    rom[off + 6:off + 6 + size] = p0
    rom[off + 6 + size:off + 6 + 2 * size] = p1      # a mask plane, if any, is kept


def patch_graphics(rom, prefix, art):
    n = 0
    for f in sorted(os.listdir(art)):
        m = re.match(r'%s_(\w+?)_record_0x([0-9A-F]+)\.png$' % prefix, f)
        if m:
            put_record(rom, int(m.group(2), 16), load_levels(os.path.join(art, f)), f)
            n += 1
    return n


# ---------------------------------------------------------------------------
# chip 04 text
# ---------------------------------------------------------------------------

def find_refs(rom, target_off):
    """Every reference to F000:target_off -- a stored (off, F000) far pointer,
    or a PUSH F000 / PUSH off pair -- as the file offset of the offset word."""
    lo, hi = target_off & 0xFF, target_off >> 8
    data = struct.pack('<HH', target_off, 0xF000)
    push = bytes([0x68, 0x00, 0xF0, 0x68, lo, hi])
    out = []
    i = rom.find(data)
    while i >= 0:
        out.append(('ptr', i))
        i = rom.find(data, i + 1)
    i = rom.find(push)
    while i >= 0:
        out.append(('push', i + 4))
        i = rom.find(push, i + 1)
    return out


def patch_strings(rom, tsv, log):
    cave = CAVE_TEXT
    rows = [l.rstrip('\n').split('\t') for l in open(tsv, encoding='utf-8')
            if l.strip() and not l.startswith('#') and not l.startswith('offset')]
    moved = 0
    for off_s, es, en, align in rows:
        off = int(off_s, 16)
        need(rom, off, bytes([len(es)]) + enc(es), 'string %r' % es)
        if align == 'code':
            continue
        if len(en) <= len(es):
            rom[off + 1:off + 1 + len(es)] = enc(pad(en, len(es), align))
            continue
        refs = find_refs(rom, off - F000)
        if not refs:
            sys.exit('no reference to %r at F000:%04X, cannot move it' % (es, off - F000))
        rec = bytes([len(en)]) + enc(en)
        if cave + len(rec) > CAVE_END:
            sys.exit('text cave full')
        rom[cave:cave + len(rec)] = rec
        for kind, at in refs:
            struct.pack_into('<H', rom, at, cave - F000)
            if kind == 'push' and rom[at - 4:at] != b'\x68\x00\xF0\x68':
                sys.exit('push at %05X is not PUSH F000 / PUSH off' % (at + BK04_BASE))
        log.append('  moved %-16r -> F000:%04X  %r  (%s)' % (
            es, cave - F000, en, ', '.join('%s@%05X' % (k, a + BK04_BASE) for k, a in refs)))
        cave += len(rec)
        moved += 1
    return len(rows), moved


def store4(text):
    """MOV DX,0116 / MOV ES,DX / four MOV ES:B[00A6+i],imm / MOV AL,last."""
    b = enc(text)
    code = bytes([0xBA, 0x16, 0x01, 0x8E, 0xC2])
    for i, v in enumerate([len(text)] + list(b)):
        code += bytes([0x26, 0xC6, 0x06, 0xA6 + i, 0x00, v])
    return code + bytes([0xB0, b[-1]])


def jmp_near(src, dst):
    return bytes([0xE9]) + struct.pack('<h', dst - (src + 3))


def fill(rom, start, end, code, what):
    if len(code) > end - start:
        sys.exit('%s does not fit' % what)
    rom[start:end] = code + b'\x90' * (end - start - len(code))


def patch_yes_no(rom):
    lin = lambda a: a - BK04_BASE
    # the four bytes the two display routines' YES branches copy
    need(rom, 0x1390C, bytes([2]) + enc('SI') + bytes([2]) + enc('NO'), 'SI/NO')
    rom[0x1390C:0x13910] = bytes([3]) + enc('YES')
    # routine 1 (F65B5): NO branch F65F9..F6628, falls into JMP F66A4 at F6629
    need(rom, lin(0xF65F9), bytes.fromhex('b800f08ec026a00f39'), 'NO branch 1')
    need(rom, lin(0xF6629), bytes.fromhex('eb79'), 'NO branch 1 exit')
    fill(rom, lin(0xF65F9), lin(0xF6629), store4('NO '), 'NO branch 1')
    # routine 2 (F689B): NO branch F68F2..F6921, falls into JMP F6B4E at F6922
    need(rom, lin(0xF68F2), bytes.fromhex('b800f08ec026a00f39'), 'NO branch 2')
    need(rom, lin(0xF6922), bytes.fromhex('e92902'), 'NO branch 2 exit')
    fill(rom, lin(0xF68F2), lin(0xF6922), store4('NO '), 'NO branch 2')
    # routine 3 (F6D31, the toggle): YES F6D46..F6D71, NO F6D7D..F6DAF, exit JMP at F6DB0
    need(rom, lin(0xF6D46), bytes.fromhex('b800f08ec026a00c39'), 'YES branch 3')
    need(rom, lin(0xF6D70), bytes.fromhex('eb35'), 'YES branch 3 exit')
    need(rom, lin(0xF6D7D), bytes.fromhex('b800f08ec026a00f39'), 'NO branch 3')
    need(rom, lin(0xF6DB0), bytes.fromhex('e92b02'), 'NO branch 3 exit')
    yes = store4('YES')
    yes += jmp_near(0xF6D46 + len(yes), 0xF6DB0)
    fill(rom, lin(0xF6D46), lin(0xF6D72), yes, 'YES branch 3')
    fill(rom, lin(0xF6D7D), lin(0xF6DB0), store4('NO '), 'NO branch 3')
    # BOLAS EXTRA page (menu record 7), line 2: value column 14 -> 13
    need(rom, 0x13238, struct.pack('<H', 0x015E), 'record 7 value position')
    struct.pack_into('<H', rom, 0x13238, 0x015D)


def patch_freeplay(rom04, rom05, art):
    lv = load_levels(os.path.join(art, 'BK05_Freeplay.png'))
    if lv.shape != (32, 128):
        sys.exit('BK05_Freeplay.png must be 128x32')
    if any(rom05[FREEPLAY_OFF:FREEPLAY_OFF + 6 + 2 * 512]):
        sys.exit('chip 05 free space at 0x%05X is not empty' % FREEPLAY_OFF)
    p0, p1 = planes(lv)
    rom05[FREEPLAY_OFF:FREEPLAY_OFF + 6 + 1024] = struct.pack('<HHH', 32, 16, 512) + p0 + p1
    lin = BK05_BASE + FREEPLAY_OFF
    struct.pack_into('<HH', rom04, CAVE_SLOT, lin & 0xFFFF, (lin >> 4) & 0xF000)
    # F2461: LES SI,CS:[0FD6] -> CS:[A000];  MOV [1015],0BF8 -> 2CB6
    need(rom04, 0x12472, bytes.fromhex('2ec436d60f'), 'CREDITOS loader')
    need(rom04, 0x1249A, bytes.fromhex('c7061510f80b'), 'CREDITOS digits step')
    struct.pack_into('<H', rom04, 0x12475, CAVE_SLOT - F000)
    struct.pack_into('<H', rom04, 0x1249E, 0x2CB6)


# chip 05's own font strings: PRIMERA/SEGUNDA PARTIDA (typewriter, F000:1D1C/1D20)
# and the high-score name entry (pointer table at 0x1B722, drawn from ED3C6)
BK05_TEXT = [
    (0x03562, 'PRIMERA PARTIDA ', 'FIRST REPLAY', 'c'),
    (0x03573, 'SEGUNDA PARTIDA ', 'SECOND REPLAY', 'c'),
    (0x1B736, 'INSCRIPCION', 'HIGH SCORE', 'c'),
    (0x1B742, 'JUGADOR 1:', 'PLAYER 1:', 'l'),
    (0x1B74D, 'JUGADOR 2:', 'PLAYER 2:', 'l'),
    (0x1B758, 'JUGADOR 3:', 'PLAYER 3:', 'l'),
    (0x1B763, 'JUGADOR 4:', 'PLAYER 4:', 'l'),
]


def patch_bk05_text(rom):
    for off, es, en, align in BK05_TEXT:
        need(rom, off, bytes([len(es)]) + enc(es), 'chip 05 string %r' % es)
        rom[off + 1:off + 1 + len(es)] = enc(pad(en, len(es), align))


# ---------------------------------------------------------------------------

def read(path, want, name, force):
    b = bytearray(open(path, 'rb').read())
    if crc(b) != want and not force:
        sys.exit('%s: CRC32 %08x, expected %08x (use --any-version to override)' % (name, crc(b), want))
    return b


def report(name, b):
    print('  %-10s %7d bytes  CRC32 %08x  MD5 %s  SHA1 %s' % (
        name, len(b), crc(b), hashlib.md5(b).hexdigest(), hashlib.sha1(b).hexdigest()))


def main():
    ap = argparse.ArgumentParser(description='Bike Race V4.1 (free play + PRESS START) -> English')
    ap.add_argument('--bk04', default=os.path.join(ROMS, 'v4.1 - free play + press start', 'bk04f.bin'))
    ap.add_argument('--bk05', default=os.path.join(ROMS, 'bkcpu05.bin'))
    ap.add_argument('--bk06', default=os.path.join(ROMS, 'bkcpu06.bin'))
    ap.add_argument('--art', default=os.path.join(TRANS, 'art'))
    ap.add_argument('--strings', default=os.path.join(TRANS, 'strings_bk04.tsv'))
    ap.add_argument('--out', default='.')
    ap.add_argument('--any-version', action='store_true')
    ap.add_argument('-v', '--verbose', action='store_true')
    a = ap.parse_args()

    r4 = read(a.bk04, CRC_BK04F, 'bk04', a.any_version)
    r5 = read(a.bk05, CRC_BK05, 'bk05', a.any_version)
    r6 = read(a.bk06, CRC_BK06, 'bk06', a.any_version)
    if any(r4[CAVE_SLOT:CAVE_END]):
        sys.exit('chip 04 free space F000:A000-F000:EFFF is not empty')

    log = []
    n_art5 = patch_graphics(r5, 'BK05', a.art)
    n_art6 = patch_graphics(r6, 'BK06', a.art)
    patch_freeplay(r4, r5, a.art)
    patch_bk05_text(r5)
    n_str, n_moved = patch_strings(r4, a.strings, log)
    patch_yes_no(r4)

    os.makedirs(a.out, exist_ok=True)
    for name, b in (('bk04e.bin', r4), ('bk05e.bin', r5), ('bk06e.bin', r6)):
        open(os.path.join(a.out, name), 'wb').write(b)
    print('chip 05: %d records + Freeplay at 0x%05X + %d strings; chip 06: %d records'
          % (n_art5, FREEPLAY_OFF, len(BK05_TEXT), n_art6))
    print('chip 04: %d strings, %d moved to free space, YES/NO, Freeplay hook' % (n_str, n_moved))
    if a.verbose:
        print('\n'.join(log))
    for name, b in (('bk04e.bin', r4), ('bk05e.bin', r5), ('bk06e.bin', r6)):
        report(name, b)


if __name__ == '__main__':
    main()
