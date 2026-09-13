#!/usr/bin/env python3
"""Split a PinMAME DMD frame dump into named screens.

The dump is the format the Serum and Pin2DMD colorization tools read and PinMAME's
core_dmd_capture_frame writes: per frame a "0x%08x" millisecond timestamp, then one
line per DMD row of one hex nibble per pixel, then a blank line.  Consecutive
identical frames are already dropped by the emulator.

A scene cuts on any of three independent signals: a mark boundary (a key
script's marks are exact, so a new one always starts a new scene, regardless of
what the pixels do), the all-pixel diff exceeding --threshold (default 0.25), or
the lit-union diff exceeding --lit-threshold (default 0.8).  No single metric is
clean, which is why there are two plus the marks rather than one tuned value.

The all-pixel diff (differing pixels over all 4096) is the metric a full-frame
animation dominates: the attract scroll never exceeds 0.065 and a bumper-hit
graphic never exceeds 0.19 frame to frame, so 0.25 keeps both as one scene each
and still cuts cleanly at a page change (attract to credit measures 0.43-0.51).
But it is the wrong metric for this machine's dominant screen class: a service
record or a fault screen lights only 400-900 of 4096 pixels, so a *complete*
change of text can measure well under 0.25 of all pixels -- measured on the boot
dump, "WAITING FOR / 8 BITS CPU" changing to "SETTING / DEFAUL" (nothing in
common) is only 0.2097 all-pixel, comfortably merged by threshold alone.

The lit-union diff (differing pixels over pixels lit in *either* frame; 0 if
neither lights any) catches that case -- the same pair measures 0.945 lit-union,
decisively over 0.8 -- but is the wrong metric for the full-frame animations
the first metric already handles cleanly, and neither metric is clean on Io
Moon's own full-frame dithered background (playing behind the static "ball
start" text), which produces diffs in the same range as a genuine new screen on
both measures and is over-split by both.  Cutting on either exceeding its own
threshold -- so more cuts than either metric alone, and more than marks alone --
errs toward over-splitting on purpose: a human merges scenes afterward, but a
missed cut loses a screen from the corpus with no trace at all.  This still does
not add up to a value or a pair of values that separates "same screen" from "new
screen" in general; it only shrinks the case where both metrics miss and no mark
covers it.

    python3 scripts/dmd_dump_split.py dmd/en/iomoont.txt --out dmd/en
"""
import argparse
import csv
import os
import sys

import iomoon_strings


def parse_dump(path):
    """[(ms, [row_string, ...]), ...] in file order.

    Geometry (row count, and each row's width) is taken from the first frame,
    not hard-coded, so the same splitter works on another machine's dump.  A
    later frame whose geometry differs is a torn write -- PinMAME's
    core_dmd_capture_frame appends each frame open-write-close, so a run
    killed mid-write leaves a partial row, not a partial timestamp -- and is
    dropped rather than kept with the wrong shape, since a scene's repr.txt is
    meant to be a real frame at the machine's own geometry.  A warning naming
    the timestamp and what differed goes to stderr either way: a torn frame is
    a capture defect, not something to pass on in silence.
    """
    frames, ms, rows = [], None, []
    shape = None

    def keep(ms, rows):
        nonlocal shape
        if shape is None:
            shape = [len(r) for r in rows]
            frames.append((ms, rows))
            return
        if len(rows) != len(shape):
            print('%s: frame 0x%08x has %d rows, expected %d -- dropped'
                  % (path, ms, len(rows), len(shape)), file=sys.stderr)
            return
        for i, (r, want) in enumerate(zip(rows, shape)):
            if len(r) != want:
                print('%s: frame 0x%08x row %d has %d characters, expected %d -- dropped'
                      % (path, ms, i, len(r), want), file=sys.stderr)
                return
        frames.append((ms, rows))

    for line in open(path):
        line = line.rstrip('\n')
        if line.startswith('0x'):
            if ms is not None and rows:
                keep(ms, rows)
            ms, rows = int(line, 16), []
        elif line.strip():
            rows.append(line)
    if ms is not None and rows:
        keep(ms, rows)
    return frames


def frame_distance(a, b):
    """Fraction of pixels that differ between two frames.

    Any geometry mismatch -- row count, or one row's width -- is treated the
    same as every pixel differing, so a malformed frame that reaches this far
    (parse_dump drops the ones it catches, but a caller can build frames by
    hand) cannot register as "no change".
    """
    if len(a) != len(b) or any(len(ra) != len(rb) for ra, rb in zip(a, b)):
        return 1.0
    diff = total = 0
    for ra, rb in zip(a, b):
        total += len(ra)
        diff += sum(1 for x, y in zip(ra, rb) if x != y)
    return diff / total if total else 0.0


def lit_union_distance(a, b):
    """Differing pixels over pixels lit ('0' is unlit) in either frame; 0 if neither lights any.

    A sparse text screen -- a service record, a fault screen, a high-score page
    -- lights a few hundred of the panel's 4096 pixels, so a complete change of
    text can measure well under frame_distance's own threshold of all pixels.
    This is the metric that catches that case; the same geometry-mismatch
    convention as frame_distance applies.
    """
    if len(a) != len(b) or any(len(ra) != len(rb) for ra, rb in zip(a, b)):
        return 1.0
    union = diff = 0
    for ra, rb in zip(a, b):
        for x, y in zip(ra, rb):
            if x == '0' and y == '0':
                continue
            union += 1
            if x != y:
                diff += 1
    return diff / union if union else 0.0


def load_marks(path):
    """[(frame, ms, label), ...] from a key script's .marks sidecar."""
    out = []
    if not os.path.exists(path):
        return out
    for line in open(path):
        parts = line.split(None, 2)
        if len(parts) == 3:
            out.append((int(parts[0]), int(parts[1]), parts[2].strip()))
    return out


def label_for(ms, marks):
    """The label of the last mark at or before this timestamp."""
    label = 'unlabelled'
    for _frame, mark_ms, text in marks:
        if mark_ms <= ms:
            label = text
        else:
            break
    return label


def split_scenes(frames, threshold=0.25, marks=None, lit_threshold=0.8):
    """Group frames into scenes, cutting at a mark boundary or either diff metric.

    `marks` (a key script's .marks sidecar, already loaded by load_marks) cuts
    unconditionally at the frame where label_for's result changes -- a mark is
    exact, so a new one always starts a new scene regardless of what the
    pixels do.  `marks=None` (or empty) cuts on the two diff metrics alone,
    unchanged from a dump with no marks file.
    """
    marks = marks or []
    scenes = []
    prev_label = None
    for i, (ms, rows) in enumerate(frames):
        label = label_for(ms, marks)
        cut = (i == 0 or label != prev_label
               or frame_distance(frames[i - 1][1], rows) > threshold
               or lit_union_distance(frames[i - 1][1], rows) > lit_threshold)
        if cut:
            scenes.append([])
        scenes[-1].append((ms, rows))
        prev_label = label
    return scenes


def decode_text(rows, glyphs, cell_w=8):
    """The on-screen text in a decoded frame's rows, read by exact bitmap match.

    `glyphs` is a glyph code -> row-bit-string table from
    iomoon_strings.glyph_bitmaps() (all one height; degenerate/uniform
    entries, including the space glyph, are already dropped there).  Every
    (x, y) window of that height is tried; a match emits the glyph's
    character and advances x by the full cell width, a miss advances by one
    pixel, so text is found at any x rather than only multiples of the cell
    width.  Since the space glyph is not in `glyphs`, a run of misses
    between two matches on the same line becomes exactly one space, rather
    than the naive "WAITINGFOR" (no gap) or a space per missed column.
    Lines are read top to bottom and joined with ' / '.
    """
    if not rows or not glyphs:
        return ''
    heights = {len(bits) for bits in glyphs.values()}
    if len(heights) != 1:
        return ''
    h = heights.pop()
    width = len(rows[0])
    if width < cell_w or len(rows) < h:
        return ''
    bits_to_code = {tuple(bits): code for code, bits in glyphs.items()}
    binrows = [''.join('1' if c != '0' else '0' for c in row) for row in rows]

    lines = []
    for y in range(len(rows) - h + 1):
        window = binrows[y:y + h]
        chars, x, gap = [], 0, False
        while x <= width - cell_w:
            code = bits_to_code.get(tuple(r[x:x + cell_w] for r in window))
            if code is not None:
                if chars and gap:
                    chars.append(' ')
                chars.append(iomoon_strings.GLYPHS.get(code, '?'))
                gap = False
                x += cell_w
            else:
                if chars:
                    gap = True
                x += 1
        if chars:
            lines.append(''.join(chars))
    return ' / '.join(lines)


def slug(text):
    keep = [c.lower() if c.isalnum() else '-' for c in text]
    s = ''.join(keep)
    while '--' in s:
        s = s.replace('--', '-')
    return s.strip('-')[:48] or 'screen'


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('dump', help='the frame dump, in the colorizer .txt format')
    ap.add_argument('--out', required=True, help='directory to write screens/ and screens.csv into')
    ap.add_argument('--marks', default=None,
                     help='the key script\'s .marks sidecar (default: <dump without extension>.marks)')
    ap.add_argument('--threshold', type=float, default=0.25,
                     help='all-pixel diff that starts a new scene (default 0.25)')
    ap.add_argument('--lit-threshold', type=float, default=0.8,
                     help='lit-union diff that starts a new scene (default 0.8)')
    ap.add_argument('--rom', default=None,
                     help='the 80188 ROM1 image (e.g. roms/iomoon/v1_3_01.bin) to read the DMD '
                          'font from for the text column; omitted, text is written empty')
    args = ap.parse_args()

    glyphs = {}
    if args.rom:
        try:
            glyphs = iomoon_strings.glyph_bitmaps(open(args.rom, 'rb').read())
        except OSError as e:
            print('%s: %s -- text column will be empty' % (args.rom, e), file=sys.stderr)

    try:
        frames = parse_dump(args.dump)
    except FileNotFoundError:
        sys.exit('no such file: %s' % args.dump)
    except ValueError as e:
        sys.exit('%s: malformed dump (%s)' % (args.dump, e))
    if not frames:
        sys.exit('no frames in %s' % args.dump)
    marks = load_marks(args.marks or (os.path.splitext(args.dump)[0] + '.marks'))
    scenes = split_scenes(frames, args.threshold, marks, args.lit_threshold)

    rows_out = []
    for n, scene in enumerate(scenes, 1):
        label = label_for(scene[0][0], marks)
        name = '%04d-%s' % (n, slug(label))
        d = os.path.join(args.out, 'screens', name)
        os.makedirs(d, exist_ok=True)
        for ms, rows in scene:
            with open(os.path.join(d, 'frame-%08d.txt' % ms), 'w') as f:
                f.write('\n'.join(rows) + '\n')
        # the representative is the scene's last frame: an animation has settled by then
        with open(os.path.join(d, 'repr.txt'), 'w') as f:
            f.write('\n'.join(scene[-1][1]) + '\n')
        rows_out.append({'id': n, 'label': label, 'dir': name,
                         'first_ms': scene[0][0], 'last_ms': scene[-1][0],
                         'frames': len(scene),
                         'text': decode_text(scene[-1][1], glyphs)})

    with open(os.path.join(args.out, 'screens.csv'), 'w', newline='') as f:
        w = csv.DictWriter(f, fieldnames=['id', 'label', 'dir', 'first_ms', 'last_ms', 'frames', 'text'])
        w.writeheader()
        w.writerows(rows_out)
    print('%d frames -> %d scenes' % (len(frames), len(scenes)))


if __name__ == '__main__':
    main()
