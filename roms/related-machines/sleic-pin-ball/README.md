# ROM Set — Sleic Pin-Ball (SLEIC, 1994)

The Sleic Pin-Ball ROM set — PinMAME's `SLEIC1` family, the oldest of the SLEIC
machines documented here. Same broad architecture as IO Moon and Bike Race (80188
game CPU + Z80 I/O CPU + I8039 display coprocessor + YM3812 + OKI MSM6376), but the
firmware is a distinctly earlier generation: its Z80 code shares almost nothing
with the IO Moon / Bike Race / Doña Elvira 2 Z80 lineage.

## Files

| Filename | Size | MD5 Checksum | CPU / device | Content |
|----------|------|--------------|--------------|---------|
| `sp01-1_1.rom` | 8,192 bytes (8 KB) | `6770d21b5691e7951cdf305aa9f0dd41` | I8039 | Display coprocessor (DMD rasterizer) — 133 bytes of program, rest `0x00` |
| `sp02-1_1.rom` | 524,288 bytes (512 KB) | `22f3d40c73d903033c12b9665cbea662` | OKI MSM6376 | ADPCM sample ROM (`REGION_USER1`) |
| `sp03-1_1.rom` | 131,072 bytes (128 KB) | `50c49844fe28d1d8b3477eb35cc8e133` | 80188 | Game + sound code, base `0xE0000` |
| `sp04-1_1.rom` | 32,768 bytes (32 KB) | `320903cb4961a0a9469182dc532fa294` | Z80 | I/O CPU ROM (switch matrix, lamps, coils) — 8,763 bytes used |

## What this set is used for in this repository

- [`../../../asm/sleicpin_80188_ndisasm.asm`](../../../asm/sleicpin_80188_ndisasm.asm) —
  full raw disassembly of `sp03`.
- [`../../../asm/sleicpin_80188_hlil.txt`](../../../asm/sleicpin_80188_hlil.txt) —
  HLIL (decompiler) export of `sp03`, 201 functions, base `0xE0000`.
- [`../../../asm/sleicpin_z80dasm.asm`](../../../asm/sleicpin_z80dasm.asm) —
  full raw disassembly of `sp04`.
- [`../../../research/sleicpin_disasm/`](../../../research/sleicpin_disasm/) —
  coil map, switch map, input-switch analysis, EEPROM/NVRAM findings, sound
  (YM3812 + OKI) wiring, and string dumps from `sp01`/`sp02`.
- [`../../../manuals/`](../../../manuals/) — the 1994 Spanish service manual
  (no schematics), source of the physical contact and coil names.

## Notable differences from IO Moon and Bike Race

- **Sound port model.** The 80188 drives both sound chips. The YM3812 register/data
  select is `0xA0000` (PCS0) **bit 1**, with both register and data written to the
  single address `0xA0280` — IO Moon instead uses two addresses (`0x280`/`0x281`)
  and Bike Race simply alternates A0 per write.
- **NVRAM policy.** Sleic Pin-Ball repairs a blank NVRAM **automatically and
  silently at boot** (`F000:818D`), so no factory image needs to be supplied to
  it. Bike Race gates the same repair behind an operator "PULSE START" screen.
- **Z80 lineage.** Its Z80 firmware is essentially unrelated to the later
  SLEIC Z80 board code — see
  [`../../../docs/sleic_board_family.md`](../../../docs/sleic_board_family.md).
