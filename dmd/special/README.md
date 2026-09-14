# The SPECIAL/match capture

[← Back to the DMD corpus overview](../README.md)

The tournament mod's second `PRESS START` hook, inside the SPECIAL/match handler at
`D5077` (`scripts/io_moon_press_start_patch.py` calls it "hook inside SPECIAL handler,
before animation starts") — a real lottery win, per `docs/iomoon_game_rules.md` §3.5: a
free-running counter is compared against the units digit of a player's score, and a match
awards a free game. This capture is the one short, targeted headless run that reaches it.

## The mechanism, cited

`sub_D4CF4` (`D4CF4`) runs once per game, from the end-of-ball state machine's own
game-over dispatch (`sub_D3145`, its call into `sub_D46F8` at `D3237`, itself gated on
`sub_D3920` signalling no balls left). For a one-player game it divides the player's own
score-digit byte (`413C:0016`) by 10 and compares the remainder, at `D4DCB`, against work
RAM `4000:113F`. That cell is incremented once every timer-0 tick inside the timer-0 ISR
itself (`D0302`-`D0311`, F3, 99.18 Hz) with no gate anywhere in the straight-line code that
writes it — it free-runs 0-9 for as long as the machine has been powered on, independent of
anything the player does. On equality, `sub_D4FDC` is called with `n=1`: it banks a credit
immediately (`nvstore_write_triple_83`, a real NVRAM write, not just an in-memory flag) and
runs the SPECIAL animation through the same `D5076`/`D5077` trampoline the tournament mod's
own `PRESS START` patch hooks, ending at the same `PRESS START` text the mod's normal
end-of-game hook (`D5123`) also draws.

## What a controlled sweep established, and what it did not

The approach: nine fixed key-press slots across an ordinary three-ball game, every slot's
own frame number and hold duration identical across every trial — only which key each slot
presses differs. A slot presses either a lane (`KEYCODE_Y`, always 100,000, units digit 0
regardless of state — every lane's own award ends in zero, docs/iomoon_game_rules.md §3.3.1)
or a bumper/bull's-eye/inner-bank (10,001, 20,001 or 50,001 — every one of these, and only
these, among the rules' own awards, ends in the digit 1, §3.5). A trial's own final score's
units digit is therefore exactly its count of nonzero-digit slots, 0 through 9, with the
event schedule — every frame a key is pressed, every drain, every plunge — never moving.

Ten trials, one per digit, each against a freshly-wiped NVRAM. None matched: NVRAM's
credit triple read `0` after every one of them (`scripts/nvcheck.py`), where a match would
read `1`. This is a real, clean null result under the simplest form of the controlled
swap the approach calls for — but it is **not** proof the counter is stable (or unstable)
under it. A single window with no hit does not distinguish "the counter behaves and this
window's own sampled value simply was not one of the ten offered" from a genuine
timing-sensitivity in exactly when `sub_D4CF4` samples it. Settling that needs an
independent read of `4000:113F` at the sampling instant, which this round could not get:

- The classic MAME debugger (`build-debug/sdl3pinmame -debug`) needs a real display
  window; under this project's own headless convention, `SDL_VIDEODRIVER=dummy`, it
  segfaults trying to create one rather than starting.
- MAME's own save-state mechanism works headlessly (the `F7`+`Left Shift`/`F7` hotkeys
  reach it through the same `-key_script` input path everything else in this corpus
  uses, no `SDL_VIDEODRIVER` dependency) and the file format is confirmed by reading
  `src/state.c`: an 24-byte header (`MAMESAVE`, version, flags, game name, a CRC
  signature) followed by every `state_save_register`'d region concatenated by a plain
  `memcpy`, in registration order, with **no per-item name or tag stored in the payload
  itself** — only used to build the save's own signature, for a load-time compatibility
  check. Locating one particular byte therefore means finding it by content, and content
  search does not work here: of the file's roughly 1.15 MB, about 780,000 byte positions
  independently read 0-9 across a run of saves taken every 7 frames, almost certainly a
  video bitmap (the SDL software-rendered window buffer is registered and saved
  alongside everything else) dominating the file with small pixel-index values that
  coincidentally satisfy "reads 0-9" far more often than one real counter byte can stand
  out against. Correlating each candidate's own value sequence against the exact
  predicted tick sequence (99.18 Hz against the confirmed 60 Hz outer frame rate, correct
  to the millisecond via the run's own `.marks` timestamps) found no candidate matching
  even loosely — either the correlation's own assumptions (a constant number of real
  frames between each save, which `do_loadsave`'s own blocking input loop does not
  strictly guarantee) do not hold tightly enough, or the databus-width registration
  PinMAME's `register_zone` (`src/memory.c`) uses for this CPU does not place the byte
  where a raw content scan can find it.

What would settle the stability question directly: the same digit-vs-lottery correlation
run against a `-debug` build under a real X server (`Xvfb`/`xvfb-run`, not the dummy
driver this project otherwise uses) with a genuine memory watch on `4000:113F`, reading
its value at the exact instant `D4DCB` executes across several digit trials.

## Reached anyway, and said so plainly

A one-byte ROM patch makes the outcome deterministic regardless of the counter or the
score: physical address `D4DCB` holds the digit-vs-counter compare's own conditional jump,
`JE` (`74 03`); changed to `JMP short` (`EB 03` — same operand, same target `D4DD0`),
`sub_D4FDC` runs unconditionally at every game's own end-of-ball dispatch. Applied in
`MACHINE_INIT(SLEIC2)` (`pinmame/src/wpc/sleic.c`), gated on `getenv("SLEIC_FORCE_MATCH")`,
applied and reverted around this one capture — `pinmame`'s own tree on `master` and
`iomoon-sim` carries none of it, the same convention `dmd/faults/README.md` documents for
its own probes.

```c
/* in MACHINE_INIT(SLEIC2), right after machine_init_SLEIC(): */
if (getenv("SLEIC_FORCE_MATCH")) {
  UINT8 *rom = memory_region(SLEIC_MEMREG_CPU);
  if (rom[0xd4dcb] == 0x74) rom[0xd4dcb] = 0xeb;   /* JE -> JMP, same target */
}
```

The screens this reaches are real; only the path to them is forced. Three distinct
screens show it, cited against `screens.csv` (`dmd/special/screens.csv`, ms timestamps
from the raw dump):

| ms | Scene | Content |
|---|---|---|
| 166566-167366 | `0298-ball-3-drained-gameover` | a Monolith/train graphic — part of the SPECIAL animation `sub_D4FDC` runs before drawing `PRESS START`, not seen anywhere in a normal, non-matching end-of-game |
| 167399-171949 | `0299-ball-3-drained-gameover` | a full-panel digit `5` — previously undocumented in this corpus, and a strong candidate for the lottery number drawn on-panel (not confirmed against the ROM's own draw routine — see Open below) |
| 172199 onward (static to the capture's own end) | `0300-ball-3-drained-gameover` | `PRESS START`, text-identical to the `D5123` occurrence already in `dmd/en/` (`0375-ball-3-drained-gameover`, both drawn by the same code-cave text routine the tournament mod's patch installs — `scripts/io_moon_press_start_patch.py`) |

**The credit award is the one thing that tells this `PRESS START` apart from an ordinary
`D5123` ending, and it is real, not asserted.** `scripts/nvcheck.py` against the run's own
`iomoont.nv`: NVRAM's triplicated credit byte (`0x083`/`0x116`/`0x20C`, F10) reads `0, 0, 0`
before the game (a fresh, wiped NVRAM: one coin inserted, one credit spent to start) and
`1, 1, 1` after it — a genuine, majority-agreeing write, not a partial or corrupted one.

## Distinguishing all three `PRESS START` occurrences

- **The boot seed screen** — `dmd/en/screens.csv` scene `0002-unlabelled`, ms 416-449,
  "SETTING / DEFAULT VALUES / PRESS START": the recoverable EEPROM-check path
  (`sub_D53C9`, `docs/press_start_patch.md`-adjacent, also `dmd/faults/README.md`'s
  `EEPROM FAILURE` item for the *un*recoverable sibling), reached on every fresh NVRAM,
  never through the tournament mod's own patched hooks at all.
- **The `D5123` end-of-game hook** — `dmd/en/screens.csv` scene
  `0375-ball-3-drained-gameover`, ms 252699, an ordinary non-qualifying game's own ending:
  no SPECIAL animation precedes it (the scene immediately before it is ordinary
  in-play/HUD content, not a Monolith graphic or a digit reveal), and NVRAM's credit byte
  is unchanged across it.
- **The `D5077` SPECIAL/match hook** — this capture, scene `0300-ball-3-drained-gameover`,
  ms 172199: preceded by the Monolith/train graphic and the digit-`5` reveal above, and
  landing with NVRAM's own credit byte incremented by exactly one. Same drawn text as
  `D5123`'s occurrence (the mod's patch installs one shared code cave for both hooks —
  `scripts/io_moon_press_start_patch.py`), reached down a visibly different, longer path.

## Reproducing this capture

```bash
cd pinmame
git diff --stat src/wpc/sleic.c   # confirm clean before starting
```

Apply the one-byte-opcode probe above inside `MACHINE_INIT(SLEIC2)` in
`src/wpc/sleic.c`, right after `machine_init_SLEIC();`, then:

```bash
cp cmake/sdl3pinmame/CMakeLists.txt CMakeLists.txt
cmake -DPLATFORM=linux -DARCH=x64 -DCMAKE_BUILD_TYPE=Release -B build
cmake --build build -j$(nproc)

rm -f ~/.sdl3pinmame/cfg/iomoont.cfg
SLEIC_FORCE_MATCH=1 SDL_VIDEODRIVER=dummy SDL_AUDIODRIVER=dummy ./build/sdl3pinmame iomoont \
  -rompath ./roms -nvram_directory /tmp/nv-special -nosound \
  -skip_disclaimer -skip_gameinfo -skip_gamewarnings -nothrottle -ftr 20000 \
  -dmd_dump_dir ../sleic-iomoon/dmd/special \
  -key_script ../sleic-iomoon/scripts/keyscripts/iomoon-special.keys

python3 ../sleic-iomoon/scripts/nvcheck.py /tmp/nv-special/iomoont.nv   # confirm credits: 1,1,1

git checkout -- src/wpc/sleic.c   # revert the probe
cmake --build build -j$(nproc)    # rebuild clean before doing anything else
```

`scripts/dmd_dump_split.py` (from `sleic-iomoon/`) with `--rom` pointed at the extracted
`v1_3_01t.bin` splits `dmd/special/iomoont.txt` into `screens.csv` and the committed
`screens/*/repr.txt` the same way it does for `en/`, `es/` and `faults/`.

## Layout

Same conventions as `dmd/en/` and `dmd/faults/` (see `../README.md`): `iomoont.txt.gz` is
the raw frame dump (Serum/Pin2DMD format, gzipped), `iomoont.marks` is the driving key
script's mark sidecar, `screens.csv` is one row per scene occurrence, and
`screens/<NNNN-label>/repr.txt` is one representative frame per distinct screen —
committed; `frame-*.txt` is not (`.gitignore`).

`scripts/keyscripts/iomoon-special.keys` is the driving key script — an ordinary
three-ball game with no attempt at any particular score, since the probe above makes the
score irrelevant to the outcome; its own header comment states that plainly.

## Open

- **Whether the digit-`5` scene (`0299-ball-3-drained-gameover`) is literally the drawn
  lottery number, or a different animation frame that happens to show a `5`, is not
  confirmed against the ROM's own drawing routine.** It is a strong candidate: it is the
  only digit-shaped content in the whole SPECIAL sequence, sitting exactly where a
  lottery-number reveal would belong, and no such screen was previously identified
  anywhere in `dmd/en/` or `dmd/es/` despite both containing an ordinary game's own
  `PRESS START` ending. What would settle it: tracing the routine that draws it (not
  identified here) against `sub_D4FDC`'s own disassembly, and checking whether the digit
  shown tracks `4000:113F`'s value at the moment of the match — which needs the same
  memory-watch tooling the stability question above is still waiting on.
- **The lottery counter's stability under the controlled digit swap is not established
  either way** — see above. The sweep that would settle it needs a genuine breakpoint or
  memory watch on `4000:113F`, not available headlessly with what this round had access
  to.
