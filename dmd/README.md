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
credit, a three-ball game exercising every playfield feature, the mod's
PRESS START screen at the normal end-of-game hook, the post-game sequence,
and the entire 38-record service-menu tree.

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

- **The `text` column does not decode an in-play score, on any scene in this
  corpus.** The score is visible in every gameplay screenshot rendered
  while producing this corpus (e.g. `2.452.230`, `3.812.237`) but decodes to
  an empty string throughout — checked directly (`decode_text` run by hand
  against a `ball-*-drained` frame, with `--rom` supplied, still empty).
  Traced to the panel's own dithered background: it puts stray lit pixels
  inside the score digits' bounding boxes, and the scoring face's matching
  in `scripts/dmd_dump_split.py` requires an **exact** bitmap match, so one
  stray pixel anywhere in a glyph's window is enough to miss. So: **every
  `text` cell for a gameplay scene in this committed `screens.csv` is
  unreliable for scores specifically**, independent of whether the face
  itself is correctly built. A tolerant match (ignore isolated single-pixel
  differences, or match against a composite-minus-mask plane rather than
  the finished frame) would likely fix it; that is a decoder change, not
  something this corpus's capture step can work around.
- **A whole second glyph face (`h=12`) does not decode in this committed
  `screens.csv`, though it is now pinned.** Several service-menu leaf pages
  in this corpus show real text in a larger face than the one
  `scripts/iomoon_strings.py` reads (`glyph_bitmaps` covers only the h=9
  face) — rendered directly, not decoded, e.g. `svc-25` showing legible
  "ORBIT FLIP"-style prose at roughly double the h=9 cell size. At the time
  this corpus was split, that face's table offset was unknown, so every
  `text` cell touching it is empty rather than wrong — a decoder gap, not a
  capture gap. It has since been pinned, at table offset 75, by work outside
  this task; **this committed `screens.csv` was produced before that fix**
  and will need re-splitting (`scripts/dmd_dump_split.py` against the
  already-committed raw dump — no new capture needed) once the decoder
  carries it, to fill in every `svc-N` `text` cell this face covers.
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
  appears twice (the boot seed screen, then the normal end-of-game hook at
  `D5123`); a real match win, which is what reaches `D5077`, needs neither
  score nor time forced deliberately by this walk. Tried directly: a score
  large enough to also clear the lowest high-score preset (50,000,000) was
  forced by hand (lanes plus a tuned run of bull's-eye hits), but every
  score tried at or above roughly 48-52,000,000 also earns an **EXTRA
  BALL**, and the ball simulator's fixed three-ball trough then has no
  further ball to serve — the display sticks on "EXTRA BALL" with the score
  frozen (checked: the panel keeps animating its own dithered background
  the whole time, so the machine is not wedged, it simply never has a ball
  to give back), for as long as tried (three separate plunge+drain attempts
  per run, waits past 20,000 frames). The high-score wheel-walk (Important
  3 of fix round 1) could not be exercised for the same reason: no run that
  reaches the qualifying score also reaches a genuine game-over to enter it
  at. What would settle it: either a `iomoont`/`iomoon` NVRAM edit that
  raises the lowest high-score preset above the extra-ball threshold before
  the run (so a qualifying score no longer also earns an extra ball), or a
  simulator with more than three balls in its trough so an awarded extra
  ball actually has one to serve.
- **The pre-credit `attract` section and the post-game `attract-again`
  section are the same content, at different lengths.** `attract-again` (the
  post-game return to idle) already runs long enough to show the attract
  cycle's own feature-ad screens (`S.MOONLIGHT`, `J.SUNSHINE`,
  `B.STARWAY`, ...); `attract` itself was lengthened in fix round 1 to
  approximate a fuller cycle rather than the ~10s the brief's literal
  ordering first produced, but a single continuous "one full loop, start to
  repeat" boundary is not identified either place.
