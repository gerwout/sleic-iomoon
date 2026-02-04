#!/usr/bin/env python3
"""
IO Moon Pinball - PRESS START Patch
====================================

Patches the IO Moon 80188 CPU ROM to display "PRESS START" text on the DMD
after end-of-game, requiring the player to press START before returning to
attract mode. Works for both normal end-of-game and SPECIAL (match) scenarios.

Usage:
    python io_moon_press_start_patch.py <rom_file> [options]

    Default:  Patches a standalone 512KB ROM1 file.
    Options:
      --combined-rom   Patch a 1MB combined ROM file (ROM0+ROM1).
      --output FILE    Specify output filename (default: auto-generated).

Patches applied:
  1. C000:0010 - Code cave: clears match number, draws "PRESS START" text
                 on DMD (font type 1, centered), waits for START button.
  2. C000:00D0 - Trampoline for SPECIAL path: calls code cave, then
                 executes the original displaced D72A:37F2 call.
  3. D5076     - Hook inside SPECIAL handler (before animation starts):
                 CALL D72A:37F2 -> CALL C000:00D0
  4. D5122     - Hook in normal end-of-game path:
                 CALL F000:174D -> CALL C000:0010
"""

import argparse
import hashlib
import sys
from pathlib import Path

# =============================================================================
# Patch definitions
# =============================================================================

# Code cave at C000:0010 (168 bytes)
# - Sets DS = 4000h
# - Writes "PRESS START" string to 4000:1200
# - Clears match number area in all 4 display buffers
# - Calls F000:0701 (text display, font type 1, Y=0x0173)
# - Waits for START button press
CODE_CAVE_OFFSET = 0x0010  # offset within C000 segment
CODE_CAVE_DATA = bytes([
    0xB8, 0x00, 0x40, 0x8E, 0xD8,                          # MOV AX,4000h; MOV DS,AX
    0xBF, 0x00, 0x12,                                      # MOV DI,1200h
    0xB0, 0x0B, 0x88, 0x05, 0x47,                          # MOV AL,0Bh; MOV [DI],AL; INC DI  (length=11)
    0xB0, 0x1B, 0x88, 0x05, 0x47,                          # 'P'
    0xB0, 0x1D, 0x88, 0x05, 0x47,                          # 'R'
    0xB0, 0x0F, 0x88, 0x05, 0x47,                          # 'E'
    0xB0, 0x1E, 0x88, 0x05, 0x47,                          # 'S'
    0xB0, 0x1E, 0x88, 0x05, 0x47,                          # 'S'
    0xB0, 0x0A, 0x88, 0x05, 0x47,                          # ' '
    0xB0, 0x1E, 0x88, 0x05, 0x47,                          # 'S'
    0xB0, 0x1F, 0x88, 0x05, 0x47,                          # 'T'
    0xB0, 0x0B, 0x88, 0x05, 0x47,                          # 'A'
    0xB0, 0x1D, 0x88, 0x05, 0x47,                          # 'R'
    0xB0, 0x1F, 0x88, 0x05, 0x47,                          # 'T'
    # Clear match number from all 4 display buffers
    0xBF, 0x76, 0x00,                                      # MOV DI,0076h (row 7, byte 6)
    0xB9, 0x16, 0x00,                                      # MOV CX,22 (rows)
    # outer_loop:
    0x51, 0x57,                                            # PUSH CX; PUSH DI
    0xB9, 0x05, 0x00,                                      # MOV CX,5 (bytes per row)
    # inner_loop:
    0x32, 0xC0,                                            # XOR AL,AL
    0x88, 0x05,                                            # MOV [DI],AL       (buffer 0x000)
    0x88, 0x85, 0x00, 0x02,                                # MOV [DI+200h],AL  (buffer 0x200)
    0x88, 0x85, 0x00, 0x04,                                # MOV [DI+400h],AL  (buffer 0x400)
    0x88, 0x85, 0x00, 0x06,                                # MOV [DI+600h],AL  (buffer 0x600)
    0x47,                                                  # INC DI
    0xE2, 0xEF,                                            # LOOP inner_loop
    0x5F, 0x83, 0xC7, 0x10,                                # POP DI; ADD DI,10h
    0x59,                                                  # POP CX
    0xE2, 0xE1,                                            # LOOP outer_loop
    # Call text display: F000:0701(type=1, Y=0x0173, seg=4000, off=1200)
    0x68, 0x00, 0x40,                                      # PUSH 4000h (string segment)
    0x68, 0x00, 0x12,                                      # PUSH 1200h (string offset)
    0x68, 0x73, 0x01,                                      # PUSH 0173h (Y position)
    0x6A, 0x01,                                            # PUSH 01h   (font type 1)
    0x9A, 0x01, 0x07, 0x00, 0xF0,                          # CALL FAR F000:0701
    0x83, 0xC4, 0x08,                                      # ADD SP,8
    # Wait for START button
    0xBB, 0x00, 0x40,                                      # MOV BX,4000h
    0x8E, 0xC3,                                            # MOV ES,BX
    # wait_loop:
    0x26, 0x80, 0x3E, 0x47, 0x11, 0x00,                    # CMP BYTE ES:[1147h],0
    0x74, 0xF8,                                            # JE wait_loop
    # Debounce: wait for release
    0x26, 0x8B, 0x1E, 0x50, 0x11,                          # MOV BX,ES:[1150h]
    0x26, 0x8A, 0x07,                                      # MOV AL,ES:[BX]
    0x3C, 0x40,                                            # CMP AL,40h
    0x74, 0x08,                                            # JE released
    0x26, 0xC6, 0x06, 0x47, 0x11, 0x00,                    # MOV BYTE ES:[1147h],0
    0xEB, 0xE4,                                            # JMP wait_loop
    # released:
    0x26, 0xC6, 0x07, 0x00,                                # MOV BYTE ES:[BX],0
    0x26, 0xC6, 0x06, 0x47, 0x11, 0x00,                    # MOV BYTE ES:[1147h],0
    0xCB,                                                  # RETF
])

# Trampoline at C000:00D0 (11 bytes)
# Called from SPECIAL path hook (D5076).
# Shows PRESS START first, then executes original displaced call.
TRAMPOLINE_OFFSET = 0x00D0
TRAMPOLINE_DATA = bytes([
    0x9A, 0x10, 0x00, 0x00, 0xC0,      # CALL FAR C000:0010 (PRESS START)
    0x9A, 0xF2, 0x37, 0x2A, 0xD7,      # CALL FAR D72A:37F2 (original call)
    0xCB,                               # RETF
])

# Hook patches (original -> new instruction bytes)
PATCHES = [
    {
        'name': 'SPECIAL path hook',
        'description': 'D5076: CALL FAR D72A:37F2 -> CALL FAR C000:00D0',
        'physical_address': 0xD5076,
        'original': bytes([0x9A, 0xF2, 0x37, 0x2A, 0xD7]),
        'patched':  bytes([0x9A, 0xD0, 0x00, 0x00, 0xC0]),
    },
    {
        'name': 'Normal path hook',
        'description': 'D5122: CALL FAR F000:174D -> CALL FAR C000:0010',
        'physical_address': 0xD5122,
        'original': bytes([0x9A, 0x4D, 0x17, 0x00, 0xF0]),
        'patched':  bytes([0x9A, 0x10, 0x00, 0x00, 0xC0]),
    },
]

# Code cave locations (written to empty 0xFF space)
CODE_CAVES = [
    {
        'name': 'PRESS START code cave',
        'physical_address': 0xC0000 + CODE_CAVE_OFFSET,
        'data': CODE_CAVE_DATA,
    },
    {
        'name': 'SPECIAL trampoline',
        'physical_address': 0xC0000 + TRAMPOLINE_OFFSET,
        'data': TRAMPOLINE_DATA,
    },
]


# =============================================================================
# Patching logic
# =============================================================================

def physical_to_rom1(addr):
    """Convert physical address to ROM1 file offset."""
    return addr - 0x80000


def validate_rom(rom_data, is_combined):
    """Validate ROM file size and check patch locations."""
    expected_size = 0x100000 if is_combined else 0x80000
    if len(rom_data) != expected_size:
        print(f"ERROR: Expected {expected_size // 1024}KB "
              f"({'combined' if is_combined else 'ROM1'}), "
              f"got {len(rom_data)} bytes.", file=sys.stderr)
        return False

    rom1_base = 0x80000 if is_combined else 0x00000
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
        description='IO Moon Pinball - PRESS START Patch',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  %(prog)s io_moon_rom1.bin
  %(prog)s io_moon_rom1.bin --output io_moon_rom1_patched.bin
  %(prog)s io_moon_combined.bin --combined-rom
        """,
    )
    parser.add_argument('rom_file', help='Input ROM file to patch')
    parser.add_argument('--combined-rom', action='store_true',
                        help='Input is a 1MB combined ROM (ROM0+ROM1)')
    parser.add_argument('--output', '-o', default=None,
                        help='Output filename (default: <name>_patched.<ext>)')
    args = parser.parse_args()

    input_path = Path(args.rom_file)
    if not input_path.is_file():
        print(f"ERROR: File not found: {input_path}", file=sys.stderr)
        sys.exit(1)

    # Determine output path
    if args.output:
        output_path = Path(args.output)
    else:
        output_path = input_path.with_name(
            f"{input_path.stem}_patched{input_path.suffix}")

    rom_type = "combined (1MB)" if args.combined_rom else "ROM1 (512KB)"

    print(f"IO Moon Pinball - PRESS START Patch")
    print(f"{'=' * 40}")
    print(f"Input:  {input_path}")
    print(f"Type:   {rom_type}")
    print(f"Output: {output_path}")
    print()

    # Load ROM
    rom_data = input_path.read_bytes()
    input_md5 = hashlib.md5(rom_data).hexdigest()
    print(f"Input MD5:  {input_md5}")
    print(f"Input size: {len(rom_data)} bytes ({len(rom_data) // 1024}KB)")
    print()

    # Validate
    print("Validating ROM...")
    if not validate_rom(rom_data, args.combined_rom):
        sys.exit(1)

    # Check if already patched
    if is_already_patched(rom_data, args.combined_rom):
        print("\nROM is already patched. No changes needed.")
        sys.exit(0)

    # Apply patches
    print("\nApplying patches...")
    patched_rom = apply_patches(rom_data, args.combined_rom)

    # Verify
    output_md5 = hashlib.md5(patched_rom).hexdigest()
    print(f"\nOutput MD5: {output_md5}")

    # Write output
    output_path.write_bytes(patched_rom)
    print(f"Written:    {output_path} ({len(patched_rom)} bytes)")
    print("\nPatch applied successfully!")


if __name__ == '__main__':
    main()
