# Sleic Pin-Ball Ball-Trough Model Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Give the PinMAME SLEIC1 driver an opt-in ball model so a keyscript can drive a Sleic Pin-Ball game of one to four players from START to game over repeatably.

**Architecture:** A two-state model in `locals`, driven by the firmware's own serve coil. C29 "Salida Bolas" reads closed while a ball waits at the ball exit; when the firmware energises coil 11 the model starts a kick countdown, and when it expires the contact opens and the ball is in play. The cabinet's existing "Ball out of trough" key returns the ball, which is the drain. Off by default, exactly like the Bike Race and Io Moon models.

**Tech Stack:** C (PinMAME, historic MAME 0.76 conventions — `MACHINE_DRIVER_START`, `SWITCH_UPDATE`, `coreGlobals.swMatrix`), built with CMake into `build/sdl3pinmame` and `build-debug/sdl3pinmame`; verified headless with `-key_script`, `SLEIC_DMD_DUMP` and the `DEBUG_SLEIC` probes.

**Spec:** `docs/superpowers/specs/2026-09-22-sleicpin-tournament-patch-design.md` — the "Prerequisite" section. The model's own design was agreed in chat as a bounded change and is restated in full below; there is no separate spec file for it.

## Global Constraints

- **Off by default.** The model runs only when the simulator port's "Balls" setting is greater than zero. `INITGAME(sleicpin, sleic_dispDMD, 1)` becomes `INITGAME(sleicpin, sleic_dispDMD, 0)`, matching `bikerace`/`bikerac2`/`bikerac3`. Under a frontend a table script owns the switches and the driver must not fabricate them.
- **OR the contact in, never assign it.** A matrix test key held on that position is a contact stuck closed, which is what the service menu's CONTACTOS test wants to see, and the model has no business overriding it. Both existing models do this and say why.
- The contact is **C29 Salida Bolas** = `coreGlobals.swMatrix[1]` bit `0x04` (común 0, retorno 2), which is the `E` key in `sleic1_pf_keys`.
- The serve coil is **bobina 11 Bobina Salida Bolas** = Z80 port `0x86` bit 6, which `sleic1_z80_write` maps to `locals.solenoids` **bit 10** (mask `0x400`) — PinMAME solenoid 11, numbered so the solenoid number equals the manual's bobina number. This is *not* Bike Race's packing, which uses bits 8-15.
- Sleic Pin-Ball is a **single-ball** machine: one ball is either at the exit or in play. No ball count, no multiball.
- Match the surrounding style in `src/wpc/`: historic MAME 0.76, no modern idioms. Every constant carries its evidence in a comment. License header on new files is `// license:BSD-3-Clause` (not needed here — no new files).
- **No AI attribution** in commit messages or PR text.
- Work on a branch off `master` named `sleicpin-trough`. Do not touch `iomoon-sw40-freeplay` or `bikerace-freeplay-pressstart`.
- **Always rebuild and leave `build/sdl3pinmame` current.** Never leave a `DEBUG_SLEIC` build as the binary the owner runs.

---

## File Structure

One file changes. This is deliberately not spread out.

| File | Responsibility |
|---|---|
| `pinmame/src/wpc/sleic.c` | the model: a struct in `locals`, a reset, an update called from `SWITCH_UPDATE(SLEIC1)`, and the serve-coil observation |
| `pinmame/src/wpc/sleicgames.c` | one character: the `INITGAME(sleicpin, …)` balls default |
| `sleic-iomoon/scripts/keyscripts/sleicpin-4p-game.keys` | the four-player game that proves it works, and which the tournament-patch plan then depends on |

---

### Task 1: Confirm the serve coil actually drives the serve

**Files:**
- Modify: `pinmame/src/wpc/sleic.c` (temporary trace, reverted in Step 5)

**Interfaces:**
- Consumes: nothing
- Produces: a yes/no answer recorded in the commit message of Task 2, plus the measured **frame delay** between the coil firing and the ball needing to leave the contact

**Why this is Task 1:** the whole model rests on the claim that the firmware
fires coil 11 to serve and waits on C29. That claim comes from the coil map
(`sleic-iomoon/research/sleicpin_disasm/sleicpin_coil_map.md`, bobina 11, fire
routine `sp04:0x032a`) and from the manual's parts list, **not** from
observation. If it is wrong, the model in Task 2 is wrong, and hand-driving the
contact from a keyscript has already been shown to stall a game on ball 3.
Settle it before building on it.

- [ ] **Step 1: Add a temporary solenoid trace**

Enable the probes and add a trace to `sleic1_z80_write`'s `case 0x06`, right
after the `locals.solenoids` assignment:

```c
#ifdef DEBUG_SLEIC
      if (getenv("SLEIC_TRACE_SOL"))
        fprintf(stderr, "[sol] f=%d port86=%02x sol=%03x\n",
                cpu_getcurrentframe(), data ^ 0xff, (locals.solenoids >> 4) & 0xff);
#endif
```

Then `cmake --build build-probe -j$(nproc)`. `build-probe` is configured with
`-DDEBUG_SLEIC` already, so the source stays untouched — do not uncomment
`sleic.c:31` as well, or the define is redefined and the compile warns.

- [ ] **Step 2: Run a game with the contact held closed the whole time**

With C29 held closed (`E` down for the whole run) the firmware always believes a
ball is waiting. If coil 11 is the serve, it should fire repeatedly — the
firmware kicks, sees the contact still closed, and kicks again.

```bash
cd /home/gerwout/iomoon/pinmame
S=$(mktemp -d); mkdir -p $S/nv $S/cfg
cat > $S/hold.keys <<'EOF'
800  tap 10 KEYCODE_5
860  tap 10 KEYCODE_5
920  tap 10 KEYCODE_5
980  tap 10 KEYCODE_5
1000 down KEYCODE_E
1200 tap 20 KEYCODE_1
3000 quit
EOF
SDL_VIDEODRIVER=dummy SDL_AUDIODRIVER=dummy SLEIC_TRACE_SOL=1 \
  ./build-probe/sdl3pinmame sleicpin -rompath roms -nvram_directory $S/nv \
  -cfg_directory $S/cfg -nosound -skip_disclaimer -skip_gameinfo -nothrottle \
  -key_script $S/hold.keys -ftr 3100 2>&1 | grep '\[sol\]' | head -40
```
Expected if the hypothesis holds: repeated lines with `sol` bit `0x40` set
(solenoid 11 within the port-86 byte) starting shortly after the START press at
frame 1200.

- [ ] **Step 3: Run the same game with the contact held open**

Replace `1000 down KEYCODE_E` with nothing, so C29 never closes. If coil 11 is
the serve, it should fire **not at all**, or once and then give up — the
firmware has no ball to kick.

Compare the two traces. The discriminating observation is: coil 11 fires when
the contact is closed and does not when it is open.

- [ ] **Step 4: Measure the kick delay**

From the closed-contact trace, measure how many frames elapse between
consecutive coil-11 firings. That interval is how long the firmware waits for
the contact to open before retrying, and the model's kick countdown must be
**shorter** than it so the contact opens before the firmware gives up. Record
the number.

- [ ] **Step 5: Revert the trace**

```bash
cd /home/gerwout/iomoon/pinmame
git checkout src/wpc/sleic.c
grep -n '^//#define DEBUG_SLEIC' src/wpc/sleic.c    # must print line 31
```

**If the hypothesis fails** — coil 11 does not fire, or fires regardless of the
contact — stop and report. Do not proceed to Task 2. The likely alternatives to
investigate are bobina 12 "Taca" (port `0x86` bit 7, the shooter/auto-plunge)
and a firmware timeout rather than a contact wait, and either changes the model.

---

### Task 2: The model

**Files:**
- Modify: `pinmame/src/wpc/sleic.c` — a struct beside `locals.iomBalls`, a reset function, an update function, a call from `SWITCH_UPDATE(SLEIC1)`, and a call from `MACHINE_INIT(SLEIC1)`
- Modify: `pinmame/src/wpc/sleicgames.c` — the `INITGAME(sleicpin, …)` balls default
- Test: headless runs, in Task 3

**Interfaces:**
- Consumes: Task 1's confirmed serve coil and measured kick interval
- Produces: `locals.spBall` (the struct), `sleic1_ball_reset(void)`, `sleic1_ball_update(int balls, int out)` — called from `SWITCH_UPDATE(SLEIC1)` after the playfield key loop, with `balls` from `SIM_BALLS(inports[CORE_SIMINPORT])` and `out` from `inports[CORE_COREINPORT] & 0x1000`

- [ ] **Step 1: Read both existing models before writing a third**

Read, in `src/wpc/sleic.c`:
- `sleic3_ball_update` and the long block comment above it — Bike Race's, a
  static mask, and the paragraph explaining why it does *not* track a ball or a
  kicker ("Inventing a serve would be inventing mechanics the disassembly does
  not show"). Pin-Ball is the case where the serve *is* shown, so this model
  goes further than Bike Race's and must say why.
- `locals.iomBalls` (the struct at `sleic.c:95`), `iomoon_ball_reset` and
  `iomoon_ball_update` — Io Moon's, the state model this one is shaped after.
  Note it takes `shoot` and `drain` inputs and stands down entirely when a
  simulator is registered (`if (coreGlobals.simAvail) { iomoon_ball_reset(); return; }`).
- `SWITCH_UPDATE(SLEIC1)` — where the call goes, and the `#ifdef DEBUG_SLEIC`
  `sleic_debug_switches(1, 0x04)` line already there, which names C29's column
  and bit.

- [ ] **Step 2: Add the struct and the reset**

Beside `iomBalls` in the `locals` struct:

```c
  /* Sleic Pin-Ball ball-exit model, see the block comment above sleic1_ball_update */
  struct { int atExit, kick, drainHeld, seeded; } spBall;
```

and, next to `iomoon_ball_reset`:

```c
static void sleic1_ball_reset(void) {
  memset(&locals.spBall, 0, sizeof locals.spBall);
}
```

Call it from `MACHINE_INIT(SLEIC1)`, which currently reads
`sleic_init_locals(); core_dmd_pwm_init(...)`. `sleic_init_locals` memsets
`locals`, so the explicit reset is belt-and-braces for a Balls change at
runtime rather than for machine init — add it anyway for symmetry with Io Moon,
whose `MACHINE_INIT` does the same at `sleic.c:1990`.

- [ ] **Step 3: Add the update, with its evidence in the comment**

```c
/*-------------------------------------------------------------------------------------
/  Sleic Pin-Ball (SLEIC1) ball-exit model -- OPT-IN, AND OFF BY DEFAULT.
/
/  Same bargain as the other two: under a frontend a table script owns the contacts, so
/  with "Balls" at its default 0 the driver presents nothing and C29 is driven only by
/  its matrix test key.  Setting "Balls" to any non-zero value hands the job to the
/  driver, which is what a headless run or desktop play needs.
/
/  This model tracks a ball where Bike Race's does not, because Pin-Ball's firmware
/  SHOWS the serve and Bike Race's does not.  The trough here is a single contact --
/  C29 Salida Bolas, comun 0 retorno 2, swMatrix[1] bit 2 -- and a single coil, bobina
/  11 Bobina Salida Bolas on port 0x86 bit 6, fire routine sp04:0x032a, which
/  sleic1_z80_write maps to locals.solenoids bit 10.  So the sequence the firmware runs
/  can be followed exactly:
/
/    ball at the exit  ->  C29 closed
/    coil 11 energised ->  kick countdown starts
/    countdown expires ->  C29 opens, the ball is in play
/    the drain key     ->  C29 closes again, ball back at the exit
/
/  There is no ball count because the machine is single-ball: the ball is at the exit or
/  it is in play.  The drain is the cabinet port's "Ball out of trough" key, which on
/  this machine RETURNS the ball rather than taking one away -- the opposite polarity to
/  Bike Race, where the same key lifts a ball off the ball-present optos.  The shared
/  SLEIC_CABPORT label is worded for that machine; this comment is the one that applies
/  here.
/-----------------------------------------------------------------------------------*/
#define SLEIC1_TROUGH_COL  1     /* swMatrix index of Z80 comun 0                       */
#define SLEIC1_TROUGH_BIT  0x04  /* retorno 2 = C29 Salida Bolas                        */
#define SLEIC1_SERVE_SOL   0x400 /* locals.solenoids bit 10 = bobina 11, port 0x86 bit 6 */
#define SLEIC1_KICK_FRAMES 8     /* coil fires -> the ball has left the contact (~0.13 s) */

/* Called from SWITCH_UPDATE(SLEIC1) AFTER the playfield key loop, and it ORs its bit in
 * rather than assigning it: a matrix test key held on C29 is a contact stuck closed,
 * which is what the CONTACTOS self-test wants to see.
 *
 * balls = the simulator port's "Balls" setting, 0 (the default) meaning model off.
 * out   = the cabinet port's "Ball out of trough", which here RETURNS the ball. */
static void sleic1_ball_update(int balls, int out) {
  if (balls <= 0) { sleic1_ball_reset(); return; }
  if (coreGlobals.simAvail) { sleic1_ball_reset(); return; }

  if (!locals.spBall.seeded) {   /* the model comes up with the ball at the exit */
    locals.spBall.seeded = 1;
    locals.spBall.atExit = 1;
  }

  /* The firmware energised the serve coil while a ball was waiting: it is on its way */
  if (locals.spBall.atExit && (locals.solenoids & SLEIC1_SERVE_SOL)
      && !locals.spBall.kick)
    locals.spBall.kick = SLEIC1_KICK_FRAMES;

  if (locals.spBall.kick && --locals.spBall.kick == 0)
    locals.spBall.atExit = 0;    /* clear of the contact, in play */

  /* One press of the drain key returns one ball, so edge-detect it */
  if (out && !locals.spBall.drainHeld) locals.spBall.atExit = 1;
  locals.spBall.drainHeld = out ? 1 : 0;

  if (locals.spBall.atExit)
    coreGlobals.swMatrix[SLEIC1_TROUGH_COL] |= SLEIC1_TROUGH_BIT;
}
```

Set `SLEIC1_KICK_FRAMES` to a value comfortably below Task 1's measured retry
interval. If Task 1 measured, say, 30 frames between retries, 8 is right; if it
measured 10, use 4.

- [ ] **Step 4: Wire it into `SWITCH_UPDATE(SLEIC1)`**

The handler currently reads the cabinet bits inside `if (inports)`, then runs
the `sleic1_pf_keys` loop. Add the two locals and the call:

```c
static SWITCH_UPDATE(SLEIC1) {
  unsigned i;
  int balls = 0, out = 0;
  if (inports) {
    balls = SIM_BALLS(inports[CORE_SIMINPORT]);
    out   = (inports[CORE_COREINPORT] & 0x1000) ? 1 : 0;
    /* ... the existing CORE_SETKEYSW block, unchanged ... */
  }
  /* ... the existing sleic1_pf_keys loop, unchanged ... */
  sleic1_ball_update(balls, out);   /* after the key loop: it ORs its bit in on top */
#ifdef DEBUG_SLEIC
  sleic_debug_switches(1, 0x04);
#endif
}
```

- [ ] **Step 5: Flip the balls default and build both binaries**

In `sleicgames.c`, `INITGAME(sleicpin, sleic_dispDMD, 1)` becomes
`INITGAME(sleicpin, sleic_dispDMD, 0)`.

```bash
cd /home/gerwout/iomoon/pinmame
cmake --build build -j$(nproc) 2>&1 | grep -E "error|warning: .*sleic|Built target sdl3pinmame"
cmake --build build-debug -j$(nproc) 2>&1 | grep -E "error|Built target sdl3pinmame"
```
Expected: both build clean, no new warnings in `sleic.c`.

- [ ] **Step 6: Confirm the default really is off**

```bash
S=$(mktemp -d); mkdir -p $S/nv $S/cfg
printf '600 mark boot\n1500 quit\n' > $S/t.keys
SDL_VIDEODRIVER=dummy SDL_AUDIODRIVER=dummy ./build-debug/sdl3pinmame sleicpin \
  -rompath roms -nvram_directory $S/nv -cfg_directory $S/cfg \
  -nosound -skip_disclaimer -skip_gameinfo -nothrottle -key_script $S/t.keys -ftr 1600
```
Expected: it starts (so `MAME_DEBUG` validity checks pass) and reaches attract.
With Balls at 0 this must behave exactly as before the change — the model is
inert.

---

### Task 3: Prove a four-player game reaches game over

**Files:**
- Create: `sleic-iomoon/scripts/keyscripts/sleicpin-4p-game.keys`

**Interfaces:**
- Consumes: Task 2's model
- Produces: a keyscript that takes a four-player game from START to attract, which the tournament-patch plan's Tasks 2, 4 and 12 all depend on

**The acceptance test for the whole plan.** Before this model existed, a
hand-driven contact stalled a game on ball 3 — that failure is what motivated
the work, and this task is what proves it fixed.

- [ ] **Step 1: Write the keyscript**

Four players, three balls each, twelve balls in total. Per ball: let the model
serve (it closes C29 itself, the firmware kicks, the contact opens), tap a few
lane keys to score, then tap the drain key. Keys: START `1`, coin `5`, lanes
`Q`/`W`/`A`/`S`/`Z`, drain `BACKSPACE`. Give each player a distinct score so
Task 2 of the tournament plan can tell the four apart — one player one lane hit,
the next two, and so on.

Set the simulator port's Balls to 1 for the run. It is a DIP in the standard
simulator port, so either pass a prepared `-cfg_directory` or add
`0 down KEYCODE_...` — the reliable route is a prepared cfg; generate it once by
running interactively, setting Balls to 1, and keeping the resulting
`sleicpin.cfg`.

- [ ] **Step 2: Run it with DMD capture**

```bash
cd /home/gerwout/iomoon/pinmame
S=$(mktemp -d); mkdir -p $S/nv $S/dmd; cp <prepared>/sleicpin.cfg $S/cfg/
SDL_VIDEODRIVER=dummy SDL_AUDIODRIVER=dummy SLEIC_DMD_DUMP=$S/dmd/f \
  ./build-probe/sdl3pinmame sleicpin -rompath roms -nvram_directory $S/nv \
  -cfg_directory $S/cfg -nosound -skip_disclaimer -skip_gameinfo -nothrottle \
  -key_script ../sleic-iomoon/scripts/keyscripts/sleicpin-4p-game.keys -ftr <n>
```

(`build-probe` needs `DEBUG_SLEIC` on for `SLEIC_DMD_DUMP`; enable it, build
`build-probe` only, and leave `build` and `build-debug` built from the shipped
default.)

- [ ] **Step 3: Check the run reached attract, not a stall**

Build a timeline of distinct DMD frames and confirm the shape: twelve
bonus-count sequences, `FIN DEL JUGADOR n` between balls, then the lottery and
attract at the end. A stall shows as one frame repeating for thousands of dumps
— the exact signature the hand-driven attempt produced.

```python
import glob, hashlib, os, sys
fs = sorted(glob.glob('f.*.pgm'))
runs = []
prev = None
for i, f in enumerate(fs):
    h = hashlib.md5(open(f, 'rb').read()).hexdigest()[:8]
    if h != prev: runs.append([i, i, h]); prev = h
    else: runs[-1][1] = i
longest = max(runs, key=lambda r: r[1]-r[0])
print(f'{len(fs)} dumps, {len(runs)} distinct frames, longest run {longest[1]-longest[0]+1}')
```
Expected: many distinct frames and no single run longer than a few hundred
dumps. A run of thousands means a stall — go back to Task 1's kick interval.

- [ ] **Step 4: Confirm the ball number advances 1, 2, 3 for each player**

Crop the status band (rows 25-31, byte columns 112-127) from a frame in each
ball and read the `BOLA n` digit, as the earlier investigation did. Twelve balls
means the digit must walk 1→2→3 four times.

- [ ] **Step 5: Commit the keyscript**

```bash
cd /home/gerwout/iomoon/sleic-iomoon
git add scripts/keyscripts/sleicpin-4p-game.keys
git commit -m "scripts: a four-player Sleic Pin-Ball game that reaches game over

Needs the SLEIC1 ball model with Balls at 1; before that model existed a
hand-driven C29 stalled on ball 3.  Each player scores a distinct number of lane
hits so a RAM diff can tell the four scores apart."
```

---

### Task 4: Regression-check the sets the change touches, then commit the driver

**Files:**
- Modify: nothing new — this task verifies and commits Tasks 1-3's driver work

**Interfaces:**
- Consumes: Tasks 1-3
- Produces: the `sleicpin-trough` branch, pushed, ready for a PR when the owner wants one

- [ ] **Step 1: Confirm the other six SLEIC sets are unaffected**

The change touches shared code (`SWITCH_UPDATE(SLEIC1)` is Pin-Ball's alone, but
`locals` and `sleicgames.c` are shared), so boot every set:

```bash
cd /home/gerwout/iomoon/pinmame
for g in bikerace bikerac2 bikerac3 bikerc3f sleicpin iomoon iomoona iomoont; do
  S=$(mktemp -d); mkdir -p $S/nv $S/cfg
  printf '600 mark boot\n900 quit\n' > $S/t.keys
  out=$(SDL_VIDEODRIVER=dummy SDL_AUDIODRIVER=dummy ./build-debug/sdl3pinmame $g \
    -rompath roms -nvram_directory $S/nv -cfg_directory $S/cfg -nosound \
    -skip_disclaimer -skip_gameinfo -skip_gamewarnings -nothrottle \
    -key_script $S/t.keys -ftr 1000 2>&1)
  echo "$g: $(echo "$out" | grep -c 'Average FPS') started, $(echo "$out" | grep -ciE 'wrong|bad|missing|incorrect') complaints"
done
```
Expected: every set prints `1 started, 0 complaints`. A set that fails
`validitychecks` prints `0 started`.

- [ ] **Step 2: Confirm Sleic Pin-Ball with Balls at 0 is byte-identical to before**

Check out `master`'s `sleic.c` and `sleicgames.c` into a scratch build, run the
same boot keyscript with `SLEIC_DMD_DUMP` on both binaries, and compare the
frame sets. With the model off the output must be identical.

```bash
python3 - <<'EOF'
import glob, hashlib
def sig(d):
    return [hashlib.md5(open(f,'rb').read()).hexdigest() for f in sorted(glob.glob(d+'/f.*.pgm'))]
a, b = sig('before'), sig('after')
print('frames', len(a), len(b), 'identical' if a == b else 'DIFFER')
EOF
```
Expected: `identical`. If they differ, the model is not actually inert at
Balls 0 and Task 2 Step 3's first two guard clauses are wrong.

- [ ] **Step 3: Confirm `build/sdl3pinmame` is the shipped configuration**

```bash
cd /home/gerwout/iomoon/pinmame
grep -n '^//#define DEBUG_SLEIC' src/wpc/sleic.c   # must print line 31
cmake --build build -j$(nproc) 2>&1 | tail -1
ls -l build/sdl3pinmame
```
Expected: the probes are off in the source and `build/` is freshly built from it.

- [ ] **Step 4: Commit on a branch off master**

```bash
cd /home/gerwout/iomoon/pinmame
git checkout -b sleicpin-trough master
git add src/wpc/sleic.c src/wpc/sleicgames.c
git commit -F - <<'EOF'
sleic: model Sleic Pin-Ball's ball exit

Sleic Pin-Ball had no ball model, so nothing closed C29 Salida Bolas and a game
could be started but not finished: driving the contact by hand from a keyscript
stalls on ball 3, because the firmware's serve is paced by its own coil and a
fixed script cannot follow it.

This model follows the coil, which Pin-Ball's firmware shows and Bike Race's
does not -- which is why Bike Race gets a static ball-present mask and this gets
a state machine.  The trough is one contact, C29 on comun 0 retorno 2, and one
coil, bobina 11 Bobina Salida Bolas on port 0x86 bit 6 (sp04's fire routine
0x032a), which sleic1_z80_write maps to locals.solenoids bit 10 -- solenoid 11,
numbered so the PinMAME number matches the manual's bobina.  So the sequence is
followed exactly: the ball rests on the contact, the firmware energises the
coil, a short countdown clears the ball off the contact, and the cabinet's
"Ball out of trough" key returns it.  No ball count: the machine is single-ball.

That the coil drives the serve is measured, not assumed.  With the contact held
closed the firmware fires coil 11 repeatedly, retrying because the ball it
kicked never left; with the contact held open it does not fire at all.  The kick
countdown is set below the measured retry interval so the contact opens before
the firmware gives up.

OFF BY DEFAULT, like the Bike Race and Io Moon models: sleicpin's "Balls" goes
from 1 to 0, so under a frontend a table script keeps ownership of the contacts
and the driver fabricates nothing.  It also stands down when a simulator is
registered.  With Balls at 0 the DMD output is byte-identical to before the
change over a boot-to-attract run, and the model ORs its bit in rather than
assigning it, so a matrix test key on C29 still reads as a stuck contact for the
CONTACTOS self-test.

Verified: a four-player, twelve-ball game runs from START to attract with the
ball number advancing 1-2-3 for each player; all eight SLEIC sets still boot;
MAME_DEBUG validitychecks pass.
EOF
git push -u origin sleicpin-trough
```

- [ ] **Step 5: Report, and do not open a PR**

The owner decides when a PR goes upstream. Report the branch name, the
verification results, and that PR #690 is already open for Bike Race so this one
is independent of it.

---

## Self-Review

**Spec coverage.** The spec's Prerequisite section is the whole requirement and
it names three things: the contact, the coil, and "a model that follows the
coil". Task 1 verifies the coil claim, Task 2 builds the model, Task 3 proves
the deliverable the spec actually asks for — "a repeatable way to drive a 2-4
player game to game over". Task 4 covers the Global Constraints that are
verifiable: off by default (Step 2), the other sets unaffected (Step 1), and
`build/sdl3pinmame` current (Step 3).

**Type consistency.** `locals.spBall` with fields `atExit`, `kick`,
`drainHeld`, `seeded`; `sleic1_ball_reset(void)`; `sleic1_ball_update(int balls,
int out)`. The four constants are `SLEIC1_TROUGH_COL`, `SLEIC1_TROUGH_BIT`,
`SLEIC1_SERVE_SOL`, `SLEIC1_KICK_FRAMES`. Those names are used identically in
Task 2's Steps 2, 3 and 4 and nowhere else.

**Two values this plan deliberately does not fix.** `SLEIC1_KICK_FRAMES` is set
from Task 1's measurement, not asserted up front — Task 2 Step 3 says how to
choose it and gives a worked example either way. And Task 3 Step 1 needs a
prepared `sleicpin.cfg` with Balls at 1, because the setting is a DIP in the
simulator port and there is no command-line switch for it; the plan says to
generate one interactively rather than pretending a flag exists.

**One risk the plan cannot remove.** If Task 1 refutes the serve-coil
hypothesis, Tasks 2-4 are void and the model needs redesigning around whatever
the firmware actually waits on. Task 1 Step 5 says to stop and report rather
than improvise, and names the two alternatives worth trying next — bobina 12
"Taca" and a firmware timeout.
