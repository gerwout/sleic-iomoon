# The solenoid, fuse and flipper fault pages

[← Back to the DMD corpus overview](../README.md)

Every page the firmware's direct-input fault dispatch can draw, in both languages —
**42 codes each, and the corpus's second-largest coverage gain: 74 strings move from
missing to present, taking the gate from 306 missing to 232.**

`dmd/faults/` already reached three of these codes and named the mechanism; this walks
all of them, so every coil group and every fuse the machine can blame is on screen.

## What each family draws

`sub_D734B` dispatches on `[413C:00D6]`, F5's 16-way direct-input scan (codes `0x50`-`0x79`,
normally gated off by port-`0x04` bit 0):

| Codes | Page | Example |
|---|---|---|
| `0x50`-`0x64`, 21 of them | `SOLENOID FAIL` / `GROUP` / `SHORT` / `CANNOT CONTINUE`, then hangs | `GROUP: TA3-B3-C3 / SHORT / CANNOT CONTINUE` |
| `0x65`-`0x76`, 18 of them | `SOLENOID FAIL` / `GROUP` / `CUT OR` / `FUSE`, returns normally | `GROUP: TA6-B6-C6 / CUT OR / FUSE F25` |
| `0x77`-`0x79`, 3 of them | the flipper cut-out name / `SEPARATE/BROKEN` | `U.C.FLIPPER / SEPARATE/BROKEN` |

The 21 coil groups are `T17-18-19`, `T20-21-22`, `T23-24-25`, `T26-27-28`, `T29-30`,
`T31-32`, `T33-24`, `T35-36`, `T39-40-41`, `T42-43-44`, `T45-46-47`, `T48-49-50`,
`T51-52`, `T53-54`, `T55-56`, `T57-58`, `TA1-B1-C1`, `TA2-B2-C2`, `TA3-B3-C3`,
`TA5-B5-C5`, `TA6-B6-C6`; the fuses run `F4`-`F15` and `F22`-`F26`.

**`GROUP: T33-24` is the ROM's own text**, not a decode error — every other group numbers
consecutively, so this one is almost certainly a typo for `T33-34` in the string pool
itself. It is recorded as it renders.

Spanish is the same 42 pages with the same group and fuse numbers and its own words:
`GRUPO: T17-18-19 / EN CORTO / IMPOSIBLE SEGUIR`, `CORTADOS O / FUSIBLE F4`,
`C. FLIPPER IZQ. / SEPARADO O ROTO`.

## Capture

**Needs a throwaway probe**, the same one `dmd/faults/README.md` documents for three fixed
codes, generalised to take the code from an environment variable. Two parts, both in
`pinmame/src/wpc/sleic.c` inside the existing `#ifdef DEBUG_SLEIC`, reverted immediately
after this capture — `pinmame`'s own tree carries neither:

- `iomoon_port04()` clears bit 0 of its return while the variable is set. That bit is what
  gates `sub_D734B` at all: `main_loop` clears `[413C:00D9]` at `D2F67`, but the boot
  country-DIP reply folds this port's bit 0 back into it at `D5EFF`, and the driver
  returns that bit high unconditionally, so the whole family is otherwise unreachable.
- `SWITCH_UPDATE(SLEIC2)` writes the code to wherever the inbound queue's own read pointer
  `[4000:1150]` points and sets `[4000:1147]`, which is exactly what the inbound NMI's
  append does (`D01C6`) — once, while `vblankCount` is 400-459, well past the boot
  handshake.

```bash
for c in $(seq 80 121); do            # 0x50 .. 0x79
  h=$(printf "%02x" $c)
  SDL_VIDEODRIVER=dummy SDL_AUDIODRIVER=dummy SLEIC_FAULT_CODE=$c \
  ./build-probe/sdl3pinmame iomoont -rompath ./roms -nvram_directory /tmp/nv -nosound \
    -skip_disclaimer -skip_gameinfo -skip_gamewarnings -nothrottle -ftr 900 \
    -dmd_dump_dir ../sleic-iomoon/dmd/solenoid-test/en/$h \
    -key_script ../sleic-iomoon/scripts/keyscripts/iomoon-faults-attract.keys
done
```

One run per code, because the `SHORT` family hangs by design after drawing. `es/` is the
same sweep with `scripts/keyscripts/iomoont-spain.cfg` copied to `<cfg dir>/iomoont.cfg`.
Each capture is split with `dmd_dump_split.py` against its own `iomoont.marks`.
