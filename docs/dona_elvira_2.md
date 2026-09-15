# Doña Elvira 2 (SLEIC-Petaco, 1996)

[← Back to main README](../README.md)

What the machine's own ROMs and its service manual establish. The ROM images are
archived at [`../roms/related-machines/dona-elvira-2/`](../roms/related-machines/dona-elvira-2/);
the manual is [`../manuals/`](../manuals/), with an OCR transcription at
[`sleic_dona_elvira_2_manual_es.md`](../manuals/sleic_dona_elvira_2_manual_es.md).
Where this document cites the manual it gives the section number, and where it cites
a schematic it gives the sheet's document number.

Doña Elvira 2 is not the IO Moon shape. There is **no 16-bit board**: a Z80 is the
game CPU, a second Z80 does sound, the display is 7-segment rather than a DMD, and
there is no FM synthesiser at all. How it relates to the other SLEIC machines is in
[`sleic_board_family.md`](sleic_board_family.md).

## Still to dump

| What | Where | State |
|---|---|---|
| `ELVSON3` | Sound board `011-065`, IC44, 27C040 | **Needs a re-read** — the archived image is short by 61,440 bytes |
| Three 6331 PROMs | Display board `011-064`, IC2 / IC5 / IC8 | **Never dumped** |

**`ELVSON3` (IC44).** The archived `040V1U04.SOM` is 462,848 bytes where a 27C040
holds 524,288. The missing `0xF000` is an interior hole at chip offset `0x43063`,
not a truncated tail: everything past it is present but sits `0xF000` early in the
file. Three of the 68 OKI phrases are affected — 57 loses its last 28,045 bytes, 58
is lost entirely at 29,823, and 59 loses its first 3,572 — and the loss accounts to
the byte: 28,045 + 29,823 + 3,572 = 61,440 = `0xF000`. The chip is probably fine; a
clean re-read should settle it. The evidence is set out in the
[ROM README](../roms/related-machines/dona-elvira-2/README.md).

**The display PROMs (IC2, IC5, IC8).** `6331` is the generic 32 × 8 bipolar PROM;
`82S123`, `74S288`, AMD `Am27S19` and `HM-6331` are the same part. All are 16-pin
DIP: `O1`-`O8` on pins 1-7 and 9, GND on 8, `A0`-`A4` on 10-14, `/CE` on 15, VCC on
16. `Am27S19` is the tri-state member, which is what this circuit wants — `Am27S18`
is the open-collector sibling.

Two practical points, because the rest of this repository is about locked parts.
These have **no security fuse and cannot be locked**: every fuse in them is a data
bit, so a read always returns the real contents. What they do need is a programmer
that handles bipolar fusible-link PROMs, which many modern USB programmers do not.
Grown-back fuses are a known ageing failure in the technology, so each part is worth
reading several times and comparing. Each dump is only **32 bytes** — that looks
wrong but is correct for a 256-bit part.

Everything else is archived: the game CPU's 27C256, the sound CPU's 27C010, and the
other three 27C040s.

## Board complement

From the manual's element table (§7.1):

| Element | Function | Clave |
|---|---|---|
| C.P.U. 8 bits | Control, audio, video | `011-030` |
| C.P.U. sonido general | Sound control | `011-065` |
| Drivers | Lamp and coil drive | `011-027` |
| Placa display y leds | Display | `011-064` |
| Alimentación sonido | Sound supply | `011-067` |
| Alimentación bobinas | Coil supply | `011-028` |
| Caja de red | Counter, fuses, test | `069-305` |
| Conjunto puentes | Rectification 44 V / 18 V | `021-162` |

`011-030` is the drawing family of IO Moon's Z80 board `011-030A`. The two machines
put the same board to different work: on IO Moon it answers to an 80188, here it is
the game CPU.

## Game CPU — board `011-030`

IC1 a Z80A-6, IC5 the 27C256 labelled `DONA ELVIRA 2 V 1.1`, and the SW10 microswitch
bank (§7.2.1.1). Connectors J1-J7 are listed in §7.2.1.2; J5 is the 10-way ribbon to
the display board.

The ROM uses 18,678 of its 32,768 bytes, the remainder `0xFF`. Its structure:

| Address | What |
|---|---|
| `0x0000` | SLEIC reset block — `NOP NOP DI` fill |
| `0x09`, `0x0D`, `0x11` | `JP 0x02B3` |
| `0x38` | `JP 0x0100` — the mode-1 interrupt |
| `0x66` | `RETN` — the NMI does nothing |
| `0x0100` | boot; dispatches the state machine through a RAM vector at `(0xC0AF)` |
| `0xC0xx` | work RAM |

Its I/O is `IN 0x01`-`0x04` and `OUT 0x80`-`0x87` — **the same port map as IO Moon's
Z80 board**, documented in [`z80_io_ports.md`](z80_io_ports.md). `OUT 0x87` carries
by far the most call sites, which on IO Moon is the direct-input index; what it does
here is not established.

No disassembly beyond these structural checks has been done. Given the 15-18 % code
overlap with IO Moon and Bike Race, the documented switch, lamp and coil port maps
should transfer with little work.

## Sound — board `011-065`

IC1 a Z80B-6, IC41 an **OKI MSM6376** voice synthesiser, IC5 the 27C010 program
EPROM `ELVSONO`, IC42-IC45 the four 27C040 sample EPROMs `ELVSON1`-`ELVSON4`, IC60 a
TL08x and IC61/IC62 TDA2030 power amplifiers (§7.2.3.1). J2 is the ribbon to the
CPU board, J3 the bass speaker in the cabinet, J4 the mid and treble speakers in the
head (§7.2.3.2).

**There is no FM chip.** All music is streamed ADPCM, which is why the machine needs
four 27C040s where IO Moon needs two: phrase 57 alone is a single 1,154,573-byte
sample.

### The sound program

`ELVSONO` uses 1,480 bytes of its 128 KB (`0x0000`-`0x05C7`), the remainder `0xFF`.
That is the whole program — it is a command relay for the OKI, nothing more.

It opens with the same shape as IO Moon's Z80 ROM: `IM 1` (`ED 56`) in the first
instruction block, vectoring to `0x0400`. `0x38` is `RETI`, so the maskable interrupt
does nothing. Boot at `0x0400` sets `IM 1` and the stack to `0x87FF`; work RAM is at
`0x8000`.

| Address | Role |
|---|---|
| `0x0066` | NMI — `IN A,(0x00)` into `[0x800F]`, the inbound command byte |
| `0x0400` | boot: stack, port shadows, then `JP 0x04B9` |
| `0x041B` | initial port states — `0xEF` to port 0, `0x7F` to port 1, `0x39` to port 2 |
| `0x0452` | periodic tick (`EX AF,AF'` / `EXX`), running the down-counters |
| `0x04B9` | main loop: service the tick, dispatch `[0x800F]` when it is not `0xFF` |
| `0x04EB` | command dispatch |
| `0x0557` | OKI latch strobe — pulse port-1 bit 1 low then high |

Ports:

| Port | Direction | Role |
|---|---|---|
| `0x00` | in | the command byte from the game CPU, read only in the NMI |
| `0x00` | out | handshake back: bit 0 tracks the port-1 input, bit 1 a delayed acknowledge |
| `0x01` | in | bit 1, polled in the main loop and while waiting |
| `0x01` | out | bit 1 the OKI latch strobe; bit 7 pulsed in the reset sequence at `0x058F` |
| `0x02` | out | the OKI MSM6376 data latch |

Command dispatch at `0x04EB` branches three ways on the byte:

- **zero** → `0x0530`, a resync: clear port-0 bit 0, pulse port-1 bit 7, then wait up
  to 200 ticks for port-1 bit 1, restarting itself on timeout.
- **bit 7 set** → `0x051A`: write the byte to the latch, strobe once.
- **bit 7 clear, non-zero** → `0x0520`: write the byte, strobe, then write it again
  with bit 7 set.

Afterwards the epilogue at `0x0503` clears port-0 bits 0 and 1, arms a 70-tick
counter that later raises port-0 bit 1, and restores `[0x800F]` to `0xFF`.

That port-1 bit 7 line is pulsed low-then-high around a write of `0x00` to the latch
in the longer sequence at `0x058F`, which reads as an OKI reset — but that is an
inference from the firmware, not from a schematic, and is not established.

### The sample set

The four 27C040s form one 2 MB MSM6376 phrase space in the order `ELVSON1`,
`ELVSON2`, `ELVSON3`, `ELVSON4`. The order is established from the data, not
assumed: the phrase table sits at offset 0 of `ELVSON1`, `ELVSON2` carries an
unbroken 128-byte block grid across its whole 512 KB, and the last phrase ends
exactly on the last programmed byte of `ELVSON4`.

The table occupies `0x000`-`0x1FF` of `ELVSON1` as 128 four-byte entries:

```
address = ((b0 & 0x3f) << 16) | (b1 << 8) | b2       b0 bit 6 set on a live entry
```

A sample is a chain of blocks, each a length byte masked to seven bits followed by
that many payload bytes, terminated by a zero byte. Samples are packed end to end —
the longest run of `0xFF` inside the used area of any of the four chips is 2 bytes.

**68 phrases** are defined, in slots 1-80; slots 8, 10, 12, 14, 20, 33, 38, 41, 42,
45, 47 and 49 are empty. They address 1,710,386 bytes in total, from `0x000220` to
`0x1A1B52`.

The same layout decodes IO Moon's own sound ROMs — 28 phrases, all contiguous, the
last ending exactly on the last programmed byte — which is the control this reading
is checked against. The extraction script is
[`extract_oki_msm6376.md`](extract_oki_msm6376.md).

**The sample rate is not established for this machine.** IO Moon's ~32 kHz is
measured from *its* firmware's duration table against its own nibble counts, and
nothing here transfers that: this sound board has a different CPU clock and a
different program. Any duration quoted in seconds elsewhere in this repository for
Doña Elvira 2 assumes 32 kHz as a placeholder. Measuring this machine's own tick
against its sample lengths, or a scope on the 6376, would settle it.

Which phrase corresponds to which game event is not established either — that needs
the game ROM disassembled.

## Display — board `011-064`

7-segment, driven serially. §7.2.4.1 lists the digits as **HDSP 3901** and **HDSP
H101**; the schematic sheets spell the second part `HDSP H103`, so the manual is
inconsistent with itself and the physical parts are the authority. IC2, IC5 and IC8
are the three `6331` PROMs. J1 is a 10-way ribbon to the CPU board, J2 a 4-pin Molex
supply (§7.2.4.2).

Sheet `011-064-02` gives the whole arrangement. These are the J1 pins the sheet
labels; 1, 2 and 7 carry no label in it:

| Pin | Signal |
|---|---|
| 3 | `SDATA` |
| 4 | `DECD` |
| 5 | `SCLK` |
| 6 | `DECC` |
| 8 | `DECB` |
| 9 | `0VCC` |
| 10 | `DECA` |

`SDATA` and `SCLK` arrive through 100 Ω series resistors with 1 kΩ pull-ups to VCC
and 1 nF to ground. They clock three **74164** serial-in / parallel-out shift
registers (IC1, IC4, IC7), daisy-chained — `QH` of each feeds the `A`/`B` inputs of
the next — so the board is one 24-bit shift register. Only the low five outputs of
each stage (`QA`-`QE`, pins 3, 4, 5, 6, 10) reach the `A0`-`A4` address lines of the
6331 beside it; `/CE` on all three PROMs is tied to ground, so they are permanently
enabled, and `O1`-`O8` drive the segments.

Each 6331 is therefore a **character generator: a 5-bit code in, an 8-bit segment
pattern out**. PinMAME records the same arrangement for IDSA, another Spanish
manufacturer of the period, at `src/wpc/idsa.c:67`.

The consequence matters for any future emulation: **the machine's alphabet lives in
those three PROMs and in no ROM already dumped.** Without them the segment pattern
for a given code cannot be known.

What the four-bit `DECA`-`DECD` bus selects is not established — it is not traced on
the sheets read so far, and the obvious reading, a digit or digit-group select, is a
guess.

## What is open

- **A re-read of `ELVSON3`** and **the three display PROMs**, as above.
- **The OKI sample rate** for this machine.
- **`DECA`-`DECD`** — what the bus selects.
- **Port-1 bit 7** on the sound board — reads as the OKI reset, unconfirmed.
- **`OUT 0x87`** on the game CPU — 100 call sites, role not established.
- **The game ROM itself** — no disassembly beyond the structural checks above, so
  the switch, lamp and coil maps, the scoring and the phrase-to-event mapping are
  all unknown.
- **Which physical IC each sample image was read from** — inferred from the
  manual's ordering; what the data proves is the order itself.
