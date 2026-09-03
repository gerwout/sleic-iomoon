# YM3812 / OKI workarounds in PinMAME drivers

Survey of how PinMAME drivers cope when a sound chip is present on the real PCB
but driven by an undumped microcontroller, PAL, or otherwise opaque firmware.

**IO Moon is not one of those cases**, and the survey is kept for the general
pattern rather than as a template for this machine. Both IO Moon sound chips are
driven directly by the 80188, whose ROM is dumped: the YM3812 over `/PCS5`
(`0xA0280` index / `0xA0281` data) from the sequencer at `D000:0D37` / `0D99`,
and the OKI MSM6376 from the dispatcher `D000:0B70` through `0C57`/`0C84` (the
`0xA0300` latch plus the `/OKCS` strobe on `0xA0000` bit 5). The PIC at IC23 is
the DMD rasterizer and drives neither; the Z80 has no wires to either chip and
forwards no sound commands. So the driver emulates the 80188's own writes, and no
C substitution is involved.

## Summary table

| Driver | Chips declared | Who drives them on real HW | Driven in PinMAME by | Workaround pattern |
| --- | --- | --- | --- | --- |
| `mephisto.c` (Cirsa Mephisto, Sport 2000) | AY8910, **YM3812**, DAC | Intel 8051 sound CPU | 8051 emulated, but its ROM never writes the YM3812; only AY8910 + DAC are reached. YM3812 added at `MDRV_SOUND_ADD` (mephisto.c:192) but receives zero writes. | "Declare it but leave it silent". |
| `alvgs.c` (Alvin G. Gen-1: Al's Garage Band) | **YM3812**, OKI6295 | 6809 sound CPU | 6809 is fully emulated; its ROM is dumped, so it writes both chips directly via `YM3812_*_w` / `OKIM6295_data_0_w` (alvgs.c:156-168). | Standard chip-on-sound-CPU emulation. Not a workaround. |
| `jvh.c` (Formula 1) | YM2203, **YM3812**, DAC | 6809 sound CPU | 6809 emulated with dumped ROM; chips are mapped into 6809 memory (jvh.c:724-740). | Standard chip-on-sound-CPU emulation. |
| `jvh.c` (movmastr) | AY8912 on 6802 board | 6802 sound CPU with NO_DUMP ROM (jvh.c:600) | The CPU runs garbage / open bus and produces no sound. | "Game marked playable (no sound), no synthetic substitution". |
| **`lancelot.c` (Peyper Sir Lancelot)** | **OKIM6295, YMF262, YAC512** | **Toshiba TMP91P640 micro with NO_DUMP ROM** (lancelot.c:436) | **Z80 main CPU**: PinMAME synthesises the micro's behaviour in C. Sound bytes the main CPU strobes out to the (absent) micro are intercepted and translated into direct register writes to OKIM6295 (lancelot.c:61-79, 134) and YMF262 (lancelot.c:87, 267-336). | **C-side stub coprocessor**. The closest precedent to Io Moon. |
| `gts3.c` (Gottlieb System 3 sound) | OKIM6295, YM2151, DACs | 6502 sound CPU | All ROMs dumped; chips mapped to the 6502 (gts3.c:961-962). | Standard. |
| `tabart.c` | YM2203, YM3526 / AY8910 | Z80 sound CPU | All ROMs dumped; chips mapped (tabart.c:102-117). | Standard. |
| `spinb.c`, `inder.c` (MSM5205 boards) | MSM5205 | Z80/8085 sound CPUs | All ROMs dumped (some BAD_DUMP); ADPCM chip fed nibble-by-nibble from the sound CPU via callback (spinb.c:1130-1180, inder.c:702-770). | Standard. |
| `alvgdmd.c` (Pistol Poker / Mystery Castle DMD) | n/a (DMD raster) | Intel 8031 micro | 8031 emulated, ROM dumped (alvgdmd.c:263). | Standard. |
| `sleic.c` (Io Moon, SLEIC2) | **YM3812**, OKIM6376 | **80188 drives both directly** (YM3812 over `/PCS5`; OKI over `0xA0300` + `/OKCS`). The PIC 16C57 is DMD-raster only; the Z80 drives neither chip and forwards no sound commands. | The 80188 is emulated and its ROM is dumped, so both chips are written by the emulated CPU. | Standard chip-on-CPU emulation — no workaround, and no substitution needed. |

The only driver in the tree that actually substitutes for an undumped sound
coprocessor in C is **lancelot.c**. Every other driver either has a dumped
sound ROM (alvgs, alvg gen-2 BSMT, jvh formula1, gts3, tabart, spinb, inder,
alvgdmd) or accepts that the chip is silent (mephisto, jvh movmastr).

Sample-playback substitution (`MDRV_SOUND_ADD(SAMPLES, ...)`) does exist in
`gpsnd.c`, `by35snd.c`, `taitos.c`, `gts1.c` and `core.c`, but it is
exclusively used for mechanical effects (flipper, knocker, chime, coin)
behind `#ifdef ENABLE_MECHANICAL_SAMPLES`. It is never used as a
replacement for an OPL / OKI music chip whose driver firmware is missing.
VGM-style playback does not exist in the tree.

## The lancelot.c pattern in detail

The Sir Lancelot board uses a Z80 main CPU that ships sound commands over
port 0x34 to a Toshiba TMP91P640 microcontroller. The microcontroller's
mask ROM is undumped (lancelot.c:436, `tmp91640.rom ... NO_DUMP`). The
TMP91P640 has all of OKIM6295 (speech / FX), YMF262 (OPL3 music) and
YAC512 (stereo DAC) hanging off it. There is no CPU added for it; the
driver just declares the sound chips and routes port 0x34 to a C
handler:

```
static PORT_WRITE_START(LANCELOT_writeport)
  ...
  {0x34,0x34, snd_w},   // lancelot.c:230
PORT_END
```

`snd_w` pattern-matches the command byte (lancelot.c:101-135) and falls
into three classes:

1. **Direct ADPCM trigger**. Bytes < 0xE0 are translated to an OKIM6295
   "speak phrase n" sequence via `OKI_w` (lancelot.c:61-79), which writes
   the 4-channel allocation prefix + 0x80|phrase + clear-channel
   sequence the real chip needs. This is a faithful low-level
   transcription of what the OKIM6295 datasheet asks for, just done by
   the host driver instead of the missing micro.
2. **Queued ADPCM sequence**. 0xE4 / 0xE6 bracket a list of phrase IDs
   the main CPU wants played back-to-back; the driver collects them and
   then uses a mame_timer (`locals.sndtimer`) to feed them one by one,
   waiting on the OKI status (`OKIM6295_status_0_r`) to drain before
   issuing the next.
3. **Music**. Bytes 0x81..0x8F and 0xF0..0xFF select one of ~30 music
   tracks. The driver reads start/stop pointers from a *separate ROM
   region* (`REGION_USER2`, snd_u5.bin, lancelot.c:441) and uses a
   second timer (`sndtimer2`, lancelot.c:81-89) to stream raw YMF262
   register writes from that ROM through `YMF262_data_A_0_w`. The
   YMF262 IRQ callback (`ymf_irq`, lancelot.c:242) advances the stream.
   So Lancelot effectively contains a tiny VGM player.

`MACHINE_INIT(LANCELOT)` (lancelot.c:261-338) pre-loads the YMF262 with
operator envelopes and channel routing that the missing micro would have
programmed at boot. Without this, the streamed register writes would hit
muted operators.

The game is shipped as `GAME_IMPERFECT_SOUND` (lancelot.c:443), not
`GAME_NOT_WORKING`, which signals that PinMAME upstream considers this
"good enough" even though it is admittedly a fragile transcription of
behaviour observed on real hardware.

## Why Io Moon needs none of this

The lancelot pattern exists because the CPU that writes the sound chips is
missing. On IO Moon that CPU is the 80188, whose ROM is dumped and which the
driver already emulates instruction by instruction, so its sound writes arrive at
the emulated peripheral block on their own:

```c
/* sleic2_periph_w, inside the PACS block at 0xA0000 */
case 0x280: YM3812_control_port_0_w(0, data); break;   /* PCS5, index */
case 0x281: YM3812_write_port_0_w(0, data);   break;   /* PCS5, data  */
case 0x300: iomoon_oki_latch = data;          break;   /* PCS6, phrase + channel */
case 0x000: if (falling edge of bit 5) iomoon_oki_strobe();  /* PCS0, /OKCS = ST */
```

Consequently:

- **No PIC core is needed.** The PIC16C57 at IC23 is the DMD rasterizer; it
  drives no sound chip, and its dump confirms it has no command interface at all.
- **No command-queue interception is needed.** The queue at `4000:1158` carries
  Z80 commands for lamps, drivers and mode changes — not sound.
- **No hand-coded register sequences are needed.** The ROM contains the whole FM
  driver: a sequencer at `D000:0D37` walking `(register, value)` streams, a song
  table of ten tracks at `CS:0DE5`, and a single write primitive at `D000:0D99`.
- **No SAMPLES substitution is needed**, and it would be the wrong tool anyway —
  in this tree `SAMPLES` is reserved for mechanical effects.

The one thing IO Moon does share with the drivers surveyed above is that its
YM3812's IRQ is not wired to any CPU: the 80188's interrupt controller unmasks
only timer 0 and INT0, so the OPL2's internal timers have nowhere to go and the
`ym3812_irq` callback body stays empty.

The OKI hookup needs one translation, because PinMAME's `OKIM6295` core speaks a
two-byte 6295 protocol rather than the 6376's `ST` / `CH2` pins: the driver turns
each `/OKCS` falling edge into the phrase-latch-and-start byte pair the core
expects. That is an interface adapter inside the driver, not a substitute for
missing firmware.

---

## Summary

The PinMAME tree contains exactly one driver that emulates an undumped sound
coprocessor in host C code: **`lancelot.c`** (Peyper, Sir Lancelot, 1994). Its
Toshiba TMP91P640 micro has a `NO_DUMP` mask ROM, and PinMAME substitutes for it
by intercepting the Z80's sound-command port writes and translating them into
hand-coded `OKIM6295_data_0_w` and `YMF262_data_A_0_w` sequences, driven by
mame_timers and the chip's own status / IRQ callbacks. Lancelot also includes a
small VGM-style player that streams pre-extracted OPL register sequences from an
auxiliary ROM (`REGION_USER2`). The game ships as `GAME_IMPERFECT_SOUND`.

Every other driver in the tree either has a dumped sound CPU and emulates it
faithfully (alvgs, jvh, tabart, gts3, spinb, inder, alvgdmd) or leaves the chip
silent (mephisto declares a YM3812 and never writes it). `SAMPLES` substitution
exists but is restricted to mechanical effects, and no driver replaces a music
chip with sample playback.

**Io Moon sits in the first group**: the CPU that writes both chips is dumped and
emulated, so `sleic.c` decodes the 80188's peripheral writes and forwards them to
the `YM3812_*` and `OKIM6376_*` cores. The lancelot pattern is documented here
for machines that genuinely need it.
