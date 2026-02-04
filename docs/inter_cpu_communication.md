# Inter-CPU Communication

[← Back to main README](../README.md)

## Overview

The IO Moon uses a **dual-CPU architecture** where the 80188 main CPU and the Z80 coprocessor communicate through **shared RAM** at segment `4000h`. Bus access is coordinated using the 80188's built-in **HOLD/HLDA** bus arbitration mechanism.

---

## Bus Arbitration: HOLD/HLDA

The 80188's RELREG register is set to `C03Ch` at boot, which enables **ET=1** (Escape/External Trigger mode). This activates the HOLD/HLDA protocol:

1. The Z80 **asserts HOLD** when it needs to access shared memory
2. The 80188 completes its current bus cycle, then **asserts HLDA** (Hold Acknowledge) and tri-states its bus
3. The Z80 reads from or writes to the shared RAM at `4000h`
4. The Z80 **releases HOLD**
5. The 80188 de-asserts HLDA and resumes execution

This is a **polling-based** scheme — there are no direct interrupt lines between the two CPUs. Each CPU checks for data from the other during its main processing loop.

---

## Shared RAM Layout (Segment `4000h`)

| Address | Function | Access |
|---------|----------|--------|
| `4000:1001` | Game status byte | Read/Write both CPUs |
| `4000:1134` | Display mode | 80188 writes, Z80 reads |
| `4000:1135` | Display flags | 80188 writes, Z80 reads |
| `4000:1138` | Display control register shadow | 80188 writes |
| `4000:1147` | START button state | Z80 writes, 80188 reads |
| `4000:114C` | Command queue write pointer | 80188 writes |
| `4000:114E` | Command queue read pointer | 80188 reads |
| `4000:1150` | Display buffer pointer 1 | 80188 writes |
| `4000:1152` | Display buffer segment 1 | 80188 writes |
| `4000:1154` | Display buffer pointer 2 | 80188 writes |
| `4000:1156` | Display buffer segment 2 | 80188 writes |
| `4000:1158`+ | Command / display buffer start | Both CPUs |
| `4000:1200`+ | String buffer (used by text display) | 80188 writes |
| `4000:1220`+ | Secondary buffer | Both CPUs |

---

## Communication Patterns

### Switch Events (Z80 → 80188)

The Z80 scans the switch matrix and writes detected switch codes to `0xC0FC` in its local RAM. The 80188 reads this value during its main loop to process switch events.

The switch code byte uses a single-producer / single-consumer model: the Z80 writes a code when a switch closure is detected, and the 80188 clears it after processing.

### Sound Commands (80188 → Z80)

The 80188 sends sound trigger commands to the Z80 via the shared mailbox. The Z80 reads these commands and drives the OKI MSM6376 sound chip via ports `0x80`–`0x81`.

### Display Commands

The 80188 maintains a **command queue** using write/read pointers at `4000:114C` and `4000:114E`. Display update commands are queued by the game logic and processed by the display update routines within the 80188's main loop.

### Lamp and Solenoid State

The 80188 writes desired lamp and solenoid states to shared memory, which the Z80 reads and applies to the hardware during its scan cycle.

---

## Key Observations

- **No interrupt lines**: Communication is entirely polling-based. Both CPUs check for new data during their respective main loops.
- **Bus contention is minimal**: The Z80 accesses shared RAM only briefly during each scan cycle. The HOLD/HLDA handshake ensures clean transfers.
- **Both CPUs use little-endian byte order**: Multi-byte values in shared RAM are stored LSB first.
- **The 80188 runs at a higher clock speed** than the Z80 (exact 80188 clock not confirmed; Z80 is 8 MHz).
- **Segment `4000h` is the sole communication interface**: There are no other shared resources between the two CPUs.
