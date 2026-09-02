# IO Moon — Language Model & Service-Menu Navigation

[← Back to main README](../README.md)

This document covers two closely related IO Moon (SLEIC2) subsystems that were
reverse-engineered and **verified during PinMAME driver work**:

1. how the firmware selects its on-screen **language** (Spanish vs. English), and
2. how switch presses drive the **service / test menu**.

Several earlier notes (in the annotated disassembly, in `game_software.md`, and in
older progress notes) got the polarity of the language test backwards and the
menu-navigation flipper wrong. The conclusions below were confirmed two ways:

- **DMD output verification** — forcing the language byte to a known value in a live
  PinMAME run and reading the rendered attract DMD ("BALL MISSING" in English vs. its
  Spanish equivalent).
- **ROM dump-diff** — comparing the *1.3 IPDB latest* and *1.3 Early version* dumps
  byte-for-byte at the relevant code.

All file offsets below are into ROM1 `roms/1.3 IPDB latest/V1 3_01.bin`. The 80188
runs this ROM in segment `D000` upward, so **linear `0xDxxxx` = file `0xDxxxx − 0x80000`**
(e.g. linear `D5CAC` = file `0x55CAC`); segment `D000` = file `0x50000`. The Z80 ROM
is `V1 3_05.bin` (flat). Addresses were spot-checked with `ndisasm`; where an earlier
label was off it is called out explicitly.

---

## A. Language model and polarity

### The language byte: `[4000:1001]`

The active display language is a single byte of 80188 work RAM at **`4000:1001`**
(physical `0x41001`). Every language-dependent renderer makes the **same** test:

```asm
cmp byte [es:1001h], 5      ; bytes 26 80 3E 01 10 05
```

There are ~51 such sites in ROM1 (41 of the exact 6-byte form above plus a handful
of equivalent variants), and **none of them compares `[1001]` against any value other
than `5`**. The language is therefore **binary** — there is no third value in play.

### Polarity (DMD-verified — do not invert)

> **`[1001] == 5` renders SPANISH. Any other value renders ENGLISH.**

The firmware default is **`0x04`** (English). This was proven on live DMD output:
forcing `[1001] = 0x04` makes the attract DMD render **"BALL MISSING" in English**;
forcing `[1001] = 0x05` renders the Spanish text. An earlier disassembly trace
labelled the `== 5` branch (and the "seg-3000" pre-rendered text set) as *English* —
**that label was swapped.** The corrected mapping:

| `[1001]` value | Language | Pre-rendered text set |
|----------------|----------|------------------------|
| `0x05`         | Spanish  | second bitmap of each pair (~seg `1000` set) |
| anything else (default `0x04`) | English | first bitmap of each pair (~seg `3000` set) |

The two text sets are **pre-rendered DMD bitmaps in ROM2**, stored as parallel/paired
entries (≈41 pointer pairs) and selected by the `[1001] == 5` test. A representative
selector site is **`DA9A9`** (file `0x5A9A9`):

```asm
DA9A9  cmp byte [es:1001h], 5     ; 26 80 3E 01 10 05
DA9AF  jnz  DA9B8
DA9B1  call F000:2FFD             ; Spanish text variant
DA9B6  jmp  DA9BD
DA9B8  call F000:3007             ; English text variant
```

> **Correction:** `DA9A9` was previously described as the test that "enters the
> service menu." It is not — it is one of the ~51 language tests (it branches between
> two pre-rendered text variants). Menu state lives in `[413C:014F]`, **not** in
> `[1001]` (see §C).

### Where `[1001]` is seeded — once, from NVRAM, at the top of the main loop

`[1001]` is **written in exactly one place** in the entire 80188 program — file
`0x52F3B`, at the head of the main game loop (`D2F22`):

```asm
D2F22  push ds
D2F23  mov  ax, 4130h
D2F26  mov  ds, ax
D2F28  push 5040h                 ; NVRAM segment
D2F2B  push 01BFh                 ; NVRAM offset = language byte
D2F2E  call D000:04BF             ; NVRAM byte-read accessor (returns AL)
D2F33  add  sp, 4
D2F36  mov  dx, 4000h
D2F39  mov  es, dx
D2F3B  mov  [es:1001h], al        ; <-- the ONLY write to [1001]
```

So the live language is sourced from **NVRAM `5040:01BF`** (the 28C64A) and read
**once per pass through the main-loop head** (`D2F22`), i.e. once per game cycle —
**not every frame.** The inner per-frame loop is `loc_D2F59` (it polls `D2F2:2DFB`
and loops back to `D2F59`); it never re-reads `01BF`. A previously-assumed
"per-frame `D2F28` reload" is therefore wrong in spirit (`D2F28` *is* the read site,
but it is on the once-per-game-cycle path, not the per-frame path).

> **Address note:** earlier notes located the language NVRAM read "at config-load,
> PC ~`D04CC`." `D04CC` is actually the tail (the `call 0x59f` epilogue) of the
> generic NVRAM byte-**read** accessor whose entry is **`D000:04BF`**. The *caller*
> that reads `01BF` and stores it into `[1001]` is `D2F2E → D2F3B`. The functional
> conclusion ("read once, into `[1001]`") is unchanged; the address is corrected to
> `D2F2E`/`D2F3B`.

`5040:01BF` itself is written (from `[4000:0020]`) by the country-init block in §B
via the NVRAM byte-**write** accessor `D000:04A9` (e.g. callers at `D6619`/`D6669`).

---

## B. The country DIP → language path is LIVE (corrected 2026-09-03)

> **This section previously concluded the country→language path was dead code. That was
> wrong, and the error was a segment resolution.** The indexed jump at `D5CC2` is
> `JMP CS:W[BX + 2DE1h]`, and the routine it sits in is in segment **`D2F2`**, not
> `D000` — every far call in it targets `0D2F2:xxxxx`. The table is therefore at
> `D2F20 + 0x2DE1` = **`D5D01`**, not at file `0x52DE1`. Read at `D5D01` it is exactly
> the country block, and `sub_D5A8B` has two callers, so nothing about the path is
> unreachable. The driver **does** emulate the real DIP → country → NVRAM → language
> chain, and must: it is what the firmware runs on every boot.

The hardware has a country DIP (SW40 SW2–SW4; see
[`hardware_architecture.md`](hardware_architecture.md)) that sets per-country coin
values **and** the language, exactly as the manual's intent says.

### The path, end to end

1. **The 80188 asks for it.** `sub_D5A8B` `D5A8B` pushes Z80 command `0xF9` and waits
   (`sub_D5C3E`, timeout `0x190` ticks). It is called from `D6601` and `D6641`, both
   inside the boot NVRAM block.

2. **The Z80 reads the DIP and answers.** Command `0xF9` → handler `2D9D` (the Z80's
   256-entry table at `$2000`, entry `0xF9`):

   ```asm
   2D9D  DB 04        in   a,(04h)     ; port 0x04 — SW40
   2D9F  F6 F0        or   a,0F0h      ; tag it as the DIP report
   2DA1  32 FC C0     ld   ($C0FC),a
   2DA4  C3 16 01     jp   host_send_c0fc
   ```

3. **The 80188 masks and dispatches it.** In `sub_D5C3E`, after the byte is dequeued:

   ```asm
   D5CA3  cmp  byte [0006h], 0F0h   ; a byte >= 0xF0 is the DIP report
   D5CA8  jnb  D5CAC
   D5CAC  mov  al, [0006h]
   D5CAF  and  al, 0Eh              ; keep SW2-SW4
   D5CB6  sub  ax, 2
   D5CBB  cmp  bx, 0Ch / ja D5CF8   ; a nibble of 0 goes to country 0
   D5CC2  jmp  word [cs:bx+2DE1h]   ; CS = D2F2 -> the table at D5D01
   ```

   The table at `D5D01` is 13 words: `2DA7 2DD8 2DAE 2DD8 2DB5 2DD8 2DBC 2DD8 2DC3
   2DD8 2DCA 2DD8 2DD1`. With `CS = D2F2` those resolve to `D5CC7`, `D5CF8`, `D5CCE`,
   `D5CF8`, `D5CD5`, … — the **country setters themselves**, on the even indices, with
   `D5CF8` (country 0) filling the odd ones. So `country = (port04 >> 1) & 7`, written
   to `[4130:0020]`.

4. **It is then used twice.** `sub_D69CC` `D69CC` applies that country's coin preset
   (one of eight, `D6D36`, `D6DDF` … `D7204`) and `sub_D6BAE` saves it to NVRAM
   `0x1C4`-`0x1CF`. And at `D664D` boot_init compares the DIP-derived country with the
   stored NVRAM `0x1BF`; **if they differ the DIP wins** — NVRAM `0x1BF` and
   `[4000:1001]` are rewritten and the preset re-applied.

5. **Language falls out of the same byte.** `[4000:1001] == 5` selects the Spanish
   string and menu-record tables at `D3277` (attract variant), `D8048` (pricing
   routine) and `DD406` (menu record table `0x00D08` instead of `0x00100`); every
   other value gets the English ones.

### What the old analysis got right, and where it went wrong

The Z80 half (`DB 04 F6 F0` at `0x2D9D`) and the mask arithmetic at `D5CAC` were read
correctly. The dispatch table was resolved with `CS = D000` → file `0x52DE1`, which is
unrelated data and does indeed contain what look like game-event offsets; that produced
the "rewired" reading, and from there the "no caller reaches `D5CAC`/`D5CC7`" claim.
Both fall away once the segment is right. The dump-diff note stands but proves nothing
either way — both dumps are byte-identical there because the code is simply the same.

### Conclusion

> **In V1.3 the country DIP sets both the coin values and the display language.** A
> faithful port-level country DIP is exactly what these ROMs want, and the PinMAME
> driver implements it: port-0x04 bits 1-3 come from PinMAME DIP bank 0
> (`iomoon_port04()` in `src/wpc/sleic.c`, DIP block `SLEIC2_COMPORTS` in `sleic.h`).
> Bridging a "language DIP" straight to `[1001]` would be wrong — it would be
> overwritten from the real DIP on the next boot.

---

## C. Service-menu navigation

### Menu state lives in `[413C:014F]`

The game state machine variable **`game_state_var` `[413C:014F]` (physical `0x4150F`)**
selects the top-level behaviour:

| Value | State |
|-------|-------|
| `1`   | attract |
| `2`   | game in progress |
| `3`   | **menu / special-display** |
| `4`   | special |

The menu state is `[014F] == 3` (7 read sites; written `= 3` at file `0x5815F`),
**not** `[1001] == 5` (which is the language test, §A).

### How a switch press reaches the menu code

The path from a button to the menu navigator is **edge-driven, one byte per press**:

1. **Z80 → J1 → 80188 NMI.** The NMI handler **`dmd_vblank_isr` (`D016D`,
   file `0x5016D`)** reads the J1 inbound latch at `es:[0100h]` (= `A000:0100` =
   peripheral chip-select PCS2, physical `0xA0100`):

   ```asm
   D018C  mov al, [es:0100h]    ; read J1 latch
   D0190  cmp al, 32h           ; end-of-frame marker?
   D0192  jnz …
   D0194  inc byte [1144h]      ; 0x32 just bumps a frame counter
   ```

   A byte `0x32` is an **end-of-frame marker** (it increments `[1144]`), **not** a
   switch. Any other byte is appended to a small ring buffer at `[4000:1154/1150]`
   and the handler sets the **switch-event-pending flag `[4000:1147] = 0xFF`**.

2. **Freshness gate + consumer — `dmd_text_display` (`D74FF`, file `0x574FF`).**
   At **`D750A`** it returns early if the pending flag is clear:

   ```asm
   D750A  mov al, [es:1147h]    ; switch_event_pending
   D750E  cbw
   D750F  or  ax, ax
   D7511  jnz D7518             ; only proceed if a fresh byte exists
   ```

   At **`D75CD`** it dequeues one ring byte into
   **`last_switch_code` `[413C:00D6]` (physical `0x41496`)**, writes `0x00` back into
   the ring slot, and advances the read pointer:

   ```asm
   D75D2  les bx, [es:1150h]    ; ring read pointer
   D75D7  mov al, [es:bx]       ; ring byte
   D75DF  mov [es:00D6h], al    ; -> last_switch_code
   ```

   Because the consumer **zeroes the slot**, a repeated identical code looks "stuck"
   if you only inspect `[00D6]`; each physical press delivers exactly one byte.

3. **Menu navigator — `dmd_attract_cycle` (`D7ABC`).** At **`D7AD5`**:

   ```asm
   D7AD5  cmp ax, 3Fh           ; RIGHT flipper -> game_mode_transition (enter/exit TOGGLE)
   D7AD8  jz  D7AE6             ; -> game_mode_transition DD253 (DD25:0003)
   D7ADA  cmp ax, 40h           ; UPPER flipper -> page STEP (via [413C:00D7] counter)
   D7ADD  jnz D7B11
   D7ADF  call D72A:0DC6
   ```

   The same `cmp byte [es:00D6h], 3Fh` test also appears in
   `attract_display_update` (`D3251`) at `d32a4` and in
   `attract_animation_cycle` (`D32FB`) at `d334e`.

> **IO Moon's V1.3 service menu has NO Bike-Race-style scroll/select code pair**
> (corrected by live-driver testing — the earlier "`0x3F` = advance/select" was
> wrong). The 80188 **never** compares `last_switch_code` against `0x34/0x35/0x36`
> (Bike Race's scroll/select/back family); those codes exist on the wire only as
> matrix Row-5 playfield switches. The menu's only live inputs are:
> - **`0x33`** (TEST/End) — **ENTER** the menu (the Z80's TEST switch emits `0x32` in
>   attract / `0x33` only in game, gated on `c068` @ Z80 `0x0D35`),
> - **`0x3F`** (RIGHT flipper) — **enter/exit TOGGLE** (`game_mode_transition` DD253),
> - **`0x40`** (UPPER flipper) — **page STEP** (increments `[413C:00D7]`; at `==1` sets
>   state 3, then walks pages),
> - **`0x3E`** (LEFT flipper) — **ignored** by the menu.
>
> So on real hardware you *enter* with TEST, *step pages* with the upper flipper, and
> *exit* with the right flipper — there is no per-item cursor. Bike Race (`0x35`=scroll,
> `0x34`=select, verified at `ED1B8`/`ED1F0`) is genuinely different here.
>
> **Driver note:** the emulated Z80's *direct-switch* event path (port 0x03 → debounced
> `C0E3` → emit) does **not** regenerate codes in PinMAME (a forced port-0x03 bit
> produces no J1 byte), so the cabinet buttons must be injected as J1 codes; only the
> *matrix-scanned* switches (coin acceptor `0x37`, playfield) reach the 80188 through the
> Z80. The faithful Z80 codes are LEFT=`0x3E`, RIGHT=`0x3F`, UPPER=`0x40`, START=`0x41`,
> TEST/Coin=`0x42`, on port 0x03 bits 0/1/4/3/2 respectively (`asm/z80_annotated.asm`
> lines 162-167 + flipper dispatch `0x1242`/`0x1252`).

### Menu page draw functions

Which menu page is shown is held in `[413C:00F4]`. The draw functions are
**draw-only** (no input handling — input is the §C path above), and all converge on a
common draw routine at **`loc_F3764`**:

| Routine | Address | Page |
|---------|---------|------|
| `service_credits_menu`   | `F35B7` | credits / pricing |
| `service_switch_test`    | `F35AC` | CONTACTOS (switch test) |
| `service_tilt_menu`      | `F35C2` | FALTA (tilt) |
| `service_sound_menu`     | `F35CD` | sound |
| `service_video_menu`     | `F35D8` | video |
| `service_game_menu`      | `F35E3` | game settings |
| ↳ balls                  | `F35EE` | NUM. BOLAS |
| ↳ extra-ball             | `F35F9` | ORBITAS / extra ball |
| ↳ awards                 | `F3604` | awards |
| ↳ match                  | `F36E0` | match |
| ↳ custom message         | `F36EB` | custom advertising message |
| `service_statistics_*`   | `F370C` / `F3717` / `F3738` / `F3743` | statistics pages |
| `service_factory_reset`  | `F3759` | BORRADO DE TODO |
| `service_lamp_test`      | `F33EF` | LUCES (lamp test) |
| `service_solenoid_test`  | `F3371` | BOBINAS (solenoid test) |

---

## D. Switch hex codes (IO Moon)

These are the codes the Z80 (`V1 3_05.bin`) places on J1 for the 80188 to read as
`last_switch_code`. They are the IO Moon values; do not confuse them with the Bike
Race codes in `bikerace_switch_map.md`.

| Code | Switch | Z80 handler |
|------|--------|-------------|
| `0x3E` | LEFT flipper | `0x125B` |
| `0x3F` | RIGHT flipper | `0x1278` |
| `0x40` | UPPER flipper | `0x1285` |
| `0x41` | START | `0x12C6` |
| `0x42` | COIN | `0x1336` |
| `0x37` | MONEDERO (coin acceptor, matrix) | — |
| `0x33` | TEST / service-menu enter | — |

### DMD / J1 marker bytes (not switches)

These bytes ride the same `0xA0100` ring but are display markers, consumed by the
NMI / frame logic rather than the switch path:

| Byte | Meaning |
|------|---------|
| `0x32` | coin-pulse / end-of-frame marker (increments `[1144]`) |
| `0x45` / `0x46` | DMD field swap |
| `0x47` | DMD vsync |

---

## E. Corrections to mislabeled routines

The auto-disassembler's labels are wrong for several routines around the switch /
menu path. The corrected identities:

- **`DA22D` is the high-score INITIALS-ENTRY handler, not a service-menu dispatcher.**
  It reads `last_switch_code` (`mov al,[es:00D6h]`), tests `0x40`/`0x41`/`0x42`
  (upper-flipper / START / COIN), and walks an alphabet index at local `[0005]`
  (seeded to `0x34` at `DA24F`). It is the player-initials entry screen.
- **The in-game ball-launch switch dispatcher is `switch_dispatch_table_lookup`
  (`D7C2B`)** → a 12-entry code table at **`D72A:0AEC`** (file `0x57D8C`), stored as
  16-bit words: `{0E 19 21 22 2E 34 35 36 37 3E 43 44}`. It is reached only from
  `ball_launch_display` (`DAAAF`), i.e. ball serve — this (not the service menu) is
  where `0x3E` is consumed **in-game**.
- **`D000:04BF`** is the generic NVRAM byte-**read** accessor (epilogue at `D04CC`);
  **`D000:04A9`** is the NVRAM byte-**write** accessor. The language read into
  `[1001]` happens at `D2F2E → D2F3B` (§A).

---

## Address reference table

All addresses spot-checked with `ndisasm` against `roms/1.3 IPDB latest/`.

| Address | File offset | What | Status |
|---------|-------------|------|--------|
| `[4000:1001]` | RAM `0x41001` | language byte (`==5` ⇒ Spanish) | DMD-verified |
| `[413C:014F]` | RAM `0x4150F` | game/menu state (`3` = menu) | verified |
| `[413C:00D6]` | RAM `0x41496` | `last_switch_code` | verified |
| `[4000:1147]` | RAM `0x41147` | switch-event-pending flag | verified |
| `[4000:1144]` | RAM `0x41144` | end-of-frame counter (`0x32` bumps it) | verified |
| `D2F2E`/`D2F3B` | `0x52F2E`/`0x52F3B` | read NVRAM `01BF` → write `[1001]` (once/cycle) | verified (was mis-cited as `D04CC`) |
| `D000:04BF` | `0x504BF` | NVRAM byte-read accessor (tail `D04CC`) | verified |
| `D000:04A9` | `0x504A9` | NVRAM byte-write accessor | verified |
| `DA9A9` | `0x5A9A9` | a `cmp [1001],5` language branch (not menu-enter) | verified |
| `D5CAC` | `0x55CAC` | `and 0Eh` country mask | verified |
| `D5CC2` | `0x55CC2` | `jmp [cs:bx+2DE1]` indexed dispatch | verified |
| `CS:2DE1` (CS = `D2F2`) | flat `D5D01` = `0x55D01` | country dispatch table — the seven country setters on the even indices, `D5CF8` (country 0) on the odd ones | verified 2026-09-03 (the old row resolved CS as `D000` and read unrelated data at `0x52DE1`) |
| `D5CC7` | `0x55CC7` | country block `[4130:0020]=1..7`, reached from the table above | verified 2026-09-03 |
| Z80 `0x2D9D` | `0x2D9D` (Z80 ROM) | `in a,(04); or 0F0h` country DIP read — the handler for 80188 command `0xF9`, requested by `sub_D5A8B` | verified |
| `D016D` / `D018C` | `0x5016D` / `0x5018C` | NMI `dmd_vblank_isr`, reads `A000:0100` | verified |
| `D74FF` / `D750A` | `0x574FF` / `0x5750A` | freshness gate (`[1147]==0`) | verified |
| `D75CD` | `0x575CD` | ring → `last_switch_code` consumer | verified |
| `D7AD5` | `0x57AD5` | `cmp 0x3F` menu enter/exit toggle | verified |
| `DA22D` | `0x5A22D` | initials-entry handler (not menu) | verified |
| `D7C2B` | `0x57C2B` | `switch_dispatch_table_lookup` | verified |
| `D72A:0AEC` | `0x57D8C` | 12-code ball-launch table | verified |

---

## See also

- [Z80 I/O Port Map](z80_io_ports.md) — port `0x04` country DIP, switch-matrix scan, J1 strobes
- [Switch, Lamp & Solenoid Tables](switch_lamp_solenoid.md) — the C-number ↔ name ↔ code mapping
- [Game Software Architecture](game_software.md) — boot, state machine, config system
- [Inter-CPU Communication](inter_cpu_communication.md) — the J1 byte-port and seg-`4000h` layout
- [Hardware Architecture](hardware_architecture.md) — SW40 DIP block and the per-country coin table
