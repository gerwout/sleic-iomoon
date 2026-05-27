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

Principal components (from service manual section 7.2.1.1, page 93):

| Reference | Component | Part | Notes |
|-----------|-----------|------|-------|
| IC1 | Microprocessor | 80C188-10 | Main CPU |
| IC23 | Microprocessor | PIC 16C54HS (Microchip) | **DMD display coprocessor** |
| IC10 | EPROM | 27C040 | `1001 v1.2` (JUEGO — game code/data) |
| IC11 | EPROM | 27C040 | `1002 v1.2` (BANK — banked extension) |
| IC52 | EPROM | 27C040 | `1003 v1.2` (SONIDO 1 — sound samples) |
| IC53 | EPROM | 27C040 | `1004 v1.2` (SONIDO 2 — sound samples) |
| IC14 | EEPROM | 28C64A (Microchip) | 8 KB — non-volatile game settings/scores |
| IC51 | Voice synthesizer | OKI 6376 | ADPCM speech / FX playback |
| IC60 | Sound generator | Yamaha YM3812 | FM music |
| IC61 | DAC | Yamaha YM3014 | YM3812 output DAC |
| IC63 | Digital potentiometer | XICOR X9103 | Music balance (**not** NVRAM) |
| P60  | Potentiometer | — | Music balance (paired with X9103) |

> **Note on the X9103**: prior write-ups (including the MAME upstream driver header) describe the X9103 as NVRAM. The service manual explicitly labels it as an **EEPOT** (digital potentiometer) used together with the analog trimmer `P60` for music balance. The actual non-volatile storage chip is the **28C64A at IC14**.

The "responsibilities" attributed to the 80188 (game logic, state machine, scoring) are correct, but the DMD raster output is mediated by the PIC16C54HS coprocessor at IC23 — see the [DMD Graphics System](dmd_graphics.md) document.

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

#### Candidate PALs / unidentified glue ICs on board 011-029

The manual's principal-components table does **not** list any PAL on this board, but several positions in figure 7-1 look like they hold programmable logic rather than ordinary 74-series glue:

| Reference | Package size | Position | Why it's a PAL candidate |
|-----------|--------------|----------|--------------------------|
| IC8 | 20-pin DIP | top, immediately left of OSC1 | Adjacent to the oscillator — typical clock-divider / bus-arbiter location |
| IC20, IC21, IC22 | 20-pin DIPs | vertical stack between IC1 (80188) and IC23 (PIC) | Sits exactly where 80188 chip-select / DMD-bus glue would go |
| IC24 | 16-pin DIP | next to IC23 | Possible PAL16xx supporting the PIC |

These are the most likely sites for the "PAL20L40" the MAME upstream comment mentions as undumped (almost certainly a typo for PAL20L8 or PAL20L10 — see the discussion in the project workspace `CLAUDE.md`). Worth dumping along with IC23.

#### Unidentified 32-pin DIP sockets

- **IC12, IC13** — 32-pin sockets in the IC10/IC11 EPROM column. Not in the principal-components list. Plausible interpretations: unpopulated EPROM expansion sockets, a 32-pin SRAM, or a 32-pin DIP RTC/NVRAM module (e.g. ST M48T08). Confirmation requires a board photo.
- **IC54** — extra 32-pin socket adjacent to IC52/IC53 in the sound EPROM column. Likely an unpopulated sound-ROM expansion socket.

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
| IC1 | Microprocessor | Z80A (Zilog/SGS) | I/O CPU @ 8 MHz |
| IC5 | EPROM | 27C256 (Texas/SGS) | `1005 v1.2` (I/O) — 32 KB |
| SW40 | DIP switch block | 8-position | See DIP table below |

Additional ICs identified from board photographs / disassembly (not listed as "principal" in the manual):

| Reference | Component | Part | Notes |
|-----------|-----------|------|-------|
| IC7 | RAM | 6116 (2 KB) | Z80 working memory @ `0xC000`–`0xC7FF` |
| IC15 | Watchdog | MAX699 | Reset supervision |
| IC8 | PAL | 16L8 | I/O address decoding (equations not dumped) |
| IC41, IC51 | Transistor arrays | ULN2803 | Lamp / solenoid driver buffers |
| X10 | Crystal | 8 MHz | Z80 clock |

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
