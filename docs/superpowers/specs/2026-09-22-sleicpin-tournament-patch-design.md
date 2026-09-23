# Sleic Pin-Ball — tournament (PRESS START) patch, design

Status: design agreed, not implemented. Free play is a **separate** patch with its
own spec; nothing here depends on it and the two must stack in either order, as
they do on Io Moon and Bike Race.

## What this patch does

At the end of a game, Sleic Pin-Ball shows no final scores. Measured in emulation
on a one-ball game, the whole post-game sequence is self-paced and takes about
eighteen seconds:

| stage | duration | what is on the panel |
|---|---|---|
| bonus count-up | ~9.3 s | eight steps, the finishing player's score |
| `FIN DEL JUGADOR n` | ~2.1 s | flashing, no score |
| `LOTERIA` | ~5.7 s | the free-game mini-game (manual §3.15) |
| attract | — | logo and `CREDITOS n` |

Nothing waits for input and nothing holds a score, so there is no moment at which
a tournament can read or photograph the result. This patch inserts one screen that
shows every player's final score and holds it until START is pressed.

Unlike the Io Moon and Bike Race patches, which freeze a score screen the firmware
already draws, this one has to **compose a screen that does not exist**. That is
the substance of the work.

## Scope

Added: one screen, between the continue offer and `LOTERIA`.

Unchanged: the bonus count-up, `FIN DEL JUGADOR`, the `¿ CONTINUAS ?` offer, the
`LOTERIA` mini-game, record name entry, attract, and every free-game award the
machine makes. The patch does not make the machine stricter; it only adds a hold.

## The three decisions

**1. Hold the scores, leave the rest alone.** The same contract as the Io Moon and
Bike Race patches. Considered and rejected: suppressing the lottery and the replay
threshold to make a stricter competition build, and skipping everything after the
bonus count so the scores are the last image before attract. Both change documented
machine behaviour for a benefit the operator has not asked for.

**2. Two scores per row in the machine's own font, and no player labels.** The
8-row face at `F000:85EB` holds 50 glyphs — `0`-`9`, space at index 10, then `A`
onward with `Ñ` at 25 — in 8 px × 8 row cells, so a 128 px row is exactly sixteen
cells and the 32-row panel is exactly four bands of eight rows.

A score is eight digits, so it is eight cells, half a row. Two scores fill a band
exactly and the four players need two bands, which leaves two bands over:

```
+--------------------------------+
| 12345670         1234560       |   band 0:  player 1   player 2
|                                |
|    12340             120       |   band 1:  player 3   player 4
|                                |
|                                |   band 2:  blank
|          PRESS START           |   band 3:  the prompt
+--------------------------------+
```

The player is identified by position — top-left, top-right, bottom-left,
bottom-right — rather than by a label, and leading zeros are blanked so each score
right-aligns in its half. A one-, two- or three-player game simply leaves the
later positions empty.

This choice is what keeps the cave small. **Every glyph lands on a byte
boundary**, so the blitter is the plain byte copy the ROM's own digit renderers
already use (`mov es:[di], al`, `add di, 0x20` per row) with no bit shifting
across byte boundaries — and no font has to be designed, drawn or carried, since
the same face draws the digits and the prompt.

Rejected: **carrying a 4 px × 7 row digit font** at a 5 px pitch to make room for
`1`-`4` labels beside each score. It reads slightly better, but it needs a
shift-and-OR blitter, which is the most error-prone assembly in the cave, plus 70
bytes of hand-drawn glyphs — for a label that position already conveys. Also
rejected: **one player per row in the stock font with labels**, which needs no new
code but consumes all four bands, leaving the prompt to alternate with player 4's
score and hiding a score one second in three.

**3. The screen sits after the `¿ CONTINUAS ?` offer resolves.** That offer is
itself START-gated (manual §3.14, above 1,000,000 points, ten-second timeout, and
in a multiplayer game *all* players must continue). Putting the new screen before
it would place a START press one screen ahead of another START-gated prompt, where
a duplicate code — which one press can produce, see below — would accept the
continuation and spend a credit. Ordering the screen after the offer removes that
failure entirely: if the player continues, the game is not over and the screen
correctly never fires. Below 1,000,000 points the offer never appears and the
screen follows `FIN DEL JUGADOR` directly.

## Architecture

### Two mechanisms, not one

**Measured, and it corrects an earlier reading of this section.** The ROM has two
separate mechanisms and the patch must use the right one.

`[0000:0281]` is a real, reusable *animation* dispatcher: it holds a handler
offset in segment `F000`, `[0000:027F]` a tick delay, `[0000:027E]` a flag, and
`[0000:0283]`/`[0000:0285]` per-screen parameters. The continue prompt uses it —
`F000:5056` draws `¿ CONTINUAS ?` from the record at `F000:533E` and installs
`F000:5092`, which decrements the ten-second counter at `[0000:02C6]`, redraws the
digit and re-installs itself with `[0000:027F] = 0xFA`. But it animates *within* a
screen; it does not sequence one screen to the next.

**The end-of-game sequence is a step table in segment E000**, a run of 26 word-sized
near offsets at `E000:4F7C` indexed by a step counter at `[0000:017D]`. Step 23 is
`E000:5090`:

```
E000:5090   9a fc de 00 f0    lcall F000:DEFC   ; clear the display buffer
E000:5095   9a 02 0b 00 f0    lcall F000:0B02   ; the LOTERIA setup
```

`F000:0B02` is referenced exactly once in the whole image — that call. An exhaustive
scan for writes of `0x0B02` into `[0000:0281]` finds none, so **`LOTERIA` is not
installed as a `[0281]` handler** and a patch cannot insert itself by that route.

### The injection point

The end-of-game sequence is a table of near offsets at `E000:4F7C` indexed by
`[0000:017D]`, dispatched with **no bounds check**:

```
E000:4F69  be7c4f      mov si, 0x4f7c
E000:4F6C  3ea17d01    mov ax, [0x17d]
E000:4F73  f7e2        mul dx           ; DX = 2
E000:4F75  03f0        add si, ax
E000:4F77  2e8b04      mov ax, cs:[si]
E000:4F7A  ffe0        jmp ax
```

The table runs to entry 25 at `E000:4FAE` (code begins at `E000:4FB0`, where
entries 1 and 13 jump), but the advance tail wraps at `0x18`, so incrementing
never reaches 25, and none of the six writes to `[017D]` in the image produces 25
either. **Entry 25 is a spare slot stock firmware cannot index.**

The patch uses it:

| path | index | what runs |
|---|---|---|
| a real game ends | **25** | the patch's stub, which holds the screen |
| attract's free-run | 23 | stock step 23, untouched |

The game-over path is `E000:1919`, called from the game-end sequence at
`E000:09C9` just before `[0103]` is cleared. It branches on a game counter in
NVRAM (`cmp byte es:[0x66d], 0x0a`) into **two tails**, each a 7-byte
`mov word ds:[0x17d], imm` followed by `ret`: `E000:197C` sets 23 for nine games
in ten, and `E000:1962` sets 1 on every tenth game, after resetting the counter.
The patch redirects **both** to 25 — hooking only the common tail would skip the
score screen on one game in ten — and each trampoline records the index its tail
would have written, so the stub can hand control back to the right step. Attract free-runs the whole table on a
~5760-frame period and holds step 23 for about 200 frames each lap, so leaving
entry 23 alone is what keeps the screen out of attract — **structurally**, not by
a guard that has to be right. `[0103]`, the in-game flag, reads `0x00` in attract
too, so it could not have made that distinction on its own.

Holding is a `ret` that skips the advance tail at `E000:50D5`: `[017D]` stays 25
and the dispatcher re-enters the stub on the next tick, with every interrupt, the
J1 link service and the screen refresh still running for as long as the player
takes. Releasing writes the recorded index back into `[017D]` and returns, so the next
tick runs exactly the step the game would have run, whichever tail it came from.
The stub never jumps into another step's code.

The stub lives in segment E000 because the table entry is a near offset there, at
`E000:50EB`, the start of a 44,821-byte `0xFF` run reaching the end of the
segment. The drawing code stays in F000, which it must, to near-call `F000:550D`
and read the face at `F000:85EB` through `CS`.

Rejected: **repointing entry 23** and gating on `[0103]`, which cannot tell a
finished game from attract and would have shown the screen every ~96 seconds in
attract. Also rejected: **hooking `F000:0B02`'s entry**, its sole caller path —
smaller and entirely within F000, but a wait there is a blocking hold of the Bike
Race kind, and an indefinite stall of the 80188 main loop is untested on this
machine.

(The VDB coil-current watchdog is *not* an argument either way: it is scanned on
the Z80's port 0x87 and read back on `IN 0x01`, so it keeps running whatever the
80188 does.)

### Cave placement

The three draw routines end in a **near** `ret`, so they can only be called from
within segment F000. The cave therefore lives in the 7,815-byte run of `0xFF` at
**F000:DFF0–F000:FE76**. A second 44,821-byte run at E000:50EB–FFFF is available if
anything ever needs segment E000, but nothing here does. Space is not a constraint;
the whole cave is expected to be 250–400 bytes.

### Components

| component | size (est.) | what it does |
|---|---|---|
| screen handler | ~120 B | draw once, re-install, poll START, chain on |
| digit-string blitter | ~30 B | draw eight glyphs from a RAM digit buffer in the 8-row face |
| score digit reader | ~30 B | reverse a block's eight digits, blank the leading zeros |
| `PRESS START` record | 24 B | `word count` + eleven glyph pointers, drawn by `F000:550D` |

No font and no bit-shifting blitter: the machine's own 8-row face draws both the
digits and the prompt, and at an 8 px pitch every glyph is byte-aligned.

### Primitives the cave uses

| address | calling convention |
|---|---|
| `F000:550D` | **draw a whole string record in the 8-row face.** `SI` = record, `DI` = buffer offset. Sets `ES = 0x6000` itself. Reads the count word and each glyph pointer through `CS`, advances `DI` by one byte per glyph, and copies eight rows per glyph at a `0x20` stride. Near `ret`. |
| `F000:015E` | the same for the 10-row face. `SI` = record, `DI` = buffer offset. Sets `ES` itself. Near. |
| `F000:0E8C` | draw one 10-row glyph by index in `AL`; computes `SI = 0x83D9 + 10*AL`. Caller sets `ES`. Near. |
| `F000:DEFC` | clear the display buffer. Far. |
| `F000:54EF` | pop one switch code, returned in `AL`, zero meaning the queue is empty. **Far.** |

`F000:550D` reads its record through `CS`, so it can only draw a string that is
**static in ROM**. That is exactly right for the prompt and unusable for a score,
whose digits are only known at run time — hence the cave's own small blitter,
which is the same eight-row copy loop reading its glyph index from RAM instead.

String records are a `word` count followed by that many `word` glyph pointers,
resolved against `CS = F000`. Fonts: 10 rows at `F000:83D9` (stride 10), 8 rows at
`F000:85EB` (stride 8), both 8 px wide, one byte per row, MSB leftmost, 50 glyphs
each. Glyph index 0-9 are the digits, 10 is space, 11 onward are `A`-`Z` with `Ñ`
at 25 — so a glyph's address in the 8-row face is `0x85EB + 8*index`, which is how
the ROM's own score renderers index it.

The display buffer is segment `0x6000`, visible area from offset `0x410`, row
stride `0x20`, sixteen bytes used per row, second plane at `+0x800`. Row *r*, byte
column *c* is `0x410 + r*0x20 + c`. The four bands of the screen therefore start at
`0x410`, `0x510`, `0x610` and `0x710`.

The screen is drawn into **both planes**, at `DI` and `DI+0x800`. The driver models
the panel's two raster fields as equal and the core integrates them, so a pixel set
in one plane only renders at half brightness — which is what the stock in-game
score does, drawing into the second plane alone at `0xC13`. Writing both planes
costs one extra call per string and makes the screen full brightness.

### Data

A **playing** score is stored as **eight unpacked decimal digits**, one per
byte, most significant digit at the highest address, at offsets `+4` to `+11`
of that player's block. The blocks are the five-entry table at `E000:190F` —
`0x1C5` live, then `0x1E7`, `0x209`, `0x22B`, `0x24D` for players 1 to 4 —
indexed by the 1-based `[0000:0105]`, with 31 bytes copied in and out of the
live block at every handoff (`E000:18CD` / `E000:18EE`). So the screen reads
digits directly and needs **no binary-to-decimal conversion**.

The **high-score** records are a different structure: the default table at
`F000:8085` on a `0x20` stride holds 3,000,000, 2,000,000 and 1,000,000 as
32-bit little-endian binary behind the names `CRABY`, `ZIPI` and `ZAPE`. The
score screen does not read those.

Eight digits caps a displayed score at 99,999,999, which is also the cap the
manual prints for the in-game display, so the screen inherits no new limit.

## What must be measured before implementation

Six items. None is expected to be hard; the first five are blocking.

1. **The per-player score array.** `0000:01C5` is confirmed but is probably the
   playing player's slot rather than the base of a four-entry array. Find the array
   and its stride by RAM diff across a multi-player game.
2. **The player count**, to know how many rows to draw.
3. **The handler transition into `LOTERIA`**, which is the interception point, and
   the original next-handler offset the cave has to preserve and restore.
4. **The meaning of `[0000:027E]`, `[0000:0283]` and `[0000:0285]`**, so the cave
   sets them the way the surrounding screens expect.
5. **A full-stop test for game over.** `FIN DEL JUGADOR n` fires at the end of
   every ball, not only the last, so the trigger needs a guard that distinguishes
   the end of the game from the end of a ball — the equivalent of Bike Race's
   `[0116:0099]` state byte and `[0116:0072]` player count.
6. **Whether the screen has to be redrawn on every tick.** The design draws once
   and then only polls, which is correct if nothing else repaints the buffer while
   the cave's handler owns the chain. The stock handlers do redraw, so confirm
   whether that is because something clears the buffer underneath them or merely
   because they animate. If something does clear it, the cave redraws each tick and
   the only cost is cycles.

Minor: confirm which glyph index is `.` in the 8-row font, for the thousands
separators in the mockup. The punctuation indices are 37 upward and not yet mapped.
Spaces are an acceptable fallback.

## Prerequisite

**The SLEIC1 ball-trough model in the PinMAME driver has to land first.** Sleic
Pin-Ball's trough is one contact (C29 Salida Bolas, `swMatrix[1]` bit 2) and one
coil (11 Bobina Salida Bolas, port `0x86` bit 6, which `sleic1_z80_write` maps to
`locals.solenoids` bit 10 — PinMAME solenoid 11, numbered so the solenoid number
equals the manual's bobina number), and without a model that follows
the coil there is no repeatable way to drive a two-to-four player game to game
over. Items 1, 2 and 5 above all need such a game, and so does testing the patch.
This is an enabler, not a side quest.

## Safety and failure modes

- **A duplicate START code.** One physical press can put more than one `0x05` in
  the FIFO: the Z80's cabinet scan has no time-based debounce, and a press during
  the bonus count-up queues a code before the screen is reached. Ordering the
  screen after the continue offer means a leftover code can only reach `LOTERIA`,
  which is flipper-driven and ignores START, so nothing is spent or started. The
  cave still drains queued `0x05` codes before chaining, as cheap insurance rather
  than a load-bearing defence.
- **A game that continues.** The screen fires only after the continue offer has
  been declined or timed out, so a continued game never reaches it.
- **Power-on and the service menu.** The trigger guard must keep the screen out of
  the boot path and out of menu teardown, the failure the Bike Race patch had to
  fix explicitly: an unguarded wait there swallows the first START press and no
  game can be started at all.
- **A stuck handler.** If the cave's handler is installed but its poll never sees
  START, the machine sits on the score screen indefinitely. That is the intended
  behaviour, and it is what the operator wants, but it means the screen must never
  be installed outside a real game over.

## Verification

Headless, with `-key_script` and every DMD frame dumped, from an identical warm
store each run:

- the screen appears at game over at one, two, three and four players, with each
  player's score correct against the scores the bonus count-up showed
- one START press releases it and `LOTERIA` follows, exactly as stock
- a press reported twice does not disturb anything downstream
- above 1,000,000 points the continue offer still appears, still accepts START and
  still times out at ten seconds; declining it leads to the new screen
- accepting the continue offer does **not** show the screen, and the game continues
- a record-beating score still reaches name entry after the lottery
- three games back to back each show their own scores
- power-on is not blocked and the service menu still opens and closes
- `MAME_DEBUG` `validitychecks()` pass

## Not in this patch

Free play. Sleic Pin-Ball has no free-play adjustment — the CREDITOS page added by
the manual's `MONEDERO ELECTRONICO` addendum is coin pricing only, with a minimum
of one coin per credit, and the CPU DIP block carries just two functions, VDB
monitoring and the initial coil test (§7.2.2.3). The approach will mirror Bike
Race's: find the one place every credit value is read and floor it at 1. That is a
separate spec.
