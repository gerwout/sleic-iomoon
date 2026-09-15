# The multiball capture

[← Back to the DMD corpus overview](../README.md)

The screens Io Moon draws when a ball is locked at Jupiter and when Multiball
starts. The `en/` and `es/` walks press `J` twice intending exactly this, but no
lock ever happened in them, so neither corpus contains these screens and neither
ever did.

## What the firmware needs

Three conditions, all in `docs/iomoon_game_rules.md` §3.3.7 and now traced to
the ROM:

1. **ORBITS complete.** Lane 4 (C17, code `0x0F`) lights LD1; bull's-eye 1
   (C32, code `0x24`) then takes one letter. Six pairs put the firmware's own
   letter count `[413C:0102]` at its cap of 6, which is the gate on Jupiter
   retaining a ball at all.
2. **A ball reported on C46.** The three Jupiter contacts are a counted device:
   C44 and C45 (codes `0x2A`/`0x2B`) are reported by the Z80 as **no code at
   all**, and C46 reports as the remapped code **`0x44`** rather than its own
   `0x2C` — the same treatment the trough's entry contact gets, where C6
   reports `0x43` instead of `0x0A`.
3. **The drop bank standing**, which is what selects Multiball over Wonderful
   Thing.

Code `0x44` is what the 80188 acts on. The in-game dispatcher at `D7661`
indexes the table at `CS:0527` by `code − 0x0E`; entry 54 reaches `sub_D9D04`,
which increments the lock counter `[4134:0030]` and branches on it — 1 arms
Little Multiball, 2 starts Multiball at `D9DBD`. Codes `0x2A`–`0x2C` reach
entries 28–30, all of which are the do-nothing default at `0x0523`.

## Capture

**This capture needs a PinMAME fix that is not upstream.** Until that lands,
the simulator fills the Jupiter device from C44, a contact the Z80 reports no
code for, so nothing is ever locked and none of these screens is drawn. The fix
is `sleic: fill Io Moon's Jupiter lock from the contact the Z80 reports`,
commit `957cf972` on branch `iomoon-probes`, which changes the state chain to
fill C46, C45, C44 in that order — the same "balls stack away from the entry"
shape the trough model already uses, and for the same reason.

Captured on **`iomoon`**, not the `iomoont` the `en/` and `es/` corpora use:
`iomoon` is the set the fix was verified on, and the tournament mod does not
bank credits under the seeding sequence below.

```bash
cd pinmame
SDL_VIDEODRIVER=dummy SDL_AUDIODRIVER=dummy ./build/sdl3pinmame iomoon \
  -rompath ./roms -nvram_directory /tmp/nv -nosound \
  -skip_disclaimer -skip_gameinfo -skip_gamewarnings -nothrottle -ftr 4200 \
  -dmd_dump_dir ../sleic-iomoon/dmd/multiball \
  -key_script ../sleic-iomoon/scripts/keyscripts/iomoon-multiball.keys

cd ../sleic-iomoon
cp scripts/keyscripts/iomoon-multiball.keys.marks dmd/multiball/iomoon.marks
python3 scripts/dmd_dump_split.py dmd/multiball/iomoon.txt \
        --out dmd/multiball --marks dmd/multiball/iomoon.marks \
        --rom ../pinmame/roms/iomoon/v1_3_01.bin
```

**`-nvram_directory` must already hold a store with credits.** On a store the
firmware has not yet written, its own default seeding zeroes the credit triple,
so coins banked during that first boot do not stick and `START` is refused —
a run that then captures attract and nothing else. Run the coin script twice
against the same directory before capturing; the second run banks. The
triplicated credit byte is `0x83`/`0x116`/`0x20C` (F10), decoded by
`scripts/nvcheck.py`.

## What is here

916 frames, 366 scene occurrences, 91 distinct screens.

| Marks | What |
|---|---|
| `boot`, `start`, `plunge` | getting a ball into play |
| `orbits-lane4-1..6`, `orbits-letter-1..6` | the six pairs that spell ORBITS |
| `orbits-complete` | `[413C:0102]` at 6 |
| `jupiter-lock-1` | **BALL LOCKED FOR MULTIBALL**, alternating outline and filled |
| `replacement-ball-1` | the ball the firmware serves after the lock |
| `jupiter-lock-2-multiball` | **MULTIBALL**, and the wipe that brings it in |
| `replacement-ball-2`, `multiball-play`, `multiball-play-2` | play with the mode running |

Layout is the corpus's own: `iomoon.txt.gz` the raw dump, `iomoon.marks` the
sidecar, `screens.csv` the index, `screens/<id>-<label>/` the frames with the
first occurrence of each distinct screen carrying a `repr.txt`.
