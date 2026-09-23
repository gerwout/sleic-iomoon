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

Two padding regions hold the payload, both erased to `0xFF` in the stock ROM:
`0xE50EB`-`0xEFFFF` (segment E000, the hold stub, its two game-over
trampolines and the attract loop's two credit-gate trampolines) and
`0xFDFF0`-`0xFFE76` (segment F000, the digit blitter, the per-player digit
reader, the `PRESS START` string record and the screen composer). Five hooks
wire the payload into the sequence table, the two game-over paths, and the
attract loop's two identical credit tests -- both of which otherwise skip
the score screen whenever a credit is standing, which free play always
leaves true. The loop's only entrance is the first test; the second is
reachable only from inside the loop.

The two game-over trampolines also snapshot the score data: the attract
loop's own entry preamble (E000:00AD-00CB, via its call to E000:07BD) zeroes
the live player block and all four saved player blocks before the stub's
first tick can run, so score_digits reads that snapshot rather than the
(by then zeroed) live blocks.

Verified (`build-probe`, `Balls>0`, headless, RAM ground truth cross-checked
against the panel's own rendered pixels bit-for-bit):

| check | result |
|---|---|
| screen appears at game over, 1 and 4 players | pass |
| each player's score matches what was actually scored | pass -- confirmed pixel-exact against the font table in both a 1-player and a 4-player game |
| one START press releases it | pass -- within the same sampled tick |
| a press reported twice does not disturb anything | pass |
| credits standing | pass |
| credits exhausted | pass |
| a coin inserted while held is not lost | pass |
| service menu opens and closes | pass |
| `MAME_DEBUG` validity checks | pass |
| three games back to back, each with its own scores | pass |
| `Balls` ships at 0 on the permanent set | not this patch's concern, but the trough model is off by default -- a game cannot reach game over without `Balls>0`, in the DIP menu or a build override |
| record-beating score reaches name entry after the lottery | not tested |
| `¿ CONTINUAS ?` offer resolves (accept/decline) | not verified -- confirmed still armed and blinking identically in stock and patched builds well past where it should time out; a START press during the window did not visibly change it. Whatever settles this needs a real machine or a scope, not more headless probing |
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
# The images this accepts: stock V1.1, plus every patched variant.
V11_FAMILY_CRC32 = (
    0x261b0ae4,   # sp03-1_1.rom, stock V1.1
    0x7861e7cd,   # + PRESS START
    0xf82af142,   # + free play (sleic_pin_ball_free_play_patch.py)
    0xa6501c6b,   # + both, either order
)

# CAVES and HOOKS are assembled at the end of this file, once every blob and
# every hook's replacement bytes exist.

# =============================================================================
# The 8-row glyph face and its blitters
# =============================================================================

# F000:85EB, 50 glyphs of the 8-row face: 0-9 digits, 10 space, 11.. A-Z with
# N-tilde after N.  Byte-aligned, 8 bytes per cell: glyph index*8 + base
# addresses a cell, exactly as F000:43C5 computes it.
GLYPH_FACE_ADDR = 0x85EB

# F000 padding starts at 0xFDFF0 (7,815 bytes, all 0xFF up to 0xFE76); this is
# the first of the four blobs packed into it.
DIGITS_DRAW_ADDR = 0xFDFF0

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

# The whole patch's scratch RAM: 8 bytes of digit buffer, 1 byte for the
# stub's DRAWN flag, a 2-byte SAVED_ADDR word, 1 byte for COUNT_ADDR, then a
# 32-byte score snapshot (4 players x 8 digit bytes). Segment 0 below 0x100
# is the interrupt vector table, copied from F000:FEF0 at boot, so the
# workspace must sit above it; nothing initialises segment 0 above 0x100 at
# power-on either way. Claimed from the 0x377-0x3E7 run (113 bytes, the
# largest of four measured candidate runs that no direct-address instruction
# in the image reaches), 44 bytes (0x3A0-0x3CB) well inside it.
WORKSPACE_ADDR = 0x3A0
DRAWN_ADDR = WORKSPACE_ADDR + 8

# The trampolines snapshot [0x106] (PLAYER_COUNT) here before the game-over
# tail zeroes it, since draw_screen cannot run until the attract loop's next
# dispatch -- by which time [0x106] already reads 0. draw_screen reads this
# instead of [0x106].
COUNT_ADDR = WORKSPACE_ADDR + 11

# The same problem hits the scores, worse: E000:07BD, called from the attract
# loop's own entry preamble (E000:00AD-00CB) ahead of the dispatcher call at
# E000:00F6, zeroes 0x1C5-0x26E -- the live block AND all four saved player
# blocks -- before the stub's first tick can ever run. A trampoline must copy
# the scores out at the same point it already copies PLAYER_COUNT: player n's
# eight digit bytes (block+4..block+11, LSD to MSD, the same order they sit
# in at the source) land at SCORE_SNAPSHOT_ADDR + 8*(n-1). draw_screen reads
# this instead of the live blocks.
SCORE_SNAPSHOT_ADDR = WORKSPACE_ADDR + 12

# Packed right after digits_draw.
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
# placed after score_digits.
PROMPT_RECORD_ADDR = SCORE_DIGITS_ADDR + len(SCORE_DIGITS)

# Last of the four F000 blobs, right after prompt_record.
DRAW_SCREEN_ADDR = PROMPT_RECORD_ADDR + len(PROMPT_RECORD)

# Takes no arguments; DS = 0 and CS = F000 on entry (the stub far-calls it).
# Clears both display planes through F000:DEFC, which also sets ES = 0x6000,
# then for each player 1..count (read from COUNT_ADDR, the trampolines'
# snapshot of [0x106] -- by the time draw_screen runs, [0x106] itself has
# already been zeroed by the game-over tail) reads that player's eight digit
# bytes out of SCORE_SNAPSHOT_ADDR (the trampolines' snapshot -- the live
# blocks are zeroed by then too, by the attract loop's own entry preamble)
# with score_digits into WORKSPACE_ADDR and draws it with digits_draw at that
# player's plane-1 slot, then draws PROMPT_RECORD twice with F000:550D, once
# per plane. Far ret. The player index lives in BP, the one register neither
# callee touches; score_digits' own +4/+11 indexing is reused as-is by
# pointing BX four bytes before the player's snapshot slot, so no snapshot
# table is needed, only the target-slot table. The caller's own BP is saved
# on entry and restored before the single retf, so BP is the one register
# this routine does not clobber.
DRAW_SCREEN_ASM = f"""BITS 16
org 0x{DRAW_SCREEN_ADDR:04X}

draw_screen:
        push bp
        call 0xF000:0xDEFC
        mov bp, 1
.loop:
        mov al, [0x{COUNT_ADDR:04X}]
        xor ah, ah
        cmp ax, bp
        jb .prompt
        mov bx, bp
        dec bx
        add bx, bx
        add bx, bx
        add bx, bx
        add bx, 0x{(SCORE_SNAPSHOT_ADDR - 4) & 0xFFFF:04X}
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

slot_table:  dw 0x410, 0x418, 0x510, 0x518
"""

DRAW_SCREEN = bytes([
    0x55,                                 # push bp                ; save the caller's BP
    0x9A, 0xFC, 0xDE, 0x00, 0xF0,         # call 0xF000:0xDEFC    ; clear buffer, ES=0x6000
    0xBD, 0x01, 0x00,                     # mov bp, 1             ; player index, 1-based
    0xA0, 0xAB, 0x03,                     # .loop: mov al, [COUNT_ADDR]; snapshot of PLAYER_COUNT
    0x30, 0xE4,                           # xor ah, ah
    0x39, 0xE8,                           # cmp ax, bp
    0x72, 0x25,                           # jb .prompt            ; count < index -> done
    0x89, 0xEB,                           # mov bx, bp
    0x4B,                                 # dec bx
    0x01, 0xDB,                           # add bx, bx  ]
    0x01, 0xDB,                           # add bx, bx  ] bx = (index-1)*8
    0x01, 0xDB,                           # add bx, bx  ]
    0x81, 0xC3, 0xA8, 0x03,               # add bx, 0x3A8         ; SCORE_SNAPSHOT_ADDR - 4
    0xBF, 0xA0, 0x03,                     # mov di, 0x3A0         ; WORKSPACE_ADDR
    0xE8, 0x9F, 0xFF,                     # call 0xFE025          ; score_digits
    0x89, 0xFE,                           # mov si, di            ; si = digit buffer
    0x89, 0xEF,                           # mov di, bp
    0x4F,                                 # dec di
    0x01, 0xFF,                           # add di, di            ; di = (index-1)*2
    0x2E, 0x8B, 0xBD, 0xAC, 0xE0,         # mov di, [cs:di+slot_table]
    0xE8, 0x5B, 0xFF,                     # call 0xFDFF0          ; digits_draw
    0x45,                                 # inc bp
    0xEB, 0xD2,                           # jmp .loop
    0xBE, 0x49, 0xE0,                     # .prompt: mov si, 0xE049 ; PROMPT_RECORD
    0xBF, 0x12, 0x07,                     # mov di, 0x712
    0xE8, 0x6C, 0x74,                     # call 0x550D
    0xBE, 0x49, 0xE0,                     # mov si, 0xE049
    0xBF, 0x12, 0x0F,                     # mov di, 0xF12
    0xE8, 0x63, 0x74,                     # call 0x550D
    0x5D,                                 # pop bp                 ; restore the caller's BP
    0xCB,                                 # retf
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
# table entry holds this as a plain near offset in segment E000, so unlike
# every F000 blob in this file (numbered in the 0xF0000+ physical-address
# style) the stub's org is the true segment offset -- it is the start of
# the 44,821-byte 0xFF run reaching the end of the segment.
STUB_ADDR = 0x50EB

# Reached as entry 25 of the [0000:017D] sequence dispatcher, re-entered
# every tick while [017D] stays 25. DS = 0 on entry (every dispatcher and
# step access is DS-relative). Not yet drawn (DRAWN_ADDR == 0): far-calls
# draw_screen, which clears both display planes itself and composes the
# score screen, sets DRAWN_ADDR, then falls into holding. Already drawn:
# peeks the FIFO head through the shared read pointer [0x4E5] rather than
# popping it -- F000:54EF and the attract switch handler (E000:02E1) share
# that pointer, and popping a non-START code here would swallow a coin or
# Test press before 02E1 ever saw it. A head of anything but START (5,
# including an empty queue) just holds. On seeing START at the head, it
# pops that one code for real, then drains the FIFO until empty (a real
# contact reports twice with no debounce, so a duplicate START must not
# leak into the next screen), restores [017D] from SAVED_ADDR and returns,
# handing the very next tick to whichever step the game would have reached.
# Clobbers AX and SI; DS/ES/other registers not touched.
STUB_ASM = f"""BITS 16
org 0x{STUB_ADDR:04X}

stub:
        cmp byte [0x{DRAWN_ADDR:04X}], 0
        jne poll
        call 0xF000:0x{DRAW_SCREEN_ADDR & 0xFFFF:04X}
        mov byte [0x{DRAWN_ADDR:04X}], 1
        jmp hold
poll:
        mov si, [0x4E5]
        cmp byte [si], 5
        jne hold
        call 0xF000:0x54EF
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
    0x75, 0x0C,                            # jne poll                ; already composed
    0x9A, 0x61, 0xE0, 0x00, 0xF0,          # call 0xF000:0xE061      ; draw_screen (clears both planes)
    0xC6, 0x06, 0xA8, 0x03, 0x01,          # mov byte [DRAWN_ADDR], 1
    0xEB, 0x1E,                            # jmp hold
    0x8B, 0x36, 0xE5, 0x04,                # poll: mov si, [0x4E5]   ; FIFO read pointer
    0x80, 0x3C, 0x05,                      # cmp byte [si], 5        ; peek, don't pop
    0x75, 0x15,                            # jne hold                ; not START: leave it queued
    0x9A, 0xEF, 0x54, 0x00, 0xF0,          # call 0xF000:0x54EF      ; it is START: pop it for real
    0x9A, 0xEF, 0x54, 0x00, 0xF0,          # drain: call 0xF000:0x54EF ; scrub duplicate STARTs
    0x08, 0xC0,                            # or al, al
    0x75, 0xF7,                            # jne drain
    0xA1, 0xA9, 0x03,                      # mov ax, [SAVED_ADDR]
    0xA3, 0x7D, 0x01,                      # mov word [0x17D], ax
    0xC3,                                  # ret                     ; the dispatcher runs the saved step next
    0xC7, 0x06, 0xDF, 0x04, 0x00, 0x00,    # hold: mov word [0x4DF], 0 ; no delay: re-enter next tick
    0xC3,                                  # ret                     ; [017D] still 25
])


# =============================================================================
# The two game-over trampolines and the sequence-table hook
# =============================================================================

# Packed right after the stub, in the same 0xE50EB-upward padding run.
TRAMPOLINE_COMMON_ADDR = STUB_ADDR + len(STUB)

# The four saved player blocks, per research/sleicpin_disasm/sleicpin_endgame.md.
# Each trampoline copies block+4..block+11 (eight digit bytes, LSD to MSD)
# into the score snapshot before the attract loop's own entry preamble
# (E000:00AD-00CB, via its call to E000:07BD) zeroes 0x1C5-0x26E -- the live
# block and all four of these -- ahead of the dispatcher's first tick.
SCORE_BLOCK_BASES = (0x1E7, 0x209, 0x22B, 0x24D)

# Reached from the common game-over tail (E000:197C -- nine games in ten,
# per the branch at E000:1919 on the NVRAM game counter [0x66D]), while
# [0x106] (PLAYER_COUNT) and the four score blocks above are still live --
# the same tail's caller zeroes them all a few instructions later, before
# the dispatcher's next tick can reach the stub. Records 0x17, the index
# that tail's own stock mov would have written to [017D], snapshots [0x106]
# into COUNT_ADDR and the four blocks into SCORE_SNAPSHOT_ADDR for
# draw_screen to read, clears DRAWN_ADDR so the stub composes a fresh
# screen, points the dispatcher at entry 25, and returns -- the same ret the
# stock tail took. ES is saved and set equal to DS for the four `rep movsb`
# copies (DF is already clear on entry -- nothing in this ROM sets it -- but
# `cld` costs one byte and removes the doubt) and restored before returning.
TRAMPOLINE_COMMON_ASM = f"""BITS 16
org 0x{TRAMPOLINE_COMMON_ADDR:04X}

trampoline_common:
        mov word [0x{SAVED_ADDR:X}], 0x17
        mov byte [0x{DRAWN_ADDR:04X}], 0
        mov al, [0x106]
        mov [0x{COUNT_ADDR:04X}], al
        push es
        push ds
        pop es
        cld
        mov di, 0x{SCORE_SNAPSHOT_ADDR:04X}
        mov si, 0x{SCORE_BLOCK_BASES[0] + 4:04X}
        mov cx, 8
        rep movsb
        mov si, 0x{SCORE_BLOCK_BASES[1] + 4:04X}
        mov cx, 8
        rep movsb
        mov si, 0x{SCORE_BLOCK_BASES[2] + 4:04X}
        mov cx, 8
        rep movsb
        mov si, 0x{SCORE_BLOCK_BASES[3] + 4:04X}
        mov cx, 8
        rep movsb
        pop es
        mov word [0x17D], 25
        ret
"""

TRAMPOLINE_COMMON = bytes([
    0xC7, 0x06, 0xA9, 0x03, 0x17, 0x00,    # mov word [SAVED_ADDR], 0x17
    0xC6, 0x06, 0xA8, 0x03, 0x00,          # mov byte [DRAWN_ADDR], 0
    0xA0, 0x06, 0x01,                      # mov al, [0x106]         ; PLAYER_COUNT, still live here
    0xA2, 0xAB, 0x03,                      # mov [COUNT_ADDR], al    ; snapshot for draw_screen
    0x06,                                  # push es
    0x1E,                                  # push ds
    0x07,                                  # pop es                  ; es = ds = 0
    0xFC,                                  # cld
    0xBF, 0xAC, 0x03,                      # mov di, SCORE_SNAPSHOT_ADDR
    0xBE, 0xEB, 0x01,                      # mov si, 0x1EB           ; block 0x1E7 + 4
    0xB9, 0x08, 0x00,                      # mov cx, 8
    0xF3, 0xA4,                            # rep movsb
    0xBE, 0x0D, 0x02,                      # mov si, 0x20D           ; block 0x209 + 4
    0xB9, 0x08, 0x00,                      # mov cx, 8
    0xF3, 0xA4,                            # rep movsb
    0xBE, 0x2F, 0x02,                      # mov si, 0x22F           ; block 0x22B + 4
    0xB9, 0x08, 0x00,                      # mov cx, 8
    0xF3, 0xA4,                            # rep movsb
    0xBE, 0x51, 0x02,                      # mov si, 0x251           ; block 0x24D + 4
    0xB9, 0x08, 0x00,                      # mov cx, 8
    0xF3, 0xA4,                            # rep movsb
    0x07,                                  # pop es
    0xC7, 0x06, 0x7D, 0x01, 0x19, 0x00,    # mov word [0x17D], 25
    0xC3,                                  # ret
])

# Packed right after trampoline_common.
TRAMPOLINE_TENTH_ADDR = TRAMPOLINE_COMMON_ADDR + len(TRAMPOLINE_COMMON)

# Reached from the tenth-game tail (E000:1962), the branch's other target,
# while [0x106] and the four score blocks are likewise still live. Identical
# to trampoline_common except it records 0x01, the index that tail's own
# stock mov would have written.
TRAMPOLINE_TENTH_ASM = f"""BITS 16
org 0x{TRAMPOLINE_TENTH_ADDR:04X}

trampoline_tenth:
        mov word [0x{SAVED_ADDR:X}], 0x01
        mov byte [0x{DRAWN_ADDR:04X}], 0
        mov al, [0x106]
        mov [0x{COUNT_ADDR:04X}], al
        push es
        push ds
        pop es
        cld
        mov di, 0x{SCORE_SNAPSHOT_ADDR:04X}
        mov si, 0x{SCORE_BLOCK_BASES[0] + 4:04X}
        mov cx, 8
        rep movsb
        mov si, 0x{SCORE_BLOCK_BASES[1] + 4:04X}
        mov cx, 8
        rep movsb
        mov si, 0x{SCORE_BLOCK_BASES[2] + 4:04X}
        mov cx, 8
        rep movsb
        mov si, 0x{SCORE_BLOCK_BASES[3] + 4:04X}
        mov cx, 8
        rep movsb
        pop es
        mov word [0x17D], 25
        ret
"""

TRAMPOLINE_TENTH = bytes([
    0xC7, 0x06, 0xA9, 0x03, 0x01, 0x00,    # mov word [SAVED_ADDR], 0x01
    0xC6, 0x06, 0xA8, 0x03, 0x00,          # mov byte [DRAWN_ADDR], 0
    0xA0, 0x06, 0x01,                      # mov al, [0x106]         ; PLAYER_COUNT, still live here
    0xA2, 0xAB, 0x03,                      # mov [COUNT_ADDR], al    ; snapshot for draw_screen
    0x06,                                  # push es
    0x1E,                                  # push ds
    0x07,                                  # pop es                  ; es = ds = 0
    0xFC,                                  # cld
    0xBF, 0xAC, 0x03,                      # mov di, SCORE_SNAPSHOT_ADDR
    0xBE, 0xEB, 0x01,                      # mov si, 0x1EB           ; block 0x1E7 + 4
    0xB9, 0x08, 0x00,                      # mov cx, 8
    0xF3, 0xA4,                            # rep movsb
    0xBE, 0x0D, 0x02,                      # mov si, 0x20D           ; block 0x209 + 4
    0xB9, 0x08, 0x00,                      # mov cx, 8
    0xF3, 0xA4,                            # rep movsb
    0xBE, 0x2F, 0x02,                      # mov si, 0x22F           ; block 0x22B + 4
    0xB9, 0x08, 0x00,                      # mov cx, 8
    0xF3, 0xA4,                            # rep movsb
    0xBE, 0x51, 0x02,                      # mov si, 0x251           ; block 0x24D + 4
    0xB9, 0x08, 0x00,                      # mov cx, 8
    0xF3, 0xA4,                            # rep movsb
    0x07,                                  # pop es
    0xC7, 0x06, 0x7D, 0x01, 0x19, 0x00,    # mov word [0x17D], 25
    0xC3,                                  # ret
])


# =============================================================================
# The attract loop's credit gate
# =============================================================================

# The attract/credit-wait loop contains two byte-identical credit tests
# (E000:00D8 and E000:00EC); both gate reaching the dispatcher call at
# E000:00F6 and both are hooked below. Entry 25 of the [0000:017D] sequence
# dispatcher is the patch's own spare slot (STUB_ADDR), so a pending score
# screen is recognised the same way the stub itself is entered: [0x17D] ==
# 25. While it holds, both trampolines keep the machine in the loop instead
# of letting it leave to start a game; E000:4F4E itself early-returns
# whenever [0x4DF], [0x27E] or [0x2C1] is non-zero, none of which is cleared
# by re-entering the loop, so a coin cannot start a game in that window
# where stock would have allowed it.

# Packed right after trampoline_tenth. Reached from the loop's second credit
# test (E000:00EC), which the loop's one call site for the game-over
# dispatcher (E000:00F6) never reaches while a credit is standing -- see
# GAME_OVER_CREDIT_GATE below. When [0x17D] == 25 the screen must keep
# dispatching regardless of credits; otherwise this reproduces the stock
# test byte for byte in behaviour.
TRAMPOLINE_CREDIT_GATE_ADDR = TRAMPOLINE_TENTH_ADDR + len(TRAMPOLINE_TENTH)

TRAMPOLINE_CREDIT_GATE_ASM = f"""BITS 16
org 0x{TRAMPOLINE_CREDIT_GATE_ADDR:04X}

trampoline_credit_gate:
        cmp word [0x17d], 25
        je dispatch
        mov al, [0x100]
        and al, al
        je dispatch
        jmp 0x106
dispatch:
        jmp 0x00F6
"""

TRAMPOLINE_CREDIT_GATE = bytes([
    0x83, 0x3E, 0x7D, 0x01, 0x19,          # cmp word [0x17D], 25   ; our screen pending?
    0x74, 0x0A,                            # je dispatch
    0xA0, 0x00, 0x01,                      # mov al, [0x100]        ; stock test from here
    0x20, 0xC0,                            # and al, al
    0x74, 0x03,                            # je dispatch
    0xE9, 0x52, 0xAF,                      # jmp 0x106              ; credits standing: leave the loop
    0xE9, 0x3F, 0xAF,                      # dispatch: jmp 0x00F6   ; the dispatcher call
])

# Packed right after trampoline_credit_gate. Reached from the loop's first
# credit test (E000:00D8), its only entrance -- reachable from outside the
# loop, whereas E000:00E9 (the second test's own site) is reachable only
# from inside it. Falls back into the loop body at 0x00E2 rather than
# dispatching directly, matching what the stock test itself did there.
TRAMPOLINE_CREDIT_GATE_ENTRANCE_ADDR = TRAMPOLINE_CREDIT_GATE_ADDR + len(TRAMPOLINE_CREDIT_GATE)

TRAMPOLINE_CREDIT_GATE_ENTRANCE_ASM = f"""BITS 16
org 0x{TRAMPOLINE_CREDIT_GATE_ENTRANCE_ADDR:04X}

trampoline_credit_gate_entrance:
        cmp word [0x17d], 25
        je continue
        mov al, [0x100]
        and al, al
        je continue
        jmp 0x106
continue:
        jmp 0x00E2
"""

TRAMPOLINE_CREDIT_GATE_ENTRANCE = bytes([
    0x83, 0x3E, 0x7D, 0x01, 0x19,          # cmp word [0x17D], 25   ; our screen pending?
    0x74, 0x0A,                            # je continue
    0xA0, 0x00, 0x01,                      # mov al, [0x100]        ; stock test from here
    0x20, 0xC0,                            # and al, al
    0x74, 0x03,                            # je continue
    0xE9, 0x3E, 0xAF,                      # jmp 0x106              ; credits standing: leave the loop
    0xE9, 0x17, 0xAF,                      # continue: jmp 0x00E2   ; screen pending or no credits
])


def _jmp_near(from_offset, to_offset, pad=4):
    """A `jmp near` (3 bytes) plus `pad` bytes of 0x90. `from_offset`/
    `to_offset` are segment E000 offsets; the displacement is relative to
    the end of the jmp itself."""
    disp = (to_offset - (from_offset + 3)) & 0xFFFF
    return bytes([0xE9, disp & 0xFF, disp >> 8]) + bytes([0x90] * pad)


# Table entry 25 of the [0000:017D] sequence dispatcher, at E000:4F7C+2*25.
# Stock holds 0x5022, a duplicate of entry 0 that stock firmware can never
# index; the patch points it at the stub instead.
TABLE_ENTRY_25_ADDR = 0xE4FAE
TABLE_ENTRY_25_ORIGINAL = bytes([0x22, 0x50])
TABLE_ENTRY_25_PATCHED = STUB_ADDR.to_bytes(2, 'little')

# The two game-over tails, both `mov word ds:[0x17D], <index>` followed by
# their own stock `ret` one instruction later (left untouched -- only the
# mov itself is replaced).
GAME_OVER_COMMON_ADDR = 0xE197C
GAME_OVER_COMMON_ORIGINAL = bytes([0x3E, 0xC7, 0x06, 0x7D, 0x01, 0x17, 0x00])
GAME_OVER_COMMON_PATCHED = _jmp_near(GAME_OVER_COMMON_ADDR - ROM_BASE, TRAMPOLINE_COMMON_ADDR)

GAME_OVER_TENTH_ADDR = 0xE1962
GAME_OVER_TENTH_ORIGINAL = bytes([0x3E, 0xC7, 0x06, 0x7D, 0x01, 0x01, 0x00])
GAME_OVER_TENTH_PATCHED = _jmp_near(GAME_OVER_TENTH_ADDR - ROM_BASE, TRAMPOLINE_TENTH_ADDR)

# The attract/credit-wait loop's second credit test (E000:00EC-00F5), which
# stock leaves the loop (`jmp 0x106`) rather than dispatch (`call 0x4F4E` at
# E000:00F6, outside this range and untouched) whenever a credit is
# standing. `jmp near` (3 bytes) + 7 bytes of 0x90 fills the 10-byte site.
GAME_OVER_CREDIT_GATE_ADDR = 0xE00EC
GAME_OVER_CREDIT_GATE_ORIGINAL = bytes([0xA0, 0x00, 0x01, 0x22, 0xC0, 0x74, 0x03, 0xE9, 0x10, 0x00])
GAME_OVER_CREDIT_GATE_PATCHED = _jmp_near(
    GAME_OVER_CREDIT_GATE_ADDR - ROM_BASE, TRAMPOLINE_CREDIT_GATE_ADDR, pad=7)

# The loop's first credit test (E000:00D8-00E1), byte-identical to the one
# above -- and, unlike it, the loop's only entrance from outside. Falls
# through to 0x00E2 (the next stock instruction, left untouched) rather
# than dispatching, exactly as GAME_OVER_CREDIT_GATE does at 0x00EC.
GAME_OVER_CREDIT_GATE_ENTRANCE_ADDR = 0xE00D8
GAME_OVER_CREDIT_GATE_ENTRANCE_ORIGINAL = bytes([0xA0, 0x00, 0x01, 0x22, 0xC0, 0x74, 0x03, 0xE9, 0x24, 0x00])
GAME_OVER_CREDIT_GATE_ENTRANCE_PATCHED = _jmp_near(
    GAME_OVER_CREDIT_GATE_ENTRANCE_ADDR - ROM_BASE, TRAMPOLINE_CREDIT_GATE_ENTRANCE_ADDR, pad=7)

CAVES = (
    (DIGITS_DRAW_ADDR, DIGITS_DRAW, "digits_draw"),
    (SCORE_DIGITS_ADDR, SCORE_DIGITS, "score_digits"),
    (PROMPT_RECORD_ADDR, PROMPT_RECORD, "PRESS START prompt record"),
    (DRAW_SCREEN_ADDR, DRAW_SCREEN, "draw_screen"),
    (ROM_BASE + STUB_ADDR, STUB, "hold stub"),
    (ROM_BASE + TRAMPOLINE_COMMON_ADDR, TRAMPOLINE_COMMON, "common game-over trampoline"),
    (ROM_BASE + TRAMPOLINE_TENTH_ADDR, TRAMPOLINE_TENTH, "tenth-game game-over trampoline"),
    (ROM_BASE + TRAMPOLINE_CREDIT_GATE_ADDR, TRAMPOLINE_CREDIT_GATE, "credit-gate trampoline"),
    (ROM_BASE + TRAMPOLINE_CREDIT_GATE_ENTRANCE_ADDR, TRAMPOLINE_CREDIT_GATE_ENTRANCE,
     "credit-gate entrance trampoline"),
)

HOOKS = (
    (TABLE_ENTRY_25_ADDR, TABLE_ENTRY_25_ORIGINAL, TABLE_ENTRY_25_PATCHED, "sequence table entry 25"),
    (GAME_OVER_COMMON_ADDR, GAME_OVER_COMMON_ORIGINAL, GAME_OVER_COMMON_PATCHED, "common game-over tail"),
    (GAME_OVER_TENTH_ADDR, GAME_OVER_TENTH_ORIGINAL, GAME_OVER_TENTH_PATCHED, "tenth-game game-over tail"),
    (GAME_OVER_CREDIT_GATE_ENTRANCE_ADDR, GAME_OVER_CREDIT_GATE_ENTRANCE_ORIGINAL,
     GAME_OVER_CREDIT_GATE_ENTRANCE_PATCHED, "attract loop credit gate entrance"),
    (GAME_OVER_CREDIT_GATE_ADDR, GAME_OVER_CREDIT_GATE_ORIGINAL, GAME_OVER_CREDIT_GATE_PATCHED,
     "attract loop credit gate"),
)


def physical_to_file(addr):
    return addr - ROM_BASE


def validate_rom(rom_data, any_version=False):
    crc = zlib.crc32(rom_data)
    if crc not in V11_FAMILY_CRC32 and not any_version:
        print(f"  ERROR: CRC32 {crc:08x} is not V1.1's sp03-1_1.rom ({V11_FAMILY_CRC32[0]:08x}),\n"
              f"  nor that image with this patch already applied.\n"
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
