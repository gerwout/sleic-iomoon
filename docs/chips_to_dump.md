# Chips worth dumping

[← Back to main README](../README.md)

Two programmable chips on the IO Moon `011-029` (16-bit) board contain undumped firmware. Both are required for a complete emulation.

| Rank | Ref  | Part                       | Package        |
|------|------|----------------------------|----------------|
| 1    | IC23 | Microchip PIC 16C57-HS/P   | PDIP-28 (OTP)  |
| 2    | IC7  | AMD/MMI PAL20L10ACNS       | PDIP-24        |

Everything else on the IO Moon boards is either already archived (the 27C040 program / display / sound EPROMs and the Z80 ROM) or runtime-mutable (the 28C64A NVRAM at IC14). For the full board IC list and the function of every other chip, see [`board_011-029_ics.md`](board_011-029_ics.md).

---

## IC23 — PIC 16C57-HS/P

- **Role**: DMD raster coprocessor and (almost certainly) the YM3812 sound driver. The only microcontroller on the board apart from the 80188; the 80188 pushes 80+ commands into a shared-RAM queue at offset `4000:1158+` that nothing else has the bus access to consume.
- **Memory**: 2048 × 12-bit OTP program memory, 72 bytes RAM, 20 I/O pins.
- **Mounting**: soldered.
- **Code-protect fuse (CP)**: state unknown until first read. If set, the program-memory dump comes back as `0xFFF`. The 16C5x family has no software unprotect — a protected chip is recoverable only via destructive decap.

### Procedure

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

---

## IC7 — PAL 20L10ACNS

- **Role**: combinational chip-select / bus glue on the 80188 main bus.

  The 80188's internal chip-select unit (UMCS / LMCS / MMCS / PACS, programmed at boot via RELREG = `C03C`) covers the obvious large blocks — the program EPROMs at IC10 / IC11, the 32 K × 8 main work RAM at IC12, and a 64-byte peripheral block. The rest of the 80188 address space has to be decoded externally, which is what IC7 does. With 14 inputs, 10 active-low outputs, and a position on the address bus immediately next to the 80188, it is the only part on the board with the I/O budget to do the per-peripheral decode.

  The 80188 touches several memory-mapped peripherals that fall outside the internal CSU:

  - The **DMD controller hardware registers at segment `A000h`**, where the 80188 hands frames to the PIC at IC23.
  - The **shared-RAM mailbox window at segment `4000h`**, where the 80188 and the Z80 swap commands under HOLD / HLDA bus arbitration.
  - The **scratchpad SRAM at IC33** (2 K × 8) and the **28C64A NVRAM at IC14**.
  - The output latches **IC40 / IC50** that buffer command and data writes on their way to the YM3812 and the DMD bus.

  IC7 generates the per-peripheral chip-selects for each of those, plus very likely the write-enable gating that protects the NVRAM from spurious writes during power transitions (in tandem with the MAX699 supervisor at IC6).

- **Mounting**: soldered.

- **Security fuse**: standard PAL behaviour — if blown, the JEDEC read returns all-`F`s. A protected PAL can only be recovered by exercising every input combination in a test fixture and reconstructing the truth table by hand.

- **Why dumping it matters**: with the fuse map archived, the full 80188-side memory map is documented and PinMAME can be made to honour real chip-select boundaries rather than the permissive `MRA_RAM` / `MWA_RAM` placeholders the current driver uses.

### Procedure

1. Power down the machine and let the PSU discharge.
2. Remove the chip with hot-air or Chip-Quik. Install a 24-pin DIP socket in its place.
3. Read into a JEDEC fuse map:
   ```
   minipro -p PAL20L10 -r ic7.jed
   ```
4. Re-insert and inspect.

---

## Equipment

| Item                                  | Use                                                       |
|---------------------------------------|-----------------------------------------------------------|
| TL866II+ / T48 universal programmer   | Reads both parts in one tool (~$50 USD).                  |
| Linux `minipro` CLI                   | Open-source driver for the TL866II+.                      |
| 28-pin and 24-pin DIP sockets         | Install on the board so future dumps are non-destructive. |
| Hot-air rework station or Chip-Quik   | Either works for desoldering. Chip-Quik is cheaper and lower-thermal-shock. |
| IC extractor, magnification, ESD strap | Standard rework hygiene.                                  |

---

## What this dump set unlocks

- **IC23** — emulation of the DMD raster path and (almost certainly) the YM3812 sound path. The single largest open question in the current PinMAME work.
- **IC7** — the 80188 chip-select decode map.
