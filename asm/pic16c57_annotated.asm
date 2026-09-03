; =============================================================================
; SLEIC IO Moon — IC23 PIC16C57 DMD raster coprocessor — annotated disassembly
; =============================================================================
;
; Source image : roms/PIC16C57/PIC16F57-DIP28-1D05-20260815.bin
;                (MD5 a244f2d8060c2d92a814e20bdd55ecfe — recovered 2026-09-02
;                by a chip-recovery lab from the code-protected original;
;                authenticated 2048/2048 against the locked chip's scrambled
;                nibble-XOR read-back — see roms/PIC16C57/README.md and
;                research/pic16c57_protection_analysis.md)
; Device       : Microchip PIC16C57-HS/P (12-bit core, 2048x12 OTP, 20 I/O).
;                The recovered code also runs unmodified on the pin-compatible
;                flash PIC16F57 (same core/instruction set) — confirmed in the
;                real machine.
; Disassembly  : cross-verified with THREE independent disassemblers, which
;                agree on every one of the 150 programmed words:
;                  - gputils 1.5.2 gpdasm  (-p pic16c57)
;                  - MAME 0.288 unidasm    (-arch pic16c5x)
;                  - project Python decoder (validated against both)
; Program size : 150 words — code at 0x000-0x094, reset GOTO at 0x7FF,
;                everything else erased (0xFFF). No CALL/RETLW (stack unused),
;                no interrupts (the 16C5x core has none).
;
; -----------------------------------------------------------------------------
; WHAT THIS PROGRAM IS
; -----------------------------------------------------------------------------
; A free-running 128x32 plasma-panel raster sequencer. Per visible frame it
; scans TWO bitplanes of 32 rows each (plane 0 = MSB first, then plane 1 =
; LSB), matching the two-planes-per-frame wire format measured in
; docs/dmd_wire_protocol.md and the seg-7000h frame layout in
; docs/dmd_graphics.md. The PIC does NOT touch pixel data at all:
;   - It drives the video-RAM ADDRESS on PORTB (VA lines to the IC33 staging
;     SRAM / latch logic), stepping 2 addresses per row = 2 x 64-pixel bursts
;     per 128-dot row.
;   - External logic serialises the addressed data at DOTCLK rate (~599 kHz
;     measured); the PIC only waits for a "burst done" tick on T0CKI (TMR0 in
;     external-counter mode) before advancing.
;   - It sequences the row/latch/frame strobes on PORTA/PORTC.
; There is NO command interface in this program: the PIC never reads a data
; port (the single input pin RC7 is never sampled), and it has no path to the
; 80188 at all — it neither sends nor receives a byte. The panel simply
; displays whatever stands in the 80188's seg-7000h staging buffer when this
; raster scans it, and the 80188 sends no per-frame strobe either (the one
; PCS4 bit-3 pulse in its ROM fires once, from boot_init). See findings F13.
;
; -----------------------------------------------------------------------------
; REGISTER MAP (file registers)
; -----------------------------------------------------------------------------
;   0x08  half-row phase counter (1 -> 0; two 64-dot bursts per row)
;   0x09  row counter (plane 0: 0x1F down; plane 1: 0x20 down — both 32 rows,
;         the test sits before/after the decrement respectively)
;   0x0A  row-hold delay counter (plane 0: 200 iterations, plane 1: 30 —
;         see BRIGHTNESS WEIGHTING below)
;   0x0C  shadow copy of the PORTB video address (kept in sync so PORTB can
;         be rewritten without reading the port back; bit 6 = plane select)
;   0x0D/0x0E/0x0F  nested delay counters (boot delay, inter-frame gap)
;   0x10  written once with 0, ORed into PORTC — always zero, vestigial
;   0x0B and everything above 0x10: unused
;
; -----------------------------------------------------------------------------
; PORT USAGE (all directions set at boot; never changed)
; -----------------------------------------------------------------------------
;   PORTA (4 bits, all outputs), init 0x0D:
;     RA0  set at each PLANE start, cleared after the plane's first row —
;          a one-row-wide "start of plane" pulse. Best candidate for the
;          SDATA frame-marker line the wire protocol names as the external
;          frame-detect trigger.
;     RA1  set at row start, cleared at row end — row window strobe
;          (RCLK/COLLAT family).
;     RA2/RA3  complementary pair: row body = RA2 high/RA3 low, row latch =
;          RA2 low/RA3 high. Row-advance vs column-latch phases
;          (RCLK / COLLAT — exact pin naming needs the 011-029-07 sheet).
;   PORTB (8 bits, all outputs), video-RAM address VA lines:
;     plane 0 walks 0x00..0x3F, plane 1 walks 0x40..0x7F (bit 6 = plane).
;     64 addresses x 64-dot bursts = 4096 dots = one 128x32 bitplane.
;   PORTC, TRIS = 0x80 (RC7 input — unused; RC0-RC6 outputs), init 0x04:
;     RC2  burst handshake: dropped low, raised again after each T0CKI tick
;          group — the per-64-dot acknowledge/enable.
;     RC3  pulsed high across the long inter-frame delay — end-of-frame /
;          VSYNC (the >=100 us DE-low gap measured between frames).
;     RC0/RC1/RC4-RC6 never change (candidates for static VA3/VA4 low bits
;          or unused).
;   TMR0: OPTION = 0x28 -> T0CS=1 (count external T0CKI edges), T0SE=0
;     (rising edge), PSA=1 (no prescale on TMR0). The wait loops below spin
;     until TMR0 becomes nonzero, i.e. until the external serialiser signals
;     a completed 64-dot burst. This is the ONLY external input the program
;     uses — the PIC is a slave to the external dot clock.
;
; -----------------------------------------------------------------------------
; BRIGHTNESS WEIGHTING (driver-relevant!)
; -----------------------------------------------------------------------------
; The per-row hold delay differs per plane: 200 counts for plane 0 (MSB) vs
; 30 for plane 1 (LSB), ~6.7:1. The MSB plane is therefore displayed much
; longer than the LSB plane — this is the hardware source of the 4-level
; grey weighting that PinMAME's sleic.c models per-machine. (Inferred from
; the code; absolute times need the crystal frequency, which is not in the
; dump.)
;
; =============================================================================
; RESET
; =============================================================================
; The 16C5x starts executing at the TOP of memory:
;
;   7FF: A00   GOTO 0x000            ; reset vector -> program start
;
; =============================================================================
; 000-010: INIT — banks, option, port directions, idle levels
; =============================================================================
000: 4A3   BCF   STATUS,5           ; PA0=0 \ select page 0 for GOTOs
001: 4C3   BCF   STATUS,6           ; PA1=0 /  (program never leaves page 0)
002: 040   CLRW
003: C28   MOVLW 0x28
004: 002   OPTION                   ; T0CS=1: TMR0 counts external T0CKI
                                    ; rising edges, no prescaler (PSA=1)
005: 061   CLRF  TMR0
006: C80   MOVLW 0x80
007: 007   TRIS  7                  ; PORTC: RC7 input, RC0-RC6 outputs
008: C00   MOVLW 0x00
009: 005   TRIS  5                  ; PORTA: all 4 bits output
00A: 006   TRIS  6                  ; PORTB: all 8 bits output
00B: C00   MOVLW 0x00
00C: 026   MOVWF PORTB              ; video address = 0
00D: C0D   MOVLW 0x0D
00E: 025   MOVWF PORTA              ; RA0=1 RA1=0 RA2=1 RA3=1 (idle levels)
00F: C04   MOVLW 0x04
010: 027   MOVWF PORTC              ; RC2=1, everything else low
;
; =============================================================================
; 011-01F: POWER-ON DELAY — triple nested loop, 10 x 256 x 256 decrements
; =============================================================================
011: C0A   MOVLW 0x0A
012: 02D   MOVWF 0x0D               ; outer   = 10
013: CFF   MOVLW 0xFF
014: 02E   MOVWF 0x0E               ; middle  = 255 (reloads to 256)
015: CFF   MOVLW 0xFF
016: 02F   MOVWF 0x0F               ; inner   = 255
017: 0EF   DECF  0x0F,F
018: 743   BTFSS STATUS,2
019: A17   GOTO  0x017              ; inner spin
01A: 0EE   DECF  0x0E,F
01B: 743   BTFSS STATUS,2
01C: A15   GOTO  0x015
01D: 0ED   DECF  0x0D,F
01E: 743   BTFSS STATUS,2
01F: A13   GOTO  0x013              ; let the panel/PSU settle after power-up
;
; =============================================================================
; 020-051: PLANE 0 (MSB bitplane) — 32 rows, addresses 0x00-0x3F
; =============================================================================
020: 06C   CLRF  0x0C               ; address shadow = 0x00 (plane 0 base)
021: 20C   MOVF  0x0C,W
022: 026   MOVWF PORTB              ; VA <- 0x00
023: 070   CLRF  0x10               ; (0x10 is always 0 — vestigial)
024: 210   MOVF  0x10,W
025: D04   IORLW 0x04
026: 027   MOVWF PORTC              ; PORTC <- 0x04 (RC2 high, RC3 low)
027: 505   BSF   PORTA,0            ; RA0=1: START-OF-PLANE marker on
                                    ; (cleared after the first row, 0x04C)
028: C01   MOVLW 0x01
029: 028   MOVWF 0x08               ; 2 bursts (2x64 dots) per row
02A: C1F   MOVLW 0x1F
02B: 029   MOVWF 0x09               ; 31 more rows after this one (32 total)
;
; ---- per-row loop ------------------------------------------------------------
02C: 545   BSF   PORTA,2            ; row body phase:   RA2=1
02D: 465   BCF   PORTA,3            ;                   RA3=0
02E: 525   BSF   PORTA,1            ; RA1=1: row window open
; ---- per-64-dot-burst loop ---------------------------------------------------
02F: 447   BCF   PORTC,2            ; RC2 low: burst request/enable
030: 201   MOVF  TMR0,W
031: 643   BTFSC STATUS,2
032: A30   GOTO  0x030              ; spin until an external T0CKI tick
                                    ; (external serialiser finished 64 dots)
033: 061   CLRF  TMR0
034: 547   BSF   PORTC,2            ; RC2 high: burst acknowledged
035: 228   MOVF  0x08,F             ; both bursts done?
036: 643   BTFSC STATUS,2
037: A3D   GOTO  0x03D              ; yes -> row latch phase
038: 2A6   INCF  PORTB,F            ; no  -> advance video address
039: 447   BCF   PORTC,2
03A: 0E8   DECF  0x08,F
03B: 2AC   INCF  0x0C,F             ; keep the shadow in sync
03C: A30   GOTO  0x030              ; second burst of this row
; ---- row latch / illumination ------------------------------------------------
03D: 425   BCF   PORTA,1            ; RA1=0: row window closed
03E: 445   BCF   PORTA,2            ; latch phase:      RA2=0
03F: 565   BSF   PORTA,3            ;                   RA3=1
040: 525   BSF   PORTA,1            ; RA1 strobed high again (latch pulse)
041: C01   MOVLW 0x01
042: 028   MOVWF 0x08               ; reload burst counter for next row
043: 2AC   INCF  0x0C,F             ; odd address step (2 per row total)
044: 20C   MOVF  0x0C,W
045: 026   MOVWF PORTB              ; resync VA from shadow
046: CC8   MOVLW 0xC8
047: 02A   MOVWF 0x0A               ; row hold = 200  <-- MSB plane held LONG
048: 0EA   DECF  0x0A,F
049: 743   BTFSS STATUS,2
04A: A48   GOTO  0x048
04B: 425   BCF   PORTA,1
04C: 405   BCF   PORTA,0            ; RA0=0 (start-of-plane pulse ends after
                                    ; the first row; no-op on later rows)
04D: 229   MOVF  0x09,F             ; rows remaining?
04E: 643   BTFSC STATUS,2
04F: A52   GOTO  0x052              ; 0 -> plane 0 finished
050: 0E9   DECF  0x09,F
051: A2C   GOTO  0x02C              ; next row
;
; =============================================================================
; 052-082: PLANE 1 (LSB bitplane) — 32 rows, addresses 0x40-0x7F
;          (structurally identical to plane 0; differences flagged)
; =============================================================================
052: 06C   CLRF  0x0C
053: 5CC   BSF   0x0C,6             ; address shadow = 0x40 (plane-select bit)
054: 20C   MOVF  0x0C,W
055: 026   MOVWF PORTB              ; VA <- 0x40
056: C04   MOVLW 0x04
057: 027   MOVWF PORTC              ; (constant this time — no 0x10 detour)
058: 505   BSF   PORTA,0            ; RA0=1: start-of-plane marker again
059: C01   MOVLW 0x01
05A: 028   MOVWF 0x08
05B: C20   MOVLW 0x20
05C: 029   MOVWF 0x09               ; 32 rows (tested BEFORE decrement here,
                                    ; so both planes scan exactly 32 rows)
05D: 545   BSF   PORTA,2            ; -- per-row loop, same as 0x02C-0x051 --
05E: 465   BCF   PORTA,3
05F: 525   BSF   PORTA,1
060: 447   BCF   PORTC,2
061: 201   MOVF  TMR0,W
062: 643   BTFSC STATUS,2
063: A61   GOTO  0x061
064: 061   CLRF  TMR0
065: 547   BSF   PORTC,2
066: 228   MOVF  0x08,F
067: 643   BTFSC STATUS,2
068: A6E   GOTO  0x06E
069: 2A6   INCF  PORTB,F
06A: 447   BCF   PORTC,2
06B: 0E8   DECF  0x08,F
06C: 2AC   INCF  0x0C,F
06D: A61   GOTO  0x061
06E: 425   BCF   PORTA,1
06F: 445   BCF   PORTA,2
070: 565   BSF   PORTA,3
071: 525   BSF   PORTA,1
072: C01   MOVLW 0x01
073: 028   MOVWF 0x08
074: 2AC   INCF  0x0C,F
075: 20C   MOVF  0x0C,W
076: 026   MOVWF PORTB
077: C1E   MOVLW 0x1E
078: 02A   MOVWF 0x0A               ; row hold = 30  <-- LSB plane held SHORT
079: 0EA   DECF  0x0A,F             ;   (200:30 vs plane 0 — the grey-level
07A: 743   BTFSS STATUS,2           ;    time-weighting, see header)
07B: A79   GOTO  0x079
07C: 425   BCF   PORTA,1
07D: 405   BCF   PORTA,0
07E: 229   MOVF  0x09,F
07F: 643   BTFSC STATUS,2
080: A83   GOTO  0x083              ; plane 1 finished -> frame gap
081: 0E9   DECF  0x09,F
082: A5D   GOTO  0x05D
;
; =============================================================================
; 083-094: INTER-FRAME GAP — RC3 (VSYNC / end-of-frame) pulse + long delay
; =============================================================================
083: 567   BSF   PORTC,3            ; RC3=1: end-of-frame marker
084: C01   MOVLW 0x01
085: 02D   MOVWF 0x0D               ; outer  = 1
086: C23   MOVLW 0x23
087: 02E   MOVWF 0x0E               ; middle = 35
088: CC8   MOVLW 0xC8
089: 02F   MOVWF 0x0F               ; inner  = 200  (~7000 decrements total —
08A: 0EF   DECF  0x0F,F             ;  the >=100 us DE-low gap the wire
08B: 743   BTFSS STATUS,2           ;  protocol doc measures between frames)
08C: A8A   GOTO  0x08A
08D: 0EE   DECF  0x0E,F
08E: 743   BTFSS STATUS,2
08F: A88   GOTO  0x088
090: 0ED   DECF  0x0D,F
091: 743   BTFSS STATUS,2
092: A86   GOTO  0x086
093: 467   BCF   PORTC,3            ; RC3=0
094: A20   GOTO  0x020              ; next frame -> plane 0
;
; =============================================================================
; NO BYTE PATH TO THE 80188
; =============================================================================
; This program exchanges no byte with the 80188 in either direction, so an
; emulator has nothing to synthesise on its behalf: it delivers Z80 bytes and
; samples the seg-7000h buffer on the panel's own clock.
;
; 0xA0100 is PCS2, the inbound J1 latch, and it carries Z80 bytes and nothing
; else (findings F4). The bytes 0x47, 0x45 and 0x46 are ordinary Z80 replies on
; the C0FC event channel -- 0x47 is the Z80's boot "alive" byte (Z80 0410) and
; 0x45/0x46 the two answers to 80188 command 0xED (Z80 2BEB). They are not
; per-frame markers, and this program could not emit them in any case: every
; port bit here is a raster signal and the one input pin is never sampled.
;
; =============================================================================
; OPEN QUESTIONS (for the PinMAME driver work)
; =============================================================================
; 1. Pin-name mapping: RA0-RA3/RC2/RC3 vs the schematic nets (RDATA, RCLK,
;    COLLAT, DE, VSYNC, SDATA) needs sheet 011-029-07 read side-by-side with
;    this listing; the roles above are inferred from code structure + the
;    measured wire protocol.
; 2. Absolute timings require the PIC crystal frequency (not recoverable
;    from the dump; measure on the board or derive from the 599 kHz DOTCLK).
; =============================================================================
