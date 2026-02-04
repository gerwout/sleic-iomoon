# ROM Set — 1.3 Early version

This is an early version of the IO Moon ROM set (version 1.3).

## Files

| Filename | Size | MD5 Checksum | Content |
|----------|------|--------------|---------|
| `V1 3_01.bin` | 524,288 bytes (512 KB) | `3d5cf32e908d20350c2dfc6c70d2d68c` | Display ROM 1 (80188 code + upper graphics) |
| `V1 3_02.bin` | 524,288 bytes (512 KB) | `4e35c714809aee1d29e2c66d1984921e` | Display ROM 2 (DMD animated frames) |
| `V1 3_03.bin` | 524,288 bytes (512 KB) | `5f4b441f3b6bb8b27689c3fc1fc5d708` | Sound ROM 1 (OKI MSM6376 ADPCM) |
| `V1 3_04.bin` | 524,288 bytes (512 KB) | `7393923e265050a4adb706d7477bd4fd` | Sound ROM 2 (OKI MSM6376 ADPCM) |
| `V1 3_05.bin` | 32,768 bytes (32 KB) | `da674b87ca562221ce5a63568b8cec1e` | Z80 CPU ROM (27C256) |

## Creating a Combined ROM

To create a 1 MB combined ROM for use with `dmd_viewer.py`:

```bash
cat "V1 3_02.bin" "V1 3_01.bin" > io_moon_combined.bin
```

> **Important:** ROM2 (`V1 3_02.bin`) must come first — it occupies the lower address range (`0x00000`–`0x7FFFF`).

## Differences from IPDB Latest

This early version has different checksums for the following ROMs compared to the IPDB latest version:

| ROM | Early Version | IPDB Latest |
|-----|---------------|-------------|
| `V1 3_01.bin` | `3d5cf32e908d20350c2dfc6c70d2d68c` | `031ca4c25f0e0433f9922b6a142478fa` |
| `V1 3_05.bin` | `da674b87ca562221ce5a63568b8cec1e` | `4a96bb470b10db89fdcbeea15fce1287` |

The graphics ROMs (`V1 3_02.bin`) and sound ROMs (`V1 3_03.bin`, `V1 3_04.bin`) are identical between versions.
