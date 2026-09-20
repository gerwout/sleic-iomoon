#!/usr/bin/env python3
"""
IO Moon Pinball - FREE PLAY patch
=================================

Patches the IO Moon 80188 CPU ROM (chip 01) so the machine always has a credit
standing, and therefore starts a game on every START press with no coin.

Usage:
    python io_moon_free_play_patch.py <rom_file> [options]

    Default:  Patches a standalone 512KB chip-01 file.
    Options:
      --combined-rom   Patch a 1MB combined ROM file (ROM0+ROM1).
      --output FILE    Specify output filename (default: auto-generated).

How it works
------------
`main_loop` at D3002 dispatches on the mode byte [413C:014F] (F11):

    mode 1 -> sub_D303C   idle, no credits
    mode 2 -> sub_D307F   idle, credits present
    mode 4 -> sub_D3145   game running
    else   -> sub_D622C   factory defaults

A game is BUILT inside sub_D307F, by the mode-3 branch at D30CD (music, display
setup, start lamp, Z80 command 0xA9, sub_DC7D7).  Forcing START past sub_D8066's
credit test at D809C is therefore not enough: sub_D8066 books the game and bumps
the games-played audit, but nothing sets it up.  Making the credit comparisons
read non-zero does not work either - sub_D307F's only normal exit is D30B0,
taken when the credit cache reads zero, so a machine that always compares
non-zero never leaves that loop and stops dispatching switches.

This patch gives the machine a real credit instead, and does it at the one place
that covers both power-on and the end of every game: main_loop's mode-1 arm.
Whenever the firmware is about to enter the no-credit idle state, the cave
writes 1 to the triplicated credit byte (F10 0x83/0x116/0x20C), sets the cache
[413C:00D4] to match, promotes the mode to 2, and returns WITHOUT calling
sub_D303C.  main_loop then re-dispatches into sub_D307F, and from there every
path is stock: attract runs as it does with a coined credit, the start lamp is
lit, and START spends the credit through the unmodified D80D1 path.

Hooking sub_D303C itself does not work, because sub_D3251 (its attract-display
call at D3058) blocks until a switch arrives and consumes that switch.  A cave
placed after it tops the credit up only once the press has already been eaten,
and the mode is not promoted until D3062, three instructions later - so the
press that pays for the credit is always refused.

The cave writes only when the cache reads zero, and the only thing that zeroes
it is a game start, so the non-volatile store sees one write per game.

Patches applied:
  1. C000:00DB - Code cave: top the credit balance up to 1 and promote the mode,
                 or perform the displaced call when a credit already stands.
  2. D301E     - Hook in main_loop's mode-1 arm:
                 CALL D2F2:011C -> CALL C000:00DB
"""

import argparse
import hashlib
import sys
import zlib
from pathlib import Path

# =============================================================================
# Patch definitions
# =============================================================================

# Code cave at C000:00DB (54 bytes).
#
# Entered by a far call in place of main_loop's "CALL FAR D2F2:011C".  AX, ES and
# CX are restored on both exits.  DS is untouched: nvstore_write_triple_83 pushes
# it and sets its own.  sub_D303C's return value is not used by main_loop (D3023
# jumps straight back), so the short path returning without it is safe.
CODE_CAVE_OFFSET = 0x00DB  # offset within the C000 segment
CODE_CAVE_DATA = bytes([
    0x50,                                # PUSH AX
    0x06,                                # PUSH ES
    0x51,                                # PUSH CX
    0xB8, 0x3C, 0x41,                    # MOV  AX, 413Ch
    0x8E, 0xC0,                          # MOV  ES, AX
    0x26, 0x80, 0x3E, 0xD4, 0x00, 0x00,  # CMP  ES:[00D4], 0   ; the credit cache
    0x75, 0x1D,                          # JNE  stock          ; a credit stands
    0x6A, 0x01,                          # PUSH 1
    0x9A, 0xD2, 0x04, 0x00, 0xD0,        # CALL FAR D000:04D2  ; write_triple_83(1)
    0x59,                                # POP  CX
    0xB8, 0x3C, 0x41,                    # MOV  AX, 413Ch
    0x8E, 0xC0,                          # MOV  ES, AX
    0x26, 0xC6, 0x06, 0xD4, 0x00, 0x01,  # MOV  ES:[00D4], 1   ; the cache
    0x26, 0xC6, 0x06, 0x4F, 0x01, 0x02,  # MOV  ES:[014F], 2   ; mode = credits present
    0x59,                                # POP  CX
    0x07,                                # POP  ES
    0x58,                                # POP  AX
    0xCB,                                # RETF -> main_loop re-dispatches to sub_D307F
    # stock:
    0x59,                                # POP  CX
    0x07,                                # POP  ES
    0x58,                                # POP  AX
    0x9A, 0x1C, 0x01, 0xF2, 0xD2,        # CALL FAR D2F2:011C  ; the displaced call
    0xCB,                                # RETF
])

# Hook patches (original -> new instruction bytes)
PATCHES = [
    {
        'name': 'main_loop mode-1 hook',
        'description': 'D301E: CALL FAR D2F2:011C -> CALL FAR C000:00DB',
        'physical_address': 0xD301E,
        'original': bytes([0x9A, 0x1C, 0x01, 0xF2, 0xD2]),
        'patched':  bytes([0x9A, 0xDB, 0x00, 0x00, 0xC0]),
    },
]

# Code cave locations (written to empty 0xFF space)
CODE_CAVES = [
    {
        'name': 'free play code cave',
        'physical_address': 0xC0000 + CODE_CAVE_OFFSET,
        'data': CODE_CAVE_DATA,
    },
]


# =============================================================================
# Patching logic
# =============================================================================

def physical_to_rom1(addr):
    """Convert physical address to chip-01 file offset."""
    return addr - 0x80000


def validate_rom(rom_data, is_combined):
    """Validate ROM file size and check patch locations."""
    expected_size = 0x100000 if is_combined else 0x80000
    if len(rom_data) != expected_size:
        print(f"ERROR: Expected {expected_size // 1024}KB "
              f"({'combined' if is_combined else 'chip 01'}), "
              f"got {len(rom_data)} bytes.", file=sys.stderr)
        return False

    offset_fn = (lambda a: a) if is_combined else physical_to_rom1

    # Check hook locations have expected original bytes
    for patch in PATCHES:
        offset = offset_fn(patch['physical_address'])
        actual = rom_data[offset:offset + len(patch['original'])]
        if actual == patch['patched']:
            print(f"  WARNING: {patch['name']} at 0x{patch['physical_address']:05X} "
                  f"already patched.")
        elif actual != patch['original']:
            print(f"  ERROR: {patch['name']} at 0x{patch['physical_address']:05X}: "
                  f"expected {patch['original'].hex()}, "
                  f"found {actual.hex()}.", file=sys.stderr)
            return False

    # Check code cave locations are empty (0xFF)
    for cave in CODE_CAVES:
        offset = offset_fn(cave['physical_address'])
        actual = rom_data[offset:offset + len(cave['data'])]
        if actual == cave['data']:
            print(f"  WARNING: {cave['name']} at 0x{cave['physical_address']:05X} "
                  f"already written.")
        elif not all(b == 0xFF for b in actual):
            print(f"  ERROR: {cave['name']} at 0x{cave['physical_address']:05X}: "
                  f"space not empty (not all 0xFF).", file=sys.stderr)
            return False

    return True


def is_already_patched(rom_data, is_combined):
    """Check if all patches are already applied."""
    offset_fn = (lambda a: a) if is_combined else physical_to_rom1
    for patch in PATCHES:
        offset = offset_fn(patch['physical_address'])
        if rom_data[offset:offset + len(patch['patched'])] != patch['patched']:
            return False
    for cave in CODE_CAVES:
        offset = offset_fn(cave['physical_address'])
        if rom_data[offset:offset + len(cave['data'])] != cave['data']:
            return False
    return True


def apply_patches(rom_data, is_combined):
    """Apply all patches and return the modified ROM."""
    rom = bytearray(rom_data)
    offset_fn = (lambda a: a) if is_combined else physical_to_rom1

    # Write code caves
    for cave in CODE_CAVES:
        offset = offset_fn(cave['physical_address'])
        rom[offset:offset + len(cave['data'])] = cave['data']
        print(f"  [+] {cave['name']}: {len(cave['data'])} bytes "
              f"at 0x{cave['physical_address']:05X}")

    # Apply hook patches
    for patch in PATCHES:
        offset = offset_fn(patch['physical_address'])
        rom[offset:offset + len(patch['patched'])] = patch['patched']
        print(f"  [+] {patch['name']}: "
              f"{patch['original'].hex()} -> {patch['patched'].hex()} "
              f"at 0x{patch['physical_address']:05X}")

    return bytes(rom)


# =============================================================================
# Main
# =============================================================================

def main():
    parser = argparse.ArgumentParser(
        description='IO Moon Pinball - FREE PLAY patch',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  %(prog)s v1_3_01.bin
  %(prog)s v1_3_01t.bin --output v1_3_01tf.bin
  %(prog)s io_moon_combined.bin --combined-rom
        """,
    )
    parser.add_argument('rom_file', help='Input chip-01 ROM file to patch')
    parser.add_argument('--combined-rom', action='store_true',
                        help='Input is a 1MB combined ROM (ROM0+ROM1)')
    parser.add_argument('--output', '-o', default=None,
                        help='Output filename (default: <name>_freeplay.<ext>)')
    args = parser.parse_args()

    input_path = Path(args.rom_file)
    if not input_path.is_file():
        print(f"ERROR: File not found: {input_path}", file=sys.stderr)
        sys.exit(1)

    if args.output:
        output_path = Path(args.output)
    else:
        output_path = input_path.with_name(
            f"{input_path.stem}_freeplay{input_path.suffix}")

    rom_type = "combined (1MB)" if args.combined_rom else "chip 01 (512KB)"

    print("IO Moon Pinball - FREE PLAY patch")
    print("=" * 40)
    print(f"Input:  {input_path}")
    print(f"Type:   {rom_type}")
    print(f"Output: {output_path}")
    print()

    rom_data = input_path.read_bytes()
    print(f"Input MD5:  {hashlib.md5(rom_data).hexdigest()}")
    print(f"Input size: {len(rom_data)} bytes ({len(rom_data) // 1024}KB)")
    print()

    print("Validating ROM...")
    if not validate_rom(rom_data, args.combined_rom):
        sys.exit(1)

    if is_already_patched(rom_data, args.combined_rom):
        print("\nROM is already patched. No changes needed.")
        sys.exit(0)

    print("\nApplying patches...")
    patched_rom = apply_patches(rom_data, args.combined_rom)

    print(f"\nOutput MD5:   {hashlib.md5(patched_rom).hexdigest()}")
    print(f"Output CRC32: {zlib.crc32(patched_rom):08x}")
    print(f"Output SHA1:  {hashlib.sha1(patched_rom).hexdigest()}")

    output_path.write_bytes(patched_rom)
    print(f"Written:      {output_path} ({len(patched_rom)} bytes)")
    print("\nPatch applied successfully!")


if __name__ == '__main__':
    main()
