# 80188 Peripheral Configuration

[← Back to main README](../README.md)

> **2026-06 correction.** An earlier revision of this document mis-identified the
> 80C188 chip-select registers — it shifted every label up by one 2-byte slot
> (calling `0xFFA0` "RELREG" when it is **UMCS**) and mis-read the relocation
> register's `ET` bit as a "HOLD/HLDA bus-sharing enable". Both were wrong. The
> register identities and values below are the corrected ones, confirmed two ways:
> (1) decoding the boot-time Peripheral Control Block writes against the 80C188
> datasheet, and (2) a live PinMAME PCB-register trace
> ([`../research/pinmame_session_2/`](../research/pinmame_session_2/)).

## Boot-time register configuration

The reset stub at `0xFFF00` writes **one** register, then jumps to the main init:

```asm
FFF00:  MOV DX, FFA0h      ; UMCS  (NOT "RELREG")
        MOV AX, C03Ch
        OUT DX, AX         ; open the upper-memory (ROM) chip-select window
        JMP FAR D000:0000  ; -> main_init
```

`main_init` at `0xD0000` then programs the rest of the Peripheral Control Block
from a 30-word table (loaded with a `lodsw / out dx,ax` loop at `0xD0018`). The
PCB stays at its reset location (I/O `0xFF00`–`0xFFFF`), so the register at I/O
`0xFFA0` is PCB offset `A0h`.

## Chip-Select registers (corrected identities + values)

80C188 PCB offsets: **UMCS = A0h, LMCS = A2h, PACS = A4h, MMCS = A6h, MPCS = A8h**,
relocation register = **FEh**.

| Register | I/O port | Value | Decoded |
|----------|----------|-------|---------|
| **UMCS** | `0xFFA0` | `C03Ch` | Upper-memory (ROM) block **start = `0xC0000`**, ends at `0xFFFFF` (256 KB). Holds the 80188 code (segments D000/E000/F000). |
| **LMCS** | `0xFFA2` | `3FFCh` | Lower-memory block **`0x00000`–`0x3FFFF`** (256 KB). ROM2 graphics. |
| **PACS** | `0xFFA4` | `A03Ch` | **Peripheral chip-select base (PBA) = `0xA0000`**, + PCS0–PCS3 wait states. |
| **MMCS** | `0xFFA6` | `41FCh` | Mid-range **memory** block **base = `0x40000`** (segment `4000h` — the 80188 work RAM, UM62256 at IC12). |
| **MPCS** | `0xFFA8` | `A0FCh` | **MS bit = 1** (peripherals are **memory-mapped**, in the PACS block, not I/O), **EX bit = 1** (all **7** PCS lines active), + mid-range block size and PCS4–6 wait states. |

The relocation register at **I/O `0xFFFE` is never written** — the PCB is left at
its reset location. There is therefore **no `ET`-bit / HOLD-HLDA / bus-sharing
mechanism** (the Z80 reaches the 80188 only through the J1 byte-port — see
[`inter_cpu_communication.md`](inter_cpu_communication.md)).

> Note: where [`inter_cpu_communication.md`](inter_cpu_communication.md) refers to
> "the PACS register value `0x41FC`", that value (`0x41FC`) is by decode the
> **MMCS** write (mid-range base `0x40000`); the **PACS** write is `0xA03C`
> (peripheral base `0xA0000`). The physical facts — a segment-`4000h` RAM window
> and a peripheral block at `0xA0000` — are right in both documents; only the
> register-name↔value pairing was swapped.

## The peripheral chip-select block at `0xA0000`

Because MPCS MS=1 (memory-mapped) and EX=1 (7 selects), PACS places the seven
peripheral chip-selects PCS0–PCS6 at `0xA0000` on **128-byte (0x80) boundaries**:

| Line | Address | Use (from code + schematic) |
|------|---------|-----------------------------|
| PCS0 | `0xA0000` | DMD control register 1 **and** the OKI `/OKCS` strobe (bit 5 pulsed) |
| PCS1 | `0xA0080` | DMD control register 2 |
| PCS2 | `0xA0100` | (inbound J1 data path per schematic; not exercised in boot/attract) |
| PCS3 | `0xA0180` | (inbound J1 status per schematic) |
| PCS4 | `0xA0200` | DMD mode / frame strobe (bit 3 toggled per frame) |
| **PCS5** | **`0xA0280` / `0xA0281`** | **YM3812** — address/index port (A0=0) and data port (A0=1). Driven by the FM music sequencer (see [`z80_io_ports.md`](z80_io_ports.md) → "YM3812 routing"). |
| PCS6 | `0xA0300` | DMD enable **and** the OKI control latch (sample # + channel/bank) |

So the block the 80188 reaches at segment `A000h` is **not** a pure "DMD register
window": it is the whole peripheral chip-select region, carrying the DMD control,
the OKI control/strobe, and the YM3812. The exact bit-level split on PCS0/PCS6
(DMD vs OKI) and any further IC7 PAL sub-decode await the IC7 dump.

## Wait states

The chip-select low bytes (`...3C` / `...FC`) encode the ready/wait configuration
per the 80C186/80C188 chip-select unit. The abbreviated datasheet does not include
a per-register bit table, so the exact wait-state *count* is not pinned down here;
the earlier doc's flat "3 wait states for everything" claim is **not** supported by
the bits and should be treated as unverified.

## I/O port / timer / DMA configuration table

The 30-word table at `DS:0041` (RAM-resident, not in the static ROM image, but
captured executing in the PCB trace) also programs the 80188's integrated timers,
interrupt controller and DMA channels. Notably the **two DMA channels are
configured but left parked** (source/dest at the top of ROM, start bit clear) and
are never re-armed at runtime — sound is **not** DMA-driven; it is explicit
ISR-driven writes to the peripheral block above.
