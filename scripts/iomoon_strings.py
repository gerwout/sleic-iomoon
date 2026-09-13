#!/usr/bin/env python3
"""Decode Io Moon's glyph-encoded string pools and its switch-code -> contact table.

Both live in the 80188 code ROM's low 256 KB, which the LMCS chip select maps to
linear 0x00000-0x3FFFF (findings F1), so a pointer's segment:offset is flat.

Run directly to print the table and the pools:
    python3 scripts/iomoon_strings.py roms/iomoon/v1_3_01.bin
"""
import struct
import sys

# Glyph indices, from the DMD font order: digits, space, then A..Z with N-tilde
# wedged in after N.  Punctuation from the strings the service menu draws.
GLYPHS = {i: str(i) for i in range(10)}
GLYPHS[0x0A] = ' '
for _i, _ch in enumerate('ABCDEFGHIJKLMNÑOPQRSTUVWXYZ'):
    GLYPHS[0x0B + _i] = _ch
GLYPHS.update({0x26: '!', 0x27: '?', 0x28: '(', 0x29: ')', 0x2a: '/',
               0x2b: ':', 0x2c: '.', 0x2d: '-', 0x2e: ':', 0x2f: '*'})

CONTACT_TABLE_BASE = 0x0830   # record = base + code*5: Cnum | off16 | seg16, pointer into ENGLISH_POOL
SPANISH_TABLE_BASE = 0x1438   # same layout, same code axis, pointer into SPANISH_POOL
ENGLISH_POOL = (0x1c5f, 0x1e4d)
SPANISH_POOL = (0x250e, 0x2784)


def decode_string(data, off):
    """A length-prefixed glyph string at file offset `off`, or None."""
    if off <= 0 or off >= len(data):
        return None
    n = data[off]
    if n == 0 or n > 30 or off + 1 + n > len(data):
        return None
    return ''.join(GLYPHS.get(b, '{%02x}' % b) for b in data[off + 1:off + 1 + n])


def _record(data, base, code):
    rec = base + code * 5
    cnum = data[rec]
    off, seg = struct.unpack('<HH', data[rec + 1:rec + 5])
    return cnum, (seg << 4) + off


def contact_table(data):
    """Switch code -> (C-number, English name, Spanish name).

    The two pools hold the same entries in different orders, so each language
    has its own code-indexed pointer table (CONTACT_TABLE_BASE,
    SPANISH_TABLE_BASE; same 5-byte layout): a code's two names are read from
    the two tables at that same code, not from a shared pool position. Only
    codes with a resolvable name in both tables are returned, which is exactly
    the set the firmware can draw on the CONTACTOS test screen.
    """
    out = {}
    for code in range(0x00, 0x60):
        cnum_en, lin_en = _record(data, CONTACT_TABLE_BASE, code)
        cnum_es, lin_es = _record(data, SPANISH_TABLE_BASE, code)
        en = decode_string(data, lin_en)
        es = decode_string(data, lin_es)
        if en is None or es is None:
            continue
        assert cnum_en == cnum_es, (
            'code %02X: C-number disagrees between tables (%d english, %d spanish)'
            % (code, cnum_en, cnum_es))
        out[code] = (cnum_en, en, es)
    return out


def string_pool(data, lo, hi):
    """Every length-prefixed glyph string between two file offsets, in order."""
    out = []
    off = lo
    while off < hi:
        n = data[off]
        if 1 <= n <= 24 and all(b < 0x40 for b in data[off + 1:off + 1 + n]):
            out.append((off, decode_string(data, off)))
            off += 1 + n
        else:
            off += 1
    return out


def _self_test(data):
    t = contact_table(data)
    # F15 already establishes the four ball-handling contacts; they anchor the table.
    assert t[0x0A][:2] == (6, 'OUTHOLE 1'), t.get(0x0A)
    assert t[0x0B][:2] == (7, 'OUTHOLE 2'), t.get(0x0B)
    assert t[0x0C][:2] == (8, 'OUTHOLE 3'), t.get(0x0C)
    assert t[0x0D][:2] == (9, 'BALL OUT'), t.get(0x0D)
    # The Spanish column comes from its own table, not ordinal position in the pool.
    assert t[0x0A][2] == 'SALIDA BOLAS 1', t[0x0A]
    assert t[0x0D][1:] == ('BALL OUT', 'BOLA FUERA'), t[0x0D]
    assert t[0x3E][1:] == ('PLUMB TILT', 'PENDULO DE FALTA'), t[0x3E]
    # These codes' English and Spanish names sit at different positions in
    # their respective pools -- exactly why each language needs its own table.
    assert t[0x0E][1:] == ('LANE 5', 'PASILLO 5'), t[0x0E]
    assert t[0x0F][1:] == ('LANE 4', 'PASILLO 4'), t[0x0F]
    assert t[0x14][1:] == ('U.C.FLIPPER', 'C.FLIPPER SUP.'), t[0x14]
    # Column 4's second ball device is Jupiter, which closes an open item.
    assert [t[c][1] for c in (0x2A, 0x2B, 0x2C)] == ['JUPITER 1', 'JUPITER 2', 'JUPITER 3']
    assert t[0x2A][1:] == ('JUPITER 1', 'JUPITER 1'), t[0x2A]
    # 48 matrix positions exist; four of column 5 are unnamed and do not.
    for code in (0x38, 0x39, 0x3A, 0x3B):
        assert code not in t, 'code %02X should have no name' % code
    # The cabinet inputs are named too.
    assert t[0x3F][:2] == (4, 'TEST BUTTON'), t.get(0x3F)
    assert t[0x40][:2] == (2, 'START BUTTON'), t.get(0x40)
    matrix = [c for c in t if 0x0A <= c <= 0x37 and c not in (0x32, 0x33)]
    assert len(matrix) == 44, 'expected 44 named matrix positions, got %d' % len(matrix)
    print('self-test OK: %d named codes, %d of them matrix positions' % (len(t), len(matrix)))


if __name__ == '__main__':
    path = sys.argv[1] if len(sys.argv) > 1 else 'roms/iomoon/v1_3_01.bin'
    blob = open(path, 'rb').read()
    _self_test(blob)
    print('\n=== contact table (F16) ===')
    for code in sorted(contact_table(blob)):
        cnum, en, es = contact_table(blob)[code]
        print('  %02X  C%-3d  %-16s %s' % (code, cnum, en, es))
    print('\n=== English pool ===')
    for off, s in string_pool(blob, *ENGLISH_POOL):
        print('  %06x |%s|' % (off, s))
    print('\n=== Spanish pool ===')
    for off, s in string_pool(blob, *SPANISH_POOL):
        print('  %06x |%s|' % (off, s))
