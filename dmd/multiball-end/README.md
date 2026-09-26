# Multiball, played to the end

[← Back to the DMD corpus overview](../README.md)

Multiball from the first Jupiter lock through the Jackpot and Superjackpot to the
**end of the mode**, the end of the ball under it, and the game carrying on
afterwards. **351 distinct screens, 118 of them new to the corpus.**

[`../jackpot/`](../jackpot/README.md) stops with the mode still running, so
nothing in the corpus showed Multiball ending, and nothing showed what the panel
does between the last Jackpot and the next ball. This walk is that route plus the
tail.

## What the tail establishes

Read from the firmware's own cells across a second, deterministic run of the same
script on a build carrying a throwaway work-RAM probe, reverted immediately after
— the score accumulator `413C:00F0`/`00F2`, the ORBITS letter count `413C:0102`,
the lock counter `4134:0030` and the three trough contacts.

**Multiball ends on the drain that leaves one ball, and the firmware clears ORBITS
with it.**

```
frame 12219  drain          three balls -> two, mode still running
frame 12609  drain          two -> one: [413C:0102] resets 6 -> 0
```

§3.2.1 says the mode "ends when only one ball is left". The ORBITS letter count
going back to zero at that same drain is the firmware agreeing: the six letters
are the gate on Jupiter retaining anything (§3.3.7), so another Multiball needs
them spelled again.

**The awards go out with it, which is what makes the end measurable.** The same
two shots pay their Multiball values while the mode runs and their base values
once it has ended:

| Shot | During Multiball | After it ends |
|---|--:|--:|
| Bull's-eye 2 (`LD2`) | **40,050,001** (Jackpot) | 50,001 |
| Ramp 2 (`LR21`) | **80,000,000** (Superjackpot) | 11,111 |

```
frame 10912  +40,050,001   bull's-eye 2   Jackpot
frame 11243  +80,000,000   ramp 2         Superjackpot
frame 11512  +    50,001   bull's-eye 2   repeat inside the mode -- base only, one-shot
frame 13102  +    50,001   bull's-eye 2   after the mode ended
frame 13312  +    11,111   ramp 2         after the mode ended
frame 13971  +   200,000   end of ball
```

The two rows at 11512 and 13102 are the same value for different reasons — the
first because each award is one-shot *inside* a Multiball, the second because
`LD2` is no longer lit at all.

**An extra ball is awarded during the walk**, and `PLAYER EXTRA BALL` stands on the
panel for about **70 seconds of play** before the display settles back to
`1 2 / PLAYER BALL`. A capture that stops sooner looks hung on the banner; it is
not, and play scores normally underneath it. Which of §3.2.9's four routes pays it
is **not settled here**: the award follows the ramp-2 shot at 13310 rather than the
score crossing any threshold 2,000 frames earlier, which is consistent with the
`LR22` route, but attributing it properly needs the `BE.SCORE` / `BE.PAS.8` /
`BE.TRAGAB.` / `BE.RAMPA2` audits (§5.15.5), which `scripts/nvcheck.py` does not
decode yet.

## Driving it: the shepherding is most of the script

The Multiball start is a chain of blocking waits (**F22**) and the simulator's keys
act on **one ball at a time** — the current one, and only while it is on the
playfield. `Down` steps to the next ball, so each wait is answered by first
stepping to the ball that can answer it. The single most useful thing to know:

> `sub_DC6AC` releases with `0xEE` and then waits for the released ball to be
> reported at a **scoop** — `sub_DC675` accepts codes `0x21` and `0x22` and nothing
> else. A lane will not answer it, and the routine re-issues `0xEE` every five
> seconds **indefinitely**, so the mode announces and then sits there.

The tail adds one more of the same kind. After the last ball drains, the served
ball sits in the shooter lane as a **different ball index** from the current one,
so a plunge does nothing until one `Down` selects it. Two `Down`s step past it
again — measured: at the serve the shooter-lane ball is index 2 while `currBall`
is 1, so exactly one `Down` is right, and the same index then stays current for
the playfield keys that follow.

## Capture

Run against the shipping `build/sdl3pinmame` with no probe compiled in, on
`pinmame` commit `84840a9c`, branch `iomoon-multiball`. Needs no pre-seeded store:
the six coin presses in the script bank one credit at country 4.

```bash
cd pinmame
SDL_VIDEODRIVER=dummy SDL_AUDIODRIVER=dummy ./build/sdl3pinmame iomoon \
  -rompath ./roms -nvram_directory /tmp/nv -nosound \
  -skip_disclaimer -skip_gameinfo -skip_gamewarnings -nothrottle -ftr 22000 \
  -dmd_dump_dir ../sleic-iomoon/dmd/multiball-end \
  -key_script ../sleic-iomoon/scripts/keyscripts/iomoon-multiball-end.keys

cd ../sleic-iomoon
cp scripts/keyscripts/iomoon-multiball-end.keys.marks dmd/multiball-end/iomoon.marks
python3 scripts/dmd_dump_split.py dmd/multiball-end/iomoon.txt \
        --out dmd/multiball-end --marks dmd/multiball-end/iomoon.marks \
        --rom ../pinmame/roms/iomoon/v1_3_01.bin
gzip -9 dmd/multiball-end/iomoon.txt
```

4824 frames → 626 scene occurrences, 351 distinct screens, reproduced identically
on the probe build and the shipping build.

## Marks

`credit` · `ball-1-start` · `orbits-lane4-1..6`, `orbits-letter-1..6`,
`orbits-complete` · `jupiter-lock-1`, `replacement-ball-1` ·
`jupiter-lock-2-multiball` · `follow-the-released-ball` ·
`scoop-1-takes-the-released-ball` · `plunge-the-served-ball` ·
`multiball-running` · `scoop-1-takes-the-second-released-ball` ·
`jackpot-1`, `superjackpot-1`, `jackpot-2`, `superjackpot-2` ·
`multiball-three-balls` · `drain-first-of-three` · `two-balls-left` ·
`multiball-over-one-ball-left` · `bullseye2-after-multiball` ·
`ramp2-after-multiball` · `ball-over-extra-ball` · `extra-ball-plunged` ·
`extra-ball-play` · `extra-ball-settled` · `extra-ball-over` ·
`next-ball-plunged` · `next-ball-play` · `end`.

## What this does not settle

**Where a released Jupiter ball physically goes.** The firmware waits for a scoop
report and retries the release coil forever if it does not come, which reads like
a ball that reliably reaches a scoop on its own rather than one the player must
shoot there. §3.2.1 says only that the served ball "hits a contact" and the two
Jupiter balls are then released. The simulator puts a released ball on the open
playfield, so the walk above has to send it to a scoop by hand. Whether the real
playfield feeds Jupiter's release into a *tragabolas* is a layout question neither
ROM answers; a photograph of the release lane, or a scope on the scoop contacts
during a Multiball start, would settle it.

**The award values are read from the score cell, not the panel**, for the reason
[`../jackpot/README.md`](../jackpot/README.md) gives: the in-play score face
overlaps consecutive digits, so the award screens decode only partial digits.
