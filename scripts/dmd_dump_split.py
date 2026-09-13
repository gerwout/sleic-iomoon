#!/usr/bin/env python3
"""Split a PinMAME DMD frame dump into named screens.

The dump is the format the Serum and Pin2DMD colorization tools read and PinMAME's
core_dmd_capture_frame writes: per frame a "0x%08x" millisecond timestamp, then one
line per DMD row of one hex nibble per pixel, then a blank line.  Consecutive
identical frames are already dropped by the emulator.

A scene cuts where more than a quarter of the pixels change between consecutive
frames (--threshold 0.25).  No single threshold is clean on a captured game: the
attract scroll and a bumper-hit graphic never exceed a 0.19 frame-to-frame diff,
so 0.25 keeps both as one scene each and still cuts cleanly at a page change
(attract to credit measures 0.43-0.51) -- but Io Moon's own full-frame dithered
background, playing behind the static "ball start" text, produces diffs of
0.2-0.5 between its own frames, the same range as a genuine new screen, and is
over-split at every threshold from 0.10 to 0.40.  0.10 additionally shatters the
two clean cases above; 0.25 is the least-bad value measured, not a value that
separates "same screen" from "new screen" in general.

    python3 scripts/dmd_dump_split.py dmd/en/iomoont.txt --out dmd/en
"""
import argparse
import csv
import os
import sys


def parse_dump(path):
    """[(ms, [row_string, ...]), ...] in file order."""
    frames, ms, rows = [], None, []
    for line in open(path):
        line = line.rstrip('\n')
        if line.startswith('0x'):
            if ms is not None and rows:
                frames.append((ms, rows))
            ms, rows = int(line, 16), []
        elif line.strip():
            rows.append(line)
    if ms is not None and rows:
        frames.append((ms, rows))
    return frames


def frame_distance(a, b):
    """Fraction of pixels that differ between two frames."""
    if len(a) != len(b):
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
    ap.add_argument('dump')
    ap.add_argument('--out', required=True)
    ap.add_argument('--marks', default=None)
    ap.add_argument('--threshold', type=float, default=0.25)
    args = ap.parse_args()

    frames = parse_dump(args.dump)
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
