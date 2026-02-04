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

## CPU Boards

### Main CPU Board — 80188 (16-bit)

| Component | Value                                                    |
|-----------|----------------------------------------------------------|
| CPU | Intel/AMD 80C188                                         |
| ROM | 4× 27C040 (512 KB each, 2 MB total)                      |
| Responsibilities | Game logic, DMD display, state machine, scoring, credits |

### Sound/Switch CPU Board — Z80 (8-bit)

| Component | Value | Reference |
|-----------|-------|-----------|
| CPU | Z80A @ 8 MHz | IC1 |
| ROM (main) | 27C256 (32 KB) | IC5 |
| RAM | 6116 (2 KB) | IC7 |
| Watchdog | MAX699 | IC15 |
| Crystal | 8 MHz | X10 |
| DIP Switch | 8-position | SW40 |
| Transistor arrays | 2× ULN2803 | IC41, IC51 |
| PAL | 16L8 | IC8 |
| Responsibilities | Switch scanning, lamp matrix, solenoids, OKI sound control |

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
| `0x0000`–`0x7FFF` | 32 KB | ROM IC5 (27C256) — main Z80 program |
| `0x8000`–`0xBFFF` | 16 KB | ROM IC6 (27C128) — secondary data |
| `0xC000`–`0xC7FF` | 2 KB | RAM IC7 (6116) — working memory |

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

## CPU Board Connectors

| Connector | Pin Count | Function |
|-----------|-----------|----------|
| J1 | — | 80188 Data Bus (D0–D7, C0–C11) |
| J2 | 20-pin ribbon | Switch Matrix (COL0–7, ROW0–7) |
| J3 | — | 80188 interface |
| J4 | 20-pin ribbon | Flipper/Bumper contacts |
| J5 | — | Multiplexer signals |

### J4 Pinout (Flipper/Bumper)

```
FIF, FIM   — Left Flipper signals
FDF, FDM   — Right Flipper signals
FAM        — Middle right Flipper signal
FBF, FBM   — Additional flipper signals
BC1–BC8    — Bumper contacts
```
