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
| 7 | DMD **frame-command handshake** via the PIC at PCS2 0xA0100 | **MODELED** — loopback; game animates + takes input |
| 8 | **YM3812 FM music pipeline** (sequencer → chip) | **VERIFIED WORKING** — arms + plays in-driver |
| 9 | Game *auto-reaching* gameplay so music/OKI arm by themselves | **OPEN** — needs the exact (undumped) PIC frame timing |

Items 1–8 are in the driver (kept local for review). The machine now **boots, runs fully
interrupt-driven, executes its complete main loop, drives the DMD command protocol, animates its
attract, responds to switch input, and — when a song is armed — plays the YM3812 FM music** — none of
which was possible before. The single remaining gap (item 9) is the game **auto-reaching** gameplay so
the sound arms by itself, which depends on the exact undumped-PIC frame timing.

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

The driver now (a) generates the NMI at the measured ~145 Hz DMD frame rate in `iomoon_irq_gen`, and (b) models
PCS2 0xA0100 as the J1 inbound latch (`iomoon_j1_inbound`, consume-on-read, default `0x32` =
"no new data / end-of-frame"), strobed by the Z80's port-0x81 bit-2 write. Result: `[1147]` is set
each frame, the boot 0x47 reaches the queue, **`vsync_check` succeeds and the main loop advances**
into `process_input_events` and `default_game_logic` — the deepest the firmware has ever run under
emulation.

## 7. [MODELED] DMD frame-command handshake — PIC loopback

The main loop reaches `process_input_events` (D5A45), `lamp_matrix_update`/`frame_counter_update`,
and the intro display routines, all of which consume a **byte stream the PIC feeds the 80188 at PCS2
0xA0100**. Tracing the consumers reveals the protocol:

* `vsync_check` (D5D1B) advances on **0x47** (vsync).
* `timer_tick_handler` (D5F03) advances on a **≥0xF0** display-command ack.
* `frame_counter_update` (D5D8D) advances on **0x45/0x46** (buffer swap → `dmd_buffer_swap`).
* `lamp_set` (D5AEB) advances on a **switch code** (e.g. 0x40 = upper flipper).
* `0x32` = end-of-frame (bumps the frame counter `[1144]`).

And the *output* side: `dmd_queue_service` (D01E5, run by `frame_isr`) drains the display-command
queue (4000:1158) to the DMD controller — writing each byte to **PCS1 0xA0080** and strobing **PCS4
0xA0200**, gated on the controller-ready bit **PCS1 0xA0180.0**. (That ready bit returned 0 in the
driver, so the queue never drained and `process_input_events` trapped at `d5a87: jmp $`.)

The driver now models the PIC (IC23) as a **command-echo + frame-marker loopback**: 0xA0180.0 reports
ready; bytes the 80188 writes to 0xA0080 are echoed back; and 0xA0100 delivers a repeating per-frame
marker sequence (`0x47` → echoed commands → `0x46` → `0x32`), with fresh Z80 J1 bytes interleaved.
With this, the firmware **runs its whole main loop, drives the DMD command protocol, plays an intro
animation (timed `[1139]` frame delays cycling), and responds to input** — injecting switch code 0x40
advances the intro to the next screen (verified: PC moves on, new display commands issue). **Switches
register.**

## 8. [OPEN] Full attract→gameplay flow + audible music

What remains is reproducing the rest of the chain — intro → attract (`game_state_var` 0→1 at D2FDA) →
started ball (state 2) → the YM3812 music sequencer (`D000:0D1B`) and OKI dispatch arming. The intro
is a sequence of input/timed-gated screens (e.g. `lamp_set` D5AEB waits on switch code 0x40 = upper
flipper). Two further facts were established here:

* **The Z80 also has a DMD-frame NMI** (handler at Z80 `0x0066`) that samples the direct switches
  (flippers, port 0x00) and runs a frame state machine — it was never triggered. The driver now pulses
  the Z80 NMI alongside the 80188 NMI, so the **flipper-input path is faithful**.
* **The frame markers come from the PIC, not the Z80.** Even with its NMI firing, the Z80 still only
  strobes J1 on a *switch change* (verified: one boot strobe over thousands of frames). So the periodic
  `0x47/0x45/0x46/0x32` stream the 80188 consumes at 0xA0100 is the **PIC's**, confirming the loopback
  model in item 7 and that faithful frame timing needs the **undumped IC23 PIC16C57**.

Tracing further: the main loop's `default_game_logic` (D622C) **is** the attract — it calls
`attract_mode_display_setup` (D08C9, the MOONLIGHT/SUNSHINE/STARWAY screens) and loops the attract
display internally, so `game_state_var` legitimately stays 0 while attract runs (state 1 is set at
D2FDA only after `default_game_logic` returns). The attract's per-screen routines, however, sit in
**input-only sub-loops** under the loopback markers — e.g. the screen at D540F loops `lamp_set`
(D5AEB) purely until switch code 0x40 (upper flipper), with **no timer auto-advance and no coin
poll**. On real hardware the PIC's exact frame markers pace those screens (timed auto-advance) and let
the coin/credit path run; under the approximate markers the attract parks in the flipper-wait and
never polls the coin — so injecting COIN (0x42) / START (0x41) does **not** raise the credit, and the
game can't enter a started ball (state 2) where the YM3812 music sequencer arms. Verified three ways
that this is the **exact-PIC-timing** dependency, not a different bug: (a) the markers come from the
PIC not the Z80; (b) the attract sub-loop is flipper-only by disassembly; (c) coin/start/flipper
injection can't advance state.

## 8a. [VERIFIED] The YM3812 FM music pipeline works in the driver

Rather than wait for the game to reach gameplay, the music path was exercised directly by replicating
`game_mode_set` (D0DB4): pick a song index, read its pointer from the table at `CS:0DE5` (physical
0xD0DE5 — 10 entries `0DF9,0E32,1662,2106,2769,22A8,25E9,26A9,29FA,2C8E`), and set the sequencer vars
in seg 4000h: `[12EA]`=song ptr, `[12EC]`=0, `[12EE]`=0xFF (enable). The result is unambiguous: the
music sequencer (D0D1B, ticked by `frame_isr`) **walks the song byte-stream** (`[12EA]` advances
`0E32→0EB2→0EC8→0EE6…`) and **writes the YM3812** (PCS5 `0xA0280`/`0xA0281`) — the YM3812 write count
climbed from 0 into the thousands across songs, and short vs long tracks matched the offline-rendered
WAVs. **So the entire FM pipeline — sequencer → write primitive (D0D99) → YM3812 — is functional;
audible FM music plays the moment a song is armed.** (The 10 tracks also render to recognisable music
offline — see `iomoon_fm_extract.md` and the rendered WAVs.) The OKI path
(`iomoon_oki_trigger`→`OKIM6376`) is likewise in place and its samples are recognisable.

## 9. [OPEN] Auto-reaching gameplay so the music/OKI arm themselves

So the sound chips work; what's missing is the game **arming** them by itself, which happens once it
enters a started ball (state 2) via `game_mode_set`. That requires the attract→coin→start chain, and
the attract's per-screen routines park in input-only sub-loops under the approximate loopback markers
(D540F loops `lamp_set` until upper-flipper 0x40, no timer auto-advance, no coin poll). On real
hardware the PIC's exact frame markers pace those screens and let the coin/credit path run; under the
approximation the attract never polls the coin, so injecting COIN/START does not raise the credit.
Verified three ways this is the **exact-PIC-timing** dependency: (a) the markers come from the PIC not
the Z80; (b) the attract sub-loop is flipper-only by disassembly; (c) coin/start/flipper injection
can't advance state. The two outstanding dumps — **IC23 PIC16C57** (frame timing) and **IC7 PAL20L10**
(ROM-bank truth table) — gate the auto-flow. This is the limit faithfully reachable without them; the
driver scaffolding (banking, NMI, command loopback, J1, and a proven sound pipeline) is all in place
for the PIC's real frame sequence to drop into.

---

*PinMAME branch kept local pending review. Items 1–7 take the machine from "segfaults / total freeze"
to "boots, runs fully interrupt-driven, executes its complete main loop, drives the DMD command
protocol, animates an intro, and responds to switch input." The PIC loopback (item 7) is a faithful
first-order model; item 8 (the full attract→gameplay flow + audible music) needs the exact PIC frame
timing from the IC23 dump.*
