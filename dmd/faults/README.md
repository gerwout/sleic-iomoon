# Fault-screen corpus

[← Back to the DMD corpus overview](../README.md)

The twelve strings a healthy `iomoont` run never draws: `BALL OUT ERROR`, `BALL
MISSING`, `WARNING`, `ONE TILT`, `TWO TILTS`, `SEPARATE/BROKEN`, `EEPROM
FAILURE`, `SOLENOID FAIL`, `SHORT`, `CANNOT CONTINUE`, `WRONG BIOS`, `CUT OR`.
All twelve are captured here. Each capture is one short, targeted headless run
of `build/sdl3pinmame iomoont`; none is a fragment of the ordinary attract/game
walk in `dmd/en/` or `dmd/es/`.

Every fault but one (the tilt warnings) needed a throwaway probe in
`pinmame/src/wpc/sleic.c`, gated on `getenv("SLEIC_FORCE_FAULT")` and reverted
in the commit right after this capture — `pinmame`'s own tree carries none of
it. This file is what makes the capture reproducible anyway: the exact
condition each screen needs, cited against `asm/baseline-2026-09/findings.md`
and the `iomoon_80188.lst` addresses that show it, and the exact probe and key
script that forced it.

## Layout

Same conventions as `dmd/en/` and `dmd/es/` (see `../README.md`), one
directory per fault instead of per language:

- `<fault>/iomoont.txt` — the raw frame dump (Serum/Pin2DMD format).
- `<fault>/iomoont.marks` — the driving key script's mark sidecar.
- `<fault>/screens.csv` — one row per scene occurrence, `dmd_dump_split.py
  --rom` output.
- `<fault>/screens/<NNNN-label>/repr.txt` — one representative frame per
  distinct screen. Committed; `frame-*.txt` is not (`.gitignore`).

## The twelve strings, and which capture has each

| String | Capture | Scene | Screen text |
|---|---|---|---|
| `EEPROM FAILURE` | `eeprom` | `0004-boot`, 716-749 ms | `EEPROM FAILURE` / `CANNOT CONTINUE` |
| `CANNOT CONTINUE` | `eeprom`, `wrongbios`, `solenoid-short` | — | see above and below |
| `WRONG BIOS` | `wrongbios` | `0002-ball-1-start`, 4666-4699 ms | `WRONG BIOS` / `CANNOT CONTINUE` |
| `BALL OUT ERROR` | `ball-out-error` | `0057-ball-1-start`, 19949-19983 ms | `BALL OUT ERROR` |
| `BALL MISSING` | `ball-missing` | `0004-boot`, 1433 ms (also `0005`/`0006`/`0008`) | `BALL MISSING` |
| `WARNING` | `tilt` | `0057-tilt-1`, `0060-tilt-2` | `WARNING` / `ONE TILT` and `WARNING` / `TWO TILTS` |
| `ONE TILT` | `tilt` | `0057-tilt-1`, 8466 ms | `WARNING` / `ONE TILT` |
| `TWO TILTS` | `tilt` | `0060-tilt-2`, 15150 ms | `WARNING` / `TWO TILTS` |
| `SOLENOID FAIL` | `solenoid-short`, `solenoid-cut` | `0010-boot`, `0009-boot` | see below (present in the raw frame, not machine-decoded — see Decoding notes) |
| `SHORT` | `solenoid-short` | `0010-boot`, 6983 ms | `SOLENOID FAIL` / `GROUP: T17-18-19` / `SHORT` / `CANNOT CONTINUE` |
| `CUT OR` | `solenoid-cut` | `0009-boot`, 6849-6866 ms | `SOLENOID FAIL` / `GROUP: T17-18-19` / `CUT OR` / `FUSE F4` |
| `SEPARATE/BROKEN` | `flipper-broken` | `0009-boot`, 6849-6866 ms | `L.C.FLIPPER` / `SEPARATE/BROKEN` |

`BALLS OK`, the healthy counterpart of `BALL MISSING`, is not one of the
twelve and is not recaptured here — it is already in the committed
`dmd/en/screens.csv` (scene id 4, label `boot`, 1099 ms), found before writing
any probe, per the "check first" rule this task was given.

## Scene occurrences vs. distinct screens

| Capture | Frames | Scene occurrences | Distinct screens |
|---|---|---|---|
| `eeprom` | 7 | 4 | 4 |
| `wrongbios` | 4 | 2 | 2 |
| `ball-out-error` | 301 | 57 | 55 |
| `ball-missing` | 12 | 8 | 5 |
| `solenoid-short` | 204 | 10 | 9 |
| `solenoid-cut` | 408 | 18 | 13 |
| `flipper-broken` | 409 | 17 | 12 |
| `tilt` | 226 | 62 | 59 |

## Decoding notes

`dmd_dump_split.py --rom`'s h=9 face reads most of these cleanly, but two
things are worth stating precisely:

- **A two-line screen can run off either edge of the 32-row panel by exactly
  one row**, and `_scan_face`'s fixed-stride scan then misses that line
  entirely (a real clip, not a decoder bug): `eeprom`'s and `wrongbios`'s
  second line (`CANNOT CONTINUE`) sits at rows 24-31 with the glyph cell's own
  9th row falling past row 31 (the panel's last), and the three
  `solenoid-*`/`flipper-broken` screens' first line (`SOLENOID FAIL`, or
  `L.C.FLIPPER` in `flipper-broken`, where `SOLENOID FAIL` is not drawn — see
  below) sits at rows 0-6 with its own top row falling before row 0. Both were
  confirmed by hand: padding the missing row with zeros and matching against
  `iomoon_strings.glyph_bitmaps()` byte-for-byte reproduces the ROM's own
  glyph bitmaps for the full string, row for row, not merely a visual
  resemblance.
- `flipper-broken`'s screen draws no `SOLENOID FAIL` line at all — confirmed
  the same way (no bitmap match at any row offset) — consistent with
  `sub_E0A51` (below) never calling the routine that draws it.

## The conditions, cited

### `EEPROM FAILURE` / `CANNOT CONTINUE` — capture `eeprom`

`sub_D622C` (called from `main_loop` every pass, F10) checks the NVRAM
signature (`sub_D05C0`, comparing the segment-5040 window against fixed
copyright-block constants in ROM). On the first failure it calls `sub_D53C9`,
which draws the **recoverable** `SETTING` / `DEFAULT VALUES` / `PRESS START`
triple (already in `dmd/en/screens.csv`, scenes 1-2, and not a fault) and
blocks for one inbound J1 byte; `sub_D06E2` then rewrites the defaults and
`sub_D05C0` runs **again**. Only if that second check *also* fails does
`sub_D536C` draw `CANNOT CONTINUE` / `EEPROM FAILURE` and the routine hang
forever (`D6254: JMP D6254`) — a truly unwritable store, not an ordinary blank
one.

Nothing in `iomoon_nvram_w` can make a write fail on its own (it is a plain
array store), so the probe corrupts the **read** side instead: `iomoon_nvram_r`
returns `~iomoon_nvram[offset]` for offsets below `0x0F` (the 15-byte
signature prefix, F10) whenever `SLEIC_FORCE_FAULT=eeprom` — every read comes
back wrong regardless of what was just written, so both checks fail
identically and the second, unrecoverable path is the only one that can be
reached.

### `WRONG BIOS` / `CANNOT CONTINUE` — capture `wrongbios`

`sub_D5A45` / `sub_D5A8B` (`main_loop`'s own boot-time country-DIP query, F11)
push Z80 command `0xF9`, arm a 400-tick countdown (`[4000:113D]`), and poll a
wait routine for the reply. If the countdown reaches zero with no reply ever
seen, `sub_D54E6` draws `CANNOT CONTINUE` / `WRONG BIOS` and the caller hangs
(`JMP $`, its own address, right after the call) — the Z80 side of the
handshake failing to answer at all.

The probe swallows exactly that one command: `sleic2_periph_w`'s PCS4 strobe
handler (the outbound J1 handshake, F6) returns before pulsing the Z80's NMI
when the byte about to go out is `0xF9` and `SLEIC_FORCE_FAULT=wrongbios` — the
Z80 never learns the command was sent, so it never can reply, and the 400-tick
timeout is genuine.

### `BALL OUT ERROR` — capture `ball-out-error`

`sub_DC09C` / `sub_DC0D0` poll for the Z80's reply to command `0xE9` (serve a
ball, F15: `2B03`, five tries of `0x3E8` ticks each against the trough's exit
contact, bit 3). A reply of `0x4A` ("gave up") rather than `0x45` ("served")
makes them call `sub_DA879`, which draws `BALL OUT ERROR` and hangs
(`D000:DA901: JMP DA901`) — the firmware's own account of a jammed kicker,
five genuine tries and all.

The probe holds bit 3 (`IOMOON_EXIT_BIT`) of the trough switch column low
every frame when `SLEIC_FORCE_FAULT=ball-out-error`, after `iomoon_ball_update`
and any registered simulator have had their say — so whatever serves the
other three contacts, the exit contact itself never closes and the Z80's own
five-try retry is what discovers and reports the fault, not an invented reply.

### `BALL MISSING` — capture `ball-missing`

The boot-time trough poll (`D5D98`-`D5E38`, gated on SW40-5, F15) answers Z80
command `0xED`: `0x45` ("balls home") draws `BALLS OK`; `0x46` (the trough not
satisfied, running the eject sequence) draws `BALL MISSING`.

`iomoont`'s own registered simulator seeds a full trough by default
(`SLEIC2_SIM_INPUT_PORTS_START(name,3)`, `sim.h`), and `iomoon_ball_update`'s
own "Balls" parameter is moot once `coreGlobals.simAvail` is set — that early
return leaves the trough exactly as the generic simulator already set it. The
probe clears all four trough-column bits (three count contacts, F15, plus the
exit contact) every frame when `SLEIC_FORCE_FAULT=ball-missing`, after
everything else has run, so the trough reads empty regardless of what seeded
it.

### `WARNING` / `ONE TILT` / `TWO TILTS` — capture `tilt`

No probe. `sub_D9EBB`, the tilt contact's own in-game handler (F5 code `0x3E`),
tests the per-ball warning budget `[4134:0033]` — reloaded at every ball start
from NVRAM `0x42` minus one (F10) — and while it is still nonzero calls
`sub_DA57E` → `sub_DA468`, which always draws `WARNING` plus `ONE TILT` or
`TWO TILTS`; only once the budget reaches zero does a further tilt skip the
warning screen entirely and go straight to a full tilt (matches
`dmd/en/`'s own committed corpus, which shows zero scenes for its own single
tilt press under the factory default — see its "Open items"). The factory
default (`0x42 = 1`) gives a **zero**-warning budget, so an unmodified NVRAM
never shows either screen; `scripts/keyscripts/iomoon-faults-tilt.keys`'s own
header gives the one-line NVRAM edit (byte `0x42 = 3`, budget 2) this capture
needs before it runs, and the two TILT presses it scripts land on `ONE TILT`
then `TWO TILTS` in order.

### `SOLENOID FAIL` / `SHORT` / `CUT OR` / `SEPARATE/BROKEN` — captures `solenoid-short`, `solenoid-cut`, `flipper-broken`

`sub_D734B` dispatches on `[413C:00D6]` (F5's 16-way direct-input scan, codes
`0x50`-`0x79`, normally gated off by port-`0x04` bit 0): `0x50`-`0x64` →
`sub_DA7EB` → `sub_E0C24`, which persists the code to NVRAM `0x31D` and draws
`SOLENOID FAIL` / the component's `GROUP` name / `SHORT` / `CANNOT CONTINUE`,
then hangs; `0x65`-`0x76` → `sub_DA5B5` → `sub_E0B0A`, which draws `SOLENOID
FAIL` / `GROUP` / `CUT OR` / `FUSE` and returns normally (no hang, no NVRAM
write); `0x77`/`0x78`/`0x79` → `sub_DA6E4` → `sub_E0A51`, which draws
`L.C.FLIPPER` / `R.C.FLIPPER` / `U.C.FLIPPER` plus `SEPARATE/BROKEN` and also
returns normally.

Two separate things gate this dispatch, both confirmed live (a temporary
diagnostic read of `[413C:00D9]`, `[413C:00D6]` and `[4000:1147]`, since
reverted with everything else):

1. `sub_D734B`'s own first instruction is `CMP [413C:00D9],0` / `JNE <return
   0>`. `main_loop` clears `[00D9]` to 0 right after the boot handshake
   (`D2F67`), but a later poll (`D5EFF`) folds the boot-time country-DIP
   query's own reply (Z80 command `0xF9`, `IN($04)|0xF0`, F11) back into
   `[00D9]` through that reply's own bit 0 — and this driver's
   `iomoon_port04()` returns bit 0 = 1 unconditionally (`IOMOON_PORT04_IDLE`,
   an "idle" bit F5 documents as unmapped to any switch). So `[00D9]` latches
   to 1 forever after the very first boot, in **every** run of this driver as
   it stands, and the whole `SOLENOID FAIL`/`CUT OR`/`SEPARATE-BROKEN` family
   is unreachable without changing that one bit.
2. Even with `[00D9]` clear, `[413C:00D6]` only carries a fault code if the
   inbound byte queue (`4000:1220-12E7`, F6/F12) genuinely holds one — and the
   firmware never puts one there in this ROM, because the 16-way scan that
   would (F5) is gated off.

Two probes, together:

- `iomoon_port04()` clears bit 0 of its return value when
  `SLEIC_FORCE_FAULT` is `solenoid-short`, `solenoid-cut` or
  `flipper-broken` — the one bit item 1 identifies, changed nowhere else on
  this port.
- `SWITCH_UPDATE(SLEIC2)` writes the fault code directly to the address the
  queue's own read pointer (`[4000:1150]`, a far pointer, F6/F12) already
  points at, and sets `[4000:1147]` (the same byte the real inbound-NMI sets
  to `0xFF` on every genuine arrival, `D01C6`) — exactly what the NMI's own
  append does, sourced from this probe instead of a J1 strobe, once, while
  `locals.vblankCount` is 400-459 (well past the boot handshake).

`SLEIC_FORCE_FAULT=solenoid-short` writes `0x50`, `solenoid-cut` writes
`0x65`, `flipper-broken` writes `0x77` (`L.C.FLIPPER`; `0x78`/`0x79` are not
exercised here).

These three use `scripts/keyscripts/iomoon-faults-attract.keys`, not the
credit+START script: the first attempt combined the injection with a real
coin and START press, and the extra queue traffic that generates shifted
which component the injected byte landed on (measured: a `solenoid-cut`
request drew `SHORT`, not `CUT OR`). The boot-only walk does not have that
problem — the queue is otherwise idle when the probe writes to it.

## Reproducing a capture

Every run: delete `~/.sdl3pinmame/cfg/iomoont.cfg` and wipe the NVRAM
directory first (`pinmame-ab-test-confounds`), and check out `pinmame`'s
`iomoon-sim` branch with the probes re-applied from this file's own citations
(they are not in the committed tree). Then, from `pinmame/`:

```bash
SLEIC_FORCE_FAULT=<fault> SDL_VIDEODRIVER=dummy SDL_AUDIODRIVER=dummy \
  ./build/sdl3pinmame iomoont -rompath ./roms -nvram_directory /tmp/nv -nosound \
  -skip_disclaimer -skip_gameinfo -skip_gamewarnings -nothrottle -ftr 4200 \
  -key_script ../sleic-iomoon/scripts/keyscripts/<script>.keys \
  -dmd_dump_dir ../sleic-iomoon/dmd/faults/<fault>
```

| `<fault>` | `<script>` |
|---|---|
| `eeprom`, `wrongbios`, `ball-out-error` | `iomoon-faults` |
| `ball-missing`, `solenoid-short`, `solenoid-cut`, `flipper-broken` | `iomoon-faults-attract` |
| (tilt: no `SLEIC_FORCE_FAULT`) | `iomoon-faults-tilt`, run against an NVRAM already patched per that script's own header |

Then split: `python3 scripts/dmd_dump_split.py dmd/faults/<fault>/iomoont.txt
--out dmd/faults/<fault> --marks dmd/faults/<fault>/iomoont.marks --rom
../pinmame/roms/iomoon/v1_3_01.bin`.
