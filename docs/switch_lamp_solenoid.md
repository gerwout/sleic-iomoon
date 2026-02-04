# Switch, Lamp & Solenoid Tables

[← Back to main README](../README.md)

All tables below are derived from the original SLEIC IO Moon service manual (Spanish, 1996) and verified against the Z80 ROM disassembly.

---

## Switches (50 total)

### Direct Switches (6)

These switches are read directly via dedicated I/O ports, bypassing the switch matrix.

| Code | Spanish Name | English Name | Z80 Port | ROM Code |
|------|-------------|--------------|----------|----------|
| C1 | Pulsador flipper izquierdo | Left Flipper Button | Port `0x03` | `0x3E` |
| C2 | Pulsador Start | START Button | Port `0x03` bit 3 | `0x41` |
| C3 | Entrada Monedas | Coin Input | Port `0x03` bit 2 | `0x42` |
| C4 | Pulsador de Test | TEST/Service Button | Port `0x03`/`0x04` | TBD |
| C5 | Pulsador flipper derecho | Right Flipper Button | Port `0x03` | `0x3F` |
| C20 | Contacto de falta | Tilt Switch | Port `0x04` | TBD |

### Matrix Switches (44)

The switch matrix uses 6 rows × 8 columns, scanned via Port `0x02` (column read) and Port `0x82` (row strobe).

| Code | Spanish Name | English Name |
|------|-------------|--------------|
| C6 | Contacto salida bolas 1 | Ball Trough Sensor 1 |
| C7 | Contacto salida bolas 2 | Ball Trough Sensor 2 |
| C8 | Contacto salida bolas 3 | Ball Trough Sensor 3 |
| C9 | Bola Fuera | Ball Drain / Outhole |
| C10 | Contacto de corte flipper izq. | Left Flipper EOS |
| C11 | Contacto de corte flipper der. | Right Flipper EOS |
| C12 | Pasillo 1 | Lane 1 (Top) |
| C13 | Pasillo 2 | Lane 2 (Top) |
| C14 | Pasillo 3 | Lane 3 (Top) |
| C15 | Expulsor 1 | Kicker / Slingshot 1 |
| C16 | Expulsor 2 | Kicker / Slingshot 2 |
| C17 | Pasillo 4 | Lane 4 |
| C18 | Pasillo 5 | Lane 5 |
| C19 | Contacto de corte flipper sup. | Upper Flipper EOS |
| C21 | Sin conectar | Not Connected |
| C22 | Pasillo 11 | Lane 11 |
| C23 | Tragabolas 1 | Scoop / VUK 1 |
| C24 | Pasillo 6 | Lane 6 |
| C25 | Bancada (A) | Drop Target A |
| C26 | Bancada (B) | Drop Target B |
| C27 | Bancada (C) | Drop Target C |
| C28 | Bancada (D) | Drop Target D |
| C29 | Bancada (E) | Drop Target E |
| C30 | Fondo Bancada | Drop Target Bank Bottom |
| C31 | Tragabolas 2 | Scoop / VUK 2 |
| C32 | Diana 1 | Standup Target 1 |
| C33 | Bumper 1 | Pop Bumper 1 |
| C34 | Bumper 2 | Pop Bumper 2 |
| C35 | Bumper 3 | Pop Bumper 3 |
| C36 | Bumper 4 | Pop Bumper 4 |
| C37 | Bumper 5 | Pop Bumper 5 |
| C38 | Diana 2 | Standup Target 2 |
| C39 | Entrada Rampa 2 | Ramp 2 Entry |
| C40 | Planeta 5 | Planet 5 |
| C41 | Pasillo 7 | Lane 7 |
| C42 | Pasillo 8 | Lane 8 |
| C43 | Pasillo 9 | Lane 9 |
| C44 | Rampa 1 | Ramp 1 |
| C45 | Rampa 2 | Ramp 2 |
| C46 | Pasillo 10 | Lane 10 |
| C47 | Entrada Rampa 1 | Ramp 1 Entry |
| C48 | Planeta 1 | Planet 1 |
| C49 | Planeta 2 | Planet 2 |
| C50 | Contacto de Servicio | Service Switch |

---

## Lamps (64 positions)

### Fixed Lamps (General Illumination)

General illumination is controlled by RELE2 on the power board. These are not individually addressable.

### Controlled Lamps (LC1–LC64)

| Code | Function |
|------|----------|
| LC1 | Start Button |
| LC2 | Monolith Message: Extra Ball |
| LC3 | Monolith Message: 3,000,000 |
| LC4 | Monolith Message: Little Multiball |
| LC5 | Monolith Message: 6,000,000 |
| LC6 | Monolith Message: Special on Lane 1 or 5 |
| LC7 | Monolith Message: 9,000,000 |
| LC8 | Monolith Message: Impact Count |
| LC9 | Monolith Message: Orbit Flip |
| LC10 | Monolith Message: Special Drop Target |
| LC11 | Monolith Message: Star Ride |
| LC12 | Lagrange Scape |
| LC13 | Lagrange Orbit |
| LC14 | Lane 1: Special |
| LC15 | Lane 2: Orbits ×2 |
| LC16 | Lane 3: Light Autodrop |
| LC17 | Scoop 1: Little Multiball |
| LC18 | Lane 4: Light Spelling Orbits |
| LC19 | Lane 5: Special |
| LC20–LC23 | Bonus 1–4 |
| LC24–LC25 | Not Connected |
| LC26–LC29 | Bonus 7–10 |
| LC30–LC35 | Drop Target Bank A–E + Bottom |
| LC36 | Lane 11: Autodrop |
| LC37 | Scoop 1: Monolith Message |
| LC38 | Spelling "O" |
| LC39 | Standup 1: Spelling Orbits |
| LC40 | Bumper 3 |
| LC41 | Spelling "R" |
| LC42 | Not Connected |
| LC43 | Bumper 4 |
| LC44 | Spelling "B" |
| LC45 | Bumper 2 |
| LC46 | Spelling "I" |
| LC47 | Bumper 5 |
| LC48 | Spelling "T" |
| LC49 | Spelling "S" |
| LC50 | Scoop 2: Monolith Message |
| LC51 | Planet 5 |
| LC52 | Standup 2: Jackpot |
| LC53 | Ramp 2: Extra Ball |
| LC54 | Ramp 1: Orbits ×2 |
| LC55 | Ramp 1: Light Hole Power |
| LC56 | Ramp 2: Super Jackpot |
| LC57 | Lane 7: Special |
| LC58 | Lane 8: Extra Ball |
| LC59 | Lane 9: Bonus ×10 |
| LC60 | Ramp 2: Black Hole Power |
| LC61 | Planet 1 |
| LC62 | Planet 2 |
| LC63–LC64 | Not Connected |

The lamp matrix is controlled by the Z80 via ports `0x82`–`0x84` (7 columns × 16 rows).

---

## Solenoids (18 total)

The machine has 18 solenoids (21 total including dual-wound flippers), controlled by the Z80 via ports `0x85` and `0x86`.

The solenoid types include:

- **Flippers**: Left, Right, Upper (dual-wound: power + hold coils)
- **Pop bumpers**: 5 units
- **Slingshots/Kickers**: 2 units
- **VUKs (Vertical Up Kickers)**: 2 scoops
- **Drop target bank reset**: 1 coil
- **Ball eject/serve**: Multiple coils for ball management
- **Flashlamp drivers**: Controlled via +24V flash circuit (TW1/TW2)

The exact solenoid-to-port mapping is documented in the [Z80 annotated assembly](../asm/z80_annotated.asm).
