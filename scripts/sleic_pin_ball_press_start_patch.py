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
hooks; the digit-glyph blitter (`digits_draw`) and the `PRESS START` string
record (`PROMPT_RECORD`) are written and `nasm`-verified but not yet placed
in the cave, so the patch payload is not yet implemented.
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

CAVE_PLACEHOLDER_DATA = bytes([0x90])

CAVES = ((CAVE_PLACEHOLDER, CAVE_PLACEHOLDER_DATA, "single-byte NOP filler"),)
HOOKS = ()

# =============================================================================
# The 8-row glyph face and its blitters
# =============================================================================

# F000:85EB, 50 glyphs of the 8-row face: 0-9 digits, 10 space, 11.. A-Z with
# N-tilde after N.  Byte-aligned, 8 bytes per cell: glyph index*8 + base
# addresses a cell, exactly as F000:43C5 computes it.
GLYPH_FACE_ADDR = 0x85EB

# Provisional; the cave's own layout is not settled yet and moves this.
DIGITS_DRAW_ADDR = 0xFDFF1

# SI = an 8-byte digit buffer in segment 0 (values 0-9, or 0xFF for a blanked
# leading zero), DI = the buffer offset of the leftmost cell, ES = 0x6000.
# Draws eight glyphs of GLYPH_FACE_ADDR, one column apart, into both display
# planes (DI and DI+0x800), each eight rows at a 0x20 stride.  A digit value
# is already its own glyph index (0-9); 0xFF draws index 10 (space).  Returns
# with SI and DI advanced past the eight cells; AX, BX, CX and DX clobbered.
DIGITS_DRAW_ASM = f"""BITS 16
org 0x{DIGITS_DRAW_ADDR:04X}

digits_draw:
        mov dx, 8
.glyph:
        mov al, [si]
        cmp al, 0xFF
        jne .idx
        mov al, 10
.idx:
        xor ah, ah
        mov bx, ax
        add bx, bx
        add bx, bx
        add bx, bx
        add bx, 0x{GLYPH_FACE_ADDR:04X}
        mov cx, 8
        push di
.row:
        mov al, [cs:bx]
        mov [es:di], al
        mov [es:di+0x800], al
        inc bx
        add di, 0x20
        loop .row
        pop di
        inc di
        inc si
        dec dx
        jnz .glyph
        ret
"""

DIGITS_DRAW = bytes([
    0xBA, 0x08, 0x00,                    # mov dx, 8             ; 8 glyph columns
    0x8A, 0x04,                          # .glyph: mov al, [si]  ; digit value (DS=0)
    0x3C, 0xFF,                          # cmp al, 0xFF
    0x75, 0x02,                          # jne .idx
    0xB0, 0x0A,                          # mov al, 10            ; blanked -> space glyph
    0x30, 0xE4,                          # .idx: xor ah, ah
    0x89, 0xC3,                          # mov bx, ax
    0x01, 0xDB,                          # add bx, bx  ]
    0x01, 0xDB,                          # add bx, bx  ] bx = index*8
    0x01, 0xDB,                          # add bx, bx  ]
    0x81, 0xC3, 0xEB, 0x85,              # add bx, 0x85EB        ; bx = glyph address
    0xB9, 0x08, 0x00,                    # mov cx, 8             ; 8 rows
    0x57,                                # push di               ; save the column
    0x2E, 0x8A, 0x07,                    # .row: mov al, [cs:bx]
    0x26, 0x88, 0x05,                    # mov [es:di], al       ; plane 1
    0x26, 0x88, 0x85, 0x00, 0x08,        # mov [es:di+0x800], al ; plane 2
    0x43,                                # inc bx
    0x83, 0xC7, 0x20,                    # add di, 0x20
    0xE2, 0xEF,                          # loop .row
    0x5F,                                # pop di
    0x47,                                # inc di                ; next glyph column
    0x46,                                # inc si                ; next digit
    0x4A,                                # dec dx
    0x75, 0xCF,                          # jnz .glyph
    0xC3,                                # ret
])

# 'PRESS START' as a [count][pointer...] record in the ROM's own string-record
# shape: a word count followed by that many word glyph pointers into
# GLYPH_FACE_ADDR.  N-tilde sits between N and O in the face, so every letter
# from O on is one higher than its plain-Latin-alphabet position.
PROMPT_TEXT = 'PRESS START'
_ALPHA = 'ABCDEFGHIJKLMNÑOPQRSTUVWXYZ'


def _glyph_index(ch):
    return 10 if ch == ' ' else 11 + _ALPHA.index(ch)


def _glyph_ptr(ch):
    return GLYPH_FACE_ADDR + 8 * _glyph_index(ch)


PROMPT_RECORD = (len(PROMPT_TEXT).to_bytes(2, 'little') +
                 b''.join(_glyph_ptr(ch).to_bytes(2, 'little') for ch in PROMPT_TEXT))


# =============================================================================
# Segment-0 workspace and the per-player score digit reader
# =============================================================================

# The whole patch's scratch RAM: 8 bytes of digit buffer, then 1 byte for the
# stub's DRAWN flag. Segment 0 below 0x100 is the interrupt vector table,
# copied from F000:FEF0 at boot, so the workspace must sit above it; nothing
# initialises segment 0 above 0x100 at power-on either way. Claimed from the
# 0x377-0x3E7 run (113 bytes, the largest of four measured candidate runs
# that no direct-address instruction in the image reaches), 9 bytes well
# inside it.
WORKSPACE_ADDR = 0x3A0
DRAWN_ADDR = WORKSPACE_ADDR + 8

# Provisional; the cave's own layout is not settled yet and moves this.
SCORE_DIGITS_ADDR = DIGITS_DRAW_ADDR + len(DIGITS_DRAW)

# BX = a player's block base (E000:190F table entry), DI = an 8-byte scratch
# buffer offset in segment 0 (WORKSPACE_ADDR), DS = 0. Reads the block's eight
# unpacked decimal digits from [BX+11] (the 10^7 place) down to [BX+4] (units)
# and stores them forward into the buffer, so the buffer comes out most
# significant digit first. Then blanks leading zeros to 0xFF, stopping at the
# first non-zero digit, so an all-zero score is left as seven 0xFF followed by
# a single 0 in the units position rather than eight blanks. Returns with DI
# restored to the buffer's first byte; BX, ES and DS untouched; AX, CX and SI
# clobbered.
SCORE_DIGITS_ASM = f"""BITS 16
org 0x{SCORE_DIGITS_ADDR:04X}

score_digits:
        mov si, bx
        add si, 11
        mov cx, 8
.copy:
        mov al, [si]
        mov [di], al
        dec si
        inc di
        loop .copy
        sub di, 8
        mov si, di
        mov cx, 7
.blank:
        cmp byte [si], 0
        jne .done
        mov byte [si], 0xFF
        inc si
        loop .blank
.done:
        ret
"""

SCORE_DIGITS = bytes([
    0x89, 0xDE,                          # mov si, bx            ; SI = block base
    0x83, 0xC6, 0x0B,                    # add si, 11             ; SI = block+11, the MSD
    0xB9, 0x08, 0x00,                    # mov cx, 8              ; 8 digits
    0x8A, 0x04,                          # .copy: mov al, [si]
    0x88, 0x05,                          # mov [di], al           ; MSD-first into the buffer
    0x4E,                                # dec si                 ; next digit toward the LSD
    0x47,                                # inc di
    0xE2, 0xF8,                          # loop .copy
    0x83, 0xEF, 0x08,                    # sub di, 8              ; DI -> buffer start
    0x89, 0xFE,                          # mov si, di
    0xB9, 0x07, 0x00,                    # mov cx, 7              ; up to 7 leading digits
    0x80, 0x3C, 0x00,                    # .blank: cmp byte [si], 0
    0x75, 0x06,                          # jne .done              ; first non-zero: stop blanking
    0xC6, 0x04, 0xFF,                    # mov byte [si], 0xFF    ; blank a leading zero
    0x46,                                # inc si
    0xE2, 0xF5,                          # loop .blank
    0xC3,                                # .done: ret
])


# =============================================================================
# The screen composer
# =============================================================================

# Data, not code: the eleven-glyph prompt record from the previous section,
# placed after score_digits. Provisional, like the two addresses above it.
PROMPT_RECORD_ADDR = SCORE_DIGITS_ADDR + len(SCORE_DIGITS)

# Provisional; the cave's own layout is not settled yet and moves this.
DRAW_SCREEN_ADDR = PROMPT_RECORD_ADDR + len(PROMPT_RECORD)

# Takes no arguments; DS = 0 and CS = F000 on entry (the stub far-calls it).
# Clears both display planes through F000:DEFC, which also sets ES = 0x6000,
# then for each player 1..PLAYER_COUNT reads that player's block with
# score_digits into WORKSPACE_ADDR and draws it with digits_draw at that
# player's plane-1 slot, then draws PROMPT_RECORD twice with F000:550D, once
# per plane. Far ret. The player index lives in BP, the one register neither
# callee touches; the two four-word tables translate it into a block base and
# a target slot without a multiply. The caller's own BP is saved on entry and
# restored before the single retf, so BP is the one register this routine
# does not clobber.
DRAW_SCREEN_ASM = f"""BITS 16
org 0x{DRAW_SCREEN_ADDR:04X}

draw_screen:
        push bp
        call 0xF000:0xDEFC
        mov bp, 1
.loop:
        mov al, [0x106]
        xor ah, ah
        cmp ax, bp
        jb .prompt
        mov bx, bp
        dec bx
        add bx, bx
        mov bx, [cs:bx+block_table]
        mov di, 0x{WORKSPACE_ADDR:04X}
        call 0x{SCORE_DIGITS_ADDR:04X}
        mov si, di
        mov di, bp
        dec di
        add di, di
        mov di, [cs:di+slot_table]
        call 0x{DIGITS_DRAW_ADDR:04X}
        inc bp
        jmp .loop
.prompt:
        mov si, 0x{PROMPT_RECORD_ADDR & 0xFFFF:04X}
        mov di, 0x712
        call 0x550D
        mov si, 0x{PROMPT_RECORD_ADDR & 0xFFFF:04X}
        mov di, 0xF12
        call 0x550D
        pop bp
        retf

block_table: dw 0x1E7, 0x209, 0x22B, 0x24D
slot_table:  dw 0x410, 0x418, 0x510, 0x518
"""

DRAW_SCREEN = bytes([
    0x55,                                 # push bp                ; save the caller's BP
    0x9A, 0xFC, 0xDE, 0x00, 0xF0,         # call 0xF000:0xDEFC    ; clear buffer, ES=0x6000
    0xBD, 0x01, 0x00,                     # mov bp, 1             ; player index, 1-based
    0xA0, 0x06, 0x01,                     # .loop: mov al, [0x106]; PLAYER_COUNT
    0x30, 0xE4,                           # xor ah, ah
    0x39, 0xE8,                           # cmp ax, bp
    0x72, 0x22,                           # jb .prompt            ; count < index -> done
    0x89, 0xEB,                           # mov bx, bp
    0x4B,                                 # dec bx
    0x01, 0xDB,                           # add bx, bx            ; bx = (index-1)*2
    0x2E, 0x8B, 0x9F, 0xAA, 0xE0,         # mov bx, [cs:bx+block_table]
    0xBF, 0xA0, 0x03,                     # mov di, 0x3A0         ; WORKSPACE_ADDR
    0xE8, 0xA2, 0xFF,                     # call 0xFE026          ; score_digits
    0x89, 0xFE,                           # mov si, di            ; si = digit buffer
    0x89, 0xEF,                           # mov di, bp
    0x4F,                                 # dec di
    0x01, 0xFF,                           # add di, di            ; di = (index-1)*2
    0x2E, 0x8B, 0xBD, 0xB2, 0xE0,         # mov di, [cs:di+slot_table]
    0xE8, 0x5E, 0xFF,                     # call 0xFDFF1          ; digits_draw
    0x45,                                 # inc bp
    0xEB, 0xD5,                           # jmp .loop
    0xBE, 0x4A, 0xE0,                     # .prompt: mov si, 0xE04A ; PROMPT_RECORD
    0xBF, 0x12, 0x07,                     # mov di, 0x712
    0xE8, 0x6E, 0x74,                     # call 0x550D
    0xBE, 0x4A, 0xE0,                     # mov si, 0xE04A
    0xBF, 0x12, 0x0F,                     # mov di, 0xF12
    0xE8, 0x65, 0x74,                     # call 0x550D
    0x5D,                                 # pop bp                 ; restore the caller's BP
    0xCB,                                 # retf
    0xE7, 0x01, 0x09, 0x02, 0x2B, 0x02, 0x4D, 0x02,  # block_table: dw 0x1E7,0x209,0x22B,0x24D
    0x10, 0x04, 0x18, 0x04, 0x10, 0x05, 0x18, 0x05,  # slot_table:  dw 0x410,0x418,0x510,0x518
])


# =============================================================================
# The hold stub
# =============================================================================

# A second word beside DRAWN_ADDR, in the same claimed 0x377-0x3E7 run: the
# sequence index a game-over trampoline would otherwise have written to
# [0x17D] (23 nine games in ten, 1 on the tenth). The stub restores it once
# START is seen, so the dispatcher's very next tick runs exactly the step
# the game would have run.
SAVED_ADDR = WORKSPACE_ADDR + 9

# The sequence table's spare slot: entries run 0-24, wrap at 24->0, and no
# write to [017D] anywhere in the image produces 25, so this entry is
# unreachable except through a game-over trampoline pointing at it. The
# table entry is a near offset in segment E000, so unlike every other blob
# in this file the stub's address is real, not provisional -- it is the
# start of the 44,821-byte 0xFF run reaching the end of the segment.
STUB_ADDR = 0x50EB

# Reached as entry 25 of the [0000:017D] sequence dispatcher, re-entered
# every tick while [017D] stays 25. DS = 0 on entry (every dispatcher and
# step access is DS-relative). Not yet drawn (DRAWN_ADDR == 0): clears both
# display planes and composes the score screen once, sets DRAWN_ADDR, then
# falls into holding. Already drawn: polls the switch FIFO once per tick
# and otherwise just holds -- a `ret` with [0x4DF] set to 0 so the
# dispatcher re-enters immediately on the next tick and [017D] never
# advances past 25. On seeing START (code 5) it drains the FIFO until empty
# (a real contact reports twice with no debounce, so a duplicate START must
# not leak into the next screen), restores [017D] from SAVED_ADDR and
# returns, handing the very next tick to whichever step the game would have
# reached. Clobbers AX; DS/ES/other registers not touched.
STUB_ASM = f"""BITS 16
org 0x{STUB_ADDR:04X}

stub:
        cmp byte [0x{DRAWN_ADDR:04X}], 0
        jne poll
        call 0xF000:0xDEFC
        call 0xF000:0x{DRAW_SCREEN_ADDR & 0xFFFF:04X}
        mov byte [0x{DRAWN_ADDR:04X}], 1
        jmp hold
poll:
        call 0xF000:0x54EF
        or al, al
        je hold
        cmp al, 5
        jne poll
drain:
        call 0xF000:0x54EF
        or al, al
        jne drain
        mov ax, [0x{SAVED_ADDR:X}]
        mov word [0x17D], ax
        ret
hold:
        mov word [0x4DF], 0
        ret
"""

STUB = bytes([
    0x80, 0x3E, 0xA8, 0x03, 0x00,          # stub: cmp byte [DRAWN_ADDR], 0
    0x75, 0x11,                            # jne poll                ; already composed
    0x9A, 0xFC, 0xDE, 0x00, 0xF0,          # call 0xF000:0xDEFC      ; clear both planes
    0x9A, 0x62, 0xE0, 0x00, 0xF0,          # call 0xF000:0xE062      ; draw_screen
    0xC6, 0x06, 0xA8, 0x03, 0x01,          # mov byte [DRAWN_ADDR], 1
    0xEB, 0x1D,                            # jmp hold
    0x9A, 0xEF, 0x54, 0x00, 0xF0,          # poll: call 0xF000:0x54EF ; pop a switch code
    0x08, 0xC0,                            # or al, al
    0x74, 0x14,                            # je hold                 ; empty: keep holding
    0x3C, 0x05,                            # cmp al, 5               ; START
    0x75, 0xF3,                            # jne poll                ; discard and keep draining
    0x9A, 0xEF, 0x54, 0x00, 0xF0,          # drain: call 0xF000:0x54EF ; scrub duplicate STARTs
    0x08, 0xC0,                            # or al, al
    0x75, 0xF7,                            # jne drain
    0xA1, 0xA9, 0x03,                      # mov ax, [SAVED_ADDR]
    0xA3, 0x7D, 0x01,                      # mov word [0x17D], ax
    0xC3,                                  # ret                     ; the dispatcher runs the saved step next
    0xC7, 0x06, 0xDF, 0x04, 0x00, 0x00,    # hold: mov word [0x4DF], 0 ; no delay: re-enter next tick
    0xC3,                                  # ret                     ; [017D] still 25
])


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
