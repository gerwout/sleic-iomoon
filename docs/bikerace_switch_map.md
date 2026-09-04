# Bike Race (SLEIC3, 1992) — Switch-Code Map

Authoritative switch map for the Bike Race I/O protocol, recovered from the ROMs
and **validated against live-hardware ground truth** (keys pressed in the
firmware's TEST DE CONTACTOS, contact C-number read off the DMD).

> NOTE: a previous RE pass assumed the contact-name pool was in sequential
> pool order and produced a WRONG code→contact mapping. That assumption is
> dropped. The mapping below comes from the firmware's real `code→C-number→name`
> lookup TABLE (decoded below), and every live-hardware anchor matches it.
> Not transferable from Io Moon — the playfield C-numbering differs.

## Sources / key ROM offsets

- **80188 `bkcpu04.bin`** (linear `0xE0000–0xFFFFF`, `file = linear − 0xE0000`):
  - **code→C-number→name lookup table @ linear `0xF373D` (file `0x1373D`)**.
    5-byte records indexed by switch code: `Cnum(1) | name_off16(2) | name_seg(2,=F000)`.
    Indexed as `[F000:0x370B + code*5]` (base `0x370B = table − 5*0x0A`).
    Runtime readers: TEST-CONTACTOS C-number fetch `[es:bx+0x370b]` @ `0xF63A6`
    (file `0x163A6`); name far-ptr fetch `[es:bx+0x370c]/[+0x370e]` @ `0xF5E11`
    (file `0x15E11`). `bx = code*5` (`imul ax,ax,5` @ `0xF639C`).
  - Contact-name glyph-string pool @ linear `0xF3DDF` (file `0x13DDF`),
    length-prefixed.  The bytes are DMD **font indices**, not ASCII:

    | byte | glyph |
    |---|---|
    | `0x00`-`0x09` | `0`-`9` |
    | `0x0A` | space |
    | `0x0B`-`0x25` | `A`-`Z`, **with `Ñ` between `N` (`0x18`) and `O` (`0x1A`)** |
    | `0x2C` | `.` |

    Derived by aligning the pool against a name the live-hardware pass had already
    read off the DMD (`0x2A` = C44 "SALIDA RAMPA 1", 14 glyphs against 14 bytes, no
    conflicts) and confirmed by decoding the rest of the table: every entry comes out
    as clean Spanish. Decode the COL4 block with it and the trough reads

    ```
      code 0x2C  bit 0x04  C22  EXPULSOR 1
      code 0x2F  bit 0x20  C6   SALIDA BOLAS
      code 0x30  bit 0x40  C7   BOLA EN ESPERA
      code 0x31  bit 0x80  C8   BOLA FUERA
    ```

    which is where the "Bola en Espera" above comes from -- an earlier pass had C7 as
    "Bola Retenida", a plausible gloss but not the firmware's own word.

    **Decoding the whole table validates this page**: all 40 matrix C-numbers match
    the ROM exactly. Four names in the table below are deliberately fuller than the
    firmware's own and should not be "corrected" back -- they carry information the
    ROM string does not:

    | code | firmware name | this page |
    |---|---|---|
    | `0x13` | `FONDO BANCADA` | Diana Fondo Bancada |
    | `0x14` | `VELETA` | Veleta / Pasillo 5 |
    | `0x2B` | `BANDAS` | Bandas Derecha (sling) |
    | `0x25`/`0x26` | `C. FLIPPER IZQ.` / `DER.` | Corte Flipper Izq./Der. (EOS) |
  - Master switch dispatcher @ `0xE9EB6` (`al=[es:0x71]; sub 0x0A; bound cmp 0x52;
    jmp [cs:bx+0x3B4]`), jump table @ linear `0xEA024` (file `0xA024`), CS=`0xE9C7`.
    This is the *gameplay* dispatcher; the *test/menu* code consumes the same
    `last_switch_code` queue via the state handler @ `0xE9DCA`.
  - `last_switch_code` = `[es:0x71]`, es=`0x116`.
- **Z80 `bkio07.bin`** (`file = linear`):
  - Matrix scan: `out (0x82)` one-hot column select `0x01,0x02,0x04,0x08,0x10`,
    `in (0x02)` 8 rows; per-bit code emitters `sub_2e83`…`l2fbb`
    (`0x2E83`–`0x2FBD`) load code `0x0A + 8*col + row` into `(0xC0FE)`.
    Column latches: COL0→`0xC0D7`, COL1→`0xC0D8`, COL2→`0xC0D9`, COL3→`0xC0DA`,
    COL4→`0xC0DB`.
  - Direct (cabinet) dispatcher `sub_0dcb` @ `0x0DCB` reads port-0x03 latch
    `0xC0DF`; flipper handlers `sub_0e30`/`sub_0e76` @ `0x0E30`/`0x0E76`;
    coin path `l0ade` @ `0x0ADE`; J1 send `sub_0afa` @ `0x0AFA`.
- **Physical names**: Bike Race service manual, page 13 (CONTACTOS).

`code = 0x0A + 8*col + row`. Matrix columns COL0..COL4 are read by the 80188 as
`swMatrix[1..5]` (selected by the Z80 port-0x82 one-hot strobe `0x01..0x10`).

## (a) Matrix switches — code → C# → name (codes 0x0A–0x31)

Decoded directly from the `0x1373D` table (byte 0 = C#, far-ptr = name) and the
Z80 matrix emitter. **Every live ground-truth anchor matches this table.**
Ground-truth-confirmed codes are marked ✓.

| code | col,row | C# | Name (manual) | anchor |
|---|---|---|---|---|
| 0x0A | 0,0 | C35 | Pasillo 1 | ✓ |
| 0x0B | 0,1 | C36 | Pasillo 2 | ✓ |
| 0x0C | 0,2 | C37 | Pasillo 3 | ✓ |
| 0x0D | 0,3 | C38 | Pasillo 4 | ✓ |
| 0x0E | 0,4 | C40 | Pasillo 6 | ✓ |
| 0x0F | 0,5 | C41 | Pasillo 7 | ✓ |
| 0x10 | 0,6 | C42 | Pasillo 8 | ✓ |
| 0x11 | 0,7 | C43 | Pasillo 9 | ✓ |
| 0x12 | 1,0 | C26 | Bola saliendo | ✓ |
| 0x13 | 1,1 | C34 | Diana Fondo Bancada | ✓ |
| 0x14 | 1,2 | C39 | Veleta / Pasillo 5 | ✓ |
| 0x15 | 1,3 | C29 | Diana Bancada A | ✓ |
| 0x16 | 1,4 | C30 | Diana Bancada B | ✓ |
| 0x17 | 1,5 | C31 | Diana Bancada C | ✓ |
| 0x18 | 1,6 | C32 | Diana Bancada D | ✓ |
| 0x19 | 1,7 | C33 | Diana Bancada E | ✓ |
| 0x1A | 2,0 | — | (unused — table entry Cnum=0, seg=0) | ✓ (no contact) |
| 0x1B | 2,1 | C27 | Bumper 1 | ✓ |
| 0x1C | 2,2 | C28 | Bumper 2 | ✓ |
| 0x1D | 2,3 | C21 | Diana 2 | ✓ |
| 0x1E | 2,4 | C20 | Entrada Rampa 1 | ✓ |
| 0x1F | 2,5 | — | (unused — table entry Cnum=0, seg=0) | ✓ (unused) |
| 0x20 | 2,6 | C18 | Diana 1 | ✓ |
| 0x21 | 2,7 | C19 | Bola cautiva | ✓ |
| 0x22 | 3,0 | C9  | Pasillo 10 | table (COL3, untested live) |
| 0x23 | 3,1 | C12 | Pasillo 11 | table |
| 0x24 | 3,2 | C13 | Pasillo 12 | table |
| 0x25 | 3,3 | C10 | Corte Flipper Izq. (EOS) | table |
| 0x26 | 3,4 | C11 | Corte Flipper Der. (EOS) | table |
| 0x27 | 3,5 | C14 | Pasillo 13 | table |
| 0x28 | 3,6 | C15 | Pasillo 14 | table |
| 0x29 | 3,7 | C16 | Pasillo 15 | table |
| 0x2A | 4,0 | C44 | Salida Rampa 1 | ✓ |
| 0x2B | 4,1 | C25 | Bandas Derecha (sling) | ✓ |
| 0x2C | 4,2 | C22 | Expulsor 1 | ✓ |
| 0x2D | 4,3 | C23 | Diana 3 | ✓ |
| 0x2E | 4,4 | C24 | Diana 4 | ✓ |
| 0x2F | 4,5 | C6  | Salida Bolas (trough) | table |
| 0x30 | 4,6 | C7  | Bola en Espera (trough) | ✓ |
| 0x31 | 4,7 | C8  | Bola Fuera (trough) | table |

COL3 (0x22–0x29) and 0x31 were untested live but are fully pinned by the table;
they account for exactly the otherwise-missing contacts C9–C16 and C8.

## (b) Cabinet / direct buttons — code → C# → name → Z80 port/bit + menu fn

The cabinet buttons are NOT in the matrix; they are read directly. The Z80
emits a per-button code into `(0xC0FE)` and forwards it over J1. The
**as-wired emission is authoritative** and matches the `0x1373D` table AND the
live anchors (`0x32=C17`, `0x34=C5`).

| code | C# | Name (manual) | Z80 source | emitter | menu function |
|---|---|---|---|---|---|
| 0x32 | C17 | Péndulo de Falta (tilt) | port-0x03 **bit 0** | `sub_0dec` @ `0x0DEC` | **ENTER test menu** |
| 0x33 | C4  | Pulsador de Test | port-0x03 **bit 1** | `sub_0e09` @ `0x0E09` | (service/test trigger) |
| 0x34 | C5  | Pulsador Flipper Der. (right flipper) | port-0x03 **bit 2** | `sub_0e76`→`l0eaa` @ `0x0EAA` | **SELECT** |
| 0x35 | C1  | Pulsador Flipper Izq. (left flipper) | port-0x03 **bit 3** | `sub_0e30`→`l0e64` @ `0x0E64` | **scroll DOWN** |
| 0x36 | C2  | Pulsador de Start | port-0x03 **bit 4** | `sub_0e16` @ `0x0E16` | proceed / next group |
| 0x37 | —  | (coin pulse, no contact) | coin logic | `l0ade` @ `0x0AEA` | — |
| 0x38 | —  | (unused — table Cnum=0) | port-0x03 **bit 6** | `sub_0e23` @ `0x0E23` | — |
| 0x39 | C3  | Monedero (coin) | coin logic (alt state) | `l0af2` @ `0x0AF2` | — |
| 0x5F | —  | Z80-ready / power-up marker | boot | `0x0125` | — |

Notes:
- The **manual's "port-0x03 bit2 = COIN" is WRONG.** Port-0x03 bit 2 is the
  **right flipper** (code 0x34 = C5), confirmed by the live anchor `0x34→C5`.
  Coin is the dedicated coin-acceptor path (codes 0x37/0x39 = C3 Monedero),
  not a port-0x03 bit.
- **Flipper codes are emitted only in the lockout/test branch** (`l0e64`/`l0eaa`,
  reached when `0xC05B/0xC05C/0xC05D` ≠ 0). In normal play, port-0x03 bit2/bit3
  fire the flipper coils directly (`sub_0466`/`sub_0493`/`sub_0493`/`sub_04ea`)
  instead of sending a switch code. So in TEST CONTACTOS the right flipper shows
  C5 and the left flipper shows C1, matching the table.
- **TILT (C17)** doubles as the **menu-enter** button: port-0x03 bit 0 emits
  code 0x32, which the 80188 also uses to enter AJUSTES Y TEST.
- **Menu navigation** is state-driven: the same codes 0x32/0x34/0x35 act as
  ENTER/SELECT/scroll depending on the current menu page. The 80188 routes them
  through the queue consumer at `0xE9DCA` (stores to `[es:0x71]`) and the
  per-page handlers. Live testing confirms: 0x32 = enter menu, 0x35 = scroll
  down, 0x34 = select.
- **BACK/EXIT and scroll-UP**: there is no dedicated cabinet button that emits a
  distinct BACK or scroll-UP code in the port-0x03 set — navigation in this
  firmware is a single-direction scroll (0x35 down) + select (0x34), with the
  test button (0x33) and start (0x36) used to step between menu groups; EXIT is
  reached by walking off the end of a page (the state machine returns to the
  parent menu). A distinct UP/BACK code is **UNKNOWN** (none found in the
  port-0x03 emitter set).
- Power-up special reads (Z80 boot @ `0x010D`): **port-0x04 bit 7** → reboot
  (`l29ae`), **bit 6** → clear-stats + enter test (`l29bf`), **bit 5** →
  `sub_2b30`. Port-0x04 **bit 0** gates the matrix scan in `sub_0d2f`. These are
  power-on service-combo inputs, not in the contact table.

## Code-emission summary

- Matrix codes **0x0A–0x31**: `code = 0x0A + 8*col + row`, emitted by the Z80
  per-bit handlers `0x2E83`–`0x2FBD`.
- Cabinet codes **0x32–0x39**: port-0x03 bits + coin/flipper logic (table above).
- The 80188 maps EVERY code through the single table @ `0xF373D` to get the
  C-number and display name for TEST DE CONTACTOS.

Non-contact / status codes seen on the wire: 0x37 (coin pulse), 0x5B/0x5D
(trough status replies), 0x5F (Z80 ready marker). Codes whose table entry has
Cnum=0/seg=0 (0x1A, 0x1F, 0x38) are unused contacts.
