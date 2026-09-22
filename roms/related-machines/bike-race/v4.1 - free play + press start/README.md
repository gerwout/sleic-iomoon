# ROM Set — Bike Race V4.1, free play + PRESS START patch

The chip-04 image of the [`v4.1`](../v4.1/) set with **both** patches applied:

* **PRESS START** — the end of a game holds the finished game's scores on the panel
  until START is pressed, instead of dropping to attract on its own.
* **Free play** — the machine always has a credit standing, so START begins a game
  with no coin.

Confirmed working on a real V4.1 machine.

## Files

| Filename | Size | MD5 | CRC32 | Content |
|----------|------|-----|-------|---------|
| `bk04f.bin` | 131,072 bytes (128 KB) | `c15131f553e31e394ae46faeaeb0f789` | `7626564e` | 80188 game + sound code, linear `0xE0000–0xFFFFF` — **PATCHED ×2** |

SHA1 `d69c5dd794c55d91d4dde5c6c07009bb1ebe2c41`.

## Source

| | MD5 | CRC32 |
|---|---|---|
| Original, [`../v4.1/bk04.bin`](../v4.1/bk04.bin) | `0ef6759ea3e87afd6b883d8052e8b2f3` | `33fd212e` |
| + free play | `b373102673837f0b020d5f4a086aadb3` | `42748f1d` |
| + PRESS START | `c746d6af7b6847c213db352d0291da28` | `07aff87d` |
| + both, this file | `c15131f553e31e394ae46faeaeb0f789` | `7626564e` |

Reproduce it by running the two scripts in sequence:

```bash
python3 scripts/bike_race_free_play_patch.py \
        "roms/related-machines/bike-race/v4.1/bk04.bin" -o tmp.bin
python3 scripts/bike_race_press_start_patch.py tmp.bin -o bk04f.bin
```

The two patches are independent — different hooks, different caves, both in the
ROM's zero padding above `F9163` — so either order produces the same bytes.

## What the free-play patch does

A cave at `F9200` reached by a hook at `E059F`, the one place every credit value
comes from. `E000:059F` reads the triplicated credit byte (`0x83`/`0x105`/`0x278`
in the store window at segment `1040`) and the cache `[0116:0070]` is recomputed
from it, so flooring that read at 1 leaves every downstream path stock.

Bypassing the START handler's credit test at `EC3B4` does **not** work: the mode
byte `[0116:0076]` is promoted 0 → 1 by the stock code only *because* a credit
appeared, and the handler refuses at its first instruction in mode 0. Giving the
machine a real credit instead keeps the end-of-game match award banking its credit
through that same path.

Bike Race has no free-play adjustment of its own — its CREDITOS page is coin
pricing only, and no ROM in the set contains GRATIS, LIBRE or FREE.

## What the PRESS START patch does

Two hooks into one shared hold, because two different things take the scores down:
`F000:10F2`, the screen loader that follows a one-, two- or three-player game, and
`E8C5D`, the panel blank ahead of the "Partida" overlay, which is what a
four-player game reaches first. Both are guarded on the state byte `[0116:0099]`
and the player count `[0116:0072]`, and `[0010:1030]` is the latch that gives a
game exactly one hold.

Releasing the hold takes the firmware's own two-step idiom. `E50E:43BA` pops one
switch code and reports START, but the FIFO can hold more than one `36h` for a
single press — the Z80's cabinet scan has no time-based debounce and re-arms the
instant the contact reads open (`bkio07:3033`). So the hold waits sixteen steps of
the free-running digit `[0010:000B]` (about 320 ms) and then calls `E9C7:2F47` to
scrub every queued `36h`, exactly as the stock START handler at `EC2FA` and the
FABRICA prompt at `E9486` do. Without the scrub one press both released the hold
and started a game.

Full detail, including the guards and the measured verification table, is in the
docstring of [`scripts/bike_race_press_start_patch.py`](../../../../scripts/bike_race_press_start_patch.py).

## Installing it

Only chip 04 changes. Program this image onto a 27C010 and swap it for the
machine's `BK04`; chips 01, 02, 03, 05, 06 and 07 stay in place.

> The rest of the machine must already be the **V4.1** set. Chips `03` and `07`
> differ between V4.1 and the 1992 parent, so a 1992 machine needs those upgraded
> too — see [`../v4.1/README.md`](../v4.1/README.md).

Keep the original EPROM: the patch is reversible only by putting it back.

## In PinMAME

Loaded as set `bikerc3f`, "Bike Race (V4.1, free play + press start)" — see
[`../../../pinmame/README.md`](../../../pinmame/README.md). That zip carries all
seven chips, so it loads with no `bikerace.zip` beside it.

## Note on redistribution

Third-party copyrighted firmware, archived for preservation, documentation and
emulator-accuracy work — the same basis as every other ROM image here. Not covered
by this repository's MIT license, which applies to the scripts and original written
material only.
