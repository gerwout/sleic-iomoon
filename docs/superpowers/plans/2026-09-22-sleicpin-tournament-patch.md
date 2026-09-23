# Sleic Pin-Ball Tournament Patch Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Patch Sleic Pin-Ball's `sp03` ROM so the end of a game shows every player's final score and holds it until START is pressed.

**Architecture:** A code cave in `sp03`'s `0xFF` padding, installed as a handler in the ROM's own cooperative screen state machine rather than as a blocking hold. The cave composes a screen the firmware does not have: player labels in the machine's 8-row font, scores in a 4×7 digit font the cave carries, two players per row, with a steady `PULSE START`. It polls the switch FIFO for code `0x05` and chains to the original next-handler when it arrives.

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
  arguments. They draw into panel rows `0xC13`, `0xD13`, `0xE13` and `0xF13` —
  one player per row, four rows of eight pixel rows filling the panel exactly,
  which leaves no room for labels or a `PULSE START` line. So they are usable
  as a fallback layout but do **not** replace Task 9's cave: the two-per-row
  layout this plan specifies still needs the cave's own smaller digit font.
  What they do supply is the digit source and a worked example of the draw
  loop.
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

**Files:**
- Create: `sleic-iomoon/research/sleicpin_disasm/sleicpin_endgame.md`
- Create: `sleic-iomoon/scripts/keyscripts/sleicpin-4p-scores.keys`

**Interfaces:**
- Consumes: Task 1's `SLEIC_RAMDUMP`; the trough model from the prerequisite plan
- Produces: `SCORE_BASE` (word, offset in segment 0), `SCORE_STRIDE` (bytes), `PLAYER_COUNT` (byte offset in segment 0). Phase 2 consumes all three.

**Known starting point:** the playing player's score is a 32-bit little-endian
binary dword at `0000:01C5`, rising 5,000 per lane hit. That is almost certainly
one slot of an array or a working copy of one. The default record table at
`F000:8085` (stride `0x20`) stores its scores the same way — 3,000,000,
2,000,000 and 1,000,000 behind `CRABY`, `ZIPI`, `ZAPE`.

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
section giving `SCORE_BASE`, `SCORE_STRIDE` and `PLAYER_COUNT` as CPU addresses,
the format (32-bit little-endian binary), and the measurement that establishes
each — the keyscript name, the frames dumped, the four values seen. State
plainly that `0000:01C5` is the playing player's slot or working copy, whichever
the array turns out to make it.

```bash
cd /home/gerwout/iomoon/sleic-iomoon
git add research/sleicpin_disasm/sleicpin_endgame.md scripts/keyscripts/sleicpin-4p-scores.keys
git commit -m "research: locate Sleic Pin-Ball's per-player scores and player count"
```

---

### Task 3: Decode the screen-handler contract and find the interception point

**Files:**
- Modify: `sleic-iomoon/research/sleicpin_disasm/sleicpin_endgame.md`

**Interfaces:**
- Consumes: nothing from earlier tasks
- Produces: `HOOK_SITE` (the `F000:xxxx` instruction the patch overwrites), `HOOK_ORIGINAL` (the exact displaced bytes), `NEXT_HANDLER` (how the cave recovers the original next-handler offset), and the semantics of `[0000:027E]`, `[0000:0283]`, `[0000:0285]`

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

### Task 7: The narrow digit font and its blitter

**Files:**
- Modify: `sleic-iomoon/scripts/sleic_pin_ball_press_start_patch.py`
- Modify: `sleic-iomoon/scripts/tests/test_sleicpin_press_start.py`

**Interfaces:**
- Consumes: `CAVES` from Task 6
- Produces: `NARROW_FONT` (70 bytes, ten 7-row glyphs, 4 px ink left-aligned in the high nibble), `NARROW_FONT_ADDR`, and a cave routine `narrow_draw` at `NARROW_DRAW_ADDR` called with `AL` = digit 0-9, `DI` = buffer offset, `CL` = bit shift 0-7, `ES` = `0x6000`; draws 7 rows at a `0x20` stride, OR-ing into the buffer so two glyphs can share a byte column

- [ ] **Step 1: Write the failing test**

Add to the test file:

```python
def test_narrow_font_is_ten_seven_row_glyphs():
    m = load()
    assert len(m.NARROW_FONT) == 70
    for d in range(10):
        rows = m.NARROW_FONT[d*7:(d+1)*7]
        assert any(rows), f'digit {d} is blank'
        assert all(r & 0x0F == 0 for r in rows), f'digit {d} has ink outside the top nibble'

def test_narrow_draw_assembles_as_written():
    m = load()
    asm = m.NARROW_DRAW_ASM
    with tempfile.TemporaryDirectory() as t:
        src = pathlib.Path(t) / 'a.asm'; out = pathlib.Path(t) / 'a.bin'
        src.write_text(asm)
        subprocess.run(['nasm', '-f', 'bin', '-o', str(out), str(src)], check=True)
        assert out.read_bytes() == bytes(m.NARROW_DRAW), 'byte list != nasm output'
```

- [ ] **Step 2: Run it to verify it fails**

Expected: `FAIL test_narrow_font_is_ten_seven_row_glyphs: ...` — `NARROW_FONT`
is not defined.

- [ ] **Step 3: Add the font and the blitter**

The font is ten glyphs, seven bytes each, ink in the top four bits:

```python
# 4 px x 7 row digits, ink left-aligned so a 0-7 bit shift places them at a 5 px
# pitch.  Drawn by narrow_draw, which ORs into the buffer.
NARROW_FONT = bytes([
    0x60,0x90,0x90,0x90,0x90,0x90,0x60,   # 0
    0x20,0x60,0x20,0x20,0x20,0x20,0x70,   # 1
    0x60,0x90,0x10,0x20,0x40,0x80,0xF0,   # 2
    0xE0,0x10,0x10,0x60,0x10,0x10,0xE0,   # 3
    0x20,0x60,0xA0,0xF0,0x20,0x20,0x20,   # 4
    0xF0,0x80,0xE0,0x10,0x10,0x90,0x60,   # 5
    0x60,0x80,0xE0,0x90,0x90,0x90,0x60,   # 6
    0xF0,0x10,0x20,0x20,0x40,0x40,0x40,   # 7
    0x60,0x90,0x90,0x60,0x90,0x90,0x60,   # 8
    0x60,0x90,0x90,0x70,0x10,0x10,0x60,   # 9
])
```

and the blitter, written as assembly **and** as the byte list the test compares:

```python
NARROW_DRAW_ASM = """bits 16
org 0
        push si
        push di
        push bx
        push ax
        mov  bl, 7
        mul  bl                  ; AX = 7 * digit
        mov  si, NARROW_FONT_ADDR_LO
        add  si, ax
        mov  bl, 7               ; 7 rows
.row:   mov  al, [cs:si]
        xor  ah, ah
        shr  ax, cl              ; slide the 4 px glyph into place
        or   [es:di], ah         ; the byte the shift carried into
        or   [es:di+1], al
        inc  si
        add  di, 0x20
        dec  bl
        jnz  .row
        pop  ax
        pop  bx
        pop  di
        pop  si
        ret
"""
```

`NARROW_FONT_ADDR_LO` is the font's offset within segment F000, filled in once
Task 11 fixes the cave layout — until then assemble with a `%define` of the
final value so the test is meaningful. Hand-assemble the same sequence into
`NARROW_DRAW`.

Note the shift direction: `shr ax, cl` with `al` holding the glyph and `ah`
zero moves ink *right* into `ah`, so `ah` is the left-hand byte. Verify that
against the test in Step 4 rather than trusting this paragraph.

- [ ] **Step 4: Run the tests and a pixel check**

```bash
python3 scripts/tests/test_sleicpin_press_start.py
```
Expected: all `PASS`. Then render the font from the byte list and confirm the
ten glyphs read `0`–`9`:

```python
f = NARROW_FONT
for d in range(10):
    print(d)
    for r in f[d*7:(d+1)*7]:
        print('  ' + ''.join('#' if r & (0x80>>k) else '.' for k in range(4)))
```

- [ ] **Step 5: Commit**

```bash
git add scripts/sleic_pin_ball_press_start_patch.py scripts/tests/test_sleicpin_press_start.py
git commit -m "scripts: the Pin-Ball patch's 4x7 digit font and its shift blitter"
```

---

### Task 8: The score formatter

**Files:**
- Modify: `sleic-iomoon/scripts/sleic_pin_ball_press_start_patch.py`
- Modify: `sleic-iomoon/scripts/tests/test_sleicpin_press_start.py`

**Interfaces:**
- Consumes: Task 2's `SCORE_BASE`/`SCORE_STRIDE`
- Produces: a cave routine `score_digits` at `SCORE_DIGITS_ADDR`, called with `BX` = the score's offset in segment 0 and `DI` = a 9-byte scratch buffer offset in segment 0; writes nine digit values 0-9 most significant first, leading zeros written as `0xFF` to mean "draw nothing"

**Why a divide loop:** the ROM has no binary-to-decimal routine — no
powers-of-ten table, no `AAM`, no BCD anywhere. The cave does its own.

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

Repeated division of a 32-bit value by 10 using the two-step `div` idiom (divide
the high word, then the low word with the remainder in `DX`), collecting
remainders least-significant first into the scratch buffer from the far end, then
replacing leading zeros with `0xFF`. Write it as `SCORE_DIGITS_ASM` and
hand-assemble it into `SCORE_DIGITS`.

- [ ] **Step 4: Verify the algorithm against a Python model, then run the tests**

Before trusting the assembly, model it in Python and check it on the values the
machine actually produces — 0, 5000, 15000, 1_000_000, 99_999_999, 999_999_999 —
asserting nine digits with correct leading-`0xFF` suppression. Then:

```bash
python3 scripts/tests/test_sleicpin_press_start.py
```
Expected: all `PASS`.

- [ ] **Step 5: Commit**

```bash
git add scripts/sleic_pin_ball_press_start_patch.py scripts/tests/test_sleicpin_press_start.py
git commit -m "scripts: the Pin-Ball patch's 32-bit score to decimal conversion"
```

---

### Task 9: The screen composer

**Files:**
- Modify: `sleic-iomoon/scripts/sleic_pin_ball_press_start_patch.py`
- Modify: `sleic-iomoon/scripts/tests/test_sleicpin_press_start.py`

**Interfaces:**
- Consumes: Tasks 7 and 8, plus Task 2's `PLAYER_COUNT` and Task 5's `GLYPH_PERIOD`
- Produces: `PROMPT_RECORD` (a `word` count plus eleven `word` glyph pointers spelling `PULSE START` in the 8-row font) and a cave routine `draw_screen` at `DRAW_SCREEN_ADDR`, taking no arguments, which clears the visible buffer and draws the whole screen

**The layout**, from the spec: player labels in the machine's 8-row font via
`F000:550D`; scores in the narrow font via Task 7; two players per row, player
*n* at column `(n & 1) * 66` px and row `2 + (n >> 1) * 11`; the prompt centred
on row 24. Rows 0-31, byte column *c*, is buffer offset `0x410 + row*0x20 + c`.

- [ ] **Step 1: Write the failing test**

```python
def test_prompt_record_spells_pulse_start():
    m = load()
    rec = m.PROMPT_RECORD
    n = int.from_bytes(rec[0:2], 'little')
    assert n == 11
    SMALL, STRIDE = 0x85EB, 8
    idx = [ (int.from_bytes(rec[2+2*k:4+2*k], 'little') - SMALL) // STRIDE
            for k in range(n) ]
    alpha = {10: ' '}
    for i, c in enumerate('ABCDEFGHIJKLMNÑOPQRSTUVWXYZ'): alpha[11+i] = c
    assert ''.join(alpha[i] for i in idx) == 'PULSE START'

def test_draw_screen_assembles_as_written():
    m = load()
    with tempfile.TemporaryDirectory() as t:
        src = pathlib.Path(t) / 'a.asm'; out = pathlib.Path(t) / 'a.bin'
        src.write_text(m.DRAW_SCREEN_ASM)
        subprocess.run(['nasm', '-f', 'bin', '-o', str(out), str(src)], check=True)
        assert out.read_bytes() == bytes(m.DRAW_SCREEN)
```

- [ ] **Step 2: Run it to verify it fails**

Expected: `FAIL` — `PROMPT_RECORD` undefined.

- [ ] **Step 3: Build the record and the composer**

`PULSE START` in the 8-row font is indices `P U L S E (space) S T A R T` =
`27 32 22 30 15 10 30 31 11 29 31`, so each pointer is `0x85EB + 8*index`.
Write `PROMPT_RECORD` from those indices computed in Python, not hand-typed.

`draw_screen` clears offsets `0x410`-`0xC0F` in both planes, then loops players
`0` to `PLAYER_COUNT-1` drawing a label and nine digits each, then draws the
prompt with `F000:550D`.

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

### Task 10: The handler

**Files:**
- Modify: `sleic-iomoon/scripts/sleic_pin_ball_press_start_patch.py`
- Modify: `sleic-iomoon/scripts/tests/test_sleicpin_press_start.py`

**Interfaces:**
- Consumes: Task 9's `draw_screen`, Task 3's `NEXT_HANDLER`, Task 5's `REDRAW_PER_TICK`
- Produces: a cave routine `handler` at `HANDLER_ADDR`, installed into `[0000:0281]`, which on each tick polls `F000:54EF` for code `0x05`, and on seeing it drains the remaining queue, restores `NEXT_HANDLER` into `[0000:0281]` and returns

- [ ] **Step 1: Write the failing test**

```python
def test_handler_assembles_as_written():
    m = load()
    with tempfile.TemporaryDirectory() as t:
        src = pathlib.Path(t) / 'a.asm'; out = pathlib.Path(t) / 'a.bin'
        src.write_text(m.HANDLER_ASM)
        subprocess.run(['nasm', '-f', 'bin', '-o', str(out), str(src)], check=True)
        assert out.read_bytes() == bytes(m.HANDLER)

def test_handler_calls_the_switch_pop_far():
    m = load()
    # 9A EF 54 00 F0 = call far F000:54EF
    assert bytes([0x9A, 0xEF, 0x54, 0x00, 0xF0]) in bytes(m.HANDLER)
```

- [ ] **Step 2: Run it to verify it fails**

Expected: `FAIL` — `HANDLER_ASM` undefined.

- [ ] **Step 3: Write the handler**

On entry: set `DS = 0`. If `REDRAW_PER_TICK`, call `draw_screen`. Then
`call far 0xF000:0x54EF`; `AL` is the popped code, zero meaning empty. If
`AL == 5`, drain by calling it until it returns zero, write `NEXT_HANDLER` to
`[0000:0281]`, set `[0000:027F]` to 0 so the chain advances at once, and return.
Otherwise re-install `HANDLER_ADDR` in `[0000:0281]` with a short
`[0000:027F]` delay and return.

Note `F000:54EF` needs `DS = 0` because it reads the FIFO read pointer at
`[0000:04E5]`, and it clobbers `AX` and `SI`.

- [ ] **Step 4: Run the tests**

```bash
python3 scripts/tests/test_sleicpin_press_start.py
```
Expected: all `PASS`.

- [ ] **Step 5: Commit**

```bash
git add scripts/sleic_pin_ball_press_start_patch.py scripts/tests/test_sleicpin_press_start.py
git commit -m "scripts: the Pin-Ball patch's screen handler and START poll"
```

---

### Task 11: The hook, the guards, and the cave layout

**Files:**
- Modify: `sleic-iomoon/scripts/sleic_pin_ball_press_start_patch.py`
- Modify: `sleic-iomoon/scripts/tests/test_sleicpin_press_start.py`

**Interfaces:**
- Consumes: every earlier Phase 2 task, plus Task 3's `HOOK_SITE`/`HOOK_ORIGINAL` and Task 4's `GUARD_ADDR`/`GUARD_TEST`
- Produces: the final `CAVES` and `HOOKS` tuples; a complete, applicable patch

- [ ] **Step 1: Write the failing test**

```python
def test_hook_original_matches_the_stock_rom():
    m = load()
    data = ROM.read_bytes()
    for addr, original, patched, label in m.HOOKS:
        off = m.physical_to_file(addr)
        assert data[off:off+len(original)] == original, f'{label}: stock bytes differ'
        assert len(original) == len(patched), f'{label}: patch changes length'

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

- [ ] **Step 2: Run it to verify it fails**

Expected: `FAIL test_hook_original_matches_the_stock_rom` — `HOOKS` is empty, so
the loop body never runs and the assertion about the hook is never exercised;
make the test also assert `len(m.HOOKS) >= 1` so it fails honestly.

- [ ] **Step 3: Lay out the cave and write the hook**

Assign final addresses from `0xFDFF0` upward: `NARROW_FONT`, `NARROW_DRAW`,
`SCORE_DIGITS`, `PROMPT_RECORD`, `DRAW_SCREEN`, `HANDLER`, then the hook
trampoline. Re-assemble every blob with the real addresses substituted and
confirm the `nasm` cross-checks still pass.

The hook replaces `HOOK_ORIGINAL` at `HOOK_SITE` with a `jmp far` to a
trampoline that: tests `GUARD_ADDR` against `GUARD_TEST` and, if this is not a
game over, runs `HOOK_ORIGINAL` and rejoins; otherwise records the original
next-handler, installs `HANDLER_ADDR` in `[0000:0281]`, calls `draw_screen`, and
rejoins.

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
git commit -m "scripts: hook the Pin-Ball score screen into the handler chain"
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
task uses. `NARROW_FONT`/`NARROW_DRAW`, `SCORE_DIGITS`, `PROMPT_RECORD`,
`DRAW_SCREEN`, `HANDLER` each have a matching `*_ASM` string for the `nasm`
cross-check and a matching `*_ADDR` assigned in Task 11.

**One honest gap.** Tasks 7-11 give assembly *structure* and the exact test that
must pass, not final byte lists, because seven of the constants those blobs
embed — `SCORE_BASE`, `SCORE_STRIDE`, `PLAYER_COUNT`, `HOOK_SITE`,
`HOOK_ORIGINAL`, `GUARD_ADDR`, `NEXT_HANDLER` — are Phase 1 outputs. Writing
byte lists now would mean inventing addresses into a ROM patch, which is the one
class of error that corrupts a live machine. The `nasm` cross-check in every
task is what makes the assembly-to-bytes step safe once the values are real.
