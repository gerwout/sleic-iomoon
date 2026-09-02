# 80188 baseline cross-verification (dasmx86 vs capstone vs ndisasm)

`tools/xverify.py` re-decodes every code region of the 2026-09 80188
baseline with two decoders that never see the committed listing --
capstone (`CS_MODE_16`) and `ndisasm -b16` -- and compares each against
dasmx86's own listing on `(address, instruction length, canonical
mnemonic)`. This supersedes Task 4's `crosscheck.py` (capstone-only, and
silently `continue`d past any address capstone lost sync on instead of
counting it); that tool has been deleted and folded into this one.

```bash
python3 asm/baseline-2026-09/tools/xverify.py --arch x86 \
    --regions asm/baseline-2026-09/iomoon_80188.cmd \
    --lst asm/baseline-2026-09/iomoon_80188.lst \
    --bin "roms/1.3 IPDB latest/V1 3_01.bin" \
    --base 0x80000
```

## Tool design

**Regions come from the `.cmd` file, not from re-deriving them via
`grow.py`.** The command-file directives that carry an address (`b` = data
span starts here, `c` = code span starts here, `e` = terminate) are read in
file order; the span from one boundary to the next is a code region iff it
was opened by `c`. `g` (segment paragraph) and `l` (in-region label) do not
open spans and are skipped. This is deliberately independent of
`grow.py`'s in-memory region model (`build_regions()`), so a bug in that
model can't hide from this check by construction; the two are cross-checked
implicitly by agreeing on the region count and byte total (83 regions,
88177 bytes -- both match Task 4's numbers exactly).

Segment (`g`) values are parsed but not used for decoding: x86 instruction
length and mnemonic in 16-bit mode do not depend on the segment a region
runs under -- only *operand text* (a near branch's absolute target) would,
and operand text is explicitly out of scope (see below).

**The `.lst` is parsed with the same line shape `grow.py`'s own `LINE_RE`
uses** (the pattern is duplicated, not imported, as `LST_LINE_RE`): four
leading spaces, hex address, colon, four spaces, space-separated hex byte
list, mnemonic, operands. `DB` byte-dump lines are recognised by a
dedicated regex (`LST_DB_LINE_RE`, matched first) and skipped -- they are
data, not instructions. See "Review fix" below: an earlier version of this
tool tried to recognise them by checking the *instruction* regex's own
mnemonic group against the literal string `"DB"`, which never actually
matched (`D`/`B` are themselves valid hex digits, so the byte-list group
silently absorbed `"DB "` first); that version happened to produce correct
results only because every `DB` row in this baseline sits inside a
`b`-opened span that `parse_cmd_regions()` already excludes, not because
the skip fired. `LST_DB_LINE_RE` recognises the byte-dump row by its own
distinct, unambiguous shape (comma-separated values) instead, so it no
longer depends on that coincidence.

**Capstone decodes each region's raw bytes fresh** (`CS_MODE_16`,
`skipdata=True`), from the ROM file, at the region's real flat address --
never from the listing.

**ndisasm decodes each region's raw bytes fresh too**, via
`ndisasm -b16 -o<origin> -` per region, bytes piped on stdin so no temp
file is needed. ndisasm has no region/segment concept, so `-o` is set to
the region's own start address on every invocation, keeping its printed
addresses directly comparable to dasmx86's flat addresses.

**Comparison key: `(address, instruction length, canonical mnemonic)`.**
Operand text is **not** compared -- out of scope by design, not an
oversight. The three tools format operands too differently to make that a
meaningful automated check: dasmx86 prints far pointers as
`SEG:OFF {label}`, capstone prints `word ptr cs:[si]`-style memory operands
and always shows an explicit destination register even for
implicit-operand string ops, and ndisasm prints raw hex with a different
radix/casing convention throughout. None of that affects whether an
instruction was decoded as the *same instruction at the same address with
the same length* -- which is the actual desync-detection signal -- so
extending the key to operand text would only add comparison noise, not
verification power.

**Canonicalisation** strips a single leading prefix-token run (segment
override / `rep`/`repe`/`repz`/`repne`/`repnz`/`lock`) that a decoder may
fold into the front of its mnemonic text (ndisasm: `"cs lodsw"`; capstone:
`"rep movsw"`), then looks the remaining first token up in a small `ALIAS`
map (below). dasmx86's own mnemonic field is already bare, so this is a
no-op for it; applying the same function uniformly to all three keeps the
logic single-path instead of three special cases. No `rep`/`repe`/`lock`
prefixed instruction actually occurs anywhere in this baseline's 29810
decoded instructions (checked directly), so that half of the stripping
logic is present for robustness/future baselines rather than because this
ROM needed it.

**Explicit accounting -- nothing is silently skipped.** For every dasmx86
instruction address in a region: if capstone (or ndisasm) has no entry at
that exact address, it is counted in `skip_capstone`/`skip_ndisasm`, not
skipped past. Symmetrically, any address where capstone or ndisasm decoded
an instruction that dasmx86's listing does not have at that address inside
the region is counted in `extra_capstone`/`extra_ndisasm` -- this is what
Task 4's `crosscheck.py` could not detect (it only ever asked "does
capstone have *this* dasmx86 address", never "does capstone have an
address dasmx86 doesn't"). A nonzero count in any of these four, or in the
length/mnemonic disagreement counts, fails the run (exit 1).

## A confirmed ndisasm 3.01 decoder gap (not a dasmx86 or capstone bug)

The first real run surfaced 19 addresses, all `FF E0` (`JMP AX`), where
ndisasm produced two bogus one-byte `db` lines instead of one two-byte
`jmp ax`, then stayed one byte out of alignment for a few bytes afterward
(enough to misreport several *following*, otherwise-correct instructions
too, in the regions where these dispatch stubs cluster). This was
investigated by hand, independent of the ROM, with a full opcode-matrix
probe of `ndisasm` against `FF C0`..`FF FF`:

| ModRM reg field | operation | mod=11 (register) | mod=00 (memory) |
|---|---|---|---|
| 0 | `INC r/m16` | decodes fine | decodes fine |
| 1 | `DEC r/m16` | decodes fine | decodes fine |
| **2** | **`CALL r/m16`** | **`db 0xff` / `db` -- fails** | decodes fine (`call [mem]`) |
| **4** | **`JMP r/m16`** | **`db 0xff` / `db` -- fails** | decodes fine (`jmp [mem]`) |
| 6 | `PUSH r/m16` | decodes fine | (not probed; not needed) |

**Verdict: dasmx86 and capstone are both correct; ndisasm 3.01 has no table
entry for the register-operand form of the `FF /2`/`FF /4` opcode group**
(only its memory-operand form). This is a real, reproducible, ROM-independent
tool limitation, not a baseline defect -- it does not loop back to a Task 3
patch because dasmx86 already decodes these correctly. `xverify.py` detects
the exact byte shape (`FF` + ModRM with `mod=11` and `reg` in `{2,4}`,
`is_ndisasm_known_gap()`) from dasmx86's own listing (validated by
capstone, which agrees), and decodes ndisasm around each such address in
separate sub-invocations originated at the next known-good boundary, so the
one-byte cursor slip cannot cascade into misreporting unrelated,
correctly-decoded instructions later in the same region. Every excluded
address is still explicitly counted and printed (`ndisasm_known_gap`, 19 in
this baseline) -- excluded from the pass/fail comparison, never dropped
from the report. All 19 instances in this ROM are `JMP r/m16`
(`FF /4`, `CALL r/m16`/`FF /2` does not occur); the detector also covers
`/2` defensively since the same table gap applies to it, confirmed by the
probe above.

## Alias table

Built from real differences observed in this baseline's actual instruction
stream (all 55 mnemonics dasmx86 emits in this ROM were enumerated and each
one's first occurrence cross-checked against capstone and ndisasm by hand
before the first full run), not a generic x86-mnemonic table. Every entry
below is load-bearing: removing it turns a currently-passing address into a
reported mismatch.

| variant (capstone or ndisasm) | canonical (dasmx86's spelling) | opcode | justification |
|---|---|---|---|
| `lcall` | `call` | `9A`, or `FF /3` | capstone's name for a far `CALL`; dasmx86 and ndisasm both say `call` |
| `ljmp` | `jmp` | `EA`, or `FF /5` | capstone's name for a far `JMP`; dasmx86 and ndisasm both say `jmp` |
| `ret` | `retn` | `C2`/`C3` | capstone's and ndisasm's name for near `RET`; dasmx86 says `retn` |
| `cwde` | `cbw` | `98` | capstone's 32-bit-mode name for opcode `0x98`, printed even in `CS_MODE_16`; dasmx86/ndisasm say `cbw` |
| `cdq` | `cwd` | `99` | capstone's 32-bit-mode name for opcode `0x99`, printed even in `CS_MODE_16`; dasmx86/ndisasm say `cwd` |
| `jc` | `jb` | `72` | ndisasm's name for opcode `0x72` -- jump-if-carry is the same condition as jump-if-below |
| `jna` | `jbe` | `76` | ndisasm's name for opcode `0x76` -- jump-if-not-above == jump-if-below-or-equal |
| `jz` | `je` | `74` | ndisasm's name for opcode `0x74` -- jump-if-zero == jump-if-equal |
| `jnz` | `jne` | `75` | ndisasm's name for opcode `0x75` |
| `jng` | `jle` | `7E` | ndisasm's name for opcode `0x7E` -- jump-if-not-greater == jump-if-less-or-equal |
| `jae` | `jnb` | `73` | capstone's name for opcode `0x73` -- jump-if-above-or-equal == jump-if-not-below |
| `jnc` | `jnb` | `73` | ndisasm's name for the *same* opcode `0x73` -- jump-if-not-carry == jump-if-not-below |
| `ja` | `jnbe` | `77` | capstone's **and** ndisasm's name for opcode `0x77` -- jump-if-above == jump-if-not-below-or-equal |
| `jge` | `jnl` | `7D` | capstone's name for opcode `0x7D` -- jump-if-greater-or-equal == jump-if-not-less |
| `jg` | `jnle` | `7F` | capstone's **and** ndisasm's name for opcode `0x7F` -- jump-if-greater == jump-if-not-less-or-equal |

Mnemonics that already agree verbatim across all three tools (lower-cased)
and so need no alias entry: `adc add and cbw cwd`* `call clc cld cli cmc
cmp dec div enter idiv imul in inc iret jb jbe jcxz jl jle jnb jnl jns
leave les lodsb lodsw loop mov mul neg nop not or out pop popf push pushf
rcl retf sbb shl shr sti stosb sub test xchg xor` -- `*` the *bare* opcodes
`98`/`99` are the ones aliased above; `cbw`/`cwd` themselves are dasmx86's
own spelling and appear here only as the alias targets. `jcxz`, `jl`,
`jnb`, `jnl`, `jns` are conditional jumps that happen to already agree
directly (ndisasm and capstone use the same signed-condition name dasmx86
does for these particular five, unlike the other ten `jcc` mnemonics
above). `SAL` (the `reg=6` alias spelling some disassemblers use for the
`D0`-`D3`/`C0`/`C1` shift-group opcode that is otherwise identical to
`SHL`) does **not** appear in this table: `reg=6` never occurs in this
ROM's shift-group instructions (checked directly across all 89 occurrences
of that opcode group -- only `reg=2` `RCL` and `reg=4` `SHL` occur), so
adding a `sal`/`shl` alias would not be justified by an observed
difference.

## RED test (Step 2)

A copy of `iomoon_80188.lst` was made and its first instruction's mnemonic
mangled (bytes left untouched -- `FA`, which is really `CLI`):

```diff
-    D0000:    FA                         CLI
+    D0000:    FA                         XLAT
```

Run against the mangled copy:

```
$ python3 xverify.py --arch x86 --regions iomoon_80188.cmd \
      --lst /tmp/.../mangled.lst --bin "roms/1.3 IPDB latest/V1 3_01.bin" --base 0x80000
regions: 83   code bytes: 88177
instructions compared: 29810

dasmx86 addr missing from capstone decode (skip_capstone): 0
dasmx86 addr missing from ndisasm  decode (skip_ndisasm) : 0
capstone addr with no dasmx86 counterpart (extra_capstone): 0
ndisasm  addr with no dasmx86 counterpart (extra_ndisasm) : 0
dasmx86 vs capstone disagreements (length or mnemonic): 1
dasmx86 vs ndisasm  disagreements (length or mnemonic): 1
excluded from the ndisasm comparison -- confirmed ndisasm 3.01 decoder gap, see is_ndisasm_known_gap: 19

dasmx86 vs capstone disagreements (1, first 25):
  D0000  mnem  dasmx86=XLAT                           bytes=FA

dasmx86 vs ndisasm disagreements (1, first 25):
  D0000  mnem  dasmx86=XLAT                           bytes=FA

dasmx86/capstone mnemonic pairs seen in disagreements: [(('xlat', 'cli'), 1)]
dasmx86/ndisasm mnemonic pairs seen in disagreements: [(('xlat', 'cli'), 1)]

FAIL: cross-verification found disagreements or desyncs (see addresses above)
$ echo $?
1
```

**RED confirmed**: nonzero exit, both decoders independently flagged the
exact mangled address `D0000` and named the disagreement (`xlat` vs
`cli`); the pre-existing, unrelated `ndisasm_known_gap` exclusion count
(19) is unaffected, showing the two failure channels don't interfere with
each other.

## GREEN run (Step 3 -- real listing)

```
$ python3 xverify.py --arch x86 --regions iomoon_80188.cmd \
      --lst iomoon_80188.lst --bin "roms/1.3 IPDB latest/V1 3_01.bin" --base 0x80000
regions: 83   code bytes: 88177
instructions compared: 29810

dasmx86 addr missing from capstone decode (skip_capstone): 0
dasmx86 addr missing from ndisasm  decode (skip_ndisasm) : 0
capstone addr with no dasmx86 counterpart (extra_capstone): 0
ndisasm  addr with no dasmx86 counterpart (extra_ndisasm) : 0
dasmx86 vs capstone disagreements (length or mnemonic): 0
dasmx86 vs ndisasm  disagreements (length or mnemonic): 0
excluded from the ndisasm comparison -- confirmed ndisasm 3.01 decoder gap, see is_ndisasm_known_gap: 19

ndisasm_known_gap (FF /2 or /4, register operand -- see docstring) (19, first 25):
  F05BF F0630 F066C F06BD F130B F2C99 F2CD2 F2D0B F2D42 F2D7D
  F2DB8 F2E4C F2E93 F2F6B F2F95 F33B9 F35AA F510D F5112

OK: dasmx86, capstone and ndisasm agree on every instruction in every region; zero skips, zero extras
$ echo $?
0
```

No genuine disagreement survived normalisation -- every one of the 29810
instructions in all 83 code regions agrees on address, length and
canonical mnemonic across all three independent decoders, with zero skips
and zero extras on both the capstone and ndisasm side. The only exclusion
(19 addresses) is the ndisasm decoder-gap above, investigated and resolved
in dasmx86's favour (capstone independently confirms).

## Final stats

| metric | value |
|---|---|
| regions | 83 |
| code bytes | 88177 |
| instructions compared | 29810 |
| skip_capstone | 0 |
| skip_ndisasm | 0 |
| extra_capstone | 0 |
| extra_ndisasm | 0 |
| dasmx86 vs capstone disagreements | 0 |
| dasmx86 vs ndisasm disagreements | 0 |
| ndisasm_known_gap (excluded, justified) | 19 |
| exit status | 0 |

The region count and byte total match Task 4's `crosscheck.py` numbers
exactly, which is expected -- both read the same underlying listing -- and
is a useful independent confirmation that this tool's from-scratch `.cmd`
parser reconstructs the same region set `grow.py`'s in-memory model does,
despite not sharing any code with it.

## Files changed

- **Created** `asm/baseline-2026-09/tools/xverify.py` -- the three-way verifier.
- **Created** `asm/baseline-2026-09/reports/xverify_80188.md` -- this report.
- **Deleted** `asm/baseline-2026-09/tools/crosscheck.py` -- folded into xverify.py per the task's "prefer one tool" guidance.
- **Modified** `asm/baseline-2026-09/tools/rebuild.sh` -- final cross-check call switched from `crosscheck.py` to `xverify.py` (same CLI contract as above), header comment updated.
- **Modified** `asm/baseline-2026-09/README.md` -- Verification section rewritten for the three-way tool and current stats; Files table gained `xverify.py`/`xverify_80188.md` rows.

## Commits

- `baseline: 80188 cross-verification clean (dasm86 vs capstone vs ndisasm)`

## Self-review

- **Region source of truth is the `.cmd` file itself**, parsed independently of `grow.py`'s in-memory model, per the task's contract (`--regions <cmdfile>`). Confirmed to reproduce the same 83 regions / 88177 bytes as `grow.py` without sharing region-building code with it -- a real independent check, not just a call-through.
- **Nothing is silently skipped.** Re-read the whole script specifically hunting for another `if x is None: continue`-shaped bug like the one this task was asked to fix in `crosscheck.py`; found and fixed one real instance of the *same class* of bug (ndisasm's cascading desync after the `FF E0` gap, which the first uninstrumented run surfaced as 30+ addresses under a vague "mismatch" bucket) by giving it its own explicit, justified, counted category instead of papering over it.
- **The RED test mangles the artifact actually being verified** (a copy of the `.lst`, i.e. dasmx86's output) rather than corrupting an input to a decoder, since the tool's job is to catch a *wrong baseline listing*, and confirmed both independent decoders (capstone and ndisasm) each separately flagged the exact address.
- **Every alias entry is justified against a specific opcode**, verified by direct byte-level probing (not by trusting the brief's example list) before it went in the table, and cross-checked against what mnemonics actually occur in this ROM (only 55 unique dasmx86 mnemonics total) so no unused/defensive alias could hide a real mismatch behind a broad rule. `sal`/`shl` from the brief's stub was deliberately **not** added, since `reg=6` never occurs here -- adding it would have been exactly the "table that just makes everything match" the task warned against.
- **Operand text is out of scope by design**, stated explicitly in the module docstring, the report, and the README, per the task's instruction to say so rather than let it be an implicit gap.
- Ran the real GREEN pass twice (once mid-development to confirm the numbers, once as the final pre-commit check) with identical output both times -- deterministic, no flakiness from decode ordering or dict iteration.

## Concerns

- The tool depends on the `capstone` Python module and the system `ndisasm` (NASM's disassembler, tested against 3.01) being installed; neither is vendored. Both were already present in this environment.
- `is_ndisasm_known_gap()` is scoped precisely to the byte shape actually observed (`FF` + ModRM with `mod=11`, `reg` in `{2,4}`) and confirmed by direct opcode-matrix probing independent of this ROM, not guessed from the ROM's own instances -- but it is still an ndisasm-version-specific fact. A future ndisasm release that fixes this gap would make the 19 exclusions simply also agree (harmless); one with a *different* gap would need a new investigation, which is exactly what this report's method (probe the opcode matrix by hand, don't guess) is for.
- `--arch x86` is currently the only implemented value (the flag exists, and is validated by `argparse`, to keep the CLI contract stable for a later task that might add e.g. `--arch z80`, per the brief's instruction to preserve this shape) -- there is no Z80 path in this file.

## Review fix (2026-09-02)

The coordinator's review accepted the core verification (the ndisasm gap
claim reproduced exactly under an independent probe; RED/GREEN and skip
accounting confirmed) but raised two Important findings, both fixed here.

### Finding 1: the DB-line skip was dead code

`parse_lst()`'s `if mnem == "DB": continue` never actually matched, because
`LST_LINE_RE`'s byte-list group `(?:[0-9A-F]{2} )+` is greedy over hex
digits and `D`/`B` are themselves valid hex digits: on a real byte-dump
row (`ADDR:    DB      FF, FF, ...`) it silently absorbed the literal text
`"DB "` as if it were one raw instruction byte, leaving `group(3)` to land
on the pseudo-op's first comma-separated *value* (`"FF,"`) instead of the
word `"DB"`. Confirmed harmless only by coincidence: every `DB` row in this
baseline's `.lst` falls inside a `b`-opened span, and `parse_cmd_regions()`
already excludes those spans from the region list entirely, so the
mis-parsed dict entries were built but never looked up -- the 29810/0/0/0
GREEN result was never actually affected by this bug.

**RED** -- reproduced the exact bug against a synthetic listing with a `DB`
row placed *inside* what would be a code region's address range (the
future-baseline risk the finding named), using the committed (pre-fix)
`parse_lst`/`LST_LINE_RE` copied verbatim from commit `b3d52b8`:

```
$ python3 old_parse_lst.py synthetic.lst
D0000  bytes=FA                   mnem='CLI'    ops=''
D0001  bytes=DB                   mnem='FF,'    ops='FF   ...'
D0003  bytes=FB                   mnem='STI'    ops=''

0xD0001 (the DB line's address) present in insns: True
  -> BUG CONFIRMED: DB line leaked through as a fake instruction:
     (['DB'], 'FF,', 'FF   ...')
```

Exactly as the finding predicted: `mnem` is `'FF,'`, never the string
`'DB'`.

**Fix**: added `LST_DB_LINE_RE = re.compile(r"^\s{4}[0-9A-F]+:\s{4}DB\s")`,
matched *before* `LST_LINE_RE` is even tried, recognising the byte-dump
row by its own distinctive, unambiguous shape (dasmx86 always prints its
`DB` pseudo-op with the mnemonic followed by a comma-separated value list,
never dasmx86's usual single-space-separated instruction byte list) rather
than trying to disambiguate the two shapes after a shared regex has
already run. The original `mnem == "DB"` check is kept as defense in depth.

**GREEN** -- same synthetic listing, fixed `xverify.parse_lst`:

```
D0000  bytes=FA                   mnem='CLI'    ops=''
D0003  bytes=FB                   mnem='STI'    ops=''

0xD0001 (the DB line addr) present in insns: False
GREEN: DB line correctly skipped; real instructions on either side parsed correctly
```

Also swept the fix against the real, full `.lst` (not just the synthetic
case): all 10903 real `DB`-shaped lines are now caught by
`LST_DB_LINE_RE` (0 missed), all 29810 real instruction lines still parse
correctly through `LST_LINE_RE` afterward, and 0 false positives (no
instruction line's mnemonic or byte-list is a literal `"DB"`) -- so the
fix changes behaviour only for the exact bug class the finding described,
not for anything already working.

### Finding 2: the 186-only-opcode counter was dropped, not folded

`crosscheck.py`'s `ONLY186_FIRST` occurrence counter re-verified, on every
rebuild, which 80186-only encodings actually occur in the decoded code --
a live check, unlike `reports/186scan.md` (Task 3's one-time snapshot).
Deleting `crosscheck.py` without carrying this into `xverify.py` would
have silently removed that self-check from `tools/rebuild.sh`'s pipeline,
even though the report's prose claimed the tool was "folded in".

**Fix** (restored, not just documented, per the review's stated
preference): added the same `ONLY186_FIRST` byte set, an
`only186: Counter[(opcode, mnemonic)]` on `Stats`, incremented once per
dasmx86 instruction already being visited in `verify_region`'s existing
per-region loop (no extra decode pass -- the bytes are already in hand),
and printed as an "80186-only encodings inside decoded code" table in
`main()`'s output, matching `crosscheck.py`'s original format.

**Verification**: re-ran the full tool; the restored counter reproduces
the README's existing table exactly:

```
80186-only encodings inside decoded code:
  68   PUSH     1539
  6A   PUSH     813
  6B   IMUL     209
  C0   SHL      5
  C8   ENTER    12
  C9   LEAVE    12
```

(`68`=1539, `6A`=813, `6B`=209, `C8`=12, `C9`=12, `C0`=5 -- exact parity
with the README's "80186 opcodes actually used" table, and with 0 counted
for `60/61/62/69/6C/6D/6E/6F/C1`, matching Task 3's/the README's finding
that those don't occur.) README's "80186 opcodes actually used" section
now notes this is re-verified on every `xverify.py` run rather than being
a one-time snapshot.

### Final re-verification after both fixes

```
regions: 83   code bytes: 88177
instructions compared: 29810
skip_capstone: 0   skip_ndisasm: 0
extra_capstone: 0  extra_ndisasm: 0
dasmx86 vs capstone disagreements: 0
dasmx86 vs ndisasm  disagreements: 0
excluded (confirmed ndisasm 3.01 decoder gap): 19
80186-only encodings: 68=1539 6A=813 6B=209 C0=5 C8=12 C9=12
OK: dasmx86, capstone and ndisasm agree on every instruction in every region; zero skips, zero extras
$ echo $? -> 0
```

Both the RED-test mangle (Step 2's mangled-`D0000` check) and the full
19-address `ndisasm_known_gap` accounting were re-run after these changes
and are unaffected -- still exit 1 naming `D0000` on the mangled copy,
still exit 0 with identical stats on the real listing.
