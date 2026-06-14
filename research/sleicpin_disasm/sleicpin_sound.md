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

Open: YM3812 clock left at the shared 4 MHz (`SLEIC_ym3812_intf`); confirm the
sleicpin crystal and tune if the pitch/tempo is off. OKI voice/channel from PCS0 bit3
not yet distinguished (uses the shared `sleic_oki_trigger`).
