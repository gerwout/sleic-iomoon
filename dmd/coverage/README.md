# The coverage sweep

[← Back to the DMD corpus overview](../README.md)

The rules sections the other captures leave out. **147 distinct screens, 62 of
them new to the corpus.**

| Covered here | Rules |
|---|---|
| **Little Multiball** arming | §3.2.6 |
| All eleven lanes, including lane 10 with ORBITS complete | §3.3.1 |
| **Bull's-eye 2**, which no other walk hits | §3.3.5 |
| The inner bank target with the bank **standing** — its ordinary 50,001 rather than the Special Drop Probe path | §3.3.6 |
| The **end-of-ball bonus** countdown, which needs a real drain | *Bonus* |

## Little Multiball

The one Monolith position the [walk](../monolith/README.md) never cashes.
`LPA3` lights only while the ORBITS lights are on, and its award is given at
**Jupiter**, not at the scoop: one ball locked with `LPA3` lit lights `LTB12`
(`LC17`, lamp column 4 bit 4) at scoop 1, a ball is served, and putting that
ball into scoop 1 releases the Jupiter ball.

Confirmed from the lamps: with ORBITS at its cap of 6, **`LPA3` lights (38
events) and `LTB12` lights with it (38 events)**, flashing around each lock,
where neither ever lights in a walk that does not spell ORBITS.

The Monolith chases rather than resting, so a lock has roughly one chance in
ten of landing on `LPA3` — which is why this script makes six attempts of
{lock, replacement ball, scoop 1} instead of one. **What is confirmed is the
arming**: `LPA3` and `LTB12` lit, the lock taken, scoop 1 entered. The release
step that puts the second ball into play is not separately evidenced here — the
lock counter `[4134:0030]` goes 1 → 2 across the attempts rather than 1 → 0 at
the scoop, so at least one attempt became an ordinary two-ball lock instead.
Isolating a single Little Multiball needs the Monolith position read live and
the lock timed against it, which this script does not do.

## Capture

Same tooling as the rest of the corpus, on `iomoon`, and it needs a
`-nvram_directory` that already holds a store with credits — see
[`../multiball/README.md`](../multiball/README.md). Like `multiball/` and
`modes/` it needs the PinMAME fix that makes the Jupiter lock reachable,
commit `957cf972`.

```bash
cd pinmame
SDL_VIDEODRIVER=dummy SDL_AUDIODRIVER=dummy ./build/sdl3pinmame iomoon \
  -rompath ./roms -nvram_directory /tmp/nv -nosound \
  -skip_disclaimer -skip_gameinfo -skip_gamewarnings -nothrottle -ftr 11400 \
  -dmd_dump_dir ../sleic-iomoon/dmd/coverage \
  -key_script ../sleic-iomoon/scripts/keyscripts/iomoon-coverage.keys

cd ../sleic-iomoon
cp scripts/keyscripts/iomoon-coverage.keys.marks dmd/coverage/iomoon.marks
python3 scripts/dmd_dump_split.py dmd/coverage/iomoon.txt \
        --out dmd/coverage --marks dmd/coverage/iomoon.marks \
        --rom ../pinmame/roms/iomoon/v1_3_01.bin
```

## Marks

`orbits-1..6`, `orbits-complete` · `lm-lock-N`, `lm-replacement-N`,
`lm-scoop1-N` for the six Little Multiball attempts · `lane-1..9`,
`lane-10-orbit-with-orbits`, `lane-11` · `bull-eye-2` ·
`inner-bank-standing` · `scoop-2` · `drain-for-bonus`, `bonus-counted`.
