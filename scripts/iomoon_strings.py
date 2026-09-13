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
# wedged in after N.  Punctuation (0x26-0x2f) is read off the h=9 face's own
# bitmaps (glyph_bitmaps, table entry = code + 23), not guessed from context:
# 0x28/0x29 by which way each paren bulges, 0x2c/0x2e/0x2f by counting and
# spacing their lit blocks, 0x2b/0x2d by the comma-style tail on '.' and ';'.
# 0x27 is left out: its bitmap is not a question mark (no gap between the
# bowl and the tail, which one requires) and nothing else pins it -- an
# unmapped code falls back to decode_string's own '{xx}' marker.
GLYPHS = {i: str(i) for i in range(10)}
GLYPHS[0x0A] = ' '
for _i, _ch in enumerate('ABCDEFGHIJKLMNÑOPQRSTUVWXYZ'):
    GLYPHS[0x0B + _i] = _ch
GLYPHS.update({0x26: '+', 0x28: '(', 0x29: ')', 0x2a: '/',
               0x2b: ',', 0x2c: '.', 0x2d: ';', 0x2e: ':', 0x2f: '-'})

CONTACT_TABLE_BASE = 0x0830   # record = base + code*5: Cnum | off16 | seg16, pointer into ENGLISH_POOL
SPANISH_TABLE_BASE = 0x1438   # same layout, same code axis, pointer into SPANISH_POOL
ENGLISH_POOL = (0x1c5f, 0x1e4d)
SPANISH_POOL = (0x250e, 0x2784)

# The DMD glyph table (docs/dmd_graphics.md, "Font System"): ROM1 file offset
# 0x20000, combined-image 0xA0000.  Its entries have no fixed stride -- each
# is a 6-byte header [h, 00, W, 00, h*W, 00] followed by three h*W-byte
# blocks (plane 0, plane 1, then a mask -- F13's composite is
# (background AND mask) OR sprite) -- so the table must be walked.
FONT_BASE = 0x20000
# The on-screen text is the h=9, W=1 (one byte, 8px) face.  Its table entry
# is the glyph code plus this offset: entry 57 matches a captured frame's
# 'W' byte-for-byte, and 'W' is glyph code 0x22 (34).
FONT_FACE_HEIGHT = 9
FONT_CODE_OFFSET = 23

# The large score/price face, past the initial one-byte-wide run (docs/
# dmd_graphics.md): 21 entries of h=23, W=2 (16 px).  Its index is the glyph
# directly, not code + an offset -- table index 0 renders a 16x23 '0'.
SCORE_FACE_HEIGHT = 23
SCORE_FACE_WIDTH = 2
# 0-9 plain digits, 10-19 the same digits with an attached decimal point (a
# plain 2x2 dot at bottom right, not a comma's tail -- a Spanish-market
# machine's peseta-style NNN.NNN pricing), 20 a colon (two stacked blocks,
# matching the h=9 face's ':' shape scaled up).  Unverified against a
# captured frame: no dump on disk shows an in-play score.
SCORE_FACE_LABELS = [str(d) for d in range(10)] + ['%d.' % d for d in range(10)] + [':']


def _font_entries(data, base=FONT_BASE):
    """[(offset, height, width_bytes), ...], walking the glyph table from `base`.

    Stops at the first header whose byte 4 cannot hold height*width (over
    255, as for a glyph larger than the on-screen face) -- walking this
    reading of the header has not been verified past that point -- or whose
    body would run past the end of `data`, as for a truncated ROM image.
    """
    out = []
    off = base
    while off + 6 <= len(data):
        h, w, hw = data[off], data[off + 2], data[off + 4]
        if h == 0 or w == 0 or hw != h * w:
            break
        if off + 6 + 3 * h * w > len(data):
            break
        out.append((off, h, w))
        off += 6 + 3 * h * w
    return out


def glyph_bitmaps(data):
    """Glyph code -> list of row bit strings, for the on-screen h=9 face.

    A uniform entry (every row identical, as for the space glyph's all-zero
    bitmap) is dropped: it would match any blank or solid window on the
    panel rather than one particular glyph, so a caller wanting a space
    between words has to notice the gap itself rather than match one.

    Raises ValueError if no matchable glyph is found at all -- a truncated
    or otherwise wrong ROM image, not a valid one with an empty face.
    """
    entries = _font_entries(data)
    out = {}
    for code in GLYPHS:
        idx = code + FONT_CODE_OFFSET
        if idx >= len(entries):
            continue
        off, h, w = entries[idx]
        if h != FONT_FACE_HEIGHT or w != 1:
            continue
        row_bytes = data[off + 6:off + 6 + h]
        if len(row_bytes) < h:
            continue
        rows = [format(b, '08b') for b in row_bytes]
        if len(set(rows)) > 1:
            out[code] = rows
    if not out:
        raise ValueError('no matchable glyphs in the h=%d face at 0x%x -- '
                          'truncated or wrong ROM image?' % (FONT_FACE_HEIGHT, FONT_BASE))
    return out


def score_glyph_bitmaps(data):
    """Label ('0'-'9', '0.'-'9.', ':') -> list of row bit strings, for the h=23 score face.

    Unlike glyph_bitmaps, an empty result is not an error: this face is
    unverified against any captured frame (see SCORE_FACE_LABELS), so a ROM
    image that has the on-screen h=9 face but not this one is not
    necessarily malformed.
    """
    entries = [e for e in _font_entries(data) if e[1] == SCORE_FACE_HEIGHT and e[2] == SCORE_FACE_WIDTH]
    out = {}
    for label, (off, h, w) in zip(SCORE_FACE_LABELS, entries):
        row_bytes = data[off + 6:off + 6 + h * w]
        if len(row_bytes) < h * w:
            continue
        rows = [''.join(format(b, '08b') for b in row_bytes[r * w:r * w + w]) for r in range(h)]
        if len(set(rows)) > 1:
            out[label] = rows
    return out


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

    glyphs = glyph_bitmaps(data)
    assert 0x0A not in glyphs, 'space is a uniform (all-zero) bitmap and must be dropped'
    w_bits = ('00000000', '10000010', '11010110', '11010110', '11111110',
              '01111100', '01101100', '01000100', '00000000')
    assert tuple(glyphs[0x22]) == w_bits, 'glyph 0x22 (W) bitmap does not match the boot frame'
    # 47 defined codes (48 minus space) minus 0x27, left unmapped -- see GLYPHS.
    assert len(glyphs) == 46, 'expected 46 non-space codes in the h=9 face, got %d' % len(glyphs)
    print('font self-test OK: %d matchable glyphs in the h=9 face' % len(glyphs))

    # A truncated ROM (a plausible partial chip dump) must fail cleanly, not
    # crash: cut right after entry 23's 6-byte header (off 0x202B2), with
    # none of its body present.
    try:
        glyph_bitmaps(data[:0x202B8])
        raise AssertionError('glyph_bitmaps should reject a font table truncated mid-entry')
    except ValueError:
        pass
    print('truncated-ROM self-test OK: glyph_bitmaps raises ValueError instead of crashing')

    score = score_glyph_bitmaps(data)
    assert len(score) == 21, 'expected 21 score-face labels, got %d' % len(score)
    for d in range(10):
        digit, dotted = score[str(d)], score['%d.' % d]
        # the '.' variant is the plain digit plus a small square mark at bottom
        # right (rows 19-20, cols 13-14); a plain dot, not a comma's tail --
        # nothing outside that 2x2 box ever differs, confirmed against all ten
        for i in range(SCORE_FACE_HEIGHT):
            if digit[i] == dotted[i]:
                continue
            assert i in (19, 20), 'digit %d.: mark row %d outside rows 19-20' % (d, i)
            assert digit[i][:13] == dotted[i][:13] and digit[i][15:] == dotted[i][15:], (
                'digit %d.: mark spread outside cols 13-14' % d)
    # the colon is two identical same-width blocks, one above the other, nothing else lit
    lit = [i for i, r in enumerate(score[':']) if r.count('1')]
    assert len(lit) == 8 and lit == [7, 8, 9, 10, 14, 15, 16, 17], lit
    assert len({score[':'][i] for i in lit}) == 1, 'colon: both blocks must be the same shape'
    print('score-face self-test OK: %d labels, digit/period pairs and colon shape check out' % len(score))


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
