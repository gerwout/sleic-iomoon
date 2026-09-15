# Chips worth dumping

[← Back to main README](../README.md)

Three programmable chips across the two CPU boards carry firmware that was never publicly dumped. The security / code-protect fuse is blown on all three, so none can be read directly with a programmer. All three now have a dump; the IC8 read is the one that still needs work, and its own README says why.

## Status

| Ref  | Part                       | Package        | Board             | State |
|------|----------------------------|----------------|-------------------|-------|
| IC23 | Microchip PIC 16C57-HS/P   | PDIP-28 (OTP)  | 011-029A (16-bit) | **Dumped** — archived at [`../roms/PIC16C57/`](../roms/PIC16C57/), disassembled in [`../asm/pic16c57_annotated.asm`](../asm/pic16c57_annotated.asm) |
| IC7  | AMD/MMI PAL20L10ACNS       | PDIP-24        | 011-029A (16-bit) | **Dumped** — archived at [`../roms/PAL20L10/`](../roms/PAL20L10/): truth table, equations and JEDEC |
| IC8  | AMD PAL16L8A-2CN           | PDIP-20        | 011-030A (Z80)    | **Dumped, with an unresolved conflict** — archived at [`../roms/PAL16L8/`](../roms/PAL16L8/) |

The IC23 dump came from a commercial chip-recovery lab, which defeated the code protection and returned a verified-good image; the lab's adaptation of it for the pin-compatible flash **PIC16F57** runs in the real machine. Authentication is described in [`../roms/PIC16C57/README.md`](../roms/PIC16C57/) and [`../research/pic16c57_protection_analysis.md`](../research/pic16c57_protection_analysis.md): the recovered code reproduces the locked chip's scrambled nibble-XOR read-back for all 2048 words.

The IC7 dump came from a **dupico (DuPAL V3)** bench rig — Path B below, and the route this document recommends for a locked bipolar PAL. The fuse map was never read; the chip's behaviour was measured over all 16384 input combinations and re-synthesised into a JEDEC that reproduces it exactly. Details and the decoded map: [`../roms/PAL20L10/README.md`](../roms/PAL20L10/README.md).

**No PAL blocks emulation.** The PinMAME `SLEIC2` driver implements the whole machine — boot, DMD, switches, lamps, drivers, coin and credit, the service menu, gameplay, and both sound chips — from the two CPU ROMs and the IC23 dump.

- **IC7** decodes the program-ROM select, the two halves of the MCS0 RAM block, the non-volatile store's chip enable, the DMD staging-buffer write strobe, the OKI phrase-latch clock and the 80188's `/TEST` input. It confirms finding **F10**'s two-bit NVRAM gate from the silicon side. It carries neither the graphics-page address lines nor the OKI data bus, so the two bit-order questions in **F2** and **F9** that were expected to fall to it stay open — see [`../roms/PAL20L10/README.md`](../roms/PAL20L10/README.md).
- **IC8** decodes the Z80 side. The bench read confirms the I/O-read and I/O-write enables that gate the port decoders at IC16 and IC17, and an interrupt-acknowledge decode on the path that clears the Z80's `/INT` latch — but it recovers **no memory chip select**, which the board demonstrably needs. That conflict is open and is set out in [`../roms/PAL16L8/README.md`](../roms/PAL16L8/README.md).

Everything else on the IO Moon boards is either already archived (the 27C040 program / display / sound EPROMs and the 27C256 Z80 ROM) or runtime-mutable (the 28C64A NVRAM at IC14 on the 16-bit board). For the full board IC lists and the function of every other chip, see [`board_011-029A_ics.md`](board_011-029A_ics.md) and [`board_011-030A_ics.md`](board_011-030A_ics.md).

### Other machines

This document is about IO Moon's own two boards. **Doña Elvira 2** has outstanding parts of its own — a re-read of the `ELVSON3` sample EPROM, and the three `6331` character-generator PROMs on its display board, which have never been dumped. Neither is a protected part, so neither needs anything in this document's Path B; both are covered in [`dona_elvira_2.md`](dona_elvira_2.md).

## How to read this document

A protectable chip can be in one of two states, and the recovery path depends on which:

- **Unlocked** — the security / code-protect fuse has never been blown. A direct read returns the real contents.
- **Locked** — the security / code-protect fuse is blown. A direct read returns garbage (a nibble-XOR fold for the PIC, all-`F`s for a PAL). Recovery requires substantially more work, equipment, or money.

All three IO Moon parts are locked, so the Path B section of each is the one that applies here; Path A is kept because it is the cheaper route on any other board where the fuse is intact, and the state is only discoverable by attempting a read.

A common misconception is that a TL866II+ / T48 universal programmer can read every chip on this list. That is **not true** for the two PALs — see the bipolar-PAL note below.

---

## IC23 — PIC 16C57-HS/P  (16-bit board, 011-029A)  ✅ DUMPED

The chip is locked, so Path B below is the route that produced the dump: a commercial recovery lab defeated the protection. The returned image verifies locally — 100 % valid 12-bit instructions, correct `GOTO 0x000` reset vector at `0x7FF`, all jump targets in range — and it reproduces the locked chip's scrambled read-back for **2048/2048 words**, which authenticates it against this exact physical chip. A direct read of the locked part yields only the XOR of the three nibbles of each 12-bit word (12 bits collapse to 4), so it carries no recoverable code. Dump and full details: [`../roms/PIC16C57/`](../roms/PIC16C57/); disassembly: [`../asm/pic16c57_annotated.asm`](../asm/pic16c57_annotated.asm).

- **Datasheet**: [`../datasheets/pic16c5x.pdf`](../datasheets/pic16c5x.pdf) (Microchip PIC16C5X family).
- **Role**: DMD raster coprocessor, and nothing else. The program is 150 words: a free-running raster that walks the video-RAM address on PORTB (`VA` lines to the IC33 staging SRAM), sequences the row/latch/frame strobes on PORTA/PORTC (`RDATA`, `RCLK`, `COLATCH`, `DE`, `VSYNC`), and waits on T0CKI for the external serialiser's per-burst tick. It has **no command interface**: the only input pin, RC7, is never sampled, and it exchanges no byte with the 80188 in either direction. It does not drive the YM3812 — that chip is selected directly by the 80188's `/PCS5`, and every PIC I/O pin is a DMD signal (sheets 011-029-01, -03 and -07).
- **Memory**: 2048 × 12-bit OTP program memory, 72 bytes RAM, 20 I/O pins; 150 words programmed.
- **Mounting**: socketed.

### Path A — chip is unlocked (CP fuse not blown)

The 16C5x family is CMOS and is supported by the TL866II+ / T48 universal programmer driven by `minipro`. Total cost of the tooling: ~$50 USD for the programmer.

1. Power down the machine and let the PSU discharge (~2 min).
2. Remove the chip with hot-air rework or a low-thermal-shock alloy like Chip-Quik. Install a 28-pin DIP socket in its place so future dumps are non-destructive.
3. Read the configuration word first and inspect the `/CP` bit:
   ```
   minipro -p PIC16C57 -r ic23_config.hex -c config
   ```
4. If `/CP = 1` (= not protected), read the program memory:
   ```
   minipro -p PIC16C57 -r ic23_code.hex -c code
   ```
5. Re-insert the chip pin-1-oriented and visually inspect before powering up.

### Path B — chip is locked (CP fuse blown)

The 16C5x family has no software unprotect. A locked PIC will return `0xFFF` from the program-memory read regardless of the programmer. The realistic options:

- **Ship the chip to a specialised chip-recovery lab.** Several commercial outfits offer PIC decap + microscope readout or electrical-glitch attacks against the security fuse. Cost is typically $200–$2000 USD per chip, depending on the lab and how much the firmware is worth.
- **Hobbyist decapping** is documented in the academic literature (Skorobogatov and others) but the success rate without specialised equipment is very low. Not realistic for a one-off preservation effort.

In practice, if the chip turns out to be locked, sending it to a recovery lab is the only path that has a meaningful chance of success.

---

## IC7 — PAL 20L10ACNS  (16-bit board, 011-029A)  ✅ DUMPED

The chip is locked, so Path B below is the route that produced the dump: a dupico (DuPAL V3) rig walked all 16384 input combinations and the resulting equations were compiled back to a JEDEC that reproduces the measurement on every one of them. Dump, decoded map and method: [`../roms/PAL20L10/`](../roms/PAL20L10/).

- **Datasheet**: [`../datasheets/pal20l10_pal16l8_mmi_pal_handbook_1983.pdf`](../datasheets/pal20l10_pal16l8_mmi_pal_handbook_1983.pdf) (MMI PAL Handbook — PAL20L10 device structure / fuse map).
- **Role**: combinational chip-select / bus glue on the 80188 main bus.

  The 80188's internal chip-select unit (UMCS / LMCS / MMCS / PACS / MPCS, programmed at boot — UMCS = `C03C` opens the ROM window) covers the large blocks, but its outputs are whole windows with no cycle qualification and no sub-division. IC7 takes those windows in — `/LCS`, `/UCS`, `/MCS0`, `/MCS1`, `/MCS3`, `/PCS4`, `/PCS6` — together with `A15`, the `/WR` strobe, the `DECH`/`DECL` pair and the two `EEE` gate bits latched in IC40, and turns them into the eight selects the board actually needs:

  - **`/PRCS`**, the program-EPROM select, reached from *both* `/LCS` and `/UCS` — which is why ROM1 (IC10) answers in two places, its low half at `0x00000` and its high half at `0xC0000`.
  - **`/RAM1`** and **`/RAM2`**, the 64 KB MCS0 block split in half on `A15`: the work RAM at IC12 occupies the lower half only, and the upper half's select has no memory behind it.
  - **`/EECE`**, the 28C64A NVRAM at IC14, enabled only in the lower half of the MCS1 window and only while the two IC40 gate bits hold opposite values.
  - **`/WRVRAM`**, the write strobe into the DMD staging SRAM at IC33 (segment `7000h`), and **`/OKCS`** and **`/OOE`**, the `/PCS6` and `/PCS4` writes qualified by `/WR` — `/OKCS` being the clock that latches the OKI phrase byte into IC50.
  - **`/TEST`**, which is not a select at all: it drives the 80188's `/TEST` pin from the EEPROM's ready line.

  What IC7 does *not* touch is as informative. The J1 byte-port latches on `/PCS1`–`/PCS3` and the YM3812 on `/PCS5` are selected by the 80188's own lines directly; the IC40 control latch is clocked by IC47A (`/PCS0` OR `/WR`), not by IC7; and the graphics-ROM page-select bits go from IC40 straight to IC11's high address lines. The NVRAM write protection the board analysis expected here does exist, but it sits on the chip *enable* as a two-bit interlock rather than on a write-enable line.

- **Mounting**: soldered.

- **The recovered equations.** Each output is active low and asserts when the right-hand side holds; the names are the schematic's, the logic is the dump's.

  | Pin | Net | Asserts when |
  |-----|-----|--------------|
  | 23 | `/PRCS`   | (`DECH`=0 · `DECL`=0 · `/LCS`) + (`DECH`=1 · `DECL`=1 · `/UCS`) |
  | 22 | `/RAM1`   | `/MCS0` · `A15`=0 |
  | 21 | `/RAM2`   | `/MCS0` · `A15`=1 |
  | 20 | `/OKCS`   | `/PCS6` · `/WR` |
  | 19 | `/OOE`    | `/PCS4` · `/WR` |
  | 18 | `/EECE`   | `/MCS1` · `A15`=0 · `EEE1`=0 · `EEE2`=1 |
  | 17 | `/TEST`   | `EEEREADY`=1 |
  | 14 | `/WRVRAM` | `/MCS3` · `/WR` |

  `/TEST` is the one that is not a select: the 80188's `WAIT` instruction blocks until `/TEST` goes low, so the board offers a hardware handshake on EEPROM write completion. **This firmware never uses it** — opcode `0x9B` appears nowhere as an instruction in either CPU ROM. The full reading, with the F10 cross-check, is in [`../roms/PAL20L10/README.md`](../roms/PAL20L10/README.md).

- **What it does not settle**: the two bit-level questions on the 80188 side stay open. The graphics-page selector's `A16`–`A18` order (finding F2) and the OKI latch's bit-to-pin mapping (finding F9) both live on signals that never reach IC7 — the page bits go from IC40 straight to ROM2, and the phrase byte goes from the data bus through IC50 to the MSM6376, with IC7 supplying only that latch's clock. A scope or a trace of IC40/IC50's outputs is what remains. The emulated map itself is pinned down by the boot chip-select table, which the driver hard-wires.

### Device structure and feedback path (schematic sheets 011-029-01 / -05, pin directions from the dump)

Pin assignments read directly from the IC7 symbol on sheet 1 and the latch logic on sheet 5; which of them the die drives comes from the bench read:

- **12 dedicated inputs** (pins 1–11, 13): `/LCS`, `/UCS`, `/MCS0`, `/MCS1`, `/PCS4`, `/PCS6`, `DECH`, `DECL`, `EEE1` (pin 9), `EEE2` (pin 10), `A15`, `/MCS3` (pin 13).
- **2 dedicated outputs** (pins 14, 23): `/WRVRAM` (14), `/PRCS` (23).
- **8 I/O pins** (pins 15–22): `EEEREADY` (15), `/WR` (16), `/TEST` (17), `/EECE` (18), `/OOE` (19), `/OKCS` (20), `/RAM2` (21), `/RAM1` (22).
- The 20L10 is purely combinational: no clock pin, no registered outputs. The dump confirms this directly — no output changes across a clock edge on any pin, and every input pattern reproduces identically when revisited out of order.

**Two of the eight I/O pins are programmed as inputs, and the dump is what shows it.** Pins 15 (`EEEREADY`) and 16 (`/WR`) never drive in any of the 16384 input combinations: their three-state enable terms are never satisfied, so they are permanently high-Z and feed the array only. In-circuit IC7 therefore presents **14 inputs and 8 outputs**, not 12 and 10 — `EEEREADY` is the EEPROM's ready line coming *in* from IC14, and `/WR` is the 80188's write strobe coming *in* from the bus, which IC7 uses to qualify `/OKCS`, `/OOE` and `/WRVRAM`.

**The board's feedback loop runs through other chips, not through the die.** `/WR` is OR'd with `/PCS0` in IC47A (74LS32); that gate output clocks IC40 (74LS273), which latches data-bus bits `D0–D7` onto its outputs, two of which are `EEE1` (4Q = `D3`) and `EEE2` (5Q = `D4`). `EEE1`/`EEE2` then return to IC7 pins 9/10. So the 80188 writes the PCS0 control byte, the write is qualified by `/WR`, and two of the latched bits arrive at IC7 as inputs — but `/WR` reaches both IC47A and IC7 as a bus signal, so no IC7 output is in the loop. The `/EECE` equation names those two bits directly (`EEE1`=0 **and** `EEE2`=1), which matches `pcs0_window_open` `D057E` clearing PCS0 bit 3 and setting bit 4, and pins `EEE1` = bit 3, `EEE2` = bit 4.

### Important — this is a bipolar PAL, not a CMOS PALCE

The `PAL20L10ACNS` is a **bipolar fuse-link PAL** from the original AMD/MMI process, not one of the CMOS-EEPROM PALCE / PALC / ATF / GAL successors. This matters because the modern budget programmers do not cover the original bipolar PAL family at all — their device libraries jump straight to the CMOS variants. Reading a bipolar PAL requires a programmer that can drive the higher fuse-verify voltages and time the read sequence the way the bipolar process expects. This rules out almost every piece of cheap-and-easy tooling that handles the PIC and the EPROMs.

### Path A — security fuse intact (unlocked)

IC7's fuse is blown, so this path does not apply to it; it is kept because it is the cheaper route on any other board where the fuse is intact, and the state is only discoverable by attempting a read. A vintage or professional programmer with native bipolar PAL support is required. The following list was assembled by checking manufacturer device files for explicit `PAL16L8` / `PAL20L10` entries.

**Confirmed capable** (bipolar `PAL16L8` *and* `PAL20L10` both in the verified device list):

| Programmer                                                                                  | Notes                                                                                                                                       |
|---------------------------------------------------------------------------------------------|---------------------------------------------------------------------------------------------------------------------------------------------|
| Elnec **BeeProg2** (non-C), **BeeProg+**, original **BeeProg**, **LabProg+**, **B&K 864/866** | Same Elnec lineage. The **Dataman 48Pro2** is the same hardware under a different badge and is also capable.                                |
| **Stag ZL30 / ZL30A / ZL30B**                                                               | RS-232 stand-alone units. Their device file lists `PAL16L8A-2` and `PAL20L10A` explicitly.                                                  |
| **Hi-Lo ALL-11**                                                                            | The 20L10 family appears in the official ALL-11 device list ([device.pdf, Jul 2000](https://elmicro.com/files/hilo/all11p3/device.pdf)).    |
| **Xeltek SuperPro** legacy / **6100** / **6100N**                                           | The newer SuperPro 7xxx / IS01 / S01 models have dropped bipolar PALs — older models only.                                                  |
| **BPM Microsystems**                                                                        | `PAL16L8` DIP-20 and `PAL20L10A` both appear in the BPM device database.                                                                    |
| **Advin PILOT-MVP**                                                                         | Period-correct universal programmer with bipolar PAL support.                                                                               |
| **Data I/O UniSite / 2900 / 3900 / 3980 / System 29A/29B**                                  | **Only** with the **LogicPak / PLD pin-driver module** installed. The base unit alone cannot read bipolar PALs.                             |

All of the above are professional-grade equipment, not hobbyist hardware. Realistic sourcing is second-hand from EPROM-programmer specialists or the chip-preservation community; working units typically run €300–€1500 used.

**Confirmed NOT capable** (CMOS PALCE / GAL / PEEL only — no bipolar PAL16L8 / PAL20L10 in the device file):

| Programmer                                          | Why it falls short                                                                                                       |
|-----------------------------------------------------|--------------------------------------------------------------------------------------------------------------------------|
| **XGecu TL866II+ / T48** (with `minipro`)           | Device library is CMOS PALCE / GAL only. This is the single most common cause of failed bipolar PAL dumps.               |
| **Retro Chip Tester Professional**                  | CMOS only, *and* limited to 8 outputs — cannot handle the 10-output PAL20L10 even electrically.                          |
| **Batronix BX48 Batego II**                         | CMOS PALCE / GAL only.                                                                                                   |
| **Conitec Galep-3 / Galep-4 / Galep-5 / Galep-5D**  | Device list covers only PALCE / GAL / PEEL CMOS parts — verified for Galep-5 directly.                                   |
| Elnec **BeeProg2C** and **BeeProg3**                | The newer Elnec flagships **dropped** bipolar PAL support from their device files — only the older models still cover it. |
| **Hi-Lo ALL-100**                                   | CMOS PALCE / PALLV only. (The older **ALL-11** *is* capable — see the table above.)                                       |
| **Wellon VP-598 / VP-998**                          | CMOS only.                                                                                                               |

Note that some of these (e.g. BeeProg2C, BeeProg3) cost significantly more than capable units like the older BeeProg2 or a second-hand ZL30 — newer and more expensive does not imply more device coverage in this corner of the market.

Steps once a compatible programmer is available:

1. Power down the machine and let the PSU discharge.
2. Remove the chip with hot-air or Chip-Quik. Install a 24-pin DIP socket in its place.
3. Read into a JEDEC fuse map using the programmer's `PAL20L10` device profile. Output is a `.jed` file.
4. Re-insert and inspect.

### Path B — security fuse blown (locked)  ✅ this is the route that worked

A locked bipolar PAL returns all-`F`s on a direct read. The fuse map cannot be recovered with any commercial programmer. The only path is to **reverse-engineer the truth table** by exercising every input combination, observing the outputs, and synthesising the table back into a `.jed`. That is what was done here.

Two practical approaches, in preferred order:

1. **[DuPAL](https://github.com/jhallen/dupal3) or [dupico](https://github.com/Murunius/dupico) (DuPAL V3, RP2040-based).** A brute-force test rig that walks every input combination, reads every output, and constructs the truth table. Cost: ~€30–80 to build. Output is a synthesised `.jed`. The dupico detects input / output / hi-Z per pin and is not limited to 8 outputs, which is what makes it tractable for the 10-output PAL20L10 (a fact that rules out, for example, the Retro Chip Tester Professional even as a fuse-state-independent reader).

   *PAL20L10 is a good DuPAL candidate from the chip side*: it has 12 dedicated inputs (pins 1–11, 13), 2 dedicated outputs (pins 14, 23) and 8 I/O pins (pins 15–22). Resolving each I/O pin's direction is the first step and it is not a formality — on IC7 two of them, pins 15 and 16, turn out to be permanently high-Z and therefore inputs, so the device presents **14 inputs and 8 outputs** and dupico walks all 2¹⁴ = 16 384 combinations rather than 2¹². Establish direction one pin at a time *before* trusting `--check_hiz`: that option pulls all data pins high in one pass and low in the other, so an input still classed as data changes the array's own logic between passes and driven outputs come back misreported as floating.

   **On-board feedback does not stop DuPAL from recovering the fuse map.** The IO Moon 16-bit board routes a loop through IC7's inputs — `/WR` is OR'd with `/PCS0` in IC47A (74LS32) to clock the IC40 latch (74LS273), whose outputs `EEE1`/`EEE2` return to IC7 pins 9/10 (see *Verified device structure* above). This is **external** feedback, and it is broken the moment the chip is on the bench: dupico drives `EEE1`, `EEE2`, `/WR` and every other pin independently, so the loop has zero effect on the extracted truth table. The only consequences are (a) the bench exercises input combinations that never occur in-circuit — harmless, in fact extra coverage — and (b) the board's *dynamic* behaviour cannot be reconstructed from the chip dump alone, which is not needed to re-create the PAL or to document the decode map. What *would* defeat a combinational extraction is a **registered output** (the 20L10 has none — no clock pin) or **internal asynchronous feedback** forming a latch (a fuse-map property, which dupico detects and handles by reading each I/O pin as input and output). Neither is present — measured, not assumed — so dupico recovers IC7's truth table cleanly, and it did: the synthesised JEDEC reproduces the chip on all 16384 entries.

2. **Logic-analyser capture during live operation.** If DuPAL is not applicable — either because of on-board feedback as above, or because the chip turns out to be partially registered after all — clip a multi-channel logic analyser onto every pin of the chip, run the machine through every state of normal operation, and reconstruct the truth table from the captured traces. Requires a 16-or-more-channel analyser (Saleae Pro 16, Kingst LA5016, Logic Pro 16 — €200–€500). Coverage of every input combination is not guaranteed and may require many hours of careful state-exercising.

---

## IC8 — PAL 16L8A-2CN  (Z80 board, 011-030A)  ⚠ DUMPED, CONFLICT OPEN

The chip is locked, so Path B below is the route that produced the dump: the same dupico (DuPAL V3) rig that recovered IC7, sweeping all 2048 combinations of eleven inputs and reading six outputs. The JEDEC reproduces the measurement on every one of them, the whole pipeline has been run twice independently to byte-identical artefacts, and pin direction is established in four configurations. But the recovered logic contains **no memory chip select**, and the board cannot work without one — so the open question is which device was read, not whether it was read correctly. Dump, what checks out, what does not, and the physical checks that would settle it: [`../roms/PAL16L8/`](../roms/PAL16L8/).

- **Datasheet**: [`../datasheets/pal20l10_pal16l8_mmi_pal_handbook_1983.pdf`](../datasheets/pal20l10_pal16l8_mmi_pal_handbook_1983.pdf) (MMI PAL Handbook — PAL16L8 device structure / fuse map).
- **Role**: combinational chip-select / bus glue on the Z80 main bus.

  The Z80 has no on-chip chip-select unit — every memory and I/O peripheral select has to be generated by external logic from the address bus and the `MREQ` / `IORQ` / `RD` / `WR` strobes. On the IO Moon Z80 board that decode is done by IC8 in tandem with the two 74LS138 3-to-8 decoders at IC16 and IC17. The PAL16L8 has 10 dedicated inputs and 8 active-low outputs in 20 pins; it takes the high address bits plus the cycle-type strobes and feeds the 74LS138s with the enables that subdivide the Z80 address space.

  Sheets `011-030-01` and `-02` show where each of its eight outputs goes:

  - **`/ROM1`** (pin 12) is the `/CE` of the program EPROM at IC5, and **`/ROM2`** (pin 13) the `/CE` of the second EPROM position at IC6, which IO Moon does not populate.
  - **`/RAM`** (pin 16) is gated with the supervisor's `WATCH` line by IC14C/D to become `/CRAM`, the `/CE` of the 2 KB work RAM at IC7.
  - **`/RD`** (pin 19) and **`/WR`** (pin 18) are the gated peripheral strobes: `/RD` drives `/OE` on IC5, IC6 and IC7 and enables the IC4 74LS245, `/WR` drives IC7's `/WE`. They are distinct nets from the raw Z80 `/PRD` and `/PWR` that come *in* on pins 5 and 4.
  - **`/CEI`** (pin 15) enables IC16, the 74LS138 that decodes the **five input ports** `0x00`–`0x04`, and **`/CEO`** (pin 17) enables IC17, the one that decodes the **eight output ports** `0x80`–`0x87`. In both cases `A7` is the other enable, so it alone separates the IN side from the OUT side. Neither decoder has a spare output.
  - **`/RI`** (pin 14) is the reset of the interrupt latch at IC14A/B, which IC12 and IC13 set once every 4096 `ZCLK` cycles. It does not go near the watchdog; IC15's `WDI` takes the separate `WATCH` net.

- **Mounting**: soldered.

- **What the dump settles**: the port decode is complete. IC16 wires five outputs and IC17 wires eight, so the Z80 has exactly the ports the firmware uses — `0x00`–`0x04` in, `0x80`–`0x87` out — and no peripheral hides at an address the firmware never touches. The bench read supplies the two enables that gate those decoders, and the interrupt-acknowledge decode on the `/RI` path.

- **What the dump leaves open**: no memory chip select appears in the recovered logic — pin 12 never drives and pin 16 reduces to `/M1` — and a Z80 board whose IC8 behaved that way could not fetch an instruction or reach its RAM. Two of the outputs also land on each other's pins relative to the symbol. The measurement is exhaustive, reproduces byte for byte on an independent run of the pipeline, and has pin direction established in four configurations, so the disagreement is between the device that was read and the device the sheet describes, and the rig cannot discriminate further. [`../roms/PAL16L8/README.md`](../roms/PAL16L8/README.md) carries the evidence and the three hardware checks: continuity from pin 12 to IC5's `/CE`, a scope on pin 16 against `/M1`, and the provenance of the part.

### Verified pinout and feedback path (schematic-confirmed, sheet 011-030-01)

Pin assignments read directly from the IC8 symbol. The bench read agrees with the input side and is at odds with part of the output side — see [`../roms/PAL16L8/README.md`](../roms/PAL16L8/README.md):

- **10 dedicated inputs** (pins 1–9, 11): `/M1`, `/MREQ`, `/IOREQ`, `/PWR`, `/PRD`, `A15`, `A14`, `A13`, `A12`, `A7`.
- **8 outputs** (pins 12–19): `/ROM1` (12), `/ROM2` (13), `/RI` (14), `/CEI` (15), `/RAM` (16), `/CEO` (17), `/WR` (18), `/RD` (19). Pins 12 and 19 are the dedicated outputs; pins 13–18 are I/O pins, all wired as outputs here.
- The 16L8 is purely combinational: no clock pin, no registered outputs.
- Note the input strobes `/PWR`/`/PRD` (the raw Z80 write/read) are **distinct nets** from the outputs `/WR`/`/RD` (gated peripheral strobes IC8 generates) — despite the similar names there is no same-net output→input wire.

The Doña Elvira 2 service manual carries an independent copy of sheet `011-030-01` (REV 3, 10 August 1995) at [`../manuals/SLEIC_1996_Dona_Elvira_2_Spanish_Service_Manual_with_schematics.pdf`](../manuals/SLEIC_1996_Dona_Elvira_2_Spanish_Service_Manual_with_schematics.pdf) — that machine's CPU board is clave `011-030`, the same drawing family. Its IC8 symbol carries the identical pin assignment, all ten inputs and all eight outputs, so the list above is confirmed by two separate manuals. The surrounding devices agree too: IC1 Z80A, IC5 27C256 on `/ROM1`, IC7 a 6116 on `/CRAM`, address buffers at IC2/IC3 and a 74LS245 at IC4.

**The one non-chip-select output is `/RI` (pin 14).** It drives a logic gate that produces `/INT`, and `/INT` goes to the Z80's interrupt input — it does **not** return to any IC8 pin. This is the loop the hardware analysis flagged for IC8, and the read is correct: it is a **system-level** loop that closes only through Z80 execution (interrupt → ISR → different bus cycles → different IC8 inputs), not an electrical feedback into the PAL. Its consequences for dumping are discussed under Path B.

### Important — bipolar PAL with bidirectional I/O pins

Same bipolar-vs-CMOS caveat as IC7: the budget CMOS-only programmers (TL866II+ / T48, Batronix BX48, Wellon VP-598/998, Conitec Galep-3/4/5/5D, Elnec BeeProg2C/3, Hi-Lo ALL-100, etc.) cannot read this part. A vintage or professional programmer from the IC7 *confirmed capable* list is required.

Like the PAL20L10 at IC7 (which has 8 I/O pins of its own, two of them programmed as inputs), the **PAL16L8 has 6 bidirectional I/O pins** (pins 13–18). Each I/O pin can be configured as an input or an output, and the state of each I/O pin can feed back into the AND array internally. The schematic shows all 6 wired as outputs on the IO Moon Z80 board (see *Verified pinout* above) — but IC7 is the caution against taking that as settled: its symbol reads the same way, and the dump found two of its I/O pins permanently high-Z. Direction is a fuse-map property and only a bench read establishes it. This affects both paths:

- Internal feedback (an I/O pin's output term routed back into the AND array) is part of what the truth table must capture, and dupico captures it by monitoring every I/O pin as both an input *and* an output. If that internal feedback ever formed an asynchronous latch the part would no longer be purely combinational — but a chip-select decoder is not expected to do that.
- On-board (external) feedback — an output looped back to an input through other chips — does **not** block a DuPAL read, because the chip is read in isolation. See the IC7 Path B section, where exactly this kind of loop (`/WR` → IC47A → IC40 → IC7's `EEE1`/`EEE2` inputs) is shown to be harmless for fuse-map recovery. IC8's `/RI` → `/INT` path is even more removed: it never returns to an IC8 pin at all.

### Path A — security fuse intact (unlocked)

IC8's fuse is blown, so this path does not apply to it either; it is kept for any other board where the fuse is intact. Same family of confirmed-capable programmers as for IC7 (see the IC7 Path A *Confirmed capable* table). Read into JEDEC using the programmer's `PAL16L8` device profile.

1. Power down, desolder, install a 20-pin DIP socket.
2. Read with the `PAL16L8` profile.
3. Re-insert and inspect.

### Path B — security fuse blown (locked)

- **DuPAL / dupico** recovers IC8's truth table, and did. The `/RI` → `/INT` path the analysis flagged is a system-level loop through the Z80 (it does not return to any IC8 pin — see *Verified pinout* above), so it has no effect on a bench read, and neither of the things that defeat a combinational extraction is present: the 16L8 has no registered output, and the part measures stateless. **Resolving each I/O pin's direction is the step that needs care.** `--check_hiz` drives every data pin high in one pass and low in the other, and six of the eight outputs feed back into the array, so a driven output can be reported as floating — on this part it reports pins 17 and 19 floating in 128 of 1024 states while a clean sweep has both driving in all 2048. The signature is *partial* false Hi-Z, so resolve direction one pin at a time and prefer a pin with no feedback path; the [dump's README](../roms/PAL16L8/README.md) works it through.
- **Logic-analyser capture** if the design uses on-board I/O-pin feedback that DuPAL cannot reproduce. Same caveats as IC7 Path B option 2.

---

## Equipment summary

| Item | What it can read here | Cost (rough) |
|------|-----------------------|--------------|
| TL866II+ / T48 + `minipro` | **PIC 16C57 only** if unlocked. Also useful for re-dumping the EPROMs / EEPROM if needed. **Cannot read the bipolar PALs at IC7 / IC8** — its device library is CMOS PALCE / GAL only. | ~$50 USD |
| Confirmed-capable bipolar PAL programmer (BeeProg2 non-C / BeeProg+ / BeeProg / LabProg+ / B&K 864 / 866 / Dataman 48Pro2, Stag ZL30 series, Hi-Lo ALL-11, Xeltek SuperPro legacy / 6100 / 6100N, BPM Microsystems, Advin PILOT-MVP, or Data I/O 2900 / 3900 / 3980 / 29A / 29B / UniSite **with** LogicPak / PLD module) | PAL20L10 + PAL16L8 if either is unlocked. | €300–€1500 used, €1500+ new |
| DuPAL / dupico (RP2040 DuPAL V3) | Truth-table reconstruction for **locked combinational PALs**. Works regardless of fuse state, and regardless of any on-board feedback (the chip is read in isolation). Not limited to 8 outputs, so handles the 10-output PAL20L10. | ~€30–80 to build |
| 16+-channel logic analyser (Saleae Pro 16, Kingst LA5016, Logic Pro 16) | Truth-table capture from a live board when DuPAL is not applicable. | €200–€500 |
| Specialised chip-recovery lab | Decap / electrical-glitch readout of a locked PIC 16C57. | $200–$2000+ per chip |
| 28-pin, 24-pin and 20-pin DIP sockets | Install on the boards so future dumps are non-destructive. | <€1 each |
| Hot-air rework station or Chip-Quik | Desoldering the chips for the first read. Chip-Quik is cheaper and lower-thermal-shock; hot-air is faster. | €15–100 |
| IC extractor, magnification, ESD strap | Standard rework hygiene. | — |

**Programmers that will *not* help on the bipolar PALs** (sometimes marketed in ways that suggest otherwise): XGecu TL866II+ / T48, Retro Chip Tester Professional, Batronix BX48 Batego II, Conitec Galep-3 / Galep-4 / Galep-5 / Galep-5D, Elnec BeeProg2C, Elnec BeeProg3, Hi-Lo ALL-100, Wellon VP-598 / VP-998. All of these are CMOS PALCE / GAL only in their current device files.

The bipolar PALs are the awkward case: there is no cheap modern programmer that reads them, and there is no software workaround once the security fuse is blown. On IC7 the cheap route is the one that worked — a ~€30–80 dupico rig recovered a locked part that no programmer on the confirmed-capable list could have read, and the same rig is what IC8 needs.

---

## What each dump is worth

- **IC23** ✅ **(dumped)** — the DMD raster path. Its listing establishes the two-plane scan order, the 200:30 per-plane row-hold ratio that makes plane 0 the MSB of the 4-level grey scale, and — as a negative result that matters just as much — that the coprocessor has no command interface, so the 80188 neither receives frame markers from it nor sends it a per-frame strobe.
- **IC7** ✅ **(dumped)** — the 80188-side decode map: the dual-window program-ROM select, the `A15` split of the MCS0 RAM block (and the second, unpopulated 32 KB half), the two-bit NVRAM interlock that confirms F10 from the silicon side, the DMD staging-buffer write strobe and the OKI latch clock. As a negative result: it carries neither the graphics-page address lines nor the OKI data bus, so neither bit-order question (F2's page selector, F9's OKI latch) is answerable from this part.
- **IC8** ⚠ **(dumped, conflict open)** — the two port-decoder enables and the interrupt-acknowledge decode, which together confirm that the Z80's five input ports and eight output ports are the whole of its I/O. The memory chip selects are missing from the read and the reason is not yet established.
