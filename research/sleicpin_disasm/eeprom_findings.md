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

## Why Sleic Pin-Ball needs NO embedded NVRAM image, but Bike Race DOES (2026-06-18)

This is the answer to "was embedding a factory image for Bike Race a wrong call?"
— **No.** The two firmwares repair a blank NVRAM differently:

- **Sleic Pin-Ball (this title):** the boot **auto-repairs silently**. `E000:0029`
  unconditionally calls `F000:818D`, which writes the **complete** factory image
  (clears `0x000-0xFFF`, writes every config block), re-validates, and continues —
  **no operator interaction**. A blank NVRAM becomes a complete valid one before the
  game even reaches attract, so no embedded C array is needed.
- **Bike Race (`SLEIC3`):** the boot does **not** silently self-heal. Its reset
  routine (`E97DB`, reached at `E520C`) shows `ESTABLECIENDO VALORES DE FABRICA /
  PULSE START` and **blocks until the operator presses START** (event `0x36`) before
  it writes the coin/credit + high-score + audit tables. Seeding only the validate
  blocks makes validate pass, which **skips** that full seed → zeroed coin table →
  the 80188 derails on the first coin (the 2026-06-07 regression). So Bike Race needs
  the complete embedded image (or a fragile auto-START injection that yields the
  identical result).

Full Bike Race analysis with addresses: `../bikerace_disasm/bikerace_nvram.md`.

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

## VERIFICATION RESULT (2026-06-14)

**EEPROM gate: FIXED and verified headless.**
- Fix shipped in `pinmame/src/wpc/sleic.c`: SLEIC1 gets its own 80188 map with
  NVRAM (seg 0x1000) mapped read==write to a single 8 KB buffer
  (`0x10000-0x11FFF`), persisted by `NVRAM_HANDLER(SLEIC1)`, wired via
  `MDRV_CPU_REPLACE` (SLEIC2/iomoon keep the base map). No embedded image.
- Baseline (broken driver): the error renders on the DMD (captured via the new
  `SLEIC_DMD_DUMP` hook) — "ATENCION / MEMORIA EEPROM / EN MAL ESTADO /
  IMPOSIBLE SEGUIR", steady (1456/1468 frames non-blank).
- Fixed driver, true fresh boot (`.nv` wiped): the firmware **self-heals** —
  `~/.xpinmame/nvram/sleicpin.nv` offset `0x100` = `(C) SLEIC 1.993` (written by
  the firmware's own factory-init `F000:818D`); the error **never appears**
  (0/8386 frames over ~33 s). Boot is past the gate.

**Next blocker (separate from EEPROM): post-gate timer-delay loop.**
After the gate the boot runs a delay loop:
```
E000:0050  mov word [ds:0x4DF],0x12C   ; counter = 300
E000:0057  cmp word [ds:0x4DF],0x0
E000:005D  jnz  0x57                    ; spin until a timer ISR decrements to 0
```
The DMD stays blank because the firmware spins here — `[0x4DF]` is decremented by
a 80188 timer interrupt that the `sleicpin` **stub** driver does not deliver
correctly (`SLEIC_irq_i80188` is a placeholder 120 Hz pulse on IRQ0 with no real
timer/IVT model). Reaching attract therefore requires completing the SLEIC1
80188 IRQ/timer model — **not** an NVRAM problem. The embed-factory-image
fallback is **not needed** for the EEPROM goal.

## SECOND BLOCKER ANALYSIS & FIX (2026-06-14) — Timer0 interrupt

**Root cause (confirmed via disassembly).** The reset code programs the 80C188
peripheral control block from a table at `F000:FEAC` (17 `out dx,ax` pairs):

| Reg | I/O | Value | Meaning |
|---|---|---|---|
| T0CON  | `0xFF56` | `0xE003` | Timer0 **enabled + interrupt-enabled**, continuous, CPU/4 |
| T0CMPA | `0xFF52` | `0x4000` | compare 16384 -> 2 MHz/16384 = **~122 Hz** |
| T0CMPB | `0xFF54` | `0x4000` | (alternate, same period) |
| TCUCON | `0xFF32` | `0x0003` | timer interrupt **unmasked** (prio 3) |
| I0-3 / DMA0-1 | `0xFF34-3E` | `0x000F` | all **masked** |

So the firmware relies **solely on the internal Timer0 interrupt**. The reset code
then copies an IVT from `F000:FEF0` to physical 0 (255 bytes). Decoded vectors:
- type 2 (NMI)    -> `F000:DF20`
- type 8 (Timer0) -> `F000:DF7F`  (all others -> `F000:FFF0` default trap)

The **Timer0 ISR `F000:DF7F`** sets `DS=0` and decrements the delay counters:
```
mov ax,[0x4DF]; and ax,ax; jz; dec ax; mov [0x4DF],ax   ; <- the loop's counter
; also [0x4E3] (reload 4), [0x4E1], [0x16E] (reload 9)
mov dx,0xFF2C; in ax,dx; and ax,0xFE; out dx,ax          ; interrupt ack
iret
```
The post-boot delay loops (`mov [0x4DF],N; spin until 0`, at E000:0050, 0x0A3E,
0x0C22, …) therefore advance only when the Timer0 ISR runs.

**Emulator gap.** The PinMAME i188 core does not emulate the 80186 internal
timers (`i86time.c` = CPU cycle timing only). The base `SLEIC_irq_i80188`
pulsed IRQ0 with **no vector** (`cpu_set_irq_line(...,0,PULSE_LINE)`), so the core
could not deliver vector type 8 -> the timer ISR never ran -> every delay loop
hung -> blank DMD. The working Bike Race path injects the vector explicitly
(`cpu_set_irq_line_and_vector(...,HOLD_LINE,0x08)`).

**Fix (shipped).** SLEIC1-specific `sleic1_irq_gen` injects Timer0 vector `0x08`
at 122 Hz, wired via `MDRV_CPU_PERIODIC_INT` in `MACHINE_DRIVER_START(SLEIC1)`
(SLEIC2/iomoon untouched). **Result: sleicpin now runs its full attract**
(logo + animation) — verified headless (`SLEIC_DMD_DUMP`): 0 -> 2841 non-blank
frames, first content at frame ~615 once the delay loops expire. Bike Race
attract reverified (no regression).

**Still open (not pursued here):** switch input / service menu likely need the
J1-byte-arrival **NMI** (vector 2 -> `F000:DF20`) strobe-driven from the Z80 side
(as SLEIC3 does), plus the peripheral/sound wiring — the next layer beyond attract.
