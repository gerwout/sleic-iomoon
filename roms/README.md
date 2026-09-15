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
| `PAL20L10/` | IC7 80188 bus-decode PAL, recovered from the locked chip on a DuPAL V3 rig — see its [README](PAL20L10/README.md) |
| `PAL16L8/` | IC8 Z80 bus-decode PAL, same rig — verified against the chip but missing the memory selects, see its [README](PAL16L8/README.md) |
| `related-machines/` | ROM images of other SLEIC machines (Sleic Pin-Ball, Bike Race, Doña Elvira 2) — see its [README](related-machines/README.md) |
| `related-machines/bike-race/v4.1/` | The six socketed chips of a Bike Race machine running V4.1, one of them a **bad dump** — see its [README](related-machines/bike-race/v4.1/README.md) |
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
| `PAL20L10/pal20l10.bin` | 16,384 bytes | `e3a32aaed374ba47146d1ef4f10ac42d` | IC7 PAL20L10 raw sweep — 16384 rows, the measurement itself |
| `PAL20L10/pal20l10_hiz.bin` | 16,384 bytes | `ce338fe6899778aacfc28414f2d9498b` | IC7 PAL20L10 Hi-Z mask, all zero |
| `PAL20L10/pal20l10_truthtable.txt` | 1,556,853 bytes | `f882e77f625cef41ab5491db3f13c0b2` | IC7 PAL20L10 truth table — the same measurement as labelled text |
| `PAL20L10/pal20l10.pld` | 742 bytes | `1bf466d505a025409872bc106bc74548` | IC7 PAL20L10 minimised equations (GALasm source) |
| `PAL20L10/pal20l10.jed` | 1,097 bytes | `a93bc2eddd25fc6a4308445805df3be7` | IC7 PAL20L10 JEDEC fuse map, `QF5892`, GAL22V10 / ATF22V10C target |
| `PAL16L8/pal16l8.bin` | 2,048 bytes | `69860d22fbf32693f60ee554d8000917` | IC8 PAL16L8 raw sweep — 2048 rows, 11 in / 6 out |
| `PAL16L8/pal16l8_hiz.bin` | 2,048 bytes | `c99a74c555371a433d121f551d6c6398` | IC8 PAL16L8 Hi-Z mask, all zero |
| `PAL16L8/pal16l8_truthtable.txt` | 153,911 bytes | `28a0514a59260ffd7a27f44ac113636f` | IC8 PAL16L8 truth table — the same measurement as labelled text |
| `PAL16L8/pal16l8.pld` | 619 bytes | `928a52736f3a5bb05f1bae4e96af5edb` | IC8 PAL16L8 minimised equations (GALasm source) |
| `PAL16L8/pal16l8.jed` | 546 bytes | `7f36726022a4a7f6d52313f2519ef472` | IC8 PAL16L8 JEDEC fuse map, `QF2194`, GAL16V8 simple-mode target |
| `PAL16L8/pal16l8_xcheck_8out.bin` | 1,024 bytes | `7bcd4e3e0bc9ea4297e248fda027ff86` | IC8 cross-check — pins 12-19 all read, 1024 rows |
| `PAL16L8/pal16l8_xcheck_8out_hiz.bin` | 1,024 bytes | `bbe64bf7a66b6312b65f57d2249e54a7` | Its Hi-Z mask — pins 12/13 flagged in all 1024 states, 17/19 in 128 |
| `PAL16L8/pal16l8_xcheck_pin13.bin` | 2,048 bytes | `aa7cb2aad36cdd2d6f38a9967d157168` | IC8 cross-check — pin 13 driven as an eleventh address bit, 2048 rows |
| `PAL16L8/pal16l8_xcheck_pin13_hiz.bin` | 2,048 bytes | `80f85f4cb6ebbc7ba22f5329979085fd` | Its Hi-Z mask — pin 12 flagged in all 2048 states |

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
| `related-machines/bike-race/v4.1/bk02.bin` | 524,288 bytes (512 KB) | `1bfba7e4db786c400f76e3b94c58f885` | OKI MSM6376 ADPCM samples 1 (V4.1 — same bytes as `bksnd02.bin`) |
| `related-machines/bike-race/v4.1/bk03.bin` | 524,288 bytes (512 KB) | `8f49bf919392f32fc0366d0ec6c92ada` | OKI MSM6376 ADPCM samples 2 (V4.1) |
| `related-machines/bike-race/v4.1/bk04.bin` | 131,072 bytes (128 KB) | `0ef6759ea3e87afd6b883d8052e8b2f3` | 80188 game + sound code (V4.1) |
| `related-machines/bike-race/v4.1/bk05.bin` | 131,072 bytes (128 KB) | `6367b9028b7470fc6dbad37a229bc761` | 80188 graphics ROM, MCS2 `0x40000` (V4.1 — same bytes as `bkcpu05.bin`) |
| `related-machines/bike-race/v4.1/bk06.bin` | 131,072 bytes (128 KB) | `014c57279281526e71914fe4eb833c67` | 80188 graphics ROM, MCS1 `0x20000` — V4.1's ROM 06, **confirmed by a re-dump**; CRC `9db436d4`, byte-identical to `bkcpu06.bin` |
| `related-machines/bike-race/v4.1/bk06.baddump.bin` | 131,072 bytes (128 KB) | `c42b2e81b987cbe63145eefda647da93` | **BAD DUMP** of V4.1's ROM 06 (CRC32 `ad48a30a`) — archived as evidence, do not use |
| `related-machines/bike-race/v4.1/bk07.bin` | 32,768 bytes (32 KB) | `244271a47eb206f3c3fc30c1f7d8fb17` | Z80 I/O CPU ROM (V4.1) |
| `related-machines/dona-elvira-2/256v1u06.pro` | 32,768 bytes (32 KB) | `358bd508dd8232bbfe9d8d14465015d3` | Z80 game CPU ROM (was archived as `ST27C256-z80.bin`) |
| `related-machines/dona-elvira-2/010v1u01.som` | 131,072 bytes (128 KB) | `1afd7bf6944044f04e07990599c45452` | Z80 sound CPU ROM, `ELVSONO` — 1,480 bytes used |
| `related-machines/dona-elvira-2/040V1U02.SOM` | 524,288 bytes (512 KB) | `e6a6c7156b55afc42f0978f3ed936572` | OKI MSM6376 samples chip 0, `ELVSON1` — carries the phrase table |
| `related-machines/dona-elvira-2/040V1U03.SOM` | 524,288 bytes (512 KB) | `17aa046c89d78aaf1e58f4161c744af0` | OKI MSM6376 samples chip 1, `ELVSON2` |
| `related-machines/dona-elvira-2/040V1U04.SOM` | 462,848 bytes | `a0ed355c16435c5443b680d912585e00` | OKI MSM6376 samples chip 2, `ELVSON3` — **INCOMPLETE**, missing `0xF000` at chip offset `0x43063`; needs a re-read |
| `related-machines/dona-elvira-2/040V1U05.SOM` | 524,288 bytes (512 KB) | `d5d1dee50970b609297f4cc3e8389f47` | OKI MSM6376 samples chip 3, `ELVSON4` — data to `0x21B52` |

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
- All six Doña Elvira 2 EPROMs are archived, but `040V1U04.SOM` (`ELVSON3`, IC44)
  is **incomplete**: 61,440 bytes are missing from its middle, not its end, so the
  data past the hole sits `0xF000` early in the file. It needs a re-read. The
  display board's three 6331 PROMs are undumped. See its
  [README](related-machines/dona-elvira-2/README.md).

To regenerate these checksums for every ROM image in this directory:

```bash
find . \( -name '*.bin' -o -name '*.rom' \) -exec md5sum {} +
```
