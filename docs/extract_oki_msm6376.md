# OKI MSM6376 Sound Extractor — `extract-oki-msm6376.py`

[← Back to main README](../README.md)

## Overview

`extract-oki-msm6376.py` extracts individual ADPCM audio samples from ROM files used with the **OKI MSM6376** speech synthesizer chip (datasheet: [`../datasheets/msm6376_oki_voice_synthesis_databook_1994.pdf`](../datasheets/msm6376_oki_voice_synthesis_databook_1994.pdf) — the 1994 OKI Voice Synthesis ICs data book). The MSM6376 stores audio in **4-bit IMA/OKI ADPCM** format, a lossy audio compression scheme common in mid-1990s arcade and gambling hardware.

This chip is used in:

- **SLEIC pinball machines** (IO Moon, Bike Race, Pinball)
- **Maygay gambling/fruit machines**
- Various other arcade and amusement devices from the mid-1990s

The script reads the chip's internal sample address index from the beginning of the ROM, locates each individual audio sample, extracts the raw ADPCM data, and optionally converts each sample to a standard WAV file using FFmpeg.

> **Note:** This script was originally published as a standalone repository at [gerwout/extract-oki-adpcm-from-rom](https://github.com/gerwout/extract-oki-adpcm-from-rom). That repository is now **deprecated** in favor of this unified IO Moon repository.

---

## Requirements

- **Python 3.6+**
- **FFmpeg** (optional, for WAV conversion) — must be installed and available in `PATH`

Install FFmpeg:

- **Linux**: `sudo apt install ffmpeg`
- **macOS**: `brew install ffmpeg`
- **Windows**: Download from [ffmpeg.org](https://ffmpeg.org/download.html) and add to `PATH`

---

## Usage

### Basic Extraction

```bash
python3 extract-oki-msm6376.py --file "V1 3_03.BIN"
```

This will:

1. Read the ROM file and parse the MSM6376 sample index
2. Create an `output/<filename>/pcm/` directory with raw ADPCM files
3. Create an `output/<filename>/wav/` directory with converted WAV files (requires FFmpeg)

### Custom Sampling Rate

The OKI ADPCM format does **not** store the sampling rate. The default is 32 kHz, but different hardware may use different rates. If playback sounds pitched incorrectly, try adjusting:

```bash
python3 extract-oki-msm6376.py --file soundrom.bin --khz 16
python3 extract-oki-msm6376.py --file soundrom.bin --khz 8
```

### IO Moon Sound ROMs

The IO Moon has **two** sound ROM files:

```bash
# Extract from first sound ROM
python3 extract-oki-msm6376.py --file "V1 3_03.BIN"

# Extract from second sound ROM
python3 extract-oki-msm6376.py --file "V1 3_04.BIN"
```

Please note that for the best results you need to combine both the IO Moon sound roms in a single file as descibed in the [Troubleshooting](#troubleshooting) section.

---

## How It Works

### MSM6376 ROM Structure

The OKI MSM6376 ROM begins with an **address table** — a sequence of 4-byte entries, where each entry points to the start of an audio sample in the ROM. The table is terminated by a `00 00 00 00` entry.

```
ROM Offset 0x000: [unused 3 bytes]
ROM Offset 0x003: [4-byte address entry 1]  → points to sample 1
ROM Offset 0x007: [4-byte address entry 2]  → points to sample 2
...
ROM Offset 0xNNN: [00 00 00 00]             → end of index
```

Each address entry is a 4-byte value; the first byte (MSB) is not used as part of the address, so only the lower 3 bytes form the actual ROM address. The script validates that addresses are monotonically increasing, as a sanity check that the file is indeed an MSM6376 ROM.

### Sample Data Format

Each audio sample is stored as a chain of **blocks**. Every block starts with a **length byte**, followed by that many data bytes:

```
[length] [data ... data]  [length] [data ... data]  ... [0x00 = end]
```

The length byte has only 7 usable bits (the MSB is masked off), giving a maximum block size of 127 bytes. A length of `0x00` signals the end of the sample.

### ADPCM Conversion

The raw extracted data is in OKI/IMA ADPCM format (4-bit encoded, 2 samples per byte). The script invokes FFmpeg to decode this into standard 16-bit PCM WAV:

```
ffmpeg -y -f u8 -c adpcm_ima_oki -ar 32k -ac 1 -i input.pcm output.wav
```

---

## Output Structure

```
output/
└── V1 3_03.BIN/
    ├── pcm/
    │   ├── 0x1a3.pcm       # Raw OKI ADPCM data
    │   ├── 0x4f2.pcm
    │   └── ...
    └── wav/
        ├── 0x1a3.wav       # Decoded WAV (16-bit PCM)
        ├── 0x4f2.wav
        └── ...
```

The filenames are the hexadecimal ROM addresses where each sample begins.

---

## Troubleshooting

**"This does not seem to be a MST3736 rom file"**
The address index entries are not in ascending order. This usually means the file is not an MSM6376 sound ROM, or the ROM file is corrupted / not the correct file.

**"The sample location is not inside this rom file"**
A sample's address chain points beyond the end of the file. This can happen when the MSM6376 expects multiple ROM chips to be concatenated. Try combining multiple ROM files:

```bash
cat sound_rom_1.bin sound_rom_2.bin > combined_sound.bin
python3 extract-oki-msm6376.py --file combined_sound.bin
```

**"Warning! ffmpeg is not installed"**
FFmpeg is not found in `PATH`. The raw `.pcm` files are still extracted and can be opened with specialized audio editors. Install FFmpeg for automatic WAV conversion.

**Audio sounds too fast or too slow**
The sampling rate is wrong. Try different values with `--khz` (common rates: 4, 6, 8, 16, 32 kHz).

---

## Technical Notes

- The MSM6376 is a speech synthesis IC by OKI Semiconductor, designed for low-bitrate voice playback.
- It uses a variant of Dialogic/IMA ADPCM with 4-bit encoded samples.
- The chip supports up to 128 individually addressable voice phrases per ROM.
- Sample playback rate is determined by an external clock divider, not stored in the ROM data. On IO Moon it works out at about **32 kHz**, measured by dividing each phrase's nibble count by the playing time the firmware's own duration table gives it (28 of 28 phrases land in 31.5–32.2 kHz). That measurement is in units of timer-0 ticks, so it inherits the timer's own open assumption: if the 80188's timer 0 interrupts only on max count B rather than on every terminal count, the rate is half of this, ~16 kHz — the other standard 6376 strapping. The two are an octave apart and are separated by ear against a real machine.
- The MSM6376 is driven by the **80188**, not the Z80: the phrase number and channel bit are latched at `0xA0300` (`/PCS6`) and started by pulsing bit 5 of `0xA0000` (`/PCS0`) as `/ST`. The Z80 has no connection to the chip and forwards no sound commands. See [`inter_cpu_communication.md`](inter_cpu_communication.md).
