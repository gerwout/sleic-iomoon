; =============================================================================
; IO Moon Pinball - Fully Annotated Z80 Coprocessor ROM Disassembly
; =============================================================================
;
; Machine:     SLEIC IO Moon Pinball (1994/1996)
; Developer:   Luis Gosálbez Carrasco / Toni Hernandez (software)
;              Santos Aranda (hardware)
; Company:     CREACIONES E INVESTIGACIONES ELECTRONICAS, S.L. (SLEIC)
; Location:    Av. Valdelaparra 3, Pol. Ind. Alcobendas, 28100 Madrid
;
; Z80 Coprocessor Specifications:
;   CPU:       Z80A @ 8 MHz (crystal X10)
;   ROM IC5:   27C256 (32KB) at 0x0000-0x7FFF  ← THIS FILE
;   ROM IC6:   27C128 (16KB) at 0x8000-0xBFFF  (not included)
;   RAM IC7:   6116 (2KB) at 0xC000-0xC7FF
;   Watchdog:  MAX699 (IC15)
;   DIP Switch: SW40 (8-position)
;
; Z80 Responsibilities (coprocessor to 80188 main CPU):
;   • Switch matrix scanning (6×8 matrix + 6 direct switches)
;   • Lamp matrix control (7 columns × 16 rows via ports 0x82-0x84)
;   • Solenoid driver control (2 banks: ports 0x85, 0x86)
;   • Sound-command generation, forwarded to the 80188 over J1 (ports 0x80/0x81)
;   • Communication with 80188 over connector J1 (8-bit handshaken byte-port)
;
; 80188 Main CPU Responsibilities:
;   • Game logic, state machine, scoring
;   • DMD display control (128×32, 2-plane)
;   • Credits, match/lottery system
;   • 4-player support, bilingual (ES/EN)
;
; ═══════════════════════════════════════════════════════════════════
; ARCHITECTURE OVERVIEW
; ═══════════════════════════════════════════════════════════════════
;
;  ┌────────────────┐                        ┌────────────────┐
;  │   80188 Main   │   J1 8-bit byte-port   │   Z80 Copro    │
;  │   AMD 80C188   │◄──────────────────────►│   Z80A @ 8MHz  │
;  ├────────────────┤  DIO0-7 (8 data lines) ├────────────────┤
;  │ • Game Logic   │    Port 0x80 (data)     │ • Switch Scan  │
;  │ • DMD Display  │    Port 0x81 (control)  │ • Lamp Matrix  │
;  │ • State Machine│                         │ • Solenoids    │
;  │ • Scoring      │   J1 handshake (8b)    │ • Sound → 80188│
;  └────────────────┘                         └────────────────┘
;         │                                          │
;    1MB ROM (2×27C040)                    32KB ROM (27C256)
;    DMD graphics + code                   + 16KB ROM (27C128)
;                                          + 2KB RAM (6116)
;
; ═══════════════════════════════════════════════════════════════════
; Z80 MEMORY MAP
; ═══════════════════════════════════════════════════════════════════
;
;  0x0000-0x7FFF  ROM IC5 (27C256, 32KB) - Main Z80 program
;  0x8000-0xBFFF  ROM IC6 (27C128, 16KB) - Extended routines/data
;  0xC000-0xC7FF  RAM IC7 (6116, 2KB)    - Work RAM, shadows, state
;  0xC800-0xFFFF  [Unmapped / mirrors]
;
; ═══════════════════════════════════════════════════════════════════
; I/O PORT MAP
; ═══════════════════════════════════════════════════════════════════
;
;  INPUT PORTS:
;  Port 0x00 (R)  Direct switches input 0 (flipper buttons, misc)
;  Port 0x01 (R)  Status register (bit1 = 80188 inter-board handshake ready, via J1 BUSY/AD)
;  Port 0x02 (R)  Switch matrix column data (8 bits, active-low, inverted by CPL)
;  Port 0x03 (R)  Direct switches input 1 (bit3=START, bit2=TEST/COIN)
;  Port 0x04 (R)  Direct switches input 2 (bit0=TILT, special)
;
;  OUTPUT PORTS:
;  Port 0x80 (W)  Inter-board data byte → 80188 over J1 (DIO0-7); switch code or fwd'd sound cmd
;  Port 0x81 (W)  Control register (bit-mapped) — every strobe targets the 80188 over J1:
;                   bit 0 = sound-channel select (set with bit1 when sending a sound cmd)
;                   bit 1 = inter-board data-valid / enable (gates port 0x80 onto DIO0-7)
;                   bit 2 = switch-byte strobe to 80188
;                   bit 4 = NMI acknowledge
;                   bit 5 = sound-command strobe to 80188
;                   bit 6 = direct-switch read enable (set before reading port 0x00)
;  Port 0x82 (W)  Lamp matrix column strobe (bit 0-6 = columns A-G)
;  Port 0x83 (W)  Lamp matrix row data byte 1 (lower 8 lamps)
;  Port 0x84 (W)  Lamp matrix row data byte 2 (upper 8 lamps)
;  Port 0x85 (W)  Solenoid bank 1 (bit0=sol1, bit2=sol2, bit4=sol4, bit5=sol3)
;  Port 0x86 (W)  Solenoid bank 2 (kickers, diverters, ball lock, etc)
;  Port 0x87 (W)  Switch matrix row strobe (0x01,0x02,0x04,0x08,0x10,0x20)
;
; ═══════════════════════════════════════════════════════════════════
; RAM MAP (0xC000-0xC7FF)
; ═══════════════════════════════════════════════════════════════════
;
;  C000-C008  I/O Port Shadow Registers (ports 0x80-0x87)
;  C009-C021  Work area (cleared during init)
;  C022-C044  Solenoid timer bank (16+ countdown timers)
;  C045       NMI downcounter (init=0x30, decremented each NMI)
;  C04C       Switch event queue write pointer
;  C04E       Main timer flag (game timing control)
;  C05F       Debounce timer (97 refs - MOST referenced location!)
;  C060       Direct switch shadow (port 0x00 last value)
;  C062-C063  Coin/credit counters
;  C068       Game active flag (0=attract mode, nonzero=game active)
;  C06A       Ball-in-play counter
;  C072       Switch event queue read pointer
;  C074-C076  NMI state machine pointers
;  C07B-C081  Lamp column data source registers (A through G)
;  C0DB-C0E0  Debounced switch state per matrix row (6 rows)
;  C0E3       Debounced direct switch state (flippers, start, etc)
;  C0E5-C0E6  Scan state machine pointer (16-bit)
;  C0E7-C0F6  Raw matrix data buffer (6 rows × 2 bytes each)
;  C0F7-C0F8  Port 0x03 raw/processed
;  C0F9       Scan debounce counter
;  C0FA       Current lamp column index
;  C0FB       Command completion flag (37 refs)
;  C0FC       Switch code staged in Z80 RAM, forwarded to 80188 over J1 (86 refs!)
;  C117       Active solenoid mask
;  C119-C11E  Lamp column on/off state registers
;  C121       DIP switch (SW40) settings cache
;
; ═══════════════════════════════════════════════════════════════════
; COMMUNICATION PROTOCOL (Z80 ↔ 80188)
; ═══════════════════════════════════════════════════════════════════
;
;  The Z80 talks to the 80188 over connector J1 — an 8-bit handshaken
;  byte-port (data lines DIO0-7 + BUSY/AD/IR handshakes), NOT shared RAM.
;  The same port carries two kinds of byte, distinguished by the strobe:
;
;  Switch events (send_to_80188, 0x0116):
;  1. Z80 detects switch closure/opening
;  2. Z80 writes the switch code to C0FC (e.g. 0x41='A' for START)
;  3. send_to_80188:
;     a. Wait for port 0x01 bit1 ready (J1 handshake)
;     b. Set bit1 on port 0x81 (data-valid)
;     c. Load A from C0FC, write A to port 0x80 (onto DIO0-7)
;     d. Pulse bit2 on port 0x81 (switch strobe)
;  4. The 80188 latches the byte (IC43 on the 16-bit board) and processes it
;
;  Sound commands (send_sound_cmd, 0x0144): same handshake and port 0x80,
;  but port 0x81 sets bit0+bit1 and pulses bit5. The 80188 receives the byte
;  and drives the OKI MSM6376 itself — the Z80 has no wires to the OKI.
;
;  Switch code encoding (C0FC values):
;    0x41 = 'A' = START button
;    0x42 = 'B' = Coin/TEST
;    0x43-0x47 = Special switches
;    0x50-0x6F = Matrix switches (mapped via table at 0x1218)
;
; ═══════════════════════════════════════════════════════════════════
; SWITCH MATRIX LAYOUT
; ═══════════════════════════════════════════════════════════════════
;
;  Matrix: 6 active rows × 8 columns = 48 positions (44 used + 4 unused)
;  Scanning: Row strobe via port 0x87, column read via port 0x02
;  Debounce: 2-read compare with timer-based delay
;
;  Row  Strobe  Matrix Codes    Typical Switches
;  ───  ──────  ────────────    ─────────────────────────
;   0   0x01    0x0A-0x11       Bumpers, slingshots
;   1   0x02    0x12-0x19       Drop targets, ramp entries
;   2   0x04    0x1A-0x21       Lanes, orbits
;   3   0x08    0x22-0x29       Targets, scoops
;   4   0x10    0x2A-0x31       Ramp exits, planets
;   5   0x20    0x34-0x3B       Misc (Jupiter entry, etc)
;
;  Direct Switches (no matrix, direct port reads):
;   C1  = Left Flipper   (code 0x3E, port 0x03/C0E3 bit 0)
;   C2  = START           (code 0x41, port 0x03 bit 3)
;   C3  = TEST/Coin       (code 0x42, port 0x03 bit 2)
;   C5  = Right Flipper  (code 0x3F, port 0x03/C0E3 bit 1)
;   C20 = TILT            (port 0x04 bit 0)
;
; ═══════════════════════════════════════════════════════════════════
; SOLENOID TIMING (from table at 0x05B6)
; ═══════════════════════════════════════════════════════════════════
;
;  Sol  Value  ~Duration  Typical Use
;  ───  ─────  ─────────  ──────────────────
;   0   0x50   ~400ms     Left flipper hold
;   1   0x28   ~200ms     Right flipper hold
;   2   0x0F   ~75ms      Pop bumper fire (fast)
;   3   0x1E   ~150ms     Slingshot fire
;   4   0x08   ~40ms      Quick pulse (diverter)
;   5   0x96   ~750ms     Ball eject (long)
;   6   0x00   (unused)
;   7   0x1E   ~150ms     Kicker
;   8   0x1E   ~150ms     Kicker
;   9   0x14   ~100ms     Drop target reset
;  10   0x00   (unused)
;  11   0x2C   ~220ms     Ramp diverter
;  12   0x01   ~5ms       Minimal pulse
;  13   0x1E   ~150ms     Ball lock release
;  14   0x00   (unused)
;  15   0x5E   ~470ms     General Illumination hold
;
; ═══════════════════════════════════════════════════════════════════
; EXECUTION FLOW OVERVIEW
; ═══════════════════════════════════════════════════════════════════
;
;  CPU Reset (0x0000)
;    │ IM 1, DI, JP main_init
;    ▼
;  main_init (0x0400)
;    │ SP = C7FFh
;    │ Clear RAM (C009-C0B0)
;    │ Initialize all I/O ports
;    │ Send init code 0x47 ('G') to 80188
;    │ EI (enable interrupts)
;    ▼
;  main_loop (0x0D4C)  ◄───────────────────────────────────────┐
;    │                                                          │
;    ├─► scan_state_entry (0x2E62)                              │
;    │     State machine: cycles through row 0-5 scanning       │
;    │     Reads port 0x02, debounces, queues changed switches  │
;    │                                                          │
;    ├─► check_start_test (0x0D76)                              │
;    │     Reads port 0x03: bit3=START, bit2=TEST               │
;    │     Sends code 0x41/0x42 to 80188 on button press        │
;    │                                                          │
;    ├─► switch_event_dispatch (0x16D5)                         │
;    │     Reads queued switch events from C072                 │
;    │     Lookup in jump table at 0x2000 (128 entries)         │
;    │     Calls appropriate handler (solenoid/lamp/score)      │
;    │                                                          │
;    ├─► check_tilt_sol_tmr (0x0DBF)                            │
;    │     Reads port 0x04 for TILT                             │
;    │     Processes solenoid timer countdown                   │
;    │                                                          │
;    └──────────────────────────────────────────────────────────┘
;
;  Interrupts:
;    RST 38h (IRQ) → irq_service_main (0x0A42):
;      • Lamp hardware refresh (ports 0x82-0x84)
;      • Lamp scan one column
;      • Scan direct switches
;      • Solenoid timer tick (auto-off expired solenoids)
;      • Game timer decrement
;
;    NMI (0x0066) → nmi_handler:
;      • State machine processing
;      • Port 0x00 direct switch read (→ C060)
;      • NMI downcounter decrement (C045)
;      • RETN
;
; ═══════════════════════════════════════════════════════════════════
; ROM UTILIZATION
; ═══════════════════════════════════════════════════════════════════
;
;  0x0000-0x0012   (18 bytes)    Reset vectors and init stub
;  0x0038-0x003B   (4 bytes)     RST 38h interrupt vector
;  0x0066-0x00A6   (65 bytes)    NMI handler
;  0x0100-0x01F1   (241 bytes)   Communication & utility routines
;  0x0400-0x16F4   (4852 bytes)  Main program: init, loop, solenoids, I/O
;  0x1218-0x1237   (32 bytes)    Switch code lookup table
;  0x16D5-0x17FF   (298 bytes)   Switch dispatch & data
;  0x2000-0x20FF   (256 bytes)   Switch jump table (128 × 16-bit)
;  0x2200-0x25E9   (1001 bytes)  Matrix switch handlers
;  0x2745-0x27B3   (110 bytes)   Additional switch handlers
;  0x27B4-0x2E53   (1695 bytes)  Game logic (DIP, scoring, modes)
;  0x2E54-0x3040   (492 bytes)   Matrix scan state machine
;  0x3040-0x340B   (971 bytes)   Lamp scan & column update routines
;  0x340B-0x3500   (245 bytes)   Lamp hardware refresh
;  0x3500-0x4FD5   (6869 bytes)  Extended game logic & utility
;  0x4FD6-0x7FFF   (12330 bytes) Unused (0xFF padding)
;  ────────────────────────────────────────────────────────────
;  Total code:     ~16,833 bytes (51.4% of 32KB ROM)
;  Unused:         ~15,935 bytes (48.6% padding)
;
; ═══════════════════════════════════════════════════════════════════
; CROSS REFERENCE SUMMARY (Top functions by call count)
; ═══════════════════════════════════════════════════════════════════
;
;  Address  Calls+Jumps  Function
;  ───────  ──────────   ────────────────────────────
;  0x0116   9+75=84      send_to_80188 (J1 byte-port write)
;  0x01B6   25           switch_debounce (most called sub)
;  0x0144   22           send_sound_cmd (forward sound cmd to 80188)
;  0x10E4   13           lamp_update_helper
;  0x2D3B   13           game_logic_lanes
;  0x2CC7   11           game_logic_bumpers
;  0x135E   10           game_state_update
;  0x0116   9            send_to_80188
;  0x33A5   8            lamp_set_col_B
;  0x3394   8            lamp_set_col_A
;  0x33B6   8            lamp_set_col_C
;  0x33D8   8            lamp_set_col_E
;  0x33C7   7            lamp_set_col_D
;  0x0613   5            sol1_activate
;  0x06A5   5            sol4_activate
;  0x0630   5            sol2_activate
;
; z80dasm original command:
;   z80dasm -t -l -g0x0000 -a V1_3_cpu_05.BIN
; ROM file: V1 3_05.BIN (27C256, 32768 bytes)
; Analysis: February 2026
;
; =============================================================================



; =============================================================================
; INTERRUPT VECTORS AND HANDLERS
; =============================================================================

; ─────────────────────────────────────────────────────────────────────────────
; reset_entry (0x0000)
; CPU Reset: IM1, DI, JP main_init
; ─────────────────────────────────────────────────────────────────────────────
reset_entry:
	nop			;0000	00		.
;  XREF: 2 refs from 0x47BA, 0x4ADA
l0001h:
	nop			;0001	00		.
l0002h:
	im 1			;0002	ed 56		. V
l0004h:
	di			;0004	f3		.
l0005h:
	nop			;0005	00		.
	nop			;0006	00		.
	jp main_init		;0007	c3 00 04	. . .  ; → main_init
l000ah:
	nop			;000a	00		.
	jp main_init		;000b	c3 00 04	. . .  ; → main_init
	nop			;000e	00		.
	jp main_init		;000f	c3 00 04	. . .  ; → main_init
	rst 38h			;0012	ff		.
	rst 38h			;0013	ff		.
l0014h:
	rst 38h			;0014	ff		.
	rst 38h			;0015	ff		.
	rst 38h			;0016	ff		.
	rst 38h			;0017	ff		.
l0018h:
	rst 38h			;0018	ff		.
	rst 38h			;0019	ff		.
	rst 38h			;001a	ff		.
	rst 38h			;001b	ff		.
	rst 38h			;001c	ff		.
	rst 38h			;001d	ff		.
l001eh:
	rst 38h			;001e	ff		.
	rst 38h			;001f	ff		.
	rst 38h			;0020	ff		.
	rst 38h			;0021	ff		.
l0022h:
	rst 38h			;0022	ff		.
	rst 38h			;0023	ff		.
	rst 38h			;0024	ff		.
l0025h:
	rst 38h			;0025	ff		.
	rst 38h			;0026	ff		.
	rst 38h			;0027	ff		.
	rst 38h			;0028	ff		.
sub_0029h:
	rst 38h			;0029	ff		.
	rst 38h			;002a	ff		.
	rst 38h			;002b	ff		.
	rst 38h			;002c	ff		.
l002dh:
	rst 38h			;002d	ff		.
	rst 38h			;002e	ff		.
	rst 38h			;002f	ff		.
l0030h:
	rst 38h			;0030	ff		.
	rst 38h			;0031	ff		.
	rst 38h			;0032	ff		.
	rst 38h			;0033	ff		.
	rst 38h			;0034	ff		.
	rst 38h			;0035	ff		.
	rst 38h			;0036	ff		.
	rst 38h			;0037	ff		.

; ─────────────────────────────────────────────────────────────────────────────
; rst38_vector (0x0038)
; RST 38h / INT vector: JP irq_service_main
; ─────────────────────────────────────────────────────────────────────────────
rst38_vector:
	jp irq_service_main		;0038	c3 42 0a	. B .  ; → irq_service_main
l003bh:
	ld bc,0ffffh		;003b	01 ff ff	. . .
	rst 38h			;003e	ff		.
	rst 38h			;003f	ff		.
l0040h:
	rst 38h			;0040	ff		.
l0041h:
	rst 38h			;0041	ff		.
l0042h:
	rst 38h			;0042	ff		.
l0043h:
	rst 38h			;0043	ff		.
	rst 38h			;0044	ff		.
	rst 38h			;0045	ff		.
	rst 38h			;0046	ff		.
	rst 38h			;0047	ff		.
l0048h:
	rst 38h			;0048	ff		.
	rst 38h			;0049	ff		.
	rst 38h			;004a	ff		.
	rst 38h			;004b	ff		.
	rst 38h			;004c	ff		.
	rst 38h			;004d	ff		.
	rst 38h			;004e	ff		.
	rst 38h			;004f	ff		.
l0050h:
	rst 38h			;0050	ff		.
l0051h:
	rst 38h			;0051	ff		.
l0052h:
	rst 38h			;0052	ff		.
	rst 38h			;0053	ff		.
	rst 38h			;0054	ff		.
	rst 38h			;0055	ff		.
	rst 38h			;0056	ff		.
	rst 38h			;0057	ff		.
	rst 38h			;0058	ff		.
	rst 38h			;0059	ff		.
l005ah:
	rst 38h			;005a	ff		.
	rst 38h			;005b	ff		.
	rst 38h			;005c	ff		.
	rst 38h			;005d	ff		.
	rst 38h			;005e	ff		.
	rst 38h			;005f	ff		.
l0060h:
	rst 38h			;0060	ff		.
	rst 38h			;0061	ff		.
	rst 38h			;0062	ff		.
	rst 38h			;0063	ff		.
l0064h:
	rst 38h			;0064	ff		.
	rst 38h			;0065	ff		.

; ─────────────────────────────────────────────────────────────────────────────
; nmi_handler (0x0066)
; NMI handler: save regs, state machine, port 0x00 read, RETN
; ─────────────────────────────────────────────────────────────────────────────
nmi_handler:
	ex af,af		;0066	08		.
	exx			;0067	d9		.
	ld hl,(0c074h)		;0068	2a 74 c0	* t .  ; [ram_nmi_state_ptr - NMI state machine HL pointer (saved)]
	ld a,(hl)		;006b	7e		~
	and a			;006c	a7		.
	jp nz,l007ch		;006d	c2 7c 00	. | .
	ld hl,0c076h		;0070	21 76 c0	! v .
	ld (0c072h),hl		;0073	22 72 c0	" r .  ; [ram_sw_queue_rptr - Switch event queue read pointer]
	ld (0c074h),hl		;0076	22 74 c0	" t .  ; [ram_nmi_state_ptr - NMI state machine HL pointer (saved)]
	jp l0080h		;0079	c3 80 00	. . .
l007ch:
	inc hl			;007c	23		#
	ld (0c074h),hl		;007d	22 74 c0	" t .  ; [ram_nmi_state_ptr - NMI state machine HL pointer (saved)]
l0080h:
	ld a,(0c001h)		;0080	3a 01 c0	: . .  ; [ram_port81_shadow - Shadow register for PORT_CONTROL]
	and 0feh		;0083	e6 fe		. .
	or 010h			;0085	f6 10		. .
	ld (0c001h),a		;0087	32 01 c0	2 . .  ; [ram_port81_shadow - Shadow register for PORT_CONTROL]
	out (081h),a		;008a	d3 81		. .  ; >> PORT_CONTROL - control → 80188 (bit4=NMI ack; bit0=sound-chan sel; bit2=switch strobe; bit5=sound strobe)
	in a,(000h)		;008c	db 00		. .  ; << PORT_DIRECT_SW_0 - Direct switches input (flipper buttons, misc)
	ld (hl),a		;008e	77		w
	inc hl			;008f	23		#
	ld (hl),000h		;0090	36 00		6 .
	ld a,(0c001h)		;0092	3a 01 c0	: . .  ; [ram_port81_shadow - Shadow register for PORT_CONTROL]
	and 0efh		;0095	e6 ef		. .
	or 001h			;0097	f6 01		. .
	ld (0c001h),a		;0099	32 01 c0	2 . .  ; [ram_port81_shadow - Shadow register for PORT_CONTROL]
	out (081h),a		;009c	d3 81		. .  ; >> PORT_CONTROL - control → 80188 (bit4=NMI ack; bit0=sound-chan sel; bit2=switch strobe; bit5=sound strobe)
	ld hl,0c045h		;009e	21 45 c0	! E .
	ld (hl),030h		;00a1	36 30		6 0
	exx			;00a3	d9		.
	ex af,af		;00a4	08		.
	retn			;00a5	ed 45		. E
	rst 38h			;00a7	ff		.
	rst 38h			;00a8	ff		.
	rst 38h			;00a9	ff		.
	rst 38h			;00aa	ff		.
	rst 38h			;00ab	ff		.
	rst 38h			;00ac	ff		.
	rst 38h			;00ad	ff		.
	rst 38h			;00ae	ff		.
	rst 38h			;00af	ff		.
	rst 38h			;00b0	ff		.
	rst 38h			;00b1	ff		.
	rst 38h			;00b2	ff		.
	rst 38h			;00b3	ff		.
	rst 38h			;00b4	ff		.
	rst 38h			;00b5	ff		.
	rst 38h			;00b6	ff		.
	rst 38h			;00b7	ff		.
	rst 38h			;00b8	ff		.
	rst 38h			;00b9	ff		.
	rst 38h			;00ba	ff		.
	rst 38h			;00bb	ff		.
	rst 38h			;00bc	ff		.
	rst 38h			;00bd	ff		.
	rst 38h			;00be	ff		.
	rst 38h			;00bf	ff		.
	rst 38h			;00c0	ff		.
	rst 38h			;00c1	ff		.
	rst 38h			;00c2	ff		.
	rst 38h			;00c3	ff		.
	rst 38h			;00c4	ff		.
	rst 38h			;00c5	ff		.
	rst 38h			;00c6	ff		.
	rst 38h			;00c7	ff		.
l00c8h:
	rst 38h			;00c8	ff		.
	rst 38h			;00c9	ff		.
	rst 38h			;00ca	ff		.
	rst 38h			;00cb	ff		.
	rst 38h			;00cc	ff		.
	rst 38h			;00cd	ff		.
	rst 38h			;00ce	ff		.
	rst 38h			;00cf	ff		.
	rst 38h			;00d0	ff		.
	rst 38h			;00d1	ff		.
	rst 38h			;00d2	ff		.
	rst 38h			;00d3	ff		.
	rst 38h			;00d4	ff		.
	rst 38h			;00d5	ff		.
	rst 38h			;00d6	ff		.
	rst 38h			;00d7	ff		.
	rst 38h			;00d8	ff		.
	rst 38h			;00d9	ff		.
	rst 38h			;00da	ff		.
	rst 38h			;00db	ff		.
	rst 38h			;00dc	ff		.
	rst 38h			;00dd	ff		.
	rst 38h			;00de	ff		.
	rst 38h			;00df	ff		.
	rst 38h			;00e0	ff		.
	rst 38h			;00e1	ff		.
	rst 38h			;00e2	ff		.
	rst 38h			;00e3	ff		.
	rst 38h			;00e4	ff		.
	rst 38h			;00e5	ff		.
	rst 38h			;00e6	ff		.
	rst 38h			;00e7	ff		.
	rst 38h			;00e8	ff		.
	rst 38h			;00e9	ff		.
	rst 38h			;00ea	ff		.
	rst 38h			;00eb	ff		.
	rst 38h			;00ec	ff		.
	rst 38h			;00ed	ff		.
	rst 38h			;00ee	ff		.
	rst 38h			;00ef	ff		.
	rst 38h			;00f0	ff		.
	rst 38h			;00f1	ff		.
	rst 38h			;00f2	ff		.
	rst 38h			;00f3	ff		.
	rst 38h			;00f4	ff		.
	rst 38h			;00f5	ff		.
	rst 38h			;00f6	ff		.
	rst 38h			;00f7	ff		.
	rst 38h			;00f8	ff		.
	rst 38h			;00f9	ff		.
	rst 38h			;00fa	ff		.
	rst 38h			;00fb	ff		.
	rst 38h			;00fc	ff		.
	rst 38h			;00fd	ff		.
	rst 38h			;00fe	ff		.
	rst 38h			;00ff	ff		.

; =============================================================================
; GAME LOGIC
; =============================================================================

; ─────────────────────────────────────────────────────────────────────────────
; sound_ctrl_init (0x0100)
; Sound control initialization routine
; ─────────────────────────────────────────────────────────────────────────────
sound_ctrl_init:
	ld a,(0c001h)		;0100	3a 01 c0	: . .  ; [ram_port81_shadow - Shadow register for PORT_CONTROL]
	or 002h			;0103	f6 02		. .
	ld (0c001h),a		;0105	32 01 c0	2 . .  ; [ram_port81_shadow - Shadow register for PORT_CONTROL]
	out (081h),a		;0108	d3 81		. .  ; >> PORT_CONTROL - control → 80188 (bit4=NMI ack; bit0=sound-chan sel; bit2=switch strobe; bit5=sound strobe)
	ret			;010a	c9		.
	ld a,(0c001h)		;010b	3a 01 c0	: . .  ; [ram_port81_shadow - Shadow register for PORT_CONTROL]
	and 0fdh		;010e	e6 fd		. .
	ld (0c001h),a		;0110	32 01 c0	2 . .  ; [ram_port81_shadow - Shadow register for PORT_CONTROL]
	out (081h),a		;0113	d3 81		. .  ; >> PORT_CONTROL - control → 80188 (bit4=NMI ack; bit0=sound-chan sel; bit2=switch strobe; bit5=sound strobe)
	ret			;0115	c9		.

; =============================================================================
; COMMUNICATION & UTILITY ROUTINES
; =============================================================================

; ─────────────────────────────────────────────────────────────────────────────
; send_to_80188 (0x0116)
; *** KEY *** Send switch byte (C0FC) to the 80188 over J1 (port 0x80 + port 0x81 strobe)
; XREF: 84 references from 0x0415, 0x0D41, 0x0D49, 0x0E4B, 0x100E, 0x1021, 0x1034, 0x10E1 ... (+76 more)
; ─────────────────────────────────────────────────────────────────────────────
send_to_80188:
	in a,(001h)		;0116	db 01		. .  ; << PORT_STATUS - status (bit1 = 80188 inter-board handshake ready, via J1 BUSY/AD)
	bit 1,a			;0118	cb 4f		. O
	jr z,send_to_80188		;011a	28 fa		( .
	di			;011c	f3		.
	ld a,(0c001h)		;011d	3a 01 c0	: . .  ; [ram_port81_shadow - Shadow register for PORT_CONTROL]
	or 002h			;0120	f6 02		. .
	out (081h),a		;0122	d3 81		. .  ; >> PORT_CONTROL - control → 80188 (bit4=NMI ack; bit0=sound-chan sel; bit2=switch strobe; bit5=sound strobe)
	ld (0c001h),a		;0124	32 01 c0	2 . .  ; [ram_port81_shadow - Shadow register for PORT_CONTROL]
	ld a,(0c0fch)		;0127	3a fc c0	: . .  ; [ram_switch_mailbox - *** MAILBOX BYTE *** Switch code → 80188 (86 refs!)]
	out (080h),a		;012a	d3 80		. .  ; >> PORT_SOUND_DATA - inter-board data byte → 80188 over J1; 80188 drives the OKI, not the Z80
l012ch:
	ld a,(0c001h)		;012c	3a 01 c0	: . .  ; [ram_port81_shadow - Shadow register for PORT_CONTROL]
	or 004h			;012f	f6 04		. .
	out (081h),a		;0131	d3 81		. .  ; >> PORT_CONTROL - control → 80188 (bit4=NMI ack; bit0=sound-chan sel; bit2=switch strobe; bit5=sound strobe)
	ld (0c001h),a		;0133	32 01 c0	2 . .  ; [ram_port81_shadow - Shadow register for PORT_CONTROL]
	ld a,(0c001h)		;0136	3a 01 c0	: . .  ; [ram_port81_shadow - Shadow register for PORT_CONTROL]
	and 0fbh		;0139	e6 fb		. .
	and 0fdh		;013b	e6 fd		. .
	ld (0c001h),a		;013d	32 01 c0	2 . .  ; [ram_port81_shadow - Shadow register for PORT_CONTROL]
	out (081h),a		;0140	d3 81		. .  ; >> PORT_CONTROL - control → 80188 (bit4=NMI ack; bit0=sound-chan sel; bit2=switch strobe; bit5=sound strobe)
	ei			;0142	fb		.
	ret			;0143	c9		.

; ─────────────────────────────────────────────────────────────────────────────
; send_sound_cmd (0x0144)
; Forward sound command (C008) to the 80188 over J1; the 80188 drives the OKI MSM6376
; XREF: 22 references from 0x08BB, 0x08CE, 0x08E7, 0x08FA, 0x0913, 0x0926, 0x093F, 0x0952 ... (+14 more)
; ─────────────────────────────────────────────────────────────────────────────
send_sound_cmd:
	in a,(001h)		;0144	db 01		. .  ; << PORT_STATUS - status (bit1 = 80188 inter-board handshake ready, via J1 BUSY/AD)
	bit 1,a			;0146	cb 4f		. O
	jr z,send_sound_cmd		;0148	28 fa		( .
	di			;014a	f3		.
	ld hl,0c045h		;014b	21 45 c0	! E .
	ld (hl),020h		;014e	36 20		6  
	ld a,(0c001h)		;0150	3a 01 c0	: . .  ; [ram_port81_shadow - Shadow register for PORT_CONTROL]
	or 003h			;0153	f6 03		. .
	out (081h),a		;0155	d3 81		. .  ; >> PORT_CONTROL - control → 80188 (bit4=NMI ack; bit0=sound-chan sel; bit2=switch strobe; bit5=sound strobe)
	ld (0c001h),a		;0157	32 01 c0	2 . .  ; [ram_port81_shadow - Shadow register for PORT_CONTROL]
	ld a,(0c008h)		;015a	3a 08 c0	: . .  ; [ram_sound_cmd - Current sound command byte]
	out (080h),a		;015d	d3 80		. .  ; >> PORT_SOUND_DATA - inter-board data byte → 80188 over J1; 80188 drives the OKI, not the Z80
	ld a,(0c001h)		;015f	3a 01 c0	: . .  ; [ram_port81_shadow - Shadow register for PORT_CONTROL]
	or 020h			;0162	f6 20		.  
	out (081h),a		;0164	d3 81		. .  ; >> PORT_CONTROL - control → 80188 (bit4=NMI ack; bit0=sound-chan sel; bit2=switch strobe; bit5=sound strobe)
	nop			;0166	00		.
	nop			;0167	00		.
	nop			;0168	00		.
	and 0dfh		;0169	e6 df		. .
	out (081h),a		;016b	d3 81		. .  ; >> PORT_CONTROL - control → 80188 (bit4=NMI ack; bit0=sound-chan sel; bit2=switch strobe; bit5=sound strobe)
	ld a,(0c001h)		;016d	3a 01 c0	: . .  ; [ram_port81_shadow - Shadow register for PORT_CONTROL]
	and 0fdh		;0170	e6 fd		. .
	ld (0c001h),a		;0172	32 01 c0	2 . .  ; [ram_port81_shadow - Shadow register for PORT_CONTROL]
	out (081h),a		;0175	d3 81		. .  ; >> PORT_CONTROL - control → 80188 (bit4=NMI ack; bit0=sound-chan sel; bit2=switch strobe; bit5=sound strobe)
	ld hl,0c045h		;0177	21 45 c0	! E .
	ld (hl),020h		;017a	36 20		6  
	ei			;017c	fb		.
	ret			;017d	c9		.

; ─────────────────────────────────────────────────────────────────────────────
; wait_status_ready (0x017E)
; Wait for port 0x01 bit ready, with timeout
; XREF: 1 references from 0x044F
; ─────────────────────────────────────────────────────────────────────────────
wait_status_ready:
	in a,(001h)		;017e	db 01		. .  ; << PORT_STATUS - status (bit1 = 80188 inter-board handshake ready, via J1 BUSY/AD)
	bit 1,a			;0180	cb 4f		. O
	jr z,wait_status_ready		;0182	28 fa		( .
	ld hl,0c045h		;0184	21 45 c0	! E .
	ld (hl),020h		;0187	36 20		6  
	ld a,(0c001h)		;0189	3a 01 c0	: . .  ; [ram_port81_shadow - Shadow register for PORT_CONTROL]
	or 003h			;018c	f6 03		. .
	out (081h),a		;018e	d3 81		. .  ; >> PORT_CONTROL - control → 80188 (bit4=NMI ack; bit0=sound-chan sel; bit2=switch strobe; bit5=sound strobe)
l0190h:
	ld (0c001h),a		;0190	32 01 c0	2 . .  ; [ram_port81_shadow - Shadow register for PORT_CONTROL]
	ld a,(0c008h)		;0193	3a 08 c0	: . .  ; [ram_sound_cmd - Current sound command byte]
	out (080h),a		;0196	d3 80		. .  ; >> PORT_SOUND_DATA - inter-board data byte → 80188 over J1; 80188 drives the OKI, not the Z80
	ld a,(0c001h)		;0198	3a 01 c0	: . .  ; [ram_port81_shadow - Shadow register for PORT_CONTROL]
	or 020h			;019b	f6 20		.  
	out (081h),a		;019d	d3 81		. .  ; >> PORT_CONTROL - control → 80188 (bit4=NMI ack; bit0=sound-chan sel; bit2=switch strobe; bit5=sound strobe)
	nop			;019f	00		.
	nop			;01a0	00		.
	nop			;01a1	00		.
	and 0dfh		;01a2	e6 df		. .
	out (081h),a		;01a4	d3 81		. .  ; >> PORT_CONTROL - control → 80188 (bit4=NMI ack; bit0=sound-chan sel; bit2=switch strobe; bit5=sound strobe)
	ld a,(0c001h)		;01a6	3a 01 c0	: . .  ; [ram_port81_shadow - Shadow register for PORT_CONTROL]
	and 0fdh		;01a9	e6 fd		. .
	ld (0c001h),a		;01ab	32 01 c0	2 . .  ; [ram_port81_shadow - Shadow register for PORT_CONTROL]
	out (081h),a		;01ae	d3 81		. .  ; >> PORT_CONTROL - control → 80188 (bit4=NMI ack; bit0=sound-chan sel; bit2=switch strobe; bit5=sound strobe)
	ld hl,0c045h		;01b0	21 45 c0	! E .
	ld (hl),020h		;01b3	36 20		6  
	ret			;01b5	c9		.

; ─────────────────────────────────────────────────────────────────────────────
; switch_debounce (0x01B6)
; Switch debounce/read utility (25 calls - MOST CALLED)
; XREF: 25 references from 0x0E03, 0x0E5A, 0x0E6F, 0x0E84, 0x0E99, 0x0EAE, 0x0EC6, 0x0EDB ... (+17 more)
; ─────────────────────────────────────────────────────────────────────────────
switch_debounce:
	in a,(001h)		;01b6	db 01		. .  ; << PORT_STATUS - status (bit1 = 80188 inter-board handshake ready, via J1 BUSY/AD)
	bit 1,a			;01b8	cb 4f		. O
	jr z,switch_debounce		;01ba	28 fa		( .
	di			;01bc	f3		.
	ld a,(0c001h)		;01bd	3a 01 c0	: . .  ; [ram_port81_shadow - Shadow register for PORT_CONTROL]
	or 002h			;01c0	f6 02		. .
	and 0feh		;01c2	e6 fe		. .
	out (081h),a		;01c4	d3 81		. .  ; >> PORT_CONTROL - control → 80188 (bit4=NMI ack; bit0=sound-chan sel; bit2=switch strobe; bit5=sound strobe)
	ld (0c001h),a		;01c6	32 01 c0	2 . .  ; [ram_port81_shadow - Shadow register for PORT_CONTROL]
	ld a,(0c001h)		;01c9	3a 01 c0	: . .  ; [ram_port81_shadow - Shadow register for PORT_CONTROL]
	or 040h			;01cc	f6 40		. @
	ld (0c001h),a		;01ce	32 01 c0	2 . .  ; [ram_port81_shadow - Shadow register for PORT_CONTROL]
	out (081h),a		;01d1	d3 81		. .  ; >> PORT_CONTROL - control → 80188 (bit4=NMI ack; bit0=sound-chan sel; bit2=switch strobe; bit5=sound strobe)
	nop			;01d3	00		.
	nop			;01d4	00		.
	nop			;01d5	00		.
	in a,(000h)		;01d6	db 00		. .  ; << PORT_DIRECT_SW_0 - Direct switches input (flipper buttons, misc)
	ld (0c060h),a		;01d8	32 60 c0	2 ` .  ; [ram_direct_sw_shadow - Direct switch shadow (port 0x00 last read)]
	ld a,(0c001h)		;01db	3a 01 c0	: . .  ; [ram_port81_shadow - Shadow register for PORT_CONTROL]
	and 0bfh		;01de	e6 bf		. .
	ld (0c001h),a		;01e0	32 01 c0	2 . .  ; [ram_port81_shadow - Shadow register for PORT_CONTROL]
	out (081h),a		;01e3	d3 81		. .  ; >> PORT_CONTROL - control → 80188 (bit4=NMI ack; bit0=sound-chan sel; bit2=switch strobe; bit5=sound strobe)
	ld a,(0c001h)		;01e5	3a 01 c0	: . .  ; [ram_port81_shadow - Shadow register for PORT_CONTROL]
	and 0fdh		;01e8	e6 fd		. .
	ld (0c001h),a		;01ea	32 01 c0	2 . .  ; [ram_port81_shadow - Shadow register for PORT_CONTROL]
	out (081h),a		;01ed	d3 81		. .  ; >> PORT_CONTROL - control → 80188 (bit4=NMI ack; bit0=sound-chan sel; bit2=switch strobe; bit5=sound strobe)
	ei			;01ef	fb		.
	ret			;01f0	c9		.
	rst 38h			;01f1	ff		.
	rst 38h			;01f2	ff		.
	rst 38h			;01f3	ff		.
	rst 38h			;01f4	ff		.
	rst 38h			;01f5	ff		.
	rst 38h			;01f6	ff		.
	rst 38h			;01f7	ff		.
	rst 38h			;01f8	ff		.
	rst 38h			;01f9	ff		.
	rst 38h			;01fa	ff		.
	rst 38h			;01fb	ff		.
	rst 38h			;01fc	ff		.
	rst 38h			;01fd	ff		.
	rst 38h			;01fe	ff		.
	rst 38h			;01ff	ff		.
l0200h:
	rst 38h			;0200	ff		.
l0201h:
	rst 38h			;0201	ff		.
l0202h:
	rst 38h			;0202	ff		.
	rst 38h			;0203	ff		.
	rst 38h			;0204	ff		.
	rst 38h			;0205	ff		.
	rst 38h			;0206	ff		.
	rst 38h			;0207	ff		.
l0208h:
	rst 38h			;0208	ff		.
	rst 38h			;0209	ff		.
	rst 38h			;020a	ff		.
	rst 38h			;020b	ff		.
	rst 38h			;020c	ff		.
	rst 38h			;020d	ff		.
	rst 38h			;020e	ff		.
	rst 38h			;020f	ff		.
l0210h:
	rst 38h			;0210	ff		.
	rst 38h			;0211	ff		.
	rst 38h			;0212	ff		.
	rst 38h			;0213	ff		.
	rst 38h			;0214	ff		.
	rst 38h			;0215	ff		.
	rst 38h			;0216	ff		.
	rst 38h			;0217	ff		.
	rst 38h			;0218	ff		.
	rst 38h			;0219	ff		.
	rst 38h			;021a	ff		.
	rst 38h			;021b	ff		.
	rst 38h			;021c	ff		.
	rst 38h			;021d	ff		.
	rst 38h			;021e	ff		.
	rst 38h			;021f	ff		.
	rst 38h			;0220	ff		.
	rst 38h			;0221	ff		.
	rst 38h			;0222	ff		.
	rst 38h			;0223	ff		.
	rst 38h			;0224	ff		.
	rst 38h			;0225	ff		.
	rst 38h			;0226	ff		.
	rst 38h			;0227	ff		.
	rst 38h			;0228	ff		.
	rst 38h			;0229	ff		.
	rst 38h			;022a	ff		.
	rst 38h			;022b	ff		.
	rst 38h			;022c	ff		.
	rst 38h			;022d	ff		.
	rst 38h			;022e	ff		.
	rst 38h			;022f	ff		.
	rst 38h			;0230	ff		.
	rst 38h			;0231	ff		.
	rst 38h			;0232	ff		.
	rst 38h			;0233	ff		.
	rst 38h			;0234	ff		.
	rst 38h			;0235	ff		.
	rst 38h			;0236	ff		.
	rst 38h			;0237	ff		.
	rst 38h			;0238	ff		.
	rst 38h			;0239	ff		.
	rst 38h			;023a	ff		.
	rst 38h			;023b	ff		.
	rst 38h			;023c	ff		.
	rst 38h			;023d	ff		.
	rst 38h			;023e	ff		.
	rst 38h			;023f	ff		.
l0240h:
	rst 38h			;0240	ff		.
	rst 38h			;0241	ff		.
	rst 38h			;0242	ff		.
	rst 38h			;0243	ff		.
	rst 38h			;0244	ff		.
	rst 38h			;0245	ff		.
	rst 38h			;0246	ff		.
	rst 38h			;0247	ff		.
	rst 38h			;0248	ff		.
	rst 38h			;0249	ff		.
	rst 38h			;024a	ff		.
	rst 38h			;024b	ff		.
	rst 38h			;024c	ff		.
	rst 38h			;024d	ff		.
	rst 38h			;024e	ff		.
	rst 38h			;024f	ff		.
	rst 38h			;0250	ff		.
	rst 38h			;0251	ff		.
	rst 38h			;0252	ff		.
	rst 38h			;0253	ff		.
	rst 38h			;0254	ff		.
	rst 38h			;0255	ff		.
	rst 38h			;0256	ff		.
	rst 38h			;0257	ff		.
	rst 38h			;0258	ff		.
	rst 38h			;0259	ff		.
	rst 38h			;025a	ff		.
	rst 38h			;025b	ff		.
	rst 38h			;025c	ff		.
	rst 38h			;025d	ff		.
	rst 38h			;025e	ff		.
	rst 38h			;025f	ff		.
	rst 38h			;0260	ff		.
	rst 38h			;0261	ff		.
	rst 38h			;0262	ff		.
	rst 38h			;0263	ff		.
	rst 38h			;0264	ff		.
	rst 38h			;0265	ff		.
	rst 38h			;0266	ff		.
	rst 38h			;0267	ff		.
	rst 38h			;0268	ff		.
	rst 38h			;0269	ff		.
	rst 38h			;026a	ff		.
	rst 38h			;026b	ff		.
	rst 38h			;026c	ff		.
	rst 38h			;026d	ff		.
	rst 38h			;026e	ff		.
	rst 38h			;026f	ff		.
	rst 38h			;0270	ff		.
	rst 38h			;0271	ff		.
	rst 38h			;0272	ff		.
	rst 38h			;0273	ff		.
	rst 38h			;0274	ff		.
	rst 38h			;0275	ff		.
	rst 38h			;0276	ff		.
	rst 38h			;0277	ff		.
	rst 38h			;0278	ff		.
	rst 38h			;0279	ff		.
	rst 38h			;027a	ff		.
	rst 38h			;027b	ff		.
	rst 38h			;027c	ff		.
	rst 38h			;027d	ff		.
	rst 38h			;027e	ff		.
	rst 38h			;027f	ff		.
sub_0280h:
	rst 38h			;0280	ff		.
	rst 38h			;0281	ff		.
	rst 38h			;0282	ff		.
	rst 38h			;0283	ff		.
	rst 38h			;0284	ff		.
	rst 38h			;0285	ff		.
	rst 38h			;0286	ff		.
	rst 38h			;0287	ff		.
l0288h:
	rst 38h			;0288	ff		.
	rst 38h			;0289	ff		.
	rst 38h			;028a	ff		.
	rst 38h			;028b	ff		.
	rst 38h			;028c	ff		.
	rst 38h			;028d	ff		.
	rst 38h			;028e	ff		.
	rst 38h			;028f	ff		.
	rst 38h			;0290	ff		.
	rst 38h			;0291	ff		.
	rst 38h			;0292	ff		.
	rst 38h			;0293	ff		.
	rst 38h			;0294	ff		.
	rst 38h			;0295	ff		.
	rst 38h			;0296	ff		.
	rst 38h			;0297	ff		.
	rst 38h			;0298	ff		.
	rst 38h			;0299	ff		.
	rst 38h			;029a	ff		.
	rst 38h			;029b	ff		.
	rst 38h			;029c	ff		.
	rst 38h			;029d	ff		.
	rst 38h			;029e	ff		.
	rst 38h			;029f	ff		.
	rst 38h			;02a0	ff		.
	rst 38h			;02a1	ff		.
	rst 38h			;02a2	ff		.
	rst 38h			;02a3	ff		.
	rst 38h			;02a4	ff		.
	rst 38h			;02a5	ff		.
	rst 38h			;02a6	ff		.
	rst 38h			;02a7	ff		.
	rst 38h			;02a8	ff		.
	rst 38h			;02a9	ff		.
	rst 38h			;02aa	ff		.
	rst 38h			;02ab	ff		.
	rst 38h			;02ac	ff		.
	rst 38h			;02ad	ff		.
	rst 38h			;02ae	ff		.
	rst 38h			;02af	ff		.
	rst 38h			;02b0	ff		.
	rst 38h			;02b1	ff		.
	rst 38h			;02b2	ff		.
	rst 38h			;02b3	ff		.
	rst 38h			;02b4	ff		.
	rst 38h			;02b5	ff		.
	rst 38h			;02b6	ff		.
	rst 38h			;02b7	ff		.
	rst 38h			;02b8	ff		.
	rst 38h			;02b9	ff		.
	rst 38h			;02ba	ff		.
	rst 38h			;02bb	ff		.
	rst 38h			;02bc	ff		.
	rst 38h			;02bd	ff		.
	rst 38h			;02be	ff		.
	rst 38h			;02bf	ff		.
	rst 38h			;02c0	ff		.
	rst 38h			;02c1	ff		.
	rst 38h			;02c2	ff		.
	rst 38h			;02c3	ff		.
	rst 38h			;02c4	ff		.
	rst 38h			;02c5	ff		.
	rst 38h			;02c6	ff		.
	rst 38h			;02c7	ff		.
	rst 38h			;02c8	ff		.
	rst 38h			;02c9	ff		.
	rst 38h			;02ca	ff		.
	rst 38h			;02cb	ff		.
	rst 38h			;02cc	ff		.
	rst 38h			;02cd	ff		.
	rst 38h			;02ce	ff		.
	rst 38h			;02cf	ff		.
	rst 38h			;02d0	ff		.
	rst 38h			;02d1	ff		.
	rst 38h			;02d2	ff		.
	rst 38h			;02d3	ff		.
	rst 38h			;02d4	ff		.
	rst 38h			;02d5	ff		.
	rst 38h			;02d6	ff		.
	rst 38h			;02d7	ff		.
	rst 38h			;02d8	ff		.
	rst 38h			;02d9	ff		.
	rst 38h			;02da	ff		.
	rst 38h			;02db	ff		.
	rst 38h			;02dc	ff		.
	rst 38h			;02dd	ff		.
	rst 38h			;02de	ff		.
	rst 38h			;02df	ff		.
	rst 38h			;02e0	ff		.
	rst 38h			;02e1	ff		.
	rst 38h			;02e2	ff		.
	rst 38h			;02e3	ff		.
	rst 38h			;02e4	ff		.
	rst 38h			;02e5	ff		.
	rst 38h			;02e6	ff		.
	rst 38h			;02e7	ff		.
	rst 38h			;02e8	ff		.
	rst 38h			;02e9	ff		.
	rst 38h			;02ea	ff		.
	rst 38h			;02eb	ff		.
	rst 38h			;02ec	ff		.
	rst 38h			;02ed	ff		.
	rst 38h			;02ee	ff		.
	rst 38h			;02ef	ff		.
	rst 38h			;02f0	ff		.
	rst 38h			;02f1	ff		.
	rst 38h			;02f2	ff		.
	rst 38h			;02f3	ff		.
	rst 38h			;02f4	ff		.
	rst 38h			;02f5	ff		.
	rst 38h			;02f6	ff		.
	rst 38h			;02f7	ff		.
	rst 38h			;02f8	ff		.
	rst 38h			;02f9	ff		.
	rst 38h			;02fa	ff		.
	rst 38h			;02fb	ff		.
	rst 38h			;02fc	ff		.
	rst 38h			;02fd	ff		.
	rst 38h			;02fe	ff		.
	rst 38h			;02ff	ff		.
	rst 38h			;0300	ff		.
	rst 38h			;0301	ff		.
	rst 38h			;0302	ff		.
	rst 38h			;0303	ff		.
	rst 38h			;0304	ff		.
	rst 38h			;0305	ff		.
	rst 38h			;0306	ff		.
	rst 38h			;0307	ff		.
	rst 38h			;0308	ff		.
	rst 38h			;0309	ff		.
	rst 38h			;030a	ff		.
	rst 38h			;030b	ff		.
	rst 38h			;030c	ff		.
	rst 38h			;030d	ff		.
	rst 38h			;030e	ff		.
	rst 38h			;030f	ff		.
	rst 38h			;0310	ff		.
	rst 38h			;0311	ff		.
	rst 38h			;0312	ff		.
	rst 38h			;0313	ff		.
	rst 38h			;0314	ff		.
	rst 38h			;0315	ff		.
	rst 38h			;0316	ff		.
	rst 38h			;0317	ff		.
	rst 38h			;0318	ff		.
	rst 38h			;0319	ff		.
	rst 38h			;031a	ff		.
	rst 38h			;031b	ff		.
	rst 38h			;031c	ff		.
	rst 38h			;031d	ff		.
	rst 38h			;031e	ff		.
	rst 38h			;031f	ff		.
l0320h:
	rst 38h			;0320	ff		.
	rst 38h			;0321	ff		.
	rst 38h			;0322	ff		.
	rst 38h			;0323	ff		.
	rst 38h			;0324	ff		.
	rst 38h			;0325	ff		.
	rst 38h			;0326	ff		.
	rst 38h			;0327	ff		.
	rst 38h			;0328	ff		.
	rst 38h			;0329	ff		.
	rst 38h			;032a	ff		.
	rst 38h			;032b	ff		.
	rst 38h			;032c	ff		.
	rst 38h			;032d	ff		.
	rst 38h			;032e	ff		.
	rst 38h			;032f	ff		.
	rst 38h			;0330	ff		.
	rst 38h			;0331	ff		.
	rst 38h			;0332	ff		.
	rst 38h			;0333	ff		.
	rst 38h			;0334	ff		.
	rst 38h			;0335	ff		.
	rst 38h			;0336	ff		.
	rst 38h			;0337	ff		.
	rst 38h			;0338	ff		.
	rst 38h			;0339	ff		.
	rst 38h			;033a	ff		.
	rst 38h			;033b	ff		.
	rst 38h			;033c	ff		.
	rst 38h			;033d	ff		.
	rst 38h			;033e	ff		.
	rst 38h			;033f	ff		.
	rst 38h			;0340	ff		.
	rst 38h			;0341	ff		.
	rst 38h			;0342	ff		.
	rst 38h			;0343	ff		.
	rst 38h			;0344	ff		.
	rst 38h			;0345	ff		.
	rst 38h			;0346	ff		.
	rst 38h			;0347	ff		.
	rst 38h			;0348	ff		.
	rst 38h			;0349	ff		.
	rst 38h			;034a	ff		.
	rst 38h			;034b	ff		.
	rst 38h			;034c	ff		.
	rst 38h			;034d	ff		.
	rst 38h			;034e	ff		.
	rst 38h			;034f	ff		.
	rst 38h			;0350	ff		.
	rst 38h			;0351	ff		.
	rst 38h			;0352	ff		.
	rst 38h			;0353	ff		.
	rst 38h			;0354	ff		.
	rst 38h			;0355	ff		.
	rst 38h			;0356	ff		.
	rst 38h			;0357	ff		.
	rst 38h			;0358	ff		.
	rst 38h			;0359	ff		.
	rst 38h			;035a	ff		.
	rst 38h			;035b	ff		.
	rst 38h			;035c	ff		.
	rst 38h			;035d	ff		.
	rst 38h			;035e	ff		.
	rst 38h			;035f	ff		.
	rst 38h			;0360	ff		.
	rst 38h			;0361	ff		.
	rst 38h			;0362	ff		.
	rst 38h			;0363	ff		.
	rst 38h			;0364	ff		.
	rst 38h			;0365	ff		.
	rst 38h			;0366	ff		.
	rst 38h			;0367	ff		.
	rst 38h			;0368	ff		.
	rst 38h			;0369	ff		.
	rst 38h			;036a	ff		.
	rst 38h			;036b	ff		.
	rst 38h			;036c	ff		.
	rst 38h			;036d	ff		.
	rst 38h			;036e	ff		.
	rst 38h			;036f	ff		.
	rst 38h			;0370	ff		.
	rst 38h			;0371	ff		.
	rst 38h			;0372	ff		.
	rst 38h			;0373	ff		.
	rst 38h			;0374	ff		.
	rst 38h			;0375	ff		.
	rst 38h			;0376	ff		.
	rst 38h			;0377	ff		.
	rst 38h			;0378	ff		.
	rst 38h			;0379	ff		.
	rst 38h			;037a	ff		.
	rst 38h			;037b	ff		.
	rst 38h			;037c	ff		.
	rst 38h			;037d	ff		.
	rst 38h			;037e	ff		.
	rst 38h			;037f	ff		.
	rst 38h			;0380	ff		.
	rst 38h			;0381	ff		.
	rst 38h			;0382	ff		.
	rst 38h			;0383	ff		.
	rst 38h			;0384	ff		.
	rst 38h			;0385	ff		.
	rst 38h			;0386	ff		.
	rst 38h			;0387	ff		.
	rst 38h			;0388	ff		.
	rst 38h			;0389	ff		.
	rst 38h			;038a	ff		.
	rst 38h			;038b	ff		.
	rst 38h			;038c	ff		.
	rst 38h			;038d	ff		.
	rst 38h			;038e	ff		.
	rst 38h			;038f	ff		.
	rst 38h			;0390	ff		.
	rst 38h			;0391	ff		.
	rst 38h			;0392	ff		.
	rst 38h			;0393	ff		.
	rst 38h			;0394	ff		.
	rst 38h			;0395	ff		.
	rst 38h			;0396	ff		.
	rst 38h			;0397	ff		.
	rst 38h			;0398	ff		.
	rst 38h			;0399	ff		.
	rst 38h			;039a	ff		.
	rst 38h			;039b	ff		.
	rst 38h			;039c	ff		.
	rst 38h			;039d	ff		.
	rst 38h			;039e	ff		.
	rst 38h			;039f	ff		.
	rst 38h			;03a0	ff		.
	rst 38h			;03a1	ff		.
	rst 38h			;03a2	ff		.
	rst 38h			;03a3	ff		.
	rst 38h			;03a4	ff		.
	rst 38h			;03a5	ff		.
	rst 38h			;03a6	ff		.
	rst 38h			;03a7	ff		.
	rst 38h			;03a8	ff		.
	rst 38h			;03a9	ff		.
	rst 38h			;03aa	ff		.
	rst 38h			;03ab	ff		.
	rst 38h			;03ac	ff		.
	rst 38h			;03ad	ff		.
	rst 38h			;03ae	ff		.
	rst 38h			;03af	ff		.
	rst 38h			;03b0	ff		.
	rst 38h			;03b1	ff		.
	rst 38h			;03b2	ff		.
	rst 38h			;03b3	ff		.
	rst 38h			;03b4	ff		.
	rst 38h			;03b5	ff		.
	rst 38h			;03b6	ff		.
	rst 38h			;03b7	ff		.
	rst 38h			;03b8	ff		.
	rst 38h			;03b9	ff		.
	rst 38h			;03ba	ff		.
	rst 38h			;03bb	ff		.
	rst 38h			;03bc	ff		.
	rst 38h			;03bd	ff		.
	rst 38h			;03be	ff		.
	rst 38h			;03bf	ff		.
	rst 38h			;03c0	ff		.
	rst 38h			;03c1	ff		.
	rst 38h			;03c2	ff		.
	rst 38h			;03c3	ff		.
	rst 38h			;03c4	ff		.
	rst 38h			;03c5	ff		.
	rst 38h			;03c6	ff		.
	rst 38h			;03c7	ff		.
	rst 38h			;03c8	ff		.
	rst 38h			;03c9	ff		.
	rst 38h			;03ca	ff		.
	rst 38h			;03cb	ff		.
	rst 38h			;03cc	ff		.
	rst 38h			;03cd	ff		.
	rst 38h			;03ce	ff		.
	rst 38h			;03cf	ff		.
	rst 38h			;03d0	ff		.
	rst 38h			;03d1	ff		.
	rst 38h			;03d2	ff		.
	rst 38h			;03d3	ff		.
	rst 38h			;03d4	ff		.
	rst 38h			;03d5	ff		.
	rst 38h			;03d6	ff		.
	rst 38h			;03d7	ff		.
	rst 38h			;03d8	ff		.
	rst 38h			;03d9	ff		.
	rst 38h			;03da	ff		.
	rst 38h			;03db	ff		.
	rst 38h			;03dc	ff		.
	rst 38h			;03dd	ff		.
	rst 38h			;03de	ff		.
	rst 38h			;03df	ff		.
	rst 38h			;03e0	ff		.
	rst 38h			;03e1	ff		.
	rst 38h			;03e2	ff		.
	rst 38h			;03e3	ff		.
	rst 38h			;03e4	ff		.
	rst 38h			;03e5	ff		.
	rst 38h			;03e6	ff		.
	rst 38h			;03e7	ff		.
l03e8h:
	rst 38h			;03e8	ff		.
	rst 38h			;03e9	ff		.
	rst 38h			;03ea	ff		.
	rst 38h			;03eb	ff		.
	rst 38h			;03ec	ff		.
	rst 38h			;03ed	ff		.
	rst 38h			;03ee	ff		.
	rst 38h			;03ef	ff		.
	rst 38h			;03f0	ff		.
	rst 38h			;03f1	ff		.
	rst 38h			;03f2	ff		.
	rst 38h			;03f3	ff		.
	rst 38h			;03f4	ff		.
	rst 38h			;03f5	ff		.
	rst 38h			;03f6	ff		.
	rst 38h			;03f7	ff		.
	rst 38h			;03f8	ff		.
	rst 38h			;03f9	ff		.
	rst 38h			;03fa	ff		.
	rst 38h			;03fb	ff		.
	rst 38h			;03fc	ff		.
	rst 38h			;03fd	ff		.
	rst 38h			;03fe	ff		.
	rst 38h			;03ff	ff		.

; =============================================================================
; SYSTEM INITIALIZATION
; =============================================================================

; ─────────────────────────────────────────────────────────────────────────────
; main_init (0x0400)
; Main init: DI, IM1, SP=C7FF, clear RAM, init I/O, EI, loop
; XREF: 6 references from 0x0007, 0x000B, 0x000F, 0x2DDE, 0x2E4D, 0x3F2D
; ─────────────────────────────────────────────────────────────────────────────
main_init:
	di			;0400	f3		.
l0401h:
	im 1			;0401	ed 56		. V
	ld sp,0c7ffh		;0403	31 ff c7	1 . .
	call init_all_io		;0406	cd 1b 04	. . .
l0409h:
	call init_clear_work_ram		;0409	cd 5a 04	. Z .
	ei			;040c	fb		.
	call init_extended_setup		;040d	cd a7 36	. . 6
	ld a,047h		;0410	3e 47		> G
	ld (0c0fch),a		;0412	32 fc c0	2 . .  ; [ram_switch_mailbox - *** MAILBOX BYTE *** Switch code → 80188 (86 refs!)]
	call send_to_80188		;0415	cd 16 01	. . .  ; → send_to_80188
	jp main_loop		;0418	c3 4c 0d	. L .  ; → main_loop
init_all_io:
	ld a,030h		;041b	3e 30		> 0
	ld (0c007h),a		;041d	32 07 c0	2 . .  ; [ram_port87_shadow - Shadow register for PORT_MATRIX_ROW]
	out (087h),a		;0420	d3 87		. .  ; >> PORT_MATRIX_ROW - Switch matrix row strobe select
	ld a,0ffh		;0422	3e ff		> .
	ld (0c005h),a		;0424	32 05 c0	2 . .  ; [ram_port85_shadow - Shadow register for PORT_SOLENOID_1]
	out (085h),a		;0427	d3 85		. .  ; >> PORT_SOLENOID_1 - Solenoid bank 1 (b0=sol1, b2=sol2, b4=sol4, b5=sol3)
	ld (0c006h),a		;0429	32 06 c0	2 . .  ; [ram_port86_shadow - Shadow register for PORT_SOLENOID_2]
	out (086h),a		;042c	d3 86		. .  ; >> PORT_SOLENOID_2 - Solenoid bank 2 (b6=sol5, other kickers/diverters)
	ld a,000h		;042e	3e 00		> .
	ld (0c003h),a		;0430	32 03 c0	2 . .  ; [ram_port83_shadow - Shadow register for PORT_LAMP_ROW1]
	out (083h),a		;0433	d3 83		. .  ; >> PORT_LAMP_ROW1 - Lamp matrix row data byte 1 (8 lamps)
	ld a,000h		;0435	3e 00		> .
	ld (0c004h),a		;0437	32 04 c0	2 . .  ; [ram_port84_shadow - Shadow register for PORT_LAMP_ROW2]
	out (084h),a		;043a	d3 84		. .  ; >> PORT_LAMP_ROW2 - Lamp matrix row data byte 2 (8 lamps)
	ld a,000h		;043c	3e 00		> .
	ld (0c000h),a		;043e	32 00 c0	2 . .  ; [ram_port80_shadow - Shadow register for PORT_SOUND_DATA]
	out (080h),a		;0441	d3 80		. .  ; >> PORT_SOUND_DATA - inter-board data byte → 80188 over J1; 80188 drives the OKI, not the Z80
	ld a,000h		;0443	3e 00		> .
	ld (0c001h),a		;0445	32 01 c0	2 . .  ; [ram_port81_shadow - Shadow register for PORT_CONTROL]
	out (081h),a		;0448	d3 81		. .  ; >> PORT_CONTROL - control → 80188 (bit4=NMI ack; bit0=sound-chan sel; bit2=switch strobe; bit5=sound strobe)
	ld a,0ffh		;044a	3e ff		> .
	ld (0c008h),a		;044c	32 08 c0	2 . .  ; [ram_sound_cmd - Current sound command byte]
	call wait_status_ready		;044f	cd 7e 01	. ~ .  ; → wait_status_ready
	ld a,000h		;0452	3e 00		> .
	ld (0c002h),a		;0454	32 02 c0	2 . .  ; [ram_port82_shadow - Shadow register for PORT_LAMP_COL]
	out (082h),a		;0457	d3 82		. .  ; >> PORT_LAMP_COL - Lamp matrix column strobe select
	ret			;0459	c9		.
init_clear_work_ram:
	ld hl,0c009h		;045a	21 09 c0	! . .
	ld b,0a8h		;045d	06 a8		. .
l045fh:
	ld (hl),000h		;045f	36 00		6 .
	inc hl			;0461	23		#
	djnz l045fh		;0462	10 fb		. .
	ld hl,0c061h		;0464	21 61 c0	! a .
	ld b,0f0h		;0467	06 f0		. .
l0469h:
	ld (hl),000h		;0469	36 00		6 .
	inc hl			;046b	23		#
	djnz l0469h		;046c	10 fb		. .
	ld hl,scan_begin_cycle		;046e	21 73 2e	! s .
	ld (0c0e5h),hl		;0471	22 e5 c0	" . .  ; [ram_scan_state_lo - Scan state machine pointer low byte]
	ld hl,l3457h		;0474	21 57 34	! W 4
	ld (0c117h),hl		;0477	22 17 c1	" . .  ; [ram_sol_active_mask - Active solenoid bitmask]
	ld hl,0c076h		;047a	21 76 c0	! v .
	ld (0c072h),hl		;047d	22 72 c0	" r .  ; [ram_sw_queue_rptr - Switch event queue read pointer]
	ld (0c074h),hl		;0480	22 74 c0	" t .  ; [ram_nmi_state_ptr - NMI state machine HL pointer (saved)]
	ld (hl),000h		;0483	36 00		6 .
	ld hl,reset_entry		;0485	21 00 00	! . .
	ld (0c04ch),hl		;0488	22 4c c0	" L .  ; [ram_sw_queue_wptr - Switch event queue write pointer]
	ld (0c04fh),hl		;048b	22 4f c0	" O .  ; [ram_timer_aux - Auxiliary timer counter]
	ld (0c040h),hl		;048e	22 40 c0	" @ .
	ld (0c03eh),hl		;0491	22 3e c0	" > .
	ld (0c049h),hl		;0494	22 49 c0	" I .
	xor a			;0497	af		.
	ld (0c04eh),a		;0498	32 4e c0	2 N .  ; [ram_timer_flag - Main timer flag (controls game timing)]
	ld (0c051h),a		;049b	32 51 c0	2 Q .  ; [ram_game_timer - Game timer (ball time / bonus countdown)]
	ld (0c052h),a		;049e	32 52 c0	2 R .  ; [ram_timer_52 - Timer register 0x52]
	ld (0c053h),a		;04a1	32 53 c0	2 S .
	ld (0c0fbh),a		;04a4	32 fb c0	2 . .  ; [ram_cmd_done_flag - Command completion flag]
	ld (0c0ffh),a		;04a7	32 ff c0	2 . .
	ld (0c100h),a		;04aa	32 00 c1	2 . .
	ld (0c101h),a		;04ad	32 01 c1	2 . .
	ld (0c102h),a		;04b0	32 02 c1	2 . .
	ld (0c103h),a		;04b3	32 03 c1	2 . .
	ld (0c104h),a		;04b6	32 04 c1	2 . .
	ld (0c105h),a		;04b9	32 05 c1	2 . .
	ld (0c106h),a		;04bc	32 06 c1	2 . .
	ld (0c10fh),a		;04bf	32 0f c1	2 . .
	ld (0c110h),a		;04c2	32 10 c1	2 . .
	ld (0c111h),a		;04c5	32 11 c1	2 . .
	ld (0c112h),a		;04c8	32 12 c1	2 . .
	ld (0c113h),a		;04cb	32 13 c1	2 . .
	ld (0c114h),a		;04ce	32 14 c1	2 . .
	ld (0c115h),a		;04d1	32 15 c1	2 . .
	ld (0c116h),a		;04d4	32 16 c1	2 . .
	ld (0c01eh),a		;04d7	32 1e c0	2 . .
	ld (0c01fh),a		;04da	32 1f c0	2 . .
	ld (0c020h),a		;04dd	32 20 c0	2   .
	ld (0c021h),a		;04e0	32 21 c0	2 ! .
	ld (0c06ah),a		;04e3	32 6a c0	2 j .  ; [ram_ball_in_play - Ball-in-play counter]
	ld (0c054h),a		;04e6	32 54 c0	2 T .
	ld (0c059h),a		;04e9	32 59 c0	2 Y .
	ld (0c057h),a		;04ec	32 57 c0	2 W .
	ld (0c126h),a		;04ef	32 26 c1	2 & .
	ld (0c053h),a		;04f2	32 53 c0	2 S .
	ld (0c044h),a		;04f5	32 44 c0	2 D .
	ld (0c11ch),a		;04f8	32 1c c1	2 . .
	ld (0c121h),a		;04fb	32 21 c1	2 ! .  ; [ram_dip_switches - DIP switch (SW40) cached settings]
	ld (0c119h),a		;04fe	32 19 c1	2 . .  ; [ram_lamp_state_flags - Lamp state flags (23 refs)]
	ld (0c122h),a		;0501	32 22 c1	2 " .
	ld (0c056h),a		;0504	32 56 c0	2 V .  ; [ram_timer_56 - Timer register 0x56]
	ld (0c068h),a		;0507	32 68 c0	2 h .  ; [ram_game_active - Game active flag (0=attract, nonzero=playing)]
	ld (0c069h),a		;050a	32 69 c0	2 i .
	ld (0c06bh),a		;050d	32 6b c0	2 k .
	ld (0c06ch),a		;0510	32 6c c0	2 l .
	ld (0c05ch),a		;0513	32 5c c0	2 \ .
	ld (0c05dh),a		;0516	32 5d c0	2 ] .
	ld (0c062h),a		;0519	32 62 c0	2 b .  ; [ram_coin_counter_1 - Coin/credit counter 1]
	ld (0c063h),a		;051c	32 63 c0	2 c .  ; [ram_coin_counter_2 - Coin/credit counter 2]
	ld (0c065h),a		;051f	32 65 c0	2 e .
	ld (0c066h),a		;0522	32 66 c0	2 f .
	ld (0c06dh),a		;0525	32 6d c0	2 m .
	ld (0c06eh),a		;0528	32 6e c0	2 n .
	ld (0c05ah),a		;052b	32 5a c0	2 Z .  ; [ram_irq_counter - IRQ service call counter]
	ld (0c058h),a		;052e	32 58 c0	2 X .
	ld (0c0e8h),a		;0531	32 e8 c0	2 . .  ; [ram_matrix_raw_1 - Raw matrix data row 0 (previous read)]
	ld (0c0eah),a		;0534	32 ea c0	2 . .  ; [ram_matrix_raw_2 - Raw matrix data row 1 (current)]
	ld (0c0ech),a		;0537	32 ec c0	2 . .  ; [ram_matrix_raw_3 - Raw matrix data row 2 (current)]
	ld (0c0eeh),a		;053a	32 ee c0	2 . .  ; [ram_matrix_raw_4 - Raw matrix data row 3 (current)]
	ld (0c0f0h),a		;053d	32 f0 c0	2 . .  ; [ram_matrix_raw_5 - Raw matrix data row 4 (current)]
	ld (0c0f2h),a		;0540	32 f2 c0	2 . .  ; [ram_matrix_raw_6 - Raw matrix data row 5 (current)]
	ld (0c0f4h),a		;0543	32 f4 c0	2 . .
	ld (0c0f6h),a		;0546	32 f6 c0	2 . .
	ld (0c0f8h),a		;0549	32 f8 c0	2 . .  ; [ram_direct_processed - Port 0x03 processed (changed bits)]
	ld (0c0e7h),a		;054c	32 e7 c0	2 . .  ; [ram_matrix_raw_0 - Raw matrix data row 0 (current read)]
	ld (0c0e9h),a		;054f	32 e9 c0	2 . .
	ld (0c0ebh),a		;0552	32 eb c0	2 . .
	ld (0c0edh),a		;0555	32 ed c0	2 . .
	ld (0c0efh),a		;0558	32 ef c0	2 . .
	ld (0c0f1h),a		;055b	32 f1 c0	2 . .
	ld (0c0f3h),a		;055e	32 f3 c0	2 . .
	ld (0c0f5h),a		;0561	32 f5 c0	2 . .
	ld (0c0f7h),a		;0564	32 f7 c0	2 . .  ; [ram_direct_raw - Port 0x03 raw value]
	ld (0c022h),a		;0567	32 22 c0	2 " .  ; [ram_sol_timer_bank - Solenoid timer bank (multiple timers)]
	ld (0c05eh),a		;056a	32 5e c0	2 ^ .
	ld a,008h		;056d	3e 08		> .
	ld (0c045h),a		;056f	32 45 c0	2 E .  ; [ram_nmi_downcnt - NMI downcounter (init=0x30, dec per NMI)]
	ld a,002h		;0572	3e 02		> .
	ld (0c0f9h),a		;0574	32 f9 c0	2 . .  ; [ram_scan_debounce - Scan cycle debounce counter]
	ld a,0ffh		;0577	3e ff		> .
	ld (0c0dbh),a		;0579	32 db c0	2 . .  ; [ram_row0_switches - Matrix row 0 debounced switch state]
	ld (0c0dch),a		;057c	32 dc c0	2 . .  ; [ram_row1_switches - Matrix row 1 debounced switch state]
	ld (0c0ddh),a		;057f	32 dd c0	2 . .  ; [ram_row2_switches - Matrix row 2 debounced switch state]
	ld (0c0deh),a		;0582	32 de c0	2 . .  ; [ram_row3_switches - Matrix row 3 debounced switch state]
	ld (0c0dfh),a		;0585	32 df c0	2 . .  ; [ram_row4_switches - Matrix row 4 debounced switch state]
	ld (0c0e0h),a		;0588	32 e0 c0	2 . .  ; [ram_row5_switches - Matrix row 5 debounced switch state]
	ld (0c0e1h),a		;058b	32 e1 c0	2 . .
	ld (0c0e2h),a		;058e	32 e2 c0	2 . .
	ld (0c0e3h),a		;0591	32 e3 c0	2 . .  ; [ram_direct_switches - Direct switch debounced state (flippers etc)]
	ld (0c107h),a		;0594	32 07 c1	2 . .
	ld (0c108h),a		;0597	32 08 c1	2 . .
	ld (0c109h),a		;059a	32 09 c1	2 . .
	ld (0c10ah),a		;059d	32 0a c1	2 . .
	ld (0c10bh),a		;05a0	32 0b c1	2 . .
	ld (0c10ch),a		;05a3	32 0c c1	2 . .
	ld (0c10dh),a		;05a6	32 0d c1	2 . .
	ld (0c10eh),a		;05a9	32 0e c1	2 . .
	ld (0c05bh),a		;05ac	32 5b c0	2 [ .
	ld (0c120h),a		;05af	32 20 c1	2   .
	ld (0c05fh),a		;05b2	32 5f c0	2 _ .  ; [ram_debounce_timer - Debounce timer (97 refs - MOST REFERENCED)]
	ret			;05b5	c9		.

; =============================================================================
; GAME LOGIC
; =============================================================================

; ─────────────────────────────────────────────────────────────────────────────
; sol_timing_table (0x05B6)
; DATA: Solenoid pulse width table (16 bytes)
; ─────────────────────────────────────────────────────────────────────────────
sol_timing_table:
	ld d,b			;05b6	50		P
l05b7h:
	jr z,$+17		;05b7	28 0f		( .
l05b9h:
	ld e,008h		;05b9	1e 08		. .
l05bbh:
	sub (hl)		;05bb	96		.
	nop			;05bc	00		.
l05bdh:
	ld e,01eh		;05bd	1e 1e		. .
l05bfh:
	inc d			;05bf	14		.
	nop			;05c0	00		.
l05c1h:
	inc l			;05c1	2c		,
	ld bc,l001eh		;05c2	01 1e 00	. . .
l05c5h:
	ld e,(hl)		;05c5	5e		^
	ld bc,l3ef3h		;05c6	01 f3 3e	. . >
	rst 38h			;05c9	ff		.
	ld (0c009h),a		;05ca	32 09 c0	2 . .  ; [ram_work_area - Work RAM area start (cleared during init)]
	ld a,(0c005h)		;05cd	3a 05 c0	: . .  ; [ram_port85_shadow - Shadow register for PORT_SOLENOID_1]
	or 002h			;05d0	f6 02		. .
	and 0feh		;05d2	e6 fe		. .
	ld (0c005h),a		;05d4	32 05 c0	2 . .  ; [ram_port85_shadow - Shadow register for PORT_SOLENOID_1]
	out (085h),a		;05d7	d3 85		. .  ; >> PORT_SOLENOID_1 - Solenoid bank 1 (b0=sol1, b2=sol2, b4=sol4, b5=sol3)
	ld a,(sol_timing_table)		;05d9	3a b6 05	: . .
	ld (0c023h),a		;05dc	32 23 c0	2 # .
	xor a			;05df	af		.
	ld (0c062h),a		;05e0	32 62 c0	2 b .  ; [ram_coin_counter_1 - Coin/credit counter 1]
	ld (0c00ch),a		;05e3	32 0c c0	2 . .  ; [ram_sol_timer_0 - Solenoid 0 remaining timer]
	ld a,01eh		;05e6	3e 1e		> .
	ld (0c05fh),a		;05e8	32 5f c0	2 _ .  ; [ram_debounce_timer - Debounce timer (97 refs - MOST REFERENCED)]
	ei			;05eb	fb		.
	ret			;05ec	c9		.
sub_05edh:
	di			;05ed	f3		.
	ld a,0ffh		;05ee	3e ff		> .
	ld (0c00ah),a		;05f0	32 0a c0	2 . .
	ld a,(0c005h)		;05f3	3a 05 c0	: . .  ; [ram_port85_shadow - Shadow register for PORT_SOLENOID_1]
	or 008h			;05f6	f6 08		. .
	and 0fbh		;05f8	e6 fb		. .
	ld (0c005h),a		;05fa	32 05 c0	2 . .  ; [ram_port85_shadow - Shadow register for PORT_SOLENOID_1]
	out (085h),a		;05fd	d3 85		. .  ; >> PORT_SOLENOID_1 - Solenoid bank 1 (b0=sol1, b2=sol2, b4=sol4, b5=sol3)
	ld a,(sol_timing_table)		;05ff	3a b6 05	: . .
	ld (0c024h),a		;0602	32 24 c0	2 $ .
	xor a			;0605	af		.
	ld (0c063h),a		;0606	32 63 c0	2 c .  ; [ram_coin_counter_2 - Coin/credit counter 2]
	ld (0c00dh),a		;0609	32 0d c0	2 . .  ; [ram_sol_timer_1 - Solenoid 1 remaining timer]
	ld a,01eh		;060c	3e 1e		> .
	ld (0c05fh),a		;060e	32 5f c0	2 _ .  ; [ram_debounce_timer - Debounce timer (97 refs - MOST REFERENCED)]
	ei			;0611	fb		.
	ret			;0612	c9		.
sol1_activate:
	di			;0613	f3		.
	ld a,0ffh		;0614	3e ff		> .
	ld (0c00ch),a		;0616	32 0c c0	2 . .  ; [ram_sol_timer_0 - Solenoid 0 remaining timer]
	ld a,(0c005h)		;0619	3a 05 c0	: . .  ; [ram_port85_shadow - Shadow register for PORT_SOLENOID_1]
	or 001h			;061c	f6 01		. .
	and 0fdh		;061e	e6 fd		. .
	ld (0c005h),a		;0620	32 05 c0	2 . .  ; [ram_port85_shadow - Shadow register for PORT_SOLENOID_1]
	out (085h),a		;0623	d3 85		. .  ; >> PORT_SOLENOID_1 - Solenoid bank 1 (b0=sol1, b2=sol2, b4=sol4, b5=sol3)
	xor a			;0625	af		.
	ld (0c009h),a		;0626	32 09 c0	2 . .  ; [ram_work_area - Work RAM area start (cleared during init)]
	ld a,01eh		;0629	3e 1e		> .
	ld (0c05fh),a		;062b	32 5f c0	2 _ .  ; [ram_debounce_timer - Debounce timer (97 refs - MOST REFERENCED)]
	ei			;062e	fb		.
	ret			;062f	c9		.
sol2_activate:
	di			;0630	f3		.
	ld a,0ffh		;0631	3e ff		> .
	ld (0c00dh),a		;0633	32 0d c0	2 . .  ; [ram_sol_timer_1 - Solenoid 1 remaining timer]
	ld a,(0c005h)		;0636	3a 05 c0	: . .  ; [ram_port85_shadow - Shadow register for PORT_SOLENOID_1]
	or 004h			;0639	f6 04		. .
	and 0f7h		;063b	e6 f7		. .
	ld (0c005h),a		;063d	32 05 c0	2 . .  ; [ram_port85_shadow - Shadow register for PORT_SOLENOID_1]
	out (085h),a		;0640	d3 85		. .  ; >> PORT_SOLENOID_1 - Solenoid bank 1 (b0=sol1, b2=sol2, b4=sol4, b5=sol3)
	xor a			;0642	af		.
	ld (0c00ah),a		;0643	32 0a c0	2 . .
	ld a,01eh		;0646	3e 1e		> .
	ld (0c05fh),a		;0648	32 5f c0	2 _ .  ; [ram_debounce_timer - Debounce timer (97 refs - MOST REFERENCED)]
	ei			;064b	fb		.
	ret			;064c	c9		.
sol1_deactivate:
	di			;064d	f3		.
	xor a			;064e	af		.
	ld (0c009h),a		;064f	32 09 c0	2 . .  ; [ram_work_area - Work RAM area start (cleared during init)]
	ld (0c00ch),a		;0652	32 0c c0	2 . .  ; [ram_sol_timer_0 - Solenoid 0 remaining timer]
	ld (0c062h),a		;0655	32 62 c0	2 b .  ; [ram_coin_counter_1 - Coin/credit counter 1]
	ld a,(0c005h)		;0658	3a 05 c0	: . .  ; [ram_port85_shadow - Shadow register for PORT_SOLENOID_1]
	or 002h			;065b	f6 02		. .
	or 001h			;065d	f6 01		. .
	ld (0c005h),a		;065f	32 05 c0	2 . .  ; [ram_port85_shadow - Shadow register for PORT_SOLENOID_1]
	out (085h),a		;0662	d3 85		. .  ; >> PORT_SOLENOID_1 - Solenoid bank 1 (b0=sol1, b2=sol2, b4=sol4, b5=sol3)
	ei			;0664	fb		.
	ret			;0665	c9		.
sol2_deactivate:
	di			;0666	f3		.
	xor a			;0667	af		.
	ld (0c00dh),a		;0668	32 0d c0	2 . .  ; [ram_sol_timer_1 - Solenoid 1 remaining timer]
	ld (0c00ah),a		;066b	32 0a c0	2 . .
	ld (0c063h),a		;066e	32 63 c0	2 c .  ; [ram_coin_counter_2 - Coin/credit counter 2]
	ld a,(0c005h)		;0671	3a 05 c0	: . .  ; [ram_port85_shadow - Shadow register for PORT_SOLENOID_1]
	or 008h			;0674	f6 08		. .
	or 004h			;0676	f6 04		. .
	ld (0c005h),a		;0678	32 05 c0	2 . .  ; [ram_port85_shadow - Shadow register for PORT_SOLENOID_1]
	out (085h),a		;067b	d3 85		. .  ; >> PORT_SOLENOID_1 - Solenoid bank 1 (b0=sol1, b2=sol2, b4=sol4, b5=sol3)
	ei			;067d	fb		.
	ret			;067e	c9		.
sol3_activate:
	di			;067f	f3		.
	ld a,0ffh		;0680	3e ff		> .
	ld (0c00bh),a		;0682	32 0b c0	2 . .
	ld a,(0c005h)		;0685	3a 05 c0	: . .  ; [ram_port85_shadow - Shadow register for PORT_SOLENOID_1]
	or 020h			;0688	f6 20		.  
	and 0efh		;068a	e6 ef		. .
	ld (0c005h),a		;068c	32 05 c0	2 . .  ; [ram_port85_shadow - Shadow register for PORT_SOLENOID_1]
	out (085h),a		;068f	d3 85		. .  ; >> PORT_SOLENOID_1 - Solenoid bank 1 (b0=sol1, b2=sol2, b4=sol4, b5=sol3)
	ld a,(l05b7h)		;0691	3a b7 05	: . .
	ld (0c025h),a		;0694	32 25 c0	2 % .
	xor a			;0697	af		.
	ld (0c064h),a		;0698	32 64 c0	2 d .
	ld (0c00eh),a		;069b	32 0e c0	2 . .
	ld a,01eh		;069e	3e 1e		> .
	ld (0c05fh),a		;06a0	32 5f c0	2 _ .  ; [ram_debounce_timer - Debounce timer (97 refs - MOST REFERENCED)]
	ei			;06a3	fb		.
	ret			;06a4	c9		.
sol4_activate:
	di			;06a5	f3		.
	ld a,0ffh		;06a6	3e ff		> .
	ld (0c00eh),a		;06a8	32 0e c0	2 . .
	ld a,(0c005h)		;06ab	3a 05 c0	: . .  ; [ram_port85_shadow - Shadow register for PORT_SOLENOID_1]
	or 010h			;06ae	f6 10		. .
	and 0dfh		;06b0	e6 df		. .
	ld (0c005h),a		;06b2	32 05 c0	2 . .  ; [ram_port85_shadow - Shadow register for PORT_SOLENOID_1]
	out (085h),a		;06b5	d3 85		. .  ; >> PORT_SOLENOID_1 - Solenoid bank 1 (b0=sol1, b2=sol2, b4=sol4, b5=sol3)
	xor a			;06b7	af		.
	ld (0c00bh),a		;06b8	32 0b c0	2 . .
	ld a,01eh		;06bb	3e 1e		> .
	ld (0c05fh),a		;06bd	32 5f c0	2 _ .  ; [ram_debounce_timer - Debounce timer (97 refs - MOST REFERENCED)]
	ei			;06c0	fb		.
	ret			;06c1	c9		.
sol3_deactivate:
	di			;06c2	f3		.
	xor a			;06c3	af		.
	ld (0c00bh),a		;06c4	32 0b c0	2 . .
	ld (0c00eh),a		;06c7	32 0e c0	2 . .
	ld (0c064h),a		;06ca	32 64 c0	2 d .
	ld a,(0c005h)		;06cd	3a 05 c0	: . .  ; [ram_port85_shadow - Shadow register for PORT_SOLENOID_1]
	or 020h			;06d0	f6 20		.  
	or 010h			;06d2	f6 10		. .
	ld (0c005h),a		;06d4	32 05 c0	2 . .  ; [ram_port85_shadow - Shadow register for PORT_SOLENOID_1]
	out (085h),a		;06d7	d3 85		. .  ; >> PORT_SOLENOID_1 - Solenoid bank 1 (b0=sol1, b2=sol2, b4=sol4, b5=sol3)
	ei			;06d9	fb		.
	ret			;06da	c9		.
sol5_activate:
	di			;06db	f3		.
	ld a,0ffh		;06dc	3e ff		> .
	ld (0c00fh),a		;06de	32 0f c0	2 . .
	ld a,(0c005h)		;06e1	3a 05 c0	: . .  ; [ram_port85_shadow - Shadow register for PORT_SOLENOID_1]
	and 0bfh		;06e4	e6 bf		. .
	ld (0c005h),a		;06e6	32 05 c0	2 . .  ; [ram_port85_shadow - Shadow register for PORT_SOLENOID_1]
	out (085h),a		;06e9	d3 85		. .  ; >> PORT_SOLENOID_1 - Solenoid bank 1 (b0=sol1, b2=sol2, b4=sol4, b5=sol3)
	ld a,(l05b7h+1)		;06eb	3a b8 05	: . .
	ld (0c026h),a		;06ee	32 26 c0	2 & .
	ld a,01eh		;06f1	3e 1e		> .
	ld (0c05fh),a		;06f3	32 5f c0	2 _ .  ; [ram_debounce_timer - Debounce timer (97 refs - MOST REFERENCED)]
	ei			;06f6	fb		.
	ret			;06f7	c9		.
sol6_activate:
	di			;06f8	f3		.
	ld a,0ffh		;06f9	3e ff		> .
	ld (0c010h),a		;06fb	32 10 c0	2 . .
	ld a,(0c006h)		;06fe	3a 06 c0	: . .  ; [ram_port86_shadow - Shadow register for PORT_SOLENOID_2]
	and 0feh		;0701	e6 fe		. .
	ld (0c006h),a		;0703	32 06 c0	2 . .  ; [ram_port86_shadow - Shadow register for PORT_SOLENOID_2]
	out (086h),a		;0706	d3 86		. .  ; >> PORT_SOLENOID_2 - Solenoid bank 2 (b6=sol5, other kickers/diverters)
	ld a,(l05b7h+1)		;0708	3a b8 05	: . .
	ld (0c027h),a		;070b	32 27 c0	2 ' .
	ld a,01eh		;070e	3e 1e		> .
	ld (0c05fh),a		;0710	32 5f c0	2 _ .  ; [ram_debounce_timer - Debounce timer (97 refs - MOST REFERENCED)]
	ei			;0713	fb		.
	ret			;0714	c9		.
sol7_activate:
	di			;0715	f3		.
	ld a,0ffh		;0716	3e ff		> .
	ld (0c011h),a		;0718	32 11 c0	2 . .
	ld a,(0c006h)		;071b	3a 06 c0	: . .  ; [ram_port86_shadow - Shadow register for PORT_SOLENOID_2]
	and 0fdh		;071e	e6 fd		. .
	ld (0c006h),a		;0720	32 06 c0	2 . .  ; [ram_port86_shadow - Shadow register for PORT_SOLENOID_2]
sub_0723h:
	out (086h),a		;0723	d3 86		. .  ; >> PORT_SOLENOID_2 - Solenoid bank 2 (b6=sol5, other kickers/diverters)
	ld a,(l05b7h+1)		;0725	3a b8 05	: . .
	ld (0c028h),a		;0728	32 28 c0	2 ( .
	ld a,01eh		;072b	3e 1e		> .
	ld (0c05fh),a		;072d	32 5f c0	2 _ .  ; [ram_debounce_timer - Debounce timer (97 refs - MOST REFERENCED)]
	ei			;0730	fb		.
	ret			;0731	c9		.
sol8_activate:
	di			;0732	f3		.
	ld a,0ffh		;0733	3e ff		> .
	ld (0c012h),a		;0735	32 12 c0	2 . .
	ld a,(0c006h)		;0738	3a 06 c0	: . .  ; [ram_port86_shadow - Shadow register for PORT_SOLENOID_2]
	and 0fbh		;073b	e6 fb		. .
	ld (0c006h),a		;073d	32 06 c0	2 . .  ; [ram_port86_shadow - Shadow register for PORT_SOLENOID_2]
	out (086h),a		;0740	d3 86		. .  ; >> PORT_SOLENOID_2 - Solenoid bank 2 (b6=sol5, other kickers/diverters)
	ld a,(l05b7h+1)		;0742	3a b8 05	: . .
	ld (0c029h),a		;0745	32 29 c0	2 ) .
	ld a,01eh		;0748	3e 1e		> .
	ld (0c05fh),a		;074a	32 5f c0	2 _ .  ; [ram_debounce_timer - Debounce timer (97 refs - MOST REFERENCED)]
	ei			;074d	fb		.
	ret			;074e	c9		.
sol9_activate:
	di			;074f	f3		.
	ld a,0ffh		;0750	3e ff		> .
	ld (0c013h),a		;0752	32 13 c0	2 . .
	ld a,(0c006h)		;0755	3a 06 c0	: . .  ; [ram_port86_shadow - Shadow register for PORT_SOLENOID_2]
	and 0f7h		;0758	e6 f7		. .
	ld (0c006h),a		;075a	32 06 c0	2 . .  ; [ram_port86_shadow - Shadow register for PORT_SOLENOID_2]
	out (086h),a		;075d	d3 86		. .  ; >> PORT_SOLENOID_2 - Solenoid bank 2 (b6=sol5, other kickers/diverters)
	ld a,(l05b7h+1)		;075f	3a b8 05	: . .
	ld (0c02ah),a		;0762	32 2a c0	2 * .
	ld a,01eh		;0765	3e 1e		> .
	ld (0c05fh),a		;0767	32 5f c0	2 _ .  ; [ram_debounce_timer - Debounce timer (97 refs - MOST REFERENCED)]
	ei			;076a	fb		.
	ret			;076b	c9		.
sol10_activate:
	di			;076c	f3		.
	ld a,0ffh		;076d	3e ff		> .
	ld (0c018h),a		;076f	32 18 c0	2 . .
	ld a,(0c006h)		;0772	3a 06 c0	: . .  ; [ram_port86_shadow - Shadow register for PORT_SOLENOID_2]
	and 0efh		;0775	e6 ef		. .
	ld (0c006h),a		;0777	32 06 c0	2 . .  ; [ram_port86_shadow - Shadow register for PORT_SOLENOID_2]
	out (086h),a		;077a	d3 86		. .  ; >> PORT_SOLENOID_2 - Solenoid bank 2 (b6=sol5, other kickers/diverters)
	ld a,(l05bdh)		;077c	3a bd 05	: . .
	ld (0c030h),a		;077f	32 30 c0	2 0 .
	ld a,01eh		;0782	3e 1e		> .
	ld (0c05fh),a		;0784	32 5f c0	2 _ .  ; [ram_debounce_timer - Debounce timer (97 refs - MOST REFERENCED)]
	ei			;0787	fb		.
	ret			;0788	c9		.
sol11_activate:
	di			;0789	f3		.
	ld a,0ffh		;078a	3e ff		> .
	ld (0c015h),a		;078c	32 15 c0	2 . .
	ld a,(0c006h)		;078f	3a 06 c0	: . .  ; [ram_port86_shadow - Shadow register for PORT_SOLENOID_2]
	and 0dfh		;0792	e6 df		. .
	ld (0c006h),a		;0794	32 06 c0	2 . .  ; [ram_port86_shadow - Shadow register for PORT_SOLENOID_2]
	out (086h),a		;0797	d3 86		. .  ; >> PORT_SOLENOID_2 - Solenoid bank 2 (b6=sol5, other kickers/diverters)
	ld a,(l05b9h+1)		;0799	3a ba 05	: . .
	ld (0c02dh),a		;079c	32 2d c0	2 - .
	ld a,01eh		;079f	3e 1e		> .
	ld (0c05fh),a		;07a1	32 5f c0	2 _ .  ; [ram_debounce_timer - Debounce timer (97 refs - MOST REFERENCED)]
	ei			;07a4	fb		.
	ret			;07a5	c9		.
sol12_activate:
	di			;07a6	f3		.
	ld a,0ffh		;07a7	3e ff		> .
	ld (0c016h),a		;07a9	32 16 c0	2 . .
	ld a,(0c006h)		;07ac	3a 06 c0	: . .  ; [ram_port86_shadow - Shadow register for PORT_SOLENOID_2]
	and 0bfh		;07af	e6 bf		. .
	ld (0c006h),a		;07b1	32 06 c0	2 . .  ; [ram_port86_shadow - Shadow register for PORT_SOLENOID_2]
	out (086h),a		;07b4	d3 86		. .  ; >> PORT_SOLENOID_2 - Solenoid bank 2 (b6=sol5, other kickers/diverters)
	ld a,(l05b9h+1)		;07b6	3a ba 05	: . .
	ld (0c02eh),a		;07b9	32 2e c0	2 . .
	ld a,01eh		;07bc	3e 1e		> .
	ld (0c05fh),a		;07be	32 5f c0	2 _ .  ; [ram_debounce_timer - Debounce timer (97 refs - MOST REFERENCED)]
	ei			;07c1	fb		.
	ret			;07c2	c9		.
sol13_activate:
	di			;07c3	f3		.
	ld a,0ffh		;07c4	3e ff		> .
	ld (0c017h),a		;07c6	32 17 c0	2 . .
	ld a,(0c006h)		;07c9	3a 06 c0	: . .  ; [ram_port86_shadow - Shadow register for PORT_SOLENOID_2]
	and 07fh		;07cc	e6 7f		. .
	ld (0c006h),a		;07ce	32 06 c0	2 . .  ; [ram_port86_shadow - Shadow register for PORT_SOLENOID_2]
	out (086h),a		;07d1	d3 86		. .  ; >> PORT_SOLENOID_2 - Solenoid bank 2 (b6=sol5, other kickers/diverters)
	ld a,(l05bbh)		;07d3	3a bb 05	: . .
	ld (0c02fh),a		;07d6	32 2f c0	2 / .
	ld a,01eh		;07d9	3e 1e		> .
	ld (0c05fh),a		;07db	32 5f c0	2 _ .  ; [ram_debounce_timer - Debounce timer (97 refs - MOST REFERENCED)]
	ei			;07de	fb		.
	ret			;07df	c9		.
sub_07e0h:
	di			;07e0	f3		.
	ld a,0ffh		;07e1	3e ff		> .
	ld (0c019h),a		;07e3	32 19 c0	2 . .
	ld a,(0c005h)		;07e6	3a 05 c0	: . .  ; [ram_port85_shadow - Shadow register for PORT_SOLENOID_1]
	and 07fh		;07e9	e6 7f		. .
	ld (0c005h),a		;07eb	32 05 c0	2 . .  ; [ram_port85_shadow - Shadow register for PORT_SOLENOID_1]
	out (085h),a		;07ee	d3 85		. .  ; >> PORT_SOLENOID_1 - Solenoid bank 1 (b0=sol1, b2=sol2, b4=sol4, b5=sol3)
	ld a,(l05bdh+1)		;07f0	3a be 05	: . .
	ld (0c031h),a		;07f3	32 31 c0	2 1 .
	ld a,01eh		;07f6	3e 1e		> .
	ld (0c05fh),a		;07f8	32 5f c0	2 _ .  ; [ram_debounce_timer - Debounce timer (97 refs - MOST REFERENCED)]
	ei			;07fb	fb		.
	ret			;07fc	c9		.
sub_07fdh:
	di			;07fd	f3		.
	xor a			;07fe	af		.
	ld (0c00fh),a		;07ff	32 0f c0	2 . .
l0802h:
	ld a,(0c005h)		;0802	3a 05 c0	: . .  ; [ram_port85_shadow - Shadow register for PORT_SOLENOID_1]
	or 040h			;0805	f6 40		. @
	ld (0c005h),a		;0807	32 05 c0	2 . .  ; [ram_port85_shadow - Shadow register for PORT_SOLENOID_1]
	out (085h),a		;080a	d3 85		. .  ; >> PORT_SOLENOID_1 - Solenoid bank 1 (b0=sol1, b2=sol2, b4=sol4, b5=sol3)
l080ch:
	ei			;080c	fb		.
	ret			;080d	c9		.
sub_080eh:
	di			;080e	f3		.
	xor a			;080f	af		.
	ld (0c010h),a		;0810	32 10 c0	2 . .
	ld a,(0c006h)		;0813	3a 06 c0	: . .  ; [ram_port86_shadow - Shadow register for PORT_SOLENOID_2]
	or 001h			;0816	f6 01		. .
	ld (0c006h),a		;0818	32 06 c0	2 . .  ; [ram_port86_shadow - Shadow register for PORT_SOLENOID_2]
	out (086h),a		;081b	d3 86		. .  ; >> PORT_SOLENOID_2 - Solenoid bank 2 (b6=sol5, other kickers/diverters)
	ei			;081d	fb		.
	ret			;081e	c9		.
sub_081fh:
	di			;081f	f3		.
	xor a			;0820	af		.
	ld (0c011h),a		;0821	32 11 c0	2 . .
	ld a,(0c006h)		;0824	3a 06 c0	: . .  ; [ram_port86_shadow - Shadow register for PORT_SOLENOID_2]
	or 002h			;0827	f6 02		. .
	ld (0c006h),a		;0829	32 06 c0	2 . .  ; [ram_port86_shadow - Shadow register for PORT_SOLENOID_2]
	out (086h),a		;082c	d3 86		. .  ; >> PORT_SOLENOID_2 - Solenoid bank 2 (b6=sol5, other kickers/diverters)
	ei			;082e	fb		.
	ret			;082f	c9		.
sub_0830h:
	di			;0830	f3		.
	xor a			;0831	af		.
	ld (0c012h),a		;0832	32 12 c0	2 . .
	ld a,(0c006h)		;0835	3a 06 c0	: . .  ; [ram_port86_shadow - Shadow register for PORT_SOLENOID_2]
	or 004h			;0838	f6 04		. .
	ld (0c006h),a		;083a	32 06 c0	2 . .  ; [ram_port86_shadow - Shadow register for PORT_SOLENOID_2]
	out (086h),a		;083d	d3 86		. .  ; >> PORT_SOLENOID_2 - Solenoid bank 2 (b6=sol5, other kickers/diverters)
	ei			;083f	fb		.
	ret			;0840	c9		.
sub_0841h:
	di			;0841	f3		.
	xor a			;0842	af		.
	ld (0c013h),a		;0843	32 13 c0	2 . .
	ld a,(0c006h)		;0846	3a 06 c0	: . .  ; [ram_port86_shadow - Shadow register for PORT_SOLENOID_2]
	or 008h			;0849	f6 08		. .
	ld (0c006h),a		;084b	32 06 c0	2 . .  ; [ram_port86_shadow - Shadow register for PORT_SOLENOID_2]
	out (086h),a		;084e	d3 86		. .  ; >> PORT_SOLENOID_2 - Solenoid bank 2 (b6=sol5, other kickers/diverters)
	ei			;0850	fb		.
	ret			;0851	c9		.
sub_0852h:
	di			;0852	f3		.
	xor a			;0853	af		.
	ld (0c018h),a		;0854	32 18 c0	2 . .
	ld a,(0c006h)		;0857	3a 06 c0	: . .  ; [ram_port86_shadow - Shadow register for PORT_SOLENOID_2]
	or 010h			;085a	f6 10		. .
	ld (0c006h),a		;085c	32 06 c0	2 . .  ; [ram_port86_shadow - Shadow register for PORT_SOLENOID_2]
	out (086h),a		;085f	d3 86		. .  ; >> PORT_SOLENOID_2 - Solenoid bank 2 (b6=sol5, other kickers/diverters)
	ei			;0861	fb		.
	ret			;0862	c9		.
sub_0863h:
	di			;0863	f3		.
	xor a			;0864	af		.
	ld (0c015h),a		;0865	32 15 c0	2 . .
	ld a,(0c006h)		;0868	3a 06 c0	: . .  ; [ram_port86_shadow - Shadow register for PORT_SOLENOID_2]
	or 020h			;086b	f6 20		.  
	ld (0c006h),a		;086d	32 06 c0	2 . .  ; [ram_port86_shadow - Shadow register for PORT_SOLENOID_2]
	out (086h),a		;0870	d3 86		. .  ; >> PORT_SOLENOID_2 - Solenoid bank 2 (b6=sol5, other kickers/diverters)
	ei			;0872	fb		.
	ret			;0873	c9		.
sub_0874h:
	di			;0874	f3		.
	xor a			;0875	af		.
	ld (0c016h),a		;0876	32 16 c0	2 . .
	ld a,(0c006h)		;0879	3a 06 c0	: . .  ; [ram_port86_shadow - Shadow register for PORT_SOLENOID_2]
	or 040h			;087c	f6 40		. @
	ld (0c006h),a		;087e	32 06 c0	2 . .  ; [ram_port86_shadow - Shadow register for PORT_SOLENOID_2]
	out (086h),a		;0881	d3 86		. .  ; >> PORT_SOLENOID_2 - Solenoid bank 2 (b6=sol5, other kickers/diverters)
	ei			;0883	fb		.
	ret			;0884	c9		.
sub_0885h:
	di			;0885	f3		.
	xor a			;0886	af		.
	ld (0c017h),a		;0887	32 17 c0	2 . .
	ld a,(0c006h)		;088a	3a 06 c0	: . .  ; [ram_port86_shadow - Shadow register for PORT_SOLENOID_2]
	or 080h			;088d	f6 80		. .
	ld (0c006h),a		;088f	32 06 c0	2 . .  ; [ram_port86_shadow - Shadow register for PORT_SOLENOID_2]
	out (086h),a		;0892	d3 86		. .  ; >> PORT_SOLENOID_2 - Solenoid bank 2 (b6=sol5, other kickers/diverters)
	ei			;0894	fb		.
	ret			;0895	c9		.
sub_0896h:
	di			;0896	f3		.
	xor a			;0897	af		.
	ld (0c019h),a		;0898	32 19 c0	2 . .
	ld a,(0c005h)		;089b	3a 05 c0	: . .  ; [ram_port85_shadow - Shadow register for PORT_SOLENOID_1]
	or 080h			;089e	f6 80		. .
	ld (0c005h),a		;08a0	32 05 c0	2 . .  ; [ram_port85_shadow - Shadow register for PORT_SOLENOID_1]
	out (085h),a		;08a3	d3 85		. .  ; >> PORT_SOLENOID_1 - Solenoid bank 1 (b0=sol1, b2=sol2, b4=sol4, b5=sol3)
	ei			;08a5	fb		.
	ret			;08a6	c9		.
sub_08a7h:
	di			;08a7	f3		.
	ld hl,(l05b9h)		;08a8	2a b9 05	* . .
	ld (0c02bh),hl		;08ab	22 2b c0	" + .
	ld a,0ffh		;08ae	3e ff		> .
	ld (0c014h),a		;08b0	32 14 c0	2 . .
	ld a,(0c008h)		;08b3	3a 08 c0	: . .  ; [ram_sound_cmd - Current sound command byte]
	and 0feh		;08b6	e6 fe		. .
	ld (0c008h),a		;08b8	32 08 c0	2 . .  ; [ram_sound_cmd - Current sound command byte]
	call send_sound_cmd		;08bb	cd 44 01	. D .  ; → send_sound_cmd
	ld a,01eh		;08be	3e 1e		> .
	ld (0c05fh),a		;08c0	32 5f c0	2 _ .  ; [ram_debounce_timer - Debounce timer (97 refs - MOST REFERENCED)]
	ei			;08c3	fb		.
	ret			;08c4	c9		.
sub_08c5h:
	di			;08c5	f3		.
	ld a,(0c008h)		;08c6	3a 08 c0	: . .  ; [ram_sound_cmd - Current sound command byte]
	or 001h			;08c9	f6 01		. .
	ld (0c008h),a		;08cb	32 08 c0	2 . .  ; [ram_sound_cmd - Current sound command byte]
	call send_sound_cmd		;08ce	cd 44 01	. D .  ; → send_sound_cmd
	ei			;08d1	fb		.
	ret			;08d2	c9		.
sub_08d3h:
	di			;08d3	f3		.
	ld hl,(l05bfh)		;08d4	2a bf 05	* . .
	ld (0c032h),hl		;08d7	22 32 c0	" 2 .
	ld a,0ffh		;08da	3e ff		> .
	ld (0c01ah),a		;08dc	32 1a c0	2 . .
	ld a,(0c008h)		;08df	3a 08 c0	: . .  ; [ram_sound_cmd - Current sound command byte]
	and 0fdh		;08e2	e6 fd		. .
	ld (0c008h),a		;08e4	32 08 c0	2 . .  ; [ram_sound_cmd - Current sound command byte]
	call send_sound_cmd		;08e7	cd 44 01	. D .  ; → send_sound_cmd
	ld a,01eh		;08ea	3e 1e		> .
	ld (0c05fh),a		;08ec	32 5f c0	2 _ .  ; [ram_debounce_timer - Debounce timer (97 refs - MOST REFERENCED)]
	ei			;08ef	fb		.
	ret			;08f0	c9		.
sub_08f1h:
	di			;08f1	f3		.
	ld a,(0c008h)		;08f2	3a 08 c0	: . .  ; [ram_sound_cmd - Current sound command byte]
	or 002h			;08f5	f6 02		. .
	ld (0c008h),a		;08f7	32 08 c0	2 . .  ; [ram_sound_cmd - Current sound command byte]
	call send_sound_cmd		;08fa	cd 44 01	. D .  ; → send_sound_cmd
	ei			;08fd	fb		.
	ret			;08fe	c9		.
sub_08ffh:
	di			;08ff	f3		.
	ld hl,(l05c1h)		;0900	2a c1 05	* . .
	ld (0c034h),hl		;0903	22 34 c0	" 4 .
	ld a,0ffh		;0906	3e ff		> .
	ld (0c01bh),a		;0908	32 1b c0	2 . .
	ld a,(0c008h)		;090b	3a 08 c0	: . .  ; [ram_sound_cmd - Current sound command byte]
	and 0fbh		;090e	e6 fb		. .
	ld (0c008h),a		;0910	32 08 c0	2 . .  ; [ram_sound_cmd - Current sound command byte]
	call send_sound_cmd		;0913	cd 44 01	. D .  ; → send_sound_cmd
	ld a,01eh		;0916	3e 1e		> .
	ld (0c05fh),a		;0918	32 5f c0	2 _ .  ; [ram_debounce_timer - Debounce timer (97 refs - MOST REFERENCED)]
	ei			;091b	fb		.
	ret			;091c	c9		.
sub_091dh:
	di			;091d	f3		.
	ld a,(0c008h)		;091e	3a 08 c0	: . .  ; [ram_sound_cmd - Current sound command byte]
	or 004h			;0921	f6 04		. .
	ld (0c008h),a		;0923	32 08 c0	2 . .  ; [ram_sound_cmd - Current sound command byte]
	call send_sound_cmd		;0926	cd 44 01	. D .  ; → send_sound_cmd
	ei			;0929	fb		.
	ret			;092a	c9		.
	di			;092b	f3		.
	ld hl,(005c3h)		;092c	2a c3 05	* . .
	ld (0c036h),hl		;092f	22 36 c0	" 6 .
	ld a,0ffh		;0932	3e ff		> .
	ld (0c01ch),a		;0934	32 1c c0	2 . .
	ld a,(0c008h)		;0937	3a 08 c0	: . .  ; [ram_sound_cmd - Current sound command byte]
	and 0f7h		;093a	e6 f7		. .
	ld (0c008h),a		;093c	32 08 c0	2 . .  ; [ram_sound_cmd - Current sound command byte]
	call send_sound_cmd		;093f	cd 44 01	. D .  ; → send_sound_cmd
	ld a,01eh		;0942	3e 1e		> .
	ld (0c05fh),a		;0944	32 5f c0	2 _ .  ; [ram_debounce_timer - Debounce timer (97 refs - MOST REFERENCED)]
	ei			;0947	fb		.
	ret			;0948	c9		.
	di			;0949	f3		.
	ld a,(0c008h)		;094a	3a 08 c0	: . .  ; [ram_sound_cmd - Current sound command byte]
	or 008h			;094d	f6 08		. .
	ld (0c008h),a		;094f	32 08 c0	2 . .  ; [ram_sound_cmd - Current sound command byte]
	call send_sound_cmd		;0952	cd 44 01	. D .  ; → send_sound_cmd
	ei			;0955	fb		.
	ret			;0956	c9		.
sub_0957h:
	di			;0957	f3		.
	ld hl,(l05c5h)		;0958	2a c5 05	* . .
	ld (0c038h),hl		;095b	22 38 c0	" 8 .
	ld a,0ffh		;095e	3e ff		> .
	ld (0c01dh),a		;0960	32 1d c0	2 . .
	ld a,(0c008h)		;0963	3a 08 c0	: . .  ; [ram_sound_cmd - Current sound command byte]
	and 0efh		;0966	e6 ef		. .
	ld (0c008h),a		;0968	32 08 c0	2 . .  ; [ram_sound_cmd - Current sound command byte]
	call send_sound_cmd		;096b	cd 44 01	. D .  ; → send_sound_cmd
	ld a,01eh		;096e	3e 1e		> .
	ld (0c05fh),a		;0970	32 5f c0	2 _ .  ; [ram_debounce_timer - Debounce timer (97 refs - MOST REFERENCED)]
	ei			;0973	fb		.
	ret			;0974	c9		.
sub_0975h:
	di			;0975	f3		.
	ld hl,(l05c5h)		;0976	2a c5 05	* . .
	ld (0c038h),hl		;0979	22 38 c0	" 8 .
	ld a,0ffh		;097c	3e ff		> .
	ld (0c01dh),a		;097e	32 1d c0	2 . .
	ld a,(0c008h)		;0981	3a 08 c0	: . .  ; [ram_sound_cmd - Current sound command byte]
	and 0afh		;0984	e6 af		. .
	ld (0c008h),a		;0986	32 08 c0	2 . .  ; [ram_sound_cmd - Current sound command byte]
	call send_sound_cmd		;0989	cd 44 01	. D .  ; → send_sound_cmd
	ld a,01eh		;098c	3e 1e		> .
	ld (0c05fh),a		;098e	32 5f c0	2 _ .  ; [ram_debounce_timer - Debounce timer (97 refs - MOST REFERENCED)]
	ei			;0991	fb		.
	ret			;0992	c9		.
sub_0993h:
	di			;0993	f3		.
	ld a,(0c008h)		;0994	3a 08 c0	: . .  ; [ram_sound_cmd - Current sound command byte]
	or 050h			;0997	f6 50		. P
	ld (0c008h),a		;0999	32 08 c0	2 . .  ; [ram_sound_cmd - Current sound command byte]
	call send_sound_cmd		;099c	cd 44 01	. D .  ; → send_sound_cmd
	ei			;099f	fb		.
	ret			;09a0	c9		.
l09a1h:
	inc c			;09a1	0c		.
	di			;09a2	f3		.
	ld a,0ffh		;09a3	3e ff		> .
	ld (0c01eh),a		;09a5	32 1e c0	2 . .
	ld a,(l09a1h)		;09a8	3a a1 09	: . .
	ld (0c03ah),a		;09ab	32 3a c0	2 : .
	ld a,(0c008h)		;09ae	3a 08 c0	: . .  ; [ram_sound_cmd - Current sound command byte]
	and 0dfh		;09b1	e6 df		. .
	ld (0c008h),a		;09b3	32 08 c0	2 . .  ; [ram_sound_cmd - Current sound command byte]
	call send_sound_cmd		;09b6	cd 44 01	. D .  ; → send_sound_cmd
	ei			;09b9	fb		.
	ret			;09ba	c9		.
	di			;09bb	f3		.
	ld a,0ffh		;09bc	3e ff		> .
	ld (0c01fh),a		;09be	32 1f c0	2 . .
	ld a,(l09a1h)		;09c1	3a a1 09	: . .
	ld (0c03bh),a		;09c4	32 3b c0	2 ; .
	ld a,(0c008h)		;09c7	3a 08 c0	: . .  ; [ram_sound_cmd - Current sound command byte]
	and 0bfh		;09ca	e6 bf		. .
	ld (0c008h),a		;09cc	32 08 c0	2 . .  ; [ram_sound_cmd - Current sound command byte]
	call send_sound_cmd		;09cf	cd 44 01	. D .  ; → send_sound_cmd
	ei			;09d2	fb		.
	ret			;09d3	c9		.
	di			;09d4	f3		.
	ld a,0ffh		;09d5	3e ff		> .
	ld (0c020h),a		;09d7	32 20 c0	2   .
	ld a,(l09a1h)		;09da	3a a1 09	: . .
	ld (0c03ch),a		;09dd	32 3c c0	2 < .
	ld a,(0c008h)		;09e0	3a 08 c0	: . .  ; [ram_sound_cmd - Current sound command byte]
	and 07fh		;09e3	e6 7f		. .
	ld (0c008h),a		;09e5	32 08 c0	2 . .  ; [ram_sound_cmd - Current sound command byte]
	call send_sound_cmd		;09e8	cd 44 01	. D .  ; → send_sound_cmd
	ei			;09eb	fb		.
	ret			;09ec	c9		.
	ret			;09ed	c9		.
	ld a,(0c008h)		;09ee	3a 08 c0	: . .  ; [ram_sound_cmd - Current sound command byte]
	and 0dfh		;09f1	e6 df		. .
	ld (0c008h),a		;09f3	32 08 c0	2 . .  ; [ram_sound_cmd - Current sound command byte]
	call send_sound_cmd		;09f6	cd 44 01	. D .  ; → send_sound_cmd
	ret			;09f9	c9		.
	ld a,(0c008h)		;09fa	3a 08 c0	: . .  ; [ram_sound_cmd - Current sound command byte]
	and 0bfh		;09fd	e6 bf		. .
	ld (0c008h),a		;09ff	32 08 c0	2 . .  ; [ram_sound_cmd - Current sound command byte]
	call send_sound_cmd		;0a02	cd 44 01	. D .  ; → send_sound_cmd
	ret			;0a05	c9		.
	ld a,(0c008h)		;0a06	3a 08 c0	: . .  ; [ram_sound_cmd - Current sound command byte]
	and 07fh		;0a09	e6 7f		. .
	ld (0c008h),a		;0a0b	32 08 c0	2 . .  ; [ram_sound_cmd - Current sound command byte]
	call send_sound_cmd		;0a0e	cd 44 01	. D .  ; → send_sound_cmd
	ret			;0a11	c9		.
sub_0a12h:
	ld a,(0c008h)		;0a12	3a 08 c0	: . .  ; [ram_sound_cmd - Current sound command byte]
	or 020h			;0a15	f6 20		.  
	ld (0c008h),a		;0a17	32 08 c0	2 . .  ; [ram_sound_cmd - Current sound command byte]
	call send_sound_cmd		;0a1a	cd 44 01	. D .  ; → send_sound_cmd
	ret			;0a1d	c9		.
sub_0a1eh:
	ld a,(0c008h)		;0a1e	3a 08 c0	: . .  ; [ram_sound_cmd - Current sound command byte]
	or 040h			;0a21	f6 40		. @
	ld (0c008h),a		;0a23	32 08 c0	2 . .  ; [ram_sound_cmd - Current sound command byte]
	call send_sound_cmd		;0a26	cd 44 01	. D .  ; → send_sound_cmd
	ret			;0a29	c9		.
sub_0a2ah:
	ld a,(0c008h)		;0a2a	3a 08 c0	: . .  ; [ram_sound_cmd - Current sound command byte]
	or 080h			;0a2d	f6 80		. .
	ld (0c008h),a		;0a2f	32 08 c0	2 . .  ; [ram_sound_cmd - Current sound command byte]
	call send_sound_cmd		;0a32	cd 44 01	. D .  ; → send_sound_cmd
	ret			;0a35	c9		.
	call sub_379ah		;0a36	cd 9a 37	. . 7
	xor a			;0a39	af		.
	ld (0c05ah),a		;0a3a	32 5a c0	2 Z .  ; [ram_irq_counter - IRQ service call counter]
	ret			;0a3d	c9		.
	call sub_37d4h		;0a3e	cd d4 37	. . 7
	ret			;0a41	c9		.

; =============================================================================
; INTERRUPT SERVICE ROUTINES
; =============================================================================

; ─────────────────────────────────────────────────────────────────────────────
; irq_service_main (0x0A42)
; Main IRQ service: lamp refresh, scan, solenoid tick
; XREF: 1 references from 0x0038
; ─────────────────────────────────────────────────────────────────────────────
irq_service_main:
	di			;0a42	f3		.
	push af			;0a43	f5		.
	push bc			;0a44	c5		.
	push de			;0a45	d5		.
	push hl			;0a46	e5		.
	call sub_3446h		;0a47	cd 46 34	. F 4
	call sub_3335h		;0a4a	cd 35 33	. 5 3
	call sub_2e54h		;0a4d	cd 54 2e	. T .
	ld a,(0c052h)		;0a50	3a 52 c0	: R .  ; [ram_timer_52 - Timer register 0x52]
	cp 0a5h			;0a53	fe a5		. .
	call l0d14h+1		;0a55	cd 15 0d	. . .
	ld a,(0c044h)		;0a58	3a 44 c0	: D .
	and a			;0a5b	a7		.
	jp nz,l0b6eh		;0a5c	c2 6e 0b	. n .
	ld a,0ffh		;0a5f	3e ff		> .
	ld (0c044h),a		;0a61	32 44 c0	2 D .
	ld a,(0c009h)		;0a64	3a 09 c0	: . .  ; [ram_work_area - Work RAM area start (cleared during init)]
	and a			;0a67	a7		.
	jp z,l0a7fh		;0a68	ca 7f 0a	. . .
	ld a,01eh		;0a6b	3e 1e		> .
	ld (0c05fh),a		;0a6d	32 5f c0	2 _ .  ; [ram_debounce_timer - Debounce timer (97 refs - MOST REFERENCED)]
	ld hl,0c023h		;0a70	21 23 c0	! # .
	dec (hl)		;0a73	35		5
	jp nz,l0a7fh		;0a74	c2 7f 0a	. . .
	call sol1_activate		;0a77	cd 13 06	. . .
	ld a,0ffh		;0a7a	3e ff		> .
	ld (0c062h),a		;0a7c	32 62 c0	2 b .  ; [ram_coin_counter_1 - Coin/credit counter 1]
;  XREF: 2 refs from 0x0A68, 0x0A74
l0a7fh:
	ld a,(0c00bh)		;0a7f	3a 0b c0	: . .
	and a			;0a82	a7		.
	jp z,l0a9ah		;0a83	ca 9a 0a	. . .
	ld a,01eh		;0a86	3e 1e		> .
	ld (0c05fh),a		;0a88	32 5f c0	2 _ .  ; [ram_debounce_timer - Debounce timer (97 refs - MOST REFERENCED)]
	ld hl,0c025h		;0a8b	21 25 c0	! % .
	dec (hl)		;0a8e	35		5
	jp nz,l0a9ah		;0a8f	c2 9a 0a	. . .
	call sol4_activate		;0a92	cd a5 06	. . .
	ld a,0ffh		;0a95	3e ff		> .
	ld (0c064h),a		;0a97	32 64 c0	2 d .
;  XREF: 2 refs from 0x0A83, 0x0A8F
l0a9ah:
	ld a,(0c00fh)		;0a9a	3a 0f c0	: . .
	and a			;0a9d	a7		.
	jp z,l0abbh		;0a9e	ca bb 0a	. . .
	ld a,01eh		;0aa1	3e 1e		> .
	ld (0c05fh),a		;0aa3	32 5f c0	2 _ .  ; [ram_debounce_timer - Debounce timer (97 refs - MOST REFERENCED)]
	ld hl,0c026h		;0aa6	21 26 c0	! & .
	dec (hl)		;0aa9	35		5
	jp nz,l0abbh		;0aaa	c2 bb 0a	. . .
	xor a			;0aad	af		.
	ld (0c00fh),a		;0aae	32 0f c0	2 . .
	ld a,(0c005h)		;0ab1	3a 05 c0	: . .  ; [ram_port85_shadow - Shadow register for PORT_SOLENOID_1]
	or 040h			;0ab4	f6 40		. @
	ld (0c005h),a		;0ab6	32 05 c0	2 . .  ; [ram_port85_shadow - Shadow register for PORT_SOLENOID_1]
	out (085h),a		;0ab9	d3 85		. .  ; >> PORT_SOLENOID_1 - Solenoid bank 1 (b0=sol1, b2=sol2, b4=sol4, b5=sol3)
;  XREF: 2 refs from 0x0A9E, 0x0AAA
l0abbh:
	ld a,(0c010h)		;0abb	3a 10 c0	: . .
	and a			;0abe	a7		.
	jp z,l0adch		;0abf	ca dc 0a	. . .
	ld a,01eh		;0ac2	3e 1e		> .
	ld (0c05fh),a		;0ac4	32 5f c0	2 _ .  ; [ram_debounce_timer - Debounce timer (97 refs - MOST REFERENCED)]
	ld hl,0c027h		;0ac7	21 27 c0	! ' .
	dec (hl)		;0aca	35		5
	jp nz,l0adch		;0acb	c2 dc 0a	. . .
	xor a			;0ace	af		.
	ld (0c010h),a		;0acf	32 10 c0	2 . .
	ld a,(0c006h)		;0ad2	3a 06 c0	: . .  ; [ram_port86_shadow - Shadow register for PORT_SOLENOID_2]
	or 001h			;0ad5	f6 01		. .
	ld (0c006h),a		;0ad7	32 06 c0	2 . .  ; [ram_port86_shadow - Shadow register for PORT_SOLENOID_2]
	out (086h),a		;0ada	d3 86		. .  ; >> PORT_SOLENOID_2 - Solenoid bank 2 (b6=sol5, other kickers/diverters)
;  XREF: 2 refs from 0x0ABF, 0x0ACB
l0adch:
	ld a,(0c011h)		;0adc	3a 11 c0	: . .
	and a			;0adf	a7		.
	jp z,l0afdh		;0ae0	ca fd 0a	. . .
	ld a,01eh		;0ae3	3e 1e		> .
	ld (0c05fh),a		;0ae5	32 5f c0	2 _ .  ; [ram_debounce_timer - Debounce timer (97 refs - MOST REFERENCED)]
	ld hl,0c028h		;0ae8	21 28 c0	! ( .
	dec (hl)		;0aeb	35		5
	jp nz,l0afdh		;0aec	c2 fd 0a	. . .
	xor a			;0aef	af		.
	ld (0c011h),a		;0af0	32 11 c0	2 . .
	ld a,(0c006h)		;0af3	3a 06 c0	: . .  ; [ram_port86_shadow - Shadow register for PORT_SOLENOID_2]
	or 002h			;0af6	f6 02		. .
	ld (0c006h),a		;0af8	32 06 c0	2 . .  ; [ram_port86_shadow - Shadow register for PORT_SOLENOID_2]
	out (086h),a		;0afb	d3 86		. .  ; >> PORT_SOLENOID_2 - Solenoid bank 2 (b6=sol5, other kickers/diverters)
;  XREF: 2 refs from 0x0AE0, 0x0AEC
l0afdh:
	ld a,(0c019h)		;0afd	3a 19 c0	: . .
	and a			;0b00	a7		.
	jp z,l0b1eh		;0b01	ca 1e 0b	. . .
	ld a,01eh		;0b04	3e 1e		> .
	ld (0c05fh),a		;0b06	32 5f c0	2 _ .  ; [ram_debounce_timer - Debounce timer (97 refs - MOST REFERENCED)]
	ld hl,0c031h		;0b09	21 31 c0	! 1 .
	dec (hl)		;0b0c	35		5
	jp nz,l0b1eh		;0b0d	c2 1e 0b	. . .
	xor a			;0b10	af		.
	ld (0c019h),a		;0b11	32 19 c0	2 . .
	ld a,(0c005h)		;0b14	3a 05 c0	: . .  ; [ram_port85_shadow - Shadow register for PORT_SOLENOID_1]
	or 080h			;0b17	f6 80		. .
	ld (0c005h),a		;0b19	32 05 c0	2 . .  ; [ram_port85_shadow - Shadow register for PORT_SOLENOID_1]
	out (085h),a		;0b1c	d3 85		. .  ; >> PORT_SOLENOID_1 - Solenoid bank 1 (b0=sol1, b2=sol2, b4=sol4, b5=sol3)
;  XREF: 2 refs from 0x0B01, 0x0B0D
l0b1eh:
	ld a,(0c01dh)		;0b1e	3a 1d c0	: . .
	and a			;0b21	a7		.
	jp z,l0b4ch		;0b22	ca 4c 0b	. L .
	ld a,01eh		;0b25	3e 1e		> .
	ld (0c05fh),a		;0b27	32 5f c0	2 _ .  ; [ram_debounce_timer - Debounce timer (97 refs - MOST REFERENCED)]
	ld hl,(0c038h)		;0b2a	2a 38 c0	* 8 .
	ld de,reset_entry		;0b2d	11 00 00	. . .
	xor a			;0b30	af		.
	sbc hl,de		;0b31	ed 52		. R
	jp z,l0b3dh		;0b33	ca 3d 0b	. = .
	dec hl			;0b36	2b		+
	ld (0c038h),hl		;0b37	22 38 c0	" 8 .
	jp l0b4ch		;0b3a	c3 4c 0b	. L .
l0b3dh:
	xor a			;0b3d	af		.
	ld (0c01dh),a		;0b3e	32 1d c0	2 . .
	ld a,(0c008h)		;0b41	3a 08 c0	: . .  ; [ram_sound_cmd - Current sound command byte]
	or 050h			;0b44	f6 50		. P
	ld (0c008h),a		;0b46	32 08 c0	2 . .  ; [ram_sound_cmd - Current sound command byte]
	call send_sound_cmd		;0b49	cd 44 01	. D .  ; → send_sound_cmd
;  XREF: 2 refs from 0x0B22, 0x0B3A
l0b4ch:
	ld a,(0c00ch)		;0b4c	3a 0c c0	: . .  ; [ram_sol_timer_0 - Solenoid 0 remaining timer]
	and a			;0b4f	a7		.
	jp z,l0b58h		;0b50	ca 58 0b	. X .
	ld a,01eh		;0b53	3e 1e		> .
	ld (0c05fh),a		;0b55	32 5f c0	2 _ .  ; [ram_debounce_timer - Debounce timer (97 refs - MOST REFERENCED)]
l0b58h:
	ld a,(0c00eh)		;0b58	3a 0e c0	: . .
	and a			;0b5b	a7		.
	jp z,l0b64h		;0b5c	ca 64 0b	. d .
	ld a,01eh		;0b5f	3e 1e		> .
	ld (0c05fh),a		;0b61	32 5f c0	2 _ .  ; [ram_debounce_timer - Debounce timer (97 refs - MOST REFERENCED)]
l0b64h:
	call sub_0cb8h		;0b64	cd b8 0c	. . .
	pop hl			;0b67	e1		.
	pop de			;0b68	d1		.
	pop bc			;0b69	c1		.
	pop af			;0b6a	f1		.
	ei			;0b6b	fb		.
	reti			;0b6c	ed 4d		. M
l0b6eh:
	xor a			;0b6e	af		.
	ld (0c044h),a		;0b6f	32 44 c0	2 D .
	ld a,(0c00ah)		;0b72	3a 0a c0	: . .
	and a			;0b75	a7		.
	jp z,l0b8dh		;0b76	ca 8d 0b	. . .
	ld a,01eh		;0b79	3e 1e		> .
	ld (0c05fh),a		;0b7b	32 5f c0	2 _ .  ; [ram_debounce_timer - Debounce timer (97 refs - MOST REFERENCED)]
	ld hl,0c024h		;0b7e	21 24 c0	! $ .
	dec (hl)		;0b81	35		5
	jp nz,l0b8dh		;0b82	c2 8d 0b	. . .
	call sol2_activate		;0b85	cd 30 06	. 0 .
	ld a,0ffh		;0b88	3e ff		> .
	ld (0c063h),a		;0b8a	32 63 c0	2 c .  ; [ram_coin_counter_2 - Coin/credit counter 2]
;  XREF: 2 refs from 0x0B76, 0x0B82
l0b8dh:
	ld a,(0c012h)		;0b8d	3a 12 c0	: . .
	and a			;0b90	a7		.
	jp z,l0baeh		;0b91	ca ae 0b	. . .
	ld a,01eh		;0b94	3e 1e		> .
	ld (0c05fh),a		;0b96	32 5f c0	2 _ .  ; [ram_debounce_timer - Debounce timer (97 refs - MOST REFERENCED)]
	ld hl,0c029h		;0b99	21 29 c0	! ) .
	dec (hl)		;0b9c	35		5
	jp nz,l0baeh		;0b9d	c2 ae 0b	. . .
	xor a			;0ba0	af		.
	ld (0c012h),a		;0ba1	32 12 c0	2 . .
	ld a,(0c006h)		;0ba4	3a 06 c0	: . .  ; [ram_port86_shadow - Shadow register for PORT_SOLENOID_2]
	or 004h			;0ba7	f6 04		. .
	ld (0c006h),a		;0ba9	32 06 c0	2 . .  ; [ram_port86_shadow - Shadow register for PORT_SOLENOID_2]
	out (086h),a		;0bac	d3 86		. .  ; >> PORT_SOLENOID_2 - Solenoid bank 2 (b6=sol5, other kickers/diverters)
;  XREF: 2 refs from 0x0B91, 0x0B9D
l0baeh:
	ld a,(0c013h)		;0bae	3a 13 c0	: . .
	and a			;0bb1	a7		.
	jp z,l0bcfh		;0bb2	ca cf 0b	. . .
	ld a,01eh		;0bb5	3e 1e		> .
	ld (0c05fh),a		;0bb7	32 5f c0	2 _ .  ; [ram_debounce_timer - Debounce timer (97 refs - MOST REFERENCED)]
	ld hl,0c02ah		;0bba	21 2a c0	! * .
	dec (hl)		;0bbd	35		5
	jp nz,l0bcfh		;0bbe	c2 cf 0b	. . .
	xor a			;0bc1	af		.
	ld (0c013h),a		;0bc2	32 13 c0	2 . .
	ld a,(0c006h)		;0bc5	3a 06 c0	: . .  ; [ram_port86_shadow - Shadow register for PORT_SOLENOID_2]
	or 008h			;0bc8	f6 08		. .
	ld (0c006h),a		;0bca	32 06 c0	2 . .  ; [ram_port86_shadow - Shadow register for PORT_SOLENOID_2]
	out (086h),a		;0bcd	d3 86		. .  ; >> PORT_SOLENOID_2 - Solenoid bank 2 (b6=sol5, other kickers/diverters)
;  XREF: 2 refs from 0x0BB2, 0x0BBE
l0bcfh:
	ld a,(0c018h)		;0bcf	3a 18 c0	: . .
	and a			;0bd2	a7		.
	jp z,l0bf0h		;0bd3	ca f0 0b	. . .
	ld a,01eh		;0bd6	3e 1e		> .
	ld (0c05fh),a		;0bd8	32 5f c0	2 _ .  ; [ram_debounce_timer - Debounce timer (97 refs - MOST REFERENCED)]
	ld hl,0c030h		;0bdb	21 30 c0	! 0 .
	dec (hl)		;0bde	35		5
	jp nz,l0bf0h		;0bdf	c2 f0 0b	. . .
	xor a			;0be2	af		.
	ld (0c018h),a		;0be3	32 18 c0	2 . .
	ld a,(0c006h)		;0be6	3a 06 c0	: . .  ; [ram_port86_shadow - Shadow register for PORT_SOLENOID_2]
	or 010h			;0be9	f6 10		. .
	ld (0c006h),a		;0beb	32 06 c0	2 . .  ; [ram_port86_shadow - Shadow register for PORT_SOLENOID_2]
	out (086h),a		;0bee	d3 86		. .  ; >> PORT_SOLENOID_2 - Solenoid bank 2 (b6=sol5, other kickers/diverters)
;  XREF: 2 refs from 0x0BD3, 0x0BDF
l0bf0h:
	ld a,(0c015h)		;0bf0	3a 15 c0	: . .
	and a			;0bf3	a7		.
	jp z,l0c11h		;0bf4	ca 11 0c	. . .
	ld a,01eh		;0bf7	3e 1e		> .
	ld (0c05fh),a		;0bf9	32 5f c0	2 _ .  ; [ram_debounce_timer - Debounce timer (97 refs - MOST REFERENCED)]
	ld hl,0c02dh		;0bfc	21 2d c0	! - .
	dec (hl)		;0bff	35		5
l0c00h:
	jp nz,l0c11h		;0c00	c2 11 0c	. . .
	xor a			;0c03	af		.
	ld (0c015h),a		;0c04	32 15 c0	2 . .
	ld a,(0c006h)		;0c07	3a 06 c0	: . .  ; [ram_port86_shadow - Shadow register for PORT_SOLENOID_2]
	or 020h			;0c0a	f6 20		.  
	ld (0c006h),a		;0c0c	32 06 c0	2 . .  ; [ram_port86_shadow - Shadow register for PORT_SOLENOID_2]
	out (086h),a		;0c0f	d3 86		. .  ; >> PORT_SOLENOID_2 - Solenoid bank 2 (b6=sol5, other kickers/diverters)
;  XREF: 2 refs from 0x0BF4, 0x0C00
l0c11h:
	ld a,(0c016h)		;0c11	3a 16 c0	: . .
	and a			;0c14	a7		.
	jp z,l0c32h		;0c15	ca 32 0c	. 2 .
	ld a,01eh		;0c18	3e 1e		> .
	ld (0c05fh),a		;0c1a	32 5f c0	2 _ .  ; [ram_debounce_timer - Debounce timer (97 refs - MOST REFERENCED)]
	ld hl,0c02eh		;0c1d	21 2e c0	! . .
	dec (hl)		;0c20	35		5
	jp nz,l0c32h		;0c21	c2 32 0c	. 2 .
	xor a			;0c24	af		.
	ld (0c016h),a		;0c25	32 16 c0	2 . .
	ld a,(0c006h)		;0c28	3a 06 c0	: . .  ; [ram_port86_shadow - Shadow register for PORT_SOLENOID_2]
	or 040h			;0c2b	f6 40		. @
	ld (0c006h),a		;0c2d	32 06 c0	2 . .  ; [ram_port86_shadow - Shadow register for PORT_SOLENOID_2]
	out (086h),a		;0c30	d3 86		. .  ; >> PORT_SOLENOID_2 - Solenoid bank 2 (b6=sol5, other kickers/diverters)
;  XREF: 2 refs from 0x0C15, 0x0C21
l0c32h:
	ld a,(0c017h)		;0c32	3a 17 c0	: . .
	and a			;0c35	a7		.
	jp z,l0c53h		;0c36	ca 53 0c	. S .
	ld a,01eh		;0c39	3e 1e		> .
	ld (0c05fh),a		;0c3b	32 5f c0	2 _ .  ; [ram_debounce_timer - Debounce timer (97 refs - MOST REFERENCED)]
	ld hl,0c02fh		;0c3e	21 2f c0	! / .
	dec (hl)		;0c41	35		5
	jp nz,l0c53h		;0c42	c2 53 0c	. S .
	xor a			;0c45	af		.
	ld (0c017h),a		;0c46	32 17 c0	2 . .
	ld a,(0c006h)		;0c49	3a 06 c0	: . .  ; [ram_port86_shadow - Shadow register for PORT_SOLENOID_2]
	or 080h			;0c4c	f6 80		. .
	ld (0c006h),a		;0c4e	32 06 c0	2 . .  ; [ram_port86_shadow - Shadow register for PORT_SOLENOID_2]
	out (086h),a		;0c51	d3 86		. .  ; >> PORT_SOLENOID_2 - Solenoid bank 2 (b6=sol5, other kickers/diverters)
;  XREF: 2 refs from 0x0C36, 0x0C42
l0c53h:
	ld a,(0c01bh)		;0c53	3a 1b c0	: . .
	and a			;0c56	a7		.
	jp z,l0c81h		;0c57	ca 81 0c	. . .
	ld a,01eh		;0c5a	3e 1e		> .
	ld (0c05fh),a		;0c5c	32 5f c0	2 _ .  ; [ram_debounce_timer - Debounce timer (97 refs - MOST REFERENCED)]
	ld hl,(0c034h)		;0c5f	2a 34 c0	* 4 .
	ld de,reset_entry		;0c62	11 00 00	. . .
	xor a			;0c65	af		.
	sbc hl,de		;0c66	ed 52		. R
	jp z,l0c72h		;0c68	ca 72 0c	. r .
	dec hl			;0c6b	2b		+
	ld (0c034h),hl		;0c6c	22 34 c0	" 4 .
	jp l0c81h		;0c6f	c3 81 0c	. . .
l0c72h:
	xor a			;0c72	af		.
	ld (0c01bh),a		;0c73	32 1b c0	2 . .
	ld a,(0c008h)		;0c76	3a 08 c0	: . .  ; [ram_sound_cmd - Current sound command byte]
	or 004h			;0c79	f6 04		. .
	ld (0c008h),a		;0c7b	32 08 c0	2 . .  ; [ram_sound_cmd - Current sound command byte]
	call send_sound_cmd		;0c7e	cd 44 01	. D .  ; → send_sound_cmd
;  XREF: 2 refs from 0x0C57, 0x0C6F
l0c81h:
	ld a,(0c00dh)		;0c81	3a 0d c0	: . .  ; [ram_sol_timer_1 - Solenoid 1 remaining timer]
	and a			;0c84	a7		.
	jp z,l0c8dh		;0c85	ca 8d 0c	. . .
	ld a,01eh		;0c88	3e 1e		> .
	ld (0c05fh),a		;0c8a	32 5f c0	2 _ .  ; [ram_debounce_timer - Debounce timer (97 refs - MOST REFERENCED)]
l0c8dh:
	call sub_0c97h		;0c8d	cd 97 0c	. . .
	pop hl			;0c90	e1		.
	pop de			;0c91	d1		.
	pop bc			;0c92	c1		.
	pop af			;0c93	f1		.
	ei			;0c94	fb		.
	reti			;0c95	ed 4d		. M
sub_0c97h:
	ld hl,0c045h		;0c97	21 45 c0	! E .
	dec (hl)		;0c9a	35		5
	ret nz			;0c9b	c0		.
	ld (hl),010h		;0c9c	36 10		6 .
	ld a,(0c001h)		;0c9e	3a 01 c0	: . .  ; [ram_port81_shadow - Shadow register for PORT_CONTROL]
	bit 3,a			;0ca1	cb 5f		. _
	jp z,l0cb0h		;0ca3	ca b0 0c	. . .
	res 3,a			;0ca6	cb 9f		. .
	res 0,a			;0ca8	cb 87		. .
	ld (0c001h),a		;0caa	32 01 c0	2 . .  ; [ram_port81_shadow - Shadow register for PORT_CONTROL]
	out (081h),a		;0cad	d3 81		. .  ; >> PORT_CONTROL - control → 80188 (bit4=NMI ack; bit0=sound-chan sel; bit2=switch strobe; bit5=sound strobe)
	ret			;0caf	c9		.
l0cb0h:
	set 3,a			;0cb0	cb df		. .
	ld (0c001h),a		;0cb2	32 01 c0	2 . .  ; [ram_port81_shadow - Shadow register for PORT_CONTROL]
	out (081h),a		;0cb5	d3 81		. .  ; >> PORT_CONTROL - control → 80188 (bit4=NMI ack; bit0=sound-chan sel; bit2=switch strobe; bit5=sound strobe)
	ret			;0cb7	c9		.
sub_0cb8h:
	ld hl,(0c04ch)		;0cb8	2a 4c c0	* L .  ; [ram_sw_queue_wptr - Switch event queue write pointer]
	ld de,reset_entry		;0cbb	11 00 00	. . .
	xor a			;0cbe	af		.
	sbc hl,de		;0cbf	ed 52		. R
	jp z,l0ccbh		;0cc1	ca cb 0c	. . .
	dec hl			;0cc4	2b		+
	ld (0c04ch),hl		;0cc5	22 4c c0	" L .  ; [ram_sw_queue_wptr - Switch event queue write pointer]
	jp l0cceh		;0cc8	c3 ce 0c	. . .
l0ccbh:
	ld (0c04eh),a		;0ccb	32 4e c0	2 N .  ; [ram_timer_flag - Main timer flag (controls game timing)]
l0cceh:
	ld hl,(0c04fh)		;0cce	2a 4f c0	* O .  ; [ram_timer_aux - Auxiliary timer counter]
	ld de,reset_entry		;0cd1	11 00 00	. . .
	xor a			;0cd4	af		.
	sbc hl,de		;0cd5	ed 52		. R
	jp z,l0ce1h		;0cd7	ca e1 0c	. . .
	dec hl			;0cda	2b		+
	ld (0c04fh),hl		;0cdb	22 4f c0	" O .  ; [ram_timer_aux - Auxiliary timer counter]
	jp l0ce4h		;0cde	c3 e4 0c	. . .
l0ce1h:
	ld (0c051h),a		;0ce1	32 51 c0	2 Q .  ; [ram_game_timer - Game timer (ball time / bonus countdown)]
l0ce4h:
	ld hl,(0c049h)		;0ce4	2a 49 c0	* I .
	ld de,reset_entry		;0ce7	11 00 00	. . .
	xor a			;0cea	af		.
	sbc hl,de		;0ceb	ed 52		. R
	jp z,l0cf7h		;0ced	ca f7 0c	. . .
	dec hl			;0cf0	2b		+
	ld (0c049h),hl		;0cf1	22 49 c0	" I .
	jp l0cfah		;0cf4	c3 fa 0c	. . .
l0cf7h:
	ld (0c04bh),a		;0cf7	32 4b c0	2 K .
l0cfah:
	ld a,(0c05fh)		;0cfa	3a 5f c0	: _ .  ; [ram_debounce_timer - Debounce timer (97 refs - MOST REFERENCED)]
	and a			;0cfd	a7		.
	jp z,l0d05h		;0cfe	ca 05 0d	. . .
	dec a			;0d01	3d		=
	ld (0c05fh),a		;0d02	32 5f c0	2 _ .  ; [ram_debounce_timer - Debounce timer (97 refs - MOST REFERENCED)]
l0d05h:
	ld hl,0c06dh		;0d05	21 6d c0	! m .
	ld a,(hl)		;0d08	7e		~
	and a			;0d09	a7		.
	jp z,l0d0eh		;0d0a	ca 0e 0d	. . .
	dec (hl)		;0d0d	35		5
l0d0eh:
	inc hl			;0d0e	23		#
	ld a,(hl)		;0d0f	7e		~
	and a			;0d10	a7		.
	ret z			;0d11	c8		.
	dec (hl)		;0d12	35		5
	ret			;0d13	c9		.
l0d14h:
	ld (0e33ah),a		;0d14	32 3a e3	2 : .
	ret nz			;0d17	c0		.
	bit 5,a			;0d18	cb 6f		. o
	jp z,l0d24h		;0d1a	ca 24 0d	. $ .
	ld a,(l0d14h)		;0d1d	3a 14 0d	: . .
	ld (0c046h),a		;0d20	32 46 c0	2 F .
	ret			;0d23	c9		.
l0d24h:
	ld a,(0c046h)		;0d24	3a 46 c0	: F .
	and a			;0d27	a7		.
	jp z,l0d30h		;0d28	ca 30 0d	. 0 .
	dec a			;0d2b	3d		=
	ld (0c046h),a		;0d2c	32 46 c0	2 F .
	ret			;0d2f	c9		.
l0d30h:
	ld a,020h		;0d30	3e 20		>  
	call sub_33fah		;0d32	cd fa 33	. . 3
	ld a,(0c068h)		;0d35	3a 68 c0	: h .  ; [ram_game_active - Game active flag (0=attract, nonzero=playing)]
	and a			;0d38	a7		.
	jp nz,l0d44h		;0d39	c2 44 0d	. D .
	ld a,032h		;0d3c	3e 32		> 2
	ld (0c0fch),a		;0d3e	32 fc c0	2 . .  ; [ram_switch_mailbox - *** MAILBOX BYTE *** Switch code → 80188 (86 refs!)]
	jp send_to_80188		;0d41	c3 16 01	. . .  ; → send_to_80188
l0d44h:
	ld a,033h		;0d44	3e 33		> 3
	ld (0c0fch),a		;0d46	32 fc c0	2 . .  ; [ram_switch_mailbox - *** MAILBOX BYTE *** Switch code → 80188 (86 refs!)]
	jp send_to_80188		;0d49	c3 16 01	. . .  ; → send_to_80188

; =============================================================================
; MAIN GAME LOOP
; =============================================================================

; ─────────────────────────────────────────────────────────────────────────────
; main_loop (0x0D4C)
; *** MAIN GAME LOOP *** scan → dispatch → timing → repeat
; XREF: 4 references from 0x0418, 0x0D66, 0x0D6D, 0x0D73
; ─────────────────────────────────────────────────────────────────────────────
main_loop:
	call scan_state_entry		;0d4c	cd 62 2e	. b .
	call check_start_test		;0d4f	cd 76 0d	. v .
	call switch_event_dispatch		;0d52	cd d5 16	. . .
	ld a,(0c0e3h)		;0d55	3a e3 c0	: . .  ; [ram_direct_switches - Direct switch debounced state (flippers etc)]
	or 0cch			;0d58	f6 cc		. .
	cp 0ffh			;0d5a	fe ff		. .
	call nz,flipper_event_handler	;0d5c	c4 42 12	. B .
	call check_tilt_sol_tmr		;0d5f	cd bf 0d	. . .
	ld a,(0c056h)		;0d62	3a 56 c0	: V .  ; [ram_timer_56 - Timer register 0x56]
	and a			;0d65	a7		.
	jp nz,main_loop		;0d66	c2 4c 0d	. L .  ; → main_loop
	ld a,(0c119h)		;0d69	3a 19 c1	: . .  ; [ram_lamp_state_flags - Lamp state flags (23 refs)]
	and a			;0d6c	a7		.
	jp nz,main_loop		;0d6d	c2 4c 0d	. L .  ; → main_loop
	call 03812h		;0d70	cd 12 38	. . 8
	jp main_loop		;0d73	c3 4c 0d	. L .  ; → main_loop
check_start_test:

; ─────────────────────────────────────────────────────────────────────────────
; check_start_test (0x0D76)
; Check START (port 0x03 bit 3) and TEST switches
; ─────────────────────────────────────────────────────────────────────────────
check_start_test:
	in a,(003h)		;0d76	db 03		. .  ; << PORT_DIRECT_SW_1 - Direct switches (bit3=START, bit2=TEST/COIN)
	bit 3,a			;0d78	cb 5f		. _
	call z,handler_start_btn	;0d7a	cc 92 12	. . .
	ld a,(0c00ch)		;0d7d	3a 0c c0	: . .  ; [ram_sol_timer_0 - Solenoid 0 remaining timer]
	ld hl,0c009h		;0d80	21 09 c0	! . .
	or (hl)			;0d83	b6		.
	jp z,l0d8eh		;0d84	ca 8e 0d	. . .
	in a,(003h)		;0d87	db 03		. .  ; << PORT_DIRECT_SW_1 - Direct switches (bit3=START, bit2=TEST/COIN)
	bit 3,a			;0d89	cb 5f		. _
	call nz,sol1_deactivate	;0d8b	c4 4d 06	. M .
l0d8eh:
	in a,(003h)		;0d8e	db 03		. .  ; << PORT_DIRECT_SW_1 - Direct switches (bit3=START, bit2=TEST/COIN)
	bit 2,a			;0d90	cb 57		. W
	call z,handler_coin_insert	;0d92	cc d8 12	. . .
	ld a,(0c00dh)		;0d95	3a 0d c0	: . .  ; [ram_sol_timer_1 - Solenoid 1 remaining timer]
	ld hl,0c00ah		;0d98	21 0a c0	! . .
	or (hl)			;0d9b	b6		.
	jp z,l0db0h		;0d9c	ca b0 0d	. . .
	in a,(003h)		;0d9f	db 03		. .  ; << PORT_DIRECT_SW_1 - Direct switches (bit3=START, bit2=TEST/COIN)
	bit 2,a			;0da1	cb 57		. W
	jp z,l0db0h		;0da3	ca b0 0d	. . .
	call sol2_deactivate		;0da6	cd 66 06	. f .
	ld a,(0c05bh)		;0da9	3a 5b c0	: [ .
	and a			;0dac	a7		.
	call nz,sol3_deactivate	;0dad	c4 c2 06	. . .
;  XREF: 2 refs from 0x0D9C, 0x0DA3
l0db0h:
	ld a,(0c06ah)		;0db0	3a 6a c0	: j .  ; [ram_ball_in_play - Ball-in-play counter]
	and a			;0db3	a7		.
	ret nz			;0db4	c0		.
	call sol1_deactivate		;0db5	cd 4d 06	. M .
	call sol2_deactivate		;0db8	cd 66 06	. f .
	call sol3_deactivate		;0dbb	cd c2 06	. . .
	ret			;0dbe	c9		.
check_tilt_sol_tmr:

; ─────────────────────────────────────────────────────────────────────────────
; check_tilt_sol_tmr (0x0DBF)
; Check TILT (port 0x04) + solenoid timer processing
; ─────────────────────────────────────────────────────────────────────────────
check_tilt_sol_tmr:
	in a,(004h)		;0dbf	db 04		. .  ; << PORT_DIRECT_SW_2 - Direct switches (bit0=TILT, special inputs)
	bit 0,a			;0dc1	cb 47		. G
	ret nz			;0dc3	c0		.
	ld a,(0c056h)		;0dc4	3a 56 c0	: V .  ; [ram_timer_56 - Timer register 0x56]
	and a			;0dc7	a7		.
	ret z			;0dc8	c8		.
	ld a,(0c062h)		;0dc9	3a 62 c0	: b .  ; [ram_coin_counter_1 - Coin/credit counter 1]
	and a			;0dcc	a7		.
	call nz,sub_0ffeh	;0dcd	c4 fe 0f	. . .
	ld a,(0c063h)		;0dd0	3a 63 c0	: c .  ; [ram_coin_counter_2 - Coin/credit counter 2]
	and a			;0dd3	a7		.
	call nz,sub_1011h	;0dd4	c4 11 10	. . .
	ld a,(0c064h)		;0dd7	3a 64 c0	: d .
	and a			;0dda	a7		.
	call nz,sub_1024h	;0ddb	c4 24 10	. $ .
	ld a,(0c05fh)		;0dde	3a 5f c0	: _ .  ; [ram_debounce_timer - Debounce timer (97 refs - MOST REFERENCED)]
	and a			;0de1	a7		.
	ret nz			;0de2	c0		.
	ld b,010h		;0de3	06 10		. .
	ld c,000h		;0de5	0e 00		. .
	ld de,switch_code_lut		;0de7	11 18 12	. . .
l0deah:
	ld a,(0c007h)		;0dea	3a 07 c0	: . .  ; [ram_port87_shadow - Shadow register for PORT_MATRIX_ROW]
	and 0f0h		;0ded	e6 f0		. .
	or c			;0def	b1		.
	ld (0c007h),a		;0df0	32 07 c0	2 . .  ; [ram_port87_shadow - Shadow register for PORT_MATRIX_ROW]
	out (087h),a		;0df3	d3 87		. .  ; >> PORT_MATRIX_ROW - Switch matrix row strobe select
	nop			;0df5	00		.
	nop			;0df6	00		.
	nop			;0df7	00		.
	in a,(001h)		;0df8	db 01		. .  ; << PORT_STATUS - status (bit1 = 80188 inter-board handshake ready, via J1 BUSY/AD)
	bit 5,a			;0dfa	cb 6f		. o
	jp z,l0e31h		;0dfc	ca 31 0e	. 1 .
l0dffh:
	inc c			;0dff	0c		.
	inc de			;0e00	13		.
	djnz l0deah		;0e01	10 e7		. .
	call switch_debounce		;0e03	cd b6 01	. . .  ; → switch_debounce
	inc de			;0e06	13		.
	ld a,(0c060h)		;0e07	3a 60 c0	: ` .  ; [ram_direct_sw_shadow - Direct switch shadow (port 0x00 last read)]
	bit 0,a			;0e0a	cb 47		. G
	call nz,sub_0e4eh	;0e0c	c4 4e 0e	. N .
	inc de			;0e0f	13		.
	ld a,(0c060h)		;0e10	3a 60 c0	: ` .  ; [ram_direct_sw_shadow - Direct switch shadow (port 0x00 last read)]
	bit 1,a			;0e13	cb 4f		. O
	call nz,sub_0ebah	;0e15	c4 ba 0e	. . .
	inc de			;0e18	13		.
	ld a,(0c060h)		;0e19	3a 60 c0	: ` .  ; [ram_direct_sw_shadow - Direct switch shadow (port 0x00 last read)]
	bit 2,a			;0e1c	cb 57		. W
	call nz,sub_0f26h	;0e1e	c4 26 0f	. & .
	inc de			;0e21	13		.
	inc de			;0e22	13		.
	ld a,(0c060h)		;0e23	3a 60 c0	: ` .  ; [ram_direct_sw_shadow - Direct switch shadow (port 0x00 last read)]
	bit 4,a			;0e26	cb 67		. g
	call nz,sub_0f92h	;0e28	c4 92 0f	. . .
	ld a,03ch		;0e2b	3e 3c		> <
	ld (0c05fh),a		;0e2d	32 5f c0	2 _ .  ; [ram_debounce_timer - Debounce timer (97 refs - MOST REFERENCED)]
	ret			;0e30	c9		.
l0e31h:
	ld a,005h		;0e31	3e 05		> .
	ld (0c05fh),a		;0e33	32 5f c0	2 _ .  ; [ram_debounce_timer - Debounce timer (97 refs - MOST REFERENCED)]
l0e36h:
	in a,(001h)		;0e36	db 01		. .  ; << PORT_STATUS - status (bit1 = 80188 inter-board handshake ready, via J1 BUSY/AD)
	bit 5,a			;0e38	cb 6f		. o
	jp nz,l0dffh		;0e3a	c2 ff 0d	. . .
	ld a,(0c05fh)		;0e3d	3a 5f c0	: _ .  ; [ram_debounce_timer - Debounce timer (97 refs - MOST REFERENCED)]
	and a			;0e40	a7		.
	jp nz,l0e36h		;0e41	c2 36 0e	. 6 .
;  XREF: 4 refs from 0x0EB7, 0x0F23, 0x0F8F, 0x0FFB
l0e44h:
	call sub_2851h		;0e44	cd 51 28	. Q (
	ld a,(de)		;0e47	1a		.
	ld (0c0fch),a		;0e48	32 fc c0	2 . .  ; [ram_switch_mailbox - *** MAILBOX BYTE *** Switch code → 80188 (86 refs!)]
	jp send_to_80188		;0e4b	c3 16 01	. . .  ; → send_to_80188
sub_0e4eh:
	ld a,001h		;0e4e	3e 01		> .
	ld (0c05fh),a		;0e50	32 5f c0	2 _ .  ; [ram_debounce_timer - Debounce timer (97 refs - MOST REFERENCED)]
l0e53h:
	ld a,(0c05fh)		;0e53	3a 5f c0	: _ .  ; [ram_debounce_timer - Debounce timer (97 refs - MOST REFERENCED)]
	and a			;0e56	a7		.
	jp nz,l0e53h		;0e57	c2 53 0e	. S .
	call switch_debounce		;0e5a	cd b6 01	. . .  ; → switch_debounce
	ld a,(0c060h)		;0e5d	3a 60 c0	: ` .  ; [ram_direct_sw_shadow - Direct switch shadow (port 0x00 last read)]
	bit 0,a			;0e60	cb 47		. G
	ret z			;0e62	c8		.
	ld a,001h		;0e63	3e 01		> .
	ld (0c05fh),a		;0e65	32 5f c0	2 _ .  ; [ram_debounce_timer - Debounce timer (97 refs - MOST REFERENCED)]
l0e68h:
	ld a,(0c05fh)		;0e68	3a 5f c0	: _ .  ; [ram_debounce_timer - Debounce timer (97 refs - MOST REFERENCED)]
	and a			;0e6b	a7		.
	jp nz,l0e68h		;0e6c	c2 68 0e	. h .
	call switch_debounce		;0e6f	cd b6 01	. . .  ; → switch_debounce
	ld a,(0c060h)		;0e72	3a 60 c0	: ` .  ; [ram_direct_sw_shadow - Direct switch shadow (port 0x00 last read)]
	bit 0,a			;0e75	cb 47		. G
	ret z			;0e77	c8		.
	ld a,001h		;0e78	3e 01		> .
	ld (0c05fh),a		;0e7a	32 5f c0	2 _ .  ; [ram_debounce_timer - Debounce timer (97 refs - MOST REFERENCED)]
l0e7dh:
	ld a,(0c05fh)		;0e7d	3a 5f c0	: _ .  ; [ram_debounce_timer - Debounce timer (97 refs - MOST REFERENCED)]
	and a			;0e80	a7		.
	jp nz,l0e7dh		;0e81	c2 7d 0e	. } .
	call switch_debounce		;0e84	cd b6 01	. . .  ; → switch_debounce
	ld a,(0c060h)		;0e87	3a 60 c0	: ` .  ; [ram_direct_sw_shadow - Direct switch shadow (port 0x00 last read)]
	bit 0,a			;0e8a	cb 47		. G
	ret z			;0e8c	c8		.
	ld a,001h		;0e8d	3e 01		> .
	ld (0c05fh),a		;0e8f	32 5f c0	2 _ .  ; [ram_debounce_timer - Debounce timer (97 refs - MOST REFERENCED)]
l0e92h:
	ld a,(0c05fh)		;0e92	3a 5f c0	: _ .  ; [ram_debounce_timer - Debounce timer (97 refs - MOST REFERENCED)]
	and a			;0e95	a7		.
	jp nz,l0e92h		;0e96	c2 92 0e	. . .
	call switch_debounce		;0e99	cd b6 01	. . .  ; → switch_debounce
	ld a,(0c060h)		;0e9c	3a 60 c0	: ` .  ; [ram_direct_sw_shadow - Direct switch shadow (port 0x00 last read)]
	bit 0,a			;0e9f	cb 47		. G
	ret z			;0ea1	c8		.
	ld a,001h		;0ea2	3e 01		> .
	ld (0c05fh),a		;0ea4	32 5f c0	2 _ .  ; [ram_debounce_timer - Debounce timer (97 refs - MOST REFERENCED)]
l0ea7h:
	ld a,(0c05fh)		;0ea7	3a 5f c0	: _ .  ; [ram_debounce_timer - Debounce timer (97 refs - MOST REFERENCED)]
	and a			;0eaa	a7		.
	jp nz,l0ea7h		;0eab	c2 a7 0e	. . .
	call switch_debounce		;0eae	cd b6 01	. . .  ; → switch_debounce
	ld a,(0c060h)		;0eb1	3a 60 c0	: ` .  ; [ram_direct_sw_shadow - Direct switch shadow (port 0x00 last read)]
	bit 0,a			;0eb4	cb 47		. G
	ret z			;0eb6	c8		.
	jp l0e44h		;0eb7	c3 44 0e	. D .
sub_0ebah:
	ld a,001h		;0eba	3e 01		> .
	ld (0c05fh),a		;0ebc	32 5f c0	2 _ .  ; [ram_debounce_timer - Debounce timer (97 refs - MOST REFERENCED)]
l0ebfh:
	ld a,(0c05fh)		;0ebf	3a 5f c0	: _ .  ; [ram_debounce_timer - Debounce timer (97 refs - MOST REFERENCED)]
	and a			;0ec2	a7		.
	jp nz,l0ebfh		;0ec3	c2 bf 0e	. . .
	call switch_debounce		;0ec6	cd b6 01	. . .  ; → switch_debounce
	ld a,(0c060h)		;0ec9	3a 60 c0	: ` .  ; [ram_direct_sw_shadow - Direct switch shadow (port 0x00 last read)]
	bit 1,a			;0ecc	cb 4f		. O
	ret z			;0ece	c8		.
	ld a,001h		;0ecf	3e 01		> .
	ld (0c05fh),a		;0ed1	32 5f c0	2 _ .  ; [ram_debounce_timer - Debounce timer (97 refs - MOST REFERENCED)]
l0ed4h:
	ld a,(0c05fh)		;0ed4	3a 5f c0	: _ .  ; [ram_debounce_timer - Debounce timer (97 refs - MOST REFERENCED)]
	and a			;0ed7	a7		.
	jp nz,l0ed4h		;0ed8	c2 d4 0e	. . .
	call switch_debounce		;0edb	cd b6 01	. . .  ; → switch_debounce
	ld a,(0c060h)		;0ede	3a 60 c0	: ` .  ; [ram_direct_sw_shadow - Direct switch shadow (port 0x00 last read)]
	bit 1,a			;0ee1	cb 4f		. O
	ret z			;0ee3	c8		.
	ld a,001h		;0ee4	3e 01		> .
	ld (0c05fh),a		;0ee6	32 5f c0	2 _ .  ; [ram_debounce_timer - Debounce timer (97 refs - MOST REFERENCED)]
l0ee9h:
	ld a,(0c05fh)		;0ee9	3a 5f c0	: _ .  ; [ram_debounce_timer - Debounce timer (97 refs - MOST REFERENCED)]
	and a			;0eec	a7		.
	jp nz,l0ee9h		;0eed	c2 e9 0e	. . .
	call switch_debounce		;0ef0	cd b6 01	. . .  ; → switch_debounce
	ld a,(0c060h)		;0ef3	3a 60 c0	: ` .  ; [ram_direct_sw_shadow - Direct switch shadow (port 0x00 last read)]
	bit 1,a			;0ef6	cb 4f		. O
	ret z			;0ef8	c8		.
	ld a,001h		;0ef9	3e 01		> .
	ld (0c05fh),a		;0efb	32 5f c0	2 _ .  ; [ram_debounce_timer - Debounce timer (97 refs - MOST REFERENCED)]
l0efeh:
	ld a,(0c05fh)		;0efe	3a 5f c0	: _ .  ; [ram_debounce_timer - Debounce timer (97 refs - MOST REFERENCED)]
	and a			;0f01	a7		.
	jp nz,l0efeh		;0f02	c2 fe 0e	. . .
	call switch_debounce		;0f05	cd b6 01	. . .  ; → switch_debounce
	ld a,(0c060h)		;0f08	3a 60 c0	: ` .  ; [ram_direct_sw_shadow - Direct switch shadow (port 0x00 last read)]
	bit 1,a			;0f0b	cb 4f		. O
	ret z			;0f0d	c8		.
	ld a,001h		;0f0e	3e 01		> .
	ld (0c05fh),a		;0f10	32 5f c0	2 _ .  ; [ram_debounce_timer - Debounce timer (97 refs - MOST REFERENCED)]
l0f13h:
	ld a,(0c05fh)		;0f13	3a 5f c0	: _ .  ; [ram_debounce_timer - Debounce timer (97 refs - MOST REFERENCED)]
	and a			;0f16	a7		.
	jp nz,l0f13h		;0f17	c2 13 0f	. . .
	call switch_debounce		;0f1a	cd b6 01	. . .  ; → switch_debounce
	ld a,(0c060h)		;0f1d	3a 60 c0	: ` .  ; [ram_direct_sw_shadow - Direct switch shadow (port 0x00 last read)]
	bit 1,a			;0f20	cb 4f		. O
	ret z			;0f22	c8		.
	jp l0e44h		;0f23	c3 44 0e	. D .
sub_0f26h:
	ld a,001h		;0f26	3e 01		> .
	ld (0c05fh),a		;0f28	32 5f c0	2 _ .  ; [ram_debounce_timer - Debounce timer (97 refs - MOST REFERENCED)]
l0f2bh:
	ld a,(0c05fh)		;0f2b	3a 5f c0	: _ .  ; [ram_debounce_timer - Debounce timer (97 refs - MOST REFERENCED)]
	and a			;0f2e	a7		.
	jp nz,l0f2bh		;0f2f	c2 2b 0f	. + .
	call switch_debounce		;0f32	cd b6 01	. . .  ; → switch_debounce
	ld a,(0c060h)		;0f35	3a 60 c0	: ` .  ; [ram_direct_sw_shadow - Direct switch shadow (port 0x00 last read)]
	bit 2,a			;0f38	cb 57		. W
	ret z			;0f3a	c8		.
	ld a,001h		;0f3b	3e 01		> .
	ld (0c05fh),a		;0f3d	32 5f c0	2 _ .  ; [ram_debounce_timer - Debounce timer (97 refs - MOST REFERENCED)]
l0f40h:
	ld a,(0c05fh)		;0f40	3a 5f c0	: _ .  ; [ram_debounce_timer - Debounce timer (97 refs - MOST REFERENCED)]
	and a			;0f43	a7		.
	jp nz,l0f40h		;0f44	c2 40 0f	. @ .
	call switch_debounce		;0f47	cd b6 01	. . .  ; → switch_debounce
	ld a,(0c060h)		;0f4a	3a 60 c0	: ` .  ; [ram_direct_sw_shadow - Direct switch shadow (port 0x00 last read)]
	bit 2,a			;0f4d	cb 57		. W
	ret z			;0f4f	c8		.
	ld a,001h		;0f50	3e 01		> .
	ld (0c05fh),a		;0f52	32 5f c0	2 _ .  ; [ram_debounce_timer - Debounce timer (97 refs - MOST REFERENCED)]
l0f55h:
	ld a,(0c05fh)		;0f55	3a 5f c0	: _ .  ; [ram_debounce_timer - Debounce timer (97 refs - MOST REFERENCED)]
	and a			;0f58	a7		.
	jp nz,l0f55h		;0f59	c2 55 0f	. U .
	call switch_debounce		;0f5c	cd b6 01	. . .  ; → switch_debounce
	ld a,(0c060h)		;0f5f	3a 60 c0	: ` .  ; [ram_direct_sw_shadow - Direct switch shadow (port 0x00 last read)]
	bit 2,a			;0f62	cb 57		. W
	ret z			;0f64	c8		.
	ld a,001h		;0f65	3e 01		> .
	ld (0c05fh),a		;0f67	32 5f c0	2 _ .  ; [ram_debounce_timer - Debounce timer (97 refs - MOST REFERENCED)]
l0f6ah:
	ld a,(0c05fh)		;0f6a	3a 5f c0	: _ .  ; [ram_debounce_timer - Debounce timer (97 refs - MOST REFERENCED)]
	and a			;0f6d	a7		.
	jp nz,l0f6ah		;0f6e	c2 6a 0f	. j .
	call switch_debounce		;0f71	cd b6 01	. . .  ; → switch_debounce
	ld a,(0c060h)		;0f74	3a 60 c0	: ` .  ; [ram_direct_sw_shadow - Direct switch shadow (port 0x00 last read)]
	bit 2,a			;0f77	cb 57		. W
	ret z			;0f79	c8		.
	ld a,001h		;0f7a	3e 01		> .
	ld (0c05fh),a		;0f7c	32 5f c0	2 _ .  ; [ram_debounce_timer - Debounce timer (97 refs - MOST REFERENCED)]
l0f7fh:
	ld a,(0c05fh)		;0f7f	3a 5f c0	: _ .  ; [ram_debounce_timer - Debounce timer (97 refs - MOST REFERENCED)]
	and a			;0f82	a7		.
	jp nz,l0f7fh		;0f83	c2 7f 0f	. . .
	call switch_debounce		;0f86	cd b6 01	. . .  ; → switch_debounce
	ld a,(0c060h)		;0f89	3a 60 c0	: ` .  ; [ram_direct_sw_shadow - Direct switch shadow (port 0x00 last read)]
	bit 2,a			;0f8c	cb 57		. W
	ret z			;0f8e	c8		.
	jp l0e44h		;0f8f	c3 44 0e	. D .
sub_0f92h:
	ld a,001h		;0f92	3e 01		> .
	ld (0c05fh),a		;0f94	32 5f c0	2 _ .  ; [ram_debounce_timer - Debounce timer (97 refs - MOST REFERENCED)]
l0f97h:
	ld a,(0c05fh)		;0f97	3a 5f c0	: _ .  ; [ram_debounce_timer - Debounce timer (97 refs - MOST REFERENCED)]
	and a			;0f9a	a7		.
	jp nz,l0f97h		;0f9b	c2 97 0f	. . .
	call switch_debounce		;0f9e	cd b6 01	. . .  ; → switch_debounce
	ld a,(0c060h)		;0fa1	3a 60 c0	: ` .  ; [ram_direct_sw_shadow - Direct switch shadow (port 0x00 last read)]
	bit 4,a			;0fa4	cb 67		. g
	ret z			;0fa6	c8		.
	ld a,001h		;0fa7	3e 01		> .
	ld (0c05fh),a		;0fa9	32 5f c0	2 _ .  ; [ram_debounce_timer - Debounce timer (97 refs - MOST REFERENCED)]
l0fach:
	ld a,(0c05fh)		;0fac	3a 5f c0	: _ .  ; [ram_debounce_timer - Debounce timer (97 refs - MOST REFERENCED)]
	and a			;0faf	a7		.
	jp nz,l0fach		;0fb0	c2 ac 0f	. . .
	call switch_debounce		;0fb3	cd b6 01	. . .  ; → switch_debounce
	ld a,(0c060h)		;0fb6	3a 60 c0	: ` .  ; [ram_direct_sw_shadow - Direct switch shadow (port 0x00 last read)]
	bit 4,a			;0fb9	cb 67		. g
	ret z			;0fbb	c8		.
	ld a,001h		;0fbc	3e 01		> .
	ld (0c05fh),a		;0fbe	32 5f c0	2 _ .  ; [ram_debounce_timer - Debounce timer (97 refs - MOST REFERENCED)]
l0fc1h:
	ld a,(0c05fh)		;0fc1	3a 5f c0	: _ .  ; [ram_debounce_timer - Debounce timer (97 refs - MOST REFERENCED)]
	and a			;0fc4	a7		.
	jp nz,l0fc1h		;0fc5	c2 c1 0f	. . .
	call switch_debounce		;0fc8	cd b6 01	. . .  ; → switch_debounce
	ld a,(0c060h)		;0fcb	3a 60 c0	: ` .  ; [ram_direct_sw_shadow - Direct switch shadow (port 0x00 last read)]
	bit 4,a			;0fce	cb 67		. g
	ret z			;0fd0	c8		.
	ld a,001h		;0fd1	3e 01		> .
	ld (0c05fh),a		;0fd3	32 5f c0	2 _ .  ; [ram_debounce_timer - Debounce timer (97 refs - MOST REFERENCED)]
l0fd6h:
	ld a,(0c05fh)		;0fd6	3a 5f c0	: _ .  ; [ram_debounce_timer - Debounce timer (97 refs - MOST REFERENCED)]
	and a			;0fd9	a7		.
	jp nz,l0fd6h		;0fda	c2 d6 0f	. . .
	call switch_debounce		;0fdd	cd b6 01	. . .  ; → switch_debounce
	ld a,(0c060h)		;0fe0	3a 60 c0	: ` .  ; [ram_direct_sw_shadow - Direct switch shadow (port 0x00 last read)]
	bit 4,a			;0fe3	cb 67		. g
	ret z			;0fe5	c8		.
	ld a,001h		;0fe6	3e 01		> .
	ld (0c05fh),a		;0fe8	32 5f c0	2 _ .  ; [ram_debounce_timer - Debounce timer (97 refs - MOST REFERENCED)]
l0febh:
	ld a,(0c05fh)		;0feb	3a 5f c0	: _ .  ; [ram_debounce_timer - Debounce timer (97 refs - MOST REFERENCED)]
	and a			;0fee	a7		.
	jp nz,l0febh		;0fef	c2 eb 0f	. . .
	call switch_debounce		;0ff2	cd b6 01	. . .  ; → switch_debounce
	ld a,(0c060h)		;0ff5	3a 60 c0	: ` .  ; [ram_direct_sw_shadow - Direct switch shadow (port 0x00 last read)]
	bit 4,a			;0ff8	cb 67		. g
	ret z			;0ffa	c8		.
	jp l0e44h		;0ffb	c3 44 0e	. D .
sub_0ffeh:
	ld a,(0c065h)		;0ffe	3a 65 c0	: e .
	and a			;1001	a7		.
	ret nz			;1002	c0		.
	ld a,0ffh		;1003	3e ff		> .
	ld (0c065h),a		;1005	32 65 c0	2 e .
	ld a,(l123fh)		;1008	3a 3f 12	: ? .
l100bh:
	ld (0c0fch),a		;100b	32 fc c0	2 . .  ; [ram_switch_mailbox - *** MAILBOX BYTE *** Switch code → 80188 (86 refs!)]
	jp send_to_80188		;100e	c3 16 01	. . .  ; → send_to_80188
sub_1011h:
	ld a,(0c066h)		;1011	3a 66 c0	: f .
	and a			;1014	a7		.
	ret nz			;1015	c0		.
	ld a,0ffh		;1016	3e ff		> .
	ld (0c066h),a		;1018	32 66 c0	2 f .
	ld a,(l1240h)		;101b	3a 40 12	: @ .
	ld (0c0fch),a		;101e	32 fc c0	2 . .  ; [ram_switch_mailbox - *** MAILBOX BYTE *** Switch code → 80188 (86 refs!)]
	jp send_to_80188		;1021	c3 16 01	. . .  ; → send_to_80188
sub_1024h:
	ld a,(0c067h)		;1024	3a 67 c0	: g .
	and a			;1027	a7		.
	ret nz			;1028	c0		.
	ld a,0ffh		;1029	3e ff		> .
	ld (0c067h),a		;102b	32 67 c0	2 g .
	ld a,(l1241h)		;102e	3a 41 12	: A .
	ld (0c0fch),a		;1031	32 fc c0	2 . .  ; [ram_switch_mailbox - *** MAILBOX BYTE *** Switch code → 80188 (86 refs!)]
	jp send_to_80188		;1034	c3 16 01	. . .  ; → send_to_80188
	ld c,001h		;1037	0e 01		. .
	ld de,l122dh		;1039	11 2d 12	. - .
	call sol1_activate		;103c	cd 13 06	. . .
	call lamp_update_helper		;103f	cd e4 10	. . .
	call sol1_deactivate		;1042	cd 4d 06	. M .
	ld c,003h		;1045	0e 03		. .
	call sol2_activate		;1047	cd 30 06	. 0 .
	call lamp_update_helper		;104a	cd e4 10	. . .
	call sol2_deactivate		;104d	cd 66 06	. f .
	ld c,005h		;1050	0e 05		. .
	call sol4_activate		;1052	cd a5 06	. . .
	call lamp_update_helper		;1055	cd e4 10	. . .
	call sol3_deactivate		;1058	cd c2 06	. . .
	ld c,006h		;105b	0e 06		. .
	call sol5_activate		;105d	cd db 06	. . .
	call lamp_update_helper		;1060	cd e4 10	. . .
	call sub_07fdh		;1063	cd fd 07	. . .
	call sub_07e0h		;1066	cd e0 07	. . .
	call lamp_update_helper		;1069	cd e4 10	. . .
	call sub_0896h		;106c	cd 96 08	. . .
	call sol6_activate		;106f	cd f8 06	. . .
	call lamp_update_helper		;1072	cd e4 10	. . .
	call sub_080eh		;1075	cd 0e 08	. . .
	call sol7_activate		;1078	cd 15 07	. . .
	call lamp_update_helper		;107b	cd e4 10	. . .
	call sub_081fh		;107e	cd 1f 08	. . .
	call sol8_activate		;1081	cd 32 07	. 2 .
	call lamp_update_helper		;1084	cd e4 10	. . .
	call sub_0830h		;1087	cd 30 08	. 0 .
	call sol9_activate		;108a	cd 4f 07	. O .
	call lamp_update_helper		;108d	cd e4 10	. . .
	call sub_0841h		;1090	cd 41 08	. A .
	call sol10_activate		;1093	cd 6c 07	. l .
	call lamp_update_helper		;1096	cd e4 10	. . .
	call sub_0852h		;1099	cd 52 08	. R .
	call sol11_activate		;109c	cd 89 07	. . .
	call lamp_update_helper		;109f	cd e4 10	. . .
	call sub_0863h		;10a2	cd 63 08	. c .
	call sol12_activate		;10a5	cd a6 07	. . .
	call lamp_update_helper		;10a8	cd e4 10	. . .
	call sub_0874h		;10ab	cd 74 08	. t .
	call sol13_activate		;10ae	cd c3 07	. . .
	call lamp_update_helper		;10b1	cd e4 10	. . .
	call sub_0885h		;10b4	cd 85 08	. . .
	call sub_08a7h		;10b7	cd a7 08	. . .
	call sub_1121h		;10ba	cd 21 11	. ! .
	call sub_08c5h		;10bd	cd c5 08	. . .
	call sub_08d3h		;10c0	cd d3 08	. . .
	call sub_1156h		;10c3	cd 56 11	. V .
	call sub_08f1h		;10c6	cd f1 08	. . .
	call sub_08ffh		;10c9	cd ff 08	. . .
	call sub_118bh		;10cc	cd 8b 11	. . .
	call sub_091dh		;10cf	cd 1d 09	. . .
	inc de			;10d2	13		.
	call sub_0957h		;10d3	cd 57 09	. W .
	call sub_11c0h		;10d6	cd c0 11	. . .
	call sub_0993h		;10d9	cd 93 09	. . .
	ld a,07ah		;10dc	3e 7a		> z
	ld (0c0fch),a		;10de	32 fc c0	2 . .  ; [ram_switch_mailbox - *** MAILBOX BYTE *** Switch code → 80188 (86 refs!)]
	jp send_to_80188		;10e1	c3 16 01	. . .  ; → send_to_80188
lamp_update_helper:
	ld hl,0c04ch		;10e4	21 4c c0	! L .
	ld (hl),004h		;10e7	36 04		6 .
	ld a,0ffh		;10e9	3e ff		> .
	ld (0c04eh),a		;10eb	32 4e c0	2 N .  ; [ram_timer_flag - Main timer flag (controls game timing)]
	ld a,(0c007h)		;10ee	3a 07 c0	: . .  ; [ram_port87_shadow - Shadow register for PORT_MATRIX_ROW]
	and 0f0h		;10f1	e6 f0		. .
	or c			;10f3	b1		.
	ld (0c007h),a		;10f4	32 07 c0	2 . .  ; [ram_port87_shadow - Shadow register for PORT_MATRIX_ROW]
	out (087h),a		;10f7	d3 87		. .  ; >> PORT_MATRIX_ROW - Switch matrix row strobe select
l10f9h:
	in a,(001h)		;10f9	db 01		. .  ; << PORT_STATUS - status (bit1 = 80188 inter-board handshake ready, via J1 BUSY/AD)
	bit 5,a			;10fb	cb 6f		. o
	jp z,l110eh		;10fd	ca 0e 11	. . .
	ld a,(0c04eh)		;1100	3a 4e c0	: N .  ; [ram_timer_flag - Main timer flag (controls game timing)]
	and a			;1103	a7		.
	jp nz,l10f9h		;1104	c2 f9 10	. . .
	ld a,(de)		;1107	1a		.
	ld (0c0fch),a		;1108	32 fc c0	2 . .  ; [ram_switch_mailbox - *** MAILBOX BYTE *** Switch code → 80188 (86 refs!)]
	call send_to_80188		;110b	cd 16 01	. . .  ; → send_to_80188
l110eh:
	inc de			;110e	13		.
	inc c			;110f	0c		.
	ld hl,0c04ch		;1110	21 4c c0	! L .
	ld (hl),096h		;1113	36 96		6 .
	ld a,0ffh		;1115	3e ff		> .
	ld (0c04eh),a		;1117	32 4e c0	2 N .  ; [ram_timer_flag - Main timer flag (controls game timing)]
l111ah:
	ld a,(0c04eh)		;111a	3a 4e c0	: N .  ; [ram_timer_flag - Main timer flag (controls game timing)]
	and a			;111d	a7		.
	ret z			;111e	c8		.
	jr l111ah		;111f	18 f9		. .
sub_1121h:
	ld hl,0c04ch		;1121	21 4c c0	! L .
	ld (hl),004h		;1124	36 04		6 .
	ld a,0ffh		;1126	3e ff		> .
	ld (0c04eh),a		;1128	32 4e c0	2 N .  ; [ram_timer_flag - Main timer flag (controls game timing)]
l112bh:
	call switch_debounce		;112b	cd b6 01	. . .  ; → switch_debounce
	ld a,(0c060h)		;112e	3a 60 c0	: ` .  ; [ram_direct_sw_shadow - Direct switch shadow (port 0x00 last read)]
	bit 0,a			;1131	cb 47		. G
	jp nz,l1144h		;1133	c2 44 11	. D .
	ld a,(0c04eh)		;1136	3a 4e c0	: N .  ; [ram_timer_flag - Main timer flag (controls game timing)]
	and a			;1139	a7		.
	jp nz,l112bh		;113a	c2 2b 11	. + .
	ld a,(de)		;113d	1a		.
	ld (0c0fch),a		;113e	32 fc c0	2 . .  ; [ram_switch_mailbox - *** MAILBOX BYTE *** Switch code → 80188 (86 refs!)]
	call send_to_80188		;1141	cd 16 01	. . .  ; → send_to_80188
l1144h:
	inc de			;1144	13		.
	ld hl,0c04ch		;1145	21 4c c0	! L .
	ld (hl),096h		;1148	36 96		6 .
	ld a,0ffh		;114a	3e ff		> .
	ld (0c04eh),a		;114c	32 4e c0	2 N .  ; [ram_timer_flag - Main timer flag (controls game timing)]
l114fh:
	ld a,(0c04eh)		;114f	3a 4e c0	: N .  ; [ram_timer_flag - Main timer flag (controls game timing)]
	and a			;1152	a7		.
	ret z			;1153	c8		.
	jr l114fh		;1154	18 f9		. .
sub_1156h:
	ld hl,0c04ch		;1156	21 4c c0	! L .
	ld (hl),004h		;1159	36 04		6 .
	ld a,0ffh		;115b	3e ff		> .
	ld (0c04eh),a		;115d	32 4e c0	2 N .  ; [ram_timer_flag - Main timer flag (controls game timing)]
l1160h:
	call switch_debounce		;1160	cd b6 01	. . .  ; → switch_debounce
	ld a,(0c060h)		;1163	3a 60 c0	: ` .  ; [ram_direct_sw_shadow - Direct switch shadow (port 0x00 last read)]
	bit 1,a			;1166	cb 4f		. O
	jp nz,l1179h		;1168	c2 79 11	. y .
	ld a,(0c04eh)		;116b	3a 4e c0	: N .  ; [ram_timer_flag - Main timer flag (controls game timing)]
	and a			;116e	a7		.
	jp nz,l1160h		;116f	c2 60 11	. ` .
	ld a,(de)		;1172	1a		.
	ld (0c0fch),a		;1173	32 fc c0	2 . .  ; [ram_switch_mailbox - *** MAILBOX BYTE *** Switch code → 80188 (86 refs!)]
	call send_to_80188		;1176	cd 16 01	. . .  ; → send_to_80188
l1179h:
	inc de			;1179	13		.
	ld hl,0c04ch		;117a	21 4c c0	! L .
	ld (hl),096h		;117d	36 96		6 .
	ld a,0ffh		;117f	3e ff		> .
	ld (0c04eh),a		;1181	32 4e c0	2 N .  ; [ram_timer_flag - Main timer flag (controls game timing)]
l1184h:
	ld a,(0c04eh)		;1184	3a 4e c0	: N .  ; [ram_timer_flag - Main timer flag (controls game timing)]
	and a			;1187	a7		.
	ret z			;1188	c8		.
	jr l1184h		;1189	18 f9		. .
sub_118bh:
	ld hl,0c04ch		;118b	21 4c c0	! L .
	ld (hl),004h		;118e	36 04		6 .
	ld a,0ffh		;1190	3e ff		> .
	ld (0c04eh),a		;1192	32 4e c0	2 N .  ; [ram_timer_flag - Main timer flag (controls game timing)]
l1195h:
	call switch_debounce		;1195	cd b6 01	. . .  ; → switch_debounce
	ld a,(0c060h)		;1198	3a 60 c0	: ` .  ; [ram_direct_sw_shadow - Direct switch shadow (port 0x00 last read)]
	bit 2,a			;119b	cb 57		. W
	jp nz,l11aeh		;119d	c2 ae 11	. . .
	ld a,(0c04eh)		;11a0	3a 4e c0	: N .  ; [ram_timer_flag - Main timer flag (controls game timing)]
	and a			;11a3	a7		.
	jp nz,l1195h		;11a4	c2 95 11	. . .
	ld a,(de)		;11a7	1a		.
	ld (0c0fch),a		;11a8	32 fc c0	2 . .  ; [ram_switch_mailbox - *** MAILBOX BYTE *** Switch code → 80188 (86 refs!)]
	call send_to_80188		;11ab	cd 16 01	. . .  ; → send_to_80188
l11aeh:
	inc de			;11ae	13		.
	ld hl,0c04ch		;11af	21 4c c0	! L .
	ld (hl),096h		;11b2	36 96		6 .
	ld a,0ffh		;11b4	3e ff		> .
	ld (0c04eh),a		;11b6	32 4e c0	2 N .  ; [ram_timer_flag - Main timer flag (controls game timing)]
l11b9h:
	ld a,(0c04eh)		;11b9	3a 4e c0	: N .  ; [ram_timer_flag - Main timer flag (controls game timing)]
	and a			;11bc	a7		.
	ret z			;11bd	c8		.
	jr l11b9h		;11be	18 f9		. .
sub_11c0h:
	ld hl,0c04ch		;11c0	21 4c c0	! L .
	ld (hl),004h		;11c3	36 04		6 .
	ld a,0ffh		;11c5	3e ff		> .
	ld (0c04eh),a		;11c7	32 4e c0	2 N .  ; [ram_timer_flag - Main timer flag (controls game timing)]
l11cah:
	call switch_debounce		;11ca	cd b6 01	. . .  ; → switch_debounce
	ld a,(0c060h)		;11cd	3a 60 c0	: ` .  ; [ram_direct_sw_shadow - Direct switch shadow (port 0x00 last read)]
	bit 4,a			;11d0	cb 67		. g
	jp nz,l11e3h		;11d2	c2 e3 11	. . .
	ld a,(0c04eh)		;11d5	3a 4e c0	: N .  ; [ram_timer_flag - Main timer flag (controls game timing)]
	and a			;11d8	a7		.
	jp nz,l11cah		;11d9	c2 ca 11	. . .
	ld a,(de)		;11dc	1a		.
	ld (0c0fch),a		;11dd	32 fc c0	2 . .  ; [ram_switch_mailbox - *** MAILBOX BYTE *** Switch code → 80188 (86 refs!)]
	call send_to_80188		;11e0	cd 16 01	. . .  ; → send_to_80188
l11e3h:
	inc de			;11e3	13		.
	ld hl,0c04ch		;11e4	21 4c c0	! L .
	ld (hl),096h		;11e7	36 96		6 .
	ld a,0ffh		;11e9	3e ff		> .
	ld (0c04eh),a		;11eb	32 4e c0	2 N .  ; [ram_timer_flag - Main timer flag (controls game timing)]
l11eeh:
	ld a,(0c04eh)		;11ee	3a 4e c0	: N .  ; [ram_timer_flag - Main timer flag (controls game timing)]
	and a			;11f1	a7		.
	ret z			;11f2	c8		.
	jr l11eeh		;11f3	18 f9		. .
	in a,(004h)		;11f5	db 04		. .  ; << PORT_DIRECT_SW_2 - Direct switches (bit0=TILT, special inputs)
	bit 0,a			;11f7	cb 47		. G
	jp nz,l1210h		;11f9	c2 10 12	. . .
	call sub_2831h		;11fc	cd 31 28	. 1 (
l11ffh:
	ld a,(0c05fh)		;11ff	3a 5f c0	: _ .  ; [ram_debounce_timer - Debounce timer (97 refs - MOST REFERENCED)]
	and a			;1202	a7		.
	jp nz,l11ffh		;1203	c2 ff 11	. . .
	ld b,0ffh		;1206	06 ff		. .

; =============================================================================
; GAME LOGIC
; =============================================================================

; ─────────────────────────────────────────────────────────────────────────────
; flipper_handler_base (0x1208)
; Flipper button handler base routine
; ─────────────────────────────────────────────────────────────────────────────
flipper_handler_base:
	call check_tilt_sol_tmr		;1208	cd bf 0d	. . .
	djnz flipper_handler_base		;120b	10 fb		. .
	call sub_2851h		;120d	cd 51 28	. Q (
l1210h:
	ld a,07ah		;1210	3e 7a		> z
	ld (0c0fch),a		;1212	32 fc c0	2 . .  ; [ram_switch_mailbox - *** MAILBOX BYTE *** Switch code → 80188 (86 refs!)]
	jp send_to_80188		;1215	c3 16 01	. . .  ; → send_to_80188

; ─────────────────────────────────────────────────────────────────────────────
; switch_code_lut (0x1218)
; DATA: Switch code lookup (32 bytes: 0x50-0x6F = 'P'-'o')
; ─────────────────────────────────────────────────────────────────────────────
switch_code_lut:
	ld d,b			;1218	50		P
	ld d,c			;1219	51		Q
	ld d,d			;121a	52		R
	ld d,e			;121b	53		S
	ld d,h			;121c	54		T
	ld d,l			;121d	55		U
	ld d,(hl)		;121e	56		V
	ld d,a			;121f	57		W
	ld e,b			;1220	58		X
	ld e,c			;1221	59		Y
	ld e,d			;1222	5a		Z
	ld e,e			;1223	5b		[
	ld e,h			;1224	5c		\
	ld e,l			;1225	5d		]
	ld e,(hl)		;1226	5e		^
	ld e,a			;1227	5f		_
	ld h,b			;1228	60		`
	ld h,c			;1229	61		a
	ld h,d			;122a	62		b
	ld h,e			;122b	63		c
	ld h,h			;122c	64		d
l122dh:
	ld h,l			;122d	65		e
	ld h,(hl)		;122e	66		f
	ld h,a			;122f	67		g
	ld l,b			;1230	68		h
	ld l,c			;1231	69		i
	ld l,d			;1232	6a		j
	ld l,e			;1233	6b		k
	ld l,h			;1234	6c		l
	ld l,l			;1235	6d		m
	ld l,(hl)		;1236	6e		n
	ld l,a			;1237	6f		o
	ld (hl),b		;1238	70		p
	ld (hl),c		;1239	71		q
	ld (hl),d		;123a	72		r
	ld (hl),e		;123b	73		s
	ld (hl),h		;123c	74		t
	ld (hl),l		;123d	75		u
	halt			;123e	76		v
l123fh:
	ld (hl),a		;123f	77		w
l1240h:
	ld a,b			;1240	78		x
l1241h:
	ld a,c			;1241	79		y
flipper_event_handler:
	ld a,(0c0e3h)		;1242	3a e3 c0	: . .  ; [ram_direct_switches - Direct switch debounced state (flippers etc)]
	bit 0,a			;1245	cb 47		. G
	call z,handler_left_flip	;1247	cc 5b 12	. [ .
	ld a,(0c0e3h)		;124a	3a e3 c0	: . .  ; [ram_direct_switches - Direct switch debounced state (flippers etc)]
	bit 1,a			;124d	cb 4f		. O
	call z,handler_right_flip	;124f	cc 78 12	. x .
	ld a,(0c0e3h)		;1252	3a e3 c0	: . .  ; [ram_direct_switches - Direct switch debounced state (flippers etc)]
	bit 4,a			;1255	cb 67		. g
	call z,handler_upper_flip	;1257	cc 85 12	. . .
	ret			;125a	c9		.
handler_left_flip:
	ld a,001h		;125b	3e 01		> .
	call sub_33fah		;125d	cd fa 33	. . 3
	ld a,(0c051h)		;1260	3a 51 c0	: Q .  ; [ram_game_timer - Game timer (ball time / bonus countdown)]
	and a			;1263	a7		.
	ret nz			;1264	c0		.
	ld hl,00bb8h		;1265	21 b8 0b	! . .
	ld (0c04fh),hl		;1268	22 4f c0	" O .  ; [ram_timer_aux - Auxiliary timer counter]
	ld a,0ffh		;126b	3e ff		> .
	ld (0c051h),a		;126d	32 51 c0	2 Q .  ; [ram_game_timer - Game timer (ball time / bonus countdown)]
	ld a,03eh		;1270	3e 3e		> >
	ld (0c0fch),a		;1272	32 fc c0	2 . .  ; [ram_switch_mailbox - *** MAILBOX BYTE *** Switch code → 80188 (86 refs!)]
	jp send_to_80188		;1275	c3 16 01	. . .  ; → send_to_80188
handler_right_flip:
	ld a,002h		;1278	3e 02		> .
	call sub_33fah		;127a	cd fa 33	. . 3
	ld a,03fh		;127d	3e 3f		> ?
	ld (0c0fch),a		;127f	32 fc c0	2 . .  ; [ram_switch_mailbox - *** MAILBOX BYTE *** Switch code → 80188 (86 refs!)]
	jp send_to_80188		;1282	c3 16 01	. . .  ; → send_to_80188
handler_upper_flip:
	ld a,010h		;1285	3e 10		> .
	call sub_33fah		;1287	cd fa 33	. . 3
	ld a,040h		;128a	3e 40		> @
	ld (0c0fch),a		;128c	32 fc c0	2 . .  ; [ram_switch_mailbox - *** MAILBOX BYTE *** Switch code → 80188 (86 refs!)]
	jp send_to_80188		;128f	c3 16 01	. . .  ; → send_to_80188
handler_start_btn:
	ld a,(0c068h)		;1292	3a 68 c0	: h .  ; [ram_game_active - Game active flag (0=attract, nonzero=playing)]
	and a			;1295	a7		.
	jp nz,l12c6h		;1296	c2 c6 12	. . .
	ld a,(0c069h)		;1299	3a 69 c0	: i .
	and a			;129c	a7		.
	jp nz,l12c6h		;129d	c2 c6 12	. . .
	ld a,(0c06ah)		;12a0	3a 6a c0	: j .  ; [ram_ball_in_play - Ball-in-play counter]
	and a			;12a3	a7		.
	ret z			;12a4	c8		.
	ld a,(0c0dbh)		;12a5	3a db c0	: . .  ; [ram_row0_switches - Matrix row 0 debounced switch state]
	bit 6,a			;12a8	cb 77		. w
	jp z,l12bdh		;12aa	ca bd 12	. . .
	ld a,(0c062h)		;12ad	3a 62 c0	: b .  ; [ram_coin_counter_1 - Coin/credit counter 1]
	and a			;12b0	a7		.
	jp nz,l12bdh		;12b1	c2 bd 12	. . .
	ld a,(0c009h)		;12b4	3a 09 c0	: . .  ; [ram_work_area - Work RAM area start (cleared during init)]
	and a			;12b7	a7		.
	ret nz			;12b8	c0		.
	call 005c7h		;12b9	cd c7 05	. . .
	ret			;12bc	c9		.
;  XREF: 2 refs from 0x12AA, 0x12B1
l12bdh:
	ld a,(0c00ch)		;12bd	3a 0c c0	: . .  ; [ram_sol_timer_0 - Solenoid 0 remaining timer]
	and a			;12c0	a7		.
	ret nz			;12c1	c0		.
	call sol1_activate		;12c2	cd 13 06	. . .
	ret			;12c5	c9		.
;  XREF: 2 refs from 0x1296, 0x129D
l12c6h:
	ld a,(0c06dh)		;12c6	3a 6d c0	: m .
	and a			;12c9	a7		.
	ret nz			;12ca	c0		.
	ld a,00ah		;12cb	3e 0a		> .
	ld (0c06dh),a		;12cd	32 6d c0	2 m .
	ld a,041h		;12d0	3e 41		> A
	ld (0c0fch),a		;12d2	32 fc c0	2 . .  ; [ram_switch_mailbox - *** MAILBOX BYTE *** Switch code → 80188 (86 refs!)]
	jp send_to_80188		;12d5	c3 16 01	. . .  ; → send_to_80188
handler_coin_insert:
	ld a,(0c068h)		;12d8	3a 68 c0	: h .  ; [ram_game_active - Game active flag (0=attract, nonzero=playing)]
	and a			;12db	a7		.
	jp nz,l1336h		;12dc	c2 36 13	. 6 .
	ld a,(0c069h)		;12df	3a 69 c0	: i .
	and a			;12e2	a7		.
	jp nz,l1336h		;12e3	c2 36 13	. 6 .
	ld a,(0c06ah)		;12e6	3a 6a c0	: j .  ; [ram_ball_in_play - Ball-in-play counter]
	and a			;12e9	a7		.
	ret z			;12ea	c8		.
	ld a,(0c0dbh)		;12eb	3a db c0	: . .  ; [ram_row0_switches - Matrix row 0 debounced switch state]
	bit 7,a			;12ee	cb 7f		. .
	jp z,l1307h		;12f0	ca 07 13	. . .
	ld a,(0c063h)		;12f3	3a 63 c0	: c .  ; [ram_coin_counter_2 - Coin/credit counter 2]
	and a			;12f6	a7		.
	jp nz,l1307h		;12f7	c2 07 13	. . .
	ld a,(0c00ah)		;12fa	3a 0a c0	: . .
	and a			;12fd	a7		.
	jp nz,handler_game_start		;12fe	c2 11 13	. . .  ; → handler_game_start
	call sub_05edh		;1301	cd ed 05	. . .
	jp handler_game_start		;1304	c3 11 13	. . .  ; → handler_game_start
;  XREF: 2 refs from 0x12F0, 0x12F7
l1307h:
	ld a,(0c00dh)		;1307	3a 0d c0	: . .  ; [ram_sol_timer_1 - Solenoid 1 remaining timer]
	and a			;130a	a7		.
	jp nz,handler_game_start		;130b	c2 11 13	. . .  ; → handler_game_start
	call sol2_activate		;130e	cd 30 06	. 0 .

; ─────────────────────────────────────────────────────────────────────────────
; handler_game_start (0x1311)
; Handler: Game start sequence
; XREF: 3 references from 0x12FE, 0x1304, 0x130B
; ─────────────────────────────────────────────────────────────────────────────
handler_game_start:
	ld a,(0c05bh)		;1311	3a 5b c0	: [ .
	and a			;1314	a7		.
	ret z			;1315	c8		.
	ld a,(0c0dch)		;1316	3a dc c0	: . .  ; [ram_row1_switches - Matrix row 1 debounced switch state]
	bit 2,a			;1319	cb 57		. W
	jp z,l132dh		;131b	ca 2d 13	. - .
	ld a,(0c064h)		;131e	3a 64 c0	: d .
	and a			;1321	a7		.
	jp nz,l132dh		;1322	c2 2d 13	. - .
	ld a,(0c00bh)		;1325	3a 0b c0	: . .
	and a			;1328	a7		.
	call z,sol3_activate	;1329	cc 7f 06	. . .
	ret			;132c	c9		.
;  XREF: 2 refs from 0x131B, 0x1322
l132dh:
	ld a,(0c00eh)		;132d	3a 0e c0	: . .
	and a			;1330	a7		.
	ret nz			;1331	c0		.
	call sol4_activate		;1332	cd a5 06	. . .
	ret			;1335	c9		.
;  XREF: 2 refs from 0x12DC, 0x12E3
l1336h:
	ld a,(0c06eh)		;1336	3a 6e c0	: n .
	and a			;1339	a7		.
	ret nz			;133a	c0		.
	ld a,00ah		;133b	3e 0a		> .
	ld (0c06eh),a		;133d	32 6e c0	2 n .
	ld a,042h		;1340	3e 42		> B
	ld (0c0fch),a		;1342	32 fc c0	2 . .  ; [ram_switch_mailbox - *** MAILBOX BYTE *** Switch code → 80188 (86 refs!)]
	jp send_to_80188		;1345	c3 16 01	. . .  ; → send_to_80188

; ─────────────────────────────────────────────────────────────────────────────
; handler_ball_launch (0x1348)
; Handler: Ball launch control
; XREF: 5 references from 0x31BA, 0x32D2, 0x32DA, 0x32E2, 0x32EA
; ─────────────────────────────────────────────────────────────────────────────
handler_ball_launch:
	ret			;1348	c9		.
	ld a,(0c047h)		;1349	3a 47 c0	: G .
	and a			;134c	a7		.
	jp z,l1355h		;134d	ca 55 13	. U .
	dec a			;1350	3d		=
	ld (0c047h),a		;1351	32 47 c0	2 G .
	ret			;1354	c9		.
l1355h:
	ld a,032h		;1355	3e 32		> 2
	ld (0c047h),a		;1357	32 47 c0	2 G .
	call scan_state_entry		;135a	cd 62 2e	. b .
	ret			;135d	c9		.
game_state_update:
	ld hl,l000ah		;135e	21 0a 00	! . .
	ld (0c04fh),hl		;1361	22 4f c0	" O .  ; [ram_timer_aux - Auxiliary timer counter]
	ld a,0ffh		;1364	3e ff		> .
	ld (0c051h),a		;1366	32 51 c0	2 Q .  ; [ram_game_timer - Game timer (ball time / bonus countdown)]
l1369h:
	ld a,(0c051h)		;1369	3a 51 c0	: Q .  ; [ram_game_timer - Game timer (ball time / bonus countdown)]
	and a			;136c	a7		.
	jp nz,l1369h		;136d	c2 69 13	. i .
	ret			;1370	c9		.
l1371h:
	ld a,080h		;1371	3e 80		> .
	call sub_33a5h		;1373	cd a5 33	. . 3
	ld a,0ffh		;1376	3e ff		> .
	ld (0c0fbh),a		;1378	32 fb c0	2 . .  ; [ram_cmd_done_flag - Command completion flag]
	jp send_to_80188		;137b	c3 16 01	. . .  ; → send_to_80188
l137eh:
	ld a,040h		;137e	3e 40		> @
	call sub_33a5h		;1380	cd a5 33	. . 3
	ld a,0ffh		;1383	3e ff		> .
	ld (0c0fbh),a		;1385	32 fb c0	2 . .  ; [ram_cmd_done_flag - Command completion flag]
	jp send_to_80188		;1388	c3 16 01	. . .  ; → send_to_80188
l138bh:
	ld a,020h		;138b	3e 20		>  
	call sub_33a5h		;138d	cd a5 33	. . 3
	ld a,0ffh		;1390	3e ff		> .
	ld (0c0fbh),a		;1392	32 fb c0	2 . .  ; [ram_cmd_done_flag - Command completion flag]
	jp send_to_80188		;1395	c3 16 01	. . .  ; → send_to_80188
l1398h:
	ld a,020h		;1398	3e 20		>  
	call sub_3394h		;139a	cd 94 33	. . 3
	ld a,0ffh		;139d	3e ff		> .
	ld (0c0fbh),a		;139f	32 fb c0	2 . .  ; [ram_cmd_done_flag - Command completion flag]
	jp send_to_80188		;13a2	c3 16 01	. . .  ; → send_to_80188
l13a5h:
	ld a,010h		;13a5	3e 10		> .
	call sub_3394h		;13a7	cd 94 33	. . 3
	ld a,0ffh		;13aa	3e ff		> .
	ld (0c0fbh),a		;13ac	32 fb c0	2 . .  ; [ram_cmd_done_flag - Command completion flag]
	jp send_to_80188		;13af	c3 16 01	. . .  ; → send_to_80188
l13b2h:
	ld a,001h		;13b2	3e 01		> .
	call sub_33b6h		;13b4	cd b6 33	. . 3
	ld a,0ffh		;13b7	3e ff		> .
	ld (0c0fbh),a		;13b9	32 fb c0	2 . .  ; [ram_cmd_done_flag - Command completion flag]
	jp send_to_80188		;13bc	c3 16 01	. . .  ; → send_to_80188
l13bfh:
	ld a,008h		;13bf	3e 08		> .
	call sub_33e9h		;13c1	cd e9 33	. . 3
	ld a,0ffh		;13c4	3e ff		> .
	ld (0c0fbh),a		;13c6	32 fb c0	2 . .  ; [ram_cmd_done_flag - Command completion flag]
	jp send_to_80188		;13c9	c3 16 01	. . .  ; → send_to_80188
l13cch:
	ld a,004h		;13cc	3e 04		> .
	call sub_33e9h		;13ce	cd e9 33	. . 3
	ld a,0ffh		;13d1	3e ff		> .
	ld (0c0fbh),a		;13d3	32 fb c0	2 . .  ; [ram_cmd_done_flag - Command completion flag]
	jp send_to_80188		;13d6	c3 16 01	. . .  ; → send_to_80188
l13d9h:
	ld a,002h		;13d9	3e 02		> .
	call sub_33e9h		;13db	cd e9 33	. . 3
	ld a,0ffh		;13de	3e ff		> .
	ld (0c0fbh),a		;13e0	32 fb c0	2 . .  ; [ram_cmd_done_flag - Command completion flag]
	jp send_to_80188		;13e3	c3 16 01	. . .  ; → send_to_80188
l13e6h:
	ld a,020h		;13e6	3e 20		>  
	call sub_33d8h		;13e8	cd d8 33	. . 3
	call sub_377fh		;13eb	cd 7f 37	. . 7
	ld a,0ffh		;13ee	3e ff		> .
	ld (0c0fbh),a		;13f0	32 fb c0	2 . .  ; [ram_cmd_done_flag - Command completion flag]
	jp send_to_80188		;13f3	c3 16 01	. . .  ; → send_to_80188
l13f6h:
	ld a,001h		;13f6	3e 01		> .
	call sub_33a5h		;13f8	cd a5 33	. . 3
	ld a,(0c05ah)		;13fb	3a 5a c0	: Z .  ; [ram_irq_counter - IRQ service call counter]
	and a			;13fe	a7		.
	jp nz,l140ah		;13ff	c2 0a 14	. . .
	ld a,0ffh		;1402	3e ff		> .
	ld (0c0fbh),a		;1404	32 fb c0	2 . .  ; [ram_cmd_done_flag - Command completion flag]
	jp send_to_80188		;1407	c3 16 01	. . .  ; → send_to_80188
l140ah:
	xor a			;140a	af		.
	ld (0c05ah),a		;140b	32 5a c0	2 Z .  ; [ram_irq_counter - IRQ service call counter]
	ld (0c05bh),a		;140e	32 5b c0	2 [ .
l1411h:
	call sub_2e83h		;1411	cd 83 2e	. . .
	call sub_32f9h		;1414	cd f9 32	. . 2
	bit 0,a			;1417	cb 47		. G
	jp z,l1411h		;1419	ca 11 14	. . .
	ld hl,l005ah		;141c	21 5a 00	! Z .
	ld (0c04ch),hl		;141f	22 4c c0	" L .  ; [ram_sw_queue_wptr - Switch event queue write pointer]
	ld a,0ffh		;1422	3e ff		> .
	ld (0c04eh),a		;1424	32 4e c0	2 N .  ; [ram_timer_flag - Main timer flag (controls game timing)]
	call sub_27e6h		;1427	cd e6 27	. . '
	call sol3_activate		;142a	cd 7f 06	. . .
	call sub_2949h		;142d	cd 49 29	. I )
	call sol3_deactivate		;1430	cd c2 06	. . .
	ld a,0ffh		;1433	3e ff		> .
	ld (0c05bh),a		;1435	32 5b c0	2 [ .
	ld a,0ffh		;1438	3e ff		> .
	ld (0c0fbh),a		;143a	32 fb c0	2 . .  ; [ram_cmd_done_flag - Command completion flag]
	jp send_to_80188		;143d	c3 16 01	. . .  ; → send_to_80188
l1440h:
	ld a,040h		;1440	3e 40		> @
	call sub_33b6h		;1442	cd b6 33	. . 3
	ld a,0ffh		;1445	3e ff		> .
	ld (0c0fbh),a		;1447	32 fb c0	2 . .  ; [ram_cmd_done_flag - Command completion flag]
	jp send_to_80188		;144a	c3 16 01	. . .  ; → send_to_80188
l144dh:
	ld a,002h		;144d	3e 02		> .
	call sub_33b6h		;144f	cd b6 33	. . 3
	ld a,0ffh		;1452	3e ff		> .
	ld (0c0fbh),a		;1454	32 fb c0	2 . .  ; [ram_cmd_done_flag - Command completion flag]
	jp send_to_80188		;1457	c3 16 01	. . .  ; → send_to_80188
l145ah:
	ld a,004h		;145a	3e 04		> .
	call sub_33b6h		;145c	cd b6 33	. . 3
	ld a,0ffh		;145f	3e ff		> .
	ld (0c0fbh),a		;1461	32 fb c0	2 . .  ; [ram_cmd_done_flag - Command completion flag]
	jp send_to_80188		;1464	c3 16 01	. . .  ; → send_to_80188
l1467h:
	ld a,008h		;1467	3e 08		> .
	call sub_33b6h		;1469	cd b6 33	. . 3
	ld a,0ffh		;146c	3e ff		> .
	ld (0c0fbh),a		;146e	32 fb c0	2 . .  ; [ram_cmd_done_flag - Command completion flag]
	jp send_to_80188		;1471	c3 16 01	. . .  ; → send_to_80188
l1474h:
	ld a,010h		;1474	3e 10		> .
	call sub_33b6h		;1476	cd b6 33	. . 3
	ld a,0ffh		;1479	3e ff		> .
	ld (0c0fbh),a		;147b	32 fb c0	2 . .  ; [ram_cmd_done_flag - Command completion flag]
	jp send_to_80188		;147e	c3 16 01	. . .  ; → send_to_80188
l1481h:
	ld a,020h		;1481	3e 20		>  
	call sub_33b6h		;1483	cd b6 33	. . 3
	ld a,0ffh		;1486	3e ff		> .
	ld (0c0fbh),a		;1488	32 fb c0	2 . .  ; [ram_cmd_done_flag - Command completion flag]
	jp send_to_80188		;148b	c3 16 01	. . .  ; → send_to_80188
l148eh:
	ld a,004h		;148e	3e 04		> .
	call sub_33c7h		;1490	cd c7 33	. . 3
	ld a,0ffh		;1493	3e ff		> .
	ld (0c0fbh),a		;1495	32 fb c0	2 . .  ; [ram_cmd_done_flag - Command completion flag]
	jp send_to_80188		;1498	c3 16 01	. . .  ; → send_to_80188
l149bh:
	ld a,010h		;149b	3e 10		> .
	call sub_33d8h		;149d	cd d8 33	. . 3
	ld a,0ffh		;14a0	3e ff		> .
	ld (0c0fbh),a		;14a2	32 fb c0	2 . .  ; [ram_cmd_done_flag - Command completion flag]
	jp send_to_80188		;14a5	c3 16 01	. . .  ; → send_to_80188
l14a8h:
	ld a,080h		;14a8	3e 80		> .
	call sub_33c7h		;14aa	cd c7 33	. . 3
	ld a,0ffh		;14ad	3e ff		> .
	ld (0c0fbh),a		;14af	32 fb c0	2 . .  ; [ram_cmd_done_flag - Command completion flag]
	jp send_to_80188		;14b2	c3 16 01	. . .  ; → send_to_80188
l14b5h:
	ld a,040h		;14b5	3e 40		> @
	call sub_33d8h		;14b7	cd d8 33	. . 3
	ld a,(0c05dh)		;14ba	3a 5d c0	: ] .
	and a			;14bd	a7		.
	jp nz,l14c9h		;14be	c2 c9 14	. . .
	ld a,0ffh		;14c1	3e ff		> .
	ld (0c0fbh),a		;14c3	32 fb c0	2 . .  ; [ram_cmd_done_flag - Command completion flag]
	jp send_to_80188		;14c6	c3 16 01	. . .  ; → send_to_80188
l14c9h:
	call sub_08ffh		;14c9	cd ff 08	. . .
	ld a,0ffh		;14cc	3e ff		> .
	ld (0c0fbh),a		;14ce	32 fb c0	2 . .  ; [ram_cmd_done_flag - Command completion flag]
	jp send_to_80188		;14d1	c3 16 01	. . .  ; → send_to_80188
	ld a,002h		;14d4	3e 02		> .
	call sub_33a5h		;14d6	cd a5 33	. . 3
	ld a,0ffh		;14d9	3e ff		> .
	ld (0c0fbh),a		;14db	32 fb c0	2 . .  ; [ram_cmd_done_flag - Command completion flag]
	jp send_to_80188		;14de	c3 16 01	. . .  ; → send_to_80188
l14e1h:
	ld a,008h		;14e1	3e 08		> .
	call sub_33d8h		;14e3	cd d8 33	. . 3
	ld a,0ffh		;14e6	3e ff		> .
	ld (0c0fbh),a		;14e8	32 fb c0	2 . .  ; [ram_cmd_done_flag - Command completion flag]
	jp send_to_80188		;14eb	c3 16 01	. . .  ; → send_to_80188
l14eeh:
	ld a,001h		;14ee	3e 01		> .
	call sub_33e9h		;14f0	cd e9 33	. . 3
	ld a,(0c068h)		;14f3	3a 68 c0	: h .  ; [ram_game_active - Game active flag (0=attract, nonzero=playing)]
	and a			;14f6	a7		.
	jp nz,l14fdh		;14f7	c2 fd 14	. . .
	call sub_3713h		;14fa	cd 13 37	. . 7
l14fdh:
	ld a,0ffh		;14fd	3e ff		> .
	ld (0c0fbh),a		;14ff	32 fb c0	2 . .  ; [ram_cmd_done_flag - Command completion flag]
	jp send_to_80188		;1502	c3 16 01	. . .  ; → send_to_80188
l1505h:
	ld a,002h		;1505	3e 02		> .
	call sub_33c7h		;1507	cd c7 33	. . 3
	ld a,(0c068h)		;150a	3a 68 c0	: h .  ; [ram_game_active - Game active flag (0=attract, nonzero=playing)]
	and a			;150d	a7		.
	jp nz,l1521h		;150e	c2 21 15	. ! .
	ld a,(0c00fh)		;1511	3a 0f c0	: . .
	and a			;1514	a7		.
	ret nz			;1515	c0		.
	ld a,(0c055h)		;1516	3a 55 c0	: U .  ; [ram_debounce_state - Debounce state variable]
	and a			;1519	a7		.
	ret z			;151a	c8		.
	call sol5_activate		;151b	cd db 06	. . .
	call delay_routine		;151e	cd f8 36	. . 6
l1521h:
	ld a,0ffh		;1521	3e ff		> .
	ld (0c0fbh),a		;1523	32 fb c0	2 . .  ; [ram_cmd_done_flag - Command completion flag]
	jp send_to_80188		;1526	c3 16 01	. . .  ; → send_to_80188
l1529h:
	ld a,010h		;1529	3e 10		> .
	call sub_33c7h		;152b	cd c7 33	. . 3
	ld a,(0c068h)		;152e	3a 68 c0	: h .  ; [ram_game_active - Game active flag (0=attract, nonzero=playing)]
	and a			;1531	a7		.
	jp nz,l1545h		;1532	c2 45 15	. E .
	ld a,(0c010h)		;1535	3a 10 c0	: . .
	and a			;1538	a7		.
	ret nz			;1539	c0		.
	ld a,(0c055h)		;153a	3a 55 c0	: U .  ; [ram_debounce_state - Debounce state variable]
	and a			;153d	a7		.
	ret z			;153e	c8		.
	call sol6_activate		;153f	cd f8 06	. . .
	call delay_routine		;1542	cd f8 36	. . 6
l1545h:
	ld a,0ffh		;1545	3e ff		> .
	ld (0c0fbh),a		;1547	32 fb c0	2 . .  ; [ram_cmd_done_flag - Command completion flag]
	jp send_to_80188		;154a	c3 16 01	. . .  ; → send_to_80188
l154dh:
	ld a,008h		;154d	3e 08		> .
	call sub_33c7h		;154f	cd c7 33	. . 3
	ld a,(0c068h)		;1552	3a 68 c0	: h .  ; [ram_game_active - Game active flag (0=attract, nonzero=playing)]
	and a			;1555	a7		.
	jp nz,l1569h		;1556	c2 69 15	. i .
	ld a,(0c011h)		;1559	3a 11 c0	: . .
	and a			;155c	a7		.
	ret nz			;155d	c0		.
	ld a,(0c055h)		;155e	3a 55 c0	: U .  ; [ram_debounce_state - Debounce state variable]
	and a			;1561	a7		.
	ret z			;1562	c8		.
	call sol7_activate		;1563	cd 15 07	. . .
	call delay_routine		;1566	cd f8 36	. . 6
l1569h:
	ld a,0ffh		;1569	3e ff		> .
	ld (0c0fbh),a		;156b	32 fb c0	2 . .  ; [ram_cmd_done_flag - Command completion flag]
	jp send_to_80188		;156e	c3 16 01	. . .  ; → send_to_80188
l1571h:
	ld a,040h		;1571	3e 40		> @
	call sub_33c7h		;1573	cd c7 33	. . 3
	ld a,(0c068h)		;1576	3a 68 c0	: h .  ; [ram_game_active - Game active flag (0=attract, nonzero=playing)]
	and a			;1579	a7		.
	jp nz,l158dh		;157a	c2 8d 15	. . .
	ld a,(0c012h)		;157d	3a 12 c0	: . .
	and a			;1580	a7		.
	ret nz			;1581	c0		.
	ld a,(0c055h)		;1582	3a 55 c0	: U .  ; [ram_debounce_state - Debounce state variable]
	and a			;1585	a7		.
	ret z			;1586	c8		.
	call sol8_activate		;1587	cd 32 07	. 2 .
	call delay_routine		;158a	cd f8 36	. . 6
l158dh:
	ld a,0ffh		;158d	3e ff		> .
	ld (0c0fbh),a		;158f	32 fb c0	2 . .  ; [ram_cmd_done_flag - Command completion flag]
	jp send_to_80188		;1592	c3 16 01	. . .  ; → send_to_80188
l1595h:
	ld a,020h		;1595	3e 20		>  
	call sub_33c7h		;1597	cd c7 33	. . 3
	ld a,(0c068h)		;159a	3a 68 c0	: h .  ; [ram_game_active - Game active flag (0=attract, nonzero=playing)]
	and a			;159d	a7		.
	jp nz,l15b1h		;159e	c2 b1 15	. . .
	ld a,(0c013h)		;15a1	3a 13 c0	: . .
	and a			;15a4	a7		.
	ret nz			;15a5	c0		.
	ld a,(0c055h)		;15a6	3a 55 c0	: U .  ; [ram_debounce_state - Debounce state variable]
	and a			;15a9	a7		.
	ret z			;15aa	c8		.
	call sol9_activate		;15ab	cd 4f 07	. O .
	call delay_routine		;15ae	cd f8 36	. . 6
l15b1h:
	ld a,0ffh		;15b1	3e ff		> .
	ld (0c0fbh),a		;15b3	32 fb c0	2 . .  ; [ram_cmd_done_flag - Command completion flag]
	jp send_to_80188		;15b6	c3 16 01	. . .  ; → send_to_80188
l15b9h:
	ld a,(0c051h)		;15b9	3a 51 c0	: Q .  ; [ram_game_timer - Game timer (ball time / bonus countdown)]
	and a			;15bc	a7		.
	ret nz			;15bd	c0		.
	ld hl,l012ch		;15be	21 2c 01	! , .
	ld (0c04fh),hl		;15c1	22 4f c0	" O .  ; [ram_timer_aux - Auxiliary timer counter]
	ld a,0ffh		;15c4	3e ff		> .
	ld (0c051h),a		;15c6	32 51 c0	2 Q .  ; [ram_game_timer - Game timer (ball time / bonus countdown)]
	jp send_to_80188		;15c9	c3 16 01	. . .  ; → send_to_80188
l15cch:
	ld a,080h		;15cc	3e 80		> .
	call sub_33b6h		;15ce	cd b6 33	. . 3
	call sub_3764h		;15d1	cd 64 37	. d 7
	jp send_to_80188		;15d4	c3 16 01	. . .  ; → send_to_80188
l15d7h:
	ld a,010h		;15d7	3e 10		> .
	call sub_33a5h		;15d9	cd a5 33	. . 3
	call sol11_activate		;15dc	cd 89 07	. . .
	ld a,0ffh		;15df	3e ff		> .
	ld (0c0fbh),a		;15e1	32 fb c0	2 . .  ; [ram_cmd_done_flag - Command completion flag]
	jp send_to_80188		;15e4	c3 16 01	. . .  ; → send_to_80188
l15e7h:
	ld a,008h		;15e7	3e 08		> .
	call sub_33a5h		;15e9	cd a5 33	. . 3
	call sol12_activate		;15ec	cd a6 07	. . .
	ld a,0ffh		;15ef	3e ff		> .
	ld (0c0fbh),a		;15f1	32 fb c0	2 . .  ; [ram_cmd_done_flag - Command completion flag]
	jp send_to_80188		;15f4	c3 16 01	. . .  ; → send_to_80188
l15f7h:
	ld a,(0c068h)		;15f7	3a 68 c0	: h .  ; [ram_game_active - Game active flag (0=attract, nonzero=playing)]
	and a			;15fa	a7		.
	ret z			;15fb	c8		.
	ld a,040h		;15fc	3e 40		> @
	call sub_3394h		;15fe	cd 94 33	. . 3
	jp send_to_80188		;1601	c3 16 01	. . .  ; → send_to_80188
l1604h:
	ld a,(0c068h)		;1604	3a 68 c0	: h .  ; [ram_game_active - Game active flag (0=attract, nonzero=playing)]
	and a			;1607	a7		.
	ret z			;1608	c8		.
	ld a,080h		;1609	3e 80		> .
	call sub_3394h		;160b	cd 94 33	. . 3
	jp send_to_80188		;160e	c3 16 01	. . .  ; → send_to_80188
l1611h:
	ld a,(0c068h)		;1611	3a 68 c0	: h .  ; [ram_game_active - Game active flag (0=attract, nonzero=playing)]
	and a			;1614	a7		.
	ret z			;1615	c8		.
	ld a,004h		;1616	3e 04		> .
	call sub_33a5h		;1618	cd a5 33	. . 3
	jp send_to_80188		;161b	c3 16 01	. . .  ; → send_to_80188
l161eh:
	ld a,(0c068h)		;161e	3a 68 c0	: h .  ; [ram_game_active - Game active flag (0=attract, nonzero=playing)]
	and a			;1621	a7		.
	jp nz,l1642h		;1622	c2 42 16	. B .
	ld a,(0c054h)		;1625	3a 54 c0	: T .
	and a			;1628	a7		.
	ret z			;1629	c8		.
	ld a,(0c04bh)		;162a	3a 4b c0	: K .
	and a			;162d	a7		.
	ret nz			;162e	c0		.
	ld hl,l00c8h		;162f	21 c8 00	! . .
	ld (0c049h),hl		;1632	22 49 c0	" I .
	ld a,0ffh		;1635	3e ff		> .
	ld (0c04bh),a		;1637	32 4b c0	2 K .
	ld a,043h		;163a	3e 43		> C
	ld (0c0fch),a		;163c	32 fc c0	2 . .  ; [ram_switch_mailbox - *** MAILBOX BYTE *** Switch code → 80188 (86 refs!)]
	jp send_to_80188		;163f	c3 16 01	. . .  ; → send_to_80188
l1642h:
	ld a,001h		;1642	3e 01		> .
	call sub_3394h		;1644	cd 94 33	. . 3
	jp send_to_80188		;1647	c3 16 01	. . .  ; → send_to_80188
l164ah:
	ld a,002h		;164a	3e 02		> .
	call sub_3394h		;164c	cd 94 33	. . 3
	ld a,(0c068h)		;164f	3a 68 c0	: h .  ; [ram_game_active - Game active flag (0=attract, nonzero=playing)]
	and a			;1652	a7		.
	jp nz,l1657h		;1653	c2 57 16	. W .
	ret			;1656	c9		.
l1657h:
	jp send_to_80188		;1657	c3 16 01	. . .  ; → send_to_80188
l165ah:
	ld a,004h		;165a	3e 04		> .
	call sub_3394h		;165c	cd 94 33	. . 3
	ld a,(0c068h)		;165f	3a 68 c0	: h .  ; [ram_game_active - Game active flag (0=attract, nonzero=playing)]
	and a			;1662	a7		.
	jp nz,l1667h		;1663	c2 67 16	. g .
	ret			;1666	c9		.
l1667h:
	jp send_to_80188		;1667	c3 16 01	. . .  ; → send_to_80188
l166ah:
	ld a,008h		;166a	3e 08		> .
	call sub_3394h		;166c	cd 94 33	. . 3
	ld a,(0c068h)		;166f	3a 68 c0	: h .  ; [ram_game_active - Game active flag (0=attract, nonzero=playing)]
	and a			;1672	a7		.
	ret z			;1673	c8		.
	jp send_to_80188		;1674	c3 16 01	. . .  ; → send_to_80188
l1677h:
	ld a,080h		;1677	3e 80		> .
	call sub_33d8h		;1679	cd d8 33	. . 3
	ld a,(0c068h)		;167c	3a 68 c0	: h .  ; [ram_game_active - Game active flag (0=attract, nonzero=playing)]
	and a			;167f	a7		.
	jp nz,l169bh		;1680	c2 9b 16	. . .
	ld a,(0c05ch)		;1683	3a 5c c0	: \ .
	and a			;1686	a7		.
	jp nz,l1695h		;1687	c2 95 16	. . .
	call sub_3749h		;168a	cd 49 37	. I 7
	ld a,0ffh		;168d	3e ff		> .
	ld (0c0fbh),a		;168f	32 fb c0	2 . .  ; [ram_cmd_done_flag - Command completion flag]
	jp send_to_80188		;1692	c3 16 01	. . .  ; → send_to_80188
l1695h:
	call sub_3749h		;1695	cd 49 37	. I 7
	call sub_0975h		;1698	cd 75 09	. u .
l169bh:
	jp send_to_80188		;169b	c3 16 01	. . .  ; → send_to_80188
l169eh:
	ld a,004h		;169e	3e 04		> .
	call sub_33d8h		;16a0	cd d8 33	. . 3
	ld a,(0c068h)		;16a3	3a 68 c0	: h .  ; [ram_game_active - Game active flag (0=attract, nonzero=playing)]
	and a			;16a6	a7		.
	jp nz,l16b2h		;16a7	c2 b2 16	. . .
	ld a,044h		;16aa	3e 44		> D
	ld (0c0fch),a		;16ac	32 fc c0	2 . .  ; [ram_switch_mailbox - *** MAILBOX BYTE *** Switch code → 80188 (86 refs!)]
	jp send_to_80188		;16af	c3 16 01	. . .  ; → send_to_80188
l16b2h:
	jp send_to_80188		;16b2	c3 16 01	. . .  ; → send_to_80188
l16b5h:
	ld a,002h		;16b5	3e 02		> .
	call sub_33d8h		;16b7	cd d8 33	. . 3
	ld a,(0c068h)		;16ba	3a 68 c0	: h .  ; [ram_game_active - Game active flag (0=attract, nonzero=playing)]
	and a			;16bd	a7		.
	jp nz,l16c2h		;16be	c2 c2 16	. . .
	ret			;16c1	c9		.
l16c2h:
	jp send_to_80188		;16c2	c3 16 01	. . .  ; → send_to_80188
l16c5h:
	ld a,001h		;16c5	3e 01		> .
	call sub_33d8h		;16c7	cd d8 33	. . 3
	ld a,(0c068h)		;16ca	3a 68 c0	: h .  ; [ram_game_active - Game active flag (0=attract, nonzero=playing)]
	and a			;16cd	a7		.
	jp nz,l16d2h		;16ce	c2 d2 16	. . .
	ret			;16d1	c9		.
l16d2h:
	jp send_to_80188		;16d2	c3 16 01	. . .  ; → send_to_80188
switch_event_dispatch:

; ─────────────────────────────────────────────────────────────────────────────
; switch_event_dispatch (0x16D5)
; Switch event dispatcher: queue → table → handler call
; ─────────────────────────────────────────────────────────────────────────────
switch_event_dispatch:
	ld hl,(0c072h)		;16d5	2a 72 c0	* r .  ; [ram_sw_queue_rptr - Switch event queue read pointer]
	ld a,(hl)		;16d8	7e		~
	and a			;16d9	a7		.
	ret z			;16da	c8		.
	ld (hl),000h		;16db	36 00		6 .
	inc hl			;16dd	23		#
	ld (0c072h),hl		;16de	22 72 c0	" r .  ; [ram_sw_queue_rptr - Switch event queue read pointer]
	ld hl,switch_dispatch_table		;16e1	21 00 20	! .  
	ld d,000h		;16e4	16 00		. .
	ld e,a			;16e6	5f		_
	sla e			;16e7	cb 23		. #
	jp nc,l16eeh		;16e9	d2 ee 16	. . .
	ld d,001h		;16ec	16 01		. .
l16eeh:
	add hl,de		;16ee	19		.
	ld e,(hl)		;16ef	5e		^
	inc hl			;16f0	23		#
	ld d,(hl)		;16f1	56		V
	ex de,hl		;16f2	eb		.
	jp (hl)			;16f3	e9		.
	rst 38h			;16f4	ff		.
	rst 38h			;16f5	ff		.
	rst 38h			;16f6	ff		.
	rst 38h			;16f7	ff		.
	rst 38h			;16f8	ff		.
	rst 38h			;16f9	ff		.
	rst 38h			;16fa	ff		.
	rst 38h			;16fb	ff		.
	rst 38h			;16fc	ff		.
	rst 38h			;16fd	ff		.
	rst 38h			;16fe	ff		.
	rst 38h			;16ff	ff		.
	rst 38h			;1700	ff		.
	rst 38h			;1701	ff		.
	rst 38h			;1702	ff		.
	rst 38h			;1703	ff		.
	rst 38h			;1704	ff		.
	rst 38h			;1705	ff		.
	rst 38h			;1706	ff		.
	rst 38h			;1707	ff		.
	rst 38h			;1708	ff		.
	rst 38h			;1709	ff		.
	rst 38h			;170a	ff		.
	rst 38h			;170b	ff		.
	rst 38h			;170c	ff		.
	rst 38h			;170d	ff		.
	rst 38h			;170e	ff		.
	rst 38h			;170f	ff		.
	rst 38h			;1710	ff		.
	rst 38h			;1711	ff		.
	rst 38h			;1712	ff		.
	rst 38h			;1713	ff		.
	rst 38h			;1714	ff		.
	rst 38h			;1715	ff		.
	rst 38h			;1716	ff		.
	rst 38h			;1717	ff		.
	rst 38h			;1718	ff		.
	rst 38h			;1719	ff		.
	rst 38h			;171a	ff		.
	rst 38h			;171b	ff		.
	rst 38h			;171c	ff		.
	rst 38h			;171d	ff		.
	rst 38h			;171e	ff		.
	rst 38h			;171f	ff		.
	rst 38h			;1720	ff		.
	rst 38h			;1721	ff		.
	rst 38h			;1722	ff		.
	rst 38h			;1723	ff		.
	rst 38h			;1724	ff		.
	rst 38h			;1725	ff		.
	rst 38h			;1726	ff		.
	rst 38h			;1727	ff		.
	rst 38h			;1728	ff		.
	rst 38h			;1729	ff		.
	rst 38h			;172a	ff		.
	rst 38h			;172b	ff		.
	rst 38h			;172c	ff		.
	rst 38h			;172d	ff		.
	rst 38h			;172e	ff		.
	rst 38h			;172f	ff		.
	rst 38h			;1730	ff		.
	rst 38h			;1731	ff		.
	rst 38h			;1732	ff		.
	rst 38h			;1733	ff		.
	rst 38h			;1734	ff		.
	rst 38h			;1735	ff		.
	rst 38h			;1736	ff		.
	rst 38h			;1737	ff		.
	rst 38h			;1738	ff		.
	rst 38h			;1739	ff		.
	rst 38h			;173a	ff		.
	rst 38h			;173b	ff		.
	rst 38h			;173c	ff		.
	rst 38h			;173d	ff		.
	rst 38h			;173e	ff		.
	rst 38h			;173f	ff		.
	rst 38h			;1740	ff		.
	rst 38h			;1741	ff		.
	rst 38h			;1742	ff		.
	rst 38h			;1743	ff		.
	rst 38h			;1744	ff		.
	rst 38h			;1745	ff		.
	rst 38h			;1746	ff		.
	rst 38h			;1747	ff		.
	rst 38h			;1748	ff		.
	rst 38h			;1749	ff		.
	rst 38h			;174a	ff		.
	rst 38h			;174b	ff		.
	rst 38h			;174c	ff		.
	rst 38h			;174d	ff		.
	rst 38h			;174e	ff		.
	rst 38h			;174f	ff		.
	rst 38h			;1750	ff		.
	rst 38h			;1751	ff		.
	rst 38h			;1752	ff		.
	rst 38h			;1753	ff		.
	rst 38h			;1754	ff		.
	rst 38h			;1755	ff		.
	rst 38h			;1756	ff		.
	rst 38h			;1757	ff		.
	rst 38h			;1758	ff		.
	rst 38h			;1759	ff		.
	rst 38h			;175a	ff		.
	rst 38h			;175b	ff		.
	rst 38h			;175c	ff		.
	rst 38h			;175d	ff		.
	rst 38h			;175e	ff		.
	rst 38h			;175f	ff		.
	rst 38h			;1760	ff		.
	rst 38h			;1761	ff		.
	rst 38h			;1762	ff		.
	rst 38h			;1763	ff		.
	rst 38h			;1764	ff		.
	rst 38h			;1765	ff		.
	rst 38h			;1766	ff		.
	rst 38h			;1767	ff		.
	rst 38h			;1768	ff		.
	rst 38h			;1769	ff		.
	rst 38h			;176a	ff		.
	rst 38h			;176b	ff		.
	rst 38h			;176c	ff		.
	rst 38h			;176d	ff		.
	rst 38h			;176e	ff		.
	rst 38h			;176f	ff		.
	rst 38h			;1770	ff		.
	rst 38h			;1771	ff		.
	rst 38h			;1772	ff		.
	rst 38h			;1773	ff		.
	rst 38h			;1774	ff		.
	rst 38h			;1775	ff		.
	rst 38h			;1776	ff		.
	rst 38h			;1777	ff		.
	rst 38h			;1778	ff		.
	rst 38h			;1779	ff		.
	rst 38h			;177a	ff		.
	rst 38h			;177b	ff		.
	rst 38h			;177c	ff		.
	rst 38h			;177d	ff		.
	rst 38h			;177e	ff		.
	rst 38h			;177f	ff		.
	rst 38h			;1780	ff		.
	rst 38h			;1781	ff		.
	rst 38h			;1782	ff		.
	rst 38h			;1783	ff		.
	rst 38h			;1784	ff		.
	rst 38h			;1785	ff		.
	rst 38h			;1786	ff		.
	rst 38h			;1787	ff		.
	rst 38h			;1788	ff		.
	rst 38h			;1789	ff		.
	rst 38h			;178a	ff		.
	rst 38h			;178b	ff		.
	rst 38h			;178c	ff		.
	rst 38h			;178d	ff		.
	rst 38h			;178e	ff		.
	rst 38h			;178f	ff		.
	rst 38h			;1790	ff		.
	rst 38h			;1791	ff		.
	rst 38h			;1792	ff		.
	rst 38h			;1793	ff		.
	rst 38h			;1794	ff		.
	rst 38h			;1795	ff		.
	rst 38h			;1796	ff		.
	rst 38h			;1797	ff		.
	rst 38h			;1798	ff		.
	rst 38h			;1799	ff		.
	rst 38h			;179a	ff		.
	rst 38h			;179b	ff		.
	rst 38h			;179c	ff		.
	rst 38h			;179d	ff		.
	rst 38h			;179e	ff		.
	rst 38h			;179f	ff		.
	rst 38h			;17a0	ff		.
	rst 38h			;17a1	ff		.
	rst 38h			;17a2	ff		.
	rst 38h			;17a3	ff		.
	rst 38h			;17a4	ff		.
	rst 38h			;17a5	ff		.
	rst 38h			;17a6	ff		.
	rst 38h			;17a7	ff		.
	rst 38h			;17a8	ff		.
	rst 38h			;17a9	ff		.
	rst 38h			;17aa	ff		.
	rst 38h			;17ab	ff		.
	rst 38h			;17ac	ff		.
	rst 38h			;17ad	ff		.
	rst 38h			;17ae	ff		.
	rst 38h			;17af	ff		.
	rst 38h			;17b0	ff		.
	rst 38h			;17b1	ff		.
	rst 38h			;17b2	ff		.
	rst 38h			;17b3	ff		.
	rst 38h			;17b4	ff		.
	rst 38h			;17b5	ff		.
	rst 38h			;17b6	ff		.
	rst 38h			;17b7	ff		.
	rst 38h			;17b8	ff		.
	rst 38h			;17b9	ff		.
	rst 38h			;17ba	ff		.
	rst 38h			;17bb	ff		.
	rst 38h			;17bc	ff		.
	rst 38h			;17bd	ff		.
	rst 38h			;17be	ff		.
	rst 38h			;17bf	ff		.
	rst 38h			;17c0	ff		.
	rst 38h			;17c1	ff		.
	rst 38h			;17c2	ff		.
	rst 38h			;17c3	ff		.
	rst 38h			;17c4	ff		.
	rst 38h			;17c5	ff		.
	rst 38h			;17c6	ff		.
	rst 38h			;17c7	ff		.
	rst 38h			;17c8	ff		.
	rst 38h			;17c9	ff		.
	rst 38h			;17ca	ff		.
	rst 38h			;17cb	ff		.
	rst 38h			;17cc	ff		.
	rst 38h			;17cd	ff		.
	rst 38h			;17ce	ff		.
	rst 38h			;17cf	ff		.
	rst 38h			;17d0	ff		.
	rst 38h			;17d1	ff		.
	rst 38h			;17d2	ff		.
	rst 38h			;17d3	ff		.
	rst 38h			;17d4	ff		.
	rst 38h			;17d5	ff		.
	rst 38h			;17d6	ff		.
	rst 38h			;17d7	ff		.
	rst 38h			;17d8	ff		.
	rst 38h			;17d9	ff		.
	rst 38h			;17da	ff		.
	rst 38h			;17db	ff		.
	rst 38h			;17dc	ff		.
	rst 38h			;17dd	ff		.
	rst 38h			;17de	ff		.
	rst 38h			;17df	ff		.
	rst 38h			;17e0	ff		.
	rst 38h			;17e1	ff		.
	rst 38h			;17e2	ff		.
	rst 38h			;17e3	ff		.
	rst 38h			;17e4	ff		.
	rst 38h			;17e5	ff		.
	rst 38h			;17e6	ff		.
	rst 38h			;17e7	ff		.
	rst 38h			;17e8	ff		.
	rst 38h			;17e9	ff		.
	rst 38h			;17ea	ff		.
	rst 38h			;17eb	ff		.
	rst 38h			;17ec	ff		.
	rst 38h			;17ed	ff		.
	rst 38h			;17ee	ff		.
	rst 38h			;17ef	ff		.
	rst 38h			;17f0	ff		.
	rst 38h			;17f1	ff		.
	rst 38h			;17f2	ff		.
	rst 38h			;17f3	ff		.
	rst 38h			;17f4	ff		.
	rst 38h			;17f5	ff		.
	rst 38h			;17f6	ff		.
	rst 38h			;17f7	ff		.
	rst 38h			;17f8	ff		.
	rst 38h			;17f9	ff		.
	rst 38h			;17fa	ff		.
	rst 38h			;17fb	ff		.
	rst 38h			;17fc	ff		.
	rst 38h			;17fd	ff		.
	rst 38h			;17fe	ff		.
	rst 38h			;17ff	ff		.
l1800h:
	rst 38h			;1800	ff		.
	rst 38h			;1801	ff		.
	rst 38h			;1802	ff		.
	rst 38h			;1803	ff		.
	rst 38h			;1804	ff		.
	rst 38h			;1805	ff		.
	rst 38h			;1806	ff		.
	rst 38h			;1807	ff		.
	rst 38h			;1808	ff		.
	rst 38h			;1809	ff		.
	rst 38h			;180a	ff		.
	rst 38h			;180b	ff		.
	rst 38h			;180c	ff		.
	rst 38h			;180d	ff		.
	rst 38h			;180e	ff		.
	rst 38h			;180f	ff		.
	rst 38h			;1810	ff		.
	rst 38h			;1811	ff		.
	rst 38h			;1812	ff		.
	rst 38h			;1813	ff		.
	rst 38h			;1814	ff		.
	rst 38h			;1815	ff		.
	rst 38h			;1816	ff		.
	rst 38h			;1817	ff		.
	rst 38h			;1818	ff		.
	rst 38h			;1819	ff		.
	rst 38h			;181a	ff		.
	rst 38h			;181b	ff		.
	rst 38h			;181c	ff		.
	rst 38h			;181d	ff		.
	rst 38h			;181e	ff		.
	rst 38h			;181f	ff		.
	rst 38h			;1820	ff		.
	rst 38h			;1821	ff		.
	rst 38h			;1822	ff		.
	rst 38h			;1823	ff		.
	rst 38h			;1824	ff		.
	rst 38h			;1825	ff		.
	rst 38h			;1826	ff		.
	rst 38h			;1827	ff		.
	rst 38h			;1828	ff		.
	rst 38h			;1829	ff		.
	rst 38h			;182a	ff		.
	rst 38h			;182b	ff		.
	rst 38h			;182c	ff		.
	rst 38h			;182d	ff		.
	rst 38h			;182e	ff		.
	rst 38h			;182f	ff		.
	rst 38h			;1830	ff		.
	rst 38h			;1831	ff		.
	rst 38h			;1832	ff		.
	rst 38h			;1833	ff		.
	rst 38h			;1834	ff		.
	rst 38h			;1835	ff		.
	rst 38h			;1836	ff		.
	rst 38h			;1837	ff		.
	rst 38h			;1838	ff		.
	rst 38h			;1839	ff		.
	rst 38h			;183a	ff		.
	rst 38h			;183b	ff		.
	rst 38h			;183c	ff		.
	rst 38h			;183d	ff		.
	rst 38h			;183e	ff		.
	rst 38h			;183f	ff		.
	rst 38h			;1840	ff		.
	rst 38h			;1841	ff		.
	rst 38h			;1842	ff		.
	rst 38h			;1843	ff		.
	rst 38h			;1844	ff		.
	rst 38h			;1845	ff		.
	rst 38h			;1846	ff		.
	rst 38h			;1847	ff		.
	rst 38h			;1848	ff		.
	rst 38h			;1849	ff		.
	rst 38h			;184a	ff		.
	rst 38h			;184b	ff		.
	rst 38h			;184c	ff		.
	rst 38h			;184d	ff		.
	rst 38h			;184e	ff		.
	rst 38h			;184f	ff		.
	rst 38h			;1850	ff		.
	rst 38h			;1851	ff		.
	rst 38h			;1852	ff		.
	rst 38h			;1853	ff		.
	rst 38h			;1854	ff		.
	rst 38h			;1855	ff		.
	rst 38h			;1856	ff		.
	rst 38h			;1857	ff		.
	rst 38h			;1858	ff		.
	rst 38h			;1859	ff		.
	rst 38h			;185a	ff		.
	rst 38h			;185b	ff		.
	rst 38h			;185c	ff		.
	rst 38h			;185d	ff		.
	rst 38h			;185e	ff		.
	rst 38h			;185f	ff		.
	rst 38h			;1860	ff		.
	rst 38h			;1861	ff		.
	rst 38h			;1862	ff		.
	rst 38h			;1863	ff		.
	rst 38h			;1864	ff		.
	rst 38h			;1865	ff		.
	rst 38h			;1866	ff		.
	rst 38h			;1867	ff		.
	rst 38h			;1868	ff		.
	rst 38h			;1869	ff		.
	rst 38h			;186a	ff		.
	rst 38h			;186b	ff		.
	rst 38h			;186c	ff		.
	rst 38h			;186d	ff		.
	rst 38h			;186e	ff		.
	rst 38h			;186f	ff		.
	rst 38h			;1870	ff		.
	rst 38h			;1871	ff		.
	rst 38h			;1872	ff		.
	rst 38h			;1873	ff		.
	rst 38h			;1874	ff		.
	rst 38h			;1875	ff		.
	rst 38h			;1876	ff		.
	rst 38h			;1877	ff		.
	rst 38h			;1878	ff		.
	rst 38h			;1879	ff		.
	rst 38h			;187a	ff		.
	rst 38h			;187b	ff		.
	rst 38h			;187c	ff		.
	rst 38h			;187d	ff		.
	rst 38h			;187e	ff		.
	rst 38h			;187f	ff		.
	rst 38h			;1880	ff		.
	rst 38h			;1881	ff		.
	rst 38h			;1882	ff		.
	rst 38h			;1883	ff		.
	rst 38h			;1884	ff		.
	rst 38h			;1885	ff		.
	rst 38h			;1886	ff		.
	rst 38h			;1887	ff		.
	rst 38h			;1888	ff		.
	rst 38h			;1889	ff		.
	rst 38h			;188a	ff		.
	rst 38h			;188b	ff		.
	rst 38h			;188c	ff		.
	rst 38h			;188d	ff		.
	rst 38h			;188e	ff		.
	rst 38h			;188f	ff		.
	rst 38h			;1890	ff		.
	rst 38h			;1891	ff		.
	rst 38h			;1892	ff		.
	rst 38h			;1893	ff		.
	rst 38h			;1894	ff		.
	rst 38h			;1895	ff		.
	rst 38h			;1896	ff		.
	rst 38h			;1897	ff		.
	rst 38h			;1898	ff		.
	rst 38h			;1899	ff		.
	rst 38h			;189a	ff		.
	rst 38h			;189b	ff		.
	rst 38h			;189c	ff		.
	rst 38h			;189d	ff		.
	rst 38h			;189e	ff		.
	rst 38h			;189f	ff		.
	rst 38h			;18a0	ff		.
	rst 38h			;18a1	ff		.
	rst 38h			;18a2	ff		.
	rst 38h			;18a3	ff		.
	rst 38h			;18a4	ff		.
	rst 38h			;18a5	ff		.
	rst 38h			;18a6	ff		.
	rst 38h			;18a7	ff		.
	rst 38h			;18a8	ff		.
	rst 38h			;18a9	ff		.
	rst 38h			;18aa	ff		.
	rst 38h			;18ab	ff		.
	rst 38h			;18ac	ff		.
	rst 38h			;18ad	ff		.
	rst 38h			;18ae	ff		.
	rst 38h			;18af	ff		.
	rst 38h			;18b0	ff		.
	rst 38h			;18b1	ff		.
	rst 38h			;18b2	ff		.
	rst 38h			;18b3	ff		.
	rst 38h			;18b4	ff		.
	rst 38h			;18b5	ff		.
	rst 38h			;18b6	ff		.
	rst 38h			;18b7	ff		.
	rst 38h			;18b8	ff		.
	rst 38h			;18b9	ff		.
	rst 38h			;18ba	ff		.
	rst 38h			;18bb	ff		.
	rst 38h			;18bc	ff		.
	rst 38h			;18bd	ff		.
	rst 38h			;18be	ff		.
	rst 38h			;18bf	ff		.
	rst 38h			;18c0	ff		.
	rst 38h			;18c1	ff		.
	rst 38h			;18c2	ff		.
	rst 38h			;18c3	ff		.
	rst 38h			;18c4	ff		.
	rst 38h			;18c5	ff		.
	rst 38h			;18c6	ff		.
	rst 38h			;18c7	ff		.
	rst 38h			;18c8	ff		.
	rst 38h			;18c9	ff		.
	rst 38h			;18ca	ff		.
	rst 38h			;18cb	ff		.
	rst 38h			;18cc	ff		.
	rst 38h			;18cd	ff		.
	rst 38h			;18ce	ff		.
	rst 38h			;18cf	ff		.
	rst 38h			;18d0	ff		.
	rst 38h			;18d1	ff		.
	rst 38h			;18d2	ff		.
	rst 38h			;18d3	ff		.
	rst 38h			;18d4	ff		.
	rst 38h			;18d5	ff		.
	rst 38h			;18d6	ff		.
	rst 38h			;18d7	ff		.
	rst 38h			;18d8	ff		.
	rst 38h			;18d9	ff		.
	rst 38h			;18da	ff		.
	rst 38h			;18db	ff		.
	rst 38h			;18dc	ff		.
	rst 38h			;18dd	ff		.
	rst 38h			;18de	ff		.
	rst 38h			;18df	ff		.
	rst 38h			;18e0	ff		.
	rst 38h			;18e1	ff		.
	rst 38h			;18e2	ff		.
	rst 38h			;18e3	ff		.
	rst 38h			;18e4	ff		.
	rst 38h			;18e5	ff		.
	rst 38h			;18e6	ff		.
	rst 38h			;18e7	ff		.
	rst 38h			;18e8	ff		.
	rst 38h			;18e9	ff		.
	rst 38h			;18ea	ff		.
	rst 38h			;18eb	ff		.
	rst 38h			;18ec	ff		.
	rst 38h			;18ed	ff		.
	rst 38h			;18ee	ff		.
	rst 38h			;18ef	ff		.
	rst 38h			;18f0	ff		.
	rst 38h			;18f1	ff		.
	rst 38h			;18f2	ff		.
	rst 38h			;18f3	ff		.
	rst 38h			;18f4	ff		.
	rst 38h			;18f5	ff		.
	rst 38h			;18f6	ff		.
	rst 38h			;18f7	ff		.
	rst 38h			;18f8	ff		.
	rst 38h			;18f9	ff		.
	rst 38h			;18fa	ff		.
	rst 38h			;18fb	ff		.
	rst 38h			;18fc	ff		.
	rst 38h			;18fd	ff		.
	rst 38h			;18fe	ff		.
	rst 38h			;18ff	ff		.
	rst 38h			;1900	ff		.
	rst 38h			;1901	ff		.
	rst 38h			;1902	ff		.
	rst 38h			;1903	ff		.
	rst 38h			;1904	ff		.
	rst 38h			;1905	ff		.
	rst 38h			;1906	ff		.
	rst 38h			;1907	ff		.
	rst 38h			;1908	ff		.
	rst 38h			;1909	ff		.
	rst 38h			;190a	ff		.
	rst 38h			;190b	ff		.
	rst 38h			;190c	ff		.
	rst 38h			;190d	ff		.
	rst 38h			;190e	ff		.
	rst 38h			;190f	ff		.
	rst 38h			;1910	ff		.
	rst 38h			;1911	ff		.
	rst 38h			;1912	ff		.
	rst 38h			;1913	ff		.
	rst 38h			;1914	ff		.
	rst 38h			;1915	ff		.
	rst 38h			;1916	ff		.
	rst 38h			;1917	ff		.
	rst 38h			;1918	ff		.
	rst 38h			;1919	ff		.
	rst 38h			;191a	ff		.
	rst 38h			;191b	ff		.
	rst 38h			;191c	ff		.
	rst 38h			;191d	ff		.
	rst 38h			;191e	ff		.
	rst 38h			;191f	ff		.
	rst 38h			;1920	ff		.
	rst 38h			;1921	ff		.
	rst 38h			;1922	ff		.
	rst 38h			;1923	ff		.
	rst 38h			;1924	ff		.
	rst 38h			;1925	ff		.
	rst 38h			;1926	ff		.
	rst 38h			;1927	ff		.
	rst 38h			;1928	ff		.
	rst 38h			;1929	ff		.
	rst 38h			;192a	ff		.
	rst 38h			;192b	ff		.
	rst 38h			;192c	ff		.
	rst 38h			;192d	ff		.
	rst 38h			;192e	ff		.
	rst 38h			;192f	ff		.
	rst 38h			;1930	ff		.
	rst 38h			;1931	ff		.
	rst 38h			;1932	ff		.
	rst 38h			;1933	ff		.
	rst 38h			;1934	ff		.
	rst 38h			;1935	ff		.
	rst 38h			;1936	ff		.
	rst 38h			;1937	ff		.
	rst 38h			;1938	ff		.
	rst 38h			;1939	ff		.
	rst 38h			;193a	ff		.
	rst 38h			;193b	ff		.
	rst 38h			;193c	ff		.
	rst 38h			;193d	ff		.
	rst 38h			;193e	ff		.
	rst 38h			;193f	ff		.
	rst 38h			;1940	ff		.
	rst 38h			;1941	ff		.
	rst 38h			;1942	ff		.
	rst 38h			;1943	ff		.
	rst 38h			;1944	ff		.
	rst 38h			;1945	ff		.
	rst 38h			;1946	ff		.
	rst 38h			;1947	ff		.
	rst 38h			;1948	ff		.
	rst 38h			;1949	ff		.
	rst 38h			;194a	ff		.
	rst 38h			;194b	ff		.
	rst 38h			;194c	ff		.
	rst 38h			;194d	ff		.
	rst 38h			;194e	ff		.
	rst 38h			;194f	ff		.
	rst 38h			;1950	ff		.
	rst 38h			;1951	ff		.
	rst 38h			;1952	ff		.
	rst 38h			;1953	ff		.
	rst 38h			;1954	ff		.
	rst 38h			;1955	ff		.
	rst 38h			;1956	ff		.
	rst 38h			;1957	ff		.
	rst 38h			;1958	ff		.
	rst 38h			;1959	ff		.
	rst 38h			;195a	ff		.
	rst 38h			;195b	ff		.
	rst 38h			;195c	ff		.
	rst 38h			;195d	ff		.
	rst 38h			;195e	ff		.
	rst 38h			;195f	ff		.
	rst 38h			;1960	ff		.
	rst 38h			;1961	ff		.
	rst 38h			;1962	ff		.
	rst 38h			;1963	ff		.
	rst 38h			;1964	ff		.
	rst 38h			;1965	ff		.
	rst 38h			;1966	ff		.
	rst 38h			;1967	ff		.
	rst 38h			;1968	ff		.
	rst 38h			;1969	ff		.
	rst 38h			;196a	ff		.
	rst 38h			;196b	ff		.
	rst 38h			;196c	ff		.
	rst 38h			;196d	ff		.
	rst 38h			;196e	ff		.
	rst 38h			;196f	ff		.
	rst 38h			;1970	ff		.
	rst 38h			;1971	ff		.
	rst 38h			;1972	ff		.
	rst 38h			;1973	ff		.
	rst 38h			;1974	ff		.
	rst 38h			;1975	ff		.
	rst 38h			;1976	ff		.
	rst 38h			;1977	ff		.
	rst 38h			;1978	ff		.
	rst 38h			;1979	ff		.
	rst 38h			;197a	ff		.
	rst 38h			;197b	ff		.
	rst 38h			;197c	ff		.
	rst 38h			;197d	ff		.
	rst 38h			;197e	ff		.
	rst 38h			;197f	ff		.
	rst 38h			;1980	ff		.
	rst 38h			;1981	ff		.
	rst 38h			;1982	ff		.
	rst 38h			;1983	ff		.
	rst 38h			;1984	ff		.
	rst 38h			;1985	ff		.
	rst 38h			;1986	ff		.
	rst 38h			;1987	ff		.
	rst 38h			;1988	ff		.
	rst 38h			;1989	ff		.
	rst 38h			;198a	ff		.
	rst 38h			;198b	ff		.
	rst 38h			;198c	ff		.
	rst 38h			;198d	ff		.
	rst 38h			;198e	ff		.
	rst 38h			;198f	ff		.
	rst 38h			;1990	ff		.
	rst 38h			;1991	ff		.
	rst 38h			;1992	ff		.
	rst 38h			;1993	ff		.
	rst 38h			;1994	ff		.
	rst 38h			;1995	ff		.
	rst 38h			;1996	ff		.
	rst 38h			;1997	ff		.
	rst 38h			;1998	ff		.
	rst 38h			;1999	ff		.
	rst 38h			;199a	ff		.
	rst 38h			;199b	ff		.
	rst 38h			;199c	ff		.
	rst 38h			;199d	ff		.
	rst 38h			;199e	ff		.
	rst 38h			;199f	ff		.
	rst 38h			;19a0	ff		.
	rst 38h			;19a1	ff		.
	rst 38h			;19a2	ff		.
	rst 38h			;19a3	ff		.
	rst 38h			;19a4	ff		.
	rst 38h			;19a5	ff		.
	rst 38h			;19a6	ff		.
	rst 38h			;19a7	ff		.
	rst 38h			;19a8	ff		.
	rst 38h			;19a9	ff		.
	rst 38h			;19aa	ff		.
	rst 38h			;19ab	ff		.
	rst 38h			;19ac	ff		.
	rst 38h			;19ad	ff		.
	rst 38h			;19ae	ff		.
	rst 38h			;19af	ff		.
	rst 38h			;19b0	ff		.
	rst 38h			;19b1	ff		.
	rst 38h			;19b2	ff		.
	rst 38h			;19b3	ff		.
	rst 38h			;19b4	ff		.
	rst 38h			;19b5	ff		.
	rst 38h			;19b6	ff		.
	rst 38h			;19b7	ff		.
	rst 38h			;19b8	ff		.
	rst 38h			;19b9	ff		.
	rst 38h			;19ba	ff		.
	rst 38h			;19bb	ff		.
	rst 38h			;19bc	ff		.
	rst 38h			;19bd	ff		.
	rst 38h			;19be	ff		.
	rst 38h			;19bf	ff		.
	rst 38h			;19c0	ff		.
	rst 38h			;19c1	ff		.
	rst 38h			;19c2	ff		.
	rst 38h			;19c3	ff		.
	rst 38h			;19c4	ff		.
	rst 38h			;19c5	ff		.
	rst 38h			;19c6	ff		.
	rst 38h			;19c7	ff		.
	rst 38h			;19c8	ff		.
	rst 38h			;19c9	ff		.
	rst 38h			;19ca	ff		.
	rst 38h			;19cb	ff		.
	rst 38h			;19cc	ff		.
	rst 38h			;19cd	ff		.
	rst 38h			;19ce	ff		.
	rst 38h			;19cf	ff		.
	rst 38h			;19d0	ff		.
	rst 38h			;19d1	ff		.
	rst 38h			;19d2	ff		.
	rst 38h			;19d3	ff		.
	rst 38h			;19d4	ff		.
	rst 38h			;19d5	ff		.
	rst 38h			;19d6	ff		.
	rst 38h			;19d7	ff		.
	rst 38h			;19d8	ff		.
	rst 38h			;19d9	ff		.
	rst 38h			;19da	ff		.
	rst 38h			;19db	ff		.
	rst 38h			;19dc	ff		.
	rst 38h			;19dd	ff		.
	rst 38h			;19de	ff		.
	rst 38h			;19df	ff		.
	rst 38h			;19e0	ff		.
	rst 38h			;19e1	ff		.
	rst 38h			;19e2	ff		.
	rst 38h			;19e3	ff		.
	rst 38h			;19e4	ff		.
	rst 38h			;19e5	ff		.
	rst 38h			;19e6	ff		.
	rst 38h			;19e7	ff		.
	rst 38h			;19e8	ff		.
	rst 38h			;19e9	ff		.
	rst 38h			;19ea	ff		.
	rst 38h			;19eb	ff		.
	rst 38h			;19ec	ff		.
	rst 38h			;19ed	ff		.
	rst 38h			;19ee	ff		.
	rst 38h			;19ef	ff		.
	rst 38h			;19f0	ff		.
	rst 38h			;19f1	ff		.
	rst 38h			;19f2	ff		.
	rst 38h			;19f3	ff		.
	rst 38h			;19f4	ff		.
	rst 38h			;19f5	ff		.
	rst 38h			;19f6	ff		.
	rst 38h			;19f7	ff		.
	rst 38h			;19f8	ff		.
	rst 38h			;19f9	ff		.
	rst 38h			;19fa	ff		.
	rst 38h			;19fb	ff		.
	rst 38h			;19fc	ff		.
	rst 38h			;19fd	ff		.
	rst 38h			;19fe	ff		.
	rst 38h			;19ff	ff		.
	rst 38h			;1a00	ff		.
	rst 38h			;1a01	ff		.
	rst 38h			;1a02	ff		.
	rst 38h			;1a03	ff		.
	rst 38h			;1a04	ff		.
	rst 38h			;1a05	ff		.
	rst 38h			;1a06	ff		.
	rst 38h			;1a07	ff		.
	rst 38h			;1a08	ff		.
	rst 38h			;1a09	ff		.
	rst 38h			;1a0a	ff		.
	rst 38h			;1a0b	ff		.
	rst 38h			;1a0c	ff		.
	rst 38h			;1a0d	ff		.
	rst 38h			;1a0e	ff		.
	rst 38h			;1a0f	ff		.
	rst 38h			;1a10	ff		.
	rst 38h			;1a11	ff		.
	rst 38h			;1a12	ff		.
	rst 38h			;1a13	ff		.
	rst 38h			;1a14	ff		.
	rst 38h			;1a15	ff		.
	rst 38h			;1a16	ff		.
	rst 38h			;1a17	ff		.
	rst 38h			;1a18	ff		.
	rst 38h			;1a19	ff		.
	rst 38h			;1a1a	ff		.
	rst 38h			;1a1b	ff		.
	rst 38h			;1a1c	ff		.
	rst 38h			;1a1d	ff		.
	rst 38h			;1a1e	ff		.
	rst 38h			;1a1f	ff		.
	rst 38h			;1a20	ff		.
	rst 38h			;1a21	ff		.
	rst 38h			;1a22	ff		.
	rst 38h			;1a23	ff		.
	rst 38h			;1a24	ff		.
	rst 38h			;1a25	ff		.
	rst 38h			;1a26	ff		.
	rst 38h			;1a27	ff		.
	rst 38h			;1a28	ff		.
	rst 38h			;1a29	ff		.
	rst 38h			;1a2a	ff		.
	rst 38h			;1a2b	ff		.
	rst 38h			;1a2c	ff		.
	rst 38h			;1a2d	ff		.
	rst 38h			;1a2e	ff		.
	rst 38h			;1a2f	ff		.
	rst 38h			;1a30	ff		.
	rst 38h			;1a31	ff		.
	rst 38h			;1a32	ff		.
	rst 38h			;1a33	ff		.
	rst 38h			;1a34	ff		.
	rst 38h			;1a35	ff		.
	rst 38h			;1a36	ff		.
	rst 38h			;1a37	ff		.
	rst 38h			;1a38	ff		.
	rst 38h			;1a39	ff		.
	rst 38h			;1a3a	ff		.
	rst 38h			;1a3b	ff		.
	rst 38h			;1a3c	ff		.
	rst 38h			;1a3d	ff		.
	rst 38h			;1a3e	ff		.
	rst 38h			;1a3f	ff		.
	rst 38h			;1a40	ff		.
	rst 38h			;1a41	ff		.
	rst 38h			;1a42	ff		.
	rst 38h			;1a43	ff		.
	rst 38h			;1a44	ff		.
	rst 38h			;1a45	ff		.
	rst 38h			;1a46	ff		.
	rst 38h			;1a47	ff		.
	rst 38h			;1a48	ff		.
	rst 38h			;1a49	ff		.
	rst 38h			;1a4a	ff		.
	rst 38h			;1a4b	ff		.
	rst 38h			;1a4c	ff		.
	rst 38h			;1a4d	ff		.
	rst 38h			;1a4e	ff		.
	rst 38h			;1a4f	ff		.
	rst 38h			;1a50	ff		.
	rst 38h			;1a51	ff		.
	rst 38h			;1a52	ff		.
	rst 38h			;1a53	ff		.
	rst 38h			;1a54	ff		.
	rst 38h			;1a55	ff		.
	rst 38h			;1a56	ff		.
	rst 38h			;1a57	ff		.
	rst 38h			;1a58	ff		.
	rst 38h			;1a59	ff		.
	rst 38h			;1a5a	ff		.
	rst 38h			;1a5b	ff		.
	rst 38h			;1a5c	ff		.
	rst 38h			;1a5d	ff		.
	rst 38h			;1a5e	ff		.
	rst 38h			;1a5f	ff		.
	rst 38h			;1a60	ff		.
	rst 38h			;1a61	ff		.
	rst 38h			;1a62	ff		.
	rst 38h			;1a63	ff		.
	rst 38h			;1a64	ff		.
	rst 38h			;1a65	ff		.
	rst 38h			;1a66	ff		.
	rst 38h			;1a67	ff		.
	rst 38h			;1a68	ff		.
	rst 38h			;1a69	ff		.
	rst 38h			;1a6a	ff		.
	rst 38h			;1a6b	ff		.
	rst 38h			;1a6c	ff		.
	rst 38h			;1a6d	ff		.
	rst 38h			;1a6e	ff		.
	rst 38h			;1a6f	ff		.
	rst 38h			;1a70	ff		.
	rst 38h			;1a71	ff		.
	rst 38h			;1a72	ff		.
	rst 38h			;1a73	ff		.
	rst 38h			;1a74	ff		.
	rst 38h			;1a75	ff		.
	rst 38h			;1a76	ff		.
	rst 38h			;1a77	ff		.
	rst 38h			;1a78	ff		.
	rst 38h			;1a79	ff		.
	rst 38h			;1a7a	ff		.
	rst 38h			;1a7b	ff		.
	rst 38h			;1a7c	ff		.
	rst 38h			;1a7d	ff		.
	rst 38h			;1a7e	ff		.
	rst 38h			;1a7f	ff		.
	rst 38h			;1a80	ff		.
	rst 38h			;1a81	ff		.
	rst 38h			;1a82	ff		.
	rst 38h			;1a83	ff		.
	rst 38h			;1a84	ff		.
	rst 38h			;1a85	ff		.
	rst 38h			;1a86	ff		.
	rst 38h			;1a87	ff		.
	rst 38h			;1a88	ff		.
	rst 38h			;1a89	ff		.
	rst 38h			;1a8a	ff		.
	rst 38h			;1a8b	ff		.
	rst 38h			;1a8c	ff		.
	rst 38h			;1a8d	ff		.
	rst 38h			;1a8e	ff		.
	rst 38h			;1a8f	ff		.
	rst 38h			;1a90	ff		.
	rst 38h			;1a91	ff		.
	rst 38h			;1a92	ff		.
	rst 38h			;1a93	ff		.
	rst 38h			;1a94	ff		.
	rst 38h			;1a95	ff		.
	rst 38h			;1a96	ff		.
	rst 38h			;1a97	ff		.
	rst 38h			;1a98	ff		.
	rst 38h			;1a99	ff		.
	rst 38h			;1a9a	ff		.
	rst 38h			;1a9b	ff		.
	rst 38h			;1a9c	ff		.
	rst 38h			;1a9d	ff		.
	rst 38h			;1a9e	ff		.
	rst 38h			;1a9f	ff		.
	rst 38h			;1aa0	ff		.
	rst 38h			;1aa1	ff		.
	rst 38h			;1aa2	ff		.
	rst 38h			;1aa3	ff		.
	rst 38h			;1aa4	ff		.
	rst 38h			;1aa5	ff		.
	rst 38h			;1aa6	ff		.
	rst 38h			;1aa7	ff		.
	rst 38h			;1aa8	ff		.
	rst 38h			;1aa9	ff		.
	rst 38h			;1aaa	ff		.
	rst 38h			;1aab	ff		.
	rst 38h			;1aac	ff		.
	rst 38h			;1aad	ff		.
	rst 38h			;1aae	ff		.
	rst 38h			;1aaf	ff		.
	rst 38h			;1ab0	ff		.
	rst 38h			;1ab1	ff		.
	rst 38h			;1ab2	ff		.
	rst 38h			;1ab3	ff		.
	rst 38h			;1ab4	ff		.
	rst 38h			;1ab5	ff		.
	rst 38h			;1ab6	ff		.
	rst 38h			;1ab7	ff		.
	rst 38h			;1ab8	ff		.
	rst 38h			;1ab9	ff		.
	rst 38h			;1aba	ff		.
	rst 38h			;1abb	ff		.
	rst 38h			;1abc	ff		.
	rst 38h			;1abd	ff		.
	rst 38h			;1abe	ff		.
	rst 38h			;1abf	ff		.
	rst 38h			;1ac0	ff		.
	rst 38h			;1ac1	ff		.
	rst 38h			;1ac2	ff		.
	rst 38h			;1ac3	ff		.
	rst 38h			;1ac4	ff		.
	rst 38h			;1ac5	ff		.
	rst 38h			;1ac6	ff		.
	rst 38h			;1ac7	ff		.
	rst 38h			;1ac8	ff		.
	rst 38h			;1ac9	ff		.
	rst 38h			;1aca	ff		.
	rst 38h			;1acb	ff		.
	rst 38h			;1acc	ff		.
	rst 38h			;1acd	ff		.
	rst 38h			;1ace	ff		.
	rst 38h			;1acf	ff		.
	rst 38h			;1ad0	ff		.
	rst 38h			;1ad1	ff		.
	rst 38h			;1ad2	ff		.
	rst 38h			;1ad3	ff		.
	rst 38h			;1ad4	ff		.
	rst 38h			;1ad5	ff		.
	rst 38h			;1ad6	ff		.
	rst 38h			;1ad7	ff		.
	rst 38h			;1ad8	ff		.
	rst 38h			;1ad9	ff		.
	rst 38h			;1ada	ff		.
	rst 38h			;1adb	ff		.
	rst 38h			;1adc	ff		.
	rst 38h			;1add	ff		.
	rst 38h			;1ade	ff		.
	rst 38h			;1adf	ff		.
	rst 38h			;1ae0	ff		.
	rst 38h			;1ae1	ff		.
	rst 38h			;1ae2	ff		.
	rst 38h			;1ae3	ff		.
	rst 38h			;1ae4	ff		.
	rst 38h			;1ae5	ff		.
	rst 38h			;1ae6	ff		.
	rst 38h			;1ae7	ff		.
	rst 38h			;1ae8	ff		.
	rst 38h			;1ae9	ff		.
	rst 38h			;1aea	ff		.
	rst 38h			;1aeb	ff		.
	rst 38h			;1aec	ff		.
	rst 38h			;1aed	ff		.
	rst 38h			;1aee	ff		.
	rst 38h			;1aef	ff		.
	rst 38h			;1af0	ff		.
	rst 38h			;1af1	ff		.
	rst 38h			;1af2	ff		.
	rst 38h			;1af3	ff		.
	rst 38h			;1af4	ff		.
	rst 38h			;1af5	ff		.
	rst 38h			;1af6	ff		.
	rst 38h			;1af7	ff		.
	rst 38h			;1af8	ff		.
	rst 38h			;1af9	ff		.
	rst 38h			;1afa	ff		.
	rst 38h			;1afb	ff		.
	rst 38h			;1afc	ff		.
	rst 38h			;1afd	ff		.
	rst 38h			;1afe	ff		.
	rst 38h			;1aff	ff		.
	rst 38h			;1b00	ff		.
	rst 38h			;1b01	ff		.
	rst 38h			;1b02	ff		.
	rst 38h			;1b03	ff		.
	rst 38h			;1b04	ff		.
	rst 38h			;1b05	ff		.
	rst 38h			;1b06	ff		.
	rst 38h			;1b07	ff		.
	rst 38h			;1b08	ff		.
	rst 38h			;1b09	ff		.
	rst 38h			;1b0a	ff		.
	rst 38h			;1b0b	ff		.
	rst 38h			;1b0c	ff		.
	rst 38h			;1b0d	ff		.
	rst 38h			;1b0e	ff		.
	rst 38h			;1b0f	ff		.
	rst 38h			;1b10	ff		.
	rst 38h			;1b11	ff		.
	rst 38h			;1b12	ff		.
	rst 38h			;1b13	ff		.
	rst 38h			;1b14	ff		.
	rst 38h			;1b15	ff		.
	rst 38h			;1b16	ff		.
	rst 38h			;1b17	ff		.
	rst 38h			;1b18	ff		.
	rst 38h			;1b19	ff		.
	rst 38h			;1b1a	ff		.
	rst 38h			;1b1b	ff		.
	rst 38h			;1b1c	ff		.
	rst 38h			;1b1d	ff		.
	rst 38h			;1b1e	ff		.
	rst 38h			;1b1f	ff		.
	rst 38h			;1b20	ff		.
	rst 38h			;1b21	ff		.
	rst 38h			;1b22	ff		.
	rst 38h			;1b23	ff		.
	rst 38h			;1b24	ff		.
	rst 38h			;1b25	ff		.
	rst 38h			;1b26	ff		.
	rst 38h			;1b27	ff		.
	rst 38h			;1b28	ff		.
	rst 38h			;1b29	ff		.
	rst 38h			;1b2a	ff		.
	rst 38h			;1b2b	ff		.
	rst 38h			;1b2c	ff		.
	rst 38h			;1b2d	ff		.
	rst 38h			;1b2e	ff		.
	rst 38h			;1b2f	ff		.
	rst 38h			;1b30	ff		.
	rst 38h			;1b31	ff		.
	rst 38h			;1b32	ff		.
	rst 38h			;1b33	ff		.
	rst 38h			;1b34	ff		.
	rst 38h			;1b35	ff		.
	rst 38h			;1b36	ff		.
	rst 38h			;1b37	ff		.
	rst 38h			;1b38	ff		.
	rst 38h			;1b39	ff		.
	rst 38h			;1b3a	ff		.
	rst 38h			;1b3b	ff		.
	rst 38h			;1b3c	ff		.
	rst 38h			;1b3d	ff		.
	rst 38h			;1b3e	ff		.
	rst 38h			;1b3f	ff		.
	rst 38h			;1b40	ff		.
	rst 38h			;1b41	ff		.
	rst 38h			;1b42	ff		.
	rst 38h			;1b43	ff		.
	rst 38h			;1b44	ff		.
	rst 38h			;1b45	ff		.
	rst 38h			;1b46	ff		.
	rst 38h			;1b47	ff		.
	rst 38h			;1b48	ff		.
	rst 38h			;1b49	ff		.
	rst 38h			;1b4a	ff		.
	rst 38h			;1b4b	ff		.
	rst 38h			;1b4c	ff		.
	rst 38h			;1b4d	ff		.
	rst 38h			;1b4e	ff		.
	rst 38h			;1b4f	ff		.
	rst 38h			;1b50	ff		.
	rst 38h			;1b51	ff		.
	rst 38h			;1b52	ff		.
	rst 38h			;1b53	ff		.
	rst 38h			;1b54	ff		.
	rst 38h			;1b55	ff		.
	rst 38h			;1b56	ff		.
	rst 38h			;1b57	ff		.
	rst 38h			;1b58	ff		.
	rst 38h			;1b59	ff		.
	rst 38h			;1b5a	ff		.
	rst 38h			;1b5b	ff		.
	rst 38h			;1b5c	ff		.
	rst 38h			;1b5d	ff		.
	rst 38h			;1b5e	ff		.
	rst 38h			;1b5f	ff		.
	rst 38h			;1b60	ff		.
	rst 38h			;1b61	ff		.
	rst 38h			;1b62	ff		.
	rst 38h			;1b63	ff		.
	rst 38h			;1b64	ff		.
	rst 38h			;1b65	ff		.
	rst 38h			;1b66	ff		.
	rst 38h			;1b67	ff		.
	rst 38h			;1b68	ff		.
	rst 38h			;1b69	ff		.
	rst 38h			;1b6a	ff		.
	rst 38h			;1b6b	ff		.
	rst 38h			;1b6c	ff		.
	rst 38h			;1b6d	ff		.
	rst 38h			;1b6e	ff		.
	rst 38h			;1b6f	ff		.
	rst 38h			;1b70	ff		.
	rst 38h			;1b71	ff		.
	rst 38h			;1b72	ff		.
	rst 38h			;1b73	ff		.
	rst 38h			;1b74	ff		.
	rst 38h			;1b75	ff		.
	rst 38h			;1b76	ff		.
	rst 38h			;1b77	ff		.
	rst 38h			;1b78	ff		.
	rst 38h			;1b79	ff		.
	rst 38h			;1b7a	ff		.
	rst 38h			;1b7b	ff		.
	rst 38h			;1b7c	ff		.
	rst 38h			;1b7d	ff		.
	rst 38h			;1b7e	ff		.
	rst 38h			;1b7f	ff		.
	rst 38h			;1b80	ff		.
	rst 38h			;1b81	ff		.
	rst 38h			;1b82	ff		.
	rst 38h			;1b83	ff		.
	rst 38h			;1b84	ff		.
	rst 38h			;1b85	ff		.
	rst 38h			;1b86	ff		.
	rst 38h			;1b87	ff		.
	rst 38h			;1b88	ff		.
	rst 38h			;1b89	ff		.
	rst 38h			;1b8a	ff		.
	rst 38h			;1b8b	ff		.
	rst 38h			;1b8c	ff		.
	rst 38h			;1b8d	ff		.
	rst 38h			;1b8e	ff		.
	rst 38h			;1b8f	ff		.
	rst 38h			;1b90	ff		.
	rst 38h			;1b91	ff		.
	rst 38h			;1b92	ff		.
	rst 38h			;1b93	ff		.
	rst 38h			;1b94	ff		.
	rst 38h			;1b95	ff		.
	rst 38h			;1b96	ff		.
	rst 38h			;1b97	ff		.
	rst 38h			;1b98	ff		.
	rst 38h			;1b99	ff		.
	rst 38h			;1b9a	ff		.
	rst 38h			;1b9b	ff		.
	rst 38h			;1b9c	ff		.
	rst 38h			;1b9d	ff		.
	rst 38h			;1b9e	ff		.
	rst 38h			;1b9f	ff		.
	rst 38h			;1ba0	ff		.
	rst 38h			;1ba1	ff		.
	rst 38h			;1ba2	ff		.
	rst 38h			;1ba3	ff		.
	rst 38h			;1ba4	ff		.
	rst 38h			;1ba5	ff		.
	rst 38h			;1ba6	ff		.
	rst 38h			;1ba7	ff		.
	rst 38h			;1ba8	ff		.
	rst 38h			;1ba9	ff		.
	rst 38h			;1baa	ff		.
	rst 38h			;1bab	ff		.
	rst 38h			;1bac	ff		.
	rst 38h			;1bad	ff		.
	rst 38h			;1bae	ff		.
	rst 38h			;1baf	ff		.
	rst 38h			;1bb0	ff		.
	rst 38h			;1bb1	ff		.
	rst 38h			;1bb2	ff		.
	rst 38h			;1bb3	ff		.
	rst 38h			;1bb4	ff		.
	rst 38h			;1bb5	ff		.
	rst 38h			;1bb6	ff		.
	rst 38h			;1bb7	ff		.
	rst 38h			;1bb8	ff		.
	rst 38h			;1bb9	ff		.
	rst 38h			;1bba	ff		.
	rst 38h			;1bbb	ff		.
	rst 38h			;1bbc	ff		.
	rst 38h			;1bbd	ff		.
	rst 38h			;1bbe	ff		.
	rst 38h			;1bbf	ff		.
	rst 38h			;1bc0	ff		.
	rst 38h			;1bc1	ff		.
	rst 38h			;1bc2	ff		.
	rst 38h			;1bc3	ff		.
	rst 38h			;1bc4	ff		.
	rst 38h			;1bc5	ff		.
	rst 38h			;1bc6	ff		.
	rst 38h			;1bc7	ff		.
	rst 38h			;1bc8	ff		.
	rst 38h			;1bc9	ff		.
	rst 38h			;1bca	ff		.
	rst 38h			;1bcb	ff		.
	rst 38h			;1bcc	ff		.
	rst 38h			;1bcd	ff		.
	rst 38h			;1bce	ff		.
	rst 38h			;1bcf	ff		.
	rst 38h			;1bd0	ff		.
	rst 38h			;1bd1	ff		.
	rst 38h			;1bd2	ff		.
	rst 38h			;1bd3	ff		.
	rst 38h			;1bd4	ff		.
	rst 38h			;1bd5	ff		.
	rst 38h			;1bd6	ff		.
	rst 38h			;1bd7	ff		.
	rst 38h			;1bd8	ff		.
	rst 38h			;1bd9	ff		.
	rst 38h			;1bda	ff		.
	rst 38h			;1bdb	ff		.
	rst 38h			;1bdc	ff		.
	rst 38h			;1bdd	ff		.
	rst 38h			;1bde	ff		.
	rst 38h			;1bdf	ff		.
	rst 38h			;1be0	ff		.
	rst 38h			;1be1	ff		.
	rst 38h			;1be2	ff		.
	rst 38h			;1be3	ff		.
	rst 38h			;1be4	ff		.
	rst 38h			;1be5	ff		.
	rst 38h			;1be6	ff		.
	rst 38h			;1be7	ff		.
	rst 38h			;1be8	ff		.
	rst 38h			;1be9	ff		.
	rst 38h			;1bea	ff		.
	rst 38h			;1beb	ff		.
	rst 38h			;1bec	ff		.
	rst 38h			;1bed	ff		.
	rst 38h			;1bee	ff		.
	rst 38h			;1bef	ff		.
	rst 38h			;1bf0	ff		.
	rst 38h			;1bf1	ff		.
	rst 38h			;1bf2	ff		.
	rst 38h			;1bf3	ff		.
	rst 38h			;1bf4	ff		.
	rst 38h			;1bf5	ff		.
	rst 38h			;1bf6	ff		.
	rst 38h			;1bf7	ff		.
	rst 38h			;1bf8	ff		.
	rst 38h			;1bf9	ff		.
	rst 38h			;1bfa	ff		.
	rst 38h			;1bfb	ff		.
	rst 38h			;1bfc	ff		.
	rst 38h			;1bfd	ff		.
	rst 38h			;1bfe	ff		.
	rst 38h			;1bff	ff		.
	rst 38h			;1c00	ff		.
	rst 38h			;1c01	ff		.
	rst 38h			;1c02	ff		.
	rst 38h			;1c03	ff		.
	rst 38h			;1c04	ff		.
	rst 38h			;1c05	ff		.
	rst 38h			;1c06	ff		.
	rst 38h			;1c07	ff		.
	rst 38h			;1c08	ff		.
	rst 38h			;1c09	ff		.
	rst 38h			;1c0a	ff		.
	rst 38h			;1c0b	ff		.
	rst 38h			;1c0c	ff		.
	rst 38h			;1c0d	ff		.
	rst 38h			;1c0e	ff		.
	rst 38h			;1c0f	ff		.
	rst 38h			;1c10	ff		.
	rst 38h			;1c11	ff		.
	rst 38h			;1c12	ff		.
	rst 38h			;1c13	ff		.
	rst 38h			;1c14	ff		.
	rst 38h			;1c15	ff		.
	rst 38h			;1c16	ff		.
	rst 38h			;1c17	ff		.
	rst 38h			;1c18	ff		.
	rst 38h			;1c19	ff		.
	rst 38h			;1c1a	ff		.
	rst 38h			;1c1b	ff		.
	rst 38h			;1c1c	ff		.
	rst 38h			;1c1d	ff		.
	rst 38h			;1c1e	ff		.
	rst 38h			;1c1f	ff		.
	rst 38h			;1c20	ff		.
	rst 38h			;1c21	ff		.
	rst 38h			;1c22	ff		.
l1c23h:
	rst 38h			;1c23	ff		.
	rst 38h			;1c24	ff		.
	rst 38h			;1c25	ff		.
	rst 38h			;1c26	ff		.
	rst 38h			;1c27	ff		.
	rst 38h			;1c28	ff		.
	rst 38h			;1c29	ff		.
	rst 38h			;1c2a	ff		.
	rst 38h			;1c2b	ff		.
	rst 38h			;1c2c	ff		.
	rst 38h			;1c2d	ff		.
	rst 38h			;1c2e	ff		.
	rst 38h			;1c2f	ff		.
	rst 38h			;1c30	ff		.
	rst 38h			;1c31	ff		.
	rst 38h			;1c32	ff		.
	rst 38h			;1c33	ff		.
	rst 38h			;1c34	ff		.
	rst 38h			;1c35	ff		.
	rst 38h			;1c36	ff		.
	rst 38h			;1c37	ff		.
	rst 38h			;1c38	ff		.
	rst 38h			;1c39	ff		.
	rst 38h			;1c3a	ff		.
	rst 38h			;1c3b	ff		.
	rst 38h			;1c3c	ff		.
	rst 38h			;1c3d	ff		.
	rst 38h			;1c3e	ff		.
	rst 38h			;1c3f	ff		.
	rst 38h			;1c40	ff		.
	rst 38h			;1c41	ff		.
	rst 38h			;1c42	ff		.
	rst 38h			;1c43	ff		.
	rst 38h			;1c44	ff		.
	rst 38h			;1c45	ff		.
	rst 38h			;1c46	ff		.
	rst 38h			;1c47	ff		.
	rst 38h			;1c48	ff		.
	rst 38h			;1c49	ff		.
	rst 38h			;1c4a	ff		.
	rst 38h			;1c4b	ff		.
	rst 38h			;1c4c	ff		.
	rst 38h			;1c4d	ff		.
	rst 38h			;1c4e	ff		.
	rst 38h			;1c4f	ff		.
	rst 38h			;1c50	ff		.
	rst 38h			;1c51	ff		.
	rst 38h			;1c52	ff		.
	rst 38h			;1c53	ff		.
	rst 38h			;1c54	ff		.
	rst 38h			;1c55	ff		.
	rst 38h			;1c56	ff		.
	rst 38h			;1c57	ff		.
	rst 38h			;1c58	ff		.
	rst 38h			;1c59	ff		.
	rst 38h			;1c5a	ff		.
	rst 38h			;1c5b	ff		.
	rst 38h			;1c5c	ff		.
	rst 38h			;1c5d	ff		.
	rst 38h			;1c5e	ff		.
	rst 38h			;1c5f	ff		.
	rst 38h			;1c60	ff		.
	rst 38h			;1c61	ff		.
	rst 38h			;1c62	ff		.
	rst 38h			;1c63	ff		.
	rst 38h			;1c64	ff		.
	rst 38h			;1c65	ff		.
	rst 38h			;1c66	ff		.
	rst 38h			;1c67	ff		.
	rst 38h			;1c68	ff		.
	rst 38h			;1c69	ff		.
	rst 38h			;1c6a	ff		.
	rst 38h			;1c6b	ff		.
	rst 38h			;1c6c	ff		.
	rst 38h			;1c6d	ff		.
	rst 38h			;1c6e	ff		.
	rst 38h			;1c6f	ff		.
	rst 38h			;1c70	ff		.
	rst 38h			;1c71	ff		.
	rst 38h			;1c72	ff		.
	rst 38h			;1c73	ff		.
	rst 38h			;1c74	ff		.
	rst 38h			;1c75	ff		.
	rst 38h			;1c76	ff		.
	rst 38h			;1c77	ff		.
	rst 38h			;1c78	ff		.
	rst 38h			;1c79	ff		.
	rst 38h			;1c7a	ff		.
	rst 38h			;1c7b	ff		.
	rst 38h			;1c7c	ff		.
	rst 38h			;1c7d	ff		.
	rst 38h			;1c7e	ff		.
	rst 38h			;1c7f	ff		.
	rst 38h			;1c80	ff		.
	rst 38h			;1c81	ff		.
	rst 38h			;1c82	ff		.
	rst 38h			;1c83	ff		.
	rst 38h			;1c84	ff		.
	rst 38h			;1c85	ff		.
	rst 38h			;1c86	ff		.
	rst 38h			;1c87	ff		.
	rst 38h			;1c88	ff		.
	rst 38h			;1c89	ff		.
	rst 38h			;1c8a	ff		.
	rst 38h			;1c8b	ff		.
	rst 38h			;1c8c	ff		.
	rst 38h			;1c8d	ff		.
	rst 38h			;1c8e	ff		.
	rst 38h			;1c8f	ff		.
	rst 38h			;1c90	ff		.
	rst 38h			;1c91	ff		.
	rst 38h			;1c92	ff		.
	rst 38h			;1c93	ff		.
	rst 38h			;1c94	ff		.
	rst 38h			;1c95	ff		.
	rst 38h			;1c96	ff		.
	rst 38h			;1c97	ff		.
	rst 38h			;1c98	ff		.
	rst 38h			;1c99	ff		.
	rst 38h			;1c9a	ff		.
	rst 38h			;1c9b	ff		.
	rst 38h			;1c9c	ff		.
	rst 38h			;1c9d	ff		.
	rst 38h			;1c9e	ff		.
	rst 38h			;1c9f	ff		.
	rst 38h			;1ca0	ff		.
	rst 38h			;1ca1	ff		.
	rst 38h			;1ca2	ff		.
	rst 38h			;1ca3	ff		.
	rst 38h			;1ca4	ff		.
	rst 38h			;1ca5	ff		.
	rst 38h			;1ca6	ff		.
	rst 38h			;1ca7	ff		.
	rst 38h			;1ca8	ff		.
	rst 38h			;1ca9	ff		.
	rst 38h			;1caa	ff		.
	rst 38h			;1cab	ff		.
	rst 38h			;1cac	ff		.
	rst 38h			;1cad	ff		.
	rst 38h			;1cae	ff		.
	rst 38h			;1caf	ff		.
	rst 38h			;1cb0	ff		.
	rst 38h			;1cb1	ff		.
	rst 38h			;1cb2	ff		.
	rst 38h			;1cb3	ff		.
	rst 38h			;1cb4	ff		.
	rst 38h			;1cb5	ff		.
	rst 38h			;1cb6	ff		.
	rst 38h			;1cb7	ff		.
	rst 38h			;1cb8	ff		.
	rst 38h			;1cb9	ff		.
	rst 38h			;1cba	ff		.
	rst 38h			;1cbb	ff		.
	rst 38h			;1cbc	ff		.
	rst 38h			;1cbd	ff		.
	rst 38h			;1cbe	ff		.
	rst 38h			;1cbf	ff		.
	rst 38h			;1cc0	ff		.
	rst 38h			;1cc1	ff		.
	rst 38h			;1cc2	ff		.
	rst 38h			;1cc3	ff		.
	rst 38h			;1cc4	ff		.
	rst 38h			;1cc5	ff		.
	rst 38h			;1cc6	ff		.
	rst 38h			;1cc7	ff		.
	rst 38h			;1cc8	ff		.
	rst 38h			;1cc9	ff		.
	rst 38h			;1cca	ff		.
	rst 38h			;1ccb	ff		.
	rst 38h			;1ccc	ff		.
	rst 38h			;1ccd	ff		.
	rst 38h			;1cce	ff		.
	rst 38h			;1ccf	ff		.
	rst 38h			;1cd0	ff		.
	rst 38h			;1cd1	ff		.
	rst 38h			;1cd2	ff		.
	rst 38h			;1cd3	ff		.
	rst 38h			;1cd4	ff		.
	rst 38h			;1cd5	ff		.
	rst 38h			;1cd6	ff		.
	rst 38h			;1cd7	ff		.
	rst 38h			;1cd8	ff		.
	rst 38h			;1cd9	ff		.
	rst 38h			;1cda	ff		.
	rst 38h			;1cdb	ff		.
	rst 38h			;1cdc	ff		.
	rst 38h			;1cdd	ff		.
	rst 38h			;1cde	ff		.
	rst 38h			;1cdf	ff		.
	rst 38h			;1ce0	ff		.
	rst 38h			;1ce1	ff		.
	rst 38h			;1ce2	ff		.
	rst 38h			;1ce3	ff		.
	rst 38h			;1ce4	ff		.
	rst 38h			;1ce5	ff		.
	rst 38h			;1ce6	ff		.
	rst 38h			;1ce7	ff		.
	rst 38h			;1ce8	ff		.
	rst 38h			;1ce9	ff		.
	rst 38h			;1cea	ff		.
	rst 38h			;1ceb	ff		.
	rst 38h			;1cec	ff		.
	rst 38h			;1ced	ff		.
	rst 38h			;1cee	ff		.
	rst 38h			;1cef	ff		.
	rst 38h			;1cf0	ff		.
	rst 38h			;1cf1	ff		.
	rst 38h			;1cf2	ff		.
	rst 38h			;1cf3	ff		.
	rst 38h			;1cf4	ff		.
	rst 38h			;1cf5	ff		.
	rst 38h			;1cf6	ff		.
	rst 38h			;1cf7	ff		.
	rst 38h			;1cf8	ff		.
	rst 38h			;1cf9	ff		.
	rst 38h			;1cfa	ff		.
	rst 38h			;1cfb	ff		.
	rst 38h			;1cfc	ff		.
	rst 38h			;1cfd	ff		.
	rst 38h			;1cfe	ff		.
	rst 38h			;1cff	ff		.
	rst 38h			;1d00	ff		.
	rst 38h			;1d01	ff		.
	rst 38h			;1d02	ff		.
	rst 38h			;1d03	ff		.
	rst 38h			;1d04	ff		.
	rst 38h			;1d05	ff		.
	rst 38h			;1d06	ff		.
	rst 38h			;1d07	ff		.
	rst 38h			;1d08	ff		.
	rst 38h			;1d09	ff		.
	rst 38h			;1d0a	ff		.
	rst 38h			;1d0b	ff		.
	rst 38h			;1d0c	ff		.
	rst 38h			;1d0d	ff		.
	rst 38h			;1d0e	ff		.
	rst 38h			;1d0f	ff		.
	rst 38h			;1d10	ff		.
	rst 38h			;1d11	ff		.
	rst 38h			;1d12	ff		.
	rst 38h			;1d13	ff		.
	rst 38h			;1d14	ff		.
	rst 38h			;1d15	ff		.
	rst 38h			;1d16	ff		.
	rst 38h			;1d17	ff		.
	rst 38h			;1d18	ff		.
	rst 38h			;1d19	ff		.
	rst 38h			;1d1a	ff		.
	rst 38h			;1d1b	ff		.
	rst 38h			;1d1c	ff		.
	rst 38h			;1d1d	ff		.
	rst 38h			;1d1e	ff		.
	rst 38h			;1d1f	ff		.
	rst 38h			;1d20	ff		.
	rst 38h			;1d21	ff		.
	rst 38h			;1d22	ff		.
	rst 38h			;1d23	ff		.
	rst 38h			;1d24	ff		.
	rst 38h			;1d25	ff		.
	rst 38h			;1d26	ff		.
	rst 38h			;1d27	ff		.
	rst 38h			;1d28	ff		.
	rst 38h			;1d29	ff		.
	rst 38h			;1d2a	ff		.
	rst 38h			;1d2b	ff		.
	rst 38h			;1d2c	ff		.
	rst 38h			;1d2d	ff		.
	rst 38h			;1d2e	ff		.
	rst 38h			;1d2f	ff		.
	rst 38h			;1d30	ff		.
	rst 38h			;1d31	ff		.
	rst 38h			;1d32	ff		.
	rst 38h			;1d33	ff		.
	rst 38h			;1d34	ff		.
	rst 38h			;1d35	ff		.
	rst 38h			;1d36	ff		.
	rst 38h			;1d37	ff		.
	rst 38h			;1d38	ff		.
	rst 38h			;1d39	ff		.
	rst 38h			;1d3a	ff		.
	rst 38h			;1d3b	ff		.
	rst 38h			;1d3c	ff		.
	rst 38h			;1d3d	ff		.
	rst 38h			;1d3e	ff		.
	rst 38h			;1d3f	ff		.
	rst 38h			;1d40	ff		.
	rst 38h			;1d41	ff		.
	rst 38h			;1d42	ff		.
	rst 38h			;1d43	ff		.
	rst 38h			;1d44	ff		.
	rst 38h			;1d45	ff		.
	rst 38h			;1d46	ff		.
	rst 38h			;1d47	ff		.
	rst 38h			;1d48	ff		.
	rst 38h			;1d49	ff		.
	rst 38h			;1d4a	ff		.
	rst 38h			;1d4b	ff		.
	rst 38h			;1d4c	ff		.
	rst 38h			;1d4d	ff		.
	rst 38h			;1d4e	ff		.
	rst 38h			;1d4f	ff		.
	rst 38h			;1d50	ff		.
	rst 38h			;1d51	ff		.
	rst 38h			;1d52	ff		.
	rst 38h			;1d53	ff		.
	rst 38h			;1d54	ff		.
	rst 38h			;1d55	ff		.
	rst 38h			;1d56	ff		.
	rst 38h			;1d57	ff		.
	rst 38h			;1d58	ff		.
	rst 38h			;1d59	ff		.
	rst 38h			;1d5a	ff		.
	rst 38h			;1d5b	ff		.
	rst 38h			;1d5c	ff		.
	rst 38h			;1d5d	ff		.
	rst 38h			;1d5e	ff		.
	rst 38h			;1d5f	ff		.
	rst 38h			;1d60	ff		.
	rst 38h			;1d61	ff		.
	rst 38h			;1d62	ff		.
	rst 38h			;1d63	ff		.
	rst 38h			;1d64	ff		.
	rst 38h			;1d65	ff		.
	rst 38h			;1d66	ff		.
	rst 38h			;1d67	ff		.
	rst 38h			;1d68	ff		.
	rst 38h			;1d69	ff		.
	rst 38h			;1d6a	ff		.
	rst 38h			;1d6b	ff		.
	rst 38h			;1d6c	ff		.
	rst 38h			;1d6d	ff		.
	rst 38h			;1d6e	ff		.
	rst 38h			;1d6f	ff		.
	rst 38h			;1d70	ff		.
	rst 38h			;1d71	ff		.
	rst 38h			;1d72	ff		.
	rst 38h			;1d73	ff		.
	rst 38h			;1d74	ff		.
	rst 38h			;1d75	ff		.
	rst 38h			;1d76	ff		.
	rst 38h			;1d77	ff		.
	rst 38h			;1d78	ff		.
	rst 38h			;1d79	ff		.
	rst 38h			;1d7a	ff		.
	rst 38h			;1d7b	ff		.
	rst 38h			;1d7c	ff		.
	rst 38h			;1d7d	ff		.
	rst 38h			;1d7e	ff		.
	rst 38h			;1d7f	ff		.
	rst 38h			;1d80	ff		.
	rst 38h			;1d81	ff		.
	rst 38h			;1d82	ff		.
	rst 38h			;1d83	ff		.
	rst 38h			;1d84	ff		.
	rst 38h			;1d85	ff		.
	rst 38h			;1d86	ff		.
	rst 38h			;1d87	ff		.
	rst 38h			;1d88	ff		.
	rst 38h			;1d89	ff		.
	rst 38h			;1d8a	ff		.
	rst 38h			;1d8b	ff		.
	rst 38h			;1d8c	ff		.
	rst 38h			;1d8d	ff		.
	rst 38h			;1d8e	ff		.
	rst 38h			;1d8f	ff		.
	rst 38h			;1d90	ff		.
	rst 38h			;1d91	ff		.
	rst 38h			;1d92	ff		.
	rst 38h			;1d93	ff		.
	rst 38h			;1d94	ff		.
	rst 38h			;1d95	ff		.
	rst 38h			;1d96	ff		.
	rst 38h			;1d97	ff		.
	rst 38h			;1d98	ff		.
	rst 38h			;1d99	ff		.
	rst 38h			;1d9a	ff		.
	rst 38h			;1d9b	ff		.
	rst 38h			;1d9c	ff		.
	rst 38h			;1d9d	ff		.
	rst 38h			;1d9e	ff		.
	rst 38h			;1d9f	ff		.
	rst 38h			;1da0	ff		.
	rst 38h			;1da1	ff		.
	rst 38h			;1da2	ff		.
	rst 38h			;1da3	ff		.
	rst 38h			;1da4	ff		.
	rst 38h			;1da5	ff		.
	rst 38h			;1da6	ff		.
	rst 38h			;1da7	ff		.
	rst 38h			;1da8	ff		.
	rst 38h			;1da9	ff		.
	rst 38h			;1daa	ff		.
	rst 38h			;1dab	ff		.
	rst 38h			;1dac	ff		.
	rst 38h			;1dad	ff		.
	rst 38h			;1dae	ff		.
	rst 38h			;1daf	ff		.
	rst 38h			;1db0	ff		.
	rst 38h			;1db1	ff		.
	rst 38h			;1db2	ff		.
	rst 38h			;1db3	ff		.
	rst 38h			;1db4	ff		.
	rst 38h			;1db5	ff		.
	rst 38h			;1db6	ff		.
	rst 38h			;1db7	ff		.
	rst 38h			;1db8	ff		.
	rst 38h			;1db9	ff		.
	rst 38h			;1dba	ff		.
	rst 38h			;1dbb	ff		.
	rst 38h			;1dbc	ff		.
	rst 38h			;1dbd	ff		.
	rst 38h			;1dbe	ff		.
	rst 38h			;1dbf	ff		.
	rst 38h			;1dc0	ff		.
	rst 38h			;1dc1	ff		.
	rst 38h			;1dc2	ff		.
	rst 38h			;1dc3	ff		.
	rst 38h			;1dc4	ff		.
	rst 38h			;1dc5	ff		.
	rst 38h			;1dc6	ff		.
	rst 38h			;1dc7	ff		.
	rst 38h			;1dc8	ff		.
	rst 38h			;1dc9	ff		.
	rst 38h			;1dca	ff		.
	rst 38h			;1dcb	ff		.
	rst 38h			;1dcc	ff		.
	rst 38h			;1dcd	ff		.
	rst 38h			;1dce	ff		.
	rst 38h			;1dcf	ff		.
	rst 38h			;1dd0	ff		.
	rst 38h			;1dd1	ff		.
	rst 38h			;1dd2	ff		.
	rst 38h			;1dd3	ff		.
	rst 38h			;1dd4	ff		.
	rst 38h			;1dd5	ff		.
	rst 38h			;1dd6	ff		.
	rst 38h			;1dd7	ff		.
	rst 38h			;1dd8	ff		.
	rst 38h			;1dd9	ff		.
	rst 38h			;1dda	ff		.
	rst 38h			;1ddb	ff		.
	rst 38h			;1ddc	ff		.
	rst 38h			;1ddd	ff		.
	rst 38h			;1dde	ff		.
	rst 38h			;1ddf	ff		.
	rst 38h			;1de0	ff		.
	rst 38h			;1de1	ff		.
	rst 38h			;1de2	ff		.
	rst 38h			;1de3	ff		.
	rst 38h			;1de4	ff		.
	rst 38h			;1de5	ff		.
	rst 38h			;1de6	ff		.
	rst 38h			;1de7	ff		.
	rst 38h			;1de8	ff		.
	rst 38h			;1de9	ff		.
	rst 38h			;1dea	ff		.
	rst 38h			;1deb	ff		.
	rst 38h			;1dec	ff		.
	rst 38h			;1ded	ff		.
	rst 38h			;1dee	ff		.
	rst 38h			;1def	ff		.
	rst 38h			;1df0	ff		.
	rst 38h			;1df1	ff		.
	rst 38h			;1df2	ff		.
	rst 38h			;1df3	ff		.
	rst 38h			;1df4	ff		.
	rst 38h			;1df5	ff		.
	rst 38h			;1df6	ff		.
	rst 38h			;1df7	ff		.
	rst 38h			;1df8	ff		.
	rst 38h			;1df9	ff		.
	rst 38h			;1dfa	ff		.
	rst 38h			;1dfb	ff		.
	rst 38h			;1dfc	ff		.
	rst 38h			;1dfd	ff		.
	rst 38h			;1dfe	ff		.
	rst 38h			;1dff	ff		.
	rst 38h			;1e00	ff		.
	rst 38h			;1e01	ff		.
	rst 38h			;1e02	ff		.
	rst 38h			;1e03	ff		.
	rst 38h			;1e04	ff		.
	rst 38h			;1e05	ff		.
	rst 38h			;1e06	ff		.
	rst 38h			;1e07	ff		.
	rst 38h			;1e08	ff		.
;  XREF: 4 refs from 0x37E6, 0x37EE, 0x37F2, 0x3806
l1e09h:
	rst 38h			;1e09	ff		.
	rst 38h			;1e0a	ff		.
	rst 38h			;1e0b	ff		.
	rst 38h			;1e0c	ff		.
	rst 38h			;1e0d	ff		.
	rst 38h			;1e0e	ff		.
	rst 38h			;1e0f	ff		.
	rst 38h			;1e10	ff		.
	rst 38h			;1e11	ff		.
	rst 38h			;1e12	ff		.
	rst 38h			;1e13	ff		.
	rst 38h			;1e14	ff		.
	rst 38h			;1e15	ff		.
	rst 38h			;1e16	ff		.
	rst 38h			;1e17	ff		.
	rst 38h			;1e18	ff		.
	rst 38h			;1e19	ff		.
	rst 38h			;1e1a	ff		.
	rst 38h			;1e1b	ff		.
	rst 38h			;1e1c	ff		.
	rst 38h			;1e1d	ff		.
	rst 38h			;1e1e	ff		.
	rst 38h			;1e1f	ff		.
	rst 38h			;1e20	ff		.
	rst 38h			;1e21	ff		.
	rst 38h			;1e22	ff		.
	rst 38h			;1e23	ff		.
	rst 38h			;1e24	ff		.
	rst 38h			;1e25	ff		.
	rst 38h			;1e26	ff		.
	rst 38h			;1e27	ff		.
	rst 38h			;1e28	ff		.
	rst 38h			;1e29	ff		.
	rst 38h			;1e2a	ff		.
	rst 38h			;1e2b	ff		.
	rst 38h			;1e2c	ff		.
	rst 38h			;1e2d	ff		.
	rst 38h			;1e2e	ff		.
	rst 38h			;1e2f	ff		.
	rst 38h			;1e30	ff		.
	rst 38h			;1e31	ff		.
	rst 38h			;1e32	ff		.
	rst 38h			;1e33	ff		.
	rst 38h			;1e34	ff		.
	rst 38h			;1e35	ff		.
	rst 38h			;1e36	ff		.
	rst 38h			;1e37	ff		.
	rst 38h			;1e38	ff		.
	rst 38h			;1e39	ff		.
	rst 38h			;1e3a	ff		.
	rst 38h			;1e3b	ff		.
	rst 38h			;1e3c	ff		.
	rst 38h			;1e3d	ff		.
	rst 38h			;1e3e	ff		.
	rst 38h			;1e3f	ff		.
	rst 38h			;1e40	ff		.
	rst 38h			;1e41	ff		.
	rst 38h			;1e42	ff		.
	rst 38h			;1e43	ff		.
	rst 38h			;1e44	ff		.
	rst 38h			;1e45	ff		.
	rst 38h			;1e46	ff		.
	rst 38h			;1e47	ff		.
	rst 38h			;1e48	ff		.
	rst 38h			;1e49	ff		.
	rst 38h			;1e4a	ff		.
	rst 38h			;1e4b	ff		.
	rst 38h			;1e4c	ff		.
	rst 38h			;1e4d	ff		.
	rst 38h			;1e4e	ff		.
	rst 38h			;1e4f	ff		.
	rst 38h			;1e50	ff		.
	rst 38h			;1e51	ff		.
	rst 38h			;1e52	ff		.
	rst 38h			;1e53	ff		.
	rst 38h			;1e54	ff		.
	rst 38h			;1e55	ff		.
	rst 38h			;1e56	ff		.
	rst 38h			;1e57	ff		.
	rst 38h			;1e58	ff		.
	rst 38h			;1e59	ff		.
	rst 38h			;1e5a	ff		.
	rst 38h			;1e5b	ff		.
	rst 38h			;1e5c	ff		.
	rst 38h			;1e5d	ff		.
	rst 38h			;1e5e	ff		.
	rst 38h			;1e5f	ff		.
	rst 38h			;1e60	ff		.
	rst 38h			;1e61	ff		.
	rst 38h			;1e62	ff		.
	rst 38h			;1e63	ff		.
	rst 38h			;1e64	ff		.
	rst 38h			;1e65	ff		.
	rst 38h			;1e66	ff		.
	rst 38h			;1e67	ff		.
	rst 38h			;1e68	ff		.
	rst 38h			;1e69	ff		.
	rst 38h			;1e6a	ff		.
	rst 38h			;1e6b	ff		.
	rst 38h			;1e6c	ff		.
	rst 38h			;1e6d	ff		.
	rst 38h			;1e6e	ff		.
	rst 38h			;1e6f	ff		.
	rst 38h			;1e70	ff		.
	rst 38h			;1e71	ff		.
	rst 38h			;1e72	ff		.
	rst 38h			;1e73	ff		.
	rst 38h			;1e74	ff		.
	rst 38h			;1e75	ff		.
	rst 38h			;1e76	ff		.
	rst 38h			;1e77	ff		.
	rst 38h			;1e78	ff		.
	rst 38h			;1e79	ff		.
	rst 38h			;1e7a	ff		.
	rst 38h			;1e7b	ff		.
	rst 38h			;1e7c	ff		.
	rst 38h			;1e7d	ff		.
	rst 38h			;1e7e	ff		.
	rst 38h			;1e7f	ff		.
	rst 38h			;1e80	ff		.
	rst 38h			;1e81	ff		.
	rst 38h			;1e82	ff		.
	rst 38h			;1e83	ff		.
	rst 38h			;1e84	ff		.
	rst 38h			;1e85	ff		.
	rst 38h			;1e86	ff		.
	rst 38h			;1e87	ff		.
	rst 38h			;1e88	ff		.
	rst 38h			;1e89	ff		.
	rst 38h			;1e8a	ff		.
	rst 38h			;1e8b	ff		.
	rst 38h			;1e8c	ff		.
	rst 38h			;1e8d	ff		.
	rst 38h			;1e8e	ff		.
	rst 38h			;1e8f	ff		.
	rst 38h			;1e90	ff		.
	rst 38h			;1e91	ff		.
	rst 38h			;1e92	ff		.
	rst 38h			;1e93	ff		.
	rst 38h			;1e94	ff		.
	rst 38h			;1e95	ff		.
	rst 38h			;1e96	ff		.
	rst 38h			;1e97	ff		.
	rst 38h			;1e98	ff		.
	rst 38h			;1e99	ff		.
	rst 38h			;1e9a	ff		.
	rst 38h			;1e9b	ff		.
	rst 38h			;1e9c	ff		.
	rst 38h			;1e9d	ff		.
	rst 38h			;1e9e	ff		.
	rst 38h			;1e9f	ff		.
	rst 38h			;1ea0	ff		.
	rst 38h			;1ea1	ff		.
	rst 38h			;1ea2	ff		.
	rst 38h			;1ea3	ff		.
	rst 38h			;1ea4	ff		.
	rst 38h			;1ea5	ff		.
	rst 38h			;1ea6	ff		.
	rst 38h			;1ea7	ff		.
	rst 38h			;1ea8	ff		.
	rst 38h			;1ea9	ff		.
	rst 38h			;1eaa	ff		.
	rst 38h			;1eab	ff		.
	rst 38h			;1eac	ff		.
	rst 38h			;1ead	ff		.
	rst 38h			;1eae	ff		.
	rst 38h			;1eaf	ff		.
	rst 38h			;1eb0	ff		.
	rst 38h			;1eb1	ff		.
	rst 38h			;1eb2	ff		.
	rst 38h			;1eb3	ff		.
	rst 38h			;1eb4	ff		.
	rst 38h			;1eb5	ff		.
	rst 38h			;1eb6	ff		.
	rst 38h			;1eb7	ff		.
	rst 38h			;1eb8	ff		.
	rst 38h			;1eb9	ff		.
	rst 38h			;1eba	ff		.
	rst 38h			;1ebb	ff		.
	rst 38h			;1ebc	ff		.
	rst 38h			;1ebd	ff		.
	rst 38h			;1ebe	ff		.
	rst 38h			;1ebf	ff		.
	rst 38h			;1ec0	ff		.
	rst 38h			;1ec1	ff		.
	rst 38h			;1ec2	ff		.
	rst 38h			;1ec3	ff		.
	rst 38h			;1ec4	ff		.
	rst 38h			;1ec5	ff		.
	rst 38h			;1ec6	ff		.
	rst 38h			;1ec7	ff		.
	rst 38h			;1ec8	ff		.
	rst 38h			;1ec9	ff		.
	rst 38h			;1eca	ff		.
	rst 38h			;1ecb	ff		.
	rst 38h			;1ecc	ff		.
	rst 38h			;1ecd	ff		.
	rst 38h			;1ece	ff		.
	rst 38h			;1ecf	ff		.
	rst 38h			;1ed0	ff		.
	rst 38h			;1ed1	ff		.
	rst 38h			;1ed2	ff		.
	rst 38h			;1ed3	ff		.
	rst 38h			;1ed4	ff		.
	rst 38h			;1ed5	ff		.
	rst 38h			;1ed6	ff		.
	rst 38h			;1ed7	ff		.
	rst 38h			;1ed8	ff		.
	rst 38h			;1ed9	ff		.
	rst 38h			;1eda	ff		.
	rst 38h			;1edb	ff		.
	rst 38h			;1edc	ff		.
	rst 38h			;1edd	ff		.
	rst 38h			;1ede	ff		.
	rst 38h			;1edf	ff		.
	rst 38h			;1ee0	ff		.
	rst 38h			;1ee1	ff		.
	rst 38h			;1ee2	ff		.
	rst 38h			;1ee3	ff		.
	rst 38h			;1ee4	ff		.
	rst 38h			;1ee5	ff		.
	rst 38h			;1ee6	ff		.
	rst 38h			;1ee7	ff		.
	rst 38h			;1ee8	ff		.
	rst 38h			;1ee9	ff		.
	rst 38h			;1eea	ff		.
	rst 38h			;1eeb	ff		.
	rst 38h			;1eec	ff		.
	rst 38h			;1eed	ff		.
	rst 38h			;1eee	ff		.
	rst 38h			;1eef	ff		.
	rst 38h			;1ef0	ff		.
	rst 38h			;1ef1	ff		.
	rst 38h			;1ef2	ff		.
	rst 38h			;1ef3	ff		.
	rst 38h			;1ef4	ff		.
	rst 38h			;1ef5	ff		.
	rst 38h			;1ef6	ff		.
	rst 38h			;1ef7	ff		.
	rst 38h			;1ef8	ff		.
	rst 38h			;1ef9	ff		.
	rst 38h			;1efa	ff		.
	rst 38h			;1efb	ff		.
	rst 38h			;1efc	ff		.
	rst 38h			;1efd	ff		.
	rst 38h			;1efe	ff		.
	rst 38h			;1eff	ff		.
	rst 38h			;1f00	ff		.
	rst 38h			;1f01	ff		.
	rst 38h			;1f02	ff		.
	rst 38h			;1f03	ff		.
	rst 38h			;1f04	ff		.
	rst 38h			;1f05	ff		.
	rst 38h			;1f06	ff		.
	rst 38h			;1f07	ff		.
	rst 38h			;1f08	ff		.
	rst 38h			;1f09	ff		.
	rst 38h			;1f0a	ff		.
	rst 38h			;1f0b	ff		.
	rst 38h			;1f0c	ff		.
	rst 38h			;1f0d	ff		.
	rst 38h			;1f0e	ff		.
	rst 38h			;1f0f	ff		.
	rst 38h			;1f10	ff		.
	rst 38h			;1f11	ff		.
	rst 38h			;1f12	ff		.
	rst 38h			;1f13	ff		.
	rst 38h			;1f14	ff		.
	rst 38h			;1f15	ff		.
	rst 38h			;1f16	ff		.
	rst 38h			;1f17	ff		.
	rst 38h			;1f18	ff		.
	rst 38h			;1f19	ff		.
	rst 38h			;1f1a	ff		.
	rst 38h			;1f1b	ff		.
	rst 38h			;1f1c	ff		.
	rst 38h			;1f1d	ff		.
	rst 38h			;1f1e	ff		.
	rst 38h			;1f1f	ff		.
	rst 38h			;1f20	ff		.
	rst 38h			;1f21	ff		.
	rst 38h			;1f22	ff		.
	rst 38h			;1f23	ff		.
	rst 38h			;1f24	ff		.
	rst 38h			;1f25	ff		.
	rst 38h			;1f26	ff		.
	rst 38h			;1f27	ff		.
	rst 38h			;1f28	ff		.
	rst 38h			;1f29	ff		.
	rst 38h			;1f2a	ff		.
	rst 38h			;1f2b	ff		.
	rst 38h			;1f2c	ff		.
	rst 38h			;1f2d	ff		.
	rst 38h			;1f2e	ff		.
	rst 38h			;1f2f	ff		.
	rst 38h			;1f30	ff		.
	rst 38h			;1f31	ff		.
	rst 38h			;1f32	ff		.
	rst 38h			;1f33	ff		.
	rst 38h			;1f34	ff		.
	rst 38h			;1f35	ff		.
	rst 38h			;1f36	ff		.
	rst 38h			;1f37	ff		.
	rst 38h			;1f38	ff		.
	rst 38h			;1f39	ff		.
	rst 38h			;1f3a	ff		.
	rst 38h			;1f3b	ff		.
	rst 38h			;1f3c	ff		.
	rst 38h			;1f3d	ff		.
	rst 38h			;1f3e	ff		.
	rst 38h			;1f3f	ff		.
	rst 38h			;1f40	ff		.
	rst 38h			;1f41	ff		.
	rst 38h			;1f42	ff		.
	rst 38h			;1f43	ff		.
	rst 38h			;1f44	ff		.
	rst 38h			;1f45	ff		.
	rst 38h			;1f46	ff		.
	rst 38h			;1f47	ff		.
	rst 38h			;1f48	ff		.
	rst 38h			;1f49	ff		.
	rst 38h			;1f4a	ff		.
	rst 38h			;1f4b	ff		.
	rst 38h			;1f4c	ff		.
	rst 38h			;1f4d	ff		.
	rst 38h			;1f4e	ff		.
	rst 38h			;1f4f	ff		.
	rst 38h			;1f50	ff		.
	rst 38h			;1f51	ff		.
	rst 38h			;1f52	ff		.
	rst 38h			;1f53	ff		.
	rst 38h			;1f54	ff		.
	rst 38h			;1f55	ff		.
	rst 38h			;1f56	ff		.
	rst 38h			;1f57	ff		.
	rst 38h			;1f58	ff		.
	rst 38h			;1f59	ff		.
	rst 38h			;1f5a	ff		.
	rst 38h			;1f5b	ff		.
	rst 38h			;1f5c	ff		.
	rst 38h			;1f5d	ff		.
	rst 38h			;1f5e	ff		.
	rst 38h			;1f5f	ff		.
	rst 38h			;1f60	ff		.
	rst 38h			;1f61	ff		.
	rst 38h			;1f62	ff		.
	rst 38h			;1f63	ff		.
	rst 38h			;1f64	ff		.
	rst 38h			;1f65	ff		.
	rst 38h			;1f66	ff		.
	rst 38h			;1f67	ff		.
	rst 38h			;1f68	ff		.
	rst 38h			;1f69	ff		.
	rst 38h			;1f6a	ff		.
	rst 38h			;1f6b	ff		.
	rst 38h			;1f6c	ff		.
	rst 38h			;1f6d	ff		.
	rst 38h			;1f6e	ff		.
	rst 38h			;1f6f	ff		.
	rst 38h			;1f70	ff		.
	rst 38h			;1f71	ff		.
	rst 38h			;1f72	ff		.
	rst 38h			;1f73	ff		.
	rst 38h			;1f74	ff		.
	rst 38h			;1f75	ff		.
	rst 38h			;1f76	ff		.
	rst 38h			;1f77	ff		.
	rst 38h			;1f78	ff		.
	rst 38h			;1f79	ff		.
	rst 38h			;1f7a	ff		.
	rst 38h			;1f7b	ff		.
	rst 38h			;1f7c	ff		.
	rst 38h			;1f7d	ff		.
	rst 38h			;1f7e	ff		.
	rst 38h			;1f7f	ff		.
	rst 38h			;1f80	ff		.
	rst 38h			;1f81	ff		.
	rst 38h			;1f82	ff		.
	rst 38h			;1f83	ff		.
	rst 38h			;1f84	ff		.
	rst 38h			;1f85	ff		.
	rst 38h			;1f86	ff		.
	rst 38h			;1f87	ff		.
	rst 38h			;1f88	ff		.
	rst 38h			;1f89	ff		.
	rst 38h			;1f8a	ff		.
	rst 38h			;1f8b	ff		.
	rst 38h			;1f8c	ff		.
	rst 38h			;1f8d	ff		.
	rst 38h			;1f8e	ff		.
	rst 38h			;1f8f	ff		.
	rst 38h			;1f90	ff		.
	rst 38h			;1f91	ff		.
	rst 38h			;1f92	ff		.
	rst 38h			;1f93	ff		.
	rst 38h			;1f94	ff		.
	rst 38h			;1f95	ff		.
	rst 38h			;1f96	ff		.
	rst 38h			;1f97	ff		.
	rst 38h			;1f98	ff		.
	rst 38h			;1f99	ff		.
	rst 38h			;1f9a	ff		.
	rst 38h			;1f9b	ff		.
	rst 38h			;1f9c	ff		.
	rst 38h			;1f9d	ff		.
	rst 38h			;1f9e	ff		.
	rst 38h			;1f9f	ff		.
	rst 38h			;1fa0	ff		.
	rst 38h			;1fa1	ff		.
	rst 38h			;1fa2	ff		.
	rst 38h			;1fa3	ff		.
	rst 38h			;1fa4	ff		.
	rst 38h			;1fa5	ff		.
	rst 38h			;1fa6	ff		.
	rst 38h			;1fa7	ff		.
	rst 38h			;1fa8	ff		.
	rst 38h			;1fa9	ff		.
	rst 38h			;1faa	ff		.
	rst 38h			;1fab	ff		.
	rst 38h			;1fac	ff		.
	rst 38h			;1fad	ff		.
	rst 38h			;1fae	ff		.
	rst 38h			;1faf	ff		.
	rst 38h			;1fb0	ff		.
	rst 38h			;1fb1	ff		.
	rst 38h			;1fb2	ff		.
	rst 38h			;1fb3	ff		.
	rst 38h			;1fb4	ff		.
	rst 38h			;1fb5	ff		.
	rst 38h			;1fb6	ff		.
	rst 38h			;1fb7	ff		.
	rst 38h			;1fb8	ff		.
	rst 38h			;1fb9	ff		.
	rst 38h			;1fba	ff		.
	rst 38h			;1fbb	ff		.
	rst 38h			;1fbc	ff		.
	rst 38h			;1fbd	ff		.
	rst 38h			;1fbe	ff		.
	rst 38h			;1fbf	ff		.
	rst 38h			;1fc0	ff		.
	rst 38h			;1fc1	ff		.
	rst 38h			;1fc2	ff		.
	rst 38h			;1fc3	ff		.
	rst 38h			;1fc4	ff		.
	rst 38h			;1fc5	ff		.
	rst 38h			;1fc6	ff		.
	rst 38h			;1fc7	ff		.
	rst 38h			;1fc8	ff		.
	rst 38h			;1fc9	ff		.
	rst 38h			;1fca	ff		.
	rst 38h			;1fcb	ff		.
	rst 38h			;1fcc	ff		.
	rst 38h			;1fcd	ff		.
	rst 38h			;1fce	ff		.
	rst 38h			;1fcf	ff		.
	rst 38h			;1fd0	ff		.
	rst 38h			;1fd1	ff		.
	rst 38h			;1fd2	ff		.
	rst 38h			;1fd3	ff		.
	rst 38h			;1fd4	ff		.
	rst 38h			;1fd5	ff		.
	rst 38h			;1fd6	ff		.
	rst 38h			;1fd7	ff		.
	rst 38h			;1fd8	ff		.
	rst 38h			;1fd9	ff		.
	rst 38h			;1fda	ff		.
	rst 38h			;1fdb	ff		.
	rst 38h			;1fdc	ff		.
	rst 38h			;1fdd	ff		.
	rst 38h			;1fde	ff		.
	rst 38h			;1fdf	ff		.
	rst 38h			;1fe0	ff		.
	rst 38h			;1fe1	ff		.
	rst 38h			;1fe2	ff		.
	rst 38h			;1fe3	ff		.
	rst 38h			;1fe4	ff		.
	rst 38h			;1fe5	ff		.
	rst 38h			;1fe6	ff		.
	rst 38h			;1fe7	ff		.
	rst 38h			;1fe8	ff		.
	rst 38h			;1fe9	ff		.
	rst 38h			;1fea	ff		.
	rst 38h			;1feb	ff		.
	rst 38h			;1fec	ff		.
	rst 38h			;1fed	ff		.
	rst 38h			;1fee	ff		.
	rst 38h			;1fef	ff		.
	rst 38h			;1ff0	ff		.
	rst 38h			;1ff1	ff		.
	rst 38h			;1ff2	ff		.
	rst 38h			;1ff3	ff		.
	rst 38h			;1ff4	ff		.
	rst 38h			;1ff5	ff		.
	rst 38h			;1ff6	ff		.
	rst 38h			;1ff7	ff		.
	rst 38h			;1ff8	ff		.
	rst 38h			;1ff9	ff		.
	rst 38h			;1ffa	ff		.
	rst 38h			;1ffb	ff		.
	rst 38h			;1ffc	ff		.
	rst 38h			;1ffd	ff		.
	rst 38h			;1ffe	ff		.
	rst 38h			;1fff	ff		.

; =============================================================================
; SWITCH DISPATCH & HANDLERS
; =============================================================================

; ─────────────────────────────────────────────────────────────────────────────
; switch_dispatch_table (0x2000)
; DATA: 128-entry jump table (switch_id × 2 → handler addr)
; ─────────────────────────────────────────────────────────────────────────────
switch_dispatch_table:
	nop			;2000	00		.
	ld (l21ffh+2),hl	;2001	22 01 22	" . "
	inc c			;2004	0c		.
	ld (l2217h),hl		;2005	22 17 22	" . "
	ld (l2d22h),hl		;2008	22 22 2d	" " -
	ld (l2238h),hl		;200b	22 38 22	" 8 "
	ld b,e			;200e	43		C
	ld (l224eh),hl		;200f	22 4e 22	" N "
	ld e,c			;2012	59		Y
	ld (l2264h),hl		;2013	22 64 22	" d "
	ld l,a			;2016	6f		o
	ld (l227ah),hl		;2017	22 7a 22	" z "
	add a,l			;201a	85		.
	ld (l2290h),hl		;201b	22 90 22	" . "
	sbc a,e			;201e	9b		.
	ld (l22a6h),hl		;201f	22 a6 22	" . "
	or c			;2022	b1		.
	ld (l22bch),hl		;2023	22 bc 22	" . "
	ld b,l			;2026	45		E
	daa			;2027	27		'
	ld d,b			;2028	50		P
	daa			;2029	27		'
	ld e,e			;202a	5b		[
	daa			;202b	27		'
	ld h,(hl)		;202c	66		f
	daa			;202d	27		'
	rst 0			;202e	c7		.
	ld (l22cdh),hl		;202f	22 cd 22	" . "
	ret c			;2032	d8		.
	ld (l22deh),hl		;2033	22 de 22	" . "
	jp (hl)			;2036	e9		.
	ld (l22efh),hl		;2037	22 ef 22	" . "
	jp m,l0022h		;203a	fa 22 00	. " .
	inc hl			;203d	23		#
	dec bc			;203e	0b		.
	inc hl			;203f	23		#
	ld de,l1c23h		;2040	11 23 1c	. # .
	inc hl			;2043	23		#
	ld (l2d22h+1),hl	;2044	22 23 2d	" # -
	inc hl			;2047	23		#
	ld a,023h		;2048	3e 23		> #
	ld e,d			;204a	5a		Z
	inc hl			;204b	23		#
	ld h,b			;204c	60		`
	inc hl			;204d	23		#
	ld c,a			;204e	4f		O
	inc hl			;204f	23		#
	nop			;2050	00		.
	ld (l2376h),hl		;2051	22 76 23	" v #
	ld a,h			;2054	7c		|
	inc hl			;2055	23		#
	ld l,e			;2056	6b		k
	inc hl			;2057	23		#
	nop			;2058	00		.
	ld (l2392h),hl		;2059	22 92 23	" . #
	sbc a,b			;205c	98		.
	inc hl			;205d	23		#
	add a,a			;205e	87		.
	inc hl			;205f	23		#
	nop			;2060	00		.
	ld (l23aeh),hl		;2061	22 ae 23	" . #
	or h			;2064	b4		.
	inc hl			;2065	23		#
	and e			;2066	a3		.
	inc hl			;2067	23		#
	nop			;2068	00		.
	ld (l23cah),hl		;2069	22 ca 23	" . #
	ret nc			;206c	d0		.
	inc hl			;206d	23		#
	cp a			;206e	bf		.
	inc hl			;206f	23		#
	nop			;2070	00		.
	ld (l23dbh),hl		;2071	22 db 23	" . #
	and 023h		;2074	e6 23		. #
	ld (hl),c		;2076	71		q
	daa			;2077	27		'
	ld a,h			;2078	7c		|
	daa			;2079	27		'
	add a,a			;207a	87		.
	daa			;207b	27		'
	sub d			;207c	92		.
	daa			;207d	27		'
	pop af			;207e	f1		.
	inc hl			;207f	23		#
	call m,sub_0723h	;2080	fc 23 07	. # .
	inc h			;2083	24		$
	ld (de),a		;2084	12		.
	inc h			;2085	24		$
	sbc a,l			;2086	9d		.
	daa			;2087	27		'
	xor b			;2088	a8		.
	daa			;2089	27		'
	nop			;208a	00		.
	ld (l21ffh+1),hl	;208b	22 00 22	" . "
	dec e			;208e	1d		.
	inc h			;208f	24		$
	jr z,l20b6h		;2090	28 24		( $
	inc sp			;2092	33		3
	inc h			;2093	24		$
	ld a,024h		;2094	3e 24		> $
	ld c,c			;2096	49		I
	inc h			;2097	24		$
	ld d,h			;2098	54		T
	inc h			;2099	24		$
	ld e,a			;209a	5f		_
	inc h			;209b	24		$
	ld l,d			;209c	6a		j
	inc h			;209d	24		$
	nop			;209e	00		.
	ld (l21ffh+1),hl	;209f	22 00 22	" . "
	nop			;20a2	00		.
	ld (l21ffh+1),hl	;20a3	22 00 22	" . "
	ld (hl),l		;20a6	75		u
	inc h			;20a7	24		$
	add a,b			;20a8	80		.
	inc h			;20a9	24		$
	adc a,e			;20aa	8b		.
	inc h			;20ab	24		$
	sub (hl)		;20ac	96		.
	inc h			;20ad	24		$
	and c			;20ae	a1		.
	inc h			;20af	24		$
	xor h			;20b0	ac		.
	inc h			;20b1	24		$
	nop			;20b2	00		.
	ld (l21ffh+1),hl	;20b3	22 00 22	" . "
l20b6h:
	nop			;20b6	00		.
	ld (l21ffh+1),hl	;20b7	22 00 22	" . "
	or a			;20ba	b7		.
	inc h			;20bb	24		$
	rst 0			;20bc	c7		.
	inc h			;20bd	24		$
	sub 024h		;20be	d6 24		. $
	call c,0e724h		;20c0	dc 24 e7	. $ .
	inc h			;20c3	24		$
	defb 0edh ;next byte illegal after ed	;20c4	ed		.
	inc h			;20c5	24		$
	ret m			;20c6	f8		.
	inc h			;20c7	24		$
	cp 024h			;20c8	fe 24		. $
	add hl,bc		;20ca	09		.
	dec h			;20cb	25		%
	rrca			;20cc	0f		.
	dec h			;20cd	25		%
	ld a,(de)		;20ce	1a		.
	dec h			;20cf	25		%
	jr nz,l20f7h		;20d0	20 25		  %
	dec hl			;20d2	2b		+
	dec h			;20d3	25		%
	ld (hl),025h		;20d4	36 25		6 %
	ld b,c			;20d6	41		A
	dec h			;20d7	25		%
	ld b,a			;20d8	47		G
	dec h			;20d9	25		%
	ld d,d			;20da	52		R
	dec h			;20db	25		%
	ld e,l			;20dc	5d		]
	dec h			;20dd	25		%
	ld l,b			;20de	68		h
	dec h			;20df	25		%
	ld l,(hl)		;20e0	6e		n
	dec h			;20e1	25		%
	ld a,c			;20e2	79		y
	dec h			;20e3	25		%
	add a,h			;20e4	84		.
	dec h			;20e5	25		%
	adc a,a			;20e6	8f		.
	dec h			;20e7	25		%
	sbc a,d			;20e8	9a		.
	dec h			;20e9	25		%
	nop			;20ea	00		.
	ld (l21ffh+1),hl	;20eb	22 00 22	" . "
	and l			;20ee	a5		.
	dec h			;20ef	25		%
	xor e			;20f0	ab		.
	dec h			;20f1	25		%
	or (hl)			;20f2	b6		.
	dec h			;20f3	25		%
	cp h			;20f4	bc		.
	dec h			;20f5	25		%
	rst 0			;20f6	c7		.
l20f7h:
	dec h			;20f7	25		%
	call 0d825h		;20f8	cd 25 d8	. % .
	dec h			;20fb	25		%
	sbc a,025h		;20fc	de 25		. %
	jp (hl)			;20fe	e9		.
	dec h			;20ff	25		%
	rst 28h			;2100	ef		.
	dec h			;2101	25		%
	jp m,l0025h		;2102	fa 25 00	. % .
	ld h,00bh		;2105	26 0b		& .
	ld h,011h		;2107	26 11		& .
	ld h,01ch		;2109	26 1c		& .
	ld h,022h		;210b	26 22		& "
	ld h,02dh		;210d	26 2d		& -
	ld h,033h		;210f	26 33		& 3
	ld h,03eh		;2111	26 3e		& >
	ld h,044h		;2113	26 44		& D
	ld h,04fh		;2115	26 4f		& O
	ld h,05eh		;2117	26 5e		& ^
	ld h,079h		;2119	26 79		& y
	ld h,07fh		;211b	26 7f		& .
l211dh:
	ld h,08ah		;211d	26 8a		& .
	ld h,090h		;211f	26 90		& .
	ld h,09bh		;2121	26 9b		& .
	ld h,0a1h		;2123	26 a1		& .
l2125h:
	ld h,0ach		;2125	26 ac		& .
	ld h,0b2h		;2127	26 b2		& .
	ld h,0bdh		;2129	26 bd		& .
	ld h,0c3h		;212b	26 c3		& .
	ld h,0ceh		;212d	26 ce		& .
	ld h,0d4h		;212f	26 d4		& .
	ld h,0dfh		;2131	26 df		& .
	ld h,0e5h		;2133	26 e5		& .
	ld h,0f0h		;2135	26 f0		& .
	ld h,0f6h		;2137	26 f6		& .
	ld h,001h		;2139	26 01		& .
	daa			;213b	27		'
	rlca			;213c	07		.
	daa			;213d	27		'
	ld (de),a		;213e	12		.
	daa			;213f	27		'
	jr l2169h		;2140	18 27		. '
	inc hl			;2142	23		#
	daa			;2143	27		'
	add hl,hl		;2144	29		)
	daa			;2145	27		'
	inc (hl)		;2146	34		4
	daa			;2147	27		'
	ld a,(l5c27h)		;2148	3a 27 5c	: ' \
	dec l			;214b	2d		-
	nop			;214c	00		.
	ld (l21ffh+1),hl	;214d	22 00 22	" . "
	nop			;2150	00		.
	ld (l27b3h),hl		;2151	22 b3 27	" . '
	ret nz			;2154	c0		.
	daa			;2155	27		'
	defb 0edh ;next byte illegal after ed	;2156	ed		.
	daa			;2157	27		'
	inc (hl)		;2158	34		4
	dec (hl)		;2159	35		5
	jp pe,00535h		;215a	ea 35 05	. 5 .
	ld (hl),020h		;215d	36 20		6  
	ld (hl),03bh		;215f	36 3b		6 ;
	ld (hl),056h		;2161	36 56		6 V
	ld (hl),071h		;2163	36 71		6 q
	ld (hl),08ch		;2165	36 8c		6 .
	ld (hl),0a7h		;2167	36 a7		6 .
l2169h:
	ld (hl),0c2h		;2169	36 c2		6 .
	ld (hl),0ddh		;216b	36 dd		6 .
	ld (hl),0f8h		;216d	36 f8		6 .
	ld (hl),0a2h		;216f	36 a2		6 .
	add hl,bc		;2171	09		.
	cp e			;2172	bb		.
	add hl,bc		;2173	09		.
	call nc,sub_3609h	;2174	d4 09 36	. . 6
	ld a,(bc)		;2177	0a		.
	ld a,00ah		;2178	3e 0a		> .
	cpl			;217a	2f		/
	jr z,l21adh		;217b	28 30		( 0
	jr z,l21b6h		;217d	28 37		( 7
	djnz $-9		;217f	10 f5		. .
	ld de,l21ffh+1		;2181	11 00 22	. . "
	nop			;2184	00		.
	ld (sub_2831h),hl	;2185	22 31 28	" 1 (
	ld d,c			;2188	51		Q
	jr z,l21ffh		;2189	28 74		( t
	jr z,$+124		;218b	28 7a		( z
	jr z,$+129		;218d	28 7f		( .
	jr z,$-121		;218f	28 85		( .
	jr z,l211dh		;2191	28 8a		( .
	jr z,l2125h		;2193	28 90		( .
	jr z,$-105		;2195	28 95		( .
	jr z,$-39		;2197	28 d7		( .
	jr z,l21b4h		;2199	28 19		( .
	add hl,hl		;219b	29		)
	ld (l2b27h+2),hl	;219c	22 29 2b	" ) +
	add hl,hl		;219f	29		)
	inc (hl)		;21a0	34		4
	add hl,hl		;21a1	29		)
	dec a			;21a2	3d		=
	add hl,hl		;21a3	29		)
	sub c			;21a4	91		.
	add hl,hl		;21a5	29		)
	ld a,a			;21a6	7f		.
	add hl,hl		;21a7	29		)
	adc a,b			;21a8	88		.
	add hl,hl		;21a9	29		)
	sbc a,h			;21aa	9c		.
	add hl,hl		;21ab	29		)
	sbc a,l			;21ac	9d		.
l21adh:
	add hl,hl		;21ad	29		)
	sbc a,(hl)		;21ae	9e		.
	add hl,hl		;21af	29		)
	or d			;21b0	b2		.
	add hl,hl		;21b1	29		)
	cp e			;21b2	bb		.
	add hl,hl		;21b3	29		)
l21b4h:
	cp a			;21b4	bf		.
	add hl,hl		;21b5	29		)
l21b6h:
	jp 0e129h		;21b6	c3 29 e1	. ) .
	add hl,hl		;21b9	29		)
	ret m			;21ba	f8		.
	add hl,hl		;21bb	29		)
	call m,sub_0029h	;21bc	fc 29 00	. ) .
	ld hl,(l2a04h)		;21bf	2a 04 2a	* . *
	ex af,af		;21c2	08		.
	ld hl,(l2a0ch)		;21c3	2a 0c 2a	* . *
	djnz l21f2h		;21c6	10 2a		. *
	dec e			;21c8	1d		.
l21c9h:
	ld hl,(l2a34h)		;21c9	2a 34 2a	* 4 *
	dec (hl)		;21cc	35		5
	ld hl,(l2a36h)		;21cd	2a 36 2a	* 6 *
	sub a			;21d0	97		.
	add hl,hl		;21d1	29		)
	inc bc			;21d2	03		.
	dec hl			;21d3	2b		+
	ld b,l			;21d4	45		E
	ld hl,(l2ab0h)		;21d5	2a b0 2a	* . *
	add a,a			;21d8	87		.
	inc l			;21d9	2c		,
	ex de,hl		;21da	eb		.
	dec hl			;21db	2b		+
	add a,(hl)		;21dc	86		.
	dec hl			;21dd	2b		+
	rst 0			;21de	c7		.
	dec hl			;21df	2b		+
	nop			;21e0	00		.
	ld (l2a22h),hl		;21e1	22 22 2a	" " *
	cpl			;21e4	2f		/
	ld hl,(l2a3ah)		;21e5	2a 3a 2a	* : *
	ld b,b			;21e8	40		@
	ld hl,(l2d8ch)		;21e9	2a 8c 2d	* . -
	sub a			;21ec	97		.
	dec l			;21ed	2d		-
	call nz,0d92dh		;21ee	c4 2d d9	. - .
	dec l			;21f1	2d		-
l21f2h:
	sbc a,l			;21f2	9d		.
	dec l			;21f3	2d		-
	and a			;21f4	a7		.
	dec l			;21f5	2d		-
	jp l002dh		;21f6	c3 2d 00	. - .
	ld (l27cdh),hl		;21f9	22 cd 27	" . '
	out (027h),a		;21fc	d3 27		. '
	nop			;21fe	00		.
l21ffh:
	ld (l21c9h),hl		;21ff	22 c9 21	" . !
	dec bc			;2202	0b		.
	pop bc			;2203	c1		.
	res 7,(hl)		;2204	cb be		. .
	ld hl,0c103h		;2206	21 03 c1	! . .
	set 7,(hl)		;2209	cb fe		. .
	ret			;220b	c9		.
	ld hl,0c10bh		;220c	21 0b c1	! . .
	set 7,(hl)		;220f	cb fe		. .
	ld hl,0c103h		;2211	21 03 c1	! . .
	res 7,(hl)		;2214	cb be		. .
	ret			;2216	c9		.
l2217h:
	ld hl,0c10bh		;2217	21 0b c1	! . .
	res 6,(hl)		;221a	cb b6		. .
	ld hl,0c103h		;221c	21 03 c1	! . .
	set 6,(hl)		;221f	cb f6		. .
	ret			;2221	c9		.
	ld hl,0c10bh		;2222	21 0b c1	! . .
	set 6,(hl)		;2225	cb f6		. .
	ld hl,0c103h		;2227	21 03 c1	! . .
	res 6,(hl)		;222a	cb b6		. .
	ret			;222c	c9		.
sub_222dh:
	ld hl,0c10bh		;222d	21 0b c1	! . .
	res 5,(hl)		;2230	cb ae		. .
	ld hl,0c103h		;2232	21 03 c1	! . .
	set 5,(hl)		;2235	cb ee		. .
	ret			;2237	c9		.
l2238h:
	ld hl,0c10bh		;2238	21 0b c1	! . .
	set 5,(hl)		;223b	cb ee		. .
	ld hl,0c103h		;223d	21 03 c1	! . .
	res 5,(hl)		;2240	cb ae		. .
	ret			;2242	c9		.
sub_2243h:
	ld hl,0c10eh		;2243	21 0e c1	! . .
	res 5,(hl)		;2246	cb ae		. .
	ld hl,0c106h		;2248	21 06 c1	! . .
	set 5,(hl)		;224b	cb ee		. .
	ret			;224d	c9		.
l224eh:
	ld hl,0c10eh		;224e	21 0e c1	! . .
	set 5,(hl)		;2251	cb ee		. .
	ld hl,0c106h		;2253	21 06 c1	! . .
	res 5,(hl)		;2256	cb ae		. .
	ret			;2258	c9		.
	ld hl,0c10eh		;2259	21 0e c1	! . .
	res 6,(hl)		;225c	cb b6		. .
	ld hl,0c106h		;225e	21 06 c1	! . .
	set 6,(hl)		;2261	cb f6		. .
	ret			;2263	c9		.
l2264h:
	ld hl,0c10eh		;2264	21 0e c1	! . .
	set 6,(hl)		;2267	cb f6		. .
	ld hl,0c106h		;2269	21 06 c1	! . .
	res 6,(hl)		;226c	cb b6		. .
	ret			;226e	c9		.
	ld hl,0c10ch		;226f	21 0c c1	! . .
	res 4,(hl)		;2272	cb a6		. .
	ld hl,0c104h		;2274	21 04 c1	! . .
	set 4,(hl)		;2277	cb e6		. .
	ret			;2279	c9		.
l227ah:
	ld hl,0c10ch		;227a	21 0c c1	! . .
	set 4,(hl)		;227d	cb e6		. .
	ld hl,0c104h		;227f	21 04 c1	! . .
	res 4,(hl)		;2282	cb a6		. .
	ret			;2284	c9		.
	ld hl,0c10ch		;2285	21 0c c1	! . .
	res 5,(hl)		;2288	cb ae		. .
	ld hl,0c104h		;228a	21 04 c1	! . .
	set 5,(hl)		;228d	cb ee		. .
	ret			;228f	c9		.
l2290h:
	ld hl,0c10ch		;2290	21 0c c1	! . .
	set 5,(hl)		;2293	cb ee		. .
	ld hl,0c104h		;2295	21 04 c1	! . .
	res 5,(hl)		;2298	cb ae		. .
	ret			;229a	c9		.
	ld hl,0c10ch		;229b	21 0c c1	! . .
	res 6,(hl)		;229e	cb b6		. .
	ld hl,0c104h		;22a0	21 04 c1	! . .
	set 6,(hl)		;22a3	cb f6		. .
	ret			;22a5	c9		.
l22a6h:
	ld hl,0c10ch		;22a6	21 0c c1	! . .
	set 6,(hl)		;22a9	cb f6		. .
	ld hl,0c104h		;22ab	21 04 c1	! . .
	res 6,(hl)		;22ae	cb b6		. .
	ret			;22b0	c9		.
	ld hl,0c109h		;22b1	21 09 c1	! . .
	res 7,(hl)		;22b4	cb be		. .
	ld hl,0c101h		;22b6	21 01 c1	! . .
	set 7,(hl)		;22b9	cb fe		. .
	ret			;22bb	c9		.
l22bch:
	ld hl,0c109h		;22bc	21 09 c1	! . .
	set 7,(hl)		;22bf	cb fe		. .
	ld hl,0c101h		;22c1	21 01 c1	! . .
	res 7,(hl)		;22c4	cb be		. .
	ret			;22c6	c9		.
	ld hl,0c101h		;22c7	21 01 c1	! . .
	set 0,(hl)		;22ca	cb c6		. .
	ret			;22cc	c9		.
l22cdh:
	ld hl,0c109h		;22cd	21 09 c1	! . .
	set 0,(hl)		;22d0	cb c6		. .
	ld hl,0c101h		;22d2	21 01 c1	! . .
	res 0,(hl)		;22d5	cb 86		. .
	ret			;22d7	c9		.
	ld hl,0c101h		;22d8	21 01 c1	! . .
	set 1,(hl)		;22db	cb ce		. .
	ret			;22dd	c9		.
l22deh:
	ld hl,0c109h		;22de	21 09 c1	! . .
	set 1,(hl)		;22e1	cb ce		. .
	ld hl,0c101h		;22e3	21 01 c1	! . .
	res 1,(hl)		;22e6	cb 8e		. .
	ret			;22e8	c9		.
	ld hl,0c101h		;22e9	21 01 c1	! . .
	set 2,(hl)		;22ec	cb d6		. .
	ret			;22ee	c9		.
l22efh:
	ld hl,0c109h		;22ef	21 09 c1	! . .
	set 2,(hl)		;22f2	cb d6		. .
	ld hl,0c101h		;22f4	21 01 c1	! . .
	res 2,(hl)		;22f7	cb 96		. .
	ret			;22f9	c9		.
	ld hl,0c101h		;22fa	21 01 c1	! . .
	set 3,(hl)		;22fd	cb de		. .
	ret			;22ff	c9		.
	ld hl,0c109h		;2300	21 09 c1	! . .
	set 3,(hl)		;2303	cb de		. .
	ld hl,0c101h		;2305	21 01 c1	! . .
	res 3,(hl)		;2308	cb 9e		. .
	ret			;230a	c9		.
	ld hl,0c101h		;230b	21 01 c1	! . .
	set 4,(hl)		;230e	cb e6		. .
	ret			;2310	c9		.
	ld hl,0c109h		;2311	21 09 c1	! . .
	set 4,(hl)		;2314	cb e6		. .
	ld hl,0c101h		;2316	21 01 c1	! . .
	res 4,(hl)		;2319	cb a6		. .
	ret			;231b	c9		.
	ld hl,0c101h		;231c	21 01 c1	! . .
	set 5,(hl)		;231f	cb ee		. .
	ret			;2321	c9		.
	ld hl,0c109h		;2322	21 09 c1	! . .
	set 5,(hl)		;2325	cb ee		. .
	ld hl,0c101h		;2327	21 01 c1	! . .
	res 5,(hl)		;232a	cb ae		. .
	ret			;232c	c9		.
	ld a,(0c109h)		;232d	3a 09 c1	: . .
	and 0c0h		;2330	e6 c0		. .
	ld (0c109h),a		;2332	32 09 c1	2 . .
	ld a,(0c101h)		;2335	3a 01 c1	: . .
	or 03fh			;2338	f6 3f		. ?
	ld (0c101h),a		;233a	32 01 c1	2 . .
	ret			;233d	c9		.
	ld a,(0c109h)		;233e	3a 09 c1	: . .
	or 03fh			;2341	f6 3f		. ?
	ld (0c109h),a		;2343	32 09 c1	2 . .
	ld a,(0c101h)		;2346	3a 01 c1	: . .
	and 0c0h		;2349	e6 c0		. .
	ld (0c101h),a		;234b	32 01 c1	2 . .
	ret			;234e	c9		.
	ld hl,0c10dh		;234f	21 0d c1	! . .
	res 0,(hl)		;2352	cb 86		. .
	ld hl,0c105h		;2354	21 05 c1	! . .
	set 0,(hl)		;2357	cb c6		. .
	ret			;2359	c9		.
sub_235ah:
	ld hl,0c105h		;235a	21 05 c1	! . .
	set 0,(hl)		;235d	cb c6		. .
	ret			;235f	c9		.
	ld hl,0c10dh		;2360	21 0d c1	! . .
	set 0,(hl)		;2363	cb c6		. .
	ld hl,0c105h		;2365	21 05 c1	! . .
	res 0,(hl)		;2368	cb 86		. .
	ret			;236a	c9		.
	ld hl,0c10dh		;236b	21 0d c1	! . .
	res 1,(hl)		;236e	cb 8e		. .
	ld hl,0c105h		;2370	21 05 c1	! . .
	set 1,(hl)		;2373	cb ce		. .
	ret			;2375	c9		.
l2376h:
	ld hl,0c105h		;2376	21 05 c1	! . .
	set 1,(hl)		;2379	cb ce		. .
	ret			;237b	c9		.
	ld hl,0c10dh		;237c	21 0d c1	! . .
	set 1,(hl)		;237f	cb ce		. .
	ld hl,0c105h		;2381	21 05 c1	! . .
	res 1,(hl)		;2384	cb 8e		. .
	ret			;2386	c9		.
	ld hl,0c10dh		;2387	21 0d c1	! . .
	res 5,(hl)		;238a	cb ae		. .
	ld hl,0c105h		;238c	21 05 c1	! . .
	set 5,(hl)		;238f	cb ee		. .
	ret			;2391	c9		.
l2392h:
	ld hl,0c105h		;2392	21 05 c1	! . .
	set 5,(hl)		;2395	cb ee		. .
	ret			;2397	c9		.
	ld hl,0c10dh		;2398	21 0d c1	! . .
	set 5,(hl)		;239b	cb ee		. .
	ld hl,0c105h		;239d	21 05 c1	! . .
	res 5,(hl)		;23a0	cb ae		. .
	ret			;23a2	c9		.
	ld hl,0c10dh		;23a3	21 0d c1	! . .
	res 3,(hl)		;23a6	cb 9e		. .
	ld hl,0c105h		;23a8	21 05 c1	! . .
	set 3,(hl)		;23ab	cb de		. .
	ret			;23ad	c9		.
l23aeh:
	ld hl,0c105h		;23ae	21 05 c1	! . .
	set 3,(hl)		;23b1	cb de		. .
	ret			;23b3	c9		.
	ld hl,0c10dh		;23b4	21 0d c1	! . .
	set 3,(hl)		;23b7	cb de		. .
	ld hl,0c105h		;23b9	21 05 c1	! . .
	res 3,(hl)		;23bc	cb 9e		. .
	ret			;23be	c9		.
	ld hl,0c10dh		;23bf	21 0d c1	! . .
	res 4,(hl)		;23c2	cb a6		. .
	ld hl,0c105h		;23c4	21 05 c1	! . .
	set 4,(hl)		;23c7	cb e6		. .
	ret			;23c9	c9		.
l23cah:
	ld hl,0c105h		;23ca	21 05 c1	! . .
	set 4,(hl)		;23cd	cb e6		. .
	ret			;23cf	c9		.
	ld hl,0c10dh		;23d0	21 0d c1	! . .
	set 4,(hl)		;23d3	cb e6		. .
	ld hl,0c105h		;23d5	21 05 c1	! . .
	res 4,(hl)		;23d8	cb a6		. .
	ret			;23da	c9		.
l23dbh:
	ld hl,0c10dh		;23db	21 0d c1	! . .
	res 2,(hl)		;23de	cb 96		. .
	ld hl,0c105h		;23e0	21 05 c1	! . .
	set 2,(hl)		;23e3	cb d6		. .
	ret			;23e5	c9		.
	ld hl,0c10dh		;23e6	21 0d c1	! . .
	set 2,(hl)		;23e9	cb d6		. .
	ld hl,0c105h		;23eb	21 05 c1	! . .
	res 2,(hl)		;23ee	cb 96		. .
	ret			;23f0	c9		.
	ld hl,0c10dh		;23f1	21 0d c1	! . .
	res 7,(hl)		;23f4	cb be		. .
	ld hl,0c105h		;23f6	21 05 c1	! . .
	set 7,(hl)		;23f9	cb fe		. .
	ret			;23fb	c9		.
	ld hl,0c10dh		;23fc	21 0d c1	! . .
	set 7,(hl)		;23ff	cb fe		. .
	ld hl,0c105h		;2401	21 05 c1	! . .
	res 7,(hl)		;2404	cb be		. .
	ret			;2406	c9		.
	ld hl,0c108h		;2407	21 08 c1	! . .
	res 6,(hl)		;240a	cb b6		. .
	ld hl,0c100h		;240c	21 00 c1	! . .
	set 6,(hl)		;240f	cb f6		. .
	ret			;2411	c9		.
	ld hl,0c108h		;2412	21 08 c1	! . .
	set 6,(hl)		;2415	cb f6		. .
	ld hl,0c100h		;2417	21 00 c1	! . .
	res 6,(hl)		;241a	cb b6		. .
	ret			;241c	c9		.
	ld hl,0c108h		;241d	21 08 c1	! . .
	res 3,(hl)		;2420	cb 9e		. .
	ld hl,0c100h		;2422	21 00 c1	! . .
	set 3,(hl)		;2425	cb de		. .
	ret			;2427	c9		.
	ld hl,0c108h		;2428	21 08 c1	! . .
	set 3,(hl)		;242b	cb de		. .
	ld hl,0c100h		;242d	21 00 c1	! . .
	res 3,(hl)		;2430	cb 9e		. .
	ret			;2432	c9		.
	ld hl,0c108h		;2433	21 08 c1	! . .
	res 2,(hl)		;2436	cb 96		. .
	ld hl,0c100h		;2438	21 00 c1	! . .
	set 2,(hl)		;243b	cb d6		. .
	ret			;243d	c9		.
	ld hl,0c108h		;243e	21 08 c1	! . .
	set 2,(hl)		;2441	cb d6		. .
	ld hl,0c100h		;2443	21 00 c1	! . .
	res 2,(hl)		;2446	cb 96		. .
	ret			;2448	c9		.
	ld hl,0c108h		;2449	21 08 c1	! . .
	res 5,(hl)		;244c	cb ae		. .
	ld hl,0c100h		;244e	21 00 c1	! . .
	set 5,(hl)		;2451	cb ee		. .
	ret			;2453	c9		.
	ld hl,0c108h		;2454	21 08 c1	! . .
	set 5,(hl)		;2457	cb ee		. .
	ld hl,0c100h		;2459	21 00 c1	! . .
	res 5,(hl)		;245c	cb ae		. .
	ret			;245e	c9		.
	ld hl,0c108h		;245f	21 08 c1	! . .
	res 4,(hl)		;2462	cb a6		. .
	ld hl,0c100h		;2464	21 00 c1	! . .
	set 4,(hl)		;2467	cb e6		. .
	ret			;2469	c9		.
	ld hl,0c108h		;246a	21 08 c1	! . .
	set 4,(hl)		;246d	cb e6		. .
	ld hl,0c100h		;246f	21 00 c1	! . .
	res 4,(hl)		;2472	cb a6		. .
	ret			;2474	c9		.
	ld hl,0c109h		;2475	21 09 c1	! . .
	res 6,(hl)		;2478	cb b6		. .
	ld hl,0c101h		;247a	21 01 c1	! . .
	set 6,(hl)		;247d	cb f6		. .
	ret			;247f	c9		.
	ld hl,0c109h		;2480	21 09 c1	! . .
	set 6,(hl)		;2483	cb f6		. .
	ld hl,0c101h		;2485	21 01 c1	! . .
	res 6,(hl)		;2488	cb b6		. .
	ret			;248a	c9		.
	ld hl,0c10bh		;248b	21 0b c1	! . .
	res 4,(hl)		;248e	cb a6		. .
	ld hl,0c103h		;2490	21 03 c1	! . .
	set 4,(hl)		;2493	cb e6		. .
	ret			;2495	c9		.
	ld hl,0c10bh		;2496	21 0b c1	! . .
	set 4,(hl)		;2499	cb e6		. .
	ld hl,0c103h		;249b	21 03 c1	! . .
	res 4,(hl)		;249e	cb a6		. .
	ret			;24a0	c9		.
	ld hl,0c10dh		;24a1	21 0d c1	! . .
	res 6,(hl)		;24a4	cb b6		. .
	ld hl,0c105h		;24a6	21 05 c1	! . .
	set 6,(hl)		;24a9	cb f6		. .
	ret			;24ab	c9		.
	ld hl,0c10dh		;24ac	21 0d c1	! . .
	set 6,(hl)		;24af	cb f6		. .
	ld hl,0c105h		;24b1	21 05 c1	! . .
	res 6,(hl)		;24b4	cb b6		. .
	ret			;24b6	c9		.
	ld a,0ffh		;24b7	3e ff		> .
	ld (0c127h),a		;24b9	32 27 c1	2 ' .
	ld hl,0c10eh		;24bc	21 0e c1	! . .
	res 7,(hl)		;24bf	cb be		. .
	ld hl,0c106h		;24c1	21 06 c1	! . .
	set 7,(hl)		;24c4	cb fe		. .
	ret			;24c6	c9		.
sub_24c7h:
	xor a			;24c7	af		.
	ld (0c127h),a		;24c8	32 27 c1	2 ' .
	ld hl,0c10eh		;24cb	21 0e c1	! . .
	set 7,(hl)		;24ce	cb fe		. .
	ld hl,0c106h		;24d0	21 06 c1	! . .
	res 7,(hl)		;24d3	cb be		. .
	ret			;24d5	c9		.
sub_24d6h:
	ld hl,0c106h		;24d6	21 06 c1	! . .
	set 4,(hl)		;24d9	cb e6		. .
	ret			;24db	c9		.
	ld hl,0c10eh		;24dc	21 0e c1	! . .
	set 4,(hl)		;24df	cb e6		. .
	ld hl,0c106h		;24e1	21 06 c1	! . .
	res 4,(hl)		;24e4	cb a6		. .
	ret			;24e6	c9		.
sub_24e7h:
	ld hl,0c106h		;24e7	21 06 c1	! . .
	set 3,(hl)		;24ea	cb de		. .
	ret			;24ec	c9		.
	ld hl,0c10eh		;24ed	21 0e c1	! . .
	set 3,(hl)		;24f0	cb de		. .
	ld hl,0c106h		;24f2	21 06 c1	! . .
	res 3,(hl)		;24f5	cb 9e		. .
	ret			;24f7	c9		.
sub_24f8h:
	ld hl,0c106h		;24f8	21 06 c1	! . .
	set 0,(hl)		;24fb	cb c6		. .
	ret			;24fd	c9		.
	ld hl,0c10eh		;24fe	21 0e c1	! . .
	set 0,(hl)		;2501	cb c6		. .
	ld hl,0c106h		;2503	21 06 c1	! . .
	res 0,(hl)		;2506	cb 86		. .
	ret			;2508	c9		.
sub_2509h:
	ld hl,0c106h		;2509	21 06 c1	! . .
	set 1,(hl)		;250c	cb ce		. .
	ret			;250e	c9		.
	ld hl,0c10eh		;250f	21 0e c1	! . .
	set 1,(hl)		;2512	cb ce		. .
	ld hl,0c106h		;2514	21 06 c1	! . .
	res 1,(hl)		;2517	cb 8e		. .
	ret			;2519	c9		.
sub_251ah:
	ld hl,0c106h		;251a	21 06 c1	! . .
	set 2,(hl)		;251d	cb d6		. .
	ret			;251f	c9		.
	ld hl,0c10eh		;2520	21 0e c1	! . .
	set 2,(hl)		;2523	cb d6		. .
	ld hl,0c106h		;2525	21 06 c1	! . .
	res 2,(hl)		;2528	cb 96		. .
	ret			;252a	c9		.
	ld hl,0c10ch		;252b	21 0c c1	! . .
	res 7,(hl)		;252e	cb be		. .
	ld hl,0c104h		;2530	21 04 c1	! . .
	set 7,(hl)		;2533	cb fe		. .
	ret			;2535	c9		.
	ld hl,0c10ch		;2536	21 0c c1	! . .
	set 7,(hl)		;2539	cb fe		. .
	ld hl,0c104h		;253b	21 04 c1	! . .
	res 7,(hl)		;253e	cb be		. .
	ret			;2540	c9		.
	ld hl,0c104h		;2541	21 04 c1	! . .
	set 0,(hl)		;2544	cb c6		. .
	ret			;2546	c9		.
	ld hl,0c10ch		;2547	21 0c c1	! . .
	set 0,(hl)		;254a	cb c6		. .
	ld hl,0c104h		;254c	21 04 c1	! . .
	res 0,(hl)		;254f	cb 86		. .
	ret			;2551	c9		.
	ld hl,0c10ch		;2552	21 0c c1	! . .
	res 1,(hl)		;2555	cb 8e		. .
	ld hl,0c104h		;2557	21 04 c1	! . .
	set 1,(hl)		;255a	cb ce		. .
	ret			;255c	c9		.
	ld hl,0c10ch		;255d	21 0c c1	! . .
	set 1,(hl)		;2560	cb ce		. .
	ld hl,0c104h		;2562	21 04 c1	! . .
	res 1,(hl)		;2565	cb 8e		. .
	ret			;2567	c9		.
	ld hl,0c104h		;2568	21 04 c1	! . .
	set 2,(hl)		;256b	cb d6		. .
	ret			;256d	c9		.
	ld hl,0c10ch		;256e	21 0c c1	! . .
	set 2,(hl)		;2571	cb d6		. .
	ld hl,0c104h		;2573	21 04 c1	! . .
	res 2,(hl)		;2576	cb 96		. .
	ret			;2578	c9		.
	ld hl,0c10ch		;2579	21 0c c1	! . .
	res 3,(hl)		;257c	cb 9e		. .
	ld hl,0c104h		;257e	21 04 c1	! . .
	set 3,(hl)		;2581	cb de		. .
	ret			;2583	c9		.
	ld hl,0c10ch		;2584	21 0c c1	! . .
	set 3,(hl)		;2587	cb de		. .
	ld hl,0c104h		;2589	21 04 c1	! . .
	res 3,(hl)		;258c	cb 9e		. .
	ret			;258e	c9		.
	ld hl,0c108h		;258f	21 08 c1	! . .
	res 7,(hl)		;2592	cb be		. .
	ld hl,0c100h		;2594	21 00 c1	! . .
	set 7,(hl)		;2597	cb fe		. .
	ret			;2599	c9		.
	ld hl,0c108h		;259a	21 08 c1	! . .
	set 7,(hl)		;259d	cb fe		. .
	ld hl,0c100h		;259f	21 00 c1	! . .
	res 7,(hl)		;25a2	cb be		. .
	ret			;25a4	c9		.
	ld hl,0c0ffh		;25a5	21 ff c0	! . .
	set 0,(hl)		;25a8	cb c6		. .
	ret			;25aa	c9		.
	ld hl,0c107h		;25ab	21 07 c1	! . .
	set 0,(hl)		;25ae	cb c6		. .
	ld hl,0c0ffh		;25b0	21 ff c0	! . .
	res 0,(hl)		;25b3	cb 86		. .
	ret			;25b5	c9		.
	ld hl,0c0ffh		;25b6	21 ff c0	! . .
	set 1,(hl)		;25b9	cb ce		. .
	ret			;25bb	c9		.
	ld hl,0c107h		;25bc	21 07 c1	! . .
	set 1,(hl)		;25bf	cb ce		. .
	ld hl,0c0ffh		;25c1	21 ff c0	! . .
	res 1,(hl)		;25c4	cb 8e		. .
	ret			;25c6	c9		.
	ld hl,0c0ffh		;25c7	21 ff c0	! . .
	set 2,(hl)		;25ca	cb d6		. .
	ret			;25cc	c9		.
	ld hl,0c107h		;25cd	21 07 c1	! . .
	set 2,(hl)		;25d0	cb d6		. .
	ld hl,0c0ffh		;25d2	21 ff c0	! . .
	res 2,(hl)		;25d5	cb 96		. .
	ret			;25d7	c9		.
	ld hl,0c0ffh		;25d8	21 ff c0	! . .
	set 3,(hl)		;25db	cb de		. .
	ret			;25dd	c9		.
	ld hl,0c107h		;25de	21 07 c1	! . .
	set 3,(hl)		;25e1	cb de		. .
	ld hl,0c0ffh		;25e3	21 ff c0	! . .
	res 3,(hl)		;25e6	cb 9e		. .
	ret			;25e8	c9		.
	ld hl,0c0ffh		;25e9	21 ff c0	! . .
	set 4,(hl)		;25ec	cb e6		. .
	ret			;25ee	c9		.
	ld hl,0c107h		;25ef	21 07 c1	! . .
	set 4,(hl)		;25f2	cb e6		. .
	ld hl,0c0ffh		;25f4	21 ff c0	! . .
	res 4,(hl)		;25f7	cb a6		. .
	ret			;25f9	c9		.
	ld hl,0c0ffh		;25fa	21 ff c0	! . .
	set 5,(hl)		;25fd	cb ee		. .
	ret			;25ff	c9		.
	ld hl,0c107h		;2600	21 07 c1	! . .
	set 5,(hl)		;2603	cb ee		. .
	ld hl,0c0ffh		;2605	21 ff c0	! . .
	res 5,(hl)		;2608	cb ae		. .
	ret			;260a	c9		.
	ld hl,0c0ffh		;260b	21 ff c0	! . .
	set 6,(hl)		;260e	cb f6		. .
	ret			;2610	c9		.
	ld hl,0c107h		;2611	21 07 c1	! . .
	set 6,(hl)		;2614	cb f6		. .
	ld hl,0c0ffh		;2616	21 ff c0	! . .
	res 6,(hl)		;2619	cb b6		. .
	ret			;261b	c9		.
	ld hl,0c0ffh		;261c	21 ff c0	! . .
	set 7,(hl)		;261f	cb fe		. .
	ret			;2621	c9		.
	ld hl,0c107h		;2622	21 07 c1	! . .
	set 7,(hl)		;2625	cb fe		. .
	ld hl,0c0ffh		;2627	21 ff c0	! . .
	res 7,(hl)		;262a	cb be		. .
	ret			;262c	c9		.
	ld hl,0c100h		;262d	21 00 c1	! . .
	set 0,(hl)		;2630	cb c6		. .
	ret			;2632	c9		.
	ld hl,0c108h		;2633	21 08 c1	! . .
	set 0,(hl)		;2636	cb c6		. .
	ld hl,0c100h		;2638	21 00 c1	! . .
	res 0,(hl)		;263b	cb 86		. .
	ret			;263d	c9		.
	ld hl,0c100h		;263e	21 00 c1	! . .
	set 1,(hl)		;2641	cb ce		. .
	ret			;2643	c9		.
	ld hl,0c108h		;2644	21 08 c1	! . .
	set 1,(hl)		;2647	cb ce		. .
	ld hl,0c100h		;2649	21 00 c1	! . .
	res 1,(hl)		;264c	cb 8e		. .
	ret			;264e	c9		.
	di			;264f	f3		.
	ld hl,0c0ffh		;2650	21 ff c0	! . .
	ld (hl),0ffh		;2653	36 ff		6 .
	ld hl,0c100h		;2655	21 00 c1	! . .
	set 0,(hl)		;2658	cb c6		. .
	set 1,(hl)		;265a	cb ce		. .
	ei			;265c	fb		.
	ret			;265d	c9		.
	di			;265e	f3		.
	ld hl,0c0ffh		;265f	21 ff c0	! . .
	ld (hl),000h		;2662	36 00		6 .
	ld hl,0c100h		;2664	21 00 c1	! . .
	res 0,(hl)		;2667	cb 86		. .
	res 1,(hl)		;2669	cb 8e		. .
	ld hl,0c107h		;266b	21 07 c1	! . .
	ld (hl),0ffh		;266e	36 ff		6 .
	ld hl,0c108h		;2670	21 08 c1	! . .
	set 0,(hl)		;2673	cb c6		. .
	set 1,(hl)		;2675	cb ce		. .
	ei			;2677	fb		.
	ret			;2678	c9		.
sub_2679h:
	ld hl,0c102h		;2679	21 02 c1	! . .
	set 0,(hl)		;267c	cb c6		. .
	ret			;267e	c9		.
	ld hl,0c10ah		;267f	21 0a c1	! . .
	set 0,(hl)		;2682	cb c6		. .
	ld hl,0c102h		;2684	21 02 c1	! . .
	res 0,(hl)		;2687	cb 86		. .
	ret			;2689	c9		.
	ld hl,0c102h		;268a	21 02 c1	! . .
	set 1,(hl)		;268d	cb ce		. .
	ret			;268f	c9		.
	ld hl,0c10ah		;2690	21 0a c1	! . .
	set 1,(hl)		;2693	cb ce		. .
	ld hl,0c102h		;2695	21 02 c1	! . .
	res 1,(hl)		;2698	cb 8e		. .
	ret			;269a	c9		.
	ld hl,0c102h		;269b	21 02 c1	! . .
	set 2,(hl)		;269e	cb d6		. .
	ret			;26a0	c9		.
	ld hl,0c10ah		;26a1	21 0a c1	! . .
	set 2,(hl)		;26a4	cb d6		. .
	ld hl,0c102h		;26a6	21 02 c1	! . .
	res 2,(hl)		;26a9	cb 96		. .
	ret			;26ab	c9		.
	ld hl,0c102h		;26ac	21 02 c1	! . .
	set 3,(hl)		;26af	cb de		. .
	ret			;26b1	c9		.
	ld hl,0c10ah		;26b2	21 0a c1	! . .
	set 3,(hl)		;26b5	cb de		. .
	ld hl,0c102h		;26b7	21 02 c1	! . .
	res 3,(hl)		;26ba	cb 9e		. .
	ret			;26bc	c9		.
	ld hl,0c102h		;26bd	21 02 c1	! . .
	set 4,(hl)		;26c0	cb e6		. .
	ret			;26c2	c9		.
	ld hl,0c10ah		;26c3	21 0a c1	! . .
	set 4,(hl)		;26c6	cb e6		. .
	ld hl,0c102h		;26c8	21 02 c1	! . .
	res 4,(hl)		;26cb	cb a6		. .
	ret			;26cd	c9		.
	ld hl,0c102h		;26ce	21 02 c1	! . .
	set 5,(hl)		;26d1	cb ee		. .
	ret			;26d3	c9		.
	ld hl,0c10ah		;26d4	21 0a c1	! . .
	set 5,(hl)		;26d7	cb ee		. .
	ld hl,0c102h		;26d9	21 02 c1	! . .
	res 5,(hl)		;26dc	cb ae		. .
	ret			;26de	c9		.
	ld hl,0c102h		;26df	21 02 c1	! . .
	set 6,(hl)		;26e2	cb f6		. .
	ret			;26e4	c9		.
	ld hl,0c10ah		;26e5	21 0a c1	! . .
	set 6,(hl)		;26e8	cb f6		. .
	ld hl,0c102h		;26ea	21 02 c1	! . .
	res 6,(hl)		;26ed	cb b6		. .
	ret			;26ef	c9		.
	ld hl,0c102h		;26f0	21 02 c1	! . .
	set 7,(hl)		;26f3	cb fe		. .
	ret			;26f5	c9		.
	ld hl,0c10ah		;26f6	21 0a c1	! . .
	set 7,(hl)		;26f9	cb fe		. .
	ld hl,0c102h		;26fb	21 02 c1	! . .
	res 7,(hl)		;26fe	cb be		. .
	ret			;2700	c9		.
	ld hl,0c103h		;2701	21 03 c1	! . .
	set 0,(hl)		;2704	cb c6		. .
	ret			;2706	c9		.
	ld hl,0c10bh		;2707	21 0b c1	! . .
	set 0,(hl)		;270a	cb c6		. .
	ld hl,0c103h		;270c	21 03 c1	! . .
	res 0,(hl)		;270f	cb 86		. .
	ret			;2711	c9		.
	ld hl,0c103h		;2712	21 03 c1	! . .
	set 1,(hl)		;2715	cb ce		. .
	ret			;2717	c9		.
	ld hl,0c10bh		;2718	21 0b c1	! . .
	set 1,(hl)		;271b	cb ce		. .
	ld hl,0c103h		;271d	21 03 c1	! . .
	res 1,(hl)		;2720	cb 8e		. .
	ret			;2722	c9		.
	ld hl,0c103h		;2723	21 03 c1	! . .
	set 2,(hl)		;2726	cb d6		. .
	ret			;2728	c9		.
	ld hl,0c10bh		;2729	21 0b c1	! . .
	set 2,(hl)		;272c	cb d6		. .
	ld hl,0c103h		;272e	21 03 c1	! . .
	res 2,(hl)		;2731	cb 96		. .
	ret			;2733	c9		.
sub_2734h:
	ld hl,0c103h		;2734	21 03 c1	! . .
	set 3,(hl)		;2737	cb de		. .
	ret			;2739	c9		.
	ld hl,0c10bh		;273a	21 0b c1	! . .
	set 3,(hl)		;273d	cb de		. .
	ld hl,0c103h		;273f	21 03 c1	! . .
	res 3,(hl)		;2742	cb 9e		. .
	ret			;2744	c9		.
	ld hl,0c10ah		;2745	21 0a c1	! . .
	res 0,(hl)		;2748	cb 86		. .
	ld hl,0c102h		;274a	21 02 c1	! . .
	set 0,(hl)		;274d	cb c6		. .
	ret			;274f	c9		.
	ld hl,0c10ah		;2750	21 0a c1	! . .
	res 1,(hl)		;2753	cb 8e		. .
	ld hl,0c102h		;2755	21 02 c1	! . .
	set 1,(hl)		;2758	cb ce		. .
	ret			;275a	c9		.
	ld hl,0c10ah		;275b	21 0a c1	! . .
	res 2,(hl)		;275e	cb 96		. .
	ld hl,0c102h		;2760	21 02 c1	! . .
	set 2,(hl)		;2763	cb d6		. .
	ret			;2765	c9		.
	ld hl,0c10ah		;2766	21 0a c1	! . .
	res 3,(hl)		;2769	cb 9e		. .
	ld hl,0c102h		;276b	21 02 c1	! . .
	set 3,(hl)		;276e	cb de		. .
	ret			;2770	c9		.
	ld hl,0c10ah		;2771	21 0a c1	! . .
	res 4,(hl)		;2774	cb a6		. .
	ld hl,0c102h		;2776	21 02 c1	! . .
	set 4,(hl)		;2779	cb e6		. .
	ret			;277b	c9		.
	ld hl,0c10ah		;277c	21 0a c1	! . .
	res 5,(hl)		;277f	cb ae		. .
	ld hl,0c102h		;2781	21 02 c1	! . .
	set 5,(hl)		;2784	cb ee		. .
	ret			;2786	c9		.
	ld hl,0c10ah		;2787	21 0a c1	! . .
	res 6,(hl)		;278a	cb b6		. .
	ld hl,0c102h		;278c	21 02 c1	! . .
	set 6,(hl)		;278f	cb f6		. .
	ret			;2791	c9		.
	ld hl,0c10ah		;2792	21 0a c1	! . .
	res 7,(hl)		;2795	cb be		. .
	ld hl,0c102h		;2797	21 02 c1	! . .
	set 7,(hl)		;279a	cb fe		. .
	ret			;279c	c9		.
	ld hl,0c10bh		;279d	21 0b c1	! . .
	res 0,(hl)		;27a0	cb 86		. .
	ld hl,0c103h		;27a2	21 03 c1	! . .
	set 0,(hl)		;27a5	cb c6		. .
	ret			;27a7	c9		.
	ld hl,0c10bh		;27a8	21 0b c1	! . .
	res 1,(hl)		;27ab	cb 8e		. .
	ld hl,0c103h		;27ad	21 03 c1	! . .
	set 1,(hl)		;27b0	cb ce		. .
	ret			;27b2	c9		.
;  XREF: 3 refs from 0x27D7, 0x35A8, 0x35E0
l27b3h:
	di			;27b3	f3		.
	ld a,(0c007h)		;27b4	3a 07 c0	: . .  ; [ram_port87_shadow - Shadow register for PORT_MATRIX_ROW]
	and 0dfh		;27b7	e6 df		. .
	ld (0c007h),a		;27b9	32 07 c0	2 . .  ; [ram_port87_shadow - Shadow register for PORT_MATRIX_ROW]
	out (087h),a		;27bc	d3 87		. .  ; >> PORT_MATRIX_ROW - Switch matrix row strobe select
	ei			;27be	fb		.
	ret			;27bf	c9		.
sub_27c0h:
	di			;27c0	f3		.
	ld a,(0c007h)		;27c1	3a 07 c0	: . .  ; [ram_port87_shadow - Shadow register for PORT_MATRIX_ROW]
	or 020h			;27c4	f6 20		.  
	ld (0c007h),a		;27c6	32 07 c0	2 . .  ; [ram_port87_shadow - Shadow register for PORT_MATRIX_ROW]
	out (087h),a		;27c9	d3 87		. .  ; >> PORT_MATRIX_ROW - Switch matrix row strobe select
	ei			;27cb	fb		.
	ret			;27cc	c9		.
l27cdh:
	ld a,0ffh		;27cd	3e ff		> .
	ld (0c022h),a		;27cf	32 22 c0	2 " .  ; [ram_sol_timer_bank - Solenoid timer bank (multiple timers)]
	ret			;27d2	c9		.
	xor a			;27d3	af		.
	ld (0c022h),a		;27d4	32 22 c0	2 " .  ; [ram_sol_timer_bank - Solenoid timer bank (multiple timers)]
	call l27b3h		;27d7	cd b3 27	. . '
	ret			;27da	c9		.
	ld hl,l003bh+1		;27db	21 3c 00	! < .
	ld (0c04ch),hl		;27de	22 4c c0	" L .  ; [ram_sw_queue_wptr - Switch event queue write pointer]
	ld a,0ffh		;27e1	3e ff		> .
	ld (0c04eh),a		;27e3	32 4e c0	2 N .  ; [ram_timer_flag - Main timer flag (controls game timing)]
sub_27e6h:
	ld a,(0c04eh)		;27e6	3a 4e c0	: N .  ; [ram_timer_flag - Main timer flag (controls game timing)]
	and a			;27e9	a7		.
	jr nz,sub_27e6h		;27ea	20 fa		  .
	ret			;27ec	c9		.
sub_27edh:
	di			;27ed	f3		.
	ld a,(0c106h)		;27ee	3a 06 c1	: . .
	and 080h		;27f1	e6 80		. .
	ld b,008h		;27f3	06 08		. .
	ld hl,0c107h		;27f5	21 07 c1	! . .
l27f8h:
	ld (hl),0ffh		;27f8	36 ff		6 .
	inc hl			;27fa	23		#
	djnz l27f8h		;27fb	10 fb		. .
	cpl			;27fd	2f		/
	ld hl,0c10eh		;27fe	21 0e c1	! . .
	and (hl)		;2801	a6		.
	ld (hl),a		;2802	77		w
	ld b,008h		;2803	06 08		. .
	ld hl,0c0ffh		;2805	21 ff c0	! . .
l2808h:
	ld (hl),000h		;2808	36 00		6 .
	inc hl			;280a	23		#
	djnz l2808h		;280b	10 fb		. .
	cpl			;280d	2f		/
	ld hl,0c106h		;280e	21 06 c1	! . .
	or (hl)			;2811	b6		.
	ld (hl),a		;2812	77		w
	xor a			;2813	af		.
	ld (0c119h),a		;2814	32 19 c1	2 . .  ; [ram_lamp_state_flags - Lamp state flags (23 refs)]
	ld a,(0c068h)		;2817	3a 68 c0	: h .  ; [ram_game_active - Game active flag (0=attract, nonzero=playing)]
	and a			;281a	a7		.
	jp nz,l282dh		;281b	c2 2d 28	. - (
	call sub_24d6h		;281e	cd d6 24	. . $
	call sub_24e7h		;2821	cd e7 24	. . $
	call sub_24f8h		;2824	cd f8 24	. . $
	call sub_2509h		;2827	cd 09 25	. . %
	call sub_251ah		;282a	cd 1a 25	. . %
l282dh:
	ei			;282d	fb		.
	ret			;282e	c9		.
	ret			;282f	c9		.
	ret			;2830	c9		.
sub_2831h:
	di			;2831	f3		.
	ld a,(0c007h)		;2832	3a 07 c0	: . .  ; [ram_port87_shadow - Shadow register for PORT_MATRIX_ROW]
	and 0efh		;2835	e6 ef		. .
	ld (0c007h),a		;2837	32 07 c0	2 . .  ; [ram_port87_shadow - Shadow register for PORT_MATRIX_ROW]
	out (087h),a		;283a	d3 87		. .  ; >> PORT_MATRIX_ROW - Switch matrix row strobe select
	ld a,0ffh		;283c	3e ff		> .
	ld (0c056h),a		;283e	32 56 c0	2 V .  ; [ram_timer_56 - Timer register 0x56]
	ld a,0ffh		;2841	3e ff		> .
	ld (0c05fh),a		;2843	32 5f c0	2 _ .  ; [ram_debounce_timer - Debounce timer (97 refs - MOST REFERENCED)]
	xor a			;2846	af		.
	ld (0c119h),a		;2847	32 19 c1	2 . .  ; [ram_lamp_state_flags - Lamp state flags (23 refs)]
	ld a,0ffh		;284a	3e ff		> .
	ld (0c055h),a		;284c	32 55 c0	2 U .  ; [ram_debounce_state - Debounce state variable]
	ei			;284f	fb		.
	ret			;2850	c9		.
sub_2851h:
	di			;2851	f3		.
	xor a			;2852	af		.
	ld (0c056h),a		;2853	32 56 c0	2 V .  ; [ram_timer_56 - Timer register 0x56]
	ld a,0ffh		;2856	3e ff		> .
	ld (0c05fh),a		;2858	32 5f c0	2 _ .  ; [ram_debounce_timer - Debounce timer (97 refs - MOST REFERENCED)]
	ld (0c055h),a		;285b	32 55 c0	2 U .  ; [ram_debounce_state - Debounce state variable]
	ld a,(0c007h)		;285e	3a 07 c0	: . .  ; [ram_port87_shadow - Shadow register for PORT_MATRIX_ROW]
	or 010h			;2861	f6 10		. .
	ld (0c007h),a		;2863	32 07 c0	2 . .  ; [ram_port87_shadow - Shadow register for PORT_MATRIX_ROW]
	out (087h),a		;2866	d3 87		. .  ; >> PORT_MATRIX_ROW - Switch matrix row strobe select
	ld a,(0c068h)		;2868	3a 68 c0	: h .  ; [ram_game_active - Game active flag (0=attract, nonzero=playing)]
	and a			;286b	a7		.
	jp nz,l2872h		;286c	c2 72 28	. r (
	call init_extended_setup		;286f	cd a7 36	. . 6
l2872h:
	ei			;2872	fb		.
	ret			;2873	c9		.
	ld a,0ffh		;2874	3e ff		> .
	ld (0c069h),a		;2876	32 69 c0	2 i .
	ret			;2879	c9		.
	xor a			;287a	af		.
	ld (0c069h),a		;287b	32 69 c0	2 i .
	ret			;287e	c9		.
	ld a,0ffh		;287f	3e ff		> .
	ld (0c06ah),a		;2881	32 6a c0	2 j .  ; [ram_ball_in_play - Ball-in-play counter]
	ret			;2884	c9		.
	xor a			;2885	af		.
	ld (0c06ah),a		;2886	32 6a c0	2 j .  ; [ram_ball_in_play - Ball-in-play counter]
	ret			;2889	c9		.
	ld a,0ffh		;288a	3e ff		> .
	ld (0c055h),a		;288c	32 55 c0	2 U .  ; [ram_debounce_state - Debounce state variable]
	ret			;288f	c9		.
	xor a			;2890	af		.
	ld (0c055h),a		;2891	32 55 c0	2 U .  ; [ram_debounce_state - Debounce state variable]
	ret			;2894	c9		.
	ld a,(0c068h)		;2895	3a 68 c0	: h .  ; [ram_game_active - Game active flag (0=attract, nonzero=playing)]
	and a			;2898	a7		.
	ret z			;2899	c8		.
	call 005c7h		;289a	cd c7 05	. . .
	call sub_28a1h		;289d	cd a1 28	. . (
	ret			;28a0	c9		.
sub_28a1h:
	ld hl,l0064h		;28a1	21 64 00	! d .
	ld (0c04ch),hl		;28a4	22 4c c0	" L .  ; [ram_sw_queue_wptr - Switch event queue write pointer]
	ld a,0ffh		;28a7	3e ff		> .
	ld (0c04eh),a		;28a9	32 4e c0	2 N .  ; [ram_timer_flag - Main timer flag (controls game timing)]
l28ach:
	call scan_begin_cycle		;28ac	cd 73 2e	. s .  ; → scan_begin_cycle
	call lamp_strobe_cycle		;28af	cd ed 32	. . 2
	ld a,(0c0dbh)		;28b2	3a db c0	: . .  ; [ram_row0_switches - Matrix row 0 debounced switch state]
	bit 6,a			;28b5	cb 77		. w
	jp z,l28c1h		;28b7	ca c1 28	. . (
	ld a,(0c04eh)		;28ba	3a 4e c0	: N .  ; [ram_timer_flag - Main timer flag (controls game timing)]
	and a			;28bd	a7		.
	jp nz,l28ach		;28be	c2 ac 28	. . (
l28c1h:
	call sol1_activate		;28c1	cd 13 06	. . .
	ld hl,l0064h		;28c4	21 64 00	! d .
	ld (0c04ch),hl		;28c7	22 4c c0	" L .  ; [ram_sw_queue_wptr - Switch event queue write pointer]
	ld a,0ffh		;28ca	3e ff		> .
	ld (0c04eh),a		;28cc	32 4e c0	2 N .  ; [ram_timer_flag - Main timer flag (controls game timing)]
l28cfh:
	ld a,(0c04eh)		;28cf	3a 4e c0	: N .  ; [ram_timer_flag - Main timer flag (controls game timing)]
	and a			;28d2	a7		.
	jp nz,l28cfh		;28d3	c2 cf 28	. . (
	ret			;28d6	c9		.
	ld a,(0c068h)		;28d7	3a 68 c0	: h .  ; [ram_game_active - Game active flag (0=attract, nonzero=playing)]
	and a			;28da	a7		.
	ret z			;28db	c8		.
	call sub_05edh		;28dc	cd ed 05	. . .
	call sub_28e3h		;28df	cd e3 28	. . (
	ret			;28e2	c9		.
sub_28e3h:
	ld hl,l0064h		;28e3	21 64 00	! d .
	ld (0c04ch),hl		;28e6	22 4c c0	" L .  ; [ram_sw_queue_wptr - Switch event queue write pointer]
	ld a,0ffh		;28e9	3e ff		> .
	ld (0c04eh),a		;28eb	32 4e c0	2 N .  ; [ram_timer_flag - Main timer flag (controls game timing)]
l28eeh:
	call scan_begin_cycle		;28ee	cd 73 2e	. s .  ; → scan_begin_cycle
	call lamp_strobe_cycle		;28f1	cd ed 32	. . 2
	ld a,(0c0dbh)		;28f4	3a db c0	: . .  ; [ram_row0_switches - Matrix row 0 debounced switch state]
	bit 7,a			;28f7	cb 7f		. .
	jp z,l2903h		;28f9	ca 03 29	. . )
	ld a,(0c04eh)		;28fc	3a 4e c0	: N .  ; [ram_timer_flag - Main timer flag (controls game timing)]
	and a			;28ff	a7		.
	jp nz,l28eeh		;2900	c2 ee 28	. . (
l2903h:
	call sol2_activate		;2903	cd 30 06	. 0 .
	ld hl,l0064h		;2906	21 64 00	! d .
	ld (0c04ch),hl		;2909	22 4c c0	" L .  ; [ram_sw_queue_wptr - Switch event queue write pointer]
	ld a,0ffh		;290c	3e ff		> .
	ld (0c04eh),a		;290e	32 4e c0	2 N .  ; [ram_timer_flag - Main timer flag (controls game timing)]
l2911h:
	ld a,(0c04eh)		;2911	3a 4e c0	: N .  ; [ram_timer_flag - Main timer flag (controls game timing)]
	and a			;2914	a7		.
	jp nz,l2911h		;2915	c2 11 29	. . )
	ret			;2918	c9		.
	ld a,(0c068h)		;2919	3a 68 c0	: h .  ; [ram_game_active - Game active flag (0=attract, nonzero=playing)]
	and a			;291c	a7		.
	ret z			;291d	c8		.
	call sol1_activate		;291e	cd 13 06	. . .
	ret			;2921	c9		.
	call sol1_deactivate		;2922	cd 4d 06	. M .
	ld a,01eh		;2925	3e 1e		> .
	ld (0c05fh),a		;2927	32 5f c0	2 _ .  ; [ram_debounce_timer - Debounce timer (97 refs - MOST REFERENCED)]
	ret			;292a	c9		.
	ld a,(0c068h)		;292b	3a 68 c0	: h .  ; [ram_game_active - Game active flag (0=attract, nonzero=playing)]
	and a			;292e	a7		.
	ret z			;292f	c8		.
	call sol2_activate		;2930	cd 30 06	. 0 .
	ret			;2933	c9		.
	call sol2_deactivate		;2934	cd 66 06	. f .
	ld a,01eh		;2937	3e 1e		> .
	ld (0c05fh),a		;2939	32 5f c0	2 _ .  ; [ram_debounce_timer - Debounce timer (97 refs - MOST REFERENCED)]
	ret			;293c	c9		.
	ld a,(0c068h)		;293d	3a 68 c0	: h .  ; [ram_game_active - Game active flag (0=attract, nonzero=playing)]
	and a			;2940	a7		.
	ret z			;2941	c8		.
	call sol3_activate		;2942	cd 7f 06	. . .
	call sub_2949h		;2945	cd 49 29	. I )
	ret			;2948	c9		.
sub_2949h:
	ld hl,l0064h		;2949	21 64 00	! d .
	ld (0c04ch),hl		;294c	22 4c c0	" L .  ; [ram_sw_queue_wptr - Switch event queue write pointer]
	ld a,0ffh		;294f	3e ff		> .
	ld (0c04eh),a		;2951	32 4e c0	2 N .  ; [ram_timer_flag - Main timer flag (controls game timing)]
l2954h:
	call sub_2e83h		;2954	cd 83 2e	. . .
	call sub_32f9h		;2957	cd f9 32	. . 2
	ld a,(0c0dch)		;295a	3a dc c0	: . .  ; [ram_row1_switches - Matrix row 1 debounced switch state]
	bit 2,a			;295d	cb 57		. W
	jp z,l2969h		;295f	ca 69 29	. i )
	ld a,(0c04eh)		;2962	3a 4e c0	: N .  ; [ram_timer_flag - Main timer flag (controls game timing)]
	and a			;2965	a7		.
	jp nz,l2954h		;2966	c2 54 29	. T )
l2969h:
	call sol4_activate		;2969	cd a5 06	. . .
	ld hl,l0064h		;296c	21 64 00	! d .
	ld (0c04ch),hl		;296f	22 4c c0	" L .  ; [ram_sw_queue_wptr - Switch event queue write pointer]
	ld a,0ffh		;2972	3e ff		> .
	ld (0c04eh),a		;2974	32 4e c0	2 N .  ; [ram_timer_flag - Main timer flag (controls game timing)]
l2977h:
	ld a,(0c04eh)		;2977	3a 4e c0	: N .  ; [ram_timer_flag - Main timer flag (controls game timing)]
	and a			;297a	a7		.
	jp nz,l2977h		;297b	c2 77 29	. w )
	ret			;297e	c9		.
	ld a,(0c068h)		;297f	3a 68 c0	: h .  ; [ram_game_active - Game active flag (0=attract, nonzero=playing)]
	and a			;2982	a7		.
	ret z			;2983	c8		.
	call sol4_activate		;2984	cd a5 06	. . .
	ret			;2987	c9		.
	call sol3_deactivate		;2988	cd c2 06	. . .
	ld a,01eh		;298b	3e 1e		> .
	ld (0c05fh),a		;298d	32 5f c0	2 _ .  ; [ram_debounce_timer - Debounce timer (97 refs - MOST REFERENCED)]
	ret			;2990	c9		.
	ld a,0ffh		;2991	3e ff		> .
	ld (0c05ah),a		;2993	32 5a c0	2 Z .  ; [ram_irq_counter - IRQ service call counter]
	ret			;2996	c9		.
	xor a			;2997	af		.
	ld (0c05ah),a		;2998	32 5a c0	2 Z .  ; [ram_irq_counter - IRQ service call counter]
	ret			;299b	c9		.
	ret			;299c	c9		.
	ret			;299d	c9		.
	ld hl,l0014h		;299e	21 14 00	! . .
	ld (0c04fh),hl		;29a1	22 4f c0	" O .  ; [ram_timer_aux - Auxiliary timer counter]
	ld a,0ffh		;29a4	3e ff		> .
	ld (0c051h),a		;29a6	32 51 c0	2 Q .  ; [ram_game_timer - Game timer (ball time / bonus countdown)]
	call sub_08a7h		;29a9	cd a7 08	. . .
l29ach:
	ld a,(0c051h)		;29ac	3a 51 c0	: Q .  ; [ram_game_timer - Game timer (ball time / bonus countdown)]
	and a			;29af	a7		.
	jr nz,l29ach		;29b0	20 fa		  .
	call sub_08c5h		;29b2	cd c5 08	. . .
	ld a,01eh		;29b5	3e 1e		> .
	ld (0c05fh),a		;29b7	32 5f c0	2 _ .  ; [ram_debounce_timer - Debounce timer (97 refs - MOST REFERENCED)]
	ret			;29ba	c9		.
	call sol11_activate		;29bb	cd 89 07	. . .
	ret			;29be	c9		.
	call sol12_activate		;29bf	cd a6 07	. . .
	ret			;29c2	c9		.
	ld hl,l0014h		;29c3	21 14 00	! . .
	ld (0c04fh),hl		;29c6	22 4f c0	" O .  ; [ram_timer_aux - Auxiliary timer counter]
	ld a,0ffh		;29c9	3e ff		> .
	ld (0c051h),a		;29cb	32 51 c0	2 Q .  ; [ram_game_timer - Game timer (ball time / bonus countdown)]
	call sub_08d3h		;29ce	cd d3 08	. . .
l29d1h:
	ld a,(0c051h)		;29d1	3a 51 c0	: Q .  ; [ram_game_timer - Game timer (ball time / bonus countdown)]
	and a			;29d4	a7		.
	jp nz,l29d1h		;29d5	c2 d1 29	. . )
	call sub_08f1h		;29d8	cd f1 08	. . .
	ld a,01eh		;29db	3e 1e		> .
	ld (0c05fh),a		;29dd	32 5f c0	2 _ .  ; [ram_debounce_timer - Debounce timer (97 refs - MOST REFERENCED)]
	ret			;29e0	c9		.
sub_29e1h:
	ld hl,l012ch		;29e1	21 2c 01	! , .
	ld (0c04fh),hl		;29e4	22 4f c0	" O .  ; [ram_timer_aux - Auxiliary timer counter]
	ld a,0ffh		;29e7	3e ff		> .
	ld (0c051h),a		;29e9	32 51 c0	2 Q .  ; [ram_game_timer - Game timer (ball time / bonus countdown)]
	call sub_07e0h		;29ec	cd e0 07	. . .
	ld a,(0c068h)		;29ef	3a 68 c0	: h .  ; [ram_game_active - Game active flag (0=attract, nonzero=playing)]
	and a			;29f2	a7		.
	ret nz			;29f3	c0		.
	call sub_372eh		;29f4	cd 2e 37	. . 7
	ret			;29f7	c9		.
	call sol5_activate		;29f8	cd db 06	. . .
	ret			;29fb	c9		.
	call sol6_activate		;29fc	cd f8 06	. . .
	ret			;29ff	c9		.
	call sol7_activate		;2a00	cd 15 07	. . .
	ret			;2a03	c9		.
l2a04h:
	call sol8_activate		;2a04	cd 32 07	. 2 .
	ret			;2a07	c9		.
	call sol9_activate		;2a08	cd 4f 07	. O .
	ret			;2a0b	c9		.
l2a0ch:
	call sol13_activate		;2a0c	cd c3 07	. . .
	ret			;2a0f	c9		.
	ld a,(0c068h)		;2a10	3a 68 c0	: h .  ; [ram_game_active - Game active flag (0=attract, nonzero=playing)]
	and a			;2a13	a7		.
	jp nz,sub_08ffh		;2a14	c2 ff 08	. . .
	ld a,0ffh		;2a17	3e ff		> .
	ld (0c05dh),a		;2a19	32 5d c0	2 ] .
	ret			;2a1c	c9		.
	xor a			;2a1d	af		.
	ld (0c05dh),a		;2a1e	32 5d c0	2 ] .
	ret			;2a21	c9		.
l2a22h:
	ld a,(0c068h)		;2a22	3a 68 c0	: h .  ; [ram_game_active - Game active flag (0=attract, nonzero=playing)]
	and a			;2a25	a7		.
	jp nz,sub_0957h		;2a26	c2 57 09	. W .
	ld a,0ffh		;2a29	3e ff		> .
	ld (0c05ch),a		;2a2b	32 5c c0	2 \ .
	ret			;2a2e	c9		.
	xor a			;2a2f	af		.
	ld (0c05ch),a		;2a30	32 5c c0	2 \ .
	ret			;2a33	c9		.
l2a34h:
	ret			;2a34	c9		.
	ret			;2a35	c9		.
l2a36h:
	call sol10_activate		;2a36	cd 6c 07	. l .
	ret			;2a39	c9		.
l2a3ah:
	ld a,0ffh		;2a3a	3e ff		> .
	ld (0c054h),a		;2a3c	32 54 c0	2 T .
	ret			;2a3f	c9		.
	xor a			;2a40	af		.
	ld (0c054h),a		;2a41	32 54 c0	2 T .
	ret			;2a44	c9		.
	call scan_begin_cycle		;2a45	cd 73 2e	. s .  ; → scan_begin_cycle
	call game_state_update		;2a48	cd 5e 13	. ^ .
	call lamp_strobe_cycle		;2a4b	cd ed 32	. . 2
	ld hl,0c070h		;2a4e	21 70 c0	! p .
	ld (hl),000h		;2a51	36 00		6 .
	ld a,(0c0dbh)		;2a53	3a db c0	: . .  ; [ram_row0_switches - Matrix row 0 debounced switch state]
	bit 0,a			;2a56	cb 47		. G
	jp nz,l2a5ch		;2a58	c2 5c 2a	. \ *
	inc (hl)		;2a5b	34		4
l2a5ch:
	bit 1,a			;2a5c	cb 4f		. O
	jp nz,l2a62h		;2a5e	c2 62 2a	. b *
	inc (hl)		;2a61	34		4
l2a62h:
	bit 2,a			;2a62	cb 57		. W
	jp nz,l2a68h		;2a64	c2 68 2a	. h *
	inc (hl)		;2a67	34		4
l2a68h:
	ld a,(hl)		;2a68	7e		~
	cp 001h			;2a69	fe 01		. .
	jp z,l2a88h		;2a6b	ca 88 2a	. . *
	cp 002h			;2a6e	fe 02		. .
	jp z,l2a98h		;2a70	ca 98 2a	. . *
	cp 003h			;2a73	fe 03		. .
	jp z,l2aa8h		;2a75	ca a8 2a	. . *
	ld a,(0c0dbh)		;2a78	3a db c0	: . .  ; [ram_row0_switches - Matrix row 0 debounced switch state]
	bit 3,a			;2a7b	cb 5f		. _
	jp z,l2a90h		;2a7d	ca 90 2a	. . *
	ld a,048h		;2a80	3e 48		> H
	ld (0c0fch),a		;2a82	32 fc c0	2 . .  ; [ram_switch_mailbox - *** MAILBOX BYTE *** Switch code → 80188 (86 refs!)]
	jp send_to_80188		;2a85	c3 16 01	. . .  ; → send_to_80188
l2a88h:
	ld a,(0c0dbh)		;2a88	3a db c0	: . .  ; [ram_row0_switches - Matrix row 0 debounced switch state]
	bit 3,a			;2a8b	cb 5f		. _
	jp z,l2aa0h		;2a8d	ca a0 2a	. . *
l2a90h:
	ld a,038h		;2a90	3e 38		> 8
	ld (0c0fch),a		;2a92	32 fc c0	2 . .  ; [ram_switch_mailbox - *** MAILBOX BYTE *** Switch code → 80188 (86 refs!)]
	jp send_to_80188		;2a95	c3 16 01	. . .  ; → send_to_80188
l2a98h:
	ld a,(0c0dbh)		;2a98	3a db c0	: . .  ; [ram_row0_switches - Matrix row 0 debounced switch state]
	bit 3,a			;2a9b	cb 5f		. _
	jp z,l2aa8h		;2a9d	ca a8 2a	. . *
l2aa0h:
	ld a,039h		;2aa0	3e 39		> 9
	ld (0c0fch),a		;2aa2	32 fc c0	2 . .  ; [ram_switch_mailbox - *** MAILBOX BYTE *** Switch code → 80188 (86 refs!)]
	jp send_to_80188		;2aa5	c3 16 01	. . .  ; → send_to_80188
;  XREF: 2 refs from 0x2A75, 0x2A9D
l2aa8h:
	ld a,03ah		;2aa8	3e 3a		> :
	ld (0c0fch),a		;2aaa	32 fc c0	2 . .  ; [ram_switch_mailbox - *** MAILBOX BYTE *** Switch code → 80188 (86 refs!)]
	jp send_to_80188		;2aad	c3 16 01	. . .  ; → send_to_80188
l2ab0h:
	call scan_row_helper		;2ab0	cd b3 2e	. . .
	call game_state_update		;2ab3	cd 5e 13	. ^ .
	call lamp_effect_update		;2ab6	cd 1d 33	. . 3
	ld hl,0c06fh		;2ab9	21 6f c0	! o .
	ld (hl),000h		;2abc	36 00		6 .
	ld a,(0c0dfh)		;2abe	3a df c0	: . .  ; [ram_row4_switches - Matrix row 4 debounced switch state]
	bit 0,a			;2ac1	cb 47		. G
	jp nz,l2ac7h		;2ac3	c2 c7 2a	. . *
	inc (hl)		;2ac6	34		4
l2ac7h:
	bit 1,a			;2ac7	cb 4f		. O
	jp nz,l2acdh		;2ac9	c2 cd 2a	. . *
	inc (hl)		;2acc	34		4
l2acdh:
	bit 2,a			;2acd	cb 57		. W
	jp nz,l2ad3h		;2acf	c2 d3 2a	. . *
	inc (hl)		;2ad2	34		4
l2ad3h:
	ld a,(hl)		;2ad3	7e		~
	cp 001h			;2ad4	fe 01		. .
	jp z,l2aebh		;2ad6	ca eb 2a	. . *
	cp 002h			;2ad9	fe 02		. .
	jp z,l2af3h		;2adb	ca f3 2a	. . *
	cp 003h			;2ade	fe 03		. .
	jp z,l2aebh		;2ae0	ca eb 2a	. . *
	ld a,049h		;2ae3	3e 49		> I
	ld (0c0fch),a		;2ae5	32 fc c0	2 . .  ; [ram_switch_mailbox - *** MAILBOX BYTE *** Switch code → 80188 (86 refs!)]
	jp send_to_80188		;2ae8	c3 16 01	. . .  ; → send_to_80188
;  XREF: 2 refs from 0x2AD6, 0x2AE0
l2aebh:
	ld a,03bh		;2aeb	3e 3b		> ;
	ld (0c0fch),a		;2aed	32 fc c0	2 . .  ; [ram_switch_mailbox - *** MAILBOX BYTE *** Switch code → 80188 (86 refs!)]
	jp send_to_80188		;2af0	c3 16 01	. . .  ; → send_to_80188
l2af3h:
	ld a,03ch		;2af3	3e 3c		> <
	ld (0c0fch),a		;2af5	32 fc c0	2 . .  ; [ram_switch_mailbox - *** MAILBOX BYTE *** Switch code → 80188 (86 refs!)]
	jp send_to_80188		;2af8	c3 16 01	. . .  ; → send_to_80188
	ld a,03dh		;2afb	3e 3d		> =
	ld (0c0fch),a		;2afd	32 fc c0	2 . .  ; [ram_switch_mailbox - *** MAILBOX BYTE *** Switch code → 80188 (86 refs!)]
	jp send_to_80188		;2b00	c3 16 01	. . .  ; → send_to_80188
	call scan_begin_cycle		;2b03	cd 73 2e	. s .  ; → scan_begin_cycle
	call game_state_update		;2b06	cd 5e 13	. ^ .
	call lamp_strobe_cycle		;2b09	cd ed 32	. . 2
	ld a,(0c0dbh)		;2b0c	3a db c0	: . .  ; [ram_row0_switches - Matrix row 0 debounced switch state]
	bit 3,a			;2b0f	cb 5f		. _
	jp z,l2b63h		;2b11	ca 63 2b	. c +
	ld a,005h		;2b14	3e 05		> .
	ld (0c048h),a		;2b16	32 48 c0	2 H .
l2b19h:
	ld hl,l03e8h		;2b19	21 e8 03	! . .
	ld (0c04ch),hl		;2b1c	22 4c c0	" L .  ; [ram_sw_queue_wptr - Switch event queue write pointer]
	ld a,0ffh		;2b1f	3e ff		> .
	ld (0c04eh),hl		;2b21	22 4e c0	" N .  ; [ram_timer_flag - Main timer flag (controls game timing)]
	call sub_08a7h		;2b24	cd a7 08	. . .
l2b27h:
	call scan_begin_cycle		;2b27	cd 73 2e	. s .  ; → scan_begin_cycle
	call game_state_update		;2b2a	cd 5e 13	. ^ .
	call lamp_strobe_cycle		;2b2d	cd ed 32	. . 2
	ld a,(0c0dbh)		;2b30	3a db c0	: . .  ; [ram_row0_switches - Matrix row 0 debounced switch state]
	bit 3,a			;2b33	cb 5f		. _
	jp z,l2b63h		;2b35	ca 63 2b	. c +
	ld a,(0c04eh)		;2b38	3a 4e c0	: N .  ; [ram_timer_flag - Main timer flag (controls game timing)]
	and a			;2b3b	a7		.
	jp z,l2b42h		;2b3c	ca 42 2b	. B +
	jp l2b27h		;2b3f	c3 27 2b	. ' +
l2b42h:
	call sub_08c5h		;2b42	cd c5 08	. . .
	ld a,01eh		;2b45	3e 1e		> .
	ld (0c05fh),a		;2b47	32 5f c0	2 _ .  ; [ram_debounce_timer - Debounce timer (97 refs - MOST REFERENCED)]
	ld a,(0c048h)		;2b4a	3a 48 c0	: H .
	and a			;2b4d	a7		.
	jp z,l2b5bh		;2b4e	ca 5b 2b	. [ +
	dec a			;2b51	3d		=
	ld (0c048h),a		;2b52	32 48 c0	2 H .
	call sub_2b73h		;2b55	cd 73 2b	. s +
	jp l2b19h		;2b58	c3 19 2b	. . +
l2b5bh:
	ld a,04ah		;2b5b	3e 4a		> J
	ld (0c0fch),a		;2b5d	32 fc c0	2 . .  ; [ram_switch_mailbox - *** MAILBOX BYTE *** Switch code → 80188 (86 refs!)]
	jp send_to_80188		;2b60	c3 16 01	. . .  ; → send_to_80188
;  XREF: 2 refs from 0x2B11, 0x2B35
l2b63h:
	call sub_08c5h		;2b63	cd c5 08	. . .
	ld a,01eh		;2b66	3e 1e		> .
	ld (0c05fh),a		;2b68	32 5f c0	2 _ .  ; [ram_debounce_timer - Debounce timer (97 refs - MOST REFERENCED)]
	ld a,045h		;2b6b	3e 45		> E
	ld (0c0fch),a		;2b6d	32 fc c0	2 . .  ; [ram_switch_mailbox - *** MAILBOX BYTE *** Switch code → 80188 (86 refs!)]
	jp send_to_80188		;2b70	c3 16 01	. . .  ; → send_to_80188
sub_2b73h:
	ld hl,l0064h		;2b73	21 64 00	! d .
	ld (0c04fh),hl		;2b76	22 4f c0	" O .  ; [ram_timer_aux - Auxiliary timer counter]
	ld a,0ffh		;2b79	3e ff		> .
	ld (0c051h),a		;2b7b	32 51 c0	2 Q .  ; [ram_game_timer - Game timer (ball time / bonus countdown)]
l2b7eh:
	ld a,(0c051h)		;2b7e	3a 51 c0	: Q .  ; [ram_game_timer - Game timer (ball time / bonus countdown)]
	and a			;2b81	a7		.
	jp nz,l2b7eh		;2b82	c2 7e 2b	. ~ +
	ret			;2b85	c9		.
	call scan_row_helper		;2b86	cd b3 2e	. . .
	call game_state_update		;2b89	cd 5e 13	. ^ .
	call lamp_effect_update		;2b8c	cd 1d 33	. . 3
	ld a,(0c0dfh)		;2b8f	3a df c0	: . .  ; [ram_row4_switches - Matrix row 4 debounced switch state]
	bit 0,a			;2b92	cb 47		. G
	jp nz,l2bc6h		;2b94	c2 c6 2b	. . +
	call sol13_activate		;2b97	cd c3 07	. . .
l2b9ah:
	call scan_row_helper		;2b9a	cd b3 2e	. . .
	call game_state_update		;2b9d	cd 5e 13	. ^ .
	call lamp_effect_update		;2ba0	cd 1d 33	. . 3
	ld a,(0c0dfh)		;2ba3	3a df c0	: . .  ; [ram_row4_switches - Matrix row 4 debounced switch state]
	bit 0,a			;2ba6	cb 47		. G
	jp z,l2b9ah		;2ba8	ca 9a 2b	. . +
l2babh:
	ld a,(0c017h)		;2bab	3a 17 c0	: . .
	and a			;2bae	a7		.
	jp z,l2bc6h		;2baf	ca c6 2b	. . +
	call scan_row_helper		;2bb2	cd b3 2e	. . .
	call game_state_update		;2bb5	cd 5e 13	. ^ .
	call lamp_effect_update		;2bb8	cd 1d 33	. . 3
	ld a,(0c0dfh)		;2bbb	3a df c0	: . .  ; [ram_row4_switches - Matrix row 4 debounced switch state]
	bit 0,a			;2bbe	cb 47		. G
	jp nz,l2babh		;2bc0	c2 ab 2b	. . +
	call sub_0885h		;2bc3	cd 85 08	. . .
;  XREF: 2 refs from 0x2B94, 0x2BAF
l2bc6h:
	ret			;2bc6	c9		.
;  XREF: 3 refs from 0x2BD2, 0x2BD9, 0x2BE8
l2bc7h:
	call sub_2c1fh		;2bc7	cd 1f 2c	. . ,
	and a			;2bca	a7		.
	jp z,l2c17h		;2bcb	ca 17 2c	. . ,
	call sub_2c41h		;2bce	cd 41 2c	. A ,
	and a			;2bd1	a7		.
	jp z,l2bc7h		;2bd2	ca c7 2b	. . +
	call sub_2c65h		;2bd5	cd 65 2c	. e ,
	and a			;2bd8	a7		.
	jp z,l2bc7h		;2bd9	ca c7 2b	. . +
	call sub_2cfbh		;2bdc	cd fb 2c	. . ,
	ld hl,l0320h		;2bdf	21 20 03	!   .
	ld (0c04ch),hl		;2be2	22 4c c0	" L .  ; [ram_sw_queue_wptr - Switch event queue write pointer]
	call sub_2d41h		;2be5	cd 41 2d	. A -
	jp l2bc7h		;2be8	c3 c7 2b	. . +
;  XREF: 2 refs from 0x2C06, 0x2C14
l2bebh:
	in a,(004h)		;2beb	db 04		. .  ; << PORT_DIRECT_SW_2 - Direct switches (bit0=TILT, special inputs)
	bit 5,a			;2bed	cb 6f		. o
	jp z,l2c17h		;2bef	ca 17 2c	. . ,
	call sub_2c1fh		;2bf2	cd 1f 2c	. . ,
	and a			;2bf5	a7		.
	jp nz,l2bffh		;2bf6	c2 ff 2b	. . +
	call sub_2851h		;2bf9	cd 51 28	. Q (
	jp l2c17h		;2bfc	c3 17 2c	. . ,
l2bffh:
	call sub_2831h		;2bff	cd 31 28	. 1 (
	call sub_2c41h		;2c02	cd 41 2c	. A ,
	and a			;2c05	a7		.
	jp z,l2bebh		;2c06	ca eb 2b	. . +
	ld a,046h		;2c09	3e 46		> F
	ld (0c0fch),a		;2c0b	32 fc c0	2 . .  ; [ram_switch_mailbox - *** MAILBOX BYTE *** Switch code → 80188 (86 refs!)]
	call send_to_80188		;2c0e	cd 16 01	. . .  ; → send_to_80188
	call sub_2cfbh		;2c11	cd fb 2c	. . ,
	jp l2bebh		;2c14	c3 eb 2b	. . +
;  XREF: 4 refs from 0x2BCB, 0x2BEF, 0x2BFC, 0x2D59
l2c17h:
	ld a,045h		;2c17	3e 45		> E
	ld (0c0fch),a		;2c19	32 fc c0	2 . .  ; [ram_switch_mailbox - *** MAILBOX BYTE *** Switch code → 80188 (86 refs!)]
	jp send_to_80188		;2c1c	c3 16 01	. . .  ; → send_to_80188
sub_2c1fh:
	call scan_begin_cycle		;2c1f	cd 73 2e	. s .  ; → scan_begin_cycle
	call game_state_update		;2c22	cd 5e 13	. ^ .
	call lamp_strobe_cycle		;2c25	cd ed 32	. . 2
	ld a,(0c0dbh)		;2c28	3a db c0	: . .  ; [ram_row0_switches - Matrix row 0 debounced switch state]
	and 007h		;2c2b	e6 07		. .
	cp 000h			;2c2d	fe 00		. .
	jp z,l2c3fh		;2c2f	ca 3f 2c	. ? ,
	ld a,(0c0dbh)		;2c32	3a db c0	: . .  ; [ram_row0_switches - Matrix row 0 debounced switch state]
	and 00eh		;2c35	e6 0e		. .
	cp 000h			;2c37	fe 00		. .
	jp z,l2c3fh		;2c39	ca 3f 2c	. ? ,
	ld a,0ffh		;2c3c	3e ff		> .
	ret			;2c3e	c9		.
;  XREF: 2 refs from 0x2C2F, 0x2C39
l2c3fh:
	xor a			;2c3f	af		.
	ret			;2c40	c9		.
sub_2c41h:
	call scan_row_helper		;2c41	cd b3 2e	. . .
	call game_state_update		;2c44	cd 5e 13	. ^ .
	call lamp_effect_update		;2c47	cd 1d 33	. . 3
	ld a,(0c0dfh)		;2c4a	3a df c0	: . .  ; [ram_row4_switches - Matrix row 4 debounced switch state]
	and 007h		;2c4d	e6 07		. .
	cp 007h			;2c4f	fe 07		. .
	jp z,l2c5ch		;2c51	ca 5c 2c	. \ ,
	call sol13_activate		;2c54	cd c3 07	. . .
	call game_logic_lanes		;2c57	cd 3b 2d	. ; -
	xor a			;2c5a	af		.
	ret			;2c5b	c9		.
l2c5ch:
	call sol13_activate		;2c5c	cd c3 07	. . .
	call game_logic_lanes		;2c5f	cd 3b 2d	. ; -
	ld a,0ffh		;2c62	3e ff		> .
	ret			;2c64	c9		.
sub_2c65h:
	call sub_2ea3h		;2c65	cd a3 2e	. . .
	call game_state_update		;2c68	cd 5e 13	. ^ .
	call sub_3311h		;2c6b	cd 11 33	. . 3
	ld a,(0c0deh)		;2c6e	3a de c0	: . .  ; [ram_row3_switches - Matrix row 3 debounced switch state]
	bit 0,a			;2c71	cb 47		. G
	jp z,l2c79h		;2c73	ca 79 2c	. y ,
	ld a,0ffh		;2c76	3e ff		> .
	ret			;2c78	c9		.
l2c79h:
	call sub_29e1h		;2c79	cd e1 29	. . )
	ld hl,l0320h		;2c7c	21 20 03	!   .
	ld (0c04ch),hl		;2c7f	22 4c c0	" L .  ; [ram_sw_queue_wptr - Switch event queue write pointer]
	call sub_2d41h		;2c82	cd 41 2d	. A -
	xor a			;2c85	af		.
	ret			;2c86	c9		.
	call game_logic_bumpers		;2c87	cd c7 2c	. . ,
	call sub_0957h		;2c8a	cd 57 09	. W .
	call game_logic_bumpers		;2c8d	cd c7 2c	. . ,
	call sub_08ffh		;2c90	cd ff 08	. . .
	call game_logic_bumpers		;2c93	cd c7 2c	. . ,
	call sol5_activate		;2c96	cd db 06	. . .
	call game_logic_bumpers		;2c99	cd c7 2c	. . ,
	call sol6_activate		;2c9c	cd f8 06	. . .
	call game_logic_bumpers		;2c9f	cd c7 2c	. . ,
	call sol7_activate		;2ca2	cd 15 07	. . .
	call game_logic_bumpers		;2ca5	cd c7 2c	. . ,
	call sol8_activate		;2ca8	cd 32 07	. 2 .
	call game_logic_bumpers		;2cab	cd c7 2c	. . ,
	call sol9_activate		;2cae	cd 4f 07	. O .
	call game_logic_bumpers		;2cb1	cd c7 2c	. . ,
	call sub_07e0h		;2cb4	cd e0 07	. . .
	call game_logic_bumpers		;2cb7	cd c7 2c	. . ,
	call sol11_activate		;2cba	cd 89 07	. . .
	call game_logic_bumpers		;2cbd	cd c7 2c	. . ,
	call sol12_activate		;2cc0	cd a6 07	. . .
	call game_logic_bumpers		;2cc3	cd c7 2c	. . ,
	ret			;2cc6	c9		.
game_logic_bumpers:
	ld hl,00096h		;2cc7	21 96 00	! . .
	ld (0c04ch),hl		;2cca	22 4c c0	" L .  ; [ram_sw_queue_wptr - Switch event queue write pointer]
	xor a			;2ccd	af		.
	ld (0c0fbh),a		;2cce	32 fb c0	2 . .  ; [ram_cmd_done_flag - Command completion flag]
	ld a,0ffh		;2cd1	3e ff		> .
	ld (0c04eh),a		;2cd3	32 4e c0	2 N .  ; [ram_timer_flag - Main timer flag (controls game timing)]
l2cd6h:
	ld a,(0c04eh)		;2cd6	3a 4e c0	: N .  ; [ram_timer_flag - Main timer flag (controls game timing)]
	and a			;2cd9	a7		.
	ret z			;2cda	c8		.
	call check_tilt_sol_tmr		;2cdb	cd bf 0d	. . .
	call scan_state_entry		;2cde	cd 62 2e	. b .
	ld a,(0c0fbh)		;2ce1	3a fb c0	: . .  ; [ram_cmd_done_flag - Command completion flag]
	and a			;2ce4	a7		.
	jp nz,l2cf9h		;2ce5	c2 f9 2c	. . ,
	in a,(003h)		;2ce8	db 03		. .  ; << PORT_DIRECT_SW_1 - Direct switches (bit3=START, bit2=TEST/COIN)
	bit 3,a			;2cea	cb 5f		. _
	jp z,l2cf9h		;2cec	ca f9 2c	. . ,
	in a,(003h)		;2cef	db 03		. .  ; << PORT_DIRECT_SW_1 - Direct switches (bit3=START, bit2=TEST/COIN)
	bit 2,a			;2cf1	cb 57		. W
	jp z,l2cf9h		;2cf3	ca f9 2c	. . ,
	jp l2cd6h		;2cf6	c3 d6 2c	. . ,
;  XREF: 3 refs from 0x2CE5, 0x2CEC, 0x2CF3
l2cf9h:
	pop hl			;2cf9	e1		.
	ret			;2cfa	c9		.
sub_2cfbh:
	call game_logic_lanes		;2cfb	cd 3b 2d	. ; -
	call sub_0957h		;2cfe	cd 57 09	. W .
	call game_logic_lanes		;2d01	cd 3b 2d	. ; -
	call sub_08ffh		;2d04	cd ff 08	. . .
	call game_logic_lanes		;2d07	cd 3b 2d	. ; -
	call sol5_activate		;2d0a	cd db 06	. . .
	call game_logic_lanes		;2d0d	cd 3b 2d	. ; -
	call sol6_activate		;2d10	cd f8 06	. . .
	call game_logic_lanes		;2d13	cd 3b 2d	. ; -
	call sol7_activate		;2d16	cd 15 07	. . .
	call game_logic_lanes		;2d19	cd 3b 2d	. ; -
	call sol8_activate		;2d1c	cd 32 07	. 2 .
	call game_logic_lanes		;2d1f	cd 3b 2d	. ; -
l2d22h:
	call sol9_activate		;2d22	cd 4f 07	. O .
	call game_logic_lanes		;2d25	cd 3b 2d	. ; -
	call sub_07e0h		;2d28	cd e0 07	. . .
	call game_logic_lanes		;2d2b	cd 3b 2d	. ; -
	call sol11_activate		;2d2e	cd 89 07	. . .
	call game_logic_lanes		;2d31	cd 3b 2d	. ; -
	call sol12_activate		;2d34	cd a6 07	. . .
	call game_logic_lanes		;2d37	cd 3b 2d	. ; -
	ret			;2d3a	c9		.
game_logic_lanes:
	ld hl,00096h		;2d3b	21 96 00	! . .
	ld (0c04ch),hl		;2d3e	22 4c c0	" L .  ; [ram_sw_queue_wptr - Switch event queue write pointer]
sub_2d41h:
	ld a,0ffh		;2d41	3e ff		> .
	ld (0c04eh),a		;2d43	32 4e c0	2 N .  ; [ram_timer_flag - Main timer flag (controls game timing)]
l2d46h:
	ld a,(0c04eh)		;2d46	3a 4e c0	: N .  ; [ram_timer_flag - Main timer flag (controls game timing)]
	and a			;2d49	a7		.
	ret z			;2d4a	c8		.
	call check_tilt_sol_tmr		;2d4b	cd bf 0d	. . .
	call sub_2c1fh		;2d4e	cd 1f 2c	. . ,
	and a			;2d51	a7		.
	jp z,l2d58h		;2d52	ca 58 2d	. X -
	jp l2d46h		;2d55	c3 46 2d	. F -
l2d58h:
	pop hl			;2d58	e1		.
	jp l2c17h		;2d59	c3 17 2c	. . ,
	di			;2d5c	f3		.
	call sub_235ah		;2d5d	cd 5a 23	. Z #
	call l2376h		;2d60	cd 76 23	. v #
	call l2392h		;2d63	cd 92 23	. . #
	call l23aeh		;2d66	cd ae 23	. . #
	call l23cah		;2d69	cd ca 23	. . #
	call l2217h		;2d6c	cd 17 22	. . "
	call sub_222dh		;2d6f	cd 2d 22	. - "
	call sub_2243h		;2d72	cd 43 22	. C "
	call sub_2734h		;2d75	cd 34 27	. 4 '
	call sub_2679h		;2d78	cd 79 26	. y &
	call sub_24d6h		;2d7b	cd d6 24	. . $
	call sub_24e7h		;2d7e	cd e7 24	. . $
	call sub_24f8h		;2d81	cd f8 24	. . $
	call sub_2509h		;2d84	cd 09 25	. . %
	call sub_251ah		;2d87	cd 1a 25	. . %
	ei			;2d8a	fb		.
	ret			;2d8b	c9		.
l2d8ch:
	ld a,(l003bh)		;2d8c	3a 3b 00	: ; .
	or 0f0h			;2d8f	f6 f0		. .
	ld (0c0fch),a		;2d91	32 fc c0	2 . .  ; [ram_switch_mailbox - *** MAILBOX BYTE *** Switch code → 80188 (86 refs!)]
	jp send_to_80188		;2d94	c3 16 01	. . .  ; → send_to_80188
	ld a,0a5h		;2d97	3e a5		> .
	ld (0c052h),a		;2d99	32 52 c0	2 R .  ; [ram_timer_52 - Timer register 0x52]
	ret			;2d9c	c9		.
	in a,(004h)		;2d9d	db 04		. .  ; << PORT_DIRECT_SW_2 - Direct switches (bit0=TILT, special inputs)
	or 0f0h			;2d9f	f6 f0		. .
	ld (0c0fch),a		;2da1	32 fc c0	2 . .  ; [ram_switch_mailbox - *** MAILBOX BYTE *** Switch code → 80188 (86 refs!)]
	jp send_to_80188		;2da4	c3 16 01	. . .  ; → send_to_80188
;  XREF: 2 refs from 0x2DAC, 0x2DC0
l2da7h:
	ld hl,(0c072h)		;2da7	2a 72 c0	* r .  ; [ram_sw_queue_rptr - Switch event queue read pointer]
	ld a,(hl)		;2daa	7e		~
	and a			;2dab	a7		.
	jp z,l2da7h		;2dac	ca a7 2d	. . -
	ld (hl),000h		;2daf	36 00		6 .
	inc hl			;2db1	23		#
	ld (0c072h),hl		;2db2	22 72 c0	" r .  ; [ram_sw_queue_rptr - Switch event queue read pointer]
	cp 0fbh			;2db5	fe fb		. .
	jp z,l2dc3h		;2db7	ca c3 2d	. . -
	ld (0c0fch),a		;2dba	32 fc c0	2 . .  ; [ram_switch_mailbox - *** MAILBOX BYTE *** Switch code → 80188 (86 refs!)]
	call send_to_80188		;2dbd	cd 16 01	. . .  ; → send_to_80188
	jp l2da7h		;2dc0	c3 a7 2d	. . -
l2dc3h:
	ret			;2dc3	c9		.
	pop hl			;2dc4	e1		.
	ld a,0ffh		;2dc5	3e ff		> .
	ld (0c068h),a		;2dc7	32 68 c0	2 h .  ; [ram_game_active - Game active flag (0=attract, nonzero=playing)]
	call sub_3534h		;2dca	cd 34 35	. 4 5
	call sub_27c0h		;2dcd	cd c0 27	. . '
	call sub_27edh		;2dd0	cd ed 27	. . '
	call sub_24c7h		;2dd3	cd c7 24	. . $
	jp l2de1h		;2dd6	c3 e1 2d	. . -
	xor a			;2dd9	af		.
	ld (0c068h),a		;2dda	32 68 c0	2 h .  ; [ram_game_active - Game active flag (0=attract, nonzero=playing)]
	di			;2ddd	f3		.
	jp main_init		;2dde	c3 00 04	. . .  ; → main_init
l2de1h:
	ld a,0ffh		;2de1	3e ff		> .
	ld (0c04eh),a		;2de3	32 4e c0	2 N .  ; [ram_timer_flag - Main timer flag (controls game timing)]
	ld hl,l0001h		;2de6	21 01 00	! . .
	ld (0c04ch),hl		;2de9	22 4c c0	" L .  ; [ram_sw_queue_wptr - Switch event queue write pointer]
l2dech:
	call sub_2e10h		;2dec	cd 10 2e	. . .
	call check_tilt_sol_tmr		;2def	cd bf 0d	. . .
	call switch_event_dispatch		;2df2	cd d5 16	. . .
	in a,(003h)		;2df5	db 03		. .  ; << PORT_DIRECT_SW_1 - Direct switches (bit3=START, bit2=TEST/COIN)
	bit 2,a			;2df7	cb 57		. W
	call z,handler_coin_insert	;2df9	cc d8 12	. . .
	in a,(003h)		;2dfc	db 03		. .  ; << PORT_DIRECT_SW_1 - Direct switches (bit3=START, bit2=TEST/COIN)
	bit 3,a			;2dfe	cb 5f		. _
	call z,handler_start_btn	;2e00	cc 92 12	. . .
	ld a,(0c0e3h)		;2e03	3a e3 c0	: . .  ; [ram_direct_switches - Direct switch debounced state (flippers etc)]
	or 0ech			;2e06	f6 ec		. .
	cp 0ffh			;2e08	fe ff		. .
	call nz,flipper_event_handler	;2e0a	c4 42 12	. B .
	jp l2dech		;2e0d	c3 ec 2d	. . -
sub_2e10h:
	ld a,(0c04eh)		;2e10	3a 4e c0	: N .  ; [ram_timer_flag - Main timer flag (controls game timing)]
	and a			;2e13	a7		.
	ret nz			;2e14	c0		.
	call scan_state_entry		;2e15	cd 62 2e	. b .
	ld a,0ffh		;2e18	3e ff		> .
	ld (0c04eh),a		;2e1a	32 4e c0	2 N .  ; [ram_timer_flag - Main timer flag (controls game timing)]
	ld hl,l0001h		;2e1d	21 01 00	! . .
	ld (0c04ch),hl		;2e20	22 4c c0	" L .  ; [ram_sw_queue_wptr - Switch event queue write pointer]
	ret			;2e23	c9		.
	ld a,047h		;2e24	3e 47		> G
	ld (0c0fch),a		;2e26	32 fc c0	2 . .  ; [ram_switch_mailbox - *** MAILBOX BYTE *** Switch code → 80188 (86 refs!)]
	call send_to_80188		;2e29	cd 16 01	. . .  ; → send_to_80188
	ld hl,l0190h		;2e2c	21 90 01	! . .
	ld (0c04ch),hl		;2e2f	22 4c c0	" L .  ; [ram_sw_queue_wptr - Switch event queue write pointer]
	ld a,0ffh		;2e32	3e ff		> .
	ld (0c04eh),a		;2e34	32 4e c0	2 N .  ; [ram_timer_flag - Main timer flag (controls game timing)]
l2e37h:
	ld a,(0c04eh)		;2e37	3a 4e c0	: N .  ; [ram_timer_flag - Main timer flag (controls game timing)]
	and a			;2e3a	a7		.
	jp nz,l2e37h		;2e3b	c2 37 2e	. 7 .
	ret			;2e3e	c9		.
	call sub_36ddh		;2e3f	cd dd 36	. . 6
l2e42h:
	in a,(004h)		;2e42	db 04		. .  ; << PORT_DIRECT_SW_2 - Direct switches (bit0=TILT, special inputs)
	bit 7,a			;2e44	cb 7f		. .
	jp z,l2e42h		;2e46	ca 42 2e	. B .
	di			;2e49	f3		.
	call sub_3534h		;2e4a	cd 34 35	. 4 5
	jp main_init		;2e4d	c3 00 04	. . .  ; → main_init
	call sub_368ch		;2e50	cd 8c 36	. . 6
	ret			;2e53	c9		.
sub_2e54h:
	in a,(003h)		;2e54	db 03		. .  ; << PORT_DIRECT_SW_1 - Direct switches (bit3=START, bit2=TEST/COIN)
	ld hl,0c0f7h		;2e56	21 f7 c0	! . .
	cpl			;2e59	2f		/
	ld (hl),a		;2e5a	77		w
	cpl			;2e5b	2f		/
	inc hl			;2e5c	23		#
	or (hl)			;2e5d	b6		.
	ld (0c0e3h),a		;2e5e	32 e3 c0	2 . .  ; [ram_direct_switches - Direct switch debounced state (flippers etc)]
	ret			;2e61	c9		.
scan_state_entry:

; ─────────────────────────────────────────────────────────────────────────────
; scan_state_entry (0x2E62)
; Scan state machine entry (called from main loop)
; ─────────────────────────────────────────────────────────────────────────────
scan_state_entry:
	in a,(003h)		;2e62	db 03		. .  ; << PORT_DIRECT_SW_1 - Direct switches (bit3=START, bit2=TEST/COIN)
	ld hl,0c0f7h		;2e64	21 f7 c0	! . .
	cpl			;2e67	2f		/
	ld (hl),a		;2e68	77		w
	cpl			;2e69	2f		/
	inc hl			;2e6a	23		#
	or (hl)			;2e6b	b6		.
	ld (0c0e3h),a		;2e6c	32 e3 c0	2 . .  ; [ram_direct_switches - Direct switch debounced state (flippers etc)]
	ld hl,(0c0e5h)		;2e6f	2a e5 c0	* . .  ; [ram_scan_state_lo - Scan state machine pointer low byte]
	jp (hl)			;2e72	e9		.

; =============================================================================
; SWITCH MATRIX SCAN STATE MACHINE
; =============================================================================

; ─────────────────────────────────────────────────────────────────────────────
; scan_begin_cycle (0x2E73)
; Begin new scan cycle: set row 0 strobe
; XREF: 6 references from 0x28AC, 0x28EE, 0x2A45, 0x2B03, 0x2B27, 0x2C1F
; ─────────────────────────────────────────────────────────────────────────────
scan_begin_cycle:
	ld a,001h		;2e73	3e 01		> .
	out (082h),a		;2e75	d3 82		. .  ; >> PORT_LAMP_COL - Lamp matrix column strobe select
	ld hl,scan_matrix_row0		;2e77	21 d3 2e	! . .
	ld (0c0e5h),hl		;2e7a	22 e5 c0	" . .  ; [ram_scan_state_lo - Scan state machine pointer low byte]
	ld a,002h		;2e7d	3e 02		> .
	ld (0c0f9h),a		;2e7f	32 f9 c0	2 . .  ; [ram_scan_debounce - Scan cycle debounce counter]
	ret			;2e82	c9		.
sub_2e83h:
	ld a,002h		;2e83	3e 02		> .
	out (082h),a		;2e85	d3 82		. .  ; >> PORT_LAMP_COL - Lamp matrix column strobe select
	ld hl,scan_matrix_row1		;2e87	21 01 2f	! . /
	ld (0c0e5h),hl		;2e8a	22 e5 c0	" . .  ; [ram_scan_state_lo - Scan state machine pointer low byte]
	ld a,002h		;2e8d	3e 02		> .
	ld (0c0f9h),a		;2e8f	32 f9 c0	2 . .  ; [ram_scan_debounce - Scan cycle debounce counter]
	ret			;2e92	c9		.
	ld a,004h		;2e93	3e 04		> .
	out (082h),a		;2e95	d3 82		. .  ; >> PORT_LAMP_COL - Lamp matrix column strobe select
	ld hl,scan_matrix_row2		;2e97	21 2f 2f	! / /
	ld (0c0e5h),hl		;2e9a	22 e5 c0	" . .  ; [ram_scan_state_lo - Scan state machine pointer low byte]
	ld a,002h		;2e9d	3e 02		> .
	ld (0c0f9h),a		;2e9f	32 f9 c0	2 . .  ; [ram_scan_debounce - Scan cycle debounce counter]
	ret			;2ea2	c9		.
sub_2ea3h:
	ld a,008h		;2ea3	3e 08		> .
	out (082h),a		;2ea5	d3 82		. .  ; >> PORT_LAMP_COL - Lamp matrix column strobe select
	ld hl,scan_matrix_row3		;2ea7	21 5d 2f	! ] /
	ld (0c0e5h),hl		;2eaa	22 e5 c0	" . .  ; [ram_scan_state_lo - Scan state machine pointer low byte]
	ld a,002h		;2ead	3e 02		> .
	ld (0c0f9h),a		;2eaf	32 f9 c0	2 . .  ; [ram_scan_debounce - Scan cycle debounce counter]
	ret			;2eb2	c9		.
scan_row_helper:
	ld a,010h		;2eb3	3e 10		> .
	out (082h),a		;2eb5	d3 82		. .  ; >> PORT_LAMP_COL - Lamp matrix column strobe select
	ld hl,scan_matrix_row4		;2eb7	21 8b 2f	! . /
	ld (0c0e5h),hl		;2eba	22 e5 c0	" . .  ; [ram_scan_state_lo - Scan state machine pointer low byte]
	ld a,002h		;2ebd	3e 02		> .
	ld (0c0f9h),a		;2ebf	32 f9 c0	2 . .  ; [ram_scan_debounce - Scan cycle debounce counter]
	ret			;2ec2	c9		.
l2ec3h:
	ld a,020h		;2ec3	3e 20		>  
	out (082h),a		;2ec5	d3 82		. .  ; >> PORT_LAMP_COL - Lamp matrix column strobe select
	ld hl,scan_matrix_row5		;2ec7	21 b9 2f	! . /
	ld (0c0e5h),hl		;2eca	22 e5 c0	" . .  ; [ram_scan_state_lo - Scan state machine pointer low byte]
	ld a,002h		;2ecd	3e 02		> .
	ld (0c0f9h),a		;2ecf	32 f9 c0	2 . .  ; [ram_scan_debounce - Scan cycle debounce counter]
	ret			;2ed2	c9		.

; ─────────────────────────────────────────────────────────────────────────────
; scan_matrix_row0 (0x2ED3)
; Scan matrix row 0 (strobe=0x01, port 0x02 read)
; ─────────────────────────────────────────────────────────────────────────────
scan_matrix_row0:
	ld a,(0c0f9h)		;2ed3	3a f9 c0	: . .  ; [ram_scan_debounce - Scan cycle debounce counter]
	and a			;2ed6	a7		.
	jp z,l2edfh		;2ed7	ca df 2e	. . .
	dec a			;2eda	3d		=
	ld (0c0f9h),a		;2edb	32 f9 c0	2 . .  ; [ram_scan_debounce - Scan cycle debounce counter]
	ret			;2ede	c9		.
l2edfh:
	ld a,002h		;2edf	3e 02		> .
	ld (0c0f9h),a		;2ee1	32 f9 c0	2 . .  ; [ram_scan_debounce - Scan cycle debounce counter]
	in a,(002h)		;2ee4	db 02		. .  ; << PORT_MATRIX_COL - Switch matrix column data (8 bits, active-low)
	ld hl,0c0e7h		;2ee6	21 e7 c0	! . .
	cpl			;2ee9	2f		/
	ld (hl),a		;2eea	77		w
	cpl			;2eeb	2f		/
	inc hl			;2eec	23		#
	or (hl)			;2eed	b6		.
	ld (0c0dbh),a		;2eee	32 db c0	2 . .  ; [ram_row0_switches - Matrix row 0 debounced switch state]
	cp 0ffh			;2ef1	fe ff		. .
	call nz,sub_2fe7h	;2ef3	c4 e7 2f	. . /
	ld a,002h		;2ef6	3e 02		> .
	out (082h),a		;2ef8	d3 82		. .  ; >> PORT_LAMP_COL - Lamp matrix column strobe select
	ld hl,scan_matrix_row1		;2efa	21 01 2f	! . /
	ld (0c0e5h),hl		;2efd	22 e5 c0	" . .  ; [ram_scan_state_lo - Scan state machine pointer low byte]
	ret			;2f00	c9		.

; ─────────────────────────────────────────────────────────────────────────────
; scan_matrix_row1 (0x2F01)
; Scan matrix row 1 (strobe=0x02)
; ─────────────────────────────────────────────────────────────────────────────
scan_matrix_row1:
	ld a,(0c0f9h)		;2f01	3a f9 c0	: . .  ; [ram_scan_debounce - Scan cycle debounce counter]
	and a			;2f04	a7		.
	jp z,l2f0dh		;2f05	ca 0d 2f	. . /
	dec a			;2f08	3d		=
	ld (0c0f9h),a		;2f09	32 f9 c0	2 . .  ; [ram_scan_debounce - Scan cycle debounce counter]
	ret			;2f0c	c9		.
l2f0dh:
	ld a,002h		;2f0d	3e 02		> .
	ld (0c0f9h),a		;2f0f	32 f9 c0	2 . .  ; [ram_scan_debounce - Scan cycle debounce counter]
	in a,(002h)		;2f12	db 02		. .  ; << PORT_MATRIX_COL - Switch matrix column data (8 bits, active-low)
	ld hl,0c0e9h		;2f14	21 e9 c0	! . .
	cpl			;2f17	2f		/
	ld (hl),a		;2f18	77		w
	cpl			;2f19	2f		/
	inc hl			;2f1a	23		#
	or (hl)			;2f1b	b6		.
	ld (0c0dch),a		;2f1c	32 dc c0	2 . .  ; [ram_row1_switches - Matrix row 1 debounced switch state]
	cp 0ffh			;2f1f	fe ff		. .
	call nz,sub_3028h	;2f21	c4 28 30	. ( 0
	ld a,004h		;2f24	3e 04		> .
	out (082h),a		;2f26	d3 82		. .  ; >> PORT_LAMP_COL - Lamp matrix column strobe select
	ld hl,scan_matrix_row2		;2f28	21 2f 2f	! / /
	ld (0c0e5h),hl		;2f2b	22 e5 c0	" . .  ; [ram_scan_state_lo - Scan state machine pointer low byte]
	ret			;2f2e	c9		.

; ─────────────────────────────────────────────────────────────────────────────
; scan_matrix_row2 (0x2F2F)
; Scan matrix row 2 (strobe=0x04)
; ─────────────────────────────────────────────────────────────────────────────
scan_matrix_row2:
	ld a,(0c0f9h)		;2f2f	3a f9 c0	: . .  ; [ram_scan_debounce - Scan cycle debounce counter]
	and a			;2f32	a7		.
	jp z,l2f3bh		;2f33	ca 3b 2f	. ; /
	dec a			;2f36	3d		=
	ld (0c0f9h),a		;2f37	32 f9 c0	2 . .  ; [ram_scan_debounce - Scan cycle debounce counter]
	ret			;2f3a	c9		.
l2f3bh:
	ld a,002h		;2f3b	3e 02		> .
	ld (0c0f9h),a		;2f3d	32 f9 c0	2 . .  ; [ram_scan_debounce - Scan cycle debounce counter]
	in a,(002h)		;2f40	db 02		. .  ; << PORT_MATRIX_COL - Switch matrix column data (8 bits, active-low)
	ld hl,0c0ebh		;2f42	21 eb c0	! . .
	cpl			;2f45	2f		/
	ld (hl),a		;2f46	77		w
	cpl			;2f47	2f		/
	inc hl			;2f48	23		#
	or (hl)			;2f49	b6		.
	ld (0c0ddh),a		;2f4a	32 dd c0	2 . .  ; [ram_row2_switches - Matrix row 2 debounced switch state]
	cp 0ffh			;2f4d	fe ff		. .
	call nz,sub_3069h	;2f4f	c4 69 30	. i 0
	ld a,008h		;2f52	3e 08		> .
	out (082h),a		;2f54	d3 82		. .  ; >> PORT_LAMP_COL - Lamp matrix column strobe select
	ld hl,scan_matrix_row3		;2f56	21 5d 2f	! ] /
	ld (0c0e5h),hl		;2f59	22 e5 c0	" . .  ; [ram_scan_state_lo - Scan state machine pointer low byte]
	ret			;2f5c	c9		.

; ─────────────────────────────────────────────────────────────────────────────
; scan_matrix_row3 (0x2F5D)
; Scan matrix row 3 (strobe=0x08)
; ─────────────────────────────────────────────────────────────────────────────
scan_matrix_row3:
	ld a,(0c0f9h)		;2f5d	3a f9 c0	: . .  ; [ram_scan_debounce - Scan cycle debounce counter]
	and a			;2f60	a7		.
	jp z,l2f69h		;2f61	ca 69 2f	. i /
	dec a			;2f64	3d		=
	ld (0c0f9h),a		;2f65	32 f9 c0	2 . .  ; [ram_scan_debounce - Scan cycle debounce counter]
	ret			;2f68	c9		.
l2f69h:
	ld a,002h		;2f69	3e 02		> .
	ld (0c0f9h),a		;2f6b	32 f9 c0	2 . .  ; [ram_scan_debounce - Scan cycle debounce counter]
	in a,(002h)		;2f6e	db 02		. .  ; << PORT_MATRIX_COL - Switch matrix column data (8 bits, active-low)
	ld hl,0c0edh		;2f70	21 ed c0	! . .
	cpl			;2f73	2f		/
	ld (hl),a		;2f74	77		w
	cpl			;2f75	2f		/
	inc hl			;2f76	23		#
	or (hl)			;2f77	b6		.
	ld (0c0deh),a		;2f78	32 de c0	2 . .  ; [ram_row3_switches - Matrix row 3 debounced switch state]
	cp 0ffh			;2f7b	fe ff		. .
	call nz,sub_30aah	;2f7d	c4 aa 30	. . 0
	ld a,010h		;2f80	3e 10		> .
	out (082h),a		;2f82	d3 82		. .  ; >> PORT_LAMP_COL - Lamp matrix column strobe select
	ld hl,scan_matrix_row4		;2f84	21 8b 2f	! . /
	ld (0c0e5h),hl		;2f87	22 e5 c0	" . .  ; [ram_scan_state_lo - Scan state machine pointer low byte]
	ret			;2f8a	c9		.

; ─────────────────────────────────────────────────────────────────────────────
; scan_matrix_row4 (0x2F8B)
; Scan matrix row 4 (strobe=0x10)
; ─────────────────────────────────────────────────────────────────────────────
scan_matrix_row4:
	ld a,(0c0f9h)		;2f8b	3a f9 c0	: . .  ; [ram_scan_debounce - Scan cycle debounce counter]
	and a			;2f8e	a7		.
	jp z,l2f97h		;2f8f	ca 97 2f	. . /
	dec a			;2f92	3d		=
	ld (0c0f9h),a		;2f93	32 f9 c0	2 . .  ; [ram_scan_debounce - Scan cycle debounce counter]
	ret			;2f96	c9		.
l2f97h:
	ld a,002h		;2f97	3e 02		> .
	ld (0c0f9h),a		;2f99	32 f9 c0	2 . .  ; [ram_scan_debounce - Scan cycle debounce counter]
	in a,(002h)		;2f9c	db 02		. .  ; << PORT_MATRIX_COL - Switch matrix column data (8 bits, active-low)
	ld hl,0c0efh		;2f9e	21 ef c0	! . .
	cpl			;2fa1	2f		/
	ld (hl),a		;2fa2	77		w
	cpl			;2fa3	2f		/
	inc hl			;2fa4	23		#
	or (hl)			;2fa5	b6		.
	ld (0c0dfh),a		;2fa6	32 df c0	2 . .  ; [ram_row4_switches - Matrix row 4 debounced switch state]
	cp 0ffh			;2fa9	fe ff		. .
	call nz,sub_30ebh	;2fab	c4 eb 30	. . 0
	ld a,020h		;2fae	3e 20		>  
	out (082h),a		;2fb0	d3 82		. .  ; >> PORT_LAMP_COL - Lamp matrix column strobe select
	ld hl,scan_matrix_row5		;2fb2	21 b9 2f	! . /
	ld (0c0e5h),hl		;2fb5	22 e5 c0	" . .  ; [ram_scan_state_lo - Scan state machine pointer low byte]
	ret			;2fb8	c9		.

; ─────────────────────────────────────────────────────────────────────────────
; scan_matrix_row5 (0x2FB9)
; Scan matrix row 5 (strobe=0x20)
; ─────────────────────────────────────────────────────────────────────────────
scan_matrix_row5:
	ld a,(0c0f9h)		;2fb9	3a f9 c0	: . .  ; [ram_scan_debounce - Scan cycle debounce counter]
	and a			;2fbc	a7		.
	jp z,l2fc5h		;2fbd	ca c5 2f	. . /
	dec a			;2fc0	3d		=
	ld (0c0f9h),a		;2fc1	32 f9 c0	2 . .  ; [ram_scan_debounce - Scan cycle debounce counter]
	ret			;2fc4	c9		.
l2fc5h:
	ld a,002h		;2fc5	3e 02		> .
	ld (0c0f9h),a		;2fc7	32 f9 c0	2 . .  ; [ram_scan_debounce - Scan cycle debounce counter]
	in a,(002h)		;2fca	db 02		. .  ; << PORT_MATRIX_COL - Switch matrix column data (8 bits, active-low)
	ld hl,0c0f1h		;2fcc	21 f1 c0	! . .
	cpl			;2fcf	2f		/
	ld (hl),a		;2fd0	77		w
	cpl			;2fd1	2f		/
	inc hl			;2fd2	23		#
	or (hl)			;2fd3	b6		.
	ld (0c0e0h),a		;2fd4	32 e0 c0	2 . .  ; [ram_row5_switches - Matrix row 5 debounced switch state]
	cp 0ffh			;2fd7	fe ff		. .
	call nz,sub_312ch	;2fd9	c4 2c 31	. , 1
	ld a,001h		;2fdc	3e 01		> .
	out (082h),a		;2fde	d3 82		. .  ; >> PORT_LAMP_COL - Lamp matrix column strobe select
	ld hl,scan_matrix_row0		;2fe0	21 d3 2e	! . .
	ld (0c0e5h),hl		;2fe3	22 e5 c0	" . .  ; [ram_scan_state_lo - Scan state machine pointer low byte]
	ret			;2fe6	c9		.
sub_2fe7h:

; ─────────────────────────────────────────────────────────────────────────────
; scan_process_changes (0x2FE7)
; Process changed switch bits: XOR → bit scan → queue
; ─────────────────────────────────────────────────────────────────────────────
scan_process_changes:
	ld a,(0c0dbh)		;2fe7	3a db c0	: . .  ; [ram_row0_switches - Matrix row 0 debounced switch state]
	bit 0,a			;2fea	cb 47		. G
	call z,sub_316dh	;2fec	cc 6d 31	. m 1
	ld a,(0c0dbh)		;2fef	3a db c0	: . .  ; [ram_row0_switches - Matrix row 0 debounced switch state]
	bit 1,a			;2ff2	cb 4f		. O
	call z,sub_3175h	;2ff4	cc 75 31	. u 1
	ld a,(0c0dbh)		;2ff7	3a db c0	: . .  ; [ram_row0_switches - Matrix row 0 debounced switch state]
	bit 2,a			;2ffa	cb 57		. W
	call z,sub_317dh	;2ffc	cc 7d 31	. } 1
	ld a,(0c0dbh)		;2fff	3a db c0	: . .  ; [ram_row0_switches - Matrix row 0 debounced switch state]
	bit 3,a			;3002	cb 5f		. _
	call z,sub_3185h	;3004	cc 85 31	. . 1
	ld a,(0c0dbh)		;3007	3a db c0	: . .  ; [ram_row0_switches - Matrix row 0 debounced switch state]
	bit 4,a			;300a	cb 67		. g
	call z,sub_318dh	;300c	cc 8d 31	. . 1
	ld a,(0c0dbh)		;300f	3a db c0	: . .  ; [ram_row0_switches - Matrix row 0 debounced switch state]
	bit 5,a			;3012	cb 6f		. o
	call z,sub_3195h	;3014	cc 95 31	. . 1
	ld a,(0c0dbh)		;3017	3a db c0	: . .  ; [ram_row0_switches - Matrix row 0 debounced switch state]
	bit 6,a			;301a	cb 77		. w
	call z,sub_319dh	;301c	cc 9d 31	. . 1
	ld a,(0c0dbh)		;301f	3a db c0	: . .  ; [ram_row0_switches - Matrix row 0 debounced switch state]
	bit 7,a			;3022	cb 7f		. .
	jp z,l31a5h		;3024	ca a5 31	. . 1
	ret			;3027	c9		.
sub_3028h:
	ld a,(0c0dch)		;3028	3a dc c0	: . .  ; [ram_row1_switches - Matrix row 1 debounced switch state]
	bit 0,a			;302b	cb 47		. G
	call z,sub_31adh	;302d	cc ad 31	. . 1
	ld a,(0c0dch)		;3030	3a dc c0	: . .  ; [ram_row1_switches - Matrix row 1 debounced switch state]
	bit 1,a			;3033	cb 4f		. O
	call z,sub_31b5h	;3035	cc b5 31	. . 1
	ld a,(0c0dch)		;3038	3a dc c0	: . .  ; [ram_row1_switches - Matrix row 1 debounced switch state]
	bit 2,a			;303b	cb 57		. W
	call z,sub_31bdh	;303d	cc bd 31	. . 1
l3040h:
	ld a,(0c0dch)		;3040	3a dc c0	: . .  ; [ram_row1_switches - Matrix row 1 debounced switch state]
	bit 3,a			;3043	cb 5f		. _
	call z,sub_31c5h	;3045	cc c5 31	. . 1
	ld a,(0c0dch)		;3048	3a dc c0	: . .  ; [ram_row1_switches - Matrix row 1 debounced switch state]
	bit 4,a			;304b	cb 67		. g
	call z,sub_31cdh	;304d	cc cd 31	. . 1
	ld a,(0c0dch)		;3050	3a dc c0	: . .  ; [ram_row1_switches - Matrix row 1 debounced switch state]
	bit 5,a			;3053	cb 6f		. o
	call z,sub_31d5h	;3055	cc d5 31	. . 1
	ld a,(0c0dch)		;3058	3a dc c0	: . .  ; [ram_row1_switches - Matrix row 1 debounced switch state]
	bit 6,a			;305b	cb 77		. w
	call z,sub_31ddh	;305d	cc dd 31	. . 1
	ld a,(0c0dch)		;3060	3a dc c0	: . .  ; [ram_row1_switches - Matrix row 1 debounced switch state]
	bit 7,a			;3063	cb 7f		. .
	jp z,l31e5h		;3065	ca e5 31	. . 1
	ret			;3068	c9		.
sub_3069h:
	ld a,(0c0ddh)		;3069	3a dd c0	: . .  ; [ram_row2_switches - Matrix row 2 debounced switch state]
	bit 0,a			;306c	cb 47		. G
	call z,sub_31edh	;306e	cc ed 31	. . 1
	ld a,(0c0ddh)		;3071	3a dd c0	: . .  ; [ram_row2_switches - Matrix row 2 debounced switch state]
	bit 1,a			;3074	cb 4f		. O
	call z,sub_31f5h	;3076	cc f5 31	. . 1
	ld a,(0c0ddh)		;3079	3a dd c0	: . .  ; [ram_row2_switches - Matrix row 2 debounced switch state]
	bit 2,a			;307c	cb 57		. W
	call z,sub_31fdh	;307e	cc fd 31	. . 1
	ld a,(0c0ddh)		;3081	3a dd c0	: . .  ; [ram_row2_switches - Matrix row 2 debounced switch state]
	bit 3,a			;3084	cb 5f		. _
	call z,sub_3205h	;3086	cc 05 32	. . 2
	ld a,(0c0ddh)		;3089	3a dd c0	: . .  ; [ram_row2_switches - Matrix row 2 debounced switch state]
	bit 4,a			;308c	cb 67		. g
	call z,sub_320dh	;308e	cc 0d 32	. . 2
	ld a,(0c0ddh)		;3091	3a dd c0	: . .  ; [ram_row2_switches - Matrix row 2 debounced switch state]
	bit 5,a			;3094	cb 6f		. o
	call z,sub_3215h	;3096	cc 15 32	. . 2
	ld a,(0c0ddh)		;3099	3a dd c0	: . .  ; [ram_row2_switches - Matrix row 2 debounced switch state]
	bit 6,a			;309c	cb 77		. w
	call z,sub_321dh	;309e	cc 1d 32	. . 2
	ld a,(0c0ddh)		;30a1	3a dd c0	: . .  ; [ram_row2_switches - Matrix row 2 debounced switch state]
	bit 7,a			;30a4	cb 7f		. .
	jp z,l3225h		;30a6	ca 25 32	. % 2
	ret			;30a9	c9		.
sub_30aah:
	ld a,(0c0deh)		;30aa	3a de c0	: . .  ; [ram_row3_switches - Matrix row 3 debounced switch state]
	bit 0,a			;30ad	cb 47		. G
	call z,sub_322dh	;30af	cc 2d 32	. - 2
	ld a,(0c0deh)		;30b2	3a de c0	: . .  ; [ram_row3_switches - Matrix row 3 debounced switch state]
	bit 1,a			;30b5	cb 4f		. O
	call z,sub_3235h	;30b7	cc 35 32	. 5 2
	ld a,(0c0deh)		;30ba	3a de c0	: . .  ; [ram_row3_switches - Matrix row 3 debounced switch state]
	bit 2,a			;30bd	cb 57		. W
	call z,sub_323dh	;30bf	cc 3d 32	. = 2
	ld a,(0c0deh)		;30c2	3a de c0	: . .  ; [ram_row3_switches - Matrix row 3 debounced switch state]
	bit 3,a			;30c5	cb 5f		. _
	call z,sub_3245h	;30c7	cc 45 32	. E 2
	ld a,(0c0deh)		;30ca	3a de c0	: . .  ; [ram_row3_switches - Matrix row 3 debounced switch state]
	bit 4,a			;30cd	cb 67		. g
	call z,sub_324dh	;30cf	cc 4d 32	. M 2
	ld a,(0c0deh)		;30d2	3a de c0	: . .  ; [ram_row3_switches - Matrix row 3 debounced switch state]
	bit 5,a			;30d5	cb 6f		. o
	call z,sub_3255h	;30d7	cc 55 32	. U 2
	ld a,(0c0deh)		;30da	3a de c0	: . .  ; [ram_row3_switches - Matrix row 3 debounced switch state]
	bit 6,a			;30dd	cb 77		. w
	call z,sub_325dh	;30df	cc 5d 32	. ] 2
	ld a,(0c0deh)		;30e2	3a de c0	: . .  ; [ram_row3_switches - Matrix row 3 debounced switch state]
	bit 7,a			;30e5	cb 7f		. .
	jp z,l3265h		;30e7	ca 65 32	. e 2
	ret			;30ea	c9		.
sub_30ebh:
	ld a,(0c0dfh)		;30eb	3a df c0	: . .  ; [ram_row4_switches - Matrix row 4 debounced switch state]
	bit 0,a			;30ee	cb 47		. G
	call z,sub_326dh	;30f0	cc 6d 32	. m 2
	ld a,(0c0dfh)		;30f3	3a df c0	: . .  ; [ram_row4_switches - Matrix row 4 debounced switch state]
	bit 1,a			;30f6	cb 4f		. O
	call z,sub_3275h	;30f8	cc 75 32	. u 2
	ld a,(0c0dfh)		;30fb	3a df c0	: . .  ; [ram_row4_switches - Matrix row 4 debounced switch state]
	bit 2,a			;30fe	cb 57		. W
	call z,sub_327dh	;3100	cc 7d 32	. } 2
	ld a,(0c0dfh)		;3103	3a df c0	: . .  ; [ram_row4_switches - Matrix row 4 debounced switch state]
	bit 3,a			;3106	cb 5f		. _
	call z,sub_3285h	;3108	cc 85 32	. . 2
	ld a,(0c0dfh)		;310b	3a df c0	: . .  ; [ram_row4_switches - Matrix row 4 debounced switch state]
	bit 4,a			;310e	cb 67		. g
	call z,sub_328dh	;3110	cc 8d 32	. . 2
	ld a,(0c0dfh)		;3113	3a df c0	: . .  ; [ram_row4_switches - Matrix row 4 debounced switch state]
	bit 5,a			;3116	cb 6f		. o
	call z,sub_3295h	;3118	cc 95 32	. . 2
	ld a,(0c0dfh)		;311b	3a df c0	: . .  ; [ram_row4_switches - Matrix row 4 debounced switch state]
	bit 6,a			;311e	cb 77		. w
	call z,sub_329dh	;3120	cc 9d 32	. . 2
	ld a,(0c0dfh)		;3123	3a df c0	: . .  ; [ram_row4_switches - Matrix row 4 debounced switch state]
	bit 7,a			;3126	cb 7f		. .
	jp z,l32a5h		;3128	ca a5 32	. . 2
	ret			;312b	c9		.
sub_312ch:
	ld a,(0c0e0h)		;312c	3a e0 c0	: . .  ; [ram_row5_switches - Matrix row 5 debounced switch state]
	bit 0,a			;312f	cb 47		. G
	call z,sub_32adh	;3131	cc ad 32	. . 2
	ld a,(0c0e0h)		;3134	3a e0 c0	: . .  ; [ram_row5_switches - Matrix row 5 debounced switch state]
	bit 1,a			;3137	cb 4f		. O
	call z,sub_32b5h	;3139	cc b5 32	. . 2
	ld a,(0c0e0h)		;313c	3a e0 c0	: . .  ; [ram_row5_switches - Matrix row 5 debounced switch state]
	bit 2,a			;313f	cb 57		. W
	call z,sub_32bdh	;3141	cc bd 32	. . 2
	ld a,(0c0e0h)		;3144	3a e0 c0	: . .  ; [ram_row5_switches - Matrix row 5 debounced switch state]
	bit 3,a			;3147	cb 5f		. _
	call z,sub_32c5h	;3149	cc c5 32	. . 2
	ld a,(0c0e0h)		;314c	3a e0 c0	: . .  ; [ram_row5_switches - Matrix row 5 debounced switch state]
	bit 4,a			;314f	cb 67		. g
	call z,sub_32cdh	;3151	cc cd 32	. . 2
	ld a,(0c0e0h)		;3154	3a e0 c0	: . .  ; [ram_row5_switches - Matrix row 5 debounced switch state]
	bit 5,a			;3157	cb 6f		. o
	call z,sub_32d5h	;3159	cc d5 32	. . 2
	ld a,(0c0e0h)		;315c	3a e0 c0	: . .  ; [ram_row5_switches - Matrix row 5 debounced switch state]
	bit 6,a			;315f	cb 77		. w
	call z,sub_32ddh	;3161	cc dd 32	. . 2
	ld a,(0c0e0h)		;3164	3a e0 c0	: . .  ; [ram_row5_switches - Matrix row 5 debounced switch state]
	bit 7,a			;3167	cb 7f		. .
	jp z,l32e5h		;3169	ca e5 32	. . 2
	ret			;316c	c9		.
sub_316dh:
	ld a,00ah		;316d	3e 0a		> .
	ld (0c0fch),a		;316f	32 fc c0	2 . .  ; [ram_switch_mailbox - *** MAILBOX BYTE *** Switch code → 80188 (86 refs!)]
	jp l161eh		;3172	c3 1e 16	. . .
sub_3175h:
	ld a,00bh		;3175	3e 0b		> .
	ld (0c0fch),a		;3177	32 fc c0	2 . .  ; [ram_switch_mailbox - *** MAILBOX BYTE *** Switch code → 80188 (86 refs!)]
	jp l164ah		;317a	c3 4a 16	. J .
sub_317dh:
	ld a,00ch		;317d	3e 0c		> .
	ld (0c0fch),a		;317f	32 fc c0	2 . .  ; [ram_switch_mailbox - *** MAILBOX BYTE *** Switch code → 80188 (86 refs!)]
	jp l165ah		;3182	c3 5a 16	. Z .
sub_3185h:
	ld a,00dh		;3185	3e 0d		> .
	ld (0c0fch),a		;3187	32 fc c0	2 . .  ; [ram_switch_mailbox - *** MAILBOX BYTE *** Switch code → 80188 (86 refs!)]
	jp l166ah		;318a	c3 6a 16	. j .
sub_318dh:
	ld a,00eh		;318d	3e 0e		> .
	ld (0c0fch),a		;318f	32 fc c0	2 . .  ; [ram_switch_mailbox - *** MAILBOX BYTE *** Switch code → 80188 (86 refs!)]
	jp l13a5h		;3192	c3 a5 13	. . .
sub_3195h:
	ld a,00fh		;3195	3e 0f		> .
	ld (0c0fch),a		;3197	32 fc c0	2 . .  ; [ram_switch_mailbox - *** MAILBOX BYTE *** Switch code → 80188 (86 refs!)]
	jp l1398h		;319a	c3 98 13	. . .
sub_319dh:
	ld a,010h		;319d	3e 10		> .
	ld (0c0fch),a		;319f	32 fc c0	2 . .  ; [ram_switch_mailbox - *** MAILBOX BYTE *** Switch code → 80188 (86 refs!)]
	jp l15f7h		;31a2	c3 f7 15	. . .
l31a5h:
	ld a,011h		;31a5	3e 11		> .
	ld (0c0fch),a		;31a7	32 fc c0	2 . .  ; [ram_switch_mailbox - *** MAILBOX BYTE *** Switch code → 80188 (86 refs!)]
	jp l1604h		;31aa	c3 04 16	. . .
sub_31adh:
	ld a,012h		;31ad	3e 12		> .
	ld (0c0fch),a		;31af	32 fc c0	2 . .  ; [ram_switch_mailbox - *** MAILBOX BYTE *** Switch code → 80188 (86 refs!)]
	jp l13f6h		;31b2	c3 f6 13	. . .
sub_31b5h:
	ld a,013h		;31b5	3e 13		> .
	ld (0c0fch),a		;31b7	32 fc c0	2 . .  ; [ram_switch_mailbox - *** MAILBOX BYTE *** Switch code → 80188 (86 refs!)]
	jp handler_ball_launch		;31ba	c3 48 13	. H .  ; → handler_ball_launch
sub_31bdh:
	ld a,014h		;31bd	3e 14		> .
	ld (0c0fch),a		;31bf	32 fc c0	2 . .  ; [ram_switch_mailbox - *** MAILBOX BYTE *** Switch code → 80188 (86 refs!)]
	jp l1611h		;31c2	c3 11 16	. . .
sub_31c5h:
	ld a,015h		;31c5	3e 15		> .
	ld (0c0fch),a		;31c7	32 fc c0	2 . .  ; [ram_switch_mailbox - *** MAILBOX BYTE *** Switch code → 80188 (86 refs!)]
	jp l15e7h		;31ca	c3 e7 15	. . .
sub_31cdh:
	ld a,016h		;31cd	3e 16		> .
	ld (0c0fch),a		;31cf	32 fc c0	2 . .  ; [ram_switch_mailbox - *** MAILBOX BYTE *** Switch code → 80188 (86 refs!)]
	jp l15d7h		;31d2	c3 d7 15	. . .
sub_31d5h:
	ld a,017h		;31d5	3e 17		> .
	ld (0c0fch),a		;31d7	32 fc c0	2 . .  ; [ram_switch_mailbox - *** MAILBOX BYTE *** Switch code → 80188 (86 refs!)]
	jp l138bh		;31da	c3 8b 13	. . .
sub_31ddh:
	ld a,018h		;31dd	3e 18		> .
	ld (0c0fch),a		;31df	32 fc c0	2 . .  ; [ram_switch_mailbox - *** MAILBOX BYTE *** Switch code → 80188 (86 refs!)]
	jp l137eh		;31e2	c3 7e 13	. ~ .
l31e5h:
	ld a,019h		;31e5	3e 19		> .
	ld (0c0fch),a		;31e7	32 fc c0	2 . .  ; [ram_switch_mailbox - *** MAILBOX BYTE *** Switch code → 80188 (86 refs!)]
	jp l1371h		;31ea	c3 71 13	. q .
sub_31edh:
	ld a,01ah		;31ed	3e 1a		> .
	ld (0c0fch),a		;31ef	32 fc c0	2 . .  ; [ram_switch_mailbox - *** MAILBOX BYTE *** Switch code → 80188 (86 refs!)]
	jp l13b2h		;31f2	c3 b2 13	. . .
sub_31f5h:
	ld a,01bh		;31f5	3e 1b		> .
	ld (0c0fch),a		;31f7	32 fc c0	2 . .  ; [ram_switch_mailbox - *** MAILBOX BYTE *** Switch code → 80188 (86 refs!)]
	jp l144dh		;31fa	c3 4d 14	. M .
sub_31fdh:
	ld a,01ch		;31fd	3e 1c		> .
	ld (0c0fch),a		;31ff	32 fc c0	2 . .  ; [ram_switch_mailbox - *** MAILBOX BYTE *** Switch code → 80188 (86 refs!)]
	jp l145ah		;3202	c3 5a 14	. Z .
sub_3205h:
	ld a,01dh		;3205	3e 1d		> .
	ld (0c0fch),a		;3207	32 fc c0	2 . .  ; [ram_switch_mailbox - *** MAILBOX BYTE *** Switch code → 80188 (86 refs!)]
	jp l1467h		;320a	c3 67 14	. g .
sub_320dh:
	ld a,01eh		;320d	3e 1e		> .
	ld (0c0fch),a		;320f	32 fc c0	2 . .  ; [ram_switch_mailbox - *** MAILBOX BYTE *** Switch code → 80188 (86 refs!)]
	jp l1474h		;3212	c3 74 14	. t .
sub_3215h:
	ld a,01fh		;3215	3e 1f		> .
	ld (0c0fch),a		;3217	32 fc c0	2 . .  ; [ram_switch_mailbox - *** MAILBOX BYTE *** Switch code → 80188 (86 refs!)]
	jp l1481h		;321a	c3 81 14	. . .
sub_321dh:
	ld a,020h		;321d	3e 20		>  
	ld (0c0fch),a		;321f	32 fc c0	2 . .  ; [ram_switch_mailbox - *** MAILBOX BYTE *** Switch code → 80188 (86 refs!)]
	jp l1440h		;3222	c3 40 14	. @ .
l3225h:
	ld a,021h		;3225	3e 21		> !
	ld (0c0fch),a		;3227	32 fc c0	2 . .  ; [ram_switch_mailbox - *** MAILBOX BYTE *** Switch code → 80188 (86 refs!)]
	jp l15cch		;322a	c3 cc 15	. . .
sub_322dh:
	ld a,022h		;322d	3e 22		> "
	ld (0c0fch),a		;322f	32 fc c0	2 . .  ; [ram_switch_mailbox - *** MAILBOX BYTE *** Switch code → 80188 (86 refs!)]
	jp l15b9h		;3232	c3 b9 15	. . .
sub_3235h:
	ld a,023h		;3235	3e 23		> #
	ld (0c0fch),a		;3237	32 fc c0	2 . .  ; [ram_switch_mailbox - *** MAILBOX BYTE *** Switch code → 80188 (86 refs!)]
	jp l1505h		;323a	c3 05 15	. . .
sub_323dh:
	ld a,024h		;323d	3e 24		> $
	ld (0c0fch),a		;323f	32 fc c0	2 . .  ; [ram_switch_mailbox - *** MAILBOX BYTE *** Switch code → 80188 (86 refs!)]
	jp l148eh		;3242	c3 8e 14	. . .
sub_3245h:
	ld a,025h		;3245	3e 25		> %
	ld (0c0fch),a		;3247	32 fc c0	2 . .  ; [ram_switch_mailbox - *** MAILBOX BYTE *** Switch code → 80188 (86 refs!)]
	jp l154dh		;324a	c3 4d 15	. M .
sub_324dh:
	ld a,026h		;324d	3e 26		> &
	ld (0c0fch),a		;324f	32 fc c0	2 . .  ; [ram_switch_mailbox - *** MAILBOX BYTE *** Switch code → 80188 (86 refs!)]
	jp l1529h		;3252	c3 29 15	. ) .
sub_3255h:
	ld a,027h		;3255	3e 27		> '
	ld (0c0fch),a		;3257	32 fc c0	2 . .  ; [ram_switch_mailbox - *** MAILBOX BYTE *** Switch code → 80188 (86 refs!)]
	jp l1595h		;325a	c3 95 15	. . .
sub_325dh:
	ld a,028h		;325d	3e 28		> (
	ld (0c0fch),a		;325f	32 fc c0	2 . .  ; [ram_switch_mailbox - *** MAILBOX BYTE *** Switch code → 80188 (86 refs!)]
	jp l1571h		;3262	c3 71 15	. q .
l3265h:
	ld a,029h		;3265	3e 29		> )
	ld (0c0fch),a		;3267	32 fc c0	2 . .  ; [ram_switch_mailbox - *** MAILBOX BYTE *** Switch code → 80188 (86 refs!)]
	jp l14a8h		;326a	c3 a8 14	. . .
sub_326dh:
	ld a,02ah		;326d	3e 2a		> *
	ld (0c0fch),a		;326f	32 fc c0	2 . .  ; [ram_switch_mailbox - *** MAILBOX BYTE *** Switch code → 80188 (86 refs!)]
	jp l16c5h		;3272	c3 c5 16	. . .
sub_3275h:
	ld a,02bh		;3275	3e 2b		> +
	ld (0c0fch),a		;3277	32 fc c0	2 . .  ; [ram_switch_mailbox - *** MAILBOX BYTE *** Switch code → 80188 (86 refs!)]
	jp l16b5h		;327a	c3 b5 16	. . .
sub_327dh:
	ld a,02ch		;327d	3e 2c		> ,
	ld (0c0fch),a		;327f	32 fc c0	2 . .  ; [ram_switch_mailbox - *** MAILBOX BYTE *** Switch code → 80188 (86 refs!)]
	jp l169eh		;3282	c3 9e 16	. . .
sub_3285h:
	ld a,02dh		;3285	3e 2d		> -
	ld (0c0fch),a		;3287	32 fc c0	2 . .  ; [ram_switch_mailbox - *** MAILBOX BYTE *** Switch code → 80188 (86 refs!)]
	jp l14e1h		;328a	c3 e1 14	. . .
sub_328dh:
	ld a,02eh		;328d	3e 2e		> .
	ld (0c0fch),a		;328f	32 fc c0	2 . .  ; [ram_switch_mailbox - *** MAILBOX BYTE *** Switch code → 80188 (86 refs!)]
	jp l149bh		;3292	c3 9b 14	. . .
sub_3295h:
	ld a,02fh		;3295	3e 2f		> /
	ld (0c0fch),a		;3297	32 fc c0	2 . .  ; [ram_switch_mailbox - *** MAILBOX BYTE *** Switch code → 80188 (86 refs!)]
	jp l13e6h		;329a	c3 e6 13	. . .
sub_329dh:
	ld a,030h		;329d	3e 30		> 0
	ld (0c0fch),a		;329f	32 fc c0	2 . .  ; [ram_switch_mailbox - *** MAILBOX BYTE *** Switch code → 80188 (86 refs!)]
	jp l14b5h		;32a2	c3 b5 14	. . .
l32a5h:
	ld a,031h		;32a5	3e 31		> 1
	ld (0c0fch),a		;32a7	32 fc c0	2 . .  ; [ram_switch_mailbox - *** MAILBOX BYTE *** Switch code → 80188 (86 refs!)]
	jp l1677h		;32aa	c3 77 16	. w .
sub_32adh:
	ld a,034h		;32ad	3e 34		> 4
	ld (0c0fch),a		;32af	32 fc c0	2 . .  ; [ram_switch_mailbox - *** MAILBOX BYTE *** Switch code → 80188 (86 refs!)]
	jp l14eeh		;32b2	c3 ee 14	. . .
sub_32b5h:
	ld a,035h		;32b5	3e 35		> 5
	ld (0c0fch),a		;32b7	32 fc c0	2 . .  ; [ram_switch_mailbox - *** MAILBOX BYTE *** Switch code → 80188 (86 refs!)]
	jp l13d9h		;32ba	c3 d9 13	. . .
sub_32bdh:
	ld a,036h		;32bd	3e 36		> 6
	ld (0c0fch),a		;32bf	32 fc c0	2 . .  ; [ram_switch_mailbox - *** MAILBOX BYTE *** Switch code → 80188 (86 refs!)]
	jp l13cch		;32c2	c3 cc 13	. . .
sub_32c5h:
	ld a,037h		;32c5	3e 37		> 7
	ld (0c0fch),a		;32c7	32 fc c0	2 . .  ; [ram_switch_mailbox - *** MAILBOX BYTE *** Switch code → 80188 (86 refs!)]
	jp l13bfh		;32ca	c3 bf 13	. . .
sub_32cdh:
	ld a,038h		;32cd	3e 38		> 8
	ld (0c0fch),a		;32cf	32 fc c0	2 . .  ; [ram_switch_mailbox - *** MAILBOX BYTE *** Switch code → 80188 (86 refs!)]
	jp handler_ball_launch		;32d2	c3 48 13	. H .  ; → handler_ball_launch
sub_32d5h:
	ld a,039h		;32d5	3e 39		> 9
	ld (0c0fch),a		;32d7	32 fc c0	2 . .  ; [ram_switch_mailbox - *** MAILBOX BYTE *** Switch code → 80188 (86 refs!)]
	jp handler_ball_launch		;32da	c3 48 13	. H .  ; → handler_ball_launch
sub_32ddh:
	ld a,03ah		;32dd	3e 3a		> :
	ld (0c0fch),a		;32df	32 fc c0	2 . .  ; [ram_switch_mailbox - *** MAILBOX BYTE *** Switch code → 80188 (86 refs!)]
	jp handler_ball_launch		;32e2	c3 48 13	. H .  ; → handler_ball_launch
l32e5h:
	ld a,03bh		;32e5	3e 3b		> ;
	ld (0c0fch),a		;32e7	32 fc c0	2 . .  ; [ram_switch_mailbox - *** MAILBOX BYTE *** Switch code → 80188 (86 refs!)]
	jp handler_ball_launch		;32ea	c3 48 13	. H .  ; → handler_ball_launch
lamp_strobe_cycle:
	ld hl,scan_begin_cycle		;32ed	21 73 2e	! s .
	ld (0c0e5h),hl		;32f0	22 e5 c0	" . .  ; [ram_scan_state_lo - Scan state machine pointer low byte]
	in a,(002h)		;32f3	db 02		. .  ; << PORT_MATRIX_COL - Switch matrix column data (8 bits, active-low)
	ld (0c0dbh),a		;32f5	32 db c0	2 . .  ; [ram_row0_switches - Matrix row 0 debounced switch state]
	ret			;32f8	c9		.
sub_32f9h:
	ld hl,scan_begin_cycle		;32f9	21 73 2e	! s .
	ld (0c0e5h),hl		;32fc	22 e5 c0	" . .  ; [ram_scan_state_lo - Scan state machine pointer low byte]
	in a,(002h)		;32ff	db 02		. .  ; << PORT_MATRIX_COL - Switch matrix column data (8 bits, active-low)
	ld (0c0dch),a		;3301	32 dc c0	2 . .  ; [ram_row1_switches - Matrix row 1 debounced switch state]
	ret			;3304	c9		.
	ld hl,scan_begin_cycle		;3305	21 73 2e	! s .
	ld (0c0e5h),hl		;3308	22 e5 c0	" . .  ; [ram_scan_state_lo - Scan state machine pointer low byte]
	in a,(002h)		;330b	db 02		. .  ; << PORT_MATRIX_COL - Switch matrix column data (8 bits, active-low)
	ld (0c0ddh),a		;330d	32 dd c0	2 . .  ; [ram_row2_switches - Matrix row 2 debounced switch state]
	ret			;3310	c9		.
sub_3311h:
	ld hl,scan_begin_cycle		;3311	21 73 2e	! s .
	ld (0c0e5h),hl		;3314	22 e5 c0	" . .  ; [ram_scan_state_lo - Scan state machine pointer low byte]
	in a,(002h)		;3317	db 02		. .  ; << PORT_MATRIX_COL - Switch matrix column data (8 bits, active-low)
	ld (0c0deh),a		;3319	32 de c0	2 . .  ; [ram_row3_switches - Matrix row 3 debounced switch state]
	ret			;331c	c9		.
lamp_effect_update:
	ld hl,scan_begin_cycle		;331d	21 73 2e	! s .
	ld (0c0e5h),hl		;3320	22 e5 c0	" . .  ; [ram_scan_state_lo - Scan state machine pointer low byte]
	in a,(002h)		;3323	db 02		. .  ; << PORT_MATRIX_COL - Switch matrix column data (8 bits, active-low)
	ld (0c0dfh),a		;3325	32 df c0	2 . .  ; [ram_row4_switches - Matrix row 4 debounced switch state]
	ret			;3328	c9		.
	ld hl,l2ec3h		;3329	21 c3 2e	! . .
	ld (0c0e5h),hl		;332c	22 e5 c0	" . .  ; [ram_scan_state_lo - Scan state machine pointer low byte]
	in a,(002h)		;332f	db 02		. .  ; << PORT_MATRIX_COL - Switch matrix column data (8 bits, active-low)
	ld (0c0e0h),a		;3331	32 e0 c0	2 . .  ; [ram_row5_switches - Matrix row 5 debounced switch state]
	ret			;3334	c9		.
sub_3335h:

; ─────────────────────────────────────────────────────────────────────────────
; lamp_scan_one_col (0x3335)
; Lamp scan: process one column per call
; ─────────────────────────────────────────────────────────────────────────────
lamp_scan_one_col:
	ld a,(0c0fah)		;3335	3a fa c0	: . .  ; [ram_current_lamp_col - Current lamp column index being refreshed]
	and a			;3338	a7		.
	jp z,l3341h		;3339	ca 41 33	. A 3
	dec a			;333c	3d		=
	ld (0c0fah),a		;333d	32 fa c0	2 . .  ; [ram_current_lamp_col - Current lamp column index being refreshed]
	ret			;3340	c9		.
l3341h:
	ld a,(0c0e7h)		;3341	3a e7 c0	: . .  ; [ram_matrix_raw_0 - Raw matrix data row 0 (current read)]
	ld hl,0c0e8h		;3344	21 e8 c0	! . .
	and (hl)		;3347	a6		.
	ld (hl),a		;3348	77		w
	ld a,(0c0e9h)		;3349	3a e9 c0	: . .
	ld hl,0c0eah		;334c	21 ea c0	! . .
	and (hl)		;334f	a6		.
	ld (hl),a		;3350	77		w
	ld a,(0c0ebh)		;3351	3a eb c0	: . .
	ld hl,0c0ech		;3354	21 ec c0	! . .
	and (hl)		;3357	a6		.
	ld (hl),a		;3358	77		w
	ld a,(0c0edh)		;3359	3a ed c0	: . .
	ld hl,0c0eeh		;335c	21 ee c0	! . .
	and (hl)		;335f	a6		.
	ld (hl),a		;3360	77		w
	ld a,(0c0efh)		;3361	3a ef c0	: . .
	ld hl,0c0f0h		;3364	21 f0 c0	! . .
	and (hl)		;3367	a6		.
	ld (hl),a		;3368	77		w
	ld a,(0c0f1h)		;3369	3a f1 c0	: . .
	ld hl,0c0f2h		;336c	21 f2 c0	! . .
	and (hl)		;336f	a6		.
	ld (hl),a		;3370	77		w
	ld a,(0c0f7h)		;3371	3a f7 c0	: . .  ; [ram_direct_raw - Port 0x03 raw value]
	ld hl,0c0f8h		;3374	21 f8 c0	! . .
	and (hl)		;3377	a6		.
	ld (hl),a		;3378	77		w
	ret			;3379	c9		.
l337ah:
	rst 38h			;337a	ff		.
l337bh:
	inc d			;337b	14		.
l337ch:
	inc d			;337c	14		.
l337dh:
	inc d			;337d	14		.
l337eh:
	inc d			;337e	14		.
l337fh:
	inc d			;337f	14		.
l3380h:
	inc d			;3380	14		.
l3381h:
	ld e,014h		;3381	1e 14		. .
	ld hl,0c0e8h		;3383	21 e8 c0	! . .
	or (hl)			;3386	b6		.
	ld (hl),a		;3387	77		w
	ld hl,0c0dbh		;3388	21 db c0	! . .
	or (hl)			;338b	b6		.
	ld (hl),a		;338c	77		w
	ld a,(l337ah)		;338d	3a 7a 33	: z 3
	ld (0c0fah),a		;3390	32 fa c0	2 . .  ; [ram_current_lamp_col - Current lamp column index being refreshed]
	ret			;3393	c9		.
sub_3394h:

; ─────────────────────────────────────────────────────────────────────────────
; lamp_set_col_A (0x3394)
; Update lamp column A
; ─────────────────────────────────────────────────────────────────────────────
lamp_set_col_A:
	ld hl,0c0e8h		;3394	21 e8 c0	! . .
	or (hl)			;3397	b6		.
	ld (hl),a		;3398	77		w
	ld hl,0c0dbh		;3399	21 db c0	! . .
	or (hl)			;339c	b6		.
	ld (hl),a		;339d	77		w
	ld a,(l337bh)		;339e	3a 7b 33	: { 3
	ld (0c0fah),a		;33a1	32 fa c0	2 . .  ; [ram_current_lamp_col - Current lamp column index being refreshed]
	ret			;33a4	c9		.
sub_33a5h:

; ─────────────────────────────────────────────────────────────────────────────
; lamp_set_col_B (0x33A5)
; Update lamp column B
; ─────────────────────────────────────────────────────────────────────────────
lamp_set_col_B:
	ld hl,0c0eah		;33a5	21 ea c0	! . .
	or (hl)			;33a8	b6		.
	ld (hl),a		;33a9	77		w
	ld hl,0c0dch		;33aa	21 dc c0	! . .
	or (hl)			;33ad	b6		.
	ld (hl),a		;33ae	77		w
	ld a,(l337ch)		;33af	3a 7c 33	: | 3
	ld (0c0fah),a		;33b2	32 fa c0	2 . .  ; [ram_current_lamp_col - Current lamp column index being refreshed]
	ret			;33b5	c9		.
sub_33b6h:

; ─────────────────────────────────────────────────────────────────────────────
; lamp_set_col_C (0x33B6)
; Update lamp column C
; ─────────────────────────────────────────────────────────────────────────────
lamp_set_col_C:
	ld hl,0c0ech		;33b6	21 ec c0	! . .
	or (hl)			;33b9	b6		.
	ld (hl),a		;33ba	77		w
	ld hl,0c0ddh		;33bb	21 dd c0	! . .
	or (hl)			;33be	b6		.
	ld (hl),a		;33bf	77		w
	ld a,(l337dh)		;33c0	3a 7d 33	: } 3
	ld (0c0fah),a		;33c3	32 fa c0	2 . .  ; [ram_current_lamp_col - Current lamp column index being refreshed]
	ret			;33c6	c9		.
sub_33c7h:

; ─────────────────────────────────────────────────────────────────────────────
; lamp_set_col_D (0x33C7)
; Update lamp column D
; ─────────────────────────────────────────────────────────────────────────────
lamp_set_col_D:
	ld hl,0c0eeh		;33c7	21 ee c0	! . .
	or (hl)			;33ca	b6		.
	ld (hl),a		;33cb	77		w
	ld hl,0c0deh		;33cc	21 de c0	! . .
	or (hl)			;33cf	b6		.
	ld (hl),a		;33d0	77		w
	ld a,(l337eh)		;33d1	3a 7e 33	: ~ 3
	ld (0c0fah),a		;33d4	32 fa c0	2 . .  ; [ram_current_lamp_col - Current lamp column index being refreshed]
	ret			;33d7	c9		.
sub_33d8h:

; ─────────────────────────────────────────────────────────────────────────────
; lamp_set_col_E (0x33D8)
; Update lamp column E
; ─────────────────────────────────────────────────────────────────────────────
lamp_set_col_E:
	ld hl,0c0f0h		;33d8	21 f0 c0	! . .
	or (hl)			;33db	b6		.
	ld (hl),a		;33dc	77		w
	ld hl,0c0dfh		;33dd	21 df c0	! . .
	or (hl)			;33e0	b6		.
	ld (hl),a		;33e1	77		w
	ld a,(l337fh)		;33e2	3a 7f 33	: . 3
	ld (0c0fah),a		;33e5	32 fa c0	2 . .  ; [ram_current_lamp_col - Current lamp column index being refreshed]
	ret			;33e8	c9		.
sub_33e9h:

; ─────────────────────────────────────────────────────────────────────────────
; lamp_set_col_F (0x33E9)
; Update lamp column F
; ─────────────────────────────────────────────────────────────────────────────
lamp_set_col_F:
	ld hl,0c0f2h		;33e9	21 f2 c0	! . .
	or (hl)			;33ec	b6		.
	ld (hl),a		;33ed	77		w
	ld hl,0c0e0h		;33ee	21 e0 c0	! . .
	or (hl)			;33f1	b6		.
	ld (hl),a		;33f2	77		w
	ld a,(l3380h)		;33f3	3a 80 33	: . 3
	ld (0c0fah),a		;33f6	32 fa c0	2 . .  ; [ram_current_lamp_col - Current lamp column index being refreshed]
	ret			;33f9	c9		.
sub_33fah:

; ─────────────────────────────────────────────────────────────────────────────
; lamp_set_col_G (0x33FA)
; Update lamp column G
; ─────────────────────────────────────────────────────────────────────────────
lamp_set_col_G:
	ld hl,0c0f8h		;33fa	21 f8 c0	! . .
	or (hl)			;33fd	b6		.
	ld (hl),a		;33fe	77		w
	ld hl,0c0e3h		;33ff	21 e3 c0	! . .
	or (hl)			;3402	b6		.
	ld (hl),a		;3403	77		w
	ld a,(l3381h)		;3404	3a 81 33	: . 3
	ld (0c0fah),a		;3407	32 fa c0	2 . .  ; [ram_current_lamp_col - Current lamp column index being refreshed]
	ret			;340a	c9		.
	ld hl,0c0f8h		;340b	21 f8 c0	! . .
	or (hl)			;340e	b6		.
	ld (hl),a		;340f	77		w
	ld hl,0c0e3h		;3410	21 e3 c0	! . .
	or (hl)			;3413	b6		.
	ld (hl),a		;3414	77		w
	ld a,(l3381h+1)		;3415	3a 82 33	: . 3
	ld (0c0fah),a		;3418	32 fa c0	2 . .  ; [ram_current_lamp_col - Current lamp column index being refreshed]
	ret			;341b	c9		.
	ld hl,0c0e8h		;341c	21 e8 c0	! . .
	and (hl)		;341f	a6		.
	ld (hl),a		;3420	77		w
	ret			;3421	c9		.
	ld hl,0c0eah		;3422	21 ea c0	! . .
	and (hl)		;3425	a6		.
	ld (hl),a		;3426	77		w
	ret			;3427	c9		.
	ld hl,0c0ech		;3428	21 ec c0	! . .
	and (hl)		;342b	a6		.
	ld (hl),a		;342c	77		w
	ret			;342d	c9		.
	ld hl,0c0eeh		;342e	21 ee c0	! . .
	and (hl)		;3431	a6		.
	ld (hl),a		;3432	77		w
	ret			;3433	c9		.
	ld hl,0c0f0h		;3434	21 f0 c0	! . .
	and (hl)		;3437	a6		.
	ld (hl),a		;3438	77		w
	ret			;3439	c9		.
	ld hl,0c0f2h		;343a	21 f2 c0	! . .
	and (hl)		;343d	a6		.
	ld (hl),a		;343e	77		w
	ret			;343f	c9		.
	ld hl,0c0f8h		;3440	21 f8 c0	! . .
	and (hl)		;3443	a6		.
	ld (hl),a		;3444	77		w
	ret			;3445	c9		.
sub_3446h:

; ─────────────────────────────────────────────────────────────────────────────
; lamp_hw_refresh (0x3446)
; Lamp hardware refresh: write ports 0x82/0x83/0x84
; ─────────────────────────────────────────────────────────────────────────────
lamp_hw_refresh:
	ld a,(0c122h)		;3446	3a 22 c1	: " .
	and a			;3449	a7		.
	call nz,sub_37a9h	;344a	c4 a9 37	. . 7
	call sub_34d7h		;344d	cd d7 34	. . 4
	call sub_353ah		;3450	cd 3a 35	. : 5
	ld hl,(0c117h)		;3453	2a 17 c1	* . .  ; [ram_sol_active_mask - Active solenoid bitmask]
	jp (hl)			;3456	e9		.
l3457h:
	ld hl,l3467h		;3457	21 67 34	! g 4
	ld (0c117h),hl		;345a	22 17 c1	" . .  ; [ram_sol_active_mask - Active solenoid bitmask]
	ld a,(0c10fh)		;345d	3a 0f c1	: . .
	out (084h),a		;3460	d3 84		. .  ; >> PORT_LAMP_ROW2 - Lamp matrix row data byte 2 (8 lamps)
	ld a,001h		;3462	3e 01		> .
	out (083h),a		;3464	d3 83		. .  ; >> PORT_LAMP_ROW1 - Lamp matrix row data byte 1 (8 lamps)
	ret			;3466	c9		.
l3467h:
	ld hl,l3477h		;3467	21 77 34	! w 4
	ld (0c117h),hl		;346a	22 17 c1	" . .  ; [ram_sol_active_mask - Active solenoid bitmask]
	ld a,(0c110h)		;346d	3a 10 c1	: . .
	out (084h),a		;3470	d3 84		. .  ; >> PORT_LAMP_ROW2 - Lamp matrix row data byte 2 (8 lamps)
	ld a,002h		;3472	3e 02		> .
	out (083h),a		;3474	d3 83		. .  ; >> PORT_LAMP_ROW1 - Lamp matrix row data byte 1 (8 lamps)
	ret			;3476	c9		.
l3477h:
	ld hl,l3487h		;3477	21 87 34	! . 4
	ld (0c117h),hl		;347a	22 17 c1	" . .  ; [ram_sol_active_mask - Active solenoid bitmask]
	ld a,(0c111h)		;347d	3a 11 c1	: . .
	out (084h),a		;3480	d3 84		. .  ; >> PORT_LAMP_ROW2 - Lamp matrix row data byte 2 (8 lamps)
	ld a,004h		;3482	3e 04		> .
	out (083h),a		;3484	d3 83		. .  ; >> PORT_LAMP_ROW1 - Lamp matrix row data byte 1 (8 lamps)
	ret			;3486	c9		.
l3487h:
	ld hl,l3497h		;3487	21 97 34	! . 4
	ld (0c117h),hl		;348a	22 17 c1	" . .  ; [ram_sol_active_mask - Active solenoid bitmask]
	ld a,(0c112h)		;348d	3a 12 c1	: . .
	out (084h),a		;3490	d3 84		. .  ; >> PORT_LAMP_ROW2 - Lamp matrix row data byte 2 (8 lamps)
	ld a,008h		;3492	3e 08		> .
	out (083h),a		;3494	d3 83		. .  ; >> PORT_LAMP_ROW1 - Lamp matrix row data byte 1 (8 lamps)
	ret			;3496	c9		.
l3497h:
	ld hl,l34a7h		;3497	21 a7 34	! . 4
	ld (0c117h),hl		;349a	22 17 c1	" . .  ; [ram_sol_active_mask - Active solenoid bitmask]
	ld a,(0c113h)		;349d	3a 13 c1	: . .
	out (084h),a		;34a0	d3 84		. .  ; >> PORT_LAMP_ROW2 - Lamp matrix row data byte 2 (8 lamps)
	ld a,010h		;34a2	3e 10		> .
	out (083h),a		;34a4	d3 83		. .  ; >> PORT_LAMP_ROW1 - Lamp matrix row data byte 1 (8 lamps)
	ret			;34a6	c9		.
l34a7h:
	ld hl,l34b7h		;34a7	21 b7 34	! . 4
	ld (0c117h),hl		;34aa	22 17 c1	" . .  ; [ram_sol_active_mask - Active solenoid bitmask]
	ld a,(0c114h)		;34ad	3a 14 c1	: . .
	out (084h),a		;34b0	d3 84		. .  ; >> PORT_LAMP_ROW2 - Lamp matrix row data byte 2 (8 lamps)
	ld a,020h		;34b2	3e 20		>  
	out (083h),a		;34b4	d3 83		. .  ; >> PORT_LAMP_ROW1 - Lamp matrix row data byte 1 (8 lamps)
	ret			;34b6	c9		.
l34b7h:
	ld hl,l34c7h		;34b7	21 c7 34	! . 4
	ld (0c117h),hl		;34ba	22 17 c1	" . .  ; [ram_sol_active_mask - Active solenoid bitmask]
	ld a,(0c115h)		;34bd	3a 15 c1	: . .
	out (084h),a		;34c0	d3 84		. .  ; >> PORT_LAMP_ROW2 - Lamp matrix row data byte 2 (8 lamps)
	ld a,040h		;34c2	3e 40		> @
	out (083h),a		;34c4	d3 83		. .  ; >> PORT_LAMP_ROW1 - Lamp matrix row data byte 1 (8 lamps)
	ret			;34c6	c9		.
l34c7h:
	ld hl,l3457h		;34c7	21 57 34	! W 4
	ld (0c117h),hl		;34ca	22 17 c1	" . .  ; [ram_sol_active_mask - Active solenoid bitmask]
	ld a,(0c116h)		;34cd	3a 16 c1	: . .
	out (084h),a		;34d0	d3 84		. .  ; >> PORT_LAMP_ROW2 - Lamp matrix row data byte 2 (8 lamps)
	ld a,080h		;34d2	3e 80		> .
	out (083h),a		;34d4	d3 83		. .  ; >> PORT_LAMP_ROW1 - Lamp matrix row data byte 1 (8 lamps)
	ret			;34d6	c9		.
sub_34d7h:
	ld a,(0c119h)		;34d7	3a 19 c1	: . .  ; [ram_lamp_state_flags - Lamp state flags (23 refs)]
	and a			;34da	a7		.
	ret z			;34db	c8		.
	ld a,(0c11dh)		;34dc	3a 1d c1	: . .  ; [ram_lamp_col_C_state - Lamp column C on/off state]
	dec a			;34df	3d		=
	ld (0c11dh),a		;34e0	32 1d c1	2 . .  ; [ram_lamp_col_C_state - Lamp column C on/off state]
	jp nz,l3504h		;34e3	c2 04 35	. . 5
	ld a,(0c11ah)		;34e6	3a 1a c1	: . .  ; [ram_lamp_col_A_state - Lamp column A on/off state]
	ld (0c11dh),a		;34e9	32 1d c1	2 . .  ; [ram_lamp_col_C_state - Lamp column C on/off state]
	ld a,(0c11bh)		;34ec	3a 1b c1	: . .  ; [ram_lamp_col_B_state - Lamp column B on/off state]
	dec a			;34ef	3d		=
	ld (0c11bh),a		;34f0	32 1b c1	2 . .  ; [ram_lamp_col_B_state - Lamp column B on/off state]
	jp z,l3524h		;34f3	ca 24 35	. $ 5
	ld hl,(0c11eh)		;34f6	2a 1e c1	* . .  ; [ram_lamp_col_D_state - Lamp column D on/off state]
	ld de,0c10fh		;34f9	11 0f c1	. . .
	ld bc,00008h		;34fc	01 08 00	. . .
	ldir			;34ff	ed b0		. .
	ld (0c11eh),hl		;3501	22 1e c1	" . .  ; [ram_lamp_col_D_state - Lamp column D on/off state]
l3504h:
	ld a,(0c127h)		;3504	3a 27 c1	: ' .
	and a			;3507	a7		.
	jp nz,l3511h		;3508	c2 11 35	. . 5
	ld hl,0c116h		;350b	21 16 c1	! . .
	res 7,(hl)		;350e	cb be		. .
	ret			;3510	c9		.
l3511h:
	ld a,(0c121h)		;3511	3a 21 c1	: ! .  ; [ram_dip_switches - DIP switch (SW40) cached settings]
	and a			;3514	a7		.
	jp nz,l351eh		;3515	c2 1e 35	. . 5
	ld hl,0c116h		;3518	21 16 c1	! . .
	res 7,(hl)		;351b	cb be		. .
	ret			;351d	c9		.
l351eh:
	ld hl,0c116h		;351e	21 16 c1	! . .
	set 7,(hl)		;3521	cb fe		. .
	ret			;3523	c9		.
;  XREF: 2 refs from 0x34F3, 0x3535
l3524h:
	xor a			;3524	af		.
	ld (0c119h),a		;3525	32 19 c1	2 . .  ; [ram_lamp_state_flags - Lamp state flags (23 refs)]
	ld hl,0c0ffh		;3528	21 ff c0	! . .
	ld de,0c10fh		;352b	11 0f c1	. . .
	ld bc,00008h		;352e	01 08 00	. . .
	ldir			;3531	ed b0		. .
	ret			;3533	c9		.
sub_3534h:
	di			;3534	f3		.
	call l3524h		;3535	cd 24 35	. $ 5
	ei			;3538	fb		.
	ret			;3539	c9		.
sub_353ah:
	ld a,(0c119h)		;353a	3a 19 c1	: . .  ; [ram_lamp_state_flags - Lamp state flags (23 refs)]
	and a			;353d	a7		.
	jp nz,l35ach		;353e	c2 ac 35	. . 5
	ld hl,0c120h		;3541	21 20 c1	!   .
	dec (hl)		;3544	35		5
	ret nz			;3545	c0		.
	ld (hl),04bh		;3546	36 4b		6 K
	ld a,(0c121h)		;3548	3a 21 c1	: ! .  ; [ram_dip_switches - DIP switch (SW40) cached settings]
	and a			;354b	a7		.
	jp z,l3594h		;354c	ca 94 35	. . 5
	xor a			;354f	af		.
	ld (0c121h),a		;3550	32 21 c1	2 ! .  ; [ram_dip_switches - DIP switch (SW40) cached settings]
	ld bc,0c0ffh		;3553	01 ff c0	. . .
	ld hl,0c107h		;3556	21 07 c1	! . .
	ld de,0c10fh		;3559	11 0f c1	. . .
	ld a,(bc)		;355c	0a		.
	and (hl)		;355d	a6		.
	ld (de),a		;355e	12		.
	inc bc			;355f	03		.
	inc hl			;3560	23		#
	inc de			;3561	13		.
	ld a,(bc)		;3562	0a		.
	and (hl)		;3563	a6		.
	ld (de),a		;3564	12		.
	inc bc			;3565	03		.
	inc hl			;3566	23		#
	inc de			;3567	13		.
	ld a,(bc)		;3568	0a		.
	and (hl)		;3569	a6		.
	ld (de),a		;356a	12		.
	inc bc			;356b	03		.
	inc hl			;356c	23		#
	inc de			;356d	13		.
	ld a,(bc)		;356e	0a		.
	and (hl)		;356f	a6		.
	ld (de),a		;3570	12		.
	inc bc			;3571	03		.
	inc hl			;3572	23		#
	inc de			;3573	13		.
	ld a,(bc)		;3574	0a		.
	and (hl)		;3575	a6		.
	ld (de),a		;3576	12		.
	inc bc			;3577	03		.
	inc hl			;3578	23		#
	inc de			;3579	13		.
	ld a,(bc)		;357a	0a		.
	and (hl)		;357b	a6		.
	ld (de),a		;357c	12		.
	inc bc			;357d	03		.
	inc hl			;357e	23		#
	inc de			;357f	13		.
	ld a,(bc)		;3580	0a		.
	and (hl)		;3581	a6		.
	ld (de),a		;3582	12		.
	inc bc			;3583	03		.
	inc hl			;3584	23		#
	inc de			;3585	13		.
	ld a,(bc)		;3586	0a		.
	and (hl)		;3587	a6		.
	ld (de),a		;3588	12		.
	inc bc			;3589	03		.
	inc hl			;358a	23		#
	inc de			;358b	13		.
	ld a,(0c022h)		;358c	3a 22 c0	: " .  ; [ram_sol_timer_bank - Solenoid timer bank (multiple timers)]
	and a			;358f	a7		.
	call nz,sub_27c0h	;3590	c4 c0 27	. . '
	ret			;3593	c9		.
l3594h:
	ld a,0ffh		;3594	3e ff		> .
	ld (0c121h),a		;3596	32 21 c1	2 ! .  ; [ram_dip_switches - DIP switch (SW40) cached settings]
	ld hl,0c0ffh		;3599	21 ff c0	! . .
	ld de,0c10fh		;359c	11 0f c1	. . .
	ld bc,00008h		;359f	01 08 00	. . .
	ldir			;35a2	ed b0		. .
	ld a,(0c022h)		;35a4	3a 22 c0	: " .  ; [ram_sol_timer_bank - Solenoid timer bank (multiple timers)]
	and a			;35a7	a7		.
	call nz,l27b3h		;35a8	c4 b3 27	. . '
	ret			;35ab	c9		.
l35ach:
	ld hl,0c120h		;35ac	21 20 c1	!   .
	dec (hl)		;35af	35		5
	ret nz			;35b0	c0		.
	ld (hl),04bh		;35b1	36 4b		6 K
	ld a,(0c121h)		;35b3	3a 21 c1	: ! .  ; [ram_dip_switches - DIP switch (SW40) cached settings]
	and a			;35b6	a7		.
	jp z,l35cbh		;35b7	ca cb 35	. . 5
	xor a			;35ba	af		.
	ld (0c121h),a		;35bb	32 21 c1	2 ! .  ; [ram_dip_switches - DIP switch (SW40) cached settings]
	ld hl,0c116h		;35be	21 16 c1	! . .
	res 7,(hl)		;35c1	cb be		. .
	ld a,(0c022h)		;35c3	3a 22 c0	: " .  ; [ram_sol_timer_bank - Solenoid timer bank (multiple timers)]
	and a			;35c6	a7		.
	call nz,sub_27c0h	;35c7	c4 c0 27	. . '
	ret			;35ca	c9		.
l35cbh:
	ld a,0ffh		;35cb	3e ff		> .
	ld (0c121h),a		;35cd	32 21 c1	2 ! .  ; [ram_dip_switches - DIP switch (SW40) cached settings]
	ld a,(0c127h)		;35d0	3a 27 c1	: ' .
	and a			;35d3	a7		.
	jp nz,l35e4h		;35d4	c2 e4 35	. . 5
	ld hl,0c116h		;35d7	21 16 c1	! . .
	res 7,(hl)		;35da	cb be		. .
	ld a,(0c022h)		;35dc	3a 22 c0	: " .  ; [ram_sol_timer_bank - Solenoid timer bank (multiple timers)]
	and a			;35df	a7		.
	call nz,l27b3h		;35e0	c4 b3 27	. . '
	ret			;35e3	c9		.
l35e4h:
	ld hl,0c116h		;35e4	21 16 c1	! . .
	set 7,(hl)		;35e7	cb fe		. .
	ret			;35e9	c9		.
	di			;35ea	f3		.
	ld hl,l39aeh		;35eb	21 ae 39	! . 9
	ld a,(hl)		;35ee	7e		~
	ld (0c11bh),a		;35ef	32 1b c1	2 . .  ; [ram_lamp_col_B_state - Lamp column B on/off state]
	inc hl			;35f2	23		#
	ld a,(hl)		;35f3	7e		~
	ld (0c11ah),a		;35f4	32 1a c1	2 . .  ; [ram_lamp_col_A_state - Lamp column A on/off state]
	ld (0c11dh),a		;35f7	32 1d c1	2 . .  ; [ram_lamp_col_C_state - Lamp column C on/off state]
	inc hl			;35fa	23		#
	ld (0c11eh),hl		;35fb	22 1e c1	" . .  ; [ram_lamp_col_D_state - Lamp column D on/off state]
	ld a,0ffh		;35fe	3e ff		> .
	ld (0c119h),a		;3600	32 19 c1	2 . .  ; [ram_lamp_state_flags - Lamp state flags (23 refs)]
	ei			;3603	fb		.
	ret			;3604	c9		.
	di			;3605	f3		.
	ld hl,038cch		;3606	21 cc 38	! . 8
sub_3609h:
	ld a,(hl)		;3609	7e		~
	ld (0c11bh),a		;360a	32 1b c1	2 . .  ; [ram_lamp_col_B_state - Lamp column B on/off state]
	inc hl			;360d	23		#
	ld a,(hl)		;360e	7e		~
	ld (0c11ah),a		;360f	32 1a c1	2 . .  ; [ram_lamp_col_A_state - Lamp column A on/off state]
	ld (0c11dh),a		;3612	32 1d c1	2 . .  ; [ram_lamp_col_C_state - Lamp column C on/off state]
	inc hl			;3615	23		#
	ld (0c11eh),hl		;3616	22 1e c1	" . .  ; [ram_lamp_col_D_state - Lamp column D on/off state]
	ld a,0ffh		;3619	3e ff		> .
	ld (0c119h),a		;361b	32 19 c1	2 . .  ; [ram_lamp_state_flags - Lamp state flags (23 refs)]
	ei			;361e	fb		.
	ret			;361f	c9		.
	di			;3620	f3		.
	ld hl,l3b7ah		;3621	21 7a 3b	! z ;
	ld a,(hl)		;3624	7e		~
	ld (0c11bh),a		;3625	32 1b c1	2 . .  ; [ram_lamp_col_B_state - Lamp column B on/off state]
	inc hl			;3628	23		#
	ld a,(hl)		;3629	7e		~
	ld (0c11ah),a		;362a	32 1a c1	2 . .  ; [ram_lamp_col_A_state - Lamp column A on/off state]
	ld (0c11dh),a		;362d	32 1d c1	2 . .  ; [ram_lamp_col_C_state - Lamp column C on/off state]
	inc hl			;3630	23		#
	ld (0c11eh),hl		;3631	22 1e c1	" . .  ; [ram_lamp_col_D_state - Lamp column D on/off state]
	ld a,0ffh		;3634	3e ff		> .
	ld (0c119h),a		;3636	32 19 c1	2 . .  ; [ram_lamp_state_flags - Lamp state flags (23 refs)]
	ei			;3639	fb		.
	ret			;363a	c9		.
	di			;363b	f3		.
	ld hl,l3a90h		;363c	21 90 3a	! . :
	ld a,(hl)		;363f	7e		~
	ld (0c11bh),a		;3640	32 1b c1	2 . .  ; [ram_lamp_col_B_state - Lamp column B on/off state]
	inc hl			;3643	23		#
	ld a,(hl)		;3644	7e		~
	ld (0c11ah),a		;3645	32 1a c1	2 . .  ; [ram_lamp_col_A_state - Lamp column A on/off state]
	ld (0c11dh),a		;3648	32 1d c1	2 . .  ; [ram_lamp_col_C_state - Lamp column C on/off state]
	inc hl			;364b	23		#
	ld (0c11eh),hl		;364c	22 1e c1	" . .  ; [ram_lamp_col_D_state - Lamp column D on/off state]
	ld a,0ffh		;364f	3e ff		> .
	ld (0c119h),a		;3651	32 19 c1	2 . .  ; [ram_lamp_state_flags - Lamp state flags (23 refs)]
	ei			;3654	fb		.
	ret			;3655	c9		.
	di			;3656	f3		.
	ld hl,l3c5ch		;3657	21 5c 3c	! \ <
	ld a,(hl)		;365a	7e		~
	ld (0c11bh),a		;365b	32 1b c1	2 . .  ; [ram_lamp_col_B_state - Lamp column B on/off state]
	inc hl			;365e	23		#
	ld a,(hl)		;365f	7e		~
	ld (0c11ah),a		;3660	32 1a c1	2 . .  ; [ram_lamp_col_A_state - Lamp column A on/off state]
	ld (0c11dh),a		;3663	32 1d c1	2 . .  ; [ram_lamp_col_C_state - Lamp column C on/off state]
	inc hl			;3666	23		#
	ld (0c11eh),hl		;3667	22 1e c1	" . .  ; [ram_lamp_col_D_state - Lamp column D on/off state]
	ld a,0ffh		;366a	3e ff		> .
	ld (0c119h),a		;366c	32 19 c1	2 . .  ; [ram_lamp_state_flags - Lamp state flags (23 refs)]
	ei			;366f	fb		.
	ret			;3670	c9		.
	di			;3671	f3		.
	ld hl,l3d9eh		;3672	21 9e 3d	! . =
	ld a,(hl)		;3675	7e		~
	ld (0c11bh),a		;3676	32 1b c1	2 . .  ; [ram_lamp_col_B_state - Lamp column B on/off state]
	inc hl			;3679	23		#
	ld a,(hl)		;367a	7e		~
	ld (0c11ah),a		;367b	32 1a c1	2 . .  ; [ram_lamp_col_A_state - Lamp column A on/off state]
	ld (0c11dh),a		;367e	32 1d c1	2 . .  ; [ram_lamp_col_C_state - Lamp column C on/off state]
	inc hl			;3681	23		#
	ld (0c11eh),hl		;3682	22 1e c1	" . .  ; [ram_lamp_col_D_state - Lamp column D on/off state]
	ld a,0ffh		;3685	3e ff		> .
	ld (0c119h),a		;3687	32 19 c1	2 . .  ; [ram_lamp_state_flags - Lamp state flags (23 refs)]
	ei			;368a	fb		.
	ret			;368b	c9		.
sub_368ch:
	di			;368c	f3		.
	ld hl,l3eb0h		;368d	21 b0 3e	! . >
	ld a,(hl)		;3690	7e		~
	ld (0c11bh),a		;3691	32 1b c1	2 . .  ; [ram_lamp_col_B_state - Lamp column B on/off state]
	inc hl			;3694	23		#
	ld a,(hl)		;3695	7e		~
	ld (0c11ah),a		;3696	32 1a c1	2 . .  ; [ram_lamp_col_A_state - Lamp column A on/off state]
	ld (0c11dh),a		;3699	32 1d c1	2 . .  ; [ram_lamp_col_C_state - Lamp column C on/off state]
	inc hl			;369c	23		#
	ld (0c11eh),hl		;369d	22 1e c1	" . .  ; [ram_lamp_col_D_state - Lamp column D on/off state]
	ld a,0ffh		;36a0	3e ff		> .
	ld (0c119h),a		;36a2	32 19 c1	2 . .  ; [ram_lamp_state_flags - Lamp state flags (23 refs)]
	ei			;36a5	fb		.
	ret			;36a6	c9		.
init_extended_setup:
	di			;36a7	f3		.
	ld hl,l3eeah		;36a8	21 ea 3e	! . >
	ld a,(hl)		;36ab	7e		~
	ld (0c11bh),a		;36ac	32 1b c1	2 . .  ; [ram_lamp_col_B_state - Lamp column B on/off state]
	inc hl			;36af	23		#
	ld a,(hl)		;36b0	7e		~
	ld (0c11ah),a		;36b1	32 1a c1	2 . .  ; [ram_lamp_col_A_state - Lamp column A on/off state]
	ld (0c11dh),a		;36b4	32 1d c1	2 . .  ; [ram_lamp_col_C_state - Lamp column C on/off state]
	inc hl			;36b7	23		#
	ld (0c11eh),hl		;36b8	22 1e c1	" . .  ; [ram_lamp_col_D_state - Lamp column D on/off state]
	ld a,0ffh		;36bb	3e ff		> .
	ld (0c119h),a		;36bd	32 19 c1	2 . .  ; [ram_lamp_state_flags - Lamp state flags (23 refs)]
	ei			;36c0	fb		.
	ret			;36c1	c9		.
	di			;36c2	f3		.
	ld hl,l41fch		;36c3	21 fc 41	! . A
	ld a,(hl)		;36c6	7e		~
	ld (0c11bh),a		;36c7	32 1b c1	2 . .  ; [ram_lamp_col_B_state - Lamp column B on/off state]
	inc hl			;36ca	23		#
	ld a,(hl)		;36cb	7e		~
	ld (0c11ah),a		;36cc	32 1a c1	2 . .  ; [ram_lamp_col_A_state - Lamp column A on/off state]
	ld (0c11dh),a		;36cf	32 1d c1	2 . .  ; [ram_lamp_col_C_state - Lamp column C on/off state]
	inc hl			;36d2	23		#
	ld (0c11eh),hl		;36d3	22 1e c1	" . .  ; [ram_lamp_col_D_state - Lamp column D on/off state]
	ld a,0ffh		;36d6	3e ff		> .
	ld (0c119h),a		;36d8	32 19 c1	2 . .  ; [ram_lamp_state_flags - Lamp state flags (23 refs)]
	ei			;36db	fb		.
	ret			;36dc	c9		.
sub_36ddh:
	di			;36dd	f3		.
	ld hl,0451eh		;36de	21 1e 45	! . E
	ld a,(hl)		;36e1	7e		~
	ld (0c11bh),a		;36e2	32 1b c1	2 . .  ; [ram_lamp_col_B_state - Lamp column B on/off state]
	inc hl			;36e5	23		#
	ld a,(hl)		;36e6	7e		~
	ld (0c11ah),a		;36e7	32 1a c1	2 . .  ; [ram_lamp_col_A_state - Lamp column A on/off state]
	ld (0c11dh),a		;36ea	32 1d c1	2 . .  ; [ram_lamp_col_C_state - Lamp column C on/off state]
	inc hl			;36ed	23		#
	ld (0c11eh),hl		;36ee	22 1e c1	" . .  ; [ram_lamp_col_D_state - Lamp column D on/off state]
	ld a,0ffh		;36f1	3e ff		> .
	ld (0c119h),a		;36f3	32 19 c1	2 . .  ; [ram_lamp_state_flags - Lamp state flags (23 refs)]
	ei			;36f6	fb		.
	ret			;36f7	c9		.
delay_routine:
	di			;36f8	f3		.
	ld hl,l4b68h		;36f9	21 68 4b	! h K
	ld a,(hl)		;36fc	7e		~
	ld (0c11bh),a		;36fd	32 1b c1	2 . .  ; [ram_lamp_col_B_state - Lamp column B on/off state]
	inc hl			;3700	23		#
	ld a,(hl)		;3701	7e		~
	ld (0c11ah),a		;3702	32 1a c1	2 . .  ; [ram_lamp_col_A_state - Lamp column A on/off state]
	ld (0c11dh),a		;3705	32 1d c1	2 . .  ; [ram_lamp_col_C_state - Lamp column C on/off state]
	inc hl			;3708	23		#
	ld (0c11eh),hl		;3709	22 1e c1	" . .  ; [ram_lamp_col_D_state - Lamp column D on/off state]
	ld a,0ffh		;370c	3e ff		> .
	ld (0c119h),a		;370e	32 19 c1	2 . .  ; [ram_lamp_state_flags - Lamp state flags (23 refs)]
	ei			;3711	fb		.
	ret			;3712	c9		.
sub_3713h:
	di			;3713	f3		.
	ld hl,l4df0h		;3714	21 f0 4d	! . M
	ld a,(hl)		;3717	7e		~
	ld (0c11bh),a		;3718	32 1b c1	2 . .  ; [ram_lamp_col_B_state - Lamp column B on/off state]
	inc hl			;371b	23		#
	ld a,(hl)		;371c	7e		~
	ld (0c11ah),a		;371d	32 1a c1	2 . .  ; [ram_lamp_col_A_state - Lamp column A on/off state]
	ld (0c11dh),a		;3720	32 1d c1	2 . .  ; [ram_lamp_col_C_state - Lamp column C on/off state]
	inc hl			;3723	23		#
	ld (0c11eh),hl		;3724	22 1e c1	" . .  ; [ram_lamp_col_D_state - Lamp column D on/off state]
	ld a,0ffh		;3727	3e ff		> .
	ld (0c119h),a		;3729	32 19 c1	2 . .  ; [ram_lamp_state_flags - Lamp state flags (23 refs)]
	ei			;372c	fb		.
	ret			;372d	c9		.
sub_372eh:
	di			;372e	f3		.
	ld hl,l4eeah		;372f	21 ea 4e	! . N
	ld a,(hl)		;3732	7e		~
	ld (0c11bh),a		;3733	32 1b c1	2 . .  ; [ram_lamp_col_B_state - Lamp column B on/off state]
	inc hl			;3736	23		#
	ld a,(hl)		;3737	7e		~
	ld (0c11ah),a		;3738	32 1a c1	2 . .  ; [ram_lamp_col_A_state - Lamp column A on/off state]
	ld (0c11dh),a		;373b	32 1d c1	2 . .  ; [ram_lamp_col_C_state - Lamp column C on/off state]
	inc hl			;373e	23		#
	ld (0c11eh),hl		;373f	22 1e c1	" . .  ; [ram_lamp_col_D_state - Lamp column D on/off state]
	ld a,0ffh		;3742	3e ff		> .
	ld (0c119h),a		;3744	32 19 c1	2 . .  ; [ram_lamp_state_flags - Lamp state flags (23 refs)]
	ei			;3747	fb		.
	ret			;3748	c9		.
sub_3749h:
	di			;3749	f3		.
	ld hl,l4c24h		;374a	21 24 4c	! $ L
	ld a,(hl)		;374d	7e		~
	ld (0c11bh),a		;374e	32 1b c1	2 . .  ; [ram_lamp_col_B_state - Lamp column B on/off state]
	inc hl			;3751	23		#
	ld a,(hl)		;3752	7e		~
	ld (0c11ah),a		;3753	32 1a c1	2 . .  ; [ram_lamp_col_A_state - Lamp column A on/off state]
	ld (0c11dh),a		;3756	32 1d c1	2 . .  ; [ram_lamp_col_C_state - Lamp column C on/off state]
	inc hl			;3759	23		#
	ld (0c11eh),hl		;375a	22 1e c1	" . .  ; [ram_lamp_col_D_state - Lamp column D on/off state]
	ld a,0ffh		;375d	3e ff		> .
	ld (0c119h),a		;375f	32 19 c1	2 . .  ; [ram_lamp_state_flags - Lamp state flags (23 refs)]
	ei			;3762	fb		.
	ret			;3763	c9		.
sub_3764h:
	di			;3764	f3		.
	ld hl,l4ba2h		;3765	21 a2 4b	! . K
	ld a,(hl)		;3768	7e		~
	ld (0c11bh),a		;3769	32 1b c1	2 . .  ; [ram_lamp_col_B_state - Lamp column B on/off state]
	inc hl			;376c	23		#
	ld a,(hl)		;376d	7e		~
	ld (0c11ah),a		;376e	32 1a c1	2 . .  ; [ram_lamp_col_A_state - Lamp column A on/off state]
	ld (0c11dh),a		;3771	32 1d c1	2 . .  ; [ram_lamp_col_C_state - Lamp column C on/off state]
	inc hl			;3774	23		#
	ld (0c11eh),hl		;3775	22 1e c1	" . .  ; [ram_lamp_col_D_state - Lamp column D on/off state]
	ld a,0ffh		;3778	3e ff		> .
	ld (0c119h),a		;377a	32 19 c1	2 . .  ; [ram_lamp_state_flags - Lamp state flags (23 refs)]
	ei			;377d	fb		.
	ret			;377e	c9		.
sub_377fh:
	di			;377f	f3		.
	ld hl,l4d2eh		;3780	21 2e 4d	! . M
	ld a,(hl)		;3783	7e		~
	ld (0c11bh),a		;3784	32 1b c1	2 . .  ; [ram_lamp_col_B_state - Lamp column B on/off state]
	inc hl			;3787	23		#
	ld a,(hl)		;3788	7e		~
	ld (0c11ah),a		;3789	32 1a c1	2 . .  ; [ram_lamp_col_A_state - Lamp column A on/off state]
	ld (0c11dh),a		;378c	32 1d c1	2 . .  ; [ram_lamp_col_C_state - Lamp column C on/off state]
	inc hl			;378f	23		#
	ld (0c11eh),hl		;3790	22 1e c1	" . .  ; [ram_lamp_col_D_state - Lamp column D on/off state]
	ld a,0ffh		;3793	3e ff		> .
	ld (0c119h),a		;3795	32 19 c1	2 . .  ; [ram_lamp_state_flags - Lamp state flags (23 refs)]
	ei			;3798	fb		.
	ret			;3799	c9		.
sub_379ah:
	xor a			;379a	af		.
	ld (0c125h),a		;379b	32 25 c1	2 % .
	ld a,001h		;379e	3e 01		> .
	ld (0c124h),a		;37a0	32 24 c1	2 $ .
	ld a,0ffh		;37a3	3e ff		> .
	ld (0c122h),a		;37a5	32 22 c1	2 " .
	ret			;37a8	c9		.
sub_37a9h:
	ld a,(0c124h)		;37a9	3a 24 c1	: $ .
	dec a			;37ac	3d		=
	ld (0c124h),a		;37ad	32 24 c1	2 $ .
	ret nz			;37b0	c0		.
	ld a,064h		;37b1	3e 64		> d
	ld (0c124h),a		;37b3	32 24 c1	2 $ .
	ld a,(0c125h)		;37b6	3a 25 c1	: % .
	cp 017h			;37b9	fe 17		. .
	jp c,l37c2h		;37bb	da c2 37	. . 7
	xor a			;37be	af		.
	jp l37c3h		;37bf	c3 c3 37	. . 7
l37c2h:
	inc a			;37c2	3c		<
l37c3h:
	ld (0c125h),a		;37c3	32 25 c1	2 % .
	ld hl,l37e2h		;37c6	21 e2 37	! . 7
	sla a			;37c9	cb 27		. '
	ld e,a			;37cb	5f		_
	ld d,000h		;37cc	16 00		. .
	add hl,de		;37ce	19		.
	ld e,(hl)		;37cf	5e		^
	inc hl			;37d0	23		#
	ld d,(hl)		;37d1	56		V
	ex de,hl		;37d2	eb		.
	jp (hl)			;37d3	e9		.
sub_37d4h:
	xor a			;37d4	af		.
	ld (0c122h),a		;37d5	32 22 c1	2 " .
	call sub_0a12h		;37d8	cd 12 0a	. . .
	call sub_0a1eh		;37db	cd 1e 0a	. . .
	call sub_0a2ah		;37de	cd 2a 0a	. * .
	ret			;37e1	c9		.
l37e2h:
	xor 009h		;37e2	ee 09		. .
	ld (de),a		;37e4	12		.
	ld a,(bc)		;37e5	0a		.
	jp m,l1e09h		;37e6	fa 09 1e	. . .
	ld a,(bc)		;37e9	0a		.
	ld b,00ah		;37ea	06 0a		. .
	ld hl,(0fa0ah)		;37ec	2a 0a fa	* . .
	add hl,bc		;37ef	09		.
	ld e,00ah		;37f0	1e 0a		. .
	jp m,l1e09h		;37f2	fa 09 1e	. . .
	ld a,(bc)		;37f5	0a		.
	xor 009h		;37f6	ee 09		. .
	ld (de),a		;37f8	12		.
	ld a,(bc)		;37f9	0a		.
	xor 009h		;37fa	ee 09		. .
	ld (de),a		;37fc	12		.
	ld a,(bc)		;37fd	0a		.
	ld b,00ah		;37fe	06 0a		. .
	ld hl,(0060ah)		;3800	2a 0a 06	* . .
	ld a,(bc)		;3803	0a		.
	ld hl,(0fa0ah)		;3804	2a 0a fa	* . .
	add hl,bc		;3807	09		.
	ld e,00ah		;3808	1e 0a		. .
	xor 009h		;380a	ee 09		. .
	ld (de),a		;380c	12		.
	ld a,(bc)		;380d	0a		.
	ld b,00ah		;380e	06 0a		. .
	ld hl,(l3a0ah)		;3810	2a 0a 3a	* . :
	inc e			;3813	1c		.
	pop bc			;3814	c1		.
	cp 04dh			;3815	fe 4d		. M
	jp c,l381eh		;3817	da 1e 38	. . 8
	xor a			;381a	af		.
	jp l381fh		;381b	c3 1f 38	. . 8
l381eh:
	inc a			;381e	3c		<
l381fh:
	ld (0c11ch),a		;381f	32 1c c1	2 . .
	ld hl,l3830h		;3822	21 30 38	! 0 8
	sla a			;3825	cb 27		. '
	ld e,a			;3827	5f		_
	ld d,000h		;3828	16 00		. .
	add hl,de		;382a	19		.
	ld e,(hl)		;382b	5e		^
	inc hl			;382c	23		#
	ld d,(hl)		;382d	56		V
	ex de,hl		;382e	eb		.
	jp (hl)			;382f	e9		.
l3830h:
	and a			;3830	a7		.
	ld (hl),0eah		;3831	36 ea		6 .
	dec (hl)		;3833	35		5
	dec b			;3834	05		.
	ld (hl),0c2h		;3835	36 c2		6 .
	ld (hl),005h		;3837	36 05		6 .
	ld (hl),0eah		;3839	36 ea		6 .
	dec (hl)		;383b	35		5
	ret m			;383c	f8		.
	ld (hl),0a7h		;383d	36 a7		6 .
	ld (hl),013h		;383f	36 13		6 .
	scf			;3841	37		7
	jp nz,02e36h		;3842	c2 36 2e	. 6 .
	scf			;3845	37		7
	ld (ix+020h),036h	;3846	dd 36 20 36	. 6   6
	jr nz,$+56		;384a	20 36		  6
	ld (ix+03bh),036h	;384c	dd 36 3b 36	. 6 ; 6
	jr nz,$+56		;3850	20 36		  6
	adc a,h			;3852	8c		.
	ld (hl),0c2h		;3853	36 c2		6 .
	ld (hl),03bh		;3855	36 3b		6 ;
	ld (hl),020h		;3857	36 20		6  
	ld (hl),056h		;3859	36 56		6 V
	ld (hl),071h		;385b	36 71		6 q
	ld (hl),0ddh		;385d	36 dd		6 .
	ld (hl),049h		;385f	36 49		6 I
	scf			;3861	37		7
	jp pe,l6435h		;3862	ea 35 64	. 5 d
	scf			;3865	37		7
	dec b			;3866	05		.
	ld (hl),07fh		;3867	36 7f		6 .
	scf			;3869	37		7
	jp pe,0a735h		;386a	ea 35 a7	. 5 .
	ld (hl),08ch		;386d	36 8c		6 .
	ld (hl),0c2h		;386f	36 c2		6 .
	ld (hl),08ch		;3871	36 8c		6 .
	ld (hl),0ddh		;3873	36 dd		6 .
	ld (hl),0a7h		;3875	36 a7		6 .
	ld (hl),0eah		;3877	36 ea		6 .
	dec (hl)		;3879	35		5
	dec b			;387a	05		.
	ld (hl),020h		;387b	36 20		6  
	ld (hl),03bh		;387d	36 3b		6 ;
	ld (hl),0ddh		;387f	36 dd		6 .
	ld (hl),08ch		;3881	36 8c		6 .
	ld (hl),013h		;3883	36 13		6 .
	scf			;3885	37		7
	and a			;3886	a7		.
	ld (hl),0f8h		;3887	36 f8		6 .
	ld (hl),0c2h		;3889	36 c2		6 .
	ld (hl),07fh		;388b	36 7f		6 .
	scf			;388d	37		7
	ld (ix+03bh),036h	;388e	dd 36 3b 36	. 6 ; 6
	jr nz,l38cah		;3892	20 36		  6
	dec b			;3894	05		.
	ld (hl),0eah		;3895	36 ea		6 .
	dec (hl)		;3897	35		5
	ld (ix-074h),036h	;3898	dd 36 8c 36	. 6 . 6
	jp nz,08c36h		;389c	c2 36 8c	. 6 .
	ld (hl),0eah		;389f	36 ea		6 .
	dec (hl)		;38a1	35		5
	dec b			;38a2	05		.
	ld (hl),08ch		;38a3	36 8c		6 .
	ld (hl),0ddh		;38a5	36 dd		6 .
	ld (hl),064h		;38a7	36 64		6 d
	scf			;38a9	37		7
	jp pe,l4935h		;38aa	ea 35 49	. 5 I
	scf			;38ad	37		7
	dec b			;38ae	05		.
	ld (hl),02eh		;38af	36 2e		6 .
	scf			;38b1	37		7
	jr nz,l38eah		;38b2	20 36		  6
	jp pe,02035h		;38b4	ea 35 20	. 5  
	ld (hl),005h		;38b7	36 05		6 .
	ld (hl),03bh		;38b9	36 3b		6 ;
	ld (hl),0a7h		;38bb	36 a7		6 .
	ld (hl),0ddh		;38bd	36 dd		6 .
	ld (hl),0eah		;38bf	36 ea		6 .
	dec (hl)		;38c1	35		5
	dec b			;38c2	05		.
	ld (hl),049h		;38c3	36 49		6 I
	scf			;38c5	37		7
	ld h,h			;38c6	64		d
	scf			;38c7	37		7
l38c8h:
	ld a,a			;38c8	7f		.
	scf			;38c9	37		7
l38cah:
	adc a,h			;38ca	8c		.
	ld (hl),01ch		;38cb	36 1c		6 .
	ld a,(bc)		;38cd	0a		.
	nop			;38ce	00		.
	nop			;38cf	00		.
	nop			;38d0	00		.
	nop			;38d1	00		.
	nop			;38d2	00		.
	cp 001h			;38d3	fe 01		. .
	nop			;38d5	00		.
	nop			;38d6	00		.
	ret nz			;38d7	c0		.
	ld h,c			;38d8	61		a
	nop			;38d9	00		.
	nop			;38da	00		.
	cp 001h			;38db	fe 01		. .
	nop			;38dd	00		.
	nop			;38de	00		.
	ret m			;38df	f8		.
	ld (hl),c		;38e0	71		q
	nop			;38e1	00		.
	nop			;38e2	00		.
	cp 001h			;38e3	fe 01		. .
	inc c			;38e5	0c		.
	nop			;38e6	00		.
	rst 38h			;38e7	ff		.
	ld a,c			;38e8	79		y
	nop			;38e9	00		.
l38eah:
	nop			;38ea	00		.
	cp 081h			;38eb	fe 81		. .
	ld e,080h		;38ed	1e 80		. .
	rst 38h			;38ef	ff		.
	ld a,l			;38f0	7d		}
	nop			;38f1	00		.
	nop			;38f2	00		.
	cp 0a1h			;38f3	fe a1		. .
	rra			;38f5	1f		.
	sbc a,b			;38f6	98		.
	rst 38h			;38f7	ff		.
	ld a,a			;38f8	7f		.
	nop			;38f9	00		.
	nop			;38fa	00		.
	cp 0b1h			;38fb	fe b1		. .
	ccf			;38fd	3f		?
	sbc a,(hl)		;38fe	9e		.
	rst 38h			;38ff	ff		.
	rst 38h			;3900	ff		.
	ld bc,0fe00h		;3901	01 00 fe	. . .
	defb 0fdh,03fh,09eh ;illegal sequence	;3904	fd 3f 9e	. ? .
	rst 38h			;3907	ff		.
	rst 38h			;3908	ff		.
	ld bc,0fe20h		;3909	01 20 fe	.   .
	rst 38h			;390c	ff		.
	ccf			;390d	3f		?
	sbc a,(hl)		;390e	9e		.
	rst 38h			;390f	ff		.
	rst 38h			;3910	ff		.
	ld bc,0fef8h		;3911	01 f8 fe	. . .
	rst 38h			;3914	ff		.
	ld a,a			;3915	7f		.
	sbc a,(hl)		;3916	9e		.
	rst 38h			;3917	ff		.
	rst 38h			;3918	ff		.
	ld bc,0fefeh		;3919	01 fe fe	. . .
	rst 38h			;391c	ff		.
	ld a,a			;391d	7f		.
	sbc a,(hl)		;391e	9e		.
	rst 38h			;391f	ff		.
	rst 38h			;3920	ff		.
	add a,c			;3921	81		.
	rst 38h			;3922	ff		.
	cp 0ffh			;3923	fe ff		. .
	ld a,a			;3925	7f		.
	sbc a,(hl)		;3926	9e		.
	rst 38h			;3927	ff		.
	rst 38h			;3928	ff		.
	pop hl			;3929	e1		.
	rst 38h			;392a	ff		.
	rst 38h			;392b	ff		.
	rst 38h			;392c	ff		.
	rst 38h			;392d	ff		.
	sbc a,(hl)		;392e	9e		.
	rst 38h			;392f	ff		.
	rst 38h			;3930	ff		.
	ld sp,hl		;3931	f9		.
	rst 38h			;3932	ff		.
	rst 38h			;3933	ff		.
	rst 38h			;3934	ff		.
	rst 38h			;3935	ff		.
	sbc a,(hl)		;3936	9e		.
	rst 38h			;3937	ff		.
	rst 38h			;3938	ff		.
	rst 38h			;3939	ff		.
	rst 38h			;393a	ff		.
	rst 38h			;393b	ff		.
	rst 38h			;393c	ff		.
	rst 38h			;393d	ff		.
	sbc a,(hl)		;393e	9e		.
	rst 38h			;393f	ff		.
	rst 38h			;3940	ff		.
	rst 38h			;3941	ff		.
	rst 38h			;3942	ff		.
	ld bc,0fffeh		;3943	01 fe ff	. . .
	sbc a,(hl)		;3946	9e		.
	ccf			;3947	3f		?
	sbc a,(hl)		;3948	9e		.
	rst 38h			;3949	ff		.
	rst 38h			;394a	ff		.
	ld bc,0fffeh		;394b	01 fe ff	. . .
	sbc a,(hl)		;394e	9e		.
	rlca			;394f	07		.
	adc a,(hl)		;3950	8e		.
	rst 38h			;3951	ff		.
	rst 38h			;3952	ff		.
	ld bc,0f3feh		;3953	01 fe f3	. . .
	sbc a,(hl)		;3956	9e		.
	nop			;3957	00		.
	add a,(hl)		;3958	86		.
	rst 38h			;3959	ff		.
	rst 38h			;395a	ff		.
	ld bc,0e17eh		;395b	01 7e e1	. ~ .
	ld e,000h		;395e	1e 00		. .
	add a,d			;3960	82		.
	rst 38h			;3961	ff		.
	rst 38h			;3962	ff		.
	ld bc,0e05eh		;3963	01 5e e0	. ^ .
	ld b,000h		;3966	06 00		. .
	add a,b			;3968	80		.
	rst 38h			;3969	ff		.
	rst 38h			;396a	ff		.
	ld bc,0c04eh		;396b	01 4e c0	. N .
	nop			;396e	00		.
	nop			;396f	00		.
	nop			;3970	00		.
	cp 0ffh			;3971	fe ff		. .
	ld bc,0c002h		;3973	01 02 c0	. . .
	nop			;3976	00		.
	nop			;3977	00		.
	nop			;3978	00		.
	cp 0dfh			;3979	fe df		. .
	ld bc,0c000h		;397b	01 00 c0	. . .
	nop			;397e	00		.
	nop			;397f	00		.
	nop			;3980	00		.
	cp 007h			;3981	fe 07		. .
	ld bc,08000h		;3983	01 00 80	. . .
	nop			;3986	00		.
	nop			;3987	00		.
	nop			;3988	00		.
	cp 001h			;3989	fe 01		. .
	ld bc,08000h		;398b	01 00 80	. . .
	nop			;398e	00		.
	nop			;398f	00		.
	nop			;3990	00		.
	ld a,(hl)		;3991	7e		~
	nop			;3992	00		.
	ld bc,08000h		;3993	01 00 80	. . .
	nop			;3996	00		.
	nop			;3997	00		.
	nop			;3998	00		.
	ld e,000h		;3999	1e 00		. .
	nop			;399b	00		.
	nop			;399c	00		.
	nop			;399d	00		.
	nop			;399e	00		.
	nop			;399f	00		.
	nop			;39a0	00		.
	ld b,000h		;39a1	06 00		. .
	nop			;39a3	00		.
	nop			;39a4	00		.
	nop			;39a5	00		.
	nop			;39a6	00		.
	nop			;39a7	00		.
	nop			;39a8	00		.
	nop			;39a9	00		.
	nop			;39aa	00		.
	nop			;39ab	00		.
	nop			;39ac	00		.
	nop			;39ad	00		.
l39aeh:
	inc e			;39ae	1c		.
	ld a,(bc)		;39af	0a		.
	nop			;39b0	00		.
	nop			;39b1	00		.
	nop			;39b2	00		.
	ld b,000h		;39b3	06 00		. .
	nop			;39b5	00		.
	nop			;39b6	00		.
	nop			;39b7	00		.
	nop			;39b8	00		.
	nop			;39b9	00		.
	nop			;39ba	00		.
	ld e,000h		;39bb	1e 00		. .
	nop			;39bd	00		.
	nop			;39be	00		.
	nop			;39bf	00		.
	nop			;39c0	00		.
	nop			;39c1	00		.
	nop			;39c2	00		.
	ld a,(hl)		;39c3	7e		~
	nop			;39c4	00		.
	ld bc,08000h		;39c5	01 00 80	. . .
	nop			;39c8	00		.
	nop			;39c9	00		.
	nop			;39ca	00		.
	cp 001h			;39cb	fe 01		. .
	ld bc,08000h		;39cd	01 00 80	. . .
	nop			;39d0	00		.
	nop			;39d1	00		.
	nop			;39d2	00		.
	cp 007h			;39d3	fe 07		. .
	ld bc,08000h		;39d5	01 00 80	. . .
	nop			;39d8	00		.
	nop			;39d9	00		.
	nop			;39da	00		.
	cp 0dfh			;39db	fe df		. .
	ld bc,0c000h		;39dd	01 00 c0	. . .
	nop			;39e0	00		.
	nop			;39e1	00		.
	nop			;39e2	00		.
	cp 0ffh			;39e3	fe ff		. .
	ld bc,0c002h		;39e5	01 02 c0	. . .
	ld b,000h		;39e8	06 00		. .
	add a,b			;39ea	80		.
	rst 38h			;39eb	ff		.
	rst 38h			;39ec	ff		.
	ld bc,0c04eh		;39ed	01 4e c0	. N .
	ld e,000h		;39f0	1e 00		. .
	add a,d			;39f2	82		.
	rst 38h			;39f3	ff		.
	rst 38h			;39f4	ff		.
	ld bc,0e05eh		;39f5	01 5e e0	. ^ .
	sbc a,(hl)		;39f8	9e		.
	nop			;39f9	00		.
	add a,(hl)		;39fa	86		.
	rst 38h			;39fb	ff		.
	rst 38h			;39fc	ff		.
	ld bc,0e17eh		;39fd	01 7e e1	. ~ .
	sbc a,(hl)		;3a00	9e		.
	rlca			;3a01	07		.
	adc a,(hl)		;3a02	8e		.
	rst 38h			;3a03	ff		.
	rst 38h			;3a04	ff		.
	ld bc,0f3feh		;3a05	01 fe f3	. . .
	sbc a,(hl)		;3a08	9e		.
	ccf			;3a09	3f		?
l3a0ah:
	sbc a,(hl)		;3a0a	9e		.
	rst 38h			;3a0b	ff		.
	rst 38h			;3a0c	ff		.
	ld bc,0fffeh		;3a0d	01 fe ff	. . .
	sbc a,(hl)		;3a10	9e		.
	rst 38h			;3a11	ff		.
	rst 38h			;3a12	ff		.
	rst 38h			;3a13	ff		.
	rst 38h			;3a14	ff		.
	ld bc,0fffeh		;3a15	01 fe ff	. . .
	sbc a,(hl)		;3a18	9e		.
	rst 38h			;3a19	ff		.
	rst 38h			;3a1a	ff		.
	rst 38h			;3a1b	ff		.
	rst 38h			;3a1c	ff		.
	rst 38h			;3a1d	ff		.
	rst 38h			;3a1e	ff		.
	rst 38h			;3a1f	ff		.
	sbc a,(hl)		;3a20	9e		.
	rst 38h			;3a21	ff		.
	rst 38h			;3a22	ff		.
	ld sp,hl		;3a23	f9		.
	rst 38h			;3a24	ff		.
	rst 38h			;3a25	ff		.
	rst 38h			;3a26	ff		.
	rst 38h			;3a27	ff		.
	sbc a,(hl)		;3a28	9e		.
	rst 38h			;3a29	ff		.
	rst 38h			;3a2a	ff		.
	pop hl			;3a2b	e1		.
	rst 38h			;3a2c	ff		.
	rst 38h			;3a2d	ff		.
	rst 38h			;3a2e	ff		.
	rst 38h			;3a2f	ff		.
	sbc a,(hl)		;3a30	9e		.
	rst 38h			;3a31	ff		.
	rst 38h			;3a32	ff		.
	add a,c			;3a33	81		.
	rst 38h			;3a34	ff		.
	cp 0ffh			;3a35	fe ff		. .
	ld a,a			;3a37	7f		.
	sbc a,(hl)		;3a38	9e		.
	rst 38h			;3a39	ff		.
	rst 38h			;3a3a	ff		.
	ld bc,0fefeh		;3a3b	01 fe fe	. . .
	rst 38h			;3a3e	ff		.
	ld a,a			;3a3f	7f		.
	sbc a,(hl)		;3a40	9e		.
	rst 38h			;3a41	ff		.
	rst 38h			;3a42	ff		.
	ld bc,0fef8h		;3a43	01 f8 fe	. . .
	rst 38h			;3a46	ff		.
	ld a,a			;3a47	7f		.
	sbc a,(hl)		;3a48	9e		.
	rst 38h			;3a49	ff		.
	rst 38h			;3a4a	ff		.
	ld bc,0fe20h		;3a4b	01 20 fe	.   .
	rst 38h			;3a4e	ff		.
	ccf			;3a4f	3f		?
	sbc a,(hl)		;3a50	9e		.
	rst 38h			;3a51	ff		.
	rst 38h			;3a52	ff		.
	ld bc,0fe00h		;3a53	01 00 fe	. . .
	defb 0fdh,03fh,098h ;illegal sequence	;3a56	fd 3f 98	. ? .
	rst 38h			;3a59	ff		.
	ld a,a			;3a5a	7f		.
	nop			;3a5b	00		.
	nop			;3a5c	00		.
	cp 0b1h			;3a5d	fe b1		. .
	ccf			;3a5f	3f		?
	add a,b			;3a60	80		.
	rst 38h			;3a61	ff		.
	ld a,l			;3a62	7d		}
	nop			;3a63	00		.
	nop			;3a64	00		.
	cp 0a1h			;3a65	fe a1		. .
	rra			;3a67	1f		.
	nop			;3a68	00		.
	rst 38h			;3a69	ff		.
	ld a,c			;3a6a	79		y
	nop			;3a6b	00		.
	nop			;3a6c	00		.
	cp 081h			;3a6d	fe 81		. .
	ld e,000h		;3a6f	1e 00		. .
	ret m			;3a71	f8		.
	ld (hl),c		;3a72	71		q
	nop			;3a73	00		.
	nop			;3a74	00		.
	cp 001h			;3a75	fe 01		. .
	inc c			;3a77	0c		.
	nop			;3a78	00		.
	ret nz			;3a79	c0		.
	ld h,c			;3a7a	61		a
	nop			;3a7b	00		.
	nop			;3a7c	00		.
	cp 001h			;3a7d	fe 01		. .
	nop			;3a7f	00		.
	nop			;3a80	00		.
	nop			;3a81	00		.
	nop			;3a82	00		.
	nop			;3a83	00		.
	nop			;3a84	00		.
	cp 001h			;3a85	fe 01		. .
	nop			;3a87	00		.
	nop			;3a88	00		.
	nop			;3a89	00		.
	nop			;3a8a	00		.
	nop			;3a8b	00		.
	nop			;3a8c	00		.
	nop			;3a8d	00		.
	nop			;3a8e	00		.
	nop			;3a8f	00		.
l3a90h:
	dec e			;3a90	1d		.
	jr l3a93h		;3a91	18 00		. .
l3a93h:
	nop			;3a93	00		.
	nop			;3a94	00		.
	nop			;3a95	00		.
	nop			;3a96	00		.
	nop			;3a97	00		.
	nop			;3a98	00		.
	nop			;3a99	00		.
	nop			;3a9a	00		.
	nop			;3a9b	00		.
	nop			;3a9c	00		.
	nop			;3a9d	00		.
	nop			;3a9e	00		.
	nop			;3a9f	00		.
	nop			;3aa0	00		.
	jr nz,l3aa3h		;3aa1	20 00		  .
l3aa3h:
	nop			;3aa3	00		.
	nop			;3aa4	00		.
	nop			;3aa5	00		.
	nop			;3aa6	00		.
	nop			;3aa7	00		.
	jr nz,l3acch		;3aa8	20 22		  "
	ld b,b			;3aaa	40		@
	nop			;3aab	00		.
	nop			;3aac	00		.
	nop			;3aad	00		.
	ld bc,02020h		;3aae	01 20 20	.    
	ld (l4040h+1),hl	;3ab1	22 41 40	" A @
	nop			;3ab4	00		.
	nop			;3ab5	00		.
	ld bc,02020h		;3ab6	01 20 20	.    
	ld h,d			;3ab9	62		b
	ld b,c			;3aba	41		A
	ld b,b			;3abb	40		@
	ld b,b			;3abc	40		@
	nop			;3abd	00		.
	ld hl,l6020h		;3abe	21 20 60	!   `
	ld h,d			;3ac1	62		b
	ld b,c			;3ac2	41		A
	ld b,b			;3ac3	40		@
	ld b,b			;3ac4	40		@
	ld b,b			;3ac5	40		@
	ld hl,l6020h		;3ac6	21 20 60	!   `
	ld h,d			;3ac9	62		b
	ld e,c			;3aca	59		Y
	ld e,b			;3acb	58		X
l3acch:
	ld c,b			;3acc	48		H
	ld c,b			;3acd	48		H
	ld l,c			;3ace	69		i
	jr z,l3b39h		;3acf	28 68		( h
	ld l,d			;3ad1	6a		j
	ld e,l			;3ad2	5d		]
	ld e,b			;3ad3	58		X
	ld c,b			;3ad4	48		H
	ld c,b			;3ad5	48		H
	ld l,l			;3ad6	6d		m
	ld l,h			;3ad7	6c		l
	ld l,h			;3ad8	6c		l
	ld l,(hl)		;3ad9	6e		n
	ld e,a			;3ada	5f		_
	ld e,h			;3adb	5c		\
	ld e,h			;3adc	5c		\
	ld l,l			;3add	6d		m
	ld l,l			;3ade	6d		m
	ld l,h			;3adf	6c		l
	ld l,(hl)		;3ae0	6e		n
	xor 0dfh		;3ae1	ee df		. .
	ld e,(hl)		;3ae3	5e		^
	ld a,(hl)		;3ae4	7e		~
	ld l,a			;3ae5	6f		o
	ld l,a			;3ae6	6f		o
	ld l,(hl)		;3ae7	6e		n
l3ae8h:
	ld l,(hl)		;3ae8	6e		n
	xor 0dfh		;3ae9	ee df		. .
	ld a,(hl)		;3aeb	7e		~
	ld a,(hl)		;3aec	7e		~
	ld a,a			;3aed	7f		.
	ld a,a			;3aee	7f		.
	ld a,(hl)		;3aef	7e		~
	ld l,(hl)		;3af0	6e		n
	xor 0dfh		;3af1	ee df		. .
	ld a,(hl)		;3af3	7e		~
	cp 07fh			;3af4	fe 7f		. .
	ld a,a			;3af6	7f		.
	ld a,(hl)		;3af7	7e		~
	ld l,(hl)		;3af8	6e		n
	xor 0ffh		;3af9	ee ff		. .
	ld a,(hl)		;3afb	7e		~
	cp 0ffh			;3afc	fe ff		. .
	ld a,a			;3afe	7f		.
	cp 06eh			;3aff	fe 6e		. n
	xor 0ffh		;3b01	ee ff		. .
	ld a,(hl)		;3b03	7e		~
	cp 0ffh			;3b04	fe ff		. .
	ld a,a			;3b06	7f		.
	cp 0eeh			;3b07	fe ee		. .
	xor 0ffh		;3b09	ee ff		. .
	ld a,(hl)		;3b0b	7e		~
	cp 0ffh			;3b0c	fe ff		. .
	ld a,a			;3b0e	7f		.
	cp 0eeh			;3b0f	fe ee		. .
	adc a,0ffh		;3b11	ce ff		. .
	ld a,(hl)		;3b13	7e		~
	cp 0ffh			;3b14	fe ff		. .
	ld a,a			;3b16	7f		.
	cp 0ceh			;3b17	fe ce		. .
	call z,sub_7ebfh	;3b19	cc bf 7e	. . ~
	cp 0ffh			;3b1c	fe ff		. .
	ld a,(hl)		;3b1e	7e		~
	sbc a,0ceh		;3b1f	de ce		. .
	call z,sub_3ebeh	;3b21	cc be 3e	. . >
	cp 0ffh			;3b24	fe ff		. .
	ld a,(hl)		;3b26	7e		~
	sbc a,0ceh		;3b27	de ce		. .
	adc a,h			;3b29	8c		.
	cp (hl)			;3b2a	be		.
	ld a,0beh		;3b2b	3e be		> .
	rst 38h			;3b2d	ff		.
	ld e,(hl)		;3b2e	5e		^
	sbc a,08eh		;3b2f	de 8e		. .
	adc a,h			;3b31	8c		.
	cp (hl)			;3b32	be		.
	ld a,0beh		;3b33	3e be		> .
	cp a			;3b35	bf		.
	ld e,(hl)		;3b36	5e		^
	sbc a,08eh		;3b37	de 8e		. .
l3b39h:
	adc a,h			;3b39	8c		.
	and (hl)		;3b3a	a6		.
	ld h,0b6h		;3b3b	26 b6		& .
	or a			;3b3d	b7		.
	ld d,0d6h		;3b3e	16 d6		. .
	add a,(hl)		;3b40	86		.
	add a,h			;3b41	84		.
	and d			;3b42	a2		.
	ld h,0b6h		;3b43	26 b6		& .
	or a			;3b45	b7		.
	ld (de),a		;3b46	12		.
	sub d			;3b47	92		.
	add a,d			;3b48	82		.
	add a,b			;3b49	80		.
	and b			;3b4a	a0		.
	ld (092a2h),hl		;3b4b	22 a2 92	" . .
	ld (de),a		;3b4e	12		.
	sub d			;3b4f	92		.
	add a,b			;3b50	80		.
	nop			;3b51	00		.
	jr nz,l3b74h		;3b52	20 20		   
	add a,b			;3b54	80		.
	sub b			;3b55	90		.
	djnz l3ae8h		;3b56	10 90		. .
	add a,b			;3b58	80		.
	nop			;3b59	00		.
	jr nz,l3b5ch		;3b5a	20 00		  .
l3b5ch:
	add a,b			;3b5c	80		.
	add a,b			;3b5d	80		.
	nop			;3b5e	00		.
	add a,b			;3b5f	80		.
	add a,b			;3b60	80		.
	nop			;3b61	00		.
	jr nz,l3b64h		;3b62	20 00		  .
l3b64h:
	nop			;3b64	00		.
	add a,b			;3b65	80		.
	nop			;3b66	00		.
	add a,b			;3b67	80		.
	add a,b			;3b68	80		.
	nop			;3b69	00		.
	nop			;3b6a	00		.
	nop			;3b6b	00		.
	nop			;3b6c	00		.
	nop			;3b6d	00		.
	nop			;3b6e	00		.
	nop			;3b6f	00		.
	add a,b			;3b70	80		.
	nop			;3b71	00		.
	nop			;3b72	00		.
	nop			;3b73	00		.
l3b74h:
	nop			;3b74	00		.
	nop			;3b75	00		.
	nop			;3b76	00		.
	nop			;3b77	00		.
	nop			;3b78	00		.
	nop			;3b79	00		.
l3b7ah:
	inc e			;3b7a	1c		.
	jr l3b7dh		;3b7b	18 00		. .
l3b7dh:
	nop			;3b7d	00		.
	nop			;3b7e	00		.
	nop			;3b7f	00		.
	nop			;3b80	00		.
	nop			;3b81	00		.
	nop			;3b82	00		.
	nop			;3b83	00		.
	nop			;3b84	00		.
	nop			;3b85	00		.
	nop			;3b86	00		.
	nop			;3b87	00		.
	nop			;3b88	00		.
	nop			;3b89	00		.
	nop			;3b8a	00		.
	jr nz,l3b8dh		;3b8b	20 00		  .
l3b8dh:
	nop			;3b8d	00		.
	nop			;3b8e	00		.
	nop			;3b8f	00		.
	nop			;3b90	00		.
	nop			;3b91	00		.
	jr nz,l3bb6h		;3b92	20 22		  "
	ld b,b			;3b94	40		@
	nop			;3b95	00		.
	nop			;3b96	00		.
	nop			;3b97	00		.
	ld bc,02020h		;3b98	01 20 20	.    
	ld (l4040h+1),hl	;3b9b	22 41 40	" A @
	nop			;3b9e	00		.
	nop			;3b9f	00		.
	ld bc,02020h		;3ba0	01 20 20	.    
	ld h,d			;3ba3	62		b
	ld b,c			;3ba4	41		A
	ld b,b			;3ba5	40		@
	ld b,b			;3ba6	40		@
	nop			;3ba7	00		.
	ld hl,l6020h		;3ba8	21 20 60	!   `
	ld h,d			;3bab	62		b
	ld b,c			;3bac	41		A
	ld b,b			;3bad	40		@
	ld b,b			;3bae	40		@
	ld b,b			;3baf	40		@
	ld hl,l6020h		;3bb0	21 20 60	!   `
	ld h,d			;3bb3	62		b
	ld e,c			;3bb4	59		Y
	ld e,b			;3bb5	58		X
l3bb6h:
	ld c,b			;3bb6	48		H
	ld c,b			;3bb7	48		H
	ld l,c			;3bb8	69		i
	jr z,l3c23h		;3bb9	28 68		( h
	ld l,d			;3bbb	6a		j
	ld e,l			;3bbc	5d		]
	ld e,b			;3bbd	58		X
	ld c,b			;3bbe	48		H
	ld c,b			;3bbf	48		H
	ld l,l			;3bc0	6d		m
	ld l,h			;3bc1	6c		l
	ld l,h			;3bc2	6c		l
	ld l,(hl)		;3bc3	6e		n
	ld e,a			;3bc4	5f		_
	ld e,h			;3bc5	5c		\
	ld e,h			;3bc6	5c		\
	ld l,l			;3bc7	6d		m
	ld l,l			;3bc8	6d		m
	ld l,h			;3bc9	6c		l
	ld l,(hl)		;3bca	6e		n
	xor 0dfh		;3bcb	ee df		. .
	ld e,(hl)		;3bcd	5e		^
	ld a,(hl)		;3bce	7e		~
	ld l,a			;3bcf	6f		o
	ld l,a			;3bd0	6f		o
	ld l,(hl)		;3bd1	6e		n
	ld l,(hl)		;3bd2	6e		n
	xor 0dfh		;3bd3	ee df		. .
	ld a,(hl)		;3bd5	7e		~
	ld a,(hl)		;3bd6	7e		~
	ld a,a			;3bd7	7f		.
	ld a,a			;3bd8	7f		.
	ld a,(hl)		;3bd9	7e		~
	ld l,(hl)		;3bda	6e		n
	xor 0dfh		;3bdb	ee df		. .
	ld a,(hl)		;3bdd	7e		~
	cp 07fh			;3bde	fe 7f		. .
	ld a,a			;3be0	7f		.
	ld a,(hl)		;3be1	7e		~
	ld l,(hl)		;3be2	6e		n
	xor 0ffh		;3be3	ee ff		. .
	ld a,(hl)		;3be5	7e		~
	cp 0ffh			;3be6	fe ff		. .
	ld a,a			;3be8	7f		.
	cp 06eh			;3be9	fe 6e		. n
	xor 0ffh		;3beb	ee ff		. .
	ld a,(hl)		;3bed	7e		~
	cp 0ffh			;3bee	fe ff		. .
	ld a,a			;3bf0	7f		.
	cp 0eeh			;3bf1	fe ee		. .
	xor 0ffh		;3bf3	ee ff		. .
	ld a,(hl)		;3bf5	7e		~
	cp 0ffh			;3bf6	fe ff		. .
	ld a,a			;3bf8	7f		.
	cp 06eh			;3bf9	fe 6e		. n
	xor 0dfh		;3bfb	ee df		. .
	ld a,(hl)		;3bfd	7e		~
	cp 07fh			;3bfe	fe 7f		. .
	ld a,a			;3c00	7f		.
	ld a,(hl)		;3c01	7e		~
	ld l,(hl)		;3c02	6e		n
	xor 0dfh		;3c03	ee df		. .
	ld e,(hl)		;3c05	5e		^
	cp 06fh			;3c06	fe 6f		. o
	ld l,a			;3c08	6f		o
	ld l,(hl)		;3c09	6e		n
	ld l,(hl)		;3c0a	6e		n
	xor 05fh		;3c0b	ee 5f		. _
	ld e,h			;3c0d	5c		\
	call c,sub_6d6dh	;3c0e	dc 6d 6d	. m m
	ld l,h			;3c11	6c		l
	ld l,(hl)		;3c12	6e		n
	xor 05dh		;3c13	ee 5d		. ]
	ld e,b			;3c15	58		X
	ret z			;3c16	c8		.
	ld c,b			;3c17	48		H
	ld l,l			;3c18	6d		m
l3c19h:
	ld l,h			;3c19	6c		l
	ld l,h			;3c1a	6c		l
	ld l,(hl)		;3c1b	6e		n
	ld e,c			;3c1c	59		Y
	ld e,b			;3c1d	58		X
	ret z			;3c1e	c8		.
	ld c,b			;3c1f	48		H
	ld l,c			;3c20	69		i
	jr z,l3c8bh		;3c21	28 68		( h
l3c23h:
	ld l,d			;3c23	6a		j
	ld b,c			;3c24	41		A
	ld b,b			;3c25	40		@
	ret nz			;3c26	c0		.
	ld b,b			;3c27	40		@
	ld hl,l6020h		;3c28	21 20 60	!   `
	ld h,d			;3c2b	62		b
	ld b,c			;3c2c	41		A
	ld b,b			;3c2d	40		@
	ret nz			;3c2e	c0		.
	nop			;3c2f	00		.
	ld hl,l6020h		;3c30	21 20 60	!   `
	ld h,d			;3c33	62		b
	ld b,c			;3c34	41		A
	ld b,b			;3c35	40		@
	add a,b			;3c36	80		.
	nop			;3c37	00		.
	ld bc,02020h		;3c38	01 20 20	.    
	ld h,d			;3c3b	62		b
	ld b,b			;3c3c	40		@
	nop			;3c3d	00		.
	add a,b			;3c3e	80		.
	nop			;3c3f	00		.
	ld bc,02020h		;3c40	01 20 20	.    
	ld (reset_entry),hl		;3c43	22 00 00	" . .
	add a,b			;3c46	80		.
	nop			;3c47	00		.
	nop			;3c48	00		.
	nop			;3c49	00		.
	jr nz,l3c6eh		;3c4a	20 22		  "
	nop			;3c4c	00		.
	nop			;3c4d	00		.
	add a,b			;3c4e	80		.
	nop			;3c4f	00		.
	nop			;3c50	00		.
	nop			;3c51	00		.
	nop			;3c52	00		.
	jr nz,l3c55h		;3c53	20 00		  .
l3c55h:
	nop			;3c55	00		.
	add a,b			;3c56	80		.
	nop			;3c57	00		.
	nop			;3c58	00		.
	nop			;3c59	00		.
	nop			;3c5a	00		.
	nop			;3c5b	00		.
l3c5ch:
	jr z,l3c69h		;3c5c	28 0b		( .
	nop			;3c5e	00		.
	nop			;3c5f	00		.
	nop			;3c60	00		.
l3c61h:
	jr nc,l3c63h		;3c61	30 00		0 .
l3c63h:
	nop			;3c63	00		.
	nop			;3c64	00		.
	nop			;3c65	00		.
	nop			;3c66	00		.
	nop			;3c67	00		.
	nop			;3c68	00		.
l3c69h:
	jr nc,l3c6bh		;3c69	30 00		0 .
l3c6bh:
	djnz l3c6dh		;3c6b	10 00		. .
l3c6dh:
	nop			;3c6d	00		.
l3c6eh:
	nop			;3c6e	00		.
l3c6fh:
	nop			;3c6f	00		.
	nop			;3c70	00		.
	jr nc,l3c83h		;3c71	30 10		0 .
	djnz l3c75h		;3c73	10 00		. .
l3c75h:
	nop			;3c75	00		.
	nop			;3c76	00		.
	nop			;3c77	00		.
	djnz $-78		;3c78	10 b0		. .
	jr nc,l3ccch		;3c7a	30 50		0 P
	nop			;3c7c	00		.
	nop			;3c7d	00		.
	nop			;3c7e	00		.
	nop			;3c7f	00		.
	sub b			;3c80	90		.
	or b			;3c81	b0		.
	ld (hl),b		;3c82	70		p
l3c83h:
	ld (hl),b		;3c83	70		p
	nop			;3c84	00		.
	nop			;3c85	00		.
	add a,b			;3c86	80		.
	djnz l3c19h		;3c87	10 90		. .
	ret p			;3c89	f0		.
	ld (hl),b		;3c8a	70		p
l3c8bh:
	ld (hl),b		;3c8b	70		p
	jr nz,l3c8eh		;3c8c	20 00		  .
l3c8eh:
	sub b			;3c8e	90		.
	djnz l3c61h		;3c8f	10 d0		. .
	ret p			;3c91	f0		.
	ld (hl),b		;3c92	70		p
	ret p			;3c93	f0		.
	and b			;3c94	a0		.
	nop			;3c95	00		.
	sub b			;3c96	90		.
	ld d,b			;3c97	50		P
	ret nc			;3c98	d0		.
	ret p			;3c99	f0		.
	ld (hl),b		;3c9a	70		p
	ret p			;3c9b	f0		.
	ret po			;3c9c	e0		.
	jr z,l3c6fh		;3c9d	28 d0		( .
	ld d,b			;3c9f	50		P
	ret nc			;3ca0	d0		.
	ret p			;3ca1	f0		.
	ld (hl),b		;3ca2	70		p
	ret m			;3ca3	f8		.
	ret po			;3ca4	e0		.
	ld l,b			;3ca5	68		h
	ret nc			;3ca6	d0		.
	ld d,b			;3ca7	50		P
	ret nc			;3ca8	d0		.
	ret p			;3ca9	f0		.
	ld a,b			;3caa	78		x
	ret m			;3cab	f8		.
	ret po			;3cac	e0		.
	ld l,b			;3cad	68		h
	ret nc			;3cae	d0		.
	ld d,b			;3caf	50		P
	ret nc			;3cb0	d0		.
	ret m			;3cb1	f8		.
	ld a,b			;3cb2	78		x
	ret m			;3cb3	f8		.
	ret po			;3cb4	e0		.
	ld l,b			;3cb5	68		h
	ret nc			;3cb6	d0		.
	ld d,b			;3cb7	50		P
	ret c			;3cb8	d8		.
	ret m			;3cb9	f8		.
	ld a,b			;3cba	78		x
	ret m			;3cbb	f8		.
	ret po			;3cbc	e0		.
	ld l,b			;3cbd	68		h
	out (05ah),a		;3cbe	d3 5a		. Z
	ret c			;3cc0	d8		.
	ret m			;3cc1	f8		.
	ld a,b			;3cc2	78		x
	ret m			;3cc3	f8		.
	ret po			;3cc4	e0		.
	ld l,b			;3cc5	68		h
	in a,(05eh)		;3cc6	db 5e		. ^
	jp c,l78f8h		;3cc8	da f8 78	. . x
	ret m			;3ccb	f8		.
l3ccch:
	ret po			;3ccc	e0		.
	ld l,b			;3ccd	68		h
	rst 18h			;3cce	df		.
	ld e,(hl)		;3ccf	5e		^
	sbc a,0fah		;3cd0	de fa		. .
	ld a,c			;3cd2	79		y
	ret m			;3cd3	f8		.
	ret po			;3cd4	e0		.
	ld l,b			;3cd5	68		h
	rst 18h			;3cd6	df		.
	ld e,(hl)		;3cd7	5e		^
	sbc a,0feh		;3cd8	de fe		. .
	ld a,e			;3cda	7b		{
	ret m			;3cdb	f8		.
	ret po			;3cdc	e0		.
	ld l,h			;3cdd	6c		l
	rst 18h			;3cde	df		.
	ld e,(hl)		;3cdf	5e		^
	sbc a,0ffh		;3ce0	de ff		. .
	ld a,e			;3ce2	7b		{
	jp m,l6ce4h		;3ce3	fa e4 6c	. . l
	rst 18h			;3ce6	df		.
	ld e,(hl)		;3ce7	5e		^
	sbc a,0ffh		;3ce8	de ff		. .
	ld a,e			;3cea	7b		{
	cp 0e6h			;3ceb	fe e6		. .
	ld l,h			;3ced	6c		l
	rst 18h			;3cee	df		.
	ld e,(hl)		;3cef	5e		^
	sbc a,0ffh		;3cf0	de ff		. .
	ld a,a			;3cf2	7f		.
	cp 0e6h			;3cf3	fe e6		. .
	ld l,(hl)		;3cf5	6e		n
	rst 18h			;3cf6	df		.
	ld e,(hl)		;3cf7	5e		^
	sbc a,0ffh		;3cf8	de ff		. .
	ld a,a			;3cfa	7f		.
	cp 0e6h			;3cfb	fe e6		. .
	xor 0dfh		;3cfd	ee df		. .
	ld e,(hl)		;3cff	5e		^
	sbc a,0cfh		;3d00	de cf		. .
	ld a,a			;3d02	7f		.
	cp 0e6h			;3d03	fe e6		. .
	xor 0dfh		;3d05	ee df		. .
	ld e,(hl)		;3d07	5e		^
	sbc a,0cfh		;3d08	de cf		. .
	ld a,a			;3d0a	7f		.
	xor 0e6h		;3d0b	ee e6		. .
	xor 0dfh		;3d0d	ee df		. .
	ld e,(hl)		;3d0f	5e		^
	sbc a,0cfh		;3d10	de cf		. .
	ld l,a			;3d12	6f		o
	xor 0e6h		;3d13	ee e6		. .
	xor 0dfh		;3d15	ee df		. .
	ld e,(hl)		;3d17	5e		^
	adc a,04fh		;3d18	ce 4f		. O
	ld c,a			;3d1a	4f		O
	xor (hl)		;3d1b	ae		.
	and 0eeh		;3d1c	e6 ee		. .
	rst 18h			;3d1e	df		.
	ld e,(hl)		;3d1f	5e		^
	ld c,(hl)		;3d20	4e		N
	ld c,a			;3d21	4f		O
	rrca			;3d22	0f		.
	adc a,(hl)		;3d23	8e		.
	and 0eeh		;3d24	e6 ee		. .
	ld e,a			;3d26	5f		_
	ld c,(hl)		;3d27	4e		N
	ld c,(hl)		;3d28	4e		N
	rrca			;3d29	0f		.
	rrca			;3d2a	0f		.
	adc a,(hl)		;3d2b	8e		.
	add a,0eeh		;3d2c	c6 ee		. .
	ld c,a			;3d2e	4f		O
	ld c,(hl)		;3d2f	4e		N
	ld c,00fh		;3d30	0e 0f		. .
	rrca			;3d32	0f		.
	ld c,046h		;3d33	0e 46		. F
	xor 04fh		;3d35	ee 4f		. O
	ld c,00eh		;3d37	0e 0e		. .
	rrca			;3d39	0f		.
	rrca			;3d3a	0f		.
	ld c,006h		;3d3b	0e 06		. .
	add a,00fh		;3d3d	c6 0f		. .
	ld c,00eh		;3d3f	0e 0e		. .
	rrca			;3d41	0f		.
	rrca			;3d42	0f		.
	ld b,006h		;3d43	06 06		. .
	add a,(hl)		;3d45	86		.
	rrca			;3d46	0f		.
	ld c,00eh		;3d47	0e 0e		. .
	rrca			;3d49	0f		.
	rlca			;3d4a	07		.
	ld b,006h		;3d4b	06 06		. .
	add a,(hl)		;3d4d	86		.
	rrca			;3d4e	0f		.
	ld c,00eh		;3d4f	0e 0e		. .
	rlca			;3d51	07		.
	rlca			;3d52	07		.
	ld b,006h		;3d53	06 06		. .
	add a,(hl)		;3d55	86		.
	rrca			;3d56	0f		.
	ld c,006h		;3d57	0e 06		. .
	rlca			;3d59	07		.
	rlca			;3d5a	07		.
	ld b,006h		;3d5b	06 06		. .
	add a,(hl)		;3d5d	86		.
	inc c			;3d5e	0c		.
	inc b			;3d5f	04		.
	ld b,007h		;3d60	06 07		. .
	rlca			;3d62	07		.
	ld b,006h		;3d63	06 06		. .
	add a,(hl)		;3d65	86		.
	inc b			;3d66	04		.
	nop			;3d67	00		.
	inc b			;3d68	04		.
	rlca			;3d69	07		.
	rlca			;3d6a	07		.
	ld b,006h		;3d6b	06 06		. .
	add a,(hl)		;3d6d	86		.
	nop			;3d6e	00		.
	nop			;3d6f	00		.
	nop			;3d70	00		.
	dec b			;3d71	05		.
	ld b,006h		;3d72	06 06		. .
	ld b,086h		;3d74	06 86		. .
	nop			;3d76	00		.
	nop			;3d77	00		.
	nop			;3d78	00		.
	ld bc,00604h		;3d79	01 04 06	. . .
	ld b,082h		;3d7c	06 82		. .
	nop			;3d7e	00		.
	nop			;3d7f	00		.
	nop			;3d80	00		.
	nop			;3d81	00		.
	inc b			;3d82	04		.
	inc b			;3d83	04		.
	ld (bc),a		;3d84	02		.
	add a,d			;3d85	82		.
	nop			;3d86	00		.
	nop			;3d87	00		.
	nop			;3d88	00		.
	nop			;3d89	00		.
	inc b			;3d8a	04		.
	nop			;3d8b	00		.
	nop			;3d8c	00		.
	add a,d			;3d8d	82		.
	nop			;3d8e	00		.
	nop			;3d8f	00		.
	nop			;3d90	00		.
	nop			;3d91	00		.
	nop			;3d92	00		.
	nop			;3d93	00		.
	nop			;3d94	00		.
	add a,b			;3d95	80		.
	nop			;3d96	00		.
	nop			;3d97	00		.
	nop			;3d98	00		.
	nop			;3d99	00		.
	nop			;3d9a	00		.
	nop			;3d9b	00		.
	nop			;3d9c	00		.
	nop			;3d9d	00		.
l3d9eh:
	ld (l100bh),hl		;3d9e	22 0b 10	" . .
	nop			;3da1	00		.
	djnz l3db4h		;3da2	10 10		. .
	nop			;3da4	00		.
	nop			;3da5	00		.
	nop			;3da6	00		.
	ld b,b			;3da7	40		@
	djnz l3daah		;3da8	10 00		. .
l3daah:
	djnz $+18		;3daa	10 10		. .
	nop			;3dac	00		.
	djnz l3dafh		;3dad	10 00		. .
l3dafh:
	ld c,b			;3daf	48		H
	djnz l3db2h		;3db0	10 00		. .
l3db2h:
	djnz $+18		;3db2	10 10		. .
l3db4h:
	djnz $+18		;3db4	10 10		. .
	ex af,af		;3db6	08		.
	ld c,b			;3db7	48		H
	ld de,sub_0ffeh+2	;3db8	11 00 10	. . .
	djnz l3dcdh		;3dbb	10 10		. .
	jr l3dc7h		;3dbd	18 08		. .
	ld c,b			;3dbf	48		H
	ld de,sub_0ffeh+2	;3dc0	11 00 10	. . .
	djnz l3dddh		;3dc3	10 18		. .
	jr l3dcfh		;3dc5	18 08		. .
l3dc7h:
	ld c,b			;3dc7	48		H
	ld de,sub_0ffeh+2	;3dc8	11 00 10	. . .
	jr $+27			;3dcb	18 19		. .
l3dcdh:
	jr l3dd7h		;3dcd	18 08		. .
l3dcfh:
	ld c,b			;3dcf	48		H
	ld de,l1800h		;3dd0	11 00 18	. . .
	jr $+27			;3dd3	18 19		. .
	jr l3ddfh		;3dd5	18 08		. .
l3dd7h:
	ld c,b			;3dd7	48		H
	sub c			;3dd8	91		.
	ex af,af		;3dd9	08		.
	jr l3df4h		;3dda	18 18		. .
	add hl,de		;3ddc	19		.
l3dddh:
	jr l3de7h		;3ddd	18 08		. .
l3ddfh:
	ld c,d			;3ddf	4a		J
	sbc a,c			;3de0	99		.
	ex af,af		;3de1	08		.
	jr l3dfch		;3de2	18 18		. .
	add hl,de		;3de4	19		.
	jr l3defh		;3de5	18 08		. .
l3de7h:
	ld c,d			;3de7	4a		J
	sbc a,a			;3de8	9f		.
	ex af,af		;3de9	08		.
	sbc a,b			;3dea	98		.
	jr l3e06h		;3deb	18 19		. .
	jr l3df7h		;3ded	18 08		. .
l3defh:
	ld c,d			;3def	4a		J
	sbc a,a			;3df0	9f		.
	inc c			;3df1	0c		.
	sbc a,b			;3df2	98		.
	sbc a,b			;3df3	98		.
l3df4h:
	add hl,de		;3df4	19		.
	jr l3dffh		;3df5	18 08		. .
l3df7h:
	ld c,(hl)		;3df7	4e		N
	sbc a,a			;3df8	9f		.
	ld c,09ch		;3df9	0e 9c		. .
	sbc a,b			;3dfb	98		.
l3dfch:
	add hl,de		;3dfc	19		.
	jr l3e0bh		;3dfd	18 0c		. .
l3dffh:
	ld c,(hl)		;3dff	4e		N
	sbc a,a			;3e00	9f		.
	ld c,09eh		;3e01	0e 9e		. .
	sbc a,h			;3e03	9c		.
	add hl,de		;3e04	19		.
	inc e			;3e05	1c		.
;  XREF: 2 refs from 0x1431, 0x2989
l3e06h:
	inc c			;3e06	0c		.
	ld c,(hl)		;3e07	4e		N
	sbc a,a			;3e08	9f		.
	ld c,09eh		;3e09	0e 9e		. .
l3e0bh:
	sbc a,a			;3e0b	9f		.
	dec e			;3e0c	1d		.
	sbc a,h			;3e0d	9c		.
	inc c			;3e0e	0c		.
	ld c,(hl)		;3e0f	4e		N
	sbc a,a			;3e10	9f		.
	ld c,09eh		;3e11	0e 9e		. .
	sbc a,a			;3e13	9f		.
	rra			;3e14	1f		.
	sbc a,h			;3e15	9c		.
	ld c,04eh		;3e16	0e 4e		. N
	sbc a,a			;3e18	9f		.
	ld c,09eh		;3e19	0e 9e		. .
	sbc a,a			;3e1b	9f		.
	rra			;3e1c	1f		.
	sbc a,(hl)		;3e1d	9e		.
	adc a,(hl)		;3e1e	8e		.
	ld c,(hl)		;3e1f	4e		N
	sbc a,a			;3e20	9f		.
	ld c,09eh		;3e21	0e 9e		. .
	sbc a,a			;3e23	9f		.
	rra			;3e24	1f		.
	sbc a,(hl)		;3e25	9e		.
	adc a,(hl)		;3e26	8e		.
	adc a,08fh		;3e27	ce 8f		. .
	ld c,08eh		;3e29	0e 8e		. .
	adc a,a			;3e2b	8f		.
	rra			;3e2c	1f		.
	sbc a,(hl)		;3e2d	9e		.
	adc a,(hl)		;3e2e	8e		.
	adc a,(hl)		;3e2f	8e		.
	adc a,a			;3e30	8f		.
	ld c,08eh		;3e31	0e 8e		. .
	adc a,a			;3e33	8f		.
	rra			;3e34	1f		.
	adc a,(hl)		;3e35	8e		.
	adc a,(hl)		;3e36	8e		.
	add a,(hl)		;3e37	86		.
	adc a,a			;3e38	8f		.
	ld c,08eh		;3e39	0e 8e		. .
	adc a,a			;3e3b	8f		.
	rrca			;3e3c	0f		.
	adc a,(hl)		;3e3d	8e		.
	add a,(hl)		;3e3e	86		.
	add a,(hl)		;3e3f	86		.
	adc a,(hl)		;3e40	8e		.
	ld c,08eh		;3e41	0e 8e		. .
	adc a,a			;3e43	8f		.
	rrca			;3e44	0f		.
	add a,(hl)		;3e45	86		.
	add a,(hl)		;3e46	86		.
	add a,(hl)		;3e47	86		.
	adc a,(hl)		;3e48	8e		.
	ld c,08eh		;3e49	0e 8e		. .
	adc a,a			;3e4b	8f		.
	rlca			;3e4c	07		.
	add a,(hl)		;3e4d	86		.
	add a,(hl)		;3e4e	86		.
	add a,(hl)		;3e4f	86		.
	adc a,(hl)		;3e50	8e		.
	ld c,08eh		;3e51	0e 8e		. .
	add a,a			;3e53	87		.
	ld b,086h		;3e54	06 86		. .
	add a,(hl)		;3e56	86		.
	add a,(hl)		;3e57	86		.
	adc a,(hl)		;3e58	8e		.
	ld c,086h		;3e59	0e 86		. .
	add a,a			;3e5b	87		.
	ld b,086h		;3e5c	06 86		. .
	add a,(hl)		;3e5e	86		.
	add a,(hl)		;3e5f	86		.
	ld c,006h		;3e60	0e 06		. .
	add a,(hl)		;3e62	86		.
	add a,a			;3e63	87		.
	ld b,086h		;3e64	06 86		. .
	add a,(hl)		;3e66	86		.
	add a,h			;3e67	84		.
	ld b,006h		;3e68	06 06		. .
	add a,(hl)		;3e6a	86		.
	add a,a			;3e6b	87		.
	ld b,086h		;3e6c	06 86		. .
	add a,(hl)		;3e6e	86		.
	add a,h			;3e6f	84		.
	nop			;3e70	00		.
	ld b,006h		;3e71	06 06		. .
	add a,a			;3e73	87		.
	ld b,086h		;3e74	06 86		. .
	add a,(hl)		;3e76	86		.
	add a,h			;3e77	84		.
	nop			;3e78	00		.
	ld (bc),a		;3e79	02		.
	ld b,007h		;3e7a	06 07		. .
	ld b,086h		;3e7c	06 86		. .
	add a,(hl)		;3e7e	86		.
	add a,b			;3e7f	80		.
	nop			;3e80	00		.
	nop			;3e81	00		.
	ld (bc),a		;3e82	02		.
	rlca			;3e83	07		.
	ld b,086h		;3e84	06 86		. .
	add a,d			;3e86	82		.
	add a,b			;3e87	80		.
	nop			;3e88	00		.
	nop			;3e89	00		.
	nop			;3e8a	00		.
	inc bc			;3e8b	03		.
	ld b,082h		;3e8c	06 82		. .
	add a,d			;3e8e	82		.
	add a,b			;3e8f	80		.
	nop			;3e90	00		.
	nop			;3e91	00		.
	nop			;3e92	00		.
	nop			;3e93	00		.
	ld (bc),a		;3e94	02		.
	ld (bc),a		;3e95	02		.
	add a,d			;3e96	82		.
	add a,b			;3e97	80		.
	nop			;3e98	00		.
	nop			;3e99	00		.
	nop			;3e9a	00		.
	nop			;3e9b	00		.
	nop			;3e9c	00		.
	ld (bc),a		;3e9d	02		.
	add a,b			;3e9e	80		.
	add a,b			;3e9f	80		.
	nop			;3ea0	00		.
	nop			;3ea1	00		.
	nop			;3ea2	00		.
	nop			;3ea3	00		.
	nop			;3ea4	00		.
	nop			;3ea5	00		.
	nop			;3ea6	00		.
	add a,b			;3ea7	80		.
	nop			;3ea8	00		.
	nop			;3ea9	00		.
	nop			;3eaa	00		.
	nop			;3eab	00		.
	nop			;3eac	00		.
	nop			;3ead	00		.
	nop			;3eae	00		.
	nop			;3eaf	00		.
l3eb0h:
	rlca			;3eb0	07		.
	ld h,b			;3eb1	60		`
	nop			;3eb2	00		.
	nop			;3eb3	00		.
	nop			;3eb4	00		.
	nop			;3eb5	00		.
	nop			;3eb6	00		.
	nop			;3eb7	00		.
	nop			;3eb8	00		.
	nop			;3eb9	00		.
	rst 38h			;3eba	ff		.
	rst 38h			;3ebb	ff		.
	rst 38h			;3ebc	ff		.
	rst 38h			;3ebd	ff		.
sub_3ebeh:
	rst 38h			;3ebe	ff		.
	rst 38h			;3ebf	ff		.
	rst 38h			;3ec0	ff		.
	rst 38h			;3ec1	ff		.
	nop			;3ec2	00		.
	nop			;3ec3	00		.
	nop			;3ec4	00		.
	nop			;3ec5	00		.
	nop			;3ec6	00		.
	nop			;3ec7	00		.
	nop			;3ec8	00		.
	nop			;3ec9	00		.
	rst 38h			;3eca	ff		.
	rst 38h			;3ecb	ff		.
	rst 38h			;3ecc	ff		.
	rst 38h			;3ecd	ff		.
	rst 38h			;3ece	ff		.
	rst 38h			;3ecf	ff		.
	rst 38h			;3ed0	ff		.
	rst 38h			;3ed1	ff		.
	nop			;3ed2	00		.
	nop			;3ed3	00		.
	nop			;3ed4	00		.
	nop			;3ed5	00		.
	nop			;3ed6	00		.
	nop			;3ed7	00		.
	nop			;3ed8	00		.
	nop			;3ed9	00		.
	rst 38h			;3eda	ff		.
	rst 38h			;3edb	ff		.
l3edch:
	rst 38h			;3edc	ff		.
	rst 38h			;3edd	ff		.
	rst 38h			;3ede	ff		.
	rst 38h			;3edf	ff		.
	rst 38h			;3ee0	ff		.
	rst 38h			;3ee1	ff		.
	nop			;3ee2	00		.
	nop			;3ee3	00		.
	nop			;3ee4	00		.
	nop			;3ee5	00		.
	nop			;3ee6	00		.
	nop			;3ee7	00		.
	nop			;3ee8	00		.
	nop			;3ee9	00		.
l3eeah:
	ld h,d			;3eea	62		b
	ld a,b			;3eeb	78		x
	add a,b			;3eec	80		.
	add hl,hl		;3eed	29		)
	nop			;3eee	00		.
	inc b			;3eef	04		.
	ld (bc),a		;3ef0	02		.
	nop			;3ef1	00		.
	nop			;3ef2	00		.
l3ef3h:
	ex af,af		;3ef3	08		.
	nop			;3ef4	00		.
	nop			;3ef5	00		.
	and d			;3ef6	a2		.
	nop			;3ef7	00		.
	ld d,c			;3ef8	51		Q
	add a,b			;3ef9	80		.
	nop			;3efa	00		.
	ld bc,l0042h		;3efb	01 42 00	. B .
	ld b,000h		;3efe	06 00		. .
	jr nz,l3f02h		;3f00	20 00		  .
l3f02h:
	add a,h			;3f02	84		.
	nop			;3f03	00		.
	sub b			;3f04	90		.
	jr nc,l3f0bh		;3f05	30 04		0 .
	ld b,b			;3f07	40		@
	nop			;3f08	00		.
	ld b,000h		;3f09	06 00		. .
l3f0bh:
	nop			;3f0b	00		.
	nop			;3f0c	00		.
	nop			;3f0d	00		.
	jr nz,$+10		;3f0e	20 08		  .
	nop			;3f10	00		.
	ex af,af		;3f11	08		.
	jr c,l3f14h		;3f12	38 00		8 .
l3f14h:
	inc b			;3f14	04		.
	ld (bc),a		;3f15	02		.
	ld (00808h),hl		;3f16	22 08 08	" . .
	nop			;3f19	00		.
	nop			;3f1a	00		.
	nop			;3f1b	00		.
	ret z			;3f1c	c8		.
	jr nz,l3f23h		;3f1d	20 04		  .
	add a,d			;3f1f	82		.
	ld (bc),a		;3f20	02		.
	nop			;3f21	00		.
	nop			;3f22	00		.
l3f23h:
	nop			;3f23	00		.
	nop			;3f24	00		.
	ld b,b			;3f25	40		@
	nop			;3f26	00		.
	and b			;3f27	a0		.
	add a,b			;3f28	80		.
	add a,b			;3f29	80		.
	inc c			;3f2a	0c		.
	nop			;3f2b	00		.
	inc c			;3f2c	0c		.
	call nz,main_init		;3f2d	c4 00 04	. . .  ; → main_init
	nop			;3f30	00		.
	ld bc,00010h		;3f31	01 10 00	. . .
	add a,b			;3f34	80		.
	jr nz,l3f37h		;3f35	20 00		  .
l3f37h:
	ex af,af		;3f37	08		.
	inc b			;3f38	04		.
	ld (bc),a		;3f39	02		.
	jr nc,l3f3eh		;3f3a	30 02		0 .
	inc b			;3f3c	04		.
	nop			;3f3d	00		.
l3f3eh:
	jr nz,l3f41h		;3f3e	20 01		  .
	ld a,(bc)		;3f40	0a		.
l3f41h:
	add a,b			;3f41	80		.
	nop			;3f42	00		.
	ld (bc),a		;3f43	02		.
	jr nz,l3f88h		;3f44	20 42		  B
	djnz $+4		;3f46	10 02		. .
	ld bc,08000h		;3f48	01 00 80	. . .
	nop			;3f4b	00		.
	ld c,d			;3f4c	4a		J
	inc b			;3f4d	04		.
	ld (bc),a		;3f4e	02		.
	nop			;3f4f	00		.
	djnz l3f72h		;3f50	10 20		.  
	jr nz,l3f54h		;3f52	20 00		  .
l3f54h:
	ld (bc),a		;3f54	02		.
	nop			;3f55	00		.
	ld b,h			;3f56	44		D
	jr nz,l3f59h		;3f57	20 00		  .
l3f59h:
	jr nz,l3edch		;3f59	20 81		  .
	nop			;3f5b	00		.
	jr l3f60h		;3f5c	18 02		. .
	ld b,h			;3f5e	44		D
	ld (bc),a		;3f5f	02		.
l3f60h:
	nop			;3f60	00		.
	ld (bc),a		;3f61	02		.
	nop			;3f62	00		.
	ld bc,sound_ctrl_init		;3f63	01 00 01	. . .
	ld b,h			;3f66	44		D
	ld c,b			;3f67	48		H
	nop			;3f68	00		.
	add a,b			;3f69	80		.
	inc c			;3f6a	0c		.
	nop			;3f6b	00		.
	ld (bc),a		;3f6c	02		.
	add a,b			;3f6d	80		.
	add a,b			;3f6e	80		.
	ld (bc),a		;3f6f	02		.
	add a,b			;3f70	80		.
	ld b,h			;3f71	44		D
l3f72h:
	ld (bc),a		;3f72	02		.
	nop			;3f73	00		.
	nop			;3f74	00		.
	ld (bc),a		;3f75	02		.
	add a,b			;3f76	80		.
	jr z,l3f79h		;3f77	28 00		( .
l3f79h:
	ld (bc),a		;3f79	02		.
	jr nc,l3f7ch		;3f7a	30 00		0 .
l3f7ch:
	jr nz,l3f7eh		;3f7c	20 00		  .
l3f7eh:
	ld h,d			;3f7e	62		b
	djnz l3fc1h		;3f7f	10 40		. @
	dec b			;3f81	05		.
	nop			;3f82	00		.
	nop			;3f83	00		.
	nop			;3f84	00		.
	jr nc,l3f99h		;3f85	30 12		0 .
	nop			;3f87	00		.
l3f88h:
	add a,b			;3f88	80		.
	ld (bc),a		;3f89	02		.
	jr nz,l3f8ch		;3f8a	20 00		  .
l3f8ch:
	ld (bc),a		;3f8c	02		.
	nop			;3f8d	00		.
	ld b,h			;3f8e	44		D
	ld (bc),a		;3f8f	02		.
	inc b			;3f90	04		.
	inc b			;3f91	04		.
	dec b			;3f92	05		.
	nop			;3f93	00		.
	nop			;3f94	00		.
	inc b			;3f95	04		.
	nop			;3f96	00		.
	ld c,024h		;3f97	0e 24		. $
l3f99h:
	nop			;3f99	00		.
	jr nz,l3f9dh		;3f9a	20 01		  .
	nop			;3f9c	00		.
l3f9dh:
	ld b,b			;3f9d	40		@
	inc bc			;3f9e	03		.
	djnz l3fa1h		;3f9f	10 00		. .
l3fa1h:
	ld b,b			;3fa1	40		@
	ld e,b			;3fa2	58		X
	nop			;3fa3	00		.
	inc b			;3fa4	04		.
	ex af,af		;3fa5	08		.
	inc b			;3fa6	04		.
	nop			;3fa7	00		.
	ld b,c			;3fa8	41		A
	jr nz,l3fabh		;3fa9	20 00		  .
l3fabh:
	inc bc			;3fab	03		.
	add a,b			;3fac	80		.
	ld c,b			;3fad	48		H
	ld bc,l0802h		;3fae	01 02 08	. . .
	nop			;3fb1	00		.
	sub b			;3fb2	90		.
	nop			;3fb3	00		.
	ld b,b			;3fb4	40		@
	nop			;3fb5	00		.
	ld b,h			;3fb6	44		D
	ld bc,01205h		;3fb7	01 05 12	. . .
	nop			;3fba	00		.
	nop			;3fbb	00		.
	ex af,af		;3fbc	08		.
	ld b,b			;3fbd	40		@
	ld b,b			;3fbe	40		@
	dec b			;3fbf	05		.
	nop			;3fc0	00		.
l3fc1h:
	nop			;3fc1	00		.
	ld b,d			;3fc2	42		B
	ld (bc),a		;3fc3	02		.
	nop			;3fc4	00		.
	djnz $+66		;3fc5	10 40		. @
	ld (sub_0ffeh+2),hl	;3fc7	22 00 10	" . .
	add a,b			;3fca	80		.
	ld (bc),a		;3fcb	02		.
	nop			;3fcc	00		.
	nop			;3fcd	00		.
	ld a,(bc)		;3fce	0a		.
	ex af,af		;3fcf	08		.
	ld (de),a		;3fd0	12		.
	and b			;3fd1	a0		.
	jr nz,l3fd4h		;3fd2	20 00		  .
l3fd4h:
	nop			;3fd4	00		.
	nop			;3fd5	00		.
	ld c,b			;3fd6	48		H
	nop			;3fd7	00		.
	jr nz,l3fdfh		;3fd8	20 05		  .
	sub b			;3fda	90		.
	nop			;3fdb	00		.
	nop			;3fdc	00		.
	inc b			;3fdd	04		.
	ex af,af		;3fde	08		.
l3fdfh:
	add a,d			;3fdf	82		.
	xor b			;3fe0	a8		.
	ld b,b			;3fe1	40		@
	nop			;3fe2	00		.
	nop			;3fe3	00		.
	ld d,b			;3fe4	50		P
	ld h,b			;3fe5	60		`
	ld b,b			;3fe6	40		@
	jr nz,l3fe9h		;3fe7	20 00		  .
l3fe9h:
	nop			;3fe9	00		.
	ld b,b			;3fea	40		@
	nop			;3feb	00		.
	ld b,b			;3fec	40		@
	ld b,008h		;3fed	06 08		. .
	ld bc,l0002h		;3fef	01 02 00	. . .
	jr nc,l3ff4h		;3ff2	30 00		0 .
l3ff4h:
	ld b,b			;3ff4	40		@
	add a,h			;3ff5	84		.
	nop			;3ff6	00		.
	nop			;3ff7	00		.
	nop			;3ff8	00		.
	ld c,b			;3ff9	48		H
	inc b			;3ffa	04		.
	ld (bc),a		;3ffb	02		.
	nop			;3ffc	00		.
	ret nz			;3ffd	c0		.
	inc (hl)		;3ffe	34		4
	ld hl,reset_entry		;3fff	21 00 00	! . .
	nop			;4002	00		.
	inc b			;4003	04		.
	ld (bc),a		;4004	02		.
	ld bc,l0043h		;4005	01 43 00	. C .
	ld bc,sound_ctrl_init		;4008	01 00 01	. . .
	ld (bc),a		;400b	02		.
	nop			;400c	00		.
	ex af,af		;400d	08		.
	add a,h			;400e	84		.
	ld bc,l0002h+1		;400f	01 03 00	. . .
	jr z,l4014h		;4012	28 00		( .
l4014h:
	nop			;4014	00		.
	add a,c			;4015	81		.
	nop			;4016	00		.
	ld b,c			;4017	41		A
	nop			;4018	00		.
	inc bc			;4019	03		.
	inc b			;401a	04		.
	nop			;401b	00		.
	ld b,b			;401c	40		@
	ld e,l			;401d	5d		]
	nop			;401e	00		.
	ld b,b			;401f	40		@
l4020h:
	djnz l4022h		;4020	10 00		. .
l4022h:
	nop			;4022	00		.
	nop			;4023	00		.
	nop			;4024	00		.
	ld b,h			;4025	44		D
	nop			;4026	00		.
	nop			;4027	00		.
	ret nz			;4028	c0		.
	jr nz,$+114		;4029	20 70		  p
	nop			;402b	00		.
	ex af,af		;402c	08		.
	ld (bc),a		;402d	02		.
	nop			;402e	00		.
	ld c,b			;402f	48		H
l4030h:
	and d			;4030	a2		.
	nop			;4031	00		.
	nop			;4032	00		.
	nop			;4033	00		.
	inc h			;4034	24		$
	ld b,b			;4035	40		@
	nop			;4036	00		.
	ex af,af		;4037	08		.
	djnz l407ah		;4038	10 40		. @
	jr nz,l4044h		;403a	20 08		  .
	ld (de),a		;403c	12		.
	nop			;403d	00		.
	ld b,h			;403e	44		D
	ld b,c			;403f	41		A
l4040h:
	djnz l4042h		;4040	10 00		. .
l4042h:
	nop			;4042	00		.
	nop			;4043	00		.
l4044h:
	nop			;4044	00		.
	dec b			;4045	05		.
	jr nz,l4068h		;4046	20 20		   
	ld (bc),a		;4048	02		.
	ld b,d			;4049	42		B
	nop			;404a	00		.
	ex af,af		;404b	08		.
	nop			;404c	00		.
	jr nz,l404fh		;404d	20 00		  .
l404fh:
	jr nz,l4071h		;404f	20 20		   
	jr z,l4073h		;4051	28 20		(  
	ld b,044h		;4053	06 44		. D
	ld b,d			;4055	42		B
	nop			;4056	00		.
	djnz l4059h		;4057	10 00		. .
l4059h:
	nop			;4059	00		.
	and b			;405a	a0		.
	nop			;405b	00		.
	inc b			;405c	04		.
	inc b			;405d	04		.
	ld bc,00008h		;405e	01 08 00	. . .
	ld b,b			;4061	40		@
	add a,b			;4062	80		.
	inc c			;4063	0c		.
	add a,b			;4064	80		.
	inc h			;4065	24		$
	ld b,b			;4066	40		@
	ld b,c			;4067	41		A
l4068h:
	ld b,b			;4068	40		@
	ex af,af		;4069	08		.
	nop			;406a	00		.
	nop			;406b	00		.
	sub b			;406c	90		.
	nop			;406d	00		.
	ld b,001h		;406e	06 01		. .
	nop			;4070	00		.
l4071h:
	ld (bc),a		;4071	02		.
	ex af,af		;4072	08		.
l4073h:
	ex af,af		;4073	08		.
	nop			;4074	00		.
	ld h,(hl)		;4075	66		f
	nop			;4076	00		.
	nop			;4077	00		.
	ex af,af		;4078	08		.
	inc b			;4079	04		.
l407ah:
	ld b,c			;407a	41		A
	nop			;407b	00		.
	jr l409eh		;407c	18 20		.  
	nop			;407e	00		.
	ld b,b			;407f	40		@
	ld (bc),a		;4080	02		.
	sub b			;4081	90		.
	nop			;4082	00		.
	nop			;4083	00		.
	nop			;4084	00		.
	nop			;4085	00		.
	jr z,l4089h		;4086	28 01		( .
	nop			;4088	00		.
l4089h:
	nop			;4089	00		.
	ld c,004h		;408a	0e 04		. .
	nop			;408c	00		.
	ld b,h			;408d	44		D
	nop			;408e	00		.
	ex af,af		;408f	08		.
	ex af,af		;4090	08		.
	djnz l409eh		;4091	10 0b		. .
	nop			;4093	00		.
	nop			;4094	00		.
	djnz $+38		;4095	10 24		. $
	ld bc,l0004h		;4097	01 04 00	. . .
	djnz l40a4h		;409a	10 08		. .
	ld (bc),a		;409c	02		.
	ld (de),a		;409d	12		.
l409eh:
	ld b,b			;409e	40		@
	ld (bc),a		;409f	02		.
	jr nz,l40a4h		;40a0	20 02		  .
	nop			;40a2	00		.
	inc b			;40a3	04		.
l40a4h:
	ld (bc),a		;40a4	02		.
	ex af,af		;40a5	08		.
	inc bc			;40a6	03		.
	nop			;40a7	00		.
l40a8h:
	nop			;40a8	00		.
	inc b			;40a9	04		.
	add a,b			;40aa	80		.
	ld (bc),a		;40ab	02		.
	ld (bc),a		;40ac	02		.
	inc b			;40ad	04		.
	ex af,af		;40ae	08		.
	ld bc,l0018h		;40af	01 18 00	. . .
l40b2h:
	jr nz,$+6		;40b2	20 04		  .
	ld b,b			;40b4	40		@
	add a,c			;40b5	81		.
	ld (bc),a		;40b6	02		.
	djnz l40b9h		;40b7	10 00		. .
l40b9h:
	ld (bc),a		;40b9	02		.
	jr nz,l40bch		;40ba	20 00		  .
l40bch:
	adc a,b			;40bc	88		.
	ld bc,reset_entry		;40bd	01 00 00	. . .
l40c0h:
	nop			;40c0	00		.
	ex af,af		;40c1	08		.
	inc a			;40c2	3c		<
	nop			;40c3	00		.
	nop			;40c4	00		.
	ld bc,02104h		;40c5	01 04 21	. . !
	nop			;40c8	00		.
	jr nz,l40dch		;40c9	20 11		  .
	inc b			;40cb	04		.
	nop			;40cc	00		.
	inc b			;40cd	04		.
	nop			;40ce	00		.
	jr z,l40e2h		;40cf	28 11		( .
	add a,b			;40d1	80		.
	add a,b			;40d2	80		.
	nop			;40d3	00		.
	inc b			;40d4	04		.
	nop			;40d5	00		.
	nop			;40d6	00		.
	ld de,08148h		;40d7	11 48 81	. H .
	djnz l40dch		;40da	10 00		. .
l40dch:
	add a,b			;40dc	80		.
	nop			;40dd	00		.
	inc h			;40de	24		$
	nop			;40df	00		.
	ld h,b			;40e0	60		`
	nop			;40e1	00		.
l40e2h:
	jr l40e4h		;40e2	18 00		. .
l40e4h:
	ex af,af		;40e4	08		.
	ld (bc),a		;40e5	02		.
	inc b			;40e6	04		.
	nop			;40e7	00		.
	add a,b			;40e8	80		.
	ld b,b			;40e9	40		@
	ld (de),a		;40ea	12		.
	ld (bc),a		;40eb	02		.
	add a,b			;40ec	80		.
	djnz l412fh		;40ed	10 40		. @
	inc b			;40ef	04		.
	ex af,af		;40f0	08		.
	inc c			;40f1	0c		.
	nop			;40f2	00		.
	ld (bc),a		;40f3	02		.
	djnz $+4		;40f4	10 02		. .
	nop			;40f6	00		.
	ld hl,03000h		;40f7	21 00 30	! . 0
	ld b,b			;40fa	40		@
	ex af,af		;40fb	08		.
	sbc a,b			;40fc	98		.
	add a,b			;40fd	80		.
	nop			;40fe	00		.
	add a,h			;40ff	84		.
	nop			;4100	00		.
	jr nz,l4105h		;4101	20 02		  .
	nop			;4103	00		.
	ld (bc),a		;4104	02		.
l4105h:
	ld (bc),a		;4105	02		.
	nop			;4106	00		.
	inc b			;4107	04		.
	inc bc			;4108	03		.
	nop			;4109	00		.
	ret nz			;410a	c0		.
	nop			;410b	00		.
	djnz $-122		;410c	10 84		. .
	ex af,af		;410e	08		.
	inc c			;410f	0c		.
	inc b			;4110	04		.
	nop			;4111	00		.
	ex af,af		;4112	08		.
	nop			;4113	00		.
	nop			;4114	00		.
	nop			;4115	00		.
	ld h,b			;4116	60		`
	ld b,b			;4117	40		@
l4118h:
	inc bc			;4118	03		.
	and h			;4119	a4		.
	nop			;411a	00		.
	nop			;411b	00		.
	nop			;411c	00		.
	inc b			;411d	04		.
	inc h			;411e	24		$
	ex af,af		;411f	08		.
	nop			;4120	00		.
	ld b,b			;4121	40		@
	ld (bc),a		;4122	02		.
	ex af,af		;4123	08		.
	inc c			;4124	0c		.
	jr nz,l40a8h		;4125	20 81		  .
	nop			;4127	00		.
	djnz l412ah		;4128	10 00		. .
l412ah:
	nop			;412a	00		.
	nop			;412b	00		.
	inc b			;412c	04		.
	ex af,af		;412d	08		.
	ld b,h			;412e	44		D
l412fh:
	ex af,af		;412f	08		.
	djnz l40b2h		;4130	10 80		. .
	inc b			;4132	04		.
	nop			;4133	00		.
	djnz l4146h		;4134	10 10		. .
	nop			;4136	00		.
	and d			;4137	a2		.
	ld b,004h		;4138	06 04		. .
	nop			;413a	00		.
	nop			;413b	00		.
	ld d,b			;413c	50		P
	ld bc,l0041h		;413d	01 41 00	. A .
	nop			;4140	00		.
	inc b			;4141	04		.
	nop			;4142	00		.
	dec b			;4143	05		.
	nop			;4144	00		.
	ld b,d			;4145	42		B
l4146h:
	adc a,b			;4146	88		.
	jr nc,l4149h		;4147	30 00		0 .
l4149h:
	ld b,b			;4149	40		@
	djnz l414ch		;414a	10 00		. .
l414ch:
	nop			;414c	00		.
	ld b,b			;414d	40		@
	ld b,b			;414e	40		@
	add a,b			;414f	80		.
	djnz l4162h		;4150	10 10		. .
	jp nz,0a000h		;4152	c2 00 a0	. . .
	nop			;4155	00		.
	nop			;4156	00		.
	jr l415bh		;4157	18 02		. .
	ld c,b			;4159	48		H
	add a,b			;415a	80		.
l415bh:
	nop			;415b	00		.
	nop			;415c	00		.
	nop			;415d	00		.
	ld (bc),a		;415e	02		.
	add a,b			;415f	80		.
	ex af,af		;4160	08		.
	nop			;4161	00		.
l4162h:
	inc de			;4162	13		.
	ex af,af		;4163	08		.
	ld b,b			;4164	40		@
	ld b,b			;4165	40		@
l4166h:
	nop			;4166	00		.
	add a,b			;4167	80		.
	djnz l4196h		;4168	10 2c		. ,
	ld (bc),a		;416a	02		.
	nop			;416b	00		.
	nop			;416c	00		.
	ld (00800h),a		;416d	32 00 08	2 . .
	nop			;4170	00		.
	ld (bc),a		;4171	02		.
	ex af,af		;4172	08		.
	inc b			;4173	04		.
	nop			;4174	00		.
	ld b,b			;4175	40		@
	ld c,b			;4176	48		H
	ld b,b			;4177	40		@
	jr l4186h		;4178	18 0c		. .
	nop			;417a	00		.
	nop			;417b	00		.
	nop			;417c	00		.
	ld b,b			;417d	40		@
	djnz l41c9h		;417e	10 49		. I
	ld (bc),a		;4180	02		.
	nop			;4181	00		.
	nop			;4182	00		.
	inc c			;4183	0c		.
	inc b			;4184	04		.
	ex af,af		;4185	08		.
l4186h:
	ld bc,sub_0ffeh+2	;4186	01 00 10	. . .
	ld (de),a		;4189	12		.
	djnz l418ch		;418a	10 00		. .
l418ch:
	ld a,(bc)		;418c	0a		.
	nop			;418d	00		.
	ld b,b			;418e	40		@
	inc b			;418f	04		.
	add a,d			;4190	82		.
	nop			;4191	00		.
	add a,b			;4192	80		.
	nop			;4193	00		.
	djnz l4118h		;4194	10 82		. .
l4196h:
	ex af,af		;4196	08		.
	ld bc,l0005h		;4197	01 05 00	. . .
	nop			;419a	00		.
	ld bc,08024h		;419b	01 24 80	. $ .
	nop			;419e	00		.
	ld bc,l0c00h		;419f	01 00 0c	. . .
	nop			;41a2	00		.
	dec b			;41a3	05		.
	nop			;41a4	00		.
	djnz l41a7h		;41a5	10 00		. .
l41a7h:
	jr nz,l41a9h		;41a7	20 00		  .
l41a9h:
	adc a,d			;41a9	8a		.
	ex af,af		;41aa	08		.
	ld (bc),a		;41ab	02		.
	add a,b			;41ac	80		.
	inc d			;41ad	14		.
	jr nz,l4210h		;41ae	20 60		  `
	jr nz,l41b6h		;41b0	20 04		  .
	nop			;41b2	00		.
	nop			;41b3	00		.
	djnz l41d6h		;41b4	10 20		.  
l41b6h:
	jr nz,l41b8h		;41b6	20 00		  .
l41b8h:
	jr nc,$+18		;41b8	30 10		0 .
	jr l41bch		;41ba	18 00		. .
l41bch:
	jr nz,l41c8h		;41bc	20 0a		  .
	jr nz,l41c1h		;41be	20 01		  .
	nop			;41c0	00		.
l41c1h:
	djnz l41cbh		;41c1	10 08		. .
	nop			;41c3	00		.
	ld b,b			;41c4	40		@
	add a,b			;41c5	80		.
	nop			;41c6	00		.
	rla			;41c7	17		.
l41c8h:
	nop			;41c8	00		.
l41c9h:
	djnz l41cbh		;41c9	10 00		. .
l41cbh:
	ld (bc),a		;41cb	02		.
	ld (de),a		;41cc	12		.
	jr nz,l41cfh		;41cd	20 00		  .
l41cfh:
	nop			;41cf	00		.
	inc b			;41d0	04		.
	ld de,l0080h		;41d1	11 80 00	. . .
	inc b			;41d4	04		.
	ld b,c			;41d5	41		A
l41d6h:
	ld (bc),a		;41d6	02		.
	ld (bc),a		;41d7	02		.
	ex af,af		;41d8	08		.
	jr z,l41dbh		;41d9	28 00		( .
l41dbh:
	nop			;41db	00		.
	nop			;41dc	00		.
	ld bc,00416h		;41dd	01 16 04	. . .
	ld bc,l4040h		;41e0	01 40 40	. @ @
	nop			;41e3	00		.
	djnz l4166h		;41e4	10 80		. .
	djnz l41e8h		;41e6	10 00		. .
l41e8h:
	nop			;41e8	00		.
	ld h,b			;41e9	60		`
	add a,h			;41ea	84		.
	nop			;41eb	00		.
	adc a,b			;41ec	88		.
	ld b,b			;41ed	40		@
	nop			;41ee	00		.
	ld b,000h		;41ef	06 00		. .
	add a,b			;41f1	80		.
	ld bc,02402h		;41f2	01 02 24	. . $
	nop			;41f5	00		.
	jr nz,l4238h		;41f6	20 40		  @
	ld b,c			;41f8	41		A
	ld (bc),a		;41f9	02		.
	nop			;41fa	00		.
	nop			;41fb	00		.
l41fch:
	ld h,h			;41fc	64		d
	ld h,h			;41fd	64		d
	inc b			;41fe	04		.
	jr l4201h		;41ff	18 00		. .
l4201h:
	djnz l4203h		;4201	10 00		. .
l4203h:
	add hl,hl		;4203	29		)
l4204h:
	ex af,af		;4204	08		.
	nop			;4205	00		.
l4206h:
	ld b,b			;4206	40		@
	nop			;4207	00		.
	nop			;4208	00		.
	ld (de),a		;4209	12		.
	nop			;420a	00		.
	add hl,hl		;420b	29		)
	nop			;420c	00		.
	inc bc			;420d	03		.
	add a,b			;420e	80		.
	nop			;420f	00		.
l4210h:
	inc b			;4210	04		.
	nop			;4211	00		.
	ret nz			;4212	c0		.
	jr nz,l4217h		;4213	20 02		  .
	inc b			;4215	04		.
	nop			;4216	00		.
l4217h:
	add a,b			;4217	80		.
	nop			;4218	00		.
	ld a,(bc)		;4219	0a		.
	inc b			;421a	04		.
	jr nz,l4225h		;421b	20 08		  .
	add hl,bc		;421d	09		.
	nop			;421e	00		.
	ld hl,l0040h		;421f	21 40 00	! @ .
	add a,c			;4222	81		.
	inc b			;4223	04		.
	and b			;4224	a0		.
l4225h:
	nop			;4225	00		.
	and b			;4226	a0		.
	jr nz,l4269h		;4227	20 40		  @
	nop			;4229	00		.
	ld d,b			;422a	50		P
	inc c			;422b	0c		.
	nop			;422c	00		.
	nop			;422d	00		.
	ld h,b			;422e	60		`
	dec c			;422f	0d		.
	ld c,b			;4230	48		H
	nop			;4231	00		.
	nop			;4232	00		.
	nop			;4233	00		.
	add a,b			;4234	80		.
	nop			;4235	00		.
	nop			;4236	00		.
	ld d,b			;4237	50		P
l4238h:
	nop			;4238	00		.
	ld (bc),a		;4239	02		.
	jr nz,$+7		;423a	20 05		  .
	inc c			;423c	0c		.
	nop			;423d	00		.
	ld b,010h		;423e	06 10		. .
	jr l4242h		;4240	18 00		. .
l4242h:
	ld bc,reset_entry		;4242	01 00 00	. . .
	ld (bc),a		;4245	02		.
	ld (bc),a		;4246	02		.
	nop			;4247	00		.
	ret nz			;4248	c0		.
	jr nz,l4264h		;4249	20 19		  .
	nop			;424b	00		.
	inc b			;424c	04		.
	nop			;424d	00		.
	ld b,b			;424e	40		@
	nop			;424f	00		.
	add a,d			;4250	82		.
	inc b			;4251	04		.
	ld (bc),a		;4252	02		.
	djnz $+26		;4253	10 18		. .
	nop			;4255	00		.
	ld b,b			;4256	40		@
	nop			;4257	00		.
	ex af,af		;4258	08		.
	ld bc,l0030h		;4259	01 30 00	. 0 .
	ld b,b			;425c	40		@
	inc c			;425d	0c		.
	nop			;425e	00		.
	inc b			;425f	04		.
	nop			;4260	00		.
	ld b,b			;4261	40		@
	jr nz,l4206h		;4262	20 a2		  .
l4264h:
	ex af,af		;4264	08		.
	inc b			;4265	04		.
	ld (l40c0h),hl		;4266	22 c0 40	" . @
l4269h:
	nop			;4269	00		.
	inc b			;426a	04		.
	ld (reset_entry),hl		;426b	22 00 00	" . .
	ld b,h			;426e	44		D
	djnz l4279h		;426f	10 08		. .
	nop			;4271	00		.
	nop			;4272	00		.
	ld (de),a		;4273	12		.
	ld b,c			;4274	41		A
	nop			;4275	00		.
	nop			;4276	00		.
	djnz l4279h		;4277	10 00		. .
l4279h:
	nop			;4279	00		.
	ld e,c			;427a	59		Y
	djnz l42adh		;427b	10 30		. 0
	nop			;427d	00		.
	jr nz,$+20		;427e	20 12		  .
	nop			;4280	00		.
	add a,h			;4281	84		.
	djnz l4204h		;4282	10 80		. .
	nop			;4284	00		.
	nop			;4285	00		.
	jr nz,l429ch		;4286	20 14		  .
	jr nz,l428ah		;4288	20 00		  .
l428ah:
	ld (de),a		;428a	12		.
	add a,b			;428b	80		.
	ld (bc),a		;428c	02		.
	nop			;428d	00		.
	jr nc,l42a2h		;428e	30 12		0 .
	nop			;4290	00		.
	jr nz,l4293h		;4291	20 00		  .
l4293h:
	ld bc,l0202h		;4293	01 02 02	. . .
	add a,b			;4296	80		.
	nop			;4297	00		.
	ld (l0802h),hl		;4298	22 02 08	" . .
	nop			;429b	00		.
l429ch:
	jr l429eh		;429c	18 00		. .
l429eh:
	nop			;429e	00		.
	nop			;429f	00		.
	ex af,af		;42a0	08		.
	nop			;42a1	00		.
l42a2h:
	and b			;42a2	a0		.
	dec b			;42a3	05		.
	jr z,l42a6h		;42a4	28 00		( .
l42a6h:
	nop			;42a6	00		.
	nop			;42a7	00		.
	add a,b			;42a8	80		.
	inc de			;42a9	13		.
	sub b			;42aa	90		.
	jr nz,l42adh		;42ab	20 00		  .
l42adh:
	nop			;42ad	00		.
	ld b,b			;42ae	40		@
	ex af,af		;42af	08		.
	nop			;42b0	00		.
	inc bc			;42b1	03		.
	add a,b			;42b2	80		.
	ld (bc),a		;42b3	02		.
	nop			;42b4	00		.
	add hl,bc		;42b5	09		.
	jr nz,$+10		;42b6	20 08		  .
	add a,b			;42b8	80		.
	nop			;42b9	00		.
	dec l			;42ba	2d		-
	nop			;42bb	00		.
	inc b			;42bc	04		.
	nop			;42bd	00		.
	nop			;42be	00		.
	ld bc,l0200h		;42bf	01 00 02	. . .
	nop			;42c2	00		.
	jr z,l42d1h		;42c3	28 0c		( .
	ex af,af		;42c5	08		.
	nop			;42c6	00		.
	add a,d			;42c7	82		.
	nop			;42c8	00		.
	and b			;42c9	a0		.
	ld b,b			;42ca	40		@
	nop			;42cb	00		.
	jr nz,$+12		;42cc	20 0a		  .
	ex af,af		;42ce	08		.
	nop			;42cf	00		.
	ld b,h			;42d0	44		D
l42d1h:
	djnz l42d4h		;42d1	10 01		. .
	inc bc			;42d3	03		.
l42d4h:
	ld b,b			;42d4	40		@
	nop			;42d5	00		.
	nop			;42d6	00		.
	jr nz,l4312h		;42d7	20 39		  9
	ld d,b			;42d9	50		P
	nop			;42da	00		.
	nop			;42db	00		.
	nop			;42dc	00		.
	inc b			;42dd	04		.
	ex af,af		;42de	08		.
	ld (bc),a		;42df	02		.
	ld bc,sub_0ffeh+2	;42e0	01 00 10	. . .
	nop			;42e3	00		.
	jr nz,l42ech		;42e4	20 06		  .
	nop			;42e6	00		.
	inc d			;42e7	14		.
	ex af,af		;42e8	08		.
	jr c,l42ebh		;42e9	38 00		8 .
l42ebh:
	inc b			;42eb	04		.
l42ech:
	jr nz,l42eeh		;42ec	20 00		  .
l42eeh:
	ex af,af		;42ee	08		.
	nop			;42ef	00		.
	ld bc,main_init		;42f0	01 00 04	. . .
	nop			;42f3	00		.
	inc h			;42f4	24		$
	ld a,(bc)		;42f5	0a		.
	nop			;42f6	00		.
	nop			;42f7	00		.
	djnz l432ah		;42f8	10 30		. 0
	nop			;42fa	00		.
	nop			;42fb	00		.
	ld b,e			;42fc	43		C
	ld bc,02800h		;42fd	01 00 28	. . (
	jr nz,$+22		;4300	20 14		  .
	nop			;4302	00		.
	add a,b			;4303	80		.
	ld b,b			;4304	40		@
	nop			;4305	00		.
	ld (l0004h),a		;4306	32 04 00	2 . .
	nop			;4309	00		.
	ld bc,l0048h		;430a	01 48 00	. H .
	nop			;430d	00		.
	nop			;430e	00		.
	ex af,af		;430f	08		.
	djnz l42a2h		;4310	10 90		. .
l4312h:
	inc b			;4312	04		.
	ex af,af		;4313	08		.
	ld bc,l0401h		;4314	01 01 04	. . .
	ld (bc),a		;4317	02		.
	ld hl,(reset_entry)		;4318	2a 00 00	* . .
	add a,b			;431b	80		.
	dec b			;431c	05		.
	nop			;431d	00		.
	nop			;431e	00		.
	nop			;431f	00		.
	nop			;4320	00		.
	ret po			;4321	e0		.
	add a,l			;4322	85		.
l4323h:
	ld bc,l0040h		;4323	01 40 00	. @ .
	or d			;4326	b2		.
	ld bc,reset_entry		;4327	01 00 00	. . .
l432ah:
	nop			;432a	00		.
	ld b,c			;432b	41		A
	nop			;432c	00		.
	ld (bc),a		;432d	02		.
	ld (bc),a		;432e	02		.
	ld b,b			;432f	40		@
	nop			;4330	00		.
	nop			;4331	00		.
	ld c,h			;4332	4c		L
l4333h:
	jr nz,l434dh		;4333	20 18		  .
	nop			;4335	00		.
	nop			;4336	00		.
	djnz l4341h		;4337	10 08		. .
	nop			;4339	00		.
	ld b,e			;433a	43		C
	ex af,af		;433b	08		.
	jr nz,l433eh		;433c	20 00		  .
l433eh:
	nop			;433e	00		.
	dec d			;433f	15		.
	ld a,(bc)		;4340	0a		.
l4341h:
	nop			;4341	00		.
	ld (bc),a		;4342	02		.
	djnz l4345h		;4343	10 00		. .
l4345h:
	nop			;4345	00		.
	nop			;4346	00		.
	nop			;4347	00		.
	ld b,e			;4348	43		C
	ld (de),a		;4349	12		.
	nop			;434a	00		.
	ld (bc),a		;434b	02		.
	ld b,b			;434c	40		@
l434dh:
	nop			;434d	00		.
	djnz l43b4h		;434e	10 64		. d
	nop			;4350	00		.
	ld b,010h		;4351	06 10		. .
	inc b			;4353	04		.
	nop			;4354	00		.
	nop			;4355	00		.
	nop			;4356	00		.
	nop			;4357	00		.
	ld (bc),a		;4358	02		.
	ld b,b			;4359	40		@
	adc a,b			;435a	88		.
	ld (bc),a		;435b	02		.
	inc bc			;435c	03		.
	nop			;435d	00		.
	nop			;435e	00		.
	inc d			;435f	14		.
	djnz l4362h		;4360	10 00		. .
l4362h:
	ex af,af		;4362	08		.
	ld b,b			;4363	40		@
	jr nc,l4366h		;4364	30 00		0 .
l4366h:
	djnz l4368h		;4366	10 00		. .
l4368h:
	inc b			;4368	04		.
	ld c,b			;4369	48		H
	ld (bc),a		;436a	02		.
	sub b			;436b	90		.
	add a,b			;436c	80		.
	nop			;436d	00		.
	and b			;436e	a0		.
	ld b,b			;436f	40		@
	nop			;4370	00		.
	nop			;4371	00		.
	ld b,040h		;4372	06 40		. @
	nop			;4374	00		.
	ex af,af		;4375	08		.
	nop			;4376	00		.
	nop			;4377	00		.
	inc h			;4378	24		$
	ld b,b			;4379	40		@
	nop			;437a	00		.
	djnz l43c5h		;437b	10 48		. H
	ld bc,04000h		;437d	01 00 40	. . @
	dec c			;4380	0d		.
	ld de,l0201h		;4381	11 01 02	. . .
	nop			;4384	00		.
	nop			;4385	00		.
	nop			;4386	00		.
	rlca			;4387	07		.
	nop			;4388	00		.
	ld b,b			;4389	40		@
	ld bc,l0051h		;438a	01 51 00	. Q .
	nop			;438d	00		.
	jr l4390h		;438e	18 00		. .
l4390h:
	ex af,af		;4390	08		.
	jr nz,l4323h		;4391	20 90		  .
	djnz l439dh		;4393	10 08		. .
	nop			;4395	00		.
	jr nz,l43a2h		;4396	20 0a		  .
	nop			;4398	00		.
	jr z,l43abh		;4399	28 10		( .
	add a,b			;439b	80		.
	inc b			;439c	04		.
l439dh:
	nop			;439d	00		.
	djnz l43a0h		;439e	10 00		. .
l43a0h:
	ld a,(bc)		;43a0	0a		.
	ex af,af		;43a1	08		.
l43a2h:
	nop			;43a2	00		.
	nop			;43a3	00		.
	ld d,b			;43a4	50		P
	ld (bc),a		;43a5	02		.
	adc a,b			;43a6	88		.
	ld (bc),a		;43a7	02		.
	nop			;43a8	00		.
	nop			;43a9	00		.
	pop bc			;43aa	c1		.
l43abh:
	djnz l43edh		;43ab	10 40		. @
	nop			;43ad	00		.
	nop			;43ae	00		.
	inc bc			;43af	03		.
	jr nz,l4333h		;43b0	20 81		  .
	ld b,h			;43b2	44		D
	ld b,b			;43b3	40		@
l43b4h:
	nop			;43b4	00		.
	nop			;43b5	00		.
	inc d			;43b6	14		.
	nop			;43b7	00		.
	nop			;43b8	00		.
	adc a,b			;43b9	88		.
	djnz $-62		;43ba	10 c0		. .
	inc b			;43bc	04		.
	nop			;43bd	00		.
	nop			;43be	00		.
	jr nz,l43c5h		;43bf	20 04		  .
	dec b			;43c1	05		.
	nop			;43c2	00		.
	djnz l43cfh		;43c3	10 0a		. .
l43c5h:
	nop			;43c5	00		.
	ld (bc),a		;43c6	02		.
	ld bc,04000h		;43c7	01 00 40	. . @
	ld hl,(00408h)		;43ca	2a 08 04	* . .
	nop			;43cd	00		.
	nop			;43ce	00		.
l43cfh:
	ld c,b			;43cf	48		H
	nop			;43d0	00		.
	nop			;43d1	00		.
	jr nz,l43d5h		;43d2	20 01		  .
	inc b			;43d4	04		.
l43d5h:
	ld (bc),a		;43d5	02		.
	nop			;43d6	00		.
	ld b,b			;43d7	40		@
	nop			;43d8	00		.
	inc b			;43d9	04		.
	ld bc,l0320h		;43da	01 20 03	.   .
	inc bc			;43dd	03		.
	add a,b			;43de	80		.
	ex af,af		;43df	08		.
	ld c,b			;43e0	48		H
	nop			;43e1	00		.
	jr nz,l43e4h		;43e2	20 00		  .
l43e4h:
	ld b,h			;43e4	44		D
	nop			;43e5	00		.
	add a,b			;43e6	80		.
	nop			;43e7	00		.
	nop			;43e8	00		.
	ld (bc),a		;43e9	02		.
	ld (de),a		;43ea	12		.
	ex af,af		;43eb	08		.
	ld d,d			;43ec	52		R
l43edh:
	nop			;43ed	00		.
	nop			;43ee	00		.
	inc b			;43ef	04		.
	inc b			;43f0	04		.
	add a,b			;43f1	80		.
	nop			;43f2	00		.
	nop			;43f3	00		.
	ld hl,(l0004h)		;43f4	2a 04 00	* . .
	adc a,h			;43f7	8c		.
	djnz l43fah		;43f8	10 00		. .
l43fah:
	nop			;43fa	00		.
	ld bc,send_sound_cmd		;43fb	01 44 01	. D .
	ld b,h			;43fe	44		D
	ld a,(bc)		;43ff	0a		.
	nop			;4400	00		.
	nop			;4401	00		.
	nop			;4402	00		.
	nop			;4403	00		.
	ld c,c			;4404	49		I
	nop			;4405	00		.
	inc b			;4406	04		.
	nop			;4407	00		.
	add a,b			;4408	80		.
	sbc a,c			;4409	99		.
	nop			;440a	00		.
	nop			;440b	00		.
	nop			;440c	00		.
	ex af,af		;440d	08		.
	ld d,h			;440e	54		T
	jr nz,l4411h		;440f	20 00		  .
l4411h:
	nop			;4411	00		.
	ex af,af		;4412	08		.
	ld b,b			;4413	40		@
l4414h:
	nop			;4414	00		.
	ld (bc),a		;4415	02		.
	djnz l4420h		;4416	10 08		. .
	nop			;4418	00		.
	djnz l443bh		;4419	10 20		.  
	ld h,b			;441b	60		`
	ld bc,00800h		;441c	01 00 08	. . .
	nop			;441f	00		.
l4420h:
	sbc a,b			;4420	98		.
	nop			;4421	00		.
	nop			;4422	00		.
	nop			;4423	00		.
	jr l442ah		;4424	18 04		. .
	jr z,l442ch		;4426	28 04		( .
	inc d			;4428	14		.
	nop			;4429	00		.
l442ah:
	nop			;442a	00		.
	nop			;442b	00		.
l442ch:
	ld d,b			;442c	50		P
	nop			;442d	00		.
	nop			;442e	00		.
	nop			;442f	00		.
	and b			;4430	a0		.
	ld b,c			;4431	41		A
	djnz l4434h		;4432	10 00		. .
l4434h:
	ex af,af		;4434	08		.
	nop			;4435	00		.
	ld b,d			;4436	42		B
	nop			;4437	00		.
	ex af,af		;4438	08		.
	ld (bc),a		;4439	02		.
	ld b,h			;443a	44		D
l443bh:
	nop			;443b	00		.
	nop			;443c	00		.
	ld bc,reset_entry		;443d	01 00 00	. . .
	nop			;4440	00		.
	nop			;4441	00		.
	or b			;4442	b0		.
	add a,b			;4443	80		.
	ld h,d			;4444	62		b
	nop			;4445	00		.
	ex af,af		;4446	08		.
	nop			;4447	00		.
	ld bc,l0050h		;4448	01 50 00	. P .
	inc h			;444b	24		$
	djnz l4450h		;444c	10 02		. .
	ret po			;444e	e0		.
	nop			;444f	00		.
l4450h:
	sub b			;4450	90		.
	inc b			;4451	04		.
	nop			;4452	00		.
	ld bc,00010h		;4453	01 10 00	. . .
	djnz $+6		;4456	10 04		. .
	nop			;4458	00		.
	ld c,c			;4459	49		I
	ld b,b			;445a	40		@
	jr nz,l445dh		;445b	20 00		  .
l445dh:
	ex af,af		;445d	08		.
	ld e,d			;445e	5a		Z
	ld (bc),a		;445f	02		.
	ld bc,reset_entry		;4460	01 00 00	. . .
	djnz l4467h		;4463	10 02		. .
	nop			;4465	00		.
	ld (bc),a		;4466	02		.
l4467h:
	add a,b			;4467	80		.
	nop			;4468	00		.
	inc b			;4469	04		.
	inc bc			;446a	03		.
	nop			;446b	00		.
	add hl,bc		;446c	09		.
	inc b			;446d	04		.
	ld (de),a		;446e	12		.
	nop			;446f	00		.
	nop			;4470	00		.
	dec h			;4471	25		%
	nop			;4472	00		.
	djnz $+20		;4473	10 12		. .
	nop			;4475	00		.
	ex af,af		;4476	08		.
	nop			;4477	00		.
	ld (bc),a		;4478	02		.
	ld b,h			;4479	44		D
	inc b			;447a	04		.
	ld (l0001h),hl		;447b	22 01 00	" . .
	djnz l4492h		;447e	10 12		. .
	jr nz,l448ch		;4480	20 0a		  .
	add a,b			;4482	80		.
	add a,b			;4483	80		.
	nop			;4484	00		.
	nop			;4485	00		.
	jr nz,l4492h		;4486	20 0a		  .
	inc b			;4488	04		.
l4489h:
	ld bc,00801h		;4489	01 01 08	. . .
l448ch:
	nop			;448c	00		.
	nop			;448d	00		.
	add a,d			;448e	82		.
	nop			;448f	00		.
	ex af,af		;4490	08		.
	add a,d			;4491	82		.
l4492h:
	jr nz,l4414h		;4492	20 80		  .
	nop			;4494	00		.
	nop			;4495	00		.
	djnz $+66		;4496	10 40		. @
	nop			;4498	00		.
	jr nz,l44dbh		;4499	20 40		  @
	inc b			;449b	04		.
	nop			;449c	00		.
	inc bc			;449d	03		.
	ret nz			;449e	c0		.
	nop			;449f	00		.
	ld (bc),a		;44a0	02		.
	ld b,c			;44a1	41		A
	jr z,l44a4h		;44a2	28 00		( .
l44a4h:
	ld b,b			;44a4	40		@
	nop			;44a5	00		.
	nop			;44a6	00		.
	nop			;44a7	00		.
	ld (bc),a		;44a8	02		.
	djnz l44cbh		;44a9	10 20		.  
	jr nc,$+6		;44ab	30 04		0 .
	ex af,af		;44ad	08		.
	add a,h			;44ae	84		.
l44afh:
	nop			;44af	00		.
	ld (08000h),hl		;44b0	22 00 80	" . .
	ld (bc),a		;44b3	02		.
	ld de,main_init		;44b4	11 00 04	. . .
	inc b			;44b7	04		.
	sbc a,b			;44b8	98		.
	ld bc,reset_entry		;44b9	01 00 00	. . .
	nop			;44bc	00		.
	add hl,bc		;44bd	09		.
	nop			;44be	00		.
	nop			;44bf	00		.
	inc b			;44c0	04		.
	ld hl,(00700h)		;44c1	2a 00 07	* . .
	ld b,b			;44c4	40		@
	nop			;44c5	00		.
	ex af,af		;44c6	08		.
	add a,b			;44c7	80		.
	ld (bc),a		;44c8	02		.
	nop			;44c9	00		.
	inc bc			;44ca	03		.
l44cbh:
	djnz l44d5h		;44cb	10 08		. .
	nop			;44cd	00		.
	add a,b			;44ce	80		.
	jr nz,l4511h		;44cf	20 40		  @
	ld bc,l0002h		;44d1	01 02 00	. . .
	ld b,h			;44d4	44		D
l44d5h:
	ex af,af		;44d5	08		.
	ld b,b			;44d6	40		@
	ld (l0052h),hl		;44d7	22 52 00	" R .
	nop			;44da	00		.
l44dbh:
	nop			;44db	00		.
	inc b			;44dc	04		.
	nop			;44dd	00		.
	inc b			;44de	04		.
	inc b			;44df	04		.
	inc b			;44e0	04		.
	jr nz,l44e3h		;44e1	20 00		  .
l44e3h:
	djnz l4525h		;44e3	10 40		. @
	inc b			;44e5	04		.
	djnz $+34		;44e6	10 20		.  
	ld bc,l0080h		;44e8	01 80 00	. . .
	sub b			;44eb	90		.
	ld b,b			;44ec	40		@
	ld bc,l4020h		;44ed	01 20 40	.   @
	jr nz,l4502h		;44f0	20 10		  .
	ld b,h			;44f2	44		D
	nop			;44f3	00		.
	inc c			;44f4	0c		.
	nop			;44f5	00		.
	adc a,d			;44f6	8a		.
	nop			;44f7	00		.
	ld hl,main_init		;44f8	21 00 04	! . .
	ex af,af		;44fb	08		.
	add a,b			;44fc	80		.
	nop			;44fd	00		.
	inc h			;44fe	24		$
	nop			;44ff	00		.
	ld (bc),a		;4500	02		.
	add a,b			;4501	80		.
l4502h:
	nop			;4502	00		.
	ld a,(bc)		;4503	0a		.
	and b			;4504	a0		.
	nop			;4505	00		.
	inc d			;4506	14		.
	jr nz,l4489h		;4507	20 80		  .
	nop			;4509	00		.
	nop			;450a	00		.
	djnz l455dh		;450b	10 50		. P
	inc b			;450d	04		.
	nop			;450e	00		.
	nop			;450f	00		.
	inc b			;4510	04		.
l4511h:
	ex af,af		;4511	08		.
	nop			;4512	00		.
	call nz,sub_0280h	;4513	c4 80 02	. . .
	nop			;4516	00		.
	jr nz,l4519h		;4517	20 00		  .
l4519h:
	ld bc,08003h		;4519	01 03 80	. . .
	add a,h			;451c	84		.
	ld bc,l38c8h		;451d	01 c8 38	. . 8
	add a,b			;4520	80		.
	add a,b			;4521	80		.
	nop			;4522	00		.
	nop			;4523	00		.
	ex af,af		;4524	08		.
l4525h:
	djnz l44afh		;4525	10 88		. .
	nop			;4527	00		.
	inc b			;4528	04		.
	nop			;4529	00		.
	ex af,af		;452a	08		.
	ld bc,l3040h		;452b	01 40 30	. @ 0
	ex af,af		;452e	08		.
	inc b			;452f	04		.
	ld (bc),a		;4530	02		.
	jr nz,l4533h		;4531	20 00		  .
l4533h:
	ex af,af		;4533	08		.
	add a,h			;4534	84		.
	jr nz,l4537h		;4535	20 00		  .
l4537h:
	ex af,af		;4537	08		.
	ld (de),a		;4538	12		.
	ld hl,l0040h		;4539	21 40 00	! @ .
	nop			;453c	00		.
	ld b,000h		;453d	06 00		. .
	inc b			;453f	04		.
	ld b,b			;4540	40		@
	nop			;4541	00		.
	ld b,b			;4542	40		@
	nop			;4543	00		.
	nop			;4544	00		.
	jr z,$+4		;4545	28 02		( .
	add hl,bc		;4547	09		.
	jr nz,l455ch		;4548	20 12		  .
	nop			;454a	00		.
	inc b			;454b	04		.
	nop			;454c	00		.
	ld bc,l080ch		;454d	01 0c 08	. . .
	nop			;4550	00		.
	ld bc,main_init		;4551	01 00 04	. . .
	ex af,af		;4554	08		.
	nop			;4555	00		.
	ld h,b			;4556	60		`
	nop			;4557	00		.
	nop			;4558	00		.
	inc b			;4559	04		.
	ld h,b			;455a	60		`
	ld h,b			;455b	60		`
l455ch:
	and b			;455c	a0		.
l455dh:
	nop			;455d	00		.
	nop			;455e	00		.
	ld (bc),a		;455f	02		.
	ex af,af		;4560	08		.
	nop			;4561	00		.
	nop			;4562	00		.
	nop			;4563	00		.
	jr z,l45a6h		;4564	28 40		( @
	ld (de),a		;4566	12		.
	nop			;4567	00		.
	ld (bc),a		;4568	02		.
	ld (bc),a		;4569	02		.
	nop			;456a	00		.
	ex af,af		;456b	08		.
	nop			;456c	00		.
	inc b			;456d	04		.
	add hl,bc		;456e	09		.
	ld bc,l0208h		;456f	01 08 02	. . .
	ld d,b			;4572	50		P
	ld b,b			;4573	40		@
	nop			;4574	00		.
	nop			;4575	00		.
	adc a,b			;4576	88		.
	nop			;4577	00		.
	nop			;4578	00		.
	ld b,b			;4579	40		@
	ret nz			;457a	c0		.
	inc b			;457b	04		.
	add hl,bc		;457c	09		.
	ret nz			;457d	c0		.
	nop			;457e	00		.
	nop			;457f	00		.
	nop			;4580	00		.
	nop			;4581	00		.
	ld b,b			;4582	40		@
	ld (bc),a		;4583	02		.
	inc bc			;4584	03		.
	ld b,b			;4585	40		@
	ld a,(bc)		;4586	0a		.
	ex af,af		;4587	08		.
	jr nz,l458ah		;4588	20 00		  .
l458ah:
	inc h			;458a	24		$
	nop			;458b	00		.
	djnz l45ceh		;458c	10 40		. @
	nop			;458e	00		.
	ld a,(bc)		;458f	0a		.
	djnz l45d2h		;4590	10 40		. @
	ld (bc),a		;4592	02		.
	nop			;4593	00		.
	add a,h			;4594	84		.
	ex af,af		;4595	08		.
	add a,b			;4596	80		.
	nop			;4597	00		.
	nop			;4598	00		.
	ex af,af		;4599	08		.
	ld bc,02002h		;459a	01 02 20	. .  
	nop			;459d	00		.
	jr nz,l45adh		;459e	20 0d		  .
	ld b,b			;45a0	40		@
	inc b			;45a1	04		.
	ld b,b			;45a2	40		@
	inc b			;45a3	04		.
	nop			;45a4	00		.
	add a,d			;45a5	82		.
l45a6h:
	djnz l45a8h		;45a6	10 00		. .
l45a8h:
	djnz l45aah		;45a8	10 00		. .
l45aah:
	ld h,b			;45aa	60		`
	and b			;45ab	a0		.
	nop			;45ac	00		.
l45adh:
	ld b,d			;45ad	42		B
	add a,b			;45ae	80		.
	nop			;45af	00		.
	add a,b			;45b0	80		.
	nop			;45b1	00		.
	ld (hl),c		;45b2	71		q
	nop			;45b3	00		.
	ld (bc),a		;45b4	02		.
	add a,b			;45b5	80		.
	ld bc,l0200h		;45b6	01 00 02	. . .
	nop			;45b9	00		.
	add a,b			;45ba	80		.
	ld (bc),a		;45bb	02		.
	djnz l45cch		;45bc	10 0e		. .
	nop			;45be	00		.
	ld (bc),a		;45bf	02		.
	sub (hl)		;45c0	96		.
	ld (de),a		;45c1	12		.
	ld bc,08000h		;45c2	01 00 80	. . .
	nop			;45c5	00		.
	nop			;45c6	00		.
	nop			;45c7	00		.
	nop			;45c8	00		.
	nop			;45c9	00		.
	nop			;45ca	00		.
	nop			;45cb	00		.
l45cch:
	sbc a,(hl)		;45cc	9e		.
	nop			;45cd	00		.
l45ceh:
	ld de,08800h		;45ce	11 00 88	. . .
	inc h			;45d1	24		$
l45d2h:
	add hl,bc		;45d2	09		.
	inc b			;45d3	04		.
	jr nz,l45d6h		;45d4	20 00		  .
l45d6h:
	nop			;45d6	00		.
	nop			;45d7	00		.
	add a,h			;45d8	84		.
	ld (l0240h),hl		;45d9	22 40 02	" @ .
	nop			;45dc	00		.
	add a,b			;45dd	80		.
	nop			;45de	00		.
	nop			;45df	00		.
	inc h			;45e0	24		$
	nop			;45e1	00		.
	ld hl,00600h		;45e2	21 00 06	! . .
	jr l45e7h		;45e5	18 00		. .
l45e7h:
	nop			;45e7	00		.
	nop			;45e8	00		.
	nop			;45e9	00		.
	ld bc,l6022h		;45ea	01 22 60	. " `
	nop			;45ed	00		.
	ld de,00600h		;45ee	11 00 06	. . .
	nop			;45f1	00		.
	ld bc,l0200h		;45f2	01 00 02	. . .
	ld (bc),a		;45f5	02		.
	ld a,(bc)		;45f6	0a		.
	ex af,af		;45f7	08		.
	ld b,b			;45f8	40		@
	jr nz,$+10		;45f9	20 08		  .
	nop			;45fb	00		.
	adc a,h			;45fc	8c		.
	ld (bc),a		;45fd	02		.
	ld (bc),a		;45fe	02		.
	nop			;45ff	00		.
	inc b			;4600	04		.
	nop			;4601	00		.
	ld bc,l4030h		;4602	01 30 40	. 0 @
	ld d,b			;4605	50		P
	djnz l4608h		;4606	10 00		. .
l4608h:
	ld (08420h),a		;4608	32 20 84	2   .
	ex af,af		;460b	08		.
	nop			;460c	00		.
	nop			;460d	00		.
	inc b			;460e	04		.
	nop			;460f	00		.
	inc b			;4610	04		.
	ld b,h			;4611	44		D
	nop			;4612	00		.
	nop			;4613	00		.
	ld b,l			;4614	45		E
	ld bc,00800h		;4615	01 00 08	. . .
	nop			;4618	00		.
	nop			;4619	00		.
	nop			;461a	00		.
	ld h,d			;461b	62		b
	add a,b			;461c	80		.
	jr z,$+19		;461d	28 11		( .
	nop			;461f	00		.
	nop			;4620	00		.
	ld b,b			;4621	40		@
	ld b,c			;4622	41		A
	ex af,af		;4623	08		.
	jr nz,l4636h		;4624	20 10		  .
	ex af,af		;4626	08		.
	nop			;4627	00		.
	add a,d			;4628	82		.
	ld (bc),a		;4629	02		.
	nop			;462a	00		.
	ld h,b			;462b	60		`
	ld b,000h		;462c	06 00		. .
	ld bc,sub_0ffeh+2	;462e	01 00 10	. . .
	nop			;4631	00		.
	nop			;4632	00		.
	add hl,de		;4633	19		.
	nop			;4634	00		.
	add a,c			;4635	81		.
l4636h:
	nop			;4636	00		.
	inc b			;4637	04		.
	djnz l463ah		;4638	10 00		. .
l463ah:
	ld de,01022h		;463a	11 22 10	. " .
	nop			;463d	00		.
	nop			;463e	00		.
	nop			;463f	00		.
	inc b			;4640	04		.
	add a,b			;4641	80		.
	nop			;4642	00		.
	ld b,b			;4643	40		@
	ld bc,00010h		;4644	01 10 00	. . .
	ld (bc),a		;4647	02		.
	nop			;4648	00		.
	inc d			;4649	14		.
	jr nz,l465dh		;464a	20 11		  .
	nop			;464c	00		.
	nop			;464d	00		.
	sbc a,b			;464e	98		.
	nop			;464f	00		.
	ld b,b			;4650	40		@
	nop			;4651	00		.
	jr nz,l4654h		;4652	20 00		  .
l4654h:
	and b			;4654	a0		.
	ld c,h			;4655	4c		L
	ld b,b			;4656	40		@
	nop			;4657	00		.
	ld b,b			;4658	40		@
	nop			;4659	00		.
	ld bc,reset_entry		;465a	01 00 00	. . .
l465dh:
	ld (hl),h		;465d	74		t
	add a,b			;465e	80		.
	nop			;465f	00		.
	ld h,b			;4660	60		`
	djnz l4667h		;4661	10 04		. .
	nop			;4663	00		.
	ld bc,sound_ctrl_init		;4664	01 00 01	. . .
l4667h:
	ld (bc),a		;4667	02		.
	ld (bc),a		;4668	02		.
	ld c,b			;4669	48		H
	adc a,b			;466a	88		.
	djnz l468dh		;466b	10 20		.  
	ex af,af		;466d	08		.
	nop			;466e	00		.
	nop			;466f	00		.
	nop			;4670	00		.
	nop			;4671	00		.
	nop			;4672	00		.
	nop			;4673	00		.
	nop			;4674	00		.
	nop			;4675	00		.
	nop			;4676	00		.
	nop			;4677	00		.
	rst 38h			;4678	ff		.
	rst 38h			;4679	ff		.
	rst 38h			;467a	ff		.
	rst 38h			;467b	ff		.
	rst 38h			;467c	ff		.
	rst 38h			;467d	ff		.
	rst 38h			;467e	ff		.
	rst 38h			;467f	ff		.
	nop			;4680	00		.
	nop			;4681	00		.
	nop			;4682	00		.
	nop			;4683	00		.
	nop			;4684	00		.
	nop			;4685	00		.
	nop			;4686	00		.
	nop			;4687	00		.
	rst 38h			;4688	ff		.
	rst 38h			;4689	ff		.
	rst 38h			;468a	ff		.
	rst 38h			;468b	ff		.
	rst 38h			;468c	ff		.
l468dh:
	rst 38h			;468d	ff		.
	rst 38h			;468e	ff		.
	rst 38h			;468f	ff		.
	nop			;4690	00		.
	nop			;4691	00		.
	nop			;4692	00		.
	nop			;4693	00		.
	nop			;4694	00		.
	nop			;4695	00		.
	nop			;4696	00		.
	nop			;4697	00		.
	rst 38h			;4698	ff		.
	rst 38h			;4699	ff		.
	rst 38h			;469a	ff		.
	rst 38h			;469b	ff		.
l469ch:
	rst 38h			;469c	ff		.
	rst 38h			;469d	ff		.
	rst 38h			;469e	ff		.
	rst 38h			;469f	ff		.
	nop			;46a0	00		.
	nop			;46a1	00		.
	nop			;46a2	00		.
	nop			;46a3	00		.
	nop			;46a4	00		.
	nop			;46a5	00		.
	nop			;46a6	00		.
	nop			;46a7	00		.
	nop			;46a8	00		.
	adc a,c			;46a9	89		.
	ld (l0001h),hl		;46aa	22 01 00	" . .
	jr nz,l46afh		;46ad	20 00		  .
l46afh:
	nop			;46af	00		.
	add a,b			;46b0	80		.
	nop			;46b1	00		.
	nop			;46b2	00		.
	nop			;46b3	00		.
	ex af,af		;46b4	08		.
	nop			;46b5	00		.
	add a,b			;46b6	80		.
	dec bc			;46b7	0b		.
	ex af,af		;46b8	08		.
	jr nc,l46fbh		;46b9	30 40		0 @
	nop			;46bb	00		.
	inc h			;46bc	24		$
	djnz $+18		;46bd	10 10		. .
	nop			;46bf	00		.
	ld c,b			;46c0	48		H
	ld h,b			;46c1	60		`
	ld (bc),a		;46c2	02		.
	nop			;46c3	00		.
	nop			;46c4	00		.
	add a,c			;46c5	81		.
	ld (bc),a		;46c6	02		.
	nop			;46c7	00		.
	nop			;46c8	00		.
	adc a,b			;46c9	88		.
	nop			;46ca	00		.
	nop			;46cb	00		.
	jr z,l46ceh		;46cc	28 00		( .
l46ceh:
	ld de,00008h		;46ce	11 08 00	. . .
	ex af,af		;46d1	08		.
	djnz l46f4h		;46d2	10 20		.  
	ld h,h			;46d4	64		d
	nop			;46d5	00		.
	ld hl,l0200h		;46d6	21 00 02	! . .
	nop			;46d9	00		.
	add a,h			;46da	84		.
	add a,b			;46db	80		.
	jr nz,l46f2h		;46dc	20 14		  .
	jr nz,l46e0h		;46de	20 00		  .
l46e0h:
	add a,b			;46e0	80		.
	nop			;46e1	00		.
l46e2h:
	jr nz,l46e9h		;46e2	20 05		  .
	nop			;46e4	00		.
	ld b,d			;46e5	42		B
	inc h			;46e6	24		$
	nop			;46e7	00		.
	add a,b			;46e8	80		.
l46e9h:
	inc b			;46e9	04		.
	ld b,(hl)		;46ea	46		F
	add hl,bc		;46eb	09		.
	nop			;46ec	00		.
	nop			;46ed	00		.
	nop			;46ee	00		.
	inc b			;46ef	04		.
	ld (bc),a		;46f0	02		.
	inc bc			;46f1	03		.
l46f2h:
	ld (bc),a		;46f2	02		.
	ld b,b			;46f3	40		@
l46f4h:
	jr nc,l46f6h		;46f4	30 00		0 .
l46f6h:
	nop			;46f6	00		.
	ex af,af		;46f7	08		.
	nop			;46f8	00		.
	ret nz			;46f9	c0		.
	ld d,b			;46fa	50		P
l46fbh:
	nop			;46fb	00		.
	nop			;46fc	00		.
	nop			;46fd	00		.
	adc a,h			;46fe	8c		.
	nop			;46ff	00		.
	inc b			;4700	04		.
	nop			;4701	00		.
	ld hl,l0004h		;4702	21 04 00	! . .
	nop			;4705	00		.
	add a,b			;4706	80		.
	ld bc,l0210h		;4707	01 10 02	. . .
	nop			;470a	00		.
	jr nz,l4711h		;470b	20 04		  .
	ld b,b			;470d	40		@
	inc b			;470e	04		.
	inc b			;470f	04		.
	add a,b			;4710	80		.
l4711h:
	inc b			;4711	04		.
	add a,b			;4712	80		.
	ld bc,02220h		;4713	01 20 22	.   "
	nop			;4716	00		.
	nop			;4717	00		.
	inc b			;4718	04		.
	nop			;4719	00		.
	djnz l469ch		;471a	10 80		. .
	ld (00121h),hl		;471c	22 21 01	" ! .
	nop			;471f	00		.
	nop			;4720	00		.
	nop			;4721	00		.
	ld bc,l0288h		;4722	01 88 02	. . .
	sub b			;4725	90		.
	jr z,l4728h		;4726	28 00		( .
l4728h:
	nop			;4728	00		.
	ld b,b			;4729	40		@
	jr nz,l473ch		;472a	20 10		  .
	adc a,b			;472c	88		.
	ex af,af		;472d	08		.
	add a,b			;472e	80		.
	nop			;472f	00		.
	nop			;4730	00		.
	ld b,b			;4731	40		@
	nop			;4732	00		.
	inc b			;4733	04		.
	inc b			;4734	04		.
	add a,b			;4735	80		.
	ld (bc),a		;4736	02		.
	rlca			;4737	07		.
	ld b,b			;4738	40		@
	ex af,af		;4739	08		.
	add a,b			;473a	80		.
	adc a,b			;473b	88		.
l473ch:
	ld b,b			;473c	40		@
	ld bc,reset_entry		;473d	01 00 00	. . .
	nop			;4740	00		.
	djnz l4753h		;4741	10 10		. .
	jr nc,l4745h		;4743	30 00		0 .
l4745h:
	ld b,h			;4745	44		D
	nop			;4746	00		.
	ld bc,l4030h		;4747	01 30 40	. 0 @
	jr nz,l476ch		;474a	20 20		   
	ld b,b			;474c	40		@
	inc b			;474d	04		.
	jr nz,l4750h		;474e	20 00		  .
l4750h:
	and b			;4750	a0		.
	nop			;4751	00		.
	inc b			;4752	04		.
l4753h:
	djnz l4755h		;4753	10 00		. .
l4755h:
	add hl,bc		;4755	09		.
	djnz l4758h		;4756	10 00		. .
l4758h:
	nop			;4758	00		.
	nop			;4759	00		.
	ret nz			;475a	c0		.
	inc b			;475b	04		.
	ld e,h			;475c	5c		\
	ld b,b			;475d	40		@
	nop			;475e	00		.
	nop			;475f	00		.
	djnz l46e2h		;4760	10 80		. .
	djnz l4788h		;4762	10 24		. $
	ex af,af		;4764	08		.
	nop			;4765	00		.
	ld (de),a		;4766	12		.
	nop			;4767	00		.
	inc h			;4768	24		$
	nop			;4769	00		.
	add a,b			;476a	80		.
	ld b,b			;476b	40		@
l476ch:
	jr nz,l476eh		;476c	20 00		  .
l476eh:
	jr nc,l4771h		;476e	30 01		0 .
	inc b			;4770	04		.
l4771h:
	ld b,b			;4771	40		@
	jr z,l4776h		;4772	28 02		( .
	nop			;4774	00		.
	nop			;4775	00		.
l4776h:
	ld bc,l0002h		;4776	01 02 00	. . .
	sub b			;4779	90		.
	sub b			;477a	90		.
	nop			;477b	00		.
	ld b,b			;477c	40		@
	nop			;477d	00		.
	jr nc,l4780h		;477e	30 00		0 .
l4780h:
	inc e			;4780	1c		.
	nop			;4781	00		.
	ld b,b			;4782	40		@
	ld d,b			;4783	50		P
	ex af,af		;4784	08		.
	ld (bc),a		;4785	02		.
	nop			;4786	00		.
	nop			;4787	00		.
l4788h:
	nop			;4788	00		.
	inc b			;4789	04		.
	nop			;478a	00		.
	djnz l478dh		;478b	10 00		. .
l478dh:
	ret z			;478d	c8		.
	inc b			;478e	04		.
	ld (bc),a		;478f	02		.
	add a,b			;4790	80		.
	nop			;4791	00		.
	ld b,b			;4792	40		@
	ld bc,01140h		;4793	01 40 11	. @ .
	ld (bc),a		;4796	02		.
	nop			;4797	00		.
	nop			;4798	00		.
	inc e			;4799	1c		.
	nop			;479a	00		.
	ld (bc),a		;479b	02		.
	add a,b			;479c	80		.
	ld b,b			;479d	40		@
	nop			;479e	00		.
	inc b			;479f	04		.
	nop			;47a0	00		.
	nop			;47a1	00		.
	jr nz,$+50		;47a2	20 30		  0
	ld de,00808h		;47a4	11 08 08	. . .
	nop			;47a7	00		.
	ld c,b			;47a8	48		H
	and b			;47a9	a0		.
	nop			;47aa	00		.
	djnz l47adh		;47ab	10 00		. .
l47adh:
	nop			;47ad	00		.
	djnz l47b0h		;47ae	10 00		. .
l47b0h:
	jr z,l47b2h		;47b0	28 00		( .
l47b2h:
	ld b,044h		;47b2	06 44		. D
	ld bc,sub_0ffeh+2	;47b4	01 00 10	. . .
	nop			;47b7	00		.
	ld a,(bc)		;47b8	0a		.
	ex af,af		;47b9	08		.
	call nz,l0001h		;47ba	c4 01 00	. . .
	djnz l47bfh		;47bd	10 00		. .
l47bfh:
	nop			;47bf	00		.
	ld h,b			;47c0	60		`
	nop			;47c1	00		.
	ld hl,switch_dispatch_table		;47c2	21 00 20	! .  
	nop			;47c5	00		.
	ld bc,l0409h		;47c6	01 09 04	. . .
	ld b,c			;47c9	41		A
	inc c			;47ca	0c		.
	ld a,(bc)		;47cb	0a		.
	nop			;47cc	00		.
	nop			;47cd	00		.
	ex af,af		;47ce	08		.
l47cfh:
	nop			;47cf	00		.
	nop			;47d0	00		.
	inc b			;47d1	04		.
	ld de,08200h		;47d2	11 00 82	. . .
	inc d			;47d5	14		.
	nop			;47d6	00		.
	inc b			;47d7	04		.
	nop			;47d8	00		.
	ld (bc),a		;47d9	02		.
	ex af,af		;47da	08		.
	ld c,b			;47db	48		H
	nop			;47dc	00		.
	ld b,b			;47dd	40		@
	nop			;47de	00		.
	ld bc,l0004h		;47df	01 04 00	. . .
	dec b			;47e2	05		.
	jr nz,l4829h		;47e3	20 44		  D
	inc b			;47e5	04		.
	nop			;47e6	00		.
	ex af,af		;47e7	08		.
	ld b,b			;47e8	40		@
	ret nz			;47e9	c0		.
	jr nc,l47f0h		;47ea	30 04		0 .
	nop			;47ec	00		.
	ld (bc),a		;47ed	02		.
	nop			;47ee	00		.
	nop			;47ef	00		.
l47f0h:
	ex af,af		;47f0	08		.
	nop			;47f1	00		.
	ex af,af		;47f2	08		.
	ex af,af		;47f3	08		.
	ld b,d			;47f4	42		B
	nop			;47f5	00		.
	djnz l47f8h		;47f6	10 00		. .
l47f8h:
	nop			;47f8	00		.
	nop			;47f9	00		.
	inc d			;47fa	14		.
	ld h,d			;47fb	62		b
	nop			;47fc	00		.
	nop			;47fd	00		.
	sbc a,b			;47fe	98		.
	nop			;47ff	00		.
	nop			;4800	00		.
	nop			;4801	00		.
	nop			;4802	00		.
	nop			;4803	00		.
	nop			;4804	00		.
	nop			;4805	00		.
	nop			;4806	00		.
	nop			;4807	00		.
	rst 38h			;4808	ff		.
	rst 38h			;4809	ff		.
	rst 38h			;480a	ff		.
	rst 38h			;480b	ff		.
	rst 38h			;480c	ff		.
	rst 38h			;480d	ff		.
	rst 38h			;480e	ff		.
	rst 38h			;480f	ff		.
	nop			;4810	00		.
	nop			;4811	00		.
	nop			;4812	00		.
	nop			;4813	00		.
	nop			;4814	00		.
	nop			;4815	00		.
	nop			;4816	00		.
	nop			;4817	00		.
	rst 38h			;4818	ff		.
	rst 38h			;4819	ff		.
	rst 38h			;481a	ff		.
	rst 38h			;481b	ff		.
	rst 38h			;481c	ff		.
	rst 38h			;481d	ff		.
	rst 38h			;481e	ff		.
	rst 38h			;481f	ff		.
	nop			;4820	00		.
	nop			;4821	00		.
	nop			;4822	00		.
	nop			;4823	00		.
	nop			;4824	00		.
	nop			;4825	00		.
	nop			;4826	00		.
	nop			;4827	00		.
	rst 38h			;4828	ff		.
l4829h:
	rst 38h			;4829	ff		.
	rst 38h			;482a	ff		.
	rst 38h			;482b	ff		.
	rst 38h			;482c	ff		.
	rst 38h			;482d	ff		.
	rst 38h			;482e	ff		.
	rst 38h			;482f	ff		.
	nop			;4830	00		.
	nop			;4831	00		.
	nop			;4832	00		.
	nop			;4833	00		.
	nop			;4834	00		.
	nop			;4835	00		.
	nop			;4836	00		.
	nop			;4837	00		.
	ld b,b			;4838	40		@
	ld b,b			;4839	40		@
	add a,b			;483a	80		.
	sub b			;483b	90		.
	nop			;483c	00		.
	ld bc,reset_entry		;483d	01 00 00	. . .
	add a,b			;4840	80		.
	add a,b			;4841	80		.
	nop			;4842	00		.
	nop			;4843	00		.
	ex af,af		;4844	08		.
	djnz l47cfh		;4845	10 88		. .
	nop			;4847	00		.
	inc b			;4848	04		.
	nop			;4849	00		.
	ex af,af		;484a	08		.
	ld bc,l3040h		;484b	01 40 30	. @ 0
	ex af,af		;484e	08		.
	inc b			;484f	04		.
	ld (bc),a		;4850	02		.
	jr nz,l4853h		;4851	20 00		  .
l4853h:
	ex af,af		;4853	08		.
	add a,h			;4854	84		.
	jr nz,l4857h		;4855	20 00		  .
l4857h:
	ex af,af		;4857	08		.
	ld (de),a		;4858	12		.
	ld hl,l0040h		;4859	21 40 00	! @ .
	nop			;485c	00		.
	ld b,000h		;485d	06 00		. .
	inc b			;485f	04		.
	ld b,b			;4860	40		@
	nop			;4861	00		.
	ld b,b			;4862	40		@
	nop			;4863	00		.
	nop			;4864	00		.
	jr z,$+4		;4865	28 02		( .
	add hl,bc		;4867	09		.
	jr nz,l487ch		;4868	20 12		  .
	nop			;486a	00		.
	inc b			;486b	04		.
	nop			;486c	00		.
	ld bc,l080ch		;486d	01 0c 08	. . .
	nop			;4870	00		.
	ld bc,main_init		;4871	01 00 04	. . .
	ex af,af		;4874	08		.
	nop			;4875	00		.
	ld h,b			;4876	60		`
	nop			;4877	00		.
	nop			;4878	00		.
	inc b			;4879	04		.
	ld h,b			;487a	60		`
	ld h,b			;487b	60		`
l487ch:
	and b			;487c	a0		.
	nop			;487d	00		.
	nop			;487e	00		.
	ld (bc),a		;487f	02		.
	ex af,af		;4880	08		.
	nop			;4881	00		.
	nop			;4882	00		.
	nop			;4883	00		.
	jr z,l48c6h		;4884	28 40		( @
	ld (de),a		;4886	12		.
	nop			;4887	00		.
	ld (bc),a		;4888	02		.
	ld (bc),a		;4889	02		.
	nop			;488a	00		.
	ex af,af		;488b	08		.
	nop			;488c	00		.
	inc b			;488d	04		.
	add hl,bc		;488e	09		.
	ld bc,l0208h		;488f	01 08 02	. . .
	ld d,b			;4892	50		P
	ld b,b			;4893	40		@
	nop			;4894	00		.
	nop			;4895	00		.
	adc a,b			;4896	88		.
	nop			;4897	00		.
	nop			;4898	00		.
	ld b,b			;4899	40		@
	ret nz			;489a	c0		.
	inc b			;489b	04		.
	add hl,bc		;489c	09		.
	ret nz			;489d	c0		.
	nop			;489e	00		.
	nop			;489f	00		.
	nop			;48a0	00		.
	nop			;48a1	00		.
	ld b,b			;48a2	40		@
	ld (bc),a		;48a3	02		.
	inc bc			;48a4	03		.
	ld b,b			;48a5	40		@
	ld a,(bc)		;48a6	0a		.
	ex af,af		;48a7	08		.
	jr nz,l48aah		;48a8	20 00		  .
l48aah:
	inc h			;48aa	24		$
	nop			;48ab	00		.
	djnz l48eeh		;48ac	10 40		. @
	nop			;48ae	00		.
	ld a,(bc)		;48af	0a		.
	djnz l48f2h		;48b0	10 40		. @
	ld (bc),a		;48b2	02		.
	nop			;48b3	00		.
	add a,h			;48b4	84		.
	ex af,af		;48b5	08		.
	add a,b			;48b6	80		.
	nop			;48b7	00		.
	nop			;48b8	00		.
	ex af,af		;48b9	08		.
	ld bc,02002h		;48ba	01 02 20	. .  
	nop			;48bd	00		.
	jr nz,l48cdh		;48be	20 0d		  .
	ld b,b			;48c0	40		@
	inc b			;48c1	04		.
	ld b,b			;48c2	40		@
	inc b			;48c3	04		.
	nop			;48c4	00		.
	add a,d			;48c5	82		.
l48c6h:
	djnz l48c8h		;48c6	10 00		. .
l48c8h:
	djnz l48cah		;48c8	10 00		. .
l48cah:
	ld h,b			;48ca	60		`
	and b			;48cb	a0		.
	nop			;48cc	00		.
l48cdh:
	ld b,d			;48cd	42		B
	add a,b			;48ce	80		.
	nop			;48cf	00		.
	add a,b			;48d0	80		.
	nop			;48d1	00		.
	ld (hl),c		;48d2	71		q
	nop			;48d3	00		.
	ld (bc),a		;48d4	02		.
	add a,b			;48d5	80		.
	ld bc,l0200h		;48d6	01 00 02	. . .
	nop			;48d9	00		.
	add a,b			;48da	80		.
	ld (bc),a		;48db	02		.
	djnz l48ech		;48dc	10 0e		. .
	nop			;48de	00		.
	ld (bc),a		;48df	02		.
	sub (hl)		;48e0	96		.
	ld (de),a		;48e1	12		.
	ld bc,08000h		;48e2	01 00 80	. . .
	nop			;48e5	00		.
	nop			;48e6	00		.
	nop			;48e7	00		.
	nop			;48e8	00		.
	nop			;48e9	00		.
	nop			;48ea	00		.
	nop			;48eb	00		.
l48ech:
	sbc a,(hl)		;48ec	9e		.
	nop			;48ed	00		.
l48eeh:
	ld de,08800h		;48ee	11 00 88	. . .
	inc h			;48f1	24		$
l48f2h:
	add hl,bc		;48f2	09		.
	inc b			;48f3	04		.
	jr nz,l48f6h		;48f4	20 00		  .
l48f6h:
	nop			;48f6	00		.
	nop			;48f7	00		.
	add a,h			;48f8	84		.
	ld (l0240h),hl		;48f9	22 40 02	" @ .
	nop			;48fc	00		.
	add a,b			;48fd	80		.
	nop			;48fe	00		.
	nop			;48ff	00		.
	inc h			;4900	24		$
	nop			;4901	00		.
	ld hl,00600h		;4902	21 00 06	! . .
	jr l4907h		;4905	18 00		. .
l4907h:
	nop			;4907	00		.
	nop			;4908	00		.
	nop			;4909	00		.
	ld bc,l6022h		;490a	01 22 60	. " `
	nop			;490d	00		.
	ld de,00600h		;490e	11 00 06	. . .
	nop			;4911	00		.
	ld bc,l0200h		;4912	01 00 02	. . .
	ld (bc),a		;4915	02		.
	ld a,(bc)		;4916	0a		.
	ex af,af		;4917	08		.
	ld b,b			;4918	40		@
	jr nz,$+10		;4919	20 08		  .
	nop			;491b	00		.
	adc a,h			;491c	8c		.
	ld (bc),a		;491d	02		.
	ld (bc),a		;491e	02		.
	nop			;491f	00		.
	inc b			;4920	04		.
	nop			;4921	00		.
	ld bc,l4030h		;4922	01 30 40	. 0 @
	ld d,b			;4925	50		P
	djnz l4928h		;4926	10 00		. .
l4928h:
	ld (08420h),a		;4928	32 20 84	2   .
	ex af,af		;492b	08		.
	nop			;492c	00		.
	nop			;492d	00		.
	inc b			;492e	04		.
	nop			;492f	00		.
	inc b			;4930	04		.
	ld b,h			;4931	44		D
	nop			;4932	00		.
	nop			;4933	00		.
	ld b,l			;4934	45		E
l4935h:
	ld bc,00800h		;4935	01 00 08	. . .
	nop			;4938	00		.
	nop			;4939	00		.
	nop			;493a	00		.
	ld h,d			;493b	62		b
	add a,b			;493c	80		.
	jr z,$+19		;493d	28 11		( .
	nop			;493f	00		.
	nop			;4940	00		.
	ld b,b			;4941	40		@
	ld b,c			;4942	41		A
	ex af,af		;4943	08		.
	jr nz,l4956h		;4944	20 10		  .
	ex af,af		;4946	08		.
	nop			;4947	00		.
	add a,d			;4948	82		.
	ld (bc),a		;4949	02		.
	nop			;494a	00		.
	ld h,b			;494b	60		`
	ld b,000h		;494c	06 00		. .
	ld bc,sub_0ffeh+2	;494e	01 00 10	. . .
	nop			;4951	00		.
	nop			;4952	00		.
	add hl,de		;4953	19		.
	nop			;4954	00		.
	add a,c			;4955	81		.
l4956h:
	nop			;4956	00		.
	inc b			;4957	04		.
	djnz l495ah		;4958	10 00		. .
l495ah:
	ld de,01022h		;495a	11 22 10	. " .
	nop			;495d	00		.
	nop			;495e	00		.
	nop			;495f	00		.
	inc b			;4960	04		.
	add a,b			;4961	80		.
	nop			;4962	00		.
	ld b,b			;4963	40		@
	ld bc,00010h		;4964	01 10 00	. . .
	ld (bc),a		;4967	02		.
	nop			;4968	00		.
	inc d			;4969	14		.
	jr nz,l497dh		;496a	20 11		  .
	nop			;496c	00		.
	nop			;496d	00		.
	sbc a,b			;496e	98		.
	nop			;496f	00		.
	ld b,b			;4970	40		@
	nop			;4971	00		.
	jr nz,l4974h		;4972	20 00		  .
l4974h:
	and b			;4974	a0		.
	ld c,h			;4975	4c		L
	ld b,b			;4976	40		@
	nop			;4977	00		.
	ld b,b			;4978	40		@
	nop			;4979	00		.
	ld bc,reset_entry		;497a	01 00 00	. . .
l497dh:
	ld (hl),h		;497d	74		t
	add a,b			;497e	80		.
	nop			;497f	00		.
	ld h,b			;4980	60		`
	djnz l4987h		;4981	10 04		. .
	nop			;4983	00		.
	ld bc,sound_ctrl_init		;4984	01 00 01	. . .
l4987h:
	ld (bc),a		;4987	02		.
	ld (bc),a		;4988	02		.
	ld c,b			;4989	48		H
	adc a,b			;498a	88		.
	djnz l49adh		;498b	10 20		.  
	ex af,af		;498d	08		.
	nop			;498e	00		.
	nop			;498f	00		.
	nop			;4990	00		.
	nop			;4991	00		.
	nop			;4992	00		.
	nop			;4993	00		.
	nop			;4994	00		.
	nop			;4995	00		.
	nop			;4996	00		.
	nop			;4997	00		.
	rst 38h			;4998	ff		.
	rst 38h			;4999	ff		.
	rst 38h			;499a	ff		.
	rst 38h			;499b	ff		.
	rst 38h			;499c	ff		.
	rst 38h			;499d	ff		.
	rst 38h			;499e	ff		.
	rst 38h			;499f	ff		.
	nop			;49a0	00		.
	nop			;49a1	00		.
	nop			;49a2	00		.
	nop			;49a3	00		.
	nop			;49a4	00		.
	nop			;49a5	00		.
	nop			;49a6	00		.
	nop			;49a7	00		.
	rst 38h			;49a8	ff		.
	rst 38h			;49a9	ff		.
	rst 38h			;49aa	ff		.
	rst 38h			;49ab	ff		.
	rst 38h			;49ac	ff		.
l49adh:
	rst 38h			;49ad	ff		.
	rst 38h			;49ae	ff		.
	rst 38h			;49af	ff		.
	nop			;49b0	00		.
	nop			;49b1	00		.
	nop			;49b2	00		.
	nop			;49b3	00		.
	nop			;49b4	00		.
	nop			;49b5	00		.
	nop			;49b6	00		.
	nop			;49b7	00		.
	rst 38h			;49b8	ff		.
	rst 38h			;49b9	ff		.
	rst 38h			;49ba	ff		.
	rst 38h			;49bb	ff		.
l49bch:
	rst 38h			;49bc	ff		.
	rst 38h			;49bd	ff		.
	rst 38h			;49be	ff		.
	rst 38h			;49bf	ff		.
	nop			;49c0	00		.
	nop			;49c1	00		.
	nop			;49c2	00		.
	nop			;49c3	00		.
	nop			;49c4	00		.
	nop			;49c5	00		.
	nop			;49c6	00		.
	nop			;49c7	00		.
	nop			;49c8	00		.
	adc a,c			;49c9	89		.
	ld (l0001h),hl		;49ca	22 01 00	" . .
	jr nz,l49cfh		;49cd	20 00		  .
l49cfh:
	nop			;49cf	00		.
	add a,b			;49d0	80		.
	nop			;49d1	00		.
	nop			;49d2	00		.
	nop			;49d3	00		.
	ex af,af		;49d4	08		.
	nop			;49d5	00		.
	add a,b			;49d6	80		.
	dec bc			;49d7	0b		.
	ex af,af		;49d8	08		.
	jr nc,l4a1bh		;49d9	30 40		0 @
	nop			;49db	00		.
	inc h			;49dc	24		$
	djnz $+18		;49dd	10 10		. .
	nop			;49df	00		.
	ld c,b			;49e0	48		H
	ld h,b			;49e1	60		`
	ld (bc),a		;49e2	02		.
	nop			;49e3	00		.
	nop			;49e4	00		.
	add a,c			;49e5	81		.
	ld (bc),a		;49e6	02		.
	nop			;49e7	00		.
	nop			;49e8	00		.
	adc a,b			;49e9	88		.
	nop			;49ea	00		.
	nop			;49eb	00		.
	jr z,l49eeh		;49ec	28 00		( .
l49eeh:
	ld de,00008h		;49ee	11 08 00	. . .
	ex af,af		;49f1	08		.
	djnz l4a14h		;49f2	10 20		.  
	ld h,h			;49f4	64		d
	nop			;49f5	00		.
	ld hl,l0200h		;49f6	21 00 02	! . .
	nop			;49f9	00		.
	add a,h			;49fa	84		.
	add a,b			;49fb	80		.
	jr nz,l4a12h		;49fc	20 14		  .
	jr nz,l4a00h		;49fe	20 00		  .
l4a00h:
	add a,b			;4a00	80		.
	nop			;4a01	00		.
l4a02h:
	jr nz,l4a09h		;4a02	20 05		  .
	nop			;4a04	00		.
	ld b,d			;4a05	42		B
	inc h			;4a06	24		$
	nop			;4a07	00		.
	add a,b			;4a08	80		.
l4a09h:
	inc b			;4a09	04		.
	ld b,(hl)		;4a0a	46		F
	add hl,bc		;4a0b	09		.
	nop			;4a0c	00		.
	nop			;4a0d	00		.
	nop			;4a0e	00		.
	inc b			;4a0f	04		.
	ld (bc),a		;4a10	02		.
	inc bc			;4a11	03		.
l4a12h:
	ld (bc),a		;4a12	02		.
	ld b,b			;4a13	40		@
l4a14h:
	jr nc,l4a16h		;4a14	30 00		0 .
l4a16h:
	nop			;4a16	00		.
	ex af,af		;4a17	08		.
	nop			;4a18	00		.
	ret nz			;4a19	c0		.
	ld d,b			;4a1a	50		P
l4a1bh:
	nop			;4a1b	00		.
	nop			;4a1c	00		.
	nop			;4a1d	00		.
	adc a,h			;4a1e	8c		.
	nop			;4a1f	00		.
	inc b			;4a20	04		.
	nop			;4a21	00		.
	ld hl,l0004h		;4a22	21 04 00	! . .
	nop			;4a25	00		.
	add a,b			;4a26	80		.
	ld bc,l0210h		;4a27	01 10 02	. . .
	nop			;4a2a	00		.
	jr nz,l4a31h		;4a2b	20 04		  .
	ld b,b			;4a2d	40		@
	inc b			;4a2e	04		.
	inc b			;4a2f	04		.
	add a,b			;4a30	80		.
l4a31h:
	inc b			;4a31	04		.
	add a,b			;4a32	80		.
	ld bc,02220h		;4a33	01 20 22	.   "
	nop			;4a36	00		.
	nop			;4a37	00		.
	inc b			;4a38	04		.
	nop			;4a39	00		.
	djnz l49bch		;4a3a	10 80		. .
	ld (00121h),hl		;4a3c	22 21 01	" ! .
	nop			;4a3f	00		.
	nop			;4a40	00		.
	nop			;4a41	00		.
	ld bc,l0288h		;4a42	01 88 02	. . .
	sub b			;4a45	90		.
	jr z,l4a48h		;4a46	28 00		( .
l4a48h:
	nop			;4a48	00		.
	ld b,b			;4a49	40		@
	jr nz,l4a5ch		;4a4a	20 10		  .
	adc a,b			;4a4c	88		.
	ex af,af		;4a4d	08		.
	add a,b			;4a4e	80		.
	nop			;4a4f	00		.
	nop			;4a50	00		.
	ld b,b			;4a51	40		@
	nop			;4a52	00		.
	inc b			;4a53	04		.
	inc b			;4a54	04		.
	add a,b			;4a55	80		.
	ld (bc),a		;4a56	02		.
	rlca			;4a57	07		.
	ld b,b			;4a58	40		@
	ex af,af		;4a59	08		.
	add a,b			;4a5a	80		.
	adc a,b			;4a5b	88		.
l4a5ch:
	ld b,b			;4a5c	40		@
	ld bc,reset_entry		;4a5d	01 00 00	. . .
	nop			;4a60	00		.
	djnz l4a73h		;4a61	10 10		. .
	jr nc,l4a65h		;4a63	30 00		0 .
l4a65h:
	ld b,h			;4a65	44		D
	nop			;4a66	00		.
	ld bc,l4030h		;4a67	01 30 40	. 0 @
	jr nz,l4a8ch		;4a6a	20 20		   
	ld b,b			;4a6c	40		@
	inc b			;4a6d	04		.
	jr nz,l4a70h		;4a6e	20 00		  .
l4a70h:
	and b			;4a70	a0		.
	nop			;4a71	00		.
	inc b			;4a72	04		.
l4a73h:
	djnz l4a75h		;4a73	10 00		. .
l4a75h:
	add hl,bc		;4a75	09		.
	djnz l4a78h		;4a76	10 00		. .
l4a78h:
	nop			;4a78	00		.
	nop			;4a79	00		.
	ret nz			;4a7a	c0		.
	inc b			;4a7b	04		.
	ld e,h			;4a7c	5c		\
	ld b,b			;4a7d	40		@
	nop			;4a7e	00		.
	nop			;4a7f	00		.
	djnz l4a02h		;4a80	10 80		. .
	djnz l4aa8h		;4a82	10 24		. $
	ex af,af		;4a84	08		.
	nop			;4a85	00		.
	ld (de),a		;4a86	12		.
	nop			;4a87	00		.
	inc h			;4a88	24		$
	nop			;4a89	00		.
	add a,b			;4a8a	80		.
	ld b,b			;4a8b	40		@
l4a8ch:
	jr nz,l4a8eh		;4a8c	20 00		  .
l4a8eh:
	jr nc,l4a91h		;4a8e	30 01		0 .
	inc b			;4a90	04		.
l4a91h:
	ld b,b			;4a91	40		@
	jr z,l4a96h		;4a92	28 02		( .
	nop			;4a94	00		.
	nop			;4a95	00		.
l4a96h:
	ld bc,l0002h		;4a96	01 02 00	. . .
	sub b			;4a99	90		.
	sub b			;4a9a	90		.
	nop			;4a9b	00		.
	ld b,b			;4a9c	40		@
	nop			;4a9d	00		.
	jr nc,l4aa0h		;4a9e	30 00		0 .
l4aa0h:
	inc e			;4aa0	1c		.
	nop			;4aa1	00		.
	ld b,b			;4aa2	40		@
	ld d,b			;4aa3	50		P
	ex af,af		;4aa4	08		.
	ld (bc),a		;4aa5	02		.
	nop			;4aa6	00		.
	nop			;4aa7	00		.
l4aa8h:
	nop			;4aa8	00		.
	inc b			;4aa9	04		.
	nop			;4aaa	00		.
	djnz l4aadh		;4aab	10 00		. .
l4aadh:
	ret z			;4aad	c8		.
	inc b			;4aae	04		.
	ld (bc),a		;4aaf	02		.
	add a,b			;4ab0	80		.
	nop			;4ab1	00		.
	ld b,b			;4ab2	40		@
	ld bc,01140h		;4ab3	01 40 11	. @ .
	ld (bc),a		;4ab6	02		.
	nop			;4ab7	00		.
	nop			;4ab8	00		.
	inc e			;4ab9	1c		.
	nop			;4aba	00		.
	ld (bc),a		;4abb	02		.
	add a,b			;4abc	80		.
	ld b,b			;4abd	40		@
	nop			;4abe	00		.
	inc b			;4abf	04		.
	nop			;4ac0	00		.
	nop			;4ac1	00		.
	jr nz,$+50		;4ac2	20 30		  0
	ld de,00808h		;4ac4	11 08 08	. . .
	nop			;4ac7	00		.
	ld c,b			;4ac8	48		H
	and b			;4ac9	a0		.
	nop			;4aca	00		.
	djnz l4acdh		;4acb	10 00		. .
l4acdh:
	nop			;4acd	00		.
	djnz l4ad0h		;4ace	10 00		. .
l4ad0h:
	jr z,l4ad2h		;4ad0	28 00		( .
l4ad2h:
	ld b,044h		;4ad2	06 44		. D
	ld bc,sub_0ffeh+2	;4ad4	01 00 10	. . .
	nop			;4ad7	00		.
	ld a,(bc)		;4ad8	0a		.
	ex af,af		;4ad9	08		.
	call nz,l0001h		;4ada	c4 01 00	. . .
	djnz l4adfh		;4add	10 00		. .
l4adfh:
	nop			;4adf	00		.
	ld h,b			;4ae0	60		`
	nop			;4ae1	00		.
	ld hl,switch_dispatch_table		;4ae2	21 00 20	! .  
	nop			;4ae5	00		.
	ld bc,l0409h		;4ae6	01 09 04	. . .
	ld b,c			;4ae9	41		A
	inc c			;4aea	0c		.
	ld a,(bc)		;4aeb	0a		.
	nop			;4aec	00		.
	nop			;4aed	00		.
	ex af,af		;4aee	08		.
	nop			;4aef	00		.
	nop			;4af0	00		.
	inc b			;4af1	04		.
	ld de,08200h		;4af2	11 00 82	. . .
	inc d			;4af5	14		.
	nop			;4af6	00		.
	inc b			;4af7	04		.
	nop			;4af8	00		.
	ld (bc),a		;4af9	02		.
	ex af,af		;4afa	08		.
	ld c,b			;4afb	48		H
	nop			;4afc	00		.
	ld b,b			;4afd	40		@
	nop			;4afe	00		.
	ld bc,l0004h		;4aff	01 04 00	. . .
	dec b			;4b02	05		.
	jr nz,l4b49h		;4b03	20 44		  D
	inc b			;4b05	04		.
	nop			;4b06	00		.
	ex af,af		;4b07	08		.
	ld b,b			;4b08	40		@
	ret nz			;4b09	c0		.
	jr nc,l4b10h		;4b0a	30 04		0 .
	nop			;4b0c	00		.
	ld (bc),a		;4b0d	02		.
	nop			;4b0e	00		.
	nop			;4b0f	00		.
l4b10h:
	ex af,af		;4b10	08		.
	nop			;4b11	00		.
	ex af,af		;4b12	08		.
	ex af,af		;4b13	08		.
	ld b,d			;4b14	42		B
	nop			;4b15	00		.
	djnz l4b18h		;4b16	10 00		. .
l4b18h:
	nop			;4b18	00		.
	nop			;4b19	00		.
	inc d			;4b1a	14		.
	ld h,d			;4b1b	62		b
	nop			;4b1c	00		.
	nop			;4b1d	00		.
	sbc a,b			;4b1e	98		.
	nop			;4b1f	00		.
	inc b			;4b20	04		.
	nop			;4b21	00		.
	nop			;4b22	00		.
	ld bc,l0060h		;4b23	01 60 00	. ` .
	add a,b			;4b26	80		.
	ex af,af		;4b27	08		.
	nop			;4b28	00		.
	nop			;4b29	00		.
	nop			;4b2a	00		.
	nop			;4b2b	00		.
	nop			;4b2c	00		.
	nop			;4b2d	00		.
	nop			;4b2e	00		.
	nop			;4b2f	00		.
	rst 38h			;4b30	ff		.
	rst 38h			;4b31	ff		.
	rst 38h			;4b32	ff		.
	rst 38h			;4b33	ff		.
	rst 38h			;4b34	ff		.
	rst 38h			;4b35	ff		.
	rst 38h			;4b36	ff		.
	rst 38h			;4b37	ff		.
	nop			;4b38	00		.
	nop			;4b39	00		.
	nop			;4b3a	00		.
	nop			;4b3b	00		.
	nop			;4b3c	00		.
	nop			;4b3d	00		.
	nop			;4b3e	00		.
	nop			;4b3f	00		.
	rst 38h			;4b40	ff		.
	rst 38h			;4b41	ff		.
	rst 38h			;4b42	ff		.
	rst 38h			;4b43	ff		.
	rst 38h			;4b44	ff		.
	rst 38h			;4b45	ff		.
	rst 38h			;4b46	ff		.
	rst 38h			;4b47	ff		.
	nop			;4b48	00		.
l4b49h:
	nop			;4b49	00		.
	nop			;4b4a	00		.
	nop			;4b4b	00		.
	nop			;4b4c	00		.
	nop			;4b4d	00		.
	nop			;4b4e	00		.
	nop			;4b4f	00		.
	rst 38h			;4b50	ff		.
	rst 38h			;4b51	ff		.
	rst 38h			;4b52	ff		.
	rst 38h			;4b53	ff		.
	rst 38h			;4b54	ff		.
	rst 38h			;4b55	ff		.
	rst 38h			;4b56	ff		.
	rst 38h			;4b57	ff		.
	nop			;4b58	00		.
	nop			;4b59	00		.
	nop			;4b5a	00		.
	nop			;4b5b	00		.
	nop			;4b5c	00		.
	nop			;4b5d	00		.
	nop			;4b5e	00		.
	nop			;4b5f	00		.
	nop			;4b60	00		.
	nop			;4b61	00		.
	nop			;4b62	00		.
	nop			;4b63	00		.
	nop			;4b64	00		.
	nop			;4b65	00		.
	nop			;4b66	00		.
	nop			;4b67	00		.
l4b68h:
	rlca			;4b68	07		.
	ld a,(bc)		;4b69	0a		.
	nop			;4b6a	00		.
	nop			;4b6b	00		.
	inc b			;4b6c	04		.
	nop			;4b6d	00		.
	nop			;4b6e	00		.
	nop			;4b6f	00		.
	nop			;4b70	00		.
	nop			;4b71	00		.
	nop			;4b72	00		.
	nop			;4b73	00		.
	inc c			;4b74	0c		.
	nop			;4b75	00		.
	nop			;4b76	00		.
	add a,b			;4b77	80		.
	nop			;4b78	00		.
	dec bc			;4b79	0b		.
	nop			;4b7a	00		.
	nop			;4b7b	00		.
	ld e,000h		;4b7c	1e 00		. .
	nop			;4b7e	00		.
	add a,b			;4b7f	80		.
	add a,b			;4b80	80		.
	dec de			;4b81	1b		.
	nop			;4b82	00		.
	inc b			;4b83	04		.
	cp a			;4b84	bf		.
	nop			;4b85	00		.
	nop			;4b86	00		.
	add a,b			;4b87	80		.
	add a,b			;4b88	80		.
	dec de			;4b89	1b		.
	nop			;4b8a	00		.
	inc b			;4b8b	04		.
	xor a			;4b8c	af		.
	nop			;4b8d	00		.
	nop			;4b8e	00		.
	add a,b			;4b8f	80		.
	add a,b			;4b90	80		.
	add hl,bc		;4b91	09		.
	nop			;4b92	00		.
	inc b			;4b93	04		.
	adc a,e			;4b94	8b		.
	nop			;4b95	00		.
	nop			;4b96	00		.
	add a,b			;4b97	80		.
	add a,b			;4b98	80		.
	ex af,af		;4b99	08		.
	nop			;4b9a	00		.
	inc b			;4b9b	04		.
	adc a,c			;4b9c	89		.
	nop			;4b9d	00		.
	nop			;4b9e	00		.
	add a,b			;4b9f	80		.
	add a,b			;4ba0	80		.
	ex af,af		;4ba1	08		.
l4ba2h:
	djnz l4bc4h		;4ba2	10 20		.  
	sub b			;4ba4	90		.
	nop			;4ba5	00		.
	nop			;4ba6	00		.
	nop			;4ba7	00		.
	nop			;4ba8	00		.
	nop			;4ba9	00		.
	nop			;4baa	00		.
	nop			;4bab	00		.
	sbc a,b			;4bac	98		.
	ld bc,reset_entry		;4bad	01 00 00	. . .
	nop			;4bb0	00		.
	nop			;4bb1	00		.
	nop			;4bb2	00		.
	nop			;4bb3	00		.
	sbc a,h			;4bb4	9c		.
	inc bc			;4bb5	03		.
	nop			;4bb6	00		.
	nop			;4bb7	00		.
	nop			;4bb8	00		.
	nop			;4bb9	00		.
	nop			;4bba	00		.
	nop			;4bbb	00		.
	sbc a,(hl)		;4bbc	9e		.
	rlca			;4bbd	07		.
	nop			;4bbe	00		.
	nop			;4bbf	00		.
	nop			;4bc0	00		.
	nop			;4bc1	00		.
	nop			;4bc2	00		.
	nop			;4bc3	00		.
l4bc4h:
	ld c,007h		;4bc4	0e 07		. .
	nop			;4bc6	00		.
	nop			;4bc7	00		.
	nop			;4bc8	00		.
	nop			;4bc9	00		.
	nop			;4bca	00		.
	nop			;4bcb	00		.
	ld b,006h		;4bcc	06 06		. .
	nop			;4bce	00		.
	nop			;4bcf	00		.
	nop			;4bd0	00		.
	nop			;4bd1	00		.
	nop			;4bd2	00		.
	nop			;4bd3	00		.
	ld (bc),a		;4bd4	02		.
	inc b			;4bd5	04		.
	nop			;4bd6	00		.
	nop			;4bd7	00		.
	nop			;4bd8	00		.
	nop			;4bd9	00		.
	nop			;4bda	00		.
	nop			;4bdb	00		.
	nop			;4bdc	00		.
	nop			;4bdd	00		.
	nop			;4bde	00		.
	nop			;4bdf	00		.
	nop			;4be0	00		.
	nop			;4be1	00		.
	nop			;4be2	00		.
	nop			;4be3	00		.
	ld (bc),a		;4be4	02		.
	inc b			;4be5	04		.
	nop			;4be6	00		.
	nop			;4be7	00		.
	nop			;4be8	00		.
	nop			;4be9	00		.
	nop			;4bea	00		.
	nop			;4beb	00		.
	ld b,006h		;4bec	06 06		. .
	nop			;4bee	00		.
	nop			;4bef	00		.
	nop			;4bf0	00		.
	nop			;4bf1	00		.
	nop			;4bf2	00		.
	nop			;4bf3	00		.
	ld c,007h		;4bf4	0e 07		. .
	nop			;4bf6	00		.
	nop			;4bf7	00		.
	nop			;4bf8	00		.
	nop			;4bf9	00		.
	nop			;4bfa	00		.
	nop			;4bfb	00		.
	sbc a,(hl)		;4bfc	9e		.
	rlca			;4bfd	07		.
	nop			;4bfe	00		.
	nop			;4bff	00		.
	nop			;4c00	00		.
	nop			;4c01	00		.
	nop			;4c02	00		.
	nop			;4c03	00		.
	sbc a,h			;4c04	9c		.
	inc bc			;4c05	03		.
	nop			;4c06	00		.
	nop			;4c07	00		.
	nop			;4c08	00		.
	nop			;4c09	00		.
	nop			;4c0a	00		.
	nop			;4c0b	00		.
	sbc a,b			;4c0c	98		.
	ld bc,reset_entry		;4c0d	01 00 00	. . .
	nop			;4c10	00		.
	nop			;4c11	00		.
	nop			;4c12	00		.
	nop			;4c13	00		.
	sub b			;4c14	90		.
	nop			;4c15	00		.
	nop			;4c16	00		.
	nop			;4c17	00		.
	nop			;4c18	00		.
	nop			;4c19	00		.
	nop			;4c1a	00		.
	nop			;4c1b	00		.
	nop			;4c1c	00		.
	nop			;4c1d	00		.
	nop			;4c1e	00		.
	nop			;4c1f	00		.
	nop			;4c20	00		.
	nop			;4c21	00		.
	nop			;4c22	00		.
	nop			;4c23	00		.
l4c24h:
	ld hl,l000ah		;4c24	21 0a 00	! . .
	nop			;4c27	00		.
	nop			;4c28	00		.
	nop			;4c29	00		.
	nop			;4c2a	00		.
	nop			;4c2b	00		.
	nop			;4c2c	00		.
	nop			;4c2d	00		.
	nop			;4c2e	00		.
	ld b,b			;4c2f	40		@
	ld bc,reset_entry		;4c30	01 00 00	. . .
	ld a,(bc)		;4c33	0a		.
	nop			;4c34	00		.
	nop			;4c35	00		.
	nop			;4c36	00		.
	ret po			;4c37	e0		.
	ld bc,reset_entry		;4c38	01 00 00	. . .
	ld e,000h		;4c3b	1e 00		. .
	nop			;4c3d	00		.
	nop			;4c3e	00		.
	ret p			;4c3f	f0		.
	ld bc,reset_entry		;4c40	01 00 00	. . .
	ld e,000h		;4c43	1e 00		. .
	nop			;4c45	00		.
	nop			;4c46	00		.
	ret po			;4c47	e0		.
	ld bc,reset_entry		;4c48	01 00 00	. . .
	jr l4c4dh		;4c4b	18 00		. .
l4c4dh:
	nop			;4c4d	00		.
	nop			;4c4e	00		.
	ret po			;4c4f	e0		.
	ld bc,reset_entry		;4c50	01 00 00	. . .
	nop			;4c53	00		.
	nop			;4c54	00		.
	nop			;4c55	00		.
	nop			;4c56	00		.
	ld h,b			;4c57	60		`
	nop			;4c58	00		.
	nop			;4c59	00		.
	nop			;4c5a	00		.
	nop			;4c5b	00		.
	nop			;4c5c	00		.
	nop			;4c5d	00		.
	nop			;4c5e	00		.
	nop			;4c5f	00		.
	nop			;4c60	00		.
	nop			;4c61	00		.
	nop			;4c62	00		.
	nop			;4c63	00		.
	nop			;4c64	00		.
	nop			;4c65	00		.
	nop			;4c66	00		.
	nop			;4c67	00		.
	nop			;4c68	00		.
	nop			;4c69	00		.
	nop			;4c6a	00		.
	ld (de),a		;4c6b	12		.
	nop			;4c6c	00		.
	nop			;4c6d	00		.
	nop			;4c6e	00		.
	nop			;4c6f	00		.
	nop			;4c70	00		.
	nop			;4c71	00		.
	nop			;4c72	00		.
	ld e,000h		;4c73	1e 00		. .
	nop			;4c75	00		.
	nop			;4c76	00		.
	jr nz,l4c7ah		;4c77	20 01		  .
	nop			;4c79	00		.
l4c7ah:
	nop			;4c7a	00		.
	ld e,000h		;4c7b	1e 00		. .
	nop			;4c7d	00		.
	nop			;4c7e	00		.
	ret po			;4c7f	e0		.
	ld bc,reset_entry		;4c80	01 00 00	. . .
	ld e,000h		;4c83	1e 00		. .
	nop			;4c85	00		.
	nop			;4c86	00		.
	ret po			;4c87	e0		.
	ld bc,reset_entry		;4c88	01 00 00	. . .
	jr l4c8dh		;4c8b	18 00		. .
l4c8dh:
	nop			;4c8d	00		.
	nop			;4c8e	00		.
	ret po			;4c8f	e0		.
	ld bc,reset_entry		;4c90	01 00 00	. . .
	nop			;4c93	00		.
	nop			;4c94	00		.
	nop			;4c95	00		.
	nop			;4c96	00		.
	ld h,b			;4c97	60		`
	nop			;4c98	00		.
	nop			;4c99	00		.
	nop			;4c9a	00		.
	nop			;4c9b	00		.
	nop			;4c9c	00		.
	nop			;4c9d	00		.
	nop			;4c9e	00		.
	nop			;4c9f	00		.
	nop			;4ca0	00		.
	nop			;4ca1	00		.
	nop			;4ca2	00		.
	nop			;4ca3	00		.
	nop			;4ca4	00		.
	nop			;4ca5	00		.
	rst 38h			;4ca6	ff		.
	rst 38h			;4ca7	ff		.
	rst 38h			;4ca8	ff		.
	rst 38h			;4ca9	ff		.
	rst 38h			;4caa	ff		.
	rst 38h			;4cab	ff		.
	rst 38h			;4cac	ff		.
	rst 38h			;4cad	ff		.
	nop			;4cae	00		.
	nop			;4caf	00		.
	nop			;4cb0	00		.
	nop			;4cb1	00		.
	nop			;4cb2	00		.
	nop			;4cb3	00		.
	nop			;4cb4	00		.
	nop			;4cb5	00		.
	nop			;4cb6	00		.
	ld b,b			;4cb7	40		@
	ld bc,reset_entry		;4cb8	01 00 00	. . .
	ld a,(bc)		;4cbb	0a		.
	nop			;4cbc	00		.
	nop			;4cbd	00		.
	nop			;4cbe	00		.
	ret po			;4cbf	e0		.
	ld bc,reset_entry		;4cc0	01 00 00	. . .
	ld e,000h		;4cc3	1e 00		. .
	nop			;4cc5	00		.
	nop			;4cc6	00		.
	ret p			;4cc7	f0		.
	ld bc,reset_entry		;4cc8	01 00 00	. . .
	ld e,000h		;4ccb	1e 00		. .
	nop			;4ccd	00		.
	nop			;4cce	00		.
	ret po			;4ccf	e0		.
	ld bc,reset_entry		;4cd0	01 00 00	. . .
	jr l4cd5h		;4cd3	18 00		. .
l4cd5h:
	nop			;4cd5	00		.
	nop			;4cd6	00		.
	ret po			;4cd7	e0		.
	ld bc,reset_entry		;4cd8	01 00 00	. . .
	nop			;4cdb	00		.
	nop			;4cdc	00		.
	nop			;4cdd	00		.
	nop			;4cde	00		.
	ld h,b			;4cdf	60		`
	nop			;4ce0	00		.
	nop			;4ce1	00		.
	nop			;4ce2	00		.
	nop			;4ce3	00		.
	nop			;4ce4	00		.
	nop			;4ce5	00		.
	nop			;4ce6	00		.
	nop			;4ce7	00		.
	nop			;4ce8	00		.
	nop			;4ce9	00		.
	nop			;4cea	00		.
	nop			;4ceb	00		.
	nop			;4cec	00		.
	nop			;4ced	00		.
	nop			;4cee	00		.
	nop			;4cef	00		.
	nop			;4cf0	00		.
	nop			;4cf1	00		.
	nop			;4cf2	00		.
	ld (de),a		;4cf3	12		.
	nop			;4cf4	00		.
	nop			;4cf5	00		.
	nop			;4cf6	00		.
	nop			;4cf7	00		.
	nop			;4cf8	00		.
	nop			;4cf9	00		.
	nop			;4cfa	00		.
	ld e,000h		;4cfb	1e 00		. .
	nop			;4cfd	00		.
	nop			;4cfe	00		.
	jr nz,l4d02h		;4cff	20 01		  .
	nop			;4d01	00		.
l4d02h:
	nop			;4d02	00		.
	ld e,000h		;4d03	1e 00		. .
	nop			;4d05	00		.
	nop			;4d06	00		.
	ret po			;4d07	e0		.
	ld bc,reset_entry		;4d08	01 00 00	. . .
	ld e,000h		;4d0b	1e 00		. .
	nop			;4d0d	00		.
	nop			;4d0e	00		.
	ret po			;4d0f	e0		.
	ld bc,reset_entry		;4d10	01 00 00	. . .
	jr l4d15h		;4d13	18 00		. .
l4d15h:
	nop			;4d15	00		.
	nop			;4d16	00		.
	ret po			;4d17	e0		.
	ld bc,reset_entry		;4d18	01 00 00	. . .
	nop			;4d1b	00		.
	nop			;4d1c	00		.
	nop			;4d1d	00		.
	nop			;4d1e	00		.
	ld h,b			;4d1f	60		`
	nop			;4d20	00		.
	nop			;4d21	00		.
	nop			;4d22	00		.
	nop			;4d23	00		.
	nop			;4d24	00		.
	nop			;4d25	00		.
	nop			;4d26	00		.
	nop			;4d27	00		.
	nop			;4d28	00		.
	nop			;4d29	00		.
	nop			;4d2a	00		.
	nop			;4d2b	00		.
	nop			;4d2c	00		.
	nop			;4d2d	00		.
l4d2eh:
	jr l4d5eh		;4d2e	18 2e		. .
	nop			;4d30	00		.
	nop			;4d31	00		.
	nop			;4d32	00		.
	nop			;4d33	00		.
	nop			;4d34	00		.
	nop			;4d35	00		.
	nop			;4d36	00		.
	nop			;4d37	00		.
	nop			;4d38	00		.
	nop			;4d39	00		.
	ld (bc),a		;4d3a	02		.
	nop			;4d3b	00		.
	nop			;4d3c	00		.
	nop			;4d3d	00		.
	nop			;4d3e	00		.
	nop			;4d3f	00		.
	nop			;4d40	00		.
	nop			;4d41	00		.
	ld b,000h		;4d42	06 00		. .
	nop			;4d44	00		.
	nop			;4d45	00		.
	nop			;4d46	00		.
	nop			;4d47	00		.
	nop			;4d48	00		.
	nop			;4d49	00		.
	ld c,000h		;4d4a	0e 00		. .
	nop			;4d4c	00		.
	nop			;4d4d	00		.
	nop			;4d4e	00		.
	nop			;4d4f	00		.
	nop			;4d50	00		.
	nop			;4d51	00		.
	ld e,000h		;4d52	1e 00		. .
	nop			;4d54	00		.
	nop			;4d55	00		.
	nop			;4d56	00		.
	nop			;4d57	00		.
	nop			;4d58	00		.
	nop			;4d59	00		.
	ld a,000h		;4d5a	3e 00		> .
	nop			;4d5c	00		.
	nop			;4d5d	00		.
l4d5eh:
	nop			;4d5e	00		.
	nop			;4d5f	00		.
	nop			;4d60	00		.
	nop			;4d61	00		.
	ld a,(hl)		;4d62	7e		~
	nop			;4d63	00		.
	nop			;4d64	00		.
	nop			;4d65	00		.
	nop			;4d66	00		.
	nop			;4d67	00		.
	nop			;4d68	00		.
	nop			;4d69	00		.
	ld a,h			;4d6a	7c		|
	nop			;4d6b	00		.
	nop			;4d6c	00		.
	nop			;4d6d	00		.
	nop			;4d6e	00		.
	nop			;4d6f	00		.
	nop			;4d70	00		.
	nop			;4d71	00		.
	ld a,b			;4d72	78		x
	nop			;4d73	00		.
	nop			;4d74	00		.
	nop			;4d75	00		.
	nop			;4d76	00		.
	nop			;4d77	00		.
	nop			;4d78	00		.
	nop			;4d79	00		.
	ld (hl),b		;4d7a	70		p
	nop			;4d7b	00		.
	nop			;4d7c	00		.
	nop			;4d7d	00		.
	nop			;4d7e	00		.
	nop			;4d7f	00		.
	nop			;4d80	00		.
	nop			;4d81	00		.
	ld h,b			;4d82	60		`
	nop			;4d83	00		.
	nop			;4d84	00		.
	nop			;4d85	00		.
	nop			;4d86	00		.
	nop			;4d87	00		.
	nop			;4d88	00		.
	nop			;4d89	00		.
	ld b,b			;4d8a	40		@
	nop			;4d8b	00		.
	nop			;4d8c	00		.
	nop			;4d8d	00		.
	nop			;4d8e	00		.
	nop			;4d8f	00		.
	nop			;4d90	00		.
	nop			;4d91	00		.
	nop			;4d92	00		.
	nop			;4d93	00		.
	nop			;4d94	00		.
	nop			;4d95	00		.
	nop			;4d96	00		.
	nop			;4d97	00		.
	nop			;4d98	00		.
	nop			;4d99	00		.
	nop			;4d9a	00		.
	nop			;4d9b	00		.
	nop			;4d9c	00		.
	nop			;4d9d	00		.
	nop			;4d9e	00		.
	nop			;4d9f	00		.
	rst 38h			;4da0	ff		.
	rst 38h			;4da1	ff		.
	rst 38h			;4da2	ff		.
	rst 38h			;4da3	ff		.
	rst 38h			;4da4	ff		.
	rst 38h			;4da5	ff		.
	rst 38h			;4da6	ff		.
	rst 38h			;4da7	ff		.
	nop			;4da8	00		.
	nop			;4da9	00		.
	nop			;4daa	00		.
	nop			;4dab	00		.
	nop			;4dac	00		.
	nop			;4dad	00		.
	nop			;4dae	00		.
	nop			;4daf	00		.
	rst 38h			;4db0	ff		.
	rst 38h			;4db1	ff		.
	rst 38h			;4db2	ff		.
	rst 38h			;4db3	ff		.
	rst 38h			;4db4	ff		.
	rst 38h			;4db5	ff		.
	rst 38h			;4db6	ff		.
	rst 38h			;4db7	ff		.
	nop			;4db8	00		.
	nop			;4db9	00		.
	ld a,(hl)		;4dba	7e		~
	nop			;4dbb	00		.
	nop			;4dbc	00		.
	nop			;4dbd	00		.
	nop			;4dbe	00		.
	nop			;4dbf	00		.
	nop			;4dc0	00		.
	nop			;4dc1	00		.
	ld a,h			;4dc2	7c		|
	nop			;4dc3	00		.
	nop			;4dc4	00		.
	nop			;4dc5	00		.
	nop			;4dc6	00		.
	nop			;4dc7	00		.
	nop			;4dc8	00		.
	nop			;4dc9	00		.
	ld a,b			;4dca	78		x
	nop			;4dcb	00		.
	nop			;4dcc	00		.
	nop			;4dcd	00		.
	nop			;4dce	00		.
	nop			;4dcf	00		.
	nop			;4dd0	00		.
	nop			;4dd1	00		.
	ld (hl),b		;4dd2	70		p
	nop			;4dd3	00		.
	nop			;4dd4	00		.
	nop			;4dd5	00		.
	nop			;4dd6	00		.
	nop			;4dd7	00		.
	nop			;4dd8	00		.
	nop			;4dd9	00		.
	ld h,b			;4dda	60		`
	nop			;4ddb	00		.
	nop			;4ddc	00		.
	nop			;4ddd	00		.
	nop			;4dde	00		.
	nop			;4ddf	00		.
	nop			;4de0	00		.
	nop			;4de1	00		.
	ld b,b			;4de2	40		@
	nop			;4de3	00		.
	nop			;4de4	00		.
	nop			;4de5	00		.
	nop			;4de6	00		.
	nop			;4de7	00		.
	nop			;4de8	00		.
	nop			;4de9	00		.
	nop			;4dea	00		.
	nop			;4deb	00		.
	nop			;4dec	00		.
	nop			;4ded	00		.
	nop			;4dee	00		.
	nop			;4def	00		.
l4df0h:
	rra			;4df0	1f		.
	jr nz,$+1		;4df1	20 ff		  .
	rst 38h			;4df3	ff		.
	rst 38h			;4df4	ff		.
	rst 38h			;4df5	ff		.
	rst 38h			;4df6	ff		.
	rst 38h			;4df7	ff		.
	rst 38h			;4df8	ff		.
	rst 38h			;4df9	ff		.
	rst 38h			;4dfa	ff		.
	rst 38h			;4dfb	ff		.
	rst 38h			;4dfc	ff		.
	rst 38h			;4dfd	ff		.
	rst 38h			;4dfe	ff		.
	ld bc,0fffeh		;4dff	01 fe ff	. . .
	rst 38h			;4e02	ff		.
	ccf			;4e03	3f		?
	sbc a,(hl)		;4e04	9e		.
	rst 38h			;4e05	ff		.
	rst 38h			;4e06	ff		.
	ld bc,0fffeh		;4e07	01 fe ff	. . .
	rst 38h			;4e0a	ff		.
	rlca			;4e0b	07		.
	adc a,(hl)		;4e0c	8e		.
	rst 38h			;4e0d	ff		.
	rst 38h			;4e0e	ff		.
	ld bc,0f3feh		;4e0f	01 fe f3	. . .
	rst 38h			;4e12	ff		.
	nop			;4e13	00		.
	add a,(hl)		;4e14	86		.
	rst 38h			;4e15	ff		.
	rst 38h			;4e16	ff		.
	ld bc,0e17eh		;4e17	01 7e e1	. ~ .
	ld a,a			;4e1a	7f		.
	nop			;4e1b	00		.
	add a,d			;4e1c	82		.
	rst 38h			;4e1d	ff		.
	rst 38h			;4e1e	ff		.
	ld bc,0e05eh		;4e1f	01 5e e0	. ^ .
	ld h,a			;4e22	67		g
	nop			;4e23	00		.
	add a,b			;4e24	80		.
	rst 38h			;4e25	ff		.
	rst 38h			;4e26	ff		.
	ld bc,0c04eh		;4e27	01 4e c0	. N .
	ld h,c			;4e2a	61		a
	nop			;4e2b	00		.
	nop			;4e2c	00		.
	cp 0ffh			;4e2d	fe ff		. .
	ld bc,0c002h		;4e2f	01 02 c0	. . .
	ld h,c			;4e32	61		a
	nop			;4e33	00		.
	nop			;4e34	00		.
	cp 0dfh			;4e35	fe df		. .
	ld bc,0c000h		;4e37	01 00 c0	. . .
	ld h,c			;4e3a	61		a
	nop			;4e3b	00		.
	nop			;4e3c	00		.
	cp 007h			;4e3d	fe 07		. .
	ld bc,08000h		;4e3f	01 00 80	. . .
	ld h,c			;4e42	61		a
	nop			;4e43	00		.
	nop			;4e44	00		.
	cp 001h			;4e45	fe 01		. .
	ld bc,08000h		;4e47	01 00 80	. . .
	ld h,c			;4e4a	61		a
	nop			;4e4b	00		.
	nop			;4e4c	00		.
	ld a,(hl)		;4e4d	7e		~
	nop			;4e4e	00		.
	ld bc,08000h		;4e4f	01 00 80	. . .
	ld h,c			;4e52	61		a
	nop			;4e53	00		.
	nop			;4e54	00		.
	ld e,000h		;4e55	1e 00		. .
	nop			;4e57	00		.
	nop			;4e58	00		.
	nop			;4e59	00		.
	ld h,c			;4e5a	61		a
	nop			;4e5b	00		.
	nop			;4e5c	00		.
	ld b,000h		;4e5d	06 00		. .
	nop			;4e5f	00		.
	nop			;4e60	00		.
	nop			;4e61	00		.
	ld h,c			;4e62	61		a
	nop			;4e63	00		.
	nop			;4e64	00		.
	nop			;4e65	00		.
	nop			;4e66	00		.
	nop			;4e67	00		.
	nop			;4e68	00		.
	nop			;4e69	00		.
	nop			;4e6a	00		.
	nop			;4e6b	00		.
	nop			;4e6c	00		.
	nop			;4e6d	00		.
	nop			;4e6e	00		.
	nop			;4e6f	00		.
	nop			;4e70	00		.
	nop			;4e71	00		.
	nop			;4e72	00		.
	nop			;4e73	00		.
	nop			;4e74	00		.
	ld b,000h		;4e75	06 00		. .
	nop			;4e77	00		.
	nop			;4e78	00		.
	nop			;4e79	00		.
	nop			;4e7a	00		.
	nop			;4e7b	00		.
	nop			;4e7c	00		.
	ld e,000h		;4e7d	1e 00		. .
	nop			;4e7f	00		.
	nop			;4e80	00		.
	nop			;4e81	00		.
	nop			;4e82	00		.
	nop			;4e83	00		.
	nop			;4e84	00		.
	ld a,(hl)		;4e85	7e		~
	nop			;4e86	00		.
	ld bc,08000h		;4e87	01 00 80	. . .
	nop			;4e8a	00		.
	nop			;4e8b	00		.
	nop			;4e8c	00		.
	cp 001h			;4e8d	fe 01		. .
	ld bc,08000h		;4e8f	01 00 80	. . .
	nop			;4e92	00		.
	nop			;4e93	00		.
	nop			;4e94	00		.
	cp 007h			;4e95	fe 07		. .
	ld bc,08000h		;4e97	01 00 80	. . .
	nop			;4e9a	00		.
	nop			;4e9b	00		.
	nop			;4e9c	00		.
	cp 0dfh			;4e9d	fe df		. .
	ld bc,0c000h		;4e9f	01 00 c0	. . .
	nop			;4ea2	00		.
	nop			;4ea3	00		.
	nop			;4ea4	00		.
	cp 0ffh			;4ea5	fe ff		. .
	ld bc,0c002h		;4ea7	01 02 c0	. . .
	ld b,000h		;4eaa	06 00		. .
	add a,b			;4eac	80		.
	rst 38h			;4ead	ff		.
	rst 38h			;4eae	ff		.
	ld bc,0c04eh		;4eaf	01 4e c0	. N .
	ld e,000h		;4eb2	1e 00		. .
	add a,d			;4eb4	82		.
	rst 38h			;4eb5	ff		.
	rst 38h			;4eb6	ff		.
	ld bc,0e05eh		;4eb7	01 5e e0	. ^ .
	sbc a,(hl)		;4eba	9e		.
	nop			;4ebb	00		.
	add a,(hl)		;4ebc	86		.
	rst 38h			;4ebd	ff		.
	rst 38h			;4ebe	ff		.
	ld bc,0e17eh		;4ebf	01 7e e1	. ~ .
	sbc a,(hl)		;4ec2	9e		.
	rlca			;4ec3	07		.
	adc a,(hl)		;4ec4	8e		.
	rst 38h			;4ec5	ff		.
	rst 38h			;4ec6	ff		.
	ld bc,0f3feh		;4ec7	01 fe f3	. . .
	sbc a,(hl)		;4eca	9e		.
	ccf			;4ecb	3f		?
	sbc a,(hl)		;4ecc	9e		.
	rst 38h			;4ecd	ff		.
	rst 38h			;4ece	ff		.
	ld bc,0fffeh		;4ecf	01 fe ff	. . .
	sbc a,(hl)		;4ed2	9e		.
	rst 38h			;4ed3	ff		.
	rst 38h			;4ed4	ff		.
	rst 38h			;4ed5	ff		.
	rst 38h			;4ed6	ff		.
	ld bc,0fffeh		;4ed7	01 fe ff	. . .
	sbc a,(hl)		;4eda	9e		.
	rst 38h			;4edb	ff		.
	rst 38h			;4edc	ff		.
	rst 38h			;4edd	ff		.
	rst 38h			;4ede	ff		.
	rst 38h			;4edf	ff		.
	rst 38h			;4ee0	ff		.
	rst 38h			;4ee1	ff		.
	rst 38h			;4ee2	ff		.
	rst 38h			;4ee3	ff		.
	rst 38h			;4ee4	ff		.
	rst 38h			;4ee5	ff		.
	rst 38h			;4ee6	ff		.
	rst 38h			;4ee7	ff		.
	rst 38h			;4ee8	ff		.
	rst 38h			;4ee9	ff		.
l4eeah:
	rra			;4eea	1f		.
	jr nz,$+1		;4eeb	20 ff		  .
	rst 38h			;4eed	ff		.
	rst 38h			;4eee	ff		.
	rst 38h			;4eef	ff		.
	rst 38h			;4ef0	ff		.
	rst 38h			;4ef1	ff		.
	rst 38h			;4ef2	ff		.
	rst 38h			;4ef3	ff		.
	rst 38h			;4ef4	ff		.
	rst 38h			;4ef5	ff		.
	rst 38h			;4ef6	ff		.
	ld sp,hl		;4ef7	f9		.
	rst 38h			;4ef8	ff		.
	rst 38h			;4ef9	ff		.
	rst 38h			;4efa	ff		.
	rst 38h			;4efb	ff		.
	rst 38h			;4efc	ff		.
	rst 38h			;4efd	ff		.
	rst 38h			;4efe	ff		.
	pop hl			;4eff	e1		.
	rst 38h			;4f00	ff		.
	rst 38h			;4f01	ff		.
	rst 38h			;4f02	ff		.
	rst 38h			;4f03	ff		.
	rst 38h			;4f04	ff		.
	rst 38h			;4f05	ff		.
	rst 38h			;4f06	ff		.
	add a,c			;4f07	81		.
	rst 38h			;4f08	ff		.
	cp 0ffh			;4f09	fe ff		. .
	ld a,a			;4f0b	7f		.
	rst 38h			;4f0c	ff		.
	rst 38h			;4f0d	ff		.
	rst 38h			;4f0e	ff		.
	ld bc,0fefeh		;4f0f	01 fe fe	. . .
	rst 38h			;4f12	ff		.
	ld a,a			;4f13	7f		.
	rst 38h			;4f14	ff		.
	rst 38h			;4f15	ff		.
	rst 38h			;4f16	ff		.
	ld bc,0fef8h		;4f17	01 f8 fe	. . .
	rst 38h			;4f1a	ff		.
	ld a,a			;4f1b	7f		.
	rst 38h			;4f1c	ff		.
	rst 38h			;4f1d	ff		.
	rst 38h			;4f1e	ff		.
	ld bc,0fe20h		;4f1f	01 20 fe	.   .
	rst 38h			;4f22	ff		.
	ccf			;4f23	3f		?
	rst 38h			;4f24	ff		.
	rst 38h			;4f25	ff		.
	rst 38h			;4f26	ff		.
	ld bc,0fe00h		;4f27	01 00 fe	. . .
	defb 0fdh,03fh,0f9h ;illegal sequence	;4f2a	fd 3f f9	. ? .
	rst 38h			;4f2d	ff		.
	ld a,a			;4f2e	7f		.
	nop			;4f2f	00		.
	nop			;4f30	00		.
	cp 0b1h			;4f31	fe b1		. .
	ccf			;4f33	3f		?
	pop hl			;4f34	e1		.
	rst 38h			;4f35	ff		.
	ld a,l			;4f36	7d		}
	nop			;4f37	00		.
	nop			;4f38	00		.
	cp 0a1h			;4f39	fe a1		. .
	rra			;4f3b	1f		.
	ld h,c			;4f3c	61		a
	rst 38h			;4f3d	ff		.
	ld a,c			;4f3e	79		y
	nop			;4f3f	00		.
	nop			;4f40	00		.
	cp 081h			;4f41	fe 81		. .
	ld e,061h		;4f43	1e 61		. a
	ret m			;4f45	f8		.
	ld (hl),c		;4f46	71		q
	nop			;4f47	00		.
	nop			;4f48	00		.
	cp 001h			;4f49	fe 01		. .
	inc c			;4f4b	0c		.
	ld h,c			;4f4c	61		a
	ret nz			;4f4d	c0		.
	ld h,c			;4f4e	61		a
	nop			;4f4f	00		.
	nop			;4f50	00		.
	cp 001h			;4f51	fe 01		. .
	nop			;4f53	00		.
	ld h,c			;4f54	61		a
	nop			;4f55	00		.
	nop			;4f56	00		.
	nop			;4f57	00		.
	nop			;4f58	00		.
	cp 001h			;4f59	fe 01		. .
	nop			;4f5b	00		.
	ld h,c			;4f5c	61		a
	nop			;4f5d	00		.
	nop			;4f5e	00		.
	nop			;4f5f	00		.
	nop			;4f60	00		.
	nop			;4f61	00		.
	nop			;4f62	00		.
	nop			;4f63	00		.
	nop			;4f64	00		.
	nop			;4f65	00		.
	nop			;4f66	00		.
	nop			;4f67	00		.
	nop			;4f68	00		.
	nop			;4f69	00		.
	nop			;4f6a	00		.
	nop			;4f6b	00		.
	nop			;4f6c	00		.
	nop			;4f6d	00		.
	nop			;4f6e	00		.
	nop			;4f6f	00		.
	nop			;4f70	00		.
	cp 001h			;4f71	fe 01		. .
	nop			;4f73	00		.
	nop			;4f74	00		.
	ret nz			;4f75	c0		.
	ld h,c			;4f76	61		a
	nop			;4f77	00		.
	nop			;4f78	00		.
	cp 001h			;4f79	fe 01		. .
	nop			;4f7b	00		.
	nop			;4f7c	00		.
	ret m			;4f7d	f8		.
	ld (hl),c		;4f7e	71		q
	nop			;4f7f	00		.
	nop			;4f80	00		.
	cp 001h			;4f81	fe 01		. .
	inc c			;4f83	0c		.
	nop			;4f84	00		.
	rst 38h			;4f85	ff		.
	ld a,c			;4f86	79		y
	nop			;4f87	00		.
	nop			;4f88	00		.
	cp 081h			;4f89	fe 81		. .
	ld e,080h		;4f8b	1e 80		. .
	rst 38h			;4f8d	ff		.
	ld a,l			;4f8e	7d		}
	nop			;4f8f	00		.
	nop			;4f90	00		.
	cp 0a1h			;4f91	fe a1		. .
	rra			;4f93	1f		.
	sbc a,b			;4f94	98		.
	rst 38h			;4f95	ff		.
	ld a,a			;4f96	7f		.
	nop			;4f97	00		.
	nop			;4f98	00		.
	cp 0b1h			;4f99	fe b1		. .
	ccf			;4f9b	3f		?
	sbc a,(hl)		;4f9c	9e		.
	rst 38h			;4f9d	ff		.
	rst 38h			;4f9e	ff		.
	ld bc,0fe00h		;4f9f	01 00 fe	. . .
	defb 0fdh,03fh,09eh ;illegal sequence	;4fa2	fd 3f 9e	. ? .
	rst 38h			;4fa5	ff		.
	rst 38h			;4fa6	ff		.
	ld bc,0fe20h		;4fa7	01 20 fe	.   .
	rst 38h			;4faa	ff		.
	ccf			;4fab	3f		?
	sbc a,(hl)		;4fac	9e		.
	rst 38h			;4fad	ff		.
	rst 38h			;4fae	ff		.
	ld bc,0fef8h		;4faf	01 f8 fe	. . .
	rst 38h			;4fb2	ff		.
	ld a,a			;4fb3	7f		.
	sbc a,(hl)		;4fb4	9e		.
	rst 38h			;4fb5	ff		.
	rst 38h			;4fb6	ff		.
	ld bc,0fefeh		;4fb7	01 fe fe	. . .
	rst 38h			;4fba	ff		.
	ld a,a			;4fbb	7f		.
	sbc a,(hl)		;4fbc	9e		.
	rst 38h			;4fbd	ff		.
	rst 38h			;4fbe	ff		.
	add a,c			;4fbf	81		.
	rst 38h			;4fc0	ff		.
	cp 0ffh			;4fc1	fe ff		. .
	ld a,a			;4fc3	7f		.
	sbc a,(hl)		;4fc4	9e		.
	rst 38h			;4fc5	ff		.
	rst 38h			;4fc6	ff		.
	pop hl			;4fc7	e1		.
	rst 38h			;4fc8	ff		.
	rst 38h			;4fc9	ff		.
	rst 38h			;4fca	ff		.
	rst 38h			;4fcb	ff		.
	sbc a,(hl)		;4fcc	9e		.
	rst 38h			;4fcd	ff		.
	rst 38h			;4fce	ff		.
	ld sp,hl		;4fcf	f9		.
	rst 38h			;4fd0	ff		.
	rst 38h			;4fd1	ff		.
	rst 38h			;4fd2	ff		.
	rst 38h			;4fd3	ff		.
	sbc a,(hl)		;4fd4	9e		.
	rst 38h			;4fd5	ff		.
	rst 38h			;4fd6	ff		.
	rst 38h			;4fd7	ff		.
	rst 38h			;4fd8	ff		.
	rst 38h			;4fd9	ff		.
	rst 38h			;4fda	ff		.
	rst 38h			;4fdb	ff		.
	rst 38h			;4fdc	ff		.
	rst 38h			;4fdd	ff		.
	rst 38h			;4fde	ff		.
	rst 38h			;4fdf	ff		.
	rst 38h			;4fe0	ff		.
	rst 38h			;4fe1	ff		.
	rst 38h			;4fe2	ff		.
	rst 38h			;4fe3	ff		.
	rst 38h			;4fe4	ff		.
	rst 38h			;4fe5	ff		.
	rst 38h			;4fe6	ff		.
	rst 38h			;4fe7	ff		.
	rst 38h			;4fe8	ff		.
	rst 38h			;4fe9	ff		.
	rst 38h			;4fea	ff		.
	rst 38h			;4feb	ff		.
	rst 38h			;4fec	ff		.
	rst 38h			;4fed	ff		.
	rst 38h			;4fee	ff		.
	rst 38h			;4fef	ff		.
	rst 38h			;4ff0	ff		.
	rst 38h			;4ff1	ff		.
	rst 38h			;4ff2	ff		.
	rst 38h			;4ff3	ff		.
	rst 38h			;4ff4	ff		.
	rst 38h			;4ff5	ff		.
	rst 38h			;4ff6	ff		.
	rst 38h			;4ff7	ff		.
	rst 38h			;4ff8	ff		.
	rst 38h			;4ff9	ff		.
	rst 38h			;4ffa	ff		.
	rst 38h			;4ffb	ff		.
	rst 38h			;4ffc	ff		.
	rst 38h			;4ffd	ff		.
	rst 38h			;4ffe	ff		.
	rst 38h			;4fff	ff		.
	rst 38h			;5000	ff		.
	rst 38h			;5001	ff		.
	rst 38h			;5002	ff		.
	rst 38h			;5003	ff		.
	rst 38h			;5004	ff		.
	rst 38h			;5005	ff		.
	rst 38h			;5006	ff		.
	rst 38h			;5007	ff		.
	rst 38h			;5008	ff		.
	rst 38h			;5009	ff		.
	rst 38h			;500a	ff		.
	rst 38h			;500b	ff		.
	rst 38h			;500c	ff		.
	rst 38h			;500d	ff		.
	rst 38h			;500e	ff		.
	rst 38h			;500f	ff		.
	rst 38h			;5010	ff		.
	rst 38h			;5011	ff		.
	rst 38h			;5012	ff		.
	rst 38h			;5013	ff		.
	rst 38h			;5014	ff		.
	rst 38h			;5015	ff		.
	rst 38h			;5016	ff		.
	rst 38h			;5017	ff		.
	rst 38h			;5018	ff		.
	rst 38h			;5019	ff		.
	rst 38h			;501a	ff		.
	rst 38h			;501b	ff		.
	rst 38h			;501c	ff		.
	rst 38h			;501d	ff		.
	rst 38h			;501e	ff		.
	rst 38h			;501f	ff		.
	rst 38h			;5020	ff		.
	rst 38h			;5021	ff		.
	rst 38h			;5022	ff		.
	rst 38h			;5023	ff		.
	rst 38h			;5024	ff		.
	rst 38h			;5025	ff		.
	rst 38h			;5026	ff		.
	rst 38h			;5027	ff		.
	rst 38h			;5028	ff		.
	rst 38h			;5029	ff		.
	rst 38h			;502a	ff		.
	rst 38h			;502b	ff		.
	rst 38h			;502c	ff		.
	rst 38h			;502d	ff		.
	rst 38h			;502e	ff		.
	rst 38h			;502f	ff		.
	rst 38h			;5030	ff		.
	rst 38h			;5031	ff		.
	rst 38h			;5032	ff		.
	rst 38h			;5033	ff		.
	rst 38h			;5034	ff		.
	rst 38h			;5035	ff		.
	rst 38h			;5036	ff		.
	rst 38h			;5037	ff		.
	rst 38h			;5038	ff		.
	rst 38h			;5039	ff		.
	rst 38h			;503a	ff		.
	rst 38h			;503b	ff		.
	rst 38h			;503c	ff		.
	rst 38h			;503d	ff		.
	rst 38h			;503e	ff		.
	rst 38h			;503f	ff		.
	rst 38h			;5040	ff		.
	rst 38h			;5041	ff		.
	rst 38h			;5042	ff		.
	rst 38h			;5043	ff		.
	rst 38h			;5044	ff		.
	rst 38h			;5045	ff		.
	rst 38h			;5046	ff		.
	rst 38h			;5047	ff		.
	rst 38h			;5048	ff		.
	rst 38h			;5049	ff		.
	rst 38h			;504a	ff		.
	rst 38h			;504b	ff		.
	rst 38h			;504c	ff		.
	rst 38h			;504d	ff		.
	rst 38h			;504e	ff		.
	rst 38h			;504f	ff		.
	rst 38h			;5050	ff		.
	rst 38h			;5051	ff		.
	rst 38h			;5052	ff		.
	rst 38h			;5053	ff		.
	rst 38h			;5054	ff		.
	rst 38h			;5055	ff		.
	rst 38h			;5056	ff		.
	rst 38h			;5057	ff		.
	rst 38h			;5058	ff		.
	rst 38h			;5059	ff		.
	rst 38h			;505a	ff		.
	rst 38h			;505b	ff		.
	rst 38h			;505c	ff		.
	rst 38h			;505d	ff		.
	rst 38h			;505e	ff		.
	rst 38h			;505f	ff		.
	rst 38h			;5060	ff		.
	rst 38h			;5061	ff		.
	rst 38h			;5062	ff		.
	rst 38h			;5063	ff		.
	rst 38h			;5064	ff		.
	rst 38h			;5065	ff		.
	rst 38h			;5066	ff		.
	rst 38h			;5067	ff		.
	rst 38h			;5068	ff		.
	rst 38h			;5069	ff		.
	rst 38h			;506a	ff		.
	rst 38h			;506b	ff		.
	rst 38h			;506c	ff		.
	rst 38h			;506d	ff		.
	rst 38h			;506e	ff		.
	rst 38h			;506f	ff		.
	rst 38h			;5070	ff		.
	rst 38h			;5071	ff		.
	rst 38h			;5072	ff		.
	rst 38h			;5073	ff		.
	rst 38h			;5074	ff		.
	rst 38h			;5075	ff		.
	rst 38h			;5076	ff		.
	rst 38h			;5077	ff		.
	rst 38h			;5078	ff		.
	rst 38h			;5079	ff		.
	rst 38h			;507a	ff		.
	rst 38h			;507b	ff		.
	rst 38h			;507c	ff		.
	rst 38h			;507d	ff		.
	rst 38h			;507e	ff		.
	rst 38h			;507f	ff		.
	rst 38h			;5080	ff		.
	rst 38h			;5081	ff		.
	rst 38h			;5082	ff		.
	rst 38h			;5083	ff		.
	rst 38h			;5084	ff		.
	rst 38h			;5085	ff		.
	rst 38h			;5086	ff		.
	rst 38h			;5087	ff		.
	rst 38h			;5088	ff		.
	rst 38h			;5089	ff		.
	rst 38h			;508a	ff		.
	rst 38h			;508b	ff		.
	rst 38h			;508c	ff		.
	rst 38h			;508d	ff		.
	rst 38h			;508e	ff		.
	rst 38h			;508f	ff		.
	rst 38h			;5090	ff		.
	rst 38h			;5091	ff		.
	rst 38h			;5092	ff		.
	rst 38h			;5093	ff		.
	rst 38h			;5094	ff		.
	rst 38h			;5095	ff		.
	rst 38h			;5096	ff		.
	rst 38h			;5097	ff		.
	rst 38h			;5098	ff		.
	rst 38h			;5099	ff		.
	rst 38h			;509a	ff		.
	rst 38h			;509b	ff		.
	rst 38h			;509c	ff		.
	rst 38h			;509d	ff		.
	rst 38h			;509e	ff		.
	rst 38h			;509f	ff		.
	rst 38h			;50a0	ff		.
	rst 38h			;50a1	ff		.
	rst 38h			;50a2	ff		.
	rst 38h			;50a3	ff		.
	rst 38h			;50a4	ff		.
	rst 38h			;50a5	ff		.
	rst 38h			;50a6	ff		.
	rst 38h			;50a7	ff		.
	rst 38h			;50a8	ff		.
	rst 38h			;50a9	ff		.
	rst 38h			;50aa	ff		.
	rst 38h			;50ab	ff		.
	rst 38h			;50ac	ff		.
	rst 38h			;50ad	ff		.
	rst 38h			;50ae	ff		.
	rst 38h			;50af	ff		.
	rst 38h			;50b0	ff		.
	rst 38h			;50b1	ff		.
	rst 38h			;50b2	ff		.
	rst 38h			;50b3	ff		.
	rst 38h			;50b4	ff		.
	rst 38h			;50b5	ff		.
	rst 38h			;50b6	ff		.
	rst 38h			;50b7	ff		.
	rst 38h			;50b8	ff		.
	rst 38h			;50b9	ff		.
	rst 38h			;50ba	ff		.
	rst 38h			;50bb	ff		.
	rst 38h			;50bc	ff		.
	rst 38h			;50bd	ff		.
	rst 38h			;50be	ff		.
	rst 38h			;50bf	ff		.
	rst 38h			;50c0	ff		.
	rst 38h			;50c1	ff		.
	rst 38h			;50c2	ff		.
	rst 38h			;50c3	ff		.
	rst 38h			;50c4	ff		.
	rst 38h			;50c5	ff		.
	rst 38h			;50c6	ff		.
	rst 38h			;50c7	ff		.
	rst 38h			;50c8	ff		.
	rst 38h			;50c9	ff		.
	rst 38h			;50ca	ff		.
	rst 38h			;50cb	ff		.
	rst 38h			;50cc	ff		.
	rst 38h			;50cd	ff		.
	rst 38h			;50ce	ff		.
	rst 38h			;50cf	ff		.
	rst 38h			;50d0	ff		.
	rst 38h			;50d1	ff		.
	rst 38h			;50d2	ff		.
	rst 38h			;50d3	ff		.
	rst 38h			;50d4	ff		.
	rst 38h			;50d5	ff		.
	rst 38h			;50d6	ff		.
	rst 38h			;50d7	ff		.
	rst 38h			;50d8	ff		.
	rst 38h			;50d9	ff		.
	rst 38h			;50da	ff		.
	rst 38h			;50db	ff		.
	rst 38h			;50dc	ff		.
	rst 38h			;50dd	ff		.
	rst 38h			;50de	ff		.
	rst 38h			;50df	ff		.
	rst 38h			;50e0	ff		.
	rst 38h			;50e1	ff		.
	rst 38h			;50e2	ff		.
	rst 38h			;50e3	ff		.
	rst 38h			;50e4	ff		.
	rst 38h			;50e5	ff		.
	rst 38h			;50e6	ff		.
	rst 38h			;50e7	ff		.
	rst 38h			;50e8	ff		.
	rst 38h			;50e9	ff		.
	rst 38h			;50ea	ff		.
	rst 38h			;50eb	ff		.
	rst 38h			;50ec	ff		.
	rst 38h			;50ed	ff		.
	rst 38h			;50ee	ff		.
	rst 38h			;50ef	ff		.
	rst 38h			;50f0	ff		.
	rst 38h			;50f1	ff		.
	rst 38h			;50f2	ff		.
	rst 38h			;50f3	ff		.
	rst 38h			;50f4	ff		.
	rst 38h			;50f5	ff		.
	rst 38h			;50f6	ff		.
	rst 38h			;50f7	ff		.
	rst 38h			;50f8	ff		.
	rst 38h			;50f9	ff		.
	rst 38h			;50fa	ff		.
	rst 38h			;50fb	ff		.
	rst 38h			;50fc	ff		.
	rst 38h			;50fd	ff		.
	rst 38h			;50fe	ff		.
	rst 38h			;50ff	ff		.
	rst 38h			;5100	ff		.
	rst 38h			;5101	ff		.
	rst 38h			;5102	ff		.
	rst 38h			;5103	ff		.
	rst 38h			;5104	ff		.
	rst 38h			;5105	ff		.
	rst 38h			;5106	ff		.
	rst 38h			;5107	ff		.
	rst 38h			;5108	ff		.
	rst 38h			;5109	ff		.
	rst 38h			;510a	ff		.
	rst 38h			;510b	ff		.
	rst 38h			;510c	ff		.
	rst 38h			;510d	ff		.
	rst 38h			;510e	ff		.
	rst 38h			;510f	ff		.
	rst 38h			;5110	ff		.
	rst 38h			;5111	ff		.
	rst 38h			;5112	ff		.
	rst 38h			;5113	ff		.
	rst 38h			;5114	ff		.
	rst 38h			;5115	ff		.
	rst 38h			;5116	ff		.
	rst 38h			;5117	ff		.
	rst 38h			;5118	ff		.
	rst 38h			;5119	ff		.
	rst 38h			;511a	ff		.
	rst 38h			;511b	ff		.
	rst 38h			;511c	ff		.
	rst 38h			;511d	ff		.
	rst 38h			;511e	ff		.
	rst 38h			;511f	ff		.
	rst 38h			;5120	ff		.
	rst 38h			;5121	ff		.
	rst 38h			;5122	ff		.
	rst 38h			;5123	ff		.
	rst 38h			;5124	ff		.
	rst 38h			;5125	ff		.
	rst 38h			;5126	ff		.
	rst 38h			;5127	ff		.
	rst 38h			;5128	ff		.
	rst 38h			;5129	ff		.
	rst 38h			;512a	ff		.
	rst 38h			;512b	ff		.
	rst 38h			;512c	ff		.
	rst 38h			;512d	ff		.
	rst 38h			;512e	ff		.
	rst 38h			;512f	ff		.
	rst 38h			;5130	ff		.
	rst 38h			;5131	ff		.
	rst 38h			;5132	ff		.
	rst 38h			;5133	ff		.
	rst 38h			;5134	ff		.
	rst 38h			;5135	ff		.
	rst 38h			;5136	ff		.
	rst 38h			;5137	ff		.
	rst 38h			;5138	ff		.
	rst 38h			;5139	ff		.
	rst 38h			;513a	ff		.
	rst 38h			;513b	ff		.
	rst 38h			;513c	ff		.
	rst 38h			;513d	ff		.
	rst 38h			;513e	ff		.
	rst 38h			;513f	ff		.
	rst 38h			;5140	ff		.
	rst 38h			;5141	ff		.
	rst 38h			;5142	ff		.
	rst 38h			;5143	ff		.
	rst 38h			;5144	ff		.
	rst 38h			;5145	ff		.
	rst 38h			;5146	ff		.
	rst 38h			;5147	ff		.
	rst 38h			;5148	ff		.
	rst 38h			;5149	ff		.
	rst 38h			;514a	ff		.
	rst 38h			;514b	ff		.
	rst 38h			;514c	ff		.
	rst 38h			;514d	ff		.
	rst 38h			;514e	ff		.
	rst 38h			;514f	ff		.
	rst 38h			;5150	ff		.
	rst 38h			;5151	ff		.
	rst 38h			;5152	ff		.
	rst 38h			;5153	ff		.
	rst 38h			;5154	ff		.
	rst 38h			;5155	ff		.
	rst 38h			;5156	ff		.
	rst 38h			;5157	ff		.
	rst 38h			;5158	ff		.
	rst 38h			;5159	ff		.
	rst 38h			;515a	ff		.
	rst 38h			;515b	ff		.
	rst 38h			;515c	ff		.
	rst 38h			;515d	ff		.
	rst 38h			;515e	ff		.
	rst 38h			;515f	ff		.
	rst 38h			;5160	ff		.
	rst 38h			;5161	ff		.
	rst 38h			;5162	ff		.
	rst 38h			;5163	ff		.
	rst 38h			;5164	ff		.
	rst 38h			;5165	ff		.
	rst 38h			;5166	ff		.
	rst 38h			;5167	ff		.
	rst 38h			;5168	ff		.
	rst 38h			;5169	ff		.
	rst 38h			;516a	ff		.
	rst 38h			;516b	ff		.
	rst 38h			;516c	ff		.
	rst 38h			;516d	ff		.
	rst 38h			;516e	ff		.
	rst 38h			;516f	ff		.
	rst 38h			;5170	ff		.
	rst 38h			;5171	ff		.
	rst 38h			;5172	ff		.
	rst 38h			;5173	ff		.
	rst 38h			;5174	ff		.
	rst 38h			;5175	ff		.
	rst 38h			;5176	ff		.
	rst 38h			;5177	ff		.
	rst 38h			;5178	ff		.
	rst 38h			;5179	ff		.
	rst 38h			;517a	ff		.
	rst 38h			;517b	ff		.
	rst 38h			;517c	ff		.
	rst 38h			;517d	ff		.
	rst 38h			;517e	ff		.
	rst 38h			;517f	ff		.
	rst 38h			;5180	ff		.
	rst 38h			;5181	ff		.
	rst 38h			;5182	ff		.
	rst 38h			;5183	ff		.
	rst 38h			;5184	ff		.
	rst 38h			;5185	ff		.
	rst 38h			;5186	ff		.
	rst 38h			;5187	ff		.
	rst 38h			;5188	ff		.
	rst 38h			;5189	ff		.
	rst 38h			;518a	ff		.
	rst 38h			;518b	ff		.
	rst 38h			;518c	ff		.
	rst 38h			;518d	ff		.
	rst 38h			;518e	ff		.
	rst 38h			;518f	ff		.
	rst 38h			;5190	ff		.
	rst 38h			;5191	ff		.
	rst 38h			;5192	ff		.
	rst 38h			;5193	ff		.
	rst 38h			;5194	ff		.
	rst 38h			;5195	ff		.
	rst 38h			;5196	ff		.
	rst 38h			;5197	ff		.
	rst 38h			;5198	ff		.
	rst 38h			;5199	ff		.
	rst 38h			;519a	ff		.
	rst 38h			;519b	ff		.
	rst 38h			;519c	ff		.
	rst 38h			;519d	ff		.
	rst 38h			;519e	ff		.
	rst 38h			;519f	ff		.
	rst 38h			;51a0	ff		.
	rst 38h			;51a1	ff		.
	rst 38h			;51a2	ff		.
	rst 38h			;51a3	ff		.
	rst 38h			;51a4	ff		.
	rst 38h			;51a5	ff		.
	rst 38h			;51a6	ff		.
	rst 38h			;51a7	ff		.
	rst 38h			;51a8	ff		.
	rst 38h			;51a9	ff		.
	rst 38h			;51aa	ff		.
	rst 38h			;51ab	ff		.
	rst 38h			;51ac	ff		.
	rst 38h			;51ad	ff		.
	rst 38h			;51ae	ff		.
	rst 38h			;51af	ff		.
	rst 38h			;51b0	ff		.
	rst 38h			;51b1	ff		.
	rst 38h			;51b2	ff		.
	rst 38h			;51b3	ff		.
	rst 38h			;51b4	ff		.
	rst 38h			;51b5	ff		.
	rst 38h			;51b6	ff		.
	rst 38h			;51b7	ff		.
	rst 38h			;51b8	ff		.
	rst 38h			;51b9	ff		.
	rst 38h			;51ba	ff		.
	rst 38h			;51bb	ff		.
	rst 38h			;51bc	ff		.
	rst 38h			;51bd	ff		.
	rst 38h			;51be	ff		.
	rst 38h			;51bf	ff		.
	rst 38h			;51c0	ff		.
	rst 38h			;51c1	ff		.
	rst 38h			;51c2	ff		.
	rst 38h			;51c3	ff		.
	rst 38h			;51c4	ff		.
	rst 38h			;51c5	ff		.
	rst 38h			;51c6	ff		.
	rst 38h			;51c7	ff		.
	rst 38h			;51c8	ff		.
	rst 38h			;51c9	ff		.
	rst 38h			;51ca	ff		.
	rst 38h			;51cb	ff		.
	rst 38h			;51cc	ff		.
	rst 38h			;51cd	ff		.
	rst 38h			;51ce	ff		.
	rst 38h			;51cf	ff		.
	rst 38h			;51d0	ff		.
	rst 38h			;51d1	ff		.
	rst 38h			;51d2	ff		.
	rst 38h			;51d3	ff		.
	rst 38h			;51d4	ff		.
	rst 38h			;51d5	ff		.
	rst 38h			;51d6	ff		.
	rst 38h			;51d7	ff		.
	rst 38h			;51d8	ff		.
	rst 38h			;51d9	ff		.
	rst 38h			;51da	ff		.
	rst 38h			;51db	ff		.
	rst 38h			;51dc	ff		.
	rst 38h			;51dd	ff		.
	rst 38h			;51de	ff		.
	rst 38h			;51df	ff		.
	rst 38h			;51e0	ff		.
	rst 38h			;51e1	ff		.
	rst 38h			;51e2	ff		.
	rst 38h			;51e3	ff		.
	rst 38h			;51e4	ff		.
	rst 38h			;51e5	ff		.
	rst 38h			;51e6	ff		.
	rst 38h			;51e7	ff		.
	rst 38h			;51e8	ff		.
	rst 38h			;51e9	ff		.
	rst 38h			;51ea	ff		.
	rst 38h			;51eb	ff		.
	rst 38h			;51ec	ff		.
	rst 38h			;51ed	ff		.
	rst 38h			;51ee	ff		.
	rst 38h			;51ef	ff		.
	rst 38h			;51f0	ff		.
	rst 38h			;51f1	ff		.
	rst 38h			;51f2	ff		.
	rst 38h			;51f3	ff		.
	rst 38h			;51f4	ff		.
	rst 38h			;51f5	ff		.
	rst 38h			;51f6	ff		.
	rst 38h			;51f7	ff		.
	rst 38h			;51f8	ff		.
	rst 38h			;51f9	ff		.
	rst 38h			;51fa	ff		.
	rst 38h			;51fb	ff		.
	rst 38h			;51fc	ff		.
	rst 38h			;51fd	ff		.
	rst 38h			;51fe	ff		.
	rst 38h			;51ff	ff		.
	rst 38h			;5200	ff		.
	rst 38h			;5201	ff		.
	rst 38h			;5202	ff		.
	rst 38h			;5203	ff		.
	rst 38h			;5204	ff		.
	rst 38h			;5205	ff		.
	rst 38h			;5206	ff		.
	rst 38h			;5207	ff		.
	rst 38h			;5208	ff		.
	rst 38h			;5209	ff		.
	rst 38h			;520a	ff		.
	rst 38h			;520b	ff		.
	rst 38h			;520c	ff		.
	rst 38h			;520d	ff		.
	rst 38h			;520e	ff		.
	rst 38h			;520f	ff		.
	rst 38h			;5210	ff		.
	rst 38h			;5211	ff		.
	rst 38h			;5212	ff		.
	rst 38h			;5213	ff		.
	rst 38h			;5214	ff		.
	rst 38h			;5215	ff		.
	rst 38h			;5216	ff		.
	rst 38h			;5217	ff		.
	rst 38h			;5218	ff		.
	rst 38h			;5219	ff		.
	rst 38h			;521a	ff		.
	rst 38h			;521b	ff		.
	rst 38h			;521c	ff		.
	rst 38h			;521d	ff		.
	rst 38h			;521e	ff		.
	rst 38h			;521f	ff		.
	rst 38h			;5220	ff		.
	rst 38h			;5221	ff		.
	rst 38h			;5222	ff		.
	rst 38h			;5223	ff		.
	rst 38h			;5224	ff		.
	rst 38h			;5225	ff		.
	rst 38h			;5226	ff		.
	rst 38h			;5227	ff		.
	rst 38h			;5228	ff		.
	rst 38h			;5229	ff		.
	rst 38h			;522a	ff		.
	rst 38h			;522b	ff		.
	rst 38h			;522c	ff		.
	rst 38h			;522d	ff		.
	rst 38h			;522e	ff		.
	rst 38h			;522f	ff		.
	rst 38h			;5230	ff		.
	rst 38h			;5231	ff		.
	rst 38h			;5232	ff		.
	rst 38h			;5233	ff		.
	rst 38h			;5234	ff		.
	rst 38h			;5235	ff		.
	rst 38h			;5236	ff		.
	rst 38h			;5237	ff		.
	rst 38h			;5238	ff		.
	rst 38h			;5239	ff		.
	rst 38h			;523a	ff		.
	rst 38h			;523b	ff		.
	rst 38h			;523c	ff		.
	rst 38h			;523d	ff		.
	rst 38h			;523e	ff		.
	rst 38h			;523f	ff		.
	rst 38h			;5240	ff		.
	rst 38h			;5241	ff		.
	rst 38h			;5242	ff		.
	rst 38h			;5243	ff		.
	rst 38h			;5244	ff		.
	rst 38h			;5245	ff		.
	rst 38h			;5246	ff		.
	rst 38h			;5247	ff		.
	rst 38h			;5248	ff		.
	rst 38h			;5249	ff		.
	rst 38h			;524a	ff		.
	rst 38h			;524b	ff		.
	rst 38h			;524c	ff		.
	rst 38h			;524d	ff		.
	rst 38h			;524e	ff		.
	rst 38h			;524f	ff		.
	rst 38h			;5250	ff		.
	rst 38h			;5251	ff		.
	rst 38h			;5252	ff		.
	rst 38h			;5253	ff		.
	rst 38h			;5254	ff		.
	rst 38h			;5255	ff		.
	rst 38h			;5256	ff		.
	rst 38h			;5257	ff		.
	rst 38h			;5258	ff		.
	rst 38h			;5259	ff		.
	rst 38h			;525a	ff		.
	rst 38h			;525b	ff		.
	rst 38h			;525c	ff		.
	rst 38h			;525d	ff		.
	rst 38h			;525e	ff		.
	rst 38h			;525f	ff		.
	rst 38h			;5260	ff		.
	rst 38h			;5261	ff		.
	rst 38h			;5262	ff		.
	rst 38h			;5263	ff		.
	rst 38h			;5264	ff		.
	rst 38h			;5265	ff		.
	rst 38h			;5266	ff		.
	rst 38h			;5267	ff		.
	rst 38h			;5268	ff		.
	rst 38h			;5269	ff		.
	rst 38h			;526a	ff		.
	rst 38h			;526b	ff		.
	rst 38h			;526c	ff		.
	rst 38h			;526d	ff		.
	rst 38h			;526e	ff		.
	rst 38h			;526f	ff		.
	rst 38h			;5270	ff		.
	rst 38h			;5271	ff		.
	rst 38h			;5272	ff		.
	rst 38h			;5273	ff		.
	rst 38h			;5274	ff		.
	rst 38h			;5275	ff		.
	rst 38h			;5276	ff		.
	rst 38h			;5277	ff		.
	rst 38h			;5278	ff		.
	rst 38h			;5279	ff		.
	rst 38h			;527a	ff		.
	rst 38h			;527b	ff		.
	rst 38h			;527c	ff		.
	rst 38h			;527d	ff		.
	rst 38h			;527e	ff		.
	rst 38h			;527f	ff		.
	rst 38h			;5280	ff		.
	rst 38h			;5281	ff		.
	rst 38h			;5282	ff		.
	rst 38h			;5283	ff		.
	rst 38h			;5284	ff		.
	rst 38h			;5285	ff		.
	rst 38h			;5286	ff		.
	rst 38h			;5287	ff		.
	rst 38h			;5288	ff		.
	rst 38h			;5289	ff		.
	rst 38h			;528a	ff		.
	rst 38h			;528b	ff		.
	rst 38h			;528c	ff		.
	rst 38h			;528d	ff		.
	rst 38h			;528e	ff		.
	rst 38h			;528f	ff		.
	rst 38h			;5290	ff		.
	rst 38h			;5291	ff		.
	rst 38h			;5292	ff		.
	rst 38h			;5293	ff		.
	rst 38h			;5294	ff		.
	rst 38h			;5295	ff		.
	rst 38h			;5296	ff		.
	rst 38h			;5297	ff		.
	rst 38h			;5298	ff		.
	rst 38h			;5299	ff		.
	rst 38h			;529a	ff		.
	rst 38h			;529b	ff		.
	rst 38h			;529c	ff		.
	rst 38h			;529d	ff		.
	rst 38h			;529e	ff		.
	rst 38h			;529f	ff		.
	rst 38h			;52a0	ff		.
	rst 38h			;52a1	ff		.
	rst 38h			;52a2	ff		.
	rst 38h			;52a3	ff		.
	rst 38h			;52a4	ff		.
	rst 38h			;52a5	ff		.
	rst 38h			;52a6	ff		.
	rst 38h			;52a7	ff		.
	rst 38h			;52a8	ff		.
	rst 38h			;52a9	ff		.
	rst 38h			;52aa	ff		.
	rst 38h			;52ab	ff		.
	rst 38h			;52ac	ff		.
	rst 38h			;52ad	ff		.
	rst 38h			;52ae	ff		.
	rst 38h			;52af	ff		.
	rst 38h			;52b0	ff		.
	rst 38h			;52b1	ff		.
	rst 38h			;52b2	ff		.
	rst 38h			;52b3	ff		.
	rst 38h			;52b4	ff		.
	rst 38h			;52b5	ff		.
	rst 38h			;52b6	ff		.
	rst 38h			;52b7	ff		.
	rst 38h			;52b8	ff		.
	rst 38h			;52b9	ff		.
	rst 38h			;52ba	ff		.
	rst 38h			;52bb	ff		.
	rst 38h			;52bc	ff		.
	rst 38h			;52bd	ff		.
	rst 38h			;52be	ff		.
	rst 38h			;52bf	ff		.
	rst 38h			;52c0	ff		.
	rst 38h			;52c1	ff		.
	rst 38h			;52c2	ff		.
	rst 38h			;52c3	ff		.
	rst 38h			;52c4	ff		.
	rst 38h			;52c5	ff		.
	rst 38h			;52c6	ff		.
	rst 38h			;52c7	ff		.
	rst 38h			;52c8	ff		.
	rst 38h			;52c9	ff		.
	rst 38h			;52ca	ff		.
	rst 38h			;52cb	ff		.
	rst 38h			;52cc	ff		.
	rst 38h			;52cd	ff		.
	rst 38h			;52ce	ff		.
	rst 38h			;52cf	ff		.
	rst 38h			;52d0	ff		.
	rst 38h			;52d1	ff		.
	rst 38h			;52d2	ff		.
	rst 38h			;52d3	ff		.
	rst 38h			;52d4	ff		.
	rst 38h			;52d5	ff		.
	rst 38h			;52d6	ff		.
	rst 38h			;52d7	ff		.
	rst 38h			;52d8	ff		.
	rst 38h			;52d9	ff		.
	rst 38h			;52da	ff		.
	rst 38h			;52db	ff		.
	rst 38h			;52dc	ff		.
	rst 38h			;52dd	ff		.
	rst 38h			;52de	ff		.
	rst 38h			;52df	ff		.
	rst 38h			;52e0	ff		.
	rst 38h			;52e1	ff		.
	rst 38h			;52e2	ff		.
	rst 38h			;52e3	ff		.
	rst 38h			;52e4	ff		.
	rst 38h			;52e5	ff		.
	rst 38h			;52e6	ff		.
	rst 38h			;52e7	ff		.
	rst 38h			;52e8	ff		.
	rst 38h			;52e9	ff		.
	rst 38h			;52ea	ff		.
	rst 38h			;52eb	ff		.
	rst 38h			;52ec	ff		.
	rst 38h			;52ed	ff		.
	rst 38h			;52ee	ff		.
	rst 38h			;52ef	ff		.
	rst 38h			;52f0	ff		.
	rst 38h			;52f1	ff		.
	rst 38h			;52f2	ff		.
	rst 38h			;52f3	ff		.
	rst 38h			;52f4	ff		.
	rst 38h			;52f5	ff		.
	rst 38h			;52f6	ff		.
	rst 38h			;52f7	ff		.
	rst 38h			;52f8	ff		.
	rst 38h			;52f9	ff		.
	rst 38h			;52fa	ff		.
	rst 38h			;52fb	ff		.
	rst 38h			;52fc	ff		.
	rst 38h			;52fd	ff		.
	rst 38h			;52fe	ff		.
	rst 38h			;52ff	ff		.
	rst 38h			;5300	ff		.
	rst 38h			;5301	ff		.
	rst 38h			;5302	ff		.
	rst 38h			;5303	ff		.
	rst 38h			;5304	ff		.
	rst 38h			;5305	ff		.
	rst 38h			;5306	ff		.
	rst 38h			;5307	ff		.
	rst 38h			;5308	ff		.
	rst 38h			;5309	ff		.
	rst 38h			;530a	ff		.
	rst 38h			;530b	ff		.
	rst 38h			;530c	ff		.
	rst 38h			;530d	ff		.
	rst 38h			;530e	ff		.
	rst 38h			;530f	ff		.
	rst 38h			;5310	ff		.
	rst 38h			;5311	ff		.
	rst 38h			;5312	ff		.
	rst 38h			;5313	ff		.
	rst 38h			;5314	ff		.
	rst 38h			;5315	ff		.
	rst 38h			;5316	ff		.
	rst 38h			;5317	ff		.
	rst 38h			;5318	ff		.
	rst 38h			;5319	ff		.
	rst 38h			;531a	ff		.
	rst 38h			;531b	ff		.
	rst 38h			;531c	ff		.
	rst 38h			;531d	ff		.
	rst 38h			;531e	ff		.
	rst 38h			;531f	ff		.
	rst 38h			;5320	ff		.
	rst 38h			;5321	ff		.
	rst 38h			;5322	ff		.
	rst 38h			;5323	ff		.
	rst 38h			;5324	ff		.
	rst 38h			;5325	ff		.
	rst 38h			;5326	ff		.
	rst 38h			;5327	ff		.
	rst 38h			;5328	ff		.
	rst 38h			;5329	ff		.
	rst 38h			;532a	ff		.
	rst 38h			;532b	ff		.
	rst 38h			;532c	ff		.
	rst 38h			;532d	ff		.
	rst 38h			;532e	ff		.
	rst 38h			;532f	ff		.
	rst 38h			;5330	ff		.
	rst 38h			;5331	ff		.
	rst 38h			;5332	ff		.
	rst 38h			;5333	ff		.
	rst 38h			;5334	ff		.
	rst 38h			;5335	ff		.
	rst 38h			;5336	ff		.
	rst 38h			;5337	ff		.
	rst 38h			;5338	ff		.
	rst 38h			;5339	ff		.
	rst 38h			;533a	ff		.
	rst 38h			;533b	ff		.
	rst 38h			;533c	ff		.
	rst 38h			;533d	ff		.
	rst 38h			;533e	ff		.
	rst 38h			;533f	ff		.
	rst 38h			;5340	ff		.
	rst 38h			;5341	ff		.
	rst 38h			;5342	ff		.
	rst 38h			;5343	ff		.
	rst 38h			;5344	ff		.
	rst 38h			;5345	ff		.
	rst 38h			;5346	ff		.
	rst 38h			;5347	ff		.
	rst 38h			;5348	ff		.
	rst 38h			;5349	ff		.
	rst 38h			;534a	ff		.
	rst 38h			;534b	ff		.
	rst 38h			;534c	ff		.
	rst 38h			;534d	ff		.
	rst 38h			;534e	ff		.
	rst 38h			;534f	ff		.
	rst 38h			;5350	ff		.
	rst 38h			;5351	ff		.
	rst 38h			;5352	ff		.
	rst 38h			;5353	ff		.
	rst 38h			;5354	ff		.
	rst 38h			;5355	ff		.
	rst 38h			;5356	ff		.
	rst 38h			;5357	ff		.
	rst 38h			;5358	ff		.
	rst 38h			;5359	ff		.
	rst 38h			;535a	ff		.
	rst 38h			;535b	ff		.
	rst 38h			;535c	ff		.
	rst 38h			;535d	ff		.
	rst 38h			;535e	ff		.
	rst 38h			;535f	ff		.
	rst 38h			;5360	ff		.
	rst 38h			;5361	ff		.
	rst 38h			;5362	ff		.
	rst 38h			;5363	ff		.
	rst 38h			;5364	ff		.
	rst 38h			;5365	ff		.
	rst 38h			;5366	ff		.
	rst 38h			;5367	ff		.
	rst 38h			;5368	ff		.
	rst 38h			;5369	ff		.
	rst 38h			;536a	ff		.
	rst 38h			;536b	ff		.
	rst 38h			;536c	ff		.
	rst 38h			;536d	ff		.
	rst 38h			;536e	ff		.
	rst 38h			;536f	ff		.
	rst 38h			;5370	ff		.
	rst 38h			;5371	ff		.
	rst 38h			;5372	ff		.
	rst 38h			;5373	ff		.
	rst 38h			;5374	ff		.
	rst 38h			;5375	ff		.
	rst 38h			;5376	ff		.
	rst 38h			;5377	ff		.
	rst 38h			;5378	ff		.
	rst 38h			;5379	ff		.
	rst 38h			;537a	ff		.
	rst 38h			;537b	ff		.
	rst 38h			;537c	ff		.
	rst 38h			;537d	ff		.
	rst 38h			;537e	ff		.
	rst 38h			;537f	ff		.
	rst 38h			;5380	ff		.
	rst 38h			;5381	ff		.
	rst 38h			;5382	ff		.
	rst 38h			;5383	ff		.
	rst 38h			;5384	ff		.
	rst 38h			;5385	ff		.
	rst 38h			;5386	ff		.
	rst 38h			;5387	ff		.
	rst 38h			;5388	ff		.
	rst 38h			;5389	ff		.
	rst 38h			;538a	ff		.
	rst 38h			;538b	ff		.
	rst 38h			;538c	ff		.
	rst 38h			;538d	ff		.
	rst 38h			;538e	ff		.
	rst 38h			;538f	ff		.
	rst 38h			;5390	ff		.
	rst 38h			;5391	ff		.
	rst 38h			;5392	ff		.
	rst 38h			;5393	ff		.
	rst 38h			;5394	ff		.
	rst 38h			;5395	ff		.
	rst 38h			;5396	ff		.
	rst 38h			;5397	ff		.
	rst 38h			;5398	ff		.
	rst 38h			;5399	ff		.
	rst 38h			;539a	ff		.
	rst 38h			;539b	ff		.
	rst 38h			;539c	ff		.
	rst 38h			;539d	ff		.
	rst 38h			;539e	ff		.
	rst 38h			;539f	ff		.
	rst 38h			;53a0	ff		.
	rst 38h			;53a1	ff		.
	rst 38h			;53a2	ff		.
	rst 38h			;53a3	ff		.
	rst 38h			;53a4	ff		.
	rst 38h			;53a5	ff		.
	rst 38h			;53a6	ff		.
	rst 38h			;53a7	ff		.
	rst 38h			;53a8	ff		.
	rst 38h			;53a9	ff		.
	rst 38h			;53aa	ff		.
	rst 38h			;53ab	ff		.
	rst 38h			;53ac	ff		.
	rst 38h			;53ad	ff		.
	rst 38h			;53ae	ff		.
	rst 38h			;53af	ff		.
	rst 38h			;53b0	ff		.
	rst 38h			;53b1	ff		.
	rst 38h			;53b2	ff		.
	rst 38h			;53b3	ff		.
	rst 38h			;53b4	ff		.
	rst 38h			;53b5	ff		.
	rst 38h			;53b6	ff		.
	rst 38h			;53b7	ff		.
	rst 38h			;53b8	ff		.
	rst 38h			;53b9	ff		.
	rst 38h			;53ba	ff		.
	rst 38h			;53bb	ff		.
	rst 38h			;53bc	ff		.
	rst 38h			;53bd	ff		.
	rst 38h			;53be	ff		.
	rst 38h			;53bf	ff		.
	rst 38h			;53c0	ff		.
	rst 38h			;53c1	ff		.
	rst 38h			;53c2	ff		.
	rst 38h			;53c3	ff		.
	rst 38h			;53c4	ff		.
	rst 38h			;53c5	ff		.
	rst 38h			;53c6	ff		.
	rst 38h			;53c7	ff		.
	rst 38h			;53c8	ff		.
	rst 38h			;53c9	ff		.
	rst 38h			;53ca	ff		.
	rst 38h			;53cb	ff		.
	rst 38h			;53cc	ff		.
	rst 38h			;53cd	ff		.
	rst 38h			;53ce	ff		.
	rst 38h			;53cf	ff		.
	rst 38h			;53d0	ff		.
	rst 38h			;53d1	ff		.
	rst 38h			;53d2	ff		.
	rst 38h			;53d3	ff		.
	rst 38h			;53d4	ff		.
	rst 38h			;53d5	ff		.
	rst 38h			;53d6	ff		.
	rst 38h			;53d7	ff		.
	rst 38h			;53d8	ff		.
	rst 38h			;53d9	ff		.
	rst 38h			;53da	ff		.
	rst 38h			;53db	ff		.
	rst 38h			;53dc	ff		.
	rst 38h			;53dd	ff		.
	rst 38h			;53de	ff		.
	rst 38h			;53df	ff		.
	rst 38h			;53e0	ff		.
	rst 38h			;53e1	ff		.
	rst 38h			;53e2	ff		.
	rst 38h			;53e3	ff		.
	rst 38h			;53e4	ff		.
	rst 38h			;53e5	ff		.
	rst 38h			;53e6	ff		.
	rst 38h			;53e7	ff		.
	rst 38h			;53e8	ff		.
	rst 38h			;53e9	ff		.
	rst 38h			;53ea	ff		.
	rst 38h			;53eb	ff		.
	rst 38h			;53ec	ff		.
	rst 38h			;53ed	ff		.
	rst 38h			;53ee	ff		.
	rst 38h			;53ef	ff		.
	rst 38h			;53f0	ff		.
	rst 38h			;53f1	ff		.
	rst 38h			;53f2	ff		.
	rst 38h			;53f3	ff		.
	rst 38h			;53f4	ff		.
	rst 38h			;53f5	ff		.
	rst 38h			;53f6	ff		.
	rst 38h			;53f7	ff		.
	rst 38h			;53f8	ff		.
	rst 38h			;53f9	ff		.
	rst 38h			;53fa	ff		.
	rst 38h			;53fb	ff		.
	rst 38h			;53fc	ff		.
	rst 38h			;53fd	ff		.
	rst 38h			;53fe	ff		.
	rst 38h			;53ff	ff		.
	rst 38h			;5400	ff		.
	rst 38h			;5401	ff		.
	rst 38h			;5402	ff		.
	rst 38h			;5403	ff		.
	rst 38h			;5404	ff		.
	rst 38h			;5405	ff		.
	rst 38h			;5406	ff		.
	rst 38h			;5407	ff		.
	rst 38h			;5408	ff		.
	rst 38h			;5409	ff		.
	rst 38h			;540a	ff		.
	rst 38h			;540b	ff		.
	rst 38h			;540c	ff		.
	rst 38h			;540d	ff		.
	rst 38h			;540e	ff		.
	rst 38h			;540f	ff		.
	rst 38h			;5410	ff		.
	rst 38h			;5411	ff		.
	rst 38h			;5412	ff		.
	rst 38h			;5413	ff		.
	rst 38h			;5414	ff		.
	rst 38h			;5415	ff		.
	rst 38h			;5416	ff		.
	rst 38h			;5417	ff		.
	rst 38h			;5418	ff		.
	rst 38h			;5419	ff		.
	rst 38h			;541a	ff		.
	rst 38h			;541b	ff		.
	rst 38h			;541c	ff		.
	rst 38h			;541d	ff		.
	rst 38h			;541e	ff		.
	rst 38h			;541f	ff		.
	rst 38h			;5420	ff		.
	rst 38h			;5421	ff		.
	rst 38h			;5422	ff		.
	rst 38h			;5423	ff		.
	rst 38h			;5424	ff		.
	rst 38h			;5425	ff		.
	rst 38h			;5426	ff		.
	rst 38h			;5427	ff		.
	rst 38h			;5428	ff		.
	rst 38h			;5429	ff		.
	rst 38h			;542a	ff		.
	rst 38h			;542b	ff		.
	rst 38h			;542c	ff		.
	rst 38h			;542d	ff		.
	rst 38h			;542e	ff		.
	rst 38h			;542f	ff		.
	rst 38h			;5430	ff		.
	rst 38h			;5431	ff		.
	rst 38h			;5432	ff		.
	rst 38h			;5433	ff		.
	rst 38h			;5434	ff		.
	rst 38h			;5435	ff		.
	rst 38h			;5436	ff		.
	rst 38h			;5437	ff		.
	rst 38h			;5438	ff		.
	rst 38h			;5439	ff		.
	rst 38h			;543a	ff		.
	rst 38h			;543b	ff		.
	rst 38h			;543c	ff		.
	rst 38h			;543d	ff		.
	rst 38h			;543e	ff		.
	rst 38h			;543f	ff		.
	rst 38h			;5440	ff		.
	rst 38h			;5441	ff		.
	rst 38h			;5442	ff		.
	rst 38h			;5443	ff		.
	rst 38h			;5444	ff		.
	rst 38h			;5445	ff		.
	rst 38h			;5446	ff		.
	rst 38h			;5447	ff		.
	rst 38h			;5448	ff		.
	rst 38h			;5449	ff		.
	rst 38h			;544a	ff		.
	rst 38h			;544b	ff		.
	rst 38h			;544c	ff		.
	rst 38h			;544d	ff		.
	rst 38h			;544e	ff		.
	rst 38h			;544f	ff		.
	rst 38h			;5450	ff		.
	rst 38h			;5451	ff		.
	rst 38h			;5452	ff		.
	rst 38h			;5453	ff		.
	rst 38h			;5454	ff		.
	rst 38h			;5455	ff		.
	rst 38h			;5456	ff		.
	rst 38h			;5457	ff		.
	rst 38h			;5458	ff		.
	rst 38h			;5459	ff		.
	rst 38h			;545a	ff		.
	rst 38h			;545b	ff		.
	rst 38h			;545c	ff		.
	rst 38h			;545d	ff		.
	rst 38h			;545e	ff		.
	rst 38h			;545f	ff		.
	rst 38h			;5460	ff		.
	rst 38h			;5461	ff		.
	rst 38h			;5462	ff		.
	rst 38h			;5463	ff		.
	rst 38h			;5464	ff		.
	rst 38h			;5465	ff		.
	rst 38h			;5466	ff		.
	rst 38h			;5467	ff		.
	rst 38h			;5468	ff		.
	rst 38h			;5469	ff		.
	rst 38h			;546a	ff		.
	rst 38h			;546b	ff		.
	rst 38h			;546c	ff		.
	rst 38h			;546d	ff		.
	rst 38h			;546e	ff		.
	rst 38h			;546f	ff		.
	rst 38h			;5470	ff		.
	rst 38h			;5471	ff		.
	rst 38h			;5472	ff		.
	rst 38h			;5473	ff		.
	rst 38h			;5474	ff		.
	rst 38h			;5475	ff		.
	rst 38h			;5476	ff		.
	rst 38h			;5477	ff		.
	rst 38h			;5478	ff		.
	rst 38h			;5479	ff		.
	rst 38h			;547a	ff		.
	rst 38h			;547b	ff		.
	rst 38h			;547c	ff		.
	rst 38h			;547d	ff		.
	rst 38h			;547e	ff		.
	rst 38h			;547f	ff		.
	rst 38h			;5480	ff		.
	rst 38h			;5481	ff		.
	rst 38h			;5482	ff		.
	rst 38h			;5483	ff		.
	rst 38h			;5484	ff		.
	rst 38h			;5485	ff		.
	rst 38h			;5486	ff		.
	rst 38h			;5487	ff		.
	rst 38h			;5488	ff		.
	rst 38h			;5489	ff		.
	rst 38h			;548a	ff		.
	rst 38h			;548b	ff		.
	rst 38h			;548c	ff		.
	rst 38h			;548d	ff		.
	rst 38h			;548e	ff		.
	rst 38h			;548f	ff		.
	rst 38h			;5490	ff		.
	rst 38h			;5491	ff		.
	rst 38h			;5492	ff		.
	rst 38h			;5493	ff		.
	rst 38h			;5494	ff		.
	rst 38h			;5495	ff		.
	rst 38h			;5496	ff		.
	rst 38h			;5497	ff		.
	rst 38h			;5498	ff		.
	rst 38h			;5499	ff		.
	rst 38h			;549a	ff		.
	rst 38h			;549b	ff		.
	rst 38h			;549c	ff		.
	rst 38h			;549d	ff		.
	rst 38h			;549e	ff		.
	rst 38h			;549f	ff		.
	rst 38h			;54a0	ff		.
	rst 38h			;54a1	ff		.
	rst 38h			;54a2	ff		.
	rst 38h			;54a3	ff		.
	rst 38h			;54a4	ff		.
	rst 38h			;54a5	ff		.
	rst 38h			;54a6	ff		.
	rst 38h			;54a7	ff		.
	rst 38h			;54a8	ff		.
	rst 38h			;54a9	ff		.
	rst 38h			;54aa	ff		.
	rst 38h			;54ab	ff		.
	rst 38h			;54ac	ff		.
	rst 38h			;54ad	ff		.
	rst 38h			;54ae	ff		.
	rst 38h			;54af	ff		.
	rst 38h			;54b0	ff		.
	rst 38h			;54b1	ff		.
	rst 38h			;54b2	ff		.
	rst 38h			;54b3	ff		.
	rst 38h			;54b4	ff		.
	rst 38h			;54b5	ff		.
	rst 38h			;54b6	ff		.
	rst 38h			;54b7	ff		.
	rst 38h			;54b8	ff		.
	rst 38h			;54b9	ff		.
	rst 38h			;54ba	ff		.
	rst 38h			;54bb	ff		.
	rst 38h			;54bc	ff		.
	rst 38h			;54bd	ff		.
	rst 38h			;54be	ff		.
	rst 38h			;54bf	ff		.
	rst 38h			;54c0	ff		.
	rst 38h			;54c1	ff		.
	rst 38h			;54c2	ff		.
	rst 38h			;54c3	ff		.
	rst 38h			;54c4	ff		.
	rst 38h			;54c5	ff		.
	rst 38h			;54c6	ff		.
	rst 38h			;54c7	ff		.
	rst 38h			;54c8	ff		.
	rst 38h			;54c9	ff		.
	rst 38h			;54ca	ff		.
	rst 38h			;54cb	ff		.
	rst 38h			;54cc	ff		.
	rst 38h			;54cd	ff		.
	rst 38h			;54ce	ff		.
	rst 38h			;54cf	ff		.
	rst 38h			;54d0	ff		.
	rst 38h			;54d1	ff		.
	rst 38h			;54d2	ff		.
	rst 38h			;54d3	ff		.
	rst 38h			;54d4	ff		.
	rst 38h			;54d5	ff		.
	rst 38h			;54d6	ff		.
	rst 38h			;54d7	ff		.
	rst 38h			;54d8	ff		.
	rst 38h			;54d9	ff		.
	rst 38h			;54da	ff		.
	rst 38h			;54db	ff		.
	rst 38h			;54dc	ff		.
	rst 38h			;54dd	ff		.
	rst 38h			;54de	ff		.
	rst 38h			;54df	ff		.
	rst 38h			;54e0	ff		.
	rst 38h			;54e1	ff		.
	rst 38h			;54e2	ff		.
	rst 38h			;54e3	ff		.
	rst 38h			;54e4	ff		.
	rst 38h			;54e5	ff		.
	rst 38h			;54e6	ff		.
	rst 38h			;54e7	ff		.
	rst 38h			;54e8	ff		.
	rst 38h			;54e9	ff		.
	rst 38h			;54ea	ff		.
	rst 38h			;54eb	ff		.
	rst 38h			;54ec	ff		.
	rst 38h			;54ed	ff		.
	rst 38h			;54ee	ff		.
	rst 38h			;54ef	ff		.
	rst 38h			;54f0	ff		.
	rst 38h			;54f1	ff		.
	rst 38h			;54f2	ff		.
	rst 38h			;54f3	ff		.
	rst 38h			;54f4	ff		.
	rst 38h			;54f5	ff		.
	rst 38h			;54f6	ff		.
	rst 38h			;54f7	ff		.
	rst 38h			;54f8	ff		.
	rst 38h			;54f9	ff		.
	rst 38h			;54fa	ff		.
	rst 38h			;54fb	ff		.
	rst 38h			;54fc	ff		.
	rst 38h			;54fd	ff		.
	rst 38h			;54fe	ff		.
	rst 38h			;54ff	ff		.
	rst 38h			;5500	ff		.
	rst 38h			;5501	ff		.
	rst 38h			;5502	ff		.
	rst 38h			;5503	ff		.
	rst 38h			;5504	ff		.
	rst 38h			;5505	ff		.
	rst 38h			;5506	ff		.
	rst 38h			;5507	ff		.
	rst 38h			;5508	ff		.
	rst 38h			;5509	ff		.
	rst 38h			;550a	ff		.
	rst 38h			;550b	ff		.
	rst 38h			;550c	ff		.
	rst 38h			;550d	ff		.
	rst 38h			;550e	ff		.
	rst 38h			;550f	ff		.
	rst 38h			;5510	ff		.
	rst 38h			;5511	ff		.
	rst 38h			;5512	ff		.
	rst 38h			;5513	ff		.
	rst 38h			;5514	ff		.
	rst 38h			;5515	ff		.
	rst 38h			;5516	ff		.
	rst 38h			;5517	ff		.
	rst 38h			;5518	ff		.
	rst 38h			;5519	ff		.
	rst 38h			;551a	ff		.
	rst 38h			;551b	ff		.
	rst 38h			;551c	ff		.
	rst 38h			;551d	ff		.
	rst 38h			;551e	ff		.
	rst 38h			;551f	ff		.
	rst 38h			;5520	ff		.
	rst 38h			;5521	ff		.
	rst 38h			;5522	ff		.
	rst 38h			;5523	ff		.
	rst 38h			;5524	ff		.
	rst 38h			;5525	ff		.
	rst 38h			;5526	ff		.
	rst 38h			;5527	ff		.
	rst 38h			;5528	ff		.
	rst 38h			;5529	ff		.
	rst 38h			;552a	ff		.
	rst 38h			;552b	ff		.
	rst 38h			;552c	ff		.
	rst 38h			;552d	ff		.
	rst 38h			;552e	ff		.
	rst 38h			;552f	ff		.
	rst 38h			;5530	ff		.
	rst 38h			;5531	ff		.
	rst 38h			;5532	ff		.
	rst 38h			;5533	ff		.
	rst 38h			;5534	ff		.
	rst 38h			;5535	ff		.
	rst 38h			;5536	ff		.
	rst 38h			;5537	ff		.
	rst 38h			;5538	ff		.
	rst 38h			;5539	ff		.
	rst 38h			;553a	ff		.
	rst 38h			;553b	ff		.
	rst 38h			;553c	ff		.
	rst 38h			;553d	ff		.
	rst 38h			;553e	ff		.
	rst 38h			;553f	ff		.
	rst 38h			;5540	ff		.
	rst 38h			;5541	ff		.
	rst 38h			;5542	ff		.
	rst 38h			;5543	ff		.
	rst 38h			;5544	ff		.
	rst 38h			;5545	ff		.
	rst 38h			;5546	ff		.
	rst 38h			;5547	ff		.
	rst 38h			;5548	ff		.
	rst 38h			;5549	ff		.
	rst 38h			;554a	ff		.
	rst 38h			;554b	ff		.
	rst 38h			;554c	ff		.
	rst 38h			;554d	ff		.
	rst 38h			;554e	ff		.
	rst 38h			;554f	ff		.
	rst 38h			;5550	ff		.
	rst 38h			;5551	ff		.
	rst 38h			;5552	ff		.
	rst 38h			;5553	ff		.
	rst 38h			;5554	ff		.
	rst 38h			;5555	ff		.
	rst 38h			;5556	ff		.
	rst 38h			;5557	ff		.
	rst 38h			;5558	ff		.
	rst 38h			;5559	ff		.
	rst 38h			;555a	ff		.
	rst 38h			;555b	ff		.
	rst 38h			;555c	ff		.
	rst 38h			;555d	ff		.
	rst 38h			;555e	ff		.
	rst 38h			;555f	ff		.
	rst 38h			;5560	ff		.
	rst 38h			;5561	ff		.
	rst 38h			;5562	ff		.
	rst 38h			;5563	ff		.
	rst 38h			;5564	ff		.
	rst 38h			;5565	ff		.
	rst 38h			;5566	ff		.
	rst 38h			;5567	ff		.
	rst 38h			;5568	ff		.
	rst 38h			;5569	ff		.
	rst 38h			;556a	ff		.
	rst 38h			;556b	ff		.
	rst 38h			;556c	ff		.
	rst 38h			;556d	ff		.
	rst 38h			;556e	ff		.
	rst 38h			;556f	ff		.
	rst 38h			;5570	ff		.
	rst 38h			;5571	ff		.
	rst 38h			;5572	ff		.
	rst 38h			;5573	ff		.
	rst 38h			;5574	ff		.
	rst 38h			;5575	ff		.
	rst 38h			;5576	ff		.
	rst 38h			;5577	ff		.
	rst 38h			;5578	ff		.
	rst 38h			;5579	ff		.
	rst 38h			;557a	ff		.
	rst 38h			;557b	ff		.
	rst 38h			;557c	ff		.
	rst 38h			;557d	ff		.
	rst 38h			;557e	ff		.
	rst 38h			;557f	ff		.
	rst 38h			;5580	ff		.
	rst 38h			;5581	ff		.
	rst 38h			;5582	ff		.
	rst 38h			;5583	ff		.
	rst 38h			;5584	ff		.
	rst 38h			;5585	ff		.
	rst 38h			;5586	ff		.
	rst 38h			;5587	ff		.
	rst 38h			;5588	ff		.
	rst 38h			;5589	ff		.
	rst 38h			;558a	ff		.
	rst 38h			;558b	ff		.
	rst 38h			;558c	ff		.
	rst 38h			;558d	ff		.
	rst 38h			;558e	ff		.
	rst 38h			;558f	ff		.
	rst 38h			;5590	ff		.
	rst 38h			;5591	ff		.
	rst 38h			;5592	ff		.
	rst 38h			;5593	ff		.
	rst 38h			;5594	ff		.
	rst 38h			;5595	ff		.
	rst 38h			;5596	ff		.
	rst 38h			;5597	ff		.
	rst 38h			;5598	ff		.
	rst 38h			;5599	ff		.
	rst 38h			;559a	ff		.
	rst 38h			;559b	ff		.
	rst 38h			;559c	ff		.
	rst 38h			;559d	ff		.
	rst 38h			;559e	ff		.
	rst 38h			;559f	ff		.
	rst 38h			;55a0	ff		.
	rst 38h			;55a1	ff		.
	rst 38h			;55a2	ff		.
	rst 38h			;55a3	ff		.
	rst 38h			;55a4	ff		.
	rst 38h			;55a5	ff		.
	rst 38h			;55a6	ff		.
	rst 38h			;55a7	ff		.
	rst 38h			;55a8	ff		.
	rst 38h			;55a9	ff		.
	rst 38h			;55aa	ff		.
	rst 38h			;55ab	ff		.
	rst 38h			;55ac	ff		.
	rst 38h			;55ad	ff		.
	rst 38h			;55ae	ff		.
	rst 38h			;55af	ff		.
	rst 38h			;55b0	ff		.
	rst 38h			;55b1	ff		.
	rst 38h			;55b2	ff		.
	rst 38h			;55b3	ff		.
	rst 38h			;55b4	ff		.
	rst 38h			;55b5	ff		.
	rst 38h			;55b6	ff		.
	rst 38h			;55b7	ff		.
	rst 38h			;55b8	ff		.
	rst 38h			;55b9	ff		.
	rst 38h			;55ba	ff		.
	rst 38h			;55bb	ff		.
	rst 38h			;55bc	ff		.
	rst 38h			;55bd	ff		.
	rst 38h			;55be	ff		.
	rst 38h			;55bf	ff		.
	rst 38h			;55c0	ff		.
	rst 38h			;55c1	ff		.
	rst 38h			;55c2	ff		.
	rst 38h			;55c3	ff		.
	rst 38h			;55c4	ff		.
	rst 38h			;55c5	ff		.
	rst 38h			;55c6	ff		.
	rst 38h			;55c7	ff		.
	rst 38h			;55c8	ff		.
	rst 38h			;55c9	ff		.
	rst 38h			;55ca	ff		.
	rst 38h			;55cb	ff		.
	rst 38h			;55cc	ff		.
	rst 38h			;55cd	ff		.
	rst 38h			;55ce	ff		.
	rst 38h			;55cf	ff		.
	rst 38h			;55d0	ff		.
	rst 38h			;55d1	ff		.
	rst 38h			;55d2	ff		.
	rst 38h			;55d3	ff		.
	rst 38h			;55d4	ff		.
	rst 38h			;55d5	ff		.
	rst 38h			;55d6	ff		.
	rst 38h			;55d7	ff		.
	rst 38h			;55d8	ff		.
	rst 38h			;55d9	ff		.
	rst 38h			;55da	ff		.
	rst 38h			;55db	ff		.
	rst 38h			;55dc	ff		.
	rst 38h			;55dd	ff		.
	rst 38h			;55de	ff		.
	rst 38h			;55df	ff		.
	rst 38h			;55e0	ff		.
	rst 38h			;55e1	ff		.
	rst 38h			;55e2	ff		.
	rst 38h			;55e3	ff		.
	rst 38h			;55e4	ff		.
	rst 38h			;55e5	ff		.
	rst 38h			;55e6	ff		.
	rst 38h			;55e7	ff		.
	rst 38h			;55e8	ff		.
	rst 38h			;55e9	ff		.
	rst 38h			;55ea	ff		.
	rst 38h			;55eb	ff		.
	rst 38h			;55ec	ff		.
	rst 38h			;55ed	ff		.
	rst 38h			;55ee	ff		.
	rst 38h			;55ef	ff		.
	rst 38h			;55f0	ff		.
	rst 38h			;55f1	ff		.
	rst 38h			;55f2	ff		.
	rst 38h			;55f3	ff		.
	rst 38h			;55f4	ff		.
	rst 38h			;55f5	ff		.
	rst 38h			;55f6	ff		.
	rst 38h			;55f7	ff		.
	rst 38h			;55f8	ff		.
	rst 38h			;55f9	ff		.
	rst 38h			;55fa	ff		.
	rst 38h			;55fb	ff		.
	rst 38h			;55fc	ff		.
	rst 38h			;55fd	ff		.
	rst 38h			;55fe	ff		.
	rst 38h			;55ff	ff		.
	rst 38h			;5600	ff		.
	rst 38h			;5601	ff		.
	rst 38h			;5602	ff		.
	rst 38h			;5603	ff		.
	rst 38h			;5604	ff		.
	rst 38h			;5605	ff		.
	rst 38h			;5606	ff		.
	rst 38h			;5607	ff		.
	rst 38h			;5608	ff		.
	rst 38h			;5609	ff		.
	rst 38h			;560a	ff		.
	rst 38h			;560b	ff		.
	rst 38h			;560c	ff		.
	rst 38h			;560d	ff		.
	rst 38h			;560e	ff		.
	rst 38h			;560f	ff		.
	rst 38h			;5610	ff		.
	rst 38h			;5611	ff		.
	rst 38h			;5612	ff		.
	rst 38h			;5613	ff		.
	rst 38h			;5614	ff		.
	rst 38h			;5615	ff		.
	rst 38h			;5616	ff		.
	rst 38h			;5617	ff		.
	rst 38h			;5618	ff		.
	rst 38h			;5619	ff		.
	rst 38h			;561a	ff		.
	rst 38h			;561b	ff		.
	rst 38h			;561c	ff		.
	rst 38h			;561d	ff		.
	rst 38h			;561e	ff		.
	rst 38h			;561f	ff		.
	rst 38h			;5620	ff		.
	rst 38h			;5621	ff		.
	rst 38h			;5622	ff		.
	rst 38h			;5623	ff		.
	rst 38h			;5624	ff		.
	rst 38h			;5625	ff		.
	rst 38h			;5626	ff		.
	rst 38h			;5627	ff		.
	rst 38h			;5628	ff		.
	rst 38h			;5629	ff		.
	rst 38h			;562a	ff		.
	rst 38h			;562b	ff		.
	rst 38h			;562c	ff		.
	rst 38h			;562d	ff		.
	rst 38h			;562e	ff		.
	rst 38h			;562f	ff		.
	rst 38h			;5630	ff		.
	rst 38h			;5631	ff		.
	rst 38h			;5632	ff		.
	rst 38h			;5633	ff		.
	rst 38h			;5634	ff		.
	rst 38h			;5635	ff		.
	rst 38h			;5636	ff		.
	rst 38h			;5637	ff		.
	rst 38h			;5638	ff		.
	rst 38h			;5639	ff		.
	rst 38h			;563a	ff		.
	rst 38h			;563b	ff		.
	rst 38h			;563c	ff		.
	rst 38h			;563d	ff		.
	rst 38h			;563e	ff		.
	rst 38h			;563f	ff		.
	rst 38h			;5640	ff		.
	rst 38h			;5641	ff		.
	rst 38h			;5642	ff		.
	rst 38h			;5643	ff		.
	rst 38h			;5644	ff		.
	rst 38h			;5645	ff		.
	rst 38h			;5646	ff		.
	rst 38h			;5647	ff		.
	rst 38h			;5648	ff		.
	rst 38h			;5649	ff		.
	rst 38h			;564a	ff		.
	rst 38h			;564b	ff		.
	rst 38h			;564c	ff		.
	rst 38h			;564d	ff		.
	rst 38h			;564e	ff		.
	rst 38h			;564f	ff		.
	rst 38h			;5650	ff		.
	rst 38h			;5651	ff		.
	rst 38h			;5652	ff		.
	rst 38h			;5653	ff		.
	rst 38h			;5654	ff		.
	rst 38h			;5655	ff		.
	rst 38h			;5656	ff		.
	rst 38h			;5657	ff		.
	rst 38h			;5658	ff		.
	rst 38h			;5659	ff		.
	rst 38h			;565a	ff		.
	rst 38h			;565b	ff		.
	rst 38h			;565c	ff		.
	rst 38h			;565d	ff		.
	rst 38h			;565e	ff		.
	rst 38h			;565f	ff		.
	rst 38h			;5660	ff		.
	rst 38h			;5661	ff		.
	rst 38h			;5662	ff		.
	rst 38h			;5663	ff		.
	rst 38h			;5664	ff		.
	rst 38h			;5665	ff		.
	rst 38h			;5666	ff		.
	rst 38h			;5667	ff		.
	rst 38h			;5668	ff		.
	rst 38h			;5669	ff		.
	rst 38h			;566a	ff		.
	rst 38h			;566b	ff		.
	rst 38h			;566c	ff		.
	rst 38h			;566d	ff		.
	rst 38h			;566e	ff		.
	rst 38h			;566f	ff		.
	rst 38h			;5670	ff		.
	rst 38h			;5671	ff		.
	rst 38h			;5672	ff		.
	rst 38h			;5673	ff		.
	rst 38h			;5674	ff		.
	rst 38h			;5675	ff		.
	rst 38h			;5676	ff		.
	rst 38h			;5677	ff		.
	rst 38h			;5678	ff		.
	rst 38h			;5679	ff		.
	rst 38h			;567a	ff		.
	rst 38h			;567b	ff		.
	rst 38h			;567c	ff		.
	rst 38h			;567d	ff		.
	rst 38h			;567e	ff		.
	rst 38h			;567f	ff		.
	rst 38h			;5680	ff		.
	rst 38h			;5681	ff		.
	rst 38h			;5682	ff		.
	rst 38h			;5683	ff		.
	rst 38h			;5684	ff		.
	rst 38h			;5685	ff		.
	rst 38h			;5686	ff		.
	rst 38h			;5687	ff		.
	rst 38h			;5688	ff		.
	rst 38h			;5689	ff		.
	rst 38h			;568a	ff		.
	rst 38h			;568b	ff		.
	rst 38h			;568c	ff		.
	rst 38h			;568d	ff		.
	rst 38h			;568e	ff		.
	rst 38h			;568f	ff		.
	rst 38h			;5690	ff		.
	rst 38h			;5691	ff		.
	rst 38h			;5692	ff		.
	rst 38h			;5693	ff		.
	rst 38h			;5694	ff		.
	rst 38h			;5695	ff		.
	rst 38h			;5696	ff		.
	rst 38h			;5697	ff		.
	rst 38h			;5698	ff		.
	rst 38h			;5699	ff		.
	rst 38h			;569a	ff		.
	rst 38h			;569b	ff		.
	rst 38h			;569c	ff		.
	rst 38h			;569d	ff		.
	rst 38h			;569e	ff		.
	rst 38h			;569f	ff		.
	rst 38h			;56a0	ff		.
	rst 38h			;56a1	ff		.
	rst 38h			;56a2	ff		.
	rst 38h			;56a3	ff		.
	rst 38h			;56a4	ff		.
	rst 38h			;56a5	ff		.
	rst 38h			;56a6	ff		.
	rst 38h			;56a7	ff		.
	rst 38h			;56a8	ff		.
	rst 38h			;56a9	ff		.
	rst 38h			;56aa	ff		.
	rst 38h			;56ab	ff		.
	rst 38h			;56ac	ff		.
	rst 38h			;56ad	ff		.
	rst 38h			;56ae	ff		.
	rst 38h			;56af	ff		.
	rst 38h			;56b0	ff		.
	rst 38h			;56b1	ff		.
	rst 38h			;56b2	ff		.
	rst 38h			;56b3	ff		.
	rst 38h			;56b4	ff		.
	rst 38h			;56b5	ff		.
	rst 38h			;56b6	ff		.
	rst 38h			;56b7	ff		.
	rst 38h			;56b8	ff		.
	rst 38h			;56b9	ff		.
	rst 38h			;56ba	ff		.
	rst 38h			;56bb	ff		.
	rst 38h			;56bc	ff		.
	rst 38h			;56bd	ff		.
	rst 38h			;56be	ff		.
	rst 38h			;56bf	ff		.
	rst 38h			;56c0	ff		.
	rst 38h			;56c1	ff		.
	rst 38h			;56c2	ff		.
	rst 38h			;56c3	ff		.
	rst 38h			;56c4	ff		.
	rst 38h			;56c5	ff		.
	rst 38h			;56c6	ff		.
	rst 38h			;56c7	ff		.
	rst 38h			;56c8	ff		.
	rst 38h			;56c9	ff		.
	rst 38h			;56ca	ff		.
	rst 38h			;56cb	ff		.
	rst 38h			;56cc	ff		.
	rst 38h			;56cd	ff		.
	rst 38h			;56ce	ff		.
	rst 38h			;56cf	ff		.
	rst 38h			;56d0	ff		.
	rst 38h			;56d1	ff		.
	rst 38h			;56d2	ff		.
	rst 38h			;56d3	ff		.
	rst 38h			;56d4	ff		.
	rst 38h			;56d5	ff		.
	rst 38h			;56d6	ff		.
	rst 38h			;56d7	ff		.
	rst 38h			;56d8	ff		.
	rst 38h			;56d9	ff		.
	rst 38h			;56da	ff		.
	rst 38h			;56db	ff		.
	rst 38h			;56dc	ff		.
	rst 38h			;56dd	ff		.
	rst 38h			;56de	ff		.
	rst 38h			;56df	ff		.
	rst 38h			;56e0	ff		.
	rst 38h			;56e1	ff		.
	rst 38h			;56e2	ff		.
	rst 38h			;56e3	ff		.
	rst 38h			;56e4	ff		.
	rst 38h			;56e5	ff		.
	rst 38h			;56e6	ff		.
	rst 38h			;56e7	ff		.
	rst 38h			;56e8	ff		.
	rst 38h			;56e9	ff		.
	rst 38h			;56ea	ff		.
	rst 38h			;56eb	ff		.
	rst 38h			;56ec	ff		.
	rst 38h			;56ed	ff		.
	rst 38h			;56ee	ff		.
	rst 38h			;56ef	ff		.
	rst 38h			;56f0	ff		.
	rst 38h			;56f1	ff		.
	rst 38h			;56f2	ff		.
	rst 38h			;56f3	ff		.
	rst 38h			;56f4	ff		.
	rst 38h			;56f5	ff		.
	rst 38h			;56f6	ff		.
	rst 38h			;56f7	ff		.
	rst 38h			;56f8	ff		.
	rst 38h			;56f9	ff		.
	rst 38h			;56fa	ff		.
	rst 38h			;56fb	ff		.
	rst 38h			;56fc	ff		.
	rst 38h			;56fd	ff		.
	rst 38h			;56fe	ff		.
	rst 38h			;56ff	ff		.
	rst 38h			;5700	ff		.
	rst 38h			;5701	ff		.
	rst 38h			;5702	ff		.
	rst 38h			;5703	ff		.
	rst 38h			;5704	ff		.
	rst 38h			;5705	ff		.
	rst 38h			;5706	ff		.
	rst 38h			;5707	ff		.
	rst 38h			;5708	ff		.
	rst 38h			;5709	ff		.
	rst 38h			;570a	ff		.
	rst 38h			;570b	ff		.
	rst 38h			;570c	ff		.
	rst 38h			;570d	ff		.
	rst 38h			;570e	ff		.
	rst 38h			;570f	ff		.
	rst 38h			;5710	ff		.
	rst 38h			;5711	ff		.
	rst 38h			;5712	ff		.
	rst 38h			;5713	ff		.
	rst 38h			;5714	ff		.
	rst 38h			;5715	ff		.
	rst 38h			;5716	ff		.
	rst 38h			;5717	ff		.
	rst 38h			;5718	ff		.
	rst 38h			;5719	ff		.
	rst 38h			;571a	ff		.
	rst 38h			;571b	ff		.
	rst 38h			;571c	ff		.
	rst 38h			;571d	ff		.
	rst 38h			;571e	ff		.
	rst 38h			;571f	ff		.
	rst 38h			;5720	ff		.
	rst 38h			;5721	ff		.
	rst 38h			;5722	ff		.
	rst 38h			;5723	ff		.
	rst 38h			;5724	ff		.
	rst 38h			;5725	ff		.
	rst 38h			;5726	ff		.
	rst 38h			;5727	ff		.
	rst 38h			;5728	ff		.
	rst 38h			;5729	ff		.
	rst 38h			;572a	ff		.
	rst 38h			;572b	ff		.
	rst 38h			;572c	ff		.
	rst 38h			;572d	ff		.
	rst 38h			;572e	ff		.
	rst 38h			;572f	ff		.
	rst 38h			;5730	ff		.
	rst 38h			;5731	ff		.
	rst 38h			;5732	ff		.
	rst 38h			;5733	ff		.
	rst 38h			;5734	ff		.
	rst 38h			;5735	ff		.
	rst 38h			;5736	ff		.
	rst 38h			;5737	ff		.
	rst 38h			;5738	ff		.
	rst 38h			;5739	ff		.
	rst 38h			;573a	ff		.
	rst 38h			;573b	ff		.
	rst 38h			;573c	ff		.
	rst 38h			;573d	ff		.
	rst 38h			;573e	ff		.
	rst 38h			;573f	ff		.
	rst 38h			;5740	ff		.
	rst 38h			;5741	ff		.
	rst 38h			;5742	ff		.
	rst 38h			;5743	ff		.
	rst 38h			;5744	ff		.
	rst 38h			;5745	ff		.
	rst 38h			;5746	ff		.
	rst 38h			;5747	ff		.
	rst 38h			;5748	ff		.
	rst 38h			;5749	ff		.
	rst 38h			;574a	ff		.
	rst 38h			;574b	ff		.
	rst 38h			;574c	ff		.
	rst 38h			;574d	ff		.
	rst 38h			;574e	ff		.
	rst 38h			;574f	ff		.
	rst 38h			;5750	ff		.
	rst 38h			;5751	ff		.
	rst 38h			;5752	ff		.
	rst 38h			;5753	ff		.
	rst 38h			;5754	ff		.
	rst 38h			;5755	ff		.
	rst 38h			;5756	ff		.
	rst 38h			;5757	ff		.
	rst 38h			;5758	ff		.
	rst 38h			;5759	ff		.
	rst 38h			;575a	ff		.
	rst 38h			;575b	ff		.
	rst 38h			;575c	ff		.
	rst 38h			;575d	ff		.
	rst 38h			;575e	ff		.
	rst 38h			;575f	ff		.
	rst 38h			;5760	ff		.
	rst 38h			;5761	ff		.
	rst 38h			;5762	ff		.
	rst 38h			;5763	ff		.
	rst 38h			;5764	ff		.
	rst 38h			;5765	ff		.
	rst 38h			;5766	ff		.
	rst 38h			;5767	ff		.
	rst 38h			;5768	ff		.
	rst 38h			;5769	ff		.
	rst 38h			;576a	ff		.
	rst 38h			;576b	ff		.
	rst 38h			;576c	ff		.
	rst 38h			;576d	ff		.
	rst 38h			;576e	ff		.
	rst 38h			;576f	ff		.
	rst 38h			;5770	ff		.
	rst 38h			;5771	ff		.
	rst 38h			;5772	ff		.
	rst 38h			;5773	ff		.
	rst 38h			;5774	ff		.
	rst 38h			;5775	ff		.
	rst 38h			;5776	ff		.
	rst 38h			;5777	ff		.
	rst 38h			;5778	ff		.
	rst 38h			;5779	ff		.
	rst 38h			;577a	ff		.
	rst 38h			;577b	ff		.
	rst 38h			;577c	ff		.
	rst 38h			;577d	ff		.
	rst 38h			;577e	ff		.
	rst 38h			;577f	ff		.
	rst 38h			;5780	ff		.
	rst 38h			;5781	ff		.
	rst 38h			;5782	ff		.
	rst 38h			;5783	ff		.
	rst 38h			;5784	ff		.
	rst 38h			;5785	ff		.
	rst 38h			;5786	ff		.
	rst 38h			;5787	ff		.
	rst 38h			;5788	ff		.
	rst 38h			;5789	ff		.
	rst 38h			;578a	ff		.
	rst 38h			;578b	ff		.
	rst 38h			;578c	ff		.
	rst 38h			;578d	ff		.
	rst 38h			;578e	ff		.
	rst 38h			;578f	ff		.
	rst 38h			;5790	ff		.
	rst 38h			;5791	ff		.
	rst 38h			;5792	ff		.
	rst 38h			;5793	ff		.
	rst 38h			;5794	ff		.
	rst 38h			;5795	ff		.
	rst 38h			;5796	ff		.
	rst 38h			;5797	ff		.
	rst 38h			;5798	ff		.
	rst 38h			;5799	ff		.
	rst 38h			;579a	ff		.
	rst 38h			;579b	ff		.
	rst 38h			;579c	ff		.
	rst 38h			;579d	ff		.
	rst 38h			;579e	ff		.
	rst 38h			;579f	ff		.
	rst 38h			;57a0	ff		.
	rst 38h			;57a1	ff		.
	rst 38h			;57a2	ff		.
	rst 38h			;57a3	ff		.
	rst 38h			;57a4	ff		.
	rst 38h			;57a5	ff		.
	rst 38h			;57a6	ff		.
	rst 38h			;57a7	ff		.
	rst 38h			;57a8	ff		.
	rst 38h			;57a9	ff		.
	rst 38h			;57aa	ff		.
	rst 38h			;57ab	ff		.
	rst 38h			;57ac	ff		.
	rst 38h			;57ad	ff		.
	rst 38h			;57ae	ff		.
	rst 38h			;57af	ff		.
	rst 38h			;57b0	ff		.
	rst 38h			;57b1	ff		.
	rst 38h			;57b2	ff		.
	rst 38h			;57b3	ff		.
	rst 38h			;57b4	ff		.
	rst 38h			;57b5	ff		.
	rst 38h			;57b6	ff		.
	rst 38h			;57b7	ff		.
	rst 38h			;57b8	ff		.
	rst 38h			;57b9	ff		.
	rst 38h			;57ba	ff		.
	rst 38h			;57bb	ff		.
	rst 38h			;57bc	ff		.
	rst 38h			;57bd	ff		.
	rst 38h			;57be	ff		.
	rst 38h			;57bf	ff		.
	rst 38h			;57c0	ff		.
	rst 38h			;57c1	ff		.
	rst 38h			;57c2	ff		.
	rst 38h			;57c3	ff		.
	rst 38h			;57c4	ff		.
	rst 38h			;57c5	ff		.
	rst 38h			;57c6	ff		.
	rst 38h			;57c7	ff		.
	rst 38h			;57c8	ff		.
	rst 38h			;57c9	ff		.
	rst 38h			;57ca	ff		.
	rst 38h			;57cb	ff		.
	rst 38h			;57cc	ff		.
	rst 38h			;57cd	ff		.
	rst 38h			;57ce	ff		.
	rst 38h			;57cf	ff		.
	rst 38h			;57d0	ff		.
	rst 38h			;57d1	ff		.
	rst 38h			;57d2	ff		.
	rst 38h			;57d3	ff		.
	rst 38h			;57d4	ff		.
	rst 38h			;57d5	ff		.
	rst 38h			;57d6	ff		.
	rst 38h			;57d7	ff		.
	rst 38h			;57d8	ff		.
	rst 38h			;57d9	ff		.
	rst 38h			;57da	ff		.
	rst 38h			;57db	ff		.
	rst 38h			;57dc	ff		.
	rst 38h			;57dd	ff		.
	rst 38h			;57de	ff		.
	rst 38h			;57df	ff		.
	rst 38h			;57e0	ff		.
	rst 38h			;57e1	ff		.
	rst 38h			;57e2	ff		.
	rst 38h			;57e3	ff		.
	rst 38h			;57e4	ff		.
	rst 38h			;57e5	ff		.
	rst 38h			;57e6	ff		.
	rst 38h			;57e7	ff		.
	rst 38h			;57e8	ff		.
	rst 38h			;57e9	ff		.
	rst 38h			;57ea	ff		.
	rst 38h			;57eb	ff		.
	rst 38h			;57ec	ff		.
	rst 38h			;57ed	ff		.
	rst 38h			;57ee	ff		.
	rst 38h			;57ef	ff		.
	rst 38h			;57f0	ff		.
	rst 38h			;57f1	ff		.
	rst 38h			;57f2	ff		.
	rst 38h			;57f3	ff		.
	rst 38h			;57f4	ff		.
	rst 38h			;57f5	ff		.
	rst 38h			;57f6	ff		.
	rst 38h			;57f7	ff		.
	rst 38h			;57f8	ff		.
	rst 38h			;57f9	ff		.
	rst 38h			;57fa	ff		.
	rst 38h			;57fb	ff		.
	rst 38h			;57fc	ff		.
	rst 38h			;57fd	ff		.
	rst 38h			;57fe	ff		.
	rst 38h			;57ff	ff		.
	rst 38h			;5800	ff		.
	rst 38h			;5801	ff		.
	rst 38h			;5802	ff		.
	rst 38h			;5803	ff		.
	rst 38h			;5804	ff		.
	rst 38h			;5805	ff		.
	rst 38h			;5806	ff		.
	rst 38h			;5807	ff		.
	rst 38h			;5808	ff		.
	rst 38h			;5809	ff		.
	rst 38h			;580a	ff		.
	rst 38h			;580b	ff		.
	rst 38h			;580c	ff		.
	rst 38h			;580d	ff		.
	rst 38h			;580e	ff		.
	rst 38h			;580f	ff		.
	rst 38h			;5810	ff		.
	rst 38h			;5811	ff		.
	rst 38h			;5812	ff		.
	rst 38h			;5813	ff		.
	rst 38h			;5814	ff		.
	rst 38h			;5815	ff		.
	rst 38h			;5816	ff		.
	rst 38h			;5817	ff		.
	rst 38h			;5818	ff		.
	rst 38h			;5819	ff		.
	rst 38h			;581a	ff		.
	rst 38h			;581b	ff		.
	rst 38h			;581c	ff		.
	rst 38h			;581d	ff		.
	rst 38h			;581e	ff		.
	rst 38h			;581f	ff		.
	rst 38h			;5820	ff		.
	rst 38h			;5821	ff		.
	rst 38h			;5822	ff		.
	rst 38h			;5823	ff		.
	rst 38h			;5824	ff		.
	rst 38h			;5825	ff		.
	rst 38h			;5826	ff		.
	rst 38h			;5827	ff		.
	rst 38h			;5828	ff		.
	rst 38h			;5829	ff		.
	rst 38h			;582a	ff		.
	rst 38h			;582b	ff		.
	rst 38h			;582c	ff		.
	rst 38h			;582d	ff		.
	rst 38h			;582e	ff		.
	rst 38h			;582f	ff		.
	rst 38h			;5830	ff		.
	rst 38h			;5831	ff		.
	rst 38h			;5832	ff		.
	rst 38h			;5833	ff		.
	rst 38h			;5834	ff		.
	rst 38h			;5835	ff		.
	rst 38h			;5836	ff		.
	rst 38h			;5837	ff		.
	rst 38h			;5838	ff		.
	rst 38h			;5839	ff		.
	rst 38h			;583a	ff		.
	rst 38h			;583b	ff		.
	rst 38h			;583c	ff		.
	rst 38h			;583d	ff		.
	rst 38h			;583e	ff		.
	rst 38h			;583f	ff		.
	rst 38h			;5840	ff		.
	rst 38h			;5841	ff		.
	rst 38h			;5842	ff		.
	rst 38h			;5843	ff		.
	rst 38h			;5844	ff		.
	rst 38h			;5845	ff		.
	rst 38h			;5846	ff		.
	rst 38h			;5847	ff		.
	rst 38h			;5848	ff		.
	rst 38h			;5849	ff		.
	rst 38h			;584a	ff		.
	rst 38h			;584b	ff		.
	rst 38h			;584c	ff		.
	rst 38h			;584d	ff		.
	rst 38h			;584e	ff		.
	rst 38h			;584f	ff		.
	rst 38h			;5850	ff		.
	rst 38h			;5851	ff		.
	rst 38h			;5852	ff		.
	rst 38h			;5853	ff		.
	rst 38h			;5854	ff		.
	rst 38h			;5855	ff		.
	rst 38h			;5856	ff		.
	rst 38h			;5857	ff		.
	rst 38h			;5858	ff		.
	rst 38h			;5859	ff		.
	rst 38h			;585a	ff		.
	rst 38h			;585b	ff		.
	rst 38h			;585c	ff		.
	rst 38h			;585d	ff		.
	rst 38h			;585e	ff		.
	rst 38h			;585f	ff		.
	rst 38h			;5860	ff		.
	rst 38h			;5861	ff		.
	rst 38h			;5862	ff		.
	rst 38h			;5863	ff		.
	rst 38h			;5864	ff		.
	rst 38h			;5865	ff		.
	rst 38h			;5866	ff		.
	rst 38h			;5867	ff		.
	rst 38h			;5868	ff		.
	rst 38h			;5869	ff		.
	rst 38h			;586a	ff		.
	rst 38h			;586b	ff		.
	rst 38h			;586c	ff		.
	rst 38h			;586d	ff		.
	rst 38h			;586e	ff		.
	rst 38h			;586f	ff		.
	rst 38h			;5870	ff		.
	rst 38h			;5871	ff		.
	rst 38h			;5872	ff		.
	rst 38h			;5873	ff		.
	rst 38h			;5874	ff		.
	rst 38h			;5875	ff		.
	rst 38h			;5876	ff		.
	rst 38h			;5877	ff		.
	rst 38h			;5878	ff		.
	rst 38h			;5879	ff		.
	rst 38h			;587a	ff		.
	rst 38h			;587b	ff		.
	rst 38h			;587c	ff		.
	rst 38h			;587d	ff		.
	rst 38h			;587e	ff		.
	rst 38h			;587f	ff		.
	rst 38h			;5880	ff		.
	rst 38h			;5881	ff		.
	rst 38h			;5882	ff		.
	rst 38h			;5883	ff		.
	rst 38h			;5884	ff		.
	rst 38h			;5885	ff		.
	rst 38h			;5886	ff		.
	rst 38h			;5887	ff		.
	rst 38h			;5888	ff		.
	rst 38h			;5889	ff		.
	rst 38h			;588a	ff		.
	rst 38h			;588b	ff		.
	rst 38h			;588c	ff		.
	rst 38h			;588d	ff		.
	rst 38h			;588e	ff		.
	rst 38h			;588f	ff		.
	rst 38h			;5890	ff		.
	rst 38h			;5891	ff		.
	rst 38h			;5892	ff		.
	rst 38h			;5893	ff		.
	rst 38h			;5894	ff		.
	rst 38h			;5895	ff		.
	rst 38h			;5896	ff		.
	rst 38h			;5897	ff		.
	rst 38h			;5898	ff		.
	rst 38h			;5899	ff		.
	rst 38h			;589a	ff		.
	rst 38h			;589b	ff		.
	rst 38h			;589c	ff		.
	rst 38h			;589d	ff		.
	rst 38h			;589e	ff		.
	rst 38h			;589f	ff		.
	rst 38h			;58a0	ff		.
	rst 38h			;58a1	ff		.
	rst 38h			;58a2	ff		.
	rst 38h			;58a3	ff		.
	rst 38h			;58a4	ff		.
	rst 38h			;58a5	ff		.
	rst 38h			;58a6	ff		.
	rst 38h			;58a7	ff		.
	rst 38h			;58a8	ff		.
	rst 38h			;58a9	ff		.
	rst 38h			;58aa	ff		.
	rst 38h			;58ab	ff		.
	rst 38h			;58ac	ff		.
	rst 38h			;58ad	ff		.
	rst 38h			;58ae	ff		.
	rst 38h			;58af	ff		.
	rst 38h			;58b0	ff		.
	rst 38h			;58b1	ff		.
	rst 38h			;58b2	ff		.
	rst 38h			;58b3	ff		.
	rst 38h			;58b4	ff		.
	rst 38h			;58b5	ff		.
	rst 38h			;58b6	ff		.
	rst 38h			;58b7	ff		.
	rst 38h			;58b8	ff		.
	rst 38h			;58b9	ff		.
	rst 38h			;58ba	ff		.
	rst 38h			;58bb	ff		.
	rst 38h			;58bc	ff		.
	rst 38h			;58bd	ff		.
	rst 38h			;58be	ff		.
	rst 38h			;58bf	ff		.
	rst 38h			;58c0	ff		.
	rst 38h			;58c1	ff		.
	rst 38h			;58c2	ff		.
	rst 38h			;58c3	ff		.
	rst 38h			;58c4	ff		.
	rst 38h			;58c5	ff		.
	rst 38h			;58c6	ff		.
	rst 38h			;58c7	ff		.
	rst 38h			;58c8	ff		.
	rst 38h			;58c9	ff		.
	rst 38h			;58ca	ff		.
	rst 38h			;58cb	ff		.
	rst 38h			;58cc	ff		.
	rst 38h			;58cd	ff		.
	rst 38h			;58ce	ff		.
	rst 38h			;58cf	ff		.
	rst 38h			;58d0	ff		.
	rst 38h			;58d1	ff		.
	rst 38h			;58d2	ff		.
	rst 38h			;58d3	ff		.
	rst 38h			;58d4	ff		.
	rst 38h			;58d5	ff		.
	rst 38h			;58d6	ff		.
	rst 38h			;58d7	ff		.
	rst 38h			;58d8	ff		.
	rst 38h			;58d9	ff		.
	rst 38h			;58da	ff		.
	rst 38h			;58db	ff		.
	rst 38h			;58dc	ff		.
	rst 38h			;58dd	ff		.
	rst 38h			;58de	ff		.
	rst 38h			;58df	ff		.
	rst 38h			;58e0	ff		.
	rst 38h			;58e1	ff		.
	rst 38h			;58e2	ff		.
	rst 38h			;58e3	ff		.
	rst 38h			;58e4	ff		.
	rst 38h			;58e5	ff		.
	rst 38h			;58e6	ff		.
	rst 38h			;58e7	ff		.
	rst 38h			;58e8	ff		.
	rst 38h			;58e9	ff		.
	rst 38h			;58ea	ff		.
	rst 38h			;58eb	ff		.
	rst 38h			;58ec	ff		.
	rst 38h			;58ed	ff		.
	rst 38h			;58ee	ff		.
	rst 38h			;58ef	ff		.
	rst 38h			;58f0	ff		.
	rst 38h			;58f1	ff		.
	rst 38h			;58f2	ff		.
	rst 38h			;58f3	ff		.
	rst 38h			;58f4	ff		.
	rst 38h			;58f5	ff		.
	rst 38h			;58f6	ff		.
	rst 38h			;58f7	ff		.
	rst 38h			;58f8	ff		.
	rst 38h			;58f9	ff		.
	rst 38h			;58fa	ff		.
	rst 38h			;58fb	ff		.
	rst 38h			;58fc	ff		.
	rst 38h			;58fd	ff		.
	rst 38h			;58fe	ff		.
	rst 38h			;58ff	ff		.
	rst 38h			;5900	ff		.
	rst 38h			;5901	ff		.
	rst 38h			;5902	ff		.
	rst 38h			;5903	ff		.
	rst 38h			;5904	ff		.
	rst 38h			;5905	ff		.
	rst 38h			;5906	ff		.
	rst 38h			;5907	ff		.
	rst 38h			;5908	ff		.
	rst 38h			;5909	ff		.
	rst 38h			;590a	ff		.
	rst 38h			;590b	ff		.
	rst 38h			;590c	ff		.
	rst 38h			;590d	ff		.
	rst 38h			;590e	ff		.
	rst 38h			;590f	ff		.
	rst 38h			;5910	ff		.
	rst 38h			;5911	ff		.
	rst 38h			;5912	ff		.
	rst 38h			;5913	ff		.
	rst 38h			;5914	ff		.
	rst 38h			;5915	ff		.
	rst 38h			;5916	ff		.
	rst 38h			;5917	ff		.
	rst 38h			;5918	ff		.
	rst 38h			;5919	ff		.
	rst 38h			;591a	ff		.
	rst 38h			;591b	ff		.
	rst 38h			;591c	ff		.
	rst 38h			;591d	ff		.
	rst 38h			;591e	ff		.
	rst 38h			;591f	ff		.
	rst 38h			;5920	ff		.
	rst 38h			;5921	ff		.
	rst 38h			;5922	ff		.
	rst 38h			;5923	ff		.
	rst 38h			;5924	ff		.
	rst 38h			;5925	ff		.
	rst 38h			;5926	ff		.
	rst 38h			;5927	ff		.
	rst 38h			;5928	ff		.
	rst 38h			;5929	ff		.
	rst 38h			;592a	ff		.
	rst 38h			;592b	ff		.
	rst 38h			;592c	ff		.
	rst 38h			;592d	ff		.
	rst 38h			;592e	ff		.
	rst 38h			;592f	ff		.
	rst 38h			;5930	ff		.
	rst 38h			;5931	ff		.
	rst 38h			;5932	ff		.
	rst 38h			;5933	ff		.
	rst 38h			;5934	ff		.
	rst 38h			;5935	ff		.
	rst 38h			;5936	ff		.
	rst 38h			;5937	ff		.
	rst 38h			;5938	ff		.
	rst 38h			;5939	ff		.
	rst 38h			;593a	ff		.
	rst 38h			;593b	ff		.
	rst 38h			;593c	ff		.
	rst 38h			;593d	ff		.
	rst 38h			;593e	ff		.
	rst 38h			;593f	ff		.
	rst 38h			;5940	ff		.
	rst 38h			;5941	ff		.
	rst 38h			;5942	ff		.
	rst 38h			;5943	ff		.
	rst 38h			;5944	ff		.
	rst 38h			;5945	ff		.
	rst 38h			;5946	ff		.
	rst 38h			;5947	ff		.
	rst 38h			;5948	ff		.
	rst 38h			;5949	ff		.
	rst 38h			;594a	ff		.
	rst 38h			;594b	ff		.
	rst 38h			;594c	ff		.
	rst 38h			;594d	ff		.
	rst 38h			;594e	ff		.
	rst 38h			;594f	ff		.
	rst 38h			;5950	ff		.
	rst 38h			;5951	ff		.
	rst 38h			;5952	ff		.
	rst 38h			;5953	ff		.
	rst 38h			;5954	ff		.
	rst 38h			;5955	ff		.
	rst 38h			;5956	ff		.
	rst 38h			;5957	ff		.
	rst 38h			;5958	ff		.
	rst 38h			;5959	ff		.
	rst 38h			;595a	ff		.
	rst 38h			;595b	ff		.
	rst 38h			;595c	ff		.
	rst 38h			;595d	ff		.
	rst 38h			;595e	ff		.
	rst 38h			;595f	ff		.
	rst 38h			;5960	ff		.
	rst 38h			;5961	ff		.
	rst 38h			;5962	ff		.
	rst 38h			;5963	ff		.
	rst 38h			;5964	ff		.
	rst 38h			;5965	ff		.
	rst 38h			;5966	ff		.
	rst 38h			;5967	ff		.
	rst 38h			;5968	ff		.
	rst 38h			;5969	ff		.
	rst 38h			;596a	ff		.
	rst 38h			;596b	ff		.
	rst 38h			;596c	ff		.
	rst 38h			;596d	ff		.
	rst 38h			;596e	ff		.
	rst 38h			;596f	ff		.
	rst 38h			;5970	ff		.
	rst 38h			;5971	ff		.
	rst 38h			;5972	ff		.
	rst 38h			;5973	ff		.
	rst 38h			;5974	ff		.
	rst 38h			;5975	ff		.
	rst 38h			;5976	ff		.
	rst 38h			;5977	ff		.
	rst 38h			;5978	ff		.
	rst 38h			;5979	ff		.
	rst 38h			;597a	ff		.
	rst 38h			;597b	ff		.
	rst 38h			;597c	ff		.
	rst 38h			;597d	ff		.
	rst 38h			;597e	ff		.
	rst 38h			;597f	ff		.
	rst 38h			;5980	ff		.
	rst 38h			;5981	ff		.
	rst 38h			;5982	ff		.
	rst 38h			;5983	ff		.
	rst 38h			;5984	ff		.
	rst 38h			;5985	ff		.
	rst 38h			;5986	ff		.
	rst 38h			;5987	ff		.
	rst 38h			;5988	ff		.
	rst 38h			;5989	ff		.
	rst 38h			;598a	ff		.
	rst 38h			;598b	ff		.
	rst 38h			;598c	ff		.
	rst 38h			;598d	ff		.
	rst 38h			;598e	ff		.
	rst 38h			;598f	ff		.
	rst 38h			;5990	ff		.
	rst 38h			;5991	ff		.
	rst 38h			;5992	ff		.
	rst 38h			;5993	ff		.
	rst 38h			;5994	ff		.
	rst 38h			;5995	ff		.
	rst 38h			;5996	ff		.
	rst 38h			;5997	ff		.
	rst 38h			;5998	ff		.
	rst 38h			;5999	ff		.
	rst 38h			;599a	ff		.
	rst 38h			;599b	ff		.
	rst 38h			;599c	ff		.
	rst 38h			;599d	ff		.
	rst 38h			;599e	ff		.
	rst 38h			;599f	ff		.
	rst 38h			;59a0	ff		.
	rst 38h			;59a1	ff		.
	rst 38h			;59a2	ff		.
	rst 38h			;59a3	ff		.
	rst 38h			;59a4	ff		.
	rst 38h			;59a5	ff		.
	rst 38h			;59a6	ff		.
	rst 38h			;59a7	ff		.
	rst 38h			;59a8	ff		.
	rst 38h			;59a9	ff		.
	rst 38h			;59aa	ff		.
	rst 38h			;59ab	ff		.
	rst 38h			;59ac	ff		.
	rst 38h			;59ad	ff		.
	rst 38h			;59ae	ff		.
	rst 38h			;59af	ff		.
	rst 38h			;59b0	ff		.
	rst 38h			;59b1	ff		.
	rst 38h			;59b2	ff		.
	rst 38h			;59b3	ff		.
	rst 38h			;59b4	ff		.
	rst 38h			;59b5	ff		.
	rst 38h			;59b6	ff		.
	rst 38h			;59b7	ff		.
	rst 38h			;59b8	ff		.
	rst 38h			;59b9	ff		.
	rst 38h			;59ba	ff		.
	rst 38h			;59bb	ff		.
	rst 38h			;59bc	ff		.
	rst 38h			;59bd	ff		.
	rst 38h			;59be	ff		.
	rst 38h			;59bf	ff		.
	rst 38h			;59c0	ff		.
	rst 38h			;59c1	ff		.
	rst 38h			;59c2	ff		.
	rst 38h			;59c3	ff		.
	rst 38h			;59c4	ff		.
	rst 38h			;59c5	ff		.
	rst 38h			;59c6	ff		.
	rst 38h			;59c7	ff		.
	rst 38h			;59c8	ff		.
	rst 38h			;59c9	ff		.
	rst 38h			;59ca	ff		.
	rst 38h			;59cb	ff		.
	rst 38h			;59cc	ff		.
	rst 38h			;59cd	ff		.
	rst 38h			;59ce	ff		.
	rst 38h			;59cf	ff		.
	rst 38h			;59d0	ff		.
	rst 38h			;59d1	ff		.
	rst 38h			;59d2	ff		.
	rst 38h			;59d3	ff		.
	rst 38h			;59d4	ff		.
	rst 38h			;59d5	ff		.
	rst 38h			;59d6	ff		.
	rst 38h			;59d7	ff		.
	rst 38h			;59d8	ff		.
	rst 38h			;59d9	ff		.
	rst 38h			;59da	ff		.
	rst 38h			;59db	ff		.
	rst 38h			;59dc	ff		.
	rst 38h			;59dd	ff		.
	rst 38h			;59de	ff		.
	rst 38h			;59df	ff		.
	rst 38h			;59e0	ff		.
	rst 38h			;59e1	ff		.
	rst 38h			;59e2	ff		.
	rst 38h			;59e3	ff		.
	rst 38h			;59e4	ff		.
	rst 38h			;59e5	ff		.
	rst 38h			;59e6	ff		.
	rst 38h			;59e7	ff		.
	rst 38h			;59e8	ff		.
	rst 38h			;59e9	ff		.
	rst 38h			;59ea	ff		.
	rst 38h			;59eb	ff		.
	rst 38h			;59ec	ff		.
	rst 38h			;59ed	ff		.
	rst 38h			;59ee	ff		.
	rst 38h			;59ef	ff		.
	rst 38h			;59f0	ff		.
	rst 38h			;59f1	ff		.
	rst 38h			;59f2	ff		.
	rst 38h			;59f3	ff		.
	rst 38h			;59f4	ff		.
	rst 38h			;59f5	ff		.
	rst 38h			;59f6	ff		.
	rst 38h			;59f7	ff		.
	rst 38h			;59f8	ff		.
	rst 38h			;59f9	ff		.
	rst 38h			;59fa	ff		.
	rst 38h			;59fb	ff		.
	rst 38h			;59fc	ff		.
	rst 38h			;59fd	ff		.
	rst 38h			;59fe	ff		.
	rst 38h			;59ff	ff		.
	rst 38h			;5a00	ff		.
	rst 38h			;5a01	ff		.
	rst 38h			;5a02	ff		.
	rst 38h			;5a03	ff		.
	rst 38h			;5a04	ff		.
	rst 38h			;5a05	ff		.
	rst 38h			;5a06	ff		.
	rst 38h			;5a07	ff		.
	rst 38h			;5a08	ff		.
	rst 38h			;5a09	ff		.
	rst 38h			;5a0a	ff		.
	rst 38h			;5a0b	ff		.
	rst 38h			;5a0c	ff		.
	rst 38h			;5a0d	ff		.
	rst 38h			;5a0e	ff		.
	rst 38h			;5a0f	ff		.
	rst 38h			;5a10	ff		.
	rst 38h			;5a11	ff		.
	rst 38h			;5a12	ff		.
	rst 38h			;5a13	ff		.
	rst 38h			;5a14	ff		.
	rst 38h			;5a15	ff		.
	rst 38h			;5a16	ff		.
	rst 38h			;5a17	ff		.
	rst 38h			;5a18	ff		.
	rst 38h			;5a19	ff		.
	rst 38h			;5a1a	ff		.
	rst 38h			;5a1b	ff		.
	rst 38h			;5a1c	ff		.
	rst 38h			;5a1d	ff		.
	rst 38h			;5a1e	ff		.
	rst 38h			;5a1f	ff		.
	rst 38h			;5a20	ff		.
	rst 38h			;5a21	ff		.
	rst 38h			;5a22	ff		.
	rst 38h			;5a23	ff		.
	rst 38h			;5a24	ff		.
	rst 38h			;5a25	ff		.
	rst 38h			;5a26	ff		.
	rst 38h			;5a27	ff		.
	rst 38h			;5a28	ff		.
	rst 38h			;5a29	ff		.
	rst 38h			;5a2a	ff		.
	rst 38h			;5a2b	ff		.
	rst 38h			;5a2c	ff		.
	rst 38h			;5a2d	ff		.
	rst 38h			;5a2e	ff		.
	rst 38h			;5a2f	ff		.
	rst 38h			;5a30	ff		.
	rst 38h			;5a31	ff		.
	rst 38h			;5a32	ff		.
	rst 38h			;5a33	ff		.
	rst 38h			;5a34	ff		.
	rst 38h			;5a35	ff		.
	rst 38h			;5a36	ff		.
	rst 38h			;5a37	ff		.
	rst 38h			;5a38	ff		.
	rst 38h			;5a39	ff		.
	rst 38h			;5a3a	ff		.
	rst 38h			;5a3b	ff		.
	rst 38h			;5a3c	ff		.
	rst 38h			;5a3d	ff		.
	rst 38h			;5a3e	ff		.
	rst 38h			;5a3f	ff		.
	rst 38h			;5a40	ff		.
	rst 38h			;5a41	ff		.
	rst 38h			;5a42	ff		.
	rst 38h			;5a43	ff		.
	rst 38h			;5a44	ff		.
	rst 38h			;5a45	ff		.
	rst 38h			;5a46	ff		.
	rst 38h			;5a47	ff		.
	rst 38h			;5a48	ff		.
	rst 38h			;5a49	ff		.
	rst 38h			;5a4a	ff		.
	rst 38h			;5a4b	ff		.
	rst 38h			;5a4c	ff		.
	rst 38h			;5a4d	ff		.
	rst 38h			;5a4e	ff		.
	rst 38h			;5a4f	ff		.
	rst 38h			;5a50	ff		.
	rst 38h			;5a51	ff		.
	rst 38h			;5a52	ff		.
	rst 38h			;5a53	ff		.
	rst 38h			;5a54	ff		.
	rst 38h			;5a55	ff		.
	rst 38h			;5a56	ff		.
	rst 38h			;5a57	ff		.
	rst 38h			;5a58	ff		.
	rst 38h			;5a59	ff		.
	rst 38h			;5a5a	ff		.
	rst 38h			;5a5b	ff		.
	rst 38h			;5a5c	ff		.
	rst 38h			;5a5d	ff		.
	rst 38h			;5a5e	ff		.
	rst 38h			;5a5f	ff		.
	rst 38h			;5a60	ff		.
	rst 38h			;5a61	ff		.
	rst 38h			;5a62	ff		.
	rst 38h			;5a63	ff		.
	rst 38h			;5a64	ff		.
	rst 38h			;5a65	ff		.
	rst 38h			;5a66	ff		.
	rst 38h			;5a67	ff		.
	rst 38h			;5a68	ff		.
	rst 38h			;5a69	ff		.
	rst 38h			;5a6a	ff		.
	rst 38h			;5a6b	ff		.
	rst 38h			;5a6c	ff		.
	rst 38h			;5a6d	ff		.
	rst 38h			;5a6e	ff		.
	rst 38h			;5a6f	ff		.
	rst 38h			;5a70	ff		.
	rst 38h			;5a71	ff		.
	rst 38h			;5a72	ff		.
	rst 38h			;5a73	ff		.
	rst 38h			;5a74	ff		.
	rst 38h			;5a75	ff		.
	rst 38h			;5a76	ff		.
	rst 38h			;5a77	ff		.
	rst 38h			;5a78	ff		.
	rst 38h			;5a79	ff		.
	rst 38h			;5a7a	ff		.
	rst 38h			;5a7b	ff		.
	rst 38h			;5a7c	ff		.
	rst 38h			;5a7d	ff		.
	rst 38h			;5a7e	ff		.
	rst 38h			;5a7f	ff		.
	rst 38h			;5a80	ff		.
	rst 38h			;5a81	ff		.
	rst 38h			;5a82	ff		.
	rst 38h			;5a83	ff		.
	rst 38h			;5a84	ff		.
	rst 38h			;5a85	ff		.
	rst 38h			;5a86	ff		.
	rst 38h			;5a87	ff		.
	rst 38h			;5a88	ff		.
	rst 38h			;5a89	ff		.
	rst 38h			;5a8a	ff		.
	rst 38h			;5a8b	ff		.
	rst 38h			;5a8c	ff		.
	rst 38h			;5a8d	ff		.
	rst 38h			;5a8e	ff		.
	rst 38h			;5a8f	ff		.
	rst 38h			;5a90	ff		.
	rst 38h			;5a91	ff		.
	rst 38h			;5a92	ff		.
	rst 38h			;5a93	ff		.
	rst 38h			;5a94	ff		.
	rst 38h			;5a95	ff		.
	rst 38h			;5a96	ff		.
	rst 38h			;5a97	ff		.
	rst 38h			;5a98	ff		.
	rst 38h			;5a99	ff		.
	rst 38h			;5a9a	ff		.
	rst 38h			;5a9b	ff		.
	rst 38h			;5a9c	ff		.
	rst 38h			;5a9d	ff		.
	rst 38h			;5a9e	ff		.
	rst 38h			;5a9f	ff		.
	rst 38h			;5aa0	ff		.
	rst 38h			;5aa1	ff		.
	rst 38h			;5aa2	ff		.
	rst 38h			;5aa3	ff		.
	rst 38h			;5aa4	ff		.
	rst 38h			;5aa5	ff		.
	rst 38h			;5aa6	ff		.
	rst 38h			;5aa7	ff		.
	rst 38h			;5aa8	ff		.
	rst 38h			;5aa9	ff		.
	rst 38h			;5aaa	ff		.
	rst 38h			;5aab	ff		.
	rst 38h			;5aac	ff		.
	rst 38h			;5aad	ff		.
	rst 38h			;5aae	ff		.
	rst 38h			;5aaf	ff		.
	rst 38h			;5ab0	ff		.
	rst 38h			;5ab1	ff		.
	rst 38h			;5ab2	ff		.
	rst 38h			;5ab3	ff		.
	rst 38h			;5ab4	ff		.
	rst 38h			;5ab5	ff		.
	rst 38h			;5ab6	ff		.
	rst 38h			;5ab7	ff		.
	rst 38h			;5ab8	ff		.
	rst 38h			;5ab9	ff		.
	rst 38h			;5aba	ff		.
	rst 38h			;5abb	ff		.
	rst 38h			;5abc	ff		.
	rst 38h			;5abd	ff		.
	rst 38h			;5abe	ff		.
	rst 38h			;5abf	ff		.
	rst 38h			;5ac0	ff		.
	rst 38h			;5ac1	ff		.
	rst 38h			;5ac2	ff		.
	rst 38h			;5ac3	ff		.
	rst 38h			;5ac4	ff		.
	rst 38h			;5ac5	ff		.
	rst 38h			;5ac6	ff		.
	rst 38h			;5ac7	ff		.
	rst 38h			;5ac8	ff		.
	rst 38h			;5ac9	ff		.
	rst 38h			;5aca	ff		.
	rst 38h			;5acb	ff		.
	rst 38h			;5acc	ff		.
	rst 38h			;5acd	ff		.
	rst 38h			;5ace	ff		.
	rst 38h			;5acf	ff		.
	rst 38h			;5ad0	ff		.
	rst 38h			;5ad1	ff		.
	rst 38h			;5ad2	ff		.
	rst 38h			;5ad3	ff		.
	rst 38h			;5ad4	ff		.
	rst 38h			;5ad5	ff		.
	rst 38h			;5ad6	ff		.
	rst 38h			;5ad7	ff		.
	rst 38h			;5ad8	ff		.
	rst 38h			;5ad9	ff		.
	rst 38h			;5ada	ff		.
	rst 38h			;5adb	ff		.
	rst 38h			;5adc	ff		.
	rst 38h			;5add	ff		.
	rst 38h			;5ade	ff		.
	rst 38h			;5adf	ff		.
	rst 38h			;5ae0	ff		.
	rst 38h			;5ae1	ff		.
	rst 38h			;5ae2	ff		.
	rst 38h			;5ae3	ff		.
	rst 38h			;5ae4	ff		.
	rst 38h			;5ae5	ff		.
	rst 38h			;5ae6	ff		.
	rst 38h			;5ae7	ff		.
	rst 38h			;5ae8	ff		.
	rst 38h			;5ae9	ff		.
	rst 38h			;5aea	ff		.
	rst 38h			;5aeb	ff		.
	rst 38h			;5aec	ff		.
	rst 38h			;5aed	ff		.
	rst 38h			;5aee	ff		.
	rst 38h			;5aef	ff		.
	rst 38h			;5af0	ff		.
	rst 38h			;5af1	ff		.
	rst 38h			;5af2	ff		.
	rst 38h			;5af3	ff		.
	rst 38h			;5af4	ff		.
	rst 38h			;5af5	ff		.
	rst 38h			;5af6	ff		.
	rst 38h			;5af7	ff		.
	rst 38h			;5af8	ff		.
	rst 38h			;5af9	ff		.
	rst 38h			;5afa	ff		.
	rst 38h			;5afb	ff		.
	rst 38h			;5afc	ff		.
	rst 38h			;5afd	ff		.
	rst 38h			;5afe	ff		.
	rst 38h			;5aff	ff		.
	rst 38h			;5b00	ff		.
	rst 38h			;5b01	ff		.
	rst 38h			;5b02	ff		.
	rst 38h			;5b03	ff		.
	rst 38h			;5b04	ff		.
	rst 38h			;5b05	ff		.
	rst 38h			;5b06	ff		.
	rst 38h			;5b07	ff		.
	rst 38h			;5b08	ff		.
	rst 38h			;5b09	ff		.
	rst 38h			;5b0a	ff		.
	rst 38h			;5b0b	ff		.
	rst 38h			;5b0c	ff		.
	rst 38h			;5b0d	ff		.
	rst 38h			;5b0e	ff		.
	rst 38h			;5b0f	ff		.
	rst 38h			;5b10	ff		.
	rst 38h			;5b11	ff		.
	rst 38h			;5b12	ff		.
	rst 38h			;5b13	ff		.
	rst 38h			;5b14	ff		.
	rst 38h			;5b15	ff		.
	rst 38h			;5b16	ff		.
	rst 38h			;5b17	ff		.
	rst 38h			;5b18	ff		.
	rst 38h			;5b19	ff		.
	rst 38h			;5b1a	ff		.
	rst 38h			;5b1b	ff		.
	rst 38h			;5b1c	ff		.
	rst 38h			;5b1d	ff		.
	rst 38h			;5b1e	ff		.
	rst 38h			;5b1f	ff		.
	rst 38h			;5b20	ff		.
	rst 38h			;5b21	ff		.
	rst 38h			;5b22	ff		.
	rst 38h			;5b23	ff		.
	rst 38h			;5b24	ff		.
	rst 38h			;5b25	ff		.
	rst 38h			;5b26	ff		.
	rst 38h			;5b27	ff		.
	rst 38h			;5b28	ff		.
	rst 38h			;5b29	ff		.
	rst 38h			;5b2a	ff		.
	rst 38h			;5b2b	ff		.
	rst 38h			;5b2c	ff		.
	rst 38h			;5b2d	ff		.
	rst 38h			;5b2e	ff		.
	rst 38h			;5b2f	ff		.
	rst 38h			;5b30	ff		.
	rst 38h			;5b31	ff		.
	rst 38h			;5b32	ff		.
	rst 38h			;5b33	ff		.
	rst 38h			;5b34	ff		.
	rst 38h			;5b35	ff		.
	rst 38h			;5b36	ff		.
	rst 38h			;5b37	ff		.
	rst 38h			;5b38	ff		.
	rst 38h			;5b39	ff		.
	rst 38h			;5b3a	ff		.
	rst 38h			;5b3b	ff		.
	rst 38h			;5b3c	ff		.
	rst 38h			;5b3d	ff		.
	rst 38h			;5b3e	ff		.
	rst 38h			;5b3f	ff		.
	rst 38h			;5b40	ff		.
	rst 38h			;5b41	ff		.
	rst 38h			;5b42	ff		.
	rst 38h			;5b43	ff		.
	rst 38h			;5b44	ff		.
	rst 38h			;5b45	ff		.
	rst 38h			;5b46	ff		.
	rst 38h			;5b47	ff		.
	rst 38h			;5b48	ff		.
	rst 38h			;5b49	ff		.
	rst 38h			;5b4a	ff		.
	rst 38h			;5b4b	ff		.
	rst 38h			;5b4c	ff		.
	rst 38h			;5b4d	ff		.
	rst 38h			;5b4e	ff		.
	rst 38h			;5b4f	ff		.
	rst 38h			;5b50	ff		.
	rst 38h			;5b51	ff		.
	rst 38h			;5b52	ff		.
	rst 38h			;5b53	ff		.
	rst 38h			;5b54	ff		.
	rst 38h			;5b55	ff		.
	rst 38h			;5b56	ff		.
	rst 38h			;5b57	ff		.
	rst 38h			;5b58	ff		.
	rst 38h			;5b59	ff		.
	rst 38h			;5b5a	ff		.
	rst 38h			;5b5b	ff		.
	rst 38h			;5b5c	ff		.
	rst 38h			;5b5d	ff		.
	rst 38h			;5b5e	ff		.
	rst 38h			;5b5f	ff		.
	rst 38h			;5b60	ff		.
	rst 38h			;5b61	ff		.
	rst 38h			;5b62	ff		.
	rst 38h			;5b63	ff		.
	rst 38h			;5b64	ff		.
	rst 38h			;5b65	ff		.
	rst 38h			;5b66	ff		.
	rst 38h			;5b67	ff		.
	rst 38h			;5b68	ff		.
	rst 38h			;5b69	ff		.
	rst 38h			;5b6a	ff		.
	rst 38h			;5b6b	ff		.
	rst 38h			;5b6c	ff		.
	rst 38h			;5b6d	ff		.
	rst 38h			;5b6e	ff		.
	rst 38h			;5b6f	ff		.
	rst 38h			;5b70	ff		.
	rst 38h			;5b71	ff		.
	rst 38h			;5b72	ff		.
	rst 38h			;5b73	ff		.
	rst 38h			;5b74	ff		.
	rst 38h			;5b75	ff		.
	rst 38h			;5b76	ff		.
	rst 38h			;5b77	ff		.
	rst 38h			;5b78	ff		.
	rst 38h			;5b79	ff		.
	rst 38h			;5b7a	ff		.
	rst 38h			;5b7b	ff		.
	rst 38h			;5b7c	ff		.
	rst 38h			;5b7d	ff		.
	rst 38h			;5b7e	ff		.
	rst 38h			;5b7f	ff		.
	rst 38h			;5b80	ff		.
	rst 38h			;5b81	ff		.
	rst 38h			;5b82	ff		.
	rst 38h			;5b83	ff		.
	rst 38h			;5b84	ff		.
	rst 38h			;5b85	ff		.
	rst 38h			;5b86	ff		.
	rst 38h			;5b87	ff		.
	rst 38h			;5b88	ff		.
	rst 38h			;5b89	ff		.
	rst 38h			;5b8a	ff		.
	rst 38h			;5b8b	ff		.
	rst 38h			;5b8c	ff		.
	rst 38h			;5b8d	ff		.
	rst 38h			;5b8e	ff		.
	rst 38h			;5b8f	ff		.
	rst 38h			;5b90	ff		.
	rst 38h			;5b91	ff		.
	rst 38h			;5b92	ff		.
	rst 38h			;5b93	ff		.
	rst 38h			;5b94	ff		.
	rst 38h			;5b95	ff		.
	rst 38h			;5b96	ff		.
	rst 38h			;5b97	ff		.
	rst 38h			;5b98	ff		.
	rst 38h			;5b99	ff		.
	rst 38h			;5b9a	ff		.
	rst 38h			;5b9b	ff		.
	rst 38h			;5b9c	ff		.
	rst 38h			;5b9d	ff		.
	rst 38h			;5b9e	ff		.
	rst 38h			;5b9f	ff		.
	rst 38h			;5ba0	ff		.
	rst 38h			;5ba1	ff		.
	rst 38h			;5ba2	ff		.
	rst 38h			;5ba3	ff		.
	rst 38h			;5ba4	ff		.
	rst 38h			;5ba5	ff		.
	rst 38h			;5ba6	ff		.
	rst 38h			;5ba7	ff		.
	rst 38h			;5ba8	ff		.
	rst 38h			;5ba9	ff		.
	rst 38h			;5baa	ff		.
	rst 38h			;5bab	ff		.
	rst 38h			;5bac	ff		.
	rst 38h			;5bad	ff		.
	rst 38h			;5bae	ff		.
	rst 38h			;5baf	ff		.
	rst 38h			;5bb0	ff		.
	rst 38h			;5bb1	ff		.
	rst 38h			;5bb2	ff		.
	rst 38h			;5bb3	ff		.
	rst 38h			;5bb4	ff		.
	rst 38h			;5bb5	ff		.
	rst 38h			;5bb6	ff		.
	rst 38h			;5bb7	ff		.
	rst 38h			;5bb8	ff		.
	rst 38h			;5bb9	ff		.
	rst 38h			;5bba	ff		.
	rst 38h			;5bbb	ff		.
	rst 38h			;5bbc	ff		.
	rst 38h			;5bbd	ff		.
	rst 38h			;5bbe	ff		.
	rst 38h			;5bbf	ff		.
	rst 38h			;5bc0	ff		.
	rst 38h			;5bc1	ff		.
	rst 38h			;5bc2	ff		.
	rst 38h			;5bc3	ff		.
	rst 38h			;5bc4	ff		.
	rst 38h			;5bc5	ff		.
	rst 38h			;5bc6	ff		.
	rst 38h			;5bc7	ff		.
	rst 38h			;5bc8	ff		.
	rst 38h			;5bc9	ff		.
	rst 38h			;5bca	ff		.
	rst 38h			;5bcb	ff		.
	rst 38h			;5bcc	ff		.
	rst 38h			;5bcd	ff		.
	rst 38h			;5bce	ff		.
	rst 38h			;5bcf	ff		.
	rst 38h			;5bd0	ff		.
	rst 38h			;5bd1	ff		.
	rst 38h			;5bd2	ff		.
	rst 38h			;5bd3	ff		.
	rst 38h			;5bd4	ff		.
	rst 38h			;5bd5	ff		.
	rst 38h			;5bd6	ff		.
	rst 38h			;5bd7	ff		.
	rst 38h			;5bd8	ff		.
	rst 38h			;5bd9	ff		.
	rst 38h			;5bda	ff		.
	rst 38h			;5bdb	ff		.
	rst 38h			;5bdc	ff		.
	rst 38h			;5bdd	ff		.
	rst 38h			;5bde	ff		.
	rst 38h			;5bdf	ff		.
	rst 38h			;5be0	ff		.
	rst 38h			;5be1	ff		.
	rst 38h			;5be2	ff		.
	rst 38h			;5be3	ff		.
	rst 38h			;5be4	ff		.
	rst 38h			;5be5	ff		.
	rst 38h			;5be6	ff		.
	rst 38h			;5be7	ff		.
	rst 38h			;5be8	ff		.
	rst 38h			;5be9	ff		.
	rst 38h			;5bea	ff		.
	rst 38h			;5beb	ff		.
	rst 38h			;5bec	ff		.
	rst 38h			;5bed	ff		.
	rst 38h			;5bee	ff		.
	rst 38h			;5bef	ff		.
	rst 38h			;5bf0	ff		.
	rst 38h			;5bf1	ff		.
	rst 38h			;5bf2	ff		.
	rst 38h			;5bf3	ff		.
	rst 38h			;5bf4	ff		.
	rst 38h			;5bf5	ff		.
	rst 38h			;5bf6	ff		.
	rst 38h			;5bf7	ff		.
	rst 38h			;5bf8	ff		.
	rst 38h			;5bf9	ff		.
	rst 38h			;5bfa	ff		.
	rst 38h			;5bfb	ff		.
	rst 38h			;5bfc	ff		.
	rst 38h			;5bfd	ff		.
	rst 38h			;5bfe	ff		.
	rst 38h			;5bff	ff		.
	rst 38h			;5c00	ff		.
	rst 38h			;5c01	ff		.
	rst 38h			;5c02	ff		.
	rst 38h			;5c03	ff		.
	rst 38h			;5c04	ff		.
	rst 38h			;5c05	ff		.
	rst 38h			;5c06	ff		.
	rst 38h			;5c07	ff		.
	rst 38h			;5c08	ff		.
	rst 38h			;5c09	ff		.
	rst 38h			;5c0a	ff		.
	rst 38h			;5c0b	ff		.
	rst 38h			;5c0c	ff		.
	rst 38h			;5c0d	ff		.
	rst 38h			;5c0e	ff		.
	rst 38h			;5c0f	ff		.
	rst 38h			;5c10	ff		.
	rst 38h			;5c11	ff		.
	rst 38h			;5c12	ff		.
	rst 38h			;5c13	ff		.
	rst 38h			;5c14	ff		.
	rst 38h			;5c15	ff		.
	rst 38h			;5c16	ff		.
	rst 38h			;5c17	ff		.
	rst 38h			;5c18	ff		.
	rst 38h			;5c19	ff		.
	rst 38h			;5c1a	ff		.
	rst 38h			;5c1b	ff		.
	rst 38h			;5c1c	ff		.
	rst 38h			;5c1d	ff		.
	rst 38h			;5c1e	ff		.
	rst 38h			;5c1f	ff		.
	rst 38h			;5c20	ff		.
	rst 38h			;5c21	ff		.
	rst 38h			;5c22	ff		.
	rst 38h			;5c23	ff		.
	rst 38h			;5c24	ff		.
	rst 38h			;5c25	ff		.
	rst 38h			;5c26	ff		.
l5c27h:
	rst 38h			;5c27	ff		.
	rst 38h			;5c28	ff		.
	rst 38h			;5c29	ff		.
	rst 38h			;5c2a	ff		.
	rst 38h			;5c2b	ff		.
	rst 38h			;5c2c	ff		.
	rst 38h			;5c2d	ff		.
	rst 38h			;5c2e	ff		.
	rst 38h			;5c2f	ff		.
	rst 38h			;5c30	ff		.
	rst 38h			;5c31	ff		.
	rst 38h			;5c32	ff		.
	rst 38h			;5c33	ff		.
	rst 38h			;5c34	ff		.
	rst 38h			;5c35	ff		.
	rst 38h			;5c36	ff		.
	rst 38h			;5c37	ff		.
	rst 38h			;5c38	ff		.
	rst 38h			;5c39	ff		.
	rst 38h			;5c3a	ff		.
	rst 38h			;5c3b	ff		.
	rst 38h			;5c3c	ff		.
	rst 38h			;5c3d	ff		.
	rst 38h			;5c3e	ff		.
	rst 38h			;5c3f	ff		.
	rst 38h			;5c40	ff		.
	rst 38h			;5c41	ff		.
	rst 38h			;5c42	ff		.
	rst 38h			;5c43	ff		.
	rst 38h			;5c44	ff		.
	rst 38h			;5c45	ff		.
	rst 38h			;5c46	ff		.
	rst 38h			;5c47	ff		.
	rst 38h			;5c48	ff		.
	rst 38h			;5c49	ff		.
	rst 38h			;5c4a	ff		.
	rst 38h			;5c4b	ff		.
	rst 38h			;5c4c	ff		.
	rst 38h			;5c4d	ff		.
	rst 38h			;5c4e	ff		.
	rst 38h			;5c4f	ff		.
	rst 38h			;5c50	ff		.
	rst 38h			;5c51	ff		.
	rst 38h			;5c52	ff		.
	rst 38h			;5c53	ff		.
	rst 38h			;5c54	ff		.
	rst 38h			;5c55	ff		.
	rst 38h			;5c56	ff		.
	rst 38h			;5c57	ff		.
	rst 38h			;5c58	ff		.
	rst 38h			;5c59	ff		.
	rst 38h			;5c5a	ff		.
	rst 38h			;5c5b	ff		.
	rst 38h			;5c5c	ff		.
	rst 38h			;5c5d	ff		.
	rst 38h			;5c5e	ff		.
	rst 38h			;5c5f	ff		.
	rst 38h			;5c60	ff		.
	rst 38h			;5c61	ff		.
	rst 38h			;5c62	ff		.
	rst 38h			;5c63	ff		.
	rst 38h			;5c64	ff		.
	rst 38h			;5c65	ff		.
	rst 38h			;5c66	ff		.
	rst 38h			;5c67	ff		.
	rst 38h			;5c68	ff		.
	rst 38h			;5c69	ff		.
	rst 38h			;5c6a	ff		.
	rst 38h			;5c6b	ff		.
	rst 38h			;5c6c	ff		.
	rst 38h			;5c6d	ff		.
	rst 38h			;5c6e	ff		.
	rst 38h			;5c6f	ff		.
	rst 38h			;5c70	ff		.
	rst 38h			;5c71	ff		.
	rst 38h			;5c72	ff		.
	rst 38h			;5c73	ff		.
	rst 38h			;5c74	ff		.
	rst 38h			;5c75	ff		.
	rst 38h			;5c76	ff		.
	rst 38h			;5c77	ff		.
	rst 38h			;5c78	ff		.
	rst 38h			;5c79	ff		.
	rst 38h			;5c7a	ff		.
	rst 38h			;5c7b	ff		.
	rst 38h			;5c7c	ff		.
	rst 38h			;5c7d	ff		.
	rst 38h			;5c7e	ff		.
	rst 38h			;5c7f	ff		.
	rst 38h			;5c80	ff		.
	rst 38h			;5c81	ff		.
	rst 38h			;5c82	ff		.
	rst 38h			;5c83	ff		.
	rst 38h			;5c84	ff		.
	rst 38h			;5c85	ff		.
	rst 38h			;5c86	ff		.
	rst 38h			;5c87	ff		.
	rst 38h			;5c88	ff		.
	rst 38h			;5c89	ff		.
	rst 38h			;5c8a	ff		.
	rst 38h			;5c8b	ff		.
	rst 38h			;5c8c	ff		.
	rst 38h			;5c8d	ff		.
	rst 38h			;5c8e	ff		.
	rst 38h			;5c8f	ff		.
	rst 38h			;5c90	ff		.
	rst 38h			;5c91	ff		.
	rst 38h			;5c92	ff		.
	rst 38h			;5c93	ff		.
	rst 38h			;5c94	ff		.
	rst 38h			;5c95	ff		.
	rst 38h			;5c96	ff		.
	rst 38h			;5c97	ff		.
	rst 38h			;5c98	ff		.
	rst 38h			;5c99	ff		.
	rst 38h			;5c9a	ff		.
	rst 38h			;5c9b	ff		.
	rst 38h			;5c9c	ff		.
	rst 38h			;5c9d	ff		.
	rst 38h			;5c9e	ff		.
	rst 38h			;5c9f	ff		.
	rst 38h			;5ca0	ff		.
	rst 38h			;5ca1	ff		.
	rst 38h			;5ca2	ff		.
	rst 38h			;5ca3	ff		.
	rst 38h			;5ca4	ff		.
	rst 38h			;5ca5	ff		.
	rst 38h			;5ca6	ff		.
	rst 38h			;5ca7	ff		.
	rst 38h			;5ca8	ff		.
	rst 38h			;5ca9	ff		.
	rst 38h			;5caa	ff		.
	rst 38h			;5cab	ff		.
	rst 38h			;5cac	ff		.
	rst 38h			;5cad	ff		.
	rst 38h			;5cae	ff		.
	rst 38h			;5caf	ff		.
	rst 38h			;5cb0	ff		.
	rst 38h			;5cb1	ff		.
	rst 38h			;5cb2	ff		.
	rst 38h			;5cb3	ff		.
	rst 38h			;5cb4	ff		.
	rst 38h			;5cb5	ff		.
	rst 38h			;5cb6	ff		.
	rst 38h			;5cb7	ff		.
	rst 38h			;5cb8	ff		.
	rst 38h			;5cb9	ff		.
	rst 38h			;5cba	ff		.
	rst 38h			;5cbb	ff		.
	rst 38h			;5cbc	ff		.
	rst 38h			;5cbd	ff		.
	rst 38h			;5cbe	ff		.
	rst 38h			;5cbf	ff		.
	rst 38h			;5cc0	ff		.
	rst 38h			;5cc1	ff		.
	rst 38h			;5cc2	ff		.
	rst 38h			;5cc3	ff		.
	rst 38h			;5cc4	ff		.
	rst 38h			;5cc5	ff		.
	rst 38h			;5cc6	ff		.
	rst 38h			;5cc7	ff		.
	rst 38h			;5cc8	ff		.
	rst 38h			;5cc9	ff		.
	rst 38h			;5cca	ff		.
	rst 38h			;5ccb	ff		.
	rst 38h			;5ccc	ff		.
	rst 38h			;5ccd	ff		.
	rst 38h			;5cce	ff		.
	rst 38h			;5ccf	ff		.
	rst 38h			;5cd0	ff		.
	rst 38h			;5cd1	ff		.
	rst 38h			;5cd2	ff		.
	rst 38h			;5cd3	ff		.
	rst 38h			;5cd4	ff		.
	rst 38h			;5cd5	ff		.
	rst 38h			;5cd6	ff		.
	rst 38h			;5cd7	ff		.
	rst 38h			;5cd8	ff		.
	rst 38h			;5cd9	ff		.
	rst 38h			;5cda	ff		.
	rst 38h			;5cdb	ff		.
	rst 38h			;5cdc	ff		.
	rst 38h			;5cdd	ff		.
	rst 38h			;5cde	ff		.
	rst 38h			;5cdf	ff		.
	rst 38h			;5ce0	ff		.
	rst 38h			;5ce1	ff		.
	rst 38h			;5ce2	ff		.
	rst 38h			;5ce3	ff		.
	rst 38h			;5ce4	ff		.
	rst 38h			;5ce5	ff		.
	rst 38h			;5ce6	ff		.
	rst 38h			;5ce7	ff		.
	rst 38h			;5ce8	ff		.
	rst 38h			;5ce9	ff		.
	rst 38h			;5cea	ff		.
	rst 38h			;5ceb	ff		.
	rst 38h			;5cec	ff		.
	rst 38h			;5ced	ff		.
	rst 38h			;5cee	ff		.
	rst 38h			;5cef	ff		.
	rst 38h			;5cf0	ff		.
	rst 38h			;5cf1	ff		.
	rst 38h			;5cf2	ff		.
	rst 38h			;5cf3	ff		.
	rst 38h			;5cf4	ff		.
	rst 38h			;5cf5	ff		.
	rst 38h			;5cf6	ff		.
	rst 38h			;5cf7	ff		.
	rst 38h			;5cf8	ff		.
	rst 38h			;5cf9	ff		.
	rst 38h			;5cfa	ff		.
	rst 38h			;5cfb	ff		.
	rst 38h			;5cfc	ff		.
	rst 38h			;5cfd	ff		.
	rst 38h			;5cfe	ff		.
	rst 38h			;5cff	ff		.
	rst 38h			;5d00	ff		.
	rst 38h			;5d01	ff		.
	rst 38h			;5d02	ff		.
	rst 38h			;5d03	ff		.
	rst 38h			;5d04	ff		.
	rst 38h			;5d05	ff		.
	rst 38h			;5d06	ff		.
	rst 38h			;5d07	ff		.
	rst 38h			;5d08	ff		.
	rst 38h			;5d09	ff		.
	rst 38h			;5d0a	ff		.
	rst 38h			;5d0b	ff		.
	rst 38h			;5d0c	ff		.
	rst 38h			;5d0d	ff		.
	rst 38h			;5d0e	ff		.
	rst 38h			;5d0f	ff		.
	rst 38h			;5d10	ff		.
	rst 38h			;5d11	ff		.
	rst 38h			;5d12	ff		.
	rst 38h			;5d13	ff		.
	rst 38h			;5d14	ff		.
	rst 38h			;5d15	ff		.
	rst 38h			;5d16	ff		.
	rst 38h			;5d17	ff		.
	rst 38h			;5d18	ff		.
	rst 38h			;5d19	ff		.
	rst 38h			;5d1a	ff		.
	rst 38h			;5d1b	ff		.
	rst 38h			;5d1c	ff		.
	rst 38h			;5d1d	ff		.
	rst 38h			;5d1e	ff		.
	rst 38h			;5d1f	ff		.
	rst 38h			;5d20	ff		.
	rst 38h			;5d21	ff		.
	rst 38h			;5d22	ff		.
	rst 38h			;5d23	ff		.
	rst 38h			;5d24	ff		.
	rst 38h			;5d25	ff		.
	rst 38h			;5d26	ff		.
	rst 38h			;5d27	ff		.
	rst 38h			;5d28	ff		.
	rst 38h			;5d29	ff		.
	rst 38h			;5d2a	ff		.
	rst 38h			;5d2b	ff		.
	rst 38h			;5d2c	ff		.
	rst 38h			;5d2d	ff		.
	rst 38h			;5d2e	ff		.
	rst 38h			;5d2f	ff		.
	rst 38h			;5d30	ff		.
	rst 38h			;5d31	ff		.
	rst 38h			;5d32	ff		.
	rst 38h			;5d33	ff		.
	rst 38h			;5d34	ff		.
	rst 38h			;5d35	ff		.
	rst 38h			;5d36	ff		.
	rst 38h			;5d37	ff		.
	rst 38h			;5d38	ff		.
	rst 38h			;5d39	ff		.
	rst 38h			;5d3a	ff		.
	rst 38h			;5d3b	ff		.
	rst 38h			;5d3c	ff		.
	rst 38h			;5d3d	ff		.
	rst 38h			;5d3e	ff		.
	rst 38h			;5d3f	ff		.
	rst 38h			;5d40	ff		.
	rst 38h			;5d41	ff		.
	rst 38h			;5d42	ff		.
	rst 38h			;5d43	ff		.
	rst 38h			;5d44	ff		.
	rst 38h			;5d45	ff		.
	rst 38h			;5d46	ff		.
	rst 38h			;5d47	ff		.
	rst 38h			;5d48	ff		.
	rst 38h			;5d49	ff		.
	rst 38h			;5d4a	ff		.
	rst 38h			;5d4b	ff		.
	rst 38h			;5d4c	ff		.
	rst 38h			;5d4d	ff		.
	rst 38h			;5d4e	ff		.
	rst 38h			;5d4f	ff		.
	rst 38h			;5d50	ff		.
	rst 38h			;5d51	ff		.
	rst 38h			;5d52	ff		.
	rst 38h			;5d53	ff		.
	rst 38h			;5d54	ff		.
	rst 38h			;5d55	ff		.
	rst 38h			;5d56	ff		.
	rst 38h			;5d57	ff		.
	rst 38h			;5d58	ff		.
	rst 38h			;5d59	ff		.
	rst 38h			;5d5a	ff		.
	rst 38h			;5d5b	ff		.
	rst 38h			;5d5c	ff		.
	rst 38h			;5d5d	ff		.
	rst 38h			;5d5e	ff		.
	rst 38h			;5d5f	ff		.
	rst 38h			;5d60	ff		.
	rst 38h			;5d61	ff		.
	rst 38h			;5d62	ff		.
	rst 38h			;5d63	ff		.
	rst 38h			;5d64	ff		.
	rst 38h			;5d65	ff		.
	rst 38h			;5d66	ff		.
	rst 38h			;5d67	ff		.
	rst 38h			;5d68	ff		.
	rst 38h			;5d69	ff		.
	rst 38h			;5d6a	ff		.
	rst 38h			;5d6b	ff		.
	rst 38h			;5d6c	ff		.
	rst 38h			;5d6d	ff		.
	rst 38h			;5d6e	ff		.
	rst 38h			;5d6f	ff		.
	rst 38h			;5d70	ff		.
	rst 38h			;5d71	ff		.
	rst 38h			;5d72	ff		.
	rst 38h			;5d73	ff		.
	rst 38h			;5d74	ff		.
	rst 38h			;5d75	ff		.
	rst 38h			;5d76	ff		.
	rst 38h			;5d77	ff		.
	rst 38h			;5d78	ff		.
	rst 38h			;5d79	ff		.
	rst 38h			;5d7a	ff		.
	rst 38h			;5d7b	ff		.
	rst 38h			;5d7c	ff		.
	rst 38h			;5d7d	ff		.
	rst 38h			;5d7e	ff		.
	rst 38h			;5d7f	ff		.
	rst 38h			;5d80	ff		.
	rst 38h			;5d81	ff		.
	rst 38h			;5d82	ff		.
	rst 38h			;5d83	ff		.
	rst 38h			;5d84	ff		.
	rst 38h			;5d85	ff		.
	rst 38h			;5d86	ff		.
	rst 38h			;5d87	ff		.
	rst 38h			;5d88	ff		.
	rst 38h			;5d89	ff		.
	rst 38h			;5d8a	ff		.
	rst 38h			;5d8b	ff		.
	rst 38h			;5d8c	ff		.
	rst 38h			;5d8d	ff		.
	rst 38h			;5d8e	ff		.
	rst 38h			;5d8f	ff		.
	rst 38h			;5d90	ff		.
	rst 38h			;5d91	ff		.
	rst 38h			;5d92	ff		.
	rst 38h			;5d93	ff		.
	rst 38h			;5d94	ff		.
	rst 38h			;5d95	ff		.
	rst 38h			;5d96	ff		.
	rst 38h			;5d97	ff		.
	rst 38h			;5d98	ff		.
	rst 38h			;5d99	ff		.
	rst 38h			;5d9a	ff		.
	rst 38h			;5d9b	ff		.
	rst 38h			;5d9c	ff		.
	rst 38h			;5d9d	ff		.
	rst 38h			;5d9e	ff		.
	rst 38h			;5d9f	ff		.
	rst 38h			;5da0	ff		.
	rst 38h			;5da1	ff		.
	rst 38h			;5da2	ff		.
	rst 38h			;5da3	ff		.
	rst 38h			;5da4	ff		.
	rst 38h			;5da5	ff		.
	rst 38h			;5da6	ff		.
	rst 38h			;5da7	ff		.
	rst 38h			;5da8	ff		.
	rst 38h			;5da9	ff		.
	rst 38h			;5daa	ff		.
	rst 38h			;5dab	ff		.
	rst 38h			;5dac	ff		.
	rst 38h			;5dad	ff		.
	rst 38h			;5dae	ff		.
	rst 38h			;5daf	ff		.
	rst 38h			;5db0	ff		.
	rst 38h			;5db1	ff		.
	rst 38h			;5db2	ff		.
	rst 38h			;5db3	ff		.
	rst 38h			;5db4	ff		.
	rst 38h			;5db5	ff		.
	rst 38h			;5db6	ff		.
	rst 38h			;5db7	ff		.
	rst 38h			;5db8	ff		.
	rst 38h			;5db9	ff		.
	rst 38h			;5dba	ff		.
	rst 38h			;5dbb	ff		.
	rst 38h			;5dbc	ff		.
	rst 38h			;5dbd	ff		.
	rst 38h			;5dbe	ff		.
	rst 38h			;5dbf	ff		.
	rst 38h			;5dc0	ff		.
	rst 38h			;5dc1	ff		.
	rst 38h			;5dc2	ff		.
	rst 38h			;5dc3	ff		.
	rst 38h			;5dc4	ff		.
	rst 38h			;5dc5	ff		.
	rst 38h			;5dc6	ff		.
	rst 38h			;5dc7	ff		.
	rst 38h			;5dc8	ff		.
	rst 38h			;5dc9	ff		.
	rst 38h			;5dca	ff		.
	rst 38h			;5dcb	ff		.
	rst 38h			;5dcc	ff		.
	rst 38h			;5dcd	ff		.
	rst 38h			;5dce	ff		.
	rst 38h			;5dcf	ff		.
	rst 38h			;5dd0	ff		.
	rst 38h			;5dd1	ff		.
	rst 38h			;5dd2	ff		.
	rst 38h			;5dd3	ff		.
	rst 38h			;5dd4	ff		.
	rst 38h			;5dd5	ff		.
	rst 38h			;5dd6	ff		.
	rst 38h			;5dd7	ff		.
	rst 38h			;5dd8	ff		.
	rst 38h			;5dd9	ff		.
	rst 38h			;5dda	ff		.
	rst 38h			;5ddb	ff		.
	rst 38h			;5ddc	ff		.
	rst 38h			;5ddd	ff		.
	rst 38h			;5dde	ff		.
	rst 38h			;5ddf	ff		.
	rst 38h			;5de0	ff		.
	rst 38h			;5de1	ff		.
	rst 38h			;5de2	ff		.
	rst 38h			;5de3	ff		.
	rst 38h			;5de4	ff		.
	rst 38h			;5de5	ff		.
	rst 38h			;5de6	ff		.
	rst 38h			;5de7	ff		.
	rst 38h			;5de8	ff		.
	rst 38h			;5de9	ff		.
	rst 38h			;5dea	ff		.
	rst 38h			;5deb	ff		.
	rst 38h			;5dec	ff		.
	rst 38h			;5ded	ff		.
	rst 38h			;5dee	ff		.
	rst 38h			;5def	ff		.
	rst 38h			;5df0	ff		.
	rst 38h			;5df1	ff		.
	rst 38h			;5df2	ff		.
	rst 38h			;5df3	ff		.
	rst 38h			;5df4	ff		.
	rst 38h			;5df5	ff		.
	rst 38h			;5df6	ff		.
	rst 38h			;5df7	ff		.
	rst 38h			;5df8	ff		.
	rst 38h			;5df9	ff		.
	rst 38h			;5dfa	ff		.
	rst 38h			;5dfb	ff		.
	rst 38h			;5dfc	ff		.
	rst 38h			;5dfd	ff		.
	rst 38h			;5dfe	ff		.
	rst 38h			;5dff	ff		.
	rst 38h			;5e00	ff		.
	rst 38h			;5e01	ff		.
	rst 38h			;5e02	ff		.
	rst 38h			;5e03	ff		.
	rst 38h			;5e04	ff		.
	rst 38h			;5e05	ff		.
	rst 38h			;5e06	ff		.
	rst 38h			;5e07	ff		.
	rst 38h			;5e08	ff		.
	rst 38h			;5e09	ff		.
	rst 38h			;5e0a	ff		.
	rst 38h			;5e0b	ff		.
	rst 38h			;5e0c	ff		.
	rst 38h			;5e0d	ff		.
	rst 38h			;5e0e	ff		.
	rst 38h			;5e0f	ff		.
	rst 38h			;5e10	ff		.
	rst 38h			;5e11	ff		.
	rst 38h			;5e12	ff		.
	rst 38h			;5e13	ff		.
	rst 38h			;5e14	ff		.
	rst 38h			;5e15	ff		.
	rst 38h			;5e16	ff		.
	rst 38h			;5e17	ff		.
	rst 38h			;5e18	ff		.
	rst 38h			;5e19	ff		.
	rst 38h			;5e1a	ff		.
	rst 38h			;5e1b	ff		.
	rst 38h			;5e1c	ff		.
	rst 38h			;5e1d	ff		.
	rst 38h			;5e1e	ff		.
	rst 38h			;5e1f	ff		.
	rst 38h			;5e20	ff		.
	rst 38h			;5e21	ff		.
	rst 38h			;5e22	ff		.
	rst 38h			;5e23	ff		.
	rst 38h			;5e24	ff		.
	rst 38h			;5e25	ff		.
	rst 38h			;5e26	ff		.
	rst 38h			;5e27	ff		.
	rst 38h			;5e28	ff		.
	rst 38h			;5e29	ff		.
	rst 38h			;5e2a	ff		.
	rst 38h			;5e2b	ff		.
	rst 38h			;5e2c	ff		.
	rst 38h			;5e2d	ff		.
	rst 38h			;5e2e	ff		.
	rst 38h			;5e2f	ff		.
	rst 38h			;5e30	ff		.
	rst 38h			;5e31	ff		.
	rst 38h			;5e32	ff		.
	rst 38h			;5e33	ff		.
	rst 38h			;5e34	ff		.
	rst 38h			;5e35	ff		.
	rst 38h			;5e36	ff		.
	rst 38h			;5e37	ff		.
	rst 38h			;5e38	ff		.
	rst 38h			;5e39	ff		.
	rst 38h			;5e3a	ff		.
	rst 38h			;5e3b	ff		.
	rst 38h			;5e3c	ff		.
	rst 38h			;5e3d	ff		.
	rst 38h			;5e3e	ff		.
	rst 38h			;5e3f	ff		.
	rst 38h			;5e40	ff		.
	rst 38h			;5e41	ff		.
	rst 38h			;5e42	ff		.
	rst 38h			;5e43	ff		.
	rst 38h			;5e44	ff		.
	rst 38h			;5e45	ff		.
	rst 38h			;5e46	ff		.
	rst 38h			;5e47	ff		.
	rst 38h			;5e48	ff		.
	rst 38h			;5e49	ff		.
	rst 38h			;5e4a	ff		.
	rst 38h			;5e4b	ff		.
	rst 38h			;5e4c	ff		.
	rst 38h			;5e4d	ff		.
	rst 38h			;5e4e	ff		.
	rst 38h			;5e4f	ff		.
	rst 38h			;5e50	ff		.
	rst 38h			;5e51	ff		.
	rst 38h			;5e52	ff		.
	rst 38h			;5e53	ff		.
	rst 38h			;5e54	ff		.
	rst 38h			;5e55	ff		.
	rst 38h			;5e56	ff		.
	rst 38h			;5e57	ff		.
	rst 38h			;5e58	ff		.
	rst 38h			;5e59	ff		.
	rst 38h			;5e5a	ff		.
	rst 38h			;5e5b	ff		.
	rst 38h			;5e5c	ff		.
	rst 38h			;5e5d	ff		.
	rst 38h			;5e5e	ff		.
	rst 38h			;5e5f	ff		.
	rst 38h			;5e60	ff		.
	rst 38h			;5e61	ff		.
	rst 38h			;5e62	ff		.
	rst 38h			;5e63	ff		.
	rst 38h			;5e64	ff		.
	rst 38h			;5e65	ff		.
	rst 38h			;5e66	ff		.
	rst 38h			;5e67	ff		.
	rst 38h			;5e68	ff		.
	rst 38h			;5e69	ff		.
	rst 38h			;5e6a	ff		.
	rst 38h			;5e6b	ff		.
	rst 38h			;5e6c	ff		.
	rst 38h			;5e6d	ff		.
	rst 38h			;5e6e	ff		.
	rst 38h			;5e6f	ff		.
	rst 38h			;5e70	ff		.
	rst 38h			;5e71	ff		.
	rst 38h			;5e72	ff		.
	rst 38h			;5e73	ff		.
	rst 38h			;5e74	ff		.
	rst 38h			;5e75	ff		.
	rst 38h			;5e76	ff		.
	rst 38h			;5e77	ff		.
	rst 38h			;5e78	ff		.
	rst 38h			;5e79	ff		.
	rst 38h			;5e7a	ff		.
	rst 38h			;5e7b	ff		.
	rst 38h			;5e7c	ff		.
	rst 38h			;5e7d	ff		.
	rst 38h			;5e7e	ff		.
	rst 38h			;5e7f	ff		.
	rst 38h			;5e80	ff		.
	rst 38h			;5e81	ff		.
	rst 38h			;5e82	ff		.
	rst 38h			;5e83	ff		.
	rst 38h			;5e84	ff		.
	rst 38h			;5e85	ff		.
	rst 38h			;5e86	ff		.
	rst 38h			;5e87	ff		.
	rst 38h			;5e88	ff		.
	rst 38h			;5e89	ff		.
	rst 38h			;5e8a	ff		.
	rst 38h			;5e8b	ff		.
	rst 38h			;5e8c	ff		.
	rst 38h			;5e8d	ff		.
	rst 38h			;5e8e	ff		.
	rst 38h			;5e8f	ff		.
	rst 38h			;5e90	ff		.
	rst 38h			;5e91	ff		.
	rst 38h			;5e92	ff		.
	rst 38h			;5e93	ff		.
	rst 38h			;5e94	ff		.
	rst 38h			;5e95	ff		.
	rst 38h			;5e96	ff		.
	rst 38h			;5e97	ff		.
	rst 38h			;5e98	ff		.
	rst 38h			;5e99	ff		.
	rst 38h			;5e9a	ff		.
	rst 38h			;5e9b	ff		.
	rst 38h			;5e9c	ff		.
	rst 38h			;5e9d	ff		.
	rst 38h			;5e9e	ff		.
	rst 38h			;5e9f	ff		.
	rst 38h			;5ea0	ff		.
	rst 38h			;5ea1	ff		.
	rst 38h			;5ea2	ff		.
	rst 38h			;5ea3	ff		.
	rst 38h			;5ea4	ff		.
	rst 38h			;5ea5	ff		.
	rst 38h			;5ea6	ff		.
	rst 38h			;5ea7	ff		.
	rst 38h			;5ea8	ff		.
	rst 38h			;5ea9	ff		.
	rst 38h			;5eaa	ff		.
	rst 38h			;5eab	ff		.
	rst 38h			;5eac	ff		.
	rst 38h			;5ead	ff		.
	rst 38h			;5eae	ff		.
	rst 38h			;5eaf	ff		.
	rst 38h			;5eb0	ff		.
	rst 38h			;5eb1	ff		.
	rst 38h			;5eb2	ff		.
	rst 38h			;5eb3	ff		.
	rst 38h			;5eb4	ff		.
	rst 38h			;5eb5	ff		.
	rst 38h			;5eb6	ff		.
	rst 38h			;5eb7	ff		.
	rst 38h			;5eb8	ff		.
	rst 38h			;5eb9	ff		.
	rst 38h			;5eba	ff		.
	rst 38h			;5ebb	ff		.
	rst 38h			;5ebc	ff		.
	rst 38h			;5ebd	ff		.
	rst 38h			;5ebe	ff		.
	rst 38h			;5ebf	ff		.
	rst 38h			;5ec0	ff		.
	rst 38h			;5ec1	ff		.
	rst 38h			;5ec2	ff		.
	rst 38h			;5ec3	ff		.
	rst 38h			;5ec4	ff		.
	rst 38h			;5ec5	ff		.
	rst 38h			;5ec6	ff		.
	rst 38h			;5ec7	ff		.
	rst 38h			;5ec8	ff		.
	rst 38h			;5ec9	ff		.
	rst 38h			;5eca	ff		.
	rst 38h			;5ecb	ff		.
	rst 38h			;5ecc	ff		.
	rst 38h			;5ecd	ff		.
	rst 38h			;5ece	ff		.
	rst 38h			;5ecf	ff		.
	rst 38h			;5ed0	ff		.
	rst 38h			;5ed1	ff		.
	rst 38h			;5ed2	ff		.
	rst 38h			;5ed3	ff		.
	rst 38h			;5ed4	ff		.
	rst 38h			;5ed5	ff		.
	rst 38h			;5ed6	ff		.
	rst 38h			;5ed7	ff		.
	rst 38h			;5ed8	ff		.
	rst 38h			;5ed9	ff		.
	rst 38h			;5eda	ff		.
	rst 38h			;5edb	ff		.
	rst 38h			;5edc	ff		.
	rst 38h			;5edd	ff		.
	rst 38h			;5ede	ff		.
	rst 38h			;5edf	ff		.
	rst 38h			;5ee0	ff		.
	rst 38h			;5ee1	ff		.
	rst 38h			;5ee2	ff		.
	rst 38h			;5ee3	ff		.
	rst 38h			;5ee4	ff		.
	rst 38h			;5ee5	ff		.
	rst 38h			;5ee6	ff		.
	rst 38h			;5ee7	ff		.
	rst 38h			;5ee8	ff		.
	rst 38h			;5ee9	ff		.
	rst 38h			;5eea	ff		.
	rst 38h			;5eeb	ff		.
	rst 38h			;5eec	ff		.
	rst 38h			;5eed	ff		.
	rst 38h			;5eee	ff		.
	rst 38h			;5eef	ff		.
	rst 38h			;5ef0	ff		.
	rst 38h			;5ef1	ff		.
	rst 38h			;5ef2	ff		.
	rst 38h			;5ef3	ff		.
	rst 38h			;5ef4	ff		.
	rst 38h			;5ef5	ff		.
	rst 38h			;5ef6	ff		.
	rst 38h			;5ef7	ff		.
	rst 38h			;5ef8	ff		.
	rst 38h			;5ef9	ff		.
	rst 38h			;5efa	ff		.
	rst 38h			;5efb	ff		.
	rst 38h			;5efc	ff		.
	rst 38h			;5efd	ff		.
	rst 38h			;5efe	ff		.
	rst 38h			;5eff	ff		.
	rst 38h			;5f00	ff		.
	rst 38h			;5f01	ff		.
	rst 38h			;5f02	ff		.
	rst 38h			;5f03	ff		.
	rst 38h			;5f04	ff		.
	rst 38h			;5f05	ff		.
	rst 38h			;5f06	ff		.
	rst 38h			;5f07	ff		.
	rst 38h			;5f08	ff		.
	rst 38h			;5f09	ff		.
	rst 38h			;5f0a	ff		.
	rst 38h			;5f0b	ff		.
	rst 38h			;5f0c	ff		.
	rst 38h			;5f0d	ff		.
	rst 38h			;5f0e	ff		.
	rst 38h			;5f0f	ff		.
	rst 38h			;5f10	ff		.
	rst 38h			;5f11	ff		.
	rst 38h			;5f12	ff		.
	rst 38h			;5f13	ff		.
	rst 38h			;5f14	ff		.
	rst 38h			;5f15	ff		.
	rst 38h			;5f16	ff		.
	rst 38h			;5f17	ff		.
	rst 38h			;5f18	ff		.
	rst 38h			;5f19	ff		.
	rst 38h			;5f1a	ff		.
	rst 38h			;5f1b	ff		.
	rst 38h			;5f1c	ff		.
	rst 38h			;5f1d	ff		.
	rst 38h			;5f1e	ff		.
	rst 38h			;5f1f	ff		.
	rst 38h			;5f20	ff		.
	rst 38h			;5f21	ff		.
	rst 38h			;5f22	ff		.
	rst 38h			;5f23	ff		.
	rst 38h			;5f24	ff		.
	rst 38h			;5f25	ff		.
	rst 38h			;5f26	ff		.
	rst 38h			;5f27	ff		.
	rst 38h			;5f28	ff		.
	rst 38h			;5f29	ff		.
	rst 38h			;5f2a	ff		.
	rst 38h			;5f2b	ff		.
	rst 38h			;5f2c	ff		.
	rst 38h			;5f2d	ff		.
	rst 38h			;5f2e	ff		.
	rst 38h			;5f2f	ff		.
	rst 38h			;5f30	ff		.
	rst 38h			;5f31	ff		.
	rst 38h			;5f32	ff		.
	rst 38h			;5f33	ff		.
	rst 38h			;5f34	ff		.
	rst 38h			;5f35	ff		.
	rst 38h			;5f36	ff		.
	rst 38h			;5f37	ff		.
	rst 38h			;5f38	ff		.
	rst 38h			;5f39	ff		.
	rst 38h			;5f3a	ff		.
	rst 38h			;5f3b	ff		.
	rst 38h			;5f3c	ff		.
	rst 38h			;5f3d	ff		.
	rst 38h			;5f3e	ff		.
	rst 38h			;5f3f	ff		.
	rst 38h			;5f40	ff		.
	rst 38h			;5f41	ff		.
	rst 38h			;5f42	ff		.
	rst 38h			;5f43	ff		.
	rst 38h			;5f44	ff		.
	rst 38h			;5f45	ff		.
	rst 38h			;5f46	ff		.
	rst 38h			;5f47	ff		.
	rst 38h			;5f48	ff		.
	rst 38h			;5f49	ff		.
	rst 38h			;5f4a	ff		.
	rst 38h			;5f4b	ff		.
	rst 38h			;5f4c	ff		.
	rst 38h			;5f4d	ff		.
	rst 38h			;5f4e	ff		.
	rst 38h			;5f4f	ff		.
	rst 38h			;5f50	ff		.
	rst 38h			;5f51	ff		.
	rst 38h			;5f52	ff		.
	rst 38h			;5f53	ff		.
	rst 38h			;5f54	ff		.
	rst 38h			;5f55	ff		.
	rst 38h			;5f56	ff		.
	rst 38h			;5f57	ff		.
	rst 38h			;5f58	ff		.
	rst 38h			;5f59	ff		.
	rst 38h			;5f5a	ff		.
	rst 38h			;5f5b	ff		.
	rst 38h			;5f5c	ff		.
	rst 38h			;5f5d	ff		.
	rst 38h			;5f5e	ff		.
	rst 38h			;5f5f	ff		.
	rst 38h			;5f60	ff		.
	rst 38h			;5f61	ff		.
	rst 38h			;5f62	ff		.
	rst 38h			;5f63	ff		.
	rst 38h			;5f64	ff		.
	rst 38h			;5f65	ff		.
	rst 38h			;5f66	ff		.
	rst 38h			;5f67	ff		.
	rst 38h			;5f68	ff		.
	rst 38h			;5f69	ff		.
	rst 38h			;5f6a	ff		.
	rst 38h			;5f6b	ff		.
	rst 38h			;5f6c	ff		.
	rst 38h			;5f6d	ff		.
	rst 38h			;5f6e	ff		.
	rst 38h			;5f6f	ff		.
	rst 38h			;5f70	ff		.
	rst 38h			;5f71	ff		.
	rst 38h			;5f72	ff		.
	rst 38h			;5f73	ff		.
	rst 38h			;5f74	ff		.
	rst 38h			;5f75	ff		.
	rst 38h			;5f76	ff		.
	rst 38h			;5f77	ff		.
	rst 38h			;5f78	ff		.
	rst 38h			;5f79	ff		.
	rst 38h			;5f7a	ff		.
	rst 38h			;5f7b	ff		.
	rst 38h			;5f7c	ff		.
	rst 38h			;5f7d	ff		.
	rst 38h			;5f7e	ff		.
	rst 38h			;5f7f	ff		.
	rst 38h			;5f80	ff		.
	rst 38h			;5f81	ff		.
	rst 38h			;5f82	ff		.
	rst 38h			;5f83	ff		.
	rst 38h			;5f84	ff		.
	rst 38h			;5f85	ff		.
	rst 38h			;5f86	ff		.
	rst 38h			;5f87	ff		.
	rst 38h			;5f88	ff		.
	rst 38h			;5f89	ff		.
	rst 38h			;5f8a	ff		.
	rst 38h			;5f8b	ff		.
	rst 38h			;5f8c	ff		.
	rst 38h			;5f8d	ff		.
	rst 38h			;5f8e	ff		.
	rst 38h			;5f8f	ff		.
	rst 38h			;5f90	ff		.
	rst 38h			;5f91	ff		.
	rst 38h			;5f92	ff		.
	rst 38h			;5f93	ff		.
	rst 38h			;5f94	ff		.
	rst 38h			;5f95	ff		.
	rst 38h			;5f96	ff		.
	rst 38h			;5f97	ff		.
	rst 38h			;5f98	ff		.
	rst 38h			;5f99	ff		.
	rst 38h			;5f9a	ff		.
	rst 38h			;5f9b	ff		.
	rst 38h			;5f9c	ff		.
	rst 38h			;5f9d	ff		.
	rst 38h			;5f9e	ff		.
	rst 38h			;5f9f	ff		.
	rst 38h			;5fa0	ff		.
	rst 38h			;5fa1	ff		.
	rst 38h			;5fa2	ff		.
	rst 38h			;5fa3	ff		.
	rst 38h			;5fa4	ff		.
	rst 38h			;5fa5	ff		.
	rst 38h			;5fa6	ff		.
	rst 38h			;5fa7	ff		.
	rst 38h			;5fa8	ff		.
	rst 38h			;5fa9	ff		.
	rst 38h			;5faa	ff		.
	rst 38h			;5fab	ff		.
	rst 38h			;5fac	ff		.
	rst 38h			;5fad	ff		.
	rst 38h			;5fae	ff		.
	rst 38h			;5faf	ff		.
	rst 38h			;5fb0	ff		.
	rst 38h			;5fb1	ff		.
	rst 38h			;5fb2	ff		.
	rst 38h			;5fb3	ff		.
	rst 38h			;5fb4	ff		.
	rst 38h			;5fb5	ff		.
	rst 38h			;5fb6	ff		.
	rst 38h			;5fb7	ff		.
	rst 38h			;5fb8	ff		.
	rst 38h			;5fb9	ff		.
	rst 38h			;5fba	ff		.
	rst 38h			;5fbb	ff		.
	rst 38h			;5fbc	ff		.
	rst 38h			;5fbd	ff		.
	rst 38h			;5fbe	ff		.
	rst 38h			;5fbf	ff		.
	rst 38h			;5fc0	ff		.
	rst 38h			;5fc1	ff		.
	rst 38h			;5fc2	ff		.
	rst 38h			;5fc3	ff		.
	rst 38h			;5fc4	ff		.
	rst 38h			;5fc5	ff		.
	rst 38h			;5fc6	ff		.
	rst 38h			;5fc7	ff		.
	rst 38h			;5fc8	ff		.
	rst 38h			;5fc9	ff		.
	rst 38h			;5fca	ff		.
	rst 38h			;5fcb	ff		.
	rst 38h			;5fcc	ff		.
	rst 38h			;5fcd	ff		.
	rst 38h			;5fce	ff		.
	rst 38h			;5fcf	ff		.
	rst 38h			;5fd0	ff		.
	rst 38h			;5fd1	ff		.
	rst 38h			;5fd2	ff		.
	rst 38h			;5fd3	ff		.
	rst 38h			;5fd4	ff		.
	rst 38h			;5fd5	ff		.
	rst 38h			;5fd6	ff		.
	rst 38h			;5fd7	ff		.
	rst 38h			;5fd8	ff		.
	rst 38h			;5fd9	ff		.
	rst 38h			;5fda	ff		.
	rst 38h			;5fdb	ff		.
	rst 38h			;5fdc	ff		.
	rst 38h			;5fdd	ff		.
	rst 38h			;5fde	ff		.
	rst 38h			;5fdf	ff		.
	rst 38h			;5fe0	ff		.
	rst 38h			;5fe1	ff		.
	rst 38h			;5fe2	ff		.
	rst 38h			;5fe3	ff		.
	rst 38h			;5fe4	ff		.
	rst 38h			;5fe5	ff		.
	rst 38h			;5fe6	ff		.
	rst 38h			;5fe7	ff		.
	rst 38h			;5fe8	ff		.
	rst 38h			;5fe9	ff		.
	rst 38h			;5fea	ff		.
	rst 38h			;5feb	ff		.
	rst 38h			;5fec	ff		.
	rst 38h			;5fed	ff		.
	rst 38h			;5fee	ff		.
	rst 38h			;5fef	ff		.
	rst 38h			;5ff0	ff		.
	rst 38h			;5ff1	ff		.
	rst 38h			;5ff2	ff		.
	rst 38h			;5ff3	ff		.
	rst 38h			;5ff4	ff		.
	rst 38h			;5ff5	ff		.
	rst 38h			;5ff6	ff		.
	rst 38h			;5ff7	ff		.
	rst 38h			;5ff8	ff		.
	rst 38h			;5ff9	ff		.
	rst 38h			;5ffa	ff		.
	rst 38h			;5ffb	ff		.
	rst 38h			;5ffc	ff		.
	rst 38h			;5ffd	ff		.
	rst 38h			;5ffe	ff		.
	rst 38h			;5fff	ff		.
	rst 38h			;6000	ff		.
	rst 38h			;6001	ff		.
	rst 38h			;6002	ff		.
	rst 38h			;6003	ff		.
	rst 38h			;6004	ff		.
	rst 38h			;6005	ff		.
	rst 38h			;6006	ff		.
	rst 38h			;6007	ff		.
	rst 38h			;6008	ff		.
	rst 38h			;6009	ff		.
	rst 38h			;600a	ff		.
	rst 38h			;600b	ff		.
	rst 38h			;600c	ff		.
	rst 38h			;600d	ff		.
	rst 38h			;600e	ff		.
	rst 38h			;600f	ff		.
	rst 38h			;6010	ff		.
	rst 38h			;6011	ff		.
	rst 38h			;6012	ff		.
	rst 38h			;6013	ff		.
	rst 38h			;6014	ff		.
	rst 38h			;6015	ff		.
	rst 38h			;6016	ff		.
	rst 38h			;6017	ff		.
	rst 38h			;6018	ff		.
	rst 38h			;6019	ff		.
	rst 38h			;601a	ff		.
	rst 38h			;601b	ff		.
	rst 38h			;601c	ff		.
	rst 38h			;601d	ff		.
	rst 38h			;601e	ff		.
	rst 38h			;601f	ff		.
l6020h:
	rst 38h			;6020	ff		.
	rst 38h			;6021	ff		.
l6022h:
	rst 38h			;6022	ff		.
	rst 38h			;6023	ff		.
	rst 38h			;6024	ff		.
	rst 38h			;6025	ff		.
	rst 38h			;6026	ff		.
	rst 38h			;6027	ff		.
	rst 38h			;6028	ff		.
	rst 38h			;6029	ff		.
	rst 38h			;602a	ff		.
	rst 38h			;602b	ff		.
	rst 38h			;602c	ff		.
	rst 38h			;602d	ff		.
	rst 38h			;602e	ff		.
	rst 38h			;602f	ff		.
	rst 38h			;6030	ff		.
	rst 38h			;6031	ff		.
	rst 38h			;6032	ff		.
	rst 38h			;6033	ff		.
	rst 38h			;6034	ff		.
	rst 38h			;6035	ff		.
	rst 38h			;6036	ff		.
	rst 38h			;6037	ff		.
	rst 38h			;6038	ff		.
	rst 38h			;6039	ff		.
	rst 38h			;603a	ff		.
	rst 38h			;603b	ff		.
	rst 38h			;603c	ff		.
	rst 38h			;603d	ff		.
	rst 38h			;603e	ff		.
	rst 38h			;603f	ff		.
	rst 38h			;6040	ff		.
	rst 38h			;6041	ff		.
	rst 38h			;6042	ff		.
	rst 38h			;6043	ff		.
	rst 38h			;6044	ff		.
	rst 38h			;6045	ff		.
	rst 38h			;6046	ff		.
	rst 38h			;6047	ff		.
	rst 38h			;6048	ff		.
	rst 38h			;6049	ff		.
	rst 38h			;604a	ff		.
	rst 38h			;604b	ff		.
	rst 38h			;604c	ff		.
	rst 38h			;604d	ff		.
	rst 38h			;604e	ff		.
	rst 38h			;604f	ff		.
	rst 38h			;6050	ff		.
	rst 38h			;6051	ff		.
	rst 38h			;6052	ff		.
	rst 38h			;6053	ff		.
	rst 38h			;6054	ff		.
	rst 38h			;6055	ff		.
	rst 38h			;6056	ff		.
	rst 38h			;6057	ff		.
	rst 38h			;6058	ff		.
	rst 38h			;6059	ff		.
	rst 38h			;605a	ff		.
	rst 38h			;605b	ff		.
	rst 38h			;605c	ff		.
	rst 38h			;605d	ff		.
	rst 38h			;605e	ff		.
	rst 38h			;605f	ff		.
	rst 38h			;6060	ff		.
	rst 38h			;6061	ff		.
	rst 38h			;6062	ff		.
	rst 38h			;6063	ff		.
	rst 38h			;6064	ff		.
	rst 38h			;6065	ff		.
	rst 38h			;6066	ff		.
	rst 38h			;6067	ff		.
	rst 38h			;6068	ff		.
	rst 38h			;6069	ff		.
	rst 38h			;606a	ff		.
	rst 38h			;606b	ff		.
	rst 38h			;606c	ff		.
	rst 38h			;606d	ff		.
	rst 38h			;606e	ff		.
	rst 38h			;606f	ff		.
	rst 38h			;6070	ff		.
	rst 38h			;6071	ff		.
	rst 38h			;6072	ff		.
	rst 38h			;6073	ff		.
	rst 38h			;6074	ff		.
	rst 38h			;6075	ff		.
	rst 38h			;6076	ff		.
	rst 38h			;6077	ff		.
	rst 38h			;6078	ff		.
	rst 38h			;6079	ff		.
	rst 38h			;607a	ff		.
	rst 38h			;607b	ff		.
	rst 38h			;607c	ff		.
	rst 38h			;607d	ff		.
	rst 38h			;607e	ff		.
	rst 38h			;607f	ff		.
	rst 38h			;6080	ff		.
	rst 38h			;6081	ff		.
	rst 38h			;6082	ff		.
	rst 38h			;6083	ff		.
	rst 38h			;6084	ff		.
	rst 38h			;6085	ff		.
	rst 38h			;6086	ff		.
	rst 38h			;6087	ff		.
	rst 38h			;6088	ff		.
	rst 38h			;6089	ff		.
	rst 38h			;608a	ff		.
	rst 38h			;608b	ff		.
	rst 38h			;608c	ff		.
	rst 38h			;608d	ff		.
	rst 38h			;608e	ff		.
	rst 38h			;608f	ff		.
	rst 38h			;6090	ff		.
	rst 38h			;6091	ff		.
	rst 38h			;6092	ff		.
	rst 38h			;6093	ff		.
	rst 38h			;6094	ff		.
	rst 38h			;6095	ff		.
	rst 38h			;6096	ff		.
	rst 38h			;6097	ff		.
	rst 38h			;6098	ff		.
	rst 38h			;6099	ff		.
	rst 38h			;609a	ff		.
	rst 38h			;609b	ff		.
	rst 38h			;609c	ff		.
	rst 38h			;609d	ff		.
	rst 38h			;609e	ff		.
	rst 38h			;609f	ff		.
	rst 38h			;60a0	ff		.
	rst 38h			;60a1	ff		.
	rst 38h			;60a2	ff		.
	rst 38h			;60a3	ff		.
	rst 38h			;60a4	ff		.
	rst 38h			;60a5	ff		.
	rst 38h			;60a6	ff		.
	rst 38h			;60a7	ff		.
	rst 38h			;60a8	ff		.
	rst 38h			;60a9	ff		.
	rst 38h			;60aa	ff		.
	rst 38h			;60ab	ff		.
	rst 38h			;60ac	ff		.
	rst 38h			;60ad	ff		.
	rst 38h			;60ae	ff		.
	rst 38h			;60af	ff		.
	rst 38h			;60b0	ff		.
	rst 38h			;60b1	ff		.
	rst 38h			;60b2	ff		.
	rst 38h			;60b3	ff		.
	rst 38h			;60b4	ff		.
	rst 38h			;60b5	ff		.
	rst 38h			;60b6	ff		.
	rst 38h			;60b7	ff		.
	rst 38h			;60b8	ff		.
	rst 38h			;60b9	ff		.
	rst 38h			;60ba	ff		.
	rst 38h			;60bb	ff		.
	rst 38h			;60bc	ff		.
	rst 38h			;60bd	ff		.
	rst 38h			;60be	ff		.
	rst 38h			;60bf	ff		.
	rst 38h			;60c0	ff		.
	rst 38h			;60c1	ff		.
	rst 38h			;60c2	ff		.
	rst 38h			;60c3	ff		.
	rst 38h			;60c4	ff		.
	rst 38h			;60c5	ff		.
	rst 38h			;60c6	ff		.
	rst 38h			;60c7	ff		.
	rst 38h			;60c8	ff		.
	rst 38h			;60c9	ff		.
	rst 38h			;60ca	ff		.
	rst 38h			;60cb	ff		.
	rst 38h			;60cc	ff		.
	rst 38h			;60cd	ff		.
	rst 38h			;60ce	ff		.
	rst 38h			;60cf	ff		.
	rst 38h			;60d0	ff		.
	rst 38h			;60d1	ff		.
	rst 38h			;60d2	ff		.
	rst 38h			;60d3	ff		.
	rst 38h			;60d4	ff		.
	rst 38h			;60d5	ff		.
	rst 38h			;60d6	ff		.
	rst 38h			;60d7	ff		.
	rst 38h			;60d8	ff		.
	rst 38h			;60d9	ff		.
	rst 38h			;60da	ff		.
	rst 38h			;60db	ff		.
	rst 38h			;60dc	ff		.
	rst 38h			;60dd	ff		.
	rst 38h			;60de	ff		.
	rst 38h			;60df	ff		.
	rst 38h			;60e0	ff		.
	rst 38h			;60e1	ff		.
	rst 38h			;60e2	ff		.
	rst 38h			;60e3	ff		.
	rst 38h			;60e4	ff		.
	rst 38h			;60e5	ff		.
	rst 38h			;60e6	ff		.
	rst 38h			;60e7	ff		.
	rst 38h			;60e8	ff		.
	rst 38h			;60e9	ff		.
	rst 38h			;60ea	ff		.
	rst 38h			;60eb	ff		.
	rst 38h			;60ec	ff		.
	rst 38h			;60ed	ff		.
	rst 38h			;60ee	ff		.
	rst 38h			;60ef	ff		.
	rst 38h			;60f0	ff		.
	rst 38h			;60f1	ff		.
	rst 38h			;60f2	ff		.
	rst 38h			;60f3	ff		.
	rst 38h			;60f4	ff		.
	rst 38h			;60f5	ff		.
	rst 38h			;60f6	ff		.
	rst 38h			;60f7	ff		.
	rst 38h			;60f8	ff		.
	rst 38h			;60f9	ff		.
	rst 38h			;60fa	ff		.
	rst 38h			;60fb	ff		.
	rst 38h			;60fc	ff		.
	rst 38h			;60fd	ff		.
	rst 38h			;60fe	ff		.
	rst 38h			;60ff	ff		.
	rst 38h			;6100	ff		.
	rst 38h			;6101	ff		.
	rst 38h			;6102	ff		.
	rst 38h			;6103	ff		.
	rst 38h			;6104	ff		.
	rst 38h			;6105	ff		.
	rst 38h			;6106	ff		.
	rst 38h			;6107	ff		.
	rst 38h			;6108	ff		.
	rst 38h			;6109	ff		.
	rst 38h			;610a	ff		.
	rst 38h			;610b	ff		.
	rst 38h			;610c	ff		.
	rst 38h			;610d	ff		.
	rst 38h			;610e	ff		.
	rst 38h			;610f	ff		.
	rst 38h			;6110	ff		.
	rst 38h			;6111	ff		.
	rst 38h			;6112	ff		.
	rst 38h			;6113	ff		.
	rst 38h			;6114	ff		.
	rst 38h			;6115	ff		.
	rst 38h			;6116	ff		.
	rst 38h			;6117	ff		.
	rst 38h			;6118	ff		.
	rst 38h			;6119	ff		.
	rst 38h			;611a	ff		.
	rst 38h			;611b	ff		.
	rst 38h			;611c	ff		.
	rst 38h			;611d	ff		.
	rst 38h			;611e	ff		.
	rst 38h			;611f	ff		.
	rst 38h			;6120	ff		.
	rst 38h			;6121	ff		.
	rst 38h			;6122	ff		.
	rst 38h			;6123	ff		.
	rst 38h			;6124	ff		.
	rst 38h			;6125	ff		.
	rst 38h			;6126	ff		.
	rst 38h			;6127	ff		.
	rst 38h			;6128	ff		.
	rst 38h			;6129	ff		.
	rst 38h			;612a	ff		.
	rst 38h			;612b	ff		.
	rst 38h			;612c	ff		.
	rst 38h			;612d	ff		.
	rst 38h			;612e	ff		.
	rst 38h			;612f	ff		.
	rst 38h			;6130	ff		.
	rst 38h			;6131	ff		.
	rst 38h			;6132	ff		.
	rst 38h			;6133	ff		.
	rst 38h			;6134	ff		.
	rst 38h			;6135	ff		.
	rst 38h			;6136	ff		.
	rst 38h			;6137	ff		.
	rst 38h			;6138	ff		.
	rst 38h			;6139	ff		.
	rst 38h			;613a	ff		.
	rst 38h			;613b	ff		.
	rst 38h			;613c	ff		.
	rst 38h			;613d	ff		.
	rst 38h			;613e	ff		.
	rst 38h			;613f	ff		.
	rst 38h			;6140	ff		.
	rst 38h			;6141	ff		.
	rst 38h			;6142	ff		.
	rst 38h			;6143	ff		.
	rst 38h			;6144	ff		.
	rst 38h			;6145	ff		.
	rst 38h			;6146	ff		.
	rst 38h			;6147	ff		.
	rst 38h			;6148	ff		.
	rst 38h			;6149	ff		.
	rst 38h			;614a	ff		.
	rst 38h			;614b	ff		.
	rst 38h			;614c	ff		.
	rst 38h			;614d	ff		.
	rst 38h			;614e	ff		.
	rst 38h			;614f	ff		.
	rst 38h			;6150	ff		.
	rst 38h			;6151	ff		.
	rst 38h			;6152	ff		.
	rst 38h			;6153	ff		.
	rst 38h			;6154	ff		.
	rst 38h			;6155	ff		.
	rst 38h			;6156	ff		.
	rst 38h			;6157	ff		.
	rst 38h			;6158	ff		.
	rst 38h			;6159	ff		.
	rst 38h			;615a	ff		.
	rst 38h			;615b	ff		.
	rst 38h			;615c	ff		.
	rst 38h			;615d	ff		.
	rst 38h			;615e	ff		.
	rst 38h			;615f	ff		.
	rst 38h			;6160	ff		.
	rst 38h			;6161	ff		.
	rst 38h			;6162	ff		.
	rst 38h			;6163	ff		.
	rst 38h			;6164	ff		.
	rst 38h			;6165	ff		.
	rst 38h			;6166	ff		.
	rst 38h			;6167	ff		.
	rst 38h			;6168	ff		.
	rst 38h			;6169	ff		.
	rst 38h			;616a	ff		.
	rst 38h			;616b	ff		.
	rst 38h			;616c	ff		.
	rst 38h			;616d	ff		.
	rst 38h			;616e	ff		.
	rst 38h			;616f	ff		.
	rst 38h			;6170	ff		.
	rst 38h			;6171	ff		.
	rst 38h			;6172	ff		.
	rst 38h			;6173	ff		.
	rst 38h			;6174	ff		.
	rst 38h			;6175	ff		.
	rst 38h			;6176	ff		.
	rst 38h			;6177	ff		.
	rst 38h			;6178	ff		.
	rst 38h			;6179	ff		.
	rst 38h			;617a	ff		.
	rst 38h			;617b	ff		.
	rst 38h			;617c	ff		.
	rst 38h			;617d	ff		.
	rst 38h			;617e	ff		.
	rst 38h			;617f	ff		.
	rst 38h			;6180	ff		.
	rst 38h			;6181	ff		.
	rst 38h			;6182	ff		.
	rst 38h			;6183	ff		.
	rst 38h			;6184	ff		.
	rst 38h			;6185	ff		.
	rst 38h			;6186	ff		.
	rst 38h			;6187	ff		.
	rst 38h			;6188	ff		.
	rst 38h			;6189	ff		.
	rst 38h			;618a	ff		.
	rst 38h			;618b	ff		.
	rst 38h			;618c	ff		.
	rst 38h			;618d	ff		.
	rst 38h			;618e	ff		.
	rst 38h			;618f	ff		.
	rst 38h			;6190	ff		.
	rst 38h			;6191	ff		.
	rst 38h			;6192	ff		.
	rst 38h			;6193	ff		.
	rst 38h			;6194	ff		.
	rst 38h			;6195	ff		.
	rst 38h			;6196	ff		.
	rst 38h			;6197	ff		.
	rst 38h			;6198	ff		.
	rst 38h			;6199	ff		.
	rst 38h			;619a	ff		.
	rst 38h			;619b	ff		.
	rst 38h			;619c	ff		.
	rst 38h			;619d	ff		.
	rst 38h			;619e	ff		.
	rst 38h			;619f	ff		.
	rst 38h			;61a0	ff		.
	rst 38h			;61a1	ff		.
	rst 38h			;61a2	ff		.
	rst 38h			;61a3	ff		.
	rst 38h			;61a4	ff		.
	rst 38h			;61a5	ff		.
	rst 38h			;61a6	ff		.
	rst 38h			;61a7	ff		.
	rst 38h			;61a8	ff		.
	rst 38h			;61a9	ff		.
	rst 38h			;61aa	ff		.
	rst 38h			;61ab	ff		.
	rst 38h			;61ac	ff		.
	rst 38h			;61ad	ff		.
	rst 38h			;61ae	ff		.
	rst 38h			;61af	ff		.
	rst 38h			;61b0	ff		.
	rst 38h			;61b1	ff		.
	rst 38h			;61b2	ff		.
	rst 38h			;61b3	ff		.
	rst 38h			;61b4	ff		.
	rst 38h			;61b5	ff		.
	rst 38h			;61b6	ff		.
	rst 38h			;61b7	ff		.
	rst 38h			;61b8	ff		.
	rst 38h			;61b9	ff		.
	rst 38h			;61ba	ff		.
	rst 38h			;61bb	ff		.
	rst 38h			;61bc	ff		.
	rst 38h			;61bd	ff		.
	rst 38h			;61be	ff		.
	rst 38h			;61bf	ff		.
	rst 38h			;61c0	ff		.
	rst 38h			;61c1	ff		.
	rst 38h			;61c2	ff		.
	rst 38h			;61c3	ff		.
	rst 38h			;61c4	ff		.
	rst 38h			;61c5	ff		.
	rst 38h			;61c6	ff		.
	rst 38h			;61c7	ff		.
	rst 38h			;61c8	ff		.
	rst 38h			;61c9	ff		.
	rst 38h			;61ca	ff		.
	rst 38h			;61cb	ff		.
	rst 38h			;61cc	ff		.
	rst 38h			;61cd	ff		.
	rst 38h			;61ce	ff		.
	rst 38h			;61cf	ff		.
	rst 38h			;61d0	ff		.
	rst 38h			;61d1	ff		.
	rst 38h			;61d2	ff		.
	rst 38h			;61d3	ff		.
	rst 38h			;61d4	ff		.
	rst 38h			;61d5	ff		.
	rst 38h			;61d6	ff		.
	rst 38h			;61d7	ff		.
	rst 38h			;61d8	ff		.
	rst 38h			;61d9	ff		.
	rst 38h			;61da	ff		.
	rst 38h			;61db	ff		.
	rst 38h			;61dc	ff		.
	rst 38h			;61dd	ff		.
	rst 38h			;61de	ff		.
	rst 38h			;61df	ff		.
	rst 38h			;61e0	ff		.
	rst 38h			;61e1	ff		.
	rst 38h			;61e2	ff		.
	rst 38h			;61e3	ff		.
	rst 38h			;61e4	ff		.
	rst 38h			;61e5	ff		.
	rst 38h			;61e6	ff		.
	rst 38h			;61e7	ff		.
	rst 38h			;61e8	ff		.
	rst 38h			;61e9	ff		.
	rst 38h			;61ea	ff		.
	rst 38h			;61eb	ff		.
	rst 38h			;61ec	ff		.
	rst 38h			;61ed	ff		.
	rst 38h			;61ee	ff		.
	rst 38h			;61ef	ff		.
	rst 38h			;61f0	ff		.
	rst 38h			;61f1	ff		.
	rst 38h			;61f2	ff		.
	rst 38h			;61f3	ff		.
	rst 38h			;61f4	ff		.
	rst 38h			;61f5	ff		.
	rst 38h			;61f6	ff		.
	rst 38h			;61f7	ff		.
	rst 38h			;61f8	ff		.
	rst 38h			;61f9	ff		.
	rst 38h			;61fa	ff		.
	rst 38h			;61fb	ff		.
	rst 38h			;61fc	ff		.
	rst 38h			;61fd	ff		.
	rst 38h			;61fe	ff		.
	rst 38h			;61ff	ff		.
	rst 38h			;6200	ff		.
	rst 38h			;6201	ff		.
	rst 38h			;6202	ff		.
	rst 38h			;6203	ff		.
	rst 38h			;6204	ff		.
	rst 38h			;6205	ff		.
	rst 38h			;6206	ff		.
	rst 38h			;6207	ff		.
	rst 38h			;6208	ff		.
	rst 38h			;6209	ff		.
	rst 38h			;620a	ff		.
	rst 38h			;620b	ff		.
	rst 38h			;620c	ff		.
	rst 38h			;620d	ff		.
	rst 38h			;620e	ff		.
	rst 38h			;620f	ff		.
	rst 38h			;6210	ff		.
	rst 38h			;6211	ff		.
	rst 38h			;6212	ff		.
	rst 38h			;6213	ff		.
	rst 38h			;6214	ff		.
	rst 38h			;6215	ff		.
	rst 38h			;6216	ff		.
	rst 38h			;6217	ff		.
	rst 38h			;6218	ff		.
	rst 38h			;6219	ff		.
	rst 38h			;621a	ff		.
	rst 38h			;621b	ff		.
	rst 38h			;621c	ff		.
	rst 38h			;621d	ff		.
	rst 38h			;621e	ff		.
	rst 38h			;621f	ff		.
	rst 38h			;6220	ff		.
	rst 38h			;6221	ff		.
	rst 38h			;6222	ff		.
	rst 38h			;6223	ff		.
	rst 38h			;6224	ff		.
	rst 38h			;6225	ff		.
	rst 38h			;6226	ff		.
	rst 38h			;6227	ff		.
	rst 38h			;6228	ff		.
	rst 38h			;6229	ff		.
	rst 38h			;622a	ff		.
	rst 38h			;622b	ff		.
	rst 38h			;622c	ff		.
	rst 38h			;622d	ff		.
	rst 38h			;622e	ff		.
	rst 38h			;622f	ff		.
	rst 38h			;6230	ff		.
	rst 38h			;6231	ff		.
	rst 38h			;6232	ff		.
	rst 38h			;6233	ff		.
	rst 38h			;6234	ff		.
	rst 38h			;6235	ff		.
	rst 38h			;6236	ff		.
	rst 38h			;6237	ff		.
	rst 38h			;6238	ff		.
	rst 38h			;6239	ff		.
	rst 38h			;623a	ff		.
	rst 38h			;623b	ff		.
	rst 38h			;623c	ff		.
	rst 38h			;623d	ff		.
	rst 38h			;623e	ff		.
	rst 38h			;623f	ff		.
	rst 38h			;6240	ff		.
	rst 38h			;6241	ff		.
	rst 38h			;6242	ff		.
	rst 38h			;6243	ff		.
	rst 38h			;6244	ff		.
	rst 38h			;6245	ff		.
	rst 38h			;6246	ff		.
	rst 38h			;6247	ff		.
	rst 38h			;6248	ff		.
	rst 38h			;6249	ff		.
	rst 38h			;624a	ff		.
	rst 38h			;624b	ff		.
	rst 38h			;624c	ff		.
	rst 38h			;624d	ff		.
	rst 38h			;624e	ff		.
	rst 38h			;624f	ff		.
	rst 38h			;6250	ff		.
	rst 38h			;6251	ff		.
	rst 38h			;6252	ff		.
	rst 38h			;6253	ff		.
	rst 38h			;6254	ff		.
	rst 38h			;6255	ff		.
	rst 38h			;6256	ff		.
	rst 38h			;6257	ff		.
	rst 38h			;6258	ff		.
	rst 38h			;6259	ff		.
	rst 38h			;625a	ff		.
	rst 38h			;625b	ff		.
	rst 38h			;625c	ff		.
	rst 38h			;625d	ff		.
	rst 38h			;625e	ff		.
	rst 38h			;625f	ff		.
	rst 38h			;6260	ff		.
	rst 38h			;6261	ff		.
	rst 38h			;6262	ff		.
	rst 38h			;6263	ff		.
	rst 38h			;6264	ff		.
	rst 38h			;6265	ff		.
	rst 38h			;6266	ff		.
	rst 38h			;6267	ff		.
	rst 38h			;6268	ff		.
	rst 38h			;6269	ff		.
	rst 38h			;626a	ff		.
	rst 38h			;626b	ff		.
	rst 38h			;626c	ff		.
	rst 38h			;626d	ff		.
	rst 38h			;626e	ff		.
	rst 38h			;626f	ff		.
	rst 38h			;6270	ff		.
	rst 38h			;6271	ff		.
	rst 38h			;6272	ff		.
	rst 38h			;6273	ff		.
	rst 38h			;6274	ff		.
	rst 38h			;6275	ff		.
	rst 38h			;6276	ff		.
	rst 38h			;6277	ff		.
	rst 38h			;6278	ff		.
	rst 38h			;6279	ff		.
	rst 38h			;627a	ff		.
	rst 38h			;627b	ff		.
	rst 38h			;627c	ff		.
	rst 38h			;627d	ff		.
	rst 38h			;627e	ff		.
	rst 38h			;627f	ff		.
	rst 38h			;6280	ff		.
	rst 38h			;6281	ff		.
	rst 38h			;6282	ff		.
	rst 38h			;6283	ff		.
	rst 38h			;6284	ff		.
	rst 38h			;6285	ff		.
	rst 38h			;6286	ff		.
	rst 38h			;6287	ff		.
	rst 38h			;6288	ff		.
	rst 38h			;6289	ff		.
	rst 38h			;628a	ff		.
	rst 38h			;628b	ff		.
	rst 38h			;628c	ff		.
	rst 38h			;628d	ff		.
	rst 38h			;628e	ff		.
	rst 38h			;628f	ff		.
	rst 38h			;6290	ff		.
	rst 38h			;6291	ff		.
	rst 38h			;6292	ff		.
	rst 38h			;6293	ff		.
	rst 38h			;6294	ff		.
	rst 38h			;6295	ff		.
	rst 38h			;6296	ff		.
	rst 38h			;6297	ff		.
	rst 38h			;6298	ff		.
	rst 38h			;6299	ff		.
	rst 38h			;629a	ff		.
	rst 38h			;629b	ff		.
	rst 38h			;629c	ff		.
	rst 38h			;629d	ff		.
	rst 38h			;629e	ff		.
	rst 38h			;629f	ff		.
	rst 38h			;62a0	ff		.
	rst 38h			;62a1	ff		.
	rst 38h			;62a2	ff		.
	rst 38h			;62a3	ff		.
	rst 38h			;62a4	ff		.
	rst 38h			;62a5	ff		.
	rst 38h			;62a6	ff		.
	rst 38h			;62a7	ff		.
	rst 38h			;62a8	ff		.
	rst 38h			;62a9	ff		.
	rst 38h			;62aa	ff		.
	rst 38h			;62ab	ff		.
	rst 38h			;62ac	ff		.
	rst 38h			;62ad	ff		.
	rst 38h			;62ae	ff		.
	rst 38h			;62af	ff		.
	rst 38h			;62b0	ff		.
	rst 38h			;62b1	ff		.
	rst 38h			;62b2	ff		.
	rst 38h			;62b3	ff		.
	rst 38h			;62b4	ff		.
	rst 38h			;62b5	ff		.
	rst 38h			;62b6	ff		.
	rst 38h			;62b7	ff		.
	rst 38h			;62b8	ff		.
	rst 38h			;62b9	ff		.
	rst 38h			;62ba	ff		.
	rst 38h			;62bb	ff		.
	rst 38h			;62bc	ff		.
	rst 38h			;62bd	ff		.
	rst 38h			;62be	ff		.
	rst 38h			;62bf	ff		.
	rst 38h			;62c0	ff		.
	rst 38h			;62c1	ff		.
	rst 38h			;62c2	ff		.
	rst 38h			;62c3	ff		.
	rst 38h			;62c4	ff		.
	rst 38h			;62c5	ff		.
	rst 38h			;62c6	ff		.
	rst 38h			;62c7	ff		.
	rst 38h			;62c8	ff		.
	rst 38h			;62c9	ff		.
	rst 38h			;62ca	ff		.
	rst 38h			;62cb	ff		.
	rst 38h			;62cc	ff		.
	rst 38h			;62cd	ff		.
	rst 38h			;62ce	ff		.
	rst 38h			;62cf	ff		.
	rst 38h			;62d0	ff		.
	rst 38h			;62d1	ff		.
	rst 38h			;62d2	ff		.
	rst 38h			;62d3	ff		.
	rst 38h			;62d4	ff		.
	rst 38h			;62d5	ff		.
	rst 38h			;62d6	ff		.
	rst 38h			;62d7	ff		.
	rst 38h			;62d8	ff		.
	rst 38h			;62d9	ff		.
	rst 38h			;62da	ff		.
	rst 38h			;62db	ff		.
	rst 38h			;62dc	ff		.
	rst 38h			;62dd	ff		.
	rst 38h			;62de	ff		.
	rst 38h			;62df	ff		.
	rst 38h			;62e0	ff		.
	rst 38h			;62e1	ff		.
	rst 38h			;62e2	ff		.
	rst 38h			;62e3	ff		.
	rst 38h			;62e4	ff		.
	rst 38h			;62e5	ff		.
	rst 38h			;62e6	ff		.
	rst 38h			;62e7	ff		.
	rst 38h			;62e8	ff		.
	rst 38h			;62e9	ff		.
	rst 38h			;62ea	ff		.
	rst 38h			;62eb	ff		.
	rst 38h			;62ec	ff		.
	rst 38h			;62ed	ff		.
	rst 38h			;62ee	ff		.
	rst 38h			;62ef	ff		.
	rst 38h			;62f0	ff		.
	rst 38h			;62f1	ff		.
	rst 38h			;62f2	ff		.
	rst 38h			;62f3	ff		.
	rst 38h			;62f4	ff		.
	rst 38h			;62f5	ff		.
	rst 38h			;62f6	ff		.
	rst 38h			;62f7	ff		.
	rst 38h			;62f8	ff		.
	rst 38h			;62f9	ff		.
	rst 38h			;62fa	ff		.
	rst 38h			;62fb	ff		.
	rst 38h			;62fc	ff		.
	rst 38h			;62fd	ff		.
	rst 38h			;62fe	ff		.
	rst 38h			;62ff	ff		.
	rst 38h			;6300	ff		.
	rst 38h			;6301	ff		.
	rst 38h			;6302	ff		.
	rst 38h			;6303	ff		.
	rst 38h			;6304	ff		.
	rst 38h			;6305	ff		.
	rst 38h			;6306	ff		.
	rst 38h			;6307	ff		.
	rst 38h			;6308	ff		.
	rst 38h			;6309	ff		.
	rst 38h			;630a	ff		.
	rst 38h			;630b	ff		.
	rst 38h			;630c	ff		.
	rst 38h			;630d	ff		.
	rst 38h			;630e	ff		.
	rst 38h			;630f	ff		.
	rst 38h			;6310	ff		.
	rst 38h			;6311	ff		.
	rst 38h			;6312	ff		.
	rst 38h			;6313	ff		.
	rst 38h			;6314	ff		.
	rst 38h			;6315	ff		.
	rst 38h			;6316	ff		.
	rst 38h			;6317	ff		.
	rst 38h			;6318	ff		.
	rst 38h			;6319	ff		.
	rst 38h			;631a	ff		.
	rst 38h			;631b	ff		.
	rst 38h			;631c	ff		.
	rst 38h			;631d	ff		.
	rst 38h			;631e	ff		.
	rst 38h			;631f	ff		.
	rst 38h			;6320	ff		.
	rst 38h			;6321	ff		.
	rst 38h			;6322	ff		.
	rst 38h			;6323	ff		.
	rst 38h			;6324	ff		.
	rst 38h			;6325	ff		.
	rst 38h			;6326	ff		.
	rst 38h			;6327	ff		.
	rst 38h			;6328	ff		.
	rst 38h			;6329	ff		.
	rst 38h			;632a	ff		.
	rst 38h			;632b	ff		.
	rst 38h			;632c	ff		.
	rst 38h			;632d	ff		.
	rst 38h			;632e	ff		.
	rst 38h			;632f	ff		.
	rst 38h			;6330	ff		.
	rst 38h			;6331	ff		.
	rst 38h			;6332	ff		.
	rst 38h			;6333	ff		.
	rst 38h			;6334	ff		.
	rst 38h			;6335	ff		.
	rst 38h			;6336	ff		.
	rst 38h			;6337	ff		.
	rst 38h			;6338	ff		.
	rst 38h			;6339	ff		.
	rst 38h			;633a	ff		.
	rst 38h			;633b	ff		.
	rst 38h			;633c	ff		.
	rst 38h			;633d	ff		.
	rst 38h			;633e	ff		.
	rst 38h			;633f	ff		.
	rst 38h			;6340	ff		.
	rst 38h			;6341	ff		.
	rst 38h			;6342	ff		.
	rst 38h			;6343	ff		.
	rst 38h			;6344	ff		.
	rst 38h			;6345	ff		.
	rst 38h			;6346	ff		.
	rst 38h			;6347	ff		.
	rst 38h			;6348	ff		.
	rst 38h			;6349	ff		.
	rst 38h			;634a	ff		.
	rst 38h			;634b	ff		.
	rst 38h			;634c	ff		.
	rst 38h			;634d	ff		.
	rst 38h			;634e	ff		.
	rst 38h			;634f	ff		.
	rst 38h			;6350	ff		.
	rst 38h			;6351	ff		.
	rst 38h			;6352	ff		.
	rst 38h			;6353	ff		.
	rst 38h			;6354	ff		.
	rst 38h			;6355	ff		.
	rst 38h			;6356	ff		.
	rst 38h			;6357	ff		.
	rst 38h			;6358	ff		.
	rst 38h			;6359	ff		.
	rst 38h			;635a	ff		.
	rst 38h			;635b	ff		.
	rst 38h			;635c	ff		.
	rst 38h			;635d	ff		.
	rst 38h			;635e	ff		.
	rst 38h			;635f	ff		.
	rst 38h			;6360	ff		.
	rst 38h			;6361	ff		.
	rst 38h			;6362	ff		.
	rst 38h			;6363	ff		.
	rst 38h			;6364	ff		.
	rst 38h			;6365	ff		.
	rst 38h			;6366	ff		.
	rst 38h			;6367	ff		.
	rst 38h			;6368	ff		.
	rst 38h			;6369	ff		.
	rst 38h			;636a	ff		.
	rst 38h			;636b	ff		.
	rst 38h			;636c	ff		.
	rst 38h			;636d	ff		.
	rst 38h			;636e	ff		.
	rst 38h			;636f	ff		.
	rst 38h			;6370	ff		.
	rst 38h			;6371	ff		.
	rst 38h			;6372	ff		.
	rst 38h			;6373	ff		.
	rst 38h			;6374	ff		.
	rst 38h			;6375	ff		.
	rst 38h			;6376	ff		.
	rst 38h			;6377	ff		.
	rst 38h			;6378	ff		.
	rst 38h			;6379	ff		.
	rst 38h			;637a	ff		.
	rst 38h			;637b	ff		.
	rst 38h			;637c	ff		.
	rst 38h			;637d	ff		.
	rst 38h			;637e	ff		.
	rst 38h			;637f	ff		.
	rst 38h			;6380	ff		.
	rst 38h			;6381	ff		.
	rst 38h			;6382	ff		.
	rst 38h			;6383	ff		.
	rst 38h			;6384	ff		.
	rst 38h			;6385	ff		.
	rst 38h			;6386	ff		.
	rst 38h			;6387	ff		.
	rst 38h			;6388	ff		.
	rst 38h			;6389	ff		.
	rst 38h			;638a	ff		.
	rst 38h			;638b	ff		.
	rst 38h			;638c	ff		.
	rst 38h			;638d	ff		.
	rst 38h			;638e	ff		.
	rst 38h			;638f	ff		.
	rst 38h			;6390	ff		.
	rst 38h			;6391	ff		.
	rst 38h			;6392	ff		.
	rst 38h			;6393	ff		.
	rst 38h			;6394	ff		.
	rst 38h			;6395	ff		.
	rst 38h			;6396	ff		.
	rst 38h			;6397	ff		.
	rst 38h			;6398	ff		.
	rst 38h			;6399	ff		.
	rst 38h			;639a	ff		.
	rst 38h			;639b	ff		.
	rst 38h			;639c	ff		.
	rst 38h			;639d	ff		.
	rst 38h			;639e	ff		.
	rst 38h			;639f	ff		.
	rst 38h			;63a0	ff		.
	rst 38h			;63a1	ff		.
	rst 38h			;63a2	ff		.
	rst 38h			;63a3	ff		.
	rst 38h			;63a4	ff		.
	rst 38h			;63a5	ff		.
	rst 38h			;63a6	ff		.
	rst 38h			;63a7	ff		.
	rst 38h			;63a8	ff		.
	rst 38h			;63a9	ff		.
	rst 38h			;63aa	ff		.
	rst 38h			;63ab	ff		.
	rst 38h			;63ac	ff		.
	rst 38h			;63ad	ff		.
	rst 38h			;63ae	ff		.
	rst 38h			;63af	ff		.
	rst 38h			;63b0	ff		.
	rst 38h			;63b1	ff		.
	rst 38h			;63b2	ff		.
	rst 38h			;63b3	ff		.
	rst 38h			;63b4	ff		.
	rst 38h			;63b5	ff		.
	rst 38h			;63b6	ff		.
	rst 38h			;63b7	ff		.
	rst 38h			;63b8	ff		.
	rst 38h			;63b9	ff		.
	rst 38h			;63ba	ff		.
	rst 38h			;63bb	ff		.
	rst 38h			;63bc	ff		.
	rst 38h			;63bd	ff		.
	rst 38h			;63be	ff		.
	rst 38h			;63bf	ff		.
	rst 38h			;63c0	ff		.
	rst 38h			;63c1	ff		.
	rst 38h			;63c2	ff		.
	rst 38h			;63c3	ff		.
	rst 38h			;63c4	ff		.
	rst 38h			;63c5	ff		.
	rst 38h			;63c6	ff		.
	rst 38h			;63c7	ff		.
	rst 38h			;63c8	ff		.
	rst 38h			;63c9	ff		.
	rst 38h			;63ca	ff		.
	rst 38h			;63cb	ff		.
	rst 38h			;63cc	ff		.
	rst 38h			;63cd	ff		.
	rst 38h			;63ce	ff		.
	rst 38h			;63cf	ff		.
	rst 38h			;63d0	ff		.
	rst 38h			;63d1	ff		.
	rst 38h			;63d2	ff		.
	rst 38h			;63d3	ff		.
	rst 38h			;63d4	ff		.
	rst 38h			;63d5	ff		.
	rst 38h			;63d6	ff		.
	rst 38h			;63d7	ff		.
	rst 38h			;63d8	ff		.
	rst 38h			;63d9	ff		.
	rst 38h			;63da	ff		.
	rst 38h			;63db	ff		.
	rst 38h			;63dc	ff		.
	rst 38h			;63dd	ff		.
	rst 38h			;63de	ff		.
	rst 38h			;63df	ff		.
	rst 38h			;63e0	ff		.
	rst 38h			;63e1	ff		.
	rst 38h			;63e2	ff		.
	rst 38h			;63e3	ff		.
	rst 38h			;63e4	ff		.
	rst 38h			;63e5	ff		.
	rst 38h			;63e6	ff		.
	rst 38h			;63e7	ff		.
	rst 38h			;63e8	ff		.
	rst 38h			;63e9	ff		.
	rst 38h			;63ea	ff		.
	rst 38h			;63eb	ff		.
	rst 38h			;63ec	ff		.
	rst 38h			;63ed	ff		.
	rst 38h			;63ee	ff		.
	rst 38h			;63ef	ff		.
	rst 38h			;63f0	ff		.
	rst 38h			;63f1	ff		.
	rst 38h			;63f2	ff		.
	rst 38h			;63f3	ff		.
	rst 38h			;63f4	ff		.
	rst 38h			;63f5	ff		.
	rst 38h			;63f6	ff		.
	rst 38h			;63f7	ff		.
	rst 38h			;63f8	ff		.
	rst 38h			;63f9	ff		.
	rst 38h			;63fa	ff		.
	rst 38h			;63fb	ff		.
	rst 38h			;63fc	ff		.
	rst 38h			;63fd	ff		.
	rst 38h			;63fe	ff		.
	rst 38h			;63ff	ff		.
	rst 38h			;6400	ff		.
	rst 38h			;6401	ff		.
	rst 38h			;6402	ff		.
	rst 38h			;6403	ff		.
	rst 38h			;6404	ff		.
	rst 38h			;6405	ff		.
	rst 38h			;6406	ff		.
	rst 38h			;6407	ff		.
	rst 38h			;6408	ff		.
	rst 38h			;6409	ff		.
	rst 38h			;640a	ff		.
	rst 38h			;640b	ff		.
	rst 38h			;640c	ff		.
	rst 38h			;640d	ff		.
	rst 38h			;640e	ff		.
	rst 38h			;640f	ff		.
	rst 38h			;6410	ff		.
	rst 38h			;6411	ff		.
	rst 38h			;6412	ff		.
	rst 38h			;6413	ff		.
	rst 38h			;6414	ff		.
	rst 38h			;6415	ff		.
	rst 38h			;6416	ff		.
	rst 38h			;6417	ff		.
	rst 38h			;6418	ff		.
	rst 38h			;6419	ff		.
	rst 38h			;641a	ff		.
	rst 38h			;641b	ff		.
	rst 38h			;641c	ff		.
	rst 38h			;641d	ff		.
	rst 38h			;641e	ff		.
	rst 38h			;641f	ff		.
	rst 38h			;6420	ff		.
	rst 38h			;6421	ff		.
	rst 38h			;6422	ff		.
	rst 38h			;6423	ff		.
	rst 38h			;6424	ff		.
	rst 38h			;6425	ff		.
	rst 38h			;6426	ff		.
	rst 38h			;6427	ff		.
	rst 38h			;6428	ff		.
	rst 38h			;6429	ff		.
	rst 38h			;642a	ff		.
	rst 38h			;642b	ff		.
	rst 38h			;642c	ff		.
	rst 38h			;642d	ff		.
	rst 38h			;642e	ff		.
	rst 38h			;642f	ff		.
	rst 38h			;6430	ff		.
	rst 38h			;6431	ff		.
	rst 38h			;6432	ff		.
	rst 38h			;6433	ff		.
	rst 38h			;6434	ff		.
l6435h:
	rst 38h			;6435	ff		.
	rst 38h			;6436	ff		.
	rst 38h			;6437	ff		.
	rst 38h			;6438	ff		.
	rst 38h			;6439	ff		.
	rst 38h			;643a	ff		.
	rst 38h			;643b	ff		.
	rst 38h			;643c	ff		.
	rst 38h			;643d	ff		.
	rst 38h			;643e	ff		.
	rst 38h			;643f	ff		.
	rst 38h			;6440	ff		.
	rst 38h			;6441	ff		.
	rst 38h			;6442	ff		.
	rst 38h			;6443	ff		.
	rst 38h			;6444	ff		.
	rst 38h			;6445	ff		.
	rst 38h			;6446	ff		.
	rst 38h			;6447	ff		.
	rst 38h			;6448	ff		.
	rst 38h			;6449	ff		.
	rst 38h			;644a	ff		.
	rst 38h			;644b	ff		.
	rst 38h			;644c	ff		.
	rst 38h			;644d	ff		.
	rst 38h			;644e	ff		.
	rst 38h			;644f	ff		.
	rst 38h			;6450	ff		.
	rst 38h			;6451	ff		.
	rst 38h			;6452	ff		.
	rst 38h			;6453	ff		.
	rst 38h			;6454	ff		.
	rst 38h			;6455	ff		.
	rst 38h			;6456	ff		.
	rst 38h			;6457	ff		.
	rst 38h			;6458	ff		.
	rst 38h			;6459	ff		.
	rst 38h			;645a	ff		.
	rst 38h			;645b	ff		.
	rst 38h			;645c	ff		.
	rst 38h			;645d	ff		.
	rst 38h			;645e	ff		.
	rst 38h			;645f	ff		.
	rst 38h			;6460	ff		.
	rst 38h			;6461	ff		.
	rst 38h			;6462	ff		.
	rst 38h			;6463	ff		.
	rst 38h			;6464	ff		.
	rst 38h			;6465	ff		.
	rst 38h			;6466	ff		.
	rst 38h			;6467	ff		.
	rst 38h			;6468	ff		.
	rst 38h			;6469	ff		.
	rst 38h			;646a	ff		.
	rst 38h			;646b	ff		.
	rst 38h			;646c	ff		.
	rst 38h			;646d	ff		.
	rst 38h			;646e	ff		.
	rst 38h			;646f	ff		.
	rst 38h			;6470	ff		.
	rst 38h			;6471	ff		.
	rst 38h			;6472	ff		.
	rst 38h			;6473	ff		.
	rst 38h			;6474	ff		.
	rst 38h			;6475	ff		.
	rst 38h			;6476	ff		.
	rst 38h			;6477	ff		.
	rst 38h			;6478	ff		.
	rst 38h			;6479	ff		.
	rst 38h			;647a	ff		.
	rst 38h			;647b	ff		.
	rst 38h			;647c	ff		.
	rst 38h			;647d	ff		.
	rst 38h			;647e	ff		.
	rst 38h			;647f	ff		.
	rst 38h			;6480	ff		.
	rst 38h			;6481	ff		.
	rst 38h			;6482	ff		.
	rst 38h			;6483	ff		.
	rst 38h			;6484	ff		.
	rst 38h			;6485	ff		.
	rst 38h			;6486	ff		.
	rst 38h			;6487	ff		.
	rst 38h			;6488	ff		.
	rst 38h			;6489	ff		.
	rst 38h			;648a	ff		.
	rst 38h			;648b	ff		.
	rst 38h			;648c	ff		.
	rst 38h			;648d	ff		.
	rst 38h			;648e	ff		.
	rst 38h			;648f	ff		.
	rst 38h			;6490	ff		.
	rst 38h			;6491	ff		.
	rst 38h			;6492	ff		.
	rst 38h			;6493	ff		.
	rst 38h			;6494	ff		.
	rst 38h			;6495	ff		.
	rst 38h			;6496	ff		.
	rst 38h			;6497	ff		.
	rst 38h			;6498	ff		.
	rst 38h			;6499	ff		.
	rst 38h			;649a	ff		.
	rst 38h			;649b	ff		.
	rst 38h			;649c	ff		.
	rst 38h			;649d	ff		.
	rst 38h			;649e	ff		.
	rst 38h			;649f	ff		.
	rst 38h			;64a0	ff		.
	rst 38h			;64a1	ff		.
	rst 38h			;64a2	ff		.
	rst 38h			;64a3	ff		.
	rst 38h			;64a4	ff		.
	rst 38h			;64a5	ff		.
	rst 38h			;64a6	ff		.
	rst 38h			;64a7	ff		.
	rst 38h			;64a8	ff		.
	rst 38h			;64a9	ff		.
	rst 38h			;64aa	ff		.
	rst 38h			;64ab	ff		.
	rst 38h			;64ac	ff		.
	rst 38h			;64ad	ff		.
	rst 38h			;64ae	ff		.
	rst 38h			;64af	ff		.
	rst 38h			;64b0	ff		.
	rst 38h			;64b1	ff		.
	rst 38h			;64b2	ff		.
	rst 38h			;64b3	ff		.
	rst 38h			;64b4	ff		.
	rst 38h			;64b5	ff		.
	rst 38h			;64b6	ff		.
	rst 38h			;64b7	ff		.
	rst 38h			;64b8	ff		.
	rst 38h			;64b9	ff		.
	rst 38h			;64ba	ff		.
	rst 38h			;64bb	ff		.
	rst 38h			;64bc	ff		.
	rst 38h			;64bd	ff		.
	rst 38h			;64be	ff		.
	rst 38h			;64bf	ff		.
	rst 38h			;64c0	ff		.
	rst 38h			;64c1	ff		.
	rst 38h			;64c2	ff		.
	rst 38h			;64c3	ff		.
	rst 38h			;64c4	ff		.
	rst 38h			;64c5	ff		.
	rst 38h			;64c6	ff		.
	rst 38h			;64c7	ff		.
	rst 38h			;64c8	ff		.
	rst 38h			;64c9	ff		.
	rst 38h			;64ca	ff		.
	rst 38h			;64cb	ff		.
	rst 38h			;64cc	ff		.
	rst 38h			;64cd	ff		.
	rst 38h			;64ce	ff		.
	rst 38h			;64cf	ff		.
	rst 38h			;64d0	ff		.
	rst 38h			;64d1	ff		.
	rst 38h			;64d2	ff		.
	rst 38h			;64d3	ff		.
	rst 38h			;64d4	ff		.
	rst 38h			;64d5	ff		.
	rst 38h			;64d6	ff		.
	rst 38h			;64d7	ff		.
	rst 38h			;64d8	ff		.
	rst 38h			;64d9	ff		.
	rst 38h			;64da	ff		.
	rst 38h			;64db	ff		.
	rst 38h			;64dc	ff		.
	rst 38h			;64dd	ff		.
	rst 38h			;64de	ff		.
	rst 38h			;64df	ff		.
	rst 38h			;64e0	ff		.
	rst 38h			;64e1	ff		.
	rst 38h			;64e2	ff		.
	rst 38h			;64e3	ff		.
	rst 38h			;64e4	ff		.
	rst 38h			;64e5	ff		.
	rst 38h			;64e6	ff		.
	rst 38h			;64e7	ff		.
	rst 38h			;64e8	ff		.
	rst 38h			;64e9	ff		.
	rst 38h			;64ea	ff		.
	rst 38h			;64eb	ff		.
	rst 38h			;64ec	ff		.
	rst 38h			;64ed	ff		.
	rst 38h			;64ee	ff		.
	rst 38h			;64ef	ff		.
	rst 38h			;64f0	ff		.
	rst 38h			;64f1	ff		.
	rst 38h			;64f2	ff		.
	rst 38h			;64f3	ff		.
	rst 38h			;64f4	ff		.
	rst 38h			;64f5	ff		.
	rst 38h			;64f6	ff		.
	rst 38h			;64f7	ff		.
	rst 38h			;64f8	ff		.
	rst 38h			;64f9	ff		.
	rst 38h			;64fa	ff		.
	rst 38h			;64fb	ff		.
	rst 38h			;64fc	ff		.
	rst 38h			;64fd	ff		.
	rst 38h			;64fe	ff		.
	rst 38h			;64ff	ff		.
	rst 38h			;6500	ff		.
	rst 38h			;6501	ff		.
	rst 38h			;6502	ff		.
	rst 38h			;6503	ff		.
	rst 38h			;6504	ff		.
	rst 38h			;6505	ff		.
	rst 38h			;6506	ff		.
	rst 38h			;6507	ff		.
	rst 38h			;6508	ff		.
	rst 38h			;6509	ff		.
	rst 38h			;650a	ff		.
	rst 38h			;650b	ff		.
	rst 38h			;650c	ff		.
	rst 38h			;650d	ff		.
	rst 38h			;650e	ff		.
	rst 38h			;650f	ff		.
	rst 38h			;6510	ff		.
	rst 38h			;6511	ff		.
	rst 38h			;6512	ff		.
	rst 38h			;6513	ff		.
	rst 38h			;6514	ff		.
	rst 38h			;6515	ff		.
	rst 38h			;6516	ff		.
	rst 38h			;6517	ff		.
	rst 38h			;6518	ff		.
	rst 38h			;6519	ff		.
	rst 38h			;651a	ff		.
	rst 38h			;651b	ff		.
	rst 38h			;651c	ff		.
	rst 38h			;651d	ff		.
	rst 38h			;651e	ff		.
	rst 38h			;651f	ff		.
	rst 38h			;6520	ff		.
	rst 38h			;6521	ff		.
	rst 38h			;6522	ff		.
	rst 38h			;6523	ff		.
	rst 38h			;6524	ff		.
	rst 38h			;6525	ff		.
	rst 38h			;6526	ff		.
	rst 38h			;6527	ff		.
	rst 38h			;6528	ff		.
	rst 38h			;6529	ff		.
	rst 38h			;652a	ff		.
	rst 38h			;652b	ff		.
	rst 38h			;652c	ff		.
	rst 38h			;652d	ff		.
	rst 38h			;652e	ff		.
	rst 38h			;652f	ff		.
	rst 38h			;6530	ff		.
	rst 38h			;6531	ff		.
	rst 38h			;6532	ff		.
	rst 38h			;6533	ff		.
	rst 38h			;6534	ff		.
	rst 38h			;6535	ff		.
	rst 38h			;6536	ff		.
	rst 38h			;6537	ff		.
	rst 38h			;6538	ff		.
	rst 38h			;6539	ff		.
	rst 38h			;653a	ff		.
	rst 38h			;653b	ff		.
	rst 38h			;653c	ff		.
	rst 38h			;653d	ff		.
	rst 38h			;653e	ff		.
	rst 38h			;653f	ff		.
	rst 38h			;6540	ff		.
	rst 38h			;6541	ff		.
	rst 38h			;6542	ff		.
	rst 38h			;6543	ff		.
	rst 38h			;6544	ff		.
	rst 38h			;6545	ff		.
	rst 38h			;6546	ff		.
	rst 38h			;6547	ff		.
	rst 38h			;6548	ff		.
	rst 38h			;6549	ff		.
	rst 38h			;654a	ff		.
	rst 38h			;654b	ff		.
	rst 38h			;654c	ff		.
	rst 38h			;654d	ff		.
	rst 38h			;654e	ff		.
	rst 38h			;654f	ff		.
	rst 38h			;6550	ff		.
	rst 38h			;6551	ff		.
	rst 38h			;6552	ff		.
	rst 38h			;6553	ff		.
	rst 38h			;6554	ff		.
	rst 38h			;6555	ff		.
	rst 38h			;6556	ff		.
	rst 38h			;6557	ff		.
	rst 38h			;6558	ff		.
	rst 38h			;6559	ff		.
	rst 38h			;655a	ff		.
	rst 38h			;655b	ff		.
	rst 38h			;655c	ff		.
	rst 38h			;655d	ff		.
	rst 38h			;655e	ff		.
	rst 38h			;655f	ff		.
	rst 38h			;6560	ff		.
	rst 38h			;6561	ff		.
	rst 38h			;6562	ff		.
	rst 38h			;6563	ff		.
	rst 38h			;6564	ff		.
	rst 38h			;6565	ff		.
	rst 38h			;6566	ff		.
	rst 38h			;6567	ff		.
	rst 38h			;6568	ff		.
	rst 38h			;6569	ff		.
	rst 38h			;656a	ff		.
	rst 38h			;656b	ff		.
	rst 38h			;656c	ff		.
	rst 38h			;656d	ff		.
	rst 38h			;656e	ff		.
	rst 38h			;656f	ff		.
	rst 38h			;6570	ff		.
	rst 38h			;6571	ff		.
	rst 38h			;6572	ff		.
	rst 38h			;6573	ff		.
	rst 38h			;6574	ff		.
	rst 38h			;6575	ff		.
	rst 38h			;6576	ff		.
	rst 38h			;6577	ff		.
	rst 38h			;6578	ff		.
	rst 38h			;6579	ff		.
	rst 38h			;657a	ff		.
	rst 38h			;657b	ff		.
	rst 38h			;657c	ff		.
	rst 38h			;657d	ff		.
	rst 38h			;657e	ff		.
	rst 38h			;657f	ff		.
	rst 38h			;6580	ff		.
	rst 38h			;6581	ff		.
	rst 38h			;6582	ff		.
	rst 38h			;6583	ff		.
	rst 38h			;6584	ff		.
	rst 38h			;6585	ff		.
	rst 38h			;6586	ff		.
	rst 38h			;6587	ff		.
	rst 38h			;6588	ff		.
	rst 38h			;6589	ff		.
	rst 38h			;658a	ff		.
	rst 38h			;658b	ff		.
	rst 38h			;658c	ff		.
	rst 38h			;658d	ff		.
	rst 38h			;658e	ff		.
	rst 38h			;658f	ff		.
	rst 38h			;6590	ff		.
	rst 38h			;6591	ff		.
	rst 38h			;6592	ff		.
	rst 38h			;6593	ff		.
	rst 38h			;6594	ff		.
	rst 38h			;6595	ff		.
	rst 38h			;6596	ff		.
	rst 38h			;6597	ff		.
	rst 38h			;6598	ff		.
	rst 38h			;6599	ff		.
	rst 38h			;659a	ff		.
	rst 38h			;659b	ff		.
	rst 38h			;659c	ff		.
	rst 38h			;659d	ff		.
	rst 38h			;659e	ff		.
	rst 38h			;659f	ff		.
	rst 38h			;65a0	ff		.
	rst 38h			;65a1	ff		.
	rst 38h			;65a2	ff		.
	rst 38h			;65a3	ff		.
	rst 38h			;65a4	ff		.
	rst 38h			;65a5	ff		.
	rst 38h			;65a6	ff		.
	rst 38h			;65a7	ff		.
	rst 38h			;65a8	ff		.
	rst 38h			;65a9	ff		.
	rst 38h			;65aa	ff		.
	rst 38h			;65ab	ff		.
	rst 38h			;65ac	ff		.
	rst 38h			;65ad	ff		.
	rst 38h			;65ae	ff		.
	rst 38h			;65af	ff		.
	rst 38h			;65b0	ff		.
	rst 38h			;65b1	ff		.
	rst 38h			;65b2	ff		.
	rst 38h			;65b3	ff		.
	rst 38h			;65b4	ff		.
	rst 38h			;65b5	ff		.
	rst 38h			;65b6	ff		.
	rst 38h			;65b7	ff		.
	rst 38h			;65b8	ff		.
	rst 38h			;65b9	ff		.
	rst 38h			;65ba	ff		.
	rst 38h			;65bb	ff		.
	rst 38h			;65bc	ff		.
	rst 38h			;65bd	ff		.
	rst 38h			;65be	ff		.
	rst 38h			;65bf	ff		.
	rst 38h			;65c0	ff		.
	rst 38h			;65c1	ff		.
	rst 38h			;65c2	ff		.
	rst 38h			;65c3	ff		.
	rst 38h			;65c4	ff		.
	rst 38h			;65c5	ff		.
	rst 38h			;65c6	ff		.
	rst 38h			;65c7	ff		.
	rst 38h			;65c8	ff		.
	rst 38h			;65c9	ff		.
	rst 38h			;65ca	ff		.
	rst 38h			;65cb	ff		.
	rst 38h			;65cc	ff		.
	rst 38h			;65cd	ff		.
	rst 38h			;65ce	ff		.
	rst 38h			;65cf	ff		.
	rst 38h			;65d0	ff		.
	rst 38h			;65d1	ff		.
	rst 38h			;65d2	ff		.
	rst 38h			;65d3	ff		.
	rst 38h			;65d4	ff		.
	rst 38h			;65d5	ff		.
	rst 38h			;65d6	ff		.
	rst 38h			;65d7	ff		.
	rst 38h			;65d8	ff		.
	rst 38h			;65d9	ff		.
	rst 38h			;65da	ff		.
	rst 38h			;65db	ff		.
	rst 38h			;65dc	ff		.
	rst 38h			;65dd	ff		.
	rst 38h			;65de	ff		.
	rst 38h			;65df	ff		.
	rst 38h			;65e0	ff		.
	rst 38h			;65e1	ff		.
	rst 38h			;65e2	ff		.
	rst 38h			;65e3	ff		.
	rst 38h			;65e4	ff		.
	rst 38h			;65e5	ff		.
	rst 38h			;65e6	ff		.
	rst 38h			;65e7	ff		.
	rst 38h			;65e8	ff		.
	rst 38h			;65e9	ff		.
	rst 38h			;65ea	ff		.
	rst 38h			;65eb	ff		.
	rst 38h			;65ec	ff		.
	rst 38h			;65ed	ff		.
	rst 38h			;65ee	ff		.
	rst 38h			;65ef	ff		.
	rst 38h			;65f0	ff		.
	rst 38h			;65f1	ff		.
	rst 38h			;65f2	ff		.
	rst 38h			;65f3	ff		.
	rst 38h			;65f4	ff		.
	rst 38h			;65f5	ff		.
	rst 38h			;65f6	ff		.
	rst 38h			;65f7	ff		.
	rst 38h			;65f8	ff		.
	rst 38h			;65f9	ff		.
	rst 38h			;65fa	ff		.
	rst 38h			;65fb	ff		.
	rst 38h			;65fc	ff		.
	rst 38h			;65fd	ff		.
	rst 38h			;65fe	ff		.
	rst 38h			;65ff	ff		.
	rst 38h			;6600	ff		.
	rst 38h			;6601	ff		.
	rst 38h			;6602	ff		.
	rst 38h			;6603	ff		.
	rst 38h			;6604	ff		.
	rst 38h			;6605	ff		.
	rst 38h			;6606	ff		.
	rst 38h			;6607	ff		.
	rst 38h			;6608	ff		.
	rst 38h			;6609	ff		.
	rst 38h			;660a	ff		.
	rst 38h			;660b	ff		.
	rst 38h			;660c	ff		.
	rst 38h			;660d	ff		.
	rst 38h			;660e	ff		.
	rst 38h			;660f	ff		.
	rst 38h			;6610	ff		.
	rst 38h			;6611	ff		.
	rst 38h			;6612	ff		.
	rst 38h			;6613	ff		.
	rst 38h			;6614	ff		.
	rst 38h			;6615	ff		.
	rst 38h			;6616	ff		.
	rst 38h			;6617	ff		.
	rst 38h			;6618	ff		.
	rst 38h			;6619	ff		.
	rst 38h			;661a	ff		.
	rst 38h			;661b	ff		.
	rst 38h			;661c	ff		.
	rst 38h			;661d	ff		.
	rst 38h			;661e	ff		.
	rst 38h			;661f	ff		.
	rst 38h			;6620	ff		.
	rst 38h			;6621	ff		.
	rst 38h			;6622	ff		.
	rst 38h			;6623	ff		.
	rst 38h			;6624	ff		.
	rst 38h			;6625	ff		.
	rst 38h			;6626	ff		.
	rst 38h			;6627	ff		.
	rst 38h			;6628	ff		.
	rst 38h			;6629	ff		.
	rst 38h			;662a	ff		.
	rst 38h			;662b	ff		.
	rst 38h			;662c	ff		.
	rst 38h			;662d	ff		.
	rst 38h			;662e	ff		.
	rst 38h			;662f	ff		.
	rst 38h			;6630	ff		.
	rst 38h			;6631	ff		.
	rst 38h			;6632	ff		.
	rst 38h			;6633	ff		.
	rst 38h			;6634	ff		.
	rst 38h			;6635	ff		.
	rst 38h			;6636	ff		.
	rst 38h			;6637	ff		.
	rst 38h			;6638	ff		.
	rst 38h			;6639	ff		.
	rst 38h			;663a	ff		.
	rst 38h			;663b	ff		.
	rst 38h			;663c	ff		.
	rst 38h			;663d	ff		.
	rst 38h			;663e	ff		.
	rst 38h			;663f	ff		.
	rst 38h			;6640	ff		.
	rst 38h			;6641	ff		.
	rst 38h			;6642	ff		.
	rst 38h			;6643	ff		.
	rst 38h			;6644	ff		.
	rst 38h			;6645	ff		.
	rst 38h			;6646	ff		.
	rst 38h			;6647	ff		.
	rst 38h			;6648	ff		.
	rst 38h			;6649	ff		.
	rst 38h			;664a	ff		.
	rst 38h			;664b	ff		.
	rst 38h			;664c	ff		.
	rst 38h			;664d	ff		.
	rst 38h			;664e	ff		.
	rst 38h			;664f	ff		.
	rst 38h			;6650	ff		.
	rst 38h			;6651	ff		.
	rst 38h			;6652	ff		.
	rst 38h			;6653	ff		.
	rst 38h			;6654	ff		.
	rst 38h			;6655	ff		.
	rst 38h			;6656	ff		.
	rst 38h			;6657	ff		.
	rst 38h			;6658	ff		.
	rst 38h			;6659	ff		.
	rst 38h			;665a	ff		.
	rst 38h			;665b	ff		.
	rst 38h			;665c	ff		.
	rst 38h			;665d	ff		.
	rst 38h			;665e	ff		.
	rst 38h			;665f	ff		.
	rst 38h			;6660	ff		.
	rst 38h			;6661	ff		.
	rst 38h			;6662	ff		.
	rst 38h			;6663	ff		.
	rst 38h			;6664	ff		.
	rst 38h			;6665	ff		.
	rst 38h			;6666	ff		.
	rst 38h			;6667	ff		.
	rst 38h			;6668	ff		.
	rst 38h			;6669	ff		.
	rst 38h			;666a	ff		.
	rst 38h			;666b	ff		.
	rst 38h			;666c	ff		.
	rst 38h			;666d	ff		.
	rst 38h			;666e	ff		.
	rst 38h			;666f	ff		.
	rst 38h			;6670	ff		.
	rst 38h			;6671	ff		.
	rst 38h			;6672	ff		.
	rst 38h			;6673	ff		.
	rst 38h			;6674	ff		.
	rst 38h			;6675	ff		.
	rst 38h			;6676	ff		.
	rst 38h			;6677	ff		.
	rst 38h			;6678	ff		.
	rst 38h			;6679	ff		.
	rst 38h			;667a	ff		.
	rst 38h			;667b	ff		.
	rst 38h			;667c	ff		.
	rst 38h			;667d	ff		.
	rst 38h			;667e	ff		.
	rst 38h			;667f	ff		.
	rst 38h			;6680	ff		.
	rst 38h			;6681	ff		.
	rst 38h			;6682	ff		.
	rst 38h			;6683	ff		.
	rst 38h			;6684	ff		.
	rst 38h			;6685	ff		.
	rst 38h			;6686	ff		.
	rst 38h			;6687	ff		.
	rst 38h			;6688	ff		.
	rst 38h			;6689	ff		.
	rst 38h			;668a	ff		.
	rst 38h			;668b	ff		.
	rst 38h			;668c	ff		.
	rst 38h			;668d	ff		.
	rst 38h			;668e	ff		.
	rst 38h			;668f	ff		.
	rst 38h			;6690	ff		.
	rst 38h			;6691	ff		.
	rst 38h			;6692	ff		.
	rst 38h			;6693	ff		.
	rst 38h			;6694	ff		.
	rst 38h			;6695	ff		.
	rst 38h			;6696	ff		.
	rst 38h			;6697	ff		.
	rst 38h			;6698	ff		.
	rst 38h			;6699	ff		.
	rst 38h			;669a	ff		.
	rst 38h			;669b	ff		.
	rst 38h			;669c	ff		.
	rst 38h			;669d	ff		.
	rst 38h			;669e	ff		.
	rst 38h			;669f	ff		.
	rst 38h			;66a0	ff		.
	rst 38h			;66a1	ff		.
	rst 38h			;66a2	ff		.
	rst 38h			;66a3	ff		.
	rst 38h			;66a4	ff		.
	rst 38h			;66a5	ff		.
	rst 38h			;66a6	ff		.
	rst 38h			;66a7	ff		.
	rst 38h			;66a8	ff		.
	rst 38h			;66a9	ff		.
	rst 38h			;66aa	ff		.
	rst 38h			;66ab	ff		.
	rst 38h			;66ac	ff		.
	rst 38h			;66ad	ff		.
	rst 38h			;66ae	ff		.
	rst 38h			;66af	ff		.
	rst 38h			;66b0	ff		.
	rst 38h			;66b1	ff		.
	rst 38h			;66b2	ff		.
	rst 38h			;66b3	ff		.
	rst 38h			;66b4	ff		.
	rst 38h			;66b5	ff		.
	rst 38h			;66b6	ff		.
	rst 38h			;66b7	ff		.
	rst 38h			;66b8	ff		.
	rst 38h			;66b9	ff		.
	rst 38h			;66ba	ff		.
	rst 38h			;66bb	ff		.
	rst 38h			;66bc	ff		.
	rst 38h			;66bd	ff		.
	rst 38h			;66be	ff		.
	rst 38h			;66bf	ff		.
	rst 38h			;66c0	ff		.
	rst 38h			;66c1	ff		.
	rst 38h			;66c2	ff		.
	rst 38h			;66c3	ff		.
	rst 38h			;66c4	ff		.
	rst 38h			;66c5	ff		.
	rst 38h			;66c6	ff		.
	rst 38h			;66c7	ff		.
	rst 38h			;66c8	ff		.
	rst 38h			;66c9	ff		.
	rst 38h			;66ca	ff		.
	rst 38h			;66cb	ff		.
	rst 38h			;66cc	ff		.
	rst 38h			;66cd	ff		.
	rst 38h			;66ce	ff		.
	rst 38h			;66cf	ff		.
	rst 38h			;66d0	ff		.
	rst 38h			;66d1	ff		.
	rst 38h			;66d2	ff		.
	rst 38h			;66d3	ff		.
	rst 38h			;66d4	ff		.
	rst 38h			;66d5	ff		.
	rst 38h			;66d6	ff		.
	rst 38h			;66d7	ff		.
	rst 38h			;66d8	ff		.
	rst 38h			;66d9	ff		.
	rst 38h			;66da	ff		.
	rst 38h			;66db	ff		.
	rst 38h			;66dc	ff		.
	rst 38h			;66dd	ff		.
	rst 38h			;66de	ff		.
	rst 38h			;66df	ff		.
	rst 38h			;66e0	ff		.
	rst 38h			;66e1	ff		.
	rst 38h			;66e2	ff		.
	rst 38h			;66e3	ff		.
	rst 38h			;66e4	ff		.
	rst 38h			;66e5	ff		.
	rst 38h			;66e6	ff		.
	rst 38h			;66e7	ff		.
	rst 38h			;66e8	ff		.
	rst 38h			;66e9	ff		.
	rst 38h			;66ea	ff		.
	rst 38h			;66eb	ff		.
	rst 38h			;66ec	ff		.
	rst 38h			;66ed	ff		.
	rst 38h			;66ee	ff		.
	rst 38h			;66ef	ff		.
	rst 38h			;66f0	ff		.
	rst 38h			;66f1	ff		.
	rst 38h			;66f2	ff		.
	rst 38h			;66f3	ff		.
	rst 38h			;66f4	ff		.
	rst 38h			;66f5	ff		.
	rst 38h			;66f6	ff		.
	rst 38h			;66f7	ff		.
	rst 38h			;66f8	ff		.
	rst 38h			;66f9	ff		.
	rst 38h			;66fa	ff		.
	rst 38h			;66fb	ff		.
	rst 38h			;66fc	ff		.
	rst 38h			;66fd	ff		.
	rst 38h			;66fe	ff		.
	rst 38h			;66ff	ff		.
	rst 38h			;6700	ff		.
	rst 38h			;6701	ff		.
	rst 38h			;6702	ff		.
	rst 38h			;6703	ff		.
	rst 38h			;6704	ff		.
	rst 38h			;6705	ff		.
	rst 38h			;6706	ff		.
	rst 38h			;6707	ff		.
	rst 38h			;6708	ff		.
	rst 38h			;6709	ff		.
	rst 38h			;670a	ff		.
	rst 38h			;670b	ff		.
	rst 38h			;670c	ff		.
	rst 38h			;670d	ff		.
	rst 38h			;670e	ff		.
	rst 38h			;670f	ff		.
	rst 38h			;6710	ff		.
	rst 38h			;6711	ff		.
	rst 38h			;6712	ff		.
	rst 38h			;6713	ff		.
	rst 38h			;6714	ff		.
	rst 38h			;6715	ff		.
	rst 38h			;6716	ff		.
	rst 38h			;6717	ff		.
	rst 38h			;6718	ff		.
	rst 38h			;6719	ff		.
	rst 38h			;671a	ff		.
	rst 38h			;671b	ff		.
	rst 38h			;671c	ff		.
	rst 38h			;671d	ff		.
	rst 38h			;671e	ff		.
	rst 38h			;671f	ff		.
	rst 38h			;6720	ff		.
	rst 38h			;6721	ff		.
	rst 38h			;6722	ff		.
	rst 38h			;6723	ff		.
	rst 38h			;6724	ff		.
	rst 38h			;6725	ff		.
	rst 38h			;6726	ff		.
	rst 38h			;6727	ff		.
	rst 38h			;6728	ff		.
	rst 38h			;6729	ff		.
	rst 38h			;672a	ff		.
	rst 38h			;672b	ff		.
	rst 38h			;672c	ff		.
	rst 38h			;672d	ff		.
	rst 38h			;672e	ff		.
	rst 38h			;672f	ff		.
	rst 38h			;6730	ff		.
	rst 38h			;6731	ff		.
	rst 38h			;6732	ff		.
	rst 38h			;6733	ff		.
	rst 38h			;6734	ff		.
	rst 38h			;6735	ff		.
	rst 38h			;6736	ff		.
	rst 38h			;6737	ff		.
	rst 38h			;6738	ff		.
	rst 38h			;6739	ff		.
	rst 38h			;673a	ff		.
	rst 38h			;673b	ff		.
	rst 38h			;673c	ff		.
	rst 38h			;673d	ff		.
	rst 38h			;673e	ff		.
	rst 38h			;673f	ff		.
	rst 38h			;6740	ff		.
	rst 38h			;6741	ff		.
	rst 38h			;6742	ff		.
	rst 38h			;6743	ff		.
	rst 38h			;6744	ff		.
	rst 38h			;6745	ff		.
	rst 38h			;6746	ff		.
	rst 38h			;6747	ff		.
	rst 38h			;6748	ff		.
	rst 38h			;6749	ff		.
	rst 38h			;674a	ff		.
	rst 38h			;674b	ff		.
	rst 38h			;674c	ff		.
	rst 38h			;674d	ff		.
	rst 38h			;674e	ff		.
	rst 38h			;674f	ff		.
	rst 38h			;6750	ff		.
	rst 38h			;6751	ff		.
	rst 38h			;6752	ff		.
	rst 38h			;6753	ff		.
	rst 38h			;6754	ff		.
	rst 38h			;6755	ff		.
	rst 38h			;6756	ff		.
	rst 38h			;6757	ff		.
	rst 38h			;6758	ff		.
	rst 38h			;6759	ff		.
	rst 38h			;675a	ff		.
	rst 38h			;675b	ff		.
	rst 38h			;675c	ff		.
	rst 38h			;675d	ff		.
	rst 38h			;675e	ff		.
	rst 38h			;675f	ff		.
	rst 38h			;6760	ff		.
	rst 38h			;6761	ff		.
	rst 38h			;6762	ff		.
	rst 38h			;6763	ff		.
	rst 38h			;6764	ff		.
	rst 38h			;6765	ff		.
	rst 38h			;6766	ff		.
	rst 38h			;6767	ff		.
	rst 38h			;6768	ff		.
	rst 38h			;6769	ff		.
	rst 38h			;676a	ff		.
	rst 38h			;676b	ff		.
	rst 38h			;676c	ff		.
	rst 38h			;676d	ff		.
	rst 38h			;676e	ff		.
	rst 38h			;676f	ff		.
	rst 38h			;6770	ff		.
	rst 38h			;6771	ff		.
	rst 38h			;6772	ff		.
	rst 38h			;6773	ff		.
	rst 38h			;6774	ff		.
	rst 38h			;6775	ff		.
	rst 38h			;6776	ff		.
	rst 38h			;6777	ff		.
	rst 38h			;6778	ff		.
	rst 38h			;6779	ff		.
	rst 38h			;677a	ff		.
	rst 38h			;677b	ff		.
	rst 38h			;677c	ff		.
	rst 38h			;677d	ff		.
	rst 38h			;677e	ff		.
	rst 38h			;677f	ff		.
	rst 38h			;6780	ff		.
	rst 38h			;6781	ff		.
	rst 38h			;6782	ff		.
	rst 38h			;6783	ff		.
	rst 38h			;6784	ff		.
	rst 38h			;6785	ff		.
	rst 38h			;6786	ff		.
	rst 38h			;6787	ff		.
	rst 38h			;6788	ff		.
	rst 38h			;6789	ff		.
	rst 38h			;678a	ff		.
	rst 38h			;678b	ff		.
	rst 38h			;678c	ff		.
	rst 38h			;678d	ff		.
	rst 38h			;678e	ff		.
	rst 38h			;678f	ff		.
	rst 38h			;6790	ff		.
	rst 38h			;6791	ff		.
	rst 38h			;6792	ff		.
	rst 38h			;6793	ff		.
	rst 38h			;6794	ff		.
	rst 38h			;6795	ff		.
	rst 38h			;6796	ff		.
	rst 38h			;6797	ff		.
	rst 38h			;6798	ff		.
	rst 38h			;6799	ff		.
	rst 38h			;679a	ff		.
	rst 38h			;679b	ff		.
	rst 38h			;679c	ff		.
	rst 38h			;679d	ff		.
	rst 38h			;679e	ff		.
	rst 38h			;679f	ff		.
	rst 38h			;67a0	ff		.
	rst 38h			;67a1	ff		.
	rst 38h			;67a2	ff		.
	rst 38h			;67a3	ff		.
	rst 38h			;67a4	ff		.
	rst 38h			;67a5	ff		.
	rst 38h			;67a6	ff		.
	rst 38h			;67a7	ff		.
	rst 38h			;67a8	ff		.
	rst 38h			;67a9	ff		.
	rst 38h			;67aa	ff		.
	rst 38h			;67ab	ff		.
	rst 38h			;67ac	ff		.
	rst 38h			;67ad	ff		.
	rst 38h			;67ae	ff		.
	rst 38h			;67af	ff		.
	rst 38h			;67b0	ff		.
	rst 38h			;67b1	ff		.
	rst 38h			;67b2	ff		.
	rst 38h			;67b3	ff		.
	rst 38h			;67b4	ff		.
	rst 38h			;67b5	ff		.
	rst 38h			;67b6	ff		.
	rst 38h			;67b7	ff		.
	rst 38h			;67b8	ff		.
	rst 38h			;67b9	ff		.
	rst 38h			;67ba	ff		.
	rst 38h			;67bb	ff		.
	rst 38h			;67bc	ff		.
	rst 38h			;67bd	ff		.
	rst 38h			;67be	ff		.
	rst 38h			;67bf	ff		.
	rst 38h			;67c0	ff		.
	rst 38h			;67c1	ff		.
	rst 38h			;67c2	ff		.
	rst 38h			;67c3	ff		.
	rst 38h			;67c4	ff		.
	rst 38h			;67c5	ff		.
	rst 38h			;67c6	ff		.
	rst 38h			;67c7	ff		.
	rst 38h			;67c8	ff		.
	rst 38h			;67c9	ff		.
	rst 38h			;67ca	ff		.
	rst 38h			;67cb	ff		.
	rst 38h			;67cc	ff		.
	rst 38h			;67cd	ff		.
	rst 38h			;67ce	ff		.
	rst 38h			;67cf	ff		.
	rst 38h			;67d0	ff		.
	rst 38h			;67d1	ff		.
	rst 38h			;67d2	ff		.
	rst 38h			;67d3	ff		.
	rst 38h			;67d4	ff		.
	rst 38h			;67d5	ff		.
	rst 38h			;67d6	ff		.
	rst 38h			;67d7	ff		.
	rst 38h			;67d8	ff		.
	rst 38h			;67d9	ff		.
	rst 38h			;67da	ff		.
	rst 38h			;67db	ff		.
	rst 38h			;67dc	ff		.
	rst 38h			;67dd	ff		.
	rst 38h			;67de	ff		.
	rst 38h			;67df	ff		.
	rst 38h			;67e0	ff		.
	rst 38h			;67e1	ff		.
	rst 38h			;67e2	ff		.
	rst 38h			;67e3	ff		.
	rst 38h			;67e4	ff		.
	rst 38h			;67e5	ff		.
	rst 38h			;67e6	ff		.
	rst 38h			;67e7	ff		.
	rst 38h			;67e8	ff		.
	rst 38h			;67e9	ff		.
	rst 38h			;67ea	ff		.
	rst 38h			;67eb	ff		.
	rst 38h			;67ec	ff		.
	rst 38h			;67ed	ff		.
	rst 38h			;67ee	ff		.
	rst 38h			;67ef	ff		.
	rst 38h			;67f0	ff		.
	rst 38h			;67f1	ff		.
	rst 38h			;67f2	ff		.
	rst 38h			;67f3	ff		.
	rst 38h			;67f4	ff		.
	rst 38h			;67f5	ff		.
	rst 38h			;67f6	ff		.
	rst 38h			;67f7	ff		.
	rst 38h			;67f8	ff		.
	rst 38h			;67f9	ff		.
	rst 38h			;67fa	ff		.
	rst 38h			;67fb	ff		.
	rst 38h			;67fc	ff		.
	rst 38h			;67fd	ff		.
	rst 38h			;67fe	ff		.
	rst 38h			;67ff	ff		.
	rst 38h			;6800	ff		.
	rst 38h			;6801	ff		.
	rst 38h			;6802	ff		.
	rst 38h			;6803	ff		.
	rst 38h			;6804	ff		.
	rst 38h			;6805	ff		.
	rst 38h			;6806	ff		.
	rst 38h			;6807	ff		.
	rst 38h			;6808	ff		.
	rst 38h			;6809	ff		.
	rst 38h			;680a	ff		.
	rst 38h			;680b	ff		.
	rst 38h			;680c	ff		.
	rst 38h			;680d	ff		.
	rst 38h			;680e	ff		.
	rst 38h			;680f	ff		.
	rst 38h			;6810	ff		.
	rst 38h			;6811	ff		.
	rst 38h			;6812	ff		.
	rst 38h			;6813	ff		.
	rst 38h			;6814	ff		.
	rst 38h			;6815	ff		.
	rst 38h			;6816	ff		.
	rst 38h			;6817	ff		.
	rst 38h			;6818	ff		.
	rst 38h			;6819	ff		.
	rst 38h			;681a	ff		.
	rst 38h			;681b	ff		.
	rst 38h			;681c	ff		.
	rst 38h			;681d	ff		.
	rst 38h			;681e	ff		.
	rst 38h			;681f	ff		.
	rst 38h			;6820	ff		.
	rst 38h			;6821	ff		.
	rst 38h			;6822	ff		.
	rst 38h			;6823	ff		.
	rst 38h			;6824	ff		.
	rst 38h			;6825	ff		.
	rst 38h			;6826	ff		.
	rst 38h			;6827	ff		.
	rst 38h			;6828	ff		.
	rst 38h			;6829	ff		.
	rst 38h			;682a	ff		.
	rst 38h			;682b	ff		.
	rst 38h			;682c	ff		.
	rst 38h			;682d	ff		.
	rst 38h			;682e	ff		.
	rst 38h			;682f	ff		.
	rst 38h			;6830	ff		.
	rst 38h			;6831	ff		.
	rst 38h			;6832	ff		.
	rst 38h			;6833	ff		.
	rst 38h			;6834	ff		.
	rst 38h			;6835	ff		.
	rst 38h			;6836	ff		.
	rst 38h			;6837	ff		.
	rst 38h			;6838	ff		.
	rst 38h			;6839	ff		.
	rst 38h			;683a	ff		.
	rst 38h			;683b	ff		.
	rst 38h			;683c	ff		.
	rst 38h			;683d	ff		.
	rst 38h			;683e	ff		.
	rst 38h			;683f	ff		.
	rst 38h			;6840	ff		.
	rst 38h			;6841	ff		.
	rst 38h			;6842	ff		.
	rst 38h			;6843	ff		.
	rst 38h			;6844	ff		.
	rst 38h			;6845	ff		.
	rst 38h			;6846	ff		.
	rst 38h			;6847	ff		.
	rst 38h			;6848	ff		.
	rst 38h			;6849	ff		.
	rst 38h			;684a	ff		.
	rst 38h			;684b	ff		.
	rst 38h			;684c	ff		.
	rst 38h			;684d	ff		.
	rst 38h			;684e	ff		.
	rst 38h			;684f	ff		.
	rst 38h			;6850	ff		.
	rst 38h			;6851	ff		.
	rst 38h			;6852	ff		.
	rst 38h			;6853	ff		.
	rst 38h			;6854	ff		.
	rst 38h			;6855	ff		.
	rst 38h			;6856	ff		.
	rst 38h			;6857	ff		.
	rst 38h			;6858	ff		.
	rst 38h			;6859	ff		.
	rst 38h			;685a	ff		.
	rst 38h			;685b	ff		.
	rst 38h			;685c	ff		.
	rst 38h			;685d	ff		.
	rst 38h			;685e	ff		.
	rst 38h			;685f	ff		.
	rst 38h			;6860	ff		.
	rst 38h			;6861	ff		.
	rst 38h			;6862	ff		.
	rst 38h			;6863	ff		.
	rst 38h			;6864	ff		.
	rst 38h			;6865	ff		.
	rst 38h			;6866	ff		.
	rst 38h			;6867	ff		.
	rst 38h			;6868	ff		.
	rst 38h			;6869	ff		.
	rst 38h			;686a	ff		.
	rst 38h			;686b	ff		.
	rst 38h			;686c	ff		.
	rst 38h			;686d	ff		.
	rst 38h			;686e	ff		.
	rst 38h			;686f	ff		.
	rst 38h			;6870	ff		.
	rst 38h			;6871	ff		.
	rst 38h			;6872	ff		.
	rst 38h			;6873	ff		.
	rst 38h			;6874	ff		.
	rst 38h			;6875	ff		.
	rst 38h			;6876	ff		.
	rst 38h			;6877	ff		.
	rst 38h			;6878	ff		.
	rst 38h			;6879	ff		.
	rst 38h			;687a	ff		.
	rst 38h			;687b	ff		.
	rst 38h			;687c	ff		.
	rst 38h			;687d	ff		.
	rst 38h			;687e	ff		.
	rst 38h			;687f	ff		.
	rst 38h			;6880	ff		.
	rst 38h			;6881	ff		.
	rst 38h			;6882	ff		.
	rst 38h			;6883	ff		.
	rst 38h			;6884	ff		.
	rst 38h			;6885	ff		.
	rst 38h			;6886	ff		.
	rst 38h			;6887	ff		.
	rst 38h			;6888	ff		.
	rst 38h			;6889	ff		.
	rst 38h			;688a	ff		.
	rst 38h			;688b	ff		.
	rst 38h			;688c	ff		.
	rst 38h			;688d	ff		.
	rst 38h			;688e	ff		.
	rst 38h			;688f	ff		.
	rst 38h			;6890	ff		.
	rst 38h			;6891	ff		.
	rst 38h			;6892	ff		.
	rst 38h			;6893	ff		.
	rst 38h			;6894	ff		.
	rst 38h			;6895	ff		.
	rst 38h			;6896	ff		.
	rst 38h			;6897	ff		.
	rst 38h			;6898	ff		.
	rst 38h			;6899	ff		.
	rst 38h			;689a	ff		.
	rst 38h			;689b	ff		.
	rst 38h			;689c	ff		.
	rst 38h			;689d	ff		.
	rst 38h			;689e	ff		.
	rst 38h			;689f	ff		.
	rst 38h			;68a0	ff		.
	rst 38h			;68a1	ff		.
	rst 38h			;68a2	ff		.
	rst 38h			;68a3	ff		.
	rst 38h			;68a4	ff		.
	rst 38h			;68a5	ff		.
	rst 38h			;68a6	ff		.
	rst 38h			;68a7	ff		.
	rst 38h			;68a8	ff		.
	rst 38h			;68a9	ff		.
	rst 38h			;68aa	ff		.
	rst 38h			;68ab	ff		.
	rst 38h			;68ac	ff		.
	rst 38h			;68ad	ff		.
	rst 38h			;68ae	ff		.
	rst 38h			;68af	ff		.
	rst 38h			;68b0	ff		.
	rst 38h			;68b1	ff		.
	rst 38h			;68b2	ff		.
	rst 38h			;68b3	ff		.
	rst 38h			;68b4	ff		.
	rst 38h			;68b5	ff		.
	rst 38h			;68b6	ff		.
	rst 38h			;68b7	ff		.
	rst 38h			;68b8	ff		.
	rst 38h			;68b9	ff		.
	rst 38h			;68ba	ff		.
	rst 38h			;68bb	ff		.
	rst 38h			;68bc	ff		.
	rst 38h			;68bd	ff		.
	rst 38h			;68be	ff		.
	rst 38h			;68bf	ff		.
	rst 38h			;68c0	ff		.
	rst 38h			;68c1	ff		.
	rst 38h			;68c2	ff		.
	rst 38h			;68c3	ff		.
	rst 38h			;68c4	ff		.
	rst 38h			;68c5	ff		.
	rst 38h			;68c6	ff		.
	rst 38h			;68c7	ff		.
	rst 38h			;68c8	ff		.
	rst 38h			;68c9	ff		.
	rst 38h			;68ca	ff		.
	rst 38h			;68cb	ff		.
	rst 38h			;68cc	ff		.
	rst 38h			;68cd	ff		.
	rst 38h			;68ce	ff		.
	rst 38h			;68cf	ff		.
	rst 38h			;68d0	ff		.
	rst 38h			;68d1	ff		.
	rst 38h			;68d2	ff		.
	rst 38h			;68d3	ff		.
	rst 38h			;68d4	ff		.
	rst 38h			;68d5	ff		.
	rst 38h			;68d6	ff		.
	rst 38h			;68d7	ff		.
	rst 38h			;68d8	ff		.
	rst 38h			;68d9	ff		.
	rst 38h			;68da	ff		.
	rst 38h			;68db	ff		.
	rst 38h			;68dc	ff		.
	rst 38h			;68dd	ff		.
	rst 38h			;68de	ff		.
	rst 38h			;68df	ff		.
	rst 38h			;68e0	ff		.
	rst 38h			;68e1	ff		.
	rst 38h			;68e2	ff		.
	rst 38h			;68e3	ff		.
	rst 38h			;68e4	ff		.
	rst 38h			;68e5	ff		.
	rst 38h			;68e6	ff		.
	rst 38h			;68e7	ff		.
	rst 38h			;68e8	ff		.
	rst 38h			;68e9	ff		.
	rst 38h			;68ea	ff		.
	rst 38h			;68eb	ff		.
	rst 38h			;68ec	ff		.
	rst 38h			;68ed	ff		.
	rst 38h			;68ee	ff		.
	rst 38h			;68ef	ff		.
	rst 38h			;68f0	ff		.
	rst 38h			;68f1	ff		.
	rst 38h			;68f2	ff		.
	rst 38h			;68f3	ff		.
	rst 38h			;68f4	ff		.
	rst 38h			;68f5	ff		.
	rst 38h			;68f6	ff		.
	rst 38h			;68f7	ff		.
	rst 38h			;68f8	ff		.
	rst 38h			;68f9	ff		.
	rst 38h			;68fa	ff		.
	rst 38h			;68fb	ff		.
	rst 38h			;68fc	ff		.
	rst 38h			;68fd	ff		.
	rst 38h			;68fe	ff		.
	rst 38h			;68ff	ff		.
	rst 38h			;6900	ff		.
	rst 38h			;6901	ff		.
	rst 38h			;6902	ff		.
	rst 38h			;6903	ff		.
	rst 38h			;6904	ff		.
	rst 38h			;6905	ff		.
	rst 38h			;6906	ff		.
	rst 38h			;6907	ff		.
	rst 38h			;6908	ff		.
	rst 38h			;6909	ff		.
	rst 38h			;690a	ff		.
	rst 38h			;690b	ff		.
	rst 38h			;690c	ff		.
	rst 38h			;690d	ff		.
	rst 38h			;690e	ff		.
	rst 38h			;690f	ff		.
	rst 38h			;6910	ff		.
	rst 38h			;6911	ff		.
	rst 38h			;6912	ff		.
	rst 38h			;6913	ff		.
	rst 38h			;6914	ff		.
	rst 38h			;6915	ff		.
	rst 38h			;6916	ff		.
	rst 38h			;6917	ff		.
	rst 38h			;6918	ff		.
	rst 38h			;6919	ff		.
	rst 38h			;691a	ff		.
	rst 38h			;691b	ff		.
	rst 38h			;691c	ff		.
	rst 38h			;691d	ff		.
	rst 38h			;691e	ff		.
	rst 38h			;691f	ff		.
	rst 38h			;6920	ff		.
	rst 38h			;6921	ff		.
	rst 38h			;6922	ff		.
	rst 38h			;6923	ff		.
	rst 38h			;6924	ff		.
	rst 38h			;6925	ff		.
	rst 38h			;6926	ff		.
	rst 38h			;6927	ff		.
	rst 38h			;6928	ff		.
	rst 38h			;6929	ff		.
	rst 38h			;692a	ff		.
	rst 38h			;692b	ff		.
	rst 38h			;692c	ff		.
	rst 38h			;692d	ff		.
	rst 38h			;692e	ff		.
	rst 38h			;692f	ff		.
	rst 38h			;6930	ff		.
	rst 38h			;6931	ff		.
	rst 38h			;6932	ff		.
	rst 38h			;6933	ff		.
	rst 38h			;6934	ff		.
	rst 38h			;6935	ff		.
	rst 38h			;6936	ff		.
	rst 38h			;6937	ff		.
	rst 38h			;6938	ff		.
	rst 38h			;6939	ff		.
	rst 38h			;693a	ff		.
	rst 38h			;693b	ff		.
	rst 38h			;693c	ff		.
	rst 38h			;693d	ff		.
	rst 38h			;693e	ff		.
	rst 38h			;693f	ff		.
	rst 38h			;6940	ff		.
	rst 38h			;6941	ff		.
	rst 38h			;6942	ff		.
	rst 38h			;6943	ff		.
	rst 38h			;6944	ff		.
	rst 38h			;6945	ff		.
	rst 38h			;6946	ff		.
	rst 38h			;6947	ff		.
	rst 38h			;6948	ff		.
	rst 38h			;6949	ff		.
	rst 38h			;694a	ff		.
	rst 38h			;694b	ff		.
	rst 38h			;694c	ff		.
	rst 38h			;694d	ff		.
	rst 38h			;694e	ff		.
	rst 38h			;694f	ff		.
	rst 38h			;6950	ff		.
	rst 38h			;6951	ff		.
	rst 38h			;6952	ff		.
	rst 38h			;6953	ff		.
	rst 38h			;6954	ff		.
	rst 38h			;6955	ff		.
	rst 38h			;6956	ff		.
	rst 38h			;6957	ff		.
	rst 38h			;6958	ff		.
	rst 38h			;6959	ff		.
	rst 38h			;695a	ff		.
	rst 38h			;695b	ff		.
	rst 38h			;695c	ff		.
	rst 38h			;695d	ff		.
	rst 38h			;695e	ff		.
	rst 38h			;695f	ff		.
	rst 38h			;6960	ff		.
	rst 38h			;6961	ff		.
	rst 38h			;6962	ff		.
	rst 38h			;6963	ff		.
	rst 38h			;6964	ff		.
	rst 38h			;6965	ff		.
	rst 38h			;6966	ff		.
	rst 38h			;6967	ff		.
	rst 38h			;6968	ff		.
	rst 38h			;6969	ff		.
	rst 38h			;696a	ff		.
	rst 38h			;696b	ff		.
	rst 38h			;696c	ff		.
	rst 38h			;696d	ff		.
	rst 38h			;696e	ff		.
	rst 38h			;696f	ff		.
	rst 38h			;6970	ff		.
	rst 38h			;6971	ff		.
	rst 38h			;6972	ff		.
	rst 38h			;6973	ff		.
	rst 38h			;6974	ff		.
	rst 38h			;6975	ff		.
	rst 38h			;6976	ff		.
	rst 38h			;6977	ff		.
	rst 38h			;6978	ff		.
	rst 38h			;6979	ff		.
	rst 38h			;697a	ff		.
	rst 38h			;697b	ff		.
	rst 38h			;697c	ff		.
	rst 38h			;697d	ff		.
	rst 38h			;697e	ff		.
	rst 38h			;697f	ff		.
	rst 38h			;6980	ff		.
	rst 38h			;6981	ff		.
	rst 38h			;6982	ff		.
	rst 38h			;6983	ff		.
	rst 38h			;6984	ff		.
	rst 38h			;6985	ff		.
	rst 38h			;6986	ff		.
	rst 38h			;6987	ff		.
	rst 38h			;6988	ff		.
	rst 38h			;6989	ff		.
	rst 38h			;698a	ff		.
	rst 38h			;698b	ff		.
	rst 38h			;698c	ff		.
	rst 38h			;698d	ff		.
	rst 38h			;698e	ff		.
	rst 38h			;698f	ff		.
	rst 38h			;6990	ff		.
	rst 38h			;6991	ff		.
	rst 38h			;6992	ff		.
	rst 38h			;6993	ff		.
	rst 38h			;6994	ff		.
	rst 38h			;6995	ff		.
	rst 38h			;6996	ff		.
	rst 38h			;6997	ff		.
	rst 38h			;6998	ff		.
	rst 38h			;6999	ff		.
	rst 38h			;699a	ff		.
	rst 38h			;699b	ff		.
	rst 38h			;699c	ff		.
	rst 38h			;699d	ff		.
	rst 38h			;699e	ff		.
	rst 38h			;699f	ff		.
	rst 38h			;69a0	ff		.
	rst 38h			;69a1	ff		.
	rst 38h			;69a2	ff		.
	rst 38h			;69a3	ff		.
	rst 38h			;69a4	ff		.
	rst 38h			;69a5	ff		.
	rst 38h			;69a6	ff		.
	rst 38h			;69a7	ff		.
	rst 38h			;69a8	ff		.
	rst 38h			;69a9	ff		.
	rst 38h			;69aa	ff		.
	rst 38h			;69ab	ff		.
	rst 38h			;69ac	ff		.
	rst 38h			;69ad	ff		.
	rst 38h			;69ae	ff		.
	rst 38h			;69af	ff		.
	rst 38h			;69b0	ff		.
	rst 38h			;69b1	ff		.
	rst 38h			;69b2	ff		.
	rst 38h			;69b3	ff		.
	rst 38h			;69b4	ff		.
	rst 38h			;69b5	ff		.
	rst 38h			;69b6	ff		.
	rst 38h			;69b7	ff		.
	rst 38h			;69b8	ff		.
	rst 38h			;69b9	ff		.
	rst 38h			;69ba	ff		.
	rst 38h			;69bb	ff		.
	rst 38h			;69bc	ff		.
	rst 38h			;69bd	ff		.
	rst 38h			;69be	ff		.
	rst 38h			;69bf	ff		.
	rst 38h			;69c0	ff		.
	rst 38h			;69c1	ff		.
	rst 38h			;69c2	ff		.
	rst 38h			;69c3	ff		.
	rst 38h			;69c4	ff		.
	rst 38h			;69c5	ff		.
	rst 38h			;69c6	ff		.
	rst 38h			;69c7	ff		.
	rst 38h			;69c8	ff		.
	rst 38h			;69c9	ff		.
	rst 38h			;69ca	ff		.
	rst 38h			;69cb	ff		.
	rst 38h			;69cc	ff		.
	rst 38h			;69cd	ff		.
	rst 38h			;69ce	ff		.
	rst 38h			;69cf	ff		.
	rst 38h			;69d0	ff		.
	rst 38h			;69d1	ff		.
	rst 38h			;69d2	ff		.
	rst 38h			;69d3	ff		.
	rst 38h			;69d4	ff		.
	rst 38h			;69d5	ff		.
	rst 38h			;69d6	ff		.
	rst 38h			;69d7	ff		.
	rst 38h			;69d8	ff		.
	rst 38h			;69d9	ff		.
	rst 38h			;69da	ff		.
	rst 38h			;69db	ff		.
	rst 38h			;69dc	ff		.
	rst 38h			;69dd	ff		.
	rst 38h			;69de	ff		.
	rst 38h			;69df	ff		.
	rst 38h			;69e0	ff		.
	rst 38h			;69e1	ff		.
	rst 38h			;69e2	ff		.
	rst 38h			;69e3	ff		.
	rst 38h			;69e4	ff		.
	rst 38h			;69e5	ff		.
	rst 38h			;69e6	ff		.
	rst 38h			;69e7	ff		.
	rst 38h			;69e8	ff		.
	rst 38h			;69e9	ff		.
	rst 38h			;69ea	ff		.
	rst 38h			;69eb	ff		.
	rst 38h			;69ec	ff		.
	rst 38h			;69ed	ff		.
	rst 38h			;69ee	ff		.
	rst 38h			;69ef	ff		.
	rst 38h			;69f0	ff		.
	rst 38h			;69f1	ff		.
	rst 38h			;69f2	ff		.
	rst 38h			;69f3	ff		.
	rst 38h			;69f4	ff		.
	rst 38h			;69f5	ff		.
	rst 38h			;69f6	ff		.
	rst 38h			;69f7	ff		.
	rst 38h			;69f8	ff		.
	rst 38h			;69f9	ff		.
	rst 38h			;69fa	ff		.
	rst 38h			;69fb	ff		.
	rst 38h			;69fc	ff		.
	rst 38h			;69fd	ff		.
	rst 38h			;69fe	ff		.
	rst 38h			;69ff	ff		.
	rst 38h			;6a00	ff		.
	rst 38h			;6a01	ff		.
	rst 38h			;6a02	ff		.
	rst 38h			;6a03	ff		.
	rst 38h			;6a04	ff		.
	rst 38h			;6a05	ff		.
	rst 38h			;6a06	ff		.
	rst 38h			;6a07	ff		.
	rst 38h			;6a08	ff		.
	rst 38h			;6a09	ff		.
	rst 38h			;6a0a	ff		.
	rst 38h			;6a0b	ff		.
	rst 38h			;6a0c	ff		.
	rst 38h			;6a0d	ff		.
	rst 38h			;6a0e	ff		.
	rst 38h			;6a0f	ff		.
	rst 38h			;6a10	ff		.
	rst 38h			;6a11	ff		.
	rst 38h			;6a12	ff		.
	rst 38h			;6a13	ff		.
	rst 38h			;6a14	ff		.
	rst 38h			;6a15	ff		.
	rst 38h			;6a16	ff		.
	rst 38h			;6a17	ff		.
	rst 38h			;6a18	ff		.
	rst 38h			;6a19	ff		.
	rst 38h			;6a1a	ff		.
	rst 38h			;6a1b	ff		.
	rst 38h			;6a1c	ff		.
	rst 38h			;6a1d	ff		.
	rst 38h			;6a1e	ff		.
	rst 38h			;6a1f	ff		.
	rst 38h			;6a20	ff		.
	rst 38h			;6a21	ff		.
	rst 38h			;6a22	ff		.
	rst 38h			;6a23	ff		.
	rst 38h			;6a24	ff		.
	rst 38h			;6a25	ff		.
	rst 38h			;6a26	ff		.
	rst 38h			;6a27	ff		.
	rst 38h			;6a28	ff		.
	rst 38h			;6a29	ff		.
	rst 38h			;6a2a	ff		.
	rst 38h			;6a2b	ff		.
	rst 38h			;6a2c	ff		.
	rst 38h			;6a2d	ff		.
	rst 38h			;6a2e	ff		.
	rst 38h			;6a2f	ff		.
	rst 38h			;6a30	ff		.
	rst 38h			;6a31	ff		.
	rst 38h			;6a32	ff		.
	rst 38h			;6a33	ff		.
	rst 38h			;6a34	ff		.
	rst 38h			;6a35	ff		.
	rst 38h			;6a36	ff		.
	rst 38h			;6a37	ff		.
	rst 38h			;6a38	ff		.
	rst 38h			;6a39	ff		.
	rst 38h			;6a3a	ff		.
	rst 38h			;6a3b	ff		.
	rst 38h			;6a3c	ff		.
	rst 38h			;6a3d	ff		.
	rst 38h			;6a3e	ff		.
	rst 38h			;6a3f	ff		.
	rst 38h			;6a40	ff		.
	rst 38h			;6a41	ff		.
	rst 38h			;6a42	ff		.
	rst 38h			;6a43	ff		.
	rst 38h			;6a44	ff		.
	rst 38h			;6a45	ff		.
	rst 38h			;6a46	ff		.
	rst 38h			;6a47	ff		.
	rst 38h			;6a48	ff		.
	rst 38h			;6a49	ff		.
	rst 38h			;6a4a	ff		.
	rst 38h			;6a4b	ff		.
	rst 38h			;6a4c	ff		.
	rst 38h			;6a4d	ff		.
	rst 38h			;6a4e	ff		.
	rst 38h			;6a4f	ff		.
	rst 38h			;6a50	ff		.
	rst 38h			;6a51	ff		.
	rst 38h			;6a52	ff		.
	rst 38h			;6a53	ff		.
	rst 38h			;6a54	ff		.
	rst 38h			;6a55	ff		.
	rst 38h			;6a56	ff		.
	rst 38h			;6a57	ff		.
	rst 38h			;6a58	ff		.
	rst 38h			;6a59	ff		.
	rst 38h			;6a5a	ff		.
	rst 38h			;6a5b	ff		.
	rst 38h			;6a5c	ff		.
	rst 38h			;6a5d	ff		.
	rst 38h			;6a5e	ff		.
	rst 38h			;6a5f	ff		.
	rst 38h			;6a60	ff		.
	rst 38h			;6a61	ff		.
	rst 38h			;6a62	ff		.
	rst 38h			;6a63	ff		.
	rst 38h			;6a64	ff		.
	rst 38h			;6a65	ff		.
	rst 38h			;6a66	ff		.
	rst 38h			;6a67	ff		.
	rst 38h			;6a68	ff		.
	rst 38h			;6a69	ff		.
	rst 38h			;6a6a	ff		.
	rst 38h			;6a6b	ff		.
	rst 38h			;6a6c	ff		.
	rst 38h			;6a6d	ff		.
	rst 38h			;6a6e	ff		.
	rst 38h			;6a6f	ff		.
	rst 38h			;6a70	ff		.
	rst 38h			;6a71	ff		.
	rst 38h			;6a72	ff		.
	rst 38h			;6a73	ff		.
	rst 38h			;6a74	ff		.
	rst 38h			;6a75	ff		.
	rst 38h			;6a76	ff		.
	rst 38h			;6a77	ff		.
	rst 38h			;6a78	ff		.
	rst 38h			;6a79	ff		.
	rst 38h			;6a7a	ff		.
	rst 38h			;6a7b	ff		.
	rst 38h			;6a7c	ff		.
	rst 38h			;6a7d	ff		.
	rst 38h			;6a7e	ff		.
	rst 38h			;6a7f	ff		.
	rst 38h			;6a80	ff		.
	rst 38h			;6a81	ff		.
	rst 38h			;6a82	ff		.
	rst 38h			;6a83	ff		.
	rst 38h			;6a84	ff		.
	rst 38h			;6a85	ff		.
	rst 38h			;6a86	ff		.
	rst 38h			;6a87	ff		.
	rst 38h			;6a88	ff		.
	rst 38h			;6a89	ff		.
	rst 38h			;6a8a	ff		.
	rst 38h			;6a8b	ff		.
	rst 38h			;6a8c	ff		.
	rst 38h			;6a8d	ff		.
	rst 38h			;6a8e	ff		.
	rst 38h			;6a8f	ff		.
	rst 38h			;6a90	ff		.
	rst 38h			;6a91	ff		.
	rst 38h			;6a92	ff		.
	rst 38h			;6a93	ff		.
	rst 38h			;6a94	ff		.
	rst 38h			;6a95	ff		.
	rst 38h			;6a96	ff		.
	rst 38h			;6a97	ff		.
	rst 38h			;6a98	ff		.
	rst 38h			;6a99	ff		.
	rst 38h			;6a9a	ff		.
	rst 38h			;6a9b	ff		.
	rst 38h			;6a9c	ff		.
	rst 38h			;6a9d	ff		.
	rst 38h			;6a9e	ff		.
	rst 38h			;6a9f	ff		.
	rst 38h			;6aa0	ff		.
	rst 38h			;6aa1	ff		.
	rst 38h			;6aa2	ff		.
	rst 38h			;6aa3	ff		.
	rst 38h			;6aa4	ff		.
	rst 38h			;6aa5	ff		.
	rst 38h			;6aa6	ff		.
	rst 38h			;6aa7	ff		.
	rst 38h			;6aa8	ff		.
	rst 38h			;6aa9	ff		.
	rst 38h			;6aaa	ff		.
	rst 38h			;6aab	ff		.
	rst 38h			;6aac	ff		.
	rst 38h			;6aad	ff		.
	rst 38h			;6aae	ff		.
	rst 38h			;6aaf	ff		.
	rst 38h			;6ab0	ff		.
	rst 38h			;6ab1	ff		.
	rst 38h			;6ab2	ff		.
	rst 38h			;6ab3	ff		.
	rst 38h			;6ab4	ff		.
	rst 38h			;6ab5	ff		.
	rst 38h			;6ab6	ff		.
	rst 38h			;6ab7	ff		.
	rst 38h			;6ab8	ff		.
	rst 38h			;6ab9	ff		.
	rst 38h			;6aba	ff		.
	rst 38h			;6abb	ff		.
	rst 38h			;6abc	ff		.
	rst 38h			;6abd	ff		.
	rst 38h			;6abe	ff		.
	rst 38h			;6abf	ff		.
	rst 38h			;6ac0	ff		.
	rst 38h			;6ac1	ff		.
	rst 38h			;6ac2	ff		.
	rst 38h			;6ac3	ff		.
	rst 38h			;6ac4	ff		.
	rst 38h			;6ac5	ff		.
	rst 38h			;6ac6	ff		.
	rst 38h			;6ac7	ff		.
	rst 38h			;6ac8	ff		.
	rst 38h			;6ac9	ff		.
	rst 38h			;6aca	ff		.
	rst 38h			;6acb	ff		.
	rst 38h			;6acc	ff		.
	rst 38h			;6acd	ff		.
	rst 38h			;6ace	ff		.
	rst 38h			;6acf	ff		.
	rst 38h			;6ad0	ff		.
	rst 38h			;6ad1	ff		.
	rst 38h			;6ad2	ff		.
	rst 38h			;6ad3	ff		.
	rst 38h			;6ad4	ff		.
	rst 38h			;6ad5	ff		.
	rst 38h			;6ad6	ff		.
	rst 38h			;6ad7	ff		.
	rst 38h			;6ad8	ff		.
	rst 38h			;6ad9	ff		.
	rst 38h			;6ada	ff		.
	rst 38h			;6adb	ff		.
	rst 38h			;6adc	ff		.
	rst 38h			;6add	ff		.
	rst 38h			;6ade	ff		.
	rst 38h			;6adf	ff		.
	rst 38h			;6ae0	ff		.
	rst 38h			;6ae1	ff		.
	rst 38h			;6ae2	ff		.
	rst 38h			;6ae3	ff		.
	rst 38h			;6ae4	ff		.
	rst 38h			;6ae5	ff		.
	rst 38h			;6ae6	ff		.
	rst 38h			;6ae7	ff		.
	rst 38h			;6ae8	ff		.
	rst 38h			;6ae9	ff		.
	rst 38h			;6aea	ff		.
	rst 38h			;6aeb	ff		.
	rst 38h			;6aec	ff		.
	rst 38h			;6aed	ff		.
	rst 38h			;6aee	ff		.
	rst 38h			;6aef	ff		.
	rst 38h			;6af0	ff		.
	rst 38h			;6af1	ff		.
	rst 38h			;6af2	ff		.
	rst 38h			;6af3	ff		.
	rst 38h			;6af4	ff		.
	rst 38h			;6af5	ff		.
	rst 38h			;6af6	ff		.
	rst 38h			;6af7	ff		.
	rst 38h			;6af8	ff		.
	rst 38h			;6af9	ff		.
	rst 38h			;6afa	ff		.
	rst 38h			;6afb	ff		.
	rst 38h			;6afc	ff		.
	rst 38h			;6afd	ff		.
	rst 38h			;6afe	ff		.
	rst 38h			;6aff	ff		.
	rst 38h			;6b00	ff		.
	rst 38h			;6b01	ff		.
	rst 38h			;6b02	ff		.
	rst 38h			;6b03	ff		.
	rst 38h			;6b04	ff		.
	rst 38h			;6b05	ff		.
	rst 38h			;6b06	ff		.
	rst 38h			;6b07	ff		.
	rst 38h			;6b08	ff		.
	rst 38h			;6b09	ff		.
	rst 38h			;6b0a	ff		.
	rst 38h			;6b0b	ff		.
	rst 38h			;6b0c	ff		.
	rst 38h			;6b0d	ff		.
	rst 38h			;6b0e	ff		.
	rst 38h			;6b0f	ff		.
	rst 38h			;6b10	ff		.
	rst 38h			;6b11	ff		.
	rst 38h			;6b12	ff		.
	rst 38h			;6b13	ff		.
	rst 38h			;6b14	ff		.
	rst 38h			;6b15	ff		.
	rst 38h			;6b16	ff		.
	rst 38h			;6b17	ff		.
	rst 38h			;6b18	ff		.
	rst 38h			;6b19	ff		.
	rst 38h			;6b1a	ff		.
	rst 38h			;6b1b	ff		.
	rst 38h			;6b1c	ff		.
	rst 38h			;6b1d	ff		.
	rst 38h			;6b1e	ff		.
	rst 38h			;6b1f	ff		.
	rst 38h			;6b20	ff		.
	rst 38h			;6b21	ff		.
	rst 38h			;6b22	ff		.
	rst 38h			;6b23	ff		.
	rst 38h			;6b24	ff		.
	rst 38h			;6b25	ff		.
	rst 38h			;6b26	ff		.
	rst 38h			;6b27	ff		.
	rst 38h			;6b28	ff		.
	rst 38h			;6b29	ff		.
	rst 38h			;6b2a	ff		.
	rst 38h			;6b2b	ff		.
	rst 38h			;6b2c	ff		.
	rst 38h			;6b2d	ff		.
	rst 38h			;6b2e	ff		.
	rst 38h			;6b2f	ff		.
	rst 38h			;6b30	ff		.
	rst 38h			;6b31	ff		.
	rst 38h			;6b32	ff		.
	rst 38h			;6b33	ff		.
	rst 38h			;6b34	ff		.
	rst 38h			;6b35	ff		.
	rst 38h			;6b36	ff		.
	rst 38h			;6b37	ff		.
	rst 38h			;6b38	ff		.
	rst 38h			;6b39	ff		.
	rst 38h			;6b3a	ff		.
	rst 38h			;6b3b	ff		.
	rst 38h			;6b3c	ff		.
	rst 38h			;6b3d	ff		.
	rst 38h			;6b3e	ff		.
	rst 38h			;6b3f	ff		.
	rst 38h			;6b40	ff		.
	rst 38h			;6b41	ff		.
	rst 38h			;6b42	ff		.
	rst 38h			;6b43	ff		.
	rst 38h			;6b44	ff		.
	rst 38h			;6b45	ff		.
	rst 38h			;6b46	ff		.
	rst 38h			;6b47	ff		.
	rst 38h			;6b48	ff		.
	rst 38h			;6b49	ff		.
	rst 38h			;6b4a	ff		.
	rst 38h			;6b4b	ff		.
	rst 38h			;6b4c	ff		.
	rst 38h			;6b4d	ff		.
	rst 38h			;6b4e	ff		.
	rst 38h			;6b4f	ff		.
	rst 38h			;6b50	ff		.
	rst 38h			;6b51	ff		.
	rst 38h			;6b52	ff		.
	rst 38h			;6b53	ff		.
	rst 38h			;6b54	ff		.
	rst 38h			;6b55	ff		.
	rst 38h			;6b56	ff		.
	rst 38h			;6b57	ff		.
	rst 38h			;6b58	ff		.
	rst 38h			;6b59	ff		.
	rst 38h			;6b5a	ff		.
	rst 38h			;6b5b	ff		.
	rst 38h			;6b5c	ff		.
	rst 38h			;6b5d	ff		.
	rst 38h			;6b5e	ff		.
	rst 38h			;6b5f	ff		.
	rst 38h			;6b60	ff		.
	rst 38h			;6b61	ff		.
	rst 38h			;6b62	ff		.
	rst 38h			;6b63	ff		.
	rst 38h			;6b64	ff		.
	rst 38h			;6b65	ff		.
	rst 38h			;6b66	ff		.
	rst 38h			;6b67	ff		.
	rst 38h			;6b68	ff		.
	rst 38h			;6b69	ff		.
	rst 38h			;6b6a	ff		.
	rst 38h			;6b6b	ff		.
	rst 38h			;6b6c	ff		.
	rst 38h			;6b6d	ff		.
	rst 38h			;6b6e	ff		.
	rst 38h			;6b6f	ff		.
	rst 38h			;6b70	ff		.
	rst 38h			;6b71	ff		.
	rst 38h			;6b72	ff		.
	rst 38h			;6b73	ff		.
	rst 38h			;6b74	ff		.
	rst 38h			;6b75	ff		.
	rst 38h			;6b76	ff		.
	rst 38h			;6b77	ff		.
	rst 38h			;6b78	ff		.
	rst 38h			;6b79	ff		.
	rst 38h			;6b7a	ff		.
	rst 38h			;6b7b	ff		.
	rst 38h			;6b7c	ff		.
	rst 38h			;6b7d	ff		.
	rst 38h			;6b7e	ff		.
	rst 38h			;6b7f	ff		.
	rst 38h			;6b80	ff		.
	rst 38h			;6b81	ff		.
	rst 38h			;6b82	ff		.
	rst 38h			;6b83	ff		.
	rst 38h			;6b84	ff		.
	rst 38h			;6b85	ff		.
	rst 38h			;6b86	ff		.
	rst 38h			;6b87	ff		.
	rst 38h			;6b88	ff		.
	rst 38h			;6b89	ff		.
	rst 38h			;6b8a	ff		.
	rst 38h			;6b8b	ff		.
	rst 38h			;6b8c	ff		.
	rst 38h			;6b8d	ff		.
	rst 38h			;6b8e	ff		.
	rst 38h			;6b8f	ff		.
	rst 38h			;6b90	ff		.
	rst 38h			;6b91	ff		.
	rst 38h			;6b92	ff		.
	rst 38h			;6b93	ff		.
	rst 38h			;6b94	ff		.
	rst 38h			;6b95	ff		.
	rst 38h			;6b96	ff		.
	rst 38h			;6b97	ff		.
	rst 38h			;6b98	ff		.
	rst 38h			;6b99	ff		.
	rst 38h			;6b9a	ff		.
	rst 38h			;6b9b	ff		.
	rst 38h			;6b9c	ff		.
	rst 38h			;6b9d	ff		.
	rst 38h			;6b9e	ff		.
	rst 38h			;6b9f	ff		.
	rst 38h			;6ba0	ff		.
	rst 38h			;6ba1	ff		.
	rst 38h			;6ba2	ff		.
	rst 38h			;6ba3	ff		.
	rst 38h			;6ba4	ff		.
	rst 38h			;6ba5	ff		.
	rst 38h			;6ba6	ff		.
	rst 38h			;6ba7	ff		.
	rst 38h			;6ba8	ff		.
	rst 38h			;6ba9	ff		.
	rst 38h			;6baa	ff		.
	rst 38h			;6bab	ff		.
	rst 38h			;6bac	ff		.
	rst 38h			;6bad	ff		.
	rst 38h			;6bae	ff		.
	rst 38h			;6baf	ff		.
	rst 38h			;6bb0	ff		.
	rst 38h			;6bb1	ff		.
	rst 38h			;6bb2	ff		.
	rst 38h			;6bb3	ff		.
	rst 38h			;6bb4	ff		.
	rst 38h			;6bb5	ff		.
	rst 38h			;6bb6	ff		.
	rst 38h			;6bb7	ff		.
	rst 38h			;6bb8	ff		.
	rst 38h			;6bb9	ff		.
	rst 38h			;6bba	ff		.
	rst 38h			;6bbb	ff		.
	rst 38h			;6bbc	ff		.
	rst 38h			;6bbd	ff		.
	rst 38h			;6bbe	ff		.
	rst 38h			;6bbf	ff		.
	rst 38h			;6bc0	ff		.
	rst 38h			;6bc1	ff		.
	rst 38h			;6bc2	ff		.
	rst 38h			;6bc3	ff		.
	rst 38h			;6bc4	ff		.
	rst 38h			;6bc5	ff		.
	rst 38h			;6bc6	ff		.
	rst 38h			;6bc7	ff		.
	rst 38h			;6bc8	ff		.
	rst 38h			;6bc9	ff		.
	rst 38h			;6bca	ff		.
	rst 38h			;6bcb	ff		.
	rst 38h			;6bcc	ff		.
	rst 38h			;6bcd	ff		.
	rst 38h			;6bce	ff		.
	rst 38h			;6bcf	ff		.
	rst 38h			;6bd0	ff		.
	rst 38h			;6bd1	ff		.
	rst 38h			;6bd2	ff		.
	rst 38h			;6bd3	ff		.
	rst 38h			;6bd4	ff		.
	rst 38h			;6bd5	ff		.
	rst 38h			;6bd6	ff		.
	rst 38h			;6bd7	ff		.
	rst 38h			;6bd8	ff		.
	rst 38h			;6bd9	ff		.
	rst 38h			;6bda	ff		.
	rst 38h			;6bdb	ff		.
	rst 38h			;6bdc	ff		.
	rst 38h			;6bdd	ff		.
	rst 38h			;6bde	ff		.
	rst 38h			;6bdf	ff		.
	rst 38h			;6be0	ff		.
	rst 38h			;6be1	ff		.
	rst 38h			;6be2	ff		.
	rst 38h			;6be3	ff		.
	rst 38h			;6be4	ff		.
	rst 38h			;6be5	ff		.
	rst 38h			;6be6	ff		.
	rst 38h			;6be7	ff		.
	rst 38h			;6be8	ff		.
	rst 38h			;6be9	ff		.
	rst 38h			;6bea	ff		.
	rst 38h			;6beb	ff		.
	rst 38h			;6bec	ff		.
	rst 38h			;6bed	ff		.
	rst 38h			;6bee	ff		.
	rst 38h			;6bef	ff		.
	rst 38h			;6bf0	ff		.
	rst 38h			;6bf1	ff		.
	rst 38h			;6bf2	ff		.
	rst 38h			;6bf3	ff		.
	rst 38h			;6bf4	ff		.
	rst 38h			;6bf5	ff		.
	rst 38h			;6bf6	ff		.
	rst 38h			;6bf7	ff		.
	rst 38h			;6bf8	ff		.
	rst 38h			;6bf9	ff		.
	rst 38h			;6bfa	ff		.
	rst 38h			;6bfb	ff		.
	rst 38h			;6bfc	ff		.
	rst 38h			;6bfd	ff		.
	rst 38h			;6bfe	ff		.
	rst 38h			;6bff	ff		.
	rst 38h			;6c00	ff		.
	rst 38h			;6c01	ff		.
	rst 38h			;6c02	ff		.
	rst 38h			;6c03	ff		.
	rst 38h			;6c04	ff		.
	rst 38h			;6c05	ff		.
	rst 38h			;6c06	ff		.
	rst 38h			;6c07	ff		.
	rst 38h			;6c08	ff		.
	rst 38h			;6c09	ff		.
	rst 38h			;6c0a	ff		.
	rst 38h			;6c0b	ff		.
	rst 38h			;6c0c	ff		.
	rst 38h			;6c0d	ff		.
	rst 38h			;6c0e	ff		.
	rst 38h			;6c0f	ff		.
	rst 38h			;6c10	ff		.
	rst 38h			;6c11	ff		.
	rst 38h			;6c12	ff		.
	rst 38h			;6c13	ff		.
	rst 38h			;6c14	ff		.
	rst 38h			;6c15	ff		.
	rst 38h			;6c16	ff		.
	rst 38h			;6c17	ff		.
	rst 38h			;6c18	ff		.
	rst 38h			;6c19	ff		.
	rst 38h			;6c1a	ff		.
	rst 38h			;6c1b	ff		.
	rst 38h			;6c1c	ff		.
	rst 38h			;6c1d	ff		.
	rst 38h			;6c1e	ff		.
	rst 38h			;6c1f	ff		.
	rst 38h			;6c20	ff		.
	rst 38h			;6c21	ff		.
	rst 38h			;6c22	ff		.
	rst 38h			;6c23	ff		.
	rst 38h			;6c24	ff		.
	rst 38h			;6c25	ff		.
	rst 38h			;6c26	ff		.
	rst 38h			;6c27	ff		.
	rst 38h			;6c28	ff		.
	rst 38h			;6c29	ff		.
	rst 38h			;6c2a	ff		.
	rst 38h			;6c2b	ff		.
	rst 38h			;6c2c	ff		.
	rst 38h			;6c2d	ff		.
	rst 38h			;6c2e	ff		.
	rst 38h			;6c2f	ff		.
	rst 38h			;6c30	ff		.
	rst 38h			;6c31	ff		.
	rst 38h			;6c32	ff		.
	rst 38h			;6c33	ff		.
	rst 38h			;6c34	ff		.
	rst 38h			;6c35	ff		.
	rst 38h			;6c36	ff		.
	rst 38h			;6c37	ff		.
	rst 38h			;6c38	ff		.
	rst 38h			;6c39	ff		.
	rst 38h			;6c3a	ff		.
	rst 38h			;6c3b	ff		.
	rst 38h			;6c3c	ff		.
	rst 38h			;6c3d	ff		.
	rst 38h			;6c3e	ff		.
	rst 38h			;6c3f	ff		.
	rst 38h			;6c40	ff		.
	rst 38h			;6c41	ff		.
	rst 38h			;6c42	ff		.
	rst 38h			;6c43	ff		.
	rst 38h			;6c44	ff		.
	rst 38h			;6c45	ff		.
	rst 38h			;6c46	ff		.
	rst 38h			;6c47	ff		.
	rst 38h			;6c48	ff		.
	rst 38h			;6c49	ff		.
	rst 38h			;6c4a	ff		.
	rst 38h			;6c4b	ff		.
	rst 38h			;6c4c	ff		.
	rst 38h			;6c4d	ff		.
	rst 38h			;6c4e	ff		.
	rst 38h			;6c4f	ff		.
	rst 38h			;6c50	ff		.
	rst 38h			;6c51	ff		.
	rst 38h			;6c52	ff		.
	rst 38h			;6c53	ff		.
	rst 38h			;6c54	ff		.
	rst 38h			;6c55	ff		.
	rst 38h			;6c56	ff		.
	rst 38h			;6c57	ff		.
	rst 38h			;6c58	ff		.
	rst 38h			;6c59	ff		.
	rst 38h			;6c5a	ff		.
	rst 38h			;6c5b	ff		.
	rst 38h			;6c5c	ff		.
	rst 38h			;6c5d	ff		.
	rst 38h			;6c5e	ff		.
	rst 38h			;6c5f	ff		.
	rst 38h			;6c60	ff		.
	rst 38h			;6c61	ff		.
	rst 38h			;6c62	ff		.
	rst 38h			;6c63	ff		.
	rst 38h			;6c64	ff		.
	rst 38h			;6c65	ff		.
	rst 38h			;6c66	ff		.
	rst 38h			;6c67	ff		.
	rst 38h			;6c68	ff		.
	rst 38h			;6c69	ff		.
	rst 38h			;6c6a	ff		.
	rst 38h			;6c6b	ff		.
	rst 38h			;6c6c	ff		.
	rst 38h			;6c6d	ff		.
	rst 38h			;6c6e	ff		.
	rst 38h			;6c6f	ff		.
	rst 38h			;6c70	ff		.
	rst 38h			;6c71	ff		.
	rst 38h			;6c72	ff		.
	rst 38h			;6c73	ff		.
	rst 38h			;6c74	ff		.
	rst 38h			;6c75	ff		.
	rst 38h			;6c76	ff		.
	rst 38h			;6c77	ff		.
	rst 38h			;6c78	ff		.
	rst 38h			;6c79	ff		.
	rst 38h			;6c7a	ff		.
	rst 38h			;6c7b	ff		.
	rst 38h			;6c7c	ff		.
	rst 38h			;6c7d	ff		.
	rst 38h			;6c7e	ff		.
	rst 38h			;6c7f	ff		.
	rst 38h			;6c80	ff		.
	rst 38h			;6c81	ff		.
	rst 38h			;6c82	ff		.
	rst 38h			;6c83	ff		.
	rst 38h			;6c84	ff		.
	rst 38h			;6c85	ff		.
	rst 38h			;6c86	ff		.
	rst 38h			;6c87	ff		.
	rst 38h			;6c88	ff		.
	rst 38h			;6c89	ff		.
	rst 38h			;6c8a	ff		.
	rst 38h			;6c8b	ff		.
	rst 38h			;6c8c	ff		.
	rst 38h			;6c8d	ff		.
	rst 38h			;6c8e	ff		.
	rst 38h			;6c8f	ff		.
	rst 38h			;6c90	ff		.
	rst 38h			;6c91	ff		.
	rst 38h			;6c92	ff		.
	rst 38h			;6c93	ff		.
	rst 38h			;6c94	ff		.
	rst 38h			;6c95	ff		.
	rst 38h			;6c96	ff		.
	rst 38h			;6c97	ff		.
	rst 38h			;6c98	ff		.
	rst 38h			;6c99	ff		.
	rst 38h			;6c9a	ff		.
	rst 38h			;6c9b	ff		.
	rst 38h			;6c9c	ff		.
	rst 38h			;6c9d	ff		.
	rst 38h			;6c9e	ff		.
	rst 38h			;6c9f	ff		.
	rst 38h			;6ca0	ff		.
	rst 38h			;6ca1	ff		.
	rst 38h			;6ca2	ff		.
	rst 38h			;6ca3	ff		.
	rst 38h			;6ca4	ff		.
	rst 38h			;6ca5	ff		.
	rst 38h			;6ca6	ff		.
	rst 38h			;6ca7	ff		.
	rst 38h			;6ca8	ff		.
	rst 38h			;6ca9	ff		.
	rst 38h			;6caa	ff		.
	rst 38h			;6cab	ff		.
	rst 38h			;6cac	ff		.
	rst 38h			;6cad	ff		.
	rst 38h			;6cae	ff		.
	rst 38h			;6caf	ff		.
	rst 38h			;6cb0	ff		.
	rst 38h			;6cb1	ff		.
	rst 38h			;6cb2	ff		.
	rst 38h			;6cb3	ff		.
	rst 38h			;6cb4	ff		.
	rst 38h			;6cb5	ff		.
	rst 38h			;6cb6	ff		.
	rst 38h			;6cb7	ff		.
	rst 38h			;6cb8	ff		.
	rst 38h			;6cb9	ff		.
	rst 38h			;6cba	ff		.
	rst 38h			;6cbb	ff		.
	rst 38h			;6cbc	ff		.
	rst 38h			;6cbd	ff		.
	rst 38h			;6cbe	ff		.
	rst 38h			;6cbf	ff		.
	rst 38h			;6cc0	ff		.
	rst 38h			;6cc1	ff		.
	rst 38h			;6cc2	ff		.
	rst 38h			;6cc3	ff		.
	rst 38h			;6cc4	ff		.
	rst 38h			;6cc5	ff		.
	rst 38h			;6cc6	ff		.
	rst 38h			;6cc7	ff		.
	rst 38h			;6cc8	ff		.
	rst 38h			;6cc9	ff		.
	rst 38h			;6cca	ff		.
	rst 38h			;6ccb	ff		.
	rst 38h			;6ccc	ff		.
	rst 38h			;6ccd	ff		.
	rst 38h			;6cce	ff		.
	rst 38h			;6ccf	ff		.
	rst 38h			;6cd0	ff		.
	rst 38h			;6cd1	ff		.
	rst 38h			;6cd2	ff		.
	rst 38h			;6cd3	ff		.
	rst 38h			;6cd4	ff		.
	rst 38h			;6cd5	ff		.
	rst 38h			;6cd6	ff		.
	rst 38h			;6cd7	ff		.
	rst 38h			;6cd8	ff		.
	rst 38h			;6cd9	ff		.
	rst 38h			;6cda	ff		.
	rst 38h			;6cdb	ff		.
	rst 38h			;6cdc	ff		.
	rst 38h			;6cdd	ff		.
	rst 38h			;6cde	ff		.
	rst 38h			;6cdf	ff		.
	rst 38h			;6ce0	ff		.
	rst 38h			;6ce1	ff		.
	rst 38h			;6ce2	ff		.
	rst 38h			;6ce3	ff		.
l6ce4h:
	rst 38h			;6ce4	ff		.
	rst 38h			;6ce5	ff		.
	rst 38h			;6ce6	ff		.
	rst 38h			;6ce7	ff		.
	rst 38h			;6ce8	ff		.
	rst 38h			;6ce9	ff		.
	rst 38h			;6cea	ff		.
	rst 38h			;6ceb	ff		.
	rst 38h			;6cec	ff		.
	rst 38h			;6ced	ff		.
	rst 38h			;6cee	ff		.
	rst 38h			;6cef	ff		.
	rst 38h			;6cf0	ff		.
	rst 38h			;6cf1	ff		.
	rst 38h			;6cf2	ff		.
	rst 38h			;6cf3	ff		.
	rst 38h			;6cf4	ff		.
	rst 38h			;6cf5	ff		.
	rst 38h			;6cf6	ff		.
	rst 38h			;6cf7	ff		.
	rst 38h			;6cf8	ff		.
	rst 38h			;6cf9	ff		.
	rst 38h			;6cfa	ff		.
	rst 38h			;6cfb	ff		.
	rst 38h			;6cfc	ff		.
	rst 38h			;6cfd	ff		.
	rst 38h			;6cfe	ff		.
	rst 38h			;6cff	ff		.
	rst 38h			;6d00	ff		.
	rst 38h			;6d01	ff		.
	rst 38h			;6d02	ff		.
	rst 38h			;6d03	ff		.
	rst 38h			;6d04	ff		.
	rst 38h			;6d05	ff		.
	rst 38h			;6d06	ff		.
	rst 38h			;6d07	ff		.
	rst 38h			;6d08	ff		.
	rst 38h			;6d09	ff		.
	rst 38h			;6d0a	ff		.
	rst 38h			;6d0b	ff		.
	rst 38h			;6d0c	ff		.
	rst 38h			;6d0d	ff		.
	rst 38h			;6d0e	ff		.
	rst 38h			;6d0f	ff		.
	rst 38h			;6d10	ff		.
	rst 38h			;6d11	ff		.
	rst 38h			;6d12	ff		.
	rst 38h			;6d13	ff		.
	rst 38h			;6d14	ff		.
	rst 38h			;6d15	ff		.
	rst 38h			;6d16	ff		.
	rst 38h			;6d17	ff		.
	rst 38h			;6d18	ff		.
	rst 38h			;6d19	ff		.
	rst 38h			;6d1a	ff		.
	rst 38h			;6d1b	ff		.
	rst 38h			;6d1c	ff		.
	rst 38h			;6d1d	ff		.
	rst 38h			;6d1e	ff		.
	rst 38h			;6d1f	ff		.
	rst 38h			;6d20	ff		.
	rst 38h			;6d21	ff		.
	rst 38h			;6d22	ff		.
	rst 38h			;6d23	ff		.
	rst 38h			;6d24	ff		.
	rst 38h			;6d25	ff		.
	rst 38h			;6d26	ff		.
	rst 38h			;6d27	ff		.
	rst 38h			;6d28	ff		.
	rst 38h			;6d29	ff		.
	rst 38h			;6d2a	ff		.
	rst 38h			;6d2b	ff		.
	rst 38h			;6d2c	ff		.
	rst 38h			;6d2d	ff		.
	rst 38h			;6d2e	ff		.
	rst 38h			;6d2f	ff		.
	rst 38h			;6d30	ff		.
	rst 38h			;6d31	ff		.
	rst 38h			;6d32	ff		.
	rst 38h			;6d33	ff		.
	rst 38h			;6d34	ff		.
	rst 38h			;6d35	ff		.
	rst 38h			;6d36	ff		.
	rst 38h			;6d37	ff		.
	rst 38h			;6d38	ff		.
	rst 38h			;6d39	ff		.
	rst 38h			;6d3a	ff		.
	rst 38h			;6d3b	ff		.
	rst 38h			;6d3c	ff		.
	rst 38h			;6d3d	ff		.
	rst 38h			;6d3e	ff		.
	rst 38h			;6d3f	ff		.
	rst 38h			;6d40	ff		.
	rst 38h			;6d41	ff		.
	rst 38h			;6d42	ff		.
	rst 38h			;6d43	ff		.
	rst 38h			;6d44	ff		.
	rst 38h			;6d45	ff		.
	rst 38h			;6d46	ff		.
	rst 38h			;6d47	ff		.
	rst 38h			;6d48	ff		.
	rst 38h			;6d49	ff		.
	rst 38h			;6d4a	ff		.
	rst 38h			;6d4b	ff		.
	rst 38h			;6d4c	ff		.
	rst 38h			;6d4d	ff		.
	rst 38h			;6d4e	ff		.
	rst 38h			;6d4f	ff		.
	rst 38h			;6d50	ff		.
	rst 38h			;6d51	ff		.
	rst 38h			;6d52	ff		.
	rst 38h			;6d53	ff		.
	rst 38h			;6d54	ff		.
	rst 38h			;6d55	ff		.
	rst 38h			;6d56	ff		.
	rst 38h			;6d57	ff		.
	rst 38h			;6d58	ff		.
	rst 38h			;6d59	ff		.
	rst 38h			;6d5a	ff		.
	rst 38h			;6d5b	ff		.
	rst 38h			;6d5c	ff		.
	rst 38h			;6d5d	ff		.
	rst 38h			;6d5e	ff		.
	rst 38h			;6d5f	ff		.
	rst 38h			;6d60	ff		.
	rst 38h			;6d61	ff		.
	rst 38h			;6d62	ff		.
	rst 38h			;6d63	ff		.
	rst 38h			;6d64	ff		.
	rst 38h			;6d65	ff		.
	rst 38h			;6d66	ff		.
	rst 38h			;6d67	ff		.
	rst 38h			;6d68	ff		.
	rst 38h			;6d69	ff		.
	rst 38h			;6d6a	ff		.
	rst 38h			;6d6b	ff		.
	rst 38h			;6d6c	ff		.
sub_6d6dh:
	rst 38h			;6d6d	ff		.
	rst 38h			;6d6e	ff		.
	rst 38h			;6d6f	ff		.
	rst 38h			;6d70	ff		.
	rst 38h			;6d71	ff		.
	rst 38h			;6d72	ff		.
	rst 38h			;6d73	ff		.
	rst 38h			;6d74	ff		.
	rst 38h			;6d75	ff		.
	rst 38h			;6d76	ff		.
	rst 38h			;6d77	ff		.
	rst 38h			;6d78	ff		.
	rst 38h			;6d79	ff		.
	rst 38h			;6d7a	ff		.
	rst 38h			;6d7b	ff		.
	rst 38h			;6d7c	ff		.
	rst 38h			;6d7d	ff		.
	rst 38h			;6d7e	ff		.
	rst 38h			;6d7f	ff		.
	rst 38h			;6d80	ff		.
	rst 38h			;6d81	ff		.
	rst 38h			;6d82	ff		.
	rst 38h			;6d83	ff		.
	rst 38h			;6d84	ff		.
	rst 38h			;6d85	ff		.
	rst 38h			;6d86	ff		.
	rst 38h			;6d87	ff		.
	rst 38h			;6d88	ff		.
	rst 38h			;6d89	ff		.
	rst 38h			;6d8a	ff		.
	rst 38h			;6d8b	ff		.
	rst 38h			;6d8c	ff		.
	rst 38h			;6d8d	ff		.
	rst 38h			;6d8e	ff		.
	rst 38h			;6d8f	ff		.
	rst 38h			;6d90	ff		.
	rst 38h			;6d91	ff		.
	rst 38h			;6d92	ff		.
	rst 38h			;6d93	ff		.
	rst 38h			;6d94	ff		.
	rst 38h			;6d95	ff		.
	rst 38h			;6d96	ff		.
	rst 38h			;6d97	ff		.
	rst 38h			;6d98	ff		.
	rst 38h			;6d99	ff		.
	rst 38h			;6d9a	ff		.
	rst 38h			;6d9b	ff		.
	rst 38h			;6d9c	ff		.
	rst 38h			;6d9d	ff		.
	rst 38h			;6d9e	ff		.
	rst 38h			;6d9f	ff		.
	rst 38h			;6da0	ff		.
	rst 38h			;6da1	ff		.
	rst 38h			;6da2	ff		.
	rst 38h			;6da3	ff		.
	rst 38h			;6da4	ff		.
	rst 38h			;6da5	ff		.
	rst 38h			;6da6	ff		.
	rst 38h			;6da7	ff		.
	rst 38h			;6da8	ff		.
	rst 38h			;6da9	ff		.
	rst 38h			;6daa	ff		.
	rst 38h			;6dab	ff		.
	rst 38h			;6dac	ff		.
	rst 38h			;6dad	ff		.
	rst 38h			;6dae	ff		.
	rst 38h			;6daf	ff		.
	rst 38h			;6db0	ff		.
	rst 38h			;6db1	ff		.
	rst 38h			;6db2	ff		.
	rst 38h			;6db3	ff		.
	rst 38h			;6db4	ff		.
	rst 38h			;6db5	ff		.
	rst 38h			;6db6	ff		.
	rst 38h			;6db7	ff		.
	rst 38h			;6db8	ff		.
	rst 38h			;6db9	ff		.
	rst 38h			;6dba	ff		.
	rst 38h			;6dbb	ff		.
	rst 38h			;6dbc	ff		.
	rst 38h			;6dbd	ff		.
	rst 38h			;6dbe	ff		.
	rst 38h			;6dbf	ff		.
	rst 38h			;6dc0	ff		.
	rst 38h			;6dc1	ff		.
	rst 38h			;6dc2	ff		.
	rst 38h			;6dc3	ff		.
	rst 38h			;6dc4	ff		.
	rst 38h			;6dc5	ff		.
	rst 38h			;6dc6	ff		.
	rst 38h			;6dc7	ff		.
	rst 38h			;6dc8	ff		.
	rst 38h			;6dc9	ff		.
	rst 38h			;6dca	ff		.
	rst 38h			;6dcb	ff		.
	rst 38h			;6dcc	ff		.
	rst 38h			;6dcd	ff		.
	rst 38h			;6dce	ff		.
	rst 38h			;6dcf	ff		.
	rst 38h			;6dd0	ff		.
	rst 38h			;6dd1	ff		.
	rst 38h			;6dd2	ff		.
	rst 38h			;6dd3	ff		.
	rst 38h			;6dd4	ff		.
	rst 38h			;6dd5	ff		.
	rst 38h			;6dd6	ff		.
	rst 38h			;6dd7	ff		.
	rst 38h			;6dd8	ff		.
	rst 38h			;6dd9	ff		.
	rst 38h			;6dda	ff		.
	rst 38h			;6ddb	ff		.
	rst 38h			;6ddc	ff		.
	rst 38h			;6ddd	ff		.
	rst 38h			;6dde	ff		.
	rst 38h			;6ddf	ff		.
	rst 38h			;6de0	ff		.
	rst 38h			;6de1	ff		.
	rst 38h			;6de2	ff		.
	rst 38h			;6de3	ff		.
	rst 38h			;6de4	ff		.
	rst 38h			;6de5	ff		.
	rst 38h			;6de6	ff		.
	rst 38h			;6de7	ff		.
	rst 38h			;6de8	ff		.
	rst 38h			;6de9	ff		.
	rst 38h			;6dea	ff		.
	rst 38h			;6deb	ff		.
	rst 38h			;6dec	ff		.
	rst 38h			;6ded	ff		.
	rst 38h			;6dee	ff		.
	rst 38h			;6def	ff		.
	rst 38h			;6df0	ff		.
	rst 38h			;6df1	ff		.
	rst 38h			;6df2	ff		.
	rst 38h			;6df3	ff		.
	rst 38h			;6df4	ff		.
	rst 38h			;6df5	ff		.
	rst 38h			;6df6	ff		.
	rst 38h			;6df7	ff		.
	rst 38h			;6df8	ff		.
	rst 38h			;6df9	ff		.
	rst 38h			;6dfa	ff		.
	rst 38h			;6dfb	ff		.
	rst 38h			;6dfc	ff		.
	rst 38h			;6dfd	ff		.
	rst 38h			;6dfe	ff		.
	rst 38h			;6dff	ff		.
	rst 38h			;6e00	ff		.
	rst 38h			;6e01	ff		.
	rst 38h			;6e02	ff		.
	rst 38h			;6e03	ff		.
	rst 38h			;6e04	ff		.
	rst 38h			;6e05	ff		.
	rst 38h			;6e06	ff		.
	rst 38h			;6e07	ff		.
	rst 38h			;6e08	ff		.
	rst 38h			;6e09	ff		.
	rst 38h			;6e0a	ff		.
	rst 38h			;6e0b	ff		.
	rst 38h			;6e0c	ff		.
	rst 38h			;6e0d	ff		.
	rst 38h			;6e0e	ff		.
	rst 38h			;6e0f	ff		.
	rst 38h			;6e10	ff		.
	rst 38h			;6e11	ff		.
	rst 38h			;6e12	ff		.
	rst 38h			;6e13	ff		.
	rst 38h			;6e14	ff		.
	rst 38h			;6e15	ff		.
	rst 38h			;6e16	ff		.
	rst 38h			;6e17	ff		.
	rst 38h			;6e18	ff		.
	rst 38h			;6e19	ff		.
	rst 38h			;6e1a	ff		.
	rst 38h			;6e1b	ff		.
	rst 38h			;6e1c	ff		.
	rst 38h			;6e1d	ff		.
	rst 38h			;6e1e	ff		.
	rst 38h			;6e1f	ff		.
	rst 38h			;6e20	ff		.
	rst 38h			;6e21	ff		.
	rst 38h			;6e22	ff		.
	rst 38h			;6e23	ff		.
	rst 38h			;6e24	ff		.
	rst 38h			;6e25	ff		.
	rst 38h			;6e26	ff		.
	rst 38h			;6e27	ff		.
	rst 38h			;6e28	ff		.
	rst 38h			;6e29	ff		.
	rst 38h			;6e2a	ff		.
	rst 38h			;6e2b	ff		.
	rst 38h			;6e2c	ff		.
	rst 38h			;6e2d	ff		.
	rst 38h			;6e2e	ff		.
	rst 38h			;6e2f	ff		.
	rst 38h			;6e30	ff		.
	rst 38h			;6e31	ff		.
	rst 38h			;6e32	ff		.
	rst 38h			;6e33	ff		.
	rst 38h			;6e34	ff		.
	rst 38h			;6e35	ff		.
	rst 38h			;6e36	ff		.
	rst 38h			;6e37	ff		.
	rst 38h			;6e38	ff		.
	rst 38h			;6e39	ff		.
	rst 38h			;6e3a	ff		.
	rst 38h			;6e3b	ff		.
	rst 38h			;6e3c	ff		.
	rst 38h			;6e3d	ff		.
	rst 38h			;6e3e	ff		.
	rst 38h			;6e3f	ff		.
	rst 38h			;6e40	ff		.
	rst 38h			;6e41	ff		.
	rst 38h			;6e42	ff		.
	rst 38h			;6e43	ff		.
	rst 38h			;6e44	ff		.
	rst 38h			;6e45	ff		.
	rst 38h			;6e46	ff		.
	rst 38h			;6e47	ff		.
	rst 38h			;6e48	ff		.
	rst 38h			;6e49	ff		.
	rst 38h			;6e4a	ff		.
	rst 38h			;6e4b	ff		.
	rst 38h			;6e4c	ff		.
	rst 38h			;6e4d	ff		.
	rst 38h			;6e4e	ff		.
	rst 38h			;6e4f	ff		.
	rst 38h			;6e50	ff		.
	rst 38h			;6e51	ff		.
	rst 38h			;6e52	ff		.
	rst 38h			;6e53	ff		.
	rst 38h			;6e54	ff		.
	rst 38h			;6e55	ff		.
	rst 38h			;6e56	ff		.
	rst 38h			;6e57	ff		.
	rst 38h			;6e58	ff		.
	rst 38h			;6e59	ff		.
	rst 38h			;6e5a	ff		.
	rst 38h			;6e5b	ff		.
	rst 38h			;6e5c	ff		.
	rst 38h			;6e5d	ff		.
	rst 38h			;6e5e	ff		.
	rst 38h			;6e5f	ff		.
	rst 38h			;6e60	ff		.
	rst 38h			;6e61	ff		.
	rst 38h			;6e62	ff		.
	rst 38h			;6e63	ff		.
	rst 38h			;6e64	ff		.
	rst 38h			;6e65	ff		.
	rst 38h			;6e66	ff		.
	rst 38h			;6e67	ff		.
	rst 38h			;6e68	ff		.
	rst 38h			;6e69	ff		.
	rst 38h			;6e6a	ff		.
	rst 38h			;6e6b	ff		.
	rst 38h			;6e6c	ff		.
	rst 38h			;6e6d	ff		.
	rst 38h			;6e6e	ff		.
	rst 38h			;6e6f	ff		.
	rst 38h			;6e70	ff		.
	rst 38h			;6e71	ff		.
	rst 38h			;6e72	ff		.
	rst 38h			;6e73	ff		.
	rst 38h			;6e74	ff		.
	rst 38h			;6e75	ff		.
	rst 38h			;6e76	ff		.
	rst 38h			;6e77	ff		.
	rst 38h			;6e78	ff		.
	rst 38h			;6e79	ff		.
	rst 38h			;6e7a	ff		.
	rst 38h			;6e7b	ff		.
	rst 38h			;6e7c	ff		.
	rst 38h			;6e7d	ff		.
	rst 38h			;6e7e	ff		.
	rst 38h			;6e7f	ff		.
	rst 38h			;6e80	ff		.
	rst 38h			;6e81	ff		.
	rst 38h			;6e82	ff		.
	rst 38h			;6e83	ff		.
	rst 38h			;6e84	ff		.
	rst 38h			;6e85	ff		.
	rst 38h			;6e86	ff		.
	rst 38h			;6e87	ff		.
	rst 38h			;6e88	ff		.
	rst 38h			;6e89	ff		.
	rst 38h			;6e8a	ff		.
	rst 38h			;6e8b	ff		.
	rst 38h			;6e8c	ff		.
	rst 38h			;6e8d	ff		.
	rst 38h			;6e8e	ff		.
	rst 38h			;6e8f	ff		.
	rst 38h			;6e90	ff		.
	rst 38h			;6e91	ff		.
	rst 38h			;6e92	ff		.
	rst 38h			;6e93	ff		.
	rst 38h			;6e94	ff		.
	rst 38h			;6e95	ff		.
	rst 38h			;6e96	ff		.
	rst 38h			;6e97	ff		.
	rst 38h			;6e98	ff		.
	rst 38h			;6e99	ff		.
	rst 38h			;6e9a	ff		.
	rst 38h			;6e9b	ff		.
	rst 38h			;6e9c	ff		.
	rst 38h			;6e9d	ff		.
	rst 38h			;6e9e	ff		.
	rst 38h			;6e9f	ff		.
	rst 38h			;6ea0	ff		.
	rst 38h			;6ea1	ff		.
	rst 38h			;6ea2	ff		.
	rst 38h			;6ea3	ff		.
	rst 38h			;6ea4	ff		.
	rst 38h			;6ea5	ff		.
	rst 38h			;6ea6	ff		.
	rst 38h			;6ea7	ff		.
	rst 38h			;6ea8	ff		.
	rst 38h			;6ea9	ff		.
	rst 38h			;6eaa	ff		.
	rst 38h			;6eab	ff		.
	rst 38h			;6eac	ff		.
	rst 38h			;6ead	ff		.
	rst 38h			;6eae	ff		.
	rst 38h			;6eaf	ff		.
	rst 38h			;6eb0	ff		.
	rst 38h			;6eb1	ff		.
	rst 38h			;6eb2	ff		.
	rst 38h			;6eb3	ff		.
	rst 38h			;6eb4	ff		.
	rst 38h			;6eb5	ff		.
	rst 38h			;6eb6	ff		.
	rst 38h			;6eb7	ff		.
	rst 38h			;6eb8	ff		.
	rst 38h			;6eb9	ff		.
	rst 38h			;6eba	ff		.
	rst 38h			;6ebb	ff		.
	rst 38h			;6ebc	ff		.
	rst 38h			;6ebd	ff		.
	rst 38h			;6ebe	ff		.
	rst 38h			;6ebf	ff		.
	rst 38h			;6ec0	ff		.
	rst 38h			;6ec1	ff		.
	rst 38h			;6ec2	ff		.
	rst 38h			;6ec3	ff		.
	rst 38h			;6ec4	ff		.
	rst 38h			;6ec5	ff		.
	rst 38h			;6ec6	ff		.
	rst 38h			;6ec7	ff		.
	rst 38h			;6ec8	ff		.
	rst 38h			;6ec9	ff		.
	rst 38h			;6eca	ff		.
	rst 38h			;6ecb	ff		.
	rst 38h			;6ecc	ff		.
	rst 38h			;6ecd	ff		.
	rst 38h			;6ece	ff		.
	rst 38h			;6ecf	ff		.
	rst 38h			;6ed0	ff		.
	rst 38h			;6ed1	ff		.
	rst 38h			;6ed2	ff		.
	rst 38h			;6ed3	ff		.
	rst 38h			;6ed4	ff		.
	rst 38h			;6ed5	ff		.
	rst 38h			;6ed6	ff		.
	rst 38h			;6ed7	ff		.
	rst 38h			;6ed8	ff		.
	rst 38h			;6ed9	ff		.
	rst 38h			;6eda	ff		.
	rst 38h			;6edb	ff		.
	rst 38h			;6edc	ff		.
	rst 38h			;6edd	ff		.
	rst 38h			;6ede	ff		.
	rst 38h			;6edf	ff		.
	rst 38h			;6ee0	ff		.
	rst 38h			;6ee1	ff		.
	rst 38h			;6ee2	ff		.
	rst 38h			;6ee3	ff		.
	rst 38h			;6ee4	ff		.
	rst 38h			;6ee5	ff		.
	rst 38h			;6ee6	ff		.
	rst 38h			;6ee7	ff		.
	rst 38h			;6ee8	ff		.
	rst 38h			;6ee9	ff		.
	rst 38h			;6eea	ff		.
	rst 38h			;6eeb	ff		.
	rst 38h			;6eec	ff		.
	rst 38h			;6eed	ff		.
	rst 38h			;6eee	ff		.
	rst 38h			;6eef	ff		.
	rst 38h			;6ef0	ff		.
	rst 38h			;6ef1	ff		.
	rst 38h			;6ef2	ff		.
	rst 38h			;6ef3	ff		.
	rst 38h			;6ef4	ff		.
	rst 38h			;6ef5	ff		.
	rst 38h			;6ef6	ff		.
	rst 38h			;6ef7	ff		.
	rst 38h			;6ef8	ff		.
	rst 38h			;6ef9	ff		.
	rst 38h			;6efa	ff		.
	rst 38h			;6efb	ff		.
	rst 38h			;6efc	ff		.
	rst 38h			;6efd	ff		.
	rst 38h			;6efe	ff		.
	rst 38h			;6eff	ff		.
	rst 38h			;6f00	ff		.
	rst 38h			;6f01	ff		.
	rst 38h			;6f02	ff		.
	rst 38h			;6f03	ff		.
	rst 38h			;6f04	ff		.
	rst 38h			;6f05	ff		.
	rst 38h			;6f06	ff		.
	rst 38h			;6f07	ff		.
	rst 38h			;6f08	ff		.
	rst 38h			;6f09	ff		.
	rst 38h			;6f0a	ff		.
	rst 38h			;6f0b	ff		.
	rst 38h			;6f0c	ff		.
	rst 38h			;6f0d	ff		.
	rst 38h			;6f0e	ff		.
	rst 38h			;6f0f	ff		.
	rst 38h			;6f10	ff		.
	rst 38h			;6f11	ff		.
	rst 38h			;6f12	ff		.
	rst 38h			;6f13	ff		.
	rst 38h			;6f14	ff		.
	rst 38h			;6f15	ff		.
	rst 38h			;6f16	ff		.
	rst 38h			;6f17	ff		.
	rst 38h			;6f18	ff		.
	rst 38h			;6f19	ff		.
	rst 38h			;6f1a	ff		.
	rst 38h			;6f1b	ff		.
	rst 38h			;6f1c	ff		.
	rst 38h			;6f1d	ff		.
	rst 38h			;6f1e	ff		.
	rst 38h			;6f1f	ff		.
	rst 38h			;6f20	ff		.
	rst 38h			;6f21	ff		.
	rst 38h			;6f22	ff		.
	rst 38h			;6f23	ff		.
	rst 38h			;6f24	ff		.
	rst 38h			;6f25	ff		.
	rst 38h			;6f26	ff		.
	rst 38h			;6f27	ff		.
	rst 38h			;6f28	ff		.
	rst 38h			;6f29	ff		.
	rst 38h			;6f2a	ff		.
	rst 38h			;6f2b	ff		.
	rst 38h			;6f2c	ff		.
	rst 38h			;6f2d	ff		.
	rst 38h			;6f2e	ff		.
	rst 38h			;6f2f	ff		.
	rst 38h			;6f30	ff		.
	rst 38h			;6f31	ff		.
	rst 38h			;6f32	ff		.
	rst 38h			;6f33	ff		.
	rst 38h			;6f34	ff		.
	rst 38h			;6f35	ff		.
	rst 38h			;6f36	ff		.
	rst 38h			;6f37	ff		.
	rst 38h			;6f38	ff		.
	rst 38h			;6f39	ff		.
	rst 38h			;6f3a	ff		.
	rst 38h			;6f3b	ff		.
	rst 38h			;6f3c	ff		.
	rst 38h			;6f3d	ff		.
	rst 38h			;6f3e	ff		.
	rst 38h			;6f3f	ff		.
	rst 38h			;6f40	ff		.
	rst 38h			;6f41	ff		.
	rst 38h			;6f42	ff		.
	rst 38h			;6f43	ff		.
	rst 38h			;6f44	ff		.
	rst 38h			;6f45	ff		.
	rst 38h			;6f46	ff		.
	rst 38h			;6f47	ff		.
	rst 38h			;6f48	ff		.
	rst 38h			;6f49	ff		.
	rst 38h			;6f4a	ff		.
	rst 38h			;6f4b	ff		.
	rst 38h			;6f4c	ff		.
	rst 38h			;6f4d	ff		.
	rst 38h			;6f4e	ff		.
	rst 38h			;6f4f	ff		.
	rst 38h			;6f50	ff		.
	rst 38h			;6f51	ff		.
	rst 38h			;6f52	ff		.
	rst 38h			;6f53	ff		.
	rst 38h			;6f54	ff		.
	rst 38h			;6f55	ff		.
	rst 38h			;6f56	ff		.
	rst 38h			;6f57	ff		.
	rst 38h			;6f58	ff		.
	rst 38h			;6f59	ff		.
	rst 38h			;6f5a	ff		.
	rst 38h			;6f5b	ff		.
	rst 38h			;6f5c	ff		.
	rst 38h			;6f5d	ff		.
	rst 38h			;6f5e	ff		.
	rst 38h			;6f5f	ff		.
	rst 38h			;6f60	ff		.
	rst 38h			;6f61	ff		.
	rst 38h			;6f62	ff		.
	rst 38h			;6f63	ff		.
	rst 38h			;6f64	ff		.
	rst 38h			;6f65	ff		.
	rst 38h			;6f66	ff		.
	rst 38h			;6f67	ff		.
	rst 38h			;6f68	ff		.
	rst 38h			;6f69	ff		.
	rst 38h			;6f6a	ff		.
	rst 38h			;6f6b	ff		.
	rst 38h			;6f6c	ff		.
	rst 38h			;6f6d	ff		.
	rst 38h			;6f6e	ff		.
	rst 38h			;6f6f	ff		.
	rst 38h			;6f70	ff		.
	rst 38h			;6f71	ff		.
	rst 38h			;6f72	ff		.
	rst 38h			;6f73	ff		.
	rst 38h			;6f74	ff		.
	rst 38h			;6f75	ff		.
	rst 38h			;6f76	ff		.
	rst 38h			;6f77	ff		.
	rst 38h			;6f78	ff		.
	rst 38h			;6f79	ff		.
	rst 38h			;6f7a	ff		.
	rst 38h			;6f7b	ff		.
	rst 38h			;6f7c	ff		.
	rst 38h			;6f7d	ff		.
	rst 38h			;6f7e	ff		.
	rst 38h			;6f7f	ff		.
	rst 38h			;6f80	ff		.
	rst 38h			;6f81	ff		.
	rst 38h			;6f82	ff		.
	rst 38h			;6f83	ff		.
	rst 38h			;6f84	ff		.
	rst 38h			;6f85	ff		.
	rst 38h			;6f86	ff		.
	rst 38h			;6f87	ff		.
	rst 38h			;6f88	ff		.
	rst 38h			;6f89	ff		.
	rst 38h			;6f8a	ff		.
	rst 38h			;6f8b	ff		.
	rst 38h			;6f8c	ff		.
	rst 38h			;6f8d	ff		.
	rst 38h			;6f8e	ff		.
	rst 38h			;6f8f	ff		.
	rst 38h			;6f90	ff		.
	rst 38h			;6f91	ff		.
	rst 38h			;6f92	ff		.
	rst 38h			;6f93	ff		.
	rst 38h			;6f94	ff		.
	rst 38h			;6f95	ff		.
	rst 38h			;6f96	ff		.
	rst 38h			;6f97	ff		.
	rst 38h			;6f98	ff		.
	rst 38h			;6f99	ff		.
	rst 38h			;6f9a	ff		.
	rst 38h			;6f9b	ff		.
	rst 38h			;6f9c	ff		.
	rst 38h			;6f9d	ff		.
	rst 38h			;6f9e	ff		.
	rst 38h			;6f9f	ff		.
	rst 38h			;6fa0	ff		.
	rst 38h			;6fa1	ff		.
	rst 38h			;6fa2	ff		.
	rst 38h			;6fa3	ff		.
	rst 38h			;6fa4	ff		.
	rst 38h			;6fa5	ff		.
	rst 38h			;6fa6	ff		.
	rst 38h			;6fa7	ff		.
	rst 38h			;6fa8	ff		.
	rst 38h			;6fa9	ff		.
	rst 38h			;6faa	ff		.
	rst 38h			;6fab	ff		.
	rst 38h			;6fac	ff		.
	rst 38h			;6fad	ff		.
	rst 38h			;6fae	ff		.
	rst 38h			;6faf	ff		.
	rst 38h			;6fb0	ff		.
	rst 38h			;6fb1	ff		.
	rst 38h			;6fb2	ff		.
	rst 38h			;6fb3	ff		.
	rst 38h			;6fb4	ff		.
	rst 38h			;6fb5	ff		.
	rst 38h			;6fb6	ff		.
	rst 38h			;6fb7	ff		.
	rst 38h			;6fb8	ff		.
	rst 38h			;6fb9	ff		.
	rst 38h			;6fba	ff		.
	rst 38h			;6fbb	ff		.
	rst 38h			;6fbc	ff		.
	rst 38h			;6fbd	ff		.
	rst 38h			;6fbe	ff		.
	rst 38h			;6fbf	ff		.
	rst 38h			;6fc0	ff		.
	rst 38h			;6fc1	ff		.
	rst 38h			;6fc2	ff		.
	rst 38h			;6fc3	ff		.
	rst 38h			;6fc4	ff		.
	rst 38h			;6fc5	ff		.
	rst 38h			;6fc6	ff		.
	rst 38h			;6fc7	ff		.
	rst 38h			;6fc8	ff		.
	rst 38h			;6fc9	ff		.
	rst 38h			;6fca	ff		.
	rst 38h			;6fcb	ff		.
	rst 38h			;6fcc	ff		.
	rst 38h			;6fcd	ff		.
	rst 38h			;6fce	ff		.
	rst 38h			;6fcf	ff		.
	rst 38h			;6fd0	ff		.
	rst 38h			;6fd1	ff		.
	rst 38h			;6fd2	ff		.
	rst 38h			;6fd3	ff		.
	rst 38h			;6fd4	ff		.
	rst 38h			;6fd5	ff		.
	rst 38h			;6fd6	ff		.
	rst 38h			;6fd7	ff		.
	rst 38h			;6fd8	ff		.
	rst 38h			;6fd9	ff		.
	rst 38h			;6fda	ff		.
	rst 38h			;6fdb	ff		.
	rst 38h			;6fdc	ff		.
	rst 38h			;6fdd	ff		.
	rst 38h			;6fde	ff		.
	rst 38h			;6fdf	ff		.
	rst 38h			;6fe0	ff		.
	rst 38h			;6fe1	ff		.
	rst 38h			;6fe2	ff		.
	rst 38h			;6fe3	ff		.
	rst 38h			;6fe4	ff		.
	rst 38h			;6fe5	ff		.
	rst 38h			;6fe6	ff		.
	rst 38h			;6fe7	ff		.
	rst 38h			;6fe8	ff		.
	rst 38h			;6fe9	ff		.
	rst 38h			;6fea	ff		.
	rst 38h			;6feb	ff		.
	rst 38h			;6fec	ff		.
	rst 38h			;6fed	ff		.
	rst 38h			;6fee	ff		.
	rst 38h			;6fef	ff		.
	rst 38h			;6ff0	ff		.
	rst 38h			;6ff1	ff		.
	rst 38h			;6ff2	ff		.
	rst 38h			;6ff3	ff		.
	rst 38h			;6ff4	ff		.
	rst 38h			;6ff5	ff		.
	rst 38h			;6ff6	ff		.
	rst 38h			;6ff7	ff		.
	rst 38h			;6ff8	ff		.
	rst 38h			;6ff9	ff		.
	rst 38h			;6ffa	ff		.
	rst 38h			;6ffb	ff		.
	rst 38h			;6ffc	ff		.
	rst 38h			;6ffd	ff		.
	rst 38h			;6ffe	ff		.
	rst 38h			;6fff	ff		.
	rst 38h			;7000	ff		.
	rst 38h			;7001	ff		.
	rst 38h			;7002	ff		.
	rst 38h			;7003	ff		.
	rst 38h			;7004	ff		.
	rst 38h			;7005	ff		.
	rst 38h			;7006	ff		.
	rst 38h			;7007	ff		.
	rst 38h			;7008	ff		.
	rst 38h			;7009	ff		.
	rst 38h			;700a	ff		.
	rst 38h			;700b	ff		.
	rst 38h			;700c	ff		.
	rst 38h			;700d	ff		.
	rst 38h			;700e	ff		.
	rst 38h			;700f	ff		.
	rst 38h			;7010	ff		.
	rst 38h			;7011	ff		.
	rst 38h			;7012	ff		.
	rst 38h			;7013	ff		.
	rst 38h			;7014	ff		.
	rst 38h			;7015	ff		.
	rst 38h			;7016	ff		.
	rst 38h			;7017	ff		.
	rst 38h			;7018	ff		.
	rst 38h			;7019	ff		.
	rst 38h			;701a	ff		.
	rst 38h			;701b	ff		.
	rst 38h			;701c	ff		.
	rst 38h			;701d	ff		.
	rst 38h			;701e	ff		.
	rst 38h			;701f	ff		.
	rst 38h			;7020	ff		.
	rst 38h			;7021	ff		.
	rst 38h			;7022	ff		.
	rst 38h			;7023	ff		.
	rst 38h			;7024	ff		.
	rst 38h			;7025	ff		.
	rst 38h			;7026	ff		.
	rst 38h			;7027	ff		.
	rst 38h			;7028	ff		.
	rst 38h			;7029	ff		.
	rst 38h			;702a	ff		.
	rst 38h			;702b	ff		.
	rst 38h			;702c	ff		.
	rst 38h			;702d	ff		.
	rst 38h			;702e	ff		.
	rst 38h			;702f	ff		.
	rst 38h			;7030	ff		.
	rst 38h			;7031	ff		.
	rst 38h			;7032	ff		.
	rst 38h			;7033	ff		.
	rst 38h			;7034	ff		.
	rst 38h			;7035	ff		.
	rst 38h			;7036	ff		.
	rst 38h			;7037	ff		.
	rst 38h			;7038	ff		.
	rst 38h			;7039	ff		.
	rst 38h			;703a	ff		.
	rst 38h			;703b	ff		.
	rst 38h			;703c	ff		.
	rst 38h			;703d	ff		.
	rst 38h			;703e	ff		.
	rst 38h			;703f	ff		.
	rst 38h			;7040	ff		.
	rst 38h			;7041	ff		.
	rst 38h			;7042	ff		.
	rst 38h			;7043	ff		.
	rst 38h			;7044	ff		.
	rst 38h			;7045	ff		.
	rst 38h			;7046	ff		.
	rst 38h			;7047	ff		.
	rst 38h			;7048	ff		.
	rst 38h			;7049	ff		.
	rst 38h			;704a	ff		.
	rst 38h			;704b	ff		.
	rst 38h			;704c	ff		.
	rst 38h			;704d	ff		.
	rst 38h			;704e	ff		.
	rst 38h			;704f	ff		.
	rst 38h			;7050	ff		.
	rst 38h			;7051	ff		.
	rst 38h			;7052	ff		.
	rst 38h			;7053	ff		.
	rst 38h			;7054	ff		.
	rst 38h			;7055	ff		.
	rst 38h			;7056	ff		.
	rst 38h			;7057	ff		.
	rst 38h			;7058	ff		.
	rst 38h			;7059	ff		.
	rst 38h			;705a	ff		.
	rst 38h			;705b	ff		.
	rst 38h			;705c	ff		.
	rst 38h			;705d	ff		.
	rst 38h			;705e	ff		.
	rst 38h			;705f	ff		.
	rst 38h			;7060	ff		.
	rst 38h			;7061	ff		.
	rst 38h			;7062	ff		.
	rst 38h			;7063	ff		.
	rst 38h			;7064	ff		.
	rst 38h			;7065	ff		.
	rst 38h			;7066	ff		.
	rst 38h			;7067	ff		.
	rst 38h			;7068	ff		.
	rst 38h			;7069	ff		.
	rst 38h			;706a	ff		.
	rst 38h			;706b	ff		.
	rst 38h			;706c	ff		.
	rst 38h			;706d	ff		.
	rst 38h			;706e	ff		.
	rst 38h			;706f	ff		.
	rst 38h			;7070	ff		.
	rst 38h			;7071	ff		.
	rst 38h			;7072	ff		.
	rst 38h			;7073	ff		.
	rst 38h			;7074	ff		.
	rst 38h			;7075	ff		.
	rst 38h			;7076	ff		.
	rst 38h			;7077	ff		.
	rst 38h			;7078	ff		.
	rst 38h			;7079	ff		.
	rst 38h			;707a	ff		.
	rst 38h			;707b	ff		.
	rst 38h			;707c	ff		.
	rst 38h			;707d	ff		.
	rst 38h			;707e	ff		.
	rst 38h			;707f	ff		.
	rst 38h			;7080	ff		.
	rst 38h			;7081	ff		.
	rst 38h			;7082	ff		.
	rst 38h			;7083	ff		.
	rst 38h			;7084	ff		.
	rst 38h			;7085	ff		.
	rst 38h			;7086	ff		.
	rst 38h			;7087	ff		.
	rst 38h			;7088	ff		.
	rst 38h			;7089	ff		.
	rst 38h			;708a	ff		.
	rst 38h			;708b	ff		.
	rst 38h			;708c	ff		.
	rst 38h			;708d	ff		.
	rst 38h			;708e	ff		.
	rst 38h			;708f	ff		.
	rst 38h			;7090	ff		.
	rst 38h			;7091	ff		.
	rst 38h			;7092	ff		.
	rst 38h			;7093	ff		.
	rst 38h			;7094	ff		.
	rst 38h			;7095	ff		.
	rst 38h			;7096	ff		.
	rst 38h			;7097	ff		.
	rst 38h			;7098	ff		.
	rst 38h			;7099	ff		.
	rst 38h			;709a	ff		.
	rst 38h			;709b	ff		.
	rst 38h			;709c	ff		.
	rst 38h			;709d	ff		.
	rst 38h			;709e	ff		.
	rst 38h			;709f	ff		.
	rst 38h			;70a0	ff		.
	rst 38h			;70a1	ff		.
	rst 38h			;70a2	ff		.
	rst 38h			;70a3	ff		.
	rst 38h			;70a4	ff		.
	rst 38h			;70a5	ff		.
	rst 38h			;70a6	ff		.
	rst 38h			;70a7	ff		.
	rst 38h			;70a8	ff		.
	rst 38h			;70a9	ff		.
	rst 38h			;70aa	ff		.
	rst 38h			;70ab	ff		.
	rst 38h			;70ac	ff		.
	rst 38h			;70ad	ff		.
	rst 38h			;70ae	ff		.
	rst 38h			;70af	ff		.
	rst 38h			;70b0	ff		.
	rst 38h			;70b1	ff		.
	rst 38h			;70b2	ff		.
	rst 38h			;70b3	ff		.
	rst 38h			;70b4	ff		.
	rst 38h			;70b5	ff		.
	rst 38h			;70b6	ff		.
	rst 38h			;70b7	ff		.
	rst 38h			;70b8	ff		.
	rst 38h			;70b9	ff		.
	rst 38h			;70ba	ff		.
	rst 38h			;70bb	ff		.
	rst 38h			;70bc	ff		.
	rst 38h			;70bd	ff		.
	rst 38h			;70be	ff		.
	rst 38h			;70bf	ff		.
	rst 38h			;70c0	ff		.
	rst 38h			;70c1	ff		.
	rst 38h			;70c2	ff		.
	rst 38h			;70c3	ff		.
	rst 38h			;70c4	ff		.
	rst 38h			;70c5	ff		.
	rst 38h			;70c6	ff		.
	rst 38h			;70c7	ff		.
	rst 38h			;70c8	ff		.
	rst 38h			;70c9	ff		.
	rst 38h			;70ca	ff		.
	rst 38h			;70cb	ff		.
	rst 38h			;70cc	ff		.
	rst 38h			;70cd	ff		.
	rst 38h			;70ce	ff		.
	rst 38h			;70cf	ff		.
	rst 38h			;70d0	ff		.
	rst 38h			;70d1	ff		.
	rst 38h			;70d2	ff		.
	rst 38h			;70d3	ff		.
	rst 38h			;70d4	ff		.
	rst 38h			;70d5	ff		.
	rst 38h			;70d6	ff		.
	rst 38h			;70d7	ff		.
	rst 38h			;70d8	ff		.
	rst 38h			;70d9	ff		.
	rst 38h			;70da	ff		.
	rst 38h			;70db	ff		.
	rst 38h			;70dc	ff		.
	rst 38h			;70dd	ff		.
	rst 38h			;70de	ff		.
	rst 38h			;70df	ff		.
	rst 38h			;70e0	ff		.
	rst 38h			;70e1	ff		.
	rst 38h			;70e2	ff		.
	rst 38h			;70e3	ff		.
	rst 38h			;70e4	ff		.
	rst 38h			;70e5	ff		.
	rst 38h			;70e6	ff		.
	rst 38h			;70e7	ff		.
	rst 38h			;70e8	ff		.
	rst 38h			;70e9	ff		.
	rst 38h			;70ea	ff		.
	rst 38h			;70eb	ff		.
	rst 38h			;70ec	ff		.
	rst 38h			;70ed	ff		.
	rst 38h			;70ee	ff		.
	rst 38h			;70ef	ff		.
	rst 38h			;70f0	ff		.
	rst 38h			;70f1	ff		.
	rst 38h			;70f2	ff		.
	rst 38h			;70f3	ff		.
	rst 38h			;70f4	ff		.
	rst 38h			;70f5	ff		.
	rst 38h			;70f6	ff		.
	rst 38h			;70f7	ff		.
	rst 38h			;70f8	ff		.
	rst 38h			;70f9	ff		.
	rst 38h			;70fa	ff		.
	rst 38h			;70fb	ff		.
	rst 38h			;70fc	ff		.
	rst 38h			;70fd	ff		.
	rst 38h			;70fe	ff		.
	rst 38h			;70ff	ff		.
	rst 38h			;7100	ff		.
	rst 38h			;7101	ff		.
	rst 38h			;7102	ff		.
	rst 38h			;7103	ff		.
	rst 38h			;7104	ff		.
	rst 38h			;7105	ff		.
	rst 38h			;7106	ff		.
	rst 38h			;7107	ff		.
	rst 38h			;7108	ff		.
	rst 38h			;7109	ff		.
	rst 38h			;710a	ff		.
	rst 38h			;710b	ff		.
	rst 38h			;710c	ff		.
	rst 38h			;710d	ff		.
	rst 38h			;710e	ff		.
	rst 38h			;710f	ff		.
	rst 38h			;7110	ff		.
	rst 38h			;7111	ff		.
	rst 38h			;7112	ff		.
	rst 38h			;7113	ff		.
	rst 38h			;7114	ff		.
	rst 38h			;7115	ff		.
	rst 38h			;7116	ff		.
	rst 38h			;7117	ff		.
	rst 38h			;7118	ff		.
	rst 38h			;7119	ff		.
	rst 38h			;711a	ff		.
	rst 38h			;711b	ff		.
	rst 38h			;711c	ff		.
	rst 38h			;711d	ff		.
	rst 38h			;711e	ff		.
	rst 38h			;711f	ff		.
	rst 38h			;7120	ff		.
	rst 38h			;7121	ff		.
	rst 38h			;7122	ff		.
	rst 38h			;7123	ff		.
	rst 38h			;7124	ff		.
	rst 38h			;7125	ff		.
	rst 38h			;7126	ff		.
	rst 38h			;7127	ff		.
	rst 38h			;7128	ff		.
	rst 38h			;7129	ff		.
	rst 38h			;712a	ff		.
	rst 38h			;712b	ff		.
	rst 38h			;712c	ff		.
	rst 38h			;712d	ff		.
	rst 38h			;712e	ff		.
	rst 38h			;712f	ff		.
	rst 38h			;7130	ff		.
	rst 38h			;7131	ff		.
	rst 38h			;7132	ff		.
	rst 38h			;7133	ff		.
	rst 38h			;7134	ff		.
	rst 38h			;7135	ff		.
	rst 38h			;7136	ff		.
	rst 38h			;7137	ff		.
	rst 38h			;7138	ff		.
	rst 38h			;7139	ff		.
	rst 38h			;713a	ff		.
	rst 38h			;713b	ff		.
	rst 38h			;713c	ff		.
	rst 38h			;713d	ff		.
	rst 38h			;713e	ff		.
	rst 38h			;713f	ff		.
	rst 38h			;7140	ff		.
	rst 38h			;7141	ff		.
	rst 38h			;7142	ff		.
	rst 38h			;7143	ff		.
	rst 38h			;7144	ff		.
	rst 38h			;7145	ff		.
	rst 38h			;7146	ff		.
	rst 38h			;7147	ff		.
	rst 38h			;7148	ff		.
	rst 38h			;7149	ff		.
	rst 38h			;714a	ff		.
	rst 38h			;714b	ff		.
	rst 38h			;714c	ff		.
	rst 38h			;714d	ff		.
	rst 38h			;714e	ff		.
	rst 38h			;714f	ff		.
	rst 38h			;7150	ff		.
	rst 38h			;7151	ff		.
	rst 38h			;7152	ff		.
	rst 38h			;7153	ff		.
	rst 38h			;7154	ff		.
	rst 38h			;7155	ff		.
	rst 38h			;7156	ff		.
	rst 38h			;7157	ff		.
	rst 38h			;7158	ff		.
	rst 38h			;7159	ff		.
	rst 38h			;715a	ff		.
	rst 38h			;715b	ff		.
	rst 38h			;715c	ff		.
	rst 38h			;715d	ff		.
	rst 38h			;715e	ff		.
	rst 38h			;715f	ff		.
	rst 38h			;7160	ff		.
	rst 38h			;7161	ff		.
	rst 38h			;7162	ff		.
	rst 38h			;7163	ff		.
	rst 38h			;7164	ff		.
	rst 38h			;7165	ff		.
	rst 38h			;7166	ff		.
	rst 38h			;7167	ff		.
	rst 38h			;7168	ff		.
	rst 38h			;7169	ff		.
	rst 38h			;716a	ff		.
	rst 38h			;716b	ff		.
	rst 38h			;716c	ff		.
	rst 38h			;716d	ff		.
	rst 38h			;716e	ff		.
	rst 38h			;716f	ff		.
	rst 38h			;7170	ff		.
	rst 38h			;7171	ff		.
	rst 38h			;7172	ff		.
	rst 38h			;7173	ff		.
	rst 38h			;7174	ff		.
	rst 38h			;7175	ff		.
	rst 38h			;7176	ff		.
	rst 38h			;7177	ff		.
	rst 38h			;7178	ff		.
	rst 38h			;7179	ff		.
	rst 38h			;717a	ff		.
	rst 38h			;717b	ff		.
	rst 38h			;717c	ff		.
	rst 38h			;717d	ff		.
	rst 38h			;717e	ff		.
	rst 38h			;717f	ff		.
	rst 38h			;7180	ff		.
	rst 38h			;7181	ff		.
	rst 38h			;7182	ff		.
	rst 38h			;7183	ff		.
	rst 38h			;7184	ff		.
	rst 38h			;7185	ff		.
	rst 38h			;7186	ff		.
	rst 38h			;7187	ff		.
	rst 38h			;7188	ff		.
	rst 38h			;7189	ff		.
	rst 38h			;718a	ff		.
	rst 38h			;718b	ff		.
	rst 38h			;718c	ff		.
	rst 38h			;718d	ff		.
	rst 38h			;718e	ff		.
	rst 38h			;718f	ff		.
	rst 38h			;7190	ff		.
	rst 38h			;7191	ff		.
	rst 38h			;7192	ff		.
	rst 38h			;7193	ff		.
	rst 38h			;7194	ff		.
	rst 38h			;7195	ff		.
	rst 38h			;7196	ff		.
	rst 38h			;7197	ff		.
	rst 38h			;7198	ff		.
	rst 38h			;7199	ff		.
	rst 38h			;719a	ff		.
	rst 38h			;719b	ff		.
	rst 38h			;719c	ff		.
	rst 38h			;719d	ff		.
	rst 38h			;719e	ff		.
	rst 38h			;719f	ff		.
	rst 38h			;71a0	ff		.
	rst 38h			;71a1	ff		.
	rst 38h			;71a2	ff		.
	rst 38h			;71a3	ff		.
	rst 38h			;71a4	ff		.
	rst 38h			;71a5	ff		.
	rst 38h			;71a6	ff		.
	rst 38h			;71a7	ff		.
	rst 38h			;71a8	ff		.
	rst 38h			;71a9	ff		.
	rst 38h			;71aa	ff		.
	rst 38h			;71ab	ff		.
	rst 38h			;71ac	ff		.
	rst 38h			;71ad	ff		.
	rst 38h			;71ae	ff		.
	rst 38h			;71af	ff		.
	rst 38h			;71b0	ff		.
	rst 38h			;71b1	ff		.
	rst 38h			;71b2	ff		.
	rst 38h			;71b3	ff		.
	rst 38h			;71b4	ff		.
	rst 38h			;71b5	ff		.
	rst 38h			;71b6	ff		.
	rst 38h			;71b7	ff		.
	rst 38h			;71b8	ff		.
	rst 38h			;71b9	ff		.
	rst 38h			;71ba	ff		.
	rst 38h			;71bb	ff		.
	rst 38h			;71bc	ff		.
	rst 38h			;71bd	ff		.
	rst 38h			;71be	ff		.
	rst 38h			;71bf	ff		.
	rst 38h			;71c0	ff		.
	rst 38h			;71c1	ff		.
	rst 38h			;71c2	ff		.
	rst 38h			;71c3	ff		.
	rst 38h			;71c4	ff		.
	rst 38h			;71c5	ff		.
	rst 38h			;71c6	ff		.
	rst 38h			;71c7	ff		.
	rst 38h			;71c8	ff		.
	rst 38h			;71c9	ff		.
	rst 38h			;71ca	ff		.
	rst 38h			;71cb	ff		.
	rst 38h			;71cc	ff		.
	rst 38h			;71cd	ff		.
	rst 38h			;71ce	ff		.
	rst 38h			;71cf	ff		.
	rst 38h			;71d0	ff		.
	rst 38h			;71d1	ff		.
	rst 38h			;71d2	ff		.
	rst 38h			;71d3	ff		.
	rst 38h			;71d4	ff		.
	rst 38h			;71d5	ff		.
	rst 38h			;71d6	ff		.
	rst 38h			;71d7	ff		.
	rst 38h			;71d8	ff		.
	rst 38h			;71d9	ff		.
	rst 38h			;71da	ff		.
	rst 38h			;71db	ff		.
	rst 38h			;71dc	ff		.
	rst 38h			;71dd	ff		.
	rst 38h			;71de	ff		.
	rst 38h			;71df	ff		.
	rst 38h			;71e0	ff		.
	rst 38h			;71e1	ff		.
	rst 38h			;71e2	ff		.
	rst 38h			;71e3	ff		.
	rst 38h			;71e4	ff		.
	rst 38h			;71e5	ff		.
	rst 38h			;71e6	ff		.
	rst 38h			;71e7	ff		.
	rst 38h			;71e8	ff		.
	rst 38h			;71e9	ff		.
	rst 38h			;71ea	ff		.
	rst 38h			;71eb	ff		.
	rst 38h			;71ec	ff		.
	rst 38h			;71ed	ff		.
	rst 38h			;71ee	ff		.
	rst 38h			;71ef	ff		.
	rst 38h			;71f0	ff		.
	rst 38h			;71f1	ff		.
	rst 38h			;71f2	ff		.
	rst 38h			;71f3	ff		.
	rst 38h			;71f4	ff		.
	rst 38h			;71f5	ff		.
	rst 38h			;71f6	ff		.
	rst 38h			;71f7	ff		.
	rst 38h			;71f8	ff		.
	rst 38h			;71f9	ff		.
	rst 38h			;71fa	ff		.
	rst 38h			;71fb	ff		.
	rst 38h			;71fc	ff		.
	rst 38h			;71fd	ff		.
	rst 38h			;71fe	ff		.
	rst 38h			;71ff	ff		.
	rst 38h			;7200	ff		.
	rst 38h			;7201	ff		.
	rst 38h			;7202	ff		.
	rst 38h			;7203	ff		.
	rst 38h			;7204	ff		.
	rst 38h			;7205	ff		.
	rst 38h			;7206	ff		.
	rst 38h			;7207	ff		.
	rst 38h			;7208	ff		.
	rst 38h			;7209	ff		.
	rst 38h			;720a	ff		.
	rst 38h			;720b	ff		.
	rst 38h			;720c	ff		.
	rst 38h			;720d	ff		.
	rst 38h			;720e	ff		.
	rst 38h			;720f	ff		.
	rst 38h			;7210	ff		.
	rst 38h			;7211	ff		.
	rst 38h			;7212	ff		.
	rst 38h			;7213	ff		.
	rst 38h			;7214	ff		.
	rst 38h			;7215	ff		.
	rst 38h			;7216	ff		.
	rst 38h			;7217	ff		.
	rst 38h			;7218	ff		.
	rst 38h			;7219	ff		.
	rst 38h			;721a	ff		.
	rst 38h			;721b	ff		.
	rst 38h			;721c	ff		.
	rst 38h			;721d	ff		.
	rst 38h			;721e	ff		.
	rst 38h			;721f	ff		.
	rst 38h			;7220	ff		.
	rst 38h			;7221	ff		.
	rst 38h			;7222	ff		.
	rst 38h			;7223	ff		.
	rst 38h			;7224	ff		.
	rst 38h			;7225	ff		.
	rst 38h			;7226	ff		.
	rst 38h			;7227	ff		.
	rst 38h			;7228	ff		.
	rst 38h			;7229	ff		.
	rst 38h			;722a	ff		.
	rst 38h			;722b	ff		.
	rst 38h			;722c	ff		.
	rst 38h			;722d	ff		.
	rst 38h			;722e	ff		.
	rst 38h			;722f	ff		.
	rst 38h			;7230	ff		.
	rst 38h			;7231	ff		.
	rst 38h			;7232	ff		.
	rst 38h			;7233	ff		.
	rst 38h			;7234	ff		.
	rst 38h			;7235	ff		.
	rst 38h			;7236	ff		.
	rst 38h			;7237	ff		.
	rst 38h			;7238	ff		.
	rst 38h			;7239	ff		.
	rst 38h			;723a	ff		.
	rst 38h			;723b	ff		.
	rst 38h			;723c	ff		.
	rst 38h			;723d	ff		.
	rst 38h			;723e	ff		.
	rst 38h			;723f	ff		.
	rst 38h			;7240	ff		.
	rst 38h			;7241	ff		.
	rst 38h			;7242	ff		.
	rst 38h			;7243	ff		.
	rst 38h			;7244	ff		.
	rst 38h			;7245	ff		.
	rst 38h			;7246	ff		.
	rst 38h			;7247	ff		.
	rst 38h			;7248	ff		.
	rst 38h			;7249	ff		.
	rst 38h			;724a	ff		.
	rst 38h			;724b	ff		.
	rst 38h			;724c	ff		.
	rst 38h			;724d	ff		.
	rst 38h			;724e	ff		.
	rst 38h			;724f	ff		.
	rst 38h			;7250	ff		.
	rst 38h			;7251	ff		.
	rst 38h			;7252	ff		.
	rst 38h			;7253	ff		.
	rst 38h			;7254	ff		.
	rst 38h			;7255	ff		.
	rst 38h			;7256	ff		.
	rst 38h			;7257	ff		.
	rst 38h			;7258	ff		.
	rst 38h			;7259	ff		.
	rst 38h			;725a	ff		.
	rst 38h			;725b	ff		.
	rst 38h			;725c	ff		.
	rst 38h			;725d	ff		.
	rst 38h			;725e	ff		.
	rst 38h			;725f	ff		.
	rst 38h			;7260	ff		.
	rst 38h			;7261	ff		.
	rst 38h			;7262	ff		.
	rst 38h			;7263	ff		.
	rst 38h			;7264	ff		.
	rst 38h			;7265	ff		.
	rst 38h			;7266	ff		.
	rst 38h			;7267	ff		.
	rst 38h			;7268	ff		.
	rst 38h			;7269	ff		.
	rst 38h			;726a	ff		.
	rst 38h			;726b	ff		.
	rst 38h			;726c	ff		.
	rst 38h			;726d	ff		.
	rst 38h			;726e	ff		.
	rst 38h			;726f	ff		.
	rst 38h			;7270	ff		.
	rst 38h			;7271	ff		.
	rst 38h			;7272	ff		.
	rst 38h			;7273	ff		.
	rst 38h			;7274	ff		.
	rst 38h			;7275	ff		.
	rst 38h			;7276	ff		.
	rst 38h			;7277	ff		.
	rst 38h			;7278	ff		.
	rst 38h			;7279	ff		.
	rst 38h			;727a	ff		.
	rst 38h			;727b	ff		.
	rst 38h			;727c	ff		.
	rst 38h			;727d	ff		.
	rst 38h			;727e	ff		.
	rst 38h			;727f	ff		.
	rst 38h			;7280	ff		.
	rst 38h			;7281	ff		.
	rst 38h			;7282	ff		.
	rst 38h			;7283	ff		.
	rst 38h			;7284	ff		.
	rst 38h			;7285	ff		.
	rst 38h			;7286	ff		.
	rst 38h			;7287	ff		.
	rst 38h			;7288	ff		.
	rst 38h			;7289	ff		.
	rst 38h			;728a	ff		.
	rst 38h			;728b	ff		.
	rst 38h			;728c	ff		.
	rst 38h			;728d	ff		.
	rst 38h			;728e	ff		.
	rst 38h			;728f	ff		.
	rst 38h			;7290	ff		.
	rst 38h			;7291	ff		.
	rst 38h			;7292	ff		.
	rst 38h			;7293	ff		.
	rst 38h			;7294	ff		.
	rst 38h			;7295	ff		.
	rst 38h			;7296	ff		.
	rst 38h			;7297	ff		.
	rst 38h			;7298	ff		.
	rst 38h			;7299	ff		.
	rst 38h			;729a	ff		.
	rst 38h			;729b	ff		.
	rst 38h			;729c	ff		.
	rst 38h			;729d	ff		.
	rst 38h			;729e	ff		.
	rst 38h			;729f	ff		.
	rst 38h			;72a0	ff		.
	rst 38h			;72a1	ff		.
	rst 38h			;72a2	ff		.
	rst 38h			;72a3	ff		.
	rst 38h			;72a4	ff		.
	rst 38h			;72a5	ff		.
	rst 38h			;72a6	ff		.
	rst 38h			;72a7	ff		.
	rst 38h			;72a8	ff		.
	rst 38h			;72a9	ff		.
	rst 38h			;72aa	ff		.
	rst 38h			;72ab	ff		.
	rst 38h			;72ac	ff		.
	rst 38h			;72ad	ff		.
	rst 38h			;72ae	ff		.
	rst 38h			;72af	ff		.
	rst 38h			;72b0	ff		.
	rst 38h			;72b1	ff		.
	rst 38h			;72b2	ff		.
	rst 38h			;72b3	ff		.
	rst 38h			;72b4	ff		.
	rst 38h			;72b5	ff		.
	rst 38h			;72b6	ff		.
	rst 38h			;72b7	ff		.
	rst 38h			;72b8	ff		.
	rst 38h			;72b9	ff		.
	rst 38h			;72ba	ff		.
	rst 38h			;72bb	ff		.
	rst 38h			;72bc	ff		.
	rst 38h			;72bd	ff		.
	rst 38h			;72be	ff		.
	rst 38h			;72bf	ff		.
	rst 38h			;72c0	ff		.
	rst 38h			;72c1	ff		.
	rst 38h			;72c2	ff		.
	rst 38h			;72c3	ff		.
	rst 38h			;72c4	ff		.
	rst 38h			;72c5	ff		.
	rst 38h			;72c6	ff		.
	rst 38h			;72c7	ff		.
	rst 38h			;72c8	ff		.
	rst 38h			;72c9	ff		.
	rst 38h			;72ca	ff		.
	rst 38h			;72cb	ff		.
	rst 38h			;72cc	ff		.
	rst 38h			;72cd	ff		.
	rst 38h			;72ce	ff		.
	rst 38h			;72cf	ff		.
	rst 38h			;72d0	ff		.
	rst 38h			;72d1	ff		.
	rst 38h			;72d2	ff		.
	rst 38h			;72d3	ff		.
	rst 38h			;72d4	ff		.
	rst 38h			;72d5	ff		.
	rst 38h			;72d6	ff		.
	rst 38h			;72d7	ff		.
	rst 38h			;72d8	ff		.
	rst 38h			;72d9	ff		.
	rst 38h			;72da	ff		.
	rst 38h			;72db	ff		.
	rst 38h			;72dc	ff		.
	rst 38h			;72dd	ff		.
	rst 38h			;72de	ff		.
	rst 38h			;72df	ff		.
	rst 38h			;72e0	ff		.
	rst 38h			;72e1	ff		.
	rst 38h			;72e2	ff		.
	rst 38h			;72e3	ff		.
	rst 38h			;72e4	ff		.
	rst 38h			;72e5	ff		.
	rst 38h			;72e6	ff		.
	rst 38h			;72e7	ff		.
	rst 38h			;72e8	ff		.
	rst 38h			;72e9	ff		.
	rst 38h			;72ea	ff		.
	rst 38h			;72eb	ff		.
	rst 38h			;72ec	ff		.
	rst 38h			;72ed	ff		.
	rst 38h			;72ee	ff		.
	rst 38h			;72ef	ff		.
	rst 38h			;72f0	ff		.
	rst 38h			;72f1	ff		.
	rst 38h			;72f2	ff		.
	rst 38h			;72f3	ff		.
	rst 38h			;72f4	ff		.
	rst 38h			;72f5	ff		.
	rst 38h			;72f6	ff		.
	rst 38h			;72f7	ff		.
	rst 38h			;72f8	ff		.
	rst 38h			;72f9	ff		.
	rst 38h			;72fa	ff		.
	rst 38h			;72fb	ff		.
	rst 38h			;72fc	ff		.
	rst 38h			;72fd	ff		.
	rst 38h			;72fe	ff		.
	rst 38h			;72ff	ff		.
	rst 38h			;7300	ff		.
	rst 38h			;7301	ff		.
	rst 38h			;7302	ff		.
	rst 38h			;7303	ff		.
	rst 38h			;7304	ff		.
	rst 38h			;7305	ff		.
	rst 38h			;7306	ff		.
	rst 38h			;7307	ff		.
	rst 38h			;7308	ff		.
	rst 38h			;7309	ff		.
	rst 38h			;730a	ff		.
	rst 38h			;730b	ff		.
	rst 38h			;730c	ff		.
	rst 38h			;730d	ff		.
	rst 38h			;730e	ff		.
	rst 38h			;730f	ff		.
	rst 38h			;7310	ff		.
	rst 38h			;7311	ff		.
	rst 38h			;7312	ff		.
	rst 38h			;7313	ff		.
	rst 38h			;7314	ff		.
	rst 38h			;7315	ff		.
	rst 38h			;7316	ff		.
	rst 38h			;7317	ff		.
	rst 38h			;7318	ff		.
	rst 38h			;7319	ff		.
	rst 38h			;731a	ff		.
	rst 38h			;731b	ff		.
	rst 38h			;731c	ff		.
	rst 38h			;731d	ff		.
	rst 38h			;731e	ff		.
	rst 38h			;731f	ff		.
	rst 38h			;7320	ff		.
	rst 38h			;7321	ff		.
	rst 38h			;7322	ff		.
	rst 38h			;7323	ff		.
	rst 38h			;7324	ff		.
	rst 38h			;7325	ff		.
	rst 38h			;7326	ff		.
	rst 38h			;7327	ff		.
	rst 38h			;7328	ff		.
	rst 38h			;7329	ff		.
	rst 38h			;732a	ff		.
	rst 38h			;732b	ff		.
	rst 38h			;732c	ff		.
	rst 38h			;732d	ff		.
	rst 38h			;732e	ff		.
	rst 38h			;732f	ff		.
	rst 38h			;7330	ff		.
	rst 38h			;7331	ff		.
	rst 38h			;7332	ff		.
	rst 38h			;7333	ff		.
	rst 38h			;7334	ff		.
	rst 38h			;7335	ff		.
	rst 38h			;7336	ff		.
	rst 38h			;7337	ff		.
	rst 38h			;7338	ff		.
	rst 38h			;7339	ff		.
	rst 38h			;733a	ff		.
	rst 38h			;733b	ff		.
	rst 38h			;733c	ff		.
	rst 38h			;733d	ff		.
	rst 38h			;733e	ff		.
	rst 38h			;733f	ff		.
	rst 38h			;7340	ff		.
	rst 38h			;7341	ff		.
	rst 38h			;7342	ff		.
	rst 38h			;7343	ff		.
	rst 38h			;7344	ff		.
	rst 38h			;7345	ff		.
	rst 38h			;7346	ff		.
	rst 38h			;7347	ff		.
	rst 38h			;7348	ff		.
	rst 38h			;7349	ff		.
	rst 38h			;734a	ff		.
	rst 38h			;734b	ff		.
	rst 38h			;734c	ff		.
	rst 38h			;734d	ff		.
	rst 38h			;734e	ff		.
	rst 38h			;734f	ff		.
	rst 38h			;7350	ff		.
	rst 38h			;7351	ff		.
	rst 38h			;7352	ff		.
	rst 38h			;7353	ff		.
	rst 38h			;7354	ff		.
	rst 38h			;7355	ff		.
	rst 38h			;7356	ff		.
	rst 38h			;7357	ff		.
	rst 38h			;7358	ff		.
	rst 38h			;7359	ff		.
	rst 38h			;735a	ff		.
	rst 38h			;735b	ff		.
	rst 38h			;735c	ff		.
	rst 38h			;735d	ff		.
	rst 38h			;735e	ff		.
	rst 38h			;735f	ff		.
	rst 38h			;7360	ff		.
	rst 38h			;7361	ff		.
	rst 38h			;7362	ff		.
	rst 38h			;7363	ff		.
	rst 38h			;7364	ff		.
	rst 38h			;7365	ff		.
	rst 38h			;7366	ff		.
	rst 38h			;7367	ff		.
	rst 38h			;7368	ff		.
	rst 38h			;7369	ff		.
	rst 38h			;736a	ff		.
	rst 38h			;736b	ff		.
	rst 38h			;736c	ff		.
	rst 38h			;736d	ff		.
	rst 38h			;736e	ff		.
	rst 38h			;736f	ff		.
	rst 38h			;7370	ff		.
	rst 38h			;7371	ff		.
	rst 38h			;7372	ff		.
	rst 38h			;7373	ff		.
	rst 38h			;7374	ff		.
	rst 38h			;7375	ff		.
	rst 38h			;7376	ff		.
	rst 38h			;7377	ff		.
	rst 38h			;7378	ff		.
	rst 38h			;7379	ff		.
	rst 38h			;737a	ff		.
	rst 38h			;737b	ff		.
	rst 38h			;737c	ff		.
	rst 38h			;737d	ff		.
	rst 38h			;737e	ff		.
	rst 38h			;737f	ff		.
	rst 38h			;7380	ff		.
	rst 38h			;7381	ff		.
	rst 38h			;7382	ff		.
	rst 38h			;7383	ff		.
	rst 38h			;7384	ff		.
	rst 38h			;7385	ff		.
	rst 38h			;7386	ff		.
	rst 38h			;7387	ff		.
	rst 38h			;7388	ff		.
	rst 38h			;7389	ff		.
	rst 38h			;738a	ff		.
	rst 38h			;738b	ff		.
	rst 38h			;738c	ff		.
	rst 38h			;738d	ff		.
	rst 38h			;738e	ff		.
	rst 38h			;738f	ff		.
	rst 38h			;7390	ff		.
	rst 38h			;7391	ff		.
	rst 38h			;7392	ff		.
	rst 38h			;7393	ff		.
	rst 38h			;7394	ff		.
	rst 38h			;7395	ff		.
	rst 38h			;7396	ff		.
	rst 38h			;7397	ff		.
	rst 38h			;7398	ff		.
	rst 38h			;7399	ff		.
	rst 38h			;739a	ff		.
	rst 38h			;739b	ff		.
	rst 38h			;739c	ff		.
	rst 38h			;739d	ff		.
	rst 38h			;739e	ff		.
	rst 38h			;739f	ff		.
	rst 38h			;73a0	ff		.
	rst 38h			;73a1	ff		.
	rst 38h			;73a2	ff		.
	rst 38h			;73a3	ff		.
	rst 38h			;73a4	ff		.
	rst 38h			;73a5	ff		.
	rst 38h			;73a6	ff		.
	rst 38h			;73a7	ff		.
	rst 38h			;73a8	ff		.
	rst 38h			;73a9	ff		.
	rst 38h			;73aa	ff		.
	rst 38h			;73ab	ff		.
	rst 38h			;73ac	ff		.
	rst 38h			;73ad	ff		.
	rst 38h			;73ae	ff		.
	rst 38h			;73af	ff		.
	rst 38h			;73b0	ff		.
	rst 38h			;73b1	ff		.
	rst 38h			;73b2	ff		.
	rst 38h			;73b3	ff		.
	rst 38h			;73b4	ff		.
	rst 38h			;73b5	ff		.
	rst 38h			;73b6	ff		.
	rst 38h			;73b7	ff		.
	rst 38h			;73b8	ff		.
	rst 38h			;73b9	ff		.
	rst 38h			;73ba	ff		.
	rst 38h			;73bb	ff		.
	rst 38h			;73bc	ff		.
	rst 38h			;73bd	ff		.
	rst 38h			;73be	ff		.
	rst 38h			;73bf	ff		.
	rst 38h			;73c0	ff		.
	rst 38h			;73c1	ff		.
	rst 38h			;73c2	ff		.
	rst 38h			;73c3	ff		.
	rst 38h			;73c4	ff		.
	rst 38h			;73c5	ff		.
	rst 38h			;73c6	ff		.
	rst 38h			;73c7	ff		.
	rst 38h			;73c8	ff		.
	rst 38h			;73c9	ff		.
	rst 38h			;73ca	ff		.
	rst 38h			;73cb	ff		.
	rst 38h			;73cc	ff		.
	rst 38h			;73cd	ff		.
	rst 38h			;73ce	ff		.
	rst 38h			;73cf	ff		.
	rst 38h			;73d0	ff		.
	rst 38h			;73d1	ff		.
	rst 38h			;73d2	ff		.
	rst 38h			;73d3	ff		.
	rst 38h			;73d4	ff		.
	rst 38h			;73d5	ff		.
	rst 38h			;73d6	ff		.
	rst 38h			;73d7	ff		.
	rst 38h			;73d8	ff		.
	rst 38h			;73d9	ff		.
	rst 38h			;73da	ff		.
	rst 38h			;73db	ff		.
	rst 38h			;73dc	ff		.
	rst 38h			;73dd	ff		.
	rst 38h			;73de	ff		.
	rst 38h			;73df	ff		.
	rst 38h			;73e0	ff		.
	rst 38h			;73e1	ff		.
	rst 38h			;73e2	ff		.
	rst 38h			;73e3	ff		.
	rst 38h			;73e4	ff		.
	rst 38h			;73e5	ff		.
	rst 38h			;73e6	ff		.
	rst 38h			;73e7	ff		.
	rst 38h			;73e8	ff		.
	rst 38h			;73e9	ff		.
	rst 38h			;73ea	ff		.
	rst 38h			;73eb	ff		.
	rst 38h			;73ec	ff		.
	rst 38h			;73ed	ff		.
	rst 38h			;73ee	ff		.
	rst 38h			;73ef	ff		.
	rst 38h			;73f0	ff		.
	rst 38h			;73f1	ff		.
	rst 38h			;73f2	ff		.
	rst 38h			;73f3	ff		.
	rst 38h			;73f4	ff		.
	rst 38h			;73f5	ff		.
	rst 38h			;73f6	ff		.
	rst 38h			;73f7	ff		.
	rst 38h			;73f8	ff		.
	rst 38h			;73f9	ff		.
	rst 38h			;73fa	ff		.
	rst 38h			;73fb	ff		.
	rst 38h			;73fc	ff		.
	rst 38h			;73fd	ff		.
	rst 38h			;73fe	ff		.
	rst 38h			;73ff	ff		.
	rst 38h			;7400	ff		.
	rst 38h			;7401	ff		.
	rst 38h			;7402	ff		.
	rst 38h			;7403	ff		.
	rst 38h			;7404	ff		.
	rst 38h			;7405	ff		.
	rst 38h			;7406	ff		.
	rst 38h			;7407	ff		.
	rst 38h			;7408	ff		.
	rst 38h			;7409	ff		.
	rst 38h			;740a	ff		.
	rst 38h			;740b	ff		.
	rst 38h			;740c	ff		.
	rst 38h			;740d	ff		.
	rst 38h			;740e	ff		.
	rst 38h			;740f	ff		.
	rst 38h			;7410	ff		.
	rst 38h			;7411	ff		.
	rst 38h			;7412	ff		.
	rst 38h			;7413	ff		.
	rst 38h			;7414	ff		.
	rst 38h			;7415	ff		.
	rst 38h			;7416	ff		.
	rst 38h			;7417	ff		.
	rst 38h			;7418	ff		.
	rst 38h			;7419	ff		.
	rst 38h			;741a	ff		.
	rst 38h			;741b	ff		.
	rst 38h			;741c	ff		.
	rst 38h			;741d	ff		.
	rst 38h			;741e	ff		.
	rst 38h			;741f	ff		.
	rst 38h			;7420	ff		.
	rst 38h			;7421	ff		.
	rst 38h			;7422	ff		.
	rst 38h			;7423	ff		.
	rst 38h			;7424	ff		.
	rst 38h			;7425	ff		.
	rst 38h			;7426	ff		.
	rst 38h			;7427	ff		.
	rst 38h			;7428	ff		.
	rst 38h			;7429	ff		.
	rst 38h			;742a	ff		.
	rst 38h			;742b	ff		.
	rst 38h			;742c	ff		.
	rst 38h			;742d	ff		.
	rst 38h			;742e	ff		.
	rst 38h			;742f	ff		.
	rst 38h			;7430	ff		.
	rst 38h			;7431	ff		.
	rst 38h			;7432	ff		.
	rst 38h			;7433	ff		.
	rst 38h			;7434	ff		.
	rst 38h			;7435	ff		.
	rst 38h			;7436	ff		.
	rst 38h			;7437	ff		.
	rst 38h			;7438	ff		.
	rst 38h			;7439	ff		.
	rst 38h			;743a	ff		.
	rst 38h			;743b	ff		.
	rst 38h			;743c	ff		.
	rst 38h			;743d	ff		.
	rst 38h			;743e	ff		.
	rst 38h			;743f	ff		.
	rst 38h			;7440	ff		.
	rst 38h			;7441	ff		.
	rst 38h			;7442	ff		.
	rst 38h			;7443	ff		.
	rst 38h			;7444	ff		.
	rst 38h			;7445	ff		.
	rst 38h			;7446	ff		.
	rst 38h			;7447	ff		.
	rst 38h			;7448	ff		.
	rst 38h			;7449	ff		.
	rst 38h			;744a	ff		.
	rst 38h			;744b	ff		.
	rst 38h			;744c	ff		.
	rst 38h			;744d	ff		.
	rst 38h			;744e	ff		.
	rst 38h			;744f	ff		.
	rst 38h			;7450	ff		.
	rst 38h			;7451	ff		.
	rst 38h			;7452	ff		.
	rst 38h			;7453	ff		.
	rst 38h			;7454	ff		.
	rst 38h			;7455	ff		.
	rst 38h			;7456	ff		.
	rst 38h			;7457	ff		.
	rst 38h			;7458	ff		.
	rst 38h			;7459	ff		.
	rst 38h			;745a	ff		.
	rst 38h			;745b	ff		.
	rst 38h			;745c	ff		.
	rst 38h			;745d	ff		.
	rst 38h			;745e	ff		.
	rst 38h			;745f	ff		.
	rst 38h			;7460	ff		.
	rst 38h			;7461	ff		.
	rst 38h			;7462	ff		.
	rst 38h			;7463	ff		.
	rst 38h			;7464	ff		.
	rst 38h			;7465	ff		.
	rst 38h			;7466	ff		.
	rst 38h			;7467	ff		.
	rst 38h			;7468	ff		.
	rst 38h			;7469	ff		.
	rst 38h			;746a	ff		.
	rst 38h			;746b	ff		.
	rst 38h			;746c	ff		.
	rst 38h			;746d	ff		.
	rst 38h			;746e	ff		.
	rst 38h			;746f	ff		.
	rst 38h			;7470	ff		.
	rst 38h			;7471	ff		.
	rst 38h			;7472	ff		.
	rst 38h			;7473	ff		.
	rst 38h			;7474	ff		.
	rst 38h			;7475	ff		.
	rst 38h			;7476	ff		.
	rst 38h			;7477	ff		.
	rst 38h			;7478	ff		.
	rst 38h			;7479	ff		.
	rst 38h			;747a	ff		.
	rst 38h			;747b	ff		.
	rst 38h			;747c	ff		.
	rst 38h			;747d	ff		.
	rst 38h			;747e	ff		.
	rst 38h			;747f	ff		.
	rst 38h			;7480	ff		.
	rst 38h			;7481	ff		.
	rst 38h			;7482	ff		.
	rst 38h			;7483	ff		.
	rst 38h			;7484	ff		.
	rst 38h			;7485	ff		.
	rst 38h			;7486	ff		.
	rst 38h			;7487	ff		.
	rst 38h			;7488	ff		.
	rst 38h			;7489	ff		.
	rst 38h			;748a	ff		.
	rst 38h			;748b	ff		.
	rst 38h			;748c	ff		.
	rst 38h			;748d	ff		.
	rst 38h			;748e	ff		.
	rst 38h			;748f	ff		.
	rst 38h			;7490	ff		.
	rst 38h			;7491	ff		.
	rst 38h			;7492	ff		.
	rst 38h			;7493	ff		.
	rst 38h			;7494	ff		.
	rst 38h			;7495	ff		.
	rst 38h			;7496	ff		.
	rst 38h			;7497	ff		.
	rst 38h			;7498	ff		.
	rst 38h			;7499	ff		.
	rst 38h			;749a	ff		.
	rst 38h			;749b	ff		.
	rst 38h			;749c	ff		.
	rst 38h			;749d	ff		.
	rst 38h			;749e	ff		.
	rst 38h			;749f	ff		.
	rst 38h			;74a0	ff		.
	rst 38h			;74a1	ff		.
	rst 38h			;74a2	ff		.
	rst 38h			;74a3	ff		.
	rst 38h			;74a4	ff		.
	rst 38h			;74a5	ff		.
	rst 38h			;74a6	ff		.
	rst 38h			;74a7	ff		.
	rst 38h			;74a8	ff		.
	rst 38h			;74a9	ff		.
	rst 38h			;74aa	ff		.
	rst 38h			;74ab	ff		.
	rst 38h			;74ac	ff		.
	rst 38h			;74ad	ff		.
	rst 38h			;74ae	ff		.
	rst 38h			;74af	ff		.
	rst 38h			;74b0	ff		.
	rst 38h			;74b1	ff		.
	rst 38h			;74b2	ff		.
	rst 38h			;74b3	ff		.
	rst 38h			;74b4	ff		.
	rst 38h			;74b5	ff		.
	rst 38h			;74b6	ff		.
	rst 38h			;74b7	ff		.
	rst 38h			;74b8	ff		.
	rst 38h			;74b9	ff		.
	rst 38h			;74ba	ff		.
	rst 38h			;74bb	ff		.
	rst 38h			;74bc	ff		.
	rst 38h			;74bd	ff		.
	rst 38h			;74be	ff		.
	rst 38h			;74bf	ff		.
	rst 38h			;74c0	ff		.
	rst 38h			;74c1	ff		.
	rst 38h			;74c2	ff		.
	rst 38h			;74c3	ff		.
	rst 38h			;74c4	ff		.
	rst 38h			;74c5	ff		.
	rst 38h			;74c6	ff		.
	rst 38h			;74c7	ff		.
	rst 38h			;74c8	ff		.
	rst 38h			;74c9	ff		.
	rst 38h			;74ca	ff		.
	rst 38h			;74cb	ff		.
	rst 38h			;74cc	ff		.
	rst 38h			;74cd	ff		.
	rst 38h			;74ce	ff		.
	rst 38h			;74cf	ff		.
	rst 38h			;74d0	ff		.
	rst 38h			;74d1	ff		.
	rst 38h			;74d2	ff		.
	rst 38h			;74d3	ff		.
	rst 38h			;74d4	ff		.
	rst 38h			;74d5	ff		.
	rst 38h			;74d6	ff		.
	rst 38h			;74d7	ff		.
	rst 38h			;74d8	ff		.
	rst 38h			;74d9	ff		.
	rst 38h			;74da	ff		.
	rst 38h			;74db	ff		.
	rst 38h			;74dc	ff		.
	rst 38h			;74dd	ff		.
	rst 38h			;74de	ff		.
	rst 38h			;74df	ff		.
	rst 38h			;74e0	ff		.
	rst 38h			;74e1	ff		.
	rst 38h			;74e2	ff		.
	rst 38h			;74e3	ff		.
	rst 38h			;74e4	ff		.
	rst 38h			;74e5	ff		.
	rst 38h			;74e6	ff		.
	rst 38h			;74e7	ff		.
	rst 38h			;74e8	ff		.
	rst 38h			;74e9	ff		.
	rst 38h			;74ea	ff		.
	rst 38h			;74eb	ff		.
	rst 38h			;74ec	ff		.
	rst 38h			;74ed	ff		.
	rst 38h			;74ee	ff		.
	rst 38h			;74ef	ff		.
	rst 38h			;74f0	ff		.
	rst 38h			;74f1	ff		.
	rst 38h			;74f2	ff		.
	rst 38h			;74f3	ff		.
	rst 38h			;74f4	ff		.
	rst 38h			;74f5	ff		.
	rst 38h			;74f6	ff		.
	rst 38h			;74f7	ff		.
	rst 38h			;74f8	ff		.
	rst 38h			;74f9	ff		.
	rst 38h			;74fa	ff		.
	rst 38h			;74fb	ff		.
	rst 38h			;74fc	ff		.
	rst 38h			;74fd	ff		.
	rst 38h			;74fe	ff		.
	rst 38h			;74ff	ff		.
	rst 38h			;7500	ff		.
	rst 38h			;7501	ff		.
	rst 38h			;7502	ff		.
	rst 38h			;7503	ff		.
	rst 38h			;7504	ff		.
	rst 38h			;7505	ff		.
	rst 38h			;7506	ff		.
	rst 38h			;7507	ff		.
	rst 38h			;7508	ff		.
	rst 38h			;7509	ff		.
	rst 38h			;750a	ff		.
	rst 38h			;750b	ff		.
	rst 38h			;750c	ff		.
	rst 38h			;750d	ff		.
	rst 38h			;750e	ff		.
	rst 38h			;750f	ff		.
	rst 38h			;7510	ff		.
	rst 38h			;7511	ff		.
	rst 38h			;7512	ff		.
	rst 38h			;7513	ff		.
	rst 38h			;7514	ff		.
	rst 38h			;7515	ff		.
	rst 38h			;7516	ff		.
	rst 38h			;7517	ff		.
	rst 38h			;7518	ff		.
	rst 38h			;7519	ff		.
	rst 38h			;751a	ff		.
	rst 38h			;751b	ff		.
	rst 38h			;751c	ff		.
	rst 38h			;751d	ff		.
	rst 38h			;751e	ff		.
	rst 38h			;751f	ff		.
	rst 38h			;7520	ff		.
	rst 38h			;7521	ff		.
	rst 38h			;7522	ff		.
	rst 38h			;7523	ff		.
	rst 38h			;7524	ff		.
	rst 38h			;7525	ff		.
	rst 38h			;7526	ff		.
	rst 38h			;7527	ff		.
	rst 38h			;7528	ff		.
	rst 38h			;7529	ff		.
	rst 38h			;752a	ff		.
	rst 38h			;752b	ff		.
	rst 38h			;752c	ff		.
	rst 38h			;752d	ff		.
	rst 38h			;752e	ff		.
	rst 38h			;752f	ff		.
	rst 38h			;7530	ff		.
	rst 38h			;7531	ff		.
	rst 38h			;7532	ff		.
	rst 38h			;7533	ff		.
	rst 38h			;7534	ff		.
	rst 38h			;7535	ff		.
	rst 38h			;7536	ff		.
	rst 38h			;7537	ff		.
	rst 38h			;7538	ff		.
	rst 38h			;7539	ff		.
	rst 38h			;753a	ff		.
	rst 38h			;753b	ff		.
	rst 38h			;753c	ff		.
	rst 38h			;753d	ff		.
	rst 38h			;753e	ff		.
	rst 38h			;753f	ff		.
	rst 38h			;7540	ff		.
	rst 38h			;7541	ff		.
	rst 38h			;7542	ff		.
	rst 38h			;7543	ff		.
	rst 38h			;7544	ff		.
	rst 38h			;7545	ff		.
	rst 38h			;7546	ff		.
	rst 38h			;7547	ff		.
	rst 38h			;7548	ff		.
	rst 38h			;7549	ff		.
	rst 38h			;754a	ff		.
	rst 38h			;754b	ff		.
	rst 38h			;754c	ff		.
	rst 38h			;754d	ff		.
	rst 38h			;754e	ff		.
	rst 38h			;754f	ff		.
	rst 38h			;7550	ff		.
	rst 38h			;7551	ff		.
	rst 38h			;7552	ff		.
	rst 38h			;7553	ff		.
	rst 38h			;7554	ff		.
	rst 38h			;7555	ff		.
	rst 38h			;7556	ff		.
	rst 38h			;7557	ff		.
	rst 38h			;7558	ff		.
	rst 38h			;7559	ff		.
	rst 38h			;755a	ff		.
	rst 38h			;755b	ff		.
	rst 38h			;755c	ff		.
	rst 38h			;755d	ff		.
	rst 38h			;755e	ff		.
	rst 38h			;755f	ff		.
	rst 38h			;7560	ff		.
	rst 38h			;7561	ff		.
	rst 38h			;7562	ff		.
	rst 38h			;7563	ff		.
	rst 38h			;7564	ff		.
	rst 38h			;7565	ff		.
	rst 38h			;7566	ff		.
	rst 38h			;7567	ff		.
	rst 38h			;7568	ff		.
	rst 38h			;7569	ff		.
	rst 38h			;756a	ff		.
	rst 38h			;756b	ff		.
	rst 38h			;756c	ff		.
	rst 38h			;756d	ff		.
	rst 38h			;756e	ff		.
	rst 38h			;756f	ff		.
	rst 38h			;7570	ff		.
	rst 38h			;7571	ff		.
	rst 38h			;7572	ff		.
	rst 38h			;7573	ff		.
	rst 38h			;7574	ff		.
	rst 38h			;7575	ff		.
	rst 38h			;7576	ff		.
	rst 38h			;7577	ff		.
	rst 38h			;7578	ff		.
	rst 38h			;7579	ff		.
	rst 38h			;757a	ff		.
	rst 38h			;757b	ff		.
	rst 38h			;757c	ff		.
	rst 38h			;757d	ff		.
	rst 38h			;757e	ff		.
	rst 38h			;757f	ff		.
	rst 38h			;7580	ff		.
	rst 38h			;7581	ff		.
	rst 38h			;7582	ff		.
	rst 38h			;7583	ff		.
	rst 38h			;7584	ff		.
	rst 38h			;7585	ff		.
	rst 38h			;7586	ff		.
	rst 38h			;7587	ff		.
	rst 38h			;7588	ff		.
	rst 38h			;7589	ff		.
	rst 38h			;758a	ff		.
	rst 38h			;758b	ff		.
	rst 38h			;758c	ff		.
	rst 38h			;758d	ff		.
	rst 38h			;758e	ff		.
	rst 38h			;758f	ff		.
	rst 38h			;7590	ff		.
	rst 38h			;7591	ff		.
	rst 38h			;7592	ff		.
	rst 38h			;7593	ff		.
	rst 38h			;7594	ff		.
	rst 38h			;7595	ff		.
	rst 38h			;7596	ff		.
	rst 38h			;7597	ff		.
	rst 38h			;7598	ff		.
	rst 38h			;7599	ff		.
	rst 38h			;759a	ff		.
	rst 38h			;759b	ff		.
	rst 38h			;759c	ff		.
	rst 38h			;759d	ff		.
	rst 38h			;759e	ff		.
	rst 38h			;759f	ff		.
	rst 38h			;75a0	ff		.
	rst 38h			;75a1	ff		.
	rst 38h			;75a2	ff		.
	rst 38h			;75a3	ff		.
	rst 38h			;75a4	ff		.
	rst 38h			;75a5	ff		.
	rst 38h			;75a6	ff		.
	rst 38h			;75a7	ff		.
	rst 38h			;75a8	ff		.
	rst 38h			;75a9	ff		.
	rst 38h			;75aa	ff		.
	rst 38h			;75ab	ff		.
	rst 38h			;75ac	ff		.
	rst 38h			;75ad	ff		.
	rst 38h			;75ae	ff		.
	rst 38h			;75af	ff		.
	rst 38h			;75b0	ff		.
	rst 38h			;75b1	ff		.
	rst 38h			;75b2	ff		.
	rst 38h			;75b3	ff		.
	rst 38h			;75b4	ff		.
	rst 38h			;75b5	ff		.
	rst 38h			;75b6	ff		.
	rst 38h			;75b7	ff		.
	rst 38h			;75b8	ff		.
	rst 38h			;75b9	ff		.
	rst 38h			;75ba	ff		.
	rst 38h			;75bb	ff		.
	rst 38h			;75bc	ff		.
	rst 38h			;75bd	ff		.
	rst 38h			;75be	ff		.
	rst 38h			;75bf	ff		.
	rst 38h			;75c0	ff		.
	rst 38h			;75c1	ff		.
	rst 38h			;75c2	ff		.
	rst 38h			;75c3	ff		.
	rst 38h			;75c4	ff		.
	rst 38h			;75c5	ff		.
	rst 38h			;75c6	ff		.
	rst 38h			;75c7	ff		.
	rst 38h			;75c8	ff		.
	rst 38h			;75c9	ff		.
	rst 38h			;75ca	ff		.
	rst 38h			;75cb	ff		.
	rst 38h			;75cc	ff		.
	rst 38h			;75cd	ff		.
	rst 38h			;75ce	ff		.
	rst 38h			;75cf	ff		.
	rst 38h			;75d0	ff		.
	rst 38h			;75d1	ff		.
	rst 38h			;75d2	ff		.
	rst 38h			;75d3	ff		.
	rst 38h			;75d4	ff		.
	rst 38h			;75d5	ff		.
	rst 38h			;75d6	ff		.
	rst 38h			;75d7	ff		.
	rst 38h			;75d8	ff		.
	rst 38h			;75d9	ff		.
	rst 38h			;75da	ff		.
	rst 38h			;75db	ff		.
	rst 38h			;75dc	ff		.
	rst 38h			;75dd	ff		.
	rst 38h			;75de	ff		.
	rst 38h			;75df	ff		.
	rst 38h			;75e0	ff		.
	rst 38h			;75e1	ff		.
	rst 38h			;75e2	ff		.
	rst 38h			;75e3	ff		.
	rst 38h			;75e4	ff		.
	rst 38h			;75e5	ff		.
	rst 38h			;75e6	ff		.
	rst 38h			;75e7	ff		.
	rst 38h			;75e8	ff		.
	rst 38h			;75e9	ff		.
	rst 38h			;75ea	ff		.
	rst 38h			;75eb	ff		.
	rst 38h			;75ec	ff		.
	rst 38h			;75ed	ff		.
	rst 38h			;75ee	ff		.
	rst 38h			;75ef	ff		.
	rst 38h			;75f0	ff		.
	rst 38h			;75f1	ff		.
	rst 38h			;75f2	ff		.
	rst 38h			;75f3	ff		.
	rst 38h			;75f4	ff		.
	rst 38h			;75f5	ff		.
	rst 38h			;75f6	ff		.
	rst 38h			;75f7	ff		.
	rst 38h			;75f8	ff		.
	rst 38h			;75f9	ff		.
	rst 38h			;75fa	ff		.
	rst 38h			;75fb	ff		.
	rst 38h			;75fc	ff		.
	rst 38h			;75fd	ff		.
	rst 38h			;75fe	ff		.
	rst 38h			;75ff	ff		.
	rst 38h			;7600	ff		.
	rst 38h			;7601	ff		.
	rst 38h			;7602	ff		.
	rst 38h			;7603	ff		.
	rst 38h			;7604	ff		.
	rst 38h			;7605	ff		.
	rst 38h			;7606	ff		.
	rst 38h			;7607	ff		.
	rst 38h			;7608	ff		.
	rst 38h			;7609	ff		.
	rst 38h			;760a	ff		.
	rst 38h			;760b	ff		.
	rst 38h			;760c	ff		.
	rst 38h			;760d	ff		.
	rst 38h			;760e	ff		.
	rst 38h			;760f	ff		.
	rst 38h			;7610	ff		.
	rst 38h			;7611	ff		.
	rst 38h			;7612	ff		.
	rst 38h			;7613	ff		.
	rst 38h			;7614	ff		.
	rst 38h			;7615	ff		.
	rst 38h			;7616	ff		.
	rst 38h			;7617	ff		.
	rst 38h			;7618	ff		.
	rst 38h			;7619	ff		.
	rst 38h			;761a	ff		.
	rst 38h			;761b	ff		.
	rst 38h			;761c	ff		.
	rst 38h			;761d	ff		.
	rst 38h			;761e	ff		.
	rst 38h			;761f	ff		.
	rst 38h			;7620	ff		.
	rst 38h			;7621	ff		.
	rst 38h			;7622	ff		.
	rst 38h			;7623	ff		.
	rst 38h			;7624	ff		.
	rst 38h			;7625	ff		.
	rst 38h			;7626	ff		.
	rst 38h			;7627	ff		.
	rst 38h			;7628	ff		.
	rst 38h			;7629	ff		.
	rst 38h			;762a	ff		.
	rst 38h			;762b	ff		.
	rst 38h			;762c	ff		.
	rst 38h			;762d	ff		.
	rst 38h			;762e	ff		.
	rst 38h			;762f	ff		.
	rst 38h			;7630	ff		.
	rst 38h			;7631	ff		.
	rst 38h			;7632	ff		.
	rst 38h			;7633	ff		.
	rst 38h			;7634	ff		.
	rst 38h			;7635	ff		.
	rst 38h			;7636	ff		.
	rst 38h			;7637	ff		.
	rst 38h			;7638	ff		.
	rst 38h			;7639	ff		.
	rst 38h			;763a	ff		.
	rst 38h			;763b	ff		.
	rst 38h			;763c	ff		.
	rst 38h			;763d	ff		.
	rst 38h			;763e	ff		.
	rst 38h			;763f	ff		.
	rst 38h			;7640	ff		.
	rst 38h			;7641	ff		.
	rst 38h			;7642	ff		.
	rst 38h			;7643	ff		.
	rst 38h			;7644	ff		.
	rst 38h			;7645	ff		.
	rst 38h			;7646	ff		.
	rst 38h			;7647	ff		.
	rst 38h			;7648	ff		.
	rst 38h			;7649	ff		.
	rst 38h			;764a	ff		.
	rst 38h			;764b	ff		.
	rst 38h			;764c	ff		.
	rst 38h			;764d	ff		.
	rst 38h			;764e	ff		.
	rst 38h			;764f	ff		.
	rst 38h			;7650	ff		.
	rst 38h			;7651	ff		.
	rst 38h			;7652	ff		.
	rst 38h			;7653	ff		.
	rst 38h			;7654	ff		.
	rst 38h			;7655	ff		.
	rst 38h			;7656	ff		.
	rst 38h			;7657	ff		.
	rst 38h			;7658	ff		.
	rst 38h			;7659	ff		.
	rst 38h			;765a	ff		.
	rst 38h			;765b	ff		.
	rst 38h			;765c	ff		.
	rst 38h			;765d	ff		.
	rst 38h			;765e	ff		.
	rst 38h			;765f	ff		.
	rst 38h			;7660	ff		.
	rst 38h			;7661	ff		.
	rst 38h			;7662	ff		.
	rst 38h			;7663	ff		.
	rst 38h			;7664	ff		.
	rst 38h			;7665	ff		.
	rst 38h			;7666	ff		.
	rst 38h			;7667	ff		.
	rst 38h			;7668	ff		.
	rst 38h			;7669	ff		.
	rst 38h			;766a	ff		.
	rst 38h			;766b	ff		.
	rst 38h			;766c	ff		.
	rst 38h			;766d	ff		.
	rst 38h			;766e	ff		.
	rst 38h			;766f	ff		.
	rst 38h			;7670	ff		.
	rst 38h			;7671	ff		.
	rst 38h			;7672	ff		.
	rst 38h			;7673	ff		.
	rst 38h			;7674	ff		.
	rst 38h			;7675	ff		.
	rst 38h			;7676	ff		.
	rst 38h			;7677	ff		.
	rst 38h			;7678	ff		.
	rst 38h			;7679	ff		.
	rst 38h			;767a	ff		.
	rst 38h			;767b	ff		.
	rst 38h			;767c	ff		.
	rst 38h			;767d	ff		.
	rst 38h			;767e	ff		.
	rst 38h			;767f	ff		.
	rst 38h			;7680	ff		.
	rst 38h			;7681	ff		.
	rst 38h			;7682	ff		.
	rst 38h			;7683	ff		.
	rst 38h			;7684	ff		.
	rst 38h			;7685	ff		.
	rst 38h			;7686	ff		.
	rst 38h			;7687	ff		.
	rst 38h			;7688	ff		.
	rst 38h			;7689	ff		.
	rst 38h			;768a	ff		.
	rst 38h			;768b	ff		.
	rst 38h			;768c	ff		.
	rst 38h			;768d	ff		.
	rst 38h			;768e	ff		.
	rst 38h			;768f	ff		.
	rst 38h			;7690	ff		.
	rst 38h			;7691	ff		.
	rst 38h			;7692	ff		.
	rst 38h			;7693	ff		.
	rst 38h			;7694	ff		.
	rst 38h			;7695	ff		.
	rst 38h			;7696	ff		.
	rst 38h			;7697	ff		.
	rst 38h			;7698	ff		.
	rst 38h			;7699	ff		.
	rst 38h			;769a	ff		.
	rst 38h			;769b	ff		.
	rst 38h			;769c	ff		.
	rst 38h			;769d	ff		.
	rst 38h			;769e	ff		.
	rst 38h			;769f	ff		.
	rst 38h			;76a0	ff		.
	rst 38h			;76a1	ff		.
	rst 38h			;76a2	ff		.
	rst 38h			;76a3	ff		.
	rst 38h			;76a4	ff		.
	rst 38h			;76a5	ff		.
	rst 38h			;76a6	ff		.
	rst 38h			;76a7	ff		.
	rst 38h			;76a8	ff		.
	rst 38h			;76a9	ff		.
	rst 38h			;76aa	ff		.
	rst 38h			;76ab	ff		.
	rst 38h			;76ac	ff		.
	rst 38h			;76ad	ff		.
	rst 38h			;76ae	ff		.
	rst 38h			;76af	ff		.
	rst 38h			;76b0	ff		.
	rst 38h			;76b1	ff		.
	rst 38h			;76b2	ff		.
	rst 38h			;76b3	ff		.
	rst 38h			;76b4	ff		.
	rst 38h			;76b5	ff		.
	rst 38h			;76b6	ff		.
	rst 38h			;76b7	ff		.
	rst 38h			;76b8	ff		.
	rst 38h			;76b9	ff		.
	rst 38h			;76ba	ff		.
	rst 38h			;76bb	ff		.
	rst 38h			;76bc	ff		.
	rst 38h			;76bd	ff		.
	rst 38h			;76be	ff		.
	rst 38h			;76bf	ff		.
	rst 38h			;76c0	ff		.
	rst 38h			;76c1	ff		.
	rst 38h			;76c2	ff		.
	rst 38h			;76c3	ff		.
	rst 38h			;76c4	ff		.
	rst 38h			;76c5	ff		.
	rst 38h			;76c6	ff		.
	rst 38h			;76c7	ff		.
	rst 38h			;76c8	ff		.
	rst 38h			;76c9	ff		.
	rst 38h			;76ca	ff		.
	rst 38h			;76cb	ff		.
	rst 38h			;76cc	ff		.
	rst 38h			;76cd	ff		.
	rst 38h			;76ce	ff		.
	rst 38h			;76cf	ff		.
	rst 38h			;76d0	ff		.
	rst 38h			;76d1	ff		.
	rst 38h			;76d2	ff		.
	rst 38h			;76d3	ff		.
	rst 38h			;76d4	ff		.
	rst 38h			;76d5	ff		.
	rst 38h			;76d6	ff		.
	rst 38h			;76d7	ff		.
	rst 38h			;76d8	ff		.
	rst 38h			;76d9	ff		.
	rst 38h			;76da	ff		.
	rst 38h			;76db	ff		.
	rst 38h			;76dc	ff		.
	rst 38h			;76dd	ff		.
	rst 38h			;76de	ff		.
	rst 38h			;76df	ff		.
	rst 38h			;76e0	ff		.
	rst 38h			;76e1	ff		.
	rst 38h			;76e2	ff		.
	rst 38h			;76e3	ff		.
	rst 38h			;76e4	ff		.
	rst 38h			;76e5	ff		.
	rst 38h			;76e6	ff		.
	rst 38h			;76e7	ff		.
	rst 38h			;76e8	ff		.
	rst 38h			;76e9	ff		.
	rst 38h			;76ea	ff		.
	rst 38h			;76eb	ff		.
	rst 38h			;76ec	ff		.
	rst 38h			;76ed	ff		.
	rst 38h			;76ee	ff		.
	rst 38h			;76ef	ff		.
	rst 38h			;76f0	ff		.
	rst 38h			;76f1	ff		.
	rst 38h			;76f2	ff		.
	rst 38h			;76f3	ff		.
	rst 38h			;76f4	ff		.
	rst 38h			;76f5	ff		.
	rst 38h			;76f6	ff		.
	rst 38h			;76f7	ff		.
	rst 38h			;76f8	ff		.
	rst 38h			;76f9	ff		.
	rst 38h			;76fa	ff		.
	rst 38h			;76fb	ff		.
	rst 38h			;76fc	ff		.
	rst 38h			;76fd	ff		.
	rst 38h			;76fe	ff		.
	rst 38h			;76ff	ff		.
	rst 38h			;7700	ff		.
	rst 38h			;7701	ff		.
	rst 38h			;7702	ff		.
	rst 38h			;7703	ff		.
	rst 38h			;7704	ff		.
	rst 38h			;7705	ff		.
	rst 38h			;7706	ff		.
	rst 38h			;7707	ff		.
	rst 38h			;7708	ff		.
	rst 38h			;7709	ff		.
	rst 38h			;770a	ff		.
	rst 38h			;770b	ff		.
	rst 38h			;770c	ff		.
	rst 38h			;770d	ff		.
	rst 38h			;770e	ff		.
	rst 38h			;770f	ff		.
	rst 38h			;7710	ff		.
	rst 38h			;7711	ff		.
	rst 38h			;7712	ff		.
	rst 38h			;7713	ff		.
	rst 38h			;7714	ff		.
	rst 38h			;7715	ff		.
	rst 38h			;7716	ff		.
	rst 38h			;7717	ff		.
	rst 38h			;7718	ff		.
	rst 38h			;7719	ff		.
	rst 38h			;771a	ff		.
	rst 38h			;771b	ff		.
	rst 38h			;771c	ff		.
	rst 38h			;771d	ff		.
	rst 38h			;771e	ff		.
	rst 38h			;771f	ff		.
	rst 38h			;7720	ff		.
	rst 38h			;7721	ff		.
	rst 38h			;7722	ff		.
	rst 38h			;7723	ff		.
	rst 38h			;7724	ff		.
	rst 38h			;7725	ff		.
	rst 38h			;7726	ff		.
	rst 38h			;7727	ff		.
	rst 38h			;7728	ff		.
	rst 38h			;7729	ff		.
	rst 38h			;772a	ff		.
	rst 38h			;772b	ff		.
	rst 38h			;772c	ff		.
	rst 38h			;772d	ff		.
	rst 38h			;772e	ff		.
	rst 38h			;772f	ff		.
	rst 38h			;7730	ff		.
	rst 38h			;7731	ff		.
	rst 38h			;7732	ff		.
	rst 38h			;7733	ff		.
	rst 38h			;7734	ff		.
	rst 38h			;7735	ff		.
	rst 38h			;7736	ff		.
	rst 38h			;7737	ff		.
	rst 38h			;7738	ff		.
	rst 38h			;7739	ff		.
	rst 38h			;773a	ff		.
	rst 38h			;773b	ff		.
	rst 38h			;773c	ff		.
	rst 38h			;773d	ff		.
	rst 38h			;773e	ff		.
	rst 38h			;773f	ff		.
	rst 38h			;7740	ff		.
	rst 38h			;7741	ff		.
	rst 38h			;7742	ff		.
	rst 38h			;7743	ff		.
	rst 38h			;7744	ff		.
	rst 38h			;7745	ff		.
	rst 38h			;7746	ff		.
	rst 38h			;7747	ff		.
	rst 38h			;7748	ff		.
	rst 38h			;7749	ff		.
	rst 38h			;774a	ff		.
	rst 38h			;774b	ff		.
	rst 38h			;774c	ff		.
	rst 38h			;774d	ff		.
	rst 38h			;774e	ff		.
	rst 38h			;774f	ff		.
	rst 38h			;7750	ff		.
	rst 38h			;7751	ff		.
	rst 38h			;7752	ff		.
	rst 38h			;7753	ff		.
	rst 38h			;7754	ff		.
	rst 38h			;7755	ff		.
	rst 38h			;7756	ff		.
	rst 38h			;7757	ff		.
	rst 38h			;7758	ff		.
	rst 38h			;7759	ff		.
	rst 38h			;775a	ff		.
	rst 38h			;775b	ff		.
	rst 38h			;775c	ff		.
	rst 38h			;775d	ff		.
	rst 38h			;775e	ff		.
	rst 38h			;775f	ff		.
	rst 38h			;7760	ff		.
	rst 38h			;7761	ff		.
	rst 38h			;7762	ff		.
	rst 38h			;7763	ff		.
	rst 38h			;7764	ff		.
	rst 38h			;7765	ff		.
	rst 38h			;7766	ff		.
	rst 38h			;7767	ff		.
	rst 38h			;7768	ff		.
	rst 38h			;7769	ff		.
	rst 38h			;776a	ff		.
	rst 38h			;776b	ff		.
	rst 38h			;776c	ff		.
	rst 38h			;776d	ff		.
	rst 38h			;776e	ff		.
	rst 38h			;776f	ff		.
	rst 38h			;7770	ff		.
	rst 38h			;7771	ff		.
	rst 38h			;7772	ff		.
	rst 38h			;7773	ff		.
	rst 38h			;7774	ff		.
	rst 38h			;7775	ff		.
	rst 38h			;7776	ff		.
	rst 38h			;7777	ff		.
	rst 38h			;7778	ff		.
	rst 38h			;7779	ff		.
	rst 38h			;777a	ff		.
	rst 38h			;777b	ff		.
	rst 38h			;777c	ff		.
	rst 38h			;777d	ff		.
	rst 38h			;777e	ff		.
	rst 38h			;777f	ff		.
	rst 38h			;7780	ff		.
	rst 38h			;7781	ff		.
	rst 38h			;7782	ff		.
	rst 38h			;7783	ff		.
	rst 38h			;7784	ff		.
	rst 38h			;7785	ff		.
	rst 38h			;7786	ff		.
	rst 38h			;7787	ff		.
	rst 38h			;7788	ff		.
	rst 38h			;7789	ff		.
	rst 38h			;778a	ff		.
	rst 38h			;778b	ff		.
	rst 38h			;778c	ff		.
	rst 38h			;778d	ff		.
	rst 38h			;778e	ff		.
	rst 38h			;778f	ff		.
	rst 38h			;7790	ff		.
	rst 38h			;7791	ff		.
	rst 38h			;7792	ff		.
	rst 38h			;7793	ff		.
	rst 38h			;7794	ff		.
	rst 38h			;7795	ff		.
	rst 38h			;7796	ff		.
	rst 38h			;7797	ff		.
	rst 38h			;7798	ff		.
	rst 38h			;7799	ff		.
	rst 38h			;779a	ff		.
	rst 38h			;779b	ff		.
	rst 38h			;779c	ff		.
	rst 38h			;779d	ff		.
	rst 38h			;779e	ff		.
	rst 38h			;779f	ff		.
	rst 38h			;77a0	ff		.
	rst 38h			;77a1	ff		.
	rst 38h			;77a2	ff		.
	rst 38h			;77a3	ff		.
	rst 38h			;77a4	ff		.
	rst 38h			;77a5	ff		.
	rst 38h			;77a6	ff		.
	rst 38h			;77a7	ff		.
	rst 38h			;77a8	ff		.
	rst 38h			;77a9	ff		.
	rst 38h			;77aa	ff		.
	rst 38h			;77ab	ff		.
	rst 38h			;77ac	ff		.
	rst 38h			;77ad	ff		.
	rst 38h			;77ae	ff		.
	rst 38h			;77af	ff		.
	rst 38h			;77b0	ff		.
	rst 38h			;77b1	ff		.
	rst 38h			;77b2	ff		.
	rst 38h			;77b3	ff		.
	rst 38h			;77b4	ff		.
	rst 38h			;77b5	ff		.
	rst 38h			;77b6	ff		.
	rst 38h			;77b7	ff		.
	rst 38h			;77b8	ff		.
	rst 38h			;77b9	ff		.
	rst 38h			;77ba	ff		.
	rst 38h			;77bb	ff		.
	rst 38h			;77bc	ff		.
	rst 38h			;77bd	ff		.
	rst 38h			;77be	ff		.
	rst 38h			;77bf	ff		.
	rst 38h			;77c0	ff		.
	rst 38h			;77c1	ff		.
	rst 38h			;77c2	ff		.
	rst 38h			;77c3	ff		.
	rst 38h			;77c4	ff		.
	rst 38h			;77c5	ff		.
	rst 38h			;77c6	ff		.
	rst 38h			;77c7	ff		.
	rst 38h			;77c8	ff		.
	rst 38h			;77c9	ff		.
	rst 38h			;77ca	ff		.
	rst 38h			;77cb	ff		.
	rst 38h			;77cc	ff		.
	rst 38h			;77cd	ff		.
	rst 38h			;77ce	ff		.
	rst 38h			;77cf	ff		.
	rst 38h			;77d0	ff		.
	rst 38h			;77d1	ff		.
	rst 38h			;77d2	ff		.
	rst 38h			;77d3	ff		.
	rst 38h			;77d4	ff		.
	rst 38h			;77d5	ff		.
	rst 38h			;77d6	ff		.
	rst 38h			;77d7	ff		.
	rst 38h			;77d8	ff		.
	rst 38h			;77d9	ff		.
	rst 38h			;77da	ff		.
	rst 38h			;77db	ff		.
	rst 38h			;77dc	ff		.
	rst 38h			;77dd	ff		.
	rst 38h			;77de	ff		.
	rst 38h			;77df	ff		.
	rst 38h			;77e0	ff		.
	rst 38h			;77e1	ff		.
	rst 38h			;77e2	ff		.
	rst 38h			;77e3	ff		.
	rst 38h			;77e4	ff		.
	rst 38h			;77e5	ff		.
	rst 38h			;77e6	ff		.
	rst 38h			;77e7	ff		.
	rst 38h			;77e8	ff		.
	rst 38h			;77e9	ff		.
	rst 38h			;77ea	ff		.
	rst 38h			;77eb	ff		.
	rst 38h			;77ec	ff		.
	rst 38h			;77ed	ff		.
	rst 38h			;77ee	ff		.
	rst 38h			;77ef	ff		.
	rst 38h			;77f0	ff		.
	rst 38h			;77f1	ff		.
	rst 38h			;77f2	ff		.
	rst 38h			;77f3	ff		.
	rst 38h			;77f4	ff		.
	rst 38h			;77f5	ff		.
	rst 38h			;77f6	ff		.
	rst 38h			;77f7	ff		.
	rst 38h			;77f8	ff		.
	rst 38h			;77f9	ff		.
	rst 38h			;77fa	ff		.
	rst 38h			;77fb	ff		.
	rst 38h			;77fc	ff		.
	rst 38h			;77fd	ff		.
	rst 38h			;77fe	ff		.
	rst 38h			;77ff	ff		.
	rst 38h			;7800	ff		.
	rst 38h			;7801	ff		.
	rst 38h			;7802	ff		.
	rst 38h			;7803	ff		.
	rst 38h			;7804	ff		.
	rst 38h			;7805	ff		.
	rst 38h			;7806	ff		.
	rst 38h			;7807	ff		.
	rst 38h			;7808	ff		.
	rst 38h			;7809	ff		.
	rst 38h			;780a	ff		.
	rst 38h			;780b	ff		.
	rst 38h			;780c	ff		.
	rst 38h			;780d	ff		.
	rst 38h			;780e	ff		.
	rst 38h			;780f	ff		.
	rst 38h			;7810	ff		.
	rst 38h			;7811	ff		.
	rst 38h			;7812	ff		.
	rst 38h			;7813	ff		.
	rst 38h			;7814	ff		.
	rst 38h			;7815	ff		.
	rst 38h			;7816	ff		.
	rst 38h			;7817	ff		.
	rst 38h			;7818	ff		.
	rst 38h			;7819	ff		.
	rst 38h			;781a	ff		.
	rst 38h			;781b	ff		.
	rst 38h			;781c	ff		.
	rst 38h			;781d	ff		.
	rst 38h			;781e	ff		.
	rst 38h			;781f	ff		.
	rst 38h			;7820	ff		.
	rst 38h			;7821	ff		.
	rst 38h			;7822	ff		.
	rst 38h			;7823	ff		.
	rst 38h			;7824	ff		.
	rst 38h			;7825	ff		.
	rst 38h			;7826	ff		.
	rst 38h			;7827	ff		.
	rst 38h			;7828	ff		.
	rst 38h			;7829	ff		.
	rst 38h			;782a	ff		.
	rst 38h			;782b	ff		.
	rst 38h			;782c	ff		.
	rst 38h			;782d	ff		.
	rst 38h			;782e	ff		.
	rst 38h			;782f	ff		.
	rst 38h			;7830	ff		.
	rst 38h			;7831	ff		.
	rst 38h			;7832	ff		.
	rst 38h			;7833	ff		.
	rst 38h			;7834	ff		.
	rst 38h			;7835	ff		.
	rst 38h			;7836	ff		.
	rst 38h			;7837	ff		.
	rst 38h			;7838	ff		.
	rst 38h			;7839	ff		.
	rst 38h			;783a	ff		.
	rst 38h			;783b	ff		.
	rst 38h			;783c	ff		.
	rst 38h			;783d	ff		.
	rst 38h			;783e	ff		.
	rst 38h			;783f	ff		.
	rst 38h			;7840	ff		.
	rst 38h			;7841	ff		.
	rst 38h			;7842	ff		.
	rst 38h			;7843	ff		.
	rst 38h			;7844	ff		.
	rst 38h			;7845	ff		.
	rst 38h			;7846	ff		.
	rst 38h			;7847	ff		.
	rst 38h			;7848	ff		.
	rst 38h			;7849	ff		.
	rst 38h			;784a	ff		.
	rst 38h			;784b	ff		.
	rst 38h			;784c	ff		.
	rst 38h			;784d	ff		.
	rst 38h			;784e	ff		.
	rst 38h			;784f	ff		.
	rst 38h			;7850	ff		.
	rst 38h			;7851	ff		.
	rst 38h			;7852	ff		.
	rst 38h			;7853	ff		.
	rst 38h			;7854	ff		.
	rst 38h			;7855	ff		.
	rst 38h			;7856	ff		.
	rst 38h			;7857	ff		.
	rst 38h			;7858	ff		.
	rst 38h			;7859	ff		.
	rst 38h			;785a	ff		.
	rst 38h			;785b	ff		.
	rst 38h			;785c	ff		.
	rst 38h			;785d	ff		.
	rst 38h			;785e	ff		.
	rst 38h			;785f	ff		.
	rst 38h			;7860	ff		.
	rst 38h			;7861	ff		.
	rst 38h			;7862	ff		.
	rst 38h			;7863	ff		.
	rst 38h			;7864	ff		.
	rst 38h			;7865	ff		.
	rst 38h			;7866	ff		.
	rst 38h			;7867	ff		.
	rst 38h			;7868	ff		.
	rst 38h			;7869	ff		.
	rst 38h			;786a	ff		.
	rst 38h			;786b	ff		.
	rst 38h			;786c	ff		.
	rst 38h			;786d	ff		.
	rst 38h			;786e	ff		.
	rst 38h			;786f	ff		.
	rst 38h			;7870	ff		.
	rst 38h			;7871	ff		.
	rst 38h			;7872	ff		.
	rst 38h			;7873	ff		.
	rst 38h			;7874	ff		.
	rst 38h			;7875	ff		.
	rst 38h			;7876	ff		.
	rst 38h			;7877	ff		.
	rst 38h			;7878	ff		.
	rst 38h			;7879	ff		.
	rst 38h			;787a	ff		.
	rst 38h			;787b	ff		.
	rst 38h			;787c	ff		.
	rst 38h			;787d	ff		.
	rst 38h			;787e	ff		.
	rst 38h			;787f	ff		.
	rst 38h			;7880	ff		.
	rst 38h			;7881	ff		.
	rst 38h			;7882	ff		.
	rst 38h			;7883	ff		.
	rst 38h			;7884	ff		.
	rst 38h			;7885	ff		.
	rst 38h			;7886	ff		.
	rst 38h			;7887	ff		.
	rst 38h			;7888	ff		.
	rst 38h			;7889	ff		.
	rst 38h			;788a	ff		.
	rst 38h			;788b	ff		.
	rst 38h			;788c	ff		.
	rst 38h			;788d	ff		.
	rst 38h			;788e	ff		.
	rst 38h			;788f	ff		.
	rst 38h			;7890	ff		.
	rst 38h			;7891	ff		.
	rst 38h			;7892	ff		.
	rst 38h			;7893	ff		.
	rst 38h			;7894	ff		.
	rst 38h			;7895	ff		.
	rst 38h			;7896	ff		.
	rst 38h			;7897	ff		.
	rst 38h			;7898	ff		.
	rst 38h			;7899	ff		.
	rst 38h			;789a	ff		.
	rst 38h			;789b	ff		.
	rst 38h			;789c	ff		.
	rst 38h			;789d	ff		.
	rst 38h			;789e	ff		.
	rst 38h			;789f	ff		.
	rst 38h			;78a0	ff		.
	rst 38h			;78a1	ff		.
	rst 38h			;78a2	ff		.
	rst 38h			;78a3	ff		.
	rst 38h			;78a4	ff		.
	rst 38h			;78a5	ff		.
	rst 38h			;78a6	ff		.
	rst 38h			;78a7	ff		.
	rst 38h			;78a8	ff		.
	rst 38h			;78a9	ff		.
	rst 38h			;78aa	ff		.
	rst 38h			;78ab	ff		.
	rst 38h			;78ac	ff		.
	rst 38h			;78ad	ff		.
	rst 38h			;78ae	ff		.
	rst 38h			;78af	ff		.
	rst 38h			;78b0	ff		.
	rst 38h			;78b1	ff		.
	rst 38h			;78b2	ff		.
	rst 38h			;78b3	ff		.
	rst 38h			;78b4	ff		.
	rst 38h			;78b5	ff		.
	rst 38h			;78b6	ff		.
	rst 38h			;78b7	ff		.
	rst 38h			;78b8	ff		.
	rst 38h			;78b9	ff		.
	rst 38h			;78ba	ff		.
	rst 38h			;78bb	ff		.
	rst 38h			;78bc	ff		.
	rst 38h			;78bd	ff		.
	rst 38h			;78be	ff		.
	rst 38h			;78bf	ff		.
	rst 38h			;78c0	ff		.
	rst 38h			;78c1	ff		.
	rst 38h			;78c2	ff		.
	rst 38h			;78c3	ff		.
	rst 38h			;78c4	ff		.
	rst 38h			;78c5	ff		.
	rst 38h			;78c6	ff		.
	rst 38h			;78c7	ff		.
	rst 38h			;78c8	ff		.
	rst 38h			;78c9	ff		.
	rst 38h			;78ca	ff		.
	rst 38h			;78cb	ff		.
	rst 38h			;78cc	ff		.
	rst 38h			;78cd	ff		.
	rst 38h			;78ce	ff		.
	rst 38h			;78cf	ff		.
	rst 38h			;78d0	ff		.
	rst 38h			;78d1	ff		.
	rst 38h			;78d2	ff		.
	rst 38h			;78d3	ff		.
	rst 38h			;78d4	ff		.
	rst 38h			;78d5	ff		.
	rst 38h			;78d6	ff		.
	rst 38h			;78d7	ff		.
	rst 38h			;78d8	ff		.
	rst 38h			;78d9	ff		.
	rst 38h			;78da	ff		.
	rst 38h			;78db	ff		.
	rst 38h			;78dc	ff		.
	rst 38h			;78dd	ff		.
	rst 38h			;78de	ff		.
	rst 38h			;78df	ff		.
	rst 38h			;78e0	ff		.
	rst 38h			;78e1	ff		.
	rst 38h			;78e2	ff		.
	rst 38h			;78e3	ff		.
	rst 38h			;78e4	ff		.
	rst 38h			;78e5	ff		.
	rst 38h			;78e6	ff		.
	rst 38h			;78e7	ff		.
	rst 38h			;78e8	ff		.
	rst 38h			;78e9	ff		.
	rst 38h			;78ea	ff		.
	rst 38h			;78eb	ff		.
	rst 38h			;78ec	ff		.
	rst 38h			;78ed	ff		.
	rst 38h			;78ee	ff		.
	rst 38h			;78ef	ff		.
	rst 38h			;78f0	ff		.
	rst 38h			;78f1	ff		.
	rst 38h			;78f2	ff		.
	rst 38h			;78f3	ff		.
	rst 38h			;78f4	ff		.
	rst 38h			;78f5	ff		.
	rst 38h			;78f6	ff		.
	rst 38h			;78f7	ff		.
l78f8h:
	rst 38h			;78f8	ff		.
	rst 38h			;78f9	ff		.
	rst 38h			;78fa	ff		.
	rst 38h			;78fb	ff		.
	rst 38h			;78fc	ff		.
	rst 38h			;78fd	ff		.
	rst 38h			;78fe	ff		.
	rst 38h			;78ff	ff		.
	rst 38h			;7900	ff		.
	rst 38h			;7901	ff		.
	rst 38h			;7902	ff		.
	rst 38h			;7903	ff		.
	rst 38h			;7904	ff		.
	rst 38h			;7905	ff		.
	rst 38h			;7906	ff		.
	rst 38h			;7907	ff		.
	rst 38h			;7908	ff		.
	rst 38h			;7909	ff		.
	rst 38h			;790a	ff		.
	rst 38h			;790b	ff		.
	rst 38h			;790c	ff		.
	rst 38h			;790d	ff		.
	rst 38h			;790e	ff		.
	rst 38h			;790f	ff		.
	rst 38h			;7910	ff		.
	rst 38h			;7911	ff		.
	rst 38h			;7912	ff		.
	rst 38h			;7913	ff		.
	rst 38h			;7914	ff		.
	rst 38h			;7915	ff		.
	rst 38h			;7916	ff		.
	rst 38h			;7917	ff		.
	rst 38h			;7918	ff		.
	rst 38h			;7919	ff		.
	rst 38h			;791a	ff		.
	rst 38h			;791b	ff		.
	rst 38h			;791c	ff		.
	rst 38h			;791d	ff		.
	rst 38h			;791e	ff		.
	rst 38h			;791f	ff		.
	rst 38h			;7920	ff		.
	rst 38h			;7921	ff		.
	rst 38h			;7922	ff		.
	rst 38h			;7923	ff		.
	rst 38h			;7924	ff		.
	rst 38h			;7925	ff		.
	rst 38h			;7926	ff		.
	rst 38h			;7927	ff		.
	rst 38h			;7928	ff		.
	rst 38h			;7929	ff		.
	rst 38h			;792a	ff		.
	rst 38h			;792b	ff		.
	rst 38h			;792c	ff		.
	rst 38h			;792d	ff		.
	rst 38h			;792e	ff		.
	rst 38h			;792f	ff		.
	rst 38h			;7930	ff		.
	rst 38h			;7931	ff		.
	rst 38h			;7932	ff		.
	rst 38h			;7933	ff		.
	rst 38h			;7934	ff		.
	rst 38h			;7935	ff		.
	rst 38h			;7936	ff		.
	rst 38h			;7937	ff		.
	rst 38h			;7938	ff		.
	rst 38h			;7939	ff		.
	rst 38h			;793a	ff		.
	rst 38h			;793b	ff		.
	rst 38h			;793c	ff		.
	rst 38h			;793d	ff		.
	rst 38h			;793e	ff		.
	rst 38h			;793f	ff		.
	rst 38h			;7940	ff		.
	rst 38h			;7941	ff		.
	rst 38h			;7942	ff		.
	rst 38h			;7943	ff		.
	rst 38h			;7944	ff		.
	rst 38h			;7945	ff		.
	rst 38h			;7946	ff		.
	rst 38h			;7947	ff		.
	rst 38h			;7948	ff		.
	rst 38h			;7949	ff		.
	rst 38h			;794a	ff		.
	rst 38h			;794b	ff		.
	rst 38h			;794c	ff		.
	rst 38h			;794d	ff		.
	rst 38h			;794e	ff		.
	rst 38h			;794f	ff		.
	rst 38h			;7950	ff		.
	rst 38h			;7951	ff		.
	rst 38h			;7952	ff		.
	rst 38h			;7953	ff		.
	rst 38h			;7954	ff		.
	rst 38h			;7955	ff		.
	rst 38h			;7956	ff		.
	rst 38h			;7957	ff		.
	rst 38h			;7958	ff		.
	rst 38h			;7959	ff		.
	rst 38h			;795a	ff		.
	rst 38h			;795b	ff		.
	rst 38h			;795c	ff		.
	rst 38h			;795d	ff		.
	rst 38h			;795e	ff		.
	rst 38h			;795f	ff		.
	rst 38h			;7960	ff		.
	rst 38h			;7961	ff		.
	rst 38h			;7962	ff		.
	rst 38h			;7963	ff		.
	rst 38h			;7964	ff		.
	rst 38h			;7965	ff		.
	rst 38h			;7966	ff		.
	rst 38h			;7967	ff		.
	rst 38h			;7968	ff		.
	rst 38h			;7969	ff		.
	rst 38h			;796a	ff		.
	rst 38h			;796b	ff		.
	rst 38h			;796c	ff		.
	rst 38h			;796d	ff		.
	rst 38h			;796e	ff		.
	rst 38h			;796f	ff		.
	rst 38h			;7970	ff		.
	rst 38h			;7971	ff		.
	rst 38h			;7972	ff		.
	rst 38h			;7973	ff		.
	rst 38h			;7974	ff		.
	rst 38h			;7975	ff		.
	rst 38h			;7976	ff		.
	rst 38h			;7977	ff		.
	rst 38h			;7978	ff		.
	rst 38h			;7979	ff		.
	rst 38h			;797a	ff		.
	rst 38h			;797b	ff		.
	rst 38h			;797c	ff		.
	rst 38h			;797d	ff		.
	rst 38h			;797e	ff		.
	rst 38h			;797f	ff		.
	rst 38h			;7980	ff		.
	rst 38h			;7981	ff		.
	rst 38h			;7982	ff		.
	rst 38h			;7983	ff		.
	rst 38h			;7984	ff		.
	rst 38h			;7985	ff		.
	rst 38h			;7986	ff		.
	rst 38h			;7987	ff		.
	rst 38h			;7988	ff		.
	rst 38h			;7989	ff		.
	rst 38h			;798a	ff		.
	rst 38h			;798b	ff		.
	rst 38h			;798c	ff		.
	rst 38h			;798d	ff		.
	rst 38h			;798e	ff		.
	rst 38h			;798f	ff		.
	rst 38h			;7990	ff		.
	rst 38h			;7991	ff		.
	rst 38h			;7992	ff		.
	rst 38h			;7993	ff		.
	rst 38h			;7994	ff		.
	rst 38h			;7995	ff		.
	rst 38h			;7996	ff		.
	rst 38h			;7997	ff		.
	rst 38h			;7998	ff		.
	rst 38h			;7999	ff		.
	rst 38h			;799a	ff		.
	rst 38h			;799b	ff		.
	rst 38h			;799c	ff		.
	rst 38h			;799d	ff		.
	rst 38h			;799e	ff		.
	rst 38h			;799f	ff		.
	rst 38h			;79a0	ff		.
	rst 38h			;79a1	ff		.
	rst 38h			;79a2	ff		.
	rst 38h			;79a3	ff		.
	rst 38h			;79a4	ff		.
	rst 38h			;79a5	ff		.
	rst 38h			;79a6	ff		.
	rst 38h			;79a7	ff		.
	rst 38h			;79a8	ff		.
	rst 38h			;79a9	ff		.
	rst 38h			;79aa	ff		.
	rst 38h			;79ab	ff		.
	rst 38h			;79ac	ff		.
	rst 38h			;79ad	ff		.
	rst 38h			;79ae	ff		.
	rst 38h			;79af	ff		.
	rst 38h			;79b0	ff		.
	rst 38h			;79b1	ff		.
	rst 38h			;79b2	ff		.
	rst 38h			;79b3	ff		.
	rst 38h			;79b4	ff		.
	rst 38h			;79b5	ff		.
	rst 38h			;79b6	ff		.
	rst 38h			;79b7	ff		.
	rst 38h			;79b8	ff		.
	rst 38h			;79b9	ff		.
	rst 38h			;79ba	ff		.
	rst 38h			;79bb	ff		.
	rst 38h			;79bc	ff		.
	rst 38h			;79bd	ff		.
	rst 38h			;79be	ff		.
	rst 38h			;79bf	ff		.
	rst 38h			;79c0	ff		.
	rst 38h			;79c1	ff		.
	rst 38h			;79c2	ff		.
	rst 38h			;79c3	ff		.
	rst 38h			;79c4	ff		.
	rst 38h			;79c5	ff		.
	rst 38h			;79c6	ff		.
	rst 38h			;79c7	ff		.
	rst 38h			;79c8	ff		.
	rst 38h			;79c9	ff		.
	rst 38h			;79ca	ff		.
	rst 38h			;79cb	ff		.
	rst 38h			;79cc	ff		.
	rst 38h			;79cd	ff		.
	rst 38h			;79ce	ff		.
	rst 38h			;79cf	ff		.
	rst 38h			;79d0	ff		.
	rst 38h			;79d1	ff		.
	rst 38h			;79d2	ff		.
	rst 38h			;79d3	ff		.
	rst 38h			;79d4	ff		.
	rst 38h			;79d5	ff		.
	rst 38h			;79d6	ff		.
	rst 38h			;79d7	ff		.
	rst 38h			;79d8	ff		.
	rst 38h			;79d9	ff		.
	rst 38h			;79da	ff		.
	rst 38h			;79db	ff		.
	rst 38h			;79dc	ff		.
	rst 38h			;79dd	ff		.
	rst 38h			;79de	ff		.
	rst 38h			;79df	ff		.
	rst 38h			;79e0	ff		.
	rst 38h			;79e1	ff		.
	rst 38h			;79e2	ff		.
	rst 38h			;79e3	ff		.
	rst 38h			;79e4	ff		.
	rst 38h			;79e5	ff		.
	rst 38h			;79e6	ff		.
	rst 38h			;79e7	ff		.
	rst 38h			;79e8	ff		.
	rst 38h			;79e9	ff		.
	rst 38h			;79ea	ff		.
	rst 38h			;79eb	ff		.
	rst 38h			;79ec	ff		.
	rst 38h			;79ed	ff		.
	rst 38h			;79ee	ff		.
	rst 38h			;79ef	ff		.
	rst 38h			;79f0	ff		.
	rst 38h			;79f1	ff		.
	rst 38h			;79f2	ff		.
	rst 38h			;79f3	ff		.
	rst 38h			;79f4	ff		.
	rst 38h			;79f5	ff		.
	rst 38h			;79f6	ff		.
	rst 38h			;79f7	ff		.
	rst 38h			;79f8	ff		.
	rst 38h			;79f9	ff		.
	rst 38h			;79fa	ff		.
	rst 38h			;79fb	ff		.
	rst 38h			;79fc	ff		.
	rst 38h			;79fd	ff		.
	rst 38h			;79fe	ff		.
	rst 38h			;79ff	ff		.
	rst 38h			;7a00	ff		.
	rst 38h			;7a01	ff		.
	rst 38h			;7a02	ff		.
	rst 38h			;7a03	ff		.
	rst 38h			;7a04	ff		.
	rst 38h			;7a05	ff		.
	rst 38h			;7a06	ff		.
	rst 38h			;7a07	ff		.
	rst 38h			;7a08	ff		.
	rst 38h			;7a09	ff		.
	rst 38h			;7a0a	ff		.
	rst 38h			;7a0b	ff		.
	rst 38h			;7a0c	ff		.
	rst 38h			;7a0d	ff		.
	rst 38h			;7a0e	ff		.
	rst 38h			;7a0f	ff		.
	rst 38h			;7a10	ff		.
	rst 38h			;7a11	ff		.
	rst 38h			;7a12	ff		.
	rst 38h			;7a13	ff		.
	rst 38h			;7a14	ff		.
	rst 38h			;7a15	ff		.
	rst 38h			;7a16	ff		.
	rst 38h			;7a17	ff		.
	rst 38h			;7a18	ff		.
	rst 38h			;7a19	ff		.
	rst 38h			;7a1a	ff		.
	rst 38h			;7a1b	ff		.
	rst 38h			;7a1c	ff		.
	rst 38h			;7a1d	ff		.
	rst 38h			;7a1e	ff		.
	rst 38h			;7a1f	ff		.
	rst 38h			;7a20	ff		.
	rst 38h			;7a21	ff		.
	rst 38h			;7a22	ff		.
	rst 38h			;7a23	ff		.
	rst 38h			;7a24	ff		.
	rst 38h			;7a25	ff		.
	rst 38h			;7a26	ff		.
	rst 38h			;7a27	ff		.
	rst 38h			;7a28	ff		.
	rst 38h			;7a29	ff		.
	rst 38h			;7a2a	ff		.
	rst 38h			;7a2b	ff		.
	rst 38h			;7a2c	ff		.
	rst 38h			;7a2d	ff		.
	rst 38h			;7a2e	ff		.
	rst 38h			;7a2f	ff		.
	rst 38h			;7a30	ff		.
	rst 38h			;7a31	ff		.
	rst 38h			;7a32	ff		.
	rst 38h			;7a33	ff		.
	rst 38h			;7a34	ff		.
	rst 38h			;7a35	ff		.
	rst 38h			;7a36	ff		.
	rst 38h			;7a37	ff		.
	rst 38h			;7a38	ff		.
	rst 38h			;7a39	ff		.
	rst 38h			;7a3a	ff		.
	rst 38h			;7a3b	ff		.
	rst 38h			;7a3c	ff		.
	rst 38h			;7a3d	ff		.
	rst 38h			;7a3e	ff		.
	rst 38h			;7a3f	ff		.
	rst 38h			;7a40	ff		.
	rst 38h			;7a41	ff		.
	rst 38h			;7a42	ff		.
	rst 38h			;7a43	ff		.
	rst 38h			;7a44	ff		.
	rst 38h			;7a45	ff		.
	rst 38h			;7a46	ff		.
	rst 38h			;7a47	ff		.
	rst 38h			;7a48	ff		.
	rst 38h			;7a49	ff		.
	rst 38h			;7a4a	ff		.
	rst 38h			;7a4b	ff		.
	rst 38h			;7a4c	ff		.
	rst 38h			;7a4d	ff		.
	rst 38h			;7a4e	ff		.
	rst 38h			;7a4f	ff		.
	rst 38h			;7a50	ff		.
	rst 38h			;7a51	ff		.
	rst 38h			;7a52	ff		.
	rst 38h			;7a53	ff		.
	rst 38h			;7a54	ff		.
	rst 38h			;7a55	ff		.
	rst 38h			;7a56	ff		.
	rst 38h			;7a57	ff		.
	rst 38h			;7a58	ff		.
	rst 38h			;7a59	ff		.
	rst 38h			;7a5a	ff		.
	rst 38h			;7a5b	ff		.
	rst 38h			;7a5c	ff		.
	rst 38h			;7a5d	ff		.
	rst 38h			;7a5e	ff		.
	rst 38h			;7a5f	ff		.
	rst 38h			;7a60	ff		.
	rst 38h			;7a61	ff		.
	rst 38h			;7a62	ff		.
	rst 38h			;7a63	ff		.
	rst 38h			;7a64	ff		.
	rst 38h			;7a65	ff		.
	rst 38h			;7a66	ff		.
	rst 38h			;7a67	ff		.
	rst 38h			;7a68	ff		.
	rst 38h			;7a69	ff		.
	rst 38h			;7a6a	ff		.
	rst 38h			;7a6b	ff		.
	rst 38h			;7a6c	ff		.
	rst 38h			;7a6d	ff		.
	rst 38h			;7a6e	ff		.
	rst 38h			;7a6f	ff		.
	rst 38h			;7a70	ff		.
	rst 38h			;7a71	ff		.
	rst 38h			;7a72	ff		.
	rst 38h			;7a73	ff		.
	rst 38h			;7a74	ff		.
	rst 38h			;7a75	ff		.
	rst 38h			;7a76	ff		.
	rst 38h			;7a77	ff		.
	rst 38h			;7a78	ff		.
	rst 38h			;7a79	ff		.
	rst 38h			;7a7a	ff		.
	rst 38h			;7a7b	ff		.
	rst 38h			;7a7c	ff		.
	rst 38h			;7a7d	ff		.
	rst 38h			;7a7e	ff		.
	rst 38h			;7a7f	ff		.
	rst 38h			;7a80	ff		.
	rst 38h			;7a81	ff		.
	rst 38h			;7a82	ff		.
	rst 38h			;7a83	ff		.
	rst 38h			;7a84	ff		.
	rst 38h			;7a85	ff		.
	rst 38h			;7a86	ff		.
	rst 38h			;7a87	ff		.
	rst 38h			;7a88	ff		.
	rst 38h			;7a89	ff		.
	rst 38h			;7a8a	ff		.
	rst 38h			;7a8b	ff		.
	rst 38h			;7a8c	ff		.
	rst 38h			;7a8d	ff		.
	rst 38h			;7a8e	ff		.
	rst 38h			;7a8f	ff		.
	rst 38h			;7a90	ff		.
	rst 38h			;7a91	ff		.
	rst 38h			;7a92	ff		.
	rst 38h			;7a93	ff		.
	rst 38h			;7a94	ff		.
	rst 38h			;7a95	ff		.
	rst 38h			;7a96	ff		.
	rst 38h			;7a97	ff		.
	rst 38h			;7a98	ff		.
	rst 38h			;7a99	ff		.
	rst 38h			;7a9a	ff		.
	rst 38h			;7a9b	ff		.
	rst 38h			;7a9c	ff		.
	rst 38h			;7a9d	ff		.
	rst 38h			;7a9e	ff		.
	rst 38h			;7a9f	ff		.
	rst 38h			;7aa0	ff		.
	rst 38h			;7aa1	ff		.
	rst 38h			;7aa2	ff		.
	rst 38h			;7aa3	ff		.
	rst 38h			;7aa4	ff		.
	rst 38h			;7aa5	ff		.
	rst 38h			;7aa6	ff		.
	rst 38h			;7aa7	ff		.
	rst 38h			;7aa8	ff		.
	rst 38h			;7aa9	ff		.
	rst 38h			;7aaa	ff		.
	rst 38h			;7aab	ff		.
	rst 38h			;7aac	ff		.
	rst 38h			;7aad	ff		.
	rst 38h			;7aae	ff		.
	rst 38h			;7aaf	ff		.
	rst 38h			;7ab0	ff		.
	rst 38h			;7ab1	ff		.
	rst 38h			;7ab2	ff		.
	rst 38h			;7ab3	ff		.
	rst 38h			;7ab4	ff		.
	rst 38h			;7ab5	ff		.
	rst 38h			;7ab6	ff		.
	rst 38h			;7ab7	ff		.
	rst 38h			;7ab8	ff		.
	rst 38h			;7ab9	ff		.
	rst 38h			;7aba	ff		.
	rst 38h			;7abb	ff		.
	rst 38h			;7abc	ff		.
	rst 38h			;7abd	ff		.
	rst 38h			;7abe	ff		.
	rst 38h			;7abf	ff		.
	rst 38h			;7ac0	ff		.
	rst 38h			;7ac1	ff		.
	rst 38h			;7ac2	ff		.
	rst 38h			;7ac3	ff		.
	rst 38h			;7ac4	ff		.
	rst 38h			;7ac5	ff		.
	rst 38h			;7ac6	ff		.
	rst 38h			;7ac7	ff		.
	rst 38h			;7ac8	ff		.
	rst 38h			;7ac9	ff		.
	rst 38h			;7aca	ff		.
	rst 38h			;7acb	ff		.
	rst 38h			;7acc	ff		.
	rst 38h			;7acd	ff		.
	rst 38h			;7ace	ff		.
	rst 38h			;7acf	ff		.
	rst 38h			;7ad0	ff		.
	rst 38h			;7ad1	ff		.
	rst 38h			;7ad2	ff		.
	rst 38h			;7ad3	ff		.
	rst 38h			;7ad4	ff		.
	rst 38h			;7ad5	ff		.
	rst 38h			;7ad6	ff		.
	rst 38h			;7ad7	ff		.
	rst 38h			;7ad8	ff		.
	rst 38h			;7ad9	ff		.
	rst 38h			;7ada	ff		.
	rst 38h			;7adb	ff		.
	rst 38h			;7adc	ff		.
	rst 38h			;7add	ff		.
	rst 38h			;7ade	ff		.
	rst 38h			;7adf	ff		.
	rst 38h			;7ae0	ff		.
	rst 38h			;7ae1	ff		.
	rst 38h			;7ae2	ff		.
	rst 38h			;7ae3	ff		.
	rst 38h			;7ae4	ff		.
	rst 38h			;7ae5	ff		.
	rst 38h			;7ae6	ff		.
	rst 38h			;7ae7	ff		.
	rst 38h			;7ae8	ff		.
	rst 38h			;7ae9	ff		.
	rst 38h			;7aea	ff		.
	rst 38h			;7aeb	ff		.
	rst 38h			;7aec	ff		.
	rst 38h			;7aed	ff		.
	rst 38h			;7aee	ff		.
	rst 38h			;7aef	ff		.
	rst 38h			;7af0	ff		.
	rst 38h			;7af1	ff		.
	rst 38h			;7af2	ff		.
	rst 38h			;7af3	ff		.
	rst 38h			;7af4	ff		.
	rst 38h			;7af5	ff		.
	rst 38h			;7af6	ff		.
	rst 38h			;7af7	ff		.
	rst 38h			;7af8	ff		.
	rst 38h			;7af9	ff		.
	rst 38h			;7afa	ff		.
	rst 38h			;7afb	ff		.
	rst 38h			;7afc	ff		.
	rst 38h			;7afd	ff		.
	rst 38h			;7afe	ff		.
	rst 38h			;7aff	ff		.
	rst 38h			;7b00	ff		.
	rst 38h			;7b01	ff		.
	rst 38h			;7b02	ff		.
	rst 38h			;7b03	ff		.
	rst 38h			;7b04	ff		.
	rst 38h			;7b05	ff		.
	rst 38h			;7b06	ff		.
	rst 38h			;7b07	ff		.
	rst 38h			;7b08	ff		.
	rst 38h			;7b09	ff		.
	rst 38h			;7b0a	ff		.
	rst 38h			;7b0b	ff		.
	rst 38h			;7b0c	ff		.
	rst 38h			;7b0d	ff		.
	rst 38h			;7b0e	ff		.
	rst 38h			;7b0f	ff		.
	rst 38h			;7b10	ff		.
	rst 38h			;7b11	ff		.
	rst 38h			;7b12	ff		.
	rst 38h			;7b13	ff		.
	rst 38h			;7b14	ff		.
	rst 38h			;7b15	ff		.
	rst 38h			;7b16	ff		.
	rst 38h			;7b17	ff		.
	rst 38h			;7b18	ff		.
	rst 38h			;7b19	ff		.
	rst 38h			;7b1a	ff		.
	rst 38h			;7b1b	ff		.
	rst 38h			;7b1c	ff		.
	rst 38h			;7b1d	ff		.
	rst 38h			;7b1e	ff		.
	rst 38h			;7b1f	ff		.
	rst 38h			;7b20	ff		.
	rst 38h			;7b21	ff		.
	rst 38h			;7b22	ff		.
	rst 38h			;7b23	ff		.
	rst 38h			;7b24	ff		.
	rst 38h			;7b25	ff		.
	rst 38h			;7b26	ff		.
	rst 38h			;7b27	ff		.
	rst 38h			;7b28	ff		.
	rst 38h			;7b29	ff		.
	rst 38h			;7b2a	ff		.
	rst 38h			;7b2b	ff		.
	rst 38h			;7b2c	ff		.
	rst 38h			;7b2d	ff		.
	rst 38h			;7b2e	ff		.
	rst 38h			;7b2f	ff		.
	rst 38h			;7b30	ff		.
	rst 38h			;7b31	ff		.
	rst 38h			;7b32	ff		.
	rst 38h			;7b33	ff		.
	rst 38h			;7b34	ff		.
	rst 38h			;7b35	ff		.
	rst 38h			;7b36	ff		.
	rst 38h			;7b37	ff		.
	rst 38h			;7b38	ff		.
	rst 38h			;7b39	ff		.
	rst 38h			;7b3a	ff		.
	rst 38h			;7b3b	ff		.
	rst 38h			;7b3c	ff		.
	rst 38h			;7b3d	ff		.
	rst 38h			;7b3e	ff		.
	rst 38h			;7b3f	ff		.
	rst 38h			;7b40	ff		.
	rst 38h			;7b41	ff		.
	rst 38h			;7b42	ff		.
	rst 38h			;7b43	ff		.
	rst 38h			;7b44	ff		.
	rst 38h			;7b45	ff		.
	rst 38h			;7b46	ff		.
	rst 38h			;7b47	ff		.
	rst 38h			;7b48	ff		.
	rst 38h			;7b49	ff		.
	rst 38h			;7b4a	ff		.
	rst 38h			;7b4b	ff		.
	rst 38h			;7b4c	ff		.
	rst 38h			;7b4d	ff		.
	rst 38h			;7b4e	ff		.
	rst 38h			;7b4f	ff		.
	rst 38h			;7b50	ff		.
	rst 38h			;7b51	ff		.
	rst 38h			;7b52	ff		.
	rst 38h			;7b53	ff		.
	rst 38h			;7b54	ff		.
	rst 38h			;7b55	ff		.
	rst 38h			;7b56	ff		.
	rst 38h			;7b57	ff		.
	rst 38h			;7b58	ff		.
	rst 38h			;7b59	ff		.
	rst 38h			;7b5a	ff		.
	rst 38h			;7b5b	ff		.
	rst 38h			;7b5c	ff		.
	rst 38h			;7b5d	ff		.
	rst 38h			;7b5e	ff		.
	rst 38h			;7b5f	ff		.
	rst 38h			;7b60	ff		.
	rst 38h			;7b61	ff		.
	rst 38h			;7b62	ff		.
	rst 38h			;7b63	ff		.
	rst 38h			;7b64	ff		.
	rst 38h			;7b65	ff		.
	rst 38h			;7b66	ff		.
	rst 38h			;7b67	ff		.
	rst 38h			;7b68	ff		.
	rst 38h			;7b69	ff		.
	rst 38h			;7b6a	ff		.
	rst 38h			;7b6b	ff		.
	rst 38h			;7b6c	ff		.
	rst 38h			;7b6d	ff		.
	rst 38h			;7b6e	ff		.
	rst 38h			;7b6f	ff		.
	rst 38h			;7b70	ff		.
	rst 38h			;7b71	ff		.
	rst 38h			;7b72	ff		.
	rst 38h			;7b73	ff		.
	rst 38h			;7b74	ff		.
	rst 38h			;7b75	ff		.
	rst 38h			;7b76	ff		.
	rst 38h			;7b77	ff		.
	rst 38h			;7b78	ff		.
	rst 38h			;7b79	ff		.
	rst 38h			;7b7a	ff		.
	rst 38h			;7b7b	ff		.
	rst 38h			;7b7c	ff		.
	rst 38h			;7b7d	ff		.
	rst 38h			;7b7e	ff		.
	rst 38h			;7b7f	ff		.
	rst 38h			;7b80	ff		.
	rst 38h			;7b81	ff		.
	rst 38h			;7b82	ff		.
	rst 38h			;7b83	ff		.
	rst 38h			;7b84	ff		.
	rst 38h			;7b85	ff		.
	rst 38h			;7b86	ff		.
	rst 38h			;7b87	ff		.
	rst 38h			;7b88	ff		.
	rst 38h			;7b89	ff		.
	rst 38h			;7b8a	ff		.
	rst 38h			;7b8b	ff		.
	rst 38h			;7b8c	ff		.
	rst 38h			;7b8d	ff		.
	rst 38h			;7b8e	ff		.
	rst 38h			;7b8f	ff		.
	rst 38h			;7b90	ff		.
	rst 38h			;7b91	ff		.
	rst 38h			;7b92	ff		.
	rst 38h			;7b93	ff		.
	rst 38h			;7b94	ff		.
	rst 38h			;7b95	ff		.
	rst 38h			;7b96	ff		.
	rst 38h			;7b97	ff		.
	rst 38h			;7b98	ff		.
	rst 38h			;7b99	ff		.
	rst 38h			;7b9a	ff		.
	rst 38h			;7b9b	ff		.
	rst 38h			;7b9c	ff		.
	rst 38h			;7b9d	ff		.
	rst 38h			;7b9e	ff		.
	rst 38h			;7b9f	ff		.
	rst 38h			;7ba0	ff		.
	rst 38h			;7ba1	ff		.
	rst 38h			;7ba2	ff		.
	rst 38h			;7ba3	ff		.
	rst 38h			;7ba4	ff		.
	rst 38h			;7ba5	ff		.
	rst 38h			;7ba6	ff		.
	rst 38h			;7ba7	ff		.
	rst 38h			;7ba8	ff		.
	rst 38h			;7ba9	ff		.
	rst 38h			;7baa	ff		.
	rst 38h			;7bab	ff		.
	rst 38h			;7bac	ff		.
	rst 38h			;7bad	ff		.
	rst 38h			;7bae	ff		.
	rst 38h			;7baf	ff		.
	rst 38h			;7bb0	ff		.
	rst 38h			;7bb1	ff		.
	rst 38h			;7bb2	ff		.
	rst 38h			;7bb3	ff		.
	rst 38h			;7bb4	ff		.
	rst 38h			;7bb5	ff		.
	rst 38h			;7bb6	ff		.
	rst 38h			;7bb7	ff		.
	rst 38h			;7bb8	ff		.
	rst 38h			;7bb9	ff		.
	rst 38h			;7bba	ff		.
	rst 38h			;7bbb	ff		.
	rst 38h			;7bbc	ff		.
	rst 38h			;7bbd	ff		.
	rst 38h			;7bbe	ff		.
	rst 38h			;7bbf	ff		.
	rst 38h			;7bc0	ff		.
	rst 38h			;7bc1	ff		.
	rst 38h			;7bc2	ff		.
	rst 38h			;7bc3	ff		.
	rst 38h			;7bc4	ff		.
	rst 38h			;7bc5	ff		.
	rst 38h			;7bc6	ff		.
	rst 38h			;7bc7	ff		.
	rst 38h			;7bc8	ff		.
	rst 38h			;7bc9	ff		.
	rst 38h			;7bca	ff		.
	rst 38h			;7bcb	ff		.
	rst 38h			;7bcc	ff		.
	rst 38h			;7bcd	ff		.
	rst 38h			;7bce	ff		.
	rst 38h			;7bcf	ff		.
	rst 38h			;7bd0	ff		.
	rst 38h			;7bd1	ff		.
	rst 38h			;7bd2	ff		.
	rst 38h			;7bd3	ff		.
	rst 38h			;7bd4	ff		.
	rst 38h			;7bd5	ff		.
	rst 38h			;7bd6	ff		.
	rst 38h			;7bd7	ff		.
	rst 38h			;7bd8	ff		.
	rst 38h			;7bd9	ff		.
	rst 38h			;7bda	ff		.
	rst 38h			;7bdb	ff		.
	rst 38h			;7bdc	ff		.
	rst 38h			;7bdd	ff		.
	rst 38h			;7bde	ff		.
	rst 38h			;7bdf	ff		.
	rst 38h			;7be0	ff		.
	rst 38h			;7be1	ff		.
	rst 38h			;7be2	ff		.
	rst 38h			;7be3	ff		.
	rst 38h			;7be4	ff		.
	rst 38h			;7be5	ff		.
	rst 38h			;7be6	ff		.
	rst 38h			;7be7	ff		.
	rst 38h			;7be8	ff		.
	rst 38h			;7be9	ff		.
	rst 38h			;7bea	ff		.
	rst 38h			;7beb	ff		.
	rst 38h			;7bec	ff		.
	rst 38h			;7bed	ff		.
	rst 38h			;7bee	ff		.
	rst 38h			;7bef	ff		.
	rst 38h			;7bf0	ff		.
	rst 38h			;7bf1	ff		.
	rst 38h			;7bf2	ff		.
	rst 38h			;7bf3	ff		.
	rst 38h			;7bf4	ff		.
	rst 38h			;7bf5	ff		.
	rst 38h			;7bf6	ff		.
	rst 38h			;7bf7	ff		.
	rst 38h			;7bf8	ff		.
	rst 38h			;7bf9	ff		.
	rst 38h			;7bfa	ff		.
	rst 38h			;7bfb	ff		.
	rst 38h			;7bfc	ff		.
	rst 38h			;7bfd	ff		.
	rst 38h			;7bfe	ff		.
	rst 38h			;7bff	ff		.
	rst 38h			;7c00	ff		.
	rst 38h			;7c01	ff		.
	rst 38h			;7c02	ff		.
	rst 38h			;7c03	ff		.
	rst 38h			;7c04	ff		.
	rst 38h			;7c05	ff		.
	rst 38h			;7c06	ff		.
	rst 38h			;7c07	ff		.
	rst 38h			;7c08	ff		.
	rst 38h			;7c09	ff		.
	rst 38h			;7c0a	ff		.
	rst 38h			;7c0b	ff		.
	rst 38h			;7c0c	ff		.
	rst 38h			;7c0d	ff		.
	rst 38h			;7c0e	ff		.
	rst 38h			;7c0f	ff		.
	rst 38h			;7c10	ff		.
	rst 38h			;7c11	ff		.
	rst 38h			;7c12	ff		.
	rst 38h			;7c13	ff		.
	rst 38h			;7c14	ff		.
	rst 38h			;7c15	ff		.
	rst 38h			;7c16	ff		.
	rst 38h			;7c17	ff		.
	rst 38h			;7c18	ff		.
	rst 38h			;7c19	ff		.
	rst 38h			;7c1a	ff		.
	rst 38h			;7c1b	ff		.
	rst 38h			;7c1c	ff		.
	rst 38h			;7c1d	ff		.
	rst 38h			;7c1e	ff		.
	rst 38h			;7c1f	ff		.
	rst 38h			;7c20	ff		.
	rst 38h			;7c21	ff		.
	rst 38h			;7c22	ff		.
	rst 38h			;7c23	ff		.
	rst 38h			;7c24	ff		.
	rst 38h			;7c25	ff		.
	rst 38h			;7c26	ff		.
	rst 38h			;7c27	ff		.
	rst 38h			;7c28	ff		.
	rst 38h			;7c29	ff		.
	rst 38h			;7c2a	ff		.
	rst 38h			;7c2b	ff		.
	rst 38h			;7c2c	ff		.
	rst 38h			;7c2d	ff		.
	rst 38h			;7c2e	ff		.
	rst 38h			;7c2f	ff		.
	rst 38h			;7c30	ff		.
	rst 38h			;7c31	ff		.
	rst 38h			;7c32	ff		.
	rst 38h			;7c33	ff		.
	rst 38h			;7c34	ff		.
	rst 38h			;7c35	ff		.
	rst 38h			;7c36	ff		.
	rst 38h			;7c37	ff		.
	rst 38h			;7c38	ff		.
	rst 38h			;7c39	ff		.
	rst 38h			;7c3a	ff		.
	rst 38h			;7c3b	ff		.
	rst 38h			;7c3c	ff		.
	rst 38h			;7c3d	ff		.
	rst 38h			;7c3e	ff		.
	rst 38h			;7c3f	ff		.
	rst 38h			;7c40	ff		.
	rst 38h			;7c41	ff		.
	rst 38h			;7c42	ff		.
	rst 38h			;7c43	ff		.
	rst 38h			;7c44	ff		.
	rst 38h			;7c45	ff		.
	rst 38h			;7c46	ff		.
	rst 38h			;7c47	ff		.
	rst 38h			;7c48	ff		.
	rst 38h			;7c49	ff		.
	rst 38h			;7c4a	ff		.
	rst 38h			;7c4b	ff		.
	rst 38h			;7c4c	ff		.
	rst 38h			;7c4d	ff		.
	rst 38h			;7c4e	ff		.
	rst 38h			;7c4f	ff		.
	rst 38h			;7c50	ff		.
	rst 38h			;7c51	ff		.
	rst 38h			;7c52	ff		.
	rst 38h			;7c53	ff		.
	rst 38h			;7c54	ff		.
	rst 38h			;7c55	ff		.
	rst 38h			;7c56	ff		.
	rst 38h			;7c57	ff		.
	rst 38h			;7c58	ff		.
	rst 38h			;7c59	ff		.
	rst 38h			;7c5a	ff		.
	rst 38h			;7c5b	ff		.
	rst 38h			;7c5c	ff		.
	rst 38h			;7c5d	ff		.
	rst 38h			;7c5e	ff		.
	rst 38h			;7c5f	ff		.
	rst 38h			;7c60	ff		.
	rst 38h			;7c61	ff		.
	rst 38h			;7c62	ff		.
	rst 38h			;7c63	ff		.
	rst 38h			;7c64	ff		.
	rst 38h			;7c65	ff		.
	rst 38h			;7c66	ff		.
	rst 38h			;7c67	ff		.
	rst 38h			;7c68	ff		.
	rst 38h			;7c69	ff		.
	rst 38h			;7c6a	ff		.
	rst 38h			;7c6b	ff		.
	rst 38h			;7c6c	ff		.
	rst 38h			;7c6d	ff		.
	rst 38h			;7c6e	ff		.
	rst 38h			;7c6f	ff		.
	rst 38h			;7c70	ff		.
	rst 38h			;7c71	ff		.
	rst 38h			;7c72	ff		.
	rst 38h			;7c73	ff		.
	rst 38h			;7c74	ff		.
	rst 38h			;7c75	ff		.
	rst 38h			;7c76	ff		.
	rst 38h			;7c77	ff		.
	rst 38h			;7c78	ff		.
	rst 38h			;7c79	ff		.
	rst 38h			;7c7a	ff		.
	rst 38h			;7c7b	ff		.
	rst 38h			;7c7c	ff		.
	rst 38h			;7c7d	ff		.
	rst 38h			;7c7e	ff		.
	rst 38h			;7c7f	ff		.
	rst 38h			;7c80	ff		.
	rst 38h			;7c81	ff		.
	rst 38h			;7c82	ff		.
	rst 38h			;7c83	ff		.
	rst 38h			;7c84	ff		.
	rst 38h			;7c85	ff		.
	rst 38h			;7c86	ff		.
	rst 38h			;7c87	ff		.
	rst 38h			;7c88	ff		.
	rst 38h			;7c89	ff		.
	rst 38h			;7c8a	ff		.
	rst 38h			;7c8b	ff		.
	rst 38h			;7c8c	ff		.
	rst 38h			;7c8d	ff		.
	rst 38h			;7c8e	ff		.
	rst 38h			;7c8f	ff		.
	rst 38h			;7c90	ff		.
	rst 38h			;7c91	ff		.
	rst 38h			;7c92	ff		.
	rst 38h			;7c93	ff		.
	rst 38h			;7c94	ff		.
	rst 38h			;7c95	ff		.
	rst 38h			;7c96	ff		.
	rst 38h			;7c97	ff		.
	rst 38h			;7c98	ff		.
	rst 38h			;7c99	ff		.
	rst 38h			;7c9a	ff		.
	rst 38h			;7c9b	ff		.
	rst 38h			;7c9c	ff		.
	rst 38h			;7c9d	ff		.
	rst 38h			;7c9e	ff		.
	rst 38h			;7c9f	ff		.
	rst 38h			;7ca0	ff		.
	rst 38h			;7ca1	ff		.
	rst 38h			;7ca2	ff		.
	rst 38h			;7ca3	ff		.
	rst 38h			;7ca4	ff		.
	rst 38h			;7ca5	ff		.
	rst 38h			;7ca6	ff		.
	rst 38h			;7ca7	ff		.
	rst 38h			;7ca8	ff		.
	rst 38h			;7ca9	ff		.
	rst 38h			;7caa	ff		.
	rst 38h			;7cab	ff		.
	rst 38h			;7cac	ff		.
	rst 38h			;7cad	ff		.
	rst 38h			;7cae	ff		.
	rst 38h			;7caf	ff		.
	rst 38h			;7cb0	ff		.
	rst 38h			;7cb1	ff		.
	rst 38h			;7cb2	ff		.
	rst 38h			;7cb3	ff		.
	rst 38h			;7cb4	ff		.
	rst 38h			;7cb5	ff		.
	rst 38h			;7cb6	ff		.
	rst 38h			;7cb7	ff		.
	rst 38h			;7cb8	ff		.
	rst 38h			;7cb9	ff		.
	rst 38h			;7cba	ff		.
	rst 38h			;7cbb	ff		.
	rst 38h			;7cbc	ff		.
	rst 38h			;7cbd	ff		.
	rst 38h			;7cbe	ff		.
	rst 38h			;7cbf	ff		.
	rst 38h			;7cc0	ff		.
	rst 38h			;7cc1	ff		.
	rst 38h			;7cc2	ff		.
	rst 38h			;7cc3	ff		.
	rst 38h			;7cc4	ff		.
	rst 38h			;7cc5	ff		.
	rst 38h			;7cc6	ff		.
	rst 38h			;7cc7	ff		.
	rst 38h			;7cc8	ff		.
	rst 38h			;7cc9	ff		.
	rst 38h			;7cca	ff		.
	rst 38h			;7ccb	ff		.
	rst 38h			;7ccc	ff		.
	rst 38h			;7ccd	ff		.
	rst 38h			;7cce	ff		.
	rst 38h			;7ccf	ff		.
	rst 38h			;7cd0	ff		.
	rst 38h			;7cd1	ff		.
	rst 38h			;7cd2	ff		.
	rst 38h			;7cd3	ff		.
	rst 38h			;7cd4	ff		.
	rst 38h			;7cd5	ff		.
	rst 38h			;7cd6	ff		.
	rst 38h			;7cd7	ff		.
	rst 38h			;7cd8	ff		.
	rst 38h			;7cd9	ff		.
	rst 38h			;7cda	ff		.
	rst 38h			;7cdb	ff		.
	rst 38h			;7cdc	ff		.
	rst 38h			;7cdd	ff		.
	rst 38h			;7cde	ff		.
	rst 38h			;7cdf	ff		.
	rst 38h			;7ce0	ff		.
	rst 38h			;7ce1	ff		.
	rst 38h			;7ce2	ff		.
	rst 38h			;7ce3	ff		.
	rst 38h			;7ce4	ff		.
	rst 38h			;7ce5	ff		.
	rst 38h			;7ce6	ff		.
	rst 38h			;7ce7	ff		.
	rst 38h			;7ce8	ff		.
	rst 38h			;7ce9	ff		.
	rst 38h			;7cea	ff		.
	rst 38h			;7ceb	ff		.
	rst 38h			;7cec	ff		.
	rst 38h			;7ced	ff		.
	rst 38h			;7cee	ff		.
	rst 38h			;7cef	ff		.
	rst 38h			;7cf0	ff		.
	rst 38h			;7cf1	ff		.
	rst 38h			;7cf2	ff		.
	rst 38h			;7cf3	ff		.
	rst 38h			;7cf4	ff		.
	rst 38h			;7cf5	ff		.
	rst 38h			;7cf6	ff		.
	rst 38h			;7cf7	ff		.
	rst 38h			;7cf8	ff		.
	rst 38h			;7cf9	ff		.
	rst 38h			;7cfa	ff		.
	rst 38h			;7cfb	ff		.
	rst 38h			;7cfc	ff		.
	rst 38h			;7cfd	ff		.
	rst 38h			;7cfe	ff		.
	rst 38h			;7cff	ff		.
	rst 38h			;7d00	ff		.
	rst 38h			;7d01	ff		.
	rst 38h			;7d02	ff		.
	rst 38h			;7d03	ff		.
	rst 38h			;7d04	ff		.
	rst 38h			;7d05	ff		.
	rst 38h			;7d06	ff		.
	rst 38h			;7d07	ff		.
	rst 38h			;7d08	ff		.
	rst 38h			;7d09	ff		.
	rst 38h			;7d0a	ff		.
	rst 38h			;7d0b	ff		.
	rst 38h			;7d0c	ff		.
	rst 38h			;7d0d	ff		.
	rst 38h			;7d0e	ff		.
	rst 38h			;7d0f	ff		.
	rst 38h			;7d10	ff		.
	rst 38h			;7d11	ff		.
	rst 38h			;7d12	ff		.
	rst 38h			;7d13	ff		.
	rst 38h			;7d14	ff		.
	rst 38h			;7d15	ff		.
	rst 38h			;7d16	ff		.
	rst 38h			;7d17	ff		.
	rst 38h			;7d18	ff		.
	rst 38h			;7d19	ff		.
	rst 38h			;7d1a	ff		.
	rst 38h			;7d1b	ff		.
	rst 38h			;7d1c	ff		.
	rst 38h			;7d1d	ff		.
	rst 38h			;7d1e	ff		.
	rst 38h			;7d1f	ff		.
	rst 38h			;7d20	ff		.
	rst 38h			;7d21	ff		.
	rst 38h			;7d22	ff		.
	rst 38h			;7d23	ff		.
	rst 38h			;7d24	ff		.
	rst 38h			;7d25	ff		.
	rst 38h			;7d26	ff		.
	rst 38h			;7d27	ff		.
	rst 38h			;7d28	ff		.
	rst 38h			;7d29	ff		.
	rst 38h			;7d2a	ff		.
	rst 38h			;7d2b	ff		.
	rst 38h			;7d2c	ff		.
	rst 38h			;7d2d	ff		.
	rst 38h			;7d2e	ff		.
	rst 38h			;7d2f	ff		.
	rst 38h			;7d30	ff		.
	rst 38h			;7d31	ff		.
	rst 38h			;7d32	ff		.
	rst 38h			;7d33	ff		.
	rst 38h			;7d34	ff		.
	rst 38h			;7d35	ff		.
	rst 38h			;7d36	ff		.
	rst 38h			;7d37	ff		.
	rst 38h			;7d38	ff		.
	rst 38h			;7d39	ff		.
	rst 38h			;7d3a	ff		.
	rst 38h			;7d3b	ff		.
	rst 38h			;7d3c	ff		.
	rst 38h			;7d3d	ff		.
	rst 38h			;7d3e	ff		.
	rst 38h			;7d3f	ff		.
	rst 38h			;7d40	ff		.
	rst 38h			;7d41	ff		.
	rst 38h			;7d42	ff		.
	rst 38h			;7d43	ff		.
	rst 38h			;7d44	ff		.
	rst 38h			;7d45	ff		.
	rst 38h			;7d46	ff		.
	rst 38h			;7d47	ff		.
	rst 38h			;7d48	ff		.
	rst 38h			;7d49	ff		.
	rst 38h			;7d4a	ff		.
	rst 38h			;7d4b	ff		.
	rst 38h			;7d4c	ff		.
	rst 38h			;7d4d	ff		.
	rst 38h			;7d4e	ff		.
	rst 38h			;7d4f	ff		.
	rst 38h			;7d50	ff		.
	rst 38h			;7d51	ff		.
	rst 38h			;7d52	ff		.
	rst 38h			;7d53	ff		.
	rst 38h			;7d54	ff		.
	rst 38h			;7d55	ff		.
	rst 38h			;7d56	ff		.
	rst 38h			;7d57	ff		.
	rst 38h			;7d58	ff		.
	rst 38h			;7d59	ff		.
	rst 38h			;7d5a	ff		.
	rst 38h			;7d5b	ff		.
	rst 38h			;7d5c	ff		.
	rst 38h			;7d5d	ff		.
	rst 38h			;7d5e	ff		.
	rst 38h			;7d5f	ff		.
	rst 38h			;7d60	ff		.
	rst 38h			;7d61	ff		.
	rst 38h			;7d62	ff		.
	rst 38h			;7d63	ff		.
	rst 38h			;7d64	ff		.
	rst 38h			;7d65	ff		.
	rst 38h			;7d66	ff		.
	rst 38h			;7d67	ff		.
	rst 38h			;7d68	ff		.
	rst 38h			;7d69	ff		.
	rst 38h			;7d6a	ff		.
	rst 38h			;7d6b	ff		.
	rst 38h			;7d6c	ff		.
	rst 38h			;7d6d	ff		.
	rst 38h			;7d6e	ff		.
	rst 38h			;7d6f	ff		.
	rst 38h			;7d70	ff		.
	rst 38h			;7d71	ff		.
	rst 38h			;7d72	ff		.
	rst 38h			;7d73	ff		.
	rst 38h			;7d74	ff		.
	rst 38h			;7d75	ff		.
	rst 38h			;7d76	ff		.
	rst 38h			;7d77	ff		.
	rst 38h			;7d78	ff		.
	rst 38h			;7d79	ff		.
	rst 38h			;7d7a	ff		.
	rst 38h			;7d7b	ff		.
	rst 38h			;7d7c	ff		.
	rst 38h			;7d7d	ff		.
	rst 38h			;7d7e	ff		.
	rst 38h			;7d7f	ff		.
	rst 38h			;7d80	ff		.
	rst 38h			;7d81	ff		.
	rst 38h			;7d82	ff		.
	rst 38h			;7d83	ff		.
	rst 38h			;7d84	ff		.
	rst 38h			;7d85	ff		.
	rst 38h			;7d86	ff		.
	rst 38h			;7d87	ff		.
	rst 38h			;7d88	ff		.
	rst 38h			;7d89	ff		.
	rst 38h			;7d8a	ff		.
	rst 38h			;7d8b	ff		.
	rst 38h			;7d8c	ff		.
	rst 38h			;7d8d	ff		.
	rst 38h			;7d8e	ff		.
	rst 38h			;7d8f	ff		.
	rst 38h			;7d90	ff		.
	rst 38h			;7d91	ff		.
	rst 38h			;7d92	ff		.
	rst 38h			;7d93	ff		.
	rst 38h			;7d94	ff		.
	rst 38h			;7d95	ff		.
	rst 38h			;7d96	ff		.
	rst 38h			;7d97	ff		.
	rst 38h			;7d98	ff		.
	rst 38h			;7d99	ff		.
	rst 38h			;7d9a	ff		.
	rst 38h			;7d9b	ff		.
	rst 38h			;7d9c	ff		.
	rst 38h			;7d9d	ff		.
	rst 38h			;7d9e	ff		.
	rst 38h			;7d9f	ff		.
	rst 38h			;7da0	ff		.
	rst 38h			;7da1	ff		.
	rst 38h			;7da2	ff		.
	rst 38h			;7da3	ff		.
	rst 38h			;7da4	ff		.
	rst 38h			;7da5	ff		.
	rst 38h			;7da6	ff		.
	rst 38h			;7da7	ff		.
	rst 38h			;7da8	ff		.
	rst 38h			;7da9	ff		.
	rst 38h			;7daa	ff		.
	rst 38h			;7dab	ff		.
	rst 38h			;7dac	ff		.
	rst 38h			;7dad	ff		.
	rst 38h			;7dae	ff		.
	rst 38h			;7daf	ff		.
	rst 38h			;7db0	ff		.
	rst 38h			;7db1	ff		.
	rst 38h			;7db2	ff		.
	rst 38h			;7db3	ff		.
	rst 38h			;7db4	ff		.
	rst 38h			;7db5	ff		.
	rst 38h			;7db6	ff		.
	rst 38h			;7db7	ff		.
	rst 38h			;7db8	ff		.
	rst 38h			;7db9	ff		.
	rst 38h			;7dba	ff		.
	rst 38h			;7dbb	ff		.
	rst 38h			;7dbc	ff		.
	rst 38h			;7dbd	ff		.
	rst 38h			;7dbe	ff		.
	rst 38h			;7dbf	ff		.
	rst 38h			;7dc0	ff		.
	rst 38h			;7dc1	ff		.
	rst 38h			;7dc2	ff		.
	rst 38h			;7dc3	ff		.
	rst 38h			;7dc4	ff		.
	rst 38h			;7dc5	ff		.
	rst 38h			;7dc6	ff		.
	rst 38h			;7dc7	ff		.
	rst 38h			;7dc8	ff		.
	rst 38h			;7dc9	ff		.
	rst 38h			;7dca	ff		.
	rst 38h			;7dcb	ff		.
	rst 38h			;7dcc	ff		.
	rst 38h			;7dcd	ff		.
	rst 38h			;7dce	ff		.
	rst 38h			;7dcf	ff		.
	rst 38h			;7dd0	ff		.
	rst 38h			;7dd1	ff		.
	rst 38h			;7dd2	ff		.
	rst 38h			;7dd3	ff		.
	rst 38h			;7dd4	ff		.
	rst 38h			;7dd5	ff		.
	rst 38h			;7dd6	ff		.
	rst 38h			;7dd7	ff		.
	rst 38h			;7dd8	ff		.
	rst 38h			;7dd9	ff		.
	rst 38h			;7dda	ff		.
	rst 38h			;7ddb	ff		.
	rst 38h			;7ddc	ff		.
	rst 38h			;7ddd	ff		.
	rst 38h			;7dde	ff		.
	rst 38h			;7ddf	ff		.
	rst 38h			;7de0	ff		.
	rst 38h			;7de1	ff		.
	rst 38h			;7de2	ff		.
	rst 38h			;7de3	ff		.
	rst 38h			;7de4	ff		.
	rst 38h			;7de5	ff		.
	rst 38h			;7de6	ff		.
	rst 38h			;7de7	ff		.
	rst 38h			;7de8	ff		.
	rst 38h			;7de9	ff		.
	rst 38h			;7dea	ff		.
	rst 38h			;7deb	ff		.
	rst 38h			;7dec	ff		.
	rst 38h			;7ded	ff		.
	rst 38h			;7dee	ff		.
	rst 38h			;7def	ff		.
	rst 38h			;7df0	ff		.
	rst 38h			;7df1	ff		.
	rst 38h			;7df2	ff		.
	rst 38h			;7df3	ff		.
	rst 38h			;7df4	ff		.
	rst 38h			;7df5	ff		.
	rst 38h			;7df6	ff		.
	rst 38h			;7df7	ff		.
	rst 38h			;7df8	ff		.
	rst 38h			;7df9	ff		.
	rst 38h			;7dfa	ff		.
	rst 38h			;7dfb	ff		.
	rst 38h			;7dfc	ff		.
	rst 38h			;7dfd	ff		.
	rst 38h			;7dfe	ff		.
	rst 38h			;7dff	ff		.
	rst 38h			;7e00	ff		.
	rst 38h			;7e01	ff		.
	rst 38h			;7e02	ff		.
	rst 38h			;7e03	ff		.
	rst 38h			;7e04	ff		.
	rst 38h			;7e05	ff		.
	rst 38h			;7e06	ff		.
	rst 38h			;7e07	ff		.
	rst 38h			;7e08	ff		.
	rst 38h			;7e09	ff		.
	rst 38h			;7e0a	ff		.
	rst 38h			;7e0b	ff		.
	rst 38h			;7e0c	ff		.
	rst 38h			;7e0d	ff		.
	rst 38h			;7e0e	ff		.
	rst 38h			;7e0f	ff		.
	rst 38h			;7e10	ff		.
	rst 38h			;7e11	ff		.
	rst 38h			;7e12	ff		.
	rst 38h			;7e13	ff		.
	rst 38h			;7e14	ff		.
	rst 38h			;7e15	ff		.
	rst 38h			;7e16	ff		.
	rst 38h			;7e17	ff		.
	rst 38h			;7e18	ff		.
	rst 38h			;7e19	ff		.
	rst 38h			;7e1a	ff		.
	rst 38h			;7e1b	ff		.
	rst 38h			;7e1c	ff		.
	rst 38h			;7e1d	ff		.
	rst 38h			;7e1e	ff		.
	rst 38h			;7e1f	ff		.
	rst 38h			;7e20	ff		.
	rst 38h			;7e21	ff		.
	rst 38h			;7e22	ff		.
	rst 38h			;7e23	ff		.
	rst 38h			;7e24	ff		.
	rst 38h			;7e25	ff		.
	rst 38h			;7e26	ff		.
	rst 38h			;7e27	ff		.
	rst 38h			;7e28	ff		.
	rst 38h			;7e29	ff		.
	rst 38h			;7e2a	ff		.
	rst 38h			;7e2b	ff		.
	rst 38h			;7e2c	ff		.
	rst 38h			;7e2d	ff		.
	rst 38h			;7e2e	ff		.
	rst 38h			;7e2f	ff		.
	rst 38h			;7e30	ff		.
	rst 38h			;7e31	ff		.
	rst 38h			;7e32	ff		.
	rst 38h			;7e33	ff		.
	rst 38h			;7e34	ff		.
	rst 38h			;7e35	ff		.
	rst 38h			;7e36	ff		.
	rst 38h			;7e37	ff		.
	rst 38h			;7e38	ff		.
	rst 38h			;7e39	ff		.
	rst 38h			;7e3a	ff		.
	rst 38h			;7e3b	ff		.
	rst 38h			;7e3c	ff		.
	rst 38h			;7e3d	ff		.
	rst 38h			;7e3e	ff		.
	rst 38h			;7e3f	ff		.
	rst 38h			;7e40	ff		.
	rst 38h			;7e41	ff		.
	rst 38h			;7e42	ff		.
	rst 38h			;7e43	ff		.
	rst 38h			;7e44	ff		.
	rst 38h			;7e45	ff		.
	rst 38h			;7e46	ff		.
	rst 38h			;7e47	ff		.
	rst 38h			;7e48	ff		.
	rst 38h			;7e49	ff		.
	rst 38h			;7e4a	ff		.
	rst 38h			;7e4b	ff		.
	rst 38h			;7e4c	ff		.
	rst 38h			;7e4d	ff		.
	rst 38h			;7e4e	ff		.
	rst 38h			;7e4f	ff		.
	rst 38h			;7e50	ff		.
	rst 38h			;7e51	ff		.
	rst 38h			;7e52	ff		.
	rst 38h			;7e53	ff		.
	rst 38h			;7e54	ff		.
	rst 38h			;7e55	ff		.
	rst 38h			;7e56	ff		.
	rst 38h			;7e57	ff		.
	rst 38h			;7e58	ff		.
	rst 38h			;7e59	ff		.
	rst 38h			;7e5a	ff		.
	rst 38h			;7e5b	ff		.
	rst 38h			;7e5c	ff		.
	rst 38h			;7e5d	ff		.
	rst 38h			;7e5e	ff		.
	rst 38h			;7e5f	ff		.
	rst 38h			;7e60	ff		.
	rst 38h			;7e61	ff		.
	rst 38h			;7e62	ff		.
	rst 38h			;7e63	ff		.
	rst 38h			;7e64	ff		.
	rst 38h			;7e65	ff		.
	rst 38h			;7e66	ff		.
	rst 38h			;7e67	ff		.
	rst 38h			;7e68	ff		.
	rst 38h			;7e69	ff		.
	rst 38h			;7e6a	ff		.
	rst 38h			;7e6b	ff		.
	rst 38h			;7e6c	ff		.
	rst 38h			;7e6d	ff		.
	rst 38h			;7e6e	ff		.
	rst 38h			;7e6f	ff		.
	rst 38h			;7e70	ff		.
	rst 38h			;7e71	ff		.
	rst 38h			;7e72	ff		.
	rst 38h			;7e73	ff		.
	rst 38h			;7e74	ff		.
	rst 38h			;7e75	ff		.
	rst 38h			;7e76	ff		.
	rst 38h			;7e77	ff		.
	rst 38h			;7e78	ff		.
	rst 38h			;7e79	ff		.
	rst 38h			;7e7a	ff		.
	rst 38h			;7e7b	ff		.
	rst 38h			;7e7c	ff		.
	rst 38h			;7e7d	ff		.
	rst 38h			;7e7e	ff		.
	rst 38h			;7e7f	ff		.
	rst 38h			;7e80	ff		.
	rst 38h			;7e81	ff		.
	rst 38h			;7e82	ff		.
	rst 38h			;7e83	ff		.
	rst 38h			;7e84	ff		.
	rst 38h			;7e85	ff		.
	rst 38h			;7e86	ff		.
	rst 38h			;7e87	ff		.
	rst 38h			;7e88	ff		.
	rst 38h			;7e89	ff		.
	rst 38h			;7e8a	ff		.
	rst 38h			;7e8b	ff		.
	rst 38h			;7e8c	ff		.
	rst 38h			;7e8d	ff		.
	rst 38h			;7e8e	ff		.
	rst 38h			;7e8f	ff		.
	rst 38h			;7e90	ff		.
	rst 38h			;7e91	ff		.
	rst 38h			;7e92	ff		.
	rst 38h			;7e93	ff		.
	rst 38h			;7e94	ff		.
	rst 38h			;7e95	ff		.
	rst 38h			;7e96	ff		.
	rst 38h			;7e97	ff		.
	rst 38h			;7e98	ff		.
	rst 38h			;7e99	ff		.
	rst 38h			;7e9a	ff		.
	rst 38h			;7e9b	ff		.
	rst 38h			;7e9c	ff		.
	rst 38h			;7e9d	ff		.
	rst 38h			;7e9e	ff		.
	rst 38h			;7e9f	ff		.
	rst 38h			;7ea0	ff		.
	rst 38h			;7ea1	ff		.
	rst 38h			;7ea2	ff		.
	rst 38h			;7ea3	ff		.
	rst 38h			;7ea4	ff		.
	rst 38h			;7ea5	ff		.
	rst 38h			;7ea6	ff		.
	rst 38h			;7ea7	ff		.
	rst 38h			;7ea8	ff		.
	rst 38h			;7ea9	ff		.
	rst 38h			;7eaa	ff		.
	rst 38h			;7eab	ff		.
	rst 38h			;7eac	ff		.
	rst 38h			;7ead	ff		.
	rst 38h			;7eae	ff		.
	rst 38h			;7eaf	ff		.
	rst 38h			;7eb0	ff		.
	rst 38h			;7eb1	ff		.
	rst 38h			;7eb2	ff		.
	rst 38h			;7eb3	ff		.
	rst 38h			;7eb4	ff		.
	rst 38h			;7eb5	ff		.
	rst 38h			;7eb6	ff		.
	rst 38h			;7eb7	ff		.
	rst 38h			;7eb8	ff		.
	rst 38h			;7eb9	ff		.
	rst 38h			;7eba	ff		.
	rst 38h			;7ebb	ff		.
	rst 38h			;7ebc	ff		.
	rst 38h			;7ebd	ff		.
	rst 38h			;7ebe	ff		.
sub_7ebfh:
	rst 38h			;7ebf	ff		.
	rst 38h			;7ec0	ff		.
	rst 38h			;7ec1	ff		.
	rst 38h			;7ec2	ff		.
	rst 38h			;7ec3	ff		.
	rst 38h			;7ec4	ff		.
	rst 38h			;7ec5	ff		.
	rst 38h			;7ec6	ff		.
	rst 38h			;7ec7	ff		.
	rst 38h			;7ec8	ff		.
	rst 38h			;7ec9	ff		.
	rst 38h			;7eca	ff		.
	rst 38h			;7ecb	ff		.
	rst 38h			;7ecc	ff		.
	rst 38h			;7ecd	ff		.
	rst 38h			;7ece	ff		.
	rst 38h			;7ecf	ff		.
	rst 38h			;7ed0	ff		.
	rst 38h			;7ed1	ff		.
	rst 38h			;7ed2	ff		.
	rst 38h			;7ed3	ff		.
	rst 38h			;7ed4	ff		.
	rst 38h			;7ed5	ff		.
	rst 38h			;7ed6	ff		.
	rst 38h			;7ed7	ff		.
	rst 38h			;7ed8	ff		.
	rst 38h			;7ed9	ff		.
	rst 38h			;7eda	ff		.
	rst 38h			;7edb	ff		.
	rst 38h			;7edc	ff		.
	rst 38h			;7edd	ff		.
	rst 38h			;7ede	ff		.
	rst 38h			;7edf	ff		.
	rst 38h			;7ee0	ff		.
	rst 38h			;7ee1	ff		.
	rst 38h			;7ee2	ff		.
	rst 38h			;7ee3	ff		.
	rst 38h			;7ee4	ff		.
	rst 38h			;7ee5	ff		.
	rst 38h			;7ee6	ff		.
	rst 38h			;7ee7	ff		.
	rst 38h			;7ee8	ff		.
	rst 38h			;7ee9	ff		.
	rst 38h			;7eea	ff		.
	rst 38h			;7eeb	ff		.
	rst 38h			;7eec	ff		.
	rst 38h			;7eed	ff		.
	rst 38h			;7eee	ff		.
	rst 38h			;7eef	ff		.
	rst 38h			;7ef0	ff		.
	rst 38h			;7ef1	ff		.
	rst 38h			;7ef2	ff		.
	rst 38h			;7ef3	ff		.
	rst 38h			;7ef4	ff		.
	rst 38h			;7ef5	ff		.
	rst 38h			;7ef6	ff		.
	rst 38h			;7ef7	ff		.
	rst 38h			;7ef8	ff		.
	rst 38h			;7ef9	ff		.
	rst 38h			;7efa	ff		.
	rst 38h			;7efb	ff		.
	rst 38h			;7efc	ff		.
	rst 38h			;7efd	ff		.
	rst 38h			;7efe	ff		.
	rst 38h			;7eff	ff		.
	rst 38h			;7f00	ff		.
	rst 38h			;7f01	ff		.
	rst 38h			;7f02	ff		.
	rst 38h			;7f03	ff		.
	rst 38h			;7f04	ff		.
	rst 38h			;7f05	ff		.
	rst 38h			;7f06	ff		.
	rst 38h			;7f07	ff		.
	rst 38h			;7f08	ff		.
	rst 38h			;7f09	ff		.
	rst 38h			;7f0a	ff		.
	rst 38h			;7f0b	ff		.
	rst 38h			;7f0c	ff		.
	rst 38h			;7f0d	ff		.
	rst 38h			;7f0e	ff		.
	rst 38h			;7f0f	ff		.
	rst 38h			;7f10	ff		.
	rst 38h			;7f11	ff		.
	rst 38h			;7f12	ff		.
	rst 38h			;7f13	ff		.
	rst 38h			;7f14	ff		.
	rst 38h			;7f15	ff		.
	rst 38h			;7f16	ff		.
	rst 38h			;7f17	ff		.
	rst 38h			;7f18	ff		.
	rst 38h			;7f19	ff		.
	rst 38h			;7f1a	ff		.
	rst 38h			;7f1b	ff		.
	rst 38h			;7f1c	ff		.
	rst 38h			;7f1d	ff		.
	rst 38h			;7f1e	ff		.
	rst 38h			;7f1f	ff		.
	rst 38h			;7f20	ff		.
	rst 38h			;7f21	ff		.
	rst 38h			;7f22	ff		.
	rst 38h			;7f23	ff		.
	rst 38h			;7f24	ff		.
	rst 38h			;7f25	ff		.
	rst 38h			;7f26	ff		.
	rst 38h			;7f27	ff		.
	rst 38h			;7f28	ff		.
	rst 38h			;7f29	ff		.
	rst 38h			;7f2a	ff		.
	rst 38h			;7f2b	ff		.
	rst 38h			;7f2c	ff		.
	rst 38h			;7f2d	ff		.
	rst 38h			;7f2e	ff		.
	rst 38h			;7f2f	ff		.
	rst 38h			;7f30	ff		.
	rst 38h			;7f31	ff		.
	rst 38h			;7f32	ff		.
	rst 38h			;7f33	ff		.
	rst 38h			;7f34	ff		.
	rst 38h			;7f35	ff		.
	rst 38h			;7f36	ff		.
	rst 38h			;7f37	ff		.
	rst 38h			;7f38	ff		.
	rst 38h			;7f39	ff		.
	rst 38h			;7f3a	ff		.
	rst 38h			;7f3b	ff		.
	rst 38h			;7f3c	ff		.
	rst 38h			;7f3d	ff		.
	rst 38h			;7f3e	ff		.
	rst 38h			;7f3f	ff		.
	rst 38h			;7f40	ff		.
	rst 38h			;7f41	ff		.
	rst 38h			;7f42	ff		.
	rst 38h			;7f43	ff		.
	rst 38h			;7f44	ff		.
	rst 38h			;7f45	ff		.
	rst 38h			;7f46	ff		.
	rst 38h			;7f47	ff		.
	rst 38h			;7f48	ff		.
	rst 38h			;7f49	ff		.
	rst 38h			;7f4a	ff		.
	rst 38h			;7f4b	ff		.
	rst 38h			;7f4c	ff		.
	rst 38h			;7f4d	ff		.
	rst 38h			;7f4e	ff		.
	rst 38h			;7f4f	ff		.
	rst 38h			;7f50	ff		.
	rst 38h			;7f51	ff		.
	rst 38h			;7f52	ff		.
	rst 38h			;7f53	ff		.
	rst 38h			;7f54	ff		.
	rst 38h			;7f55	ff		.
	rst 38h			;7f56	ff		.
	rst 38h			;7f57	ff		.
	rst 38h			;7f58	ff		.
	rst 38h			;7f59	ff		.
	rst 38h			;7f5a	ff		.
	rst 38h			;7f5b	ff		.
	rst 38h			;7f5c	ff		.
	rst 38h			;7f5d	ff		.
	rst 38h			;7f5e	ff		.
	rst 38h			;7f5f	ff		.
	rst 38h			;7f60	ff		.
	rst 38h			;7f61	ff		.
	rst 38h			;7f62	ff		.
	rst 38h			;7f63	ff		.
	rst 38h			;7f64	ff		.
	rst 38h			;7f65	ff		.
	rst 38h			;7f66	ff		.
	rst 38h			;7f67	ff		.
	rst 38h			;7f68	ff		.
	rst 38h			;7f69	ff		.
	rst 38h			;7f6a	ff		.
	rst 38h			;7f6b	ff		.
	rst 38h			;7f6c	ff		.
	rst 38h			;7f6d	ff		.
	rst 38h			;7f6e	ff		.
	rst 38h			;7f6f	ff		.
	rst 38h			;7f70	ff		.
	rst 38h			;7f71	ff		.
	rst 38h			;7f72	ff		.
	rst 38h			;7f73	ff		.
	rst 38h			;7f74	ff		.
	rst 38h			;7f75	ff		.
	rst 38h			;7f76	ff		.
	rst 38h			;7f77	ff		.
	rst 38h			;7f78	ff		.
	rst 38h			;7f79	ff		.
	rst 38h			;7f7a	ff		.
	rst 38h			;7f7b	ff		.
	rst 38h			;7f7c	ff		.
	rst 38h			;7f7d	ff		.
	rst 38h			;7f7e	ff		.
	rst 38h			;7f7f	ff		.
	rst 38h			;7f80	ff		.
	rst 38h			;7f81	ff		.
	rst 38h			;7f82	ff		.
	rst 38h			;7f83	ff		.
	rst 38h			;7f84	ff		.
	rst 38h			;7f85	ff		.
	rst 38h			;7f86	ff		.
	rst 38h			;7f87	ff		.
	rst 38h			;7f88	ff		.
	rst 38h			;7f89	ff		.
	rst 38h			;7f8a	ff		.
	rst 38h			;7f8b	ff		.
	rst 38h			;7f8c	ff		.
	rst 38h			;7f8d	ff		.
	rst 38h			;7f8e	ff		.
	rst 38h			;7f8f	ff		.
	rst 38h			;7f90	ff		.
	rst 38h			;7f91	ff		.
	rst 38h			;7f92	ff		.
	rst 38h			;7f93	ff		.
	rst 38h			;7f94	ff		.
	rst 38h			;7f95	ff		.
	rst 38h			;7f96	ff		.
	rst 38h			;7f97	ff		.
	rst 38h			;7f98	ff		.
	rst 38h			;7f99	ff		.
	rst 38h			;7f9a	ff		.
	rst 38h			;7f9b	ff		.
	rst 38h			;7f9c	ff		.
	rst 38h			;7f9d	ff		.
	rst 38h			;7f9e	ff		.
	rst 38h			;7f9f	ff		.
	rst 38h			;7fa0	ff		.
	rst 38h			;7fa1	ff		.
	rst 38h			;7fa2	ff		.
	rst 38h			;7fa3	ff		.
	rst 38h			;7fa4	ff		.
	rst 38h			;7fa5	ff		.
	rst 38h			;7fa6	ff		.
	rst 38h			;7fa7	ff		.
	rst 38h			;7fa8	ff		.
	rst 38h			;7fa9	ff		.
	rst 38h			;7faa	ff		.
	rst 38h			;7fab	ff		.
	rst 38h			;7fac	ff		.
	rst 38h			;7fad	ff		.
	rst 38h			;7fae	ff		.
	rst 38h			;7faf	ff		.
	rst 38h			;7fb0	ff		.
	rst 38h			;7fb1	ff		.
	rst 38h			;7fb2	ff		.
	rst 38h			;7fb3	ff		.
	rst 38h			;7fb4	ff		.
	rst 38h			;7fb5	ff		.
	rst 38h			;7fb6	ff		.
	rst 38h			;7fb7	ff		.
	rst 38h			;7fb8	ff		.
	rst 38h			;7fb9	ff		.
	rst 38h			;7fba	ff		.
	rst 38h			;7fbb	ff		.
	rst 38h			;7fbc	ff		.
	rst 38h			;7fbd	ff		.
	rst 38h			;7fbe	ff		.
	rst 38h			;7fbf	ff		.
	rst 38h			;7fc0	ff		.
	rst 38h			;7fc1	ff		.
	rst 38h			;7fc2	ff		.
	rst 38h			;7fc3	ff		.
	rst 38h			;7fc4	ff		.
	rst 38h			;7fc5	ff		.
	rst 38h			;7fc6	ff		.
	rst 38h			;7fc7	ff		.
	rst 38h			;7fc8	ff		.
	rst 38h			;7fc9	ff		.
	rst 38h			;7fca	ff		.
	rst 38h			;7fcb	ff		.
	rst 38h			;7fcc	ff		.
	rst 38h			;7fcd	ff		.
	rst 38h			;7fce	ff		.
	rst 38h			;7fcf	ff		.
	rst 38h			;7fd0	ff		.
	rst 38h			;7fd1	ff		.
	rst 38h			;7fd2	ff		.
	rst 38h			;7fd3	ff		.
	rst 38h			;7fd4	ff		.
	rst 38h			;7fd5	ff		.
	rst 38h			;7fd6	ff		.
	rst 38h			;7fd7	ff		.
	rst 38h			;7fd8	ff		.
	rst 38h			;7fd9	ff		.
	rst 38h			;7fda	ff		.
	rst 38h			;7fdb	ff		.
	rst 38h			;7fdc	ff		.
	rst 38h			;7fdd	ff		.
	rst 38h			;7fde	ff		.
	rst 38h			;7fdf	ff		.
	rst 38h			;7fe0	ff		.
	rst 38h			;7fe1	ff		.
	rst 38h			;7fe2	ff		.
	rst 38h			;7fe3	ff		.
	rst 38h			;7fe4	ff		.
	rst 38h			;7fe5	ff		.
	rst 38h			;7fe6	ff		.
	rst 38h			;7fe7	ff		.
	rst 38h			;7fe8	ff		.
	rst 38h			;7fe9	ff		.
	rst 38h			;7fea	ff		.
	rst 38h			;7feb	ff		.
	rst 38h			;7fec	ff		.
	rst 38h			;7fed	ff		.
	rst 38h			;7fee	ff		.
	rst 38h			;7fef	ff		.
	rst 38h			;7ff0	ff		.
	rst 38h			;7ff1	ff		.
	rst 38h			;7ff2	ff		.
	rst 38h			;7ff3	ff		.
	rst 38h			;7ff4	ff		.
	rst 38h			;7ff5	ff		.
	rst 38h			;7ff6	ff		.
	rst 38h			;7ff7	ff		.
	rst 38h			;7ff8	ff		.
	rst 38h			;7ff9	ff		.
	rst 38h			;7ffa	ff		.
	rst 38h			;7ffb	ff		.
	rst 38h			;7ffc	ff		.
	rst 38h			;7ffd	ff		.
	rst 38h			;7ffe	ff		.
	rst 38h			;7fff	ff		.

; =============================================================================
; END OF Z80 COPROCESSOR ROM DISASSEMBLY
; =============================================================================