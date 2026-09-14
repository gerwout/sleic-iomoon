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
A tighter threshold like 0.10 is worse, not just more cautious: the bumper-hit
graphic's own 0.19 frame-to-frame diff alone would already cross it, shattering
that one clean case into many scenes for no new information; 0.25 is the
least-bad value measured for this metric, not one that separates "same screen"
from "new screen" in general.

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

    python3 scripts/dmd_dump_split.py dmd/en/iomoont.txt.gz --out dmd/en
"""
import argparse
import csv
import gzip
import os
import sys
from collections import Counter

import iomoon_strings


def parse_dump(path):
    """[(ms, [row_string, ...]), ...] in file order.

    Geometry (row count, and each row's width) is taken from the modal shape
    of the first few frames, not hard-coded, so the same splitter works on
    another machine's dump -- and so a torn *first* frame (the same failure
    mode as any other torn frame, just at offset 0) does not lock in the
    wrong shape and drop every good frame after it. A later frame whose
    geometry differs from the settled one is a torn write -- PinMAME's
    core_dmd_capture_frame appends each frame open-write-close, so a run
    killed mid-write leaves a partial row, not a partial timestamp -- and is
    dropped rather than kept with the wrong shape, since a scene's repr.txt is
    meant to be a real frame at the machine's own geometry.  A warning naming
    the timestamp and what differed goes to stderr either way: a torn frame is
    a capture defect, not something to pass on in silence.
    """
    PROBE = 5
    frames, ms, rows = [], None, []
    shape = None
    pending = []

    def keep(ms, rows):
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

    def settle(pending):
        nonlocal shape
        counts = Counter(tuple(len(r) for r in prows) for _, prows in pending)
        shape = list(counts.most_common(1)[0][0])
        for pms, prows in pending:
            keep(pms, prows)

    def see(ms, rows):
        nonlocal shape
        if shape is not None:
            keep(ms, rows)
            return
        pending.append((ms, rows))
        if len(pending) >= PROBE:
            settle(pending)

    opener = gzip.open if path.endswith('.gz') else open

    for line in opener(path, 'rt'):
        line = line.rstrip('\n')
        if line.startswith('0x'):
            if ms is not None and rows:
                see(ms, rows)
            ms, rows = int(line, 16), []
        elif line.strip():
            rows.append(line)
    if ms is not None and rows:
        see(ms, rows)
    if shape is None and pending:
        settle(pending)
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


def _scan_face(rows, bits_to_label, height, cell_w, binarize=True, min_glyphs=2):
    """[(y, text), ...] for one glyph face, read by exact bitmap match.

    `bits_to_label` maps a tuple of `height` row strings (each `cell_w` wide)
    to the string to emit -- usually one character, but the score face's
    digit+period glyphs stand for two.  Every (x, y) window of that height is
    tried; a match emits its label and advances x by the full cell width, a
    miss advances by one pixel, so text is found at any x rather than only
    multiples of the cell width.

    `binarize` collapses the frame's four pixel levels to lit/unlit before
    matching -- correct for the single-bitplane h=9 and h=12 faces, whose own
    keys are '0'/'1' bit strings, but wrong for the shaded h=23 score face:
    its glyphs mix level 1 (interior) and level 3 (outline) in the same cell,
    so collapsing the frame would compare a two-level key against a
    one-level frame and never match. Pass binarize=False there and match the
    frame's own '0'-'3' characters directly against
    iomoon_strings.score_glyph_bitmaps()'s own level strings.

    Binarizing is itself two different rules, tried in order, not one:
    "nonzero is lit" (the original rule, correct for a service-menu screen,
    whose own h=9/h=12 text renders at a flat level 1 throughout -- rendering
    `dmd/en/screens/5383-svc-1/repr.txt` finds no level-3 pixel anywhere on
    it) and "only level 3 is lit" (needed for a screen like the high-score
    wheel-walk, where the same faces render at level 3 but the panel's own
    background dither shows through a glyph's *blank* margin at level 1 --
    "nonzero is lit" then requires that dither to also be exactly 0, which
    it never is, so an exact match finds the word nowhere even though it
    renders cleanly). Neither rule is a strict refinement of the other --
    "nonzero" is the looser requirement on lit pixels but the stricter one
    on blank pixels, and vice versa for "only 3" -- so a window is tried
    against "nonzero" first and only falls through to "only 3" on a miss:
    this can only ever recover a match the first rule missed, never
    override one it already found, which is why re-splitting the whole
    corpus with this added showed zero cells lost, not just zero regressed.

    A run of misses between two matches on the same line becomes exactly
    one space (rather than the naive "WAITINGFOR" with no gap, or a space
    per missed column) -- this relies on the space glyph itself never being
    in `bits_to_label` (iomoon_strings.glyph_bitmaps drops it, being a
    uniform, all-zero bitmap that would match any blank window).

    A line of exactly one matched glyph is dropped, not reported: a glyph
    sparse enough to be mostly blank (the period is 7 blank rows and 2 lit
    ones) can exact-match a fragment of a different, taller glyph sitting
    over enough blank canvas -- e.g. the top half of a colon a few rows
    above its own baseline reproduces the period's bitmap exactly. Such a
    fragment is never adjacent to a second matched glyph on its own line,
    while every genuine use of a sparse glyph here (a decimal point inside
    a run of digits, a colon between two words) is. Requiring at least two
    keeps every real line and drops exactly this class of noise.

    `min_glyphs` overrides that "at least two" floor -- pass 1 for a face
    whose glyphs are dense enough that a lone match carries negligible
    false-positive risk (the in-play score digit table: 16x18 pixels of
    real content per glyph, nothing like the period's 2-of-162-pixel
    bitmap this rule was written to guard against), since overlapping
    consecutive digits in a real score already leaves only one glyph
    surviving intact in most captured frames (iomoon_strings.
    SCORE_DIGIT_BASE's own comment) -- requiring two there would silently
    discard almost every real recovery.
    """
    if not rows or not bits_to_label or len(rows) < height:
        return []
    width = len(rows[0])
    if width < cell_w:
        return []
    if binarize:
        cmp_variants = [
            [''.join('1' if c != '0' else '0' for c in row) for row in rows],
            [''.join('1' if c == '3' else '0' for c in row) for row in rows],
        ]
    else:
        cmp_variants = [rows]

    lines = []
    for y in range(len(rows) - height + 1):
        windows = [cmp[y:y + height] for cmp in cmp_variants]
        chars, x, gap = [], 0, False
        while x <= width - cell_w:
            label = None
            for window in windows:
                label = bits_to_label.get(tuple(r[x:x + cell_w] for r in window))
                if label is not None:
                    break
            if label is not None:
                if chars and gap:
                    chars.append(' ')
                chars.append(label)
                gap = False
                x += cell_w
            else:
                if chars:
                    gap = True
                x += 1
        if len(chars) >= min_glyphs:
            lines.append((y, ''.join(chars)))
    return lines


def _scan_words(rows, messages, max_blank_lit_fraction=0.2):
    """[(y, text), ...] for a table of whole-phrase bitmaps, matched on
    their *lit* pixels only -- iomoon_strings.hud_message_bitmaps()'s own
    entries (BALL, PLAYER, the two-line INSERT COIN, ...), not
    per-character glyphs.

    Unlike _scan_face, entries here vary in both height and width (each is
    a complete rendered word), so there is no single cell size to advance
    by on a match -- every (label, height, width, lit_rows) entry is tried
    independently at every (x, y), and a match advances x by *that*
    label's own width rather than a shared constant.

    This is a masked match, not an exact one, and deliberately so: an
    exact match (blank template pixels required to be blank on screen,
    same as every other face here) finds these words nowhere in the
    corpus even though they are plainly on screen, because the stored
    word's blank margins fall over the panel's own dithered background on
    a real frame -- confirmed by rendering a frame that shows PLAYER and
    BALL directly while an exact matcher finds neither anywhere in either
    committed corpus. `lit_rows` (the '0'/'1' plane-0 bitmap
    hud_message_bitmaps() already returns) says only which pixels the
    stored word actually lights; every other pixel in the cell is,
    *within limits* (see below), a don't-care. To keep this looser rule
    from over-matching against a dimmer dither level rather than the word
    itself, a lit pixel must be at **full brightness** ('3') in the frame,
    not merely nonzero -- `rows` is therefore the frame's own raw '0'-'3'
    level rows, not binarized.

    Ignoring blank pixels entirely over-matches a different way: a large,
    solid, near-uniformly-bright graphic (a bonus-multiplier blob, an
    animation frame) satisfies almost any sparse lit-pixel mask trivially,
    since nearly every candidate pixel already reads level 3 regardless of
    the word's own shape -- caught on a real scene (`score-recover-hits`,
    a large bright graphic overlapping a score display), where a
    lit-pixels-only match fired for both `BALL` and `BOLA` at three
    positions with no real word anywhere near them, alongside a fourth,
    genuine `BALL` match elsewhere on the same frame. Measured across
    known-true and known-false matches, the discriminator is the
    *fraction* of the template's own blank pixels that read level 3 in the
    frame: 0-3% for confirmed real words (`PLAYER`/`BALL` on a genuine
    HUD row), 73-77% for the false-positive graphic -- not a close call.
    `max_blank_lit_fraction` (default 0.2, comfortably below every measured
    false positive and above every measured true one) rejects a candidate
    whose blank area is mostly full-brightness anyway, without reinstating
    the blank-must-be-blank exact match this function exists to avoid.

    A whole word's worth of *required* lit pixels (tens to several dozen,
    all at one specific brightness) plus the blank-fraction check above is
    still specific enough that no minimum-match-count filter is applied,
    unlike _scan_face's sparse-glyph guard.
    """
    if not rows or not messages:
        return []
    H, W = len(rows), len(rows[0])
    hits = []
    for label, height, width, lit_rows in messages:
        if height > H or width > W:
            continue
        lit = [(r, c) for r in range(height) for c in range(width) if lit_rows[r][c] == '1']
        blank = [(r, c) for r in range(height) for c in range(width) if lit_rows[r][c] == '0']
        if not lit or not blank:
            continue
        blank_limit = int(len(blank) * max_blank_lit_fraction)
        y = 0
        while y <= H - height:
            x = 0
            while x <= W - width:
                if (all(rows[y + r][x + c] == '3' for r, c in lit)
                        and sum(1 for r, c in blank if rows[y + r][x + c] == '3') <= blank_limit):
                    hits.append((y, x, label))
                    x += width
                else:
                    x += 1
            y += 1
    # merge same-row hits left to right, the same convention _scan_face's
    # own lines use, so decode_text's final sort-and-join treats a word
    # table's output the same way as every other face's.
    hits.sort()
    lines = []
    for y, x, label in hits:
        if lines and lines[-1][0] == y:
            lines[-1] = (y, lines[-1][1] + ' ' + label)
        else:
            lines.append((y, label))
    return lines


def decode_text(rows, glyphs, glyphs12=None, score_glyphs=None, small_digits=None,
                 hud_messages=None, player_digits=None, score_digits=None,
                 cell_w=8, score_cell_w=16, player_digit_cell_w=8, score_digit_cell_w=16):
    """The on-screen text in a decoded frame's rows, read by exact bitmap match.

    `glyphs` is the h=9 glyph code -> row-bit-string table from
    iomoon_strings.glyph_bitmaps(); `glyphs12`, if given, is the same but for
    the large h=12 face (iomoon_strings.glyph_bitmaps(data, height=12,
    code_offset=75)); `score_glyphs` and `small_digits`, if given, are the
    two digit faces' label -> row-level-string tables from
    iomoon_strings.score_glyph_bitmaps() (the large, 16x23 face at its
    default parameters, and the small, 8x12 one respectively -- see that
    function for both). `hud_messages`, if given, is
    iomoon_strings.hud_message_bitmaps()'s own label -> (height, width,
    rows) table for the in-play PLAYER/BALL HUD words (both languages);
    `player_digits`, if given, is iomoon_strings.player_number_bitmaps()'s
    '0'-'9' table for the digit that follows PLAYER/PLAYERS; `score_digits`,
    if given, is iomoon_strings.score_digit_bitmaps()'s own '0'/'2'-'9'/'.'
    table for the in-play score (see that function's own comment for why
    '1' is absent, and for the overlap that limits how many digits of a
    real multi-digit score this table recovers).

    Every face is scanned independently over the whole frame and their
    lines merged top to bottom, then joined with ' / '. The two
    iomoon_strings.score_glyph_bitmaps() faces and score_digits match on raw
    pixel levels ('0'-'3', not binarized -- see _scan_face); glyphs,
    glyphs12 and player_digits match on lit/unlit only; hud_messages
    matches on its own lit pixels against full brightness specifically (not
    merely nonzero) and does not require its blank margins to be blank on
    screen -- see _scan_words for why an exact match, correct for every
    other face here, finds these particular words nowhere in a real
    capture. See _scan_face and _scan_words for the matching, space and
    noise rules each uses.

    The h=12 face has one real ambiguity, not a bug: code 0 ('0') and code
    0x1A ('O') render the identical bitmap, so inverting code -> bitmap into
    the bitmap -> label map this function needs necessarily drops one label
    for that one shape.  '0' wins -- GLYPHS iterates digits before letters,
    and this face's own pinned use (the attract high-score amount) is
    numeric -- so a screen that genuinely shows a large-face 'O' decodes as
    '0' instead; no pixel-level test can tell the two apart in this face.
    """
    lines = []
    # (table, cell_w, binarize, label_is_key, min_glyphs) -- `binarize`
    # picks the matching convention (lit/unlit vs raw '0'-'3' levels, see
    # _scan_face); `label_is_key` is independent of it: the two score faces
    # and the two new digit faces already key their table by the label to
    # emit ('0'-'9', '0.'-'9.', ':', '.'), while glyphs/glyphs12/player_digits
    # key by glyph code or digit and need iomoon_strings.GLYPHS to turn that
    # into a character -- player_digits is the one face where these two
    # choices disagree with each other (binarized like glyphs, but
    # key-is-label like the score faces), which is exactly why they are two
    # separate flags here and not the one `is_score` flag this used to be.
    faces = [(glyphs, cell_w, True, False, 2), (glyphs12, cell_w, True, False, 2),
             (score_glyphs, score_cell_w, False, True, 2), (small_digits, cell_w, False, True, 2),
             (player_digits, player_digit_cell_w, True, True, 2),
             (score_digits, score_digit_cell_w, False, True, 1)]
    for table, glyph_cell_w, binarize, label_is_key, min_glyphs in faces:
        if not table:
            continue
        heights = {len(bits) for bits in table.values()}
        if len(heights) != 1:
            continue
        bits_to_label = {}
        for key, bits in table.items():
            bits_to_label.setdefault(tuple(bits), key if label_is_key else iomoon_strings.GLYPHS.get(key, '?'))
        lines += _scan_face(rows, bits_to_label, heights.pop(), glyph_cell_w,
                             binarize=binarize, min_glyphs=min_glyphs)
    if hud_messages:
        # raw levels, not binarized -- _scan_words matches lit pixels
        # against full brightness ('3') specifically, see its own comment.
        messages = [(label, h, w, tuple(bits)) for label, (h, w, bits) in hud_messages.items()]
        lines += _scan_words(rows, messages)
    lines.sort(key=lambda yt: yt[0])
    return ' / '.join(text for _, text in lines)


def slug(text):
    keep = [c.lower() if c.isalnum() else '-' for c in text]
    s = ''.join(keep)
    while '--' in s:
        s = s.replace('--', '-')
    return s.strip('-')[:48] or 'screen'


def _normalize_field(s):
    """Case- and whitespace-fold one decoded field for coverage comparison.

    Collapses internal blank runs to one space and drops leading/trailing
    ones, because _scan_face's own space rule (a run of misses between two
    matches becomes exactly one space; a leading gap before the first
    matched glyph is never captured at all) means a corpus-decoded field
    never reproduces a ROM pool string's original spacing byte for byte
    (e.g. the pool's own '  OF  10 CRED:' decodes on screen as 'OF 10
    CRED:').
    """
    return ' '.join(s.split()).upper()


def coverage_report(rom_path, csv_paths):
    """[(tier, source, string, found), ...] -- every string iomoon_strings.py
    can currently name, checked against every given screens.csv's `text`
    column, most to least certain about what ROM data a string actually is:

      tier 1 -- contact_table()/menu_records(): a string reached through a
        resolved pointer (F14 the 38-record menu tree, F16 the switch/
        cabinet names), both languages.
      tier 2 -- ENGLISH_POOL/SPANISH_POOL: the two windows iomoon_strings.py
        declares. English is now the verified full envelope of tier 1's own
        two English tables (so it adds nothing tier 1 didn't already reach);
        Spanish stays a narrower, verified-clean sub-window -- tier 1's own
        Spanish tables already resolve strings outside it.
      tier 3 -- every other length-prefixed string a flat byte sweep finds
        in the ROM's whole string area (0x17a8-0x2eaa -- 18 bytes short of
        0x2ebc, which picks up one spurious string, '0020000000000000' at
        0x2eab: the six bytes right before it, 20 00 10 00 00 02 at 0x2ea9,
        are a second image header in the same format as the one at
        0x24EA4 (F20), not padding): fault/boot messages, the coil-group
        and fuse names, the per-country CREDITS-page denominations -- real
        ROM strings with no pointer table pinned down yet, reported as
        exactly that, not folded into a coverage number against tiers 1-2
        alone.

    A string counts as present only if it equals -- after `_normalize_field`
    on both sides -- one whole decoded field (one ' / '-delimited segment of
    a row's `text`), never a substring or a single word carved out of a
    longer field: a substring test counts the pool's own short or common
    entries ('M', 'YES', 'SETTING') as covered by nearly any text, and even
    a whole-word test would wrongly credit the ROM's distinct 'SETTING'
    string from a field that is really the unrelated 'SETTING COUNTRY'.
    Each distinct string value is reported once, at its first (lowest-
    offset/earliest) source.
    """
    data = open(rom_path, 'rb').read()
    seen = set()
    for p in csv_paths:
        for row in csv.DictReader(open(p)):
            for seg in (row.get('text') or '').split(' / '):
                seg = _normalize_field(seg)
                if seg:
                    seen.add(seg)

    # Dedup key is the *normalized* form, not the raw bytes: the same string
    # can sit at two pointer-reached offsets one byte apart (a far pointer
    # that includes or skips a leading space a neighbouring one does not),
    # which would otherwise report the identical word twice under two tiers.
    out = []
    known = set()

    for code, (cnum, en, es) in sorted(iomoon_strings.contact_table(data).items()):
        for lang, s in (('en', en), ('es', es)):
            if _normalize_field(s) not in known:
                known.add(_normalize_field(s))
                out.append(('1', 'contact_table:%s code 0x%02X (C%d)' % (lang, code, cnum), s))
    for base, lang in ((iomoon_strings.MENU_TABLE_BASE, 'en'),
                        (iomoon_strings.SPANISH_MENU_TABLE_BASE, 'es')):
        for i, (_rtype, _ic, _lc, lines, _children) in enumerate(iomoon_strings.menu_records(data, base)):
            for s in lines:
                if _normalize_field(s) not in known:
                    known.add(_normalize_field(s))
                    out.append(('1', 'menu_records:%s record %d' % (lang, i), s))

    for lang, bounds in (('en', iomoon_strings.ENGLISH_POOL), ('es', iomoon_strings.SPANISH_POOL)):
        for off, s in iomoon_strings.string_pool(data, *bounds):
            s = s.strip()
            if s and _normalize_field(s) not in known:
                known.add(_normalize_field(s))
                out.append(('2', 'pool:%s 0x%x' % (lang, off), s))

    for off, s in iomoon_strings.string_pool(data, 0x17a8, 0x2eaa):
        s = s.strip()
        if s and _normalize_field(s) not in known:
            known.add(_normalize_field(s))
            out.append(('3', 'sweep 0x%x' % off, s))

    return [(tier, src, s, _normalize_field(s) in seen) for tier, src, s in out]


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('paths', nargs='+',
                     help='the frame dump (colorizer .txt format); with --coverage, one or '
                          'more screens.csv files instead')
    ap.add_argument('--out', help='directory to write screens/ and screens.csv into')
    ap.add_argument('--marks', default=None,
                     help='the key script\'s .marks sidecar (default: <dump without extension>.marks)')
    ap.add_argument('--threshold', type=float, default=0.25,
                     help='all-pixel diff that starts a new scene (default 0.25)')
    ap.add_argument('--lit-threshold', type=float, default=0.8,
                     help='lit-union diff that starts a new scene (default 0.8)')
    ap.add_argument('--rom', default=None,
                     help='the 80188 ROM1 image (e.g. roms/iomoon/v1_3_01.bin) to read the DMD '
                          'font from for the text column; omitted, text is written empty. '
                          'Required with --coverage, to decode the ROM string pools.')
    ap.add_argument('--coverage', action='store_true',
                     help='report which ROM strings (see coverage_report) the given '
                          'screens.csv files do and do not contain, instead of splitting a dump')
    args = ap.parse_args()

    if args.coverage:
        if not args.rom:
            sys.exit('--coverage needs --rom')
        rows = coverage_report(args.rom, args.paths)
        missing = 0
        for tier, src, s, found in rows:
            print('%s  tier %s  %-40s |%s|' % ('   OK' if found else 'MISSING', tier, src, s))
            missing += not found
        print('%d strings named, %d missing (tier counts: %s)'
              % (len(rows), missing,
                 ', '.join('%s=%d' % (t, sum(1 for r in rows if r[0] == t)) for t in '123')))
        return

    if len(args.paths) != 1:
        sys.exit('exactly one dump file is required (omit --coverage for this mode)')
    if not args.out:
        sys.exit('--out is required (omit --coverage for this mode)')
    args.dump = args.paths[0]

    glyphs, glyphs12, score_glyphs, small_digits = {}, {}, {}, {}
    hud_messages, player_digits, score_digits = {}, {}, {}
    if args.rom:
        try:
            rom_data = open(args.rom, 'rb').read()
        except OSError as e:
            print('%s: %s -- text column will be empty' % (args.rom, e), file=sys.stderr)
        else:
            try:
                glyphs = iomoon_strings.glyph_bitmaps(rom_data)
                glyphs12 = iomoon_strings.glyph_bitmaps(
                    rom_data, height=iomoon_strings.FONT_H12_HEIGHT,
                    code_offset=iomoon_strings.FONT_H12_CODE_OFFSET)
            except ValueError as e:
                sys.exit('%s: malformed ROM (%s)' % (args.rom, e))
            score_glyphs = iomoon_strings.score_glyph_bitmaps(rom_data)
            small_digits = iomoon_strings.score_glyph_bitmaps(
                rom_data, height=iomoon_strings.SMALL_DIGIT_FACE_HEIGHT,
                width=iomoon_strings.SMALL_DIGIT_FACE_WIDTH,
                index=iomoon_strings.SMALL_DIGIT_FACE_INDEX)
            hud_messages = iomoon_strings.hud_message_bitmaps(rom_data)
            player_digits = iomoon_strings.player_number_bitmaps(rom_data)
            score_digits = iomoon_strings.score_digit_bitmaps(rom_data)

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

    # A scene's repr.txt is written once per DISTINCT content, not once per
    # scene: many scenes -- a menu record with no leaf under it, an idle
    # attract frame the loop revisits, the settled tail of an animation --
    # show pixel-for-pixel the same frame as an earlier scene, and a corpus
    # that stores that frame again for every occurrence overstates how many
    # screens the machine actually draws (measured on the committed en/
    # corpus: 5716 scenes, 922 distinct repr.txt contents -- 84% redundant
    # copies).
    # The first scene (in dump order, so this is stable across a re-split of
    # the same dump) to show a given content is canonical: its directory is
    # the one that gets a real repr.txt, and every later scene with the same
    # content records that scene's id in its own `repr_id` column instead of
    # writing the bytes again. A canonical scene's own `repr_id` is its own
    # id, so the column resolves the same way -- look up the row whose `id`
    # equals this row's `repr_id`, read *that* row's `dir` -- whether or not
    # this row is the one holding the file.
    canonical_id = {}
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
        content = tuple(scene[-1][1])
        repr_id = canonical_id.setdefault(content, n)
        if repr_id == n:
            with open(os.path.join(d, 'repr.txt'), 'w') as f:
                f.write('\n'.join(scene[-1][1]) + '\n')
        rows_out.append({'id': n, 'label': label, 'dir': name,
                         'first_ms': scene[0][0], 'last_ms': scene[-1][0],
                         'frames': len(scene),
                         'text': decode_text(scene[-1][1], glyphs, glyphs12, score_glyphs, small_digits,
                                             hud_messages, player_digits, score_digits),
                         'repr_id': repr_id})

    with open(os.path.join(args.out, 'screens.csv'), 'w', newline='') as f:
        w = csv.DictWriter(f, fieldnames=['id', 'label', 'dir', 'first_ms', 'last_ms',
                                          'frames', 'text', 'repr_id'])
        w.writeheader()
        w.writerows(rows_out)
    print('%d frames -> %d scene occurrences, %d distinct screens'
          % (len(frames), len(scenes), len(canonical_id)))


if __name__ == '__main__':
    main()
