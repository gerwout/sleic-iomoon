# IC8 — PAL16L8 Z80 bus decoder dump

[← Back to ROM index](../README.md) · [Chip background](../../docs/chips_to_dump.md)

A bench read of **IC8**, the AMD **PAL16L8A-2CN** on the IO Moon Z80 board
(011-030A), desoldered from the board and read in a socket. The part is bipolar
and security-locked, so what is archived here is its measured behaviour and a
fuse map that reproduces it.

> **Read *What this device decodes* before using this.** The measurement is
> exhaustive, reproduces byte for byte on an independent run of the pipeline,
> and has pin direction established four ways. The device is a **bus-cycle
> decoder**: three of the five address lines wired to it reach no output at
> all, and it generates no memory chip select and no memory read or write
> strobe. The nets schematic sheet 011-030-01 puts on pins 12, 16, 18 and 19
> are therefore not what the board has there.

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

The device is the one desoldered from this machine's own 011-030A board, and
the machine runs — which is what makes the gap between the measurement and the
schematic a statement about the board rather than about the part.

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
  clear the request, which is what the `/RI` net does at the IC14A/IC14B latch
  ([`../../research/z80_irq_timing.md`](../../research/z80_irq_timing.md)).

Two of those three sit on the other's pin relative to the symbol: the I/O-write
decode is on pin 14, labelled `/RI`, and the interrupt-acknowledge decode on pin
17, labelled `/CEO`. The socket mapping is fixed by the package — IC pin 10 on
the POD's hard-wired ground and IC pin 20 on its switched supply — so the two
pins are not interchangeable at the rig.

## Pin direction

Pins 12 and 13 do not drive. They read permanently high-impedance in four
configurations:

| Configuration | Pin 12 | Pin 13 |
|---|---|---|
| `characterize3.py`, one pin pulled at a time, 26 patterns | never drives | never drives |
| `data = [12]` alone / `data = [13]` alone, 1024 combinations | always Hi-Z | always Hi-Z |
| `data = [12,14..19]`, pin 13 driven as an address bit, 2048 combinations | always Hi-Z | — |
| `data = [12,13,14..19]`, 1024 combinations | always Hi-Z | always Hi-Z |

The physics is what makes these readings mean something. This is a bipolar
PAL16L8 sourcing and sinking tens of milliamps; the rig pulls through about
10 kΩ, roughly 0.5 mA. **The rig cannot override a driven output**, so a pin
whose level follows the pull is a pin the chip is not driving.

The single-pin sweep of **pin 12 is decisive on its own**: pin 12 has no
feedback path into the AND array, so pulling it high in one pass and low in the
other cannot change what the array sees, and both passes present identical
inputs. Pin 13 does feed back, so in principle a self-dependent enable term
could move between passes; its result rests on the other three configurations.

Driving pin 13 as an address bit across the full 2048-state space is what
covers an enable conditioned on `ROM2` **high**, which a sweep leaving pin 13
at logic 0 cannot see (dump SHA1
`3a218fdcb939b73e02484fc736df78575cb93724`). The eight-output configuration
reproduces this file's six outputs **bit for bit across all 1024 rows**, zero
mismatches (dump SHA1 `f76007f249c3844c0de63e85a2c91889a6ba2427`).

`/ROM2` on pin 13 carries weight in the array — `/RD` requires it high and
`/CEO` requires it low. That the outputs follow a level the rig imposes is the
same measurement as the Hi-Z test restated, not a second line of evidence, but
it is consistent: pin 13 is an input.

**`--check_hiz` reports false Hi-Z on this part, and the effect is partial.**
`dpdumper` drives every data pin high in one pass and low in the other; six of
the eight outputs (pins 13-18) feed back into the AND array, so the array's own
inputs move between the passes and a driven output can be reported as floating.
On this device, in the eight-output configuration, pins 17 and 19 are reported
Hi-Z in **128 of 1024** states, where the eleven-input sweep has both driving in
all 2048. The effect appears only in states where the chip is not driving, so it
produces state-dependent false Hi-Z, never the all-states reading that pins 12
and 13 give. Resolve direction one pin at a time, and prefer a pin with no
feedback path, before trusting the mask.

## What this device decodes, and what it does not

Every output's support set, taken by exhaustive single-bit flips over all 2048
rows rather than read off the minimised equations — `D` marks an input the
output actually depends on:

| Output | `/M1` | `/MREQ` | `/IOREQ` | `/PWR` | `/PRD` | `A15` | `A14` | `A13` | `A12` | `A7` | `/ROM2` |
|---|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|
| `/RI` (14)  | D | D | D | D | . | . | . | . | . | . | . |
| `/CEI` (15) | D | D | D | D | D | . | . | . | . | . | . |
| `/RAM` (16) | D | . | . | . | . | . | . | . | . | . | . |
| `/CEO` (17) | D | D | D | . | . | . | . | . | . | . | D |
| `/WR` (18)  | D | . | . | D | D | D | D | . | . | . | . |
| `/RD` (19)  | D | D | D | . | . | . | . | . | . | . | D |

Assertion rates over the same 2048 rows: `/RI` 128, `/CEI` 64, `/RAM` 1024,
`/CEO` 128, `/WR` 64, `/RD` 128. Every pair is mutually exclusive except
`/RAM`, which overlaps `/CEO` and `/RD` at 128 each — the pattern of a signal
passed through rather than a select.

**This part is a bus-cycle decoder.** `A13`, `A12` and `A7` are wired to it and
no output depends on any of them. Exactly one output touches the address bus at
all, and only two of the five address lines present. Four of the six are pure
decodes over the control signals; the fifth, pin 16, follows a single control
signal — it depends on `/M1` alone and asserts in exactly half the input space.

So the memory-map decode is not in this device, and the reason is structural
rather than a gap in the read: a part that ignores three of the five address
inputs wired to it is not selecting memory with them. Concretely, none of the
six outputs can be:

- **A ROM select** — it would have to be true for every memory cycle with `A15`
  low. Pin 16 is true only during `M1`, pin 19 only during an opcode fetch, pin
  18 only while no strobe is active, and pins 14, 15 and 17 all require
  `/IOREQ`.
- **A RAM select** — it would have to be true for `A15`=1 · `A14`=1 · `A13`=0.
  `A13` is in no support set, and the only output using `A15` and `A14`
  requires both **low**.
- **A memory read or write strobe** — every output that responds to `/PRD` or
  `/PWR` also requires `/IOREQ`, so none is true during a memory cycle.

Pin 18 is a static address-range decode of the bottom 16 KB qualified by "no
strobe active". It is not a refresh decode: `/MREQ` is not in its support set,
and a refresh strobe has to be gated on `/RFSH` or at least `/MREQ` or it fires
through idle bus states.

**What follows for the board.** The part read is the device desoldered from
this machine's own 011-030A board, and the machine runs, so IC5's chip enable,
IC7's chip enable and the memory read and write strobes are generated somewhere
other than IC8 — which is not what schematic sheet 011-030-01 shows on pins 12,
16, 18 and 19. What IC8 does supply is the I/O half of the decode and the
interrupt acknowledge: the enables for IC16 and IC17, and the pulse that clears
the `/INT` latch.

Two of those three also sit on each other's label: the I/O-write decode is on
pin 14, marked `/RI`, and the interrupt acknowledge on pin 17, marked `/CEO`.

## What would settle it

Three measurements on the board, in order of value:

1. **Trace IC5 pin 20 (`/CE`) and IC7 pin 18 (`/CE`) back to what drives
   them**, and the same for the `/OE` and `/WE` lines those parts take. Sheet
   011-030-01 routes all of them from IC8, through IC14C/D in the RAM's case.
   The measurement says IC8 drives none of them.
2. **Continuity from IC8 pin 12 to IC5 pin 20** — the narrow form of the same
   question.
3. **A scope on pins 14 and 17** against an `OUT` instruction and against an
   interrupt, to read which net each actually drives. Pin 15 is already
   corroborated by IC16's wiring.

Until then the three confirmed decodes above are the usable result.
