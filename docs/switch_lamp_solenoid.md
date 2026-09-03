# Switch, Lamp & Solenoid Tables

[← Back to main README](../README.md)

The C-numbers and names below are the original SLEIC IO Moon service manual's
contact list. The **ports and codes** beside them are read out of the Z80 ROM
(`V1 3_05.bin`) in [`../asm/baseline-2026-09/`](../asm/baseline-2026-09/) and are
findings F5 / F7 / F15 of
[`findings.md`](../asm/baseline-2026-09/findings.md); where the ROM and the
manual's summary differ, the ROM is what runs and the difference is called out.

> For how the service menu is opened and navigated, see
> [`iomoon_language_and_service_menu.md`](iomoon_language_and_service_menu.md):
> TEST (`0x3F`) opens and exits it, the flipper codes `0x41` and `0x42` scroll
> and select, and START (`0x40`) goes back.

---

## Switches

The Z80 delivers **48 matrix positions** (6 columns × 8 rows), **6 cabinet
inputs** on port `0x03`, and a further 16-way multiplexed **direct-input scan**
on port `0x87` / port `0x01` bit 5 that is disabled on this machine
(port `0x04` bit 0 gates `direct_input_scan` off). The manual's contact list
runs C1–C50.

### Cabinet inputs (port `0x03`)

Read directly, bypassing the matrix. The bit → code mapping is exact; the
C-number beside each is the manual's.

| Code | Port `0x03` bit | Spanish Name | English Name | Z80 handler |
|------|-----------------|--------------|--------------|-------------|
| `0x32` (`0x33` in test mode) | 5 | Entrada Monedas (C3) | Coin mechanism — one code per press | `0D3C` / `0D44` |
| `0x3E` | 0 | Contacto de falta (C20) | Tilt | `sub_125B` |
| `0x3F` | 1 | Pulsador de Test (C4) | TEST / service menu | `sub_1278` |
| `0x40` | 4 | Pulsador Start (C2) | START | `sub_1285` |
| `0x41` | 3 | Pulsador flipper izquierdo (C1) | Left flipper button | `sub_1292` |
| `0x42` | 2 | Pulsador flipper derecho (C5) | Right flipper button | `sub_12D8` |

The two flipper bits fire the port-`0x85` coil pairs directly (`sub_05C7` /
`sub_05ED`) and only emit `0x41` / `0x42` over J1 while test mode is set; the
other four emit their code on every press. `0x32` is the one code the 80188's
NMI does not queue — it counts it in `[4000:1144]` as a coin pulse instead.

### Matrix contacts

6 columns × 8 rows = 48 positions, strobed on port `0x82` (one-hot `0x01`–`0x20`)
and read back on port `0x02`. **Column c, bit b → code `0x0A + 8c + b`** for
c = 0..4, and **`0x34 + b`** for column 5.

Four positions are identified from the firmware: **column 0 bits 0–3, codes
`0x0A`–`0x0D`, are the ball-handling contacts** — bits 0–2 the three trough
contacts (manual C6/C7/C8) and bit 3 the ball-exit contact (C9). Contact 0 is the
trough entry: it doubles as the ball-over sensor and reports code `0x43` instead
of its own `0x0A`, and the ball complement is three. The remaining 44 positions
are exact as codes but are not yet tied to individual entries in the manual's
list below.

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

The lamp matrix is driven by the Z80 as **8 columns × 8 bits = 64**: the row byte
goes to port `0x84` (active high), then the one-hot column strobe to port `0x83`
(`0x01`–`0x80`), one column per Z80 interrupt. Each lamp has two bank bits — bank 1
at `C0FF`–`C106` and bank 2 at `C107`–`C10E` — which together give steady-on,
blinking and off; see [`z80_io_ports.md`](z80_io_ports.md).

---

## Drivers (solenoids)

Two 8-bit latches on Z80 ports `0x85` and `0x86`, **active LOW** — `boot_port_init`
`041B` writes `0xFF` to both at reset, so a cleared bit fires a driver. That is
**16 driver bits**, and they are not 16 independent devices: port `0x86` drives
all eight of its bits independently, while on port `0x85` bits 0/1, 2/3 and 4/5
are driven as complementary pairs and bits 6 and 7 individually. **13 addressable
devices**, then — the complementary pairs being the power/hold windings the
manual counts as dual-wound flippers.

The driven loads are:

- **Flippers**: left, right, upper (dual-wound: power + hold)
- **Pop bumpers**: 5 units
- **Slingshots / kickers**: 2 units
- **VUKs (vertical up-kickers)**: 2 scoops
- **Drop-target bank reset**: 1 coil
- **Ball eject / serve** coils for ball management
- **Flashlamp drivers** on the +24 V flash circuit (TW1/TW2)

Which command byte reaches which bit is decoded by the Z80's 256-entry table at
`$2000` (commands `0xCB`–`0xE7`); see [`z80_io_ports.md`](z80_io_ports.md).
