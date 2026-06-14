# Sleic Pin-Ball — EEPROM validation analysis & reconstruction recipe

Source: full `ndisasm -b 16` of `sp03-1_1.rom` (80188 game code, maps to
`0xE0000-0xFFFFF`; **F000:xxxx = file offset `0x10000+xxxx`**, E000:xxxx = file
offset `xxxx`). Analysis date 2026-06-14.

## TL;DR

The "Memoria EEPROM en mal estado / Imposible Seguir" halt is **not** a missing
factory image and **not** a stored jump vector. It is caused by the emulator's
NVRAM being **write-only**: the driver maps NVRAM reads to `read_0` (returns 0)
while writes go to a separate `generic_nvram` buffer. The firmware *already
self-repairs* a blank NVRAM at boot — but it then reads the region back to
verify, gets zeros, and halts. **Fix = make the NVRAM region read/write
consistent (and persisted); the firmware seeds itself.**

## Boot/validation control flow (E000:0000 →)

```
E000:001C  call F000:80F5      ; VALIDATE NVRAM
E000:0021  mov  al,[ds:0x4D0]  ; result flag (DS=0): 0xFF = valid, 0x00 = invalid
E000:0025  and  al,al
E000:0027  jnz  0x4A           ; valid -> continue normal boot
E000:0029  call F000:818D      ; INVALID -> AUTO-REPAIR (writes factory defaults to NVRAM)
E000:002E  call F000:80F5      ; re-VALIDATE
E000:0033  mov  al,[ds:0x4D0]
E000:0037  and  al,al
E000:0039  jz   0x43           ; STILL invalid -> error
E000:003B  call F000:82BC      ; now valid -> finish + jmp 0x4A (continue)
E000:0043  call F000:49E8      ; ERROR: display "EEPROM en mal estado"
E000:0048  jmp  0x48           ; HALT (Imposible Seguir)
```

## VALIDATE routine — `F000:80F5` (file 0x180F5)

A signature-string compare. With `ES=0x1000`, it compares NVRAM against ROM
reference strings; **any** byte mismatch sets the fail flag:

```
mov ax,0x1000 / mov es,ax
; per block: mov bx,<nv_off> / mov si,<rom_off> / mov cx,<len>
;   loop: mov al,[es:bx] ; mov ah,[cs:si] ; cmp al,ah ; jnz FAIL ; inc bx ; inc si ; loop
FAIL (0x18187):  mov al,0x00 / mov [0x4D0],al / retf   ; 0x00 = INVALID
OK   (0x18181):  mov al,0xFF / mov [0x4D0],al / retf   ; 0xFF = VALID
```

Blocks checked (NVRAM is segment `0x1000`, so physical = `0x10000 + off`):

| NVRAM off | phys      | ROM ref (CS=F000) | len  | content |
|-----------|-----------|-------------------|------|---------|
| `0x100`   | `0x10100` | `0x820B`          | 0x0F | `(C) SLEIC 1.993` |
| `0x200`   | `0x10200` | `0x821A`          | 0x33 | `(C) CREACIONES E INVESTIGACIONES ELECTRONICAS, S.L.` |
| `0x300`   | `0x10300` | `0x824D`          | 0x20 | `(C) LUIS GOSALBEZ CARRASCO 1.993` |
| `0x500`   | `0x10500` | `0x826D`          | 0x35 | `AV.VALDELAPARRA, 3. POLIGONO INDUSTRIAL DE ALCOBENDAS` |
| `0x700`   | `0x10700` | `0x82A2`          | 0x1A | `28100 MADRID. TEL: 6619796` |

The ROM reference block lives at file `0x1820B-0x182BA`.

## AUTO-REPAIR / factory-init — `F000:818D` (file 0x1818D)

Writes the factory defaults into NVRAM (`ES=0x1000`). It:
- copies the 5 signature strings above to `0x100/0x200/0x300/0x500/0x700`;
- writes a config block (`CS:0x8048` → `0x600`, len 0x2D) and other blocks at
  `0x800/0x820/0x840/0x860` (len 0x20 each), `0x19B` (len 0x26);
- **clears `0x000-0xFFF`** (`mov di,0; mov cx,0xFFF`) — so the config/NVRAM area
  is **≥ 4 KB** in segment `0x1000`;
- calls sub-init routines (e.g. `F000:DE5E` ×6).

Because the boot calls this on a blank NVRAM, **the firmware seeds its own valid
image** — no embedded C array is strictly required, provided the writes are
read-backable.

## ERROR display — `F000:49E8` (file 0x149E8)

Prints 4 glyph-encoded lines (`CS:0x4A12/0x4A2C/0x4A4A/0x4A68`, DMD rows
`0x410/0x510/0x610/0x710`) via print routine `F000:550D`. The text is **font
glyph indices, not ASCII** — which is why `strings` finds no "EEPROM" anywhere
in any ROM.

## Jump-address recollection — VERDICT: REFUTED (for Sleic Pin-Ball)

The gate is a byte-for-byte signature **string compare**, not a pointer the
firmware jumps through. A search of the full sp03 disassembly for indirect
`jmp [...]` / `call [...]` returns **zero** matches. There is no NVRAM-resident
"address to jump to" in this title's EEPROM path. (The Bike Race recollection may
refer to a different mechanism or be imprecise; it does not apply here.)

## Emulator root cause (current `sleic.c`)

```
READ : {0x10100,0x10900, read_0 /* MRA_RAM */}                  // returns 0
WRITE: {0x10100,0x10900, MWA_RAM, &generic_nvram, ...}          // writes elsewhere
```
Read and write target different things, and the read returns 0. The firmware's
auto-repair writes correct defaults to `generic_nvram`, but re-validation reads
via `read_0` → 0 → mismatch → halt. Also the mapped window (`0x10100-0x10900`,
2 KB, starting at `0x100`) is **narrower** than the firmware's ≥4 KB config area
starting at offset `0x000`.

## Reconstruction recipe (revised — simpler than the original plan)

**Primary fix (try first):** give SLEIC1 a single coherent, persisted NVRAM
region in segment `0x1000`:
- Map **reads and writes to the same buffer**, covering at least
  `0x10000-0x10FFF` (recommend the full 28C64A-class window `0x10000-0x11FFF`,
  8 KB, to be safe).
- Use a real `NVRAM_HANDLER(SLEIC1)` (persist to `.nv`), isolated from
  SLEIC2/iomoon (own memory map + `MDRV_CPU_REPLACE`).
- **No embedded factory image needed** — on first boot the firmware's
  `F000:818D` auto-repair populates a valid image, re-validation passes, boot
  continues. The `.nv` then persists it.

**Fallback (if auto-repair leaves gameplay tables incomplete — the Bike Race
"coins add no credits" caveat):** capture the firmware-written `.nv` after first
boot and embed its non-zero head as `sleic1_nvram_init[]` so a fresh boot starts
from a complete config (the original hybrid approach).

## Impact on the implementation plan
- Tasks 1-3 (disassembly + analysis): **done.**
- Task 6 simplifies to "coherent + persisted NVRAM region" (the read/write-split
  bug fix) rather than crafting a minimal signature seed.
- Tasks 7-8 (runtime capture + embed) become a **fallback**, exercised only if
  Task 9 verification shows the self-healed config is functionally incomplete.
