# IC23 — PIC16C57 DMD raster coprocessor dump

[← Back to ROM index](../README.md) · [Chip background](../../docs/chips_to_dump.md)

`PIC16F57-DIP28-1D05-20260815.bin` is the recovered program memory of **IC23**,
the Microchip **PIC16C57-HS/P** DMD raster coprocessor on the IO Moon 16-bit
board (011-029A).

## Provenance

The original OTP chip is **code-protected** (security fuse blown). A direct
read on a universal programmer (2026-06-28) returned only scrambled data. The
chip was sent to a commercial chip-recovery lab, which defeated the code
protection; this dump was received on 2026-09-02. The lab adjusted the code
for the pin-compatible flash-based **PIC16F57** (same 12-bit core, identical
instruction set) — a 16F57 programmed with this image has been **confirmed
working in the real machine**.

## File format

8192 bytes = 4096 little-endian 16-bit slots:

| Slots (word addr) | Content |
|-------------------|---------|
| `0x000–0x7FF`     | 2048 × 12-bit program words (upper 4 bits of each slot are 0; blank/erased words read `0x0FFF`) |
| `0x800–0x803`     | Four user-ID words (`0x00F` each) |
| `0x804–0xFFF`     | Zero padding from the programmer image |

## Verification

- Every one of the 2048 program words fits in 12 bits.
- Only **150 words are programmed**: contiguous code at `0x000–0x094` plus the
  mandatory reset-vector `GOTO 0x000` (`0xA00`) at `0x7FF`; the rest is erased
  fill (`0xFFF`).
- All 150 words decode to valid PIC16C5x 12-bit instructions; all 20
  `GOTO` targets land inside the programmed region; no `CALL`/`RETLW` used.
- The code structure matches the chip's known DMD-raster role: `OPTION = 0x28`
  (TMR0 counting external T0CKI pulses), ports A/B as outputs, an endless
  refresh loop with two nearly identical field halves, PORTA/PORTC bits
  toggled as raster clock/latch/strobe lines.

## Authenticated against the physical chip

A code-protected 16C5x does not read back as all-`0xFFF` — it returns, for
every 12-bit word, the **XOR of its three nibbles** (`read = n2 ^ n1 ^ n0`, a
lossy 12-bit → 4-bit compression). The scrambled 2026-06-28 read of the locked
original chip matches this transform of the lab dump for **all 2048 words**
(code, blanks, and ID words alike), which authenticates the dump against this
exact physical chip. The same cross-check lets anyone with a similar locked
chip and a ~$50 programmer verify that this published dump matches their chip
revision — without any lab work.

Note the scrambling also means the real code can **never** be reconstructed
from a protected read alone: 256 candidate words map to every read-back
nibble.

## Related material

- Annotated disassembly: [`../../asm/pic16c57_annotated.asm`](../../asm/pic16c57_annotated.asm)
  (cross-verified with gpdasm, MAME unidasm, and a project decoder — all three
  agree on every word)
- How the protection works and how the lab likely cracked it:
  [`../../research/pic16c57_protection_analysis.md`](../../research/pic16c57_protection_analysis.md)

## Checksum

```
a244f2d8060c2d92a814e20bdd55ecfe  PIC16F57-DIP28-1D05-20260815.bin
```
