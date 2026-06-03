# PinMAME boot session — log artefacts

> **2026-06 correction — the central conclusion of this early boot-only run is now debunked.**
> This run found "zero writes to any YM3812 register" and inferred the chip was **BOM-only /
> never accessed**. That inference was **wrong**: the trace only covered the silent attract/boot
> phase, and the YM3812 **plays the in-game FM music** (10 tracks) — the 80188 drives it directly
> over `/PCS5` (`0xA0280`/`0xA0281`) from a music sequencer at `D000:0D37`/`0D99`, now byte-verified
> in ROM1 and **verified working in the PinMAME driver**. Likewise, the "shared-RAM mapping at
> `0x40000`" used as a stub patch below is **not the real hardware**: segment `4000h` is
> 80188-**private** work RAM, and the inter-CPU link is the **J1 8-bit handshaken byte-port** (no
> shared RAM, no HOLD/HLDA). The boot-path PCs and PCB-init capture remain accurate; treat the
> YM3812 "BOM-only" verdict and the shared-RAM framing as historical, superseded notes.

This directory holds the relevant slices of an `xpinmamed.sdl` log captured by running the existing PinMAME SLEIC stub (`pinmame/src/wpc/sleic.c`, base commit `07f1089`) against the IO Moon ROM set under Xvfb on Linux.

The purpose of the run was to answer the **YM3812 routing** question empirically: does the IO Moon software ever access an address in segment `A000h` other than the four documented DMD register offsets?

## Run setup

```
build: makefile.unixsdl_debug  →  xpinmamed.sdl
runtime: 15s wall, ~1800 emulated 80188 IRQ ticks at the stub's placeholder rate (the real DMD frame rate is the measured ~145 Hz)
display: Xvfb 1024x768x24
sound:   disabled (-nosound -fakesound, no /dev/dsp on the host)
ROMs:    sleic-iomoon/roms/1.3 IPDB latest/  (CRC-verified)
```

Local patches to the stub (kept in working tree, not yet committed):

1. Replaced `pic_w` with a wider `a000_w` / `a000_r` pair covering `0xA0000-0xA0FFF` and annotating the four documented DMD register offsets.
2. Added a RAM mapping at `0x40000-0x41FFF` so the 80188 can read/write segment `4000h` (its private MMCS work RAM — the patch called this "shared RAM", which is wrong; the Z80 has no path into it) without filling the log with "unmapped" warnings.
3. Added a one-shot `MACHINE_INIT(SLEIC)` log line and a sampled-PC log inside `SLEIC_irq_i80188` (every 60th tick).
4. Temporarily cleared `GAME_NOT_WORKING` from the `iomoon` entry in `sleicgames.c` so `showgamewarnings` doesn't block the headless run.

## Files

| File | What's in it |
|---|---|
| `00_summary.txt` | Total log size; distinct A000h writes; A000h offset frequencies; unmapped-access count and samples; final PC. |
| `01_pcb_init.txt` | First ~70 lines of writes the 80188 makes to its Peripheral Control Block during `main_init`. |
| `02_dmd_register_writes.txt` | Every write to segment `A000h` in the run, with the documented-register tag. |
| `03_irq_ticks.txt` | Sampled IRQ-tick log entries with the 80188's PC at each tick. |
| `04_init.txt` | Confirmation that `MACHINE_INIT(SLEIC)` runs. |

## Key findings

1. **80188 boot is fully captured.** The PCB writes in `01_pcb_init.txt` decode exactly to the 30-entry I/O configuration table at ROM offset `0xD0041` that was statically extracted from the disassembly earlier. Cross-validates the static analysis.
2. **DMD register layout matches the documentation.** The four registers (`A000:000` `0x28`, `A000:080` `0x00`, `A000:200` `0x07` then `0x0F` toggle, `A000:300` `0x80`) all appear with the expected values during `dmd_controller_init`.
3. **No undocumented A000h offset was written** in the ~15 s of emulated runtime. At the time this was read as evidence that the YM3812 was BOM-only and never accessed. **That reading is now known to be wrong** (see the correction banner): this run never left the silent boot/attract phase, so it could not have caught the YM3812 — the chip is written over `/PCS5` (`0xA0280`/`0xA0281`) by the music sequencer during gameplay, byte-verified in ROM1 and confirmed working in the driver. The "only two `OUT` instructions / no MPCS chip-select" static premise was also a register-label misread; MPCS *is* configured and the YM3812 is reached by memory-mapped `mov` stores, not `out dx, ax`.
4. **Stub blocker identified.** The 80188 hangs at `PC=0x40024` (segment `4000h`, the 80188's private MMCS work RAM — the stub mislabelled this region as "shared RAM") after about 180 IRQ ticks. The IRQ-tick PCs trace a clean boot path through the `F000h` system code, into `0x01E9C`/`0x03D40`/`0x05BE4` (early game-state setup in ROM2 graphics region), then `0x711AF`/`0x642F3` (graphics-table lookups), then a runaway loop at `0x40024` (executing what is supposed to be code from a location that, in real hardware, is loaded into LMCS-mapped ROM2 graphics but in the current PinMAME stub is unmapped).
5. **Caveat on (3)**: 1800 IRQ ticks is "boot only". The 80188 never reached attract-mode-running state — and (as later confirmed) the YM3812 is used precisely there, in gameplay, which this run never exercised. To reach that state, the next debug session needs ROM2 mapped into REGION_CPU1 at `0x00000-0x7FFFF` (overlaying the `0x40000-0x41FFF` work-RAM window).

## Reproducing

From `pinmame/`, after applying the four local patches above:

```bash
Xvfb :99 -screen 0 1024x768x24 &
DISPLAY=:99 timeout 15 ./xpinmamed.sdl iomoon \
    -rompath /path/to/iomoon-roms-dir \
    -nosound -fakesound \
    -log iomoon_debug.log \
    -nothrottle -skip_disclaimer -skip_gameinfo
pkill Xvfb
```

Then mine the log with the grep patterns in `00_summary.txt`.

## Next step (for whoever picks this up)

1. Define a new `SLEIC_ROMSTART_IOMOON` (or modify `SLEIC_ROMSTART5` only for IO Moon) so ROM2 (v1_3_02.bin) is loaded into `REGION_CPU1` at `0x00000-0x7FFFF` instead of into `REGION_USER2`. The `0x40000-0x41FFF` work-RAM window (the 80188's private MMCS RAM, mislabelled "shared RAM" by this early stub) will overlay ROM2 — that matches the real chip-select priority for that small window.
2. Re-run the debug session and confirm the 80188 progresses past `PC=0x40024` and reaches attract-mode code (PCs should diversify across the F000 system, D000 game logic, and segment 4000 work-RAM access patterns).
3. Look for any A000h write to an offset *other than* 0x000/0x080/0x200/0x300. (This step has since been answered: the YM3812 base is `/PCS5` = `0xA0280` index / `0xA0281` data, written by the 80188 music sequencer during gameplay — so the chip must be **mapped**, not left declared-but-unmapped.)
