# DMD screen corpus

Per-language captures of every screen the IO Moon DMD draws, produced by driving
`build/sdl3pinmame` headlessly with a `-key_script` and splitting the resulting
frame dump with `scripts/dmd_dump_split.py`. See
`scripts/keyscripts/iomoon-en.keys` for the exact walk and its own header
comment for what it covers and what it found running against the real binary.
See `docs/iomoon_dmd_screens.md` for the screen-by-screen index and the
coverage report against the ROM's own string data.

## PinMAME build and capture

Every capture in `en/`, `es/`, and `faults/` is built against
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

## Multiball (`multiball/`), captured against `iomoon`

The lock and mode screens neither `en/` nor `es/` contains. Both walks press
`J` twice intending a Jupiter lock, but the simulator filled the device from
C44 — a contact the Z80 reports no code for — so nothing was ever locked and
none of these screens was drawn. The device reports only on **C46**, as the
remapped code `0x44`, which the 80188 counts in `[4134:0030]` through
`sub_D9D04`: 1 arms Little Multiball, 2 starts Multiball at `D9DBD`.

916 frames, 366 scene occurrences, **91 distinct screens**, including
**BALL LOCKED FOR MULTIBALL** (alternating outline and filled) and the
full-height **MULTIBALL** with its wipe. Captured on the parent set rather
than `iomoont`, and it needs a PinMAME fix that is not upstream —
`dmd/multiball/README.md` has the conditions, the commands and the NVRAM
seeding this capture depends on.

## Monolith awards (`monolith/`), captured against `iomoon`

Every position the Monolith can cash, and every mode played rather than just
announced: Extra Ball, 3/6/9 millions, Special, Little Multiball, Impact Count,
Orbit Flip, Special Drop Target and Star Ride, plus the Lagrange Scape /
Lagrange Orbit pair the shooters alternate.

Twelve rounds of {lane 6 to arm, one bumper to step, scoop 1 to cash, then a
play burst}. Twelve single steps around a ten-position cycle reach every
position wherever it starts, and the burst is exactly twenty bumper hits so the
cycle stays aligned while Impact Count gets the twenty it wants.

5044 frames, 432 scene occurrences, **237 distinct screens, 184 of them not
present anywhere else in this corpus**. `dmd/monolith/README.md` has the
mechanism, the coverage argument and what it does not yet establish — the
screens are traceable to a round and stage, not yet labelled per named award.

## Wonderful Thing and the bank (`modes/`), captured against `iomoon`

The sequences the Monolith walk and the multiball capture cannot reach, all in
one ball because the drop bank resets only at ball start: ORBITS, the bank
cleared, **Special Drop Probe**, **Wonderful Thing** and the Lagrange pair.

123 distinct screens, **50 new to the corpus**. Every sequence is confirmed from
the firmware's own state rather than from the script — `[413C:0102]` reaching 6,
`LP7`/`LP8`/`LP9` lit together for the Probe, and the lock counter `[4134:0030]`
going 1 → 2 and then back down **2 → 1 → 0 in two steps**, which is §3.2.2's
staged release and is what separates Wonderful Thing from Multiball.
`dmd/modes/README.md` has the table.

## Coverage sweep (`coverage/`), captured against `iomoon`

The rules sections the other captures leave out: **Little Multiball** arming
(`LPA3` and `LTB12` lit, which needs ORBITS), all eleven lanes including lane 10
with ORBITS complete, **bull's-eye 2**, the inner bank target with the bank
standing, and the **end-of-ball bonus** countdown. 147 distinct screens, **62
new to the corpus**. `dmd/coverage/README.md` says what is confirmed and what is
only armed.

## Little Multiball isolated (`little-multiball/`), captured against `iomoon`

The Monolith chases, so `LPA3` cannot be hit by a scripted key -- a lock lands
on it about one time in ten. This capture uses a throwaway probe that takes the
lock **on the frame `LPA3` is lit**, the way `faults/` uses its own probes.
Exactly one ball locks (`[4134:0030]` = 1, not 2, which is what separates Little
Multiball from Multiball) with `LTB12` lit at scoop 1. 90 distinct screens, 15
new.

The **release does not happen and coil 16 never fires**, across eight scoop-1
collects -- which narrows the rules' own open question about *Sueltabolas de
Júpiter* rather than settling it. `dmd/little-multiball/README.md` has the probe
and the argument.

## The lit-lane awards (`lanes/`), captured against `iomoon`

The three awards a lane pays with its own lamp lit — **Bonus x10** at lane 9,
**Special** at lane 7, **Extra Ball** at lane 8 — which no other capture here
collects, for a structural reason: the walks that light a lane lamp press no
lane but lane 6, and the coverage sweep, which presses all eleven, lights none
of them first.

The drop bank hands the light along (two targets to `LP9`, four to `LP7`, five
to `LP8`, each step replacing the last), so all three collects sit inside one
ball. 194 distinct screens, **51 new to the corpus**. Every collect is
confirmed from the lamp rather than the script: each lamp blinks continuously
from its own target step until within five frames of its own lane press, and
never again. `dmd/lanes/README.md` has the timeline.

## A four-player game (`players/`), captured against `iomoon`

Every other capture in this corpus plays one player. Four players, three balls
each, twelve balls: 219 distinct screens, **76 new to the corpus**. The
four-player score display is what separates it — `screens.csv` decodes
`1 2 / 3 4 / 1 1 / PLAYER BALL`, the four player numbers together, where `en/`
only ever decodes `1 1`, `1 2` and `1 3`. Twelve ball-over events (`0x43`)
confirm the player count from the machine rather than the script.

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

- **Jackpot and Superjackpot cannot be captured, because Multiball announces
  but does not engage.** Both are Multiball-only awards: `LD2` lights at
  bull's-eye 2 and `LR21` at Ramp 2 when the mode starts, and both go out when
  it ends (3.2.1). With ORBITS complete and the bank standing, a second Jupiter
  lock draws the full-height MULTIBALL screen and plays its music — the frame is
  byte-identical to `dmd/multiball/screens/0114-*` — but **neither lamp ever
  lights**: lamp column 1 bits 5 and 6 (F18) flash only through the lock and
  announce animations and are dark for the rest of the run, measured across
  15,000 frames with fourteen playfield hits after the lock. **Coil 16 never
  fires either**, so no ball is released and the mode never has three balls in
  play. F22 establishes the firmware side — the coil is reached by exactly four
  80188 commands and no mode path issues one — so what is missing is which path
  should. Until that is answered the two awards are not reachable, and no key
  script can reach them; `scripts/keyscripts/iomoon-jackpot.keys` drives
  everything up to the point of collection and is kept for that reason.

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
  stored digit, occupies its table slot in the traced mode — see the doc
  above for the five untraced modes this might still reach it through).
  The digit table's own alternate base, `CS:052BF`, turns out to be the
  same digit shapes pitch-shifted 4px, not a second font (`docs/
  dmd_graphics.md`) — confirmed, but not wired into the decoder this round:
  the expected gain (recovering some of the digits the overlap above
  already drops) did not seem worth changing a function every other face
  also relies on, without the time left this round to re-verify all of them
  against it.
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
  independently confirmed here; the other two (both `attract-again`, the
  post-game idle cycle) most likely read part of a larger, still-unidentified digit
  graphic.

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
  frame. The Spanish key script carries the same corrected mark and `dmd/es/`
  shows the same two `full-tilt` occurrences; its second is the Spanish
  equivalent screen, a large drop-shadowed word of 2531 lit pixels against the
  English `TILT`'s 2265 (`dmd/es/screens/0302-full-tilt/repr.txt`), and like the
  English one it is legible by eye but matched by no walked face.
- **The record-inscription (wheel-walk) screen decodes: `captured, not read`
  is fixed for its header and player label, and confirmed against the ROM's
  own stored strings, not just bitmap matching.** The header reads
  `INSCRIPTION` (`INSCRIPCION` in Spanish) — `text` itself shows
  `INSCRIPTI0N`, a zero for the `O`; that is the `height=12` face's own
  `0`/`O` bitmap collision (`docs/dmd_graphics.md`), not a decode error.
  The label beside the entered
  initials reads `PLAYER 1:` (`JUGADOR 1:`) — both found verbatim as
  GLYPHS-encoded bytes in ROM1 at flat `0x10014`/`0x10021` (English) and
  `0x30015`/`0x30021` (Spanish), a small table of `PLAYER 1:`/`PLAYER 2:`/
  `PLAYER 3:`/`PLAYER 4:` label lines, not just inferred from partial glyph
  matches. Both use the existing `h=9`/`h=12` faces; what was broken was the
  matcher, not a missing font: it required every blank margin pixel to also
  read blank on screen ("nonzero is lit"), which holds for a clean
  service-menu screen (confirmed: `dmd/en/screens/5383-svc-1/repr.txt` has
  no level-3 pixel anywhere, so that screen's own text genuinely needs
  "nonzero is lit" to match) but not for this one, where the panel's
  dithered background shows through the header's own blank margins at
  level 1. `_scan_face` now tries "nonzero is lit" first and falls back to
  "only level 3 is lit" on a miss, recovering both without ever replacing a
  match the first rule already found — re-splitting both corpora with the
  fix lost zero previously-decoded cells (checked directly, not assumed).

  **Not fixed: the player-number digit's own last three letters
  (`PLAYER`'s `Y`, `E`, `R`) render unreliably** — row 1 of each cell (the
  glyph's own top row) is sometimes blank, sometimes lit but not matching
  the stored glyph exactly, varying scene to scene with no pattern found
  (not simply another binarization threshold: the missing pixels are
  genuinely absent from the captured frame, not dimmed).

  Two things checked before leaving it open, as asked. **Row 1 is not
  simply content the blitter never draws**: `dmd/en/screens/
  5200-score-recover-drained/repr.txt` shows `Y` and `E`'s own row 1
  matching their stored `h=9` bitmaps exactly at level 3, in the same scene
  where `R`'s row 1 shows dim, wrong-shaped content — row 1 is genuinely
  drawn, correctly, for two of the three letters, in a scene where the
  third still fails, which rules out "always blank" as the cause.
  **Because of that, tolerating a missing row 1 was not implemented**: since
  row 1 is sometimes the *only* pixels distinguishing a correct match from
  a coincidental one, a blanket "row 1 doesn't count" rule would trade a
  narrow, already-rare failure for a broader, harder-to-bound one, for a
  letter class (`Y`/`E`/`R`) that only ever appears in this one label. The
  decoder recovers `PLA` reliably and the rest inconsistently
  (`PLAYE`/`PLAYER`/`PLA` depending on the scene); the full word is
  confirmed from the ROM string above, not from any single frame's bitmap.
  What would settle it: tracing the routine that draws this specific label
  (not identified here) rather than more bitmap comparison — `R` sitting at
  the *end* of the label, the one position never observed correct, is worth
  checking against a right-edge clipping boundary specifically.

  **Also decoded, meaning not established:** the block beside the label
  (`0I8M`-style, growing by one `h=12` character as the wheel is cycled)
  matches the walked font table cleanly and exactly, character by
  character, confirmed against the growing sequence across all 17
  `wheel-c*` scenes — but what it represents (the entered initials
  themselves, a candidate-history readout, something else) is not
  established; the growth pattern does not cleanly map to three initial
  slots (it reaches five characters), so it is reported as decoded rather
  than interpreted.
- ~~The mod's SPECIAL trampoline (`D5077`) is not exercised~~ **— reached, with a real
  lottery win, on the shipped release build.** No ROM patch and no driver probe:
  `scripts/keyscripts/iomoon-special.keys` aims the firmware's own match, NVRAM's
  triplicated credit byte goes `0,0,0` → `1,1,1` across the game (`scripts/nvcheck.py`), and
  the `PRESS START` the `D5077` trampoline draws is `dmd/special/screens/0313-*`.

  **The rule, and it now holds exactly over 104 complete games.** `sub_D4CF4` (`D4CF4`,
  called from `sub_D46F8` at `D3237`, from the end-of-ball game-over dispatch `sub_D3145`)
  divides the player's score-digit cell `413C:0016` by 10 and compares the remainder, at
  `D4DCB`, against work RAM `4000:113F`; on equality `sub_D4FDC` banks a credit
  (`nvstore_write_triple_83`) and takes the `D5076`/`D5077` trampoline, and on inequality the
  game ends through the mod's other hook at `D5123`. `[4000:113F] == [413C:0016] mod 10`
  predicted the credit award in 104 of 104 trials, no exceptions either way.

  **The counter is the count of *delivered* timer-0 ticks, mod 10 — which is not the same as
  elapsed time.** The timer-0 ISR is its only writer (`D030E` stores the wrap, `D0315`
  increments; nothing else in either ROM writes it, and `D4DC4` is the only other reader),
  and its value equals the number of ISR writes so far, mod 10, in every trial. But ticks
  that come due while the firmware has interrupts masked are lost: eight games on one fixed
  event schedule, differing only in which targets scored, reached the compare at the same
  millisecond having delivered 15,335 to 15,341 ticks — against 16,513 nominal for that
  166.494 s at 99.18 Hz. So the counter at the compare **moves with what the game did**, and
  a sweep over the score digit alone is not a ten-way search against a fixed target. (How
  many ticks real hardware drops is not established; the 80188's timer latches one request
  per source, as the driver models, so it loses them too.)

  **Aiming it takes two controls.** Twelve scoring slots, each a lane (`KEYCODE_Y`, 100,000,
  units digit 0) or the inner bank (`KEYCODE_I`, 50,001, units digit 1): `[413C:0016]` at the
  compare equals the number of inner-bank slots exactly, for every count 0 to 12, so that
  cell is a raw accumulator `sub_D4CF4` reduces itself. And a whole-game time shift, which
  moves the counter while leaving the score alone. A 13 × 8 sweep of the two landed twelve
  free games out of 104, 11.5%, against §3.5's "roughly 20%" for the machine.

  **The lottery number is drawn on the panel, and it is the counter's own value** — which
  settles what the full-panel digit in this sequence is. Counter `5` draws `5`, counter `9`
  draws `9`, and `dmd/en/`'s own `0374-lottery`, from an unaimed ordinary
  game, draws `4`. It is **not** SPECIAL-only: the whole reveal — the Monolith/train graphic
  (`dmd/special/screens/0311-*`, byte-identical to `dmd/en/screens/0373-*`) and the digit —
  runs at the end of every game. What a match changes on the panel is only *when* `PRESS
  START` arrives (250 ms after the reveal ends, against 1.35 s), and that this occurrence
  does not release on a START press where the `D5123` one does — that one is settled too:
  the cave is entered with a byte still unconsumed under the inbound FIFO's read cursor,
  which only the main loop it is holding could advance, so every press is received and
  rejected. `dmd/special/README.md` has the full account: the sweep's own table, the five
  digit observations, the three-way `PRESS START` comparison, the FIFO trace, and the
  reverted watch every measurement came from.

- ~~The second game's own `score-lottery` and `score-press-start-normal` marks do not sit
  on the screens they name~~ **— fixed, and the reason they were hard to place is a real
  difference between the two endings.** A read watch on `4000:113F` across the whole English
  walk catches the compare (`D4DC4`) exactly twice, once per game: at ms 246038 with the
  counter reading `4`, and at ms **1628730** with it reading `7`. The second game's draw
  therefore runs *after* the name-entry wheel walk, not before it — the opposite order to
  the first game's — which is why nothing resembling a draw appears between that game's last
  drain and its name entry. `score-lottery` now marks the draw itself (ms 1628800-1634466 in
  `en`, 1628800-1634316 in `es`) and `score-press-start-normal` the `PRESS START` frame that
  follows it (ms 1635783 in `en`, 1634566 in `es`, where it previously had no frame at all).

  The same run confirms the drawn digit independently, on captures made before any of this
  work: the first game's counter is `4` and `dmd/en/screens/0374-lottery/repr.txt` draws a
  `4`; the second game's is `7` and `dmd/en/screens/5219-score-lottery/repr.txt` draws a `7`.
  Neither game matched — their score digits at the compare were `7` and `6` — so the walk's
  closing credit is an unspent coin, not an award.
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
  five of its occurrences even after the 25x dwell.

  **The spike's own guess for `svc-24` — that its record passes a zero bar
  count — is refuted, not just unconfirmed.** The bar's own counter,
  work-RAM `4000:114A`, is written in exactly two places in the whole ROM
  (`D09E3`, `D0A19`), both *inside* the increment/decrement routines
  themselves (F21's own `sub_D09BC`/its decrement counterpart) — nowhere is
  it loaded from a menu record field, so no record, `svc-24`'s included,
  can "pass" it a value at all. The real driver, traced to its caller
  (`sub_DD669`, the menu's own navigation dispatch, four-way on switch codes
  `0x3F`-`0x42`, F14): pressing **scroll** (`0x41`) calls the increment
  routine: pressing **back** (`0x40`) calls the decrement; the counter
  persists across records rather than resetting per-record, which is
  consistent with "grows with the depth of a whole walk" without needing a
  per-record source at all. `svc-24` showing nothing is therefore a
  property of *this walk's own key sequence* at that record (whether it
  happened to press scroll there), not a stored ROM value — though why
  `svc-24` specifically shows *no* bar, rather than whatever length the
  cumulative counter had already reached by that point in the walk (every
  other deep record does show some bar), is not explained by this alone
  and stays open. What would settle it: a capture that presses scroll at
  least once while `svc-24` itself is open, checked against one that
  deliberately does not. Whether the tile-bar depth records (`svc-2` and
  others) are *also* full-screen images, rather than the tile bar being
  their genuine drawn content, is not established either way.

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
