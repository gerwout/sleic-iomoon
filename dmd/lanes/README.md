# The lit-lane awards

[← Back to the DMD corpus overview](../README.md)

The three awards a lane pays when its own lamp is lit. **194 distinct screens, 51 of
them new to the corpus.**

No other capture here collects one, and the reason is structural rather than
accidental: the walks that light a lane lamp — [`monolith/`](../monolith/README.md)
and [`modes/`](../modes/README.md) — press no lane but lane 6, and the
[coverage sweep](../coverage/README.md), which presses all eleven lanes, lights none
of them first.

| Collected here | Lamp | Rules |
|---|---|---|
| **Bonus ×10** at lane 9 | `LP9` (`LC59`) | 3.3.1, 3.3.6 |
| **Special** at lane 7 | `LP7` (`LC57`) | 3.2.10, 3.3.6 |
| **Extra Ball** at lane 8 | `LP8` (`LC58`) | 3.2.9, 3.3.6 |

## All in one ball, because the bank hands the light along

The drop bank lights each of those lanes in turn as it goes down — two targets light
`LP9`, four light `LP7` and put `LP9` out, five light `LP8` and put `LP7` out (3.3.6)
— and each step **replaces** the one before it. So each lane has to be run before the
next target falls, and the whole sequence has to happen inside one ball, since the
bank resets only at ball start.

## What fired, with the evidence

F18 puts `LP7`, `LP8` and `LP9` at lamp column 5 bits 4, 5 and 6. All three **blink**,
roughly nine frames on and nine off, so a single-frame sample of the matrix says
nothing either way — the earlier reading that these lamps never lit was a sample
taken in a blink-off phase. What confirms each collect is the whole timeline: the
lamp blinks continuously from its own target step until a few frames after its lane
is pressed, and never again.

| Lamp | Blinks from | Out at | Lane pressed |
|---|--:|--:|--:|
| `LP9` | frame 7927 | 8213 | 8210 (lane 9) |
| `LP7` | frame 8739 | 9005 | 9010 (lane 7) |
| `LP8` | frame 9346 | 9613 | 9610 (lane 8) |

Each lamp's last blink is within five frames of its own lane press, and each lane
code reaches the 80188 in turn — `0x35` lane 9, `0x37` lane 7, `0x36` lane 8,
interleaved with the bank's own `0x1B`–`0x1F`.

## Credits without a pre-seeded store

Unlike [`multiball/`](../multiball/README.md), this capture needs no
`-nvram_directory` prepared in advance. Two things make a coin stick: it has to come
**after the first attract cycle** (a coin during the boot cycle is lost, because the
firmware's own default seeding zeroes the credit triple), and **one coin is not one
credit** under country 4's coin preset (F11) — six are pressed here, and `START` is
accepted at frame 7210.

## Capture

```bash
cd pinmame
SDL_VIDEODRIVER=dummy SDL_AUDIODRIVER=dummy ./build/sdl3pinmame iomoon \
  -rompath ./roms -nvram_directory /tmp/nv -nosound \
  -skip_disclaimer -skip_gameinfo -skip_gamewarnings -nothrottle -ftr 10300 \
  -dmd_dump_dir ../sleic-iomoon/dmd/lanes \
  -key_script ../sleic-iomoon/scripts/keyscripts/iomoon-lanes.keys

cd ../sleic-iomoon
cp scripts/keyscripts/iomoon-lanes.keys.marks dmd/lanes/iomoon.marks
python3 scripts/dmd_dump_split.py dmd/lanes/iomoon.txt \
        --out dmd/lanes --marks dmd/lanes/iomoon.marks \
        --rom ../pinmame/roms/iomoon/v1_3_01.bin
```

Run against the shipping `build/sdl3pinmame` with no probe compiled in. The lamp
evidence above comes from a second run of the same script on a build carrying a
throwaway per-frame lamp probe, reverted immediately after; the emulation is
deterministic, so the two runs are the same run.

## Marks

`credit` · `ball-1-start` · `drop-target-1`, `drop-target-2-lights-lp9` ·
`lane-9-bonus-x10` · `drop-target-3`, `drop-target-4-lights-lp7` ·
`lane-7-special` · `drop-target-5-lights-lp8` · `lane-8-extra-ball` · `end`.

## What this does not settle

**What a Special actually pays** stays open (`docs/iomoon_game_rules.md`, *Open
questions*): the award is collected here, but neither the manual nor this capture
says whether it is a credit, and the non-volatile credit triple is not read back
across this run.

**The two lane Specials, LP1 and LP5, are not here.** They are lit by cashing the
Monolith's `LPA5`, and the Monolith chases rather than resting, so a scripted key
cannot be timed to it — the same problem `LPA3` posed, which
[`little-multiball/`](../little-multiball/README.md) solved with a probe that waits
for the lamp. The same technique would reach these.
