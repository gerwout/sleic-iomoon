# DMD screen corpus

Per-language captures of every screen the IO Moon DMD draws, produced by driving
`build/sdl3pinmame` headlessly with a `-key_script` and splitting the resulting
frame dump with `scripts/dmd_dump_split.py`. See
`scripts/keyscripts/iomoon-en.keys` for the exact walk and its own header
comment for what it covers and what it found running against the real binary.
See `docs/iomoon_dmd_screens.md` for the screen-by-screen index and the
coverage report against the ROM's own string data.

## PinMAME build and capture

Every capture in this corpus (`en/`, `es/`, and `faults/`) is built against
`pinmame` commit `ea634848` ("sleic: wire Io Moon's DMD path into the
frame-dump hook"), branch `iomoon-sim` — the commit that first wires
`-dmd_dump_dir` into Io Moon's own frame-submit path, checked out clean
(`git status --short src/wpc/sleic.c` empty) for `en/` and `es/`; `faults/`
additionally needs the throwaway probes `dmd/faults/README.md` cites per
fault, reverted immediately after.

```bash
cd pinmame
cp cmake/sdl3pinmame/CMakeLists.txt CMakeLists.txt
cmake -DPLATFORM=linux -DARCH=x64 -DCMAKE_BUILD_TYPE=Release -B build
cmake --build build -j$(nproc)

SDL_VIDEODRIVER=dummy SDL_AUDIODRIVER=dummy ./build/sdl3pinmame iomoont \
  -rompath ./roms -nvram_directory /tmp/nv -nosound \
  -skip_disclaimer -skip_gameinfo -skip_gamewarnings -nothrottle -ftr 400000 \
  -dmd_dump_dir ../sleic-iomoon/dmd/en \
  -key_script ../sleic-iomoon/scripts/keyscripts/iomoon-en.keys
```

`es/` is the same invocation with `dmd/es` and `iomoon-es.keys`, run after
copying `scripts/keyscripts/iomoont-spain.cfg` to `<cfg dir>/iomoont.cfg`
(country 5; see the Spanish-corpus section below for why a saved cfg, not a
live DIP sequence, is what sets it). `faults/`'s own per-fault commands,
probes and scripts are `dmd/faults/README.md`'s "Reproducing a capture"
section, not repeated here.

`<lang>/<romset>.txt` is the artefact with downstream value: it is the exact
input `SortingCDump`/`ColorizingDMD` and the Pin2DMD editor read (byte-exact
Serum/Pin2DMD format, per-frame timestamps, no PinMAME-specific framing).
Everything else in this directory — `screens.csv`, `screens/*/repr.txt`,
`screens/*/frame-*.txt` — is derived from that one file (plus its `.marks`
sidecar) by `scripts/dmd_dump_split.py` and is regenerable from it; see
`docs/iomoon_dmd_screens.md`'s "Regenerating" for the exact commands.

## Layout

- `<lang>/<romset>.txt` — the raw frame dump, byte-exact Serum/Pin2DMD format
  with per-frame timestamps. This is the artefact with downstream value.
- `<lang>/<romset>.marks` — the key script's mark sidecar (frame, ms, label).
- `<lang>/screens.csv` — one row per **scene occurrence**: id, label, dir,
  first/last ms, frame count, the on-screen text decoded from the ROM's own
  font (`--rom`, where the h=9 face covers it), and `repr_id`, the id of the
  scene whose directory holds this occurrence's actual representative
  frame (see the next item). Every occurrence gets a row; occurrences are
  not the same count as distinct screens — see below.
- `<lang>/screens/<NNNN-label>/repr.txt` — one representative frame (the
  scene's last) **per distinct content**, not per occurrence: many
  occurrences show pixel-for-pixel the same frame as an earlier one (an
  idle attract frame the loop revisits, a menu record with no leaf under
  it, the settled tail of an animation), and `dmd_dump_split.py` writes the
  bytes only under the first scene, in dump order, to show that content —
  every later occurrence of the same content has no `repr.txt` of its own
  and points at that scene's id through its own row's `repr_id` instead.
  Committed.
- `<lang>/screens/<NNNN-label>/frame-*.txt` — every raw frame of the scene.
  Not committed (`.gitignore`); regenerate with `dmd_dump_split.py` from the
  committed raw dump, which carries the timestamps a scene needs to be
  re-sliced.

## English corpus (`en/`), captured against `iomoont`

`iomoont` is the PRESS START tournament MOD (country 4, Netherlands, English
by DIP default — F11). The walk covers boot, a full attract cycle, coin and
credit, then two games and the entire 38-record service-menu tree. The
first game is the original feature-coverage game (both ramps, the orbit
lane, all five bumpers twice round, both bull's-eyes, the drop bank to
2/4/5 targets, the inner bank, both holes, Jupiter's lock twice for
multiball, two tilt warnings to a full tilt) at an ordinary, non-qualifying
score; the second (its labels prefixed `score-`) plays purely to clear the
high-score bar and walk the initials wheel (three balls of lane hits, the
awarded extra ball drained for real, then the RECORD INSCRIPTION screen).
Both games end at the mod's own PRESS START screen at the normal
end-of-game hook (`D5123`).

`screens.csv` lists **5716 scene occurrences** across the walk, covering
**922 distinct screens** (repr.txt contents) under **118 labels** — the
second number is the one that answers "how many screens does this machine
draw"; the first counts how many times the walk visited one.

**A limitation found after the fact, and it is this corpus's, not
Spanish-only.** F19 (`asm/baseline-2026-09/findings.md`) establishes that
exiting the service menu re-derives the machine's tracked country from a
stray byte and gets it wrong in **every** country, not only Spain — the
byte it wrongly accepts decodes to country 7 (Portugal) regardless of
which country was actually running. This walk's own key script exits and
re-enters the menu several times over its 38-record traversal (its
`reopen-for-svc-N` marks, the first at script frame 116400, are exactly
those re-entries), so at least the later part of the service-menu section
here was almost certainly captured at country 7, not the Netherlands'
country 4 the run started at — invisible in the decoded text, since both
render in English, but not invisible everywhere: menu record 23 (CREDITS)
renders the **live coin-pricing table**, which differs by country (F11),
so that page, wherever it falls after the first re-entry, shows Portugal's
prices rather than the Netherlands'. Record 23 itself (`svc-23`) is marked
*before* that first re-entry in this walk's own frame order (script frame
115560 against 116400), so which country was in effect for it specifically
turns on exactly which navigation step first makes the menu loop
(`sub_DD2E6`, F14) return — not traced here. It is moot for this one page
regardless: rendered directly, `svc-23`'s own captured frames do not show
legible pricing digits at all (the same `h=12` "growing letter run / level
indicator" artifact already documented under Open items below, not the
settled CREDITS page), so which country's prices they would show, if any
were legible, is unverified either way. What would settle both questions:
tracing which specific key presses in this script make `sub_DD2E6` return
versus stay in its own internal back-navigation (F14), cross-referenced
against these frame timestamps.

## Spanish corpus (`es/`), captured against `iomoont`

Country 5 selects the Spanish string and menu tables (F11: `D3277`,
`D8048`, `DD406`); every other value is English. There is no command-line
DIP option in this build (checked `src/unix/config.c`), so country 5 is
set through a saved MAME cfg, `scripts/keyscripts/iomoont-spain.cfg`
(MAME 0.76's binary `MAMECFG` format), rather than a live DIP-menu
sequence inside `scripts/keyscripts/iomoon-es.keys` itself. To reproduce
it: copy that cfg to `<cfg dir>/iomoont.cfg` (`~/.sdl3pinmame/cfg/` by
default) before running the script — `python3 scripts/nvcheck.py
<nvram>/iomoont.nv` should then read country 5 both before and after the
run. The cfg was produced by driving MAME's own Config Menu from a
throwaway key script (`KEYCODE_TAB` opens it; `KEYCODE_DOWN` to "Dip
Switches", `KEYCODE_ENTER` to enter it, `KEYCODE_DOWN` to the "SW40-2/3/4
Country" row, one `KEYCODE_RIGHT` to step Netherlands → Spain, `TAB` to
close), confirmed both via `nvcheck.py` (NVRAM `0x1BF` = 5) and visually
(the boot screen reads `BOLAS OK`, not `BALLS OK`).

**This corpus has both games (the feature-coverage game and the
high-score/wheel-walk game) and no service-menu tree.** The game portion
is `scripts/keyscripts/iomoon-en.keys`'s own game section, replayed
unchanged — same keys, same relative timing — since playfield switch
timing is not language-dependent; only the on-screen text differs, and
the wheel-walk lands on the same score (`233,400,000`) and the same
per-step decoder progression as the English capture. **The Spanish
service-menu tree is not capturable through the menu at all, in
principle, not by bad luck of this capture** — opening the menu flips
the machine's own tracked country to 7 (Portugal) before the first
record renders, in **every** country, regardless of which one was
running. That is a firmware behaviour, not a driver bug and not
something a re-timed key script can route around: see finding F19 in
`asm/baseline-2026-09/findings.md` for the full trace. In short, menu
exit reboots the Z80 (F14), and the rebooting Z80 announces its own
"all inputs idle" byte (`0xFF`) over J1 before the 80188's real
country-DIP query can get an answer; the 80188's wait loop accepts the
first byte `>= 0xF0` it sees as the DIP report (F19), and `0xFF` decodes
to country 7 unconditionally — not to whatever country was actually
selected. Confirmed with `nvcheck.py` reproducing exactly this
(country 5 to 7) across three attempts of decreasing scope, down to a
bare TEST-key open-then-immediately-close with no other key and no
game ever played. Capturing service-menu screens under a country that
has already silently become Portuguese would misrepresent them as
Spanish, so they are left out.

A related, now-resolved finding along the way: reaching country 5 through
the live DIP menu **inside** the same run that then tries to play a game
does not work — ball 1 never registers a single feature hit afterward,
in every combination of coin count and settle time tried. A clean control
(the identical DIP-menu sequence left at the Netherlands default) plays
normally, and reaching country 5 through the saved cfg instead — with the
English script's original coin economy completely unchanged — also plays
normally (a real, climbing score). So the live DIP-menu key sequence
itself, not country 5 and not Spain's coin pricing, is what breaks
gameplay; this is consistent with F15's undocumented-timeout ball-search
deadlock (`DC507` waits forever for command `0xEF`'s reply, satisfied
only by three adjacent trough contacts closed), triggered by whatever the
DIP-menu's own input-port refresh does to the ball simulator's exposed
switches at that moment. Using the cfg instead of the live menu avoids it
entirely, which is what this corpus does.

`screens.csv` lists **5411 scene occurrences**, covering **824 distinct
screens** under **52 labels**. `du -sh dmd/es` is 297M before committing
(90M raw dump), comparable to `en/`'s 351M/108M once the missing
service-menu tail is accounted for — not wildly larger, so nothing here
is looping.

## Parent differential (`iomoont` vs `iomoon`)

The mod differs from the parent (`iomoon`) in 186 bytes of the end-of-game
path only (four patched regions, two hook sites — see
`docs/press_start_patch.md`), so the same key script run against the parent
set should draw the same screens everywhere else. Run both, split both, and
compare **per label**, not as one global unordered set: for every mod-only
representative-frame hash, check whether that same content appears anywhere
in the parent's own scenes carrying the *same* label. That is what actually
tells "same screen, caught a frame apart" apart from "a screen the other
side never draws at all" — an unordered global hash set cannot, since it
would call a genuine divergence and a relabelled coincidence the same thing.

```bash
python3 scripts/dmd_dump_split.py /tmp/parent/iomoon.txt --out /tmp/parent \
        --marks /tmp/parent/iomoon.marks --rom ../pinmame/roms/iomoon/v1_3_01.bin
python3 scripts/dmd_dump_diff.py dmd/en /tmp/parent
```

`scripts/dmd_dump_diff.py` is the comparison tool itself (committed); the
parent dump it reads is not (rebuild it with the two commands above — same
key script, the parent ROM set). See that script's own docstring for what
"per label" does and does not establish; the short version, worth restating
here because the phrase is easy to over-read: **labels are literal mark
strings from the key script that drives both runs, so both sides land on
the same label vocabulary near-automatically, whatever is actually on
screen.** "Every label appears on both sides" confirms both ROMs completed
the same scripted navigation — neither one got stuck or diverged onto a
screen the script has no mark for — it does not by itself confirm the
*content* under a shared label matches.

No mismatch count in this section is current against the `en/` corpus
above: producing one needs a parent capture built with the two commands
above, from the current key script — including its current
record-to-record dwell (Open items, below), which sets the corpus above's
own scene boundaries — and no such capture is committed.

Given the patch touches only the end-of-game path
(`docs/press_start_patch.md`), a mismatch, if any, is expected only under
`PRESS START` and its neighbours (`press-start-normal`,
`ball-3-drained-gameover`, `high-score-entry`, `lottery`, `attract-again`),
the auto-cycling TECNICO tests, and the menu's own `back-to-N` transitions —
not under any GAME or SOUND/VIDEO adjustment page, attract feature-ad
screen, or boot-text label, since the patch does not touch those code
paths. This is a prediction from the patch's scope, not a measured result.
What would settle it: rebuild the parent capture with the two commands
above and run `python3 scripts/dmd_dump_diff.py dmd/en /tmp/parent`
against it, then check every mod-only hash's label against the parent's
own scenes under that label, per the method above.

## Open items

- ~~Two different score displays exist in this game, and only one of them
  decodes~~ **— the in-play display is now identified too, a headerless
  table the walked font table's own reader never reaches.** The
  attract-mode high-score table is the `height=12` face (table offset 75)
  and decodes cleanly: `S.MOONLIGHT / 300.000.000 / . .`, `J.SUNSHINE /
  200.000.000 / . .`, `B.STARWAY / 100.000.000 / . .` (scenes
  51/420/5281/5674, 55/5287, 61/428). The **in-play** score's own digit
  table sits at flat `0x29154` (pointer `CS:052BB`), indexed by digit value
  with a `MUL DX,0x6C` stride read directly out of the drawing routine's own
  loop, not the walked table's `[h,w,len16]` header format at all — see
  `docs/dmd_graphics.md`, "The in-play score digit table is headerless...",
  for the full layout and how it was confirmed (digit `2`'s stored bitmap
  reproduces a real captured frame byte-for-byte). The `(h=23, W=2)` face
  this item used to name as a candidate is ruled out, unchanged from
  before: it never exact-matches a real frame anywhere in this corpus.

  **Measured against the committed corpus, this table's own contribution is
  small: 15 of 645 newly-recovered English scenes and 16 of 642 Spanish
  ones (see the `PLAYER`/`BALL` item below for the total and for the face
  that accounts for nearly all of it).** Consecutive digits in a real
  number overlap on screen (a plain-overwrite draw order; see the doc
  above), so an exact-bitmap matcher only recovers the digit that happens
  to survive a frame's own draw order — usually one, which is why this
  table alone never recovers a multi-digit score, only isolated digits
  (`1`, `2`, ...). Digit `1` is not decoded at all (a sentinel byte, not a
  stored digit, occupies its table slot — see the doc above), and a second,
  alternating drawing path (`CS:052BF`) is not modelled.
- **The `h=12` face is pinned (table offset 75) and now decodes the
  single most valuable text in this corpus: the attract high-score
  table**, beside the h=9 `S.MOONLIGHT`/`J.SUNSHINE`/`B.STARWAY` labels
  already present (see above). It also renders real text on several
  service-menu leaf pages too large for the h=9 face — e.g. `svc-25`
  showing legible "ORBIT FLIP"-style prose at roughly double the h=9 cell
  size — and, through a second, smaller `(12, 1)` digit block at table
  index 183-203, real digit runs from three gameplay scenes:
  `ball-2-in-play` (`3. 8.743`), `drop-bank-2-down` (`3. 5. 8`),
  `drop-bank-4-down` (`: 95`). It also reads `00` on six scenes — four
  (`svc-33`, `svc-34`, `svc-37`, `svc-menu-final-close`) sit at or near the
  free-running lamp/relay counters the auto-cycling TECNICO tests already
  show elsewhere in this document, a plausible source though not
  independently confirmed here; the other two (`lottery`, `attract-again`)
  most likely read part of a larger, still-unidentified digit graphic.

  Scanned over every frame in the corpus rather than just the screens it
  was confirmed against, the same face also produces a **growing letter
  run on `svc-N`/`back-to-N` scenes** — `AA`, `AAD`, `AADC`, `AADCA`,
  `AADCAA`, ..., up to `AADCAAAADAI AE / AACABAAAAB AAB` — that grows by
  exactly one character per scene as the service-menu walk descends. This
  is bitmap-faithful, not noise (rendered directly,
  `dmd/en/screens/5417-svc-16/repr.txt`, it is a row of 13-14 real `h=12`
  glyph shapes over a dim, level-1 bar) and simply is not text: F21
  (`asm/baseline-2026-09/findings.md`) traces the drawing routine
  (`sub_D0AF8`/`sub_D0ACA`) and finds no table read anywhere in it — the bar
  is stamped column by column straight from a loop counter, so a font
  matcher colliding with real glyph shapes at some fill levels is
  coincidence by construction, closed to any matcher, this one or any
  other. A reader of `screens.csv` should expect a growing letter run under
  those two labels and read it as a level indicator, not a word.
- ~~`full-tilt` produces zero scenes~~ **— resolved: a mark-placement issue,
  not a missing capture.** The TILT screen was captured all along —
  `dmd/en/iomoont.txt.gz` holds a frame at ms 171399 (2265 lit pixels, large
  drop-shadowed `TILT` text) — but the key script's own `full-tilt` mark sat
  at ms 175633, 4.2 s later, so this corpus's own "a scene runs from its
  mark to the next" rule folded the TILT frame into the preceding
  `drop-bank-5-down` scene instead. `scripts/keyscripts/iomoon-en.keys` now
  marks `full-tilt` at script frame 10280 (the first tilt-warning key press)
  instead of 10540 (the second, full-tilt-triggering one); a verification
  run confirms the mark now lands at ms 171299, 100 ms *before* the TILT
  frame, and `full-tilt` now covers two scene occurrences, the second
  showing the TILT screen itself. `dmd/en/iomoont.marks` carries the
  corrected mark; the raw dump itself is unchanged, since it already had the
  frame. The Spanish key script (`iomoon-es.keys`) has the identical
  mark-placement bug, unfixed — its own `full-tilt` mark never has a frame
  attached at all in the committed `dmd/es/` corpus (zero rows in
  `screens.csv`), not just a misattributed one.
- **The mod's SPECIAL trampoline (`D5077`) is not exercised.** `PRESS START`
  appears three times in this corpus (the boot seed screen, the normal
  end-of-game hook at `D5123` twice — once per game below); reaching
  `D5077` needs an actual match win, which this walk does not force.

  F10/F11's short-ball "salida nula" replay protection governs a scoring
  ball regardless of how it was awarded: `sub_D368C`, tested at `D31D3`,
  replays any ball — an awarded extra ball included — that scores at or
  below the NVRAM `0x43` threshold (factory 100,000), indistinguishable
  from a player abandoning the ball. A bare plunge immediately followed by
  a drain scores
  exactly zero and loops forever under this rule; it is not specific to
  extra balls (an ordinary drained ball with no score loops identically)
  and it is not a fault in the ball simulator, the driver, or the firmware.

  With that understood, `scripts/keyscripts/iomoon-en.keys` clears the
  lowest high-score preset (50,000,000 at NVRAM `0x85`, F10) with margin —
  three balls of unlit-lane hits land the score around 233,000,000 — and
  gives the awarded recovery ball five diverse real hits (a bumper, a
  bull's-eye, a drop target, a ramp, Jupiter) before draining it, rather
  than a bare plunge-and-drain. Both the qualifying score and the RECORD
  INSCRIPTION entry screen are reached cleanly this way, and the high-score
  wheel-walk (docs/iomoon_game_rules.md 4.2: right flipper forward, left
  flipper backward, START fixes the character shown) is captured in
  full — `score-high-score-entry` through `wheel-c3-fixed` in
  `screens.csv`, including one erase-symbol demonstration
  (`wheel-c3-erase-symbol` /
  `wheel-c3-erase-tried`) — with the selected character changing at every
  single marked step, confirmed against the current `h=12` decoder rather
  than assumed from the key presses alone.

  What is still open is the match itself: neither the ordinary,
  non-qualifying game played first nor the qualifying one played second in
  this same capture shows a distinct match/lottery screen in the window
  after their own `PRESS START` — both go straight back into the normal
  attract cycle (S. MOONLIGHT / J.SUNSHINE / ...), not a match digit or a
  third, differently reached `PRESS START`. Reaching `D5077` needs an
  actual match win, i.e. the score's last digit landing on whatever this
  walk's fixed key sequence deterministically draws, and this walk does
  not aim for that.
  What would settle it: tracing the match check itself with a `-debug`
  build (there is no probe for it among the `DEBUG_SLEIC` set) rather than
  searching for a lucky score/timing combination by hand.
- **The pre-credit `attract` section and the post-game `attract-again`
  section are the same content, at different lengths.** `attract-again` (the
  post-game return to idle) already runs long enough to show the attract
  cycle's own feature-ad screens (`S.MOONLIGHT`, `J.SUNSHINE`,
  `B.STARWAY`, ...); `attract` itself runs long enough to approximate a
  fuller cycle, but a single continuous "one full loop, start to repeat"
  boundary is not identified either place.
- ~~The in-play `PLAYER`/`BALL` font is not in the walked font table~~
  **— found: a five-word pointer pool, not a code+offset face.** `BALL`,
  `EXTRA BALL`, `INSERT COIN`, `PLAYERS` and `PLAYER` (both languages) are
  whole-word bitmaps read through hard-coded far pointers at
  `CS:0522F`-`CS:0523F` (`docs/dmd_graphics.md`, "The in-play PLAYER/BALL
  HUD is a pointer pool of whole words, not a walked table"), confirmed both
  by reading the letters directly off each bitmap and by the `LES
  SI,CS:xxxx` operand at every drawing routine's own call site. Validated
  directly against the raw capture: searching every per-ms frame of scene
  `0198-ball-1-in-play` finds exact `PLAYER` matches on 9 frames and exact
  `BALL` matches on 10 more, alternating — the documented flash behaviour.

  **An exact bitmap match against this table recovers zero scenes in the
  committed corpus, but the cause is the stored word's own blank margins,
  not blink timing.** The first cut of this decoder matched the whole
  stored cell — `PLAYER`'s own bitmap is 8 rows x 40 px, lit only at rows
  1-6, columns 4-32 — against the frame exactly, requiring every blank
  margin pixel to also read blank on screen. It never does: those margins
  fall over the panel's own dithered background, so an exact match finds
  `PLAYER`/`BALL` nowhere in either corpus even on a frame that shows both
  words plainly (rendering `dmd/en/screens/0198-ball-1-in-play`'s own raw
  per-ms frames confirms both on screen, simultaneously, on 44 of 46 of
  them — not alternating, the flash-timing explanation this item
  previously gave, which was itself an artifact of the same exact-match
  bug: two words each needing their own margins clean in the same frame at
  once is a much rarer coincidence than either alone).

  **Fixed by matching only the word's own lit pixels, at full brightness,
  and treating everything else as don't-care** (`scripts/dmd_dump_split.py`'s
  `_scan_words`) — the stored bitmap's `1` pixels must read level 3 in the
  frame; its `0` pixels are unconstrained. Doing that naively over-matches a
  different way: a large, solid, near-uniformly-bright graphic (a
  bonus-multiplier blob, an animation frame) satisfies almost any sparse
  word mask trivially. Caught on `score-recover-hits`, where `BALL` and
  `BOLA` both fired against such a graphic with no real word anywhere near
  it, alongside a genuine `BALL` match elsewhere on the same frame — the
  fix adds a second requirement, that no more than 20% of the word's own
  *blank* pixels may also read level 3 (measured 0-3% on confirmed real
  matches, 73-77% on the false positive above; not a close call). Checked
  across every resulting match in both corpora: every one falls under a
  gameplay label (`ball-N-*`, `score-ball-N-*`, `score-recover-*`,
  `score-start`, `drop-bank-N-down`) and none under an implausible one.

  **Measured against the committed corpus with the fix applied: 645 of the
  5716 English scene occurrences that previously decoded empty now do (548
  of 922 distinct screens), and 642 of 5411 Spanish (544 of 824
  distinct).** `hud_message_bitmaps()` alone accounts for 642 of the 645
  English recoveries and 639 of the 642 Spanish ones; the rest come from
  the player/ball-number digit (`CS:0531B`) or the score table above,
  sometimes alongside a HUD word on the same row — this is the combined
  total the score item above points to. No previously-decoded cell changed
  non-additively in either corpus — checked against both the immediately
  preceding commit and the corpus as it stood before this whole item was
  opened.
- **The 38-record service-menu tree's own item/title text mostly doesn't
  render.** Beyond the root record and its first child, every deeper
  `svc-N`/`back-to-N` scene shows the `h=12` tile-glyph-bar level indicator
  (above) or nothing, never the record's own static list, at the current
  ~3000-frame record-to-record dwell (each ordinary transition holds a
  scene until the next mark, on the reasoning that a scene's representative
  is whatever stands last in that window — the same mark-alignment rule
  used elsewhere in this corpus). Dwell length is not the general cause:
  root and record 1 already capture correctly; of the other 36, only
  `svc-35` (one of the auto-cycling LIGHT TEST records) shows content
  beyond the tile-bar — a legible dynamic readout, `LIGHT: LC10` — and that
  is a sample of its own running test landing inside the capture window,
  not the record's own static item name. `svc-2`'s own scene decodes the
  identical tile-bar pattern at 167 ms into the record as at the full
  ~3000-frame window, which points to the tile-bar being the stable,
  fully-drawn state at this depth, not a transitional one a longer wait
  would resolve into real text.

  **A raw-pixel comparison for three of these records settles part of this
  (F20).** `svc-33` (SEND-REC TEST), `svc-36` (LIGHT
  TEST 2) and `svc-37` (LIGHT TEST 3) are confirmed showing, as their real
  settled or mid-redraw content, a complete 128x32 picture stored in ROM1
  in the exact entry format the walked font table itself uses (header at
  `0x24EA4`), not text composed from glyphs — `docs/dmd_graphics.md`, "Full-
  screen images outside the walked table use the same entry format (F20)".
  No font-based decoder can recover a string from a page drawn this way; it
  is a third, distinct class from "not yet captured" and from "captured but
  in an unlocated font." `svc-24` (SOLENOID TEST) is not part of this
  answer — it shows no new content of any kind, image or text, across all
  five of its occurrences even after the 25x dwell, so its own mechanism
  stays open. Whether the tile-bar depth records (`svc-2` and others) are
  *also* full-screen images, rather than the tile bar being their genuine
  drawn content, is not established either way.

  `docs/iomoon_dmd_screens.md`'s Coverage section has the current breakdown,
  including the F16 switch/cabinet names (a separate gap: they render only
  on the live CONTACTOS/SWITCH TEST screen when an actual matrix switch
  closes, which this walk never triggers).
- **`boot-setting-country` never shows text**, in either language. Its
  three scenes per language are pixel-identical, in kind, to the ordinary
  attract-logo dissolve (`dmd/en/screens/0008-attract/repr.txt`), not a
  blank or text screen — this walk's normal boot path never triggers the
  country-mismatch recovery screen (`SETTING COUNTRY` / `DEFAULT VALUES`,
  `sub_D664D`'s override path, F11) the mark was presumably placed to
  catch. What would settle it: a capture with the DIP-selected country
  deliberately mismatched against the stored NVRAM country at boot.
