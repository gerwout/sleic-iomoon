# Cross-verification — Bike Race 80188, dasmx86 vs capstone vs ndisasm

Both listings in this directory are verified against two independent decoders.
Neither second opinion ever sees the listing: each re-decodes the same region of
the same ROM image from scratch, so agreement is triangulation rather than one
tool checking its own homework. The comparison key per instruction is
`(address, length, canonical mnemonic)`; operand text is deliberately not
compared, because the three tools format operands too differently for that to
mean anything.

## Result

```
python3 asm/bikerace-2026-09/tools/xverify.py --arch x86 \
    --regions asm/bikerace-2026-09/v41/bk04.cmd \
    --lst     asm/bikerace-2026-09/v41/bk04.lst \
    --bin     roms/related-machines/bike-race/v4.1/bk04.bin \
    --base    0xE0000
```

| | `parent` (`bkcpu04`) | `v41` (`bk04`) |
|---|---:|---:|
| code regions | 81 | 80 |
| code bytes | 64,817 | 64,776 |
| instructions compared | **21,431** | **21,461** |
| dasmx86 address missing from capstone | 0 | 0 |
| dasmx86 address missing from ndisasm | 0 | 0 |
| capstone instruction with no dasmx86 counterpart | 0 | 0 |
| ndisasm instruction with no dasmx86 counterpart | 0 | 0 |
| length or mnemonic disagreements, dasmx86 vs capstone | **0** | **0** |
| length or mnemonic disagreements, dasmx86 vs ndisasm | **0** | **0** |
| excluded as a known ndisasm decoder gap | 1 | 1 |

**All three decoders agree on every instruction in every region of both ROMs.**
A dasmxx instruction with no counterpart at the same address in another
decoder's output is not skipped silently — it is counted as a desync and fails
the run — and so is an address where another decoder drew a boundary dasmxx did
not. Both counts are zero, in both ROMs.

## The one exclusion

`F100F` in the parent and `F0FCC` in V4.1: an `FF /2` or `FF /4` with a register
operand, which ndisasm does not decode. capstone and dasmx86 agree with each
other on it. This is a pre-existing, documented ndisasm gap
(`is_ndisasm_known_gap` in the tool) inherited from the IO Moon baseline, not a
question about these ROMs.

## Two things the run had to be told, and why

Getting to zero took two corrections. Both are recorded in the per-set
`notcode.txt` and `csdata.txt` with their evidence, and both are real
classification facts about the ROM rather than concessions to a tool.

**Text decoded as code.** `scanptr.py`'s pushptr channel seeds a code entry point
for every far pointer it sees pushed, and cannot tell a pointer-to-text from a
pointer-to-routine. Bike Race pushes a great many of the former: its on-screen
messages are stored as DMD font indices, every byte in `0x00-0x2F`, in 46-byte
records. Decoded as code they produce a dense run of `POP CS` — opcode `0x0F`,
a real 8086/80188 instruction deleted on the 80286, which capstone and ndisasm
read instead as a two-byte-opcode prefix. That is what the first runs reported:
33 and 34 disagreements, 71 skips, 46 extras, every one of them inside a text
block. `strptr.py` and `glyphblk.py` identify those blocks and feed
`notcode.txt`; see the repository's [`../README.md`](../README.md).

**Far pointers stored in the code segment.** `sub_F08E6` (parent) / `sub_F08A3`
(V4.1) loads two sprite pointers out of its own `CS` with
`LES SI, CS:[0A45]`/`CS:[0A49]` and `CS:[0A02]`/`CS:[0A06]`. The eight bytes
those name are data sitting inside the code region. Decoded as code, the second
pointer's first byte `D6` is the undocumented 8086 `SALC`, which dasmx86 does
not implement and both other decoders do — the single remaining disagreement
after the text blocks were resolved. `csdata.txt` carves the span out as a byte
dump. The pointers themselves are `2000:0636` and `2000:0BD6`, identical in both
ROMs, and they matter to
[`v41_sprite_table.md`](v41_sprite_table.md).

## 80186-only encodings in the decoded code

The same counts in both ROMs, which is why the unpatched upstream dasmxx cannot
be used here: without the 80186 extensions these all mis-decode, and each
mis-decode drags the instruction stream out of sync behind it.

| opcode | mnemonic | count |
|---|---|---:|
| `68` | `PUSH imm16` | 883 |
| `6A` | `PUSH imm8` | 692 |
| `6B` | `IMUL r16, r/m16, imm8` | 216 |
| `C0` | `SHL/ROL… r/m8, imm8` | 12 |
| `C1` | `SHR/SAR… r/m16, imm8` | 22 |
| `C8` | `ENTER` | 9 |
| `C9` | `LEAVE` | 9 |

## Coverage

49.5 % of the 128 KB UMCS window in the parent, 49.4 % in V4.1. The remainder is
data and is not decoded: the sprite table in ROM 06's first `0x1104` bytes is on
another chip entirely, but within these code ROMs it is the text blocks, the
tables, and the zero-filled tail from `0xF9163` up. Nothing is decoded
speculatively — every region traces back to an entry point in `entries.txt` with
the evidence that produced it.
