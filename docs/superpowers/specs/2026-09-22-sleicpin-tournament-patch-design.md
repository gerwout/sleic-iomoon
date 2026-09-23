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

**2. Two players per row, with a digit font carried in the cave.** Both ROM fonts
are 8 px wide, giving sixteen characters per line, and the 8-row font's four lines
consume all thirty-two rows — so a four-player screen drawn with the stock font
leaves nowhere for a prompt. Measured: the glyph ink is 7 px in an 8 px cell and 7
rows in an 8-row cell, one spare column and one spare row, so tightening the pitch
to 7 px makes adjacent glyphs touch and is unreadable. Rendering it proved that.

The patch therefore carries its own **4 px × 7 row digit font**, ten glyphs, 70
bytes, drawn at a 5 px pitch by a small bit-shifting blitter in the cave. Digit
*height* is unchanged from stock — only the width drops — so legibility holds.
Player labels use the machine's own 8-row font. Four scores and a steady prompt
then fit with room to spare:

```
+--------------------------------+
| 1  12.345.670   2   1.234.560  |
|                                |
| 3      12.340   4         120  |
|                                |
|         PULSE START            |
+--------------------------------+
```

Nothing alternates and nothing is ever hidden. Rejected: one player per row in the
stock font, which needs no new code but must alternate player 4's score with the
prompt, hiding a score one second in three.

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

### The injection point — OPEN

The approved design said the cave installs itself into `[0000:0281]`. That rested on
a premise the measurement refutes, so the injection mechanism is **open** and needs a
decision before Phase 2 starts. The candidates:

1. **Repoint step 23** of the `E000:4F7C` table at a small stub in segment E000 that
   far-calls an `F000` cave, then falls through to the stock `E000:5090`. Keeps the
   cooperative, non-blocking property by simply *not advancing* `[0000:017D]` until
   START arrives — the same trick the approved design wanted, in the variable that
   actually drives the sequence. The `F000` cave can still make the near calls to the
   draw routines.
2. **Hook `F000:0B02`'s entry**, its sole caller path. Simpler and stays entirely in
   `F000`, but a wait there is a blocking hold of the Bike Race kind, which this
   design rejected on the grounds that an indefinite stall of the 80188 main loop is
   untested on this machine.

Option 1 preserves the property the design was chosen for. Option 2 is smaller.
Steps 0-18 and 24-25 of the table are not yet traced, which is the main unknown
weighing against option 1.

Nothing blocks. Interrupts, the J1 link service and the screen refresh all keep
running for as long as the player takes — which on a tournament machine may be
minutes. A blocking hold of the Bike Race kind was the alternative and is kept as
the fallback if the handler contract proves opaque. The reason to prefer the handler
is simply that an indefinite stall of the 80188 main loop is untested on this
machine, and the ROM already contains the idiom that avoids needing to test it.
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
| narrow digit font | 70 B | ten 4 × 7 glyphs |
| narrow blitter | ~80 B | draw a digit string at 5 px pitch with bit shifting |
| score formatter | ~40 B | 32-bit binary → decimal digits, most significant first, leading zeros suppressed |
| `PULSE START` record | ~24 B | `word count` + eleven glyph pointers |

### Primitives the cave uses

| address | calling convention |
|---|---|
| `F000:015E` | draw a string record, 10-row font. `SI` = record, `DI` = buffer offset. Sets `ES` itself. Near. |
| `F000:550D` | the same, 8-row font. Near. |
| `F000:0E8C` | draw one 10-row glyph by index in `AL`; computes `SI = 0x83D9 + 10*AL`. Caller sets `ES`. Near. |
| `F000:54EF` | pop one switch code, returned in `AL`, zero meaning the queue is empty. **Far.** |

String records are a `word` count followed by that many `word` glyph pointers,
resolved against CS = F000. Fonts: 10 rows at `F000:83D9`, 8 rows at `F000:85EB`,
both 8 px wide, one byte per row, MSB leftmost. Glyph index 0–9 are the digits,
10 is space, 11 onward are `A`–`Z` with `Ñ` at 25.

The display buffer is segment `0x6000`, visible area from offset `0x410`, row
stride `0x20`, sixteen bytes used per row, second plane at `+0x800`. Row *r*,
byte column *c* is `0x410 + r*0x20 + c`.

### Data

Scores are **32-bit little-endian binary**, confirmed twice: the default record
table at `F000:8085` on a `0x20` stride holds 3,000,000, 2,000,000 and 1,000,000
behind the names `CRABY`, `ZIPI` and `ZAPE`, and a live RAM diff found the playing
player's score at `0000:01C5` rising by 5,000 per lane hit, matching manual §3.13.

The manual caps the in-game display at 99,999,999 even though a score may reach
999,999,999, so the screen shows up to nine digits and inherits no new limit.

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
