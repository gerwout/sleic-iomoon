# Game Software Architecture

[← Back to main README](../README.md)

## Boot Sequence

After power-on reset, the 80188 begins execution at `0xFFFF0` (the standard x86 reset vector):

```
CPU Reset
    │
    ▼
0xFFFF0: JMP FAR FFFF:0000
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
         ├── Configure I/O ports from table at DS:0041
         ├── CALL sub_D00B9      ; Initialize DMD controller
         ├── CALL sub_D011C      ; Initialize buffers
         ├── CALL sub_D00FA      ; Reset display
         ├── CALL sub_F0000      ; Extended initialization
         └── CALL sub_D0B2B      ; Additional setup
         │
         STI                     ; Enable interrupts
         JMP D2F2:0002           ; Enter main game loop
```

---

## Main Game Loop

The main loop at `0xD2F22` runs continuously and handles all game logic:

```
0xD2F22: Main Game Loop
    │
    ├── Call display update routines
    ├── Call sub_D5133          ; Game state update
    ├── Call sub_DD3FB          ; Additional processing
    │
    ▼
    ┌──────────────────────────────────────────┐
    │  Wait Loop (loc_D2F59)                   │
    │  Polls sub_D5D1B until non-zero return   │
    └──────────────────────────────────────────┘
    │
    ├── Call sub_D5A45          ; Process switch input
    ├── Call sub_D622C          ; Game logic
    │
    ▼
    ┌──────────────────────────────────────────┐
    │  State Machine (loc_D3002)               │
    │  Switch on ES:[014F]:                    │
    │    1 → sub_D303C  (Attract mode)         │
    │    2 → sub_D307F  (Game active)          │
    │    4 → sub_D3145  (Special/match)        │
    │    else → sub_D622C (default handler)    │
    └──────────────────────────────────────────┘
```

---

## State Machine

The game state is stored at `413C:014F`. The main loop dispatches to different handlers based on this value:

| State | Value | Handler | Description |
|-------|-------|---------|-------------|
| Attract | `01` | `sub_D303C` | Demo mode, waiting for coin/start |
| Active | `02` | `sub_D307F` | Game in progress |
| Special | `04` | `sub_D3145` | Match/lottery sequence after game end |

State transitions:

- **Attract → Active**: Player inserts coin and presses START
- **Active → Special**: Game ends, enter match sequence
- **Special → Attract**: Match animation completes, return to demo mode

---

## Configuration System

The IO Moon supports operator-configurable settings stored in EEPROM. The configuration system has three key functions:

| Function | Address | Description |
|----------|---------|-------------|
| `config_load_defaults` | `0xD0C57` | Load factory default settings |
| `config_load_eeprom` | `0xD0C84` | Load settings from EEPROM |
| `config_save_eeprom` | `0xD0CB8` | Save current settings to EEPROM |
| `config_validate` | `0xD0CE0` | Validate loaded configuration |

Configuration data includes pricing, game settings (balls per game, tilt sensitivity), language selection, and high score thresholds.

The **display language** is a single binary byte: `[4000:1001] == 5` renders Spanish,
any other value (firmware default `0x04`) renders English. It is seeded once per
main-loop cycle from NVRAM `5040:01BF` at `D2F2E → D2F3B`, **not** from the country
DIP (that path is dead code in V1.3). See
[`iomoon_language_and_service_menu.md`](iomoon_language_and_service_menu.md).

---

## Display Command Queue

The 80188 uses a command queue system for DMD updates:

- **Write pointer**: `4000:114C`
- **Read pointer**: `4000:114E`
- **Queue buffer**: Starts at `4000:1158`

The `display_cmd_queue` function at `0xD0138` is referenced 80 times throughout the code, making it one of the most-called functions. Commands include frame loading, text display, animation triggers, and screen clearing.

### Key Display Functions

| Address | Function | Description |
|---------|----------|-------------|
| `0xD0138` | `display_cmd_queue` | Queue a display command (80 references) |
| `0xF0701` | Text display | Render text string on DMD (font type, position, string pointer) |
| `0xF0907` | `dmd_frame_load` | Load a DMD frame from ROM data |
| `0xD00B9` | DMD init | Initialize DMD controller hardware |
| `0xD00FA` | DMD reset | Clear display buffers |

---

## Test Menu

The test menu is accessed by pressing the TEST button (switch code `0x33`) during
attract mode. Menu state is `game_state_var [413C:014F] == 3`. The live navigator
acts on the **RIGHT-flipper code `0x3F`** (advance/select) and `0x40` (upper flipper,
alt-advance); it ignores the left-flipper code `0x3E`. The switch-event → menu path,
the per-page draw functions, and the switch codes are documented in
[`iomoon_language_and_service_menu.md`](iomoon_language_and_service_menu.md).

The menu structure:

```
- TECNICO -
├── TEST TABLERO
│   ├── BOBINAS       (Solenoid test - cycles through all solenoids)
│   ├── LUCES         (Lamp test - 3 modes: sequential, all-on, chase)
│   └── CONTACTOS     (Switch test - displays switch code on activation)
├── CREDITOS          (Credit/pricing configuration)
└── FALTA             (Tilt configuration)
```

### Factory Reset

The "BORRADO DE TODO" function erases all statistics, high scores, advertising settings, and restores factory defaults including volume reset to 6 steps.

---

## Game State Variables

Key game state variables in segment `413C`:

| Offset | Function | References |
|--------|----------|------------|
| `00D7` | Game flag 1 | Multiple |
| `00D9` | Game flag 2 | Multiple |
| `014F` | State machine variable (1, 2, or 4) | Core dispatch |
| `10E6` | Timer counter | Timer-based events |
| `10F0` | Timer enable flag | Timer control |

The segment `413C` is the most heavily referenced data area in the code, with **920 cross-references** — it contains the primary shared game state.

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

- `0xC0000`–`0xCFFFF`: Large block of `0xFF` bytes (ROM1 graphics area, much of it unused)
- `0xF5000`–`0xF9000`: Smaller `0xFF` regions in the F000 code segment
