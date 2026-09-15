# IC8 — PAL16L8 Z80 bus decoder dump

[← Back to ROM index](../README.md) · [Chip background](../../docs/chips_to_dump.md)

A bench read of **IC8**, the AMD **PAL16L8A-2CN** on the IO Moon Z80 board
(011-030A). The part is soldered, bipolar and security-locked, so what is
archived here is its measured behaviour and a fuse map that reproduces it.

> **Read the *What does not add up* section before using this.** The
> measurement is exhaustive and self-consistent, and three of its six outputs
> land exactly on three of IC8's documented jobs — but the memory chip selects
> the board provably needs are not in it. The recovered logic is almost
> certainly **incomplete**, and the section says what to re-measure.

| File | What |
|------|------|
| [`pal16l8_truthtable.txt`](pal16l8_truthtable.txt) | the measurement — 2048 rows, 11 inputs × 6 outputs, pin-labelled |
| [`pal16l8.pld`](pal16l8.pld) | the minimised equations, GALasm source |
| [`pal16l8.jed`](pal16l8.jed) | JEDEC fuse map, `QF2194`, target **GAL16V8**, simple mode |

| File | Size | MD5 |
|------|------|-----|
| `pal16l8_truthtable.txt` | 153,911 bytes | `28a0514a59260ffd7a27f44ac113636f` |
| `pal16l8.pld`            | 619 bytes     | `928a52736f3a5bb05f1bae4e96af5edb` |
| `pal16l8.jed`            | 546 bytes     | `7f36726022a4a7f6d52313f2519ef472` |

## Provenance

Read on a **dupico (DuPAL V3)** board with the PAL POD, using `dpdumper` →
`dpdump2tab` → `espresso` → `galasm`, the same rig and pipeline that recovered
[IC7](../PAL20L10/README.md). A 20-pin part sits at the *bottom* of the POD's
ZIF24 socket, so IC pin 10 lands on the socket's hard-wired ground and IC pin
20 on the switched supply at socket position 22 — the device definition has to
force that pin high or the chip is never powered.

The sweep treats the device as 11 inputs and 6 outputs: pins 1-9, 11 and 13
driven, pins 14-19 read.

- Dump SHA1 `7d7da99a370c58d455334c15ecc2894c6a149f41`.
- Hi-Z mask **all-zero over all 2048 entries**: none of the six read outputs
  ever floats.
- **Pin 12 never drives**, in any of the 2048 combinations. On a PAL16L8 pins
  12 and 19 are output-only with no path back into the array, so pin 12 cannot
  be pressed into service as an input either — it simply contributes nothing.
- **Pin 13 was resolved as an input** and driven as the eleventh address bit.

## Verification

The JEDEC is simulated fuse-by-fuse against the raw dump and **matches on all
2048 entries**. GALasm selected the GAL16V8's *simple* mode — eight product
terms per macrocell, outputs permanently enabled — which suits a part with no
reachable tri-state, and set the `AC1` bit for pin 13, i.e. that macrocell is
configured as an input.

`PAL16L8 → GAL16V8` is the standard 20-pin substitution.

## The recovered equations

Pin names are from the IC8 symbol on schematic sheet 011-030-01 (REV 3, 10
August 1995), which the Doña Elvira 2 manual carries an independent copy of.
Each output is active low and asserts when the right-hand side holds; a signal
written `/X` in a condition means that line is asserted (low).

Inputs: pin 1 `/M1`, 2 `/MREQ`, 3 `/IOREQ`, 4 `/PWR`, 5 `/PRD`, 6 `A15`,
7 `A14`, 8 `A13`, 9 `A12`, 11 `A7`, 13 `/ROM2`.

| Pin | Net | Asserts when | Reading |
|-----|-----|--------------|---------|
| 19 | `/RD`   | `/MREQ` · `/M1` · `IOREQ` high · `ROM2` high | an M1 opcode fetch |
| 18 | `/WR`   | `A15`=0 · `A14`=0 · no `PRD` · no `PWR` · no `M1` | address below `0x4000`, no strobe active |
| 17 | `/CEO`  | `/IOREQ` · `/M1` · `MREQ` high · `ROM2` low | **interrupt acknowledge** |
| 16 | `/RAM`  | `/M1` | every M1 cycle |
| 15 | `/CEI`  | `/IOREQ` · `/PRD` · no `PWR` · no `MREQ` · no `M1` | **I/O read, excluding INTACK** |
| 14 | `/RI`   | `/IOREQ` · `/PWR` · no `MREQ` · no `M1` | **I/O write** |

Pins 8, 9 and 11 — `A13`, `A12` and `A7` — are wired to the part but appear in
no product term.

## What checks out

Three of the six are textbook Z80 cycle decodes, and the board needs exactly
those three (sheet 011-030-02):

- **I/O read, excluding interrupt acknowledge.** That is the enable for
  **IC16**, the 74LS138 that decodes the input ports: its `G1` is tied high,
  `G2A` takes `A7` and `G2B` takes `/CEI`, and only `Y0`-`Y4` are wired, as
  `I0`-`I4`. So the board decodes **exactly five input ports, `0x00`-`0x04`**,
  matching finding **F5** with nothing spare — and `A7` low is what selects the
  input side.
- **I/O write.** That is the enable for **IC17**, the 74LS138 that decodes the
  output ports: `G1` takes `A7`, `G2A` and `G2B` are tied together on `/CEO`,
  and all eight outputs `Y0`-`Y7` are wired as `O0`-`O7`. So the board decodes
  **exactly eight output ports, `0x80`-`0x87`**, matching finding **F7** with
  nothing spare.
- **Interrupt acknowledge** (`/M1` and `/IOREQ` together). The Z80 runs in
  interrupt mode 1, so an INTACK cycle fetches no vector — its only job is to
  clear the request, which is exactly what the `/RI` net does at the latch
  described below.

That the input pinout produces three clean, needed Z80 cycle decodes is strong
evidence that the input side of this read is right.

Two of those three sit on the wrong pin for their name, though: the I/O-write
decode comes out on pin 14 (`/RI`) and the interrupt-acknowledge decode on pin
17 (`/CEO`), where function says they belong the other way round. A wiring or
socket error cannot transpose two pins three apart, so either the symbol's two
labels are swapped or this device is not the one the symbol describes.

## What does not add up

**The memory chip selects are missing, and the board cannot work without
them.** From sheet 011-030-01 and -02:

- `/ROM1` (pin 12) is the `/CE` of **IC5**, the 27C256 program EPROM. Pin 12
  never drives.
- `/RAM` (pin 16) feeds IC14D and IC14C (74LS00), which gate it with the
  supervisor's `WATCH` line to produce `/CRAM`, the `/CE` of **IC7**, the 6116
  work RAM. Pin 16 reduces to `/M1`.
- `/RD` (pin 19) is the `/OE` of IC5, IC6 and IC7 and gates the IC4 74LS245
  data-bus transceiver. It comes out as an opcode-fetch decode, so data reads
  would never enable the ROM, the RAM or the bus buffer.
- `/WR` (pin 18) is the `/WE` of IC7. It comes out as a term that is true only
  when *no* strobe is active.

A Z80 board wired this way could not fetch an instruction or touch its RAM, so
the recovered logic cannot be the whole story.

**The most likely cause is the direction resolution on pins 12 and 13.**
`dpdumper`'s `--check_hiz` drives every data pin high in one pass and low in
the other; on a PAL16L8 six of the eight outputs (pins 13-18) feed back into
the AND array, so the array's own inputs move between the two passes and a
driven output can be reported as floating. That is the same confound that
misreported a pin on the [IC7](../PAL20L10/README.md) read, and it is recorded
as gotcha 7 in the rig's own notes. If pin 12 in fact drives, its equation —
the ROM select — is simply absent from this dump; if pin 13 in fact drives, the
sweep drove an output, and `/ROM2` is an internal term of `/CEO` and `/RD`
rather than an input.

**What would settle it**, in order of cost:

1. Re-resolve pin direction **one pin at a time** (`characterize3.py`, or a
   single-pin `data = [n]` sweep) for pins 12 and 13, without `--check_hiz`.
2. Re-dump in the eight-output configuration — `address = [1,2,3,4,5,6,7,8,9,11]`,
   `data = [12,13,14,15,16,17,18,19]`, 1024 combinations — and compare the six
   overlapping outputs against this file. They must agree bit for bit.
3. On the board, a continuity check from IC8 pin 12 to IC5 pin 20, and a scope
   on IC8 pin 16 against `/M1`, decide it outright.

Until then, treat the three confirmed decodes above as the usable result and
the rest of this file as an unresolved measurement.
