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
| [`bike-race/`](bike-race/) | Bike Race | 1992 | `SLEIC3` | complete (7 ROMs) |
| [`dona-elvira-2/`](dona-elvira-2/) | Doña Elvira 2 (SLEIC-Petaco) | 1996 | — | **partial — Z80 CPU ROM only** |

IO Moon itself is `SLEIC2`; its ROM sets live one level up in
[`../1.3 IPDB latest/`](../1.3%20IPDB%20latest/) and
[`../1.3 Early version/`](../1.3%20Early%20version/).

## Provenance

- **Bike Race** and **Sleic Pin-Ball** — filenames follow the PinMAME set naming
  convention (`bkcpu04.bin`, `sp03-1_1.rom`, …). These are the images every Bike
  Race and Sleic Pin-Ball statement in this repository was verified against.
- **Doña Elvira 2** — read off the Z80 CPU board's 27C256 EPROM (an ST27C256,
  hence the filename). No public dump of this machine was known to us when it was
  archived here, which is also why it cannot be cross-checked against a second
  source the way the IO Moon set could.

## Checksums

Per-file MD5s are listed in each machine's README and, together with every other
ROM image in this repository, in the master index at [`../README.md`](../README.md).

## Note on redistribution

These are third-party copyrighted firmware images, archived for preservation,
documentation, and emulator-accuracy work — the same basis on which the IO Moon
images in the parent directory are kept. They are not covered by this
repository's MIT license, which applies to the scripts and original written
material only.
