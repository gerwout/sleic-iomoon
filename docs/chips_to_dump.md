# Chips worth dumping

[← Back to main README](../README.md)

Three programmable chips across the two CPU boards contain undumped firmware. All three are required for a complete emulation.

| Rank | Ref  | Part                       | Package        | Board             |
|------|------|----------------------------|----------------|-------------------|
| 1    | IC23 | Microchip PIC 16C57-HS/P   | PDIP-28 (OTP)  | 011-029A (16-bit) |
| 2    | IC7  | AMD/MMI PAL20L10ACNS       | PDIP-24        | 011-029A (16-bit) |
| 3    | IC8  | AMD PAL16L8A-2CN           | PDIP-20        | 011-030A (Z80)    |

Everything else on the IO Moon boards is either already archived (the 27C040 program / display / sound EPROMs and the 27C256 Z80 ROM) or runtime-mutable (the 28C64A NVRAM at IC14 on the 16-bit board). For the full board IC lists and the function of every other chip, see [`board_011-029A_ics.md`](board_011-029A_ics.md) and [`board_011-030A_ics.md`](board_011-030A_ics.md).

## How to read this document

Every one of the three chips can be in one of two states, and the recovery path depends on which:

- **Unlocked** — the security / code-protect fuse has never been blown. A direct read returns the real contents.
- **Locked** — the security / code-protect fuse is blown. A direct read returns garbage (`0xFFF` for the PIC, all-`F`s for a PAL). Recovery requires substantially more work, equipment, or money.

You only discover which state a chip is in by attempting a read. Each chip section below lists both paths. The locked path is always harder and more expensive than the unlocked one.

A common misconception is that a TL866II+ / T48 universal programmer can read every chip on this list. That is **not true** for the two PALs — see the bipolar-PAL note below.

---

## IC23 — PIC 16C57-HS/P  (16-bit board, 011-029A)

- **Role**: DMD raster coprocessor and (almost certainly) the YM3812 sound driver. The only microcontroller on the board apart from the 80188; the 80188 pushes 80+ commands into a shared-RAM queue at offset `4000:1158+` that nothing else has the bus access to consume.
- **Memory**: 2048 × 12-bit OTP program memory, 72 bytes RAM, 20 I/O pins.
- **Mounting**: soldered.

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

## IC7 — PAL 20L10ACNS  (16-bit board, 011-029A)

- **Role**: combinational chip-select / bus glue on the 80188 main bus.

  The 80188's internal chip-select unit (UMCS / LMCS / MMCS / PACS, programmed at boot via RELREG = `C03C`) covers the obvious large blocks — the program EPROMs at IC10 / IC11, the 32 K × 8 main work RAM at IC12, and a 64-byte peripheral block. The rest of the 80188 address space has to be decoded externally, which is what IC7 does. With 12 dedicated inputs, 10 active-low outputs, and a position on the address bus immediately next to the 80188, it is the only part on the board with the I/O budget to do the per-peripheral decode.

  The 80188 touches several memory-mapped peripherals that fall outside the internal CSU:

  - The **DMD controller hardware registers at segment `A000h`**, where the 80188 hands frames to the PIC at IC23.
  - The **shared-RAM mailbox window at segment `4000h`**, where the 80188 and the Z80 swap commands under HOLD / HLDA bus arbitration.
  - The **scratchpad SRAM at IC33** (2 K × 8) and the **28C64A NVRAM at IC14**.
  - The output latches **IC40 / IC50** that buffer command and data writes on their way to the YM3812 and the DMD bus.

  IC7 generates the per-peripheral chip-selects for each of those, plus very likely the write-enable gating that protects the NVRAM from spurious writes during power transitions (in tandem with the MAX699 supervisor at IC6).

- **Mounting**: soldered.

- **Why dumping it matters**: with the fuse map archived, the full 80188-side memory map is documented and PinMAME can be made to honour real chip-select boundaries rather than the permissive `MRA_RAM` / `MWA_RAM` placeholders the current driver uses.

### Verified device structure and feedback path (schematic-confirmed, sheets 011-029-01 / -05)

Pin assignments read directly from the IC7 symbol on sheet 1 and the latch logic on sheet 5:

- **12 dedicated inputs** (pins 1–11, 13): `/LCS`, `/UCS`, `/MCS0`, `/MCS1`, `/PCS4`, `/PCS6`, `DECH`, `DECL`, `EEE1` (pin 9), `EEE2` (pin 10), `A15`, `/MCS3` (pin 13).
- **2 dedicated outputs** (pins 14, 23): `/WRVRAM` (14), `/PRCS` (23).
- **8 I/O pins** (pins 15–22): `EEEREADY` (15), `/WR` (16), `/TEST` (17), `/EECE` (18), `/OOE` (19), `/OKCS` (20), `/RAM2` (21), `/RAM1` (22). On this board **all 8 I/O pins are wired as outputs**, so IC7 presents 12 inputs and 10 outputs in-circuit — but it is *not* a no-I/O-pin device.
- The 20L10 is purely combinational: no clock pin, no registered outputs.

**The board does contain an output→input feedback loop, and it is external to the die.** IC7's `/WR` (pin 16) is OR'd with `/PCS0` in IC47A (74LS32); that gate output clocks IC40 (74LS273), which latches data-bus bits `D0–D7` onto its outputs, two of which are `EEE1` (Q4) and `EEE2` (Q5). `EEE1`/`EEE2` then return to IC7 pins 9/10. So the 80188 writes a control byte to that port, the write is qualified by IC7's own `/WR`, and two of the latched bits feed back into IC7 as inputs. This is the loop the hardware analysis flagged for IC7, and the read is correct. Its consequences for dumping are discussed under Path B.

### Important — this is a bipolar PAL, not a CMOS PALCE

The `PAL20L10ACNS` is a **bipolar fuse-link PAL** from the original AMD/MMI process, not one of the CMOS-EEPROM PALCE / PALC / ATF / GAL successors. This matters because the modern budget programmers do not cover the original bipolar PAL family at all — their device libraries jump straight to the CMOS variants. Reading a bipolar PAL requires a programmer that can drive the higher fuse-verify voltages and time the read sequence the way the bipolar process expects. This rules out almost every piece of cheap-and-easy tooling that handles the PIC and the EPROMs.

### Path A — security fuse intact (unlocked)

A vintage or professional programmer with native bipolar PAL support is required. The following list was assembled by checking manufacturer device files for explicit `PAL16L8` / `PAL20L10` entries.

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

### Path B — security fuse blown (locked)

A locked bipolar PAL returns all-`F`s on a direct read. The fuse map cannot be recovered with any commercial programmer. The only path is to **reverse-engineer the truth table** by exercising every input combination, observing the outputs, and synthesising the table back into a `.jed`.

Two practical approaches, in preferred order:

1. **[DuPAL](https://github.com/jhallen/dupal3) or [dupico](https://github.com/Murunius/dupico) (DuPAL V3, RP2040-based).** A brute-force test rig that walks every input combination, reads every output, and constructs the truth table. Cost: ~€30–80 to build. Output is a synthesised `.jed`. The dupico detects input / output / hi-Z per pin and is not limited to 8 outputs, which is what makes it tractable for the 10-output PAL20L10 (a fact that rules out, for example, the Retro Chip Tester Professional even as a fuse-state-independent reader).

   *PAL20L10 is a good DuPAL candidate from the chip side*: it has 12 dedicated inputs (pins 1–11, 13), 2 dedicated outputs (pins 14, 23) and 8 I/O pins (pins 15–22). On the IO Moon board all 8 I/O pins are wired as outputs, so the device presents 12 inputs and 10 outputs — dupico walks all 2¹² = 4 096 input combinations and reads all 10 outputs. As with the 16L8, dupico must first resolve the direction of each I/O pin (here they all resolve to *output*); this is **not** the dedicated-pin-only "trivial" case it was previously described as, but it is fully tractable.

   **On-board feedback does not stop DuPAL from recovering the fuse map.** The IO Moon 16-bit board *does* route one of IC7's outputs back to its own inputs — `/WR` (pin 16) is OR'd with `/PCS0` in IC47A (74LS32) to clock the IC40 latch (74LS273), whose outputs `EEE1`/`EEE2` return to IC7 pins 9/10 (see *Verified device structure* above). This is **external** feedback, and it is broken the moment the chip is on the bench: dupico drives `EEE1`, `EEE2`, `/WR` and every other pin independently, so the loop has zero effect on the extracted truth table. The only consequences are (a) the bench exercises input combinations that never occur in-circuit — harmless, in fact extra coverage — and (b) the board's *dynamic* behaviour cannot be reconstructed from the chip dump alone, which is not needed to re-create the PAL or to document the decode map. What *would* defeat a combinational extraction is a **registered output** (the 20L10 has none — no clock pin) or **internal asynchronous feedback** forming a latch (a fuse-map property, which dupico detects and handles by reading each I/O pin as input and output). Neither is present, so DuPAL/dupico recovers IC7's truth table cleanly.

2. **Logic-analyser capture during live operation.** If DuPAL is not applicable — either because of on-board feedback as above, or because the chip turns out to be partially registered after all — clip a multi-channel logic analyser onto every pin of the chip, run the machine through every state of normal operation, and reconstruct the truth table from the captured traces. Requires a 16-or-more-channel analyser (Saleae Pro 16, Kingst LA5016, Logic Pro 16 — €200–€500). Coverage of every input combination is not guaranteed and may require many hours of careful state-exercising.

---

## IC8 — PAL 16L8A-2CN  (Z80 board, 011-030A)

- **Role**: combinational chip-select / bus glue on the Z80 main bus.

  The Z80 has no on-chip chip-select unit — every memory and I/O peripheral select has to be generated by external logic from the address bus and the `MREQ` / `IORQ` / `RD` / `WR` strobes. On the IO Moon Z80 board that decode is done by IC8 in tandem with the two 74LS138 3-to-8 decoders at IC16 and IC17. The PAL16L8 has 10 dedicated inputs and 8 active-low outputs in 20 pins; it takes the high address bits plus the cycle-type strobes and feeds the 74LS138s with the enables that subdivide the Z80 address space.

  Outputs the PAL almost certainly generates:

  - The Z80 **memory chip-selects** for the program ROM at IC5 (`0x0000`–`0x7FFF`) and the work RAM at IC7 (`0xC000`–`0xC7FF`).
  - The **I/O port decode enables** for the OUT-strobes that drive the lamp / solenoid / matrix-scan latches (ports `0x80`–`0x87`) and the IN-strobes that gate the switch / DIP-switch / status buffers.
  - The **shared-RAM mailbox window** gating on the Z80 side of the J3 inter-board ribbon, including the HOLD / HLDA response back to the 80188.
  - The **watchdog reset** path from the IC12 / IC13 counter chain into the IC15 ADM699 supervisor.

- **Mounting**: soldered.

- **Why dumping it matters**: with the fuse map archived, the Z80-side I/O and memory decode is documented exactly rather than inferred from firmware traces. The current PinMAME `z80_read_port` / `z80_write_port` handlers cover ports `0x80`–`0x87` based on disassembly evidence; an IC8 dump would either confirm that decode is complete or surface peripherals at addresses the firmware does not exercise in the trace window.

### Verified pinout and feedback path (schematic-confirmed, sheet 011-030-01)

Pin assignments read directly from the IC8 symbol:

- **10 dedicated inputs** (pins 1–9, 11): `/M1`, `/MREQ`, `/IOREQ`, `/PWR`, `/PRD`, `A15`, `A14`, `A13`, `A12`, `A7`.
- **8 outputs** (pins 12–19): `/ROM1` (12), `/ROM2` (13), `/RI` (14), `/CEI` (15), `/RAM` (16), `/CEO` (17), `/WR` (18), `/RD` (19). Pins 12 and 19 are the dedicated outputs; pins 13–18 are I/O pins, all wired as outputs here.
- The 16L8 is purely combinational: no clock pin, no registered outputs.
- Note the input strobes `/PWR`/`/PRD` (the raw Z80 write/read) are **distinct nets** from the outputs `/WR`/`/RD` (gated peripheral strobes IC8 generates) — despite the similar names there is no same-net output→input wire.

**The one non-chip-select output is `/RI` (pin 14).** It drives a logic gate that produces `/INT`, and `/INT` goes to the Z80's interrupt input — it does **not** return to any IC8 pin. This is the loop the hardware analysis flagged for IC8, and the read is correct: it is a **system-level** loop that closes only through Z80 execution (interrupt → ISR → different bus cycles → different IC8 inputs), not an electrical feedback into the PAL. Its consequences for dumping are discussed under Path B.

### Important — bipolar PAL with bidirectional I/O pins

Same bipolar-vs-CMOS caveat as IC7: the budget CMOS-only programmers (TL866II+ / T48, Batronix BX48, Wellon VP-598/998, Conitec Galep-3/4/5/5D, Elnec BeeProg2C/3, Hi-Lo ALL-100, etc.) cannot read this part. A vintage or professional programmer from the IC7 *confirmed capable* list is required.

Like the PAL20L10 at IC7 (which has 8 I/O pins of its own), the **PAL16L8 has 6 bidirectional I/O pins** (pins 13–18). Each I/O pin can be configured as an input or an output, and the state of each I/O pin can feed back into the AND array internally. On the IO Moon Z80 board all 6 are wired as outputs (see *Verified pinout* above). This affects both paths:

- Internal feedback (an I/O pin's output term routed back into the AND array) is part of what the truth table must capture, and dupico captures it by monitoring every I/O pin as both an input *and* an output. If that internal feedback ever formed an asynchronous latch the part would no longer be purely combinational — but a chip-select decoder is not expected to do that.
- On-board (external) feedback — an output looped back to an input through other chips — does **not** block a DuPAL read, because the chip is read in isolation. See the IC7 Path B section, where exactly this kind of loop (IC7 `/WR` → IC40 → `EEE1`/`EEE2`) is shown to be harmless for fuse-map recovery. IC8's `/RI` → `/INT` path is even more removed: it never returns to an IC8 pin at all.

### Path A — security fuse intact (unlocked)

Same family of confirmed-capable programmers as for IC7 (see the IC7 Path A *Confirmed capable* table). Read into JEDEC using the programmer's `PAL16L8` device profile.

1. Power down, desolder, install a 20-pin DIP socket.
2. Read with the `PAL16L8` profile.
3. Re-insert and inspect.

### Path B — security fuse blown (locked)

- **DuPAL / dupico** recovers IC8's truth table. The `/RI` → `/INT` path the analysis flagged is a system-level loop through the Z80 (it does not return to any IC8 pin — see *Verified pinout* above), so it has no effect on a bench read. dupico discovers each I/O pin's direction in turn (here all six resolve to *output*), detects input / output / hi-Z per pin, is not limited to 8 outputs, and handles both the 8-output PAL16L8 and the 10-output PAL20L10. As with IC7, the only things that would defeat a combinational extraction are a registered output (the 16L8 has none) or internal asynchronous latch feedback (a fuse-map property dupico detects) — neither of which a chip-select decoder is expected to use.
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

The two PALs are the awkward case: there is no cheap modern programmer that reads them, and there is no software workaround if the security fuse is blown. The realistic preservation strategy is to attempt Path A first with a borrowed or second-hand confirmed-capable programmer (or a willing party in the chip-preservation community), and only fall back to DuPAL / logic-analyser reconstruction if that fails.

---

## What this dump set unlocks

- **IC23** — emulation of the DMD raster path and (almost certainly) the YM3812 sound path. The single largest open question in the current PinMAME work.
- **IC7** — the 80188-side chip-select decode map.
- **IC8** — the Z80-side memory and I/O decode map.
