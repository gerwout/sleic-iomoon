# PinMAME integration findings (Io Moon driver)

[← Back to main README](../README.md)

Findings from making the Io Moon machine **run** in PinMAME (the `vpinball/pinmame` fork, driver
`src/wpc/sleic.c`, machine `SLEIC2`), from building + running headless (Xvfb, `-nosound`,
`-frames_to_run`, valgrind, gdb, targeted instrumentation).

> Status: **[FIXED]** verified fix in the driver/core · **[OPEN]** the remaining work.

## Summary

| # | Item | Status |
|---|---|---|
| 1 | Release-build segfault (i86 `change_pc16` on a 20-bit CPU) | **FIXED** — the game runs |
| 2 | Direct-switch polarity inverted | **FIXED** |
| 3 | DMD read the wrong (empty) buffer → solid panel | **FIXED** — renders real 4-grey content |
| 4 | 80188 interrupts never fired (wrong IVT + wrong vector + not latched) | **FIXED** — the boot now completes through the real ISRs |
| 5 | Music (YM3812) / OKI audible | **OPEN** — needs reaching gameplay (attract is IF=0/silent) |
| 6 | Reaching gameplay (credit / start / ball-trough switches) | **OPEN — the next step** |

Items 1–4 are in the driver (kept local for review). The machine now boots cleanly into its
**interrupt-driven attract** with a working DMD. The remaining gap is purely **reaching a started
ball**, where the game arms the music and the ISRs resume.

## 1. [FIXED] Release-build segfault — a genuine i86-core bug

valgrind: `Invalid read at cpu_readop ← i186_execute`, "Access not within mapped region at
0xD011C". The i86/i186/i188 core sets the opcode base via **`change_pc16`**, but I188 is a **20-bit**
CPU (`cpuintrf.c: CPU0(I188,…,8,20,…)`); the 16-bit updater indexes the L1 table with `pc>>4` not
`pc>>8`, so a PC ≥ 0x10000 (segment D000) corrupts `OP_ROM` and the release fast path dereferences
it. **Fix:** `change_pc16`→`change_pc20` in `src/cpu/i86/i86.h:98` and `i86.c:166,192,589`.
valgrind-clean; multi-thousand-frame runs, no segfault. (Affects any i86-family game; only Io Moon
triggered it, via its multi-region map + high D000 code.)

## 2. [FIXED] Direct-switch polarity

The Z80 reads direct switches **active-low** (idle `0xFF`); the driver returned ports 0x00/0x03/0x04
non-inverted, so idle = every direct switch phantom-held. Fixed by inverting them.

## 3. [FIXED] DMD read the wrong buffer

Segment 7000h is only a clear/staging area (always all-zeros → solid lit panel). The 80188 draws
into the buffer addressed by the **display pointer at `4000:1150`** (runtime `4000:1220`=`0x41220`).
`iomoon_submit_dmd_frame` now reads that pointer (plane0=base, plane1=base+0x200) and renders real
4-grey attract graphics.

## 4. [FIXED] 80188 interrupts — IVT location + vector + HOLD_LINE

Three things had to be right for the 80188's two interrupts to fire (INT0 type 0x0C →
`frame_isr` D000:0343 = YM3812 music + DMD; Timer0 type 0x08 → `sound_timer_isr` D000:024F = OKI):

1. **Vector.** I188's default IRQ vector is `0xFF` (`cpuintrf.c:465`), so the old
   `cpu_set_irq_line(0,PULSE_LINE)` vectored to type 0xFF — neither ISR. The driver now injects the
   right types with `cpu_set_irq_line_and_vector(…, 0x0C / 0x08)`.
2. **IVT location.** The 80188 reads vectors from physical 0, which the driver maps as ROM2 graphics
   — *not* a valid IVT. The **valid IVT image is in ROM1 (`V1 3_01.bin`) at offset 0** (file `0x20`
   = IVT[8] = `D000:024F`; file `0x30` = IVT[0x0C] = `D000:0343`). A one-time
   `memcpy(region, region+0x80000, 0x400)` places it at physical 0. *(On the real board physical 0
   is RAM holding this image — LMCS is RAM with the DMD graphics banked, not "ROM2 at physical 0";
   a clean memory-map fix is the long-term form, but the memcpy is correct and sufficient.)*
3. **HOLD_LINE, not PULSE_LINE.** MAME's i86 only takes an IRQ `if (I.IF)` and doesn't latch a
   pulse; but its `STI` handler re-checks a *held* request (`if (I.IF && I.irq_state) _interrupt`).
   So `HOLD_LINE` survives the brief IF=0 windows during boot.

**Result (verified):** the boot's `process_input_events` busy-wait on `[4000:113D]` — which is
decremented **only** by `sound_timer_isr` (d02fe) — now clears, so the **boot completes** and the
80188 reaches its normal **interrupt-driven attract** (state 3, DMD rendering). The implemented
generator (`iomoon_irq_gen`, `MDRV_CPU_PERIODIC_INT(…,244)`) emits Timer0 (~99 Hz) and INT0
(~145 Hz) by accumulator. *(One-vector-per-tick under a single IRQ line slightly under-drives the
faster source; a future refinement is two MAME timers or modelling the EOI/INSERV at 0xFF2C to
clear+re-assert. Both ISRs already EOI to 0xFF2C — a no-op in this core.)*

## 5. [OPEN] Music / OKI audible — needs gameplay

In **attract** the game runs with interrupts effectively off after boot (the ISR EOI count freezes —
~27 runs to clear the boot wait, then stops), and attract is **silent on real hardware** (no song is
armed). So no YM3812/OKI output in attract is *correct*. The music sequencer (`D000:0D1B`, DS=4000h:
enable `[12EE]`=`0x412EE`, duration `[12EC]`=`0x412EC`, song ptr `[12EA]`=`0x412EA`, tempo
`[12EF]`=`0x412EF`; song table `CS:0DE5`) and the OKI dispatch only run when the game is in a
**started ball** and re-enables/serves the interrupts. The 10 FM tracks decode cleanly offline
(see `iomoon_fm_extract.md`); the in-emulator path to hearing them is item 6.

## 6. [OPEN — next step] Reaching gameplay

State machine `state_machine_dispatch` (D000:3002) on `game_state_var` (`413C:014F`=`0x4150F`):
1→`attract_mode_handler` (starts a game when `credit_available` `413C:00D4`=**`0x41494`** ≠ 0),
2→`game_active_handler`, 3→attract animation, 4→special. The recipe to drive a started ball
headlessly (from the boot/gameplay RE):

1. **Credit**: poke `0x41494` (413C:00D4) non-zero, *or* assert COIN (switch code `0x42`).
2. **START**: assert switch code `0x41` (Port 0x03 bit 3 → `swMatrix[9]` bit 3; the SLEIC2
   SWITCH_UPDATE already routes the START input there). `button_filter_accept_start` (d7b47) accepts
   0x40/0x41/0x42.
3. **Ball trough**: default-**close** the trough sensors **C6/C7/C8** ("Contacto salida bolas 1-3",
   matrix switches) and leave the drain/outhole **C9** open, else `ball_serve` (d34f4) /
   `ball_drain_handler` (d31d3) treats the ball as drained and bounces back to attract.
4. The Z80 must keep delivering J1 events (the main loop's `vsync_check` d5d1b and
   `timer_tick_handler` d5f03 consume them).

Then `dmd_anim_sequence_play` (d8066) → `dmd_anim_helper` (d815f, state=3) → `game_start_sequence`
(d33a5) → `ball_serve` (d34f4); the game runs interrupt-driven and the YM3812 (`iomoon_periph_w`
PCS5 `0xA0280`/`0xA0281`) + OKI fire.

**Empirical result (this pass):** seeding the credit and pulsing START did **not** progress the game
— it stays locked in **state 3** (attract animation) and never returns to state 1 to check the
credit/START. The state machine isn't cycling, which points at the **Z80↔80188 J1 inter-CPU comms**:
the 80188's attract/main loop consumes Z80 events (switch scans, the `0x47` display sync, queue
bytes ≥0xF0 for `timer_tick_handler`) to advance, and the driver's mailbox approximation
(`iomoon_z80_to_188_mailbox` poking `0x41496`) doesn't deliver the full J1 protocol the 80188 polls.
**So the real next blocker is completing the Z80↔80188 J1 comms** (the byte-port handshake +
switch-event/`switch_event_pending` `[4000:1147]` + the display/queue sync), after which the credit/
START/trough recipe above should drive a started ball with audible music. This is the priority for
the next pass.

---

*PinMAME branch kept local pending review. The driver carries items 1–4 (FIXED); item 6 (the
gameplay switch/credit harness) is the path to items 5 (audible music/OKI) and a fully playable
machine.*
