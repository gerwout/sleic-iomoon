# IO Moon ROM Sets

This directory holds the dumped IO Moon ROM images, organised into two known
version 1.3 ROM sets plus a tournament patch, alongside the ROM images of three
related SLEIC machines. Each subdirectory has its own README with set-specific
details; this file is a single index of **every ROM image** in the directory
together with its MD5 checksum for quick integrity verification.

## Directory layout

| Path | Description |
|------|-------------|
| `1.3 IPDB latest/` | Latest known v1.3 ROM set (from IPDB) — see its [README](1.3%20IPDB%20latest/README.md) |
| `1.3 IPDB latest/Start-Tournament-Patch/` | PRESS START tournament patch for the IPDB set — see its [README](1.3%20IPDB%20latest/Start-Tournament-Patch/README.md) |
| `1.3 Early version/` | An earlier v1.3 ROM set — see its [README](1.3%20Early%20version/README.md) |
| `PIC16C57/` | IC23 DMD-raster PIC dump, recovered from the locked chip by a recovery lab — see its [README](PIC16C57/README.md) |
| `related-machines/` | ROM images of other SLEIC machines (Sleic Pin-Ball, Bike Race, Doña Elvira 2) — see its [README](related-machines/README.md) |
| `pinmame/` | These images repackaged as PinMAME-loadable `.zip` sets, plus the six Bike Race clone chips held only there — see its [README](pinmame/README.md) |

## MD5 checksums — IO Moon

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
| `PIC16C57/PIC16F57-DIP28-1D05-20260815.bin` | 8,192 bytes (8 KB) | `a244f2d8060c2d92a814e20bdd55ecfe` | IC23 PIC16C57 DMD raster coprocessor (16F57-adjusted, cracked from locked original) |

## MD5 checksums — related SLEIC machines

| File | Size | MD5 Checksum | Content |
|------|------|--------------|---------|
| `related-machines/sleic-pin-ball/sp01-1_1.rom` | 8,192 bytes (8 KB) | `6770d21b5691e7951cdf305aa9f0dd41` | I8039 display coprocessor |
| `related-machines/sleic-pin-ball/sp02-1_1.rom` | 524,288 bytes (512 KB) | `22f3d40c73d903033c12b9665cbea662` | OKI MSM6376 ADPCM samples |
| `related-machines/sleic-pin-ball/sp03-1_1.rom` | 131,072 bytes (128 KB) | `50c49844fe28d1d8b3477eb35cc8e133` | 80188 game + sound code |
| `related-machines/sleic-pin-ball/sp04-1_1.rom` | 32,768 bytes (32 KB) | `320903cb4961a0a9469182dc532fa294` | Z80 I/O CPU ROM |
| `related-machines/bike-race/bkdsp01.bin` | 8,192 bytes (8 KB) | `f9c98453e94762f6ddf499e33e98a6cf` | I8039 display coprocessor |
| `related-machines/bike-race/bksnd02.bin` | 524,288 bytes (512 KB) | `1bfba7e4db786c400f76e3b94c58f885` | OKI MSM6376 ADPCM samples 1 |
| `related-machines/bike-race/bksnd03.bin` | 524,288 bytes (512 KB) | `2435a0a13df5ebf8fd759cfbdf23419d` | OKI MSM6376 ADPCM samples 2 |
| `related-machines/bike-race/bkcpu04.bin` | 131,072 bytes (128 KB) | `6e06ee13bc64769c110bb5e17e7b61d9` | 80188 game + sound code (`0xE0000`) |
| `related-machines/bike-race/bkcpu05.bin` | 131,072 bytes (128 KB) | `6367b9028b7470fc6dbad37a229bc761` | 80188 graphics ROM (MCS2 `0x40000`) |
| `related-machines/bike-race/bkcpu06.bin` | 131,072 bytes (128 KB) | `014c57279281526e71914fe4eb833c67` | 80188 graphics ROM (MCS1 `0x20000`) |
| `related-machines/bike-race/bkio07.bin` | 32,768 bytes (32 KB) | `0141e09fa7a4ff36c666a3d1e777d1c2` | Z80 I/O CPU ROM |
| `related-machines/dona-elvira-2/ST27C256-z80.bin` | 32,768 bytes (32 KB) | `358bd508dd8232bbfe9d8d14465015d3` | Z80 I/O CPU ROM (**only ROM dumped**) |

### Notes

- The graphics ROM (`V1 3_02.bin`) and both OKI sound ROMs (`V1 3_03.bin`,
  `V1 3_04.bin`) are **byte-identical** across the two IO Moon ROM sets.
- The two IO Moon sets differ only in the 80188 display ROM (`V1 3_01.bin`) and
  the Z80 CPU ROM (`V1 3_05.bin`).
- The tournament-patch `V1 3_01.bin` is derived from the IPDB-latest
  `V1 3_01.bin` (`031ca4c2…`) by the PRESS START patch; see
  [`Start-Tournament-Patch/README.md`](1.3%20IPDB%20latest/Start-Tournament-Patch/README.md).
- A second, physically distinct IO Moon board was dumped in August 2026; all five
  images came out **byte-identical to the `1.3 IPDB latest` set**, so that set is
  confirmed by two independent boards and the duplicate dump was not archived.
- The Doña Elvira 2 dump is **partial** — the Z80 I/O ROM only. See its
  [README](related-machines/dona-elvira-2/README.md).

To regenerate these checksums for every ROM image in this directory:

```bash
find . \( -name '*.bin' -o -name '*.rom' \) -exec md5sum {} +
```
