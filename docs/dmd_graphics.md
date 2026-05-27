# DMD Graphics System

[← Back to main README](../README.md)

## Display Specifications

| Property | Value |
|----------|-------|
| Panel | 128 × 32 gas plasma dot matrix (board `011-022`) |
| Color depth | 2-bit (4 brightness levels, time-multiplexed) |
| Bitplanes | 2 (combined for 4 shades) |
| Display coprocessor | **Microchip PIC 16C54HS** at IC23 on the CPU 16-bit board (`011-029`) |
| Controller register window | Memory-mapped from the 80188 at segment `A000h` |
| Panel power supply | 95 V AC / 58 V AC (connectors TW3–TW6, board `011-023`) |

> The PIC 16C54HS is the actual DMD rasterizer: the 80188 writes frame buffers and control registers to segment `A000h`, and the PIC reads those, generates the scan/strobe timing the plasma panel needs, and clocks pixel data out. The MAME upstream driver header lists this PIC as "optional"; on IO Moon (service manual section 7.2.1 / page 92) it is **required** and labelled "ayudado en las funciones del display por otro de 8 bits PIC 16C54HS". The PIC's internal firmware is undumped.

---

## DMD Controller Registers

| Register | Address | Value | Function |
|----------|---------|-------|----------|
| Control 1 | `A000:0000` | `0x28` | Display on |
| Control 2 | `A000:0080` | — | Secondary control |
| Mode | `A000:0200` | bit 3 | Strobe signal |
| Enable | `A000:0300` | `0x80` | Display enable |

---

## Animated Frame Format

The ROM contains **400 animated frames** stored sequentially in ROM2 (`0x00000`–`0x6F974`). Each frame is 1030 bytes:

### Header (6 bytes)

```
Byte 0: 0x20  — Height (32 pixels)
Byte 1: 0x00  — Reserved
Byte 2: 0x10  — Width in bytes (16 = 128 pixels ÷ 8)
Byte 3: 0x00  — Reserved
Byte 4: 0x00  — Reserved
Byte 5: 0x02  — Number of bitplanes (2)
```

### Data (1024 bytes)

Two consecutive 512-byte bitplanes:

```
Offset 0x006 – 0x205: Plane 0 (512 bytes: 16 bytes/row × 32 rows)
Offset 0x206 – 0x405: Plane 1 (512 bytes: 16 bytes/row × 32 rows)
```

### Pixel Encoding

Each pixel value is computed from the two bitplanes:

```
pixel_value = plane0_bit + (2 × plane1_bit)
```

| Value | Plane 0 | Plane 1 | Appearance |
|-------|---------|---------|------------|
| 0 | 0 | 0 | Off (black) |
| 1 | 1 | 0 | Dim |
| 2 | 0 | 1 | Medium |
| 3 | 1 | 1 | Bright (full) |

### Bit Inversion

Frame data is stored with **inverted bits**: a `0` bit in the ROM means the pixel is **lit**, and a `1` bit means it is **off**. The `dmd_viewer.py` script inverts by default for correct display.

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

Each bitmap uses **1 bitplane** only (on/off, no brightness levels). Static screens are **not** bit-inverted (unlike animated frames).

### Content Examples

The identified static screens include game messages in both Spanish and English, such as score labels, mode indicators (MOONLIGHT, SUNSHINE, STARWAY), bonus displays, and system messages (TILT, credits).

---

## Scrolling Credits

The credits animation data occupies the range `0xA9D00`–`0xAC000`. Unlike the static screens, credits are stored as a **continuous vertical strip** that scrolls upward during the attract mode credits sequence.

The `dmd_viewer.py` script extracts **42 individual text elements** from this strip by detecting content boundaries (rows with at least some lit pixels, grouped into elements with a minimum height of 5 rows).

The credits screens identify the development team:

- **Software**: Luis J. Gosálbez, Toñi Hernandez
- **Hardware**: Santos Aranda, Luis J. Gosálbez
- **Electromechanics**: Toñi Hernandez, J. Manuel Vázquez

---

## Font System

The ROM contains **131 font glyphs** stored in the range `0xA0000`–`0xB0000`. Glyphs come in multiple sizes:

| Size | Pixel Height | Usage |
|------|-------------|-------|
| 9 px | 9 pixels | Small text (labels, status) |
| 10 px | 10 pixels | Extra large characters |
| 12 px | 12 pixels | Large text (scores, headings) |
| 12 px | 12 pixels | 7-segment style digits |

### Font Entry Structure

Each glyph has a 6-byte header followed by 2 copies of the bitmap data:

```
Header: [height, 0x00, 0x01, 0x00, height, 0x00]
Data:   [height bytes] × 2 (two copies of the glyph bitmap)
```

All glyphs are **8 pixels wide**. Each byte in the glyph data represents one row of 8 pixels.

### Character Mapping

The font entries map to characters as follows:

- Entries 0–9 (9px): Digits `0`–`9`
- Entry 10 (9px): Space
- Entries 11–37 (9px): Letters `A`–`Z` and `Ñ`
- Entries 38–51 (9px): Punctuation and symbols
- Entries 52–61 (12px): Digits `0`–`9` (large)
- Entry 62 (12px): Space
- Entries 63–89 (12px): Letters `A`–`Z` and `Ñ` (large)
- Entries 90–104 (12px): Punctuation and symbols
- Entries 105–125 (12px): 7-segment style digits

### Custom Text Encoding

The 80188 game code uses a **custom character encoding** for DMD text, not standard ASCII:

```
0x0A = space    0x0B = 'A'    0x0C = 'B'    0x0D = 'C'    0x0E = 'D'
0x0F = 'E'      0x10 = 'F'    0x11 = 'G'    0x12 = 'H'    0x13 = 'I'
0x14 = 'J'      0x15 = 'K'    0x16 = 'L'    0x17 = 'M'    0x18 = 'N'
0x19 = 'Ñ'      0x1A = 'O'    0x1B = 'P'    0x1C = 'Q'    0x1D = 'R'
0x1E = 'S'      0x1F = 'T'    0x20 = 'U'    0x21 = 'V'    0x22 = 'W'
0x23 = 'X'      0x24 = 'Y'    0x25 = 'Z'
0x2C = ','      0x2E = '.'    0x2F = newline  0x00 = terminator
```

A **character mapping table** at ROM offset `0x809B0` (96 bytes) maps ASCII codes `0x20`–`0x7F` to glyph indices.

---

## Memory Layout Summary

```
0x00000 – 0x6F974 : Animated DMD frames (400 × 1030 bytes)
0x70000 – 0x7FFFF : Additional graphics/data
0x80000 – 0x809AF : Unknown data
0x809B0 – 0x80A0F : Character mapping table (ASCII → glyph index)
0x82000 – 0xA0000 : Static screens (bilingual pairs)
0xA0000 – 0xA1100 : Font glyphs (131 entries)
0xA9D00 – 0xAC000 : Scrolling credits animation data
0xD0000 – 0xFFFFF : Program code
```
