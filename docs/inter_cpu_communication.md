# Inter-CPU Communication

[← Back to main README](../README.md)

## Overview

The IO Moon's 80188 main CPU and Z80 I/O CPU communicate over **connector J1** —
an 8-bit byte-port with handshakes, **not** shared RAM. The Z80 has no address
path into the 80188's memory; bytes cross J1 one at a time, and **each direction
raises an interrupt on the receiving CPU**. This is finding **F6** of
[`findings.md`](../asm/baseline-2026-09/findings.md).

---

## Inter-Board Link: Connector J1 (byte-port + handshake)

The two boards are joined by **connector J1** ("DB20ESP", 20-pin) on the 80188 board (sheet `011-029-05`). J1 carries:

- **8 bidirectional data lines** `DIO0`–`DIO7` (pins 18→11), pulled up by `AR40` (10 kΩ × 8)
- **handshake lines** in both directions: `IR-IN`/`IR-OUT`, `BUSY-IN`/`BUSY-OUT`, `AD-IN`/`AD-OUT`, `IO-IN`/`IO-OUT`
- `/RESOUT`, `SDA-IN`, `CLK-IN`, `GND`

**There is no address bus on J1.** The Z80 cannot place an address on the link,
so it physically cannot read or write the 80188's memory. The link is a
byte-port: one side presents a byte on `DIO0`–`DIO7` and pulses a handshake, the
other side latches it. The Z80 firmware corroborates this — it makes no memory
access outside its own `0x0000-0x7FFF` ROM and `0xC000-0xC7FF` RAM, so segment
`4000h` is **80188-private**. The 80188's relocation register (I/O `0xFFFE`) is
never written and its HOLD/HLDA pins play no part; see
[`80188_config.md`](80188_config.md).

On the 80188 side the link is a chain of latches/buffers driven by the peripheral chip-selects `/PCS0`–`/PCS3` (each gated with `/WR` or `/RD` through `IC47`):

| Part | Type | Strobe | Role |
|------|------|--------|------|
| `IC41` → `IC42` | 74LS374 → 74LS244 | `/PCS1`·`/WR` | **outbound data** — 80188 → `DIO0`–`DIO7` |
| `IC43` | 74LS244 | `/PCS2`·`/RD` | **inbound data** — `DIO0`–`DIO7` → 80188 D-bus |
| `IC44` | 74LS244 | `/PCS3`·`/RD` | **inbound status** — buffers `BUSY-IN`/`AD-IN`/`SDA-IN`/`CLK-IN` **and the OKI's `/OKBUSY` + `/WAR`** onto the 80188 D-bus |
| `IC45` → `IC46` | 74LS273 → 7406 (o.c.) | `/OOE` | **outbound handshake/control** — `BUSY-OUT`/`AD-OUT`/`IR-OUT`/`IO-OUT`, `/RESOUT`, plus X9C503 pot control (`/CSP`,`/U-D`,`INC`) and the D40 LED |
| `IC40` | 74LS273 | `/PCS0`·`/WR` | control latch — sample-ROM bank `BVROM0-2`, `EEE1/2`, **`/ST` (OKI start)**, `VA12`, `SCREEN` |

`IC44` puts the OKI MSM6376's `/OKBUSY` line on the 80188 data bus, which is
consistent with the OKI sitting on the 80188 side of the machine — though the
80188 firmware never reads it: its busy model is entirely software (finding F9).

### Z80 → 80188

The Z80 has two outbound channels sharing the data port at `OUT ($80)`:

| Channel | Payload | Routine | Strobe |
|---|---|---|---|
| `C0FC` | one-byte **event code** (a switch, a status reply — see [`z80_io_ports.md`](z80_io_ports.md)) | `host_send_c0fc` `0116` | port-`0x81` **bit 2** |
| `C008` | an 8-bit **state bitmask**, bits set and cleared individually | `host_send_c008_a` `0144`, `_b` `017E` | port-`0x81` **bit 5** |

```asm
host_send_c0fc 0116:
    IN A,($01) / BIT 1,A / JR Z,self   ; spin until the port is free
    DI
    (C001) |= 0x02, OUT ($81)          ; data-valid
    A = (C0FC), OUT ($80)              ; the byte onto DIO0-DIO7
    (C001) |= 0x04, OUT ($81)          ; strobe bit 2
    (C001) &= ~0x04, OUT ($81)
```

The strobe raises an **NMI** on the 80188. Its handler `D000:016D` reads the byte
at PCS2 `0xA0100` — the only read of that address in the whole 80188 ROM —
asserting PCS4 bits 7/6/4 around the read and leaving bit 7 asserted afterwards
as the acknowledgement. `pcs4_clear_bit7` `D0331` drops it again from the timer-0
ISR, 16 timer ticks (~161 ms) after the last inbound byte.

### 80188 → Z80

An outbound FIFO in work RAM at `4000:1158`, drained by the INT0 ISR:

```asm
qout_push          D0138   append a byte, advance the write pointer [114E]
qout_service_pcs1  D01E5   called from the INT0 ISR:
    [1145] counts 3->0, so it acts on one call in four
    head byte from [114C]; 0 = queue empty
    TEST ES:00180, 001     ; PCS3 bit 0 = the Z80 has taken the previous byte
    MOV ES:B[00080], AL    ; PCS1 = the byte
    PCS4 |= 0x40 ; PCS4 |= 0x20 ; 13x NOP ; PCS4 &= ~0x20 & ~0x40
```

Because the ISR calls it on alternate INT0s and it acts on one call in four, the
outbound byte rate is **INT0 / 8**.

That strobe is an **NMI on the Z80** (handler `0066`): it raises port-`0x81`
bit 4, reads the byte with `IN A,($00)`, stores it into a ring at `$C076` (read
pointer `$C072`, write pointer `$C074`) and returns. `host_cmd_dispatch` `16D5`
then indexes the **256-entry word table at `$2000`** with the byte and `JP (HL)`s
— so every outbound byte is a Z80 **command**. There is also a polled inbound
path, `host_read_byte` `01B6`, gated by port-`0x81` bit 6 instead of bit 4, used
only by `direct_input_scan`.

**Port `0x01` bit 1 is a bus-free/ready line in both directions** — it is the
spin condition of all three `host_send_*` routines and of `host_read_byte`.

### The boot handshake

The Z80 sends `0x47` at `0410`, and the 80188's `main_entry` spins at `D2F59`
until it arrives:

```asm
D2F59:  CALL sub_D5D1B     ; poll the inbound FIFO for 0x47
D2F5E:  OR   AL, AL
D2F60:  JE   0D2F59
```

Nothing downstream of that point runs until the byte is delivered.

---

## Segment `4000h` layout (80188-internal)

> These are 80188-internal addresses, not a shared window. The Z80 cannot read
> or write segment `4000h`. Where a row mentions a value that "came from" the
> Z80, it means the 80188 stored a byte that travelled over the J1 byte-port.

| Address | Function |
|---------|----------|
| `4000:1001` | **Country / language byte** (`== 5` ⇒ Spanish, else English); loaded from the non-volatile store offset `0x1BF` at `D2F3B`, and rewritten from the SW40 country DIP at `D664D` whenever the two disagree |
| `4000:1134` | **PCS0 output shadow** — graphics page (bits 0–2), NVRAM window gate (bits 3/4), OKI `/OKCS` (bit 5) |
| `4000:1135` | **PCS1 output shadow** — the last byte presented on the outbound latch |
| `4000:1138` | **PCS4 output shadow** — the J1 outbound handshake bits |
| `4000:1145` | Divider that makes `qout_service_pcs1` act on one call in four; boot value 4 |
| `4000:1142` | INT0 half-frame toggle: even = DMD blit + animation dispatch, odd = DMD composite + FM tick + outbound-queue service |
| `4000:1144` | **Coin-pulse counter** — the NMI increments it for inbound byte `0x32` instead of queueing the byte |
| `4000:1147` | **Inbound-byte-available flag**, set to `0xFF` by the NMI |
| `4000:114C` | Outbound command queue **read pointer** (consumer) |
| `4000:114E` | Outbound command queue **write pointer** (producer) |
| `4000:1150` / `4000:1152` | Inbound FIFO **far read pointer** (offset / segment) |
| `4000:1154` / `4000:1156` | Inbound FIFO **far write pointer** (offset / segment) |
| `4000:1158`+ | **Outbound command queue body** — the byte stream drained to PCS1 for the Z80 |
| `4000:1220`–`12E7` | **Inbound byte FIFO** — every non-`0x32` byte the NMI receives |
| `4000:12EA`–`12EF` | FM sequencer state (stream pointer, duration, enable, tempo) |
| `4000:12FC`–`1305` | OKI channel state (sample numbers, duration counters, deferred trigger) |

The DMD pixel pipeline occupies `4000:0000`–`0DFF` and is documented in
[`dmd_graphics.md`](dmd_graphics.md); the display buffer itself is at segment
`7000`. Segment `4000h` is MCS0, the first of the four mid-range memory blocks
based at `0x40000` ([`80188_config.md`](80188_config.md)).

---

## What crosses the link

### Switch and status events (Z80 → 80188)

The Z80 scans the switch matrix and stages the detected code in `0xC0FC` in its
**local** RAM, then `host_send_c0fc` transmits it. On the 80188 side the NMI
appends it to the FIFO at `4000:1220`; the general dispatcher `sub_D7453` pops
one byte and stores it in **`413C:00D6` = physical `0x41496`** before acting on
it. The code map — 48 matrix positions, six cabinet inputs, the direct-input
scan and the status replies — is in [`z80_io_ports.md`](z80_io_ports.md).

Every consumer of the inbound FIFO **pops one byte unconditionally and then
tests it**, discarding it if it is not the value that consumer wants. A byte that
arrives while the firmware is spinning in a different poll routine is therefore
consumed and dropped. That is firmware behaviour, and an emulator reproduces it
simply by delivering bytes.

### Lamp, driver and mode commands (80188 → Z80)

The outbound queue carries **Z80 command bytes** — the indices of the 256-entry
table at `$2000`. `qout_push` has 172 call sites with 54 distinct constant
immediates, all valid table indices, and the handshake at `D2F96` proves the
payload's identity: the 80188 pushes `0xC0`, Z80 table entry `0xC0` is `$11F5`
(the direct-input self-scan), and the reply `0x7A` is exactly the byte the 80188
then waits for. What the commands do — 64 lamps in two blink banks, two
active-low driver latches, canned lamp sequences, test-mode entry and exit — is
in [`z80_io_ports.md`](z80_io_ports.md) and
[`switch_lamp_solenoid.md`](switch_lamp_solenoid.md).

### Sound

**No sound command crosses J1 in either direction.** Both sound chips are on the
16-bit board and are written directly by 80188 game code: the OKI MSM6376
through the dispatcher `sub_D0B70` (81 call sites, latch at `0xA0300` plus the
`0xA0000` bit-5 `/OKCS` strobe) and the YM3812 through `fm_song_select` `D0DB4`
(24 call sites, sequencer `D0D37`, write primitive `D0D99`, ports
`0xA0280`/`0xA0281`). Neither takes its argument from a queue; both are far-called
with an immediate or computed byte on the stack. This is finding F12.

### Display

The 80188 composes DMD frames entirely on its own side and blits them into the
staging buffer at `7000:0000`–`03FF`; the PIC16C57 at IC23 free-runs a raster
over that buffer. Nothing about the display crosses J1. See
[`dmd_graphics.md`](dmd_graphics.md).

---

## Key observations

- **Each direction interrupts the receiver**: the Z80's strobe raises the
  80188's NMI, and the 80188's strobe raises the Z80's NMI. Only the ready line
  (port `0x01` bit 1 / PCS3 bit 0) is polled.
- **One byte per handshake**: the link moves a single byte at a time. There is no
  bus contention, because the Z80 never touches the 80188's bus.
- **Both CPUs are little-endian**: multi-byte values are stored LSB first.
- **Connector J1 is the sole inter-CPU interface.** Segment `4000h` is
  80188-private, not a shared resource.

Two details are traced but not settled without the PAL dumps
([`chips_to_dump.md`](chips_to_dump.md)): which physical J1 line each of PCS4
bits 5/6/7 and PCS3 bit 0 corresponds to, and whether the Z80's two outbound
strobes reach the same 80188 latch. On the latter the balance of evidence says
they do — `0xA0100` is the only inbound read in the 80188 ROM, so a byte sent on
the bit-5 channel would otherwise never be read, and `inbound_byte_take_b`
`D5E7A` accepts exactly the value range the `C008` bitmask produces.
