# Z80 I/O Port Map

[← Back to main README](../README.md)

Every entry below is read out of the `IN`/`OUT` sites in
[`../asm/baseline-2026-09/iomoon_z80.lst`](../asm/baseline-2026-09/) (the Z80 ROM
`V1 3_05.bin`, 141 I/O sites across 12 decoded regions). The port roles, the
switch-code map and the lamp/driver model are findings **F5**, **F6** and **F7**
of [`findings.md`](../asm/baseline-2026-09/findings.md).

## Port assignments

| Port | Direction | Function |
|------|-----------|----------|
| `0x00` | IN | **J1 inbound data byte** from the 80188. Taken by the NMI handler at `0080` (gated by port-`0x81` bit 4) or by the polled `host_read_byte` `01B6` (gated by bit 6). One latch either way. |
| `0x01` | IN | Status. **bit 1 = J1 port free** — the spin condition of all three `host_send_*` routines *and* of `host_read_byte`. **bit 5 = the selected direct input**, active low, read by `direct_input_scan` (`0DF8`/`0E36`). |
| `0x02` | IN | **Switch-matrix return**, 8 bits, active low (`sw_read_col0..5` at `2ED3`–`2FB9` `CPL` it into the per-column change masks). |
| `0x03` | IN | **Cabinet inputs**, active low (`input_port03_read` `2E54` `CPL`s it). Bits and the codes their handlers send: bit 0 → `0x3E` (tilt, `sub_125B`, with a 3000-tick lockout); bit 1 → `0x3F` (test / service menu, `sub_1278`); bit 4 → `0x40` (START, `sub_1285`); bits 3 and 2 → the left and right flipper buttons (`sub_1292` / `sub_12D8`, which fire the port-`0x85` coil pairs directly and send `0x41` / `0x42` **only in test mode**); bit 5 → the coin mechanism, one `0x32` per press (`0x33` in test mode; `0D3C` / `0D44`). |
| `0x04` | IN | Cabinet / configuration byte. **bit 0** gates `direct_input_scan` `0DBF` off when high; **bits 1-3** are SW40-2/3/4, the country code, reported to the 80188 on command `0xF9` (`2D9D`: `IN A,($04) / OR 0F0h`); **bit 5** is SW40-5, the manual's "no balls dispensed" service position, read by the command-`0xED` handler `2BEB`; **bit 7** must be high or `selftest_wait_reset` `2E42` spins forever. |
| `0x80` | OUT | **J1 outbound data byte** onto lines `DIO0`–`DIO7`. Carries an event code or a state bitmask depending on which strobe follows; it reaches no sound chip. |
| `0x81` | OUT | J1 control register, bit-mapped — see below. |
| `0x82` | OUT | **Switch-matrix column strobe**, one-hot `0x01`–`0x20` = columns 0–5. |
| `0x83` | OUT | **Lamp column strobe**, one-hot `0x01`–`0x80` = columns 0–7. Written *after* the row byte. |
| `0x84` | OUT | **Lamp row data**, 8 bits, active high, latched. |
| `0x85` | OUT | **Driver latch 1**, active LOW (`0xFF` = all off at reset). Bits 0/1, 2/3 and 4/5 are driven as complementary pairs; bits 6 and 7 individually. |
| `0x86` | OUT | **Driver latch 2**, active LOW. All eight bits driven independently, with a timed auto-release path inside the IRQ handler (`0ADA`–`0C51`). |
| `0x87` | OUT | **Direct-input index** (low nibble) plus two flag bits; the multiplexer address for the 16-way scan read back on port `0x01` bit 5. |

`boot_port_init` `041B` writes `0xFF` to both driver latches at reset
(`0422`, `0429`), which is what makes `1` = off and a cleared bit = a fired
driver.

---

## Port 0x81 control bits

The Z80 keeps a shadow of port `0x81` in RAM at `0xC001` and read-modify-writes
it.

| Bit | Mask | Function |
|-----|------|----------|
| 0 | `0x01` | Set together with bit 1 on the `C008` sends (`0153: OR A,#$03`); cleared on the polled read (`01C2`), by the NMI while it raises bit 4 (`0080`), and by `port81_bit3_toggle` on its bit-3-clear path (`0CA8`). Its role is not established. |
| 1 | `0x02` | **Data-valid** — set before the port-`0x80` write and cleared after; gates the byte onto `DIO0`–`DIO7`. |
| 2 | `0x04` | **Strobe for the `C0FC` event-code channel** — the pulse that latches the byte on the 80188 side and raises its NMI. |
| 3 | `0x08` | **Periodic square wave.** `port81_bit3_toggle` `0C97` flips it (`RES 3,A` at `0CA6`, `SET 3,A` at `0CB0`) each time the `C045` counter expires, immediately before `OUT ($81),A`. The Z80 never reads it back, so it is plausibly a line *to* the 80188; it is not free-running, because `C045` is reloaded by J1 traffic (to `#$30` by the NMI at `009E`, to `#$20` by `host_send_c008_a` at `014B`). |
| 4 | `0x10` | **Inbound gate for the NMI's `IN A,($00)`.** |
| 5 | `0x20` | **Strobe for the `C008` state-bitmask channel** — pulsed with three `NOP`s of width. |
| 6 | `0x40` | **Inbound gate for the polled `IN A,($00)`** at `01D6`, used only by `direct_input_scan`. |
| 7 | `0x80` | Never manipulated anywhere in the ROM. |

All 22 `OUT ($81),A` sites were inspected. Bits 0–2 and 4–6 are set and cleared
with `OR`/`AND` immediates — the masks that reach the port are `01h`, `02h`,
`03h`, `04h`, `10h`, `20h`, `40h` and `BFh`, `DFh`, `EFh`, `FBh`, `FDh`, `FEh`.
**Bit 3 is the exception**: it is manipulated
with the bit instructions `RES 3,A` (`CB 9F`) and `SET 3,A` (`CB DF`) in
`port81_bit3_toggle` and nowhere else, which is why a search for immediate masks
alone does not find it. Bit 7 is never touched by any instruction.

---

## Switch codes on the J1 event channel

A programmatic sweep of the whole Z80 listing for the byte pattern
`3E nn / 32 FC C0` (`LD A,#nn / LD ($C0FC),A`) finds **73 sites** and no others.
They break down as:

| Source | Codes | Where |
|--------|-------|-------|
| Switch matrix, **6 columns × 8 rows = 48 inputs** | `0x0A`–`0x31` (columns 0–4, 40 routines at `316D` step 8) and `0x34`–`0x3B` (column 5, 8 routines at `32AD` step 8) | per-bit routines dispatched by `sw_col0_changed` `2FE7` … `sw_col5_changed` `312C` |
| Port `0x03` bits 0 / 1 / 4 | `0x3E` tilt / `0x3F` test / `0x40` START | `sub_125B` / `sub_1278` / `sub_1285`, dispatched by `sub_1242` |
| Port `0x03` bits 3 / 2, the flipper buttons | `0x41` / `0x42` — **test mode only** | `sub_1292` `12D0` / `sub_12D8` `1340`, gated on `C068`/`C069`; in play they call `sub_05C7` / `sub_05ED`, fire the port-`0x85` coil pairs and send nothing |
| Port `0x03` bit 5, the coin mechanism | `0x32` (normal) / `0x33` (test mode), **one per press** | `0D3C` / `0D44`, debounced by the `C046` counter |
| Direct-input scan, 16-way on port `0x87` low nibble + port `0x01` bit 5 | `0x50`–`0x79` (42-byte table at `1218`) | `direct_input_scan` `0DBF` |
| Command-table re-sends of matrix codes | `0x38`, `0x39`, `0x3A`, `0x3B`, `0x3C`, `0x3D` | the switch-test handlers reached by 80188 commands `0xE9`/`0xEA`/`0xEB` |
| Status / liveness replies | `0x43`, `0x44`, `0x45`, `0x46`, `0x47`, `0x48`, `0x49`, `0x4A`, `0x7A`, and `0xF0`+nibble | scattered command-table handlers |

The matrix map is exactly regular: **column c, bit b → code `0x0A + 8c + b`**
for c = 0..4, and **`0x34 + b`** for c = 5.

```asm
sw_col0_changed 2FE7:
    LD  A, ($C0DB)      ; column 0 change mask
    BIT 0, A
    CALL Z, $316D       ; bit 0 -> the code-0x0A routine
    ... eight times, targets 316D 3175 317D 3185 318D 3195 319D 31A5 (step 8)

316D:  LD A,#$0A / LD ($C0FC),A / JP sub_161E
3175:  LD A,#$0B / LD ($C0FC),A / JP sub_164A
...
32E5:  LD A,#$3B / LD ($C0FC),A / JP sub_1348      ; column 5 bit 7
```

**One press produces one code, not a repeat while held.** `sub_0D15` debounces
port-`0x03` bit 5 for `0x32` ticks of `C046` and sends one code, then calls
`sub_33FA`, which ORs the bit into **both** `C0F8` (the mask) and `C0E3` (the
debounced shadow). `input_port03_read` `2E54` rebuilds `C0E3` every scan as
`IN($03) | C0F8`, so a still-held button reads as released; `sub_3335` clears
the mask again with `C0F8 &= C0F7` once the contact physically opens.

`0x45`, `0x46` and `0x47` are ordinary event codes on this same channel:
`0x47` is the Z80's boot "alive" byte (`0410`, resent by the command-table
handler at `2E24`) and `0x45`/`0x46` are the two answers to 80188 command `0xED`
(`2BEB`: `IN A,($04) / BIT 5,A / JP Z,$2C17`). They are **not** display markers,
and the 80188 also dispatches `0x45` through its ordinary switch-code path at
five sites.

Which physical contact sits behind each of the 48 matrix codes is established
for four of them: **column 0 bits 0–3, codes `0x0A`–`0x0D`, are the ball-handling
contacts** — bits 0–2 the three trough contacts and bit 3 the ball-exit contact
(finding F15). Contact 0 is the trough entry and doubles as the ball-over
sensor, reporting code `0x43` rather than its own `0x0A` (`161E`). The other 44
positions are exact as codes but not yet tied to named playfield switches.

---

## Lamps and drivers

The 80188 commands all lamp and driver output as **single command bytes** over
the J1 outbound path; the Z80 decodes them through a **256-entry word table at
`$2000`** (230 live entries, 26 pointing at the no-op at `$2200`).

**Lamps: 8 columns × 8 bits = 64, with a two-bank blink model.**

```
C0FF..C106   bank 1  ("lit")
C107..C10E   bank 2  ("steady")
C10F..C116   the bytes actually written to port 0x84
```

`sub_353A` alternates the output every time `C120` counts down from `0x4B` (75)
ticks: phase A (`3594`) copies bank 1 verbatim, phase B (`3553`) ANDs bank 1 with
bank 2. So bank1=1 and bank2=1 is steady on, bank1=1 and bank2=0 blinks, and
bank1=0 is off. One column is emitted per Z80 interrupt:

```asm
lamp_col0_out 3457:  LD A,($C10F) / OUT ($84),A / LD A,#$01 / OUT ($83),A
lamp_col1_out 3467:  ... ($C110) ... #$02 ...   (through lamp_col7_out 34C7, #$80)
```

Command bytes `0x01`–`0xA4` are the individual bank bit operations, e.g.

```asm
2201 (cmd 01):  LD HL,#$C10B / RES 7,(HL) / LD HL,#$C103 / SET 7,(HL)
22C7 (cmd 17):  LD HL,#$C101 / SET 0,(HL)
```

Commands `0xAD`–`0xB7` load one of sixteen canned lamp-sequence blocks in
`38CC`–`4FD4` into the sequence player at `C11A`/`C11B`/`C11E`.

**Drivers: two 8-bit latches, active LOW, individually timed.** Port `0x86`
drives all eight bits independently (`AND #$FE`…`#$7F` to fire at `0706`–`07D1`,
`OR #$01`…`#$80` to release at `081B`–`0892`, plus the timed auto-release inside
the IRQ handler). Port `0x85` is mixed: bits 0/1, 2/3 and 4/5 are complementary
pairs (a flipper's power and hold windings, `05D7`/`0623`, …) with bits 6 and 7
individual. So the hardware is **16 driver bits = 13 addressable devices**.
Command bytes `0xCB`–`0xE7` call into that family (`2895 → sub_05C7`,
`28D7 → sub_05ED`, `2919 → sub_0613`, …), several arming a duration in
`C04F`/`C051` first.

Commands `0xF7` and `0xF8` enter and leave test mode: `2DC4` sets `C068`, and
`2DD9` clears it, does `DI` and `JP boot` — **leaving test mode reboots the
Z80**, re-running `boot_port_init` and clearing every lamp column and both driver
latches.

---

## Switch-matrix scan

The scan lives at `0x2ED3`–`0x2FE6` and is dispatched from the main loop through
`(C0E5)` — **not** from the IRQ handler, which only calls `sub_2E54` to read the
cabinet inputs on port `0x03`.

| Strobe on port `0x82` | Column | Switch codes |
|-------|--------|--------------|
| `0x01` | 0 | `0x0A`–`0x11` |
| `0x02` | 1 | `0x12`–`0x19` |
| `0x04` | 2 | `0x1A`–`0x21` |
| `0x08` | 3 | `0x22`–`0x29` |
| `0x10` | 4 | `0x2A`–`0x31` |
| `0x20` | 5 | `0x34`–`0x3B` |

Each iteration strobes one column, reads the return on port `0x02`, compares it
with the debounced state at `0xC0DB`+column, and on a change calls the per-bit
routine, which stages its code in `0xC0FC` and sends it over J1.

---

## Key Z80 RAM addresses

| Address | Function |
|---------|----------|
| `0xC001` | Port `0x81` shadow |
| `0xC005` / `0xC006` | Port `0x85` / `0x86` driver-latch shadows |
| `0xC008` | The state bitmask sent on the port-`0x81` bit-5 channel |
| `0xC045` | Counter behind the port-`0x81` bit-3 toggle; reloaded by J1 traffic |
| `0xC046` | Coin-input debounce counter |
| `0xC068` / `0xC069` | Test-mode flags (set by 80188 command `0xF7`) |
| `0xC06A` | Flippers-enabled flag (80188 command `0xC7`) |
| `0xC072` / `0xC074` / `0xC076`+ | Inbound command ring: read pointer, write pointer, body |
| `0xC0DB`–`0xC0E0` | Debounced matrix state, six columns |
| `0xC0E3` | Debounced cabinet-input state (port `0x03` snapshot) |
| `0xC0E5`–`0xC0E6` | Scan-routine state pointer |
| `0xC0F7` / `0xC0F8` | Raw and latched cabinet-input masks |
| `0xC0FC` | Current event code, staged in Z80 RAM and sent over J1 |
| `0xC0FF`–`0xC116` | Lamp bank 1, bank 2 and the emitted bytes |

`0xC0FC` is Z80-local RAM, **not** shared memory: the Z80 writes the code there
and `host_send_c0fc` transmits it over the J1 byte-port. The 80188 receives it
through the inbound latch (IC43 on the 16-bit board), the NMI appends it to the
FIFO at `4000:1220`, and `sub_D7453` pops it into `413C:00D6`. See
[`inter_cpu_communication.md`](inter_cpu_communication.md).

---

## Switch-matrix hardware

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

## Interrupt structure

The Z80 runs in **interrupt mode 1** (`IM 1` at `0x0002`, repeated in the boot
path at `0x0401`), so `/INT` vectors through `0x0038`, which jumps to the
service routine at `0x0A42`. That routine refreshes one lamp column per call,
advances one step of the driver timers, and reads the cabinet inputs. The IRQ
itself comes from the divider chain on the 16-bit board and arrives over J3 at
about 977 Hz — see [`../research/z80_irq_timing.md`](../research/z80_irq_timing.md)
— which gives each lamp column a refresh of about 122 Hz.

The **NMI** (`0x0066`) is the J1 inbound path: it reads port `0x00`, stores the
byte in the ring at `$C076` and returns; `host_cmd_dispatch` `16D5` then
dispatches it through the `$2000` table.
