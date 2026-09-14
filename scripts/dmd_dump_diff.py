#!/usr/bin/env python3
"""Compare two split DMD dumps (scripts/dmd_dump_split.py output) per label.

For each scene label, diff the two runs' representative-frame (repr.txt)
hashes within that label only, rather than treating every scene in the dump
as one global unordered set. A global set can call a genuine divergence and
a same-screen-caught-a-frame-apart coincidence the same thing; comparing
within a label at least confirms the frame recurs somewhere under the same
label on the other side, not merely somewhere in the whole run.

This does NOT by itself prove the two runs drew the same screens. Labels are
literal mark strings from the key script, and the same key script drives
both runs, so both sides necessarily end up with the same label vocabulary
regardless of what is actually on screen at each mark -- a label existing on
both sides only shows both runs completed the same scripted navigation, not
that the content matched. Whether a same-label mismatch is real timing drift
(the same screen, caught a frame apart) or a genuine content difference has
to be checked by rendering specific pairs and looking, which this script
does not do for you.

Typical use -- the IO Moon corpus vs its parent set, from sleic-iomoon:

    cd pinmame
    rm -rf /tmp/parent /tmp/nv && mkdir -p /tmp/parent /tmp/nv
    SDL_VIDEODRIVER=dummy SDL_AUDIODRIVER=dummy ./build/sdl3pinmame iomoon \\
      -rompath ./roms -nvram_directory /tmp/nv -nosound \\
      -skip_disclaimer -skip_gameinfo -skip_gamewarnings -nothrottle -ftr 400000 \\
      -dmd_dump_dir /tmp/parent \\
      -key_script ../sleic-iomoon/scripts/keyscripts/iomoon-en.keys
    cd ../sleic-iomoon
    cp scripts/keyscripts/iomoon-en.keys.marks /tmp/parent/iomoon.marks
    python3 scripts/dmd_dump_split.py /tmp/parent/iomoon.txt --out /tmp/parent \\
            --marks /tmp/parent/iomoon.marks --rom ../pinmame/roms/iomoon/v1_3_01.bin
    python3 scripts/dmd_dump_diff.py dmd/en /tmp/parent
"""
import argparse
import csv
import hashlib
import os
from collections import Counter, defaultdict


def sha(path):
    return hashlib.sha256(open(path, 'rb').read()).hexdigest()


def load(out_dir):
    """label -> [(repr.txt sha256, scene id), ...] for one split-dump directory.

    dmd_dump_split.py writes repr.txt once per distinct content: a scene
    whose representative frame duplicates an earlier one carries that
    scene's id in its own `repr_id` column instead of a second copy of the
    file. Resolving through `repr_id` (via `dir_by_id`) rather than reading
    `r['dir']` directly means this still finds the right bytes for a
    duplicate scene, which has no repr.txt of its own.
    """
    rows = list(csv.DictReader(open(os.path.join(out_dir, 'screens.csv'))))
    dir_by_id = {r['id']: r['dir'] for r in rows}
    by_label = defaultdict(list)
    for r in rows:
        repr_dir = dir_by_id[r.get('repr_id') or r['id']]
        p = os.path.join(out_dir, 'screens', repr_dir, 'repr.txt')
        by_label[r['label']].append((sha(p), r['id']))
    return by_label, len(rows)


def main():
    ap = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    ap.add_argument('a_dir', help='a split-dump output directory (--out of dmd_dump_split.py)')
    ap.add_argument('b_dir', help='the other split-dump output directory to compare against')
    args = ap.parse_args()

    a, a_total = load(args.a_dir)
    b, b_total = load(args.b_dir)

    only_a_labels = sorted(l for l in a if l not in b)
    only_b_labels = sorted(l for l in b if l not in a)

    matched = a_only = b_only = 0
    a_only_by_label, b_only_by_label = Counter(), Counter()
    for label in sorted(set(a) | set(b)):
        a_hashes = {h for h, _ in a.get(label, [])}
        b_hashes = {h for h, _ in b.get(label, [])}
        matched += len(a_hashes & b_hashes)
        a_only += len(a_hashes - b_hashes)
        b_only += len(b_hashes - a_hashes)
        a_only_by_label[label] = len(a_hashes - b_hashes)
        b_only_by_label[label] = len(b_hashes - a_hashes)

    print('%s: %d scenes, %d labels' % (args.a_dir, a_total, len(a)))
    print('%s: %d scenes, %d labels' % (args.b_dir, b_total, len(b)))
    print()
    print('labels only in %s:' % args.a_dir, only_a_labels or '(none)')
    print('labels only in %s:' % args.b_dir, only_b_labels or '(none)')
    print()
    print('per-label representative-frame hashes:')
    print('  matched (same content under the same label, either side):', matched)
    print('  only in %s (never recurs under that label in %s):' % (args.a_dir, args.b_dir), a_only)
    print('  only in %s (never recurs under that label in %s):' % (args.b_dir, args.a_dir), b_only)
    print()
    print('only-in-%s by label:' % args.a_dir, {k: v for k, v in a_only_by_label.items() if v})
    print('only-in-%s by label:' % args.b_dir, {k: v for k, v in b_only_by_label.items() if v})


if __name__ == '__main__':
    main()
