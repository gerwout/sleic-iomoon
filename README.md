# SLEIC IO Moon Pinball — Reverse Engineering & Tools

<p align="center">
  <img src="images/dmd_single_frame.png" alt="IO Moon DMD Frame" width="700">
</p>

**IO Moon** is a pinball machine manufactured in 1996 by **SLEIC** (*Creaciones e Investigaciones Electrónicas, S.L.*) based in Alcobendas, Madrid, Spain. The theme revolves around a space exploration mission to Jupiter. The machine was designed by Luis J. Gosálbez Carrasco (software), Toñi Hernandez (software), and Santos Aranda (hardware).

This repository documents the results of an extensive reverse engineering effort on the IO Moon ROM images. It contains analysis tools, annotated disassembly listings, and technical documentation covering the dual-CPU hardware architecture, the DMD graphics format, the OKI sound chip, and a ROM patch for tournament play.

---

## Table of Contents

- [Hardware Overview](#hardware-overview)
- [Repository Structure](#repository-structure)
- [Scripts & Tools](#scripts--tools)
- [Technical Documentation](#technical-documentation)
- [Annotated Assembly Listings](#annotated-assembly-listings)
- [ROM Files](#rom-files)
- [Manuals](#manuals)
- [Related Work](#related-work)
- [License](#license)

---

## Hardware Overview

<p align="center">
  <a href="images/overview_backbox_all_boards.jpg" target="_blank" rel="noopener">
    <img src="images/overview_backbox_all_boards_thumb.jpg" alt="IO Moon backbox — all boards in situ" width="800">
  </a>
  <br>
  <em>The IO Moon backbox with all five boards in situ. Click for the full 4096 × 3072 photograph.</em>
</p>

The IO Moon uses a **three-CPU architecture**:

| Component             | Specification                                                                          |
|-----------------------|----------------------------------------------------------------------------------------|
| Main CPU              | AMD N80C188-10 (16-bit) — IC1 on board 011-029A                                         |
| Main work RAM         | UMC UM62256D-70LL 32 K × 8 SRAM — IC12 on board 011-029A                                |
| 80188 chip-select PAL | AMD/MMI PAL20L10ACNS — IC7 on board 011-029A (**undumped**)                             |
| 80188 reset / watchdog | Maxim MAX699 supervisor — IC6 on board 011-029A                                        |
| Game ROM              | 2× 27C040 (IC10 `1001`, IC11 `1002`; 1 MB total) on board 011-029A                      |
| Display CPU           | Microchip PIC 16C57-HS/P — IC23 on board 011-029A (**undumped**)                        |
| Display               | 128 × 32 **gas plasma** dot panel, 4 brightness levels                                 |
| FM sound              | Yamaha YM3812 (IC60) + Yamaha YM3014B DAC (IC61) on board 011-029A                      |
| Voice synth           | OKI MSM6376 ADPCM — IC51 on board 011-029A                                              |
| Sound ROM             | 2× 27C040 (IC52 `1003`, IC53 `1004`; 1 MB total) on board 011-029A                      |
| NVRAM                 | Microchip 28C64A EEPROM — IC14 on board 011-029A (8 KB)                                 |
| Music balance         | Xicor X9C503P digital potentiometer — IC63 on board 011-029A                            |
| I/O CPU               | Goldstar Z8400A PS Z80A @ 8 MHz — IC1 on board 011-030A                                 |
| Z80 work RAM          | Goldstar GM76C28-10 2 K × 8 SRAM — IC7 on board 011-030A                                |
| Z80 I/O decode PAL    | AMD PAL16L8A-2CN — IC8 on board 011-030A (**undumped**)                                 |
| Z80 reset / watchdog  | Analog Devices ADM699AN supervisor — IC15 on board 011-030A                             |
| Z80 ROM               | 27C256 — IC5 (`1005`, 32 KB) on board 011-030A                                          |
| Driver arrays         | 2× ULN2803 — IC41 / IC51 on board 011-030A (lamp / solenoid current drive)              |
| Power                 | 220 V AC (European market)                                                             |

For the complete chip-by-chip inventory of each board, see [`docs/board_011-029A_ics.md`](docs/board_011-029A_ics.md) (16-bit board) and [`docs/board_011-030A_ics.md`](docs/board_011-030A_ics.md) (Z80 board).

The **80188** runs game logic, the state machine, scoring, the inter-CPU link, and **both** sound chips: the **OKI MSM6376** voice synth carries **speech and sound effects** (phrase number and start written through the IC50 and IC40 latches), while the **YM3812** FM synth carries the **music** — 10 FM tracks, memory-mapped via peripheral chip-select `/PCS5`. The YM3812 driver was located and byte-verified in the 80188 ROM: a register-write primitive at `D000:0D99` and a sequencer at `D000:0D37` reading a song-index table, with all 10 tracks decoding to valid OPL2 registers (see [`docs/iomoon_fm_extract.md`](docs/iomoon_fm_extract.md)). The **Z80** scans the switch matrix and drives the lamp matrix and solenoids; its sound routines issue commands to the 80188 over the inter-board link rather than driving the sound chips directly. The **PIC 16C57-HS/P** at IC23 generates the DMD raster timing — the 80188 writes frame data and control words into the DMD register area at segment `A000h`, and the PIC converts these into the timing the plasma panel needs; it does **not** drive the YM3812. These driver assignments were verified by tracing the 011-029 and 011-030 schematics and the ROM disassembly; see [`docs/board_011-029A_ics.md`](docs/board_011-029A_ics.md), [`docs/ym3812_pinmame_precedents.md`](docs/ym3812_pinmame_precedents.md), and [`docs/iomoon_fm_extract.md`](docs/iomoon_fm_extract.md).

The 80188 and Z80 communicate over connector **J1 — an 8-bit handshaken byte-port**, one byte at a time under a request/acknowledge handshake. There is **no shared RAM and no HOLD/HLDA bus arbitration**: J1 has no address bus, so segment `4000h` is 80188-private work RAM that the Z80 cannot reach. The Z80 forwards switch codes and sound-command bytes to the 80188 over J1; the 80188 reads each inbound byte at its `/PCS2` latch (`0xA0100`).

For a detailed breakdown of the hardware architecture, see:

- [Hardware Architecture](docs/hardware_architecture.md) — CPU boards, memory map, J1 inter-CPU link
- [16-bit Board IC Inventory](docs/board_011-029A_ics.md) — Every populated chip on the 80188 board with part number and function
- [Z80 Board IC Inventory](docs/board_011-030A_ics.md) — Every populated chip on the Z80 board with part number and function
- [DMD Graphics System](docs/dmd_graphics.md) — Display format, bitplanes, frame encoding
- [DMD Wire Protocol](docs/dmd_wire_protocol.md) — Signals on the PIC→plasma panel ribbon, frame-detect timing, measured clock rates
- [YM3812 PinMAME Precedents](docs/ym3812_pinmame_precedents.md) — How other PinMAME drivers attach the YM3812; what that implies for IO Moon
- [Chips Worth Dumping](docs/chips_to_dump.md) — The undumped programmable parts (one PIC, two PALs) with dumping procedures
- [Component Datasheets](datasheets/README.md) — Offline PDF datasheets for every IC on the boards, linked from the board IC inventories
- [Switch, Lamp & Solenoid Tables](docs/switch_lamp_solenoid.md) — Complete I/O mapping from the service manual
- [Z80 I/O Port Map](docs/z80_io_ports.md) — Port assignments and switch matrix scan routine
- [80188 Peripheral Configuration](docs/80188_config.md) — Chip select registers and memory mapping
- [Inter-CPU Communication](docs/inter_cpu_communication.md) — J1 8-bit byte-port protocol between the 80188 and Z80
- [Language Model & Service-Menu Navigation](docs/iomoon_language_and_service_menu.md) — `[1001]` language polarity (DMD-verified), the dead country-DIP path, switch codes, and the menu navigation flow

---

## Repository Structure

```
sleic-io-moon/
├── README.md                          # This file
├── scripts/
│   ├── dmd_viewer.py                  # DMD graphics viewer & exporter
│   ├── extract-oki-msm6376.py         # OKI ADPCM sound sample extractor
│   ├── iomoon_fm_extract.py           # YM3812 (OPL2) FM music extractor
│   └── io_moon_press_start_patch.py   # Tournament "PRESS START" ROM patch
├── docs/
│   ├── dmd_viewer.md                  # DMD Viewer documentation
│   ├── extract_oki_msm6376.md         # OKI extractor documentation
│   ├── iomoon_fm_extract.md           # YM3812 FM music extractor documentation
│   ├── press_start_patch.md           # PRESS START patch documentation
│   ├── hardware_architecture.md       # Hardware architecture overview
│   ├── board_011-029A_ics.md          # 16-bit / 80188 board IC inventory
│   ├── board_011-030A_ics.md          # 8-bit / Z80 board IC inventory
│   ├── chips_to_dump.md               # Undumped programmable parts + procedures
│   ├── dmd_graphics.md                # DMD graphics format & encoding
│   ├── dmd_wire_protocol.md           # PIC → plasma panel wire protocol
│   ├── ym3812_pinmame_precedents.md   # YM3812 hookup precedents in PinMAME
│   ├── switch_lamp_solenoid.md        # Switch, lamp, and solenoid tables
│   ├── z80_io_ports.md                # Z80 I/O port map & scan routine
│   ├── 80188_config.md                # 80188 peripheral configuration
│   ├── inter_cpu_communication.md     # Shared memory & bus arbitration
│   ├── game_software.md               # Game state machine & boot sequence
│   └── iomoon_language_and_service_menu.md  # Language polarity + service-menu navigation
├── datasheets/                        # Offline PDF datasheets for every board IC
│   ├── README.md                      # Datasheet catalogue (part → file → source)
│   ├── 80c188.pdf                     # Intel 80186/80188 CPU (IC1, 011-029A)
│   ├── z80_cpu_user_manual.pdf        # Zilog Z80 CPU (IC1, 011-030A)
│   ├── pic16c5x.pdf                   # Microchip PIC16C5X (IC23, 011-029A)
│   ├── ym3812.pdf                     # Yamaha YM3812 OPL2 (IC60, 011-029A)
│   ├── ym3014b.pdf                    # Yamaha YM3014B DAC (IC61, 011-029A)
│   ├── msm6376_oki_voice_synthesis_databook_1994.pdf  # OKI MSM6376 (IC51)
│   ├── pal20l10_pal16l8_mmi_pal_handbook_1983.pdf     # PALs (IC7/IC8)
│   └── … (EPROM, SRAM, EEPROM, supervisor, op-amp, 74-series logic, …)
├── asm/
│   ├── 80188_annotated.asm            # Fully annotated 80188 ROM disassembly
│   └── z80_annotated.asm              # Fully annotated Z80 ROM disassembly
├── roms/
│   ├── 1.3 Early version/             # Early ROM set
│   │   ├── README.md
│   │   ├── V1 3_01.bin                # Display ROM 1 (80188)
│   │   ├── V1 3_02.bin                # Display ROM 2 (DMD graphics)
│   │   ├── V1 3_03.bin                # Sound ROM 1 (OKI)
│   │   ├── V1 3_04.bin                # Sound ROM 2 (OKI)
│   │   └── V1 3_05.bin                # Z80 CPU ROM
│   └── 1.3 IPDB latest/               # Latest ROM set from IPDB
│       ├── README.md
│       ├── V1 3_01.bin                # Display ROM 1 (80188)
│       ├── V1 3_02.bin                # Display ROM 2 (DMD graphics)
│       ├── V1 3_03.bin                # Sound ROM 1 (OKI)
│       ├── V1 3_04.bin                # Sound ROM 2 (OKI)
│       ├── V1 3_05.bin                # Z80 CPU ROM
│       └── Start-Tournament-Patch/    # Tournament patch for this ROM set
│           ├── README.md
│           └── V1 3_01.bin            # Patched Display ROM 1
├── images/                            # Screenshots and board photographs
│   ├── dmd_single_frame.png
│   ├── dmd_static_screen.png
│   ├── dmd_grid_animated.png
│   ├── dmd_fonts.png
│   ├── dmd_dot_comparison.png
│   ├── dmd_invert_comparison.png
│   ├── dmd_plane_order_comparison.png
│   ├── overview_backbox_all_boards.jpg        # Full-resolution backbox photo
│   ├── 80188_board_011_029A.jpg               # 16-bit board photo
│   ├── z80-sleic-011-030A.jpg                 # Z80 board photo
│   ├── driver_board_sleic_011-027A.jpg        # Drivers board photo
│   └── sound_amplifier_board_sleic_011-024.jpg # Audio amplifier board photo
│   # Each board JPG also has a smaller *_thumb.jpg companion used for inline previews.
├── manuals/
│   ├── README.md
│   └── sleic_io_moon_manual_es.pdf    # Original Spanish service manual
└── research/                          # Investigative notes that informed the docs
    ├── board_inventory.md             # Original photo-by-photo IC inventory
    ├── 80188_to_z80_mailbox.md        # 80188→Z80 command-path investigation (J1 byte-port)
    ├── z80_irq_timing.md              # Z80 periodic-IRQ rate derivation
    ├── ym3812_oki_workarounds.md      # YM3812 hookup investigation
    ├── pinmame_boot_log/              # PinMAME first-boot tracing
    └── pinmame_session_2/             # PinMAME follow-up tracing
```

---

## Scripts & Tools

### [DMD Viewer](docs/dmd_viewer.md) — `scripts/dmd_viewer.py`

A Python tool for viewing, analyzing, and exporting DMD graphics from the IO Moon ROM. It can decode animated frames (400 frames, 2-bitplane, 4 brightness levels), static screens (274 bilingual text screens), scrolling credits, and font glyphs (131 characters in multiple sizes).

<p align="center">
  <img src="images/dmd_grid_animated.png" alt="DMD Grid View" width="700">
</p>

### [OKI MSM6376 Sound Extractor](docs/extract_oki_msm6376.md) — `scripts/extract-oki-msm6376.py`

Extracts individual ADPCM audio samples from OKI MSM6376 sound ROM files. The MSM6376 stores audio in 4-bit IMA/OKI ADPCM format. This tool reads the chip's internal sample index, extracts each sample as raw PCM, and optionally converts them to WAV files using FFmpeg.

### [YM3812 FM Music Extractor](docs/iomoon_fm_extract.md) — `scripts/iomoon_fm_extract.py`

The music counterpart to the OKI extractor. Extracts the IO Moon **YM3812 (OPL2) FM music** (10 tracks) straight from the 80188 code ROM (`V1 3_01.bin`), driven by the in-ROM song-index table rather than hard-coded offsets, and exports each track as raw register logs, standard VGM, and WAV (rendered through the offline DOSBox OPL2 core via PyOPL). The YM3812 driver was located and byte-verified in ROM — write primitive at `D000:0D99`, sequencer at `D000:0D37` — and decoding all 10 tracks yields zero invalid OPL2 registers.

### [PRESS START Patch](docs/press_start_patch.md) — `scripts/io_moon_press_start_patch.py`

A ROM patch for tournament use. After a game ends, the original IO Moon immediately transitions to attract mode, making it impossible to photograph or record final scores. This patch injects 80188 machine code into unused ROM space that displays "PRESS START" on the DMD and waits for the START button before returning to attract mode.

<p align="center">
  <a href="https://www.youtube.com/watch?v=wjNdBtwymYc">
    <img src="https://img.youtube.com/vi/wjNdBtwymYc/maxresdefault.jpg" alt="PRESS START Patch Demo" width="700">
  </a>
  <br>
  <em>Click to watch the PRESS START patch in action</em>
</p>

---

## Technical Documentation

Detailed write-ups covering the IO Moon hardware and software, based on ROM reverse engineering and the original SLEIC service manual:

| Document | Description |
|----------|-------------|
| [Hardware Architecture](docs/hardware_architecture.md) | Dual-CPU design, CPU board components, memory map, power connectors |
| [DMD Graphics System](docs/dmd_graphics.md) | Frame format (header, bitplanes, encoding), static screens, fonts, credits |
| [YM3812 FM Music Extractor](docs/iomoon_fm_extract.md) | The 80188 music engine (song-index table, sequencer opcodes, write primitive) and how the extractor exports the 10 FM tracks |
| [Switch, Lamp & Solenoid Tables](docs/switch_lamp_solenoid.md) | All 50 switches, 64 lamps, and 18 solenoids with codes and descriptions |
| [Z80 I/O Port Map](docs/z80_io_ports.md) | Port assignments, switch matrix scan routine, key Z80 RAM addresses |
| [80188 Peripheral Configuration](docs/80188_config.md) | Chip selects (UMCS, LMCS, PACS, MMCS, MPCS), wait states |
| [Inter-CPU Communication](docs/inter_cpu_communication.md) | J1 8-bit handshaken byte-port between the 80188 and Z80 (no shared RAM) |
| [Game Software Architecture](docs/game_software.md) | Boot sequence, main loop, state machine, text encoding, configuration system |

---

## Annotated Assembly Listings

The `asm/` directory contains fully annotated disassembly listings for both CPUs:

- **`80188_annotated.asm`** — The complete 80188 main CPU ROM (~10,458 instructions across segments D000h, E000h, and F000h). Covers the game state machine, DMD display routines, configuration system, scoring, and the boot sequence.

- **`z80_annotated.asm`** — The Z80 coprocessor ROM (27C256, 32 KB). Covers switch matrix scanning, lamp matrix control, solenoid drivers, the sound-command staging it forwards to the 80188, and communication with the 80188 over the **J1 byte-port** (Z80 port 0x80 data + port 0x81 strobes; the Z80 does not drive the sound chips directly).

---

## ROM Files

The `roms/` directory has placeholders for two known ROM sets. The IO Moon uses 5 ROM chips:

| Filename      | Chip   | Size | CPU | Content                                           |
|---------------|--------|------|-----|---------------------------------------------------|
| `V1 3_01.bin` | 27C040 | 512 KB | 80188 | Display ROM 1 (ROM1: game code + upper graphics)  |
| `V1 3_02.bin` | 27C040 | 512 KB | 80188 | Display ROM 2 (ROM2: lower graphics / DMD frames) |
| `V1 3_03.bin` | 27C040 | 512 KB | OKI | Sound ROM 1                                       |
| `V1 3_04.bin` | 27C040 | 512 KB | OKI | Sound ROM 2                                       |
| `V1 3_05.bin` | 27C256 | 32 KB | Z80 | CPU ROM (switch/lamp/solenoid/sound control)      |

To create a combined 1 MB ROM for use with `dmd_viewer.py`:

```bash
cat "V1 3_02.bin" "V1 3_01.bin" > io_moon_combined.bin
```

```cmd
copy /b "V1 3_02.bin" + "V1 3_01.bin" io_moon_combined.bin
```

> **Note:** ROM2 goes first (lower addresses 0x00000–0x7FFFF), then ROM1 (upper addresses 0x80000–0xFFFFF).

---

## Manuals

- [Original Spanish Service Manual](manuals/sleic_io_moon_manual_es.pdf) — 114 pages + 30 schematic pages


---

## Related Work

This repository supersedes the standalone [extract-oki-adpcm-from-rom](https://github.com/gerwout/extract-oki-adpcm-from-rom) repository. The OKI MSM6376 extractor script is now maintained here as part of the broader IO Moon reverse engineering effort. The standalone repository is deprecated.

Discussion about this project can be found on [Pinside](https://pinside.com/pinball/forum/topic/tool-to-extract-sound-from-a-sleic-rom-file).

---

## License

The scripts in this repository are released under the MIT License. The annotated disassembly listings and documentation are provided for educational and preservation purposes. All reverse engineering was conducted in accordance with Dutch and EU law, which permits reverse engineering for interoperability and error correction purposes.

SLEIC, IO Moon, and all related trademarks belong to their respective owners.
