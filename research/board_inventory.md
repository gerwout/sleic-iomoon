# IO Moon — Physical Board Inventory from Photographs

> **Status note.** This file records the *original* photo-by-photo research pass.
> The findings here have been consolidated into the per-board IC inventories
> ([`../docs/board_011-029A_ics.md`](../docs/board_011-029A_ics.md) and
> [`../docs/board_011-030A_ics.md`](../docs/board_011-030A_ics.md)), which are now
> the canonical reference. The eleven `IMG_20260527_XXXXXX.jpg` files originally
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
            IC57 (likely an extra PIC — see flag below)  IC61/IC62/IC63 (8-pin)
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
| Right side | IC15 (8-pin SOIC/DIP, top) — MAX699 watchdog; IC5 (28-pin UV EPROM, windowed) — `IO MOON V1.2-04`; IC6 socket (covered by tape — population status indeterminate from this photo) |
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
- IC15: 8-pin DIP near top edge — MAX699 (Maxim watchdog supervisor)
- IC41, IC51: bottom row, 18-pin DIPs — ULN2803A

Approximate full chip list visible (close-ups would let me read each one):

| Ref | Package | Part | Notes |
|-----|---------|------|-------|
| IC1 | PDIP-40 | Z80A (GoldStar Z0840004PSC) | I/O CPU |
| IC5 | PDIP-28, windowed | 27C256 — `IO MOON V1.2-04` | Z80 ROM |
| IC6 | PDIP-28 socket | (covered by tape; population unclear) | "Extended routines" socket per asm |
| IC7 | PDIP-24 | 6116 SRAM (assumed, label not readable) | Z80 work RAM |
| IC8 | PDIP-20 | PAL16L8 (assumed, label not readable) | I/O decode |
| IC15 | PDIP-8 | MAX699 | Watchdog supervisor |
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
| IC7 (silkscreen at lower-left of this image) | `PIC16C57/04XL`-style marking with `9277BNCN` date code | **Likely an additional PIC16C5x** (uncertain — see flag) | PDIP-28 (~14 pins per side) | This is a previously-undocumented PIC location; see "Extra PIC at IC7/IC57" below. |
| IC9 (next to IC7) | `74LS138` style | 74LS138 decoder | PDIP-16 | |
| IC44 | `74LSxx` | 74LS-series | PDIP-14 | |
| IC43 | `74LSxx` | 74LS-series | PDIP-14 | |

**Critically:** I do **not** see a 42-pin DIP anywhere in this region. The
OKI MSM6376 is a 42-pin / 600-mil chip that would be visually unmistakable
(roughly 53 mm long). The chip closest to the silkscreen label `IC51` is a
small 8-pin package. Either:

  1. The principal-components table's pin-count / package style for IC51 is
     wrong, and the IC51 position holds a small audio buffer, **and the OKI
     6376 sits elsewhere on the board** (most likely at the position the
     silkscreen labels as IC7 or IC57); **or**
  2. The OKI MSM6376 has been substituted with a smaller-package equivalent
     (e.g. an OKI ADPCM SOIC variant); **or**
  3. The OKI MSM6376 is genuinely absent on this board revision and IO Moon
     uses only YM3812 + DAC for audio.

A focused close-up of every chip in the IC51 / IC57 / IC7 cluster would
resolve this. As-photographed, the OKI MSM6376 designation given in
`hardware_architecture.md` cannot be confirmed.

### 9. `80188_board_011_029A.jpg` — close-up: upper-centre/left of 16-bit board (CPU, EPROMs, PIC, DMD RAM)

Very clear close-up of the most important region.

| Ref (silkscreen) | Visible top-mark | Best identification | Package | Notes |
|------|----------|---------------------|---------|-------|
| IC1 | (square PLCC, marking partially obscured by ribbon) | **N80C188-10 / AM80C188-10** | PLCC-68 | Main 16-bit CPU, populated |
| IC10 | windowed EPROM, paper sticker `IO MOON V1.2-04` (also `V1.3-02` on a different photo, see below) | 27C040 (or M27C2001) | PDIP-32, windowed | Game code/data |
| IC11 | windowed EPROM | 27C040 | PDIP-32, windowed | Banked extension |
| IC50 | `GoldStar GM76C29-10 / 9009 KOREA` | **GoldStar GM76C29 32K×8 SRAM** | PDIP-28 | DMD framebuffer RAM |
| IC55 | `YAMAHA / YM...` partly visible **OR** `TOSHIBA TC55...` SRAM | Either a second SRAM or further YM3812-related chip — needs clarification | PDIP-28 | Probably the second DMD framebuffer SRAM (paired with IC50) |
| IC23 | small ~18-pin DIP, socketed; top-mark hard to read but clearly Microchip-style; appears as `PIC16C5?-HS/P` | **PIC16C5x — likely PIC16C54-HS/P or PIC16C57-HS/P** | PDIP-18 if it's PIC16C54, PDIP-28 if PIC16C57. From the pin count visible in this image (~9 pins per side), it is **18-pin**, consistent with **PIC16C54-HS/P** (matches the manual's claim). | DMD raster coprocessor. **Socketed.** |
| IC34 | 28-pin DIP, top-mark reads either `PIC16C57-HC/P` (Microchip PIC16C57) or possibly `PT8SC5T-HC/P` (cannot rule out a custom Sleic / Petaco-marked part). Date code `9215 GCT/P` visible. | **Likely a second PIC (PIC16C57-HC/P)** — see flag in "Discrepancies" below. | PDIP-28 | **Undocumented in `hardware_architecture.md` as a programmable device.** |
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

Best image for confirming the IC12 / IC13 / IC14 column and the IC57 chip.

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
| IC57 | `PIC16C(?)/04XL / 9277BNCN` — Microchip-style font, ~18-pin DIP | **Likely PIC16C54-04/XL** (XL = extended-temperature plastic, 04 = 4 MHz) | PDIP-18 | **Undocumented in `hardware_architecture.md`.** A second PIC microcontroller, in addition to IC23. Could be a video output companion to IC23. |
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
| IC8 | 74LSxx **OR** PAL16L8 (uncertain) | unknown | PDIP-20 | Clock-divider / glue | Yes | Low — needs close-up |
| IC10 | 27C040 — `IO MOON V1.3-02` | Microchip / ST / AMD | PDIP-32 windowed | Game code/data EPROM | Yes | High |
| IC11 | 27C040 — `IO MOON V1.x-xx` (sticker covered) | — | PDIP-32 windowed | Banked extension EPROM | Yes | High (chip), Medium (revision label) |
| IC12 | UM62256BL-70LL | UMC | PDIP-28 | 32K×8 SRAM (main work RAM) | Yes | High |
| IC13 | — | — | PDIP-32 socket | Unpopulated expansion socket | **No** | High |
| IC14 | 28C64A-25 | Microchip | PDIP-28 | 8K×8 EEPROM (NVRAM) | Yes | High |
| IC20, IC21, IC22, IC24 | (markings unreadable) | suspected PAL16L8 | PDIP-20 (and IC24 is PDIP-16) | Bus / DMD glue — candidate PAL positions | Yes | Low — needs close-up |
| IC23 | PIC16C54-HS/P (most likely — 18-pin package confirmed) | Microchip | PDIP-18 | **DMD raster coprocessor** | Yes, **SOCKETED** | Medium-High |
| IC25 | 74LSxx | — | PDIP-16 | glue | Yes | Low |
| IC30–IC34 | several 14/16/20-pin DIPs — see flag for IC34 | — | varies | glue / **suspected second PIC at IC34** | Yes | Low — IC34 needs close-up |
| IC34 | likely PIC16C57-HC/P **OR** custom-marked Sleic part (uncertain) | Microchip (probably) | PDIP-28 | Unknown — possibly a second coprocessor | Yes | **Low — important to verify** |
| IC35 | (28-pin DIP, marking unread) | — | PDIP-28 | possibly third SRAM / EPROM | Yes | Low |
| IC40 | 74xx373 | — | PDIP-20 | Latch | Yes | Medium |
| IC41–IC46 | 74LSxx | TI / etc | PDIP-14/16 | glue | Yes | Medium |
| IC47 | 74HCT138 | — | PDIP-16 | Address decoder | Yes | Medium |
| IC50 | GM76C29-10 | GoldStar (LG) | PDIP-28 | 32K×8 SRAM (DMD framebuffer A) | Yes | High |
| IC51 | 8-pin DIP (NOT 42-pin OKI 6376) | — | DIP-8 / SOIC-8 | Audio op-amp / buffer (likely) — see OKI finding | Yes | Medium — manual designation incorrect |
| IC52 | 27C040 (windowed) — sound EPROM | — | PDIP-32 windowed | Sound samples 1 | Yes | High |
| IC53 | 27C040 (windowed) — sound EPROM | — | PDIP-32 windowed | Sound samples 2 | Yes | High |
| IC54 | — | — | PDIP-32 socket | Unpopulated sound EPROM expansion | **No** | High |
| IC55 | GM76C29-10 (or similar SRAM) | GoldStar | PDIP-28 | 32K×8 SRAM (DMD framebuffer B) | Yes | Medium |
| IC56 | SN74LS373AN | TI | PDIP-20 | Octal latch | Yes | High |
| IC57 | likely PIC16C54-04/XL (uncertain — markings degraded) | Microchip (likely) | PDIP-18 | **Undocumented PIC, possible audio coprocessor / DMD secondary** | Yes | **Low — important to verify** |
| IC60 | YM3812 | Yamaha | PDIP-24 | FM synthesizer (OPL2) | **Yes — POPULATED** | High |
| IC61 | YM3014 (likely, marking unread) | Yamaha | PDIP-8 / SOIC-8 | DAC for YM3812 output | Yes | Medium |
| IC62 | LGS 74xx-series | LG Semicon | PDIP-14 | glue | Yes | Medium |
| IC63 | X9103 (digital pot, likely) | Xicor | DIP-8 | Music balance EEPOT | Yes | Medium |
| IC64 | (8-pin, marking unread) | — | DIP-8 | Likely the other of YM3014 / X9103 | Yes | Low |
| OSC1 | crystal can (frequency unread — likely 20 MHz for 80188 ÷2) | — | HC-49 | Main system clock | Yes | High |
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
| IC6 | (socket — population unclear, covered by tape on photo) | — | PDIP-28 socket | Z80 extension ROM (`asm/z80_annotated.asm`) | Unclear — needs photo with tape removed | Low |
| IC7 | 6116 (likely) | — | PDIP-24 | 2K×8 Z80 SRAM | Yes | Medium |
| IC8 | PAL16L8 (likely — marking not legible in photo) | — | PDIP-20 | I/O address decode | Yes | Medium (needs close-up to confirm PN) |
| IC15 | MAX699 (likely) | Maxim | PDIP-8 | Watchdog supervisor | Yes | Medium |
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

Every programmable / firmware-bearing device located on the photographs,
ranked by dumping difficulty. All are TL866II+-compatible (the TL866II+
supports PIC16C5x, PAL16L8, 27Cxxx EPROMs and 28Cxx EEPROMs out of the box).

| Ref | Board | Part (best read) | Package | Socketed? | Dumping difficulty | Programmer notes |
|-----|-------|------------------|---------|-----------|--------------------|------------------|
| IC10 | 011-029A (16-bit) | 27C040 — `IO MOON V1.3-02` | PDIP-32 windowed | Yes (socketed in 32-pin DIP socket) | Easy | TL866II+ → 27C040; pull from socket, read directly. Already dumped per project state (verify against `IO_MOON V1.3-02` rev — note this differs from V1.2-04 elsewhere). |
| IC11 | 011-029A | 27C040 — game data | PDIP-32 windowed | Yes | Easy | TL866II+ → 27C040 |
| IC52 | 011-029A | 27C040 — sound 1 | PDIP-32 windowed | Yes | Easy | TL866II+ → 27C040 |
| IC53 | 011-029A | 27C040 — sound 2 | PDIP-32 windowed | Yes | Easy | TL866II+ → 27C040 |
| IC14 | 011-029A | 28C64A-25 | PDIP-28 | Yes (28-pin socket) | Easy | TL866II+ → AT28C64A. Live NVRAM — read, then put it back; or read in-situ via a clip if you want to preserve settings. |
| IC23 | 011-029A | PIC16C54-HS/P (likely; could be PIC16C57-HS/P — depends on actual pin count) | PDIP-18 | **Yes — clearly socketed** | Medium | TL866II+ → PIC16C54 / 16C57 mode. **CP fuse may be set**; check before assuming a clean read. If CP is set, the device is OTP and will return scrambled data — no recovery without etch / decap, which is destructive. |
| IC34 (uncertain) | 011-029A | possibly PIC16C57-HC/P (or custom Sleic-marked part) | PDIP-28 | Likely socketed (needs close-up to confirm) | Medium — but **first verify it is actually a PIC**, not a custom mask part | TL866II+ → PIC16C57 mode if it's a 16C57. If marked as a non-Microchip part, do not attempt — could be a one-time mask ROM. |
| IC57 (uncertain) | 011-029A | possibly PIC16C54-04/XL | PDIP-18 | Likely socketed | Medium | TL866II+ → PIC16C54. Same CP-fuse caveat. |
| IC8 | 011-030A (8-bit) | PAL16L8 (assumed) | PDIP-20 | Likely socketed | Medium-Hard | PAL16L8 must be dumped by *replay* via a PAL reader (TL866II+ does support 16L8 read). If the SEC fuse is blown, the part is unreadable and must be reverse-engineered by logic-probing the inputs/outputs through a full input truth table. |
| IC5 | 011-030A | 27C256 — `IO MOON V1.2-04` | PDIP-28 windowed | Yes | Easy | TL866II+ → 27C256. Already dumped. |
| IC6 | 011-030A | possibly 27C128 — `IO MOON V1.x` | PDIP-28 socket | Unclear (tape covers socket) | Easy IF populated | TL866II+ → 27C128 (or whatever the actual part). Confirm population first. |
| IC20, IC21, IC22, IC24 | 011-029A | candidate PAL16L8s (markings unverified) | PDIP-20 / 16 | Likely socketed | Medium — first verify these are PALs (not 74LSxx) | TL866II+ if they turn out to be PALs |

Dumping priority (most-valuable first):

1. **IC23** — the documented DMD coprocessor PIC. Highest value because it
   is currently a complete black box.
2. **IC34 and IC57** — *if* they are PICs as suspected, they are also black
   boxes and would explain pieces of the current driver gaps (e.g. the
   missing YM3812 register writes).
3. **IC8** on the Z80 board — PAL16L8 that does I/O address decoding. Would
   complete the Z80 memory map.
4. **IC20–IC22 / IC24** on the 16-bit board — candidate PALs around the
   80188 chip-selects.
5. **IC10/IC11/IC52/IC53 EPROMs at the V1.3-02 revision** — the sticker on
   IC10 in image 10 reads **V1.3-02**, while elsewhere the chips are
   labelled **V1.2-04**. If this is a real revision mismatch on the
   physical board, V1.3-02 is a newer ROM than what the project currently
   archives, and should be dumped and diffed against the V1.2-04 dump.

---

## Corrections / additions to `hardware_architecture.md`

Each entry below is something the photo evidence either contradicts or adds
to the principal-components table on pages 93 and 95 of the service manual.

1. **IC51 / OKI MSM6376 (16-bit board) — population status not confirmed**.
   The manual designates IC51 as `OKI 6376` (42-pin DIP, 600 mil). The chip
   present at the silkscreen position closest to "IC51" in image
   `80188_board_011_029A.jpg` is an **8-pin device**, not a 42-pin DIP. No
   42-pin DIP is visible anywhere on the 16-bit board in any photograph. This
   means **one of three things**: (a) the manual mislabels the IC51 position,
   and the OKI MSM6376 lives at a different silkscreen reference (most
   plausibly the "IC7" or "IC57" position, where there is a larger DIP
   present); (b) the OKI MSM6376 has been depopulated on this board revision;
   or (c) the photographs do not clearly show the OKI region. **Action:** take
   a new close-up of every chip in the IC7 / IC51 / IC57 cluster and read each
   top-mark. Without this, the `hardware_architecture.md` claim of "IC51 OKI
   6376 ADPCM speech / FX playback" is unverified.

2. **IC57 — undocumented chip, likely another PIC**. The chip at silkscreen
   `IC57` (in `80188_board_011_029A.jpg`) carries Microchip-style markings
   `PIC16C(?)/04XL / 9277BNCN`. This chip is *not* listed in the principal
   components table. It is in an 18-pin DIP package — same pin-count as
   IC23 — and therefore plausibly a **second PIC16C54** or similar. If
   confirmed, this changes the system architecture: IO Moon has at least
   two PIC microcontrollers (IC23 and IC57), not just one. **Action:** read
   the top-mark on this chip from above with macro lighting.

3. **IC34 — undocumented chip, possibly a third PIC (PIC16C57)**. The chip
   at silkscreen `IC34` (in `80188_board_011_029A.jpg`) carries markings that
   could read either `PIC16C57-HC/P` or `PT8SC5T-HC/P` (the latter being a
   custom Sleic-marked part). The date code `9215 GCT/P` style is Microchip.
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

10. **ROM revision discrepancy: IC10 sticker reads `V1.3-02`** in
    `80188_board_011_029A.jpg`, while elsewhere on the board (and on the Z80
    board IC5) the sticker reads `V1.2-04`. This may be a hand-mixed set,
    or a service-replacement ROM. The project's currently-archived dump
    set should be checked against this — if only V1.2-04 is in the
    archive, V1.3-02 is a new revision worth dumping.

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

## Findings on the YM3812 hookup question

The principal motivation of the empirical PinMAME tracing — "is the YM3812
populated at all?" — is now answered visually.

**Image `80188_board_011_029A.jpg` and `80188_board_011_029A.jpg` both clearly
show a 24-pin DIP at silkscreen IC60 with the visible top-marking `YAMAHA /
YM3812 / JAPAN`.** The chip is fully seated in its socket (or directly
soldered — hard to tell from this angle); decoupling capacitor CD60 is
visible immediately adjacent to it; the resistor / capacitor support
components around the chip appear normal and complete. There is no sign
that this chip is a BOM-compatibility placeholder — it is fully populated
and surrounded by the support circuitry it would need to function.

> **2026-06 correction — this question is now resolved, and the speculation
> below is debunked.** The "zero YM3812 writes" trace was simply a
> **boot/attract-only** capture (a silent phase). The YM3812 **is** driven —
> by the **80188 directly**, over `/PCS5` (`0xA0280` index / `0xA0281` data),
> from a music sequencer at `D000:0D37`/`0D99` that plays 10 FM tracks during
> gameplay (byte-verified in ROM1, and verified working in the PinMAME driver).
> There is **no sound coprocessor**: "IC34/IC57" were misreads — IC34 is a
> CD74HC151E multiplexer and "IC57" was a misread of the IC7 PAL20L10. The PIC
> at IC23 is the **DMD rasterizer only**. The list below is kept for the record
> but every bullet has been ruled out.

This means the empirical PinMAME observation ("zero writes to any YM3812
register address from either CPU") was originally read as pointing to one of
the following — **all now ruled out** (the real answer is the last bullet:
the music path is in firmware that the boot-only trace never executed):

- ~~The YM3812 is reached via a *different* address than the docs assume.~~
  (It is at the documented `/PCS5` base; the trace just never reached it.)
- ~~The YM3812 is reached via a glue PAL or an undocumented PIC at IC34/IC57.~~
  (No such part exists; IC34 is a 74HC151 mux, "IC57" was the IC7 PAL.)
- ~~The YM3812 is driven only at game-start / reset.~~ (It is driven
  continuously by the per-frame music sequencer during gameplay.)
- The YM3812 is driven from a firmware path the boot trace never executed —
  **this is the correct one**: the music sequencer in the 80188 ROM only runs
  in gameplay, which the boot-only run never reached.

Earlier drafts speculated about extra Microchip chips at IC34 and IC57 acting
as a sound coprocessor. That is **wrong**: IC34 is a CD74HC151E multiplexer,
"IC57" was a misread of the IC7 PAL20L10, and the 80188 itself issues the
YM3812 writes — there is no coprocessor on the sound path.

---

## Finding on the PIC at IC23

`80188_board_011_029A.jpg` shows IC23 (top-right region of the 16-bit board,
next to JP7 and IC24, just below the top edge of the board) as a small DIP
in a socket. Counting pins on the package as photographed: **~9 pins per
side = 18-pin DIP**, consistent with the PIC16C54 (18-pin) part documented.

The chip is **clearly socketed** (the socket walls extend below the chip
body, and pin headers can be seen recessed into the PCB). A
non-destructive pull-and-read is therefore possible. **No UV window is
visible** on the top of the package — the surface is matte black plastic,
no quartz window — confirming this is the **OTP variant**, not the
windowed PIC16C54/JW. The exact speed-grade suffix (XT vs HS vs RC vs LP)
could not be read at this image resolution; the architecture doc's claim
of "HS" should be confirmed with a macro photo.

If the CP (code-protect) fuse is *not* set, the TL866II+ in PIC16C5x
"verify by reading" mode will return a clean 12-bit-wide program memory
dump. If CP is set, the chip will return scrambled bytes and is
effectively unrecoverable without decap. There is no way to know which
state it is in until you try.

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

## Summary of remaining uncertainties

These are the questions the next photo session should answer:

1. **Top-marks on IC34 and IC57** — are they PICs, and if so which variant?
2. **Top-mark on IC8 of the Z80 board** — is it actually a PAL16L8?
3. **Top-marks on IC20, IC21, IC22, IC24 of the 16-bit board** — are any of
   these PALs?
4. **What is the chip at silkscreen IC51 on the 16-bit board?** (The
   manual says OKI MSM6376; the photo shows an 8-pin device.)
5. **Is there a 42-pin DIP anywhere on the 16-bit board?** (If yes, that is
   the actual OKI MSM6376 position.)
6. **IC6 socket population status on the Z80 board** (tape removed).
7. **IC23 speed-grade suffix** (XT / HS / RC / LP).
8. **IC10/IC11 ROM revision labels** — confirm whether V1.3-02 is on this
   board (per image 10) and whether IC11 carries the same revision.
9. **OSC1 frequency on the 16-bit board** (the crystal can text was not
   readable).
10. **Silkscreen pin labels at J1, J2, J3** on the 16-bit board.

Each of these can be resolved with a focused macro shot taken with the
boards out of the backbox.
