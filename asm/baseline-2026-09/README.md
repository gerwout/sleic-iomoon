# IO Moon 80188 -- 2026-09 baseline disassembly

A fresh, independently derived disassembly of the IO Moon (SLEIC, 1994) main
CPU ROM, built with [dasmxx](https://github.com/nejohnson/dasmxx)'s `dasmx86`
and cross-checked against capstone.

**Nothing here was taken from the older `asm/80188_annotated.asm` or from
`docs/*.md`.** Old addresses were used only as *probes* -- "decode here and
see whether a coherent handler is really there" -- and the section
"Agreement and disagreement with the older material" records what that
check confirmed and what it contradicted. Every region, label and claim
below is justified by the instruction stream decoded in this directory.

## Files

| file | what it is |
|---|---|
| `entries.txt` | the code entry points, one per line, with the evidence that produced each |
| `labels.txt` | hand-given provisional names, applied on top of the generated ones |
| `iomoon_80188.cmd` | the dasmxx command list (generated -- do not hand-edit) |
| `iomoon_80188.lst` | the listing dasmx86 produces from it |
| `reports/regions.md` | region inventory + classification of everything not decoded as code |
| `reports/jumptables.md` | every recovered `JMP CS:W[BX+disp]` table, with its entries |
| `reports/186scan.md` | Task 3's 80186-opcode pre-scan |
| `tools/` | the scripts that drive dasmx86 and generate the above |
| `tools/dasmxx-x86-fixes.patch` | the dasmxx changes this baseline depends on |

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

`tools/crosscheck.py` re-disassembles every decoded region with capstone
(16-bit mode) and compares instruction boundaries first, then mnemonics:

```
regions: 83   code bytes: 88177 (33.6% of the 262144-byte UMCS window)
instructions compared: 29810
length disagreements : 0
mnemonic differences : 0
```

Zero length disagreements is the load-bearing number: it means dasmx86 and
capstone agree on every instruction boundary across the whole region set,
so neither has desynchronised anywhere. (The only spelling differences found
were capstone printing `98`/`99` with their 32-bit names `cwde`/`cdq`, and
the usual `retf`/`lcall`/`ja` aliases; these are listed in the script.)

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
decoded instructions:

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
