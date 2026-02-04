# Z80 I/O Port Map

[← Back to main README](../README.md)

## Port Assignments

| Port | Direction | Function |
|------|-----------|----------|
| `0x00` | IN | Data from 80188 |
| `0x01` | IN | Status / Timing |
| `0x02` | IN | Switch Matrix Column Read |
| `0x03` | IN | Direct Switches (Flippers, START, Coin) |
| `0x04` | IN | Direct Switches (Tilt, etc.) |
| `0x80` | OUT | Lamp Matrix Row / Sound Data |
| `0x81` | OUT | Control Register / Sound Control |
| `0x82` | OUT | Switch Matrix Row Strobe |
| `0x83` | OUT | Solenoid Control Bank 1 |
| `0x84` | OUT | Solenoid Control Bank 2 |
| `0x85` | OUT | Sound Control 1 |
| `0x86` | OUT | Sound Control 2 |
| `0x87` | OUT | Lamp / General Control |

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
