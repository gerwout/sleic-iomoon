# 011-029A (16-bit / 80188 board) — IC inventory

[← Back to main README](../README.md)

<p align="center">
  <a href="../images/80188_board_011_029A.jpg" target="_blank" rel="noopener">
    <img src="../images/80188_board_011_029A_thumb.jpg" alt="011-029A 16-bit board — click for full resolution" width="900">
  </a>
  <br>
  <em>011-029A — 16-bit / 80188 CPU board. Click the image for the full 4096 × 3072 photograph.</em>
</p>

This is the complete list of integrated circuits populated on the IO Moon 16-bit CPU board (silkscreen `011-029A`), together with the function of each part. Identifications are based on direct readout of the chip top-marks plus public datasheets for the part numbers.

The Z80 / sound-driver board (`011-030A`) is documented separately.

## Summary by function

| Group | ICs | Purpose |
|-------|-----|---------|
| Main CPU & bus glue | IC1, IC2, IC3, IC4, IC5, IC6, IC7, IC8, IC35, IC43, IC44, IC47 | 80188 CPU, address/data demultiplex, chip-select decode, reset/supervisor. |
| Program / display ROM | IC10, IC11 | Two 27C040 EPROMs holding game code and DMD frames, mapped by the 80188. |
| RAM | IC12, IC33 | 32 K × 8 main work RAM (IC12) plus a small 2 K × 8 scratchpad (IC33). |
| NVRAM | IC14 | 28C64A EEPROM for operator settings and high scores. |
| DMD coprocessor | IC23 | PIC 16C57 microcontroller — raster-drives the DMD and (almost certainly) drives the YM3812 sound chip. |
| Glue / timing | IC20, IC21, IC22, IC24, IC30, IC31, IC34, IC40, IC46, IC50, IC56 | Counters, multiplexers, latches, NOR/OR gates, open-collector drivers. |
| Sound | IC51, IC52, IC53, IC60, IC61, IC62, IC63 | OKI ADPCM voice synth, OPL2 FM synth, DAC, op-amp, digital pot, sample ROMs. |

## Full IC list

| IC | Part | Package | Function |
|----|------|---------|----------|
| IC1  | AMD N80C188                  | PLCC-68 | Main 16-bit CPU. 80186-compatible, with integrated DMA, timers, interrupt controller and chip-select unit. |
| IC2  | TI SN74LS373N                | PDIP-20 | Octal D-type transparent latch. Demultiplexes the 80188 address/data bus (low-byte address latch). |
| IC3  | TI SN74LS244N                | PDIP-20 | Octal buffer / line driver, 3-state. |
| IC4  | TI SN74LS373N                | PDIP-20 | Octal D-type transparent latch. Companion to IC2. |
| IC5  | TI SN74LS245N                | PDIP-20 | Octal bus transceiver, 3-state. Data-bus buffer. |
| IC6  | Maxim MAX699                 | DIP-8   | Microprocessor supervisor: power-on reset, brownout detect, watchdog timeout, NVRAM write protect. |
| IC7  | AMD/MMI PAL20L10ACNS         | PDIP-24 | Programmable Array Logic — 80188 chip-select / bus glue. **Undumped** (see [`chips_to_dump.md`](chips_to_dump.md)). |
| IC8  | National DM74LS74AN          | PDIP-14 | Dual D-type positive-edge-triggered flip-flop with preset / clear. |
| IC10 | EPROM 27C040                 | PDIP-32 | First display / code ROM (512 KB). Mapped by the 80188 via LMCS. |
| IC11 | EPROM 27C040                 | PDIP-32 | Second display / code ROM (512 KB). |
| IC12 | UMC UM62256D-70LL            | PDIP-28 | 32 K × 8 CMOS SRAM, 70 ns. Main 80188 work RAM. |
| IC14 | Microchip 28C64A             | PDIP-28 | 8 K × 8 parallel EEPROM. NVRAM — operator settings, high scores. |
| IC20 | National DM74LS393N          | PDIP-14 | Dual 4-bit binary ripple counter. Part of the clock-divider chain. |
| IC21 | National DM74LS393N          | PDIP-14 | Dual 4-bit binary ripple counter. |
| IC22 | TI SN74LS27N                 | PDIP-14 | Triple 3-input NOR gate. |
| IC23 | Microchip PIC 16C57-HS/P     | PDIP-28 | DMD raster coprocessor and (almost certainly) YM3812 sound driver. 2048 × 12-bit OTP program memory, 72 bytes RAM, 20 I/O pins. **Undumped** (see [`chips_to_dump.md`](chips_to_dump.md)). |
| IC24 | TI SN74LS07N                 | PDIP-14 | Hex buffer / driver with open-collector outputs. Voltage-level translation / open-drain interfacing. |
| IC30 | TI SN74LS157N                | PDIP-16 | Quad 2-input data selector / multiplexer, non-inverting outputs. |
| IC31 | TI SN74LS157N                | PDIP-16 | Quad 2-input data selector / multiplexer. |
| IC33 | Goldstar GM76C28-10          | PDIP-24 | 2 K × 8 CMOS SRAM, 100 ns. Scratchpad memory (likely DMD / PIC workspace). |
| IC34 | TI CD74HC151E                | PDIP-16 | 8-to-1 data selector / multiplexer (HCMOS). |
| IC35 | TI SN74LS245N                | PDIP-20 | Octal bus transceiver, 3-state. |
| IC40 | TI SN74LS273N                | PDIP-20 | Octal D-type flip-flop with master reset. Output latch. |
| IC43 | TI SN74LS244N                | PDIP-20 | Octal buffer / line driver, 3-state. |
| IC44 | TI SN74LS244N                | PDIP-20 | Octal buffer / line driver, 3-state. |
| IC46 | TI SN7406N                   | PDIP-14 | Hex inverter buffer / driver with open-collector high-voltage outputs (30 V). |
| IC47 | National DM74LS32N           | PDIP-14 | Quad 2-input OR gate. |
| IC50 | TI SN74LS273N                | PDIP-20 | Octal D-type flip-flop with master reset. Output latch. |
| IC51 | OKI MSM6376                  | PDIP-42 | ADPCM voice / sample synthesiser. Driven by the Z80 via ports 0x80 / 0x81. |
| IC52 | EPROM 27C040                 | PDIP-32 | OKI sample ROM 1. |
| IC53 | EPROM 27C040                 | PDIP-32 | OKI sample ROM 2. |
| IC56 | TI SN74LS139AN               | PDIP-16 | Dual 2-to-4-line decoder / demultiplexer. |
| IC60 | Yamaha YM3812                | PDIP-24 | OPL2 FM synthesiser. 9 FM channels, 2 operators per channel. |
| IC61 | Yamaha YM3014B               | DIP-8   | Floating-point serial DAC. Companion to the YM3812 — converts the OPL2 serial output to analogue. |
| IC62 | GL324                        | PDIP-14 | Quad operational amplifier (LM324-class). Audio output buffering / filtering. |
| IC63 | Xicor X9C503P                | DIP-8   | Digitally controlled potentiometer, 100 wiper positions, 50 kΩ. Music balance / volume trim, written over a simple INC / U-D serial interface. |

## Programmable parts (firmware status)

| IC  | Part                   | Status                                                |
|-----|------------------------|-------------------------------------------------------|
| IC7  | PAL 20L10ACNS          | **Undumped.** See [`chips_to_dump.md`](chips_to_dump.md). |
| IC10 | EPROM 27C040           | Archived in [`../roms/1.3 IPDB latest/`](../roms/1.3%20IPDB%20latest/). |
| IC11 | EPROM 27C040           | Archived. |
| IC14 | EEPROM 28C64A          | Runtime-mutable NVRAM — contents are not a useful preservation artefact. |
| IC23 | PIC 16C57-HS/P         | **Undumped.** See [`chips_to_dump.md`](chips_to_dump.md). |
| IC52 | EPROM 27C040           | Archived. |
| IC53 | EPROM 27C040           | Archived. |
