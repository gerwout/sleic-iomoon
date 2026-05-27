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
| `4000:114C` | Command queue **head** (consumer side — read pointer) | 80188 writes (initialiser only) |
| `4000:114E` | Command queue **tail** (producer side — write pointer) | 80188 writes (every push) |
| `4000:1150` | Display buffer pointer 1 | 80188 writes |
| `4000:1152` | Display buffer segment 1 | 80188 writes |
| `4000:1154` | Display buffer pointer 2 | 80188 writes |
| `4000:1156` | Display buffer segment 2 | 80188 writes |
| `4000:1158`+ | **Command queue body** — circular byte FIFO read by an external coprocessor (almost certainly the PIC at IC34 or IC57); see [`../research/80188_to_z80_mailbox.md`](../research/80188_to_z80_mailbox.md). Despite the section title, **this queue is NOT consumed by the Z80** — the Z80 has no reads outside its `0x0000-0x7FFF` ROM and `0xC000-0xC7FF` RAM. |
| `4000:1200`+ | String buffer (used by text display) | 80188 writes |
| `4000:1220`+ | Secondary buffer | Both CPUs |

The PACS window at segment `4000h` is at least **32 KB wide** (`0x40000`–`0x47FFF`). A PinMAME debugger trace (see [`../research/pinmame_session_2/`](../research/pinmame_session_2/)) observed 80188 accesses up to physical `0x47B77`, well past the small `4000:11xx` mailbox area documented here. The full extent of the window is determined by the PACS register value `0x41FC` written at boot and the 80188's internal chip-select decode.

A separate 1 KB DMD frame buffer at segment `7000h` (`0x70000`–`0x703FF`) is also driven by the 80188 — see [`dmd_graphics.md`](dmd_graphics.md). It is **not** part of the segment `4000h` PACS window.

---

## Communication Patterns

### Switch Events (Z80 → 80188)

The Z80 scans the switch matrix and writes detected switch codes to `0xC0FC` in its local RAM. The `send_to_80188` routine (Z80 ROM `0x0116`) then latches that byte into the 80188's view of shared RAM at **physical `0x41496`** (`413C:00D6`, labelled `last_switch_code` in the 80188 disassembly) via port `0x80` + port `0x81` bit 1 + bit 2 strobe. The 80188 polls `413C:00D6` during its main loop to process switch events.

The switch code byte uses a single-producer / single-consumer model: the Z80 writes a code when a switch closure is detected, and the 80188 clears it after processing.

### Sound / Command Queue (80188 → coprocessor — **NOT Z80**)

A previous draft of this document described "Sound Commands (80188 → Z80)" via shared mailbox. That description was **wrong about the consumer.** The 80188 does push commands into a circular byte queue at `4000:1158+`, with a producer-tail pointer at `4000:114E` and a consumer-head pointer at `4000:114C` (push routine `cmd_queue_push` at `0xD0138`, ~80 call sites at game events). But the Z80 has no memory reads outside its own ROM (`0x0000-0x7FFF`) and RAM (`0xC000-0xC7FF`), so it **cannot** consume the queue.

The actual consumer is almost certainly the undocumented Microchip PIC at IC34 (PDIP-28) or IC57 (PDIP-18) on the 16-bit board — see [`hardware_architecture.md`](hardware_architecture.md) for the photographic evidence and [`../research/80188_to_z80_mailbox.md`](../research/80188_to_z80_mailbox.md) for the full investigation. Confirming requires dumping one of those PICs.

The Z80 drives the OKI MSM6376 directly through ports `0x80` + `0x81` from local Z80 RAM (`0xC008` = `ram_sound_cmd`), generated locally from solenoid events — *not* from any byte the 80188 sends.

### Display Commands

The display-buffer pointers at `4000:1150-1156` are the 80188's internal double-buffering state — not a Z80-facing interface. The 80188 fills one buffer while the PIC raster coprocessor at IC23 streams the other to the plasma panel.

### Lamp and Solenoid State

The 80188 writes desired lamp and solenoid states to shared memory, which the Z80 reads and applies to the hardware during its scan cycle.

---

## Key Observations

- **No interrupt lines**: Communication is entirely polling-based. Both CPUs check for new data during their respective main loops.
- **Bus contention is minimal**: The Z80 accesses shared RAM only briefly during each scan cycle. The HOLD/HLDA handshake ensures clean transfers.
- **Both CPUs use little-endian byte order**: Multi-byte values in shared RAM are stored LSB first.
- **The 80188 runs at a higher clock speed** than the Z80 (exact 80188 clock not confirmed; Z80 is 8 MHz).
- **Segment `4000h` is the sole communication interface**: There are no other shared resources between the two CPUs.
