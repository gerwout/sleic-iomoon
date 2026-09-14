# DMD Screen Corpus — Index and Coverage

[← Back to main README](../README.md)

Three captures of `iomoont` (the PRESS START tournament ROM) make up the corpus: an
English walk (`dmd/en/`), a Spanish walk (`dmd/es/`), and eight targeted fault captures
(`dmd/faults/`). `dmd/README.md` and `dmd/faults/README.md` are the narrative account of
how each was produced and what each one found along the way; this document is the index
— what screen is where — and the coverage gate: which of the ROM's own strings the three
captures together do and do not put on screen, and why.

| Corpus | Scene occurrences | Distinct screens | Labels |
|---|---|---|---|
| `dmd/en/` | 5683 | 909 | 118 |
| `dmd/es/` | 5411 | 824 | 52 |
| `dmd/faults/` (8 captures) | 178 | 159 | 7 labels, shared across captures (`unlabelled`, `boot`, `credit`, `ball-1-start`, `tilt-1`, `tilt-2`, `settle`) — a fault's own text rides on one of these, not a fault-named label of its own |

"Scene occurrences" counts every visit the walk makes; "distinct screens" counts unique
`repr.txt` content — the number that answers "how many screens does this machine draw."
The Spanish corpus has no service-menu tree: F19 establishes that opening the menu
re-derives the machine's tracked country from a stray byte and gets it wrong in every
country, unconditionally landing on country 7 (Portugal) — so a Spanish menu capture
would show Portugal's strings under a Spanish label, not Spain's. `dmd/README.md`'s own
Spanish section has the full trace.

## File format

One row per scene occurrence in `<lang>/screens.csv`:

```
id,label,dir,first_ms,last_ms,frames,text,repr_id
```

Worked example (`dmd/en/screens.csv`):

```
id=5461, label=svc-35-close, dir=5461-svc-35-close, first_ms=1962050,
last_ms=1962083, frames=2, text="SOUND/VIDEO / GAME / TECHNICAL", repr_id=5382
```

`text` is the on-screen text decoded from the scene's last frame, one segment per
matched font face and screen row, joined `' / '` (`decode_text`,
`scripts/dmd_dump_split.py`) — here the h=9 face reads the menu root's own three
item lines on one row each. `repr_id` (5382) differs from `id` (5461): this
occurrence's last frame is pixel-identical to an earlier scene's (`5382`, label
`svc-0`, closing back out to the same root-menu screen), so no `repr.txt` was written
under `5461-svc-35-close/` — only `frame-*.txt` (not committed) — and the actual bytes
live at `dmd/en/screens/5382-svc-0/repr.txt`. Looking up a scene's real content is
always "read the row whose `id` equals this row's `repr_id`, then read *that* row's
`dir`" — true whether or not the row in hand is the canonical one.

## Directory layout

```
dmd/
├── README.md                    # capture method, build/commit info, per-corpus narrative
├── en/
│   ├── iomoont.txt               # raw frame dump (Serum/Pin2DMD format, timestamped)
│   ├── iomoont.marks             # key script's (frame, ms, label) sidecar
│   ├── screens.csv               # one row per scene occurrence (see above)
│   └── screens/<NNNN-label>/
│       ├── repr.txt              # one committed frame per distinct screen
│       └── frame-*.txt           # every raw frame of the scene (gitignored, regenerable)
├── es/                          # same layout, no service-menu tree (F19)
└── faults/
    ├── README.md                 # which probe forced each of the 8 captures
    └── <fault>/                  # same iomoont.txt / iomoont.marks / screens.csv / screens/ layout
```

## Regenerating

Split one dump (needs the raw dump + marks sidecar, both committed; `--rom` is optional
but needed for the `text` column):

```bash
cd sleic-iomoon
python3 scripts/dmd_dump_split.py dmd/en/iomoont.txt --out /tmp/regen \
        --marks dmd/en/iomoont.marks --rom ../pinmame/roms/iomoon/v1_3_01.bin
diff <(cut -d, -f1,2,6 /tmp/regen/screens.csv) <(cut -d, -f1,2,6 dmd/en/screens.csv) \
  && echo "regeneration reproduces the corpus"
```

Verified for this document: `27198 frames -> 5683 scene occurrences, 909 distinct
screens`, and the diff prints nothing but `regeneration reproduces the corpus`. The same
two commands, with `es`/`faults/<fault>` in place of `en`, regenerate those.

Capturing a dump in the first place (build, commit, exact invocation) is `dmd/README.md`'s
job, not this document's — see its "PinMAME build and capture" section.

## Screen index, by area

Full per-row detail is `screens.csv` itself; this groups the corpus's 118 (`en`) / 52
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
| `attract-again` | 111/110 | 74/74 | same idle cycle, reached after a game instead of from boot |
| `lottery` | 15/15 | 9/9 | `00` (h=12 tile-bar noise, not real text — see Coverage) |
| `credit` | 7/7 | 6/6 | empty |
| `press-start-normal` | 3/3 | 3/3 | empty |
| `score-attract-again` (same idle cycle, second game) | 149/172 | 86/76 | `S.` |
| `score-credit` (same as `credit`, second game) | 5/6 | 5/6 | empty |
| `score-lottery` (same as `lottery`, second game) | 8/6 | 8/6 | empty |

### Game

| Label | Occ (en/es) | Distinct (en/es) | Example text |
|---|---|---|---|
| `ball-N-start` (N=1-3) | 45/45 | 45/45 | empty |
| `score-start` (the second game's own START-to-ball-1 transition, following `score-credit`) | 46/46 | 46/46 | empty |
| `ball-N-in-play` | 67/67 | 42/42 | `3. 8.743` (the small `h=12` digit face; F13, `docs/dmd_graphics.md`) |
| `ball-N-drained` | 92/92 | 92/92 | empty |
| `drop-bank-N-down` | 12/12 | 12/12 | `3. 5. 8` |
| `score-ball-N-in-play` | 4480/4478 | 341/337 | empty — the second, high-score-qualifying game's own play, same mechanics |
| `score-ball-N-drained` | 90/90 | 90/90 | empty |
| `score-recover-*` (4 labels: `drained`, `hits`, `plunge`, `wait` — the awarded extra ball) | 25/24 | 24/23 | `N N` (recovery-ball hit counter, `h=12`) |

Every `ball-N-in-play`/`ball-N-drained`/`ball-N-start` scene shows `PLAYER 1` and `BALL 1`
on screen in a small, single-pixel-stroke face; that font is not in the walked glyph
table (`docs/dmd_graphics.md`, "Open items"; carried forward from Task 15b), so these
labels' `text` is empty or partial by construction, not because the screen is missing.

### End of game

| Label | Occ (en/es) | Distinct (en/es) | Example text |
|---|---|---|---|
| `ball-3-drained-gameover` | 11/11 | 10/10 | `PRESS START` |
| `high-score-entry` | 7/7 | 6/6 | empty |
| `wheel-cN-*` (12 label families — `fixed`/`fwd-00..04`/`refwd-00..03`/`erase-*` — across wheels 1-3, 17 raw labels) | 20/19 | matches occ (each a distinct redraw) | `N N / 0D` (the selected character plus its wheel position) |
| `score-post-entry-wait` (holds after fixing the last initial, before returning to attract) | 3/18 | 3/7 | empty |
| `score-ball-3-drained-gameover` (same as `ball-3-drained-gameover`, second game) | 43/42 | 43/42 | empty |
| `score-high-score-entry` (same as `high-score-entry`, second game) | 1/1 | 1/1 | `N N` |

The initials wheel-walk (`docs/iomoon_game_rules.md` 4.2) is captured in full, including
one erase-symbol demonstration (`wheel-c3-erase-symbol`/`wheel-c3-erase-tried`), with the
selected character changing at every marked step per `dmd/README.md`'s own account.

### Service menu (`en` only — F19)

| Label | Occ | Distinct | Example text |
|---|---|---|---|
| `svc-0` .. `svc-37` (38 records) | 139 | 76 | `SOUND/VIDEO / GAME / TECHNICAL` (record 0 only); every deeper record shows the `h=12` tile-glyph-bar artifact or nothing — see Coverage |
| `svc-N-close` | 84 | 44 | same root-menu text, on backing out |
| `back-to-N` | 31 | 31 | `VOLUME / CUSTOM MESSAGE` (record 1's own two lines, on one back-out path) |
| `reopen-for-svc-N` | 48 | 15 | empty (transient re-entry frames; F19's own re-entry marks) |
| `svc-menu-done` | 20 | 20 | empty |
| `svc-menu-final-close` | 72 | 38 | `--` (h=12 tile-bar noise) |
| `svc-root-exit` | 3 | 3 | `GAME / TECHNICAL` (stale root-record fragment) |

Every one of the 38 records has at least one captured scene; only the root (record 0) and
its first child (record 1) decode legible static item text. See Coverage, "the menu
tree's own item text mostly doesn't render in this walk's dwell," for why and what would
recover the rest.

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
length-prefixed strings between `0x17a8` and `0x2eaa` — a number that "would come out
flatteringly high and mean nothing" (this task's own ruling file). This tool instead
names strings in three tiers, most to least certain about what ROM data a string actually
is:

1. **`contact_table()`/`menu_records()`** — a string reached through a resolved pointer
   (F14 the 38-record menu tree, F16 the switch/cabinet names), both languages.
2. **`ENGLISH_POOL`/`SPANISH_POOL`** — the two windows `iomoon_strings.py` declares.
   `ENGLISH_POOL` is now the verified full envelope of tier 1's own two English tables
   (Task 15b), so in practice it adds nothing tier 1 didn't already reach; `SPANISH_POOL`
   stays a narrower, verified-clean sub-window.
3. **Everything else** a flat length-prefixed byte sweep finds in the ROM's whole string
   area, `0x17a8`-`0x2eaa` (one byte short of this task's ruling file's own approximate
   `0x2ebc`: a sweep that wide catches one zero-padding run right after the ROM's last
   real string, `FABRICA DE PAIS` at `0x2e99`, that a byte-level sweep otherwise misreads
   as a string). These are real ROM strings with no pointer table pinned down yet — the
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

### Numbers

| | Count |
|---|---|
| Strings named (tier 1 / tier 2 / tier 3) | 275 / 0 / 166 = 441 |
| Present (whole-field match, any of the three corpora) | 27 |
| Missing | 414 |

Tier 2 contributes zero *additional* strings once tier 1 is already counted — every
`ENGLISH_POOL`/`SPANISH_POOL` entry is also reachable through `contact_table()` or
`menu_records()` (or is the same string at a one-byte-different offset, folded together
by the whole-field normalization). This is expected, not a bug: it is exactly what Task
15b's fix to `ENGLISH_POOL` set out to do.

**This is not "94% missing."** A string being "named" only means `iomoon_strings.py` can
point at its ROM bytes; "missing" here means *not decoded as a whole field in any
captured scene's representative frame* — which, per the in-play font and the
menu-tree-dwell finding below, is dominated by decoder and capture-timing gaps on
screens the corpus already contains, not by screens it never drew. The rest of this
section is the actual answer: every missing string, grouped, with a citation and a
disposition.

### What is captured and decoded

27 strings match cleanly:

- **Menu chrome (tier 1, English only):** the root record's three items
  (`SOUND/VIDEO`, `GAME`, `TECHNICAL`) and its first child's two
  (`VOLUME`, `CUSTOM MESSAGE`).
- **One contact name (tier 1):** `L.C.FLIPPER` — not from the CONTACTOS test screen, but
  from the `flipper-broken` fault screen, which happens to show the same name.
- **21 tier-3 strings**, all from `dmd/faults/` plus `dmd/en/`'s own boot scenes:
  `GROUP: T17-18-19`, `FUSE F4` (the one coil group and fuse the `solenoid-cut` probe
  exercises), `BALL OUT ERROR`, `BALL MISSING`, `BALLS OK`, `WARNING`, `ONE TILT`,
  `TWO TILTS`, `SEPARATE/BROKEN`, `EEPROM FAILURE`, `SETTING`, `DEFAULT VALUES`,
  `PRESS START`, `SHORT`, `CANNOT CONTINUE`, `WRONG BIOS`, `CUT OR`, `WAITING FOR`,
  `8 BITS CPU`, `SETTING COUNTRY`, `BOLAS OK`.

`PRESS START`/`SETTING`/`DEFAULT VALUES` are in this list: this task's ruling file
corrects the brief's framing of `PRESS START` as "in neither ROM string pool" — it is
real string-pool data at `0x2a1f` (`SETTING` `0x2a08`, `DEFAULT VALUES` `0x2a10`), merely
outside `ENGLISH_POOL`'s narrow window, and tier 3's sweep names it like any other pool
string. It is confirmed captured: `dmd/en/screens.csv` scene 2 and seven of the eight
`dmd/faults/*` captures' own scene 2 (all but `tilt`, whose NVRAM is pre-patched per its
own key script's header — F10, so the recoverable first-check this screen belongs to may
not trigger there at all) decode `SETTING / DEFAULT VALUES / PRESS START` verbatim.
Whether the tournament mod's code cave *additionally* rebuilds its own copy of
this text at run time from `MOV AL,<glyph>` immediates (the brief's original Step 2) is a
separate, open question this task's ruling file explicitly does not resolve either way
from these three strings' pool membership — it bears on the patch's own implementation
(`docs/press_start_patch.md`), not on whether this string is covered by the corpus, which
it now demonstrably is.

### Every missing string, grouped and explained

**Tier 1 — 269 missing.** No individual disposition per string; two mechanisms account
for all of them.

1. **F16 switch/cabinet names, 90 missing (`contact_table()`, English + Spanish, shared
   text deduplicated once).** These render only on the live CONTACTOS/SWITCH TEST screen
   (record 26's child, `svc-32`; F14) when an actual matrix switch closes during the test
   — confirmed by inspection: `svc-32`'s own scenes decode empty or noise
   (`'--'`/`'TEC'`) across every occurrence, never a contact name. Neither walk closes a
   playfield switch while inside this screen. **Capture gap:** extend
   `scripts/keyscripts/iomoon-en.keys` (or a probe using `SLEIC_INJECT_COL`/
   `SLEIC_INJECT_BIT`) to trigger a few matrix switches while `svc-32` is open. Spanish
   names are additionally gated by F19 (below).

2. **The 38-record menu tree's own item/title prose, 179 missing (`menu_records()`,
   English + Spanish).** Every record has a captured scene, but beyond the root and its
   first child, the representative frame shows the `h=12` tile-glyph-bar level indicator
   (`dmd/README.md`'s own "Open items", carried forward from Task 15b) or nothing —
   never the record's own static list. Checked directly: `svc-2`'s entire scene (all 4
   raw frames, its full 167 ms dwell — `dmd/en/iomoont.txt` between `ms=1794016` and
   `ms=1794183`) decodes `AA8`/`AA9`/`AA`/`AAA` throughout, the tile-bar's own growing
   count, with no trace of record 2's real lines (`LOWEST SCORE`/`BALLS`/`EXTRA
   BALLS`/`AWARDS`) at any point. This is consistent with a **capture-timing gap**, not a
   font or content limit: the key script advances through the tree fast enough that only
   the two shallowest records (visited longest, since the walk pauses there before
   diving deeper) get enough dwell for the item list to settle before the next mark cuts
   the scene. **What would recover it:** a script that pauses briefly at each of the
   remaining 36 records before advancing, checked frame-by-frame the way `svc-2` was
   checked here. Spot-checked on one record only (`svc-2`); not verified on the other 35.
   Spanish is additionally gated by F19: the corpus never opens the Spanish menu at all
   (below).

**Tier 3 — 145 missing.** Ten groups; every one of the 145 strings is a member of exactly
one.

| Group | Count | Members | Disposition |
|---|---|---|---|
| English coil-group names | 20 | `GROUP: T29-30` .. `GROUP: TA3-B3-C3` (`T17-18-19` already captured) | **Capture gap.** Shown one at a time on the SOLENOID TEST screen (`svc-24`) by a `SOLEN. NUM.` entry (F14) or the fault probe's own direct-input code (`dmd/faults/README.md`, `0x50`-`0x64`); this walk and the fault probes exercise only `T17-18-19`. Extending the fault probe's own injected code across `0x50`-`0x64` would recover the rest. |
| Spanish coil-group names | 21 | `GRUPO: T17-18-19` .. `GRUPO: TA3-B3-C3` | **Capture gap, doubly gated.** Same mechanism as above, plus F19 below (no Spanish service-menu tree) and the fault corpus running under the English/default country throughout. |
| English fuse names | 14 | `FUSE F5`..`F26` (`F4` already captured) | **Capture gap.** Same SOLENOID TEST screen, its fuse-cycling phase; only `F4` was exercised. |
| Spanish fuse names | 15 | `FUSIBLE F4`..`F26` | **Capture gap, doubly gated**, same as the Spanish coil-group row. |
| English SOLENOID/LIGHT/SEND-REC test chrome | 13 | `YES`, `NO`, `FLASH: FL`, `SEND`, `RECEIVE`, `CONTROLLED L.`, `FIXED LIGHTS`, `FLASHES`, `FUSES TEST`, `FUSES END`, `SOLENOID ERROR`, `PRESS TEST`, `SOLENOID FAIL` | **Twelve are a capture gap** (same family as the coil/fuse names — the LIGHT TEST 1/2/3 and SEND-REC TEST leaf screens, `svc-33`/`35`/`36`/`37`, decode empty on every occurrence in `dmd/en/`, confirmed by direct inspection of their `screens.csv` rows). **`SOLENOID FAIL` is a decoder limit, not a capture gap** — `dmd/faults/README.md`'s own "Decoding notes" confirms it by hand: the string sits at rows 0-6 with its own top row clipped past the panel's row 0, and padding the missing row and matching against `iomoon_strings.glyph_bitmaps()` reproduces the ROM's bitmap byte for byte. It is on screen in both `solenoid-short` and `solenoid-cut`; `_scan_face`'s fixed-stride scan cannot recover a line that starts before row 0. |
| Spanish SOLENOID/LIGHT/SEND-REC test chrome | 11 | `SI`, `ENVIA`, `RECIBE`, `L. CONTROLADAS`, `LUCES FIJAS`, `TEST FUSIBLES`, `FIN FUSIBLES`, `ERROR BOBINAS`, `PULSE TEST`, `PONIENDO VALORES`, `FABRICA DE PAIS` | **Capture gap, doubly gated** — same leaf-screen-content gap as the English row, plus no Spanish service-menu tree (F19). |
| Per-country CREDITS denominations (English) | 20 | `OF 1OF CRED:`, `OF 5DM CRED:`, `OF 2ML CRED:`, `OF 20K CRED:`, `OF 50F CRED:`, `OF 200 CRED:`, `OF 50E CRED:`, … (every English denomination row except the Netherlands' own `OF 10`/`OF 50`/`OF 1PD CRED:`, which are tier 1 and also missing — see above) | **Unreachable under this corpus, not dead code.** F11: `sub_D69CC` applies a country's coin preset from a seven-way table (`D5D01`); this is that same per-country selection surfacing in the CREDITS page's own label text. The corpus runs exactly two countries (4, Netherlands; 5, Spain — the latter using `DE X CRED:` labels via `menu_records()`, itself missing, tier 1). **What would settle it:** capturing `svc-23` under each of the other five country DIP settings (F11's own table: 0 United Kingdom, 1 France, 2 Germany, 3 Italy, 6 Belgium, 7 Portugal — the corpus already covers 4 Netherlands and 5 Spain) — undertaken only if a reason to trust the per-country coin presets specifically (not general coverage) calls for it. |
| Spanish fault/boot messages | 17 | `FALLO MEM. CPU8`, `ERROR SAL. BOLAS`, `FALTAN BOLAS`, `ATENCION`, `UNA FALTA`, `DOS FALTAS`, `SEPARADO O ROTO`, `FALLO EEPROM`, `ESTABLECIENDO`, `VALORES FABRICA`, `PULSE START`, `FALLO BOBINA`, `EN CORTO`, `IMPOSIBLE SEGUIR`, `CORTADOS O`, `ESPERANDO`, `CPU 8 BITS` | **Capture gap.** These are the Spanish-language counterparts of the twelve strings `dmd/faults/README.md` already captures in English; every fault probe in that corpus ran under the default (English) country. Extending each `SLEIC_FORCE_FAULT` capture with the Spanish `iomoont-spain.cfg` (`dmd/README.md`'s own Spanish-corpus method) would recover these, exactly the way `dmd/es/` reused `dmd/en/`'s own game section under Spain's cfg. |
| Trough/ball-serve status | 8 | `SACA BOLA 1`, `SACA BOLA 2`, `SACA BOLA 3`, `UNA BOLA`, `DOS BOLAS`, `TRES BOLAS`, `SALIDA BOLAS`, `JUPITER` | **Unreachable under this corpus's simulator setup, not dead code.** This is F15's ball-serve/search status text (commands `0xE9`/`0xEF`), shown while balls are actively being ejected from the trough one at a time. `iomoont`'s registered simulator seeds a full trough by default (`SLEIC2_SIM_INPUT_PORTS_START`), so the multi-ball serve sequence this text narrates never runs during an ordinary boot. **What would settle it:** a probe holding the trough short by one or more balls at boot (the same technique `dmd/faults/ball-missing` already uses, extended to a *partial* rather than fully-empty trough) and capturing the resulting serve sequence. |
| Gameplay feature-progress hints (English + Spanish) | 6 | `ORBITS LEFT TO`, `TARGETS LEFT TO`, `LIT EXTRA BALL`; `ORBITAS PARA`, `DIANAS PARA`, `LUZ BOLA EXTRA` | **Decoder limit, not a capture gap.** `dmd/en/`'s own walk exercises both the orbit lane and the drop-target bank (`dmd/README.md`'s English-corpus description), so these progress messages plausibly did render during the captured game. They are gameplay-only text, the same screen class documented as unreadable in `docs/dmd_graphics.md`'s "Open items" — the in-play `PLAYER`/`BALL` font is not in the walked glyph table, and this message class is drawn during the same gameplay state. Not independently confirmed frame-by-frame the way `svc-2` was above; carried forward as the same open item, not re-measured. |

One more open item this task's own check surfaced: **`boot-setting-country` never shows
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
path exists for.

### Carried forward from Task 15b, not re-measured

- **The in-play `PLAYER`/`BALL` font is not in the walked font table** — confirmed by
  three search forms across both ROMs, none finding it. Every `ball-N-*` scene's `text`
  is empty or partial as a direct result; this is why so many tier-3 gameplay strings
  above read as "missing" when the screen itself is captured. `docs/dmd_graphics.md`,
  "Open items," has the full account and what would settle it.
- **Which face draws the main in-play score is open**, and the `(h=23, W=2)` face is
  ruled out for it (zero exact matches across 11,723 raw frames). Not a coverage
  question directly (no ROM *string* names the score), but the same open item.
