# YM3812 hookups in other PinMAME drivers

[← Back to main README](../README.md)

> **RESOLVED (2026-06):** the open question this document circles — whether/how the
> IO Moon YM3812 is driven — is now **answered**. The **80188 drives the YM3812
> directly via /PCS5 (`0xA0280` index / `0xA0281` data)** for the in-game music;
> the driver code was located and byte-verified in `V1 3_01.bin` (OPL2 write
> primitive `D000:0D99`, music sequencer `D000:0D37`, song table `CS:0DE5`). The
> "PIC does both jobs" and "BOM-only / never driven" hypotheses below are
> **superseded** — see the Update section at the end. (IC23 is DMD-only.)

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

For the immediate driver work, start by **leaving the YM3812 attached-but-unmapped (current state) and run the ROM in MAME's debugger with logging on segment A000h**. Any write to A000:XXXX that's *not* one of the four DMD register offsets is a candidate YM3812 register access. If no such write ever happens after running through attract mode + a full game, hypothesis (2) — the chip is BOM-only — wins. *(Superseded: this was later resolved — the YM3812 base is `/PCS5` = `0xA0280`/`0xA0281` and the chip plays the in-game music, so it must be mapped; see the Update section below. "BOM-only" was an attract-only artefact.)*

---

## Update — RESOLVED (2026-06): YM3812 driven by the 80188; 10 FM music tracks in ROM1

- IC60 is **confirmed populated** with a real `YAMAHA / YM3812 / JAPAN` 24-pin DIP, with the decoupling/support parts it needs to function. Not a placeholder.
- Earlier PinMAME tracing showed zero FM writes **only because that trace ran in attract / isolated-boot mode, which is silent** — the music plays during *gameplay*. That was never evidence of a silent chip.
- The 80188's `4000:1158+` byte queue is the **display/animation** queue; the sound drivers are a **separate 80188 code path** (below). The PIC at IC23 is **DMD-only** (all its pins are DMD signals on sheet 011-029-07) — the "one PIC, two jobs" idea is **wrong**.

### What actually drives it (byte-verified in `V1 3_01.bin`; `D000` = file `0x50000`)

- **One FM write site** — `D000:0D99` (file `0x50D99`): `mov es:[0280h],ah` (YM3812 index port, `0xA0280`) → OPL2 settling-delay subroutine (`0x50DA9`) → `mov es:[0281h],al` (data port, `0xA0281`, file `0x50DA1`). A whole-ROM signature scan finds this as the **sole** FM write site; all register programming flows through it.
- **Music sequencer** `D000:0D37` walks `(register, value)` opcode streams (`0xEE` note-duration, `0xEF` tempo, `0xDD` loop-with-target, `0xFF` end; default = FM register write), pointer in `[12EAh]`, ticked per frame from a timer ISR.
- **Song table** at `CS:0DE5` (file `0x50DE5`) — **exactly 10 entries → 10 FM music tracks** (targets `0x50DF9, 0x50E32, 0x51662, 0x52106, 0x52769, 0x522A8, 0x525E9, 0x526A9, 0x529FA, 0x52C8E`). Decoding all ten yields **510 KeyOn events and ~3,600 FM register writes with zero invalid OPL2 registers**; track 1 contains a full OPL2 instrument setup using the exact channel→operator slot offsets (0,1,2,8,9,10,16,17,18) — unmistakably hand-written FM driver data. Track 0 is a short "all-notes-off" init stub.
- **OKI cross-check** — the MSM6376 sample ROMs hold **28 phrases, 0.11–4.49 s each (~50 s total)**: short speech/SFX only, **no music-length phrase**. So music is FM, not sampled; the OKI handles speech + sound effects.

**Implication for the PinMAME driver**: do **not** leave the YM3812 attached-but-unmapped. Map it at `0xA0280` (index, A0=0) / `0xA0281` (data, A0=1) inside the 80188's `A000h` peripheral window and route those writes to PinMAME's `YM3812_control_port_0_w` / `YM3812_write_port_0_w`; the emulated OPL2 will then play the 10 tracks. **Dumping IC23 is unnecessary for sound** (it is DMD-only); dumping **IC7** only refines the OKI control-latch bit map.
