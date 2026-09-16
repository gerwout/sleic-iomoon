# A four-player game

[← Back to the DMD corpus overview](../README.md)

Every other capture in this corpus plays **one** player, so the whole multi-player
side of the machine had never been on screen. **219 distinct screens, 76 of them new
to the corpus.**

The ROM carries `PLAYER 1:` through `PLAYER 4:` as real strings (`JUGADOR 1:` to
`JUGADOR 4:` in Spanish, the record-inscription labels at flat `0x10014` and
`0x30015`), and the in-play HUD's own pointer pool carries `PLAYERS` beside `PLAYER`
— none of which a one-player walk can put on the panel.

## What is here

Four players, three balls each, twelve balls in all. Every ball has the same shape —
plunge, two lane hits so the ball scores, drain, follow the next ball — which keeps
the walk short while still giving each player its own ball-start, in-play and drained
screens on all three balls, and the player-to-player handover at every drain.

**The four-player score display is the screen that separates this capture from the
rest.** `screens.csv` decodes `1 2 / 3 4 / 1 1 / PLAYER BALL` — the four player
numbers together on one panel, over the in-play HUD words. `dmd/en/`, playing one
player, only ever decodes `1 1`, `1 2` and `1 3`: its own player number and its three
ball numbers, never a second player's row.

## Confirmed from the machine, not the script

Twelve **ball-over** events (code `0x43`, the trough entry contact reporting as the
ball-over sensor, F15) reach the 80188 across the run — exactly four players × three
balls. A one-player game gives three. Five `0x40` START codes are delivered: one that
dismisses the boot screen and four that each add a player before the first plunge.

## Four credits, and what it takes to get them

A coin sticks only **after the first attract cycle** — one pressed during the boot
cycle is lost, because the firmware's own default seeding zeroes the credit triple —
and **one coin is not one credit** under country 4's coin preset (F11): six coins buy
one. Twenty-four are pressed here, then `START` four times, all before the first ball
is plunged, which is what makes it a four-player game rather than four games.

## Capture

```bash
cd pinmame
SDL_VIDEODRIVER=dummy SDL_AUDIODRIVER=dummy ./build/sdl3pinmame iomoon \
  -rompath ./roms -nvram_directory /tmp/nv -nosound \
  -skip_disclaimer -skip_gameinfo -skip_gamewarnings -nothrottle -ftr 18700 \
  -dmd_dump_dir ../sleic-iomoon/dmd/players \
  -key_script ../sleic-iomoon/scripts/keyscripts/iomoon-players.keys

cd ../sleic-iomoon
cp scripts/keyscripts/iomoon-players.keys.marks dmd/players/iomoon.marks
python3 scripts/dmd_dump_split.py dmd/players/iomoon.txt \
        --out dmd/players --marks dmd/players/iomoon.marks \
        --rom ../pinmame/roms/iomoon/v1_3_01.bin
```

Run against the shipping `build/sdl3pinmame`, no probe compiled in.

## Marks

`credits-4` · `start-player-1` .. `start-player-4` · `four-players-up` ·
`ball-N-player-P-start`, `ball-N-player-P-in-play`, `ball-N-player-P-drained` for
N = 1..3 and P = 1..4 · `game-over` · `end`.

## What this does not settle

**The record-inscription screen for players 2, 3 and 4 is still not captured.** §4.2
invites each qualifying player in turn, and the `PLAYER 2:`/`3:`/`4:` label lines
exist in ROM for exactly that, but entry needs the player to beat one of the five
stored records — 100,000,000 on a freshly seeded store — which twelve balls of lane
hits at 100,000 each cannot approach. Reaching it wants either a pre-seeded
non-volatile store with low records in it, or the extra-ball/replay thresholds turned
down through the service menu first.
