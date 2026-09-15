# ROMs — Doña Elvira 2 (SLEIC-Petaco, 1996)

All six EPROMs of *Doña Elvira 2*, a rare SLEIC-Petaco machine from 1996 — the same
year as IO Moon. Five are complete; `040V1U04.SOM` is missing 61,440 bytes and needs
a re-read. No public dump of this machine was known to us when these images were
archived, so unlike the IO Moon set they cannot be cross-checked against an
independent source.

The machine's service manual is archived at [`../../../manuals/`](../../../manuals/)
and is the source for the board and component references below.

## Files

Named as the dumper supplied them: the numeric prefix is the EPROM type (`010` =
27C010, `040` = 27C040, `256` = 27C256), `v1` the version, `uNN` a position in the
dumper's own sequence — **not** the board's IC number — and the extension the board
(`.som` = *sonido*, `.pro` = *programa*).

| File | Size | MD5 | Board / IC | Manual label | Content |
|---|---|---|---|---|---|
| `256v1u06.pro` | 32,768 | `358bd508dd8232bbfe9d8d14465015d3` | C.P.U. 8 bits `011-030`, IC5 | `DONA ELVIRA 2 V 1.1` | Game CPU program (Z80A-6). 18,678 bytes used, remainder `0xFF` |
| `010v1u01.som` | 131,072 | `1afd7bf6944044f04e07990599c45452` | C.P.U. sonido `011-065`, IC5 | `ELVSONO` | Sound CPU program (Z80B-6). 1,480 bytes used (`0x0000`-`0x05C7`), remainder `0xFF` |
| `040V1U02.SOM` | 524,288 | `e6a6c7156b55afc42f0978f3ed936572` | `011-065`, IC42 | `ELVSON1` | OKI samples, chip 0 — carries the phrase table |
| `040V1U03.SOM` | 524,288 | `17aa046c89d78aaf1e58f4161c744af0` | `011-065`, IC43 | `ELVSON2` | OKI samples, chip 1 |
| `040V1U04.SOM` | **462,848** | `a0ed355c16435c5443b680d912585e00` | `011-065`, IC44 | `ELVSON3` | OKI samples, chip 2 — **incomplete, see below** |
| `040V1U05.SOM` | 524,288 | `d5d1dee50970b609297f4cc3e8389f47` | `011-065`, IC45 | `ELVSON4` | OKI samples, chip 3. Data to `0x21B52`, remainder `0xFF` |

`256v1u06.pro` is byte-identical to the image previously archived here as
`ST27C256-z80.bin`, which it supersedes.

The IC numbers come from the manual's §7.2.1.1 and §7.2.3.1 component tables.
Which physical IC each sample image was read from is an inference from that
ordering; what the data proves is the order itself (below).

## `040V1U04.SOM` is missing 61,440 bytes from its middle

Not from its end. The dump is short by exactly `0xF000`, and the loss is an interior
hole at chip offset `0x43063`-`0x52062` — OKI address `0x143063`-`0x152062`.
Everything past the hole is present, displaced `0xF000` earlier in the file.

Three independent lines of evidence:

- **The phrase table.** Phrases 60-78 resolve to valid sample starts only at
  *(table address − `0xF000`)*, while phrases 1-56 and 79-80 resolve at their
  literal addresses. Phrase 58's start (`0x149DF0`) and phrase 59's (`0x15126F`)
  fall inside the hole.
- **The chip's tail is intact.** Phrase 78's block chain crosses from `ELVSON3`
  into `ELVSON4` and ends exactly on phrase 79's start; 79 ends exactly on 80's
  start; 80 ends exactly on the last programmed byte. An end-truncated dump cannot
  do that.
- **The loss accounts to the byte.** 28,045 (tail of phrase 57) + 29,823 (all of
  phrase 58) + 3,572 (head of phrase 59) = 61,440 = `0xF000`.

It is **not** stripped erased space:

- `040V1U05.SOM` keeps 386,222 bytes of trailing `0xFF` and `010v1u01.som` keeps
  129,592, so nothing in this delivery strips `0xFF`.
- The longest interior `0xFF` run anywhere in the used sample area of all four
  sample chips is **2 bytes** — the samples are packed end to end, with no padding
  for a dumper to drop.
- The phrase table allocates two sized slots inside the hole. A table does not
  point phrase starts into erased space.

Damage is confined to three of the 68 phrases: **57** loses its last 28,045 bytes
(2% of a 1.15 MB sample), **58 is lost entirely**, **59** loses its first 3,572
bytes (56%). The other 65 are complete.

## The OKI sample set

The four 27C040s form one 2 MB MSM6376 phrase space in the order `ELVSON1`,
`ELVSON2`, `ELVSON3`, `ELVSON4`. The order is established from the data: the phrase
table sits at offset 0 of `ELVSON1`; `ELVSON2` carries an unbroken 128-byte block
grid across its whole 512 KB; and the last phrase ends exactly on the last
programmed byte of `ELVSON4`.

The phrase table occupies `0x000`-`0x1FF` of `ELVSON1` as 128 four-byte entries,
address = `((b0 & 0x3f) << 16) | (b1 << 8) | b2` with `b0` bit 6 set on a live
entry. **68 phrases** are defined, in slots 1-80 (slots 8, 10, 12, 14, 20, 33, 38,
41, 42, 45, 47 and 49 are empty). Samples are chains of blocks, each a length byte
masked to 7 bits with a zero byte terminating, packed contiguously.

The same layout decodes IO Moon's own sound ROMs — 28 phrases, all contiguous, the
last ending exactly on the last programmed byte — which is what the reading above is
checked against.

This machine has **no FM chip**, so its music is streamed ADPCM: phrase 57 alone is
a single 1,154,573-byte sample, about 72 s at 32 kHz. That is why the set needs four
27C040s where IO Moon needs two.

## The board complement

The manual's element table (§7.1) lists the machine's complete electronics, and it is
not the two-CPU shape IO Moon and Bike Race have. There is **no 16-bit board**: the
*C.P.U. 8 BITS* (`011-030`) is the game CPU, described in §7.2.1 as running all game
functions, the playfield and cabinet contacts, the lamps and the coils. Its principal
components are IC1 a Z80A-6 and IC5 the 27C256 above, with the SW10 microswitch bank.

The sound board `011-065` (§7.2.3.1) carries IC1 a Z80B-6, IC41 an OKI 6376 voice
synthesiser, the five EPROMs above, IC60 a TL08x and IC61/IC62 TDA2030 amplifiers.

Still undumped: the three 6331 bipolar PROMs at IC2, IC5 and IC8 on the display board
`011-064` (§7.2.4.1). The display is 7-segment (HDSP 3901 / HDSP H101; the schematic
sheets spell the second part `HDSP H103`) — there is no DMD and no display
coprocessor.

Schematic sheet `011-064-02` (PDF page 124) shows what those three PROMs do. The
board takes five signals from the CPU board over J1, a 10-way ribbon: `SDATA` and
`SCLK`, plus a four-bit `DECA`-`DECD` bus. `SDATA`/`SCLK` clock a character code into
three 74164 serial-in/parallel-out shift registers (IC1, IC4, IC7), whose parallel
outputs drive the five address lines `A0`-`A4` of the 6331 beside each one (IC2, IC5,
IC8); the PROM's `O1`-`O8` then drive the segments.

So each 6331 is a character generator: 32 codes in, an 8-bit segment pattern out.
**The machine's alphabet lives in those three PROMs and nowhere else** — no ROM
already dumped contains it, so without them the segment pattern for a given code
cannot be known. PinMAME records the same arrangement for IDSA, another Spanish
manufacturer of the period, at `src/wpc/idsa.c:67`.

## Identification

The game ROM self-identifies in plain ASCII:

```
SLEIC-PETACO DONA ELVIRA 2
(C) SLEIC 1996
AV.VALDELAPARRA, 3. POLIGONO INDUSTRIAL
ALCOBENDAS. 28100 MADRID
TEL.:073416619796  FAX:073416616975
```

That is SLEIC's Alcobendas (Madrid) address, the same manufacturer as IO Moon.

## Both Z80 ROMs hold valid code

The game CPU ROM has the SLEIC reset block (`NOP NOP DI` fill, `JP 0x02B3` at
`0x09`/`0x0D`/`0x11`, `JP 0x0100` at `0x38`), boots at `0x0100` and dispatches its
state machine through a RAM vector at `(0xC0AF)`, with RAM at `0xC0xx`. Its I/O is
`IN 0x01`-`0x04` and `OUT 0x80`-`0x87` — the same port map as IO Moon's Z80 board.

The sound CPU ROM is complete in 1,480 bytes: `IM 1`, stack at `0x87FF`, RAM at
`0x8000`. Its NMI at `0x66` reads `IN (0x00)` — the command byte from the game CPU —
into `0x800F`; the main loop at `0x04BF` dispatches it, writing the phrase number to
`OUT (0x02)` and then the same byte with bit 7 set, which is the MSM6376 trigger
sequence. Port `0x00` carries data and handshake back to the game CPU, port `0x01`
returns status on bit 1.

## It is the same Z80 board generation as IO Moon and Bike Race

Comparing distinct 16-byte code windows across the four dumped SLEIC Z80 game ROMs
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

The reset/vector block is the SLEIC standard shape, shared by Sleic Pin-Ball too, so
the vector layout alone is not the discriminator; the body code is:

| ROM | `JP` at `0x09`/`0x0D`/`0x11` | `RST 38h` handler |
|-----|------------------------------|-------------------|
| Doña Elvira 2 | `0x02B3` | `0x0100` |
| Bike Race `bkio07` | `0x0100` | `0x061F` |
| Sleic Pin-Ball `sp04` | `0x0100` | `0x03CA` |

IO Moon's `V1 3_05` differs at the very start (`ED 56` = `IM 1` in the first
instruction block, vectors to `0x0400`), which is why it is the least similar of
the three siblings while still clearly belonging to the family. `010v1u01.som`, the
Doña Elvira 2 *sound* CPU, opens with that same `ED 56` shape.

Analysis basis for the wider picture:
[`../../../docs/sleic_board_family.md`](../../../docs/sleic_board_family.md).

## Status

No disassembly or functional analysis of the game ROM has been done beyond the
structural checks above. The obvious next step is a `z80dasm` pass and a comparison
of its switch-matrix scan and lamp/coil ports against the documented IO Moon
([`../../../docs/z80_io_ports.md`](../../../docs/z80_io_ports.md)) and Bike Race
([`../../../docs/bikerace_switch_map.md`](../../../docs/bikerace_switch_map.md))
maps.

Two things would complete the set: a re-read of `ELVSON3` (IC44), and the three
6331 display PROMs.
