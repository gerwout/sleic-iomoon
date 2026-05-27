# 80188 -> Z80 Mailbox Investigation

## Bottom line

The 80188 sends commands to its coprocessor through a **circular byte queue at
`4000:1158+`** ( physical `0x41158`+ ), with a producer "write tail" at
`4000:114E` ( phys `0x4114E` ) and a consumer "read head" at `4000:114C`
( phys `0x4114C` ). The single most plausible mailbox address is therefore not a
single byte but the **next-byte slot pointed to by `4000:114E`** when the
producer pushes; the queue base is `4000:1158`.

This is a **multi-byte command queue**, not a single-byte mailbox. The label
"display command queue" that appears in the existing annotations is misleading
on its semantics (see Caveats below): the 80188 itself never reads back the
queue, only writes to it. That means the queue is consumed by something *not*
the 80188 - i.e. it is an outgoing mailbox.

The auto-generated function name `sound_play_command` at `0xD0978` is a red
herring (see Caveats - it writes to `5040:02B9`, outside any shared region).
The real producer function is `cmd_queue_push` at `0xD0138`.

## Evidence

### 1. The queue itself

`cmd_queue_push` ( `0xD0138`, ~82 callers ), from `asm/80188_annotated.asm`
lines 1311-1340:

```
d0138:  fa                  cli                       ; CLI/STI protected push
d0143:  bb 00 40            mov  bx, 4000h            ; DS := segment 4000h
d0146:  8e db               mov  ds, bx
d0148:  8b 36 4e 11         mov  si, [114eh]          ; SI := producer tail
d014c:  80 3c 00            cmp  byte [si], 00h       ; slot empty (sentinel)?
d014f:  74 0f               jz   loc_d0160            ;   no: queue-full reset
d0151:  46                  inc  si
d0152:  89 36 4e 11         mov  [114eh], si          ; advance tail
d0156:  88 04   loc_d0156:  mov  [si], al             ; *** byte written here ***
d0158:  46                  inc  si
d0159:  c6 04 00            mov  byte [si], 00h       ; write sentinel at next slot
d015f:  cb                  retf
                                                       ; queue-full reset path:
d0160:  be 58 11            mov  si, 1158h            ; restart at queue base
d0163:  89 36 4e 11         mov  [114eh], si          ; reset tail
d0167:  89 36 4c 11         mov  [114ch], si          ; reset head
d016b:  eb e9               jmp  short loc_d0156
```

Init ( `dmd_controller_init` at `0xD00B9`, lines 1257-1259 ):

```
d00e5:  be 58 11            mov  si, 1158h
d00e8:  89 36 4c 11         mov  [114ch], si          ; head <- 1158h
d00ec:  89 36 4e 11         mov  [114eh], si          ; tail <- 1158h
d00f0:  c6 04 00            mov  byte [si], 00h       ; queue empty sentinel
```

### 2. The 80188 never reads from the queue

Searches of `asm/80188_annotated.asm` show:

- `[114ch]` (the documented "write pointer") - **2 writes, 0 reads**:
  line 1258 ( init ) and line 1339 ( queue-full reset ). The 80188 never
  loads from `[114ch]`.
- `1158h` - **0 reads** anywhere. Only appears as an immediate constant
  set into `SI` during init / queue-full reset ( lines 1257, 1337 ).
- `[114eh]` - read on every push at line 1321 ( `mov si, [114eh]` ),
  written back at lines 1325 and 1338. This is the producer-internal tail
  pointer.

So whoever maintains `[114ch]` and consumes bytes from `1158+` is **not the
80188**. That makes the queue an outbound channel.

### 3. The pushed values are opaque small bytes, not display text

35 distinct values are pushed across the 82 call sites:

```
24h, 5dh, 5eh, 8ch, a5h, a9h, abh, b3h, bch, c0h, c3h, c4h, c5h, c6h, c7h,
c8h, dbh, e4h, e7h, e8h, e9h, eah, ebh, ech, edh, eeh, efh, f1h, f2h, f3h,
f4h, f6h, f7h, f8h, f9h
```

These are not ASCII text ( cf. switch codes like `0x41`='A'='START' ), not
bitmask state, and not coordinates. The clustering in the `0x8C-0xF9` range
plus single low values `0x24`, `0x5D`, `0x5E` is consistent with sample / phrase
indices for an OKI MSM6376-class chip, or generic opcode-style commands for a
coprocessor.

Call sites cluster at game-event boundaries ( game start, ball-end, mode
change ): e.g. `d2f96-d2f99` pushes `0xC0` right after a successful
game-start detection ( line 2333 ); `d3085-d3087` pushes `0x5D` in
`game_active_handler` ( line 2473 ); `d3104-d3106` pushes `0x5D` after
setting `413C:00DE = 1` ( line 2516 ); `d3441` pushes `0x8C` after
clearing `413C:00FA` ( line 2837 ). These are exactly the moments at which
sound or coprocessor-driven actions would be triggered.

### 4. Cross-reference against the Z80 disassembly

The Z80 ROM does **not** consume this queue. Confirmed by:

- The Z80 has no memory reads outside `0x0000-0x7FFF` ( ROM IC5 ) and
  `0xC000-0xC7FF` ( RAM IC7 ) - 385 `ld a,(<imm16>)` instructions all
  resolve to `0xC0xx`. No address in `0x4000-0x7FFF` or `0x8000-0xBFFF`
  is ever read as data ( verified by grep ).
- The Z80's own "sound command" path is self-contained: `send_sound_cmd`
  at `0x0144` ( z80 line 609 ) reads from `0xC008` ( its local
  `ram_sound_cmd` shadow byte ), which is built up via bit-masking
  operations ( `or 050h`, `or 001h`, `and 0FEh`, etc. ) inside the Z80's
  IRQ handler and solenoid-timer code paths. The Z80 generates its sound
  / OKI command bits from its own hardware events ( solenoid timer
  expiry at `0x0B41-0x0B49` is a clear example ), not from an
  80188-supplied byte.
- The Z80's `port 0x00 IN` instructions occur in two contexts, neither of
  which retrieves anything that resembles a queue byte: the NMI handler
  at `0x008C` reads port `0x00` with port `0x81` bit 4 set ( NMI ack ),
  and `switch_debounce` at `0x01D6` reads port `0x00` with port `0x81`
  bit 6 set ( "direct-switch read enable" per `docs/z80_io_ports.md`
  line 44 ). Both paths store the result to `0xC060`
  ( `ram_direct_sw_shadow` ), labelled "direct switches" in the
  disassembly header ( z80 line 95 ).

Combined with the empirical PinMAME tracing in
`research/pinmame_session_2/00_summary.txt` lines 114-130 ( "zero writes
to YM3812 from either CPU" ), the conclusion is that the queue at
`4000:1158+` is consumed by a **third coprocessor**, most likely the
undumped PIC at IC34 or IC57 hypothesised in
`docs/hardware_architecture.md:148` and `docs/ym3812_pinmame_precedents.md:130`.
The PIC reads the queue from shared RAM and drives the YM3812 ( and
possibly the OKI ) register bus.

This is consistent with - but corrects in detail - the
`docs/inter_cpu_communication.md` claim that "Sound Commands ( 80188 -> Z80 )
goes via the shared mailbox." The shared-RAM mailbox exists; the consumer
is just not the Z80.

## Address summary

| Field | 80188 view (segment:offset) | Physical | Owner | Notes |
|-------|----------------------------|----------|-------|-------|
| Queue base | `4000:1158` | `0x41158` | shared | Byte stream, null-terminated growing region |
| Queue write tail ( producer ) | `4000:114E` | `0x4114E` | 80188 writes & reads | "cmd_queue_read_ptr" label in current asm is misleading |
| Queue read head ( consumer ) | `4000:114C` | `0x4114C` | 80188 init-writes, **never reads**; consumer reads & advances | "cmd_queue_write_ptr" label is misleading |
| Producer function | `cs:0138` ( `cs=D000` ) | `0xD0138` | `cmd_queue_push` | 82 call sites |

## Caveats

1. **No physical confirmation of the consumer**. The Z80 cannot read this
   region ( no address maps to it on the Z80 bus ). The most likely
   consumer is the undumped PIC microcontroller at IC34 or IC57. Until
   that chip is dumped, the consumer-side protocol is inferred, not
   verified. The "Bottom line" address is correct for what the **80188**
   writes; what physically picks the bytes up is a separate question.

2. **Pointer label semantics are reversed in the existing annotations.**
   `[114ch]` is labelled `cmd_queue_write_ptr` and `[114eh]` is labelled
   `cmd_queue_read_ptr`, but the actual code paths use `[114eh]` as the
   producer's tail-of-write pointer and `[114ch]` as the consumer's
   head-of-read pointer ( evidenced by the 80188 never reading `[114ch]`
   and using `[114eh]` to choose where to place the next byte ). The
   labels should be swapped to match producer / consumer conventions.

3. **`sound_play_command` at `0xD0978` does not push to this queue.** Its
   single store is `mov byte es:[02b9h], 00h` with `ES = 5040h`
   ( physical `0x504B9` ), well outside the PACS window. The function
   is bracketed by `display_set_buffer_14refs` / `display_clear_area_24refs`
   and is a display-buffer-segment write. The auto-name is wrong, as
   already noted in `docs/z80_io_ports.md:58`.

4. **No verified single-byte mailbox** for the 80188 -> Z80 direction
   beyond this queue. Other candidates were searched and ruled out:
   - `4000:1147` ( labelled "switch_event_pending" ) is written by the
     80188 only to clear it ( value `0` ); it is set by the Z80 side and
     is a Z80 -> 80188 signal.
   - `4000:1148`, `4000:1145` are each written exactly once during
     `system_init` ( both `0` at `f0042` and `04h` at `d00f3` ); never
     written again.
   - All byte-writes inside the `4000:10C0-114F` block resolve to
     game-state or display-mode bookkeeping that the 80188 also reads
     back ( i.e. internal state, not a write-only mailbox ).

5. **Direction of the symmetry argument.** Z80 -> 80188 uses
   `Z80 OUT 0x80` -> 80188 reads at `413C:00D6` ( phys `0x41496` ). The
   mirror image would be: 80188 writes a byte somewhere in the PACS
   window -> Z80 reads via `IN 0x00` with `port 0x81 bit 6 = 0`. No code
   path in the Z80 ROM is observed reading port `0x00` with bit 6 clear
   and using the result as anything other than direct-switch input, so
   the direct symmetry does not exist. The queue described above is the
   actual outbound channel from the 80188, but its consumer is not the
   Z80.
