# IO Moon — Language Model & Service-Menu Navigation

[← Back to main README](../README.md)

This document covers three closely related IO Moon (SLEIC2) subsystems:

1. how the firmware selects its on-screen **language** (Spanish vs. English),
2. how the **country DIP** drives both that and the coin values, and
3. how switch presses open and drive the **service / test menu**.

Everything below is verified two ways: against the cross-checked disassembly in
[`../asm/baseline-2026-09/`](../asm/baseline-2026-09/) (findings F5, F11, F14),
and against rendered DMD output from a running PinMAME `SLEIC2` machine.

All file offsets are into ROM1 `roms/1.3 IPDB latest/V1 3_01.bin`. The 80188 runs
this ROM in segment `D000` upward, so **linear `0xDxxxx` = file `0xDxxxx − 0x80000`**
(e.g. linear `D5CAC` = file `0x55CAC`); segment `D000` = file `0x50000`. The Z80 ROM
is `V1 3_05.bin` (flat).

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

### Polarity (DMD-verified)

> **`[1001] == 5` renders SPANISH. Any other value renders ENGLISH.**

Verified on live DMD output: with `[1001] = 0x04` the attract DMD renders
"BALL MISSING" in English, and with `[1001] = 0x05` it renders the Spanish text.

| `[1001]` value | Language | Pre-rendered text set |
|----------------|----------|------------------------|
| `0x05`         | Spanish  | second bitmap of each pair (~seg `1000` set) |
| anything else  | English  | first bitmap of each pair (~seg `3000` set) |

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

`DA9A9` is one of the ~51 language tests, branching between two pre-rendered text
variants. It has nothing to do with the service menu, which is opened by switch
code `0x3F` (see §C).

### Where `[1001]` is written — three sites

There are **three** writes to `[1001]` in the 80188 program, and they split into
two roles: one reload per game cycle, and two overrides at boot.

**The per-cycle reload**, at the head of the main loop (`D2F22`, file `0x52F3B`):

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
D2F3B  mov  [es:1001h], al        ; byte form: 26 A2 01 10
```

So the live language is sourced from **the non-volatile store, offset `0x1BF`**
and read **once per pass through the main-loop head** (`D2F22`), i.e. once per
game cycle, not every frame. `D000:04BF` is the generic byte-read accessor (its
epilogue is at `D04CC`); the caller that reads `0x1BF` and stores it into `[1001]`
is `D2F2E → D2F3B`.

**The two boot overrides** are in the country-init block §B describes, and they
write the DIP-derived country number straight through rather than reading it back
from the store. Both use the register form, which is why a grep for the
immediate-store encoding alone does not find them:

```asm
D6607  mov  dl, [0020h]           ; the country number from [4130:0020]
D660D  mov  [es:1001h], dl        ; register form: 26 88 16 01 10
D6612  ...                        ; then persist it to store offset 0x1BF
```

with the identical sequence again at `D6656`-`D665C`, on the branch `D664D`
takes when the DIP-derived country disagrees with the stored one. Each is
immediately followed by a write of the same value to store offset `0x1BF`
through `D000:04A9` (callers at `D6619` / `D6669`).

**The ordering is what makes the DIP authoritative.** `boot_init` runs the
country block first, so both the store and `[1001]` already hold the DIP's value
by the time the main-loop head reloads `[1001]` from the store — the reload
therefore re-reads what the DIP just wrote. Forcing `[1001]` from outside the
firmware is overwritten at the next boot for the same reason.

---

## B. The country DIP sets the coin values and the language

The hardware has a country DIP (SW40 SW2–SW4; see
[`hardware_architecture.md`](hardware_architecture.md)). The firmware reads it on every
boot and acts on it twice: it selects the per-country coin-value preset, and it selects
the display language. A driver must emulate the DIP → country → NVRAM → language chain
rather than writing the language byte directly, because the chain re-derives that byte
from the DIP at each power-on.

**Segment note for anyone re-reading the dispatch:** the indexed jump at `D5CC2` is
`JMP CS:W[BX + 2DE1h]` and the routine it sits in runs with **`CS = D2F2`** — every far
call in it targets `0D2F2:xxxxx`. Its table is therefore at `D2F20 + 0x2DE1` = **`D5D01`**
(file `0x55D01`). Resolving that displacement against `D000` lands on `0x52DE1`, which is
unrelated data.

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
   D5CC0  shl  bx, 1                ; word index
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

### Which switch is the low bit, and where the ROM differs from the manual

`SW2` is the low bit, with ON = 0. That is settled by the presets themselves and
not by the two obvious anchors: country 0 = the manual's UK row and country 5 =
its Spain row are both invariant under swapping SW2 and SW4 (`000` and `101` are
palindromes), and so is Germany (`010`). The rows that discriminate are Italy,
Netherlands, France and Belgium, and with SW2 as the low bit six of the eight
rows match the manual exactly:

| Value | Divisors (pulses) | Credits | Manual row | Verdict |
|-------|-------------------|---------|------------|---------|
| 0 | 3 / 5 / 10 | 1 / 2 / 5 | United Kingdom | exact |
| 1 | 2 / 5 / 10 | 1 / 3 / 7 | France | differs (manual 3/5/10, 1/2/5) |
| 2 | 1 / 2 / 5 | 1 / 3 / 8 | Germany | exact |
| 3 | 1 / 2 / 4 | 1 / 3 / 7 | Italy | exact |
| 4 | 2 / 5 / 10 | 1 / 3 / 7 | Netherlands | exact |
| 5 | 2 / 4 / 8 / 20 | 1 / 3 / 7 / 18 | Spain | coins exact, third credit 7 vs 8 |
| 6 | 2 / 4 / 10 | 1 / 3 / 8 | Belgium | differs (manual 2/5/10, 1/3/7) |
| 7 | 1 / 2 / 4 | 1 / 3 / 6 | Portugal | coins exact, third credit 6 vs 7 |

Reverse SW2 and SW4 and three of the four discriminating rows break — value 3
would have to be Belgium, value 4 France and value 6 Italy — buying only
Netherlands at value 1. The ROM is what runs: values 1 and 6 carry coin values
that are not the manual's at all (value 1 is a byte-for-byte duplicate of value
4's Netherlands preset), and values 5 and 7 differ by one credit on their largest
coin.

### Conclusion

> **In V1.3 the country DIP sets both the coin values and the display language.** A
> faithful port-level country DIP is exactly what these ROMs want, and the PinMAME
> driver implements it: port-0x04 bits 1-3 come from PinMAME DIP bank 0
> (`iomoon_port04()` in `src/wpc/sleic.c`, DIP block `SLEIC2_COMPORTS` in `sleic.h`).
> Bridging a "language DIP" straight to `[1001]` would be wrong — it would be
> overwritten from the real DIP on the next boot.

---

## C. Service-menu navigation

### What opens it

**Switch code `0x3F` opens the service menu.** It is the Z80's port-`0x03` bit-1
input (`sub_1278` at `1278`), delivered over J1 like any other switch code and
dispatched from the `413C:00D6` shadow:

```asm
D7ACF  mov al, [es:00D6h]      ; the switch-code shadow (F5)
D7AD5  cmp ax, 3Fh
D7AD8  jz  D7AE6
D7AE6  call 0DD25:0003         ; sub_DD253, the menu root
```

The same test also appears at `D32A4` and `D334E` (`cmp byte [es:00D6h], 3Fh`).
Code `0x40` (START) is the adjacent branch at `D7ADA` and is not the menu key.
The menu is also entered automatically on a boot self-test fault, from
`main_entry` at `D2FB4`.

The menu root `sub_DD253`:

```asm
DD263  mov word [es:015Ah], 0    ; record index = 0
DD274  push 0F7h / call qout_push ; Z80 command 0xF7 = enter test mode
DD294  call sub_DD2E6            ; the menu loop
DD29E  push 0F8h / call qout_push ; Z80 command 0xF8 = leave test mode
```

On the Z80 side `0xF7` → `2DC4` sets `C068`; `0xF8` → `2DD9` clears it, does `DI`
and `JP boot` — **leaving the menu reboots the I/O Z80**, which re-runs
`boot_port_init` and re-initialises every lamp column and both driver latches.
That is the firmware's design, not a fault.

### How a switch press reaches the menu code

The path from a button to the menu is edge-driven, one byte per press:

1. **Z80 → J1 → 80188 NMI.** The Z80 stages the code in `C0FC` and strobes
   port-`0x81` bit 2. The 80188's NMI handler `isr_type02_nmi` (`D016D`) reads
   the inbound latch at PCS2 `0xA0100`:

   ```asm
   D018C  mov al, [es:0100h]    ; the ONLY read of 0xA0100 in the whole ROM
   D0190  cmp al, 32h           ; the coin-mechanism pulse?
   D0192  jnz D019B
   D0194  inc byte [1144h]      ; 0x32 is counted, not queued
   D019B  ...                   ; everything else -> the FIFO at 4000:1220
   D01C4  mov byte [1147h], 0FFh ; "byte available"
   ```

2. **Dequeue and shadow.** `sub_D7453` (and about a dozen sibling poll routines)
   pops one byte from the FIFO — far read pointer at `[1150]`, write pointer at
   `[1154]` — and stores it in `last_switch_code` `[413C:00D6]` (physical
   `0x41496`):

   ```asm
   D745E  mov al, [es:1147h]     ; anything pending?
   D7471  cmp word [es:1144h], 0 ; the coin counter first
   D749C  les bx, [es:1150h]     ; FIFO read pointer
   D74A9  mov [es:00D6h], al     ; ES = 413C -> flat 0x41496
   ```

   Every consumer pops **unconditionally** and then tests, so a byte arriving
   while the firmware sits in a different poll routine is consumed and dropped.

3. **Dispatch.** `D7AD5` compares the shadow against `0x3F` as above.

`413C:00D6` is a firmware RAM variable, not a hardware mailbox: an emulator must
deliver the byte through J1 and let `sub_D7453` fill it. Note also that game code
stores `0x32` into it directly at four sites (`DAF0C`, `DB1B4`, `DB298`,
`DB2BA`), so a value in the shadow does not imply a byte arrived over J1.

### The record tree

The menu loop `sub_DD2E6` indexes a table of **46-byte (`0x2E`) records** through
the far pointer at `[4137:004B]`, using `[413C:015A]` as the index, and dispatches
each record's first word through a 14-way jump table at `CS:018F`:

```asm
DD2F1  mov ax, [es:015Ah] / imul ax, 2Eh
DD2F8  les bx, [004Bh] / add bx, ax
DD2FE  mov bx, [es:bx] / cmp bx, 0Dh
DD306  shl bx, 1 / jmp word [cs:bx+018Fh]
```

`sub_DD3FB` sets that far pointer to flat **`0x00100`** (English) or **`0x00D08`**
(country 5, Spanish). Each record is
`{word type, word item count, word line count, 4 × 8-byte line descriptor,
4 × word child index}`. Walked from record 0 the tree is 38 records deep:

```
0  ADJUSTMENT      -> 1 SOUND/VIDEO, 2 GAME, 3 TECHNICAL
1  SOUND           -> 4 VOLUME (type 9), 5 CUSTOM MESSAGE (type 6)
2  GAME            -> 31, 6, 7, 8
3  TECHNICAL       -> 22 BOARD TEST, 23 CREDITS (type 8), 30 TILTS
```

with 8 → {9,10,11}, 11 → {12,15,18}, 12 → {13,14}, 15 → {16,17},
18 → {19,20,21}, 22 → {24,25,26}, 25 → {35,36,37}, 26 → {32,33,34},
6 → {27,28,29}. Type 0 is a submenu; types 1–13 are leaf pages.

### Navigation

Ordinary item handlers accept exactly four codes and dispatch through a
four-entry table. `sub_DD480` (record type 0) is the pattern:

```asm
DD4E1  call sub_DF9D4 / mov [001Bh],al / cmp byte [001Bh],0 / jz DD4E1  ; block
DD4F5  sub ax, 3Fh
DD4FA  cmp bx, 3 / ja DD4E1                     ; only 0x3F..0x42
DD501  jmp word [cs:bx+0337h]                   ; table at DD587
DD587  2B 03  0D 03  B6 02  FE 02   -> DD57B  DD55D  DD506  DD54E
```

| Code | Button | Target | Action |
|------|--------|--------|--------|
| `0x3F` | TEST | `DD57B` | redraw, return 1 — **exit** this item to its caller |
| `0x40` | START | `DD55D` | at record 0 the same exit, otherwise `sub_DF829` — **back / up** |
| `0x41` | left flipper | `DD506` | `[4137:0013]++` with a wrap at `record[2]-1`, recompute the display line `413C:0158`, redraw — **scroll** |
| `0x42` | right flipper | `DD54E` | `sub_DF764([4137:0013])` — **select** the line under the cursor |

`sub_DD669` (record type 9, the VOLUME page) has the same shape with its own
table at `DD6F4`, adding volume up/down on `0x41`/`0x42`.

The cursor is `[4137:0013]`, **not** `[413C:015A]`: `015A` is written in exactly
one place in the whole ROM (`DD263`, zeroed on entry) and holds the record being
displayed, which changes only on a descent.

### What paces the display

Nothing external. Each menu item is a blocking routine that pushes Z80 commands
and spins on an inbound byte — the lamp test `sub_D5F99` is the clearest case:

```asm
D5FA4  push 0FAh / call qout_push      ; Z80 cmd 0xFA
D5FCC  push [000Eh] / call qout_push   ; push lamp codes 0x01..0x31 in turn
D6027  call sub_D5BCF / or al,al / jz D6027   ; wait for ANY inbound byte
```

So the menu holds open for exactly as long as switch bytes keep being delivered.
It needs no frame clock and no marker stream: the DMD raster coprocessor at IC23
sends the 80188 nothing at all.

### Two pages worth knowing

- **Record 4, VOLUME** (type 9) calls `fm_song_select(1)` on entry (`DD66F`) — a
  real firmware music trigger reachable from attract with no credits, in three
  keypresses.
- **Record 23, CREDITS** (type 8) renders the live pricing table, which is the
  cheapest check that the country DIP (§B) is being read correctly.

Verified against the rendered DMD: the root draws `- ADJUSTMENT -` over
SOUND/VIDEO, GAME, TECHNICAL; scrolling moves the highlight; selecting TECHNICAL
then CREDITS renders `1 OF 50E CRED:1 / 1 OF 100 CRED:3 / 1 OF 200 CRED:6`,
matching country 7's preset byte for byte; and country 5 renders the same tree in
Spanish (`- AJUSTE -`, SONIDO/VIDEO, JUEGO, TECNICO) from record table `0x0D08`.

**There is no OKI sound-test page.** Above `DD000` the ROM has exactly two calls
to the OKI dispatcher `sub_D0B70`, and one of them is the coin sound in
`sub_DD1C1` (`DD1E0`); the other is `F2C2E`, in game code. The sound branch of
the menu is FM and volume only.

### The boot language prompt

`sub_D5AD1` `D5AD1` pushes Z80 command `0xED` and spins on `sub_D5D8D` for `0x45`
(option A, drawing the string triple at record offsets `0x0C`/`0x0E`/`0x10`) or
`0x46` (option B, offsets `0x06`/`0x08`/`0x0A`). The Z80's `0xED` handler `2BEB`
reads **port `0x04` bit 5** — SW40-5 — to choose: low is the service position
"no balls dispensed" and answers at once, high is normal play and checks the ball
trough first.

**That prompt is one *use* of `0x45`, not its definition.** `0x45` also reaches
the ordinary switch-code shadow and is dispatched there at five sites — `D7B2E`,
`DC063`, `DC08E`, `DC0B5`, `DC0EE`. Routing it only to `sub_D5D8D`, or reserving
it as a "prompt reply", breaks every one of those. The same holds for `0x46` and
`0x47`: they are event codes the Z80 sends, and the prompt and the boot handshake
are two of the states that happen to be listening for them.

---

## D. Switch hex codes (IO Moon)

These are the codes the Z80 (`V1 3_05.bin`) places on the J1 event channel for the
80188 to read as `last_switch_code`. They are the IO Moon values; do not confuse
them with the Bike Race codes in [`bikerace_switch_map.md`](bikerace_switch_map.md).

| Code | Input | Z80 handler |
|------|-------|-------------|
| `0x0A`–`0x31` | switch matrix, columns 0–4 (`0x0A + 8c + b`) | 40 routines at `316D`, step 8 |
| `0x32` | coin mechanism, port `0x03` bit 5 (`0x33` in test mode) | `0D3C` / `0D44` |
| `0x34`–`0x3B` | switch matrix, column 5 (`0x34 + b`) | 8 routines at `32AD`, step 8 |
| `0x38`–`0x3D` | trough/device counts re-sent by the ball commands `0xEA`/`0xEB` | `2A90`, `2AA0`, `2AA8`, `2AEB`, `2AF3`, `2AFB` |
| `0x3E` | TILT, port `0x03` bit 0 | `sub_125B` `125B` |
| `0x3F` | TEST — **opens and exits the service menu** | `sub_1278` `1278` |
| `0x40` | START, port `0x03` bit 4 — **back/up in the menu** | `sub_1285` `1285` |
| `0x41` | LEFT flipper (test mode only) — **scroll** | `sub_1292` `12D0` |
| `0x42` | RIGHT flipper (test mode only) — **select** | `sub_12D8` `1340` |
| `0x43` | ball over — sent by trough contact 0 instead of its own `0x0A` | `161E` |
| `0x45` / `0x46` | the two answers to 80188 command `0xED` (and ordinary event codes) | `2C17` / `2C09` |
| `0x47` | the Z80's boot "alive" byte | `0410`, resent at `2E24` |
| `0x48`–`0x4A` | "no balls" / "gave up" replies to the ball commands | `2A45`, `2AB0`, `2B03` |
| `0x50`–`0x79` | the 16-way direct-input scan (disabled on this machine) | `direct_input_scan` `0DBF`, table at `1218` |
| `0x7A` | "all direct inputs clear", the reply to command `0xC0` | `11F5` |
| `0xF0`+nibble | the port-`0x04` DIP report, the reply to command `0xF9` | `2D9D` |

**There are no marker bytes.** `0xA0100` carries Z80 bytes and nothing else: the
DMD raster coprocessor has no path to that latch and no command interface at all
(see [`../asm/pic16c57_annotated.asm`](../asm/pic16c57_annotated.asm) and finding
F4). `0x32` is the coin pulse, and `0x45`/`0x46`/`0x47` are ordinary Z80 replies.

---

## E. Routine identities

Generated labels in [`../asm/superseded/`](../asm/superseded/) are wrong for
several routines on this path. The identities established from the fresh decode:

- **`D000:016D` is the inbound-J1-byte NMI handler**, not a DMD vblank ISR — it
  reads PCS2 and touches no pixel data.
- **`D000:0343` is the INT0 handler**, not a timer ISR; timer 0's handler is at
  `D000:024F`.
- **`DA22D` is the high-score initials-entry handler**, not a service-menu
  dispatcher. It reads `last_switch_code`, tests `0x40`/`0x41`/`0x42`, and walks
  an alphabet index at local `[0005]` (seeded to `0x34` at `DA24F`).
- **`D000:04BF`** is the generic non-volatile byte-**read** accessor (epilogue at
  `D04CC`); **`D000:04A9`** is the byte-**write** accessor. The language read into
  `[1001]` happens at `D2F2E → D2F3B` (§A).
- **The `F35xx` family are paired language text-draw routines, not menu pages.**
  `sub_F2FFD` is a one-line far-callable wrapper around `sub_F35AC` and
  `sub_F3007` around `sub_F35B7`, and the two wrappers are the Spanish/English
  arms of the `cmp [1001],5` branch at `DA9B1`/`DA9B8`. The menu's own dispatch is
  the 14-way jump table at `CS:018F` described in §C.
- **The in-game switch dispatcher is `sub_D7636`**, whose 55-entry table at
  `CS:0527` is range-checked against `0x0E` first, so the ball-handling codes
  `0x0A`–`0x0D` deliberately reach no handler there.

---

## Address reference table

| Address | File offset | What |
|---------|-------------|------|
| `[4000:1001]` | RAM `0x41001` | country / language byte (`==5` ⇒ Spanish) |
| `[4000:1144]` | RAM `0x41144` | coin-pulse counter (`0x32` bumps it) |
| `[4000:1147]` | RAM `0x41147` | inbound-byte-available flag |
| `[4000:1220]` | RAM `0x41220` | inbound J1 byte FIFO, through `0x412E7` |
| `[4130:0020]` | RAM `0x41320` | country number 0–7 |
| `[4137:0013]` | RAM `0x41383` | service-menu cursor |
| `[4137:004B]` | RAM `0x413BB` | far pointer to the menu record table |
| `[413C:00D6]` | RAM `0x41496` | `last_switch_code` |
| `[413C:014F]` | RAM `0x4150F` | game mode (1 attract, 2 credits, 3 game start, 4 ball in play) |
| `[413C:015A]` | RAM `0x4151A` | the menu record being displayed |
| `D016D` / `D018C` | `0x5016D` / `0x5018C` | `isr_type02_nmi`, the only read of `0xA0100` |
| `D2F2E` / `D2F3B` | `0x52F2E` / `0x52F3B` | read store offset `0x1BF` → write `[1001]`, once per cycle |
| `D000:04A9` / `D000:04BF` | `0x504A9` / `0x504BF` | non-volatile byte write / read accessors |
| `D5A8B` | `0x55A8B` | push Z80 command `0xF9` and wait for the DIP report |
| `D5CAC` | `0x55CAC` | `and 0Eh` country mask |
| `D5CC2` | `0x55CC2` | `jmp [cs:bx+2DE1]`, `CS = D2F2` → the table at `D5D01` |
| `D5D01` | `0x55D01` | country dispatch table: the seven setters on even indices, `D5CF8` (country 0) on the odd ones |
| `D69CC` | `0x569CC` | apply the country's coin preset |
| `D7453` / `D74A9` | `0x57453` / `0x574A9` | dequeue one FIFO byte into `last_switch_code` |
| `D7AD5` | `0x57AD5` | `cmp 0x3F` — the service-menu entry test |
| `DD253` | `0x5D253` | menu root: `0xF7`, the loop, `0xF8` |
| `DD2E6` / `DD306` | `0x5D2E6` / `0x5D306` | menu loop and its 14-way jump table at `CS:018F` |
| `DD480` / `DD501` / `DD587` | `0x5D480` / `0x5D501` / `0x5D587` | record-type-0 handler, its four-code dispatch and its table |
| `DD3FB` | `0x5D3FB` | select the English (`0x00100`) or Spanish (`0x00D08`) record table |
| `DA22D` | `0x5A22D` | high-score initials entry |
| `DA9A9` | `0x5A9A9` | a `cmp [1001],5` language branch |
| Z80 `0x1278` | `0x1278` (Z80 ROM) | port-`0x03` bit 1 → code `0x3F` |
| Z80 `0x2BEB` | `0x2BEB` (Z80 ROM) | command `0xED`: `IN A,($04) / BIT 5,A` → `0x45` or `0x46` |
| Z80 `0x2D9D` | `0x2D9D` (Z80 ROM) | command `0xF9`: `IN A,($04) / OR 0F0h` |
| Z80 `0x2DC4` / `0x2DD9` | `0x2DC4` / `0x2DD9` | commands `0xF7` / `0xF8` — test mode on, and off with a reboot |

---

## See also

- [Z80 I/O Port Map](z80_io_ports.md) — port `0x04` country DIP, switch-matrix scan, J1 strobes
- [Switch, Lamp & Solenoid Tables](switch_lamp_solenoid.md) — the C-number ↔ name ↔ code mapping
- [Game Software Architecture](game_software.md) — boot, state machine, config system
- [Inter-CPU Communication](inter_cpu_communication.md) — the J1 byte-port and seg-`4000h` layout
- [Hardware Architecture](hardware_architecture.md) — SW40 DIP block and the per-country coin table
