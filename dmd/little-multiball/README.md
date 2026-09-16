# Little Multiball, isolated

[← Back to the DMD corpus overview](../README.md)

The one Monolith position the [walk](../monolith/README.md) cannot cash and the
[coverage sweep](../coverage/README.md) only arms. **90 distinct screens, 15 new
to the corpus.**

## Why a closed loop is needed

`LPA3` lights only while the ORBITS lights are on, and **the Monolith chases
rather than resting** — its cycle lamps run continuously, so a lock lands on
`LPA3` about one time in ten. No scripted key can be timed to it, which is why
the coverage sweep's six attempts produced an ordinary two-ball lock instead.

So this capture does not press `J` at all. It is driven by a throwaway driver
probe, `SLEIC_LM_AUTO`, which waits for the ORBITS count `[413C:0102]` to reach
its cap of 6 and then takes the lock **on the frame `LPA3` is actually lit**,
by asserting C50 (the entrance) for ten frames and then holding C46 — the one
Jupiter contact the Z80 reports, as remapped code `0x44`. It drops C46 when the
game fires coil 16, so the hold cannot pin the count.

This is the same arrangement `faults/` uses: a probe cited here, applied for the
capture and reverted immediately after. The probe is reproduced at the end of
this file.

## What is confirmed

| | |
|---|---|
| ORBITS at its cap | `[413C:0102]` = 6 |
| `LPA3` lit, and the lock taken on that frame | probe log: *LPA3 lit, taking the lock* |
| Exactly **one** ball locked | `[4134:0030]` goes 0 → **1** and stays there |
| `LTB12` lit at scoop 1 | `LC17`, lamp column 4 bit 4 |

One ball rather than two is what makes this the Little Multiball branch and not
Multiball, which is `[4134:0030]` reaching 2 (§3.3.7).

## What is not

**The release does not happen, and coil 16 never fires.** §3.2.6 has scoop 1
releasing the Jupiter ball for two balls in play; across eight scoop-1 collects
after the lock, `[4134:0030]` stays at 1 and `core_getSol(16)` is never true.

That is consistent with the rules' own open question on coil 16
([`../../docs/iomoon_game_rules.md`](../../docs/iomoon_game_rules.md), *Open
questions*): whether *Sueltabolas de Júpiter* fires in normal play is not
established, and it was not observed in single-ball play either. This capture
narrows it rather than settling it — the coil does not fire for a **single**
lock with `LPA3` lit, which is exactly the case §3.2.6 says should release.

What would settle it is the firmware side: find the writers of the coil-16
wrapper and what gates them, in the same way the `0x44` lock path was traced.

## Capture

Needs the `SLEIC_LM_AUTO` probe below compiled in, `DEBUG_SLEIC` uncommented,
and a seeded NVRAM with credits — see [`../multiball/README.md`](../multiball/README.md).
It also needs the PinMAME fix that makes the Jupiter lock reachable at all,
commit `957cf972`.

```bash
cd pinmame            # with the probe applied and DEBUG_SLEIC enabled
SDL_VIDEODRIVER=dummy SDL_AUDIODRIVER=dummy SLEIC_LM_AUTO=1 \
  ./build-probe/sdl3pinmame iomoon -rompath ./roms -nvram_directory /tmp/nv \
  -nosound -skip_disclaimer -skip_gameinfo -skip_gamewarnings -nothrottle \
  -ftr 6800 -dmd_dump_dir ../sleic-iomoon/dmd/little-multiball \
  -key_script ../sleic-iomoon/scripts/keyscripts/iomoon-little-multiball.keys

cd ../sleic-iomoon
cp scripts/keyscripts/iomoon-little-multiball.keys.marks dmd/little-multiball/iomoon.marks
python3 scripts/dmd_dump_split.py dmd/little-multiball/iomoon.txt \
        --out dmd/little-multiball --marks dmd/little-multiball/iomoon.marks \
        --rom ../pinmame/roms/iomoon/v1_3_01.bin
```

## The probe

Placed at the end of `SWITCH_UPDATE(SLEIC2)` in `src/wpc/sleic.c`, inside the
existing `#ifdef DEBUG_SLEIC`, and reverted after the capture.

```c
  /* Closed-loop Little Multiball: the Monolith chases, so a scripted key cannot be timed
     to LPA3.  Wait for ORBITS at its cap, then take the lock on the frame LPA3 is lit. */
  if (getenv("SLEIC_LM_AUTO")) {   /*TEMPPROBE*/
    static int armed = 0, phase = -1;
    const int orb = cpu_readmem20(0x414c2);
    const int lpa3 = !!(coreGlobals.tmpLampMatrix[3] & 0x04);
    const int lock = cpu_readmem20(0x41370);
    iomoon_dbgFrame++;
    if (orb >= 6) armed = 1;
    if (armed && phase < 0 && lpa3 && lock == 0) {
      phase = 0;
      fprintf(stderr, "%6d [LM] LPA3 lit, taking the lock\n", iomoon_dbgFrame);
    }
    if (phase >= 0) {
      static int released = 0;
      phase++;
      /* Hold the ball on C46 until the game fires coil 16, Sueltabolas de Jupiter --
         holding it through the release is what would pin the counter at 1 for ever */
      if (!released && phase > 30 && core_getSol(16)) {
        released = 1;
        fprintf(stderr, "%6d [LM] coil 16 fired -- releasing\n", iomoon_dbgFrame);
      }
      if (phase < 10)       coreGlobals.swMatrix[5] |= 0x80;   /* C50 entrance */
      else if (!released)   coreGlobals.swMatrix[5] |= 0x04;   /* C46, reports 0x44 */
    }
    { static int lk=-1, lt=-1;
      const int ltb12=!!(coreGlobals.tmpLampMatrix[4]&0x10);
      if (lock!=lk){ fprintf(stderr,"%6d [LOCK] %d\n",iomoon_dbgFrame,lock); lk=lock; }
      if (ltb12!=lt && ltb12){ fprintf(stderr,"%6d [LTB12] on\n",iomoon_dbgFrame); lt=ltb12; }
      else if (ltb12!=lt) lt=ltb12; }
  }
```
