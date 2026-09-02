# IO Moon — driver contract, F1..F14

Fourteen numbered facts extracted from the **2026-09 fresh baselines** in this
directory. Later driver tasks reference them by number.

**Sources, and only these sources.** Every address citation below was read out
of one of:

| source | what |
|---|---|
| `asm/baseline-2026-09/iomoon_80188.lst` | 80188 game/sound ROM (`V1 3_01.bin`), 83 regions, 29810 instructions, 3-way cross-verified |
| `asm/baseline-2026-09/iomoon_z80.lst` | Z80 I/O ROM (`V1 3_05.bin`), 12 regions, 4760 instructions, 2-way cross-verified |
| `asm/pic16c57_annotated.asm` | IC23 PIC16C57 raster program, 3-tool verified (150 words) |
| the ROM images themselves | raw byte reads, quoted with the offset |

`docs/*.md`, `asm/80188_annotated.asm`, `asm/z80_annotated.asm` and the old
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
the *bit order* of the selector (whether bit 0 is A16) is **inferred** — it
would take IC7 or a scope to prove the wiring is not reversed. A driver
should implement it as a table of seven base offsets so a swap is a one-line
change.

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
   pin) is never sampled, and there is no data port. Its own OPEN QUESTIONS
   item 2 says the markers "are NOT emitted by this program".

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

**Confidence:** confirmed. The *physical* switch behind each code is not
established for the 48 matrix positions — that needs the wiring diagram or the
service manual's switch list; the codes and their matrix positions are exact.
The six **cabinet** codes were identified on 2026-09-03 from what consumes
them (F11, F14): `0x32` the coin mechanism, `0x3E` tilt, `0x3F` test /
service-menu, `0x40` START, `0x41`/`0x42` the flipper buttons.

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
PCS3 bit 0 correspond to on J1 (needs IC7/IC8), and whether the two Z80
outbound strobes reach the *same* 80188 latch. On the latter, the balance of
evidence says yes: `0xA0100` is the only inbound read in the whole 80188 ROM,
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
is inferred and still wants the IC7 PAL.

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
`2BEB` reads **port `0x04` bit 5** to choose.

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

## What changed

**Counting basis.** Three facts — F2, F13 and F14 — have **split
dispositions**, because the prior claim was right about one thing and wrong
about another. They are counted **per hypothesis half** and dual-listed
below, so a split fact appears under both of its halves. 14 facts therefore
produce **17 disposition entries**.

| disposition | entries | n |
|---|---|---|
| **confirmed** | F1; F5 (`0x41496` was right); F6; F8; F9; **F13's** `7000:0000`/`0200` two-plane layout and plane-0-as-MSB weighting | 6 |
| **corrected** | F3 (NMI is the inbound-byte handler, not the DMD handler); F7 (ports `0x82`/`0x83`/`0x84` roles swapped relative to the old driver; 16 driver bits, not 18 solenoids); F10 (NVRAM is the segment-`5040` window); F12 (`4000:1158` is the Z80 command queue); **F2's** banking half — PCS0 *bits 0-2* page ROM2 into segment `6000`, so the intuition "PCS0 banks a graphics ROM" was right | 5 |
| **rejected** | F4 (the marker byte stream); **F2's** *bits 4/5 over segment `0000`* form — segment `0000` is not banked at all, bits 3/4 gate the NVRAM window and bit 5 is `/OKCS`; **F13's** `0xA0200` bit-3 frame strobe and the bit inversion; **F14's** earlier project guesses (`0x3F` = select, Bike-Race-style scroll/select, `0x33` opens the menu, menu paced by PIC markers) | 4 |
| **no prior hypothesis to adjudicate** | F11 (credit/coin entry points); **F14's** own open question, answered: code `0x3F` opens the menu | 2 |

Cross-check: 6 + 5 + 4 + 2 = 17 entries over 14 facts, with F2, F13 and F14
each contributing two. Every per-fact *Disposition* line above agrees with
the row it appears in.

**Open, and stated as open — 5 facts carry gaps, 6 clauses (F9 has two).**
**F11's clause was CLOSED on 2026-09-03 (Task 16) and is struck below.**

| # | fact | gap |
|---|---|---|
| 1 | F3 | the INT0 source and rate — everything time-based hangs off it; a recommended-not-confirmed starting value (~290 Hz) is given, but see the 2026-09-02 emulation result in F3: 290 Hz and 145 Hz are both unservable against the handler's measured cost, the driver ships 72.5 Hz as a serviceability constant matching no candidate, and the per-plane *source* hypothesis is weakened by the same measurement |
| 2 | F2 | the *bit order* of the PCS0 bits-0-2 page selector: the window and the seven pages are confirmed, the A16-A18 wiring is inferred |
| 3 | F5 | the physical switch behind each code. *Narrowed 2026-09-03 to the 48 MATRIX positions only:* all six cabinet codes are now identified from what consumes them — `0x32` coin mech, `0x3E` tilt, `0x3F` test, `0x40` START, `0x41`/`0x42` the flipper buttons. Note `0x41`/`0x42` are emitted **only in test mode** (gated on `C068`/`C069`); in play those two bits fire the port-`0x85` coil pairs at `sub_05C7`/`sub_05ED` and send nothing. |
| 4 | F6 | whether the Z80's two outbound strobes reach one 80188 latch |
| 5 | F9 | the OKI latch bit-to-pin mapping |
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
