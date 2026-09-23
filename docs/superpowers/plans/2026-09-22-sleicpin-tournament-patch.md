# Sleic Pin-Ball Tournament Patch Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Patch Sleic Pin-Ball's `sp03` ROM so the end of a game shows every player's final score and holds it until START is pressed.

**Architecture:** A code cave in `sp03`'s `0xFF` padding, installed as a handler in the ROM's own cooperative screen state machine rather than as a blocking hold. The cave composes a screen the firmware does not have: two 8-digit scores per row in the machine's own 8-row font, no player labels, with a steady `PRESS START` on the bottom band. It polls the switch FIFO for code `0x05` and chains to the original next-handler when it arrives.

**Tech Stack:** Python 3 (the patch script, matching the other `scripts/*_patch.py`), 8086/80188 assembly hand-assembled into a Python byte list and cross-checked with `nasm`, PinMAME (`build-probe/sdl3pinmame` with `DEBUG_SLEIC`) for headless verification with `-key_script` and `SLEIC_DMD_DUMP`.

**Spec:** `docs/superpowers/specs/2026-09-22-sleicpin-tournament-patch-design.md`

## Global Constraints

- Target ROM: `sp03-1_1.rom`, 131,072 bytes, CRC32 `261b0ae4`. Maps to physical `0xE0000-0xFFFFF`, so **`F000:xxxx` = file offset `0x10000+xxxx`** and `E000:xxxx` = file offset `xxxx`.
- The cave lives in segment **F000** only, in the `0xFF` run at `F000:DFF0-F000:FE76` (7,815 bytes). The ROM's draw routines end in a near `ret` and cannot be called from segment E000.
- Patch must be **idempotent**, must refuse a ROM whose CRC32 is not in its accepted family unless `--any-version` is passed, and must refuse to write if its cave space is neither empty (`0xFF`) nor already its own bytes. Mirror `scripts/bike_race_press_start_patch.py` exactly for this behaviour.
- Patch must be **independent of the free-play patch** — different hooks, different caves — so the two stack in either order and give the same bytes either way.
- Repository documentation rule: **present truth only**, present tense, evidence cited by address or findings number. No project-history narrative in `sleic-iomoon/` docs. A superseded claim gets corrected, not annotated with when it changed.
- **No AI attribution** in any commit message or PR text.
- Every numeric claim in a docstring or doc must be one this plan's tasks actually measured. Mark inference as inference.

---

## Prerequisite, not part of this plan

**The SLEIC1 ball-trough model in `pinmame/src/wpc/sleic.c` must land first.** Sleic Pin-Ball's trough is one contact (C29 Salida Bolas, `swMatrix[1]` bit 2, key `E`) and one serve coil (11 Bobina Salida Bolas, port `0x86` bit 6, which `sleic1_z80_write` maps to `locals.solenoids` bit 10 — PinMAME solenoid 11, numbered to match the manual's bobina). Without a model that follows the coil there is no repeatable way to drive a 2–4 player game to game over, and Tasks 2, 4 and 12 all need one. That work is a PinMAME driver change in a separate repository and gets its own plan.

**Do not start Task 2 until a keyscript can reliably take a 4-player game from START to attract.**

---

## File Structure

| File | Responsibility |
|---|---|
| `pinmame/src/wpc/sleic.c` | Task 1 only: add `SLEIC_RAMDUMP`/`SLEIC_RAMAT` to the existing `DEBUG_SLEIC` probe set. No other change. |
| `sleic-iomoon/research/sleicpin_disasm/sleicpin_endgame.md` | New. The Phase 1 findings: score array, player count, handler contract, game-over guard. The constants Phase 2 consumes. |
| `sleic-iomoon/scripts/sleic_pin_ball_press_start_patch.py` | The patch: cave byte blobs, hook bytes, CRC family, validation, application. One file, same shape as the two Bike Race patch scripts. |
| `sleic-iomoon/scripts/tests/test_sleicpin_press_start.py` | Plain-`python3` assert tests: the `nasm` cross-check of every cave blob, plus CRC gating, idempotence and foreign-image refusal. No pytest — the repo has no test framework and this needs none. |
| `sleic-iomoon/scripts/keyscripts/sleicpin-*.keys` | The verification runs for Task 12. |
| `sleic-iomoon/roms/related-machines/sleic-pin-ball - press start/` | Task 13: the patched chip and its README. |
| `sleic-iomoon/roms/pinmame/sleicpinp.zip` | Task 13: the PinMAME set. |

---

# Phase 1 — Measurement

Five tasks. Each produces a **verified constant or answer** recorded in
`research/sleicpin_disasm/sleicpin_endgame.md`. Phase 2 consumes them by name.
Do not guess any of these values; a wrong address here produces a patch that
corrupts a live game.

## Phase 1 constants already settled

Recorded with their evidence in
[`research/sleicpin_disasm/sleicpin_endgame.md`](../../../research/sleicpin_disasm/sleicpin_endgame.md).
Phase 2 consumes these values; the tasks below that produced them need not be
re-run.

| Plan name | Value | Task |
|---|---|---|
| `SCORE_BASE` | `0x01EB` — player 1's least significant digit | 2 |
| `SCORE_STRIDE` | `0x22` | 2 |
| score format | **8 bytes, one unpacked decimal digit each, most significant digit at the highest address** (`base+7` = the `10^7` place) | 2 |
| `PLAYER_COUNT` | `[0000:0106]`, 1..4 | 2 |
| `GUARD_ADDR` | `[0000:0103]` — the in-game flag | 4 |
| `GUARD_TEST` | `0xFF` while a game is running, `0x00` once it is over: set at `E000:0706`, cleared at `E000:09DC` | 4 |
| `GLYPH_PERIOD` | `44` (`43` = comma, `44` = period, `45` = semicolon) | 5 |
| current player | `[0000:0105]`, 1-based | 2 |
| credit count | cache `[0000:0100]`, authority the triplicated NVRAM byte `0x140`/`0x141`/`0x142`, loader `E000:1463` | — |

Two things this changes for Phase 2:

- **The ROM already has four 8-digit score renderers**, `F000:4234`, `43C5`,
  `4556` and `46E7`, one per player, each self-contained and taking no
  arguments. They draw one player per row at a hardcoded position in the second
  plane (`0xC13`, `0xD13`, `0xE13`, `0xF13`), four bands filling the panel
  exactly, so they cannot be reused for a screen that also carries a prompt.
  What they supply is the worked draw loop and the proof of how the face is
  indexed: `0x85EB + 8*digit`.
- **`F000:550D` draws a whole string record in that same face** and sets
  `ES = 0x6000` itself, but reads the record through `CS`, so it draws static
  ROM strings only. That covers the prompt; the scores need the cave's own
  copy of the same loop reading digits from RAM (Task 7).
- **`REDRAW_PER_TICK` is `false`** (Task 5), so a cave that draws once and then
  only polls is correct.

The **injection point** is settled too, and it is better than repointing step 23:
the table at `E000:4F7C` has a **spare entry 25** that stock firmware can never
index, because the advance tail wraps at `0x18` and no write to `[0000:017D]`
anywhere in the image produces 25. The patch points entry 25 at an `E000` stub
and redirects the game-over write at `E000:197C` from `0x17` to 25, leaving entry
23 — the one attract's free-run reaches — untouched. The sequence stays
cooperative because the stub returns without advancing `[0000:017D]`. The spec's original `[0000:0281]` route does not reach `LOTERIA` —
nothing writes a LOTERIA address into `[0281]`, and `F000:0B02` is referenced
exactly once in the image. Phase 2's first verification is that a no-op stub at
step 23 leaves the stock sequence unchanged; steps 0-18 and 24-25 of the table
are untraced and are the residual unknown.

### Task 1: RAM-dump probe in the driver

> **Resolved.** The answer is in the Phase 1 constants table above and in
> `research/sleicpin_disasm/sleicpin_endgame.md`. The steps below are the
> recipe that produced it and do not need re-running.

**Files:**
- Modify: `pinmame/src/wpc/sleic.c` — add a function beside `sleic_debug_switches`, call it from `SWITCH_UPDATE(SLEIC1)`
- Test: manual, by running the probe and checking the file appears with the right size

**Interfaces:**
- Consumes: nothing
- Produces: env vars `SLEIC_RAMDUMP=<prefix>` and `SLEIC_RAMAT=<f1,f2,…>`; writes `<prefix>.<frame:06d}.bin`, 0x2000 bytes, the 80188 work RAM at physical 0

- [ ] **Step 1: Read the existing probe set first**

Read `pinmame/src/wpc/sleic.c` around the `#ifdef DEBUG_SLEIC` block that
defines `sleic_debug_switches` (search for `SLEIC_DMD_DUMP`). Match its style:
`getenv` per call, no state beyond a static frame counter, everything inside
`#ifdef DEBUG_SLEIC`, and `//#define DEBUG_SLEIC` stays commented out at
`sleic.c:31` so nothing ships compiled in.

- [ ] **Step 2: Add the probe**

Insert immediately before `static SWITCH_UPDATE(SLEIC1) {`:

```c
#ifdef DEBUG_SLEIC
/* Dump the 8 KB of 80188 work RAM (physical 0, MRA_RAM) at each frame named in
 * SLEIC_RAMAT, as <SLEIC_RAMDUMP>.<frame>.bin.  Diffing two dumps across a
 * scoring event is how the score and credit variables were located */
static void sleic1_ramdump(void) {
  const char *pfx = getenv("SLEIC_RAMDUMP"), *at = getenv("SLEIC_RAMAT");
  static int frame = 0;
  char fn[512];
  FILE *fp;
  const char *p;
  frame++;
  if (!pfx || !at) return;
  for (p = at; *p; ) {
    const int f = strtol(p, (char **)&p, 10);
    if (f == frame) {
      snprintf(fn, sizeof fn, "%s.%06d.bin", pfx, frame);
      if ((fp = fopen(fn, "wb"))) {
        fwrite(memory_region(REGION_CPU1), 1, 0x2000, fp);
        fclose(fp);
      }
    }
    while (*p && *p != ',') p++;
    if (*p == ',') p++;
  }
}
#endif
```

and as the first statement inside `SWITCH_UPDATE(SLEIC1)`:

```c
#ifdef DEBUG_SLEIC
  sleic1_ramdump();
#endif
```

- [ ] **Step 3: Build with the probes enabled**

```bash
cd /home/gerwout/iomoon/pinmame
cmake --build build-probe -j$(nproc) 2>&1 | grep -E "error|warning: .*DEBUG_SLEIC|Built target sdl3pinmame"
```
Expected: `Built target sdl3pinmame`, no errors and no warnings.

`build-probe` is configured with `-DDEBUG_SLEIC` in `CMAKE_C_FLAGS`, so it
compiles the probes with the source untouched. Do **not** uncomment
`sleic.c:31` as well — the define is then redefined and the compile warns.

- [ ] **Step 4: Verify it writes**

```bash
S=$(mktemp -d); mkdir -p $S/nv $S/cfg $S/ram
printf '600 mark boot\n900 quit\n' > $S/t.keys
SDL_VIDEODRIVER=dummy SDL_AUDIODRIVER=dummy SLEIC_RAMDUMP=$S/ram/r SLEIC_RAMAT=500,800 \
  ./build-probe/sdl3pinmame sleicpin -rompath roms -nvram_directory $S/nv \
  -cfg_directory $S/cfg -nosound -skip_disclaimer -skip_gameinfo -nothrottle \
  -key_script $S/t.keys -ftr 1000 >/dev/null 2>&1
ls -l $S/ram/
```
Expected: two files, each exactly 8192 bytes.

- [ ] **Step 5: Restore the shipped default and commit**

```bash
cd /home/gerwout/iomoon/pinmame
grep -n '^//#define DEBUG_SLEIC' src/wpc/sleic.c    # must print line 31, untouched
cmake --build build -j$(nproc) 2>&1 | grep -E "error|Built target sdl3pinmame"
git add src/wpc/sleic.c
git commit -m "sleic: add a work-RAM dump probe for Sleic Pin-Ball

SLEIC_RAMDUMP plus SLEIC_RAMAT write the 8 KB of 80188 work RAM at named
frames.  Diffing two dumps across a scoring event is how the playing player's
score was located at 0000:01C5; the same technique finds the per-player array,
the player count and the credit store.  Gated on DEBUG_SLEIC like every other
probe here, so nothing ships compiled in."
```

Commit on a branch off `master`, not on `bikerace-freeplay-pressstart`.

---

### Task 2: Locate the per-player score array and the player count

> **Resolved.** The answer is in the Phase 1 constants table above and in
> `research/sleicpin_disasm/sleicpin_endgame.md`. The steps below are the
> recipe that produced it and do not need re-running.

**Files:**
- Create: `sleic-iomoon/research/sleicpin_disasm/sleicpin_endgame.md`
- Create: `sleic-iomoon/scripts/keyscripts/sleicpin-4p-scores.keys`

**Interfaces:**
- Consumes: Task 1's `SLEIC_RAMDUMP`; the trough model from the prerequisite plan
- Produces: `SCORE_BASE` (word, offset in segment 0), `SCORE_STRIDE` (bytes), `PLAYER_COUNT` (byte offset in segment 0). Phase 2 consumes all three.

**Answer:** `[0000:01C5]` is the **live player block**, swapped in and out of
four saved blocks listed in the word table at `E000:190F` (`0x1E7`, `0x209`,
`0x22B`, `0x24D`, stride `0x22`), and the score inside a block is **eight
unpacked decimal digits** at `+4` (units) to `+11` (`10^7`). The 32-bit
little-endian dwords at `F000:8085` are the separate high-score records, not
the playing score.

- [ ] **Step 1: Write a 4-player keyscript that gives each player a different score**

Create `scripts/keyscripts/sleicpin-4p-scores.keys`. Four START presses to
select four players, then per player a *distinct* number of lane hits so the
four scores are unmistakably different — 1 hit, 2, 3 and 4 gives 5,000 / 10,000
/ 15,000 / 20,000. Drain between players with the trough model's drain key
(`KEYCODE_BACKSPACE`). Dump RAM after the fourth player's score is up and again
after game over. Keys: START `1`, coin `5`, lanes `Q`/`W`/`A`, drain `BACKSPACE`.

- [ ] **Step 2: Run it**

```bash
cd /home/gerwout/iomoon/pinmame
S=$(mktemp -d); mkdir -p $S/nv $S/cfg $S/ram
SDL_VIDEODRIVER=dummy SDL_AUDIODRIVER=dummy \
  SLEIC_RAMDUMP=$S/ram/r SLEIC_RAMAT=<after-p4>,<after-gameover> \
  ./build-probe/sdl3pinmame sleicpin -rompath roms -nvram_directory $S/nv \
  -cfg_directory $S/cfg -nosound -skip_disclaimer -skip_gameinfo -nothrottle \
  -key_script ../sleic-iomoon/scripts/keyscripts/sleicpin-4p-scores.keys -ftr <n>
```

- [ ] **Step 3: Find the four values in one dump**

```python
import struct, pathlib
d = pathlib.Path('r.<after-p4>.bin').read_bytes()
want = [5000, 10000, 15000, 20000]
hits = {v: [o for o in range(len(d)-4) if struct.unpack_from('<I', d, o)[0] == v]
        for v in want}
for v, offs in hits.items():
    print(v, [hex(o) for o in offs])
# a 4-entry array shows as four offsets in arithmetic progression
for o in hits[want[0]]:
    for stride in (4, 5, 6, 8, 0x10, 0x20):
        if all(struct.unpack_from('<I', d, o + k*stride)[0] == want[k] for k in range(4)):
            print(f'ARRAY base {o:#06x} stride {stride}')
```
Expected: exactly one `ARRAY base … stride …` line. Record it as `SCORE_BASE`
and `SCORE_STRIDE`.

- [ ] **Step 4: Find the player count**

In the same dump, search bytes `0x0000-0x0400` for the value 4, then re-run the
keyscript with only **two** players selected and intersect: the player count is
a byte that reads 4 in the first dump and 2 in the second.

```python
a = pathlib.Path('r4.bin').read_bytes(); b = pathlib.Path('r2.bin').read_bytes()
print([hex(o) for o in range(0x400) if a[o] == 4 and b[o] == 2])
```
Expected: a short list; pick the one that also reads 1 in a one-player run.
Record it as `PLAYER_COUNT`.

- [ ] **Step 5: Write the findings document and commit**

Create `research/sleicpin_disasm/sleicpin_endgame.md` with a `## Score storage`
section giving the block table, the per-block digit layout and `PLAYER_COUNT` as
CPU addresses, together with the evidence for each.

```bash
cd /home/gerwout/iomoon/sleic-iomoon
git add research/sleicpin_disasm/sleicpin_endgame.md scripts/keyscripts/sleicpin-4p-scores.keys
git commit -m "research: locate Sleic Pin-Ball's per-player scores and player count"
```

---

### Task 3: Decode the screen-handler contract and find the interception point

> **Resolved.** The answer is in the Phase 1 constants table above and in
> `research/sleicpin_disasm/sleicpin_endgame.md`. The steps below are the
> recipe that produced it and do not need re-running.

**Files:**
- Modify: `sleic-iomoon/research/sleicpin_disasm/sleicpin_endgame.md`

**Interfaces:**
- Consumes: nothing from earlier tasks
- Produced: the semantics of `[0000:027E]`-`[0285]`, and the finding that the
  end-of-game sequence is the `[0000:017D]` table at `E000:4F7C` rather than a
  `[0281]` handler chain — so the hook is the two-byte table entry at
  `E000:4FAA`, and `HOOK_SITE`/`HOOK_ORIGINAL`/`NEXT_HANDLER` as framed below do
  not apply. The steps below are the recipe that established that.

**Known starting point:** `[0000:0281]` is the next handler's offset,
`[0000:027F]` a tick delay, `[0000:027E]` a flag. The worked example is the
continue prompt: `F000:5056` sets it up and installs `F000:5092`, which
decrements `[0000:02C6]` from 10, redraws, re-installs itself with
`[0000:027F] = 0xFA`, and chains on. `F000:0B0D` references the `- LOTERIA -`
string record at `F000:0B28`, so the lottery's setup routine is around
`F000:0B00`.

- [ ] **Step 1: Disassemble the lottery setup and the continue prompt properly**

The committed `sp03_80188_ndisasm.asm` is a flat linear sweep and mis-decodes
every data region — use it for orientation only. Do a recursive-descent pass
with capstone (`CS_ARCH_X86`, `CS_MODE_16`) seeded at `F000:0B00` and
`F000:5056`, following calls and branches, or use `/code/dasmxx/src/dasmx86`.

- [ ] **Step 2: Identify the transition into the lottery**

Find the instruction that writes the lottery setup routine's offset into
`[0000:0281]`. That write is `HOOK_SITE`; the value written is the original
next-handler. Record the exact bytes at that site as `HOOK_ORIGINAL` — the cave
must run them or reproduce their effect.

- [ ] **Step 3: Establish what the three parameter bytes mean**

For each of `[0000:027E]`, `[0000:0283]` and `[0000:0285]`, collect every site
that writes it and what it writes, then state the meaning. `F000:5087`-`F000:5091`
sets `[0285] = 0x0711`, `[027F] = 0`, `[027E] = 0xFF` — a buffer offset, a delay
and an arm flag respectively is the hypothesis; confirm or correct it.

- [ ] **Step 4: Confirm by observation, not just by reading**

Add a temporary trace to the driver (under `DEBUG_SLEIC`, reverted afterwards)
printing `[0281]`, `[027F]` and `[027E]` once per frame, and run a game to game
over. The handler chain should be visible as a sequence of `[0281]` values.
Confirm the lottery's setup offset appears where Step 2 predicts.

- [ ] **Step 5: Record and commit**

Add a `## The screen state machine` section to `sleicpin_endgame.md`: the five
variables with their meanings, the observed handler chain at game over as a list
of offsets, `HOOK_SITE`, `HOOK_ORIGINAL` and `NEXT_HANDLER`. Revert the trace.

```bash
git add research/sleicpin_disasm/sleicpin_endgame.md
git commit -m "research: decode Sleic Pin-Ball's screen-handler chain"
```

---

### Task 4: Settle the game-over guard

> **Resolved.** The answer is in the Phase 1 constants table above and in
> `research/sleicpin_disasm/sleicpin_endgame.md`. The steps below are the
> recipe that produced it and do not need re-running.

**Files:**
- Modify: `sleic-iomoon/research/sleicpin_disasm/sleicpin_endgame.md`

**Interfaces:**
- Consumes: Task 1's probe, Task 3's handler chain
- Produces: `GUARD_ADDR` and `GUARD_TEST` — the byte and the comparison that distinguish end-of-game from end-of-ball

**Why this matters:** `FIN DEL JUGADOR n` fires at the end of **every** ball. A
hook that fires there without a guard shows the score screen after every ball.
Bike Race's equivalents are the state byte `[0116:0099]` (4 = a game is running)
and the player count `[0116:0072]`.

- [ ] **Step 1: Dump RAM at the end of each ball and at game over**

Using the 4-player keyscript from Task 2, dump at the end of ball 1 for player 1
and again after the last ball of player 4. There should be a byte that differs
between "a ball ended" and "the game ended".

- [ ] **Step 2: Diff for the guard**

```python
import pathlib
ball = pathlib.Path('r.ball.bin').read_bytes()
over = pathlib.Path('r.over.bin').read_bytes()
print([(hex(o), ball[o], over[o]) for o in range(0x400) if ball[o] != over[o]])
```
Expected: a handful of candidates. Narrow by repeating at a different player and
ball number and keeping only the byte that behaves the same way each time.

- [ ] **Step 3: Cross-check against `[0000:0103]`**

The driver comment on `SWITCH_UPDATE(SLEIC1)` records that the tilt handler
"acts only in-game (`[0x103]!=0`)". Test whether `[0000:0103]` is the state byte
and whether it clears at game over — if so it is the guard and no search is
needed.

- [ ] **Step 4: Record and commit**

Add a `## Game over versus end of ball` section stating `GUARD_ADDR`,
`GUARD_TEST`, and the measurement over at least two different player counts.

```bash
git add research/sleicpin_disasm/sleicpin_endgame.md
git commit -m "research: distinguish Sleic Pin-Ball's game over from end of ball"
```

---

### Task 5: Settle the redraw question and the punctuation glyphs

> **Resolved.** The answer is in the Phase 1 constants table above and in
> `research/sleicpin_disasm/sleicpin_endgame.md`. The steps below are the
> recipe that produced it and do not need re-running.

**Files:**
- Modify: `sleic-iomoon/research/sleicpin_disasm/sleicpin_endgame.md`

**Interfaces:**
- Consumes: nothing
- Produces: `REDRAW_PER_TICK` (boolean), `GLYPH_PERIOD` (the 8-row font index of `.`)

- [ ] **Step 1: Determine whether anything clears the display buffer**

Every stock handler redraws. Establish whether that is because something clears
the buffer underneath them or merely because they animate: find every writer to
segment `0x6000` offsets `0x410`-`0xC0F` and check for a bulk clear. `F000:50FB`
is one candidate — it writes zeros in a nested loop.

- [ ] **Step 2: Confirm in emulation**

Install a trivial handler experiment: patch a throwaway image so a handler draws
a string once and then only re-installs itself with a delay, and dump DMD
frames. If the string persists, `REDRAW_PER_TICK` is false.

- [ ] **Step 3: Find the `.` glyph**

Render 8-row font indices 37-51 (base `F000:85EB`, stride 8) as ASCII and
identify the period. The manual's §4.2 character set is
`(space) A-Z with Ñ, + ¢ ( ) ' ? , . 0-9 . <-`, so punctuation follows the
letters.

```python
import pathlib
d = pathlib.Path('roms/related-machines/sleic-pin-ball/sp03-1_1.rom').read_bytes()
BASE, H = 0x185EB, 8
for i in range(37, 52):
    print(f'index {i}')
    for r in range(H):
        b = d[BASE + i*H + r]
        print('  ' + ''.join('#' if b & (0x80 >> k) else '.' for k in range(8)))
```
Expected: one glyph with ink only in the bottom-left — that is `.`. Record as
`GLYPH_PERIOD`. If no period exists in the 8-row face, the screen uses spaces as
separators and `GLYPH_PERIOD` is the space index 10.

- [ ] **Step 4: Record and commit**

```bash
git add research/sleicpin_disasm/sleicpin_endgame.md
git commit -m "research: settle Sleic Pin-Ball's buffer redraw and punctuation glyphs"
```

---

# Phase 2 — The cave

Every blob is hand-assembled into a Python byte list **and** cross-checked by
assembling the same source with `nasm`, byte for byte. That cross-check caught
two displacement errors in the Bike Race patch and is not optional.

### Task 6: Patch script skeleton and the assembler cross-check harness

**Files:**
- Create: `sleic-iomoon/scripts/sleic_pin_ball_press_start_patch.py`
- Create: `sleic-iomoon/scripts/tests/test_sleicpin_press_start.py`

**Interfaces:**
- Consumes: nothing
- Produces: module constants `ROM_BASE = 0xE0000`, `ROM_SIZE = 0x20000`, `V11_FAMILY_CRC32` (tuple), `CAVES` (tuple of `(physical_addr, bytes, label)`), `HOOKS` (tuple of `(physical_addr, original, patched, label)`), and the functions `physical_to_file(addr)`, `validate_rom(data, any_version)`, `is_already_patched(data)`, `apply_patches(data)` — the same names and signatures `bike_race_press_start_patch.py` uses.

- [ ] **Step 1: Write the failing test**

Create `scripts/tests/test_sleicpin_press_start.py`:

```python
#!/usr/bin/env python3
"""Byte-level tests for the Sleic Pin-Ball PRESS START patch. Run: python3 this."""
import importlib.util, pathlib, subprocess, sys, tempfile, zlib

HERE = pathlib.Path(__file__).resolve().parent
SCRIPTS = HERE.parent
ROM = SCRIPTS.parent / 'roms/related-machines/sleic-pin-ball/sp03-1_1.rom'

def load():
    spec = importlib.util.spec_from_file_location(
        'ps', SCRIPTS / 'sleic_pin_ball_press_start_patch.py')
    m = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(m)
    return m

def test_stock_rom_is_accepted():
    m = load()
    data = ROM.read_bytes()
    assert zlib.crc32(data) == 0x261b0ae4, 'wrong stock ROM'
    assert m.validate_rom(data, False) is True

def test_caves_fit_the_padding():
    m = load()
    data = ROM.read_bytes()
    for addr, blob, label in m.CAVES:
        off = m.physical_to_file(addr)
        assert 0 <= off and off + len(blob) <= len(data), f'{label} outside the ROM'
        assert all(b == 0xFF for b in data[off:off+len(blob)]), f'{label} space not empty'
        assert 0xFDFF0 <= addr and addr + len(blob) - 1 <= 0xFFE76, \
            f'{label} outside the F000:DFF0-FE76 padding'

def test_patch_is_idempotent():
    m = load()
    once = m.apply_patches(ROM.read_bytes())
    assert m.is_already_patched(once)
    assert m.apply_patches(once) == once

def test_foreign_rom_is_refused():
    m = load()
    junk = bytes(m.ROM_SIZE)
    assert m.validate_rom(junk, False) is False

if __name__ == '__main__':
    fails = 0
    for name, fn in sorted(globals().items()):
        if name.startswith('test_') and callable(fn):
            try:
                fn(); print(f'  PASS {name}')
            except AssertionError as e:
                fails += 1; print(f'  FAIL {name}: {e}')
    print('FAILED' if fails else 'OK')
    sys.exit(1 if fails else 0)
```

- [ ] **Step 2: Run it to verify it fails**

```bash
cd /home/gerwout/iomoon/sleic-iomoon && python3 scripts/tests/test_sleicpin_press_start.py
```
Expected: an import error, because the patch script does not exist yet.

- [ ] **Step 3: Write the script with empty cave blobs**

Copy the structure of `scripts/bike_race_press_start_patch.py` — module
docstring, `ROM_BASE`/`ROM_SIZE`/CRC family, `CAVES`/`HOOKS`, the four
functions, `main()` with `--output`/`--any-version` and the MD5/CRC32/SHA1
report. Set `CAVES` to a single one-byte placeholder blob at `0xFDFF0` and
`HOOKS` to an empty tuple for now; the blobs arrive in Tasks 7-11. Accept only
CRC32 `0x261b0ae4` in the family for now.

- [ ] **Step 4: Run the tests to verify they pass**

```bash
python3 scripts/tests/test_sleicpin_press_start.py
```
Expected: four `PASS` lines and `OK`.

- [ ] **Step 5: Commit**

```bash
git add scripts/sleic_pin_ball_press_start_patch.py scripts/tests/test_sleicpin_press_start.py
git commit -m "scripts: Sleic Pin-Ball PRESS START patch skeleton and its byte tests"
```

---

### Task 7: The digit-string blitter

**Files:**
- Modify: `sleic-iomoon/scripts/sleic_pin_ball_press_start_patch.py`
- Modify: `sleic-iomoon/scripts/tests/test_sleicpin_press_start.py`

**Interfaces:**
- Consumes: `CAVES` from Task 6
- Produces: a cave routine `digits_draw` at `DIGITS_DRAW_ADDR`, called with
  `SI` = an 8-byte digit buffer in segment 0 (values `0`-`9`, or `0xFF` for a
  blanked leading zero), `DI` = the buffer offset of the leftmost cell, and
  `ES` = `0x6000`; draws eight glyphs of the 8-row face at `F000:85EB`, one
  byte column apart, eight rows at a `0x20` stride, into **both** planes
  (`DI` and `DI+0x800`)

**No font and no bit shifting.** The face at `F000:85EB` is 8 px wide in 8 px
cells with 50 glyphs — digits, space at index 10, then `A` onward — so every
glyph is byte-aligned and a glyph's address is `0x85EB + 8*index`, exactly as
the ROM's own score renderers compute it. A blanked leading zero draws index 10
(space). This routine is the RAM-sourced twin of `F000:550D`, which does the
same copy but reads its glyph pointers through `CS` and so can only draw static
ROM strings.

- [ ] **Step 1: Write the failing test**

Add to the test file:

```python
def test_digits_draw_assembles_as_written():
    m = load()
    with tempfile.TemporaryDirectory() as t:
        src = pathlib.Path(t) / 'a.asm'; out = pathlib.Path(t) / 'a.bin'
        src.write_text(m.DIGITS_DRAW_ASM)
        subprocess.run(['nasm', '-f', 'bin', '-o', str(out), str(src)], check=True)
        assert out.read_bytes() == bytes(m.DIGITS_DRAW), 'byte list != nasm output'

def test_prompt_record_is_eleven_glyph_pointers():
    m = load()
    assert m.PROMPT_RECORD[:2] == bytes([11, 0]), 'count word is not 11'
    assert len(m.PROMPT_RECORD) == 2 + 22, 'record is not count + 11 words'
    # 'N with tilde' sits between N and O, so every letter from O on is one
    # higher than its position in the plain Latin alphabet would suggest.
    ALPHA = 'ABCDEFGHIJKLMN\u00d1OPQRSTUVWXYZ'
    for k, ch in enumerate('PRESS START'):
        idx = 10 if ch == ' ' else 11 + ALPHA.index(ch)
        ptr = int.from_bytes(m.PROMPT_RECORD[2+2*k:4+2*k], 'little')
        assert ptr == 0x85EB + 8*idx, f'glyph {k} ({ch!r}) points at {ptr:#06x}'
```

The eleven indices are `27 29 15 30 30 10 30 31 11 29 31` and the eleven pointers
are `0x86C3 0x86D3 0x8663 0x86DB 0x86DB 0x863B 0x86DB 0x86E3 0x8643 0x86D3
0x86E3` — confirmed by rendering those cells out of the ROM, where they read
`PRESS START`. Build the record from the alphabet in Python rather than typing
the pointers, so the test checks the generator.

- [ ] **Step 2: Run it to verify it fails**

Expected: `FAIL` — `DIGITS_DRAW_ASM` and `PROMPT_RECORD` are not defined.

- [ ] **Step 3: Write the blitter and the prompt record**

Build `PROMPT_RECORD` in Python from the string `PRESS START` and the index
scheme, so the test above checks the generator rather than a hand-typed table.

The blitter is one glyph loop around one row loop, the row loop being the copy
the ROM already uses (`mov al, cs:[si] / mov es:[di], al / add di, 0x20`), with
the second-plane write alongside it. Write it as `DIGITS_DRAW_ASM` and
hand-assemble it into `DIGITS_DRAW`.

- [ ] **Step 4: Run the tests**

```bash
python3 scripts/tests/test_sleicpin_press_start.py
```
Expected: all `PASS`.

- [ ] **Step 5: Commit**

```bash
git add scripts/sleic_pin_ball_press_start_patch.py scripts/tests/test_sleicpin_press_start.py
git commit -m "scripts: the Pin-Ball patch's digit blitter and PRESS START record"
```

---

### Task 8: The score reader

**Files:**
- Modify: `sleic-iomoon/scripts/sleic_pin_ball_press_start_patch.py`
- Modify: `sleic-iomoon/scripts/tests/test_sleicpin_press_start.py`

**Interfaces:**
- Consumes: the block table at `E000:190F` and the digit layout — player N's
  eight digits sit at `table[N]+4` (units) to `table[N]+11` (the `10^7` place)
- Produces: a cave routine `score_digits` at `SCORE_DIGITS_ADDR`, called with
  `BX` = a player's block base and `DI` = an 8-byte scratch buffer offset in
  segment 0; writes eight digit values `0`-`9` **most significant first**, with
  leading zeros replaced by `0xFF` to mean "draw nothing". Also produces
  `WORKSPACE_ADDR`, the single segment-0 scratch region this patch owns: 8 bytes
  of digit buffer plus 1 byte for the stub's `DRAWN` flag, so `DRAWN_ADDR` is
  `WORKSPACE_ADDR + 8`

**No divide loop.** The score is already eight unpacked decimal digits in
memory, so this is a reversing copy with leading-zero suppression, not a
binary-to-decimal conversion. The digit layout and the block table it sits in
are in "Per-player score storage" in
`research/sleicpin_disasm/sleicpin_endgame.md`.

**The workspace.** This patch needs 9 contiguous bytes of segment-0 RAM and must
claim them once, here, for every later task to use. Boot initialises segment 0
only from `0x0000` to `0x00FE`, and that block is the **interrupt vector table**
(255 bytes copied from `F000:FEF0`: every entry `F000:FFF0` except vector 2 at
`F000:DF20` and vector 8 at `F000:DF7F`), so the workspace must sit above
`0x100` and nothing initialises it at power-on — which is why the game-over
trampoline writes the `DRAWN` flag before the stub can run.

Choose `WORKSPACE_ADDR` inside a run of segment-0 bytes that **no direct-address
instruction in the image references**, neither the bytes themselves nor either
neighbour. Measured candidate runs above `0x100`: `0x377`-`0x3E7` (113 bytes),
`0x312`-`0x36E` (93), `0x43A`-`0x486` (77), `0x133`-`0x16C` (58). Take 9 bytes
well inside one of them and say in a comment which run it came from. Absence of a
direct reference is not proof the firmware never reaches the byte through an
index register — the per-player score blocks themselves are reached that way — so
record the choice as an unreferenced region, not a free one.

- [ ] **Step 1: Write the failing test**

```python
def test_score_digits_assembles_as_written():
    m = load()
    with tempfile.TemporaryDirectory() as t:
        src = pathlib.Path(t) / 'a.asm'; out = pathlib.Path(t) / 'a.bin'
        src.write_text(m.SCORE_DIGITS_ASM)
        subprocess.run(['nasm', '-f', 'bin', '-o', str(out), str(src)], check=True)
        assert out.read_bytes() == bytes(m.SCORE_DIGITS)
```

- [ ] **Step 2: Run it to verify it fails**

Expected: `FAIL` — `SCORE_DIGITS_ASM` undefined.

- [ ] **Step 3: Write the routine**

Read `[BX+11]` down to `[BX+4]`, storing forward into the scratch buffer, so the
buffer comes out most significant first. Then walk the buffer from the front
replacing zeros with `0xFF` until the first non-zero digit, leaving a score of
zero as a single `0` in the units position rather than eight blanks — the ROM's
own renderers draw nothing at all for a zero score, which is wrong for a score
screen. Write it as `SCORE_DIGITS_ASM` and hand-assemble it into `SCORE_DIGITS`.

- [ ] **Step 4: Verify against a Python model, then run the tests**

Model it in Python and check it on digit arrays the machine actually produces —
all zeros, `5000`, `15000`, `1_000_000`, `99_999_999` — asserting eight entries
with correct leading-`0xFF` suppression and that zero yields seven `0xFF` then
`0`. Then:

```bash
python3 scripts/tests/test_sleicpin_press_start.py
```
Expected: all `PASS`.

- [ ] **Step 5: Commit**

```bash
git add scripts/sleic_pin_ball_press_start_patch.py scripts/tests/test_sleicpin_press_start.py
git commit -m "scripts: the Pin-Ball patch's per-player score digit reader"
```

---

### Task 9: The screen composer

**Files:**
- Modify: `sleic-iomoon/scripts/sleic_pin_ball_press_start_patch.py`
- Modify: `sleic-iomoon/scripts/tests/test_sleicpin_press_start.py`

**Interfaces:**
- Consumes: Task 7's `digits_draw` and `PROMPT_RECORD`, Task 8's `score_digits` and `WORKSPACE_ADDR`, and `PLAYER_COUNT` at `[0000:0106]`
- Produces: a cave routine `draw_screen` at `DRAW_SCREEN_ADDR`, taking no arguments, which clears the display buffer and draws the whole screen

**The layout**, from the spec. The buffer is segment `0x6000`, visible from
offset `0x410`, row stride `0x20`, second plane at `+0x800`, so the four bands of
eight rows start at `0x410`, `0x510`, `0x610` and `0x710`. A score is eight
glyphs, eight byte columns, half of the sixteen a row holds:

| what | plane 1 | plane 2 |
|---|---|---|
| player 1 | `0x410` | `0xC10` |
| player 2 | `0x418` | `0xC18` |
| player 3 | `0x510` | `0xD10` |
| player 4 | `0x518` | `0xD18` |
| `PRESS START`, centred | `0x712` | `0xF12` |

Eleven glyphs centred in sixteen columns leaves a two-column left margin, hence
`0x712`. Band 2 (`0x610`) stays blank.

**Call `digits_draw` once per player, with the plane-1 offset only.** It writes
both planes itself, at `DI` and `DI+0x800`. The plane-2 column above is what it
produces, not a second call to make. `F000:550D` is the opposite — it writes one
plane per call — so the prompt takes two calls, at `0x712` and `0xF12`.

**Do not read the block table at `E000:190F`.** This routine lives in the F000
cave and runs with `CS = F000`, so a `cs:`-relative read of `0x190F` would fetch
`F000:190F`, not the table. The four block bases are constants: player *n* is at
`0x1E7 + 0x22*(n-1)`, so `0x1E7`, `0x209`, `0x22B`, `0x24D`. Either compute that
or keep a four-word table **inside the cave**, where `CS` reaches it.

**Registers on entry.** The stub far-calls this routine with `DS = 0`, which is
what `PLAYER_COUNT` and the score blocks need. Calling `F000:DEFC` first also
leaves `ES = 0x6000`, which is what `digits_draw` requires its caller to have
set — so clear the buffer before drawing anything, not after.

- [ ] **Step 1: Write the failing test**

```python
def test_draw_screen_assembles_as_written():
    m = load()
    with tempfile.TemporaryDirectory() as t:
        src = pathlib.Path(t) / 'a.asm'; out = pathlib.Path(t) / 'a.bin'
        src.write_text(m.DRAW_SCREEN_ASM)
        subprocess.run(['nasm', '-f', 'bin', '-o', str(out), str(src)], check=True)
        assert out.read_bytes() == bytes(m.DRAW_SCREEN)

def test_draw_screen_uses_the_documented_slots():
    m = load()
    for off in (0x410, 0x418, 0x510, 0x518, 0x712):
        assert off.to_bytes(2, 'little') in bytes(m.DRAW_SCREEN), f'{off:#05x} missing'
```

- [ ] **Step 2: Run it to verify it fails**

Expected: `FAIL` — `DRAW_SCREEN_ASM` undefined.

- [ ] **Step 3: Write the composer**

Far-call `F000:DEFC` to clear the buffer — it sets `ES = 0x6000` itself and
`stosb`s 0xFFF zero bytes from `DI = 0x410`, which covers `0x410`-`0x140E` and so
clears **both** planes in one call, ending in `retf`. Then for each player `1` to
`PLAYER_COUNT`, call `score_digits` with `BX` = that player's block base and
`DI` = `WORKSPACE_ADDR`, then call `digits_draw` with `SI` = `WORKSPACE_ADDR` and
`DI` = that player's plane-1 slot. Then draw the prompt twice with `F000:550D`,
at `0x712` and `0xF12`.

Both callees are **near** calls and both are in this same F000 cave or in F000
ROM, so `CS = F000` throughout. Mind the clobber lists in the two reports:
`score_digits` clobbers `AX/CX/SI` and restores `DI`; `digits_draw` clobbers
`AX/BX/CX/DX` and advances both `SI` and `DI` by 8. Neither preserves a loop
counter for you, so keep the player index somewhere they do not touch, or on the
stack.

Take the scratch digit buffer from `WORKSPACE_ADDR` (Task 8), not from the live
player block — the live block is real game state.

- [ ] **Step 4: Run the tests**

```bash
python3 scripts/tests/test_sleicpin_press_start.py
```
Expected: all `PASS`.

- [ ] **Step 5: Commit**

```bash
git add scripts/sleic_pin_ball_press_start_patch.py scripts/tests/test_sleicpin_press_start.py
git commit -m "scripts: the Pin-Ball patch's score-screen composer"
```

---

### Task 10: The hold stub

**Files:**
- Modify: `sleic-iomoon/scripts/sleic_pin_ball_press_start_patch.py`
- Modify: `sleic-iomoon/scripts/tests/test_sleicpin_press_start.py`

**Interfaces:**
- Consumes: Task 9's `draw_screen` (in the F000 cave) and Task 8's
  `DRAWN_ADDR` (= `WORKSPACE_ADDR + 8`)
- Produces: `STUB_ASM`/`STUB` and `STUB_ADDR`, a routine in **segment E000**
  reached as entry **25** of the `[0000:017D]` sequence table

**The mechanism.** The sequence dispatcher has **no bounds check**:

```
E000:4F57  cmp byte [0x27e], 0    ; a [0281] handler armed? then do nothing
E000:4F5D  je 0x4f60
E000:4F5F  ret
E000:4F60  cmp byte [0x2c1], 0
E000:4F66  je 0x4f69
E000:4F68  ret
E000:4F69  be7c4f      mov si, 0x4f7c   ; the table base
E000:4F6C  3ea17d01    mov ax, [0x17d]
E000:4F70  ba0200      mov dx, 2
E000:4F73  f7e2        mul dx
E000:4F75  03f0        add si, ax
E000:4F77  2e8b04      mov ax, cs:[si]
E000:4F7A  ffe0        jmp ax           ; NEAR jmp, so a step ends in ret
```

and the table has **a spare slot**. Entries run 0 to 25 at `E000:4F7C`-`4FAF`,
with code beginning at `E000:4FB0` (entries 1 and 13 both jump there). The
advance tail wraps at `0x18`:

```
E000:50D5  cmp word [0x17d], 0x18
E000:50DB  jne 0x50e5
E000:50DD  mov word [0x17d], 0     ; 24 wraps to 0
E000:50E4  ret
E000:50E5  inc word [0x17d]
E000:50EA  ret
```

so incrementing never produces 25, and no write to `[017D]` anywhere in the image
produces 25 either — the six writes are `1` (`E000:0075`), `1` (`E000:1962`),
`0x17` (`E000:197C`), `0` (`E000:50DE`), and two bare `inc`s (`E000:5051`,
`E000:50E6`). **Entry 25 at `E000:4FAE` is therefore unreachable in stock
firmware**, and it holds `0x5022`, a duplicate of entry 0.

That gives the patch a clean separation no state flag can match:

| path | index | what runs |
|---|---|---|
| a real game ends | **25** | the patch's stub |
| attract's free-run | 23 | stock step 23, untouched |

`E000:196A` is the game-over path: it bumps an NVRAM audit byte
(`inc byte es:[0x66d]` with `ES = 0x1000`), far-calls `F000:002C`, and then sets
`[017D] = 0x17` to jump the sequence to the LOTERIA screen. Redirecting **that
write** to 25 is what routes a finished game to the stub, while attract — which
free-runs the whole table on a ~5760-frame period and holds step 23 for about 200
frames each lap — reaches only the stock entry. The screen therefore **cannot**
appear in attract, structurally, rather than by a guard that has to be right.

Holding is a `ret` that skips the advance tail: `[017D]` stays 25 and the
dispatcher re-enters the stub next tick. Releasing sets `[017D] = 23` and jumps
to `0x5090`, so the stock step 23 draws LOTERIA and its own tail advances 23 to
24 exactly as it would have.

The stub must be in segment E000 because the table entry is a near offset there;
it lives at `E000:50EB`, the start of a 44,821-byte `0xFF` run reaching the end of
the segment. The drawing cave stays in F000 and is reached by `lcall`.

`DS` is already 0 on entry — every access in the dispatcher and in each step is a
`3E`-prefixed direct address in segment 0.

`F000:54EF` is verified to behave as this task assumes:

```
F000:54EF  3e8b36e504   mov si, ds:[0x4e5]     ; the FIFO read pointer
F000:54F4  3e8a04       mov al, ds:[si]
F000:54F7  22c0         and al, al
F000:54F9  740b         je 0x5506              ; empty
F000:54FB  3ec60400     mov byte ds:[si], 0    ; consume the slot
F000:54FF  46           inc si
F000:5500  3e8936e504   mov ds:[0x4e5], si
F000:5505  cb           retf
F000:5506  3ec606e40400 mov byte ds:[0x4e4], 0 ; empty: clear the pending flag
F000:550C  cb           retf                   ;   and return with AL = 0
```

So it needs `DS = 0`, clobbers `AX` and `SI`, returns `AL = 0` on an empty queue,
and is safe to call in a loop — which is what the drain below does.

**The one flag.** The stub is re-entered every tick while holding, so it needs to
know whether it has already drawn — redrawing would mean clearing and recomposing
the buffer under the panel's raster. `DRAWN_ADDR` is `WORKSPACE_ADDR + 8` from
Task 8, and the game-over trampoline writes it to 0 immediately before the stub
can ever run, so its power-on value is unreachable.

- [ ] **Step 1: Write the failing test**

```python
def test_stub_assembles_as_written():
    m = load()
    with tempfile.TemporaryDirectory() as t:
        src = pathlib.Path(t) / 'a.asm'; out = pathlib.Path(t) / 'a.bin'
        src.write_text(m.STUB_ASM)
        subprocess.run(['nasm', '-f', 'bin', '-o', str(out), str(src)], check=True)
        assert out.read_bytes() == bytes(m.STUB)

def test_stub_polls_the_switch_queue_far():
    m = load()
    assert bytes([0x9A, 0xEF, 0x54, 0x00, 0xF0]) in bytes(m.STUB), 'no far call to F000:54EF'

def test_stub_hands_back_to_the_stock_step_23():
    m = load()
    asm = m.STUB_ASM.lower()
    # the release path restores index 23 and rejoins the stock step
    assert '0x17d' in asm, 'stub never writes the sequence index'
    assert '0x5090' in asm, 'stub never rejoins the stock step 23'
    assert '0x50d5' not in asm, 'stub must not jump to the advance tail itself'

def test_workspace_is_above_the_vector_table():
    m = load()
    assert m.WORKSPACE_ADDR >= 0x100, 'the workspace would land in the vector table'
    assert m.DRAWN_ADDR == m.WORKSPACE_ADDR + 8, 'the flag is not the workspace tail'
```

- [ ] **Step 2: Run it to verify it fails**

Expected: `FAIL` — `STUB_ASM` undefined.

- [ ] **Step 3: Write the stub**

```
stub:   cmp byte [DRAWN_ADDR], 0
        jne poll                   ; already composed: just poll
        lcall F000:DEFC            ; clear both planes
        lcall F000:<draw_screen>   ; compose the screen once
        mov byte [DRAWN_ADDR], 1
        jmp hold
poll:   lcall F000:0x54EF          ; pop one switch code, AL = 0 when empty
        or al, al
        je hold                    ;   queue empty: keep holding
        cmp al, 5                  ; START
        jne poll                   ;   anything else: discard it and keep draining
drain:  lcall F000:0x54EF          ; scrub duplicate START codes before moving on
        or al, al
        jne drain
        mov word [0x17d], 0x17     ; hand the sequence back to the stock step 23
        jmp 0x5090                 ;   whose own tail advances 23 -> 24
hold:   mov word [0x4df], <dwell>  ; this step's dwell in ticks
        ret                        ; [017D] still 25: the stub runs again
```

Pick `<dwell>` small enough that START feels responsive — the draw happens once,
guarded by `DRAWN_ADDR`, so the dwell only paces the poll. Write it as `STUB_ASM`
with `org 0x50EB` and hand-assemble it into `STUB`.

The `drain` loop is this ROM's own idiom for a START press: the Z80 cabinet scan
has no time-based debounce, so one press can leave more than one `0x05` in the
FIFO, and an undrained duplicate would be consumed by whatever screen follows.
Bike Race needed exactly this and the patch was wrong without it.

- [ ] **Step 4: Run the tests**

```bash
python3 scripts/tests/test_sleicpin_press_start.py
```
Expected: all `PASS`.

- [ ] **Step 5: Commit**

```bash
git add scripts/sleic_pin_ball_press_start_patch.py scripts/tests/test_sleicpin_press_start.py
git commit -m "scripts: the Pin-Ball patch's hold stub and START poll"
```

---

### Task 11: The hook and the cave layout

**Files:**
- Modify: `sleic-iomoon/scripts/sleic_pin_ball_press_start_patch.py`
- Modify: `sleic-iomoon/scripts/tests/test_sleicpin_press_start.py`

**Interfaces:**
- Consumes: every earlier Phase 2 task
- Produces: the final `CAVES` and `HOOKS` tuples; a complete, applicable patch

**Two hooks, both tiny.**

1. **Table entry 25**, at `E000:4FAE`, reads `22 50` (`0x5022`, a duplicate of
   entry 0 that stock firmware can never index). The patch writes the stub's
   offset there.
2. **The game-over redirect**, at `E000:197C`, is `3e c7 06 7d 01 17 00` —
   `mov word ds:[0x17d], 0x17` — followed by `ret` at `E000:1983`. The patch
   replaces those seven bytes with a `jmp near` to a trampoline plus `0x90`
   padding. The trampoline sets `[017D] = 25`, clears `DRAWN_ADDR`, and `ret`s,
   which is the same `ret` the stock path took.

Entry 23 is **left alone**, which is what keeps the screen out of attract.

Two cave regions, so `CAVES` spans two padding runs:

| region | physical | holds |
|---|---|---|
| E000 padding | `0xE50EB` upward | `STUB`, the game-over trampoline |
| F000 padding | `0xFDFF0` upward | `DIGITS_DRAW`, `SCORE_DIGITS`, `PROMPT_RECORD`, `DRAW_SCREEN` |

- [ ] **Step 1: Write the failing test**

```python
def test_hooks_are_present_and_match_the_stock_rom():
    m = load()
    data = ROM.read_bytes()
    assert len(m.HOOKS) == 2, 'expected the table entry and the game-over redirect'
    for addr, original, patched, label in m.HOOKS:
        off = m.physical_to_file(addr)
        assert data[off:off+len(original)] == original, f'{label}: stock bytes differ'
        assert len(original) == len(patched), f'{label}: patch changes length'

def test_the_spare_table_entry_is_the_hook():
    m = load()
    by_addr = {addr: (o, p) for addr, o, p, _ in m.HOOKS}
    assert 0xE4FAE in by_addr, 'spare entry 25 of the E000:4F7C table is not hooked'
    original, patched = by_addr[0xE4FAE]
    assert original == bytes([0x22, 0x50]), 'stock entry 25 is not 0x5022'
    assert int.from_bytes(patched, 'little') == m.STUB_ADDR & 0xFFFF
    assert 0xE4FAA not in by_addr, 'entry 23 must be left alone, or attract shows the screen'

def test_the_game_over_write_is_redirected():
    m = load()
    by_addr = {addr: (o, p) for addr, o, p, _ in m.HOOKS}
    assert 0xE197C in by_addr, 'the game-over write to [017D] is not hooked'
    original, _ = by_addr[0xE197C]
    assert original == bytes([0x3E, 0xC7, 0x06, 0x7D, 0x01, 0x17, 0x00]), \
        'stock bytes at E000:197C are not mov word ds:[0x17d], 0x17'

def test_patched_rom_differs_only_in_caves_and_hooks():
    m = load()
    stock = ROM.read_bytes()
    patched = m.apply_patches(stock)
    allowed = set()
    for addr, blob, _ in m.CAVES:
        allowed |= set(range(m.physical_to_file(addr), m.physical_to_file(addr)+len(blob)))
    for addr, original, _, _ in m.HOOKS:
        allowed |= set(range(m.physical_to_file(addr), m.physical_to_file(addr)+len(original)))
    diff = {i for i in range(len(stock)) if stock[i] != patched[i]}
    assert diff <= allowed, f'{len(diff - allowed)} bytes changed outside cave and hook'
```

Note that `test_caves_fit_the_padding` from Task 6 asserts every cave sits inside
`0xFDFF0`-`0xFFE76`. Widen it to accept either padding run, keeping the assertion
that the space is `0xFF` before the patch writes it.

- [ ] **Step 2: Run it to verify it fails**

Expected: `FAIL test_hooks_are_present_and_match_the_stock_rom` — `HOOKS` is
empty, so the length assertion fires before the loop can pass vacuously.

- [ ] **Step 3: Lay out the caves and write the hook**

Assign the F000 blobs from `0xFDFF0` upward, and the stub plus the game-over
trampoline from `0xE50EB` upward. Re-assemble every blob with the real addresses
substituted and confirm the `nasm` cross-checks still pass.

Then write the two hooks described above. The trampoline's `jmp near`
displacement is relative to the end of the `jmp` at `E000:197F`, so compute it
from the final trampoline address rather than assuming one.

- [ ] **Step 4: Run the tests and apply the patch for real**

```bash
python3 scripts/tests/test_sleicpin_press_start.py
python3 scripts/sleic_pin_ball_press_start_patch.py \
    roms/related-machines/sleic-pin-ball/sp03-1_1.rom -o /tmp/sp03p.bin
```
Expected: all `PASS`, and the patch reports its output MD5/CRC32/SHA1. Record
the output CRC32; it becomes a member of `V11_FAMILY_CRC32`.

- [ ] **Step 5: Commit**

```bash
git add scripts/sleic_pin_ball_press_start_patch.py scripts/tests/test_sleicpin_press_start.py
git commit -m "scripts: hook the Pin-Ball score screen into the sequence table"
```

---

# Phase 3 — Verification and archive

### Task 12: Verify the patched ROM in emulation

**Files:**
- Create: `sleic-iomoon/scripts/keyscripts/sleicpin-pressstart-1p.keys`
- Create: `sleic-iomoon/scripts/keyscripts/sleicpin-pressstart-4p.keys`
- Create: `sleic-iomoon/scripts/keyscripts/sleicpin-pressstart-continue.keys`
- Modify: `pinmame/src/wpc/sleicgames.c`, `pinmame/src/wpc/driver.c` — add a temporary set for the patched ROM
- Modify: `sleic-iomoon/scripts/sleic_pin_ball_press_start_patch.py` — fill in the `Verified` table

**Interfaces:**
- Consumes: Task 11's patched image
- Produces: a filled-in `Verified` table in the docstring, every row measured

- [ ] **Step 1: Add a PinMAME set for the patched ROM**

In `sleicgames.c`, clone the `sleicpin` block as `sleicpinp` with the patched
`sp03` checksum, and add `DRIVERNV(sleicpinp)` to the `// SLEIC` block of
`driver.c`. Build both binaries and confirm `MAME_DEBUG` validity checks pass:

```bash
cd /home/gerwout/iomoon/pinmame
cmake --build build-debug -j$(nproc) 2>&1 | grep -E "error|Built target sdl3pinmame"
SDL_VIDEODRIVER=dummy SDL_AUDIODRIVER=dummy ./build-debug/sdl3pinmame sleicpinp \
  -rompath roms -nvram_directory /tmp/nv -cfg_directory /tmp/cfg \
  -nosound -skip_disclaimer -skip_gameinfo -nothrottle -ftr 300
```
Expected: it starts and reports an FPS line. A `validitychecks` failure exits
before machine init and prints nothing.

- [ ] **Step 2: Write the three keyscripts**

One-player, four-player, and a run that scores above 1,000,000 so the
`¿ CONTINUAS ?` offer appears. Each dumps DMD frames throughout.

- [ ] **Step 3: Run each and check the spec's table**

For every row of the spec's Verification section, run the matching keyscript
with `SLEIC_DMD_DUMP` and check the frames. The checks that must pass:

| check | how |
|---|---|
| the screen appears at game over, 1-4 players | a stable frame after the bonus count, showing as many scores as players |
| the scores are right | each equals what the bonus count-up showed |
| one START press releases it | the frame changes to `LOTERIA` within a few frames of the press |
| a press reported twice | tap START twice 10 frames apart; still reaches `LOTERIA`, nothing else disturbed |
| above 1,000,000 the offer still works | `¿ CONTINUAS ?` appears, accepts START, times out at 10 s |
| accepting the continue offer | the score screen does **not** appear and the game continues |
| a record-beating score | name entry still reached after the lottery |
| three games back to back | three screens, each with its own scores |
| power-on and the service menu | boot is not blocked; TEST opens and closes the menu |

- [ ] **Step 4: Fill in the docstring's Verified table with the measured results**

Every row states what was measured, not what was expected. If a row fails, stop
and fix the cave — do not soften the row.

- [ ] **Step 5: Revert the temporary set and commit the keyscripts**

```bash
cd /home/gerwout/iomoon/pinmame && git checkout src/wpc/sleicgames.c src/wpc/driver.c
cd /home/gerwout/iomoon/sleic-iomoon
git add scripts/keyscripts/sleicpin-pressstart-*.keys scripts/sleic_pin_ball_press_start_patch.py
git commit -m "scripts: verify the Pin-Ball PRESS START patch in emulation"
```

The permanent set is added in Task 13, once the image is archived and its
checksums are final.

---

### Task 13: Archive the patched ROM and add the PinMAME set

**Files:**
- Create: `sleic-iomoon/roms/related-machines/sleic-pin-ball - press start/sp03-1_1p.rom`
- Create: `sleic-iomoon/roms/related-machines/sleic-pin-ball - press start/README.md`
- Create: `sleic-iomoon/roms/pinmame/sleicpinp.zip`
- Modify: `sleic-iomoon/roms/README.md`, `sleic-iomoon/roms/pinmame/README.md`, `sleic-iomoon/roms/related-machines/README.md`, `sleic-iomoon/README.md`
- Modify: `pinmame/src/wpc/sleicgames.c`, `pinmame/src/wpc/driver.c`
- Modify: `/home/gerwout/iomoon/CLAUDE.md`

**Interfaces:**
- Consumes: Task 12's verified image
- Produces: the archived chip, the loadable set, and the driver entry

Follow the pattern established for Bike Race in commit `db7e5bc` exactly — that
commit archived `bk04f.bin` beside its stock dump with its own README, added
`bikerc3f.zip` carrying every chip of the machine so it loads standalone, and
updated four index READMEs.

- [ ] **Step 1: Generate and archive the image**

```bash
cd /home/gerwout/iomoon/sleic-iomoon
mkdir -p "roms/related-machines/sleic-pin-ball - press start"
python3 scripts/sleic_pin_ball_press_start_patch.py \
    roms/related-machines/sleic-pin-ball/sp03-1_1.rom \
    -o "roms/related-machines/sleic-pin-ball - press start/sp03-1_1p.rom"
```

- [ ] **Step 2: Build the PinMAME zip with all four chips**

So it loads with no `sleicpin.zip` beside it, as `iomoontf.zip` and
`bikerc3f.zip` do. Then verify every member against its archival source and the
driver's checksums, and check every relative link in the new and modified
READMEs resolves.

- [ ] **Step 3: Write the set README**

Mirror
`roms/related-machines/bike-race/v4.1 - free play + press start/README.md`:
what the patch does, the file table with size/MD5/CRC32/SHA1, a Source table
giving the stock and patched hashes, the reproduction command, what the patch
does technically, installation, and the redistribution note.

- [ ] **Step 4: Add the driver set and verify**

Add `sleicpinp` to `sleicgames.c` and `driver.c` with the archived checksums,
build both binaries, run the debug build for validity checks and the release
build for a real load.

- [ ] **Step 5: Update the indexes and commit both repositories**

Update the four `sleic-iomoon` READMEs and the `CLAUDE.md` script list. Commit
`sleic-iomoon` as one `roms:` commit and `pinmame` as one `sleic:` commit on a
branch off `master`.

---

## Self-Review

**Spec coverage.** Every spec section maps to a task: the three decisions to
Tasks 7/9 (layout), 11 (ordering via the hook site) and 12 (scope, by verifying
the lottery and record entry still run); the architecture to Tasks 10 and 11;
cave placement to Task 11 and the test in Task 6; the components table to Tasks
7-10 one for one; the data section to Task 2; all six measurement items to Tasks
2-5; the prerequisite to the standalone note; safety and failure modes to Tasks
4, 10 and 12; verification to Task 12; and the free-play exclusion is untouched
here by construction.

**Type consistency.** `physical_to_file`, `validate_rom`, `is_already_patched`,
`apply_patches`, `CAVES`, `HOOKS` are the names Task 6 defines and every later
task uses. `DIGITS_DRAW`, `SCORE_DIGITS`, `PROMPT_RECORD`, `DRAW_SCREEN` and
`STUB` each have a matching `*_ASM` string for the `nasm` cross-check and a
matching `*_ADDR` assigned in Task 11.

**Why structure and not byte lists.** Tasks 7-11 give assembly *structure* and
the exact test that must pass, not final byte lists, because every blob embeds
addresses that are only fixed once the cave is laid out in Task 11. Writing byte
lists earlier would mean inventing addresses into a ROM patch, which is the one
class of error that corrupts a live machine. The `nasm` cross-check in every task
is what makes the assembly-to-bytes step safe.
