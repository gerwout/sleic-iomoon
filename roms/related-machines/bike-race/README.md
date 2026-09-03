# ROM Set — Bike Race (SLEIC, 1992)

The Bike Race ROM set. Bike Race is PinMAME's `SLEIC3` family: an 80188 game CPU,
a Z80 I/O CPU, an Intel 8039 display coprocessor, a YM3812 (OPL2) for FM music and
an OKI MSM6376 for ADPCM speech/effects — the same architecture IO Moon (`SLEIC2`)
uses, with the notable difference that Bike Race's display coprocessor is a
**fully dumped I8039** where IO Moon's is an undumped PIC16C5x. That is what makes
this set valuable here: it is the live oracle for the shared SLEIC hardware model.

## Files

| Filename | Size | MD5 Checksum | CPU / device | Content |
|----------|------|--------------|--------------|---------|
| `bkdsp01.bin` | 8,192 bytes (8 KB) | `f9c98453e94762f6ddf499e33e98a6cf` | I8039 | Display coprocessor (DMD rasterizer) — only 117 bytes are program, rest `0xFF` |
| `bksnd02.bin` | 524,288 bytes (512 KB) | `1bfba7e4db786c400f76e3b94c58f885` | OKI MSM6376 | ADPCM sample ROM 1 |
| `bksnd03.bin` | 524,288 bytes (512 KB) | `2435a0a13df5ebf8fd759cfbdf23419d` | OKI MSM6376 | ADPCM sample ROM 2 |
| `bkcpu04.bin` | 131,072 bytes (128 KB) | `6e06ee13bc64769c110bb5e17e7b61d9` | 80188 | Game + sound code, linear `0xE0000–0xFFFFF` |
| `bkcpu05.bin` | 131,072 bytes (128 KB) | `6367b9028b7470fc6dbad37a229bc761` | 80188 | Graphics ROM, mapped at **MCS2 `0x40000`** |
| `bkcpu06.bin` | 131,072 bytes (128 KB) | `014c57279281526e71914fe4eb833c67` | 80188 | Graphics ROM, mapped at **MCS1 `0x20000`** |
| `bkio07.bin` | 32,768 bytes (32 KB) | `0141e09fa7a4ff36c666a3d1e777d1c2` | Z80 | I/O CPU ROM (switch matrix, lamps, coils) — 18,635 bytes used |

> **Graphics ROM order matters.** `bkcpu06` belongs at `0x20000` (MCS1) and
> `bkcpu05` at `0x40000` (MCS2). Swapped, the DMD composer reads a garbage frame
> descriptor at segment `0x2000` and runs away in the blit loop. The PinMAME
> `SLEIC3` ROM block and the `MACHINE_DRIVER_START(SLEIC3)` comments in
> `src/wpc/sleic.c` carry this; see also
> [`../../../docs/sleic_board_family.md`](../../../docs/sleic_board_family.md)
> ("Graphics ROM mapping").

## What this set is used for in this repository

- [`../../../research/bikerace_disasm/`](../../../research/bikerace_disasm/) —
  full `ndisasm` of `bkcpu04` and `z80dasm` of `bkio07`, plus the NVRAM
  validation / factory-reset analysis.
- [`../../../docs/bikerace_switch_map.md`](../../../docs/bikerace_switch_map.md) —
  switch-code map recovered from `bkcpu04` and `bkio07`.
- [`../../../docs/sleic_board_family.md`](../../../docs/sleic_board_family.md) —
  what Bike Race shares with IO Moon and where the two diverge: the same PACS
  peripheral base `0xA0000` and a byte-identical timer-0 setup (`0xE003` /
  `0x6276` → 99.18 Hz), against different graphics-ROM mapping, a different
  YM3812 A0 arrangement (Bike Race alternates A0 on one address; IO Moon uses two)
  and a different OKI `/OKCS` bit (PCS0 bit 4 here, bit 5 on IO Moon). The
  per-machine memory maps and the I8039 rasterizer analysis live in the
  `SLEIC3` blocks of `src/wpc/sleic.c` in the PinMAME tree.
- [`../../../manuals/`](../../../manuals/) — the 1992 Spanish service manual with
  parts list and schematics, which supplies the physical switch and coil names.

## Relationship to IO Moon

Bike Race's 80188 `PACS` peripheral block (`0xA0000`) and Timer0 configuration are
byte-identical to IO Moon's, and its DMD composer is the same routine family as IO
Moon's annotated `dmd_frame_load`. The two differ in sound-port details (YM3812 A0
handling, OKI strobe bit) and in NVRAM repair policy. See
[`../../../docs/sleic_board_family.md`](../../../docs/sleic_board_family.md).
