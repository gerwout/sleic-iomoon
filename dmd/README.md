# DMD screen corpus

Per-language captures of every screen the IO Moon DMD draws, produced by driving
`build/sdl3pinmame` headlessly with a `-key_script` and splitting the resulting
frame dump with `scripts/dmd_dump_split.py`. See
`scripts/keyscripts/iomoon-en.keys` for the exact walk and its own header
comment for what it covers and what it found running against the real binary.

## Layout

- `<lang>/<romset>.txt` — the raw frame dump, byte-exact Serum/Pin2DMD format
  with per-frame timestamps. This is the artefact with downstream value.
- `<lang>/<romset>.marks` — the key script's mark sidecar (frame, ms, label).
- `<lang>/screens.csv` — one row per scene: id, label, dir, first/last ms,
  frame count, and the on-screen text decoded from the ROM's own font
  (`--rom`), where the h=9 face covers it.
- `<lang>/screens/<NNNN-label>/repr.txt` — one representative frame (the
  scene's last) per scene. Committed.
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

Measured on the committed `en/` corpus: every label that appears on one side
appears on the other (zero labels unique to either side, in the sense just
qualified above). Within the shared labels, **80 mod-only** and **124
parent-only** representative-frame hashes never recur under that same label
on the other side, out of **857 (mod) / 898 (parent) scenes** total — close
to the plain global-hash count from fix round 1 (81 / 122), which confirms
the two counting methods agree here, though "agree" is itself only a
consistency check between two hash-counting methods, not independent
confirmation that the mismatches are harmless. The 41-scene difference in
total scene counts (857 vs 898) is plausible under the same mechanism (more
attract-loop frames pass the splitter's diff threshold on one side than the
other) but has not been separately confirmed.

The mismatches fall into three groups by label — `PRESS START` and its
neighbours (`press-start-normal`, `ball-3-drained-gameover`,
`high-score-entry`, `lottery`, `attract-again`), the auto-cycling TECNICO
tests, and the menu's own `back-to-N` transitions — and it is plausible that
all three are timing drift (the same screen, caught a frame apart) rather
than a genuine content difference, since the patch touches only the
end-of-game path. That plausibility is not the same as having looked.
**Spot-checked, one pair per group, by rendering both sides' `repr.txt`
directly:**

- `attract-again` (mod scene 402 vs parent scene 440, same script frame):
  the mod's frame is a partial, mid-dissolve view of the "IO MOON" logo
  (only the bottom of the letters); the parent's is the same logo fully
  settled. Consistent with the same attract-loop animation caught at two
  different points, not a different screen.
- `svc-37` (mod scene 649 vs parent scene 690, same script frame, one of the
  CONTACTOS-adjacent auto-cycling tests): the two frames are visually
  identical but for a one-or-two-pixel difference in a small mark near the
  bottom of the panel — consistent with a free-running relay/lamp counter
  one tick apart.
- `back-to-2` (mod scene 541 vs parent scene 582, same script frame): the
  two frames show the same layout and are nearly pixel-identical, but one
  character position differs — consistent with a redraw caught mid-update
  rather than a different value being displayed.

All three checked pairs support "timing drift, not content divergence" —
but three pairs out of 204 mismatched frames is a spot check, not a proof
for the other 201.

A fourth thing worth stating precisely rather than glossing over: many
`svc-N` service-menu records only have one captured scene on each side at
all (a single-item leaf visited once), and for about twenty of them that one
scene *is* the mismatch — there is no second, matching scene to fall back
on, so for these labels 100% of the captured content differs, not a minor
exception. Rendered one (`svc-7`, mod scene 542 vs parent scene 583, same
script frame): the same near-miss shape as `back-to-2` above — nearly
identical content, one character position different, nothing else. So the
pattern extends to these too, on the one further example checked, but "no
`svc-N` record differs" would be the wrong way to summarize it; the honest
statement is that every checked `svc-N` mismatch (four now, across both
`back-to-N` and plain `svc-N` labels) looks like the same single-glyph
redraw-timing artifact, not a structurally different screen, and that this
has been checked on 4 of the roughly 55 mismatched `svc-N`/`back-to-N`
pairs (110 mismatched hash instances split evenly between the two sides).

No GAME or SOUND/VIDEO adjustment page, attract feature-ad screen, or boot
text shows a mismatch at all — which is the expected result given the patch
touches only the end-of-game path.

## Open items

- **Two different score displays exist in this game, and only one of them
  decodes.** The attract-mode high-score table is drawn in the `height=12`
  face (table offset 75) and now decodes cleanly: `S.MOONLIGHT /
  300.000.000 / . .`, `J.SUNSHINE / 200.000.000 / . .`, `B.STARWAY /
  100.000.000 / . .` (scenes 51/420/780, 55/424/784, 61/428/790). The
  **in-play** score is a separate, larger display — shaded digits, a bright
  (level 3) outline around a mid-tone (level 1) interior, legible by eye
  during a gameplay capture (e.g. `2.452.230`, `3.812.237`, `1.027.571` in
  earlier renders of this and the prior corpus) — and its face is not
  identified. `iomoon_strings.score_glyph_bitmaps` now builds its match key
  from both bitplanes (level = `2*plane0_bit + plane1_bit`, F13's own
  weighting), which rules out the panel's own dithered background as the
  cause of the original empty cells: thresholding the frame at level 3
  (discarding the dimmer dither levels entirely) across 268 empty gameplay
  and attract scenes recovered only 2, and the fix is confirmed
  structurally sound against the ROM's own font-table data (the
  decimal-point mark it now finds spans a shaded 3x3 area, not the
  plane-0-only 2x2 box the old reading found). Applied and measured, it
  rules out one specific candidate for the in-play display: the `(h=23,
  W=2)` face never exact-matches a real frame anywhere in this corpus —
  scanning all 21 of its labels against every one of the raw dump's 11,723
  frames finds zero hits, and the closest approximate match differs in 120
  of 368 pixels, no resemblance. What would settle which face draws the
  in-play score: matching a rendered in-play frame, by eye, against each
  remaining candidate face in the walked font table (`docs/dmd_graphics.md`
  lists them).
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
  is not noise: rendered directly (`dmd/en/screens/0557-svc-16/repr.txt`),
  it is a row of 13-14 glyph-shaped tiles over a dim (level-1) bar — the
  service menu draws a bar or level indicator out of the same `h=12` letter
  bitmaps, filling one tile at a time, so the matches are bitmap-faithful
  (they are the real `h=12` bitmaps, not a coincidence) and simply are not
  text. A reader of `screens.csv` should expect a growing letter run under
  those two labels and read it as a level indicator, not a word.
- **`full-tilt` produces zero scenes.** The tilt sequence itself runs (ball
  2 correctly proceeds to ball 3 afterward), but no DMD frame is captured
  between the second tilt press and the ball's drain — not a handful of
  near-duplicate frames, *none* at all, confirmed by checking the raw dump
  directly (no frame between the two timestamps). F17's own account of full
  tilt (stop the music, clear both DMD planes, play the tilt sound, disable
  the drivers) says the screen should go blank right on that press; whether
  the panel genuinely stops redrawing until the next real input (the drain)
  or a frame is being produced and silently dropped somewhere upstream of
  the dump is not settled. What would settle it: a `-debug` build with the
  `SLEIC_TRACE_PW` probe enabled, watching for a PCS0/PCS4 write in the gap.
- **The mod's SPECIAL trampoline (`D5077`) is not exercised.** `PRESS START`
  appears three times in this corpus (the boot seed screen, the normal
  end-of-game hook at `D5123` twice — once per game below); reaching
  `D5077` needs an actual match win, which this walk does not force.

  An earlier round of this corpus recorded, as committed fact, that every
  score at or above roughly 50,000,000 also earns an EXTRA BALL and that
  "the ball simulator's fixed three-ball trough then has no further ball to
  serve." That was wrong, and the real cause is F10/F11's short-ball
  "salida nula" replay protection: `sub_D368C`, tested at `D31D3`, replays
  any ball — an awarded extra ball included — that scores at or below the
  NVRAM `0x43` threshold (factory 100,000), indistinguishable from a player
  abandoning the ball. A bare plunge immediately followed by a drain scores
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
  `B.STARWAY`, ...); `attract` itself was lengthened in fix round 1 to
  approximate a fuller cycle rather than the ~10s the brief's literal
  ordering first produced, but a single continuous "one full loop, start to
  repeat" boundary is not identified either place.
- **The in-play `PLAYER`/`BALL` font is not in the walked font table.**
  Every `ball-N-in-play`/`ball-N-drained` scene shows `PLAYER 1` and
  `BALL 1` in a small, roughly 6-row-tall, single-pixel-stroke font at full
  brightness — nothing like the bold `h=9` or `h=12` faces this decoder
  reads. It is not among the font table's 224 entries: searching both ROMs
  for its `P` bitmap finds no match as contiguous one byte per row, padded
  with blank rows to a taller cell, or at a 16-byte stride inside a
  128-pixel-wide frame buffer. Unchanged by this round; see
  `docs/dmd_graphics.md`'s own "Open items" for the full account and what
  would settle it.
