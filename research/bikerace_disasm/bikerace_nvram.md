# Bike Race — NVRAM validation & factory-reset flow (why the driver embeds a factory image)

Source: full `ndisasm -b 16` of `bkcpu04.bin` (80188 game/sound code, linear
`0xE0000-0xFFFFF`). Analysis date 2026-06-18. Cross-checked against the live
PinMAME `SLEIC3` driver and the 2026-06-07 coin-crash regression.

## TL;DR — it is NOT a wrong judgement call

`pinmame/src/wpc/sleic.c` embeds a complete ~875-byte factory NVRAM image for Bike
Race (`sleic3_nvram_init[]`) and seeds it on a fresh boot, whereas Sleic Pin-Ball
(`SLEIC1`) needs **no** embedded image. That asymmetry is **correct** and reflects a
real difference in the two firmwares:

| | **Sleic Pin-Ball (SLEIC1)** | **Bike Race (SLEIC3)** |
|---|---|---|
| Blank-NVRAM repair | **automatic + silent at boot** | **operator-gated** ("PULSE START") |
| Writes the *complete* image? | yes, in one routine (`F000:818D`) | only **after** the operator presses START |
| Embedded image needed? | **no** — firmware self-heals | **yes** — to skip the operator-START gate |

So Bike Race cannot use Sleic Pin-Ball's "let the firmware self-heal a blank NVRAM"
approach: on a blank NVRAM Bike Race **blocks on a `ESTABLECIENDO VALORES DE FABRICA /
PULSE START` screen and waits for a human to press START** before it writes the
gameplay tables. The embedded image gives the firmware an already-valid NVRAM so
`config_validate` passes and it boots straight to attract — i.e. it represents *a
machine that has been factory-reset once*, which is the correct out-of-box state.

(For the Sleic Pin-Ball side, see `../sleicpin_disasm/eeprom_findings.md`: boot
`E000:001C` validates `F000:80F5`; on fail `E000:0029` **unconditionally** calls the
auto-repair `F000:818D`, which clears `0x000-0xFFF` and writes the full config, then
re-validates and continues — no operator interaction.)

## Bike Race NVRAM control flow

NVRAM is the 28C64A at segment `0x1040` (linear `0x10400-0x123FF`), mapped in the
driver as `sleic3_nvram_r/w`.

### config_validate — `E05F7`
Compares **8 template blocks** of NVRAM against ROM reference blocks (`CS=E000`); any
single byte mismatch returns `ax=0` (invalid), else `ax=1` (valid):

| NVRAM off | len   | ROM ref (CS:E000) |
|-----------|-------|-------------------|
| `0x000`   | `0x0F`| `0x7BC` |
| `0x047`   | `0x33`| `0x7CB` |
| `0x0C9`   | `0x20`| `0x7FE` |
| `0x162`   | `0x35`| `0x81E` |
| `0x1EC`   | `0x1A`| `0x853` |
| `0x23C`   | `0x20`| `0x7FE` |
| `0x2ED`   | `0x35`| `0x81E` |
| `0x351`   | `0x1A`| `0x853` |

### config_load_defaults — `E06FB`
Copies the **same 8 template blocks** from ROM into NVRAM. **It does NOT write the
coin/credit pulse table, the high-score table, or the audit blocks** — those are seeded
separately (see the full-seed step below).

### Reset / validate routine — `E97DB` (called as `E50E:46FB`)
Reached at boot from the main loop at **`E520C`** (and re-entered from the service-menu
BORRADO paths `E53A6` / `F5058` / `F7049`). Flow:

```
E97DB  validate config (E05F7)
E97E6  or ax,ax
E97E8  jz  0x97ed            ; INVALID -> repair path
E97EA  jmp 0x9aeb            ; VALID   -> skip reset entirely, continue to attract
; --- repair path (NVRAM invalid / blank) ---
E97ED  call 0x9425           ; show "ESTABLECIENDO VALORES FABRICA / PULSE START"
                             ;   and BLOCK until the operator presses START (see E9425)
E97F1  call config_load_defaults (E06FB)   ; writes the 8 template blocks
E97F6  call config_validate  (E05F7)       ; re-validate
E97FB  or ax,ax
E97FD  jnz 0x9805            ; now valid -> FULL seed
E97FF  call E93E0 ; jmp $    ; still invalid -> error + HALT
; --- E9805: FULL factory seed (only runs AFTER the operator START) ---
E9805  call E08DC
E980A  call E0569
E9814  call E0584
E9826  call E054A  ; copies the coin/credit + audit blocks (e.g. CS:8700 -> NVRAM 0x85/0x96/0xA7)
...    high-score table copies into NVRAM [0x89], [0xAB]; audit via E9C7:2C11
```

### The operator-START gate — `E9425` / `E9497`
`E9425` prints the `ESTABLECIENDO VALORES DE FABRICA` / `PULSE START` strings
(`F000:3DC1/3DCF/3DDF`) and then **busy-waits** for the START button:

```
E9478  call E50E:43b7        ; = E9497, poll the J1 inbound event queue
E947D  or al,al
E947F  jz  0x9478            ; loop forever until START arrives
E9481  push 0x36 ; call ...  ; START (event 0x36) received -> proceed
```

`E9497` reads the J1/NMI event queue (`seg 0x10:[0x11]` flag, `[0x1a]` pointer) and
returns `al=1` **only when the dequeued event code == `0x36` (START)**, else `al=0`.
This is the same J1 event path the Z80 fills on a real cabinet START press.

## Why a partial seed does NOT work (the 2026-06-07 regression)

Seeding **only** `config_validate`'s 8 template blocks (to make validate pass without
embedding the whole image) is broken, and the disassembly explains exactly why:

* If validate **passes**, `E97EA jmp 0x9aeb` **skips the entire reset routine** — so the
  full seed at `E9805` (which writes the coin/credit table `0x230-0x23B`, high scores,
  audit) **never runs**.
* That leaves the coin/credit pulse table at **zero**. The coin handler then computes a
  far-jump from the zeroed table and the 80188 derails into NVRAM
  (observed live: attract `F08xx` -> coin code `0x37` -> `1138D` -> `1AA39` -> stuck
  `008E1`; `0x1138D` = NVRAM seg `0x1040:0xF8D`). The Z80 stayed alive (flippers
  worked) — only the 80188 firmware crashed.

So the only two states that boot cleanly are:
1. **Complete factory image** (current approach) -> validate passes -> straight to attract. ✓
2. **Blank NVRAM + operator START** -> firmware runs its own full seed (`E9805`). ✓ (but
   requires a human / injected START, and produces the *identical* NVRAM as #1).

The complete embedded image is #1 captured once from the firmware's own #2 (verified
byte-exact, 0 diffs of 8192). See [`bikerace-boots-oracle`] memory note for the capture
method.

## Empirical confirmation (2026-06-18)

* **Sleic Pin-Ball** self-heals: its persisted `sleicpin.nv` contains the
  firmware-written config blocks (`0x600-0x870`) and the `Memoria EEPROM en mal estado`
  error never appears — silent boot-time repair, no operator action.
* **Bike Race** does **not** self-heal: booting headless with an all-zero NVRAM for
  10000 frames left the NVRAM **still all-zero** — the firmware never wrote defaults on
  its own. (The `PULSE START` screen itself is not reachable in a headless run because
  Bike Race's attract never advances to the NVRAM-gated stage without the full
  J1/display environment; that step rests on the disassembly trace above, which is
  conclusive. Headless Bike Race runs the same early attract loop regardless of NVRAM
  content.)

## Could we drop the embedded image anyway?

Two alternatives, both inferior:

* **(A) Auto-inject START on a fresh boot** — detect a blank `.nv` and feed a synthetic
  `0x36` (START) event so the firmware runs its own `E9805` seed. This is exactly how
  the embedded image was originally captured. It removes the embedded bytes but is
  fragile (depends on first-boot J1/NMI/timing reaching `E9478`, delivering START once,
  and finishing the seed before any read) and yields a byte-identical NVRAM. Net: more
  risk, same result.
* **(B) Partial seed** — proven broken (above).

**Recommendation: keep the embedded factory image for Bike Race.** It is the correct,
deterministic, byte-exact way to represent an already-factory-reset machine, and it is
the only robust option that does not depend on first-boot input/timing.

## Address reference
- config_validate: `E05F7`
- config_load_defaults: `E06FB`
- reset/validate routine: `E97DB` (entry `E50E:46FB`; boot caller `E520C`)
- FABRICA prompt + START wait: `E9425` (poll `E9497`, START event `0x36`)
- full factory seed: `E9805` (`E08DC`/`E0569`/`E0584`/`E054A` + high-score/audit)
- error + halt: `E93E0` / `E9803 jmp $`
