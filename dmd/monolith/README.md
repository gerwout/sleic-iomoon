# The Monolith award walk

[← Back to the DMD corpus overview](../README.md)

Every position the Monolith can cash, and every mode played rather than just
announced. **237 distinct screens, 184 of which appear nowhere else in the
corpus.**

## The mechanism

The Monolith (`LPA1`…`LPA10`, rules §3.3.3) is a ten-position cycle. **Every
bumper hit steps it one place**, and entering either scoop with `LTB11` or
`LTB2` lit — armed at lane 6 or the Jupiter entry — cashes whatever it shows.

| Position | Award | Position | Award |
|---|---|---|---|
| LPA1 | Extra Ball | LPA6 | 9,000,000 |
| LPA2 | 3,000,000 | LPA7 | Impact Count (timed, 15 s) |
| LPA3 | Little Multiball | LPA8 | Orbit Flip (timed, 15 s) |
| LPA4 | 6,000,000 | LPA9 | Special Drop Target |
| LPA5 | Special (lane 1 or 5) | LPA10 | Star Ride |

`LPA11` / `LPA12` (Lagrange Scape / Lagrange Orbit) are not in the cycle and are
never cashed — the two *Expulsores* alternate them (§3.3.4), which is what the
two shooter presses at the end of the walk are for.

## How the walk covers all ten

Twelve rounds of **{lane 6 to arm, one bumper to step, scoop 1 to cash, then
play}**. Twelve single steps around a ten-position cycle reach every position at
least once wherever the cycle happens to start, so the walk needs no knowledge
of the position up front and no lamp reading.

The play burst after each cash is the same every round, because which mode just
started depends on the position. It exercises all four timed modes at once:
20 bumper hits (Impact Count wants 20 inside its 15 s), both ramps (Orbit Flip
lights `LR12` on Ramp 1 and can drop the ball from Ramp 2), all five drop
targets (Special Drop Target pays 100,000 each) and both scoops (Star Ride pays
10,000,000 and 15,000,000).

**The burst is exactly twenty bumper hits on purpose.** Bumpers step the
Monolith, so any multiple of ten leaves the cycle where it was and the
one-step-per-round walk stays aligned; 20 is the smallest multiple that also
satisfies Impact Count.

## Capture

Same tooling as the rest of the corpus, on `iomoon`, and it needs a
`-nvram_directory` that already holds a store with credits — see
[`../multiball/README.md`](../multiball/README.md) for why a first boot banks
nothing.

```bash
cd pinmame
SDL_VIDEODRIVER=dummy SDL_AUDIODRIVER=dummy ./build/sdl3pinmame iomoon \
  -rompath ./roms -nvram_directory /tmp/nv -nosound \
  -skip_disclaimer -skip_gameinfo -skip_gamewarnings -nothrottle -ftr 22000 \
  -dmd_dump_dir ../sleic-iomoon/dmd/monolith \
  -key_script ../sleic-iomoon/scripts/keyscripts/iomoon-monolith.keys

cd ../sleic-iomoon
cp scripts/keyscripts/iomoon-monolith.keys.marks dmd/monolith/iomoon.marks
python3 scripts/dmd_dump_split.py dmd/monolith/iomoon.txt \
        --out dmd/monolith --marks dmd/monolith/iomoon.marks \
        --rom ../pinmame/roms/iomoon/v1_3_01.bin
```

## What is here

5044 frames, 432 scene occurrences, 237 distinct screens. Marks name every
stage of every round, so a screen can be traced to what produced it:

| Mark | Distinct screens over the 12 rounds |
|---|--:|
| `arm-N` — lane 6 | 17 |
| `step-N` — one bumper | 6 |
| `cash-N` — scoop 1 collects the position | **17** |
| `play-bumpers-N` — the 20-hit burst | 30 |
| `play-ramp1-N` | **47** |
| `play-ramp2-N` | 27 |
| `play-drops-N` — the five targets | 40 |
| `play-scoop2-N` | 12 |
| `shooter-left-lagrange`, `shooter-right-lagrange` | the `LPA11`/`LPA12` pair |

## Which award each round cashed

Read from the lamp matrix, not guessed. F18 puts the Monolith cycle on lamp
column 3 bits 0-7 (`LC2`-`LC9` = LPA1-LPA8) and column 4 bits 0-1 (`LC10`,
`LC11` = LPA9, LPA10); the Lagrange pair `LPA11`/`LPA12` is column 4 bits 2-3
and is read separately, since it is lit all the time and would otherwise mask
the cycle. The position **chases** rather than resting, so what a round cashes
is whichever lamp is lit as the ball enters the scoop:

| Round | Monolith at the scoop | Award |
|---|---|---|
| `cash-1` | LPA2 | 3,000,000 |
| `cash-2` | LPA7 | Impact Count |
| `cash-3` | LPA4 | 6,000,000 |
| `cash-4` | LPA9 | Special Drop Target |
| `cash-5` | LPA6 | 9,000,000 |
| `cash-6` | LPA1 | Extra Ball |
| `cash-7` | LPA8 | Orbit Flip |
| `cash-8` | LPA5 | Special |
| `cash-9` | LPA10 | Star Ride |
| `cash-10` | LPA7 | Impact Count |
| `cash-11` | LPA4 | 6,000,000 |
| `cash-12` | LPA9 | Special Drop Target |

**Nine of the ten positions were cashed.** The missing one is `LPA3`, Little
Multiball, and its absence is correct rather than a gap: §3.3.3 lights `LPA3`
only while the ORBITS lights are on, and this walk never spells ORBITS. The
`modes/` capture does, and covers the Jupiter side of it.

## What this does and does not establish

It establishes that the simulator can **drive every input the twelve positions
need** — bumpers, lane 6, both scoops, both ramps, all five drop targets and
both shooters — and that each produces screens; and that a twelve-round walk of
a ten-position cycle cashes every position at least once.

Each round is now labelled with the award it cashed, from the lamp matrix, so a
`cash-N` screen has a name. What is still unlabelled is the **play** stages: a
`play-ramp1-7` screen belongs to whatever mode round 7 started, which the table
above gives, but a screen inside a 20-hit bumper burst may belong to the mode or
to ordinary play, and nothing here separates those.
