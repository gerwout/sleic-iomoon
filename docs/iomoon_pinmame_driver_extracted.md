# Io Moon PinMAME driver — extracted from the Bike Race commit

## Purpose

The PinMAME work produced a **fully working Bike Race (SLEIC3)** driver and a
**partially working Io Moon (SLEIC2)** driver, developed together in the same
`src/wpc/sleic.c`. To land a clean, reviewable commit that *only* adds Bike Race,
the Io Moon-specific code was lifted back out, leaving Bike Race intact. This
document records what was removed, where the Io Moon work is preserved, and how to
re-integrate it when the **IC23 PIC16C57 is dumped** (the remaining blocker for
finishing Io Moon).

Nothing was deleted: every line of the Io Moon driver still exists in git on the
`sleic` branch. This doc is the map back.

## Branch layout (pinmame repo, local-only)

| Branch | Base | Contents |
|---|---|---|
| `master` | upstream | the SLEIC **stub** — all four games `GAME_NOT_WORKING`; `sleic.c` = 322 lines |
| `sleic` | master + 5 commits + working tree | **the full Io Moon + Bike Race + cleanup** (the preserved knowledge) |
| `bike-race` | master | **Bike Race only** — the clean commit; Io Moon/Sleic Pin-Ball left as master's stubs |

The Io Moon driver lives on `sleic`:
- 5 committed commits: `517a2eda` → `a6f37208` → `10bfd0ac` → `57cb8b9c` → `cc47fe72`
  (Z80 I/O ports, Z80→80188 mailbox, clocks 80188 10 MHz / Z80 8 MHz / IRQ 977 Hz,
  keyboard input, seg-7000h DMD frame-buffer extract).
- plus the uncommitted working tree on `sleic` (the shared-core generalization,
  the PIC handoff, and the driver cleanup).

`bike-race` was branched from `master`, so its history is `master → (Add Bike Race)`
with **no Io Moon in the diff**.

## What was removed from `bike-race` (Io-Moon-specific, all session-additive)

`src/wpc/sleic.c`:
- Functions: `iomoon_z80_read`, `iomoon_z80_write`, `iomoon_swcode_r`,
  `iomoon_lmcs_r`, `iomoon_irq_gen`, `iomoon_z80_to_188_mailbox`.
- Statics: `iomoon_shared_ram` (+`_size`), `iomoon_z80_to_188_ready`,
  `iomoon_dmd_ack[]` (+`_head`/`_tail`), `iomoon_lmcs_ctrl`.
- Memory/port maps: `SLEIC2_80188_readmem`, `SLEIC2_80188_writemem`,
  `SLEIC2_Z80_readport`, `SLEIC2_Z80_writeport`.
- `SWITCH_UPDATE(SLEIC2)` and the Io Moon `MACHINE_DRIVER_START(SLEIC2)` body
  (reverted to master's stub: `IMPORT_FROM(SLEIC)` + 3 sound chips).
- The Io Moon branches inside the shared handlers, which were gated by a
  `sleic_j1_hold` flag (1 = Bike Race, 0 = Io Moon). With Io Moon gone the flag
  was removed and the handlers collapsed to the Bike Race path. The Io Moon
  alternatives were: PCS5 `0xA0281` = YM3812 data port (Bike Race instead toggles
  A0 on `0xA0280`); PCS0 `/OKCS` strobe on **bit 5 (0x20)** (Bike Race uses bit 4,
  0x10); PCS2 `0xA0100` idle sentinel **0x32** (Bike Race 0x37); and the
  `iomoon_dmd_ack` command-echo on `0xA0100` (see PIC section).

`src/wpc/sleic.h`:
- `SLEIC_ROMSTART5` (Io Moon's ROM layout: ROM2 graphics at 0x00000 via LMCS,
  ROM1 code at 0x80000 via UMCS, OKI ROMs in REGION_USER1) — reverted to master.
- KEPT (Bike Race needs them): the `SLEIC_COMPORTS` additions (flipper remaps to
  L/R-Shift, START/COIN/TILT/TEST cabinet bits) and `SLEIC_ROMSTART7`.

## The shared SLEIC core Bike Race kept (Io Moon will reuse it)

These started as Io Moon code, were generalized for Bike Race, and now live on
`bike-race`. Io Moon should reuse them rather than reintroduce its own:
- `iomoon_periph_r` / `iomoon_periph_w` — the PACS peripheral block (`0xA0000`
  chip-selects): YM3812 (PCS5 `0x280`), OKI control latch (PCS6 `0x300`) + `/OKCS`
  strobe (PCS0 `0x000`), DMD mode (PCS4 `0x200`), the J1 inbound latch (PCS2
  `0x100`).
- `iomoon_submit_dmd_frame`, `iomoon_oki_trigger`/`_latch`/`_pending`/`_prev_strobe`.
- The J1 byte-port mailbox: `iomoon_188_cmd`, `iomoon_j1_inbound`/`_fresh`/`_prev_ctrl`.
- `src/cpu/i86/i86.c` + `.h`: the `change_pc16`→`change_pc20` fix (the 80188
  segfault fix; required by **both** games).

When restoring Io Moon, the LMCS graphics-ROM banking (`iomoon_lmcs_r` +
`SLEIC2_80188_readmem` banking `0x00000-0x3FFFF` between ROM2 frames and ROM1
fonts via PCS0 bits 4/5) must come back — that was the keystone that stopped the
attract freeze.

## The PIC (IC23) handoff — the key open question (needs the dump)

The 80188 writes DMD commands to the PIC (PCS1 `0xA0080`) and the firmware's
`process_input_events` (D5A45) traps at `d5a87` unless it sees a `>=0xF0`
command-ACK on PCS2 `0xA0100` within ~400 ticks. The real IC23 PIC firmware is
**undumped**, so the working tree on `sleic` models the handoff. Two stopgap
models were tried; **both are placeholders** until the dump tells us what the PIC
actually returns:

1. **Command-echo (`dmd_ack`) — the current model on `sleic`.** Bytes written to
   `0xA0080` are queued and echoed back on subsequent `0xA0100` reads (behind any
   fresh Z80 J1 byte); idle returns `0x32`. Rationale: the corrected hardware
   model says the PIC is DMD-raster-only and sends no synthesized vsync/swap
   markers (the `0x47`/`0x46` seen at boot came from the Z80 sync + the firmware's
   own queue, not the PIC).

2. **Per-frame marker phase machine — the earlier model (recovered, not current).**
   ```c
   /* PCS2 0xA0100: PIC feeds a per-frame marker sequence */
   if (iomoon_j1_fresh) return iomoon_j1_inbound;
   switch (iomoon_pic_phase) {
     case 0: iomoon_pic_phase = 1; return 0x47;            /* vsync */
     case 1: if (iomoon_pic_head != iomoon_pic_tail)       /* drain echoed DMD cmds */
               return iomoon_pic_fifo[iomoon_pic_tail++];
             iomoon_pic_phase = 2; return 0x46;            /* buffer swap */
     default: iomoon_pic_phase = 0; return 0x32;           /* end of frame */
   }
   ```
   with `static UINT8 iomoon_pic_fifo[256], iomoon_pic_head, iomoon_pic_tail, iomoon_pic_phase;`
   and the `0xA0080` write doing `iomoon_pic_fifo[iomoon_pic_head++] = data;`.

**Action when the IC23 PIC16C57 is dumped:** disassemble it, determine exactly
what it returns on `0xA0100` (and the real `/OKCS` and bank decode, which also
want the IC7 PAL20L10), and replace whichever stopgap with the faithful model.

## How to finalize Io Moon later

Option A (recommended): once `bike-race` is merged, branch from it and re-apply the
Io Moon driver from `sleic` — un-revert `SLEIC2`, re-add the Io-Moon functions /
maps / `SWITCH_UPDATE(SLEIC2)` / `SLEIC_ROMSTART5` / the `0x281`/`0x20`/`0x32` and
`dmd_ack` paths in `iomoon_periph_*`. The shared core and the i86 fix are already
present on the Bike Race base, so only the SLEIC2-specific pieces above are needed.

Option B: keep developing Io Moon on `sleic` (which already has everything) and
rebase it onto the Bike Race base when ready.

Either way, the verbatim Io Moon code is in git on `sleic` — `git show
cc47fe72:src/wpc/sleic.c` for the committed driver, and the `sleic` working tree
for the latest shared-core + PIC-handoff state.
