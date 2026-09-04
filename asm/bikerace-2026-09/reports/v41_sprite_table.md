# Why Bike Race V4.1 draws garbage: ROM 06 does not match ROM 04

`bikerac3`, the V4.1 set, used to be registered `GAME_NOT_WORKING` in PinMAME: it
booted and ran but rendered unreadable artwork. This is the evidence for what
caused that, established from the cross-verified disassemblies in this directory
and from captured DMD frames.

**It is resolved.** The V4.1 ROM 06 in circulation, CRC `ad48a30a`, is a bad
dump; the driver now inherits `bkcpu06` from the parent set and `bikerac3` carries
flag `0`. The bad image is archived as `bk06.baddump.bin` in
[`../../../roms/related-machines/bike-race/v4.1/`](../../../roms/related-machines/bike-race/v4.1/).

**The short version.** ROM 04 (the 80188 code) reaches the sprite/character
table through far pointers held in its own code segment. Those pointers are
byte-identical to the 1992 set's. The 1992 ROM 06 holds a well-formed sprite
record at each of the addresses they name; **the V4.1 ROM 06 holds none.** The
same code reading the same addresses therefore finds no sprite and draws
garbage. Substituting the 1992 ROM 06 — or just its first `0x1104` bytes —
makes the V4.1 set render correctly.

The fault is confined to `bk06.bin[0x0000:0x1104]`, 4356 bytes. That region
contains **no artwork that is not already in the 1992 chip** — it is that chip's
own bytes with 0x200-aligned blocks taken from the wrong place. ROMs 03, 04 and
07 of the set are sound.

## The sprite record format

Both graphics ROMs store sprites as a 6-byte header followed by three bit
planes:

```
  W (word)   sprite width in pixels
  1 (word)   constant
  H (word)   sprite height in pixels
  then ceil(W/8) * H bytes each of plane 0, plane 1 and the mask
```

Plane 0 and plane 1 give the four grey levels; the mask is the pass-all/pass-none
plane, the same three-plane arrangement IO Moon uses
([`../../../docs/dmd_graphics.md`](../../../docs/dmd_graphics.md)). The 1992 ROM 06's
first record, at offset `0x0000`, reads:

```
  08 00 01 00 08 00                          W=8, H=8
  00 18 24 24 24 24 18 00                    plane 0
  00 18 24 24 24 24 18 00                    plane 1
  C3 81 81 81 81 81 81 C3                    mask
```

## The pointers are identical, the data is not

Scanning both code ROMs for every 4-byte far pointer whose segment is `0x2000`
(MCS1, where ROM 06 is mapped) finds **24 pointer slots in each, holding the
same 20 distinct offsets**. Slot by slot, in listing order, every value matches:

| ROM 04 slot (parent) | ROM 04 slot (V4.1) | offset into ROM 06 |
|---|---|---|
| `F0B0B` | `F0AC8` | `0x0000` |
| `F0E1A` | `F0DD7` | `0x012C` |
| `F08DA`, `F09C4` | `F0897`, `F0981` | `0x014A` |
| `F08DE` | `F089B` | `0x03A2` |
| `F08E2` | `F089F` | `0x05FA` |
| `F0A45` | `F0A02` | `0x0636` |
| `F0A49` | `F0A06` | `0x0BD6` |
| … 13 more, all equal … | | `0x1206` … `0xBBFC` |

Where a slot moved at all it moved because the code around it moved — most sit
`0x43` lower in V4.1, a few at the same address, one at `-0x3` and one at
`+0x22`. What matters is the right-hand column: not one pointer *value* changed.
The same holds for segment `0x4000`/`0x5000` (ROM 05, MCS2), 39 and 105 slots
respectively with the same targets in both, and for `0x6000`/`0x7000` (the DMD
buffer). **V4.1 fetches its artwork from exactly the addresses the 1992 set
does.**

Walking the record chain from `0x0000` in each ROM 06:

| | records before the chain breaks |
|---|---|
| `bkcpu06` (1992) | **12** — eleven 8×8 sprites on a `0x1E` stride at `0x0000`…`0x012C`, then an 18×18 at `0x014A` |
| `bk06` (V4.1) | **0** — the header at `0x0000` is `01 00 12 00 00 3C`, which is not a record |

Note where the parent's chain lands: `0x012C` and `0x014A` are the eleventh and
twelfth records, and they are two of the five addresses ROM 04 points at. The
chain and the pointers agree exactly. In V4.1 they agree about nothing —
scanning the whole chip for well-formed headers finds **32 in `bkcpu06`, 19 in
`bk06`**, at different offsets, and in both ROMs every one of them lies inside
`0x0000-0x1103`. That 4356-byte block is the entire sprite table, and V4.1's
copy of it is a different table.

## The substitution test

Four headless runs of 1200 frames each, DMD frames captured at every submit
(`SLEIC_DMD_DUMP`, 5131 frames per run), counting distinct frames:

| ROM 06 used with V4.1's ROM 03/04/07 | distinct frames | result |
|---|---|---|
| `bkcpu06` (1992) — none | 8 | *(this is the `bikerace` parent, for reference)* |
| `bk06` (V4.1, as dumped) | **2** | one garbage screen, then blank for the remaining 5107 frames |
| `bkcpu06` (1992) whole chip | **7** | clean: "SLEIC PRESENTA / SU NUEVO PINBALL", then "FALTAN n BOLAS" |
| `bk06` with only `0x0000-0x1103` replaced by `bkcpu06`'s | **7** | clean — **5131 of 5131 frames byte-identical to the row above** |

The last two rows differing in not one frame out of 5131 is the point: the other
124 KB of V4.1's own ROM 06 is fine and is being used. Only the sprite table is
wrong.

The 80188 is not hung in the failing run -- it submits all 5131 frames, so the
INT0 blit pipeline is alive throughout. It draws one garbage screen and then
5107 blank ones, because every sprite lookup after that returns nothing. The
repaired run blanks only 257 frames and changes content 12 times, which is
ordinary attract behaviour.

## What this rules out

- **A missing chip.** The V4.1 16-bit board carries exactly three 27C010
  positions and all three are populated
  ([`../../../docs/bikerace_boards.md`](../../../docs/bikerace_boards.md)), so the
  seven-chip complement PinMAME expects is the whole machine.
- **A different memory map.** The 29-entry peripheral-control table ROM 04 writes
  at boot — read from file offset `0x50` and applied by the `LODSW`/`OUT DX,AX`
  loop at `E0018` — is byte-identical in the two ROMs, `MMCS 0x01FF`, `PACS
  0xA03C`, `MPCS 0xC0FC` included. Both decode ROM 06 at MCS1 `0x20000` and ROM
  05 at MCS2 `0x40000`.
- **Different interrupt wiring.** The 255-byte IVT image ROM 04 copies from
  `E000:00C4` to physical 0 is also byte-identical: NMI `E000:0272`, timer 0
  `E000:0325`, INT0 `E000:0439`, every other vector the same filler.
- **A driver bug.** V4.1's own code renders correctly under this driver the
  moment it is given a sprite table in the format it reads.

## `bk06` contains no new artwork

The differing bytes are not a new sprite table. Classifying every byte of
`bk06[0x0000:0x1200]` as either the 1992 chip's byte at the same address, or its
byte 0x200 further on, leaves almost nothing over:

| range in `bk06` | bytes | origin in `bkcpu06` |
|---|---:|---|
| `0x0000-0x002D` | 46 | displaced **+0x200** |
| `0x002E-0x002F` | **2** | **matches neither** |
| `0x0030-0x00FF` | 208 | same address |
| `0x0100-0x01FF` | 256 | displaced **+0x200** |
| `0x0200-0x03FF` | 512 | same address |
| `0x0400-0x05FF` | 512 | displaced **+0x200** |
| `0x0600-0x07FF` | 512 | same address |
| `0x0800-0x09FF` | 512 | displaced **+0x200** |
| `0x0A00-0x0BFF` | 512 | same address |
| `0x0C00-0x0DFF` | 512 | displaced **+0x200** |
| `0x0E00-0x0FFF` | 512 | same address |
| `0x1000-0x1104` | 261 | displaced **+0x200** |
| `0x1105-0x11FF` | 251 | same address |

**2099 bytes displaced, 2507 correct, 2 bytes unaccounted for.** Every run is
exact, not approximate, and the `+0x200` runs are verified against the 1992 chip
directly rather than inferred — for instance `bk06[0x0400:0x0600]` is
byte-for-byte `bkcpu06[0x0600:0x0800]`, which also makes it byte-for-byte
`bk06[0x0600:0x0800]`, a duplication `bkcpu06` does not have.

That is what settles the question of whether this is a genuine V4.1 revision. A
revised sprite table would contain revised sprites. This one contains **two bytes**
that are not already in the 1992 chip, at `0x002E-0x002F`. Everything else is
recycled, and the recycling is at a 0x200 page granularity that no build tool
produces.

## Traced at runtime: the exact byte, and the exact instruction

Instrumenting the driver's ROM 06 window with a logging read handler and running
both sets headless for 400 frames settles the mechanism without inference. The
two traces are identical for their first 120 reads -- both fetch the 18x18 record
at `0x20366`, byte for byte -- and then diverge on one read:

```
        bikerace (works)                bikerac3 (V4.1)
  2001E  08  pc=F01DC             2001E  18  pc=F0199
  2001F  00  pc=F01DC             2001F  06  pc=F0199
  20020  01  pc=F01E4             20020  26  pc=F01A1
  20021  00  pc=F01E4             20021  26  pc=F01A1
  20022  08  pc=F01EC             20022  3C  pc=F01A9
  20023  00  pc=F01EC             20023  3C  pc=F01A9
```

Same code, same address, different byte. The parent reads
`08 00 01 00 08 00` -- an 8x8 record -- and draws it. V4.1 reads
`18 06 26 26 3C 3C`, i.e. a width of `0x0618` = 1560 pixels, and runs away: 3514
reads reaching `0x20D5F` against the parent's 180 reaching `0x203A1`.

`0x1E` is the second record of the table, and `bk06[0x001E]` is
`bkcpu06[0x021E]` -- the +0x200 displacement, confirmed at the point of use.

## No arrangement of the given ROMs works

Three driver-side alternatives were built and run, 600 frames each, counting
distinct DMD frames (the set as dumped gives 2; a working set gives 7):

| candidate loaded in the ROM 06 slot | distinct frames | result |
|---|---:|---|
| `bkcpu05` -- i.e. the 05/06 order swapped for this set | 2 | no change |
| `bk06` rotated so chip offset `0x200` lands at `0x20000` | 8 | garbage, in more variety |
| `bk06` rotated the other way | 2 | no change |

The emulation is reading the byte the file contains. No mapping, ordering or
offset can turn `18 06 26 26` into a sprite header, so nothing on the driver side
can make this ROM set render.

## What it is *not*, and what the owner's machine settles

It is **not** a stuck address line, which an earlier reading of this suggested and
which the block map rules out. `A9` held permanently high would displace every
0x200 block whose address has bit 9 clear; `0x0030-0x00FF` and `0x1105-0x11FF`
have bit 9 clear and are *correct*, and the boundary at `0x1104` falls in the
middle of a 0x200 block, where no address line can change behaviour. It is also
not a uniform shift, since the intervening blocks are right.

**The machine this set came from runs correctly**, which its owner confirms. That
is what closes the question the bytes could not. For the machine to work, the
byte its 80188 reads at flat `0x2001E` must be `0x08`; the file says `0x18`.
Both cannot be true of the same chip, so the file is not what the chip holds:
**the read is at fault, and the physical ROM 06 is fine.**

It also explains why the damage stops after 4 KB rather than following any
address line: a marginal contact or a reader that fetched the opening pages twice
would corrupt the beginning of a read and then settle, which is exactly the shape
here.

## The other graphics ROM, and the lineage

Bike Race carries **two** graphics ROMs -- ROM 05 at MCS2 `0x40000` and ROM 06 at
MCS1 `0x20000` -- the same count as IO Moon (chip 01's upper half and chip 02).
ROM 04 is code; the on-screen text lives there, but as font indices, not bitmaps.

ROM 05 is the larger sprite bank: **133 well-formed records against ROM 06's 32.**
And it is **byte-identical across every known Bike Race set**, CRC `072ce879` in
the 1992 parent, in `bikerac2` and in V4.1.

That matters three ways.

**The lineage never touches the graphics ROMs.** `bikerac2` is a genuinely
different code revision -- `04` and `07` both rebuilt -- and it leaves *both*
graphics ROMs alone. V4.1 rebuilds `04` and `07` again and tweaks `03` by 229
bytes. A revision that changed ROM 06 and nothing else about the artwork would be
the sole exception in the family.

**The same dump session read ROM 05 perfectly.** 128 KB byte-for-byte correct,
and applying the page-duplication test to it finds **zero** duplicated pages in
its first 8 KB where `bk06` has three. Same machine, same reader, same sitting:
the fault is one chip's read, not the setup.

**The surviving records line up exactly with the correctly-read bytes.** This is
the clincher. Of the 32 records in the 1992 ROM 06:

| | count | all inside a... |
|---|---:|---|
| survived into `bk06` | **15** | correctly-read window |
| lost from `bk06` | **17** | mis-read window |
| anomalies | **0** | — |

Not one record survives that sits in a mis-read page, and not one is lost that
sits in a good one. So `bk06`'s table is not a different table with 19 records --
it is the 1992 table with exactly the records that fell in the damaged pages
knocked out, and exactly the records in the intact pages preserved. The first
seven survivors, at `0x3C` through `0xF0`, are precisely the run that falls in
the correctly-read `0x0030-0x00FF`.

Taken with the owner's machine working, that makes the prediction a good deal
firmer than "a valid table would fix it": **a clean re-read of ROM 06 should come
back as `bkcpu06`, CRC `9db436d4`.**

## How to check and re-read

The file condemns itself without reference to any other ROM. Three of its 0x200
pages are simply the previous page again:

```
  bk06[0x0400:0x0600] == bk06[0x0600:0x0800]
  bk06[0x0800:0x0A00] == bk06[0x0A00:0x0C00]
  bk06[0x0C00:0x0E00] == bk06[0x0E00:0x1000]
```

A sprite table on a 0x1E record stride cannot look like that, and `bkcpu06` does
not.

So: **re-read ROM 06, and check offset `0x001E` first.** It must be
`08 00 01 00 08 00`; anything else and the read went wrong again. Re-seat the
chip, and confirm the reader is set to a 27C010.

## What the driver does in the meantime

`bikerac3` now inherits `bkcpu06.bin` from the parent and is a **three-chip
clone** -- `bk03`, `bk04`, `bk07` -- with flag `0`. It boots, runs attract, takes
coins and plays, and its DMD output matches the substitution run frame for frame.

That inheritance rests on the evidence above, **not on a dump**: no good V4.1 ROM
06 exists. The expectation is CRC `9db436d4`, and it is an expectation. If a
clean re-read ever differs, the `bkcpu06.bin` line in the `bikerac3` ROM block and
`bk06.bin` in the ROM archive are what change.
