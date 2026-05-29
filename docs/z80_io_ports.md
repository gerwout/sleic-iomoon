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
| `0x81` | OUT | Control register, bit-mapped (see "Port 0x81 control bits" below) |
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

---

## Port 0x81 control bits

The Z80 keeps a shadow of port 0x81 in RAM at `0xC001` (`ram_port81_shadow`) and read-modify-writes it. Based on which bits are set/cleared in the actual code paths:

| Bit | Mask | Set by | Cleared by | Function |
|-----|------|--------|------------|----------|
| 0 | `0x01` | `or 003h` in `send_sound_cmd` (0x0144) | `and 0FEh` later in `send_sound_cmd` | **OKI sound strobe** — pulses high to latch sound command into the MSM6376 |
| 1 | `0x02` | `or 002h` / `or 003h` in `send_to_80188` (0x0116), `send_sound_cmd` | `and 0FDh` (5× across routines) | **80188 mailbox enable** — gates port 0x80 data onto the inter-board bus |
| 2 | `0x04` | `or 004h` in `send_to_80188` | (cleared as part of `and 0FBh and 0FDh` sequence) | **80188 mailbox strobe** — pulses the latch on the receiving side |
| 3 | `0x08` | **never set** (no `or 008h` before any `out (081h),a`) | — | unused on the Z80 side |
| 4 | `0x10` | `or 010h` in NMI/IRQ acknowledge | (implicit) | **NMI acknowledge** |
| 5 | `0x20` | `or 020h` in `send_sound_cmd` (2×) | `and 0DFh` (2×) | **OKI command latch** — extends the sound strobe / selects OKI command vs sample channel |
| 6 | `0x40` | `or 040h` in `switch_debounce` (0x01B6) | `and 0BFh` (3× in scan-loop tear-down) | **Direct-switch read enable** — must be set before reading port `0x00` |
| 7 | `0x80` | **never set** (no `or 080h` before any `out (081h),a`) | — | unused on the Z80 side |

Statistical evidence: I grep'd the entire Z80 ROM for the value loaded into A on the path to each of the ~36 `out (081h),a` instructions. The only `or` masks observed are `01h`, `02h`, `03h`, `04h`, `10h`, `20h`, `40h`. The only `and` masks observed are `BFh`, `DFh`, `FDh`, `FEh`. Bits 3 and 7 of port `0x81` are never manipulated.

---

## YM3812 routing — open question

The YM3812 FM synthesizer (IC60, on the 80188 board) is conspicuously absent from any code path we can find:

- **No Z80 access**: no port writes to anything beyond `0x80–0x87`; port `0x81` has no remaining unused bits that could select a YM3812 path; the apparent `out (027h),a`, `out (05Ah),a`, `in a,(05Eh)` instructions visible in the disassembly all sit inside data tables (envelope/wave-table-like byte patterns) and are not reachable as code.
- **No 80188 port access**: the entire 80188 ROM contains only **two** `out dx, ax` instructions (`0xFFF06` and `0xD001E`), both during boot peripheral configuration. The YM3812 is not driven by I/O ports.
- **No additional 80188 chip selects**: the boot I/O table at `cs:0041` (ROM offset `0xD0041`) writes **30 register pairs** to the 80188's Peripheral Control Block. Among them are the documented chip selects (`UMCS=0x3FFC`, `LMCS=0xA03C`, `PACS=0x41FC`, `MMCS=0xA0FC`) — but there is **no write to `0xFFAA` (MPCS)**, meaning the mid-range peripheral chip selects PCS0–PCS6 are left at their default (disabled). The 80188 therefore has exactly four chip-select windows, none of which are unaccounted for.
- **`sound_play_command` is a red herring**: the auto-generated function name suggests this is where YM3812 writes happen, but the function writes to `ES=5040h offset 02B9h` — physical address `0x506B9`, which is **outside any of the four chip-select windows** (LMCS covers up to `0x4FFFF`; nothing covers `0x50000–0x9FFFF`). It also calls `display_set_buffer_14refs` and `display_clear_area_24refs`, strongly suggesting it is actually display-related, not sound, and that the auto-name is wrong.

Two remaining possibilities:

1. **The YM3812 is memory-mapped inside the MMCS window (segment `A000h`)** at offsets the current reverse-engineering hasn't traced cleanly. The DMD registers live at offsets `0x0000`, `0x0080`, `0x0200`, `0x0300`; the YM3812's index/data register pair could be at e.g. `A000:0100`/`A000:0101` or similar. Confirming this requires tracing memory accesses while ES=A000h through a non-trivial portion of the 80188 game code (or running the ROM in a CPU simulator).
2. **The YM3812 is physically populated on the IO Moon board but never actually used by the IO Moon software** — its presence on the principal-components list of `011-029A` could be inherited from earlier SLEIC machines (Bike Race / Sleic Pin-Ball) that *do* use it. The OKI MSM6376 alone is responsible for both speech and music in IO Moon.

For PinMAME emulation purposes, the safe default is to *attach* a YM3812 to the IO Moon machine driver but not expect it to be driven; if (1) is true, the address eventually surfaces during emulation; if (2) is true, no driver code ever writes to it and the chip stays silent — which matches reality.

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
