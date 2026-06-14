# Sleic Pin-Ball — complete switch (contact) map

Source: **SLEIC 1994 Sleic Pin-Ball Service Manual** (Spanish, OCR'd + page images),
section 2.1.1 "DESCRIPCIÓN DE CONTACTOS" (manual p.5) and FIGURA 24 "MATRIZ DE
CONTACTOS" (manual p.66). Cross-checked against the `sp03`/`sp04` disassembly.
Pin-Ball has **two types of contacts**: matrix (`Matriz`) and direct (`Directo`).

## Contact list (C1–C36) — names from the manual

| Code | Name (ES) | Name (EN) | Type |
|---|---|---|---|
| C1  | Pasillo 1 | Lane 1 | Matriz |
| C2  | Pasillo 2 | Lane 2 | Matriz |
| C3  | Pasillo 3 | Lane 3 | Matriz |
| C4  | Pasillo 4 | Lane 4 | Matriz |
| C5  | Pasillo 5 | Lane 5 | Matriz |
| C6  | Pasillo 6 | Lane 6 | Matriz |
| C7  | Pasillo 7 | Lane 7 | Matriz |
| C8  | Pasillo 8 | Lane 8 | Matriz |
| C9  | Pasillo 9 | Lane 9 | Matriz |
| C10 | Pasillo 10 | Lane 10 | Matriz |
| C11 | Pasillo 11 | Lane 11 | Matriz |
| C12 | *(not used)* | — | — |
| C13 | Bumper Izquierdo | Left bumper | Matriz |
| C14 | Bumper Derecho | Right bumper | Matriz |
| C15 | Contacto Banda | Slingshot | Matriz |
| C16 | Contacto Banda | Slingshot | Matriz |
| C17 | Bola Cautiva Izquierda | Left captive ball | Matriz |
| C18 | Bola Cautiva Derecha | Right captive ball | Matriz |
| C19 | Diana Izquierda (A) | Left drop target A | Matriz |
| C20 | Diana Izquierda (B) | Left drop target B | Matriz |
| C21 | Diana Izquierda (C) | Left drop target C | Matriz |
| C22 | Fondo Bancada Izquierda | Left target-bank bottom | Matriz |
| C23 | Diana Derecha (A) | Right drop target A | Matriz |
| C24 | Diana Derecha (B) | Right drop target B | Matriz |
| C25 | Diana Derecha (C) | Right drop target C | Matriz |
| C26 | Fondo Bancada Derecha | Right target-bank bottom | Matriz |
| C27 | Expulsor Izquierdo | Left kicker | Matriz |
| C28 | Expulsor Derecho | Right kicker | Matriz |
| C29 | Salida Bolas | Ball exit/trough | Matriz |
| C30 | Veleta | Spinner | Matriz |
| C31 | Flipper Izquierdo | Left flipper | **Directo** |
| C32 | Flipper Derecho | Right flipper | **Directo** |
| C33 | Pulsador Start | Start button | **Directo** |
| C34 | Monedero | Coin | **Directo** |
| C35 | Péndulo de Falta | Tilt pendulum | **Directo** |
| C36 | Pulsador de Test | Test button | **Directo** |

29 matrix contacts (C1–C11, C13–C30) + 6 direct (C31–C36). C12 does not exist.

## Matrix wiring (FIGURA 24) — 8 común (scan) × 4 retorno (read)

The Z80 strobes común 0–7 one-hot on **port 0x82**; the 4 return lines are read on
**port 0x02** (active-low). Cell label `(c·r)` = común c, retorno r.

| común \ retorno | RET 0 | RET 1 | RET 2 | RET 3 |
|---|---|---|---|---|
| **COMÚN 0** | C1 Pasillo 1 | C28 Expulsor Der | C29 Salida Bolas | C6 Pasillo 6 |
| **COMÚN 1** | C2 Pasillo 2 | C23 Diana Der A | C27 Expulsor Izq | C18 Bola Cautiva Der |
| **COMÚN 2** | C14 Bumper Der | C24 Diana Der B | C10 Pasillo 10 | C15 Contacto Banda |
| **COMÚN 3** | C17 Bola Cautiva Izq | C25 Diana Der C | C11 Pasillo 11 | C13 Bumper Izq |
| **COMÚN 4** | C16 Contacto Banda | C7 Pasillo 7 | C19 Diana Izq A | C30 Veleta |
| **COMÚN 5** | — | C8 Pasillo 8 | C20 Diana Izq B | C3 Pasillo 3 |
| **COMÚN 6** | — | C9 Pasillo 9 | C21 Diana Izq C | C4 Pasillo 4 |
| **COMÚN 7** | — | C26 Fondo Bancada Der † | C22 Fondo Bancada Izq | C5 Pasillo 5 |

† The manual prints "C28" at both (0·1) and (7·1) and omits C26; since the 29 used
cells must hold the 29 distinct matrix contacts, (7·1) is read here as **C26**
(Fondo Bancada Derecha). Confirm against the real machine / `sp03` contact-name
table if it is ever located.

Empty cells: (5·0), (6·0), (7·0).

## Mapping to PinMAME `coreGlobals.swMatrix`

Mirror the SLEIC3 model (`port 0x82` one-hot -> `swStrobe`; `port 0x02` returns
`~swMatrix[1+swStrobe]`; cabinet on `port 0x03` -> `swMatrix[9]`). RET r = bit r.

| swMatrix[] | común | bit0 (RET0) | bit1 (RET1) | bit2 (RET2) | bit3 (RET3) |
|---|---|---|---|---|---|
| `swMatrix[1]` | 0 | C1 | C28 | C29 | C6 |
| `swMatrix[2]` | 1 | C2 | C23 | C27 | C18 |
| `swMatrix[3]` | 2 | C14 | C24 | C10 | C15 |
| `swMatrix[4]` | 3 | C17 | C25 | C11 | C13 |
| `swMatrix[5]` | 4 | C16 | C7 | C19 | C30 |
| `swMatrix[6]` | 5 | — | C8 | C20 | C3 |
| `swMatrix[7]` | 6 | — | C9 | C21 | C4 |
| `swMatrix[8]` | 7 | — | C26 † | C22 | C5 |
| `swMatrix[9]` | direct (port 0x03) | C31..C36 (bit assignment TBD from sp04) | | | |

Direct/cabinet (C31–C36) are read on **port 0x03** → `swMatrix[9]`. **Confirmed**
bit→code→contact (sp04 dispatcher `sub_0978`/`sub_09fe..0a70` + sp03 handlers):

| port-0x03 bit | code | contact | evidence |
|---|---|---|---|
| 0 | 0x01 | C35 Péndulo de Falta (tilt) | handler acts only in-game (`[0x103]≠0`), warning counter |
| 1 | 0x02 | C36 Pulsador de Test | enters service menu (`F000:567F` sets `[0x4d1]`) |
| 2 | 0x03 | C32 Flipper Derecho | fires coil 03 (Flipper Der Fuerza) |
| 3 | 0x04 | C31 Flipper Izquierdo | fires coil 01 (Flipper Izq Fuerza) |
| 4 | 0x05 | C33 Pulsador Start | game-start handler (start key '1') |
| 5 | 0x06 | C34 Monedero (coin) | coin handler (coin key '5') |

Flippers (bits 2/3) fire their coils in real time; codes 0x03/0x04 are sent to the
80188 only in menu mode (for navigation).

## Comparison with Bike Race
- Bike Race matrix is documented (`docs/bikerace_switch_map.md`) as a 5-column model;
  **Sleic Pin-Ball is 8 común × 4 retorno** (32 cells, 29 used) — different geometry,
  but the same scan mechanism (port 0x82 strobe + port 0x02 read) and the same J1/NMI
  delivery. The contact assignments are game-specific (different playfield).
- Both store switch mapping in ROM (sleicpin dispatch jump table at `E000:0310`).

## Appendix — lamps & solenoids (for later wiring; from the manual)
- **Luces (FIGURA 3, manual p.6):** controlled lamps **LC1–LC31**, fixed lamps
  **LF0–LF27**. Lamp matrix driven on Z80 ports 0x83 (column) / 0x84 (row); see
  manual §2.2 and FIGURA 30 (MATRIZ DE LUCES).
- **Bobinas/solenoids (manual §7.2.3, p.68):** Flipper Izq/Der (Fuerza+Mantenimiento),
  Bancada Izq/Der, Bumper Izq/Der, Expulsor Izq/Der, Salida Bolas, Taca. Driven on
  Z80 ports 0x85/0x86 with VDB (Vigilancia Dinámica de Bobinas) protection.
