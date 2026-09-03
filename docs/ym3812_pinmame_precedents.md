# YM3812 hookups in other PinMAME drivers

[← Back to main README](../README.md)

Survey of the existing PinMAME drivers that declare the Yamaha YM3812 FM
synthesizer, and where IO Moon sits among them. Source:
`pinmame/src/wpc/{jvh,alvg,alvgs,mephisto,sleic}.c`.

**IO Moon's own hookup, for reference:** the 80188 drives the YM3812 directly
over `/PCS5`, with the index port at `0xA0280` (A0 = 0) and the data port at
`0xA0281` (A0 = 1) — two distinct addresses, not an A0 toggle on one. The write
primitive is `D000:0D99`, the sequencer `D000:0D37` and the song table `CS:0DE5`,
and there are ten tracks. See [`iomoon_fm_extract.md`](iomoon_fm_extract.md) and
finding F8 in [`findings.md`](../asm/baseline-2026-09/findings.md).

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

### Sleic (`sleic.c`, `SLEIC2` = IO Moon)

IO Moon is the outlier in this survey: it is the only machine here whose YM3812
hangs off the **main game CPU** rather than a dedicated sound CPU. There is no
6809, no sound-CPU ROM and no command port; the 80188's own game code writes FM
registers between everything else it does.

```c
static struct YM3812interface SLEIC2_ym3812_intf = { 1, 4000000, { 100 }, { ym3812_irq } };

/* in sleic2_periph_w, inside the PACS block at 0xA0000 */
case 0x280: YM3812_control_port_0_w(0, data); break;   /* index */
case 0x281: YM3812_write_port_0_w(0, data);   break;   /* data  */
```

Two details of that hookup:

- **The index and data ports are separate addresses**, `0xA0280` and `0xA0281`.
  That is the same shape as the 6809 machines' `BASE` / `BASE+1`, but reached by
  memory-mapped `mov` stores through a peripheral chip-select rather than by a
  6809 store. (Sleic Pin-Ball and Bike Race, on the same board family, drive A0
  differently again — see [`sleic_board_family.md`](sleic_board_family.md).)
- **The YM3812's IRQ is not wired to the CPU.** The 80188's interrupt controller
  unmasks only timer 0 and INT0 (finding F1), so there is no line for the OPL2's
  internal timers to reach; the `ym3812_irq` callback body stays empty.

## Notes on the shared parameters

1. **Clock.** 4 MHz is what IO Moon uses, matching Alvin G and the usual pinball
   OPL2 rate; the IO Moon figure is inferred from the board's 8 MHz divider chain
   (see [`iomoon_fm_extract.md`](iomoon_fm_extract.md)) rather than measured.
2. **The two-byte footprint** (index + data) is universal across all of these
   drivers, whatever the CPU.
3. **"Declared but never written" is a real state in this tree** — Cirsa /
   Mephisto is in production that way. It is worth knowing as a category, because
   a silent trace is not by itself evidence that a chip is unused: IO Moon's music
   plays only in gameplay, and attract mode is silent by design.
