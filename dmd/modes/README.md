# Wonderful Thing, Special Drop Probe and the bank

[← Back to the DMD corpus overview](../README.md)

The sequences neither the [Monolith walk](../monolith/README.md) nor the
[multiball capture](../multiball/README.md) can reach. **123 distinct screens,
50 of them new to the corpus.**

## All in one ball, and why that matters

The drop bank starts standing and **resets only at ball start** (§3.3.6), so
flattening it mid-ball is what arms Special Drop Probe *and* what turns the
second Jupiter lock into Wonderful Thing rather than Multiball (§3.3.7). A
drain would put the bank back up and undo both, so none is scripted.

## What fired, with the evidence

Each of these was confirmed from the firmware's own state, read live during the
run, not inferred from the script:

| Sequence | Evidence |
|---|---|
| **ORBITS complete** | `[413C:0102]` climbs to its cap of 6 |
| **Bank cleared** | `LP8` alone lit afterwards — §3.3.6's "clearing the whole bank leaves only LP8" |
| **Special Drop Probe** | `LP7`, `LP8` and `LP9` all lit together, §3.2.7's own signature, after the inner target with the bank flat |
| **Wonderful Thing** | the lock counter `[4134:0030]` goes 1 → 2 with the bank down |
| **Black Hole Power** | `LBH` (`LC60`, lamp column 5 bit 7) lit |
| **Lagrange pair** | `LPA11`/`LPA12` (column 4 bits 2-3) both seen toggling, driven by the two shooters |

**Wonderful Thing is distinguishable from Multiball in the trace, not just by
setup.** The lock counter comes back down **2 → 1 → 0 in two separate steps**,
which is §3.2.2's staged release — "the remaining balls are released slowly,
one after another" — against Multiball's simultaneous release. That is the
rule's own distinguishing behaviour showing up in the firmware's counter.

## Capture

Same tooling as the rest of the corpus, on `iomoon`, and it needs a
`-nvram_directory` that already holds a store with credits — see
[`../multiball/README.md`](../multiball/README.md).

```bash
cd pinmame
SDL_VIDEODRIVER=dummy SDL_AUDIODRIVER=dummy ./build/sdl3pinmame iomoon \
  -rompath ./roms -nvram_directory /tmp/nv -nosound \
  -skip_disclaimer -skip_gameinfo -skip_gamewarnings -nothrottle -ftr 6700 \
  -dmd_dump_dir ../sleic-iomoon/dmd/modes \
  -key_script ../sleic-iomoon/scripts/keyscripts/iomoon-modes.keys

cd ../sleic-iomoon
cp scripts/keyscripts/iomoon-modes.keys.marks dmd/modes/iomoon.marks
python3 scripts/dmd_dump_split.py dmd/modes/iomoon.txt \
        --out dmd/modes --marks dmd/modes/iomoon.marks \
        --rom ../pinmame/roms/iomoon/v1_3_01.bin
```

Like `multiball/`, this needs the PinMAME fix that makes the Jupiter lock
reachable at all — `sleic: fill Io Moon's Jupiter lock from the contact the Z80
reports`, commit `957cf972`.

## Marks

`orbits-lane4-N` / `orbits-letter-N` the six pairs · `orbits-complete` ·
`drop-target-1..5` the bank coming down · `special-drop-probe` and
`probe-expired` · `wonderful-lock-1`, `wonderful-replacement-1`,
`wonderful-thing-lock-2`, `wonderful-replacement-2`, `wonderful-ramp2` ·
`shooter-left-lagrange`, `shooter-right-lagrange`.
