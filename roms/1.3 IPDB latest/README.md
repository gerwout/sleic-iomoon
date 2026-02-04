# ROM Set — Version 1.3 IPDB latest

This is the latest known version of the IO Moon ROM set (version 1.3), as available from IPDB.

## Files

| Filename | Size | MD5 Checksum | Content |
|----------|------|--------------|---------|
| `V1 3_01.bin` | 524,288 bytes (512 KB) | `031ca4c25f0e0433f9922b6a142478fa` | Display ROM 1 (80188 code + upper graphics) |
| `V1 3_02.bin` | 524,288 bytes (512 KB) | `4e35c714809aee1d29e2c66d1984921e` | Display ROM 2 (DMD animated frames) |
| `V1 3_03.bin` | 524,288 bytes (512 KB) | `5f4b441f3b6bb8b27689c3fc1fc5d708` | Sound ROM 1 (OKI MSM6376 ADPCM) |
| `V1 3_04.bin` | 524,288 bytes (512 KB) | `7393923e265050a4adb706d7477bd4fd` | Sound ROM 2 (OKI MSM6376 ADPCM) |
| `V1 3_05.bin` | 32,768 bytes (32 KB) | `4a96bb470b10db89fdcbeea15fce1287` | Z80 CPU ROM (27C256) |

## Subdirectories

| Directory | Description |
|-----------|-------------|
| `Start-Tournament-Patch/` | Contains the patched `V1 3_01.bin` for tournament play |

## Creating a Combined ROM

To create a 1 MB combined ROM for use with `dmd_viewer.py` and `io_moon_press_start_patch.py`:

```bash
cat "V1 3_02.bin" "V1 3_01.bin" > io_moon_combined.bin
```

> **Important:** ROM2 (`V1 3_02.bin`) must come first — it occupies the lower address range (`0x00000`–`0x7FFFF`).
