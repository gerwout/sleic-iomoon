# ROM — Doña Elvira 2 (SLEIC-Petaco, 1996)

A **partial** dump of *Doña Elvira 2*, a rare SLEIC-Petaco machine from 1996 — the
same year as IO Moon. Only the **game CPU ROM** is dumped. It was read off the Z80
board's 27C256 EPROM (an ST27C256, hence the filename). No public dump of this
machine's ROMs was known to us when this image was archived, so unlike the IO Moon
set it cannot be cross-checked against an independent source.

The machine's service manual is archived at
[`../../../manuals/`](../../../manuals/) and is the source for the board
complement below.

## Files

| Filename | Size | MD5 Checksum | CPU | Content |
|----------|------|--------------|-----|---------|
| `ST27C256-z80.bin` | 32,768 bytes (32 KB) | `358bd508dd8232bbfe9d8d14465015d3` | Z80 | Game CPU ROM — 18,678 bytes used, remainder `0xFF` |

## The board complement, and what is missing

The service manual's element table (page 60) lists the machine's complete
electronics, and it is not the two-CPU shape IO Moon and Bike Race have. There is
**no 16-bit board**: the *C.P.U. 8 BITS* (`011-030`) is the game CPU, described in
§7.2.1 as running all game functions, the playfield and cabinet contacts, the lamps
and the coils. Its principal components are IC1 a Z80A-6, IC5 a 27C256 labelled
`DONA ELVIRA 2 V 1.1`, and the SW40 microswitch bank — so `ST27C256-z80.bin` is
this machine's main program, not a subordinate I/O layer.

That leaves two boards carrying undumped code:

| Board | Clave | Undumped parts |
|-------|-------|----------------|
| C.P.U. sonido general | `011-065` | IC5 `27C10` (`ELVSONO`) and IC42–IC45 `27C40` (`ELVSON1`–`ELVSON4`), the manual's own shorthand for the part numbers. A second Z80 (IC1, Z80B-6) drives an OKI 6376 at IC41. |
| Placa display y leds | `011-064` | three 6331 bipolar PROMs at IC2/IC5/IC8. The display is 7-segment (HDSP 3901 / HDSP H101) — there is no DMD and no display coprocessor. |

So a complete set is this ROM plus five sound EPROMs and three display PROMs.
Without the sound images the machine cannot be emulated with audio; the game code
itself is here in full.

## Identification

The ROM self-identifies in plain ASCII:

```
SLEIC-PETACO DONA ELVIRA 2
(C) SLEIC 1996
AV.VALDELAPARRA, 3. POLIGONO INDUSTRIAL
ALCOBENDAS. 28100 MADRID
TEL.:073416619796  FAX:073416616975
```

That is SLEIC's Alcobendas (Madrid) address, the same manufacturer as IO Moon.

## It is the same Z80 board generation as IO Moon and Bike Race

Comparing distinct 16-byte code windows across the four dumped SLEIC Z80 ROMs
(`0xFF`/`0x00` padding trimmed, near-constant windows excluded):

| Pair | Shared 16-byte windows | % of the smaller ROM |
|------|-----------------------|----------------------|
| Doña Elvira 2 ↔ Bike Race (`bkio07`) | 2,396 | **17.9 %** |
| Doña Elvira 2 ↔ IO Moon (`V1 3_05`) | 2,374 | **15.3 %** |
| Doña Elvira 2 ↔ Sleic Pin-Ball (`sp04`) | 31 | 0.4 % |

So Doña Elvira 2's firmware is a sibling of the IO Moon / Bike Race Z80 code and
shares essentially nothing with the older Sleic Pin-Ball Z80 code. Its overall size
profile agrees: 18,678 bytes used, against 18,635 for Bike Race and 20,437 for IO
Moon, versus 8,763 for Sleic Pin-Ball.

The board reference says the same thing. `011-030` is the drawing family of IO
Moon's Z80 board `011-030A`, and the service manual's schematic sheet `011-030-01`
(REV 3, August 10 1995) carries the same IC8 PAL16L8 pin assignment as the IO Moon
copy of that sheet
([`../../../docs/chips_to_dump.md`](../../../docs/chips_to_dump.md)). The two
machines put the same board to different work: on IO Moon it answers to an 80188,
here it is the game CPU.

Its reset/vector block is the SLEIC standard shape (`NOP NOP DI` fill, three `JP`
entries at `0x09`/`0x0D`/`0x11`, `JP` at `0x38` for the mode-1 interrupt) — shared
by Sleic Pin-Ball too, so the vector layout alone is not the discriminator; the
body code is:

| ROM | `JP` at `0x09`/`0x0D`/`0x11` | `RST 38h` handler |
|-----|------------------------------|-------------------|
| Doña Elvira 2 | `0x02B3` | `0x0100` |
| Bike Race `bkio07` | `0x0100` | `0x061F` |
| Sleic Pin-Ball `sp04` | `0x0100` | `0x03CA` |

IO Moon's `V1 3_05` differs at the very start (`ED 56` = `IM 1` in the first
instruction block, vectors to `0x0400`), which is why it is the least similar of
the three siblings while still clearly belonging to the family.

Analysis basis for the wider picture:
[`../../../docs/sleic_board_family.md`](../../../docs/sleic_board_family.md).

## Status

No disassembly or functional analysis of this ROM has been done yet. The obvious
next step is a `z80dasm` pass and a comparison of its switch-matrix scan and
lamp/coil ports against the documented IO Moon
([`../../../docs/z80_io_ports.md`](../../../docs/z80_io_ports.md)) and Bike Race
([`../../../docs/bikerace_switch_map.md`](../../../docs/bikerace_switch_map.md))
maps.
