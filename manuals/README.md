# Manuals

Original SLEIC service manuals, all in Spanish. The IO Moon manual is the primary
reference for this repository; the other three cover the related machines documented
in [`../docs/sleic_board_family.md`](../docs/sleic_board_family.md) and supply the
physical switch, contact and coil names that the disassemblies are matched against.

| Manual | Machine | Year | Pages | Schematics |
|--------|---------|------|-------|------------|
| [`sleic_io_moon_manual_es.pdf`](sleic_io_moon_manual_es.pdf) | IO Moon | — | 159 | yes |
| [`SLEIC_1992_Bike_Race_Spanish_Service_Manual_with_parts_list_and_paginated_schematics.pdf`](SLEIC_1992_Bike_Race_Spanish_Service_Manual_with_parts_list_and_paginated_schematics.pdf) | Bike Race | 1992 | 125 | yes, paginated |
| [`SLEIC_1994_Sleic_Pin_Ball_Service_Manual_no_schematics.pdf`](SLEIC_1994_Sleic_Pin_Ball_Service_Manual_no_schematics.pdf) | Sleic Pin-Ball | 1994 | 93 | no |
| [`SLEIC_1996_Dona_Elvira_2_Spanish_Service_Manual_with_schematics.pdf`](SLEIC_1996_Dona_Elvira_2_Spanish_Service_Manual_with_schematics.pdf) | Doña Elvira 2 | 1996 | 142 | yes, seven board sets |

## IO Moon — original Spanish service manual

📄 [`sleic_io_moon_manual_es.pdf`](sleic_io_moon_manual_es.pdf)

The original SLEIC IO Moon service manual in Spanish. Covers installation,
maintenance, switch/lamp/solenoid tables, test procedures, and operator
configuration, with approximately 30 pages of schematics.

## Bike Race — 1992 Spanish service manual

📄 [`SLEIC_1992_Bike_Race_Spanish_Service_Manual_with_parts_list_and_paginated_schematics.pdf`](SLEIC_1992_Bike_Race_Spanish_Service_Manual_with_parts_list_and_paginated_schematics.pdf)

125 pages, including a parts list and a full set of paginated schematics. Page 13
(*CONTACTOS*) is the authority for the physical switch names used in
[`../docs/bikerace_switch_map.md`](../docs/bikerace_switch_map.md).

## Sleic Pin-Ball — 1994 Spanish service manual

📄 [`SLEIC_1994_Sleic_Pin_Ball_Service_Manual_no_schematics.pdf`](SLEIC_1994_Sleic_Pin_Ball_Service_Manual_no_schematics.pdf)

93 pages. No schematics section, but it carries the contact and coil tables that
the `sp03`/`sp04` disassemblies in
[`../research/sleicpin_disasm/`](../research/sleicpin_disasm/) are cross-checked
against.

## Doña Elvira 2 — 1996 Spanish service manual

📄 [`SLEIC_1996_Dona_Elvira_2_Spanish_Service_Manual_with_schematics.pdf`](SLEIC_1996_Dona_Elvira_2_Spanish_Service_Manual_with_schematics.pdf)

142 pages, a scan with no text layer. Eight sections: machine description, the
playfield tables (contacts, lamps, coils), gameplay and scoring, the programmable
values behind the SW40 microswitch bank, the adjustment and test menus, an exploded
parts breakdown, a per-board electronic description, and a schematics section.

The schematics (PDF pages 88–141) are separately paginated in seven board sets:
cableado general (I), placa CPU 8 bits (II, PDF 93–104), placa de sonido general
(III), placa de drivers (IV), placa de relés (V), placa de display (VI) and placa de
alimentación de sonido (VII).

This is the only manual here for a machine whose ROMs are not fully dumped
([`../roms/related-machines/dona-elvira-2/`](../roms/related-machines/dona-elvira-2/)),
so it is what the archived Z80 image is read against. Its element table (page 60)
gives the board references: **C.P.U. 8 BITS `011-030`**, C.P.U. sonido general
`011-065`, drivers `011-027`, placa display y leds `011-064`, alimentación sonido
`011-067`, alimentación bobinas `011-028`. `011-030` is the same drawing family as
IO Moon's Z80 board `011-030A`, and the manual's schematic sheet carries document
number `011-030-01` at REV 3, dated August 10 1995 — the same sheet number as the
IO Moon copy the IC8 PAL16L8 pinout in
[`../docs/chips_to_dump.md`](../docs/chips_to_dump.md) is read from, with the same
pin assignment.

Three things the manual establishes about the machine itself:

- **It has no 16-bit CPU board.** The element table lists the complete electronics,
  and the *C.P.U. 8 BITS* is the game CPU — "Control, Audio, Video", and by §7.2.1
  all game functions, playfield and cabinet contacts, lamps and coils. Its principal
  components (§7.2.1.1) are IC1 a Z80A-6, IC5 a 27C256 labelled `DONA ELVIRA 2 V 1.1`,
  and the SW40 microswitch bank — the board the archived dump came off.
- **Sound is a second Z80 board.** §7.2.3.1: IC1 Z80B-6, IC41 an OKI 6376, and five
  EPROMs — IC5 `27C10` (`ELVSONO`) and IC42–IC45 `27C40` (`ELVSON1`–`ELVSON4`), the
  manual's own shorthand for the part numbers. It reaches the CPU board over J3/J28.
- **The display is 7-segment, not a DMD.** §7.2.4: HDSP 3901 and HDSP H101 digits
  driven from three 6331 bipolar PROMs at IC2/IC5/IC8.

The contact matrix (figure 7-2) is 4 scan lines × 8 return lines, codes `00`–`36`,
plus 8 direct cabinet inputs `80`–`87` (monedero, test, falta, FI, CFI, CFD, FD,
start) — a narrower matrix than IO Moon's 6 × 8.
