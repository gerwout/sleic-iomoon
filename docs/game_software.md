# Game Software Architecture

[← Back to main README](../README.md)

## Boot Sequence

After power-on reset, the 80188 begins execution at `0xFFFF0` (the standard x86 reset vector):

```
CPU Reset
    │
    ▼
0xFFFF0: JMP FAR FFF0:0000
    │
    ▼
0xFFF00: MOV DX, FFA0h          ; UMCS register (upper-memory chip-select)
         MOV AX, C03Ch           ; Open ROM window 0xC0000-0xFFFFF
         OUT DX, AX
         JMP FAR D000:0000       ; Jump to main initialization
    │
    ▼
0xD0000: CLI                     ; Disable interrupts
         MOV AX, 4152h           ; Set up stack segment
         MOV SS, AX
         MOV SP, 0205h           ; Stack pointer
         MOV AX, 4000h           ; Data segment = 80188-private work RAM (seg 4000h)
         MOV DS, AX
         MOV ES, AX
         │
         ├── Program the peripheral control block from the 30-entry
         │   table in ROM at CS:0041 (chip selects, timer 0, the
         │   interrupt controller, both parked DMA channels) — F1
         ├── CALL sub_D00B9      ; PCS0/PCS4/PCS6 idle levels, queue pointers
         ├── CALL sub_D011C      ; clear the DMD buffers
         ├── CALL sub_D00FA      ; the single PCS4 bit-3 pulse (F13)
         ├── CALL sub_F0000      ; extended initialisation
         └── CALL sub_D0B2B      ; additional setup
         │
         STI                     ; Enable interrupts
         JMP D2F2:0002           ; Enter main game loop
```

---

## Main Game Loop

The main loop at `0xD2F22` runs continuously and handles all game logic:

```
0xD2F22: Main loop head
    │
    ├── Read the country/language byte from NVRAM 0x1BF into [4000:1001]
    ├── Call sub_D5133          ; state setup
    ├── Call sub_DD3FB          ; select the English or Spanish record table
    │
    ▼
    ┌──────────────────────────────────────────┐
    │  Boot handshake (loc_D2F59)              │
    │  Spins on sub_D5D1B until the Z80's      │
    │  0x47 "alive" byte arrives over J1       │
    └──────────────────────────────────────────┘
    │
    ├── Call sub_D5A45          ; process pending input
    ├── Call sub_D622C          ; NVRAM signature check / factory defaults
    │
    ▼
    ┌──────────────────────────────────────────┐
    │  State Machine (loc_D3002)               │
    │  Switch on ES:[014F]:                    │
    │    1 → sub_D303C  (attract)              │
    │    2 → sub_D307F  (credits present)      │
    │    4 → sub_D3145  (ball in play)         │
    └──────────────────────────────────────────┘
```

Nothing past `D2F59` runs until the Z80 sends `0x47`, and the machine also runs a
direct-input self-check there: it pushes Z80 command `0xC0`, waits for the reply
`0x7A` ("all direct inputs clear"), and on any other answer goes straight to the
fault display and the service menu.

---

## State Machine

The game state is stored at `413C:014F`. The main loop dispatches to different handlers based on this value:

| Value | Handler | Description |
|-------|---------|-------------|
| `1` | `sub_D303C` | Attract — no credits |
| `2` | `sub_D307F` | Credits present, waiting for START |
| `3` | — | Game started (`sub_D8154` writes this at `D815F`) |
| `4` | `sub_D3145` | Ball in play, through end-of-ball and the match sequence |

State transitions:

- **1 → 2**: a coin is priced into a credit
- **2 → 3**: START is pressed; `sub_D8066` decrements the credit triple and, on
  the first player, calls `sub_D8154`, which bumps the games-played audit and
  starts the in-game song
- **3 → 4**: the ball is served
- **4 → 1**: the last ball is home and the match animation completes

---

## Configuration System

The IO Moon supports operator-configurable settings stored in EEPROM. The configuration system has three key functions:

The non-volatile store is a window at **segment `5040`** (flat `0x50400`+),
gated by the complementary PCS0 bits 3 and 4; every access is bracketed by
`pcs0_window_open` `D057E` / `pcs0_window_close` `D059F` and goes through one of
four accessors (finding F10):

| Function | Address | Description |
|----------|---------|-------------|
| `nvstore_read_byte_far` | `0xD04BF` | 8-bit read |
| `nvstore_write_byte_far` | `0xD04A9` | 8-bit write |
| `nvstore_read_dword_far` | `0xD0492` | 32-bit read |
| `nvstore_write_dword_far` | `0xD046D` | 32-bit write |
| `nvstore_write_triple_83` / `_84` | `0xD04D2` / `0xD04F3` | write the triplicated credit bytes |
| `nvstore_check_triple_83` / `_84` | `0xD0514` / `0xD0549` | majority-compare them; zero all three on mismatch |
| `sub_D05C0` | `0xD05C0` | signature check against the copyright block at `CS:07A9` |
| `sub_D622C` | `0xD622C` | write the factory defaults when the signature fails |

Stored data includes the pricing table (`0x1C4`–`0x1CF`), the country byte
(`0x1BF`), balls per game (`0x3C`), the tilt-warning count (`0x42`), the
short-ball replay threshold (dword `0x43`), the credit balance (triplicated at
`0x83`/`0x116`/`0x20C` with the sub-credit remainder at `0x84`/`0x117`/`0x20D`),
five 17-byte high-score records from `0x85`, and the audit dwords from `0x118`.
The highest offset the firmware touches is `0x31D`.

The **display language** is a single binary byte: `[4000:1001] == 5` renders Spanish,
any other value renders English. It is read from NVRAM `5040:01BF` at `D2F2E → D2F3B`,
but that is not where it originates: boot_init re-derives the country from the SW40 DIP
on every boot (`sub_D5A8B` → Z80 command `0xF9` → `D5CA3`-`D5CC2`, dispatch table at
`D5D01`) and at `D664D` **overwrites** NVRAM `0x1BF` and `[4000:1001]` when the DIP
disagrees. The country DIP therefore drives the language. See
[`iomoon_language_and_service_menu.md`](iomoon_language_and_service_menu.md).

---

## The outbound command queue

The 80188 stages **Z80 command bytes** — indices into the Z80's 256-entry table
at `$2000` — in a circular byte queue in its own work RAM:

- **Read pointer (consumer)**: `4000:114C`
- **Write pointer (producer)**: `4000:114E`
- **Queue body**: from `4000:1158`

`qout_push` at `0xD0138` is the producer, with **172 call sites** and 54 distinct
constant immediates; `qout_service_pcs1` at `0xD01E5` is the consumer, called
from the INT0 ISR, and hands one byte at a time to PCS1 `0xA0080`. The payload is
lamp, driver, mode and test-mode commands — not sound and not display data
(finding F12). See [`inter_cpu_communication.md`](inter_cpu_communication.md).

### Key display functions

| Address | Function |
|---------|----------|
| `0xF08A5` | Composite: `(background AND mask) OR sprite`, both planes |
| `0xF08EB` | Blit the composite planes into the display buffer at `7000:0000` |
| `0xF0348` | `anim_stream_open` — read a graphics page header and start a stream |
| `0xF00A0` | Select the graphics page (PCS0 bits 0–2) |
| `0xF0701` | Render a text string on the DMD (font type, position, string pointer) |
| `0xD00B9` | Boot: peripheral idle levels and queue pointers |
| `0xD00FA` | Boot: the single PCS4 bit-3 pulse |

---

## Test Menu

The service menu is opened by the TEST button, switch code **`0x3F`**, dispatched
from the switch-code shadow at `D7AD5` into the menu root `sub_DD253`. It is a
tree of 38 forty-six-byte records reached through the far pointer `[4137:004B]`;
the cursor is `[4137:0013]` and the record being displayed is `[413C:015A]`.
Navigation is TEST (`0x3F`) to exit, START (`0x40`) to go back, and the two
flipper codes `0x41` / `0x42` to scroll and select. The full record tree, the
per-record dispatch and the language selection are in
[`iomoon_language_and_service_menu.md`](iomoon_language_and_service_menu.md).

Entering the menu queues Z80 command `0xF7` (test mode on) and leaving it queues
`0xF8`, which **reboots the I/O Z80** by design.

The top of the tree:

```
- ADJUSTMENT / AJUSTE -
├── SOUND/VIDEO       → VOLUME (plays song 1 on entry), CUSTOM MESSAGE
├── GAME              → the game adjustments
└── TECHNICAL
    ├── BOARD TEST    (solenoid, lamp and switch tests)
    ├── CREDITS       (the live pricing table)
    └── TILTS
```

### Factory Reset

The "BORRADO DE TODO" function erases all statistics, high scores, advertising settings, and restores factory defaults including volume reset to 6 steps.

---

## Game State Variables

Key game state variables in segment `413C`:

| Offset | Function |
|--------|----------|
| `00D4` | Credit balance — a **cache** of the NVRAM pair `0x83 + 0x84` |
| `00D5` | Coin-pulse accumulator, folded in from `[4000:1144]` by `sub_D800A` |
| `00D6` | `last_switch_code` — the byte `sub_D7453` popped from the inbound FIFO |
| `00D7` | Players in the current game |
| `00A9`–`00B0` | The live pricing table, loaded from NVRAM `0x1C4`–`0x1CF` at boot |
| `00EB` | Ball-over flag, set by `sub_D92C0` |
| `00F8` / `00F9` | Ball counts in device 2 and the trough |
| `00FF` | Ball number in play |
| `014F` | Game mode (1 attract, 2 credits present, 3 game started, 4 ball in play) |
| `015A` | The menu record currently displayed |

Segment `413C` is the most heavily referenced data area in the code — it holds
the primary game state. Configuration derived at boot lives one segment lower, in
`4130` (country number at `0020`, balls per game at `003D`, the extra-ball
threshold at `0039`/`003B`), and the menu cursor in `4137`.

---

## Patching Considerations

For ROM modifications, the most useful hook points are:

| Address | Context | Notes |
|---------|---------|-------|
| `0xD303C` | Attract mode handler | Entry point for attract mode behavior |
| `0xD307F` | Active game handler | Main game processing |
| `0xD3145` | Special/match handler | Post-game match sequence |
| `0xD2F22` | Main loop entry | Top of the main game loop |
| `0xD5122` | Post-match, pre-animation | Scores still visible on DMD (used by PRESS START patch) |
| `0xD5076` | SPECIAL path | Match animation trigger point |

Unused ROM space for code caves exists at:

- `0xC0000`–`0xCFFFF`: a large block of `0xFF` bytes at the bottom of the UMCS
  window (ROM1 file `0x40000`–`0x4FFFF`), mapped and executable but unused
- `0xF5000`–`0xF9000`: Smaller `0xFF` regions in the F000 code segment
