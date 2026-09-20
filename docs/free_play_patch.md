# Free Play Patch — `io_moon_free_play_patch.py`

[← Back to main README](../README.md)

## Overview

IO Moon has no free-play adjustment. Its service menu prices coins and nothing
more, and no string in either ROM offers one. This patch gives the machine a
standing credit instead, so **START begins a game on every press with no coin**.

It is meant to be stacked on the
[PRESS START patch](press_start_patch.md): together they are the tournament
image, held-scores plus coin-free starting. The two are independent — different
hooks, different caves — and produce the same bytes in either order.

## Pre-patched ROM

| Directory | Chip 01 MD5 | CRC32 |
|-----------|-------------|-------|
| [`roms/1.3 IPDB latest - Tournament and free play patch/`](../roms/1.3%20IPDB%20latest%20-%20Tournament%20and%20free%20play%20patch/) | `ead2200c63d9dee990c2a570c41033bf` | `007ec001` |

Only chip 01 changes. Program it onto a 27C040 and swap it for the machine's
`V1 3_01`; chips 02-05 stay in place. The machine must already be the **IPDB
latest** set — the Z80 ROM `V1 3_05.bin` differs from the Early version.

## How it works

59 bytes in two regions: a 54-byte cave in the ROM's `0xFF` padding at `C00DB`,
reached by a five-byte hook planted at `D301E`.

**Forcing the START handler is not enough.** `sub_D8066`'s credit test at `D809C`
guards only the *booking* of a game — it bumps the games-played audit and spends
the credit. A game is *built* somewhere else: `main_loop` at `D3002` dispatches on
the mode byte `[413C:014F]`, where mode 1 is `sub_D303C`, the idle state with an
empty bank, and mode 2 is `sub_D307F`, the idle state with credits, and it is
`sub_D307F`'s mode-3 branch at `D30CD` that sets up music, display, the start lamp,
Z80 command `0xA9` and `sub_DC7D7`. Bypassing the credit test leaves the machine in
mode 1, where the handler refuses at its first instruction.

So the cave hooks `main_loop`'s mode-1 arm. Whenever the firmware is about to enter
the no-credit idle it:

1. writes 1 to the triplicated credit bytes `0x83`/`0x116`/`0x20C` in the
   non-volatile store's segment-`5040` window (F10's scheme — a majority compare
   zeroes all three on a mismatch, so all of them have to be written),
2. sets the cache `[413C:00D4]` to match,
3. promotes the mode byte to 2,
4. returns **without** calling `sub_D303C`, so `main_loop` re-dispatches into
   `sub_D307F`.

That single site covers power-on and the end of every game. From there every path
is stock: attract behaves exactly as it does with a coined credit, and START spends
the credit through the unmodified `D80D1` path.

The cave writes only when the cache reads zero, and only a game start zeroes it, so
the EEPROM sees **one write per game** rather than one per frame.

Coins still work — a coined machine simply accumulates one credit higher than
stock throughout.

## Usage

```bash
python3 scripts/io_moon_free_play_patch.py "V1 3_01.bin" -o "V1 3_01f.bin"
```

Stacked on the tournament patch, in either order:

```bash
python3 scripts/io_moon_press_start_patch.py "roms/1.3 IPDB latest/V1 3_01.bin" -o tmp.bin
python3 scripts/io_moon_free_play_patch.py   tmp.bin -o "V1 3_01.bin"
```

`--combined-rom` patches a 1 MB `ROM2+ROM1` image instead of a standalone chip-01
file.

## Verified

In emulation, as PinMAME set `iomoontf`: with no coins inserted, a single START
press reaches credits 1, mode 1 and players 1, where an untouched machine stays at
credits 0, mode 0 and never starts. Coins still accumulate, one credit higher than
stock at each step. Attract is undisturbed.
