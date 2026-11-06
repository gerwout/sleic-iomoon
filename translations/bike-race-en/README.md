# Bike Race — English translation

An English version of the **Bike Race V4.1 free play + PRESS START** set
(PinMAME `bikerc3f`). Three chips change and the other four stay V4.1's:

| Chip | In | Out | What changes |
|---|---|---|---|
| 04 | `bk04f.bin` (`7626564e`) | `bk04e.bin` (`99006ab6`) | the 185 menu and message strings, YES/NO, the attract credit screen → Freeplay |
| 05 | `bkcpu05.bin` (`072ce879`) | `bk05e.bin` (`590aced9`) | 52 text screens and sprites, the staff-credits roll, the new Freeplay screen, 7 font strings |
| 06 | `bkcpu06.bin` (`9db436d4`) | `bk06e.bin` (`47f41c51`) | the two "UNO" frames → "ONE" |

The patch script writes the three chips, and the CRC32s above are what it produces.
The chips themselves, and a PinMAME set for them, stay out of this repository until
they have run on a real machine.

## Files

| File | What |
|---|---|
| `art/` | one PNG per replaced graphics record, named `BK<rom>_<index>_record_0x<offset>.png` after `scripts/sleic_dmd_viewer.py --index`, plus `BK05_Freeplay.png` and `BK05_roll_record_0x08276.png`, the 270-row staff-credits roll, which `--index` lists only with `--max-rows 300` |
| `strings_bk04.tsv` | chip 04's text: file offset, Spanish, English, alignment |
| `make_art.py` | rebuilds `art/` from the hand-drawn source images |
| [`../../scripts/bike_race_english_patch.py`](../../scripts/bike_race_english_patch.py) | writes the three chips; its docstring has the technical detail |

## Rebuilding

```bash
python3 translations/bike-race-en/make_art.py --src <folder of hand-drawn BK05_*.ppm>
python3 scripts/bike_race_english_patch.py --out <dir> -v
```

Changing a word or a picture means editing the TSV or the PNG and running the patch
script again.

## How the text is fitted

The firmware draws text in a 16-column grid of 8-pixel cells. Every caller passes a
fixed position, and the drawer never centres anything itself.

- **English no longer than the Spanish** is written in place, space-padded to exactly
  the Spanish length. That repaints exactly the cells the Spanish did.
  - **Titles** (`- SETUP -`) and **stand-alone messages** are centred in that space.
  - **Labels with a number directly after them** (`SW: C`, `LAMP:LC`, `COIL NO.`) are right-aligned.
  - **Everything else** is left-aligned.
- **English that is longer** is written to free space at `F000:A100` and its
  references are repointed. Only list items and stand-alone lines are lengthened,
  never a label with a value after it:
  - `HIGH SCORES`, twice;
  - `1 BALL MISSING`, `2 BALLS MISSING`;
  - `SPINNER`, `TARGET 1`–`4`, `SLINGSHOTS`, `COIN MECH`;
  - the coil-fault lines `SHORT CIRCUIT`, `TRANSISTORS OPEN` and `OR BAD FUSE F4`–`F15`.

  The script checks every repointed `PUSH F000 / PUSH offset` pair after writing it.
- **YES/NO** is copied byte by byte by three routines rather than reached through a
  pointer. Their branches are rewritten to store a full three-character value, and the
  value column on the extra-ball page moves one cell left.

"Partida" is translated as **Replay**:
- The manual awards *Partida Gratis* and announces "la Partida" on the panel
  (§3.2.3, §3.2.6, §3.4.2, §3.4.4).
- The match is a separate thing, *Lotería*, which "da Partida por lotería" (§3.12).
- §5.14 sets the two replay scores, *Primera* and *Segunda* → First and Second.

## Artwork

- **Hand-drawn:** most of `art/`, copied in unchanged.
- **Derived by `make_art.py`:**

| Record | English | How |
|---|---|---|
| 0184–0187 | `1 MILLION` | the hand-drawn frames re-spaced |
| 0198 | `SPARE PARTS` | the hand-drawn `SPAREPARTS` split, thick strokes narrowed to make room |
| 0211 | `Replay` | Nimbus Roman Bold with the "Partida" drop shadow |
| 0221 / 0222 | `First` / `Second` | Z003 outlined like "Primera"/"Segunda". The attract draws the replay score over rows 19–30, columns 40–119, so the words keep to the top left. |
| 0226 | `Aerial view...` | Z003 with the original's one-dot shadow |
| BK06 0081/0082 | `ONE` | U closed into an O, the face moved 12 px right, an E drawn in the gap |
| roll, 0x08276 | staff credits | ELECTROMECANICA, DISEÑO MECANICO, MUSICA, FABRICADO POR and `tlf.` become ELECTROMECHANICS, MECHANICAL DESIGN, MUSIC, MADE BY and TEL., set in the roll's own letters with a G and a Y drawn to match. Names, company and address are unchanged. |

Any of these can be redrawn by hand: replace the PNG and run the patch script.

## Verified in emulation

Headless in PinMAME, as set `bikerc3e` with a Bike Race ball simulator, in scripted
and randomised games. Neither is in PinMAME yet; both wait for the same real-machine
test. Every captured frame was matched against the translated records, and the
frames were looked at.

| Area | What was seen |
|---|---|
| Boot and factory reset | `WAITING / 8-BIT CPU`, `BALLS OK`, `RESTORING / FACTORY VALUES / PRESS START` |
| Attract loop | Freeplay → START → Replay → First / Second with the replay scores → PODIUM → the high-score table → NO HELMET… NO RIDE, and the staff-credits roll. A coin shows Freeplay. |
| Service menu | every page: the menus, every value page, YES/NO both ways, the three CLEAR pages, credits, tilts, the message editor, and the coil, lamp and switch tests with every switch name |
| Ball start | ONE, PLAYER / BALL sprites, BALL SAVE |
| Ramp 1 laps | the Pole Position clock, BONUS, `RECORD` Pole Position, Lap Record, Time Bonus, and the crossed-out BONUS when a lap is interrupted |
| Video mode | Aerial view…, the ride and its score |
| Multiball | MULTIBALL, the second ball served and the first kicked out of Expulsor 1 |
| Awards | 1 MILLION, 5 MILLION, Extra Ball, EXTRA BALL, Replay |
| Ball and game end | BONUS, Total bonus, GRAND PRIX Points, the parts screens (GASOLINE, OIL, TIRES, BRAKES, SPARKPLUGS, plain and inverted), SPARE PARTS with each part's award, CHAMPIONSHIP Points, the match, the PRESS START hold |
| Tilt | `WARNING / 1 TILT` with two tilts allowed, then TILT |
| High score | RECORD, `HIGH SCORE` / `PLAYER 1:` and `PLAYER 2:` with letters entered, and the new entry in the attract table |
| Faults | `COIL FAULT nn` / `GROUP: Txx-yy` with `TRANSISTORS OPEN` / `OR BAD FUSE Fn` or `SHORT CIRCUIT` / `CANNOT CONTINUE`, `L.`/`R. FLIPPER EOS` / `LOOSE OR BROKEN`, `CANNOT CONTINUE` / `EEPROM FAULT`, `CANNOT CONTINUE` / `BAD BK07 ROM`, and `1 BALL MISSING` / `2 BALLS MISSING` |

No Spanish word appears in any captured frame. Every graphics record in chips 05
and 06, including the four taller than 64 rows, was also rendered with
`scripts/sleic_dmd_viewer.py` and checked by eye.

Emulation never produces a fault on its own, so the fault screens were forced with
debug probes in that PinMAME build: Z80 port `0x04` read as `0xFE` turns the coil
monitoring on, a fault code handed to the 80188 as if the Z80 had sent it, a store
that refuses writes, and a Z80 boot reply dropped. The codes are in
[`docs/bikerace_coils_and_trough.md`](../../docs/bikerace_coils_and_trough.md).

**Not reached:** INSERT COINS (two records) and the CREDITS box. Free play always
has a credit, and the attract's credit screen is the one Freeplay replaces.

## Burning

27C010 EPROMs for chips 04, 05 and 06. The machine must already run the V4.1 set,
because chips 03 and 07 differ from the 1992 parent's.
