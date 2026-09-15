# The SPECIAL/match capture

[← Back to the DMD corpus overview](../README.md)

The tournament mod's second `PRESS START` hook, inside the SPECIAL/match handler at
`D5077` (`scripts/io_moon_press_start_patch.py` calls it "hook inside SPECIAL handler,
before animation starts"), reached by a **real lottery win**: a free game the firmware
awards itself, against the shipped `build/sdl3pinmame` with no ROM patch and no driver
probe. NVRAM's triplicated credit byte (`0x083`/`0x116`/`0x20C`, F10) reads `0, 0, 0`
before the game — one coin in, one credit spent to start — and `1, 1, 1` after it, a
majority-agreeing write decoded with `scripts/nvcheck.py`.

## The rule, cited

`sub_D4CF4` (`D4CF4`) runs once per game, from the end-of-ball state machine's own
game-over dispatch (`sub_D3145`, its call into `sub_D46F8` at `D3237`, itself gated on
`sub_D3920` signalling no balls left). For a one-player game it divides the player's own
score-digit cell `413C:0016` by 10 and compares the remainder, at `D4DCB`, against work
RAM `4000:113F`. On equality `sub_D4FDC` is called with `n=1`: it banks a credit
(`nvstore_write_triple_83`, a real NVRAM write) and runs the SPECIAL animation through the
`D5076`/`D5077` trampoline the mod's `PRESS START` patch hooks. On inequality the game ends
through the mod's other hook, at `D5123`.

**The rule holds exactly, over 104 complete games:** `[4000:113F] == [413C:0016] mod 10`
at the compare predicted whether the credit was banked in 104 of 104 trials, with no
exceptions either way (the sweep below; every trial's own compare read directly, every
trial's NVRAM decoded afterwards).

## The counter — `4000:113F`

**The timer-0 ISR is its only writer.** A write watch on the byte across a full game logs
exactly two writing addresses, `D030E` and `D0315`, both inside the timer-0 handler (F3):
`D0315` increments, `D030E` stores the wrap back to `0`. Nothing else in either ROM writes
it, and only one other address ever reads it — `D4DC4`, the compare above, once per game.

**Its value is the number of *delivered* timer-0 ticks, mod 10.** Counted directly: the
number of ISR writes up to the compare, mod 10, equals the value the compare read, in every
trial.

**It is not a function of elapsed time, and not independent of play.** Ticks that come due
while the firmware has interrupts masked are lost, and how many are lost depends on what
the firmware is doing. Eight games on one fixed event schedule, differing only in which
targets the twelve scoring slots hit, reached the compare at the same millisecond and had
delivered between **15,335 and 15,341** ticks — against **16,513** nominal ticks for the
same 166.494 s at 99.18 Hz, so about 7% never arrive. Six ticks of spread is six different
counter values for the same wall-clock instant.

The *number* of dropped ticks is emulation-specific: `iomoon_irq_gen`
(`pinmame/src/wpc/sleic.c`) keeps one pending request per source and defers it while `IF`
is clear, so a second tick coming due before the first is served replaces it. The 80188's
own timer has a single interrupt-request latch per source too, so late service loses ticks
on hardware as well — but the rate at which it does is **not established here**.

## Aiming a match

Two independent controls, both needed, because the counter is not fixed.

**The score's units digit.** Each of the twelve scoring slots in the key script presses
either a lane (`KEYCODE_Y`, 100,000 — every lane's award ends in zero,
`docs/iomoon_game_rules.md` §3.3.1) or the inner bank / *Fondo Bancada* (`KEYCODE_I`,
50,001, §3.3.6). Measured at the compare, `[413C:0016]` equals the number of inner-bank
slots **exactly**, for every count from 0 to 12: at 10, 11 and 12 slots it reads 10, 11 and
12, and the match lands against counter `0`, `1` and `2`. So what the cell holds is the units
digit **unreduced**, which is why `sub_D4CF4` divides rather than compares. A watch on the
cell shows it is not incremented in place during play: it is cleared at `DCA08` and set at
`DCA82`, once at each ball's end and again at game over, then read immediately by a drawing
routine at `F0A87` — the score line the draw puts above the digit. What `DCA82` computes it
from is not established.
Four slots per ball also keeps every ball above the 100,000 short-ball replay threshold
(F10 `0x43`) whichever key each slot takes — four inner banks still score 200,004.

**A whole-game time shift.** Every event from the coin press onward moved N frames later
leaves the score untouched and moves the counter.

## The sweep

13 digit values × 8 one-frame shifts, each a complete single three-ball game against a
freshly wiped NVRAM. The counter each trial's own compare read, with the matching trials in
bold:

| inner-bank slots | +0 | +1 | +2 | +3 | +4 | +5 | +6 | +7 |
|---|---|---|---|---|---|---|---|---|
| 0 (digit 0) | 5 | 3 | 5 | 3 | 5 | 7 | 2 | 5 |
| 1 (digit 1) | 6 | 4 | 5 | 8 | 4 | 9 | 4 | 6 |
| 2 (digit 2) | 7 | 4 | 5 | 9 | 7 | 1 | 5 | 6 |
| 3 (digit 3) | 7 | 4 | 4 | 0 | 8 | 2 | 5 | 7 |
| 4 (digit 4) | 1 | 5 | 5 | 1 | 7 | 3 | **4** | 8 |
| 5 (digit 5) | 9 | **5** | 4 | 3 | 8 | 4 | 6 | 8 |
| 6 (digit 6) | 1 | **6** | 5 | 3 | 9 | 5 | 7 | 9 |
| 7 (digit 7) | 0 | 6 | 6 | 5 | 1 | 6 | 8 | 0 |
| 8 (digit 8) | 9 | 7 | 7 | 7 | 2 | 7 | **8** | 9 |
| 9 (digit 9) | 0 | 6 | 7 | 7 | 4 | **9** | **9** | **9** |
| 10 (digit 0) | 1 | 7 | 7 | 9 | 6 | 1 | **0** | 1 |
| 11 (digit 1) | 3 | 7 | 8 | 0 | 5 | 2 | **1** | **1** |
| 12 (digit 2) | **2** | 8 | 0 | 1 | 8 | **2** | 1 | 1 |

Twelve of the 104 landed the free game, 11.5%, against the 10% the mechanism implies and
the "roughly 20%" §3.5 states for the machine. The counter moves with both controls and
monotonically with neither, which is the reason a sweep over the digit alone cannot be
treated as a ten-way search against a fixed target.

## This capture

`scripts/keyscripts/iomoon-special.keys`: five inner-bank slots, every game event shifted
one frame. The compare lands at ms 166494 with counter `5` and score digit `5`.

## What the panel shows, and what the match does not change

**The end-of-game lottery reveal is the same in a matching and a non-matching game.** All
three scenes below appear in an ordinary ending too:

| ms | Scene | Content |
|---|---|---|
| 166566-167366 | `0311-lottery` | a Monolith/train graphic — **byte-identical** to `dmd/en/screens/0373-lottery/repr.txt`, from a non-matching ending |
| 167399-171949 | `0312-lottery` | the final score, and below it a full-panel digit |
| 172199 | `0313-special-press-start` | `PRESS START` |

**The full-panel digit is the lottery number, and it is the counter's own value.** Five
games, each with its counter read at its own compare and its panel then read back:

| Game | Counter at the compare | Digit drawn |
|---|---|---|
| this capture | `5` | `5` (`dmd/special/screens/0312-lottery`) |
| nine inner-bank slots, five-frame shift (also a match) | `9` | `9` |
| all-lane slots, no shift (no match) | `5` | `5` |
| `dmd/en/`'s own first game, ms 246038 | `4` | `4` (`dmd/en/screens/0374-lottery`) |
| `dmd/en/`'s own second game, ms 1628730 | `7` | `7` (`dmd/en/screens/5219-score-lottery`) |

The last two are decisive because that capture was made before any of this work and aimed
at nothing: the counter simply landed where it landed, and the panel followed it. Nothing
else on the panel differs between the matching and non-matching runs but the score line.

**In a game that qualifies for a high score the draw runs *after* name entry, not before
it.** `dmd/en/`'s second game ends, walks the name-entry wheels, and only then reaches its
compare at ms 1628730 and its draw at ms 1628800 — the opposite order to its first game's.

**What a match does change on the panel is when `PRESS START` arrives:** ms 172199 here,
250 ms after the digit reveal ends, against ms 173299 — 1.35 s after it — in the all-lane,
unshifted game that does not match, because this occurrence comes from the `D5077`
trampoline and that one from the `D5123` hook.

## Distinguishing all three `PRESS START` occurrences

- **The boot seed screen** — `dmd/en/screens.csv` scene `0002-unlabelled`, ms 416-449,
  "SETTING / DEFAULT VALUES / PRESS START": the recoverable EEPROM-check path
  (`sub_D53C9`; `dmd/faults/README.md` covers the unrecoverable sibling), reached on every
  fresh NVRAM and never through the mod's patched hooks at all.
- **The `D5123` end-of-game hook** — `dmd/en/screens.csv` scene
  `0375-press-start-normal`, ms 252699: 1.35 s after the digit reveal ends, NVRAM's
  credit byte unchanged across it, and it **releases on the first START press** — the press
  returns the machine to attract, where the high-score table and the feature ads follow.
- **The `D5077` SPECIAL/match hook** — this capture, scene `0313-special-press-start`,
  ms 172199: 250 ms after the digit reveal ends, NVRAM's credit byte incremented by exactly
  one, and it **does not release on START**. The four taps in this capture (ms 174983,
  191649, 208316 and 224983 — `iomoont.marks`) leave the panel unchanged, and the dump ends
  with the same frame it reached at 172199; nine taps across 140 s in a longer run of the
  same configuration do the same. The drawn text is identical to the `D5123` occurrence,
  which is expected: the mod installs one shared code cave for both hooks.

## Reproducing this capture

No probe and no patch — the shipped release build.

```bash
cd pinmame
rm -f ~/.sdl3pinmame/cfg/iomoont.cfg
SDL_VIDEODRIVER=dummy SDL_AUDIODRIVER=dummy ./build/sdl3pinmame iomoont \
  -rompath ./roms -nvram_directory /tmp/nv-special -nosound \
  -skip_disclaimer -skip_gameinfo -skip_gamewarnings -nothrottle -ftr 15000 \
  -dmd_dump_dir ../sleic-iomoon/dmd/special \
  -key_script ../sleic-iomoon/scripts/keyscripts/iomoon-special.keys

python3 ../sleic-iomoon/scripts/nvcheck.py /tmp/nv-special/iomoont.nv   # credits: 1,1,1
```

`scripts/dmd_dump_split.py` (from `sleic-iomoon/`) with `--rom` pointed at the extracted
`v1_3_01t.bin` splits `dmd/special/iomoont.txt` into `screens.csv` and the committed
`screens/*/repr.txt`, the same way it does for `en/`, `es/` and `faults/`. Copy the key
script's own `.marks` sidecar to `dmd/special/iomoont.marks` first, so the scenes are
labelled.

## How the counter was measured

The counter claims above come from a watch on `4000:113F`, added to
`pinmame/src/wpc/sleic.c` for the measurement and reverted afterwards — `pinmame`'s own
tree carries none of it, the convention `dmd/faults/README.md` documents for its probes.
It is an observer: the read handler returns the same byte the RAM read would have, and the
write handler stores what the write would have stored, so the machine behaves identically
with it installed. **The capture itself needs none of this.**

```c
/* before MACHINE_INIT(SLEIC2) */
static FILE *iomoon_watch_fp;
static READ_HANDLER(iomoon_watch_113f) {
  const UINT8 * const ram = memory_region(SLEIC_MEMREG_CPU);
  if (iomoon_watch_fp)
    fprintf(iomoon_watch_fp, "%d %05X cnt=%u d16=%02X\n",
            (int)(timer_get_time() * 1000.0), (unsigned)activecpu_get_pc(),
            ram[0x4113f], ram[0x413d6]);
  return ram[0x4113f];
}
static WRITE_HANDLER(iomoon_watch_113f_w) {
  UINT8 * const ram = memory_region(SLEIC_MEMREG_CPU);
  if (iomoon_watch_fp)
    fprintf(iomoon_watch_fp, "%d %05X W=%u was=%u\n",
            (int)(timer_get_time() * 1000.0), (unsigned)activecpu_get_pc(),
            data, ram[0x4113f]);
  ram[0x4113f] = data;
}

/* at the end of MACHINE_INIT(SLEIC2) */
{ const char *w = getenv("SLEIC_WATCH_MATCH");
  if (w && *w && !iomoon_watch_fp) {
    iomoon_watch_fp = fopen(w, "w");
    install_mem_read_handler (0, 0x4113f, 0x4113f, iomoon_watch_113f);
    install_mem_write_handler(0, 0x4113f, 0x4113f, iomoon_watch_113f_w);
  } }
```

A byte-wide handler installed over one address of a `MRA_RAM`/`MWA_RAM` range is enough
here because the 80188 has an 8-bit data bus (`CPU0(I188, i188, …, 8, 20, …)`,
`src/cpuintrf.c`), so `install_mem_read_handler` is the right flavour and every data access
to that byte goes through it.

## Layout

Same conventions as `dmd/en/` and `dmd/faults/` (see `../README.md`): `iomoont.txt.gz` is
the raw frame dump (Serum/Pin2DMD format, gzipped; the dump writes a frame only when the
panel content changes, which is why a screen the machine holds still is one frame),
`iomoont.marks` is the driving key script's mark sidecar, `screens.csv` is one row per
scene occurrence, and `screens/<NNNN-label>/repr.txt` is one representative frame per
distinct screen — committed; `frame-*.txt` is not (`.gitignore`).

## Why the `D5077` screen never releases

Settled, by watching `4000:1147`, `4000:1150` and the inbound FIFO at `4000:1220` (F6)
across a matching and a non-matching game driven by the same presses.

The mod's code cave releases only when `ES:[1147h]` is non-zero *and* the byte at
`ES:[[1150h]]` reads `0x40`, the START switch code
(`scripts/io_moon_press_start_patch.py`); otherwise it clears `[1147h]` and loops.
`[4000:1150]` is the inbound FIFO's **read cursor**, and the two sides of it move on
different threads: the NMI resets it to `0x1220` when it appends to an empty FIFO
(`D01BE`, then `D01C0` stores the byte), while only main-loop code advances it past a byte
it has consumed (`D74EF`, `D8006`).

- **Non-matching game.** The main loop is still draining when the game ends — the cursor
  last moves at ms 170782 — so the FIFO is empty when START arrives at ms 175000. The NMI
  resets the cursor to `0x1220` and writes `0x40` there; the cave reads `0x40` and returns.
- **Matching game.** The last cursor motion is at ms 164014, where the NMI put a `0xFF`
  at `4000:1220`. The main loop never consumes it — it goes into `sub_D4FDC` and then into
  the cave — so the cursor stays on that `0xFF`. START at ms 175001 is received (the NMI
  sets `[1147h]` to `0xFF` at `D01C9`, and does so again for every later press) but its
  `0x40` is appended at `4000:1223`, three slots past where the cave looks. The cave reads
  `0xFF`, rejects it, clears `[1147h]` and loops.

So the presses are not missed: they are read and rejected, every time. It is a deadlock by
construction rather than a timing accident — once the cave holds the main loop with a
byte other than `0x40` under the cursor, nothing can advance the cursor, and no press can
ever satisfy the test.

This is reproducible here on every run, and the FIFO discipline it turns on is the
firmware's own. Whether a real tournament machine hangs the same way on a matched free
game has not been checked on hardware.

## Open

- **Whether a real tournament machine hangs on a matched free game the way this one does is
  not established.** The cause above is firmware logic, but the byte traffic that leaves the
  FIFO unconsumed comes from the Z80 over J1, and that half is modelled. What would settle
  it: matching the lottery on a real machine and seeing whether START clears the screen.
- **Whether real hardware drops timer-0 ticks at the same rate is not established** — see
  the counter section. What would settle it: timing the lottery digit's advance on a real
  machine against its own clock, or a scope on the timer-0 interrupt line.
