# 011-030A (8-bit / Z80 board) — IC inventory

[← Back to main README](../README.md)

<p align="center">
  <a href="../images/z80-sleic-011-030A.jpg" target="_blank" rel="noopener">
    <img src="../images/z80-sleic-011-030A_thumb.jpg" alt="011-030A Z80 board — click for full resolution" width="900">
  </a>
  <br>
  <em>011-030A — 8-bit / Z80 I/O board. Click the image for the full 4096 × 3072 photograph.</em>
</p>

This is the complete list of integrated circuits populated on the IO Moon Z80 / I/O board (silkscreen `011-030A`), together with the function of each part. Identifications are based on direct readout of the chip top-marks plus public datasheets for the part numbers. The **Datasheet** column links to an offline copy of each part's datasheet under [`../datasheets/`](../datasheets/) (see the [datasheet catalogue](../datasheets/README.md) for sources and equivalent-part notes).

The 16-bit / 80188 board (`011-029A`) is documented separately in [`board_011-029A_ics.md`](board_011-029A_ics.md).

## Summary by function

| Group | ICs | Purpose |
|-------|-----|---------|
| CPU & memory | IC1, IC5, IC7 | Z80A CPU, 32 KB program ROM, 2 KB work RAM. |
| Address / I/O decode | IC8, IC16, IC17 | PAL chip-select decode plus two 74LS138 3-to-8 demuxes generating the per-peripheral selects for the Z80 memory and I/O ports 0x80–0x87. |
| Reset / watchdog | IC15, IC12, IC13 | Microprocessor supervisor (ADM699), 12-stage CMOS counter, 13-input NAND for terminal-count detect — together the hardware watchdog. |
| Bus glue | IC2, IC3, IC4, IC10, IC11, IC14 | Z80 address / data buffers, inverters and small flip-flop / NAND glue. |
| Output latches | IC20, IC24, IC40, IC50, IC52, IC54, IC56, IC60 | 74LS374 octal D flip-flops — lamp / solenoid / matrix-scan strobe registers written by the Z80 OUT instructions. |
| Input buffers | IC21, IC22, IC23, IC30, IC42, IC43, IC53, IC55, IC57, IC61 | 74LS244 octal buffers — switch matrix return, direct switches, DIP switches, driver status. |
| Open-collector drivers | IC25, IC26 | 7406 / 74LS06 hex inverters with open-collector high-voltage outputs for off-board signalling. |
| Power drivers | IC41, IC51 | ULN2803 Darlington arrays driving lamp / solenoid loads off the connector ribbons. |
| Analogue level sensing | IC31, IC32, IC44, IC45 | LM339-class quad voltage comparators reading switch returns / driver status with hysteresis. |

## Full IC list

| IC | Part | Package | Datasheet | Function |
|----|------|---------|-----------|----------|
| IC1  | Goldstar Z8400A PS           | PDIP-40 | [Z80 user manual](../datasheets/z80_cpu_user_manual.pdf) | Z80A 8-bit CPU, a 4 MHz-grade part. Scans the switch matrix and drives the lamp matrix and the two driver latches; it has no connection to either sound chip and forwards no sound commands. The 80188 owns the OKI MSM6376 (via the IC50 / IC40 latches) and the YM3812 (via `/PCS5`). The inter-board link is the **J1 byte-port** (one byte at a time, with handshakes and an interrupt in each direction) — there is no shared RAM. |
| IC2  | TI SN74LS244N                | PDIP-20 | [74ls244.pdf](../datasheets/74ls244.pdf) | Octal buffer / line driver, 3-state. Address / data bus buffer toward J3 (inter-board ribbon). |
| IC3  | TI SN74LS244N                | PDIP-20 | [74ls244.pdf](../datasheets/74ls244.pdf) | Octal buffer / line driver, 3-state. |
| IC4  | TI SN74LS245N                | PDIP-20 | [74ls245.pdf](../datasheets/74ls245.pdf) | Octal bus transceiver, 3-state. Data-bus buffer between the Z80 and the rest of the board. |
| IC5  | EPROM 27C256                 | PDIP-28 | [27c256.pdf](../datasheets/27c256.pdf) | Z80 program ROM (`1005 v1.2`, 32 KB). Maps to `0x0000`–`0x7FFF`. `/CE` ← `/ROM1` from IC8, `/OE` ← `/RD` (sheet 011-030-01). |
| IC6  | — (position for a 27C128)    | PDIP-28 | [27c256.pdf](../datasheets/27c256.pdf) | **Not populated on IO Moon.** The 011-030 family carries a second EPROM position here, a 27C128 on `/ROM2` with `/OE` ← `/RD`; it is in the family parts list but absent from this board. |
| IC7  | Goldstar GM76C28-10          | PDIP-24 | [gm76c28.pdf](../datasheets/gm76c28.pdf) | 2 K × 8 CMOS SRAM, 100 ns. Z80 working RAM at `0xC000`–`0xC7FF`. |
| IC8  | AMD PAL16L8A-2CN             | PDIP-20 | [PAL handbook](../datasheets/pal20l10_pal16l8_mmi_pal_handbook_1983.pdf) | Programmable Array Logic — Z80 memory and I/O decode. Inputs (sheet 011-030-01): `/M1`, `/MREQ`, `/IOREQ`, `/PWR`, `/PRD`, `A15`, `A14`, `A13`, `A12`, `A7`. Outputs: `/ROM1` (12, IC5 `/CE`), `/ROM2` (13, the vacant IC6), `/RI` (14, clears the interrupt latch), `/CEI` (15, IC16 enable), `/RAM` (16, becomes IC7's `/CRAM`), `/CEO` (17, IC17 enable), `/WR` (18), `/RD` (19). **Dumped** — the bench read makes it a bus-cycle decoder: it supplies the I/O-read and I/O-write enables and the interrupt acknowledge, and no memory chip select, with `A13`, `A12` and `A7` reaching no output. So the `/ROM1`, `/RAM`, `/WR` and `/RD` roles the symbol shows are driven from elsewhere on the board. [`../roms/PAL16L8/`](../roms/PAL16L8/). |
| IC10 | TI SN74LS04N                 | PDIP-14 | [74ls04.pdf](../datasheets/74ls04.pdf) | Hex inverter. |
| IC11 | National DM74LS74AN          | PDIP-14 | [74ls74a.pdf](../datasheets/74ls74a.pdf) | Dual D-type positive-edge-triggered flip-flop with preset / clear. |
| IC12 | National CD4040BCN           | PDIP-16 | [cd4040b.pdf](../datasheets/cd4040b.pdf) | 12-stage CMOS ripple-carry binary counter — the **periodic-interrupt timer**, not a watchdog. `CLK` ← `ZCLK`, `RST` tied to ground, so it free-runs and is never cleared; all twelve outputs `Q1`-`Q12` go to IC13 (sheet 011-030-02). With `ZCLK` = 2 MHz that is one terminal count every 4096 clocks = **488.28 Hz**. |
| IC13 | SGS T74LS133B1               | PDIP-16 | [74hc133.pdf](../datasheets/74hc133.pdf) | Single 13-input NAND gate. Decodes IC12's terminal count — twelve inputs from `Q1`-`Q12`, the thirteenth tied high — so its output pulses low once every 4096 `ZCLK` cycles and **sets the Z80's interrupt latch** through IC14B. It has no path to IC15 and is not part of the watchdog. (Linked HC133 sheet documents the identical 13-input NAND function/pinout.) |
| IC14 | National DM74LS00N           | PDIP-14 | [74ls00.pdf](../datasheets/74ls00.pdf) | Quad 2-input NAND gate, doing two jobs (sheet 011-030-02). **A and B** are cross-coupled into an SR latch: IC13's terminal-count pulse sets it and its output is the Z80's `/INT`; IC8's `/RI` resets it. **C and D** gate IC8's `/RAM` with the supervisor's `WATCH` line to produce `/CRAM`, IC7's chip enable — so the work RAM is deselected whenever that line is low. |
| IC15 | Analog Devices ADM699AN      | DIP-8   | [adm699.pdf](../datasheets/adm699.pdf) | Microprocessor supervisor: power-on reset, brownout detect, watchdog timeout input. Pin- and function-compatible with the Maxim MAX699. Its `WDI` takes the `WATCH` net, pulled up by R13 (1 k); that same net gates IC7's chip enable through IC14C/D. This is the board's only watchdog — IC12/IC13 are the interrupt timer. |
| IC16 | TI SN74LS138N                | PDIP-16 | [74ls138.pdf](../datasheets/74ls138.pdf) | 3-to-8 line decoder. The **input**-port decoder: `A`/`B`/`C` ← `A0`-`A2`, `G1` tied high, `G2A` ← `A7`, `G2B` ← `/CEI` from IC8. Only `Y0`-`Y4` are wired, as `I0`-`I4` — so the board decodes **exactly five input ports, `0x00`-`0x04`**, which is the whole of finding F5's IN list with nothing spare. |
| IC17 | TI SN74LS138N                | PDIP-16 | [74ls138.pdf](../datasheets/74ls138.pdf) | 3-to-8 line decoder. The **output**-port decoder: `A`/`B`/`C` ← `A0`-`A2`, `G1` ← `A7`, `G2A` and `G2B` tied together on `/CEO` from IC8. All eight outputs `Y0`-`Y7` are wired as `O0`-`O7` — so the board decodes **exactly eight output ports, `0x80`-`0x87`**, which is the whole of finding F7's OUT list with nothing spare. |
| IC20 | TI SN74LS374N                | PDIP-20 | [74ls374.pdf](../datasheets/74ls374.pdf) | Octal D-type flip-flop with 3-state outputs. Output latch — one of the lamp / solenoid / scan registers. |
| IC21 | TI SN74LS244N                | PDIP-20 | [74ls244.pdf](../datasheets/74ls244.pdf) | Octal buffer / line driver, 3-state. Switch return / status read buffer. |
| IC22 | TI SN74LS244N                | PDIP-20 | [74ls244.pdf](../datasheets/74ls244.pdf) | Octal buffer / line driver, 3-state. |
| IC23 | TI SN74LS244N                | PDIP-20 | [74ls244.pdf](../datasheets/74ls244.pdf) | Octal buffer / line driver, 3-state. |
| IC24 | TI SN74LS374N                | PDIP-20 | [74ls374.pdf](../datasheets/74ls374.pdf) | Octal D-type flip-flop, 3-state. Output latch. |
| IC25 | TI SN7406N                   | PDIP-14 | [7406.pdf](../datasheets/7406.pdf) | Hex inverter buffer / driver with open-collector high-voltage outputs (30 V). |
| IC26 | TI SN74LS06N                 | PDIP-14 | [74ls06.pdf](../datasheets/74ls06.pdf) | Hex inverter buffer / driver with open-collector high-voltage outputs (LS variant). |
| IC30 | TI SN74LS244N                | PDIP-20 | [74ls244.pdf](../datasheets/74ls244.pdf) | Octal buffer / line driver, 3-state. |
| IC31 | Goldstar GL339               | PDIP-14 | [lm339.pdf](../datasheets/lm339.pdf) | Quad voltage comparator (LM339-class) with open-collector outputs. Switch return / driver status level sensing. |
| IC32 | Goldstar GL339               | PDIP-14 | [lm339.pdf](../datasheets/lm339.pdf) | Quad voltage comparator. |
| IC40 | TI SN74LS374N                | PDIP-20 | [74ls374.pdf](../datasheets/74ls374.pdf) | Octal D-type flip-flop, 3-state. Output latch. |
| IC41 | Toshiba ULN2803G             | PDIP-18 | [uln2803a.pdf](../datasheets/uln2803a.pdf) | 8-channel Darlington transistor array (50 V / 500 mA per channel). Lamp / solenoid current driver. |
| IC42 | TI SN74LS244N                | PDIP-20 | [74ls244.pdf](../datasheets/74ls244.pdf) | Octal buffer / line driver, 3-state. |
| IC43 | TI SN74LS244N                | PDIP-20 | [74ls244.pdf](../datasheets/74ls244.pdf) | Octal buffer / line driver, 3-state. |
| IC44 | Goldstar GL339               | PDIP-14 | [lm339.pdf](../datasheets/lm339.pdf) | Quad voltage comparator. |
| IC45 | Goldstar GL339               | PDIP-14 | [lm339.pdf](../datasheets/lm339.pdf) | Quad voltage comparator. |
| IC50 | TI SN74LS374N                | PDIP-20 | [74ls374.pdf](../datasheets/74ls374.pdf) | Octal D-type flip-flop, 3-state. Output latch. |
| IC51 | Allegro ULN2803A             | PDIP-18 | [uln2803a.pdf](../datasheets/uln2803a.pdf) | 8-channel Darlington transistor array. Second lamp / solenoid current driver. |
| IC52 | TI SN74LS374N                | PDIP-20 | [74ls374.pdf](../datasheets/74ls374.pdf) | Octal D-type flip-flop, 3-state. Output latch. |
| IC53 | TI SN74LS244N                | PDIP-20 | [74ls244.pdf](../datasheets/74ls244.pdf) | Octal buffer / line driver, 3-state. |
| IC54 | TI SN74LS374N                | PDIP-20 | [74ls374.pdf](../datasheets/74ls374.pdf) | Octal D-type flip-flop, 3-state. Output latch. |
| IC55 | TI SN74LS244N                | PDIP-20 | [74ls244.pdf](../datasheets/74ls244.pdf) | Octal buffer / line driver, 3-state. |
| IC56 | TI SN74LS374N                | PDIP-20 | [74ls374.pdf](../datasheets/74ls374.pdf) | Octal D-type flip-flop, 3-state. Output latch. |
| IC57 | TI SN74LS244N                | PDIP-20 | [74ls244.pdf](../datasheets/74ls244.pdf) | Octal buffer / line driver, 3-state. |
| IC60 | TI SN74LS374N                | PDIP-20 | [74ls374.pdf](../datasheets/74ls374.pdf) | Octal D-type flip-flop, 3-state. Output latch. |
| IC61 | TI SN74LS244N                | PDIP-20 | [74ls244.pdf](../datasheets/74ls244.pdf) | Octal buffer / line driver, 3-state. |

Eight 74LS374 latches × 8 bits = 64 bits of output across lamps, solenoids and matrix-scan strobes. Twelve 74LS244 buffers × 8 bits = 96 bits of input across the switch matrix, DIP switches, direct switches and driver-status returns.

## Programmable parts (firmware status)

| IC  | Part            | Status                                                |
|-----|-----------------|-------------------------------------------------------|
| IC5 | EPROM 27C256 ([datasheet](../datasheets/27c256.pdf)) | Archived as `v1_3_05.bin` in [`../roms/1.3 IPDB latest/`](../roms/1.3%20IPDB%20latest/). |
| IC8 | PAL16L8A-2CN ([datasheet](../datasheets/pal20l10_pal16l8_mmi_pal_handbook_1983.pdf)) | **Undumped.** See [`chips_to_dump.md`](chips_to_dump.md). |

`0x8000`–`0xBFFF` is the IC6 expansion-ROM window. The inspected board carries no IC6 chip at that position — the socket is either vacant or absent on this revision — and no Z80 code reads the range.
