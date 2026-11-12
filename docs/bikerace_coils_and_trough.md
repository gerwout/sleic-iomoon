# Bike Race (SLEIC3) — Coils and the Ball Trough

What the V4.1 set (`bikerac3` and its mods) drives on its two Z80 driver latches,
and how its two-ball trough works. PinMAME's Bike Race ball simulator
(`src/wpc/sims/sleic/bikerace.c`, proposed in
[vpinball/pinmame#832](https://github.com/vpinball/pinmame/pull/832)) follows this page. Switch codes and contact names are in
[`bikerace_switch_map.md`](bikerace_switch_map.md).

## Coils

The Z80 drives ports `0x85` and `0x86`, active low. The service manual
(§2.3.1) lists twelve coils. Which bit fires which coil comes from running the
service menu's COIL TEST and recording the bit that is set while the panel shows
each `COIL NO.`:

| Port bit | PinMAME solenoid | Manual coil | Function | Z80 fire routine / command |
|---|---|---|---|---|
| `0x85` b0 | 1 | 01 | left flipper, power winding | — |
| `0x85` b1 | 2 | 02 | left flipper, hold winding | — |
| `0x85` b2 | 3 | 03 | right flipper, power winding | — |
| `0x85` b3 | 4 | 04 | right flipper, hold winding | — |
| `0x85` b4-b7 | 5-8 | — | flash lamps, not coils (`0559`/`0571`/`0589`/`05A1`, commands `0x55`-`0x58`) | |
| `0x86` b0 | 9 | 12 | drop-target bank reset | `0311`, command `0xCB` |
| `0x86` b1 | 10 | 07 | *Multibola* — releases the waiting ball into the shooter lane | `0330`, command `0xCC`; held, cleared by `0447` (command `0xD3`) |
| `0x86` b2 | 11 | 10 | bumper 1 | `034F`, command `0xCD` |
| `0x86` b3 | 12 | 11 | bumper 2 | `036E`, command `0xCE` |
| `0x86` b4 | 13 | 09 | Expulsor 1 (the C22 hole) | `038D`/`0409`, command `0xCF` |
| `0x86` b5 | 14 | 05 | Expulsor 2 de Cañón — the Pasillo 10 kickback | `03AC`/`0428`, command `0xD0` |
| `0x86` b6 | 15 | 06 | *Salida de Bolas* — lifts the outhole ball to the waiting position | `03CB`, command `0xD1` |
| `0x86` b7 | 16 | 08 | *Taca* | `03EA`, command `0xD2` |

Addresses are in the V4.1 Z80 ROM `bk07.bin`. The command table is the
256-entry word table at `0x2000`. Ball start (80188 command `0x9B`) fires the
bank reset together with the flash lamp on `0x85` b7.

The bumpers and the kickback are fired by the Z80 in the same frame as their
contact. Some pulses last less than one 60 Hz frame: Expulsor 1 is one of them.

## The trough

Two balls and three contacts on switch column 4:

| Contact | Code | Firmware name | Where it is (manual figure 2) |
|---|---|---|---|
| C6 | `0x2F` | SALIDA BOLAS | the outhole under the apron, where a drained ball lands |
| C7 | `0x30` | BOLA EN ESPERA | the waiting position beside the shooter lane |
| C8 | `0x31` | BOLA FUERA | the foot of the shooter lane |
| C26 | `0x12` | BOLA SALIENDO | up the shooter lane, closed by a plunged ball |

A ball moves outhole → waiting → shooter lane:

- coil 6 lifts the C6 ball to C7;
- coil 7 releases the C7 ball to C8 and stays on until C8 closes.

The serve is 80188 command `0x98`, Z80 handler `26F1`. It strobes column 4,
reads it raw and branches on what it finds:

| Closed | What the Z80 does |
|---|---|
| C6 + C7 (both balls home) | fires coil 7, then refills C7 from C6 |
| C6 + C8 | nothing to release; refills C7 from C6 |
| C7 + C8 | nothing to do |
| C7 alone | fires coil 7 |
| C8 alone | nothing to do |
| anything else | waits, reports, retries |

While a refill is pending, the C6 handler (`121E`) fires coil 6 every 800 ticks
for as long as C6 stays closed. Once C7 has read closed four times in a row,
150 ticks apart (`1272`), the trough is settled. A ball reaching C6 after that
is the drain: the Z80 sends `0x2F` to the 80188 and, with C7 empty, lifts it.

Each column-4 contact reports once and then masks itself (`3137` sets the bit
in the mask at `C0EC`); the 80188 re-arms it with a command (`3182` clears it).
C8's handler (`12C1`) also sets `C068`, which tells the serve that the ball
arrived.

The boot check (command `0xD5`) wants two balls including the one at C7, which
is the at-rest state above.

## Coil monitoring and the fault screens

The Z80 watches the coil drivers (the manual's VDB, §2.4) and reports a failed
coil to the 80188 as a switch code:

| Code | Meaning | 80188 screen |
|---|---|---|
| `0x41`-`0x4C` | coil *code* − `0x40` shorted | coil number, transistor group, "EN CORTO", "IMPOSIBLE SEGUIR"; the game halts (`F000:7C8E`) |
| `0x4D`-`0x58` | coil *code* − `0x4C` open, or its fuse | coil number, transistor group, "CORTADOS O", the fuse (`F000:7BAE`) |
| `0x59` / `0x5A` | left / right flipper end-of-stroke switch | its name over "SEPARADO O ROTO" (`F000:7B4D`) |

The group and fuse text come from a 10-byte record per coil at `F000:3878`
(+10 × coil): a far pointer to the group string, then one to the fuse string.
The game dispatcher (`E9C7:01C5`) and the coil test both route these codes.

The 80188 acts on them only while `[0116:98]` is 0. That byte is bit 0 of the
Z80's reply to the boot handshake (command `0xD4`, `E000:9724`), and the reply is
port `0x04` with the top nibble set, so port `0x04` bit 0 switches the
monitoring off. PinMAME's driver returns `0xFF` on that port, which is why an
emulated machine never shows these screens.

Two more faults stop the machine at boot, both over "IMPOSIBLE SEGUIR":

- "FALLO EEPROM" (`E000:93E3`): the non-volatile store fails its check, the
  factory reset rewrites it, and it fails again (`E000:97DE`).
- "BK07 ERRONEA" (`E000:9756`): no reply to command `0xD4` within 200 ticks
  (`E000:957E`).

## Not established

- Coil 8 (*Taca*): what it acts on. Command `0x9C` fires it together with the
  four flash lamps.
- The 1992 parent's and `bikerac2`'s Z80 ROMs answer the trough differently
  and are not traced here.
