# Sleic Pin-Ball — switch input, NMI/J1 path, and switch mapping

Investigation date 2026-06-14. Source: `sp03_80188_ndisasm.asm` (80188 game code,
F000:xxxx = file `0x10000+xxxx`) and `sp04_z80dasm.asm` (Z80 I/O code, addr = file
offset). Compared against the working Bike Race (SLEIC3) driver in `pinmame/src/wpc/sleic.c`
and `docs/bikerace_switch_map.md`.

## Headline: the input path is architecturally identical to Bike Race

Sleic Pin-Ball (SLEIC1) and Bike Race (SLEIC3) share the same I/O hardware and the
same firmware structure for input. Switch mapping **is** stored in the ROM, the same
way Bike Race stores it (a per-code dispatch jump table; plus the J1/NMI delivery).
The only differences are table offsets and the game-specific contact assignments.

## Switch matrix scan (Z80, sp04) — VERIFIED against the disassembly

The Z80 scans the matrix at `0x1770+`:
```
out (082h),a    ; strobe one matrix column (one-hot on port 0x82)
in  a,(002h)    ; read 8 row bits on port 0x02 (active-low; CPL'd after read)
```
repeated 8 times (column reads at Z80 `0x1772,0x1791,0x17B0,0x17CF,0x17EE,0x180D,0x182C,0x184B`).
So **the matrix strobe is port `0x82` and the data read is port `0x02`** — exactly like
the working Bike Race driver (`sleic3_z80_read/write`), **NOT** port `0x87` as
`docs/z80_io_ports.md` (an IO Moon doc) suggests. (Port `0x87`, used 17×, is a
separate control/strobe — verify its exact role when wiring; it is not the matrix
column select.)

Switch code formula (same as Bike Race): `code = 0x0A + 8*col + row`.

### Verified Z80 I/O port map (sp04)

| Dir | Port | Count | Role |
|---|---|---|---|
| IN  | `0x00` | 1  | J1 inbound byte (80188->Z80 command; read in NMI handler) |
| IN  | `0x01` | 24 | J1 status / handshake (ready bit polled before sending) |
| IN  | `0x02` | 8  | **switch-matrix column data** (8 reads = the scan loop) |
| IN  | `0x03` | 1  | direct/cabinet buttons |
| IN  | `0x04` | 7  | status / boot-mode bits |
| OUT | `0x80` | 2  | J1 outbound data byte (switch code / sound cmd) |
| OUT | `0x81` | 7  | J1 control: data-valid, **switch strobe (bit 2)**, sound strobe, NMI-ack |
| OUT | `0x82` | 9  | **switch-matrix column strobe** (one-hot) |
| OUT | `0x83` | 6  | lamp column strobe |
| OUT | `0x84` | 6  | lamp row data |
| OUT | `0x85` | 9  | solenoid bank 1 |
| OUT | `0x86` | 17 | solenoid bank 2 |
| OUT | `0x87` | 17 | control/strobe (role TBC; not the matrix column) |

## J1 -> 80188 delivery via NMI — VERIFIED

The Z80 sends a switch code over the J1 byte-port (port `0x80` data + port `0x81`
bit-2 strobe). On the 80188 side that strobe latches the byte at peripheral
`0xA0100` (PCS2) and raises the **NMI** (IVT type 2). NMI handler at **`F000:DF20`**:

```
mov ds,0 ; mov es,0xA000
mov si,[0x4E7]                 ; ring write pointer
... wrap at 0x80D back to 0x67D ...
mov al,[0x4DE]; or al,0x10; mov [es:0x200],al   ; strobe 0xA0200 (PCS4) bit4 = ack
mov al,[es:0x100]              ; READ the J1 byte from 0xA0100 (PCS2)  <-- switch byte
mov [ds:si],al                 ; push into ring buffer (0x67D..0x80D, seg 0)
mov al,[0x4DE]; mov [es:0x200],al               ; restore 0xA0200
mov al,0xFF; mov [0x4E4],al    ; set "new byte available" flag
iret
```
This matches Bike Race's NMI/J1 model exactly (read PCS2 `0xA0100`, buffer, flag),
so the driver must, on the Z80 port-0x81 bit-2 strobe: latch the byte at `0xA0100`
and pulse the 80188 NMI — i.e. mirror `sleic3_z80_write` + a PCS2 read handler.

## Switch dispatch — ROM-stored jump table (the "switch mapping")

The 80188 consumes buffered bytes at **`E000:02E1`**:
```
mov si,[0x4E5]                 ; ring read pointer
mov al,[ds:si]; test -> done if 0
inc/advance read pointer
mov si,0x310; xor ah,ah; shl ax,1; add si,ax   ; index = code*2 into table at CS:0x310
mov ax,[cs:si]; jmp ax         ; jump to the per-code handler
```
So **the switch->action mapping is a ROM jump table at `E000:0310`** (file `0x310`),
indexed by `code*2`, giving a 16-bit handler offset in segment E000. Decoded:

- codes `0x00-0x09` -> special/pre-matrix handlers
- codes **`0x0A-0x31`** -> the **40 matrix switches** (5 cols x 8 rows), almost all
  with distinct handlers (a few point to the `0x0522` no-op). Examples:
  `0x0A`->E000:0F9E, `0x12`->E000:12F7, `0x1A`->E000:0E61, `0x2A`->E000:199F.
- codes `0x32+` -> cabinet/coin handlers.

This is directly analogous to Bike Race's dispatcher jump table. (Bike Race also
has a separate code->C-number->name table at file `0x1373D` for the TEST-CONTACTOS
self-test; the equivalent sleicpin name table has not yet been pinned — the contact
NAMES need either that table decoded or a Pin-Ball service manual, which we do not
have. The matrix POSITIONS, however, are fully known.)

## Mapping to PinMAME (mirror SLEIC3)

| Logical | PinMAME | Source |
|---|---|---|
| matrix COL0..COL4 (codes 0x0A-0x31) | `swMatrix[1..5]` | port-0x82 strobe selects column, port-0x02 returns `~swMatrix[1+col]` |
| cabinet/direct buttons (codes 0x32+) | `swMatrix[9]` | port-0x03 returns `~swMatrix[9]` |

`SLEIC_sw2m`/`SLEIC_m2sw` (already in the driver) encode `no = 40 + col*10 + row`.

## Comparison: SLEIC1 (Sleic Pin-Ball) vs SLEIC3 (Bike Race)

| Aspect | Same? | Notes |
|---|---|---|
| Z80 matrix scan (port 0x82 strobe + 0x02 read) | YES | verified in both ROMs |
| Code formula `0x0A + 8*col + row` | YES | 5 cols x 8 rows, codes 0x0A-0x31 |
| J1 byte-port + port-0x81 bit-2 strobe | YES | same handshake bits |
| 80188 NMI (IVT type 2) reads PCS2 `0xA0100` | YES | sleicpin handler `F000:DF20` |
| Switch mapping stored in ROM (dispatch jump table) | YES | sleicpin at `E000:0310`; Bike Race analogous |
| Code->C-number->name table (TEST-CONTACTOS) | likely | Bike Race at file `0x1373D`; sleicpin offset TBD |
| Contact assignments / names | NO | game-specific playfield |
| Ring buffer + new-byte flag | YES | sleicpin: ring 0x67D-0x80D, ptrs [0x4E5]/[0x4E7], flag [0x4E4] |

## Driver implementation plan (SLEIC1)

Mirror the SLEIC3 input wiring, adapted to SLEIC1's existing maps:
1. Add `sleic1_z80_read`/`sleic1_z80_write` (ports 0x00-0x04 in, 0x80-0x87 out) like
   `sleic3_z80_read/write`: feed `swMatrix` (0x02 column, 0x03 cabinet), set the
   matrix strobe from port 0x82, drive lamps/solenoids from 0x83-0x86, and on the
   port-0x81 bit-2 rising edge latch the J1 byte + pulse the 80188 NMI.
2. Add a PCS2 read at `0xA0100` (and the rest of the peripheral read block) on the
   SLEIC1 80188 map so the NMI handler reads the latched switch byte.
3. Add a `SWITCH_UPDATE(SLEIC1)` + a playfield-key table (like `sleic3_pf_keys`) so
   the CONTACTOS self-test and gameplay can be exercised.
4. Wire the Z80 port handlers + switch update into `MACHINE_DRIVER_START(SLEIC1)`.

Open items to confirm while wiring:
- exact role of Z80 port `0x87` (17 writes) and whether the scan is 5 or 8 columns;
- the J1 "ready"/status bits the Z80 polls on IN `0x01`/`0x04` (Bike Race needed
  port-0x04 bit 7 = 1 and an 0x5F "ready" byte — confirm sleicpin's equivalents);
- the reverse path (80188 -> Z80 NMI) for sound-command delivery, if needed;
- the sleicpin code->name table offset (for human-readable contact names).
