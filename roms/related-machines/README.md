# Related SLEIC Machines — ROM Images

The images in this subtree are **not** IO Moon. They belong to three other SLEIC
pinball machines that share board designs, firmware idioms, or both with IO Moon,
and they are archived here because the reverse engineering in this repository was
carried out against them: the Bike Race and Sleic Pin-Ball disassemblies in
[`../../asm/`](../../asm/) and [`../../research/`](../../research/) are derived
from these exact bytes, and the PinMAME driver work used Bike Race as the live
oracle for the shared SLEIC hardware model.

See [`../../docs/sleic_board_family.md`](../../docs/sleic_board_family.md) for how
the four machines relate.

## The machines

| Directory | Machine | Year | PinMAME family | Dump status |
|-----------|---------|------|----------------|-------------|
| [`sleic-pin-ball/`](sleic-pin-ball/) | Sleic Pin-Ball | 1994 | `SLEIC1` | complete (4 ROMs) |
| [`bike-race/`](bike-race/) | Bike Race | 1992 | `SLEIC3` | complete (7 ROMs), plus a six-chip [V4.1 set](bike-race/v4.1/) |
| [`dona-elvira-2/`](dona-elvira-2/) | Doña Elvira 2 (SLEIC-Petaco) | 1996 | — | all 6 EPROMs; **`ELVSON3` short `0xF000`** |

IO Moon itself is `SLEIC2`; its ROM sets live one level up in
[`../1.3 IPDB latest/`](../1.3%20IPDB%20latest/) and
[`../1.3 Early version/`](../1.3%20Early%20version/).

## Provenance

- **Bike Race** and **Sleic Pin-Ball** — filenames follow the PinMAME set naming
  convention (`bkcpu04.bin`, `sp03-1_1.rom`, …). These are the images every Bike
  Race and Sleic Pin-Ball statement in this repository was verified against.
- **Bike Race V4.1** ([`bike-race/v4.1/`](bike-race/v4.1/)) — the six socketed
  chips of one V4.1 machine, pulled together off its two backbox boards, which are
  photographed in [`../../docs/bikerace_boards.md`](../../docs/bikerace_boards.md).
  Filenames are the chips' own (`bk02.bin` … `bk07.bin`), not PinMAME's.
- **Bike Race V4.1, patched** ([`bike-race/v4.1 - free play + press start/`](bike-race/v4.1%20-%20free%20play%20+%20press%20start/))
  — that set's chip 04 carrying the PRESS START and free-play patches, confirmed
  working on a real V4.1 machine. Reproducible from `bk04.bin` with the two
  scripts in [`../../scripts/`](../../scripts/).
- **Doña Elvira 2** — all six EPROMs of one machine: the Z80 game CPU's 27C256, the
  Z80 sound CPU's 27C010, and the four 27C040s of OKI samples. Filenames are the
  dumper's own, where the numeric prefix is the EPROM type and the extension the
  board (`.som` = *sonido*, `.pro` = *programa*); the `uNN` numbers are a dump
  sequence, not the board's IC numbers. No public dump of this machine was known to
  us when these were archived, which is also why they cannot be cross-checked
  against a second source the way the IO Moon set could. Its service manual is
  archived in [`../../manuals/`](../../manuals/), and is what the board complement
  and the IC assignments in that machine's README are read from.

## Checksums

Per-file MD5s are listed in each machine's README and, together with every other
ROM image in this repository, in the master index at [`../README.md`](../README.md).

## Note on redistribution

These are third-party copyrighted firmware images, archived for preservation,
documentation, and emulator-accuracy work — the same basis on which the IO Moon
images in the parent directory are kept. They are not covered by this
repository's MIT license, which applies to the scripts and original written
material only.
