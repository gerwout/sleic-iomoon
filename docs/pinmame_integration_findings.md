# PinMAME integration findings (Io Moon driver)

[← Back to main README](../README.md)

Findings from making the Io Moon machine **run** in PinMAME (the `vpinball/pinmame` fork, driver
`src/wpc/sleic.c`, machine `SLEIC2`), from building + running headless (Xvfb, `-nosound`,
`-frames_to_run`, valgrind, gdb, and targeted CPU-core instrumentation).

> Status: **[FIXED]** verified fix in the driver/core · **[OPEN]** the remaining work.

## Summary

| # | Item | Status |
|---|------|--------|
| 1 | Release-build segfault (i86 `change_pc16` on a 20-bit CPU) | **FIXED** — the game runs |
| 2 | Direct-switch polarity inverted | **FIXED** |
| 3 | DMD read the wrong (empty) buffer → solid panel | **FIXED** |
| 4 | 80188 interrupt model — IVT, vectors, **the NMI**, HOLD_LINE | **FIXED** — three real ISRs |
| 5 | **LMCS ROM banking** (ROM2 frames ↔ ROM1 fonts) | **FIXED** — *the keystone*; broke the freeze |
| 6 | DMD-VBLANK **NMI + J1 vsync** (`dmd_vblank_isr`, `[1147]`, 0x47) | **FIXED** — boot reaches the main loop |
| 7 | DMD **frame-command handshake** via the PIC at PCS2 0xA0100 | **OPEN** — needs the undumped IC23 PIC |

Items 1–6 are in the driver (kept local for review). The machine now **boots, runs fully
interrupt-driven, and executes its main loop and game-logic dispatch** — none of which was possible
before. The one remaining wall (item 7) is a hardware dependency on the undumped PIC.

## 1. [FIXED] Release-build segfault — a genuine i86-core bug

valgrind: invalid read in `cpu_readop ← i186_execute`. The i86/i186/i188 core set the opcode base
with **`change_pc16`**, but I188 is a **20-bit** CPU; the 16-bit updater indexes the page table with
`pc>>4` not `pc>>8`, so any PC ≥ 0x10000 (segment D000/F000) corrupts `OP_ROM` and the release fast
path dereferences it. **Fix:** `change_pc16`→`change_pc20` in `src/cpu/i86/i86.h:98` and
`i86.c` (3 sites). valgrind-clean; multi-thousand-frame runs, no segfault. (Affects any i86-family
20-bit game; only Io Moon triggered it.)

## 2. [FIXED] Direct-switch polarity

The Z80 reads direct switches **active-low** (idle `0xFF`). The driver returned ports 0x00/0x03/0x04
non-inverted → idle = every direct switch phantom-held. Fixed by inverting them.

## 3. [FIXED] DMD read the wrong buffer

Segment 7000h is only a clear/staging area. The real frame is addressed by the **display pointer at
`4000:1150`**. `iomoon_submit_dmd_frame` now reads that pointer (plane0=base, plane1=base+0x200).

## 4. [FIXED] 80188 interrupt model — IVT, vectors, the NMI, HOLD_LINE

The IVT image lives in ROM1 (`V1 3_01.bin`) at offset 0 and is placed at physical 0 by a one-time
`memcpy(region, region+0x80000, 0x400)`. Decoding it reveals **three** enabled interrupts:

| IVT type | Phys | Vector | Handler | Role |
|---|---|---|---|---|
| **0x02 (NMI)** | 0x008 | D000:016D | `dmd_vblank_isr` | DMD VBLANK: reads PCS2 (J1) latch, fills display queue, sets `[1147]` |
| 0x08 (Timer0) | 0x020 | D000:024F | `sound_timer_isr` | OKI sample streaming; decrements `[113D]` etc. |
| 0x0C (INT0)   | 0x030 | D000:0343 | `frame_isr`       | YM3812 music sequencer + DMD command queue service |

The NMI (type 2) is the **DMD frame interrupt** — it was the missing third source. Timer0/INT0 are
maskable and were vectored correctly only after: (a) the right vectors via
`cpu_set_irq_line_and_vector(…,0x08/0x0C)` (the I188 default vector is 0xFF), and (b) **HOLD_LINE**
(MAME's i86 only takes an IRQ while `IF=1` and re-checks a *held* request on `STI`).

## 5. [FIXED] LMCS ROM banking — the keystone that broke the freeze

**This was the root cause of the total freeze.** Symptom: after ~28 boot interrupts the 80188 fell
into an **infinite loop inside an interrupt** (entries=28, returns=27) and ran the entire attract with
`IF=0`, so no further interrupt ever fired — the machine looked alive (≈740 FPS) but was dead.

Root cause: the LMCS low-memory window (80188 segment `0000–3FFF`, physical 0x00000–0x3FFFF) is
**hardware-banked** between two ROM sources:

* **ROM2** (`V1 3_02.bin`) — DMD **animation frames** (1030-byte frames, headers `{0x20,0x10,0x200}`)
* **ROM1's low half** (`V1 3_01.bin` file 0x00000–0x3FFFF) — DMD **fonts / static screens / credits**

ROM1 is 512 KB but UMCS only exposes its top 256 KB (code at 0xC0000–0xFFFFF), so the font half is
reachable **only** through this banked window. The driver hard-wired ROM2 there, so every font/string
descriptor read hit graphics garbage. Concretely a BIOS text routine reads a 6-byte `{rows,width,
stride}` header via `les si,[cs:536F]` → `3000:036A`; under ROM2 that is `{0x0000, 0xE11F}` → a
**3.78-billion-iteration** draw loop (an effective hang inside `frame_isr`). The *same* offset in
ROM1 is `{0x0A, 0x04, 0x28}` = a valid 10×4 glyph. Verified live: `ROM1[0x1029A]={8,3,24}`,
`ROM1[0x3036A]={10,4,40}`.

The bank is selected by **IC40 (74LS273) latch bits EEE1/EEE2 = bits 4/5 of the PCS0 byte
(0xA0000)**, decoded by the **IC7 PAL20L10**. The driver now models it: `iomoon_lmcs_r` returns
ROM1-fonts when PCS0 bit 5 is set, else ROM2 (bit 4 selecting ROM2's 256 KB half). With the bank in
place the deadlock is gone: interrupts flow continuously (thousands of taken/returned pairs), `IF=1`
returns, and the 80188 reaches its main loop.

> ⚠️ The exact bit→bank truth table lives in the **undumped IC7 PAL20L10**. The bit-5/bit-4 model
> above is the empirically-verified approximation and should be confirmed against the PAL fuse map.

## 6. [FIXED] DMD-VBLANK NMI + J1 vsync — boot reaches the main loop

With banking fixed, the 80188 spun in `main_loop_wait_vsync` (D2F59), polling `vsync_check` (D5D1B),
which returns "frame ready" only when **`[4000:1147]` ≠ 0** *and* the display-queue byte at
`[4000:1150]` **== 0x47**. Both are produced by the **NMI** `dmd_vblank_isr` (D000:016D), which on
the real board is raised once per DMD frame by the PIC: it reads the J1 inbound latch at **PCS2
0xA0100**, appends the byte to the display queue at `4000:1220`, and sets `[1147]=0xFF`.

The driver now (a) generates the NMI at the 244 Hz DMD frame rate in `iomoon_irq_gen`, and (b) models
PCS2 0xA0100 as the J1 inbound latch (`iomoon_j1_inbound`, consume-on-read, default `0x32` =
"no new data / end-of-frame"), strobed by the Z80's port-0x81 bit-2 write. Result: `[1147]` is set
each frame, the boot 0x47 reaches the queue, **`vsync_check` succeeds and the main loop advances**
into `process_input_events` and `default_game_logic` — the deepest the firmware has ever run under
emulation.

## 7. [OPEN] DMD frame-command handshake — blocked on the undumped IC23 PIC

The main loop now reaches `process_input_events` (D5A45), which pushes command `0xF9` to the command
queue and waits up to 400 ticks for `timer_tick_handler` (D5F03) to consume a **≥0xF0** byte from the
display queue, else it traps at `d5a87: jmp $` (a deliberate halt). That ≥0xF0 acknowledgement is a
**DMD frame-command byte supplied by the PIC over PCS2 0xA0100** as it rasterizes frames — alongside
the `0x47` (sync), `0x32` (end-of-frame), and `0x45/0x46` (buffer-swap) markers `dmd_vblank_isr`
decodes. The Z80 is *not* the source: it is alive and loops correctly but only sends on switch
changes (verified — one boot strobe, PC cycling through its main loop). The frame markers come from
the **IC23 PIC16C57 (DMD rasterizer), whose firmware is undumped**.

So the remaining blocker is a **hardware data dependency**: faithfully modelling the PIC's DMD
frame-command stream at 0xA0100 requires the PIC dump. Until then the firmware reaches the start of
its attract frame loop and waits for the PIC. The two outstanding dumps — **IC23 PIC16C57** and
**IC7 PAL20L10** — gate, respectively, the DMD frame handshake (item 7) and confirmation of the
ROM-bank truth table (item 5).

---

*PinMAME branch kept local pending review. Items 1–6 are FIXED in the driver and take the machine
from "segfaults / total freeze" to "boots, runs interrupt-driven, executes the main loop and game
dispatch with a working DMD-vsync mechanism." Item 7 (the PIC DMD frame handshake) is the next —
and is blocked on dumping the IC23 PIC.*
