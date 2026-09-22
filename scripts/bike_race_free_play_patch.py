#!/usr/bin/env python3
"""
Sleic Bike Race (V4.1) - FREE PLAY patch
========================================

Patches the Bike Race V4.1 80188 game ROM (chip 04, `bk04.bin`) so the machine
always has a credit standing, and therefore starts a game on every START press
with no coin.

Usage:
    python bike_race_free_play_patch.py <bk04.bin> [--output FILE]

**V4.1 only.** The V4.1 set (`bikerac3`) rebuilds chips 03/04/07 over the parent;
chip 04 is the game code and is the only chip this touches. The parent sets
(`bikerace`, `bikerac2`) carry their own chip 04, `bkcpu04.bin`, whose code sits
at slightly different addresses -- but the credit-read primitive this patch
rewrites is byte-identical in both, so the byte check cannot tell them apart.
The input CRC32 is checked instead, and `--any-version` overrides it.

Bike Race has no free-play adjustment of its own: its menu tree is
AJUSTE -> {SONIDO/VIDEO, JUEGO, TECNICO}, TECNICO -> {TEST TABLERO, CREDITOS,
FALTAS}, and CREDITOS is the coin-pricing page only. No ROM in the set contains
GRATIS, LIBRE, FREE or any equivalent.

How it works
------------
Bike Race's game state lives in segment `0116`: `[0070]` is the credit cache,
`[0072]` the player count and `[0076]` a two-valued mode byte. The START handler
at `EC394` is the same routine as Io Moon's `sub_D8066`:

```
EC394:  CMP ES:[0076], 1 / JE  continue   ; mode 1 = credits present, ready
EC3A4:  CMP ES:[0072], 4 / JB  continue   ; fewer than four players
EC3B4:  CMP ES:[0070], 0 / JNE continue   ; a credit stands
EC3BF:  the credit spend, then the game start
```

**Forcing the credit test is not enough.** Measured in emulation, the mode byte
is promoted 0 -> 1 by the stock code *because a credit appeared*:

```
frame 1110   credits 0 -> 1      a coin lands
frame 1170   mode    0 -> 1      promoted in consequence
frame 2430   players 0 -> 1      START now works
```

A machine with the credit test bypassed but no credit stays in mode 0 and the
handler refuses at its first instruction.

So this patch gives the machine a real credit, at the one place every credit
value comes from. `E000:059F` reads the triplicated credit byte (F10's scheme,
here `0083`/`0105`/`0278` in the store window at segment `1040`) and returns it;
`[0116:0070]` is recomputed from it as credits + sub-credits. Flooring that read
at 1 makes the cache non-zero, the stock code promotes the mode, START spends
through the unmodified path, and the next read floors again.

`bk04.bin` is **zero-padded, not 0xFF-padded**, which is why a first pass for free
space found none. There is a 28,061-byte run of `0x00` at `F9163` reaching to the
reset-vector page, with no far call or jump anywhere in the ROM targeting it, so
it is genuine padding and the cave lives there.

Nothing of the original routine is rewritten. `E059F`'s six-byte prologue
(`PUSH ES / MOV AX,1040 / MOV ES,AX`) becomes a five-byte far jump to the cave
plus a `NOP`, and the cave carries the whole routine: the same triplicated read,
the same mismatch resync, and the floor. The original body at `E05A5`-`E05CA`
is left byte-for-byte intact (unreachable, but unmodified).

Coins still work: verified in emulation, a coined machine accumulates 1 -> 2 -> 4
exactly as stock does 0 -> 1 -> 3, and the credit display reads one higher.

Verified in emulation (bikerac3, headless): with no coins and a single START
press the machine reaches credits=1, mode=1 and players=1, where an untouched
machine stays at credits=0, mode=0 and never starts.  Coins still accumulate
1 -> 2 -> 4 exactly as stock does 0 -> 1 -> 3.
"""

import argparse
import hashlib
import sys
import zlib
from pathlib import Path

# =============================================================================
# Patch definition
# =============================================================================

ROM_BASE = 0xE0000          # bk04.bin is mapped at physical 0xE0000
ROM_SIZE = 0x20000          # 128 KB
# The four images in this family: stock V4.1, and it with either or both of this
# repository's patches applied.  Any of them is a valid input.
V41_FAMILY_CRC32 = (
    0x33fd212e,   # bk04.bin, stock V4.1
    0x42748f1d,   # + free play
    0x07aff87d,   # + press start
    0x7626564e,   # + both
)

CREDIT_READ = 0xE059F       # E000:059F, the triplicated-credit read primitive
CAVE       = 0xF9200        # F920:0000, inside the dead 0x00 padding at F9163

# The six-byte prologue we displace, and the far jump that replaces it.
ORIGINAL = bytes([0x06, 0xB8, 0x40, 0x10, 0x8E, 0xC0])   # PUSH ES / MOV AX,1040 / MOV ES,AX
PATCHED  = bytes([0xEA, 0x00, 0x00, 0x20, 0xF9, 0x90])   # JMP FAR F920:0000 / NOP

# The cave: the stock routine reproduced, with the result floored at 1.
CAVE_DATA = bytes([
    0x06,                          # PUSH ES                  ] the displaced prologue
    0xB8, 0x40, 0x10,              # MOV  AX, 1040h           ] (the store window)
    0x8E, 0xC0,                    # MOV  ES, AX              ]
    0x26, 0xA0, 0x83, 0x00,        # MOV  AL, ES:[0083]       ; credit byte
    0x26, 0x3A, 0x06, 0x05, 0x01,  # CMP  AL, ES:[0105]       ; copy 2
    0x75, 0x11,                    # JNE  resync
    0x26, 0x3A, 0x06, 0x78, 0x02,  # CMP  AL, ES:[0278]       ; copy 3
    0x75, 0x0A,                    # JNE  resync
    0x0A, 0xC0,                    # OR   AL, AL
    0x75, 0x02,                    # JNZ  done
    0xB0, 0x01,                    # MOV  AL, 1               ; the free-play credit
    0x32, 0xE4,                    # done: XOR AH, AH
    0x07,                          # POP  ES
    0xCB,                          # RETF
    0x33, 0xC0,                    # resync: XOR AX, AX       ] stock mismatch handling,
    0x26, 0xA2, 0x83, 0x00,        # MOV  ES:[0083], AL       ] reproduced verbatim
    0x26, 0xA2, 0x05, 0x01,        # MOV  ES:[0105], AL       ]
    0x26, 0xA2, 0x78, 0x02,        # MOV  ES:[0278], AL       ]
    0xB0, 0x01,                    # MOV  AL, 1
    0x32, 0xE4,                    # XOR  AH, AH
    0x07,                          # POP  ES
    0xCB,                          # RETF
])

assert len(ORIGINAL) == len(PATCHED)


# =============================================================================
# Patching logic
# =============================================================================

def physical_to_file(addr):
    """Convert a physical address to a bk04.bin file offset."""
    return addr - ROM_BASE


def validate_rom(rom_data, any_version=False):
    crc = zlib.crc32(rom_data)
    if crc not in V41_FAMILY_CRC32 and not any_version:
        print(f"  ERROR: CRC32 {crc:08x} is not V4.1's bk04.bin ({V41_FAMILY_CRC32[0]:08x}),\n"
              f"  nor that image with this repository's patches applied.\n"
              f"  This patch is verified on V4.1 only.  The parent sets carry the same\n"
              f"  credit-read code, so it would very likely apply there too, but that is\n"
              f"  untested -- pass --any-version if you want to try it.", file=sys.stderr)
        return False
    if len(rom_data) != ROM_SIZE:
        print(f"ERROR: Expected {ROM_SIZE // 1024}KB (bk04.bin), "
              f"got {len(rom_data)} bytes.", file=sys.stderr)
        return False

    cav = physical_to_file(CAVE)
    space = rom_data[cav:cav + len(CAVE_DATA)]
    if space != CAVE_DATA and not all(b == 0x00 for b in space):
        print(f"  ERROR: cave at 0x{CAVE:05X}: space not empty (not all 0x00).",
              file=sys.stderr)
        return False

    off = physical_to_file(CREDIT_READ)
    actual = rom_data[off:off + len(ORIGINAL)]
    if actual == PATCHED:
        print(f"  WARNING: credit read at 0x{CREDIT_READ:05X} already patched.")
    elif actual != ORIGINAL:
        print(f"  ERROR: credit read at 0x{CREDIT_READ:05X}: expected\n"
              f"         {ORIGINAL.hex()}\n"
              f"    found {actual.hex()}\n"
              f"  This is V4.1's bk04.bin only -- the parent sets' bkcpu04.bin "
              f"differs.", file=sys.stderr)
        return False
    return True


def is_already_patched(rom_data):
    off, cav = physical_to_file(CREDIT_READ), physical_to_file(CAVE)
    return (rom_data[off:off + len(PATCHED)] == PATCHED and
            rom_data[cav:cav + len(CAVE_DATA)] == CAVE_DATA)


def apply_patches(rom_data):
    rom = bytearray(rom_data)
    cav = physical_to_file(CAVE)
    rom[cav:cav + len(CAVE_DATA)] = CAVE_DATA
    print(f"  [+] free play code cave: {len(CAVE_DATA)} bytes at 0x{CAVE:05X}")
    off = physical_to_file(CREDIT_READ)
    rom[off:off + len(PATCHED)] = PATCHED
    print(f"  [+] credit read hook: {ORIGINAL.hex()} -> {PATCHED.hex()} "
          f"at 0x{CREDIT_READ:05X}")
    return bytes(rom)


# =============================================================================
# Main
# =============================================================================

def main():
    parser = argparse.ArgumentParser(
        description='Sleic Bike Race (V4.1) - FREE PLAY patch',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Example:
  %(prog)s bk04.bin -o bk04f.bin
        """,
    )
    parser.add_argument('rom_file', help="V4.1 game ROM, chip 04 (bk04.bin)")
    parser.add_argument('--output', '-o', default=None,
                        help='Output filename (default: <name>_freeplay.<ext>)')
    parser.add_argument('--any-version', action='store_true',
                        help='Accept a chip 04 that is not V4.1 (untested)')
    args = parser.parse_args()

    input_path = Path(args.rom_file)
    if not input_path.is_file():
        print(f"ERROR: File not found: {input_path}", file=sys.stderr)
        sys.exit(1)

    output_path = (Path(args.output) if args.output else
                   input_path.with_name(f"{input_path.stem}_freeplay{input_path.suffix}"))

    print("Sleic Bike Race (V4.1) - FREE PLAY patch")
    print("=" * 42)
    print(f"Input:  {input_path}")
    print(f"Output: {output_path}")
    print()

    rom_data = input_path.read_bytes()
    print(f"Input MD5:   {hashlib.md5(rom_data).hexdigest()}")
    print(f"Input CRC32: {zlib.crc32(rom_data):08x}")
    print(f"Input size:  {len(rom_data)} bytes")
    print()

    print("Validating ROM...")
    if not validate_rom(rom_data, args.any_version):
        sys.exit(1)

    if is_already_patched(rom_data):
        print("\nROM is already patched. No changes needed.")
        sys.exit(0)

    print("\nApplying patch...")
    patched_rom = apply_patches(rom_data)

    print(f"\nOutput MD5:   {hashlib.md5(patched_rom).hexdigest()}")
    print(f"Output CRC32: {zlib.crc32(patched_rom):08x}")
    print(f"Output SHA1:  {hashlib.sha1(patched_rom).hexdigest()}")

    output_path.write_bytes(patched_rom)
    print(f"Written:      {output_path} ({len(patched_rom)} bytes)")
    print("\nPatch applied successfully!")


if __name__ == '__main__':
    main()
