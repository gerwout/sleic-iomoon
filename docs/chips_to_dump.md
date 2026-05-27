# Chips worth dumping

[← Back to main README](../README.md)

A consolidated list of every programmable / firmware-bearing device that has been identified on the IO Moon PCBs, ranked by value of dumping. This document is the single point of reference when planning a dumping session. It supersedes the looser mentions in [`hardware_architecture.md`](hardware_architecture.md) and `research/board_inventory.md`.

All listed parts are supported by the TL866II+/T48 universal programmer with its standard adapter set. PIC and PAL parts may have **read-protection fuses set**, in which case the dump comes back scrambled — see the per-chip notes.

---

## Priority list

| Rank | Ref | Board | Part (best read) | Why it matters |
|------|-----|-------|------------------|----------------|
| 1 | **IC23** | 011-029 (16-bit) | **Microchip `PIC 16C57-HS/P`** (PDIP-28, OTP) — board photo confirms 28-pin part, NOT the PIC 16C54 the manual lists | DMD raster coprocessor. **Likely also the YM3812 sound driver** (only programmable microcontroller on the board; 20 I/O pins are enough for both jobs). Completely undumped; opaque to current emulation. 2048 × 12-bit program memory (4× a 16C54). |
| 2 | **IC7** | 011-029 | **AMD/MMI `PAL20L10ACNS`** (PDIP-24) — markings confirmed in `IMG_20260527_212833.jpg` | Bus / chip-select glue on the 80188 side. Almost certainly the "PAL20L40" that MAME upstream lists as undumped — `20L40` is a typo for `20L10`. Dumping it would complete the 80188 chip-select decode. |
| 3 | (removed) | (was listed as 011-030 / Z80) | IC8 was previously listed as a candidate PAL16L8 per the service manual. Two corrections from direct chip readout: (a) IC8 is on the **16-bit board** `011-029`, not the Z80 board; (b) it is a National Semiconductor `DM74LS74AN` dual D flip-flop (PDIP-14, date code 9536). Nothing programmable to dump at this position. The Z80 board has no confirmed PAL at all. |
| 4 | (removed) | 011-029 | IC24 was the last unread candidate PAL on the 16-bit board. User readout confirms it is a TI `SN74LS07N` hex buffer / driver, lot code `4CCFXRK`. Nothing programmable. **The chip identification phase on this board is now complete:** only IC23 (PIC 16C57) and IC7 (PAL 20L10) are programmable parts. |
| 5 | **IC14** | 011-029 | Microchip `28C64A-25` (PDIP-28) | NVRAM. Holds runtime configuration and high scores — useful for preserving a specific operator-tuned machine, less useful for emulation since the contents are dynamic. |
| 6 | **IC11, IC52, IC53** | 011-029 | 27C040 (PDIP-32, windowed) | Already archived. The "V1.3-02" sticker on IC10 reads as set-chip notation (chip 02 of V1.3 set), NOT a sub-revision; nothing new to dump from these sticker labels alone. |
| 7 | **IC5** | 011-030 | 27C256 (PDIP-28, windowed) — `IO MOON V1.2-04` | Already archived as `v1_3_05.bin`. Re-dump from this board confirms revision parity. |
| 8 | **IC6** | 011-030 | PDIP-28 socket — population status unknown (covered by tape in current photos) | If populated, contents are unknown ("extended routines/data" per the Z80 disassembly). A "not included" entry in the asm listing. |

---

## Per-chip dumping notes

### IC23 — PIC 16C57-HS/P (DMD coprocessor)

- **Board**: 011-029, top-right region next to J2 (the 14-pin display ribbon). Adjacent components: JP7 jumper, IC24 small DIP, IC20/IC21/IC22 column.
- **Package**: **28-pin PDIP** — confirmed by macro crop of `IMG_20260527_212505.jpg`, top-mark reads `PIC16C57-HS/P / 9526 CCH/W / Microchip`. The service manual claims this position holds a PIC 16C54 (18-pin part), but the physical chip is a PIC 16C57 (28-pin). **Confirmed socketed.** No UV window — OTP variant.
- **Why 16C57 matters**: 2048 × 12-bit program memory vs the 16C54's 512 × 12-bit, and 20 I/O pins vs 12 on the 16C54. Enough difference that the firmware reverse-engineering process is qualitatively different.
- **Programmer**: TL866II+ in **PIC16C57** mode. Read program memory (2048 × 12-bit) and the configuration word separately.
- **Code-protect fuse (CP)**: unknown until first read attempt. If CP is set, the program-memory dump returns scrambled / 0xFFF data. The PIC16C5x family is well known to have a *weak* CP — some programmers have firmware support for "unprotect" sequences (Pavel Zima's published method), but the safest assumption is "if CP is set, the chip is recoverable only via decap, which is destructive".
- **Procedure**: pull from socket, drop into TL866II+ ZIF, run `minipro -p PIC16C54 -r config.hex -c config` first; inspect the CP bit; only if `/CP = 1` (not protected) read `minipro -p PIC16C54 -r iomoon_pic_ic23.hex -c code`.

### IC7 — PAL 20L10ACNS

- **Board**: 011-029, lower-centre, below IC60 (the YM3812) and to the left of IC56 (a 74LS139 decoder).
- **Package**: 24-pin PDIP.
- **Markings observed in `IMG_20260527_212833.jpg`**: top-mark reads clearly `20L10ACNS / BRDN`. This is an AMD/MMI PAL20L10 in commercial-grade plastic. The earlier subagent pass mis-read this chip as a PIC 16C54 — that was wrong.
- **Why it's interesting**: this is almost certainly the chip the MAME upstream `sleic.cpp` comment lists as `Undumped PALs: 20L40, 16L8`. `20L40` is not a standard PAL part number; it is most plausibly a typo for `20L10` (the only other entry in that part-number range with 10-output suffix), and IC7's location next to the 80188 main bus is exactly where chip-select decode glue would sit. Dumping it would complete the 80188 chip-select map.
- **Programmer**: TL866II+ in `PAL20L10` mode. Output is a JEDEC fuse map (`.jed`), not a binary.
- **SEC fuse caveat**: as with all PALs, if the security fuse is blown the JEDEC dump returns all-`F`s and the only recovery is to reverse-engineer the truth table by exercising every input combination in a test fixture.

### (Note on the chips formerly listed as IC34 and IC57)

The earlier draft of this list called IC34 and "IC57" candidate PICs based on a subagent's reading of board photos. Both readings turned out to be wrong:

- **"IC57" doesn't exist** as a silkscreen designator on the board. The chip the subagent saw is at silkscreen position **IC7**, and it is the PAL 20L10 listed above — not a PIC.
- **IC34** is `CD74HC151E` — a TI / NS 74HC151 8-to-1 multiplexer in a 16-pin DIP, date code `H9540`. Confirmed by reading the physical chip top-mark. Ordinary HC-series combinational glue, not a microcontroller. Nothing to dump.

The only microcontroller on the 16-bit board is **IC23 (PIC 16C57)** — at the top of this list.

### (Note on the chip formerly listed as IC8 = PAL16L8)

The Io Moon service manual labels IC8 as a `PAL 16L8` on the Z80 board. User readout of the physical chip shows two things wrong with that label:

1. **IC8 is on the 16-bit board `011-029`, not the Z80 board.** The Z80 board (`011-030`) has no IC8 silkscreen position.
2. **The chip's top-mark is `NP9536SD / DM74LS74AN`** — a National Semiconductor `DM74LS74AN` dual D-type flip-flop in 14-pin PDIP, manufactured 1995 week 36. Not a PAL.

The most likely source of the manual's "PAL 16L8 at IC8" claim is cross-contamination from the Bike Race schematic — MAME's own comment in `sleic.cpp` explicitly notes that "the only known schematic is for Bike Race". Bike Race may have a 16L8 at its IC8 on its Z80 board; Io Moon does not.

**There is no known PAL on the Io Moon Z80 board.** The Z80 I/O port decode (ports 0x80–0x87 OUT, 0x00–0x04 IN) is therefore implemented in straight 74LS-series glue rather than a programmable device. The earlier hypothesis that an undumped PAL16L8 was responsible for routing the OKI 6376 strobe or the inter-CPU bus access has no chip to attribute it to. If a fresh inspection finds a 20-pin DIP elsewhere on the 8-bit board with a `PAL` / `GAL` part number, this section needs revising.

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
