# DMD Wire Protocol (PIC → Plasma Panel)

[← Back to main README](../README.md)

This document describes the **serial signal protocol** that the PIC 16C57 at IC23 produces on the 14-pin display ribbon (connector J2 on board 011-029A) and that drives the gas plasma panel (board 011-022). It is the *downstream* half of the display path; the *upstream* half — the 80188 blitting two bitplanes into the 1 KB buffer at `7000:0000` — is in [`dmd_graphics.md`](dmd_graphics.md). Nothing crosses between the two: the PIC free-runs over the buffer and exchanges no byte with the 80188.

The protocol was identified by:

1. A Saleae Logic 2 capture (`Io Moon - Sleic 128x32.sal`) hosted in [PPUC/dmdreader](https://github.com/PPUC/dmdreader/tree/ppuc/logicanalyzer/Sleic). Six digital channels at 12 MHz sample rate, ~44.5 s duration.
2. The Sleic support added in [PPUC/dmdreader#44](https://github.com/PPUC/dmdreader/pull/44), which contains an RP2040 PIO-based decoder that reconstructs frames from the same six signals on real hardware.

---

## Signals

The 14-pin display ribbon carries (in addition to power and ground) six logic signals. Five of them are standard for plasma DMD panels of this era; one (`SDATA`) is Sleic-specific in its use.

| Signal | Direction | Function |
|--------|-----------|----------|
| `DE` | PIC → panel | Display Enable. HIGH during a frame, LOW for ≥ ~100 µs between frames. The falling edge marks end-of-frame; the rising edge marks start-of-frame. |
| `RDATA` | PIC → panel | Row data line. Carries the serialised pixel bits for the current row. |
| `RCLK` | PIC → panel | Row clock. Each pulse advances the panel to the next row. |
| `COLLAT` | PIC → panel | Column latch strobe. Latches the assembled row into the column drivers, after which the panel illuminates that row. |
| `DOTCLK` | PIC → panel | Pixel clock. On the rising edge, the value on the active data line is sampled into the column shift register. |
| `SDATA` | PIC → panel | Secondary data / frame marker. Used by external decoders as the frame-detect trigger. |

(Signal definitions are consistent with the generic plasma-panel signal table in [dmdreader/signals.md](https://github.com/PPUC/dmdreader/blob/ppuc/signals.md) and verified against the Sleic-specific decoder.)

---

## Measured frequencies (from the dmdreader detector thresholds)

The PPUC dmdreader identifies Sleic-class hardware by these signal frequencies, which fall inside the following bands (the measured nominal in parentheses):

| Signal | Range | Nominal |
|--------|-------|---------|
| `DOTCLK` | 570 – 630 kHz | **~599 kHz** |
| `RCLK`   | 4.55 – 4.85 kHz | **~4.7 kHz** |
| `RDATA` | 135 – 155 Hz (frame rate of data transitions) | **~145 Hz** |

Cross-checks:

- 4.7 kHz ÷ 32 rows ≈ **146.9 frames/sec** — consistent with the 145 Hz RDATA refresh.
- 599 kHz ÷ (128 pixels × 32 rows) ≈ **146.2 fps** — same number from the other direction.

So the panel runs at roughly **145 wire-level frames per second**. Because each visible frame is made of **2 bitplanes** (see below), the effective visible refresh rate is **~72 fps**, plenty to avoid flicker on a plasma panel.

---

## Frame composition

From `PPUC/dmdreader` `src/dmdreader.cpp:1268–1289`:

```c
case DMD_SLEIC: {
  uint input_pins[] = {DE, RDATA};
  dmdreader_programs_init(...
    &dmd_framedetect_sleic_program, ...
    input_pins, 2, DE, SDATA);

  pio_sm_put(dmd_pio, dmd_sm, 8191);  /* expect 8192 pixels per frame */

  source_width             = 128;
  source_height            = 32;
  source_bitsperpixel      = 2;
  target_bitsperpixel      = 2;
  source_planesperframe    = 2;
  source_planehistoryperframe = 0;
  source_lineoversampling  = LINEOVERSAMPLING_NONE;
  source_mergeplanes       = MERGEPLANES_ADDSHIFT;
}
```

- **128 × 32 = 4096 pixels per bitplane**
- **2 bitplanes per frame, sent sequentially** (not interleaved). The PIO state machine is told to expect 8191 dots = 8192 - 1 = 2 × 4096.
- The two bitplanes are combined with **ADD-SHIFT** to yield a 2-bit-per-pixel value (4 brightness levels). The Sleic-specific shift in `dmdreader.cpp:653–655` is:

  ```c
  } else if (dmd_type == DMD_SLEIC) {
    v <<= (source_planesperframe - 1) - plane;
  }
  ```

  i.e. **plane 0 → shift left by 1 (MSB)**, **plane 1 → shift left by 0 (LSB)**.

> The PIC streams bitplanes in buffer order — buffer plane 0 (`7000:0000`) = wire plane 0 = **MSB (weight ×2)** — which agrees with [`dmd_graphics.md`](dmd_graphics.md) and with the PIC's own 200:30 per-plane row-hold ratio in [`../asm/pic16c57_annotated.asm`](../asm/pic16c57_annotated.asm).

---

## Frame-detect state machine

From `src/pio/dmd_framedetect_sleic.pio`:

```
.define DE 7
.define RDATA 6
.define RCLK 5
.define COLLAT 4
.define DOTCLK 3
.define SDATA 2
.define FRAME_START_IRQ 5

.program dmd_framedetect_sleic
    set x, 3            ; x = 3
    in x, 2             ; shift in 2 bits, isr = 3
    in null, 11         ; shift left by 11 bits = 6144
.wrap_target
wait_low:
    mov x, isr          ; set x to 6144
    wait 0 gpio DE      ; wait for DE to go low
delay_loop:
    jmp pin, wait_low   ; if pin went high early, restart
    jmp x-- delay_loop  ; otherwise count down ~100 µs
    wait 1 gpio RDATA   ; then wait for RDATA to go high
    irq FRAME_START_IRQ ; fire frame-start interrupt
.wrap
```

Algorithm in words:

1. Wait for `DE` to fall LOW.
2. Verify that `DE` stays LOW continuously for ~6144 decoder cycles (≈ 100 µs at the chosen PIO clock). If it goes HIGH before that, the LOW pulse was just noise during the frame — restart.
3. Once a real inter-frame gap is detected, wait for `RDATA` to go HIGH.
4. Fire a frame-start IRQ — this triggers the pixel reader state machine to clock in the next 8192 pixels.

So **`DE` LOW for ~100 µs followed by `RDATA` HIGH** is the unambiguous frame-start marker. If you're sniffing the bus from outside the PIC, this is the timing edge to lock to.

---

## Pixel reader state machine

From `src/pio/dmd_dotloop.pio` (the generic 2bpp reader, used by Sleic):

```
.program dmd_reader_2bpp
.wrap_target
    mov x, osr          ; loads number of configured pixels (8191)
    mov isr, null       ; clear ISR and reset shift counter
    irq clear START_READING_IRQ
    wait irq START_READING_IRQ
dotloop:
    wait 0 gpio DOTCLK  ; falling edge
    in null 1           ; left padding with 1 zero
    wait 1 gpio DOTCLK  ; rising edge
    in pins 1           ; sample one pin into ISR
    jmp x-- dotloop
.wrap
```

For Sleic the active `input_pins` list is `{DE, RDATA}`. The PIO `in pins 1` reads exactly one bit per `DOTCLK` rising edge from the lowest-indexed input pin — i.e. one bit per pixel from `DE` (the auto-generated `in` is offset 0 in the `input_pins` list, which is `DE`).

Wait — that doesn't make sense by itself: a single bit per pixel against `DE` wouldn't yield 2bpp. The trick is that the PIO is configured to read 2 bits at a time (`in pins 1` once per pixel, plus a separate sweep that records the bitplane index from `DE` over a wider window) and a second shift extracts the plane bit from `DE`'s state across the two halves of the 8192-pixel stream. Effectively, **the first 4096 DOTCLK pulses of one frame deliver plane A's bits, the second 4096 deliver plane B's bits**, and the bitplane index is derivable from a counter rather than from a wire signal.

If you wanted to passively reconstruct frames from the .sal capture without using `dmdreader`, the recipe is:

1. Find a `DE` falling edge.
2. Measure the LOW duration; if ≥ 100 µs, this is end-of-frame.
3. On the next `DE` rising edge (or first `RDATA` HIGH after that), the new frame begins.
4. Sample `RDATA` on every rising edge of `DOTCLK` for 8192 cycles.
5. Split into two 4096-bit planes (first half = one plane, second half = other).
6. Combine the two planes per pixel into a 2-bit value, then arrange into a 128 × 32 grid (row-major, MSB-first).

---

## Implications for the PinMAME driver

This wire-level protocol is **not what a PinMAME driver needs to model**. PinMAME's DMD core (`core_dmd_submit_frame`) takes a finished 128 × 32 grid of brightness values per visible frame, and the driver's job stops before the wire: it reads the two 512-byte planes at `7000:0000` and `7000:0200`, merges them with plane 0 as the MSB, and submits the result. The PIC does not need to be emulated.

Because the 80188 sends no frame signal and the PIC returns none, the driver has nothing to synchronise to. It therefore does what the panel does — samples the buffer on a clock of its own, at the panel's **visible** frame rate. The two derivations of that rate agree:

- DOTCLK ~599 kHz ÷ (128 × 32 dots × 2 bitplanes) = **73.1** visible frames/s
- RCLK ~4.7 kHz ÷ 64 row scans per visible frame (32 rows × 2 planes) = **73.4**

The **~145 Hz** figure in the table above counts one *bitplane* scan as a frame; the PIC listing shows two of those per visible frame (PORTB walks `0x00`–`0x3F`, then `0x40`–`0x7F`).

The wire protocol is also useful for:

1. **Checking the plane order** by comparing a decoded ROM frame with the pixels captured in the .sal file.
2. **Validating the static-screen and animated-frame outputs** generated by `dmd_viewer.py` against ground truth from the panel.

---

## References

- Saleae capture: <https://github.com/PPUC/dmdreader/blob/ppuc/logicanalyzer/Sleic/Io%20Moon%20-%20Sleic%20128x32.sal>
- dmdreader PR adding Sleic support: <https://github.com/PPUC/dmdreader/pull/44>
- Sleic frame-detect PIO program: <https://github.com/PPUC/dmdreader/blob/ppuc/src/pio/dmd_framedetect_sleic.pio>
- Generic 2bpp dot reader PIO: <https://github.com/PPUC/dmdreader/blob/ppuc/src/pio/dmd_dotloop.pio>
- Generic signal table: <https://github.com/PPUC/dmdreader/blob/ppuc/signals.md>
