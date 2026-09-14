# DMD Graphics System

[← Back to main README](../README.md)

## Display Specifications

| Property | Value |
|----------|-------|
| Panel | 128 × 32 gas plasma dot matrix (board `011-022`) |
| Color depth | 2-bit (4 brightness levels, time-multiplexed) |
| Bitplanes | 2 (combined for 4 shades) |
| Display coprocessor | **Microchip PIC 16C57-HS/P** at IC23 on the CPU 16-bit board (`011-029A`) |
| Display buffer | `7000:0000`–`7000:03FF` in the 80188's address space (MCS3) |
| Panel power supply | 95 V AC / 58 V AC (connectors TW3–TW6, board `011-023`) |

> The PIC at IC23 is the DMD rasterizer, and it is a **free-running** one: it has
> no command interface, samples no data port, and exchanges no byte with the
> 80188 in either direction. It walks the video-RAM address over the 1 KB display
> buffer and sequences the panel's row/latch/frame strobes; the panel simply shows
> whatever stands in that buffer when the raster reaches it. Its 150 programmed
> words are disassembled in
> [`../asm/pic16c57_annotated.asm`](../asm/pic16c57_annotated.asm). The service
> manual (section 7.2.1 / page 92) describes it as "ayudado en las funciones del
> display por otro de 8 bits PIC 16C54HS"; the part actually fitted, and dumped,
> is a PIC16C57-HS/P.

---

## The frame pipeline

The 80188 composes every frame in its own work RAM and ends with a plain copy
into the 1 KB display buffer at segment `7000`, which is all the panel ever sees.
Everything is 128×32 two-plane: 16 bytes per row × 32 rows = 512 bytes per plane.
This is finding **F13** of [`findings.md`](../asm/baseline-2026-09/findings.md).

```
4000:0000-01FF  sprite / foreground plane 0   \ cleared by sub_F00C4
4000:0200-03FF  sprite / foreground plane 1   /
4000:0400-05FF  mask, one plane                 (0xFF = pass-all)
4000:0600-07FF  background plane 0            \ where the animation loader lands its frames
4000:0800-09FF  background plane 1            /
4000:0A00-0BFF  composite plane 0             \ the blit source
4000:0C00-0DFF  composite plane 1             /
7000:0000-01FF  display plane 0               \ what the PIC rasters
7000:0200-03FF  display plane 1               /
```

**Composite** (`sub_F08A5`) computes `(background AND mask) OR sprite` for both
planes, 32 rows × 16 bytes. **Blit** (`sub_F08EB`) copies `4000:0C00` → `7000:0200`
and `4000:0A00` → `7000:0000`. The two are the alternating branches of the INT0
ISR at `D000:0343` — `[4000:1142]` toggles on entry, the even branch blits and
dispatches animation, the odd branch composites and ticks the FM player — so the
display buffer is refreshed at INT0/2.

**There is no frame strobe and no double buffering.** PCS4 `0xA0200` bit 3 — the
one candidate for a "swap buffers" pulse — is written exactly once in the entire
ROM, by `pcs4_bit3_strobe` `D00FA`, called only from `boot_init`. The PIC is a
free-running raster with no command interface, so it displays whatever stands in
`7000:0000`–`03FF` at the moment it scans it. A sample can therefore catch a blit
in progress and show one plane a frame ahead of the other; the real panel has the
same race for the same reason.

**Nothing in this path inverts.** The firmware ANDs, ORs and copies these bytes
and never NOTs or XORs them.

The registers the 80188 writes in segment `A000h` are **not** DMD registers:
`A000h` is the peripheral chip-select block, carrying the J1 byte-port latches
and both sound chips. The boot values `sub_D00B9` writes there — PCS0 `0x28`,
PCS6 `0x80`, PCS4 `0x07` — are the idle levels of those, not display controls.
See [`80188_config.md`](80188_config.md).

Two more routines in the F-segment clear the display buffer at boot:
`0xF0113` and `0xF0124` (`ES=7000h, DI=0, CX=0x400, AL=0; REP STOSB`), whatever
names the older generated listings gave them.

---

## Animated Frame Format

The ROM contains **400 animated frames** stored sequentially in ROM2 (`0x00000`–`0x6F974`). Each frame is 1030 bytes:

### Header (6 bytes)

```
Bytes 0-1: 0x0020  — rows (32)
Bytes 2-3: 0x0010  — bytes per row (16 = 128 pixels / 8)
Bytes 4-5: 0x0200  — plane stride (512 = one plane)
```

Three little-endian words, and they are exactly the fields `anim_stream_open`
(`0xF0348`) reads into `[4000:1102]`, `[1104]` and `[1106]` before
`sub_F036D` copies the two planes into the background buffers. Every populated
64 KB page of `V1 3_02.bin` begins with the identical triple.

### Data (1024 bytes)

Two consecutive 512-byte bitplanes:

```
Offset 0x006 – 0x205: Plane 0 (512 bytes: 16 bytes/row × 32 rows)
Offset 0x206 – 0x405: Plane 1 (512 bytes: 16 bytes/row × 32 rows)
```

### Pixel Encoding

Each pixel value is computed from the two bitplanes:

```
pixel_value = (2 × plane0_bit) + plane1_bit
```

| Value | Plane 0 (MSB ×2) | Plane 1 (LSB ×1) | Appearance |
|-------|------------------|-------------------|------------|
| 0 | 0 | 0 | Off (black) |
| 1 | 0 | 1 | Dim |
| 2 | 1 | 0 | Medium |
| 3 | 1 | 1 | Bright (full) |

**Plane 0 is the MSB**, and three independent things say so:

1. The PIC's own raster program holds each row of the plane it scans first for
   **200** delay iterations against **30** for the second — a 6.7:1 duty ratio —
   and it scans `7000:0000`–`01FF` first
   ([`../asm/pic16c57_annotated.asm`](../asm/pic16c57_annotated.asm)).
2. The PPUC `dmdreader` Sleic decoder shifts wire plane 0 left by one and wire
   plane 1 by zero (see [`dmd_wire_protocol.md`](dmd_wire_protocol.md)), and it
   is confirmed working on a real IO Moon machine.
3. Rendered frames: the moon disc's anti-aliased edge ramps level 1 → 2 → 3 from
   outside in, and the service menu draws unselected items in plane 1 alone and
   the selected item in both planes — dim against bright only with plane 1 as the
   LSB.

![Plane-order comparison](../images/dmd_plane_order_comparison.png)

### Bit polarity: a set bit is lit

A `1` bit is a **lit** pixel, throughout: in the ROM frame data, in the work-RAM
pipeline, in the display buffer and on the wire. The firmware applies no
inversion anywhere between the graphics ROM and `7000:0000`, and rendering ROM
frames with `1` = lit produces coherent images (frame 120 of `V1 3_02.bin`, for
instance, is a clean lunar disc), while the inverted reading produces a
full-screen lit rectangle with a hole in it.

> ⚠️ `scripts/dmd_viewer.py` does not use this convention by default. It inverts
> (`--no-invert` turns that off) and it weights the planes the other way round —
> `decode_frame()` computes `p0_bit + 2 * p1_bit` where the panel computes
> `2 * p0_bit + p1_bit`. The two differences do not cancel: composed, the default
> output has levels **0 and 3 swapped** (off renders as full-bright and vice
> versa), with levels 1 and 2 passing through. See
> [`dmd_viewer.md`](dmd_viewer.md) for the truth table. Its static-screen and
> font rendering is single-bitplane and unaffected.

---

## DMD Signal Decoding

The DMD data signals are encoded such that a 2-bit-per-pixel frame can be perceived. The first plane, representing the most significant bit (MSB), is displayed for approximately 6.25 ms. The second plane, representing the least significant bit (LSB), is then displayed for approximately 1.87 ms.

Interestingly, the LSB plane contains an additional “garbage” row of data at row 33. Since the display itself only has 32 rows, this extra row is ignored by the hardware and effectively discarded.

After the LSB plane is processed and the garbage row is thrown out, the display remains blank for roughly 5.64 ms before the next frame begins, again starting with the MSB plane.

Based on these observations, several conclusions can be drawn. All timing and signal information described above was obtained using a logic analyzer capture, available [here.](https://github.com/PPUC/dmdreader/tree/ppuc/logicanalyzer/Sleic)


### DMD Signal Summary

| FPS          | Pattern                 | Brightness split   |
|--------------|-------------------------|--------------------|
| 72 (13.85ms) | 2 plane MSB + LSB merge | 0%, 23%, 76%, 100% |

Interesting notes:

- Sleic has an unusual brightness split. Other manufacturers such as Bally / Williams and Data East / Sega implement 2bpp brightness levels as `0%, 33%, 67%, 100%`, which is far more logical.
- Only one other system appears to handle DMD signaling in a similar way: the Spike 1 system introduced in 2015. Unlike Sleic, which combines two planes to produce a 2bpp frame, the Spike 1 system combines four planes to produce a 4bpp frame. 
   - Important to mention here is that Sleic handles the MSB plane first, Spike handles LSB first. So Sleic is unique at that.
- Very unusual compared to the other manufacturers: Sleic appears to blank the DMD after every MSB + LSB cycle (approximately 8.12 ms) for an additional ~5.64 ms, resulting in a total frame time of roughly 13.85 ms. During this 5.64 ms interval, no activity is present on any signal line. In theory, this idle period could have been used to achieve a higher refresh rate, but Sleic clearly chose not to do so. 

---

## Static Screens

**274 static screens** are stored in ROM1 (`0x82000`–`0xC0000`). These are used for text displays: game messages, score labels, player names, etc.

### Format

Static screens are stored in **bilingual pairs** sharing a single header:

```
Header (6 bytes) → English bitmap (512 bytes) → Spanish bitmap (512 bytes)
```

Each bitmap uses **1 bitplane** only (on/off, no brightness levels), with a set bit lit — the same polarity as the animated frames, and as everything else in the display path.

Which of the two paired bitmaps is shown is selected by the language byte
`[4000:1001]`: **`== 5` ⇒ Spanish (second bitmap), any other value ⇒ English (first
bitmap)** — the default is `0x04` (English). This polarity is DMD-verified; see
[`iomoon_language_and_service_menu.md`](iomoon_language_and_service_menu.md).

### Content Examples

The identified static screens include game messages in both Spanish and English, such as score labels, mode indicators (MOONLIGHT, SUNSHINE, STARWAY), bonus displays, and system messages (TILT, credits).

---

## Scrolling Credits

The credits animation data occupies the range `0xA9D00`–`0xAC000` of the combined
`ROM2 + ROM1` image (= ROM1 file offset `0x29D00`–`0x2C000`). Unlike the static screens, credits are stored as a **continuous vertical strip** that scrolls upward during the attract mode credits sequence.

The `dmd_viewer.py` script extracts **42 individual text elements** from this strip by detecting content boundaries (rows with at least some lit pixels, grouped into elements with a minimum height of 5 rows).

The credits screens identify the development team:

- **Software**: Luis J. Gosálbez, Toñi Hernandez
- **Hardware**: Santos Aranda, Luis J. Gosálbez
- **Electromechanics**: Toñi Hernandez, J. Manuel Vázquez

---

## Font System

The DMD font table starts at ROM1 file offset `0x20000` (combined-image
`0xA0000`), inside the LMCS-resident low 256 KB (F1). It is a table of
variable-size entries with no fixed stride; a reader has to walk it.

### Font Entry Structure

Each entry is a 6-byte header followed by **three** bitmap blocks, not two:

```
Header: [height, 0x00, width, 0x00, len16_lo, len16_hi]
Data:   [len16 bytes] plane 0
        [len16 bytes] plane 1
        [len16 bytes] mask
```

`len16` is a **16-bit** field (bytes 4-5, little-endian), equal to
`height*width`, not a byte: the entry at ROM1 `0x22C2E` is `height=0x20,
width=0x10`, length bytes `00 02` = `0x0200` = 512 = 32*16, a full-screen
128x32 image, and a byte-wide read of byte 4 alone misreads that length as 0.

`width` is bytes per row, not pixels wide: the on-screen text face is one
byte (8 px) wide, but the table also holds two-byte-wide entries, so glyphs
are not uniformly 8 px wide. Entry stride is `6 + 3*len16` and varies entry
to entry — there is no fixed stride to index by.

The third block is a mask, not a second copy of the bitmap: F13's DMD
composite is `(background AND mask) OR sprite`, and a glyph's mask reads as
the complement of its own cell (`0x07` for a left-aligned glyph, `0xE0` for a
right-aligned one).

Walking from `0x20000` with one byte per row (`width == 1`), 162 consecutive
entries decode before the first two-byte-wide entry, at file offset
`0x218B4` (combined-image `0xA18B4`). Heights seen in that run: 12 px (53
entries), 9 px (52), 8 px (34), 18 px (21), 15 px (2). There is no 10 px size
and no 7-segment-style face at this offset. The table runs 224 entries in
total, ROM1 `0x20000`-`0x22C2E` (combined `0xA0000`-`0xA2C2E`), and is
followed directly by the full-screen image at `0x22C2E` described above.

### Full-screen images outside the walked table use the same entry format (F20)

The image at `0x22C2E` is not the only one. A second, separate `[height=32,
0x00, width=16, 0x00, len16=0x0200]` header sits at ROM1 `0x24EA4` — well
past the walked table's own end and not reached by walking from `0x20000`,
confirmed by re-deriving its data offsets from the header alone and checking
them independently: plane 0 at `0x24EAA` (header `+6`), plane 1 at `0x250AA`
(`+len16`), each row `width=16` bytes apart, so row 10 of plane 0 is
`0x24EAA + 10*16 = 0x24F4A` and row 10 of plane 1 is `0x250AA + 10*16 =
0x2514A` — both land exactly on the bytes that reproduce a captured frame's
row 10, checked below.

Reconstructing all 32 rows from this header's two planes (`level =
2*plane0_bit + plane1_bit`, F13's weighting) matches a real captured DMD
frame **byte-for-byte, all 32 rows** —
`dmd/en/screens/0023-attract/repr.txt`, large multi-level shaded text (the
same shaded style as the score glyphs, not the flat `height=9`/`height=12`
text faces). The identical bytes are not a one-off: the same content, or a
mid-redraw partial of it (rows already drawn matching exactly, rows not yet
reached still blank), turns up as the settled or in-progress content of
three deep service-menu leaf records in `dmd/en/screens.csv` — `svc-33`
(SEND-REC TEST), `svc-36` (LIGHT TEST 2) and `svc-37` (LIGHT TEST 3) — and
is absent from every other ROM chip in the set (`v1_3_02.bin` through
`v1_3_05.bin`, byte-searched directly for the plane-0 block).

**This is a third, distinct category from either a decoded string or an
undecoded one: a screen whose content is a picture, composed once at ROM
build time and blitted whole, not text assembled from character codes at
run time.** No font-based matcher — this decoder or any other — can recover
a string from a page drawn this way, because the pixels are not glyphs; the
mechanism is the same one the walked table's own entries use (identical
6-byte header, identical three-plane layout), just invoked on a "glyph"
that happens to be an entire panel instead of one character. Which of the
service-menu tree's own catalogued strings this specific picture depicts is
not established — the picture has not been read letter by letter — only
that it is a picture, on these three records, and not glyph-composed text.

What is still open: whether every deep service-menu leaf record renders
this way (only three are confirmed; `svc-24`, SOLENOID TEST, shows no new
content of any kind across five occurrences even after a 25x longer dwell —
`dmd/README.md`'s own Open items — so its mechanism is unresolved, not
assumed to be this one or any other); why the identical bytes also appear
during ordinary attract-mode play (`0023-attract`) — reuse of one baked
asset across two unrelated screens is the simplest explanation and is
consistent with everything checked so far, but is not independently
confirmed; and whether the *other* full-screen image already noted above,
at `0x22C2E`, is likewise reused anywhere in the captured corpus (not
checked). What would settle the first question: the same row-by-row
byte comparison used here, run against a captured frame from each of the
remaining leaf records in turn.

### The in-play PLAYER/BALL HUD is a pointer pool of whole words, not a walked table

The small, single-pixel-stroke font `PLAYER 1`/`BALL 1` render in during
gameplay is not in the walked table above and is not reached by code+offset
the way every other face here is. It is five whole-word bitmaps, one
language pair each, pulled by hard-coded far pointers out of a 620-byte
literal-pointer pool at flat `0xF5183`-`0xF53EB` (620 bytes, 155 four-byte
entries, terminated by a null entry at `0xF53EF` then zero padding) — most
of the pool resolves to unrelated assets (further full-screen pictures in
F20's own format, the walked table's own entries reached a second way,
work-RAM addresses) and only a five-entry English run plus its Spanish
counterparts matter here:

| pointer | shape | renders as | drawn by |
|---|---|---|---|
| `CS:0522F` | h=8, w=3 | `BALL` | `sub_F0D70` |
| `CS:05233` | h=8, w=5 | `EXTRA BALL` | `sub_F0DB2`/`F0DDA`/`F0E1A` (flash pair) |
| `CS:05237` | h=16, w=6 | `INSERT` / `COIN` | `sub_F0E60`/`F0E85`/`F0EAB` |
| `CS:0523B` | h=8, w=7 | `PLAYERS` | `sub_F0FFA`/`F1054` |
| `CS:0523F` | h=8, w=5 | `PLAYER` | `sub_F108E`/`F10E5` |

Each entry is the walked table's own `[h,0x00,w,0x00,len16]` header+3-plane
format, just holding a whole rendered phrase instead of one character —
confirmed by segmenting each bitmap on its own blank columns and reading the
letters directly off the pixels (plane 0 alone, the same single-plane
convention `glyph_bitmaps` already uses; plane 1 and the mask, present in
every entry, carry nothing legible). `PLAYER`/`PLAYERS` are each followed by
a player/ball-number digit from a **third**, independent digit table
(`CS:0531B`, `h=8, w=1`, stride `0x1E`, the same code+offset convention as
the walked table's own faces, just at a base this decoder had not walked
from before) — work-RAM byte `413C:00D7` (after `PLAYERS`) or `413C:00FE`
(after `PLAYER`) multiplied by the stride and added to the base.

Spanish counterparts sit in the same pool at country-switched call sites
(`CMP [4137:1001],5`, F11), confirmed from the actual `LES SI,CS:xxxx`
operand at each site rather than assumed from a fixed offset: the first
three pair at `+0x134` (`BOLA`, `BOLA EXTRA`, `INTRODUCIR`/`MONEDA`), but
`PLAYERS`/`PLAYER` pair with `JUGADORES`/`JUGADOR` at `+0x138` instead — one
entry further apart than the first three, not the same fixed offset applied
uniformly.

`scripts/iomoon_strings.py`'s `HUD_MESSAGE_POINTERS`/`hud_message_bitmaps()`
and `PLAYER_NUM_BASE`/`player_number_bitmaps()` read this pool; the corpus
splitter matches each whole-word bitmap directly (`scripts/
dmd_dump_split.py`'s `_scan_words`), since these entries vary in both height
and width and are not per-character cells.

### The in-play score digit table is headerless, and each digit is drawn from two glyph halves

The large, shaded in-play score (`2.452.230`-style numbers, legible by eye
in a gameplay capture) is drawn from a table the walked table's own
`_font_entries` never reaches, because it carries no header at all. Pointer
`CS:052BB` resolves to flat `0x29154`; `sub_F0907` (the decimal-string
renderer behind the in-play score, dispatched by work-RAM mode byte
`413C:00EA`) indexes it by digit value with `MUL DX,0x6C` (108) — read
directly from `sub_F0907`'s own draw loop, not assumed from the byte count:
`108 = 3 planes x 12 rows x 3 bytes` is a plausible guess from the stride
alone, and it is wrong (rendering it that way produces noise, not digits).

Each 108-byte digit slot holds two adjacent 54-byte halves, and `sub_F0C7B`
— the routine every digit call site uses — settles their shape directly: a
fixed 18 rows (`MOV BP,0x12` / `MOV CX,0x12`, hard-coded in the routine, not
read from any header) of one byte (8 px) each, three such planes (plane 0,
plane 1, mask) per half. `sub_F0907` calls `sub_F0C7B` once at `DI`, then
again one byte-column to the left (`DEC DI`) — and the second call's source
is not the first call's data replayed (`sub_F0C7B` advances its own source
pointer by 54 bytes internally), so the two halves are the left and right
8 px columns of one 16 px-wide, 18-row glyph, not a blurred duplicate of the
same image. Read that way (both halves, `level = 2*plane0_bit + plane1_bit`,
F13's own weighting, the mask unused — every digit comes out using only
level 0 and level 3, with no stored level-1 "interior" to recover by reading
it), digit `2`'s bitmap reproduces
`dmd/en/screens/5132-score-ball-3-in-play/repr.txt` byte-for-byte at
row 0, column 8 — the ROM's own data matching a real captured frame exactly,
not merely a plausible-looking render.

Byte value `1` is intercepted as a decimal-point sentinel *before* the
multiply (`CS:052C3`, a separate always-single-call pointer that happens to
physically sit where "digit 1" would fall under the stride formula but is
never reached that way), so digit `1` is not reachable through this table at
all and is left undecoded rather than guessed at. A second, alternating
drawing path exists (`CS:052BF`, toggled by work-RAM flag `413C:00CD` for a
digit immediately following a decimal point, drawn by a different
compositing primitive — `sub_F0C49`, OR then AND, not plain overwrite) and
is not modelled by the decoder; only the `CS:052BB` path above is, since
that is the one confirmed against a real frame.

Consecutive digits in a real number overlap on screen: confirmed digit `2`
sits at its full, unclipped 16 px width because it is the leftmost (most
significant, last-drawn — `sub_F0907` scans its source right to left) digit
in its own number; a plain-overwrite draw order means an earlier-drawn
digit's own columns get overwritten by whatever draws after it. An
exact-bitmap matcher only recovers the digits that happen to survive a given
frame's own draw order, not every digit of a longer number — see
`dmd/README.md` for the measured effect on corpus recovery, and its Open
items for what is not yet resolved (digit `1`, the `CS:052BF` alternate
path, and the overlap itself).

`scripts/iomoon_strings.py`'s `SCORE_DIGIT_BASE`/`score_digit_bitmaps()`
reads this table.

### Character Mapping

The table's entry index is **not** the glyph code: entry 0 renders a
different, narrower (8 px tall) face, not the digit `0`.

The on-screen text is the `height=9`, one-byte-wide face. Its entries begin
at table index 23 — pinned by matching a captured frame's `W` byte-for-byte
against table entry 57, and `W` is glyph code `0x22` (34): `table index =
glyph code + 23`.

A second complete face exists at `height=12`, entries **75-127** (53
entries), immediately after the `height=9` run. Its offset is confirmed
three independent ways: entry 75 renders a clean `0` (so code 0 = entry 75);
entry 119 is a 2x2 dot on the baseline and `119-75=44=0x2C`, exactly the
period pinned independently off the `height=9` face; and the attract
high-score screen decodes as `300.000.000` in this face beside `S.MOONLIGHT`
in `height=9` (`dmd/en/screens/0051-attract/repr.txt` in the English
corpus). Two of its glyphs render the identical bitmap — code `0` and code
`0x1A` (`O`) — so the face has 37 distinct bitmaps across its 46 defined
codes, not 46: the two codes are genuinely indistinguishable by pixels alone
in this face, not a decoder gap. `iomoon_strings.GLYPHS` resolves the
collision by iterating digits before letters, so `'0'` always wins — a
`height=12` decode reading `INSCRIPTI0N` for `INSCRIPTION` (`dmd/README.md`,
the record-inscription item) is this same face fact showing up in the
`text` column, not a separate matcher bug. The `height=9` face has no such
collision: its own `0` and `O` glyphs are two genuinely different bitmaps
(checked directly, not assumed from this face's own case), so `text`
segments read through `height=9` never need this caveat.

Past the initial one-byte-wide run, at file offset `0x218B4`, sit 62 further
entries of mixed shape: 21 of `height=23, width=2` (16 px, table index
162-182), 21 of `(12, 1)` (183-203), 20 of `(16, 1)` (204-223). The `(23,
2)` set is the large price/score digits, and it needs no offset pinned
beyond its own start index: entry 162 renders a 16x23 `0`, 163 a `1`, 164 a
`2`. Entries 172-181 are the same ten digits with one small mark added at
bottom right, a decimal point, consistent with a Spanish-market machine's
peseta-style `NNN.NNN` pricing. Entry 182 is a colon: two of the h=9 face's
own colon blocks, scaled to this face's width.

**This face is SHADED, not single-plane.** Every glyph is a bright (level 3)
outline around a mid-tone (level 1) interior, so it occupies both bitplanes
at once: reading plane 0 alone (as the `height=9` and `height=12` text
faces correctly do — they are genuinely single-plane) throws away the
interior/outline distinction and can never exact-match a real captured
frame, whose four pixel levels reflect both planes. `iomoon_strings.
score_glyph_bitmaps` reconstructs each glyph's per-pixel level as
`2*plane0_bit + plane1_bit` (F13's own weighting) and returns level strings
('0'-'3'), not bit strings, so a caller has to match against the frame's own
levels directly rather than a binarized lit/unlit reading — confirmed
against the mark added by the decimal-point entries, which spans a shaded
3x3 area (rows 19-21, columns 13-15) once both planes are read, not the
plane-0-only 2x2 box a single-bitplane reading finds. Despite the fix, no
captured scene in the committed English corpus (`dmd/en/`) shows this
specific face decoding a real in-play number: scanning all 21 of its labels
against all 27,712 raw frames of `dmd/en/iomoont.txt.gz` finds zero exact
matches, and the closest approximate match anywhere in a gameplay-adjacent
frame differs in 120 of the glyph's 368 pixels — no resemblance, not a near
miss.

The 21-entry `(12, 1)` block immediately after it (table index 183-203) is
the same 21-label layout at a smaller size, and it is confirmed against a
real frame: its digits 0-9 (183-192) and their decimal-point variants
(194-203) exact-match a run of digits at row 0 of
`dmd/en/screens/0287-ball-2-in-play/repr.txt`, decoding `3. 8.743`, and two
more `ball-*`/`drop-bank-*` scenes in the committed corpus (294, 298) decode
real digit runs the same way. Unlike the large face, every one of its
glyphs uses only level 0 and level 3 — plane 0 and plane 1 always agree, so
it renders at flat full brightness rather than shaded, even though the same
two-plane match key correctly reads it (a level string that happens to use
only two of its four possible values). Which gameplay quantity this face
displays (a bonus count, a lane multiplier, or something else — the digit
runs decoded so far are short and the scenes' own labels do not say) is not
established; see "Open items" below.

### Custom Text Encoding

The 80188 game code uses a **custom character encoding** for DMD text, not standard ASCII:

```
0x0A = space    0x0B = 'A'    0x0C = 'B'    0x0D = 'C'    0x0E = 'D'
0x0F = 'E'      0x10 = 'F'    0x11 = 'G'    0x12 = 'H'    0x13 = 'I'
0x14 = 'J'      0x15 = 'K'    0x16 = 'L'    0x17 = 'M'    0x18 = 'N'
0x19 = 'Ñ'      0x1A = 'O'    0x1B = 'P'    0x1C = 'Q'    0x1D = 'R'
0x1E = 'S'      0x1F = 'T'    0x20 = 'U'    0x21 = 'V'    0x22 = 'W'
0x23 = 'X'      0x24 = 'Y'    0x25 = 'Z'
0x26 = '+'      0x28 = '('    0x29 = ')'    0x2A = '/'
0x2B = ','      0x2C = '.'    0x2D = ';'    0x2E = ':'    0x2F = '-'
0x00 = terminator
```

`0x26`-`0x2F` are read off the h=9 face's own bitmaps (`glyph_bitmaps`, table
entry = code + 23), the same way entry 57 pinned the face itself against a
captured `W`. Read by eye: `0x26` is a vertical bar crossed by a horizontal
one -- a plus sign. `0x28`/`0x29` bulge toward the opening they curve
around, confirming them as `(` and `)`. `0x2A` is a single diagonal stroke,
upper right to lower left -- `/`. `0x2B` is a 2x2 block with a tail trailing
down-left -- a comma. `0x2C` is that same 2x2 block alone, on the baseline
-- a period. `0x2D` is two of that block stacked with a gap, plus a comma's
tail below the lower one -- a semicolon. `0x2E` is the same two stacked
blocks with no tail -- a colon. `0x2F` is a single one-row horizontal bar --
a hyphen.

`0x27`'s bitmap is left open: there is no gap between the bowl and the tail,
which a question mark requires — the shape is continuous through the middle
rows where a real `?` has a break before the dot. What it actually is isn't
settled from the bitmap alone; it would take a captured frame that shows
this code in use, or a string-pool entry that resolves to it, the way `W`
pinned the h=9 face itself. `iomoon_strings.py`'s `GLYPHS` leaves this code
unmapped rather than guess.

None of this touches any string decoded so far: scanning both `ENGLISH_POOL`
and `SPANISH_POOL` (which between them cover the contact table, F16, and the
menu tree, F14), the codes `>= 0x26` in use are `0x2F` (hyphen, 67 times —
every `- LABEL -` menu header uses two), `0x2C` (period, 46), `0x2E` (colon,
16), `0x2A` (slash, 3, e.g. `SOUND/VIDEO`) and `0x29` (close paren, 2, in a
line reading ` 2)`). `0x26`, `0x28`, `0x2B` and `0x2D` do not appear in
either pool at all, and `0x27` never appears anywhere. The bitmap-pinned
mappings above matter only to the DMD frame decoder, then, and only for a
screen that actually draws one of these marks (on the captures examined so
far, none does).

A **character mapping table** at ROM offset `0x809B0` (96 bytes) maps ASCII codes `0x20`–`0x7F` to glyph indices.

---

## Memory layout summary

Offsets into the **combined `ROM2 + ROM1`** image the tooling uses
(`cat "V1 3_02.bin" "V1 3_01.bin" > io_moon_combined.bin`), which is not the
80188's address space — see [`hardware_architecture.md`](hardware_architecture.md)
for the three windows the CPU actually sees.

```
0x00000 – 0x6F974 : ROM2: animated DMD frames (400 x 1030 bytes, seven 64 KB pages)
0x70000 – 0x7FFFF : ROM2 page 7, blank
0x80000 – 0x800FF : ROM1: the resident 80188 interrupt vector table
0x80100 – 0x808D3 : ROM1: service-menu records — 38 x 46-byte records twice over,
                    English at ROM1 offset 0x00100-0x007D3 and Spanish at
                    0x00D08-0x0013DB (80188 flat addresses, via LMCS)
0x808D4 – 0x809AF : ROM1: further tables in the LMCS window
0x809B0 – 0x80A0F : Character mapping table (ASCII -> glyph index)
0x82000 – 0xA0000 : Static screens (bilingual pairs)
0xA0000 – 0xA2C2E : Font glyph table, variable-stride entries, 224 of them
                    (see Font System)
0xA2C2E –         : A full-screen (128x32) image in the same header format,
                    immediately after the font table
0xA9D00 – 0xAC000 : Scrolling credits animation data
0xC0000 – 0xFFFFF : ROM1: 80188 program code (segments D000/E000/F000 + boot stub)
```

---

## Open items

### `CS:052BF` is a pitch-shifted duplicate, not a second drawing path — not wired into the decoder

`sub_F0907` (the in-play score renderer) alternates a digit between
`CS:052BB` and `CS:052BF` on *every* digit, not on a decimal-point
condition: the mode flag `413C:00CD` toggles after every plain digit
(`F09BB`/`F0A1F`) and holds only across a decimal point (`F09E1`/`F0A47`),
so digits strictly alternate tables — odd position `CS:052BB`, even
position `CS:052BF` — while a decimal point never changes which table is
next. `CS:052BF`'s own base resolves to `CS:052BB`'s base plus exactly ten
strides (`0x2958C` = `0x29154 + 10*0x6C`); read the same way (two 54-byte
halves, `level = 2*plane0_bit + plane1_bit`), its digits `0`/`2`-`9` are
**pixel-for-pixel the same shapes as `CS:052BB`'s, shifted 4 px left within
the 16 px cell** — confirmed by direct comparison, not assumed from the
stride arithmetic. `sub_F0C49` (the primitive `CS:052BF`'s first half uses,
OR-then-AND rather than plain overwrite) composites this shifted copy
against whatever the previous digit already drew, which is what lets
adjacent digits overlap by a consistent 4 px rather than needing the
firmware to bit-shift a single stored glyph at draw time — a rendering
optimization, not a visually distinct second font. **Not wired into the
decoder**: recognizing `CS:052BF`'s own shapes as additional bitmaps for
the same digit labels would recover some even-position digits the overlap
(below) currently drops, but doing so needs `_scan_face`'s single
bits-per-label assumption extended to multiple variants, which was not
attempted this round given the bounded expected gain against the
regression-testing cost of changing a function every other face also uses.

Digit `1` is confirmed unreachable through either table by the normal
digit-value multiply, in `sub_F0907`'s traced mode (work-RAM mode byte
`413C:00EA` = 1, the one confirmed as the in-play score path) — byte value
`1` is intercepted as the decimal-point sentinel before the multiply in
*both* the `CS:052BB` and the `CS:052BF` branch. `413C:00EA` dispatches five
other modes (0, 2, 3, 4, 5) through the same renderer, each its own
routine, not traced this round — whether digit `1` is drawn by any of them,
through some other mechanism entirely, is open. What would settle it:
tracing those five routines.

### Consecutive in-play score digits overlap, limiting recovery

`sub_F0907` draws digits right to left (least significant first), plain
overwrite, and confirmed digit `2` sits at its full 16 px width only because
it is the *last*-drawn (most significant, leftmost) digit of its own number
— an earlier-drawn digit's own columns get overwritten by whatever the
routine draws after it. An exact-bitmap matcher recovers only the digits
that happen to survive a given frame's own draw order, which in practice is
often just one digit of a longer score. See `dmd/README.md` for the
measured effect on corpus recovery.

Two further faces from the same font table are walked but not pinned to any
code offset or confirmed against a captured frame: `height=16` (20 entries,
table index 204-223, immediately after the small digit face) and `height=18`
(21 entries, within the initial one-byte-wide run). A two-plane search of
both across every `attract`- and `ball`-labelled scene in the English corpus
turns up only a coincidental partial match of a sparse two-dot glyph against
unrelated animated content, not a genuine decode. What would settle either
open question: a capture with a cleaner instant (a frame taken right after a
score change, before the gameplay background animation resumes), a
disassembly trace of the routine that draws the main score, or pinning the
`height=16`/`height=18` faces the way `height=12`'s text face was pinned
above.
