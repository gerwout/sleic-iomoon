#!/usr/bin/env python3
"""Build the English DMD artwork for the Bike Race translation patch.

Everything the patch writes into graphics ROMs 05 and 06 is a PNG in `art/`,
one file per ROM record, named `BK<rom>_<index>_record_0x<offset>.png` after
`sleic_dmd_viewer.py --index` (plus `BK05_Freeplay.png`, which has no slot of
its own).  Most of them are hand-drawn and are copied in unchanged from the
source folder.  This script derives the rest:

  BK05_0184..0187  "1MILLION" -> "1 MILLION": the "1" and the word are moved
                   apart (the four frames of the zoom keep their own letters)
  BK05_0198        "SPAREPARTS" -> "SPARE PARTS", the same way
  BK05_0211        "Replay" (was "Match"), Nimbus Roman Bold with the drop
                   shadow the original "Partida" uses
  BK05_0221/0222   "First" / "Second" (were "Primary" / "Secondary"), Z003
                   (Zapf Chancery) outlined like "Primera" / "Segunda"
  BK05_0226        "Aerial view..." (was "Viewing aerea..."), Z003 with the
                   original's one-dot shadow
  BK06_0081/0082   "ONE" (was "UNO"): the U is closed into an O, the N stays,
                   the rider's face moves 12 px right and an E is drawn in the
                   space it leaves
  BK05_roll        the 128x270 staff-credits roll at 0x08276: ELECTROMECANICA,
                   DISENO MECANICO, MUSICA, FABRICADO POR and "tlf." become
                   ELECTROMECHANICS, MECHANICAL DESIGN, MUSIC, MADE BY and TEL.,
                   set in the roll's own letters (G and Y drawn to match).  The
                   names, the company and its address stay as they are

    python3 make_art.py --src ../../../brace_english/brace/ppm --out art

Levels are the panel's own: 0 off, 1 dim, 2 half, 3 full (palette below).
"""
import argparse
import os
import shutil
import struct

import numpy as np
from PIL import Image, ImageDraw, ImageFont

HERE = os.path.dirname(os.path.abspath(__file__))
ROMDIR = os.path.join(HERE, '..', '..', 'roms', 'related-machines', 'bike-race')
PAL = [(0, 0, 0), (85, 34, 0), (170, 68, 0), (255, 102, 0)]
SERIF_BOLD = '/usr/share/fonts/opentype/urw-base35/NimbusRoman-Bold.otf'
SCRIPT = '/usr/share/fonts/opentype/urw-base35/Z003-MediumItalic.otf'


def rom_levels(rom, off):
    r, b, s = struct.unpack('<HHH', rom[off:off + 6])
    p0 = np.unpackbits(np.frombuffer(rom[off + 6:off + 6 + s], np.uint8)).reshape(r, b * 8)
    p1 = np.unpackbits(np.frombuffer(rom[off + 6 + s:off + 6 + 2 * s], np.uint8)).reshape(r, b * 8)
    return (2 * p0 + p1).astype(np.uint8)


def load(path):
    a = np.array(Image.open(path).convert('RGB'))[:, :, 0].astype(int)
    return np.select([a < 40, a < 120, a < 200], [0, 1, 2], 3).astype(np.uint8)


def save(lv, path):
    rgb = np.array(PAL, np.uint8)[lv]
    Image.fromarray(rgb, 'RGB').save(path)


def text_box(text, font, w, h, thr):
    """`text` rendered large, cropped to its ink and resampled to exactly w x h."""
    f = ImageFont.truetype(font, 200)
    l, t, r, b = f.getbbox(text)
    im = Image.new('L', (r - l + 20, b - t + 20), 0)
    ImageDraw.Draw(im).text((10 - l, 10 - t), text, font=f, fill=255)
    ys, xs = np.where(np.array(im) > 0)
    im = im.crop((xs.min(), ys.min(), xs.max() + 1, ys.max() + 1)).resize((w, h), Image.LANCZOS)
    return np.array(im) / 255.0 > thr


def text_fit(text, font, maxw, maxh, thr):
    """`text` at the largest point size whose ink fits maxw x maxh."""
    for px in range(80, 8, -1):
        f = ImageFont.truetype(font, px * 8)
        l, t, r, b = f.getbbox(text)
        im = Image.new('L', (r - l + 32, b - t + 32), 0)
        ImageDraw.Draw(im).text((16 - l, 16 - t), text, font=f, fill=255)
        im = im.resize((im.size[0] // 8, im.size[1] // 8), Image.BOX)
        a = np.array(im) / 255.0 > thr
        ys, xs = np.where(a)
        a = a[ys.min():ys.max() + 1, xs.min():xs.max() + 1]
        if a.shape[0] <= maxh and a.shape[1] <= maxw:
            return a
    raise ValueError(text)


def place(mask, w, h, x0=None, y0=None):
    out = np.zeros((h, w), bool)
    mh, mw = mask.shape
    x0 = (w - mw) // 2 if x0 is None else x0
    y0 = (h - mh) // 2 if y0 is None else y0
    out[y0:y0 + mh, x0:x0 + mw] = mask
    return out


def shift(b, dx, dy):
    s = np.zeros_like(b)
    h, w = b.shape
    s[max(dy, 0):h + min(dy, 0), max(dx, 0):w + min(dx, 0)] = \
        b[max(-dy, 0):h + min(-dy, 0), max(-dx, 0):w + min(-dx, 0)]
    return s


def dilate(b, r):
    out = b.copy()
    for dy in range(-r, r + 1):
        for dx in range(-r, r + 1):
            if dx * dx + dy * dy <= r * r + r:
                out |= shift(b, dx, dy)
    return out


def shadow_style(b, offs):
    """Full-bright text over a dim shadow cast down and to the right."""
    sh = np.zeros_like(b)
    for dx, dy in offs:
        sh |= shift(b, dx, dy)
    lv = np.zeros(b.shape, np.uint8)
    lv[sh & ~b] = 1
    lv[b] = 3
    return lv


def outline_style(b, r=2):
    """Black glyph, full-bright outline, dim background -- "Primera"'s look."""
    lv = np.full(b.shape, 1, np.uint8)
    lv[dilate(b, r)] = 3
    lv[b] = 0
    return lv


def respace_one_million(lv, gap=8):
    """Move the leading "1" away from "MILLION" and re-centre the pair."""
    ink = (lv > 0).any(axis=0)
    xs = np.where(ink)[0]
    end1 = xs[0]
    while ink[end1 + 1]:
        end1 += 1
    one = lv[:, xs[0]:end1 + 1]
    word = lv[:, xs[np.searchsorted(xs, end1 + 1)]:xs[-1] + 1]
    w = lv.shape[1]
    # the two largest frames fill the panel: narrow the word's 2+ px letter
    # gaps by one column each until the space can be at least `gap` wide
    blank = ~(word > 0).any(axis=0)
    drop = []
    for x in range(1, word.shape[1]):
        if w - 2 - one.shape[1] - (word.shape[1] - len(drop)) >= gap:
            break
        if blank[x] and blank[x - 1]:
            drop.append(x)
            blank[x] = False
    word = np.delete(word, drop, axis=1)
    need = gap - (w - 2 - one.shape[1] - word.shape[1])
    if need > 0:
        word = squeeze(word, need)
    g = min(gap, w - 2 - one.shape[1] - word.shape[1])
    total = one.shape[1] + g + word.shape[1]
    x = (w - total) // 2
    out = np.zeros_like(lv)
    out[:, x:x + one.shape[1]] = one
    out[:, x + one.shape[1] + g:x + total] = word
    return out


def squeeze(part, n):
    """Drop n columns that repeat their left neighbour inside a thick stroke,
    spread across `part`, which leaves every letter's shape."""
    dup = [x for x in range(1, part.shape[1])
           if (part[:, x] > 0).any() and (part[:, x] == part[:, x - 1]).all()]
    pick = [dup[int((i + 0.5) * len(dup) / n)] for i in range(n)]
    return np.delete(part, pick, axis=1)


def split_words(lv, split, gap):
    """Open a `gap` at column `split`, narrowing both words to make room."""
    def trim(p):
        xs = np.where((p > 0).any(axis=0))[0]
        return p[:, xs[0]:xs[-1] + 1]
    left, right = trim(lv[:, :split]), trim(lv[:, split:])
    w = lv.shape[1]
    need = left.shape[1] + gap + right.shape[1] - (w - 2)
    if need > 0:
        nl = need * left.shape[1] // (left.shape[1] + right.shape[1])
        left, right = squeeze(left, nl), squeeze(right, need - nl)
    total = left.shape[1] + gap + right.shape[1]
    x = (w - total) // 2
    out = np.zeros_like(lv)
    out[:, x:x + left.shape[1]] = left
    out[:, x + left.shape[1] + gap:x + total] = right
    return out


def uno_to_one(lv):
    """ROM 06's "UNO" frames: U -> O, N kept, face moved right, E drawn."""
    out = lv.copy()
    # O: the U plus its own mirror image (rows 3..28 are the letter)
    u = lv[:, 0:32]
    bright = u == 3
    black = u == 0
    fb = np.zeros_like(bright)
    fk = np.zeros_like(black)
    fb[3:29] = bright[3:29][::-1]
    fk[3:29] = black[3:29][::-1]
    o = u.copy()
    o[3:29][fk[3:29]] = 0
    o[(bright | fb)] = 3
    out[:, 0:32] = o
    # the face (columns 89..114) moves 12 columns right, over plain background
    face = lv[:, 89:115].copy()
    bg = lv[:, 115:128]
    out[:, 66:128] = np.tile(bg, (1, 5))[:, :62]
    out[:, 101:127] = face
    # E: a stem like the N's, three arms
    e = np.zeros(lv.shape, bool)
    e[3:28, 66:76] = True
    e[3:9, 66:93] = True
    e[13:18, 66:89] = True
    e[22:28, 66:93] = True
    out[dilate(e, 1) & ~e] = 0
    out[e] = 3
    # keep the original bottom-row sparkle under the O and N
    out[29:, 0:66] = lv[29:, 0:66]
    return out


def roll_glyphs(lv, y0, y1, text):
    """{char: bitmap} cut from one line of the roll, whose letters are `text`."""
    ink = (lv[y0:y1] > 0).any(axis=0)
    xs, x = [], 0
    while x < lv.shape[1]:
        if ink[x]:
            x0 = x
            while x < lv.shape[1] and ink[x]:
                x += 1
            xs.append((x0, x))
        else:
            x += 1
    text = text.replace(' ', '')
    return {c: lv[y0:y1, a:b].copy() for c, (a, b) in zip(text, xs) if c not in ' '}


def roll_line(font, text, space):
    parts = []
    for c in text:
        parts.append(np.zeros((next(iter(font.values())).shape[0], space), np.uint8) if c == ' ' else font[c])
        parts.append(np.zeros((parts[-1].shape[0], 1), np.uint8))
    return np.hstack(parts[:-1])


def roll_put(lv, y0, bm, x0=None):
    x0 = (lv.shape[1] - bm.shape[1]) // 2 if x0 is None else x0
    lv[y0:y0 + bm.shape[0], x0:x0 + bm.shape[1]] = bm


def credits_roll(lv):
    """BK05 0x08276: the staff-credits roll's Spanish headings in English."""
    out = lv.copy()
    big = {}                                     # the 6-row heading face
    for y0, text in ((0, 'HARDWARE'), (90, 'ELECTROMECANICA'), (141, 'MUSICA')):
        big.update(roll_glyphs(lv, y0, y0 + 6, text))
    small = roll_glyphs(lv, 201, 206, 'ELECTRONICAS S.L.')   # the 5-row address face
    small.update(roll_glyphs(lv, 225, 230, '28100ALCOBENDAS(MADRID)'))
    small['Y'] = np.array([[3, 0, 0, 0, 3], [3, 3, 0, 3, 3], [0, 3, 3, 3, 0],
                           [0, 0, 3, 0, 0], [0, 0, 3, 0, 0]], np.uint8)
    big['G'] = np.array([[3, 3, 3, 3], [3, 0, 0, 0], [3, 0, 0, 0],
                         [3, 0, 3, 3], [3, 0, 0, 3], [3, 3, 3, 3]], np.uint8)
    big['Y'] = np.array([[3, 0, 0, 3], [3, 0, 0, 3], [3, 3, 3, 3],
                         [0, 3, 0, 0], [0, 3, 0, 0], [0, 3, 0, 0]], np.uint8)
    for y0, y1, text in ((90, 96, 'ELECTROMECHANICS'), (114, 122, 'MECHANICAL DESIGN'),
                         (141, 147, 'MUSIC')):
        out[y0:y1] = 0
        roll_put(out, y1 - 6, roll_line(big, text, 4))
    # MADE BY beside the Sleic logo, in the small face as FABRICADO POR was, the
    # pair re-centred.  The logo is everything on rows 176-187 that is not the old
    # text (rows 177-181, left of column 78)
    band = lv[176:188].copy()
    band[1:6, :78] = 0
    lx = np.where((band > 0).any(axis=0))[0]
    logo = band[:, lx[0]:lx[-1] + 1]
    text = roll_line(small, 'MADE BY', 4)
    gap = 77 + 1 - lx[0]                         # the old R overlapped the logo by this
    w = text.shape[1] - gap + logo.shape[1]
    x0 = (lv.shape[1] - w) // 2
    out[176:188] = 0
    out[176:188, x0 + text.shape[1] - gap:x0 + text.shape[1] - gap + logo.shape[1]] |= logo
    out[177:182, x0:x0 + text.shape[1]] |= text
    # "tlf." -> "TEL.", the line re-centred
    tel = roll_line(small, 'TEL.', 3)
    rest = lv[233:238, 27:114]
    line = np.hstack([tel, np.zeros((5, 3), np.uint8), rest])
    out[233:238] = 0
    roll_put(out, 233, line)
    return out


def main():
    ap = argparse.ArgumentParser(description=__doc__.split('\n')[0])
    ap.add_argument('--src', required=True, help='folder of hand-drawn BK05_*.ppm/png')
    ap.add_argument('--out', default=os.path.join(HERE, 'art'))
    a = ap.parse_args()
    os.makedirs(a.out, exist_ok=True)
    rom06 = open(os.path.join(ROMDIR, 'bkcpu06.bin'), 'rb').read()

    # 1. the hand-drawn set, as PNG
    for f in sorted(os.listdir(a.src)):
        if f.startswith('BK05_') and f.endswith(('.ppm', '.png')):
            save(load(os.path.join(a.src, f)), os.path.join(a.out, f.rsplit('.', 1)[0] + '.png'))

    # 2. derived corrections
    for n in ('0184_record_0x11FC6', '0185_record_0x123CC', '0186_record_0x127D2', '0187_record_0x12BD8'):
        p = os.path.join(a.out, 'BK05_%s.png' % n)
        save(respace_one_million(load(p)), p)
    p = os.path.join(a.out, 'BK05_0198_record_0x1483A.png')
    save(split_words(load(p), 66, 5), p)
    save(shadow_style(place(text_fit('Replay', SERIF_BOLD, 124, 29, 0.5), 128, 32, y0=1),
                      ((1, 1), (2, 2), (1, 2), (2, 1))),
         os.path.join(a.out, 'BK05_0211_record_0x17AC8.png'))
    # the attract draws the replay score over rows 19-30, columns 40-119, so the
    # word keeps to the top left, as "Primera" does
    save(outline_style(place(text_box('First', SCRIPT, 84, 21, 0.38), 128, 32, x0=3, y0=0)),
         os.path.join(a.out, 'BK05_0221_record_0x1A304.png'))
    save(outline_style(place(text_box('Second', SCRIPT, 100, 21, 0.38), 128, 32, x0=3, y0=0)),
         os.path.join(a.out, 'BK05_0222_record_0x1A70A.png'))
    save(shadow_style(place(text_fit('Aerial view...', SCRIPT, 126, 18, 0.4), 128, 20),
                      ((1, 1), (1, 0))),
         os.path.join(a.out, 'BK05_0226_record_0x1B76E.png'))
    rom05 = open(os.path.join(ROMDIR, 'bkcpu05.bin'), 'rb').read()
    save(credits_roll(rom_levels(rom05, 0x08276)), os.path.join(a.out, 'BK05_roll_record_0x08276.png'))
    for idx, off in ((81, 0x089AE), (82, 0x08DB4)):
        save(uno_to_one(rom_levels(rom06, off)),
             os.path.join(a.out, 'BK06_%04d_record_0x%05X.png' % (idx, off)))
    print('art written to', a.out)


if __name__ == '__main__':
    main()
