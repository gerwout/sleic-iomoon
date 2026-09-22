#!/usr/bin/env python3
"""
Sleic Bike Race (V4.1) - PRESS START patch
==========================================

Patches the Bike Race V4.1 80188 game ROM (chip 04, `bk04.bin`) so the end of a
game holds the final scores on the panel until START is pressed, instead of
dropping to attract on its own.

Usage:
    python bike_race_press_start_patch.py <bk04.bin> [--output FILE]

**V4.1 only**, by CRC; `--any-version` overrides. Independent of
`bike_race_free_play_patch.py` - different hooks, different caves - so the two
can be applied to the same image in either order.

What takes the scores down
--------------------------
Two different things, depending on how many players were in the game, which is
why the patch carries two hooks into one shared hold.

* **`F000:10F2`** is one of a family of ~50 near-identical **screen loaders**
  (`LES SI,[CS:<ptr>]` / `MOV DI,0` / `CALL F000:031B`, then a block of display
  variables and `[0010:100E] = 0FFh`). This one loads the screen at `2000:AFEA`,
  and in a one-, two- or three-player game it is the next screen after the
  finished game's scores. It runs exactly twice per game, one frame apart, at
  the very end.
* **`E8C5D`** is the first of the two panel blanks that precede `E8C67`'s
  `CALL FAR F000:2331`, the loader for the **"Partida"** overlay at `5000:7AC8`.
  (`F000:008A` clears `[0010:07C8]`; `F000:005D` clears `[0010:01C8]` and sets
  `[0010:05C8]`'s mask to 0xFF.) In a **four-player** game that block runs
  *before* `F000:10F2` does, so a hold placed only on the loader gets "Partida"
  on the panel and the scores are already gone.

  It has to be this call site and not `F000:005D` itself. The blank is shared by
  every screen change, including the Puntos GRAND PRIX and Puntos CAMPEONATO
  bonus screens that run between game over and the final scores, and a hold on
  the routine freezes one of those instead. `F000:2331` has four call sites
  (`E6366`, `E6A4C`, `E8C67`, `ED9B0`); recording its return address shows
  `E8C67` is the only one reached with `[0072]` still non-zero -- it is the
  four-player path -- while one-, two- and three-player games reach `E6A4C`
  later, in attract, with the player count already cleared.

Both hooks call the same cave. It holds on whichever fires first, so the panel
keeps whatever was last composed on it - the finished game's scores.

The guards
----------
Bike Race's game state lives in segment `0116`: `[0099]` is the state byte
(4 = a game is running) and `[0072]` the player count.

* `[0099] == 4` - a clear or a screen change during play, e.g. a mode change or a
  replay award. No hold. Bike Race's PREMIOS/PARTIDA award is a replay at a score
  threshold granted **during** play (`E7292`: `INC ES:[0070]` then the credit
  write), not a digit match at game over, so it lands squarely in this case.
* `[0072] == 0` - no game ran, so this is attract, a power-on or a menu teardown.
  No hold, and the cave **arms** itself here (see below). Without this the hook
  fires on the way into attract at power-on, the first START press is swallowed,
  and no game can be started at all.

`0010:1030`, the once-per-game latch
------------------------------------
Both hooks fire at the end of a four-player game, and without a latch the machine
would ask for START twice. The cave sets `0010:1030` to `0A5h` when it holds and
clears it on any pass with `[0072] == 0`, so a game gets exactly one hold and
attract re-arms it.

`0010:1030` is free: the display page's variable block is `[0010:100E]`-`[1026]`,
its save area (written by `F000:2CA3`, read back by `F000:2CB6`) is
`[0010:1035]`-`[104B]` and `[104C]` is that save's flag, leaving `[1029]`-`[1034]`
between them. Measured in emulation over a full session - power-on, attract, a
four-player game and back to attract - the firmware reads and writes `[1027]` and
`[1028]` once each and **never touches `[1029]`-`[1034]` at all**. Nothing
initialises the latch either, so the cave is written to tolerate any power-on
value: attract runs `F000:005D` constantly with `[0072] == 0`, which clears it
long before a game can be started.

The prompt
----------
The cave draws **"PRESS START"** over the held screen with the machine's own text
routine `F000:0682`, whose third argument is a byte offset into the display
buffer at a 16-byte row stride, so `0140h` is row 20, column 0. The finished-game
score lines sit on rows 1-7 (players 1 and 2) and 10-16 (players 3 and 4), so the
prompt never covers a score. The ROM's own prompt reads "PULSE START", so the
patch carries its own string record at `F928:0000`.

Because the 80188 is stopped, nothing rebuilds the panel afterwards, and the
prompt composites onto the finished game's screen rather than replacing it.

`F000:0682` clobbers SI, DI, BX, CX and DX, which `F000:005D` preserves, so the
cave brackets the hold with `PUSHA`/`POPA` (the 80188 has both).

Releasing it
------------
`E50E:43BA` pops one code off the inbound switch FIFO at `[0010:001A]` and returns
1 only on `CMP AX, 36h`, Bike Race's operator START event. Every other code is
drained and ignored, so **only START releases the hold** - measured, with twelve
playfield keys and a coin leaving it frozen.

Popping the code is not enough on its own. The FIFO -- `0010:00EA`-`[01B2]`, filled
by the NMI at `E0272` -- holds more than one `36h` whenever more than one reaches it
before the hold pops: a press during the end-of-game bonus screens queues one before
the hold is even entered, and the Z80's cabinet scan has no time-based debounce, so
it re-arms the instant the contact reads open (`bkio07:3033`) and reports a bouncing
button twice. `43BA` takes exactly one code per call, so the rest survive the hold
and attract's START handler acts on the next one, starting a game where attract
should have run.

The firmware's own answer is `E9C7:2F47`. Called with a code on the stack, it walks
the FIFO from the read pointer to its terminating zero and overwrites every
occurrence of that code with the harmless `64h`. Fourteen sites use it, the START
handler at `EC2FA` and the FABRICA prompt at `E9486` among them, always as
`PUSH 36h / CALL FAR E9C7:2F47 / POP CX` immediately after acting on the press.

A single scrub covers only what is already queued, and a bouncing contact reports
again milliseconds later, so the hold first lets the press settle and then scrubs.
`[0010:000B]` is the free-running digit the timer-0 ISR steps at `E0413` -- 0 to 9
on every second tick, so one step per 20.2 ms at timer 0's 99.18 Hz, and the same
digit the MATCH draws on. The hold waits for sixteen steps of it, about 320 ms, and
scrubs `36h` once at the end. Nothing drains the FIFO while the hold owns the main
loop, so every code the press produced is still there to be scrubbed, whether it
arrived before the pop or after it; the ISR that steps the digit runs throughout.
One press therefore releases the hold and leaves nothing for attract to start a
game with, and a deliberate second press lands well outside the window.

Verified
--------
Measured on `bikerc3f` with the "Balls" setting at 3, each run from an identical
warm store, driving a full game with `-key_script` and dumping every DMD frame:

| | patched | unpatched |
|---|---|---|
| one, two and three players | **holds the scores** until a press | clears at once |
| **four players** | **holds the scores** until a press | held "Partida", scores gone |
| panel during the hold | **1 distinct frame -- frozen** | animating (attract) |
| releasing it | **one** START press, at every player count | - |
| the same press reported twice, 166 ms apart | releases into attract | started a new game |
| three games back to back | three holds, each with its own score | - |
| replay awards granted mid-game | no spurious hold; still holds at game over | - |
| a won MATCH | credit banked (NVRAM `0083` 1 -> 2); hold still frozen | - |
| a START press | releases it; attract resumes | - |
| a deliberate press after that | starts the next game | - |

The double-report row is `keyscripts/bikerace-pressstart-double.keys`: two closures
ten frames apart at the prompt, standing in for one bouncing contact. The hold comes
away 20 frames (333 ms) later than an unsettled one, which is the sixteen `[000B]`
steps, and the panel then runs the attract cycle for the remaining 3,500 frames.

Free play is unaffected with both patches applied, and power-on is not blocked.

The match is a genuine end-of-game award here, unlike Io Moon's, and it is reached
by chance: `E8888` takes each player's last score digit (`IDIV 10` into
`[0121:0011..0014]`) and compares it at `E8955` with the random digit at
`[0010:000B]`, awarding through `E50E:3A71` on a hit. To test it deterministically,
turn `E8959`'s `JE` (`74 03`) into a `JMP` (`EB 03`) in a throwaway image -- forcing
the digits equal from the driver cannot win the race, because the whole routine
runs inside one frame.

> Testing note: the "Balls" setting defaults to 0, and with it at 0 no game can
> start at all, so a run that forgets it shows two identical attract screens and
> looks like the patch does nothing. The store also needs its FABRICA prompt
> already cleared, or the first START press is consumed by that.

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
# The images this accepts: stock V4.1, and it with the free-play patch applied.
V41_FAMILY_CRC32 = (
    0x33fd212e,   # bk04.bin, stock V4.1
    0x42748f1d,   # + free play
    0x07aff87d,   # + press start
    0x7626564e,   # + both
)

HOOK_LOADER = 0xF10F2   # F000:10F2, the screen loader that follows a 1-3 player game
HOOK_CLEAR  = 0xE8C5D   # E8C5D, the panel blank that precedes the "Partida" overlay
CAVE_LOADER = 0xF9240   # F924:0000, clear of the free-play cave at F9200
CAVE_CLEAR  = 0xF9260   # F926:0000
STRING      = 0xF9280   # F928:0000, our own "PRESS START" record
HOLD        = 0xF92E0   # F92E:0000, the shared hold

LATCH = 0x1030          # [0010:1030], the once-per-game latch

ORIGINAL_LOADER = bytes([0xFA, 0x1E, 0xB8, 0x10, 0x00])   # CLI / PUSH DS / MOV AX,0010
PATCHED_LOADER  = bytes([0xEA, 0x00, 0x00, 0x24, 0xF9])   # JMP FAR F924:0000
ORIGINAL_CLEAR  = bytes([0x9A, 0x8A, 0x00, 0x00, 0xF0])   # CALL FAR F000:008A
PATCHED_CLEAR   = bytes([0xEA, 0x00, 0x00, 0x26, 0xF9])   # JMP FAR F926:0000

# The machine's own glyph encoding: 0x0A = space, 0x0B.. = A..Z with N-tilde after N.
# A string record is [length][glyphs].  The ROM's own prompt reads "PULSE START"; this
# is our own record so the panel can say "PRESS START" instead.
STRING_DATA = bytes([0x0B,                                      # 11 characters
                     0x1B, 0x1D, 0x0F, 0x1E, 0x1E,              # P R E S S
                     0x0A,                                      # space
                     0x1E, 0x1F, 0x0B, 0x1D, 0x1F])             # S T A R T

# Each hook's cave: call the shared hold, run the bytes the far jump displaced, rejoin.
CAVE_LOADER_DATA = bytes([
    0x9A, 0x00, 0x00, 0x2E, 0xF9,        # CALL FAR F92E:0000  ; the hold
    0xFA, 0x1E, 0xB8, 0x10, 0x00,        # the displaced prologue
    0xEA, 0xF7, 0x10, 0x00, 0xF0,        # JMP FAR F000:10F7
])
CAVE_CLEAR_DATA = bytes([
    0x9A, 0x00, 0x00, 0x2E, 0xF9,        # CALL FAR F92E:0000  ; the hold
    0x9A, 0x8A, 0x00, 0x00, 0xF0,        # the displaced CALL FAR F000:008A
    0xEA, 0x82, 0x3B, 0x0E, 0xE5,        # JMP FAR E50E:3B82   ; rejoin at E8C62
])

# The shared hold.  PUSHA/POPA because F000:0682 clobbers registers that both
# hooked routines preserve.
HOLD_DATA = bytes([
    0x60,                                # PUSHA
    0x06, 0x1E,                          # PUSH ES / PUSH DS
    0xB8, 0x16, 0x01, 0x8E, 0xC0,        # MOV  AX,0116h / MOV ES,AX
    0xB8, 0x10, 0x00, 0x8E, 0xD8,        # MOV  AX,0010h / MOV DS,AX
    0x26, 0x80, 0x3E, 0x99, 0x00, 0x04,  # CMP  ES:[0099], 4    ; a game is running
    0x74, 0x4F,                          # JE   out
    0x26, 0x80, 0x3E, 0x72, 0x00, 0x00,  # CMP  ES:[0072], 0    ; the player count
    0x75, 0x07,                          # JNE  ended           ; a game just ended
    0xC6, 0x06, 0x30, 0x10, 0x00,        # MOV  byte [1030h], 0 ; attract -> re-arm
    0xEB, 0x40,                          # JMP  out
    0x80, 0x3E, 0x30, 0x10, 0xA5,        # ended: CMP byte [1030h], 0A5h
    0x74, 0x39,                          # JE   out             ; already held this game
    0xC6, 0x06, 0x30, 0x10, 0xA5,        # MOV  byte [1030h], 0A5h
    0x68, 0x28, 0xF9,                    # PUSH 0F928h          ] our "PRESS START"
    0x68, 0x00, 0x00,                    # PUSH 00000h          ] segment:offset
    0x68, 0x40, 0x01,                    # PUSH 00140h          ; row 20, column 0
    0x6A, 0x01,                          # PUSH 1               ; font type
    0x9A, 0x82, 0x06, 0x00, 0xF0,        # CALL FAR F000:0682   ; draw it OVER the scores
    0x83, 0xC4, 0x08,                    # ADD  SP, 8
    0x9A, 0xBA, 0x43, 0x0E, 0xE5,        # wait: CALL FAR E50E:43BA  ; poll for START
    0x0A, 0xC0,                          # OR   AL, AL
    0x74, 0xF7,                          # JE   wait
    0xB1, 0x10,                          # MOV  CL, 16          ; let the press settle
    0x8A, 0x2E, 0x0B, 0x00,              # tick: MOV CH, [000Bh]
    0x3A, 0x2E, 0x0B, 0x00,              # spin: CMP CH, [000Bh]
    0x74, 0xFA,                          # JE   spin            ; wait for the tick
    0xFE, 0xC9,                          # DEC  CL
    0x75, 0xF2,                          # JNE  tick
    0x6A, 0x36,                          # PUSH 36h             ] then scrub every
    0x9A, 0x47, 0x2F, 0xC7, 0xE9,        # CALL FAR E9C7:2F47   ] queued START code
    0x58,                                # POP  AX              ; CX holds the counter
    0x1F, 0x07, 0x61,                    # out: POP DS / POP ES / POPA
    0xCB,                                # RETF
])

CAVES = ((CAVE_LOADER, CAVE_LOADER_DATA, "loader cave"),
         (CAVE_CLEAR,  CAVE_CLEAR_DATA,  "panel-clear cave"),
         (STRING,      STRING_DATA,      "\"PRESS START\" string"),
         (HOLD,        HOLD_DATA,        "shared hold"))
HOOKS = ((HOOK_LOADER, ORIGINAL_LOADER, PATCHED_LOADER, "screen-loader hook"),
         (HOOK_CLEAR,  ORIGINAL_CLEAR,  PATCHED_CLEAR,  "panel-clear hook"))


# =============================================================================
# Patching logic
# =============================================================================

def physical_to_file(addr):
    return addr - ROM_BASE


def validate_rom(rom_data, any_version=False):
    crc = zlib.crc32(rom_data)
    if crc not in V41_FAMILY_CRC32 and not any_version:
        print(f"  ERROR: CRC32 {crc:08x} is not V4.1's bk04.bin ({V41_FAMILY_CRC32[0]:08x}),\n"
              f"  nor that image with the free-play patch applied.\n"
              f"  This patch is verified on V4.1 only -- pass --any-version to force it.",
              file=sys.stderr)
        return False
    if len(rom_data) != ROM_SIZE:
        print(f"ERROR: Expected {ROM_SIZE // 1024}KB (bk04.bin), "
              f"got {len(rom_data)} bytes.", file=sys.stderr)
        return False

    for base, blob, what in CAVES:
        off = physical_to_file(base)
        space = rom_data[off:off + len(blob)]
        if space != blob and not all(b == 0x00 for b in space):
            print(f"  ERROR: {what} at 0x{base:05X}: space not empty (not all 0x00).",
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
        description='Sleic Bike Race (V4.1) - PRESS START patch',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  %(prog)s bk04.bin -o bk04p.bin

Stacking with free play (either order works):
  python bike_race_free_play_patch.py bk04.bin -o tmp.bin
  %(prog)s tmp.bin -o bk04fp.bin
        """,
    )
    parser.add_argument('rom_file', help="V4.1 game ROM, chip 04 (bk04.bin)")
    parser.add_argument('--output', '-o', default=None,
                        help='Output filename (default: <name>_pressstart.<ext>)')
    parser.add_argument('--any-version', action='store_true',
                        help='Accept a chip 04 that is not V4.1 (untested)')
    args = parser.parse_args()

    input_path = Path(args.rom_file)
    if not input_path.is_file():
        print(f"ERROR: File not found: {input_path}", file=sys.stderr)
        sys.exit(1)

    output_path = (Path(args.output) if args.output else
                   input_path.with_name(f"{input_path.stem}_pressstart{input_path.suffix}"))

    print("Sleic Bike Race (V4.1) - PRESS START patch")
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
