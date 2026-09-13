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
# per label: for each label both sides share, diff the hash sets within it
# (see the fix-round report for the exact script used)
```

Measured on the committed `en/` corpus: **every label that appears on one
side appears on the other** (zero labels unique to either side). Within the
shared labels, **80 mod-only** and **124 parent-only** representative-frame
hashes never recur under that same label on the other side, out of 857
(mod) / 898 (parent) scenes total — close to the plain global-hash count
(81 / 122), which confirms the two methods agree here and neither is hiding
a mislabelled divergence. All of it is timing drift, not a content
difference, and falls into the same two kinds as before:

- the mod's `PRESS START` screen and the frames around it
  (`press-start-normal`, `ball-3-drained-gameover`, `high-score-entry`,
  `lottery`, `attract-again`) — the parent has no such gate, so it is
  already further into (or a full cycle further round) its own attract loop
  by the time the same absolute key-script frame numbers fire, landing on a
  different attract sub-screen than the mod; and
- the auto-cycling TECNICO tests and the menu's own `back-to-N` transitions,
  which are each other's nearest neighbours in time and so pick up a
  different single frame of the same still-changing content (a lamp/relay
  counter tick, a redraw settling) depending on which side happens to reach
  that exact checkpoint a frame earlier or later.

No `svc-N` record differs in content on either side, and no GAME or
SOUND/VIDEO adjustment page, attract feature-ad screen, or boot text differs
between the two runs — which is the expected result given the patch touches
only the end-of-game path.

## Open items

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
