# Z80 baseline -- cross-verification (dasmz80 vs unidasm)

`tools/xverify.py --arch z80` re-decodes every code region of the Z80
baseline with an independent disassembler and compares it, instruction by
instruction, against the committed `iomoon_z80.lst`.

The second opinion is **`unidasm -arch z80`** from `mame-tools 0.288+dfsg1-1`
(`/usr/bin/unidasm`). It never sees the dasmz80 listing: it is handed the raw
bytes of one region and an origin, and decodes them from scratch. There is no
third decoder on this side -- capstone has no Z80 architecture and ndisasm is
x86-only -- so the Z80 check is two-way where the 80188 check
(`xverify_80188.md`) is three-way.

Comparison key per instruction: **(address, instruction length, canonical
mnemonic)**. Operand text is deliberately not compared; the two tools format
it differently (`LD HL, #$C074` vs `ld hl,$C074`, `AND A, A` vs `and a`).

```
python3 asm/baseline-2026-09/tools/xverify.py --arch z80 \
    --regions asm/baseline-2026-09/iomoon_z80.cmd \
    --lst     asm/baseline-2026-09/iomoon_z80.lst \
    --bin     "roms/1.3 IPDB latest/V1 3_05.bin" \
    --base    0x0
```

## Result (GREEN)

```
regions: 12   code bytes: 10737
instructions compared: 4760

dasmz80 addr missing from unidasm decode (skip_unidasm): 0
unidasm addr with no dasmz80 counterpart (extra_unidasm): 0
dasmz80 vs unidasm disagreements (length or mnemonic): 0

OK: dasmz80 and unidasm agree on every instruction in every region; zero skips, zero extras
```

Exit status 0. Zero skips and zero extras is the load-bearing part: it means
the two decoders drew **every** instruction boundary in the same place across
all 12 regions, so neither has desynchronised anywhere. Zero mismatches means
they also agreed on every mnemonic.

Supporting counts from the same listing:

| | |
|---|---|
| instructions in decoded regions | 4760 |
| distinct mnemonics used | 32 |
| `???` (undecodable) bytes in decoded regions | 0 |
| `IN`/`OUT` instructions | 36 / 105 (= the 141 sites in the README's I/O table) |

## Alias table: empty, and that is a result

`ALIAS_X86` exists because capstone and ndisasm spell a number of x86
opcodes differently from dasmx86 (`jz`/`je`, `lcall`/`call`, ...). On the Z80
side **no alias was needed**: over 4760 instructions covering 32 distinct
mnemonics, dasmz80 and unidasm spell every one of them identically. So
`ALIAS_Z80` is committed empty, under the same rule the x86 table follows --
an alias that is not needed to explain an *observed* difference does not
belong in it. `PREFIX_TOKENS_Z80` is empty for the same reason: the Z80 has
no prefix that either decoder folds into the mnemonic text (`DD`/`FD`/`ED`/
`CB` select an instruction, they do not decorate one), so the x86 prefix
tokens are swapped out rather than left to run against Z80 mnemonics.

No `unidasm` decoder gap was found either, so there is no Z80 counterpart to
the x86 side's `is_ndisasm_known_gap` exclusion list. All 19 exclusions in
`xverify_80188.md` remain x86-only.

## The one real defect this found: `DB nn` is an instruction on the Z80

The first Z80 run was **not** clean. It reported 36 `extra_unidasm`
addresses -- addresses where unidasm decoded an instruction that the dasmz80
listing appeared not to contain -- with no mismatches and no skips. Every one
of them turned out to be an `IN A,(port)` site.

Cause: `parse_lst()`'s data-row filter was

```python
LST_DB_LINE_RE = re.compile(r"^\s{4}[0-9A-F]+:\s{4}DB\s")
```

which reads "an address, then the pseudo-op `DB`, then whitespace" and
skips the line as a byte dump. On x86 that is harmless. On the Z80 `DB` is
also a real *opcode byte*: `DB nn` = `IN A,(nn)`. So every line of the form

```
    008C:    DB 00          IN       A, ($00)
```

was silently dropped from the parsed listing, and all 36 `IN` instructions
disappeared from the comparison -- which is exactly why they surfaced as
unidasm "extras". Had xverify.py not counted extras (the earlier
`crosscheck.py` did not), the run would have reported a clean pass while
36 instructions went unchecked.

Fix: use dasmxx's own fixed-width formatting as the discriminator. dasmxx
prints a data row with `printf("DB      ")` -- literally `DB` followed by six
spaces (`src/dasmxx.c` lines 917, 986, 1214, 1282) -- whereas an instruction
whose first raw byte is `0xDB` prints it in the space-separated byte list, so
exactly one space follows. The filter is now

```python
LST_DB_LINE_RE = re.compile(r"^\s{4}[0-9A-F]+:\s{4}DB {6}")
```

After the fix: 4760 instructions compared (was 4724 with the `IN`s missing),
zero extras.

The x86 side is unaffected in outcome -- it has no instruction beginning with
`0xDB` in any decoded region, which is why its extra count was already 0 --
but it now runs the stricter filter too. The x86 run was re-executed after
every change to xverify.py and reproduces its committed numbers exactly
(83 regions, 88177 code bytes, 29810 instructions, 0 skips / 0 extras /
0 disagreements on both decoders, 19 ndisasm known-gap exclusions, identical
80186-opcode histogram).

## A second dasmxx defect, fixed in the disassembler

`dasmz80` printed the *port* operand of `IN A,(n)` / `OUT (n),A` through
`xref_genwordaddr()`, which substitutes a **memory** label whenever one
exists at the same numeric address. With a label at memory address `0x0000`,
`DB 00` printed as

```
    008C:    DB 00          IN       A, (reset)
```

The Z80's I/O ports are a separate 8-bit address space, so this is simply
wrong, and it destroys the port number the listing is being read for. Fixed
in `tools/dasmxx-z80-fixes.patch` (print the raw port; the `X_IO`
cross-reference is still registered, so `-x` still lists each port's call
sites). This did not affect xverify -- operand text is not compared -- but it
would have corrupted the I/O surface table, which is this task's main
deliverable.

## RED tests -- the checker fails when it should

A verifier that has only ever printed OK proves nothing. Three deliberately
corrupted copies of the committed listing were run against the *unmodified*
command file and ROM; each targets one detector, and each must exit 1.

Note that shifting a region boundary in the `.cmd` file is **not** a valid
RED test here: both decoders are handed the same region bounds, so they would
shift together and still agree. The corruption has to be in the listing.

### 1. Wrong mnemonic (`0400: F3` relabelled `DI` -> `EI`)

```
dasmz80 vs unidasm disagreements (length or mnemonic): 1
  0400  mnem  dasmz80=EI                             bytes=F3
dasmz80/unidasm mnemonic pairs seen in disagreements: [(('ei', 'di'), 1)]
FAIL: cross-verification found disagreements or desyncs
```
exit 1.

### 2. Missing instruction (the `0401: ED 56  IM 1` line deleted)

```
instructions compared: 4759
unidasm addr with no dasmz80 counterpart (extra_unidasm): 1
extra_unidasm (1, first 25):
  0401
FAIL: cross-verification found disagreements or desyncs
```
exit 1. This is the detector that caught the `DB nn` bug above.

### 3. Wrong instruction length (`0403: 31 FF C7` shortened to `31 FF`)

```
dasmz80 vs unidasm disagreements (length or mnemonic): 1
  0403  len   dasmz80=LD       SP, #$C7FF            bytes=31 FF
FAIL: cross-verification found disagreements or desyncs
```
exit 1.

The unmodified listing, run immediately before and after these three, exits 0
with the GREEN output at the top of this file.

## What this does and does not establish

**Does:** that the committed listing's instruction boundaries and mnemonics
are what the bytes actually encode, independently confirmed, over every byte
of every decoded region -- so no region has silently desynchronised, and no
instruction in the I/O surface table is a parsing artefact.

**Does not:** say anything about whether a region *should* be code. That is
decided by `entries_z80.txt` and the three discovery channels, and is argued
separately in the README (region inventory + the classification of every
undecoded span). A byte table wrongly decoded as code would pass this check
happily, because both decoders would decode the same wrong thing.
