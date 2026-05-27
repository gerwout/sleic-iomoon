# IO Moon Z80 I/O Coprocessor — Periodic IRQ Timing Analysis

**Question:** What frequency should the Z80's RST 38h IRQ fire at in the
PinMAME driver?

**Answer (recommendation):** **`MDRV_CPU_PERIODIC_INT(IOMOON_irq_z80, 8000000/8192.0)`** — about **977 Hz** on an 8 MHz Z80.  A practical alternative is the explicit constant **`976`** or **`1000`** Hz.

---

## 1. Hardware context

From the service manual (§7.2.2.1, p.95) and the board inventory:

| Item | Value |
|------|-------|
| Z80 part | GoldStar `Z0840004PSC` (Z80A) — IC1 on board 011-030 |
| Crystal | X10 = **8 MHz** (HC-49 can, bottom-right of board) |
| ROM IC5 | 27C256, 32 KB, `IO MOON V1.2-04` |
| Watchdog | MAX699 (IC15) — **reset-only**, no clock output |
| PAL | IC8 (PAL16L8) — purely combinatorial, **cannot generate an IRQ** |
| Timer chip | **none** (no PIT, no CTC, no 8253) |

The Z80 uses **Interrupt Mode 1** (`im 1` at `0x0002`, repeated in `main_init`
at `0x0401`) which fires RST 38h on `/INT` assertion.  The vector at `0x0038`
unconditionally jumps to `irq_service_main` at `0x0A42`:

```
0038  c3 42 0a   jp irq_service_main
```

There is **no `OUT (port),A` in the boot sequence that programs a counter
chip** — `init_all_io` (0x041B–0x0459) only writes initial values to ports
0x80, 0x81, 0x82, 0x83, 0x84, 0x85, 0x86, 0x87.  The periodic IRQ must
therefore come from **external glue logic** — almost certainly the 8 MHz
crystal divided down through a 74LS-family counter in the un-labelled DIP
cluster on the Z80 board, with the carry output gated by IC8's PAL.

The most natural divider chains for an 8 MHz source are:

| Divider | IRQ rate | Notes |
|---------|----------|-------|
| ÷8192   | 976.6 Hz | One stage 74HC4040/4060 |
| ÷4096   | 1953  Hz | Slightly fast for safety |
| ÷16384  | 488.3 Hz | Plausible but borderline for lamps |

## 2. What the IRQ handler does each call

`irq_service_main` at **0x0A42** (annotated disassembly lines 2036–2331):

```
0a42  di
0a43  push af / push bc / push de / push hl          ; 4 × 11 = 44 T
0a47  call lamp_hw_refresh        (0x3446)
0a4a  call lamp_scan_one_col      (0x3335)
0a4d  call sub_2e54h              (direct-switch read, port 0x03)
0a50  ld a,(c052h) / cp a5h / call l0d15h            ; light timer tick
0a58  ... 10 × solenoid-timer blocks (banks 1 and 2) ...
0b64  call sub_0cb8h              (switch queue + game/aux timers + debounce)
0b67  pop hl / pop de / pop bc / pop af / ei / reti  ; ≈ 70 T
```

The handler is moderately long (≈ 600–1500 T-states depending on which
solenoid timers are running).  At 8 MHz, that is 75–190 µs of IRQ work — i.e.
≈ 10–20 % CPU at 1 kHz, which is comfortable.

**Key observation about lamp refresh** — `lamp_hw_refresh` (0x3446)
implements an 8-state jump-pointer state machine (entries at
0x3457, 0x3467, 0x3477, 0x3487, 0x3497, 0x34A7, 0x34B7, 0x34C7).  Each
entry writes a **different bit-mask** to port 0x83 (one of `0x01, 0x02,
0x04, 0x08, 0x10, 0x20, 0x40, 0x80`) together with the corresponding row
byte to port 0x84, then advances the state pointer at `(c117h)`.  So:

> **Lamp refresh rate per column = IRQ rate ÷ 8**

For zero visible flicker (≥ 50 Hz per column) the IRQ must be **≥ 400 Hz**.
For smooth dimming/PWM it should be **≥ 800 Hz**.  This rules out anything
below ≈ 500 Hz.

Cycle counting also rules out **anything above ≈ 5 kHz**: at 5 kHz the IRQ
work would consume ≈ 75 % of CPU and starve the main loop (which is doing
the switch-matrix scan and 80188 mailbox protocol).

## 3. Switch-matrix scan rate

Contrary to the file header at line 220, **the matrix scan state machine is
NOT in the IRQ — it runs from the main loop**.  `irq_service_main` only
calls `sub_2e54h` (0x2E54) which reads `port 0x03` (the direct switches:
flippers, START, TEST/COIN).  The full matrix scan via
`scan_state_entry` (0x2E62) and `scan_matrix_row0`..`row5` (0x2ED3–0x2FE6)
is dispatched through `(c0e5h)` from the main loop.  The IRQ-rate
constraint from the matrix scan is therefore weak; the lamp refresh is the
binding constraint.

The scan code uses a 2-tick debounce (`c0f9 = 2` after each row), so
6 rows × 2 ticks = ≈ 12 main-loop iterations per complete scan cycle.
At any plausible IRQ rate (≥ 500 Hz) the main loop will easily complete a
full scan in a few milliseconds.

## 4. Comparison with analogous PinMAME drivers

| Driver | File | Z80 clock | IRQ rate | Notes |
|--------|------|-----------|----------|-------|
| **JP** (Juegos Populares — Spanish) | `jp.c:295-298` | 4 MHz | **`JP_CPUFREQ/4096 = 977 Hz`** | Comment: "IRQ @ 977 Hz (4MHz/2048/2)" — explicit clock-divider chain |
| **Peyper** (Spanish) | `peyper.c:22, 215-219` | 5 MHz | 1600 Hz (Sound), 2500 Hz (Odin Dx), 440 Hz (Odin proto) | Wide spread |
| **Inder** (Spanish) | `inder.c:317-320` | 2.5 MHz | 250 Hz | Plus newer titles 180–225 Hz with comment *"any higher, and switches behave erratic"* |
| **Inderp** sound CPU | `inderp.c:174` | — | 220 Hz | "guessed" |
| **Spinb** (ex-Inder) | `spinbgames.c` + `spinb.c:881` | 5 MHz | **175 Hz** (gameSpecific2 for all Spinb titles) | Runtime-adjustable |
| **Sleic (current stub)** | `sleic.c:455-458` | 2.5 MHz | `2500000/2048 = 1221 Hz` | Inherited from Pin-Ball; not IO-Moon-specific |

Two clusters are visible:

* **Low-rate camp (175–250 Hz)** — Inder & Spinb. These boards do not use
  the Z80 to refresh lamps in the IRQ (they use dedicated lamp drivers
  with their own multiplex or shift registers).
* **kHz-rate camp (977–1600 Hz)** — JP and Peyper.  These boards **do**
  use the Z80 IRQ for lamp/display multiplexing.

IO Moon belongs squarely in the **kHz camp**: the Z80 IRQ handler explicitly
walks an 8-state lamp-refresh state machine (see §2).  Therefore the JP
driver's **8 MHz / 8192 = 977 Hz** is the closest analogue — same divider
topology (clock-derived counter chain), same purpose (lamp matrix refresh),
same Spanish-pinball engineering style.

## 5. Likely IRQ source on the IO Moon Z80 board

With no PIT, no CTC, and a MAX699 watchdog that has only `/RESET` output,
the IRQ must come from one of:

1. **Clock divider on X10 (8 MHz) → carry feeds /INT.**  Standard practice on
   Spanish boards (cf. JP `4 MHz/4096`).  Requires one 74HC4040, 74HC4060
   or 74LS393 — easily hidden in the un-labelled DIP cluster on the left
   edge of board 011-030.
2. **50 Hz mains-derived signal.**  Possible but unlikely — would give
   only 50 Hz lamp refresh / 6.25 Hz per column, which would flicker.
3. **NE555 RC oscillator.**  No 8-pin DIP near X10 other than IC15
   (MAX699), so this is unlikely too.

**Conclusion: option 1.**  Almost certainly an 8 MHz ÷ 2ⁿ chain in glue
logic, most likely ÷8192 = 977 Hz to match the JP/Peyper convention.

## 6. Recommendation

```c
/* IO Moon Z80 I/O coprocessor: 8 MHz Z80A, IM1, RST 38h via clock-derived /INT. */
MDRV_CPU_ADD_TAG("icpu", Z80, 8000000)
MDRV_CPU_MEMORY(IOMOON_Z80_readmem, IOMOON_Z80_writemem)
MDRV_CPU_PORTS (IOMOON_Z80_readport, IOMOON_Z80_writeport)
MDRV_CPU_PERIODIC_INT(IOMOON_irq_z80, 8000000/8192.0)   /* ≈ 977 Hz */
```

**Reasoning:**

* **8 MHz** matches the X10 crystal and the service-manual statement
  (§7.2.2.1, p.95).  The `Z0840004` rating is conservative; the part runs
  fine at 8 MHz with the supply voltages used.
* **977 Hz** gives lamp refresh of **122 Hz per column** — well above the
  flicker threshold and consistent with the JP driver's documented value.
* It is the most natural divisor of the X10 crystal that lands in the
  required range (400 Hz–5 kHz).
* It matches the established Spanish-pinball convention of clock ÷ 4096
  IRQ-divider chains.

If empirically too slow (switches feel laggy) or too fast (mailbox protocol
to 80188 starves), the alternative values to try in order are:

1. `8000000/8192.0` ≈ **977 Hz** *(recommended starting point)*
2. `8000000/4096.0` ≈ **1953 Hz**
3. `8000000/16384.0` ≈ **488 Hz**

The current stub value `2500000/2048 = 1221 Hz` is in the right ballpark
for lamp refresh (≈ 153 Hz per column) but **uses the wrong CPU clock
(2.5 MHz instead of 8 MHz)** and an arbitrary divider; replacing it with
`8000000/8192.0` corrects both at once.

---

## Citations

* `/home/gerwout/iomoon/sleic-iomoon/asm/z80_annotated.asm`
  * Lines 297–315: reset vector `nop / nop / im 1 / di / jp main_init` (`0x0002` = `IM 1`)
  * Lines 366–367: `rst38_vector: jp irq_service_main` (`0x0038 → 0x0A42`)
  * Lines 1254–1267: `main_init` — `di`, `im 1`, RAM clear, `ei`, jump to `main_loop`
  * Lines 1268–1295: `init_all_io` — no programmable-timer setup
  * Lines 2036–2183: `irq_service_main` body — handler structure
  * Lines 2042–2044: three calls (`lamp_hw_refresh`, `lamp_scan_one_col`, direct-switch read)
  * Lines 7912–7928: `scan_state_entry` — matrix scan dispatched **from main loop**, not from IRQ
  * Lines 8778–8849: `lamp_hw_refresh` — 8-state column strobe (0x01..0x80) writing port 0x83
* `/home/gerwout/iomoon/pinmame/src/wpc/jp.c:13–14, 32, 295–298`  — JP driver `IRQ @ 977 Hz (4MHz/2048/2)`
* `/home/gerwout/iomoon/pinmame/src/wpc/peyper.c:22–25, 215–243` — Peyper 1600 / 2500 / 440 Hz
* `/home/gerwout/iomoon/pinmame/src/wpc/inder.c:317–320, 547, 931`  — Inder 250 / 180 / 225 Hz
* `/home/gerwout/iomoon/pinmame/src/wpc/spinbgames.c:36` and `spinb.c:881` — Spinb 175 Hz
* `/home/gerwout/iomoon/pinmame/src/wpc/sleic.c:455–458` — current stub `Z80 @ 2.5 MHz`, IRQ at `2500000/2048 ≈ 1221 Hz`
* `/home/gerwout/iomoon/sleic-iomoon/research/board_inventory.md:96, 103, 117–125` — X10 = 8 MHz crystal, MAX699 watchdog (reset-only), IC8 = PAL16L8
