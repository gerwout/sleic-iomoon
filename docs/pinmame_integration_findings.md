# PinMAME integration findings (Io Moon driver)

[← Back to main README](../README.md)

Findings from making the Io Moon machine **run** in PinMAME (the `vpinball/pinmame` fork,
driver `src/wpc/sleic.c`, machine `SLEIC2`), from building + running headless (Xvfb, `-nosound`,
`-frames_to_run`, valgrind, gdb).

> Status: **[FIXED]** verified fix in the driver/core · **[VALIDATED]** mechanism proven but
> gated on a deeper blocker · **[OPEN]** the remaining blocker.

## Summary

| # | Item | Status |
|---|---|---|
| 1 | Release-build segfault (i86 `change_pc16` on a 20-bit CPU) | **FIXED** — the game now runs |
| 2 | Direct-switch polarity inverted | **FIXED** |
| 3 | DMD read the wrong (empty) buffer → solid panel | **FIXED** — reads the display-pointer buffer; renders real 4-grey content |
| 4 | 80188 timer/interrupt config + vector→ISR map | **VALIDATED** |
| 5 | Driving the real interrupt vectors (music/OKI) | **VALIDATED** — IVT + HOLD_LINE makes `frame_isr` run |
| 6 | Game stays in IF=0 "degraded boot" → interrupts don't sustain | **OPEN — the keystone** |
| 7 | Gameplay (credit / state machine / playfield switches) | **OPEN** |

The three **[FIXED]** items are in the driver (kept local for review). Items 4–5 are validated and
implemented-but-disabled (the driver ships the simple placeholder IRQ) because of item 6.

## 1. [FIXED] Release-build segfault — a genuine i86-core bug

valgrind: `Invalid read of size 1 at cpu_readop ← i186_execute`, "Access not within mapped region
at 0xD011C". The i86/i186/i188 core sets the opcode base (`OP_ROM`) via **`change_pc16`**, but I188
is a **20-bit** CPU (`cpuintrf.c: CPU0(I188,…,8,20,…)`); the 16-bit updater indexes the L1 table with
`pc>>4` instead of `pc>>8`, so a PC ≥ 0x10000 (segment D000) corrupts `OP_ROM`, and the release fast
path dereferences it. The MAME_DEBUG build's safe path hid it. **Fix:** `change_pc16`→`change_pc20`
in `src/cpu/i86/i86.h:98` and `src/cpu/i86/i86.c:166,192,589`. Verified: clean multi-thousand-frame
runs, no segfault. (Affects any i86-family game; only Io Moon triggered it.)

## 2. [FIXED] Direct-switch polarity

The Z80 reads direct switches **active-low** (idle `0xFF`); the driver returned ports 0x00/0x03/0x04
non-inverted, so idle = every direct switch phantom-held. Fixed by inverting them (`~swMatrix[…]`).

## 3. [FIXED] DMD read the wrong buffer

Segment 7000h is only a clear/staging area (always all-zeros → a solid lit panel). The 80188 draws
into the buffer addressed by the **display pointer at `4000:1150`** (segment/offset; runtime
`4000:1220` = `0x41220`, ~330 non-zero bytes of attract content). The driver now reads that pointer
(`iomoon_submit_dmd_frame`) and decodes plane0=base / plane1=base+0x200 — real 4-grey graphics now
render. *(Double-buffer swap and exact layout polish depend on item 6; without the swap there can be
tearing, but content is correct.)*

## 4. [VALIDATED] 80188 timer/interrupt config and vector→ISR map

From the boot PCB trace: **Timer0** (MaxCnt `0x6276`, mode `0xE003`) ⇒ **≈99.18 Hz**; **Timer-int
ctrl** `0xFF32=0x0001` and **INT0 ctrl** `0xFF38=0x0000` ⇒ only **Timer0 (type 8)** and **INT0
(type 0x0C, external)** are enabled. The vector→ISR map (proven by which In-Service bit each ISR's
EOI clears):
- **Timer0 (type 0x08, IVT 0x080) → `sound_timer_isr` @ D000:024F** — OKI MSM6376 — ~99 Hz.
- **INT0 (type 0x0C, IVT 0x030) → `frame_isr` @ D000:0343** — YM3812 music sequencer (via the
  `[1142h]` gate, ~72 Hz effective) + DMD queue + display swap — external PIC DMD-frame ~145 Hz.
- `dmd_vblank_isr` @ D000:016D is **dead code** in this config.

PinMAME's I188 core emulates **no** integrated timer/interrupt controller, and its default IRQ vector
is **0xFF** (`cpuintrf.c:465`), so the placeholder `cpu_set_irq_line(0,PULSE_LINE)` vectors to type
0xFF and **neither ISR runs**.

## 5. [VALIDATED] Driving the vectors — IVT location + HOLD_LINE

Two non-obvious facts made `frame_isr` actually run:

**(a) The IVT is in ROM1, not at physical 0.** The 80188 reads vectors from physical 0, which the
driver maps as ROM2 graphics — *not* a valid IVT (`IVT[8]`=`IVT[0x0C]`=`0000:00F8`). The **valid IVT
image lives in `V1 3_01.bin` (the code ROM) at offset 0x0–0x3FF**: file `0x20` = `4f 02 00 d0`
(IVT[8]=`D000:024F`=sound_timer_isr), file `0x30` = `43 03 00 d0` (IVT[0x0C]=`D000:0343`=frame_isr).
On the real board physical 0 is RAM holding this image (LMCS is almost certainly RAM with the DMD
graphics banked — *not* "ROM2 at physical 0" as the driver assumes). A one-time
`memcpy(region, region+0x80000, 0x400)` places the valid IVT at physical 0 and the vectors resolve
correctly. *(A clean memory-map fix — LMCS=RAM + banked graphics — is the proper long-term form.)*

**(b) Use HOLD_LINE, not PULSE_LINE.** MAME's i86 only takes an IRQ `if (state!=CLEAR && I.IF)` and
does not latch it — so a `PULSE_LINE` issued while `IF=0` is lost forever. But the i86 **`STI`
handler re-checks a held request** (`if (I.IF && I.irq_state) _interrupt(-1)`), so a **`HOLD_LINE`**
request survives until the game enables interrupts. The implemented (validated) generator:

```c
/* INT0 0x0C -> frame_isr (music+DMD); Timer0 0x08 -> sound_timer_isr (OKI). Place the IVT once. */
static INTERRUPT_GEN(iomoon_irq_gen) {            /* MDRV_CPU_PERIODIC_INT(iomoon_irq_gen, 145) */
  static int ivt_done = 0;
  if (!ivt_done) { UINT8 *r = memory_region(SLEIC_MEMREG_CPU); ivt_done=1; memcpy(r, r+0x80000, 0x400); }
  iomoon_t0_acc += 99.18/145.0;
  if (iomoon_t0_acc >= 1.0) { iomoon_t0_acc -= 1.0;
    cpu_set_irq_line_and_vector(SLEIC_MAIN_CPU, 0, HOLD_LINE, 0x08); }   /* Timer0 -> OKI   */
  else
    cpu_set_irq_line_and_vector(SLEIC_MAIN_CPU, 0, HOLD_LINE, 0x0C);     /* INT0   -> music */
}
```

**Result:** with (a)+(b), `frame_isr` **runs** (no crash; the 80188's main loop advances to new
states as it services interrupts). This is real, verified progress on the sound path. *(One-vector-
per-tick under-drives INT0; the proper form runs the generator at ~244 Hz and emits whichever source
is due, or models the EOI to clear the line — but that refinement is moot until item 6.)*

## 6. [OPEN — keystone] The game stays in IF=0 "degraded boot"

Even with valid vectors held, the YM3812 stays silent and the music player's `[12EC]` countdown
doesn't advance. Instrumentation shows the IRQ is *requested* ~9700×/run but **taken only once or
sporadically** — i.e. the 80188 runs with **IF≈0** almost always. On real hardware the game runs
**interrupt-driven** (IF=1) — its music, OKI and DMD timing depend on Timer0/INT0. So the emulated
game is in a **degraded boot**: it never enters its normal interrupt-enabled main loop.

The strong hypothesis: the boot blocks on a readiness check it never passes — most likely the
**Z80↔80188 J1 handshake / inter-CPU sync** (the 80188 expects the Z80 to report the playfield/IO is
alive before it commits to the interrupt-driven game loop), and/or a self-test the headless harness
doesn't satisfy. Resolving this — getting the 80188 to complete boot and run with IF=1 — is the
keystone that unblocks **music (item 5), OKI, correct DMD double-buffering (item 3), the right
interrupt rates (item 4), and gameplay (item 7)** together.

## 7. [OPEN] Reaching gameplay

State machine `state_machine_dispatch` (D000:3002) on `game_state_var` (`413C:014F`=`0x4150F`):
1→`attract_mode_handler` (starts a game when `credit_available` `413C:00D4`=`0x41494` ≠ 0), 2→game,
3→attract animation (`dmd_anim_helper`), 4→special. Seeding a credit didn't start a ball — the
service ISR (item 6) isn't sustained and the ball-trough playfield switches aren't modelled. Coin
acceptance is via the 80188 credit counter (the Z80 gates the coin/start switch codes on being
in-game). Full gameplay needs item 6 solved + the playfield switch/solenoid layer.

## Music-state addresses (for reference, item 5)

`music_sequencer` (D000:0D1B) uses DS=4000h: `[12EE]` enable=`0x412EE`, `[12EC]` duration=`0x412EC`,
`[12EA]` song ptr=`0x412EA`, `[12EF]` tempo=`0x412EF`; song table `CS:0DE5`. Forcing these plays a
track only once `frame_isr` is sustained (item 6). The 10 FM tracks decode cleanly
(see `iomoon_fm_extract.md`).

---

*PinMAME branch kept local pending review. The shipped driver carries items 1–3 (FIXED) plus the
placeholder IRQ; the item-4/5 interrupt solution above is validated and ready to enable once item 6
(the IF=0 boot) is solved — that is the priority for the next pass.*
