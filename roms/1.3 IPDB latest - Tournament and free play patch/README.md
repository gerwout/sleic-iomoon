# ROM Set — 1.3 IPDB latest, Tournament + free play patch

The chip-01 image of the [`1.3 IPDB latest`](../1.3%20IPDB%20latest/) set with
**both** patches applied:

* **PRESS START** — the end of a game holds the final scores on the panel until
  START is pressed, instead of running the match animation straight into attract.
* **Free play** — the machine always has a credit standing, so START begins a game
  with no coin.

This is the recommended tournament image, and it supersedes
[`1.3 IPDB latest - Tournament patch/`](../1.3%20IPDB%20latest%20-%20Tournament%20patch/),
which carries the PRESS START patch alone.

## Files

| Filename | Size | MD5 | CRC32 | Content |
|----------|------|-----|-------|---------|
| `V1 3_01.bin` | 524,288 bytes (512 KB) | `ead2200c63d9dee990c2a570c41033bf` | `007ec001` | Display ROM 1 (80188 code + upper graphics) — **PATCHED ×2** |

## Source

| | MD5 | CRC32 |
|---|---|---|
| Original, `1.3 IPDB latest/V1 3_01.bin` | `031ca4c25f0e0433f9922b6a142478fa` | `df80bf4f` |
| + PRESS START | `71f19724d19bed4eac02f6c7caaad774` | `42cafcda` |
| + free play, this file | `ead2200c63d9dee990c2a570c41033bf` | `007ec001` |

Reproduce it by running the two scripts in sequence:

```bash
python3 scripts/io_moon_press_start_patch.py "roms/1.3 IPDB latest/V1 3_01.bin" -o tmp.bin
python3 scripts/io_moon_free_play_patch.py   tmp.bin -o "V1 3_01.bin"
```

The two patches are independent — different hooks, different caves — so either
order produces the same bytes.

## What the free-play patch does

59 bytes in two regions: a 54-byte cave in the ROM's `0xFF` padding at `C00DB`,
reached by a five-byte hook planted at `D301E`.

`main_loop` at `D3002` dispatches on the mode byte `[413C:014F]`: mode 1 is the
idle state with an empty bank, mode 2 the idle state with credits. A game is
*built* inside mode 2's handler, so forcing START past the credit test at `D809C`
is not enough — that books the game and bumps the audit, but nothing sets it up.
The cave hooks `main_loop`'s mode-1 arm instead: whenever the firmware is about to
enter the no-credit idle it writes 1 to the triplicated credit bytes
`0x83`/`0x116`/`0x20C`, sets the cache `[413C:00D4]` to match, promotes the mode to
2 and returns. From there every path is stock — attract behaves as it does with a
coined credit, and START spends through the unmodified path. The cave writes only
when the cache reads zero, and only a game start zeroes it, so the store sees one
write per game.

Coins still work: a coined machine accumulates one credit higher than stock
throughout.

## Installing it

Only chip 01 changes. Program this image onto a 27C040 and swap it for the
machine's `V1 3_01`; chips 02-05 stay in place.

> The rest of the machine must already be the **IPDB latest** set. The Z80 ROM
> `V1 3_05.bin` differs between that set and
> [`1.3 Early version`](../1.3%20Early%20version/) (`4a96bb47…` against
> `da674b87…`), so an Early-version machine needs that chip upgraded too. Chips
> 02, 03 and 04 are byte-identical in both sets.

Keep the original EPROM: the patch is reversible only by putting it back.

## In PinMAME

Loaded as set `iomoontf`, "Io Moon (tournament MOD, free play)" — see
[`../pinmame/README.md`](../pinmame/README.md).
