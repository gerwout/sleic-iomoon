# Jackpot and Superjackpot

[← Back to the DMD corpus overview](../README.md)

The two awards that are lit only while Multiball runs, collected and paid.
**223 distinct screens, 36 of them new to the corpus.**

| Award | Where | Paid here | Rules |
|---|---|--:|---|
| **Jackpot** | bull's-eye 2, with `LD2` lit | **40,050,001** | 3.3.5, 5.13 |
| **Superjackpot** | Ramp 2, with `LR21` lit | **80,000,000** | 3.3.2 |

## The award values, measured from the firmware's own score

Read from the score accumulator `413C:00F0`/`00F2` across the run:

```
frame 10912  code 0x2e  +40,050,001   bull's-eye 2  -> JPOT 40,000,000 + the target's own 50,001
frame 11212  code 0x2d  +     11,111   ramp 2 entrance, its ordinary award
frame 11243             +80,000,000   Superjackpot -- exactly double the Jackpot
frame 11512  code 0x2e  +     50,001   bull's-eye 2 again: base only
frame 11812  code 0x2d  +     11,111   ramp 2 again: base only
```

Three things fall out of that, none of them stated in the manual with a number
attached to a measurement:

- **The Jackpot is §5.13's factory `JPOT`, 40,000,000**, paid on top of bull's-eye
  2's own 50,001 rather than instead of it.
- **The Superjackpot is exactly double**, which is what §3.3.2 says and this is the
  arithmetic confirming it.
- **Both are one-shot per Multiball.** The repeat of each pays only its base value,
  so `LD2` and `LR21` are cleared as they are collected, not merely when the mode
  ends.

## Why this capture needs a PinMAME fix, and what it is

Before `pinmame` commit `dfba2385` neither award was collectable at all, because
Multiball announced and never started. **The two CPUs use different Jupiter
contacts**: the 80188 counts a lock from **C46** — the only one the Z80 reports, as
remapped code `0x44` — but the Z80's release, command `0xEE` (`sub_2B86`), keys on
**C44**, and the switch matrix is active low, so it returns "nothing to release"
whenever C44 reads open. With both locked balls resting on C46 and C45 it answered
every one of the nine `0xEE` issues a measured run made that way, coil 16 never
fired, and `LD2`/`LR21` were never lit. A ball now rolls **over** C46 and rests on
**C44**; the second rests on C45 and rolls down as C44 empties. **F22** has the
firmware side.

## The shepherding, which is most of the script

The multiball start is a chain of blocking waits (F22), each needing a ball event,
and the simulator's keys act on **one ball at a time** — the current one, and only
while it is on the playfield. `Down` steps to the next ball, so each wait is
answered by first stepping to the ball that can answer it:

| Wait | Answered by |
|---|---|
| after each lock the held ball leaves the playfield | `Down` to the ball just served, then plunge |
| `sub_DC6AC` releases with `0xEE` and wants a **scoop** report (`0x21`/`0x22` only) | two `Down`s to the released ball, then `LCtrl+H` |
| `sub_DC47E` serves with `0xE9` and wants its reply | plunge the served ball |
| `sub_DB457`, then `DB7E5`, each want one dispatched switch event | two `Down`s and `Y` (lane 1) |
| the **second** held ball is released and wants its own scoop report | the second `LCtrl+H` |

A lane will not satisfy the release wait: `sub_DC675` accepts only the two scoop
codes, and `sub_DC6AC` otherwise re-issues `0xEE` every five seconds indefinitely.
That is the single most useful thing to know about driving this mode.

## Capture

```bash
cd pinmame
SDL_VIDEODRIVER=dummy SDL_AUDIODRIVER=dummy ./build/sdl3pinmame iomoon \
  -rompath ./roms -nvram_directory /tmp/nv -nosound \
  -skip_disclaimer -skip_gameinfo -skip_gamewarnings -nothrottle -ftr 12500 \
  -dmd_dump_dir ../sleic-iomoon/dmd/jackpot \
  -key_script ../sleic-iomoon/scripts/keyscripts/iomoon-jackpot.keys

cd ../sleic-iomoon
cp scripts/keyscripts/iomoon-jackpot.keys.marks dmd/jackpot/iomoon.marks
python3 scripts/dmd_dump_split.py dmd/jackpot/iomoon.txt \
        --out dmd/jackpot --marks dmd/jackpot/iomoon.marks \
        --rom ../pinmame/roms/iomoon/v1_3_01.bin
```

Run against the shipping `build/sdl3pinmame` with no probe compiled in, and needing
no pre-seeded store. The score and lamp evidence above comes from a second,
deterministic run of the same script on a build carrying a throwaway work-RAM probe,
reverted immediately after.

## Marks

`credit` · `ball-1-start` · `orbits-lane4-1..6`, `orbits-letter-1..6`,
`orbits-complete` · `jupiter-lock-1`, `replacement-ball-1` ·
`jupiter-lock-2-multiball` · `follow-the-released-ball` ·
`scoop-1-takes-the-released-ball` · `plunge-the-served-ball` ·
`multiball-running` · `scoop-1-takes-the-second-released-ball` ·
`jackpot-1`, `superjackpot-1`, `jackpot-2`, `superjackpot-2` · `end`.

## What this does not settle

The award screens themselves decode only partial digits (`4` at the Jackpot, `8` at
the Superjackpot), the documented consequence of consecutive digits overlapping in
the in-play score face (`docs/dmd_graphics.md`). The values above are read from the
firmware's own score cell, not from the panel.
