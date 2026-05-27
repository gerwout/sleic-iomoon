# Z80 I/O Port Map

[← Back to main README](../README.md)

## Port Assignments

Authoritative source: the annotated Z80 disassembly header at `asm/z80_annotated.asm:64–82`. Cross-checked against the actual `IN`/`OUT` instructions in the disassembly.

| Port | Direction | Function |
|------|-----------|----------|
| `0x00` | IN | Direct switches input 0 (flipper buttons, misc) |
| `0x01` | IN | Status register — bit 1 = MSM6376 / 80188 handshake ready |
| `0x02` | IN | Switch matrix column data (8 bits, active-low; Z80 `CPL`s after reading) |
| `0x03` | IN | Direct switches input 1 — bit 3 = START, bit 2 = TEST/COIN |
| `0x04` | IN | Direct switches input 2 — bit 0 = TILT, special inputs |
| `0x80` | OUT | Sound data bus → OKI MSM6376 phrase select / 80188 mailbox data (dual-purpose) |
| `0x81` | OUT | Control register, bit-mapped: bit 0 = sound strobe, bit 4 = NMI ack, others below |
| `0x82` | OUT | **Lamp matrix column strobe** (bits 0–6 = columns A–G) |
| `0x83` | OUT | **Lamp matrix row data byte 1** (lower 8 lamps of the addressed column) |
| `0x84` | OUT | **Lamp matrix row data byte 2** (upper 8 lamps of the addressed column) |
| `0x85` | OUT | **Solenoid bank 1** — bit 0 = sol1, bit 2 = sol2, bit 4 = sol4, bit 5 = sol3 |
| `0x86` | OUT | **Solenoid bank 2** — kickers, diverters, ball lock, etc. |
| `0x87` | OUT | **Switch matrix row strobe** — one-hot value `0x01, 0x02, 0x04, 0x08, 0x10, 0x20` |

> ⚠️ **Corrections vs. earlier revisions of this document**: ports `0x82` through `0x87` were previously listed as "Switch Matrix Row Strobe / Solenoid Bank 1 / Solenoid Bank 2 / Sound Control 1 / Sound Control 2 / Lamp General Control" — that mapping was wrong on five of the six ports. The values above match the actual `OUT` instructions in the Z80 disassembly. Notable consequences:
>
> - **Lamp matrix is driven by ports `0x82` (column) + `0x83`/`0x84` (16 row bits per column)**, not by port `0x80` as the old "Lamp Matrix Row / Sound Data" label on `0x80` suggested.
> - **Switch matrix row strobe is on `0x87`**, not `0x82`. The strobe values cycle through `0x01–0x20` (6 rows), matching the switch matrix scan routine documented below.
> - **There is no dedicated YM3812 port on the Z80 side.** Ports labelled "Sound Control 1/2" in the previous doc are actually solenoid drivers. How the 80188 reaches the YM3812 at IC60 — which physically sits on the 80188 board (`011-029`) — is still an open question; the 80188 disassembly contains only two `OUT dx, ax` instructions (both during boot peripheral config), so the YM3812 must be memory-mapped. The exact address has not yet been identified in the reverse-engineering.

---

## Switch Matrix Scan Routine

The switch matrix scan routine resides at Z80 ROM addresses `0x2ED3`–`0x2FE6`.

### Row Strobe Sequence

The Z80 strobes one row at a time via port `0x82`, then reads the column state via port `0x02`:

| Strobe Value | Row | Switch Codes |
|-------------|-----|-------------|
| `0x01` | Row 0 | `0x0A`–`0x11` |
| `0x02` | Row 1 | `0x12`–`0x19` |
| `0x04` | Row 2 | `0x1A`–`0x21` |
| `0x08` | Row 3 | `0x22`–`0x29` |
| `0x10` | Row 4 | `0x2A`–`0x31` |
| `0x20` | Row 5 | `0x34`–`0x3B` |

### Direct Switch Codes

These are read from ports `0x03` and `0x04` without matrix scanning:

| Code | Switch |
|------|--------|
| `0x3E` | Left Flipper |
| `0x3F` | Right Flipper |
| `0x40` | Upper Flipper |
| `0x41` | START Button |
| `0x42` | Coin Input |

---

## Key Z80 RAM Addresses

| Address | Function |
|---------|----------|
| `0xC0DB`–`0xC0E0` | Matrix switch debounced states (6 rows) |
| `0xC0E3` | Direct switch state (Port `0x03` snapshot) |
| `0xC0E5`–`0xC0E6` | Scan routine state pointer |
| `0xC0E7`–`0xC0F2` | Raw matrix data (before debounce) |
| `0xC0FC` | Current switch code output (mailbox to 80188) |

The byte at `0xC0FC` is the primary communication channel from the Z80 to the 80188. When a switch is activated, the Z80 writes the corresponding switch code to this address, where the 80188 reads it during its main loop polling cycle.

---

## Switch Matrix Hardware

### Connector J2 (20-pin ribbon)

```
COL0–COL7 (C0–C7): Column strobe outputs (directly drive matrix columns)
ROW0–ROW7 (F0–F7): Row input returns (active-low, active when switch is closed)
```

### Connector J4 (20-pin ribbon)

```
FIF, FIM   — Left Flipper signals (fire, hold)
FDF, FDM   — Right Flipper signals (fire, hold)
FAM        — Right Middle Flipper signal
FBF, FBM   — Additional flipper signals
BC1–BC8    — Bumper contacts (active-low)
```

---

## Scan Timing

The Z80 runs at 8 MHz and performs a complete matrix scan cycle as part of its main processing loop. Each scan iteration:

1. Strobes one row via port `0x82`
2. Reads column state via port `0x02`
3. Compares with debounced state at `0xC0DB`+row
4. If a change is detected, updates the debounced state and writes the switch code to `0xC0FC`
5. Reads direct switches from ports `0x03` and `0x04`
6. Processes lamp matrix updates
7. Processes solenoid updates

The complete scan cycle handles all 6 matrix rows plus direct switches in a single pass.
