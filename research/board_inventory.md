# IO Moon — Physical Board Inventory from Photographs

> **Status note.** This file records the *original* photo-by-photo research pass,
> taken with the boards in the backbox and with many markings only partly legible.
> Every entry it flags "likely" or "uncertain" has since been settled by direct
> inspection, and the settled identifications live in the per-board IC inventories
> ([`../docs/board_011-029A_ics.md`](../docs/board_011-029A_ics.md) and
> [`../docs/board_011-030A_ics.md`](../docs/board_011-030A_ics.md)), which are the
> canonical reference. **Where this file and those disagree, those are right.**
> The ones that matter:
>
> | Position | Reading in this file | Actual part |
> |---|---|---|
> | IC51 (16-bit board) | "8-pin device, not the 42-pin OKI" | **OKI MSM6376**, PDIP-42 |
> | IC23 (16-bit board) | "18-pin, PIC16C54" | **PIC16C57-HS/P**, PDIP-28 — dumped, [`../roms/PIC16C57/`](../roms/PIC16C57/) |
> | IC7 (16-bit board) | "an additional PIC16C5x" | **AMD/MMI PAL20L10ACNS** — the 80188 chip-select glue |
> | IC34 (16-bit board) | "possibly a second PIC" | **TI CD74HC151E**, an 8-to-1 multiplexer |
> | "IC57" (16-bit board) | "an undocumented PIC" | no such position; it was IC7 |
> | IC8 (16-bit board) | "74LSxx or PAL16L8" | **DM74LS74AN**, a dual flip-flop |
> | IC50 / IC55 (16-bit board) | "32K×8 SRAM, DMD framebuffers" | 74LS273 latch (IC50, the OKI phrase latch) and 74LS139A decoder (IC55) |
> | IC15 (Z80 board) | "MAX699" | **ADM699AN** (the MAX699 is IC6 on the 16-bit board) |
> | IC10/IC11 sticker "V1.3-02" vs "V1.2-04" | "a revision mismatch worth dumping" | the sticker convention is `V<set>-<chip number>`, so `V1.3-02` is chip 02 of the V1.3 set — not a sub-revision |
>
> There is exactly **one** PIC on the machine and there are **two** PALs; see
> [`../docs/chips_to_dump.md`](../docs/chips_to_dump.md). The eleven `IMG_20260527_XXXXXX.jpg` files originally
> photographed during this pass have since been superseded by five
> high-resolution composite board photographs in [`../images/`](../images/):
>
> | New image                                       | Original photos it consolidates                                                              |
> |-------------------------------------------------|----------------------------------------------------------------------------------------------|
> | `overview_backbox_all_boards.jpg`               | `IMG_20260527_212447.jpg` (full backbox overview)                                            |
> | `80188_board_011_029A.jpg`                      | `IMG_20260527_212505.jpg`, `_212802.jpg`, `_212824.jpg`, `_212828.jpg`, `_212830.jpg`, `_212833.jpg` |
> | `z80-sleic-011-030A.jpg`                        | `IMG_20260527_212606.jpg`, `_212607.jpg`                                                     |
> | `driver_board_sleic_011-027A.jpg`               | `IMG_20260527_212637.jpg`                                                                    |
> | `sound_amplifier_board_sleic_011-024.jpg`       | *(audio amplifier board, not photographed in the original pass)*                              |
>
> Within this document the original `IMG_XXX.jpg` filenames have been replaced
> by the new consolidated filenames. The `+5 V / lamp / solenoid power supply`
> photo (`IMG_20260527_212457.jpg`) below has no high-resolution replacement yet.

This document records what is *visible on the actual boards*. Where a marking
was difficult to read, the entry is flagged with "likely" / "uncertain" so the
caller knows which entries still need confirmation by direct inspection or by
re-photographing the chip at a tighter angle.

The photographs were taken with the boards still wired into the backbox, so
some chips are partially obscured by ribbon cables and the right-side
silkscreen border of the 16-bit board reads "SLEIC-PETACO 011-" with the
trailing digits clipped. The 8-bit board's silkscreen "SLEIC-PETACO 011-030A"
is fully visible at the right edge of the consolidated `z80-sleic-011-030A.jpg`
photograph.

---

## Per-image inventory

### 1. `overview_backbox_all_boards.jpg` — full backbox overview

Shows the entire head with all five major PCBs visible. Useful for layout
orientation; chip-level reading impossible at this zoom.

| Region of image | Board |
|-----------------|-------|
| Top-left | Audio amplifier (011-024) — small green PCB, large electrolytics, finned heatsinks |
| Top-right | Plasma display power supply (011-023) — row of TW3/TW6 spade connectors at the top edge |
| Centre-left | CPU 16-bit board (011-029A) — PLCC68 visible mid-board |
| Centre-right | CPU 8-bit board (011-030A) — Z80 board, ribbon cables exiting left and bottom |
| Bottom-centre and bottom-right | Drivers board (011-027A) — bank of TO-220 power transistors |
| Inter-board cabling | 20-pin ribbon between J1 (16-bit) and J3 (8-bit) visible crossing the gap |

No chip-level entries possible from this image.

### 2. `IMG_20260527_212457.jpg` — +5 V / lamp / solenoid power supply (cabinet)

This is the cabinet PSU board (designator `011-028` per service manual, but
designator not visible on this photo). Components visible:

| Component | Description |
|-----------|-------------|
| 2× large electrolytic capacitors | Bulk filter caps (likely 10000 µF or similar) |
| Bridge / discrete rectifier diodes | 4× large axial diodes — discrete bridge rectifier |
| 2× heatsink-mounted TO-220 regulators | Linear regs (likely LM7805 / LM317 — labels not visible from this angle; candidate datasheets: [LM7805](../datasheets/candidate_lm7805.pdf), [LM317](../datasheets/candidate_lm317.pdf)) |
| 2× cartridge fuses | In-line, output protection |
| Bottom-edge daughter card | Small green PCB with one 8-pin IC visible — likely the +24 V / +44 V regulator or status / OK monitor |

No DIP-packaged logic ICs are present on this PCB beyond the daughter card.

### 3. `80188_board_011_029A.jpg` — CPU 16-bit board (011-029A), full board overview

Wide shot of the entire 011-029A board. Useful for confirming the layout
described in figure 7-1 (page 94) of the service manual. Silkscreen
"SLEIC-PETACO 011-..." visible right edge, partially clipped.

Layout observed:

```
Top edge:    J2 (14-pin ribbon to plasma display) ----- IC2/IC3/IC4/IC5 (20-pin DIPs)
                                                        |
                                                        IC8, OSC1
                                                        IC22, IC21, IC20
                                                        JP7   IC23 (PIC, socketed)
                                                        IC30, IC31, IC32, IC33, IC34, IC55
            IC1 (80188-10 PLCC68)                       IC50, IC55 (DMD framebuffer SRAMs)
                                                        IC10, IC11 (UV EPROMs, windowed)
                                                        IC52, IC53 (sound EPROMs, windowed)
                                                        IC54 (32-pin socket, likely unpopulated)

Bottom edge: IC12 (24-pin SRAM)  IC13 (32-pin EMPTY socket)  IC14 (28C64A EEPROM)
            IC60 (YM3812, POPULATED)  IC56/IC50/IC45/IC46 (74LS glue)
            IC7 (PAL20L10, read as "IC57" in this pass)  IC61/IC62/IC63 (8-pin)
            J1 (20-pin ribbon header to Z80 board) at right
            J3 (audio output) at right
```

Chip-level identification deferred to the close-up images that follow.

### 4. `z80-sleic-011-030A.jpg` — CPU 8-bit board (011-030A), full board overview

Wide shot of the Z80 board. Silkscreen `SLEIC-PETACO 011-030A` clearly visible
along the right edge. White paper tape covers IC6 socket area.

| Region | Visible components |
|--------|--------------------|
| Top-centre | SW40 8-position blue DIP switch |
| Top-centre, right of SW40 | IC8 (20-pin DIP — the documented PAL16L8) |
| Right side | IC15 (8-pin DIP, top) — ADM699AN watchdog supervisor; IC5 (28-pin UV EPROM, windowed) — `IO MOON V1.2-04`; IC6 socket (covered by tape — population status indeterminate from this photo) |
| Centre | IC1 — `GoldStar Z0840004PSC` Z80A 40-pin DIP |
| Left | Column of 8-pin DIPs (resistor packs or comparators) and 16-pin DIPs (74LS244 / 74LS373 buffers) along ribbon edge |
| Bottom | IC41, IC51 — two 18-pin DIPs (ULN2803A driver arrays) |
| Bottom-left | Multiple ribbon connector headers (J2, J4, J6, J7, J8) |
| Bottom-right | X10 8 MHz crystal can |

### 5. `z80-sleic-011-030A.jpg` — CPU 8-bit board (011-030A), variant angle

Same board as image 4, very similar angle, very slightly closer crop. Same
identifications apply. The two views combined give clearer reads on:

- IC1: `GoldStar Z0840004PSC` (Z80A, 4 MHz nominal — but with the 8 MHz X10
  crystal divided by 2 internally this is the standard Z80 clocking)
- IC5: 28-pin UV-erasable EPROM, white quartz window visible, paper label
  reads `IO MOON V1.2-04`
- IC8: 20-pin DIP, suspected PAL16L8 (the printed part number on top is not
  legible in either image — needs a focused close-up)
- IC15: 8-pin DIP near top edge — ADM699AN (Analog Devices watchdog supervisor)
- IC41, IC51: bottom row, 18-pin DIPs — ULN2803A

Approximate full chip list visible (close-ups would let me read each one):

| Ref | Package | Part | Notes |
|-----|---------|------|-------|
| IC1 | PDIP-40 | Z80A (GoldStar Z0840004PSC) | I/O CPU |
| IC5 | PDIP-28, windowed | 27C256 — `IO MOON V1.2-04` | Z80 ROM |
| IC6 | PDIP-28 socket | (covered by tape; population unclear) | "Extended routines" socket per asm |
| IC7 | PDIP-24 | 6116 SRAM (assumed, label not readable) | Z80 work RAM |
| IC8 | PDIP-20 | PAL16L8 (assumed, label not readable) | I/O decode |
| IC15 | DIP-8 | ADM699AN | Watchdog supervisor |
| IC41 | PDIP-18 | ULN2803A | Driver buffer |
| IC51 | PDIP-18 | ULN2803A | Driver buffer |
| SW40 | DIP switch | 8-position | Config |
| X10 | HC-49 can | 8 MHz crystal | Z80 clock |
| (~30 unlabelled 14/16/20-pin DIPs) | 74LSxx | 74LS244 / 74LS373 / 74LS138 family | Glue logic |

### 6. `driver_board_sleic_011-027A.jpg` — Drivers board (011-027A)

Visible features:

- Multiple TO-220 power transistors mounted to L-brackets (typical Darlington
  power switches — likely TIP122 / BD679 / 2N6044 family). Exact PN not
  readable from this angle. Candidate-family datasheets (unconfirmed):
  [TIP122](../datasheets/candidate_tip122.pdf),
  [BD679](../datasheets/candidate_bd679.pdf),
  [2N6040 (2N6044 family)](../datasheets/candidate_2n6040.pdf).
- Series base/emitter resistors visible in a regular grid on the right side.
- Two ribbon-cable headers at top (signals in from CPU board).
- Solenoid / lamp blade-output connectors at the bottom edge.
- One PDIP-14 logic IC near the top-centre marked
  `MALAYSIA 9140K / 3910103-008 / 1474115DA` — likely a 74LSxx series chip
  with the part number absent / stamped over. The "MALAYSIA" location and
  date-code style is consistent with TI-Malaysia or NS-Malaysia production.
- No microcontroller or programmable logic visible on this board.

The drivers board is purely an analog/power switching stage; no firmware is
involved.

### 7. `80188_board_011_029A.jpg` — CPU 16-bit board, slightly oblique overview

Another full-board view of 011-029A. Same chips as image 3 but a different
camera angle that lets me see:

- The 32-pin DIP socket IC13 is **clearly empty** — through-hole pins
  visible, no chip inserted.
- The 32-pin DIP socket IC54 is **clearly empty** — same observation.
- IC12 (32-pin DIP in the same column as IC13) is **populated** with a
  through-hole IC (label not readable from this angle).
- The 80188 PLCC68 (IC1) and a 100-pin square chip below-left of it are
  visible.

### 8. `80188_board_011_029A.jpg` — close-up: bottom-right of 16-bit board (sound / output)

Excellent close-up of the YM3812 / OKI / glue region. Reading silkscreen
labels paired with chip top-marks:

| Ref (silkscreen) | Visible top-mark | Best identification | Package | Notes |
|-------|----------|---------------------|---------|-------|
| IC60 | `YAMAHA / YM3812 / JAPAN` | **Yamaha YM3812 (OPL2)** | PDIP-24 | **POPULATED** — chip clearly present, not a vacant socket. |
| IC56 | `SN74LS373AN` (TI) | 74LS373 octal latch | PDIP-20 | Standard glue |
| IC50 | `SN74LS273N` (TI) | 74LS273 octal flip-flop | PDIP-20 | |
| IC45 | `SN74LS273N` (TI) | 74LS273 octal flip-flop | PDIP-20 | |
| IC46 | (small DIP, ~14-pin) | 74LSxx (text not fully readable) | PDIP-14 | |
| IC62 | `LGS GD74...` (LG) | 74-series buffer, LGS branded | PDIP-14 | |
| IC51 | small 8-pin SOIC / DIP visible just above IC62 — **NOT a 42-pin chip** | 8-pin op-amp or DAC (likely audio output buffer); **NOT the OKI MSM6376** | SOIC-8 / DIP-8 | See "OKI MSM6376 finding" below. |
| IC63 | small 8-pin DIP top-right | Likely X9103 digital pot OR YM3014 DAC | DIP-8 / SOIC-8 | |
| IC64 | small 8-pin DIP top-right | Same family as IC63 (the other of X9103 / YM3014) | DIP-8 | |
| IC7 (silkscreen at lower-left of this image) | 24-pin DIP, marking not legible at this resolution | **AMD/MMI PAL20L10ACNS** — the 80188 chip-select glue (settled by direct inspection) | PDIP-24 | Not a PIC; see [`../docs/chips_to_dump.md`](../docs/chips_to_dump.md) |
| IC9 (next to IC7) | `74LS138` style | 74LS138 decoder | PDIP-16 | |
| IC44 | `74LSxx` | 74LS-series | PDIP-14 | |
| IC43 | `74LSxx` | 74LS-series | PDIP-14 | |

> **No 42-pin DIP is identifiable in this photograph**, which is a limitation of
> the shot rather than of the board: `IC51` **is** the OKI MSM6376 in a PDIP-42,
> confirmed by direct inspection and recorded in
> [`../docs/board_011-029A_ics.md`](../docs/board_011-029A_ics.md). The 8-pin
> package read here as "IC51" is one of the small analogue parts beside it.

### 9. `80188_board_011_029A.jpg` — close-up: upper-centre/left of 16-bit board (CPU, EPROMs, PIC, DMD RAM)

Very clear close-up of the most important region.

| Ref (silkscreen) | Visible top-mark | Best identification | Package | Notes |
|------|----------|---------------------|---------|-------|
| IC1 | (square PLCC, marking partially obscured by ribbon) | **N80C188-10 / AM80C188-10** | PLCC-68 | Main 16-bit CPU, populated |
| IC10 | windowed EPROM, paper sticker `IO MOON V1.2-04` (also `V1.3-02` on a different photo, see below) | 27C040 (or M27C2001) | PDIP-32, windowed | Game code/data |
| IC11 | windowed EPROM | 27C040 | PDIP-32, windowed | Banked extension |
| IC50 | `GoldStar GM76C29-10 / 9009 KOREA` | **GoldStar GM76C29 32K×8 SRAM** | PDIP-28 | DMD framebuffer RAM |
| IC55 | `YAMAHA / YM...` partly visible **OR** `TOSHIBA TC55...` SRAM | Either a second SRAM or further YM3812-related chip — needs clarification | PDIP-28 | Probably the second DMD framebuffer SRAM (paired with IC50) |
| IC23 | DIP, socketed; top-mark Microchip-style, hard to read at this resolution | **PIC16C57-HS/P** (settled by direct inspection) | PDIP-28 | DMD raster coprocessor. **Socketed.** Dumped — [`../roms/PIC16C57/`](../roms/PIC16C57/). |
| IC34 | 28-pin DIP, date code `9215 GCT/P` visible, top-mark not legible at this resolution | **TI CD74HC151E**, an 8-to-1 multiplexer (settled by direct inspection) | PDIP-16 | Not a programmable part |
| IC25 | small DIP, marking unreadable | 74LS series | PDIP-16 | |
| IC20, IC21, IC22, IC24 | row of 20-pin DIPs adjacent to IC1 / IC23 | suspected PAL16L8 cluster (candidate PAL positions, per the manual analysis) | PDIP-20 | Worth probing with a PAL programmer |
| IC2, IC3, IC4, IC5 | 20-pin DIPs at top-left | 74LSxx latches | PDIP-20 | |
| IC35 (visible at bottom-left of this image) | 28-pin DIP | likely a third SRAM or sound EPROM | PDIP-28 | |

### 10. `80188_board_011_029A.jpg` — close-up: bottom-left of 16-bit board (CPU + EPROMs + clock)

Provides clearer reads on IC1, IC10, IC11, and IC14 region:

| Ref | Visible top-mark | Identification | Package | Notes |
|-----|----------|----------------|---------|-------|
| IC1 | `N80C188-10` (Intel) **or** `AM80C188-10` (AMD second-source) | 80188 main CPU, 10 MHz | PLCC-68 | Populated |
| IC10 | EPROM window, sticker `IO MOON V1.3-02` | 27C040 / M27C2001 | PDIP-32, windowed | NOTE: sticker says **V1.3-02** here, not V1.2-04 as on the other ROMs and on the Z80's IC5 — there may be mixed-revision ROMs on this physical board. **Important data point** for the dump-archival side. |
| IC11 | EPROM, second windowed package (sticker partly obscured by green tape) | 27C040 | PDIP-32, windowed | |
| IC14 | (visible at right edge of view) `MICROCHIP / 28C64A-25 / SN/L` | **28C64A** 8K×8 EEPROM | PDIP-28 | NVRAM for settings/scores — **confirmed**. Manufacturer Microchip, -25 = 250 ns access time. |
| IC55 / IC50 | (top-right of view) `GoldStar GM76C29-10` × 2 | GoldStar GM76C29 32K×8 SRAM × 2 | PDIP-28 | DMD framebuffer (pair) |
| IC60 | (top-right of view, partial) `YAMAHA YM3812` | YM3812 | PDIP-24 | |

### 11. `80188_board_011_029A.jpg` — close-up: bottom of 16-bit board (IC12/13/14, IC60, J1 ribbon)

Best image for the IC12 / IC13 / IC14 column and for IC7.

| Ref | Visible top-mark | Identification | Package | Notes |
|-----|----------|----------------|---------|-------|
| IC12 | `UMC / UM62256BL-70LL / 9417S / N3082Z` | **UMC UM62256 32K×8 SRAM** (70 ns) | PDIP-28 | 80188 main work RAM (probably shared with Z80 over J1 ↔ J3 ribbon) |
| IC13 | (empty 32-pin DIP socket — pads visible, no chip) | **VACANT** | PDIP-32 socket | Unpopulated expansion socket — confirms architecture doc. |
| IC14 | `28C64A-25 SN/L / MICROCHIP / © 2007` (silkscreened year) | **Microchip 28C64A 8K×8 EEPROM** | PDIP-28 | NVRAM — confirmed. |
| IC60 (top-left of view) | `YAMAHA YM3812 / JAPAN` (top edge visible) | YM3812 | PDIP-24 | **POPULATED.** |
| IC56 | `SN74LS373AN` | 74LS373 | PDIP-20 | |
| IC50 | `SN74LS273N` | 74LS273 | PDIP-20 | |
| IC45 | `SN74LS273N` | 74LS273 | PDIP-20 | |
| IC46 | `74LS86` or `74LS00` (small, unclear) | 74LSxx | PDIP-14 | |
| "IC57" | `9277BNCN` date code, ~24-pin DIP | There is no IC57 on this board: the position is **IC7**, the AMD/MMI PAL20L10ACNS chip-select PAL | PDIP-24 | Settled by direct inspection |
| IC40 | 20-pin DIP, `74HCT373` or `74LS373` | 74xx373 octal latch | PDIP-20 | |
| IC47 | 16-pin DIP, decoder pattern | 74HCT138 | PDIP-16 | |
| IC41, IC42, IC43, IC44 | 14/16-pin 74LS family | 74LSxx | PDIP-14 / 16 | |
| AR42 (visible at right) | 20-pin SIP / DIP resistor pack near J1 | resistor network | SIP-20 | Pull-ups for J1 bus |
| J1 | 20-pin ribbon header (right edge of view) | Inter-CPU bus to 011-030A J3 | 20-pin shrouded male | Silkscreen `J1` label visible nearby |

---

## Consolidated complete chip inventory

Combining all images, the following chips are identifiable on each board.
Entries marked **(uncertain)** have a low-confidence reading and should be
re-verified with a tighter close-up before relying on the part number for
dumping / firmware work.

### CPU 16-bit board (011-029A)

| Ref | Part number | Manufacturer | Package | Function | Populated? | Confidence |
|-----|-------------|--------------|---------|----------|------------|------------|
| IC1 | 80C188-10 (N80C188-10 or AM80C188-10) | Intel / AMD | PLCC-68 | Main 16-bit CPU | Yes | High |
| IC2–IC5 | 74LSxx | TI / others | PDIP-20 | Latches | Yes | Medium (part numbers not all read) |
| IC8 | DM74LS74AN | National | PDIP-14 | Dual D flip-flop. (The 16-bit board's PAL is **IC7**, not IC8.) | Yes | Settled |
| IC10 | 27C040 — `IO MOON V1.3-02` | Microchip / ST / AMD | PDIP-32 windowed | Game code/data EPROM | Yes | High |
| IC11 | 27C040 — sticker `1002` | — | PDIP-32 windowed | Graphics EPROM, paged into segment `6000h` 64 KB at a time | Yes | Settled |
| IC12 | UM62256BL-70LL | UMC | PDIP-28 | 32K×8 SRAM (main work RAM) | Yes | High |
| IC13 | — | — | PDIP-32 socket | Unpopulated expansion socket | **No** | High |
| IC14 | 28C64A-25 | Microchip | PDIP-28 | 8K×8 EEPROM (NVRAM) | Yes | High |
| IC20, IC21, IC22, IC24 | (markings unreadable) | suspected PAL16L8 | PDIP-20 (and IC24 is PDIP-16) | Bus / DMD glue — candidate PAL positions | Yes | Low — needs close-up |
| IC23 | PIC16C57-HS/P | Microchip | PDIP-28 | **DMD raster coprocessor** — dumped | Yes, **SOCKETED** | Settled |
| IC25 | 74LSxx | — | PDIP-16 | glue | Yes | Low |
| IC30–IC34 | 74LS157 x2, GM76C28 SRAM (IC33), CD74HC151E (IC34) | TI / Goldstar | varies | Multiplexers, DMD staging SRAM | Yes | Settled — see the canonical inventory |
| IC34 | CD74HC151E | TI | PDIP-16 | 8-to-1 multiplexer | Yes | Settled |
| IC35 | (28-pin DIP, marking unread) | — | PDIP-28 | possibly third SRAM / EPROM | Yes | Low |
| IC40 | 74xx373 | — | PDIP-20 | Latch | Yes | Medium |
| IC41–IC46 | 74LSxx | TI / etc | PDIP-14/16 | glue | Yes | Medium |
| IC47 | 74HCT138 | — | PDIP-16 | Address decoder | Yes | Medium |
| IC50 | SN74LS273N | TI | PDIP-20 | Octal latch — the OKI phrase/channel latch at `/PCS6` | Yes | Settled |
| IC51 | OKI MSM6376 | OKI | PDIP-42 | ADPCM voice / sample synthesiser | Yes | Settled — the 8-pin part read here is a neighbouring analogue device |
| IC52 | 27C040 (windowed) — sound EPROM | — | PDIP-32 windowed | Sound samples 1 | Yes | High |
| IC53 | 27C040 (windowed) — sound EPROM | — | PDIP-32 windowed | Sound samples 2 | Yes | High |
| IC54 | — | — | PDIP-32 socket | Unpopulated sound EPROM expansion | **No** | High |
| IC55 | SN74LS139AN | TI | PDIP-16 | Dual 2-to-4 decoder | Yes | Settled |
| IC56 | SN74LS373AN | TI | PDIP-20 | Octal latch | Yes | High |
| IC57 | no such position — the chip read here is **IC7**, the PAL20L10ACNS | AMD/MMI | PDIP-24 | 80188 chip-select glue | Yes | Settled |
| IC60 | YM3812 | Yamaha | PDIP-24 | FM synthesizer (OPL2) | **Yes — POPULATED** | High |
| IC61 | YM3014 (likely, marking unread) | Yamaha | PDIP-8 / SOIC-8 | DAC for YM3812 output | Yes | Medium |
| IC62 | LGS 74xx-series | LG Semicon | PDIP-14 | glue | Yes | Medium |
| IC63 | X9103 (digital pot, likely) | Xicor | DIP-8 | Music balance EEPOT | Yes | Medium |
| IC64 | (8-pin, marking unread) | — | DIP-8 | Likely the other of YM3014 / X9103 | Yes | Low |
| OSC1 | crystal can, frequency not readable in any photograph | — | HC-49 | Main system clock; the 10 MHz CLKOUT used throughout the docs is inferred from the `N80C188-10` part, not measured | Yes | Open |
| AR20, AR40, AR42 | resistor networks | — | SIP packages | Pull-ups | Yes | Medium |
| J1 | 20-pin ribbon header to Z80 | — | shrouded male | Inter-CPU bus | Yes | High |
| J2 | 14-pin ribbon header to plasma display | — | shrouded male | DMD interface | Yes | High |
| J3 | audio output connector | — | 2-pin / 3-pin | Audio | Yes | High |
| J4 | power input | — | molex | +5 V / GND | Yes | High |
| JP7 | jumper | — | 2-pin / 3-pin | Configuration | Yes | High |

### CPU 8-bit board (011-030A)

| Ref | Part number | Manufacturer | Package | Function | Populated? | Confidence |
|-----|-------------|--------------|---------|----------|------------|------------|
| IC1 | Z0840004PSC (Z80A) | GoldStar (LG) | PDIP-40 | I/O CPU | Yes | High |
| IC5 | 27C256 — `IO MOON V1.2-04` | — | PDIP-28 windowed | Z80 ROM | Yes | High |
| IC6 | (socket — population unclear, covered by tape on photo) | — | PDIP-28 socket | Z80 expansion-ROM window `0x8000`-`0xBFFF`; no Z80 code reads it | Unclear — needs photo with tape removed | Low |
| IC7 | Goldstar GM76C28-10 | Goldstar | PDIP-24 | 2K×8 Z80 work RAM | Yes | Settled |
| IC8 | AMD PAL16L8A-2CN | AMD | PDIP-20 | Z80 memory / I/O address decode — **undumped** | Yes | Settled |
| IC15 | ADM699AN | Analog Devices | DIP-8 | Watchdog supervisor (pin-compatible with the MAX699, which is IC6 on the 16-bit board) | Yes | Settled |
| IC41 | ULN2803A | TI / ST | PDIP-18 | Driver buffer | Yes | High |
| IC51 | ULN2803A | TI / ST | PDIP-18 | Driver buffer | Yes | High |
| SW40 | 8-position DIP switch | — | DIP-16 (8-pos) | Config | Yes | High |
| X10 | 8 MHz crystal | — | HC-49 | Z80 clock | Yes | High |
| ~30 × 74LSxx | 74LS244 / 74LS373 / 74LS138 / 74LS245 | — | PDIP-14/16/20 | Glue | Yes | Medium |
| J1 | Power input | — | molex | +5 V / GND | Yes | High |
| J2, J4, J6, J7, J8 | ribbon connectors | — | various | Lamp/solenoid/switch matrix | Yes | High |
| J3 | 20-pin ribbon to CPU 16-bit J1 | — | shrouded male | Inter-CPU bus | Yes | High |

### Drivers board (011-027A)

| Component | Description | Notes |
|-----------|-------------|-------|
| ~16 × TO-220 power transistors | Darlington power switches (likely TIP122 / BD679 / 2N6044 — candidate datasheets in [`../datasheets/`](../datasheets/README.md#candidate-parts--driver-board-011-027a-unconfirmed)) | Mounted to L-bracket / chassis for heatsinking |
| Base resistor networks | Series resistors per channel | Standard |
| 1 × PDIP-14 logic IC | Marking `MALAYSIA 9140K / 3910103-008 / 1474115DA` — likely 74LSxx | Single glue IC; no firmware on this board |
| Blade output connectors | Solenoid / lamp loads | Bottom edge |
| Ribbon input connectors | Signals from CPU board | Top edge |

### Audio amplifier (011-024), display PSUs, etc.

Only visible in the overview shot (image 1) — no chip-level reads possible.

---

## Chips worth dumping

Superseded by [`../docs/chips_to_dump.md`](../docs/chips_to_dump.md), which lists
the three programmable parts the machine actually has — IC23 (PIC16C57, dumped),
IC7 (PAL20L10) and IC8 on the Z80 board (PAL16L8) — with the procedures for each.
The candidate PIC positions this photo pass proposed at IC34 and "IC57" do not
exist; those are a 74HC151 multiplexer and IC7's PAL respectively. The mask ROMs
(IC10, IC11, IC52, IC53, IC5) are all archived in [`../roms/`](../roms/).

---

## Additions to the service manual's component table

Each entry below is something the photographs add to the principal-components
table on pages 93 and 95 of the service manual. The three entries this pass
raised as contradictions — an 8-pin part at IC51, an extra PIC at "IC57", and
another at IC34 — were resolution artefacts and are resolved in the status note
at the top of this file: IC51 is the 42-pin OKI MSM6376, "IC57" is IC7's
PAL20L10, and IC34 is a CD74HC151E multiplexer. The machine has one PIC.

3. **IC34** carries a 28-pin DIP whose top-mark was not legible in this pass;
   it is a `TI CD74HC151E` 8-to-1 multiplexer.
   28-pin DIP package. **Action:** as above, macro photo to confirm.

4. **IC13 (32-pin socket) is genuinely unpopulated** — confirmed by image
   `80188_board_011_029A.jpg`. The manual leaves this slot ambiguous; we can
   now state with confidence that it is a vacant expansion socket.

5. **IC54 (32-pin socket in the sound-EPROM column) is unpopulated** —
   confirmed by image `80188_board_011_029A.jpg`. The "third sound EPROM"
   socket is empty.

6. **IC12 is populated and is an SRAM, not an EPROM**. Marking
   `UMC UM62256BL-70LL` confirms 32K×8 static RAM. The architecture
   document had IC12 as "unidentified 32-pin DIP" — it should be classified
   as the 80188 main work RAM.

7. **IC50 and IC55 are SRAM, specifically GoldStar GM76C29-10**. Two
   identical 32K×8 SRAMs — almost certainly a pair forming the
   double-buffered DMD framebuffer (consistent with the `dmd_wire_protocol`
   description of the DMD controller). The architecture document did not
   identify these.

8. **IC14 EEPROM confirmed as Microchip 28C64A-25 in PDIP-28** — matches the
   manual. No correction needed; just confirmation.

9. **Main CPU (IC1) confirmed as 80C188-10 in PLCC-68** — matches the
   manual.

10. **ROM stickers.** IC10 reads `V1.3-02` and the Z80 board's IC5 reads
    `V1.2-04`. These are not different revisions of one program: the sticker
    convention is `V<set>-<chip number>`, so `V1.3-02` is chip 02 of the V1.3
    set. The archived dumps in [`../roms/`](../roms/) are that set.

11. **Drivers board (011-027A) has exactly one logic IC**, an unmarked
    PDIP-14 with Malaysia date code `9140K / 3910103-008`. The board is
    otherwise entirely passive + power transistors. No correction needed
    for the architecture document; just adding inventory completeness.

12. **Z80 board (011-030A) IC6 socket population is indeterminate from the
    photos** — covered by paper tape in both available images. The
    architecture document already flags IC6 as "either unpopulated,
    optional expansion, or not enumerated". This remains unresolved.

13. **GoldStar Z0840004PSC** is the actual Z80A part on IC1 of the 8-bit
    board. The architecture document said "Z80A (Zilog/SGS)" — neither
    second-source is correct; it is a GoldStar (LG Semicon) part. Minor
    correction.

---

## The YM3812 is populated

Both close-ups of the 16-bit board show a 24-pin DIP at silkscreen IC60 with the
top-marking `YAMAHA / YM3812 / JAPAN`, fully seated, with decoupling capacitor
CD60 immediately adjacent and its resistor/capacitor support complete. It is a
working part, not a BOM-compatibility placeholder.

How it is driven is settled from the firmware, not the photographs: the 80188
writes it directly over `/PCS5` — index port `0xA0280`, data port `0xA0281` —
from a sequencer at `D000:0D37` / `0D99` playing ten FM tracks, and the music runs
during gameplay only, which is why attract mode is silent. There is no sound
coprocessor anywhere on the board. See
[`../docs/iomoon_fm_extract.md`](../docs/iomoon_fm_extract.md) and finding F8.

---

## The PIC at IC23

IC23 sits in the top-right region of the 16-bit board, next to JP7 and IC24, and
is **socketed** — the socket walls extend below the chip body and the pin headers
are visible recessed into the PCB — so a non-destructive pull-and-read is
possible. The package is matte black plastic with no quartz window, i.e. the OTP
variant.

The part is a **PIC16C57-HS/P in a PDIP-28**, not the 18-pin PIC16C54 the
service manual's text names (this photo pass read it as 18-pin at the resolution
available). Its code-protect fuse is blown, so a direct read returns only a
nibble-XOR fold of each 12-bit word; the recovered program is archived at
[`../roms/PIC16C57/`](../roms/PIC16C57/) and disassembled in
[`../asm/pic16c57_annotated.asm`](../asm/pic16c57_annotated.asm). See
[`pic16c57_protection_analysis.md`](pic16c57_protection_analysis.md) for how the
recovery was authenticated.

---

## Inter-board signal observations

The 14-pin J2 ribbon leaving the top-left edge of the 16-bit board toward
the plasma display is visible in `overview_backbox_all_boards.jpg`,
`80188_board_011_029A.jpg`, and `80188_board_011_029A.jpg`. The silkscreen
near J2 is partially obscured by the ribbon itself and by the paper labels
on the EPROMs — **no individual pin labels are legible in any photo**. A
fresh photo of the J2 region with the ribbon disconnected would be needed
to read the signal names from the silkscreen.

The 20-pin J1↔J3 ribbon between the two CPU boards is visible crossing the
gap between the boards in `overview_backbox_all_boards.jpg`. The connectors
themselves are shrouded male headers; no per-pin silkscreen labels are
visible from the angle photographed.

---

## Remaining uncertainties

The chip identities this pass flagged are all settled — see the status note at the
top of this file and the two canonical board inventories. What the photographs
still do not show:

1. **Silkscreen pin labels at J1, J2 and J3** on the 16-bit board — obscured by
   the ribbons and by the paper labels on the EPROMs. Reading them needs a fresh
   photo with the ribbons disconnected.
2. **OSC1's frequency** on the 16-bit board — the crystal can's text was not
   readable, and no ROM states the CPU clock either, so the 10 MHz figure used
   throughout remains an inference from the `N80C188-10` part
   ([`../docs/hardware_architecture.md`](../docs/hardware_architecture.md)).
3. **X10's division ratio** on the Z80 board — the crystal is 8 MHz and the CPU
   is a 4 MHz-grade Z80A, so it is divided, but by what is not visible.
4. **IC6's socket population** on the Z80 board — covered by tape in both
   photographs. No Z80 code reads its address range in any case.
5. **The part numbers of the drivers board's TO-220 power transistors**, which
   carry no legible markings in the photograph.
