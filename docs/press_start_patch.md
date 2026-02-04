# PRESS START Patch — `io_moon_press_start_patch.py`

[← Back to main README](../README.md)

## Overview

The IO Moon's original software has a design issue for tournament and competitive play: after a game ends, the machine immediately transitions through the match animation and into attract mode. There is **no pause** between the end of the game and the attract mode, making it impossible for players or judges to read, photograph, or record the final scores.

<p align="center">
  <a href="https://www.youtube.com/watch?v=wjNdBtwymYc">
    <img src="https://img.youtube.com/vi/wjNdBtwymYc/maxresdefault.jpg" alt="PRESS START Patch Demo" width="700">
  </a>
  <br>
  <em>Click to watch the PRESS START patch in action</em>
</p>

This patch modifies the 80188 CPU ROM to inject custom machine code that:

1. Displays "**PRESS START**" text on the DMD after the match animation
2. Clears the match number from the score display (so only scores remain visible)
3. Waits indefinitely for the player to press the START button
4. Only then returns to attract mode

The patch is fully reversible and uses only unused (`0xFF`) ROM space for the injected code.

---

## Pre-Patched ROM Download

A ready-to-use patched ROM is available in this repository:

**[Download V1 3_01.bin (patched)](../roms/1.3%20IPDB%20latest/Start-Tournament-Patch/V1%203_01.bin)**

| File | MD5 Checksum |
|------|--------------|
| `V1 3_01.bin` (patched) | `71f19724d19bed4eac02f6c7caaad774` |

### Requirements

- Your IO Moon must already have the **IPDB latest** ROM set installed. If your current ROMs have different checksums, you should first upgrade all ROMs to the IPDB latest versions (see [ROM Checksums](#rom-checksums) below).
- An **EPROM programmer** capable of programming 27C040 chips.
- A blank **27C040 EPROM** (512 KB, 32-pin DIP).

### Installation

1. Download the patched `V1 3_01.bin` file from this repository
2. Verify the MD5 checksum matches `71f19724d19bed4eac02f6c7caaad774`
3. Program the file onto a blank 27C040 EPROM using your EPROM programmer
4. Replace the original `V1 3_01` chip in your IO Moon's CPU board with the newly programmed EPROM
5. Power on and test — after each game ends, you should now see "PRESS START" on the DMD

> **Note:** Keep your original `V1 3_01` EPROM in a safe place in case you want to revert to the unpatched version.

---

## Usage (Create Your Own Patch)

### Patching a standalone ROM1 file (512 KB)

```bash
python3 io_moon_press_start_patch.py "V1 3_01.BIN"
```

This creates `V1 3_01_patched.BIN` in the same directory.

### Patching a combined ROM file (1 MB)

```bash
python3 io_moon_press_start_patch.py io_moon_combined.bin --combined-rom
```

### Custom output filename

```bash
python3 io_moon_press_start_patch.py "V1 3_01.BIN" --output my_patched_rom.bin
```

### Output

The script prints MD5 checksums of the input and output files, validates that the target addresses contain the expected original bytes (or are empty `0xFF` space), and reports each patch applied.

---

## What the Patch Does

The patch touches 4 locations in the ROM:

| Address | Type | Description |
|---------|------|-------------|
| `C000:0010` | Code cave (168 bytes) | Main patch code: writes "PRESS START" string, clears match number area, calls DMD text display routine, polls START button |
| `C000:00D0` | Trampoline (11 bytes) | Redirect for the SPECIAL (match) path: calls PRESS START, then executes the original displaced call |
| `D5076` | Hook (5 bytes) | SPECIAL path: `CALL FAR D72A:37F2` → `CALL FAR C000:00D0` |
| `D5122` | Hook (5 bytes) | Normal path: `CALL FAR F000:174D` → `CALL FAR C000:0010` |

### Code Cave Details

The injected code at `C000:0010` performs the following steps:

1. **Set up data segment** (`DS = 4000h`) to access shared RAM
2. **Write "PRESS START" string** to `4000:1200` using the IO Moon's custom text encoding (where `0x0B` = 'A', `0x1B` = 'P', etc.)
3. **Clear the match number** from all 4 DMD display buffers by zeroing a 5-byte × 22-row region at offset `0x0076` (row 7, byte 6)
4. **Call the ROM's text display routine** (`F000:0701`) with parameters: font type 1, Y-position `0x0173`, string at `4000:1200`
5. **Poll the START button** by checking `ES:[1147h]` until it becomes non-zero
6. **Debounce**: verify the button is actually pressed by checking the display buffer pointer, then wait for release
7. **Return** via `RETF` to resume normal game flow

### Two Hook Points

The end-of-game flow has two distinct paths that both need interception:

- **Normal path** (`D5122`): The game ends without a SPECIAL (match). The code at `D5122` normally calls `F000:174D` to start the next animation. The hook redirects this to the PRESS START code cave.

- **SPECIAL path** (`D5076`): The game ends with a SPECIAL (match win). The code at `D5076` calls `D72A:37F2` for the match animation. The trampoline at `C000:00D0` first shows PRESS START, then proceeds to the original match animation call.

---
## Validation

The script performs several safety checks before patching:

- **File size**: Must be exactly 512 KB (ROM1) or 1 MB (combined)
- **Original bytes**: Verifies the hook locations contain the expected original instruction bytes
- **Empty space**: Verifies the code cave locations are all `0xFF` (unused EPROM space)
- **Already patched**: Detects if the patch has already been applied and exits cleanly
- **MD5 checksums**: Prints input and output hashes for verification

---

## Reversibility

To revert the patch, restore the original bytes at the 4 patched locations:

| Address | Original bytes |
|---------|---------------|
| `C0010`–`C00B7` | All `0xFF` |
| `C00D0`–`C00DA` | All `0xFF` |
| `D5076` | `9A F2 37 2A D7` |
| `D5122` | `9A 4D 17 00 F0` |

Or simply re-flash the original unmodified ROM.

---

## ROM Checksums

The patch has been tested with the following ROM versions. Use MD5 checksums to verify you have the correct source ROM before patching.

### Supported Input ROMs

| ROM Version | MD5 Checksum | Status               |
|-------------|--------------|----------------------|
| V1 3_01.bin (IPDB latest) | `031ca4c25f0e0433f9922b6a142478fa` | **Recommended**      |
| V1 3_01.bin (Early version) | `3d5cf32e908d20350c2dfc6c70d2d68c` | Not Supported/Tested |

### Patched Output ROM

| Input ROM | Output MD5 Checksum |
|-----------|---------------------|
| V1 3_01.bin (IPDB latest) | `71f19724d19bed4eac02f6c7caaad774` |

A pre-patched ROM is available in `roms/1.3 IPDB latest/Start-Tournament-Patch/`.

### Verifying Checksums

Before patching, verify your source ROM:

```bash
md5sum "V1 3_01.bin"
```

The script will also print checksums during execution:

```
Input file:  V1 3_01.bin
Input MD5:   031ca4c25f0e0433f9922b6a142478fa
Output file: V1 3_01_patched.bin
Output MD5:  71f19724d19bed4eac02f6c7caaad774
```

If your input checksum doesn't match either known version, the ROM may be corrupted or from an unknown revision. The patch may still work if the code at the hook locations matches the expected bytes, but proceed with caution.
