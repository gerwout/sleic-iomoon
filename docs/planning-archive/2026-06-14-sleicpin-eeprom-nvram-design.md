# Sleic Pin-Ball — EEPROM/NVRAM factory-image reconstruction

**Date:** 2026-06-14
**Game:** `sleicpin` — Sleic Pin-Ball (1993), SLEIC1 machine
**Status:** design approved; ready for implementation plan

## Problem

Running `sleicpin` in PinMAME halts at boot with the Spanish DMD message:

> *Atención: Memoria EEPROM en mal estado. Imposible Seguir.*
> ("Attention: EEPROM memory in bad condition. Cannot continue.")

The 80188 game CPU validates its battery-backed NVRAM at power-on. `sleicpin`
currently inherits the base SLEIC machine driver, whose NVRAM is
`generic_0fill` (zero-filled) mapped at `0x10100-0x10900`. A zero-filled NVRAM
fails the firmware's integrity check, so the firmware refuses to continue.

This is the **same pre-fix state Bike Race (SLEIC3) was in.** Bike Race was
fixed by reconstructing the factory NVRAM image and seeding it on a fresh boot
(`src/wpc/sleic.c:323-394`, `NVRAM_HANDLER(SLEIC3)`). The Bike Race NVRAM begins
with the signature string `"(C) SLEIC 1.994"` followed by config and coin/credit
tables; the working fix embeds the non-zero head of the firmware's own
factory-reset output and lets `core_nvram` zero-fill the tail.

## Goal & success criteria

`sleicpin` boots **past** the EEPROM validation: the "Memoria EEPROM en mal
estado / Imposible Seguir" message no longer appears and the game proceeds to
attract mode. Verified **headless** with before/after DMD frame capture.

**Out of scope:** full gameplay correctness, sound, switch input, I8039 DMD
timing. This effort targets only the EEPROM gate and reaching attract.

## ROM → CPU map (`SLEIC_ROMSTART4`, confirmed in `sleic.h`)

| ROM            | Size   | Region                | Role |
|----------------|--------|-----------------------|------|
| `sp03-1_1.rom` | 128 KB | CPU @ `0xe0000`       | **80188 game code — EEPROM check + DMD message live here** |
| `sp04-1_1.rom` | 32 KB  | IO @ `0x0000`         | Z80 I/O code (switch scan, J1 link, possible reset/menu triggers) |
| `sp01-1_1.rom` | 8 KB   | DISPLAY @ `0x0000`    | I8039/MCS-48 DMD rasteriser |
| `sp02-1_1.rom` | 512 KB | `REGION_USER1`        | graphics (DMD frames) + OKI sound samples — data, not code |

All four CRC32s verified against the `sleicpin` `ROM_START` in `sleicgames.c`.

## Approach: hybrid factory-image reconstruction (Approach C)

Statically seed the minimum bytes needed to pass the gate so the firmware boots,
then let the running firmware perform its own factory-reset to populate the
complete image, capture that, and embed it. Combines static reliability (to get
booting) with runtime completeness (the firmware fills every secondary table
correctly). This is effectively how the working Bike Race image was produced.

## Phases

### Phase 1 — Disassemble
Output to `sleic-iomoon/research/sleicpin_disasm/` (parallel to `bikerace_disasm/`):

- `sp03` → `ndisasm -b 16` → `sp03_80188_ndisasm.asm`
- `sp04` → `z80dasm` → `sp04_z80dasm.asm`
- `sp01` (I8039), `sp02` (data) → `strings`/structure scan only
- Locate the *"EEPROM en mal estado"* / *"Imposible Seguir"* text — as ASCII in
  `sp03`, or DMD-font-encoded in `sp02` — and find its cross-reference.

### Phase 2 — Analyze the EEPROM check  *(review checkpoint)*
- Trace back from the error-string xref to the validation routine.
- Determine: NVRAM physical address + size; **what** is validated (signature
  string? checksum? a stored pointer / jump vector?); the pass/fail branch.
- **Explicitly verify the "NVRAM holds a memory address to jump to"
  recollection** — confirm or refute against the actual code, and record what is
  truly checked.
- Identify the firmware's factory-reset / NVRAM-init subroutine entry address
  (needed for Phase 3's runtime capture).
- **Deliverable:** written findings + exact reconstruction recipe. **Pause for
  user review.**

### Phase 3 — Reconstruct the factory image (hybrid)
- Statically seed the minimum bytes to pass the gate (signature + checksum) so
  the firmware boots.
- Boot under the MAME debugger (`xpinmamed.sdl ... -debug`); let or force the
  firmware's own factory-reset routine to run; dump the NVRAM region.
- That dump is the complete factory image (config + coin/credit + audit tables).
  Embed only its non-zero head; the zero tail comes from `core_nvram`'s fill —
  matching SLEIC3 and avoiding the "coins add no credits" trap recorded in the
  Bike Race comment.

### Phase 4 — Wire SLEIC1 NVRAM  *(review checkpoint before this edit)*
- In `src/wpc/sleic.c`, add `sleic1_nvram[]`, `sleic1_nvram_init[]`,
  `sleic1_nvram_r/w`, and `NVRAM_HANDLER(SLEIC1)` (parallel to the SLEIC3 block).
- Point the NVRAM region at the dedicated handlers **without disturbing
  SLEIC2/iomoon.** The base `SLEIC_80188_readmem/writemem` map is shared, so
  introduce a SLEIC1-specific memory map (or a guarded region) rather than
  editing the shared one.
- Add `MDRV_NVRAM_HANDLER(SLEIC1)` to `MACHINE_DRIVER_START(SLEIC1)`, overriding
  the inherited `generic_0fill`.

### Phase 5 — Build + verify (headless, with DMD capture)
- `make -f makefile.unixsdl` (`make clean` first if a struct/region change
  requires it — the unix makefile's header-dependency tracking is incomplete).
- Delete any stale `roms/sleicpin.nv` so the seed path is exercised.
- Headless run:
  ```
  Xvfb :99 -screen 0 1280x1024x24 & export DISPLAY=:99
  SDL_AUDIODRIVER=dummy ./xpinmame.sdl sleicpin --rompath roms \
    -nosound -skip_disclaimer -skip_gameinfo -skip_gamewarnings -ftr N
  ```
- **DMD capture instrumentation** (per request): add an env-gated DMD frame
  dumper so headless runs produce viewable screens for before/after comparison.
  Preferred: a small debug hook at the driver's `core_dmd_submit_frame` path (or
  PinMAME's existing DMD frame buffer) that writes frames as PGM/text to a file
  when e.g. `SLEIC_DMD_DUMP=<path>` is set. Decode/preview with the existing
  `sleic-iomoon/scripts/dmd_viewer.py`. This instrumentation is debug-only and
  gated off by default.
- Confirm: no "mal estado" text in captured frames; attract animation reached.

## Risks / unknowns
- **Error text may be DMD-font-encoded**, not ASCII → search both `sp03` and
  `sp02`; reuse the Bike Race string-finding method.
- **Factory-reset routine may need inputs unreachable headless** → fallback:
  debugger-force the init subroutine, or a pure-static seed (Approach B) if the
  format turns out simple.
- **Shared base memory map** → keep SLEIC1 changes isolated so `iomoon`
  (SLEIC2) is unaffected.
- **I8039/MCS-48 disassembly not tooled** → out of scope unless the trail
  demands it (the check is on the 80188, so it should not).

## Testing
Headless DMD capture before/after; confirm the message is gone and attract
animation runs. Optional persistence test: settings survive a `.nv` round-trip
(boot, change a setting via firmware, reboot, confirm retained).

## Process / git notes
- Disassembly + reconstruction artifacts live in `sleic-iomoon/research/`
  (reverse-engineering side); the driver change lives in `pinmame/`.
- Per the "pinmame stays local" rule: any commit (this spec, later the driver
  change) is a **local commit with an explicit single-file `git add`** — never
  `git add -A`, never a push.
