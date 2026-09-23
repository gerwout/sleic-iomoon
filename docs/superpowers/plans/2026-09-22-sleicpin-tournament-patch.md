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

The **injection point** is settled too: repoint **step 23** of the 26-entry
end-of-game table at `E000:4F7C` (indexed by `[0000:017D]`) at an `E000` stub
that far-calls the `F000` cave and falls through to the stock `E000:5090`, and
keep the sequence cooperative by not advancing `[0000:017D]` until START
arrives. The spec's original `[0000:0281]` route does not reach `LOTERIA` —
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
    want = 'PRESS START'
    for k, ch in enumerate(want):
        idx = 10 if ch == ' ' else 11 + (ord(ch) - ord('A'))
        ptr = int.from_bytes(m.PROMPT_RECORD[2+2*k:4+2*k], 'little')
        assert ptr == 0x85EB + 8*idx, f'glyph {k} ({ch!r}) points at {ptr:#06x}'
```

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
  leading zeros replaced by `0xFF` to mean "draw nothing"

**No divide loop.** The score is already eight unpacked decimal digits in
memory, so this is a reversing copy with leading-zero suppression, not a
binary-to-decimal conversion. The digit layout and the block table it sits in
are in "Per-player score storage" in
`research/sleicpin_disasm/sleicpin_endgame.md`.

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
- Consumes: Task 7's `digits_draw` and `PROMPT_RECORD`, Task 8's `score_digits`, the block table at `E000:190F` and `PLAYER_COUNT`
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
`PLAYER_COUNT` index the block table at `E000:190F`, call `score_digits` to get
eight digits into a scratch buffer with the leading zeros blanked, and call
`digits_draw` with that player's slot offset from the table above. Then draw the
prompt twice with `F000:550D`, at `0x712` and `0xF12`, since that routine writes
one plane per call.

Take the scratch digit buffer from the cave's own segment-0 workspace, not from
the live player block — the live block is real game state.

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
- Consumes: Task 9's `draw_screen` (in the F000 cave), `GUARD_ADDR = 0x0103`
- Produces: `STUB_ASM`/`STUB` and `STUB_ADDR`, a routine in **segment E000**
  reached as step 23 of the `[0000:017D]` sequence table, plus `STATE_ADDR`, one
  byte of segment-0 workspace

**The mechanism.** Step 23 of the table at `E000:4F7C` is stock `E000:5090`:

```
E000:5090  9afcde00f0   lcall F000:DEFC          ; clear the display buffer
E000:5095  9a020b00f0   lcall F000:0B02          ; the LOTERIA setup
E000:509A  3ec706df046400  mov word [0x4df], 0x64  ; this step's dwell, in ticks
E000:50A1  e93100       jmp 0x50d5               ; the advance tail
```

and the advance tail every step ends in is:

```
E000:50D5  3e833e7d0118  cmp word [0x17d], 0x18
E000:50DB  7508          jne 0x50e5
E000:50DD  3ec7067d010000 mov word [0x17d], 0     ; wrap
E000:50E4  c3            ret
E000:50E5  3eff067d01    inc word [0x17d]
E000:50EA  c3            ret
```

So **holding the screen is a `ret` that skips `0x50D5`**: `[017D]` stays at 23
and the dispatcher vectors here again on the next tick. Releasing is
`jmp 0x5090`, which runs the stock step and advances normally. The stub must be
in segment E000 because the table entry is a near offset in that segment; it
lives at `E000:50EB`, the start of a 44,821-byte `0xFF` run reaching the end of
the segment. The drawing cave stays in F000 and is reached by `lcall`.

`DS` is already 0 on entry — every access in the dispatcher and in step 23 is a
`3E`-prefixed direct address in segment 0. Confirm that before relying on it.

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

**The state byte.** `STATE_ADDR` holds 0 = not yet drawn, 1 = drawn and holding.
The release path sets it back to 0, so a later game gets its screen. Whether that
is sufficient depends on whether the `[017D]` sequence revisits step 23 during
attract — if it does, a game-start reset hook is needed as well, which Task 11
adds. The answer is recorded in the ledger before this task runs.

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

def test_stub_guards_on_the_in_game_flag():
    m = load()
    # 3E 80 3E 03 01 00 = cmp byte ds:[0103], 0
    assert bytes([0x3E, 0x80, 0x3E, 0x03, 0x01, 0x00]) in bytes(m.STUB)

def test_stub_rejoins_the_stock_step_and_not_the_advance_tail():
    m = load()
    asm = m.STUB_ASM
    assert '0x5090' in asm or '05090' in asm, 'stub never rejoins the stock step 23'
    assert '0x50d5' not in asm.lower(), 'stub must not jump to the advance tail itself'
```

- [ ] **Step 2: Run it to verify it fails**

Expected: `FAIL` — `STUB_ASM` undefined.

- [ ] **Step 3: Write the stub**

```
stub:   cmp byte [0x103], 0        ; in-game flag: 0 means the game is over
        jne stock                  ;   a game is running: behave exactly as stock
        cmp byte [STATE_ADDR], 0
        jne holding
        lcall F000:<draw_screen>   ; compose the screen once
        mov byte [STATE_ADDR], 1
        jmp hold
holding:
        lcall F000:0x54EF          ; pop one switch code, AL = 0 when empty
        or al, al
        je hold                    ;   queue empty: keep holding
        cmp al, 5                  ; START
        jne holding                ;   anything else: discard it and keep draining
drain:  lcall F000:0x54EF          ; scrub duplicate START codes before moving on
        or al, al
        jne drain
        mov byte [STATE_ADDR], 0
        jmp stock
hold:   mov word [0x4df], <dwell>  ; this step's dwell in ticks
        ret                        ; [017D] untouched: step 23 runs again
stock:  jmp 0x5090
```

Pick `<dwell>` small enough that START feels responsive and large enough not to
redraw needlessly — the draw is already guarded by `STATE_ADDR`, so the dwell
only paces the poll. Write it as `STUB_ASM` with `org 0x50EB` and
hand-assemble it into `STUB`.

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

**The hook is two bytes.** Table entry 23 sits at `E000:4FAA` and reads
`90 50` (`0x5090`). The patch writes the stub's offset there. That is the whole
hook — no displaced instructions, no trampoline, nothing to replay.

Two cave regions, so `CAVES` spans two padding runs:

| region | physical | holds |
|---|---|---|
| E000 padding | `0xE50EB` upward | `STUB` |
| F000 padding | `0xFDFF0` upward | `DIGITS_DRAW`, `SCORE_DIGITS`, `PROMPT_RECORD`, `DRAW_SCREEN` |

- [ ] **Step 1: Write the failing test**

```python
def test_hooks_are_present_and_match_the_stock_rom():
    m = load()
    data = ROM.read_bytes()
    assert len(m.HOOKS) >= 1, 'HOOKS is empty, so the assertions below never run'
    for addr, original, patched, label in m.HOOKS:
        off = m.physical_to_file(addr)
        assert data[off:off+len(original)] == original, f'{label}: stock bytes differ'
        assert len(original) == len(patched), f'{label}: patch changes length'

def test_the_table_entry_is_the_hook():
    m = load()
    addrs = {addr for addr, _, _, _ in m.HOOKS}
    assert 0xE4FAA in addrs, 'step 23 of the E000:4F7C table is not hooked'
    for addr, original, patched, _ in m.HOOKS:
        if addr == 0xE4FAA:
            assert original == bytes([0x90, 0x50]), 'stock entry 23 is not 0x5090'
            assert int.from_bytes(patched, 'little') == m.STUB_ADDR & 0xFFFF

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
empty.

- [ ] **Step 3: Lay out the caves and write the hook**

Assign the F000 blobs from `0xFDFF0` upward and the stub at `0xE50EB`,
re-assemble every blob with the real addresses substituted, and confirm the
`nasm` cross-checks still pass. Add the game-start reset hook only if the ledger
records that the `[017D]` sequence revisits step 23 during attract; if it does,
clear `STATE_ADDR` from `E000:0706`, where the stock code already writes
`[0103] = 0xFF` and `[0105] = 1`.

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
