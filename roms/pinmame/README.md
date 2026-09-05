# PinMAME ROM Sets

Ready-to-load PinMAME `.zip` sets for the four SLEIC machines whose ROMs are
archived in this repository, packed under the member names the PinMAME driver asks
for. Most members are just a repackaging of an image already stored loose elsewhere
under [`../`](../) — the loose per-machine directories stay the archival copy and
this directory is the emulator-facing packaging of them. The exception is
`bikerac2`: its two distinguishing chips (`04`/`07`) are held **only** here.
`bikerac3`'s three (`bk03`/`bk04`/`bk07`) are also archived loose, inside the
complete six-chip V4.1 pull at
[`../related-machines/bike-race/v4.1/`](../related-machines/bike-race/v4.1/).

Drop the whole directory on PinMAME's ROM path:

```bash
./xpinmame.sdl iomoon --rompath /path/to/sleic-iomoon/roms/pinmame
```

The set definitions — file names, CRC32s and SHA1s — come from `src/wpc/sleicgames.c`
in the PinMAME tree.

## Sets

| Zip | Machine | Family | Parent |
|-----|---------|--------|--------|
| `bikerace.zip` | Bike Race (1992) | `SLEIC3` | — |
| `bikerac2.zip` | Bike Race (2-ball play) | `SLEIC3` | `bikerace` |
| `bikerac3.zip` | Bike Race (V4.1) | `SLEIC3` | `bikerace` |
| `sleicpin.zip` | Sleic Pin-Ball (1993) | `SLEIC1` | — |
| `iomoon.zip` | Io Moon | `SLEIC2` | — |
| `iomoona.zip` | Io Moon (earlier ROM revision) | `SLEIC2` | `iomoon` |
| `iomoont.zip` | Io Moon (PRESS START tournament MOD) | `SLEIC2` | `iomoon` |

**Clone sets follow the MAME convention**: a clone zip holds only the chips that
differ from its parent, and MAME pulls the rest out of the parent zip. So
`bikerac2.zip`, `bikerac3.zip`, `iomoona.zip` and `iomoont.zip` will not load on
their own — the matching parent zip has to be on the same ROM path.

## Members

CRC32 as listed by the driver; each member is byte-verified against both the CRC32
and the SHA1 in `sleicgames.c`.

### `bikerace.zip` — parent, 7 chips

| Member | CRC32 | Source image |
|--------|-------|--------------|
| `bkdsp01.bin` | `9b220fcb` | `../related-machines/bike-race/bkdsp01.bin` |
| `bksnd02.bin` | `d67b3883` | `../related-machines/bike-race/bksnd02.bin` |
| `bksnd03.bin` | `b6d00245` | `../related-machines/bike-race/bksnd03.bin` |
| `bkcpu04.bin` | `ce745e89` | `../related-machines/bike-race/bkcpu04.bin` |
| `bkcpu05.bin` | `072ce879` | `../related-machines/bike-race/bkcpu05.bin` |
| `bkcpu06.bin` | `9db436d4` | `../related-machines/bike-race/bkcpu06.bin` |
| `bkio07.bin` | `b52a9d4f` | `../related-machines/bike-race/bkio07.bin` |

### `bikerac2.zip` — clone, 2 chips differ

| Member | CRC32 | Chip |
|--------|-------|------|
| `04.bin` | `aaaa4a8a` | 80188 game + sound code |
| `07.bin` | `0b763a89` | Z80 I/O CPU ROM |

Chips 01/02/03/05/06 are the parent's.

### `bikerac3.zip` — clone (V4.1), 3 chips differ

| Member | CRC32 | Chip |
|--------|-------|------|
| `bk03.bin` | `74c10536` | OKI sample ROM 2 |
| `bk04.bin` | `33fd212e` | 80188 game + sound code |
| `bk07.bin` | `200ff3fc` | Z80 I/O CPU ROM |

Chips 01/02/05/06 are the parent's. For `02` and `05` that is verified rather than
assumed, against the complete six-chip V4.1 pull at
[`../related-machines/bike-race/v4.1/`](../related-machines/bike-race/v4.1/). ROM
01 of this revision has never been dumped.

**ROM 06 is inherited because a re-dump confirmed it is the parent's.** The first
V4.1 read of ROM 06, CRC `ad48a30a`, was defective; it used to be a member of this
zip, which is why the set was flagged `GAME_NOT_WORKING`. A re-read of the same
machine came back CRC `9db436d4` — byte-identical to `bkcpu06.bin` — so ROM 06 is
inherited from the parent, the set works, and the flag is gone. The evidence is in
[`../../asm/bikerace-2026-09/reports/v41_sprite_table.md`](../../asm/bikerace-2026-09/reports/v41_sprite_table.md);
the bad image is archived as `bk06.baddump.bin` alongside the loose chips.

### `sleicpin.zip` — 4 chips

| Member | CRC32 | Source image |
|--------|-------|--------------|
| `sp01-1_1.rom` | `240015bb` | `../related-machines/sleic-pin-ball/sp01-1_1.rom` |
| `sp02-1_1.rom` | `0e4851a0` | `../related-machines/sleic-pin-ball/sp02-1_1.rom` |
| `sp03-1_1.rom` | `261b0ae4` | `../related-machines/sleic-pin-ball/sp03-1_1.rom` |
| `sp04-1_1.rom` | `84514cfa` | `../related-machines/sleic-pin-ball/sp04-1_1.rom` |

### `iomoon.zip` — parent, 5 chips

| Member | CRC32 | Source image |
|--------|-------|--------------|
| `v1_3_01.bin` | `df80bf4f` | `../1.3 IPDB latest/V1 3_01.bin` |
| `v1_3_02.bin` | `2bd589cd` | `../1.3 IPDB latest/V1 3_02.bin` |
| `v1_3_03.bin` | `334d0e20` | `../1.3 IPDB latest/V1 3_03.bin` |
| `v1_3_04.bin` | `f3a950bf` | `../1.3 IPDB latest/V1 3_04.bin` |
| `v1_3_05.bin` | `6bb5e101` | `../1.3 IPDB latest/V1 3_05.bin` |

### `iomoona.zip` — clone, 2 chips differ

| Member | CRC32 | Source image |
|--------|-------|--------------|
| `v1_3_01e.bin` | `00a75790` | `../1.3 Early version/V1 3_01.bin` |
| `v1_3_05e.bin` | `dd5145f5` | `../1.3 Early version/V1 3_05.bin` |

Chips 02/03/04 are byte-identical to the parent's and are inherited from
`iomoon.zip`. The `e` suffix is the driver's, to tell the two revisions apart —
the chips themselves carry no label that separates them.

### `iomoont.zip` — clone, 1 chip differs

| Member | CRC32 | Source image |
|--------|-------|--------------|
| `v1_3_01t.bin` | `42cafcda` | `../1.3 IPDB latest/Start-Tournament-Patch/V1 3_01.bin` |

Chips 02-05 are the parent's.

## Verifying

```bash
unzip -lv iomoon.zip          # member names, sizes and CRC32s
```

The CRC32 column must match the `CRC(...)` values in `sleicgames.c` exactly; PinMAME
checks both CRC32 and SHA1 at load and warns on a mismatch.

## Note on redistribution

Same basis as the loose images these are packed from: third-party copyrighted
firmware, archived for preservation, documentation and emulator-accuracy work. Not
covered by this repository's MIT license, which applies to the scripts and original
written material only.
