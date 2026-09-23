#!/usr/bin/env python3
"""
Sleic Pin-Ball (V1.1) - PRESS START patch
==========================================

Patches the Sleic Pin-Ball 80188 game ROM (chip 03, `sp03-1_1.rom`) so the end
of a game holds the final scores on the panel until START is pressed, instead
of dropping to attract on its own.

Usage:
    python sleic_pin_ball_press_start_patch.py <sp03-1_1.rom> [--output FILE]

**V1.1 only**, by CRC; `--any-version` overrides.

Two padding regions are free in this ROM, both erased to `0xFF`:
`0xE50EB`-`0xEFFFF` (segment E000) and `0xFDFF0`-`0xFFE76` (segment F000).
This revision carries a single one-byte placeholder cave at `0xFDFF0` and no
hooks; the patch payload is not yet implemented.
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
# The images this accepts: stock V1.1.
V11_FAMILY_CRC32 = (
    0x261b0ae4,   # sp03-1_1.rom, stock V1.1
)

CAVE_PLACEHOLDER = 0xFDFF0   # F000:DFF0, free padding before FE76

CAVE_PLACEHOLDER_DATA = bytes([0x90])   # NOP; the real payload replaces this in Tasks 7-11

CAVES = ((CAVE_PLACEHOLDER, CAVE_PLACEHOLDER_DATA, "placeholder cave"),)
HOOKS = ()


# =============================================================================
# Patching logic
# =============================================================================

def physical_to_file(addr):
    return addr - ROM_BASE


def validate_rom(rom_data, any_version=False):
    crc = zlib.crc32(rom_data)
    if crc not in V11_FAMILY_CRC32 and not any_version:
        print(f"  ERROR: CRC32 {crc:08x} is not V1.1's sp03-1_1.rom ({V11_FAMILY_CRC32[0]:08x}).\n"
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
        description='Sleic Pin-Ball (V1.1) - PRESS START patch',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  %(prog)s sp03-1_1.rom -o sp03p.rom
        """,
    )
    parser.add_argument('rom_file', help="V1.1 game ROM, chip 03 (sp03-1_1.rom)")
    parser.add_argument('--output', '-o', default=None,
                        help='Output filename (default: <name>_pressstart.<ext>)')
    parser.add_argument('--any-version', action='store_true',
                        help='Accept a chip 03 that is not V1.1 (untested)')
    args = parser.parse_args()

    input_path = Path(args.rom_file)
    if not input_path.is_file():
        print(f"ERROR: File not found: {input_path}", file=sys.stderr)
        sys.exit(1)

    output_path = (Path(args.output) if args.output else
                   input_path.with_name(f"{input_path.stem}_pressstart{input_path.suffix}"))

    print("Sleic Pin-Ball (V1.1) - PRESS START patch")
    print("=" * 44)
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
