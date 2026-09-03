# IO Moon Z80 I/O Coprocessor — Periodic IRQ Timing Analysis

**Question:** What frequency should the Z80's RST 38h IRQ fire at in the
PinMAME driver?

**Answer:** **`8000000/8192`** — about **977 Hz**. The 8 MHz is the board crystal
X10, not the Z80's own clock (the Z8400A at IC1 is a 4 MHz-grade part), and the
divider is on the 16-bit board, not this one — see §5. This is the rate the
PinMAME `SLEIC2` driver uses.

---

## 1. Hardware context

From the service manual (§7.2.2.1, p.95) and the board inventory:

| Item | Value |
|------|-------|
| Z80 part | GoldStar `Z0840004PSC` (Z80A, 4 MHz grade) — IC1 on board 011-030A |
| Crystal | X10 = **8 MHz** (HC-49 can, bottom-right of board) — the board timing source, divided down for the CPU |
| ROM IC5 | 27C256, 32 KB |
| Watchdog | ADM699 (IC15) — **reset-only**, no clock output |
| PAL | IC8 (PAL16L8) — purely combinatorial, **cannot generate an IRQ** |
| Timer chip | **none** (no PIT, no CTC, no 8253) |

The Z80 uses **Interrupt Mode 1** (`im 1` at `0x0002`, repeated in `main_init`
at `0x0401`) which fires RST 38h on `/INT` assertion.  The vector at `0x0038`
unconditionally jumps to `irq_service_main` at `0x0A42`:

```
0038  c3 42 0a   jp irq_service_main
```

There is **no `OUT (port),A` in the boot sequence that programs a counter
chip** — `boot_port_init` (0x041B–0x0459) only writes initial values to ports
0x80–0x87.  The periodic IRQ therefore comes from outside this board: the
divider chain is on the **16-bit** board — two cascaded 74LS393 counters
(IC20, IC21) into a 74LS27 (IC22), next to OSC1 — and the result reaches the Z80
over the J3 ribbon.  See [`../docs/hardware_architecture.md`](../docs/hardware_architecture.md).

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
driver timers are running) — at 4 MHz that is 150–375 µs of work per interrupt,
i.e. 15–37 % of the CPU at 1 kHz, which is workable.

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

## 5. The IRQ source

The Z80 board has no PIT, no CTC, and an ADM699 whose only output is `/RESET`,
so the periodic `/INT` cannot originate here.  It comes from the divider chain
on the 16-bit board: IC20 and IC21 (74LS393 dual counters) cascaded into IC22
(74LS27), positioned beside OSC1, with the result carried over the J3 ribbon
([`../docs/board_011-029A_ics.md`](../docs/board_011-029A_ics.md)).  8 MHz ÷ 8192
= **977 Hz** is the tap that lands in the range §2 requires (400 Hz–5 kHz) and
matches the JP/Peyper convention for the same job.  The exact tap is read off the
counter chain rather than measured.

## 6. What the driver uses

```c
MDRV_CPU_PERIODIC_INT(SLEIC_irq_z80, 8000000/8192.)   /* ~977 Hz */
```

stated as `8000000/8192` rather than as a constant so the derivation stays
visible.  At 977 Hz each lamp column refreshes at **122 Hz**, well above the
flicker threshold.

The Z80's own clock is a separate question and is **not** 8 MHz: IC1 is a
`Z0840004`, a 4 MHz-grade Z80A, so X10 is divided for the CPU.  The PinMAME
driver still runs the emulated Z80 at the 2.5 MHz figure inherited from the
sister machines, with 4 MHz noted as the likely correction; changing it re-times
every J1 measurement at once, so it is a step of its own.

---

## Citations

* Z80 ROM `V1 3_05.bin`, decoded in [`../asm/baseline-2026-09/iomoon_z80.lst`](../asm/baseline-2026-09/)
  * `0x0002` `IM 1`; `0x0038` `JP 0x0A42` (the RST 38h vector)
  * `0x0401` `IM 1` again in the boot path
  * `0x041B`–`0x0459` `boot_port_init` — no programmable-timer setup
  * `0x0A42` the IRQ service routine, and its three leading calls
  * `0x2E62` the matrix-scan state entry, dispatched from the main loop
  * `0x3446` the 8-state lamp column strobe (0x01..0x80) on port 0x83
* `/home/gerwout/iomoon/pinmame/src/wpc/jp.c:13–14, 32, 295–298`  — JP driver `IRQ @ 977 Hz (4MHz/2048/2)`
* `/home/gerwout/iomoon/pinmame/src/wpc/peyper.c:22–25, 215–243` — Peyper 1600 / 2500 / 440 Hz
* `/home/gerwout/iomoon/pinmame/src/wpc/inder.c:317–320, 547, 931`  — Inder 250 / 180 / 225 Hz
* `/home/gerwout/iomoon/pinmame/src/wpc/spinbgames.c:36` and `spinb.c:881` — Spinb 175 Hz
* `pinmame/src/wpc/sleic.c` — `MACHINE_DRIVER_START(SLEIC2)`, `8000000/8192.`
* [`../docs/board_011-030A_ics.md`](../docs/board_011-030A_ics.md) — X10 = 8 MHz crystal, ADM699 (reset-only), IC8 = PAL16L8
