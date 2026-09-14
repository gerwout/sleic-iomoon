#!/usr/bin/env python3
"""Decode Io Moon's glyph-encoded string pools and its switch-code -> contact table.

Both live in the 80188 code ROM's low 256 KB, which the LMCS chip select maps to
linear 0x00000-0x3FFFF (findings F1), so a pointer's segment:offset is flat.

Run directly to print the table and the pools:
    python3 scripts/iomoon_strings.py roms/iomoon/v1_3_01.bin
"""
import io
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

CONTACT_TABLE_BASE = 0x0830   # record = base + code*5: Cnum | off16 | seg16
SPANISH_TABLE_BASE = 0x1438   # same layout, same code axis

# sub_DD3FB (F14) sets [4137:004B] to one of these two flat addresses -- the
# 38-record service-menu tree, one record per DD3FB's own English/Spanish
# branch. Each 46-byte record is F14's layout (word type, word item count,
# word line count, 4 x 8-byte line descriptor, 4 x word child index); a line
# descriptor's first two words are an (offset, segment) far pointer, flat at
# (segment << 4) + offset, into the same string data CONTACT_TABLE_BASE
# reads -- record 0's first line decodes as '- ADJUSTMENT -' at flat 0x17a8.
# An unused line (fewer than 4) has offset word 0x0000 or 0xFFFF.
MENU_TABLE_BASE = 0x0100
SPANISH_MENU_TABLE_BASE = 0x0D08

# Every string either language's own two pointer-table families
# (CONTACT_TABLE_BASE/SPANISH_TABLE_BASE, MENU_TABLE_BASE/
# SPANISH_MENU_TABLE_BASE) resolve a string from, established the way
# CONTACT_TABLE_BASE itself is: walk the pointers and take the envelope
# of every offset any of them reaches, not a byte-pattern sweep.
#
# English's envelope, 0x17a8-0x1e4d, is a clean window: it holds every
# string either English table resolves, and no Spanish-table string falls
# inside it.
ENGLISH_POOL = (0x17a8, 0x1e4d)

# Spanish's own envelope is 0x1380-0x292b -- and it contains English's whole
# window (every English-table offset falls inside it), because the ROM
# interleaves the two languages' string data in blocks rather than
# partitioning it into two contiguous halves (a sample: 0x17a8 '- ADJUSTMENT
# -' and 0x185b 'NADA' are English and Spanish respectively, four bytes
# apart). No address window can bound "Spanish only" the way ENGLISH_POOL
# bounds English -- only which table resolves a pointer says which language
# a string is in, so SPANISH_POOL is left at this narrower sub-window rather
# than widened to that envelope: every string it currently sweeps is a real
# Spanish-table hit (50 of 50, checked), where the full envelope would also
# sweep in every English one. A complete Spanish enumeration is
# contact_table()'s Spanish column unioned with
# menu_records(data, SPANISH_MENU_TABLE_BASE)'s lines, not a window.
SPANISH_POOL = (0x250e, 0x2784)

# The DMD glyph table (docs/dmd_graphics.md, "Font System"): ROM1 file offset
# 0x20000, combined-image 0xA0000.  Its entries have no fixed stride -- each
# is a 6-byte header [h, 00, W, 00, len16_lo, len16_hi] (len16 = h*W, a 16-bit
# field, not a byte -- the entry at ROM1 0x22c2e is h=0x20, W=0x10, len16=
# 0x0200=512=32*16, a full-screen image, which a byte-wide read of bytes 4-5
# would misread as 0) followed by three len16-byte blocks (plane 0, plane 1,
# then a mask -- F13's composite is (background AND mask) OR sprite) -- so
# the table must be walked.  It runs 224 entries, ROM1 0x20000-0x22c2e, then
# one full-screen (h=32, W=16) image immediately follows at 0x22c2e before a
# zero header ends the run at 0x23234.
FONT_BASE = 0x20000
# The on-screen text is the h=9, W=1 (one byte, 8px) face.  Its table entry
# is the glyph code plus this offset: entry 57 matches a captured frame's
# 'W' byte-for-byte, and 'W' is glyph code 0x22 (34).
FONT_FACE_HEIGHT = 9
FONT_CODE_OFFSET = 23

# The large h=12, W=1 face -- entries 75..127, 53 entries, contiguous and
# immediately after the h=9 run.  Pinned three independent ways: entry 75
# renders a clean '0' (so code 0 = entry 75); entry 119 is a 2x2 baseline
# dot and 119-75=0x2c, the period pinned independently off the h=9 face; and
# the attract high-score screen decodes as '300.000.000' in this face beside
# 'S.MOONLIGHT' in h=9.  A "yields 38 distinct bitmaps" completeness
# heuristic is the wrong test here: two of offset 75's glyphs share a
# bitmap, so it correctly yields 37 distinct bitmaps, not 38.
FONT_H12_HEIGHT = 12
FONT_H12_CODE_OFFSET = 75

# Two 21-entry digit faces sit back to back, past the initial one-byte-wide
# run (docs/dmd_graphics.md): the large 16x23 price/score face, then a small
# 8x12 digit face immediately after it. Both share the same 21-label layout
# (0-9 plain, 10-19 the same digits plus a decimal-point mark, 20 a colon)
# and are indexed by absolute table position, not code + an offset --
# necessary because table position, not shape, is what tells them apart: a
# second, unrelated 8x12 face (FONT_H12_HEIGHT/FONT_H12_CODE_OFFSET, entries
# 75-127) already has the same (height, width), so filtering _font_entries
# by shape alone would pick up the wrong block for the small digit face.
SCORE_FACE_HEIGHT = 23
SCORE_FACE_WIDTH = 2
SCORE_FACE_INDEX = 162    # table index 162 renders a 16x23 '0'

# The small digit face -- confirmed against a real frame, unlike the large
# one above: entries 183-192 (0-9) and 194-203 (0.-9.) exact-match a run of
# digits at row 0 of dmd/en/screens/0287-ball-2-in-play/repr.txt, decoding
# '3. 8.743'.  Scanning every entry of both digit faces against all 27,712
# raw frames of dmd/en/iomoont.txt.gz, the large (23, 2) face never exact-
# matches anywhere in the corpus; this one does, repeatedly, in gameplay.
SMALL_DIGIT_FACE_HEIGHT = 12
SMALL_DIGIT_FACE_WIDTH = 1
SMALL_DIGIT_FACE_INDEX = 183   # immediately after the 21 SCORE_FACE entries

# 0-9 plain digits, 10-19 the same digits with an attached decimal point (a
# plain 2x2 dot at bottom right, not a comma's tail -- a Spanish-market
# machine's peseta-style NNN.NNN pricing), 20 a colon (two stacked blocks,
# matching the h=9 face's ':' shape scaled up).
SCORE_FACE_LABELS = [str(d) for d in range(10)] + ['%d.' % d for d in range(10)] + [':']

# The in-play PLAYER/BALL HUD is not a walked-table code+offset face at all
# -- it is five whole-word bitmaps (both languages) pulled by hard-coded far
# pointers (offset, segment; little-endian) out of a much larger literal-
# pointer pool that starts right after a RETF at flat 0xF5182 and runs 155
# four-byte entries (CS:05183-CS:053EB) to a null terminator at CS:053EF,
# then zero padding. Confirmed by grepping iomoon_80188.lst for every
# CS:052xx/CS:053xx operand: dozens of `LES SI,CS:xxxx` sites, scattered
# across many unrelated subroutines, address this one 620-byte span --
# most of it resolves to unrelated assets (full-screen 32x16 attract/menu
# pictures in F20's own format, the walked font table's own entries reached
# a second way, work-RAM addresses) and is out of scope here. The five HUD
# words sit in one tight run, CS:0522F-CS:0523F, each entry the walked
# table's own [h,00,w,00,len16] header+3-plane format but holding a whole
# rendered word rather than a per-character glyph -- confirmed by
# segmenting each bitmap on blank columns and reading the letters directly
# off the pixels, and independently by the LES SI,CS:xxxx operand at each
# drawing routine's own call site:
#
#   CS:0522F  h=8  w=3  "BALL"           sub_F0D70 (single reference)
#   CS:05233  h=8  w=5  "EXTRA BALL"     sub_F0DB2/F0DDA/F0E1A (flash pair)
#   CS:05237  h=16 w=6  "INSERT/COIN"    sub_F0E60/F0E85/F0EAB
#   CS:0523B  h=8  w=7  "PLAYERS"        sub_F0FFA/F1054, + a digit from
#                                        PLAYER_NUM_BASE below
#   CS:0523F  h=8  w=5  "PLAYER"         sub_F108E/F10E5, + a digit, same
#                                        table
#
# Spanish counterparts sit in the same pool at country-switched sites
# (CMP [4137:1001],5, F11) right next to each English LES -- but not all at
# the same fixed offset: CS:05363/05367/0536B pair with the first three at
# +0x134 (BOLA / BOLA EXTRA / INTRODUCIR-MONEDA), while CS:05373/05377 pair
# with PLAYERS/PLAYER at +0x138, confirmed from the actual `LES SI,CS:05373`
# / `CS:05377` operands inside sub_F0FFA/sub_F108E themselves (JUGADORES /
# JUGADOR), not assumed from the first pair's offset.
#
# Every entry here is single-plane for legibility -- plane 0 alone renders
# the word; plane 1 and the mask, both present (the format always carries
# three planes), are unused, the same convention glyph_bitmaps already uses
# for the h=9/h=12 faces -- confirmed by rendering plane 0 alone and reading
# real words off it.
HUD_MESSAGE_POINTERS = {
    'BALL': 0x0522F, 'EXTRA BALL': 0x05233, 'INSERT COIN': 0x05237,
    'PLAYERS': 0x0523B, 'PLAYER': 0x0523F,
    'BOLA': 0x05363, 'BOLA EXTRA': 0x05367, 'INTRODUCIR MONEDA': 0x0536B,
    'JUGADORES': 0x05373, 'JUGADOR': 0x05377,
}

# The player/ball number glyph drawn right after PLAYER or PLAYERS above:
# work-RAM byte 413C:00D7 (PLAYERS' own routine) or 413C:00FE (PLAYER's) is
# read, then multiplied by this table's own stride and added to
# PLAYER_NUM_BASE (`MUL DX,0x1E` / `ADD SI,AX` at F103E/F10D3) -- a
# code+offset digit face in the walked table's own header+3-plane format,
# no different in kind from FONT_H12_CODE_OFFSET above, just at a table
# this decoder had not walked from before. Not language-switched (digits
# don't need to be).
PLAYER_NUM_BASE = 0x0531B    # CS:0531B; h=8, w=1, stride 0x1E (one full entry)
PLAYER_NUM_STRIDE = 0x1E

# The in-play SCORE digit table (F13's DMD pipeline draws into the same
# composite/blit path every other DMD content uses). Pointer at CS:052BB
# resolves to flat 0x29154 and indexes by digit value with `MUL DX,0x6C`
# (108) -- confirmed by reading sub_F0907's own draw loop in
# iomoon_80188.lst, not assumed from the stride alone: byte value 1 is
# intercepted as a decimal-point sentinel *before* the multiply (CS:052C3,
# a separate, always-single-call pointer that happens to physically sit
# where "digit 1" would fall under the stride formula but is never reached
# that way), so the multiply only ever runs for byte values 0 and 2-9 --
# digit 1 is not reached via this path and is left out below rather than
# guessed.
#
# Each 108-byte digit slot is NOT the header+3-plane format the walked
# table and HUD_MESSAGE_POINTERS above both use, and it is not "3 planes x
# 12 rows x 3 bytes" either (a plausible guess from the byte count alone
# that renders as noise, not digits, when tried) -- it has no header at
# all. sub_F0C7B, the routine every mode-0 digit call site uses, draws a
# fixed 18 rows (`MOV BP,0x12` / `MOV CX,0x12`, both hard-coded, not read
# from any header) of one byte each -- three such 18-row/8px planes
# (plane 0, plane 1, mask; 54 bytes) -- then the caller (sub_F0907,
# F09D2-F09D6) calls it a SECOND time one byte-column to the left (`DEC
# DI`) before drawing again. The second call's source is not the first
# call's data replayed: sub_F0C7B advances SI by 54 internally, so the
# second 54-byte half is distinct ROM data, not a repeated stamp -- the two
# halves are the left and right 8px columns of one 16px-wide, 18-row glyph,
# not a blurred duplicate. Read that way (both halves, level =
# 2*plane0_bit + plane1_bit, F13's own weighting, mask unused -- see
# below), digit 2's bitmap matches
# `dmd/en/screens/5132-score-ball-3-in-play/repr.txt` byte-for-byte at
# (row 0, column 8) -- the ROM's own data reproducing a real captured frame
# exactly, not merely a plausible-looking render.
#
# The mask plane is not needed for legibility, matching glyph_bitmaps' and
# score_glyph_bitmaps' own precedent (neither reads a mask either): every
# digit, read as level = 2*plane0_bit + plane1_bit with no mask applied,
# comes out as a clean, fully-formed shape using only level 0 and level 3 --
# no level 1 or 2 appears anywhere in any digit, so there is no stored
# "mid-tone interior" to recover by reading the mask. Whatever mid-tone
# shading a captured frame shows around these digits is not stored in this
# table; the mask bits that exist instead mark each digit's own margin and
# its loop interior as "background passes through" (F13's sprite-mask
# convention), a property of the DMD composite step, not of the glyph.
#
# Consecutive digits in a real number overlap in the drawn frame: the
# confirmed digit "2" above sits at its full, unclipped 16px width because
# it is the leftmost (most significant, last-drawn) digit in its own
# number; a plain-overwrite draw order (right-to-left, most significant
# digit drawn last, per sub_F0907's own scan direction) means an
# earlier-drawn digit's own columns get overwritten by whatever draws after
# it. An exact-bitmap matcher only recovers the digits that happen to
# survive a given frame's own overwrite order, not every digit of a longer
# number -- a real limitation of the mechanism, not a decoder bug; see
# dmd/README.md for the measured effect on corpus recovery.
#
# A second, alternating drawing path exists (CS:052BF, `010CD`'s own
# toggle in sub_F0907 selects it for a digit immediately following a
# decimal point) using a different compositing primitive (sub_F0C49: OR
# then AND, not plain overwrite) and, per the pointer pool above, its own
# base 10 stride-slots after CS:052BB's -- not modelled here; only the
# CS:052BB path this comment already confirms against a real frame is.
SCORE_DIGIT_BASE = 0x052BB   # CS:052BB; a MUL DX,0x6C base, not a header
SCORE_DIGIT_POINT = 0x052C3  # CS:052C3; decimal point, single 54-byte half
SCORE_DIGIT_STRIDE = 0x6C
SCORE_DIGIT_HEIGHT = 18


def _font_entries(data, base=FONT_BASE):
    """[(offset, height, width_bytes), ...], walking the glyph table from `base`.

    Stops cleanly, with no message, at the first all-zero header (h == 0 or
    W == 0) or the first header whose len16 (bytes 4-5, little-endian) does
    not equal height*W -- on the real ROM this is the zero header at ROM1
    0x23234, right after the one full-screen image that follows the last
    glyph. Stops loudly, printing to stderr, when a header parses fine but
    its body runs past the end of `data`: that is a truncated ROM, not the
    table's real end, and a caller silently getting fewer glyphs back than
    the ROM actually has is exactly the failure mode this reports.
    """
    out = []
    off = base
    while off + 6 <= len(data):
        h, w = data[off], data[off + 2]
        len16 = data[off + 4] | (data[off + 5] << 8)
        if h == 0 or w == 0 or len16 != h * w:
            break
        if off + 6 + 3 * len16 > len(data):
            print('iomoon_strings: font table truncated mid-entry at 0x%x (h=%d, w=%d) -- '
                  '%d entries read, everything past this point is missing'
                  % (off, h, w, len(out)), file=sys.stderr)
            break
        out.append((off, h, w))
        off += 6 + 3 * len16
    return out


def glyph_bitmaps(data, height=FONT_FACE_HEIGHT, code_offset=FONT_CODE_OFFSET):
    """Glyph code -> list of row bit strings, for a one-byte-wide face.

    Defaults to the on-screen h=9 face; pass height=FONT_H12_HEIGHT,
    code_offset=FONT_H12_CODE_OFFSET for the large h=12 face.

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
        idx = code + code_offset
        if idx >= len(entries):
            continue
        off, h, w = entries[idx]
        if h != height or w != 1:
            continue
        row_bytes = data[off + 6:off + 6 + h]
        if len(row_bytes) < h:
            continue
        rows = [format(b, '08b') for b in row_bytes]
        if len(set(rows)) > 1:
            out[code] = rows
    if not out:
        raise ValueError('no matchable glyphs in the h=%d face at 0x%x -- '
                          'truncated or wrong ROM image?' % (height, FONT_BASE))
    return out


def score_glyph_bitmaps(data, height=SCORE_FACE_HEIGHT, width=SCORE_FACE_WIDTH, index=SCORE_FACE_INDEX):
    """Label ('0'-'9', '0.'-'9.', ':') -> list of row level strings, for a digit face.

    Defaults to the large h=23 score/price face at SCORE_FACE_INDEX; pass
    height=SMALL_DIGIT_FACE_HEIGHT, width=SMALL_DIGIT_FACE_WIDTH,
    index=SMALL_DIGIT_FACE_INDEX for the small h=12 digit face. Both are
    read by absolute table position (`index` + label position), not by
    filtering the whole table for matching (height, width): the small face
    shares its shape with an unrelated face (FONT_H12_HEIGHT/
    FONT_H12_CODE_OFFSET), so a shape-only filter would pick up the wrong
    21 entries.

    The large face is SHADED: a bright (level 3) outline around a mid-tone
    (level 1) interior, so a single bitplane cannot represent one -- the
    match key has to combine both. Each row is a string of '0'-'3'
    characters (one per pixel, MSB first), built as level = 2*plane0_bit +
    plane1_bit, the same weighting the display pipeline itself uses (F13:
    plane 0 the MSB) -- not the '0'/'1' bit strings glyph_bitmaps returns
    for the single-plane faces. The small face happens to use only levels 0
    and 3 (plane 0 and plane 1 always agree), so the same level-string key
    still matches it correctly without a separate code path.

    Unlike glyph_bitmaps, an empty result is not an error: a ROM image that
    has the on-screen h=9 face but not this one is not necessarily
    malformed.
    """
    entries = _font_entries(data)
    out = {}
    for i, label in enumerate(SCORE_FACE_LABELS):
        idx = index + i
        if idx >= len(entries):
            continue
        off, h, w = entries[idx]
        if h != height or w != width:
            continue
        hw = h * w
        plane0 = data[off + 6:off + 6 + hw]
        plane1 = data[off + 6 + hw:off + 6 + 2 * hw]
        if len(plane1) < hw:
            continue
        rows = []
        for r in range(h):
            row = []
            for c in range(w):
                b0, b1 = plane0[r * w + c], plane1[r * w + c]
                row.extend(str(((b0 >> bit) & 1) * 2 + ((b1 >> bit) & 1)) for bit in range(7, -1, -1))
            rows.append(''.join(row))
        if len(set(rows)) > 1:
            out[label] = rows
    return out


def _far_cs(data, cs_offset):
    """Resolve one CS:xxxx far pointer (offset, segment; little-endian),
    stored at flat 0xF0000+cs_offset (file 0x70000+cs_offset), to the file
    offset its target lives at. Every pointer HUD_MESSAGE_POINTERS,
    PLAYER_NUM_BASE and SCORE_DIGIT_BASE/SCORE_DIGIT_POINT use resolves into
    ROM1's LMCS-resident low half (F1, flat < 0x40000), so the result is
    already a file offset -- unlike FONT_BASE's own CS:-based callers, no
    further +0x80000 adjustment is needed.
    """
    file_off = 0x70000 + cs_offset
    off = data[file_off] | (data[file_off + 1] << 8)
    seg = data[file_off + 2] | (data[file_off + 3] << 8)
    return (seg << 4) + off


def hud_message_bitmaps(data):
    """label -> (height, width_px, [row_bit_string, ...]), one entry per
    in-play HUD word (both languages) -- see HUD_MESSAGE_POINTERS' own
    comment for the pool this reads and what it does and does not cover.

    Unlike glyph_bitmaps' output, entries here vary in both height (8 for
    every word except the two-line 'INSERT COIN'/'INTRODUCIR MONEDA' pair,
    which are 16) and width, because each is a whole rendered phrase, not a
    character cell -- a caller matches each one as its own complete bitmap
    rather than assembling a line glyph by glyph.
    """
    out = {}
    for label, cs_off in HUD_MESSAGE_POINTERS.items():
        off = _far_cs(data, cs_off)
        h, _z1, w, _z2, l0, l1 = data[off:off + 6]
        len16 = l0 | (l1 << 8)
        assert len16 == h * w, (label, hex(off), h, w, len16)
        plane0 = data[off + 6:off + 6 + len16]
        rows = [''.join(format(b, '08b') for b in plane0[r * w:(r + 1) * w])
                for r in range(h)]
        out[label] = (h, w * 8, rows)
    return out


def player_number_bitmaps(data, base=PLAYER_NUM_BASE, stride=PLAYER_NUM_STRIDE):
    """'0'-'9' -> row-bit-string list, for the player/ball number glyph
    drawn beside PLAYER/PLAYERS -- see PLAYER_NUM_BASE's own comment. Same
    walked-table entry format as the h=9/h=12 faces (single-plane, plane 0
    only), just reached by a direct base+digit*stride rather than
    code+offset into FONT_BASE.
    """
    start = _far_cs(data, base)
    out = {}
    for d in range(10):
        off = start + d * stride
        h, _z1, w, _z2, l0, l1 = data[off:off + 6]
        len16 = l0 | (l1 << 8)
        if len16 != h * w:
            continue
        plane0 = data[off + 6:off + 6 + len16]
        rows = [''.join(format(b, '08b') for b in plane0[r * w:(r + 1) * w])
                for r in range(h)]
        if len(set(rows)) > 1:
            out[str(d)] = rows
    return out


def _score_digit_block(data, off, height=SCORE_DIGIT_HEIGHT):
    """One 54-byte half (height rows x 1 byte, 3 planes: plane0/plane1/mask
    -- see SCORE_DIGIT_BASE's own comment; the mask is read here but never
    used, kept only so a caller could inspect it."""
    plane0 = data[off:off + height]
    plane1 = data[off + height:off + 2 * height]
    mask = data[off + 2 * height:off + 3 * height]
    return plane0, plane1, mask


def _score_digit_levels(plane0, plane1):
    """height rows of an 8-pixel-wide level string ('0'-'3'); mask unused,
    see SCORE_DIGIT_BASE's own comment for why."""
    return [''.join(str(((b0 >> bit) & 1) * 2 + ((b1 >> bit) & 1)) for bit in range(7, -1, -1))
            for b0, b1 in zip(plane0, plane1)]


def score_digit_bitmaps(data, base=SCORE_DIGIT_BASE, point=SCORE_DIGIT_POINT,
                         stride=SCORE_DIGIT_STRIDE, height=SCORE_DIGIT_HEIGHT):
    """'0', '2'-'9' and '.' -> level-string rows, for the in-play score
    digit table (SCORE_DIGIT_BASE) -- see that constant's own comment for
    the layout this reads and what it does and does not recover. Digits are
    `height` rows x 16 px (two adjacent 8px halves, left then right, per
    sub_F0907's own draw order -- DEC DI shifts the *second* call left of
    the first); the decimal point is `height` rows x 8 px (one half only,
    matching how sub_F0907 draws it: a single call, never doubled). '1' is
    not returned -- see SCORE_DIGIT_BASE's own comment for why it is not
    reachable via this table at all.
    """
    out = {}
    start = _far_cs(data, base)
    for d in range(10):
        if d == 1:
            continue
        slot = start + d * stride
        p0_right, p1_right, _m = _score_digit_block(data, slot, height)
        p0_left, p1_left, _m = _score_digit_block(data, slot + 3 * height, height)
        left = _score_digit_levels(p0_left, p1_left)
        right = _score_digit_levels(p0_right, p1_right)
        out[str(d)] = [l + r for l, r in zip(left, right)]
    point_off = _far_cs(data, point)
    p0, p1, _m = _score_digit_block(data, point_off, height)
    out['.'] = _score_digit_levels(p0, p1)
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


def menu_records(data, base=MENU_TABLE_BASE, count=38):
    """The service-menu tree (F14) at `base`: [(type, item_count, line_count, [line strings], children), ...].

    `base` is MENU_TABLE_BASE (English) or SPANISH_MENU_TABLE_BASE (country
    5, Spanish); `children` is the 4 child record indices (0xFFFF where a
    slot is unused). Decodes strictly fewer lines than `line_count` gives no
    error: a leaf record's later line slots carry 0xFFFF and are skipped, not
    a malformed table.
    """
    out = []
    for i in range(count):
        rec = data[base + i * 46:base + i * 46 + 46]
        if len(rec) < 46:
            break
        rtype, item_count, line_count = struct.unpack('<HHH', rec[0:6])
        lines = []
        for j in range(4):
            off16, seg16 = struct.unpack('<HH', rec[6 + 8 * j:10 + 8 * j])
            if off16 in (0x0000, 0xFFFF):
                continue
            s = decode_string(data, (seg16 << 4) + off16)
            if s is not None:
                lines.append(s)
        children = struct.unpack('<HHHH', rec[38:46])
        out.append((rtype, item_count, line_count, lines, children))
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

    # The h=12 face (FONT_H12_HEIGHT/FONT_H12_CODE_OFFSET): entry 75 is code
    # 0, a clean '0'; entry 119 (75 + 0x2c) is the period, a 2x2 baseline dot,
    # the same shape class as the h=9 face's own period.
    glyphs12 = glyph_bitmaps(data, height=FONT_H12_HEIGHT, code_offset=FONT_H12_CODE_OFFSET)
    zero_bits = ('00000000', '00111100', '01111110', '01100110', '01100110', '01100110',
                 '01100110', '01100110', '01100110', '01111110', '00111100', '00000000')
    assert tuple(glyphs12[0]) == zero_bits, 'h=12 entry 75 (code 0) is not a clean 0'
    dot_bits = ('00000000',) * 9 + ('00011000', '00011000', '00000000')
    assert tuple(glyphs12[0x2C]) == dot_bits, 'h=12 entry 119 (75+0x2c) is not a 2x2 baseline dot'
    # 47 defined codes minus 0x27 -- same completeness as the h=9 face.
    assert len(glyphs12) == 46, 'expected 46 non-space codes in the h=12 face, got %d' % len(glyphs12)
    print('h=12 font self-test OK: %d matchable glyphs' % len(glyphs12))

    # A truncated ROM (a plausible partial chip dump) must fail cleanly, not
    # crash: cut right after entry 23's 6-byte header (off 0x202B2), with
    # none of its body present.
    try:
        glyph_bitmaps(data[:0x202B8])
        raise AssertionError('glyph_bitmaps should reject a font table truncated mid-entry')
    except ValueError:
        pass
    print('truncated-ROM self-test OK: glyph_bitmaps raises ValueError instead of crashing')

    # A later truncation -- past enough entries that glyph_bitmaps' own
    # non-emptiness check is already satisfied, but before the table's real
    # end -- must still be reported, not merely returned short: cut mid-body
    # of entry 60 ('X', table index 60 + no offset needed here, just past
    # the codes a minimal ROM read would already have found).
    stderr, sys.stderr = sys.stderr, io.StringIO()
    try:
        cut = _font_entries(data)[60][0] + 8  # past the header, mid-body
        glyphs_short = glyph_bitmaps(data[:cut])
        warned = sys.stderr.getvalue()
    finally:
        sys.stderr = stderr
    assert glyphs_short, 'a mid-table cut should still return the entries before it'
    assert 'truncated' in warned, 'a mid-table cut must warn, not fail silently: got %r' % warned
    print('loud-truncation self-test OK: a later cut still warns (%d glyphs recovered)' % len(glyphs_short))

    en_menu = menu_records(data, MENU_TABLE_BASE)
    assert len(en_menu) == 38, 'expected 38 English menu records, got %d' % len(en_menu)
    assert en_menu[0][3] == ['- ADJUSTMENT -', 'SOUND/VIDEO', 'GAME', 'TECHNICAL'], en_menu[0]
    assert en_menu[0][4] == (1, 2, 3, 0xFFFF), en_menu[0]
    assert en_menu[4][3][0] == '- VOLUME -', en_menu[4]  # F14: the music-trigger page
    assert en_menu[23][3][0] == '  OF  10 CRED:', en_menu[23]  # F14: the CREDITS page
    es_menu = menu_records(data, SPANISH_MENU_TABLE_BASE)
    assert len(es_menu) == 38, 'expected 38 Spanish menu records, got %d' % len(es_menu)
    assert es_menu[0][3][0] == '- AJUSTE -', es_menu[0]
    print('menu-record self-test OK: %d English + %d Spanish records decode' % (len(en_menu), len(es_menu)))

    score = score_glyph_bitmaps(data)
    assert len(score) == 21, 'expected 21 score-face labels, got %d' % len(score)
    for d in range(10):
        digit, dotted = score[str(d)], score['%d.' % d]
        # the '.' variant is the plain digit plus a small shaded mark at
        # bottom right (rows 19-21, cols 13-15) -- a dot, not a comma's
        # tail -- nothing outside that box ever differs, confirmed against
        # all ten; digit 7 has no difference at all (the ROM's '7' and '7.'
        # entries share a bitmap, the same kind of glyph reuse the h=12 face
        # shows at offset 75).
        for i in range(SCORE_FACE_HEIGHT):
            if digit[i] == dotted[i]:
                continue
            assert i in (19, 20, 21), 'digit %d.: mark row %d outside rows 19-21' % (d, i)
            assert digit[i][:13] == dotted[i][:13], 'digit %d.: mark spread left of col 13' % d
    # the colon is two identical shaded blocks, one above the other, nothing else lit
    lit = [i for i, r in enumerate(score[':']) if any(ch != '0' for ch in r)]
    assert lit == [7, 8, 9, 10, 11, 14, 15, 16, 17, 18], lit
    assert score[':'][7:12] == score[':'][14:19], 'colon: both blocks must be the same shape'
    print('score-face self-test OK: %d labels, digit/period pairs and colon shape check out' % len(score))

    small = score_glyph_bitmaps(data, height=SMALL_DIGIT_FACE_HEIGHT, width=SMALL_DIGIT_FACE_WIDTH,
                                 index=SMALL_DIGIT_FACE_INDEX)
    assert len(small) == 21, 'expected 21 small-digit-face labels, got %d' % len(small)
    zero_bits = ('00000000', '00333000', '03000300', '03000300', '03000300', '00000000',
                 '03000300', '03000300', '03000300', '00333000', '00000000', '00000000')
    assert tuple(small['0']) == zero_bits, 'small-digit-face entry 183 is not a closed-loop 0'
    # unlike the large score face, this one is never shaded -- every pixel is level 0 or 3
    assert set(''.join(small['8'])) <= set('03'), 'small-digit-face should use only levels 0/3'
    print('small-digit-face self-test OK: %d labels' % len(small))

    hud = hud_message_bitmaps(data)
    assert set(hud) == {
        'BALL', 'EXTRA BALL', 'INSERT COIN', 'PLAYERS', 'PLAYER',
        'BOLA', 'BOLA EXTRA', 'INTRODUCIR MONEDA', 'JUGADORES', 'JUGADOR',
    }, sorted(hud)
    ball_h, ball_w, ball_rows = hud['BALL']
    assert (ball_h, ball_w) == (8, 24), (ball_h, ball_w)
    # segmenting BALL's own bitmap on blank columns and reading the letters
    # directly off the pixels is how this table was found in the first
    # place -- pin one full row here so a future ROM swap that silently
    # shuffles the pointer pool is caught by a shape mismatch, not missed.
    assert ball_rows[1] == '001110001100100001000000', ball_rows[1]
    insert_h, insert_w, _insert_rows = hud['INSERT COIN']
    assert (insert_h, insert_w) == (16, 48), (insert_h, insert_w)
    print('hud-message self-test OK: %d words, both languages' % len(hud))

    pnum = player_number_bitmaps(data)
    assert len(pnum) == 10, 'expected 10 player-number digits, got %d' % len(pnum)
    zero_bits = ('00000000', '00011000', '00100100', '00100100',
                 '00100100', '00100100', '00011000', '00000000')
    assert tuple(pnum['0']) == zero_bits, 'player-number digit 0 is not a closed-loop 0'
    print('player-number self-test OK: %d digits' % len(pnum))

    sdig = score_digit_bitmaps(data)
    assert set(sdig) == {'0', '2', '3', '4', '5', '6', '7', '8', '9', '.'}, sorted(sdig)
    # digit 2's stored bitmap reproduces a real captured frame byte-for-byte
    # (dmd/en/screens/5132-score-ball-3-in-play/repr.txt, rows 0-17,
    # columns 8-23) -- the strongest evidence this table's layout is right,
    # so pin it here rather than just a shape check.
    two_bits = (
        '0000000000000000', '0000000033333000', '0000000333333300', '0000003330003330',
        '0000003300000330', '0000003300000330', '0000000000000330', '0000000000000330',
        '0000000000003300', '0000000000003300', '0000000000033000', '0000000000330000',
        '0000000003300000', '0000000033000000', '0000000330000000', '0000003333333330',
        '0000033333333330', '0000000000000000',
    )
    assert tuple(sdig['2']) == two_bits, 'score digit 2 does not match the captured frame'
    print('score-digit self-test OK: %d labels' % len(sdig))


if __name__ == '__main__':
    path = sys.argv[1] if len(sys.argv) > 1 else 'roms/iomoon/v1_3_01.bin'
    blob = open(path, 'rb').read()
    _self_test(blob)
    print('\n=== contact table (F16) ===')
    for code in sorted(contact_table(blob)):
        cnum, en, es = contact_table(blob)[code]
        print('  %02X  C%-3d  %-16s %s' % (code, cnum, en, es))
    print('\n=== English menu tree (F14) ===')
    for i, (rtype, item_count, line_count, lines, children) in enumerate(menu_records(blob, MENU_TABLE_BASE)):
        print('  %2d  type %-2d  %s  -> %s' % (i, rtype, ' / '.join(lines), children))
    print('\n=== Spanish menu tree (F14) ===')
    for i, (rtype, item_count, line_count, lines, children) in enumerate(menu_records(blob, SPANISH_MENU_TABLE_BASE)):
        print('  %2d  type %-2d  %s  -> %s' % (i, rtype, ' / '.join(lines), children))
    print('\n=== English pool ===')
    for off, s in string_pool(blob, *ENGLISH_POOL):
        print('  %06x |%s|' % (off, s))
    print('\n=== Spanish pool (a narrow, verified-clean sub-window; see SPANISH_POOL) ===')
    for off, s in string_pool(blob, *SPANISH_POOL):
        print('  %06x |%s|' % (off, s))
