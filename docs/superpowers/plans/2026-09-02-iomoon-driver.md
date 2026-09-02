# IO Moon PinMAME Driver Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make IO Moon (SLEIC2) fully playable with correct sound in PinMAME, on a fresh disassembly baseline, and prepare an upstream PR.

**Architecture:** New `io-moon` branch off pinmame master `9b497714`. A fresh dasmxx-driven disassembly of both IO Moon ROMs (cross-verified with capstone/ndisasm/unidasm) supplies confirmed facts; the driver is rebuilt in `src/wpc/sleic.c` gated to SLEIC2: memory map + interrupts + J1 byte-port, a new behavioral marker-cadence generator modeled on the recovered IC23 PIC program, then DMD/lamps/sound. The old `sleic` branch is a reference to audit against, never a copy source.

**Tech Stack:** MAME-0.76-era PinMAME C (`src/wpc/`), GNU make (`makefile.unixsdl`), Python 3 (analysis scripts), dasmxx (dasm86/dasm80), capstone, ndisasm, MAME unidasm, Xvfb headless harness.

**Spec:** `sleic-iomoon/docs/superpowers/specs/2026-09-02-iomoon-driver-design.md`

## Global Constraints

- Repos: `~/iomoon/pinmame` (driver work, branch `io-moon` off master `9b497714`) and `~/iomoon/sleic-iomoon` (baseline + docs, branch `main`). Tools build in `~/iomoon/tools/` (not in either repo).
- All driver changes gated to SLEIC2/iomoon — `SLEIC1`/`SLEIC3` (Sleic Pin-Ball, Bike Race) behavior must remain byte-identical in headless regression runs.
- MAME 0.76 idioms only (no modern MAME devices/address_space). Match surrounding style in `src/wpc/sleic.c`. License header on new files: `// license:BSD-3-Clause`.
- **Never** put Claude/AI mentions or Co-Authored-By trailers in commits or PR text.
- Old disassemblies/derived docs are hypotheses; the only trusted prior artifact is `sleic-iomoon/asm/pic16c57_annotated.asm`. Every fact the driver uses needs a citation into `asm/baseline-2026-09/`. `scripts/iomoon_fm_extract.py` may be used ONLY to locate sound code/tables (its audio output is known-wrong).
- Debug instrumentation goes in commits whose subject starts with `debug:`; they are dropped before the PR (Task 20). Never mix debug scaffolding into feature commits.
- Before every A/B or regression run: `rm -f ~/.xpinmame/nvram/iomoon.nv` and a full `make -f makefile.unixsdl clean` rebuild (incomplete header dep tracking makes incremental builds untrustworthy after struct changes).
- Headless harness (used throughout; the `-skip_gamewarnings` switch is now upstream):

  ```bash
  Xvfb :99 -screen 0 1280x1024x24 & export DISPLAY=:99
  SDL_AUDIODRIVER=dummy ./xpinmame.sdl <game> --rompath ~/iomoon/pinmame/roms \
    -nosound -skip_disclaimer -skip_gameinfo -skip_gamewarnings -ftr 400
  ```

  A successful run prints `Average FPS:` and exits 0.
- ROM images (already present): `~/iomoon/sleic-iomoon/roms/1.3 IPDB latest/` — `V1 3_01.bin` (80188 code+fonts, 512 KB; segment `D000` = file offset `0x50000`; reset vector at file `0x7FFF0`), `V1 3_02.bin` (DMD frames), `V1 3_03/04.bin` (OKI samples), `V1 3_05.bin` (Z80, 32 KB). PinMAME expects them zipped as `roms/iomoon.zip` with the names in `sleicgames.c`.

---

## Phase A — Toolchain and baselines

### Task 1: Branch + regression baseline

**Files:**
- Create: `~/iomoon/pinmame` branch `io-moon`
- Create: `/tmp/claude-*/scratchpad/regression/baseline-<game>.log` (scratch, never committed)

**Interfaces:**
- Produces: branch `io-moon`; `regression.sh` scratch script used by every later task's regression step.

- [ ] **Step 1: Create the branch**

```bash
cd ~/iomoon/pinmame
git fetch upstream && git checkout master && git merge --ff-only upstream/master
git checkout -b io-moon
git log --oneline -1   # expect 9b497714 or a newer upstream ff — record the SHA
```

- [ ] **Step 2: Clean build**

```bash
make -f makefile.unixsdl clean && make -f makefile.unixsdl -j$(nproc)
ls -la xpinmame.sdl    # must be freshly timestamped
```

- [ ] **Step 3: Write the regression script** (scratchpad, not committed)

```bash
#!/bin/bash
# regression.sh — headless boot check for the merged SLEIC games + iomoon
set -u
pkill -f 'Xvfb :99' 2>/dev/null; Xvfb :99 -screen 0 1280x1024x24 &
export DISPLAY=:99; sleep 1
for g in bikerace bikerac2 sleicpin iomoon; do
  rm -f ~/.xpinmame/nvram/$g.nv
  SDL_AUDIODRIVER=dummy timeout 300 ./xpinmame.sdl $g --rompath ./roms \
    -nosound -skip_disclaimer -skip_gameinfo -skip_gamewarnings -ftr 400 \
    > /tmp/reg-$g.log 2>&1
  echo "$g exit=$? fps=$(grep -o 'Average FPS:.*' /tmp/reg-$g.log | head -1)"
done
```

- [ ] **Step 4: Record the baseline**

Run `regression.sh`; expect `bikerace`, `bikerac2`, `sleicpin` to exit 0 with an FPS line. Record `iomoon`'s current behavior (whatever it is — likely early exit or hang) as the starting point. Save all four logs to the scratchpad `regression/` dir.

- [ ] **Step 5: Commit** — nothing to commit in pinmame (branch creation only). Done when the four baseline logs exist.

### Task 2: Build dasmxx + install second-opinion tools

**Files:**
- Create: `~/iomoon/tools/dasmxx/` (clone + build, outside both repos)

**Interfaces:**
- Produces: `~/iomoon/tools/dasmxx/src/dasm86`, `.../dasm80` executables; python3 `capstone` importable; `ndisasm` on PATH.

- [ ] **Step 1: Clone and build**

```bash
mkdir -p ~/iomoon/tools && cd ~/iomoon/tools
git clone https://github.com/nejohnson/dasmxx && cd dasmxx
make 2>&1 | tail -5        # adjust to the repo's documented build if different (check its README)
find . -name 'dasm86*' -o -name 'dasm80*' | head
```

- [ ] **Step 2: Smoke-test both tools**

Consult `USAGE.md` / `doc/` in the repo for the command-file format (regions, labels, org). Then create a 4-byte test binary `printf '\xb8\x34\x12\xc3' > /tmp/t86.bin` (mov ax,0x1234; ret) and a minimal command file; run dasm86 on it. Expected output contains `mov` and `ret`. Same for dasm80 with `printf '\x3e\x42\xc9' > /tmp/t80.bin` (ld a,0x42; ret).

- [ ] **Step 3: Second-opinion tools**

```bash
pip3 install --user capstone || sudo apt-get install -y python3-capstone
python3 -c "import capstone; print(capstone.__version__)"
which ndisasm || sudo apt-get install -y nasm
which unidasm    # already installed via mame-tools
```

- [ ] **Step 4: Commit** — nothing repo-side; done when all tools run.

### Task 3: 186-opcode pre-scan (and dasm86 patch only if needed)

**Files:**
- Create: `~/iomoon/sleic-iomoon/asm/baseline-2026-09/tools/scan186.py`
- Possibly modify: `~/iomoon/tools/dasmxx/src/dasm86.c` (local patch)

**Interfaces:**
- Produces: `asm/baseline-2026-09/reports/186scan.md` — verdict: does the firmware use 186-class opcodes, and is dasm86 safe as-is?

- [ ] **Step 1: Write the scanner**

```python
#!/usr/bin/env python3
"""Decode 80188 code regions with capstone (16-bit mode, which covers 186
instructions) and report any 186-only instructions the firmware uses."""
import sys, capstone
ONLY186 = {"pusha","popa","bound","enter","leave","insb","insw","outsb","outsw"}
md = capstone.Cs(capstone.CS_ARCH_X86, capstone.CS_MODE_16)
data = open(sys.argv[1], "rb").read()
base = int(sys.argv[2], 16)          # file offset of region start
size = int(sys.argv[3], 16)
hits = []
for insn in md.disasm(data[base:base+size], base):
    if insn.mnemonic in ONLY186: hits.append((insn.address, insn.mnemonic, insn.op_str))
    # push imm (6A/68) and imul imm (6B/69) and C0/C1 shift-imm are 186-only encodings:
    if insn.bytes[0] in (0x6A,0x68,0x6B,0x69,0xC0,0xC1): hits.append((insn.address, insn.mnemonic, insn.op_str))
for a,m,o in hits: print("%06X: %s %s" % (a,m,o))
print("TOTAL", len(hits))
```

- [ ] **Step 2: Run over the boot code region**

```bash
cd ~/iomoon/sleic-iomoon
python3 asm/baseline-2026-09/tools/scan186.py "roms/1.3 IPDB latest/V1 3_01.bin" 0x50000 0x30000
```

(Region = segments D000–FFFF, file `0x50000`–`0x7FFFF`; linear disassembly over data will produce noise — the authoritative rerun happens in Task 5 once code regions are known. This first pass only answers "are 186 encodings present at all".)

- [ ] **Step 3: Decide and (only if hits are in real code) patch dasm86**

If the Task 5 code regions contain 186-only encodings, add them to dasm86's opcode table (follow the existing table entry pattern in `dasm86.c`; the encodings to add are exactly: `60` PUSHA, `61` POPA, `62 /r` BOUND, `68 iw` PUSH imm16, `69 /r iw` IMUL r,r/m,imm16, `6A ib` PUSH imm8, `6B /r ib` IMUL r,r/m,imm8, `6C/6D` INSB/INSW, `6E/6F` OUTSB/OUTSW, `C0 /n ib` and `C1 /n ib` shift/rotate imm8, `C8 iw ib` ENTER, `C9` LEAVE). Acceptance: a synthetic binary containing each of those byte sequences disassembles identically under patched dasm86 and capstone.

- [ ] **Step 4: Write the report + commit**

`asm/baseline-2026-09/reports/186scan.md`: verdict + hit list + whether dasm86 was patched.

```bash
cd ~/iomoon/sleic-iomoon && git add asm/baseline-2026-09 && git commit -m "baseline: 186-opcode scan for the IO Moon 80188 ROM"
```

---

## Phase B — Fresh disassembly baseline

### Task 4: 80188 entry points and first dasm86 run

**Files:**
- Create: `asm/baseline-2026-09/iomoon_80188.cmd` (dasm86 command file)
- Create: `asm/baseline-2026-09/iomoon_80188.lst` (generated listing)
- Create: `asm/baseline-2026-09/README.md` (method notes)

**Interfaces:**
- Produces: listing + command file that later tasks extend; README documents the offset math (`linear = file + 0x80000` for ROM1; segment `D000:xxxx` = file `0x50000+xxxx`).

- [ ] **Step 1: Extract the reset vector**

```bash
xxd -s 0x7fff0 -l 16 "roms/1.3 IPDB latest/V1 3_01.bin"
```

Decode the bytes at `FFFF0` by hand (expect a far JMP `EA xx xx yy yy` → CS:IP). Record the boot target in README.md.

- [ ] **Step 2: Seed the command file**

Command file starts with: org/offset mapping, one code region at the reset target, plus the chip-select-init routine it jumps to. Use dasmxx's documented directives (from its USAGE) for `code`/`byte` regions and labels.

- [ ] **Step 3: Iterative growth loop**

Repeat until stable: run dasm86 → grep the listing for `call`/`jmp` targets that land outside known regions → classify each target (code vs data) by inspection → add to the command file with a provisional label. Track coverage: every ISR reachable from the IVT the firmware installs (find the IVT copy loop in the boot path — it memcpys a vector table to physical 0; decode that table and add each handler as a region).

Stop criteria (spec §5): reset path, IVT + live ISRs, main loop, and entry points for DMD queue handling, switch handling, sound sequencer, OKI trigger, NVRAM access are all inside decoded regions.

- [ ] **Step 4: Commit**

```bash
git add asm/baseline-2026-09 && git commit -m "baseline: 80188 disassembly, reset path + IVT + main loop coverage"
```

### Task 5: Cross-verification script + report (80188)

**Files:**
- Create: `asm/baseline-2026-09/tools/xverify.py`
- Create: `asm/baseline-2026-09/reports/xverify_80188.md`

**Interfaces:**
- Consumes: `iomoon_80188.cmd` regions, `iomoon_80188.lst`.
- Produces: `xverify.py --arch x86 --regions <cmdfile> --lst <lst> --bin <rom> --base 0x80000` exits 0 when every region agrees across dasm86/capstone/ndisasm; report lists resolved disagreements.

- [ ] **Step 1: Write the verifier**

```python
#!/usr/bin/env python3
"""Compare dasm86 listing against capstone and ndisasm per code region.
Comparison key: (address, instruction length, canonical mnemonic).
Mnemonic aliases (jz/je, shl/sal, ...) are normalized via ALIAS map."""
import subprocess, sys, re, capstone
ALIAS = {"je":"jz","jne":"jnz","sal":"shl","repe":"rep","xlatb":"xlat"}
def canon(m): return ALIAS.get(m, m)
# parse regions from the dasmxx command file; parse (addr, bytes, mnemonic) from the .lst;
# for each region: capstone CS_MODE_16 decode; ndisasm -b16 -o<org> decode (parse stdout);
# report any (addr) where length or canonical mnemonic differ between the three.
```

Fill in the three parsers (command-file regions, dasmxx listing lines, ndisasm lines) against the actual formats observed in Task 2/4 outputs; keep the comparison logic exactly as the docstring states.

- [ ] **Step 2: Run to failure first**

Run on one small region with a deliberately mangled listing line to prove the tool reports a diff. Expected: nonzero exit naming the address.

- [ ] **Step 3: Run over all regions; resolve disagreements**

Each genuine disagreement is investigated by hand (raw bytes vs the three decoders); the winner and reasoning are recorded in `xverify_80188.md`. dasm86 table bugs found here loop back to the Task 3 patch. Re-run until exit 0.

- [ ] **Step 4: Commit**

```bash
git add asm/baseline-2026-09 && git commit -m "baseline: 80188 cross-verification clean (dasm86 vs capstone vs ndisasm)"
```

### Task 6: Z80 baseline + cross-verification

**Files:**
- Create: `asm/baseline-2026-09/iomoon_z80.cmd`, `iomoon_z80.lst`
- Create: `asm/baseline-2026-09/reports/xverify_z80.md`

**Interfaces:**
- Produces: Z80 listing covering reset, the periodic-IRQ handler, the switch-scan loop, all `out (nn),a` sites (lamp/solenoid/J1 ports), all `in` sites.

- [ ] **Step 1: Seed and grow** — same loop as Task 4 with dasm80: regions from `0x0000` (reset) and `0x0038` (IM 1 IRQ) — confirm the interrupt mode from the code itself (`im 1` instruction) rather than assuming.

- [ ] **Step 2: Enumerate the I/O surface** — grep the listing for every `out`/`in`; table of port → call sites goes in the README. This table is the raw material for the switch/lamp/solenoid facts (Task 7) and must be complete (every site classified).

- [ ] **Step 3: Cross-verify** — extend `xverify.py` with `--arch z80` using `unidasm -arch z80` as the second opinion. Run to exit 0; record resolutions.

- [ ] **Step 4: Commit**

```bash
git add asm/baseline-2026-09 && git commit -m "baseline: Z80 disassembly + cross-verification, full I/O surface enumerated"
```

### Task 7: Findings document — the driver contract

**Files:**
- Create: `asm/baseline-2026-09/findings.md`

**Interfaces:**
- Produces: numbered facts `F1..F14`, each with listing address citations. Later tasks reference facts by number. Format per fact: statement, evidence (addresses + instruction quotes), confidence (confirmed / inferred), and — where an old-doc hypothesis existed — whether it was confirmed, corrected, or rejected.

- [ ] **Step 1: Extract and write these facts** (the list is the deliverable; hypotheses in parentheses are the prior claims to test):

- **F1** Chip-select init: I/O writes near boot to `0xFFA0..0xFFA8` with values (hyp: UMCS=C03C, LMCS=3FFC, PACS=A03C, MMCS=41FC, MPCS=A0FC → PCS base `0xA0000`, 0x80 spacing).
- **F2** LMCS banking: which PCS0 (`0xA0000`) bits select ROM2-frames vs ROM1-fonts in segment `0000h` (hyp: bits 4/5), from the font/frame access code paths.
- **F3** Interrupt table: which vector numbers the firmware installs, handler addresses, and what each ISR does (hyp: NMI type 2 = DMD frame handler; type 8 timer; type 0x0C INT0).
- **F4** Marker contract: the byte values the NMI/frame handler compares the `0xA0100` latch against, and the exact dequeue order relative to switch bytes (hyp: `0x47` vsync, `0x45`/`0x46` plane swap). Quote the `cmp` instructions.
- **F5** Switch-code table: the cabinet switch byte values the switch handler recognizes and the shadow location it stores to (hyp: `0x41496`).
- **F6** J1 protocol: Z80 side (out ports, data-valid/strobe bits, hyp: port `0x80` data + `0x81` bits) and 80188 side (latch read, ack), both directions including the 80188→Z80 reverse path.
- **F7** Lamp/solenoid map: Z80 out-port → latch → matrix row/col semantics from the scan routine (hyp: ports `0x82–0x87`).
- **F8** YM3812: write primitive address, port addresses (hyp: `0xA0280` index / `0xA0281` data — note Bike Race instead toggles A0 on a single address; determine which style IO Moon uses), sequencer entry, tick source and rate (which timer ISR calls it, at what divisor).
- **F9** OKI trigger: routine addresses, latch address + strobe (hyp: `0xA0300` latch, `0xA0000` bit 5 strobe), byte format (sample #, channel/bank bits), busy handling.
- **F10** NVRAM: address window and access width (hyp: 28C64A, 8 KB).
- **F11** Credits/coin logic entry points (for the credit-runaway regression test).
- **F12** Sound-command flow: how Z80-forwarded command bytes reach the sound dispatcher (distinguishing the display queue at `4000:1158` hypothesis from the sound path).
- **F13** DMD frame submit: seg-`7000h` staging layout, plane order, strobe (hyp: DMD-MODE bit-3 at `0xA0200`, plane 0 = MSB, bits inverted).
- **F14** Game-state/service-menu entry: what opens the menu (switch code), what paces its display loop.

- [ ] **Step 2: Commit**

```bash
git add asm/baseline-2026-09/findings.md && git commit -m "baseline: findings F1-F14 - the driver contract with address citations"
```

**Checkpoint: review findings vs the old `sleic` branch.** For each fact, note in findings.md whether the old branch's implementation agrees. Divergences are flagged for the corresponding driver task. This is the "audit, don't copy" step made concrete.

---

## Phase C — Driver foundation (pinmame, branch `io-moon`)

Tasks 8–13 all end with: run `regression.sh`; the three merged games must match their Task 1 baseline; commit.

### Task 8: Memory map + NVRAM

**Files:**
- Modify: `src/wpc/sleic.c` (SLEIC2 memory handlers), `src/wpc/sleic.h` if a new machine hook is needed
- Reference (audit only): `git show sleic:src/wpc/sleic.c`

**Interfaces:**
- Produces: `iomoon_lmcs_r` (banked `0x00000-0x3FFFF` read handler honoring F2), MMCS RAM at `0x40000`, NVRAM handlers wired to PinMAME core NVRAM (`nvram_handler` / `core_nvram` pattern — copy the style from the SLEIC1 NVRAM code already in master), per F1/F10.

- [ ] **Step 1: Write the memory map per F1/F2/F10.** Skeleton (constants from findings, not from this plan):

```c
/* SLEIC2: segment 0000h is banked between graphics-ROM frames and font data
 * by PCS0 control bits (F2). PCS0 shadow updated in iomoon_periph_w. */
static int iomoon_lmcs_bank;              /* set from PCS0 writes per F2 */
static READ_HANDLER(iomoon_lmcs_r) {
  UINT8 *rom2 = memory_region(SLEIC_MEMREG_CPU);        /* frames */
  UINT8 *rom1 = memory_region(SLEIC_MEMREG_CPU) + 0x80000; /* fonts  */
  return iomoon_lmcs_bank ? rom1[/* F2 window math */ offset]
                          : rom2[offset];
}
```

- [ ] **Step 2: Boot probe.** Debug commit (`debug:`): log the first 32 chip-select I/O writes and the first 16 far-call targets. Run iomoon headless; expected: the F1 values appear, execution proceeds past chip-select init without wild jumps.

- [ ] **Step 3: Regression + commit** (`sleic: iomoon memory map + NVRAM from fresh baseline (F1,F2,F10)`).

### Task 9: Interrupt model

**Files:**
- Modify: `src/wpc/sleic.c` (SLEIC2 machine driver: periodic IRQ callbacks)

**Interfaces:**
- Produces: `iomoon_irq_gen` firing NMI + the F3 vectored interrupts with `HOLD_LINE`; valid IVT present at physical 0 (the firmware installs its own — verify rather than memcpy one, unless F3 shows the firmware expects a pre-seeded table); Z80 977 Hz IRQ kept (`8000000/8192`).

- [ ] **Step 1: Implement per F3.** Rates: placeholder until Task 11 gives the real frame clock; NMI at the frame rate, timer0 per its 80188 timer programming (read the timer control words the firmware writes — they define the real rate; compute it, don't guess 120 Hz).
- [ ] **Step 2: Probe:** debug-log PC at each NMI entry for 100 frames; expected: stable ISR address from F3, main loop advances (PC histogram shows loop addresses, not a tight spin with IF=0 — the old freeze signature).
- [ ] **Step 3: Regression + commit** (`sleic: iomoon interrupt model per baseline F3`).

### Task 10: J1 byte-port + switch delivery

**Files:**
- Modify: `src/wpc/sleic.c` (Z80 port handlers per F6; 80188 `0xA0100` latch read; reverse path)

**Interfaces:**
- Produces: `iomoon_j1_to188_w` (Z80 out), latch state + data-valid flag consumed by the periph read handler; `core_setSw`-driven switches flow Z80→J1→80188. Consumed by Task 11's arbitration.

- [ ] **Step 1: Implement both directions per F6/F7.** Z80 switch scan feeds from `coreGlobals.swMatrix` via the existing SLEIC port-read pattern in master.
- [ ] **Step 2: Switch-injection probe** (debug commit): a timer that pulses each cabinet switch via `core_setSw(sw, 1)`/`core_setSw(sw, 0)` in sequence, plus a memory peek of the F5 shadow address after each pulse; log `injected=XX seen=YY`. Without markers running yet, expected: 100% of codes reach the shadow.
- [ ] **Step 3: Regression + commit** (`sleic: iomoon J1 byte-port and switch path (F5-F7)`).

### Task 11: Marker cadence generator — the centerpiece

**Files:**
- Modify: `src/wpc/sleic.c`

**Interfaces:**
- Consumes: latch + data-valid from Task 10; marker values + dequeue order from F4.
- Produces: `iomoon_marker_timer` (via `timer_pulse`) and an arbitration queue feeding the `0xA0100` read handler.

- [ ] **Step 1: Implement the cadence.** Model (constants: wire frame ~145 Hz; sequence per frame from the PIC program structure — plane 0 scan, plane 1 scan, inter-frame gap; byte values from F4):

```c
/* Marker cadence per the recovered IC23 PIC program: each ~6.9 ms wire frame
 * emits plane-0 start, plane-1 start (mid-frame), then the vsync marker across
 * the inter-frame gap. Markers and Z80 switch bytes share the one inbound
 * latch; hardware order is preserved by a small FIFO (F4 dequeue contract). */
#define IOMOON_FRAME_HZ  145
static void iomoon_marker_cb(int phase);  /* 3-phase timer: plane0, plane1, vsync */
static struct { UINT8 buf[8]; int head, tail; } iomoon_j1_fifo;
static void iomoon_j1_push(UINT8 b) { /* drop-oldest-marker, NEVER drop a switch byte */ }
```

The arbitration rule implements F4 exactly: if the firmware dequeues one byte per NMI and discards non-markers in the frame handler (the old crowding bug), the FIFO must present switch bytes only in the window the switch handler reads — encode whatever F4 actually says, and document it in a comment citing the findings line.

- [ ] **Step 2: Re-run the Task 10 switch probe WITH markers running.** Expected: still 100% delivery over ≥5 pulses per code. This is the regression test for the crowding bug; failure means the F4 contract is misread — go back to the listing, do not tune blindly.
- [ ] **Step 3: Attract probe:** 2000-frame headless run; DMD frames must keep changing (capture via Task 12's dumper or a temporary frame-counter log); no freeze.
- [ ] **Step 4: Regression + commit** (`sleic: iomoon marker cadence from the IC23 PIC program (F4)`).

### Task 12: DMD submit + grey weighting + frame captures

**Files:**
- Modify: `src/wpc/sleic.c` (SLEIC2 frame submit per F13; per-machine weighting hookup)
- Create: scratchpad `dmdcap.py` (parses debug frame dumps into PNGs)

**Interfaces:**
- Produces: DMD frames submitted with plane 0 = MSB and the PIC's 200:30 row-hold weighting fed to master's per-machine shading; debug frame dumper (`debug:` commit) writing raw planes to `/tmp/dmd/NNNN.bin`.

- [ ] **Step 1: Implement per F13**; reuse master's existing 2-bitplane submit path, adding only what F13 requires for SLEIC2.
- [ ] **Step 2: Verify against ROM frames:** decode a captured attract frame and the same frame taken directly from `V1 3_02.bin` (offset from F13/graphics layout); pixel-compare. Expected: exact match on at least one full attract frame.
- [ ] **Step 3: Menu-hold probe:** inject the F14 menu switch code; capture 200 frames; expected: menu screen visible and stable (not the ~2-frame flicker of the old driver).
- [ ] **Step 4: Regression + commit** (`sleic: iomoon DMD frame path + PIC-derived grey weighting (F13)`).

**OWNER CHECKPOINT 1 (attract + language select):** clean rebuild, hand the owner a build + run instructions; compare attract animation, timing, and language-select behavior against the real machine.

### Task 13: Lamps + solenoids

**Files:**
- Modify: `src/wpc/sleic.c` (Z80 out-port handlers per F7 → `coreGlobals.lampMatrix` / `.solenoids`)

- [ ] **Step 1: Implement per F7** following the master SLEIC1/SLEIC3 lamp/solenoid handler style.
- [ ] **Step 2: Probe:** headless run with start pressed; log nonzero lamp-matrix rows and solenoid bits; expected: activity consistent with F7's map (e.g. GI/flipper enable on start).
- [ ] **Step 3: Regression + commit** (`sleic: iomoon lamp and solenoid decode (F7)`).

---

## Phase D — Sound

### Task 14: YM3812 (FM music)

**Files:**
- Modify: `src/wpc/sleic.c` (SLEIC2 periph read/write: PCS5 decode per F8; `MDRV_SOUND_ADD` wiring; remove the spurious DAC if F8/F9 confirm none exists)

**Interfaces:**
- Produces: YM3812 register/data writes reaching `YM3812_control_port_0_w`/`YM3812_write_port_0_w` per F8's addressing style; status read wired.

- [ ] **Step 1: Implement per F8** in the style of master's `sleic1_periph_w` YM handling. Clock: from F8/board facts (do not carry over the old branch's value without confirmation).
- [ ] **Step 2: Stream probe** (`debug:`): log (reg, val) pairs with timestamps during a headless run that starts a game (start switch injected). Expected: bursts of channel/operator register writes when the F8 sequencer runs, at the tick rate F8 derived — sanity only; `iomoon_fm_extract.py` output is NOT the reference.
- [ ] **Step 3: Regression + commit** (`sleic: iomoon YM3812 music path (F8)`).

### Task 15: OKI MSM6376 (speech/FX)

**Files:**
- Modify: `src/wpc/sleic.c` (PCS6 latch + PCS0 strobe per F9; OKI region/interface wiring — the 6376 is driven through `OKIM6376_data_0_w`, see `src/sound/adpcm.h`)

- [ ] **Step 1: Implement per F9**: latch byte captured at the F9 latch address; playback triggered on the F9 strobe edge; sample/bank/channel bits per F9's byte format.
- [ ] **Step 2: Trigger probe:** headless run injecting coin + start; log latched sample numbers; expected: sample numbers within the F9 duration-table range, triggered on those events. If bank/channel ambiguity remains that the listing cannot resolve → this is the IC7 dupico contingency gate; stop and report rather than guess.
- [ ] **Step 3: Regression + commit** (`sleic: iomoon OKI MSM6376 trigger path (F9)`).

**OWNER CHECKPOINT 2+3 (sound):** clean rebuild; owner A/Bs against the real machine: coin/start sounds, attract→game music start, in-game music transitions, speech identity and pitch/tempo. Findings loop back into F8/F9 review before any code tweaks.

---

## Phase E — Completion

### Task 16: Service menu + credits/NVRAM behavior

- [ ] **Step 1: Menu walk:** with F14's codes, drive the menu headless (inject navigate/select codes, capture DMD each step); expected: menu opens, holds, navigates, exits.
- [ ] **Step 2: Credit regression:** insert N coins headless, read the credit display frame + NVRAM; restart; credits persist and do not run away (F11).
- [ ] **Step 3: Regression + commit** (`sleic: iomoon service menu and credit handling verified (F11,F14)`).

**OWNER CHECKPOINT 4 (service menu + full gameplay):** owner plays the machine-vs-emulator comparison; sign-off gates Task 17.

### Task 17: Flag flip + docs

**Files:**
- Modify: `src/wpc/sleicgames.c` (drop `GAME_NOT_WORKING` from iomoon), `release/whatsnew.txt`, root `README.md` (supported-games note, mirroring how PR #627 did it)

- [ ] Steps: edit, full regression (all four games), commit (`sleic: Io Moon is playable - drop GAME_NOT_WORKING`).

### Task 18: sleic-iomoon documentation sync

**Files:**
- Modify: `sleic-iomoon/docs/*` where findings corrected old claims; `CLAUDE.md` status section (project no longer paused; PIC dumped; stale `-skip_gamewarnings` "local addition" note fixed)

- [ ] Steps: update each doc with a pointer to the findings fact that corrects it; commit to sleic-iomoon (`docs: sync with baseline-2026-09 findings and driver completion`).

### Task 19: Branch cleanup

- [ ] **Step 1:** `git rebase -i` is unavailable — use `git rebase --onto` / `git cherry-pick` onto a fresh `io-moon-clean` branch to drop every `debug:` commit; verify `git log --oneline | grep -c debug:` is 0 and the final diff vs the debug branch is exactly the debug instrumentation.
- [ ] **Step 2:** full clean rebuild + regression on the clean branch.
- [ ] **Step 3:** push `io-moon` (clean) to origin.

### Task 20: Upstream PR

- [ ] **Step 1:** Draft PR text: summary of the hardware model (PIC cadence, chip-selects, sound paths), what was verified and how (cross-verified baseline, real-machine A/B), link to the sleic-iomoon repo. **No AI attribution anywhere.**
- [ ] **Step 2:** Owner reviews the PR text; then `gh pr create` against `vpinball/pinmame` master.

---

## Task-order dependencies

`1,2 → 3 → 4 → 5 → 7`; `6 → 7`; `7 → 8 → 9 → 10 → 11 → 12 → 13`; `7 → 14,15` (after 9); `12+15 → 16 → 17 → 18 → 19 → 20`. Owner checkpoints gate: CP1 after 12, CP2/3 after 15, CP4 after 16.
