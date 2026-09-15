# IO Moon Z80 I/O Coprocessor — Periodic IRQ Timing Analysis

**Question:** What frequency should the Z80's RST 38h IRQ fire at in the
PinMAME driver?

**Answer:** **`2000000/4096`** — **488.28 Hz**, generated on the Z80 board
itself. Schematic sheet `011-030-02` carries the whole chain: X10 (8 MHz) is
halved twice, giving `GCLK` = 4 MHz (the Z80's own clock) and `ZCLK` = 2 MHz;
`ZCLK` clocks a free-running CD4040 at IC12; all twelve of its outputs feed the
13-input NAND at IC13, which pulses at terminal count and sets the IC14A/IC14B
latch that drives `/INT`; IC8's `/RI` clears it. See §5.

**The PinMAME `SLEIC2` driver currently runs 977 Hz — a factor of two too
fast** — and its Z80 core runs at 2.5 MHz where the board says 4 MHz. Both are
driver changes waiting to be made; neither is made here.

---

## 1. Hardware context

From the service manual (§7.2.2.1, p.95) and the board inventory:

| Item | Value |
|------|-------|
| Z80 part | GoldStar `Z0840004PSC` (Z80A, 4 MHz grade) — IC1 on board 011-030A |
| Crystal | X10 = **8 MHz** (HC-49 can, bottom-right of board) — the board timing source, divided down for the CPU |
| ROM IC5 | 27C256, 32 KB |
| Z80 clock | `GCLK` = **4 MHz** — X10 halved once by IC11A (74LS74), sheet `011-030-02` |
| Watchdog | ADM699 (IC15) — reset and brownout; its `WDI` takes the `WATCH` net |
| PAL | IC8 (PAL16L8) — purely combinatorial, **cannot generate** an IRQ, but it **clears** one: its `/RI` output resets the latch |
| Timer | IC12 CD4040 (12-stage ripple counter, `RST` grounded, clocked by `ZCLK` = 2 MHz) + IC13 74S133 13-input NAND decoding terminal count |

The Z80 uses **Interrupt Mode 1** (`im 1` at `0x0002`, repeated in `main_init`
at `0x0401`) which fires RST 38h on `/INT` assertion.  The vector at `0x0038`
unconditionally jumps to `irq_service_main` at `0x0A42`:

```
0038  c3 42 0a   jp irq_service_main
```

There is **no `OUT (port),A` in the boot sequence that programs a counter
chip** — `boot_port_init` (0x041B–0x0459) only writes initial values to ports
0x80–0x87.  Nothing needs to: the timer is hard-wired ripple logic with its
reset tied to ground, so it starts at power-on and never stops.  The rate is
therefore fixed by the divider chain alone:

| Stage | Divisor | Result |
|-------|---------|--------|
| X10 crystal | — | 8 MHz |
| IC11A (74LS74) | ÷2 | `GCLK` = 4 MHz — **the Z80's clock** |
| IC11B (74LS74) | ÷2 | `ZCLK` = 2 MHz — clocks IC12 |
| IC12 (CD4040) + IC13 (74S133) | ÷4096 | **488.28 Hz** — the IRQ |

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

The Z80 board has no PIT and no CTC, but it does have a timer: **IC12 + IC13**,
which the board inventory used to describe as a watchdog. Sheet `011-030-02`
shows otherwise. IC12 is a CD4040 12-stage ripple counter with `CLK` ← `ZCLK`
and `RST` tied to **ground** — it free-runs and nothing ever clears it. All
twelve outputs `Q1`–`Q12` go to IC13, a 13-input NAND whose thirteenth input is
tied high, so IC13's output drops for one `ZCLK` period each time the counter
reaches `0xFFF`: **once every 4096 clocks**.

That pulse is the *set* input of a cross-coupled NAND latch built from IC14A
and IC14B (74LS00). The latch's output is the Z80's **`/INT`**. Its *reset*
input is **`/RI`**, an output of the PAL at IC8 — which is why a combinational
PAL appears in an interrupt path at all: it does not generate the interrupt, it
clears it. The bench read of IC8 recovers an interrupt-acknowledge decode
(`/M1` and `/IOREQ` together), which is exactly the right shape for that job:
the Z80 runs in interrupt mode 1, so its INTACK cycle fetches no vector and its
only purpose is to acknowledge ([`../roms/PAL16L8/`](../roms/PAL16L8/)).

With `ZCLK` = 2 MHz the rate is **2 000 000 / 4096 = 488.28 Hz**. That lands
just inside the range §2 requires and puts each lamp column at 61 Hz, the
conventional refresh figure. The watchdog is separate: IC15's `WDI` takes the
`WATCH` net, which also gates the work RAM's chip enable through IC14C/D.

## 6. What the driver uses

```c
MDRV_CPU_PERIODIC_INT(SLEIC_irq_z80, 8000000/8192.)   /* ~977 Hz */
```

That is **twice the board's rate** and should become `2000000/4096.` — 488.28
Hz — with each lamp column refreshing at 61 Hz rather than 122 Hz. The Z80 core
likewise still runs at the 2.5 MHz figure inherited from the sister machines
where the board says **4 MHz**. Both corrections re-time every J1 measurement at
once, so each is a step of its own and neither is made here.

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
* [`../docs/board_011-030A_ics.md`](../docs/board_011-030A_ics.md) — X10 = 8 MHz crystal, the IC11 divider pair, IC12/IC13 interrupt timer, IC14 latch, IC15 ADM699, IC8 = PAL16L8
* IO Moon service manual, schematic sheets `011-030-01` (Z80, EPROMs, RAM, IC8 symbol) and `011-030-02` (clock chain, IC12/IC13/IC14 interrupt latch, IC15, the IC16/IC17 port decoders) — [`../manuals/sleic_io_moon_manual_es.pdf`](../manuals/sleic_io_moon_manual_es.pdf)
* [`../roms/PAL16L8/`](../roms/PAL16L8/) — the IC8 bench read, including the interrupt-acknowledge decode on the `/RI` path
