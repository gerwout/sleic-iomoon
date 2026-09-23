# Sleic Pin-Ball — the endgame screen state machine

Source: `sp03-1_1.rom` (128 KB, 80188 game code, physical `0xE0000-0xFFFFF`,
`E000:xxxx` = file offset `xxxx`, `F000:xxxx` = file offset `0x10000+xxxx`),
decoded with a recursive-descent Capstone (`CS_ARCH_X86`/`CS_MODE_16`) pass
seeded at the addresses below and confirmed by an exhaustive byte-level scan
of the ROM for every `MOV`-family instruction that references the five
addresses in question. The committed `sp03_80188_ndisasm.asm` is a flat sweep
and is not used as evidence here — where it and this pass disagree (see the
`F000:0B0D` note below), this pass wins, per the project's own caution about
that listing.

## The screen state machine

### The five variables

All five live at physical `DS:0000` (segment 0), read and written throughout
`F000` code with the 16-bit direct-address `MOV` forms (`A0`-`A3`, `C6 06`,
`C7 06`), always with `DS` as the implicit or explicit (`3E`) segment.

| Address | Size | Meaning | Confirmed by |
|---|---|---|---|
| `[0000:027E]` | byte | **Arm flag.** `0xFF` = a handler is installed and running; `0x00` = idle, dispatcher does nothing. | The dispatcher itself, `F000:01BC` (below) |
| `[0000:027F]` | word | **Tick delay.** Decremented once per dispatcher call; the handler at `[0281]` runs when it reaches 0. | Same |
| `[0000:0281]` | word | **Next handler.** An offset in segment `F000`, reached by a **near** `JMP AX` — so every installed handler must end in `RETF`, popping the far return address left on the stack by whatever originally far-called into the dispatcher (a periodic driver routine, not traced here). | Same |
| `[0000:0283]` | word | **Handler parameter A.** No fixed meaning — each handler interprets it as it likes. Empirically the most common use is a **repeat counter**, loaded into `CX` and written back at the end of a tick so it persists across invocations. | `F000:0211` (below); set to `0` by handlers that don't use it (e.g. the continue-prompt install, `F000:507D`) |
| `[0000:0285]` | word | **Handler parameter B.** Empirically the most common use is a **display-buffer offset**, loaded into `DI`. Read at well over 80 call sites across the ROM via `MOV DI, WORD PTR [0x285]` — this is the single most common thing done with the value. | `F000:0211` (below); `F000:5083` sets it to `0x0711`, matching the digit position the continue-prompt handler draws to |

`[0283]` and `[0285]` are per-screen parameters rather than fixed roles —
`[0283]` is a parameter, not a second delay — and each handler decides what
both of them mean.

**The dispatcher**, `F000:01BC`-`F000:01D4` (called once per tick from
outside this listing, not traced here):

```
F000:01BC  a07e02      mov al, byte ptr [0x27e]
F000:01BF  22c0        and al, al
F000:01C1  7501        jne 0x1c4
F000:01C3  cb          retf                    ; [027E]==0: idle, do nothing
F000:01C4  a17f02      mov ax, word ptr [0x27f]
F000:01C7  23c0        and ax, ax
F000:01C9  7405        je 0x1d0
F000:01CB  48          dec ax
F000:01CC  a37f02      mov word ptr [0x27f], ax
F000:01CF  cb          retf                    ; not yet time: count delay down
F000:01D0  a18102      mov ax, word ptr [0x281]
F000:01D3  ffe0        jmp ax                  ; delay expired: hand off to the handler
```

A second, structurally identical triplet exists at `[0287]`/`[0288]`/`[028A]`
(`F000:01D5`-`F000:01EC`), dispatched the same way. This is a **second,
independent instance of the same generic mechanism**, not a continuation of
the first — corroborating evidence that `027E`/`027F`/`0281` is a reusable
"arm flag / delay / handler" idiom rather than three screen-specific bytes.

**A handler that uses both parameters**, the wipe/fill effect at `F000:0211`
(installed by `F000:01EE`, which sets `[0283]=0x20`, `[0285]=0x14`):

```
F000:0219  8b3e8502    mov di, word ptr [0x285]     ; DI  <- param B
F000:021D  8b0e8302    mov cx, word ptr [0x283]     ; CX  <- param A
F000:0221  51          push cx
...                                                  ; draws a 32-row block from a
                                                       ; fixed pattern table into es:[di]
F000:0244  e203        loop 0x249
F000:0246  e90f00       jmp 0x258                    ; CX reached 0: finished, don't re-arm
F000:0249  893e8502    mov word ptr [0x285], di     ; DI  -> param B  (persist buffer pos)
F000:024D  890e8302    mov word ptr [0x283], cx     ; CX  -> param A  (persist repeat count)
F000:0251  b80500      mov ax, 5
F000:0254  a37f02      mov word ptr [0x27f], ax     ; re-arm: 5-tick delay
F000:0257  cb          retf
```

**The continue-prompt install**, `F000:5065`-`F000:5091` (immediately after
the `¿ CONTINUAS ?` text draw at `F000:5056`-`F000:5064`, byte-contiguous with
it but a separate `RETF`-terminated routine — the two are always called as a
pair, never independently):

```
F000:5065  be3653      mov si, 0x5336
F000:5068  bf1007      mov di, 0x710
F000:506B  e89f04      call 0x550d             ; draw the digit placeholder (8-row font)
F000:506E  3ec606c6020a mov byte ptr ds:[0x2c6], 0xa   ; ten-second counter = 10
F000:5074  b89250      mov ax, 0x5092
F000:5077  a38102      mov word ptr [0x281], ax  ; next handler = F000:5092
F000:507A  b80000      mov ax, 0
F000:507D  a38302      mov word ptr [0x283], ax  ; param A unused by 5092: 0
F000:5080  b81107      mov ax, 0x711
F000:5083  a38502      mov word ptr [0x285], ax  ; param B = 0x711 (unused by 5092 either — it hardcodes DI=0x711 itself)
F000:5086  b80000      mov ax, 0
F000:5089  a37f02      mov word ptr [0x27f], ax  ; delay = 0 (fire on the very next tick)
F000:508C  b0ff        mov al, 0xff
F000:508E  a27e02      mov byte ptr [0x27e], al  ; armed
F000:5091  cb          retf
```

The install spans `F000:5065`-`5091`: the instructions above `5086` set
`[0281]` and `[0283]` as well, so the whole block, not just the arm at its
tail, is what stages this screen.

`F000:5092` itself (the polling handler) decrements `[0x2c6]`, redraws the
digit, and re-arms with `[027F]=0xFA` (250) each tick it is still counting;
when `[0x2c6]` underflows to `0xFF` it clears `[027E]` (`F000:50EA`,
`3e c6 06 7e 02 00`) and clears a small `3×8`-byte region at buffer offset
`0x710` (`F000:50FB`, see "Redraw" below) — but it never touches `[0281]`.
The chain-on for this screen happens **outside** the `[0281]` mechanism: it is
E000 game-logic code (`E000:0AC9`-`0BB7`) that polls `F000:54EF` for switch
code `0x05` (START, per `sleicpin_switch_map.md`) in a loop that also
tolerates codes `0x03`/`0x04` (flippers) and `0x06` (coin), and exits either
on a qualifying press or on `[0x2c6]==0xFF`; on exit it clears `[027E]`
itself (`E000:0B81`) as a belt-and-braces stop, independent of whether
`F000:5092`'s own countdown already did.

### The observed handler chain at game over

There are **two different mechanisms** in play, not one:

**1. The continue offer is E000 game logic**, not a `[0281]` handler chain.
`E000:0AC9` is called once (from `E000:09C6`, itself part of the ball/game-end
sequence that also clears the in-game flag `[0000:0103]` — see "The
game-state, credit and score variables" below).

Its player test is a four-way **unrolled cascade**, not a loop: it tries the
highest active player first and stops at the first one that qualifies, pairing
`cmp byte [0106],N / JB` with `cmp byte [<base>],1 / JB` for N = 4, 3, 2 and
then falling through to player 1.

| Player | Guard | "Qualifies" byte |
|---|---|---|
| 4 | `E000:0AD2` `cmp [0106],4` | `E000:0ADA` `cmp [0257],1` |
| 3 | `E000:0AE5` `cmp [0106],3` | `E000:0AED` `cmp [0235],1` |
| 2 | `E000:0AF8` `cmp [0106],2` | `E000:0B00` `cmp [0213],1` |
| 1 | — | `E000:0B0B` `cmp [01F1],1` |

The four "qualifies" bytes are addressed by four separate direct-address
instructions rather than through an index register, so the `0x22` between them
is an observation about the four addresses, not an indexed structure the code
walks.

The offer itself then far-calls `F000:5056` (draw), conditionally `F000:5065`
(install the countdown), and polls switches until the player answers or the
countdown expires. The countdown is installed **only when credits are short**:
`E000:0B19` calls the credit loader `E000:1463`, and `E000:0B1C`-`0B24`
compares the resulting credit count `[0000:0100]` against the player count
`[0000:0106]`, skipping `F000:5065` when credits are the greater. The same
compare is repeated at `E000:0B45` after the answer. This is a blocking E000
wait, but it does not block interrupts (no `CLI`), so the `[0281]`-driven
`F000:5092` keeps animating the digit while E000 waits.

**2. Everything from the bonus count-up through `LOTERIA` and back to
attract is a single 25-step table**, indexed by `[0000:017D]` (range `0`-`0x18`,
wrapping — confirmed by the wrap check at `E000:50D5`,
`cmp word ptr [0x17d],0x18` / reset to `0` on match), read once per tick by:

```
E000:4F4E  3e833edf0400  cmp word ptr ds:[0x4df], 0
E000:4F54  7401          je 0x4f57
E000:4F56  c3            ret                    ; [4DF] (a hold-timer) not yet 0: wait
E000:4F57  3e803e7e0200  cmp byte ptr ds:[0x27e], 0
E000:4F5D  7401          je 0x4f60
E000:4F5F  c3            ret                    ; the F000 mini-state-machine still armed: wait
E000:4F60  3e803ec10200  cmp byte ptr ds:[0x2c1], 0
E000:4F66  7401          je 0x4f69
E000:4F68  c3            ret                    ; a second busy flag [2C1] still set: wait
E000:4F69  be7c4f        mov si, 0x4f7c         ; SI = table base
E000:4F6C  3ea17d01      mov ax, word ptr ds:[0x17d]
E000:4F70  ba0200        mov dx, 2
E000:4F73  f7e2          mul dx
E000:4F75  03f0          add si, ax             ; SI = table + 2*[17D]
E000:4F77  2e8b04        mov ax, word ptr cs:[si]
E000:4F7A  ffe0          jmp ax                 ; jump to this step's E000 code
```

`[0000:02C1]` is the same "screen-effect busy" flag the fade/dissolve handlers
(`F000:0061`, `F000:00F2`, `F000:0291`) clear on their own completion — a
second, E000-visible busy gate layered on top of the F000 `[027E]` one.

Table (`E000:4F7C`, 25 words, one per step):

| step | table value | what it does | content (where confirmed) |
|---|---|---|---|
| 0-17 | various | bonus count-up / per-player "FIN DEL JUGADOR" animation and its fade transitions | **not traced**; each installs a `[0281]` handler in the same style as `F000:0211`/`F000:5065` |
| 18 | `E000:5043` | branches on `ES:[0x900]` | not traced |
| **19** | `E000:506D` → far-calls `F000:0B88` | clear (`F000:DEFC`) + border (`F000:26B`) + two string records | **"BOLA EXTRA"** (extra-ball award) — record `F000:0BCB` decodes as `- BOLA EXTRA -` in the 10-row font |
| **20** | `E000:50BF` → far-calls `F000:00BD` | installs the fade-in handler `F000:00F2` | dissolve transition |
| **21** | `E000:507C` → far-calls `F000:0BA5` | clear + border + three records (two via a different, undecoded routine `F000:0C5B`, likely a digit/game-number display) | **"PARTIDA"** — record `F000:0BEB` decodes as `- PARTIDA -` |
| **22** | `E000:50BF` (same target as step 20) | same fade-in handler | dissolve transition |
| **23** | `E000:5090` → far-calls `F000:0B02` | clear + border + three records | **"LOTERIA"** — record `F000:0B28` decodes as `- LOTERIA -`; records `F000:0B44`/`F000:0B66` decode (8-row font) as `SI DAS A LA BOLA` / `PREMIADA PIERDES` — the mini-game's own rule text |
| 24 | `E000:50BF` again | same fade-in handler | dissolve transition, presumably into whatever follows (record entry / attract — not traced) |

String decoding used the 10-row font at `F000:83D9` (stride 10) and 8-row
font at `F000:85EB` (stride 8), computing glyph index as `(pointer-base)/stride`
for each word in a record and mapping `0`-`9` to digits, `10` to space,
`11`-`24`/`26`-`37` to `A`-`Z` (`Ñ` at `25`, per the existing font-table
convention in `docs/superpowers/`), and treating out-of-range indices as
punctuation (index `47` decodes consistently as `-` across three different
records, `50`/`51` as `¿`/`?` in `¿ CONTINUAS ?`) — offered as corroboration,
not as a claim about the exact punctuation table (that is Task 5's job).

**Record name entry and attract are not in this table's traced range** and are
not established by this task; steps 0-18 and 24-onward are not decoded beyond
confirming they exist and follow the same table/dispatch mechanism.

**Correcting the flat listing:** the committed `sp03_80188_ndisasm.asm`
places the LOTERIA-record reference at `F000:0B0D`. The correct address,
confirmed by decoding from the actual preceding instruction boundary (the
routine's real entry is `F000:0B02`; the two bytes at `F000:0B00`-`0B01` are
the tail of an unrelated, earlier routine, `mov ax,0 / mov ds,ax / ret`), is
**`F000:0B0C`** (`be 28 0b`, `mov si, 0xb28`). The flat sweep is one byte off
because it free-runs from offset 0 and mis-decodes the data preceding this
routine.

### The interception point

**Nothing installs a handler offset for `LOTERIA`.** An exhaustive scan of the
entire ROM for every `MOV`-family instruction referencing `[0000:0281]`
(direct forms `A1`/`A3`, and the immediate forms `C7 06 81 02`) finds every
hit inside segment `F000` — none in `E000` — and **none of them writes any
address associated with the lottery screen**. A further scan for every near
(`E8`) or far (`9A`) `CALL`/`JMP` in the entire ROM whose resolved target is
`F000:0B02` (the lottery draw routine, confirmed by content above) finds
**exactly one reference in the whole image**:

```
E000:5090  9afcde00f0   lcall 0xf000, 0xdefc     ; clear the DMD buffer
E000:5095  9a020b00f0   lcall 0xf000, 0xb02      ; draw LOTERIA
E000:509A  3ec706df046400  mov word ptr ds:[0x4df], 0x64   ; hold 100 ticks
E000:50A1  e93100       jmp 0x50d5                ; advance [0x17d]
```

`LOTERIA` is entered by a direct far call from the `[0x17d]` sequencer's step
23, never through `[0000:0281]`. `[0281]` is a reusable mechanism that *some*
steps use for their own multi-tick animation (the fade/dissolve steps, the
bonus count-up), but the LOTERIA, BOLA EXTRA and PARTIDA screens are drawn
once by a plain far call and never touch it.

Given that, the hook has to sit at the one real call site. Patching the far
call at `E000:5095` would work — its 2-byte offset operand is all that would
need to change, since the cave stays in the same segment — but that address
is in `E000`, outside the area the plan scopes the cave to ("the cave lives
in segment F000 only"). Hooking the routine's own entry, `F000:0B02`, is
functionally identical (it is the only call site) and keeps the patch
entirely inside `F000`. Its first instruction is a **second, redundant**
clear — `E000:5090` already clears the buffer immediately before calling it
— so replacing that instruction costs nothing:

```
HOOK_SITE     = F000:0B02
HOOK_ORIGINAL = 9A FC DE 00 F0   (5 bytes: lcall 0xF000:0xDEFC)
NEXT_HANDLER  = F000:0B07
```

`F000:0B07` is the instruction right after the displaced one — the start of
the unmodified original routine (`lcall F000:26B` / draw the three LOTERIA
lines / `retf`). There is no address to preserve and restore, since
nothing installs LOTERIA's offset anywhere;
the cave's obligation is instead: **once the player presses START, transfer
control to `F000:0B07`** (or replay the displaced clear-buffer call first, for
robustness against the caller-side redundancy ever going away, then jump to
`F000:0B07`) so the stock LOTERIA screen draws exactly as it does today. A
cave that wants a non-blocking, interrupt-friendly wait — matching this ROM's
own idiom rather than a tight poll loop — can install itself into
`[0000:0281]`/`[027F]`/`[027E]` the same way `F000:5065` does, since those
three bytes are confirmed idle at this point in the sequence: the very gate
that lets step 23 run at all (`E000:4F57`-`4F5F`) requires `[027E]==0`.

### Redraw

**Nothing clears the display buffer between ticks of the same handler.**
The only full-buffer clear in the ROM is `F000:DEFC`:

```
F000:DEFC  b80060      mov ax, 0x6000
F000:DEFF  8ec0        mov es, ax
F000:DF01  b9ff0f      mov cx, 0xfff          ; 4095 bytes = exactly both planes,
F000:DF04  32c0        xor al, al             ;   0x800 bytes/plane, stride 0x20, 32 rows
F000:DF06  bf1004      mov di, 0x410           ; the documented visible-area start
F000:DF09  9b          wait
F000:DF0A  aa          stosb byte ptr es:[di], al
F000:DF0B  e2fc        loop 0xdf09
F000:DF0D  cb          retf
```

`F000:DEFC` is called **once per screen transition**, by the setup code that
installs a new screen — `F000:5056`, `F000:0B02`, `F000:00BD`, `F000:0291`,
`E000:5090`/`5022`/`507C`/`50B7`/etc. — never by a recurring `[0281]` handler
on its own subsequent ticks. The per-tick handlers examined here (`F000:5092`,
`F000:0211`) draw or update only the specific bytes their own animation
touches and otherwise leave the buffer alone, which is why they persist
without redrawing the rest of the screen.

`F000:50FB` is **not** a general clear. It runs
once, inside `F000:5092`'s countdown-expired branch, and clears a `3×8`-byte
rectangle at buffer offset `0x710` — exactly the footprint of the single
countdown digit that handler itself draws, nothing more:

```
F000:50F5  bf1007      mov di, 0x710
F000:50F8  b90800       mov cx, 8            ; 8 rows
F000:50FB  51          push cx
F000:50FC  57          push di
F000:50FD  b90300       mov cx, 3            ; 3 bytes/row
F000:5100  9b          wait
F000:5101  26c60500    mov byte ptr es:[di], 0
F000:5105  47          inc di
F000:5106  e2f8         loop 0x5100
F000:5108  5f          pop di
F000:5109  83c720       add di, 0x20
F000:510C  59          pop cx
F000:510D  e2ec         loop 0x50fb
```

**`REDRAW_PER_TICK = false.`** A cave handler that draws its score screen once
and then only polls for START, re-installing itself with a short delay each
tick, is correct and matches this ROM's own idiom — nothing will overwrite
its pixels underneath it. (`F000:26B`, called by every static multi-line
screen right after `F000:DEFC`, is a second shared primitive worth noting: it
blits a fixed graphic into the second bit-plane at buffer offset `0xC10`,
apparently a border/frame common to these screens — mentioned for
completeness.)

## The game-state, credit and score variables

All of these live at physical `DS:0000` alongside the five dispatcher
variables above. The credit store lives in NVRAM, segment `0x1000`, physical
`0x10000 + off` (`eeprom_findings.md`).

| Address | Size | Meaning | Evidence |
|---|---|---|---|
| `[0000:0100]` | byte | **Credit count, cache only.** Not the authority — see the store below. | Written from exactly two places, `E000:147E` and `E000:14C8`, both immediately after reading the NVRAM triple |
| `[0000:0101]` / `[0102]` | byte | the cache's two display digits, tens and units | `E000:1452` splits `AL` by repeated `sub al,10 / inc bh` (`E000:1455`) and both writers store `BL`/`BH` into them |
| `[0000:0103]` | byte | **In-game flag.** `0xFF` = a game is running, `0x00` = not. | Set `0xFF` at `E000:0706`, cleared at `E000:09DC` (`xor al,al` at `09DA`). Read at 35 sites in the image, every one of them followed by `and al,al`; one `cmp byte [0103],0xFF` at `E000:1ACC` |
| `[0000:0105]` | byte | **Current player**, 1-based | Set to `1` at `E000:070D` (immediately after the flag above) and at `E000:0BF9`; `cmp al,[0106]` at `E000:08D5` is the "last player?" test; `E000:18D2`/`18F3` shift it left by one to index a stride table |
| `[0000:0106]` | byte | **Player count**, 1..4 | `E000:06C5`-`06CA` is the add-a-player path: `mov al,[0106] / inc al / mov [0106],al / cmp al,4`. Bounded by `cmp byte [0106],4` with `JB` at `E000:053A` and `06A1`, and used as the loop limit in the continue-offer loop (`E000:0B20`, `0B49`, `0BA0`) |
| `[0000:01C5]` | 31 bytes | **the live player block** — the playing player's own copy, swapped in and out of the four saved blocks at every handoff | `E000:18CD` and `E000:18EE`, below |
| `[0000:01C5]`+0 (low) +2 (high) | dword | a field of that block, compared as a 32-bit magnitude against the threshold dword `[0000:019D]`/`[019F]` | `E000:0222`-`0236` reads `+2` first and only falls through to `+0` on equality, so `+2` is the more significant word; compared the same way at `E000:0253` and `E000:0284`, and `E000:186C` adds `[0000:0190]` into `+2` |

### The credit store

Credits are a **triplicated byte at NVRAM `0x140`/`0x141`/`0x142`** (physical
`0x10140`-`0x10142`), three consecutive bytes rather than the scattered
offsets IO Moon uses.

`E000:1463` is the loader, and the **one place every credit value comes
from**:

```
E000:1463  b80010      mov ax, 0x1000
E000:1466  8ec0        mov es, ax
E000:1468  bb4001      mov bx, 0x140
E000:146B  268a07      mov al, es:[bx]
E000:146E  43          inc bx
E000:146F  263a07      cmp al, es:[bx]      ; all three bytes must be equal
E000:1472  751e        jne 0x1492           ;   any mismatch -> AL = 0
E000:1474  43          inc bx
E000:1475  263a07      cmp al, es:[bx]
E000:1478  7518        jne 0x1492
E000:147A  3c32        cmp al, 0x32         ; and the count must be under 50
E000:147C  7314        jae 0x1492
E000:147E  3ea20001    mov ds:[0x100], al   ; cache it
E000:1482  9a521400e0  lcall E000:1452      ; split into the two digits
```

The check is a three-way **equality**, not a majority vote: any disagreement
between the three bytes yields zero credits rather than the majority value.

`E000:14AA` is the decrementer — it returns without doing anything when the
count is already zero, decrements, writes the new value back to **all three**
bytes through a `CX = 3` loop, and then refreshes the cache and the digits the
same way:

```
E000:14AF  268a07      mov al, es:[bx]      ; BX = 0x140
E000:14B2  22c0        and al, al
E000:14B4  7501        jne 0x14b7
E000:14B6  c3          ret                  ; no credits: nothing to take
E000:14B7  fec8        dec al
E000:14BC  bb4001      mov bx, 0x140
E000:14BF  b90300      mov cx, 3
E000:14C2  268807      mov es:[bx], al      ; write all three
E000:14C5  43          inc bx
E000:14C6  e2fa        loop 0x14c2
E000:14C8  3ea20001    mov ds:[0x100], al
E000:14CC  9a521400e0  lcall E000:1452
```

So a free-play patch belongs at `E000:1463`, flooring `AL` to at least 1
before the cache write at `E000:147E` — the same shape as IO Moon's and Bike
Race's free-play patches, which both hook the single place the credit value is
read rather than the START handler's test. Patching `[0000:0100]` alone would
be wrong: the next call to either routine above overwrites it from the store.

### Per-player score storage

The playing player works in a single **live block at `[0000:01C5]`**, and each
player's block is saved and restored around it. `E000:190F` is the 5-entry word
table of block bases:

```
E000:190F   C5 01   E7 01   09 02   2B 02   4D 02
            0x1C5   0x1E7   0x209   0x22B   0x24D
            live    player1 player2 player3 player4
```

Stride `0x22`, indexed by the 1-based current player `[0000:0105]`, so entry 0
is the live block itself. `E000:18CD` copies **31 bytes** out of the live block
into the current player's slot and `E000:18EE` copies them back:

```
E000:18CD  be0f19      mov si, 0x190f         ; the table
E000:18D0  b400        mov ah, 0
E000:18D2  a00501      mov al, [0x105]        ; current player, 1-based
E000:18D5  d1e0        shl ax, 1
E000:18D7  03f0        add si, ax
E000:18D9  2e8b04      mov ax, cs:[si]        ; that player's block base
E000:18DC  8bf8        mov di, ax
E000:18DE  b80000      mov ax, 0
E000:18E1  8ec0        mov es, ax
E000:18E3  bec501      mov si, 0x1c5          ; the live block
E000:18E6  b91f00      mov cx, 0x1f           ; 31 bytes
E000:18E9  ac          lodsb
E000:18EA  aa          stosb
E000:18EB  e2fc        loop 0x18e9
E000:18ED  c3          ret
```

This is why the live block looks transient in a RAM diff: it is overwritten
from the saved block at every player change.

**The score itself is eight unpacked decimal digits at block offsets `+4` to
`+11`**, one digit per byte, with the **most significant digit at the highest
address** — there is no binary score to convert:

| Player | Block | LSD (`+4`) | MSD (`+11`) | Renderer | Panel-buffer row |
|---|---|---|---|---|---|
| 1 | `0x01E7` | `[0000:01EB]` | `[0000:01F2]` | `F000:4234`-`43BA` | `0xC13`-`0xC1A` |
| 2 | `0x0209` | `[0000:020D]` | `[0000:0214]` | `F000:43C5`-`454B` | `0xD13`-`0xD1A` |
| 3 | `0x022B` | `[0000:022F]` | `[0000:0236]` | `F000:4556`-`46DC` | `0xE13`-`0xE1A` |
| 4 | `0x024D` | `[0000:0251]` | `[0000:0258]` | `F000:46E7`-`486D` | `0xF13`-`0xF1A` |

So `block+11` is the `10^7` place and `block+4` the units.

Each renderer is **eight unrolled copies** of one block, one per digit, ending
in a single `pop si / retf`. Every copy has the same shape — this is player
2's most significant digit:

```
F000:43D0  a01402       mov al, [0x214]        ; this digit
F000:43D3  3e0806b502   or  ds:[0x2b5], al     ; leading-zero latch
F000:43D8  7422         je  0x43fc             ;   still all zeros: draw nothing
F000:43DA  3ec606b502ff mov ds:[0x2b5], 0xff   ;   first non-zero: latch on
F000:43E0  32e4         xor ah, ah
F000:43E2  ba0800       mov dx, 8
F000:43E5  f7e2         mul dx                 ; 8 bytes per glyph cell
F000:43E7  03f0         add si, ax             ; SI = the caller's font base
F000:43E9  bf130d       mov di, 0xd13          ; this digit's column
F000:43EC  b90800       mov cx, 8              ; 8 rows
F000:43EF  2e8a04       mov al, cs:[si]
F000:43F2  9b           wait
F000:43F3  268805       mov es:[di], al
F000:43F6  46           inc si
F000:43F7  83c720       add di, 0x20           ; next row, 32 bytes on
F000:43FA  e2f3         loop 0x43ef
F000:43FC  5e           pop si                 ; restore the font base and
F000:43FD  56           push si                ;   keep it for the next digit
```

`[0000:02B5]` is a shared **leading-zero latch**: each digit ORs itself into
it and draws nothing while it is still zero, so a score prints without leading
zeros and a score of 0 prints as nothing at all.

Each renderer is self-contained — a three-instruction prologue clears that
latch, loads the font base into `SI` and pushes it, and the eight blocks
follow:

```
F000:43C5  3ec606b50200 mov ds:[0x2b5], 0      ; player 2's entry point
F000:43CB  beeb85       mov si, 0x85eb         ; the 8-row face
F000:43CE  56           push si
```

All four use `0x85EB`, the 8-row face, whose 8-byte cells are what the
`mul dx` with `DX = 8` indexes. Five further digit renderers of the same
construction exist for other displays, at `F000:102A`, `11EC`, `13F3`,
`30BC` and `32CD`, between them using `0x85EB`, `0x8E43` and `0x90C3`.

A score screen therefore does not need to compose digits itself: the four
renderers already exist, take no arguments, and already place player N on
panel row `0xC13 + 0x100*(N-1)`.

### What the continue offer actually tests

This also identifies the four bytes the continue-offer cascade compares
against `1`. Each is its player's block `+0x0A`, the **second digit from the
left** and so the `10^6` place, which makes `cmp byte [0213],1 / JB` a score
threshold: offer the continue only to a player who has scored at least one
million. `E000:0AC9`'s `cmp byte [0173],0 / JNE ret` is the global
enable in front of all four.

## The sequence dispatcher and what gates it

`E000:4F4E` is the only code that reads `[0000:017D]`, and it has **exactly one
call site in the whole image**: the near `call` at `E000:00F6`, inside the
attract/credit-wait loop. Nothing in either interrupt handler reaches it.

```
E000:4F4E  3e833edf0400  cmp word ds:[0x4df], 0   ; a delay pending?
E000:4F54  7401          je 0x4f57
E000:4F56  c3            ret
E000:4F57  3e803e7e0200  cmp byte ds:[0x27e], 0   ; a [0281] handler armed?
E000:4F5D  7401          je 0x4f60
E000:4F5F  c3            ret
E000:4F60  3e803ec10200  cmp byte ds:[0x2c1], 0
E000:4F66  7401          je 0x4f69
E000:4F68  c3            ret
E000:4F69  be7c4f        mov si, 0x4f7c           ; the table base
E000:4F6C  3ea17d01      mov ax, ds:[0x17d]
E000:4F70  ba0200        mov dx, 2
E000:4F73  f7e2          mul dx
E000:4F75  03f0          add si, ax
E000:4F77  2e8b04        mov ax, cs:[si]
E000:4F7A  ffe0          jmp ax                   ; near, so a step ends in ret
```

There is **no bounds check**. The table runs to entry 25 at `E000:4FAE`, with code
beginning at `E000:4FB0` where entries 1 and 13 jump, and the advance tail wraps
at `0x18` — so incrementing never produces 25 and, of the six writes to `[017D]`
in the image, none produces it either. **Entry 25 is unreachable in stock
firmware**; it holds `0x5022`, a duplicate of entry 0.

`[0000:04DF]` is a **tick countdown**, not a dwell: the vector-8 timer handler
decrements it once per interrupt and saturates at zero,

```
F000:DFB1  a1df04    mov ax, [0x4df]
F000:DFB4  23c0      and ax, ax
F000:DFB6  7404      je 0xdfbc
F000:DFB8  48        dec ax
F000:DFB9  a3df04    mov [0x4df], ax
```

so a step writing `N` means "wait N ticks before the next step", and `0` means
"advance on the dispatcher's next call". Stock step 23 writes `0x64`.

### The sequence runs only when no credits are standing

The attract loop tests the credit count **twice**, with byte-identical code, and
leaves the loop on either test when a credit is standing:

```
E000:00D5  e88b13    call 0x1463    ; recompute [0x100] from the store
E000:00D8  a0 00 01  mov al, [0x100]      \ the loop's only entrance
E000:00DB  22 c0     and al, al           |
E000:00DD  74 03     je 0xe2              |
E000:00DF  e9 24 00  jmp 0x106            / credits standing: leave
E000:00E2  b070      mov al, 0x70
E000:00E9  e87713    call 0x1463
E000:00EC  a0 00 01  mov al, [0x100]      \ the same test again
E000:00EF  22 c0     and al, al           |
E000:00F1  74 03     je 0xf6              |
E000:00F3  e9 10 00  jmp 0x106            / credits standing: leave
E000:00F6  e8554e    call 0x4f4e          ; the dispatcher
```

`0x00E9` is reachable only from inside the loop (`0x00FF`, `0x0104`) or by
falling through `0x00E2`, so **every entrance to the loop passes `0x00D8`**. The
consequence is that the whole end-of-game screen sequence — `LOTERIA` included —
runs only while the credit count is zero. A machine with a credit standing goes
straight from game over to the next game.

### The player count does not survive the game-end sequence

`[0000:0106]` is zeroed **twice** inside the sequence that reaches the screen
steps, at `E000:09FA` and `E000:0A06`, and again at `E000:00B8` on the attract
re-entry. `E000:1919` — which selects the screen step — is called from
`E000:09C9`, well before those writes, and the dispatcher cannot run until the
whole sequence returns at `E000:0A1D`. So the number of players in the finished
game is **not readable** from `[0106]` by anything the sequence dispatches; it
has to be captured earlier.

The scores themselves do survive: `E000:08CA` calls the block save at `E000:18CD`
unconditionally before the ball and player advance, and the game-end tail clears
only `0x1D8`-`0x1E6`, which is the live block, not the four saved ones.

## Boot initialisation of segment 0

Boot writes only `0x0000`-`0x00FE` of segment 0, and that block is the
**interrupt vector table**, copied byte by byte from a ROM table at `F000:FEF0`:

```
F000:FE98  bef0fe    mov si, 0xfef0
F000:FE9B  b9ff00    mov cx, 0xff
F000:FE9F  bf0000    mov di, 0
F000:FEA2  2eac      lodsb cs:[si]
F000:FEA4  aa        stosb es:[di]
F000:FEA5  e2fb      loop 0xfea2
F000:FEA7  ea000000e0 ljmp E000:0000
```

Every entry is `F000:FFF0`, the reset vector, except vector 2 at `F000:DF20` and
vector 8 at `F000:DF7F`. Nothing above `0x00FE` is initialised at power-on, so a
work-RAM byte in that region holds whatever the RAM came up with until the
firmware writes it.
