# Io Moon — the drop-target bank

The five-target drop bank (*Bancada*) and the target behind it (*Fondo Bancada*),
read out of the 80188 ROM and checked against the service manual's §3.3.6.
[`iomoon_game_rules.md`](iomoon_game_rules.md) carries the rules as the manual
states them; this file carries the code that implements them, the two game modes
that turn on the bank's state, and what is known and open about resetting it.

## The contacts

| Target | Contact | Code | Matrix | Manual name |
|---|---|---|---|---|
| Bank A | C25 | `0x1B` | c2.1 | DIANA BANCADA A |
| Bank B | C26 | `0x1C` | c2.2 | DIANA BANCADA B |
| Bank C | C27 | `0x1D` | c2.3 | DIANA BANCADA C |
| Bank D | C28 | `0x1E` | c2.4 | DIANA BANCADA D |
| Bank E | C29 | `0x1F` | c2.5 | DIANA BANCADA E |
| Inner bank | C30 | `0x20` | c2.6 | FONDO BANCADA |

The inner target sits **behind** the bank, so it is only reachable once the five
are down. The firmware relies on that: its handler carries no "all five down"
test (see [Special Drop Probe](#the-inner-target) below).

## How a bank target is handled

The in-game dispatcher at `D7661` indexes the jump table at `CS:0527`
(`CS = D72A`) by `code − 0x0E`. Entries 13-17 are five identical stubs at
`D76C6`, `D76D2`, `D76DE`, `D76EA`, `D76F6`:

```
D76C6:  6A 2C            PUSH 02C                 ; this target's lamp index, 0x2C..0x30
D76C8:  CALL sub_DC934                            ; clear it -- the target is down
D76CE:  6A 1B            PUSH 01B                 ; this target's switch code
D76D0:  JMP  D7700                                ; the shared tail
```

`D7700` calls `sub_D72AA(code)` and then **`sub_D89B5`**, which is the whole
rule:

| Where | What |
|---|---|
| `D89BD` | OKI phrase `0x16` |
| `D89D1` | score **+ `0x63A9` = 25,513** |
| `D89EB` | **`INC [413C:00103]`** — the bank counter |
| `D89F8`-`D8A31` | the progressive awards, on counter = 2, 4, 5 |
| `D8A3D` | if the mode register `[413C:00F4] == 5`, a **further `0x186A0` = 100,000** |

**The base value is 25,513.** §3.3.6 gives only the Special Drop Target figure
and states no base, so this is the ROM's number and has no manual counterpart.

### The progressive awards

`sub_DC97A(n)` writes 0 to `[413C:0104 + n]` and `sub_DC934(n)` writes 1;
`sub_DBCA1` fills that array with 1 at boot, with every lamp dark, so **0 is lit
and 1 is dark** (2 is a third state both routines decline to overwrite). Read
that way the code is §3.3.6 exactly:

| Counter | Code | §3.3.6 |
|---|---|---|
| 2 | `sub_DC97A(0x07)` | lights LP9 (Bonus ×10) |
| 4 | `sub_DC97A(0x05)`, `sub_DC934(0x07)` | lights LP7 (Special), LP9 off |
| 5 | `sub_DC97A(0x36)`, `sub_DC97A(0x06)`, `sub_DC934(0x05)` | lights LP8 (Extra Ball), LP7 off |

So lamp index 5 = LP7, 6 = LP8, 7 = LP9. The tests are `CMP AX,2 / JE`,
`CMP AX,4 / JE`, `CMP AX,5 / JE` — **equality**, not threshold, which matters to
anything that would reset the counter mid-ball.

### The inner target

`sub_D8A7C` (dispatcher entry 18):

- OKI phrase `0x1A`.
- `D8A96`: with `[00F4] == 5` (Special Drop Target), score **+100,000** and stop.
- otherwise `D8B0A`: score **+ `0xC351` = 50,001**, §3.3.5's stated value.
- `D8AD0`: with `[0013A] == 0` **and** `[00F4] == 0`, it lights lamps and calls
  `sub_DB369` — the manual's **Special Drop Probe**. There is no bank-counter
  test here; the bank being down is enforced by the playfield, not the code.

## The two modes the bank decides

`[413C:00F4]` is the mode register. It is written with 0-9 at eleven sites
(`D371B`, `D9E13`, `D9E60`, `DAE97`, `DAEB2`, `DB002`, `DB12B`, `DB230`,
`DB374`, `DB54D`, `DB702`, and the clears at `DB5EB`, `DB77C`, `DB7DF`,
`DBE81`, `DBFDE`).

**The bank counter is the selector between Multiball and Wonderful Thing.** At
the second Jupiter lock, inside `sub_D9D04`'s count-2 branch:

```
D9E06:  CMP ES:[00103], 005      ; the bank counter
D9E0C:  JB  D9E5B                ; fewer than five down -> D9E60: [00F4] = 9, Multiball
D9E0E:  MOV ES:[000F4], 001      ; all five down        -> mode 1, Wonderful Thing
```

| Mode | `[00F4]` | Relationship to the bank |
|---|---|---|
| Wonderful Thing (Black Hole Power, §3.2.2) | 1 | **requires all five down** at the second lock |
| Multiball (§3.2.1) | 9 | requires them **not** all down at the second lock |
| Special Drop Target (§3.2.5, Monolith LPA9) | 5 | while it runs, every bank target pays +100,000 |

Clearing the bank is therefore not only a qualification — it is the choice that
**costs the player Multiball**.

Mode 5 is tested in four handlers, not one: the bank (`D8A3D`), the inner target
(`D8A96`), bull's-eye 1 (`D8B4A`, `sub_D8B30`) and bull's-eye 2 (`D8C8B`,
`sub_D8C71`). A flat bank costs Special Drop Target five of its eight boosted
targets; the two bull's-eyes and the inner target still pay 100,000.

No other mode's value is tested in the bank handler, so Impact Count, Orbit Flip
and Star Ride do not change what the targets pay.

## Resetting the bank

**The bank comes up at ball start and at no other time.** Its reset coil is 18
(*Bancada de Dianas*).

**No firmware path to that coil is known.** F17 enumerates every `OUT` in the
Z80 ROM — 105 instructions, exactly eight distinct ports, all accounted for —
and coil 18 is on driver expansion board 011-033A, which neither CPU can
address. Coils 17-21 "are fed from one of the sixteen channels or from the
011-033A connector itself"; which is **open**.

Z80 command `0xF3` is not the reset. Its handler is three instructions and
fires nothing:

```
2A3A:  LD A,#$FF / LD ($C054),A / RET
```

### What this costs the player

Because the bank cannot be rebuilt mid-ball:

- **Special Drop Target** started with the bank already flat has only the two
  bull's-eyes and the inner target left to pay 100,000.
- **Special Drop Probe** needs five standing targets to knock down.
- Order matters: clear the bank *after* the Monolith hands you a mode, and
  decide before the second Jupiter lock which multiball you want.

### Why PinMAME cannot settle it

The simulator models the bank fully — `swBankA`-`swBankE` carry `SIM_STSWKEEP`,
so a target stays down once hit, and `iomoon_handleMech` raises all five on
`sBankReset`. But `sBankReset` is `CORE_CUSTSOLNO(2)`, **derived from command
`0xF3`**, and `0xF3` drives nothing on hardware. The driver's own comment says
the reset is "modelled from the manual's rules, not from either ROM (F17)".

A ROM patch that sent `0xF3` mid-ball would therefore **reset the bank in
PinMAME and do nothing on the machine**. Any headless test of a bank-reset patch
is a false positive until the drive path is known.

### What would settle it

The machine's own coil test: *TECNICO → TEST TABLERO → BOBINAS*, menu record 24,
which offers `RELAY ON` and `SOLEN. NUM.`. With the glass off and all five
targets pushed down by hand, fire each solenoid number in turn and watch the
bank. Coil 18 answers it directly if the test offers it; coil 17 (*Salida de
Bolas*, the ball serve) is the candidate that would explain "resets at ball start
and never again" with no firmware involvement at all.

Three outcomes: a coil raises the bank and the drive path is known; coil 18 is
selectable and does nothing, so the firmware addresses a channel that is not
wired to the bank; or nothing raises it, and no ROM patch can ever reset the
bank.

## SW40 numbering

The country switches SW2-SW4 are port-`0x04` **bits 1-3**, so the block is wired
switch *n* → bit *n−1*. The trough-check bypass the firmware reads is **bit 5**
(`2BEB: IN A,($04) / BIT 5,A / JP Z,$2C17`), which is therefore physical
**switch 6**, not switch 5. Confirmed on the machine: with SW40-6 in the service
position a machine whose trough reports a fault boots past BALL MISSING into
attract; switch 5 has no effect in either position.

The manual's §7.2.2.3 table names SW5 "no balls dispensed" and SW6 "solenoid
test". The firmware reads bit 5 and no other bit above the country field, so the
manual's two rows do not match what the ROM does.
