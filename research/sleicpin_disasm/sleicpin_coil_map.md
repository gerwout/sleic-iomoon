# Sleic Pin-Ball — coil (bobina) map

Source: service manual §2.3.1 "DESCRIPCIÓN DE BOBINAS" (FIGURA 4, manual p.9) +
the `sp04` Z80 disassembly (the assembler is the baseline). 12 coils total
(10 functions; the two flippers are double-wound → 12 windings). Compared with
Bike Race — **same port structure, different coil layout (do not assume identical).**

## How coils are driven (sp04)

Each coil has a small fire routine: `ld a,(shadow); and ~(1<<bit); ld (shadow),a;
out (port),a` — **active-low** (a coil is energised when its bit is *cleared* in the
shadow), with a per-coil auto-release timer. Two shadow/port pairs:
- **port 0x85** ← shadow `0xC005` (flipper windings, 4 bits used)
- **port 0x86** ← shadow `0xC006` (playfield coils, all 8 bits used)

(`port 0x87` is the **VDB** — Vigilancia Dinámica de Bobinas, coil-current watchdog —
scan, read back on `IN 0x01`; it is **not** a coil output.)

## Verified bit → coil mapping

| Port·bit | Bobina | Function | Fire routine (sp04) |
|---|---|---|---|
| 0x85·0 | **01** | Flipper Izquierdo (Bobinado Fuerza) | `sub_024a` (left flipper, `sub_0a3a`) |
| 0x85·1 | **02** | Flipper Izquierdo (Mantenimiento) | `0x036e` |
| 0x85·2 | **03** | Flipper Derecho (Bobinado Fuerza) | `sub_0266` (right flipper, `sub_0a18`) |
| 0x85·3 | **04** | Flipper Derecho (Mantenimiento) | `0x0390` |
| 0x85·4-7 | — | unused | — |
| 0x86·0 | **05** | Bancada de Dianas Izquierda | `sub_0282` (`0x14cc`) |
| 0x86·1 | **06** | Bancada de Dianas Derecha | `0x029e` (`0x14d0`) |
| 0x86·2 | **07** | Bumper Izquierdo | `0x02ba` (hit `0x0a90`, test `0x15ee`) |
| 0x86·3 | **08** | Bumper Derecho | `0x02d6` (hit `0x0a9e`, test `0x15f2`) |
| 0x86·4 | **09** | Expulsor Izquierdo | `0x02f2` (hit `0x0aae`, test `0x15f6`) |
| 0x86·5 | **10** | Expulsor Derecho | `0x030e` (hit `0x0abe`, test `0x15fa`) |
| 0x86·6 | **11** | Bobina Salida Bolas | `0x032a` (`0x14da`) |
| 0x86·7 | **12** | Taca (shooter/auto-plunge) | `0x0346` (`0x14e8`) |

The flipper handlers confirm the flipper windings: the left flipper button
(`sub_0a3a`) fires `sub_024a` (port 0x85 bit 0) and the right (`sub_0a18`) fires
`sub_0266` (port 0x85 bit 2) — the **Fuerza** (power) windings; the Mantenimiento
(hold) windings follow on bits 1/3. The bumper/expulsor coils (07-10) are fired both
on switch hits (gameplay) and by the service coil-test, confirming the bit order.

## PinMAME mapping (driver)

`pinmame/src/wpc/sleic.c` `sleic1_z80_write`:
- port 0x85 (active-low) → `coreGlobals.solenoids` bits 0-3 → **solenoids 1-4**
- port 0x86 (active-low) → `coreGlobals.solenoids` bits 4-11 → **solenoids 5-12**

so **PinMAME solenoid number == the manual's bobina number** (sol1-12 = bobinas
01-12).  Earlier the driver inherited Bike Race's layout (port 0x86 → bits 8-15),
which put coils 05-12 on solenoids 9-16; corrected 2026-06-15.

## vs Bike Race
Same mechanism (two active-low shadow ports 0x85/0x86, per-coil timers, VDB on 0x87)
but a **different coil set/order** (Bike Race is a motorbike-race playfield). Bike
Race maps port 0x86 to solenoids 9-16; sleicpin's 12-coil layout maps cleanly to
solenoids 1-12, so the two drivers intentionally differ here.
