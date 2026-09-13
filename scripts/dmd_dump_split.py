#!/usr/bin/env python3
"""Split a PinMAME DMD frame dump into named screens.

The dump is the format the Serum and Pin2DMD colorization tools read and PinMAME's
core_dmd_capture_frame writes: per frame a "0x%08x" millisecond timestamp, then one
line per DMD row of one hex nibble per pixel, then a blank line.  Consecutive
identical frames are already dropped by the emulator.

A scene cuts where more than a quarter of the pixels change between consecutive
frames (--threshold 0.25).  No single threshold is clean on a captured game: the
attract scroll never exceeds a 0.065 frame-to-frame diff and a bumper-hit graphic
never exceeds 0.19, so 0.25 keeps both as one scene each and still cuts cleanly at
a page change (attract to credit measures 0.43-0.51) -- but Io Moon's own
full-frame dithered background, playing behind the static "ball start" text,
produces diffs of 0.2-0.5 between its own frames, the same range as a genuine new
screen, and is over-split at every threshold from 0.10 to 0.40.  0.10 additionally
shatters the bumper-hit case alone (57 of its 86 own frame-to-frame diffs land
above 0.10, against 2 above 0.25); 0.25 is the least-bad value measured, not a
value that separates "same screen" from "new screen" in general.

    python3 scripts/dmd_dump_split.py dmd/en/iomoont.txt --out dmd/en
"""
import argparse
import csv
import os
import sys


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


def split_scenes(frames, threshold=0.25):
    """Group frames into scenes, cutting where the picture changes wholesale."""
    scenes = []
    for i, (ms, rows) in enumerate(frames):
        if i == 0 or frame_distance(frames[i - 1][1], rows) > threshold:
            scenes.append([])
        scenes[-1].append((ms, rows))
    return scenes


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
                     help='fraction of pixels that must change to start a new scene (default 0.25)')
    args = ap.parse_args()

    try:
        frames = parse_dump(args.dump)
    except FileNotFoundError:
        sys.exit('no such file: %s' % args.dump)
    except ValueError as e:
        sys.exit('%s: malformed dump (%s)' % (args.dump, e))
    if not frames:
        sys.exit('no frames in %s' % args.dump)
    marks = load_marks(args.marks or (os.path.splitext(args.dump)[0] + '.marks'))
    scenes = split_scenes(frames, args.threshold)

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
                         'frames': len(scene)})

    with open(os.path.join(args.out, 'screens.csv'), 'w', newline='') as f:
        w = csv.DictWriter(f, fieldnames=['id', 'label', 'dir', 'first_ms', 'last_ms', 'frames'])
        w.writeheader()
        w.writerows(rows_out)
    print('%d frames -> %d scenes' % (len(frames), len(scenes)))


if __name__ == '__main__':
    main()
