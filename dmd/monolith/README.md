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

## What this does and does not establish

It establishes that the simulator can **drive every input the twelve positions
need** — bumpers, lane 6, both scoops, both ramps, all five drop targets and
both shooters — and that each produces screens; and that a twelve-round walk of
a ten-position cycle cashes every position at least once.

It does **not** yet label each screen with the named award it belongs to. Doing
that needs either the lamp matrix (F18 puts the Monolith on `LC2`–`LC13`) read
alongside the frames, or the per-screen DMD text decoded and matched against the
award names. Until then the marks say which round and stage a screen came from,
not which of the ten awards was showing.
