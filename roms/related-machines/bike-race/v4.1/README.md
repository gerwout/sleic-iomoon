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

## Why `bikerac3` is `GAME_NOT_WORKING`, and what these bytes rule out

V4.1 boots and runs under PinMAME but draws garbage artwork. Four things the
complete set and the board photograph now establish, none of which were checkable
before:

1. **The 80188 chip-select programming is unchanged.** The register/value table at
   file offset `0x50` in `bk04` — `MMCS 0x01FF`, `PACS 0xA03C`, `MPCS 0xC0FC` — is
   byte-identical to `bkcpu04`'s. V4.1 therefore decodes the same map the 1992 sets
   do: `MCS1 0x20000` = ROM 06, `MCS2 0x40000` = ROM 05, `MCS3 0x60000` = the DMD
   buffer.
2. **The graphics ROM at `MCS2 0x40000` is unchanged.** `bk05` is byte-identical to
   `bkcpu05`, all 128 KB of it.
3. **The graphics ROM at `MCS1 0x20000` is unchanged from `0x1104` on.** `bk06`
   differs from `bkcpu06` only across `0x0000-0x1103`, and the differences there
   fall in 109 short scattered runs with the shape of edited glyph and sprite
   bitmaps, not of a repointed table.
4. **There is no fourth ROM position on the board** to hold artwork the set is
   missing.

So V4.1 addresses the same map and reads very nearly the same artwork bytes at the
same addresses. What did change wholesale is the code: `bk04` differs from
`bkcpu04` in 49 % of its bytes and `bk07` from `bkio07` in 38 %, both full rebuilds
rather than relocations — a shifted-copy search over ±8 KB peaks at zero shift and
only 39 % agreement, and both `bk04` and `bkcpu04` end their used region at the
same `0x1FFF5`.

That points the investigation at how V4.1's rebuilt code drives the DMD pipeline,
or at what the driver models differently from what that code expects — not at a
missing or mismapped graphics ROM.

> The reason recorded above the `bikerac3` ROM block in `sleicgames.c` says
> something else: that V4.1's graphics-descriptor table sends the artwork fetch to
> `0x24000` instead of `0x40000`. That explanation predates this dump and is not
> supported by the bytes above — it is worth re-establishing from a running trace
> before anything is built on it.

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
