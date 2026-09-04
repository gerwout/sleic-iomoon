# ROM Set — Bike Race V4.1

The **six socketed chips of a Bike Race machine running V4.1**, dumped as one set
from one machine: `BK02`–`BK06` off the 16-bit board and `BK07` off the Z80 board.
The two boards this set came out of are photographed in
[`../../../../docs/bikerace_boards.md`](../../../../docs/bikerace_boards.md), and
every chip here wears a `V4.1` sticker in those pictures.

`BK01`, the I8039 display-coprocessor ROM, lives on a third board and is **not**
part of this dump. The parent set's `BK01`
([`../bkdsp01.bin`](../bkdsp01.bin)) is what PinMAME uses for V4.1.

## Files

| Filename | Size | MD5 | CRC32 | CPU / device | Content |
|----------|------|-----|-------|--------------|---------|
| `bk02.bin` | 524,288 bytes (512 KB) | `1bfba7e4db786c400f76e3b94c58f885` | `d67b3883` | OKI MSM6376 | ADPCM sample ROM 1 — **same bytes as the parent set** |
| `bk03.bin` | 524,288 bytes (512 KB) | `8f49bf919392f32fc0366d0ec6c92ada` | `74c10536` | OKI MSM6376 | ADPCM sample ROM 2 |
| `bk04.bin` | 131,072 bytes (128 KB) | `0ef6759ea3e87afd6b883d8052e8b2f3` | `33fd212e` | 80188 | Game + sound code, linear `0xE0000–0xFFFFF` |
| `bk05.bin` | 131,072 bytes (128 KB) | `6367b9028b7470fc6dbad37a229bc761` | `072ce879` | 80188 | Graphics ROM, MCS2 `0x40000` — **same bytes as the parent set** |
| `bk06.bin` | 131,072 bytes (128 KB) | `c42b2e81b987cbe63145eefda647da93` | `ad48a30a` | 80188 | Graphics ROM, MCS1 `0x20000` |
| `bk07.bin` | 32,768 bytes (32 KB) | `244271a47eb206f3c3fc30c1f7d8fb17` | `200ff3fc` | Z80 | I/O CPU ROM (switch matrix, lamps, coils) |

Every one of the six is byte-identical to a chip PinMAME already knows: `bk03`,
`bk04`, `bk06` and `bk07` are the four members of the `bikerac3` clone set, and
`bk02` and `bk05` are the parent `bikerace` set's `bksnd02.bin` and `bkcpu05.bin`.

## What this dump establishes

**That `bk02` and `bk05` really are unchanged in V4.1.** The `bikerac3` set is a
four-chip clone: it lists only the chips that differ and inherits `01`, `02` and
`05` from the parent. Inheritance is an assumption in a clone set — it says
"assume these are the parent's" — and until this dump nothing had checked it for
V4.1, because no complete V4.1 pull existed. A complete six-chip pull off one
machine now confirms two thirds of it directly: `BK02` and `BK05` on a V4.1 board
carry the parent's bytes. `BK01` is still inherited on the assumption alone.

**That V4.1 has no fourth graphics ROM.** The 16-bit board holds exactly three
128 KB positions and they are `BK04`, `BK05` and `BK06`; the next devices along are
the work RAM and the EEPROM. See
[`../../../../docs/bikerace_boards.md`](../../../../docs/bikerace_boards.md).

## Why `bikerac3` is `GAME_NOT_WORKING`: ROM 06 does not match ROM 04

V4.1 boots and runs under PinMAME but draws unreadable artwork. The cause is in
this ROM set, not in the driver, and it is 4356 bytes wide.

`bk04` reaches the sprite/character table through far pointers held in its own
code segment, and **those pointers are byte-identical to the 1992 set's** — all
24 segment-`0x2000` pointer slots hold the same offset as the matching slot in
`bkcpu04`, `0x0000`, `0x012C`, `0x014A`, `0x03A2` and `0x05FA` among them.
`bkcpu06` holds a well-formed sprite record at each of those offsets; **`bk06`
holds none.** Walking the record chain from `0x0000` — a 6-byte header `W, 1, H`
then `ceil(W/8)*H*3` bytes of plane 0, plane 1 and mask — `bkcpu06` yields eleven
8x8 sprites on a `0x1E` stride and then an 18x18 at `0x014A`, landing exactly on
the addresses the code names. `bk06` fails on the very first record. Chip-wide
there are 32 well-formed headers in `bkcpu06` and 19 in `bk06`, and in both they
all lie inside `0x0000-0x1103`: that block is the whole sprite table, and V4.1's
copy of it is a different table.

Substituting `bkcpu06` for `bk06` — or replacing only its first `0x1104` bytes
and leaving the other 124 KB of V4.1's own graphics in place — makes this set
render correctly. Over 1200 headless frames with the DMD captured at every
submit, the two substitutions produce **5131 of 5131 byte-identical frames**,
seven distinct screens instead of two, "SLEIC PRESENTA / SU NUEVO PINBALL" and
"FALTAN n BOLAS" clean. `bk03`, `bk04` and `bk07` are sound.

Three things this rules out, each checked rather than assumed:

- **A missing chip.** The board carries exactly three 27C010 positions and all
  three are populated
  ([`../../../../docs/bikerace_boards.md`](../../../../docs/bikerace_boards.md)).
- **A different memory map.** `bk04`'s 29-entry peripheral-control table at file
  offset `0x50` — `MMCS 0x01FF`, `PACS 0xA03C`, `MPCS 0xC0FC` and the timer and
  DMA setup — is byte-identical to `bkcpu04`'s, so V4.1 decodes ROM 06 at MCS1
  `0x20000` and ROM 05 at MCS2 `0x40000` exactly as the 1992 sets do. So is the
  255-byte interrupt-vector image it copies to physical 0 at boot.
- **A driver bug.** V4.1's own code renders correctly under the same driver the
  moment it is given a sprite table in the format it reads.

The full evidence, with the pointer-slot table and the frame counts, is in
[`../../../../asm/bikerace-2026-09/reports/v41_sprite_table.md`](../../../../asm/bikerace-2026-09/reports/v41_sprite_table.md),
alongside the cross-verified disassemblies of both code ROMs it rests on.

### `bk06` contains no new artwork

The differing 4356 bytes are not a revised sprite table. Classifying every byte
of `bk06[0x0000:0x1200]` as either the 1992 chip's byte at the same address or
its byte 0x200 further on accounts for all but two of them:

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

2099 bytes displaced, 2507 correct, **2 bytes** unaccounted for. Every run is
exact. A revised sprite table would contain revised sprites; this one contains
two bytes that are not already in the 1992 chip, and a 0x200-page granularity no
build tool produces.

**The machine this set came from runs correctly**, which its owner confirms, and
that closes the question the bytes could not. Traced at runtime -- the driver's
ROM 06 window instrumented with a logging read handler -- the two sets read
identically for 120 accesses and then diverge on one: at flat `0x2001E`, the
second record of the table, the 1992 set reads `08 00 01 00 08 00` and draws an
8x8 sprite, while V4.1 reads `18 06 26 26 3C 3C`, a width of `0x0618` = 1560
pixels, and runs away (3514 reads reaching `0x20D5F` against 180 reaching
`0x203A1`). For the machine to work that byte must be `0x08`. The file says
`0x18`. Both cannot be true of the same chip, so **the read is at fault and the
physical ROM 06 is fine.**

That also explains why the damage stops after 4 KB instead of following an
address line: a marginal contact, or a reader that fetched the opening pages
twice, corrupts the start of a read and then settles.

Nothing on the driver side can compensate. Three alternatives were built and run
-- ROM 05 in the 06 slot, and `bk06` rotated `0x200` each way -- and none renders;
the emulation is faithfully reading the byte the file contains.

### Re-reading it

The file condemns itself without reference to any other ROM: three of its 0x200
pages are the previous page again --
`bk06[0x0400:0x0600] == bk06[0x0600:0x0800]`, and the same at `0x0800`/`0x0A00`
and `0x0C00`/`0x0E00`. A sprite table on a 0x1E record stride cannot look like
that, and `bkcpu06` does not.

**So re-read ROM 06 and check offset `0x001E` first**: it must be
`08 00 01 00 08 00`. Re-seat the chip and confirm the reader is set to a 27C010.
A good read makes the whole set work -- `bk03`, `bk04` and `bk07` are sound.

Whether the corrected ROM 06 is byte-identical to `bkcpu06` is a separate
question. The substitution run above shows only that *a* valid table at those
offsets fixes the set, not that V4.1's table is the 1992 one. If the re-read does
come back as `bkcpu06`, CRC `9db436d4`, then V4.1 is a three-chip clone --
`bk03`, `bk04` and `bk07` over the 1992 set.

## Version labelling — one unresolved conflict

Two ROM archives reached this repository together, both labelled V4.1 by their
source:

| Archive | Contents | Verdict |
|---------|----------|---------|
| `bikerace41.zip` | six chips, `BK02`–`BK07` | **this set.** Matches `bikerac3` plus the parent's `02`/`05`. |
| `bike_race_roms_Vers. 401 (1 Ball).zip` | seven chips, `BK01`–`BK07`, each in a folder naming the chip's job in Spanish and its EPROM type | byte-for-byte the **parent** `bikerace` set — all seven chips, no exceptions |

The bytes and the stickers agree with each other and not with the second archive's
label. The photographed machine's stickers read `BK02.V4.1` through `BK07 V.4.1`
and its six chips are this set; the second archive's seven chips are what PinMAME,
IPDB and this repository all hold as the base Bike Race set. Its `V4.1` label is
therefore **unverified** and is not adopted here.

What the second archive does contribute, at no new bytes: it is an independent
second dump of all seven parent chips, confirming that set; it names the chips'
jobs — `01` Display, `02`/`03` Sonido, `04`/`05`/`06` Juego, `07` — and their EPROM
types (27C64, 27C040, 27C010, 27C256); and its `1 Bola` marking is consistent with
PinMAME titling the parent's sibling clone `bikerac2` "Bike Race (2-ball play)".

Settling the conflict needs the version as the machine itself reports it — Bike
Race renders text through DMD font glyphs, so no version string appears in ASCII in
any of these ROMs, and neither `bk04` nor the parent's `bkcpu04` carries one.

## Loading this set in PinMAME

PinMAME wants the V4.1 chips under `bikerac3.zip`, using the driver's member names,
alongside `bikerace.zip` for the inherited chips:

```
bikerac3.zip   bk03.bin  bk04.bin  bk06.bin  bk07.bin
```

That zip is prebuilt at [`../../../pinmame/bikerac3.zip`](../../../pinmame/bikerac3.zip).
The `bk02.bin` and `bk05.bin` in this directory are not members of it — PinMAME
pulls those from `bikerace.zip` as `bksnd02.bin` and `bkcpu05.bin`.

## Note on redistribution

Third-party copyrighted firmware, archived for preservation, documentation and
emulator-accuracy work — the same basis as every other ROM image here. Not covered
by this repository's MIT license, which applies to the scripts and original written
material only.
