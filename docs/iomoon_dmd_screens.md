# DMD Screen Corpus — Index and Coverage

[← Back to main README](../README.md)

Eighteen capture directories make up the corpus. Five are of `iomoont`, the PRESS START
tournament ROM — an English walk (`dmd/en/`), a Spanish walk (`dmd/es/`), the Spanish
service menu (`dmd/es-menu/`), eight targeted fault captures (`dmd/faults/`) and one
capture of the mod's SPECIAL/match `PRESS START` hook (`dmd/special/`). The other eight are of the parent `iomoon`, and cover play the
two language walks never reach: the Jupiter lock and Multiball (`dmd/multiball/`), every
Monolith award (`dmd/monolith/`), Wonderful Thing and the bank (`dmd/modes/`), the
rules sections those leave out (`dmd/coverage/`), Little Multiball in isolation
(`dmd/little-multiball/`), the three lit-lane awards (`dmd/lanes/`), a four-player
game (`dmd/players/`) and the Jackpot and Superjackpot (`dmd/jackpot/`).

Each directory's own README is the narrative account of how it was produced and what it
found; this document is the index — what screen is where — and the coverage gate: which
of the ROM's own strings the captures together do and do not put on screen, and why.

| Capture | Scene occurrences | Distinct screens | Labels |
|---|--:|--:|---|
| `dmd/en/` | 5714 | 920 | 120 |
| `dmd/es/` | 5410 | 823 | 54 |
| `dmd/faults/` (8 captures) | 178 | 159 | 7 labels, shared across captures (`unlabelled`, `boot`, `credit`, `ball-1-start`, `tilt-1`, `tilt-2`, `settle`) — a fault's own text rides on one of these, not a fault-named label of its own |
| `dmd/special/` | 313 | 259 | 14 — an ordinary boot/attract/game walk's labels plus `lottery` for the draw and `special-press-start` for the `D5077` screen the match reaches (`dmd/special/README.md`) |
| `dmd/multiball/` | 366 | 91 | 24 |
| `dmd/monolith/` | 432 | 237 | 104 |
| `dmd/modes/` | 169 | 123 | 33 |
| `dmd/coverage/` | 501 | 147 | 46 |
| `dmd/little-multiball/` | 158 | 90 | 23 |
| `dmd/lanes/` | 352 | 194 | 12 |
| `dmd/players/` | 400 | 219 | 45 |
| `dmd/jackpot/` | 475 | 223 | 27 |
| `dmd/contacts/` (2 languages) | 151 | 137 | 48 |
| `dmd/credits/` (8 countries) | 240 | 36 | 6 |
| `dmd/solenoid-test/` (84 captures) | 840 | 96 | 5 |
| `dmd/es-menu-full/` | 70 | 51 | 42 |
| `dmd/es-tilt/` | 218 | 152 | 8 |
| `dmd/es-menu/` | 57 | 40 | 33 |

**Corpus-wide that is 4,484 committed representative frames covering 2,441 distinct
screens** — distinct by `repr.txt` content across every capture, so a screen two walks
both reach is counted once.

"Scene occurrences" counts every visit the walk makes; "distinct screens" counts unique
`repr.txt` content — the number that answers "how many screens does this machine draw."
Both are counted from the committed files themselves, `screens.csv` rows and `repr.txt`
files, which can differ by a scene or two from `dmd_dump_split.py`'s own console summary
for the same dump.
`dmd/es/` itself has no service-menu tree, and `dmd/es-menu/` is why that is a gap in
the walk rather than a property of the machine. F19's country re-derivation lives on the
menu's **exit** path, so a walk that opens the menu once and navigates with select,
scroll and *back* keeps its country: `dmd/es-menu/` stays at country 5 throughout and
renders the records in Spanish. `dmd/README.md` and `dmd/es-menu/README.md` have the
trace and the measurements.

## File format

One row per scene occurrence in `<lang>/screens.csv`:

```
id,label,dir,first_ms,last_ms,frames,text,repr_id
```

Worked example (`dmd/en/screens.csv`):

```
id=5517, label=svc-36-close, dir=5517-svc-36-close, first_ms=4088716,
last_ms=4088750, frames=2, text="SOUND/VIDEO / GAME / TECHNICAL", repr_id=5382
```

`text` is the on-screen text decoded from the scene's last frame, one segment per
matched font face and screen row, joined `' / '` (`decode_text`,
`scripts/dmd_dump_split.py`) — here the h=9 face reads the menu root's own three
item lines on one row each. `repr_id` (5382) differs from `id` (5517): this
occurrence's last frame is pixel-identical to an earlier scene's (`5382`, label
`svc-0`, closing back out to the same root-menu screen), so no `repr.txt` was written
under `5517-svc-36-close/` — only `frame-*.txt` (not committed) — and the actual bytes
live at `dmd/en/screens/5382-svc-0/repr.txt`. Looking up a scene's real content is
always "read the row whose `id` equals this row's `repr_id`, then read *that* row's
`dir`" — true whether or not the row in hand is the canonical one.

A `text` segment read through the `height=12` face can show a `0` where the panel
actually reads `O`, or vice versa: that face's own `0` and `O` glyphs are
byte-identical bitmaps (`docs/dmd_graphics.md`, "Font Entry Structure"), an
undecidable-from-pixels property of the font, not a decoder fault — `INSCRIPTI0N`
for `INSCRIPTION` (`dmd/README.md`, the record-inscription item) is this, not a
typo. No other face here has the collision.

## Directory layout

```
dmd/
├── README.md                    # capture method, build/commit info, per-corpus narrative
├── en/
│   ├── iomoont.txt.gz            # raw frame dump (Serum/Pin2DMD format, timestamped), gzipped
│   ├── iomoont.marks             # key script's (frame, ms, label) sidecar
│   ├── screens.csv               # one row per scene occurrence (see above)
│   └── screens/<NNNN-label>/
│       ├── repr.txt              # one committed frame per distinct screen
│       └── frame-*.txt           # every raw frame of the scene (gitignored, regenerable)
├── es/                          # same layout; its own walk has no service-menu tree
├── es-menu/                     # the Spanish menu, captured in one entry (F19 bites on exit)
├── faults/
│   ├── README.md                 # which probe forced each of the 8 captures
│   └── <fault>/                  # same iomoont.txt.gz / iomoont.marks / screens.csv / screens/ layout
├── special/
│   ├── README.md                 # the SPECIAL/match (D5077) win, the lottery counter, and the three-way PRESS START comparison
│   └── iomoont.txt.gz / iomoont.marks / screens.csv / screens/   # same layout again
├── multiball/                   # the Jupiter lock and the MULTIBALL announce
├── monolith/                    # every Monolith award, and every mode it starts
├── modes/                       # Wonderful Thing, Special Drop Probe, the bank
├── coverage/                    # the rules sections the others leave out
├── little-multiball/            # LPA3 isolated with a probe that waits for the lamp
├── lanes/                       # Bonus x10, Special and Extra Ball collected at a lit lane
└── players/                     # a four-player game
        # each of the seven: README.md + iomoon.txt.gz / iomoon.marks / screens.csv / screens/
```

The seven gameplay captures are of the **parent `iomoon`**, so their dump and marks
files are `iomoon.*` rather than `iomoont.*`. Five of them — everything that locks a
ball at Jupiter — also need the PinMAME fix that makes the lock reachable at all
(commit `50b95257`); each README says so.

## Regenerating

Split one dump (needs the raw dump + marks sidecar, both committed; `--rom` is optional
but needed for the `text` column):

```bash
cd sleic-iomoon
python3 scripts/dmd_dump_split.py dmd/en/iomoont.txt.gz --out /tmp/regen \
        --marks dmd/en/iomoont.marks --rom ../pinmame/roms/iomoon/v1_3_01.bin
diff <(cut -d, -f1,2,6 /tmp/regen/screens.csv) <(cut -d, -f1,2,6 dmd/en/screens.csv) \
  && echo "regeneration reproduces the corpus"
```

Verified for this document: `27712 frames -> 5716 scene occurrences, 922 distinct
screens`, and the diff prints nothing but `regeneration reproduces the corpus`. The same
two commands, with `es`/`faults/<fault>` in place of `en`, regenerate those.

Capturing a dump in the first place (build, commit, exact invocation) is `dmd/README.md`'s
job, not this document's — see its "PinMAME build and capture" section.

## Screen index, by area

Full per-row detail is `screens.csv` itself; this groups the corpus's 120 (`en`) / 54
(`es`) labels by area, with scene-occurrence and distinct-screen counts (`en`/`es`) and
one example of decoded text where any exists. Numbered families (`ball-1-*`,
`ball-2-*`, `ball-3-*`; `svc-0` .. `svc-37`; …) are collapsed to one row.

### Boot

| Label | Occ (en/es) | Distinct (en/es) | Example text |
|---|---|---|---|
| `unlabelled` (pre-mark boot frames) | 2/2 | 2/2 | `WAITING FOR / 8 BITS CPU`, then `SETTING / DEFAULT VALUES / PRESS START` |
| `boot` | 2/2 | 2/2 | `BALLS OK` (`en`) / `BOLAS OK` (`es`) |
| `boot-setting-country` | 3/3 | 3/3 | empty — see Coverage, "boot-setting-country never shows text" |

### Attract

| Label | Occ (en/es) | Distinct (en/es) | Example text |
|---|---|---|---|
| `attract` | 134/133 | 88/88 | `S.` (fragment of `S.MOONLIGHT`) |
| `attract-again` | 125/124 | 75/75 | same idle cycle, reached after a game instead of from boot |
| `credit` | 7/7 | 6/6 | empty |
| `press-start-normal` | 4/4 | 4/4 | `PRESS START` — the tournament mod's end-of-game hook (`D5123`) |
| `score-attract-again` (same idle cycle, second game) | 149/172 | 86/76 | `S.` |
| `score-credit` (same as `credit`, second game) | 5/6 | 5/6 | empty |

### Game

| Label | Occ (en/es) | Distinct (en/es) | Example text |
|---|---|---|---|
| `ball-N-start` (N=1-3) | 45/45 | 45/45 | `PLAYER BALL` (`en`) / `JUGADOR BOLA` (`es`) — the in-play HUD, most but not all occurrences (42/45) |
| `score-start` (the second game's own START-to-ball-1 transition, following `score-credit`) | 46/46 | 46/46 | `1 1 / PLAYER BALL` |
| `ball-N-in-play` | 67/67 | 42/42 | `PLAYER BALL` — the small `h=12` digit face's own `3. 8.743` (F13, `docs/dmd_graphics.md`) still decodes too, on the scenes that show it |
| `ball-N-drained` | 92/92 | 92/92 | `1 2 / PLAYER BALL` |
| `drop-bank-N-down` | 10/10 | 10/10 | `PLAYER BALL` (was 12/12 before the `full-tilt` mark fix below moved 2 `drop-bank-5-down` occurrences to the `full-tilt` label instead) |
| `full-tilt` | 2/2 | 2/2 | empty — large drop-shadowed `TILT` text (2265 lit pixels, `dmd/en/screens/0303-full-tilt/repr.txt`), legible by eye but not matched by any walked face; whether it is font-composed or a picture is not established (`dmd/README.md`, item 4). Faults' own `tilt` capture separately has the small `h=9`-face `ONE TILT`/`TWO TILTS` warning strings |
| `score-ball-N-in-play` | 4480/4478 | 341/337 | `PLAYER BALL` (`en`) / `JUGADOR BOLA` (`es`) — the second, high-score-qualifying game's own play, same mechanics |
| `score-ball-N-drained` | 90/90 | 90/90 | `PLAYER BALL` |
| `score-recover-*` (4 labels: `drained`, `hits`, `plunge`, `wait` — the awarded extra ball) | 25/24 | 23/22 | `2 6.515 / PLAYER BALL` (recovery-ball hit counter, `h=12`, beside the in-play HUD) |

Every `ball-N-in-play`/`ball-N-drained`/`ball-N-start` scene shows `PLAYER 1` and `BALL 1`
on screen in a small, single-pixel-stroke face; that font is now decoded
(`docs/dmd_graphics.md`, "The in-play PLAYER/BALL HUD..."), and these labels'
`Example text` above reflects it. What is still empty on some of these labels is the
gameplay-only feature text beside the HUD words (orbit/target progress hints, feature
awards) — see Coverage, "Gameplay feature-progress hints" — not the HUD words
themselves.

### End of game

| Label | Occ (en/es) | Distinct (en/es) | Example text |
|---|---|---|---|
| `ball-3-drained-gameover` | 7/7 | 7/7 | empty — the last drain and the score wrap-up, up to the draw |
| `lottery` | 3/3 | 3/3 | empty — the post-game draw (§3.5): a Monolith/train graphic, then the final score above a full-panel digit, and **that digit is the drawn number**, equal to the counter `4000:113F` the match compares against (`dmd/special/README.md`). Drawn at the end of every game, matching or not |
| `high-score-entry` | 7/7 | 6/6 | empty |
| `score-lottery` (the second game's own draw) | 1/1 | 1/1 | empty — the same reveal, but **after** name entry rather than before it: that game's compare runs at ms 1628730, and the digit drawn is `7`, the counter's value there (`dmd/special/README.md`) |
| `score-press-start-normal` | 1/1 | 1/1 | `PRESS START` — the second game's own `D5123` ending |
| `wheel-cN-*` (12 label families — `fixed`/`fwd-00..04`/`refwd-00..03`/`erase-*` — across wheels 1-3, 17 raw labels) | 18/18 | matches occ (each a distinct redraw) | `N N / 0D` (the selected character plus its wheel position) |
| `score-post-entry-wait` (holds after the second game's own `PRESS START`, before returning to attract) | 10/23 | 9/11 | empty |
| `score-ball-3-drained-gameover` (same as `ball-3-drained-gameover`, second game) | 43/42 | 43/42 | empty |
| `score-high-score-entry` (same as `high-score-entry`, second game) | 1/1 | 1/1 | `N N` |

The initials wheel-walk (`docs/iomoon_game_rules.md` 4.2) is captured in full, including
one erase-symbol demonstration (`wheel-c3-erase-symbol`/`wheel-c3-erase-tried`), with the
selected character changing at every marked step per `dmd/README.md`'s own account.

### Service menu (`en` only — F19)

| Label | Occ | Distinct | Example text |
|---|---|---|---|
| `svc-0` .. `svc-37` (38 records) | 109 | 55 | `SOUND/VIDEO / GAME / TECHNICAL` (record 0); every deeper record shows the `h=12` tile-glyph-bar artifact, a pre-rendered full-screen image, or nothing — see Coverage |
| `svc-N-close` | 11 | 6 | same root-menu text, on backing out |
| `back-to-N` | 31 | 31 | `VOLUME / CUSTOM MESSAGE` (record 1's own two lines, on one back-out path) |
| `reopen-for-svc-N` | 49 | 19 | mostly empty (transient re-entry frames; F19's own re-entry marks), but three of these scenes (leading into `svc-35`) catch a legible mid-animation moment: `BOARD TEST / CREDITS / TILTS`, `SOLENOIDS / LIGHTS / SWITCHES`, `LIGHT TEST 1 / LIGHT TEST 2 / LIGHT TEST 3` — see Coverage |
| `svc-menu-done` | 20 | 20 | empty |
| `svc-menu-final-close` | 72 | 38 | `--` (h=12 tile-bar noise) |
| `svc-root-exit` | 43 | 26 | mostly empty; one scene decodes `SETTING COUNTRY / DEFAULT VALUES` (the boot country-mismatch recovery screen, F11 — also captured here, not only at `boot-setting-country`), another `GAME / TECHNICAL` (a stale root-record fragment) |

Every one of the 38 records has at least one captured scene. Under their own `svc-N`
label, only the root (record 0) and its first child (record 1) settle to legible static
item text; three further records' own item text (3, 22, 25) turns up instead as a
transient mid-animation catch under `reopen-for-svc-N` (above), not as their own settled
page. Three deep leaf records (33, 36, 37) are confirmed showing a pre-rendered
full-screen image, not composed text, as their real content — no capture, however
extended, recovers a string from those. One (24) shows no new content of any kind. See
Coverage for the full breakdown and what each disposition means.

### Gameplay (the seven `iomoon` captures)

These cover play the two language walks never reach. Each capture's own README lists
its marks and the firmware state that confirms it; this is where to look for a screen
rather than a full label index.

| Capture | What is in it | Occ | Distinct |
|---|---|--:|--:|
| `multiball/` | the six ORBITS letters, two Jupiter locks, **BALL LOCKED FOR MULTIBALL** and the full-height **MULTIBALL** with its wipe | 366 | 91 |
| `monolith/` | twelve rounds of arm / step / cash, covering nine of the ten Monolith positions and playing every mode each one starts | 432 | 237 |
| `modes/` | ORBITS, the bank cleared, **Special Drop Probe**, **Wonderful Thing** and its staged release, the Lagrange pair | 169 | 123 |
| `coverage/` | Little Multiball arming, all eleven lanes, lane 10 with ORBITS complete, bull's-eye 2, the inner target with the bank standing, the end-of-ball bonus countdown | 501 | 147 |
| `little-multiball/` | one lock taken on the frame `LPA3` is lit, `LTB12` at scoop 1, eight scoop-1 collects | 158 | 90 |
| `jackpot/` | Multiball driven to a running mode, then the **Jackpot** at bull's-eye 2 and the **Superjackpot** at Ramp 2, each collected twice to show it is one-shot | 475 | 223 |
| `lanes/` | **Bonus ×10** at lane 9, **Special** at lane 7, **Extra Ball** at lane 8, each with its own lamp confirmed lit up to the press | 352 | 194 |
| `players/` | a **four-player** game, twelve balls, and the four-player score display | 400 | 219 |

**Almost none of this decodes as text**, which is why the coverage numbers below do not
move when these captures are included: across all seven, `screens.csv` decodes little
beyond the in-play HUD's own `PLAYER`/`BALL` words and score digits. The mode
announcements — `BALL LOCKED FOR MULTIBALL`, `MULTIBALL`, the award banners — are
legible by eye in their `repr.txt` and matched by no walked face, the same class as the
full-tilt `TILT` screen (`dmd/README.md`, Open items).

**Jackpot and Superjackpot are in `dmd/jackpot/`**, collected and paid — the Jackpot
40,050,001, the Superjackpot 80,000,000, both one-shot per Multiball. Reaching them
needed a simulator fix (`pinmame` `dfba2385`): the 80188 counts a Jupiter lock from C46
but the Z80 releases from C44, so the mode used to announce and never start. F22 has
the firmware side.

### Faults (`dmd/faults/`, 8 captures)

`dmd/faults/README.md` is the complete, per-fault account (condition, probe, exact
mechanism cited against `iomoon_80188.lst`) — not repeated here. Summary:

| Fault | Capture | String(s) confirmed on screen |
|---|---|---|
| EEPROM failure | `eeprom` | `EEPROM FAILURE`, `CANNOT CONTINUE` |
| Wrong BIOS handshake | `wrongbios` | `WRONG BIOS`, `CANNOT CONTINUE` |
| Ball-out kicker jam | `ball-out-error` | `BALL OUT ERROR` |
| Trough not satisfied at boot | `ball-missing` | `BALL MISSING` (and, already in `dmd/en/`, the healthy counterpart `BALLS OK`) |
| Tilt warnings | `tilt` | `WARNING`, `ONE TILT`, `TWO TILTS` |
| Solenoid short | `solenoid-short` | `GROUP: T17-18-19`, `SHORT`, `CANNOT CONTINUE` (`SOLENOID FAIL` present but not decoded — see Coverage) |
| Solenoid cut/open | `solenoid-cut` | `GROUP: T17-18-19`, `CUT OR`, `FUSE F4` (`SOLENOID FAIL` likewise) |
| Flipper winding separated/broken | `flipper-broken` | `L.C.FLIPPER`, `SEPARATE/BROKEN` |

All twelve of the fault strings `dmd/faults/README.md` sets out to capture are captured;
one (`SOLENOID FAIL`) is on screen but not decoded — a documented panel-edge clip, not a
missing screen (see Coverage).

## Coverage

### Method

`scripts/dmd_dump_split.py --coverage --rom <ROM1> <screens.csv>...` enumerates every
string `iomoon_strings.py` can currently name and checks each against every given
`screens.csv`'s `text` column. Run for this document:

```bash
cd sleic-iomoon
python3 scripts/dmd_dump_split.py --coverage \
        --rom ../pinmame/roms/iomoon/v1_3_01.bin \
        dmd/en/screens.csv dmd/es/screens.csv dmd/faults/*/screens.csv
```

**What counts as "named."** The brief's original `coverage()` (walking only
`ENGLISH_POOL`/`SPANISH_POOL`) measures against roughly 100 of the ROM's ~505
length-prefixed strings between `0x17a8` and `0x2eaa` — a number that would come out
flatteringly high and mean nothing. This tool instead
names strings in three tiers, most to least certain about what ROM data a string actually
is:

1. **`contact_table()`/`menu_records()`** — a string reached through a resolved pointer
   (F14 the 38-record menu tree, F16 the switch/cabinet names), both languages.
2. **`ENGLISH_POOL`/`SPANISH_POOL`** — the two windows `iomoon_strings.py` declares.
   `ENGLISH_POOL` is the verified full envelope of tier 1's own two English tables,
   so in practice it adds nothing tier 1 didn't already reach; `SPANISH_POOL`
   stays a narrower, verified-clean sub-window.
3. **Everything else** a flat length-prefixed byte sweep finds in the ROM's whole string
   area, `0x17a8`-`0x2eaa` (18 bytes short of `0x2ebc`: a sweep that wide picks up one
   spurious string, `0020000000000000` at `0x2eab` — the six bytes right before it,
   `20 00 10 00 00 02` at `0x2ea9`, are a second image header in the same format as the
   one at `0x24EA4` (F20), not padding, so the sweep stops before it). These are real ROM
   strings with no pointer table pinned down yet — the
   fault/boot messages, the coil-group and fuse names, the per-country CREDITS-page
   denominations — reported as exactly that, tier 3, not folded into tiers 1-2's own
   count.

Each distinct string value is named once, at its first (lowest-tier, then lowest-offset)
source.

**What counts as "present."** A string is present only if it equals — after folding case
and collapsing whitespace on both sides — one *whole* decoded field: one `' / '`-delimited
segment of a row's `text`, never a substring and never a single word carved out of a
longer field. A substring test (the brief's own `s.upper() not in blob`) counts the
pool's own short or common entries — `M`, `YES`, `SHORT`, `SETTING` — as covered by nearly
any text; and even a whole-*word* test would wrongly credit the ROM's distinct `SETTING`
string (`0x2a08`, the EEPROM-recovery screen) from a field that is really the unrelated
`SETTING COUNTRY` (`0x2c7c`, a different string with its own separate offset).

**What "missing" can mean — three different things, kept separate throughout this
report.** A string counted as missing by the rule above falls into one of three cases,
and conflating them overstates the capture gap:

1. **Missing from the corpus** — the machine can draw this screen and the walk never
   reached it, or reached it too briefly.
2. **Captured, but in a font this decoder cannot read** — the screen is on the panel,
   `repr.txt` holds it, a human reading the pixels can see the words, and no walked font
   table entry matches the bitmap. The in-play `PLAYER`/`BALL` font was the standing
   example for this case; it is now decoded (`docs/dmd_graphics.md`, "The in-play
   PLAYER/BALL HUD..."). The gameplay feature-progress hints below (orbit/target
   progress, feature awards) are the current standing example: a different, still
   unlocated font or table, not the same one.
3. **Captured, but drawn as a picture, not text** — the screen is on the panel and
   `repr.txt` holds it, but the content is a complete pre-rendered image baked into ROM1
   at build time (F20; `docs/dmd_graphics.md`, "Full-screen images outside the walked
   table use the same entry format"), not characters assembled from the font table at
   run time. **No font-based decoder, this one or any other, can ever recover a string
   from a screen in this category** — extending the capture cannot help, because there
   is nothing font-shaped on the page to match. This is different from case 2: case 2 is
   a decoder that hasn't found the right font yet; case 3 has no font to find.

This is also why the numbers below understate what the corpus actually contains: a
screen can be fully captured and perfectly legible to a human looking at `repr.txt`, and
still contribute nothing to a text-match count, for either reason 2 or reason 3.

### Numbers

| | Count |
|---|---|
| Strings named (tier 1 / tier 2 / tier 3) | 275 / 0 / 166 = 441 |
| Present (whole-field match, anywhere in the corpus) | 214 |
| Missing | 227 |

**Computed over every capture**, all sixteen directories, in one run:

```bash
python3 scripts/dmd_dump_split.py --coverage \
        --rom ../pinmame/roms/iomoon/v1_3_01.bin \
        dmd/*/screens.csv dmd/faults/*/screens.csv \
        dmd/contacts/*/screens.csv dmd/credits/*/screens.csv \
        dmd/solenoid-test/*/*/screens.csv
```

**The gameplay captures move the count by zero**, and the service-menu ones move it a
long way. `dmd/en`, `dmd/es`, `dmd/faults` and `dmd/special` alone give 404 missing; the
seven gameplay captures add nothing to that; `dmd/es-menu/` takes it to 399, and then
`dmd/contacts/` (the machine's own switch test, 93 strings) and `dmd/solenoid-test/`
(every coil-group and fuse page, 74) take it to **227**, with the Spanish tilt warnings and the Spanish menu walk closing the rest of what language alone was hiding. Where a machine keeps its text
is now clear from the numbers: in the service menu, not in play. That is a real result about where this machine's text lives rather than a
shortfall in those captures: they hold 1,101 distinct screens between them, but what
is on those screens is mode announcements and award banners drawn in faces the decoder
does not have, plus the in-play HUD it does. A `PLAYER`, a `BALL` or a bare digit is
rarely a whole-field match for a *named* ROM string, most of which are multi-word
menu or fault prose.

The same holds for the HUD/score decoder work before it (`dmd/README.md`'s own items on
the in-play `PLAYER`/`BALL` HUD and the in-play score): it added hundreds of decoded
fields to both language corpora and moved this count by one.

Tier 2 contributes zero *additional* strings once tier 1 is already counted — every
`ENGLISH_POOL`/`SPANISH_POOL` entry is also reachable through `contact_table()` or
`menu_records()` (or is the same string at a one-byte-different offset, folded together
by the whole-field normalization). This is expected, not a bug: it is what widening
`ENGLISH_POOL` to the pointer tables' own envelope achieves.

**This is not "92% missing."** A string being "named" only means `iomoon_strings.py` can
point at its ROM bytes; "missing" here means *not decoded as a whole field in any
captured scene's representative frame*, for one of the three reasons above — capture gap,
unlocated font, or pre-rendered image — and that last one, in particular, cannot be
closed by capturing more. The rest of this section is the actual answer: every missing
string, grouped, with a citation and a disposition.

### What is captured and decoded

37 strings match cleanly:

- **Menu chrome (tier 1, English only):** the root record's three items
  (`SOUND/VIDEO`, `GAME`, `TECHNICAL`) and its first child's two
  (`VOLUME`, `CUSTOM MESSAGE`) — each under its own `svc-N`/`back-to-N` scene, the
  record's genuine settled page.
- **Three further records' own item lines (tier 1, 9 strings, new against the
  recaptured `dmd/en`):** record 3 (`BOARD TEST`, `CREDITS`, `TILTS`), record 22
  (`SOLENOIDS`, `LIGHTS`, `SWITCHES`), record 25 (`LIGHT TEST 1`, `LIGHT TEST 2`,
  `LIGHT TEST 3`) — all three under `reopen-for-svc-N`, not their own `svc-N` label:
  they are caught mid-animation as the menu walks back down past them while re-opening
  toward `svc-35`, not as their own settled resting page (which, under `svc-3`/`svc-22`/
  `svc-25` themselves, still shows the `h=12` tile-bar). Real ROM text, genuinely on
  screen and genuinely decoded — just not where a reader watching only `svc-N` labels
  would expect to find it, which is exactly why `dmd/README.md`'s own Open-items
  account of the service-menu dwell didn't count it: that check
  looked at `svc-N` scenes specifically, and none of those three changed.
- **One contact name (tier 1):** `L.C.FLIPPER` — not from the CONTACTOS test screen, but
  from the `flipper-broken` fault screen, which happens to show the same name.
- **One menu item, matched from an unrelated screen (tier 1, new):** `EXTRA BALL` — the
  named string is record 11's own item line (`- STATISTICS -` submenu), never itself
  captured under a `svc-N` label; the whole-field match instead comes from the in-play
  HUD's own flashing `EXTRA BALL` indicator (`dmd/README.md`, the `PLAYER`/`BALL` item),
  which happens to render the identical text. A coincidence of two unrelated ROM
  strings sharing the same words, not a decode of the STATISTICS record.
- **21 tier-3 strings**, all from `dmd/faults/` plus `dmd/en/`'s own boot scenes:
  `GROUP: T17-18-19`, `FUSE F4` (the one coil group and fuse the `solenoid-cut` probe
  exercises), `BALL OUT ERROR`, `BALL MISSING`, `BALLS OK`, `WARNING`, `ONE TILT`,
  `TWO TILTS`, `SEPARATE/BROKEN`, `EEPROM FAILURE`, `SETTING`, `DEFAULT VALUES`,
  `PRESS START`, `SHORT`, `CANNOT CONTINUE`, `WRONG BIOS`, `CUT OR`, `WAITING FOR`,
  `8 BITS CPU`, `SETTING COUNTRY`, `BOLAS OK`.

`PRESS START`/`SETTING`/`DEFAULT VALUES` are in this list, against the brief's framing
of `PRESS START` as "in neither ROM string pool" — it is
real string-pool data at `0x2a1f` (`SETTING` `0x2a08`, `DEFAULT VALUES` `0x2a10`), merely
outside `ENGLISH_POOL`'s narrow window, and tier 3's sweep names it like any other pool
string. It is confirmed captured: `dmd/en/screens.csv` scene 2 and six of the eight
`dmd/faults/*` captures' own scene 2 decode `SETTING / DEFAULT VALUES / PRESS START`
verbatim. Two do not: `tilt`, whose NVRAM is pre-patched per its own key script's header
(F10), so the recoverable first check this screen belongs to may not trigger there at
all; and `wrongbios`, whose scene 2 is `WRONG BIOS` — that capture stops at two scenes.
Whether the tournament mod's code cave *additionally* rebuilds its own copy of
this text at run time from `MOV AL,<glyph>` immediates (the brief's original Step 2) is a
separate, open question that these three strings' pool membership does not resolve
either way — it bears on the patch's own implementation
(`docs/press_start_patch.md`), not on whether this string is covered by the corpus, which
it now demonstrably is.

### Every missing string, grouped and explained

**Tier 1 — 254 missing.** No individual disposition per string; two source groups
account for all of them, and item 2 splits into four distinct outcomes below.

1. **F16 switch/cabinet names, 90 missing (`contact_table()`, English + Spanish, shared
   text deduplicated once).** These render only on the live CONTACTOS/SWITCH TEST screen
   (record 26's child, `svc-32`; F14) when an actual matrix switch closes during the test
   — confirmed by inspection: `svc-32`'s own scenes decode empty or noise
   (`'--'`/`'TEC'`) across every occurrence, never a contact name. Neither walk closes a
   playfield switch while inside this screen. **Capture gap:** extend
   `scripts/keyscripts/iomoon-en.keys` (or a probe using `SLEIC_INJECT_COL`/
   `SLEIC_INJECT_BIT`) to trigger a few matrix switches while `svc-32` is open. Spanish
   names are additionally gated by F19 (below).

2. **The 38-record menu tree's own item/title prose, 164 missing (`menu_records()`,
   English + Spanish; 10 moved to present — the 9 from the earlier recapture plus
   `EXTRA BALL`, matched coincidentally from the in-play HUD rather than from its own
   record, see "What is captured and decoded" above).** Commit `8d2c0f5` stretches every
   plain record-to-record transition roughly 25x (120 to 3000 frames), testing directly
   whether a deeper record simply needs more dwell.
   Measured against `svc-N`-labeled scenes specifically (the record's own settled page,
   as opposed to a transient re-entry frame under a different label), dwell is not the
   general answer (`dmd/README.md`'s Open items): only root and record 1 settle to their
   own static item text. What the fuller picture actually shows:
   - **Records 3, 22 and 25's own item lines are genuinely present (the 9 strings
     above), but not as their own settled `svc-N` page** — a `reopen-for-svc-N` scene
     catches them mid-animation as the menu walks back down past them while re-opening
     toward `svc-35`. `svc-3`/`svc-22`/`svc-25` themselves are unchanged, still the
     `h=12` tile-bar.
   - **`LIGHT: LC` (the template line records 35, 36 and 37 share) is a matching-rule
     limit, not a missing screen.** Record 35 shows genuine live composed text,
     `LIGHT: LC10` — real content, correctly decoded — but a live screen always appends
     a number, so it can never whole-field-match the bare pool string. No amount of
     capture closes this gap; the pool string is a template, not the complete on-screen
     text.
   - **Three records' own titles — `-SEND-REC TEST-` (33), `- LIGHT TEST 2 -` (36),
     `- LIGHT TEST 3 -` (37) — are a pre-rendered image, confirmed (F20).** All three
     records are directly confirmed, by row-for-row byte comparison against ROM1, to
     show a complete pre-composed picture (header at `0x24EA4`) as their real settled or
     mid-redraw content, not text assembled from the font table — see "What 'missing'
     can mean" above and `docs/dmd_graphics.md`. **No capture recovers these strings.**
     Record 36 also carries the shared `LIGHT: LC` line (above) and is directly
     confirmed drawing the image (a mid-redraw partial match, `svc-36` scene 5511,
     rows 8-31 exact, rows 2-7 still blank); whether it *also*
     shows a live `LIGHT: LC`n readout at some other point in its own occurrence
     sequence, the way 35 does, has not been checked.
   - **The remaining ~29 records (4-21, 23, 26-32, 34, both languages) are unresolved,
     not confirmed as either a capture gap or an image.** `svc-2`'s own scene (record 2,
     a plain branch/list record like 0 and 1) decodes the identical tile-bar pattern at
     both the original ~120-frame dwell and the stretched ~3000-frame one — evidence the
     tile-bar is this depth's stable, fully-drawn state, not a transition a longer wait
     resolves — but whether that state is itself font-composed, a different image, or
     something else has not been checked the way 33/36/37 were. `svc-24` (SOLENOID
     TEST) is a sharper, separate open case: every one of its five occurrences, even
     after the dwell stretch, matches early boot/attract content exactly — no new
     content of any kind, image or text — so its own screen appears never to redraw
     during this walk at all, a different symptom from the tile-bar records. **What
     would settle the rest:** the same row-for-row ROM byte comparison used for
     33/36/37, run against a captured frame from each remaining record in turn.
   Spanish is additionally gated by F19 throughout this whole item: the corpus never
   opens the Spanish menu at all (below).

**Tier 3 — 145 missing** (tier 3 measures ROM
strings against text anywhere in any of the three corpora; none of `dmd/en`'s 9
newly-present strings are tier-3 ones — see "What is captured and decoded"
above). Thirteen groups (the SEND-REC/LIGHT TEST chrome group of the original ten has
split three ways with F20's finding); every one of the 145 strings is a member of
exactly one.

| Group | Count | Members | Disposition |
|---|---|---|---|
| English coil-group names | 20 | `GROUP: T29-30` .. `GROUP: TA3-B3-C3` (`T17-18-19` already captured) | **Capture gap, confirmed only via the fault probe.** Shown one at a time by the fault probe's own direct-input code (`dmd/faults/README.md`, `0x50`-`0x64`); this walk and the fault probes exercise only `T17-18-19`. Whether the record's own live `SOLEN. NUM.` entry (F14, `svc-24`) reaches the same content is now open, not assumed: every one of `svc-24`'s five occurrences, even at the 25x-longer dwell (`8d2c0f5`), matches early boot/attract content exactly, with no new content of any kind (Tier 1, above). Extending the fault probe's own injected code across `0x50`-`0x64` is the confirmed path to recover the rest. |
| Spanish coil-group names | 21 | `GRUPO: T17-18-19` .. `GRUPO: TA3-B3-C3` | **Capture gap.** Same mechanism as above, plus the fault corpus running under the English/default country throughout. `dmd/es-menu/` shows the Spanish menu is reachable in one entry, so F19 is not a second gate here. |
| English fuse names | 14 | `FUSE F5`..`F26` (`F4` already captured) | **Capture gap, confirmed only via the fault probe** — same caveat as the coil-group row: only `F4` was exercised, and `svc-24`'s own ordinary menu path is unconfirmed, not assumed working. |
| Spanish fuse names | 15 | `FUSIBLE F4`..`F26` | **Capture gap, doubly gated**, same as the Spanish coil-group row. |
| English SEND-REC/LIGHT TEST chrome — confirmed pre-rendered image | 4 | `SEND`, `RECEIVE` (record 33, SEND-REC TEST), `FIXED LIGHTS` (record 36, LIGHT TEST 2), `FLASHES` (record 37, LIGHT TEST 3) | **Pre-rendered image, confirmed (F20).** These three records are directly confirmed showing a complete pre-composed picture, not composed text, as their real content (see Tier 1, item 2, and `docs/dmd_graphics.md`). Record attribution is by ROM string order matching record order (`SEND`/`RECEIVE` at `0x2c1d`/`0x2c22`, `FIXED LIGHTS` at `0x2c38`, `FLASHES` at `0x2c45`, sequential and in the same order as records 33/36/37); the image itself has not been read letter by letter, so which of these words it depicts, if any, is not separately confirmed — only that the page they would render on is a picture. **No capture recovers these.** |
| English LIGHT TEST 1 chrome — still a capture gap | 1 | `CONTROLLED L.` (record 35, by the same ROM-order inference) | **Capture gap**, not reclassified: record 35 is confirmed showing genuine live composed text (`LIGHT: LC10`, Tier 1 above), so this record's screen is glyph-based, not an image — the specific word `CONTROLLED L.` simply was not the content on screen when this walk visited. |
| English SOLENOID TEST chrome — mechanism unresolved | 7 | `YES`, `NO`, `FLASH: FL`, `FUSES TEST`, `FUSES END`, `SOLENOID ERROR`, `PRESS TEST` | **Open**, by ROM-cluster proximity to `svc-24` (SOLENOID TEST), whose own mechanism is itself unresolved (Tier 1, item 2): neither an image nor real glyph content is confirmed there, so neither disposition can be asserted for these seven yet. What would settle it: the same row-for-row ROM comparison used for records 33/36/37, checked against `svc-24`'s own captured frames first (they may simply never change). |
| `SOLENOID FAIL` — decoder limit, not a capture gap or an image | 1 | `SOLENOID FAIL` | `dmd/faults/README.md`'s own "Decoding notes" confirms this by hand: the string sits at rows 0-6 with its own top row clipped past the panel's row 0, and padding the missing row and matching against `iomoon_strings.glyph_bitmaps()` reproduces the ROM's bitmap byte for byte. It is on screen in both `solenoid-short` and `solenoid-cut`; `_scan_face`'s fixed-stride scan cannot recover a line that starts before row 0. Confirmed real glyph text, not a picture. |
| Spanish SOLENOID/LIGHT/SEND-REC test chrome | 11 | `SI`, `ENVIA`, `RECIBE`, `L. CONTROLADAS`, `LUCES FIJAS`, `TEST FUSIBLES`, `FIN FUSIBLES`, `ERROR BOBINAS`, `PULSE TEST`, `PONIENDO VALORES`, `FABRICA DE PAIS` | **Doubly gated, mechanism moot.** No Spanish service-menu tree at all (F19) already fully explains every one of these regardless of whether its English counterpart's own record turns out to be an image, glyph-based, or unresolved. |
| Per-country CREDITS denominations (English) | 20 | `OF 1OF CRED:`, `OF 5DM CRED:`, `OF 2ML CRED:`, `OF 20K CRED:`, `OF 50F CRED:`, `OF 200 CRED:`, `OF 50E CRED:`, … (every English denomination row except the Netherlands' own `OF 10`/`OF 50`/`OF 1PD CRED:`, which are tier 1 and also missing — see above) | **Matching-rule limit, not a capture gap — all seven countries are now captured** (`dmd/credits/`). These strings are **templates**: the ROM stores `OF 5DM CRED:`, and the live page draws `1 OF 5DM CRED:8`, prepending the coin count and appending the credit count, so it can never whole-field-match however often it is captured. Same class as `LIGHT: LC`. The screens themselves are legible and decoded — `1 OF 1PD CRED:5` (United Kingdom), `1 OF 2DM CRED:3` (Germany), `1 DE 100 CRED:3` (Spain, which renders the whole page in Spanish) — and `dmd/credits/README.md` has the table. |
| Spanish fault/boot messages | 17 | `FALLO MEM. CPU8`, `ERROR SAL. BOLAS`, `FALTAN BOLAS`, `ATENCION`, `UNA FALTA`, `DOS FALTAS`, `SEPARADO O ROTO`, `FALLO EEPROM`, `ESTABLECIENDO`, `VALORES FABRICA`, `PULSE START`, `FALLO BOBINA`, `EN CORTO`, `IMPOSIBLE SEGUIR`, `CORTADOS O`, `ESPERANDO`, `CPU 8 BITS` | **Capture gap.** These are the Spanish-language counterparts of the twelve strings `dmd/faults/README.md` already captures in English; every fault probe in that corpus ran under the default (English) country. Extending each `SLEIC_FORCE_FAULT` capture with the Spanish `iomoont-spain.cfg` (`dmd/README.md`'s own Spanish-corpus method) would recover these, exactly the way `dmd/es/` reused `dmd/en/`'s own game section under Spain's cfg. |
| Trough/ball-serve status | 8 | `SACA BOLA 1`, `SACA BOLA 2`, `SACA BOLA 3`, `UNA BOLA`, `DOS BOLAS`, `TRES BOLAS`, `SALIDA BOLAS`, `JUPITER` | **Open, and the obvious hypothesis is refuted.** It was read as F15's ball-serve/search narration, to be reached by holding the trough short. It is not: a throwaway probe that masks trough optos off *after* the simulator fills them (the existing `SLEIC_TROUGH` can only OR bits in, which cannot take a ball away) was run three ways — short at boot with masks `0x04`, `0x06` and `0x07`, and short from mid-game after the ball is in play. Short at boot draws `BALL MISSING` and blocks the game before it ever serves; short mid-game changes nothing visible, the HUD simply continues. None of the eight strings appeared in any run. What the words themselves suggest — `SACA BOLA 1`-`3` ("eject ball 1-3"), `UNA`/`DOS`/`TRES BOLAS`, and the two device names `SALIDA BOLAS` and `JUPITER` — is a **ball-location diagnostic page** in the service menu rather than in-play narration, which would put it on one of the records the walks only ever see as F21's depth bar. Settling it wants the drawing routine traced from the Spanish/English string tables, not another capture. |
| Gameplay feature-progress hints (English + Spanish) | 6 | `ORBITS LEFT TO`, `TARGETS LEFT TO`, `LIT EXTRA BALL`; `ORBITAS PARA`, `DIANAS PARA`, `LUZ BOLA EXTRA` | **Decoder limit, not a capture gap.** `dmd/en/`'s own walk exercises both the orbit lane and the drop-target bank (`dmd/README.md`'s English-corpus description), so these progress messages plausibly did render during the captured game. They are gameplay-only text, drawn during the same in-play state the HUD `PLAYER`/`BALL` words are — but not the same font or table: the HUD words are now decoded (`docs/dmd_graphics.md`, "The in-play PLAYER/BALL HUD..."), and these six strings are not among its entries, so they sit in a still-unlocated font or table of their own. Not independently confirmed frame-by-frame the way `svc-2` was above; still open. |

**`boot-setting-country` never shows
text**, in either language (3 scenes each, all empty; `dmd/en/screens.csv` ids 5-7). Its
representative frames are the attract-logo dissolve, not any string — rendered directly,
scenes `0006-boot-setting-country` and `0007-boot-setting-country` show the same dithered
"IO MOON" background as `dmd/en/screens/0008-attract/repr.txt`, pixel for pixel in
kind, not a blank or text screen. `SETTING COUNTRY`/`DEFAULT VALUES` (the second
occurrence, `0x2c8c`) are captured elsewhere in tier 3 (`SETTING COUNTRY` is in the
"captured and decoded" list above) but not against this label — this label's own mark
sits at a moment the walk's normal boot path never actually triggers the
country-mismatch recovery screen the mark was presumably placed to catch. Open; what
would settle it is a capture with the DIP-selected country deliberately mismatched
against the stored NVRAM country at boot (F11), the condition `sub_D664D`'s own override
path exists for. Confirms it is capturable in principle, though: one `svc-root-exit`
scene (menu-exit reboot, not boot) decodes `SETTING COUNTRY / DEFAULT VALUES`
verbatim — the same recovery screen, reached a different way,
not through `boot-setting-country`'s own mark.

### Related open items

- ~~The in-play `PLAYER`/`BALL` font is not in the walked font table~~ **— found and
  decoded.** `BALL`/`EXTRA BALL`/`INSERT COIN`/`PLAYERS`/`PLAYER` (both languages) are
  whole-word bitmaps in a pointer pool at `CS:0522F`-`CS:0523F`, matched on their own lit
  pixels against full brightness rather than by exact bitmap (`docs/dmd_graphics.md`,
  "The in-play PLAYER/BALL HUD..."; `scripts/dmd_dump_split.py`'s `_scan_words`). Every
  `ball-N-*`/`score-ball-N-*` scene's `text` now carries these words where they are
  genuinely on screen; the tier-3 gameplay strings above that were attributed to this
  gap have been re-checked against the fixed decoder (see "Every missing string, grouped
  and explained").
- **Which face draws the main in-play score is found too**: a headerless digit table at
  `CS:052BB`, not the walked `(h=23, W=2)` face (still ruled out, unchanged — zero exact
  matches across 27,712 raw frames). See `docs/dmd_graphics.md`, "The in-play score
  digit table is headerless...". Consecutive digits overlap on screen (a plain-overwrite
  draw order), so only some digits of a longer number are recovered — see the Numbers
  section for the measured effect. Digit `1` (a decimal-point sentinel occupies its
  table slot) and a second, alternating drawing path (`CS:052BF`) remain open; what
  would settle each is in `docs/dmd_graphics.md`'s own Open items.
