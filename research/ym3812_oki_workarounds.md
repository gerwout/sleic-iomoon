# YM3812 / OKI workarounds in PinMAME drivers

> **2026-06 correction — this survey's premise is obsolete.** It was written on
> the assumption that the IO Moon YM3812 (and OKI) were driven by an *undumped*
> coprocessor (the PIC 16C57 at IC23), so PinMAME would need a lancelot-style C
> substitution. That is **wrong**: the **80188 drives both sound chips directly**,
> and the 80188 ROM **is dumped**. The YM3812 is written over `/PCS5`
> (`0xA0280`/`0xA0281`) by a music sequencer at `D000:0D37`/`0D99` (10 FM tracks),
> and the OKI MSM6376 from `D000:0B70`/`0C57` (`0xA0300` latch, `/OKCS` strobe via
> `0xA0000` bit 5). The PIC at IC23 is the **DMD rasterizer only** and drives no
> sound chip; the Z80 forwards sound-command bytes to the 80188 over J1 but drives
> no chip either. So there is **nothing undumped to substitute for** — the right
> approach is to emulate the 80188's own writes, exactly as the working PinMAME
> driver now does. The cross-driver survey below is still accurate about *those*
> drivers, but the "Recommended pattern for Io Moon" sections are superseded.

Survey of how PinMAME drivers cope when a sound chip is present on the real
PCB but actually driven by an undumped microcontroller, PAL, or otherwise
opaque firmware. (Originally intended to pick a precedent for the Sleic Io Moon
driver — see the correction above for why that precedent is no longer needed.)

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
| `sleic.c` (Io Moon, SLEIC2) | **YM3812**, OKIM6376, DAC | **80188 drives both directly** (YM3812 over `/PCS5`; OKI over `0xA0300` + `/OKCS`). The PIC 16C57 is DMD-raster only; the Z80 forwards command bytes over J1 but drives no chip. | The early stub reached the OKI via a Z80 port handler (`sleic.c:395`) and left the YM3812 silent; the working driver now emulates the 80188's own writes to both chips. | _Superseded — the 80188 ROM is dumped, so no C substitution is needed (see correction at top)._ |

The only driver in the tree that actually substitutes for an undumped sound
coprocessor in C is **lancelot.c**. Every other driver either has a dumped
sound ROM (alvgs, alvg gen-2 BSMT, jvh formula1, gts3, tabart, spinb, inder,
alvgdmd) or accepts that the chip is silent (mephisto, jvh movmastr, sleic
today).

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

## Recommended pattern for Io Moon

The Io Moon situation maps onto lancelot.c almost one-for-one, with a
useful simplification:

| | Lancelot | Io Moon |
| --- | --- | --- |
| Main CPU | Z80 | 80188 |
| Undumped consumer | TMP91P640 | PIC 16C57-HS |
| Command channel | Z80 OUT 0x34 | _(N/A — see correction: the 80188 drives its own sound chips; the `4000:1158+` queue is the DMD/animation path, not sound)_ |
| Music chip | YMF262 (OPL3) | YM3812 (OPL2) — driven directly by the 80188 over `/PCS5`, **not** by any PIC |
| ADPCM chip | OKIM6295 | OKIM6376 — driven directly by the 80188 (`0xA0300` latch + `/OKCS`), **not** by the Z80 |
| Auxiliary tone ROM | snd_u5.bin in REGION_USER2 | none known yet |

The Mephisto pattern (declare YM3812, never drive it) is what `sleic.c`
already does. The Io Moon driver should follow lancelot.c instead:

### Minimal bridge

1. **Don't emulate the PIC**. Drop any plan to MDRV_CPU_ADD the
   16C57 — PinMAME has no PIC 16C5x core, and the firmware is missing
   anyway. Lancelot precedent says it is fine to declare only the audio
   chips and skip the host micro entirely.
2. **Hook the command queue from the 80188 side**. In
   `SLEIC2_80188_writemem` add a write handler covering the queue
   region (`4000:1158+`, physical 0x41158..). Mirror the bytes into
   `iomoon_shared_ram` exactly as today (the 80188 code expects to read
   them back, so MWA_RAM is still needed), but also push each one into
   a small C-side FIFO.
3. **Drain the FIFO into YM3812 writes**. A mame_timer running at the
   PIC's natural cadence (probably the panel refresh, ~120 Hz) pops one
   byte from the FIFO and pattern-matches it. The mapping cmd ->
   YM3812 register sequence has to be reverse-engineered (or eventually
   transcribed from a logic-analyzer capture of the real PIC's pin
   output), but the *shape* of the bridge is exactly lancelot's
   `snd_w` / `timer_callback`:
   - For tone / sfx events: emit a hand-coded sequence of
     `YM3812_control_port_0_w(0, reg)` /
     `YM3812_write_port_0_w(0, val)` pairs that set up operator
     envelopes, F-number, key-on / key-off.
   - For music: if a separate tone-stream ROM is ever found (or
     extracted from the 80188 graphics ROM), play it back through
     `YM3812_write_port_0_w` driven by the YM3812's own timer-IRQ
     callback. The existing stub `ym3812_irq` in sleic.c:193 is the
     right place to advance the stream.
4. **Pre-program the YM3812 in MACHINE_INIT**. Mirror what
   lancelot's MACHINE_INIT does for the YMF262: set operator levels,
   feedback / algorithm bits, key-scale levels, default tremolo /
   vibrato. Without this, register writes for individual notes will
   produce silence.
5. **No SAMPLES path**. The SAMPLES driver in PinMAME is reserved by
   convention for mechanical effects. Substituting a sampled music
   track for YM3812 output would be unprecedented in the tree and
   would also make the eventual real-PIC dump harder to slot in.
6. **Mark the driver `GAME_IMPERFECT_SOUND`**, not `GAME_NOT_WORKING`,
   once any subset of commands produces audible output — that is the
   precedent lancelot.c sets.

### What the bridge does *not* need to do

> **Superseded (2026-06).** This subsection assumed neither CPU writes the
> YM3812 and that the OKI is driven from the Z80 — both now known to be false.
> The 80188 drives **both** sound chips itself (YM3812 over `/PCS5`, OKI over
> `0xA0300`/`/OKCS`), and its ROM is dumped, so the correct implementation is
> simply to decode those peripheral writes in `sleic.c` and forward them to the
> emulated `YM3812_*` / `OKIM6376_*` cores — **no PIC core, no C-side command
> substitution, and no command-queue interception are needed.** That is what the
> working driver now does.

---

## Summary (<250 words)

The PinMAME tree contains exactly one driver that emulates an undumped
sound coprocessor in host C code: **`lancelot.c`** (Peyper, Sir Lancelot,
1994). Its Toshiba TMP91P640 micro has a NO_DUMP mask ROM, and PinMAME
substitutes for it by intercepting the Z80's sound-command port writes
and translating them into hand-coded `OKIM6295_data_0_w` and
`YMF262_data_A_0_w` sequences, driven by mame_timers and the chip's own
status / IRQ callbacks. Lancelot also includes a tiny VGM-style player
that streams pre-extracted OPL register sequences from a separate
auxiliary ROM (REGION_USER2). The game ships as `GAME_IMPERFECT_SOUND`,
not `GAME_NOT_WORKING`.

Every other driver in the tree either has a dumped sound CPU and
emulates it faithfully (alvgs, jvh, tabart, gts3, spinb, inder, alvgdmd),
or leaves the chip silent (mephisto declares YM3812 but never writes it,
which is what `sleic.c` does today). `SAMPLES` substitution exists but is
restricted to mechanical effects, and no driver replaces a music chip
with sample playback.

**Recommendation for Io Moon: copy the lancelot.c pattern.** Add a write
handler on the 80188 side covering the circular command queue at
`4000:1158+`, push bytes into a C FIFO, and drain them through a
mame_timer that issues `YM3812_control_port_0_w` /
`YM3812_write_port_0_w` register sequences. Pre-program operator
envelopes in `MACHINE_INIT(SLEIC)`. Do not emulate the PIC (PinMAME has
no PIC 16C5x core, and lancelot.c sets the precedent for skipping it).
Do not use SAMPLES. Once any subset of commands produces audible output,
flip the games from `GAME_NOT_WORKING` to `GAME_IMPERFECT_SOUND`.
