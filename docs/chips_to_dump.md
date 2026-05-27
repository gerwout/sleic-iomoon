# Chips worth dumping

[← Back to main README](../README.md)

A consolidated list of every programmable / firmware-bearing device that has been identified on the IO Moon PCBs, ranked by value of dumping. This document is the single point of reference when planning a dumping session. It supersedes the looser mentions in [`hardware_architecture.md`](hardware_architecture.md) and `research/board_inventory.md`.

All listed parts are supported by the TL866II+/T48 universal programmer with its standard adapter set. PIC and PAL parts may have **read-protection fuses set**, in which case the dump comes back scrambled — see the per-chip notes.

---

## Priority list

| Rank | Ref | Board | Part (best read) | Why it matters |
|------|-----|-------|------------------|----------------|
| 1 | **IC23** | 011-029 (16-bit) | **Microchip `PIC 16C57-HS/P`** (PDIP-28, OTP) — board photo confirms 28-pin part, NOT the PIC 16C54 the manual lists | DMD raster coprocessor. Completely undumped; opaque to current emulation. 2048 × 12-bit program memory (4× a 16C54). |
| 2 | **IC34** | 011-029 | Likely Microchip `PIC 16C57-HC/P` (PDIP-28). Markings uncertain. | Undocumented coprocessor. **Strongest candidate for the missing YM3812 driver path**. |
| 3 | **IC57** | 011-029 | Likely Microchip `PIC 16C54-04/XL` (PDIP-18). Markings uncertain. | Second undocumented coprocessor. Same rationale as IC34. |
| 4 | **IC8** | 011-030 (Z80) | PAL16L8 (assumed; printed markings not photographed clearly yet) | I/O address decode for the Z80. Dumping it would complete the Z80 chip-select map. |
| 5 | (removed — not a new revision) | — | — | An earlier draft of this list flagged the `V1.3-02` sticker on IC10 as a newer revision. That was wrong: `V1.3-02` is the chip-number convention `V<set>-<chip number>`, i.e. chip 02 of the V1.3 set — the same generation as `v1_3_02.bin` in the archive. No new revision; nothing extra to dump here. |
| 6 | **IC20, IC21, IC22, IC24** | 011-029 | Candidate PALs (PDIP-20 stacked between the 80188 and IC23) | Possible site for the "PAL20L40" the MAME upstream comment lists as undumped (likely a typo for PAL20L8 or PAL20L10). |
| 7 | **IC14** | 011-029 | Microchip `28C64A-25` (PDIP-28) | NVRAM. Holds runtime configuration and high scores — useful for preserving a specific operator-tuned machine, less useful for emulation since the contents are dynamic. |
| 8 | **IC11, IC52, IC53** | 011-029 | 27C040 (PDIP-32, windowed) | Already archived as `v1_3_02/03/04.bin` but a re-dump from this exact physical board would confirm whether IC11/IC52/IC53 share the V1.2-04 or V1.3-02 revision. |
| 9 | **IC5** | 011-030 | 27C256 (PDIP-28, windowed) — `IO MOON V1.2-04` | Already archived as `v1_3_05.bin`. Re-dump from this board confirms revision parity. |
| 10 | **IC6** | 011-030 | PDIP-28 socket — population status unknown (covered by tape in current photos) | If populated, contents are unknown ("extended routines/data" per the Z80 disassembly). A "not included" entry in the asm listing. |

---

## Per-chip dumping notes

### IC23 — PIC 16C57-HS/P (DMD coprocessor)

- **Board**: 011-029, top-right region next to J2 (the 14-pin display ribbon). Adjacent components: JP7 jumper, IC24 small DIP, IC20/IC21/IC22 column.
- **Package**: **28-pin PDIP** — confirmed by macro crop of `IMG_20260527_212505.jpg`, top-mark reads `PIC16C57-HS/P / 9526 CCH/W / Microchip`. The service manual claims this position holds a PIC 16C54 (18-pin part), but the physical chip is a PIC 16C57 (28-pin). **Confirmed socketed.** No UV window — OTP variant.
- **Why 16C57 matters**: 2048 × 12-bit program memory vs the 16C54's 512 × 12-bit, and 20 I/O pins vs 12 on the 16C54. Enough difference that the firmware reverse-engineering process is qualitatively different.
- **Programmer**: TL866II+ in **PIC16C57** mode. Read program memory (2048 × 12-bit) and the configuration word separately.
- **Code-protect fuse (CP)**: unknown until first read attempt. If CP is set, the program-memory dump returns scrambled / 0xFFF data. The PIC16C5x family is well known to have a *weak* CP — some programmers have firmware support for "unprotect" sequences (Pavel Zima's published method), but the safest assumption is "if CP is set, the chip is recoverable only via decap, which is destructive".
- **Procedure**: pull from socket, drop into TL866II+ ZIF, run `minipro -p PIC16C54 -r config.hex -c config` first; inspect the CP bit; only if `/CP = 1` (not protected) read `minipro -p PIC16C54 -r iomoon_pic_ic23.hex -c code`.

### IC34 — likely PIC 16C57

- **Board**: 011-029, in the glue-IC row beneath IC22.
- **Package**: 28-pin PDIP. Socketed status not yet confirmed.
- **Why it's interesting**: the empirical PinMAME tracing in `research/pinmame_session_2/00_summary.txt` finds zero writes to the YM3812 from either the 80188 or the Z80, but IC60 (YM3812) is confirmed populated. A coprocessor doing the writes — most naturally a PIC reading sound commands from shared RAM — explains both observations.
- **Programmer**: TL866II+ in PIC16C57 mode if confirmed as a PIC16C57. **First step is to take a macro photo and confirm the markings** — the auto-disassembled label could read either `PIC16C57-HC/P` or `PT8SC5T-HC/P` (a possible custom Sleic-marked part). If it's a custom mask ROM, do not attempt to dump.

### IC57 — likely PIC 16C54-04/XL

- **Board**: 011-029, bottom-right of the board.
- **Package**: 18-pin PDIP.
- **Markings observed**: `PIC16C(?)/04XL / 9277BNCN` — consistent with Microchip PIC16C54-04/XL (4 MHz, extended-temperature plastic).
- **Why it's interesting**: same rationale as IC34. If both IC34 and IC57 are PICs, one of them most likely drives the YM3812 while the other handles a different audio path (OKI? DAC?).
- **Programmer**: TL866II+ in PIC16C54 mode. Same CP caveat as IC23.

### IC8 — PAL16L8 (Z80 board)

- **Board**: 011-030, top-centre, immediately to the right of the SW40 DIP switch block.
- **Package**: 20-pin PDIP.
- **Why it's interesting**: this PAL generates the chip-select signals for the Z80's I/O ports (`0x00-0x04 IN`, `0x80-0x87 OUT`) and possibly for the inter-CPU bus access. Its equations would tell us where the IC6 socket (extension ROM) is selected, and whether any other ports decode to peripherals we have not yet identified.
- **Programmer**: TL866II+ in PAL16L8 mode. PAL16L8 is fuse-mapped, so the dump is a `.jed` file rather than a binary, and reading it back into PAL equations requires a JEDEC decoder.
- **Security fuse (SEC)**: as with PICs, if the security fuse is blown, the chip returns no useful data. Older Sleic boards (mid-1990s) generally did not secure their PALs but it is not guaranteed. If SEC is set the only recovery is to **reverse the truth table by clipping the chip in-circuit and exercising every input combination** while reading every output.

### IC20, IC21, IC22, IC24 — candidate PALs on the 16-bit board

- **Board**: 011-029, vertical stack between the 80188 (IC1) and the PIC (IC23), in the top-right region.
- **Packages**: IC20/IC21/IC22 are PDIP-20, IC24 is PDIP-16.
- **Status**: their top-marks were not readable at the resolution of the current board photos. They may be PALs or they may be ordinary 74LSxx glue. The position (right between the CPU and the DMD coprocessor) is exactly where 80188 chip-select / DMD-bus glue would sit, which is why they are flagged as candidates.
- **Before dumping**: take a macro photograph of each top-mark. If they read as `PAL16Lx`, `GAL16V8`, `PALCE16V8`, `PAL20Lx` — they are programmable. If they read as `74LSxx` — they are not.

### IC10 (V1.3-02 sticker), IC11, IC52, IC53 — 27C040 EPROMs on the 16-bit board

- **Board**: 011-029, two columns of windowed EPROMs (game code on the left, sound on the right).
- **Status**: archived versions are V1.2-04 (filenames `v1_3_01..04.bin` in `roms/1.3 IPDB latest/`). One physical board photographed shows IC10 carrying a **V1.3-02** sticker — possibly a newer service-released revision. Worth re-dumping to confirm and archiving as a separate ROM set.
- **Programmer**: TL866II+ in 27C040 mode. No security fuse on EPROMs — clean read every time.

### IC14 — 28C64A EEPROM (NVRAM)

- **Board**: 011-029.
- **Status**: confirmed `MICROCHIP / 28C64A-25` (PDIP-28). Contents are runtime-mutable (high scores, operator settings).
- **Programmer**: TL866II+ in AT28C64A mode. Dump and **put the chip back** if you want to preserve the operator's existing high-score table. A live in-circuit read with a SOIC clip is theoretically possible but the chip is full-size DIP so the simplest procedure is pull + read + replace.

### IC5 (Z80 ROM) and IC6 (Z80 extension socket)

- **Board**: 011-030.
- **IC5**: 27C256 windowed, sticker `IO MOON V1.2-04`. Already archived.
- **IC6**: 28-pin PDIP socket. Population status indeterminate from current photos (covered by paper tape). The Z80 disassembly references IC6 as "extended routines/data, not included" — meaning the disassembler knew about the socket but did not have a dump for it.
- **Action**: remove the tape and check the socket. If a chip is present, dump it; if the socket is empty, document that.

---

## Equipment

| Item | Use |
|------|-----|
| **TL866II+ / T48 universal programmer** | Reads all of the listed parts in one tool. Cheapest is the TL866II+, ~$50 USD; T48 is the newer successor with improved low-voltage support. |
| Linux `minipro` CLI tool | Open-source driver for the TL866II+. Pacman: `minipro`, apt: `minipro`. |
| MPLAB IPE + PICkit 4/5 | Alternative for PIC parts only; needs MPLAB X. The TL866II+ is more convenient if you have only Microchip parts to dump. |
| ZIF-DIP adapters | 32-pin universal ZIF preferred; 40-pin needed for the Z80 (although the Z80 itself is not on the dumping list — it's a CPU, not a programmable part). |
| IC extractor (PLCC, DIP) | Each chip is socketed; gentle removal with an extractor is far less risky than tipping with a screwdriver. |

---

## Procedure overview

1. **Power down the machine**, wait for PSU caps to discharge (~2 min).
2. **Photograph each socketed chip** end-on before pulling, so the orientation (pin 1 location) is preserved for re-insertion.
3. **For each PIC**: read the config word first (`-c config`), inspect the `/CP` bit, then read program memory only if `/CP = 1` (= not protected).
4. **For each PAL**: read into a `.jed` file. If the SEC fuse is set, the read returns all-`F`s and the part is not recoverable without truth-table reconstruction.
5. **For each EPROM/EEPROM**: straight binary read. Verify against the archived SHA1 sums if the part is already known.
6. **Re-insert each chip pin-1-oriented as it was**. Visually inspect under magnification before powering up.

---

## What this dump set would unlock

- **IC23**: emulation of the DMD raster path becomes possible (or, more pragmatically, the firmware can be analysed to confirm the wire-protocol details already inferred from PPUC dmdreader + the Saleae capture).
- **IC34 + IC57**: explanation of how the YM3812 is driven on IO Moon — the single largest open question in the current PinMAME work.
- **IC8 PAL16L8**: completes the Z80 chip-select map, may reveal additional peripherals the current docs miss.
- **IC10 V1.3-02**: a new ROM revision in the project archive if it's truly different from V1.2-04.
- **IC20–IC24**: if any of them are PALs, completes the 80188 chip-select map.

---

## Cross-references

- Detailed photographic identification: [`../research/board_inventory.md`](../research/board_inventory.md).
- The empirical evidence that motivates dumping IC34 / IC57: [`../research/pinmame_session_2/`](../research/pinmame_session_2/) (the YM3812 silence in a running 80188 emulation despite a populated chip).
- PIC dumping how-to and CP-fuse notes are also discussed in this project's `CLAUDE.md` workspace file.
