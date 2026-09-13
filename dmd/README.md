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
compare each scene's representative frame by hash:

```bash
python3 scripts/dmd_dump_split.py /tmp/parent/iomoon.txt --out /tmp/parent \
        --marks /tmp/parent/iomoon.marks --rom ../pinmame/roms/iomoon/v1_3_01.bin
for d in /tmp/parent/screens/*/; do md5sum "$d/repr.txt"; done | awk '{print $1}' | sort > /tmp/parent.md5
for d in dmd/en/screens/*/;   do md5sum "$d/repr.txt"; done | awk '{print $1}' | sort > /tmp/mod.md5
comm -13 /tmp/mod.md5 /tmp/parent.md5 | wc -l   # parent-only
comm -23 /tmp/mod.md5 /tmp/parent.md5 | wc -l   # mod-only
```

Measured on the committed `en/` corpus: **81 parent-only** representative
frames and **34 mod-only** ones, out of several hundred scenes each side.
Both counts are timing drift, not a content difference: every service-menu
record on both sides ends up on the same list of items, and the differing
frames are of two kinds —

- the mod's `PRESS START` screen and the frames immediately around it
  (`press-start-normal`, `ball-3-drained-gameover`, `high-score-entry`,
  `attract-again`, `credit`) — the parent has no such gate, so it is already
  further into (or a full cycle further round) its own attract loop by the
  time the same absolute key-script frame numbers fire, landing on a
  different attract sub-screen than the mod; and
- the three auto-cycling TECNICO tests (SOLENOIDS, LIGHT TEST 1-3, and the
  CONTACTOS-adjacent tests), which free-run their own lamp/relay counters
  independently of the key script — the two sides are simply at a different
  point in the same walk when each side's identical fixed-frame checkpoint
  lands, the same way two stopwatches started a frame apart never agree
  again. Spot-checked (`svc-35`, both a blank frame at the same checkpoint):
  same content, different instant.

No difference falls anywhere else in the tree — no GAME or SOUND/VIDEO
adjustment page, no attract feature-ad screen, no boot text differs between
the two runs — which is the expected result given the patch touches only the
end-of-game path.
