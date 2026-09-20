# ROM Set — Version 1.3 IPDB latest (Tournament Patch)

This directory contains the patched ROM for tournament play. The PRESS START patch modifies the end-of-game behavior to display "PRESS START" and wait for player confirmation before returning to attract mode.

## Files

| Filename | Size | MD5 Checksum | Content |
|----------|------|--------------|---------|
| `V1 3_01.bin` | 524,288 bytes (512 KB) | `71f19724d19bed4eac02f6c7caaad774` | Display ROM 1 (80188 code + upper graphics) — **PATCHED** |

## Source ROM

This patched ROM was created from the unpatched `V1 3_01.bin` from the "1.3 IPDB latest" ROM set:

| Version | MD5 Checksum |
|---------|--------------|
| Original (unpatched) | `031ca4c25f0e0433f9922b6a142478fa` |
| Patched (this file) | `71f19724d19bed4eac02f6c7caaad774` |

## Usage

Replace the original `V1 3_01.bin` EPROM in your IO Moon machine with this patched version.

> **Important:** This patched ROM is designed for use with the **IPDB latest** ROM set. If your machine currently has ROMs with different checksums (e.g., the "Early version" ROM set), you should first upgrade **all ROMs that differ** to the IPDB latest versions before installing this patch.

### Required ROM Set (IPDB latest)

| Filename | MD5 Checksum | Notes |
|----------|--------------|-------|
| `V1 3_01.bin` | `71f19724d19bed4eac02f6c7caaad774` | **Use this patched version** |
| `V1 3_02.bin` | `4e35c714809aee1d29e2c66d1984921e` | Identical in both ROM sets |
| `V1 3_03.bin` | `5f4b441f3b6bb8b27689c3fc1fc5d708` | Identical in both ROM sets |
| `V1 3_04.bin` | `7393923e265050a4adb706d7477bd4fd` | Identical in both ROM sets |
| `V1 3_05.bin` | `4a96bb470b10db89fdcbeea15fce1287` | **Different from Early version — upgrade required** |

The Z80 CPU ROM (`V1 3_05.bin`) differs between the Early version and IPDB latest. If you have the Early version checksum (`da674b87ca562221ce5a63568b8cec1e`), you must upgrade to the IPDB latest Z80 ROM for full compatibility.

For details on what the patch modifies, see [PRESS START Patch Documentation](../../../docs/press_start_patch.md).

## Creating Your Own Patched ROM

You can create this patched ROM yourself using the patch script:

```bash
python3 io_moon_press_start_patch.py "V1 3_01.bin"
```

This creates `V1 3_01_patched.BIN` with the same checksum as the file in this directory.
