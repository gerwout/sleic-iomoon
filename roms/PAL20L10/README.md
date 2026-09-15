# IC7 — PAL20L10 chip-select decoder dump

[← Back to ROM index](../README.md) · [Chip background](../../docs/chips_to_dump.md)

The recovered contents of **IC7**, the AMD/MMI **PAL20L10ACNS** bus-decode PAL
on the IO Moon 16-bit board (011-029A). The part is soldered, bipolar, and
security-locked, so it is not readable on a programmer; what is archived here
is its behaviour, recovered exhaustively on a bench rig and re-expressed as a
fuse map that reproduces it.

| File | What |
|------|------|
| [`pal20l10.bin`](pal20l10.bin) | the raw sweep — 16384 rows, one byte each |
| [`pal20l10_hiz.bin`](pal20l10_hiz.bin) | its Hi-Z mask, all zero |
| [`pal20l10_truthtable.txt`](pal20l10_truthtable.txt) | the same measurement as labelled text — 16384 rows, 14 inputs × 8 outputs |
| [`pal20l10.pld`](pal20l10.pld) | the minimised equations, GALasm source |
| [`pal20l10.jed`](pal20l10.jed) | JEDEC fuse map, `QF5892`, target **GAL22V10 / ATF22V10C** |

The part is soldered back onto the board, so the raw dump is archived alongside
the derived files: it is the measurement, and it is not repeatable.

| File | Size | MD5 | SHA1 |
|------|------|-----|------|
| `pal20l10.bin` | 16,384 | `e3a32aaed374ba47146d1ef4f10ac42d` | `34e48f2b5de5e8b5a13392b996e4e7c7c9487d61` |
| `pal20l10_hiz.bin` | 16,384 | `ce338fe6899778aacfc28414f2d9498b` | `897256b6709e1a4da9daba92b6bde39ccfccd8c1` |
| `pal20l10_truthtable.txt` | 1,556,853 | `f882e77f625cef41ab5491db3f13c0b2` | — |
| `pal20l10.pld` | 742 | `1bf466d505a025409872bc106bc74548` | — |
| `pal20l10.jed` | 1,097 | `a93bc2eddd25fc6a4308445805df3be7` | — |

## File format

`pal20l10.bin` is one byte per input state: the state index is pins 1-11, 13,
15, 16 with pin 1 as `A0`, and the byte holds pins 14, 17, 18, 19, 20, 21, 22,
23 with pin 14 as bit 0. `pal20l10_hiz.bin` has the same layout, a set bit
meaning that pin read as high-impedance in that state; it is all zero. Decoded
that way the dump reproduces
[`pal20l10_truthtable.txt`](pal20l10_truthtable.txt) on all 16384 rows.

## Provenance

Read on a **dupico (DuPAL V3)** board with the PAL POD, using `dpdumper`
0.4.4 → `dpdump2tab` → `espresso` → `galasm` (GALasm 2.1). The chip was first
characterised pin by pin: it shows no clock sensitivity and no history
dependence (every pattern reproduces identically when revisited out of order),
so it is purely combinational, and each pin's direction was established one pin
at a time before the sweep.

That characterisation found **pins 15 and 16 never drive**, under any of the
16384 input patterns. On the PAL20L10 the ten outputs are three-state with a
programmable enable (the MMI handbook's own worked example is *"an octal latch
with preset and three-state outputs"*), so an output whose enable term is never
satisfied is permanently high-Z and the pin is usable only as an input. IC7 is
programmed that way on two of its macrocells: it presents **14 inputs and 8
outputs**, not the 12-and-10 its package position suggests.

The sweep therefore covers all 2¹⁴ = 16384 combinations of pins
1-11, 13, 15, 16, reading pins 14, 17-23.

- Dump [`pal20l10.bin`](pal20l10.bin), SHA1 `34e48f2b5de5e8b5a13392b996e4e7c7c9487d61`.
- Hi-Z mask **all-zero over all 16384 entries**: none of the eight outputs ever
  floats, so no output carries a live enable term and no bus-sharing is hidden
  in the part.

## Verification

The JEDEC is simulated fuse-by-fuse against the raw dump and **matches on all
16384 entries**. The check is exhaustive, not sampled: the device is proven
stateless, so there is no input the chip can see that has not been tested.

`PAL20L10 → GAL22V10` is a sound substitution. The layouts are identical
24-pin (GND 12, VCC 24), with 12 dedicated inputs and 10 I/O, and the 22V10's
8-16 product terms per macrocell comfortably exceed what is needed here (9
product terms in total, at most 2 on any one output). GALasm emits no native
PAL20L10 fuse map — it knows only GAL16V8/20V8/22V10/20RA10 — and bipolar
20L10 blanks are one-time-programmable and scarce, so a GAL22V10 or ATF22V10C
burned with `pal20l10.jed` is the practical replacement part.

## What IC7 decodes

The pin names come from the IC7 symbol on schematic sheet 011-029-01; the
equations come from the dump. Each output is active low, and asserts when the
right-hand side holds:

| Pin | Net | Asserts when |
|-----|-----|--------------|
| 23 | `/PRCS`   | (`DECH`=0 · `DECL`=0 · `/LCS`) + (`DECH`=1 · `DECL`=1 · `/UCS`) |
| 22 | `/RAM1`   | `/MCS0` · `A15`=0 |
| 21 | `/RAM2`   | `/MCS0` · `A15`=1 |
| 20 | `/OKCS`   | `/PCS6` · `/WR` |
| 19 | `/OOE`    | `/PCS4` · `/WR` |
| 18 | `/EECE`   | `/MCS1` · `A15`=0 · `EEE1`=0 · `EEE2`=1 |
| 17 | `/TEST`   | `EEEREADY`=1 |
| 14 | `/WRVRAM` | `/MCS3` · `/WR` |

Inputs: pin 1 `/LCS`, 2 `/UCS`, 3 `/MCS0`, 4 `/MCS1`, 5 `/PCS4`, 6 `/PCS6`,
7 `DECH`, 8 `DECL`, 9 `EEE1`, 10 `EEE2`, 11 `A15`, 13 `/MCS3`, 15 `EEEREADY`,
16 `/WR`.

Read against the firmware's own memory map (findings
[F1](../../asm/baseline-2026-09/findings.md), F2, F10, F13):

- **`/PRCS`** is the program-ROM select, and it is reached from *both* the
  80188's lower and upper chip-selects. That is the hardware behind ROM1 (IC10)
  appearing twice in the address space — its low half under LMCS at `0x00000`
  and its high half under UMCS at `0xC0000` — which the PinMAME driver models
  by loading the image twice (`SLEIC_ROMSTART5`).
- **`/RAM1` and `/RAM2` split the 64 KB MCS0 block in half on `A15`.** The
  lower half, `0x40000`-`0x47FFF`, is the 32 K × 8 work RAM at IC12, and it
  holds everything the firmware uses — the highest area the ROM addresses is
  the stack segment `4152h` (SP init `0x0205`), under 6 KB in. The upper half,
  `0x48000`-`0x4FFFF`, has a chip-select and no memory: the decode makes room
  for a second 32 KB part the board never populates. The vacant 32-pin socket
  **IC13**, in the same column as IC12, is the obvious destination; sheet
  011-029-01 would confirm it.
- **`/OKCS`** is the write strobe for the OKI phrase latch: `/PCS6` qualified
  by `/WR`, which clocks IC50 (74LS273) with the byte the 80188 writes to
  `0xA0300`. It is not gated on anything else, so every write to the PCS6
  block latches.
- **`/EECE`** is the non-volatile store's chip enable, and it is a genuine
  two-bit interlock rather than one gate bit plus a spare: the store answers
  only when `EEE1` is **low** *and* `EEE2` is **high**, on top of `/MCS1` and
  `A15`=0. `EEE1`/`EEE2` are two bits of the PCS0 control byte latched in IC40,
  and the firmware drives exactly that pattern — `pcs0_window_open` `D057E`
  clears bit 3 and sets bit 4 (`AND 0xF7` / `OR 0x10`), `pcs0_window_close`
  `D059F` does the reverse. So `EEE1` = PCS0 bit 3 and `EEE2` = PCS0 bit 4, the
  boot value `0x28` leaves the store closed, and a single bit stuck at the
  wrong level closes the store rather than leaving it open. This is an
  independent, silicon-side confirmation of **F10**, whose "complementary pair"
  reading came from the firmware alone, and it is the NVRAM write protection
  the board analysis expected to find.
  `A15`=0 also places the window in the lower half of MCS1, agreeing with the
  segment-`5040` (flat `0x50400`) window the firmware uses.
- **`/WRVRAM`** is `/MCS3` qualified by `/WR` — the write strobe into the DMD
  staging buffer at segment `7000` (IC33), the last stage of the F13 pipeline.
- **`/TEST` is driven from `EEEREADY`**, i.e. the 80188's `/TEST` pin carries
  the EEPROM's ready line, inverted. The 80188 `WAIT` instruction blocks until
  `/TEST` is low, so the hardware offers a ready handshake on EEPROM writes.
  **This firmware never uses it**: opcode `0x9B` does not appear as an
  instruction anywhere in either CPU ROM.

## What it does not settle

Two open questions were expected to fall to this dump. Neither does, and the
dump is what shows why — the signals involved never reach IC7:

- **The graphics-page selector's bit order** (open item 2, finding F2). PCS0
  bits 0-2 are latched in IC40 and go to ROM2's `A16`-`A18` directly. IC7 has
  no page-select input and no `A16`-`A18` output. Only a scope, or tracing
  IC40's outputs to IC11, settles which bit is which.
- **The OKI latch's bit-to-pin mapping** (open item 5, finding F9). The phrase
  byte travels `D0`-`D7` → IC50 → the MSM6376. IC7 supplies IC50's clock and
  nothing else, so it says when the byte is latched, never which bit lands on
  which OKI pin.

IC7 also carries no output for the driver expansion board and none for the J1
handshake lines, so it has nothing to say about those either.

## Reproducing the read

The part is soldered. Lifting it is the one invasive step; everything after it
is repeatable from the archived files. With a dupico and the PAL POD:

```sh
dpdumper -p /dev/ttyACM0 read -d PAL20L10.toml \
    -o p20.txt -ob p20.bin -obz p20_hiz.bin --check_hiz
dpdump2tab -d PAL20L10.toml -i p20.bin -o p20.pla
espresso p20.pla > p20.eqn
galasm pal20l10.pld          # -> pal20l10.jed
```

The dumper definition treats the chip as a ROM: address pins
`[1,2,3,4,5,6,7,8,9,10,11,13,15,16]`, data pins `[14,17,18,19,20,21,22,23]`,
no global enable. Establish each pin's direction **before** trusting
`--check_hiz`: that option pulls all data pins high in one pass and low in the
other, so with pins 15/16 still classed as data the array's own inputs move
between passes and driven outputs are misreported as floating.
