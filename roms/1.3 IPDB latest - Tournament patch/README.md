# ROM Set — 1.3 IPDB latest, Tournament patch

> **DEPRECATED — use
> [`1.3 IPDB latest - Tournament and free play patch/`](../1.3%20IPDB%20latest%20-%20Tournament%20and%20free%20play%20patch/)
> instead.** That image is this one with the free-play patch stacked on top: it
> holds the scores in exactly the same way and adds coin-free starting, which is
> what a tournament wants. This directory stays for anyone who needs the
> PRESS-START behaviour on a coin-operated machine, and because `iomoont` in
> PinMAME loads it.

The chip-01 image of the [`1.3 IPDB latest`](../1.3%20IPDB%20latest/) set with the
PRESS START patch applied: at the end of a game the machine holds the final
scores on the panel until START is pressed, instead of running the match
animation straight into attract.

## Files

| Filename | Size | MD5 | CRC32 | Content |
|----------|------|-----|-------|---------|
| `V1 3_01.bin` | 524,288 bytes (512 KB) | `71f19724d19bed4eac02f6c7caaad774` | `42cafcda` | Display ROM 1 (80188 code + upper graphics) — **PATCHED** |

## Source

| | MD5 | CRC32 |
|---|---|---|
| Original, `1.3 IPDB latest/V1 3_01.bin` | `031ca4c25f0e0433f9922b6a142478fa` | `df80bf4f` |
| Patched, this file | `71f19724d19bed4eac02f6c7caaad774` | `42cafcda` |

Reproduce it with
[`scripts/io_moon_press_start_patch.py`](../../scripts/io_moon_press_start_patch.py):

```bash
python3 scripts/io_moon_press_start_patch.py "roms/1.3 IPDB latest/V1 3_01.bin" \
        -o "V1 3_01.bin"
```

What the patch changes is in
[`docs/press_start_patch.md`](../../docs/press_start_patch.md): 186 bytes in four
regions — a 168-byte and an 11-byte block of new code in the ROM's `0xFF` padding
at `C0010`-`C00B7` and `C00D0`-`C00DA`, reached by two four-byte hooks at `D5077`
and `D5123`.

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

Loaded as set `iomoont`, "Io Moon (PRESS START tournament MOD)" — see
[`../pinmame/README.md`](../pinmame/README.md).
