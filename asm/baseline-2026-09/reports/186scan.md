# Task 3 Report: 186-opcode pre-scan

## Verdict

**The IO Moon 80188 firmware genuinely uses 80186-class instructions**, and
dasmxx's x86 disassembler (`~/iomoon/tools/dasmxx/src/dasmx86`, decoder
source `src/decodex86.c`) was **not** safe as-shipped: its opcode table had
**zero** entries for any 186-only encoding, so on hitting one it printed a
1-byte `???` and then resynchronised the rest of the stream from the wrong
byte boundary — a silent, cascading misdecode, not a contained failure.

Confirmed present in real, correctly-aligned code (not scan noise):
- **`PUSH imm8`/`PUSH imm16`** (`0x6A`/`0x68`) — pervasive: the dominant
  calling convention idiom in the ROM (push args right-to-left, far-call,
  `ADD SP,n` cleanup).
- **`IMUL r16,r/m16,imm8/16`** (`0x6B`/`0x69`) — struct/array index scaling
  (`imul ax,ax,9`-style).
- **`ENTER`/`LEAVE`** (`0xC8`/`0xC9`) — confirmed in the independently-named
  `cmd_queue_push` routine at **D000:0138** (CLAUDE.md's documented address
  for this function, decoded byte-for-byte).
- **Shift/rotate-by-imm8** (`0xC0`/`0xC1`, e.g. `SHL AL,2`) — confirmed in
  clean byte-scaling code (4 of 6 sampled hits; the other 2 were noise).

**Patched** `decodex86.c` per the brief's policy (186-only encodings found
in real code → patch). Acceptance test (synthetic binary, all 15 listed
encodings) passes: patched dasmx86 agrees with capstone on mnemonic,
operands and instruction length for every case. Existing dasmxx x86 test
suite (`test/dasmx86 && make test`) is **byte-for-byte identical**
before/after the patch (verified via `git stash`/rebuild/diff) — no
regression on 8086-era decoding.

## 1. Scanner: brief's code, with two real bugs fixed

`asm/baseline-2026-09/tools/scan186.py` — started from the brief's snippet,
fixed two problems discovered while running it:

1. **Silent-truncation bug (found, not in the brief's "double-count" note,
   but far more serious).** capstone's `Cs.disasm()` generator **stops dead**
   at the first byte sequence it cannot decode — it does not skip a byte and
   resync. Running the brief's exact snippet over the 0x30000-byte window
   decoded only **26 instructions (68 bytes)** before halting, so its
   `TOTAL 0` result was scanning 0.02% of the requested window, not "no
   186 opcodes in this region" as it would appear. Fix: `md.skipdata = True`,
   which makes capstone emit a 1-byte `.byte 0xXX` pseudo-instruction for
   anything undecodable and continue — this is required to cover the full
   window at all. Verified: with `skipdata`, the same window decodes 83,024
   instructions.
2. **Double-count bug (as named in the task).** Restructured the two hit
   conditions (`mnemonic in ONLY186` vs `first byte in ONLY186_FIRST_BYTE`)
   as `if`/`elif` so a hit can never be appended twice, regardless of any
   future overlap between the mnemonic set and the byte set (checked: with
   the brief's literal sets there is no actual overlap today, since no
   ONLY186 mnemonic's encoding starts with `0x6A/0x68/0x6B/0x69/0xC0/0xC1`,
   but the elif makes this true by construction rather than by accident).
3. **Mnemonic-spelling gap (found during verification, fixed defensively).**
   capstone 5.0.7's 16-bit-mode mnemonics for opcodes `0x60`/`0x61` are
   `pushaw`/`popaw`, not the brief's `pusha`/`popa` — the brief's literal
   `ONLY186` set would have silently missed every PUSHA/POPA hit. Both
   spellings are now in the set.

Usage: `python3 asm/baseline-2026-09/tools/scan186.py <romfile> <hex-base> <hex-size>`.

## 2. Raw linear scan (Step 2 of the brief)

```
cd ~/iomoon/sleic-iomoon
python3 asm/baseline-2026-09/tools/scan186.py "roms/1.3 IPDB latest/V1 3_01.bin" 0x50000 0x30000
```

Region = segments D000–FFFF, file `0x50000`-`0x7FFFF` (matches
`SLEIC_ROMSTART5`'s ROM1 code window and CLAUDE.md's "segment D000 = linear
0xD0000 = file 0x50000" convention).

**Raw hit count: 2744**, breakdown by mnemonic:

| mnemonic | count | opcode(s) |
|---|---|---|
| push | 2370 | `0x6A`/`0x68` |
| imul | 228 | `0x6B`/`0x69` |
| popaw | 33 | `0x61` |
| outsb | 33 | `0x6E` |
| leave | 14 | `0xC9` |
| bound | 14 | `0x62` |
| enter | 11 | `0xC8` |
| ror | 9 | `0xC0`/`0xC1` |
| pushaw | 9 | `0x60` |
| insw | 8 | `0x6D` |
| shl | 6 | `0xC0`/`0xC1` |
| rol | 3 | `0xC0`/`0xC1` |
| outsw | 3 | `0x6F` |
| insb | 2 | `0x6C` |
| rcl | 1 | `0xC0`/`0xC1` |

As the brief warned, this **raw count is dominated by linear-scan noise**
over data/padding — the vast majority of `push`/`imul` hits sit inside a
0x30000-byte window that is mostly non-code (strings, tables, sound/DMD
data), and once capstone desyncs from a real instruction boundary it does
not resynchronise reliably. The raw total is not by itself evidence of
anything; see the anchored-stretch analysis below for the actual verdict.

## 3. Anchored-stretch analysis (Step 2/3, the real evidence)

### 3a. Reset vector chain — 100% clean, zero 186 opcodes

Per the brief: decoded the far-JMP at file `0x7FFF0` (= physical `0xFFFF0`,
the 80188 reset vector).

```
7FFF0: EA 00 00 F0 FF   → JMP FAR FFF0:0000  (physical 0xFFF00, file 0x7FF00)
```

Decoded `FFF0:0000` (file `0x7FF00`):
```
BA A0 FF          MOV DX, 0xFFA0
B8 3C C0          MOV AX, 0xC03C
EF                OUT DX, AX          ; writes UMCS = C03C — matches
                                       ; CLAUDE.md's confirmed chip-select table
EA 00 00 00 D0    JMP FAR D000:0000   ; jumps into the real init code
```

Decoded `D000:0000` (file `0x50000`, 65 bytes, all plain 8086):
```
CLI; MOV SS/SP; MOV DS/ES,0x4000
LOOP over CS:[0x41] (15 I/O-port/value pairs — matches the chip-select
    setup table implied by CLAUDE.md's PACS/MMCS/MPCS/UMCS/LMCS table)
CLI
LCALL D000:00B9
LCALL D000:011C
LCALL D000:00FA
LCALL F000:0000
LCALL D000:0B2B
STI
JMP FAR D2F2:0002       ; hands off to the main firmware
```

Decoded all **5 called routines** (D000:00B9, D000:011C, D000:00FA,
F000:0000, D000:0B2B) plus the **4 nested subroutines** F000:0000 calls
(0x700C4, 0x700F1, 0x70113, 0x70124) — ~400 bytes total, every routine
terminates cleanly at `RETF`. All are simple chip-select/RAM-init code
(register writes, memory-clear loops via `STOSB`/`LOOP`). **Zero 186-only
opcodes in the entire boot chain.**

### 3b. First code immediately after boot — confirms real 186 usage

Decoding continues past `D000:011C`'s `RETF` (file `0x50137`) into the next
bytes at file `0x50138`, which turn out to be a **complete, independently
named routine**: `cmd_queue_push` at **D000:0138** — exactly the address
CLAUDE.md documents for this function (`4000:1158+` byte queue,
`cmd_queue_push @ D000:0138`). It decodes cleanly start-to-finish as:

```
050138: CLI
050139: ENTER 2,0                 ; <-- 186-only, real
05013D: MOV AX,[BP+6]             ; parameter, consistent with ENTER's frame
...
05015C: POP DS
05015D: LEAVE                     ; <-- 186-only, real
05015E: STI
05015F: RETF
```

This single find is strong, independent confirmation that `ENTER`/`LEAVE`
are genuinely used (not noise): the function's address, name, and behaviour
(circular byte-queue push with wraparound) match the existing
reverse-engineering docs exactly, and the `ENTER 2,0` / `LEAVE` bracket a
completely coherent function body with no invalid bytes.

Immediately following (file `0x5016D`) is another clean routine that saves
all GP registers via 9 individual `PUSH` instructions (AX,BX,CX,DX,SI,DI,BP,
ES,DS) rather than a single `PUSHA` — worth noting as circumstantial
evidence the toolchain/author deliberately avoided `PUSHA`/`POPA` even where
it would have been the shorter encoding.

### 3c. Sampled `push`/`imul` hits — confirmed real, not noise

Took 8 random samples from the 2744 raw hits plus one dense 0x400-byte
contiguous stretch starting at one of them (file `0x53FC6`, 318
instructions decoded, only 3 invalid `.byte` bytes = 0.9% invalid — the
signature of real code, not misaligned data). All samples show the same
coherent shape:

```
push <imm>              ; args, right to left
push <imm>
lcall <fixed-segment>:<offset>   ; segments D000, D2F2, D72A, F000 recur
add sp, N                        ; caller-cleanup
```

One sample (file `0x53FCE`) calls `D000:0B70` — CLAUDE.md's documented
address for the **sound-command handler** (`~81 call sites`) — with
`PUSH 9` / `PUSH 0x14` as its arguments, i.e. this scan independently landed
on a known, previously-verified call site. Another stretch (file `0x54080`)
shows `mov al,[...]; mov ah,0; imul ax,ax,9; ...` — classic array-of-9-byte-
struct index scaling, also fully coherent.

**Verdict: `PUSH imm8/16` and `IMUL r,r/m,imm8/16` are pervasive, load-
bearing, real-code encodings** — this firmware's calling convention runs on
them.

### 3d. Sampled shift/rotate-imm8 (`C0`/`C1`) hits — mixed, majority real

All 6 `shl` hits and the 1 `rcl` hit were checked individually:
- 4/6 `shl` hits sit in clean code: `mov es,0x413c; mov al,es:[0xA7]; shl
  al,2; ...` (repeated 4× with a small variant, at file `0x56F85`,
  `0x570CB`, `0x570E0`, `0x5719E`) — byte-index scaling by 4 or 8, clean on
  both sides.
- 1/6 `shl` (`0x516DB`) and the 1 `rcl` (`0x752C3`) sit in clearly garbage
  streams (e.g. an `add byte ptr fs:[bp+si],dh` immediately upstream — the
  `FS:` override prefix does not exist before the 80386, so that decode is
  itself proof of misalignment).

**Verdict: `0xC0`/`0xC1` shift/rotate-by-imm8 is also real**, though used
far less than `PUSH imm`/`IMUL imm`.

### 3e. `bound`, `pusha`/`popa`, `insb`/`insw`/`outsb`/`outsw` — sampled, all noise

Checked one representative context for `pushaw` (`0x50E42`), `popaw`
(`0x50E3D`), `bound` (`0x50DE9`), `insb` (`0x75254`), `outsb` (`0x50F79`) —
every one sits inside a stream of nonsensical instructions (impossible
operand forms, register combinations that don't correspond to sensible
code, in one case again the impossible `FS:` prefix). No anchored/plausible
use of these five encodings was found in this pass. This is not proof they
are never used anywhere in the ROM (Task 5's full code-region map is the
authoritative pass), but nothing in this scan supports treating them as
confirmed-real the way `PUSH imm`, `IMUL imm`, `ENTER`/`LEAVE` and `C0`/`C1`
shifts are.

## 4. Patch (Step 3)

**Decision: patch.** Real code uses 186-only encodings (3c/3b/3d above), so
per the brief's policy dasmx86 needed the fix now, not deferred to Task 5.
Per the brief's instruction ("If patching, add exactly: ..."), the **full**
listed set was added — including the 5 encodings from 3e that weren't
independently confirmed in real code this pass, since the brief's spec and
acceptance test cover the complete 80186 opcode extension as a unit, and
leaving isolated gaps (e.g. `PUSHA` decoding as `???` right next to a
correctly-decoded `PUSH imm`) would reintroduce the same class of bug.

**File:** `~/iomoon/tools/dasmxx/src/decodex86.c` (not `dasm86.c` — see the
Task 2 report's naming correction). Local, **uncommitted** patch in the
`dasmxx` git repo (`~/iomoon/tools/dasmxx` has its own `.git`, outside both
`pinmame/` and `sleic-iomoon/`) — consistent with the brief's "local patch"
framing and Task 2's precedent of not committing anything to that tree.
`git diff --stat`: `src/decodex86.c | 105 +++++++++++++++++++++++++------
 (94 insertions, 11 deletions)`.

**What was added**, following the existing `optab.h` MASK/MASK2/INSN table
pattern:
- `PUSHA`/`POPA` (`0x60`/`0x61`) — plain `INSN(..., none, ...)`.
- `BOUND` (`0x62 /r`) — reused the existing generic `modrm` operand
  function; added a case to its opcode-specific `switch` (alongside the
  existing `LEA`/`LDS`/`LES` special cases) forcing `wordop=1, dir=1`.
- `PUSH imm16`/`PUSH imm8` (`0x68`/`0x6A`) — reused the existing `imm16`/
  `imm8` operand functions directly.
- `IMUL r16,r/m16,imm16/imm8` (`0x69`/`0x6B`) — new operand functions
  `modrm_imm16`/`modrm_imm8` (call the existing `modrm` operand function
  with direction forced reg-then-r/m, then append the immediate); added
  `0x69`/`0x6B` to the same `wordop=1, dir=1` special-case switch as BOUND.
- `INSB`/`INSW`/`OUTSB`/`OUTSW` (`0x6C`-`0x6F`) — plain `INSN(..., none,
  ...)`, matching the house style already used for `MOVSB`/`STOSB`/etc.
- Shift/rotate-by-imm8 group (`0xC0`/`0xC1`) — new operand function
  `modrm_shiftimm` (mirrors the existing `modrmC` used for the `D0`-`D3`
  CL/1 group, but reads an explicit imm8 count instead of appending
  `", CL"`/`", 1"`); added a new `SHIFT_ROT_IMM_GRP` macro mirroring the
  existing `SHIFT_ROT_GRP`, and added `0xC0`/`0xC1` to the "REG field
  selects the operation, not a destination register" opcode list in
  `modrm()` (the same list `D0`-`D3` are already on).
- `ENTER`/`LEAVE` (`0xC8`/`0xC9`) — added `TWO_OPERAND(imm16, imm8)` (the
  file's existing macro for auto-generating "a, b" operand-pair functions)
  and used it for `ENTER`'s `size, nestlevel` operands; `LEAVE` is a plain
  `INSN(..., none, ...)`.

Built clean, no warnings (`cd ~/iomoon/tools/dasmxx/src && make dasmx86`).

### Acceptance test (brief's Step 3 requirement)

Synthetic binary (`/tmp/.../scratchpad/synth186/synth186.bin`, 31 bytes)
containing exactly the 15 byte sequences the brief lists (`60`, `61`,
`62 04`, `68 34 12`, `69 C0 34 12`, `6A 05`, `6B C0 05`, `6C`, `6D`, `6E`,
`6F`, `C0 E0 04`, `C1 E0 04`, `C8 10 00 00`, `C9`).

**capstone (16-bit mode)** vs **patched dasmx86**, instruction-by-
instruction:

| bytes | capstone | dasmx86 |
|---|---|---|
| `60` | `pushaw` | `PUSHA` |
| `61` | `popaw` | `POPA` |
| `62 04` | `bound ax, dword ptr [si]` | `BOUND AX, W[SI]` |
| `68 34 12` | `push 0x1234` | `PUSH 01234` |
| `69 C0 34 12` | `imul ax, ax, 0x1234` | `IMUL AX, AX, 01234` |
| `6A 05` | `push 5` | `PUSH 005` |
| `6B C0 05` | `imul ax, ax, 5` | `IMUL AX, AX, 00005` |
| `6C` | `insb byte ptr es:[di], dx` | `INSB` |
| `6D` | `insw word ptr es:[di], dx` | `INSW` |
| `6E` | `outsb dx, byte ptr [si]` | `OUTSB` |
| `6F` | `outsw dx, word ptr [si]` | `OUTSW` |
| `C0 E0 04` | `shl al, 4` | `SHL AL, 004` |
| `C1 E0 04` | `shl ax, 4` | `SHL AX, 004` |
| `C8 10 00 00` | `enter 0x10, 0` | `ENTER 00010, 000` |
| `C9` | `leave` | `LEAVE` |

**Agreement: all 15/15** — same instruction identified, same operand
values, and critically **same byte length consumed at every step** (no
truncation, no cascading misalignment); the only differences are each
tool's own house formatting (mnemonic case, `0x`-hex vs `0NNNN`-hex,
`dword ptr`/`word ptr` size annotations that dasmx86's simpler memory-
operand printer omits — the same kind of cosmetic difference already
documented as normal cross-tool variance in the Task 2 report).

**Regression check:** `cd ~/iomoon/tools/dasmxx/test/dasmx86 && make test`
output is **byte-for-byte identical** before and after the patch (compared
via `git stash` / rebuild / rerun / `git stash pop` / rebuild / `diff`,
exit 0, no output) — the existing 8086-era opcode-coverage test suite is
unaffected.

## 5. Files changed / commits

- Created: `asm/baseline-2026-09/tools/scan186.py`
- Created: `asm/baseline-2026-09/reports/186scan.md` (this file)
- Modified (uncommitted, separate repo): `~/iomoon/tools/dasmxx/src/decodex86.c`

Commit in `sleic-iomoon`:
```
git add asm/baseline-2026-09 && git commit -m "baseline: 186-opcode scan for the IO Moon 80188 ROM"
```

## 6. Self-review

- The brief's scanner snippet had a **materially worse bug than the one it
  named**: without `skipdata`, capstone silently stops after the first
  undecodable byte, so the unmodified snippet would have reported `TOTAL 0`
  over a window it scanned 0.02% of — a false "no 186 opcodes" verdict.
  This would have been a serious miss if not caught (I initially got
  `TOTAL 0` on the first run, which looked plausible until I checked how
  many bytes were actually consumed). Caught and fixed before drawing any
  conclusion from hit counts.
- Verified the double-count fix is real (not just cosmetic): confirmed with
  the brief's literal `ONLY186` set there is no actual overlap with
  `ONLY186_FIRST_BYTE` today, so the `if`/`elif` restructure is a
  belt-and-braces fix rather than a fix for an observed double-count in
  this run — flagging that distinction rather than overclaiming "this fixed
  an active bug."
- Also found and fixed a third, unprompted issue: capstone 5.0.7's 16-bit
  mnemonics for `0x60`/`0x61` are `pushaw`/`popaw`, not the brief's
  `pusha`/`popa` — the brief's scanner would have been blind to every
  PUSHA/POPA hit. Both spellings are now recognised.
- The "raw linear scan" number (2744) is reported but explicitly **not**
  used as evidence by itself — the verdict rests entirely on the anchored
  stretches (3a-3e), consistent with the brief's stated methodology and the
  controller's precision note about desync/false-positives.
- Classification in 3c-3e is based on manual inspection of a limited sample
  (8 push/imul random samples + 1 dense 400-byte run; all 6 shl + 1 rcl;
  1 sample each for the 5 unconfirmed mnemonics) — not exhaustive. This
  matches the brief's stated scope ("first-pass answer... authoritative
  verdict comes later in Task 5"); Task 5 should re-verify with the full
  code-region map, especially to check whether `PUSHA`/`POPA`/`BOUND`/
  `INSx`/`OUTSx` are used anywhere for real once code/data regions are
  known precisely, since this pass's 5 single-sample checks for those are
  thin evidence of absence.
- Chose to patch the **complete** brief-specified opcode set rather than
  only the encodings independently confirmed in real code (3c/3b/3d), per
  the brief's explicit instruction to add "exactly" that list once patching
  is triggered, and because a partial patch would leave exactly the kind of
  gap (one 186 opcode decoding as `???` next to a correctly-decoded
  neighbour) that caused the original problem — this is a small increase in
  patch surface (5 extra encodings, all no-operand or simple-modrm, all
  independently exercised by the acceptance test) in exchange for not
  reintroducing partial-table risk.
- No blockers. No concerns beyond the Task-5 follow-up noted above (full
  code-region-map re-verification of the 5 not-yet-confirmed encodings).
