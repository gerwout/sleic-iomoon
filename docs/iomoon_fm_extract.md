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
  settling delay → `mov es:[0281h],al`. The sequencer is ticked once per frame.

Decoding all 10 tracks yields **zero invalid OPL2 registers** and ~510 KeyOn
events — the correctness proof for the opcode encoding.

## Usage

```bash
# all tracks -> raw logs + VGM files
python3 scripts/iomoon_fm_extract.py --rom "roms/1.3 IPDB latest/V1 3_01.bin" \
        --all --format raw vgm --out out

# one track -> WAV via the offline OPL2 emulator (needs pyopl)
python3 scripts/iomoon_fm_extract.py --rom "roms/1.3 IPDB latest/V1 3_01.bin" \
        --track 1 --format wav --ym-clock 4000000 --tick-hz 60 --out out
```

Key options: `--table-offset` (default `0x50DE5`), `--seg-base` (default
`0x50000`), `--count` (auto from the table), `--ym-clock` (VGM header; default
`3579545`, the board uses ~`4000000`), `--tick-hz` (frame/tick rate — only the
**tempo** depends on it; pitch is absolute from Fnum/Block).

## Dependencies

- `raw` and `vgm` export: Python standard library only.
- `wav` export: [`pyopl`](https://pypi.org/project/pyopl/) (the DOSBox OPL2 core),
  `pip install pyopl`. The script warns and continues if it is missing.
- The `0xDD` self-loop tracks are export-capped at one iteration (the loop target
  is recorded in the `.txt` header so a player can loop indefinitely).

## Verification

Rendered through PyOPL (DOSBox OPL2), track 1 produces a ~122 s WAV with a real
arranged structure (quiet intro building to a full mix), confirming the music is
genuine FM synthesis — not OKI-sampled audio.
