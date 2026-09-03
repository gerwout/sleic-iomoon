# 80188 Peripheral Configuration

[← Back to main README](../README.md)

The register identities and values below are read out of the boot code in
[`../asm/baseline-2026-09/iomoon_80188.lst`](../asm/baseline-2026-09/) and decoded
against the 80C188 datasheet; they are finding **F1** of
[`findings.md`](../asm/baseline-2026-09/findings.md).

## Boot-time register configuration

The reset stub at `0xFFF00` writes **one** register, then jumps to the main init:

```asm
FFFF0:  JMP FAR FFF0:0000
FFF00:  MOV DX, FFA0h      ; UMCS
        MOV AX, C03Ch
        OUT DX, AX         ; open the upper-memory (ROM) chip-select window
        JMP FAR D000:0000  ; -> boot_init
```

`boot_init` at `0xD0000` then programs the rest of the Peripheral Control Block
from a **30-entry table in ROM at `CS:0041`–`CS:00B9`** (four bytes per entry:
port word, value word), walked by a `lodsw / lodsw / out dx,ax / loop` loop at
`0xD0018`:

```asm
D0012:  MOV SI, 0041h      ; the table, in the code segment
D0015:  MOV CX, 001Eh      ; 30 entries
D0018:  LODSW CS: / MOV DX,AX / LODSW CS: / OUT DX,AX / LOOP
```

The PCB stays at its reset location (I/O `0xFF00`–`0xFFFF`), so the register at
I/O `0xFFA0` is PCB offset `A0h`. **Nothing reprograms any of this after boot:**
the only PCB registers written anywhere else in the decoded ROM are `FF2C`
(INSERV, the two end-of-interrupt writes) and `FFA0` (UMCS, in the reset stub).

## Chip-select registers

80C188 PCB offsets: **UMCS = A0h, LMCS = A2h, PACS = A4h, MMCS = A6h, MPCS = A8h**,
relocation register = **FEh**.

| Register | I/O port | Value | Decoded |
|----------|----------|-------|---------|
| **UMCS** | `0xFFA0` | `C03Ch` | Upper-memory (ROM) block **`0xC0000`–`0xFFFFF`** (256 KB). ROM1's upper half: all 80188 code (segments D000/E000/F000) and the reset vector. |
| **LMCS** | `0xFFA2` | `3FFCh` | Lower-memory block **`0x00000`–`0x3FFFF`** (256 KB). ROM1's **lower** half: the resident interrupt vector table at physical 0, followed by the animation and font data the `F5183` far-pointer table addresses. Not banked. |
| **PACS** | `0xFFA4` | `A03Ch` | **Peripheral chip-select base (PBA) = `0xA0000`**, + PCS0–PCS3 wait states. |
| **MMCS** | `0xFFA6` | `41FCh` | Mid-range **memory** block **base = `0x40000`**. |
| **MPCS** | `0xFFA8` | `A0FCh` | **MS bit = 1** (peripherals are **memory-mapped**, in the PACS block, not I/O), **EX bit = 1** (all **7** PCS lines active), + mid-range block size and PCS4–6 wait states. |

The relocation register at **I/O `0xFFFE` is never written** — the PCB is left at
its reset location, and there is no bus-sharing mechanism of any kind. The Z80
reaches the 80188 only through the J1 byte-port; see
[`inter_cpu_communication.md`](inter_cpu_communication.md).

### The four mid-range memory blocks

MMCS + MPCS give four 64 KB blocks `MCS0`–`MCS3` based at `0x40000`:

| Line | Range | Use |
|------|-------|-----|
| MCS0 | `0x40000`–`0x4FFFF` | 80188 work RAM (UM62256 at IC12); stack `SS:SP = 4152:0205` |
| MCS1 | `0x50000`–`0x5FFFF` | non-volatile store, window at segment `5040` = `0x50400` (finding F10) |
| MCS2 | `0x60000`–`0x6FFFF` | **one 64 KB page of the graphics ROM**, selected by PCS0 bits 0–2 (finding F2) |
| MCS3 | `0x70000`–`0x7FFFF` | DMD staging buffer at `7000:0000`–`7000:03FF` (finding F13) |

The segments the firmware actually loads confirm the map is complete:
`0000`/`1000`/`3000` (LMCS), `4000`/`4130`/`4134`/`4137`/`413C` (MCS0), `5040`
(MCS1), `7000` (MCS3), `A000` (PACS) — and `6000` never as an immediate, only
through the far pointers F2 describes.

## The peripheral chip-select block at `0xA0000`

Because MPCS MS=1 (memory-mapped) and EX=1 (7 selects), PACS places the seven
peripheral chip-selects PCS0–PCS6 at `0xA0000` on **128-byte (0x80) boundaries**:

| Line | Address | Use |
|------|---------|-----|
| PCS0 | `0xA0000` | Control byte, shadowed at `[4000:1134]`, boot value `0x28`. Bits 0–2 = graphics page select (F2); bits 3/4 = the complementary non-volatile-store window gate (F10); bit 5 = the OKI `/OKCS` strobe (F9); bits 6/7 never written. |
| PCS1 | `0xA0080` | **Outbound J1 data latch** — the byte `qout_service_pcs1` (`D01E5`) presents to the Z80 (F6). |
| PCS2 | `0xA0100` | **Inbound J1 data latch** — read in exactly one place in the whole 80188 ROM, the NMI handler at `D018C` (F4/F6). |
| PCS3 | `0xA0180` | Inbound status; **bit 0 = the Z80 has taken the last outbound byte**, tested at `D0206` before the next one is presented (F6). |
| PCS4 | `0xA0200` | Outbound handshake/control, shadowed at `[4000:1138]`. Bits 7/6/4 are asserted around the inbound read (`D0181`), bits 6 and 5 are the two outbound strobes (`D0216`/`D022A`), and bit 3 is pulsed exactly once, from `boot_init` (F6/F13). |
| **PCS5** | **`0xA0280` / `0xA0281`** | **YM3812** — index port (A0=0) and data port (A0=1), two distinct addresses. Written only by `ym3812_write` `D0D99` (F8). |
| PCS6 | `0xA0300` | **OKI MSM6376 control latch** — bits 0–6 phrase number, bit 7 channel; boot value `0x80` (F9). |

So the block the 80188 reaches at segment `A000h` is the peripheral chip-select
region carrying the J1 byte-port latches and both sound chips. It is not a DMD
register window: the DMD path is the staging buffer in MCS3, and the raster
coprocessor at IC23 has no command interface at all (F13,
[`../asm/pic16c57_annotated.asm`](../asm/pic16c57_annotated.asm)).

The exact bit-level pin mapping of the PCS0 and PCS6 bytes at the OKI, and any
further IC7 PAL sub-decode, await the IC7 dump
([`chips_to_dump.md`](chips_to_dump.md)).

## Timers, interrupt controller and DMA

The same 30-entry table programs the integrated timers, interrupt controller and
DMA channels:

- **Timer 0**: mode `E003` (enabled, interrupt on, continuous), max count A = max
  count B = `6276h` = 25206, clocked at CLKOUT/4. At the inferred CLKOUT of
  10 MHz that is 2 500 000 / 25206 = **99.18 Hz**. The count is confirmed; the
  crystal is not stated by any ROM.
- **Timers 1 and 2**: disabled (`FF5E` / `FF66` = 0).
- **Interrupt controller**: only **timer 0** (`FF32` = `0001`, priority 1) and
  **INT0** (`FF38` = `0000`, priority 0, edge-triggered) are unmasked; DMA0,
  DMA1, INT1, INT2 and INT3 all have MSK set (`000F`), and PRIMSK (`FF2A`) = 1
  restricts service to priority levels 0–1.
- **Both DMA channels are programmed and parked** — the control word `FFA0` is
  written *first*, with ST (bit 1) and CHG (bit 2) both clear, so the write
  cannot start a channel, and nothing re-arms them at runtime. Sound is explicit
  ISR-driven writes to the peripheral block, not DMA.

Together with the resident vector table that gives three live interrupt sources —
NMI (`D000:016D`), timer 0 (`D000:024F`) and INT0 (`D000:0343`) — described in
finding F3.

## Wait states

The chip-select low bytes (`...3C` / `...FC`) encode the ready/wait configuration
per the 80C186/80C188 chip-select unit. The abbreviated datasheet carries no
per-register bit table, so the exact wait-state *count* is not pinned down here.
