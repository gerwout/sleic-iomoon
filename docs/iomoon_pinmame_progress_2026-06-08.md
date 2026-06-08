# IO Moon PinMAME driver — progress & findings (2026-06-08)

This documents a session that re-integrated the IO Moon (`SLEIC2`) driver onto the
`io-moon` branch of the pinmame fork and pushed it well past the previous "stub"
state. The driver now **boots, renders real DMD graphics, scans the switch matrix,
and reaches the attract / factory-config screen**. The pinmame branch is kept LOCAL
(uncommitted) per the project constraint; this doc records what was learned so it can
be reproduced.

## Status summary

| Subsystem | State |
|---|---|
| Boot / interrupts / memory map | ✅ working (10 MHz 80188 + 8 MHz Z80, LMCS banking, 3-IRQ model) |
| DMD rendering | ✅ **renders real text/graphics** (was blank) |
| Switch matrix scan (Z80) | ✅ working (verified: forcing switches → Z80 emits codes) |
| Ball trough / "BALL MISSING" | ✅ cleared by holding C6/C7/C8 |
| Attract / factory screen | ✅ reaches "VALORES FABRICA / PULSE START" |
| Coins / credits / NVRAM | ❌ blocked — NVRAM not mapped/persisted |
| Service menu (TEST) | ⏳ keys wired, entry path being validated |
| Sound (YM3812 + OKI) | ⏳ scaffolded, gated on reaching gameplay |

## The DMD fix (the big one)

The 2-plane DMD **pixel buffer is at physical `0x40000` (plane0) / `0x40200`
(plane1)** in seg-4000h work RAM — confirmed via `dmd_buffer_swap` (F00C4), which
clears `4000:0000-03FF`. The earlier driver read pixels from
`base = (display_buf_seg1<<4) + display_buf_ptr1` (the `4000:1150` pointer), but that
pointer is the **DMD marker/event QUEUE** (`0x1220`, holding the `0x47/0x40/0x46` sync
bytes), *not* pixels — which is why the DMD was blank. Fix: decode `0x40000`/`0x40200`,
weight `pixel = 2*plane0_bit + plane1_bit` (plane0 = MSB), submit once per frame on the
`0xA0200` bit-4 write (the NMI's `[1138]|0xD0` vblank strobe).

## PIC (IC23) marker model on PCS2 `0xA0100`

`0xA0100` is read from **exactly one place — the NMI handler `dmd_vblank_isr` (D016D,
PC `d0190`)**, once per frame. It appends any non-`0x32` byte to the display queue and
sets frame-pending `[4000:1147]`. Consumers then read the queue: `vsync_check` (D5D1B)
needs `0x47`, `frame_counter_update` (D5D8D) needs `0x45/0x46`, `lamp_set` (D5AEB)
returns 1 on `0x40` (upper flipper). The **Z80 sends only one J1 byte (`0x47`) at boot
(Z80 PC 0133)** then nothing — so the per-frame markers must be modeled. A **per-frame
marker phase machine** (`0x47` vsync → drain echoed `0xA0080` cmds → `0x46` swap →
`0x32` eof) on the Io Moon `0xA0100` read makes vsync run and the attract animate; an
echo-only model gets stuck at boot. (Exact timing still needs the undumped IC23 PIC.)

## Switch table (extracted from the Z80 ROM)

The Z80 scan (`0x2ED3`) strobes a row via **port 0x82** (shared lamp-column / switch-row
strobe — NOT port 0x87 as a stale doc revision claimed) and reads the column on port
0x02. Per-switch handlers (`sub_2fe7` for row 0, etc.) write the code to the mailbox
`0xC0FC` and dispatch. **Matrix code = `0x0A + row*8 + bit`** (rows 0-5 = PinMAME
`swMatrix[1..6]`):

| Code | Switch | Notes |
|---|---|---|
| 0x0A / 0x0B / 0x0C | **C6 / C7 / C8** | **the 3 ball-trough sensors** (row0 bits 0/1/2) |
| 0x0D | C9 | outhole / ball drain |
| 0x0E / 0x0F | C10 / C11 | **Left / Right flipper EOS** (row0 bits 4/5) |
| 0x10 / 0x11 | C12 / C13 | (row0 bits 6/7) |

**Solenoid bug root cause:** forcing the whole of row 0 closed the flipper-EOS switches
(0x0E/0x0F) → the firmware latched the flipper coils on → "rows of solenoids stuck on".
Hold **only** bits 0/1/2 (the trough) to put balls in the trough cleanly.

Direct switches (Z80): flippers on port 0x00 (`swMatrix[0]`) bit0 = L (`0x3E`), bit1 = R
(`0x3F`), bit4 = upper (`0x40`); port 0x03 (`swMatrix[9]`) bit3 = START (`0x41`), bit2 =
COIN (`0x42`); TILT = `0x32`, TEST = `0x33`. Z80 routines: `check_start_test` (0x0D76),
`flipper_event_handler` (0x1242, reads debounced `0xC0E3`), `handler_start_btn` (0x1292)
/ `handler_coin_insert` (0x12D8) — both `ret z` if `ball_in_play` (`0xC06A`) == 0, i.e.
they only forward START/COIN during a game, not in attract.

The 80188 reads dispatched switch codes from **`last_switch_code` = 413C:00D6 = phys
`0x41496`** (e.g. `dmd_anim_resource_play` D7B7A jump table for codes 0x0E-0x44;
`button_filter_accept_start` D7B47 accepts 0x40/0x41/0x42). The display-queue path
(read by `vsync_check`/`lamp_set`) is separate from this mailbox path.

## Service menu (from the Spanish manual, sec. 5)

Enter with **TEST**. Navigation: **LEFT flipper = move cursor, RIGHT flipper =
select/enter, START = back/confirm, TEST = exit**. The 80188 enters the menu when
`game_status_byte` `[4000:1001] == 5` (checked at `da9a9`).

**Factory reset (BORRADO DE TODO, 5.15.10): `ESTADISTICAS → BORRADO → TODO` →
"VALORES FABRICA / PULSE START" → press START.** Default settings seen in the manual:
NUM. BOLAS = 3, ORBITAS = 10 (extra ball), free game at 6 000 000 / 8 000 000.

## ✅ NVRAM BREAKTHROUGH — the machine now reaches gameplay

**The IO Moon 28C64A NVRAM is at 80188 segment `5040h` = physical `0x50400-0x523FF`.**
The driver mapped that address as read-only ROM2 graphics, so `config_validate`
(the real one — `display_flush_2refs` @ D05C0/D05CB) could never match the factory
signature and the machine sat on "VALORES FABRICA" forever. `config_validate`
byte-compares 8 blocks at seg `5040h` against ROM-resident defaults; `config_load_defaults`
(D06ED) writes them. The blocks `(nvram_off, ROM_off in D000 seg, len)`:
`(0x000,0x7A9,0x0F) (0x047,0x7B8,0x33) (0x0DA,0x7EB,0x20) (0x130,0x80B,0x35)
(0x180,0x840,0x1A) (0x1D0,0x7EB,0x20) (0x27D,0x80B,0x35) (0x2E1,0x840,0x1A)` —
the `(C) SLEIC 1.994` signature + operator strings (ROM file `0x507A9`), the **same
strings as the Bike Race NVRAM image**.

**Fix:** map `0x50400-0x523FF` as battery-backed RAM and seed it on fresh boot by
replicating `config_load_defaults` (copy those 8 ROM blocks). Then `config_validate`
passes and the state machine cycles **attract (1) ↔ game-active (2)** — a game runs.

**Still to do for a polished game:** the seed has only the 8 *text* blocks
`config_load_defaults` writes — not the **game settings** (coins-per-credit, NUM.BOLAS=3,
free-game points) that the full BORRADO-DE-TODO reset writes, so credits are
free-play-ish; the **gameplay DMD** renders to a different page than attract (blank in
game); the **intro/attract auto-advance** is PIC-timed (waits on upper-flipper 0x40);
**sound** (YM3812/OKI) is unverified in-game; **lamps/coils** go via the un-traced
80188→Z80 reverse path (IC8 PAL).

## (Historical) NVRAM analysis — what the blocker looked like before it was found

- The SLEIC2 driver originally mapped **no persisted NVRAM** (it inherited
  `generic_0fill` with nothing bound), so a factory reset did **not** persist.
- The runtime config the game reads lives in seg-4000h work RAM (`coin_handler` D4CF4
  reads coin/credit config at `413C:0016 / 0028 / 0031`; `credit_available` at
  `413C:00D4` = `0x41494`). This region is **interleaved with volatile state** (display
  queue `0x41147`/`0x41220`, stack `0x41520`), so the whole segment can't be blindly
  persisted.
- The separate **28C64A** (8 KB, IC14) 80188 address is still unidentified (it can't be
  at Bike Race's seg `0x1040` because that's IO Moon's LMCS ROM window).
- Observed: with the trough held, the machine reaches "VALORES FABRICA / PULSE START"
  but pressing START does not advance even though the switch registers — consistent with
  the factory-init writing an unmapped NVRAM and re-validation then failing.
- **Plan (mirrors the Bike Race method):** get the TEST/service menu working, do
  `BORRADO DE TODO`, capture the firmware-written config, and embed it as a factory seed
  in the driver (plus an `NVRAM_HANDLER` to persist it).

## Reproduction notes

- Driver: `pinmame/src/wpc/sleic.c` SLEIC2 path (re-integrated from the `sleic`-branch
  WIP, dangling commit `b9c4514`, with the DMD-buffer + port-0x82-strobe + Model-A
  marker fixes above). Build `makefile.unixsdl`; run headless with Xvfb (24bpp) +
  `-skip_disclaimer -skip_gameinfo -skip_gamewarnings -ftr N`.
- Memory map: LMCS `0x00000-0x3FFFF` banked (ROM2 frames / ROM1 fonts via PCS0 bits
  4/5), work RAM `0x40000-0x47FFF`, PACS `0xA0000`, UMCS code `0x80000-0xFFFFF`
  (`0xC0000+`). `SLEIC_ROMSTART5` must load ROM2 (`v1_3_02`) at `REGION_CPU1[0x00000]`.
