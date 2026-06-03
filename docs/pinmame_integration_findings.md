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

---

## 2026-06-03 — Bike Race "Rosetta Stone" reframe (supersedes the PIC-loopback model)

The fully-dumped **Bike Race** sibling (`/home/gerwout/Downloads/bikerace`, same 80188 firmware
lineage, an Intel **8039** display coprocessor instead of the PIC) plus a fresh read of the board
schematics **debunk the PIC marker-loopback** (items 7–9 above). Verified independently against the
ROMs/disassembly (two read-only agents) — confidence HIGH except where noted:

* **The 80188↔display-coprocessor link is UNIDIRECTIONAL.** The 8039 program (`bkdsp01.bin`, 0x74
  bytes) has **no `MOVX`, no bus write, never enables interrupts** — a pure `JNT1`-gated, P1/P2
  bit-banging free-runner (`JMP 016` forever). The PIC's 20 I/O pins are likewise all DMD signals.
  So the coprocessor sends the 80188 **nothing** — the old `iomoon_pic_phase` FIFO feeding
  `0x47/0x46/0x32` back at PCS2 `0xA0100` was **fictional**. **(driver R1: removed it; `0xA0100` is now
  the plain Z80→J1 inbound latch, idle sentinel `0x32`.)**
* **Same codebase, recompiled.** Bike Race 80188 = IO Moon 80188 source relocated (work RAM seg
  `1000h` vs `4000h`; `dmd_reset_pulse` differs by only 4 operand bytes; Timer0/PACS/interrupt-config
  tables byte-identical).
* **Timer0 = 99.18 Hz** (T0CMPA=T0CMPB=`0x6276`, CLKOUT/4) — CONFIRMED. **frame_isr (D0343) is a
  GENUINE external INT0** (INT0CON=`0x0000` enabled; it EOIs in-service **bit 4 = INT0** while
  `sound_timer_isr` EOIs **bit 0 = Timer0**) — so it must stay a *separate* INT0 source at the frame
  rate, **not** be folded into the Timer0 cadence (this refutes the handoff's R3).
* **THE ORACLE — attract is switch-token-driven, not timer-driven.** `dmd_attract_cycle` (D7ABC)
  advances only when `last_switch_code [413C:00D6]` becomes a flipper token (`0x3F`/`0x40`); there is
  **no internal-timer fall-through** (the `[1139]`/`[113D]` counters are Timer0-decremented *deadlock*
  watchdogs — Bike Race's twin of IO Moon's `d5a87: jmp $` is `bkcpu04:0x95be: jmp $`). In attract the
  Z80 forwards only the idle sentinel (`0x32` IO / `0x37` BR); a flipper press sends `0x40`. So
  reaching gameplay requires injecting the **switch tokens** through the J1-latch path.
* **process_input_events needs a ≥0xF0 command-ACK** within 400 Timer0 ticks or it traps at `d5a87`.
  The DMD controller acknowledges each command written to PCS1 `0xA0080`. **(driver: modeled as a
  minimal echo — bytes written to `0xA0080` are returned on subsequent `0xA0100` reads; this clears
  the d5a87 trap and the 80188 runs its main loop. The exact ACK source is residual-unknown #3,
  pending schematic 011-029-05.)**

**Driver state after this pass** (`SLEIC2`, local for review): fictional PIC FIFO removed → plain J1
latch (idle `0x32`) + the `≥0xF0` command-ACK echo; INT0 kept as a separate frame-rate source; NMI
~145 Hz, Timer0 99.18 Hz. With the ACK the 80188 clears `d5a87` and runs its main loop.

**The remaining gap to gameplay** is an *ordered per-frame marker stream* in the shared display queue
(`4000:1220`, read via the single pointer `[1150]` by `vsync_check`→`0x47`, `timer_tick_handler`→
`≥0xF0`, `frame_counter_update`→`0x45/0x46`, `dmd_text_display`→switch token). The **vsync `0x47` and
swap `0x45/0x46` sources are genuinely unresolved** — the Z80 sends `0x47` only at boot, so a
**divider-derived frame strobe** is the leading hypothesis (handoff residual-unknown #1, needs
schematic 011-029-01) — and because all consumers share the `[1150]` pointer, an injected switch
token is consumed by `vsync_check` before `dmd_text_display` sees it unless the stream is correctly
ordered. Resolving the marker source + the queue ordering is the path to attract→coin→state 2→music.

**Bike Race bring-up:** all 7 ROM SHA1s match `sleicgames.c`; it loads and runs. But the `SLEIC3`
path uses the generic stub `SLEIC_80188_*mem` map (RAM/ROM/peripheral windows wrong for Bike Race's
seg-`1000h` work RAM, `0xE0000` code, and A000 peripherals; `pic_w` swallows YM3812/OKI; no J1
latch). Running its firmware needs the same memory-map + A000-peripheral + J1-latch treatment as
SLEIC2 — at which point Bike Race (real, fully-dumped coprocessor) directly validates the IO Moon model.

---

## 2026-06-03 — Bike Race (SLEIC3) BOOTS, runs attract, renders DMD

The Bike Race bring-up succeeded: the 80188 now **boots, runs its attract loop, and
renders the DMD** (legible logo text) in PinMAME — further than IO Moon (which traps at
`d5a87`). It is the live oracle: same 80188 firmware family with a *fully-dumped* I8039
display coprocessor instead of the undumped PIC, so it validates the shared model.

**Bike Race hardware model** — decoded from the `bkcpu04` boot at `E000:0000` and its
29-entry chip-select table at `E000:0050`:

| 80188 reg | value | meaning |
|---|---|---|
| MMCS `0xFFA6` | `0x01FF` | 512 KB mid-range block based at `0x00000`, split into four 128 KB MCS lines |
| MPCS `0xFFA8` | `0xC0FC` | MS=1 (peripherals memory-mapped), EX=1, 512 KB block-size field |
| PACS `0xFFA4` | `0xA03C` | peripheral block at `0xA0000` — **identical to IO Moon** (J1/YM3812/OKI handlers reused) |
| T0CON/T0CMP | `0xE003`/`0x6276` | Timer0 — **byte-identical to IO Moon → 99.18 Hz** |
| INT0CON `0xFF38` | `0x0000` | INT0 enabled (genuine external frame source) |

The four MCS blocks:
- **MCS0 `0x00000-0x1FFFF`** — work RAM (boot stack `SS:SP=012F:0203`; the boot copies its
  own IVT image from `CS:00C4` into physical 0 before any `STI`, so **no driver IVT memcpy**,
  unlike SLEIC2 where physical 0 is ROM).
- **MCS1 `0x20000` / MCS2 `0x40000`** — the two 128 KB graphics ROMs. **Order matters:**
  `bkcpu06` at `0x20000`, `bkcpu05` at `0x40000`. Segment `0x2000` is where the F000 DMD
  composer's frame-descriptor pointer lands; with the ROMs swapped the descriptor read `0x7C00`
  (garbage) → a ~4-billion-iteration runaway blit. Correct order yields a sane `{rows,cols,bp}`
  descriptor (e.g. `{18,1,18}`).
- **MCS3 `0x60000-0x7FFFF`** — DMD / video frame-buffer RAM. `F000:00EF/0117/013A` zero
  `ES=0x6000` offset `0x410` (= `0x60410`, the panel staging buffer the I8039 rasterizes).

**DMD composer** (`F000:01D9` reads the descriptor, `F000:0231` blits): reads `{rows,cols,bp}`
from `ES:SI` in the graphics ROM, then copies 2 interleaved bitplanes into the work-RAM /
`0x60000` buffer. IO Moon's annotated `dmd_frame_load` (`F000:0907`) is the same routine family.

**Interrupts** (`sleic3_irq_gen`, no IVT memcpy): Timer0 vec `0x08` → `E000:0325` (decrements the
delay/animation counters incl. `[phys 0x105]`, the counter the `E83C8` delay routine spins on);
INT0 vec `0x0C` → `E000:0439`; NMI vec `0x02` → `E000:0272`.

**The decisive bug** that blocked it: the existing `SLEIC_irq_i8039` DMD-decode loop used
`jj < 16` → 256 px/row written into the 128-stride `rawDMD[128*32]` buffer, overrunning it and
corrupting adjacent driver statics every I8039 IRQ. That zeroed `sleic3_irq_gen`'s interrupt-
injection accumulators on every call, so Timer0 never fired and attract froze. Fixed to `jj < 8`
(128 px/row). Only `SLEIC1`/`SLEIC3` run the I8039, so IO Moon (SLEIC2) was unaffected.

**Verified running** (headless): `delay[105]` cycles `9→8→…→1→0` (Timer0 delays complete and
restart), PC spread across `F08xx` (dmd_frame_load), `E95/E51/E83xx` (attract logic), and the DMD
renders the manufacturer logo. Driver state is **local** (`SLEIC3` map + `sleic3_irq_gen` +
`SLEIC_ROMSTART7` graphics-ROM order in `sleic.h`; `SLEIC_irq_i8039` overflow fix).

**Implication for IO Moon:** the oracle confirms the shared memory-map/interrupt/peripheral model
and that attract is **Timer0-delay-driven** (not purely switch-token-gated). IO Moon's remaining
`d5a87`/marker-stream gap can now be diagnosed by direct comparison against Bike Race's working
flow rather than the undumped PIC.

---

## 2026-06-03 — Bike Race attract: Z80 I/O bring-up + the E95BE DMD-ACK watchdog (4-disassembler cross-verified)

After the SLEIC3 80188 boot+DMD work, the attract stuck on **"ESPERANDO"** (waiting), then — once the
Z80 was wired — on **"IMPOSIBLE SEGUIR / ERRONEA"** + a `jmp $` trap. Two layers were reverse-engineered;
the second was cross-verified with **four independent disassemblers** (ndisasm, Capstone, objdump, radare2
for the 80188; MAME's `8039dasm.c` + an independent Python MCS-48 decoder for the coprocessor), all agreeing
byte-for-byte on the code regions.

### Layer 1 — ESPERANDO = the Z80 I/O handshake
The SLEIC3 Z80 used the generic base ports; **bkio07 hangs in its service loop at Z80 0x29AE unless input
port 0x04 bit 7 reads 1**. Added `sleic3_z80_read/write` (port map from bkio07): IN 0x01 bit5 = J1 ready,
IN 0x04 = 0xFF, OUT 0x80 = J1 data, OUT 0x81 bit-2 strobe latches into the 80188's 0xA0100, OUT 0x82 =
switch-col strobe. The Z80 sends **0x5F "ready"** once at boot (Z80 0x012A). The **80188 NMI (E000:0272)**
reads 0xA0100 and treats byte **0x37 as idle** (just bumps a counter); any other byte is pushed to an event
queue (flag [phys 0x111], read ptr [0x11A], buffer at phys 0x1EA) that `process_input_events` drains. So
Bike Race's idle J1 value is **0x37** (not Io Moon's 0x32). With that, the 0x5F clears ESPERANDO.

### Layer 2 — the DMD-command ACK watchdog (and the I8039's true role)
`process_input_events` (the wait at **E957B**, twin of Io Moon's `d5a87`): pushes a DMD command via
`cmd_queue_push` (E000:023D), arms a Timer0 countdown [phys 0x109], then loops on the event-check
**E50E:45DD (= linear 0xE96BD)**. On timeout it renders the error strings ("IMPOSIBLE SEGUIR" at
F000:400E, an "…ERRONEA" subtitle at F000:4158) via `dmd_text_render` (F000:06C5) and hangs at
**E95BE `jmp $`**.

- **The accepted ACK is an inbound queue byte STRICTLY > 0xF0** (E96BD: `cmp byte [..],0xF0` / `jbe reject`;
  then `and al,1` selects a status flag). This *corrects* the earlier handoff note of "≥0xF0" to **`>0xF0`
  (≥0xF1)** — echoing the literal command (e.g. 0xD4) is **rejected**, which is exactly why the trap fired.
- **DMD command path:** `dmd_tx` (E02E0), called once per **INT0**, reads the command queue, **polls
  0xA0180 (PCS3) bit 0 = "controller ready"**, writes the byte to **0xA0080 (PCS1)**, then pulses the
  0xA0200 (PCS4) strobe. (Structural twin of Io Moon's `dmd_queue_service`.)
- **The I8039 (bkdsp01) is a verified pure one-way rasterizer.** Its whole program is 117 bytes (rest 0xFF);
  it executes `DIS I` + `DIS TCNTI` as its first two instructions and **never** re-enables interrupts, has
  **zero** `INS A,BUS` / `OUTL BUS,A` / `MOVX` (reads nothing from and writes nothing to the 80188), and only
  samples its **T1** panel-sync pin while driving P1/P2 to the plasma panel. It loops `0x016→0x073→0x016`
  forever. **It returns the 80188 absolutely nothing** — so the >0xF0 ACK the watchdog needs does NOT come
  from the DMD coprocessor. (MAME's `8039dasm.c` has a cosmetic bug: opcodes 0x39/0x3A print as `outl p5/p2`
  but are really `OUTL P1,A`/`OUTL P2,A`.)

**Driver change:** model the controller ACK as a **>0xF0 loopback** — on a 0xA0080 command write, push
0xFF to the inbound-ACK path (Bike Race only; Io Moon keeps the literal echo). This **clears the E95BE trap**
(verified: the PC moves to the watchdog *success* path E95D6/E95DC instead of `jmp $`).

### Still open
Clearing the trap revealed the attract loops back to **ESPERANDO** rather than advancing to the real attract:
the init handshake has further interacting steps (the >0xF0 ACK events tangle with the earlier ESPERANDO
event-wait). The remaining work is to RE the full attract-init event *sequence* — what the outer loop waits
on between ESPERANDO and the running attract (a specific Z80 event sequence, not just the DMD ACK).

**Direct payoff for Io Moon:** the **`>0xF0` ACK** finding (not the literal echo) applies to Io Moon's own
`d5a87` `process_input_events` trap — the same firmware family, same event-check structure.

### 2026-06-03 (cont.) — the attract-init is a multi-gate J1 handshake cascade

RE of the main loop (E50E:0007) shows the boot-init is a *sequence* of event-gates over the shared
J1 inbound queue (NMI-filled, 0x37=idle), gating entry to the game state machine (state byte
seg 0x116:[0x99] = phys 0x11F9, set =2 at E5230):
- **Gate A** (E9509): wait for **0x5F** (Z80 boot-ready) — ESPERANDO is shown until this passes.
- **Gate B** (E957B): send cmd 0xD4 → wait for a byte **>0xF0** (200-tick timeout → E95BE trap).
- **Gate C** (E95C2): send cmd 0xD5 → wait (no timeout) for ball-status **0x5B/5C/5D**.
- **Gate D** (E9478): wait for Z80 event **0x36** (bkio07 sends it from 0x0E16, conditional on Z80 state).
- …and more after.

A **selective per-command loopback** (cmd 0xD4→0xF1, cmd 0xD5→0x5D, else fire-and-forget — a blanket
ACK floods the queue and drowns gate A's 0x5F) clears gates B and C and **advances past ESPERANDO and
the trap to a real attract text screen**, then stalls at gate D.

**The honest architectural conclusion:** modelling each gate's reply as an 80188-side loopback is a
shortcut that runs out after a gate or two, because the Z80-sourced gates (A, C, D, …) each need the
*real* bkio07 firmware's conditional response. The faithful fix is to **wire the bidirectional J1**:
the 80188 writes commands to 0xA0080 and the Z80 must READ them (via a Z80 IN port not yet identified —
the bkio07 RE so far only mapped the Z80→80188 send path and the port-0x01 status) and answer through
its normal send path. Only **gate B** is genuine glue logic (the I8039 returns nothing). This is the
recommended next step, and it would resolve the whole cascade at once rather than gate-by-gate.

### 2026-06-03 (cont.) — bidirectional J1 wired → Bike Race attract RUNS

Cross-verified RE of bkio07 (two independent Z80 decoders) showed the Bike Race Z80 **does** read the
80188's commands (unlike Io Moon): the 80188's **0xA0080 write asserts the Z80 NMI**; the NMI (0x0066)
reads the command via **IN port 0x00**, and the dispatcher (0x10FF, jump table @0x2000) handles it:
cmd **0xD4** → handler 0x2923 replies `IN(0x04)|0xF0` (always >0xF0 → gate B); cmd **0xD5** → handler
0x0B1D replies ball-trough status **0x5B/5C/5D** (gate C). The reply returns through the Z80's normal
send path (OUT 0x80 + port-0x81 bit-2 strobe → 0xA0100).

**Driver:** replaced the per-command loopback with the real link — on a 0xA0080 write, latch the byte
and pulse the Z80 NMI; the Z80 IN(0x00) returns it; the Z80 NMI is no longer fired by the 145 Hz
periodic (it is now event-driven on the command, else the stale command re-enqueues every frame).

**Result:** with the genuine bkio07 firmware answering, the 80188 clears gates A/B/C
(`Z80->5F`; `188->cmd D4`→`Z80->FF`; `188->cmd D5`→`Z80->5B` "ball present") and the **DMD runs a
cycling/animating attract sequence** (the pixel count cycles through ~6 distinct frames plus blanks)
instead of stalling. This is the faithful fix — no faked replies.

**Remaining (non-blocking polish):** (1) a DMD vertical-striping cosmetic artifact from the stand-in
`SLEIC_irq_i8039` 0x60410 decoder (content correct/readable; faithful fix = real I8039 rasterization);
(2) gate D (autonomous 0x36 on a flipper direct-switch) + coin/start to reach gameplay; (3) sound.
The bidirectional-J1 model, the >0xF0 ACK, and the gate structure transfer directly to Io Moon's d5a87.

### 2026-06-03 (cont.) — DMD rendering fixed (striping + single-DMD view)

The Bike Race DMD showed vertical striping with the text squished/mis-positioned, plus 3 small panels
below it. Root causes:
- **Striping:** the `SLEIC_irq_i8039` stand-in decoder read the 0x60410 frame buffer with a 16-byte row
  stride, but the DMD VRAM is **32 bytes per row** (16 bytes = 128 px, MSB first, 1 = lit, followed by
  16 unused bytes). Reading 16 made every real row alternate with a blank (the "striping") and showed
  only the top half of the frame. Fixed to a 32-byte stride -> text renders full-height, correctly
  positioned. (Verified against a buffer dump: content rows at 0x60590, 0x605B0, 0x605D0… = 32 apart.)
- **The "3 panels"** are PinMAME's generic **simulator status grids** (solenoids / diagnostic LED / GI /
  lamps, drawn in `core.c` ~line 1990 below the DMD) — not a driver issue. Run with **`-dmd_only`** for a
  clean single DMD (confirmed: a perfect 128x32 DMD showing "FALTA 1 BOLA", nothing else).
- **Ball count corrected to 2** (manual §3.9 multiball): `INITGAME(bikerace,…,2)`.

**Still open — "FALTA 1 BOLA":** the 80188's passive ball-count reports a missing ball because the trough
is empty in emulation. The Z80 cmd-0xD5 ball handler reads matrix column 4 (`swMatrix[5]`, bits 2/5/7,
trough cluster C6/C7/C8 + C17 pendulum per the manual) but *defaults to "ball present"*, so the FALTA is
the 80188's own count routine — which needs x86 tracing to find exactly which trough switches it counts
and how many, so the driver can preset them. Forcing whole switch columns changes the display but isn't a
clean fix. (Attract otherwise runs and cycles correctly; the message is the machine faithfully reporting
an empty trough.)

### 2026-06-03 (cont.) — "FALTA 1 BOLA" fixed (80188 ball-count traced)

Traced the 80188 ball-status display routine at **E9640**: it reads the dequeued Z80 reply byte and
maps **0x5D → "BOLAS OK"**, **0x5B → "FALTA 1 BOLA"**, **0x5C → "FALTAN 2 BOLAS"** (length-prefixed
glyph strings at F000:3D7D / 3D61 / 3D6E). So the displayed message is driven entirely by the Z80's
cmd-0xD5 reply — not an independent 80188 count (correcting the earlier guess).

The Z80 cmd-0xD5 handler (bkio07 **0x0B1D → 0x0B31**) replies **0x5D ("BOLAS OK") when switch-matrix
column-4 bit5 OR bit7 is closed**:
```
ld a,(0c0dbh)      ; col-4 debounced data (= ~swMatrix, so a CLOSED switch reads 0)
or 0dfh / cp 0dfh / jp z, reply_5D    ; bit5 == 0 (closed) -> 0x5D
or 07fh / cp 07fh / jp z, reply_5D    ; bit7 == 0 (closed) -> 0x5D
or 0fbh / cp 0fbh / jp z, eject       ; bit2 == 0 (closed) -> eject, reply 0x5B
... (else) reply 0x5B
```
Manual p.13 names the matrix ball contacts: **C6 "Salida Bolas"** (release = col4 bit2, would trigger
an eject), **C7 "Bola Retenida"** and **C8 "Bola fuera"** (the two balls at rest = col4 bits 5 and 7).

**Fix:** `MACHINE_INIT(SLEIC)` seats both balls for Bike Race at power-on — `coreGlobals.swMatrix[5] |=
0xA0` (C7 bit5 + C8 bit7). The Z80 then replies 0x5D and attract advances to the real screens
("ESTABLECIENDO VALORES FABRICA" / "PULSE START") instead of "FALTA 1 BOLA". Combined with `balls=2`,
the 32-byte DMD stride, and `-dmd_only`, Bike Race now shows a clean single DMD running real attract.

### 2026-06-03 (cont.) — NVRAM factory defaults (boots straight to attract)

A fresh (0-filled) NVRAM made Bike Race show **"ESTABLECIENDO VALORES FABRICA" / "PULSE START"**
(the factory-reset prompt) and wait, instead of going to attract. Traced it:
- **config_validate (E05F7)** compares the config at seg 0x1040 (= phys 0x10400) against ROM-resident
  factory defaults at E000:07BC.. in **eight sub-blocks**; any mismatch returns "invalid".  Block 1 is
  the **"(C) SLEIC 1.994"** signature string; the rest are the default game/coin/score config.
- **config_load_defaults (E06FB)** copies those same eight blocks ROM->NVRAM.

The blocks (nvram_off @0x10400, rom_off @0xE0000, len): (0x000,0x7BC,15) (0x047,0x7CB,51)
(0x0C9,0x7FE,32) (0x162,0x81E,53) (0x1EC,0x853,26) (0x23C,0x7FE,32) (0x2ED,0x81E,53) (0x351,0x853,26).

**Fix:** `MACHINE_INIT(SLEIC)` seeds those eight blocks for Bike Race (a faithful copy of what
config_load_defaults writes), so config_validate passes on the first check and the machine boots
straight to attract — it shows "BOLAS OK" (ball check) and then cycles the real attract screens, no
factory-reset prompt.  (The NVRAM is re-seeded each boot rather than persisted across runs; a proper
NVRAM handler that maps the 0x10400 region as battery-backed and saves it is a follow-up.)

**Bike Race status:** boots → renders DMD cleanly → real bidirectional J1 handshake → balls present →
NVRAM valid → **boots straight to a clean, cycling attract** (run with `-dmd_only`).  Remaining for
gameplay: coin/start + flipper switch wiring and sound (YM3812/OKI).
