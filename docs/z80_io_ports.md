# Z80 I/O Port Map

[← Back to main README](../README.md)

## Port Assignments

Authoritative source: the annotated Z80 disassembly header at `asm/z80_annotated.asm:64–82`. Cross-checked against the actual `IN`/`OUT` instructions in the disassembly.

| Port | Direction | Function |
|------|-----------|----------|
| `0x00` | IN | Direct switches input 0 (flipper buttons, misc) |
| `0x01` | IN | Status register — bit 1 = 80188 inter-board handshake ready (J1 BUSY/AD); **not** an OKI ready line |
| `0x02` | IN | Switch matrix column data (8 bits, active-low; Z80 `CPL`s after reading) |
| `0x03` | IN | Direct (cabinet) switches, active-low. bit0 = TILT/Péndulo (C17, code 0x32); bit1 = TEST (C4, code 0x33); bit2 = RIGHT flipper (C5, code 0x34); bit3 = LEFT flipper (C1, code 0x35); bit4 = START (C2, code 0x36); bit6 = unused (code 0x38). **The earlier "bit3=START, bit2=TEST/COIN" was wrong** — verified against live TEST-DE-CONTACTOS anchors (0x32→C17, 0x34→C5). Dispatched by `sub_0dcb` @ `0x0DCB` (latch `0xC0DF`); flipper bits 2/3 handled by `sub_0e76`/`sub_0e30`. Coin is a separate acceptor path (codes 0x37/0x39 = C3 Monedero), **not** a port-0x03 bit. See `bikerace_switch_map.md`. |
| `0x04` | IN | Direct switches input 2 / power-on service combo. bit0 gates the matrix scan (`sub_0d2f`); boot reads bit7 = reboot, bit6 = clear-stats+test, bit5 = `sub_2b30`. |
| `0x80` | OUT | Inter-board data byte to the 80188 (placed on J1 lines DIO0-7); carries a switch code or a forwarded sound command depending on the strobe; does **not** reach the OKI directly |
| `0x81` | OUT | Control register, bit-mapped (see "Port 0x81 control bits" below) |
| `0x82` | OUT | **Lamp matrix column strobe** (bits 0–6 = columns A–G) |
| `0x83` | OUT | **Lamp matrix row data byte 1** (lower 8 lamps of the addressed column) |
| `0x84` | OUT | **Lamp matrix row data byte 2** (upper 8 lamps of the addressed column) |
| `0x85` | OUT | **Solenoid bank 1** — bit 0 = sol1, bit 2 = sol2, bit 4 = sol4, bit 5 = sol3 |
| `0x86` | OUT | **Solenoid bank 2** — kickers, diverters, ball lock, etc. |
| `0x87` | OUT | **Switch matrix row strobe** — one-hot value `0x01, 0x02, 0x04, 0x08, 0x10, 0x20` |

> ⚠️ **Corrections vs. earlier revisions of this document**: ports `0x82` through `0x87` were previously listed as "Switch Matrix Row Strobe / Solenoid Bank 1 / Solenoid Bank 2 / Sound Control 1 / Sound Control 2 / Lamp General Control" — that mapping was wrong on five of the six ports. The values above match the actual `OUT` instructions in the Z80 disassembly. Notable consequences:
>
> - **Lamp matrix is driven by ports `0x82` (column) + `0x83`/`0x84` (16 row bits per column)**, not by port `0x80` as the old "Lamp Matrix Row / Sound Data" label on `0x80` suggested.
> - **Switch matrix row strobe is on `0x87`**, not `0x82`. The strobe values cycle through `0x01–0x20` (6 rows), matching the switch matrix scan routine documented below.

---

## Port 0x81 control bits

The Z80 keeps a shadow of port 0x81 in RAM at `0xC001` (`ram_port81_shadow`) and read-modify-writes it. Based on which bits are set/cleared in the actual code paths:

| Bit | Mask | Set by | Cleared by | Function |
|-----|------|--------|------------|----------|
| 0 | `0x01` | `or 003h` in `send_sound_cmd` (0x0144) | `and 0FEh` later in `send_sound_cmd` | **Sound-channel select to the 80188** — set together with bit 1 while a sound command is on port `0x80`, so the 80188 routes the byte as a sound command rather than a switch code. Not an OKI latch (the Z80 has no connection to the MSM6376) |
| 1 | `0x02` | `or 002h` / `or 003h` in `send_to_80188` (0x0116), `send_sound_cmd` | `and 0FDh` (5× across routines) | **80188 inter-board data-valid / enable** — gates the port `0x80` byte onto the J1 data lines (DIO0-7); set in both send routines |
| 2 | `0x04` | `or 004h` in `send_to_80188` | (cleared as part of `and 0FBh and 0FDh` sequence) | **Switch-byte strobe to the 80188** — pulses the latch on the 80188 side for a switch code |
| 3 | `0x08` | **never set** (no `or 008h` before any `out (081h),a`) | — | unused on the Z80 side |
| 4 | `0x10` | `or 010h` in NMI/IRQ acknowledge | (implicit) | **NMI acknowledge** |
| 5 | `0x20` | `or 020h` in `send_sound_cmd` (2×) | `and 0DFh` (2×) | **Sound-command strobe to the 80188** — pulsed high → 3×`nop` → low in `send_sound_cmd`; mirrors bit 2 for the sound channel. Not an OKI strobe |
| 6 | `0x40` | `or 040h` in `switch_debounce` (0x01B6) | `and 0BFh` (3× in scan-loop tear-down) | **Direct-switch read enable** — must be set before reading port `0x00` |
| 7 | `0x80` | **never set** (no `or 080h` before any `out (081h),a`) | — | unused on the Z80 side |

Statistical evidence: I grep'd the entire Z80 ROM for the value loaded into A on the path to each of the ~36 `out (081h),a` instructions. The only `or` masks observed are `01h`, `02h`, `03h`, `04h`, `10h`, `20h`, `40h`. The only `and` masks observed are `BFh`, `DFh`, `FDh`, `FEh`. Bits 3 and 7 of port `0x81` are never manipulated.

---

## YM3812 routing — RESOLVED: driven by the 80188 via /PCS5

The YM3812 FM synthesizer (IC60) is on the 80188 board and is **driven by the 80188** — not the Z80, not the PIC — and it plays the **in-game music**. The drive code has now been located and byte-verified in the code ROM (`V1 3_01.bin`); see "How it is actually driven" at the end of this section. What the schematic settles is how it is selected:

- **It is an 80188 peripheral, selected by /PCS5.** Sheet 011-029-07 wires the YM3812 `/CS` to **/PCS5**, a peripheral chip-select generated by the 80188 itself (with A0 = register/data select and `/WR`/`/RD`). The chip is therefore **not** on the Z80 side, and **not** memory-mapped in the MMCS mid-range (`A000h`) window — it lives in the 80188's PCS5 window.
- **No Z80 access**: no Z80 port writes beyond `0x80–0x87`, and port `0x81` has no spare bits for a YM3812 path. The apparent `out (027h),a` / `out (05Ah),a` / `in a,(05Eh)` bytes in the disassembly all sit inside data tables (envelope/wave-table-like patterns), not reachable code.
- **The "exactly four chip-select windows" argument does not hold.** It rested on two claims the 80C188 datasheet contradicts. First, it looked for MPCS at I/O `0xFFAA`; in the 80C188 Peripheral Control Block MPCS is at offset `0xA8` (I/O `0xFFA8`), and the relocation register is at offset `0xFE` (I/O `0xFFFE`). Second, the register labels in the disassembly appear shifted by one 2-byte slot: it labels `0xFFA0` "RELREG", but `0xFFA0` is UMCS — the reset stub at `0xFFF00` writes `0xC03C` there to open the ROM window, which is a UMCS action — and the boot never writes the true relocation register at `0xFFFE`. With the labels corrected, the write the disassembly calls "MMCS" at `0xFFA8` is in fact **MPCS**, so MPCS *is* configured and the mid-range peripheral chip-selects (PCS0–PCS6, hence /PCS5) are **not** necessarily disabled. The exact PCS base and whether MPCS maps the strobes into I/O or memory (the MS bit) have not been re-derived here.
- **The "only two `out dx, ax`" argument does not hold either.** That count is of **word** writes only. An 8-bit device like the YM3812 is written with a **byte** OUT (`out dx, al`), and if MPCS maps the PCS lines into memory rather than I/O it is written with ordinary `mov` stores — neither of which is an `out dx, ax`. A low word-OUT count therefore says nothing about whether the YM3812 is driven. (The `sound_play_command` auto-name does look wrong — it writes `ES=5040h:02B9h` ≈ `0x506B9` and calls `display_set_buffer_14refs` / `display_clear_area_24refs`, so it appears display-related rather than a sound path — but that is a side observation, not part of the chip-select accounting.)

### How it is actually driven (verified in `V1 3_01.bin`)

The MPCS MS bit is **1**, so the PCS lines are **memory-mapped**; PACS places the
peripheral base at `0xA0000`, so **/PCS5 = `0xA0280`** (A0=0, address/index port)
and **`0xA0281`** (A0=1, data port). (Segment `D000` = linear `0xD0000` = file
offset `0x50000` in the ROM.)

- **OPL2 write primitive — `D000:0D99`** (file `0x50D99`): `mov es:[0280h],ah`
  (bytes `26 88 26 80 02`) → short settling-delay `call` → `mov es:[0281h],al`
  (file `0x50DA1`, bytes `26 A2 81 02`). This is the canonical OPL2 "write register
  index, then write data" sequence.
- **Music sequencer — `D000:0D37`** (file `0x50D37`): sets `ES=A000h`, walks a
  byte-pair `(register, value)` opcode stream pointed to by `[12EAh]`, with control
  opcodes `0xEE` = note duration, `0xEF` = tempo scale, `0xFF` = end, `0xDD` =
  jump/loop; the default case calls the write primitive at `0D99`. The opcode
  dispatch (`cmp ah,0EEh/0EFh/0FFh/0DDh`) is verified at file `0x50D4E`–`0x50D64`.
- **Song table** at `CS:0DE5`; **track selection** `game_mode_set` @ `D000:0DB4`,
  called from ~24 game-event sites. The player is **ticked every frame** from a
  timer ISR (`D000:0343` → `0D1B`).

This is why earlier passes "couldn't find" the FM code: (a) the music plays only
during **gameplay** — attract mode is silent, so the boot/attract PinMAME trace
triggered no FM writes — and (b) the annotated disassembly mis-classified this
region (`d0d09`–`d0db3`) as data/strings.

**For PinMAME**: map the YM3812 at `0xA0280` (index, A0=0) / `0xA0281` (data,
A0=1) and let its register writes drive the emulated OPL2. The chip is genuinely
used; "attached-but-unmapped" is only an interim stub, not the correct end state.

---

## Switch Matrix Scan Routine

The switch matrix scan routine resides at Z80 ROM addresses `0x2ED3`–`0x2FE6`.

### Row Strobe Sequence

The Z80 strobes one row at a time via port `0x82`, then reads the column state via port `0x02`:

| Strobe Value | Row | Switch Codes |
|-------------|-----|-------------|
| `0x01` | Row 0 | `0x0A`–`0x11` |
| `0x02` | Row 1 | `0x12`–`0x19` |
| `0x04` | Row 2 | `0x1A`–`0x21` |
| `0x08` | Row 3 | `0x22`–`0x29` |
| `0x10` | Row 4 | `0x2A`–`0x31` |
| `0x20` | Row 5 | `0x34`–`0x3B` |

### Direct Switch Codes

These are read from ports `0x03` and `0x04` without matrix scanning:

| Code | Switch |
|------|--------|
| `0x3E` | Left Flipper |
| `0x3F` | Right Flipper |
| `0x40` | Upper Flipper |
| `0x41` | START Button |
| `0x42` | Coin Input |

---

## Key Z80 RAM Addresses

| Address | Function |
|---------|----------|
| `0xC0DB`–`0xC0E0` | Matrix switch debounced states (6 rows) |
| `0xC0E3` | Direct switch state (Port `0x03` snapshot) |
| `0xC0E5`–`0xC0E6` | Scan routine state pointer |
| `0xC0E7`–`0xC0F2` | Raw matrix data (before debounce) |
| `0xC0FC` | Current switch code, staged in Z80 RAM and forwarded to the 80188 over J1 |

The byte at `0xC0FC` holds the current switch code. It is Z80-local RAM, **not** shared memory: when a switch is activated the Z80 writes the code here, then `send_to_80188` transmits it over the J1 byte-port (port `0x80` data + a port `0x81` strobe). The 80188 receives the byte through its inbound latch (IC43 on the 16-bit board) and stores it as `last_switch_code`, which it polls during its main loop.

---

## Switch Matrix Hardware

### Connector J2 (20-pin ribbon)

```
COL0–COL7 (C0–C7): Column strobe outputs (directly drive matrix columns)
ROW0–ROW7 (F0–F7): Row input returns (active-low, active when switch is closed)
```

### Connector J4 (20-pin ribbon)

```
FIF, FIM   — Left Flipper signals (fire, hold)
FDF, FDM   — Right Flipper signals (fire, hold)
FAM        — Right Middle Flipper signal
FBF, FBM   — Additional flipper signals
BC1–BC8    — Bumper contacts (active-low)
```

---

## Scan Timing

The Z80 runs at 8 MHz and performs a complete matrix scan cycle as part of its main processing loop. Each scan iteration:

1. Strobes one row via port `0x82`
2. Reads column state via port `0x02`
3. Compares with debounced state at `0xC0DB`+row
4. If a change is detected, updates the debounced state and writes the switch code to `0xC0FC`
5. Reads direct switches from ports `0x03` and `0x04`
6. Processes lamp matrix updates
7. Processes solenoid updates

The complete scan cycle handles all 6 matrix rows plus direct switches in a single pass.
