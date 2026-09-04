# Bike Race — 2026-09 baseline disassembly (80188)

Independently derived disassemblies of **both** Bike Race 80188 code ROMs, built
with [dasmxx](https://github.com/nejohnson/dasmxx) and cross-checked against
capstone and ndisasm:

| set | ROM | what it is |
|---|---|---|
| `parent/` | [`bkcpu04.bin`](../../roms/related-machines/bike-race/bkcpu04.bin) | the 1992/94 set PinMAME calls `bikerace` — working |
| `v41/` | [`bk04.bin`](../../roms/related-machines/bike-race/v4.1/bk04.bin) | the V4.1 set PinMAME calls `bikerac3` — `GAME_NOT_WORKING` |

Two ROMs rather than one because the question these were built to answer is a
*difference*: what changed in V4.1, and which of the changes is why it does not
render. The answer is in [`reports/v41_sprite_table.md`](reports/v41_sprite_table.md)
— ROM 06 does not match ROM 04, and the fault is 4356 bytes wide.

This directory follows the method of the IO Moon baseline next door
([`../baseline-2026-09/`](../baseline-2026-09/)) and reuses its tools, adapted.
Read that one first if you want the reasoning behind the approach.

## Address arithmetic

Both code ROMs are 128 KB and both are mapped by UMCS over `0xE0000-0xFFFFF`, so
the arithmetic is the same for either:

```
linear (flat 80188 address) = file offset + 0xE0000
file offset                 = linear - 0xE0000

segment E000:xxxx = linear 0xE0000 + xxxx = file 0x00000 + xxxx
segment F000:xxxx = linear 0xF0000 + xxxx = file 0x10000 + xxxx
reset vector FFFF0                        = file 0x1FFF0
```

The reset vector is `EA 00 00 F0 FF`, a far jump to `FFF0:0000` = `0xFFF00`,
where a three-instruction stub sets `UMCS = 0xE03C` and jumps to `E000:0000`.
Everything else follows from there; see `*/entries.txt` for the seeds and the
evidence for each.

## Files

| file | what it is |
|---|---|
| `<set>/entries.txt` | code entry points, one per line, each with the evidence that produced it |
| `<set>/notcode.txt` | addresses **proven not to be code**, so a discovery channel that seeds them cannot keep re-adding them |
| `<set>/csdata.txt` | data spans that sit **inside** a code region — far pointers the code loads out of its own `CS` |
| `<set>/labels.txt` | hand-given provisional names, applied on top of the generated ones |
| `<set>/<stem>.cmd` | the dasmxx command list (generated — do not hand-edit) |
| `<set>/<stem>.lst` | the listing dasmx86 produces from it |
| `reports/v41_sprite_table.md` | why V4.1 draws garbage |
| `reports/xverify_80188.md` | dasmx86 vs capstone vs ndisasm — **zero disagreements, zero desyncs, both ROMs** |

## Reproducing

Run from the repository root. `BK_SET` picks the ROM; everything else follows.

```sh
BK_SET=parent sh asm/bikerace-2026-09/tools/rebuild.sh
BK_SET=v41    sh asm/bikerace-2026-09/tools/rebuild.sh
```

`rebuild.sh` iterates two nested loops to a joint fixed point. The inner loop
grows code regions:

- `grow.py add` — direct `CALL`/`JMP` edges out of the dasmx86 listing
- `jumptab.py` — `JMP CS:W[BX+disp]` handler tables
- `scanptr.py` — far pointers pushed on the stack, and a routine-prologue
  signature for what neither of those reaches

The outer loop then re-classifies what the inner loop got wrong, into
`notcode.txt`, and runs it again until that file settles:

- `strptr.py` — far pointers consumed by the four-argument text drawer
- `glyphblk.py` — entries sitting inside an all-glyph text block

Those two channels exist because `scanptr.py`'s pushptr scan cannot tell a far
pointer-to-text from a far pointer-to-routine, and Bike Race pushes a lot of the
former. See **Text is not code** below.

Then cross-verify:

```sh
python3 asm/bikerace-2026-09/tools/xverify.py --arch x86 \
    --regions asm/bikerace-2026-09/v41/bk04.cmd \
    --lst     asm/bikerace-2026-09/v41/bk04.lst \
    --bin     roms/related-machines/bike-race/v4.1/bk04.bin \
    --base    0xE0000
```

### The disassembler needs the IO Moon baseline's patch

`dasmx86` is used as patched by
[`../baseline-2026-09/tools/dasmxx-x86-fixes.patch`](../baseline-2026-09/tools/dasmxx-x86-fixes.patch),
against upstream dasmxx at `23af0f64`. Unpatched it decodes this ROM wrongly —
the 80186 opcode extensions are missing (`bk04` uses `PUSH imm`, `IMUL imm`,
`ENTER`/`LEAVE` and shift-by-imm8 heavily), near branches escape their segment,
and the `F6`/`F7` unary group is mis-mapped. `grow.py` takes the binary's path
from `BK_DASM`, defaulting to `/code/dasmxx/src/dasmx86`.

## Text is not code

Bike Race stores its on-screen text as **indices into the DMD font**, not as
ASCII: every byte of a message is in `0x00-0x2F`, and the table is indexed with
`IMUL BX, BX, 0x2E` — 46-byte records, the same record size IO Moon uses for its
service-menu tree. It is drawn with a four-argument far call:

```
    PUSH  <seg>          far pointer to the text ...
    PUSH  <off>          ... in two pushes
    PUSH  <position>     DMD position
    PUSH  <attr>         attribute / mode
    CALL  <text drawer>  F000:06C5 in the parent set, F000:0682 in V4.1
    ADD   SP, 8
```

`strptr.py` identifies the drawer by shape rather than by address — it is the
four-push far-call target used far more often than any other, 41 sites in each
ROM — and reports every pointer it consumes. `glyphblk.py` catches the rest by
looking for runs of at least 256 bytes in which *every* byte is `<= 0x2F`, then
reporting entry points that have a whole 46-byte record still inside such a run.
Both feed `notcode.txt`.

Getting this wrong is not cosmetic. `0x0F` is a common glyph index, and on the
8086/80188 `0x0F` is `POP CS` — a real instruction, deleted on the 80286. Text
decoded as code therefore produces a dense run of `POP CS` that dasmx86 renders
faithfully and that capstone and ndisasm, which only know later CPUs, read as a
two-byte-opcode prefix. That is what the cross-verifier reports, and chasing the
"disagreement" back is what identifies the text.

## Known limits

- **Coverage is about 49.5 % of the 128 KB UMCS window in each ROM.** The rest is
  data: the text blocks, the tables the code indexes, and the zero-filled tail
  from `0xF9163` up. (The sprite table itself is not in these ROMs at all — it
  lives in the first `0x1104` bytes of ROM 06.) Only reachable code is decoded;
  nothing is decoded speculatively.
- **`bk07`, the Z80 I/O ROM, is not disassembled here.** It is a full rebuild
  relative to `bkio07` (38 % of bytes differ) and deserves the same treatment
  with `dasmz80` vs unidasm, following
  [`../baseline-2026-09/`](../baseline-2026-09/)'s Part 2. It is not on the path
  to the V4.1 rendering fault, which is settled without it.
- **Routine names are generated**, `sub_<linear>`, except where `labels.txt`
  gives one. Nothing here inherits a name from
  [`../../research/bikerace_disasm/`](../../research/bikerace_disasm/), whose
  `ndisasm` listing was produced by a different method and is not cross-verified.
