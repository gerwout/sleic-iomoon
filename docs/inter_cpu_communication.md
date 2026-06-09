# Inter-CPU Communication

[← Back to main README](../README.md)

## Overview

The IO Moon uses a **dual-CPU architecture** where the 80188 main CPU and the Z80 coprocessor communicate over **connector J1** — an 8-bit handshaken byte-port, **not** shared RAM. The Z80 has no address path into the 80188's memory; bytes cross J1 one at a time under a request/acknowledge handshake. (The 80188's HOLD/HLDA bus-arbitration pins are *not* involved — see below.)

---

## Inter-Board Link: Connector J1 (byte-port + handshake)

The two boards are joined by **connector J1** ("DB20ESP", 20-pin) on the 80188 board (sheet `011-029-05`). J1 carries:

- **8 bidirectional data lines** `DIO0`–`DIO7` (pins 18→11), pulled up by `AR40` (10 kΩ × 8)
- **handshake lines** in both directions: `IR-IN`/`IR-OUT`, `BUSY-IN`/`BUSY-OUT`, `AD-IN`/`AD-OUT`, `IO-IN`/`IO-OUT`
- `/RESOUT`, `SDA-IN`, `CLK-IN`, `GND`

Crucially, **there is no address bus on J1.** The Z80 cannot place an address on the link, so it physically cannot read or write the 80188's memory. The link is a byte-port: one side presents a byte on `DIO0`–`DIO7` and pulses a handshake, the other side latches it. The Z80 firmware corroborates this — it makes no memory access outside its own `0x0000-0x7FFF` ROM and `0xC000-0xC7FF` RAM, so segment `4000h` is **80188-private**, never a shared window.

On the 80188 side the link is a chain of latches/buffers driven by the peripheral chip-selects `/PCS0`–`/PCS3` (each gated with `/WR` or `/RD` through `IC47`):

| Part | Type | Strobe | Role |
|------|------|--------|------|
| `IC41` → `IC42` | 74LS374 → 74LS244 | `/PCS1`·`/WR` | **outbound data** — 80188 → `DIO0`–`DIO7` |
| `IC43` | 74LS244 | `/PCS2`·`/RD` | **inbound data** — `DIO0`–`DIO7` → 80188 D-bus |
| `IC44` | 74LS244 | `/PCS3`·`/RD` | **inbound status** — buffers `BUSY-IN`/`AD-IN`/`SDA-IN`/`CLK-IN` **and the OKI's `/OKBUSY` + `/WAR`** onto the 80188 D-bus |
| `IC45` → `IC46` | 74LS273 → 7406 (o.c.) | `/OOE` | **outbound handshake/control** — `BUSY-OUT`/`AD-OUT`/`IR-OUT`/`IO-OUT`, `/RESOUT`, plus X9C503 pot control (`/CSP`,`/U-D`,`INC`) and the D40 LED |
| `IC40` | 74LS273 | `/PCS0`·`/WR` | control latch — sample-ROM bank `BVROM0-2`, `EEE1/2`, **`/ST` (OKI start)**, `VA12`, `SCREEN` |

That `IC44` puts the **OKI MSM6376's `/OKBUSY` line onto the 80188 data bus** is decisive: the chip whose busy flag the 80188 polls is the chip the 80188 drives. The OKI sits on the 80188 side, not the Z80 side (see *Sound* below).

Communication is **polling-based** — there are no inter-CPU interrupt lines. Each side checks the J1 handshake during its main loop.

### What this corrects

Earlier revisions described an 80188 **HOLD/HLDA** bus-arbitration scheme in which the Z80 took the 80188's bus to reach "shared RAM" at segment `4000h`. That model survives neither the schematic nor the datasheet:

- **J1 has no address lines**, so cross-board memory access is impossible regardless of any arbitration. The link is a byte-port.
- The claim that the boot **"sets RELREG = `C03Ch`, enabling ET=1, which activates HOLD/HLDA"** is a register/bit misreading. Per the 80C188 datasheet the relocation register is at PCB offset `0xFE` (I/O `0xFFFE`), which the boot never writes; the `C03Ch` value is written to I/O `0xFFA0`, which is **UMCS** (the upper-memory / ROM chip-select), not the relocation register. And the relocation register's `ET` bit is the **ESC / numeric-coprocessor trap** enable (it makes the CPU trap on `ESC` opcodes and selects interrupt-controller slave mode) — it is **not** a bus-arbitration enable. HOLD/HLDA on the 80C188 are dedicated pins, always available; they are not switched on by `ET`.

---

## Segment `4000h` Layout (80188-internal)

> **These are 80188-internal addresses, not a shared window.** The Z80 cannot read or write segment `4000h` (J1 has no address bus, and the Z80 makes no memory access outside its own ROM/RAM). Where a row notes a value "received from" or "exchanged with" the Z80, it means the 80188 stores/exposes a byte that *travelled over the J1 byte-port* — the Z80 never touches this memory directly. There is no dual-port RAM.

| Address | Function | Notes |
|---------|----------|-------|
| `4000:1001` | **Language byte** (`== 5` ⇒ Spanish, else English; default `0x04`); seeded once/cycle from NVRAM `5040:01BF` at `D2F3B` | 80188-internal |
| `4000:1134` | Display mode | 80188-internal (drives the DMD) |
| `4000:1135` | Display flags | 80188-internal |
| `4000:1138` | Display control register shadow | 80188-internal |
| `4000:1147` | START button state | 80188-internal; reflects a switch code received from the Z80 over J1 |
| `4000:114C` | Command queue **head** (consumer read pointer) | 80188 writes (initialiser only) |
| `4000:114E` | Command queue **tail** (producer write pointer) | 80188 writes (every push) |
| `4000:1150` | Display buffer pointer 1 | 80188-internal |
| `4000:1152` | Display buffer segment 1 | 80188-internal |
| `4000:1154` | Display buffer pointer 2 | 80188-internal |
| `4000:1156` | Display buffer segment 2 | 80188-internal |
| `4000:1158`+ | **Command queue body** — circular byte FIFO. Consumer **resolved**: it is the 80188's own `dmd_queue_service` (`D000:01E5`), which drains the bytes to the DMD controller at `/PCS1` (`0xA0080`, strobe `/PCS4` `0xA0200`), gated on the ready bit at `0xA0180.0`. It is *not* the Z80 (no `4000h` access) and *not* the PIC at IC23 (DMD-raster only — see below). See [`../research/80188_to_z80_mailbox.md`](../research/80188_to_z80_mailbox.md). |
| `4000:1200`+ | String buffer (text display) | 80188-internal |
| `4000:1220`+ | Secondary buffer | 80188-internal |

The work-RAM window at segment `4000h` is the **MMCS mid-range memory** block (MMCS = `0x41FC`, base `0x40000`), at least **32 KB wide** (`0x40000`–`0x47FFF`); a PinMAME trace (see [`../research/pinmame_session_2/`](../research/pinmame_session_2/)) observed 80188 accesses up to physical `0x47B77`. (The separate **PACS** register = `0xA03C` selects the *peripheral* chip-select block at `0xA0000` — **not** this RAM; see [`80188_config.md`](80188_config.md). Earlier text labelled the `0x41FC` value "PACS"; by decode it is **MMCS**.)

A separate 1 KB DMD frame buffer at segment `7000h` (`0x70000`–`0x703FF`) is also driven by the 80188 — see [`dmd_graphics.md`](dmd_graphics.md). It is **not** part of the segment `4000h` PACS window.

---

## Communication Patterns

### Switch Events (Z80 → 80188)

The Z80 scans the switch matrix and stages the detected switch code in `0xC0FC` in its **local** RAM. The `send_to_80188` routine (Z80 ROM `0x0116`) then transmits that byte over J1: it waits for the port `0x01` bit-1 handshake, sets port `0x81` bit 1 (data-valid), drives the byte onto `DIO0`–`DIO7` via port `0x80`, and pulses port `0x81` bit 2 (switch strobe). On the 80188 side the byte arrives through the inbound latch `IC43` (`/PCS2`·`/RD`); the 80188 stores it at **physical `0x41496`** (`413C:00D6`, labelled `last_switch_code`) and polls it during its main loop. No shared memory is involved — only the J1 byte-port.

The switch code uses a single-producer / single-consumer model: the Z80 sends a code over J1 when a switch closure is detected, and the 80188 clears its stored copy after processing.

### Sound, and the 80188 → coprocessor command queue

A previous draft of this document described "Sound Commands (80188 → Z80)" via shared mailbox. That description was **wrong about the consumer.** The 80188 does push commands into a circular byte queue at `4000:1158+`, with a producer-tail pointer at `4000:114E` and a consumer-head pointer at `4000:114C` (push routine `cmd_queue_push` at `0xD0138`, ~80 call sites at game events). But the Z80 has no memory reads outside its own ROM (`0x0000-0x7FFF`) and RAM (`0xC000-0xC7FF`), so it **cannot** consume the queue.

**Update (2026-06): this is the display/animation queue, its consumer is now resolved, and the sound path is resolved separately.** The `4000:1158+` queue feeds the DMD/animation pipeline and is consumed **within the 80188** by `dmd_queue_service` (`D000:01E5`), which drains the queued bytes to the DMD controller at `/PCS1` (`0xA0080`, strobe `/PCS4` `0xA0200`), gated on the ready bit at `0xA0180.0` (not the Z80, not the DMD-raster PIC). The **sound drivers are a different 80188 code path**, located and byte-verified in ROM1 (`V1 3_01.bin`): the OKI is triggered from `D000:0B70`/`0C57` (control latch at `0xA0300`, `/OKCS` strobe via `0xA0000` bit 5), and the **YM3812 music is driven from `D000:0D37`/`0D99` via /PCS5 at `0xA0280`/`0xA0281`** (10 FM tracks; song table `CS:0DE5`). The 80188's two DMA channels are configured but parked — not a sound path. Earlier drafts hypothesised PICs at IC34 and "IC57"; those turned out to be a 74LS glue chip and a PAL 20L10. See [`hardware_architecture.md`](hardware_architecture.md) for the chip inventory and [`../research/80188_to_z80_mailbox.md`](../research/80188_to_z80_mailbox.md) for the investigation.

The Z80 does **not** drive the OKI MSM6376. It generates sound-command bytes locally (from game/solenoid events) in `0xC008` (`ram_sound_cmd`) and **forwards them to the 80188 over J1** — the same byte-port used for switch codes, but tagged as a sound command (port `0x81` bit 0 + bit 1 set, bit 5 strobed instead of bit 2). The **80188** then drives the OKI: it latches the phrase number and channel into `IC50` (74LS273, clocked by `/OKCS`), asserts `/ST` (start) from `IC40` Q6, and polls the OKI's `/OKBUSY` line back through `IC44`. The Z80 has no wires to the OKI at all. The 80188 likewise owns the **YM3812** (chip-select `/PCS5`, sheet `011-029-07`).

### Display Commands

The display-buffer pointers at `4000:1150-1156` are the 80188's internal double-buffering state — not a Z80-facing interface. The 80188 fills one buffer while the PIC raster coprocessor at IC23 streams the other to the plasma panel.

### Lamp and Solenoid State

The 80188 communicates the desired lamp and solenoid states to the Z80 **over J1** (the reverse direction of the byte-port — the 80188 presents a byte via `IC41`/`IC42` and drives the handshake via `IC45`/`IC46`); the Z80 applies them to the hardware during its scan cycle. (The exact Z80-side decode for the reverse path — via PAL `IC8` and connector `J3` — has not been traced.)

---

## Key Observations

- **No interrupt lines**: Communication is entirely polling-based. Both CPUs check for new data during their respective main loops.
- **One byte per handshake**: the link moves a single byte at a time over J1. There is no bus contention, because the Z80 never touches the 80188's bus — only the byte-port.
- **Both CPUs are little-endian**: multi-byte values are stored LSB first.
- **The 80188 runs at a higher clock speed** than the Z80 (exact 80188 clock not confirmed; Z80 is 8 MHz).
- **Connector J1 is the sole inter-CPU interface**: the 8-bit handshaken byte-port is the only link between the two CPUs. Segment `4000h` is 80188-private, not a shared resource.
