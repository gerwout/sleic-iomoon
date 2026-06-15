# Sleic Pin-Ball — sound (YM3812 FM + OKI MSM6376), confirmed vs sp03

The **80188 drives both sound chips** (sp03 game/sound code). Confirmed against the
assembler, with Bike Race as a reference but verified independently.

## YM3812 (Yamaha OPL2 — FM music)

- Port: **`0xA0280` (PCS5)** — register **and** data both go to this single address.
- Register-vs-data select = **`0xA0000` (PCS0) bit 1** (the A0 line): bit1=0 → register
  /index, bit1=1 → data.  The FM write primitive (sp03 file `0x1E5E`):
  ```
  and [0x4da],0xfd ; out 0xA0000   ; A0 = 0
  mov [es:0x280],ah                ; register #
  <settling delay>
  or  [0x4da],0x02 ; out 0xA0000   ; A0 = 1
  mov [es:0x280],al                ; data
  ```
  This differs from **IO Moon** (which uses two addresses 0x280/0x281) and from
  **Bike Race** (which simply alternates A0 per write).
- Driven by an FM sequencer (sp03 `0x1E05`) walking `(register,value)` opcode streams
  with control bytes `0xEE` (duration), `0xEF` (tempo), `0xFF` (end); ticked from a
  timer ISR. Silent in attract; plays during a game.

## OKI MSM6376 (ADPCM — speech / FX)

- Phrase latch: **`0xA0300` (PCS6)** = the phrase number (sp03 `0x1B36`/`0x1B47`,
  value from `[0x27d]`, e.g. `0x31`).
- `/OKCS` strobe: **`0xA0000` (PCS0) bit 4 (0x10)** pulsed clear→set; the rising edge
  starts the latched phrase (sp03 `0x1B6B`). Channel select = PCS0 bit 3 (0x08).
- Same trigger model as Bike Race (PCS6 latch + PCS0 bit-4 edge). Sample ROM = sp02
  in `REGION_USER1`.

## PCS0 vs PCS4 (important)

`0xA0000` (PCS0, shadow `[0x4da]`, init `0xFC` at sp03 `0x1DD56`) carries the **sound**
control bits (YM A0 = bit1, OKI strobe = bit4, OKI channel = bit3).  The **DMD** frame
strobe is a *separate* select, `0xA0200` (PCS4, shadow `[0x4de]`) — so routing sound
through PCS0 does not interfere with the DMD (which the I8039 renders from `0x60410`).

## PinMAME wiring (driver) + verification

`pinmame/src/wpc/sleic.c` `sleic1_periph_w`: PCS5 → `YM3812_control/write_port_0_w`
(per `sleic1_ym_a0` = PCS0 bit1), PCS6 → OKI phrase latch, PCS0 bit4 edge →
`sleic_oki_trigger`. Verified headless (`SLEIC_TRACE_SND` + `SLEIC_AUTOSTART`):
- YM3812: **942** register/data writes in-game with a correct OPL2 register pattern
  (`0x20-0x35` EG, `0x40-0x55` levels, `0x60-0x75` AD, `0x80-0x95` SR, `0xA0-0xB8`
  freq/key-on, `0xC0-0xC6` fb, `0xE0-0xED` waveform, `0xBD` rhythm) — reg/data
  alternation correct.
- OKI: **11** phrase triggers (`0x16/0x19/0x2f/0x31/0x3f`).

## YM3812 clock crystal (XTAL3)

**Sleic Pin-Ball has a DEDICATED sound-section crystal `XTAL3`** on the 16-bit CPU
board — confirmed from the service manual FIGURA 22 (p.63): a crystal oscillator
(`XTAL3` + load caps `C24`/`C25` + feedback `R21`) sitting among IC41 (YM3812),
IC42 (EEPOT), IC46 (OKI), IC43 (YM3014 DAC).  This differs from **IO Moon**, whose
YM3812 φM is derived from the main 74LS393 divider (no dedicated sound crystal).
The board also has XTAL1 (top, main CPU) and XTAL2 (middle).  The manual is
"no schematics" and the layout shows crystal *positions* but **not** frequency
values, so XTAL3's exact frequency is not documented.

**Confirming the driver's 4 MHz:** the driver uses YM3812 = 4 MHz and OKI = 2 MHz.
The OKI being exactly half constrains XTAL3:
- XTAL3 = **8 MHz** → YM3812 = 8/2 = **4 MHz**, OKI = 8/4 = 2 MHz (both clean) ✓
- XTAL3 = **4 MHz** → YM3812 = **4 MHz** (direct), OKI = 4/2 = 2 MHz (both clean) ✓
- XTAL3 = 3.579545 MHz (the usual OPL2 colorburst) → YM3812 = 3.58 MHz, but OKI = 2 MHz
  would not divide cleanly ✗ (unlikely).

Both plausible XTAL3 values give **YM3812 = 4 MHz**, which is also the OPL2 φM ceiling
and the IO Moon value — so **the current 4 MHz is most likely correct** (no change).
The in-game FM register stream verified earlier is a correct OPL2 pattern at this clock.
**To be 100% sure, read the XTAL3 marking on the physical 16-bit board** (it will say
e.g. `8.000` or `4.000`); only a 3.579545 MHz part would change the value.

Open: OKI voice/channel from PCS0 bit3 not yet distinguished (uses the shared
`sleic_oki_trigger`, voice 2).
