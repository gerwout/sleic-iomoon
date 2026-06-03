# PinMAME integration findings (Io Moon driver)

[← Back to main README](../README.md)

Findings from making the Io Moon machine actually **run** in PinMAME (the `vpinball/pinmame`
fork, driver `src/wpc/sleic.c`, machine `SLEIC2`), discovered by building and running the
emulator headless (Xvfb, `-nosound`, `-frames_to_run`, valgrind).

> Status: **[FIXED]** verified fix in driver/core · **[CONFIRMED]** verified by running ·
> **[BLOCKED]** understood, fix blocked on a deeper issue · **[OPEN]** not yet resolved.

## Summary of the session

| # | Item | Status |
|---|---|---|
| 1 | Release-build segfault (i86 core `change_pc16` on a 20-bit CPU) | **FIXED** |
| 2 | Direct-switch polarity inverted | **FIXED** |
| 3 | DMD read the wrong (empty) buffer → solid panel | **FIXED** (reads the display-pointer buffer; shows content) |
| 4 | 80188 timer/interrupt configuration | **CONFIRMED** |
| 5 | Interrupt vector→ISR mapping (music/OKI) | **CONFIRMED**, but driving it is **BLOCKED** (§6) |
| 6 | IVT / low-memory map — the keystone blocker for music + OKI | **OPEN** |
| 7 | Music-state addresses & sequencer | **CONFIRMED** |
| 8 | Reaching gameplay (credit / state machine / playfield) | **OPEN** |

The single biggest win: **the game now runs** (the segfault is gone) and the **DMD renders
real content**. Music (YM3812) and speech/FX (OKI) are blocked behind one root cause — the
interrupt vectors can't be driven until the IVT/low-RAM map is corrected (§6).

## 1. [FIXED] Release-build segfault — a genuine i86-core bug (`change_pc16` on a 20-bit CPU)

valgrind pinpointed it: `Invalid read of size 1 at cpu_readop ← i186_execute`, "Access not
within mapped region at address 0xD011C". The shared i86/i186/i188 core sets the opcode-fetch
base (`OP_ROM`) via **`change_pc16`**, but the I188 is a **20-bit (1 MB) address-bus** CPU
(`src/cpuintrf.c`: `CPU0(I188,…,8,20,…)`). The 16-bit updater indexes the L1 table with
`pc>>4` instead of `pc>>8`; for PC ≥ 0x10000 (segment D000 code) that runs past the 4096-entry
table, corrupting `OP_ROM`, and the release fast-path dereferences a wild pointer. The
MAME_DEBUG build's safe path (`CPUREADOP_SAFETY_FULL`) repaired it every fetch, hiding it.

**Fix:** `change_pc16` → `change_pc20` in `src/cpu/i86/i86.h:98` (`CHANGE_PC` macro) and
`src/cpu/i86/i86.c:166,192,589`. Correct for every i86-family CPU in this tree (all 20-bit);
the disassembler in the same core already used `change_pc20`. Verified: clean multi-thousand-
frame headless runs, no segfault. *(This bug affected any complex i86/i186/i188 game; it only
bit Io Moon because of its multi-region map + high D000 code.)*

## 2. [FIXED] Direct-switch polarity inverted

`iomoon_z80_read` returned the direct-switch ports (0x00/0x03/0x04) non-inverted, but the Z80
treats them **active-low** (idle shadows `0xFF`, handlers `bit n / call z`). Idle therefore read
as `0` = every direct switch phantom-held. Fixed by inverting (`~swMatrix[…]`), matching port
0x02.

## 3. [FIXED] DMD read the wrong buffer

The driver decoded the DMD from segment 7000h, which is only a **clear/staging area and is
always all-zeros** (→ a solid all-lit panel). The 80188 actually draws the frame into the
buffer addressed by the **display pointer at `4000:1150`** (offset/segment), which at runtime is
`4000:1220` (physical `0x41220`) and holds the attract content (~330 non-zero bytes). The driver
now reads `cpu_readmem20(0x41150…)` to get the live buffer base and decodes plane 0 = base,
plane 1 = base+0x200 — and the panel now shows real 4-level-grey graphics. *(Minor layout/decode
refinement may still be wanted, and proper double-buffer swap depends on §6, but content renders.)*

## 4. [CONFIRMED] 80188 timer/interrupt configuration (from the boot PCB trace)

From `research/pinmame_session_2/03_boot_pcb_init.txt` (line `XX:Y val` ⇒ PCB offset `XX*2(+Y)`):
**Timer0** MaxCnt A/B `0x6276`, Mode `0xE003` (EN, continuous, CPU/4 clock, INT-on-maxcount) ⇒
**≈99.18 Hz** (10 MHz/4 / 0x6276). **Timer int ctrl** `0xFF32=0x0001` (Timer0 enabled);
**INT0 ctrl** `0xFF38=0x0000` (external INT0 enabled); everything else masked. So exactly
**two interrupt sources: Timer0 (type 8) and INT0 (type 0x0C, external — the PIC DMD-frame edge
~145 Hz)**. PinMAME's I188 core emulates **none** of the integrated timer/interrupt/DMA/chip-
select hardware, so the driver must generate these interrupts itself.

## 5. [CONFIRMED] Interrupt vector → ISR mapping

Decisive evidence = which In-Service-Register bit each ISR clears at EOI (`out 0FF2Ch`):
- **Timer0 (type 8, IVT 0x080) → `sound_timer_isr` @ D000:024F** (clears INSERV bit0) — drives
  the **OKI MSM6376** + the FM frame counter. ~99 Hz.
- **INT0 (type 0x0C, IVT 0x030) → `frame_isr` @ D000:0343** (clears INSERV bit4) — services the
  **YM3812 music sequencer** (D000:0D1B, every other call via the `[1142h]` gate ⇒ ~72 Hz), the
  DMD command queue, and the display draw/swap. ~145 Hz.
- `dmd_vblank_isr` @ D000:016D is **dead code** in the Io Moon config (it never touches INSERV;
  it is leftover from the I8039-DMD SLEIC variants).

**The concrete driver bug:** the I188's default IRQ vector is **0xFF** (`cpuintrf.c:465`
`dirq=255`), so the placeholder `cpu_set_irq_line(…,0,PULSE_LINE)` vectors to type 0xFF — neither
8 nor 0x0C — so **`frame_isr` and `sound_timer_isr` never run** (telemetry: `[1142h]` gate never
toggles, music countdown `[12EC]` never decrements, `ym=0`). The fix is to inject the two
sources by vector via `cpu_set_irq_line_and_vector(…, type)` at their rates (INT0 0x0C @ ~145 Hz,
Timer0 0x08 @ ~99 Hz). **This is implemented and correct in principle — but blocked by §6.**

## 6. [OPEN — keystone] The IVT / low-memory map is wrong, so vectored interrupts can't fire

`PREFIX(_interrupt)` reads the handler from `IVT[type*4]` in **segment 0 (physical 0)**. In the
current driver, physical 0 is mapped as **ROM2 graphics** (`{0x00000,0x6ffff, MRA_ROM}`), and
`V1 3_02.bin` offset 0 is graphics data, **not a valid IVT** (`IVT[8]`=`IVT[0x0C]`=`0000:00F8`).
So firing the real vectors (0x08/0x0C) jumps into garbage and hangs the 80188 (the DMD strobe
freezes). Mapping `0x0–0x3FF` as RAM did **not** help — the game does not write a fresh IVT
there, and the read still returned the ROM2 bytes.

**Implication:** the real low-memory layout differs from the current model. On an 80188 the IVT
*must* be valid at physical 0, and the game *does* enable Timer0+INT0 — so physical 0 must be
**RAM** (or a ROM image that actually starts with a valid IVT) on the real board, not the DMD
graphics ROM. The strong hypothesis: **LMCS (`0x00000–0x3FFFF`) selects work RAM, and the DMD
graphics ROM is banked** (consistent with the IC40 `VA12` bank bit and the IC7 PAL), i.e. the
driver's "ROM2 at physical 0" assumption is incorrect for the low region. Resolving this — where
the IVT lives, whether/where the game builds it, and the true LMCS RAM/ROM + graphics-bank
decode — is the **keystone** that unblocks music (§5), OKI (§5), correct DMD double-buffering
(§3), and the proper interrupt rates (§4). It likely needs the IC7 PAL dump or a low-address bus
trace to settle definitively.

## 7. [CONFIRMED] Music-state variables (segment 4000h)

`music_sequencer` (D000:0D1B) sets **DS = 4000h**: `[12EE]` enable = `0x412EE`, `[12EC]`
duration = `0x412EC`, `[12EA]` song pointer (into CS=D000) = `0x412EA`, `[12EF]` tempo =
`0x412EF`; song table `CS:0DE5`. Forcing these produced YM3812 writes only when `frame_isr` runs
(i.e. once §6 is solved). The 10 FM tracks decode cleanly (see `iomoon_fm_extract.md`).

## 8. [OPEN] Reaching gameplay

State machine `state_machine_dispatch` (D000:3002) reads `game_state_var` (`413C:014F` =
`0x4150F`): 1→`attract_mode_handler`, 2→`game_active_handler`, 4→special, else→`default_game_logic`.
In attract the game cycles state **1** (checks credit) and **3** (`dmd_anim_helper`, attract
animation). `attract_mode_handler` (D000:303C) starts a game (state→2) when `credit_available`
(`413C:00D4` = `0x41494`) ≠ 0. Seeding a credit did not progress to a ball in the current run —
because the service ISR (§6) isn't running and the ball-trough playfield switches aren't modelled
(the start sequence can't complete). Also: the Z80 suppresses the coin/start switch codes while
not already in a game; the coin path is the 80188 credit counter, and the direct coin switch is
shared with TEST. Full gameplay needs §6 solved plus the playfield switch/solenoid layer.

---

*PinMAME branch kept local pending review; only this doc (and the existing RE docs) are committed
to the reverse-engineering repo. The remaining blocker (§6) is the priority for the next pass.*
