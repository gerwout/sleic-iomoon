# IO Moon ROM Sets

This directory holds the dumped IO Moon ROM images, organised into two known
version 1.3 ROM sets plus a tournament patch. Each subdirectory has its own
README with set-specific details; this file is a single index of **every `.bin`
ROM image** in the directory together with its MD5 checksum for quick integrity
verification.

## Directory layout

| Path | Description |
|------|-------------|
| `1.3 IPDB latest/` | Latest known v1.3 ROM set (from IPDB) — see its [README](1.3%20IPDB%20latest/README.md) |
| `1.3 IPDB latest/Start-Tournament-Patch/` | PRESS START tournament patch for the IPDB set — see its [README](1.3%20IPDB%20latest/Start-Tournament-Patch/README.md) |
| `1.3 Early version/` | An earlier v1.3 ROM set — see its [README](1.3%20Early%20version/README.md) |

## MD5 checksums — all ROM images

| File | Size | MD5 Checksum | Content |
|------|------|--------------|---------|
| `1.3 IPDB latest/V1 3_01.bin` | 524,288 bytes (512 KB) | `031ca4c25f0e0433f9922b6a142478fa` | Display ROM 1 (80188 code + upper graphics) |
| `1.3 IPDB latest/V1 3_02.bin` | 524,288 bytes (512 KB) | `4e35c714809aee1d29e2c66d1984921e` | Display ROM 2 (DMD animated frames) |
| `1.3 IPDB latest/V1 3_03.bin` | 524,288 bytes (512 KB) | `5f4b441f3b6bb8b27689c3fc1fc5d708` | Sound ROM 1 (OKI MSM6376 ADPCM) |
| `1.3 IPDB latest/V1 3_04.bin` | 524,288 bytes (512 KB) | `7393923e265050a4adb706d7477bd4fd` | Sound ROM 2 (OKI MSM6376 ADPCM) |
| `1.3 IPDB latest/V1 3_05.bin` | 32,768 bytes (32 KB) | `4a96bb470b10db89fdcbeea15fce1287` | Z80 CPU ROM (27C256) |
| `1.3 IPDB latest/Start-Tournament-Patch/V1 3_01.bin` | 524,288 bytes (512 KB) | `71f19724d19bed4eac02f6c7caaad774` | Display ROM 1 — **PRESS START patched** |
| `1.3 Early version/V1 3_01.bin` | 524,288 bytes (512 KB) | `3d5cf32e908d20350c2dfc6c70d2d68c` | Display ROM 1 (80188 code + upper graphics) |
| `1.3 Early version/V1 3_02.bin` | 524,288 bytes (512 KB) | `4e35c714809aee1d29e2c66d1984921e` | Display ROM 2 (DMD animated frames) |
| `1.3 Early version/V1 3_03.bin` | 524,288 bytes (512 KB) | `5f4b441f3b6bb8b27689c3fc1fc5d708` | Sound ROM 1 (OKI MSM6376 ADPCM) |
| `1.3 Early version/V1 3_04.bin` | 524,288 bytes (512 KB) | `7393923e265050a4adb706d7477bd4fd` | Sound ROM 2 (OKI MSM6376 ADPCM) |
| `1.3 Early version/V1 3_05.bin` | 32,768 bytes (32 KB) | `da674b87ca562221ce5a63568b8cec1e` | Z80 CPU ROM (27C256) |

### Notes

- The graphics ROM (`V1 3_02.bin`) and both OKI sound ROMs (`V1 3_03.bin`,
  `V1 3_04.bin`) are **byte-identical** across the two ROM sets.
- The two sets differ only in the 80188 display ROM (`V1 3_01.bin`) and the
  Z80 CPU ROM (`V1 3_05.bin`).
- The tournament-patch `V1 3_01.bin` is derived from the IPDB-latest
  `V1 3_01.bin` (`031ca4c2…`) by the PRESS START patch; see
  [`Start-Tournament-Patch/README.md`](1.3%20IPDB%20latest/Start-Tournament-Patch/README.md).

To regenerate these checksums for every ROM image in this directory:

```bash
find . -name '*.bin' -exec md5sum {} +
```
