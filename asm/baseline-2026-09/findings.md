# IO Moon — driver contract, F1..F21

Twenty-one numbered facts extracted from the **2026-09 fresh baselines** in
this directory. Later driver tasks reference them by number.

**Sources, and only these sources.** Every address citation below was read out
of one of:

| source | what |
|---|---|
| `asm/baseline-2026-09/iomoon_80188.lst` | 80188 game/sound ROM (`V1 3_01.bin`), 83 regions, 29810 instructions, 3-way cross-verified |
| `asm/baseline-2026-09/iomoon_z80.lst` | Z80 I/O ROM (`V1 3_05.bin`), 12 regions, 4760 instructions, 2-way cross-verified |
| `asm/pic16c57_annotated.asm` | IC23 PIC16C57 raster program, 3-tool verified (150 words) |
| the ROM images themselves | raw byte reads, quoted with the offset |

`docs/*.md`, `asm/superseded/80188_annotated.asm`,
`asm/superseded/z80_annotated.asm` and the old
`sleic` branch driver were used **only as hypotheses to test**. Where one of
them is named below it is being adjudicated, never cited as evidence.

**Address conventions.** 80188 addresses are flat 20-bit; `SEG:OFF` is given
where the code's own segment register makes it clearer.
`linear = file offset + 0x80000` for `V1 3_01.bin`. Z80 addresses are flat
16-bit and equal the file offset in `V1 3_05.bin`.

**Reading a fact.** *Statement* is what the driver must implement.
*Evidence* is the instruction stream that says so. *Confidence* is
**confirmed** (directly readable in the listings — implement it literally) or
**inferred** (a reasoned conclusion that a schematic, PAL dump or scope trace
could still overturn — implement it, but behind a named constant).
*Disposition* adjudicates the prior hypothesis the brief named.

A summary of what changed, and the per-fact audit of the old `sleic` branch,
are the last two sections.

---

## F1 — Chip-select and interrupt-controller initialisation

**Statement.** The reset path is
`FFFF0 -> FFF00 -> D000:0000`, and `D000:0000` runs a 30-entry table-driven
`OUT` loop that programs every 80188 peripheral-control-block register the
firmware ever uses. The resulting map is:

| register | I/O | value | effect |
|---|---|---|---|
| UMCS | `FFA0` | `C03C` | ROM window `0xC0000-0xFFFFF` (written by the reset stub, before the table) |
| LMCS | `FFA2` | `3FFC` | low window `0x00000-0x3FFFF` |
| MMCS | `FFA6` | `41FC` | mid-range memory base `0x40000` |
| PACS | `FFA4` | `A03C` | peripheral chip-select base `0xA0000` |
| MPCS | `FFA8` | `A0FC` | peripherals memory-mapped, 7 PCS lines, 4x64 KiB mid-range blocks |

so `PCS0..PCS6 = 0xA0000, 0xA0080, 0xA0100, 0xA0180, 0xA0200, 0xA0280,
0xA0300` (0x80 spacing), and the mid-range memory region is
`0x40000-0x7FFFF` in four 64 KiB blocks.

Timer 0: mode `E003` (enabled, interrupt on, continuous), max count A = max
count B = `6276` = 25206. Timers 1 and 2 disabled (`FF5E`/`FF66` = 0).
Interrupt controller: **only timer0 (`FF32`=0001, priority 1) and INT0
(`FF38`=0000, priority 0, edge triggered) are unmasked**; DMA0, DMA1, INT1,
INT2, INT3 all have MSK set (`000F`), and `PRIMSK` (`FF2A`) = 1 restricts
service to priority levels 0-1. Both DMA channels are programmed and
**parked** — control word `FFA0` written *first*, with ST (bit 1) and CHG
(bit 2) both clear, so the write cannot start a channel.

**Nothing reprograms any of this after boot.** The only peripheral-control-block
registers written anywhere else in the decoded ROM are `FF2C` (INSERV, the
two EOI writes) and `FFA0` (UMCS, in the reset stub).

**Evidence.**
```
FFFF0: EA 00 00 F0 FF     JMP FAR FFF0:0000
FFF00: BA A0 FF           MOV DX, 0FFA0
FFF03: B8 3C C0           MOV AX, 0C03C
FFF06: EF                 OUT DX, AX
FFF07: EA 00 00 00 D0     JMP FAR D000:0000
D0012: BE 41 00           MOV SI, 00041      ; table at CS:0041
D0015: B9 1E 00           MOV CX, 0001E      ; 30 entries
D0018: 2E AD / 8B D0 / 2E AD / EF / E2 F7    ; LODSW port, LODSW value, OUT, LOOP
```
The table spans `CS:0041..CS:00B9` (30 x 4 bytes = 120), ending exactly on
`D000:00B9`, the first routine `boot_init` far-calls. Full 30-row table in
`README.md` section *Step 1*.

Timer 0 rate: 25206 counts at CLKOUT/4. With CLKOUT = 10 MHz (the
N80C188-10 at IC1) that is 2.5 MHz / 25206 = **99.18 Hz**. The count is
confirmed; the frequency depends on the crystal, which no ROM states.

**The external sub-decode.** The 80188's chip-select lines are whole windows
with no cycle qualification; the IC7 PAL narrows them, and its dump
([`../../roms/PAL20L10/`](../../roms/PAL20L10/)) gives the map exactly.
`/LCS` and `/UCS` both produce the same program-ROM select `/PRCS`, which is
the hardware behind ROM1 answering in two places. `/MCS0` is split on `A15`:
`/RAM1` for `0x40000-0x47FFF`, the 32 KB work RAM at IC12, and `/RAM2` for
`0x48000-0x4FFFF`, which has a select and no memory behind it. `/MCS1` gated
by `A15`=0 and the two PCS0 interlock bits becomes the NVRAM's `/EECE` (F10).
`/MCS3` qualified by `/WR` becomes `/WRVRAM`, the write strobe into the DMD
staging buffer (F13). `/PCS6` and `/PCS4`, likewise qualified by `/WR`, become
`/OKCS` and `/OOE`. `/PCS1`, `/PCS2`, `/PCS3` and `/PCS5` are not IC7 inputs
at all — the J1 latches and the YM3812 hang off the 80188's own lines.

**Confidence:** confirmed (register/value table); the 99.2 Hz figure is
inferred from an assumed 10 MHz CLKOUT.

**Disposition:** hypothesis **confirmed**, and extended — the old material
quoted 5 of the 30 entries and did not record the interrupt-controller
masking, the PRIMSK value, or the DMA parking.

---

## F2 — What is in the LMCS window, and the graphics bank

**Statement.** Two separate things, and the old hypothesis conflated them.

1. **The LMCS window is not banked.** LMCS (`0x00000-0x3FFFF`) is ROM1's own
   low half, holding the IVT and the animation data the `F5183` far-pointer
   table addresses. Nothing selects it; it is always present.
2. **There *is* a banked graphics window, elsewhere: segment `6000`
   (`0x60000-0x6FFFF`), selected by PCS0 bits 0-2, holding pages 0-6 of
   `V1 3_02.bin`.** So ROM2 *is* in the 80188's address space, one 64 KiB
   page at a time.

```
LMCS        0x00000-0x3FFFF  <-  V1 3_01.bin file 0x00000-0x3FFFF   (IVT + animation data, unbanked)
seg 6000    0x60000-0x6FFFF  <-  V1 3_02.bin file (page<<16) .. +0xFFFF, page = PCS0 bits 0-2, 0..6
UMCS        0xC0000-0xFFFFF  <-  V1 3_01.bin file 0x40000-0x7FFFF   (code)
```

Segment `6000` is **read-only in practice**: no instruction writes it, and
`06000` is never loaded as an immediate segment value — it is only ever
reached through the far pointers below.

**Evidence — part 1, the LMCS window.**

1. The CPU must fetch interrupt vectors from physical `0`, which lies inside
   the LMCS window. `V1 3_01.bin` file offset `0x0000-0x00FF` is a coherent
   IVT — 61 of 64 slots are the uniform filler `IP=F000, CS=FFF0`, and the
   three live slots point at real handlers:
   ```
   file 0x0008:  6D 01 00 D0   -> D000:016D   (vector 02, NMI)
   file 0x0020:  4F 02 00 D0   -> D000:024F   (vector 08, timer 0)
   file 0x0030:  43 03 00 D0   -> D000:0343   (vector 0C, INT0)
   ```
   `V1 3_02.bin` offset `0x0000` is `20 00 10 00 00 02 7F 7F ...`, which is a
   frame header (see part 2), not an IVT. Only ROM1 can be at physical 0.
2. **No code writes segment 0 anywhere**, and there is no IVT copy loop:
   `MOVSW`/`MOVSB` occur **zero times in the decoded listing**, and a
   whole-image byte scan of `V1 3_01.bin` for `F3 A5` (`REP MOVSW`) and
   `F3 A4` (`REP MOVSB`) also returns zero — both re-verified this round.
   Every `MOV AX,0 / MOV ES,AX` site (36 of them, from `DE5D2` on) is
   followed by a *read* (`MOV AL, ES:B[2C9B]`-shaped).
3. The 620-byte far-pointer table at `F5183-F53EF` (155 entries) is read by
   the animation family with `LES SI, CS:52xx/53xx` (`F0750`, `F138F`,
   `F2ECB`, `F4954`, `F0963: 2E C4 36 BB 52  LES SI, CS:052BB`). Its segment
   histogram is `0000`x12, `1000`x43, `2000`x47, `3000`x44, `4000`x9 —
   **146 of 155 pointers address flat `0x00000-0x3FFFF`**, exactly the LMCS
   window; the other 9 are work RAM.
4. Spot check of one such pointer. `CS:52BB` (file `0x752BB`) holds
   `54 91 00 20` = `2000:9154` = flat `0x29154`. At file offset `0x29154`,
   `V1 3_01.bin` reads
   `00 F0 F8 0C 06 06 06 06 06 06 06 06 06 06 0C F8 F0 00` twice over — a
   closed glyph outline, the same shape in both bitplanes.

**Evidence — part 2, the segment-6000 bank.**

5. **PCS0 bits 0-2 are a 3-bit output register with its own accessor.**
   ```
   sub_F00A0 F00A0:
       F00A0: 55 / 8B EC              PUSH BP / MOV BP,SP
       F00A4: B8 00 40 / 8E D8        DS = 4000
       F00A9: B8 00 A0 / 8E C0        ES = A000
       F00AE: 8A 46 06                MOV AL, B[BP + 006]     ; the caller's argument
       F00B1: 80 26 34 11 F8          AND 01134, 0F8          ; clear bits 0-2 of the PCS0 shadow
       F00B6: 0A 06 34 11             OR  AL, 01134
       F00BA: 26 A2 00 00             MOV ES:B[00000], AL     ; PCS0 <- shadow with new bits 0-2
       F00BE: A2 34 11                MOV B[01134], AL
   ```
6. **17 call sites, all immediates in 0..6, each immediately followed by a
   far pointer into segment `6000` and `anim_stream_open`.** `F1548`,
   `F1597`, `F1708`, `F1757`, `F17A6`, `F183D`, `F191C`, `F196B`, `F1D1A`,
   `F1D69`, `F2B00`, `F2B4F`, `F2BE6`, `F4410`, `F479F`, `F4BD8`, `F4F6A`.
   The idiom is uniform:
   ```
   F1754: 6A 00 / 0E / E8 46 E9       PUSH 000 / PUSH CS / CALL sub_F00A0   ; select page 0
   F175B: 2E C4 36 0D 13              LES SI, CS:0130D
   F1760: BF 00 00 / E8 E2 EB         DI = 0 / CALL anim_stream_open

   F1919: 6A 01 ... CALL sub_F00A0 ; LES SI, CS:01311                        ; page 1
   F1705: 6A 02 ... CALL sub_F00A0 ; LES SI, CS:01319                        ; page 2
   F183A: 6A 03 ... CALL sub_F00A0 ; LES SI, CS:0131D                        ; page 3
   ```
7. **Those pointers all resolve to segment `6000`.** Read out of the ROM at
   `CS:130D..1335` (file `0x7130D`):
   `6000:0000`, `6000:0000`, `6000:6496`, `6000:0000`, `6000:0000`,
   `6000:88CC`, `6000:B108`, `6000:0000`, `6000:0000`, `6000:0000`,
   `6000:7CBA`.
8. **Four different selectors open a stream at the same address
   `6000:0000`** — `F1754` (0), `F1919` (1), `F1705` (2), `F183A` (3). That
   is only coherent if the selector pages the window; otherwise all four
   routines would display identical graphics.
9. **The pages carry the header `anim_stream_open` reads.**
   ```
   anim_stream_open F0348:  [1102] <- ES:W[SI]     ; rows
                            [1104] <- ES:W[SI+2]   ; bytes per row
                            [1106] <- ES:W[SI+4]   ; plane stride
                            [10FE] <- SI, [1100] <- ES
   sub_F036D:               ES = [1100], BP = [1106], DI = 0600, BX = 0200,
                            CX = 0x20 rows x 0x10 bytes;
                            ES:B[SI] -> [0600+], ES:B[BP+SI] -> [0800+]
   ```
   Every 64 KiB page of `V1 3_02.bin` at offsets `0x00000, 0x10000, ...,
   0x60000` begins with the **identical** three words
   `20 00 / 10 00 / 00 02` = rows `0x20` (32), bytes/row `0x10` (16), plane
   stride `0x200` (512) — exactly the 128x32 two-plane geometry `sub_F036D`
   consumes, and exactly the F13 buffer layout. Page 7 (`0x70000`) is
   entirely blank (0 non-zero bytes), which matches the selector range 0-6
   observed at the call sites. Non-zero byte counts per page: 42433, 7976,
   22485, 31833, 16255, 16558, 12027, **0**.

**The complete PCS0 (`0xA0000`) bit map**, since three facts share this one
register. Every write in the ROM is accounted for; the shadow is
`[4000:1134]` and boot leaves it at `0x28`:

| bits | role | written by | fact |
|---|---|---|---|
| 0-2 | segment-6000 graphics page select, 0..6 | `sub_F00A0` `F00BA`, from a caller argument (17 sites) | F2 |
| 3, 4 | complementary segment-5040 NVRAM window gate (open = bit4, closed = bit3) | `pcs0_window_open` `D0596`, `pcs0_window_close` `D05B7` | F10 |
| 5 | OKI `/OKCS` strobe, idle high, pulsed low-high | `okcs_strobe` `D0CEA`/`D0CF7`, `pcs0_bit5_clear` `D0D04`, `pcs0_bit5_set_far` `D0D16` | F9 |
| 6, 7 | **never written**; stay 0 from the boot value `0x28` | — | — |

**Confidence:** confirmed. The page->file mapping (`page << 16`) is the
natural reading of a 3-bit selector over a 512 KiB part and is corroborated
by all seven populated pages carrying the header and page 7 being blank, but
the *bit order* of the selector (whether bit 0 is A16) is **inferred**. IC7 is
dumped ([`../../roms/PAL20L10/`](../../roms/PAL20L10/)) and settles nothing
here: the page bits are latched in IC40 and go to IC11's high address lines
directly, so they never reach the PAL, whose eight outputs are `/PRCS`,
`/RAM1`, `/RAM2`, `/EECE`, `/WRVRAM`, `/OKCS`, `/OOE` and `/TEST`. A scope, or
tracing IC40's outputs to IC11, is what remains. A driver should implement it
as a table of seven base offsets so a swap is a one-line change.

**Disposition:** hypothesis **partly rejected, partly corrected**.
*Rejected:* "PCS0 bits **4/5** select ROM2 frames vs ROM1 fonts **in segment
0000h**" — bits 3/4 gate the segment-5040 non-volatile store (F10), bit 5 is
the OKI `/OKCS` strobe (F9), and segment `0000` is not banked at all.
*Corrected:* the underlying intuition that PCS0 banks a graphics ROM was
right — it is **bits 0-2**, over **segment 6000**, not bits 4/5 over segment
0000.

---

## F3 — Interrupt table and the three live ISRs

**Statement.** The IVT is **resident in ROM** at flat `0x00000` (through
LMCS, see F2) — the firmware installs nothing. Three vectors are live:

| vector | handler | what it does |
|---|---|---|
| `02` NMI | `D000:016D` | inbound J1 byte: asserts PCS4 bits, reads PCS2 `0xA0100`, byte `0x32` bumps `[4000:1144]`, every other byte is appended to the `4000:1220` log and sets flag `[4000:1147]` |
| `08` timer 0 | `D000:024F` | OKI duration counters and deferred triggers, general down-counters `[1139]`/`[113B]`/`[113D]`/`[113F]`/`[1140]`, EOI = clear INSERV **bit 0** |
| `0C` INT0 | `D000:0343` | alternating half-frames: even = DMD blit + animation dispatch, odd = DMD composite + `fm_player_tick` + `qout_service_pcs1`, EOI = clear INSERV **bit 4** |

The INT0 handler toggles `[4000:1142]` on entry, so its two bodies run on
alternate interrupts:

```
D0352: 80 3E 42 11 00   CMP  01142, 000
D0357: 75 25            JNE  0D037E
D0359: C6 06 42 11 FF   MOV  01142, 0FF      ; even branch
D035E: 9A EB 08 00 F0   CALL 0F000:008EB     ; DMD blit  4000:0A00 -> 7000:0000
D036A: 9A 03 13 00 F0   CALL 0F000:01303     ; anim_dispatch_10F6
...
D037E: C6 06 42 11 00   MOV  01142, 000      ; odd branch
D0383: 9A A5 08 00 F0   CALL 0F000:008A5     ; DMD composite
D038D: 9A 1B 0D 00 D0   CALL 0D000:00D1B     ; fm_player_tick
D0392: E8 50 FE         CALL qout_service_pcs1
```

The two EOI masks are self-checking: `D031E: MOV DX,0FF2C / IN AX,DX /
AND AX,000FE / OUT DX,AX` clears the **timer** in-service bit in the handler
reached from vector `08`, and `D03AD: ... AND AX,000EF` clears the **INT0**
in-service bit in the handler reached from vector `0C`. That agrees with the
interrupt-controller programming in F1.

**INT0's electrical source is not determined by either ROM.** Candidates,
with the rate each implies:

| candidate | rate | argument for |
|---|---|---|
| PIC per-plane pulse RA0 | ~290 Hz | the ISR does DMD work; ~145 Hz wire frame x 2 planes |
| PIC per-frame pulse RC3 | ~145 Hz | same, one interrupt per frame |
| Z80 port-`0x81` bit 3 toggle | **not fixed-rate** | bit 3 sits in the J1 control register with five other J1 handshake bits and the Z80 never reads it back, so it is plausibly a line *to* the 80188. But it is **not a free-running square wave**: `port81_bit3_toggle` `0C97` flips it when the `C045` counter expires, and `C045` is *reloaded by J1 traffic* — to `#$30` by the NMI (`009E: 21 45 C0 / 36 30`) and to `#$20` by `host_send_c008_a` (`014B: 21 45 C0 / 36 20`) — so the interval stretches whenever bytes move. With INT0 configured edge-triggered (`FF38 = 0000`) only one polarity latches, so a set/clear pair yields one interrupt: at a nominal 977 Hz Z80 IRQ that is ~30 Hz *at best*, and irregular. Weakest of the three. |

**Recommended starting value — not confirmed: the PIC per-plane pulse,
~290 Hz.** Two arguments. (a) The ISR's two branches are blit and composite
(F13); at one interrupt per *plane* they line up as blit at plane-0 start and
composite at plane-1 start — a clean double-buffer per wire frame, giving one
full DMD update per ~145 Hz frame. (b) It is the only candidate whose implied
outbound byte rate (INT0/8 = ~36 bytes/s) can carry 64 lamps and 13 drivers
at a playable rate; ~145 Hz gives 18/s and the bit-3 candidate gives under 4/s.

Everything the 80188 paces off INT0 — DMD refresh, FM tempo, and the
outbound-queue drain rate — scales with this choice, so the driver must hold
it in **one named constant** and label it as unmeasured.

**Emulation result, added 2026-09-02 by the PinMAME interrupt task — read
this before re-deriving 290 Hz.** Both PIC rates were tried in the driver and
**neither is servable**, because of what the handler at `D000:0343` costs.
Its composite branch `sub_F08A5` alone is two 512-iteration byte loops of 7–9
instructions each — about **65 000 clocks, 6.5 ms at 10 MHz** — and its blit
branch `sub_F08EB` is a 512-iteration loop plus the animation dispatch;
measured over a headless boot the handler averages **7.5 ms** (timer 0's, for
comparison, is 28 µs). A 290 Hz period is 3.45 ms and a 145 Hz period 6.9 ms,
so neither contains it. The failure is not graceful: INT0 outranks timer 0 on
the controller (F1: priority 0 against 1), so a permanently-pending INT0
**starves the timer outright** — at 290 Hz timer 0 measures **0 interrupts
per second** and the firmware never leaves its frame-delay loop at `D5611`.
Measured sweep (PinMAME, headless, 400–800 frames):

| INT0 setting | INT0 served | timer 0 served | in-ISR | firmware |
|---|---|---|---|---|
| 290 Hz (this fact's recommendation) | 124.8/s | **0.0/s** | 93.8% | stuck in the `D5611` delay loop |
| 145 Hz | 116.7/s | 34.0/s | 87.5% | reaches the `D2F59` J1 wait, timers 3× slow |
| 100 Hz | 99.9/s | 65.8/s | 75.0% | reaches `D2F59`, timers 1.5× slow |
| **72.5 Hz (shipped)** | **72.5/s** | **92.1/s** | 54.4% | reaches `D2F59`, timers ~7% slow |
| 60 Hz | 59.9/s | 93.5/s | 45.0% | reaches `D2F59` |

The driver therefore ships `IOMOON_INT0_HZ = 72.5`, which is a
**serviceability constant matching no candidate in the table above** — it is
not a hardware derivation, and in particular it is *not* "145 Hz ÷ 2 planes":
a per-plane pulse multiplies the frame rate, which is why the per-plane
candidate is 290 Hz. It is simply the highest rate at which both handlers
stay served.

**What this does to the source hypothesis.** If the handler costs anything
like 7 ms on silicon too — the instruction count says it should, since a real
80186 needs the same clocks and the 80188's 8-bit bus needs more — then no
~290 Hz line can be driving it, so the measurement **weakens the per-plane
source hypothesis itself**, not merely its rate. It does not refute it: an
emulator's cycle model is not a scope, and the argument runs through the
handler's cost rather than through the PIC. **F3's gap stays open**; this is
an emulation-side result, not a hardware confirmation. Sweep logs:
`scratchpad/regression/task9-*.log` and `t9-sweep*.log` of that session,
reproducible with the driver's `SLEIC_PROBE_INT0HZ` / `SLEIC_PROBE_IRQ`.

**Confidence:** confirmed for the vectors, handlers and their bodies;
**inferred/unresolved** for the INT0 source and rate — with the emulation
result above narrowing the plausible rate to well under ~130 Hz for as long
as the handler-cost argument holds.

**Disposition:** hypothesis **corrected**. "NMI type 2 = DMD frame handler"
is wrong — vector 02 is the *inbound byte* handler and touches no pixel data;
the DMD work is in the INT0 handler. "Type 8 timer, type 0x0C INT0" is
confirmed. The prior claim that `D000:0343` is a timer ISR (and the
"sound timer ISR at `D000:0250`", one byte past the real vector) is rejected.

---

## F4 — The "marker contract": there is no marker byte stream

**Statement.** **`0xA0100` (PCS2) carries Z80->80188 bytes and nothing else.
No DMD frame markers are ever delivered as bytes, so there is nothing for a
driver to synthesise.** The bytes `0x45`, `0x46` and `0x47` are real, but
they are **Z80 replies to 80188 commands**, sent through the ordinary
`C0FC` J1 channel — not per-frame markers.

**Evidence.**

1. `0xA0100` is read **exactly once in the entire 80188 ROM**, at `D018C`
   inside the NMI handler:
   ```
   D0181: A0 38 11        MOV AL, B[01138]     ; PCS4 shadow
   D0184: 0C D0           OR  AL, 0D0          ; assert bits 7,6,4 (not shadowed)
   D0186: 90 90           NOP NOP
   D0188: 26 A2 00 02     MOV ES:B[00200], AL  ; PCS4 = read gate
   D018C: 26 A0 00 01     MOV AL, ES:B[00100]  ; <- the ONLY PCS2 read
   D0190: 3C 32           CMP AL, 032          ; <- the ONLY compare in the handler
   D0192: 75 07           JNE 0D019B
   D0194: FE 06 44 11     INC 01144            ; 0x32 -> counter, not queued
   D0198: EB 2A           JMP 0D01C4
   D019B: ...             ; everything else -> append to the 4000:1220 log
   D01C4: B0 FF / A2 47 11    MOV [01147], 0FF ; "byte available" flag
   D01C9: A0 38 11 / 0C 80 / 26 A2 00 02       ; PCS4 bit 7 left asserted (ack)
   D01D4: C7 06 40 11 10 00  MOV 01140, 00010  ; 16-tick timeout, see F6
   ```
   `0x32` is the **only** value the NMI special-cases.
2. `0x47`, `0x45` and `0x46` do appear — as compares in *poll routines* that
   dequeue from the `4000:1220` log, far away from the NMI:
   ```
   D5D80: 3D 47 00        CMP AX, 00047     ; sub_D5D1B
   D5DF6: 3D 45 00        CMP AX, 00045     ; sub_D5D8D
   D5DFB: 3D 46 00        CMP AX, 00046     ;   "
   ```
   **Five further compares against `0x45` exist** and were missed by the
   first pass — `D7B2E`, `DC063`, `DC08E`, `DC0B5`, `DC0EE`, all
   `3D 45 00  CMP AX, 00045` — but every one of them loads the *switch-code
   shadow* `413C:00D6` first (e.g. `DC058: MOV AL, ES:B[000D6] / CBW /
   CMP AX,00040 / JE / CMP AX,00045`), i.e. they treat `0x45` as an ordinary
   event code arriving through the F5 path, which is the opposite of a frame
   marker. There is **no** further compare against `0x46` or `0x47` anywhere.
   *Method note:* the first pass grepped the `CMP AL, imm8` encoding and so
   could not see the `CMP AX, imm16` form. Both greps in this document have
   been re-run **by operand** (`CMP <any reg-or-memory operand>, 0*4[567]`),
   which is the form that cannot miss an encoding.
3. The Z80 ROM sends all three, from named sites, over the `C0FC` channel:
   ```
   0410: 3E 47 / 32 FC C0 / CD 16 01   ; boot: send 0x47
   2E24: 3E 47 / 32 FC C0 / CD 16 01   ; command-table handler, resend 0x47
   2B6B: 3E 45 ...   2C17: 3E 45 ...   ; replies inside command handlers ED/EF
   2C09: 3E 46 ...
   ```
   `2C09`/`2C17` sit in the handler for 80188 command `0xED` (`2BEB`), which
   is literally `IN A,($04) / BIT 5,A / JP Z,$2C17` — read a cabinet input,
   reply `0x45` or `0x46`.
4. Their use on the 80188 side is a request/response pair, not a frame clock.
   `sub_D5D1B` (poll for `0x47`) is spun on **once, in the boot path**:
   ```
   D2F59: 9A FB 2D F2 D2   CALL sub_D5D1B
   D2F5E: 0A C0            OR   AL, AL
   D2F60: 74 F7            JE   0D2F59       ; wait for the Z80's "alive" byte
   ```
   `sub_D5AD1` pushes command `0xED` and then spins on `sub_D5D8D` for
   `0x45`/`0x46`, each of which draws a different string pair and returns —
   the two-option (language) prompt:
   ```
   D5AD7: 68 ED 00 / CALL qout_push        ; ask the Z80 to read the option input
   D5AE0: CALL sub_D5D8D / OR AL,AL / JE 0D5AE0
   ```
5. The PIC has no path to that latch. `asm/pic16c57_annotated.asm`: 150
   programmed words, every port bit is a raster signal, `RC7` (the only input
   pin) is never sampled, and there is no data port. Its *NO BYTE PATH TO THE
   80188* section says the same: the program "exchanges no byte with the 80188
   in either direction".

**Dequeue order, which is the part a driver gets wrong.** The NMI appends
every non-`0x32` byte to a single FIFO (`4000:1220..12E7`, far read pointer
`[1150]:[1152]`, far write pointer `[1154]:[1156]`). Every consumer —
`inbound_byte_take_a` `D5AEB`, `sub_D5B5D`, `sub_D5BCF`, `sub_D5C3E`,
`sub_D5D1B`, `sub_D5D8D`, `inbound_byte_take_b` `D5E7A`, `sub_D5F03`, the
general dispatcher `sub_D7453`, and about a dozen sibling copies —
**pops one byte unconditionally and then tests it**, discarding it if it is
not the value that consumer wants. So a byte that arrives while the firmware
is spinning in the wrong poll routine is *consumed and dropped*. That is
firmware behaviour, faithfully reproduced by simply delivering bytes; it is
not something a driver should compensate for.

**Confidence:** confirmed.

**Disposition:** hypothesis **rejected**. There is no `0x47` vsync /
`0x45`-`0x46` plane-swap marker cadence on `0xA0100`. The old driver's
"marker machine" invented those bytes and then read them back; the PinMAME
traces that appeared to confirm them were circular.

---

## F5 — Switch-code table and the shadow byte

**Statement.** Every switch event reaches the 80188 as a **one-byte code on
the J1 `C0FC` channel**, and the 80188's general dispatcher stores the byte
in **`413C:00D6` = flat `0x41496`** before acting on it.

Code map, read out of the Z80 ROM:

| source | codes | where |
|---|---|---|
| switch matrix, 6 columns x 8 rows = **48 inputs** | `0x0A-0x31` (columns 0-4, 40 routines at `316D` step 8) and `0x34-0x3B` (column 5, 8 routines at `32AD` step 8) | per-bit routines dispatched by `sw_col0_changed` `2FE7` .. `sw_col5_changed` `312C` |
| port `0x03` bits 0 / 1 / 4 | `0x3E` / `0x3F` / `0x40` | `sub_125B` / `sub_1278` / `sub_1285`, dispatched by `sub_1242` |
| port `0x03` bits 3 / 2, the **flipper buttons** | `0x41`, `0x42` | `sub_1292` `12D0` / `sub_12D8` `1340` — but only in TEST mode: both are gated on `C068`/`C069` and in play they call `sub_05C7` / `sub_05ED`, which fire the port-`0x85` coil pairs and send nothing |
| port `0x03` bit 5, the **coin mechanism** (F11), ONE code per press | `0x32` (normal) / `0x33` (test mode) | `0D3C` / `0D44`, debounced by the `C046` counter and selected by the `C068` test flag |
| direct-input scan, 16-way on port `0x87` low nibble + port `0x01` bit 5, plus the `C060` follow-up bits | `0x50-0x79` (42-byte table at `1218`) | `direct_input_scan` `0DBF` |
| command-table re-sends of matrix codes | `0x38`, `0x39`, `0x3A` (`2A90`, `2AA0`, `2AA8`), `0x3B` (`2AEB`), **`0x3C` (`2AF3`), `0x3D` (`2AFB`)** | the switch-test handlers reached by 80188 commands `0xE9`/`0xEA` |
| Z80 status/liveness replies | `0x43`, `0x44`, `0x45`, `0x46`, `0x47`, `0x48`, `0x49`, `0x4A`, `0x7A`, and `0xF0`+nibble | scattered command-table handlers |

The matrix map is exactly regular: **column c, bit b -> code `0x0A + 8c + b`
for c = 0..4, and `0x34 + b` for c = 5.**

**Evidence.**
```
sw_col0_changed 2FE7:
    3A DB C0        LD  A, ($C0DB)      ; column 0 change mask
    CB 47           BIT 0, A
    CC 6D 31        CALL Z, $316D       ; bit 0 -> the code-0x0A routine
    ... eight times, targets 316D 3175 317D 3185 318D 3195 319D 31A5 (step 8)

316D:  3E 0A / 32 FC C0 / C3 1E 16     LD A,#$0A / LD ($C0FC),A / JP sub_161E
3175:  3E 0B / 32 FC C0 / C3 4A 16
...
32A5:  3E 31 / 32 FC C0 / ...          ; last of the 40-routine run
32AD:  3E 34 / 32 FC C0 / C3 EE 14     ; column 5 bit 0
...
32E5:  3E 3B / 32 FC C0 / C3 48 13     ; column 5 bit 7
```
A programmatic sweep of the whole Z80 listing for the byte pattern
`3E nn / 32 FC C0` finds **73 sites** and no others; the 48 matrix routines
and 5 port-`0x03` routines above are 53 of them.

**Correction (2026-09-03): `0x32` does not auto-repeat while the input is held.**
The earlier row said "auto-repeating", which a driver would model as a pulse
train from one press. `sub_0D15` `0D15` does debounce port-`0x03` bit 5 for
`0x32` ticks of `C046` and then send one `0x32`, but on the way out it calls
`sub_33FA` `33FA`, which ORs the bit into **both** `C0F8` and `C0E3`:

```
sub_33FA:  HL=C0F8 / OR (HL) / LD (HL),A     ; the mask
           HL=C0E3 / OR (HL) / LD (HL),A     ; the debounced shadow
input_port03_read 2E54:  A = IN($03) / (C0F7) = ~A / A |= (C0F8) / (C0E3) = A
sub_3335 3371:           A = (C0F7) / (C0F8) &= A     ; mask cleared on RELEASE
```

so a still-held button reads as released and no second code follows; the mask
clears only when the contact physically opens. **One press, one code** —
measured directly in emulation on 2026-09-03: the coin input held for 400
frames produced exactly one `0x32` on J1. What one pulse is *worth* is the F11
pricing table's business, not the Z80's.

The 80188 side, `sub_D7453` — the general dequeue-and-shadow routine:
```
D745E: 26 A0 47 11        MOV AL, ES:B[01147]   ; anything pending?
D7471: 26 80 3E 44 11 00  CMP ES:01144, 000     ; the 0x32 tick counter first
D749C: 26 C4 1E 50 11     LES BX, ES:01150      ; FIFO read pointer
D74A1: 26 8A 07           MOV AL, ES:B[BX]
D74A9: 26 A2 D6 00        MOV ES:B[000D6], AL   ; ES = 413C -> flat 0x41496
```
and consumers of the shadow, e.g.
```
D7ACF: 26 A0 D6 00        MOV AL, ES:B[000D6]
D7AD5: 3D 3F 00           CMP AX, 0003F
D7AD8: 74 0C              JE  0D7AE6            ; -> service menu, see F14
D7ADA: 3D 40 00           CMP AX, 00040
D7ADD: 75 32              JNE 0D7B11
D7ADF: 9A C6 0D 2A D7     CALL sub_D8066
```
`413C:00D6` is loaded at 21 sites (`MOV reg, ES:B[000D6]`), compared in
place at 12 more (`CMP ES:000D6, imm`), and **written at 10**:

| site | write |
|---|---|
| `D73F3`, `D7419`, `D7443` | `MOV ES:000D6, DL` — the direct-input range handlers |
| `D74A9`, `D75DF` | `MOV ES:B[000D6], AL` — the general FIFO dequeue (`sub_D7453`) |
| `DAF0C`, `DB1B4`, `DB298`, `DB2BA` | `MOV ES:000D6, 032` — **game code self-injects code `0x32`** |
| `DBCAC` | `MOV ES:000D6, 000` — clears the shadow |

The four immediate stores of `0x32` matter for a driver: the shadow can hold
a switch code that **never came over J1**, so a test that asserts
"shadow value implies an inbound byte" is wrong. *Method note:* the first
pass matched `MOV ES:...,(AL|DL)` — a register-source pattern — and so
missed every immediate store. Re-run by operand
(`MOV ES:(B\[)?000D6\]?, <anything>`).

**`0x45` is also an ordinary event code.** Besides being the reply to
command `0xED` (F4), `0x45` is tested against this shadow at `D7B2E`,
`DC063`, `DC08E`, `DC0B5` and `DC0EE`. A driver must deliver it through the
normal J1 path like any other code and must not treat it as reserved.

**Confidence:** confirmed. The *physical* switch behind each code is
established for **four** of the 48 matrix positions and no more: column 0 bits
0-3, codes `0x0A`-`0x0D`, are the ball-handling contacts, and **F15** carries
that evidence — including the fact that code `0x0A`'s contact reports `0x43`
(ball over) instead of its own code. The other 44 need the wiring diagram or
the service manual's switch list; the codes and their matrix positions are
exact for all 48.
The six **cabinet** codes were identified on 2026-09-03 from what consumes
them (F11, F14): `0x32` the coin mechanism, `0x3E` tilt, `0x3F` test /
service-menu, `0x40` START, `0x41`/`0x42` the flipper buttons.

**The IN-port list is confirmed complete from the hardware.** Sheet
`011-030-02` shows IC16, the 74LS138 that decodes the Z80's input ports,
enabled by `A7` low and by IC8's `/CEI` (an I/O-read decode, from the bench
read at [`../../roms/PAL16L8/`](../../roms/PAL16L8/)), with only `Y0`-`Y4`
wired, as `I0`-`I4`. Five input ports are all the board has, so `0x00`-`0x04`
is not merely all this ROM uses — it is all there is.

**Disposition:** hypothesis **confirmed**. `0x41496` is right, and is now
pinned to its symbolic form `413C:00D6` with the routine that writes it. Note
this is a *firmware RAM variable*, not a hardware mailbox — the driver must
not write it; it must deliver the byte through J1 and let `sub_D7453` fill it.

---

## F6 — The J1 byte port, both directions

**Statement.** J1 is an 8-bit bidirectional byte port with handshakes and
**no address bus, no shared memory, no HOLD/HLDA**. Each direction is a
latch plus an interrupt.

**Z80 -> 80188.** The Z80 has two outbound channels sharing the data port:

| channel | payload | routine | strobe |
|---|---|---|---|
| `C0FC` | one-byte **event code** (F5) | `host_send_c0fc` `0116` | port-`0x81` **bit 2** |
| `C008` | an 8-bit **state bitmask**, bits set/cleared individually | `host_send_c008_a` `0144`, `_b` `017E` | port-`0x81` **bit 5** (with 3 `NOP`s of width) |

```
host_send_c0fc 0116:
    DB 01 / CB 4F / 28 FA     IN A,($01) / BIT 1,A / JR Z,self   ; spin: bus free
    F3                        DI
    3A 01 C0 / F6 02 / D3 81  (C001) |= 0x02, OUT ($81)          ; data-valid
    3A FC C0 / D3 80          A = (C0FC), OUT ($80)              ; the byte
    3A 01 C0 / F6 04 / D3 81  (C001) |= 0x04, OUT ($81)          ; strobe bit 2
    3A 01 C0 / E6 FB / ...    clear bit 2 again
```

The 80188 sees the byte as an **NMI**, and reads it at PCS2 `0xA0100`
(F4). Around the read the NMI asserts PCS4 `0xA0200` bits 7, 6 and 4
(`OR AL,0D0`) and leaves bit 7 asserted afterwards (`OR AL,080`), without
updating the shadow. Bit 7 is dropped again by `pcs4_clear_bit7` `D0331`,
which the timer-0 ISR calls when the counter `[4000:1140]` — reloaded to
`0x10` by every NMI — reaches zero, i.e. **16 timer ticks ~ 161 ms after the
last inbound byte**.

**80188 -> Z80.** An outbound FIFO in work RAM, drained by the INT0 ISR:

```
qout_push        D0138   append a byte to 4000:1158, advance [114E]
qout_service_pcs1 D01E5  called from the INT0 ISR:
    D01E5: 80 3E 45 11 00 / 74 05 / FE 0E 45 11 / C3   ; [1145] 3->0: 1 byte per 4 calls
    D01F6: 8B 36 4C 11 / 8A 04 / 22 C0 / 75 01 / C3    ; head byte, 0 = queue empty
    D0206: 26 F6 06 80 01 01   TEST ES:00180, 001      ; PCS3 bit 0 = receiver ready
    D020C: 75 01 / C3                                   ;   not ready -> give up
    D020F: 26 A2 80 00        MOV ES:B[00080], AL       ; PCS1 = the byte
    D0216: 0C 40 / 26 A2 00 02  PCS4 |= 0x40            ; strobe bit 6
    D022A: 0C 20 / ...          PCS4 |= 0x20            ; strobe bit 5
    D0233: 13x NOP
    D0243: 24 DF / 24 BF / ...  PCS4 &= ~0x20 & ~0x40   ; strobes released
```
Because the ISR calls it on alternate INT0s and it acts on one call in four,
the outbound byte rate is **INT0 / 8**.

On the Z80 that strobe is an **NMI**:
```
0066: 08 / D9                  EX AF,AF' / EXX
0068: 2A 74 C0                 LD HL, ($C074)          ; ring write pointer
0080: 3A 01 C0 / E6 FE / F6 10 / 32 01 C0 / D3 81      ; port-81 bit 4 on, bit 0 off
008C: DB 00                    IN A, ($00)             ; the byte
008E: 77 / 23 / 36 00          store, advance, terminate
0092: 3A 01 C0 / E6 EF / F6 01 / 32 01 C0 / D3 81      ; bit 4 off again
009E: 21 45 C0 / 36 30         LD (C045), #$30
00A3: D9 / 08 / ED 45          EXX / EX AF,AF' / RETN
```
The byte lands in a ring at `$C076` (read pointer `$C072`, write pointer
`$C074`) and is consumed by `host_cmd_dispatch` `16D5`, which indexes the
**256-entry word table at `$2000`** and `JP (HL)`s. There is also a *polled*
inbound path, `host_read_byte` `01B6`, gated by port-`0x81` **bit 6** instead
of bit 4, used only by `direct_input_scan`.

**Port `0x81` bit map (complete; every one of the 22 `OUT ($81),A` sites was
inspected).**

| bit | meaning |
|---|---|
| 0 | set with bit 1 on the `C008` sends (`0153: F6 03  OR A,#$03`); cleared on the polled read (`01C2: E6 FE`), by the NMI while it raises bit 4 (`0080: E6 FE / F6 10`), and by `port81_bit3_toggle` on its bit-3-clear path (`0CA8: CB 87  RES 0,A`). Role not proven |
| 1 | data-valid, set before the port-`0x80` write and cleared after |
| 2 | strobe for the `C0FC` event-code channel |
| 3 | periodic square wave — `port81_bit3_toggle` `0C97` flips it (`RES 3,A` `CB 9F` at `0CA6`, `SET 3,A` `CB DF` at `0CB0`) every 16 ticks of the `C045` counter, each time immediately before `OUT ($81),A`. See the F3 INT0 discussion. |
| 4 | inbound gate for the NMI's `IN A,($00)` |
| 5 | strobe for the `C008` state channel |
| 6 | inbound gate for the polled `IN A,($00)` at `01D6` |
| 7 | never manipulated anywhere in the ROM |

**Port `0x01` bit 1 is a bus-free/ready line in *both* directions** — it is
the spin condition of all three `host_send_*` routines *and* of the inbound
`host_read_byte` (`01B6-01BA`).

**Boot handshake, which gates everything.** The Z80 sends `0x47` at `0410`,
and the 80188's `main_entry` spins at `D2F59` until it arrives (F4 evidence
item 4). A driver that does not deliver `0x47` never leaves boot.

**Confidence:** confirmed for both directions, the strobes, the gates and the
handshake. **Inferred/unresolved:** which physical line PCS4 bits 5/6/7 and
PCS3 bit 0 correspond to on J1, and whether the two Z80 outbound strobes reach
the *same* 80188 latch. IC7 is dumped and does not answer the first: its only
PCS4 involvement is `/OOE` = `/PCS4` · `/WR`, the write strobe for the block,
which says when the byte is latched and nothing about where each bit goes.
On the latter, the balance of evidence says yes: `0xA0100` is the only inbound read in the whole 80188 ROM,
so if the bit-5 channel went anywhere else nothing would ever read it — and
`inbound_byte_take_b` `D5E7A` accepts exactly the value range the `C008`
bitmask produces (`0x50-0x64`, plus `0x7A`).

**Disposition:** hypothesis **confirmed and completed**. Port `0x80` data +
port `0x81` bits is right; the reverse path (previously "un-traced") is now
fully traced: `qout_push` -> `qout_service_pcs1` -> PCS1 `0xA0080` + PCS4
strobe -> Z80 NMI -> `IN ($00)` -> ring at `$C076` -> 256-entry table at `$2000`.

---

## F7 — Lamps and drivers (the 80188 -> Z80 command map)

**Statement.** All lamp and driver output is commanded by the 80188 as
**single command bytes** through the F6 outbound path, decoded by the Z80's
256-entry table at `$2000`. Of the 256 entries, 230 are live and 26 point at
the no-op at `$2200`.

**Lamps: 8 columns x 8 bits = 64, with a two-bank blink model.**

```
C0FF..C106   bank 1  ("lit")
C107..C10E   bank 2  ("steady")
C10F..C116   the bytes actually written to port 0x84
```
`sub_353A` `353A` alternates the output every time `C120` counts down from
`0x4B` (75) ticks of `lamp_scan_tick`:
```
3594:  phase A:  LDIR  C0FF..C106 -> C10F..C116          (bank 1 verbatim)
3553:  phase B:  LD A,(BC) / AND (HL) / LD (DE),A ...    (bank 1 AND bank 2)
```
so bank1=1 and bank2=1 is steady on, bank1=1 and bank2=0 blinks, bank1=0 is
off. One column is emitted per IRQ:
```
lamp_col0_out 3457:  LD A,($C10F) / OUT ($84),A / LD A,#$01 / OUT ($83),A
lamp_col1_out 3467:  ... ($C110) ... #$02 ...      (through lamp_col7_out 34C7, #$80)
```
Command bytes `0x01-0xA4` are exactly these bank bit operations, e.g.
```
2201 (cmd 01):  LD HL,#$C10B / RES 7,(HL) / LD HL,#$C103 / SET 7,(HL)
220C (cmd 02):  LD HL,#$C10B / SET 7,(HL) / LD HL,#$C103 / RES 7,(HL)
22C7 (cmd 17):  LD HL,#$C101 / SET 0,(HL)
22CD (cmd 18):  LD HL,#$C109 / SET 0,(HL) / LD HL,#$C101 / RES 0,(HL)
```
The full byte -> (bank, index, bit, set/res) map is mechanically recoverable
from the table and the handlers; the extraction is ~30 lines of Python over
`iomoon_z80.lst` plus `V1 3_05.bin` `0x2000-0x21FF`, and produces a complete
230-row listing.

**Drivers: two 8-bit latches, active LOW, individually timed.**
`boot_port_init` `041B` writes `0xFF` to both ports at reset:
```
0422: 3E FF / 32 05 C0 / D3 85     port 0x85 <- 0xFF   (shadow C005)
0429:         32 06 C0 / D3 86     port 0x86 <- 0xFF   (shadow C006)
```
so `1` = off and clearing a bit fires the driver. Port `0x86` uses all eight
bits independently (`AND #$FE .. #$7F` to fire at `0706`-`07D1`, `OR #$01 ..
#$80` to release at `081B`-`0892`, plus a timed auto-release path at
`0ADA`-`0C51` inside the IRQ handler). Port `0x85` is mixed: bits 0/1, 2/3
and 4/5 are driven as **complementary pairs** (`OR #$02 / AND #$FE` at
`05D7` vs `OR #$01 / AND #$FD` at `0623`, and so on), with bits 6 and 7
individual. So the machine has **16 driver bits = 8 independent drivers on
port `0x86` + 3 complementary pairs + 2 singles on port `0x85` = 13
addressable devices.**

Command bytes `0xCB-0xE7` call into that driver family (`2895 -> sub_05C7`,
`28D7 -> sub_05ED`, `2919 -> sub_0613`, ...), several of them arming a
duration in `C04F`/`C051` first.

Commands `0xAD-0xB7` load one of sixteen data blocks in `38CC-4FD4`
(`35EA: LD HL,#$39AE`, `3605: LD HL,#$38CC`, ... `36F8: LD HL,#$4B68`) into
the lamp-sequence player at `C11A`/`C11B`/`C11E` — canned lamp animations.
Commands `0xF7`/`0xF8` enter and leave test mode (`2DC4` sets `C068`;
`2DD9` clears it and `JP boot`, rebooting the Z80).

**The OUT-port list is confirmed complete from the hardware.** Sheet
`011-030-02` shows IC17, the 74LS138 that decodes the Z80's output ports,
enabled by `A7` high and by IC8's `/CEO` (an I/O-write decode, from the bench
read at [`../../roms/PAL16L8/`](../../roms/PAL16L8/)), with all eight outputs
wired as `O0`-`O7`. Eight output ports are all the board has, so `0x80`-`0x87`
is the whole OUT space and no ninth strobe exists.

**Confidence:** confirmed.

**Disposition:** hypothesis **corrected**. Ports `0x82-0x87` are indeed
lamp/solenoid/switch-scan and not sound — but the assignment inside that
range in the old driver is wrong: `0x82` is the **switch** column strobe,
`0x83` is the **lamp** column strobe and `0x84` the lamp data. See the audit.
Also: "64 lamps" is confirmed exactly; "18 solenoids" is **not** — the
hardware is 16 driver bits.

---

## F8 — YM3812 (FM music)

**Statement.** The YM3812 is at **PCS5**, with the index port at `0xA0280`
and the data port at `0xA0281` — two distinct addresses, **not** an A0 toggle
on one address (that is the Bike Race style, and IO Moon does not use it).

```
ym3812_write D0D99:
    D0D99: 26 88 26 80 02   MOV ES:00280, AH      ; register index
    D0D9E: E8 08 00         CALL ym3812_settle_delay
    D0DA1: 26 A2 81 02      MOV ES:B[00281], AL   ; value
    D0DA5: E8 01 00         CALL ym3812_settle_delay
ym3812_settle_delay D0DA9:  MOV AL,00A / DEC AL / AND AL,AL / JNE   ; 10 iterations
```
These are the only two accesses to `0xA0280`/`0xA0281` in the whole ROM.

**Sequencer.** `fm_sequencer_step` `D0D37` walks a `CS:`-relative byte stream
through the pointer `[4000:12EA]`, reading `(AH, AL)` pairs:

| control byte (`AH`) | meaning |
|---|---|
| `0xEE` | duration: `[12EC] = AL * [12EF]` (tempo), then return |
| `0xEF` | set tempo: `[12EF] = AL` |
| `0xFF` | end: `[12EE] = 0`, `[12EC] = 0` |
| `0xDD` | jump: new stream offset from the next byte |
| anything else | `ym3812_write(AH = register, AL = value)` |

**Song select.** `fm_song_select` `D0DB4` takes a song index, doubles it and
adds `0x0DE5`:
```
D0DCA: D1 E6            SHL SI, 1
D0DCC: 81 C6 E5 0D      ADD SI, 00DE5
D0DD0: 2E 8B 04         MOV AX, CS:W[SI]     ; stream start offset
D0DD3: A3 EA 12         MOV [012EA], AX
D0DDC: C6 06 EE 12 FF   MOV [012EE], 0FF     ; player enabled
```
The table at `D0DE5` holds **10** word pointers —
`0DF9, 0E32, 1662, 2106, 2769, 22A8, 25E9, 26A9, 29FA, 2C8E` — and song 0's
stream begins immediately after it at `0DF9` with `EF 01` (tempo 1) followed
by register writes `43 3F`, `44 3F`, `45 3F`, `4B 3F`, ... `A0 00`, `B0 00`,
... `FF` — i.e. an OPL2 all-notes-off preamble. `fm_song_select` is called
from **24** sites.

**Tick source and rate.** `fm_player_tick` `D0D1B` is called from the INT0
ISR at `D038D`, in the odd branch only, so its rate is **INT0 / 2** — see F3
for why INT0's absolute rate is not yet settled. `fm_player_tick` returns
immediately unless `[12EE]` is set, then counts `[12EC]` down and calls the
sequencer when it reaches zero.

**Confidence:** confirmed for the ports, primitive, opcodes, song table and
call graph; the absolute tempo is **inferred** and inherits F3's open INT0
rate.

**Disposition:** hypothesis **confirmed**. Separate index/data addresses, not
A0-toggling. The earlier "YM3812 is silent / BOM-only" claim stays withdrawn.

---

## F9 — OKI MSM6376 (speech / effects)

**Statement.** Control latch at **PCS6 `0xA0300`**, strobed by pulsing
**PCS0 `0xA0000` bit 5 low then high**. Two channels, driven from the timer-0
ISR, with a software command dispatcher in front of them.

**The strobe.**
```
okcs_strobe D0CE2:
    D0CE2: A0 34 11 / 24 DF / A2 34 11   shadow [1134] &= ~0x20
    D0CEA: 26 A2 00 00                   MOV ES:B[00000], AL      ; /OKCS low
    D0CEE: 90                            NOP
    D0CEF: A0 34 11 / 0C 20 / A2 34 11   shadow |= 0x20
    D0CF7: 26 A2 00 00                   MOV ES:B[00000], AL      ; /OKCS high
```
Boot leaves PCS0 at `0x28` (`D00CA: B0 28 / D00CC: MOV ES:B[00000],AL`), i.e.
bit 5 idle **high**, and PCS6 at `0x80` (`D00C4: B0 80 / D00C6`).

**Trigger sequences.**
```
oki_trigger_a D0C57(AL = sample):     oki_trigger_b D0C84(AL = sample):
  [12FC] = AL                           [12FF] = AL
  A0300 <- AL | 0x80                    A0300 <- AL & 0x7F
  [12FD] = CS:W[0C1F + 2*(n-1)]         [1300] = CS:W[0C1F + 2*(n-1)]
  okcs_strobe                           okcs_strobe
  [1304] |= 0xF0                        A0300 <- AL | 0x80   (no second strobe)
                                        [1304] |= 0x0F
```
`sub_D0CB8` is the silence/reset path: `A0300 <- 0`, PCS0 bit 5 cleared and
left low, both duration counters set to 1.

**Command dispatcher** `sub_D0B70` (**81 call sites** — this is *the* sound
entry point for game code):
- `[1302] != 0` -> a deferred sample is already pending, drop this one.
- command `0x00` -> pick the next of six sample numbers from the table at
  `CS:0C19` (`29 31 2A 24 2D 3E`), cycling through `[1305]` 0..5.
- **bit 7 set** = high priority: if either channel is busy (`[12FC]`/`[12FF]`
  bit 7) or both durations are running, park the sample in `[12F9]` and set
  `[1302] = 0xFF`; the timer-0 ISR starts it when a channel frees
  (`D0284`-`D02C4`).
- **bit 7 clear** = fire-and-forget: start on channel A if `[12FD]` is 0,
  channel B if `[1300]` is 0, otherwise drop it.

So **bit 7 of the command byte is a priority/queue flag, and bits 0-6 are the
sample number**; the byte written to the latch has bit 7 as the channel
sequencing bit.

**Busy handling** is entirely software: the durations `[12FD]`/`[1300]` count
down in the timer-0 ISR (`D0299`, `D02CC`); no OKI busy pin is read anywhere.

**One anomaly, recorded rather than resolved:** the duration index
`0x0C1F + 2*(n-1)` stays inside the data block `D0C19-D0C56` only for
n <= 28, yet the `CS:0C19` random list contains sample numbers up to `0x3E`
(62), whose index would read bytes of `oki_trigger_a`'s own code as a
duration. Either the duration table is larger than the block boundary this
baseline drew, or the firmware tolerates a garbage countdown for high sample
numbers. The driver is unaffected (the value only paces re-triggering).

**Confidence:** confirmed for the addresses, strobe, sequences and
dispatcher. The **bit-level meaning of the latch byte at the OKI's pins**
is inferred, and IC7 — now dumped
([`../../roms/PAL20L10/`](../../roms/PAL20L10/)) — cannot settle it: the PAL
supplies only `/OKCS` = `/PCS6` · `/WR`, the clock that latches the byte into
IC50. The byte itself travels `D0`-`D7` through IC50 to the MSM6376, so this
one wants a scope or a continuity trace of IC50's outputs.

**Disposition:** hypothesis **confirmed** (`0xA0300` latch, `0xA0000` bit 5
strobe, routines `D000:0C57`/`0C84`, table `CS:0C1F`), and completed with the
byte format, the priority bit and the software busy model.

---

## F10 — Non-volatile store

**Statement.** The non-volatile store is a **separate memory window at
segment `5040`** (flat `0x50400+`), inside MMCS block 1, and it is
**gated by PCS0 bits 3 and 4**, which are a complementary pair:

```
pcs0_window_open  D057E:   CLI / shadow[1134] &= ~0x08 | 0x10 / A0000 <- shadow / STI
pcs0_window_close D059F:   CLI / shadow[1134] &= ~0x10 | 0x08 / A0000 <- shadow / STI
```
Every access is bracketed by that pair, and the accessors are byte- and
dword-wide far calls:

| routine | width |
|---|---|
| `nvstore_read_byte_far` `D04BF` / `nvstore_write_byte_far` `D04A9` | 8 bit |
| `nvstore_read_dword_far` `D0492` / `nvstore_write_dword_far` `D046D` | 32 bit |
| `nvstore_write_triple_83` `D04D2` / `_84` `D04F3`, `nvstore_check_triple_83` `D0514` / `_84` `D0549` | triplicated byte at `0083`/`0116`/`020C` and `0084`/`0117`/`020D`, with a majority compare that zeroes all three on mismatch |

**Offsets actually used** (from the immediates pushed at the 279 accessor
call sites): bytes `0x3C-0x42`, `0x83`, `0x84`, `0x89-0x95`, `0x116`,
`0x117`, `0x1BF-0x1CF`, `0x20C`, `0x20D`, `0x21F`, `0x244`, `0x269`, `0x2B9`,
`0x2CD`, `0x31D`; dwords `0x43`, `0x85`/`0x96`/`0xA7`/`0xB8`/`0xC9` (stride
0x11), `0x118`-`0x12C` (stride 4), `0x16C`-`0x17C` (stride 4), `0x20E`,
`0x233`, `0x258`. **Highest offset touched: `0x31D`** — under 800 bytes in
use.

Two identifications the code makes unambiguous:
- **Signature check.** `sub_D05C0` compares `5040:0000-000E` against the
  15-byte prefix of the copyright block at `CS:07A9`, then `5040:0047`
  against `CS:07B8` for `0x33` bytes; on mismatch it returns 0 and
  `sub_D622C` rewrites the factory defaults.
- **High-score table.** `sub_D622C` writes dword `0x02FAF080` = **50 000 000**
  to `0x0085` and `0x05F5E100` = **100 000 000** to `0x0096`, then copies 13
  name bytes to `0x0089+i`. Five 17-byte records at `0x85`, `0x96`, `0xA7`,
  `0xB8`, `0xC9`.

**Confirmed from the hardware side.** The IC7 PAL dump
([`../../roms/PAL20L10/`](../../roms/PAL20L10/)) contains the gate as an
equation: `/EECE` = `/MCS1` · `A15`=0 · `EEE1`=0 · `EEE2`=1, where `EEE1` and
`EEE2` are two bits of the PCS0 control byte latched in IC40. The store is
chip-enabled only while those two bits hold *opposite* values, which is
exactly what `pcs0_window_open` writes (clear bit 3, set bit 4) and
`pcs0_window_close` undoes — so `EEE1` = PCS0 bit 3, `EEE2` = PCS0 bit 4, and
the complementary pair is a genuine two-bit interlock in silicon rather than
one gate bit plus a spare. `A15`=0 also places the window in the lower half of
the MCS1 block, agreeing with segment `5040`. This is an independent
confirmation: the firmware and the PAL were read from different artefacts.

**Confidence:** confirmed for the window, the gating bits, the access widths
and the offsets in use. **Inferred:** that the device is the 28C64A. Nothing
in the ROM names a part, and only the low ~800 bytes of the window are ever
touched, so an 8 KiB part is consistent but not proven; a driver should back
the whole window and save it.

**Disposition:** hypothesis **corrected in location**. The store is at
segment `5040` behind a chip-select gate, not at any address the old driver
mapped (which put `generic_nvram` at `0x10100-0x10900`, an address the
firmware never touches). The 8 KiB size is plausible and unrefuted.

---

## F11 — Credits, coin and audit entry points

**Statement.** Coins and credits are ordinary switch codes (F5) handled by
game code; the persistent counters live in the F10 store. The entry points a
regression test needs:

| what | where |
|---|---|
| **adjustment editor** — 25 items, dispatched on `413C:015A - 7` through the jump table at `CS:1BDE` | `sub_DE736` `DE736` |
| a byte adjustment with wrap: read NVRAM `0x3C`, `CMP AL,009 / JL` -> +1 else reset to 1 | `DE774`-`DE7E8` |
| a score adjustment with cap: read NVRAM dword `0x43`, add `0xC350` (50 000), cap at `0x7A120` (500 000) then wrap to `0xC350` | `DE7F7`-`DE84F` |
| **games-played audit**: read NVRAM dword `0x118`, `ADD AX,1 / ADC DX,0`, write back — the same routine sets the mode byte `413C:014F = 3` (game start) and fires two sounds | `sub_D8154` `D8154` |
| other audit dwords incremented the same way | `0x118` at `D4D93`/`D4E08`/`D4E92`/`D4F46`/`DE497`, `0x11C` at `D366D`/`D3683`/`DE4B6` |
| factory defaults / NVRAM reinit (high scores, all adjustments) | `sub_D622C` `D622C` |
| persisted boot-fault code | NVRAM byte `0x31D`, written by `sub_E0D23` `E0D23`, cleared at `D2FBB` |

```
sub_D8154 D8154:
    D815F: 26 C6 06 4F 01 03    MOV ES:0014F, 003        ; mode = in game
    D8165: 68 40 50 / 68 18 01 / CALL nvstore_read_dword_far
    D8173: 05 01 00 / 83 D2 00  ADD AX,1 / ADC DX,0
    D817B: ... CALL nvstore_write_dword_far
    D818E: 68 81 00 / CALL sub_D0B70                     ; sound 0x81
    D8197: 68 8F 00 / CALL sub_D0B70                     ; sound 0x8F
    D81A5: 68 C3 00 / CALL qout_push                     ; Z80 command 0xC3
    D81AE: 68 AB 00 / CALL qout_push                     ; Z80 command 0xAB
```

### The credit balance and the coin path (added 2026-09-03, Task 16)

**The credit balance is the F10 triplicated NVRAM byte `0x83`/`0x116`/`0x20C`,
with a sub-credit remainder in `0x84`/`0x117`/`0x20D`, and `413C:00D4` is a
volatile CACHE of their sum.** The gap this fact recorded is closed. It was
not found through the `413C:00D6` dispatch, because the coin does not go
through it: the coin code is `0x32`, and `0x32` is the one code the NMI does
not queue.

```
isr_type02_nmi D016D:
    D018C: 26 A0 00 01        MOV AL, ES:B[00100]   ; the PCS2 inbound latch
    D0190: 3C 32              CMP AL, 032
    D0192: 75 07              JNE 0D019B            ; anything else -> the FIFO
    D0194: FE 06 44 11        INC 01144             ; 0x32 -> the coin PULSE counter
```

The chain from there, every step confirmed:

| step | where |
|---|---|
| pulse counter `4000:1144`, incremented by the NMI, tested first by every dequeue routine (`D7471`, `D751D`, `D7C50`, `D7DDD`, `D7F77`) | `D0194` |
| `[1144]` folded into the pulse accumulator `413C:00D5`, then `[1144]` cleared, then the per-country pricing routine called — `sub_DCD9E` if the country byte `4000:1001` is 5, else `sub_DD03D` | `sub_D800A` `D800A` |
| pricing: divide the accumulated pulses by each coin value in turn (`413C:00AF`, then `00AE`, then `00AD` — and `00B0` on the country-5 path), multiply by that coin's credit value (`00AB`, `00AA`, `00A9`; `00AC` on the country-5 path), keep the remainder in `00D5` | `sub_DD03D` `DD03D` / `sub_DCD9E` `DCD9E` |
| bank it: add to the sub-credit byte `0x84`, play OKI sound `0x0A`, and when `0x84` reaches the threshold add it into the credit byte `0x83`, zero `0x84` and refresh `00D4` | `sub_DD1C1` `DD1C1` / `sub_DCFAB` `DCFAB` |
| the pricing table itself, loaded at boot from NVRAM `0x1C4`-`0x1CF` into `413C:00A5`-`00B0` | `sub_D6A36` `D6A36`, saved back by `sub_D6BAE` `D6BAE` |

`00D4` is only ever a cache, and the firmware keeps it as **`0x83 + 0x84` mod
256**: on boot `sub_D66AB` consolidates `0x83 += 0x84`, zeroes `0x84` and sets
`00D4 = 0x83` (`D66CE`); the credit refresh `sub_DCD29` recomputes
`00D4 = 0x83 + 0x84` and splits it into the display digits `00D2`/`00D3`; and
`sub_D8066`'s start path decrements `0x83` alone (`D80D6`) and then re-adds
`0x84` (`D80EB`). Decrementing a zero `0x83` to `0xFF` is therefore correct
and not an underflow — with `0x84 = 3` the pair still reads 2. A driver must
persist **all six bytes**: the F10 majority compare zeroes all three copies on
mismatch, so persisting one of a triple loses the balance at the next boot.

Other credit writers, all reaching the same triple: `sub_D4FDC` `D4FDC`
(award n credits, also bumps audit dword `0x12C`), the replay-score check
`sub_D34F4` `D34F4` (`D3658 INC 00D4` then `nvstore_write_triple_83`), the
match award reached from `sub_D4CF4` `D4CF4`, `sub_D81B9` `D81B9` (`D821C`),
and the fault handlers `sub_DA7EB`/`sub_DA879` which add the player count back.
The 99 cap is `sub_DCD29`'s `DCD34: CMP ES:000D4, 063`.

**The country byte drives all of it, and it is a DIP switch.** `4000:1001` is
read from NVRAM `0x1BF` at `D2F3B`, but `boot_init` re-derives it from the
hardware on every boot and lets the hardware win: `sub_D5A8B` `D5A8B` pushes
Z80 command `0xF9`, the Z80's handler `2D9D` answers `IN A,($04) | 0xF0`, and
`D5CA3`-`D5CC2` turns bits 1-3 of that byte into a country number 0..7
(`AND 0x0E / SUB 2`, seven-way table at `D5D01`) in `[4130:0020]`; `D664D`
compares it with the stored value and on a difference rewrites NVRAM `0x1BF`
and re-runs `sub_D69CC`, which applies that country's coin preset (one of
eight, `D6D36`, `D6DDF` … `D7204`) and saves it to `0x1C4`-`0x1CF`. The
service manual's SW40 table (section 7.2.2.3) has SW2-SW4 as the country code
with per-country coin values, and country 5 also selects the Spanish string and
menu-record tables (`D3277`, `D8048`, `DD406`), so this single DIP sets the
coinage **and** the language.

**Which switch is the low bit** is settled by the presets, and *not* by the two
obvious anchors. Country 0 = the manual's UK row and country 5 = its Spain row
are both **invariant** under swapping SW2 and SW4 (`000` and `101` are
palindromes), and so is Germany (`010`); none of the three discriminates. The
rows that do are Italy, Netherlands, France and Belgium. Reading every preset
out of the emulator one country at a time, with **SW2 as the low bit and
ON = 0**:

| value | divisors (pulses) | credits | manual row | verdict |
|---|---|---|---|---|
| 0 | 3 / 5 / 10 | 1 / 2 / 5 | United Kingdom | exact |
| 1 | 2 / 5 / 10 | 1 / 3 / 7 | France | **does not match** (manual 3/5/10, 1/2/5) |
| 2 | 1 / 2 / 5 | 1 / 3 / 8 | Germany | exact |
| 3 | 1 / 2 / 4 | 1 / 3 / 7 | Italy | exact |
| 4 | 2 / 5 / 10 | 1 / 3 / 7 | Netherlands | exact |
| 5 | 2 / 4 / 8 / 20 | 1 / 3 / 7 / 18 | Spain | coins exact, 3rd credit 7 vs 8 |
| 6 | 2 / 4 / 10 | 1 / 3 / 8 | Belgium | **does not match** (manual 2/5/10, 1/3/7) |
| 7 | 1 / 2 / 4 | 1 / 3 / 6 | Portugal | coins exact, 3rd credit 6 vs 7 |

Six of the eight rows match. Swap SW2 and SW4 and three of the four
discriminating rows break — value 3 would have to be Belgium (manual 2/5/10
against the ROM's 1/2/4), value 4 France (3/5/10 against 2/5/10) and value 6
Italy (1/2/4 against 2/4/10) — buying only Netherlands at value 1. That is the
evidence for the bit order; the UK and Spain anchors are consistent with it but
cannot establish it.

So the ROM and the manual disagree in **four** places, not two: values 1 and 6
carry coin values that are not the manual's at all (value 1 is a byte-for-byte
duplicate of value 4's Netherlands preset), and values 5 and 7 differ by one
credit on their largest coin. The ROM is what runs.

**Confidence:** confirmed for the listed entry points and their arithmetic,
for the credit-balance cell and the whole coin path, and for the country
switch. Verified in emulation on 2026-09-03: eight coin presses award 12
credits under country 7, the balance survives a power cycle through the
NVRAM triple, START takes one and moves the mode 2 → 3, and no unprompted
credit appears in a 6000-frame idle soak.

**Disposition:** no prior hypothesis existed to adjudicate. For the
credit-runaway regression, `sub_D8154` (games played) and `sub_DE736`
(adjustments) are the observable hooks; a runaway will show as unbounded
growth of NVRAM `0x118`/`0x11C`. **For a driver, the one thing that must be
right is that the coin button produces code `0x32` and not `0x3E`:** `0x3E`
is the tilt contact (`sub_D9EBB`, warning counter `[4134:0033]` reloaded from
NVRAM `0x42` at every ball start, `DBE17`/`DBF7F`), and a driver that puts the
coin there never awards a credit at all.

---

## F12 — Sound-command flow

**Statement.** **The Z80 forwards no sound commands, and neither queue in
work RAM is a sound queue.** Sound is called directly by 80188 game code:

```
game code  --(word arg)-->  sub_D0B70  D0B70   OKI dispatcher      (81 call sites)
game code  --(word arg)-->  fm_song_select D0DB4  YM3812 song      (24 call sites)
```
Neither takes its argument from a queue: both are far-called with an
immediate or a computed byte on the stack (e.g. `D818E: 68 81 00 / CALL
0D000:00B70`).

The two byte queues in work RAM are both **inter-CPU**, not sound:

| queue | direction | pointers | who drains it |
|---|---|---|---|
| `4000:1158` | **outbound to the Z80** | `[114C]` read, `[114E]` write | `qout_service_pcs1` `D01E5`, from the INT0 ISR, to PCS1 `0xA0080` |
| `4000:1220..12E7` | **inbound from the Z80** | far `[1150]:[1152]` read, far `[1154]:[1156]` write | the NMI appends; ~12 poll routines and `sub_D7453` drain |

The outbound queue's payload is proven to be Z80 command bytes by the
handshake at `D2F96`: the 80188 pushes `0xC0`, and Z80 table entry `0xC0` is
`$11F5`, the direct-input self-scan, which replies `0x7A` — exactly the byte
the 80188 then waits for.
```
D2F96: 68 C0 00 / CALL qout_push
D2F9F: CALL inbound_byte_take_b / OR AL,AL / JE 0D2F9F
D2FA8: 80 3E 06 00 7A   CMP 00006, 07A          ; 0x7A = all direct inputs clear
D2FAD: 74 0C            JE  0D2FBB              ;   -> clear NVRAM 0x31D
D2FAF: CALL sub_D5468 / CALL sub_DD253          ;   -> fault display + service menu
```
`qout_push` has **172 call sites** with **54 distinct constant immediates**
(`0x84`, `0x86`, `0x88`, `0x8A`, `0x8C`, `0xA5`, `0xA9`, `0xAA`, `0xAB`,
`0xAC`, `0xB0`, `0xB3`, `0xB6`, `0xBB`, `0xBC`, `0xBF`, `0xC0`, `0xC3`-`0xCA`,
`0xD2`, `0xD7`, `0xDB`, `0xDC`, `0xE3`-`0xEC`, `0xED`, `0xEE`, `0xEF`,
`0xF1`-`0xF4`, `0xF6`-`0xFB`, `0xFD`, `0xFE`) plus computed values — all of
which are valid indices into the Z80's 256-entry table.

**Confidence:** confirmed.

**Disposition:** hypothesis **corrected**. `4000:1158` is neither a sound
queue (the older `inter_cpu_communication.md` reading) nor a display queue
(the current `CLAUDE.md` reading) — it is the **80188->Z80 command queue** for
lamps, drivers and mode changes.

---

## F13 — DMD frame pipeline

**Statement.** A four-stage pipeline in work RAM feeding a 1 KiB display
buffer at segment `7000`, all 128x32 two-plane, 16 bytes per row x 32 rows =
512 bytes per plane:

```
4000:0000-01FF  sprite/foreground plane 0     \ cleared by sub_F00C4
4000:0200-03FF  sprite/foreground plane 1     /
4000:0400-05FF  mask, one plane               (filled with 0xFF = pass-all by sub_F00C4; sub_F00E0 clears 0000-05FF wholesale)
4000:0600-07FF  background plane 0            \ cleared by sub_F00F1 (0x400 bytes) / sub_F0102 (0x200)
4000:0800-09FF  background plane 1            /
4000:0A00-0BFF  composite plane 0             \ the blit source
4000:0C00-0DFF  composite plane 1             /
7000:0000-01FF  display plane 0               \ cleared at boot by sub_F0113 / sub_F0124
7000:0200-03FF  display plane 1               /
```

**Composite** (`sub_F08A5`, called from the INT0 ISR at `D0383`):
composite = (background AND mask) OR sprite, both planes, 32 rows x 16 bytes.
```
F08A5: BE 00 04 / BF 00 06 / BD 00 04 / BB 00 02 / B9 20 00   SI=0400 DI=0600 BP=0400 BX=0200 CX=32
F08B8: 8A 05 / 22 04 / 3E 88 03      AL=[0600+] & [0400+] -> DS:[0A00+]
F08BF: 8A 01 / 22 04 / 88 85 00 06   AL=[0800+] & [0400+] -> [0C00+]
F08CE: BE 00 00 / BF 00 0A           SI=0000 DI=0A00
F08DB: 8A 04 / 08 05                 [0A00+] |= [0000+]
F08DF: 8A 00 / 08 01                 [0C00+] |= [0200+]
```
**Blit** (`sub_F08EB`, called from the INT0 ISR at `D035E`, the other branch):
```
F08EB: B8 00 70 / 8E C0        ES = 7000
F08F0: BE 00 0A / BF 00 00     SI = 0A00, DI = 0000
F08F6: B9 00 02 / BD 00 02     CX = 0200, BP = 0200
F08FC: 3E 8A 02 / 26 88 03     [4000:0C00+] -> [7000:0200+]     ; plane 1
F0902: AC / AA                 [4000:0A00+] -> [7000:0000+]     ; plane 0
```
So the two ISR branches alternate composite and blit, and the DMD update rate
is **INT0 / 2** (F3).

**No inversion is applied by the firmware** anywhere in this path — the bytes
are `AND`ed and `OR`ed and copied, never `NOT`ed or `XOR`ed. If the panel is
active-low, that is a property of the panel, not of the data.

**Plane weighting** comes from the PIC, not from either CPU ROM:
`asm/pic16c57_annotated.asm` — "per visible frame it scans TWO bitplanes of
32 rows each (plane 0 = MSB first, then plane 1 = LSB)", with PORTB walking
`0x00-0x3F` for plane 0 and `0x40-0x7F` for plane 1 (bit 6 = plane select).
That matches the buffer split above: `7000:0000-01FF` is the plane the PIC
scans first.

**There is no per-frame strobe from the 80188.** PCS4 `0xA0200` bit 3 is
pulsed exactly **once**, in the boot path:
```
pcs4_bit3_strobe D00FA:   shadow | 0x08 -> A0200, 4x NOP, & ~0x08 -> A0200
                          called only from D002C, inside boot_init
```
The PIC is a free-running raster with no command interface (150 words, no
input sampled), so the panel simply displays whatever is in `7000:0000-03FF`
when it scans it.

**Confidence:** confirmed for the buffers, the pipeline, the blit and the
absence of a strobe or an inversion. **Inferred:** plane 0 = MSB (from the
PIC annotation and the wire-protocol measurement, not from either CPU ROM).

**Disposition:** hypothesis **partly confirmed, partly rejected**. The
`7000:0000-03FF` two-plane layout and "plane 0 = MSB" stand. The "DMD-MODE
bit-3 strobe at `0xA0200`" submitting a frame is **rejected** — that bit
fires once at boot. "Bits inverted" is **not supported** by the firmware; if
the driver needs an inversion it must be justified as a panel property and
labelled as such.

---

## F14 — Service menu: what opens it and what paces it

**Statement.** **Switch code `0x3F` opens the service menu.** It is the Z80's
port-`0x03` **bit 1** input (`sub_1278` at `1278`), delivered over J1 like
any other switch code and dispatched from the `413C:00D6` shadow:

```
D7ACF: 26 A0 D6 00      MOV AL, ES:B[000D6]      ; the switch-code shadow (F5)
D7AD5: 3D 3F 00         CMP AX, 0003F
D7AD8: 74 0C            JE  0D7AE6
D7AE6: 9A 03 00 25 DD   CALL 0DD25:00003 {sub_DD253}     ; the menu root
```
The same test also appears at `D32A4` and `D334E`
(`CMP ES:000D6, 03F`). Code `0x40` (port-`0x03` bit 4, `sub_1285`) is the
adjacent action at `D7ADA` and is **not** the menu key.

The menu root `sub_DD253` `DD253`:
```
DD263: 26 C7 06 5A 01 00 00   MOV ES:0015A, 00000     ; menu item index = 0
DD274: 68 F7 00 / CALL qout_push                      ; Z80 cmd 0xF7 = enter test mode
DD294: 9A 96 00 25 DD  CALL sub_DD2E6                 ; the menu loop
DD29E: 68 F8 00 / CALL qout_push                      ; Z80 cmd 0xF8 = leave test mode
DD2A7: 68 C4 00 ... 68 A9 00 ... 68 C4 00 ... 68 F6 00 ... 68 C8 00 ... 68 F4 00
```
On the Z80 side, `0xF7` -> `2DC4` sets `C068 = 0xFF` and `port87_bit5_set`;
`0xF8` -> `2DD9` clears `C068`, `DI`, and `JP boot` — it **reboots the Z80**.

The menu loop `sub_DD2E6` `DD2E6` indexes a table of **46-byte (`0x2E`)
records** through the far pointer at `[4137:004B]` with `413C:015A` as the
index, and dispatches the record's first word through a 14-way jump table at
`CS:018F`:
```
DD2F1: 26 A1 5A 01 / 6B C0 2E    AX = [0015A] * 0x2E
DD2F8: C4 1E 4B 00 / 03 D8       LES BX, [004B] + AX
DD2FE: 26 8B 1F / 83 FB 0D       BX = record[0]; bound 0..0x0D
DD306: D1 E3 / 2E FF A7 8F 01    JMP CS:W[BX + 018F]
```

**The display loop is not paced by anything external.** Each menu item is a
blocking routine that pushes Z80 commands and spins on an inbound byte, e.g.
the lamp test `sub_D5F99` `D5F99`:
```
D5FA4: 68 FA 00 / CALL qout_push           ; Z80 cmd 0xFA
D5FCC: A0 0E 00 / PUSH AX / CALL qout_push ; push lamp codes 0x01..0x31 in turn
D5FC2: 83 3E 0E 00 32 / 75 03              ; stop at 0x32
D6027: CALL sub_D5BCF / OR AL,AL / JE 0D6027  ; wait for ANY inbound byte
```
So the menu holds open for exactly as long as the driver keeps delivering
switch bytes; it needs no marker stream (F4) and no frame clock.

The menu is also entered automatically on a boot self-test fault, from
`main_entry` at `D2FB4` (see F12).

### How you navigate it (added 2026-09-03, Task 16)

"Waits for ANY inbound byte" is true of the *lamp test*, and it is what made
the earlier navigation guesses possible. The ordinary item handlers are
narrower: they accept exactly four codes and dispatch through a four-entry
table. `sub_DD480` `DD480`, the handler for record type 0, is the pattern:

```
DD4E1: CALL sub_DF9D4 / MOV [001B],AL / CMP [001B],0 / JE 0DD4E1  ; block for a byte
DD4F5: 2D 3F 00            SUB AX, 0003F
DD4FA: 83 FB 03 / 77 E2    CMP BX,3 / JNBE 0DD4E1                 ; only 0x3F..0x42
DD501: 2E FF A7 37 03      JMP CS:W[BX + 00337]                   ; table at DD587
DD587: 2B 03  0D 03  B6 02  FE 02      -> DD57B  DD55D  DD506  DD54E
```

| code | target | what it does |
|---|---|---|
| `0x3F` | `DD57B` | redraw, return 1 — **exit** this item to its caller |
| `0x40` | `DD55D` | at record index 0 the same exit, otherwise `sub_DF829` — **back/up** |
| `0x41` | `DD506` | `[4137:0013]++` with a wrap at `record[2]-1`, recompute the display line `413C:0158`, redraw — **scroll** |
| `0x42` | `DD54E` | `sub_DF764([4137:0013])` — **select** the line under the cursor |

`sub_DD669` `DD669` (record type 9) has the same shape with its own table at
`DD6F4`, adding volume up/down on `0x41`/`0x42`.

So: TEST (`0x3F`) opens and exits, the **left flipper** (`0x41`) scrolls, the
**right flipper** (`0x42`) selects, START (`0x40`) goes back. The cursor is
`[4137:0013]`, **not** `413C:015A` — `015A` is written in exactly one place in
the whole ROM (`DD263`, zeroed on entry) and holds the record being displayed,
which changes only on a descent.

**The menu is a tree of 46-byte records in the LMCS window**, reached through
the far pointer `[4137:004B]` that `sub_DD3FB` `DD3FB` sets to flat `0x00100`
(English) or `0x00D08` (country 5, Spanish). Each record is
`{word type, word item count, word line count, 4 x 8-byte line descriptor,
4 x word child index}`. Walked from record 0 the tree is 38 records deep:

```
0  ADJUSTMENT      -> 1 SOUND/VIDEO, 2 GAME, 3 TECHNICAL
1  SOUND           -> 4 VOLUME (type 9), 5 CUSTOM MESSAGE (type 6)
2  GAME            -> 31, 6, 7, 8
3  TECHNICAL       -> 22 BOARD TEST, 23 CREDITS (type 8), 30 TILTS
```

with 8 → {9,10,11}, 11 → {12,15,18}, 12 → {13,14}, 15 → {16,17},
18 → {19,20,21}, 22 → {24,25,26}, 25 → {35,36,37}, 26 → {32,33,34},
6 → {27,28,29}. Types 1-13 are leaf pages; type 0 is a submenu.

**Two of these matter to a driver.** Record 4 (type 9) is the VOLUME page and
it calls `fm_song_select(1)` on entry (`DD66F`) — a real firmware music
trigger reachable **with no credits**, from attract, in three keypresses. And
record 23 (type 8) is the CREDITS page, which renders the live pricing table
and is the cheapest check that the country DIP (F11) is being read correctly.

Verified in emulation on 2026-09-03 against the observed DMD: the root draws
`- ADJUSTMENT -` over SOUND/VIDEO, GAME, TECHNICAL; scrolling moves the
highlight; selecting TECHNICAL then CREDITS renders
`1 OF 50E CRED:1 / 1 OF 100 CRED:3 / 1 OF 200 CRED:6`, matching country 7's
preset byte for byte; and country 5 renders the same tree in Spanish
(`- AJUSTE -`, SONIDO/VIDEO, JUEGO, TECNICO) from record table `0x0D08`.

**There is no OKI sound-test page.** Above `DD000` the ROM has exactly two
calls to the OKI dispatcher `sub_D0B70`, and one of them is the coin sound in
`sub_DD1C1` (`DD1E0`); the other is `F2C2E`, in game code. The sound branch of
the menu is FM and volume only.

Adjacent fact, same mechanism: the **language prompt** at boot is
`sub_D5AD1` `D5AD1` — push Z80 command `0xED`, spin on `sub_D5D8D` for
`0x45` (option A, draws the string triple at record offsets `0x0C/0x0E/0x10`)
or `0x46` (option B, offsets `0x06/0x08/0x0A`). The Z80's `0xED` handler
`2BEB` reads **port `0x04` bit 5** to choose, and F15 fixes which position is
which: low is the service position "no balls dispensed" (answer at once),
high is normal play (check the trough first).

**But that prompt is one *use* of `0x45`, not its definition — do not
special-case the code.** `0x45` also reaches the ordinary switch-code shadow
`413C:00D6` and is dispatched there like any other event, at five sites:
`D7B2E`, `DC063`, `DC08E`, `DC0B5`, `DC0EE` (each `MOV AL, ES:B[000D6] / CBW
/ CMP AX, 00045`; `DC05E` tests `0x40` on the same byte immediately before).
So a driver must deliver `0x45` through the normal J1 path (F5, F6) and let
the firmware decide what it means in the current state — routing it only to
`sub_D5D8D`, or reserving it as a "prompt reply", breaks every one of those
five dispatch sites. The same holds for `0x46` and `0x47`: they are event
codes the Z80 sends, and the prompt and the boot handshake are two of the
states that happen to be listening for them.

**Confidence:** confirmed.

**Disposition:** hypothesis **answered**. The brief left "what opens the
menu" open; the earlier project guesses recorded in `CLAUDE.md` —
"`0x3F` = select", "scroll/select like Bike Race", "`0x33` opens the menu" —
are all **rejected**: `0x3F` *opens* the menu, `0x33` is the test-mode
variant of the port-`0x03` bit-5 input (which F11 now identifies as the coin
mechanism's pulse line, so `0x33` is what a coin pulse reports while test mode
is open), and the `0xED` -> `0x45`/`0x46` exchange is a request/response, not
navigation. *Amended 2026-09-03:* navigation IS by scroll and select after
all, just not on the codes the old guesses picked — the flipper codes `0x41`
and `0x42` scroll and select, and `0x3F`/`0x40` exit and go back. See "How you
navigate it" above; the earlier guesses stay rejected on their specifics. The "menu display loop is paced by PIC markers" belief is rejected with
F4.

---

## F15 — Ball handling: the trough contacts, the serve, and the drain code

**Statement.** Four of the 48 matrix contacts are **ball-handling** contacts,
not playfield events, and both CPUs block on them. They are **switch column 0
bits 0-3**, codes `0x0A`-`0x0D`: bits 0-2 are the three trough contacts and
bit 3 the ball-exit contact. **Contact 0 is the trough entry and doubles as
the ball-over sensor**, reporting code `0x43` rather than its own `0x0A`.

**They are not playfield events.** The in-game dispatcher `sub_D7636`
range-checks against `0x0E` before its 55-entry table, so `0x0A`-`0x0D` reach
no handler:

```
D7652: 2D 0E 00        SUB AX, 0000E
D7657: 83 FB 36        CMP BX, 00036
D765A: 76 03           JBE 0D765F        ; else fall through to the no-op D77C3
D7661: 2E FF A7 27 05  JMP CS:W[BX + 00527]
```

The service manual's matrix list agrees for the group — its first four entries
are `contacto salida bolas 1/2/3` and `bola fuera` — but the manual gives no
bit numbers, so which contact is which comes from the ROM below.

**The four commands** (Z80 handlers, 256-entry table at `$2000`):

| cmd | handler | what it does | answers |
|---|---|---|---|
| `0xE9` | `2B03` | **serve**. If column-0 bit 3 is closed, answer at once; else report driver state 0 busy (`sub_08A7`) and poll column 0 until bit 3 closes — five tries of `0x3E8` ticks | `0x45` served, `0x4A` gave up |
| `0xEA` | `2A45` | **count the trough**: closed contacts among C0DB bits 0-2, plus bit 3 | `0x48` none, `0x38`/`0x39`/`0x3A` = 1/2/3 |
| `0xEB` | `2AB0` | the same count on **column 4** bits 0-2, a second ball device | `0x49` none, `0x3B`/`0x3C` |
| `0xEF` | `2BC7` | **balls home**: test the trough (`sub_2C1F`), run the ball-search coil sequence (`sub_2CFB`), wait (`sub_2D41`), repeat. Its ONLY exit is `sub_2C1F` returning 0 — `2C2B: AND 007` or `2C35: AND 00E` all-zero, i.e. three ADJACENT trough contacts closed | `0x45`, and only then |

`0xEC` (`2C87`) is the same coil sequence with flipper-abortable waits and
`0xED` (`2BEB`) is the trough check gated on port-`0x04` bit 5 (F11's SW40-5).

**That gate fixes SW40-5's polarity.** With bit 5 LOW, `2BEB` answers `0x45`
without looking at a contact — which is precisely "no se dispensan bolas", so
low is the SERVICE position. With it HIGH the handler runs the real check:
strobe column 0, `sub_2C1F`, and either `sub_2851` -> `0x45` (balls home) or
`0x46` and the eject sequence. Normal play is therefore bit 5 **high**, and
in emulation it answers `0x45` in one frame at boot with a full trough.

**The 80188 side.** `sub_DC10D` turns the `0xEA` answer into a ball count in
`[413C:00F9]` through a 4-entry reply table at `CS:04EE4` (`DC144`-`DC17D`
store 3/2/1/0); `sub_DC194` does the same for `0xEB` into `[413C:00F8]`. The
ball-start path `sub_DC4C9`:

```
DC4D0: CALL sub_DC410            ; 0xEA with a 0x96-tick timeout and retry
DC4D4: CALL sub_DC2FC            ; 0xEB, same shape
DC4DC: CMP ES:000F9,0 / JE DC4FE ; trough empty -> ball search
DC4F9: CMP DX,3 / JNL DC522      ; [00F9]+[00F8] >= 3 -> skip the search
DC4FE: PUSH 0EF / CALL qout_push
DC507: CALL sub_DC075 / OR AX,AX / JE DC507   ; wait for 0x45 -- NO TIMEOUT
DC514: MOV ES:000F9, 003         ; a completed search means three in the trough
DC522: CALL sub_DC47E            ; 0xE9, serve one
DC52B: DEC [00F9]
```

`sub_DC53C` is the same with `CMP DX,3 / JE`. **Three is the ball
complement**: `DC514`, `DC587` and `DC14D` all store 3, and `sub_2C1F` only
ever clears with three adjacent contacts closed.

**`DC507` and `2BC7` together are a deadlock** for any emulation that does not
present balls. `0xEA` answers `0x48`, `DC4DC` takes the search branch, the
80188 waits at `DC507` for a reply the Z80 cannot send, and the Z80 never
leaves `2BC7` — so `main_loop` `0D4C` stops running and with it
`input_port03_read_tick` `2E62` and the whole switch scan. Measured in
emulation on 2026-09-03: at game start the Z80's I/O-site histogram switches
from `2E64`/`0D78`/`0D90`/`0DC1` (main_loop, ~7600 reads per 300 frames each)
to `32F5`/`3325`/`3319` (the column snapshots inside the ball loops) with the
main-loop sites at **zero**, and no switch code of any kind reaches
`413C:00D6` again.

**The drain is code `0x43`, and it fixes the trough's orientation.** Contact
0's per-bit routine is the only one of the 48 that does not send its own code:

```
316D:  LD A,#$0A / LD (C0FC),A / JP sub_161E
161E:  LD A,(C068) / AND A / JP NZ,1642   ; TEST mode: send 0x0A like any contact
1625:  LD A,(C054) / AND A / RET Z        ; monitor not armed -> report NOTHING
162A:  LD A,(C04B) / AND A / RET NZ       ; 200-tick lockout still running
162F:  LD HL,#$00C8 / LD (C049),HL / LD A,#$FF / LD (C04B),A
163A:  LD A,#$43 / LD (C0FC),A / JP host_send_c0fc
```

`C054` is armed by 80188 command `0xF3` (Z80 `2A3A`: `C054 = 0xFF`) and
disarmed by `0xF4` (`2A40`), and `sub_DC74B` pushes `0xF3` immediately after
serving the ball (`DC779`). On the 80188 side `0x43` is **ball over** in both
in-game tables: the dispatcher table at `CS:0527` sends it to `D7666 -> CALL
sub_D92C0`, and the ball-in-play wait table at `CS:07AE` (`sub_D7A12`) sends
it to `D7A3E -> CALL sub_D92C0`, where every other playfield code merely
returns 1 to end the wait. `sub_D92C0` sets the ball-over flag
`[413C:000EB] = 1` at `D93A7`, which the mode-4 loop `sub_D3145` tests at
`D31C6`.

Note also that `161E`'s normal-play path never calls `sub_3394`, so it never
sets the reported-mask bit in `C0E8` — unlike contacts 1-3 (`sub_164A` /
`sub_165A` / `sub_166A`), which set the mask and go quiet. Contact 0 therefore
re-reports for as long as it is closed, at the `C04B` lockout rate.

**Consequence:** contact 0 is the trough ENTRY. A ball rests on it only when it
is home, it is open while a ball is out on the playfield, and a ball arriving
there is the drain. Balls fill the trough **from contact 2 down**. Filling
from the other end instead reports a drain the instant the game arms the
monitor — measured: the ball ends about a second after it starts.

**Ball accounting, and what ends a game.** The counters the ball-over path
feeds are per-player record fields, not the `4134` pair:

```
D3999: MOV ES:B[BX + 0002D], AL   ; end of ball, record[player*9+0x2D] = [413C:00FF]
D3B81: CMP ES:000D7, 001 / JNBE   ; players > 1 -> rotate; 1 player -> D3C4E
D3C53: MOV AL, ES:B[00036]        ; the same slot with [413C:00FE] = 1
D3C57: CMP AL, 0003D              ; against balls per game, 4130:003D
D3C5B: JNB 0D3CD7                 ; played >= balls/game -> the game ends
D3C78: MOV ES:B[000FF], AL        ; else this is the next ball number
```

`4130:003D` and the extra-ball score threshold at `4130:0039/003B` are filled
by `boot_init` from the non-volatile store (F10) — `D6711`-`D671F` reads
`5040:003C` and `D66D2`-`D66E4` reads the dword at `5040:0085`. Measured under
the firmware's own factory seed: balls per game **3**, threshold
**50 000 000** (`5040:0085..88` = `80 F0 FA 02`), and the once-per-game award
latch `4130:003E` **0**. Both are ordinary adjustments, neither is degenerate.

The extra ball those cells award is spent before the ball advances —
`D3526: INC [413C:00EE]` on crossing the threshold, `D3A9C`/`D3AB7` test and
decrement it so the same ball is replayed — but it is gated on the score, so
a game that scores nothing never reaches it.

**Confidence:** confirmed for the protocol, the contacts, the drain code and
the SW40-5 polarity.
**A ball that scores too little is given back, and that is what gates the
accounting.** The mode-4 loop tests `sub_D368C` before it reaches `sub_D3920`:

```
D31D3: CALL sub_D368C / OR AX,AX
D31DA: JE 0D31E3                      ; 0 -> on to the accounting at D31F5
D31DC: CALL sub_D449D / JMP 0D323C    ; non-zero -> replay the ball
```
```
sub_D368C D368C:
  D3692: PUSH 05040 / PUSH 00043 / CALL nvstore_read_dword_far   ; DX:AX
  D36A5: BX = ES:000F2 / CX = ES:000F0            ; the score now
  D36AF: SUB CX, 0002D / SBB BX, 0002F            ; minus the score at ball start
  D36B7: CMP DX, BX / JL D36ED                    ; threshold < delta -> return 0
  D36BD: CMP AX, CX / JB D36ED
  D36C6: CMP ES:000EE, 0 / JNE D36ED              ; no extra ball pending
  D36D3: CMP ES:000ED, 0 / JNE D36ED
  D36E0: CMP ES:000DB, 0 / JNE D36ED
  D36E8: MOV AX, 00001                            ; -> replay this ball
```

so a ball scoring **at or below** the adjustment at `5040:0043` is replayed and
never reaches the accounting. Under the firmware's own factory seed that
threshold is **100 000**.

Above it the accounting runs as written and a game ends. Measured over one
player and three balls: `413C:0036` goes 0 -> 1 -> 2 -> 3 and `413C:00FF`
1 -> 2 -> 3; the third ball takes `D3C5B: JNB 0D3CD7`, `D3CD7: XOR AX,AX /
RETF` returns 0, the caller's `D31FC: JE 0D3237` reaches `sub_D46F8`, and the
machine returns to attract (`413C:014F` 4 -> 1) once the last ball is home.

**Inferred:** whether the ball leaves the ball-exit contact
because a player pulls a plunger or because a coil launches it — neither ROM says, and the only
firmware requirement is that it does leave (with bit 3 held closed the
ball-start path re-runs about every 4 s instead of settling into play). The
second ball device on column 4 (`0xEB`, `0xEE` `2B86`) is traced but its
physical identity is not established.

**Disposition:** **no prior hypothesis to adjudicate** — F5 recorded the code
map and left "which physical contact" open for all 48 positions. Four of them
are now closed, from the ROM alone.

---

## F16 — The switch-code to contact table

**Statement.** The firmware carries its own **switch-code -> contact-name
table, in two languages**, which closes most of F5's open item. Two 5-byte
record tables — one per language — sit in the LMCS window (F1), so their
pointers are flat: **English at file offset `0x0830`**, **Spanish at
`0x1438`**. Both are indexed the same way, `record = base + code*5`, each
record `Cnum | off16 | seg16` pointing into that language's own name pool of
length-prefixed glyph strings (`0x0A` = space, `0x0B`-`0x25` = A-Z with Ñ at
`0x19`): the **English pool at `0x1c5f`**, the **Spanish pool at `0x250e`**.

**The two tables are not one shared pool read by ordinal position — each
language has its own code-indexed table.** A code resolves through each
table separately into that table's own pool, and the pools hold the same
entries in a different order: code `0x14`'s English name `U.C.FLIPPER` sits
at file offset `0x1dc7` in the English pool, while its Spanish name
`C.FLIPPER SUP.` sits at a different ordinal position in the Spanish pool.
Pairing the two pools by position does not work; only the shared `code` axis
lines a name up with its translation.

Extracted mechanically by `scripts/iomoon_strings.py`'s `contact_table()`,
which self-tests against F15's four ball-handling contacts, the SW40 tilt
code and the two Jupiter/lane pairs before printing:

```
$ python3 scripts/iomoon_strings.py roms/iomoon/v1_3_01.bin
self-test OK: 51 named codes, 44 of them matrix positions
```

The full table, with `col.bit` from F5's map (`code = 0x0A + 8c + b` for
c = 0..4, `0x34 + b` for c = 5; cabinet codes carry no column/bit):

| code | col.bit | C# | English | Spanish |
|---|---|---|---|---|
| `0x0A` | c0.0 | C6 | OUTHOLE 1 | SALIDA BOLAS 1 |
| `0x0B` | c0.1 | C7 | OUTHOLE 2 | SALIDA BOLAS 2 |
| `0x0C` | c0.2 | C8 | OUTHOLE 3 | SALIDA BOLAS 3 |
| `0x0D` | c0.3 | C9 | BALL OUT | BOLA FUERA |
| `0x0E` | c0.4 | C18 | LANE 5 | PASILLO 5 |
| `0x0F` | c0.5 | C17 | LANE 4 | PASILLO 4 |
| `0x10` | c0.6 | C11 | L.C.FLIPPER | C. FLIPPER IZQ. |
| `0x11` | c0.7 | C10 | R.C.FLIPPER | C. FLIPPER DER. |
| `0x12` | c1.0 | C22 | LANE 11 | PASILLO 11 |
| `0x13` | c1.1 | C21 | RAMP 1 EXIT | SALIDA RAMPA 1 |
| `0x14` | c1.2 | C19 | U.C.FLIPPER | C.FLIPPER SUP. |
| `0x15` | c1.3 | C16 | RIGHT SHOOTER | EXPULSOR DERECHO |
| `0x16` | c1.4 | C15 | LEFT SHOOTER | EXPULSOR IZQ. |
| `0x17` | c1.5 | C14 | LANE 3 | PASILLO 3 |
| `0x18` | c1.6 | C13 | LANE 2 | PASILLO 2 |
| `0x19` | c1.7 | C12 | LANE 1 | PASILLO 1 |
| `0x1A` | c2.0 | C24 | LANE 6 | PASILLO 6 |
| `0x1B` | c2.1 | C25 | BANK A | DIANA BANCADA A |
| `0x1C` | c2.2 | C26 | BANK B | DIANA BANCADA B |
| `0x1D` | c2.3 | C27 | BANK C | DIANA BANCADA C |
| `0x1E` | c2.4 | C28 | BANK D | DIANA BANCADA D |
| `0x1F` | c2.5 | C29 | BANK E | DIANA BANCADA E |
| `0x20` | c2.6 | C30 | INNER BANK | FONDO BANCADA |
| `0x21` | c2.7 | C31 | HOLE 2 | TRAGABOLAS 2 |
| `0x22` | c3.0 | C23 | HOLE 1 | TRAGABOLAS 1 |
| `0x23` | c3.1 | C33 | BUMPER 1 | BUMPER 1 |
| `0x24` | c3.2 | C32 | BULL EYE 1 | DIANA 1 |
| `0x25` | c3.3 | C35 | BUMPER 3 | BUMPER 3 |
| `0x26` | c3.4 | C34 | BUMPER 2 | BUMPER 2 |
| `0x27` | c3.5 | C37 | BUMPER 5 | BUMPER 5 |
| `0x28` | c3.6 | C36 | BUMPER 4 | BUMPER 4 |
| `0x29` | c3.7 | C40 | RAMP 1 ENTRANCE | ENTRADA RAMPA 1 |
| `0x2A` | c4.0 | C44 | JUPITER 1 | JUPITER 1 |
| `0x2B` | c4.1 | C45 | JUPITER 2 | JUPITER 2 |
| `0x2C` | c4.2 | C46 | JUPITER 3 | JUPITER 3 |
| `0x2D` | c4.3 | C39 | RAMP 2 ENTRANCE | ENTRADA RAMPA 2 |
| `0x2E` | c4.4 | C38 | BULL EYE 2 | DIANA 2 |
| `0x2F` | c4.5 | C48 | LANE 10 | PASILLO 10 |
| `0x30` | c4.6 | C49 | RAMP 1 MIDDLE | MEDIA RAMPA 1 |
| `0x31` | c4.7 | C50 | ENTRADA JUPITER | ENTRADA JUPITER |
| `0x32` | — | C50 | ENTRADA JUPITER | ENTRADA JUPITER |
| `0x33` | — | C3 | COINS INPUT | MONEDERO |
| `0x34` | c5.0 | C47 | RAMP 2 EXIT | SALIDA RAMPA 2 |
| `0x35` | c5.1 | C43 | LANE 9 | PASILLO 9 |
| `0x36` | c5.2 | C42 | LANE 8 | PASILLO 8 |
| `0x37` | c5.3 | C41 | LANE 7 | PASILLO 7 |
| `0x3E` | — | C20 | PLUMB TILT | PENDULO DE FALTA |
| `0x3F` | — | C4 | TEST BUTTON | PULSADOR TEST |
| `0x40` | — | C2 | START BUTTON | PULSADOR START |
| `0x41` | — | C1 | L. FLIPPER | FLIPPER IZQ. |
| `0x42` | — | C5 | R. FLIPPER | FLIPPER DER. |

**What it closes.** F5's open item — "44 of the 48 switch-matrix positions
have exact codes but no established physical contact" — is closed: every one
of the 44, plus all 6 cabinet inputs (already named in F5) plus the coin's
test-mode code, now carries the firmware's own C-number and name in both
languages. **Column 4's second ball device (F15's command `0xEB`, Z80
handler `2AB0`) is Jupiter** — codes `0x2A`-`0x2C` are JUPITER 1/2/3,
C44-C46.

**What is dead.** Codes `0x38`-`0x3B` — four more column-5 positions — have
table records with no resolvable name pointer, so those four positions do
not exist. `0x13` has a name (RAMP 1 EXIT, C21) but its per-bit dispatcher is
a bare `RET`, and the service manual's own contact list (2.1.1) lists C21 as
*Sin conectar* — named in the ROM, wired to nothing. The record at `0x32`
duplicates `0x31`'s exactly (both C50 ENTRADA JUPITER) and is stale; `0x33`
resolves independently to C3 COINS INPUT / MONEDERO — the code the coin
mechanism sends while test mode is open (F5, F11), which is exactly where
the CONTACTOS test screen reads it.

**Three discrepancies, recorded not resolved.**
- The ROM pairs C10 with R.C.FLIPPER and C11 with L.C.FLIPPER; the manual's
  own 2.1.1 table has C10 as "Contacto de corte de flipper izquierdo" and
  C11 as "...derecho" — the opposite way round.
- `docs/switch_lamp_solenoid.md`'s C40 and C44-C50 rows disagree with the
  ROM (C39, C41-C43 agree); e.g. C47 = Salida Rampa 2 in the ROM and the
  manual, "Entrada Rampa 1" in the docs. The ROM and the manual's 2.1.1
  table agree with each other there too, except C44-C46 — the next bullet.
- Codes `0x2A`-`0x2C` (C44/C45/C46) are JUPITER 1/2/3 in the ROM, in both
  languages, where the manual's 2.1.1 contact list names the same three
  C-numbers Planeta 1/2/3 — the ROM is what runs. The manual's own lamp
  list agrees with the ROM here (LC51 *Planeta 5*, LC61 *Planeta 1*, LC62
  *Planeta 2* are lamps, not contacts), and these three codes are already
  the second ball device Z80 command `0xEB` (handler `2AB0`) counts above:
  the manual's Jupiter two-ball lock.

**Confidence:** confirmed — table location, record layout and pool decode
are mechanical and self-tested; the C-numbers and names are cross-checked
against the Spanish service manual's own 2.1.1 table for all 51 codes.

**Disposition:** hypothesis **answered**. F5's per-fact gap table (#3)
narrowed the open item to "the physical switch behind each code" for 44
matrix positions once F15 closed the ball-handling four; this closes those
44, from the ROM's own contact names, cross-checked against the manual.

---

## F17 — The Z80 driver latches carry coils 1-16

**Statement.** Z80 ports `$85`/`$86` — F7's two 8-bit, active-low driver
latches — map onto the service manual's coil numbers 1-16 in the simplest
possible way: **`$85` bit *b* = coil *b*+1, `$86` bit *b* = coil *b*+9.**

| port | bit | coil | manual name (2.3.1) | fires at |
|---|---|---|---|---|
| `$85` | 0 | 1 | Flipper izquierdo fuerza | `05C7` |
| `$85` | 1 | 2 | Flipper izquierdo mantenimiento | `0613` |
| `$85` | 2 | 3 | Flipper derecho fuerza | `05ED` |
| `$85` | 3 | 4 | Flipper derecho mantenimiento | `0630` |
| `$85` | 4 | 5 | Flipper superior fuerza | `067F` |
| `$85` | 5 | 6 | Flipper superior mantenimiento | `06A5` |
| `$85` | 6 | 7 | Bumper 1 | `06DB` |
| `$85` | 7 | 8 | Tragabolas 1 | `07E0` |
| `$86` | 0 | 9 | Bumper 2 | `06F8` |
| `$86` | 1 | 10 | Bumper 3 | `0715` |
| `$86` | 2 | 11 | Bumper 4 | `0732` |
| `$86` | 3 | 12 | Bumper 5 | `074F` |
| `$86` | 4 | 13 | Taca | `076C` |
| `$86` | 5 | 14 | Expulsor 1 | `0789` |
| `$86` | 6 | 15 | Expulsor 2 | `07A6` |
| `$86` | 7 | 16 | Sueltabolas de Jupiter | `07C3` |

**Three independent sources agree.**

Z80-side, each bit has its own fire routine: DI, arm a per-channel on-timer
byte to `0xFF`, flip the port shadow under `OR`/`AND` masks, `OUT`, EI —
e.g.
```
05C7:  LD A,#$FF / LD (C009),A / A=(C005) OR #$02 AND #$FE / OUT ($85),A   ; fire 1, release 2
0613:  LD A,#$FF / LD (C00C),A / A=(C005) OR #$01 AND #$FD / OUT ($85),A   ; fire 2, release 1
06DB:  LD A,#$FF / LD (C00F),A / A=(C005) AND #$BF          / OUT ($85),A   ; fire 7 (lone bit)
06F8:  LD A,#$FF / LD (C010),A / A=(C006) AND #$FE          / OUT ($86),A   ; fire 9 (lone bit)
07E0:  LD A,#$FF / LD (C019),A / A=(C005) AND #$7F          / OUT ($85),A   ; fire 8 (lone bit)
```
All sixteen fire routines (`05C7`, `05ED`, `0613`, `0630`, `067F`, `06A5`,
`06DB`, `07E0` on `$85`, then `06F8`-`07D1` on `$86`) follow this shape, each
arming its own on-timer byte — 16 bytes spanning `C009`-`C019` (skipping
`C014`) for the 16 channels — and each reached from the 80188 command table
`$2000` through a wrapper that gates on `C068` (test mode) first, e.g.
`sub_2895 -> 289A: CALL 05C7`, `sub_2919 -> 291E: CALL 0613` (F7).

Second, the service manual's own coil table, **2.3.1 DESCRIPCION DE
BOBINAS**: "el aparato dispone de 18 bobinas (en los flippers hay doble
bobinado lo que supone un total de 21)", numbered 01-21 in exactly the order
above for 1-16, then 17 Salida de bolas, 18 Bancada de dianas, 19 Diverter de
Rampa, 20 Black Hole Power (No conectada), 21 Diverter de Jupiter.

Third, the manual's own split of those 21 coils into two drive circuits,
**7.2.4.3 CIRCUITOS DE ATAQUE A BOBINAS**: the *potencia* circuit (figura
7-11) drives Flipper Izquierdo/Derecho/Superior Fuerza, Bumper 1-5 and the
five expansion-board coils; the *mediana potencia* circuit (figura 7-12)
drives Flipper Izquierdo/Derecho/Superior Mantenimiento, Tragabolas 1, Taca,
Expulsor 1/2 and Sueltabolas de Jupiter. Landed on the bit map above, that is
**`$85` bits 0/2/4/6 potencia, 1/3/5/7 mediana potencia**, and **`$86` bits
0-3 potencia, 4-7 mediana potencia** — exactly the fuerza/mantenimiento split
the fire routines already show.

**F7's "three complementary pairs on `$85`" are the three dual-wound
flippers.** `05C7`/`0613` are coils 1/2 (left), `05ED`/`0630` are coils 3/4
(right), `067F`/`06A5` are coils 5/6 (upper); each pair's release routine
(`064D`, `0666`, `06C2`) sets both bits high together.

**What is open.** Coils 17-21 — *Salida de Bolas*, *Bancada de Dianas*,
*Diverter de Rampa*, *Black Hole Power* (marked *no conectada* in both the
coil table and the circuit list) and *Diverter de Jupiter* — plus the three
flash lamps are on the driver expansion board 011-033A, whose own connector
(figura 7-10) carries them as channels TA/TB/TC 1-8. **No Z80 port drives
them.** Enumerating every `OUT` in `iomoon_z80.lst` (105 instructions) finds
exactly eight distinct ports and nothing else:
```
$ grep -oE 'OUT[[:space:]]+\([^)]*\)' iomoon_z80.lst | sort | uniq -c | sort -rn
     25 OUT      ($86)
     22 OUT      ($81)
     16 OUT      ($85)
     13 OUT      ($82)
      9 OUT      ($84)
      9 OUT      ($83)
      7 OUT      ($87)
      4 OUT      ($80)
```
and every bit of those eight is accounted for: `$80`/`$81` J1 (F6), `$82`
the switch-column strobe, `$83`/`$84` the lamp matrix (F7), `$85`/`$86` the
16 channels above, `$87` the direct-input index plus bits 4 and 5 set and
cleared individually (`port87_bit5_clear`/`port87_bit5_set` at `27B3`/`27C0`,
and the bit-4 pair at `2831`/`2851`). **Settled on the Z80 side:** schematic
sheet `011-030-02` shows IC17, the 74LS138 that decodes the output ports,
wiring all eight of its outputs as `O0`-`O7` and nothing more, enabled by `A7`
and by IC8's `/CEO` — so eight output ports is the whole of the Z80's OUT
space, and there is no ninth strobe for an expansion board to hang off. IC7,
the 80188-side PAL, is dumped and rules itself out too: none of its eight
outputs leaves the 16-bit board. **Neither CPU can address the expansion board
at all**, so whatever drives coils 17-21 is fed from one of the sixteen
channels above or from the 011-033A connector itself.

**Confidence:** confirmed for the bit map, the fire-routine shape and the
manual cross-reference; the expansion-board wiring rests on the manual alone
(7.2.4.1/7.2.4.3), since no Z80 code touches it.

**Disposition:** hypothesis **answered** — F7 established the 16-bit
driver-latch count and the three complementary pairs without naming the
coils; this pins all 16 to the manual's own numbering and confirms the split
with the manual's own circuit description.

### Addendum (2026-09-13, Task 13): Tragabolas 2, the ball-search sweep, and coil 16

**Hole 2 (Tragabolas 2, code `0x21`, C31) has no coil — corrected to the
right dispatch address (2026-09-13, fix round 1).** `sub_D7636`'s jump table
(`JMP CS:W[BX+00527]`) executes with `CS = D72A` (visible a few lines above
it, in a far `CALL 0D72A:02020` from the same routine), so the table itself
is at flat `D72A0+0527 = D77C7`, indexed by `code-0x0E`. Read directly out
of the ROM (`v1_3_01.bin`, file offset `0x577C7 + 2*(code-0x0E)`, since
UMCS's flat `0xC0000-0xFFFFF` is file `0x40000-0x7FFFF` — F1): code `0x21`'s
word is `0x050E`, landing at flat `D72A0+050E = D77AE`, an unconditional
`CALL sub_D9CAB` — **not** `D7723` as this addendum first said (that word,
`0x0483` at code `0x25`, is Bumper 3's own entry). `sub_D9CAB` loads
`DS = 4134` and never loads `ES` at all, and neither of its two byte
accesses carries an ES-override prefix (`80 3E 26 00 00`, `C6 06 27 00 01` —
no leading `26`), so they are **`4134:0026`** and **`4134:0027`**, a
different segment from `413C` (fix round 2 — this addendum first mis-cited
both as `413C`). Gated on the one-byte counter `4134:0026`: `> 0` does
nothing (`XOR AX,AX`); otherwise it plays one OKI cue (`sub_D0B70(0x18)`)
and sets `4134:0027 = 1`. **Neither branch calls `qout_push`**, so no Z80
command and no coil can result — the
"no kicker" conclusion holds, now resting on the address that is actually
Hole 2's. The manual's 2.3.1 coil list still independently agrees: it names
"Bobina Tragabolas 1" (coil 8) and has no counterpart for Tragabolas 2, and
"Bobina de Taca" (coil 13) is a separate line; Tragabolas 2 appears in the
manual only as a contact (2.1.1), a lamp (2.2.2 — LC17, LC37, LC50) and a
scoring rule (3.3.8), never as a coil. Measured in emulation, unchanged:
routing a ball to Hole 2 delivers code `0x21` to the switch-code shadow
`413C:00D6`, confirming the contact reaches the 80188, and
`coreGlobals.solenoids` stays `0` for the following 900+ frames (15 s at
60 Hz — three times the 300-frame window checked), reproduced on two runs.

**Hole 1 (Tragabolas 1, code `0x22`, C23) — traced to its real handler, and
the mechanism corrected.** Its table word, one earlier, is `0x04F8`, flat
`D7798` — **gated at the dispatch level itself**, but the other way round
from what this addendum first said (fix round 2): the bytes are
`CMP ES:000F4,009 / JNE D77A7` (`D779D`-`D77A3`), so `413C:00F4 == 9` is the
value that falls through to `JMP D77C3` and does **nothing**, and any other
value is what takes the branch into `CALL sub_D9B91`. That routine is
modal, not Hole 2's scoring twin: a one-shot debounce (`sub_D9B76`, latch
`4134:0028`) admits only the first call per visit; it then branches on
`4134:0026` (`> 0` fires coil 8 alone, via `sub_D9B49`, and stops — same
segment as Hole 2's own gate above, confirmed the same way: no ES prefix on
either access) and otherwise on `413C:00F4` again (`7` awards Star Ride
points with no coil — `0xE4E1C0` (15,000,000) when `4134:0027 != 0` and
`0x989680` (10,000,000) when it is `0` — matching the manual's 3.3.8 Star Ride figures for
the two holes; anything else — neither `7` nor `0` — scores 150,000 and
calls `sub_D9B49` alone, no Taca; `0` is the value that reaches `D9C61`).
`D9C61` is itself a further, three-way split on `413C:010F` and
`4134:0027`, not a plain call to `sub_D97D1`: `010F == 1` or `010F == 2`
calls `sub_D97D1`; `010F` anything else **and** `0027 != 0` also calls
`sub_D97D1`; but `010F` anything else **and** `0027 == 0` takes a
**different, untraced branch at `D9C8A`** — `qout_push(0xF2)`, then
`sub_DB503`, then `qout_push(0xF1)` — which never touches `sub_D97D1`, the
stepper, or coil 13 at all. `sub_D97D1` (reached on the first two of those
three arms) branches on `413C:010E` (`1`: score 150,000, call `sub_D9B49`,
done; otherwise: bump two audit counters and dispatch a 10-state stepper at
`4134:0002E`, `CS:02895` — verified directly against the ROM's own ten
words at flat `D9B35`, e.g. word 0 is `0x25A7`, landing at
`D72A0+25A7 = D9847`). **State 0** of that stepper compares a counter
`413C:00EE` against a threshold `413C:0101`: at or past the threshold, it
skips straight to an audit bump; below it, it also plays an OKI cue
(`0x83`), waits for it to finish (`4000:1304`), and additionally calls
`sub_D823B`, which does `qout_push(0xE7)` — the Z80's own 256-entry table
at `$2000` (read directly from `V1 3_05.bin`, entry for `0xE7`) is `0x2A36`
→ `sub_2A36` → `CALL sub_076C` = **coil 13, Taca** — before an NVRAM
increment and the same audit bump. **Both outcomes of that threshold check
converge** on `JMP D9B2F`, which falls into `D9814` → `CALL sub_D9B49` —
`qout_push(0xDC)` (Z80 table entry `0x29E1`, likewise read directly from
the ROM) → arms a 300-tick timer → `CALL sub_07E0` = **coil 8** — so on this
branch coil 8 fires every time, and Taca fires only while `413C:00EE` is below
`413C:0101`, a separate, narrower gate than the branch selection itself.
Measured: two separate fresh games both took this exact branch with the
counter still below threshold, coil 13 firing about 3.2 s after the contact
and coil 8 about 3.75 s after that — real intervening work (the OKI cue and
its busy-wait, the NVRAM increment) accounts for the gap.

**This is one reachable branch of several, not the routine's only
behaviour — restated as conditional.** Other branches fire coil 8 alone
(`4134:0026 > 0`, or `413C:00F4` anything but `0` or `7`), the
`413C:00F4 == 7` branch fires no coil at all, and the untraced `D9C8A`
branch above sends two commands (`0xF2`, `0xF1`) that are neither coil.
Two fresh, freshly-reset games taking the same branch is consistent with
every gating cell (`4134:0026/0027/0028/002E`, `413C:00F4`, `:010E`,
`:010F`, `413C:00EE`) starting at its boot-time default both times, not
with the mechanism being unconditional. What `413C:00F4`, `:010E`, `:010F`,
the stepper `4134:002E`, the `413C:00EE`/`:0101` counter, and the `D9C8A`
branch's two commands mean in player-visible terms is **not decoded here
and is recorded as open**. What this does settle: "Bobina de Taca" is not a
stray name for Tragabolas 2's missing coil — on the branch measured here it
fires from Tragabolas 1's own handler, immediately ahead of that same
handler's own coil 8, and Hole 2's handler (`sub_D9CAB`) never reaches it.

**The two holes share a flag, and that is established, not guessed.**
`sub_D9CAB` (Hole 2) sets `4134:0027 = 1` on its OKI-cue branch;
`sub_D9B91` (Hole 1) reads that same cell to pick the Star Ride award,
`0xE4E1C0` (15,000,000) when it is set, `0x989680` (10,000,000) when it is
clear — the manual's own two different Tragabolas Star Ride figures (3.3.8)
are produced by **one code path, Hole 1's, selected by a flag Hole 2's own
contact sets.** Both halves of that are read directly out of the two
routines above; the connection between them is the new fact.

**Hypothesis, not established, from that shared flag:** the two scoops may
share a physical ball-return path, with `4134:0027` recording which of the
two most recently fed it — which would bear directly on this document's own
open question of what frees a ball sitting in Hole 2. Nothing traced here
shows a physical mechanism, only a shared software flag; a real machine or
a look at the two holes' own ball paths (manual figura, if one exists, or a
teardown) would settle it.

**A second correction: `413C:00F0`/`00F2` is the running score, not "a
bonus."** Three handlers writing the same dword settle it against the
manual's own numbers: Lane 6 (`sub_D8590`) adds `0x186A0` = 100,000; Diana 1
/ bull's-eye 1 (`sub_D8B30`) adds `0xC351` = 50,001, or `0x186A0` = 100,000
when `413C:00F4 == 5` (Special Drop Target) — both read directly from the
ROM and both the manual's own score values for those contacts, verbatim.
Every place above that was called "a bonus add" is a score add.

**The ball-search sweep (`sub_2CFB`, F15's "run the ball-search coil
sequence, wait, repeat") pulses eight coils, and neither Taca nor the
Jupiter release.** Its ten calls, each separated by the `sub_2D3B`/`sub_2D41`
delay, are `sub_0957`, `sub_08FF` (both clear a bit of the J1 state byte
`$C008` and send it — F6, not a coil port), then `sub_06DB`(7), `sub_06F8`(9),
`sub_0715`(10), `sub_0732`(11), `sub_074F`(12), `sub_07E0`(8), `sub_0789`(14),
`sub_07A6`(15) — coils 7, 9, 10, 11, 12, 8, 14 and 15 in that call order.
Neither `sub_076C` (13, Taca) nor `sub_07C3` (16, Sueltabolas de Jupiter) is
called anywhere in `sub_2CFB`. Re-measured in emulation at a fresh ball start
(plain `iomoon`): the live solenoid trace shows exactly this order once,
`0x0040, 0x0100, 0x0200, 0x0400, 0x0800, 0x0080, 0x2000, 0x4000`, with no
`0x1000` (13) or `0x8000` (16) anywhere in it.

This is a positive datum for Hole 2 having no kicker — the firmware's own
ball-recovery sweep does not treat Taca as a ball-freeing device either —
but it is not proof by itself: the sweep recovers *missing trough balls*, so
skipping 13 and 16 only shows neither is wired into *that* recovery. It says
nothing about what frees a ball already captured in Hole 2 or in Jupiter.
Jupiter's own release is coil 16, fired by a different routine entirely
(`sub_2C41`, which calls `sub_07C3` at both `2C54` and `2C5C` — i.e.
regardless of which way its own three-Jupiter-contact test comes out).

**Coil 16 was not observed firing in about 46 s of normal single-ball play**
(plain `iomoon`: coin, START, plunge, 2700 frames), and the one-time
ball-search sweep above does not touch it either. That is an observation,
not proof it never fires: `sub_2C41` exists and calls `sub_07C3`
unconditionally on both outcomes of its own test, and the project's own ball
simulator already models "a legitimate Jupiter lock… released by the game
through coil 16" (`pinmame/src/wpc/sims/sleic/iomoon.c`) — a genuine
two-ball Jupiter lock or a multiball might reach it where a single default
ball never does. What would settle it: the MAME debugger on 80188 command
`0xEB`'s handler (`2AB0`) and the coil-16 wrapper, or a real machine.

**Confidence:** confirmed for the dispatch-table read, done directly against
the ROM (`D77AE` → `sub_D9CAB` for Hole 2, no `qout_push`; `D7798` →
`sub_D9B91` for Hole 1 — gated on `413C:00F4 != 9`, verified byte for byte —
which reaches `sub_D823B` → coil 13 and `sub_D9B49` → coil 8 on one traced
branch of several), for the segment on every `4134:` cell (`0026`, `0027`,
`0028`, `002E` — each checked for the absence of an ES-override prefix, not
assumed), for the shared-flag fact (`4134:0027`, read directly out of both
routines), for the score-not-bonus correction (three handlers, three
manual-matching values), and for `sub_2CFB`'s ten calls and their
identities; confirmed by live measurement for Hole 2's silence, Hole 1's
coil 13/coil 8 sequence on the branch two fresh games both took, and the
sweep's live order. Open: which player-visible condition selects Hole 1's
branch (named cells: `4134:0026/0027/0028/002E`, `413C:00F4`, `:010E`,
`:010F`, `413C:00EE`/`:0101`); what the untraced `D9C8A` branch's two
commands (`0xF2`, `0xF1`) do; whether the two holes share a physical return
path (a hypothesis, not established); what, if anything, ever frees a ball
sitting in Hole 2; and coil 16 outside single-ball play.

**Disposition:** hypothesis **answered** for Hole 2 (no coil, on two
independent kinds of evidence, now at the correct address and segment) and
for the sweep's coil list (confirmed, not merely named); **corrected** for
Hole 1 (Taca-then-coil-8 is real, but conditional, and its dispatch gate is
the opposite polarity from this addendum's first round, on the address,
segment and mechanism now traced end to end rather than assumed); **new**
for the shared `4134:0027` flag explaining the manual's two Star Ride
figures; **open** for the gating cells' player-visible meaning, the
`D9C8A` branch, the shared-return-path hypothesis, and coil 16 outside the
cases measured here.

---

## F18 — The lamp matrix

**Statement.** The service manual's figure 7-7 gives (column,row) -> LC
number, but its OCR is damaged in places, so the table below is **measured**
from the firmware's own sequential lamp test rather than transcribed: the
service menu's TEST LUCES 1 walks the controlled lamps LC1..LC64 one at a
time, in the order the manual's 2.2.2 lists them, so the *N*th single-lamp
step is LC*N*.

Reached, per F14's tree, at the country default (4, Netherlands — English;
country 5 selects Spanish, see F11): TEST (`0x3F`) -> root (record 0), scroll
twice, select -> record 3 (TECHNICAL — F14's own tree; TECNICO in the
manual/Spanish) -> select at once -> record 22 (BOARD TEST / the manual's
TEST TABLERO) -> scroll once, select -> record 25 (LIGHTS / LUCES) -> select
at once -> record 35, the walk itself, on-screen "- LIGHT TEST -". F14
already shows record 0's own three items rendering identically in English
and Spanish (just relabelled), so records 3/22/25/35 are expected, not
verified here, to be the same positions in the Spanish table at `0x0D08`.
Captured with `scripts/keyscripts/iomoon-lamptest.keys` and a temporary probe
in `SLEIC_interface_update` printing `coreGlobals.lampMatrix` on every
column change (removed before commit — nothing in the driver carries it).

**The walk is monotonic and single-lamp — verified, not assumed.** Over the
full 64 steps plus the wrap back to LC1: every non-zero value logged is a
power of two (one bit at a time), the 64 (column,bit) pairs are pairwise
distinct (no repeats within the 64), and step 65 reproduces step 1 exactly
(column 7, bit 7) — a complete, non-skipping, non-repeating cycle of 64.
Reproduced down to the millisecond on two independent runs: the `iomoont`
tournament-mod set navigated per the path above, and the plain `iomoon` set
as a cross-check (chip 01 is the only ROM these two sets do not share, and it
carries no part of the menu tree or the lamp test).

**The 64-lamp table**, Z80 lamp column (0-7) x row/bit (0-7) -> LC:

| col \ row | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 |
|---|---|---|---|---|---|---|---|---|
| 0 | LC20 | LC21 | LC22 | LC23 | LC24 | LC25 | LC26 | LC27 |
| 1 | LC28 | LC29 | LC55 | LC54 | LC53 | LC56 | LC52 | LC51 |
| 2 | LC38 | LC41 | LC44 | LC46 | LC48 | LC49 | LC37 | LC36 |
| 3 | LC2 | LC3 | LC4 | LC5 | LC6 | LC7 | LC8 | LC9 |
| 4 | LC10 | LC11 | LC12 | LC13 | LC17 | LC16 | LC15 | LC14 |
| 5 | LC61 | LC62 | LC63 | LC64 | LC57 | LC58 | LC59 | LC60 |
| 6 | LC30 | LC31 | LC32 | LC33 | LC34 | LC35 | LC50 | LC39 |
| 7 | LC40 | LC43 | LC47 | LC45 | LC42 | LC18 | LC19 | LC1 |

**Agrees with figure 7-7 everywhere it is legible — no disagreement found.**
30 of the 64 cells are individually readable in the manual's own OCR text
(`sleic_io_moon_manual_es.md`, "figura 7-7"): all of column 0 (LC20-27, read
as a run against the sequential `(0,1)..(0,7)` labels), all of column 2
(LC38, 41, 44, 46, 48, 49, 37, 36), (1,0)=28, (3,0)=2, (4,0)=10, (4,1)=11,
(4,3)=13, (4,4)=17, (4,5)=16, (4,6)=15, (4,7)=14, (5,0)=61, (6,0)=30,
(6,4)=34, (7,0)=40 and (7,7)=1. Every one of the 30 agrees with the
measured table above. The rest of the figure's OCR is too garbled — merged
color codes, dropped digits, coordinates and values out of registration — to
read a value from with confidence, so it is not transcribed.

**Confidence:** confirmed — the walk's own single-lamp, non-repeating
structure over a full 64-step cycle is the primary evidence, reproduced on
two independent ROM sets; the legible fraction of figure 7-7 is independent
corroboration, with zero disagreements across 30 cross-checked cells.

**Disposition:** hypothesis **answered** — F7 established the 64-lamp,
8-column x 8-bit matrix and its two-bank blink model without naming which
physical lamp sits at which (column,bit); there was no full LC map committed
before this. It is now measured rather than transcribed, closing that gap
the same way F16 closed the switch-matrix one.

---

## F19 — Opening the service menu re-derives the country from a stray byte, not the DIP

**Statement.** Opening the service menu **changes the machine's own tracked
country**, every time, regardless of which country was running. It is not a
capture artefact and not a Spanish-specific bug: the country-DIP re-read that
menu exit triggers loses a race against the Z80 reboot that same exit
causes, and the byte it wrongly accepts as the DIP report decodes to country
7 (Portugal) **unconditionally**, whatever country was actually selected.

**The command sequence, read directly out of the ROM.** Menu exit
(`sub_DD253`, F14) queues four 80188->Z80 commands back to back through
`qout_push` (F6, the outbound FIFO at `4000:1158`, drained at INT0/8):

```
DD29E: PUSH 000F8 / CALL qout_push        ; leave test mode
DD2A7: PUSH 000C4 / CALL qout_push        ; queued directly behind F8
DD2B0: CALL sub_D622C                     ; F10's NVRAM-reinit routine --
                                           ; calls sub_D5A8B below, which
                                           ; itself queues F9
DD2B5: PUSH 000A9 / CALL qout_push
...
```
`sub_D622C` (F10) is not a first-boot-only routine here: this call site
(`DD2B0`) is one of four, alongside boot itself (`D2F72`, `D3033`) and a
fourth site (`DF5FF`). Inside it, at the point F11 already names (`D664D`),
`sub_D5A8B` `D5A8B` runs the country-DIP re-read:

```
D5A91: PUSH 000F9 / CALL qout_push        ; ask the Z80 for the DIP byte
D5AA6: CALL sub_D5C3E                     ; poll for the reply, in a retry
D5AAD: JNE 0D5ABC                         ; loop against a 16-tick timeout
D5AB4: CMP ES:0113D, 00000 / JNE 0D5AA6   ; ([113D], loaded 0x14 at DD28D)
```

**`sub_D5C3E`'s accept test is "the next byte in the FIFO is `>= 0xF0`", not
"the next byte is `0xF9`'s specific reply".** Traced byte for byte:

```
D5C49: MOV AL, ES:[1147]                  ; F4's "byte available" flag
D5C5C: LES BX, ES:[1150]                  ; the SAME inbound FIFO F4 describes
D5C61: MOV AL, ES:[BX]                     ; pop the head byte, unconditionally
D5CA3: CMP 00006, 0F0 / JNB D5CAC          ; >= 0xF0 -> accept; else discard, return "nothing yet"
D5CAC: AND AL, 00E                         ; bits 1-3
D5CB6: SUB AX, 00002                       ; 7-way jump table, indices 0,2,4,6,8,10,12 -> country 1..7
D5CF8: (out of range)  MOV 00020, 000      ; country 0 (fallback)
```
This is F4's own general rule — "every consumer pops one byte unconditionally
and then tests it, discarding it if it is not the value that consumer
wants" — except that `sub_D5C3E`'s test is a **range**, not an exact match,
so it does not discard a byte merely because it came from somewhere else.
Any byte `>= 0xF0` that reaches the head of the FIFO while this loop is
polling is accepted as the DIP report, from whatever source sent it.

**What supplies that byte, faster than the real reply can arrive.** `0xF8`
(queued first, above) reboots the Z80 outright — F14: `2DD9: DI / JP boot`.
A rebooting Z80 announces its own input state unconditionally, over the
**other** J1 channel (F6: `C008`, the state-bitmask send, `host_send_c008_*`,
strobed on port-`0x81` bit 5, a **different** strobe from the `C0FC`
event-code channel `0xF9`'s reply travels on but the **same** inbound
NMI/PCS2 path on the 80188 side that every byte — event code or state
bitmask alike — is read through, per F6's own account). "All inputs idle"
is `0xFF`, and `(0xFF AND 0x0E) - 2 = 0x0C`, the **last** of the seven table
entries traced above — **country 7, unconditionally, whatever byte a real
DIP would have produced**, because `0xFF` is not a DIP report at all, it is
every input bit set. The real `0xF9` reply cannot win this race structurally:
it is queued (at `sub_D622C`'s call into `sub_D5A8B`) **after** `0xC4`, which
is itself queued **after** `0xF8`, and the outbound FIFO drains one
throttled byte at a time (F6: INT0/8) — while the `0xFF` announcement rides
the Z80's own reboot and needs no outbound turn at all.

**Confirmed live, not only from the ROM.** A traced repro run, country 5
selected beforehand:
```
cmd=f8 -> byte=ff(C008) -> NVRAM 0x1BF 05->07 -> byte=47(alive) -> cmd=c4 -> cmd=f9 -> byte=fb
```
`0xFF` arrives and NVRAM `0x1BF` is rewritten from 5 to 7 **before** `0xF9`
is even transmitted — matching the queue order traced above exactly (`C4`
before `F9`) — and the real reply, `0xFB` (`(0xFB AND 0x0E) - 2 = 0x08`,
table entry 4 of 7 -> country 5, correct), arrives too late: `sub_D5A8B`'s
retry loop has already accepted the `0xFF` on an earlier pass and returned.
Independently verified against the disassembly above with a second country:
`0xFF` decodes to country 7 by the same arithmetic regardless of which
country was actually running, since it does not depend on the real DIP
value at all — only on `0xFF` itself.

**The flip is session-only, and it is the menu's EXIT that causes it.** Two
measurements bound what it costs:

- **A power cycle puts it back.** The same store, booted again without a menu
  visit, reads its DIP country again — `D664D` lets the DIP override the stored
  value on every boot (F11). Measured: a run that opens and exits the menu takes
  `0x1BF` from 4 to 7; the same store booted again, untouched, reads 4.
- **A walk that opens the menu once and never re-enters keeps its country.** The
  re-derivation lives on the exit path (`sub_DD253` -> `DD29E`), so navigating
  with select, scroll and *back* never reaches it. Measured at country 5: the
  store still reads 5 after a menu walk, and the records render in Spanish —
  `SONIDO/VIDEO / JUEGO / TECNICO` and `VOLUMEN / PUBLICIDAD`
  ([`../../dmd/es-menu/`](../../dmd/es-menu/)).

**Confidence:** confirmed for the command sequence (`DD29E`-`DD2B5`, byte for
byte), for `sub_D5C3E`'s accept test and arithmetic (`D5C49`-`D5CFD`, traced
to the same seven-way table F11 names at `D5D01`), for the channel identity
(F6: `C008` state bitmask vs `C0FC` event code, one inbound path), and for
`D664D` persisting whatever `sub_D5A8B` returns (F11). Confirmed live on
traced repro runs reproducing the exact byte sequence the static trace
predicts — including on the **corrected** Z80 timing (4 MHz, IRQ 488.28 Hz),
so the race does not depend on the two constants the driver previously
carried. **Open:** whether a real machine's Z80/80188 pair races the same
way — the 16-tick (F6) timeout and the INT0/8 outbound rate are this
emulation's timing, not measured against real silicon; a logic-analyzer
capture of J1 during a real machine's menu exit would settle it, and would
also settle whether the real machine's own operators have ever observed a
country/language flip after using the service menu (which this finding
predicts they should, on every exit, in every country, until the next
power-up).

**Disposition:** new. No prior hypothesis existed to adjudicate — this is a
firmware behaviour, not a driver bug, and no driver change follows from it:
delivering the `0xFF` accurately (as any faithful emulation of the Z80
reboot must) is what triggers it, and there is no correct place to suppress
that byte without becoming unfaithful to the ROM.

---

## F20 — Full-screen images share the font table's own entry format

**Statement.** ROM1 stores at least one complete 128x32 DMD screen using the
identical entry layout the walked font/glyph table uses (F13's frame
buffers; `docs/dmd_graphics.md`, "Font Entry Structure") — a 6-byte header
`[height, 0x00, width, 0x00, len16_lo, len16_hi]` followed by three
`len16`-byte planes (plane 0, plane 1, mask) — sitting outside the walked
table (`0x20000`-`0x22C2E`) rather than as one of its 224 entries, so it is
not reached by walking from the table's own base and has to be found by
other means (here, by searching the ROM for a captured frame's own bytes).

**The instance, read directly out of the ROM.** Header at `0x24EA4`:
`height=0x20, width=0x10, len16=0x0200` (`=32*16=512`, the same full-screen
dimensions as the already-documented terminator image at `0x22C2E`). Plane 0
at `0x24EAA` (header `+6`), plane 1 at `0x250AA` (`+len16`); each row is
`width=16` bytes, so row 10 of plane 0 falls at `0x24EAA + 10*16 = 0x24F4A`
and row 10 of plane 1 at `0x250AA + 10*16 = 0x2514A`.

**Confirmed against a captured frame, not just against the header
arithmetic.** Reconstructing all 32 rows from these two planes
(`level = 2*plane0_bit + plane1_bit`, F13's own weighting) reproduces
`dmd/en/screens/0023-attract/repr.txt` byte-for-byte, all 32 rows, no
discrepancy. The same content — full or, in one case, a mid-redraw partial
with the already-drawn rows matching exactly and the not-yet-reached rows
still blank — is the settled or in-progress content of three deep
service-menu leaf records in the same corpus: `svc-33` (SEND-REC TEST),
`svc-36` (LIGHT TEST 2), `svc-37` (LIGHT TEST 3). A direct byte search of
`v1_3_02.bin` through `v1_3_05.bin` (the graphics, sound and Z80 ROM images)
for the plane-0 block finds no match in any of them — this image lives only
in ROM1, in the font-table's own chip.

**What this means for the DMD text decoder.** A screen drawn this way
contributes no font-table match, ever, to `scripts/dmd_dump_split.py` or any
other bitmap-matching decoder, because there are no glyphs on it to match —
the panel content is one large pre-composed picture, not characters
assembled from the font table at run time. This is a third class of
"undecoded," distinct from a missing capture and from an unlocated font
(`docs/dmd_graphics.md`'s own "Open items" already documents the unlocated
in-play `PLAYER`/`BALL` font as the second class).

**Confidence:** confirmed for the header, the two verified plane offsets,
and the byte-exact 32-row match against a real captured frame. **Open:**
which specific catalogued ROM string(s), if any, this particular picture
depicts (not read letter by letter); whether every deep service-menu leaf
record uses this mechanism (three are confirmed; `svc-24`, SOLENOID TEST,
shows no new content of any kind across five occurrences even after F14's
record-to-record dwell was stretched 25x, so its own mechanism is
unresolved — see `dmd/README.md`'s Open items); why the same bytes also
surface during ordinary attract-mode play (asset reuse across two contexts
is the simplest reading and is consistent with everything checked, but is
not independently confirmed); and whether the in-play score or any other
still-undecoded screen (`docs/dmd_graphics.md`, "Which face draws the main
player score is not settled") uses this same mechanism — not established
either way, and not to be assumed from this finding alone.

**Disposition:** new. No prior finding addressed whether a DMD screen could
be a picture rather than composed text; this one does, with one directly
confirmed instance and a documented method (byte-search a candidate frame
against both ROM images, then verify the header arithmetic independently)
for checking any other suspected instance.

---

## F21 — The service-menu depth bar is drawn procedurally, not read from a table

**Statement.** The tile-bar/level indicator that renders on several deep
service-menu leaf records (`svc-N`, `back-to-N`) is not glyph-composed: it is
a run of identical solid columns plus one partial column, both stamped
directly from a loop counter with no bitmap ever read. No font-table matcher
can recover text from it, by construction, because there is no stored shape
to match against.

**The mechanism, read directly out of the ROM.** `sub_D0AF8` (`D0AF8`) stamps
one 6-row-tall column at `DI` with a caller-supplied fill byte in `AL`
(`MOV B[DI],AL` / `ADD DI,0x10`, unrolled six times — no table read of any
kind). `sub_D0ACA` (`D0ACA`) reads a column count from work-RAM `4000:114A`
and calls `sub_D0AF8` with `AL=0xFF` that many times, decrementing `DI` by
one byte column each time — i.e. it draws N solid, full-height columns side
by side, purely from a loop counter. A dispatch table immediately above it,
`sub_D0A5D` (`D0A5D`, entries at `D0A94`-`D0AC9`), supplies one of nine
partial-fill bytes (`0x00, 0x80, 0xC0, 0xE0, 0xF0, 0xF8, 0xFC, 0xFE, 0xFF`)
keyed by a second work-RAM cell, `4000:114B` (0-8), giving the bar's leading
edge sub-column precision instead of only whole-column steps — the standard
technique for a smooth level/progress gauge. Both destination cells are the
background plane (`DI = 0x600 + 0x101 + count`, inside F13's `4000:0600-09FF`
window), not the sprite plane text is normally composed into.

Two callers drive the whole mechanism, sharing the same pair of state cells:
`sub_D09BC` (`D09BC`) increments the column count (capped at 100, work-RAM
`4000:1149`) and calls `sub_D0A5D`/`sub_D0ACA` to redraw one notch longer;
`sub_D0A33`'s neighbour at `D09F3`/`D0A02` decrements it and redraws one
notch shorter. This is a general-purpose level-gauge primitive, not a
routine written for one specific menu record — consistent with it recurring
across multiple different `svc-N` pages rather than belonging to just one.

**What actually calls the two callers.** `sub_DD669` (the menu's own
navigation dispatch, F14) reads a switch code, subtracts `0x3F`, and jumps
one of four ways: **exit** (`0x3F`) saves and leaves; **back** (`0x40`,
`sub_DD6DB`) calls the decrement path; **scroll** (`0x41`, `sub_DD6C3`)
calls the increment path; **select** (`0x42`) is a fourth branch, not
traced here. Column count `4000:1149` is never reset between records —
confirmed by grepping the whole listing for every write to it: only the
increment/decrement routines themselves touch it — so the bar's length at
any one record is however many net scroll-minus-back presses the whole
walk has made *so far*, not a value tied to that record specifically. This
is why the bar appears to "grow with depth": a deeper record has typically
taken more navigation presses to reach, not because any record stores its
own target length.

**What this means for the DMD text decoder.** A font matcher finds real
bitmap matches on these pages (the columns this loop stamps collide, at some
fill levels, with real `h=12` glyph shapes in the walked font table) purely
by coincidence: nothing here indexes the font table, or any table, for
shape — the shape is the loop itself. This is a third class of "undecoded,"
distinct from F20's stored-picture case and from an unlocated font: here
there is no stored shape to find in the first place.

**Confidence:** confirmed — both routines, the partial-fill dispatch table,
and `sub_DD669`'s own four-way dispatch are read directly from the listing,
with no inference involved. This settles "which specific quantity" the bar
shows: none — it is a navigation-press counter, not a per-record reading of
volume, brightness, or intensity. Open: `svc-24`'s own record shows no bar
at all rather than whatever length the cumulative counter had reached by
that point in a given walk (every other deep record shows some length) —
not explained by the counter being cumulative alone; see `dmd/README.md`
for what would settle it.

**Disposition:** new. No prior finding addressed the service-menu depth bar;
`dmd/README.md`'s own Open items previously described it only as an
unexplained "growing letter run" coincidentally matching real glyph bitmaps.

---

## F22 — Jupiter's release keys on C44, and the Multiball start drives it

**Statement.** Coil 16, *Sueltabolas de Júpiter*, is fired by one Z80 routine,
`sub_07C3`, reached by exactly four 80188 commands — `0xE2`, `0xEE`, `0xED`
and `0xEF` — plus the service solenoid walk. `0xEE` is the one play uses: the
Multiball start issues it, and its handler **keys on C44**, not on C46. The
two CPUs therefore use different Jupiter contacts — the 80188 counts a lock
from C46, the Z80 releases from C44.

**The coil.** `sub_07C3` (`07C3`) reads the port-`$86` shadow `$C006`, ANDs it
with `0x7F` and writes the result to `$C006` and `OUT ($86)`. Port `$86` is
active LOW (F17), so clearing bit 7 fires coil 16 — F17's own `$86` bit 7. It
also sets `$C017` to `0xFF` and `$C05F` to `0x1E`, a flag and a countdown the
callers below test.

**The five call sites, and the commands that reach them:**

| Site | Routine | Reached by |
|---|---|---|
| `10AE` | inside `sub_1037` | the service solenoid walk — a chain of `sub_06xx`/`sub_07xx` coil routines interleaved with `sub_10E4`, the same shape as `sub_2C87` |
| `2A0C` | its own two-instruction handler | 80188 command **`0xE2`** — a bare fire-and-return |
| `2B97` | `sub_2B86` | 80188 command **`0xEE`** |
| `2C54`, `2C5C` | both inside `sub_2C41` | `sub_2BC7`, command **`0xEF`** (ball search), and `sub_2BEB`, command **`0xED`** (the trough check) |

Command-to-handler mapping is read from the Z80's own 256-entry table at
`$2000`, indexed by command byte: entry `0xE2` is `0x2A0C`, `0xEE` is
`0x2B86`, `0xEF` is `0x2BC7`, `0xED` is `0x2BEB`.

**`sub_2C41` fires the coil on both arms of its own test.** It strobes switch
column 4, ANDs the result with `0x07` — the three Jupiter contacts C44, C45
and C46 — and compares against `0x07`. All three closed returns `0xFF`, any
other state returns `0x00`, but `sub_07C3` is called first either way. The
three-contact test sets the *reply*, not whether the ball is released.

**`sub_2B86` (`0xEE`) keys on C44 alone.** It tests bit 0 of column 4 — C44,
JUPITER 1. **The matrix is active low**, so a set bit is an OPEN contact: the
Z80 reads `IN ($02)` as the complement of the closed set, and `sub_2C1F`'s own
trough test only reads as F15 describes under that polarity. The handler
therefore returns at once when C44 is **open** — no ball there to release —
and with a ball resting on C44 it fires the coil, spins until that contact
**opens** (the ball has gone), and then waits for the next ball to arrive at
C44 or for its own `$C017`/`$C05F` timeout.

**What drives it in play: the Multiball start.** The lock handler's count-2
arm (`D9E7E`) calls `sub_DB716`, which reaches `sub_DC6AC`. That routine
issues `0xEE`, arms a ~500-tick window in `4000:1139`, and polls `sub_DC675`
until the window runs out; on failure it **re-issues `0xEE` and repeats,
unbounded**. `sub_DC675` accepts only two switch codes — `0x21` and `0x22`,
TRAGABOLAS 2 and TRAGABOLAS 1 — so **a released ball is confirmed by reaching
a scoop**; code `0x43`, the ball-over sensor, calls `sub_D92C0` and does not
count as confirmation.

**The start sequence is a chain of blocking waits**, each needing a ball event
before the mode can run, which is why a released ball that goes nowhere stalls
it indefinitely:

| Where | Waits for |
|---|---|
| `sub_DC6AC` (from `DB7B4`) | the released ball to report at a scoop, `0x21`/`0x22` |
| `sub_DC47E` (via `sub_DC636`) | the serve it issues with `0xE9` to answer `0x45` or `0x4A` |
| `sub_DB457` (`DB47F`-`DB4A8`) | any dispatched switch event, during the animation |
| `DB7E5` | one more dispatched switch event |

Only past the last of those does `DB822`/`DB82A` light `LD2` and `LR21` — the
Jackpot and Superjackpot lamps — and `sub_DC2A6` release what Jupiter still
holds.

**What this settles about §3.2.6.** Little Multiball's release — the rules'
"putting that ball into scoop 1 releases the Jupiter ball" — **has no code
path in this firmware**. Scoop 1's handler `sub_D9B91` reaches `sub_DB503`
through `D9C8A` when its three gates are clear (mode `[413C:00F4]` = 0,
`[413C:010F]` neither 1 nor 2, `[4134:0027]` = 0 — all three measured at 0
throughout ordinary play, so the path is open, and `[413C:010F]` is read at
`D9C66`/`D9C70` and **written nowhere in the image**). But `sub_DB503` only
pushes `0xFE`, moves lamps and clears the mode: it issues none of the four
commands that reach coil 16. Since those four are the complete set, no
scoop-1 collect can release a held ball, however the gates fall. The release
exists for the two-ball Multiball start and for ball recovery, and nowhere
else.

**Confidence:** confirmed. Every call site, table entry and wait is read
directly from the listing and the ROM image. The behaviour is confirmed
running as well: with a ball resting on C44 the coil fires, the lock counter
decrements on the scoop report, and the mode cell `[413C:00F4]` goes 9 to 0 —
`sub_DB716` running to its end — where it never did while the locked balls sat
on C46 and C45.

**Disposition:** answers the rules page's own open question on coil 16
(`docs/iomoon_game_rules.md`, *Open questions*) in full: the coil is not dead,
it is the Multiball start that drives it, and it acts on C44. It also
identified a simulator defect, since fixed — PinMAME rested locked balls on
C46, so C44 never closed, so the Z80 answered every one of the nine `0xEE`
issues in a measured run with "nothing to release" and the mode never
started.

---

## F23 — The upper flipper is driven from the right button, and its auto-fire is unused

**Statement.** The mini upper flipper has no button of its own: its coils are
fired from inside the **right** flipper's own service routine, so it flips
whenever the right button is pressed. The Z80 also carries commands that let the
80188 fire any flipper by itself, and **this firmware issues none of them**.

**The right button drives both.** `sub_12D8` is the right flipper's service
routine, called from two places (`0D92` in the main loop and `2DF9` in the test
loop), each as `IN A,($03)` / `BIT 2,A` / `CALL Z` — port `0x03` bit 2 is the
right button, active low (F16's `0x42`). The routine handles the right flipper
first (`12EB`-`130E`, keyed on C10's cut-out at column 0 bit 7), then falls
straight into the **upper** flipper at `1311`: gate on `[$C05B]`, read column 1,
`BIT 2` — C19, U.C.FLIPPER, the upper flipper's own cut-out — and fire power
`sub_067F` with it open or hold `sub_06A5` with it closed. Nothing between the
two sections tests a second button. `sub_1292`, the left flipper's routine
(`BIT 3`), has no such second half.

`[$C05B]` is an enable, not a trigger: the only writers are the upper-flipper
self-test at `140E`/`1435`, which clears it, exercises the coil directly and
sets it again, and the bulk init at `05AC`.

**The auto-fire path exists and is dead.** The Z80's command table gives the
80188 direct control of every flipper coil:

| Command | Handler | Fires |
|---|---|---|
| `0xCB` / `0xCD` / `0xCE` | `sub_2895` / `sub_2919` / `sub_2922` | left power / hold / off |
| `0xCC` / `0xCF` / `0xD0` | `sub_28D7` / `sub_292B` / `sub_2934` | right power / hold / off |
| `0xD1` / `0xD3` / `0xD4` | `sub_293D` / `sub_297F` / `sub_2988` | **upper** power / hold / off |

All nine are gated on `[$C068]`. **None of the nine appears anywhere in the
80188 image**: a search of every immediate push feeding `qout_push` finds zero
occurrences of `0xCB`-`0xD4`, against five for `0xEE`, which is known to be
issued. So a switch-triggered auto-flip is within the I/O board's vocabulary but
is not used by V1.3's game code. (A command pushed from a table rather than an
immediate would not be caught by that search; no such table is known.)

**Confidence:** confirmed for the button path and the command table, both read
directly from the listing and the ROM's own 256-entry table at `$2000`. The
"never issued" half is confirmed to the strength of an exhaustive immediate
search, with the table caveat above.

**Disposition:** new. It also corrects a driver-side assumption: because the Z80
fires the upper flipper from the right button, PinMAME reproduces it already,
and the absence of `FLIP_SW(FLIP_UL)` costs only the C19 cut-out switch, not the
flipper.

---

## What changed

**Counting basis.** Three facts — F2, F13 and F14 — have **split
dispositions**, because the prior claim was right about one thing and wrong
about another. They are counted **per hypothesis half** and dual-listed
below, so a split fact appears under both of its halves. 15 facts therefore
produce **18 disposition entries**.

| disposition | entries | n |
|---|---|---|
| **confirmed** | F1; F5 (`0x41496` was right); F6; F8; F9; **F13's** `7000:0000`/`0200` two-plane layout and plane-0-as-MSB weighting | 6 |
| **corrected** | F3 (NMI is the inbound-byte handler, not the DMD handler); F7 (ports `0x82`/`0x83`/`0x84` roles swapped relative to the old driver; 16 driver bits, not 18 solenoids); F10 (NVRAM is the segment-`5040` window); F12 (`4000:1158` is the Z80 command queue); **F2's** banking half — PCS0 *bits 0-2* page ROM2 into segment `6000`, so the intuition "PCS0 banks a graphics ROM" was right | 5 |
| **rejected** | F4 (the marker byte stream); **F2's** *bits 4/5 over segment `0000`* form — segment `0000` is not banked at all, bits 3/4 gate the NVRAM window and bit 5 is `/OKCS`; **F13's** `0xA0200` bit-3 frame strobe and the bit inversion; **F14's** earlier project guesses (`0x3F` = select, Bike-Race-style scroll/select, `0x33` opens the menu, menu paced by PIC markers) | 4 |
| **no prior hypothesis to adjudicate** | F11 (credit/coin entry points); **F14's** own open question, answered: code `0x3F` opens the menu; F15 (ball handling — four of F5's 48 physical contacts identified) | 3 |

Cross-check: 6 + 5 + 4 + 3 = 18 entries over 15 facts, with F2, F13 and F14
each contributing two. Every per-fact *Disposition* line above agrees with
the row it appears in.

**Open, and stated as open — 5 facts carry gaps, 6 clauses (F9 has two).**
**F11's clause was CLOSED on 2026-09-03 (Task 16) and is struck below.**

| # | fact | gap |
|---|---|---|
| 1 | F3 | the INT0 source and rate — everything time-based hangs off it; a recommended-not-confirmed starting value (~290 Hz) is given, but see the 2026-09-02 emulation result in F3: 290 Hz and 145 Hz are both unservable against the handler's measured cost, the driver ships 72.5 Hz as a serviceability constant matching no candidate, and the per-plane *source* hypothesis is weakened by the same measurement |
| 2 | F2 | the *bit order* of the PCS0 bits-0-2 page selector: the window and the seven pages are confirmed, the A16-A18 wiring is inferred. **Narrowed by the IC7 dump:** the page bits never reach the PAL, so only a scope or a trace of IC40 -> IC11 settles it |
| 3 | F5 | the physical switch behind each code. *Narrowed 2026-09-03 to 44 of the 48 MATRIX positions:* column 0 bits 0-3, codes `0x0A`-`0x0D`, are the ball-handling contacts and are identified in **F15**; and all six cabinet codes are now identified from what consumes them — `0x32` coin mech, `0x3E` tilt, `0x3F` test, `0x40` START, `0x41`/`0x42` the flipper buttons. Note `0x41`/`0x42` are emitted **only in test mode** (gated on `C068`/`C069`); in play those two bits fire the port-`0x85` coil pairs at `sub_05C7`/`sub_05ED` and send nothing. |
| 4 | F6 | whether the Z80's two outbound strobes reach one 80188 latch |
| 5 | F9 | the OKI latch bit-to-pin mapping. **Narrowed by the IC7 dump:** the PAL supplies only the IC50 latch clock (`/OKCS` = `/PCS6` · `/WR`), so the byte's path to the OKI's pins wants a scope or a trace of IC50 |
| 6 | F9 | the OKI duration-table extent past sample ~28 |
| ~~7~~ | ~~F11~~ | ~~the credit-*balance* NVRAM cell~~ — **closed 2026-09-03**: it is the F10 triple `0x83`/`0x116`/`0x20C` with the sub-credit remainder in `0x84`/`0x117`/`0x20D`, cached in `413C:00D4`; the coin path is code `0x32` -> `4000:1144` -> `sub_D800A` -> the per-country pricing routine. See the section added to F11. |

---

## Audit against the old `sleic` branch driver

Compared against `git -C pinmame show sleic:src/wpc/sleic.c` — the `iomoon_*`
handlers and `MACHINE_DRIVER_START(SLEIC2)`.

| fact | old branch | |
|---|---|---|
| **F1** chip selects | **diverges** — no chip-select emulation at all; `SLEIC2_80188_readmem` hard-codes a map that contradicts the boot table (see F2 row). Timer 0 is not modelled; `MDRV_CPU_PERIODIC_INT(SLEIC_irq_i80188, 120)` is a single unexplained 120 Hz IRQ standing in for both timer0 (99.2 Hz) and INT0. |
| **F2** LMCS + graphics bank | **diverges** — maps ROM2 flat at `0x00000-0x7FFFF` and ROM1 at `0x80000-0xFFFFF`. Should be ROM1 low half at `0x00000-0x3FFFF`, ROM1 high half at `0xC0000-0xFFFFF`, and a **banked** ROM2 page at `0x60000-0x6FFFF` selected by PCS0 bits 0-2. **Regression risk for Task 8:** `{0x00000,0x6ffff, MRA_ROM}` over a flat ROM2 image accidentally pins segment `6000` to ROM2 **page 6**, statically — so some graphics render today *because of* the wrong map. Replacing it with the correct banked window will change what page 6's callers show and will make the other six pages appear for the first time; do not read "different pixels than before" as a regression without checking the selector. |
| **F3** interrupts | **diverges** — no IVT-backed NMI/timer0/INT0 model; one periodic IRQ on line 0 at 120 Hz. The alternating INT0 half-frames are not modelled, so DMD composite/blit and the FM tick never run in the right ratio. |
| **F4** markers | **diverges, and this is the big one** — the branch's `iomoon_dmd_r` returns 0 for the whole `0xA0000-0xA0FFF` window; the local (unpushed) work described in `CLAUDE.md` added a fake `0x47`/`0x45`/`0x46` marker machine on `0xA0100`. Both are wrong: `0xA0100` must return the pending Z80->80188 byte and nothing else. |
| **F5** switch codes | **partly agrees** — `IOMOON_SHARED_OFF_SWCODE 0x1496` is the right address, correctly annotated `413C:00D6`. But `iomoon_swcode_r`/`iomoon_z80_to_188_mailbox` *write* it directly from the Z80 port handler, bypassing the NMI, the FIFO and `sub_D7453`. The 48+5 code map is absent; `SWITCH_UPDATE(SLEIC2)` invents a `swMatrix[9]`/`[10]` layout with no basis in the ROM. |
| **F6** J1 | **diverges** — modelled as shared RAM plus a one-byte mailbox. Port `0x01` returns a constant `0x02` (always ready), the port-`0x81` strobes are read as "bit 0 = OKI strobe, bit 1 = mailbox" (both wrong: bit 1 is data-valid, bit 2 and bit 5 are the two strobes), there is no 80188->Z80 path at all (no PCS1 latch, no Z80 NMI), and no boot `0x47` handshake — so the firmware cannot get past `D2F59` by design. |
| **F7** lamps/drivers | **diverges** — `iomoon_z80_write` treats port `0x82` as the lamp column, `0x83`/`0x84` as two lamp data bytes and `0x87` as the switch strobe. Fresh evidence: `0x82` = switch column strobe, `0x83` = lamp column strobe, `0x84` = lamp data, `0x87` = direct-input index + two flag bits. Solenoids are written straight from ports `0x85`/`0x86` without the active-low inversion, so every coil reads as permanently on at reset (`0xFF`). |
| **F8** YM3812 | **partly agrees** — `MDRV_SOUND_ADD(YM3812, ...)` is present at 4 MHz, but `0xA0280`/`0xA0281` fall into `iomoon_dmd_w`, which only logs them. No register/data decode, so no FM ever reaches the chip. |
| **F9** OKI | **diverges** — `iomoon_z80_write` calls `OKIM6376_data_0_w` from the **Z80** when port-`0x81` bit 0 is set. The Z80 drives no sound chip; the OKI is written by the 80188 at `0xA0300` with the `0xA0000` bit-5 strobe, which the branch routes into the logging DMD handler. |
| **F10** NVRAM | **diverges** — `generic_nvram` is mapped at `0x10100-0x10900` in `SLEIC_80188_writemem`, an address IO Moon never touches, and `SLEIC2_80188_writemem` maps no NVRAM at all (its own comment admits "The 28C64A NVRAM location ... is not yet known"). It is segment `5040` behind the PCS0 bit-3/4 gate. |
| **F11** credits | **diverges** — with no NVRAM window there is nowhere for the audits to persist; the credit-runaway symptom recorded in `CLAUDE.md` is consistent with counters living in volatile RAM that the fake mailbox re-triggers. |
| **F12** sound commands | **diverges** — the branch has no outbound `4000:1158` -> PCS1 -> Z80 path, so no lamp, driver or mode command ever reaches the Z80, and `sub_D0B70`/`fm_song_select` are never exercised because the firmware does not get that far. |
| **F13** DMD | **partly agrees** — `iomoon_submit_dmd_frame` reads `0x70000-0x701FF` / `0x70200-0x703FF` as plane 0 / plane 1 with plane 0 as MSB, which is right. Three problems: it is triggered by `offset == 0x200 && (data & 0x08)`, a strobe that fires once at boot (F13), so frames are submitted once; it applies `^ 0xFF` to both planes, which the firmware does not justify; and `{0x70000,0x703ff, MRA_RAM}` is carved between the two `MRA_ROM` regions `{0x00000,0x6ffff}` and `{0x70400,0x7ffff}`, so the staging buffer is a RAM island inside declared ROM. |
| **F14** service menu | **diverges** — no menu path can work, because it depends on F5 (code `0x3F` arriving through the real dispatcher) and on F6 (the `0xED` -> `0x45`/`0x46` request/response). The branch has neither. The "menu flickers and collapses" symptom in `CLAUDE.md` is explained by F4: the fake marker machine was injecting bytes the poll routines dequeued and discarded. |

**Nothing in the old `iomoon_*` code should be carried forward except three
things**: the `0x41496` address (F5), the `7000:0000/0200` plane split and
plane-0-as-MSB weighting (F13), and the Z80 clock/IRQ-rate comment
(8 MHz, `8000000/8192` ~ 977 Hz) — which this baseline neither confirms nor
refutes, since the Z80 IRQ source is external to both ROMs.
