# ROM Set — Sleic Pin-Ball V1.1, free play + PRESS START patch

The chip-03 image of the [complete set](../) with **both** patches applied:

* **PRESS START** — the end of a game holds the finished game's scores on the panel
  until START is pressed, instead of dropping to attract on its own.
* **Free play** — the machine always has a credit standing, so START begins a game
  with no coin.

Verified in emulation, headless. **Not yet confirmed on a real machine.**

## Files

| Filename | Size | MD5 | CRC32 | Content |
|----------|------|-----|-------|---------|
| `sp03-1_1.rom` | 131,072 bytes (128 KB) | `045e8ba3ac1fa12d70c6f99966f5466f` | `a6501c6b` | 80188 game + sound code, `0xE0000-0xFFFFF` — **PATCHED ×2** |

SHA1 `feae88ef522f7436fa31083cea71ed171bc5cc77`.

## Source

| | MD5 | CRC32 |
|---|---|---|
| Original, [`../sp03-1_1.rom`](../sp03-1_1.rom) | `50c49844fe28d1d8b3477eb35cc8e133` | `261b0ae4` |
| + free play | `42d5dae15b21ec4bc2b40396efc4e84e` | `f82af142` |
| + PRESS START | `2b1e14cd382d3046a66473e4344c23cc` | `7861e7cd` |
| + both, this file | `045e8ba3ac1fa12d70c6f99966f5466f` | `a6501c6b` |

Reproduce it by running the two scripts in sequence:

```bash
python3 scripts/sleic_pin_ball_free_play_patch.py \
        "roms/related-machines/sleic-pin-ball/sp03-1_1.rom" -o tmp.rom
python3 scripts/sleic_pin_ball_press_start_patch.py tmp.rom -o "sp03-1_1.rom"
```

The two patches are independent — different hooks, different caves — so either
order produces the same bytes.

## What the free-play patch does

Credits are a triplicated NVRAM byte at `0x140`-`0x142`, read behind a three-way
equality check, with `[0000:0100]` the RAM cache every consumer actually reads.
The patch floors that cache to at least 1 at both of its writers, `E000:147E`
(the clean-read path) and `E000:14C8` (the banking tail), and lets the floored
value fall through to the digit splitter so the credit display agrees. It never
writes the NVRAM triple, so a free game consumes nothing and the store cannot be
corrupted.

Sleic Pin-Ball has no free-play adjustment of its own.

## What the PRESS START patch does

Five hooks, all in segment E000. The end-of-game screen sequence is a table of
near offsets at `E000:4F7C`, indexed by `[0000:017D]` and dispatched from
`E000:4F4E`. Entry 25 at `E000:4FAE` is a spare slot stock firmware can never
index, so the patch points it at a stub; the two game-over tails at `E000:197C`
and `E000:1962` are redirected to it, each recording which step the game would
have gone to so the stub can hand control back; and both of the attract loop's
credit tests, at `E000:00D8` and `E000:00EC`, are hooked so the screen appears
whether or not credits are standing. That last pair is what makes it work on
free play. Entry 23, which attract's own free-running cycle reaches, is
deliberately left alone, so the screen cannot appear in attract.

The stub snapshots what it needs — the player count and all four players' score
digits — because the attract loop's entry preamble resets the game state before
the stub runs: `[0x106]` at `E000:00B8`, and `call 0x7bd` at `E000:00CB`, which
wipes `0x1C5`-`0x26E`, every player's score block.

Full mechanism detail is in
[`research/sleicpin_disasm/sleicpin_endgame.md`](../../../../research/sleicpin_disasm/sleicpin_endgame.md).

## Verified

In emulation, headless: the screen appears at game over for 1 and 4 players with
the scores rendering correctly, one START press releases it, a press reported
twice does not disturb anything, it works with credits standing and exhausted, a
coin inserted while held is not lost, three games back to back each show their
own scores, the service menu still opens and closes, and free play starts a game
with no coin.

On a real machine: both patches in play, and a record-beating score still reaches
name entry.

Whether the `¿ CONTINUAS ?` offer (above 1,000,000 points) resolves is not
established. It is armed and blinking identically in stock and patched builds
well past where it should time out, and nothing headless settles it.

## Installing it

Only chip 03 changes. Program this image onto the appropriate EPROM and swap it
for the machine's chip 03; chips 01, 02 and 04 stay in place.

Keep the original EPROM: the patch is reversible only by putting it back.

## In PinMAME

Loaded as set `sleicpnf`, "Sleic Pin-Ball (free play + end-of-game scores)" — see
[`../../../pinmame/README.md`](../../../pinmame/README.md). That zip carries all
four chips, so it loads with no `sleicpin.zip` beside it.

The `sleicpnf` set and the SLEIC1 ball-exit model it needs are **not upstream
yet**. Until they are, the zip runs against the stock `sleicpin` driver by
pointing `-rompath` at a directory holding it named `sleicpin.zip`, which reports
a checksum warning that `-skip_gamewarnings` suppresses — and, without the
ball-exit model, no ball is served, so a game cannot reach game over.

`sleicpin` ships the `Balls` setting at 1, which is what enables the ball-exit
model once that is upstream; a value of 0 disables it.

## Note on redistribution

Third-party copyrighted firmware, archived for preservation, documentation and
emulator-accuracy work — the same basis as every other ROM image here. Not covered
by this repository's MIT license, which applies to the scripts and original written
material only.
