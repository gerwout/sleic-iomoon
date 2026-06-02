# Component datasheets

[← Back to main README](../README.md)

Local, offline copies of the manufacturer datasheets for every integrated
circuit identified on the IO Moon boards. They are bundled here so the
reverse-engineering notes can be read (and verified) without chasing
part numbers across the web — the board IC inventories
([`../docs/board_011-029A_ics.md`](../docs/board_011-029A_ics.md),
[`../docs/board_011-030A_ics.md`](../docs/board_011-030A_ics.md)) link
straight into these PDFs.

All files are vendor PDFs collected for **educational and preservation
purposes**. Copyright remains with the respective manufacturers
(Intel/AMD, Zilog, Microchip, Yamaha, OKI, STMicroelectronics, Texas
Instruments, Analog Devices/Maxim, Renesas/Intersil/Xicor, etc.). The
"Source" column records where each file was retrieved.

## Notes on substitutions

A few parts are documented by a functionally identical equivalent rather
than the exact silkscreen marking, because the original vendor PDF is no
longer published in a directly downloadable form. These are JEDEC-standard
or pin/function-compatible parts with the same pinout and behaviour:

| Board part | Datasheet used | Why it is equivalent |
|---|---|---|
| UMC `UM62256D-70LL` (IC12, 011-029A) | [`62256_generic_as6c62256.pdf`](62256_generic_as6c62256.pdf) (Alliance Memory AS6C62256) | Industry-standard JEDEC `62256` 32 K × 8 SRAM — identical 28-pin pinout and function. The UMC-branded PDF survives only on JS-gated aggregators. |
| SGS `T74LS133B1` (IC13, 011-030A) | [`74hc133.pdf`](74hc133.pdf) (74HC133) | Same single 13-input NAND, same DIP-16 pinout. An LS-family-specific 133 PDF was not directly downloadable; the HC sheet documents the identical logic/pinout. |
| National `DM74LSxx`, SGS `T74LSxx` markings | TI `SN74LSxx` sheets | The `74LSxx` logic family is second-sourced; the TI datasheet documents the same function, truth table and pinout regardless of the maker's prefix (`DM`, `SN`, `T`, `M`). |
| Goldstar `GL324` / `GL339` | TI [`lm324.pdf`](lm324.pdf) / [`lm339.pdf`](lm339.pdf) | `GLxxx` are LG/Goldstar second sources of the industry-standard LM324 quad op-amp and LM339 quad comparator. |
| Microchip `28C64A` (IC14) | [`28c64a.pdf`](28c64a.pdf) (Atmel AT28C64) | Atmel was acquired by Microchip; this is the same 8 K × 8 parallel EEPROM family. |

## Catalogue

### CPUs / microcontrollers

| File | Part(s) documented | Used at | Source |
|---|---|---|---|
| [`80c188.pdf`](80c188.pdf) | Intel 80186/80188 (covers AMD N80C188) | IC1 (011-029A) | [datasheets.chipdb.org](https://datasheets.chipdb.org/Intel/x86/8018x/datashts/27243002.PDF) |
| [`z80_cpu_user_manual.pdf`](z80_cpu_user_manual.pdf) | Zilog Z80 CPU User Manual (Z8400/Z84C00) | IC1 (011-030A) | [bitsavers.org](https://www.bitsavers.org/components/zilog/z80/UM008003-1202_Z80_CPU_Users_Manual_2002.pdf) |
| [`pic16c5x.pdf`](pic16c5x.pdf) | Microchip PIC16C5X (16C54/16C56/16C57) | IC23 (011-029A) | [ww1.microchip.com](https://ww1.microchip.com/downloads/en/DeviceDoc/30453e.pdf) |

### Sound

| File | Part(s) documented | Used at | Source |
|---|---|---|---|
| [`ym3812.pdf`](ym3812.pdf) | Yamaha YM3812 (OPL2) FM synthesiser | IC60 (011-029A) | [ardent-tool.com](https://www.ardent-tool.com/datasheets/Yamaha_YM3812.pdf) |
| [`ym3812_opl2_application_manual.pdf`](ym3812_opl2_application_manual.pdf) | Yamaha YM3812 OPL2 Application Manual (programming) | IC60 (011-029A) | [c64.xentax.com](https://c64.xentax.com/images/LSI-2438124-Yamaha-YM3812-OPL2-Application-Manual.pdf) |
| [`ym3014b.pdf`](ym3014b.pdf) | Yamaha YM3014B serial floating-point DAC | IC61 (011-029A) | [bitsavers.org](http://www.bitsavers.org/components/yamaha/YM3014B_199403.pdf) |
| [`msm6376_oki_voice_synthesis_databook_1994.pdf`](msm6376_oki_voice_synthesis_databook_1994.pdf) | OKI MSM6376 ADPCM voice synth (in the 1994 OKI Voice Synthesis ICs data book) | IC51 (011-029A) | [bitsavers.org](https://www.bitsavers.org/components/oki/_dataBooks/1994_OKI_Voice_Synthesis_ICs.pdf) |

### Memory

| File | Part(s) documented | Used at | Source |
|---|---|---|---|
| [`27c040.pdf`](27c040.pdf) | ST M27C4001 4 Mbit (512 K × 8) EPROM (= 27C040) | IC10, IC11, IC52, IC53 (011-029A) | [farnell.com](https://www.farnell.com/datasheets/7903.pdf) |
| [`27c256.pdf`](27c256.pdf) | ST M27C256B 256 Kbit (32 K × 8) EPROM | IC5 (011-030A) | [farnell.com](https://www.farnell.com/datasheets/34221.pdf) |
| [`62256_generic_as6c62256.pdf`](62256_generic_as6c62256.pdf) | 62256 32 K × 8 SRAM (Alliance AS6C62256, std. pinout for UMC UM62256) | IC12 (011-029A) | [alliancememory.com](https://www.alliancememory.com/datasheets/as6c62256/) |
| [`gm76c28.pdf`](gm76c28.pdf) | Goldstar GM76C28A 2 K × 8 CMOS SRAM | IC33 (011-029A), IC7 (011-030A) | [silicon-ark.co.uk](https://www.silicon-ark.co.uk/datasheets/gm76c28a-datasheet-gs.pdf) |
| [`28c64a.pdf`](28c64a.pdf) | Atmel AT28C64 8 K × 8 parallel EEPROM (= Microchip 28C64A) | IC14 (011-029A) | [ww1.microchip.com](https://ww1.microchip.com/downloads/en/devicedoc/doc0270.pdf) |

### Programmable logic (PALs — undumped on the board)

| File | Part(s) documented | Used at | Source |
|---|---|---|---|
| [`pal20l10_pal16l8_mmi_pal_handbook_1983.pdf`](pal20l10_pal16l8_mmi_pal_handbook_1983.pdf) | MMI PAL Handbook (3rd ed.) — covers PAL20L10 and PAL16L8 | IC7 (011-029A), IC8 (011-030A) | [bitsavers.org](https://www.bitsavers.org/components/mmi/_dataBooks/1983_MMI_PAL_Handbook_3ed.pdf) |

### Power supervision / supervisors

| File | Part(s) documented | Used at | Source |
|---|---|---|---|
| [`max699.pdf`](max699.pdf) | Maxim MAX698/MAX699 reset + watchdog controller | IC6 (011-029A) | [analog.com via Wayback](https://web.archive.org/web/2id_/https://www.analog.com/media/en/technical-documentation/data-sheets/max698-max699.pdf) |
| [`adm699.pdf`](adm699.pdf) | Analog Devices ADM698/ADM699 supervisory circuit | IC15 (011-030A) | [analog.com via Wayback](https://web.archive.org/web/2id_/https://www.analog.com/media/en/technical-documentation/data-sheets/ADM698_699.pdf) |

### Analogue

| File | Part(s) documented | Used at | Source |
|---|---|---|---|
| [`lm324.pdf`](lm324.pdf) | LM324 quad op-amp (= Goldstar GL324) | IC62 (011-029A) | [ti.com](https://www.ti.com/lit/ds/symlink/lm324.pdf) |
| [`lm339.pdf`](lm339.pdf) | LM339 quad comparator (= Goldstar GL339) | IC31/IC32/IC44/IC45 (011-030A) | [ti.com](https://www.ti.com/lit/ds/symlink/lm339.pdf) |
| [`x9c503.pdf`](x9c503.pdf) | Xicor X9C102/103/104/503 digitally-controlled potentiometer | IC63 (011-029A) | [farnell.com](https://www.farnell.com/datasheets/18974.pdf) |

### Power drivers

| File | Part(s) documented | Used at | Source |
|---|---|---|---|
| [`uln2803a.pdf`](uln2803a.pdf) | ULN2803A 8-channel Darlington array | IC41/IC51 (011-030A) | [ti.com](https://www.ti.com/lit/ds/symlink/uln2003a.pdf) |

### 74-series logic & counters

| File | Part(s) documented | Used at | Source |
|---|---|---|---|
| [`74ls373.pdf`](74ls373.pdf) | SN74LS373 octal transparent latch | IC2, IC4 (011-029A) | [ti.com](https://www.ti.com/lit/ds/symlink/sn74ls373.pdf) |
| [`74ls374.pdf`](74ls374.pdf) | SN74LS374 octal D flip-flop | IC20/24/40/50/52/54/56/60 (011-030A) | [ti.com](https://www.ti.com/lit/ds/symlink/sn74ls374.pdf) |
| [`74ls244.pdf`](74ls244.pdf) | SN74LS244 octal buffer/line driver | IC3/35/43/44 (011-029A); many (011-030A) | [ti.com](https://www.ti.com/lit/ds/symlink/sn74ls244.pdf) |
| [`74ls245.pdf`](74ls245.pdf) | SN74LS245 octal bus transceiver | IC5 (011-029A); IC4 (011-030A) | [ti.com](https://www.ti.com/lit/ds/symlink/sn74ls245.pdf) |
| [`74ls273.pdf`](74ls273.pdf) | SN74LS273 octal D flip-flop w/ reset | IC40, IC50 (011-029A) | [ti.com](https://www.ti.com/lit/ds/symlink/sn74ls273.pdf) |
| [`74ls74a.pdf`](74ls74a.pdf) | SN74LS74A dual D flip-flop | IC8 (011-029A); IC11 (011-030A) | [ti.com](https://www.ti.com/lit/ds/symlink/sn74ls74a.pdf) |
| [`74ls393.pdf`](74ls393.pdf) | SN74LS393 dual 4-bit ripple counter | IC20, IC21 (011-029A) | [ti.com](https://www.ti.com/lit/ds/symlink/sn74ls393.pdf) |
| [`74ls27.pdf`](74ls27.pdf) | SN74LS27 triple 3-input NOR | IC22 (011-029A) | [ti.com](https://www.ti.com/lit/ds/symlink/sn74ls27.pdf) |
| [`74ls07.pdf`](74ls07.pdf) | SN74LS07 hex buffer, open-collector | IC24 (011-029A) | [ti.com](https://www.ti.com/lit/ds/symlink/sn74ls07.pdf) |
| [`74ls157.pdf`](74ls157.pdf) | SN74LS157 quad 2:1 multiplexer | IC30, IC31 (011-029A) | [ti.com](https://www.ti.com/lit/ds/symlink/sn74ls157.pdf) |
| [`74hc151.pdf`](74hc151.pdf) | CD74HC151 8:1 multiplexer | IC34 (011-029A) | [ti.com](https://www.ti.com/lit/ds/symlink/cd74hc151.pdf) |
| [`7406.pdf`](7406.pdf) | SN7406 hex inverter, open-collector 30 V | IC46 (011-029A); IC25 (011-030A) | [ti.com](https://www.ti.com/lit/ds/symlink/sn7406.pdf) |
| [`74ls06.pdf`](74ls06.pdf) | SN74LS06 hex inverter, open-collector | IC26 (011-030A) | [ti.com](https://www.ti.com/lit/ds/symlink/sn74ls06.pdf) |
| [`74ls32.pdf`](74ls32.pdf) | SN74LS32 quad 2-input OR | IC47 (011-029A) | [ti.com](https://www.ti.com/lit/ds/symlink/sn74ls32.pdf) |
| [`74ls00.pdf`](74ls00.pdf) | SN74LS00 quad 2-input NAND | IC14 (011-030A) | [ti.com](https://www.ti.com/lit/ds/symlink/sn74ls00.pdf) |
| [`74ls04.pdf`](74ls04.pdf) | SN74LS04 hex inverter | IC10 (011-030A) | [ti.com](https://www.ti.com/lit/ds/symlink/sn74ls04.pdf) |
| [`74ls138.pdf`](74ls138.pdf) | SN74LS138 3:8 decoder | IC16, IC17 (011-030A) | [ti.com](https://www.ti.com/lit/ds/symlink/sn74ls138.pdf) |
| [`74ls139a.pdf`](74ls139a.pdf) | SN74LS139A dual 2:4 decoder | IC56 (011-029A) | [ti.com](https://www.ti.com/lit/ds/symlink/sn74ls139a.pdf) |
| [`74hc133.pdf`](74hc133.pdf) | 74HC133 13-input NAND (= SGS T74LS133 function) | IC13 (011-030A) | [edutek.ltd.uk](https://www.edutek.ltd.uk/Binaries/Datasheets/7400/74HC133.pdf) |
| [`cd4040b.pdf`](cd4040b.pdf) | CD4040B 12-stage ripple counter | IC12 (011-030A) | [ti.com](https://www.ti.com/lit/ds/symlink/cd4040b.pdf) |

### Candidate parts — driver board 011-027A (UNCONFIRMED)

The driver board (`011-027A`) carries a bank of TO-220 power semiconductors and
two heatsink-mounted linear regulators whose exact part numbers were **not
legible** from the board photos. `../research/board_inventory.md` lists the
*likely* families. The `candidate_*` files below are datasheets for those
candidate families, provided so a technician can cross-check against the
physical markings — **they are not confirmed identifications**.

| File | Candidate part | Likely role | Source |
|---|---|---|---|
| [`candidate_tip122.pdf`](candidate_tip122.pdf) | TIP120/121/**122** NPN Darlington | Lamp / solenoid power switch | [onsemi via Wayback](https://web.archive.org/web/2id_/https://www.onsemi.com/pdf/datasheet/tip120-d.pdf) |
| [`candidate_bd679.pdf`](candidate_bd679.pdf) | **BD679** Darlington (BD6xx family) | Lamp / solenoid power switch | [st.com via Wayback](https://web.archive.org/web/2id_/https://www.st.com/resource/en/datasheet/bd679.pdf) |
| [`candidate_2n6040.pdf`](candidate_2n6040.pdf) | **2N6040** (2N6038–2N6049 Darlington family, incl. 2N6044) | Lamp / solenoid power switch | provided manually (2N6044-family equivalent) |
| [`candidate_lm7805.pdf`](candidate_lm7805.pdf) | LM7805 / LM340 +5 V regulator | TO-220 linear regulator | [ti.com](https://www.ti.com/lit/ds/symlink/lm340.pdf) |
| [`candidate_lm317.pdf`](candidate_lm317.pdf) | LM317 adjustable regulator | TO-220 linear regulator | [ti.com](https://www.ti.com/lit/ds/symlink/lm317.pdf) |
