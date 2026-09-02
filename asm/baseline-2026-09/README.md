# IO Moon -- 2026-09 baseline disassembly

Fresh, independently derived disassemblies of **both** IO Moon (SLEIC, 1994)
CPU ROMs, built with [dasmxx](https://github.com/nejohnson/dasmxx) and
cross-checked against independent decoders:

* **Part 1 -- the 80188 game/sound CPU** (`V1 3_01.bin`), `dasmx86` vs
  capstone vs ndisasm. That is everything up to "Known limits".
* **Part 2 -- the Z80 I/O CPU** (`V1 3_05.bin`), `dasmz80` vs unidasm.
  Starts at "Part 2 -- the Z80 I/O CPU (IC5)".

**Nothing here was taken from the older `asm/80188_annotated.asm`,
`asm/z80_annotated.asm` or from `docs/*.md`.** Old addresses were used only
as *probes* -- "decode here and see whether a coherent handler is really
there" -- and each part's "Agreement and disagreement with the older
material" section records what that check confirmed and what it
contradicted. Every region, label and claim below is justified by the
instruction stream decoded in this directory.

## Files

80188 side:

| file | what it is |
|---|---|
| `entries.txt` | the code entry points, one per line, with the evidence that produced each |
| `labels.txt` | hand-given provisional names, applied on top of the generated ones |
| `iomoon_80188.cmd` | the dasmxx command list (generated -- do not hand-edit) |
| `iomoon_80188.lst` | the listing dasmx86 produces from it |
| `reports/regions.md` | region inventory + classification of everything not decoded as code |
| `reports/jumptables.md` | every recovered `JMP CS:W[BX+disp]` table, with its entries |
| `reports/186scan.md` | Task 3's 80186-opcode pre-scan |
| `reports/xverify_80188.md` | dasmx86 vs capstone vs ndisasm cross-verification: alias table, disagreement resolutions, final stats |
| `tools/grow.py`, `jumptab.py`, `scanptr.py`, `inventory.py`, `probe.py`, `scan186.py`, `rebuild.sh` | the scripts that drive dasmx86 and generate the above |
| `tools/dasmxx-x86-fixes.patch` | the dasmxx x86 changes this baseline depends on |

Z80 side:

| file | what it is |
|---|---|
| `entries_z80.txt` | the code entry points, one per line, with the evidence that produced each |
| `labels_z80.txt` | hand-given provisional names, applied on top of the generated ones |
| `iomoon_z80.cmd` | the dasmxx command list (generated -- do not hand-edit) |
| `iomoon_z80.lst` | the listing dasmz80 produces from it |
| `reports/xverify_z80.md` | dasmz80 vs unidasm cross-verification: RED tests, the `DB nn` parsing defect it caught, final stats |
| `tools/growz80.py`, `jumptabz80.py`, `orphanz80.py`, `iotabz80.py`, `rebuild_z80.sh` | the scripts that drive dasmz80 and generate the above |
| `tools/dasmxx-z80-fixes.patch` | the dasmxx Z80 change this baseline depends on |

Shared:

| file | what it is |
|---|---|
| `tools/xverify.py` | the cross-verifier for both parts: `--arch x86` (dasmx86/capstone/ndisasm) and `--arch z80` (dasmz80/unidasm) |

## Address arithmetic

The ROM analysed is `roms/1.3 IPDB latest/V1 3_01.bin`, 512 KiB, the 80188's
program ROM (chip 01 of the V1.3 set).

```
linear (flat 80188 address) = file offset + 0x80000
file offset                 = linear - 0x80000

segment D000:xxxx  = linear 0xD0000 + xxxx = file 0x50000 + xxxx
segment F000:xxxx  = linear 0xF0000 + xxxx = file 0x70000 + xxxx
reset vector FFFF0                          = file 0x7FFF0
```

Only part of that image is visible to the CPU as code. The boot code's own
chip-select programming (decoded below) puts **UMCS over
`0xC0000-0xFFFFF`**, so the listing covers `0xC0000-0xFFFFF`, i.e. the upper
256 KiB of the file (`0x40000-0x7FFFF`).

The lower 256 KiB of the file is not in the UMCS window. What the code
*does* establish about it: the boot table puts **LMCS over
`0x00000-0x3FFFF`**; decoded code repeatedly reads data out of segment
`0000` (`MOV AX,0 / MOV ES,AX / MOV AL,ES:B[2C9B]`-style) and never writes
it; and ROM1 file offset `0x0000-0x00FF` holds a coherent interrupt vector
table whose live entries point at real handlers (§ *Step 1b*). Since the
80188 fetches vectors from physical `0` and physical `0` is inside the LMCS
ROM window, the low part of this ROM image must be what LMCS presents there
-- that last step is an inference from the code, not something the code
states.

Listing addresses are flat, but near branches are computed **within the
segment**, so each region carries the CS value it runs under (`entries.txt`
column 2, emitted as dasmxx `g` commands). Far pointers are printed as
`SEG:OFF {flat}` so both forms are visible.

## Step 1 -- the reset vector, decoded by hand

```
$ xxd -s 0x7fff0 -l 16 "roms/1.3 IPDB latest/V1 3_01.bin"
0007fff0: ea00 00f0 ff00 0000 0000 0000 0000 0000

FFFF0:  EA 00 00 F0 FF      JMP FAR FFF0:0000     -> flat FFF00 (file 0x7FF00)
```

At `FFF00`:

```
FFF00:  BA A0 FF            MOV DX, 0FFA0         ; UMCS register
FFF03:  B8 3C C0            MOV AX, 0C03C
FFF06:  EF                  OUT DX, AX            ; UMCS = C03C -> ROM at C0000-FFFFF
FFF07:  EA 00 00 00 D0      JMP FAR D000:0000     -> flat D0000 (file 0x50000)
```

At `D0000` the real init runs: `CLI`, `SS=4152 / SP=0205` (stack top flat
`0x41725`), `DS=ES=4000`, then

```
D0012:  BE 41 00            MOV SI, 00041         ; table at CS:0041
D0015:  B9 1E 00            MOV CX, 0001E         ; 30 iterations
D0018:  2E AD               LODSW                 ; <- loop top
D001A:  8B D0               MOV DX, AX            ;    port
D001C:  2E AD               LODSW                 ;    value
D001E:  EF                  OUT DX, AX
D001F:  E2 F7               LOOP 0D0018
```

`CX = 0x1E` = **30** iterations, each consuming a 4-byte (port, value) pair,
so the table is 120 bytes spanning `CS:0041..CS:00B9` -- ending exactly on
`D000:00B9`, which is the first routine the boot code far-calls. That
coincidence is the check that the extent is right.

Then five far calls (`D000:00B9`, `D000:011C`, `D000:00FA`, `F000:0000`,
`D000:0B2B`), `STI`, and `JMP FAR D2F2:0002`.

All 30 entries of the table at `CS:0041` (file `0x50041`), read out directly,
in the order the loop writes them:

| # | I/O | value | 80188 register | effect |
|---|---|---|---|---|
| 0 | `FFA2` | `3FFC` | LMCS | low memory `00000-3FFFF` |
| 1 | `FFA6` | `41FC` | MMCS | mid-range memory base `40000` |
| 2 | `FFA4` | `A03C` | PACS | peripheral chip-select base `A0000` |
| 3 | `FFA8` | `A0FC` | MPCS | peripherals memory-mapped, 7 PCS lines, 4x64K mid-range blocks |
| 4 | `FF56` | `E003` | T0 mode/control | timer 0 enabled, interrupt on, alternating max counts, continuous |
| 5 | `FF52` | `6276` | T0 max count A | 25206 counts |
| 6 | `FF54` | `6276` | T0 max count B | same, so a uniform ~99.2 Hz at CLKOUT/4 = 2.5 MHz |
| 7 | `FF50` | `0000` | T0 count | cleared |
| 8 | `FF5E` | `0000` | T1 mode/control | timer 1 **disabled** |
| 9 | `FF66` | `0000` | T2 mode/control | timer 2 **disabled** |
| 10 | `FF32` | `0001` | timer int control | **unmasked**, priority 1 |
| 11 | `FF34` | `000F` | DMA0 int control | masked (MSK=1), priority 7 |
| 12 | `FF36` | `000F` | DMA1 int control | masked |
| 13 | `FF38` | `0000` | INT0 control | **unmasked**, priority 0, edge triggered |
| 14 | `FF3A` | `000F` | INT1 control | masked |
| 15 | `FF3C` | `000F` | INT2 control | masked |
| 16 | `FF3E` | `000F` | INT3 control | masked |
| 17 | `FF2A` | `0001` | PRIMSK | service priority levels 0-1 only |
| 18 | `FFCA` | `FFA0` | DMA0 control word | written first, with **ST (bit 1) = 0**: channel programmed but not started |
| 19 | `FFDA` | `FFA0` | DMA1 control word | same |
| 20 | `FFC8` | `0001` | DMA0 transfer count | 1 |
| 21 | `FFD8` | `0001` | DMA1 transfer count | 1 |
| 22 | `FFC6` | `000F` | DMA0 dest pointer, high | destination = `F:FFF2` |
| 23 | `FFD6` | `000F` | DMA1 dest pointer, high | |
| 24 | `FFC4` | `FFF2` | DMA0 dest pointer, low | = flat `FFFF2` |
| 25 | `FFD4` | `FFF2` | DMA1 dest pointer, low | |
| 26 | `FFC2` | `000F` | DMA0 source pointer, high | source = `F:FFF0` |
| 27 | `FFD2` | `000F` | DMA1 source pointer, high | |
| 28 | `FFC0` | `FFF0` | DMA0 source pointer, low | = flat `FFFF0` |
| 29 | `FFD0` | `FFF0` | DMA1 source pointer, low | |

`UMCS = C03C` is written by the reset stub before this table runs.

Reading the whole table rather than its first half does not change the
conclusion, and makes it stronger: of the eight maskable sources, **only
timer 0 (priority 1) and INT0 (priority 0) are unmasked** -- DMA0, DMA1 and
INT1/INT2/INT3 all have MSK set -- and `PRIMSK = 1` additionally restricts
service to priority levels 0 and 1, which is exactly the pair that is
enabled. That matches the vector table having exactly three live entries
(NMI, which is not maskable, plus timer and INT0).

Both DMA channels are **configured but parked**. The control word `FFA0`
has ST (bit 1, start/stop) clear *and* CHG (bit 2) clear, so the write
cannot start the channel even accidentally; it is written *before* the
pointers and count, the correct "program while stopped" order. The
source/destination they are pointed at (`FFFF0` -> `FFFF2`, one byte) lies
inside the reset vector itself and is not a meaningful transfer -- it reads
as putting the registers in a harmless known state rather than preparing
real DMA.

Nothing ever restarts them, and this is checkable rather than assumed: the
**only** 80188 peripheral-control-block registers written anywhere in the
decoded code, outside this boot table, are `FF2C` (INSERV -- the two EOI
writes at the end of the timer and INT0 handlers) and `FFA0` (UMCS, in the
reset stub). No code reprograms a chip select, a timer, the interrupt
controller or a DMA channel after boot.

## Step 1b -- the interrupt vector table

The brief expected an IVT copy loop in the boot path. **There is none, and
there cannot be one**: physical `0` is inside the LMCS ROM window, not RAM.
The table is instead resident in ROM, at **ROM1 file offset `0x0000`**, which
the CPU sees at physical `0` through LMCS.

Evidence: 64 four-byte entries at file `0x0000-0x00FF` are all
`IP=F000, CS=FFF0` filler except three, and those three point at coherent
interrupt handlers (`PUSHF; PUSH AX; ...; POPF; IRET`). From `0x0100` on, the
data stops looking like vectors entirely. Independently, a full-ROM byte
scan finds no `MOV ES,0`-then-store sequence anywhere -- segment `0` is only
ever *read*.

| vector | file offset | handler | what it does |
|---|---|---|---|
| `02` (NMI) | `0x0008` | `D000:016D` | reads PCS2 `A0100`; byte `0x32` bumps `[4000:1144]`, anything else is appended to the `4000:1220` byte log and sets the flag `[4000:1147]` |
| `08` (timer) | `0x0020` | `D000:024F` | OKI duration counters, `oki_trigger_a`/`_b`, general down-counters; ends `IN AX,FF2C / AND AX,00FE / OUT` (clear INSERV bit 0 = timer) |
| `0C` (INT0) | `0x0030` | `D000:0343` | `qout_service_pcs1`, `fm_player_tick`, animation calls; ends `AND AX,00EF` (clear INSERV bit 4 = INT0) |

The two EOI writes are themselves confirmation that the vector numbers are
read correctly: the handler at `0x08` clears the *timer* in-service bit and
the handler at `0x0C` clears the *INT0* in-service bit.

## Step 2/3 -- how the command file was built

`iomoon_80188.cmd` is generated, never hand-edited. `entries.txt` holds the
entry points, `tools/grow.py` turns them into regions and runs dasmx86:

1. **Extent.** For each entry, dasmx86 disassembles a window starting there
   and `grow.py` reads the result: linear sweep, extended over every forward
   branch it sees, stopping at the first `RET`/`RETF`/`IRET`/unconditional
   `JMP` that no in-region branch jumps past.
2. **Merge.** Overlapping spans merge only when they carry the same CS.
3. **Emit.** One `g`/`c` pair per region, `b` byte dumps for everything
   between them, `l` labels for entries inside a region.
4. **Grow.** dasmx86 runs with `-x` over the whole window; every `Call`/`Jump`
   cross-reference whose target is outside a region becomes a new entry, with
   the CS taken from the far pointer's own operand (opcode `9A`/`EA`) or
   inherited from the referring region.

Direct call graph alone stops well short, because this firmware hides code
behind several indirect constructs. Each has its own scanner, and every
address they produce is validated by decoding it:

* `tools/jumptab.py` -- `JMP CS:W[BX + disp]` handler tables. Two shapes:
  `CMP BX,n / JNBE / SHL BX,1 / JMP CS:W[BX+disp]` (table at `CS:disp`,
  `n+1` entries) and `MOV CX,n / MOV BX,base / <key search> / JMP
  CS:W[BX+disp]` (parallel handler table at `CS:base+disp`, `n` entries).
  Both the base and the entry count come from the code, never from a guess;
  a jump whose shape does not match either is left alone. The recovered
  table sizes land exactly on the next code region's start in every case
  that could be checked, which is a strong independent confirmation.
* `tools/scanptr.py pushptr` -- `PUSH <seg>; PUSH <off>` far function
  pointers, later invoked through `CALL W[BP+n]` (`FF /3`).
* `tools/scanptr.py dispatch` -- `MOV W[10F6],imm` / `MOV W[10F8],imm`. The
  dispatcher at `F000:1303` is `MOV AX,[4000:10F6]; JMP AX`, and the
  handlers it reaches do the same with `[10F8]`, so each immediate stored to
  either is an entry point in segment `F000`.
* `tools/scanptr.py prologue` -- a last-resort byte-signature match for
  `CLI / PUSH DS / MOV AX,4000 / MOV DS,AX` in still-undecoded space, which
  picks up members of the segment-`F000` animation-routine family that
  nothing else reaches. This is the weakest channel -- it asserts nothing
  about control flow -- so it is deliberately isolated in its own scanner.
  Its footprint: **150** sites match the signature inside the UMCS window,
  **58** of them were still undecoded when the scanner ran and became
  entries in `entries.txt` (tagged `# prologue`), and **0 of the 83 regions
  depend on it exclusively** -- every region containing a prologue-derived
  entry also contains an entry reached by a control-flow channel. So even
  if the signature were unsound, no region would be lost, and the baseline
  can be rebuilt without the scanner.

`tools/rebuild.sh` iterates all of them to a joint fixed point.

### Reproducing

```bash
cd sleic-iomoon
# incremental, over whatever entries.txt already holds:
sh asm/baseline-2026-09/tools/rebuild.sh
# or from scratch: discard everything below the hand-derived seed block and
# rediscover it, then regenerate .cmd/.lst and cross-check against capstone:
sh asm/baseline-2026-09/tools/rebuild.sh --from-seed

python3 asm/baseline-2026-09/tools/inventory.py > asm/baseline-2026-09/reports/regions.md
python3 asm/baseline-2026-09/tools/jumptab.py --tables   # -> reports/jumptables.md body
```

To inspect one address without touching the baseline:

```bash
python3 asm/baseline-2026-09/tools/probe.py <flat-hex> <len-hex> [<CS-hex>]
```

and to run dasmx86 by hand on the committed command file (**from the
repository root** -- the ROM path inside it is repository-relative and
dasmxx resolves it against the current directory):

```bash
cd sleic-iomoon
~/iomoon/tools/dasmxx/src/dasmx86 -x asm/baseline-2026-09/iomoon_80188.cmd
```

## dasmx86 patches this baseline depends on

`~/iomoon/tools/dasmxx` is a separate checkout outside this repository, so
the changes are not committed there. They are captured here as
**`tools/dasmxx-x86-fixes.patch`**, which applies cleanly to upstream commit
`23af0f649268c17644fa1ab9ae0594e93b67721e`:

```bash
git -C ~/iomoon/tools/dasmxx apply \
    asm/baseline-2026-09/tools/dasmxx-x86-fixes.patch
cd ~/iomoon/tools/dasmxx/src && make dasmx86
```

Task 3 added the 80186 opcode extensions. This task found and fixed five
more defects, each verified against capstone and against dasmxx's own x86
test suite:

1. **Near branch targets escaped the segment.** `disp8`/`disp16` computed
   `pc + disp` in a flat address space, so any backwards branch produced a
   target 0x10000 too high (`E9 F0 FF` at `00100` gave `100F3` instead of
   `000F3`). Targets are now wrapped modulo 64K around a segment base.
2. **No segment base existed.** Added a `g<base>` command to dasmxx
   (`struct fmt` field, parser case, propagation at every clist advance) so
   each region can name the CS it runs under -- needed because `D2F2`,
   `D72A`, `DD25` and `E326` are not 64K-aligned.
3. **`ADC r/m,imm` never decoded, and `AND`/`OR`/`XOR` lacked their `0x83`
   form.** The `80/81/83` group's ADC entry used mask value `0x80`, outside
   the `0x38` REG-field mask, so it could never match.
4. **The `F6/F7` group was mapped onto `FE/FF`.** `NOT/NEG/MUL/IMUL/DIV/IDIV`
   were coded against opcodes `FE`/`FF` instead of `F6`/`F7`. That both hid
   the real group-3 instructions (`F6`/`F7` fell through to a catch-all
   "`TEST r/m,imm`" that swallowed 1-2 following bytes -- a *silent resync
   error*) and hijacked the `FF` group, so `CALL`/`JMP`/`PUSH r/m` decoded as
   `NOT`/`MUL`/`IMUL`/`DIV`. dasmxx's own test suite contained an instance
   (`FF 20`, now correctly `JMP W[BX+SI]`, previously `MUL`).
5. **`MOV Sreg` with REG >= 4 crashed the disassembler.** `segreg[reg+1]`
   indexed a 5-element array with 5..8 and handed `operand()` a wild
   pointer; a data byte pair like `8C 34` was enough to SIGSEGV, truncating
   the listing silently. Bounded, now prints `?SEG?`.

Two smaller changes: far pointers (`9A`/`EA`) now register a cross-reference
at the flat target and print it as `SEG:OFF {flat}` (they registered none,
so far calls -- this firmware's dominant idiom -- were invisible in `-x`),
and the x86 profile's max instruction length went from 5 to 8 bytes so that
6-8 byte instructions show all their bytes in the listing.

`grow.py` now treats a non-zero dasmx86 exit as fatal; defect 5 above
produced a *truncated but plausible-looking* listing that went unnoticed
until the exit status was checked.

## Verification

`tools/xverify.py` re-disassembles every decoded region with **two**
independent decoders -- capstone (16-bit mode) and `ndisasm -b16` -- and
compares each against the committed dasmx86 listing on (address, length,
canonical mnemonic), with every skip/extra/disagreement counted and named
rather than silently dropped:

```
python3 asm/baseline-2026-09/tools/xverify.py --arch x86 \
    --regions asm/baseline-2026-09/iomoon_80188.cmd \
    --lst asm/baseline-2026-09/iomoon_80188.lst \
    --bin "roms/1.3 IPDB latest/V1 3_01.bin" \
    --base 0x80000
```

```
regions: 83   code bytes: 88177
instructions compared: 29810
dasmx86 addr missing from capstone/ndisasm decode: 0 / 0
capstone/ndisasm addr with no dasmx86 counterpart: 0 / 0
dasmx86 vs capstone/ndisasm disagreements: 0 / 0
excluded from the ndisasm comparison (confirmed ndisasm 3.01 decoder gap): 19
```

Zero skips and zero disagreements is the load-bearing result: it means all
three decoders agree on every instruction boundary and mnemonic across the
whole region set, so none of them has desynchronised anywhere. The 19
exclusions are a confirmed ndisasm 3.01 defect (it cannot decode the
register-operand form of `FF /2`/`FF /4`, i.e. `call`/`jmp` through a
register), not a baseline question -- dasmx86 and capstone agree on all 19.
Full alias table, the ndisasm-gap investigation and final stats are in
`reports/xverify_80188.md`.

Further checks:

* **Zero `???` bytes** in the decoded regions.
* **Zero uncovered far-call targets.** A raw byte scan of the *entire* ROM
  for `9A`/`EA` followed by any CS value seen in real code finds no target
  outside a decoded region.
* The listing contains exactly 29810 code lines, the same number the
  cross-check disassembled -- so nothing was silently truncated.
* Every one of the 83 regions ends on a terminator: 72 on `RETF`, 9 on an
  unconditional `JMP`, 2 on `RETN`.
* No region extent hit the sweep's window cap, so no region end is an
  artefact of the search limit.
* Recovered jump-table sizes end exactly where the next code region begins.

### 80186 opcodes actually used (Task 3's open question)

Task 3 could confirm only some of the 186-only encodings and left the rest
for "when there is a region map". There now is one; inside the 29810
decoded instructions -- and `xverify.py` recounts this table on every run
(not just once), so a future rebuild that changes which 80186-only
encodings occur is caught automatically instead of silently going stale:

| encoding | count |
|---|---|
| `68` `PUSH imm16` | 1539 |
| `6A` `PUSH imm8` | 813 |
| `6B` `IMUL r,r/m,imm8` | 209 |
| `C8` `ENTER` | 12 |
| `C9` `LEAVE` | 12 |
| `C0` shift/rotate by imm8 | 5 |

`PUSHA`, `POPA`, `BOUND`, `INSB/INSW`, `OUTSB/OUTSW`, `69` (`IMUL` with a
16-bit immediate) and `C1` (word shift by imm8) **do not occur in decoded
code at all** -- Task 3's suspicion that its hits for those were linear-scan
noise is confirmed.

## What the decoded code says about the hardware

These follow directly from the instruction stream and are recorded because
the driver work depends on them.

* **PACS peripherals** (base `0xA0000`, `0x80` spacing).
  `PCS0 = A0000`: a write-only control byte, shadowed in `[4000:1134]`.
  Bit 5 is the OKI chip-select strobe (`okcs_strobe` clears then sets it
  around every OKI latch write). Bits 3 and 4 form a two-state window
  select toggled around every access to segment `5040`
  (`pcs0_window_open`/`_close`).
  `PCS1 = A0080`: outbound byte latch (`qout_service_pcs1`).
  `PCS2 = A0100`: inbound byte latch, read by the NMI handler.
  `PCS3 = A0180`: bit 0 is the ready/handshake input polled before writing
  PCS1.
  `PCS4 = A0200`: control/strobe byte, shadowed in `[4000:1138]`; bit 3
  strobed at boot, bits 5 and 6 strobed around each PCS1 write, bit 7 and
  bit 4/6 patterns used by the NMI handler.
  `PCS5 = A0280`/`A0281`: YM3812 index and data (`ym3812_write`).
  `PCS6 = A0300`: OKI MSM6376 sample/control latch.
* **Two byte queues in work RAM**, both set up at boot.
  `4000:1158` with pointers `[114C]` (read) / `[114E]` (write) is
  *outbound*: `qout_push` fills it and `qout_service_pcs1`, called from the
  INT0 handler, drains it to PCS1.
  `4000:1220..12E7` with far pointers `[1150]:[1152]` (read) /
  `[1154]:[1156]` (write) is *inbound*: the NMI handler appends bytes read
  from PCS2 and sets `[1147]`; `inbound_byte_take_a`/`_b` and about a dozen
  sibling copies drain it.
* **Memory map from MMCS/MPCS.** `MPCS = A0FC` selects a 256 KiB mid-range
  region in four 64 KiB blocks from `MMCS` base `0x40000`, which matches the
  segments the code actually uses: `4000`/`4130`/`4134`/`4137`/`413C`/`4152`
  (work RAM and stack) in the first block, `5040` in the second, and `7000`
  in the fourth -- `boot_ram_var_init` clears `7000:0000-03FF`, exactly two
  128x32 bitplanes.
* **Segment `5040` is a non-volatile store.** Every access is bracketed by
  the PCS0 window toggle, it is read during boot before anything else, and
  records are written in triplicate -- one routine writes a single value to
  `5040:0083`, `5040:0116` and `5040:020C`, and another reads the three
  copies back and compares them -- the classic EEPROM integrity pattern.
  The board's 28C64A is the obvious candidate but nothing in the code names
  it.
* **Animation/graphics data is addressed inside the LMCS window.** A
  620-byte far-pointer table at `F5183-F53EF` (155 entries) is read by the
  animation routines with `LES SI, CS:52xx/53xx` -- e.g. `F0750`, `F138F`,
  `F2ECB`, `F4954`. Of its 155 pointers, **146 address segments `0000`,
  `1000`, `2000` and `3000`** -- flat `00000-3FFFF`, i.e. the LMCS window --
  and the remaining 9 address segment `4000` work RAM. So the bulk of the
  image data the animation code streams does not live in the UMCS code ROM
  at all; it is fetched through LMCS, which is the same window the IVT is
  read from. Directly relevant to how the graphics ROM has to be banked.
* **A copyright block sits at `D000:07A9`**: "(C) SLEIC 1.994 / (C)
  CREACIONES E INVESTIGACIONES ELECTRONICAS, S.L. / (C) LUIS GOSALBEZ
  CARRASCO 1.994 / AV.VALDELAPARRA, 3. POLIGONO I..." -- 288 bytes of ASCII
  correctly classified as data, not code.

## Agreement and disagreement with the older material

Old addresses were used only as probes. Decoding them fresh:

**Confirmed** -- `cmd_queue_push` at `D000:0138`; the NMI/DMD handler at
`D000:016D`; the OKI trigger routines at `D000:0C57` and `D000:0C84` and
their duration table at `CS:0C1F`; the FM player tick at `D000:0D1B` and
sequencer at `D000:0D37` with control bytes `EE`/`EF`/`FF`/`DD`; the OPL2
write primitive at `D000:0D99` writing `A0280` then `A0281`; song select at
`D000:0DB4`; the chip-select values `UMCS=C03C`, `LMCS=3FFC`, `PACS=A03C`,
`MMCS=41FC`, `MPCS=A0FC`; the OKI `/OKCS` strobe being bit 5 of `A0000`; the
DMD staging buffer being `7000:0000-03FF`; the `A0180` bit-0 ready flag and
`A0080` command latch; that the 80188 -- not the Z80 -- drives both sound
chips; and that the **two DMA channels are configured but parked** -- now
shown from the boot table's own DMA entries (control word written first
with ST and CHG clear) together with the fact that no code outside that
table writes any DMA register.

**Contradicted or refined:**

* The IVT is **not copied to physical 0 by a boot loop**; it is a ROM
  table at ROM1 file offset 0, seen at physical 0 through LMCS. No code
  anywhere in the ROM writes segment 0.
* `D000:0343` is the **INT0** handler (IVT type `0C`), not a timer handler.
  The timer 0 handler is `D000:024F` (IVT type `08`), and it is the one that
  drives the OKI. Old material describing a "sound timer ISR at `D000:0250`"
  is one byte past the real vector.
* PCS0 bit 4 (with bit 3) gates access to the **segment-5040 store**, not a
  graphics-ROM bank; bit 5 is the OKI strobe. Whether the same latch also
  banks LMCS cannot be settled from this ROM's code alone -- no code here
  writes PCS0 for that purpose.
* Segment `4000` is much more finely structured than "work RAM": the code
  uses `4000`, `4130`, `4134`, `4137`, `413C` and `4152` as distinct bases.
* `main_entry` at `D2F2:0002` is a boot/attract *prologue*; the actual main
  loop is the four-way dispatch at `D2F2:00E2` (flat `D3002`) on the mode
  byte at `413C:014F`.

## Known limits

* Coverage is limited to what is reachable from the reset vector, the three
  live interrupt vectors, and the three indirect constructs above. Code
  reachable only through some fourth mechanism would be missed -- though the
  full-ROM far-call scan finding nothing outside the regions makes a large
  miss unlikely.
* Labels are provisional and describe observed peripheral/RAM traffic.
  Where a name implies purpose (`nvstore_*`, `anim_*`) the evidence for it is
  in `labels.txt` and above; treat it as a hypothesis, not a fact.
* Data structures (jump tables, the FM song data at `D0DE5-D2F22`, the
  animation record tables) are classified as non-code but not yet decoded.

---

# Part 2 -- the Z80 I/O CPU (IC5)

A fresh disassembly of `roms/1.3 IPDB latest/V1 3_05.bin` (32 KiB, the 27C256
at IC5 on the Z80 board), built with `dasmz80` and cross-checked against
`unidasm -arch z80`.

Same rule as Part 1: `asm/z80_annotated.asm` and `docs/z80_io_ports.md` were
used only as *hypotheses to probe*. Every address below was decoded fresh,
and "Agreement and disagreement with the older material (Z80)" records what
that confirmed and what it did not.

## Address arithmetic

The Z80's address space is flat and 16-bit, and the ROM is selected from
`0x0000`, so throughout this part:

```
listing address == ROM file offset
```

Programmed content occupies `0x0000-0x4FD4`; `0x4FD5-0x7FFF` is unprogrammed
`0xFF`. Work RAM is at `0xC000` upward (the boot code sets `SP = 0xC7FF` and
every RAM access decoded lands in `C000-C127`).

## Step 1 -- the hardware entry points, decoded by hand

```
$ xxd -l 16 "roms/1.3 IPDB latest/V1 3_05.bin"
00000000: 0000 ed56 f300 00c3 0004 00c3 0004 00c3

0000:  00              NOP
0001:  00              NOP
0002:  ED 56           IM   1          <- interrupt mode read from the ROM, not assumed
0004:  F3              DI
0005:  00 00           NOP NOP
0007:  C3 00 04        JP   $0400      <- the real boot code
```

`0400` re-establishes it and sets up the machine:

```
0400:  F3              DI
0401:  ED 56           IM   1
0403:  31 FF C7        LD   SP, #$C7FF
0406:  CD 1B 04        CALL boot_port_init     ; writes all 8 output ports + shadows
0409:  CD 5A 04        CALL boot_ram_init
040C:  FB              EI
040D:  CD A7 36        CALL sub_36A7
0410:  3E 47 / 32 FC C0 / CD 16 01              ; sends 0x47 to the 80188
0418:  C3 4C 0D        JP   main_loop
```

**Interrupt mode 1 is settled by the code, three ways over.** `ED 56` (`IM 1`)
appears at `0002` and `0401` and **nowhere else**; there is no `IM 0`
(`ED 46`), no `IM 2` (`ED 5E`) and no `LD I,A` (`ED 47`) anywhere in the
decoded listing. So every maskable interrupt vectors to the fixed address
`0x0038`:

```
0038:  C3 42 0A        JP   $0A42      <- irq_handler
```

and `irq_handler` is confirmed to be an interrupt handler by how it ends --
`POP HL / POP DE / POP BC / POP AF / EI / RETI` at both of its exits (`0B6C`
and `0C95`). Those are the listing's only two `RETI`s.

The **NMI** vector at `0x0066` is likewise confirmed by its exit: it is the
listing's only `RETN` (`ED 45` at `00A5`). It uses the alternate register set
rather than the stack (`EX AF,AF' / EXX` on entry, the reverse on exit), and
its body is short and specific:

```
0066:  08 / D9                     EX AF,AF' / EXX
0068:  2A 74 C0                    LD  HL, ($C074)        ; ring-buffer write pointer
006B:  7E / A7 / C2 7C 00          LD A,(HL) / AND A / JP NZ,$007C   ; wrap when the slot is used
0070:  21 76 C0 / 22 72 C0 / 22 74 C0                     ; reset both pointers to $C076
0080:  3A 01 C0 / E6 FE / F6 10 / 32 01 C0 / D3 81        ; port-81 bit 4 set, bit 0 cleared
008C:  DB 00                       IN  A, ($00)           ; <- the inbound byte
008E:  77 / 23 / 36 00             LD (HL),A / INC HL / LD (HL),#$00
0092:  3A 01 C0 / E6 EF / F6 01 / 32 01 C0 / D3 81        ; port-81 bit 4 cleared again
009E:  21 45 C0 / 36 30            LD HL,#$C045 / LD (HL),#$30
00A3:  D9 / 08 / ED 45             EXX / EX AF,AF' / RETN
```

So the **NMI is the 80188 -> Z80 byte channel**: one byte read from port
`0x00` and appended to a ring buffer based at `$C076`, with `$C074` as the
write pointer and `$C072` as the read pointer. `host_cmd_dispatch` at `16D5`
is the consumer (below).

### The RST vectors are not used

`RST 08` (`0x0008`) lands on `00 04 00` -- `NOP / INC B / NOP` -- and then
the `JP $0400` at `000B`, so it restarts the machine. `RST 10` (`0x0010`)
lands *inside* the `C3 00 04` at `000F`, decoding as `NOP / INC B` and then
running into the `0xFF` filler at `0012`, which decodes as `RST $38` and
therefore lands in `irq_handler` -- clearly not a designed path. `RST 18`,
`20`, `28` and `30` all land in that same filler.

None of this matters, because **the listing contains zero `RST`
instructions**: 4760 decoded instructions, 32 distinct mnemonics, `RST` not
among them. The `0007`/`000B`/`000F` triple reads as belt-and-braces padding
of the vector page rather than as live vectors. (The third copy, at
`000E-0011`, is the only piece of real-looking code in the ROM this baseline
leaves classified as data: nothing reaches it, and it is 4 bytes.)

Seed entries are therefore `0000` (reset), `0008` (the RST 08 landing),
`0038` (the IM 1 vector) and `0066` (NMI) -- see `entries_z80.txt`.

## Step 2 -- how the command file was built

`iomoon_z80.cmd` is generated, never hand-edited; `entries_z80.txt` holds the
entry points and `tools/growz80.py` turns them into regions and runs dasmz80.
The extent rule is the Z80 analogue of Part 1's: linear sweep from the entry,
extended over every **conditional** `JP`/`JR` (and `DJNZ`) target, stopping
at the first unconditional `RET`/`RETI`/`RETN`/`JP`/`JR` that no in-region
conditional branch jumps past.

Two Z80-specific wrinkles, both handled in `growz80.py`:

* An **unconditional** `JP`/`JR` ends the region and its target becomes a
  separate entry (via the `-x` cross-reference dump), instead of extending
  the region across the jump as Part 1's `grow.py` does for `JMP`. On this
  ROM the very first instruction pair -- `JP $0400` at the reset vector --
  would otherwise absorb the whole `0012-03FF` filler-and-vector area into
  one bogus "code" region.
* `0xFF`, the unprogrammed-EPROM byte, decodes as the *valid* instruction
  `RST $38`, which falls through. A sweep that ran off the end of a routine
  into filler would never terminate, so the sweep stops at a run of four or
  more consecutive `0xFF` bytes (safe here precisely because the ROM contains
  no real `RST`).

Three discovery channels, run by `tools/rebuild_z80.sh` in **two phases**:

1. **`growz80.py add`** -- direct `CALL`/`JP`/`JR` edges out of dasmz80's own
   `-x` cross-reference dump. **161** entry points.
2. **`jumptabz80.py`** -- the `JP (HL)` dispatches. **257** entry points, by
   far the largest channel; the direct call graph alone reaches only about a
   tenth of the ROM. Detail below.
3. **`orphanz80.py`** -- routines that no control-flow edge reaches, sitting
   in a gap *between* two decoded regions. **24** entry points. This is the
   weakest channel (it asserts nothing about control flow), so it is isolated
   in its own script and runs in phase 2, only after channels 1 and 2 have
   converged. Detail below.

### The five `JP (HL)` dispatches, and how each was bounded

Every `JP (HL)` in the listing is accounted for; `jumptabz80.py` exits
nonzero if one matches neither shape, so a construct it does not understand
cannot silently cost coverage.

| site | shape | table / variable | entries | how the count was bounded |
|---|---|---|---|---|
| `16F3` | indexed word table | `$2000` | 256 | the index is built `LD E,A / SLA E / JP NC,+ / LD D,#$01`, folding the shift's carry into `D`: a 9-bit byte offset, i.e. a full 256-entry word table. `0x2000 + 512 = 0x2200`, exactly where the first handler sits. |
| `37D3` | indexed word table | `$37E2` | 24 | guarded by `CP #$17 / JP C,+ / XOR A / JP ++ / INC A`, so the index runs `0..0x17`. `0x37E2 + 48 = 0x3812`, exactly the next code region's start. |
| `382F` | indexed word table | `$3830` | 78 | guarded by `CP #$4D`, index `0..0x4D`. `0x3830 + 156 = 0x38CC`, exactly where the first of the sixteen data blocks below begins. |
| `2E72` | RAM state pointer | `($C0E5)` | 19 stores | the switch-column state machine: each handler writes its successor's address into `C0E5` before returning. Entries are every `LD HL,#imm / LD (C0E5),HL` in the ROM (byte pattern `21 lo hi 22 E5 C0`). |
| `3456` | RAM state pointer | `($C117)` | 9 stores | the lamp-column state machine, same construction. |

The `$2000` table is the **80188 -> Z80 command table**: 256 entries, all 256
pointing at coherent code between `09A2` and `36F8`, indexed by the byte
`host_cmd_dispatch` (`16D5`) pulls out of the ring buffer the NMI fills.
Every one of the 231 distinct targets decodes cleanly; none was rejected.

Each recovered table's size landing exactly on the next region's start (or on
the next data block's start) is the independent confirmation that the bound
taken from the guard instruction is right.

### The orphan channel, and why it is safe

`orphanz80.py` looks only at gaps *between* two decoded regions -- never past
the last one, so the ROM's trailing data is out of reach -- and a gap has to
survive three tests:

* **No data reference into it.** dasmxx records `Ptr`/`Imm` cross-references;
  a gap any of whose bytes is referenced holds a table, not code. That is
  what correctly keeps the byte tables at `05B6`, `1218`, `2000`, `37E2` and
  `3830` out. A reference whose target byte is `0xFF` is dropped first, since
  dasmxx registers an `Imm` xref for *every* 16-bit immediate and constants
  like `#$03E8` (1000) are not addresses. The one exception to "skip whole":
  when the references form a **contiguous run of at least two** addresses
  with nothing referenced above it, the table's extent is known exactly and
  code may follow it -- that is the `337B-3382` byte table, one entry per
  routine of the nine-routine family at `3383`/`339E`/.../`3415`, with the
  family's `[0]` member immediately behind it.
* **Leading `0xFF` filler is skipped**, then the gap must decode with no
  `???`.
* **It must land exactly on a boundary**: either it reaches an unconditional
  terminator inside the gap (at least three instructions, unless the
  terminator lands precisely on the gap's end -- a gap whose whole content is
  one `RET` is a routine tail, not a coincidence), or it runs to the gap's
  end exactly with no terminator, i.e. falls through into the next region.
  A byte table decoded as instructions would have to end its last instruction
  on precisely the right byte to be mistaken for either; the `LD r,r'` run at
  `1218` fails this even before the data-reference test.

Phase ordering matters and is the reason `rebuild_z80.sh` has two phases: the
stray byte at `003B` is a constant read by the routine at `2D8C`, and `2D8C`
is only reachable through the 256-entry command table. Run early, the orphan
channel has not seen that reference yet and mistakes `003B` for code. With
phase 1 finished first, the result no longer depends on discovery order --
two independent `--from-seed` runs produce byte-identical `.cmd` and `.lst`.

### Reproducing

```bash
cd sleic-iomoon
# incremental, over whatever entries_z80.txt already holds:
sh asm/baseline-2026-09/tools/rebuild_z80.sh
# or from scratch (about two minutes): discard everything below the
# hand-derived seed block, rediscover it, regenerate .cmd/.lst, cross-check:
sh asm/baseline-2026-09/tools/rebuild_z80.sh --from-seed

python3 asm/baseline-2026-09/tools/jumptabz80.py --tables   # the five dispatches
python3 asm/baseline-2026-09/tools/orphanz80.py  --detail   # per-gap accept/reject
python3 asm/baseline-2026-09/tools/iotabz80.py   --sites    # the I/O surface
```

and to run dasmz80 by hand on the committed command file (**from the
repository root** -- the ROM path inside it is repository-relative):

```bash
~/iomoon/tools/dasmxx/src/dasmz80 -x asm/baseline-2026-09/iomoon_z80.cmd
```

## The dasmz80 patch this baseline depends on

`tools/dasmxx-z80-fixes.patch`, on top of upstream commit
`23af0f649268c17644fa1ab9ae0594e93b67721e` (the same base as the x86 patch):

```bash
git -C ~/iomoon/tools/dasmxx apply \
    asm/baseline-2026-09/tools/dasmxx-z80-fixes.patch
cd ~/iomoon/tools/dasmxx/src && make dasmz80
```

One defect, in the operand printer for `IN A,(n)` / `OUT (n),A`: dasmz80 ran
the **port** number through `xref_genwordaddr()`, which substitutes a
**memory** label whenever one exists at the same numeric address. With a
label at memory address `0x0000`, `DB 00` printed as `IN A, (reset)`. The
Z80's I/O ports are a separate 8-bit address space, so that is simply wrong,
and it destroys the port number the listing is being read for -- the input to
this part's main deliverable. The `X_IO` cross-reference is still registered,
so `-x` still lists each port's call sites.

## Verification

```
python3 asm/baseline-2026-09/tools/xverify.py --arch z80 \
    --regions asm/baseline-2026-09/iomoon_z80.cmd \
    --lst asm/baseline-2026-09/iomoon_z80.lst \
    --bin "roms/1.3 IPDB latest/V1 3_05.bin" \
    --base 0x0
```

```
regions: 12   code bytes: 10737
instructions compared: 4760
dasmz80 addr missing from unidasm decode: 0
unidasm addr with no dasmz80 counterpart:  0
dasmz80 vs unidasm disagreements:          0
```

Two decoders, not three: capstone has no Z80 architecture and ndisasm is
x86-only, so `unidasm -arch z80` (mame-tools 0.288) is the single second
opinion. Zero skips and zero extras is the load-bearing result -- both
decoders drew every instruction boundary in the same place across all twelve
regions, so neither desynchronised anywhere.

`reports/xverify_z80.md` has the RED tests (three deliberately corrupted
listings, each exercising one detector, each exiting 1), the empty-by-design
`ALIAS_Z80` table, and the real defect this cross-check caught: xverify's
data-row filter matched `DB` + *any* whitespace, and on the Z80 `DB nn` is
`IN A,(nn)`, so all 36 `IN` instructions were silently dropped from the
comparison -- 4724 instructions compared instead of 4760, surfacing as 36
unidasm "extras". Fixed by keying on dasmxx's fixed-width `"DB      "` data
row instead. The x86 run reproduces its committed numbers exactly after every
change to the shared tool.

Further checks:

* **Zero `???` bytes** in the decoded regions.
* Every one of the 12 regions ends **exactly** on an unconditional
  terminator -- 6 on `RET`, 1 on `RETN`, 5 on `JP` (two of them the
  `JP (HL)` dispatches) -- with the terminator's last byte on the region's
  last byte. No region end is an artefact of where the sweep gave up.
* No region extent hit the sweep's window cap.
* Recovered dispatch-table sizes end exactly where the next code region or
  data block begins (table above).
* Every `JP (HL)` site matches one of the two recognised dispatch shapes.
* The whole-ROM I/O opcode scan below leaves nothing unexplained.

## The I/O surface -- all 141 sites

This is the table the driver work depends on. It is generated by
`tools/iotabz80.py`, which takes each port number from the instruction's own
**raw bytes** (`D3 nn` = `OUT (nn),A`, `DB nn` = `IN A,(nn)`), not from the
operand text.

**The ROM uses exactly five input ports (`0x00-0x04`) and eight output ports
(`0x80-0x87`), and nothing else.** There is not one `IN r,(C)` / `OUT (C),r`
(`ED 40+8r` / `ED 41+8r`) and not one block-I/O instruction (`INI`/`IND`/
`OUTI`/`OUTD`/`INIR`/`INDR`/`OTIR`/`OTDR`) in the ROM, so every I/O site in
the machine has a port number that is a compile-time constant, listed here.

| port | dir | sites | addresses |
|---|---|---|---|
| `0x00` | IN | 2 | 008C, 01D6 |
| `0x01` | IN | 7 | 0116, 0144, 017E, 01B6, 0DF8, 0E36, 10F9 |
| `0x02` | IN | 12 | 2EE4, 2F12, 2F40, 2F6E, 2F9C, 2FCA, 32F3, 32FF, 330B, 3317, 3323, 332F |
| `0x03` | IN | 10 | 0D76, 0D87, 0D8E, 0D9F, 2CE8, 2CEF, 2DF5, 2DFC, 2E54, 2E62 |
| `0x04` | IN | 5 | 0DBF, 11F5, 2BEB, 2D9D, 2E42 |
| `0x80` | OUT | 4 | 012A, 015D, 0196, 0441 |
| `0x81` | OUT | 22 | 008A, 009C, 0108, 0113, 0122, 0131, 0140, 0155, 0164, 016B, 0175, 018E, 019D, 01A4, 01AE, 01C4, 01D1, 01E3, 01ED, 0448, 0CAD, 0CB5 |
| `0x82` | OUT | 13 | 0457, 2E75, 2E85, 2E95, 2EA5, 2EB5, 2EC5, 2EF8, 2F26, 2F54, 2F82, 2FB0, 2FDE |
| `0x83` | OUT | 9 | 0433, 3464, 3474, 3484, 3494, 34A4, 34B4, 34C4, 34D4 |
| `0x84` | OUT | 9 | 043A, 3460, 3470, 3480, 3490, 34A0, 34B0, 34C0, 34D0 |
| `0x85` | OUT | 16 | 0427, 05D7, 05FD, 0623, 0640, 0662, 067B, 068F, 06B5, 06D7, 06E9, 07EE, 080A, 08A3, 0AB9, 0B1C |
| `0x86` | OUT | 25 | 042C, 0706, 0723, 0740, 075D, 077A, 0797, 07B4, 07D1, 081B, 082C, 083D, 084E, 085F, 0870, 0881, 0892, 0ADA, 0AFB, 0BAC, 0BCD, 0BEE, 0C0F, 0C30, 0C51 |
| `0x87` | OUT | 7 | 0420, 0DF3, 10F7, 27BC, 27C9, 283A, 2866 |

Total 141 (36 `IN`, 105 `OUT`).

### What each port does, from the code

Every output port has a **RAM shadow byte**, written alongside the port by
`boot_port_init` (`041B`) and read-modify-written by everything else, which
is how the bit-level uses below are readable at all:

| port | shadow | role, and the instructions that show it |
|---|---|---|
| `0x00` IN | -- | inbound data byte from the 80188. Read in exactly two places, each immediately after enabling a port-81 gate bit: the NMI handler (`008C`, gate bit 4) and `host_read_byte` (`01D6`, gate bit 6). |
| `0x01` IN | -- | status from the 80188. **Bit 1 is the outbound handshake**: `host_send_c0fc`/`_c008_a`/`_c008_b` all begin `IN A,($01) / BIT 1,A / JR Z,self`, spinning until it is set before touching port `0x80`. **Bit 5** is the datum read by `direct_input_scan`'s 16-way scan. |
| `0x02` IN | -- | **switch-matrix row byte.** Read once per column by `sw_read_col0..5`, `CPL`-ed and stored to `C0E7/E9/EB/ED/EF/F1`, with the change mask going to `C0DB..C0E0`. |
| `0x03` IN | `C0F7` | a second, non-matrixed input byte: `IN A,($03) / CPL -> (C0F7) / OR (C0F8) -> (C0E3)` in `input_port03_read`. `input_port03_bit3` tests bit 3 of it directly. |
| `0x04` IN | -- | status/cabinet input, always bit-tested, never stored whole: bit 0 gates `direct_input_scan`, bit 7 is the spin condition in `selftest_wait_reset`. |
| `0x80` OUT | `C0FC`/`C008` | **outbound data byte to the 80188.** Written in exactly four places -- once in `boot_port_init` (0x00) and once in each of the three `host_send_*` routines, each of which has already spun on port-01 bit 1. |
| `0x81` OUT | `C001` | **control/strobe register.** bit 1 is set before the port-80 write and cleared after (data-valid); bit 2 is pulsed after it in `host_send_c0fc`; bit 5 is pulsed after it (with three `NOP`s of width) in `host_send_c008_a`/`_b`; bit 6 gates the polled `IN A,($00)`; bit 4 gates the NMI's `IN A,($00)`; bit 0 is set with bit 1 on the `c008` sends and cleared on the read; bit 3 is toggled once every 16 ticks of the `C045` counter by `port81_bit3_toggle`, i.e. driven as a periodic square wave. |
| `0x82` OUT | `C002` | **switch-matrix column strobe**, one-hot: `sw_strobe_col0..5` and the tail of each `sw_read_colN` write `01, 02, 04, 08, 10, 20`. Six columns. |
| `0x83` OUT | `C003` | **lamp-matrix column strobe**, one-hot `01..80` across `lamp_col0_out..lamp_col7_out`. Eight columns. |
| `0x84` OUT | `C004` | **lamp-matrix data byte**, taken from `C10F..C116`, written immediately *before* the matching `0x83` column strobe. |
| `0x85` OUT | `C005` | driver latch A. Sixteen sites, almost all of the form `LD A,(C005) / OR #bit / AND #~bit / LD (C005),A / OUT ($85),A` in a routine that also arms a countdown in `C0xx` -- the shape of an individually-timed coil/driver output. |
| `0x86` OUT | `C006` | driver latch B, same shape, 25 sites. |
| `0x87` OUT | `C007` | mixed. The **low nibble** is the index of `direct_input_scan`'s 16-way scan (`0DEA-0E01`: `C007 AND #$F0 OR C`, `OUT ($87)`, three `NOP`s, `IN A,($01) / BIT 5`). Bit 4 is set/cleared at `2851`/`2831`, bit 5 at `port87_bit5_set`/`_clear`. `boot_port_init` starts it at `0x30`. |

### Nothing was missed

`iotabz80.py` also scans **the whole 32 KiB image** for any byte that could
begin an I/O instruction (`D3`, `DB`, or `ED` followed by a `4x`/block-I/O
second byte) and reports every one that is not an instruction start inside a
decoded region. Four hits remain, and all four are data bytes inside blocks
this baseline has already classified:

| address | bytes | where |
|---|---|---|
| `2072` | `DB 23` | inside the 256-entry command table (`2000-21FF`): the low/high halves of adjacent entries |
| `21FC` | `D3 27` | same table -- it is entry `0xFE` = `$27D3`, stored little-endian |
| `3CBE` | `D3 5A` | inside the sixteen data blocks at `38CC-4FD4` |
| `3CC6` | `DB 5E` | same |

So the 141 sites above are the complete I/O surface of this ROM.

## What the decoded code says about the hardware

* **The main loop is `0D4C`**, the target of the boot path's final `JP`:
  `input_port03_read_tick` (which also ticks the switch-column state machine)
  -> `input_port03_bit3` -> `host_cmd_dispatch` -> a test of `C0E3` ->
  `direct_input_scan` -> two flag tests -> `anim78_dispatch` -> `JP $0D4C`.
* **The switch matrix is 6 columns x 8 rows = 48 inputs**, strobed one-hot on
  port `0x82` and read on port `0x02`, plus the 8 bits of port `0x03` = 56
  possible inputs in total. The scan is a state machine, not a loop: one
  column per call, paced by a settling counter in `C0F9`, with the state
  pointer in `C0E5`. Each column has its own change handler
  (`sw_col0_changed` at `2FE7` and five siblings at `+0x41` intervals) which
  walks the change mask bit by bit and calls a distinct per-bit routine --
  i.e. the switch *numbering* is directly readable out of those six routines.
* **The lamp matrix is 8 columns x 8 bits = 64 lamps**, data on port `0x84`
  from `C10F..C116`, column strobe on port `0x83`, one column per call of
  `lamp_scan_tick` (`3446`) through the `C117` state pointer.
* **The 80188 link is a byte port, exactly as Part 1 describes from the other
  side.** Outbound: spin on port-01 bit 1, write port `0x80`, pulse a port-81
  strobe. Inbound: NMI -> port-81 bit 4 -> `IN A,($00)` -> ring buffer at
  `$C076` (pointers `$C072` read, `$C074` write) -> `host_cmd_dispatch`
  (`16D5`) -> 256-entry table at `$2000`. There is no shared-memory path: the
  Z80 never addresses anything outside `0000-4FD4` (ROM) and `C000-C7FF`
  (RAM).
* **The Z80 drives no sound chip.** Its only host-facing writes are the data
  byte on `0x80` and the strobes on `0x81`; ports `0x82-0x87` are all
  accounted for as switch/lamp/driver traffic above.
* **RAM footprint**: `C000-C008` are the eight port shadows plus one spare,
  `C009-C0B0` and `C061-C150` are cleared at boot, and every RAM address the
  listing touches lies in `C000-C127`. Stack top `C7FF`.

## Region inventory

12 code regions, 10737 bytes (32.8% of the 32 KiB image; the image is only
`0x0000-0x4FD4` = 20437 bytes of programmed content, of which 16833 bytes are
non-`0xFF`).

| region | bytes | what it is |
|---|---|---|
| `0000-000E` | 14 | reset stub + the RST 08 landing |
| `0038-003B` | 3 | the IM 1 vector's `JP` |
| `0066-00A7` | 65 | NMI handler |
| `0100-01F1` | 241 | the port-81 bit helpers and the three `host_send_*` / `host_read_byte` routines |
| `0400-05B6` | 438 | boot (`0400`), `boot_port_init` (`041B`) and `boot_ram_init` (`045A`), which runs to the `RET` at `05B5` |
| `05C7-09A1` | 986 | driver latch A and B routines |
| `09A2-0D14` | 882 | command-table handlers `09A2/09BB/09D4/0A36/0A3E`, the IRQ handler, its timers |
| `0D15-1218` | 1283 | main loop, `direct_input_scan`, its sub-handlers |
| `1242-16F4` | 1202 | the port-`0x03` input handlers (`1242` tests bits 0/1/4 of `C0E3` and calls `125B`/`1278`/`1285`, each of which loads a command code into `C0FC` and jumps to `host_send_c0fc`), a large sibling family through `16C5`, and `host_cmd_dispatch` at `16D5` |
| `2200-337A` | 4474 | the 256-entry command table's handlers, the switch scan and its per-column change handlers |
| `3383-37E2` | 1119 | the `33xx` bit-set family, the lamp scan, `anim24_dispatch` |
| `3812-3830` | 30 | `anim78_dispatch` |

### Everything not decoded as code

| span | bytes | non-`FF` | classification |
|---|---|---|---|
| `000E-0038` | 42 | 4 | the third, unreachable `NOP / JP $0400` (see above) + filler |
| `003B-0066` | 43 | 1 | the constant byte at `003B`, read by `2D8C` (`Ptr` xref) + filler |
| `00A7-0100` | 89 | 0 | filler |
| `01F1-0400` | 527 | 0 | filler |
| `05B6-05C7` | 17 | 17 | byte table, 12 of its bytes read individually by `05D9`, `05FF`, `0691`, ... |
| `09A1-09A2` | 1 | 1 | one-byte ROM constant, read by `09DA` |
| `0D14-0D15` | 1 | 1 | one-byte ROM constant, read by `0D1D` |
| `1218-1242` | 42 | 42 | byte table, base loaded by `LD DE,#$1218` at `0DE7` in `direct_input_scan` |
| `16F4-2200` | 2828 | 512 | the **256-entry command dispatch table** at `2000-21FF`, + filler |
| `337A-3383` | 9 | 8 | 9-byte table, one entry per routine of the `3383..3415` family |
| `37E2-3812` | 48 | 48 | the **24-entry** dispatch table of `anim24_dispatch` |
| `3830-8000` | 18384 | 5644 | the **78-entry** dispatch table at `3830-38CB`, then sixteen data blocks at `38CC-4FD4` (each the target of a `LD HL,#imm` in the `35EA/3605/3620/.../3780` family, which loads two header bytes into `C11A`/`C11B` and the rest pointer into `C11E`), then filler from `4FD5` |

## Agreement and disagreement with the older material (Z80)

Old addresses and claims were used only as probes. Decoding fresh:

**Confirmed.**

* **Ports `0x00-0x04` in, `0x80-0x87` out** -- exactly right, and now
  provably exhaustive (the whole-ROM opcode scan above).
* **`IM 1`, with the periodic IRQ handler entered at `0x0038`** -- confirmed
  from the `ED 56` bytes themselves, plus the absence of `IM 0`/`IM 2`/`LD I,A`,
  plus the handler's two `RETI` exits.
* **A switch-matrix scan routine exists** -- confirmed and pinned down: 6
  columns strobed on `0x82`, rows read on `0x02`, state machine through
  `C0E5`, per-column change handlers.
* **Ports `0x82-0x87` are lamp/solenoid/switch-scan, not sound** (the current
  `CLAUDE.md` position) -- confirmed; the Z80 writes no sound chip.
* **Port `0x01` bit 1 IN is the outbound handshake, not an OKI-ready line**
  -- confirmed: it is the spin condition of every one of the three
  `host_send_*` routines, immediately before a port-`0x80` write.
* **Port `0x81` bit 1 = data-valid, bit 4 = the NMI path's inbound gate,
  bit 5 = the command strobe, bit 6 = the polled inbound gate** -- all four
  confirmed mechanically (each is set immediately before, and cleared
  immediately after, the transfer it gates).
* **64 lamps** (`docs/switch_lamp_solenoid.md`) -- confirmed exactly: 8
  columns x 8 data bits.

**Refined or not confirmed.**

* Port `0x81` **bit 2** is *not* a switch strobe: it is pulsed only by
  `host_send_c0fc`, after the port-`0x80` write, as a second strobe distinct
  from bit 5. The switch strobe is port `0x82`.
* Port `0x81` **bit 3** is not mentioned in the older material at all. It is
  toggled every 16 ticks of the `C045` counter by `port81_bit3_toggle`
  (`0C97`), i.e. driven as a periodic square wave, and bit 0 is cleared with
  it.
* Port `0x81` **bit 0** is set on the two `c008` sends and cleared on the
  read. "Sound-channel select" is consistent with that but is not something
  this ROM proves.
* **"50 switches"** is not confirmed. The hardware the code drives is 48
  matrix inputs (6x8) plus the 8 bits of port `0x03`; how many are populated
  is a question for the per-bit handlers in `sw_col0_changed..sw_col5_changed`
  (Task 7), not for this baseline.
* **"18 solenoids"** is not confirmed either. Ports `0x85` and `0x86` are two
  8-bit shadowed latches = 16 driver bits, with port `0x87`'s bits 4/5 as
  further candidates. Again a Task 7 question.
* The claim that the Z80 has any path into 80188 memory is contradicted: the
  Z80 addresses only its own ROM and `C000-C7FF` RAM.

## Known limits (Z80)

* Coverage is what the three channels reach. The orphan channel is the
  weakest of them; its 24 entries are tagged `# orphan routine` in
  `entries_z80.txt` and can be removed to see the baseline without them.
* The six `IN A,($02)` sites at `32F3..332F` belong to a family
  (`sub_32ED..sub_3329`) that resets the switch state pointer to column 0 and
  re-reads one row byte directly; what event drives them is not established
  here.
* Labels in `labels_z80.txt` are provisional and describe observed
  peripheral/RAM traffic only. Where a name implies purpose (`lamp_`, `sw_`,
  `host_`) the justification is the comment beside it; treat it as a
  hypothesis.
* The data blocks at `38CC-4FD4` (~5.6 KiB, the bulk of the non-code content)
  are classified as data and bounded, but their format is not decoded.
