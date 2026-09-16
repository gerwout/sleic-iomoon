# IO Moon — Complete Rule Set

[← Back to main README](../README.md)

How the SLEIC **IO Moon** (1994) plays: what every contact does, what every
playfield light means, how each mode starts and ends, and which of it an
operator can change.

The rules themselves are the original SLEIC service manual, **SECCION 3
"DESCRIPCION DEL JUEGO"** for play, **SECCION 4** for high-score entry and
**SECCION 5** for the adjustables. The contact numbers, contact names, coil
numbers and lamp-matrix positions are the firmware's own, from findings
**F16**, **F17** and **F18** of
[`../asm/baseline-2026-09/findings.md`](../asm/baseline-2026-09/findings.md).

The theme is a voyage to **Io**, a moon of Jupiter (§1.1). Three balls can be
in play at once.

---

## How to read this page

**Citations.** A bare `§` is a section of the service manual — `§3.3.1` is the
PASILLOS table. **F16**, **F17** and **F18** are findings numbers from the
cross-verified disassembly: F16 the switch-code → contact table, F17 the coil
map, F18 the measured lamp matrix. Where the manual and the ROM disagree, **the
ROM is what runs** and the difference is called out where it falls.

**Spanish.** The machine speaks Spanish: the manual, the DMD and the service
menu all use these words, and the firmware carries both languages (F16), so
both are given throughout.

| Spanish | English | What it is |
|---|---|---|
| *Pasillo* | lane | a rollover lane, 11 of them |
| *Rampa* | ramp | one of the two ramps |
| *Bumper* | bumper | the five pop bumpers |
| *Diana* | target | covers both the two stand-up bull's-eyes and the drop-target bank |
| *Bancada* | (drop-target) bank | the five-target drop bank |
| *Fondo Bancada* | inner bank | the target behind the bank |
| *Tragabolas* | scoop / hole | one of the two ball-swallowing holes |
| *Expulsor* | shooter / kicker | one of the two side kickers |
| *Sueltabolas* | ball release | the Jupiter release coil |
| *Taca* | — (no English name) | part of Tragabolas 1's return (F17) |
| *Bola Extra* | extra ball | |
| *Especial* | Special | |
| *Falta* | tilt | |
| *Lotería* | lottery | the post-game draw (§3.5) |
| *Partida (gratis)* | (free) game | |
| *Deletreo* | spelling | the ORBITS letters |

**Scoring notation.** The manual writes Spanish thousands separators —
`3.000.000` is three million. This page uses `3,000,000`.

**Maximum score** is 999,999,999 (§3.4).

---

<p align="center">
  <a href="../images/iomoon-playfield.jpeg" target="_blank" rel="noopener">
    <img src="../images/iomoon-playfield_thumb.jpg" alt="IO Moon playfield, unpopulated, insert legends readable" width="700">
  </a>
  <br>
  <em>The lower playfield with nothing mounted on it, which is the clearest record of the
  insert legends this page names.</em>
</p>

Every light named below is readable on that photograph, including the three fixed-award
inserts `3 MILLIONS`, `6 MILLIONS` and `9 MILLIONS` down the right of the monolith, which
the manual's own light list does not name.

---

## The playfield, contact by contact

Every scoring device, with the manual's contact number (**C*n***, §2.1.1), the
**switch code** the Z80 puts on the J1 wire, its **column.bit** in the switch
matrix, and the firmware's own name in both languages — all four from **F16**.
A rule below can therefore be traced to a byte on the wire.

The coil column is **F17**: coils 1–16 are the Z80's two driver latches, ports
`$85` and `$86`. Coils **17–21** sit on driver expansion board 011-033A and
**no Z80 port drives them** (F17) — see [Coils](#the-coils).

### Lanes — *Pasillos*

| Device | C# | Code | col.bit | Firmware name (EN / ES) |
|---|---|---|---|---|
| Lane 1 | C12 | `0x19` | c1.7 | LANE 1 / PASILLO 1 |
| Lane 2 | C13 | `0x18` | c1.6 | LANE 2 / PASILLO 2 |
| Lane 3 | C14 | `0x17` | c1.5 | LANE 3 / PASILLO 3 |
| Lane 4 | C17 | `0x0F` | c0.5 | LANE 4 / PASILLO 4 |
| Lane 5 | C18 | `0x0E` | c0.4 | LANE 5 / PASILLO 5 |
| Lane 6 | C24 | `0x1A` | c2.0 | LANE 6 / PASILLO 6 |
| Lane 7 | C41 | `0x37` | c5.3 | LANE 7 / PASILLO 7 |
| Lane 8 | C42 | `0x36` | c5.2 | LANE 8 / PASILLO 8 |
| Lane 9 | C43 | `0x35` | c5.1 | LANE 9 / PASILLO 9 |
| Lane 10 | C48 | `0x2F` | c4.5 | LANE 10 / PASILLO 10 |
| Lane 11 | C22 | `0x12` | c1.0 | LANE 11 / PASILLO 11 |

Lanes 1–3 are one wiring group (column 1) and lanes 4–5 another (column 0);
their lamps are grouped the same way (F18), which is the first check on the
light mapping below.

### Ramps — *Rampas*

| Device | C# | Code | col.bit | Firmware name (EN / ES) |
|---|---|---|---|---|
| Ramp 1 entrance | C40 | `0x29` | c3.7 | RAMP 1 ENTRANCE / ENTRADA RAMPA 1 |
| Ramp 1 middle | C49 | `0x30` | c4.6 | RAMP 1 MIDDLE / MEDIA RAMPA 1 |
| Ramp 1 exit | C21 | `0x13` | c1.1 | RAMP 1 EXIT / SALIDA RAMPA 1 |
| Ramp 2 entrance | C39 | `0x2D` | c4.3 | RAMP 2 ENTRANCE / ENTRADA RAMPA 2 |
| Ramp 2 exit | C47 | `0x34` | c5.0 | RAMP 2 EXIT / SALIDA RAMPA 2 |

> **C21 is not wired.** §2.1.1 lists it *Sin conectar*, and its per-bit
> dispatcher in the Z80 ROM is a bare `RET` (F16) — the name exists in the
> firmware's table, the contact does not exist on the playfield. Ramp 1 is
> therefore sensed at its entrance and its middle only.

The ramp **diverter** is coil 19 (*Diverter de Rampa*), on the expansion board.

### Bumpers

Five pop bumpers, each with its own coil. Note the switch codes do not run in
C-number order (F16).

| Device | C# | Code | col.bit | Coil |
|---|---|---|---|---|
| Bumper 1 | C33 | `0x23` | c3.1 | 7 |
| Bumper 2 | C34 | `0x26` | c3.4 | 9 |
| Bumper 3 | C35 | `0x25` | c3.3 | 10 |
| Bumper 4 | C36 | `0x28` | c3.6 | 11 |
| Bumper 5 | C37 | `0x27` | c3.5 | 12 |

### Targets — *Dianas*

| Device | C# | Code | col.bit | Firmware name (EN / ES) |
|---|---|---|---|---|
| Bull's-eye 1 | C32 | `0x24` | c3.2 | BULL EYE 1 / DIANA 1 |
| Bull's-eye 2 | C38 | `0x2E` | c4.4 | BULL EYE 2 / DIANA 2 |
| Bank A | C25 | `0x1B` | c2.1 | BANK A / DIANA BANCADA A |
| Bank B | C26 | `0x1C` | c2.2 | BANK B / DIANA BANCADA B |
| Bank C | C27 | `0x1D` | c2.3 | BANK C / DIANA BANCADA C |
| Bank D | C28 | `0x1E` | c2.4 | BANK D / DIANA BANCADA D |
| Bank E | C29 | `0x1F` | c2.5 | BANK E / DIANA BANCADA E |
| Inner bank | C30 | `0x20` | c2.6 | INNER BANK / FONDO BANCADA |

The bank's reset coil is 18 (*Bancada de dianas*), on the expansion board.

### Scoops, shooters and Jupiter

| Device | C# | Code | col.bit | Firmware name (EN / ES) | Coil |
|---|---|---|---|---|---|
| Scoop 1 | C23 | `0x22` | c3.0 | HOLE 1 / TRAGABOLAS 1 | 8, plus 13 (*Taca*) |
| Scoop 2 | C31 | `0x21` | c2.7 | HOLE 2 / TRAGABOLAS 2 | **none** |
| Left shooter | C15 | `0x16` | c1.4 | LEFT SHOOTER / EXPULSOR IZQ. | 14 (*Expulsor 1*) |
| Right shooter | C16 | `0x15` | c1.3 | RIGHT SHOOTER / EXPULSOR DERECHO | 15 (*Expulsor 2*) |
| Jupiter entry | C50 | `0x31` | c4.7 | ENTRADA JUPITER | — |
| Jupiter 1 | C44 | `0x2A` | c4.0 | JUPITER 1 | — |
| Jupiter 2 | C45 | `0x2B` | c4.1 | JUPITER 2 | — |
| Jupiter 3 | C46 | `0x2C` | c4.2 | JUPITER 3 | — |

> **Scoop 1 is kicked out, scoop 2 is not** (F17 addendum). Scoop 1 fires coil
> 13 (*Taca*) and then coil 8 (*Tragabolas 1*), measured reproducibly — *Taca*
> belongs to scoop 1's own ball return, not to scoop 2. Scoop 2 has **no coil
> at all**: §2.3.1's list of 21 coils names none for it, and no solenoid fires
> for 900+ frames after the contact arrives, reproduced on two runs. §3.3.8
> nonetheless
> gives scoop 2 a full set of awards, so the ball does leave it — by gravity or
> by a mechanical kick-out, not by a driven coil.

> **C44–C46: the ROM says JUPITER, the manual says *Planeta*.** §2.1.1 names
> these three contacts *Planeta 1/2/3*; the firmware names them JUPITER 1/2/3
> in both languages, and they are the ball device the 80188 counts with command
> `0xEB` — the Jupiter lock §3.3.7 describes (F16). The ROM is what runs. The
> manual's own lamp list uses *Planeta* for three different items (LC51, LC61,
> LC62 — lamps, not contacts), so §2.1.1's naming here is corroborated nowhere
> else in the manual.

### Ball handling and cabinet

| Device | C# | Code | col.bit | Firmware name (EN / ES) |
|---|---|---|---|---|
| Trough 1 (entry, also ball-over) | C6 | `0x0A` (reports `0x43`) | c0.0 | OUTHOLE 1 / SALIDA BOLAS 1 |
| Trough 2 | C7 | `0x0B` | c0.1 | OUTHOLE 2 / SALIDA BOLAS 2 |
| Trough 3 | C8 | `0x0C` | c0.2 | OUTHOLE 3 / SALIDA BOLAS 3 |
| Ball out (drain) | C9 | `0x0D` | c0.3 | BALL OUT / BOLA FUERA |
| Left flipper cut-out | C11 | `0x10` | c0.6 | L.C.FLIPPER / C. FLIPPER IZQ. |
| Right flipper cut-out | C10 | `0x11` | c0.7 | R.C.FLIPPER / C. FLIPPER DER. |
| Upper flipper cut-out | C19 | `0x14` | c1.2 | U.C.FLIPPER / C.FLIPPER SUP. |
| Left flipper button | C1 | `0x41` | direct | L. FLIPPER / FLIPPER IZQ. |
| Right flipper button | C5 | `0x42` | direct | R. FLIPPER / FLIPPER DER. |
| START | C2 | `0x40` | direct | START BUTTON / PULSADOR START |
| Coin | C3 | `0x32` (`0x33` in test) | direct | COINS INPUT / MONEDERO |
| TEST | C4 | `0x3F` | direct | TEST BUTTON / PULSADOR TEST |
| Tilt pendulum | C20 | `0x3E` | direct | PLUMB TILT / PENDULO DE FALTA |

Balls fill the trough from contact 3 down; contact 1 doubles as the ball-over
sensor and reports code `0x43` rather than its own `0x0A`. The trough kicker is
coil 17 (*Salida de bolas*), on the expansion board. The three flipper cut-out
contacts are end-of-stroke power cuts, not scoring.

> **C10/C11 are crossed between the two sources.** The ROM pairs C10 with the
> **right** flipper cut-out and C11 with the **left**; §2.1.1 has it the
> opposite way round (F16). The ROM is what runs. Nothing in play depends on
> which way it goes.

The flipper buttons fire their coil pairs directly in the Z80 and send nothing
over J1 during play; they emit codes `0x41`/`0x42` only in test mode (F16),
which is why the same two buttons drive the service menu.

See [`switch_lamp_solenoid.md`](switch_lamp_solenoid.md) for the same tables in
full, including the four column-5 positions that do not exist.

---

## The lights the rules name

**This is the page's reason to exist.** SECCION 3 writes its rules in terms of
lights called `LPA`*n*, `LP`*n*, `LR`*nn*, `LD`*n*, `LTB`*nn* and `LBH` — and
**none of those names appears in the manual's own lamp list**, §2.2.2, which
only ever uses `LC1`–`LC64`. A reader with the manual alone cannot follow the
rules. The mapping below closes that gap.

Each row is established from §2.2.2's own text: the lamp list names every LC by
the device it sits on and the award it stands for, and the rules text names each
light by the same award. The **F18** column gives the lamp's measured
(column.bit) position in the Z80's lamp matrix, which corroborates the mapping
structurally — see the note after the table.

| Rules name | Lamp | §2.2.2's own name for it | F18 col.bit | Basis |
|---|---|---|---|---|
| LPA1 | LC2 | Monolith message: Extra Ball | 3.0 | award name |
| LPA2 | LC3 | Monolith message: 3,000,000 | 3.1 | award name |
| LPA3 | LC4 | Monolith message: Little Multiball | 3.2 | award name |
| LPA4 | LC5 | Monolith message: 6,000,000 | 3.3 | award name |
| LPA5 | LC6 | Monolith message: Special on Lane 1 or 5 | 3.4 | award name |
| LPA6 | LC7 | Monolith message: 9,000,000 | 3.5 | award name |
| LPA7 | LC8 | Monolith message: Impact Count | 3.6 | award name |
| LPA8 | LC9 | Monolith message: Orbit Flip | 3.7 | award name |
| LPA9 | LC10 | Monolith message: Special Drop Target | 4.0 | award name |
| LPA10 | LC11 | Monolith message: Star Ride | 4.1 | award name |
| LPA11 | LC12 | Lagrange Scape | 4.2 | name, verbatim (§3.3.4) |
| LPA12 | LC13 | Lagrange Orbit | 4.3 | name, verbatim (§3.3.4) |
| LP1 | LC14 | Lane 1: Special | 4.7 | device + award |
| LP2 | LC15 | Lane 2: Orbits ×2 | 4.6 | device + award |
| LP3 | LC16 | Lane 3: lights Autodrop | 4.5 | device + award |
| LP4 | **LC18** | Lane 4: lights Orbits spelling | 7.5 | device + award |
| LP5 | LC19 | Lane 5: Special | 7.6 | device + award |
| LP7 | LC57 | Lane 7: Special | 5.4 | device + award |
| LP8 | LC58 | Lane 8: Extra Ball | 5.5 | device + award |
| LP9 | LC59 | Lane 9: Bonus ×10 | 5.6 | device + award |
| LP11 | LC36 | Lane 11: Autodrop | 2.7 | device + award |
| LR11 | LC54 | Ramp 1: Orbits ×2 | 1.3 | device + award |
| LR12 | LC55 | Ramp 1: lights Hole Power | 1.2 | device + function, by elimination |
| LR21 | LC56 | Ramp 2: Superjackpot | 1.5 | device + award |
| LR22 | LC53 | Ramp 2: Extra Ball | 1.4 | device + award |
| LBH | LC60 | Ramp 2: Black Hole Power | 5.7 | name, verbatim |
| LD1 | LC39 | Bull's-eye 1: Orbits spelling | 6.7 | device + award |
| LD2 | LC52 | Bull's-eye 2: Jackpot | 1.6 | device + award |
| LTB11 | LC37 | Scoop 1: Monolith message | 2.6 | device + award |
| LTB12 | LC17 | Scoop 1: Little Multiball | 4.4 | device + award, and §3.3.7 says "in TB1" |
| LTB2 | LC50 | Scoop 2: Monolith message | 6.6 | device + award |

**The naming scheme, once the rows are in place.** `LPA` = the Monolith
(*panel*) lights. `LP`*n* = the light at **lane** *n* — which is why there is no
LP6 and no LP10 (lanes 6 and 10 have no lamp in §2.2.2, and their rules do not
need one). `LR`*rn* = **ramp** *r*, light *n* — so LR11/LR12 are on Ramp 1 and
LR21/LR22 on Ramp 2, matching §2.2.2 exactly: Ramp 1 has two lamps (LC54,
LC55), Ramp 2 has three (LC53, LC56, LC60). `LD`*n* = the light at **bull's-eye
(*Diana*)** *n*. `LTB`*sn* = **scoop (*Tragabolas*)** *s*, light *n* — scoop 1
has two lamps (LC17, LC37) and scoop 2 has one (LC50), again exactly as §2.2.2
has it. `LBH` = **Black Hole**.

**Two rows deserve their reasoning spelled out.**

- **LP4 is LC18, not LC17.** LPA1–LPA10 map to LC2–LC11 as a clean +1 offset,
  and LP1/LP2/LP3 continue it into LC14/LC15/LC16 — but the offset then
  **breaks**, because LC17 is not a lane lamp at all: §2.2.2 gives it as *scoop
  1: Little Multiball*. LP4 is the Lane 4 lamp, which §2.2.2 puts at LC18
  ("Lane 4: lights Orbits spelling"), matching §3.1's own gloss of LP4 as
  "possibility of Orbits Spell" and §3.3.1's "Lane 4 lit → lights LD1 (Orbits
  Spell)". Extending the offset past LC16 gives the wrong answer.
- **LR12 is LC55 by elimination plus function.** §2.2.2 gives Ramp 1 exactly
  two lamps, LC54 ("Ramp 1: Orbits ×2") and LC55 ("Ramp 1: lights Hole Power").
  LR11 is LC54 on a verbatim award match. §3.2.4 puts LR12 on Ramp 1 and says
  running the ramp with it lit lights LBH (Black Hole Power) — which is what
  §2.2.2 says LC55 does. LC55's name drops the word *Black* that LC60's keeps;
  the two are different lamps on different ramps.

**F18 corroborates the mapping structurally**, independently of the names. Four
blocks of the measured lamp matrix fall out exactly as the mapping predicts:

- the **twelve** Monolith lights LPA1–LPA12 are twelve **consecutive** matrix
  positions in order, column 3 bit 0 through column 4 bit 3 (LC2…LC13);
- the **four** ramp lights are four consecutive positions, column 1 bits 2–5
  (LC55, LC54, LC53, LC56 = LR12, LR11, LR22, LR21);
- LP7, LP8, LP9 and LBH are four consecutive positions, column 5 bits 4–7
  (LC57–LC60);
- the six ORBITS letters are six consecutive positions **in spelling order**,
  column 2 bits 0–5 (see below).

A mis-assignment inside any of those blocks would break its run.

### The ORBITS spelling

The rules refer to «luces "ORBITS"» without ever giving the lamps an `L` name.
They are §2.2.2's six *Deletrea* lamps, and F18 places them at six consecutive
matrix positions in spelling order:

| Letter | Lamp | F18 col.bit |
|---|---|---|
| O | LC38 | 2.0 |
| R | LC41 | 2.1 |
| B | LC44 | 2.2 |
| I | LC46 | 2.3 |
| T | LC48 | 2.4 |
| S | LC49 | 2.5 |

Letters are lit at bull's-eye 1 while LD1 is on (§3.3.5), and the firmware keeps
the count in a single byte, `[413C:0102]`, hard-capped at 6. Completing the word
gates three things: Jupiter holds balls at all (§3.3.7), the Monolith offers
LPA3 / Little Multiball (§3.3.3), and lane 10 pays its larger award (§3.3.1).
Those are the three places the firmware tests the count against 6.

### Lamps the rules never mention

| Lamps | §2.2.2 name | Status |
|---|---|---|
| LC20–LC23, LC26–LC29 | Bonus 1–4, Bonus 7–10 | the bonus ladder (below) |
| LC24, LC25 | *No conectado* | the ladder's 5th and 6th positions, unpopulated |
| LC30–LC35 | Bank A, B, Inner, D, E, C | the drop bank's own six lamps |
| LC40, LC43, LC45, LC47 | Bumper 3, 4, 2, 5 | the four lit bumpers |
| LC42 | *No conectado* | fifth bumper-lamp position, unpopulated |
| LC51, LC61, LC62 | *Planeta 5*, *Planeta 1*, *Planeta 2* | no rule in SECCION 3 refers to any of them |
| LC63, LC64 | *No conectado* | |
| LC1 | Start button | cabinet |

**Bonus ladder.** §2.2.2 names ten steps but connects eight: Bonus 1–4, then
LC24/LC25 *No conectado*, then Bonus 7–10. F18 shows LC20–LC29 occupying ten
consecutive matrix positions (column 0 bits 0–7 and column 1 bits 0–1), so the
two unconnected lamps are the ladder's own 5th and 6th positions left
unpopulated — the wiring is for ten, the playfield shows eight.

**Bumper lamps.** §2.2.2 gives lamps for bumpers 2, 3, 4 and 5 and names none
for bumper 1; F18 puts those four plus the unconnected LC42 at five consecutive
positions (column 7 bits 0–4). That is consistent with LC42 being the fifth
bumper's own lamp position left unpopulated, which would mean **bumper 1 has no
lit state** and always pays the unlit value. That is an inference from the
grouping, not something either source states — see [Open](#open-questions).

---

## The coils

§2.3.1 lists **21 coils** — "18 coils, and the flippers are double-wound, which
makes 21". Coils **1–16** are the Z80's two driver latches (F17); coils
**17–21** and the three flash lamps sit on driver expansion board 011-033A,
addressed on its own connector as channels TA/TB/TC 1–8 (§7.2.4.1), and **no
Z80 port drives any of them** — every `OUT` in the Z80 ROM resolves to eight
ports whose every bit is already accounted for (F17).

| Coil | §2.3.1 name | Drive | Role in the rules |
|---|---|---|---|
| 1 / 2 | Flipper izquierdo fuerza / mantenimiento | `$85` b0/b1 | left flipper, power + hold |
| 3 / 4 | Flipper derecho fuerza / mantenimiento | `$85` b2/b3 | right flipper |
| 5 / 6 | Flipper superior fuerza / mantenimiento | `$85` b4/b5 | upper flipper |
| 7 | Bumper 1 | `$85` b6 | |
| 8 | Tragabolas 1 | `$85` b7 | scoop 1 kick-out |
| 9–12 | Bumper 2–5 | `$86` b0–b3 | |
| 13 | Taca | `$86` b4 | fires before coil 8 on a scoop-1 entry (F17) |
| 14 / 15 | Expulsor 1 / 2 | `$86` b5/b6 | left / right shooter |
| 16 | Sueltabolas de Júpiter | `$86` b7 | the Jupiter ball release |
| 17 | Salida de bolas | expansion TA/TB/TC 1 | trough kicker |
| 18 | Bancada de dianas | expansion 5 | **the drop-bank reset** |
| 19 | Diverter de Rampa | expansion 2 | Ramp 1's diverter (Lagrange) |
| 20 | Black Hole Power | expansion 6 | **marked *no conectada*** |
| 21 | Diverter de Júpiter | expansion 3 | |

Ball recovery uses coils 7, 9, 10, 11, 12, 8, 14 and 15, in that order, and
**skips 13 and 16** (F17 addendum) — the search shakes the bumpers, scoop 1 and
both shooters, and neither *Taca* nor the Jupiter release takes part.

---

## Starting a ball

**At ball start three lane lights are on** (§3.1):

| Light | Lamp | Meaning |
|---|---|---|
| LP2 | LC15 | Lane 2 is lit — Orbits ×2 available |
| LP3 | LC16 | Lane 3 is lit — Autodrop available |
| LP4 | LC18 | Lane 4 is lit — Orbits spelling available |

Everything else starts dark. Notably **neither Special lane is lit**: LP1 (lane
1) and LP5 (lane 5) are off until the Monolith's LPA5 award lights one of them
(§3.3.8), after which the two shooters move it from side to side (§3.3.4).

The **drop-target bank starts fully reset** — see
[the bank](#the-drop-target-bank--bancada), which is the one place where the
reset's timing changes how a mode plays.

---

## The lanes — *Pasillos*

All of §3.3.1. Every lane scores **100,000** unlit. Lit, each does its own thing.

| Lane | C# / code | Lit | Unlit |
|---|---|---|---|
| 1 | C12 `0x19` | **Special** | 100,000 |
| 2 | C13 `0x18` | lights LR11 (Orbits ×2 on Ramp 1) | 100,000 |
| 3 | C14 `0x17` | lights LP11 (Autodrop at lane 11) | 100,000 |
| 4 | C17 `0x0F` | lights LD1 (Orbits spelling at bull's-eye 1) | 100,000 |
| 5 | C18 `0x0E` | **Special** | 100,000 |
| 6 | C24 `0x1A` | lights LTB11 **and** LTB2 (Monolith message at both scoops); 100,000 unless the ball arrives from a **Skill Orbit** — see below | |
| 7 | C41 `0x37` | **Special** | 100,000 |
| 8 | C42 `0x36` | **Extra Ball** | 100,000 |
| 9 | C43 `0x35` | **Bonus ×10** | 100,000 |
| 10 | C48 `0x2F` | *with* all six ORBITS lights: **5,000,000** first time, **3,000,000** after | *without* them: **2,000,000** first time, **1,000,000** after |
| 11 | C22 `0x12` | **Autodrop** | **Drop Shuttle** |
| Jupiter entry | C50 `0x31` | lights LTB11 **and** LTB2 (Monolith message at both scoops) | |

Three points the table cannot carry:

- **Lane 6 and the Jupiter entry are the Monolith's only arming shots.** Each
  lights *both* scoop lamps at once, so either scoop can then cash the Monolith
  message. That is why §3.3.8 lists "LTB11 or LTB2" at both scoops rather than
  one lamp each — the pair is lit and cleared together.
- **A "Skill Orbit" is lane 6 taken straight from lane 10.** §3.3.1 withholds
  lane 6's 100,000 when the ball "comes from a Skill Orbit" without defining the
  term anywhere in the manual; the firmware defines it. Lane 10's handler sets
  the flag `[4134:0029]` as its first action (`D8799`), and lane 6's handler
  (`sub_D8590`) is the only reader: with the flag clear it adds 100,000
  (`D85BC`), and with it set it scores nothing and clears the flag (`D85E1`). So
  running the orbit and continuing into lane 6 arms the Monolith without the
  lane's own 100,000 — one flag, set in exactly one place and consumed in
  exactly one place.
- **Lane 10's two columns are the other way round in the manual.** §3.3.1
  prints 2,000,000 / 1,000,000 under *Con Luces Orbita* and 5,000,000 /
  3,000,000 under *Sin Luces Orbita*. The firmware pays the **larger** award
  with the lights **lit**, and the table above follows the firmware. Lane 10's
  handler is `sub_D878B`, reached from the in-play switch dispatcher `sub_D7636`
  through its jump table (code `0x2F` → index `0x21`), and it has exactly four
  score paths, each adding a 32-bit constant to the score at `413C:00F0`/`00F2`:

  | Condition | Address | Constant | Award |
  |---|---|---|---|
  | ORBITS complete, first time | `D87BA` | `0x004C4B40` | 5,000,000 |
  | ORBITS complete, thereafter | `D886E` | `0x002DC6C0` | 3,000,000 |
  | ORBITS incomplete, first time | `D880C` | `0x001E8480` | 2,000,000 |
  | ORBITS incomplete, thereafter | `D88B9` | `0x000F4240` | 1,000,000 |

  The "complete" test is `CMP ES:[0102], 6`, and the first-time axis is the
  sticky flag `[4134:002C]`, which `sub_D878B` sets on its first pass.
  **`[413C:0102]` is the count of lit ORBITS letters**, 0–6: bull's-eye 1's
  handler increments it, hard-capped at 6 (`D8C0D`/`D8C17`), which is §3.3.5's
  "lights one ORBITS letter"; and the Monolith stepper `sub_D95B0` skips
  position 2 unless it has reached 6 (`D95DA`), which is §3.3.3's "LPA3 only
  while the ORBITS lights are lit". Six letters, a cap of six, and both gates —
  so neither the meaning of the test nor the direction of lane 10 is in doubt.
- **"Autodrop" and "Drop Shuttle" are undefined.** Both appear in the manual
  **only** in this table and nowhere else. See [Open](#open-questions).

---

## The ramps — *Rampas* (§3.3.2)

### Ramp 1 — the orbit counter

Ramp 1 is how orbits are banked, and how the two Lagrange lights show
themselves.

| Condition | Effect |
|---|---|
| LR11 lit (Orbits ×2) | the run counts **2 orbits** |
| LR11 unlit | the run counts **1 orbit** |
| the orbit maximum is reached | lights **LR22** — Extra Ball at Ramp 2 |
| LPA11 lit (Lagrange Scape) | **the ramp diverter fires** (coil 19) |
| LPA12 lit (Lagrange Orbit) | the diverter does **not** fire |
| LR12 lit (Orbit Flip running) | lights **LBH** (Black Hole Power), and lights one of LP7 (Special), LP8 (Extra Ball) or LP9 (Bonus ×10) **at random** |

The orbit maximum is the **ORBITAS** adjustable, factory **10** (§5.9).

LPA11 and LPA12 are the Monolith's two Lagrange positions; the shooters
alternate between them (§3.3.4), so which one is lit — and therefore whether the
diverter sends the ball a different way — is set at the shooters, not on the
ramp.

Ramp 1 is sensed at its entrance (C40) and its middle (C49) only; its exit
contact C21 does not exist.

### Ramp 2 — the payout ramp

Ramp 2 pays whatever its lit lamp says. It has three.

| Lit lamp | Award |
|---|---|
| LR22 (LC53, Extra Ball) | **Extra Ball** |
| LBH (LC60, Black Hole Power), **without** Wonderful Thing | lights one of the **upper lanes'** lights — LP7 (Special), LP8 (Extra Ball) or LP9 (Bonus ×10) |
| LBH, **with** Wonderful Thing running | lights lane 8's Extra Ball lamp (LP8) and releases the Jupiter balls slowly, one after another |
| LR21 (LC56, Superjackpot) **and** Multiball running | **Superjackpot** — double the Jackpot value |

Superjackpot requires both the lamp and Multiball: LR21 is lit when Multiball
starts and goes out when it ends (§3.2.1). **Measured at 80,000,000** — exactly
double the factory Jackpot, as §3.3.2 says — and one-shot the same way: a second
run of Ramp 2 pays only its ordinary 11,111
([`../dmd/jackpot/`](../dmd/jackpot/)).

§3.3.2 says only "one of the upper lanes' lights" for the non-Wonderful-Thing
case, but the manual identifies which three elsewhere: §3.2.4 calls LP7, LP8 and
LP9 "the lights of [Black Hole Power's] **associated contacts**", and F18 places
LC57–LC60 — LP7, LP8, LP9 and LBH itself — at four consecutive lamp-matrix
positions (column 5 bits 4–7). The upper lanes are therefore 7, 8 and 9, and
Black Hole Power's effect is to light one of their three awards.

What remains open is the **device**: the coil named *Black Hole Power* (20) is
marked *no conectada* in both §2.3.1 and §7.2.4.1, so whatever physical
mechanism the name refers to is not fitted on this machine and the award reaches
the player only through those lamps. See [Open](#open-questions).

---

## The Monolith (§3.3.3, §3.3.8)

The Monolith is a twelve-lamp display, and it works in two halves.

**The bumpers cycle it.** Every bumper hit steps the lit Monolith message one
position along LPA1…LPA10, and pays for itself:

| Bumper hit | Score |
|---|---|
| lit | 20,001 |
| unlit | 10,001 |

**The shooters toggle the other two.** The two *Expulsores* alternate LPA11
(Lagrange Scape) and LPA12 (Lagrange Orbit) — the pair that controls Ramp 1's
diverter (§3.3.4). They are not part of the ten-position cycle and are never an
award.

**The scoops cash it.** With LTB11 or LTB2 lit — armed at lane 6 or the Jupiter
entry — entering either scoop collects whatever the Monolith currently shows:

| Position | Lamp | What the position **is** (§3.3.3) | What cashing it **awards** (§3.3.8) |
|---|---|---|---|
| LPA1 | LC2 | Extra Ball | **Extra Ball** |
| LPA2 | LC3 | 3,000,000 | **3,000,000** |
| LPA3 | LC4 | Little Multiball available — *only while the ORBITS lights are lit* | the award is given **at Jupiter**, not at the scoop |
| LPA4 | LC5 | 6,000,000 | **6,000,000** |
| LPA5 | LC6 | Special at lane 1 or 5 | lights **LP5** (lane 5) if LPA11 (Lagrange Scape) is lit; lights **LP1** (lane 1) if LPA12 (Lagrange Orbit) is lit |
| LPA6 | LC7 | 9,000,000 | **9,000,000** |
| LPA7 | LC8 | Impact Count | **starts Impact Count** |
| LPA8 | LC9 | Orbit Flip | **starts Orbit Flip** |
| LPA9 | LC10 | Special Drop Target | **starts Special Drop Target** |
| LPA10 | LC11 | Star Ride | **starts Star Ride** |

So the Monolith is the machine's mode selector: five of its ten positions are
straight awards, four start a timed mode, and one (LPA3) is not collected at the
scoop at all — it arms Little Multiball for the next ball held at Jupiter.

**LPA5's award depends on the Lagrange pair**, which the shooters control. Since
the shooters also swap LP1 and LP5 directly (§3.3.4), a lit Special can be moved
to whichever lane the player can actually hit.

---

## The shooters — *Expulsores* (§3.3.4)

Each shooter does three things:

1. **adds bonus**;
2. alternates the Monolith's LPA11 / LPA12 pair (Lagrange Scape / Lagrange
   Orbit);
3. moves a lit Special across the playfield —
   - the **left** shooter: if LP5 (lane 5) is lit, it turns LP5 off and LP1
     (lane 1) on;
   - the **right** shooter: if LP1 is lit, it turns LP1 off and LP5 on.

The left shooter is C15 / coil 14 (*Expulsor 1*), the right is C16 / coil 15
(*Expulsor 2*).

---

## The bull's-eyes — *Dianas* 1 and 2 (§3.3.5)

Both score **50,001**, or **100,000** each while Special Drop Target is running.

**Bull's-eye 1 (C32)** lights the Monolith's bumper lamps, and the ORBITS
letters when armed:

| Condition | Effect |
|---|---|
| LD1 unlit | lights one bumper lamp |
| LD1 lit (Orbits spelling armed at lane 4) | lights one bumper lamp **and** one ORBITS letter |

**Bull's-eye 2 (C38)** is the Jackpot target, and the second route to the Extra
Ball on Ramp 2:

| Condition | Effect |
|---|---|
| LD2 unlit | increments the *dianas* count; at the maximum, lights **LR22** (Extra Ball at Ramp 2) |
| LD2 lit (Jackpot — lit for Multiball) | pays the **Jackpot** value set in the adjustments |

The *dianas* maximum is the **DIANAS** adjustable, factory **10** (§5.10); the
Jackpot value is **JPOT**, factory **40,000,000** (§5.13). LD2 is lit when
Multiball starts and goes out when it ends (§3.2.1), so the Jackpot is a
Multiball award.

**Measured, from the firmware's own score accumulator** (`413C:00F0`/`00F2`,
[`../dmd/jackpot/`](../dmd/jackpot/)): collecting it adds **40,050,001** — the
factory `JPOT` **on top of** bull's-eye 2's own 50,001, not instead of it — and
it is **one-shot**: a second hit inside the same Multiball pays the bare 50,001,
so LD2 is cleared as the award is taken rather than when the mode ends.

---

## The drop-target bank — *Bancada*

Five drop targets A–E (C25–C29) plus the inner target *Fondo Bancada* (C30), all
of §3.3.6. Every target pays **100,000** while Special Drop Target is running.

**Progressive awards as the bank goes down:**

| Targets down | Award |
|---|---|
| 2 | lights **LP9** (Bonus ×10 at lane 9) |
| 4 | lights **LP7** (Special at lane 7) and turns **LP9 off** |
| 5 | lights **LP8** (Extra Ball at lane 8) and turns **LP7 off** |

Each step **replaces** the previous one — the three lane lights are not
cumulative, they hand off. Clearing the whole bank leaves only LP8, the Extra
Ball at lane 8.

**The inner target** (*Fondo Bancada*, C30) pays 50,001, or 100,000 during
Special Drop Target. With **all five targets already down**, hitting it starts
**Special Drop Probe**: LP7, LP8 and LP9 all light for 10 seconds, and when the
time runs out only LP8 (Extra Ball) is left lit.

> **The bank resets only at ball start.** Its reset coil is 18 (*Bancada de
> dianas*), on driver expansion board 011-033A, and **no Z80 port drives it**
> (F17) — the ROM baseline shows nothing about what paces it, and §3.3.6 does
> not say. On the machine the bank comes back up at ball start and not again
> during the ball. The consequence is a real rule: **a drop-dependent award
> started with targets already down cannot be completed in that ball.** Special
> Drop Target's 15 seconds pay 100,000 per target, so it is worth little with
> the bank already flat; Special Drop Probe needs five standing targets to knock
> down in the first place. Order matters — clear the bank *after* the Monolith
> hands you the mode, not before. What would settle the mechanism is now a scope
> on the 011-033A connector, and nothing else: neither CPU can address the
> expansion board. IC7 drives nothing off the 16-bit board
> ([`../roms/PAL20L10/`](../roms/PAL20L10/)), and the Z80's output decoder wires
> exactly eight strobes for ports `0x80`-`0x87` with none to spare (sheet
> `011-030-02`).

The bank has its own six lamps, LC30–LC35 (bank A, B, inner, D, E, C — in that
matrix order, F18); §2.2.2 does not give them `L`-names and the rules text does
not refer to them.

---

## Jupiter (§3.3.7)

Jupiter is the ball lock, and the gate to all three multiball modes. It is
sensed by three contacts, C44/C45/C46 (codes `0x2A`–`0x2C`), which is how the
80188 counts how many balls it holds; the entry lane is C50.

> **Nothing is held unless the ORBITS lights are all lit.** §3.3.7 is explicit:
> without the full ORBITS spelling, Jupiter does not retain balls at all — the
> ball simply passes through. Completing ORBITS at bull's-eye 1 (with LD1 lit
> from lane 4) is the prerequisite for the entire branch below.

With ORBITS complete, each ball entered is **held**, up to **two**, and a
replacement ball is served each time. What happens next depends on how many are
held and on the state of the drop bank:

| Held | Bank | Result |
|---|---|---|
| 1 | — | if **LPA3** is lit, the Little Multiball lamp **LTB12** lights at scoop 1 |
| 2 | five targets **down** | **Wonderful Thing** |
| 2 | targets **not** down | **Multiball** |

So the drop bank is the switch between the two two-ball-lock modes: clear it
before locking the second ball for Wonderful Thing, leave it standing for
Multiball.

The release coil is 16 (*Sueltabolas de Júpiter*); the Jupiter diverter is coil
21, on the expansion board. Whether coil 16 fires in normal play is
[open](#open-questions).

---

## The scoops — *Tragabolas* (§3.3.8)

Both scoops **count the bonus down** (*Descuento de Bonos*) and score
**150,000**.

| Scoop | Base | With Star Ride | With LTB11 / LTB2 lit | With LTB12 lit |
|---|---|---|---|---|
| Scoop 1 (C23) | 150,000 | **10,000,000** | cashes the Monolith message | starts **Little Multiball** |
| Scoop 2 (C31) | 150,000 | **15,000,000** | cashes the Monolith message | — |

Scoop 2 pays half again as much as scoop 1 during Star Ride — 15,000,000
against 10,000,000 — which makes the scoop with no kick-out coil the better
shot while the mode runs.

Scoop 1 is kicked out by coil 13 (*Taca*) then coil 8; scoop 2 has no coil
(F17 addendum).

> The manual labels both scoops *Descuento de Bonos* — the bonus is counted down
> and paid there — but never says what that adds to the score, and never names an
> end-of-ball bonus collect either. The dword at `413C:00F0`/`00F2` is the
> **player's score**, not the bonus: bull's-eye 1's handler adds `0xC351` =
> 50,001 to it, which is §3.3.5's own stated value for that target, and lane 6
> adds 100,000 to it, which is §3.3.1's. See [Open](#open-questions).

---

## The three multiball modes

All three need the ORBITS spelling complete, because all three start at Jupiter.

### How the firmware counts a lock

The three Jupiter contacts are a counted device, and only **C46** reports: the
Z80 sends no code at all for C44 and C45, and sends the remapped code **`0x44`**
for C46 rather than its own `0x2C` — the same treatment the trough's entry
contact gets, where C6 reports `0x43` instead of `0x0A`. Measured by pulsing
every bit of Z80 column 4 in turn: bits 3-7 give `0x2D`-`0x31`, bits 0 and 1
give nothing, bit 2 gives `0x44`.

`0x44` is what the game acts on. The in-game dispatcher at `D7661` indexes the
jump table at `CS:0527` by `code − 0x0E`, and entry 54 reaches **`sub_D9D04`**:

| | |
|---|---|
| `D9D0A` | gate on `[4134:0022]`; non-zero takes the pass-through branch (`INC [4134:0026]`, sound `0x0A`, Z80 command `0xEE`) |
| `D9D29` | **`INC [4134:0030]`** — the lock counter |
| `D9D31` | count 1 → `D9D41`: sound `0x14`, `fm_song_select(0)` then `(3)`, and the DMD text at `F000:1F02` / `F000:1FAC` through `sub_DAAAF` |
| `D9D36` | count 2 → **`D9DBD`**, the Multiball path |

Codes `0x2A`-`0x2C` reach dispatcher entries 28-30, all of which are the
do-nothing default at `0x0523`, so the other two contacts carry no game logic.

The device count `[413C:00F8]` is a different thing and is **not** how a lock is
registered: it is filled by `sub_DC194` from command `0xEB`'s reply, and `0xEB`
is issued from exactly two sites (`DC4D4`, `DC547`), both ball-serve paths. It
is inventory — how many balls are accounted for at a serve, read at `DC4F1` and
`DC564` to decide whether a ball search is needed, and at `DC2DA` where
`sub_DC2A6` calls `sub_D92C0` once per held ball.

The Jupiter *entrance* contact C50 (`0x31`) is not part of the lock: its handler
`sub_D9CCE` adds 100,000 to the score and plays OKI phrase `0x17`, and nothing
else.

Screens for the first lock and for Multiball starting are captured in
[`../dmd/multiball/`](../dmd/multiball/).

### Multiball (§3.2.1, §3.3.7)

**Starts** when the **second** ball is locked in Jupiter **and the five bank
targets are not down**.

1. A further ball is served.
2. **LD2** (Jackpot, at bull's-eye 2) and **LR21** (Superjackpot, at Ramp 2)
   light.
3. As soon as that served ball hits any contact, **both Jupiter balls are
   released** — three balls in play.

**Ends** when only one ball is left. LD2 and LR21 go out, so the Jackpot and
Superjackpot are Multiball-only awards.

### Wonderful Thing (§3.2.2)

**Starts** when the **second** ball is locked in Jupiter **and all five bank
targets are down**.

1. **LBH** (Black Hole Power) lights.
2. A further ball is served.
3. If that ball runs **Ramp 2**, lane 8's Extra Ball lamp (**LP8**) lights and
   the remaining balls are released **slowly, one after another**.

The manual gives Wonderful Thing no end condition of its own — it names one only
for Multiball (§3.2.1). Its distinguishing awards are the extra ball at lane 8
and the staged, rather than simultaneous, ball release.

### Little Multiball (§3.2.6, §3.3.7, §3.3.8)

**Starts** from **one** ball locked in Jupiter with **LPA3** lit on the Monolith
— and LPA3 itself is only meaningful while the ORBITS lights are on (§3.3.3).

1. **LTB12** (Little Multiball) lights at scoop 1.
2. A ball is served so play continues.
3. Putting that ball into **scoop 1** releases the Jupiter ball — **two balls in
   play**.

§3.3.8 describes the same sequence from the scoop's end and adds that the
release happens once the new ball hits a contact, releasing everything held in
Jupiter and in the scoop — the same delayed release Multiball uses. The two
passages agree on the outcome (two balls) and differ only in where they start
counting.

---

## The timed modes

Four of them are started from the Monolith by a scoop; the fifth comes from the
drop bank.

| Mode | Started by | Duration | What it does |
|---|---|---|---|
| **Impact Count** (§3.2.3) | Monolith LPA7 | 15 s | counts bumper hits; reaching the impact count (**20 hits**) pays **5,000,000** |
| **Orbit Flip** (§3.2.4) | Monolith LPA8 | 15 s | lights **LR12** on Ramp 1; running Ramp 1 lights **LBH** plus one of LP7 / LP8 / LP9 at random. Running **Ramp 2** inside the 15 s can drop the ball into one of the lanes at random. Everything lit is switched off when the time expires. |
| **Special Drop Target** (§3.2.5) | Monolith LPA9 | 15 s | every *diana* — both bull's-eyes, all five bank targets and the inner target — pays **100,000** instead of its usual value |
| **Star Ride** (§3.2.8) | Monolith LPA10 | 15 s | scoop 1 pays **10,000,000**, scoop 2 pays **15,000,000** |
| **Special Drop Probe** (§3.2.7, §3.3.6) | the inner bank target with all five targets already down | **10 s** | LP7 (Special), LP8 (Extra Ball) and LP9 (Bonus ×10) all light; when the time expires **only LP8 stays lit** |

Special Drop Probe is the one mode at 10 seconds rather than 15; §3.2.7 and
§3.3.6 state it independently and agree.

**Three of these are confirmed against the firmware's own state**, captured in
[`../dmd/modes/`](../dmd/modes/) and [`../dmd/monolith/`](../dmd/monolith/):

- **Special Drop Probe** lights `LP7`, `LP8` and `LP9` together — lamp column 5
  bits 4-6 (F18) — after the inner target with the bank already flat, and the
  bank cleared on its own leaves `LP8` alone beforehand, exactly as §3.3.6 says.
- **Wonderful Thing's staged release is visible in the lock counter.**
  `[4134:0030]` goes 1 → 2 as the two balls are locked with the bank down, then
  comes back down **2 → 1 → 0 in two separate steps** rather than at once —
  §3.2.2's "released slowly, one after another", against Multiball's
  simultaneous release.
- **The Monolith chases rather than resting.** Its cycle lamps (column 3 bits
  0-7, column 4 bits 0-1) run continuously, so what a scoop cashes is whichever
  position is lit at that instant; `LPA11`/`LPA12` sit on column 4 bits 2-3 and
  are lit independently of the cycle.

**Special Drop Target is worth the least with the bank already flat**, because
five of its seven eligible targets are drop targets that do not come back up
during the ball — see [the bank](#the-drop-target-bank--bancada).

---

## Extra balls — *Bolas Extra* (§3.2.9)

**Four routes**, and the machine audits exactly these four (§5.15.5, §5.15.6 —
the counters are BE.SCORE, BE.PAS.8, BE.TRAGAB. and BE.RAMPA2, under a BE.TOTAL):

| Route | How |
|---|---|
| **Lane 8** | run lane 8 (C42) with **LP8** lit. LP8 is lit by clearing all five bank targets, by Special Drop Probe (and it is the one light left when that mode expires), at random by Orbit Flip, or by Ramp 2 during Wonderful Thing |
| **A scoop** | cash Monolith position **LPA1** (Extra Ball) at either scoop with LTB11 / LTB2 lit |
| **Ramp 2** | run Ramp 2 with **LR22** lit. LR22 lights on reaching the **orbit** maximum at Ramp 1, or the **dianas** maximum at bull's-eye 2 |
| **Score** | reach the extra-ball score threshold (§5.11) |

Two adjustments cap this (§5.11): **BOLAS EXTRA N.** limits extra balls per ball
(factory **3**), and **B.EX EN B.EX** decides whether an extra ball can itself
earn another (factory **NO**).

A tilt forfeits any extra ball earned on that ball (§3.3.9).

---

## Specials — *Especiales* (§3.2.10)

**Three routes**, all lanes:

| Route | How the light gets lit |
|---|---|
| **Lane 1** (LP1, LC14) | Monolith **LPA5** cashed while **LPA12** (Lagrange Orbit) is lit; or the **left** shooter moving a lit LP5 across |
| **Lane 5** (LP5, LC19) | Monolith **LPA5** cashed while **LPA11** (Lagrange Scape) is lit; or the **right** shooter moving a lit LP1 across |
| **Lane 7** (LP7, LC57) | **4** bank targets down; or Orbit Flip's random pick; or Special Drop Probe's 10 s |

Note that lane 7's light is **taken away again** by the fifth bank target
(§3.3.6) and by Special Drop Probe expiring (§3.2.7) — both replace LP7 with
LP8. A Special at lane 7 has to be collected before the next target falls.

**ESPECIALES** (§5.13) caps how many Specials a player can take from contacts in
one game, factory **3**.

The manual does not say what a Special pays. §5.13 groups it with the Jackpot
under *PREMIOS* (awards) and caps it per game the way a credit award would be
capped; §5.14 and §3.5 both use *partida* for a free game. See
[Open](#open-questions).

---

## Bonus — *Bonos*

The bonus ladder is §2.2.2's *Bono 1*…*Bono 10* — lamps LC20–LC23 and
LC26–LC29, with the 5th and 6th positions unpopulated.

| Action | Effect on the bonus |
|---|---|
| either shooter (*Expulsor*) | **adds** bonus (§3.3.4) |
| lane 9 with **LP9** lit | **Bonus ×10** (§3.3.1) |
| either scoop | **counts the bonus down** — *Descuento de Bonos* (§3.3.8) |
| tilt | the bonus obtained on that ball is **lost** (§3.3.9) |

LP9 is lit by two bank targets down, by Orbit Flip's random pick, or by Special
Drop Probe; the fourth bank target takes it away again (§3.3.6).

§3.3.9's statement that a tilt loses the bonus implies the bonus is otherwise
paid, but the manual never names an end-of-ball bonus collect, and what the
scoops' *descuento* does to the score is not spelled out. See
[Open](#open-questions).

---

## Tilt — *Falta* (§3.3.9)

A plumb-bob tilt (C20, code `0x3E`) guards against shaking or lifting the
cabinet.

The number of *faltas* allowed is programmable (§5.16.12), and the count is the
number of tilts **including** the fatal one:

| FALTAS | Behaviour |
|---|---|
| 1 (factory) | the first tilt is fatal — no warning |
| 2 | one warning, then the second tilt is fatal |
| 3 | two warnings, then the third is fatal |

Each non-fatal tilt puts a warning on the display. When the count is reached:

- the **playfield lights go out**;
- the ball **stops scoring** for the rest of its time on the playfield;
- once it reaches the outhole, play moves to the next ball if there is one;
- the **bonus** accumulated on that ball is **lost**;
- any **extra balls** earned on that ball are **lost**.

The tilt ends the ball's scoring only — the game continues with the player's
remaining balls.

---

## End of game

### The lottery — *Lotería* (§3.5)

When the game is over a lottery screen appears with a number. If that number
matches the **units digit** of any player's score, that player gets a free game.
§3.5 puts this at roughly **20%** of games.

Worth knowing as a player: of every award the rules list, only the **bumpers**
(10,001 / 20,001) and the **bull's-eyes and inner target** (50,001) have a
non-zero units digit — every other value ends in 0. The digit a player finishes
on is therefore decided by how many of those they took, and Special Drop Target
suspends even that by paying the *dianas* a flat 100,000 for its 15 seconds.
This is arithmetic on the manual's own numbers, not a rule the manual states —
but the firmware agrees with it, and the bonus does not disturb it.

**How the firmware does it.** `sub_D4CF4` (`D4CF4`) runs once per game, from the
end-of-ball state machine's own game-over dispatch (`sub_D3145`, its call into
`sub_D46F8` at `D3237`). It divides the player's own score-digit cell
`413C:0016` by 10 and compares the remainder, at `D4DCB`, against work RAM
`4000:113F` — the number the lottery screen draws, and **the same number the
panel shows as a full-panel digit** under the final score. On equality
`sub_D4FDC` banks a credit and runs the SPECIAL animation. The counter is
incremented once per delivered timer-0 tick and by nothing else (`D030E`,
`D0315`, F3), so nothing a player does steers it. It is not a clock, though:
a tick that comes due while the firmware has interrupts masked is lost, so the
number drawn is not a function of how long the machine has been on either
(`dmd/special/README.md`).

Two things this settles about the paragraph above. The bonus, whatever the
manual leaves out about its values, **ends in zero**: across games whose only
non-zero-digit awards were inner-target hits, `413C:0016` at the compare read
exactly the number of those hits, so nothing else contributed to the units
digit. And the cell holds that digit **unreduced** — it reads 10, 11 or 12
after that many such hits — which is why the firmware divides rather than
compares. Measured win rate over 104 complete games driven to known
digits: 11.5%, against §3.5's own "roughly 20%"; the mechanism itself implies
10%. `dmd/special/README.md` has the measurements and what drove them.

### High scores — *Records* (§4.1, §4.2)

Beating any of the stored high scores invites the player to enter a name of up
to **six** characters (§4.1). The table holds **five** records — five 17-byte
records in the non-volatile store at offsets `0x85`, `0x96`, `0xA7`, `0xB8` and
`0xC9`, each a score dword followed by the name bytes (F10). The entry screen
names the **player** being invited, `1`, `2`, `3` or `4`, so a four-player game
can queue several entries one after another (§4.2).

**The character set**, in the order the selector walks it (§4.2):

1. blank space
2. `A`–`Z`, **with `Ñ` between `N` and `O`** — 27 letters, matching the firmware's
   own glyph table exactly: F16 gives it as `0x0B`–`0x25` for A–Z with `Ñ` at
   `0x19`, which is 27 codes with `Ñ` sitting between `N` (`0x18`) and `O`
   (`0x1A`)
3. punctuation and symbols
4. `0`–`9`
5. **`<-`** — the erase symbol

**Entry procedure** (§4.2):

| Control | Action |
|---|---|
| **left flipper** | move **backwards** through the character table |
| **right flipper** | move **forwards** through the character table |
| **START** | fix the character currently shown |
| **START on `<-`** | erase the previous character; pressing START again erases the one before that, and so on |

There is a **10-second** timer per character. If nothing is entered for 10
seconds, whatever has been typed so far is stored with the score. Entry also
finishes as soon as six characters are fixed, after which the next qualifying
player is invited.

§4.1's list of allowed characters — letters, numbers, symbols — is looser than
§4.2's enumerated table; §4.2's table is the one the machine walks. The exact
punctuation set is [not recoverable from the scan](#ocr-and-the-rules-section).

---

## The adjustables that change the rules (SECCION 5)

Reached with the TEST button (code `0x3F`) and navigated with the flippers and
START — see
[`iomoon_language_and_service_menu.md`](iomoon_language_and_service_menu.md) for
the menu tree and
[`switch_lamp_solenoid.md`](switch_lamp_solenoid.md) for the codes.

| Setting | Menu path (§) | Factory | What it changes above |
|---|---|---|---|
| **PUNT. MINIMA** | §5.6 | **100,000** | the minimum a ball must score to avoid a *salida nula* — a ball at or below it is replayed |
| **NUM. BOLAS** | §5.8 | **3** | balls per player per game |
| **ORBITAS** | §5.9 | **10** | orbits needed at Ramp 1 to light LR22 (Extra Ball at Ramp 2) |
| **DIANAS** | §5.10 | **10** | bull's-eye-2 hits needed to light LR22 |
| **BOLAS EXTRA N.** | §5.11 | **3** | maximum extra balls per ball |
| **B.EX EN B.EX** | §5.11 | **NO** | whether an extra ball can earn another extra ball |
| **PUNT.** (extra ball) | §5.11 | **400,000,000** as printed | the score at which an extra ball is awarded |
| **ESPECIALES** | §5.13 | **3** | maximum Specials per game from contacts |
| **JPOT** | §5.13 | **40,000,000** | the Jackpot value at bull's-eye 2; Superjackpot is double |
| **PARTIDA GRATIS** | §5.14 | **6,000,000** and **8,000,000** | the two replay score levels |
| **FALTAS** | §5.16.12 | **1** | tilts allowed, the fatal one included |

Remember that **ORBITAS** and **DIANAS** both light the *same* lamp, LR22 — the
two are alternative routes to one extra ball at Ramp 2, not two separate awards.

**The extra-ball score threshold as printed is suspect.** §5.11 shows
`PUNT.:400000000` — 400,000,000, nine digits, against a 999,999,999 score
ceiling (§3.4) and a Jackpot of 40,000,000 (eight digits) on the adjacent
screen. It is recorded as printed and flagged as [open](#open-questions).

The country/language DIP (SW40-2/3/4) sets coinage and the display language, not
play; §5.16.11 sets the electronic coin mechanism's credit values. Both are
covered in
[`iomoon_language_and_service_menu.md`](iomoon_language_and_service_menu.md).

---

## Where the ROM and the manual disagree

The ROM is what runs. The first three differences are naming and change no rule;
the fourth changes a rule, and the page follows the firmware.

| Item | Manual | ROM (F16) |
|---|---|---|
| C10 / C11 | C10 left flipper cut-out, C11 right (§2.1.1) | C10 R.C.FLIPPER, C11 L.C.FLIPPER |
| C44 / C45 / C46 | *Planeta 1 / 2 / 3* (§2.1.1) | JUPITER 1 / 2 / 3, in both languages — the Jupiter lock of §3.3.7 |
| C21 | *Sin conectar* (§2.1.1) | named RAMP 1 EXIT, dispatcher a bare `RET` — both agree it does nothing |
| **Lane 10's award** | 2,000,000 / 1,000,000 *with* the ORBITS lights and 5,000,000 / 3,000,000 *without* (§3.3.1) | the other way round — the larger award is paid **with** the lights lit (`sub_D878B`) |

**The fourth is about substance, and the page follows the ROM.** §3.3.1's two
lane-10 columns are swapped relative to the firmware, which pays 5,000,000 /
3,000,000 with the ORBITS lights lit. Each of the manual's two cells carries its
own *Con Luces Orbita* / *Sin Luces Orbita* label beside its own pair of values,
and both OCR passes bind label to values identically, so the error is in the
printed table rather than introduced by the scan — a column swap during scanning
would have had to exchange the two labels while leaving the values in place. See
[the lanes](#the-lanes--pasillos) for the four score paths.

---

## Open questions

Stated as open rather than guessed. Each line says what would settle it.

- **"Autodrop" and "Drop Shuttle"** — lane 11's lit and unlit awards. Neither is
  defined anywhere in the manual; both appear only in that one table row.
  *Autodrop* is at least named by its lamps (LP3 at lane 3 "lights Autodrop",
  LP11 at lane 11 "Autodrop") and the bank's reset coil 18 is the only candidate
  mechanism for dropping targets without shooting them, but the manual never
  connects the two. *Drop Shuttle* has no other occurrence at all. *Settled by:*
  lane 11's handler `sub_D890F`, reached from `sub_D7636`'s table at index `0x04`,
  or a real machine.
- **What the "Black Hole Power" device was meant to do** — the lamp-level effect
  is established (it lights one of LP7 / LP8 / LP9 at lanes 7–9, §3.3.2 with
  §3.2.4), but the coil of that name, 20, is marked *no conectada* in both
  §2.3.1 and §7.2.4.1, so the physical mechanism the name refers to is absent.
  Whether the firmware still drives its expansion-board channel is unknown,
  since no Z80 port reaches the expansion board at all (F17), and the Z80's
  output decoder has no spare strobe either. *Settled by:* a machine with the
  position populated.
- **What a Special pays** — §3.2.10 lists where Specials are available and §5.13
  caps them per game, but neither says what one gives. Elsewhere SLEIC uses
  *partida* for a free game (§3.5, §5.14). *Settled by:* the credit path in the
  80188 for the three lane codes, or a real machine.
- **What a Special pays** stays open above; **what makes Jupiter release a ball
  is not open.** **F22** settles it: `sub_07C3` clears bit 7 of the active-low
  port `$86`, and the play-time driver is command `0xEE`, issued by the
  Multiball start (`sub_DB716` → `sub_DC6AC`). Its handler `sub_2B86` keys on
  **C44** — the matrix is active low, so it returns at once when C44 is open
  and fires only with a ball resting there — and `sub_DC6AC` then waits for the
  released ball to report at a **scoop** (`0x21`/`0x22`), re-issuing `0xEE`
  every five seconds until it does. So the two CPUs use different Jupiter
  contacts: the 80188 counts a lock from C46, the Z80 releases from C44.
- **Little Multiball's own release is not reproduced** — §3.2.6 has scoop 1
  releasing the held ball for two balls in play, and that does not happen in
  emulation. It is not the Jupiter-rest problem F22 describes, which is fixed and
  which the Multiball release now demonstrably clears: re-tested with the ball
  resting on C44, a single lock with `LPA3` lit registers (`[4134:0030]` = 1), two
  scoop-1 collects register with `LTB12` armed, and coil 16 is never fired
  ([`../dmd/little-multiball/`](../dmd/little-multiball/)). *Settled by:* tracing
  scoop 1's handler `sub_D9B91` past its `D9C61` branch — which tests `[413C:010F]`
  and `[4134:0027]` before reaching `sub_DB503` — to find which gate is unmet.
- **What frees a ball sitting in scoop 2** — scoop 2 has no coil (F17 addendum),
  and the firmware's ball-recovery sweep does not treat *Taca* as a
  ball-freeing device either, yet §3.3.8 gives scoop 2 a full set of awards.
  *Settled by:* the playfield mechanism itself.
- **How the drop bank is reset, and by what** — coil 18 is on the expansion
  board and no Z80 port drives it (F17). The behaviour the rules depend on —
  reset at ball start and not again during the ball — is the machine's, not
  something either ROM shows. *Settled by:* a scope on the 011-033A connector at
  ball start; both PALs are dumped and neither reaches that board.
- **What the bonus is worth, and when it is paid** — §3.3.8 labels both scoops
  *Descuento de Bonos* without saying what the count-down adds to the score, and
  the manual names no end-of-ball bonus collect anywhere, though §3.3.9 says a
  tilt loses the bonus, which implies one exists. The score accumulator is
  `413C:00F0`/`00F2`; the bonus's own cell is not identified here.
  *Settled by:* tracing either scoop's handler — `sub_D9B91` for scoop 1,
  `sub_D9CAB` for scoop 2 — or a real machine.
- **Whether bumper 1 has a lit state** — §2.2.2 names lamps for bumpers 2–5 and
  none for bumper 1, and F18 places those four plus the unconnected LC42 at five
  consecutive matrix positions. If LC42 is bumper 1's unpopulated position then
  bumper 1 always pays the unlit 10,001. *Settled by:* the playfield, or the
  lamp-panel wiring.
- **The *Planeta* lamps** — LC61 (*Planeta 1*), LC62 (*Planeta 2*) and LC51
  (*Planeta 5*) are in §2.2.2 with no *Planeta 3* or *4* anywhere, and **no rule
  in SECCION 3 refers to any of them**. The two unconnected lamps immediately
  after LC61/LC62 in the matrix (LC63, LC64, column 5 bits 2–3, F18) sit where a
  *Planeta 3* and *4* would fall, but LC51 is in a different column, so the
  grouping does not carry through. *Settled by:* the playfield.
- **Wonderful Thing's end condition** — §3.2.1 gives Multiball an explicit end
  ("only one ball left", LD2 and LR21 out); §3.2.2 gives Wonderful Thing none.
  *Settled by:* the 80188's mode state machine, or a real machine.
- **The extra-ball score threshold** — §5.11 prints `PUNT.:400000000`
  (400,000,000) against a 999,999,999 ceiling and an adjacent eight-digit
  Jackpot. *Settled by:* the factory-default table in the ROM, or the machine's
  own screen.
- **The exact symbol set for high-score entry** — §4.2's punctuation line is
  destroyed in the scan. The letters and digits are recoverable; the
  punctuation is not. *Settled by:* the firmware's glyph table, or a clean scan.

The lamp matrix itself is **not** open: F18 measures all 64 positions from the
firmware's own lamp test and agrees with every legible cell of the manual's
figure 7-7.

---

## OCR and the rules section

The manual is scanned from paper and SECCION 3 is the worst-affected part of it.
What follows is what the scan does, so a reader can tell a transcription problem
from a machine behaviour.

**The PASILLOS table appears twice, and neither copy is wholly clean.** Row
labels are corrupted in both, in *different* places: the first copy mangles
`Pasillo9`, the second mangles `Pasillo5` and `Pasillo8`, and both mangle
`Pasillo1`. **The two copies agree on every award and every value in all twelve
rows** — the only other difference is `1ª vez` rendered `1a vez` in one and
`1* vez` in the other, both meaning "first time". The labels are recoverable
because the rows run 1–11 then *Paso Júpiter* in order, and each row's award
matches §2.2.2's name for that lane's own lamp. So the table above is not taken
from one copy or the other; it is the agreed content of both.

**§3.2.6–§3.2.10 appear twice, once truncated.** The first pass loses the middle
of §3.2.6 (Little Multiball) and the duration in §3.2.7 (Special Drop Probe) to
mid-sentence dropouts; its §3.2.8, §3.2.9 and §3.2.10 text is intact and
identical to the second pass. The second pass is clean and properly headed, and
its §3.2.6 is a strict superset of the truncated one — no content is lost and
the two do not disagree. This page uses the clean copy. Special Drop Probe's
**10 seconds** additionally comes from §3.3.6, an independent passage.

**Section numbering is inconsistent.** "3.3.- ACTUACIONES DE LOS CONTACTOS"
appears as a heading twice, once before each PASILLOS copy. "3.3.2.- RAMPAS"
survives only as a comment in the scan, so the ramps subsection has no visible
heading of its own. §3.3.9 (FALTA) and §5.10 (DIANAS) are body text rather than
headings. The section numbers used on this page are the manual's own, taken from
whichever copy carries them.

**Two characters are read from context.** §2.2.2's LC46 scans as *Deletrea "1"*
— read here as the letter **I**, because the six *Deletrea* lamps spell ORBITS
and F18 puts LC46 at the fourth of six consecutive matrix positions, which is
where the I falls. §4.2's entry prompt scans as `RECORD JUGADOR (1,2,3 64)` —
read as *(1,2,3 ó 4)*, the player number, `ó 4` having merged into `64`.

**Individual values that look wrong are checked or flagged, never quietly
adjusted.** Lane 10's lit-versus-unlit values read the wrong way round in the
manual and are **settled from the firmware** — the page prints the firmware's
direction and says where the manual differs. §5.11's `400000000` is not settled
and stays [recorded as open](#open-questions).

**Figure 7-7, the lamp-matrix diagram, is too damaged to transcribe** — merged
colour codes, dropped digits, coordinates out of registration. 30 of its 64
cells are individually legible and all 30 agree with F18's measured table
(F18), which is why this page cites F18 for matrix positions and never the
figure.

---

## Related documents

| Document | What it carries |
|---|---|
| [Switch, Lamp & Solenoid Tables](switch_lamp_solenoid.md) | the full contact, lamp and coil tables, the lamp matrix, and the codes that do not exist |
| [Language Model & Service-Menu Navigation](iomoon_language_and_service_menu.md) | how the menus above are opened and navigated, and the country DIP |
| [Game Software Architecture](game_software.md) | boot, the state machine, and the non-volatile store the adjustables live in |
| [DMD Graphics System](dmd_graphics.md) | how the display the rules are announced on is driven |
| [`findings.md`](../asm/baseline-2026-09/findings.md) | F16 the contact table, F17 the coils, F18 the lamp matrix |
