# Hardware Architecture

[← Back to main README](../README.md)

## General Specifications

| Property | Value |
|----------|-------|
| Manufacturer | SLEIC — Creaciones e Investigaciones Electrónicas, S.L. |
| Location | Av. Valdelaparra 3, Pol. Ind. Alcobendas, 28100 Madrid, Spain |
| Year | 1996 |
| Theme | Space exploration / Jupiter mission |

### Mechanical

- 3 Flippers (left, right, middle right)
- 5 Pop bumpers
- 5 Drop targets (bank A–E)
- 2 Ramps
- 2 Scoops / VUKs (Vertical Up Kickers)
- Jupiter ball lock mechanism

### Game Features

- MOONLIGHT, SUNSHINE, STARWAY game modes
- ORBITS letter spelling
- Monolith Messages (10 different awards)
- Multiball and Little Multiball
- Match/Lottery system
- 4-player support
- Bilingual: Spanish and English

---

## Board Inventory

From the service manual, section 7.1 (page 91 of the manual / SLEIC reference codes):

| Board | Designator | Function | Location |
|-------|-----------|----------|----------|
| C.P.U. 16 bits | `011-029` | Control, Audio, Video | Head |
| C.P.U. 8 bits | `011-030` | Lights, Solenoids, Switches | Head |
| Drivers | `011-027` | Light & solenoid power drivers | Head |
| Audio amplifier | `011-024` | Audio power output | Head |
| Plasma display power | — | Display PSU | Head |
| Visualizador Plasma | `011-022` | The DMD itself (gas plasma panel) | Head |
| Plasma display power supply | `011-023` | Display HV PSU | Head |
| Light/Solenoid PSU | `011-028` | +24V/+44V supplies | Cabinet |
| Electronic coin mechanism | `N-50` | Coin entry | Door |

The DMD is a **gas plasma panel**, not an LED dot matrix — note the 95 V AC / 58 V AC supply requirement (connectors TW3–TW6).

---

## CPU Boards

### Main CPU Board — 80188 (16-bit) — SLEIC-PETACO 011-029

Principal components per the service manual section 7.2.1.1 (page 93), corrected and augmented with direct-photograph identifications (see [`../research/board_inventory.md`](../research/board_inventory.md) for the photo evidence):

| Reference | Component | Part | Notes |
|-----------|-----------|------|-------|
| IC1 | Main CPU | Intel/AMD 80C188-10 (PLCC-68) | 16-bit, 10 MHz |
| IC10 | EPROM (windowed) | 27C040 — sticker `IO MOON V1.3-xx` | Game code/data (`1001 JUEGO`). The "V1.3-NN" sticker convention is `V<set>-<chip number within the set>`: V1.3 is the ROM-set version, the trailing two digits are the chip's position in the set (01 = JUEGO, 02 = BANK, 03 = SONIDO 1, 04 = SONIDO 2, 05 = Z80 I/O). The "-02" sticker seen on the photographed chip does **not** indicate a sub-revision of V1.3 — it just identifies which chip within the V1.3 set this is, matching `v1_3_02.bin` in the archive. |
| IC11 | EPROM (windowed) | 27C040 | Banked extension (`1002 BANK`) |
| IC52 | EPROM (windowed) | 27C040 | Sound samples 1 (`1003 SONIDO 1`) |
| IC53 | EPROM (windowed) | 27C040 | Sound samples 2 (`1004 SONIDO 2`) |
| IC12 | SRAM | UMC `UM62256BL-70LL` (PDIP-28) | 32 K × 8 main work RAM |
| IC14 | EEPROM | Microchip `28C64A-25` (PDIP-28) | 8 K × 8 NVRAM (game settings, high scores) |
| IC50 | SRAM | GoldStar `GM76C29-10` (PDIP-28) | 32 K × 8 — **DMD frame buffer A** |
| IC55 | SRAM | GoldStar `GM76C29-10` (PDIP-28) | 32 K × 8 — **DMD frame buffer B** (paired with IC50) |
| IC23 | Microcontroller | **Microchip `PIC 16C57-HS/P`** (PDIP-28, socketed, OTP — no UV window) | DMD raster coprocessor — likely also the sound coprocessor (see [`ym3812_pinmame_precedents.md`](ym3812_pinmame_precedents.md)). **Confirmed by macro crop of `IMG_20260527_212505.jpg` as a 28-pin PIC 16C57**, not the PIC 16C54 the manual lists. 2 K × 12-bit program memory and 20 I/O pins — comfortably enough for both DMD raster and YM3812 driving. |
| IC7 | PAL | **AMD/MMI `PAL20L10ACNS`** (PDIP-24, OTP) | **Bus / chip-select glue.** Markings clearly visible in `IMG_20260527_212833.jpg` close-up: `20L10ACNS / BRDN`. Almost certainly the "PAL20L40" the MAME upstream comment lists as undumped — `20L40` being a typo for `20L10`. Worth dumping (see [`chips_to_dump.md`](chips_to_dump.md)). |
| IC34 | Logic | TI / NS `CD74HC151E` (PDIP-16, 8-to-1 multiplexer) | Date code `H9540` (1995 week 40). User-confirmed reading from the physical board. Earlier draft of these docs claimed IC34 was a PIC 16C57; that was a subagent misread — IC34 is ordinary HC-series glue logic, almost certainly used in switch-matrix or status-line selection on the 80188 side. |
| IC60 | Sound generator | Yamaha `YM3812 JAPAN` (PDIP-24) | FM music synthesizer — **confirmed populated** |
| IC61 | DAC | Yamaha YM3014 (likely, PDIP/SOIC-8) | YM3812 output DAC |
| IC51 | Voice synthesizer | **OKI MSM6376** (PDIP-42) | ADPCM speech / FX playback — **confirmed populated**, visible as the first chip on the top-right side of the board in `IMG_20260527_212505.jpg`. The original `research/board_inventory.md` subagent pass mis-attributed the IC51 silkscreen label to an adjacent 8-pin device; the correct IC51 is the 42-pin DIP. |
| IC63 | Digital potentiometer | XICOR X9103 (DIP-8) | Music balance (**not** NVRAM) |
| IC64 | (8-pin DIP) | likely the other of YM3014 / X9103 | Audio output stage |
| IC13 | (32-pin DIP socket) | **vacant** | Confirmed unpopulated by photograph |
| IC54 | (32-pin DIP socket) | **vacant** | Sound-EPROM expansion socket, confirmed unpopulated |
| IC56 | Logic | TI `SN74LS373AN` | Octal latch |
| IC45, IC50 logic position | Logic | TI `SN74LS273N` | Octal flip-flops in the audio/output path |
| OSC1 | Crystal can | (frequency not yet read; likely 20 MHz feeding 80188 ÷2) | Main system clock |
| P60 | Trim potentiometer | — | Music balance (paired with X9103) |

> **Correction on the X9103 (IC63)**: prior write-ups (including the MAME upstream driver header) describe the X9103 as NVRAM. The service manual explicitly labels it as an **EEPOT** (digital potentiometer) used together with the analog trimmer `P60` for music balance. The actual non-volatile storage chip is the **28C64A at IC14**.

> **Correction on Sleic-PETACO board manufacturer of the Z80**: see the 8-bit board section below — the actual silicon is **GoldStar Z0840004PSC**, not Zilog/SGS as the manual lists.

> **One PIC + one PAL on the Intel board**: the service manual lists only IC23 as a microcontroller. Board photographs confirm: **only IC23 is a PIC**. An earlier draft of these docs claimed IC34 and "IC57" were additional PICs based on subagent misreads — both were wrong. The chip at silkscreen position **IC7** is an **AMD/MMI PAL 20L10** (programmable *logic* — combinatorial, no firmware in the microcontroller sense); the chip at IC34 is small-package 74LS-series glue logic. "IC57" doesn't exist on the board — the subagent was reading "IC7" with an extra digit.

> **DMD frame buffer hardware identified**: the empirical PinMAME tracing in `research/pinmame_session_2/` discovered a 1 KB buffer at segment `7000h` that the 80188 fills at panel-refresh rate via the `dmd_pixel_set` / `dmd_pixel_clear` routines (F0113 / F0124). Board photography now identifies the physical RAM behind this: the paired GoldStar `GM76C29-10` SRAMs at IC50 and IC55, each 32 K × 8. The visible 1 KB at `7000:0000-7000:03FF` is only a fraction of the 64 KB total available on these two chips, suggesting the chip-select scheme maps the SRAMs across a larger range of the 80188 address space than is currently traced.

The 80188's nominal responsibilities (game logic, state machine, scoring) remain correct, but the DMD raster output is mediated by IC23 — see [`dmd_graphics.md`](dmd_graphics.md).

#### Board placement (from figure 7-1, page 94)

Approximate layout of board 011-029 as drawn in the manual's component-placement figure:

```
   Top-Left                                    Top-Right
   ─────────────────────────────────────────────────────────
   IC2  IC3  IC4  IC5  (20-pin latches)        IC8  OSC1   J2 (14-pin → display)
                                               IC22                  AR20  IC24
                                               IC21
                          IC1 (80188-10)       IC20      JP7  IC23   (← PIC 16C54HS)
                          68-pin PLCC          ────────────────────
                                               IC30  IC31  IC32  IC34   (glue logic row)
                                               IC33  IC55
   ─────────────────────────────────────────────────────────
   Bottom-Left                                 Bottom-Right
   IC10 (27C040, 1001 JUEGO)                   IC54  (32-pin DIP, unidentified)
   IC11 (27C040, 1002 BANK)                    IC53  (27C040, 1004 SONIDO 2)
   IC12, IC13 (32-pin DIPs, unidentified)      IC52  (27C040, 1003 SONIDO 1)
   IC14 (28C64A NVRAM, 28-pin)                 IC56  IC50  IC44  IC45  IC43  IC46
   IC41  IC42 (drivers / latches, 20-pin)      IC60 (YM3812)   IC51 (OKI 6376, 42-pin)
   AR40, J1 (20-pin → CPU 8-bit)               IC61 (YM3014, 8-pin)   IC63 (X9103, 8-pin)
                                                                       P50 (music balance trim)
```

**IC23 (PIC 16C54HS) location**: top-right region, **18-pin DIP**, drawn as socketed, immediately to the right of the IC20/IC21/IC22 stack and just left of (or below) connector J2 (the 14-pin ribbon to the plasma panel). Adjacent components: jumper JP7, IC24 (smaller DIP).

#### Confirmed and candidate ICs on board 011-029 (not in the manual's principal-components table)

| Reference | Part | Notes |
|-----------|------|-------|
| IC7 | **AMD/MMI `PAL 20L10ACNS`** (PDIP-24) | Confirmed by photo. Bus / chip-select glue. Almost certainly the "PAL20L40" the MAME upstream comment lists as undumped (`20L40` = typo for `20L10`). |
| IC8 | **National Semiconductor `DM74LS74AN`** (PDIP-14, dual D flip-flop) — date code `9536` (1995 week 36) | Confirmed by user readout of the physical chip. The service manual lists IC8 as "PAL 16L8" — that designation appears to be from the Bike Race schematic and is wrong for Io Moon. Position: top of board, immediately left of OSC1. |
| IC34 | **TI / NS `CD74HC151E`** (PDIP-16, 8-to-1 multiplexer) | Confirmed by user readout. Date code `H9540`. |
| IC20, IC21, IC22 | 20-pin DIPs in the column between IC1 (80188) and IC23 (PIC) | Still candidate PALs — top-marks not yet read. |
| IC24 | 16-pin DIP next to IC23 | Still candidate; top-mark not yet read. |

With IC7 now identified as the PAL 20L10, the most likely target of the MAME upstream comment's `20L40 undumped` is IC7. The remaining `16L8 undumped` in that same comment cannot be IC8 (which is a 74LS74) and has no confirmed location on Io Moon yet.

#### 32-pin DIP positions — resolved by photograph

- **IC12** is populated with `UMC UM62256BL-70LL` 32 K × 8 SRAM. The 80188 main work RAM.
- **IC13** is a **vacant 32-pin socket** (an expansion option, not used by IO Moon).
- **IC54** is a **vacant 32-pin socket** in the sound-EPROM column (sound-ROM expansion option, not used).

#### Resolved: OKI MSM6376 at IC51

The service manual designates IC51 as the **OKI MSM6376** voice synthesizer in a 42-pin / 600-mil DIP, and this is **confirmed correct**. The 42-pin DIP at the top-right of the 16-bit board, clearly visible in `IMG_20260527_212505.jpg`, is the OKI. An earlier pass of `research/board_inventory.md` mis-attributed the IC51 silkscreen label to an adjacent 8-pin device; that note has been superseded.

#### Open question: YM3812 hookup

IC60 is **confirmed populated** with a real Yamaha YM3812 (top-mark `YAMAHA / YM3812 / JAPAN`, decoupling cap CD60 present). Empirical PinMAME tracing (see `research/pinmame_session_2/`) finds **zero writes to any candidate YM3812 register address from either the 80188 or the Z80** in ~30 s of running game code. The independent investigation of the 80188 → coprocessor command queue at `4000:1158+` (see [`../research/80188_to_z80_mailbox.md`](../research/80188_to_z80_mailbox.md)) confirms the Z80 can not be the consumer — its memory bus only reaches its own 32 KB ROM and 2 KB RAM. Something between the 80188 and the YM3812 reads that queue and emits the register writes.

There is **only one programmable microcontroller** on the 16-bit board: **IC23 (PIC 16C57-HS/P)**. It is documented as the DMD raster coprocessor. The 16C57 has 2 K × 12-bit instruction memory (4× a 16C54's) and 20 I/O pins — comfortably enough to drive both the DMD wire protocol (6 signals on J2) and the YM3812 register-write interface (~11 signals — D0–D7 + A0 + WR + CS) in a single chip. The most economical hypothesis is therefore that **IC23 does both jobs**: DMD raster and sound command dispatch.

Resolving this requires dumping IC23 (see [`chips_to_dump.md`](chips_to_dump.md)). If the firmware turns out to be DMD-only, the YM3812 driver must be hiding in either the PAL20L10 at IC7 (combinatorial logic isn't typically that capable, but a PAL with registered outputs could implement a simple latch-and-strobe) or in a chip we still haven't identified.

Connectors (manual section 7.2.1.2):

| Connector | Function |
|-----------|----------|
| J1 | Bus communication to CPU 8-bit board (20-pin ribbon, matches J3 on the 8-bit board) |
| J2 | Display interface (14-pin ribbon to the plasma display) |
| J3 | Audio output to amplifier (shielded mesh+active) |
| J4 | Power input (+5 V / GND) |

### Sound/Switch CPU Board — Z80 (8-bit) — SLEIC-PETACO 011-030

Principal components (from service manual section 7.2.2.1, page 95):

| Reference | Component | Part | Notes |
|-----------|-----------|------|-------|
| IC1 | Microprocessor | GoldStar `Z0840004PSC` (Z80A) | I/O CPU @ 8 MHz (board photo: not Zilog/SGS as the manual lists) |
| IC5 | EPROM | 27C256 (Texas/SGS) | `1005 v1.2` (I/O) — 32 KB |
| SW40 | DIP switch block | 8-position | See DIP table below |

Additional ICs identified from board photographs / disassembly (not listed as "principal" in the manual):

| Reference | Component | Part | Notes |
|-----------|-----------|------|-------|
| IC7 | RAM | 6116 (2 KB) | Z80 working memory @ `0xC000`–`0xC7FF` |
| IC15 | Watchdog | MAX699 | Reset supervision |
| IC41, IC51 | Transistor arrays | ULN2803 | Lamp / solenoid driver buffers |
| X10 | Crystal | 8 MHz | Z80 clock |

> The Io Moon service manual claims a `PAL 16L8` at IC8 on this board. The user's direct readout of the physical chip on a real machine establishes two corrections: (a) **IC8 is on the 16-bit board, not on the Z80 board**, and (b) it is a `DM74LS74AN` dual D flip-flop, not a PAL — see the "Candidate PALs / unidentified glue ICs on board 011-029" section above. The 16L8 reference therefore appears to be a manual / schematic cross-contamination artefact (MAME's own comment notes the only known schematic is for Bike Race, not Io Moon). **There is no confirmed PAL on the Io Moon Z80 board**; the I/O port decode is implemented in straight 74LS-series glue.

Connectors (manual section 7.2.2.2):

| Connector | Function |
|-----------|----------|
| J1 | Power input (+5 V / GND) |
| J2 | Lamp matrix driver output (20-pin ribbon) |
| J3 | Bus communication to CPU 16-bit board (20-pin ribbon, matches J1 on the 16-bit board) |
| J4 | Solenoid driver output (20-pin ribbon) |
| J5 | VDB (solenoid watchdog) supervision (10-pin) |
| J6 | Switch matrix column scan (SCAN) outputs |
| J7 | Direct switch inputs (flippers, START, coin, tilt, test) |
| J8 | Switch matrix row return (RET) inputs |

### DIP Switch SW40 (CPU 8-bit board)

From service manual section 7.2.2.3:

| Switch | ON | OFF |
|--------|----|-----|
| SW1 | VDB solenoid watchdog **disabled** | VDB **enabled** |
| SW2–4 | Country code (see below) | — |
| SW5 | Service: no balls dispensed | Normal operation |
| SW6 | Service: solenoid test | Normal operation |
| SW7 | Service: lamp test | Normal operation |
| SW8 | Service: board self-test | Normal operation |

Country code (SW2–SW4 combination) with default coin values:

| Country | SW2 | SW3 | SW4 | Default coin values |
|---------|-----|-----|-----|---------------------|
| United Kingdom (Inglaterra) | ON | ON | ON | 30p / 1, 50p / 2, £1 / 5 |
| France | OFF | ON | ON | 3 Fr / 1, 5 Fr / 2, 10 Fr / 5 |
| Germany | ON | OFF | ON | 1 DM / 1, 2 DM / 3, 5 DM / 8 |
| Italy | OFF | OFF | ON | 500 L / 1, 1000 L / 3, 2000 L / 7 |
| Netherlands (Holanda) | ON | ON | OFF | 1 Fl / 1, 2.5 Fl / 3, 5 Fl / 7 |
| Spain (España) | OFF | ON | OFF | 50 pts / 1, 100 pts / 3, 200 pts / 8, 500 pts / 18 |
| Belgium | ON | OFF | OFF | 20 BF / 1, 50 BF / 3, 100 BF / 7 |
| Portugal | OFF | OFF | OFF | 50 Esc / 1, 100 Esc / 3, 200 Esc / 7 |

---

## Memory Map

### Physical ROM Layout

```
Address Range     Size    Content
─────────────────────────────────────────────
0x00000–0x7FFFF   512 KB  ROM2 — DMD Graphics (animated frames)
0x80000–0xCFFFF   320 KB  ROM1 — DMD Graphics (static screens, fonts, credits)
0xD0000–0xDFFFF    64 KB  Code Segment D000 — Main program (8,532 instructions)
0xE0000–0xEFFFF    64 KB  Code Segment E000 — Extended code/data (430 instructions)
0xF0000–0xFFEFF    63 KB  Code Segment F000 — System code (1,491 instructions)
0xFFF00–0xFFFFF   256 B   Boot code / reset vector (5 instructions)
```

Total executable code: ~10,458 instructions (~30 KB, ~3% of ROM). The remaining ~97% is DMD graphics data and lookup tables.

### 80188 Segment Map

| Segment | Linear Range | Function |
|---------|-------------|----------|
| `4000h` | `0x40000` | Work RAM (shared with Z80) |
| `4130h` | `0x41300` | Game configuration data |
| `4134h` | `0x41340` | Game configuration (146 references) |
| `4137h` | `0x41370` | Game mode data (32 references) |
| `413Ch` | `0x413C0` | Game state variables (920 references) |
| `4152h` | `0x41520` | Stack segment (SP init = `0x0205`) |
| `A000h` | `0xA0000` | DMD controller hardware registers |
| `D000h` | `0xD0000` | Main program code |
| `E000h` | `0xE0000` | Extended code/data |
| `F000h` | `0xF0000` | System code / BIOS |

### Z80 Memory Map

| Address Range | Size | Content |
|--------------|------|---------|
| `0x0000`–`0x7FFF` | 32 KB | ROM IC5 (27C256) — main Z80 program (`1005 v1.2`) |
| `0x8000`–`0xBFFF` | 16 KB | ROM IC6 socket (27C128) — extended routines/data; **not dumped** |
| `0xC000`–`0xC7FF` | 2 KB | RAM IC7 (6116) — working memory |

> **IC6 status**: the annotated Z80 disassembly (`asm/z80_annotated.asm:14`, `:55`) explicitly documents an `IC6 (27C128, 16 KB) at 0x8000–0xBFFF — extended routines/data`, with the note **"(not included)"** — meaning the socket position is part of the documented design but the chip's contents were not in the dump set used for the disassembly. The IO Moon service manual's *principal*-components table on page 95 lists only IC5; this is consistent with IC6 being either unpopulated, an optional expansion, or simply not enumerated in the "principal" list. The Z80 driver code may or may not actually call into `0x8000–0xBFFF` (the disassembly references it as "extended routines/data"). Confirmation requires inspecting an actual board to see if the IC6 socket is populated, and dumping it if so.
>
> An earlier revision of this document removed IC6 entirely based on the manual's principal-components list alone; that was wrong — the Z80 disassembly is the stronger source here, and the socket is reinstated above with the dumped/undumped status made explicit.

---

## Power Connectors

| Connector | Function |
|-----------|----------|
| TW1–TW2 | +24V / GND Flash Lights |
| TW3–TW6 | Display power (95V AC, 58V AC) |
| TW7–TW8 | +24V DC / GND Light Matrix |
| TW9–TW10 | 6.3V AC General Illumination |
| TW11–TW12 | +44V DC / GND Solenoids |
| TW13 | Protective wire |
| TW14–TW16 | Audio amplifier (±12V, 0V) |
| TW17–TW18 | AC mains (220V) |

---

## Inter-board cabling

The two CPU boards are linked by a single 20-pin ribbon between the **16-bit board J1** and the **8-bit board J3** (manual sections 7.2.1.2 and 7.2.2.2). This is the physical channel that carries the multiplexed 80188 data bus signals used by the shared-RAM mailbox protocol described in [Inter-CPU Communication](inter_cpu_communication.md).

Switch matrix, lamp matrix, and solenoid drivers are all anchored on the 8-bit board (connectors J2, J4, J6, J7, J8). The 16-bit board has **no** direct switch-matrix or driver connections — all I/O passes through the Z80.
