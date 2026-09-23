#!/usr/bin/env python3
"""
Sleic Pin-Ball (V1.1) - FREE PLAY patch
=========================================

Patches the Sleic Pin-Ball 80188 game ROM (chip 03, `sp03-1_1.rom`) so
START begins a game with no coin inserted. The machine has no free-play
adjustment of its own.

Usage:
    python sleic_pin_ball_free_play_patch.py <sp03-1_1.rom> [--output FILE]

**V1.1 only**, by CRC; `--any-version` overrides. Independent of the
PRESS START patch in this repository (`sleic_pin_ball_press_start_patch.py`):
the two touch disjoint code and share no cave, so either can be applied to
an image already carrying the other, in either order, with an identical
result -- see `test_sleicpin_free_play.py`'s stacking test.

How it works
------------
Credits live in NVRAM as a triplicated byte at `0x140`/`0x141`/`0x142`
(segment `0x1000`, physical `0x10140`-`0x10142`). `[0000:0100]` is the RAM
cache every consumer actually reads, with its two display digits at
`[0101]`/`[0102]`. `E000:1463` is the loader: it requires all three NVRAM
bytes to be equal, bounds-checks the value below `0x32`, then caches it.
`E000:14BC` is the banking tail used by the add, decrement and repair
paths. Both write the cache with the identical 4-byte instruction
`3e a2 00 01` (`mov ds:[0x100], al`) -- at `E000:147E` (the clean-read
path) and `E000:14C8` (the banking tail) -- and nothing in the image
branches into either 4-byte window.

Each site becomes a `jmp near` to its own trampoline, which floors AL at 1
before writing the cache and rejoining the stock code immediately after.
Both writers are followed by `lcall E000:1452`, the digit splitter, so
leaving the floored value in AL makes the credit display read 1 rather
than 0. Both trampolines pack into the 256-byte gap between `E000:FF00`
and the end of the 44,821-byte `0xE50EB`-`0xEFFFF` padding run; the PRESS
START patch occupies the bottom of that run and never reaches this high,
so the two caves cannot collide however either grows.

The NVRAM triple itself is never touched. With real credits at zero the
decrementer at `E000:14AC` returns without writing, so starting a game
spends nothing and the store is never disturbed.
"""

import argparse
import hashlib
import sys
import zlib
from pathlib import Path

# =============================================================================
# Patch definition
# =============================================================================

ROM_BASE = 0xE0000
ROM_SIZE = 0x20000

# The images this accepts: stock V1.1, this patch alone, PRESS START alone
# (so free play can stack on top of it), and both together -- which is the
# same image regardless of which patch was applied first.
FREE_PLAY_FAMILY_CRC32 = (
    0x261b0ae4,   # sp03-1_1.rom, stock V1.1
    0xf82af142,   # + free play
    0x7861e7cd,   # + PRESS START
    0xa6501c6b,   # + both, either order
)

WRITER_ORIGINAL = bytes([0x3E, 0xA2, 0x00, 0x01])   # mov ds:[0x100], al

# Writer 1: E000:1463's loader, the clean-read path. Falls through to
# E000:1482 (`lcall E000:1452`, the digit splitter) once patched.
WRITER1_ADDR = 0xE147E
# Writer 2: E000:14BC's banking tail, the identical instruction.
WRITER2_ADDR = 0xE14C8

# Top of the E50EB-EFFFF padding run -- clear of the PRESS START patch,
# which occupies the bottom of it, however either patch grows.
TRAMPOLINE_WRITER1_ADDR = 0xFF00   # E000:FF00


def physical_to_file(addr):
    return addr - ROM_BASE


def _jmp_near(from_offset, to_offset, pad=1):
    """A `jmp near` (3 bytes) plus `pad` bytes of 0x90. `from_offset`/
    `to_offset` are segment E000 offsets; the displacement is relative to
    the end of the jmp itself."""
    disp = (to_offset - (from_offset + 3)) & 0xFFFF
    return bytes([0xE9, disp & 0xFF, disp >> 8]) + bytes([0x90] * pad)


WRITER1_OFFSET = physical_to_file(WRITER1_ADDR)   # 0x147E
WRITER1_RESUME = WRITER1_OFFSET + 4               # 0x1482, the lcall past the hook
WRITER2_OFFSET = physical_to_file(WRITER2_ADDR)   # 0x14C8
WRITER2_RESUME = WRITER2_OFFSET + 4               # 0x14CC, the lcall past the hook

# =============================================================================
# The two floor trampolines
# =============================================================================

# AL holds the value the stock code is about to cache. Floor it at 1 if it
# is 0, write the cache, then rejoin the stock code right where the hook
# displaced it -- the far call that splits AL into the two display digits.
TRAMPOLINE_WRITER1_ASM = f"""BITS 16
org 0x{TRAMPOLINE_WRITER1_ADDR:04X}

trampoline_writer1:
        or  al, al
        jnz short .keep
        mov al, 1
.keep:
        mov ds:[0x100], al
        jmp 0x{WRITER1_RESUME:04X}
"""

TRAMPOLINE_WRITER1 = bytes([
    0x08, 0xC0,                    # or  al, al
    0x75, 0x02,                    # jnz short .keep
    0xB0, 0x01,                    # mov al, 1              ; the free-play credit
    0x3E, 0xA2, 0x00, 0x01,        # .keep: mov ds:[0x100], al
    0xE9, 0x75, 0x15,              # jmp 0x1482             ; rejoin the digit splitter call
])

TRAMPOLINE_WRITER2_ADDR = TRAMPOLINE_WRITER1_ADDR + len(TRAMPOLINE_WRITER1)   # 0xFF0D

TRAMPOLINE_WRITER2_ASM = f"""BITS 16
org 0x{TRAMPOLINE_WRITER2_ADDR:04X}

trampoline_writer2:
        or  al, al
        jnz short .keep
        mov al, 1
.keep:
        mov ds:[0x100], al
        jmp 0x{WRITER2_RESUME:04X}
"""

TRAMPOLINE_WRITER2 = bytes([
    0x08, 0xC0,                    # or  al, al
    0x75, 0x02,                    # jnz short .keep
    0xB0, 0x01,                    # mov al, 1              ; the free-play credit
    0x3E, 0xA2, 0x00, 0x01,        # .keep: mov ds:[0x100], al
    0xE9, 0xB2, 0x15,              # jmp 0x14CC             ; rejoin the digit splitter call
])

WRITER1_PATCHED = _jmp_near(WRITER1_OFFSET, TRAMPOLINE_WRITER1_ADDR)
WRITER2_PATCHED = _jmp_near(WRITER2_OFFSET, TRAMPOLINE_WRITER2_ADDR)

CAVES = (
    (ROM_BASE + TRAMPOLINE_WRITER1_ADDR, TRAMPOLINE_WRITER1, "writer 1 floor trampoline"),
    (ROM_BASE + TRAMPOLINE_WRITER2_ADDR, TRAMPOLINE_WRITER2, "writer 2 floor trampoline"),
)

HOOKS = (
    (WRITER1_ADDR, WRITER_ORIGINAL, WRITER1_PATCHED, "credit cache writer 1 (clean-read path)"),
    (WRITER2_ADDR, WRITER_ORIGINAL, WRITER2_PATCHED, "credit cache writer 2 (banking tail)"),
)


# =============================================================================
# Patching logic
# =============================================================================

def validate_rom(rom_data, any_version=False):
    crc = zlib.crc32(rom_data)
    if crc not in FREE_PLAY_FAMILY_CRC32 and not any_version:
        print(f"  ERROR: CRC32 {crc:08x} is not V1.1's sp03-1_1.rom ({FREE_PLAY_FAMILY_CRC32[0]:08x}),\n"
              f"  nor that image with this patch or the PRESS START patch applied.\n"
              f"  This patch is verified on V1.1 only -- pass --any-version to force it.",
              file=sys.stderr)
        return False
    if len(rom_data) != ROM_SIZE:
        print(f"ERROR: Expected {ROM_SIZE // 1024}KB (sp03-1_1.rom), "
              f"got {len(rom_data)} bytes.", file=sys.stderr)
        return False

    for base, blob, what in CAVES:
        off = physical_to_file(base)
        space = rom_data[off:off + len(blob)]
        if space != blob and not all(b == 0xFF for b in space):
            print(f"  ERROR: {what} at 0x{base:05X}: space not empty (not all 0xFF).",
                  file=sys.stderr)
            return False

    for addr, orig, new, what in HOOKS:
        off = physical_to_file(addr)
        actual = rom_data[off:off + len(orig)]
        if actual == new:
            print(f"  WARNING: {what} at 0x{addr:05X} already patched.")
        elif actual != orig:
            print(f"  ERROR: {what} at 0x{addr:05X}: expected "
                  f"{orig.hex()}, found {actual.hex()}.", file=sys.stderr)
            return False
    return True


def is_already_patched(rom_data):
    def at(addr, blob):
        off = physical_to_file(addr)
        return rom_data[off:off + len(blob)] == blob
    return (all(at(a, b) for a, b, _ in CAVES) and
            all(at(a, p) for a, _, p, _ in HOOKS))


def apply_patches(rom_data):
    rom = bytearray(rom_data)
    for base, blob, what in CAVES:
        off = physical_to_file(base)
        rom[off:off + len(blob)] = blob
        print(f"  [+] {what}: {len(blob)} bytes at 0x{base:05X}")
    for addr, orig, new, what in HOOKS:
        off = physical_to_file(addr)
        rom[off:off + len(new)] = new
        print(f"  [+] {what}: {orig.hex()} -> {new.hex()} at 0x{addr:05X}")
    return bytes(rom)


# =============================================================================
# Main
# =============================================================================

def main():
    parser = argparse.ArgumentParser(
        description='Sleic Pin-Ball (V1.1) - FREE PLAY patch',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Example:
  %(prog)s sp03-1_1.rom -o sp03f.rom
        """,
    )
    parser.add_argument('rom_file', help="V1.1 game ROM, chip 03 (sp03-1_1.rom)")
    parser.add_argument('--output', '-o', default=None,
                        help='Output filename (default: <name>_freeplay.<ext>)')
    parser.add_argument('--any-version', action='store_true',
                        help='Accept a chip 03 that is not V1.1 (untested)')
    args = parser.parse_args()

    input_path = Path(args.rom_file)
    if not input_path.is_file():
        print(f"ERROR: File not found: {input_path}", file=sys.stderr)
        sys.exit(1)

    output_path = (Path(args.output) if args.output else
                   input_path.with_name(f"{input_path.stem}_freeplay{input_path.suffix}"))

    print("Sleic Pin-Ball (V1.1) - FREE PLAY patch")
    print("=" * 40)
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
