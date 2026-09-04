# The SLEIC Board Family

IO Moon is not a one-off design. SLEIC (*Creaciones e Investigaciones
Electrónicas, S.L.*, Alcobendas, Madrid) reused the same two-CPU architecture
across its pinball machines, and much of what this repository documents about IO
Moon was only pinned down by cross-checking against its siblings — in particular
Bike Race, whose display coprocessor is dumped where IO Moon's is not.

This page is the map of that family: which machines exist here, what they share,
where they diverge, and what is still missing.

## The machines

| Machine | Year | PinMAME family | ROMs archived here | Dump status |
|---------|------|----------------|--------------------|-------------|
| Sleic Pin-Ball | 1993 | `SLEIC1` | [`roms/related-machines/sleic-pin-ball/`](../roms/related-machines/sleic-pin-ball/) | complete (4) |
| IO Moon | 1996 | `SLEIC2` | [`roms/1.3 IPDB latest/`](../roms/1.3%20IPDB%20latest/), [`roms/1.3 Early version/`](../roms/1.3%20Early%20version/) | complete (5), two versions |
| Bike Race | 1992 | `SLEIC3` | [`roms/related-machines/bike-race/`](../roms/related-machines/bike-race/), [`.../v4.1/`](../roms/related-machines/bike-race/v4.1/) | complete (7), plus a six-chip V4.1 set |
| Doña Elvira 2 (SLEIC-Petaco) | 1996 | — | [`roms/related-machines/dona-elvira-2/`](../roms/related-machines/dona-elvira-2/) | **partial — Z80 I/O ROM only** |

The PinMAME family numbers are driver-registration order, not chronology: Bike
Race (`SLEIC3`) is the oldest machine of the three that PinMAME knows about.
No PinMAME driver for Doña Elvira 2 is known to us — one ROM is not enough to run
it in any case.

Bike Race is the only sibling whose boards are photographed here:
[`bikerace_boards.md`](bikerace_boards.md) has the 16-bit and Z80 boards at full
resolution, and the IC complement they establish.

## The shared architecture

Every machine here is built the same way:

| Role | Device | Notes |
|------|--------|-------|
| Game CPU | Intel 80188 | Game rules, DMD frame composition, both sound chips |
| I/O CPU | Zilog Z80 | Switch matrix scan, lamps, coils; talks to the 80188 over the J1 byte port |
| Display coprocessor | Intel 8039 (`SLEIC1`, `SLEIC3`) or PIC16C57 (IO Moon) | Free-running rasterizer over the staged frame buffer; sends the 80188 nothing |
| FM music | Yamaha YM3812 (OPL2) | Driven by the 80188; IO Moon pairs it with a YM3014B DAC (IC61) |
| Speech / FX | OKI MSM6376 | ADPCM samples in dedicated ROMs |
| NVRAM | EEPROM (28C64A on IO Moon and Bike Race) | Config + audits, validated against a ROM template at boot — Bike Race's is `IC20`, a Microchip `28C64A-20/P` ([`bikerace_boards.md`](bikerace_boards.md)) |

The 80188 peripheral block sits at `0xA0000` (`PACS`) on IO Moon and Bike Race
alike — byte-identical configuration — as does the timer-0 setup that yields the
99.18 Hz tick. See [`80188_config.md`](80188_config.md).

## Z80 lineage — where Doña Elvira 2 fits

The four dumped Z80 I/O ROMs fall into two clearly separated generations. Counting
*distinct 16-byte code windows* shared between each pair (trailing pad bytes
removed, near-constant windows excluded so that runs of table data don't inflate
the count):

| Pair | Shared 16-byte windows | % of the smaller ROM |
|------|-----------------------|----------------------|
| IO Moon ↔ Bike Race | 3,475 | **26.0 %** |
| Doña Elvira 2 ↔ Bike Race | 2,396 | **17.9 %** |
| Doña Elvira 2 ↔ IO Moon | 2,374 | **15.3 %** |
| Bike Race ↔ Sleic Pin-Ball | 97 | 1.4 % |
| Doña Elvira 2 ↔ Sleic Pin-Ball | 31 | 0.4 % |
| IO Moon ↔ Sleic Pin-Ball | 21 | 0.3 % |

Two orders of magnitude separate the three later machines from Sleic Pin-Ball.
**Doña Elvira 2's I/O firmware is a sibling of the IO Moon and Bike Race code**,
i.e. it runs the same later Z80 board generation (IO Moon's is the `011-030A`,
inventoried in [`board_011-030A_ics.md`](board_011-030A_ics.md)), and shares
essentially nothing with the 1993 Sleic Pin-Ball I/O code.

Code volume agrees with that grouping:

| ROM | Chip | Bytes used | Pad |
|-----|------|-----------:|-----|
| Sleic Pin-Ball `sp04-1_1.rom` | 27C256 | 8,763 | `0x00` |
| Bike Race `bkio07.bin` | 27C256 | 18,635 | `0xFF` |
| Doña Elvira 2 `ST27C256-z80.bin` | 27C256 | 18,678 | `0xFF` |
| IO Moon `V1 3_05.bin` | 27C256 | 20,437 | `0xFF` |

Reset/vector blocks share one shape across all four — `NOP NOP DI` fill, three
`JP` entries at `0x09`/`0x0D`/`0x11`, and a `JP` at `0x38` for the mode-1
interrupt — so the vector layout is *not* what separates the generations; the body
code is. IO Moon is the one that puts `IM 1` (`ED 56`) in the very first
instruction block and vectors to `0x0400`, while Sleic Pin-Ball, Bike Race and
Doña Elvira 2 all vector to `0x0100`/`0x02B3`.

Reproduce the table with:

```python
import itertools
files = {
    'de2':      'roms/related-machines/dona-elvira-2/ST27C256-z80.bin',
    'iomoon':   'roms/1.3 IPDB latest/V1 3_05.bin',
    'bikerace': 'roms/related-machines/bike-race/bkio07.bin',
    'sleicpin': 'roms/related-machines/sleic-pin-ball/sp04-1_1.rom',
}
sets = {}
for k, p in files.items():
    d = open(p, 'rb').read().rstrip(b'\xff').rstrip(b'\x00')
    sets[k] = {d[i:i+16] for i in range(len(d) - 16) if len(set(d[i:i+16])) > 2}
for a, b in itertools.combinations(files, 2):
    n = len(sets[a] & sets[b])
    print(f'{a:9s} {b:9s} {n:6d}  {100*n/min(len(sets[a]), len(sets[b])):.1f}%')
```

## Where the machines diverge

**Display coprocessor.** Sleic Pin-Ball and Bike Race use an Intel 8039; IO Moon
uses a PIC16C57. All three ROMs are now available — `sp01`, `bkdsp01`, and the
IO Moon PIC recovered from its code-protected part
([`chips_to_dump.md`](chips_to_dump.md),
[`../asm/pic16c57_annotated.asm`](../asm/pic16c57_annotated.asm)) — and all three
are the same kind of program: a pure one-way rasterizer that reads nothing back
from the 80188. The two 8039 programs share only their first 8 bytes and are 133
bytes (`sp01`) and 117 bytes (`bkdsp01`) in an 8 KB part; Bike Race's disables
interrupts immediately and samples only its T1 panel-sync pin. IO Moon's is 150
words, samples only the external dot clock on T0CKI, and its one asymmetry — a
200:30 per-plane row-hold ratio — is what makes buffer plane 0 the MSB of the
4-level grey scale.

**YM3812 register/data select.** The same chip, wired three different ways:

| Machine | How the A0 line is driven |
|---------|---------------------------|
| IO Moon | two addresses — `0xA0280` (index) and `0xA0281` (data) |
| Sleic Pin-Ball | single address `0xA0280`; A0 = `0xA0000` (PCS0) **bit 1** |
| Bike Race | single address `0xA0280`; A0 alternates per write |

See [`ym3812_pinmame_precedents.md`](ym3812_pinmame_precedents.md) and
[`../research/sleicpin_disasm/sleicpin_sound.md`](../research/sleicpin_disasm/sleicpin_sound.md).

**OKI MSM6376 strobe.** Phrase number is latched at `0xA0300` (PCS6) on all of
them; the `/OKCS` trigger is PCS0 **bit 5** on IO Moon and **bit 4** on Bike Race
and Sleic Pin-Ball.

**Blank-NVRAM policy.** Sleic Pin-Ball repairs a blank NVRAM automatically and
silently at boot, so an emulator needs no factory image for it. Bike Race gates
the same repair behind an operator "ESTABLECIENDO VALORES DE FABRICA / PULSE
START" screen, which is why its PinMAME driver embeds a factory NVRAM image. See
[`../research/bikerace_disasm/bikerace_nvram.md`](../research/bikerace_disasm/bikerace_nvram.md).

**Graphics ROM mapping.** Bike Race maps two 128 KB graphics ROMs at MCS1
`0x20000` (`bkcpu06`) and MCS2 `0x40000` (`bkcpu05`), with work RAM at MCS0 and the
DMD frame buffer at MCS3 `0x60000`. IO Moon instead pairs a single 512 KB code
ROM with a 512 KB graphics ROM that is too big to map flat: it is **banked** one
64 KB page at a time into MCS2 `0x60000` by PCS0 bits 0–2, and its own MCS3
`0x70000` holds the DMD staging buffer
([`hardware_architecture.md`](hardware_architecture.md)).

## What is still missing

- **The two PALs on the IO Moon boards** — IC7 (80188 chip-select glue) and IC8
  (Z80 decode), both with the security fuse blown. Neither blocks emulation; see
  [`chips_to_dump.md`](chips_to_dump.md) for exactly what each would settle.
- **Doña Elvira 2's 80188, graphics, sound and display ROMs** — only the Z80 I/O
  ROM exists here. Without the 80188 code the machine can be neither emulated nor
  meaningfully documented beyond its I/O layer.
- **Doña Elvira 2 disassembly** — not started. Given the 15–18 % code overlap with
  IO Moon and Bike Race, the documented switch/lamp/coil port maps
  ([`z80_io_ports.md`](z80_io_ports.md),
  [`bikerace_switch_map.md`](bikerace_switch_map.md)) should transfer to it with
  little work, and would be the cheapest way to learn what that machine's playfield
  looks like electrically.
