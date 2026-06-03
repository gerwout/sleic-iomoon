# YM3812 FM music extractor (`scripts/iomoon_fm_extract.py`)

[← Back to main README](../README.md)

Extracts the IO Moon **YM3812 (OPL2) FM music** from the 80188 code ROM
(`V1 3_01.bin`), driven by the in-ROM **song-index table** (no hard-coded
per-track offsets), and exports each track to raw register logs, standard
**VGM**, and/or **WAV** rendered through an offline OPL2 emulator.

This is the companion to [`extract_oki_msm6376.md`](extract_oki_msm6376.md): the
OKI MSM6376 carries **speech + sound effects**, while the YM3812 carries the
**music** (see [`z80_io_ports.md`](z80_io_ports.md) → "YM3812 routing" and
[`ym3812_pinmame_precedents.md`](ym3812_pinmame_precedents.md)).

## The music engine (re-derived from the 80188 disassembly)

Segment `CS = D000`, so a file offset = `0x50000 + Dxxxx`.

- **Song-pointer table** at `CS:0DE5` (file `0x50DE5`): **10** little-endian
  `uint16` offsets → **10 music tracks** (track 0 is a short all-notes-off init
  stub; tracks 6≡7 and 8≡9 are byte-identical pairs).
- **Sequencer** at `CS:0D37` (file `0x50D37`): per song pointer `SI`, it reads a
  byte pair `AH = cs:[si]; si++; AL = cs:[si]; si++` and dispatches on `AH`:

  | `AH` | meaning | operand |
  |---|---|---|
  | `0xEE` | set note-duration (`= AL × tempo`), ends this tick | `AL` |
  | `0xEF` | set tempo scale | `AL` |
  | `0xFF` | end of track | — |
  | `0xDD` | jump/loop: `SI = (next_byte << 8) \| AL` | `AL` + 1 byte |
  | else | **write YM3812 register `AH` := value `AL`** (index `0xA0280`, data `0xA0281`) | — |

- **Write primitive** at `CS:0D99` (file `0x50D99`): `mov es:[0280h],ah` →
  settling delay (`opl2_delay` `CS:0DA9`) → `mov es:[0281h],al` → settling delay.
  Index port first (`0xA0280`, A0=0), then data port (`0xA0281`, A0=1). The
  extractor replays writes in this exact ROM order; the busy-wait settling delay
  is a hardware bus-timing detail and has no effect on the emulated OPL2 result.
- The sequencer is **ticked from the DMD frame ISR**, not a free-running sound
  timer — see "Fidelity notes" for the rate.

Decoding all 10 tracks yields **zero invalid OPL2 registers** and ~510 KeyOn
events — the correctness proof for the opcode encoding.

## Usage

```bash
# all tracks -> raw logs + VGM files (correct clock/tempo are the defaults now)
python3 scripts/iomoon_fm_extract.py --rom "roms/1.3 IPDB latest/V1 3_01.bin" \
        --all --format raw vgm --out out

# one track -> WAV via the offline OPL2 emulator (needs pyopl)
python3 scripts/iomoon_fm_extract.py --rom "roms/1.3 IPDB latest/V1 3_01.bin" \
        --track 1 --format wav --out out
```

The hardware-correct **clock (4.0 MHz)** and **tick rate (72.5 Hz)** are now the
defaults — no flags needed. Key options: `--table-offset` (default `0x50DE5`),
`--seg-base` (default `0x50000`), `--count` (auto from the table), `--ym-clock`
(YM3812 φM; default `4000000` = the IO Moon YACLK; sets the VGM header **and**
corrects WAV pitch/envelope speed — the old `3579545` PC value is wrong),
`--tick-hz` (sequencer/music tick; default `72.5`; controls **tempo**),
`--wav-rate` (default `48000`), `--filter-hz` (reconstruction low-pass cutoff,
default `12000`), `--no-filter` (raw OPL2 output, no analog model).

## Fidelity notes

Earlier renders produced the *right tracks* but sounded "awkwardly different".
Three global parameters were wrong; the per-register data was always faithful.

### 1. YM3812 master clock = **4.0 MHz** (was 3.579545 MHz)

IC60's clock pin (φM) is fed **`YACLK` from the IC20 (74LS393) divider chain**
off the board's 8 MHz timing domain — it is **not** a 3.579545 MHz PC-soundcard
colorburst crystal (see [`board_011-029A_ics.md`](board_011-029A_ics.md) IC60 and
[`hardware_architecture.md`](hardware_architecture.md) "Clocking"). The YM3812's
φM ceiling is 4.0 MHz, and the only in-spec 74LS393 tap of 8 MHz is **8 MHz / 2 =
4.0 MHz** — which is also the standard pinball OPL2 clock and the value the
PinMAME `sleic.c` stub uses. Using 4.0 MHz instead of 3.579545 MHz raises pitch
by **+1.92 semitones** and speeds every FM envelope/LFO by **~11.7 %**. This is
the single biggest contributor to the wrong sound.

> Implementation note: PyOPL's DOSBox core *always* synthesises a 3.579545 MHz
> chip and resamples; you cannot move its pitch by changing the sample rate. The
> extractor renders at PyOPL's native 49716 Hz, then resamples the PCM by
> `3579545/clock` to shift pitch + envelope speed, while pre-compensating the
> tick scheduling so the musical tempo (set by `--tick-hz`) is preserved.

### 2. Music tick rate = **~72.5 Hz** (was 60 Hz)

The sequencer is serviced from the **DMD frame ISR** (`D000:0343` →
`call music_sequencer D000:0D1B`), **not** the sound timer ISR (`D000:024F`,
which calls `dmd_strobe_clear`, not the player). The frame ISR contains a 1-bit
toggle gate (`[1142h]`, `D0352`/`D0359`/`D037E`) so the player advances on
**every other** frame interrupt. The DMD wire-frame rate is **~145 Hz** (Saleae
capture, [`dmd_wire_protocol.md`](dmd_wire_protocol.md)); with **2 bitplanes per
visible frame** the player ticks once per visible frame ≈ **145 / 2 = 72.5 Hz**.
The old 60 Hz default made every track ~21 % too slow (`72.5/60 = 1.208×`).

### 3. Output reconstruction (YM3014B DAC + analog filter)

The raw OPL2 output is a harsh, aliased staircase. On hardware it passes through
the **YM3014B floating-point DAC (IC61)** and the board's analog reconstruction /
low-pass before reaching the amp (the **X9C503P digital pot, IC63**, sets the
FM-vs-OKI balance — a level, not a tone, control). The WAV path now models this
with a DC-block + a one-pole reconstruction low-pass (`--filter-hz`, default
12 kHz) and a −3 dBFS headroom/peak limiter so nothing clips. Use `--no-filter`
for the bare OPL2 timbre.

### Already correct — register-level handling

These were **not** bugs; the extractor replays the in-ROM `(register,value)`
stream verbatim through a real OPL2 core, so the OPL2 emulation honours all of:

- **Write order / inter-write delay** — index port then data port, exact ROM
  order; the hardware settling delay does not change the emulated result.
- **Key-on/off + block/fnum** — regs `0xA0–0xA8` / `0xB0–0xB8` (KON bit 5)
  replayed at their true ticks (~510 KeyOn edges across the 10 tracks).
- **Waveform select (WSE)** — the data writes `reg 0x01 = 0x20` (bit 5, WSE on)
  before the per-operator waveform regs `0xE0–0xF5`; the OPL2 core honours WSE.
- **Vibrato / tremolo** — `reg 0xBD` DAM/DVB depth bits and per-operator
  `0x20–0x35` AM/VIB bits are emulated by the OPL2 core from the replayed bytes.

## Dependencies

- `raw` and `vgm` export: Python standard library only.
- `wav` export: [`pyopl`](https://pypi.org/project/pyopl/) (the DOSBox OPL2 core),
  `pip install pyopl`. The script warns and continues if it is missing.
- The `0xDD` self-loop tracks are export-capped at one iteration (the loop target
  is recorded in the `.txt` header so a player can loop indefinitely).

## Verification

Rendered through PyOPL (DOSBox OPL2) at the corrected 4.0 MHz clock / 72.5 Hz
tick, track 1 produces a **~101 s** WAV with a real arranged structure (quiet
intro building to a full mix), confirming the music is genuine FM synthesis — not
OKI-sampled audio. A controlled single-note check confirms the clock correction
shifts a 520 Hz note to 580 Hz (+1.89 semitones, matching the 4.0/3.579545 ratio)
while leaving the track duration unchanged (tempo is set by `--tick-hz` and is
independent of the OPL2 clock). No track clips (peak ≤ −3 dBFS).
