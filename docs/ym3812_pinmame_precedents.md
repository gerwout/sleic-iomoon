# YM3812 hookups in other PinMAME drivers

[← Back to main README](../README.md)

Survey of every existing PinMAME driver that declares the Yamaha YM3812 FM synthesizer. The point is to identify a hookup pattern that might apply to the SLEIC IO Moon and to compare the **already-attempted-but-stalled** PinMAME drivers against IO Moon's situation. Source: `pinmame/src/wpc/{jvh,alvg,alvgs,mephisto,sleic}.c`.

YM3812 datasheets: [`../datasheets/ym3812.pdf`](../datasheets/ym3812.pdf) (device datasheet) and [`../datasheets/ym3812_opl2_application_manual.pdf`](../datasheets/ym3812_opl2_application_manual.pdf) (OPL2 register-level programming manual); the companion DAC is [`../datasheets/ym3014b.pdf`](../datasheets/ym3014b.pdf).

## Drivers that map the YM3812 to addresses

### Alvin G. and Co. — `alvg_s1` sound board (`alvgs.c`)

| Aspect | Value |
|---|---|
| Sound CPU | **Motorola 6809** (`ALVGS1_SNDCPU_FREQ`) |
| Address decoder | **74LS138 (U26)** decoded on A14-A13-A12 — 8 chip selects on 0x1000 boundaries |
| Clock | 4 MHz |
| YM3812 location | **`0x2000` (control/index) + `0x2001` (data)** on the M6809 |
| YM3812 status read | **`0x2000`** on the M6809 |
| OKI MSM6295 | `0x4000` on the M6809 (same address for status read + data write) |
| YM3812 IRQ | Wired to `M6809_IRQ_LINE` of the sound CPU |
| Communication with main CPU | 6522 VIA at `0x5000-0x500F` (PA = sound data, CA1 = strobe) |

The comment block in `alvgs.c` explicitly documents the U26 decoder logic — that's the textbook YM3812 attachment in pinball:

```
A14 A13 A12  Y0  Y1  Y2  Y3  Y4  Y5  Y6  Y7
 0   0   0   /CS  -   -   -   -   -   -   -    Y0 = NC
 0   0   1    -  /CS  -   -   -   -   -   -    Y1 = NC
 0   1   0    -   -  /CS  -   -   -   -   -    Y2 = YM3812 Enable   (0x2000)
 0   1   1    -   -   -  /CS  -   -   -   -    Y3 = RAM Enable      (0x3000)
 1   0   0    -   -   -   -  /CS  -   -   -    Y4 = OKI6295 Enable  (0x4000)
 ...
```

### Jac Van Ham — `jvh3` (Formula 1, `jvh.c`)

| Aspect | Value |
|---|---|
| Sound CPU | **Motorola 6809** @ 2 MHz |
| Clock | 1 MHz YM3812 master clock |
| YM3812 location | **`0x4000` (control/index) + `0x4001` (data)** on the M6809 |
| YM3812 status read | **`0x4000`** on the M6809 |
| YM2203 also present | `0x2000` (control) + `0x2001` (data) on the same M6809 |
| Combined status read | `0xC000` returns `YM2203_status | YM3812_status` |

A second M6809 handles DAC + 6522 VIA on top of the FM CPU.

### Pattern in both

- YM3812 on **its own CPU** (a dedicated 6809 audio coprocessor), never on the main game CPU.
- Two consecutive byte addresses: `BASE` = control/index/status, `BASE+1` = data.
- IRQ from the YM3812's internal timers is routed to the **same** CPU it's mapped on.
- A standalone 74LS138 (or PAL) handles the chip-select decode.

## Drivers that declare YM3812 without mapping it

### Stargame Mephisto / Cirsa (`mephisto.c`)

```c
static struct YM3812interface cirsa_ym3812Int = {
    1, 3579545, { 50 }, { ym3812_irq },
};
/* ... */
MACHINE_DRIVER_START(mephisto)
    ...
    MDRV_CPU_ADD_TAG("scpu", I8051, 12000000)
    MDRV_CPU_MEMORY(cirsa_readsnd, cirsa_writesnd)
    MDRV_CPU_PORTS(cirsa_readsndport, cirsa_writesndport)
    MDRV_SOUND_ADD(YM3812, cirsa_ym3812Int)   /* <-- declared */
    ...
MACHINE_DRIVER_END
```

But `cirsa_readsnd`, `cirsa_writesnd`, `cirsa_readsndport`, `cirsa_writesndport` **contain no `YM3812_*` handlers anywhere**. The chip is wired to PinMAME's sound mixer but receives zero register writes, so it makes no sound. The Cirsa Mephisto is an I8051-based machine — same family as our 80188+Z80 case in that the sound CPU is not an M6809.

This is "attached but unmappable" — the original driver author knew the chip is on the board but couldn't (or didn't) figure out how it's wired from disassembly alone.

### Sleic (current `sleic.c`)

The existing PinMAME SLEIC stub does exactly the Cirsa thing:

```c
static void ym3812_irq(int irq) {
  // cpu_set_irq_line(SLEIC_MAIN_CPU, 0, irq ? ASSERT_LINE : CLEAR_LINE);   <-- commented out
}

static struct YM3812interface SLEIC_ym3812_intf = {
    1, 4000000, { 100 }, { ym3812_irq },
};

MACHINE_DRIVER_START(SLEIC2)             /* IO Moon */
    MDRV_IMPORT_FROM(SLEIC)
    MDRV_SOUND_ADD(YM3812, SLEIC_ym3812_intf)   /* <-- declared */
    MDRV_SOUND_ADD(OKIM6295, SLEIC_okim6376_intf2)
    MDRV_SOUND_ADD(DAC, SLEIC_dac_intf)
MACHINE_DRIVER_END
```

- YM3812 declared on the SLEIC base machine.
- IRQ callback present but body **commented out** — even if internal YM3812 timers fire, nothing happens.
- No memory or port handlers anywhere refer to `YM3812_control_port_0_w` / `YM3812_write_port_0_w`.

State: identical to Cirsa. The chip is present in the mixer, never written, makes no sound.

## What this means for the IO Moon driver work

1. **There is no PinMAME precedent for a YM3812 driven by an 80188 directly.** Every working YM3812 hookup goes through a dedicated 6809 sound CPU with the chip at consecutive byte memory addresses.
2. **There is a precedent for "YM3812 declared but never wired" — Cirsa / Mephisto**. Those drivers are still in production with the chip silent. The IO Moon stub already follows this pattern.
3. **If the YM3812 *is* actually used on IO Moon**, the simplest emulation hookup would be to add a `YM3812_control_port_0_w` / `YM3812_write_port_0_w` handler pair to the 80188 memory map at whatever address we discover. The likely location is inside the MMCS window (segment `A000h`) at an offset distinct from the four documented DMD register offsets (`0x0000/0x0080/0x0200/0x0300`).
4. **The two-byte footprint** (index + data) means the new PinMAME handler additions are exactly one read + two write entries:
   ```c
   /* hypothetical IO Moon YM3812 at A000:XXXX */
   { 0xa0XXX, 0xa0XXX, YM3812_status_port_0_r },        /* in read map */
   { 0xa0XXX, 0xa0XXX, YM3812_control_port_0_w },       /* in write map */
   { 0xa0YYY, 0xa0YYY, YM3812_write_port_0_w },         /* YYY = XXX+1 */
   ```
5. **The IRQ callback needs to be wired**: `cpu_set_irq_line(SLEIC_MAIN_CPU, ...)` — uncomment, and verify the IRQ vector handler exists in the 80188 init table at `CS:0041` (it does — entries at `0xFF32`/`0xFF34` configure INT0/INT1 control words).
6. **The clock value in the current stub is 4 MHz** — same as Alvin G; this is the standard YM3812 master clock in pinball. Likely correct without changing.

For the immediate driver work, start by **leaving the YM3812 attached-but-unmapped (current state) and run the ROM in MAME's debugger with logging on segment A000h**. Any write to A000:XXXX that's *not* one of the four DMD register offsets is a candidate YM3812 register access. If no such write ever happens after running through attract mode + a full game, hypothesis (2) — the chip is BOM-only — wins.

---

## Update (board-photograph evidence — `research/board_inventory.md`)

The "BOM-only" hypothesis can now be **ruled out**:

- IC60 is **confirmed populated** with a real `YAMAHA / YM3812 / JAPAN` 24-pin DIP, surrounded by decoupling cap CD60 and the support resistors / caps it would need to function. It is not a vacant placeholder.
- Empirical PinMAME tracing of 30 seconds of running game code still shows **zero writes to any candidate YM3812 register address from either the 80188 or the Z80**.
- An independent disassembly grep (see [`../research/80188_to_z80_mailbox.md`](../research/80188_to_z80_mailbox.md)) shows the 80188 pushes 80+ events into a circular byte queue at `4000:1158+`. The Z80 cannot consume the queue (no reads outside `0x0000-0x7FFF` ROM and `0xC000-0xC7FF` RAM), so something else does. That something else is the YM3812 driver.

The natural candidate for this role is a **microcontroller coprocessor** between the 80188 and the YM3812 — and a refined reading of the board photos identifies exactly one such device on the 16-bit board: **IC23, the `PIC 16C57-HS/P`**. This is the chip the service manual already documents as the DMD raster coprocessor.

The earlier draft of this document hypothesised two *additional* PICs at IC34 and "IC57". Both readings turned out to be wrong: IC34 is a smaller 74LS-series glue chip, and "IC57" doesn't exist on the board — the subagent had been reading IC7 (which holds a `PAL 20L10`, not a PIC). The clean architecture is therefore: **one PIC, two jobs**.

The PIC 16C57 has **2 K × 12-bit program memory** (4× a PIC 16C54) and **20 I/O pins**. Driving the DMD wire protocol takes 6 signals (DE, RDATA, RCLK, COLLAT, DOTCLK, SDATA per [`dmd_wire_protocol.md`](dmd_wire_protocol.md)); driving a YM3812 takes about 11 signals (D0–D7, A0, /WR, /CS). Total: 17 pins — fits comfortably in the 20 the chip has. The program memory is also more than enough to host both routines plus a small command-queue reader for the 80188's `4000:1158+` mailbox.

**Implication for the PinMAME driver**: the current "attached but unmapped" YM3812 stub remains the right interim state. It produces silent audio output, matching what the emulation can know without modelling the coprocessor. Once IC23 is dumped, a future driver pass would either (a) emulate the PIC 16C57 directly (PinMAME has no PIC 16C5x core today, so this would be net-new work), or (b) parse its instruction stream offline and re-implement its behaviour as a piece of C code that bridges the 80188's `4000:1158+` command queue to PinMAME's `YM3812_*_w` calls.
