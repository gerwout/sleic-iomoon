# The 80188 outbound command queue (`4000:1158`)

The 80188 keeps a circular byte queue in its own work RAM at **`4000:1158`+**
(physical `0x41158`+), with a producer write pointer at `4000:114E` and a
consumer read pointer at `4000:114C`. It is the **80188 → Z80 command channel**:
the bytes are indices into the Z80's 256-entry dispatch table at `$2000`, and
they carry lamp, driver, mode and test-mode commands. This is finding **F12** of
[`../asm/baseline-2026-09/findings.md`](../asm/baseline-2026-09/findings.md); the
protocol around it is F6, written up in
[`../docs/inter_cpu_communication.md`](../docs/inter_cpu_communication.md).

It is **not** a sound channel: both sound chips are written directly by 80188 game
code, through `sub_D0B70` for the OKI (81 call sites) and `fm_song_select`
`D0DB4` for the YM3812 (24 call sites), neither of which takes its argument from
a queue. And it is not display data: the DMD pipeline runs entirely in
`4000:0000`–`0DFF` and ends in the buffer at segment `7000`.

## The producer

`qout_push` at `0xD0138`, **172 call sites**:

```asm
d0138:  cli                       ; CLI/STI protected push
d0143:  mov  bx, 4000h            ; DS := segment 4000h
d0146:  mov  ds, bx
d0148:  mov  si, [114eh]          ; SI := write pointer
d014c:  cmp  byte [si], 00h       ; slot empty (sentinel)?
d014f:  jz   loc_d0160            ;   no: queue-full reset
d0151:  inc  si
d0152:  mov  [114eh], si          ; advance
d0156:  mov  [si], al             ; the byte
d0158:  inc  si
d0159:  mov  byte [si], 00h       ; sentinel in the next slot
d015f:  retf
                                  ; queue-full reset:
d0160:  mov  si, 1158h
d0163:  mov  [114eh], si
d0167:  mov  [114ch], si
d016b:  jmp  short loc_d0156
```

Initialised at boot (`0xD00E5`): both pointers set to `1158h`, sentinel written.

## The consumer

`qout_service_pcs1` at `0xD01E5`, called from the INT0 ISR at `D0392`:

```asm
D01E5:  cmp byte [1145h],0 / jz +5 / dec byte [1145h] / ret   ; 1 call in 4
D01F6:  mov si,[114ch] / mov al,[si] / and al,al / jnz +1 / ret ; head byte, 0 = empty
D0206:  test byte [es:0180h], 01h    ; PCS3 bit 0 = the Z80 took the previous byte
D020C:  jnz +1 / ret
D020F:  mov [es:0080h], al           ; PCS1 = the byte, onto the J1 data lines
D0216:  or al,40h / mov [es:0200h],al ; PCS4 bit 6
D022A:  or al,20h / ...               ; PCS4 bit 5 -- the strobe that NMIs the Z80
D0243:  and al,0DFh / and al,0BFh / ... ; strobes released
```

The ISR calls it on alternate INT0s and it acts on one call in four, so the
outbound byte rate is **INT0 / 8**.

The read pointer is set up in `SI` rather than reloaded from a literal `[114ch]`
on every pass, which is why a grep for the constant alone does not find the
consumer.

## What proves the payload is a Z80 command

The boot handshake at `D2F96`. The 80188 pushes `0xC0`; the Z80's table entry
`0xC0` is `$11F5`, the direct-input self-scan, which answers `0x7A`; and `0x7A`
is exactly the byte the 80188 then waits for:

```asm
D2F96:  push 0C0h / call qout_push
D2F9F:  call inbound_byte_take_b / or al,al / jz D2F9F
D2FA8:  cmp byte [00006h], 07Ah      ; 0x7A = all direct inputs clear
D2FAD:  jz  D2FBB                    ;   -> clear the boot-fault byte
D2FAF:  call sub_D5468 / call sub_DD253  ; -> fault display + service menu
```

The 54 distinct constant immediates pushed across the 172 call sites — `0x84`,
`0x86`, `0x88`, `0x8A`, `0x8C`, `0xA5`, `0xA9`–`0xAC`, `0xB0`, `0xB3`, `0xB6`,
`0xBB`, `0xBC`, `0xBF`, `0xC0`, `0xC3`–`0xCA`, `0xD2`, `0xD7`, `0xDB`, `0xDC`,
`0xE3`–`0xEF`, `0xF1`–`0xF4`, `0xF6`–`0xFB`, `0xFD`, `0xFE` — are all valid
indices into that table, and computed values reach it too. Call sites cluster at
game-event boundaries, which is where a lamp or coil command belongs.

## Why the Z80 cannot read the queue directly

- The Z80 makes **no memory access outside `0x0000-0x7FFF` (ROM IC5) and
  `0xC000-0xC7FF` (RAM IC7)**: all 385 `ld a,(<imm16>)` instructions resolve to
  `0xC0xx`, and no address in `0x4000-0x7FFF` or `0x8000-0xBFFF` is ever read as
  data.
- J1 carries no address bus, so cross-board memory access is impossible in any
  case.

The queue's bytes reach the Z80 one at a time, through the PCS1 latch and the
Z80's own NMI, which stores each byte in the ring at `$C076` for
`host_cmd_dispatch` `16D5` to dispatch.

## Naming note

The generated labels in [`../asm/superseded/`](../asm/superseded/) reverse the
pointer roles: they call `[114ch]` `cmd_queue_write_ptr` and `[114eh]`
`cmd_queue_read_ptr`, where the code uses `[114eh]` as the producer's write
pointer and `[114ch]` as the consumer's read pointer. `sound_play_command`
`0xD0978` in the same listings is not a sound path either — its single store is
`mov byte es:[02b9h], 00h` with `ES = 5040h`, i.e. a write into the non-volatile
store.
