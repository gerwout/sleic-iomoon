; z80dasm 1.1.6
; command line: z80dasm -a -t -l -g 0x0000 /home/gerwout/Downloads/sleic-pin-ball/sp04-1_1.rom

	org	00000h

l0000h:
	nop			;0000	00 	. 
	nop			;0001	00 	. 
l0002h:
	di			;0002	f3 	. 
	nop			;0003	00 	. 
	nop			;0004	00 	. 
l0005h:
	di			;0005	f3 	. 
	nop			;0006	00 	. 
	nop			;0007	00 	. 
	di			;0008	f3 	. 
	jp l0100h		;0009	c3 00 01 	. . . 
	nop			;000c	00 	. 
	jp l0100h		;000d	c3 00 01 	. . . 
	nop			;0010	00 	. 
	jp l0100h		;0011	c3 00 01 	. . . 
	nop			;0014	00 	. 
	nop			;0015	00 	. 
	nop			;0016	00 	. 
	nop			;0017	00 	. 
	nop			;0018	00 	. 
	nop			;0019	00 	. 
	nop			;001a	00 	. 
	nop			;001b	00 	. 
	nop			;001c	00 	. 
	nop			;001d	00 	. 
	nop			;001e	00 	. 
	nop			;001f	00 	. 
l0020h:
	nop			;0020	00 	. 
	nop			;0021	00 	. 
	nop			;0022	00 	. 
	nop			;0023	00 	. 
	nop			;0024	00 	. 
	nop			;0025	00 	. 
	nop			;0026	00 	. 
	nop			;0027	00 	. 
	nop			;0028	00 	. 
	nop			;0029	00 	. 
	nop			;002a	00 	. 
	nop			;002b	00 	. 
	nop			;002c	00 	. 
	nop			;002d	00 	. 
	nop			;002e	00 	. 
	nop			;002f	00 	. 
	nop			;0030	00 	. 
	nop			;0031	00 	. 
	nop			;0032	00 	. 
	nop			;0033	00 	. 
	nop			;0034	00 	. 
	nop			;0035	00 	. 
	nop			;0036	00 	. 
	nop			;0037	00 	. 
	jp l03cah		;0038	c3 ca 03 	. . . 
	nop			;003b	00 	. 
l003ch:
	nop			;003c	00 	. 
	nop			;003d	00 	. 
	nop			;003e	00 	. 
	nop			;003f	00 	. 
	nop			;0040	00 	. 
	nop			;0041	00 	. 
	nop			;0042	00 	. 
	nop			;0043	00 	. 
	nop			;0044	00 	. 
	nop			;0045	00 	. 
	nop			;0046	00 	. 
	nop			;0047	00 	. 
	nop			;0048	00 	. 
	nop			;0049	00 	. 
	nop			;004a	00 	. 
	nop			;004b	00 	. 
	nop			;004c	00 	. 
	nop			;004d	00 	. 
	nop			;004e	00 	. 
	nop			;004f	00 	. 
	nop			;0050	00 	. 
	nop			;0051	00 	. 
	nop			;0052	00 	. 
	nop			;0053	00 	. 
	nop			;0054	00 	. 
	nop			;0055	00 	. 
	nop			;0056	00 	. 
	nop			;0057	00 	. 
	nop			;0058	00 	. 
	nop			;0059	00 	. 
	nop			;005a	00 	. 
	nop			;005b	00 	. 
	nop			;005c	00 	. 
	nop			;005d	00 	. 
	nop			;005e	00 	. 
	nop			;005f	00 	. 
	nop			;0060	00 	. 
	nop			;0061	00 	. 
	nop			;0062	00 	. 
	nop			;0063	00 	. 
	nop			;0064	00 	. 
	nop			;0065	00 	. 
	ex af,af'			;0066	08 	. 
	exx			;0067	d9 	. 
	ld hl,(0c054h)		;0068	2a 54 c0 	* T . 
	ld a,(hl)			;006b	7e 	~ 
	and a			;006c	a7 	. 
	jp z,l008ah		;006d	ca 8a 00 	. . . 
	inc hl			;0070	23 	# 
	ld (0c054h),hl		;0071	22 54 c0 	" T . 
l0074h:
	ld a,(0c001h)		;0074	3a 01 c0 	: . . 
	or 010h		;0077	f6 10 	. . 
	out (081h),a		;0079	d3 81 	. . 
	in a,(000h)		;007b	db 00 	. . 
	ld (hl),a			;007d	77 	w 
	inc hl			;007e	23 	# 
	ld (hl),000h		;007f	36 00 	6 . 
	ld a,(0c001h)		;0081	3a 01 c0 	: . . 
	out (081h),a		;0084	d3 81 	. . 
	exx			;0086	d9 	. 
	ex af,af'			;0087	08 	. 
	retn		;0088	ed 45 	. E 
l008ah:
	ld hl,0c056h		;008a	21 56 c0 	! V . 
	ld (0c052h),hl		;008d	22 52 c0 	" R . 
	ld (0c054h),hl		;0090	22 54 c0 	" T . 
	jp l0074h		;0093	c3 74 00 	. t . 
	nop			;0096	00 	. 
	nop			;0097	00 	. 
	nop			;0098	00 	. 
	nop			;0099	00 	. 
	nop			;009a	00 	. 
	nop			;009b	00 	. 
	nop			;009c	00 	. 
	nop			;009d	00 	. 
	nop			;009e	00 	. 
	nop			;009f	00 	. 
	nop			;00a0	00 	. 
	nop			;00a1	00 	. 
	nop			;00a2	00 	. 
	nop			;00a3	00 	. 
	nop			;00a4	00 	. 
	nop			;00a5	00 	. 
	nop			;00a6	00 	. 
	nop			;00a7	00 	. 
	nop			;00a8	00 	. 
	nop			;00a9	00 	. 
	nop			;00aa	00 	. 
	nop			;00ab	00 	. 
	nop			;00ac	00 	. 
	nop			;00ad	00 	. 
	nop			;00ae	00 	. 
	nop			;00af	00 	. 
	nop			;00b0	00 	. 
	nop			;00b1	00 	. 
	nop			;00b2	00 	. 
	nop			;00b3	00 	. 
	nop			;00b4	00 	. 
	nop			;00b5	00 	. 
	nop			;00b6	00 	. 
	nop			;00b7	00 	. 
	nop			;00b8	00 	. 
	nop			;00b9	00 	. 
	nop			;00ba	00 	. 
	nop			;00bb	00 	. 
	nop			;00bc	00 	. 
	nop			;00bd	00 	. 
	nop			;00be	00 	. 
	nop			;00bf	00 	. 
	nop			;00c0	00 	. 
	nop			;00c1	00 	. 
	nop			;00c2	00 	. 
	nop			;00c3	00 	. 
	nop			;00c4	00 	. 
	nop			;00c5	00 	. 
	nop			;00c6	00 	. 
	nop			;00c7	00 	. 
l00c8h:
	nop			;00c8	00 	. 
	nop			;00c9	00 	. 
	nop			;00ca	00 	. 
	nop			;00cb	00 	. 
	nop			;00cc	00 	. 
	nop			;00cd	00 	. 
	nop			;00ce	00 	. 
	nop			;00cf	00 	. 
	nop			;00d0	00 	. 
	nop			;00d1	00 	. 
	nop			;00d2	00 	. 
	nop			;00d3	00 	. 
	nop			;00d4	00 	. 
	nop			;00d5	00 	. 
	nop			;00d6	00 	. 
	nop			;00d7	00 	. 
	nop			;00d8	00 	. 
	nop			;00d9	00 	. 
	nop			;00da	00 	. 
	nop			;00db	00 	. 
	nop			;00dc	00 	. 
	nop			;00dd	00 	. 
	nop			;00de	00 	. 
	nop			;00df	00 	. 
	nop			;00e0	00 	. 
	nop			;00e1	00 	. 
	nop			;00e2	00 	. 
	nop			;00e3	00 	. 
	nop			;00e4	00 	. 
	nop			;00e5	00 	. 
	nop			;00e6	00 	. 
	nop			;00e7	00 	. 
	nop			;00e8	00 	. 
	nop			;00e9	00 	. 
	nop			;00ea	00 	. 
	nop			;00eb	00 	. 
	nop			;00ec	00 	. 
	nop			;00ed	00 	. 
	nop			;00ee	00 	. 
	nop			;00ef	00 	. 
	nop			;00f0	00 	. 
	nop			;00f1	00 	. 
	nop			;00f2	00 	. 
	nop			;00f3	00 	. 
	nop			;00f4	00 	. 
	nop			;00f5	00 	. 
	nop			;00f6	00 	. 
	nop			;00f7	00 	. 
	nop			;00f8	00 	. 
	nop			;00f9	00 	. 
	nop			;00fa	00 	. 
	nop			;00fb	00 	. 
	nop			;00fc	00 	. 
	nop			;00fd	00 	. 
	nop			;00fe	00 	. 
l00ffh:
	nop			;00ff	00 	. 
l0100h:
	di			;0100	f3 	. 
	im 1		;0101	ed 56 	. V 
	ld sp,0c7ffh		;0103	31 ff c7 	1 . . 
	call sub_011dh		;0106	cd 1d 01 	. . . 
	call sub_0154h		;0109	cd 54 01 	. T . 
	ei			;010c	fb 	. 
	in a,(004h)		;010d	db 04 	. . 
	bit 7,a		;010f	cb 7f 	.  
	jp z,l011ah		;0111	ca 1a 01 	. . . 
	call sub_13eeh		;0114	cd ee 13 	. . . 
	jp l083eh		;0117	c3 3e 08 	. > . 
l011ah:
	jp l1741h		;011a	c3 41 17 	. A . 
sub_011dh:
	ld a,0ffh		;011d	3e ff 	> . 
	ld (0c005h),a		;011f	32 05 c0 	2 . . 
	out (085h),a		;0122	d3 85 	. . 
	ld (0c006h),a		;0124	32 06 c0 	2 . . 
	out (086h),a		;0127	d3 86 	. . 
	ld a,000h		;0129	3e 00 	> . 
	ld (0c007h),a		;012b	32 07 c0 	2 . . 
	out (087h),a		;012e	d3 87 	. . 
	ld a,000h		;0130	3e 00 	> . 
	ld (0c003h),a		;0132	32 03 c0 	2 . . 
	out (083h),a		;0135	d3 83 	. . 
	ld a,000h		;0137	3e 00 	> . 
	ld (0c004h),a		;0139	32 04 c0 	2 . . 
	out (084h),a		;013c	d3 84 	. . 
	ld a,000h		;013e	3e 00 	> . 
	ld (0c000h),a		;0140	32 00 c0 	2 . . 
	out (080h),a		;0143	d3 80 	. . 
	ld a,000h		;0145	3e 00 	> . 
	ld (0c001h),a		;0147	32 01 c0 	2 . . 
	out (081h),a		;014a	d3 81 	. . 
	ld a,000h		;014c	3e 00 	> . 
	ld (0c002h),a		;014e	32 02 c0 	2 . . 
	out (082h),a		;0151	d3 82 	. . 
	ret			;0153	c9 	. 
sub_0154h:
	ld hl,0c008h		;0154	21 08 c0 	! . . 
	ld b,04eh		;0157	06 4e 	. N 
l0159h:
	ld (hl),000h		;0159	36 00 	6 . 
	inc hl			;015b	23 	# 
	djnz l0159h		;015c	10 fb 	. . 
	ld hl,l1768h		;015e	21 68 17 	! h . 
	ld (0c0c5h),hl		;0161	22 c5 c0 	" . . 
	ld hl,l1bbdh		;0164	21 bd 1b 	! . . 
	ld (0c0efh),hl		;0167	22 ef c0 	" . . 
	ld hl,0c056h		;016a	21 56 c0 	! V . 
	ld (0c052h),hl		;016d	22 52 c0 	" R . 
	ld (0c054h),hl		;0170	22 54 c0 	" T . 
	ld (hl),000h		;0173	36 00 	6 . 
	ld hl,l0000h		;0175	21 00 00 	! . . 
	ld (0c020h),hl		;0178	22 20 c0 	"   . 
	ld (0c01eh),hl		;017b	22 1e c0 	" . . 
	ld (0c022h),hl		;017e	22 22 c0 	" " . 
	xor a			;0181	af 	. 
	ld (0c029h),a		;0182	32 29 c0 	2 ) . 
	ld (0c02ah),a		;0185	32 2a c0 	2 * . 
	ld (0c027h),a		;0188	32 27 c0 	2 ' . 
	ld (0c031h),a		;018b	32 31 c0 	2 1 . 
	ld (0c032h),a		;018e	32 32 c0 	2 2 . 
	ld (0c0dah),a		;0191	32 da c0 	2 . . 
	ld (0c0deh),a		;0194	32 de c0 	2 . . 
	ld (0c0dfh),a		;0197	32 df c0 	2 . . 
	ld (0c0e0h),a		;019a	32 e0 c0 	2 . . 
	ld (0c0e1h),a		;019d	32 e1 c0 	2 . . 
	ld (0c0e2h),a		;01a0	32 e2 c0 	2 . . 
	ld (0c034h),a		;01a3	32 34 c0 	2 4 . 
	ld (0c035h),a		;01a6	32 35 c0 	2 5 . 
	ld (0c036h),a		;01a9	32 36 c0 	2 6 . 
	ld (0c031h),a		;01ac	32 31 c0 	2 1 . 
	ld (0c026h),a		;01af	32 26 c0 	2 & . 
	ld (0c0f8h),a		;01b2	32 f8 c0 	2 . . 
	ld (0c0f1h),a		;01b5	32 f1 c0 	2 . . 
	ld (0c0fah),a		;01b8	32 fa c0 	2 . . 
	ld (0c039h),a		;01bb	32 39 c0 	2 9 . 
	ld (0c03ah),a		;01be	32 3a c0 	2 : . 
	ld (0c03bh),a		;01c1	32 3b c0 	2 ; . 
	ld (0c03ch),a		;01c4	32 3c c0 	2 < . 
	ld (0c03dh),a		;01c7	32 3d c0 	2 = . 
	ld (0c03eh),a		;01ca	32 3e c0 	2 > . 
	ld (0c03fh),a		;01cd	32 3f c0 	2 ? . 
	ld (0c040h),a		;01d0	32 40 c0 	2 @ . 
	ld (0c041h),a		;01d3	32 41 c0 	2 A . 
	ld (0c042h),a		;01d6	32 42 c0 	2 B . 
	ld (0c043h),a		;01d9	32 43 c0 	2 C . 
	ld (0c044h),a		;01dc	32 44 c0 	2 D . 
	ld (0c045h),a		;01df	32 45 c0 	2 E . 
	ld (0c046h),a		;01e2	32 46 c0 	2 F . 
	ld (0c047h),a		;01e5	32 47 c0 	2 G . 
	ld (0c048h),a		;01e8	32 48 c0 	2 H . 
	ld (0c049h),a		;01eb	32 49 c0 	2 I . 
	ld (0c04ah),a		;01ee	32 4a c0 	2 J . 
	ld (0c04bh),a		;01f1	32 4b c0 	2 K . 
l01f4h:
	ld (0c04ch),a		;01f4	32 4c c0 	2 L . 
	ld (0c04dh),a		;01f7	32 4d c0 	2 M . 
	ld (0c04eh),a		;01fa	32 4e c0 	2 N . 
	ld (0c04fh),a		;01fd	32 4f c0 	2 O . 
	ld (0c050h),a		;0200	32 50 c0 	2 P . 
	ld (0c038h),a		;0203	32 38 c0 	2 8 . 
	ld (0c051h),a		;0206	32 51 c0 	2 Q . 
	ld (0c024h),a		;0209	32 24 c0 	2 $ . 
	ld (0c025h),a		;020c	32 25 c0 	2 % . 
	ld a,00ah		;020f	3e 0a 	> . 
	ld (0c028h),a		;0211	32 28 c0 	2 ( . 
	ld a,0ffh		;0214	3e ff 	> . 
	ld (0c0bbh),a		;0216	32 bb c0 	2 . . 
	ld (0c0bch),a		;0219	32 bc c0 	2 . . 
	ld (0c0bdh),a		;021c	32 bd c0 	2 . . 
	ld (0c0beh),a		;021f	32 be c0 	2 . . 
	ld (0c0bfh),a		;0222	32 bf c0 	2 . . 
	ld (0c0c0h),a		;0225	32 c0 c0 	2 . . 
	ld (0c0c1h),a		;0228	32 c1 c0 	2 . . 
	ld (0c0c2h),a		;022b	32 c2 c0 	2 . . 
	ld (0c0c3h),a		;022e	32 c3 c0 	2 . . 
	ld (0c0e3h),a		;0231	32 e3 c0 	2 . . 
	ld (0c0e4h),a		;0234	32 e4 c0 	2 . . 
	ld (0c0e5h),a		;0237	32 e5 c0 	2 . . 
	ld (0c0e6h),a		;023a	32 e6 c0 	2 . . 
	ld (0c0e7h),a		;023d	32 e7 c0 	2 . . 
	ld (0c0f7h),a		;0240	32 f7 c0 	2 . . 
	ret			;0243	c9 	. 
l0244h:
	jr z,l025ah		;0244	28 14 	( . 
l0246h:
	inc d			;0246	14 	. 
l0247h:
	inc d			;0247	14 	. 
l0248h:
	jr z,$+32		;0248	28 1e 	( . 
sub_024ah:
	di			;024a	f3 	. 
	ld a,0ffh		;024b	3e ff 	> . 
	ld (0c008h),a		;024d	32 08 c0 	2 . . 
	ld a,(0c005h)		;0250	3a 05 c0 	: . . 
	and 0feh		;0253	e6 fe 	. . 
	ld (0c005h),a		;0255	32 05 c0 	2 . . 
	out (085h),a		;0258	d3 85 	. . 
l025ah:
	ld a,(l0244h)		;025a	3a 44 02 	: D . 
	ld (0c014h),a		;025d	32 14 c0 	2 . . 
	xor a			;0260	af 	. 
	ld (0c045h),a		;0261	32 45 c0 	2 E . 
	ei			;0264	fb 	. 
	ret			;0265	c9 	. 
sub_0266h:
	di			;0266	f3 	. 
	ld a,0ffh		;0267	3e ff 	> . 
	ld (0c009h),a		;0269	32 09 c0 	2 . . 
	ld a,(0c005h)		;026c	3a 05 c0 	: . . 
	and 0fbh		;026f	e6 fb 	. . 
	ld (0c005h),a		;0271	32 05 c0 	2 . . 
	out (085h),a		;0274	d3 85 	. . 
	ld a,(l0244h)		;0276	3a 44 02 	: D . 
	ld (0c015h),a		;0279	32 15 c0 	2 . . 
	xor a			;027c	af 	. 
	ld (0c047h),a		;027d	32 47 c0 	2 G . 
	ei			;0280	fb 	. 
	ret			;0281	c9 	. 
sub_0282h:
	di			;0282	f3 	. 
	ld a,0ffh		;0283	3e ff 	> . 
	ld (0c00ah),a		;0285	32 0a c0 	2 . . 
	ld a,(0c006h)		;0288	3a 06 c0 	: . . 
	and 0feh		;028b	e6 fe 	. . 
	ld (0c006h),a		;028d	32 06 c0 	2 . . 
	out (086h),a		;0290	d3 86 	. . 
	ld a,(l0244h+1)		;0292	3a 45 02 	: E . 
	ld (0c016h),a		;0295	32 16 c0 	2 . . 
	xor a			;0298	af 	. 
	ld (0c049h),a		;0299	32 49 c0 	2 I . 
	ei			;029c	fb 	. 
	ret			;029d	c9 	. 
sub_029eh:
	di			;029e	f3 	. 
	ld a,0ffh		;029f	3e ff 	> . 
	ld (0c00bh),a		;02a1	32 0b c0 	2 . . 
	ld a,(0c006h)		;02a4	3a 06 c0 	: . . 
	and 0fdh		;02a7	e6 fd 	. . 
	ld (0c006h),a		;02a9	32 06 c0 	2 . . 
	out (086h),a		;02ac	d3 86 	. . 
	ld a,(l0244h+1)		;02ae	3a 45 02 	: E . 
	ld (0c017h),a		;02b1	32 17 c0 	2 . . 
	xor a			;02b4	af 	. 
	ld (0c04ah),a		;02b5	32 4a c0 	2 J . 
	ei			;02b8	fb 	. 
	ret			;02b9	c9 	. 
sub_02bah:
	di			;02ba	f3 	. 
	ld a,0ffh		;02bb	3e ff 	> . 
	ld (0c00ch),a		;02bd	32 0c c0 	2 . . 
	ld a,(0c006h)		;02c0	3a 06 c0 	: . . 
	and 0fbh		;02c3	e6 fb 	. . 
	ld (0c006h),a		;02c5	32 06 c0 	2 . . 
	out (086h),a		;02c8	d3 86 	. . 
	ld a,(l0246h)		;02ca	3a 46 02 	: F . 
	ld (0c018h),a		;02cd	32 18 c0 	2 . . 
	xor a			;02d0	af 	. 
	ld (0c04bh),a		;02d1	32 4b c0 	2 K . 
	ei			;02d4	fb 	. 
	ret			;02d5	c9 	. 
sub_02d6h:
	di			;02d6	f3 	. 
	ld a,0ffh		;02d7	3e ff 	> . 
	ld (0c00dh),a		;02d9	32 0d c0 	2 . . 
	ld a,(0c006h)		;02dc	3a 06 c0 	: . . 
	and 0f7h		;02df	e6 f7 	. . 
	ld (0c006h),a		;02e1	32 06 c0 	2 . . 
	out (086h),a		;02e4	d3 86 	. . 
	ld a,(l0246h)		;02e6	3a 46 02 	: F . 
	ld (0c019h),a		;02e9	32 19 c0 	2 . . 
	xor a			;02ec	af 	. 
	ld (0c04ch),a		;02ed	32 4c c0 	2 L . 
	ei			;02f0	fb 	. 
	ret			;02f1	c9 	. 
sub_02f2h:
	di			;02f2	f3 	. 
	ld a,0ffh		;02f3	3e ff 	> . 
	ld (0c00eh),a		;02f5	32 0e c0 	2 . . 
	ld a,(0c006h)		;02f8	3a 06 c0 	: . . 
	and 0efh		;02fb	e6 ef 	. . 
	ld (0c006h),a		;02fd	32 06 c0 	2 . . 
	out (086h),a		;0300	d3 86 	. . 
	ld a,(l0247h)		;0302	3a 47 02 	: G . 
	ld (0c01ah),a		;0305	32 1a c0 	2 . . 
	xor a			;0308	af 	. 
	ld (0c04dh),a		;0309	32 4d c0 	2 M . 
	ei			;030c	fb 	. 
	ret			;030d	c9 	. 
sub_030eh:
	di			;030e	f3 	. 
	ld a,0ffh		;030f	3e ff 	> . 
	ld (0c00fh),a		;0311	32 0f c0 	2 . . 
	ld a,(0c006h)		;0314	3a 06 c0 	: . . 
	and 0dfh		;0317	e6 df 	. . 
	ld (0c006h),a		;0319	32 06 c0 	2 . . 
	out (086h),a		;031c	d3 86 	. . 
	ld a,(l0247h)		;031e	3a 47 02 	: G . 
	ld (0c01bh),a		;0321	32 1b c0 	2 . . 
	xor a			;0324	af 	. 
	ld (0c04eh),a		;0325	32 4e c0 	2 N . 
	ei			;0328	fb 	. 
	ret			;0329	c9 	. 
sub_032ah:
	di			;032a	f3 	. 
	ld a,0ffh		;032b	3e ff 	> . 
	ld (0c010h),a		;032d	32 10 c0 	2 . . 
	ld a,(0c006h)		;0330	3a 06 c0 	: . . 
	and 0bfh		;0333	e6 bf 	. . 
	ld (0c006h),a		;0335	32 06 c0 	2 . . 
	out (086h),a		;0338	d3 86 	. . 
	ld a,(l0248h)		;033a	3a 48 02 	: H . 
	ld (0c01ch),a		;033d	32 1c c0 	2 . . 
	xor a			;0340	af 	. 
	ld (0c04fh),a		;0341	32 4f c0 	2 O . 
	ei			;0344	fb 	. 
	ret			;0345	c9 	. 
sub_0346h:
	di			;0346	f3 	. 
	ld a,0ffh		;0347	3e ff 	> . 
	ld (0c011h),a		;0349	32 11 c0 	2 . . 
	ld a,(0c006h)		;034c	3a 06 c0 	: . . 
	and 07fh		;034f	e6 7f 	.  
	ld (0c006h),a		;0351	32 06 c0 	2 . . 
	out (086h),a		;0354	d3 86 	. . 
	ld a,(l0248h+1)		;0356	3a 49 02 	: I . 
	ld (0c01dh),a		;0359	32 1d c0 	2 . . 
	xor a			;035c	af 	. 
	ld (0c050h),a		;035d	32 50 c0 	2 P . 
	ei			;0360	fb 	. 
	ret			;0361	c9 	. 
sub_0362h:
	ld hl,l03e8h		;0362	21 e8 03 	! . . 
	ld (0c01eh),hl		;0365	22 1e c0 	" . . 
	di			;0368	f3 	. 
	ld a,0ffh		;0369	3e ff 	> . 
	ld (0c012h),a		;036b	32 12 c0 	2 . . 
	ld a,(0c005h)		;036e	3a 05 c0 	: . . 
	and 0fdh		;0371	e6 fd 	. . 
	ld (0c005h),a		;0373	32 05 c0 	2 . . 
	out (085h),a		;0376	d3 85 	. . 
	ld a,(l0244h)		;0378	3a 44 02 	: D . 
	ld (0c0bah),a		;037b	32 ba c0 	2 . . 
	xor a			;037e	af 	. 
	ld (0c046h),a		;037f	32 46 c0 	2 F . 
	ei			;0382	fb 	. 
	ret			;0383	c9 	. 
sub_0384h:
	ld hl,l03e8h		;0384	21 e8 03 	! . . 
	ld (0c020h),hl		;0387	22 20 c0 	"   . 
	di			;038a	f3 	. 
	ld a,0ffh		;038b	3e ff 	> . 
	ld (0c013h),a		;038d	32 13 c0 	2 . . 
	ld a,(0c005h)		;0390	3a 05 c0 	: . . 
	and 0f7h		;0393	e6 f7 	. . 
	ld (0c005h),a		;0395	32 05 c0 	2 . . 
	out (085h),a		;0398	d3 85 	. . 
	ld a,(l0244h)		;039a	3a 44 02 	: D . 
	ld (0c0bah),a		;039d	32 ba c0 	2 . . 
	xor a			;03a0	af 	. 
	ld (0c048h),a		;03a1	32 48 c0 	2 H . 
	ei			;03a4	fb 	. 
	ret			;03a5	c9 	. 
sub_03a6h:
	xor a			;03a6	af 	. 
	ld (0c012h),a		;03a7	32 12 c0 	2 . . 
	ld (0c03ah),a		;03aa	32 3a c0 	2 : . 
	ld a,(0c005h)		;03ad	3a 05 c0 	: . . 
	or 002h		;03b0	f6 02 	. . 
	ld (0c005h),a		;03b2	32 05 c0 	2 . . 
	out (085h),a		;03b5	d3 85 	. . 
	ret			;03b7	c9 	. 
sub_03b8h:
	xor a			;03b8	af 	. 
	ld (0c013h),a		;03b9	32 13 c0 	2 . . 
	ld (0c03ch),a		;03bc	32 3c c0 	2 < . 
	ld a,(0c005h)		;03bf	3a 05 c0 	: . . 
	or 008h		;03c2	f6 08 	. . 
	ld (0c005h),a		;03c4	32 05 c0 	2 . . 
	out (085h),a		;03c7	d3 85 	. . 
	ret			;03c9	c9 	. 
l03cah:
	di			;03ca	f3 	. 
	push af			;03cb	f5 	. 
	push bc			;03cc	c5 	. 
	push de			;03cd	d5 	. 
	push hl			;03ce	e5 	. 
	call sub_1ba8h		;03cf	cd a8 1b 	. . . 
	call sub_1752h		;03d2	cd 52 17 	. R . 
	ld a,(0c026h)		;03d5	3a 26 c0 	: & . 
	and a			;03d8	a7 	. 
	jp nz,l05adh		;03d9	c2 ad 05 	. . . 
	ld a,0ffh		;03dc	3e ff 	> . 
	ld (0c026h),a		;03de	32 26 c0 	2 & . 
	ld a,(0c007h)		;03e1	3a 07 c0 	: . . 
	and 0f0h		;03e4	e6 f0 	. . 
	or 000h		;03e6	f6 00 	. . 
l03e8h:
	ld (0c007h),a		;03e8	32 07 c0 	2 . . 
	out (087h),a		;03eb	d3 87 	. . 
	ld a,(0c008h)		;03ed	3a 08 c0 	: . . 
	and a			;03f0	a7 	. 
	jp nz,l0402h		;03f1	c2 02 04 	. . . 
	in a,(001h)		;03f4	db 01 	. . 
	bit 5,a		;03f6	cb 6f 	. o 
	jp nz,l0432h		;03f8	c2 32 04 	. 2 . 
	ld hl,0c039h		;03fb	21 39 c0 	! 9 . 
	inc (hl)			;03fe	34 	4 
	jp l0436h		;03ff	c3 36 04 	. 6 . 
l0402h:
	ld hl,0c014h		;0402	21 14 c0 	! . . 
	dec (hl)			;0405	35 	5 
	jp z,l0417h		;0406	ca 17 04 	. . . 
	in a,(001h)		;0409	db 01 	. . 
	bit 5,a		;040b	cb 6f 	. o 
	jp z,l042bh		;040d	ca 2b 04 	. + . 
	ld hl,0c045h		;0410	21 45 c0 	! E . 
	inc (hl)			;0413	34 	4 
	jp l0436h		;0414	c3 36 04 	. 6 . 
l0417h:
	xor a			;0417	af 	. 
	ld (0c008h),a		;0418	32 08 c0 	2 . . 
	ld (0c039h),a		;041b	32 39 c0 	2 9 . 
	ld a,(0c005h)		;041e	3a 05 c0 	: . . 
	or 001h		;0421	f6 01 	. . 
	ld (0c005h),a		;0423	32 05 c0 	2 . . 
	out (085h),a		;0426	d3 85 	. . 
	call sub_0362h		;0428	cd 62 03 	. b . 
l042bh:
	xor a			;042b	af 	. 
	ld (0c045h),a		;042c	32 45 c0 	2 E . 
	jp l0436h		;042f	c3 36 04 	. 6 . 
l0432h:
	xor a			;0432	af 	. 
	ld (0c039h),a		;0433	32 39 c0 	2 9 . 
l0436h:
	ld a,(0c007h)		;0436	3a 07 c0 	: . . 
	and 0f0h		;0439	e6 f0 	. . 
	or 001h		;043b	f6 01 	. . 
	ld (0c007h),a		;043d	32 07 c0 	2 . . 
	out (087h),a		;0440	d3 87 	. . 
	ld a,(0c012h)		;0442	3a 12 c0 	: . . 
	and a			;0445	a7 	. 
	jp z,l045eh		;0446	ca 5e 04 	. ^ . 
	in a,(001h)		;0449	db 01 	. . 
	bit 5,a		;044b	cb 6f 	. o 
	jp z,l0457h		;044d	ca 57 04 	. W . 
	ld hl,0c046h		;0450	21 46 c0 	! F . 
	inc (hl)			;0453	34 	4 
	jp l0470h		;0454	c3 70 04 	. p . 
l0457h:
	xor a			;0457	af 	. 
	ld (0c046h),a		;0458	32 46 c0 	2 F . 
	jp l0470h		;045b	c3 70 04 	. p . 
l045eh:
	in a,(001h)		;045e	db 01 	. . 
	bit 5,a		;0460	cb 6f 	. o 
	jp nz,l046ch		;0462	c2 6c 04 	. l . 
	ld hl,0c03ah		;0465	21 3a c0 	! : . 
	inc (hl)			;0468	34 	4 
	jp l0470h		;0469	c3 70 04 	. p . 
l046ch:
	xor a			;046c	af 	. 
	ld (0c03ah),a		;046d	32 3a c0 	2 : . 
l0470h:
	ld a,(0c007h)		;0470	3a 07 c0 	: . . 
	and 0f0h		;0473	e6 f0 	. . 
	or 002h		;0475	f6 02 	. . 
	ld (0c007h),a		;0477	32 07 c0 	2 . . 
	out (087h),a		;047a	d3 87 	. . 
	ld a,(0c009h)		;047c	3a 09 c0 	: . . 
	and a			;047f	a7 	. 
	jp nz,l0491h		;0480	c2 91 04 	. . . 
	in a,(001h)		;0483	db 01 	. . 
	bit 5,a		;0485	cb 6f 	. o 
	jp nz,l04c1h		;0487	c2 c1 04 	. . . 
	ld hl,0c03bh		;048a	21 3b c0 	! ; . 
	inc (hl)			;048d	34 	4 
	jp l04c5h		;048e	c3 c5 04 	. . . 
l0491h:
	ld hl,0c015h		;0491	21 15 c0 	! . . 
	dec (hl)			;0494	35 	5 
	jp z,l04a6h		;0495	ca a6 04 	. . . 
	in a,(001h)		;0498	db 01 	. . 
	bit 5,a		;049a	cb 6f 	. o 
	jp z,l04bah		;049c	ca ba 04 	. . . 
	ld hl,0c047h		;049f	21 47 c0 	! G . 
	inc (hl)			;04a2	34 	4 
	jp l04c5h		;04a3	c3 c5 04 	. . . 
l04a6h:
	xor a			;04a6	af 	. 
	ld (0c009h),a		;04a7	32 09 c0 	2 . . 
	ld (0c03bh),a		;04aa	32 3b c0 	2 ; . 
	ld a,(0c005h)		;04ad	3a 05 c0 	: . . 
	or 004h		;04b0	f6 04 	. . 
	ld (0c005h),a		;04b2	32 05 c0 	2 . . 
	out (085h),a		;04b5	d3 85 	. . 
	call sub_0384h		;04b7	cd 84 03 	. . . 
l04bah:
	xor a			;04ba	af 	. 
	ld (0c047h),a		;04bb	32 47 c0 	2 G . 
	jp l04c5h		;04be	c3 c5 04 	. . . 
l04c1h:
	xor a			;04c1	af 	. 
	ld (0c03bh),a		;04c2	32 3b c0 	2 ; . 
l04c5h:
	ld a,(0c007h)		;04c5	3a 07 c0 	: . . 
	and 0f0h		;04c8	e6 f0 	. . 
	or 003h		;04ca	f6 03 	. . 
	ld (0c007h),a		;04cc	32 07 c0 	2 . . 
	out (087h),a		;04cf	d3 87 	. . 
	ld a,(0c013h)		;04d1	3a 13 c0 	: . . 
	and a			;04d4	a7 	. 
	jp z,l04edh		;04d5	ca ed 04 	. . . 
	in a,(001h)		;04d8	db 01 	. . 
	bit 5,a		;04da	cb 6f 	. o 
	jp z,l04e6h		;04dc	ca e6 04 	. . . 
	ld hl,0c048h		;04df	21 48 c0 	! H . 
	inc (hl)			;04e2	34 	4 
	jp l04ffh		;04e3	c3 ff 04 	. . . 
l04e6h:
	xor a			;04e6	af 	. 
	ld (0c048h),a		;04e7	32 48 c0 	2 H . 
	jp l04ffh		;04ea	c3 ff 04 	. . . 
l04edh:
	in a,(001h)		;04ed	db 01 	. . 
	bit 5,a		;04ef	cb 6f 	. o 
	jp nz,l04fbh		;04f1	c2 fb 04 	. . . 
	ld hl,0c03ch		;04f4	21 3c c0 	! < . 
	inc (hl)			;04f7	34 	4 
	jp l04ffh		;04f8	c3 ff 04 	. . . 
l04fbh:
	xor a			;04fb	af 	. 
	ld (0c03ch),a		;04fc	32 3c c0 	2 < . 
l04ffh:
	ld a,(0c007h)		;04ff	3a 07 c0 	: . . 
	and 0f0h		;0502	e6 f0 	. . 
	or 008h		;0504	f6 08 	. . 
	ld (0c007h),a		;0506	32 07 c0 	2 . . 
	out (087h),a		;0509	d3 87 	. . 
	ld a,(0c00ah)		;050b	3a 0a c0 	: . . 
	and a			;050e	a7 	. 
	jp nz,l0520h		;050f	c2 20 05 	.   . 
	in a,(001h)		;0512	db 01 	. . 
	bit 5,a		;0514	cb 6f 	. o 
	jp nz,l054dh		;0516	c2 4d 05 	. M . 
	ld hl,0c03dh		;0519	21 3d c0 	! = . 
	inc (hl)			;051c	34 	4 
	jp l0551h		;051d	c3 51 05 	. Q . 
l0520h:
	ld hl,0c016h		;0520	21 16 c0 	! . . 
	dec (hl)			;0523	35 	5 
	jp z,l0535h		;0524	ca 35 05 	. 5 . 
	in a,(001h)		;0527	db 01 	. . 
	bit 5,a		;0529	cb 6f 	. o 
	jp z,l0546h		;052b	ca 46 05 	. F . 
	ld hl,0c049h		;052e	21 49 c0 	! I . 
	inc (hl)			;0531	34 	4 
	jp l0551h		;0532	c3 51 05 	. Q . 
l0535h:
	xor a			;0535	af 	. 
	ld (0c00ah),a		;0536	32 0a c0 	2 . . 
	ld (0c03dh),a		;0539	32 3d c0 	2 = . 
	ld a,(0c006h)		;053c	3a 06 c0 	: . . 
	or 001h		;053f	f6 01 	. . 
	ld (0c006h),a		;0541	32 06 c0 	2 . . 
	out (086h),a		;0544	d3 86 	. . 
l0546h:
	xor a			;0546	af 	. 
	ld (0c049h),a		;0547	32 49 c0 	2 I . 
	jp l0551h		;054a	c3 51 05 	. Q . 
l054dh:
	xor a			;054d	af 	. 
	ld (0c03dh),a		;054e	32 3d c0 	2 = . 
l0551h:
	ld a,(0c007h)		;0551	3a 07 c0 	: . . 
	and 0f0h		;0554	e6 f0 	. . 
	or 009h		;0556	f6 09 	. . 
	ld (0c007h),a		;0558	32 07 c0 	2 . . 
	out (087h),a		;055b	d3 87 	. . 
	ld a,(0c00bh)		;055d	3a 0b c0 	: . . 
	and a			;0560	a7 	. 
	jp nz,l0572h		;0561	c2 72 05 	. r . 
	in a,(001h)		;0564	db 01 	. . 
	bit 5,a		;0566	cb 6f 	. o 
	jp nz,l059fh		;0568	c2 9f 05 	. . . 
	ld hl,0c03eh		;056b	21 3e c0 	! > . 
	inc (hl)			;056e	34 	4 
	jp l05a3h		;056f	c3 a3 05 	. . . 
l0572h:
	ld hl,0c017h		;0572	21 17 c0 	! . . 
	dec (hl)			;0575	35 	5 
	jp z,l0587h		;0576	ca 87 05 	. . . 
	in a,(001h)		;0579	db 01 	. . 
	bit 5,a		;057b	cb 6f 	. o 
	jp z,l0598h		;057d	ca 98 05 	. . . 
	ld hl,0c04ah		;0580	21 4a c0 	! J . 
	inc (hl)			;0583	34 	4 
	jp l05a3h		;0584	c3 a3 05 	. . . 
l0587h:
	xor a			;0587	af 	. 
	ld (0c00bh),a		;0588	32 0b c0 	2 . . 
	ld (0c03eh),a		;058b	32 3e c0 	2 > . 
	ld a,(0c006h)		;058e	3a 06 c0 	: . . 
	or 002h		;0591	f6 02 	. . 
	ld (0c006h),a		;0593	32 06 c0 	2 . . 
	out (086h),a		;0596	d3 86 	. . 
l0598h:
	xor a			;0598	af 	. 
	ld (0c04ah),a		;0599	32 4a c0 	2 J . 
	jp l05a3h		;059c	c3 a3 05 	. . . 
l059fh:
	xor a			;059f	af 	. 
	ld (0c03eh),a		;05a0	32 3e c0 	2 > . 
l05a3h:
	call sub_07a7h		;05a3	cd a7 07 	. . . 
	pop hl			;05a6	e1 	. 
	pop de			;05a7	d1 	. 
	pop bc			;05a8	c1 	. 
	pop af			;05a9	f1 	. 
	ei			;05aa	fb 	. 
	reti		;05ab	ed 4d 	. M 
l05adh:
	xor a			;05ad	af 	. 
	ld (0c026h),a		;05ae	32 26 c0 	2 & . 
	ld a,(0c007h)		;05b1	3a 07 c0 	: . . 
	and 0f0h		;05b4	e6 f0 	. . 
	or 00ah		;05b6	f6 0a 	. . 
	ld (0c007h),a		;05b8	32 07 c0 	2 . . 
	out (087h),a		;05bb	d3 87 	. . 
	ld a,(0c00ch)		;05bd	3a 0c c0 	: . . 
	and a			;05c0	a7 	. 
	jp nz,l05d2h		;05c1	c2 d2 05 	. . . 
	in a,(001h)		;05c4	db 01 	. . 
	bit 5,a		;05c6	cb 6f 	. o 
	jp nz,l05ffh		;05c8	c2 ff 05 	. . . 
	ld hl,0c03fh		;05cb	21 3f c0 	! ? . 
	inc (hl)			;05ce	34 	4 
	jp l0603h		;05cf	c3 03 06 	. . . 
l05d2h:
	ld hl,0c018h		;05d2	21 18 c0 	! . . 
	dec (hl)			;05d5	35 	5 
	jp z,l05e7h		;05d6	ca e7 05 	. . . 
	in a,(001h)		;05d9	db 01 	. . 
	bit 5,a		;05db	cb 6f 	. o 
	jp z,l05f8h		;05dd	ca f8 05 	. . . 
	ld hl,0c04bh		;05e0	21 4b c0 	! K . 
	inc (hl)			;05e3	34 	4 
	jp l0603h		;05e4	c3 03 06 	. . . 
l05e7h:
	xor a			;05e7	af 	. 
	ld (0c00ch),a		;05e8	32 0c c0 	2 . . 
	ld (0c03fh),a		;05eb	32 3f c0 	2 ? . 
	ld a,(0c006h)		;05ee	3a 06 c0 	: . . 
	or 004h		;05f1	f6 04 	. . 
	ld (0c006h),a		;05f3	32 06 c0 	2 . . 
	out (086h),a		;05f6	d3 86 	. . 
l05f8h:
	xor a			;05f8	af 	. 
	ld (0c04bh),a		;05f9	32 4b c0 	2 K . 
	jp l0603h		;05fc	c3 03 06 	. . . 
l05ffh:
	xor a			;05ff	af 	. 
	ld (0c03fh),a		;0600	32 3f c0 	2 ? . 
l0603h:
	ld a,(0c007h)		;0603	3a 07 c0 	: . . 
	and 0f0h		;0606	e6 f0 	. . 
	or 00bh		;0608	f6 0b 	. . 
	ld (0c007h),a		;060a	32 07 c0 	2 . . 
	out (087h),a		;060d	d3 87 	. . 
	ld a,(0c00dh)		;060f	3a 0d c0 	: . . 
	and a			;0612	a7 	. 
	jp nz,l0624h		;0613	c2 24 06 	. $ . 
	in a,(001h)		;0616	db 01 	. . 
	bit 5,a		;0618	cb 6f 	. o 
	jp nz,l0651h		;061a	c2 51 06 	. Q . 
	ld hl,0c040h		;061d	21 40 c0 	! @ . 
	inc (hl)			;0620	34 	4 
	jp l0655h		;0621	c3 55 06 	. U . 
l0624h:
	ld hl,0c019h		;0624	21 19 c0 	! . . 
	dec (hl)			;0627	35 	5 
	jp z,l0639h		;0628	ca 39 06 	. 9 . 
	in a,(001h)		;062b	db 01 	. . 
	bit 5,a		;062d	cb 6f 	. o 
	jp z,l064ah		;062f	ca 4a 06 	. J . 
	ld hl,0c04ch		;0632	21 4c c0 	! L . 
	inc (hl)			;0635	34 	4 
	jp l0655h		;0636	c3 55 06 	. U . 
l0639h:
	xor a			;0639	af 	. 
	ld (0c00dh),a		;063a	32 0d c0 	2 . . 
	ld (0c040h),a		;063d	32 40 c0 	2 @ . 
	ld a,(0c006h)		;0640	3a 06 c0 	: . . 
	or 008h		;0643	f6 08 	. . 
	ld (0c006h),a		;0645	32 06 c0 	2 . . 
	out (086h),a		;0648	d3 86 	. . 
l064ah:
	xor a			;064a	af 	. 
	ld (0c04ch),a		;064b	32 4c c0 	2 L . 
	jp l0655h		;064e	c3 55 06 	. U . 
l0651h:
	xor a			;0651	af 	. 
	ld (0c040h),a		;0652	32 40 c0 	2 @ . 
l0655h:
	ld a,(0c007h)		;0655	3a 07 c0 	: . . 
	and 0f0h		;0658	e6 f0 	. . 
	or 00ch		;065a	f6 0c 	. . 
	ld (0c007h),a		;065c	32 07 c0 	2 . . 
	out (087h),a		;065f	d3 87 	. . 
	ld a,(0c00eh)		;0661	3a 0e c0 	: . . 
	and a			;0664	a7 	. 
	jp nz,l0676h		;0665	c2 76 06 	. v . 
	in a,(001h)		;0668	db 01 	. . 
	bit 5,a		;066a	cb 6f 	. o 
	jp nz,l06a3h		;066c	c2 a3 06 	. . . 
	ld hl,0c041h		;066f	21 41 c0 	! A . 
	inc (hl)			;0672	34 	4 
	jp l06a7h		;0673	c3 a7 06 	. . . 
l0676h:
	ld hl,0c01ah		;0676	21 1a c0 	! . . 
	dec (hl)			;0679	35 	5 
	jp z,l068bh		;067a	ca 8b 06 	. . . 
	in a,(001h)		;067d	db 01 	. . 
	bit 5,a		;067f	cb 6f 	. o 
	jp z,l069ch		;0681	ca 9c 06 	. . . 
	ld hl,0c04dh		;0684	21 4d c0 	! M . 
	inc (hl)			;0687	34 	4 
	jp l06a7h		;0688	c3 a7 06 	. . . 
l068bh:
	xor a			;068b	af 	. 
	ld (0c00eh),a		;068c	32 0e c0 	2 . . 
	ld (0c041h),a		;068f	32 41 c0 	2 A . 
	ld a,(0c006h)		;0692	3a 06 c0 	: . . 
	or 010h		;0695	f6 10 	. . 
	ld (0c006h),a		;0697	32 06 c0 	2 . . 
	out (086h),a		;069a	d3 86 	. . 
l069ch:
	xor a			;069c	af 	. 
	ld (0c04dh),a		;069d	32 4d c0 	2 M . 
	jp l06a7h		;06a0	c3 a7 06 	. . . 
l06a3h:
	xor a			;06a3	af 	. 
	ld (0c041h),a		;06a4	32 41 c0 	2 A . 
l06a7h:
	ld a,(0c007h)		;06a7	3a 07 c0 	: . . 
	and 0f0h		;06aa	e6 f0 	. . 
	or 00dh		;06ac	f6 0d 	. . 
	ld (0c007h),a		;06ae	32 07 c0 	2 . . 
	out (087h),a		;06b1	d3 87 	. . 
	ld a,(0c00fh)		;06b3	3a 0f c0 	: . . 
	and a			;06b6	a7 	. 
	jp nz,l06c8h		;06b7	c2 c8 06 	. . . 
	in a,(001h)		;06ba	db 01 	. . 
	bit 5,a		;06bc	cb 6f 	. o 
	jp nz,l06f5h		;06be	c2 f5 06 	. . . 
	ld hl,0c042h		;06c1	21 42 c0 	! B . 
	inc (hl)			;06c4	34 	4 
	jp l06f9h		;06c5	c3 f9 06 	. . . 
l06c8h:
	ld hl,0c01bh		;06c8	21 1b c0 	! . . 
	dec (hl)			;06cb	35 	5 
	jp z,l06ddh		;06cc	ca dd 06 	. . . 
	in a,(001h)		;06cf	db 01 	. . 
	bit 5,a		;06d1	cb 6f 	. o 
	jp z,l06eeh		;06d3	ca ee 06 	. . . 
	ld hl,0c04eh		;06d6	21 4e c0 	! N . 
	inc (hl)			;06d9	34 	4 
	jp l06f9h		;06da	c3 f9 06 	. . . 
l06ddh:
	xor a			;06dd	af 	. 
	ld (0c00fh),a		;06de	32 0f c0 	2 . . 
	ld (0c042h),a		;06e1	32 42 c0 	2 B . 
	ld a,(0c006h)		;06e4	3a 06 c0 	: . . 
	or 020h		;06e7	f6 20 	.   
	ld (0c006h),a		;06e9	32 06 c0 	2 . . 
	out (086h),a		;06ec	d3 86 	. . 
l06eeh:
	xor a			;06ee	af 	. 
	ld (0c04eh),a		;06ef	32 4e c0 	2 N . 
	jp l06f9h		;06f2	c3 f9 06 	. . . 
l06f5h:
	xor a			;06f5	af 	. 
	ld (0c042h),a		;06f6	32 42 c0 	2 B . 
l06f9h:
	ld a,(0c007h)		;06f9	3a 07 c0 	: . . 
	and 0f0h		;06fc	e6 f0 	. . 
	or 00eh		;06fe	f6 0e 	. . 
	ld (0c007h),a		;0700	32 07 c0 	2 . . 
	out (087h),a		;0703	d3 87 	. . 
	ld a,(0c010h)		;0705	3a 10 c0 	: . . 
	and a			;0708	a7 	. 
	jp nz,l071ah		;0709	c2 1a 07 	. . . 
	in a,(001h)		;070c	db 01 	. . 
	bit 5,a		;070e	cb 6f 	. o 
	jp nz,l0747h		;0710	c2 47 07 	. G . 
	ld hl,0c043h		;0713	21 43 c0 	! C . 
	inc (hl)			;0716	34 	4 
	jp l074bh		;0717	c3 4b 07 	. K . 
l071ah:
	ld hl,0c01ch		;071a	21 1c c0 	! . . 
	dec (hl)			;071d	35 	5 
	jp z,l072fh		;071e	ca 2f 07 	. / . 
	in a,(001h)		;0721	db 01 	. . 
	bit 5,a		;0723	cb 6f 	. o 
	jp z,l0740h		;0725	ca 40 07 	. @ . 
	ld hl,0c04fh		;0728	21 4f c0 	! O . 
	inc (hl)			;072b	34 	4 
	jp l074bh		;072c	c3 4b 07 	. K . 
l072fh:
	xor a			;072f	af 	. 
	ld (0c010h),a		;0730	32 10 c0 	2 . . 
	ld (0c043h),a		;0733	32 43 c0 	2 C . 
	ld a,(0c006h)		;0736	3a 06 c0 	: . . 
	or 040h		;0739	f6 40 	. @ 
	ld (0c006h),a		;073b	32 06 c0 	2 . . 
	out (086h),a		;073e	d3 86 	. . 
l0740h:
	xor a			;0740	af 	. 
	ld (0c04fh),a		;0741	32 4f c0 	2 O . 
	jp l074bh		;0744	c3 4b 07 	. K . 
l0747h:
	xor a			;0747	af 	. 
	ld (0c043h),a		;0748	32 43 c0 	2 C . 
l074bh:
	ld a,(0c007h)		;074b	3a 07 c0 	: . . 
	and 0f0h		;074e	e6 f0 	. . 
	or 00fh		;0750	f6 0f 	. . 
	ld (0c007h),a		;0752	32 07 c0 	2 . . 
	out (087h),a		;0755	d3 87 	. . 
	ld a,(0c011h)		;0757	3a 11 c0 	: . . 
	and a			;075a	a7 	. 
	jp nz,l076ch		;075b	c2 6c 07 	. l . 
	in a,(001h)		;075e	db 01 	. . 
	bit 5,a		;0760	cb 6f 	. o 
	jp nz,l0799h		;0762	c2 99 07 	. . . 
	ld hl,0c044h		;0765	21 44 c0 	! D . 
	inc (hl)			;0768	34 	4 
	jp l079dh		;0769	c3 9d 07 	. . . 
l076ch:
	ld hl,0c01dh		;076c	21 1d c0 	! . . 
	dec (hl)			;076f	35 	5 
	jp z,l0781h		;0770	ca 81 07 	. . . 
	in a,(001h)		;0773	db 01 	. . 
	bit 5,a		;0775	cb 6f 	. o 
	jp z,l0792h		;0777	ca 92 07 	. . . 
	ld hl,0c050h		;077a	21 50 c0 	! P . 
	inc (hl)			;077d	34 	4 
	jp l079dh		;077e	c3 9d 07 	. . . 
l0781h:
	xor a			;0781	af 	. 
	ld (0c011h),a		;0782	32 11 c0 	2 . . 
	ld (0c044h),a		;0785	32 44 c0 	2 D . 
	ld a,(0c006h)		;0788	3a 06 c0 	: . . 
	or 080h		;078b	f6 80 	. . 
	ld (0c006h),a		;078d	32 06 c0 	2 . . 
	out (086h),a		;0790	d3 86 	. . 
l0792h:
	xor a			;0792	af 	. 
	ld (0c050h),a		;0793	32 50 c0 	2 P . 
	jp l079dh		;0796	c3 9d 07 	. . . 
l0799h:
	xor a			;0799	af 	. 
	ld (0c044h),a		;079a	32 44 c0 	2 D . 
l079dh:
	call sub_07c6h		;079d	cd c6 07 	. . . 
	pop hl			;07a0	e1 	. 
	pop de			;07a1	d1 	. 
	pop bc			;07a2	c1 	. 
	pop af			;07a3	f1 	. 
	ei			;07a4	fb 	. 
	reti		;07a5	ed 4d 	. M 
sub_07a7h:
	ld hl,0c028h		;07a7	21 28 c0 	! ( . 
	dec (hl)			;07aa	35 	5 
	ret nz			;07ab	c0 	. 
	ld (hl),030h		;07ac	36 30 	6 0 
	ld a,(0c001h)		;07ae	3a 01 c0 	: . . 
	bit 3,a		;07b1	cb 5f 	. _ 
	jp z,l07beh		;07b3	ca be 07 	. . . 
	res 3,a		;07b6	cb 9f 	. . 
	ld (0c001h),a		;07b8	32 01 c0 	2 . . 
	out (081h),a		;07bb	d3 81 	. . 
	ret			;07bd	c9 	. 
l07beh:
	set 3,a		;07be	cb df 	. . 
	ld (0c001h),a		;07c0	32 01 c0 	2 . . 
	out (081h),a		;07c3	d3 81 	. . 
	ret			;07c5	c9 	. 
sub_07c6h:
	ld a,(0c012h)		;07c6	3a 12 c0 	: . . 
	and a			;07c9	a7 	. 
	jp z,l07e7h		;07ca	ca e7 07 	. . . 
	ld hl,(0c01eh)		;07cd	2a 1e c0 	* . . 
	ld de,l0000h		;07d0	11 00 00 	. . . 
	sbc hl,de		;07d3	ed 52 	. R 
	jp z,l07e2h		;07d5	ca e2 07 	. . . 
	ld hl,(0c01eh)		;07d8	2a 1e c0 	* . . 
	dec hl			;07db	2b 	+ 
	ld (0c01eh),hl		;07dc	22 1e c0 	" . . 
	jp l07e7h		;07df	c3 e7 07 	. . . 
l07e2h:
	ld a,0ffh		;07e2	3e ff 	> . 
	ld (0c024h),a		;07e4	32 24 c0 	2 $ . 
l07e7h:
	ld a,(0c013h)		;07e7	3a 13 c0 	: . . 
	and a			;07ea	a7 	. 
	jp z,l0808h		;07eb	ca 08 08 	. . . 
	ld hl,(0c020h)		;07ee	2a 20 c0 	*   . 
	ld de,l0000h		;07f1	11 00 00 	. . . 
	sbc hl,de		;07f4	ed 52 	. R 
	jp z,l0803h		;07f6	ca 03 08 	. . . 
	ld hl,(0c020h)		;07f9	2a 20 c0 	*   . 
	dec hl			;07fc	2b 	+ 
	ld (0c020h),hl		;07fd	22 20 c0 	"   . 
	jp l0808h		;0800	c3 08 08 	. . . 
l0803h:
	ld a,0ffh		;0803	3e ff 	> . 
	ld (0c025h),a		;0805	32 25 c0 	2 % . 
l0808h:
	ld hl,(0c02bh)		;0808	2a 2b c0 	* + . 
	dec hl			;080b	2b 	+ 
	ld (0c02bh),hl		;080c	22 2b c0 	" + . 
	ld de,l0000h		;080f	11 00 00 	. . . 
	xor a			;0812	af 	. 
	sbc hl,de		;0813	ed 52 	. R 
	jp nz,l081bh		;0815	c2 1b 08 	. . . 
	ld (0c02dh),a		;0818	32 2d c0 	2 - . 
l081bh:
	ld hl,(0c022h)		;081b	2a 22 c0 	* " . 
	ld de,l0000h		;081e	11 00 00 	. . . 
	xor a			;0821	af 	. 
	sbc hl,de		;0822	ed 52 	. R 
	ret z			;0824	c8 	. 
	dec hl			;0825	2b 	+ 
	ld (0c022h),hl		;0826	22 22 c0 	" " . 
	ret			;0829	c9 	. 
sub_082ah:
	di			;082a	f3 	. 
	ld a,(0c0dbh)		;082b	3a db c0 	: . . 
	out (080h),a		;082e	d3 80 	. . 
	ld a,(0c001h)		;0830	3a 01 c0 	: . . 
	or 004h		;0833	f6 04 	. . 
	out (081h),a		;0835	d3 81 	. . 
	ld a,(0c001h)		;0837	3a 01 c0 	: . . 
	out (081h),a		;083a	d3 81 	. . 
	ei			;083c	fb 	. 
	ret			;083d	c9 	. 
l083eh:
	ld a,(0c0dah)		;083e	3a da c0 	: . . 
	and a			;0841	a7 	. 
	call nz,sub_0966h		;0842	c4 66 09 	. f . 
	ld a,(0c012h)		;0845	3a 12 c0 	: . . 
	and a			;0848	a7 	. 
	jp z,l085bh		;0849	ca 5b 08 	. [ . 
	ld a,(0c024h)		;084c	3a 24 c0 	: $ . 
	and a			;084f	a7 	. 
	call nz,sub_0894h		;0850	c4 94 08 	. . . 
	ld a,(0c0d8h)		;0853	3a d8 c0 	: . . 
	bit 3,a		;0856	cb 5f 	. _ 
	call z,sub_03a6h		;0858	cc a6 03 	. . . 
l085bh:
	ld a,(0c013h)		;085b	3a 13 c0 	: . . 
	and a			;085e	a7 	. 
	jp z,l0871h		;085f	ca 71 08 	. q . 
	ld a,(0c025h)		;0862	3a 25 c0 	: % . 
	and a			;0865	a7 	. 
	call nz,sub_08fdh		;0866	c4 fd 08 	. . . 
	ld a,(0c0d8h)		;0869	3a d8 c0 	: . . 
	bit 2,a		;086c	cb 57 	. W 
	call z,sub_03b8h		;086e	cc b8 03 	. . . 
l0871h:
	ld a,(0c034h)		;0871	3a 34 c0 	: 4 . 
	and a			;0874	a7 	. 
	call z,sub_03a6h		;0875	cc a6 03 	. . . 
	ld a,(0c034h)		;0878	3a 34 c0 	: 4 . 
	and a			;087b	a7 	. 
	call z,sub_03b8h		;087c	cc b8 03 	. . . 
	in a,(004h)		;087f	db 04 	. . 
	bit 0,a		;0881	cb 47 	. G 
	call z,sub_09a1h		;0883	cc a1 09 	. . . 
	call sub_0ba0h		;0886	cd a0 0b 	. . . 
	ld a,(0c0c3h)		;0889	3a c3 c0 	: . . 
	cp 0ffh		;088c	fe ff 	. . 
	call nz,sub_0973h		;088e	c4 73 09 	. s . 
	jp l083eh		;0891	c3 3e 08 	. > . 
sub_0894h:
	ld a,007h		;0894	3e 07 	> . 
	ld (0c0dbh),a		;0896	32 db c0 	2 . . 
	call sub_082ah		;0899	cd 2a 08 	. * . 
l089ch:
	ld a,(0c0d8h)		;089c	3a d8 c0 	: . . 
	bit 3,a		;089f	cb 5f 	. _ 
	jp z,l08e7h		;08a1	ca e7 08 	. . . 
	ld a,(0c0dah)		;08a4	3a da c0 	: . . 
	and a			;08a7	a7 	. 
	call nz,sub_0966h		;08a8	c4 66 09 	. f . 
	in a,(004h)		;08ab	db 04 	. . 
	bit 0,a		;08ad	cb 47 	. G 
	call z,sub_09a1h		;08af	cc a1 09 	. . . 
	call sub_0ba0h		;08b2	cd a0 0b 	. . . 
	ld a,(0c0c3h)		;08b5	3a c3 c0 	: . . 
	cp 0ffh		;08b8	fe ff 	. . 
	call nz,sub_0973h		;08ba	c4 73 09 	. s . 
	ld a,(0c013h)		;08bd	3a 13 c0 	: . . 
	and a			;08c0	a7 	. 
	jp z,l08cch		;08c1	ca cc 08 	. . . 
	ld a,(0c0d8h)		;08c4	3a d8 c0 	: . . 
	bit 2,a		;08c7	cb 57 	. W 
	call z,sub_03b8h		;08c9	cc b8 03 	. . . 
l08cch:
	ld hl,l0000h		;08cc	21 00 00 	! . . 
	ld (0c020h),hl		;08cf	22 20 c0 	"   . 
	xor a			;08d2	af 	. 
	ld (0c025h),a		;08d3	32 25 c0 	2 % . 
	ld a,(0c034h)		;08d6	3a 34 c0 	: 4 . 
	and a			;08d9	a7 	. 
	call z,sub_03a6h		;08da	cc a6 03 	. . . 
	ld a,(0c034h)		;08dd	3a 34 c0 	: 4 . 
	and a			;08e0	a7 	. 
	call z,sub_03b8h		;08e1	cc b8 03 	. . . 
	jp l089ch		;08e4	c3 9c 08 	. . . 
l08e7h:
	ld a,025h		;08e7	3e 25 	> % 
	ld (0c0dbh),a		;08e9	32 db c0 	2 . . 
	call sub_082ah		;08ec	cd 2a 08 	. * . 
	call sub_03a6h		;08ef	cd a6 03 	. . . 
	xor a			;08f2	af 	. 
	ld (0c024h),a		;08f3	32 24 c0 	2 $ . 
	ld hl,l0000h		;08f6	21 00 00 	! . . 
	ld (0c01eh),hl		;08f9	22 1e c0 	" . . 
	ret			;08fc	c9 	. 
sub_08fdh:
	ld a,007h		;08fd	3e 07 	> . 
	ld (0c0dbh),a		;08ff	32 db c0 	2 . . 
	call sub_082ah		;0902	cd 2a 08 	. * . 
l0905h:
	ld a,(0c0d8h)		;0905	3a d8 c0 	: . . 
	bit 2,a		;0908	cb 57 	. W 
	jp z,l0950h		;090a	ca 50 09 	. P . 
	ld a,(0c0dah)		;090d	3a da c0 	: . . 
	and a			;0910	a7 	. 
	call nz,sub_0966h		;0911	c4 66 09 	. f . 
	in a,(004h)		;0914	db 04 	. . 
	bit 0,a		;0916	cb 47 	. G 
	call z,sub_09a1h		;0918	cc a1 09 	. . . 
	call sub_0ba0h		;091b	cd a0 0b 	. . . 
	ld a,(0c0c3h)		;091e	3a c3 c0 	: . . 
	cp 0ffh		;0921	fe ff 	. . 
	call nz,sub_0973h		;0923	c4 73 09 	. s . 
	ld a,(0c012h)		;0926	3a 12 c0 	: . . 
	and a			;0929	a7 	. 
	jp z,l0935h		;092a	ca 35 09 	. 5 . 
	ld a,(0c0d8h)		;092d	3a d8 c0 	: . . 
	bit 3,a		;0930	cb 5f 	. _ 
	call z,sub_03a6h		;0932	cc a6 03 	. . . 
l0935h:
	ld hl,l0000h		;0935	21 00 00 	! . . 
	ld (0c01eh),hl		;0938	22 1e c0 	" . . 
	xor a			;093b	af 	. 
	ld (0c024h),a		;093c	32 24 c0 	2 $ . 
	ld a,(0c034h)		;093f	3a 34 c0 	: 4 . 
	and a			;0942	a7 	. 
	call z,sub_03a6h		;0943	cc a6 03 	. . . 
	ld a,(0c034h)		;0946	3a 34 c0 	: 4 . 
	and a			;0949	a7 	. 
	call z,sub_03b8h		;094a	cc b8 03 	. . . 
	jp l0905h		;094d	c3 05 09 	. . . 
l0950h:
	ld a,025h		;0950	3e 25 	> % 
	ld (0c0dbh),a		;0952	32 db c0 	2 . . 
	call sub_082ah		;0955	cd 2a 08 	. * . 
	call sub_03b8h		;0958	cd b8 03 	. . . 
	xor a			;095b	af 	. 
	ld (0c025h),a		;095c	32 25 c0 	2 % . 
	ld hl,l0000h		;095f	21 00 00 	! . . 
	ld (0c020h),hl		;0962	22 20 c0 	"   . 
	ret			;0965	c9 	. 
sub_0966h:
	xor a			;0966	af 	. 
	ld (0c0dah),a		;0967	32 da c0 	2 . . 
	ld hl,(0c0dch)		;096a	2a dc c0 	* . . 
	jp (hl)			;096d	e9 	. 
l096eh:
	xor a			;096e	af 	. 
	ld (0c0dah),a		;096f	32 da c0 	2 . . 
	ret			;0972	c9 	. 
sub_0973h:
	bit 0,a		;0973	cb 47 	. G 
	call z,sub_09feh		;0975	cc fe 09 	. . . 
	ld a,(0c0c3h)		;0978	3a c3 c0 	: . . 
	bit 1,a		;097b	cb 4f 	. O 
	call z,sub_0a0bh		;097d	cc 0b 0a 	. . . 
	ld a,(0c0c3h)		;0980	3a c3 c0 	: . . 
	bit 2,a		;0983	cb 57 	. W 
	call z,sub_0a18h		;0985	cc 18 0a 	. . . 
	ld a,(0c0c3h)		;0988	3a c3 c0 	: . . 
	bit 3,a		;098b	cb 5f 	. _ 
	call z,sub_0a3ah		;098d	cc 3a 0a 	. : . 
	ld a,(0c0c3h)		;0990	3a c3 c0 	: . . 
	bit 4,a		;0993	cb 67 	. g 
	call z,sub_0a5ch		;0995	cc 5c 0a 	. \ . 
	ld a,(0c0c3h)		;0998	3a c3 c0 	: . . 
	bit 5,a		;099b	cb 6f 	. o 
	call z,sub_0a69h		;099d	cc 69 0a 	. i . 
	ret			;09a0	c9 	. 
sub_09a1h:
	ld a,(0c038h)		;09a1	3a 38 c0 	: 8 . 
	and a			;09a4	a7 	. 
	ret z			;09a5	c8 	. 
	ld hl,0c039h		;09a6	21 39 c0 	! 9 . 
	ld de,l09e6h		;09a9	11 e6 09 	. . . 
	ld b,00ch		;09ac	06 0c 	. . 
	ld a,0f0h		;09ae	3e f0 	> . 
l09b0h:
	cp (hl)			;09b0	be 	. 
	jp c,l09c5h		;09b1	da c5 09 	. . . 
	inc hl			;09b4	23 	# 
	inc de			;09b5	13 	. 
	djnz l09b0h		;09b6	10 f8 	. . 
	ld b,00ch		;09b8	06 0c 	. . 
	ld a,012h		;09ba	3e 12 	> . 
l09bch:
	cp (hl)			;09bc	be 	. 
	jp c,l09d7h		;09bd	da d7 09 	. . . 
	inc hl			;09c0	23 	# 
	inc de			;09c1	13 	. 
	djnz l09bch		;09c2	10 f8 	. . 
	ret			;09c4	c9 	. 
l09c5h:
	ld a,(de)			;09c5	1a 	. 
	ld (0c031h),a		;09c6	32 31 c0 	2 1 . 
	ld (hl),000h		;09c9	36 00 	6 . 
	call sub_148bh		;09cb	cd 8b 14 	. . . 
	ld a,(0c031h)		;09ce	3a 31 c0 	: 1 . 
	ld (0c0dbh),a		;09d1	32 db c0 	2 . . 
	jp sub_082ah		;09d4	c3 2a 08 	. * . 
l09d7h:
	ld a,(de)			;09d7	1a 	. 
	ld (0c031h),a		;09d8	32 31 c0 	2 1 . 
	ld (hl),000h		;09db	36 00 	6 . 
	ld a,(0c031h)		;09dd	3a 31 c0 	: 1 . 
	ld (0c0dbh),a		;09e0	32 db c0 	2 . . 
	jp sub_082ah		;09e3	c3 2a 08 	. * . 
l09e6h:
	add hl,hl			;09e6	29 	) 
	ld hl,(l2c2bh)		;09e7	2a 2b 2c 	* + , 
	dec l			;09ea	2d 	- 
	ld l,02fh		;09eb	2e 2f 	. / 
	jr nc,$+51		;09ed	30 31 	0 1 
	ld (l3433h),a		;09ef	32 33 34 	2 3 4 
	dec (hl)			;09f2	35 	5 
	ld (hl),037h		;09f3	36 37 	6 7 
	jr c,$+59		;09f5	38 39 	8 9 
	ld a,(l3c3bh)		;09f7	3a 3b 3c 	: ; < 
	dec a			;09fa	3d 	= 
	ld a,03fh		;09fb	3e 3f 	> ? 
	ld b,b			;09fd	40 	@ 
sub_09feh:
	ld a,001h		;09fe	3e 01 	> . 
	call sub_1a78h		;0a00	cd 78 1a 	. x . 
	ld a,001h		;0a03	3e 01 	> . 
	ld (0c0dbh),a		;0a05	32 db c0 	2 . . 
	jp sub_082ah		;0a08	c3 2a 08 	. * . 
sub_0a0bh:
	ld a,002h		;0a0b	3e 02 	> . 
	call sub_1a78h		;0a0d	cd 78 1a 	. x . 
	ld a,002h		;0a10	3e 02 	> . 
	ld (0c0dbh),a		;0a12	32 db c0 	2 . . 
	jp sub_082ah		;0a15	c3 2a 08 	. * . 
sub_0a18h:
	ld a,(0c051h)		;0a18	3a 51 c0 	: Q . 
	and a			;0a1b	a7 	. 
	jp nz,l0a32h		;0a1c	c2 32 0a 	. 2 . 
	ld a,(0c034h)		;0a1f	3a 34 c0 	: 4 . 
	and a			;0a22	a7 	. 
	ret z			;0a23	c8 	. 
	ld a,004h		;0a24	3e 04 	> . 
	call sub_1a78h		;0a26	cd 78 1a 	. x . 
	ld a,(0c009h)		;0a29	3a 09 c0 	: . . 
	and a			;0a2c	a7 	. 
	ret nz			;0a2d	c0 	. 
	call sub_0266h		;0a2e	cd 66 02 	. f . 
	ret			;0a31	c9 	. 
l0a32h:
	ld a,003h		;0a32	3e 03 	> . 
	ld (0c0dbh),a		;0a34	32 db c0 	2 . . 
	jp sub_082ah		;0a37	c3 2a 08 	. * . 
sub_0a3ah:
	ld a,(0c051h)		;0a3a	3a 51 c0 	: Q . 
	and a			;0a3d	a7 	. 
	jp nz,l0a54h		;0a3e	c2 54 0a 	. T . 
	ld a,(0c034h)		;0a41	3a 34 c0 	: 4 . 
	and a			;0a44	a7 	. 
	ret z			;0a45	c8 	. 
	ld a,008h		;0a46	3e 08 	> . 
	call sub_1a78h		;0a48	cd 78 1a 	. x . 
	ld a,(0c008h)		;0a4b	3a 08 c0 	: . . 
	and a			;0a4e	a7 	. 
	ret nz			;0a4f	c0 	. 
	call sub_024ah		;0a50	cd 4a 02 	. J . 
	ret			;0a53	c9 	. 
l0a54h:
	ld a,004h		;0a54	3e 04 	> . 
	ld (0c0dbh),a		;0a56	32 db c0 	2 . . 
	jp sub_082ah		;0a59	c3 2a 08 	. * . 
sub_0a5ch:
	ld a,010h		;0a5c	3e 10 	> . 
	call sub_1a78h		;0a5e	cd 78 1a 	. x . 
	ld a,005h		;0a61	3e 05 	> . 
	ld (0c0dbh),a		;0a63	32 db c0 	2 . . 
	jp sub_082ah		;0a66	c3 2a 08 	. * . 
sub_0a69h:
	ld a,020h		;0a69	3e 20 	>   
	call sub_1a78h		;0a6b	cd 78 1a 	. x . 
	ld a,006h		;0a6e	3e 06 	> . 
	ld (0c0dbh),a		;0a70	32 db c0 	2 . . 
	jp sub_082ah		;0a73	c3 2a 08 	. * . 
l0a76h:
	ld a,(0c035h)		;0a76	3a 35 c0 	: 5 . 
	and a			;0a79	a7 	. 
	ret z			;0a7a	c8 	. 
	ld hl,(0c022h)		;0a7b	2a 22 c0 	* " . 
	ld de,l0000h		;0a7e	11 00 00 	. . . 
	xor a			;0a81	af 	. 
	sbc hl,de		;0a82	ed 52 	. R 
	ret nz			;0a84	c0 	. 
	ld hl,l01f4h		;0a85	21 f4 01 	! . . 
	ld (0c022h),hl		;0a88	22 22 c0 	" " . 
	jp sub_082ah		;0a8b	c3 2a 08 	. * . 
l0a8eh:
	ld a,008h		;0a8e	3e 08 	> . 
	call sub_1a23h		;0a90	cd 23 1a 	. # . 
	ld a,(0c00ch)		;0a93	3a 0c c0 	: . . 
	and a			;0a96	a7 	. 
	ret nz			;0a97	c0 	. 
	call sub_02bah		;0a98	cd ba 02 	. . . 
	jp sub_082ah		;0a9b	c3 2a 08 	. * . 
l0a9eh:
	ld a,001h		;0a9e	3e 01 	> . 
	call sub_1a12h		;0aa0	cd 12 1a 	. . . 
	ld a,(0c00dh)		;0aa3	3a 0d c0 	: . . 
	and a			;0aa6	a7 	. 
	ret nz			;0aa7	c0 	. 
	call sub_02d6h		;0aa8	cd d6 02 	. . . 
	jp sub_082ah		;0aab	c3 2a 08 	. * . 
l0aaeh:
	ld a,004h		;0aae	3e 04 	> . 
	call sub_1a01h		;0ab0	cd 01 1a 	. . . 
	ld a,(0c00eh)		;0ab3	3a 0e c0 	: . . 
	and a			;0ab6	a7 	. 
	ret nz			;0ab7	c0 	. 
	call sub_02f2h		;0ab8	cd f2 02 	. . . 
	jp sub_082ah		;0abb	c3 2a 08 	. * . 
l0abeh:
	ld a,002h		;0abe	3e 02 	> . 
	call sub_1a67h		;0ac0	cd 67 1a 	. g . 
	ld a,(0c00fh)		;0ac3	3a 0f c0 	: . . 
	and a			;0ac6	a7 	. 
	ret nz			;0ac7	c0 	. 
	call sub_030eh		;0ac8	cd 0e 03 	. . . 
	jp sub_082ah		;0acb	c3 2a 08 	. * . 
l0aceh:
	ld a,004h		;0ace	3e 04 	> . 
	call sub_1a34h		;0ad0	cd 34 1a 	. 4 . 
	jp sub_082ah		;0ad3	c3 2a 08 	. * . 
l0ad6h:
	ld a,004h		;0ad6	3e 04 	> . 
	call sub_1a45h		;0ad8	cd 45 1a 	. E . 
	jp sub_082ah		;0adb	c3 2a 08 	. * . 
l0adeh:
	ld a,004h		;0ade	3e 04 	> . 
	call sub_1a56h		;0ae0	cd 56 1a 	. V . 
	jp sub_082ah		;0ae3	c3 2a 08 	. * . 
l0ae6h:
	ld a,004h		;0ae6	3e 04 	> . 
	call sub_1a67h		;0ae8	cd 67 1a 	. g . 
	jp sub_082ah		;0aeb	c3 2a 08 	. * . 
l0aeeh:
	ld a,002h		;0aee	3e 02 	> . 
	call sub_1a01h		;0af0	cd 01 1a 	. . . 
	jp sub_082ah		;0af3	c3 2a 08 	. * . 
l0af6h:
	ld a,002h		;0af6	3e 02 	> . 
	call sub_1a12h		;0af8	cd 12 1a 	. . . 
	jp sub_082ah		;0afb	c3 2a 08 	. * . 
l0afeh:
	ld a,002h		;0afe	3e 02 	> . 
	call sub_1a23h		;0b00	cd 23 1a 	. # . 
	jp sub_082ah		;0b03	c3 2a 08 	. * . 
l0b06h:
	ld a,002h		;0b06	3e 02 	> . 
	call sub_19f0h		;0b08	cd f0 19 	. . . 
	jp sub_082ah		;0b0b	c3 2a 08 	. * . 
sub_0b0eh:
	ld hl,l003ch		;0b0e	21 3c 00 	! < . 
	ld (0c02bh),hl		;0b11	22 2b c0 	" + . 
l0b14h:
	ld hl,(0c02bh)		;0b14	2a 2b c0 	* + . 
	ld de,l0000h		;0b17	11 00 00 	. . . 
	xor a			;0b1a	af 	. 
	sbc hl,de		;0b1b	ed 52 	. R 
	jr nz,l0b14h		;0b1d	20 f5 	  . 
	ret			;0b1f	c9 	. 
l0b20h:
	ld a,001h		;0b20	3e 01 	> . 
	call sub_19f0h		;0b22	cd f0 19 	. . . 
	jp sub_082ah		;0b25	c3 2a 08 	. * . 
l0b28h:
	ld a,001h		;0b28	3e 01 	> . 
	call sub_1a01h		;0b2a	cd 01 1a 	. . . 
	jp sub_082ah		;0b2d	c3 2a 08 	. * . 
l0b30h:
	ld a,008h		;0b30	3e 08 	> . 
	call sub_1a45h		;0b32	cd 45 1a 	. E . 
	jp sub_082ah		;0b35	c3 2a 08 	. * . 
l0b38h:
	ld a,008h		;0b38	3e 08 	> . 
	call sub_1a56h		;0b3a	cd 56 1a 	. V . 
	jp sub_082ah		;0b3d	c3 2a 08 	. * . 
l0b40h:
	ld a,008h		;0b40	3e 08 	> . 
	call sub_1a67h		;0b42	cd 67 1a 	. g . 
	jp sub_082ah		;0b45	c3 2a 08 	. * . 
l0b48h:
	ld a,008h		;0b48	3e 08 	> . 
	call sub_19f0h		;0b4a	cd f0 19 	. . . 
	jp sub_082ah		;0b4d	c3 2a 08 	. * . 
l0b50h:
	ld a,002h		;0b50	3e 02 	> . 
	call sub_1a34h		;0b52	cd 34 1a 	. 4 . 
	jp sub_082ah		;0b55	c3 2a 08 	. * . 
l0b58h:
	ld a,002h		;0b58	3e 02 	> . 
	call sub_1a45h		;0b5a	cd 45 1a 	. E . 
	jp sub_082ah		;0b5d	c3 2a 08 	. * . 
l0b60h:
	ld a,002h		;0b60	3e 02 	> . 
	call sub_1a56h		;0b62	cd 56 1a 	. V . 
	jp sub_082ah		;0b65	c3 2a 08 	. * . 
l0b68h:
	ld a,004h		;0b68	3e 04 	> . 
	call sub_1a12h		;0b6a	cd 12 1a 	. . . 
	jp sub_082ah		;0b6d	c3 2a 08 	. * . 
l0b70h:
	ld a,004h		;0b70	3e 04 	> . 
	call sub_1a23h		;0b72	cd 23 1a 	. # . 
	jp sub_082ah		;0b75	c3 2a 08 	. * . 
l0b78h:
	ld a,008h		;0b78	3e 08 	> . 
	call sub_1a12h		;0b7a	cd 12 1a 	. . . 
	jp sub_082ah		;0b7d	c3 2a 08 	. * . 
l0b80h:
	ld a,001h		;0b80	3e 01 	> . 
	call sub_1a34h		;0b82	cd 34 1a 	. 4 . 
	jp sub_082ah		;0b85	c3 2a 08 	. * . 
l0b88h:
	ld a,008h		;0b88	3e 08 	> . 
	call sub_1a34h		;0b8a	cd 34 1a 	. 4 . 
	jp sub_082ah		;0b8d	c3 2a 08 	. * . 
l0b90h:
	ld a,001h		;0b90	3e 01 	> . 
	call sub_1a23h		;0b92	cd 23 1a 	. # . 
	jp sub_082ah		;0b95	c3 2a 08 	. * . 
l0b98h:
	ld a,008h		;0b98	3e 08 	> . 
	call sub_1a01h		;0b9a	cd 01 1a 	. . . 
	jp sub_082ah		;0b9d	c3 2a 08 	. * . 
sub_0ba0h:
	ld hl,(0c052h)		;0ba0	2a 52 c0 	* R . 
	ld a,(hl)			;0ba3	7e 	~ 
	and a			;0ba4	a7 	. 
	ret z			;0ba5	c8 	. 
	ld (hl),000h		;0ba6	36 00 	6 . 
	inc hl			;0ba8	23 	# 
	ld (0c052h),hl		;0ba9	22 52 c0 	" R . 
	ld hl,l1000h		;0bac	21 00 10 	! . . 
	ld d,000h		;0baf	16 00 	. . 
	ld e,a			;0bb1	5f 	_ 
	sla e		;0bb2	cb 23 	. # 
	jp nc,l0bb9h		;0bb4	d2 b9 0b 	. . . 
	ld d,001h		;0bb7	16 01 	. . 
l0bb9h:
	add hl,de			;0bb9	19 	. 
	ld e,(hl)			;0bba	5e 	^ 
	inc hl			;0bbb	23 	# 
	ld d,(hl)			;0bbc	56 	V 
	ex de,hl			;0bbd	eb 	. 
	jp (hl)			;0bbe	e9 	. 
	nop			;0bbf	00 	. 
	nop			;0bc0	00 	. 
	nop			;0bc1	00 	. 
	nop			;0bc2	00 	. 
	nop			;0bc3	00 	. 
	nop			;0bc4	00 	. 
	nop			;0bc5	00 	. 
	nop			;0bc6	00 	. 
	nop			;0bc7	00 	. 
	nop			;0bc8	00 	. 
	nop			;0bc9	00 	. 
	nop			;0bca	00 	. 
	nop			;0bcb	00 	. 
	nop			;0bcc	00 	. 
	nop			;0bcd	00 	. 
	nop			;0bce	00 	. 
	nop			;0bcf	00 	. 
	nop			;0bd0	00 	. 
	nop			;0bd1	00 	. 
	nop			;0bd2	00 	. 
	nop			;0bd3	00 	. 
	nop			;0bd4	00 	. 
	nop			;0bd5	00 	. 
	nop			;0bd6	00 	. 
	nop			;0bd7	00 	. 
	nop			;0bd8	00 	. 
	nop			;0bd9	00 	. 
	nop			;0bda	00 	. 
	nop			;0bdb	00 	. 
	nop			;0bdc	00 	. 
	nop			;0bdd	00 	. 
	nop			;0bde	00 	. 
	nop			;0bdf	00 	. 
	nop			;0be0	00 	. 
	nop			;0be1	00 	. 
	nop			;0be2	00 	. 
	nop			;0be3	00 	. 
	nop			;0be4	00 	. 
	nop			;0be5	00 	. 
	nop			;0be6	00 	. 
	nop			;0be7	00 	. 
	nop			;0be8	00 	. 
	nop			;0be9	00 	. 
	nop			;0bea	00 	. 
	nop			;0beb	00 	. 
	nop			;0bec	00 	. 
	nop			;0bed	00 	. 
	nop			;0bee	00 	. 
	nop			;0bef	00 	. 
	nop			;0bf0	00 	. 
	nop			;0bf1	00 	. 
	nop			;0bf2	00 	. 
	nop			;0bf3	00 	. 
	nop			;0bf4	00 	. 
	nop			;0bf5	00 	. 
	nop			;0bf6	00 	. 
	nop			;0bf7	00 	. 
	nop			;0bf8	00 	. 
	nop			;0bf9	00 	. 
	nop			;0bfa	00 	. 
	nop			;0bfb	00 	. 
	nop			;0bfc	00 	. 
	nop			;0bfd	00 	. 
	nop			;0bfe	00 	. 
	nop			;0bff	00 	. 
	nop			;0c00	00 	. 
	nop			;0c01	00 	. 
	nop			;0c02	00 	. 
	nop			;0c03	00 	. 
	nop			;0c04	00 	. 
	nop			;0c05	00 	. 
	nop			;0c06	00 	. 
	nop			;0c07	00 	. 
	nop			;0c08	00 	. 
	nop			;0c09	00 	. 
	nop			;0c0a	00 	. 
	nop			;0c0b	00 	. 
	nop			;0c0c	00 	. 
	nop			;0c0d	00 	. 
	nop			;0c0e	00 	. 
	nop			;0c0f	00 	. 
	nop			;0c10	00 	. 
	nop			;0c11	00 	. 
	nop			;0c12	00 	. 
l0c13h:
	nop			;0c13	00 	. 
	nop			;0c14	00 	. 
	nop			;0c15	00 	. 
	nop			;0c16	00 	. 
	nop			;0c17	00 	. 
	nop			;0c18	00 	. 
	nop			;0c19	00 	. 
	nop			;0c1a	00 	. 
	nop			;0c1b	00 	. 
	nop			;0c1c	00 	. 
	nop			;0c1d	00 	. 
	nop			;0c1e	00 	. 
	nop			;0c1f	00 	. 
	nop			;0c20	00 	. 
	nop			;0c21	00 	. 
	nop			;0c22	00 	. 
	nop			;0c23	00 	. 
	nop			;0c24	00 	. 
	nop			;0c25	00 	. 
	nop			;0c26	00 	. 
	nop			;0c27	00 	. 
	nop			;0c28	00 	. 
	nop			;0c29	00 	. 
	nop			;0c2a	00 	. 
	nop			;0c2b	00 	. 
	nop			;0c2c	00 	. 
	nop			;0c2d	00 	. 
	nop			;0c2e	00 	. 
	nop			;0c2f	00 	. 
	nop			;0c30	00 	. 
	nop			;0c31	00 	. 
	nop			;0c32	00 	. 
	nop			;0c33	00 	. 
	nop			;0c34	00 	. 
	nop			;0c35	00 	. 
	nop			;0c36	00 	. 
	nop			;0c37	00 	. 
	nop			;0c38	00 	. 
	nop			;0c39	00 	. 
	nop			;0c3a	00 	. 
	nop			;0c3b	00 	. 
	nop			;0c3c	00 	. 
	nop			;0c3d	00 	. 
	nop			;0c3e	00 	. 
	nop			;0c3f	00 	. 
	nop			;0c40	00 	. 
	nop			;0c41	00 	. 
	nop			;0c42	00 	. 
	nop			;0c43	00 	. 
	nop			;0c44	00 	. 
	nop			;0c45	00 	. 
	nop			;0c46	00 	. 
	nop			;0c47	00 	. 
	nop			;0c48	00 	. 
	nop			;0c49	00 	. 
	nop			;0c4a	00 	. 
	nop			;0c4b	00 	. 
	nop			;0c4c	00 	. 
	nop			;0c4d	00 	. 
	nop			;0c4e	00 	. 
	nop			;0c4f	00 	. 
	nop			;0c50	00 	. 
	nop			;0c51	00 	. 
	nop			;0c52	00 	. 
	nop			;0c53	00 	. 
	nop			;0c54	00 	. 
	nop			;0c55	00 	. 
	nop			;0c56	00 	. 
	nop			;0c57	00 	. 
	nop			;0c58	00 	. 
	nop			;0c59	00 	. 
	nop			;0c5a	00 	. 
	nop			;0c5b	00 	. 
	nop			;0c5c	00 	. 
	nop			;0c5d	00 	. 
	nop			;0c5e	00 	. 
	nop			;0c5f	00 	. 
	nop			;0c60	00 	. 
	nop			;0c61	00 	. 
	nop			;0c62	00 	. 
	nop			;0c63	00 	. 
	nop			;0c64	00 	. 
	nop			;0c65	00 	. 
	nop			;0c66	00 	. 
	nop			;0c67	00 	. 
	nop			;0c68	00 	. 
	nop			;0c69	00 	. 
	nop			;0c6a	00 	. 
	nop			;0c6b	00 	. 
	nop			;0c6c	00 	. 
	nop			;0c6d	00 	. 
	nop			;0c6e	00 	. 
	nop			;0c6f	00 	. 
	nop			;0c70	00 	. 
	nop			;0c71	00 	. 
	nop			;0c72	00 	. 
	nop			;0c73	00 	. 
	nop			;0c74	00 	. 
	nop			;0c75	00 	. 
	nop			;0c76	00 	. 
	nop			;0c77	00 	. 
	nop			;0c78	00 	. 
	nop			;0c79	00 	. 
	nop			;0c7a	00 	. 
	nop			;0c7b	00 	. 
	nop			;0c7c	00 	. 
	nop			;0c7d	00 	. 
	nop			;0c7e	00 	. 
	nop			;0c7f	00 	. 
	nop			;0c80	00 	. 
	nop			;0c81	00 	. 
	nop			;0c82	00 	. 
	nop			;0c83	00 	. 
	nop			;0c84	00 	. 
	nop			;0c85	00 	. 
	nop			;0c86	00 	. 
	nop			;0c87	00 	. 
	nop			;0c88	00 	. 
	nop			;0c89	00 	. 
	nop			;0c8a	00 	. 
	nop			;0c8b	00 	. 
	nop			;0c8c	00 	. 
	nop			;0c8d	00 	. 
	nop			;0c8e	00 	. 
	nop			;0c8f	00 	. 
	nop			;0c90	00 	. 
	nop			;0c91	00 	. 
	nop			;0c92	00 	. 
	nop			;0c93	00 	. 
	nop			;0c94	00 	. 
	nop			;0c95	00 	. 
	nop			;0c96	00 	. 
	nop			;0c97	00 	. 
	nop			;0c98	00 	. 
	nop			;0c99	00 	. 
	nop			;0c9a	00 	. 
	nop			;0c9b	00 	. 
	nop			;0c9c	00 	. 
	nop			;0c9d	00 	. 
	nop			;0c9e	00 	. 
	nop			;0c9f	00 	. 
	nop			;0ca0	00 	. 
	nop			;0ca1	00 	. 
	nop			;0ca2	00 	. 
	nop			;0ca3	00 	. 
	nop			;0ca4	00 	. 
	nop			;0ca5	00 	. 
	nop			;0ca6	00 	. 
	nop			;0ca7	00 	. 
	nop			;0ca8	00 	. 
	nop			;0ca9	00 	. 
	nop			;0caa	00 	. 
	nop			;0cab	00 	. 
	nop			;0cac	00 	. 
	nop			;0cad	00 	. 
	nop			;0cae	00 	. 
	nop			;0caf	00 	. 
	nop			;0cb0	00 	. 
	nop			;0cb1	00 	. 
	nop			;0cb2	00 	. 
	nop			;0cb3	00 	. 
	nop			;0cb4	00 	. 
	nop			;0cb5	00 	. 
	nop			;0cb6	00 	. 
	nop			;0cb7	00 	. 
	nop			;0cb8	00 	. 
	nop			;0cb9	00 	. 
	nop			;0cba	00 	. 
	nop			;0cbb	00 	. 
	nop			;0cbc	00 	. 
	nop			;0cbd	00 	. 
	nop			;0cbe	00 	. 
	nop			;0cbf	00 	. 
	nop			;0cc0	00 	. 
	nop			;0cc1	00 	. 
	nop			;0cc2	00 	. 
	nop			;0cc3	00 	. 
	nop			;0cc4	00 	. 
	nop			;0cc5	00 	. 
	nop			;0cc6	00 	. 
	nop			;0cc7	00 	. 
	nop			;0cc8	00 	. 
	nop			;0cc9	00 	. 
	nop			;0cca	00 	. 
	nop			;0ccb	00 	. 
	nop			;0ccc	00 	. 
	nop			;0ccd	00 	. 
	nop			;0cce	00 	. 
	nop			;0ccf	00 	. 
	nop			;0cd0	00 	. 
	nop			;0cd1	00 	. 
	nop			;0cd2	00 	. 
	nop			;0cd3	00 	. 
	nop			;0cd4	00 	. 
	nop			;0cd5	00 	. 
	nop			;0cd6	00 	. 
	nop			;0cd7	00 	. 
	nop			;0cd8	00 	. 
	nop			;0cd9	00 	. 
	nop			;0cda	00 	. 
	nop			;0cdb	00 	. 
	nop			;0cdc	00 	. 
	nop			;0cdd	00 	. 
	nop			;0cde	00 	. 
	nop			;0cdf	00 	. 
	nop			;0ce0	00 	. 
	nop			;0ce1	00 	. 
	nop			;0ce2	00 	. 
	nop			;0ce3	00 	. 
	nop			;0ce4	00 	. 
	nop			;0ce5	00 	. 
	nop			;0ce6	00 	. 
	nop			;0ce7	00 	. 
	nop			;0ce8	00 	. 
	nop			;0ce9	00 	. 
	nop			;0cea	00 	. 
	nop			;0ceb	00 	. 
	nop			;0cec	00 	. 
	nop			;0ced	00 	. 
	nop			;0cee	00 	. 
	nop			;0cef	00 	. 
	nop			;0cf0	00 	. 
	nop			;0cf1	00 	. 
	nop			;0cf2	00 	. 
	nop			;0cf3	00 	. 
	nop			;0cf4	00 	. 
	nop			;0cf5	00 	. 
	nop			;0cf6	00 	. 
	nop			;0cf7	00 	. 
	nop			;0cf8	00 	. 
	nop			;0cf9	00 	. 
	nop			;0cfa	00 	. 
	nop			;0cfb	00 	. 
	nop			;0cfc	00 	. 
	nop			;0cfd	00 	. 
	nop			;0cfe	00 	. 
	nop			;0cff	00 	. 
	nop			;0d00	00 	. 
	nop			;0d01	00 	. 
	nop			;0d02	00 	. 
	nop			;0d03	00 	. 
	nop			;0d04	00 	. 
	nop			;0d05	00 	. 
	nop			;0d06	00 	. 
	nop			;0d07	00 	. 
	nop			;0d08	00 	. 
	nop			;0d09	00 	. 
	nop			;0d0a	00 	. 
	nop			;0d0b	00 	. 
	nop			;0d0c	00 	. 
	nop			;0d0d	00 	. 
	nop			;0d0e	00 	. 
	nop			;0d0f	00 	. 
	nop			;0d10	00 	. 
	nop			;0d11	00 	. 
	nop			;0d12	00 	. 
	nop			;0d13	00 	. 
	nop			;0d14	00 	. 
	nop			;0d15	00 	. 
	nop			;0d16	00 	. 
	nop			;0d17	00 	. 
	nop			;0d18	00 	. 
	nop			;0d19	00 	. 
	nop			;0d1a	00 	. 
	nop			;0d1b	00 	. 
	nop			;0d1c	00 	. 
	nop			;0d1d	00 	. 
	nop			;0d1e	00 	. 
	nop			;0d1f	00 	. 
	nop			;0d20	00 	. 
	nop			;0d21	00 	. 
	nop			;0d22	00 	. 
	nop			;0d23	00 	. 
	nop			;0d24	00 	. 
	nop			;0d25	00 	. 
	nop			;0d26	00 	. 
	nop			;0d27	00 	. 
	nop			;0d28	00 	. 
	nop			;0d29	00 	. 
	nop			;0d2a	00 	. 
	nop			;0d2b	00 	. 
	nop			;0d2c	00 	. 
	nop			;0d2d	00 	. 
	nop			;0d2e	00 	. 
	nop			;0d2f	00 	. 
	nop			;0d30	00 	. 
	nop			;0d31	00 	. 
	nop			;0d32	00 	. 
	nop			;0d33	00 	. 
	nop			;0d34	00 	. 
	nop			;0d35	00 	. 
	nop			;0d36	00 	. 
	nop			;0d37	00 	. 
	nop			;0d38	00 	. 
	nop			;0d39	00 	. 
	nop			;0d3a	00 	. 
	nop			;0d3b	00 	. 
	nop			;0d3c	00 	. 
	nop			;0d3d	00 	. 
	nop			;0d3e	00 	. 
	nop			;0d3f	00 	. 
	nop			;0d40	00 	. 
	nop			;0d41	00 	. 
	nop			;0d42	00 	. 
	nop			;0d43	00 	. 
	nop			;0d44	00 	. 
	nop			;0d45	00 	. 
	nop			;0d46	00 	. 
	nop			;0d47	00 	. 
	nop			;0d48	00 	. 
	nop			;0d49	00 	. 
	nop			;0d4a	00 	. 
	nop			;0d4b	00 	. 
	nop			;0d4c	00 	. 
	nop			;0d4d	00 	. 
	nop			;0d4e	00 	. 
	nop			;0d4f	00 	. 
	nop			;0d50	00 	. 
	nop			;0d51	00 	. 
	nop			;0d52	00 	. 
	nop			;0d53	00 	. 
	nop			;0d54	00 	. 
	nop			;0d55	00 	. 
	nop			;0d56	00 	. 
	nop			;0d57	00 	. 
	nop			;0d58	00 	. 
	nop			;0d59	00 	. 
	nop			;0d5a	00 	. 
	nop			;0d5b	00 	. 
	nop			;0d5c	00 	. 
	nop			;0d5d	00 	. 
	nop			;0d5e	00 	. 
	nop			;0d5f	00 	. 
	nop			;0d60	00 	. 
	nop			;0d61	00 	. 
	nop			;0d62	00 	. 
	nop			;0d63	00 	. 
	nop			;0d64	00 	. 
	nop			;0d65	00 	. 
	nop			;0d66	00 	. 
	nop			;0d67	00 	. 
	nop			;0d68	00 	. 
	nop			;0d69	00 	. 
	nop			;0d6a	00 	. 
	nop			;0d6b	00 	. 
	nop			;0d6c	00 	. 
	nop			;0d6d	00 	. 
	nop			;0d6e	00 	. 
	nop			;0d6f	00 	. 
	nop			;0d70	00 	. 
	nop			;0d71	00 	. 
	nop			;0d72	00 	. 
	nop			;0d73	00 	. 
	nop			;0d74	00 	. 
	nop			;0d75	00 	. 
	nop			;0d76	00 	. 
	nop			;0d77	00 	. 
	nop			;0d78	00 	. 
	nop			;0d79	00 	. 
	nop			;0d7a	00 	. 
	nop			;0d7b	00 	. 
	nop			;0d7c	00 	. 
	nop			;0d7d	00 	. 
	nop			;0d7e	00 	. 
	nop			;0d7f	00 	. 
	nop			;0d80	00 	. 
	nop			;0d81	00 	. 
	nop			;0d82	00 	. 
	nop			;0d83	00 	. 
	nop			;0d84	00 	. 
	nop			;0d85	00 	. 
	nop			;0d86	00 	. 
	nop			;0d87	00 	. 
	nop			;0d88	00 	. 
	nop			;0d89	00 	. 
	nop			;0d8a	00 	. 
	nop			;0d8b	00 	. 
	nop			;0d8c	00 	. 
	nop			;0d8d	00 	. 
	nop			;0d8e	00 	. 
	nop			;0d8f	00 	. 
	nop			;0d90	00 	. 
	nop			;0d91	00 	. 
	nop			;0d92	00 	. 
	nop			;0d93	00 	. 
	nop			;0d94	00 	. 
	nop			;0d95	00 	. 
	nop			;0d96	00 	. 
	nop			;0d97	00 	. 
	nop			;0d98	00 	. 
	nop			;0d99	00 	. 
	nop			;0d9a	00 	. 
	nop			;0d9b	00 	. 
	nop			;0d9c	00 	. 
	nop			;0d9d	00 	. 
	nop			;0d9e	00 	. 
	nop			;0d9f	00 	. 
	nop			;0da0	00 	. 
	nop			;0da1	00 	. 
	nop			;0da2	00 	. 
	nop			;0da3	00 	. 
	nop			;0da4	00 	. 
	nop			;0da5	00 	. 
	nop			;0da6	00 	. 
	nop			;0da7	00 	. 
	nop			;0da8	00 	. 
	nop			;0da9	00 	. 
	nop			;0daa	00 	. 
	nop			;0dab	00 	. 
	nop			;0dac	00 	. 
	nop			;0dad	00 	. 
	nop			;0dae	00 	. 
	nop			;0daf	00 	. 
	nop			;0db0	00 	. 
	nop			;0db1	00 	. 
	nop			;0db2	00 	. 
	nop			;0db3	00 	. 
	nop			;0db4	00 	. 
	nop			;0db5	00 	. 
	nop			;0db6	00 	. 
	nop			;0db7	00 	. 
	nop			;0db8	00 	. 
	nop			;0db9	00 	. 
	nop			;0dba	00 	. 
	nop			;0dbb	00 	. 
	nop			;0dbc	00 	. 
	nop			;0dbd	00 	. 
	nop			;0dbe	00 	. 
	nop			;0dbf	00 	. 
	nop			;0dc0	00 	. 
	nop			;0dc1	00 	. 
	nop			;0dc2	00 	. 
	nop			;0dc3	00 	. 
	nop			;0dc4	00 	. 
	nop			;0dc5	00 	. 
	nop			;0dc6	00 	. 
	nop			;0dc7	00 	. 
	nop			;0dc8	00 	. 
	nop			;0dc9	00 	. 
	nop			;0dca	00 	. 
	nop			;0dcb	00 	. 
	nop			;0dcc	00 	. 
	nop			;0dcd	00 	. 
	nop			;0dce	00 	. 
	nop			;0dcf	00 	. 
	nop			;0dd0	00 	. 
	nop			;0dd1	00 	. 
	nop			;0dd2	00 	. 
	nop			;0dd3	00 	. 
	nop			;0dd4	00 	. 
	nop			;0dd5	00 	. 
	nop			;0dd6	00 	. 
	nop			;0dd7	00 	. 
	nop			;0dd8	00 	. 
	nop			;0dd9	00 	. 
	nop			;0dda	00 	. 
	nop			;0ddb	00 	. 
	nop			;0ddc	00 	. 
	nop			;0ddd	00 	. 
	nop			;0dde	00 	. 
	nop			;0ddf	00 	. 
	nop			;0de0	00 	. 
	nop			;0de1	00 	. 
	nop			;0de2	00 	. 
	nop			;0de3	00 	. 
	nop			;0de4	00 	. 
	nop			;0de5	00 	. 
	nop			;0de6	00 	. 
	nop			;0de7	00 	. 
	nop			;0de8	00 	. 
	nop			;0de9	00 	. 
	nop			;0dea	00 	. 
	nop			;0deb	00 	. 
	nop			;0dec	00 	. 
	nop			;0ded	00 	. 
	nop			;0dee	00 	. 
	nop			;0def	00 	. 
	nop			;0df0	00 	. 
	nop			;0df1	00 	. 
	nop			;0df2	00 	. 
	nop			;0df3	00 	. 
	nop			;0df4	00 	. 
	nop			;0df5	00 	. 
	nop			;0df6	00 	. 
	nop			;0df7	00 	. 
	nop			;0df8	00 	. 
	nop			;0df9	00 	. 
	nop			;0dfa	00 	. 
	nop			;0dfb	00 	. 
	nop			;0dfc	00 	. 
	nop			;0dfd	00 	. 
	nop			;0dfe	00 	. 
	nop			;0dff	00 	. 
	nop			;0e00	00 	. 
	nop			;0e01	00 	. 
	nop			;0e02	00 	. 
	nop			;0e03	00 	. 
	nop			;0e04	00 	. 
	nop			;0e05	00 	. 
	nop			;0e06	00 	. 
	nop			;0e07	00 	. 
	nop			;0e08	00 	. 
	nop			;0e09	00 	. 
	nop			;0e0a	00 	. 
	nop			;0e0b	00 	. 
	nop			;0e0c	00 	. 
	nop			;0e0d	00 	. 
	nop			;0e0e	00 	. 
	nop			;0e0f	00 	. 
	nop			;0e10	00 	. 
	nop			;0e11	00 	. 
	nop			;0e12	00 	. 
	nop			;0e13	00 	. 
	nop			;0e14	00 	. 
	nop			;0e15	00 	. 
	nop			;0e16	00 	. 
	nop			;0e17	00 	. 
	nop			;0e18	00 	. 
	nop			;0e19	00 	. 
	nop			;0e1a	00 	. 
	nop			;0e1b	00 	. 
	nop			;0e1c	00 	. 
	nop			;0e1d	00 	. 
	nop			;0e1e	00 	. 
	nop			;0e1f	00 	. 
	nop			;0e20	00 	. 
	nop			;0e21	00 	. 
	nop			;0e22	00 	. 
	nop			;0e23	00 	. 
	nop			;0e24	00 	. 
	nop			;0e25	00 	. 
	nop			;0e26	00 	. 
	nop			;0e27	00 	. 
	nop			;0e28	00 	. 
	nop			;0e29	00 	. 
	nop			;0e2a	00 	. 
	nop			;0e2b	00 	. 
	nop			;0e2c	00 	. 
	nop			;0e2d	00 	. 
	nop			;0e2e	00 	. 
	nop			;0e2f	00 	. 
	nop			;0e30	00 	. 
	nop			;0e31	00 	. 
	nop			;0e32	00 	. 
	nop			;0e33	00 	. 
	nop			;0e34	00 	. 
	nop			;0e35	00 	. 
	nop			;0e36	00 	. 
	nop			;0e37	00 	. 
	nop			;0e38	00 	. 
	nop			;0e39	00 	. 
	nop			;0e3a	00 	. 
	nop			;0e3b	00 	. 
	nop			;0e3c	00 	. 
	nop			;0e3d	00 	. 
	nop			;0e3e	00 	. 
	nop			;0e3f	00 	. 
	nop			;0e40	00 	. 
	nop			;0e41	00 	. 
	nop			;0e42	00 	. 
	nop			;0e43	00 	. 
	nop			;0e44	00 	. 
	nop			;0e45	00 	. 
	nop			;0e46	00 	. 
	nop			;0e47	00 	. 
	nop			;0e48	00 	. 
	nop			;0e49	00 	. 
	nop			;0e4a	00 	. 
	nop			;0e4b	00 	. 
	nop			;0e4c	00 	. 
	nop			;0e4d	00 	. 
	nop			;0e4e	00 	. 
	nop			;0e4f	00 	. 
	nop			;0e50	00 	. 
	nop			;0e51	00 	. 
	nop			;0e52	00 	. 
	nop			;0e53	00 	. 
	nop			;0e54	00 	. 
	nop			;0e55	00 	. 
	nop			;0e56	00 	. 
	nop			;0e57	00 	. 
	nop			;0e58	00 	. 
	nop			;0e59	00 	. 
	nop			;0e5a	00 	. 
	nop			;0e5b	00 	. 
	nop			;0e5c	00 	. 
	nop			;0e5d	00 	. 
	nop			;0e5e	00 	. 
	nop			;0e5f	00 	. 
	nop			;0e60	00 	. 
	nop			;0e61	00 	. 
	nop			;0e62	00 	. 
	nop			;0e63	00 	. 
	nop			;0e64	00 	. 
	nop			;0e65	00 	. 
	nop			;0e66	00 	. 
	nop			;0e67	00 	. 
	nop			;0e68	00 	. 
	nop			;0e69	00 	. 
	nop			;0e6a	00 	. 
	nop			;0e6b	00 	. 
	nop			;0e6c	00 	. 
	nop			;0e6d	00 	. 
	nop			;0e6e	00 	. 
	nop			;0e6f	00 	. 
	nop			;0e70	00 	. 
	nop			;0e71	00 	. 
	nop			;0e72	00 	. 
	nop			;0e73	00 	. 
	nop			;0e74	00 	. 
	nop			;0e75	00 	. 
	nop			;0e76	00 	. 
	nop			;0e77	00 	. 
	nop			;0e78	00 	. 
	nop			;0e79	00 	. 
	nop			;0e7a	00 	. 
	nop			;0e7b	00 	. 
	nop			;0e7c	00 	. 
	nop			;0e7d	00 	. 
	nop			;0e7e	00 	. 
	nop			;0e7f	00 	. 
	nop			;0e80	00 	. 
	nop			;0e81	00 	. 
	nop			;0e82	00 	. 
	nop			;0e83	00 	. 
	nop			;0e84	00 	. 
	nop			;0e85	00 	. 
	nop			;0e86	00 	. 
	nop			;0e87	00 	. 
	nop			;0e88	00 	. 
	nop			;0e89	00 	. 
	nop			;0e8a	00 	. 
	nop			;0e8b	00 	. 
	nop			;0e8c	00 	. 
	nop			;0e8d	00 	. 
	nop			;0e8e	00 	. 
	nop			;0e8f	00 	. 
	nop			;0e90	00 	. 
	nop			;0e91	00 	. 
	nop			;0e92	00 	. 
	nop			;0e93	00 	. 
	nop			;0e94	00 	. 
	nop			;0e95	00 	. 
	nop			;0e96	00 	. 
	nop			;0e97	00 	. 
	nop			;0e98	00 	. 
	nop			;0e99	00 	. 
	nop			;0e9a	00 	. 
	nop			;0e9b	00 	. 
	nop			;0e9c	00 	. 
	nop			;0e9d	00 	. 
	nop			;0e9e	00 	. 
	nop			;0e9f	00 	. 
	nop			;0ea0	00 	. 
	nop			;0ea1	00 	. 
	nop			;0ea2	00 	. 
	nop			;0ea3	00 	. 
	nop			;0ea4	00 	. 
	nop			;0ea5	00 	. 
	nop			;0ea6	00 	. 
	nop			;0ea7	00 	. 
	nop			;0ea8	00 	. 
	nop			;0ea9	00 	. 
	nop			;0eaa	00 	. 
	nop			;0eab	00 	. 
	nop			;0eac	00 	. 
	nop			;0ead	00 	. 
	nop			;0eae	00 	. 
	nop			;0eaf	00 	. 
	nop			;0eb0	00 	. 
	nop			;0eb1	00 	. 
	nop			;0eb2	00 	. 
	nop			;0eb3	00 	. 
	nop			;0eb4	00 	. 
	nop			;0eb5	00 	. 
	nop			;0eb6	00 	. 
	nop			;0eb7	00 	. 
	nop			;0eb8	00 	. 
	nop			;0eb9	00 	. 
	nop			;0eba	00 	. 
	nop			;0ebb	00 	. 
	nop			;0ebc	00 	. 
	nop			;0ebd	00 	. 
	nop			;0ebe	00 	. 
	nop			;0ebf	00 	. 
	nop			;0ec0	00 	. 
	nop			;0ec1	00 	. 
	nop			;0ec2	00 	. 
	nop			;0ec3	00 	. 
	nop			;0ec4	00 	. 
	nop			;0ec5	00 	. 
	nop			;0ec6	00 	. 
	nop			;0ec7	00 	. 
	nop			;0ec8	00 	. 
	nop			;0ec9	00 	. 
	nop			;0eca	00 	. 
	nop			;0ecb	00 	. 
	nop			;0ecc	00 	. 
	nop			;0ecd	00 	. 
	nop			;0ece	00 	. 
	nop			;0ecf	00 	. 
	nop			;0ed0	00 	. 
	nop			;0ed1	00 	. 
	nop			;0ed2	00 	. 
	nop			;0ed3	00 	. 
	nop			;0ed4	00 	. 
	nop			;0ed5	00 	. 
	nop			;0ed6	00 	. 
	nop			;0ed7	00 	. 
	nop			;0ed8	00 	. 
	nop			;0ed9	00 	. 
	nop			;0eda	00 	. 
	nop			;0edb	00 	. 
	nop			;0edc	00 	. 
	nop			;0edd	00 	. 
	nop			;0ede	00 	. 
	nop			;0edf	00 	. 
	nop			;0ee0	00 	. 
	nop			;0ee1	00 	. 
	nop			;0ee2	00 	. 
	nop			;0ee3	00 	. 
	nop			;0ee4	00 	. 
	nop			;0ee5	00 	. 
	nop			;0ee6	00 	. 
	nop			;0ee7	00 	. 
	nop			;0ee8	00 	. 
	nop			;0ee9	00 	. 
	nop			;0eea	00 	. 
	nop			;0eeb	00 	. 
	nop			;0eec	00 	. 
	nop			;0eed	00 	. 
	nop			;0eee	00 	. 
	nop			;0eef	00 	. 
	nop			;0ef0	00 	. 
	nop			;0ef1	00 	. 
	nop			;0ef2	00 	. 
	nop			;0ef3	00 	. 
	nop			;0ef4	00 	. 
	nop			;0ef5	00 	. 
	nop			;0ef6	00 	. 
	nop			;0ef7	00 	. 
	nop			;0ef8	00 	. 
	nop			;0ef9	00 	. 
	nop			;0efa	00 	. 
	nop			;0efb	00 	. 
	nop			;0efc	00 	. 
	nop			;0efd	00 	. 
	nop			;0efe	00 	. 
	nop			;0eff	00 	. 
	nop			;0f00	00 	. 
	nop			;0f01	00 	. 
	nop			;0f02	00 	. 
	nop			;0f03	00 	. 
	nop			;0f04	00 	. 
	nop			;0f05	00 	. 
	nop			;0f06	00 	. 
	nop			;0f07	00 	. 
	nop			;0f08	00 	. 
	nop			;0f09	00 	. 
	nop			;0f0a	00 	. 
	nop			;0f0b	00 	. 
	nop			;0f0c	00 	. 
	nop			;0f0d	00 	. 
	nop			;0f0e	00 	. 
	nop			;0f0f	00 	. 
	nop			;0f10	00 	. 
	nop			;0f11	00 	. 
	nop			;0f12	00 	. 
	nop			;0f13	00 	. 
	nop			;0f14	00 	. 
	nop			;0f15	00 	. 
	nop			;0f16	00 	. 
	nop			;0f17	00 	. 
	nop			;0f18	00 	. 
	nop			;0f19	00 	. 
	nop			;0f1a	00 	. 
	nop			;0f1b	00 	. 
	nop			;0f1c	00 	. 
	nop			;0f1d	00 	. 
	nop			;0f1e	00 	. 
	nop			;0f1f	00 	. 
	nop			;0f20	00 	. 
	nop			;0f21	00 	. 
	nop			;0f22	00 	. 
	nop			;0f23	00 	. 
	nop			;0f24	00 	. 
	nop			;0f25	00 	. 
	nop			;0f26	00 	. 
	nop			;0f27	00 	. 
	nop			;0f28	00 	. 
	nop			;0f29	00 	. 
	nop			;0f2a	00 	. 
	nop			;0f2b	00 	. 
	nop			;0f2c	00 	. 
	nop			;0f2d	00 	. 
	nop			;0f2e	00 	. 
	nop			;0f2f	00 	. 
	nop			;0f30	00 	. 
	nop			;0f31	00 	. 
	nop			;0f32	00 	. 
	nop			;0f33	00 	. 
	nop			;0f34	00 	. 
	nop			;0f35	00 	. 
	nop			;0f36	00 	. 
	nop			;0f37	00 	. 
	nop			;0f38	00 	. 
	nop			;0f39	00 	. 
	nop			;0f3a	00 	. 
	nop			;0f3b	00 	. 
	nop			;0f3c	00 	. 
	nop			;0f3d	00 	. 
	nop			;0f3e	00 	. 
	nop			;0f3f	00 	. 
	nop			;0f40	00 	. 
	nop			;0f41	00 	. 
	nop			;0f42	00 	. 
	nop			;0f43	00 	. 
	nop			;0f44	00 	. 
	nop			;0f45	00 	. 
	nop			;0f46	00 	. 
	nop			;0f47	00 	. 
	nop			;0f48	00 	. 
	nop			;0f49	00 	. 
	nop			;0f4a	00 	. 
	nop			;0f4b	00 	. 
	nop			;0f4c	00 	. 
	nop			;0f4d	00 	. 
	nop			;0f4e	00 	. 
	nop			;0f4f	00 	. 
	nop			;0f50	00 	. 
	nop			;0f51	00 	. 
	nop			;0f52	00 	. 
	nop			;0f53	00 	. 
	nop			;0f54	00 	. 
	nop			;0f55	00 	. 
	nop			;0f56	00 	. 
	nop			;0f57	00 	. 
	nop			;0f58	00 	. 
	nop			;0f59	00 	. 
	nop			;0f5a	00 	. 
	nop			;0f5b	00 	. 
	nop			;0f5c	00 	. 
	nop			;0f5d	00 	. 
	nop			;0f5e	00 	. 
	nop			;0f5f	00 	. 
	nop			;0f60	00 	. 
	nop			;0f61	00 	. 
	nop			;0f62	00 	. 
	nop			;0f63	00 	. 
	nop			;0f64	00 	. 
	nop			;0f65	00 	. 
	nop			;0f66	00 	. 
	nop			;0f67	00 	. 
	nop			;0f68	00 	. 
	nop			;0f69	00 	. 
	nop			;0f6a	00 	. 
	nop			;0f6b	00 	. 
	nop			;0f6c	00 	. 
	nop			;0f6d	00 	. 
	nop			;0f6e	00 	. 
	nop			;0f6f	00 	. 
	nop			;0f70	00 	. 
	nop			;0f71	00 	. 
	nop			;0f72	00 	. 
	nop			;0f73	00 	. 
	nop			;0f74	00 	. 
	nop			;0f75	00 	. 
	nop			;0f76	00 	. 
	nop			;0f77	00 	. 
	nop			;0f78	00 	. 
	nop			;0f79	00 	. 
	nop			;0f7a	00 	. 
	nop			;0f7b	00 	. 
	nop			;0f7c	00 	. 
	nop			;0f7d	00 	. 
	nop			;0f7e	00 	. 
	nop			;0f7f	00 	. 
	nop			;0f80	00 	. 
	nop			;0f81	00 	. 
	nop			;0f82	00 	. 
	nop			;0f83	00 	. 
	nop			;0f84	00 	. 
	nop			;0f85	00 	. 
	nop			;0f86	00 	. 
	nop			;0f87	00 	. 
	nop			;0f88	00 	. 
	nop			;0f89	00 	. 
	nop			;0f8a	00 	. 
	nop			;0f8b	00 	. 
	nop			;0f8c	00 	. 
	nop			;0f8d	00 	. 
	nop			;0f8e	00 	. 
	nop			;0f8f	00 	. 
	nop			;0f90	00 	. 
	nop			;0f91	00 	. 
	nop			;0f92	00 	. 
	nop			;0f93	00 	. 
	nop			;0f94	00 	. 
	nop			;0f95	00 	. 
	nop			;0f96	00 	. 
	nop			;0f97	00 	. 
	nop			;0f98	00 	. 
	nop			;0f99	00 	. 
	nop			;0f9a	00 	. 
	nop			;0f9b	00 	. 
	nop			;0f9c	00 	. 
	nop			;0f9d	00 	. 
	nop			;0f9e	00 	. 
	nop			;0f9f	00 	. 
	nop			;0fa0	00 	. 
	nop			;0fa1	00 	. 
	nop			;0fa2	00 	. 
	nop			;0fa3	00 	. 
	nop			;0fa4	00 	. 
	nop			;0fa5	00 	. 
	nop			;0fa6	00 	. 
	nop			;0fa7	00 	. 
	nop			;0fa8	00 	. 
	nop			;0fa9	00 	. 
	nop			;0faa	00 	. 
	nop			;0fab	00 	. 
	nop			;0fac	00 	. 
	nop			;0fad	00 	. 
	nop			;0fae	00 	. 
	nop			;0faf	00 	. 
	nop			;0fb0	00 	. 
	nop			;0fb1	00 	. 
	nop			;0fb2	00 	. 
	nop			;0fb3	00 	. 
	nop			;0fb4	00 	. 
	nop			;0fb5	00 	. 
	nop			;0fb6	00 	. 
	nop			;0fb7	00 	. 
	nop			;0fb8	00 	. 
	nop			;0fb9	00 	. 
	nop			;0fba	00 	. 
	nop			;0fbb	00 	. 
	nop			;0fbc	00 	. 
	nop			;0fbd	00 	. 
	nop			;0fbe	00 	. 
	nop			;0fbf	00 	. 
	nop			;0fc0	00 	. 
	nop			;0fc1	00 	. 
	nop			;0fc2	00 	. 
	nop			;0fc3	00 	. 
	nop			;0fc4	00 	. 
	nop			;0fc5	00 	. 
	nop			;0fc6	00 	. 
	nop			;0fc7	00 	. 
	nop			;0fc8	00 	. 
	nop			;0fc9	00 	. 
	nop			;0fca	00 	. 
	nop			;0fcb	00 	. 
	nop			;0fcc	00 	. 
	nop			;0fcd	00 	. 
	nop			;0fce	00 	. 
	nop			;0fcf	00 	. 
	nop			;0fd0	00 	. 
	nop			;0fd1	00 	. 
	nop			;0fd2	00 	. 
	nop			;0fd3	00 	. 
	nop			;0fd4	00 	. 
	nop			;0fd5	00 	. 
	nop			;0fd6	00 	. 
	nop			;0fd7	00 	. 
	nop			;0fd8	00 	. 
	nop			;0fd9	00 	. 
	nop			;0fda	00 	. 
	nop			;0fdb	00 	. 
	nop			;0fdc	00 	. 
	nop			;0fdd	00 	. 
	nop			;0fde	00 	. 
	nop			;0fdf	00 	. 
	nop			;0fe0	00 	. 
	nop			;0fe1	00 	. 
	nop			;0fe2	00 	. 
	nop			;0fe3	00 	. 
	nop			;0fe4	00 	. 
	nop			;0fe5	00 	. 
	nop			;0fe6	00 	. 
	nop			;0fe7	00 	. 
	nop			;0fe8	00 	. 
	nop			;0fe9	00 	. 
	nop			;0fea	00 	. 
	nop			;0feb	00 	. 
	nop			;0fec	00 	. 
	nop			;0fed	00 	. 
	nop			;0fee	00 	. 
	nop			;0fef	00 	. 
	nop			;0ff0	00 	. 
	nop			;0ff1	00 	. 
	nop			;0ff2	00 	. 
	nop			;0ff3	00 	. 
	nop			;0ff4	00 	. 
	nop			;0ff5	00 	. 
	nop			;0ff6	00 	. 
	nop			;0ff7	00 	. 
	nop			;0ff8	00 	. 
	nop			;0ff9	00 	. 
	nop			;0ffa	00 	. 
	nop			;0ffb	00 	. 
	nop			;0ffc	00 	. 
	nop			;0ffd	00 	. 
	nop			;0ffe	00 	. 
	nop			;0fff	00 	. 
l1000h:
	ld (bc),a			;1000	02 	. 
	ld (de),a			;1001	12 	. 
	inc bc			;1002	03 	. 
	ld (de),a			;1003	12 	. 
	ld c,012h		;1004	0e 12 	. . 
	add hl,de			;1006	19 	. 
	ld (de),a			;1007	12 	. 
	rra			;1008	1f 	. 
	ld (de),a			;1009	12 	. 
	dec h			;100a	25 	% 
	ld (de),a			;100b	12 	. 
	dec hl			;100c	2b 	+ 
	ld (de),a			;100d	12 	. 
	ld (bc),a			;100e	02 	. 
	ld (de),a			;100f	12 	. 
	ld (bc),a			;1010	02 	. 
	ld (de),a			;1011	12 	. 
	ld (bc),a			;1012	02 	. 
	ld (de),a			;1013	12 	. 
	ld (bc),a			;1014	02 	. 
	ld (de),a			;1015	12 	. 
	ld sp,l3c12h		;1016	31 12 3c 	1 . < 
	ld (de),a			;1019	12 	. 
	ld b,a			;101a	47 	G 
	ld (de),a			;101b	12 	. 
	ld c,l			;101c	4d 	M 
	ld (de),a			;101d	12 	. 
	ld d,e			;101e	53 	S 
	ld (de),a			;101f	12 	. 
	ld e,c			;1020	59 	Y 
	ld (de),a			;1021	12 	. 
	ld (hl),a			;1022	77 	w 
	ld (de),a			;1023	12 	. 
	add a,d			;1024	82 	. 
	ld (de),a			;1025	12 	. 
	ld (bc),a			;1026	02 	. 
	ld (de),a			;1027	12 	. 
	ld (bc),a			;1028	02 	. 
	ld (de),a			;1029	12 	. 
	ld (bc),a			;102a	02 	. 
	ld (de),a			;102b	12 	. 
	ld (bc),a			;102c	02 	. 
	ld (de),a			;102d	12 	. 
	ld e,a			;102e	5f 	_ 
	ld (de),a			;102f	12 	. 
	ld h,l			;1030	65 	e 
	ld (de),a			;1031	12 	. 
	ld l,e			;1032	6b 	k 
	ld (de),a			;1033	12 	. 
	ld (hl),c			;1034	71 	q 
	ld (de),a			;1035	12 	. 
	ld (bc),a			;1036	02 	. 
	ld (de),a			;1037	12 	. 
	ld (bc),a			;1038	02 	. 
	ld (de),a			;1039	12 	. 
	ld (bc),a			;103a	02 	. 
	ld (de),a			;103b	12 	. 
	ld (bc),a			;103c	02 	. 
	ld (de),a			;103d	12 	. 
	adc a,l			;103e	8d 	. 
	ld (de),a			;103f	12 	. 
	sub e			;1040	93 	. 
	ld (de),a			;1041	12 	. 
	sbc a,c			;1042	99 	. 
	ld (de),a			;1043	12 	. 
	sbc a,a			;1044	9f 	. 
	ld (de),a			;1045	12 	. 
	and l			;1046	a5 	. 
	ld (de),a			;1047	12 	. 
	or b			;1048	b0 	. 
	ld (de),a			;1049	12 	. 
	cp e			;104a	bb 	. 
	ld (de),a			;104b	12 	. 
	add a,012h		;104c	c6 12 	. . 
	ld (bc),a			;104e	02 	. 
	ld (de),a			;104f	12 	. 
	ld (bc),a			;1050	02 	. 
	ld (de),a			;1051	12 	. 
	pop de			;1052	d1 	. 
	ld (de),a			;1053	12 	. 
	rst 10h			;1054	d7 	. 
	ld (de),a			;1055	12 	. 
	defb 0ddh,012h,0e3h	;illegal sequence		;1056	dd 12 e3 	. . . 
	ld (de),a			;1059	12 	. 
	jp (hl)			;105a	e9 	. 
	ld (de),a			;105b	12 	. 
	rst 28h			;105c	ef 	. 
	ld (de),a			;105d	12 	. 
	push af			;105e	f5 	. 
	ld (de),a			;105f	12 	. 
	ei			;1060	fb 	. 
	ld (de),a			;1061	12 	. 
	ld bc,l0c13h		;1062	01 13 0c 	. . . 
	inc de			;1065	13 	. 
	rla			;1066	17 	. 
	inc de			;1067	13 	. 
	dec e			;1068	1d 	. 
	inc de			;1069	13 	. 
	inc hl			;106a	23 	# 
	inc de			;106b	13 	. 
	add hl,hl			;106c	29 	) 
	inc de			;106d	13 	. 
	cpl			;106e	2f 	/ 
	inc de			;106f	13 	. 
	dec (hl)			;1070	35 	5 
	inc de			;1071	13 	. 
	ld (bc),a			;1072	02 	. 
	ld (de),a			;1073	12 	. 
	ld (bc),a			;1074	02 	. 
	ld (de),a			;1075	12 	. 
	dec sp			;1076	3b 	; 
	inc de			;1077	13 	. 
	ld b,(hl)			;1078	46 	F 
	inc de			;1079	13 	. 
	ld d,c			;107a	51 	Q 
	inc de			;107b	13 	. 
	ld d,a			;107c	57 	W 
	inc de			;107d	13 	. 
	ld e,l			;107e	5d 	] 
	inc de			;107f	13 	. 
	ld h,e			;1080	63 	c 
	inc de			;1081	13 	. 
	ld l,c			;1082	69 	i 
	inc de			;1083	13 	. 
	ld l,a			;1084	6f 	o 
	inc de			;1085	13 	. 
	ld (hl),l			;1086	75 	u 
	inc de			;1087	13 	. 
	add a,b			;1088	80 	. 
	inc de			;1089	13 	. 
	adc a,e			;108a	8b 	. 
	inc de			;108b	13 	. 
	sub (hl)			;108c	96 	. 
	inc de			;108d	13 	. 
	ld (bc),a			;108e	02 	. 
	ld (de),a			;108f	12 	. 
	ld (bc),a			;1090	02 	. 
	ld (de),a			;1091	12 	. 
	and c			;1092	a1 	. 
	inc de			;1093	13 	. 
	and a			;1094	a7 	. 
	inc de			;1095	13 	. 
	xor l			;1096	ad 	. 
	inc de			;1097	13 	. 
	or e			;1098	b3 	. 
	inc de			;1099	13 	. 
	cp c			;109a	b9 	. 
	inc de			;109b	13 	. 
	call nz,0cf13h		;109c	c4 13 cf 	. . . 
	inc de			;109f	13 	. 
	call c,0e913h		;10a0	dc 13 e9 	. . . 
	inc de			;10a3	13 	. 
	defb 0edh;next byte illegal after ed		;10a4	ed 	. 
	inc de			;10a5	13 	. 
	ld e,e			;10a6	5b 	[ 
	inc d			;10a7	14 	. 
	adc a,e			;10a8	8b 	. 
	inc d			;10a9	14 	. 
	sbc a,h			;10aa	9c 	. 
	inc d			;10ab	14 	. 
	xor c			;10ac	a9 	. 
	inc d			;10ad	14 	. 
	or (hl)			;10ae	b6 	. 
	inc d			;10af	14 	. 
	cp h			;10b0	bc 	. 
	inc d			;10b1	14 	. 
	pop bc			;10b2	c1 	. 
	inc d			;10b3	14 	. 
	rst 0			;10b4	c7 	. 
	inc d			;10b5	14 	. 
	ld (bc),a			;10b6	02 	. 
	ld (de),a			;10b7	12 	. 
	ld (bc),a			;10b8	02 	. 
	ld (de),a			;10b9	12 	. 
	call z,0d014h		;10ba	cc 14 d0 	. . . 
	inc d			;10bd	14 	. 
	call nc,0e814h		;10be	d4 14 e8 	. . . 
	inc d			;10c1	14 	. 
	call pe,0a914h		;10c2	ec 14 a9 	. . . 
	inc e			;10c5	1c 	. 
	push bc			;10c6	c5 	. 
	inc e			;10c7	1c 	. 
	pop hl			;10c8	e1 	. 
	inc e			;10c9	1c 	. 
	defb 0fdh,01ch,019h	;illegal sequence		;10ca	fd 1c 19 	. . . 
	dec e			;10cd	1d 	. 
	dec (hl)			;10ce	35 	5 
	dec e			;10cf	1d 	. 
	ld d,c			;10d0	51 	Q 
	dec e			;10d1	1d 	. 
	add a,c			;10d2	81 	. 
	dec d			;10d3	15 	. 
	ex (sp),hl			;10d4	e3 	. 
	inc d			;10d5	14 	. 
	inc e			;10d6	1c 	. 
	dec d			;10d7	15 	. 
	ccf			;10d8	3f 	? 
	dec d			;10d9	15 	. 
	ld l,l			;10da	6d 	m 
	dec e			;10db	1d 	. 
	adc a,c			;10dc	89 	. 
	dec e			;10dd	1d 	. 
	and l			;10de	a5 	. 
	dec e			;10df	1d 	. 
	ret			;10e0	c9 	. 
	dec e			;10e1	1d 	. 
	pop bc			;10e2	c1 	. 
	dec e			;10e3	1d 	. 
	ld e,a			;10e4	5f 	_ 
	dec d			;10e5	15 	. 
	jp nz,0cb15h		;10e6	c2 15 cb 	. . . 
	dec d			;10e9	15 	. 
	call nc,0d815h		;10ea	d4 15 d8 	. . . 
	dec d			;10ed	15 	. 
	pop hl			;10ee	e1 	. 
	dec d			;10ef	15 	. 
	jp pe,0ee15h		;10f0	ea 15 ee 	. . . 
	dec d			;10f3	15 	. 
	jp p,0f615h		;10f4	f2 15 f6 	. . . 
	dec d			;10f7	15 	. 
	jp m,09515h		;10f8	fa 15 95 	. . . 
	dec d			;10fb	15 	. 
	ld (hl),017h		;10fc	36 17 	6 . 
	cp 015h		;10fe	fe 15 	. . 
	ld (bc),a			;1100	02 	. 
	ld (de),a			;1101	12 	. 
	adc a,d			;1102	8a 	. 
	dec d			;1103	15 	. 
	sub b			;1104	90 	. 
	dec d			;1105	15 	. 
	xor 013h		;1106	ee 13 	. . 
	ld (bc),a			;1108	02 	. 
	ld (de),a			;1109	12 	. 
	ld (bc),a			;110a	02 	. 
	ld (de),a			;110b	12 	. 
	ld (bc),a			;110c	02 	. 
	ld (de),a			;110d	12 	. 
	ld (bc),a			;110e	02 	. 
	ld (de),a			;110f	12 	. 
	ld (bc),a			;1110	02 	. 
	ld (de),a			;1111	12 	. 
	ld (bc),a			;1112	02 	. 
	ld (de),a			;1113	12 	. 
	ld (bc),a			;1114	02 	. 
	ld (de),a			;1115	12 	. 
	ld (bc),a			;1116	02 	. 
	ld (de),a			;1117	12 	. 
	ld (bc),a			;1118	02 	. 
	ld (de),a			;1119	12 	. 
	ld (bc),a			;111a	02 	. 
	ld (de),a			;111b	12 	. 
	ld (bc),a			;111c	02 	. 
	ld (de),a			;111d	12 	. 
	ld (bc),a			;111e	02 	. 
	ld (de),a			;111f	12 	. 
	ld (bc),a			;1120	02 	. 
	ld (de),a			;1121	12 	. 
	ld (bc),a			;1122	02 	. 
	ld (de),a			;1123	12 	. 
	ld (bc),a			;1124	02 	. 
	ld (de),a			;1125	12 	. 
	ld (bc),a			;1126	02 	. 
	ld (de),a			;1127	12 	. 
	ld (bc),a			;1128	02 	. 
	ld (de),a			;1129	12 	. 
	ld (bc),a			;112a	02 	. 
	ld (de),a			;112b	12 	. 
	ld (bc),a			;112c	02 	. 
	ld (de),a			;112d	12 	. 
	ld (bc),a			;112e	02 	. 
	ld (de),a			;112f	12 	. 
	ld (bc),a			;1130	02 	. 
	ld (de),a			;1131	12 	. 
	ld (bc),a			;1132	02 	. 
	ld (de),a			;1133	12 	. 
	ld (bc),a			;1134	02 	. 
	ld (de),a			;1135	12 	. 
	ld (bc),a			;1136	02 	. 
	ld (de),a			;1137	12 	. 
	ld (bc),a			;1138	02 	. 
	ld (de),a			;1139	12 	. 
	ld (bc),a			;113a	02 	. 
	ld (de),a			;113b	12 	. 
	ld (bc),a			;113c	02 	. 
	ld (de),a			;113d	12 	. 
	ld (bc),a			;113e	02 	. 
	ld (de),a			;113f	12 	. 
	ld (bc),a			;1140	02 	. 
	ld (de),a			;1141	12 	. 
	ld (bc),a			;1142	02 	. 
	ld (de),a			;1143	12 	. 
	ld (bc),a			;1144	02 	. 
	ld (de),a			;1145	12 	. 
	ld (bc),a			;1146	02 	. 
	ld (de),a			;1147	12 	. 
	ld (bc),a			;1148	02 	. 
	ld (de),a			;1149	12 	. 
	ld (bc),a			;114a	02 	. 
	ld (de),a			;114b	12 	. 
	ld (bc),a			;114c	02 	. 
	ld (de),a			;114d	12 	. 
	ld (bc),a			;114e	02 	. 
	ld (de),a			;114f	12 	. 
	ld (bc),a			;1150	02 	. 
	ld (de),a			;1151	12 	. 
	ld (bc),a			;1152	02 	. 
	ld (de),a			;1153	12 	. 
	ld (bc),a			;1154	02 	. 
	ld (de),a			;1155	12 	. 
	ld (bc),a			;1156	02 	. 
	ld (de),a			;1157	12 	. 
	ld (bc),a			;1158	02 	. 
	ld (de),a			;1159	12 	. 
	ld (bc),a			;115a	02 	. 
	ld (de),a			;115b	12 	. 
	ld (bc),a			;115c	02 	. 
	ld (de),a			;115d	12 	. 
	ld (bc),a			;115e	02 	. 
	ld (de),a			;115f	12 	. 
	ld (bc),a			;1160	02 	. 
	ld (de),a			;1161	12 	. 
	ld (bc),a			;1162	02 	. 
	ld (de),a			;1163	12 	. 
	ld (bc),a			;1164	02 	. 
	ld (de),a			;1165	12 	. 
	ld (bc),a			;1166	02 	. 
	ld (de),a			;1167	12 	. 
	ld (bc),a			;1168	02 	. 
	ld (de),a			;1169	12 	. 
	ld (bc),a			;116a	02 	. 
	ld (de),a			;116b	12 	. 
	ld (bc),a			;116c	02 	. 
	ld (de),a			;116d	12 	. 
	ld (bc),a			;116e	02 	. 
	ld (de),a			;116f	12 	. 
	ld (bc),a			;1170	02 	. 
	ld (de),a			;1171	12 	. 
	ld (bc),a			;1172	02 	. 
	ld (de),a			;1173	12 	. 
	ld (bc),a			;1174	02 	. 
	ld (de),a			;1175	12 	. 
	ld (bc),a			;1176	02 	. 
	ld (de),a			;1177	12 	. 
	ld (bc),a			;1178	02 	. 
	ld (de),a			;1179	12 	. 
	ld (bc),a			;117a	02 	. 
	ld (de),a			;117b	12 	. 
	ld (bc),a			;117c	02 	. 
	ld (de),a			;117d	12 	. 
	ld (bc),a			;117e	02 	. 
	ld (de),a			;117f	12 	. 
	ld (bc),a			;1180	02 	. 
	ld (de),a			;1181	12 	. 
	ld (bc),a			;1182	02 	. 
	ld (de),a			;1183	12 	. 
	ld (bc),a			;1184	02 	. 
	ld (de),a			;1185	12 	. 
	ld (bc),a			;1186	02 	. 
	ld (de),a			;1187	12 	. 
	ld (bc),a			;1188	02 	. 
	ld (de),a			;1189	12 	. 
	ld (bc),a			;118a	02 	. 
	ld (de),a			;118b	12 	. 
	ld (bc),a			;118c	02 	. 
	ld (de),a			;118d	12 	. 
	ld (bc),a			;118e	02 	. 
	ld (de),a			;118f	12 	. 
	ld (bc),a			;1190	02 	. 
	ld (de),a			;1191	12 	. 
	ld (bc),a			;1192	02 	. 
	ld (de),a			;1193	12 	. 
	ld (bc),a			;1194	02 	. 
	ld (de),a			;1195	12 	. 
	ld (bc),a			;1196	02 	. 
	ld (de),a			;1197	12 	. 
	ld (bc),a			;1198	02 	. 
	ld (de),a			;1199	12 	. 
	ld (bc),a			;119a	02 	. 
	ld (de),a			;119b	12 	. 
	ld (bc),a			;119c	02 	. 
	ld (de),a			;119d	12 	. 
	ld (bc),a			;119e	02 	. 
	ld (de),a			;119f	12 	. 
	ld (bc),a			;11a0	02 	. 
	ld (de),a			;11a1	12 	. 
	ld (bc),a			;11a2	02 	. 
	ld (de),a			;11a3	12 	. 
	ld (bc),a			;11a4	02 	. 
	ld (de),a			;11a5	12 	. 
	ld (bc),a			;11a6	02 	. 
	ld (de),a			;11a7	12 	. 
	ld (bc),a			;11a8	02 	. 
	ld (de),a			;11a9	12 	. 
	ld (bc),a			;11aa	02 	. 
	ld (de),a			;11ab	12 	. 
	ld (bc),a			;11ac	02 	. 
	ld (de),a			;11ad	12 	. 
	ld (bc),a			;11ae	02 	. 
	ld (de),a			;11af	12 	. 
	ld (bc),a			;11b0	02 	. 
	ld (de),a			;11b1	12 	. 
	ld (bc),a			;11b2	02 	. 
	ld (de),a			;11b3	12 	. 
	ld (bc),a			;11b4	02 	. 
	ld (de),a			;11b5	12 	. 
	ld (bc),a			;11b6	02 	. 
	ld (de),a			;11b7	12 	. 
	ld (bc),a			;11b8	02 	. 
	ld (de),a			;11b9	12 	. 
	ld (bc),a			;11ba	02 	. 
	ld (de),a			;11bb	12 	. 
	ld (bc),a			;11bc	02 	. 
	ld (de),a			;11bd	12 	. 
	ld (bc),a			;11be	02 	. 
	ld (de),a			;11bf	12 	. 
	ld (bc),a			;11c0	02 	. 
	ld (de),a			;11c1	12 	. 
	ld (bc),a			;11c2	02 	. 
	ld (de),a			;11c3	12 	. 
	ld (bc),a			;11c4	02 	. 
	ld (de),a			;11c5	12 	. 
	ld (bc),a			;11c6	02 	. 
	ld (de),a			;11c7	12 	. 
	ld (bc),a			;11c8	02 	. 
	ld (de),a			;11c9	12 	. 
	ld (bc),a			;11ca	02 	. 
	ld (de),a			;11cb	12 	. 
	ld (bc),a			;11cc	02 	. 
	ld (de),a			;11cd	12 	. 
	ld (bc),a			;11ce	02 	. 
	ld (de),a			;11cf	12 	. 
	ld (bc),a			;11d0	02 	. 
	ld (de),a			;11d1	12 	. 
	ld (bc),a			;11d2	02 	. 
	ld (de),a			;11d3	12 	. 
	ld (bc),a			;11d4	02 	. 
	ld (de),a			;11d5	12 	. 
	ld (bc),a			;11d6	02 	. 
	ld (de),a			;11d7	12 	. 
	ld (bc),a			;11d8	02 	. 
	ld (de),a			;11d9	12 	. 
	ld (bc),a			;11da	02 	. 
	ld (de),a			;11db	12 	. 
	ld (bc),a			;11dc	02 	. 
	ld (de),a			;11dd	12 	. 
	ld (bc),a			;11de	02 	. 
	ld (de),a			;11df	12 	. 
	ld (bc),a			;11e0	02 	. 
	ld (de),a			;11e1	12 	. 
	ld (bc),a			;11e2	02 	. 
	ld (de),a			;11e3	12 	. 
	ld (bc),a			;11e4	02 	. 
	ld (de),a			;11e5	12 	. 
	ld (bc),a			;11e6	02 	. 
	ld (de),a			;11e7	12 	. 
	ld (bc),a			;11e8	02 	. 
	ld (de),a			;11e9	12 	. 
	ld (bc),a			;11ea	02 	. 
	ld (de),a			;11eb	12 	. 
	ld (bc),a			;11ec	02 	. 
	ld (de),a			;11ed	12 	. 
	ld (bc),a			;11ee	02 	. 
	ld (de),a			;11ef	12 	. 
	ld (bc),a			;11f0	02 	. 
	ld (de),a			;11f1	12 	. 
	ld (bc),a			;11f2	02 	. 
	ld (de),a			;11f3	12 	. 
	ld (bc),a			;11f4	02 	. 
	ld (de),a			;11f5	12 	. 
	ld (bc),a			;11f6	02 	. 
	ld (de),a			;11f7	12 	. 
	ld (bc),a			;11f8	02 	. 
	ld (de),a			;11f9	12 	. 
	ld (bc),a			;11fa	02 	. 
	ld (de),a			;11fb	12 	. 
	ld (bc),a			;11fc	02 	. 
	ld (de),a			;11fd	12 	. 
	ld (bc),a			;11fe	02 	. 
	ld (de),a			;11ff	12 	. 
	ld (bc),a			;1200	02 	. 
	ld (de),a			;1201	12 	. 
l1202h:
	ret			;1202	c9 	. 
sub_1203h:
	ld hl,0c0e3h		;1203	21 e3 c0 	! . . 
	res 0,(hl)		;1206	cb 86 	. . 
	ld hl,0c0deh		;1208	21 de c0 	! . . 
	set 0,(hl)		;120b	cb c6 	. . 
	ret			;120d	c9 	. 
sub_120eh:
	ld hl,0c0e3h		;120e	21 e3 c0 	! . . 
	set 0,(hl)		;1211	cb c6 	. . 
	ld hl,0c0deh		;1213	21 de c0 	! . . 
	res 0,(hl)		;1216	cb 86 	. . 
	ret			;1218	c9 	. 
sub_1219h:
	ld hl,0c0dfh		;1219	21 df c0 	! . . 
	set 0,(hl)		;121c	cb c6 	. . 
	ret			;121e	c9 	. 
sub_121fh:
	ld hl,0c0dfh		;121f	21 df c0 	! . . 
	res 0,(hl)		;1222	cb 86 	. . 
	ret			;1224	c9 	. 
sub_1225h:
	ld hl,0c0e0h		;1225	21 e0 c0 	! . . 
	set 0,(hl)		;1228	cb c6 	. . 
	ret			;122a	c9 	. 
sub_122bh:
	ld hl,0c0e0h		;122b	21 e0 c0 	! . . 
	res 0,(hl)		;122e	cb 86 	. . 
	ret			;1230	c9 	. 
sub_1231h:
	ld hl,0c0e3h		;1231	21 e3 c0 	! . . 
	res 1,(hl)		;1234	cb 8e 	. . 
	ld hl,0c0deh		;1236	21 de c0 	! . . 
	set 1,(hl)		;1239	cb ce 	. . 
	ret			;123b	c9 	. 
sub_123ch:
	ld hl,0c0e3h		;123c	21 e3 c0 	! . . 
	set 1,(hl)		;123f	cb ce 	. . 
	ld hl,0c0deh		;1241	21 de c0 	! . . 
	res 1,(hl)		;1244	cb 8e 	. . 
	ret			;1246	c9 	. 
sub_1247h:
	ld hl,0c0dfh		;1247	21 df c0 	! . . 
	set 1,(hl)		;124a	cb ce 	. . 
	ret			;124c	c9 	. 
sub_124dh:
	ld hl,0c0dfh		;124d	21 df c0 	! . . 
	res 1,(hl)		;1250	cb 8e 	. . 
	ret			;1252	c9 	. 
sub_1253h:
	ld hl,0c0e0h		;1253	21 e0 c0 	! . . 
	set 1,(hl)		;1256	cb ce 	. . 
	ret			;1258	c9 	. 
sub_1259h:
	ld hl,0c0e0h		;1259	21 e0 c0 	! . . 
	res 1,(hl)		;125c	cb 8e 	. . 
	ret			;125e	c9 	. 
sub_125fh:
	ld hl,0c0dfh		;125f	21 df c0 	! . . 
	set 2,(hl)		;1262	cb d6 	. . 
	ret			;1264	c9 	. 
sub_1265h:
	ld hl,0c0dfh		;1265	21 df c0 	! . . 
	res 2,(hl)		;1268	cb 96 	. . 
	ret			;126a	c9 	. 
sub_126bh:
	ld hl,0c0e0h		;126b	21 e0 c0 	! . . 
	set 2,(hl)		;126e	cb d6 	. . 
	ret			;1270	c9 	. 
sub_1271h:
	ld hl,0c0e0h		;1271	21 e0 c0 	! . . 
	res 2,(hl)		;1274	cb 96 	. . 
	ret			;1276	c9 	. 
sub_1277h:
	ld hl,0c0e6h		;1277	21 e6 c0 	! . . 
	res 2,(hl)		;127a	cb 96 	. . 
	ld hl,0c0e1h		;127c	21 e1 c0 	! . . 
	set 2,(hl)		;127f	cb d6 	. . 
	ret			;1281	c9 	. 
sub_1282h:
	ld hl,0c0e6h		;1282	21 e6 c0 	! . . 
	set 2,(hl)		;1285	cb d6 	. . 
	ld hl,0c0e1h		;1287	21 e1 c0 	! . . 
	res 2,(hl)		;128a	cb 96 	. . 
	ret			;128c	c9 	. 
sub_128dh:
	ld hl,0c0deh		;128d	21 de c0 	! . . 
	set 3,(hl)		;1290	cb de 	. . 
	ret			;1292	c9 	. 
sub_1293h:
	ld hl,0c0deh		;1293	21 de c0 	! . . 
	res 3,(hl)		;1296	cb 9e 	. . 
	ret			;1298	c9 	. 
sub_1299h:
	ld hl,0c0dfh		;1299	21 df c0 	! . . 
	set 3,(hl)		;129c	cb de 	. . 
	ret			;129e	c9 	. 
sub_129fh:
	ld hl,0c0dfh		;129f	21 df c0 	! . . 
	res 3,(hl)		;12a2	cb 9e 	. . 
	ret			;12a4	c9 	. 
sub_12a5h:
	ld hl,0c0e5h		;12a5	21 e5 c0 	! . . 
	res 3,(hl)		;12a8	cb 9e 	. . 
	ld hl,0c0e0h		;12aa	21 e0 c0 	! . . 
	set 3,(hl)		;12ad	cb de 	. . 
	ret			;12af	c9 	. 
sub_12b0h:
	ld hl,0c0e5h		;12b0	21 e5 c0 	! . . 
	set 3,(hl)		;12b3	cb de 	. . 
	ld hl,0c0e0h		;12b5	21 e0 c0 	! . . 
	res 3,(hl)		;12b8	cb 9e 	. . 
	ret			;12ba	c9 	. 
sub_12bbh:
	ld hl,0c0e6h		;12bb	21 e6 c0 	! . . 
	res 3,(hl)		;12be	cb 9e 	. . 
	ld hl,0c0e1h		;12c0	21 e1 c0 	! . . 
	set 3,(hl)		;12c3	cb de 	. . 
	ret			;12c5	c9 	. 
sub_12c6h:
	ld hl,0c0e6h		;12c6	21 e6 c0 	! . . 
	set 3,(hl)		;12c9	cb de 	. . 
	ld hl,0c0e1h		;12cb	21 e1 c0 	! . . 
	res 3,(hl)		;12ce	cb 9e 	. . 
	ret			;12d0	c9 	. 
sub_12d1h:
	ld hl,0c0deh		;12d1	21 de c0 	! . . 
	set 4,(hl)		;12d4	cb e6 	. . 
	ret			;12d6	c9 	. 
sub_12d7h:
	ld hl,0c0deh		;12d7	21 de c0 	! . . 
	res 4,(hl)		;12da	cb a6 	. . 
	ret			;12dc	c9 	. 
sub_12ddh:
	ld hl,0c0dfh		;12dd	21 df c0 	! . . 
	set 4,(hl)		;12e0	cb e6 	. . 
	ret			;12e2	c9 	. 
sub_12e3h:
	ld hl,0c0dfh		;12e3	21 df c0 	! . . 
	res 4,(hl)		;12e6	cb a6 	. . 
	ret			;12e8	c9 	. 
sub_12e9h:
	ld hl,0c0e0h		;12e9	21 e0 c0 	! . . 
	set 4,(hl)		;12ec	cb e6 	. . 
	ret			;12ee	c9 	. 
sub_12efh:
	ld hl,0c0e0h		;12ef	21 e0 c0 	! . . 
	res 4,(hl)		;12f2	cb a6 	. . 
	ret			;12f4	c9 	. 
sub_12f5h:
	ld hl,0c0e1h		;12f5	21 e1 c0 	! . . 
	set 4,(hl)		;12f8	cb e6 	. . 
	ret			;12fa	c9 	. 
sub_12fbh:
	ld hl,0c0e1h		;12fb	21 e1 c0 	! . . 
	res 4,(hl)		;12fe	cb a6 	. . 
	ret			;1300	c9 	. 
sub_1301h:
	ld hl,0c0e7h		;1301	21 e7 c0 	! . . 
	res 4,(hl)		;1304	cb a6 	. . 
	ld hl,0c0e2h		;1306	21 e2 c0 	! . . 
	set 4,(hl)		;1309	cb e6 	. . 
	ret			;130b	c9 	. 
sub_130ch:
	ld hl,0c0e7h		;130c	21 e7 c0 	! . . 
	set 4,(hl)		;130f	cb e6 	. . 
	ld hl,0c0e2h		;1311	21 e2 c0 	! . . 
	res 4,(hl)		;1314	cb a6 	. . 
	ret			;1316	c9 	. 
sub_1317h:
	ld hl,0c0deh		;1317	21 de c0 	! . . 
	set 5,(hl)		;131a	cb ee 	. . 
	ret			;131c	c9 	. 
sub_131dh:
	ld hl,0c0deh		;131d	21 de c0 	! . . 
	res 5,(hl)		;1320	cb ae 	. . 
	ret			;1322	c9 	. 
sub_1323h:
	ld hl,0c0dfh		;1323	21 df c0 	! . . 
	set 5,(hl)		;1326	cb ee 	. . 
	ret			;1328	c9 	. 
sub_1329h:
	ld hl,0c0dfh		;1329	21 df c0 	! . . 
	res 5,(hl)		;132c	cb ae 	. . 
	ret			;132e	c9 	. 
sub_132fh:
	ld hl,0c0e0h		;132f	21 e0 c0 	! . . 
	set 5,(hl)		;1332	cb ee 	. . 
	ret			;1334	c9 	. 
sub_1335h:
	ld hl,0c0e0h		;1335	21 e0 c0 	! . . 
	res 5,(hl)		;1338	cb ae 	. . 
	ret			;133a	c9 	. 
sub_133bh:
	ld hl,0c0e7h		;133b	21 e7 c0 	! . . 
	res 5,(hl)		;133e	cb ae 	. . 
	ld hl,0c0e2h		;1340	21 e2 c0 	! . . 
	set 5,(hl)		;1343	cb ee 	. . 
	ret			;1345	c9 	. 
sub_1346h:
	ld hl,0c0e7h		;1346	21 e7 c0 	! . . 
	set 5,(hl)		;1349	cb ee 	. . 
	ld hl,0c0e2h		;134b	21 e2 c0 	! . . 
	res 5,(hl)		;134e	cb ae 	. . 
	ret			;1350	c9 	. 
sub_1351h:
	ld hl,0c0deh		;1351	21 de c0 	! . . 
	set 6,(hl)		;1354	cb f6 	. . 
	ret			;1356	c9 	. 
sub_1357h:
	ld hl,0c0deh		;1357	21 de c0 	! . . 
	res 6,(hl)		;135a	cb b6 	. . 
	ret			;135c	c9 	. 
sub_135dh:
	ld hl,0c0dfh		;135d	21 df c0 	! . . 
	set 6,(hl)		;1360	cb f6 	. . 
	ret			;1362	c9 	. 
sub_1363h:
	ld hl,0c0dfh		;1363	21 df c0 	! . . 
	res 6,(hl)		;1366	cb b6 	. . 
	ret			;1368	c9 	. 
sub_1369h:
	ld hl,0c0e0h		;1369	21 e0 c0 	! . . 
	set 6,(hl)		;136c	cb f6 	. . 
	ret			;136e	c9 	. 
sub_136fh:
	ld hl,0c0e0h		;136f	21 e0 c0 	! . . 
	res 6,(hl)		;1372	cb b6 	. . 
	ret			;1374	c9 	. 
sub_1375h:
	ld hl,0c0e6h		;1375	21 e6 c0 	! . . 
	res 6,(hl)		;1378	cb b6 	. . 
	ld hl,0c0e1h		;137a	21 e1 c0 	! . . 
	set 6,(hl)		;137d	cb f6 	. . 
	ret			;137f	c9 	. 
sub_1380h:
	ld hl,0c0e6h		;1380	21 e6 c0 	! . . 
	set 6,(hl)		;1383	cb f6 	. . 
	ld hl,0c0e1h		;1385	21 e1 c0 	! . . 
	res 6,(hl)		;1388	cb b6 	. . 
	ret			;138a	c9 	. 
sub_138bh:
	ld hl,0c0e7h		;138b	21 e7 c0 	! . . 
	res 6,(hl)		;138e	cb b6 	. . 
	ld hl,0c0e2h		;1390	21 e2 c0 	! . . 
	set 6,(hl)		;1393	cb f6 	. . 
	ret			;1395	c9 	. 
sub_1396h:
	ld hl,0c0e7h		;1396	21 e7 c0 	! . . 
	set 6,(hl)		;1399	cb f6 	. . 
	ld hl,0c0e2h		;139b	21 e2 c0 	! . . 
	res 6,(hl)		;139e	cb b6 	. . 
	ret			;13a0	c9 	. 
sub_13a1h:
	ld hl,0c0dfh		;13a1	21 df c0 	! . . 
	set 7,(hl)		;13a4	cb fe 	. . 
	ret			;13a6	c9 	. 
sub_13a7h:
	ld hl,0c0dfh		;13a7	21 df c0 	! . . 
	res 7,(hl)		;13aa	cb be 	. . 
	ret			;13ac	c9 	. 
sub_13adh:
	ld hl,0c0e0h		;13ad	21 e0 c0 	! . . 
	set 7,(hl)		;13b0	cb fe 	. . 
	ret			;13b2	c9 	. 
sub_13b3h:
	ld hl,0c0e0h		;13b3	21 e0 c0 	! . . 
	res 7,(hl)		;13b6	cb be 	. . 
	ret			;13b8	c9 	. 
sub_13b9h:
	ld hl,0c0e6h		;13b9	21 e6 c0 	! . . 
	res 7,(hl)		;13bc	cb be 	. . 
	ld hl,0c0e1h		;13be	21 e1 c0 	! . . 
	set 7,(hl)		;13c1	cb fe 	. . 
	ret			;13c3	c9 	. 
sub_13c4h:
	ld hl,0c0e6h		;13c4	21 e6 c0 	! . . 
	set 7,(hl)		;13c7	cb fe 	. . 
	ld hl,0c0e1h		;13c9	21 e1 c0 	! . . 
	res 7,(hl)		;13cc	cb be 	. . 
	ret			;13ce	c9 	. 
sub_13cfh:
	di			;13cf	f3 	. 
	ld hl,0c0e7h		;13d0	21 e7 c0 	! . . 
	res 7,(hl)		;13d3	cb be 	. . 
	ld hl,0c0e2h		;13d5	21 e2 c0 	! . . 
	set 7,(hl)		;13d8	cb fe 	. . 
	ei			;13da	fb 	. 
	ret			;13db	c9 	. 
sub_13dch:
	di			;13dc	f3 	. 
	ld hl,0c0e7h		;13dd	21 e7 c0 	! . . 
	set 7,(hl)		;13e0	cb fe 	. . 
	ld hl,0c0e2h		;13e2	21 e2 c0 	! . . 
	res 7,(hl)		;13e5	cb be 	. . 
	ei			;13e7	fb 	. 
	ret			;13e8	c9 	. 
l13e9h:
	di			;13e9	f3 	. 
	jp l13e9h		;13ea	c3 e9 13 	. . . 
	ret			;13ed	c9 	. 
sub_13eeh:
	in a,(004h)		;13ee	db 04 	. . 
	bit 1,a		;13f0	cb 4f 	. O 
	ret nz			;13f2	c0 	. 
	call sub_145bh		;13f3	cd 5b 14 	. [ . 
	call sub_1445h		;13f6	cd 45 14 	. E . 
	call sub_1445h		;13f9	cd 45 14 	. E . 
	call sub_15eeh		;13fc	cd ee 15 	. . . 
	call sub_1445h		;13ff	cd 45 14 	. E . 
	call sub_15f2h		;1402	cd f2 15 	. . . 
	call sub_1445h		;1405	cd 45 14 	. E . 
	call sub_14cch		;1408	cd cc 14 	. . . 
	call sub_1445h		;140b	cd 45 14 	. E . 
	call sub_14d0h		;140e	cd d0 14 	. . . 
	call sub_1445h		;1411	cd 45 14 	. E . 
	call sub_15f6h		;1414	cd f6 15 	. . . 
	call sub_1445h		;1417	cd 45 14 	. E . 
	call sub_15fah		;141a	cd fa 15 	. . . 
	call sub_1445h		;141d	cd 45 14 	. E . 
	call sub_14e8h		;1420	cd e8 14 	. . . 
	call sub_1445h		;1423	cd 45 14 	. E . 
	call sub_024ah		;1426	cd 4a 02 	. J . 
	call sub_1445h		;1429	cd 45 14 	. E . 
	call sub_0266h		;142c	cd 66 02 	. f . 
	call sub_1445h		;142f	cd 45 14 	. E . 
	call sub_148bh		;1432	cd 8b 14 	. . . 
	di			;1435	f3 	. 
	xor a			;1436	af 	. 
	ld (0c0dbh),a		;1437	32 db c0 	2 . . 
	ld (0c032h),a		;143a	32 32 c0 	2 2 . 
	ld hl,l1202h		;143d	21 02 12 	! . . 
	ld (0c0dch),hl		;1440	22 dc c0 	" . . 
	ei			;1443	fb 	. 
	ret			;1444	c9 	. 
sub_1445h:
	ld hl,l00c8h		;1445	21 c8 00 	! . . 
	ld (0c02bh),hl		;1448	22 2b c0 	" + . 
l144bh:
	ld hl,(0c02bh)		;144b	2a 2b c0 	* + . 
	ld de,l0000h		;144e	11 00 00 	. . . 
	xor a			;1451	af 	. 
	sbc hl,de		;1452	ed 52 	. R 
	ret z			;1454	c8 	. 
	call sub_09a1h		;1455	cd a1 09 	. . . 
	jp l144bh		;1458	c3 4b 14 	. K . 
sub_145bh:
	di			;145b	f3 	. 
	ld a,(0c007h)		;145c	3a 07 c0 	: . . 
	or 010h		;145f	f6 10 	. . 
	ld (0c007h),a		;1461	32 07 c0 	2 . . 
	out (087h),a		;1464	d3 87 	. . 
	ei			;1466	fb 	. 
	ld hl,0012ch		;1467	21 2c 01 	! , . 
	ld (0c02bh),hl		;146a	22 2b c0 	" + . 
	ld a,0ffh		;146d	3e ff 	> . 
	ld (0c02dh),a		;146f	32 2d c0 	2 - . 
l1472h:
	ld a,(0c02dh)		;1472	3a 2d c0 	: - . 
	and a			;1475	a7 	. 
	jp nz,l1472h		;1476	c2 72 14 	. r . 
	di			;1479	f3 	. 
	ld hl,0c039h		;147a	21 39 c0 	! 9 . 
	ld b,018h		;147d	06 18 	. . 
l147fh:
	ld (hl),000h		;147f	36 00 	6 . 
	inc hl			;1481	23 	# 
	djnz l147fh		;1482	10 fb 	. . 
	ei			;1484	fb 	. 
	ld a,0ffh		;1485	3e ff 	> . 
	ld (0c038h),a		;1487	32 38 c0 	2 8 . 
	ret			;148a	c9 	. 
sub_148bh:
	di			;148b	f3 	. 
	xor a			;148c	af 	. 
	ld (0c038h),a		;148d	32 38 c0 	2 8 . 
	ld a,(0c007h)		;1490	3a 07 c0 	: . . 
	and 0efh		;1493	e6 ef 	. . 
	ld (0c007h),a		;1495	32 07 c0 	2 . . 
	out (087h),a		;1498	d3 87 	. . 
	ei			;149a	fb 	. 
	ret			;149b	c9 	. 
sub_149ch:
	di			;149c	f3 	. 
	ld a,(0c007h)		;149d	3a 07 c0 	: . . 
	or 020h		;14a0	f6 20 	.   
	ld (0c007h),a		;14a2	32 07 c0 	2 . . 
	out (087h),a		;14a5	d3 87 	. . 
	ei			;14a7	fb 	. 
	ret			;14a8	c9 	. 
sub_14a9h:
	di			;14a9	f3 	. 
	ld a,(0c007h)		;14aa	3a 07 c0 	: . . 
	and 0dfh		;14ad	e6 df 	. . 
	ld (0c007h),a		;14af	32 07 c0 	2 . . 
	out (087h),a		;14b2	d3 87 	. . 
	ei			;14b4	fb 	. 
	ret			;14b5	c9 	. 
	ld a,0ffh		;14b6	3e ff 	> . 
	ld (0c034h),a		;14b8	32 34 c0 	2 4 . 
	ret			;14bb	c9 	. 
	xor a			;14bc	af 	. 
	ld (0c034h),a		;14bd	32 34 c0 	2 4 . 
	ret			;14c0	c9 	. 
	ld a,0ffh		;14c1	3e ff 	> . 
	ld (0c037h),a		;14c3	32 37 c0 	2 7 . 
	ret			;14c6	c9 	. 
	xor a			;14c7	af 	. 
	ld (0c037h),a		;14c8	32 37 c0 	2 7 . 
	ret			;14cb	c9 	. 
sub_14cch:
	call sub_0282h		;14cc	cd 82 02 	. . . 
	ret			;14cf	c9 	. 
sub_14d0h:
	call sub_029eh		;14d0	cd 9e 02 	. . . 
	ret			;14d3	c9 	. 
	ld hl,l01f4h		;14d4	21 f4 01 	! . . 
	ld (0c022h),hl		;14d7	22 22 c0 	" " . 
	call sub_032ah		;14da	cd 2a 03 	. * . 
	ld a,0ffh		;14dd	3e ff 	> . 
	ld (0c035h),a		;14df	32 35 c0 	2 5 . 
	ret			;14e2	c9 	. 
	xor a			;14e3	af 	. 
	ld (0c035h),a		;14e4	32 35 c0 	2 5 . 
	ret			;14e7	c9 	. 
sub_14e8h:
	call sub_0346h		;14e8	cd 46 03 	. F . 
	ret			;14eb	c9 	. 
sub_14ech:
	di			;14ec	f3 	. 
	ld b,005h		;14ed	06 05 	. . 
	ld hl,0c0e3h		;14ef	21 e3 c0 	! . . 
l14f2h:
	ld (hl),0ffh		;14f2	36 ff 	6 . 
	inc hl			;14f4	23 	# 
	djnz l14f2h		;14f5	10 fb 	. . 
	ld b,005h		;14f7	06 05 	. . 
	ld hl,0c0deh		;14f9	21 de c0 	! . . 
l14fch:
	ld (hl),000h		;14fc	36 00 	6 . 
	inc hl			;14fe	23 	# 
	djnz l14fch		;14ff	10 fb 	. . 
	ei			;1501	fb 	. 
	ret			;1502	c9 	. 
	ld a,(0c0deh)		;1503	3a de c0 	: . . 
	and 087h		;1506	e6 87 	. . 
	ld (0c0deh),a		;1508	32 de c0 	2 . . 
	ld a,(0c0dfh)		;150b	3a df c0 	: . . 
	and 0f0h		;150e	e6 f0 	. . 
	ld (0c0dfh),a		;1510	32 df c0 	2 . . 
	ld a,(0c0e1h)		;1513	3a e1 c0 	: . . 
	and 0efh		;1516	e6 ef 	. . 
	ld (0c0e1h),a		;1518	32 e1 c0 	2 . . 
	ret			;151b	c9 	. 
	di			;151c	f3 	. 
	ld a,(0c0dfh)		;151d	3a df c0 	: . . 
	or 0f0h		;1520	f6 f0 	. . 
	ld (0c0dfh),a		;1522	32 df c0 	2 . . 
	ld a,(0c0e0h)		;1525	3a e0 c0 	: . . 
	or 0f1h		;1528	f6 f1 	. . 
	ld (0c0e0h),a		;152a	32 e0 c0 	2 . . 
	ld a,(0c0e2h)		;152d	3a e2 c0 	: . . 
	or 080h		;1530	f6 80 	. . 
	ld (0c0e2h),a		;1532	32 e2 c0 	2 . . 
	ld a,(0c0e7h)		;1535	3a e7 c0 	: . . 
	or 080h		;1538	f6 80 	. . 
	ld (0c0e7h),a		;153a	32 e7 c0 	2 . . 
	ei			;153d	fb 	. 
	ret			;153e	c9 	. 
	di			;153f	f3 	. 
	ld a,(0c0dfh)		;1540	3a df c0 	: . . 
	and 00fh		;1543	e6 0f 	. . 
	ld (0c0dfh),a		;1545	32 df c0 	2 . . 
	ld a,(0c0e0h)		;1548	3a e0 c0 	: . . 
	and 00eh		;154b	e6 0e 	. . 
	ld (0c0e0h),a		;154d	32 e0 c0 	2 . . 
	ld a,(0c0e2h)		;1550	3a e2 c0 	: . . 
	and 07fh		;1553	e6 7f 	.  
	ld (0c0e2h),a		;1555	32 e2 c0 	2 . . 
	ld hl,0c0e7h		;1558	21 e7 c0 	! . . 
	set 7,(hl)		;155b	cb fe 	. . 
	ei			;155d	fb 	. 
	ret			;155e	c9 	. 
	call sub_14a9h		;155f	cd a9 14 	. . . 
	call sub_0b0eh		;1562	cd 0e 0b 	. . . 
	call sub_149ch		;1565	cd 9c 14 	. . . 
	call sub_0b0eh		;1568	cd 0e 0b 	. . . 
	call sub_14a9h		;156b	cd a9 14 	. . . 
	call sub_0b0eh		;156e	cd 0e 0b 	. . . 
	call sub_149ch		;1571	cd 9c 14 	. . . 
	call sub_0b0eh		;1574	cd 0e 0b 	. . . 
	call sub_14a9h		;1577	cd a9 14 	. . . 
	call sub_0b0eh		;157a	cd 0e 0b 	. . . 
	call sub_149ch		;157d	cd 9c 14 	. . . 
	ret			;1580	c9 	. 
	ld a,(0c0c4h)		;1581	3a c4 c0 	: . . 
	ld (0c0dbh),a		;1584	32 db c0 	2 . . 
	jp sub_082ah		;1587	c3 2a 08 	. * . 
	ld a,0ffh		;158a	3e ff 	> . 
	ld (0c051h),a		;158c	32 51 c0 	2 Q . 
	ret			;158f	c9 	. 
	xor a			;1590	af 	. 
	ld (0c051h),a		;1591	32 51 c0 	2 Q . 
	ret			;1594	c9 	. 
	pop hl			;1595	e1 	. 
	ld a,0ffh		;1596	3e ff 	> . 
	ld (0c051h),a		;1598	32 51 c0 	2 Q . 
	ld (0c035h),a		;159b	32 35 c0 	2 5 . 
	call sub_1dc1h		;159e	cd c1 1d 	. . . 
	call sub_14a9h		;15a1	cd a9 14 	. . . 
	call sub_14ech		;15a4	cd ec 14 	. . . 
	jp l15aah		;15a7	c3 aa 15 	. . . 
l15aah:
	ld a,(0c0dah)		;15aa	3a da c0 	: . . 
	and a			;15ad	a7 	. 
	call nz,sub_0966h		;15ae	c4 66 09 	. f . 
	call sub_09a1h		;15b1	cd a1 09 	. . . 
	call sub_0ba0h		;15b4	cd a0 0b 	. . . 
	ld a,(0c0c3h)		;15b7	3a c3 c0 	: . . 
	cp 0ffh		;15ba	fe ff 	. . 
	call nz,sub_0973h		;15bc	c4 73 09 	. s . 
	jp l15aah		;15bf	c3 aa 15 	. . . 
	ld a,(0c051h)		;15c2	3a 51 c0 	: Q . 
	and a			;15c5	a7 	. 
	ret z			;15c6	c8 	. 
	call sub_024ah		;15c7	cd 4a 02 	. J . 
	ret			;15ca	c9 	. 
	ld a,(0c051h)		;15cb	3a 51 c0 	: Q . 
	and a			;15ce	a7 	. 
	ret z			;15cf	c8 	. 
	call sub_0362h		;15d0	cd 62 03 	. b . 
	ret			;15d3	c9 	. 
	call sub_03a6h		;15d4	cd a6 03 	. . . 
	ret			;15d7	c9 	. 
	ld a,(0c051h)		;15d8	3a 51 c0 	: Q . 
	and a			;15db	a7 	. 
	ret z			;15dc	c8 	. 
	call sub_0266h		;15dd	cd 66 02 	. f . 
	ret			;15e0	c9 	. 
	ld a,(0c051h)		;15e1	3a 51 c0 	: Q . 
	and a			;15e4	a7 	. 
	ret z			;15e5	c8 	. 
	call sub_0384h		;15e6	cd 84 03 	. . . 
	ret			;15e9	c9 	. 
	call sub_03b8h		;15ea	cd b8 03 	. . . 
	ret			;15ed	c9 	. 
sub_15eeh:
	call sub_02bah		;15ee	cd ba 02 	. . . 
	ret			;15f1	c9 	. 
sub_15f2h:
	call sub_02d6h		;15f2	cd d6 02 	. . . 
	ret			;15f5	c9 	. 
sub_15f6h:
	call sub_02f2h		;15f6	cd f2 02 	. . . 
	ret			;15f9	c9 	. 
sub_15fah:
	call sub_030eh		;15fa	cd 0e 03 	. . . 
	ret			;15fd	c9 	. 
	ld a,(0c051h)		;15fe	3a 51 c0 	: Q . 
	and a			;1601	a7 	. 
	ret z			;1602	c8 	. 
	call sub_1277h		;1603	cd 77 12 	. w . 
	call sub_171bh		;1606	cd 1b 17 	. . . 
	call sub_1282h		;1609	cd 82 12 	. . . 
	call sub_133bh		;160c	cd 3b 13 	. ; . 
	call sub_171bh		;160f	cd 1b 17 	. . . 
	call sub_1346h		;1612	cd 46 13 	. F . 
	call sub_1301h		;1615	cd 01 13 	. . . 
	call sub_171bh		;1618	cd 1b 17 	. . . 
	call sub_130ch		;161b	cd 0c 13 	. . . 
	call sub_12bbh		;161e	cd bb 12 	. . . 
	call sub_171bh		;1621	cd 1b 17 	. . . 
	call sub_12c6h		;1624	cd c6 12 	. . . 
	call sub_1351h		;1627	cd 51 13 	. Q . 
	call sub_171bh		;162a	cd 1b 17 	. . . 
	call sub_1357h		;162d	cd 57 13 	. W . 
	call sub_1317h		;1630	cd 17 13 	. . . 
	call sub_171bh		;1633	cd 1b 17 	. . . 
	call sub_131dh		;1636	cd 1d 13 	. . . 
	call sub_12d1h		;1639	cd d1 12 	. . . 
	call sub_171bh		;163c	cd 1b 17 	. . . 
	call sub_12d7h		;163f	cd d7 12 	. . . 
	call sub_128dh		;1642	cd 8d 12 	. . . 
	call sub_171bh		;1645	cd 1b 17 	. . . 
	call sub_1293h		;1648	cd 93 12 	. . . 
	call sub_1375h		;164b	cd 75 13 	. u . 
	call sub_171bh		;164e	cd 1b 17 	. . . 
	call sub_1380h		;1651	cd 80 13 	. . . 
	call sub_13b9h		;1654	cd b9 13 	. . . 
	call sub_171bh		;1657	cd 1b 17 	. . . 
	call sub_13c4h		;165a	cd c4 13 	. . . 
	call sub_12f5h		;165d	cd f5 12 	. . . 
	call sub_171bh		;1660	cd 1b 17 	. . . 
	call sub_12fbh		;1663	cd fb 12 	. . . 
	call sub_1299h		;1666	cd 99 12 	. . . 
	call sub_171bh		;1669	cd 1b 17 	. . . 
	call sub_129fh		;166c	cd 9f 12 	. . . 
	call sub_125fh		;166f	cd 5f 12 	. _ . 
	call sub_171bh		;1672	cd 1b 17 	. . . 
	call sub_1265h		;1675	cd 65 12 	. e . 
	call sub_1247h		;1678	cd 47 12 	. G . 
	call sub_171bh		;167b	cd 1b 17 	. . . 
	call sub_124dh		;167e	cd 4d 12 	. M . 
	call sub_1219h		;1681	cd 19 12 	. . . 
	call sub_171bh		;1684	cd 1b 17 	. . . 
	call sub_121fh		;1687	cd 1f 12 	. . . 
	call sub_1231h		;168a	cd 31 12 	. 1 . 
	call sub_171bh		;168d	cd 1b 17 	. . . 
	call sub_123ch		;1690	cd 3c 12 	. < . 
	call sub_1203h		;1693	cd 03 12 	. . . 
	call sub_171bh		;1696	cd 1b 17 	. . . 
	call sub_120eh		;1699	cd 0e 12 	. . . 
	call sub_13cfh		;169c	cd cf 13 	. . . 
	call sub_171bh		;169f	cd 1b 17 	. . . 
	call sub_13dch		;16a2	cd dc 13 	. . . 
	call sub_13a1h		;16a5	cd a1 13 	. . . 
	call sub_171bh		;16a8	cd 1b 17 	. . . 
	call sub_13a7h		;16ab	cd a7 13 	. . . 
	call sub_135dh		;16ae	cd 5d 13 	. ] . 
	call sub_171bh		;16b1	cd 1b 17 	. . . 
	call sub_1363h		;16b4	cd 63 13 	. c . 
	call sub_1323h		;16b7	cd 23 13 	. # . 
	call sub_171bh		;16ba	cd 1b 17 	. . . 
	call sub_1329h		;16bd	cd 29 13 	. ) . 
	call sub_12ddh		;16c0	cd dd 12 	. . . 
	call sub_171bh		;16c3	cd 1b 17 	. . . 
	call sub_12e3h		;16c6	cd e3 12 	. . . 
	call sub_13adh		;16c9	cd ad 13 	. . . 
	call sub_171bh		;16cc	cd 1b 17 	. . . 
	call sub_13b3h		;16cf	cd b3 13 	. . . 
	call sub_1369h		;16d2	cd 69 13 	. i . 
	call sub_171bh		;16d5	cd 1b 17 	. . . 
	call sub_136fh		;16d8	cd 6f 13 	. o . 
	call sub_132fh		;16db	cd 2f 13 	. / . 
	call sub_171bh		;16de	cd 1b 17 	. . . 
	call sub_1335h		;16e1	cd 35 13 	. 5 . 
	call sub_12e9h		;16e4	cd e9 12 	. . . 
	call sub_171bh		;16e7	cd 1b 17 	. . . 
	call sub_12efh		;16ea	cd ef 12 	. . . 
	call sub_1225h		;16ed	cd 25 12 	. % . 
	call sub_171bh		;16f0	cd 1b 17 	. . . 
	call sub_122bh		;16f3	cd 2b 12 	. + . 
	call sub_138bh		;16f6	cd 8b 13 	. . . 
	call sub_171bh		;16f9	cd 1b 17 	. . . 
	call sub_1396h		;16fc	cd 96 13 	. . . 
	call sub_12a5h		;16ff	cd a5 12 	. . . 
	call sub_171bh		;1702	cd 1b 17 	. . . 
	call sub_12b0h		;1705	cd b0 12 	. . . 
	call sub_126bh		;1708	cd 6b 12 	. k . 
	call sub_171bh		;170b	cd 1b 17 	. . . 
	call sub_1271h		;170e	cd 71 12 	. q . 
	call sub_1253h		;1711	cd 53 12 	. S . 
	call sub_171bh		;1714	cd 1b 17 	. . . 
	call sub_1259h		;1717	cd 59 12 	. Y . 
	ret			;171a	c9 	. 
sub_171bh:
	ld a,028h		;171b	3e 28 	> ( 
	ld (0c0dbh),a		;171d	32 db c0 	2 . . 
	call sub_082ah		;1720	cd 2a 08 	. * . 
	ld hl,00190h		;1723	21 90 01 	! . . 
	ld (0c02bh),hl		;1726	22 2b c0 	" + . 
	ld a,0ffh		;1729	3e ff 	> . 
	ld (0c02dh),a		;172b	32 2d c0 	2 - . 
l172eh:
	ld a,(0c02dh)		;172e	3a 2d c0 	: - . 
	and a			;1731	a7 	. 
	jp nz,l172eh		;1732	c2 2e 17 	. . . 
	ret			;1735	c9 	. 
	xor a			;1736	af 	. 
	ld (0c051h),a		;1737	32 51 c0 	2 Q . 
	ld (0c035h),a		;173a	32 35 c0 	2 5 . 
	pop hl			;173d	e1 	. 
	jp l0000h		;173e	c3 00 00 	. . . 
l1741h:
	call sub_1dc9h		;1741	cd c9 1d 	. . . 
l1744h:
	in a,(004h)		;1744	db 04 	. . 
	bit 7,a		;1746	cb 7f 	.  
	jp z,l1744h		;1748	ca 44 17 	. D . 
	di			;174b	f3 	. 
	call sub_1dc1h		;174c	cd c1 1d 	. . . 
	jp l0100h		;174f	c3 00 01 	. . . 
sub_1752h:
	in a,(003h)		;1752	db 03 	. . 
	ld hl,0c0d7h		;1754	21 d7 c0 	! . . 
	cpl			;1757	2f 	/ 
	ld (hl),a			;1758	77 	w 
	cpl			;1759	2f 	/ 
	inc hl			;175a	23 	# 
	or (hl)			;175b	b6 	. 
	ld (0c0c3h),a		;175c	32 c3 c0 	2 . . 
	in a,(004h)		;175f	db 04 	. . 
	ld (0c0c4h),a		;1761	32 c4 c0 	2 . . 
	ld hl,(0c0c5h)		;1764	2a c5 c0 	* . . 
	jp (hl)			;1767	e9 	. 
l1768h:
	ld hl,l1787h		;1768	21 87 17 	! . . 
	ld (0c0c5h),hl		;176b	22 c5 c0 	" . . 
	ld a,001h		;176e	3e 01 	> . 
	out (082h),a		;1770	d3 82 	. . 
	in a,(002h)		;1772	db 02 	. . 
	ld hl,0c0c7h		;1774	21 c7 c0 	! . . 
	cpl			;1777	2f 	/ 
	ld (hl),a			;1778	77 	w 
	cpl			;1779	2f 	/ 
	inc hl			;177a	23 	# 
	or (hl)			;177b	b6 	. 
	ld (0c0bbh),a		;177c	32 bb c0 	2 . . 
	cp 0ffh		;177f	fe ff 	. . 
	jp nz,l1860h		;1781	c2 60 18 	. ` . 
	jp l1980h		;1784	c3 80 19 	. . . 
l1787h:
	ld hl,l17a6h		;1787	21 a6 17 	! . . 
	ld (0c0c5h),hl		;178a	22 c5 c0 	" . . 
	ld a,002h		;178d	3e 02 	> . 
	out (082h),a		;178f	d3 82 	. . 
	in a,(002h)		;1791	db 02 	. . 
	ld hl,0c0c9h		;1793	21 c9 c0 	! . . 
	cpl			;1796	2f 	/ 
	ld (hl),a			;1797	77 	w 
	cpl			;1798	2f 	/ 
	inc hl			;1799	23 	# 
	or (hl)			;179a	b6 	. 
	ld (0c0bch),a		;179b	32 bc c0 	2 . . 
	cp 0ffh		;179e	fe ff 	. . 
	jp nz,l1884h		;17a0	c2 84 18 	. . . 
	jp l1980h		;17a3	c3 80 19 	. . . 
l17a6h:
	ld hl,l17c5h		;17a6	21 c5 17 	! . . 
	ld (0c0c5h),hl		;17a9	22 c5 c0 	" . . 
	ld a,004h		;17ac	3e 04 	> . 
	out (082h),a		;17ae	d3 82 	. . 
	in a,(002h)		;17b0	db 02 	. . 
	ld hl,0c0cbh		;17b2	21 cb c0 	! . . 
	cpl			;17b5	2f 	/ 
	ld (hl),a			;17b6	77 	w 
	cpl			;17b7	2f 	/ 
	inc hl			;17b8	23 	# 
	or (hl)			;17b9	b6 	. 
	ld (0c0bdh),a		;17ba	32 bd c0 	2 . . 
	cp 0ffh		;17bd	fe ff 	. . 
	jp nz,l18a8h		;17bf	c2 a8 18 	. . . 
	jp l1980h		;17c2	c3 80 19 	. . . 
l17c5h:
	ld hl,l17e4h		;17c5	21 e4 17 	! . . 
	ld (0c0c5h),hl		;17c8	22 c5 c0 	" . . 
	ld a,008h		;17cb	3e 08 	> . 
	out (082h),a		;17cd	d3 82 	. . 
	in a,(002h)		;17cf	db 02 	. . 
	ld hl,0c0cdh		;17d1	21 cd c0 	! . . 
	cpl			;17d4	2f 	/ 
	ld (hl),a			;17d5	77 	w 
	cpl			;17d6	2f 	/ 
	inc hl			;17d7	23 	# 
	or (hl)			;17d8	b6 	. 
	ld (0c0beh),a		;17d9	32 be c0 	2 . . 
	cp 0ffh		;17dc	fe ff 	. . 
	jp nz,l18cch		;17de	c2 cc 18 	. . . 
	jp l1980h		;17e1	c3 80 19 	. . . 
l17e4h:
	ld hl,l1803h		;17e4	21 03 18 	! . . 
	ld (0c0c5h),hl		;17e7	22 c5 c0 	" . . 
	ld a,010h		;17ea	3e 10 	> . 
	out (082h),a		;17ec	d3 82 	. . 
	in a,(002h)		;17ee	db 02 	. . 
	ld hl,0c0cfh		;17f0	21 cf c0 	! . . 
	cpl			;17f3	2f 	/ 
	ld (hl),a			;17f4	77 	w 
	cpl			;17f5	2f 	/ 
	inc hl			;17f6	23 	# 
	or (hl)			;17f7	b6 	. 
	ld (0c0bfh),a		;17f8	32 bf c0 	2 . . 
	cp 0ffh		;17fb	fe ff 	. . 
	jp nz,l18f0h		;17fd	c2 f0 18 	. . . 
	jp l1980h		;1800	c3 80 19 	. . . 
l1803h:
	ld hl,l1822h		;1803	21 22 18 	! " . 
	ld (0c0c5h),hl		;1806	22 c5 c0 	" . . 
	ld a,020h		;1809	3e 20 	>   
	out (082h),a		;180b	d3 82 	. . 
	in a,(002h)		;180d	db 02 	. . 
	ld hl,0c0d1h		;180f	21 d1 c0 	! . . 
	cpl			;1812	2f 	/ 
	ld (hl),a			;1813	77 	w 
	cpl			;1814	2f 	/ 
	inc hl			;1815	23 	# 
	or (hl)			;1816	b6 	. 
	ld (0c0c0h),a		;1817	32 c0 c0 	2 . . 
	cp 0ffh		;181a	fe ff 	. . 
	jp nz,l1914h		;181c	c2 14 19 	. . . 
	jp l1980h		;181f	c3 80 19 	. . . 
l1822h:
	ld hl,l1841h		;1822	21 41 18 	! A . 
	ld (0c0c5h),hl		;1825	22 c5 c0 	" . . 
	ld a,040h		;1828	3e 40 	> @ 
	out (082h),a		;182a	d3 82 	. . 
	in a,(002h)		;182c	db 02 	. . 
	ld hl,0c0d3h		;182e	21 d3 c0 	! . . 
	cpl			;1831	2f 	/ 
	ld (hl),a			;1832	77 	w 
	cpl			;1833	2f 	/ 
	inc hl			;1834	23 	# 
	or (hl)			;1835	b6 	. 
	ld (0c0c1h),a		;1836	32 c1 c0 	2 . . 
	cp 0ffh		;1839	fe ff 	. . 
	jp nz,l1938h		;183b	c2 38 19 	. 8 . 
	jp l1980h		;183e	c3 80 19 	. . . 
l1841h:
	ld hl,l1768h		;1841	21 68 17 	! h . 
	ld (0c0c5h),hl		;1844	22 c5 c0 	" . . 
	ld a,080h		;1847	3e 80 	> . 
	out (082h),a		;1849	d3 82 	. . 
	in a,(002h)		;184b	db 02 	. . 
	ld hl,0c0d5h		;184d	21 d5 c0 	! . . 
	cpl			;1850	2f 	/ 
	ld (hl),a			;1851	77 	w 
	cpl			;1852	2f 	/ 
	inc hl			;1853	23 	# 
	or (hl)			;1854	b6 	. 
	ld (0c0c2h),a		;1855	32 c2 c0 	2 . . 
	cp 0ffh		;1858	fe ff 	. . 
	jp nz,l195ch		;185a	c2 5c 19 	. \ . 
	jp l1980h		;185d	c3 80 19 	. . . 
l1860h:
	bit 0,a		;1860	cb 47 	. G 
	jp z,l1a9ah		;1862	ca 9a 1a 	. . . 
	bit 1,a		;1865	cb 4f 	. O 
	jp z,l1aa2h		;1867	ca a2 1a 	. . . 
	bit 2,a		;186a	cb 57 	. W 
	jp z,l1aaah		;186c	ca aa 1a 	. . . 
	bit 3,a		;186f	cb 5f 	. _ 
	jp z,l1ab2h		;1871	ca b2 1a 	. . . 
	ld hl,l096eh		;1874	21 6e 09 	! n . 
	ld (0c0dch),hl		;1877	22 dc c0 	" . . 
	xor a			;187a	af 	. 
	ld (0c0dbh),a		;187b	32 db c0 	2 . . 
	ld (0c0dah),a		;187e	32 da c0 	2 . . 
	jp l1980h		;1881	c3 80 19 	. . . 
l1884h:
	bit 0,a		;1884	cb 47 	. G 
	jp z,l1abah		;1886	ca ba 1a 	. . . 
	bit 1,a		;1889	cb 4f 	. O 
	jp z,l1ac2h		;188b	ca c2 1a 	. . . 
	bit 2,a		;188e	cb 57 	. W 
	jp z,l1acah		;1890	ca ca 1a 	. . . 
	bit 3,a		;1893	cb 5f 	. _ 
	jp z,l1ad2h		;1895	ca d2 1a 	. . . 
	ld hl,l096eh		;1898	21 6e 09 	! n . 
	ld (0c0dch),hl		;189b	22 dc c0 	" . . 
	xor a			;189e	af 	. 
	ld (0c0dbh),a		;189f	32 db c0 	2 . . 
	ld (0c0dah),a		;18a2	32 da c0 	2 . . 
	jp l1980h		;18a5	c3 80 19 	. . . 
l18a8h:
	bit 0,a		;18a8	cb 47 	. G 
	jp z,l1adah		;18aa	ca da 1a 	. . . 
	bit 1,a		;18ad	cb 4f 	. O 
	jp z,l1ae2h		;18af	ca e2 1a 	. . . 
	bit 2,a		;18b2	cb 57 	. W 
	jp z,l1aeah		;18b4	ca ea 1a 	. . . 
	bit 3,a		;18b7	cb 5f 	. _ 
	jp z,l1af2h		;18b9	ca f2 1a 	. . . 
	ld hl,l096eh		;18bc	21 6e 09 	! n . 
	ld (0c0dch),hl		;18bf	22 dc c0 	" . . 
	xor a			;18c2	af 	. 
	ld (0c0dbh),a		;18c3	32 db c0 	2 . . 
	ld (0c0dah),a		;18c6	32 da c0 	2 . . 
	jp l1980h		;18c9	c3 80 19 	. . . 
l18cch:
	bit 0,a		;18cc	cb 47 	. G 
	jp z,l1afah		;18ce	ca fa 1a 	. . . 
	bit 1,a		;18d1	cb 4f 	. O 
	jp z,l1b02h		;18d3	ca 02 1b 	. . . 
	bit 2,a		;18d6	cb 57 	. W 
	jp z,l1b0ah		;18d8	ca 0a 1b 	. . . 
	bit 3,a		;18db	cb 5f 	. _ 
	jp z,l1b12h		;18dd	ca 12 1b 	. . . 
	ld hl,l096eh		;18e0	21 6e 09 	! n . 
	ld (0c0dch),hl		;18e3	22 dc c0 	" . . 
	xor a			;18e6	af 	. 
	ld (0c0dbh),a		;18e7	32 db c0 	2 . . 
	ld (0c0dah),a		;18ea	32 da c0 	2 . . 
	jp l1980h		;18ed	c3 80 19 	. . . 
l18f0h:
	bit 0,a		;18f0	cb 47 	. G 
	jp z,l1b1ah		;18f2	ca 1a 1b 	. . . 
	bit 1,a		;18f5	cb 4f 	. O 
	jp z,l1b22h		;18f7	ca 22 1b 	. " . 
	bit 2,a		;18fa	cb 57 	. W 
	jp z,l1b2ah		;18fc	ca 2a 1b 	. * . 
	bit 3,a		;18ff	cb 5f 	. _ 
	jp z,l1b32h		;1901	ca 32 1b 	. 2 . 
	ld hl,l096eh		;1904	21 6e 09 	! n . 
	ld (0c0dch),hl		;1907	22 dc c0 	" . . 
	xor a			;190a	af 	. 
	ld (0c0dbh),a		;190b	32 db c0 	2 . . 
	ld (0c0dah),a		;190e	32 da c0 	2 . . 
	jp l1980h		;1911	c3 80 19 	. . . 
l1914h:
	bit 0,a		;1914	cb 47 	. G 
	jp z,l1b3ah		;1916	ca 3a 1b 	. : . 
	bit 1,a		;1919	cb 4f 	. O 
	jp z,l1b42h		;191b	ca 42 1b 	. B . 
	bit 2,a		;191e	cb 57 	. W 
	jp z,l1b4ah		;1920	ca 4a 1b 	. J . 
	bit 3,a		;1923	cb 5f 	. _ 
	jp z,l1b52h		;1925	ca 52 1b 	. R . 
	ld hl,l096eh		;1928	21 6e 09 	! n . 
	ld (0c0dch),hl		;192b	22 dc c0 	" . . 
	xor a			;192e	af 	. 
	ld (0c0dbh),a		;192f	32 db c0 	2 . . 
	ld (0c0dah),a		;1932	32 da c0 	2 . . 
	jp l1980h		;1935	c3 80 19 	. . . 
l1938h:
	bit 0,a		;1938	cb 47 	. G 
	jp z,l1b5ah		;193a	ca 5a 1b 	. Z . 
	bit 1,a		;193d	cb 4f 	. O 
	jp z,l1b62h		;193f	ca 62 1b 	. b . 
	bit 2,a		;1942	cb 57 	. W 
	jp z,l1b6ah		;1944	ca 6a 1b 	. j . 
	bit 3,a		;1947	cb 5f 	. _ 
	jp z,l1b72h		;1949	ca 72 1b 	. r . 
	ld hl,l096eh		;194c	21 6e 09 	! n . 
	ld (0c0dch),hl		;194f	22 dc c0 	" . . 
	xor a			;1952	af 	. 
	ld (0c0dbh),a		;1953	32 db c0 	2 . . 
	ld (0c0dah),a		;1956	32 da c0 	2 . . 
	jp l1980h		;1959	c3 80 19 	. . . 
l195ch:
	bit 0,a		;195c	cb 47 	. G 
	jp z,l1b7ah		;195e	ca 7a 1b 	. z . 
	bit 1,a		;1961	cb 4f 	. O 
	jp z,l1b82h		;1963	ca 82 1b 	. . . 
	bit 2,a		;1966	cb 57 	. W 
	jp z,l1b8ah		;1968	ca 8a 1b 	. . . 
	bit 3,a		;196b	cb 5f 	. _ 
	jp z,l1b92h		;196d	ca 92 1b 	. . . 
	ld hl,l096eh		;1970	21 6e 09 	! n . 
	ld (0c0dch),hl		;1973	22 dc c0 	" . . 
	xor a			;1976	af 	. 
	ld (0c0dbh),a		;1977	32 db c0 	2 . . 
	ld (0c0dah),a		;197a	32 da c0 	2 . . 
	jp l1980h		;197d	c3 80 19 	. . . 
l1980h:
	ld a,(0c0d9h)		;1980	3a d9 c0 	: . . 
	and a			;1983	a7 	. 
	jp z,l198ch		;1984	ca 8c 19 	. . . 
	dec a			;1987	3d 	= 
	ld (0c0d9h),a		;1988	32 d9 c0 	2 . . 
	ret			;198b	c9 	. 
l198ch:
	ld a,(0c0c7h)		;198c	3a c7 c0 	: . . 
	ld hl,0c0c8h		;198f	21 c8 c0 	! . . 
	and (hl)			;1992	a6 	. 
	ld (hl),a			;1993	77 	w 
	ld a,(0c0c9h)		;1994	3a c9 c0 	: . . 
	ld hl,0c0cah		;1997	21 ca c0 	! . . 
	and (hl)			;199a	a6 	. 
	ld (hl),a			;199b	77 	w 
	ld a,(0c0cbh)		;199c	3a cb c0 	: . . 
	ld hl,0c0cch		;199f	21 cc c0 	! . . 
	and (hl)			;19a2	a6 	. 
	ld (hl),a			;19a3	77 	w 
	ld a,(0c0cdh)		;19a4	3a cd c0 	: . . 
	ld hl,0c0ceh		;19a7	21 ce c0 	! . . 
	and (hl)			;19aa	a6 	. 
	ld (hl),a			;19ab	77 	w 
	ld a,(0c0cfh)		;19ac	3a cf c0 	: . . 
	ld hl,0c0d0h		;19af	21 d0 c0 	! . . 
	and (hl)			;19b2	a6 	. 
	ld (hl),a			;19b3	77 	w 
	ld a,(0c0d1h)		;19b4	3a d1 c0 	: . . 
	ld hl,0c0d2h		;19b7	21 d2 c0 	! . . 
	and (hl)			;19ba	a6 	. 
	ld (hl),a			;19bb	77 	w 
	ld a,(0c0d3h)		;19bc	3a d3 c0 	: . . 
	ld hl,0c0d4h		;19bf	21 d4 c0 	! . . 
	and (hl)			;19c2	a6 	. 
	ld (hl),a			;19c3	77 	w 
	ld a,(0c0d5h)		;19c4	3a d5 c0 	: . . 
	ld hl,0c0d6h		;19c7	21 d6 c0 	! . . 
	and (hl)			;19ca	a6 	. 
	ld (hl),a			;19cb	77 	w 
	ld a,(0c0d7h)		;19cc	3a d7 c0 	: . . 
	ld hl,0c0d8h		;19cf	21 d8 c0 	! . . 
	and (hl)			;19d2	a6 	. 
	ld (hl),a			;19d3	77 	w 
	ret			;19d4	c9 	. 
l19d5h:
	rst 38h			;19d5	ff 	. 
l19d6h:
	inc d			;19d6	14 	. 
l19d7h:
	inc d			;19d7	14 	. 
l19d8h:
	inc d			;19d8	14 	. 
l19d9h:
	inc d			;19d9	14 	. 
l19dah:
	inc d			;19da	14 	. 
l19dbh:
	inc d			;19db	14 	. 
l19dch:
	inc d			;19dc	14 	. 
l19ddh:
	ld d,b			;19dd	50 	P 
l19deh:
	ld d,b			;19de	50 	P 
	ld hl,0c0c8h		;19df	21 c8 c0 	! . . 
	or (hl)			;19e2	b6 	. 
	ld (hl),a			;19e3	77 	w 
	ld hl,0c0bbh		;19e4	21 bb c0 	! . . 
	or (hl)			;19e7	b6 	. 
	ld (hl),a			;19e8	77 	w 
	ld a,(l19d5h)		;19e9	3a d5 19 	: . . 
	ld (0c0d9h),a		;19ec	32 d9 c0 	2 . . 
	ret			;19ef	c9 	. 
sub_19f0h:
	ld hl,0c0c8h		;19f0	21 c8 c0 	! . . 
	or (hl)			;19f3	b6 	. 
	ld (hl),a			;19f4	77 	w 
	ld hl,0c0bbh		;19f5	21 bb c0 	! . . 
	or (hl)			;19f8	b6 	. 
	ld (hl),a			;19f9	77 	w 
	ld a,(l19d6h)		;19fa	3a d6 19 	: . . 
	ld (0c0d9h),a		;19fd	32 d9 c0 	2 . . 
	ret			;1a00	c9 	. 
sub_1a01h:
	ld hl,0c0cah		;1a01	21 ca c0 	! . . 
	or (hl)			;1a04	b6 	. 
	ld (hl),a			;1a05	77 	w 
	ld hl,0c0bch		;1a06	21 bc c0 	! . . 
	or (hl)			;1a09	b6 	. 
	ld (hl),a			;1a0a	77 	w 
	ld a,(l19d7h)		;1a0b	3a d7 19 	: . . 
	ld (0c0d9h),a		;1a0e	32 d9 c0 	2 . . 
	ret			;1a11	c9 	. 
sub_1a12h:
	ld hl,0c0cch		;1a12	21 cc c0 	! . . 
	or (hl)			;1a15	b6 	. 
	ld (hl),a			;1a16	77 	w 
	ld hl,0c0bdh		;1a17	21 bd c0 	! . . 
	or (hl)			;1a1a	b6 	. 
	ld (hl),a			;1a1b	77 	w 
	ld a,(l19d8h)		;1a1c	3a d8 19 	: . . 
	ld (0c0d9h),a		;1a1f	32 d9 c0 	2 . . 
	ret			;1a22	c9 	. 
sub_1a23h:
	ld hl,0c0ceh		;1a23	21 ce c0 	! . . 
	or (hl)			;1a26	b6 	. 
	ld (hl),a			;1a27	77 	w 
	ld hl,0c0beh		;1a28	21 be c0 	! . . 
	or (hl)			;1a2b	b6 	. 
	ld (hl),a			;1a2c	77 	w 
	ld a,(l19d9h)		;1a2d	3a d9 19 	: . . 
	ld (0c0d9h),a		;1a30	32 d9 c0 	2 . . 
	ret			;1a33	c9 	. 
sub_1a34h:
	ld hl,0c0d0h		;1a34	21 d0 c0 	! . . 
	or (hl)			;1a37	b6 	. 
	ld (hl),a			;1a38	77 	w 
	ld hl,0c0bfh		;1a39	21 bf c0 	! . . 
	or (hl)			;1a3c	b6 	. 
	ld (hl),a			;1a3d	77 	w 
	ld a,(l19dah)		;1a3e	3a da 19 	: . . 
	ld (0c0d9h),a		;1a41	32 d9 c0 	2 . . 
	ret			;1a44	c9 	. 
sub_1a45h:
	ld hl,0c0d2h		;1a45	21 d2 c0 	! . . 
	or (hl)			;1a48	b6 	. 
	ld (hl),a			;1a49	77 	w 
	ld hl,0c0c0h		;1a4a	21 c0 c0 	! . . 
	or (hl)			;1a4d	b6 	. 
	ld (hl),a			;1a4e	77 	w 
	ld a,(l19dbh)		;1a4f	3a db 19 	: . . 
	ld (0c0d9h),a		;1a52	32 d9 c0 	2 . . 
	ret			;1a55	c9 	. 
sub_1a56h:
	ld hl,0c0d4h		;1a56	21 d4 c0 	! . . 
	or (hl)			;1a59	b6 	. 
	ld (hl),a			;1a5a	77 	w 
	ld hl,0c0c1h		;1a5b	21 c1 c0 	! . . 
	or (hl)			;1a5e	b6 	. 
	ld (hl),a			;1a5f	77 	w 
	ld a,(l19dch)		;1a60	3a dc 19 	: . . 
	ld (0c0d9h),a		;1a63	32 d9 c0 	2 . . 
	ret			;1a66	c9 	. 
sub_1a67h:
	ld hl,0c0d6h		;1a67	21 d6 c0 	! . . 
	or (hl)			;1a6a	b6 	. 
	ld (hl),a			;1a6b	77 	w 
	ld hl,0c0c2h		;1a6c	21 c2 c0 	! . . 
	or (hl)			;1a6f	b6 	. 
	ld (hl),a			;1a70	77 	w 
	ld a,(l19ddh)		;1a71	3a dd 19 	: . . 
	ld (0c0d9h),a		;1a74	32 d9 c0 	2 . . 
	ret			;1a77	c9 	. 
sub_1a78h:
	ld hl,0c0d8h		;1a78	21 d8 c0 	! . . 
	or (hl)			;1a7b	b6 	. 
	ld (hl),a			;1a7c	77 	w 
	ld hl,0c0c3h		;1a7d	21 c3 c0 	! . . 
	or (hl)			;1a80	b6 	. 
	ld (hl),a			;1a81	77 	w 
	ld a,(l19deh)		;1a82	3a de 19 	: . . 
	ld (0c0d9h),a		;1a85	32 d9 c0 	2 . . 
	ret			;1a88	c9 	. 
	ld hl,0c0d8h		;1a89	21 d8 c0 	! . . 
	or (hl)			;1a8c	b6 	. 
	ld (hl),a			;1a8d	77 	w 
	ld hl,0c0c3h		;1a8e	21 c3 c0 	! . . 
	or (hl)			;1a91	b6 	. 
	ld (hl),a			;1a92	77 	w 
	ld a,(l19d7h)		;1a93	3a d7 19 	: . . 
	ld (0c0d9h),a		;1a96	32 d9 c0 	2 . . 
	ret			;1a99	c9 	. 
l1a9ah:
	ld a,015h		;1a9a	3e 15 	> . 
	ld hl,l0b20h		;1a9c	21 20 0b 	!   . 
	jp l1b9ah		;1a9f	c3 9a 1b 	. . . 
l1aa2h:
	ld a,014h		;1aa2	3e 14 	> . 
	ld hl,l0b06h		;1aa4	21 06 0b 	! . . 
	jp l1b9ah		;1aa7	c3 9a 1b 	. . . 
l1aaah:
	ld a,008h		;1aaa	3e 08 	> . 
	ld hl,l0a76h		;1aac	21 76 0a 	! v . 
	jp l1b9ah		;1aaf	c3 9a 1b 	. . . 
l1ab2h:
	ld a,01ah		;1ab2	3e 1a 	> . 
	ld hl,l0b48h		;1ab4	21 48 0b 	! H . 
	jp l1b9ah		;1ab7	c3 9a 1b 	. . . 
l1abah:
	ld a,016h		;1aba	3e 16 	> . 
	ld hl,l0b28h		;1abc	21 28 0b 	! ( . 
	jp l1b9ah		;1abf	c3 9a 1b 	. . . 
l1ac2h:
	ld a,011h		;1ac2	3e 11 	> . 
	ld hl,l0aeeh		;1ac4	21 ee 0a 	! . . 
	jp l1b9ah		;1ac7	c3 9a 1b 	. . . 
l1acah:
	ld a,00bh		;1aca	3e 0b 	> . 
	ld hl,l0aaeh		;1acc	21 ae 0a 	! . . 
	jp l1b9ah		;1acf	c3 9a 1b 	. . . 
l1ad2h:
	ld a,024h		;1ad2	3e 24 	> $ 
	ld hl,l0b98h		;1ad4	21 98 0b 	! . . 
	jp l1b9ah		;1ad7	c3 9a 1b 	. . . 
l1adah:
	ld a,00ah		;1ada	3e 0a 	> . 
	ld hl,l0a9eh		;1adc	21 9e 0a 	! . . 
	jp l1b9ah		;1adf	c3 9a 1b 	. . . 
l1ae2h:
	ld a,012h		;1ae2	3e 12 	> . 
	ld hl,l0af6h		;1ae4	21 f6 0a 	! . . 
	jp l1b9ah		;1ae7	c3 9a 1b 	. . . 
l1aeah:
	ld a,01eh		;1aea	3e 1e 	> . 
	ld hl,l0b68h		;1aec	21 68 0b 	! h . 
	jp l1b9ah		;1aef	c3 9a 1b 	. . . 
l1af2h:
	ld a,020h		;1af2	3e 20 	>   
	ld hl,l0b78h		;1af4	21 78 0b 	! x . 
	jp l1b9ah		;1af7	c3 9a 1b 	. . . 
l1afah:
	ld a,023h		;1afa	3e 23 	> # 
	ld hl,l0b90h		;1afc	21 90 0b 	! . . 
	jp l1b9ah		;1aff	c3 9a 1b 	. . . 
l1b02h:
	ld a,013h		;1b02	3e 13 	> . 
	ld hl,l0afeh		;1b04	21 fe 0a 	! . . 
	jp l1b9ah		;1b07	c3 9a 1b 	. . . 
l1b0ah:
	ld a,01fh		;1b0a	3e 1f 	> . 
	ld hl,l0b70h		;1b0c	21 70 0b 	! p . 
	jp l1b9ah		;1b0f	c3 9a 1b 	. . . 
l1b12h:
	ld a,009h		;1b12	3e 09 	> . 
	ld hl,l0a8eh		;1b14	21 8e 0a 	! . . 
	jp l1b9ah		;1b17	c3 9a 1b 	. . . 
l1b1ah:
	ld a,021h		;1b1a	3e 21 	> ! 
	ld hl,l0b80h		;1b1c	21 80 0b 	! . . 
	jp l1b9ah		;1b1f	c3 9a 1b 	. . . 
l1b22h:
	ld a,01bh		;1b22	3e 1b 	> . 
	ld hl,l0b50h		;1b24	21 50 0b 	! P . 
	jp l1b9ah		;1b27	c3 9a 1b 	. . . 
l1b2ah:
	ld a,00dh		;1b2a	3e 0d 	> . 
	ld hl,l0aceh		;1b2c	21 ce 0a 	! . . 
	jp l1b9ah		;1b2f	c3 9a 1b 	. . . 
l1b32h:
	ld a,022h		;1b32	3e 22 	> " 
	ld hl,l0b88h		;1b34	21 88 0b 	! . . 
	jp l1b9ah		;1b37	c3 9a 1b 	. . . 
l1b3ah:
	ld a,000h		;1b3a	3e 00 	> . 
	ld hl,l096eh		;1b3c	21 6e 09 	! n . 
	jp l1b9ah		;1b3f	c3 9a 1b 	. . . 
l1b42h:
	ld a,01ch		;1b42	3e 1c 	> . 
	ld hl,l0b58h		;1b44	21 58 0b 	! X . 
	jp l1b9ah		;1b47	c3 9a 1b 	. . . 
l1b4ah:
	ld a,00eh		;1b4a	3e 0e 	> . 
	ld hl,l0ad6h		;1b4c	21 d6 0a 	! . . 
	jp l1b9ah		;1b4f	c3 9a 1b 	. . . 
l1b52h:
	ld a,017h		;1b52	3e 17 	> . 
	ld hl,l0b30h		;1b54	21 30 0b 	! 0 . 
	jp l1b9ah		;1b57	c3 9a 1b 	. . . 
l1b5ah:
	ld a,03ch		;1b5a	3e 3c 	> < 
	ld hl,l096eh		;1b5c	21 6e 09 	! n . 
	jp l1b9ah		;1b5f	c3 9a 1b 	. . . 
l1b62h:
	ld a,01dh		;1b62	3e 1d 	> . 
	ld hl,l0b60h		;1b64	21 60 0b 	! ` . 
	jp l1b9ah		;1b67	c3 9a 1b 	. . . 
l1b6ah:
	ld a,00fh		;1b6a	3e 0f 	> . 
	ld hl,l0adeh		;1b6c	21 de 0a 	! . . 
	jp l1b9ah		;1b6f	c3 9a 1b 	. . . 
l1b72h:
	ld a,018h		;1b72	3e 18 	> . 
	ld hl,l0b38h		;1b74	21 38 0b 	! 8 . 
	jp l1b9ah		;1b77	c3 9a 1b 	. . . 
l1b7ah:
	ld a,046h		;1b7a	3e 46 	> F 
	ld hl,l096eh		;1b7c	21 6e 09 	! n . 
	jp l1b9ah		;1b7f	c3 9a 1b 	. . . 
l1b82h:
	ld a,00ch		;1b82	3e 0c 	> . 
	ld hl,l0abeh		;1b84	21 be 0a 	! . . 
	jp l1b9ah		;1b87	c3 9a 1b 	. . . 
l1b8ah:
	ld a,010h		;1b8a	3e 10 	> . 
	ld hl,l0ae6h		;1b8c	21 e6 0a 	! . . 
	jp l1b9ah		;1b8f	c3 9a 1b 	. . . 
l1b92h:
	ld a,019h		;1b92	3e 19 	> . 
	ld hl,l0b40h		;1b94	21 40 0b 	! @ . 
	jp l1b9ah		;1b97	c3 9a 1b 	. . . 
l1b9ah:
	ld (0c0dbh),a		;1b9a	32 db c0 	2 . . 
	ld (0c0dch),hl		;1b9d	22 dc c0 	" . . 
	ld a,0ffh		;1ba0	3e ff 	> . 
	ld (0c0dah),a		;1ba2	32 da c0 	2 . . 
	jp l1980h		;1ba5	c3 80 19 	. . . 
sub_1ba8h:
	ld a,(0c0f9h)		;1ba8	3a f9 c0 	: . . 
	add a,001h		;1bab	c6 01 	. . 
	ld (0c0f9h),a		;1bad	32 f9 c0 	2 . . 
	call sub_1c0dh		;1bb0	cd 0d 1c 	. . . 
	call sub_1c4eh		;1bb3	cd 4e 1c 	. N . 
	call sub_1dd7h		;1bb6	cd d7 1d 	. . . 
	ld hl,(0c0efh)		;1bb9	2a ef c0 	* . . 
	jp (hl)			;1bbc	e9 	. 
l1bbdh:
	ld hl,l1bcdh		;1bbd	21 cd 1b 	! . . 
	ld (0c0efh),hl		;1bc0	22 ef c0 	" . . 
	ld a,(0c0e9h)		;1bc3	3a e9 c0 	: . . 
	out (084h),a		;1bc6	d3 84 	. . 
	ld a,001h		;1bc8	3e 01 	> . 
	out (083h),a		;1bca	d3 83 	. . 
	ret			;1bcc	c9 	. 
l1bcdh:
	ld hl,l1bddh		;1bcd	21 dd 1b 	! . . 
	ld (0c0efh),hl		;1bd0	22 ef c0 	" . . 
	ld a,(0c0eah)		;1bd3	3a ea c0 	: . . 
	out (084h),a		;1bd6	d3 84 	. . 
	ld a,002h		;1bd8	3e 02 	> . 
	out (083h),a		;1bda	d3 83 	. . 
	ret			;1bdc	c9 	. 
l1bddh:
	ld hl,l1bedh		;1bdd	21 ed 1b 	! . . 
	ld (0c0efh),hl		;1be0	22 ef c0 	" . . 
	ld a,(0c0ebh)		;1be3	3a eb c0 	: . . 
	out (084h),a		;1be6	d3 84 	. . 
	ld a,004h		;1be8	3e 04 	> . 
	out (083h),a		;1bea	d3 83 	. . 
	ret			;1bec	c9 	. 
l1bedh:
	ld hl,l1bfdh		;1bed	21 fd 1b 	! . . 
	ld (0c0efh),hl		;1bf0	22 ef c0 	" . . 
	ld a,(0c0ech)		;1bf3	3a ec c0 	: . . 
	out (084h),a		;1bf6	d3 84 	. . 
	ld a,008h		;1bf8	3e 08 	> . 
	out (083h),a		;1bfa	d3 83 	. . 
	ret			;1bfc	c9 	. 
l1bfdh:
	ld hl,l1bbdh		;1bfd	21 bd 1b 	! . . 
	ld (0c0efh),hl		;1c00	22 ef c0 	" . . 
	ld a,(0c0edh)		;1c03	3a ed c0 	: . . 
	out (084h),a		;1c06	d3 84 	. . 
	ld a,010h		;1c08	3e 10 	> . 
	out (083h),a		;1c0a	d3 83 	. . 
	ret			;1c0c	c9 	. 
sub_1c0dh:
	ld a,(0c0fah)		;1c0d	3a fa c0 	: . . 
	and a			;1c10	a7 	. 
	ret nz			;1c11	c0 	. 
	ld a,(0c0f1h)		;1c12	3a f1 c0 	: . . 
	and a			;1c15	a7 	. 
	ret z			;1c16	c8 	. 
	ld a,(0c0f4h)		;1c17	3a f4 c0 	: . . 
	dec a			;1c1a	3d 	= 
	ld (0c0f4h),a		;1c1b	32 f4 c0 	2 . . 
	ret nz			;1c1e	c0 	. 
	ld a,(0c0f2h)		;1c1f	3a f2 c0 	: . . 
	ld (0c0f4h),a		;1c22	32 f4 c0 	2 . . 
	ld a,(0c0f3h)		;1c25	3a f3 c0 	: . . 
	dec a			;1c28	3d 	= 
	ld (0c0f3h),a		;1c29	32 f3 c0 	2 . . 
	jp z,l1c3eh		;1c2c	ca 3e 1c 	. > . 
	ld hl,(0c0f5h)		;1c2f	2a f5 c0 	* . . 
	ld de,0c0e9h		;1c32	11 e9 c0 	. . . 
	ld bc,l0005h		;1c35	01 05 00 	. . . 
	ldir		;1c38	ed b0 	. . 
	ld (0c0f5h),hl		;1c3a	22 f5 c0 	" . . 
	ret			;1c3d	c9 	. 
l1c3eh:
	xor a			;1c3e	af 	. 
	ld (0c0f1h),a		;1c3f	32 f1 c0 	2 . . 
	ld hl,0c0deh		;1c42	21 de c0 	! . . 
	ld de,0c0e9h		;1c45	11 e9 c0 	. . . 
	ld bc,l0005h		;1c48	01 05 00 	. . . 
	ldir		;1c4b	ed b0 	. . 
	ret			;1c4d	c9 	. 
sub_1c4eh:
	ld a,(0c0f1h)		;1c4e	3a f1 c0 	: . . 
	and a			;1c51	a7 	. 
	ret nz			;1c52	c0 	. 
	ld a,(0c0fah)		;1c53	3a fa c0 	: . . 
	and a			;1c56	a7 	. 
	ret nz			;1c57	c0 	. 
	ld a,(0c0f7h)		;1c58	3a f7 c0 	: . . 
	dec a			;1c5b	3d 	= 
	ld (0c0f7h),a		;1c5c	32 f7 c0 	2 . . 
	ret nz			;1c5f	c0 	. 
	ld a,04bh		;1c60	3e 4b 	> K 
	ld (0c0f7h),a		;1c62	32 f7 c0 	2 . . 
	ld a,(0c0f8h)		;1c65	3a f8 c0 	: . . 
	and a			;1c68	a7 	. 
	jp z,l1c98h		;1c69	ca 98 1c 	. . . 
	xor a			;1c6c	af 	. 
	ld (0c0f8h),a		;1c6d	32 f8 c0 	2 . . 
	ld hl,0c0e3h		;1c70	21 e3 c0 	! . . 
	ld de,0c0e9h		;1c73	11 e9 c0 	. . . 
	ld a,(0c0deh)		;1c76	3a de c0 	: . . 
	and (hl)			;1c79	a6 	. 
	ld (de),a			;1c7a	12 	. 
	inc hl			;1c7b	23 	# 
	inc de			;1c7c	13 	. 
	ld a,(0c0dfh)		;1c7d	3a df c0 	: . . 
	and (hl)			;1c80	a6 	. 
	ld (de),a			;1c81	12 	. 
	inc hl			;1c82	23 	# 
	inc de			;1c83	13 	. 
	ld a,(0c0e0h)		;1c84	3a e0 c0 	: . . 
	and (hl)			;1c87	a6 	. 
	ld (de),a			;1c88	12 	. 
	inc hl			;1c89	23 	# 
	inc de			;1c8a	13 	. 
	ld a,(0c0e1h)		;1c8b	3a e1 c0 	: . . 
	and (hl)			;1c8e	a6 	. 
	ld (de),a			;1c8f	12 	. 
	inc hl			;1c90	23 	# 
	inc de			;1c91	13 	. 
	ld a,(0c0e2h)		;1c92	3a e2 c0 	: . . 
	and (hl)			;1c95	a6 	. 
	ld (de),a			;1c96	12 	. 
	ret			;1c97	c9 	. 
l1c98h:
	ld a,0ffh		;1c98	3e ff 	> . 
	ld (0c0f8h),a		;1c9a	32 f8 c0 	2 . . 
	ld hl,0c0deh		;1c9d	21 de c0 	! . . 
	ld de,0c0e9h		;1ca0	11 e9 c0 	. . . 
	ld bc,l0005h		;1ca3	01 05 00 	. . . 
	ldir		;1ca6	ed b0 	. . 
	ret			;1ca8	c9 	. 
	ld a,(0c0fah)		;1ca9	3a fa c0 	: . . 
	and a			;1cac	a7 	. 
	ret nz			;1cad	c0 	. 
	ld hl,l1dfch		;1cae	21 fc 1d 	! . . 
	ld (0c0f5h),hl		;1cb1	22 f5 c0 	" . . 
	ld a,021h		;1cb4	3e 21 	> ! 
	ld (0c0f3h),a		;1cb6	32 f3 c0 	2 . . 
	ld a,019h		;1cb9	3e 19 	> . 
	ld (0c0f2h),a		;1cbb	32 f2 c0 	2 . . 
	ld (0c0f1h),a		;1cbe	32 f1 c0 	2 . . 
	ld (0c0f4h),a		;1cc1	32 f4 c0 	2 . . 
	ret			;1cc4	c9 	. 
	ld a,(0c0fah)		;1cc5	3a fa c0 	: . . 
	and a			;1cc8	a7 	. 
	ret nz			;1cc9	c0 	. 
	ld hl,l1ee7h		;1cca	21 e7 1e 	! . . 
	ld (0c0f5h),hl		;1ccd	22 f5 c0 	" . . 
	ld a,021h		;1cd0	3e 21 	> ! 
	ld (0c0f3h),a		;1cd2	32 f3 c0 	2 . . 
	ld a,019h		;1cd5	3e 19 	> . 
	ld (0c0f2h),a		;1cd7	32 f2 c0 	2 . . 
	ld (0c0f1h),a		;1cda	32 f1 c0 	2 . . 
	ld (0c0f4h),a		;1cdd	32 f4 c0 	2 . . 
	ret			;1ce0	c9 	. 
	ld a,(0c0fah)		;1ce1	3a fa c0 	: . . 
	and a			;1ce4	a7 	. 
	ret nz			;1ce5	c0 	. 
	ld hl,l1f8ch		;1ce6	21 8c 1f 	! . . 
	ld (0c0f5h),hl		;1ce9	22 f5 c0 	" . . 
	ld a,00ah		;1cec	3e 0a 	> . 
	ld (0c0f3h),a		;1cee	32 f3 c0 	2 . . 
	ld a,03ch		;1cf1	3e 3c 	> < 
	ld (0c0f2h),a		;1cf3	32 f2 c0 	2 . . 
	ld (0c0f1h),a		;1cf6	32 f1 c0 	2 . . 
	ld (0c0f4h),a		;1cf9	32 f4 c0 	2 . . 
	ret			;1cfc	c9 	. 
	ld a,(0c0fah)		;1cfd	3a fa c0 	: . . 
	and a			;1d00	a7 	. 
	ret nz			;1d01	c0 	. 
	ld hl,l1fbfh		;1d02	21 bf 1f 	! . . 
	ld (0c0f5h),hl		;1d05	22 f5 c0 	" . . 
	ld a,020h		;1d08	3e 20 	>   
	ld (0c0f3h),a		;1d0a	32 f3 c0 	2 . . 
	ld a,019h		;1d0d	3e 19 	> . 
	ld (0c0f2h),a		;1d0f	32 f2 c0 	2 . . 
	ld (0c0f1h),a		;1d12	32 f1 c0 	2 . . 
	ld (0c0f4h),a		;1d15	32 f4 c0 	2 . . 
	ret			;1d18	c9 	. 
	ld a,(0c0fah)		;1d19	3a fa c0 	: . . 
	and a			;1d1c	a7 	. 
	ret nz			;1d1d	c0 	. 
	ld hl,l205fh		;1d1e	21 5f 20 	! _   
	ld (0c0f5h),hl		;1d21	22 f5 c0 	" . . 
	ld a,013h		;1d24	3e 13 	> . 
	ld (0c0f3h),a		;1d26	32 f3 c0 	2 . . 
	ld a,03ch		;1d29	3e 3c 	> < 
	ld (0c0f2h),a		;1d2b	32 f2 c0 	2 . . 
	ld (0c0f1h),a		;1d2e	32 f1 c0 	2 . . 
	ld (0c0f4h),a		;1d31	32 f4 c0 	2 . . 
	ret			;1d34	c9 	. 
	ld a,(0c0fah)		;1d35	3a fa c0 	: . . 
	and a			;1d38	a7 	. 
	ret nz			;1d39	c0 	. 
	ld hl,l20bfh		;1d3a	21 bf 20 	! .   
	ld (0c0f5h),hl		;1d3d	22 f5 c0 	" . . 
	ld a,013h		;1d40	3e 13 	> . 
	ld (0c0f3h),a		;1d42	32 f3 c0 	2 . . 
	ld a,03ch		;1d45	3e 3c 	> < 
	ld (0c0f2h),a		;1d47	32 f2 c0 	2 . . 
	ld (0c0f1h),a		;1d4a	32 f1 c0 	2 . . 
	ld (0c0f4h),a		;1d4d	32 f4 c0 	2 . . 
	ret			;1d50	c9 	. 
	ld a,(0c0fah)		;1d51	3a fa c0 	: . . 
	and a			;1d54	a7 	. 
	ret nz			;1d55	c0 	. 
	ld hl,l211fh		;1d56	21 1f 21 	! . ! 
	ld (0c0f5h),hl		;1d59	22 f5 c0 	" . . 
	ld a,014h		;1d5c	3e 14 	> . 
	ld (0c0f3h),a		;1d5e	32 f3 c0 	2 . . 
	ld a,03ch		;1d61	3e 3c 	> < 
	ld (0c0f2h),a		;1d63	32 f2 c0 	2 . . 
	ld (0c0f1h),a		;1d66	32 f1 c0 	2 . . 
	ld (0c0f4h),a		;1d69	32 f4 c0 	2 . . 
	ret			;1d6c	c9 	. 
	ld a,(0c0fah)		;1d6d	3a fa c0 	: . . 
	and a			;1d70	a7 	. 
	ret nz			;1d71	c0 	. 
	ld hl,l2184h		;1d72	21 84 21 	! . ! 
	ld (0c0f5h),hl		;1d75	22 f5 c0 	" . . 
	ld a,013h		;1d78	3e 13 	> . 
	ld (0c0f3h),a		;1d7a	32 f3 c0 	2 . . 
	ld a,03ch		;1d7d	3e 3c 	> < 
	ld (0c0f2h),a		;1d7f	32 f2 c0 	2 . . 
	ld (0c0f1h),a		;1d82	32 f1 c0 	2 . . 
	ld (0c0f4h),a		;1d85	32 f4 c0 	2 . . 
	ret			;1d88	c9 	. 
	ld a,(0c0fah)		;1d89	3a fa c0 	: . . 
	and a			;1d8c	a7 	. 
	ret nz			;1d8d	c0 	. 
	ld hl,l21e4h		;1d8e	21 e4 21 	! . ! 
	ld (0c0f5h),hl		;1d91	22 f5 c0 	" . . 
	ld a,009h		;1d94	3e 09 	> . 
	ld (0c0f3h),a		;1d96	32 f3 c0 	2 . . 
	ld a,03ch		;1d99	3e 3c 	> < 
	ld (0c0f2h),a		;1d9b	32 f2 c0 	2 . . 
	ld (0c0f1h),a		;1d9e	32 f1 c0 	2 . . 
	ld (0c0f4h),a		;1da1	32 f4 c0 	2 . . 
	ret			;1da4	c9 	. 
	ld a,(0c0fah)		;1da5	3a fa c0 	: . . 
	and a			;1da8	a7 	. 
	ret nz			;1da9	c0 	. 
	ld hl,l2212h		;1daa	21 12 22 	! . " 
	ld (0c0f5h),hl		;1dad	22 f5 c0 	" . . 
	ld a,008h		;1db0	3e 08 	> . 
	ld (0c0f3h),a		;1db2	32 f3 c0 	2 . . 
	ld a,03ch		;1db5	3e 3c 	> < 
	ld (0c0f2h),a		;1db7	32 f2 c0 	2 . . 
	ld (0c0f1h),a		;1dba	32 f1 c0 	2 . . 
	ld (0c0f4h),a		;1dbd	32 f4 c0 	2 . . 
	ret			;1dc0	c9 	. 
sub_1dc1h:
	xor a			;1dc1	af 	. 
	ld (0c0f1h),a		;1dc2	32 f1 c0 	2 . . 
	ld (0c0fah),a		;1dc5	32 fa c0 	2 . . 
	ret			;1dc8	c9 	. 
sub_1dc9h:
	ld a,0ffh		;1dc9	3e ff 	> . 
	ld (0c0fah),a		;1dcb	32 fa c0 	2 . . 
	ld a,067h		;1dce	3e 67 	> g 
	ld (0c0f2h),a		;1dd0	32 f2 c0 	2 . . 
	ld (0c0f4h),a		;1dd3	32 f4 c0 	2 . . 
	ret			;1dd6	c9 	. 
sub_1dd7h:
	ld a,(0c0fah)		;1dd7	3a fa c0 	: . . 
	and a			;1dda	a7 	. 
	ret z			;1ddb	c8 	. 
	ld a,(0c0f4h)		;1ddc	3a f4 c0 	: . . 
	dec a			;1ddf	3d 	= 
	ld (0c0f4h),a		;1de0	32 f4 c0 	2 . . 
	ret nz			;1de3	c0 	. 
	ld a,(0c0f2h)		;1de4	3a f2 c0 	: . . 
	ld (0c0f4h),a		;1de7	32 f4 c0 	2 . . 
	ld hl,0c0edh		;1dea	21 ed c0 	! . . 
	ld de,0c0eeh		;1ded	11 ee c0 	. . . 
	ld bc,l0005h		;1df0	01 05 00 	. . . 
	lddr		;1df3	ed b8 	. . 
	ld a,(0c0f9h)		;1df5	3a f9 c0 	: . . 
	ld (0c0e9h),a		;1df8	32 e9 c0 	2 . . 
	ret			;1dfb	c9 	. 
l1dfch:
	nop			;1dfc	00 	. 
	nop			;1dfd	00 	. 
	ld (bc),a			;1dfe	02 	. 
	nop			;1dff	00 	. 
	nop			;1e00	00 	. 
	nop			;1e01	00 	. 
	nop			;1e02	00 	. 
	ld b,000h		;1e03	06 00 	. . 
	nop			;1e05	00 	. 
	nop			;1e06	00 	. 
	nop			;1e07	00 	. 
	rlca			;1e08	07 	. 
	nop			;1e09	00 	. 
	nop			;1e0a	00 	. 
	nop			;1e0b	00 	. 
l1e0ch:
	nop			;1e0c	00 	. 
	rra			;1e0d	1f 	. 
	nop			;1e0e	00 	. 
	nop			;1e0f	00 	. 
	nop			;1e10	00 	. 
	nop			;1e11	00 	. 
	ccf			;1e12	3f 	? 
	nop			;1e13	00 	. 
	nop			;1e14	00 	. 
	nop			;1e15	00 	. 
	nop			;1e16	00 	. 
	ld a,a			;1e17	7f 	 
	nop			;1e18	00 	. 
	nop			;1e19	00 	. 
	nop			;1e1a	00 	. 
	nop			;1e1b	00 	. 
	rst 38h			;1e1c	ff 	. 
	nop			;1e1d	00 	. 
	ld b,b			;1e1e	40 	@ 
	nop			;1e1f	00 	. 
	djnz $+1		;1e20	10 ff 	. . 
	nop			;1e22	00 	. 
	ld b,b			;1e23	40 	@ 
	nop			;1e24	00 	. 
	ld sp,l00ffh		;1e25	31 ff 00 	1 . . 
	ld b,b			;1e28	40 	@ 
	nop			;1e29	00 	. 
	ld (hl),e			;1e2a	73 	s 
	rst 38h			;1e2b	ff 	. 
	nop			;1e2c	00 	. 
	ld b,b			;1e2d	40 	@ 
	nop			;1e2e	00 	. 
	di			;1e2f	f3 	. 
	rst 38h			;1e30	ff 	. 
	nop			;1e31	00 	. 
	ld b,b			;1e32	40 	@ 
	nop			;1e33	00 	. 
	rst 30h			;1e34	f7 	. 
	rst 38h			;1e35	ff 	. 
	nop			;1e36	00 	. 
	ld b,b			;1e37	40 	@ 
	ld bc,0fff7h		;1e38	01 f7 ff 	. . . 
	nop			;1e3b	00 	. 
	ret nz			;1e3c	c0 	. 
	ld bc,0ffffh		;1e3d	01 ff ff 	. . . 
	nop			;1e40	00 	. 
	ret nz			;1e41	c0 	. 
	ld bc,0ffffh		;1e42	01 ff ff 	. . . 
	nop			;1e45	00 	. 
	ret nz			;1e46	c0 	. 
	ld bc,0ffffh		;1e47	01 ff ff 	. . . 
	djnz l1e0ch		;1e4a	10 c0 	. . 
	ld bc,0ffffh		;1e4c	01 ff ff 	. . . 
	sub b			;1e4f	90 	. 
	ret nz			;1e50	c0 	. 
	ld bc,0ffffh		;1e51	01 ff ff 	. . . 
	ret nc			;1e54	d0 	. 
	ret nz			;1e55	c0 	. 
	add hl,bc			;1e56	09 	. 
	rst 38h			;1e57	ff 	. 
	rst 38h			;1e58	ff 	. 
	ret nc			;1e59	d0 	. 
	ret nz			;1e5a	c0 	. 
	add hl,de			;1e5b	19 	. 
	rst 38h			;1e5c	ff 	. 
	rst 38h			;1e5d	ff 	. 
	ret nc			;1e5e	d0 	. 
	ret nz			;1e5f	c0 	. 
	add hl,sp			;1e60	39 	9 
	rst 38h			;1e61	ff 	. 
	rst 38h			;1e62	ff 	. 
	ret nc			;1e63	d0 	. 
	ret nz			;1e64	c0 	. 
	ld a,c			;1e65	79 	y 
	rst 38h			;1e66	ff 	. 
	rst 38h			;1e67	ff 	. 
	ret nc			;1e68	d0 	. 
	ret nz			;1e69	c0 	. 
	ld a,c			;1e6a	79 	y 
	rst 38h			;1e6b	ff 	. 
	rst 38h			;1e6c	ff 	. 
	ret c			;1e6d	d8 	. 
	ret nz			;1e6e	c0 	. 
	ld a,c			;1e6f	79 	y 
	rst 38h			;1e70	ff 	. 
	rst 38h			;1e71	ff 	. 
	ret c			;1e72	d8 	. 
	ret p			;1e73	f0 	. 
	rst 38h			;1e74	ff 	. 
	rst 38h			;1e75	ff 	. 
	defb 0fdh,0ffh,0ffh	;illegal sequence		;1e76	fd ff ff 	. . . 
	rst 38h			;1e79	ff 	. 
	rst 38h			;1e7a	ff 	. 
	ld sp,hl			;1e7b	f9 	. 
	rst 38h			;1e7c	ff 	. 
	rst 38h			;1e7d	ff 	. 
	rst 38h			;1e7e	ff 	. 
	rst 38h			;1e7f	ff 	. 
	ret m			;1e80	f8 	. 
	rst 38h			;1e81	ff 	. 
	rst 38h			;1e82	ff 	. 
	rst 38h			;1e83	ff 	. 
	rst 38h			;1e84	ff 	. 
	ret po			;1e85	e0 	. 
	rst 38h			;1e86	ff 	. 
	rst 38h			;1e87	ff 	. 
	rst 38h			;1e88	ff 	. 
	rst 38h			;1e89	ff 	. 
	ret nz			;1e8a	c0 	. 
	rst 38h			;1e8b	ff 	. 
	rst 38h			;1e8c	ff 	. 
	rst 38h			;1e8d	ff 	. 
	rst 38h			;1e8e	ff 	. 
	add a,b			;1e8f	80 	. 
	rst 38h			;1e90	ff 	. 
	rst 38h			;1e91	ff 	. 
	rst 38h			;1e92	ff 	. 
	rst 38h			;1e93	ff 	. 
	nop			;1e94	00 	. 
	rst 38h			;1e95	ff 	. 
	cp a			;1e96	bf 	. 
	rst 38h			;1e97	ff 	. 
	rst 28h			;1e98	ef 	. 
	nop			;1e99	00 	. 
	rst 38h			;1e9a	ff 	. 
	cp a			;1e9b	bf 	. 
	rst 38h			;1e9c	ff 	. 
	adc a,000h		;1e9d	ce 00 	. . 
	rst 38h			;1e9f	ff 	. 
	cp a			;1ea0	bf 	. 
	rst 38h			;1ea1	ff 	. 
	adc a,h			;1ea2	8c 	. 
	nop			;1ea3	00 	. 
	rst 38h			;1ea4	ff 	. 
	cp a			;1ea5	bf 	. 
	rst 38h			;1ea6	ff 	. 
	ex af,af'			;1ea7	08 	. 
	nop			;1ea8	00 	. 
	rst 38h			;1ea9	ff 	. 
	cp a			;1eaa	bf 	. 
	cp 008h		;1eab	fe 08 	. . 
	nop			;1ead	00 	. 
	rst 38h			;1eae	ff 	. 
	ccf			;1eaf	3f 	? 
	cp 000h		;1eb0	fe 00 	. . 
	nop			;1eb2	00 	. 
	rst 38h			;1eb3	ff 	. 
	ccf			;1eb4	3f 	? 
	cp 000h		;1eb5	fe 00 	. . 
	nop			;1eb7	00 	. 
	rst 38h			;1eb8	ff 	. 
	ccf			;1eb9	3f 	? 
	cp 000h		;1eba	fe 00 	. . 
	nop			;1ebc	00 	. 
	rst 28h			;1ebd	ef 	. 
	ccf			;1ebe	3f 	? 
	cp 000h		;1ebf	fe 00 	. . 
	nop			;1ec1	00 	. 
	ld l,a			;1ec2	6f 	o 
	ccf			;1ec3	3f 	? 
	cp 000h		;1ec4	fe 00 	. . 
	nop			;1ec6	00 	. 
	cpl			;1ec7	2f 	/ 
	ccf			;1ec8	3f 	? 
	or 000h		;1ec9	f6 00 	. . 
	nop			;1ecb	00 	. 
	cpl			;1ecc	2f 	/ 
	ccf			;1ecd	3f 	? 
	and 000h		;1ece	e6 00 	. . 
	nop			;1ed0	00 	. 
	cpl			;1ed1	2f 	/ 
	ccf			;1ed2	3f 	? 
	add a,000h		;1ed3	c6 00 	. . 
	nop			;1ed5	00 	. 
	cpl			;1ed6	2f 	/ 
	ccf			;1ed7	3f 	? 
	add a,(hl)			;1ed8	86 	. 
	nop			;1ed9	00 	. 
	nop			;1eda	00 	. 
	cpl			;1edb	2f 	/ 
	ccf			;1edc	3f 	? 
	add a,(hl)			;1edd	86 	. 
	nop			;1ede	00 	. 
	nop			;1edf	00 	. 
	daa			;1ee0	27 	' 
	ccf			;1ee1	3f 	? 
	nop			;1ee2	00 	. 
	nop			;1ee3	00 	. 
	nop			;1ee4	00 	. 
	nop			;1ee5	00 	. 
	nop			;1ee6	00 	. 
l1ee7h:
	nop			;1ee7	00 	. 
	inc c			;1ee8	0c 	. 
	nop			;1ee9	00 	. 
	djnz l1eech		;1eea	10 00 	. . 
l1eech:
	nop			;1eec	00 	. 
	ld c,000h		;1eed	0e 00 	. . 
	djnz l1ef1h		;1eef	10 00 	. . 
l1ef1h:
	nop			;1ef1	00 	. 
	ld c,000h		;1ef2	0e 00 	. . 
	jr l1ef6h		;1ef4	18 00 	. . 
l1ef6h:
	nop			;1ef6	00 	. 
	ld c,000h		;1ef7	0e 00 	. . 
	jr l1f1bh		;1ef9	18 20 	.   
	nop			;1efb	00 	. 
	ld c,000h		;1efc	0e 00 	. . 
	ld e,b			;1efe	58 	X 
	jr nc,l1f01h		;1eff	30 00 	0 . 
l1f01h:
	ld c,000h		;1f01	0e 00 	. . 
	ret c			;1f03	d8 	. 
	jr nc,l1f06h		;1f04	30 00 	0 . 
l1f06h:
	ld c,00eh		;1f06	0e 0e 	. . 
	ret c			;1f08	d8 	. 
	jr nc,l1f0bh		;1f09	30 00 	0 . 
l1f0bh:
	ld e,0ceh		;1f0b	1e ce 	. . 
	ret c			;1f0d	d8 	. 
	jr nc,l1f10h		;1f0e	30 00 	0 . 
l1f10h:
	ld a,0dfh		;1f10	3e df 	> . 
	ret c			;1f12	d8 	. 
	jr nc,$+3		;1f13	30 01 	0 . 
	ld a,0dfh		;1f15	3e df 	> . 
	ret c			;1f17	d8 	. 
	jr nc,l1f1bh		;1f18	30 01 	0 . 
	ld a,(hl)			;1f1a	7e 	~ 
l1f1bh:
	rst 18h			;1f1b	df 	. 
	ret c			;1f1c	d8 	. 
	jr nc,$+3		;1f1d	30 01 	0 . 
	cp 0dfh		;1f1f	fe df 	. . 
	ret c			;1f21	d8 	. 
	or b			;1f22	b0 	. 
	add hl,bc			;1f23	09 	. 
	cp 0dfh		;1f24	fe df 	. . 
	ret c			;1f26	d8 	. 
	or b			;1f27	b0 	. 
	add hl,de			;1f28	19 	. 
	cp 0dfh		;1f29	fe df 	. . 
	ret c			;1f2b	d8 	. 
	or b			;1f2c	b0 	. 
	ld a,c			;1f2d	79 	y 
	cp 0dfh		;1f2e	fe df 	. . 
	ret c			;1f30	d8 	. 
	or b			;1f31	b0 	. 
	ld a,c			;1f32	79 	y 
	cp 0dfh		;1f33	fe df 	. . 
	ret c			;1f35	d8 	. 
	ret p			;1f36	f0 	. 
	rst 38h			;1f37	ff 	. 
	di			;1f38	f3 	. 
	rst 38h			;1f39	ff 	. 
	rst 28h			;1f3a	ef 	. 
	rst 38h			;1f3b	ff 	. 
	rst 38h			;1f3c	ff 	. 
	pop af			;1f3d	f1 	. 
	rst 38h			;1f3e	ff 	. 
	rst 28h			;1f3f	ef 	. 
	rst 38h			;1f40	ff 	. 
	rst 38h			;1f41	ff 	. 
	ret p			;1f42	f0 	. 
	rst 38h			;1f43	ff 	. 
	rst 28h			;1f44	ef 	. 
	rst 38h			;1f45	ff 	. 
	rst 38h			;1f46	ff 	. 
	ret p			;1f47	f0 	. 
	rst 38h			;1f48	ff 	. 
	rst 20h			;1f49	e7 	. 
	rst 38h			;1f4a	ff 	. 
	rst 38h			;1f4b	ff 	. 
	ret p			;1f4c	f0 	. 
	rst 38h			;1f4d	ff 	. 
	rst 20h			;1f4e	e7 	. 
	rst 18h			;1f4f	df 	. 
	rst 38h			;1f50	ff 	. 
	ret p			;1f51	f0 	. 
	rst 38h			;1f52	ff 	. 
	and a			;1f53	a7 	. 
	rst 8			;1f54	cf 	. 
	rst 38h			;1f55	ff 	. 
	ret p			;1f56	f0 	. 
	rst 38h			;1f57	ff 	. 
	daa			;1f58	27 	' 
	rst 8			;1f59	cf 	. 
	rst 38h			;1f5a	ff 	. 
	ret p			;1f5b	f0 	. 
	pop af			;1f5c	f1 	. 
	daa			;1f5d	27 	' 
	rst 8			;1f5e	cf 	. 
	rst 38h			;1f5f	ff 	. 
	ret po			;1f60	e0 	. 
	ld sp,0cf27h		;1f61	31 27 cf 	1 ' . 
	rst 38h			;1f64	ff 	. 
	ret nz			;1f65	c0 	. 
	nop			;1f66	00 	. 
	daa			;1f67	27 	' 
	rst 8			;1f68	cf 	. 
	cp 0c0h		;1f69	fe c0 	. . 
	nop			;1f6b	00 	. 
	daa			;1f6c	27 	' 
	rst 8			;1f6d	cf 	. 
	cp 080h		;1f6e	fe 80 	. . 
	nop			;1f70	00 	. 
	daa			;1f71	27 	' 
	rst 8			;1f72	cf 	. 
	cp 000h		;1f73	fe 00 	. . 
	nop			;1f75	00 	. 
	daa			;1f76	27 	' 
	ld c,a			;1f77	4f 	O 
	or 000h		;1f78	f6 00 	. . 
	nop			;1f7a	00 	. 
	daa			;1f7b	27 	' 
	ld c,a			;1f7c	4f 	O 
	and 000h		;1f7d	e6 00 	. . 
	nop			;1f7f	00 	. 
	daa			;1f80	27 	' 
	ld c,a			;1f81	4f 	O 
	add a,(hl)			;1f82	86 	. 
	nop			;1f83	00 	. 
	nop			;1f84	00 	. 
	daa			;1f85	27 	' 
	ld c,a			;1f86	4f 	O 
	nop			;1f87	00 	. 
	nop			;1f88	00 	. 
	nop			;1f89	00 	. 
	nop			;1f8a	00 	. 
	nop			;1f8b	00 	. 
l1f8ch:
	ld a,c			;1f8c	79 	y 
	rst 38h			;1f8d	ff 	. 
	rst 38h			;1f8e	ff 	. 
	ret c			;1f8f	d8 	. 
	ret p			;1f90	f0 	. 
	nop			;1f91	00 	. 
	nop			;1f92	00 	. 
	nop			;1f93	00 	. 
	nop			;1f94	00 	. 
	nop			;1f95	00 	. 
	ld a,c			;1f96	79 	y 
	rst 38h			;1f97	ff 	. 
	rst 38h			;1f98	ff 	. 
	ret c			;1f99	d8 	. 
	ret p			;1f9a	f0 	. 
	nop			;1f9b	00 	. 
	nop			;1f9c	00 	. 
	nop			;1f9d	00 	. 
	nop			;1f9e	00 	. 
	nop			;1f9f	00 	. 
	ld a,c			;1fa0	79 	y 
	rst 38h			;1fa1	ff 	. 
	rst 38h			;1fa2	ff 	. 
	ret c			;1fa3	d8 	. 
	ret p			;1fa4	f0 	. 
	nop			;1fa5	00 	. 
	nop			;1fa6	00 	. 
	nop			;1fa7	00 	. 
	nop			;1fa8	00 	. 
	nop			;1fa9	00 	. 
	ld a,c			;1faa	79 	y 
	rst 38h			;1fab	ff 	. 
	rst 38h			;1fac	ff 	. 
	ret c			;1fad	d8 	. 
	ret p			;1fae	f0 	. 
	nop			;1faf	00 	. 
	nop			;1fb0	00 	. 
	nop			;1fb1	00 	. 
	nop			;1fb2	00 	. 
	nop			;1fb3	00 	. 
	ld a,c			;1fb4	79 	y 
	rst 38h			;1fb5	ff 	. 
	rst 38h			;1fb6	ff 	. 
	ret c			;1fb7	d8 	. 
	ret p			;1fb8	f0 	. 
	nop			;1fb9	00 	. 
	nop			;1fba	00 	. 
	nop			;1fbb	00 	. 
	nop			;1fbc	00 	. 
	nop			;1fbd	00 	. 
	rst 38h			;1fbe	ff 	. 
l1fbfh:
	nop			;1fbf	00 	. 
	nop			;1fc0	00 	. 
	nop			;1fc1	00 	. 
	nop			;1fc2	00 	. 
	ld b,b			;1fc3	40 	@ 
	ld h,b			;1fc4	60 	` 
	nop			;1fc5	00 	. 
	nop			;1fc6	00 	. 
	nop			;1fc7	00 	. 
	ld b,b			;1fc8	40 	@ 
	ld a,b			;1fc9	78 	x 
	nop			;1fca	00 	. 
	nop			;1fcb	00 	. 
	nop			;1fcc	00 	. 
	ld b,b			;1fcd	40 	@ 
	ld a,b			;1fce	78 	x 
	add a,b			;1fcf	80 	. 
	nop			;1fd0	00 	. 
	nop			;1fd1	00 	. 
	ret nz			;1fd2	c0 	. 
	ld a,c			;1fd3	79 	y 
	ret nz			;1fd4	c0 	. 
	nop			;1fd5	00 	. 
	nop			;1fd6	00 	. 
	ret nz			;1fd7	c0 	. 
	ld a,c			;1fd8	79 	y 
	ret po			;1fd9	e0 	. 
	nop			;1fda	00 	. 
	nop			;1fdb	00 	. 
	ret nz			;1fdc	c0 	. 
	ld a,c			;1fdd	79 	y 
	ret po			;1fde	e0 	. 
	ld sp,0c000h		;1fdf	31 00 c0 	1 . . 
	ld a,c			;1fe2	79 	y 
	ret p			;1fe3	f0 	. 
	pop af			;1fe4	f1 	. 
	nop			;1fe5	00 	. 
	ret nz			;1fe6	c0 	. 
	ld a,c			;1fe7	79 	y 
	ret p			;1fe8	f0 	. 
	rst 38h			;1fe9	ff 	. 
	nop			;1fea	00 	. 
	ret nz			;1feb	c0 	. 
	ld a,c			;1fec	79 	y 
	ret p			;1fed	f0 	. 
	rst 38h			;1fee	ff 	. 
	add a,b			;1fef	80 	. 
	ret nc			;1ff0	d0 	. 
	ld a,c			;1ff1	79 	y 
	ret p			;1ff2	f0 	. 
	rst 38h			;1ff3	ff 	. 
	ret nz			;1ff4	c0 	. 
	ret nc			;1ff5	d0 	. 
	ld a,c			;1ff6	79 	y 
	ret p			;1ff7	f0 	. 
	rst 38h			;1ff8	ff 	. 
	ret nz			;1ff9	c0 	. 
	ret p			;1ffa	f0 	. 
	ld a,c			;1ffb	79 	y 
	ret p			;1ffc	f0 	. 
	rst 38h			;1ffd	ff 	. 
	ret z			;1ffe	c8 	. 
	ret p			;1fff	f0 	. 
	ld a,c			;2000	79 	y 
	pop af			;2001	f1 	. 
	rst 38h			;2002	ff 	. 
	ret z			;2003	c8 	. 
	ret p			;2004	f0 	. 
	ld a,c			;2005	79 	y 
	push af			;2006	f5 	. 
	rst 38h			;2007	ff 	. 
	ret z			;2008	c8 	. 
	ret p			;2009	f0 	. 
	ld a,c			;200a	79 	y 
	defb 0fdh,0ffh,0d8h	;illegal sequence		;200b	fd ff d8 	. . . 
	ret p			;200e	f0 	. 
	rst 38h			;200f	ff 	. 
	rst 38h			;2010	ff 	. 
	rst 38h			;2011	ff 	. 
	rst 38h			;2012	ff 	. 
	cp a			;2013	bf 	. 
	sbc a,a			;2014	9f 	. 
	rst 38h			;2015	ff 	. 
	rst 38h			;2016	ff 	. 
	rst 38h			;2017	ff 	. 
	cp a			;2018	bf 	. 
	add a,a			;2019	87 	. 
	rst 38h			;201a	ff 	. 
	rst 38h			;201b	ff 	. 
	rst 38h			;201c	ff 	. 
	cp a			;201d	bf 	. 
	add a,a			;201e	87 	. 
	ld a,a			;201f	7f 	 
	rst 38h			;2020	ff 	. 
	rst 38h			;2021	ff 	. 
	ccf			;2022	3f 	? 
	add a,(hl)			;2023	86 	. 
	ccf			;2024	3f 	? 
	rst 38h			;2025	ff 	. 
	rst 38h			;2026	ff 	. 
	ccf			;2027	3f 	? 
	add a,(hl)			;2028	86 	. 
	rra			;2029	1f 	. 
	rst 38h			;202a	ff 	. 
	rst 38h			;202b	ff 	. 
	ccf			;202c	3f 	? 
	add a,(hl)			;202d	86 	. 
	rra			;202e	1f 	. 
	adc a,0ffh		;202f	ce ff 	. . 
	ccf			;2031	3f 	? 
	add a,(hl)			;2032	86 	. 
	rrca			;2033	0f 	. 
	ld c,0ffh		;2034	0e ff 	. . 
	ccf			;2036	3f 	? 
	add a,(hl)			;2037	86 	. 
	rrca			;2038	0f 	. 
	nop			;2039	00 	. 
	rst 38h			;203a	ff 	. 
	ccf			;203b	3f 	? 
	add a,(hl)			;203c	86 	. 
	rrca			;203d	0f 	. 
	nop			;203e	00 	. 
	ld a,a			;203f	7f 	 
	cpl			;2040	2f 	/ 
	add a,(hl)			;2041	86 	. 
	rrca			;2042	0f 	. 
	nop			;2043	00 	. 
	ccf			;2044	3f 	? 
	cpl			;2045	2f 	/ 
	add a,(hl)			;2046	86 	. 
	rrca			;2047	0f 	. 
	nop			;2048	00 	. 
	ccf			;2049	3f 	? 
	rrca			;204a	0f 	. 
	add a,(hl)			;204b	86 	. 
	rrca			;204c	0f 	. 
	nop			;204d	00 	. 
	scf			;204e	37 	7 
	rrca			;204f	0f 	. 
	add a,(hl)			;2050	86 	. 
	ld c,000h		;2051	0e 00 	. . 
	scf			;2053	37 	7 
	rrca			;2054	0f 	. 
	add a,(hl)			;2055	86 	. 
	inc c			;2056	0c 	. 
	nop			;2057	00 	. 
	scf			;2058	37 	7 
	rrca			;2059	0f 	. 
	nop			;205a	00 	. 
	nop			;205b	00 	. 
	nop			;205c	00 	. 
	nop			;205d	00 	. 
	nop			;205e	00 	. 
l205fh:
	nop			;205f	00 	. 
	nop			;2060	00 	. 
	ld (bc),a			;2061	02 	. 
	nop			;2062	00 	. 
	nop			;2063	00 	. 
	nop			;2064	00 	. 
	nop			;2065	00 	. 
	inc b			;2066	04 	. 
	nop			;2067	00 	. 
	nop			;2068	00 	. 
	nop			;2069	00 	. 
	nop			;206a	00 	. 
	add hl,bc			;206b	09 	. 
	nop			;206c	00 	. 
	nop			;206d	00 	. 
	nop			;206e	00 	. 
	nop			;206f	00 	. 
	djnz l2072h		;2070	10 00 	. . 
l2072h:
	nop			;2072	00 	. 
	nop			;2073	00 	. 
	nop			;2074	00 	. 
	nop			;2075	00 	. 
	nop			;2076	00 	. 
	nop			;2077	00 	. 
	nop			;2078	00 	. 
	ld bc,l0020h		;2079	01 20 00 	.   . 
	nop			;207c	00 	. 
	nop			;207d	00 	. 
	ld (bc),a			;207e	02 	. 
	ld b,b			;207f	40 	@ 
	nop			;2080	00 	. 
	nop			;2081	00 	. 
	nop			;2082	00 	. 
	inc b			;2083	04 	. 
	add a,b			;2084	80 	. 
	nop			;2085	00 	. 
	nop			;2086	00 	. 
	nop			;2087	00 	. 
	jr l208ah		;2088	18 00 	. . 
l208ah:
	nop			;208a	00 	. 
	nop			;208b	00 	. 
	nop			;208c	00 	. 
	jr nz,l208fh		;208d	20 00 	  . 
l208fh:
	djnz l2091h		;208f	10 00 	. . 
l2091h:
	nop			;2091	00 	. 
	ld b,b			;2092	40 	@ 
	nop			;2093	00 	. 
	ret nz			;2094	c0 	. 
	ld b,b			;2095	40 	@ 
	ld bc,l0000h		;2096	01 00 00 	. . . 
	nop			;2099	00 	. 
	nop			;209a	00 	. 
	nop			;209b	00 	. 
	add a,b			;209c	80 	. 
	nop			;209d	00 	. 
	nop			;209e	00 	. 
	nop			;209f	00 	. 
	ld bc,l0000h		;20a0	01 00 00 	. . . 
	nop			;20a3	00 	. 
	add a,b			;20a4	80 	. 
	nop			;20a5	00 	. 
	nop			;20a6	00 	. 
	nop			;20a7	00 	. 
	ex af,af'			;20a8	08 	. 
	nop			;20a9	00 	. 
	ex af,af'			;20aa	08 	. 
	nop			;20ab	00 	. 
	nop			;20ac	00 	. 
	nop			;20ad	00 	. 
	jr nz,l20c0h		;20ae	20 10 	  . 
	nop			;20b0	00 	. 
	nop			;20b1	00 	. 
	nop			;20b2	00 	. 
	djnz $+34		;20b3	10 20 	.   
	nop			;20b5	00 	. 
	nop			;20b6	00 	. 
	nop			;20b7	00 	. 
	nop			;20b8	00 	. 
	ld b,b			;20b9	40 	@ 
	nop			;20ba	00 	. 
	nop			;20bb	00 	. 
	nop			;20bc	00 	. 
	nop			;20bd	00 	. 
	rst 38h			;20be	ff 	. 
l20bfh:
	nop			;20bf	00 	. 
l20c0h:
	nop			;20c0	00 	. 
	inc bc			;20c1	03 	. 
	nop			;20c2	00 	. 
	ld b,b			;20c3	40 	@ 
	nop			;20c4	00 	. 
	nop			;20c5	00 	. 
	inc (hl)			;20c6	34 	4 
	nop			;20c7	00 	. 
	nop			;20c8	00 	. 
	nop			;20c9	00 	. 
	nop			;20ca	00 	. 
	ld c,b			;20cb	48 	H 
	nop			;20cc	00 	. 
	nop			;20cd	00 	. 
	nop			;20ce	00 	. 
	nop			;20cf	00 	. 
	add a,b			;20d0	80 	. 
	nop			;20d1	00 	. 
	nop			;20d2	00 	. 
	nop			;20d3	00 	. 
	djnz l20d6h		;20d4	10 00 	. . 
l20d6h:
	nop			;20d6	00 	. 
	nop			;20d7	00 	. 
	nop			;20d8	00 	. 
	and b			;20d9	a0 	. 
	nop			;20da	00 	. 
	nop			;20db	00 	. 
	nop			;20dc	00 	. 
	nop			;20dd	00 	. 
	ld b,b			;20de	40 	@ 
	nop			;20df	00 	. 
	nop			;20e0	00 	. 
	nop			;20e1	00 	. 
	nop			;20e2	00 	. 
	nop			;20e3	00 	. 
	nop			;20e4	00 	. 
	nop			;20e5	00 	. 
	add a,b			;20e6	80 	. 
	add hl,bc			;20e7	09 	. 
	ld bc,l0000h		;20e8	01 00 00 	. . . 
	nop			;20eb	00 	. 
	ld de,l0002h		;20ec	11 02 00 	. . . 
	nop			;20ef	00 	. 
	nop			;20f0	00 	. 
	jr nz,l20f3h		;20f1	20 00 	  . 
l20f3h:
	nop			;20f3	00 	. 
	nop			;20f4	00 	. 
	nop			;20f5	00 	. 
	nop			;20f6	00 	. 
	inc b			;20f7	04 	. 
	nop			;20f8	00 	. 
	nop			;20f9	00 	. 
	nop			;20fa	00 	. 
	ld b,b			;20fb	40 	@ 
	nop			;20fc	00 	. 
	nop			;20fd	00 	. 
	add a,b			;20fe	80 	. 
	nop			;20ff	00 	. 
	nop			;2100	00 	. 
	ex af,af'			;2101	08 	. 
	nop			;2102	00 	. 
	nop			;2103	00 	. 
	nop			;2104	00 	. 
	nop			;2105	00 	. 
	nop			;2106	00 	. 
	nop			;2107	00 	. 
	ld b,b			;2108	40 	@ 
	nop			;2109	00 	. 
	nop			;210a	00 	. 
	nop			;210b	00 	. 
	nop			;210c	00 	. 
	djnz l210fh		;210d	10 00 	. . 
l210fh:
	nop			;210f	00 	. 
	nop			;2110	00 	. 
	nop			;2111	00 	. 
	nop			;2112	00 	. 
	djnz l2115h		;2113	10 00 	. . 
l2115h:
	nop			;2115	00 	. 
	nop			;2116	00 	. 
	ex af,af'			;2117	08 	. 
	nop			;2118	00 	. 
	nop			;2119	00 	. 
	nop			;211a	00 	. 
	nop			;211b	00 	. 
	nop			;211c	00 	. 
	jr nz,$+1		;211d	20 ff 	  . 
l211fh:
	nop			;211f	00 	. 
	nop			;2120	00 	. 
	nop			;2121	00 	. 
	nop			;2122	00 	. 
	jr nz,l2125h		;2123	20 00 	  . 
l2125h:
	nop			;2125	00 	. 
	nop			;2126	00 	. 
	ex af,af'			;2127	08 	. 
	nop			;2128	00 	. 
	nop			;2129	00 	. 
	nop			;212a	00 	. 
	nop			;212b	00 	. 
	nop			;212c	00 	. 
	djnz l212fh		;212d	10 00 	. . 
l212fh:
	nop			;212f	00 	. 
	nop			;2130	00 	. 
	djnz l2133h		;2131	10 00 	. . 
l2133h:
	ld b,b			;2133	40 	@ 
	nop			;2134	00 	. 
	nop			;2135	00 	. 
	ld b,b			;2136	40 	@ 
	nop			;2137	00 	. 
	nop			;2138	00 	. 
	nop			;2139	00 	. 
	nop			;213a	00 	. 
	nop			;213b	00 	. 
	nop			;213c	00 	. 
	nop			;213d	00 	. 
	ex af,af'			;213e	08 	. 
	nop			;213f	00 	. 
	nop			;2140	00 	. 
	nop			;2141	00 	. 
	nop			;2142	00 	. 
	nop			;2143	00 	. 
	nop			;2144	00 	. 
	add a,b			;2145	80 	. 
	nop			;2146	00 	. 
	jr nz,$+6		;2147	20 04 	  . 
	nop			;2149	00 	. 
	nop			;214a	00 	. 
	nop			;214b	00 	. 
	ld de,l0000h		;214c	11 00 00 	. . . 
	nop			;214f	00 	. 
	nop			;2150	00 	. 
	add hl,bc			;2151	09 	. 
	ld (bc),a			;2152	02 	. 
	nop			;2153	00 	. 
	nop			;2154	00 	. 
	nop			;2155	00 	. 
	nop			;2156	00 	. 
	ld bc,l0000h		;2157	01 00 00 	. . . 
	add a,b			;215a	80 	. 
	nop			;215b	00 	. 
	ld b,b			;215c	40 	@ 
	nop			;215d	00 	. 
	nop			;215e	00 	. 
	nop			;215f	00 	. 
	nop			;2160	00 	. 
	and b			;2161	a0 	. 
	nop			;2162	00 	. 
	nop			;2163	00 	. 
	nop			;2164	00 	. 
	nop			;2165	00 	. 
	djnz l2168h		;2166	10 00 	. . 
l2168h:
	nop			;2168	00 	. 
	nop			;2169	00 	. 
	nop			;216a	00 	. 
	nop			;216b	00 	. 
	add a,b			;216c	80 	. 
	nop			;216d	00 	. 
	nop			;216e	00 	. 
	nop			;216f	00 	. 
	nop			;2170	00 	. 
	ex af,af'			;2171	08 	. 
	nop			;2172	00 	. 
	nop			;2173	00 	. 
	nop			;2174	00 	. 
	nop			;2175	00 	. 
	ld b,b			;2176	40 	@ 
	nop			;2177	00 	. 
	nop			;2178	00 	. 
	nop			;2179	00 	. 
	nop			;217a	00 	. 
	inc (hl)			;217b	34 	4 
	nop			;217c	00 	. 
	nop			;217d	00 	. 
	nop			;217e	00 	. 
	nop			;217f	00 	. 
	inc bc			;2180	03 	. 
	nop			;2181	00 	. 
	ld b,b			;2182	40 	@ 
	rst 38h			;2183	ff 	. 
l2184h:
	ld b,b			;2184	40 	@ 
	nop			;2185	00 	. 
	nop			;2186	00 	. 
	nop			;2187	00 	. 
	nop			;2188	00 	. 
	jr nz,l218bh		;2189	20 00 	  . 
l218bh:
	nop			;218b	00 	. 
	nop			;218c	00 	. 
	djnz $+18		;218d	10 10 	. . 
	nop			;218f	00 	. 
	nop			;2190	00 	. 
	nop			;2191	00 	. 
	jr nz,l2194h		;2192	20 00 	  . 
l2194h:
	nop			;2194	00 	. 
	nop			;2195	00 	. 
	nop			;2196	00 	. 
	nop			;2197	00 	. 
	ex af,af'			;2198	08 	. 
	nop			;2199	00 	. 
	nop			;219a	00 	. 
	ex af,af'			;219b	08 	. 
	nop			;219c	00 	. 
	ld bc,l0000h		;219d	01 00 00 	. . . 
	nop			;21a0	00 	. 
	add a,b			;21a1	80 	. 
	ld bc,00080h		;21a2	01 80 00 	. . . 
	ret nz			;21a5	c0 	. 
	nop			;21a6	00 	. 
	nop			;21a7	00 	. 
	ld b,b			;21a8	40 	@ 
	nop			;21a9	00 	. 
	djnz l21ach		;21aa	10 00 	. . 
l21ach:
	nop			;21ac	00 	. 
	ex af,af'			;21ad	08 	. 
	nop			;21ae	00 	. 
	nop			;21af	00 	. 
	nop			;21b0	00 	. 
	nop			;21b1	00 	. 
	jr nz,l21b4h		;21b2	20 00 	  . 
l21b4h:
	nop			;21b4	00 	. 
	nop			;21b5	00 	. 
	nop			;21b6	00 	. 
	inc d			;21b7	14 	. 
	nop			;21b8	00 	. 
	nop			;21b9	00 	. 
	nop			;21ba	00 	. 
	nop			;21bb	00 	. 
	ld (bc),a			;21bc	02 	. 
	nop			;21bd	00 	. 
	nop			;21be	00 	. 
	ld b,b			;21bf	40 	@ 
	nop			;21c0	00 	. 
	ld bc,00080h		;21c1	01 80 00 	. . . 
	nop			;21c4	00 	. 
	nop			;21c5	00 	. 
	nop			;21c6	00 	. 
	ld b,b			;21c7	40 	@ 
	nop			;21c8	00 	. 
	nop			;21c9	00 	. 
	nop			;21ca	00 	. 
	nop			;21cb	00 	. 
	jr nz,l21ceh		;21cc	20 00 	  . 
l21ceh:
	nop			;21ce	00 	. 
	nop			;21cf	00 	. 
	nop			;21d0	00 	. 
	djnz l21d3h		;21d1	10 00 	. . 
l21d3h:
	nop			;21d3	00 	. 
	nop			;21d4	00 	. 
	nop			;21d5	00 	. 
	add hl,bc			;21d6	09 	. 
	nop			;21d7	00 	. 
	nop			;21d8	00 	. 
	nop			;21d9	00 	. 
	nop			;21da	00 	. 
	inc b			;21db	04 	. 
	nop			;21dc	00 	. 
	nop			;21dd	00 	. 
	nop			;21de	00 	. 
	nop			;21df	00 	. 
	ld (bc),a			;21e0	02 	. 
	nop			;21e1	00 	. 
	nop			;21e2	00 	. 
	rst 38h			;21e3	ff 	. 
l21e4h:
	nop			;21e4	00 	. 
	nop			;21e5	00 	. 
	nop			;21e6	00 	. 
	djnz l21e9h		;21e7	10 00 	. . 
l21e9h:
	nop			;21e9	00 	. 
	ex af,af'			;21ea	08 	. 
	nop			;21eb	00 	. 
	nop			;21ec	00 	. 
	nop			;21ed	00 	. 
	nop			;21ee	00 	. 
	inc b			;21ef	04 	. 
	nop			;21f0	00 	. 
	nop			;21f1	00 	. 
	nop			;21f2	00 	. 
	nop			;21f3	00 	. 
	ld (bc),a			;21f4	02 	. 
	nop			;21f5	00 	. 
	nop			;21f6	00 	. 
	nop			;21f7	00 	. 
	nop			;21f8	00 	. 
	ld bc,l0000h		;21f9	01 00 00 	. . . 
	nop			;21fc	00 	. 
	ld b,b			;21fd	40 	@ 
	nop			;21fe	00 	. 
	nop			;21ff	00 	. 
	nop			;2200	00 	. 
	nop			;2201	00 	. 
	jr nz,l2204h		;2202	20 00 	  . 
l2204h:
	nop			;2204	00 	. 
	nop			;2205	00 	. 
	nop			;2206	00 	. 
	djnz l2209h		;2207	10 00 	. . 
l2209h:
	nop			;2209	00 	. 
	nop			;220a	00 	. 
	nop			;220b	00 	. 
	ex af,af'			;220c	08 	. 
	nop			;220d	00 	. 
	nop			;220e	00 	. 
	nop			;220f	00 	. 
	nop			;2210	00 	. 
	rst 38h			;2211	ff 	. 
l2212h:
	ld a,b			;2212	78 	x 
	rrca			;2213	0f 	. 
	ex af,af'			;2214	08 	. 
	djnz l2217h		;2215	10 00 	. . 
l2217h:
	nop			;2217	00 	. 
	nop			;2218	00 	. 
	nop			;2219	00 	. 
	nop			;221a	00 	. 
	nop			;221b	00 	. 
	ld a,b			;221c	78 	x 
	rrca			;221d	0f 	. 
	ex af,af'			;221e	08 	. 
	djnz l2221h		;221f	10 00 	. . 
l2221h:
	nop			;2221	00 	. 
	nop			;2222	00 	. 
	nop			;2223	00 	. 
	nop			;2224	00 	. 
	nop			;2225	00 	. 
	ld a,b			;2226	78 	x 
	rrca			;2227	0f 	. 
	ex af,af'			;2228	08 	. 
	djnz l222bh		;2229	10 00 	. . 
l222bh:
	nop			;222b	00 	. 
	nop			;222c	00 	. 
	nop			;222d	00 	. 
	nop			;222e	00 	. 
	nop			;222f	00 	. 
	ld a,b			;2230	78 	x 
	rrca			;2231	0f 	. 
	ex af,af'			;2232	08 	. 
	djnz l2235h		;2233	10 00 	. . 
l2235h:
	nop			;2235	00 	. 
	nop			;2236	00 	. 
	nop			;2237	00 	. 
	nop			;2238	00 	. 
	nop			;2239	00 	. 
	rst 38h			;223a	ff 	. 
	nop			;223b	00 	. 
	nop			;223c	00 	. 
	nop			;223d	00 	. 
	nop			;223e	00 	. 
	nop			;223f	00 	. 
	nop			;2240	00 	. 
	nop			;2241	00 	. 
	nop			;2242	00 	. 
	nop			;2243	00 	. 
	nop			;2244	00 	. 
	nop			;2245	00 	. 
	nop			;2246	00 	. 
	nop			;2247	00 	. 
	nop			;2248	00 	. 
	nop			;2249	00 	. 
	nop			;224a	00 	. 
	nop			;224b	00 	. 
	nop			;224c	00 	. 
	nop			;224d	00 	. 
	nop			;224e	00 	. 
	nop			;224f	00 	. 
	nop			;2250	00 	. 
	nop			;2251	00 	. 
	nop			;2252	00 	. 
	nop			;2253	00 	. 
	nop			;2254	00 	. 
	nop			;2255	00 	. 
	nop			;2256	00 	. 
	nop			;2257	00 	. 
	nop			;2258	00 	. 
	nop			;2259	00 	. 
	nop			;225a	00 	. 
	nop			;225b	00 	. 
	nop			;225c	00 	. 
	nop			;225d	00 	. 
	nop			;225e	00 	. 
	nop			;225f	00 	. 
	nop			;2260	00 	. 
	nop			;2261	00 	. 
	nop			;2262	00 	. 
	nop			;2263	00 	. 
	nop			;2264	00 	. 
	nop			;2265	00 	. 
	nop			;2266	00 	. 
	nop			;2267	00 	. 
	nop			;2268	00 	. 
	nop			;2269	00 	. 
	nop			;226a	00 	. 
	nop			;226b	00 	. 
	nop			;226c	00 	. 
	nop			;226d	00 	. 
	nop			;226e	00 	. 
	nop			;226f	00 	. 
	nop			;2270	00 	. 
	nop			;2271	00 	. 
	nop			;2272	00 	. 
	nop			;2273	00 	. 
	nop			;2274	00 	. 
	nop			;2275	00 	. 
	nop			;2276	00 	. 
	nop			;2277	00 	. 
	nop			;2278	00 	. 
	nop			;2279	00 	. 
	nop			;227a	00 	. 
	nop			;227b	00 	. 
	nop			;227c	00 	. 
	nop			;227d	00 	. 
	nop			;227e	00 	. 
	nop			;227f	00 	. 
	nop			;2280	00 	. 
	nop			;2281	00 	. 
	nop			;2282	00 	. 
	nop			;2283	00 	. 
	nop			;2284	00 	. 
	nop			;2285	00 	. 
	nop			;2286	00 	. 
	nop			;2287	00 	. 
	nop			;2288	00 	. 
	nop			;2289	00 	. 
	nop			;228a	00 	. 
	nop			;228b	00 	. 
	nop			;228c	00 	. 
	nop			;228d	00 	. 
	nop			;228e	00 	. 
	nop			;228f	00 	. 
	nop			;2290	00 	. 
	nop			;2291	00 	. 
	nop			;2292	00 	. 
	nop			;2293	00 	. 
	nop			;2294	00 	. 
	nop			;2295	00 	. 
	nop			;2296	00 	. 
	nop			;2297	00 	. 
	nop			;2298	00 	. 
	nop			;2299	00 	. 
	nop			;229a	00 	. 
	nop			;229b	00 	. 
	nop			;229c	00 	. 
	nop			;229d	00 	. 
	nop			;229e	00 	. 
	nop			;229f	00 	. 
	nop			;22a0	00 	. 
	nop			;22a1	00 	. 
	nop			;22a2	00 	. 
	nop			;22a3	00 	. 
	nop			;22a4	00 	. 
	nop			;22a5	00 	. 
	nop			;22a6	00 	. 
	nop			;22a7	00 	. 
	nop			;22a8	00 	. 
	nop			;22a9	00 	. 
	nop			;22aa	00 	. 
	nop			;22ab	00 	. 
	nop			;22ac	00 	. 
	nop			;22ad	00 	. 
	nop			;22ae	00 	. 
	nop			;22af	00 	. 
	nop			;22b0	00 	. 
	nop			;22b1	00 	. 
	nop			;22b2	00 	. 
	nop			;22b3	00 	. 
	nop			;22b4	00 	. 
	nop			;22b5	00 	. 
	nop			;22b6	00 	. 
	nop			;22b7	00 	. 
	nop			;22b8	00 	. 
	nop			;22b9	00 	. 
	nop			;22ba	00 	. 
	nop			;22bb	00 	. 
	nop			;22bc	00 	. 
	nop			;22bd	00 	. 
	nop			;22be	00 	. 
	nop			;22bf	00 	. 
	nop			;22c0	00 	. 
	nop			;22c1	00 	. 
	nop			;22c2	00 	. 
	nop			;22c3	00 	. 
	nop			;22c4	00 	. 
	nop			;22c5	00 	. 
	nop			;22c6	00 	. 
	nop			;22c7	00 	. 
	nop			;22c8	00 	. 
	nop			;22c9	00 	. 
	nop			;22ca	00 	. 
	nop			;22cb	00 	. 
	nop			;22cc	00 	. 
	nop			;22cd	00 	. 
	nop			;22ce	00 	. 
	nop			;22cf	00 	. 
	nop			;22d0	00 	. 
	nop			;22d1	00 	. 
	nop			;22d2	00 	. 
	nop			;22d3	00 	. 
	nop			;22d4	00 	. 
	nop			;22d5	00 	. 
	nop			;22d6	00 	. 
	nop			;22d7	00 	. 
	nop			;22d8	00 	. 
	nop			;22d9	00 	. 
	nop			;22da	00 	. 
	nop			;22db	00 	. 
	nop			;22dc	00 	. 
	nop			;22dd	00 	. 
	nop			;22de	00 	. 
	nop			;22df	00 	. 
	nop			;22e0	00 	. 
	nop			;22e1	00 	. 
	nop			;22e2	00 	. 
	nop			;22e3	00 	. 
	nop			;22e4	00 	. 
	nop			;22e5	00 	. 
	nop			;22e6	00 	. 
	nop			;22e7	00 	. 
	nop			;22e8	00 	. 
	nop			;22e9	00 	. 
	nop			;22ea	00 	. 
	nop			;22eb	00 	. 
	nop			;22ec	00 	. 
	nop			;22ed	00 	. 
	nop			;22ee	00 	. 
	nop			;22ef	00 	. 
	nop			;22f0	00 	. 
	nop			;22f1	00 	. 
	nop			;22f2	00 	. 
	nop			;22f3	00 	. 
	nop			;22f4	00 	. 
	nop			;22f5	00 	. 
	nop			;22f6	00 	. 
	nop			;22f7	00 	. 
	nop			;22f8	00 	. 
	nop			;22f9	00 	. 
	nop			;22fa	00 	. 
	nop			;22fb	00 	. 
	nop			;22fc	00 	. 
	nop			;22fd	00 	. 
	nop			;22fe	00 	. 
	nop			;22ff	00 	. 
	nop			;2300	00 	. 
	nop			;2301	00 	. 
	nop			;2302	00 	. 
	nop			;2303	00 	. 
	nop			;2304	00 	. 
	nop			;2305	00 	. 
	nop			;2306	00 	. 
	nop			;2307	00 	. 
	nop			;2308	00 	. 
	nop			;2309	00 	. 
	nop			;230a	00 	. 
	nop			;230b	00 	. 
	nop			;230c	00 	. 
	nop			;230d	00 	. 
	nop			;230e	00 	. 
	nop			;230f	00 	. 
	nop			;2310	00 	. 
	nop			;2311	00 	. 
	nop			;2312	00 	. 
	nop			;2313	00 	. 
	nop			;2314	00 	. 
	nop			;2315	00 	. 
	nop			;2316	00 	. 
	nop			;2317	00 	. 
	nop			;2318	00 	. 
	nop			;2319	00 	. 
	nop			;231a	00 	. 
	nop			;231b	00 	. 
	nop			;231c	00 	. 
	nop			;231d	00 	. 
	nop			;231e	00 	. 
	nop			;231f	00 	. 
	nop			;2320	00 	. 
	nop			;2321	00 	. 
	nop			;2322	00 	. 
	nop			;2323	00 	. 
	nop			;2324	00 	. 
	nop			;2325	00 	. 
	nop			;2326	00 	. 
	nop			;2327	00 	. 
	nop			;2328	00 	. 
	nop			;2329	00 	. 
	nop			;232a	00 	. 
	nop			;232b	00 	. 
	nop			;232c	00 	. 
	nop			;232d	00 	. 
	nop			;232e	00 	. 
	nop			;232f	00 	. 
	nop			;2330	00 	. 
	nop			;2331	00 	. 
	nop			;2332	00 	. 
	nop			;2333	00 	. 
	nop			;2334	00 	. 
	nop			;2335	00 	. 
	nop			;2336	00 	. 
	nop			;2337	00 	. 
	nop			;2338	00 	. 
	nop			;2339	00 	. 
	nop			;233a	00 	. 
	nop			;233b	00 	. 
	nop			;233c	00 	. 
	nop			;233d	00 	. 
	nop			;233e	00 	. 
	nop			;233f	00 	. 
	nop			;2340	00 	. 
	nop			;2341	00 	. 
	nop			;2342	00 	. 
	nop			;2343	00 	. 
	nop			;2344	00 	. 
	nop			;2345	00 	. 
	nop			;2346	00 	. 
	nop			;2347	00 	. 
	nop			;2348	00 	. 
	nop			;2349	00 	. 
	nop			;234a	00 	. 
	nop			;234b	00 	. 
	nop			;234c	00 	. 
	nop			;234d	00 	. 
	nop			;234e	00 	. 
	nop			;234f	00 	. 
	nop			;2350	00 	. 
	nop			;2351	00 	. 
	nop			;2352	00 	. 
	nop			;2353	00 	. 
	nop			;2354	00 	. 
	nop			;2355	00 	. 
	nop			;2356	00 	. 
	nop			;2357	00 	. 
	nop			;2358	00 	. 
	nop			;2359	00 	. 
	nop			;235a	00 	. 
	nop			;235b	00 	. 
	nop			;235c	00 	. 
	nop			;235d	00 	. 
	nop			;235e	00 	. 
	nop			;235f	00 	. 
	nop			;2360	00 	. 
	nop			;2361	00 	. 
	nop			;2362	00 	. 
	nop			;2363	00 	. 
	nop			;2364	00 	. 
	nop			;2365	00 	. 
	nop			;2366	00 	. 
	nop			;2367	00 	. 
	nop			;2368	00 	. 
	nop			;2369	00 	. 
	nop			;236a	00 	. 
	nop			;236b	00 	. 
	nop			;236c	00 	. 
	nop			;236d	00 	. 
	nop			;236e	00 	. 
	nop			;236f	00 	. 
	nop			;2370	00 	. 
	nop			;2371	00 	. 
	nop			;2372	00 	. 
	nop			;2373	00 	. 
	nop			;2374	00 	. 
	nop			;2375	00 	. 
	nop			;2376	00 	. 
	nop			;2377	00 	. 
	nop			;2378	00 	. 
	nop			;2379	00 	. 
	nop			;237a	00 	. 
	nop			;237b	00 	. 
	nop			;237c	00 	. 
	nop			;237d	00 	. 
	nop			;237e	00 	. 
	nop			;237f	00 	. 
	nop			;2380	00 	. 
	nop			;2381	00 	. 
	nop			;2382	00 	. 
	nop			;2383	00 	. 
	nop			;2384	00 	. 
	nop			;2385	00 	. 
	nop			;2386	00 	. 
	nop			;2387	00 	. 
	nop			;2388	00 	. 
	nop			;2389	00 	. 
	nop			;238a	00 	. 
	nop			;238b	00 	. 
	nop			;238c	00 	. 
	nop			;238d	00 	. 
	nop			;238e	00 	. 
	nop			;238f	00 	. 
	nop			;2390	00 	. 
	nop			;2391	00 	. 
	nop			;2392	00 	. 
	nop			;2393	00 	. 
	nop			;2394	00 	. 
	nop			;2395	00 	. 
	nop			;2396	00 	. 
	nop			;2397	00 	. 
	nop			;2398	00 	. 
	nop			;2399	00 	. 
	nop			;239a	00 	. 
	nop			;239b	00 	. 
	nop			;239c	00 	. 
	nop			;239d	00 	. 
	nop			;239e	00 	. 
	nop			;239f	00 	. 
	nop			;23a0	00 	. 
	nop			;23a1	00 	. 
	nop			;23a2	00 	. 
	nop			;23a3	00 	. 
	nop			;23a4	00 	. 
	nop			;23a5	00 	. 
	nop			;23a6	00 	. 
	nop			;23a7	00 	. 
	nop			;23a8	00 	. 
	nop			;23a9	00 	. 
	nop			;23aa	00 	. 
	nop			;23ab	00 	. 
	nop			;23ac	00 	. 
	nop			;23ad	00 	. 
	nop			;23ae	00 	. 
	nop			;23af	00 	. 
	nop			;23b0	00 	. 
	nop			;23b1	00 	. 
	nop			;23b2	00 	. 
	nop			;23b3	00 	. 
	nop			;23b4	00 	. 
	nop			;23b5	00 	. 
	nop			;23b6	00 	. 
	nop			;23b7	00 	. 
	nop			;23b8	00 	. 
	nop			;23b9	00 	. 
	nop			;23ba	00 	. 
	nop			;23bb	00 	. 
	nop			;23bc	00 	. 
	nop			;23bd	00 	. 
	nop			;23be	00 	. 
	nop			;23bf	00 	. 
	nop			;23c0	00 	. 
	nop			;23c1	00 	. 
	nop			;23c2	00 	. 
	nop			;23c3	00 	. 
	nop			;23c4	00 	. 
	nop			;23c5	00 	. 
	nop			;23c6	00 	. 
	nop			;23c7	00 	. 
	nop			;23c8	00 	. 
	nop			;23c9	00 	. 
	nop			;23ca	00 	. 
	nop			;23cb	00 	. 
	nop			;23cc	00 	. 
	nop			;23cd	00 	. 
	nop			;23ce	00 	. 
	nop			;23cf	00 	. 
	nop			;23d0	00 	. 
	nop			;23d1	00 	. 
	nop			;23d2	00 	. 
	nop			;23d3	00 	. 
	nop			;23d4	00 	. 
	nop			;23d5	00 	. 
	nop			;23d6	00 	. 
	nop			;23d7	00 	. 
	nop			;23d8	00 	. 
	nop			;23d9	00 	. 
	nop			;23da	00 	. 
	nop			;23db	00 	. 
	nop			;23dc	00 	. 
	nop			;23dd	00 	. 
	nop			;23de	00 	. 
	nop			;23df	00 	. 
	nop			;23e0	00 	. 
	nop			;23e1	00 	. 
	nop			;23e2	00 	. 
	nop			;23e3	00 	. 
	nop			;23e4	00 	. 
	nop			;23e5	00 	. 
	nop			;23e6	00 	. 
	nop			;23e7	00 	. 
	nop			;23e8	00 	. 
	nop			;23e9	00 	. 
	nop			;23ea	00 	. 
	nop			;23eb	00 	. 
	nop			;23ec	00 	. 
	nop			;23ed	00 	. 
	nop			;23ee	00 	. 
	nop			;23ef	00 	. 
	nop			;23f0	00 	. 
	nop			;23f1	00 	. 
	nop			;23f2	00 	. 
	nop			;23f3	00 	. 
	nop			;23f4	00 	. 
	nop			;23f5	00 	. 
	nop			;23f6	00 	. 
	nop			;23f7	00 	. 
	nop			;23f8	00 	. 
	nop			;23f9	00 	. 
	nop			;23fa	00 	. 
	nop			;23fb	00 	. 
	nop			;23fc	00 	. 
	nop			;23fd	00 	. 
	nop			;23fe	00 	. 
	nop			;23ff	00 	. 
	nop			;2400	00 	. 
	nop			;2401	00 	. 
	nop			;2402	00 	. 
	nop			;2403	00 	. 
	nop			;2404	00 	. 
	nop			;2405	00 	. 
	nop			;2406	00 	. 
	nop			;2407	00 	. 
	nop			;2408	00 	. 
	nop			;2409	00 	. 
	nop			;240a	00 	. 
	nop			;240b	00 	. 
	nop			;240c	00 	. 
	nop			;240d	00 	. 
	nop			;240e	00 	. 
	nop			;240f	00 	. 
	nop			;2410	00 	. 
	nop			;2411	00 	. 
	nop			;2412	00 	. 
	nop			;2413	00 	. 
	nop			;2414	00 	. 
	nop			;2415	00 	. 
	nop			;2416	00 	. 
	nop			;2417	00 	. 
	nop			;2418	00 	. 
	nop			;2419	00 	. 
	nop			;241a	00 	. 
	nop			;241b	00 	. 
	nop			;241c	00 	. 
	nop			;241d	00 	. 
	nop			;241e	00 	. 
	nop			;241f	00 	. 
	nop			;2420	00 	. 
	nop			;2421	00 	. 
	nop			;2422	00 	. 
	nop			;2423	00 	. 
	nop			;2424	00 	. 
	nop			;2425	00 	. 
	nop			;2426	00 	. 
	nop			;2427	00 	. 
	nop			;2428	00 	. 
	nop			;2429	00 	. 
	nop			;242a	00 	. 
	nop			;242b	00 	. 
	nop			;242c	00 	. 
	nop			;242d	00 	. 
	nop			;242e	00 	. 
	nop			;242f	00 	. 
	nop			;2430	00 	. 
	nop			;2431	00 	. 
	nop			;2432	00 	. 
	nop			;2433	00 	. 
	nop			;2434	00 	. 
	nop			;2435	00 	. 
	nop			;2436	00 	. 
	nop			;2437	00 	. 
	nop			;2438	00 	. 
	nop			;2439	00 	. 
	nop			;243a	00 	. 
	nop			;243b	00 	. 
	nop			;243c	00 	. 
	nop			;243d	00 	. 
	nop			;243e	00 	. 
	nop			;243f	00 	. 
	nop			;2440	00 	. 
	nop			;2441	00 	. 
	nop			;2442	00 	. 
	nop			;2443	00 	. 
	nop			;2444	00 	. 
	nop			;2445	00 	. 
	nop			;2446	00 	. 
	nop			;2447	00 	. 
	nop			;2448	00 	. 
	nop			;2449	00 	. 
	nop			;244a	00 	. 
	nop			;244b	00 	. 
	nop			;244c	00 	. 
	nop			;244d	00 	. 
	nop			;244e	00 	. 
	nop			;244f	00 	. 
	nop			;2450	00 	. 
	nop			;2451	00 	. 
	nop			;2452	00 	. 
	nop			;2453	00 	. 
	nop			;2454	00 	. 
	nop			;2455	00 	. 
	nop			;2456	00 	. 
	nop			;2457	00 	. 
	nop			;2458	00 	. 
	nop			;2459	00 	. 
	nop			;245a	00 	. 
	nop			;245b	00 	. 
	nop			;245c	00 	. 
	nop			;245d	00 	. 
	nop			;245e	00 	. 
	nop			;245f	00 	. 
	nop			;2460	00 	. 
	nop			;2461	00 	. 
	nop			;2462	00 	. 
	nop			;2463	00 	. 
	nop			;2464	00 	. 
	nop			;2465	00 	. 
	nop			;2466	00 	. 
	nop			;2467	00 	. 
	nop			;2468	00 	. 
	nop			;2469	00 	. 
	nop			;246a	00 	. 
	nop			;246b	00 	. 
	nop			;246c	00 	. 
	nop			;246d	00 	. 
	nop			;246e	00 	. 
	nop			;246f	00 	. 
	nop			;2470	00 	. 
	nop			;2471	00 	. 
	nop			;2472	00 	. 
	nop			;2473	00 	. 
	nop			;2474	00 	. 
	nop			;2475	00 	. 
	nop			;2476	00 	. 
	nop			;2477	00 	. 
	nop			;2478	00 	. 
	nop			;2479	00 	. 
	nop			;247a	00 	. 
	nop			;247b	00 	. 
	nop			;247c	00 	. 
	nop			;247d	00 	. 
	nop			;247e	00 	. 
	nop			;247f	00 	. 
	nop			;2480	00 	. 
	nop			;2481	00 	. 
	nop			;2482	00 	. 
	nop			;2483	00 	. 
	nop			;2484	00 	. 
	nop			;2485	00 	. 
	nop			;2486	00 	. 
	nop			;2487	00 	. 
	nop			;2488	00 	. 
	nop			;2489	00 	. 
	nop			;248a	00 	. 
	nop			;248b	00 	. 
	nop			;248c	00 	. 
	nop			;248d	00 	. 
	nop			;248e	00 	. 
	nop			;248f	00 	. 
	nop			;2490	00 	. 
	nop			;2491	00 	. 
	nop			;2492	00 	. 
	nop			;2493	00 	. 
	nop			;2494	00 	. 
	nop			;2495	00 	. 
	nop			;2496	00 	. 
	nop			;2497	00 	. 
	nop			;2498	00 	. 
	nop			;2499	00 	. 
	nop			;249a	00 	. 
	nop			;249b	00 	. 
	nop			;249c	00 	. 
	nop			;249d	00 	. 
	nop			;249e	00 	. 
	nop			;249f	00 	. 
	nop			;24a0	00 	. 
	nop			;24a1	00 	. 
	nop			;24a2	00 	. 
	nop			;24a3	00 	. 
	nop			;24a4	00 	. 
	nop			;24a5	00 	. 
	nop			;24a6	00 	. 
	nop			;24a7	00 	. 
	nop			;24a8	00 	. 
	nop			;24a9	00 	. 
	nop			;24aa	00 	. 
	nop			;24ab	00 	. 
	nop			;24ac	00 	. 
	nop			;24ad	00 	. 
	nop			;24ae	00 	. 
	nop			;24af	00 	. 
	nop			;24b0	00 	. 
	nop			;24b1	00 	. 
	nop			;24b2	00 	. 
	nop			;24b3	00 	. 
	nop			;24b4	00 	. 
	nop			;24b5	00 	. 
	nop			;24b6	00 	. 
	nop			;24b7	00 	. 
	nop			;24b8	00 	. 
	nop			;24b9	00 	. 
	nop			;24ba	00 	. 
	nop			;24bb	00 	. 
	nop			;24bc	00 	. 
	nop			;24bd	00 	. 
	nop			;24be	00 	. 
	nop			;24bf	00 	. 
	nop			;24c0	00 	. 
	nop			;24c1	00 	. 
	nop			;24c2	00 	. 
	nop			;24c3	00 	. 
	nop			;24c4	00 	. 
	nop			;24c5	00 	. 
	nop			;24c6	00 	. 
	nop			;24c7	00 	. 
	nop			;24c8	00 	. 
	nop			;24c9	00 	. 
	nop			;24ca	00 	. 
	nop			;24cb	00 	. 
	nop			;24cc	00 	. 
	nop			;24cd	00 	. 
	nop			;24ce	00 	. 
	nop			;24cf	00 	. 
	nop			;24d0	00 	. 
	nop			;24d1	00 	. 
	nop			;24d2	00 	. 
	nop			;24d3	00 	. 
	nop			;24d4	00 	. 
	nop			;24d5	00 	. 
	nop			;24d6	00 	. 
	nop			;24d7	00 	. 
	nop			;24d8	00 	. 
	nop			;24d9	00 	. 
	nop			;24da	00 	. 
	nop			;24db	00 	. 
	nop			;24dc	00 	. 
	nop			;24dd	00 	. 
	nop			;24de	00 	. 
	nop			;24df	00 	. 
	nop			;24e0	00 	. 
	nop			;24e1	00 	. 
	nop			;24e2	00 	. 
	nop			;24e3	00 	. 
	nop			;24e4	00 	. 
	nop			;24e5	00 	. 
	nop			;24e6	00 	. 
	nop			;24e7	00 	. 
	nop			;24e8	00 	. 
	nop			;24e9	00 	. 
	nop			;24ea	00 	. 
	nop			;24eb	00 	. 
	nop			;24ec	00 	. 
	nop			;24ed	00 	. 
	nop			;24ee	00 	. 
	nop			;24ef	00 	. 
	nop			;24f0	00 	. 
	nop			;24f1	00 	. 
	nop			;24f2	00 	. 
	nop			;24f3	00 	. 
	nop			;24f4	00 	. 
	nop			;24f5	00 	. 
	nop			;24f6	00 	. 
	nop			;24f7	00 	. 
	nop			;24f8	00 	. 
	nop			;24f9	00 	. 
	nop			;24fa	00 	. 
	nop			;24fb	00 	. 
	nop			;24fc	00 	. 
	nop			;24fd	00 	. 
	nop			;24fe	00 	. 
	nop			;24ff	00 	. 
	nop			;2500	00 	. 
	nop			;2501	00 	. 
	nop			;2502	00 	. 
	nop			;2503	00 	. 
	nop			;2504	00 	. 
	nop			;2505	00 	. 
	nop			;2506	00 	. 
	nop			;2507	00 	. 
	nop			;2508	00 	. 
	nop			;2509	00 	. 
	nop			;250a	00 	. 
	nop			;250b	00 	. 
	nop			;250c	00 	. 
	nop			;250d	00 	. 
	nop			;250e	00 	. 
	nop			;250f	00 	. 
	nop			;2510	00 	. 
	nop			;2511	00 	. 
	nop			;2512	00 	. 
	nop			;2513	00 	. 
	nop			;2514	00 	. 
	nop			;2515	00 	. 
	nop			;2516	00 	. 
	nop			;2517	00 	. 
	nop			;2518	00 	. 
	nop			;2519	00 	. 
	nop			;251a	00 	. 
	nop			;251b	00 	. 
	nop			;251c	00 	. 
	nop			;251d	00 	. 
	nop			;251e	00 	. 
	nop			;251f	00 	. 
	nop			;2520	00 	. 
	nop			;2521	00 	. 
	nop			;2522	00 	. 
	nop			;2523	00 	. 
	nop			;2524	00 	. 
	nop			;2525	00 	. 
	nop			;2526	00 	. 
	nop			;2527	00 	. 
	nop			;2528	00 	. 
	nop			;2529	00 	. 
	nop			;252a	00 	. 
	nop			;252b	00 	. 
	nop			;252c	00 	. 
	nop			;252d	00 	. 
	nop			;252e	00 	. 
	nop			;252f	00 	. 
	nop			;2530	00 	. 
	nop			;2531	00 	. 
	nop			;2532	00 	. 
	nop			;2533	00 	. 
	nop			;2534	00 	. 
	nop			;2535	00 	. 
	nop			;2536	00 	. 
	nop			;2537	00 	. 
	nop			;2538	00 	. 
	nop			;2539	00 	. 
	nop			;253a	00 	. 
	nop			;253b	00 	. 
	nop			;253c	00 	. 
	nop			;253d	00 	. 
	nop			;253e	00 	. 
	nop			;253f	00 	. 
	nop			;2540	00 	. 
	nop			;2541	00 	. 
	nop			;2542	00 	. 
	nop			;2543	00 	. 
	nop			;2544	00 	. 
	nop			;2545	00 	. 
	nop			;2546	00 	. 
	nop			;2547	00 	. 
	nop			;2548	00 	. 
	nop			;2549	00 	. 
	nop			;254a	00 	. 
	nop			;254b	00 	. 
	nop			;254c	00 	. 
	nop			;254d	00 	. 
	nop			;254e	00 	. 
	nop			;254f	00 	. 
	nop			;2550	00 	. 
	nop			;2551	00 	. 
	nop			;2552	00 	. 
	nop			;2553	00 	. 
	nop			;2554	00 	. 
	nop			;2555	00 	. 
	nop			;2556	00 	. 
	nop			;2557	00 	. 
	nop			;2558	00 	. 
	nop			;2559	00 	. 
	nop			;255a	00 	. 
	nop			;255b	00 	. 
	nop			;255c	00 	. 
	nop			;255d	00 	. 
	nop			;255e	00 	. 
	nop			;255f	00 	. 
	nop			;2560	00 	. 
	nop			;2561	00 	. 
	nop			;2562	00 	. 
	nop			;2563	00 	. 
	nop			;2564	00 	. 
	nop			;2565	00 	. 
	nop			;2566	00 	. 
	nop			;2567	00 	. 
	nop			;2568	00 	. 
	nop			;2569	00 	. 
	nop			;256a	00 	. 
	nop			;256b	00 	. 
	nop			;256c	00 	. 
	nop			;256d	00 	. 
	nop			;256e	00 	. 
	nop			;256f	00 	. 
	nop			;2570	00 	. 
	nop			;2571	00 	. 
	nop			;2572	00 	. 
	nop			;2573	00 	. 
	nop			;2574	00 	. 
	nop			;2575	00 	. 
	nop			;2576	00 	. 
	nop			;2577	00 	. 
	nop			;2578	00 	. 
	nop			;2579	00 	. 
	nop			;257a	00 	. 
	nop			;257b	00 	. 
	nop			;257c	00 	. 
	nop			;257d	00 	. 
	nop			;257e	00 	. 
	nop			;257f	00 	. 
	nop			;2580	00 	. 
	nop			;2581	00 	. 
	nop			;2582	00 	. 
	nop			;2583	00 	. 
	nop			;2584	00 	. 
	nop			;2585	00 	. 
	nop			;2586	00 	. 
	nop			;2587	00 	. 
	nop			;2588	00 	. 
	nop			;2589	00 	. 
	nop			;258a	00 	. 
	nop			;258b	00 	. 
	nop			;258c	00 	. 
	nop			;258d	00 	. 
	nop			;258e	00 	. 
	nop			;258f	00 	. 
	nop			;2590	00 	. 
	nop			;2591	00 	. 
	nop			;2592	00 	. 
	nop			;2593	00 	. 
	nop			;2594	00 	. 
	nop			;2595	00 	. 
	nop			;2596	00 	. 
	nop			;2597	00 	. 
	nop			;2598	00 	. 
	nop			;2599	00 	. 
	nop			;259a	00 	. 
	nop			;259b	00 	. 
	nop			;259c	00 	. 
	nop			;259d	00 	. 
	nop			;259e	00 	. 
	nop			;259f	00 	. 
	nop			;25a0	00 	. 
	nop			;25a1	00 	. 
	nop			;25a2	00 	. 
	nop			;25a3	00 	. 
	nop			;25a4	00 	. 
	nop			;25a5	00 	. 
	nop			;25a6	00 	. 
	nop			;25a7	00 	. 
	nop			;25a8	00 	. 
	nop			;25a9	00 	. 
	nop			;25aa	00 	. 
	nop			;25ab	00 	. 
	nop			;25ac	00 	. 
	nop			;25ad	00 	. 
	nop			;25ae	00 	. 
	nop			;25af	00 	. 
	nop			;25b0	00 	. 
	nop			;25b1	00 	. 
	nop			;25b2	00 	. 
	nop			;25b3	00 	. 
	nop			;25b4	00 	. 
	nop			;25b5	00 	. 
	nop			;25b6	00 	. 
	nop			;25b7	00 	. 
	nop			;25b8	00 	. 
	nop			;25b9	00 	. 
	nop			;25ba	00 	. 
	nop			;25bb	00 	. 
	nop			;25bc	00 	. 
	nop			;25bd	00 	. 
	nop			;25be	00 	. 
	nop			;25bf	00 	. 
	nop			;25c0	00 	. 
	nop			;25c1	00 	. 
	nop			;25c2	00 	. 
	nop			;25c3	00 	. 
	nop			;25c4	00 	. 
	nop			;25c5	00 	. 
	nop			;25c6	00 	. 
	nop			;25c7	00 	. 
	nop			;25c8	00 	. 
	nop			;25c9	00 	. 
	nop			;25ca	00 	. 
	nop			;25cb	00 	. 
	nop			;25cc	00 	. 
	nop			;25cd	00 	. 
	nop			;25ce	00 	. 
	nop			;25cf	00 	. 
	nop			;25d0	00 	. 
	nop			;25d1	00 	. 
	nop			;25d2	00 	. 
	nop			;25d3	00 	. 
	nop			;25d4	00 	. 
	nop			;25d5	00 	. 
	nop			;25d6	00 	. 
	nop			;25d7	00 	. 
	nop			;25d8	00 	. 
	nop			;25d9	00 	. 
	nop			;25da	00 	. 
	nop			;25db	00 	. 
	nop			;25dc	00 	. 
	nop			;25dd	00 	. 
	nop			;25de	00 	. 
	nop			;25df	00 	. 
	nop			;25e0	00 	. 
	nop			;25e1	00 	. 
	nop			;25e2	00 	. 
	nop			;25e3	00 	. 
	nop			;25e4	00 	. 
	nop			;25e5	00 	. 
	nop			;25e6	00 	. 
	nop			;25e7	00 	. 
	nop			;25e8	00 	. 
	nop			;25e9	00 	. 
	nop			;25ea	00 	. 
	nop			;25eb	00 	. 
	nop			;25ec	00 	. 
	nop			;25ed	00 	. 
	nop			;25ee	00 	. 
	nop			;25ef	00 	. 
	nop			;25f0	00 	. 
	nop			;25f1	00 	. 
	nop			;25f2	00 	. 
	nop			;25f3	00 	. 
	nop			;25f4	00 	. 
	nop			;25f5	00 	. 
	nop			;25f6	00 	. 
	nop			;25f7	00 	. 
	nop			;25f8	00 	. 
	nop			;25f9	00 	. 
	nop			;25fa	00 	. 
	nop			;25fb	00 	. 
	nop			;25fc	00 	. 
	nop			;25fd	00 	. 
	nop			;25fe	00 	. 
	nop			;25ff	00 	. 
	nop			;2600	00 	. 
	nop			;2601	00 	. 
	nop			;2602	00 	. 
	nop			;2603	00 	. 
	nop			;2604	00 	. 
	nop			;2605	00 	. 
	nop			;2606	00 	. 
	nop			;2607	00 	. 
	nop			;2608	00 	. 
	nop			;2609	00 	. 
	nop			;260a	00 	. 
	nop			;260b	00 	. 
	nop			;260c	00 	. 
	nop			;260d	00 	. 
	nop			;260e	00 	. 
	nop			;260f	00 	. 
	nop			;2610	00 	. 
	nop			;2611	00 	. 
	nop			;2612	00 	. 
	nop			;2613	00 	. 
	nop			;2614	00 	. 
	nop			;2615	00 	. 
	nop			;2616	00 	. 
	nop			;2617	00 	. 
	nop			;2618	00 	. 
	nop			;2619	00 	. 
	nop			;261a	00 	. 
	nop			;261b	00 	. 
	nop			;261c	00 	. 
	nop			;261d	00 	. 
	nop			;261e	00 	. 
	nop			;261f	00 	. 
	nop			;2620	00 	. 
	nop			;2621	00 	. 
	nop			;2622	00 	. 
	nop			;2623	00 	. 
	nop			;2624	00 	. 
	nop			;2625	00 	. 
	nop			;2626	00 	. 
	nop			;2627	00 	. 
	nop			;2628	00 	. 
	nop			;2629	00 	. 
	nop			;262a	00 	. 
	nop			;262b	00 	. 
	nop			;262c	00 	. 
	nop			;262d	00 	. 
	nop			;262e	00 	. 
	nop			;262f	00 	. 
	nop			;2630	00 	. 
	nop			;2631	00 	. 
	nop			;2632	00 	. 
	nop			;2633	00 	. 
	nop			;2634	00 	. 
	nop			;2635	00 	. 
	nop			;2636	00 	. 
	nop			;2637	00 	. 
	nop			;2638	00 	. 
	nop			;2639	00 	. 
	nop			;263a	00 	. 
	nop			;263b	00 	. 
	nop			;263c	00 	. 
	nop			;263d	00 	. 
	nop			;263e	00 	. 
	nop			;263f	00 	. 
	nop			;2640	00 	. 
	nop			;2641	00 	. 
	nop			;2642	00 	. 
	nop			;2643	00 	. 
	nop			;2644	00 	. 
	nop			;2645	00 	. 
	nop			;2646	00 	. 
	nop			;2647	00 	. 
	nop			;2648	00 	. 
	nop			;2649	00 	. 
	nop			;264a	00 	. 
	nop			;264b	00 	. 
	nop			;264c	00 	. 
	nop			;264d	00 	. 
	nop			;264e	00 	. 
	nop			;264f	00 	. 
	nop			;2650	00 	. 
	nop			;2651	00 	. 
	nop			;2652	00 	. 
	nop			;2653	00 	. 
	nop			;2654	00 	. 
	nop			;2655	00 	. 
	nop			;2656	00 	. 
	nop			;2657	00 	. 
	nop			;2658	00 	. 
	nop			;2659	00 	. 
	nop			;265a	00 	. 
	nop			;265b	00 	. 
	nop			;265c	00 	. 
	nop			;265d	00 	. 
	nop			;265e	00 	. 
	nop			;265f	00 	. 
	nop			;2660	00 	. 
	nop			;2661	00 	. 
	nop			;2662	00 	. 
	nop			;2663	00 	. 
	nop			;2664	00 	. 
	nop			;2665	00 	. 
	nop			;2666	00 	. 
	nop			;2667	00 	. 
	nop			;2668	00 	. 
	nop			;2669	00 	. 
	nop			;266a	00 	. 
	nop			;266b	00 	. 
	nop			;266c	00 	. 
	nop			;266d	00 	. 
	nop			;266e	00 	. 
	nop			;266f	00 	. 
	nop			;2670	00 	. 
	nop			;2671	00 	. 
	nop			;2672	00 	. 
	nop			;2673	00 	. 
	nop			;2674	00 	. 
	nop			;2675	00 	. 
	nop			;2676	00 	. 
	nop			;2677	00 	. 
	nop			;2678	00 	. 
	nop			;2679	00 	. 
	nop			;267a	00 	. 
	nop			;267b	00 	. 
	nop			;267c	00 	. 
	nop			;267d	00 	. 
	nop			;267e	00 	. 
	nop			;267f	00 	. 
	nop			;2680	00 	. 
	nop			;2681	00 	. 
	nop			;2682	00 	. 
	nop			;2683	00 	. 
	nop			;2684	00 	. 
	nop			;2685	00 	. 
	nop			;2686	00 	. 
	nop			;2687	00 	. 
	nop			;2688	00 	. 
	nop			;2689	00 	. 
	nop			;268a	00 	. 
	nop			;268b	00 	. 
	nop			;268c	00 	. 
	nop			;268d	00 	. 
	nop			;268e	00 	. 
	nop			;268f	00 	. 
	nop			;2690	00 	. 
	nop			;2691	00 	. 
	nop			;2692	00 	. 
	nop			;2693	00 	. 
	nop			;2694	00 	. 
	nop			;2695	00 	. 
	nop			;2696	00 	. 
	nop			;2697	00 	. 
	nop			;2698	00 	. 
	nop			;2699	00 	. 
	nop			;269a	00 	. 
	nop			;269b	00 	. 
	nop			;269c	00 	. 
	nop			;269d	00 	. 
	nop			;269e	00 	. 
	nop			;269f	00 	. 
	nop			;26a0	00 	. 
	nop			;26a1	00 	. 
	nop			;26a2	00 	. 
	nop			;26a3	00 	. 
	nop			;26a4	00 	. 
	nop			;26a5	00 	. 
	nop			;26a6	00 	. 
	nop			;26a7	00 	. 
	nop			;26a8	00 	. 
	nop			;26a9	00 	. 
	nop			;26aa	00 	. 
	nop			;26ab	00 	. 
	nop			;26ac	00 	. 
	nop			;26ad	00 	. 
	nop			;26ae	00 	. 
	nop			;26af	00 	. 
	nop			;26b0	00 	. 
	nop			;26b1	00 	. 
	nop			;26b2	00 	. 
	nop			;26b3	00 	. 
	nop			;26b4	00 	. 
	nop			;26b5	00 	. 
	nop			;26b6	00 	. 
	nop			;26b7	00 	. 
	nop			;26b8	00 	. 
	nop			;26b9	00 	. 
	nop			;26ba	00 	. 
	nop			;26bb	00 	. 
	nop			;26bc	00 	. 
	nop			;26bd	00 	. 
	nop			;26be	00 	. 
	nop			;26bf	00 	. 
	nop			;26c0	00 	. 
	nop			;26c1	00 	. 
	nop			;26c2	00 	. 
	nop			;26c3	00 	. 
	nop			;26c4	00 	. 
	nop			;26c5	00 	. 
	nop			;26c6	00 	. 
	nop			;26c7	00 	. 
	nop			;26c8	00 	. 
	nop			;26c9	00 	. 
	nop			;26ca	00 	. 
	nop			;26cb	00 	. 
	nop			;26cc	00 	. 
	nop			;26cd	00 	. 
	nop			;26ce	00 	. 
	nop			;26cf	00 	. 
	nop			;26d0	00 	. 
	nop			;26d1	00 	. 
	nop			;26d2	00 	. 
	nop			;26d3	00 	. 
	nop			;26d4	00 	. 
	nop			;26d5	00 	. 
	nop			;26d6	00 	. 
	nop			;26d7	00 	. 
	nop			;26d8	00 	. 
	nop			;26d9	00 	. 
	nop			;26da	00 	. 
	nop			;26db	00 	. 
	nop			;26dc	00 	. 
	nop			;26dd	00 	. 
	nop			;26de	00 	. 
	nop			;26df	00 	. 
	nop			;26e0	00 	. 
	nop			;26e1	00 	. 
	nop			;26e2	00 	. 
	nop			;26e3	00 	. 
	nop			;26e4	00 	. 
	nop			;26e5	00 	. 
	nop			;26e6	00 	. 
	nop			;26e7	00 	. 
	nop			;26e8	00 	. 
	nop			;26e9	00 	. 
	nop			;26ea	00 	. 
	nop			;26eb	00 	. 
	nop			;26ec	00 	. 
	nop			;26ed	00 	. 
	nop			;26ee	00 	. 
	nop			;26ef	00 	. 
	nop			;26f0	00 	. 
	nop			;26f1	00 	. 
	nop			;26f2	00 	. 
	nop			;26f3	00 	. 
	nop			;26f4	00 	. 
	nop			;26f5	00 	. 
	nop			;26f6	00 	. 
	nop			;26f7	00 	. 
	nop			;26f8	00 	. 
	nop			;26f9	00 	. 
	nop			;26fa	00 	. 
	nop			;26fb	00 	. 
	nop			;26fc	00 	. 
	nop			;26fd	00 	. 
	nop			;26fe	00 	. 
	nop			;26ff	00 	. 
	nop			;2700	00 	. 
	nop			;2701	00 	. 
	nop			;2702	00 	. 
	nop			;2703	00 	. 
	nop			;2704	00 	. 
	nop			;2705	00 	. 
	nop			;2706	00 	. 
	nop			;2707	00 	. 
	nop			;2708	00 	. 
	nop			;2709	00 	. 
	nop			;270a	00 	. 
	nop			;270b	00 	. 
	nop			;270c	00 	. 
	nop			;270d	00 	. 
	nop			;270e	00 	. 
	nop			;270f	00 	. 
	nop			;2710	00 	. 
	nop			;2711	00 	. 
	nop			;2712	00 	. 
	nop			;2713	00 	. 
	nop			;2714	00 	. 
	nop			;2715	00 	. 
	nop			;2716	00 	. 
	nop			;2717	00 	. 
	nop			;2718	00 	. 
	nop			;2719	00 	. 
	nop			;271a	00 	. 
	nop			;271b	00 	. 
	nop			;271c	00 	. 
	nop			;271d	00 	. 
	nop			;271e	00 	. 
	nop			;271f	00 	. 
	nop			;2720	00 	. 
	nop			;2721	00 	. 
	nop			;2722	00 	. 
	nop			;2723	00 	. 
	nop			;2724	00 	. 
	nop			;2725	00 	. 
	nop			;2726	00 	. 
	nop			;2727	00 	. 
	nop			;2728	00 	. 
	nop			;2729	00 	. 
	nop			;272a	00 	. 
	nop			;272b	00 	. 
	nop			;272c	00 	. 
	nop			;272d	00 	. 
	nop			;272e	00 	. 
	nop			;272f	00 	. 
	nop			;2730	00 	. 
	nop			;2731	00 	. 
	nop			;2732	00 	. 
	nop			;2733	00 	. 
	nop			;2734	00 	. 
	nop			;2735	00 	. 
	nop			;2736	00 	. 
	nop			;2737	00 	. 
	nop			;2738	00 	. 
	nop			;2739	00 	. 
	nop			;273a	00 	. 
	nop			;273b	00 	. 
	nop			;273c	00 	. 
	nop			;273d	00 	. 
	nop			;273e	00 	. 
	nop			;273f	00 	. 
	nop			;2740	00 	. 
	nop			;2741	00 	. 
	nop			;2742	00 	. 
	nop			;2743	00 	. 
	nop			;2744	00 	. 
	nop			;2745	00 	. 
	nop			;2746	00 	. 
	nop			;2747	00 	. 
	nop			;2748	00 	. 
	nop			;2749	00 	. 
	nop			;274a	00 	. 
	nop			;274b	00 	. 
	nop			;274c	00 	. 
	nop			;274d	00 	. 
	nop			;274e	00 	. 
	nop			;274f	00 	. 
	nop			;2750	00 	. 
	nop			;2751	00 	. 
	nop			;2752	00 	. 
	nop			;2753	00 	. 
	nop			;2754	00 	. 
	nop			;2755	00 	. 
	nop			;2756	00 	. 
	nop			;2757	00 	. 
	nop			;2758	00 	. 
	nop			;2759	00 	. 
	nop			;275a	00 	. 
	nop			;275b	00 	. 
	nop			;275c	00 	. 
	nop			;275d	00 	. 
	nop			;275e	00 	. 
	nop			;275f	00 	. 
	nop			;2760	00 	. 
	nop			;2761	00 	. 
	nop			;2762	00 	. 
	nop			;2763	00 	. 
	nop			;2764	00 	. 
	nop			;2765	00 	. 
	nop			;2766	00 	. 
	nop			;2767	00 	. 
	nop			;2768	00 	. 
	nop			;2769	00 	. 
	nop			;276a	00 	. 
	nop			;276b	00 	. 
	nop			;276c	00 	. 
	nop			;276d	00 	. 
	nop			;276e	00 	. 
	nop			;276f	00 	. 
	nop			;2770	00 	. 
	nop			;2771	00 	. 
	nop			;2772	00 	. 
	nop			;2773	00 	. 
	nop			;2774	00 	. 
	nop			;2775	00 	. 
	nop			;2776	00 	. 
	nop			;2777	00 	. 
	nop			;2778	00 	. 
	nop			;2779	00 	. 
	nop			;277a	00 	. 
	nop			;277b	00 	. 
	nop			;277c	00 	. 
	nop			;277d	00 	. 
	nop			;277e	00 	. 
	nop			;277f	00 	. 
	nop			;2780	00 	. 
	nop			;2781	00 	. 
	nop			;2782	00 	. 
	nop			;2783	00 	. 
	nop			;2784	00 	. 
	nop			;2785	00 	. 
	nop			;2786	00 	. 
	nop			;2787	00 	. 
	nop			;2788	00 	. 
	nop			;2789	00 	. 
	nop			;278a	00 	. 
	nop			;278b	00 	. 
	nop			;278c	00 	. 
	nop			;278d	00 	. 
	nop			;278e	00 	. 
	nop			;278f	00 	. 
	nop			;2790	00 	. 
	nop			;2791	00 	. 
	nop			;2792	00 	. 
	nop			;2793	00 	. 
	nop			;2794	00 	. 
	nop			;2795	00 	. 
	nop			;2796	00 	. 
	nop			;2797	00 	. 
	nop			;2798	00 	. 
	nop			;2799	00 	. 
	nop			;279a	00 	. 
	nop			;279b	00 	. 
	nop			;279c	00 	. 
	nop			;279d	00 	. 
	nop			;279e	00 	. 
	nop			;279f	00 	. 
	nop			;27a0	00 	. 
	nop			;27a1	00 	. 
	nop			;27a2	00 	. 
	nop			;27a3	00 	. 
	nop			;27a4	00 	. 
	nop			;27a5	00 	. 
	nop			;27a6	00 	. 
	nop			;27a7	00 	. 
	nop			;27a8	00 	. 
	nop			;27a9	00 	. 
	nop			;27aa	00 	. 
	nop			;27ab	00 	. 
	nop			;27ac	00 	. 
	nop			;27ad	00 	. 
	nop			;27ae	00 	. 
	nop			;27af	00 	. 
	nop			;27b0	00 	. 
	nop			;27b1	00 	. 
	nop			;27b2	00 	. 
	nop			;27b3	00 	. 
	nop			;27b4	00 	. 
	nop			;27b5	00 	. 
	nop			;27b6	00 	. 
	nop			;27b7	00 	. 
	nop			;27b8	00 	. 
	nop			;27b9	00 	. 
	nop			;27ba	00 	. 
	nop			;27bb	00 	. 
	nop			;27bc	00 	. 
	nop			;27bd	00 	. 
	nop			;27be	00 	. 
	nop			;27bf	00 	. 
	nop			;27c0	00 	. 
	nop			;27c1	00 	. 
	nop			;27c2	00 	. 
	nop			;27c3	00 	. 
	nop			;27c4	00 	. 
	nop			;27c5	00 	. 
	nop			;27c6	00 	. 
	nop			;27c7	00 	. 
	nop			;27c8	00 	. 
	nop			;27c9	00 	. 
	nop			;27ca	00 	. 
	nop			;27cb	00 	. 
	nop			;27cc	00 	. 
	nop			;27cd	00 	. 
	nop			;27ce	00 	. 
	nop			;27cf	00 	. 
	nop			;27d0	00 	. 
	nop			;27d1	00 	. 
	nop			;27d2	00 	. 
	nop			;27d3	00 	. 
	nop			;27d4	00 	. 
	nop			;27d5	00 	. 
	nop			;27d6	00 	. 
	nop			;27d7	00 	. 
	nop			;27d8	00 	. 
	nop			;27d9	00 	. 
	nop			;27da	00 	. 
	nop			;27db	00 	. 
	nop			;27dc	00 	. 
	nop			;27dd	00 	. 
	nop			;27de	00 	. 
	nop			;27df	00 	. 
	nop			;27e0	00 	. 
	nop			;27e1	00 	. 
	nop			;27e2	00 	. 
	nop			;27e3	00 	. 
	nop			;27e4	00 	. 
	nop			;27e5	00 	. 
	nop			;27e6	00 	. 
	nop			;27e7	00 	. 
	nop			;27e8	00 	. 
	nop			;27e9	00 	. 
	nop			;27ea	00 	. 
	nop			;27eb	00 	. 
	nop			;27ec	00 	. 
	nop			;27ed	00 	. 
	nop			;27ee	00 	. 
	nop			;27ef	00 	. 
	nop			;27f0	00 	. 
	nop			;27f1	00 	. 
	nop			;27f2	00 	. 
	nop			;27f3	00 	. 
	nop			;27f4	00 	. 
	nop			;27f5	00 	. 
	nop			;27f6	00 	. 
	nop			;27f7	00 	. 
	nop			;27f8	00 	. 
	nop			;27f9	00 	. 
	nop			;27fa	00 	. 
	nop			;27fb	00 	. 
	nop			;27fc	00 	. 
	nop			;27fd	00 	. 
	nop			;27fe	00 	. 
	nop			;27ff	00 	. 
	nop			;2800	00 	. 
	nop			;2801	00 	. 
	nop			;2802	00 	. 
	nop			;2803	00 	. 
	nop			;2804	00 	. 
	nop			;2805	00 	. 
	nop			;2806	00 	. 
	nop			;2807	00 	. 
	nop			;2808	00 	. 
	nop			;2809	00 	. 
	nop			;280a	00 	. 
	nop			;280b	00 	. 
	nop			;280c	00 	. 
	nop			;280d	00 	. 
	nop			;280e	00 	. 
	nop			;280f	00 	. 
	nop			;2810	00 	. 
	nop			;2811	00 	. 
	nop			;2812	00 	. 
	nop			;2813	00 	. 
	nop			;2814	00 	. 
	nop			;2815	00 	. 
	nop			;2816	00 	. 
	nop			;2817	00 	. 
	nop			;2818	00 	. 
	nop			;2819	00 	. 
	nop			;281a	00 	. 
	nop			;281b	00 	. 
	nop			;281c	00 	. 
	nop			;281d	00 	. 
	nop			;281e	00 	. 
	nop			;281f	00 	. 
	nop			;2820	00 	. 
	nop			;2821	00 	. 
	nop			;2822	00 	. 
	nop			;2823	00 	. 
	nop			;2824	00 	. 
	nop			;2825	00 	. 
	nop			;2826	00 	. 
	nop			;2827	00 	. 
	nop			;2828	00 	. 
	nop			;2829	00 	. 
	nop			;282a	00 	. 
	nop			;282b	00 	. 
	nop			;282c	00 	. 
	nop			;282d	00 	. 
	nop			;282e	00 	. 
	nop			;282f	00 	. 
	nop			;2830	00 	. 
	nop			;2831	00 	. 
	nop			;2832	00 	. 
	nop			;2833	00 	. 
	nop			;2834	00 	. 
	nop			;2835	00 	. 
	nop			;2836	00 	. 
	nop			;2837	00 	. 
	nop			;2838	00 	. 
	nop			;2839	00 	. 
	nop			;283a	00 	. 
	nop			;283b	00 	. 
	nop			;283c	00 	. 
	nop			;283d	00 	. 
	nop			;283e	00 	. 
	nop			;283f	00 	. 
	nop			;2840	00 	. 
	nop			;2841	00 	. 
	nop			;2842	00 	. 
	nop			;2843	00 	. 
	nop			;2844	00 	. 
	nop			;2845	00 	. 
	nop			;2846	00 	. 
	nop			;2847	00 	. 
	nop			;2848	00 	. 
	nop			;2849	00 	. 
	nop			;284a	00 	. 
	nop			;284b	00 	. 
	nop			;284c	00 	. 
	nop			;284d	00 	. 
	nop			;284e	00 	. 
	nop			;284f	00 	. 
	nop			;2850	00 	. 
	nop			;2851	00 	. 
	nop			;2852	00 	. 
	nop			;2853	00 	. 
	nop			;2854	00 	. 
	nop			;2855	00 	. 
	nop			;2856	00 	. 
	nop			;2857	00 	. 
	nop			;2858	00 	. 
	nop			;2859	00 	. 
	nop			;285a	00 	. 
	nop			;285b	00 	. 
	nop			;285c	00 	. 
	nop			;285d	00 	. 
	nop			;285e	00 	. 
	nop			;285f	00 	. 
	nop			;2860	00 	. 
	nop			;2861	00 	. 
	nop			;2862	00 	. 
	nop			;2863	00 	. 
	nop			;2864	00 	. 
	nop			;2865	00 	. 
	nop			;2866	00 	. 
	nop			;2867	00 	. 
	nop			;2868	00 	. 
	nop			;2869	00 	. 
	nop			;286a	00 	. 
	nop			;286b	00 	. 
	nop			;286c	00 	. 
	nop			;286d	00 	. 
	nop			;286e	00 	. 
	nop			;286f	00 	. 
	nop			;2870	00 	. 
	nop			;2871	00 	. 
	nop			;2872	00 	. 
	nop			;2873	00 	. 
	nop			;2874	00 	. 
	nop			;2875	00 	. 
	nop			;2876	00 	. 
	nop			;2877	00 	. 
	nop			;2878	00 	. 
	nop			;2879	00 	. 
	nop			;287a	00 	. 
	nop			;287b	00 	. 
	nop			;287c	00 	. 
	nop			;287d	00 	. 
	nop			;287e	00 	. 
	nop			;287f	00 	. 
	nop			;2880	00 	. 
	nop			;2881	00 	. 
	nop			;2882	00 	. 
	nop			;2883	00 	. 
	nop			;2884	00 	. 
	nop			;2885	00 	. 
	nop			;2886	00 	. 
	nop			;2887	00 	. 
	nop			;2888	00 	. 
	nop			;2889	00 	. 
	nop			;288a	00 	. 
	nop			;288b	00 	. 
	nop			;288c	00 	. 
	nop			;288d	00 	. 
	nop			;288e	00 	. 
	nop			;288f	00 	. 
	nop			;2890	00 	. 
	nop			;2891	00 	. 
	nop			;2892	00 	. 
	nop			;2893	00 	. 
	nop			;2894	00 	. 
	nop			;2895	00 	. 
	nop			;2896	00 	. 
	nop			;2897	00 	. 
	nop			;2898	00 	. 
	nop			;2899	00 	. 
	nop			;289a	00 	. 
	nop			;289b	00 	. 
	nop			;289c	00 	. 
	nop			;289d	00 	. 
	nop			;289e	00 	. 
	nop			;289f	00 	. 
	nop			;28a0	00 	. 
	nop			;28a1	00 	. 
	nop			;28a2	00 	. 
	nop			;28a3	00 	. 
	nop			;28a4	00 	. 
	nop			;28a5	00 	. 
	nop			;28a6	00 	. 
	nop			;28a7	00 	. 
	nop			;28a8	00 	. 
	nop			;28a9	00 	. 
	nop			;28aa	00 	. 
	nop			;28ab	00 	. 
	nop			;28ac	00 	. 
	nop			;28ad	00 	. 
	nop			;28ae	00 	. 
	nop			;28af	00 	. 
	nop			;28b0	00 	. 
	nop			;28b1	00 	. 
	nop			;28b2	00 	. 
	nop			;28b3	00 	. 
	nop			;28b4	00 	. 
	nop			;28b5	00 	. 
	nop			;28b6	00 	. 
	nop			;28b7	00 	. 
	nop			;28b8	00 	. 
	nop			;28b9	00 	. 
	nop			;28ba	00 	. 
	nop			;28bb	00 	. 
	nop			;28bc	00 	. 
	nop			;28bd	00 	. 
	nop			;28be	00 	. 
	nop			;28bf	00 	. 
	nop			;28c0	00 	. 
	nop			;28c1	00 	. 
	nop			;28c2	00 	. 
	nop			;28c3	00 	. 
	nop			;28c4	00 	. 
	nop			;28c5	00 	. 
	nop			;28c6	00 	. 
	nop			;28c7	00 	. 
	nop			;28c8	00 	. 
	nop			;28c9	00 	. 
	nop			;28ca	00 	. 
	nop			;28cb	00 	. 
	nop			;28cc	00 	. 
	nop			;28cd	00 	. 
	nop			;28ce	00 	. 
	nop			;28cf	00 	. 
	nop			;28d0	00 	. 
	nop			;28d1	00 	. 
	nop			;28d2	00 	. 
	nop			;28d3	00 	. 
	nop			;28d4	00 	. 
	nop			;28d5	00 	. 
	nop			;28d6	00 	. 
	nop			;28d7	00 	. 
	nop			;28d8	00 	. 
	nop			;28d9	00 	. 
	nop			;28da	00 	. 
	nop			;28db	00 	. 
	nop			;28dc	00 	. 
	nop			;28dd	00 	. 
	nop			;28de	00 	. 
	nop			;28df	00 	. 
	nop			;28e0	00 	. 
	nop			;28e1	00 	. 
	nop			;28e2	00 	. 
	nop			;28e3	00 	. 
	nop			;28e4	00 	. 
	nop			;28e5	00 	. 
	nop			;28e6	00 	. 
	nop			;28e7	00 	. 
	nop			;28e8	00 	. 
	nop			;28e9	00 	. 
	nop			;28ea	00 	. 
	nop			;28eb	00 	. 
	nop			;28ec	00 	. 
	nop			;28ed	00 	. 
	nop			;28ee	00 	. 
	nop			;28ef	00 	. 
	nop			;28f0	00 	. 
	nop			;28f1	00 	. 
	nop			;28f2	00 	. 
	nop			;28f3	00 	. 
	nop			;28f4	00 	. 
	nop			;28f5	00 	. 
	nop			;28f6	00 	. 
	nop			;28f7	00 	. 
	nop			;28f8	00 	. 
	nop			;28f9	00 	. 
	nop			;28fa	00 	. 
	nop			;28fb	00 	. 
	nop			;28fc	00 	. 
	nop			;28fd	00 	. 
	nop			;28fe	00 	. 
	nop			;28ff	00 	. 
	nop			;2900	00 	. 
	nop			;2901	00 	. 
	nop			;2902	00 	. 
	nop			;2903	00 	. 
	nop			;2904	00 	. 
	nop			;2905	00 	. 
	nop			;2906	00 	. 
	nop			;2907	00 	. 
	nop			;2908	00 	. 
	nop			;2909	00 	. 
	nop			;290a	00 	. 
	nop			;290b	00 	. 
	nop			;290c	00 	. 
	nop			;290d	00 	. 
	nop			;290e	00 	. 
	nop			;290f	00 	. 
	nop			;2910	00 	. 
	nop			;2911	00 	. 
	nop			;2912	00 	. 
	nop			;2913	00 	. 
	nop			;2914	00 	. 
	nop			;2915	00 	. 
	nop			;2916	00 	. 
	nop			;2917	00 	. 
	nop			;2918	00 	. 
	nop			;2919	00 	. 
	nop			;291a	00 	. 
	nop			;291b	00 	. 
	nop			;291c	00 	. 
	nop			;291d	00 	. 
	nop			;291e	00 	. 
	nop			;291f	00 	. 
	nop			;2920	00 	. 
	nop			;2921	00 	. 
	nop			;2922	00 	. 
	nop			;2923	00 	. 
	nop			;2924	00 	. 
	nop			;2925	00 	. 
	nop			;2926	00 	. 
	nop			;2927	00 	. 
	nop			;2928	00 	. 
	nop			;2929	00 	. 
	nop			;292a	00 	. 
	nop			;292b	00 	. 
	nop			;292c	00 	. 
	nop			;292d	00 	. 
	nop			;292e	00 	. 
	nop			;292f	00 	. 
	nop			;2930	00 	. 
	nop			;2931	00 	. 
	nop			;2932	00 	. 
	nop			;2933	00 	. 
	nop			;2934	00 	. 
	nop			;2935	00 	. 
	nop			;2936	00 	. 
	nop			;2937	00 	. 
	nop			;2938	00 	. 
	nop			;2939	00 	. 
	nop			;293a	00 	. 
	nop			;293b	00 	. 
	nop			;293c	00 	. 
	nop			;293d	00 	. 
	nop			;293e	00 	. 
	nop			;293f	00 	. 
	nop			;2940	00 	. 
	nop			;2941	00 	. 
	nop			;2942	00 	. 
	nop			;2943	00 	. 
	nop			;2944	00 	. 
	nop			;2945	00 	. 
	nop			;2946	00 	. 
	nop			;2947	00 	. 
	nop			;2948	00 	. 
	nop			;2949	00 	. 
	nop			;294a	00 	. 
	nop			;294b	00 	. 
	nop			;294c	00 	. 
	nop			;294d	00 	. 
	nop			;294e	00 	. 
	nop			;294f	00 	. 
	nop			;2950	00 	. 
	nop			;2951	00 	. 
	nop			;2952	00 	. 
	nop			;2953	00 	. 
	nop			;2954	00 	. 
	nop			;2955	00 	. 
	nop			;2956	00 	. 
	nop			;2957	00 	. 
	nop			;2958	00 	. 
	nop			;2959	00 	. 
	nop			;295a	00 	. 
	nop			;295b	00 	. 
	nop			;295c	00 	. 
	nop			;295d	00 	. 
	nop			;295e	00 	. 
	nop			;295f	00 	. 
	nop			;2960	00 	. 
	nop			;2961	00 	. 
	nop			;2962	00 	. 
	nop			;2963	00 	. 
	nop			;2964	00 	. 
	nop			;2965	00 	. 
	nop			;2966	00 	. 
	nop			;2967	00 	. 
	nop			;2968	00 	. 
	nop			;2969	00 	. 
	nop			;296a	00 	. 
	nop			;296b	00 	. 
	nop			;296c	00 	. 
	nop			;296d	00 	. 
	nop			;296e	00 	. 
	nop			;296f	00 	. 
	nop			;2970	00 	. 
	nop			;2971	00 	. 
	nop			;2972	00 	. 
	nop			;2973	00 	. 
	nop			;2974	00 	. 
	nop			;2975	00 	. 
	nop			;2976	00 	. 
	nop			;2977	00 	. 
	nop			;2978	00 	. 
	nop			;2979	00 	. 
	nop			;297a	00 	. 
	nop			;297b	00 	. 
	nop			;297c	00 	. 
	nop			;297d	00 	. 
	nop			;297e	00 	. 
	nop			;297f	00 	. 
	nop			;2980	00 	. 
	nop			;2981	00 	. 
	nop			;2982	00 	. 
	nop			;2983	00 	. 
	nop			;2984	00 	. 
	nop			;2985	00 	. 
	nop			;2986	00 	. 
	nop			;2987	00 	. 
	nop			;2988	00 	. 
	nop			;2989	00 	. 
	nop			;298a	00 	. 
	nop			;298b	00 	. 
	nop			;298c	00 	. 
	nop			;298d	00 	. 
	nop			;298e	00 	. 
	nop			;298f	00 	. 
	nop			;2990	00 	. 
	nop			;2991	00 	. 
	nop			;2992	00 	. 
	nop			;2993	00 	. 
	nop			;2994	00 	. 
	nop			;2995	00 	. 
	nop			;2996	00 	. 
	nop			;2997	00 	. 
	nop			;2998	00 	. 
	nop			;2999	00 	. 
	nop			;299a	00 	. 
	nop			;299b	00 	. 
	nop			;299c	00 	. 
	nop			;299d	00 	. 
	nop			;299e	00 	. 
	nop			;299f	00 	. 
	nop			;29a0	00 	. 
	nop			;29a1	00 	. 
	nop			;29a2	00 	. 
	nop			;29a3	00 	. 
	nop			;29a4	00 	. 
	nop			;29a5	00 	. 
	nop			;29a6	00 	. 
	nop			;29a7	00 	. 
	nop			;29a8	00 	. 
	nop			;29a9	00 	. 
	nop			;29aa	00 	. 
	nop			;29ab	00 	. 
	nop			;29ac	00 	. 
	nop			;29ad	00 	. 
	nop			;29ae	00 	. 
	nop			;29af	00 	. 
	nop			;29b0	00 	. 
	nop			;29b1	00 	. 
	nop			;29b2	00 	. 
	nop			;29b3	00 	. 
	nop			;29b4	00 	. 
	nop			;29b5	00 	. 
	nop			;29b6	00 	. 
	nop			;29b7	00 	. 
	nop			;29b8	00 	. 
	nop			;29b9	00 	. 
	nop			;29ba	00 	. 
	nop			;29bb	00 	. 
	nop			;29bc	00 	. 
	nop			;29bd	00 	. 
	nop			;29be	00 	. 
	nop			;29bf	00 	. 
	nop			;29c0	00 	. 
	nop			;29c1	00 	. 
	nop			;29c2	00 	. 
	nop			;29c3	00 	. 
	nop			;29c4	00 	. 
	nop			;29c5	00 	. 
	nop			;29c6	00 	. 
	nop			;29c7	00 	. 
	nop			;29c8	00 	. 
	nop			;29c9	00 	. 
	nop			;29ca	00 	. 
	nop			;29cb	00 	. 
	nop			;29cc	00 	. 
	nop			;29cd	00 	. 
	nop			;29ce	00 	. 
	nop			;29cf	00 	. 
	nop			;29d0	00 	. 
	nop			;29d1	00 	. 
	nop			;29d2	00 	. 
	nop			;29d3	00 	. 
	nop			;29d4	00 	. 
	nop			;29d5	00 	. 
	nop			;29d6	00 	. 
	nop			;29d7	00 	. 
	nop			;29d8	00 	. 
	nop			;29d9	00 	. 
	nop			;29da	00 	. 
	nop			;29db	00 	. 
	nop			;29dc	00 	. 
	nop			;29dd	00 	. 
	nop			;29de	00 	. 
	nop			;29df	00 	. 
	nop			;29e0	00 	. 
	nop			;29e1	00 	. 
	nop			;29e2	00 	. 
	nop			;29e3	00 	. 
	nop			;29e4	00 	. 
	nop			;29e5	00 	. 
	nop			;29e6	00 	. 
	nop			;29e7	00 	. 
	nop			;29e8	00 	. 
	nop			;29e9	00 	. 
	nop			;29ea	00 	. 
	nop			;29eb	00 	. 
	nop			;29ec	00 	. 
	nop			;29ed	00 	. 
	nop			;29ee	00 	. 
	nop			;29ef	00 	. 
	nop			;29f0	00 	. 
	nop			;29f1	00 	. 
	nop			;29f2	00 	. 
	nop			;29f3	00 	. 
	nop			;29f4	00 	. 
	nop			;29f5	00 	. 
	nop			;29f6	00 	. 
	nop			;29f7	00 	. 
	nop			;29f8	00 	. 
	nop			;29f9	00 	. 
	nop			;29fa	00 	. 
	nop			;29fb	00 	. 
	nop			;29fc	00 	. 
	nop			;29fd	00 	. 
	nop			;29fe	00 	. 
	nop			;29ff	00 	. 
	nop			;2a00	00 	. 
	nop			;2a01	00 	. 
	nop			;2a02	00 	. 
	nop			;2a03	00 	. 
	nop			;2a04	00 	. 
	nop			;2a05	00 	. 
	nop			;2a06	00 	. 
	nop			;2a07	00 	. 
	nop			;2a08	00 	. 
	nop			;2a09	00 	. 
	nop			;2a0a	00 	. 
	nop			;2a0b	00 	. 
	nop			;2a0c	00 	. 
	nop			;2a0d	00 	. 
	nop			;2a0e	00 	. 
	nop			;2a0f	00 	. 
	nop			;2a10	00 	. 
	nop			;2a11	00 	. 
	nop			;2a12	00 	. 
	nop			;2a13	00 	. 
	nop			;2a14	00 	. 
	nop			;2a15	00 	. 
	nop			;2a16	00 	. 
	nop			;2a17	00 	. 
	nop			;2a18	00 	. 
	nop			;2a19	00 	. 
	nop			;2a1a	00 	. 
	nop			;2a1b	00 	. 
	nop			;2a1c	00 	. 
	nop			;2a1d	00 	. 
	nop			;2a1e	00 	. 
	nop			;2a1f	00 	. 
	nop			;2a20	00 	. 
	nop			;2a21	00 	. 
	nop			;2a22	00 	. 
	nop			;2a23	00 	. 
	nop			;2a24	00 	. 
	nop			;2a25	00 	. 
	nop			;2a26	00 	. 
	nop			;2a27	00 	. 
	nop			;2a28	00 	. 
	nop			;2a29	00 	. 
	nop			;2a2a	00 	. 
	nop			;2a2b	00 	. 
	nop			;2a2c	00 	. 
	nop			;2a2d	00 	. 
	nop			;2a2e	00 	. 
	nop			;2a2f	00 	. 
	nop			;2a30	00 	. 
	nop			;2a31	00 	. 
	nop			;2a32	00 	. 
	nop			;2a33	00 	. 
	nop			;2a34	00 	. 
	nop			;2a35	00 	. 
	nop			;2a36	00 	. 
	nop			;2a37	00 	. 
	nop			;2a38	00 	. 
	nop			;2a39	00 	. 
	nop			;2a3a	00 	. 
	nop			;2a3b	00 	. 
	nop			;2a3c	00 	. 
	nop			;2a3d	00 	. 
	nop			;2a3e	00 	. 
	nop			;2a3f	00 	. 
	nop			;2a40	00 	. 
	nop			;2a41	00 	. 
	nop			;2a42	00 	. 
	nop			;2a43	00 	. 
	nop			;2a44	00 	. 
	nop			;2a45	00 	. 
	nop			;2a46	00 	. 
	nop			;2a47	00 	. 
	nop			;2a48	00 	. 
	nop			;2a49	00 	. 
	nop			;2a4a	00 	. 
	nop			;2a4b	00 	. 
	nop			;2a4c	00 	. 
	nop			;2a4d	00 	. 
	nop			;2a4e	00 	. 
	nop			;2a4f	00 	. 
	nop			;2a50	00 	. 
	nop			;2a51	00 	. 
	nop			;2a52	00 	. 
	nop			;2a53	00 	. 
	nop			;2a54	00 	. 
	nop			;2a55	00 	. 
	nop			;2a56	00 	. 
	nop			;2a57	00 	. 
	nop			;2a58	00 	. 
	nop			;2a59	00 	. 
	nop			;2a5a	00 	. 
	nop			;2a5b	00 	. 
	nop			;2a5c	00 	. 
	nop			;2a5d	00 	. 
	nop			;2a5e	00 	. 
	nop			;2a5f	00 	. 
	nop			;2a60	00 	. 
	nop			;2a61	00 	. 
	nop			;2a62	00 	. 
	nop			;2a63	00 	. 
	nop			;2a64	00 	. 
	nop			;2a65	00 	. 
	nop			;2a66	00 	. 
	nop			;2a67	00 	. 
	nop			;2a68	00 	. 
	nop			;2a69	00 	. 
	nop			;2a6a	00 	. 
	nop			;2a6b	00 	. 
	nop			;2a6c	00 	. 
	nop			;2a6d	00 	. 
	nop			;2a6e	00 	. 
	nop			;2a6f	00 	. 
	nop			;2a70	00 	. 
	nop			;2a71	00 	. 
	nop			;2a72	00 	. 
	nop			;2a73	00 	. 
	nop			;2a74	00 	. 
	nop			;2a75	00 	. 
	nop			;2a76	00 	. 
	nop			;2a77	00 	. 
	nop			;2a78	00 	. 
	nop			;2a79	00 	. 
	nop			;2a7a	00 	. 
	nop			;2a7b	00 	. 
	nop			;2a7c	00 	. 
	nop			;2a7d	00 	. 
	nop			;2a7e	00 	. 
	nop			;2a7f	00 	. 
	nop			;2a80	00 	. 
	nop			;2a81	00 	. 
	nop			;2a82	00 	. 
	nop			;2a83	00 	. 
	nop			;2a84	00 	. 
	nop			;2a85	00 	. 
	nop			;2a86	00 	. 
	nop			;2a87	00 	. 
	nop			;2a88	00 	. 
	nop			;2a89	00 	. 
	nop			;2a8a	00 	. 
	nop			;2a8b	00 	. 
	nop			;2a8c	00 	. 
	nop			;2a8d	00 	. 
	nop			;2a8e	00 	. 
	nop			;2a8f	00 	. 
	nop			;2a90	00 	. 
	nop			;2a91	00 	. 
	nop			;2a92	00 	. 
	nop			;2a93	00 	. 
	nop			;2a94	00 	. 
	nop			;2a95	00 	. 
	nop			;2a96	00 	. 
	nop			;2a97	00 	. 
	nop			;2a98	00 	. 
	nop			;2a99	00 	. 
	nop			;2a9a	00 	. 
	nop			;2a9b	00 	. 
	nop			;2a9c	00 	. 
	nop			;2a9d	00 	. 
	nop			;2a9e	00 	. 
	nop			;2a9f	00 	. 
	nop			;2aa0	00 	. 
	nop			;2aa1	00 	. 
	nop			;2aa2	00 	. 
	nop			;2aa3	00 	. 
	nop			;2aa4	00 	. 
	nop			;2aa5	00 	. 
	nop			;2aa6	00 	. 
	nop			;2aa7	00 	. 
	nop			;2aa8	00 	. 
	nop			;2aa9	00 	. 
	nop			;2aaa	00 	. 
	nop			;2aab	00 	. 
	nop			;2aac	00 	. 
	nop			;2aad	00 	. 
	nop			;2aae	00 	. 
	nop			;2aaf	00 	. 
	nop			;2ab0	00 	. 
	nop			;2ab1	00 	. 
	nop			;2ab2	00 	. 
	nop			;2ab3	00 	. 
	nop			;2ab4	00 	. 
	nop			;2ab5	00 	. 
	nop			;2ab6	00 	. 
	nop			;2ab7	00 	. 
	nop			;2ab8	00 	. 
	nop			;2ab9	00 	. 
	nop			;2aba	00 	. 
	nop			;2abb	00 	. 
	nop			;2abc	00 	. 
	nop			;2abd	00 	. 
	nop			;2abe	00 	. 
	nop			;2abf	00 	. 
	nop			;2ac0	00 	. 
	nop			;2ac1	00 	. 
	nop			;2ac2	00 	. 
	nop			;2ac3	00 	. 
	nop			;2ac4	00 	. 
	nop			;2ac5	00 	. 
	nop			;2ac6	00 	. 
	nop			;2ac7	00 	. 
	nop			;2ac8	00 	. 
	nop			;2ac9	00 	. 
	nop			;2aca	00 	. 
	nop			;2acb	00 	. 
	nop			;2acc	00 	. 
	nop			;2acd	00 	. 
	nop			;2ace	00 	. 
	nop			;2acf	00 	. 
	nop			;2ad0	00 	. 
	nop			;2ad1	00 	. 
	nop			;2ad2	00 	. 
	nop			;2ad3	00 	. 
	nop			;2ad4	00 	. 
	nop			;2ad5	00 	. 
	nop			;2ad6	00 	. 
	nop			;2ad7	00 	. 
	nop			;2ad8	00 	. 
	nop			;2ad9	00 	. 
	nop			;2ada	00 	. 
	nop			;2adb	00 	. 
	nop			;2adc	00 	. 
	nop			;2add	00 	. 
	nop			;2ade	00 	. 
	nop			;2adf	00 	. 
	nop			;2ae0	00 	. 
	nop			;2ae1	00 	. 
	nop			;2ae2	00 	. 
	nop			;2ae3	00 	. 
	nop			;2ae4	00 	. 
	nop			;2ae5	00 	. 
	nop			;2ae6	00 	. 
	nop			;2ae7	00 	. 
	nop			;2ae8	00 	. 
	nop			;2ae9	00 	. 
	nop			;2aea	00 	. 
	nop			;2aeb	00 	. 
	nop			;2aec	00 	. 
	nop			;2aed	00 	. 
	nop			;2aee	00 	. 
	nop			;2aef	00 	. 
	nop			;2af0	00 	. 
	nop			;2af1	00 	. 
	nop			;2af2	00 	. 
	nop			;2af3	00 	. 
	nop			;2af4	00 	. 
	nop			;2af5	00 	. 
	nop			;2af6	00 	. 
	nop			;2af7	00 	. 
	nop			;2af8	00 	. 
	nop			;2af9	00 	. 
	nop			;2afa	00 	. 
	nop			;2afb	00 	. 
	nop			;2afc	00 	. 
	nop			;2afd	00 	. 
	nop			;2afe	00 	. 
	nop			;2aff	00 	. 
	nop			;2b00	00 	. 
	nop			;2b01	00 	. 
	nop			;2b02	00 	. 
	nop			;2b03	00 	. 
	nop			;2b04	00 	. 
	nop			;2b05	00 	. 
	nop			;2b06	00 	. 
	nop			;2b07	00 	. 
	nop			;2b08	00 	. 
	nop			;2b09	00 	. 
	nop			;2b0a	00 	. 
	nop			;2b0b	00 	. 
	nop			;2b0c	00 	. 
	nop			;2b0d	00 	. 
	nop			;2b0e	00 	. 
	nop			;2b0f	00 	. 
	nop			;2b10	00 	. 
	nop			;2b11	00 	. 
	nop			;2b12	00 	. 
	nop			;2b13	00 	. 
	nop			;2b14	00 	. 
	nop			;2b15	00 	. 
	nop			;2b16	00 	. 
	nop			;2b17	00 	. 
	nop			;2b18	00 	. 
	nop			;2b19	00 	. 
	nop			;2b1a	00 	. 
	nop			;2b1b	00 	. 
	nop			;2b1c	00 	. 
	nop			;2b1d	00 	. 
	nop			;2b1e	00 	. 
	nop			;2b1f	00 	. 
	nop			;2b20	00 	. 
	nop			;2b21	00 	. 
	nop			;2b22	00 	. 
	nop			;2b23	00 	. 
	nop			;2b24	00 	. 
	nop			;2b25	00 	. 
	nop			;2b26	00 	. 
	nop			;2b27	00 	. 
	nop			;2b28	00 	. 
	nop			;2b29	00 	. 
	nop			;2b2a	00 	. 
	nop			;2b2b	00 	. 
	nop			;2b2c	00 	. 
	nop			;2b2d	00 	. 
	nop			;2b2e	00 	. 
	nop			;2b2f	00 	. 
	nop			;2b30	00 	. 
	nop			;2b31	00 	. 
	nop			;2b32	00 	. 
	nop			;2b33	00 	. 
	nop			;2b34	00 	. 
	nop			;2b35	00 	. 
	nop			;2b36	00 	. 
	nop			;2b37	00 	. 
	nop			;2b38	00 	. 
	nop			;2b39	00 	. 
	nop			;2b3a	00 	. 
	nop			;2b3b	00 	. 
	nop			;2b3c	00 	. 
	nop			;2b3d	00 	. 
	nop			;2b3e	00 	. 
	nop			;2b3f	00 	. 
	nop			;2b40	00 	. 
	nop			;2b41	00 	. 
	nop			;2b42	00 	. 
	nop			;2b43	00 	. 
	nop			;2b44	00 	. 
	nop			;2b45	00 	. 
	nop			;2b46	00 	. 
	nop			;2b47	00 	. 
	nop			;2b48	00 	. 
	nop			;2b49	00 	. 
	nop			;2b4a	00 	. 
	nop			;2b4b	00 	. 
	nop			;2b4c	00 	. 
	nop			;2b4d	00 	. 
	nop			;2b4e	00 	. 
	nop			;2b4f	00 	. 
	nop			;2b50	00 	. 
	nop			;2b51	00 	. 
	nop			;2b52	00 	. 
	nop			;2b53	00 	. 
	nop			;2b54	00 	. 
	nop			;2b55	00 	. 
	nop			;2b56	00 	. 
	nop			;2b57	00 	. 
	nop			;2b58	00 	. 
	nop			;2b59	00 	. 
	nop			;2b5a	00 	. 
	nop			;2b5b	00 	. 
	nop			;2b5c	00 	. 
	nop			;2b5d	00 	. 
	nop			;2b5e	00 	. 
	nop			;2b5f	00 	. 
	nop			;2b60	00 	. 
	nop			;2b61	00 	. 
	nop			;2b62	00 	. 
	nop			;2b63	00 	. 
	nop			;2b64	00 	. 
	nop			;2b65	00 	. 
	nop			;2b66	00 	. 
	nop			;2b67	00 	. 
	nop			;2b68	00 	. 
	nop			;2b69	00 	. 
	nop			;2b6a	00 	. 
	nop			;2b6b	00 	. 
	nop			;2b6c	00 	. 
	nop			;2b6d	00 	. 
	nop			;2b6e	00 	. 
	nop			;2b6f	00 	. 
	nop			;2b70	00 	. 
	nop			;2b71	00 	. 
	nop			;2b72	00 	. 
	nop			;2b73	00 	. 
	nop			;2b74	00 	. 
	nop			;2b75	00 	. 
	nop			;2b76	00 	. 
	nop			;2b77	00 	. 
	nop			;2b78	00 	. 
	nop			;2b79	00 	. 
	nop			;2b7a	00 	. 
	nop			;2b7b	00 	. 
	nop			;2b7c	00 	. 
	nop			;2b7d	00 	. 
	nop			;2b7e	00 	. 
	nop			;2b7f	00 	. 
	nop			;2b80	00 	. 
	nop			;2b81	00 	. 
	nop			;2b82	00 	. 
	nop			;2b83	00 	. 
	nop			;2b84	00 	. 
	nop			;2b85	00 	. 
	nop			;2b86	00 	. 
	nop			;2b87	00 	. 
	nop			;2b88	00 	. 
	nop			;2b89	00 	. 
	nop			;2b8a	00 	. 
	nop			;2b8b	00 	. 
	nop			;2b8c	00 	. 
	nop			;2b8d	00 	. 
	nop			;2b8e	00 	. 
	nop			;2b8f	00 	. 
	nop			;2b90	00 	. 
	nop			;2b91	00 	. 
	nop			;2b92	00 	. 
	nop			;2b93	00 	. 
	nop			;2b94	00 	. 
	nop			;2b95	00 	. 
	nop			;2b96	00 	. 
	nop			;2b97	00 	. 
	nop			;2b98	00 	. 
	nop			;2b99	00 	. 
	nop			;2b9a	00 	. 
	nop			;2b9b	00 	. 
	nop			;2b9c	00 	. 
	nop			;2b9d	00 	. 
	nop			;2b9e	00 	. 
	nop			;2b9f	00 	. 
	nop			;2ba0	00 	. 
	nop			;2ba1	00 	. 
	nop			;2ba2	00 	. 
	nop			;2ba3	00 	. 
	nop			;2ba4	00 	. 
	nop			;2ba5	00 	. 
	nop			;2ba6	00 	. 
	nop			;2ba7	00 	. 
	nop			;2ba8	00 	. 
	nop			;2ba9	00 	. 
	nop			;2baa	00 	. 
	nop			;2bab	00 	. 
	nop			;2bac	00 	. 
	nop			;2bad	00 	. 
	nop			;2bae	00 	. 
	nop			;2baf	00 	. 
	nop			;2bb0	00 	. 
	nop			;2bb1	00 	. 
	nop			;2bb2	00 	. 
	nop			;2bb3	00 	. 
	nop			;2bb4	00 	. 
	nop			;2bb5	00 	. 
	nop			;2bb6	00 	. 
	nop			;2bb7	00 	. 
	nop			;2bb8	00 	. 
	nop			;2bb9	00 	. 
	nop			;2bba	00 	. 
	nop			;2bbb	00 	. 
	nop			;2bbc	00 	. 
	nop			;2bbd	00 	. 
	nop			;2bbe	00 	. 
	nop			;2bbf	00 	. 
	nop			;2bc0	00 	. 
	nop			;2bc1	00 	. 
	nop			;2bc2	00 	. 
	nop			;2bc3	00 	. 
	nop			;2bc4	00 	. 
	nop			;2bc5	00 	. 
	nop			;2bc6	00 	. 
	nop			;2bc7	00 	. 
	nop			;2bc8	00 	. 
	nop			;2bc9	00 	. 
	nop			;2bca	00 	. 
	nop			;2bcb	00 	. 
	nop			;2bcc	00 	. 
	nop			;2bcd	00 	. 
	nop			;2bce	00 	. 
	nop			;2bcf	00 	. 
	nop			;2bd0	00 	. 
	nop			;2bd1	00 	. 
	nop			;2bd2	00 	. 
	nop			;2bd3	00 	. 
	nop			;2bd4	00 	. 
	nop			;2bd5	00 	. 
	nop			;2bd6	00 	. 
	nop			;2bd7	00 	. 
	nop			;2bd8	00 	. 
	nop			;2bd9	00 	. 
	nop			;2bda	00 	. 
	nop			;2bdb	00 	. 
	nop			;2bdc	00 	. 
	nop			;2bdd	00 	. 
	nop			;2bde	00 	. 
	nop			;2bdf	00 	. 
	nop			;2be0	00 	. 
	nop			;2be1	00 	. 
	nop			;2be2	00 	. 
	nop			;2be3	00 	. 
	nop			;2be4	00 	. 
	nop			;2be5	00 	. 
	nop			;2be6	00 	. 
	nop			;2be7	00 	. 
	nop			;2be8	00 	. 
	nop			;2be9	00 	. 
	nop			;2bea	00 	. 
	nop			;2beb	00 	. 
	nop			;2bec	00 	. 
	nop			;2bed	00 	. 
	nop			;2bee	00 	. 
	nop			;2bef	00 	. 
	nop			;2bf0	00 	. 
	nop			;2bf1	00 	. 
	nop			;2bf2	00 	. 
	nop			;2bf3	00 	. 
	nop			;2bf4	00 	. 
	nop			;2bf5	00 	. 
	nop			;2bf6	00 	. 
	nop			;2bf7	00 	. 
	nop			;2bf8	00 	. 
	nop			;2bf9	00 	. 
	nop			;2bfa	00 	. 
	nop			;2bfb	00 	. 
	nop			;2bfc	00 	. 
	nop			;2bfd	00 	. 
	nop			;2bfe	00 	. 
	nop			;2bff	00 	. 
	nop			;2c00	00 	. 
	nop			;2c01	00 	. 
	nop			;2c02	00 	. 
	nop			;2c03	00 	. 
	nop			;2c04	00 	. 
	nop			;2c05	00 	. 
	nop			;2c06	00 	. 
	nop			;2c07	00 	. 
	nop			;2c08	00 	. 
	nop			;2c09	00 	. 
	nop			;2c0a	00 	. 
	nop			;2c0b	00 	. 
	nop			;2c0c	00 	. 
	nop			;2c0d	00 	. 
	nop			;2c0e	00 	. 
	nop			;2c0f	00 	. 
	nop			;2c10	00 	. 
	nop			;2c11	00 	. 
	nop			;2c12	00 	. 
	nop			;2c13	00 	. 
	nop			;2c14	00 	. 
	nop			;2c15	00 	. 
	nop			;2c16	00 	. 
	nop			;2c17	00 	. 
	nop			;2c18	00 	. 
	nop			;2c19	00 	. 
	nop			;2c1a	00 	. 
	nop			;2c1b	00 	. 
	nop			;2c1c	00 	. 
	nop			;2c1d	00 	. 
	nop			;2c1e	00 	. 
	nop			;2c1f	00 	. 
	nop			;2c20	00 	. 
	nop			;2c21	00 	. 
	nop			;2c22	00 	. 
	nop			;2c23	00 	. 
	nop			;2c24	00 	. 
	nop			;2c25	00 	. 
	nop			;2c26	00 	. 
	nop			;2c27	00 	. 
	nop			;2c28	00 	. 
	nop			;2c29	00 	. 
	nop			;2c2a	00 	. 
l2c2bh:
	nop			;2c2b	00 	. 
	nop			;2c2c	00 	. 
	nop			;2c2d	00 	. 
	nop			;2c2e	00 	. 
	nop			;2c2f	00 	. 
	nop			;2c30	00 	. 
	nop			;2c31	00 	. 
	nop			;2c32	00 	. 
	nop			;2c33	00 	. 
	nop			;2c34	00 	. 
	nop			;2c35	00 	. 
	nop			;2c36	00 	. 
	nop			;2c37	00 	. 
	nop			;2c38	00 	. 
	nop			;2c39	00 	. 
	nop			;2c3a	00 	. 
	nop			;2c3b	00 	. 
	nop			;2c3c	00 	. 
	nop			;2c3d	00 	. 
	nop			;2c3e	00 	. 
	nop			;2c3f	00 	. 
	nop			;2c40	00 	. 
	nop			;2c41	00 	. 
	nop			;2c42	00 	. 
	nop			;2c43	00 	. 
	nop			;2c44	00 	. 
	nop			;2c45	00 	. 
	nop			;2c46	00 	. 
	nop			;2c47	00 	. 
	nop			;2c48	00 	. 
	nop			;2c49	00 	. 
	nop			;2c4a	00 	. 
	nop			;2c4b	00 	. 
	nop			;2c4c	00 	. 
	nop			;2c4d	00 	. 
	nop			;2c4e	00 	. 
	nop			;2c4f	00 	. 
	nop			;2c50	00 	. 
	nop			;2c51	00 	. 
	nop			;2c52	00 	. 
	nop			;2c53	00 	. 
	nop			;2c54	00 	. 
	nop			;2c55	00 	. 
	nop			;2c56	00 	. 
	nop			;2c57	00 	. 
	nop			;2c58	00 	. 
	nop			;2c59	00 	. 
	nop			;2c5a	00 	. 
	nop			;2c5b	00 	. 
	nop			;2c5c	00 	. 
	nop			;2c5d	00 	. 
	nop			;2c5e	00 	. 
	nop			;2c5f	00 	. 
	nop			;2c60	00 	. 
	nop			;2c61	00 	. 
	nop			;2c62	00 	. 
	nop			;2c63	00 	. 
	nop			;2c64	00 	. 
	nop			;2c65	00 	. 
	nop			;2c66	00 	. 
	nop			;2c67	00 	. 
	nop			;2c68	00 	. 
	nop			;2c69	00 	. 
	nop			;2c6a	00 	. 
	nop			;2c6b	00 	. 
	nop			;2c6c	00 	. 
	nop			;2c6d	00 	. 
	nop			;2c6e	00 	. 
	nop			;2c6f	00 	. 
	nop			;2c70	00 	. 
	nop			;2c71	00 	. 
	nop			;2c72	00 	. 
	nop			;2c73	00 	. 
	nop			;2c74	00 	. 
	nop			;2c75	00 	. 
	nop			;2c76	00 	. 
	nop			;2c77	00 	. 
	nop			;2c78	00 	. 
	nop			;2c79	00 	. 
	nop			;2c7a	00 	. 
	nop			;2c7b	00 	. 
	nop			;2c7c	00 	. 
	nop			;2c7d	00 	. 
	nop			;2c7e	00 	. 
	nop			;2c7f	00 	. 
	nop			;2c80	00 	. 
	nop			;2c81	00 	. 
	nop			;2c82	00 	. 
	nop			;2c83	00 	. 
	nop			;2c84	00 	. 
	nop			;2c85	00 	. 
	nop			;2c86	00 	. 
	nop			;2c87	00 	. 
	nop			;2c88	00 	. 
	nop			;2c89	00 	. 
	nop			;2c8a	00 	. 
	nop			;2c8b	00 	. 
	nop			;2c8c	00 	. 
	nop			;2c8d	00 	. 
	nop			;2c8e	00 	. 
	nop			;2c8f	00 	. 
	nop			;2c90	00 	. 
	nop			;2c91	00 	. 
	nop			;2c92	00 	. 
	nop			;2c93	00 	. 
	nop			;2c94	00 	. 
	nop			;2c95	00 	. 
	nop			;2c96	00 	. 
	nop			;2c97	00 	. 
	nop			;2c98	00 	. 
	nop			;2c99	00 	. 
	nop			;2c9a	00 	. 
	nop			;2c9b	00 	. 
	nop			;2c9c	00 	. 
	nop			;2c9d	00 	. 
	nop			;2c9e	00 	. 
	nop			;2c9f	00 	. 
	nop			;2ca0	00 	. 
	nop			;2ca1	00 	. 
	nop			;2ca2	00 	. 
	nop			;2ca3	00 	. 
	nop			;2ca4	00 	. 
	nop			;2ca5	00 	. 
	nop			;2ca6	00 	. 
	nop			;2ca7	00 	. 
	nop			;2ca8	00 	. 
	nop			;2ca9	00 	. 
	nop			;2caa	00 	. 
	nop			;2cab	00 	. 
	nop			;2cac	00 	. 
	nop			;2cad	00 	. 
	nop			;2cae	00 	. 
	nop			;2caf	00 	. 
	nop			;2cb0	00 	. 
	nop			;2cb1	00 	. 
	nop			;2cb2	00 	. 
	nop			;2cb3	00 	. 
	nop			;2cb4	00 	. 
	nop			;2cb5	00 	. 
	nop			;2cb6	00 	. 
	nop			;2cb7	00 	. 
	nop			;2cb8	00 	. 
	nop			;2cb9	00 	. 
	nop			;2cba	00 	. 
	nop			;2cbb	00 	. 
	nop			;2cbc	00 	. 
	nop			;2cbd	00 	. 
	nop			;2cbe	00 	. 
	nop			;2cbf	00 	. 
	nop			;2cc0	00 	. 
	nop			;2cc1	00 	. 
	nop			;2cc2	00 	. 
	nop			;2cc3	00 	. 
	nop			;2cc4	00 	. 
	nop			;2cc5	00 	. 
	nop			;2cc6	00 	. 
	nop			;2cc7	00 	. 
	nop			;2cc8	00 	. 
	nop			;2cc9	00 	. 
	nop			;2cca	00 	. 
	nop			;2ccb	00 	. 
	nop			;2ccc	00 	. 
	nop			;2ccd	00 	. 
	nop			;2cce	00 	. 
	nop			;2ccf	00 	. 
	nop			;2cd0	00 	. 
	nop			;2cd1	00 	. 
	nop			;2cd2	00 	. 
	nop			;2cd3	00 	. 
	nop			;2cd4	00 	. 
	nop			;2cd5	00 	. 
	nop			;2cd6	00 	. 
	nop			;2cd7	00 	. 
	nop			;2cd8	00 	. 
	nop			;2cd9	00 	. 
	nop			;2cda	00 	. 
	nop			;2cdb	00 	. 
	nop			;2cdc	00 	. 
	nop			;2cdd	00 	. 
	nop			;2cde	00 	. 
	nop			;2cdf	00 	. 
	nop			;2ce0	00 	. 
	nop			;2ce1	00 	. 
	nop			;2ce2	00 	. 
	nop			;2ce3	00 	. 
	nop			;2ce4	00 	. 
	nop			;2ce5	00 	. 
	nop			;2ce6	00 	. 
	nop			;2ce7	00 	. 
	nop			;2ce8	00 	. 
	nop			;2ce9	00 	. 
	nop			;2cea	00 	. 
	nop			;2ceb	00 	. 
	nop			;2cec	00 	. 
	nop			;2ced	00 	. 
	nop			;2cee	00 	. 
	nop			;2cef	00 	. 
	nop			;2cf0	00 	. 
	nop			;2cf1	00 	. 
	nop			;2cf2	00 	. 
	nop			;2cf3	00 	. 
	nop			;2cf4	00 	. 
	nop			;2cf5	00 	. 
	nop			;2cf6	00 	. 
	nop			;2cf7	00 	. 
	nop			;2cf8	00 	. 
	nop			;2cf9	00 	. 
	nop			;2cfa	00 	. 
	nop			;2cfb	00 	. 
	nop			;2cfc	00 	. 
	nop			;2cfd	00 	. 
	nop			;2cfe	00 	. 
	nop			;2cff	00 	. 
	nop			;2d00	00 	. 
	nop			;2d01	00 	. 
	nop			;2d02	00 	. 
	nop			;2d03	00 	. 
	nop			;2d04	00 	. 
	nop			;2d05	00 	. 
	nop			;2d06	00 	. 
	nop			;2d07	00 	. 
	nop			;2d08	00 	. 
	nop			;2d09	00 	. 
	nop			;2d0a	00 	. 
	nop			;2d0b	00 	. 
	nop			;2d0c	00 	. 
	nop			;2d0d	00 	. 
	nop			;2d0e	00 	. 
	nop			;2d0f	00 	. 
	nop			;2d10	00 	. 
	nop			;2d11	00 	. 
	nop			;2d12	00 	. 
	nop			;2d13	00 	. 
	nop			;2d14	00 	. 
	nop			;2d15	00 	. 
	nop			;2d16	00 	. 
	nop			;2d17	00 	. 
	nop			;2d18	00 	. 
	nop			;2d19	00 	. 
	nop			;2d1a	00 	. 
	nop			;2d1b	00 	. 
	nop			;2d1c	00 	. 
	nop			;2d1d	00 	. 
	nop			;2d1e	00 	. 
	nop			;2d1f	00 	. 
	nop			;2d20	00 	. 
	nop			;2d21	00 	. 
	nop			;2d22	00 	. 
	nop			;2d23	00 	. 
	nop			;2d24	00 	. 
	nop			;2d25	00 	. 
	nop			;2d26	00 	. 
	nop			;2d27	00 	. 
	nop			;2d28	00 	. 
	nop			;2d29	00 	. 
	nop			;2d2a	00 	. 
	nop			;2d2b	00 	. 
	nop			;2d2c	00 	. 
	nop			;2d2d	00 	. 
	nop			;2d2e	00 	. 
	nop			;2d2f	00 	. 
	nop			;2d30	00 	. 
	nop			;2d31	00 	. 
	nop			;2d32	00 	. 
	nop			;2d33	00 	. 
	nop			;2d34	00 	. 
	nop			;2d35	00 	. 
	nop			;2d36	00 	. 
	nop			;2d37	00 	. 
	nop			;2d38	00 	. 
	nop			;2d39	00 	. 
	nop			;2d3a	00 	. 
	nop			;2d3b	00 	. 
	nop			;2d3c	00 	. 
	nop			;2d3d	00 	. 
	nop			;2d3e	00 	. 
	nop			;2d3f	00 	. 
	nop			;2d40	00 	. 
	nop			;2d41	00 	. 
	nop			;2d42	00 	. 
	nop			;2d43	00 	. 
	nop			;2d44	00 	. 
	nop			;2d45	00 	. 
	nop			;2d46	00 	. 
	nop			;2d47	00 	. 
	nop			;2d48	00 	. 
	nop			;2d49	00 	. 
	nop			;2d4a	00 	. 
	nop			;2d4b	00 	. 
	nop			;2d4c	00 	. 
	nop			;2d4d	00 	. 
	nop			;2d4e	00 	. 
	nop			;2d4f	00 	. 
	nop			;2d50	00 	. 
	nop			;2d51	00 	. 
	nop			;2d52	00 	. 
	nop			;2d53	00 	. 
	nop			;2d54	00 	. 
	nop			;2d55	00 	. 
	nop			;2d56	00 	. 
	nop			;2d57	00 	. 
	nop			;2d58	00 	. 
	nop			;2d59	00 	. 
	nop			;2d5a	00 	. 
	nop			;2d5b	00 	. 
	nop			;2d5c	00 	. 
	nop			;2d5d	00 	. 
	nop			;2d5e	00 	. 
	nop			;2d5f	00 	. 
	nop			;2d60	00 	. 
	nop			;2d61	00 	. 
	nop			;2d62	00 	. 
	nop			;2d63	00 	. 
	nop			;2d64	00 	. 
	nop			;2d65	00 	. 
	nop			;2d66	00 	. 
	nop			;2d67	00 	. 
	nop			;2d68	00 	. 
	nop			;2d69	00 	. 
	nop			;2d6a	00 	. 
	nop			;2d6b	00 	. 
	nop			;2d6c	00 	. 
	nop			;2d6d	00 	. 
	nop			;2d6e	00 	. 
	nop			;2d6f	00 	. 
	nop			;2d70	00 	. 
	nop			;2d71	00 	. 
	nop			;2d72	00 	. 
	nop			;2d73	00 	. 
	nop			;2d74	00 	. 
	nop			;2d75	00 	. 
	nop			;2d76	00 	. 
	nop			;2d77	00 	. 
	nop			;2d78	00 	. 
	nop			;2d79	00 	. 
	nop			;2d7a	00 	. 
	nop			;2d7b	00 	. 
	nop			;2d7c	00 	. 
	nop			;2d7d	00 	. 
	nop			;2d7e	00 	. 
	nop			;2d7f	00 	. 
	nop			;2d80	00 	. 
	nop			;2d81	00 	. 
	nop			;2d82	00 	. 
	nop			;2d83	00 	. 
	nop			;2d84	00 	. 
	nop			;2d85	00 	. 
	nop			;2d86	00 	. 
	nop			;2d87	00 	. 
	nop			;2d88	00 	. 
	nop			;2d89	00 	. 
	nop			;2d8a	00 	. 
	nop			;2d8b	00 	. 
	nop			;2d8c	00 	. 
	nop			;2d8d	00 	. 
	nop			;2d8e	00 	. 
	nop			;2d8f	00 	. 
	nop			;2d90	00 	. 
	nop			;2d91	00 	. 
	nop			;2d92	00 	. 
	nop			;2d93	00 	. 
	nop			;2d94	00 	. 
	nop			;2d95	00 	. 
	nop			;2d96	00 	. 
	nop			;2d97	00 	. 
	nop			;2d98	00 	. 
	nop			;2d99	00 	. 
	nop			;2d9a	00 	. 
	nop			;2d9b	00 	. 
	nop			;2d9c	00 	. 
	nop			;2d9d	00 	. 
	nop			;2d9e	00 	. 
	nop			;2d9f	00 	. 
	nop			;2da0	00 	. 
	nop			;2da1	00 	. 
	nop			;2da2	00 	. 
	nop			;2da3	00 	. 
	nop			;2da4	00 	. 
	nop			;2da5	00 	. 
	nop			;2da6	00 	. 
	nop			;2da7	00 	. 
	nop			;2da8	00 	. 
	nop			;2da9	00 	. 
	nop			;2daa	00 	. 
	nop			;2dab	00 	. 
	nop			;2dac	00 	. 
	nop			;2dad	00 	. 
	nop			;2dae	00 	. 
	nop			;2daf	00 	. 
	nop			;2db0	00 	. 
	nop			;2db1	00 	. 
	nop			;2db2	00 	. 
	nop			;2db3	00 	. 
	nop			;2db4	00 	. 
	nop			;2db5	00 	. 
	nop			;2db6	00 	. 
	nop			;2db7	00 	. 
	nop			;2db8	00 	. 
	nop			;2db9	00 	. 
	nop			;2dba	00 	. 
	nop			;2dbb	00 	. 
	nop			;2dbc	00 	. 
	nop			;2dbd	00 	. 
	nop			;2dbe	00 	. 
	nop			;2dbf	00 	. 
	nop			;2dc0	00 	. 
	nop			;2dc1	00 	. 
	nop			;2dc2	00 	. 
	nop			;2dc3	00 	. 
	nop			;2dc4	00 	. 
	nop			;2dc5	00 	. 
	nop			;2dc6	00 	. 
	nop			;2dc7	00 	. 
	nop			;2dc8	00 	. 
	nop			;2dc9	00 	. 
	nop			;2dca	00 	. 
	nop			;2dcb	00 	. 
	nop			;2dcc	00 	. 
	nop			;2dcd	00 	. 
	nop			;2dce	00 	. 
	nop			;2dcf	00 	. 
	nop			;2dd0	00 	. 
	nop			;2dd1	00 	. 
	nop			;2dd2	00 	. 
	nop			;2dd3	00 	. 
	nop			;2dd4	00 	. 
	nop			;2dd5	00 	. 
	nop			;2dd6	00 	. 
	nop			;2dd7	00 	. 
	nop			;2dd8	00 	. 
	nop			;2dd9	00 	. 
	nop			;2dda	00 	. 
	nop			;2ddb	00 	. 
	nop			;2ddc	00 	. 
	nop			;2ddd	00 	. 
	nop			;2dde	00 	. 
	nop			;2ddf	00 	. 
	nop			;2de0	00 	. 
	nop			;2de1	00 	. 
	nop			;2de2	00 	. 
	nop			;2de3	00 	. 
	nop			;2de4	00 	. 
	nop			;2de5	00 	. 
	nop			;2de6	00 	. 
	nop			;2de7	00 	. 
	nop			;2de8	00 	. 
	nop			;2de9	00 	. 
	nop			;2dea	00 	. 
	nop			;2deb	00 	. 
	nop			;2dec	00 	. 
	nop			;2ded	00 	. 
	nop			;2dee	00 	. 
	nop			;2def	00 	. 
	nop			;2df0	00 	. 
	nop			;2df1	00 	. 
	nop			;2df2	00 	. 
	nop			;2df3	00 	. 
	nop			;2df4	00 	. 
	nop			;2df5	00 	. 
	nop			;2df6	00 	. 
	nop			;2df7	00 	. 
	nop			;2df8	00 	. 
	nop			;2df9	00 	. 
	nop			;2dfa	00 	. 
	nop			;2dfb	00 	. 
	nop			;2dfc	00 	. 
	nop			;2dfd	00 	. 
	nop			;2dfe	00 	. 
	nop			;2dff	00 	. 
	nop			;2e00	00 	. 
	nop			;2e01	00 	. 
	nop			;2e02	00 	. 
	nop			;2e03	00 	. 
	nop			;2e04	00 	. 
	nop			;2e05	00 	. 
	nop			;2e06	00 	. 
	nop			;2e07	00 	. 
	nop			;2e08	00 	. 
	nop			;2e09	00 	. 
	nop			;2e0a	00 	. 
	nop			;2e0b	00 	. 
	nop			;2e0c	00 	. 
	nop			;2e0d	00 	. 
	nop			;2e0e	00 	. 
	nop			;2e0f	00 	. 
	nop			;2e10	00 	. 
	nop			;2e11	00 	. 
	nop			;2e12	00 	. 
	nop			;2e13	00 	. 
	nop			;2e14	00 	. 
	nop			;2e15	00 	. 
	nop			;2e16	00 	. 
	nop			;2e17	00 	. 
	nop			;2e18	00 	. 
	nop			;2e19	00 	. 
	nop			;2e1a	00 	. 
	nop			;2e1b	00 	. 
	nop			;2e1c	00 	. 
	nop			;2e1d	00 	. 
	nop			;2e1e	00 	. 
	nop			;2e1f	00 	. 
	nop			;2e20	00 	. 
	nop			;2e21	00 	. 
	nop			;2e22	00 	. 
	nop			;2e23	00 	. 
	nop			;2e24	00 	. 
	nop			;2e25	00 	. 
	nop			;2e26	00 	. 
	nop			;2e27	00 	. 
	nop			;2e28	00 	. 
	nop			;2e29	00 	. 
	nop			;2e2a	00 	. 
	nop			;2e2b	00 	. 
	nop			;2e2c	00 	. 
	nop			;2e2d	00 	. 
	nop			;2e2e	00 	. 
	nop			;2e2f	00 	. 
	nop			;2e30	00 	. 
	nop			;2e31	00 	. 
	nop			;2e32	00 	. 
	nop			;2e33	00 	. 
	nop			;2e34	00 	. 
	nop			;2e35	00 	. 
	nop			;2e36	00 	. 
	nop			;2e37	00 	. 
	nop			;2e38	00 	. 
	nop			;2e39	00 	. 
	nop			;2e3a	00 	. 
	nop			;2e3b	00 	. 
	nop			;2e3c	00 	. 
	nop			;2e3d	00 	. 
	nop			;2e3e	00 	. 
	nop			;2e3f	00 	. 
	nop			;2e40	00 	. 
	nop			;2e41	00 	. 
	nop			;2e42	00 	. 
	nop			;2e43	00 	. 
	nop			;2e44	00 	. 
	nop			;2e45	00 	. 
	nop			;2e46	00 	. 
	nop			;2e47	00 	. 
	nop			;2e48	00 	. 
	nop			;2e49	00 	. 
	nop			;2e4a	00 	. 
	nop			;2e4b	00 	. 
	nop			;2e4c	00 	. 
	nop			;2e4d	00 	. 
	nop			;2e4e	00 	. 
	nop			;2e4f	00 	. 
	nop			;2e50	00 	. 
	nop			;2e51	00 	. 
	nop			;2e52	00 	. 
	nop			;2e53	00 	. 
	nop			;2e54	00 	. 
	nop			;2e55	00 	. 
	nop			;2e56	00 	. 
	nop			;2e57	00 	. 
	nop			;2e58	00 	. 
	nop			;2e59	00 	. 
	nop			;2e5a	00 	. 
	nop			;2e5b	00 	. 
	nop			;2e5c	00 	. 
	nop			;2e5d	00 	. 
	nop			;2e5e	00 	. 
	nop			;2e5f	00 	. 
	nop			;2e60	00 	. 
	nop			;2e61	00 	. 
	nop			;2e62	00 	. 
	nop			;2e63	00 	. 
	nop			;2e64	00 	. 
	nop			;2e65	00 	. 
	nop			;2e66	00 	. 
	nop			;2e67	00 	. 
	nop			;2e68	00 	. 
	nop			;2e69	00 	. 
	nop			;2e6a	00 	. 
	nop			;2e6b	00 	. 
	nop			;2e6c	00 	. 
	nop			;2e6d	00 	. 
	nop			;2e6e	00 	. 
	nop			;2e6f	00 	. 
	nop			;2e70	00 	. 
	nop			;2e71	00 	. 
	nop			;2e72	00 	. 
	nop			;2e73	00 	. 
	nop			;2e74	00 	. 
	nop			;2e75	00 	. 
	nop			;2e76	00 	. 
	nop			;2e77	00 	. 
	nop			;2e78	00 	. 
	nop			;2e79	00 	. 
	nop			;2e7a	00 	. 
	nop			;2e7b	00 	. 
	nop			;2e7c	00 	. 
	nop			;2e7d	00 	. 
	nop			;2e7e	00 	. 
	nop			;2e7f	00 	. 
	nop			;2e80	00 	. 
	nop			;2e81	00 	. 
	nop			;2e82	00 	. 
	nop			;2e83	00 	. 
	nop			;2e84	00 	. 
	nop			;2e85	00 	. 
	nop			;2e86	00 	. 
	nop			;2e87	00 	. 
	nop			;2e88	00 	. 
	nop			;2e89	00 	. 
	nop			;2e8a	00 	. 
	nop			;2e8b	00 	. 
	nop			;2e8c	00 	. 
	nop			;2e8d	00 	. 
	nop			;2e8e	00 	. 
	nop			;2e8f	00 	. 
	nop			;2e90	00 	. 
	nop			;2e91	00 	. 
	nop			;2e92	00 	. 
	nop			;2e93	00 	. 
	nop			;2e94	00 	. 
	nop			;2e95	00 	. 
	nop			;2e96	00 	. 
	nop			;2e97	00 	. 
	nop			;2e98	00 	. 
	nop			;2e99	00 	. 
	nop			;2e9a	00 	. 
	nop			;2e9b	00 	. 
	nop			;2e9c	00 	. 
	nop			;2e9d	00 	. 
	nop			;2e9e	00 	. 
	nop			;2e9f	00 	. 
	nop			;2ea0	00 	. 
	nop			;2ea1	00 	. 
	nop			;2ea2	00 	. 
	nop			;2ea3	00 	. 
	nop			;2ea4	00 	. 
	nop			;2ea5	00 	. 
	nop			;2ea6	00 	. 
	nop			;2ea7	00 	. 
	nop			;2ea8	00 	. 
	nop			;2ea9	00 	. 
	nop			;2eaa	00 	. 
	nop			;2eab	00 	. 
	nop			;2eac	00 	. 
	nop			;2ead	00 	. 
	nop			;2eae	00 	. 
	nop			;2eaf	00 	. 
	nop			;2eb0	00 	. 
	nop			;2eb1	00 	. 
	nop			;2eb2	00 	. 
	nop			;2eb3	00 	. 
	nop			;2eb4	00 	. 
	nop			;2eb5	00 	. 
	nop			;2eb6	00 	. 
	nop			;2eb7	00 	. 
	nop			;2eb8	00 	. 
	nop			;2eb9	00 	. 
	nop			;2eba	00 	. 
	nop			;2ebb	00 	. 
	nop			;2ebc	00 	. 
	nop			;2ebd	00 	. 
	nop			;2ebe	00 	. 
	nop			;2ebf	00 	. 
	nop			;2ec0	00 	. 
	nop			;2ec1	00 	. 
	nop			;2ec2	00 	. 
	nop			;2ec3	00 	. 
	nop			;2ec4	00 	. 
	nop			;2ec5	00 	. 
	nop			;2ec6	00 	. 
	nop			;2ec7	00 	. 
	nop			;2ec8	00 	. 
	nop			;2ec9	00 	. 
	nop			;2eca	00 	. 
	nop			;2ecb	00 	. 
	nop			;2ecc	00 	. 
	nop			;2ecd	00 	. 
	nop			;2ece	00 	. 
	nop			;2ecf	00 	. 
	nop			;2ed0	00 	. 
	nop			;2ed1	00 	. 
	nop			;2ed2	00 	. 
	nop			;2ed3	00 	. 
	nop			;2ed4	00 	. 
	nop			;2ed5	00 	. 
	nop			;2ed6	00 	. 
	nop			;2ed7	00 	. 
	nop			;2ed8	00 	. 
	nop			;2ed9	00 	. 
	nop			;2eda	00 	. 
	nop			;2edb	00 	. 
	nop			;2edc	00 	. 
	nop			;2edd	00 	. 
	nop			;2ede	00 	. 
	nop			;2edf	00 	. 
	nop			;2ee0	00 	. 
	nop			;2ee1	00 	. 
	nop			;2ee2	00 	. 
	nop			;2ee3	00 	. 
	nop			;2ee4	00 	. 
	nop			;2ee5	00 	. 
	nop			;2ee6	00 	. 
	nop			;2ee7	00 	. 
	nop			;2ee8	00 	. 
	nop			;2ee9	00 	. 
	nop			;2eea	00 	. 
	nop			;2eeb	00 	. 
	nop			;2eec	00 	. 
	nop			;2eed	00 	. 
	nop			;2eee	00 	. 
	nop			;2eef	00 	. 
	nop			;2ef0	00 	. 
	nop			;2ef1	00 	. 
	nop			;2ef2	00 	. 
	nop			;2ef3	00 	. 
	nop			;2ef4	00 	. 
	nop			;2ef5	00 	. 
	nop			;2ef6	00 	. 
	nop			;2ef7	00 	. 
	nop			;2ef8	00 	. 
	nop			;2ef9	00 	. 
	nop			;2efa	00 	. 
	nop			;2efb	00 	. 
	nop			;2efc	00 	. 
	nop			;2efd	00 	. 
	nop			;2efe	00 	. 
	nop			;2eff	00 	. 
	nop			;2f00	00 	. 
	nop			;2f01	00 	. 
	nop			;2f02	00 	. 
	nop			;2f03	00 	. 
	nop			;2f04	00 	. 
	nop			;2f05	00 	. 
	nop			;2f06	00 	. 
	nop			;2f07	00 	. 
	nop			;2f08	00 	. 
	nop			;2f09	00 	. 
	nop			;2f0a	00 	. 
	nop			;2f0b	00 	. 
	nop			;2f0c	00 	. 
	nop			;2f0d	00 	. 
	nop			;2f0e	00 	. 
	nop			;2f0f	00 	. 
	nop			;2f10	00 	. 
	nop			;2f11	00 	. 
	nop			;2f12	00 	. 
	nop			;2f13	00 	. 
	nop			;2f14	00 	. 
	nop			;2f15	00 	. 
	nop			;2f16	00 	. 
	nop			;2f17	00 	. 
	nop			;2f18	00 	. 
	nop			;2f19	00 	. 
	nop			;2f1a	00 	. 
	nop			;2f1b	00 	. 
	nop			;2f1c	00 	. 
	nop			;2f1d	00 	. 
	nop			;2f1e	00 	. 
	nop			;2f1f	00 	. 
	nop			;2f20	00 	. 
	nop			;2f21	00 	. 
	nop			;2f22	00 	. 
	nop			;2f23	00 	. 
	nop			;2f24	00 	. 
	nop			;2f25	00 	. 
	nop			;2f26	00 	. 
	nop			;2f27	00 	. 
	nop			;2f28	00 	. 
	nop			;2f29	00 	. 
	nop			;2f2a	00 	. 
	nop			;2f2b	00 	. 
	nop			;2f2c	00 	. 
	nop			;2f2d	00 	. 
	nop			;2f2e	00 	. 
	nop			;2f2f	00 	. 
	nop			;2f30	00 	. 
	nop			;2f31	00 	. 
	nop			;2f32	00 	. 
	nop			;2f33	00 	. 
	nop			;2f34	00 	. 
	nop			;2f35	00 	. 
	nop			;2f36	00 	. 
	nop			;2f37	00 	. 
	nop			;2f38	00 	. 
	nop			;2f39	00 	. 
	nop			;2f3a	00 	. 
	nop			;2f3b	00 	. 
	nop			;2f3c	00 	. 
	nop			;2f3d	00 	. 
	nop			;2f3e	00 	. 
	nop			;2f3f	00 	. 
	nop			;2f40	00 	. 
	nop			;2f41	00 	. 
	nop			;2f42	00 	. 
	nop			;2f43	00 	. 
	nop			;2f44	00 	. 
	nop			;2f45	00 	. 
	nop			;2f46	00 	. 
	nop			;2f47	00 	. 
	nop			;2f48	00 	. 
	nop			;2f49	00 	. 
	nop			;2f4a	00 	. 
	nop			;2f4b	00 	. 
	nop			;2f4c	00 	. 
	nop			;2f4d	00 	. 
	nop			;2f4e	00 	. 
	nop			;2f4f	00 	. 
	nop			;2f50	00 	. 
	nop			;2f51	00 	. 
	nop			;2f52	00 	. 
	nop			;2f53	00 	. 
	nop			;2f54	00 	. 
	nop			;2f55	00 	. 
	nop			;2f56	00 	. 
	nop			;2f57	00 	. 
	nop			;2f58	00 	. 
	nop			;2f59	00 	. 
	nop			;2f5a	00 	. 
	nop			;2f5b	00 	. 
	nop			;2f5c	00 	. 
	nop			;2f5d	00 	. 
	nop			;2f5e	00 	. 
	nop			;2f5f	00 	. 
	nop			;2f60	00 	. 
	nop			;2f61	00 	. 
	nop			;2f62	00 	. 
	nop			;2f63	00 	. 
	nop			;2f64	00 	. 
	nop			;2f65	00 	. 
	nop			;2f66	00 	. 
	nop			;2f67	00 	. 
	nop			;2f68	00 	. 
	nop			;2f69	00 	. 
	nop			;2f6a	00 	. 
	nop			;2f6b	00 	. 
	nop			;2f6c	00 	. 
	nop			;2f6d	00 	. 
	nop			;2f6e	00 	. 
	nop			;2f6f	00 	. 
	nop			;2f70	00 	. 
	nop			;2f71	00 	. 
	nop			;2f72	00 	. 
	nop			;2f73	00 	. 
	nop			;2f74	00 	. 
	nop			;2f75	00 	. 
	nop			;2f76	00 	. 
	nop			;2f77	00 	. 
	nop			;2f78	00 	. 
	nop			;2f79	00 	. 
	nop			;2f7a	00 	. 
	nop			;2f7b	00 	. 
	nop			;2f7c	00 	. 
	nop			;2f7d	00 	. 
	nop			;2f7e	00 	. 
	nop			;2f7f	00 	. 
	nop			;2f80	00 	. 
	nop			;2f81	00 	. 
	nop			;2f82	00 	. 
	nop			;2f83	00 	. 
	nop			;2f84	00 	. 
	nop			;2f85	00 	. 
	nop			;2f86	00 	. 
	nop			;2f87	00 	. 
	nop			;2f88	00 	. 
	nop			;2f89	00 	. 
	nop			;2f8a	00 	. 
	nop			;2f8b	00 	. 
	nop			;2f8c	00 	. 
	nop			;2f8d	00 	. 
	nop			;2f8e	00 	. 
	nop			;2f8f	00 	. 
	nop			;2f90	00 	. 
	nop			;2f91	00 	. 
	nop			;2f92	00 	. 
	nop			;2f93	00 	. 
	nop			;2f94	00 	. 
	nop			;2f95	00 	. 
	nop			;2f96	00 	. 
	nop			;2f97	00 	. 
	nop			;2f98	00 	. 
	nop			;2f99	00 	. 
	nop			;2f9a	00 	. 
	nop			;2f9b	00 	. 
	nop			;2f9c	00 	. 
	nop			;2f9d	00 	. 
	nop			;2f9e	00 	. 
	nop			;2f9f	00 	. 
	nop			;2fa0	00 	. 
	nop			;2fa1	00 	. 
	nop			;2fa2	00 	. 
	nop			;2fa3	00 	. 
	nop			;2fa4	00 	. 
	nop			;2fa5	00 	. 
	nop			;2fa6	00 	. 
	nop			;2fa7	00 	. 
	nop			;2fa8	00 	. 
	nop			;2fa9	00 	. 
	nop			;2faa	00 	. 
	nop			;2fab	00 	. 
	nop			;2fac	00 	. 
	nop			;2fad	00 	. 
	nop			;2fae	00 	. 
	nop			;2faf	00 	. 
	nop			;2fb0	00 	. 
	nop			;2fb1	00 	. 
	nop			;2fb2	00 	. 
	nop			;2fb3	00 	. 
	nop			;2fb4	00 	. 
	nop			;2fb5	00 	. 
	nop			;2fb6	00 	. 
	nop			;2fb7	00 	. 
	nop			;2fb8	00 	. 
	nop			;2fb9	00 	. 
	nop			;2fba	00 	. 
	nop			;2fbb	00 	. 
	nop			;2fbc	00 	. 
	nop			;2fbd	00 	. 
	nop			;2fbe	00 	. 
	nop			;2fbf	00 	. 
	nop			;2fc0	00 	. 
	nop			;2fc1	00 	. 
	nop			;2fc2	00 	. 
	nop			;2fc3	00 	. 
	nop			;2fc4	00 	. 
	nop			;2fc5	00 	. 
	nop			;2fc6	00 	. 
	nop			;2fc7	00 	. 
	nop			;2fc8	00 	. 
	nop			;2fc9	00 	. 
	nop			;2fca	00 	. 
	nop			;2fcb	00 	. 
	nop			;2fcc	00 	. 
	nop			;2fcd	00 	. 
	nop			;2fce	00 	. 
	nop			;2fcf	00 	. 
	nop			;2fd0	00 	. 
	nop			;2fd1	00 	. 
	nop			;2fd2	00 	. 
	nop			;2fd3	00 	. 
	nop			;2fd4	00 	. 
	nop			;2fd5	00 	. 
	nop			;2fd6	00 	. 
	nop			;2fd7	00 	. 
	nop			;2fd8	00 	. 
	nop			;2fd9	00 	. 
	nop			;2fda	00 	. 
	nop			;2fdb	00 	. 
	nop			;2fdc	00 	. 
	nop			;2fdd	00 	. 
	nop			;2fde	00 	. 
	nop			;2fdf	00 	. 
	nop			;2fe0	00 	. 
	nop			;2fe1	00 	. 
	nop			;2fe2	00 	. 
	nop			;2fe3	00 	. 
	nop			;2fe4	00 	. 
	nop			;2fe5	00 	. 
	nop			;2fe6	00 	. 
	nop			;2fe7	00 	. 
	nop			;2fe8	00 	. 
	nop			;2fe9	00 	. 
	nop			;2fea	00 	. 
	nop			;2feb	00 	. 
	nop			;2fec	00 	. 
	nop			;2fed	00 	. 
	nop			;2fee	00 	. 
	nop			;2fef	00 	. 
	nop			;2ff0	00 	. 
	nop			;2ff1	00 	. 
	nop			;2ff2	00 	. 
	nop			;2ff3	00 	. 
	nop			;2ff4	00 	. 
	nop			;2ff5	00 	. 
	nop			;2ff6	00 	. 
	nop			;2ff7	00 	. 
	nop			;2ff8	00 	. 
	nop			;2ff9	00 	. 
	nop			;2ffa	00 	. 
	nop			;2ffb	00 	. 
	nop			;2ffc	00 	. 
	nop			;2ffd	00 	. 
	nop			;2ffe	00 	. 
	nop			;2fff	00 	. 
	nop			;3000	00 	. 
	nop			;3001	00 	. 
	nop			;3002	00 	. 
	nop			;3003	00 	. 
	nop			;3004	00 	. 
	nop			;3005	00 	. 
	nop			;3006	00 	. 
	nop			;3007	00 	. 
	nop			;3008	00 	. 
	nop			;3009	00 	. 
	nop			;300a	00 	. 
	nop			;300b	00 	. 
	nop			;300c	00 	. 
	nop			;300d	00 	. 
	nop			;300e	00 	. 
	nop			;300f	00 	. 
	nop			;3010	00 	. 
	nop			;3011	00 	. 
	nop			;3012	00 	. 
	nop			;3013	00 	. 
	nop			;3014	00 	. 
	nop			;3015	00 	. 
	nop			;3016	00 	. 
	nop			;3017	00 	. 
	nop			;3018	00 	. 
	nop			;3019	00 	. 
	nop			;301a	00 	. 
	nop			;301b	00 	. 
	nop			;301c	00 	. 
	nop			;301d	00 	. 
	nop			;301e	00 	. 
	nop			;301f	00 	. 
	nop			;3020	00 	. 
	nop			;3021	00 	. 
	nop			;3022	00 	. 
	nop			;3023	00 	. 
	nop			;3024	00 	. 
	nop			;3025	00 	. 
	nop			;3026	00 	. 
	nop			;3027	00 	. 
	nop			;3028	00 	. 
	nop			;3029	00 	. 
	nop			;302a	00 	. 
	nop			;302b	00 	. 
	nop			;302c	00 	. 
	nop			;302d	00 	. 
	nop			;302e	00 	. 
	nop			;302f	00 	. 
	nop			;3030	00 	. 
	nop			;3031	00 	. 
	nop			;3032	00 	. 
	nop			;3033	00 	. 
	nop			;3034	00 	. 
	nop			;3035	00 	. 
	nop			;3036	00 	. 
	nop			;3037	00 	. 
	nop			;3038	00 	. 
	nop			;3039	00 	. 
	nop			;303a	00 	. 
	nop			;303b	00 	. 
	nop			;303c	00 	. 
	nop			;303d	00 	. 
	nop			;303e	00 	. 
	nop			;303f	00 	. 
	nop			;3040	00 	. 
	nop			;3041	00 	. 
	nop			;3042	00 	. 
	nop			;3043	00 	. 
	nop			;3044	00 	. 
	nop			;3045	00 	. 
	nop			;3046	00 	. 
	nop			;3047	00 	. 
	nop			;3048	00 	. 
	nop			;3049	00 	. 
	nop			;304a	00 	. 
	nop			;304b	00 	. 
	nop			;304c	00 	. 
	nop			;304d	00 	. 
	nop			;304e	00 	. 
	nop			;304f	00 	. 
	nop			;3050	00 	. 
	nop			;3051	00 	. 
	nop			;3052	00 	. 
	nop			;3053	00 	. 
	nop			;3054	00 	. 
	nop			;3055	00 	. 
	nop			;3056	00 	. 
	nop			;3057	00 	. 
	nop			;3058	00 	. 
	nop			;3059	00 	. 
	nop			;305a	00 	. 
	nop			;305b	00 	. 
	nop			;305c	00 	. 
	nop			;305d	00 	. 
	nop			;305e	00 	. 
	nop			;305f	00 	. 
	nop			;3060	00 	. 
	nop			;3061	00 	. 
	nop			;3062	00 	. 
	nop			;3063	00 	. 
	nop			;3064	00 	. 
	nop			;3065	00 	. 
	nop			;3066	00 	. 
	nop			;3067	00 	. 
	nop			;3068	00 	. 
	nop			;3069	00 	. 
	nop			;306a	00 	. 
	nop			;306b	00 	. 
	nop			;306c	00 	. 
	nop			;306d	00 	. 
	nop			;306e	00 	. 
	nop			;306f	00 	. 
	nop			;3070	00 	. 
	nop			;3071	00 	. 
	nop			;3072	00 	. 
	nop			;3073	00 	. 
	nop			;3074	00 	. 
	nop			;3075	00 	. 
	nop			;3076	00 	. 
	nop			;3077	00 	. 
	nop			;3078	00 	. 
	nop			;3079	00 	. 
	nop			;307a	00 	. 
	nop			;307b	00 	. 
	nop			;307c	00 	. 
	nop			;307d	00 	. 
	nop			;307e	00 	. 
	nop			;307f	00 	. 
	nop			;3080	00 	. 
	nop			;3081	00 	. 
	nop			;3082	00 	. 
	nop			;3083	00 	. 
	nop			;3084	00 	. 
	nop			;3085	00 	. 
	nop			;3086	00 	. 
	nop			;3087	00 	. 
	nop			;3088	00 	. 
	nop			;3089	00 	. 
	nop			;308a	00 	. 
	nop			;308b	00 	. 
	nop			;308c	00 	. 
	nop			;308d	00 	. 
	nop			;308e	00 	. 
	nop			;308f	00 	. 
	nop			;3090	00 	. 
	nop			;3091	00 	. 
	nop			;3092	00 	. 
	nop			;3093	00 	. 
	nop			;3094	00 	. 
	nop			;3095	00 	. 
	nop			;3096	00 	. 
	nop			;3097	00 	. 
	nop			;3098	00 	. 
	nop			;3099	00 	. 
	nop			;309a	00 	. 
	nop			;309b	00 	. 
	nop			;309c	00 	. 
	nop			;309d	00 	. 
	nop			;309e	00 	. 
	nop			;309f	00 	. 
	nop			;30a0	00 	. 
	nop			;30a1	00 	. 
	nop			;30a2	00 	. 
	nop			;30a3	00 	. 
	nop			;30a4	00 	. 
	nop			;30a5	00 	. 
	nop			;30a6	00 	. 
	nop			;30a7	00 	. 
	nop			;30a8	00 	. 
	nop			;30a9	00 	. 
	nop			;30aa	00 	. 
	nop			;30ab	00 	. 
	nop			;30ac	00 	. 
	nop			;30ad	00 	. 
	nop			;30ae	00 	. 
	nop			;30af	00 	. 
	nop			;30b0	00 	. 
	nop			;30b1	00 	. 
	nop			;30b2	00 	. 
	nop			;30b3	00 	. 
	nop			;30b4	00 	. 
	nop			;30b5	00 	. 
	nop			;30b6	00 	. 
	nop			;30b7	00 	. 
	nop			;30b8	00 	. 
	nop			;30b9	00 	. 
	nop			;30ba	00 	. 
	nop			;30bb	00 	. 
	nop			;30bc	00 	. 
	nop			;30bd	00 	. 
	nop			;30be	00 	. 
	nop			;30bf	00 	. 
	nop			;30c0	00 	. 
	nop			;30c1	00 	. 
	nop			;30c2	00 	. 
	nop			;30c3	00 	. 
	nop			;30c4	00 	. 
	nop			;30c5	00 	. 
	nop			;30c6	00 	. 
	nop			;30c7	00 	. 
	nop			;30c8	00 	. 
	nop			;30c9	00 	. 
	nop			;30ca	00 	. 
	nop			;30cb	00 	. 
	nop			;30cc	00 	. 
	nop			;30cd	00 	. 
	nop			;30ce	00 	. 
	nop			;30cf	00 	. 
	nop			;30d0	00 	. 
	nop			;30d1	00 	. 
	nop			;30d2	00 	. 
	nop			;30d3	00 	. 
	nop			;30d4	00 	. 
	nop			;30d5	00 	. 
	nop			;30d6	00 	. 
	nop			;30d7	00 	. 
	nop			;30d8	00 	. 
	nop			;30d9	00 	. 
	nop			;30da	00 	. 
	nop			;30db	00 	. 
	nop			;30dc	00 	. 
	nop			;30dd	00 	. 
	nop			;30de	00 	. 
	nop			;30df	00 	. 
	nop			;30e0	00 	. 
	nop			;30e1	00 	. 
	nop			;30e2	00 	. 
	nop			;30e3	00 	. 
	nop			;30e4	00 	. 
	nop			;30e5	00 	. 
	nop			;30e6	00 	. 
	nop			;30e7	00 	. 
	nop			;30e8	00 	. 
	nop			;30e9	00 	. 
	nop			;30ea	00 	. 
	nop			;30eb	00 	. 
	nop			;30ec	00 	. 
	nop			;30ed	00 	. 
	nop			;30ee	00 	. 
	nop			;30ef	00 	. 
	nop			;30f0	00 	. 
	nop			;30f1	00 	. 
	nop			;30f2	00 	. 
	nop			;30f3	00 	. 
	nop			;30f4	00 	. 
	nop			;30f5	00 	. 
	nop			;30f6	00 	. 
	nop			;30f7	00 	. 
	nop			;30f8	00 	. 
	nop			;30f9	00 	. 
	nop			;30fa	00 	. 
	nop			;30fb	00 	. 
	nop			;30fc	00 	. 
	nop			;30fd	00 	. 
	nop			;30fe	00 	. 
	nop			;30ff	00 	. 
	nop			;3100	00 	. 
	nop			;3101	00 	. 
	nop			;3102	00 	. 
	nop			;3103	00 	. 
	nop			;3104	00 	. 
	nop			;3105	00 	. 
	nop			;3106	00 	. 
	nop			;3107	00 	. 
	nop			;3108	00 	. 
	nop			;3109	00 	. 
	nop			;310a	00 	. 
	nop			;310b	00 	. 
	nop			;310c	00 	. 
	nop			;310d	00 	. 
	nop			;310e	00 	. 
	nop			;310f	00 	. 
	nop			;3110	00 	. 
	nop			;3111	00 	. 
	nop			;3112	00 	. 
	nop			;3113	00 	. 
	nop			;3114	00 	. 
	nop			;3115	00 	. 
	nop			;3116	00 	. 
	nop			;3117	00 	. 
	nop			;3118	00 	. 
	nop			;3119	00 	. 
	nop			;311a	00 	. 
	nop			;311b	00 	. 
	nop			;311c	00 	. 
	nop			;311d	00 	. 
	nop			;311e	00 	. 
	nop			;311f	00 	. 
	nop			;3120	00 	. 
	nop			;3121	00 	. 
	nop			;3122	00 	. 
	nop			;3123	00 	. 
	nop			;3124	00 	. 
	nop			;3125	00 	. 
	nop			;3126	00 	. 
	nop			;3127	00 	. 
	nop			;3128	00 	. 
	nop			;3129	00 	. 
	nop			;312a	00 	. 
	nop			;312b	00 	. 
	nop			;312c	00 	. 
	nop			;312d	00 	. 
	nop			;312e	00 	. 
	nop			;312f	00 	. 
	nop			;3130	00 	. 
	nop			;3131	00 	. 
	nop			;3132	00 	. 
	nop			;3133	00 	. 
	nop			;3134	00 	. 
	nop			;3135	00 	. 
	nop			;3136	00 	. 
	nop			;3137	00 	. 
	nop			;3138	00 	. 
	nop			;3139	00 	. 
	nop			;313a	00 	. 
	nop			;313b	00 	. 
	nop			;313c	00 	. 
	nop			;313d	00 	. 
	nop			;313e	00 	. 
	nop			;313f	00 	. 
	nop			;3140	00 	. 
	nop			;3141	00 	. 
	nop			;3142	00 	. 
	nop			;3143	00 	. 
	nop			;3144	00 	. 
	nop			;3145	00 	. 
	nop			;3146	00 	. 
	nop			;3147	00 	. 
	nop			;3148	00 	. 
	nop			;3149	00 	. 
	nop			;314a	00 	. 
	nop			;314b	00 	. 
	nop			;314c	00 	. 
	nop			;314d	00 	. 
	nop			;314e	00 	. 
	nop			;314f	00 	. 
	nop			;3150	00 	. 
	nop			;3151	00 	. 
	nop			;3152	00 	. 
	nop			;3153	00 	. 
	nop			;3154	00 	. 
	nop			;3155	00 	. 
	nop			;3156	00 	. 
	nop			;3157	00 	. 
	nop			;3158	00 	. 
	nop			;3159	00 	. 
	nop			;315a	00 	. 
	nop			;315b	00 	. 
	nop			;315c	00 	. 
	nop			;315d	00 	. 
	nop			;315e	00 	. 
	nop			;315f	00 	. 
	nop			;3160	00 	. 
	nop			;3161	00 	. 
	nop			;3162	00 	. 
	nop			;3163	00 	. 
	nop			;3164	00 	. 
	nop			;3165	00 	. 
	nop			;3166	00 	. 
	nop			;3167	00 	. 
	nop			;3168	00 	. 
	nop			;3169	00 	. 
	nop			;316a	00 	. 
	nop			;316b	00 	. 
	nop			;316c	00 	. 
	nop			;316d	00 	. 
	nop			;316e	00 	. 
	nop			;316f	00 	. 
	nop			;3170	00 	. 
	nop			;3171	00 	. 
	nop			;3172	00 	. 
	nop			;3173	00 	. 
	nop			;3174	00 	. 
	nop			;3175	00 	. 
	nop			;3176	00 	. 
	nop			;3177	00 	. 
	nop			;3178	00 	. 
	nop			;3179	00 	. 
	nop			;317a	00 	. 
	nop			;317b	00 	. 
	nop			;317c	00 	. 
	nop			;317d	00 	. 
	nop			;317e	00 	. 
	nop			;317f	00 	. 
	nop			;3180	00 	. 
	nop			;3181	00 	. 
	nop			;3182	00 	. 
	nop			;3183	00 	. 
	nop			;3184	00 	. 
	nop			;3185	00 	. 
	nop			;3186	00 	. 
	nop			;3187	00 	. 
	nop			;3188	00 	. 
	nop			;3189	00 	. 
	nop			;318a	00 	. 
	nop			;318b	00 	. 
	nop			;318c	00 	. 
	nop			;318d	00 	. 
	nop			;318e	00 	. 
	nop			;318f	00 	. 
	nop			;3190	00 	. 
	nop			;3191	00 	. 
	nop			;3192	00 	. 
	nop			;3193	00 	. 
	nop			;3194	00 	. 
	nop			;3195	00 	. 
	nop			;3196	00 	. 
	nop			;3197	00 	. 
	nop			;3198	00 	. 
	nop			;3199	00 	. 
	nop			;319a	00 	. 
	nop			;319b	00 	. 
	nop			;319c	00 	. 
	nop			;319d	00 	. 
	nop			;319e	00 	. 
	nop			;319f	00 	. 
	nop			;31a0	00 	. 
	nop			;31a1	00 	. 
	nop			;31a2	00 	. 
	nop			;31a3	00 	. 
	nop			;31a4	00 	. 
	nop			;31a5	00 	. 
	nop			;31a6	00 	. 
	nop			;31a7	00 	. 
	nop			;31a8	00 	. 
	nop			;31a9	00 	. 
	nop			;31aa	00 	. 
	nop			;31ab	00 	. 
	nop			;31ac	00 	. 
	nop			;31ad	00 	. 
	nop			;31ae	00 	. 
	nop			;31af	00 	. 
	nop			;31b0	00 	. 
	nop			;31b1	00 	. 
	nop			;31b2	00 	. 
	nop			;31b3	00 	. 
	nop			;31b4	00 	. 
	nop			;31b5	00 	. 
	nop			;31b6	00 	. 
	nop			;31b7	00 	. 
	nop			;31b8	00 	. 
	nop			;31b9	00 	. 
	nop			;31ba	00 	. 
	nop			;31bb	00 	. 
	nop			;31bc	00 	. 
	nop			;31bd	00 	. 
	nop			;31be	00 	. 
	nop			;31bf	00 	. 
	nop			;31c0	00 	. 
	nop			;31c1	00 	. 
	nop			;31c2	00 	. 
	nop			;31c3	00 	. 
	nop			;31c4	00 	. 
	nop			;31c5	00 	. 
	nop			;31c6	00 	. 
	nop			;31c7	00 	. 
	nop			;31c8	00 	. 
	nop			;31c9	00 	. 
	nop			;31ca	00 	. 
	nop			;31cb	00 	. 
	nop			;31cc	00 	. 
	nop			;31cd	00 	. 
	nop			;31ce	00 	. 
	nop			;31cf	00 	. 
	nop			;31d0	00 	. 
	nop			;31d1	00 	. 
	nop			;31d2	00 	. 
	nop			;31d3	00 	. 
	nop			;31d4	00 	. 
	nop			;31d5	00 	. 
	nop			;31d6	00 	. 
	nop			;31d7	00 	. 
	nop			;31d8	00 	. 
	nop			;31d9	00 	. 
	nop			;31da	00 	. 
	nop			;31db	00 	. 
	nop			;31dc	00 	. 
	nop			;31dd	00 	. 
	nop			;31de	00 	. 
	nop			;31df	00 	. 
	nop			;31e0	00 	. 
	nop			;31e1	00 	. 
	nop			;31e2	00 	. 
	nop			;31e3	00 	. 
	nop			;31e4	00 	. 
	nop			;31e5	00 	. 
	nop			;31e6	00 	. 
	nop			;31e7	00 	. 
	nop			;31e8	00 	. 
	nop			;31e9	00 	. 
	nop			;31ea	00 	. 
	nop			;31eb	00 	. 
	nop			;31ec	00 	. 
	nop			;31ed	00 	. 
	nop			;31ee	00 	. 
	nop			;31ef	00 	. 
	nop			;31f0	00 	. 
	nop			;31f1	00 	. 
	nop			;31f2	00 	. 
	nop			;31f3	00 	. 
	nop			;31f4	00 	. 
	nop			;31f5	00 	. 
	nop			;31f6	00 	. 
	nop			;31f7	00 	. 
	nop			;31f8	00 	. 
	nop			;31f9	00 	. 
	nop			;31fa	00 	. 
	nop			;31fb	00 	. 
	nop			;31fc	00 	. 
	nop			;31fd	00 	. 
	nop			;31fe	00 	. 
	nop			;31ff	00 	. 
	nop			;3200	00 	. 
	nop			;3201	00 	. 
	nop			;3202	00 	. 
	nop			;3203	00 	. 
	nop			;3204	00 	. 
	nop			;3205	00 	. 
	nop			;3206	00 	. 
	nop			;3207	00 	. 
	nop			;3208	00 	. 
	nop			;3209	00 	. 
	nop			;320a	00 	. 
	nop			;320b	00 	. 
	nop			;320c	00 	. 
	nop			;320d	00 	. 
	nop			;320e	00 	. 
	nop			;320f	00 	. 
	nop			;3210	00 	. 
	nop			;3211	00 	. 
	nop			;3212	00 	. 
	nop			;3213	00 	. 
	nop			;3214	00 	. 
	nop			;3215	00 	. 
	nop			;3216	00 	. 
	nop			;3217	00 	. 
	nop			;3218	00 	. 
	nop			;3219	00 	. 
	nop			;321a	00 	. 
	nop			;321b	00 	. 
	nop			;321c	00 	. 
	nop			;321d	00 	. 
	nop			;321e	00 	. 
	nop			;321f	00 	. 
	nop			;3220	00 	. 
	nop			;3221	00 	. 
	nop			;3222	00 	. 
	nop			;3223	00 	. 
	nop			;3224	00 	. 
	nop			;3225	00 	. 
	nop			;3226	00 	. 
	nop			;3227	00 	. 
	nop			;3228	00 	. 
	nop			;3229	00 	. 
	nop			;322a	00 	. 
	nop			;322b	00 	. 
	nop			;322c	00 	. 
	nop			;322d	00 	. 
	nop			;322e	00 	. 
	nop			;322f	00 	. 
	nop			;3230	00 	. 
	nop			;3231	00 	. 
	nop			;3232	00 	. 
	nop			;3233	00 	. 
	nop			;3234	00 	. 
	nop			;3235	00 	. 
	nop			;3236	00 	. 
	nop			;3237	00 	. 
	nop			;3238	00 	. 
	nop			;3239	00 	. 
	nop			;323a	00 	. 
	nop			;323b	00 	. 
	nop			;323c	00 	. 
	nop			;323d	00 	. 
	nop			;323e	00 	. 
	nop			;323f	00 	. 
	nop			;3240	00 	. 
	nop			;3241	00 	. 
	nop			;3242	00 	. 
	nop			;3243	00 	. 
	nop			;3244	00 	. 
	nop			;3245	00 	. 
	nop			;3246	00 	. 
	nop			;3247	00 	. 
	nop			;3248	00 	. 
	nop			;3249	00 	. 
	nop			;324a	00 	. 
	nop			;324b	00 	. 
	nop			;324c	00 	. 
	nop			;324d	00 	. 
	nop			;324e	00 	. 
	nop			;324f	00 	. 
	nop			;3250	00 	. 
	nop			;3251	00 	. 
	nop			;3252	00 	. 
	nop			;3253	00 	. 
	nop			;3254	00 	. 
	nop			;3255	00 	. 
	nop			;3256	00 	. 
	nop			;3257	00 	. 
	nop			;3258	00 	. 
	nop			;3259	00 	. 
	nop			;325a	00 	. 
	nop			;325b	00 	. 
	nop			;325c	00 	. 
	nop			;325d	00 	. 
	nop			;325e	00 	. 
	nop			;325f	00 	. 
	nop			;3260	00 	. 
	nop			;3261	00 	. 
	nop			;3262	00 	. 
	nop			;3263	00 	. 
	nop			;3264	00 	. 
	nop			;3265	00 	. 
	nop			;3266	00 	. 
	nop			;3267	00 	. 
	nop			;3268	00 	. 
	nop			;3269	00 	. 
	nop			;326a	00 	. 
	nop			;326b	00 	. 
	nop			;326c	00 	. 
	nop			;326d	00 	. 
	nop			;326e	00 	. 
	nop			;326f	00 	. 
	nop			;3270	00 	. 
	nop			;3271	00 	. 
	nop			;3272	00 	. 
	nop			;3273	00 	. 
	nop			;3274	00 	. 
	nop			;3275	00 	. 
	nop			;3276	00 	. 
	nop			;3277	00 	. 
	nop			;3278	00 	. 
	nop			;3279	00 	. 
	nop			;327a	00 	. 
	nop			;327b	00 	. 
	nop			;327c	00 	. 
	nop			;327d	00 	. 
	nop			;327e	00 	. 
	nop			;327f	00 	. 
	nop			;3280	00 	. 
	nop			;3281	00 	. 
	nop			;3282	00 	. 
	nop			;3283	00 	. 
	nop			;3284	00 	. 
	nop			;3285	00 	. 
	nop			;3286	00 	. 
	nop			;3287	00 	. 
	nop			;3288	00 	. 
	nop			;3289	00 	. 
	nop			;328a	00 	. 
	nop			;328b	00 	. 
	nop			;328c	00 	. 
	nop			;328d	00 	. 
	nop			;328e	00 	. 
	nop			;328f	00 	. 
	nop			;3290	00 	. 
	nop			;3291	00 	. 
	nop			;3292	00 	. 
	nop			;3293	00 	. 
	nop			;3294	00 	. 
	nop			;3295	00 	. 
	nop			;3296	00 	. 
	nop			;3297	00 	. 
	nop			;3298	00 	. 
	nop			;3299	00 	. 
	nop			;329a	00 	. 
	nop			;329b	00 	. 
	nop			;329c	00 	. 
	nop			;329d	00 	. 
	nop			;329e	00 	. 
	nop			;329f	00 	. 
	nop			;32a0	00 	. 
	nop			;32a1	00 	. 
	nop			;32a2	00 	. 
	nop			;32a3	00 	. 
	nop			;32a4	00 	. 
	nop			;32a5	00 	. 
	nop			;32a6	00 	. 
	nop			;32a7	00 	. 
	nop			;32a8	00 	. 
	nop			;32a9	00 	. 
	nop			;32aa	00 	. 
	nop			;32ab	00 	. 
	nop			;32ac	00 	. 
	nop			;32ad	00 	. 
	nop			;32ae	00 	. 
	nop			;32af	00 	. 
	nop			;32b0	00 	. 
	nop			;32b1	00 	. 
	nop			;32b2	00 	. 
	nop			;32b3	00 	. 
	nop			;32b4	00 	. 
	nop			;32b5	00 	. 
	nop			;32b6	00 	. 
	nop			;32b7	00 	. 
	nop			;32b8	00 	. 
	nop			;32b9	00 	. 
	nop			;32ba	00 	. 
	nop			;32bb	00 	. 
	nop			;32bc	00 	. 
	nop			;32bd	00 	. 
	nop			;32be	00 	. 
	nop			;32bf	00 	. 
	nop			;32c0	00 	. 
	nop			;32c1	00 	. 
	nop			;32c2	00 	. 
	nop			;32c3	00 	. 
	nop			;32c4	00 	. 
	nop			;32c5	00 	. 
	nop			;32c6	00 	. 
	nop			;32c7	00 	. 
	nop			;32c8	00 	. 
	nop			;32c9	00 	. 
	nop			;32ca	00 	. 
	nop			;32cb	00 	. 
	nop			;32cc	00 	. 
	nop			;32cd	00 	. 
	nop			;32ce	00 	. 
	nop			;32cf	00 	. 
	nop			;32d0	00 	. 
	nop			;32d1	00 	. 
	nop			;32d2	00 	. 
	nop			;32d3	00 	. 
	nop			;32d4	00 	. 
	nop			;32d5	00 	. 
	nop			;32d6	00 	. 
	nop			;32d7	00 	. 
	nop			;32d8	00 	. 
	nop			;32d9	00 	. 
	nop			;32da	00 	. 
	nop			;32db	00 	. 
	nop			;32dc	00 	. 
	nop			;32dd	00 	. 
	nop			;32de	00 	. 
	nop			;32df	00 	. 
	nop			;32e0	00 	. 
	nop			;32e1	00 	. 
	nop			;32e2	00 	. 
	nop			;32e3	00 	. 
	nop			;32e4	00 	. 
	nop			;32e5	00 	. 
	nop			;32e6	00 	. 
	nop			;32e7	00 	. 
	nop			;32e8	00 	. 
	nop			;32e9	00 	. 
	nop			;32ea	00 	. 
	nop			;32eb	00 	. 
	nop			;32ec	00 	. 
	nop			;32ed	00 	. 
	nop			;32ee	00 	. 
	nop			;32ef	00 	. 
	nop			;32f0	00 	. 
	nop			;32f1	00 	. 
	nop			;32f2	00 	. 
	nop			;32f3	00 	. 
	nop			;32f4	00 	. 
	nop			;32f5	00 	. 
	nop			;32f6	00 	. 
	nop			;32f7	00 	. 
	nop			;32f8	00 	. 
	nop			;32f9	00 	. 
	nop			;32fa	00 	. 
	nop			;32fb	00 	. 
	nop			;32fc	00 	. 
	nop			;32fd	00 	. 
	nop			;32fe	00 	. 
	nop			;32ff	00 	. 
	nop			;3300	00 	. 
	nop			;3301	00 	. 
	nop			;3302	00 	. 
	nop			;3303	00 	. 
	nop			;3304	00 	. 
	nop			;3305	00 	. 
	nop			;3306	00 	. 
	nop			;3307	00 	. 
	nop			;3308	00 	. 
	nop			;3309	00 	. 
	nop			;330a	00 	. 
	nop			;330b	00 	. 
	nop			;330c	00 	. 
	nop			;330d	00 	. 
	nop			;330e	00 	. 
	nop			;330f	00 	. 
	nop			;3310	00 	. 
	nop			;3311	00 	. 
	nop			;3312	00 	. 
	nop			;3313	00 	. 
	nop			;3314	00 	. 
	nop			;3315	00 	. 
	nop			;3316	00 	. 
	nop			;3317	00 	. 
	nop			;3318	00 	. 
	nop			;3319	00 	. 
	nop			;331a	00 	. 
	nop			;331b	00 	. 
	nop			;331c	00 	. 
	nop			;331d	00 	. 
	nop			;331e	00 	. 
	nop			;331f	00 	. 
	nop			;3320	00 	. 
	nop			;3321	00 	. 
	nop			;3322	00 	. 
	nop			;3323	00 	. 
	nop			;3324	00 	. 
	nop			;3325	00 	. 
	nop			;3326	00 	. 
	nop			;3327	00 	. 
	nop			;3328	00 	. 
	nop			;3329	00 	. 
	nop			;332a	00 	. 
	nop			;332b	00 	. 
	nop			;332c	00 	. 
	nop			;332d	00 	. 
	nop			;332e	00 	. 
	nop			;332f	00 	. 
	nop			;3330	00 	. 
	nop			;3331	00 	. 
	nop			;3332	00 	. 
	nop			;3333	00 	. 
	nop			;3334	00 	. 
	nop			;3335	00 	. 
	nop			;3336	00 	. 
	nop			;3337	00 	. 
	nop			;3338	00 	. 
	nop			;3339	00 	. 
	nop			;333a	00 	. 
	nop			;333b	00 	. 
	nop			;333c	00 	. 
	nop			;333d	00 	. 
	nop			;333e	00 	. 
	nop			;333f	00 	. 
	nop			;3340	00 	. 
	nop			;3341	00 	. 
	nop			;3342	00 	. 
	nop			;3343	00 	. 
	nop			;3344	00 	. 
	nop			;3345	00 	. 
	nop			;3346	00 	. 
	nop			;3347	00 	. 
	nop			;3348	00 	. 
	nop			;3349	00 	. 
	nop			;334a	00 	. 
	nop			;334b	00 	. 
	nop			;334c	00 	. 
	nop			;334d	00 	. 
	nop			;334e	00 	. 
	nop			;334f	00 	. 
	nop			;3350	00 	. 
	nop			;3351	00 	. 
	nop			;3352	00 	. 
	nop			;3353	00 	. 
	nop			;3354	00 	. 
	nop			;3355	00 	. 
	nop			;3356	00 	. 
	nop			;3357	00 	. 
	nop			;3358	00 	. 
	nop			;3359	00 	. 
	nop			;335a	00 	. 
	nop			;335b	00 	. 
	nop			;335c	00 	. 
	nop			;335d	00 	. 
	nop			;335e	00 	. 
	nop			;335f	00 	. 
	nop			;3360	00 	. 
	nop			;3361	00 	. 
	nop			;3362	00 	. 
	nop			;3363	00 	. 
	nop			;3364	00 	. 
	nop			;3365	00 	. 
	nop			;3366	00 	. 
	nop			;3367	00 	. 
	nop			;3368	00 	. 
	nop			;3369	00 	. 
	nop			;336a	00 	. 
	nop			;336b	00 	. 
	nop			;336c	00 	. 
	nop			;336d	00 	. 
	nop			;336e	00 	. 
	nop			;336f	00 	. 
	nop			;3370	00 	. 
	nop			;3371	00 	. 
	nop			;3372	00 	. 
	nop			;3373	00 	. 
	nop			;3374	00 	. 
	nop			;3375	00 	. 
	nop			;3376	00 	. 
	nop			;3377	00 	. 
	nop			;3378	00 	. 
	nop			;3379	00 	. 
	nop			;337a	00 	. 
	nop			;337b	00 	. 
	nop			;337c	00 	. 
	nop			;337d	00 	. 
	nop			;337e	00 	. 
	nop			;337f	00 	. 
	nop			;3380	00 	. 
	nop			;3381	00 	. 
	nop			;3382	00 	. 
	nop			;3383	00 	. 
	nop			;3384	00 	. 
	nop			;3385	00 	. 
	nop			;3386	00 	. 
	nop			;3387	00 	. 
	nop			;3388	00 	. 
	nop			;3389	00 	. 
	nop			;338a	00 	. 
	nop			;338b	00 	. 
	nop			;338c	00 	. 
	nop			;338d	00 	. 
	nop			;338e	00 	. 
	nop			;338f	00 	. 
	nop			;3390	00 	. 
	nop			;3391	00 	. 
	nop			;3392	00 	. 
	nop			;3393	00 	. 
	nop			;3394	00 	. 
	nop			;3395	00 	. 
	nop			;3396	00 	. 
	nop			;3397	00 	. 
	nop			;3398	00 	. 
	nop			;3399	00 	. 
	nop			;339a	00 	. 
	nop			;339b	00 	. 
	nop			;339c	00 	. 
	nop			;339d	00 	. 
	nop			;339e	00 	. 
	nop			;339f	00 	. 
	nop			;33a0	00 	. 
	nop			;33a1	00 	. 
	nop			;33a2	00 	. 
	nop			;33a3	00 	. 
	nop			;33a4	00 	. 
	nop			;33a5	00 	. 
	nop			;33a6	00 	. 
	nop			;33a7	00 	. 
	nop			;33a8	00 	. 
	nop			;33a9	00 	. 
	nop			;33aa	00 	. 
	nop			;33ab	00 	. 
	nop			;33ac	00 	. 
	nop			;33ad	00 	. 
	nop			;33ae	00 	. 
	nop			;33af	00 	. 
	nop			;33b0	00 	. 
	nop			;33b1	00 	. 
	nop			;33b2	00 	. 
	nop			;33b3	00 	. 
	nop			;33b4	00 	. 
	nop			;33b5	00 	. 
	nop			;33b6	00 	. 
	nop			;33b7	00 	. 
	nop			;33b8	00 	. 
	nop			;33b9	00 	. 
	nop			;33ba	00 	. 
	nop			;33bb	00 	. 
	nop			;33bc	00 	. 
	nop			;33bd	00 	. 
	nop			;33be	00 	. 
	nop			;33bf	00 	. 
	nop			;33c0	00 	. 
	nop			;33c1	00 	. 
	nop			;33c2	00 	. 
	nop			;33c3	00 	. 
	nop			;33c4	00 	. 
	nop			;33c5	00 	. 
	nop			;33c6	00 	. 
	nop			;33c7	00 	. 
	nop			;33c8	00 	. 
	nop			;33c9	00 	. 
	nop			;33ca	00 	. 
	nop			;33cb	00 	. 
	nop			;33cc	00 	. 
	nop			;33cd	00 	. 
	nop			;33ce	00 	. 
	nop			;33cf	00 	. 
	nop			;33d0	00 	. 
	nop			;33d1	00 	. 
	nop			;33d2	00 	. 
	nop			;33d3	00 	. 
	nop			;33d4	00 	. 
	nop			;33d5	00 	. 
	nop			;33d6	00 	. 
	nop			;33d7	00 	. 
	nop			;33d8	00 	. 
	nop			;33d9	00 	. 
	nop			;33da	00 	. 
	nop			;33db	00 	. 
	nop			;33dc	00 	. 
	nop			;33dd	00 	. 
	nop			;33de	00 	. 
	nop			;33df	00 	. 
	nop			;33e0	00 	. 
	nop			;33e1	00 	. 
	nop			;33e2	00 	. 
	nop			;33e3	00 	. 
	nop			;33e4	00 	. 
	nop			;33e5	00 	. 
	nop			;33e6	00 	. 
	nop			;33e7	00 	. 
	nop			;33e8	00 	. 
	nop			;33e9	00 	. 
	nop			;33ea	00 	. 
	nop			;33eb	00 	. 
	nop			;33ec	00 	. 
	nop			;33ed	00 	. 
	nop			;33ee	00 	. 
	nop			;33ef	00 	. 
	nop			;33f0	00 	. 
	nop			;33f1	00 	. 
	nop			;33f2	00 	. 
	nop			;33f3	00 	. 
	nop			;33f4	00 	. 
	nop			;33f5	00 	. 
	nop			;33f6	00 	. 
	nop			;33f7	00 	. 
	nop			;33f8	00 	. 
	nop			;33f9	00 	. 
	nop			;33fa	00 	. 
	nop			;33fb	00 	. 
	nop			;33fc	00 	. 
	nop			;33fd	00 	. 
	nop			;33fe	00 	. 
	nop			;33ff	00 	. 
	nop			;3400	00 	. 
	nop			;3401	00 	. 
	nop			;3402	00 	. 
	nop			;3403	00 	. 
	nop			;3404	00 	. 
	nop			;3405	00 	. 
	nop			;3406	00 	. 
	nop			;3407	00 	. 
	nop			;3408	00 	. 
	nop			;3409	00 	. 
	nop			;340a	00 	. 
	nop			;340b	00 	. 
	nop			;340c	00 	. 
	nop			;340d	00 	. 
	nop			;340e	00 	. 
	nop			;340f	00 	. 
	nop			;3410	00 	. 
	nop			;3411	00 	. 
	nop			;3412	00 	. 
	nop			;3413	00 	. 
	nop			;3414	00 	. 
	nop			;3415	00 	. 
	nop			;3416	00 	. 
	nop			;3417	00 	. 
	nop			;3418	00 	. 
	nop			;3419	00 	. 
	nop			;341a	00 	. 
	nop			;341b	00 	. 
	nop			;341c	00 	. 
	nop			;341d	00 	. 
	nop			;341e	00 	. 
	nop			;341f	00 	. 
	nop			;3420	00 	. 
	nop			;3421	00 	. 
	nop			;3422	00 	. 
	nop			;3423	00 	. 
	nop			;3424	00 	. 
	nop			;3425	00 	. 
	nop			;3426	00 	. 
	nop			;3427	00 	. 
	nop			;3428	00 	. 
	nop			;3429	00 	. 
	nop			;342a	00 	. 
	nop			;342b	00 	. 
	nop			;342c	00 	. 
	nop			;342d	00 	. 
	nop			;342e	00 	. 
	nop			;342f	00 	. 
	nop			;3430	00 	. 
	nop			;3431	00 	. 
	nop			;3432	00 	. 
l3433h:
	nop			;3433	00 	. 
	nop			;3434	00 	. 
	nop			;3435	00 	. 
	nop			;3436	00 	. 
	nop			;3437	00 	. 
	nop			;3438	00 	. 
	nop			;3439	00 	. 
	nop			;343a	00 	. 
	nop			;343b	00 	. 
	nop			;343c	00 	. 
	nop			;343d	00 	. 
	nop			;343e	00 	. 
	nop			;343f	00 	. 
	nop			;3440	00 	. 
	nop			;3441	00 	. 
	nop			;3442	00 	. 
	nop			;3443	00 	. 
	nop			;3444	00 	. 
	nop			;3445	00 	. 
	nop			;3446	00 	. 
	nop			;3447	00 	. 
	nop			;3448	00 	. 
	nop			;3449	00 	. 
	nop			;344a	00 	. 
	nop			;344b	00 	. 
	nop			;344c	00 	. 
	nop			;344d	00 	. 
	nop			;344e	00 	. 
	nop			;344f	00 	. 
	nop			;3450	00 	. 
	nop			;3451	00 	. 
	nop			;3452	00 	. 
	nop			;3453	00 	. 
	nop			;3454	00 	. 
	nop			;3455	00 	. 
	nop			;3456	00 	. 
	nop			;3457	00 	. 
	nop			;3458	00 	. 
	nop			;3459	00 	. 
	nop			;345a	00 	. 
	nop			;345b	00 	. 
	nop			;345c	00 	. 
	nop			;345d	00 	. 
	nop			;345e	00 	. 
	nop			;345f	00 	. 
	nop			;3460	00 	. 
	nop			;3461	00 	. 
	nop			;3462	00 	. 
	nop			;3463	00 	. 
	nop			;3464	00 	. 
	nop			;3465	00 	. 
	nop			;3466	00 	. 
	nop			;3467	00 	. 
	nop			;3468	00 	. 
	nop			;3469	00 	. 
	nop			;346a	00 	. 
	nop			;346b	00 	. 
	nop			;346c	00 	. 
	nop			;346d	00 	. 
	nop			;346e	00 	. 
	nop			;346f	00 	. 
	nop			;3470	00 	. 
	nop			;3471	00 	. 
	nop			;3472	00 	. 
	nop			;3473	00 	. 
	nop			;3474	00 	. 
	nop			;3475	00 	. 
	nop			;3476	00 	. 
	nop			;3477	00 	. 
	nop			;3478	00 	. 
	nop			;3479	00 	. 
	nop			;347a	00 	. 
	nop			;347b	00 	. 
	nop			;347c	00 	. 
	nop			;347d	00 	. 
	nop			;347e	00 	. 
	nop			;347f	00 	. 
	nop			;3480	00 	. 
	nop			;3481	00 	. 
	nop			;3482	00 	. 
	nop			;3483	00 	. 
	nop			;3484	00 	. 
	nop			;3485	00 	. 
	nop			;3486	00 	. 
	nop			;3487	00 	. 
	nop			;3488	00 	. 
	nop			;3489	00 	. 
	nop			;348a	00 	. 
	nop			;348b	00 	. 
	nop			;348c	00 	. 
	nop			;348d	00 	. 
	nop			;348e	00 	. 
	nop			;348f	00 	. 
	nop			;3490	00 	. 
	nop			;3491	00 	. 
	nop			;3492	00 	. 
	nop			;3493	00 	. 
	nop			;3494	00 	. 
	nop			;3495	00 	. 
	nop			;3496	00 	. 
	nop			;3497	00 	. 
	nop			;3498	00 	. 
	nop			;3499	00 	. 
	nop			;349a	00 	. 
	nop			;349b	00 	. 
	nop			;349c	00 	. 
	nop			;349d	00 	. 
	nop			;349e	00 	. 
	nop			;349f	00 	. 
	nop			;34a0	00 	. 
	nop			;34a1	00 	. 
	nop			;34a2	00 	. 
	nop			;34a3	00 	. 
	nop			;34a4	00 	. 
	nop			;34a5	00 	. 
	nop			;34a6	00 	. 
	nop			;34a7	00 	. 
	nop			;34a8	00 	. 
	nop			;34a9	00 	. 
	nop			;34aa	00 	. 
	nop			;34ab	00 	. 
	nop			;34ac	00 	. 
	nop			;34ad	00 	. 
	nop			;34ae	00 	. 
	nop			;34af	00 	. 
	nop			;34b0	00 	. 
	nop			;34b1	00 	. 
	nop			;34b2	00 	. 
	nop			;34b3	00 	. 
	nop			;34b4	00 	. 
	nop			;34b5	00 	. 
	nop			;34b6	00 	. 
	nop			;34b7	00 	. 
	nop			;34b8	00 	. 
	nop			;34b9	00 	. 
	nop			;34ba	00 	. 
	nop			;34bb	00 	. 
	nop			;34bc	00 	. 
	nop			;34bd	00 	. 
	nop			;34be	00 	. 
	nop			;34bf	00 	. 
	nop			;34c0	00 	. 
	nop			;34c1	00 	. 
	nop			;34c2	00 	. 
	nop			;34c3	00 	. 
	nop			;34c4	00 	. 
	nop			;34c5	00 	. 
	nop			;34c6	00 	. 
	nop			;34c7	00 	. 
	nop			;34c8	00 	. 
	nop			;34c9	00 	. 
	nop			;34ca	00 	. 
	nop			;34cb	00 	. 
	nop			;34cc	00 	. 
	nop			;34cd	00 	. 
	nop			;34ce	00 	. 
	nop			;34cf	00 	. 
	nop			;34d0	00 	. 
	nop			;34d1	00 	. 
	nop			;34d2	00 	. 
	nop			;34d3	00 	. 
	nop			;34d4	00 	. 
	nop			;34d5	00 	. 
	nop			;34d6	00 	. 
	nop			;34d7	00 	. 
	nop			;34d8	00 	. 
	nop			;34d9	00 	. 
	nop			;34da	00 	. 
	nop			;34db	00 	. 
	nop			;34dc	00 	. 
	nop			;34dd	00 	. 
	nop			;34de	00 	. 
	nop			;34df	00 	. 
	nop			;34e0	00 	. 
	nop			;34e1	00 	. 
	nop			;34e2	00 	. 
	nop			;34e3	00 	. 
	nop			;34e4	00 	. 
	nop			;34e5	00 	. 
	nop			;34e6	00 	. 
	nop			;34e7	00 	. 
	nop			;34e8	00 	. 
	nop			;34e9	00 	. 
	nop			;34ea	00 	. 
	nop			;34eb	00 	. 
	nop			;34ec	00 	. 
	nop			;34ed	00 	. 
	nop			;34ee	00 	. 
	nop			;34ef	00 	. 
	nop			;34f0	00 	. 
	nop			;34f1	00 	. 
	nop			;34f2	00 	. 
	nop			;34f3	00 	. 
	nop			;34f4	00 	. 
	nop			;34f5	00 	. 
	nop			;34f6	00 	. 
	nop			;34f7	00 	. 
	nop			;34f8	00 	. 
	nop			;34f9	00 	. 
	nop			;34fa	00 	. 
	nop			;34fb	00 	. 
	nop			;34fc	00 	. 
	nop			;34fd	00 	. 
	nop			;34fe	00 	. 
	nop			;34ff	00 	. 
	nop			;3500	00 	. 
	nop			;3501	00 	. 
	nop			;3502	00 	. 
	nop			;3503	00 	. 
	nop			;3504	00 	. 
	nop			;3505	00 	. 
	nop			;3506	00 	. 
	nop			;3507	00 	. 
	nop			;3508	00 	. 
	nop			;3509	00 	. 
	nop			;350a	00 	. 
	nop			;350b	00 	. 
	nop			;350c	00 	. 
	nop			;350d	00 	. 
	nop			;350e	00 	. 
	nop			;350f	00 	. 
	nop			;3510	00 	. 
	nop			;3511	00 	. 
	nop			;3512	00 	. 
	nop			;3513	00 	. 
	nop			;3514	00 	. 
	nop			;3515	00 	. 
	nop			;3516	00 	. 
	nop			;3517	00 	. 
	nop			;3518	00 	. 
	nop			;3519	00 	. 
	nop			;351a	00 	. 
	nop			;351b	00 	. 
	nop			;351c	00 	. 
	nop			;351d	00 	. 
	nop			;351e	00 	. 
	nop			;351f	00 	. 
	nop			;3520	00 	. 
	nop			;3521	00 	. 
	nop			;3522	00 	. 
	nop			;3523	00 	. 
	nop			;3524	00 	. 
	nop			;3525	00 	. 
	nop			;3526	00 	. 
	nop			;3527	00 	. 
	nop			;3528	00 	. 
	nop			;3529	00 	. 
	nop			;352a	00 	. 
	nop			;352b	00 	. 
	nop			;352c	00 	. 
	nop			;352d	00 	. 
	nop			;352e	00 	. 
	nop			;352f	00 	. 
	nop			;3530	00 	. 
	nop			;3531	00 	. 
	nop			;3532	00 	. 
	nop			;3533	00 	. 
	nop			;3534	00 	. 
	nop			;3535	00 	. 
	nop			;3536	00 	. 
	nop			;3537	00 	. 
	nop			;3538	00 	. 
	nop			;3539	00 	. 
	nop			;353a	00 	. 
	nop			;353b	00 	. 
	nop			;353c	00 	. 
	nop			;353d	00 	. 
	nop			;353e	00 	. 
	nop			;353f	00 	. 
	nop			;3540	00 	. 
	nop			;3541	00 	. 
	nop			;3542	00 	. 
	nop			;3543	00 	. 
	nop			;3544	00 	. 
	nop			;3545	00 	. 
	nop			;3546	00 	. 
	nop			;3547	00 	. 
	nop			;3548	00 	. 
	nop			;3549	00 	. 
	nop			;354a	00 	. 
	nop			;354b	00 	. 
	nop			;354c	00 	. 
	nop			;354d	00 	. 
	nop			;354e	00 	. 
	nop			;354f	00 	. 
	nop			;3550	00 	. 
	nop			;3551	00 	. 
	nop			;3552	00 	. 
	nop			;3553	00 	. 
	nop			;3554	00 	. 
	nop			;3555	00 	. 
	nop			;3556	00 	. 
	nop			;3557	00 	. 
	nop			;3558	00 	. 
	nop			;3559	00 	. 
	nop			;355a	00 	. 
	nop			;355b	00 	. 
	nop			;355c	00 	. 
	nop			;355d	00 	. 
	nop			;355e	00 	. 
	nop			;355f	00 	. 
	nop			;3560	00 	. 
	nop			;3561	00 	. 
	nop			;3562	00 	. 
	nop			;3563	00 	. 
	nop			;3564	00 	. 
	nop			;3565	00 	. 
	nop			;3566	00 	. 
	nop			;3567	00 	. 
	nop			;3568	00 	. 
	nop			;3569	00 	. 
	nop			;356a	00 	. 
	nop			;356b	00 	. 
	nop			;356c	00 	. 
	nop			;356d	00 	. 
	nop			;356e	00 	. 
	nop			;356f	00 	. 
	nop			;3570	00 	. 
	nop			;3571	00 	. 
	nop			;3572	00 	. 
	nop			;3573	00 	. 
	nop			;3574	00 	. 
	nop			;3575	00 	. 
	nop			;3576	00 	. 
	nop			;3577	00 	. 
	nop			;3578	00 	. 
	nop			;3579	00 	. 
	nop			;357a	00 	. 
	nop			;357b	00 	. 
	nop			;357c	00 	. 
	nop			;357d	00 	. 
	nop			;357e	00 	. 
	nop			;357f	00 	. 
	nop			;3580	00 	. 
	nop			;3581	00 	. 
	nop			;3582	00 	. 
	nop			;3583	00 	. 
	nop			;3584	00 	. 
	nop			;3585	00 	. 
	nop			;3586	00 	. 
	nop			;3587	00 	. 
	nop			;3588	00 	. 
	nop			;3589	00 	. 
	nop			;358a	00 	. 
	nop			;358b	00 	. 
	nop			;358c	00 	. 
	nop			;358d	00 	. 
	nop			;358e	00 	. 
	nop			;358f	00 	. 
	nop			;3590	00 	. 
	nop			;3591	00 	. 
	nop			;3592	00 	. 
	nop			;3593	00 	. 
	nop			;3594	00 	. 
	nop			;3595	00 	. 
	nop			;3596	00 	. 
	nop			;3597	00 	. 
	nop			;3598	00 	. 
	nop			;3599	00 	. 
	nop			;359a	00 	. 
	nop			;359b	00 	. 
	nop			;359c	00 	. 
	nop			;359d	00 	. 
	nop			;359e	00 	. 
	nop			;359f	00 	. 
	nop			;35a0	00 	. 
	nop			;35a1	00 	. 
	nop			;35a2	00 	. 
	nop			;35a3	00 	. 
	nop			;35a4	00 	. 
	nop			;35a5	00 	. 
	nop			;35a6	00 	. 
	nop			;35a7	00 	. 
	nop			;35a8	00 	. 
	nop			;35a9	00 	. 
	nop			;35aa	00 	. 
	nop			;35ab	00 	. 
	nop			;35ac	00 	. 
	nop			;35ad	00 	. 
	nop			;35ae	00 	. 
	nop			;35af	00 	. 
	nop			;35b0	00 	. 
	nop			;35b1	00 	. 
	nop			;35b2	00 	. 
	nop			;35b3	00 	. 
	nop			;35b4	00 	. 
	nop			;35b5	00 	. 
	nop			;35b6	00 	. 
	nop			;35b7	00 	. 
	nop			;35b8	00 	. 
	nop			;35b9	00 	. 
	nop			;35ba	00 	. 
	nop			;35bb	00 	. 
	nop			;35bc	00 	. 
	nop			;35bd	00 	. 
	nop			;35be	00 	. 
	nop			;35bf	00 	. 
	nop			;35c0	00 	. 
	nop			;35c1	00 	. 
	nop			;35c2	00 	. 
	nop			;35c3	00 	. 
	nop			;35c4	00 	. 
	nop			;35c5	00 	. 
	nop			;35c6	00 	. 
	nop			;35c7	00 	. 
	nop			;35c8	00 	. 
	nop			;35c9	00 	. 
	nop			;35ca	00 	. 
	nop			;35cb	00 	. 
	nop			;35cc	00 	. 
	nop			;35cd	00 	. 
	nop			;35ce	00 	. 
	nop			;35cf	00 	. 
	nop			;35d0	00 	. 
	nop			;35d1	00 	. 
	nop			;35d2	00 	. 
	nop			;35d3	00 	. 
	nop			;35d4	00 	. 
	nop			;35d5	00 	. 
	nop			;35d6	00 	. 
	nop			;35d7	00 	. 
	nop			;35d8	00 	. 
	nop			;35d9	00 	. 
	nop			;35da	00 	. 
	nop			;35db	00 	. 
	nop			;35dc	00 	. 
	nop			;35dd	00 	. 
	nop			;35de	00 	. 
	nop			;35df	00 	. 
	nop			;35e0	00 	. 
	nop			;35e1	00 	. 
	nop			;35e2	00 	. 
	nop			;35e3	00 	. 
	nop			;35e4	00 	. 
	nop			;35e5	00 	. 
	nop			;35e6	00 	. 
	nop			;35e7	00 	. 
	nop			;35e8	00 	. 
	nop			;35e9	00 	. 
	nop			;35ea	00 	. 
	nop			;35eb	00 	. 
	nop			;35ec	00 	. 
	nop			;35ed	00 	. 
	nop			;35ee	00 	. 
	nop			;35ef	00 	. 
	nop			;35f0	00 	. 
	nop			;35f1	00 	. 
	nop			;35f2	00 	. 
	nop			;35f3	00 	. 
	nop			;35f4	00 	. 
	nop			;35f5	00 	. 
	nop			;35f6	00 	. 
	nop			;35f7	00 	. 
	nop			;35f8	00 	. 
	nop			;35f9	00 	. 
	nop			;35fa	00 	. 
	nop			;35fb	00 	. 
	nop			;35fc	00 	. 
	nop			;35fd	00 	. 
	nop			;35fe	00 	. 
	nop			;35ff	00 	. 
	nop			;3600	00 	. 
	nop			;3601	00 	. 
	nop			;3602	00 	. 
	nop			;3603	00 	. 
	nop			;3604	00 	. 
	nop			;3605	00 	. 
	nop			;3606	00 	. 
	nop			;3607	00 	. 
	nop			;3608	00 	. 
	nop			;3609	00 	. 
	nop			;360a	00 	. 
	nop			;360b	00 	. 
	nop			;360c	00 	. 
	nop			;360d	00 	. 
	nop			;360e	00 	. 
	nop			;360f	00 	. 
	nop			;3610	00 	. 
	nop			;3611	00 	. 
	nop			;3612	00 	. 
	nop			;3613	00 	. 
	nop			;3614	00 	. 
	nop			;3615	00 	. 
	nop			;3616	00 	. 
	nop			;3617	00 	. 
	nop			;3618	00 	. 
	nop			;3619	00 	. 
	nop			;361a	00 	. 
	nop			;361b	00 	. 
	nop			;361c	00 	. 
	nop			;361d	00 	. 
	nop			;361e	00 	. 
	nop			;361f	00 	. 
	nop			;3620	00 	. 
	nop			;3621	00 	. 
	nop			;3622	00 	. 
	nop			;3623	00 	. 
	nop			;3624	00 	. 
	nop			;3625	00 	. 
	nop			;3626	00 	. 
	nop			;3627	00 	. 
	nop			;3628	00 	. 
	nop			;3629	00 	. 
	nop			;362a	00 	. 
	nop			;362b	00 	. 
	nop			;362c	00 	. 
	nop			;362d	00 	. 
	nop			;362e	00 	. 
	nop			;362f	00 	. 
	nop			;3630	00 	. 
	nop			;3631	00 	. 
	nop			;3632	00 	. 
	nop			;3633	00 	. 
	nop			;3634	00 	. 
	nop			;3635	00 	. 
	nop			;3636	00 	. 
	nop			;3637	00 	. 
	nop			;3638	00 	. 
	nop			;3639	00 	. 
	nop			;363a	00 	. 
	nop			;363b	00 	. 
	nop			;363c	00 	. 
	nop			;363d	00 	. 
	nop			;363e	00 	. 
	nop			;363f	00 	. 
	nop			;3640	00 	. 
	nop			;3641	00 	. 
	nop			;3642	00 	. 
	nop			;3643	00 	. 
	nop			;3644	00 	. 
	nop			;3645	00 	. 
	nop			;3646	00 	. 
	nop			;3647	00 	. 
	nop			;3648	00 	. 
	nop			;3649	00 	. 
	nop			;364a	00 	. 
	nop			;364b	00 	. 
	nop			;364c	00 	. 
	nop			;364d	00 	. 
	nop			;364e	00 	. 
	nop			;364f	00 	. 
	nop			;3650	00 	. 
	nop			;3651	00 	. 
	nop			;3652	00 	. 
	nop			;3653	00 	. 
	nop			;3654	00 	. 
	nop			;3655	00 	. 
	nop			;3656	00 	. 
	nop			;3657	00 	. 
	nop			;3658	00 	. 
	nop			;3659	00 	. 
	nop			;365a	00 	. 
	nop			;365b	00 	. 
	nop			;365c	00 	. 
	nop			;365d	00 	. 
	nop			;365e	00 	. 
	nop			;365f	00 	. 
	nop			;3660	00 	. 
	nop			;3661	00 	. 
	nop			;3662	00 	. 
	nop			;3663	00 	. 
	nop			;3664	00 	. 
	nop			;3665	00 	. 
	nop			;3666	00 	. 
	nop			;3667	00 	. 
	nop			;3668	00 	. 
	nop			;3669	00 	. 
	nop			;366a	00 	. 
	nop			;366b	00 	. 
	nop			;366c	00 	. 
	nop			;366d	00 	. 
	nop			;366e	00 	. 
	nop			;366f	00 	. 
	nop			;3670	00 	. 
	nop			;3671	00 	. 
	nop			;3672	00 	. 
	nop			;3673	00 	. 
	nop			;3674	00 	. 
	nop			;3675	00 	. 
	nop			;3676	00 	. 
	nop			;3677	00 	. 
	nop			;3678	00 	. 
	nop			;3679	00 	. 
	nop			;367a	00 	. 
	nop			;367b	00 	. 
	nop			;367c	00 	. 
	nop			;367d	00 	. 
	nop			;367e	00 	. 
	nop			;367f	00 	. 
	nop			;3680	00 	. 
	nop			;3681	00 	. 
	nop			;3682	00 	. 
	nop			;3683	00 	. 
	nop			;3684	00 	. 
	nop			;3685	00 	. 
	nop			;3686	00 	. 
	nop			;3687	00 	. 
	nop			;3688	00 	. 
	nop			;3689	00 	. 
	nop			;368a	00 	. 
	nop			;368b	00 	. 
	nop			;368c	00 	. 
	nop			;368d	00 	. 
	nop			;368e	00 	. 
	nop			;368f	00 	. 
	nop			;3690	00 	. 
	nop			;3691	00 	. 
	nop			;3692	00 	. 
	nop			;3693	00 	. 
	nop			;3694	00 	. 
	nop			;3695	00 	. 
	nop			;3696	00 	. 
	nop			;3697	00 	. 
	nop			;3698	00 	. 
	nop			;3699	00 	. 
	nop			;369a	00 	. 
	nop			;369b	00 	. 
	nop			;369c	00 	. 
	nop			;369d	00 	. 
	nop			;369e	00 	. 
	nop			;369f	00 	. 
	nop			;36a0	00 	. 
	nop			;36a1	00 	. 
	nop			;36a2	00 	. 
	nop			;36a3	00 	. 
	nop			;36a4	00 	. 
	nop			;36a5	00 	. 
	nop			;36a6	00 	. 
	nop			;36a7	00 	. 
	nop			;36a8	00 	. 
	nop			;36a9	00 	. 
	nop			;36aa	00 	. 
	nop			;36ab	00 	. 
	nop			;36ac	00 	. 
	nop			;36ad	00 	. 
	nop			;36ae	00 	. 
	nop			;36af	00 	. 
	nop			;36b0	00 	. 
	nop			;36b1	00 	. 
	nop			;36b2	00 	. 
	nop			;36b3	00 	. 
	nop			;36b4	00 	. 
	nop			;36b5	00 	. 
	nop			;36b6	00 	. 
	nop			;36b7	00 	. 
	nop			;36b8	00 	. 
	nop			;36b9	00 	. 
	nop			;36ba	00 	. 
	nop			;36bb	00 	. 
	nop			;36bc	00 	. 
	nop			;36bd	00 	. 
	nop			;36be	00 	. 
	nop			;36bf	00 	. 
	nop			;36c0	00 	. 
	nop			;36c1	00 	. 
	nop			;36c2	00 	. 
	nop			;36c3	00 	. 
	nop			;36c4	00 	. 
	nop			;36c5	00 	. 
	nop			;36c6	00 	. 
	nop			;36c7	00 	. 
	nop			;36c8	00 	. 
	nop			;36c9	00 	. 
	nop			;36ca	00 	. 
	nop			;36cb	00 	. 
	nop			;36cc	00 	. 
	nop			;36cd	00 	. 
	nop			;36ce	00 	. 
	nop			;36cf	00 	. 
	nop			;36d0	00 	. 
	nop			;36d1	00 	. 
	nop			;36d2	00 	. 
	nop			;36d3	00 	. 
	nop			;36d4	00 	. 
	nop			;36d5	00 	. 
	nop			;36d6	00 	. 
	nop			;36d7	00 	. 
	nop			;36d8	00 	. 
	nop			;36d9	00 	. 
	nop			;36da	00 	. 
	nop			;36db	00 	. 
	nop			;36dc	00 	. 
	nop			;36dd	00 	. 
	nop			;36de	00 	. 
	nop			;36df	00 	. 
	nop			;36e0	00 	. 
	nop			;36e1	00 	. 
	nop			;36e2	00 	. 
	nop			;36e3	00 	. 
	nop			;36e4	00 	. 
	nop			;36e5	00 	. 
	nop			;36e6	00 	. 
	nop			;36e7	00 	. 
	nop			;36e8	00 	. 
	nop			;36e9	00 	. 
	nop			;36ea	00 	. 
	nop			;36eb	00 	. 
	nop			;36ec	00 	. 
	nop			;36ed	00 	. 
	nop			;36ee	00 	. 
	nop			;36ef	00 	. 
	nop			;36f0	00 	. 
	nop			;36f1	00 	. 
	nop			;36f2	00 	. 
	nop			;36f3	00 	. 
	nop			;36f4	00 	. 
	nop			;36f5	00 	. 
	nop			;36f6	00 	. 
	nop			;36f7	00 	. 
	nop			;36f8	00 	. 
	nop			;36f9	00 	. 
	nop			;36fa	00 	. 
	nop			;36fb	00 	. 
	nop			;36fc	00 	. 
	nop			;36fd	00 	. 
	nop			;36fe	00 	. 
	nop			;36ff	00 	. 
	nop			;3700	00 	. 
	nop			;3701	00 	. 
	nop			;3702	00 	. 
	nop			;3703	00 	. 
	nop			;3704	00 	. 
	nop			;3705	00 	. 
	nop			;3706	00 	. 
	nop			;3707	00 	. 
	nop			;3708	00 	. 
	nop			;3709	00 	. 
	nop			;370a	00 	. 
	nop			;370b	00 	. 
	nop			;370c	00 	. 
	nop			;370d	00 	. 
	nop			;370e	00 	. 
	nop			;370f	00 	. 
	nop			;3710	00 	. 
	nop			;3711	00 	. 
	nop			;3712	00 	. 
	nop			;3713	00 	. 
	nop			;3714	00 	. 
	nop			;3715	00 	. 
	nop			;3716	00 	. 
	nop			;3717	00 	. 
	nop			;3718	00 	. 
	nop			;3719	00 	. 
	nop			;371a	00 	. 
	nop			;371b	00 	. 
	nop			;371c	00 	. 
	nop			;371d	00 	. 
	nop			;371e	00 	. 
	nop			;371f	00 	. 
	nop			;3720	00 	. 
	nop			;3721	00 	. 
	nop			;3722	00 	. 
	nop			;3723	00 	. 
	nop			;3724	00 	. 
	nop			;3725	00 	. 
	nop			;3726	00 	. 
	nop			;3727	00 	. 
	nop			;3728	00 	. 
	nop			;3729	00 	. 
	nop			;372a	00 	. 
	nop			;372b	00 	. 
	nop			;372c	00 	. 
	nop			;372d	00 	. 
	nop			;372e	00 	. 
	nop			;372f	00 	. 
	nop			;3730	00 	. 
	nop			;3731	00 	. 
	nop			;3732	00 	. 
	nop			;3733	00 	. 
	nop			;3734	00 	. 
	nop			;3735	00 	. 
	nop			;3736	00 	. 
	nop			;3737	00 	. 
	nop			;3738	00 	. 
	nop			;3739	00 	. 
	nop			;373a	00 	. 
	nop			;373b	00 	. 
	nop			;373c	00 	. 
	nop			;373d	00 	. 
	nop			;373e	00 	. 
	nop			;373f	00 	. 
	nop			;3740	00 	. 
	nop			;3741	00 	. 
	nop			;3742	00 	. 
	nop			;3743	00 	. 
	nop			;3744	00 	. 
	nop			;3745	00 	. 
	nop			;3746	00 	. 
	nop			;3747	00 	. 
	nop			;3748	00 	. 
	nop			;3749	00 	. 
	nop			;374a	00 	. 
	nop			;374b	00 	. 
	nop			;374c	00 	. 
	nop			;374d	00 	. 
	nop			;374e	00 	. 
	nop			;374f	00 	. 
	nop			;3750	00 	. 
	nop			;3751	00 	. 
	nop			;3752	00 	. 
	nop			;3753	00 	. 
	nop			;3754	00 	. 
	nop			;3755	00 	. 
	nop			;3756	00 	. 
	nop			;3757	00 	. 
	nop			;3758	00 	. 
	nop			;3759	00 	. 
	nop			;375a	00 	. 
	nop			;375b	00 	. 
	nop			;375c	00 	. 
	nop			;375d	00 	. 
	nop			;375e	00 	. 
	nop			;375f	00 	. 
	nop			;3760	00 	. 
	nop			;3761	00 	. 
	nop			;3762	00 	. 
	nop			;3763	00 	. 
	nop			;3764	00 	. 
	nop			;3765	00 	. 
	nop			;3766	00 	. 
	nop			;3767	00 	. 
	nop			;3768	00 	. 
	nop			;3769	00 	. 
	nop			;376a	00 	. 
	nop			;376b	00 	. 
	nop			;376c	00 	. 
	nop			;376d	00 	. 
	nop			;376e	00 	. 
	nop			;376f	00 	. 
	nop			;3770	00 	. 
	nop			;3771	00 	. 
	nop			;3772	00 	. 
	nop			;3773	00 	. 
	nop			;3774	00 	. 
	nop			;3775	00 	. 
	nop			;3776	00 	. 
	nop			;3777	00 	. 
	nop			;3778	00 	. 
	nop			;3779	00 	. 
	nop			;377a	00 	. 
	nop			;377b	00 	. 
	nop			;377c	00 	. 
	nop			;377d	00 	. 
	nop			;377e	00 	. 
	nop			;377f	00 	. 
	nop			;3780	00 	. 
	nop			;3781	00 	. 
	nop			;3782	00 	. 
	nop			;3783	00 	. 
	nop			;3784	00 	. 
	nop			;3785	00 	. 
	nop			;3786	00 	. 
	nop			;3787	00 	. 
	nop			;3788	00 	. 
	nop			;3789	00 	. 
	nop			;378a	00 	. 
	nop			;378b	00 	. 
	nop			;378c	00 	. 
	nop			;378d	00 	. 
	nop			;378e	00 	. 
	nop			;378f	00 	. 
	nop			;3790	00 	. 
	nop			;3791	00 	. 
	nop			;3792	00 	. 
	nop			;3793	00 	. 
	nop			;3794	00 	. 
	nop			;3795	00 	. 
	nop			;3796	00 	. 
	nop			;3797	00 	. 
	nop			;3798	00 	. 
	nop			;3799	00 	. 
	nop			;379a	00 	. 
	nop			;379b	00 	. 
	nop			;379c	00 	. 
	nop			;379d	00 	. 
	nop			;379e	00 	. 
	nop			;379f	00 	. 
	nop			;37a0	00 	. 
	nop			;37a1	00 	. 
	nop			;37a2	00 	. 
	nop			;37a3	00 	. 
	nop			;37a4	00 	. 
	nop			;37a5	00 	. 
	nop			;37a6	00 	. 
	nop			;37a7	00 	. 
	nop			;37a8	00 	. 
	nop			;37a9	00 	. 
	nop			;37aa	00 	. 
	nop			;37ab	00 	. 
	nop			;37ac	00 	. 
	nop			;37ad	00 	. 
	nop			;37ae	00 	. 
	nop			;37af	00 	. 
	nop			;37b0	00 	. 
	nop			;37b1	00 	. 
	nop			;37b2	00 	. 
	nop			;37b3	00 	. 
	nop			;37b4	00 	. 
	nop			;37b5	00 	. 
	nop			;37b6	00 	. 
	nop			;37b7	00 	. 
	nop			;37b8	00 	. 
	nop			;37b9	00 	. 
	nop			;37ba	00 	. 
	nop			;37bb	00 	. 
	nop			;37bc	00 	. 
	nop			;37bd	00 	. 
	nop			;37be	00 	. 
	nop			;37bf	00 	. 
	nop			;37c0	00 	. 
	nop			;37c1	00 	. 
	nop			;37c2	00 	. 
	nop			;37c3	00 	. 
	nop			;37c4	00 	. 
	nop			;37c5	00 	. 
	nop			;37c6	00 	. 
	nop			;37c7	00 	. 
	nop			;37c8	00 	. 
	nop			;37c9	00 	. 
	nop			;37ca	00 	. 
	nop			;37cb	00 	. 
	nop			;37cc	00 	. 
	nop			;37cd	00 	. 
	nop			;37ce	00 	. 
	nop			;37cf	00 	. 
	nop			;37d0	00 	. 
	nop			;37d1	00 	. 
	nop			;37d2	00 	. 
	nop			;37d3	00 	. 
	nop			;37d4	00 	. 
	nop			;37d5	00 	. 
	nop			;37d6	00 	. 
	nop			;37d7	00 	. 
	nop			;37d8	00 	. 
	nop			;37d9	00 	. 
	nop			;37da	00 	. 
	nop			;37db	00 	. 
	nop			;37dc	00 	. 
	nop			;37dd	00 	. 
	nop			;37de	00 	. 
	nop			;37df	00 	. 
	nop			;37e0	00 	. 
	nop			;37e1	00 	. 
	nop			;37e2	00 	. 
	nop			;37e3	00 	. 
	nop			;37e4	00 	. 
	nop			;37e5	00 	. 
	nop			;37e6	00 	. 
	nop			;37e7	00 	. 
	nop			;37e8	00 	. 
	nop			;37e9	00 	. 
	nop			;37ea	00 	. 
	nop			;37eb	00 	. 
	nop			;37ec	00 	. 
	nop			;37ed	00 	. 
	nop			;37ee	00 	. 
	nop			;37ef	00 	. 
	nop			;37f0	00 	. 
	nop			;37f1	00 	. 
	nop			;37f2	00 	. 
	nop			;37f3	00 	. 
	nop			;37f4	00 	. 
	nop			;37f5	00 	. 
	nop			;37f6	00 	. 
	nop			;37f7	00 	. 
	nop			;37f8	00 	. 
	nop			;37f9	00 	. 
	nop			;37fa	00 	. 
	nop			;37fb	00 	. 
	nop			;37fc	00 	. 
	nop			;37fd	00 	. 
	nop			;37fe	00 	. 
	nop			;37ff	00 	. 
	nop			;3800	00 	. 
	nop			;3801	00 	. 
	nop			;3802	00 	. 
	nop			;3803	00 	. 
	nop			;3804	00 	. 
	nop			;3805	00 	. 
	nop			;3806	00 	. 
	nop			;3807	00 	. 
	nop			;3808	00 	. 
	nop			;3809	00 	. 
	nop			;380a	00 	. 
	nop			;380b	00 	. 
	nop			;380c	00 	. 
	nop			;380d	00 	. 
	nop			;380e	00 	. 
	nop			;380f	00 	. 
	nop			;3810	00 	. 
	nop			;3811	00 	. 
	nop			;3812	00 	. 
	nop			;3813	00 	. 
	nop			;3814	00 	. 
	nop			;3815	00 	. 
	nop			;3816	00 	. 
	nop			;3817	00 	. 
	nop			;3818	00 	. 
	nop			;3819	00 	. 
	nop			;381a	00 	. 
	nop			;381b	00 	. 
	nop			;381c	00 	. 
	nop			;381d	00 	. 
	nop			;381e	00 	. 
	nop			;381f	00 	. 
	nop			;3820	00 	. 
	nop			;3821	00 	. 
	nop			;3822	00 	. 
	nop			;3823	00 	. 
	nop			;3824	00 	. 
	nop			;3825	00 	. 
	nop			;3826	00 	. 
	nop			;3827	00 	. 
	nop			;3828	00 	. 
	nop			;3829	00 	. 
	nop			;382a	00 	. 
	nop			;382b	00 	. 
	nop			;382c	00 	. 
	nop			;382d	00 	. 
	nop			;382e	00 	. 
	nop			;382f	00 	. 
	nop			;3830	00 	. 
	nop			;3831	00 	. 
	nop			;3832	00 	. 
	nop			;3833	00 	. 
	nop			;3834	00 	. 
	nop			;3835	00 	. 
	nop			;3836	00 	. 
	nop			;3837	00 	. 
	nop			;3838	00 	. 
	nop			;3839	00 	. 
	nop			;383a	00 	. 
	nop			;383b	00 	. 
	nop			;383c	00 	. 
	nop			;383d	00 	. 
	nop			;383e	00 	. 
	nop			;383f	00 	. 
	nop			;3840	00 	. 
	nop			;3841	00 	. 
	nop			;3842	00 	. 
	nop			;3843	00 	. 
	nop			;3844	00 	. 
	nop			;3845	00 	. 
	nop			;3846	00 	. 
	nop			;3847	00 	. 
	nop			;3848	00 	. 
	nop			;3849	00 	. 
	nop			;384a	00 	. 
	nop			;384b	00 	. 
	nop			;384c	00 	. 
	nop			;384d	00 	. 
	nop			;384e	00 	. 
	nop			;384f	00 	. 
	nop			;3850	00 	. 
	nop			;3851	00 	. 
	nop			;3852	00 	. 
	nop			;3853	00 	. 
	nop			;3854	00 	. 
	nop			;3855	00 	. 
	nop			;3856	00 	. 
	nop			;3857	00 	. 
	nop			;3858	00 	. 
	nop			;3859	00 	. 
	nop			;385a	00 	. 
	nop			;385b	00 	. 
	nop			;385c	00 	. 
	nop			;385d	00 	. 
	nop			;385e	00 	. 
	nop			;385f	00 	. 
	nop			;3860	00 	. 
	nop			;3861	00 	. 
	nop			;3862	00 	. 
	nop			;3863	00 	. 
	nop			;3864	00 	. 
	nop			;3865	00 	. 
	nop			;3866	00 	. 
	nop			;3867	00 	. 
	nop			;3868	00 	. 
	nop			;3869	00 	. 
	nop			;386a	00 	. 
	nop			;386b	00 	. 
	nop			;386c	00 	. 
	nop			;386d	00 	. 
	nop			;386e	00 	. 
	nop			;386f	00 	. 
	nop			;3870	00 	. 
	nop			;3871	00 	. 
	nop			;3872	00 	. 
	nop			;3873	00 	. 
	nop			;3874	00 	. 
	nop			;3875	00 	. 
	nop			;3876	00 	. 
	nop			;3877	00 	. 
	nop			;3878	00 	. 
	nop			;3879	00 	. 
	nop			;387a	00 	. 
	nop			;387b	00 	. 
	nop			;387c	00 	. 
	nop			;387d	00 	. 
	nop			;387e	00 	. 
	nop			;387f	00 	. 
	nop			;3880	00 	. 
	nop			;3881	00 	. 
	nop			;3882	00 	. 
	nop			;3883	00 	. 
	nop			;3884	00 	. 
	nop			;3885	00 	. 
	nop			;3886	00 	. 
	nop			;3887	00 	. 
	nop			;3888	00 	. 
	nop			;3889	00 	. 
	nop			;388a	00 	. 
	nop			;388b	00 	. 
	nop			;388c	00 	. 
	nop			;388d	00 	. 
	nop			;388e	00 	. 
	nop			;388f	00 	. 
	nop			;3890	00 	. 
	nop			;3891	00 	. 
	nop			;3892	00 	. 
	nop			;3893	00 	. 
	nop			;3894	00 	. 
	nop			;3895	00 	. 
	nop			;3896	00 	. 
	nop			;3897	00 	. 
	nop			;3898	00 	. 
	nop			;3899	00 	. 
	nop			;389a	00 	. 
	nop			;389b	00 	. 
	nop			;389c	00 	. 
	nop			;389d	00 	. 
	nop			;389e	00 	. 
	nop			;389f	00 	. 
	nop			;38a0	00 	. 
	nop			;38a1	00 	. 
	nop			;38a2	00 	. 
	nop			;38a3	00 	. 
	nop			;38a4	00 	. 
	nop			;38a5	00 	. 
	nop			;38a6	00 	. 
	nop			;38a7	00 	. 
	nop			;38a8	00 	. 
	nop			;38a9	00 	. 
	nop			;38aa	00 	. 
	nop			;38ab	00 	. 
	nop			;38ac	00 	. 
	nop			;38ad	00 	. 
	nop			;38ae	00 	. 
	nop			;38af	00 	. 
	nop			;38b0	00 	. 
	nop			;38b1	00 	. 
	nop			;38b2	00 	. 
	nop			;38b3	00 	. 
	nop			;38b4	00 	. 
	nop			;38b5	00 	. 
	nop			;38b6	00 	. 
	nop			;38b7	00 	. 
	nop			;38b8	00 	. 
	nop			;38b9	00 	. 
	nop			;38ba	00 	. 
	nop			;38bb	00 	. 
	nop			;38bc	00 	. 
	nop			;38bd	00 	. 
	nop			;38be	00 	. 
	nop			;38bf	00 	. 
	nop			;38c0	00 	. 
	nop			;38c1	00 	. 
	nop			;38c2	00 	. 
	nop			;38c3	00 	. 
	nop			;38c4	00 	. 
	nop			;38c5	00 	. 
	nop			;38c6	00 	. 
	nop			;38c7	00 	. 
	nop			;38c8	00 	. 
	nop			;38c9	00 	. 
	nop			;38ca	00 	. 
	nop			;38cb	00 	. 
	nop			;38cc	00 	. 
	nop			;38cd	00 	. 
	nop			;38ce	00 	. 
	nop			;38cf	00 	. 
	nop			;38d0	00 	. 
	nop			;38d1	00 	. 
	nop			;38d2	00 	. 
	nop			;38d3	00 	. 
	nop			;38d4	00 	. 
	nop			;38d5	00 	. 
	nop			;38d6	00 	. 
	nop			;38d7	00 	. 
	nop			;38d8	00 	. 
	nop			;38d9	00 	. 
	nop			;38da	00 	. 
	nop			;38db	00 	. 
	nop			;38dc	00 	. 
	nop			;38dd	00 	. 
	nop			;38de	00 	. 
	nop			;38df	00 	. 
	nop			;38e0	00 	. 
	nop			;38e1	00 	. 
	nop			;38e2	00 	. 
	nop			;38e3	00 	. 
	nop			;38e4	00 	. 
	nop			;38e5	00 	. 
	nop			;38e6	00 	. 
	nop			;38e7	00 	. 
	nop			;38e8	00 	. 
	nop			;38e9	00 	. 
	nop			;38ea	00 	. 
	nop			;38eb	00 	. 
	nop			;38ec	00 	. 
	nop			;38ed	00 	. 
	nop			;38ee	00 	. 
	nop			;38ef	00 	. 
	nop			;38f0	00 	. 
	nop			;38f1	00 	. 
	nop			;38f2	00 	. 
	nop			;38f3	00 	. 
	nop			;38f4	00 	. 
	nop			;38f5	00 	. 
	nop			;38f6	00 	. 
	nop			;38f7	00 	. 
	nop			;38f8	00 	. 
	nop			;38f9	00 	. 
	nop			;38fa	00 	. 
	nop			;38fb	00 	. 
	nop			;38fc	00 	. 
	nop			;38fd	00 	. 
	nop			;38fe	00 	. 
	nop			;38ff	00 	. 
	nop			;3900	00 	. 
	nop			;3901	00 	. 
	nop			;3902	00 	. 
	nop			;3903	00 	. 
	nop			;3904	00 	. 
	nop			;3905	00 	. 
	nop			;3906	00 	. 
	nop			;3907	00 	. 
	nop			;3908	00 	. 
	nop			;3909	00 	. 
	nop			;390a	00 	. 
	nop			;390b	00 	. 
	nop			;390c	00 	. 
	nop			;390d	00 	. 
	nop			;390e	00 	. 
	nop			;390f	00 	. 
	nop			;3910	00 	. 
	nop			;3911	00 	. 
	nop			;3912	00 	. 
	nop			;3913	00 	. 
	nop			;3914	00 	. 
	nop			;3915	00 	. 
	nop			;3916	00 	. 
	nop			;3917	00 	. 
	nop			;3918	00 	. 
	nop			;3919	00 	. 
	nop			;391a	00 	. 
	nop			;391b	00 	. 
	nop			;391c	00 	. 
	nop			;391d	00 	. 
	nop			;391e	00 	. 
	nop			;391f	00 	. 
	nop			;3920	00 	. 
	nop			;3921	00 	. 
	nop			;3922	00 	. 
	nop			;3923	00 	. 
	nop			;3924	00 	. 
	nop			;3925	00 	. 
	nop			;3926	00 	. 
	nop			;3927	00 	. 
	nop			;3928	00 	. 
	nop			;3929	00 	. 
	nop			;392a	00 	. 
	nop			;392b	00 	. 
	nop			;392c	00 	. 
	nop			;392d	00 	. 
	nop			;392e	00 	. 
	nop			;392f	00 	. 
	nop			;3930	00 	. 
	nop			;3931	00 	. 
	nop			;3932	00 	. 
	nop			;3933	00 	. 
	nop			;3934	00 	. 
	nop			;3935	00 	. 
	nop			;3936	00 	. 
	nop			;3937	00 	. 
	nop			;3938	00 	. 
	nop			;3939	00 	. 
	nop			;393a	00 	. 
	nop			;393b	00 	. 
	nop			;393c	00 	. 
	nop			;393d	00 	. 
	nop			;393e	00 	. 
	nop			;393f	00 	. 
	nop			;3940	00 	. 
	nop			;3941	00 	. 
	nop			;3942	00 	. 
	nop			;3943	00 	. 
	nop			;3944	00 	. 
	nop			;3945	00 	. 
	nop			;3946	00 	. 
	nop			;3947	00 	. 
	nop			;3948	00 	. 
	nop			;3949	00 	. 
	nop			;394a	00 	. 
	nop			;394b	00 	. 
	nop			;394c	00 	. 
	nop			;394d	00 	. 
	nop			;394e	00 	. 
	nop			;394f	00 	. 
	nop			;3950	00 	. 
	nop			;3951	00 	. 
	nop			;3952	00 	. 
	nop			;3953	00 	. 
	nop			;3954	00 	. 
	nop			;3955	00 	. 
	nop			;3956	00 	. 
	nop			;3957	00 	. 
	nop			;3958	00 	. 
	nop			;3959	00 	. 
	nop			;395a	00 	. 
	nop			;395b	00 	. 
	nop			;395c	00 	. 
	nop			;395d	00 	. 
	nop			;395e	00 	. 
	nop			;395f	00 	. 
	nop			;3960	00 	. 
	nop			;3961	00 	. 
	nop			;3962	00 	. 
	nop			;3963	00 	. 
	nop			;3964	00 	. 
	nop			;3965	00 	. 
	nop			;3966	00 	. 
	nop			;3967	00 	. 
	nop			;3968	00 	. 
	nop			;3969	00 	. 
	nop			;396a	00 	. 
	nop			;396b	00 	. 
	nop			;396c	00 	. 
	nop			;396d	00 	. 
	nop			;396e	00 	. 
	nop			;396f	00 	. 
	nop			;3970	00 	. 
	nop			;3971	00 	. 
	nop			;3972	00 	. 
	nop			;3973	00 	. 
	nop			;3974	00 	. 
	nop			;3975	00 	. 
	nop			;3976	00 	. 
	nop			;3977	00 	. 
	nop			;3978	00 	. 
	nop			;3979	00 	. 
	nop			;397a	00 	. 
	nop			;397b	00 	. 
	nop			;397c	00 	. 
	nop			;397d	00 	. 
	nop			;397e	00 	. 
	nop			;397f	00 	. 
	nop			;3980	00 	. 
	nop			;3981	00 	. 
	nop			;3982	00 	. 
	nop			;3983	00 	. 
	nop			;3984	00 	. 
	nop			;3985	00 	. 
	nop			;3986	00 	. 
	nop			;3987	00 	. 
	nop			;3988	00 	. 
	nop			;3989	00 	. 
	nop			;398a	00 	. 
	nop			;398b	00 	. 
	nop			;398c	00 	. 
	nop			;398d	00 	. 
	nop			;398e	00 	. 
	nop			;398f	00 	. 
	nop			;3990	00 	. 
	nop			;3991	00 	. 
	nop			;3992	00 	. 
	nop			;3993	00 	. 
	nop			;3994	00 	. 
	nop			;3995	00 	. 
	nop			;3996	00 	. 
	nop			;3997	00 	. 
	nop			;3998	00 	. 
	nop			;3999	00 	. 
	nop			;399a	00 	. 
	nop			;399b	00 	. 
	nop			;399c	00 	. 
	nop			;399d	00 	. 
	nop			;399e	00 	. 
	nop			;399f	00 	. 
	nop			;39a0	00 	. 
	nop			;39a1	00 	. 
	nop			;39a2	00 	. 
	nop			;39a3	00 	. 
	nop			;39a4	00 	. 
	nop			;39a5	00 	. 
	nop			;39a6	00 	. 
	nop			;39a7	00 	. 
	nop			;39a8	00 	. 
	nop			;39a9	00 	. 
	nop			;39aa	00 	. 
	nop			;39ab	00 	. 
	nop			;39ac	00 	. 
	nop			;39ad	00 	. 
	nop			;39ae	00 	. 
	nop			;39af	00 	. 
	nop			;39b0	00 	. 
	nop			;39b1	00 	. 
	nop			;39b2	00 	. 
	nop			;39b3	00 	. 
	nop			;39b4	00 	. 
	nop			;39b5	00 	. 
	nop			;39b6	00 	. 
	nop			;39b7	00 	. 
	nop			;39b8	00 	. 
	nop			;39b9	00 	. 
	nop			;39ba	00 	. 
	nop			;39bb	00 	. 
	nop			;39bc	00 	. 
	nop			;39bd	00 	. 
	nop			;39be	00 	. 
	nop			;39bf	00 	. 
	nop			;39c0	00 	. 
	nop			;39c1	00 	. 
	nop			;39c2	00 	. 
	nop			;39c3	00 	. 
	nop			;39c4	00 	. 
	nop			;39c5	00 	. 
	nop			;39c6	00 	. 
	nop			;39c7	00 	. 
	nop			;39c8	00 	. 
	nop			;39c9	00 	. 
	nop			;39ca	00 	. 
	nop			;39cb	00 	. 
	nop			;39cc	00 	. 
	nop			;39cd	00 	. 
	nop			;39ce	00 	. 
	nop			;39cf	00 	. 
	nop			;39d0	00 	. 
	nop			;39d1	00 	. 
	nop			;39d2	00 	. 
	nop			;39d3	00 	. 
	nop			;39d4	00 	. 
	nop			;39d5	00 	. 
	nop			;39d6	00 	. 
	nop			;39d7	00 	. 
	nop			;39d8	00 	. 
	nop			;39d9	00 	. 
	nop			;39da	00 	. 
	nop			;39db	00 	. 
	nop			;39dc	00 	. 
	nop			;39dd	00 	. 
	nop			;39de	00 	. 
	nop			;39df	00 	. 
	nop			;39e0	00 	. 
	nop			;39e1	00 	. 
	nop			;39e2	00 	. 
	nop			;39e3	00 	. 
	nop			;39e4	00 	. 
	nop			;39e5	00 	. 
	nop			;39e6	00 	. 
	nop			;39e7	00 	. 
	nop			;39e8	00 	. 
	nop			;39e9	00 	. 
	nop			;39ea	00 	. 
	nop			;39eb	00 	. 
	nop			;39ec	00 	. 
	nop			;39ed	00 	. 
	nop			;39ee	00 	. 
	nop			;39ef	00 	. 
	nop			;39f0	00 	. 
	nop			;39f1	00 	. 
	nop			;39f2	00 	. 
	nop			;39f3	00 	. 
	nop			;39f4	00 	. 
	nop			;39f5	00 	. 
	nop			;39f6	00 	. 
	nop			;39f7	00 	. 
	nop			;39f8	00 	. 
	nop			;39f9	00 	. 
	nop			;39fa	00 	. 
	nop			;39fb	00 	. 
	nop			;39fc	00 	. 
	nop			;39fd	00 	. 
	nop			;39fe	00 	. 
	nop			;39ff	00 	. 
	nop			;3a00	00 	. 
	nop			;3a01	00 	. 
	nop			;3a02	00 	. 
	nop			;3a03	00 	. 
	nop			;3a04	00 	. 
	nop			;3a05	00 	. 
	nop			;3a06	00 	. 
	nop			;3a07	00 	. 
	nop			;3a08	00 	. 
	nop			;3a09	00 	. 
	nop			;3a0a	00 	. 
	nop			;3a0b	00 	. 
	nop			;3a0c	00 	. 
	nop			;3a0d	00 	. 
	nop			;3a0e	00 	. 
	nop			;3a0f	00 	. 
	nop			;3a10	00 	. 
	nop			;3a11	00 	. 
	nop			;3a12	00 	. 
	nop			;3a13	00 	. 
	nop			;3a14	00 	. 
	nop			;3a15	00 	. 
	nop			;3a16	00 	. 
	nop			;3a17	00 	. 
	nop			;3a18	00 	. 
	nop			;3a19	00 	. 
	nop			;3a1a	00 	. 
	nop			;3a1b	00 	. 
	nop			;3a1c	00 	. 
	nop			;3a1d	00 	. 
	nop			;3a1e	00 	. 
	nop			;3a1f	00 	. 
	nop			;3a20	00 	. 
	nop			;3a21	00 	. 
	nop			;3a22	00 	. 
	nop			;3a23	00 	. 
	nop			;3a24	00 	. 
	nop			;3a25	00 	. 
	nop			;3a26	00 	. 
	nop			;3a27	00 	. 
	nop			;3a28	00 	. 
	nop			;3a29	00 	. 
	nop			;3a2a	00 	. 
	nop			;3a2b	00 	. 
	nop			;3a2c	00 	. 
	nop			;3a2d	00 	. 
	nop			;3a2e	00 	. 
	nop			;3a2f	00 	. 
	nop			;3a30	00 	. 
	nop			;3a31	00 	. 
	nop			;3a32	00 	. 
	nop			;3a33	00 	. 
	nop			;3a34	00 	. 
	nop			;3a35	00 	. 
	nop			;3a36	00 	. 
	nop			;3a37	00 	. 
	nop			;3a38	00 	. 
	nop			;3a39	00 	. 
	nop			;3a3a	00 	. 
	nop			;3a3b	00 	. 
	nop			;3a3c	00 	. 
	nop			;3a3d	00 	. 
	nop			;3a3e	00 	. 
	nop			;3a3f	00 	. 
	nop			;3a40	00 	. 
	nop			;3a41	00 	. 
	nop			;3a42	00 	. 
	nop			;3a43	00 	. 
	nop			;3a44	00 	. 
	nop			;3a45	00 	. 
	nop			;3a46	00 	. 
	nop			;3a47	00 	. 
	nop			;3a48	00 	. 
	nop			;3a49	00 	. 
	nop			;3a4a	00 	. 
	nop			;3a4b	00 	. 
	nop			;3a4c	00 	. 
	nop			;3a4d	00 	. 
	nop			;3a4e	00 	. 
	nop			;3a4f	00 	. 
	nop			;3a50	00 	. 
	nop			;3a51	00 	. 
	nop			;3a52	00 	. 
	nop			;3a53	00 	. 
	nop			;3a54	00 	. 
	nop			;3a55	00 	. 
	nop			;3a56	00 	. 
	nop			;3a57	00 	. 
	nop			;3a58	00 	. 
	nop			;3a59	00 	. 
	nop			;3a5a	00 	. 
	nop			;3a5b	00 	. 
	nop			;3a5c	00 	. 
	nop			;3a5d	00 	. 
	nop			;3a5e	00 	. 
	nop			;3a5f	00 	. 
	nop			;3a60	00 	. 
	nop			;3a61	00 	. 
	nop			;3a62	00 	. 
	nop			;3a63	00 	. 
	nop			;3a64	00 	. 
	nop			;3a65	00 	. 
	nop			;3a66	00 	. 
	nop			;3a67	00 	. 
	nop			;3a68	00 	. 
	nop			;3a69	00 	. 
	nop			;3a6a	00 	. 
	nop			;3a6b	00 	. 
	nop			;3a6c	00 	. 
	nop			;3a6d	00 	. 
	nop			;3a6e	00 	. 
	nop			;3a6f	00 	. 
	nop			;3a70	00 	. 
	nop			;3a71	00 	. 
	nop			;3a72	00 	. 
	nop			;3a73	00 	. 
	nop			;3a74	00 	. 
	nop			;3a75	00 	. 
	nop			;3a76	00 	. 
	nop			;3a77	00 	. 
	nop			;3a78	00 	. 
	nop			;3a79	00 	. 
	nop			;3a7a	00 	. 
	nop			;3a7b	00 	. 
	nop			;3a7c	00 	. 
	nop			;3a7d	00 	. 
	nop			;3a7e	00 	. 
	nop			;3a7f	00 	. 
	nop			;3a80	00 	. 
	nop			;3a81	00 	. 
	nop			;3a82	00 	. 
	nop			;3a83	00 	. 
	nop			;3a84	00 	. 
	nop			;3a85	00 	. 
	nop			;3a86	00 	. 
	nop			;3a87	00 	. 
	nop			;3a88	00 	. 
	nop			;3a89	00 	. 
	nop			;3a8a	00 	. 
	nop			;3a8b	00 	. 
	nop			;3a8c	00 	. 
	nop			;3a8d	00 	. 
	nop			;3a8e	00 	. 
	nop			;3a8f	00 	. 
	nop			;3a90	00 	. 
	nop			;3a91	00 	. 
	nop			;3a92	00 	. 
	nop			;3a93	00 	. 
	nop			;3a94	00 	. 
	nop			;3a95	00 	. 
	nop			;3a96	00 	. 
	nop			;3a97	00 	. 
	nop			;3a98	00 	. 
	nop			;3a99	00 	. 
	nop			;3a9a	00 	. 
	nop			;3a9b	00 	. 
	nop			;3a9c	00 	. 
	nop			;3a9d	00 	. 
	nop			;3a9e	00 	. 
	nop			;3a9f	00 	. 
	nop			;3aa0	00 	. 
	nop			;3aa1	00 	. 
	nop			;3aa2	00 	. 
	nop			;3aa3	00 	. 
	nop			;3aa4	00 	. 
	nop			;3aa5	00 	. 
	nop			;3aa6	00 	. 
	nop			;3aa7	00 	. 
	nop			;3aa8	00 	. 
	nop			;3aa9	00 	. 
	nop			;3aaa	00 	. 
	nop			;3aab	00 	. 
	nop			;3aac	00 	. 
	nop			;3aad	00 	. 
	nop			;3aae	00 	. 
	nop			;3aaf	00 	. 
	nop			;3ab0	00 	. 
	nop			;3ab1	00 	. 
	nop			;3ab2	00 	. 
	nop			;3ab3	00 	. 
	nop			;3ab4	00 	. 
	nop			;3ab5	00 	. 
	nop			;3ab6	00 	. 
	nop			;3ab7	00 	. 
	nop			;3ab8	00 	. 
	nop			;3ab9	00 	. 
	nop			;3aba	00 	. 
	nop			;3abb	00 	. 
	nop			;3abc	00 	. 
	nop			;3abd	00 	. 
	nop			;3abe	00 	. 
	nop			;3abf	00 	. 
	nop			;3ac0	00 	. 
	nop			;3ac1	00 	. 
	nop			;3ac2	00 	. 
	nop			;3ac3	00 	. 
	nop			;3ac4	00 	. 
	nop			;3ac5	00 	. 
	nop			;3ac6	00 	. 
	nop			;3ac7	00 	. 
	nop			;3ac8	00 	. 
	nop			;3ac9	00 	. 
	nop			;3aca	00 	. 
	nop			;3acb	00 	. 
	nop			;3acc	00 	. 
	nop			;3acd	00 	. 
	nop			;3ace	00 	. 
	nop			;3acf	00 	. 
	nop			;3ad0	00 	. 
	nop			;3ad1	00 	. 
	nop			;3ad2	00 	. 
	nop			;3ad3	00 	. 
	nop			;3ad4	00 	. 
	nop			;3ad5	00 	. 
	nop			;3ad6	00 	. 
	nop			;3ad7	00 	. 
	nop			;3ad8	00 	. 
	nop			;3ad9	00 	. 
	nop			;3ada	00 	. 
	nop			;3adb	00 	. 
	nop			;3adc	00 	. 
	nop			;3add	00 	. 
	nop			;3ade	00 	. 
	nop			;3adf	00 	. 
	nop			;3ae0	00 	. 
	nop			;3ae1	00 	. 
	nop			;3ae2	00 	. 
	nop			;3ae3	00 	. 
	nop			;3ae4	00 	. 
	nop			;3ae5	00 	. 
	nop			;3ae6	00 	. 
	nop			;3ae7	00 	. 
	nop			;3ae8	00 	. 
	nop			;3ae9	00 	. 
	nop			;3aea	00 	. 
	nop			;3aeb	00 	. 
	nop			;3aec	00 	. 
	nop			;3aed	00 	. 
	nop			;3aee	00 	. 
	nop			;3aef	00 	. 
	nop			;3af0	00 	. 
	nop			;3af1	00 	. 
	nop			;3af2	00 	. 
	nop			;3af3	00 	. 
	nop			;3af4	00 	. 
	nop			;3af5	00 	. 
	nop			;3af6	00 	. 
	nop			;3af7	00 	. 
	nop			;3af8	00 	. 
	nop			;3af9	00 	. 
	nop			;3afa	00 	. 
	nop			;3afb	00 	. 
	nop			;3afc	00 	. 
	nop			;3afd	00 	. 
	nop			;3afe	00 	. 
	nop			;3aff	00 	. 
	nop			;3b00	00 	. 
	nop			;3b01	00 	. 
	nop			;3b02	00 	. 
	nop			;3b03	00 	. 
	nop			;3b04	00 	. 
	nop			;3b05	00 	. 
	nop			;3b06	00 	. 
	nop			;3b07	00 	. 
	nop			;3b08	00 	. 
	nop			;3b09	00 	. 
	nop			;3b0a	00 	. 
	nop			;3b0b	00 	. 
	nop			;3b0c	00 	. 
	nop			;3b0d	00 	. 
	nop			;3b0e	00 	. 
	nop			;3b0f	00 	. 
	nop			;3b10	00 	. 
	nop			;3b11	00 	. 
	nop			;3b12	00 	. 
	nop			;3b13	00 	. 
	nop			;3b14	00 	. 
	nop			;3b15	00 	. 
	nop			;3b16	00 	. 
	nop			;3b17	00 	. 
	nop			;3b18	00 	. 
	nop			;3b19	00 	. 
	nop			;3b1a	00 	. 
	nop			;3b1b	00 	. 
	nop			;3b1c	00 	. 
	nop			;3b1d	00 	. 
	nop			;3b1e	00 	. 
	nop			;3b1f	00 	. 
	nop			;3b20	00 	. 
	nop			;3b21	00 	. 
	nop			;3b22	00 	. 
	nop			;3b23	00 	. 
	nop			;3b24	00 	. 
	nop			;3b25	00 	. 
	nop			;3b26	00 	. 
	nop			;3b27	00 	. 
	nop			;3b28	00 	. 
	nop			;3b29	00 	. 
	nop			;3b2a	00 	. 
	nop			;3b2b	00 	. 
	nop			;3b2c	00 	. 
	nop			;3b2d	00 	. 
	nop			;3b2e	00 	. 
	nop			;3b2f	00 	. 
	nop			;3b30	00 	. 
	nop			;3b31	00 	. 
	nop			;3b32	00 	. 
	nop			;3b33	00 	. 
	nop			;3b34	00 	. 
	nop			;3b35	00 	. 
	nop			;3b36	00 	. 
	nop			;3b37	00 	. 
	nop			;3b38	00 	. 
	nop			;3b39	00 	. 
	nop			;3b3a	00 	. 
	nop			;3b3b	00 	. 
	nop			;3b3c	00 	. 
	nop			;3b3d	00 	. 
	nop			;3b3e	00 	. 
	nop			;3b3f	00 	. 
	nop			;3b40	00 	. 
	nop			;3b41	00 	. 
	nop			;3b42	00 	. 
	nop			;3b43	00 	. 
	nop			;3b44	00 	. 
	nop			;3b45	00 	. 
	nop			;3b46	00 	. 
	nop			;3b47	00 	. 
	nop			;3b48	00 	. 
	nop			;3b49	00 	. 
	nop			;3b4a	00 	. 
	nop			;3b4b	00 	. 
	nop			;3b4c	00 	. 
	nop			;3b4d	00 	. 
	nop			;3b4e	00 	. 
	nop			;3b4f	00 	. 
	nop			;3b50	00 	. 
	nop			;3b51	00 	. 
	nop			;3b52	00 	. 
	nop			;3b53	00 	. 
	nop			;3b54	00 	. 
	nop			;3b55	00 	. 
	nop			;3b56	00 	. 
	nop			;3b57	00 	. 
	nop			;3b58	00 	. 
	nop			;3b59	00 	. 
	nop			;3b5a	00 	. 
	nop			;3b5b	00 	. 
	nop			;3b5c	00 	. 
	nop			;3b5d	00 	. 
	nop			;3b5e	00 	. 
	nop			;3b5f	00 	. 
	nop			;3b60	00 	. 
	nop			;3b61	00 	. 
	nop			;3b62	00 	. 
	nop			;3b63	00 	. 
	nop			;3b64	00 	. 
	nop			;3b65	00 	. 
	nop			;3b66	00 	. 
	nop			;3b67	00 	. 
	nop			;3b68	00 	. 
	nop			;3b69	00 	. 
	nop			;3b6a	00 	. 
	nop			;3b6b	00 	. 
	nop			;3b6c	00 	. 
	nop			;3b6d	00 	. 
	nop			;3b6e	00 	. 
	nop			;3b6f	00 	. 
	nop			;3b70	00 	. 
	nop			;3b71	00 	. 
	nop			;3b72	00 	. 
	nop			;3b73	00 	. 
	nop			;3b74	00 	. 
	nop			;3b75	00 	. 
	nop			;3b76	00 	. 
	nop			;3b77	00 	. 
	nop			;3b78	00 	. 
	nop			;3b79	00 	. 
	nop			;3b7a	00 	. 
	nop			;3b7b	00 	. 
	nop			;3b7c	00 	. 
	nop			;3b7d	00 	. 
	nop			;3b7e	00 	. 
	nop			;3b7f	00 	. 
	nop			;3b80	00 	. 
	nop			;3b81	00 	. 
	nop			;3b82	00 	. 
	nop			;3b83	00 	. 
	nop			;3b84	00 	. 
	nop			;3b85	00 	. 
	nop			;3b86	00 	. 
	nop			;3b87	00 	. 
	nop			;3b88	00 	. 
	nop			;3b89	00 	. 
	nop			;3b8a	00 	. 
	nop			;3b8b	00 	. 
	nop			;3b8c	00 	. 
	nop			;3b8d	00 	. 
	nop			;3b8e	00 	. 
	nop			;3b8f	00 	. 
	nop			;3b90	00 	. 
	nop			;3b91	00 	. 
	nop			;3b92	00 	. 
	nop			;3b93	00 	. 
	nop			;3b94	00 	. 
	nop			;3b95	00 	. 
	nop			;3b96	00 	. 
	nop			;3b97	00 	. 
	nop			;3b98	00 	. 
	nop			;3b99	00 	. 
	nop			;3b9a	00 	. 
	nop			;3b9b	00 	. 
	nop			;3b9c	00 	. 
	nop			;3b9d	00 	. 
	nop			;3b9e	00 	. 
	nop			;3b9f	00 	. 
	nop			;3ba0	00 	. 
	nop			;3ba1	00 	. 
	nop			;3ba2	00 	. 
	nop			;3ba3	00 	. 
	nop			;3ba4	00 	. 
	nop			;3ba5	00 	. 
	nop			;3ba6	00 	. 
	nop			;3ba7	00 	. 
	nop			;3ba8	00 	. 
	nop			;3ba9	00 	. 
	nop			;3baa	00 	. 
	nop			;3bab	00 	. 
	nop			;3bac	00 	. 
	nop			;3bad	00 	. 
	nop			;3bae	00 	. 
	nop			;3baf	00 	. 
	nop			;3bb0	00 	. 
	nop			;3bb1	00 	. 
	nop			;3bb2	00 	. 
	nop			;3bb3	00 	. 
	nop			;3bb4	00 	. 
	nop			;3bb5	00 	. 
	nop			;3bb6	00 	. 
	nop			;3bb7	00 	. 
	nop			;3bb8	00 	. 
	nop			;3bb9	00 	. 
	nop			;3bba	00 	. 
	nop			;3bbb	00 	. 
	nop			;3bbc	00 	. 
	nop			;3bbd	00 	. 
	nop			;3bbe	00 	. 
	nop			;3bbf	00 	. 
	nop			;3bc0	00 	. 
	nop			;3bc1	00 	. 
	nop			;3bc2	00 	. 
	nop			;3bc3	00 	. 
	nop			;3bc4	00 	. 
	nop			;3bc5	00 	. 
	nop			;3bc6	00 	. 
	nop			;3bc7	00 	. 
	nop			;3bc8	00 	. 
	nop			;3bc9	00 	. 
	nop			;3bca	00 	. 
	nop			;3bcb	00 	. 
	nop			;3bcc	00 	. 
	nop			;3bcd	00 	. 
	nop			;3bce	00 	. 
	nop			;3bcf	00 	. 
	nop			;3bd0	00 	. 
	nop			;3bd1	00 	. 
	nop			;3bd2	00 	. 
	nop			;3bd3	00 	. 
	nop			;3bd4	00 	. 
	nop			;3bd5	00 	. 
	nop			;3bd6	00 	. 
	nop			;3bd7	00 	. 
	nop			;3bd8	00 	. 
	nop			;3bd9	00 	. 
	nop			;3bda	00 	. 
	nop			;3bdb	00 	. 
	nop			;3bdc	00 	. 
	nop			;3bdd	00 	. 
	nop			;3bde	00 	. 
	nop			;3bdf	00 	. 
	nop			;3be0	00 	. 
	nop			;3be1	00 	. 
	nop			;3be2	00 	. 
	nop			;3be3	00 	. 
	nop			;3be4	00 	. 
	nop			;3be5	00 	. 
	nop			;3be6	00 	. 
	nop			;3be7	00 	. 
	nop			;3be8	00 	. 
	nop			;3be9	00 	. 
	nop			;3bea	00 	. 
	nop			;3beb	00 	. 
	nop			;3bec	00 	. 
	nop			;3bed	00 	. 
	nop			;3bee	00 	. 
	nop			;3bef	00 	. 
	nop			;3bf0	00 	. 
	nop			;3bf1	00 	. 
	nop			;3bf2	00 	. 
	nop			;3bf3	00 	. 
	nop			;3bf4	00 	. 
	nop			;3bf5	00 	. 
	nop			;3bf6	00 	. 
	nop			;3bf7	00 	. 
	nop			;3bf8	00 	. 
	nop			;3bf9	00 	. 
	nop			;3bfa	00 	. 
	nop			;3bfb	00 	. 
	nop			;3bfc	00 	. 
	nop			;3bfd	00 	. 
	nop			;3bfe	00 	. 
	nop			;3bff	00 	. 
	nop			;3c00	00 	. 
	nop			;3c01	00 	. 
	nop			;3c02	00 	. 
	nop			;3c03	00 	. 
	nop			;3c04	00 	. 
	nop			;3c05	00 	. 
	nop			;3c06	00 	. 
	nop			;3c07	00 	. 
	nop			;3c08	00 	. 
	nop			;3c09	00 	. 
	nop			;3c0a	00 	. 
	nop			;3c0b	00 	. 
	nop			;3c0c	00 	. 
	nop			;3c0d	00 	. 
	nop			;3c0e	00 	. 
	nop			;3c0f	00 	. 
	nop			;3c10	00 	. 
	nop			;3c11	00 	. 
l3c12h:
	nop			;3c12	00 	. 
	nop			;3c13	00 	. 
	nop			;3c14	00 	. 
	nop			;3c15	00 	. 
	nop			;3c16	00 	. 
	nop			;3c17	00 	. 
	nop			;3c18	00 	. 
	nop			;3c19	00 	. 
	nop			;3c1a	00 	. 
	nop			;3c1b	00 	. 
	nop			;3c1c	00 	. 
	nop			;3c1d	00 	. 
	nop			;3c1e	00 	. 
	nop			;3c1f	00 	. 
	nop			;3c20	00 	. 
	nop			;3c21	00 	. 
	nop			;3c22	00 	. 
	nop			;3c23	00 	. 
	nop			;3c24	00 	. 
	nop			;3c25	00 	. 
	nop			;3c26	00 	. 
	nop			;3c27	00 	. 
	nop			;3c28	00 	. 
	nop			;3c29	00 	. 
	nop			;3c2a	00 	. 
	nop			;3c2b	00 	. 
	nop			;3c2c	00 	. 
	nop			;3c2d	00 	. 
	nop			;3c2e	00 	. 
	nop			;3c2f	00 	. 
	nop			;3c30	00 	. 
	nop			;3c31	00 	. 
	nop			;3c32	00 	. 
	nop			;3c33	00 	. 
	nop			;3c34	00 	. 
	nop			;3c35	00 	. 
	nop			;3c36	00 	. 
	nop			;3c37	00 	. 
	nop			;3c38	00 	. 
	nop			;3c39	00 	. 
	nop			;3c3a	00 	. 
l3c3bh:
	nop			;3c3b	00 	. 
	nop			;3c3c	00 	. 
	nop			;3c3d	00 	. 
	nop			;3c3e	00 	. 
	nop			;3c3f	00 	. 
	nop			;3c40	00 	. 
	nop			;3c41	00 	. 
	nop			;3c42	00 	. 
	nop			;3c43	00 	. 
	nop			;3c44	00 	. 
	nop			;3c45	00 	. 
	nop			;3c46	00 	. 
	nop			;3c47	00 	. 
	nop			;3c48	00 	. 
	nop			;3c49	00 	. 
	nop			;3c4a	00 	. 
	nop			;3c4b	00 	. 
	nop			;3c4c	00 	. 
	nop			;3c4d	00 	. 
	nop			;3c4e	00 	. 
	nop			;3c4f	00 	. 
	nop			;3c50	00 	. 
	nop			;3c51	00 	. 
	nop			;3c52	00 	. 
	nop			;3c53	00 	. 
	nop			;3c54	00 	. 
	nop			;3c55	00 	. 
	nop			;3c56	00 	. 
	nop			;3c57	00 	. 
	nop			;3c58	00 	. 
	nop			;3c59	00 	. 
	nop			;3c5a	00 	. 
	nop			;3c5b	00 	. 
	nop			;3c5c	00 	. 
	nop			;3c5d	00 	. 
	nop			;3c5e	00 	. 
	nop			;3c5f	00 	. 
	nop			;3c60	00 	. 
	nop			;3c61	00 	. 
	nop			;3c62	00 	. 
	nop			;3c63	00 	. 
	nop			;3c64	00 	. 
	nop			;3c65	00 	. 
	nop			;3c66	00 	. 
	nop			;3c67	00 	. 
	nop			;3c68	00 	. 
	nop			;3c69	00 	. 
	nop			;3c6a	00 	. 
	nop			;3c6b	00 	. 
	nop			;3c6c	00 	. 
	nop			;3c6d	00 	. 
	nop			;3c6e	00 	. 
	nop			;3c6f	00 	. 
	nop			;3c70	00 	. 
	nop			;3c71	00 	. 
	nop			;3c72	00 	. 
	nop			;3c73	00 	. 
	nop			;3c74	00 	. 
	nop			;3c75	00 	. 
	nop			;3c76	00 	. 
	nop			;3c77	00 	. 
	nop			;3c78	00 	. 
	nop			;3c79	00 	. 
	nop			;3c7a	00 	. 
	nop			;3c7b	00 	. 
	nop			;3c7c	00 	. 
	nop			;3c7d	00 	. 
	nop			;3c7e	00 	. 
	nop			;3c7f	00 	. 
	nop			;3c80	00 	. 
	nop			;3c81	00 	. 
	nop			;3c82	00 	. 
	nop			;3c83	00 	. 
	nop			;3c84	00 	. 
	nop			;3c85	00 	. 
	nop			;3c86	00 	. 
	nop			;3c87	00 	. 
	nop			;3c88	00 	. 
	nop			;3c89	00 	. 
	nop			;3c8a	00 	. 
	nop			;3c8b	00 	. 
	nop			;3c8c	00 	. 
	nop			;3c8d	00 	. 
	nop			;3c8e	00 	. 
	nop			;3c8f	00 	. 
	nop			;3c90	00 	. 
	nop			;3c91	00 	. 
	nop			;3c92	00 	. 
	nop			;3c93	00 	. 
	nop			;3c94	00 	. 
	nop			;3c95	00 	. 
	nop			;3c96	00 	. 
	nop			;3c97	00 	. 
	nop			;3c98	00 	. 
	nop			;3c99	00 	. 
	nop			;3c9a	00 	. 
	nop			;3c9b	00 	. 
	nop			;3c9c	00 	. 
	nop			;3c9d	00 	. 
	nop			;3c9e	00 	. 
	nop			;3c9f	00 	. 
	nop			;3ca0	00 	. 
	nop			;3ca1	00 	. 
	nop			;3ca2	00 	. 
	nop			;3ca3	00 	. 
	nop			;3ca4	00 	. 
	nop			;3ca5	00 	. 
	nop			;3ca6	00 	. 
	nop			;3ca7	00 	. 
	nop			;3ca8	00 	. 
	nop			;3ca9	00 	. 
	nop			;3caa	00 	. 
	nop			;3cab	00 	. 
	nop			;3cac	00 	. 
	nop			;3cad	00 	. 
	nop			;3cae	00 	. 
	nop			;3caf	00 	. 
	nop			;3cb0	00 	. 
	nop			;3cb1	00 	. 
	nop			;3cb2	00 	. 
	nop			;3cb3	00 	. 
	nop			;3cb4	00 	. 
	nop			;3cb5	00 	. 
	nop			;3cb6	00 	. 
	nop			;3cb7	00 	. 
	nop			;3cb8	00 	. 
	nop			;3cb9	00 	. 
	nop			;3cba	00 	. 
	nop			;3cbb	00 	. 
	nop			;3cbc	00 	. 
	nop			;3cbd	00 	. 
	nop			;3cbe	00 	. 
	nop			;3cbf	00 	. 
	nop			;3cc0	00 	. 
	nop			;3cc1	00 	. 
	nop			;3cc2	00 	. 
	nop			;3cc3	00 	. 
	nop			;3cc4	00 	. 
	nop			;3cc5	00 	. 
	nop			;3cc6	00 	. 
	nop			;3cc7	00 	. 
	nop			;3cc8	00 	. 
	nop			;3cc9	00 	. 
	nop			;3cca	00 	. 
	nop			;3ccb	00 	. 
	nop			;3ccc	00 	. 
	nop			;3ccd	00 	. 
	nop			;3cce	00 	. 
	nop			;3ccf	00 	. 
	nop			;3cd0	00 	. 
	nop			;3cd1	00 	. 
	nop			;3cd2	00 	. 
	nop			;3cd3	00 	. 
	nop			;3cd4	00 	. 
	nop			;3cd5	00 	. 
	nop			;3cd6	00 	. 
	nop			;3cd7	00 	. 
	nop			;3cd8	00 	. 
	nop			;3cd9	00 	. 
	nop			;3cda	00 	. 
	nop			;3cdb	00 	. 
	nop			;3cdc	00 	. 
	nop			;3cdd	00 	. 
	nop			;3cde	00 	. 
	nop			;3cdf	00 	. 
	nop			;3ce0	00 	. 
	nop			;3ce1	00 	. 
	nop			;3ce2	00 	. 
	nop			;3ce3	00 	. 
	nop			;3ce4	00 	. 
	nop			;3ce5	00 	. 
	nop			;3ce6	00 	. 
	nop			;3ce7	00 	. 
	nop			;3ce8	00 	. 
	nop			;3ce9	00 	. 
	nop			;3cea	00 	. 
	nop			;3ceb	00 	. 
	nop			;3cec	00 	. 
	nop			;3ced	00 	. 
	nop			;3cee	00 	. 
	nop			;3cef	00 	. 
	nop			;3cf0	00 	. 
	nop			;3cf1	00 	. 
	nop			;3cf2	00 	. 
	nop			;3cf3	00 	. 
	nop			;3cf4	00 	. 
	nop			;3cf5	00 	. 
	nop			;3cf6	00 	. 
	nop			;3cf7	00 	. 
	nop			;3cf8	00 	. 
	nop			;3cf9	00 	. 
	nop			;3cfa	00 	. 
	nop			;3cfb	00 	. 
	nop			;3cfc	00 	. 
	nop			;3cfd	00 	. 
	nop			;3cfe	00 	. 
	nop			;3cff	00 	. 
	nop			;3d00	00 	. 
	nop			;3d01	00 	. 
	nop			;3d02	00 	. 
	nop			;3d03	00 	. 
	nop			;3d04	00 	. 
	nop			;3d05	00 	. 
	nop			;3d06	00 	. 
	nop			;3d07	00 	. 
	nop			;3d08	00 	. 
	nop			;3d09	00 	. 
	nop			;3d0a	00 	. 
	nop			;3d0b	00 	. 
	nop			;3d0c	00 	. 
	nop			;3d0d	00 	. 
	nop			;3d0e	00 	. 
	nop			;3d0f	00 	. 
	nop			;3d10	00 	. 
	nop			;3d11	00 	. 
	nop			;3d12	00 	. 
	nop			;3d13	00 	. 
	nop			;3d14	00 	. 
	nop			;3d15	00 	. 
	nop			;3d16	00 	. 
	nop			;3d17	00 	. 
	nop			;3d18	00 	. 
	nop			;3d19	00 	. 
	nop			;3d1a	00 	. 
	nop			;3d1b	00 	. 
	nop			;3d1c	00 	. 
	nop			;3d1d	00 	. 
	nop			;3d1e	00 	. 
	nop			;3d1f	00 	. 
	nop			;3d20	00 	. 
	nop			;3d21	00 	. 
	nop			;3d22	00 	. 
	nop			;3d23	00 	. 
	nop			;3d24	00 	. 
	nop			;3d25	00 	. 
	nop			;3d26	00 	. 
	nop			;3d27	00 	. 
	nop			;3d28	00 	. 
	nop			;3d29	00 	. 
	nop			;3d2a	00 	. 
	nop			;3d2b	00 	. 
	nop			;3d2c	00 	. 
	nop			;3d2d	00 	. 
	nop			;3d2e	00 	. 
	nop			;3d2f	00 	. 
	nop			;3d30	00 	. 
	nop			;3d31	00 	. 
	nop			;3d32	00 	. 
	nop			;3d33	00 	. 
	nop			;3d34	00 	. 
	nop			;3d35	00 	. 
	nop			;3d36	00 	. 
	nop			;3d37	00 	. 
	nop			;3d38	00 	. 
	nop			;3d39	00 	. 
	nop			;3d3a	00 	. 
	nop			;3d3b	00 	. 
	nop			;3d3c	00 	. 
	nop			;3d3d	00 	. 
	nop			;3d3e	00 	. 
	nop			;3d3f	00 	. 
	nop			;3d40	00 	. 
	nop			;3d41	00 	. 
	nop			;3d42	00 	. 
	nop			;3d43	00 	. 
	nop			;3d44	00 	. 
	nop			;3d45	00 	. 
	nop			;3d46	00 	. 
	nop			;3d47	00 	. 
	nop			;3d48	00 	. 
	nop			;3d49	00 	. 
	nop			;3d4a	00 	. 
	nop			;3d4b	00 	. 
	nop			;3d4c	00 	. 
	nop			;3d4d	00 	. 
	nop			;3d4e	00 	. 
	nop			;3d4f	00 	. 
	nop			;3d50	00 	. 
	nop			;3d51	00 	. 
	nop			;3d52	00 	. 
	nop			;3d53	00 	. 
	nop			;3d54	00 	. 
	nop			;3d55	00 	. 
	nop			;3d56	00 	. 
	nop			;3d57	00 	. 
	nop			;3d58	00 	. 
	nop			;3d59	00 	. 
	nop			;3d5a	00 	. 
	nop			;3d5b	00 	. 
	nop			;3d5c	00 	. 
	nop			;3d5d	00 	. 
	nop			;3d5e	00 	. 
	nop			;3d5f	00 	. 
	nop			;3d60	00 	. 
	nop			;3d61	00 	. 
	nop			;3d62	00 	. 
	nop			;3d63	00 	. 
	nop			;3d64	00 	. 
	nop			;3d65	00 	. 
	nop			;3d66	00 	. 
	nop			;3d67	00 	. 
	nop			;3d68	00 	. 
	nop			;3d69	00 	. 
	nop			;3d6a	00 	. 
	nop			;3d6b	00 	. 
	nop			;3d6c	00 	. 
	nop			;3d6d	00 	. 
	nop			;3d6e	00 	. 
	nop			;3d6f	00 	. 
	nop			;3d70	00 	. 
	nop			;3d71	00 	. 
	nop			;3d72	00 	. 
	nop			;3d73	00 	. 
	nop			;3d74	00 	. 
	nop			;3d75	00 	. 
	nop			;3d76	00 	. 
	nop			;3d77	00 	. 
	nop			;3d78	00 	. 
	nop			;3d79	00 	. 
	nop			;3d7a	00 	. 
	nop			;3d7b	00 	. 
	nop			;3d7c	00 	. 
	nop			;3d7d	00 	. 
	nop			;3d7e	00 	. 
	nop			;3d7f	00 	. 
	nop			;3d80	00 	. 
	nop			;3d81	00 	. 
	nop			;3d82	00 	. 
	nop			;3d83	00 	. 
	nop			;3d84	00 	. 
	nop			;3d85	00 	. 
	nop			;3d86	00 	. 
	nop			;3d87	00 	. 
	nop			;3d88	00 	. 
	nop			;3d89	00 	. 
	nop			;3d8a	00 	. 
	nop			;3d8b	00 	. 
	nop			;3d8c	00 	. 
	nop			;3d8d	00 	. 
	nop			;3d8e	00 	. 
	nop			;3d8f	00 	. 
	nop			;3d90	00 	. 
	nop			;3d91	00 	. 
	nop			;3d92	00 	. 
	nop			;3d93	00 	. 
	nop			;3d94	00 	. 
	nop			;3d95	00 	. 
	nop			;3d96	00 	. 
	nop			;3d97	00 	. 
	nop			;3d98	00 	. 
	nop			;3d99	00 	. 
	nop			;3d9a	00 	. 
	nop			;3d9b	00 	. 
	nop			;3d9c	00 	. 
	nop			;3d9d	00 	. 
	nop			;3d9e	00 	. 
	nop			;3d9f	00 	. 
	nop			;3da0	00 	. 
	nop			;3da1	00 	. 
	nop			;3da2	00 	. 
	nop			;3da3	00 	. 
	nop			;3da4	00 	. 
	nop			;3da5	00 	. 
	nop			;3da6	00 	. 
	nop			;3da7	00 	. 
	nop			;3da8	00 	. 
	nop			;3da9	00 	. 
	nop			;3daa	00 	. 
	nop			;3dab	00 	. 
	nop			;3dac	00 	. 
	nop			;3dad	00 	. 
	nop			;3dae	00 	. 
	nop			;3daf	00 	. 
	nop			;3db0	00 	. 
	nop			;3db1	00 	. 
	nop			;3db2	00 	. 
	nop			;3db3	00 	. 
	nop			;3db4	00 	. 
	nop			;3db5	00 	. 
	nop			;3db6	00 	. 
	nop			;3db7	00 	. 
	nop			;3db8	00 	. 
	nop			;3db9	00 	. 
	nop			;3dba	00 	. 
	nop			;3dbb	00 	. 
	nop			;3dbc	00 	. 
	nop			;3dbd	00 	. 
	nop			;3dbe	00 	. 
	nop			;3dbf	00 	. 
	nop			;3dc0	00 	. 
	nop			;3dc1	00 	. 
	nop			;3dc2	00 	. 
	nop			;3dc3	00 	. 
	nop			;3dc4	00 	. 
	nop			;3dc5	00 	. 
	nop			;3dc6	00 	. 
	nop			;3dc7	00 	. 
	nop			;3dc8	00 	. 
	nop			;3dc9	00 	. 
	nop			;3dca	00 	. 
	nop			;3dcb	00 	. 
	nop			;3dcc	00 	. 
	nop			;3dcd	00 	. 
	nop			;3dce	00 	. 
	nop			;3dcf	00 	. 
	nop			;3dd0	00 	. 
	nop			;3dd1	00 	. 
	nop			;3dd2	00 	. 
	nop			;3dd3	00 	. 
	nop			;3dd4	00 	. 
	nop			;3dd5	00 	. 
	nop			;3dd6	00 	. 
	nop			;3dd7	00 	. 
	nop			;3dd8	00 	. 
	nop			;3dd9	00 	. 
	nop			;3dda	00 	. 
	nop			;3ddb	00 	. 
	nop			;3ddc	00 	. 
	nop			;3ddd	00 	. 
	nop			;3dde	00 	. 
	nop			;3ddf	00 	. 
	nop			;3de0	00 	. 
	nop			;3de1	00 	. 
	nop			;3de2	00 	. 
	nop			;3de3	00 	. 
	nop			;3de4	00 	. 
	nop			;3de5	00 	. 
	nop			;3de6	00 	. 
	nop			;3de7	00 	. 
	nop			;3de8	00 	. 
	nop			;3de9	00 	. 
	nop			;3dea	00 	. 
	nop			;3deb	00 	. 
	nop			;3dec	00 	. 
	nop			;3ded	00 	. 
	nop			;3dee	00 	. 
	nop			;3def	00 	. 
	nop			;3df0	00 	. 
	nop			;3df1	00 	. 
	nop			;3df2	00 	. 
	nop			;3df3	00 	. 
	nop			;3df4	00 	. 
	nop			;3df5	00 	. 
	nop			;3df6	00 	. 
	nop			;3df7	00 	. 
	nop			;3df8	00 	. 
	nop			;3df9	00 	. 
	nop			;3dfa	00 	. 
	nop			;3dfb	00 	. 
	nop			;3dfc	00 	. 
	nop			;3dfd	00 	. 
	nop			;3dfe	00 	. 
	nop			;3dff	00 	. 
	nop			;3e00	00 	. 
	nop			;3e01	00 	. 
	nop			;3e02	00 	. 
	nop			;3e03	00 	. 
	nop			;3e04	00 	. 
	nop			;3e05	00 	. 
	nop			;3e06	00 	. 
	nop			;3e07	00 	. 
	nop			;3e08	00 	. 
	nop			;3e09	00 	. 
	nop			;3e0a	00 	. 
	nop			;3e0b	00 	. 
	nop			;3e0c	00 	. 
	nop			;3e0d	00 	. 
	nop			;3e0e	00 	. 
	nop			;3e0f	00 	. 
	nop			;3e10	00 	. 
	nop			;3e11	00 	. 
	nop			;3e12	00 	. 
	nop			;3e13	00 	. 
	nop			;3e14	00 	. 
	nop			;3e15	00 	. 
	nop			;3e16	00 	. 
	nop			;3e17	00 	. 
	nop			;3e18	00 	. 
	nop			;3e19	00 	. 
	nop			;3e1a	00 	. 
	nop			;3e1b	00 	. 
	nop			;3e1c	00 	. 
	nop			;3e1d	00 	. 
	nop			;3e1e	00 	. 
	nop			;3e1f	00 	. 
	nop			;3e20	00 	. 
	nop			;3e21	00 	. 
	nop			;3e22	00 	. 
	nop			;3e23	00 	. 
	nop			;3e24	00 	. 
	nop			;3e25	00 	. 
	nop			;3e26	00 	. 
	nop			;3e27	00 	. 
	nop			;3e28	00 	. 
	nop			;3e29	00 	. 
	nop			;3e2a	00 	. 
	nop			;3e2b	00 	. 
	nop			;3e2c	00 	. 
	nop			;3e2d	00 	. 
	nop			;3e2e	00 	. 
	nop			;3e2f	00 	. 
	nop			;3e30	00 	. 
	nop			;3e31	00 	. 
	nop			;3e32	00 	. 
	nop			;3e33	00 	. 
	nop			;3e34	00 	. 
	nop			;3e35	00 	. 
	nop			;3e36	00 	. 
	nop			;3e37	00 	. 
	nop			;3e38	00 	. 
	nop			;3e39	00 	. 
	nop			;3e3a	00 	. 
	nop			;3e3b	00 	. 
	nop			;3e3c	00 	. 
	nop			;3e3d	00 	. 
	nop			;3e3e	00 	. 
	nop			;3e3f	00 	. 
	nop			;3e40	00 	. 
	nop			;3e41	00 	. 
	nop			;3e42	00 	. 
	nop			;3e43	00 	. 
	nop			;3e44	00 	. 
	nop			;3e45	00 	. 
	nop			;3e46	00 	. 
	nop			;3e47	00 	. 
	nop			;3e48	00 	. 
	nop			;3e49	00 	. 
	nop			;3e4a	00 	. 
	nop			;3e4b	00 	. 
	nop			;3e4c	00 	. 
	nop			;3e4d	00 	. 
	nop			;3e4e	00 	. 
	nop			;3e4f	00 	. 
	nop			;3e50	00 	. 
	nop			;3e51	00 	. 
	nop			;3e52	00 	. 
	nop			;3e53	00 	. 
	nop			;3e54	00 	. 
	nop			;3e55	00 	. 
	nop			;3e56	00 	. 
	nop			;3e57	00 	. 
	nop			;3e58	00 	. 
	nop			;3e59	00 	. 
	nop			;3e5a	00 	. 
	nop			;3e5b	00 	. 
	nop			;3e5c	00 	. 
	nop			;3e5d	00 	. 
	nop			;3e5e	00 	. 
	nop			;3e5f	00 	. 
	nop			;3e60	00 	. 
	nop			;3e61	00 	. 
	nop			;3e62	00 	. 
	nop			;3e63	00 	. 
	nop			;3e64	00 	. 
	nop			;3e65	00 	. 
	nop			;3e66	00 	. 
	nop			;3e67	00 	. 
	nop			;3e68	00 	. 
	nop			;3e69	00 	. 
	nop			;3e6a	00 	. 
	nop			;3e6b	00 	. 
	nop			;3e6c	00 	. 
	nop			;3e6d	00 	. 
	nop			;3e6e	00 	. 
	nop			;3e6f	00 	. 
	nop			;3e70	00 	. 
	nop			;3e71	00 	. 
	nop			;3e72	00 	. 
	nop			;3e73	00 	. 
	nop			;3e74	00 	. 
	nop			;3e75	00 	. 
	nop			;3e76	00 	. 
	nop			;3e77	00 	. 
	nop			;3e78	00 	. 
	nop			;3e79	00 	. 
	nop			;3e7a	00 	. 
	nop			;3e7b	00 	. 
	nop			;3e7c	00 	. 
	nop			;3e7d	00 	. 
	nop			;3e7e	00 	. 
	nop			;3e7f	00 	. 
	nop			;3e80	00 	. 
	nop			;3e81	00 	. 
	nop			;3e82	00 	. 
	nop			;3e83	00 	. 
	nop			;3e84	00 	. 
	nop			;3e85	00 	. 
	nop			;3e86	00 	. 
	nop			;3e87	00 	. 
	nop			;3e88	00 	. 
	nop			;3e89	00 	. 
	nop			;3e8a	00 	. 
	nop			;3e8b	00 	. 
	nop			;3e8c	00 	. 
	nop			;3e8d	00 	. 
	nop			;3e8e	00 	. 
	nop			;3e8f	00 	. 
	nop			;3e90	00 	. 
	nop			;3e91	00 	. 
	nop			;3e92	00 	. 
	nop			;3e93	00 	. 
	nop			;3e94	00 	. 
	nop			;3e95	00 	. 
	nop			;3e96	00 	. 
	nop			;3e97	00 	. 
	nop			;3e98	00 	. 
	nop			;3e99	00 	. 
	nop			;3e9a	00 	. 
	nop			;3e9b	00 	. 
	nop			;3e9c	00 	. 
	nop			;3e9d	00 	. 
	nop			;3e9e	00 	. 
	nop			;3e9f	00 	. 
	nop			;3ea0	00 	. 
	nop			;3ea1	00 	. 
	nop			;3ea2	00 	. 
	nop			;3ea3	00 	. 
	nop			;3ea4	00 	. 
	nop			;3ea5	00 	. 
	nop			;3ea6	00 	. 
	nop			;3ea7	00 	. 
	nop			;3ea8	00 	. 
	nop			;3ea9	00 	. 
	nop			;3eaa	00 	. 
	nop			;3eab	00 	. 
	nop			;3eac	00 	. 
	nop			;3ead	00 	. 
	nop			;3eae	00 	. 
	nop			;3eaf	00 	. 
	nop			;3eb0	00 	. 
	nop			;3eb1	00 	. 
	nop			;3eb2	00 	. 
	nop			;3eb3	00 	. 
	nop			;3eb4	00 	. 
	nop			;3eb5	00 	. 
	nop			;3eb6	00 	. 
	nop			;3eb7	00 	. 
	nop			;3eb8	00 	. 
	nop			;3eb9	00 	. 
	nop			;3eba	00 	. 
	nop			;3ebb	00 	. 
	nop			;3ebc	00 	. 
	nop			;3ebd	00 	. 
	nop			;3ebe	00 	. 
	nop			;3ebf	00 	. 
	nop			;3ec0	00 	. 
	nop			;3ec1	00 	. 
	nop			;3ec2	00 	. 
	nop			;3ec3	00 	. 
	nop			;3ec4	00 	. 
	nop			;3ec5	00 	. 
	nop			;3ec6	00 	. 
	nop			;3ec7	00 	. 
	nop			;3ec8	00 	. 
	nop			;3ec9	00 	. 
	nop			;3eca	00 	. 
	nop			;3ecb	00 	. 
	nop			;3ecc	00 	. 
	nop			;3ecd	00 	. 
	nop			;3ece	00 	. 
	nop			;3ecf	00 	. 
	nop			;3ed0	00 	. 
	nop			;3ed1	00 	. 
	nop			;3ed2	00 	. 
	nop			;3ed3	00 	. 
	nop			;3ed4	00 	. 
	nop			;3ed5	00 	. 
	nop			;3ed6	00 	. 
	nop			;3ed7	00 	. 
	nop			;3ed8	00 	. 
	nop			;3ed9	00 	. 
	nop			;3eda	00 	. 
	nop			;3edb	00 	. 
	nop			;3edc	00 	. 
	nop			;3edd	00 	. 
	nop			;3ede	00 	. 
	nop			;3edf	00 	. 
	nop			;3ee0	00 	. 
	nop			;3ee1	00 	. 
	nop			;3ee2	00 	. 
	nop			;3ee3	00 	. 
	nop			;3ee4	00 	. 
	nop			;3ee5	00 	. 
	nop			;3ee6	00 	. 
	nop			;3ee7	00 	. 
	nop			;3ee8	00 	. 
	nop			;3ee9	00 	. 
	nop			;3eea	00 	. 
	nop			;3eeb	00 	. 
	nop			;3eec	00 	. 
	nop			;3eed	00 	. 
	nop			;3eee	00 	. 
	nop			;3eef	00 	. 
	nop			;3ef0	00 	. 
	nop			;3ef1	00 	. 
	nop			;3ef2	00 	. 
	nop			;3ef3	00 	. 
	nop			;3ef4	00 	. 
	nop			;3ef5	00 	. 
	nop			;3ef6	00 	. 
	nop			;3ef7	00 	. 
	nop			;3ef8	00 	. 
	nop			;3ef9	00 	. 
	nop			;3efa	00 	. 
	nop			;3efb	00 	. 
	nop			;3efc	00 	. 
	nop			;3efd	00 	. 
	nop			;3efe	00 	. 
	nop			;3eff	00 	. 
	nop			;3f00	00 	. 
	nop			;3f01	00 	. 
	nop			;3f02	00 	. 
	nop			;3f03	00 	. 
	nop			;3f04	00 	. 
	nop			;3f05	00 	. 
	nop			;3f06	00 	. 
	nop			;3f07	00 	. 
	nop			;3f08	00 	. 
	nop			;3f09	00 	. 
	nop			;3f0a	00 	. 
	nop			;3f0b	00 	. 
	nop			;3f0c	00 	. 
	nop			;3f0d	00 	. 
	nop			;3f0e	00 	. 
	nop			;3f0f	00 	. 
	nop			;3f10	00 	. 
	nop			;3f11	00 	. 
	nop			;3f12	00 	. 
	nop			;3f13	00 	. 
	nop			;3f14	00 	. 
	nop			;3f15	00 	. 
	nop			;3f16	00 	. 
	nop			;3f17	00 	. 
	nop			;3f18	00 	. 
	nop			;3f19	00 	. 
	nop			;3f1a	00 	. 
	nop			;3f1b	00 	. 
	nop			;3f1c	00 	. 
	nop			;3f1d	00 	. 
	nop			;3f1e	00 	. 
	nop			;3f1f	00 	. 
	nop			;3f20	00 	. 
	nop			;3f21	00 	. 
	nop			;3f22	00 	. 
	nop			;3f23	00 	. 
	nop			;3f24	00 	. 
	nop			;3f25	00 	. 
	nop			;3f26	00 	. 
	nop			;3f27	00 	. 
	nop			;3f28	00 	. 
	nop			;3f29	00 	. 
	nop			;3f2a	00 	. 
	nop			;3f2b	00 	. 
	nop			;3f2c	00 	. 
	nop			;3f2d	00 	. 
	nop			;3f2e	00 	. 
	nop			;3f2f	00 	. 
	nop			;3f30	00 	. 
	nop			;3f31	00 	. 
	nop			;3f32	00 	. 
	nop			;3f33	00 	. 
	nop			;3f34	00 	. 
	nop			;3f35	00 	. 
	nop			;3f36	00 	. 
	nop			;3f37	00 	. 
	nop			;3f38	00 	. 
	nop			;3f39	00 	. 
	nop			;3f3a	00 	. 
	nop			;3f3b	00 	. 
	nop			;3f3c	00 	. 
	nop			;3f3d	00 	. 
	nop			;3f3e	00 	. 
	nop			;3f3f	00 	. 
	nop			;3f40	00 	. 
	nop			;3f41	00 	. 
	nop			;3f42	00 	. 
	nop			;3f43	00 	. 
	nop			;3f44	00 	. 
	nop			;3f45	00 	. 
	nop			;3f46	00 	. 
	nop			;3f47	00 	. 
	nop			;3f48	00 	. 
	nop			;3f49	00 	. 
	nop			;3f4a	00 	. 
	nop			;3f4b	00 	. 
	nop			;3f4c	00 	. 
	nop			;3f4d	00 	. 
	nop			;3f4e	00 	. 
	nop			;3f4f	00 	. 
	nop			;3f50	00 	. 
	nop			;3f51	00 	. 
	nop			;3f52	00 	. 
	nop			;3f53	00 	. 
	nop			;3f54	00 	. 
	nop			;3f55	00 	. 
	nop			;3f56	00 	. 
	nop			;3f57	00 	. 
	nop			;3f58	00 	. 
	nop			;3f59	00 	. 
	nop			;3f5a	00 	. 
	nop			;3f5b	00 	. 
	nop			;3f5c	00 	. 
	nop			;3f5d	00 	. 
	nop			;3f5e	00 	. 
	nop			;3f5f	00 	. 
	nop			;3f60	00 	. 
	nop			;3f61	00 	. 
	nop			;3f62	00 	. 
	nop			;3f63	00 	. 
	nop			;3f64	00 	. 
	nop			;3f65	00 	. 
	nop			;3f66	00 	. 
	nop			;3f67	00 	. 
	nop			;3f68	00 	. 
	nop			;3f69	00 	. 
	nop			;3f6a	00 	. 
	nop			;3f6b	00 	. 
	nop			;3f6c	00 	. 
	nop			;3f6d	00 	. 
	nop			;3f6e	00 	. 
	nop			;3f6f	00 	. 
	nop			;3f70	00 	. 
	nop			;3f71	00 	. 
	nop			;3f72	00 	. 
	nop			;3f73	00 	. 
	nop			;3f74	00 	. 
	nop			;3f75	00 	. 
	nop			;3f76	00 	. 
	nop			;3f77	00 	. 
	nop			;3f78	00 	. 
	nop			;3f79	00 	. 
	nop			;3f7a	00 	. 
	nop			;3f7b	00 	. 
	nop			;3f7c	00 	. 
	nop			;3f7d	00 	. 
	nop			;3f7e	00 	. 
	nop			;3f7f	00 	. 
	nop			;3f80	00 	. 
	nop			;3f81	00 	. 
	nop			;3f82	00 	. 
	nop			;3f83	00 	. 
	nop			;3f84	00 	. 
	nop			;3f85	00 	. 
	nop			;3f86	00 	. 
	nop			;3f87	00 	. 
	nop			;3f88	00 	. 
	nop			;3f89	00 	. 
	nop			;3f8a	00 	. 
	nop			;3f8b	00 	. 
	nop			;3f8c	00 	. 
	nop			;3f8d	00 	. 
	nop			;3f8e	00 	. 
	nop			;3f8f	00 	. 
	nop			;3f90	00 	. 
	nop			;3f91	00 	. 
	nop			;3f92	00 	. 
	nop			;3f93	00 	. 
	nop			;3f94	00 	. 
	nop			;3f95	00 	. 
	nop			;3f96	00 	. 
	nop			;3f97	00 	. 
	nop			;3f98	00 	. 
	nop			;3f99	00 	. 
	nop			;3f9a	00 	. 
	nop			;3f9b	00 	. 
	nop			;3f9c	00 	. 
	nop			;3f9d	00 	. 
	nop			;3f9e	00 	. 
	nop			;3f9f	00 	. 
	nop			;3fa0	00 	. 
	nop			;3fa1	00 	. 
	nop			;3fa2	00 	. 
	nop			;3fa3	00 	. 
	nop			;3fa4	00 	. 
	nop			;3fa5	00 	. 
	nop			;3fa6	00 	. 
	nop			;3fa7	00 	. 
	nop			;3fa8	00 	. 
	nop			;3fa9	00 	. 
	nop			;3faa	00 	. 
	nop			;3fab	00 	. 
	nop			;3fac	00 	. 
	nop			;3fad	00 	. 
	nop			;3fae	00 	. 
	nop			;3faf	00 	. 
	nop			;3fb0	00 	. 
	nop			;3fb1	00 	. 
	nop			;3fb2	00 	. 
	nop			;3fb3	00 	. 
	nop			;3fb4	00 	. 
	nop			;3fb5	00 	. 
	nop			;3fb6	00 	. 
	nop			;3fb7	00 	. 
	nop			;3fb8	00 	. 
	nop			;3fb9	00 	. 
	nop			;3fba	00 	. 
	nop			;3fbb	00 	. 
	nop			;3fbc	00 	. 
	nop			;3fbd	00 	. 
	nop			;3fbe	00 	. 
	nop			;3fbf	00 	. 
	nop			;3fc0	00 	. 
	nop			;3fc1	00 	. 
	nop			;3fc2	00 	. 
	nop			;3fc3	00 	. 
	nop			;3fc4	00 	. 
	nop			;3fc5	00 	. 
	nop			;3fc6	00 	. 
	nop			;3fc7	00 	. 
	nop			;3fc8	00 	. 
	nop			;3fc9	00 	. 
	nop			;3fca	00 	. 
	nop			;3fcb	00 	. 
	nop			;3fcc	00 	. 
	nop			;3fcd	00 	. 
	nop			;3fce	00 	. 
	nop			;3fcf	00 	. 
	nop			;3fd0	00 	. 
	nop			;3fd1	00 	. 
	nop			;3fd2	00 	. 
	nop			;3fd3	00 	. 
	nop			;3fd4	00 	. 
	nop			;3fd5	00 	. 
	nop			;3fd6	00 	. 
	nop			;3fd7	00 	. 
	nop			;3fd8	00 	. 
	nop			;3fd9	00 	. 
	nop			;3fda	00 	. 
	nop			;3fdb	00 	. 
	nop			;3fdc	00 	. 
	nop			;3fdd	00 	. 
	nop			;3fde	00 	. 
	nop			;3fdf	00 	. 
	nop			;3fe0	00 	. 
	nop			;3fe1	00 	. 
	nop			;3fe2	00 	. 
	nop			;3fe3	00 	. 
	nop			;3fe4	00 	. 
	nop			;3fe5	00 	. 
	nop			;3fe6	00 	. 
	nop			;3fe7	00 	. 
	nop			;3fe8	00 	. 
	nop			;3fe9	00 	. 
	nop			;3fea	00 	. 
	nop			;3feb	00 	. 
	nop			;3fec	00 	. 
	nop			;3fed	00 	. 
	nop			;3fee	00 	. 
	nop			;3fef	00 	. 
	nop			;3ff0	00 	. 
	nop			;3ff1	00 	. 
	nop			;3ff2	00 	. 
	nop			;3ff3	00 	. 
	nop			;3ff4	00 	. 
	nop			;3ff5	00 	. 
	nop			;3ff6	00 	. 
	nop			;3ff7	00 	. 
	nop			;3ff8	00 	. 
	nop			;3ff9	00 	. 
	nop			;3ffa	00 	. 
	nop			;3ffb	00 	. 
	nop			;3ffc	00 	. 
	nop			;3ffd	00 	. 
	nop			;3ffe	00 	. 
	nop			;3fff	00 	. 
	nop			;4000	00 	. 
	nop			;4001	00 	. 
	nop			;4002	00 	. 
	nop			;4003	00 	. 
	nop			;4004	00 	. 
	nop			;4005	00 	. 
	nop			;4006	00 	. 
	nop			;4007	00 	. 
	nop			;4008	00 	. 
	nop			;4009	00 	. 
	nop			;400a	00 	. 
	nop			;400b	00 	. 
	nop			;400c	00 	. 
	nop			;400d	00 	. 
	nop			;400e	00 	. 
	nop			;400f	00 	. 
	nop			;4010	00 	. 
	nop			;4011	00 	. 
	nop			;4012	00 	. 
	nop			;4013	00 	. 
	nop			;4014	00 	. 
	nop			;4015	00 	. 
	nop			;4016	00 	. 
	nop			;4017	00 	. 
	nop			;4018	00 	. 
	nop			;4019	00 	. 
	nop			;401a	00 	. 
	nop			;401b	00 	. 
	nop			;401c	00 	. 
	nop			;401d	00 	. 
	nop			;401e	00 	. 
	nop			;401f	00 	. 
	nop			;4020	00 	. 
	nop			;4021	00 	. 
	nop			;4022	00 	. 
	nop			;4023	00 	. 
	nop			;4024	00 	. 
	nop			;4025	00 	. 
	nop			;4026	00 	. 
	nop			;4027	00 	. 
	nop			;4028	00 	. 
	nop			;4029	00 	. 
	nop			;402a	00 	. 
	nop			;402b	00 	. 
	nop			;402c	00 	. 
	nop			;402d	00 	. 
	nop			;402e	00 	. 
	nop			;402f	00 	. 
	nop			;4030	00 	. 
	nop			;4031	00 	. 
	nop			;4032	00 	. 
	nop			;4033	00 	. 
	nop			;4034	00 	. 
	nop			;4035	00 	. 
	nop			;4036	00 	. 
	nop			;4037	00 	. 
	nop			;4038	00 	. 
	nop			;4039	00 	. 
	nop			;403a	00 	. 
	nop			;403b	00 	. 
	nop			;403c	00 	. 
	nop			;403d	00 	. 
	nop			;403e	00 	. 
	nop			;403f	00 	. 
	nop			;4040	00 	. 
	nop			;4041	00 	. 
	nop			;4042	00 	. 
	nop			;4043	00 	. 
	nop			;4044	00 	. 
	nop			;4045	00 	. 
	nop			;4046	00 	. 
	nop			;4047	00 	. 
	nop			;4048	00 	. 
	nop			;4049	00 	. 
	nop			;404a	00 	. 
	nop			;404b	00 	. 
	nop			;404c	00 	. 
	nop			;404d	00 	. 
	nop			;404e	00 	. 
	nop			;404f	00 	. 
	nop			;4050	00 	. 
	nop			;4051	00 	. 
	nop			;4052	00 	. 
	nop			;4053	00 	. 
	nop			;4054	00 	. 
	nop			;4055	00 	. 
	nop			;4056	00 	. 
	nop			;4057	00 	. 
	nop			;4058	00 	. 
	nop			;4059	00 	. 
	nop			;405a	00 	. 
	nop			;405b	00 	. 
	nop			;405c	00 	. 
	nop			;405d	00 	. 
	nop			;405e	00 	. 
	nop			;405f	00 	. 
	nop			;4060	00 	. 
	nop			;4061	00 	. 
	nop			;4062	00 	. 
	nop			;4063	00 	. 
	nop			;4064	00 	. 
	nop			;4065	00 	. 
	nop			;4066	00 	. 
	nop			;4067	00 	. 
	nop			;4068	00 	. 
	nop			;4069	00 	. 
	nop			;406a	00 	. 
	nop			;406b	00 	. 
	nop			;406c	00 	. 
	nop			;406d	00 	. 
	nop			;406e	00 	. 
	nop			;406f	00 	. 
	nop			;4070	00 	. 
	nop			;4071	00 	. 
	nop			;4072	00 	. 
	nop			;4073	00 	. 
	nop			;4074	00 	. 
	nop			;4075	00 	. 
	nop			;4076	00 	. 
	nop			;4077	00 	. 
	nop			;4078	00 	. 
	nop			;4079	00 	. 
	nop			;407a	00 	. 
	nop			;407b	00 	. 
	nop			;407c	00 	. 
	nop			;407d	00 	. 
	nop			;407e	00 	. 
	nop			;407f	00 	. 
	nop			;4080	00 	. 
	nop			;4081	00 	. 
	nop			;4082	00 	. 
	nop			;4083	00 	. 
	nop			;4084	00 	. 
	nop			;4085	00 	. 
	nop			;4086	00 	. 
	nop			;4087	00 	. 
	nop			;4088	00 	. 
	nop			;4089	00 	. 
	nop			;408a	00 	. 
	nop			;408b	00 	. 
	nop			;408c	00 	. 
	nop			;408d	00 	. 
	nop			;408e	00 	. 
	nop			;408f	00 	. 
	nop			;4090	00 	. 
	nop			;4091	00 	. 
	nop			;4092	00 	. 
	nop			;4093	00 	. 
	nop			;4094	00 	. 
	nop			;4095	00 	. 
	nop			;4096	00 	. 
	nop			;4097	00 	. 
	nop			;4098	00 	. 
	nop			;4099	00 	. 
	nop			;409a	00 	. 
	nop			;409b	00 	. 
	nop			;409c	00 	. 
	nop			;409d	00 	. 
	nop			;409e	00 	. 
	nop			;409f	00 	. 
	nop			;40a0	00 	. 
	nop			;40a1	00 	. 
	nop			;40a2	00 	. 
	nop			;40a3	00 	. 
	nop			;40a4	00 	. 
	nop			;40a5	00 	. 
	nop			;40a6	00 	. 
	nop			;40a7	00 	. 
	nop			;40a8	00 	. 
	nop			;40a9	00 	. 
	nop			;40aa	00 	. 
	nop			;40ab	00 	. 
	nop			;40ac	00 	. 
	nop			;40ad	00 	. 
	nop			;40ae	00 	. 
	nop			;40af	00 	. 
	nop			;40b0	00 	. 
	nop			;40b1	00 	. 
	nop			;40b2	00 	. 
	nop			;40b3	00 	. 
	nop			;40b4	00 	. 
	nop			;40b5	00 	. 
	nop			;40b6	00 	. 
	nop			;40b7	00 	. 
	nop			;40b8	00 	. 
	nop			;40b9	00 	. 
	nop			;40ba	00 	. 
	nop			;40bb	00 	. 
	nop			;40bc	00 	. 
	nop			;40bd	00 	. 
	nop			;40be	00 	. 
	nop			;40bf	00 	. 
	nop			;40c0	00 	. 
	nop			;40c1	00 	. 
	nop			;40c2	00 	. 
	nop			;40c3	00 	. 
	nop			;40c4	00 	. 
	nop			;40c5	00 	. 
	nop			;40c6	00 	. 
	nop			;40c7	00 	. 
	nop			;40c8	00 	. 
	nop			;40c9	00 	. 
	nop			;40ca	00 	. 
	nop			;40cb	00 	. 
	nop			;40cc	00 	. 
	nop			;40cd	00 	. 
	nop			;40ce	00 	. 
	nop			;40cf	00 	. 
	nop			;40d0	00 	. 
	nop			;40d1	00 	. 
	nop			;40d2	00 	. 
	nop			;40d3	00 	. 
	nop			;40d4	00 	. 
	nop			;40d5	00 	. 
	nop			;40d6	00 	. 
	nop			;40d7	00 	. 
	nop			;40d8	00 	. 
	nop			;40d9	00 	. 
	nop			;40da	00 	. 
	nop			;40db	00 	. 
	nop			;40dc	00 	. 
	nop			;40dd	00 	. 
	nop			;40de	00 	. 
	nop			;40df	00 	. 
	nop			;40e0	00 	. 
	nop			;40e1	00 	. 
	nop			;40e2	00 	. 
	nop			;40e3	00 	. 
	nop			;40e4	00 	. 
	nop			;40e5	00 	. 
	nop			;40e6	00 	. 
	nop			;40e7	00 	. 
	nop			;40e8	00 	. 
	nop			;40e9	00 	. 
	nop			;40ea	00 	. 
	nop			;40eb	00 	. 
	nop			;40ec	00 	. 
	nop			;40ed	00 	. 
	nop			;40ee	00 	. 
	nop			;40ef	00 	. 
	nop			;40f0	00 	. 
	nop			;40f1	00 	. 
	nop			;40f2	00 	. 
	nop			;40f3	00 	. 
	nop			;40f4	00 	. 
	nop			;40f5	00 	. 
	nop			;40f6	00 	. 
	nop			;40f7	00 	. 
	nop			;40f8	00 	. 
	nop			;40f9	00 	. 
	nop			;40fa	00 	. 
	nop			;40fb	00 	. 
	nop			;40fc	00 	. 
	nop			;40fd	00 	. 
	nop			;40fe	00 	. 
	nop			;40ff	00 	. 
	nop			;4100	00 	. 
	nop			;4101	00 	. 
	nop			;4102	00 	. 
	nop			;4103	00 	. 
	nop			;4104	00 	. 
	nop			;4105	00 	. 
	nop			;4106	00 	. 
	nop			;4107	00 	. 
	nop			;4108	00 	. 
	nop			;4109	00 	. 
	nop			;410a	00 	. 
	nop			;410b	00 	. 
	nop			;410c	00 	. 
	nop			;410d	00 	. 
	nop			;410e	00 	. 
	nop			;410f	00 	. 
	nop			;4110	00 	. 
	nop			;4111	00 	. 
	nop			;4112	00 	. 
	nop			;4113	00 	. 
	nop			;4114	00 	. 
	nop			;4115	00 	. 
	nop			;4116	00 	. 
	nop			;4117	00 	. 
	nop			;4118	00 	. 
	nop			;4119	00 	. 
	nop			;411a	00 	. 
	nop			;411b	00 	. 
	nop			;411c	00 	. 
	nop			;411d	00 	. 
	nop			;411e	00 	. 
	nop			;411f	00 	. 
	nop			;4120	00 	. 
	nop			;4121	00 	. 
	nop			;4122	00 	. 
	nop			;4123	00 	. 
	nop			;4124	00 	. 
	nop			;4125	00 	. 
	nop			;4126	00 	. 
	nop			;4127	00 	. 
	nop			;4128	00 	. 
	nop			;4129	00 	. 
	nop			;412a	00 	. 
	nop			;412b	00 	. 
	nop			;412c	00 	. 
	nop			;412d	00 	. 
	nop			;412e	00 	. 
	nop			;412f	00 	. 
	nop			;4130	00 	. 
	nop			;4131	00 	. 
	nop			;4132	00 	. 
	nop			;4133	00 	. 
	nop			;4134	00 	. 
	nop			;4135	00 	. 
	nop			;4136	00 	. 
	nop			;4137	00 	. 
	nop			;4138	00 	. 
	nop			;4139	00 	. 
	nop			;413a	00 	. 
	nop			;413b	00 	. 
	nop			;413c	00 	. 
	nop			;413d	00 	. 
	nop			;413e	00 	. 
	nop			;413f	00 	. 
	nop			;4140	00 	. 
	nop			;4141	00 	. 
	nop			;4142	00 	. 
	nop			;4143	00 	. 
	nop			;4144	00 	. 
	nop			;4145	00 	. 
	nop			;4146	00 	. 
	nop			;4147	00 	. 
	nop			;4148	00 	. 
	nop			;4149	00 	. 
	nop			;414a	00 	. 
	nop			;414b	00 	. 
	nop			;414c	00 	. 
	nop			;414d	00 	. 
	nop			;414e	00 	. 
	nop			;414f	00 	. 
	nop			;4150	00 	. 
	nop			;4151	00 	. 
	nop			;4152	00 	. 
	nop			;4153	00 	. 
	nop			;4154	00 	. 
	nop			;4155	00 	. 
	nop			;4156	00 	. 
	nop			;4157	00 	. 
	nop			;4158	00 	. 
	nop			;4159	00 	. 
	nop			;415a	00 	. 
	nop			;415b	00 	. 
	nop			;415c	00 	. 
	nop			;415d	00 	. 
	nop			;415e	00 	. 
	nop			;415f	00 	. 
	nop			;4160	00 	. 
	nop			;4161	00 	. 
	nop			;4162	00 	. 
	nop			;4163	00 	. 
	nop			;4164	00 	. 
	nop			;4165	00 	. 
	nop			;4166	00 	. 
	nop			;4167	00 	. 
	nop			;4168	00 	. 
	nop			;4169	00 	. 
	nop			;416a	00 	. 
	nop			;416b	00 	. 
	nop			;416c	00 	. 
	nop			;416d	00 	. 
	nop			;416e	00 	. 
	nop			;416f	00 	. 
	nop			;4170	00 	. 
	nop			;4171	00 	. 
	nop			;4172	00 	. 
	nop			;4173	00 	. 
	nop			;4174	00 	. 
	nop			;4175	00 	. 
	nop			;4176	00 	. 
	nop			;4177	00 	. 
	nop			;4178	00 	. 
	nop			;4179	00 	. 
	nop			;417a	00 	. 
	nop			;417b	00 	. 
	nop			;417c	00 	. 
	nop			;417d	00 	. 
	nop			;417e	00 	. 
	nop			;417f	00 	. 
	nop			;4180	00 	. 
	nop			;4181	00 	. 
	nop			;4182	00 	. 
	nop			;4183	00 	. 
	nop			;4184	00 	. 
	nop			;4185	00 	. 
	nop			;4186	00 	. 
	nop			;4187	00 	. 
	nop			;4188	00 	. 
	nop			;4189	00 	. 
	nop			;418a	00 	. 
	nop			;418b	00 	. 
	nop			;418c	00 	. 
	nop			;418d	00 	. 
	nop			;418e	00 	. 
	nop			;418f	00 	. 
	nop			;4190	00 	. 
	nop			;4191	00 	. 
	nop			;4192	00 	. 
	nop			;4193	00 	. 
	nop			;4194	00 	. 
	nop			;4195	00 	. 
	nop			;4196	00 	. 
	nop			;4197	00 	. 
	nop			;4198	00 	. 
	nop			;4199	00 	. 
	nop			;419a	00 	. 
	nop			;419b	00 	. 
	nop			;419c	00 	. 
	nop			;419d	00 	. 
	nop			;419e	00 	. 
	nop			;419f	00 	. 
	nop			;41a0	00 	. 
	nop			;41a1	00 	. 
	nop			;41a2	00 	. 
	nop			;41a3	00 	. 
	nop			;41a4	00 	. 
	nop			;41a5	00 	. 
	nop			;41a6	00 	. 
	nop			;41a7	00 	. 
	nop			;41a8	00 	. 
	nop			;41a9	00 	. 
	nop			;41aa	00 	. 
	nop			;41ab	00 	. 
	nop			;41ac	00 	. 
	nop			;41ad	00 	. 
	nop			;41ae	00 	. 
	nop			;41af	00 	. 
	nop			;41b0	00 	. 
	nop			;41b1	00 	. 
	nop			;41b2	00 	. 
	nop			;41b3	00 	. 
	nop			;41b4	00 	. 
	nop			;41b5	00 	. 
	nop			;41b6	00 	. 
	nop			;41b7	00 	. 
	nop			;41b8	00 	. 
	nop			;41b9	00 	. 
	nop			;41ba	00 	. 
	nop			;41bb	00 	. 
	nop			;41bc	00 	. 
	nop			;41bd	00 	. 
	nop			;41be	00 	. 
	nop			;41bf	00 	. 
	nop			;41c0	00 	. 
	nop			;41c1	00 	. 
	nop			;41c2	00 	. 
	nop			;41c3	00 	. 
	nop			;41c4	00 	. 
	nop			;41c5	00 	. 
	nop			;41c6	00 	. 
	nop			;41c7	00 	. 
	nop			;41c8	00 	. 
	nop			;41c9	00 	. 
	nop			;41ca	00 	. 
	nop			;41cb	00 	. 
	nop			;41cc	00 	. 
	nop			;41cd	00 	. 
	nop			;41ce	00 	. 
	nop			;41cf	00 	. 
	nop			;41d0	00 	. 
	nop			;41d1	00 	. 
	nop			;41d2	00 	. 
	nop			;41d3	00 	. 
	nop			;41d4	00 	. 
	nop			;41d5	00 	. 
	nop			;41d6	00 	. 
	nop			;41d7	00 	. 
	nop			;41d8	00 	. 
	nop			;41d9	00 	. 
	nop			;41da	00 	. 
	nop			;41db	00 	. 
	nop			;41dc	00 	. 
	nop			;41dd	00 	. 
	nop			;41de	00 	. 
	nop			;41df	00 	. 
	nop			;41e0	00 	. 
	nop			;41e1	00 	. 
	nop			;41e2	00 	. 
	nop			;41e3	00 	. 
	nop			;41e4	00 	. 
	nop			;41e5	00 	. 
	nop			;41e6	00 	. 
	nop			;41e7	00 	. 
	nop			;41e8	00 	. 
	nop			;41e9	00 	. 
	nop			;41ea	00 	. 
	nop			;41eb	00 	. 
	nop			;41ec	00 	. 
	nop			;41ed	00 	. 
	nop			;41ee	00 	. 
	nop			;41ef	00 	. 
	nop			;41f0	00 	. 
	nop			;41f1	00 	. 
	nop			;41f2	00 	. 
	nop			;41f3	00 	. 
	nop			;41f4	00 	. 
	nop			;41f5	00 	. 
	nop			;41f6	00 	. 
	nop			;41f7	00 	. 
	nop			;41f8	00 	. 
	nop			;41f9	00 	. 
	nop			;41fa	00 	. 
	nop			;41fb	00 	. 
	nop			;41fc	00 	. 
	nop			;41fd	00 	. 
	nop			;41fe	00 	. 
	nop			;41ff	00 	. 
	nop			;4200	00 	. 
	nop			;4201	00 	. 
	nop			;4202	00 	. 
	nop			;4203	00 	. 
	nop			;4204	00 	. 
	nop			;4205	00 	. 
	nop			;4206	00 	. 
	nop			;4207	00 	. 
	nop			;4208	00 	. 
	nop			;4209	00 	. 
	nop			;420a	00 	. 
	nop			;420b	00 	. 
	nop			;420c	00 	. 
	nop			;420d	00 	. 
	nop			;420e	00 	. 
	nop			;420f	00 	. 
	nop			;4210	00 	. 
	nop			;4211	00 	. 
	nop			;4212	00 	. 
	nop			;4213	00 	. 
	nop			;4214	00 	. 
	nop			;4215	00 	. 
	nop			;4216	00 	. 
	nop			;4217	00 	. 
	nop			;4218	00 	. 
	nop			;4219	00 	. 
	nop			;421a	00 	. 
	nop			;421b	00 	. 
	nop			;421c	00 	. 
	nop			;421d	00 	. 
	nop			;421e	00 	. 
	nop			;421f	00 	. 
	nop			;4220	00 	. 
	nop			;4221	00 	. 
	nop			;4222	00 	. 
	nop			;4223	00 	. 
	nop			;4224	00 	. 
	nop			;4225	00 	. 
	nop			;4226	00 	. 
	nop			;4227	00 	. 
	nop			;4228	00 	. 
	nop			;4229	00 	. 
	nop			;422a	00 	. 
	nop			;422b	00 	. 
	nop			;422c	00 	. 
	nop			;422d	00 	. 
	nop			;422e	00 	. 
	nop			;422f	00 	. 
	nop			;4230	00 	. 
	nop			;4231	00 	. 
	nop			;4232	00 	. 
	nop			;4233	00 	. 
	nop			;4234	00 	. 
	nop			;4235	00 	. 
	nop			;4236	00 	. 
	nop			;4237	00 	. 
	nop			;4238	00 	. 
	nop			;4239	00 	. 
	nop			;423a	00 	. 
	nop			;423b	00 	. 
	nop			;423c	00 	. 
	nop			;423d	00 	. 
	nop			;423e	00 	. 
	nop			;423f	00 	. 
	nop			;4240	00 	. 
	nop			;4241	00 	. 
	nop			;4242	00 	. 
	nop			;4243	00 	. 
	nop			;4244	00 	. 
	nop			;4245	00 	. 
	nop			;4246	00 	. 
	nop			;4247	00 	. 
	nop			;4248	00 	. 
	nop			;4249	00 	. 
	nop			;424a	00 	. 
	nop			;424b	00 	. 
	nop			;424c	00 	. 
	nop			;424d	00 	. 
	nop			;424e	00 	. 
	nop			;424f	00 	. 
	nop			;4250	00 	. 
	nop			;4251	00 	. 
	nop			;4252	00 	. 
	nop			;4253	00 	. 
	nop			;4254	00 	. 
	nop			;4255	00 	. 
	nop			;4256	00 	. 
	nop			;4257	00 	. 
	nop			;4258	00 	. 
	nop			;4259	00 	. 
	nop			;425a	00 	. 
	nop			;425b	00 	. 
	nop			;425c	00 	. 
	nop			;425d	00 	. 
	nop			;425e	00 	. 
	nop			;425f	00 	. 
	nop			;4260	00 	. 
	nop			;4261	00 	. 
	nop			;4262	00 	. 
	nop			;4263	00 	. 
	nop			;4264	00 	. 
	nop			;4265	00 	. 
	nop			;4266	00 	. 
	nop			;4267	00 	. 
	nop			;4268	00 	. 
	nop			;4269	00 	. 
	nop			;426a	00 	. 
	nop			;426b	00 	. 
	nop			;426c	00 	. 
	nop			;426d	00 	. 
	nop			;426e	00 	. 
	nop			;426f	00 	. 
	nop			;4270	00 	. 
	nop			;4271	00 	. 
	nop			;4272	00 	. 
	nop			;4273	00 	. 
	nop			;4274	00 	. 
	nop			;4275	00 	. 
	nop			;4276	00 	. 
	nop			;4277	00 	. 
	nop			;4278	00 	. 
	nop			;4279	00 	. 
	nop			;427a	00 	. 
	nop			;427b	00 	. 
	nop			;427c	00 	. 
	nop			;427d	00 	. 
	nop			;427e	00 	. 
	nop			;427f	00 	. 
	nop			;4280	00 	. 
	nop			;4281	00 	. 
	nop			;4282	00 	. 
	nop			;4283	00 	. 
	nop			;4284	00 	. 
	nop			;4285	00 	. 
	nop			;4286	00 	. 
	nop			;4287	00 	. 
	nop			;4288	00 	. 
	nop			;4289	00 	. 
	nop			;428a	00 	. 
	nop			;428b	00 	. 
	nop			;428c	00 	. 
	nop			;428d	00 	. 
	nop			;428e	00 	. 
	nop			;428f	00 	. 
	nop			;4290	00 	. 
	nop			;4291	00 	. 
	nop			;4292	00 	. 
	nop			;4293	00 	. 
	nop			;4294	00 	. 
	nop			;4295	00 	. 
	nop			;4296	00 	. 
	nop			;4297	00 	. 
	nop			;4298	00 	. 
	nop			;4299	00 	. 
	nop			;429a	00 	. 
	nop			;429b	00 	. 
	nop			;429c	00 	. 
	nop			;429d	00 	. 
	nop			;429e	00 	. 
	nop			;429f	00 	. 
	nop			;42a0	00 	. 
	nop			;42a1	00 	. 
	nop			;42a2	00 	. 
	nop			;42a3	00 	. 
	nop			;42a4	00 	. 
	nop			;42a5	00 	. 
	nop			;42a6	00 	. 
	nop			;42a7	00 	. 
	nop			;42a8	00 	. 
	nop			;42a9	00 	. 
	nop			;42aa	00 	. 
	nop			;42ab	00 	. 
	nop			;42ac	00 	. 
	nop			;42ad	00 	. 
	nop			;42ae	00 	. 
	nop			;42af	00 	. 
	nop			;42b0	00 	. 
	nop			;42b1	00 	. 
	nop			;42b2	00 	. 
	nop			;42b3	00 	. 
	nop			;42b4	00 	. 
	nop			;42b5	00 	. 
	nop			;42b6	00 	. 
	nop			;42b7	00 	. 
	nop			;42b8	00 	. 
	nop			;42b9	00 	. 
	nop			;42ba	00 	. 
	nop			;42bb	00 	. 
	nop			;42bc	00 	. 
	nop			;42bd	00 	. 
	nop			;42be	00 	. 
	nop			;42bf	00 	. 
	nop			;42c0	00 	. 
	nop			;42c1	00 	. 
	nop			;42c2	00 	. 
	nop			;42c3	00 	. 
	nop			;42c4	00 	. 
	nop			;42c5	00 	. 
	nop			;42c6	00 	. 
	nop			;42c7	00 	. 
	nop			;42c8	00 	. 
	nop			;42c9	00 	. 
	nop			;42ca	00 	. 
	nop			;42cb	00 	. 
	nop			;42cc	00 	. 
	nop			;42cd	00 	. 
	nop			;42ce	00 	. 
	nop			;42cf	00 	. 
	nop			;42d0	00 	. 
	nop			;42d1	00 	. 
	nop			;42d2	00 	. 
	nop			;42d3	00 	. 
	nop			;42d4	00 	. 
	nop			;42d5	00 	. 
	nop			;42d6	00 	. 
	nop			;42d7	00 	. 
	nop			;42d8	00 	. 
	nop			;42d9	00 	. 
	nop			;42da	00 	. 
	nop			;42db	00 	. 
	nop			;42dc	00 	. 
	nop			;42dd	00 	. 
	nop			;42de	00 	. 
	nop			;42df	00 	. 
	nop			;42e0	00 	. 
	nop			;42e1	00 	. 
	nop			;42e2	00 	. 
	nop			;42e3	00 	. 
	nop			;42e4	00 	. 
	nop			;42e5	00 	. 
	nop			;42e6	00 	. 
	nop			;42e7	00 	. 
	nop			;42e8	00 	. 
	nop			;42e9	00 	. 
	nop			;42ea	00 	. 
	nop			;42eb	00 	. 
	nop			;42ec	00 	. 
	nop			;42ed	00 	. 
	nop			;42ee	00 	. 
	nop			;42ef	00 	. 
	nop			;42f0	00 	. 
	nop			;42f1	00 	. 
	nop			;42f2	00 	. 
	nop			;42f3	00 	. 
	nop			;42f4	00 	. 
	nop			;42f5	00 	. 
	nop			;42f6	00 	. 
	nop			;42f7	00 	. 
	nop			;42f8	00 	. 
	nop			;42f9	00 	. 
	nop			;42fa	00 	. 
	nop			;42fb	00 	. 
	nop			;42fc	00 	. 
	nop			;42fd	00 	. 
	nop			;42fe	00 	. 
	nop			;42ff	00 	. 
	nop			;4300	00 	. 
	nop			;4301	00 	. 
	nop			;4302	00 	. 
	nop			;4303	00 	. 
	nop			;4304	00 	. 
	nop			;4305	00 	. 
	nop			;4306	00 	. 
	nop			;4307	00 	. 
	nop			;4308	00 	. 
	nop			;4309	00 	. 
	nop			;430a	00 	. 
	nop			;430b	00 	. 
	nop			;430c	00 	. 
	nop			;430d	00 	. 
	nop			;430e	00 	. 
	nop			;430f	00 	. 
	nop			;4310	00 	. 
	nop			;4311	00 	. 
	nop			;4312	00 	. 
	nop			;4313	00 	. 
	nop			;4314	00 	. 
	nop			;4315	00 	. 
	nop			;4316	00 	. 
	nop			;4317	00 	. 
	nop			;4318	00 	. 
	nop			;4319	00 	. 
	nop			;431a	00 	. 
	nop			;431b	00 	. 
	nop			;431c	00 	. 
	nop			;431d	00 	. 
	nop			;431e	00 	. 
	nop			;431f	00 	. 
	nop			;4320	00 	. 
	nop			;4321	00 	. 
	nop			;4322	00 	. 
	nop			;4323	00 	. 
	nop			;4324	00 	. 
	nop			;4325	00 	. 
	nop			;4326	00 	. 
	nop			;4327	00 	. 
	nop			;4328	00 	. 
	nop			;4329	00 	. 
	nop			;432a	00 	. 
	nop			;432b	00 	. 
	nop			;432c	00 	. 
	nop			;432d	00 	. 
	nop			;432e	00 	. 
	nop			;432f	00 	. 
	nop			;4330	00 	. 
	nop			;4331	00 	. 
	nop			;4332	00 	. 
	nop			;4333	00 	. 
	nop			;4334	00 	. 
	nop			;4335	00 	. 
	nop			;4336	00 	. 
	nop			;4337	00 	. 
	nop			;4338	00 	. 
	nop			;4339	00 	. 
	nop			;433a	00 	. 
	nop			;433b	00 	. 
	nop			;433c	00 	. 
	nop			;433d	00 	. 
	nop			;433e	00 	. 
	nop			;433f	00 	. 
	nop			;4340	00 	. 
	nop			;4341	00 	. 
	nop			;4342	00 	. 
	nop			;4343	00 	. 
	nop			;4344	00 	. 
	nop			;4345	00 	. 
	nop			;4346	00 	. 
	nop			;4347	00 	. 
	nop			;4348	00 	. 
	nop			;4349	00 	. 
	nop			;434a	00 	. 
	nop			;434b	00 	. 
	nop			;434c	00 	. 
	nop			;434d	00 	. 
	nop			;434e	00 	. 
	nop			;434f	00 	. 
	nop			;4350	00 	. 
	nop			;4351	00 	. 
	nop			;4352	00 	. 
	nop			;4353	00 	. 
	nop			;4354	00 	. 
	nop			;4355	00 	. 
	nop			;4356	00 	. 
	nop			;4357	00 	. 
	nop			;4358	00 	. 
	nop			;4359	00 	. 
	nop			;435a	00 	. 
	nop			;435b	00 	. 
	nop			;435c	00 	. 
	nop			;435d	00 	. 
	nop			;435e	00 	. 
	nop			;435f	00 	. 
	nop			;4360	00 	. 
	nop			;4361	00 	. 
	nop			;4362	00 	. 
	nop			;4363	00 	. 
	nop			;4364	00 	. 
	nop			;4365	00 	. 
	nop			;4366	00 	. 
	nop			;4367	00 	. 
	nop			;4368	00 	. 
	nop			;4369	00 	. 
	nop			;436a	00 	. 
	nop			;436b	00 	. 
	nop			;436c	00 	. 
	nop			;436d	00 	. 
	nop			;436e	00 	. 
	nop			;436f	00 	. 
	nop			;4370	00 	. 
	nop			;4371	00 	. 
	nop			;4372	00 	. 
	nop			;4373	00 	. 
	nop			;4374	00 	. 
	nop			;4375	00 	. 
	nop			;4376	00 	. 
	nop			;4377	00 	. 
	nop			;4378	00 	. 
	nop			;4379	00 	. 
	nop			;437a	00 	. 
	nop			;437b	00 	. 
	nop			;437c	00 	. 
	nop			;437d	00 	. 
	nop			;437e	00 	. 
	nop			;437f	00 	. 
	nop			;4380	00 	. 
	nop			;4381	00 	. 
	nop			;4382	00 	. 
	nop			;4383	00 	. 
	nop			;4384	00 	. 
	nop			;4385	00 	. 
	nop			;4386	00 	. 
	nop			;4387	00 	. 
	nop			;4388	00 	. 
	nop			;4389	00 	. 
	nop			;438a	00 	. 
	nop			;438b	00 	. 
	nop			;438c	00 	. 
	nop			;438d	00 	. 
	nop			;438e	00 	. 
	nop			;438f	00 	. 
	nop			;4390	00 	. 
	nop			;4391	00 	. 
	nop			;4392	00 	. 
	nop			;4393	00 	. 
	nop			;4394	00 	. 
	nop			;4395	00 	. 
	nop			;4396	00 	. 
	nop			;4397	00 	. 
	nop			;4398	00 	. 
	nop			;4399	00 	. 
	nop			;439a	00 	. 
	nop			;439b	00 	. 
	nop			;439c	00 	. 
	nop			;439d	00 	. 
	nop			;439e	00 	. 
	nop			;439f	00 	. 
	nop			;43a0	00 	. 
	nop			;43a1	00 	. 
	nop			;43a2	00 	. 
	nop			;43a3	00 	. 
	nop			;43a4	00 	. 
	nop			;43a5	00 	. 
	nop			;43a6	00 	. 
	nop			;43a7	00 	. 
	nop			;43a8	00 	. 
	nop			;43a9	00 	. 
	nop			;43aa	00 	. 
	nop			;43ab	00 	. 
	nop			;43ac	00 	. 
	nop			;43ad	00 	. 
	nop			;43ae	00 	. 
	nop			;43af	00 	. 
	nop			;43b0	00 	. 
	nop			;43b1	00 	. 
	nop			;43b2	00 	. 
	nop			;43b3	00 	. 
	nop			;43b4	00 	. 
	nop			;43b5	00 	. 
	nop			;43b6	00 	. 
	nop			;43b7	00 	. 
	nop			;43b8	00 	. 
	nop			;43b9	00 	. 
	nop			;43ba	00 	. 
	nop			;43bb	00 	. 
	nop			;43bc	00 	. 
	nop			;43bd	00 	. 
	nop			;43be	00 	. 
	nop			;43bf	00 	. 
	nop			;43c0	00 	. 
	nop			;43c1	00 	. 
	nop			;43c2	00 	. 
	nop			;43c3	00 	. 
	nop			;43c4	00 	. 
	nop			;43c5	00 	. 
	nop			;43c6	00 	. 
	nop			;43c7	00 	. 
	nop			;43c8	00 	. 
	nop			;43c9	00 	. 
	nop			;43ca	00 	. 
	nop			;43cb	00 	. 
	nop			;43cc	00 	. 
	nop			;43cd	00 	. 
	nop			;43ce	00 	. 
	nop			;43cf	00 	. 
	nop			;43d0	00 	. 
	nop			;43d1	00 	. 
	nop			;43d2	00 	. 
	nop			;43d3	00 	. 
	nop			;43d4	00 	. 
	nop			;43d5	00 	. 
	nop			;43d6	00 	. 
	nop			;43d7	00 	. 
	nop			;43d8	00 	. 
	nop			;43d9	00 	. 
	nop			;43da	00 	. 
	nop			;43db	00 	. 
	nop			;43dc	00 	. 
	nop			;43dd	00 	. 
	nop			;43de	00 	. 
	nop			;43df	00 	. 
	nop			;43e0	00 	. 
	nop			;43e1	00 	. 
	nop			;43e2	00 	. 
	nop			;43e3	00 	. 
	nop			;43e4	00 	. 
	nop			;43e5	00 	. 
	nop			;43e6	00 	. 
	nop			;43e7	00 	. 
	nop			;43e8	00 	. 
	nop			;43e9	00 	. 
	nop			;43ea	00 	. 
	nop			;43eb	00 	. 
	nop			;43ec	00 	. 
	nop			;43ed	00 	. 
	nop			;43ee	00 	. 
	nop			;43ef	00 	. 
	nop			;43f0	00 	. 
	nop			;43f1	00 	. 
	nop			;43f2	00 	. 
	nop			;43f3	00 	. 
	nop			;43f4	00 	. 
	nop			;43f5	00 	. 
	nop			;43f6	00 	. 
	nop			;43f7	00 	. 
	nop			;43f8	00 	. 
	nop			;43f9	00 	. 
	nop			;43fa	00 	. 
	nop			;43fb	00 	. 
	nop			;43fc	00 	. 
	nop			;43fd	00 	. 
	nop			;43fe	00 	. 
	nop			;43ff	00 	. 
	nop			;4400	00 	. 
	nop			;4401	00 	. 
	nop			;4402	00 	. 
	nop			;4403	00 	. 
	nop			;4404	00 	. 
	nop			;4405	00 	. 
	nop			;4406	00 	. 
	nop			;4407	00 	. 
	nop			;4408	00 	. 
	nop			;4409	00 	. 
	nop			;440a	00 	. 
	nop			;440b	00 	. 
	nop			;440c	00 	. 
	nop			;440d	00 	. 
	nop			;440e	00 	. 
	nop			;440f	00 	. 
	nop			;4410	00 	. 
	nop			;4411	00 	. 
	nop			;4412	00 	. 
	nop			;4413	00 	. 
	nop			;4414	00 	. 
	nop			;4415	00 	. 
	nop			;4416	00 	. 
	nop			;4417	00 	. 
	nop			;4418	00 	. 
	nop			;4419	00 	. 
	nop			;441a	00 	. 
	nop			;441b	00 	. 
	nop			;441c	00 	. 
	nop			;441d	00 	. 
	nop			;441e	00 	. 
	nop			;441f	00 	. 
	nop			;4420	00 	. 
	nop			;4421	00 	. 
	nop			;4422	00 	. 
	nop			;4423	00 	. 
	nop			;4424	00 	. 
	nop			;4425	00 	. 
	nop			;4426	00 	. 
	nop			;4427	00 	. 
	nop			;4428	00 	. 
	nop			;4429	00 	. 
	nop			;442a	00 	. 
	nop			;442b	00 	. 
	nop			;442c	00 	. 
	nop			;442d	00 	. 
	nop			;442e	00 	. 
	nop			;442f	00 	. 
	nop			;4430	00 	. 
	nop			;4431	00 	. 
	nop			;4432	00 	. 
	nop			;4433	00 	. 
	nop			;4434	00 	. 
	nop			;4435	00 	. 
	nop			;4436	00 	. 
	nop			;4437	00 	. 
	nop			;4438	00 	. 
	nop			;4439	00 	. 
	nop			;443a	00 	. 
	nop			;443b	00 	. 
	nop			;443c	00 	. 
	nop			;443d	00 	. 
	nop			;443e	00 	. 
	nop			;443f	00 	. 
	nop			;4440	00 	. 
	nop			;4441	00 	. 
	nop			;4442	00 	. 
	nop			;4443	00 	. 
	nop			;4444	00 	. 
	nop			;4445	00 	. 
	nop			;4446	00 	. 
	nop			;4447	00 	. 
	nop			;4448	00 	. 
	nop			;4449	00 	. 
	nop			;444a	00 	. 
	nop			;444b	00 	. 
	nop			;444c	00 	. 
	nop			;444d	00 	. 
	nop			;444e	00 	. 
	nop			;444f	00 	. 
	nop			;4450	00 	. 
	nop			;4451	00 	. 
	nop			;4452	00 	. 
	nop			;4453	00 	. 
	nop			;4454	00 	. 
	nop			;4455	00 	. 
	nop			;4456	00 	. 
	nop			;4457	00 	. 
	nop			;4458	00 	. 
	nop			;4459	00 	. 
	nop			;445a	00 	. 
	nop			;445b	00 	. 
	nop			;445c	00 	. 
	nop			;445d	00 	. 
	nop			;445e	00 	. 
	nop			;445f	00 	. 
	nop			;4460	00 	. 
	nop			;4461	00 	. 
	nop			;4462	00 	. 
	nop			;4463	00 	. 
	nop			;4464	00 	. 
	nop			;4465	00 	. 
	nop			;4466	00 	. 
	nop			;4467	00 	. 
	nop			;4468	00 	. 
	nop			;4469	00 	. 
	nop			;446a	00 	. 
	nop			;446b	00 	. 
	nop			;446c	00 	. 
	nop			;446d	00 	. 
	nop			;446e	00 	. 
	nop			;446f	00 	. 
	nop			;4470	00 	. 
	nop			;4471	00 	. 
	nop			;4472	00 	. 
	nop			;4473	00 	. 
	nop			;4474	00 	. 
	nop			;4475	00 	. 
	nop			;4476	00 	. 
	nop			;4477	00 	. 
	nop			;4478	00 	. 
	nop			;4479	00 	. 
	nop			;447a	00 	. 
	nop			;447b	00 	. 
	nop			;447c	00 	. 
	nop			;447d	00 	. 
	nop			;447e	00 	. 
	nop			;447f	00 	. 
	nop			;4480	00 	. 
	nop			;4481	00 	. 
	nop			;4482	00 	. 
	nop			;4483	00 	. 
	nop			;4484	00 	. 
	nop			;4485	00 	. 
	nop			;4486	00 	. 
	nop			;4487	00 	. 
	nop			;4488	00 	. 
	nop			;4489	00 	. 
	nop			;448a	00 	. 
	nop			;448b	00 	. 
	nop			;448c	00 	. 
	nop			;448d	00 	. 
	nop			;448e	00 	. 
	nop			;448f	00 	. 
	nop			;4490	00 	. 
	nop			;4491	00 	. 
	nop			;4492	00 	. 
	nop			;4493	00 	. 
	nop			;4494	00 	. 
	nop			;4495	00 	. 
	nop			;4496	00 	. 
	nop			;4497	00 	. 
	nop			;4498	00 	. 
	nop			;4499	00 	. 
	nop			;449a	00 	. 
	nop			;449b	00 	. 
	nop			;449c	00 	. 
	nop			;449d	00 	. 
	nop			;449e	00 	. 
	nop			;449f	00 	. 
	nop			;44a0	00 	. 
	nop			;44a1	00 	. 
	nop			;44a2	00 	. 
	nop			;44a3	00 	. 
	nop			;44a4	00 	. 
	nop			;44a5	00 	. 
	nop			;44a6	00 	. 
	nop			;44a7	00 	. 
	nop			;44a8	00 	. 
	nop			;44a9	00 	. 
	nop			;44aa	00 	. 
	nop			;44ab	00 	. 
	nop			;44ac	00 	. 
	nop			;44ad	00 	. 
	nop			;44ae	00 	. 
	nop			;44af	00 	. 
	nop			;44b0	00 	. 
	nop			;44b1	00 	. 
	nop			;44b2	00 	. 
	nop			;44b3	00 	. 
	nop			;44b4	00 	. 
	nop			;44b5	00 	. 
	nop			;44b6	00 	. 
	nop			;44b7	00 	. 
	nop			;44b8	00 	. 
	nop			;44b9	00 	. 
	nop			;44ba	00 	. 
	nop			;44bb	00 	. 
	nop			;44bc	00 	. 
	nop			;44bd	00 	. 
	nop			;44be	00 	. 
	nop			;44bf	00 	. 
	nop			;44c0	00 	. 
	nop			;44c1	00 	. 
	nop			;44c2	00 	. 
	nop			;44c3	00 	. 
	nop			;44c4	00 	. 
	nop			;44c5	00 	. 
	nop			;44c6	00 	. 
	nop			;44c7	00 	. 
	nop			;44c8	00 	. 
	nop			;44c9	00 	. 
	nop			;44ca	00 	. 
	nop			;44cb	00 	. 
	nop			;44cc	00 	. 
	nop			;44cd	00 	. 
	nop			;44ce	00 	. 
	nop			;44cf	00 	. 
	nop			;44d0	00 	. 
	nop			;44d1	00 	. 
	nop			;44d2	00 	. 
	nop			;44d3	00 	. 
	nop			;44d4	00 	. 
	nop			;44d5	00 	. 
	nop			;44d6	00 	. 
	nop			;44d7	00 	. 
	nop			;44d8	00 	. 
	nop			;44d9	00 	. 
	nop			;44da	00 	. 
	nop			;44db	00 	. 
	nop			;44dc	00 	. 
	nop			;44dd	00 	. 
	nop			;44de	00 	. 
	nop			;44df	00 	. 
	nop			;44e0	00 	. 
	nop			;44e1	00 	. 
	nop			;44e2	00 	. 
	nop			;44e3	00 	. 
	nop			;44e4	00 	. 
	nop			;44e5	00 	. 
	nop			;44e6	00 	. 
	nop			;44e7	00 	. 
	nop			;44e8	00 	. 
	nop			;44e9	00 	. 
	nop			;44ea	00 	. 
	nop			;44eb	00 	. 
	nop			;44ec	00 	. 
	nop			;44ed	00 	. 
	nop			;44ee	00 	. 
	nop			;44ef	00 	. 
	nop			;44f0	00 	. 
	nop			;44f1	00 	. 
	nop			;44f2	00 	. 
	nop			;44f3	00 	. 
	nop			;44f4	00 	. 
	nop			;44f5	00 	. 
	nop			;44f6	00 	. 
	nop			;44f7	00 	. 
	nop			;44f8	00 	. 
	nop			;44f9	00 	. 
	nop			;44fa	00 	. 
	nop			;44fb	00 	. 
	nop			;44fc	00 	. 
	nop			;44fd	00 	. 
	nop			;44fe	00 	. 
	nop			;44ff	00 	. 
	nop			;4500	00 	. 
	nop			;4501	00 	. 
	nop			;4502	00 	. 
	nop			;4503	00 	. 
	nop			;4504	00 	. 
	nop			;4505	00 	. 
	nop			;4506	00 	. 
	nop			;4507	00 	. 
	nop			;4508	00 	. 
	nop			;4509	00 	. 
	nop			;450a	00 	. 
	nop			;450b	00 	. 
	nop			;450c	00 	. 
	nop			;450d	00 	. 
	nop			;450e	00 	. 
	nop			;450f	00 	. 
	nop			;4510	00 	. 
	nop			;4511	00 	. 
	nop			;4512	00 	. 
	nop			;4513	00 	. 
	nop			;4514	00 	. 
	nop			;4515	00 	. 
	nop			;4516	00 	. 
	nop			;4517	00 	. 
	nop			;4518	00 	. 
	nop			;4519	00 	. 
	nop			;451a	00 	. 
	nop			;451b	00 	. 
	nop			;451c	00 	. 
	nop			;451d	00 	. 
	nop			;451e	00 	. 
	nop			;451f	00 	. 
	nop			;4520	00 	. 
	nop			;4521	00 	. 
	nop			;4522	00 	. 
	nop			;4523	00 	. 
	nop			;4524	00 	. 
	nop			;4525	00 	. 
	nop			;4526	00 	. 
	nop			;4527	00 	. 
	nop			;4528	00 	. 
	nop			;4529	00 	. 
	nop			;452a	00 	. 
	nop			;452b	00 	. 
	nop			;452c	00 	. 
	nop			;452d	00 	. 
	nop			;452e	00 	. 
	nop			;452f	00 	. 
	nop			;4530	00 	. 
	nop			;4531	00 	. 
	nop			;4532	00 	. 
	nop			;4533	00 	. 
	nop			;4534	00 	. 
	nop			;4535	00 	. 
	nop			;4536	00 	. 
	nop			;4537	00 	. 
	nop			;4538	00 	. 
	nop			;4539	00 	. 
	nop			;453a	00 	. 
	nop			;453b	00 	. 
	nop			;453c	00 	. 
	nop			;453d	00 	. 
	nop			;453e	00 	. 
	nop			;453f	00 	. 
	nop			;4540	00 	. 
	nop			;4541	00 	. 
	nop			;4542	00 	. 
	nop			;4543	00 	. 
	nop			;4544	00 	. 
	nop			;4545	00 	. 
	nop			;4546	00 	. 
	nop			;4547	00 	. 
	nop			;4548	00 	. 
	nop			;4549	00 	. 
	nop			;454a	00 	. 
	nop			;454b	00 	. 
	nop			;454c	00 	. 
	nop			;454d	00 	. 
	nop			;454e	00 	. 
	nop			;454f	00 	. 
	nop			;4550	00 	. 
	nop			;4551	00 	. 
	nop			;4552	00 	. 
	nop			;4553	00 	. 
	nop			;4554	00 	. 
	nop			;4555	00 	. 
	nop			;4556	00 	. 
	nop			;4557	00 	. 
	nop			;4558	00 	. 
	nop			;4559	00 	. 
	nop			;455a	00 	. 
	nop			;455b	00 	. 
	nop			;455c	00 	. 
	nop			;455d	00 	. 
	nop			;455e	00 	. 
	nop			;455f	00 	. 
	nop			;4560	00 	. 
	nop			;4561	00 	. 
	nop			;4562	00 	. 
	nop			;4563	00 	. 
	nop			;4564	00 	. 
	nop			;4565	00 	. 
	nop			;4566	00 	. 
	nop			;4567	00 	. 
	nop			;4568	00 	. 
	nop			;4569	00 	. 
	nop			;456a	00 	. 
	nop			;456b	00 	. 
	nop			;456c	00 	. 
	nop			;456d	00 	. 
	nop			;456e	00 	. 
	nop			;456f	00 	. 
	nop			;4570	00 	. 
	nop			;4571	00 	. 
	nop			;4572	00 	. 
	nop			;4573	00 	. 
	nop			;4574	00 	. 
	nop			;4575	00 	. 
	nop			;4576	00 	. 
	nop			;4577	00 	. 
	nop			;4578	00 	. 
	nop			;4579	00 	. 
	nop			;457a	00 	. 
	nop			;457b	00 	. 
	nop			;457c	00 	. 
	nop			;457d	00 	. 
	nop			;457e	00 	. 
	nop			;457f	00 	. 
	nop			;4580	00 	. 
	nop			;4581	00 	. 
	nop			;4582	00 	. 
	nop			;4583	00 	. 
	nop			;4584	00 	. 
	nop			;4585	00 	. 
	nop			;4586	00 	. 
	nop			;4587	00 	. 
	nop			;4588	00 	. 
	nop			;4589	00 	. 
	nop			;458a	00 	. 
	nop			;458b	00 	. 
	nop			;458c	00 	. 
	nop			;458d	00 	. 
	nop			;458e	00 	. 
	nop			;458f	00 	. 
	nop			;4590	00 	. 
	nop			;4591	00 	. 
	nop			;4592	00 	. 
	nop			;4593	00 	. 
	nop			;4594	00 	. 
	nop			;4595	00 	. 
	nop			;4596	00 	. 
	nop			;4597	00 	. 
	nop			;4598	00 	. 
	nop			;4599	00 	. 
	nop			;459a	00 	. 
	nop			;459b	00 	. 
	nop			;459c	00 	. 
	nop			;459d	00 	. 
	nop			;459e	00 	. 
	nop			;459f	00 	. 
	nop			;45a0	00 	. 
	nop			;45a1	00 	. 
	nop			;45a2	00 	. 
	nop			;45a3	00 	. 
	nop			;45a4	00 	. 
	nop			;45a5	00 	. 
	nop			;45a6	00 	. 
	nop			;45a7	00 	. 
	nop			;45a8	00 	. 
	nop			;45a9	00 	. 
	nop			;45aa	00 	. 
	nop			;45ab	00 	. 
	nop			;45ac	00 	. 
	nop			;45ad	00 	. 
	nop			;45ae	00 	. 
	nop			;45af	00 	. 
	nop			;45b0	00 	. 
	nop			;45b1	00 	. 
	nop			;45b2	00 	. 
	nop			;45b3	00 	. 
	nop			;45b4	00 	. 
	nop			;45b5	00 	. 
	nop			;45b6	00 	. 
	nop			;45b7	00 	. 
	nop			;45b8	00 	. 
	nop			;45b9	00 	. 
	nop			;45ba	00 	. 
	nop			;45bb	00 	. 
	nop			;45bc	00 	. 
	nop			;45bd	00 	. 
	nop			;45be	00 	. 
	nop			;45bf	00 	. 
	nop			;45c0	00 	. 
	nop			;45c1	00 	. 
	nop			;45c2	00 	. 
	nop			;45c3	00 	. 
	nop			;45c4	00 	. 
	nop			;45c5	00 	. 
	nop			;45c6	00 	. 
	nop			;45c7	00 	. 
	nop			;45c8	00 	. 
	nop			;45c9	00 	. 
	nop			;45ca	00 	. 
	nop			;45cb	00 	. 
	nop			;45cc	00 	. 
	nop			;45cd	00 	. 
	nop			;45ce	00 	. 
	nop			;45cf	00 	. 
	nop			;45d0	00 	. 
	nop			;45d1	00 	. 
	nop			;45d2	00 	. 
	nop			;45d3	00 	. 
	nop			;45d4	00 	. 
	nop			;45d5	00 	. 
	nop			;45d6	00 	. 
	nop			;45d7	00 	. 
	nop			;45d8	00 	. 
	nop			;45d9	00 	. 
	nop			;45da	00 	. 
	nop			;45db	00 	. 
	nop			;45dc	00 	. 
	nop			;45dd	00 	. 
	nop			;45de	00 	. 
	nop			;45df	00 	. 
	nop			;45e0	00 	. 
	nop			;45e1	00 	. 
	nop			;45e2	00 	. 
	nop			;45e3	00 	. 
	nop			;45e4	00 	. 
	nop			;45e5	00 	. 
	nop			;45e6	00 	. 
	nop			;45e7	00 	. 
	nop			;45e8	00 	. 
	nop			;45e9	00 	. 
	nop			;45ea	00 	. 
	nop			;45eb	00 	. 
	nop			;45ec	00 	. 
	nop			;45ed	00 	. 
	nop			;45ee	00 	. 
	nop			;45ef	00 	. 
	nop			;45f0	00 	. 
	nop			;45f1	00 	. 
	nop			;45f2	00 	. 
	nop			;45f3	00 	. 
	nop			;45f4	00 	. 
	nop			;45f5	00 	. 
	nop			;45f6	00 	. 
	nop			;45f7	00 	. 
	nop			;45f8	00 	. 
	nop			;45f9	00 	. 
	nop			;45fa	00 	. 
	nop			;45fb	00 	. 
	nop			;45fc	00 	. 
	nop			;45fd	00 	. 
	nop			;45fe	00 	. 
	nop			;45ff	00 	. 
	nop			;4600	00 	. 
	nop			;4601	00 	. 
	nop			;4602	00 	. 
	nop			;4603	00 	. 
	nop			;4604	00 	. 
	nop			;4605	00 	. 
	nop			;4606	00 	. 
	nop			;4607	00 	. 
	nop			;4608	00 	. 
	nop			;4609	00 	. 
	nop			;460a	00 	. 
	nop			;460b	00 	. 
	nop			;460c	00 	. 
	nop			;460d	00 	. 
	nop			;460e	00 	. 
	nop			;460f	00 	. 
	nop			;4610	00 	. 
	nop			;4611	00 	. 
	nop			;4612	00 	. 
	nop			;4613	00 	. 
	nop			;4614	00 	. 
	nop			;4615	00 	. 
	nop			;4616	00 	. 
	nop			;4617	00 	. 
	nop			;4618	00 	. 
	nop			;4619	00 	. 
	nop			;461a	00 	. 
	nop			;461b	00 	. 
	nop			;461c	00 	. 
	nop			;461d	00 	. 
	nop			;461e	00 	. 
	nop			;461f	00 	. 
	nop			;4620	00 	. 
	nop			;4621	00 	. 
	nop			;4622	00 	. 
	nop			;4623	00 	. 
	nop			;4624	00 	. 
	nop			;4625	00 	. 
	nop			;4626	00 	. 
	nop			;4627	00 	. 
	nop			;4628	00 	. 
	nop			;4629	00 	. 
	nop			;462a	00 	. 
	nop			;462b	00 	. 
	nop			;462c	00 	. 
	nop			;462d	00 	. 
	nop			;462e	00 	. 
	nop			;462f	00 	. 
	nop			;4630	00 	. 
	nop			;4631	00 	. 
	nop			;4632	00 	. 
	nop			;4633	00 	. 
	nop			;4634	00 	. 
	nop			;4635	00 	. 
	nop			;4636	00 	. 
	nop			;4637	00 	. 
	nop			;4638	00 	. 
	nop			;4639	00 	. 
	nop			;463a	00 	. 
	nop			;463b	00 	. 
	nop			;463c	00 	. 
	nop			;463d	00 	. 
	nop			;463e	00 	. 
	nop			;463f	00 	. 
	nop			;4640	00 	. 
	nop			;4641	00 	. 
	nop			;4642	00 	. 
	nop			;4643	00 	. 
	nop			;4644	00 	. 
	nop			;4645	00 	. 
	nop			;4646	00 	. 
	nop			;4647	00 	. 
	nop			;4648	00 	. 
	nop			;4649	00 	. 
	nop			;464a	00 	. 
	nop			;464b	00 	. 
	nop			;464c	00 	. 
	nop			;464d	00 	. 
	nop			;464e	00 	. 
	nop			;464f	00 	. 
	nop			;4650	00 	. 
	nop			;4651	00 	. 
	nop			;4652	00 	. 
	nop			;4653	00 	. 
	nop			;4654	00 	. 
	nop			;4655	00 	. 
	nop			;4656	00 	. 
	nop			;4657	00 	. 
	nop			;4658	00 	. 
	nop			;4659	00 	. 
	nop			;465a	00 	. 
	nop			;465b	00 	. 
	nop			;465c	00 	. 
	nop			;465d	00 	. 
	nop			;465e	00 	. 
	nop			;465f	00 	. 
	nop			;4660	00 	. 
	nop			;4661	00 	. 
	nop			;4662	00 	. 
	nop			;4663	00 	. 
	nop			;4664	00 	. 
	nop			;4665	00 	. 
	nop			;4666	00 	. 
	nop			;4667	00 	. 
	nop			;4668	00 	. 
	nop			;4669	00 	. 
	nop			;466a	00 	. 
	nop			;466b	00 	. 
	nop			;466c	00 	. 
	nop			;466d	00 	. 
	nop			;466e	00 	. 
	nop			;466f	00 	. 
	nop			;4670	00 	. 
	nop			;4671	00 	. 
	nop			;4672	00 	. 
	nop			;4673	00 	. 
	nop			;4674	00 	. 
	nop			;4675	00 	. 
	nop			;4676	00 	. 
	nop			;4677	00 	. 
	nop			;4678	00 	. 
	nop			;4679	00 	. 
	nop			;467a	00 	. 
	nop			;467b	00 	. 
	nop			;467c	00 	. 
	nop			;467d	00 	. 
	nop			;467e	00 	. 
	nop			;467f	00 	. 
	nop			;4680	00 	. 
	nop			;4681	00 	. 
	nop			;4682	00 	. 
	nop			;4683	00 	. 
	nop			;4684	00 	. 
	nop			;4685	00 	. 
	nop			;4686	00 	. 
	nop			;4687	00 	. 
	nop			;4688	00 	. 
	nop			;4689	00 	. 
	nop			;468a	00 	. 
	nop			;468b	00 	. 
	nop			;468c	00 	. 
	nop			;468d	00 	. 
	nop			;468e	00 	. 
	nop			;468f	00 	. 
	nop			;4690	00 	. 
	nop			;4691	00 	. 
	nop			;4692	00 	. 
	nop			;4693	00 	. 
	nop			;4694	00 	. 
	nop			;4695	00 	. 
	nop			;4696	00 	. 
	nop			;4697	00 	. 
	nop			;4698	00 	. 
	nop			;4699	00 	. 
	nop			;469a	00 	. 
	nop			;469b	00 	. 
	nop			;469c	00 	. 
	nop			;469d	00 	. 
	nop			;469e	00 	. 
	nop			;469f	00 	. 
	nop			;46a0	00 	. 
	nop			;46a1	00 	. 
	nop			;46a2	00 	. 
	nop			;46a3	00 	. 
	nop			;46a4	00 	. 
	nop			;46a5	00 	. 
	nop			;46a6	00 	. 
	nop			;46a7	00 	. 
	nop			;46a8	00 	. 
	nop			;46a9	00 	. 
	nop			;46aa	00 	. 
	nop			;46ab	00 	. 
	nop			;46ac	00 	. 
	nop			;46ad	00 	. 
	nop			;46ae	00 	. 
	nop			;46af	00 	. 
	nop			;46b0	00 	. 
	nop			;46b1	00 	. 
	nop			;46b2	00 	. 
	nop			;46b3	00 	. 
	nop			;46b4	00 	. 
	nop			;46b5	00 	. 
	nop			;46b6	00 	. 
	nop			;46b7	00 	. 
	nop			;46b8	00 	. 
	nop			;46b9	00 	. 
	nop			;46ba	00 	. 
	nop			;46bb	00 	. 
	nop			;46bc	00 	. 
	nop			;46bd	00 	. 
	nop			;46be	00 	. 
	nop			;46bf	00 	. 
	nop			;46c0	00 	. 
	nop			;46c1	00 	. 
	nop			;46c2	00 	. 
	nop			;46c3	00 	. 
	nop			;46c4	00 	. 
	nop			;46c5	00 	. 
	nop			;46c6	00 	. 
	nop			;46c7	00 	. 
	nop			;46c8	00 	. 
	nop			;46c9	00 	. 
	nop			;46ca	00 	. 
	nop			;46cb	00 	. 
	nop			;46cc	00 	. 
	nop			;46cd	00 	. 
	nop			;46ce	00 	. 
	nop			;46cf	00 	. 
	nop			;46d0	00 	. 
	nop			;46d1	00 	. 
	nop			;46d2	00 	. 
	nop			;46d3	00 	. 
	nop			;46d4	00 	. 
	nop			;46d5	00 	. 
	nop			;46d6	00 	. 
	nop			;46d7	00 	. 
	nop			;46d8	00 	. 
	nop			;46d9	00 	. 
	nop			;46da	00 	. 
	nop			;46db	00 	. 
	nop			;46dc	00 	. 
	nop			;46dd	00 	. 
	nop			;46de	00 	. 
	nop			;46df	00 	. 
	nop			;46e0	00 	. 
	nop			;46e1	00 	. 
	nop			;46e2	00 	. 
	nop			;46e3	00 	. 
	nop			;46e4	00 	. 
	nop			;46e5	00 	. 
	nop			;46e6	00 	. 
	nop			;46e7	00 	. 
	nop			;46e8	00 	. 
	nop			;46e9	00 	. 
	nop			;46ea	00 	. 
	nop			;46eb	00 	. 
	nop			;46ec	00 	. 
	nop			;46ed	00 	. 
	nop			;46ee	00 	. 
	nop			;46ef	00 	. 
	nop			;46f0	00 	. 
	nop			;46f1	00 	. 
	nop			;46f2	00 	. 
	nop			;46f3	00 	. 
	nop			;46f4	00 	. 
	nop			;46f5	00 	. 
	nop			;46f6	00 	. 
	nop			;46f7	00 	. 
	nop			;46f8	00 	. 
	nop			;46f9	00 	. 
	nop			;46fa	00 	. 
	nop			;46fb	00 	. 
	nop			;46fc	00 	. 
	nop			;46fd	00 	. 
	nop			;46fe	00 	. 
	nop			;46ff	00 	. 
	nop			;4700	00 	. 
	nop			;4701	00 	. 
	nop			;4702	00 	. 
	nop			;4703	00 	. 
	nop			;4704	00 	. 
	nop			;4705	00 	. 
	nop			;4706	00 	. 
	nop			;4707	00 	. 
	nop			;4708	00 	. 
	nop			;4709	00 	. 
	nop			;470a	00 	. 
	nop			;470b	00 	. 
	nop			;470c	00 	. 
	nop			;470d	00 	. 
	nop			;470e	00 	. 
	nop			;470f	00 	. 
	nop			;4710	00 	. 
	nop			;4711	00 	. 
	nop			;4712	00 	. 
	nop			;4713	00 	. 
	nop			;4714	00 	. 
	nop			;4715	00 	. 
	nop			;4716	00 	. 
	nop			;4717	00 	. 
	nop			;4718	00 	. 
	nop			;4719	00 	. 
	nop			;471a	00 	. 
	nop			;471b	00 	. 
	nop			;471c	00 	. 
	nop			;471d	00 	. 
	nop			;471e	00 	. 
	nop			;471f	00 	. 
	nop			;4720	00 	. 
	nop			;4721	00 	. 
	nop			;4722	00 	. 
	nop			;4723	00 	. 
	nop			;4724	00 	. 
	nop			;4725	00 	. 
	nop			;4726	00 	. 
	nop			;4727	00 	. 
	nop			;4728	00 	. 
	nop			;4729	00 	. 
	nop			;472a	00 	. 
	nop			;472b	00 	. 
	nop			;472c	00 	. 
	nop			;472d	00 	. 
	nop			;472e	00 	. 
	nop			;472f	00 	. 
	nop			;4730	00 	. 
	nop			;4731	00 	. 
	nop			;4732	00 	. 
	nop			;4733	00 	. 
	nop			;4734	00 	. 
	nop			;4735	00 	. 
	nop			;4736	00 	. 
	nop			;4737	00 	. 
	nop			;4738	00 	. 
	nop			;4739	00 	. 
	nop			;473a	00 	. 
	nop			;473b	00 	. 
	nop			;473c	00 	. 
	nop			;473d	00 	. 
	nop			;473e	00 	. 
	nop			;473f	00 	. 
	nop			;4740	00 	. 
	nop			;4741	00 	. 
	nop			;4742	00 	. 
	nop			;4743	00 	. 
	nop			;4744	00 	. 
	nop			;4745	00 	. 
	nop			;4746	00 	. 
	nop			;4747	00 	. 
	nop			;4748	00 	. 
	nop			;4749	00 	. 
	nop			;474a	00 	. 
	nop			;474b	00 	. 
	nop			;474c	00 	. 
	nop			;474d	00 	. 
	nop			;474e	00 	. 
	nop			;474f	00 	. 
	nop			;4750	00 	. 
	nop			;4751	00 	. 
	nop			;4752	00 	. 
	nop			;4753	00 	. 
	nop			;4754	00 	. 
	nop			;4755	00 	. 
	nop			;4756	00 	. 
	nop			;4757	00 	. 
	nop			;4758	00 	. 
	nop			;4759	00 	. 
	nop			;475a	00 	. 
	nop			;475b	00 	. 
	nop			;475c	00 	. 
	nop			;475d	00 	. 
	nop			;475e	00 	. 
	nop			;475f	00 	. 
	nop			;4760	00 	. 
	nop			;4761	00 	. 
	nop			;4762	00 	. 
	nop			;4763	00 	. 
	nop			;4764	00 	. 
	nop			;4765	00 	. 
	nop			;4766	00 	. 
	nop			;4767	00 	. 
	nop			;4768	00 	. 
	nop			;4769	00 	. 
	nop			;476a	00 	. 
	nop			;476b	00 	. 
	nop			;476c	00 	. 
	nop			;476d	00 	. 
	nop			;476e	00 	. 
	nop			;476f	00 	. 
	nop			;4770	00 	. 
	nop			;4771	00 	. 
	nop			;4772	00 	. 
	nop			;4773	00 	. 
	nop			;4774	00 	. 
	nop			;4775	00 	. 
	nop			;4776	00 	. 
	nop			;4777	00 	. 
	nop			;4778	00 	. 
	nop			;4779	00 	. 
	nop			;477a	00 	. 
	nop			;477b	00 	. 
	nop			;477c	00 	. 
	nop			;477d	00 	. 
	nop			;477e	00 	. 
	nop			;477f	00 	. 
	nop			;4780	00 	. 
	nop			;4781	00 	. 
	nop			;4782	00 	. 
	nop			;4783	00 	. 
	nop			;4784	00 	. 
	nop			;4785	00 	. 
	nop			;4786	00 	. 
	nop			;4787	00 	. 
	nop			;4788	00 	. 
	nop			;4789	00 	. 
	nop			;478a	00 	. 
	nop			;478b	00 	. 
	nop			;478c	00 	. 
	nop			;478d	00 	. 
	nop			;478e	00 	. 
	nop			;478f	00 	. 
	nop			;4790	00 	. 
	nop			;4791	00 	. 
	nop			;4792	00 	. 
	nop			;4793	00 	. 
	nop			;4794	00 	. 
	nop			;4795	00 	. 
	nop			;4796	00 	. 
	nop			;4797	00 	. 
	nop			;4798	00 	. 
	nop			;4799	00 	. 
	nop			;479a	00 	. 
	nop			;479b	00 	. 
	nop			;479c	00 	. 
	nop			;479d	00 	. 
	nop			;479e	00 	. 
	nop			;479f	00 	. 
	nop			;47a0	00 	. 
	nop			;47a1	00 	. 
	nop			;47a2	00 	. 
	nop			;47a3	00 	. 
	nop			;47a4	00 	. 
	nop			;47a5	00 	. 
	nop			;47a6	00 	. 
	nop			;47a7	00 	. 
	nop			;47a8	00 	. 
	nop			;47a9	00 	. 
	nop			;47aa	00 	. 
	nop			;47ab	00 	. 
	nop			;47ac	00 	. 
	nop			;47ad	00 	. 
	nop			;47ae	00 	. 
	nop			;47af	00 	. 
	nop			;47b0	00 	. 
	nop			;47b1	00 	. 
	nop			;47b2	00 	. 
	nop			;47b3	00 	. 
	nop			;47b4	00 	. 
	nop			;47b5	00 	. 
	nop			;47b6	00 	. 
	nop			;47b7	00 	. 
	nop			;47b8	00 	. 
	nop			;47b9	00 	. 
	nop			;47ba	00 	. 
	nop			;47bb	00 	. 
	nop			;47bc	00 	. 
	nop			;47bd	00 	. 
	nop			;47be	00 	. 
	nop			;47bf	00 	. 
	nop			;47c0	00 	. 
	nop			;47c1	00 	. 
	nop			;47c2	00 	. 
	nop			;47c3	00 	. 
	nop			;47c4	00 	. 
	nop			;47c5	00 	. 
	nop			;47c6	00 	. 
	nop			;47c7	00 	. 
	nop			;47c8	00 	. 
	nop			;47c9	00 	. 
	nop			;47ca	00 	. 
	nop			;47cb	00 	. 
	nop			;47cc	00 	. 
	nop			;47cd	00 	. 
	nop			;47ce	00 	. 
	nop			;47cf	00 	. 
	nop			;47d0	00 	. 
	nop			;47d1	00 	. 
	nop			;47d2	00 	. 
	nop			;47d3	00 	. 
	nop			;47d4	00 	. 
	nop			;47d5	00 	. 
	nop			;47d6	00 	. 
	nop			;47d7	00 	. 
	nop			;47d8	00 	. 
	nop			;47d9	00 	. 
	nop			;47da	00 	. 
	nop			;47db	00 	. 
	nop			;47dc	00 	. 
	nop			;47dd	00 	. 
	nop			;47de	00 	. 
	nop			;47df	00 	. 
	nop			;47e0	00 	. 
	nop			;47e1	00 	. 
	nop			;47e2	00 	. 
	nop			;47e3	00 	. 
	nop			;47e4	00 	. 
	nop			;47e5	00 	. 
	nop			;47e6	00 	. 
	nop			;47e7	00 	. 
	nop			;47e8	00 	. 
	nop			;47e9	00 	. 
	nop			;47ea	00 	. 
	nop			;47eb	00 	. 
	nop			;47ec	00 	. 
	nop			;47ed	00 	. 
	nop			;47ee	00 	. 
	nop			;47ef	00 	. 
	nop			;47f0	00 	. 
	nop			;47f1	00 	. 
	nop			;47f2	00 	. 
	nop			;47f3	00 	. 
	nop			;47f4	00 	. 
	nop			;47f5	00 	. 
	nop			;47f6	00 	. 
	nop			;47f7	00 	. 
	nop			;47f8	00 	. 
	nop			;47f9	00 	. 
	nop			;47fa	00 	. 
	nop			;47fb	00 	. 
	nop			;47fc	00 	. 
	nop			;47fd	00 	. 
	nop			;47fe	00 	. 
	nop			;47ff	00 	. 
	nop			;4800	00 	. 
	nop			;4801	00 	. 
	nop			;4802	00 	. 
	nop			;4803	00 	. 
	nop			;4804	00 	. 
	nop			;4805	00 	. 
	nop			;4806	00 	. 
	nop			;4807	00 	. 
	nop			;4808	00 	. 
	nop			;4809	00 	. 
	nop			;480a	00 	. 
	nop			;480b	00 	. 
	nop			;480c	00 	. 
	nop			;480d	00 	. 
	nop			;480e	00 	. 
	nop			;480f	00 	. 
	nop			;4810	00 	. 
	nop			;4811	00 	. 
	nop			;4812	00 	. 
	nop			;4813	00 	. 
	nop			;4814	00 	. 
	nop			;4815	00 	. 
	nop			;4816	00 	. 
	nop			;4817	00 	. 
	nop			;4818	00 	. 
	nop			;4819	00 	. 
	nop			;481a	00 	. 
	nop			;481b	00 	. 
	nop			;481c	00 	. 
	nop			;481d	00 	. 
	nop			;481e	00 	. 
	nop			;481f	00 	. 
	nop			;4820	00 	. 
	nop			;4821	00 	. 
	nop			;4822	00 	. 
	nop			;4823	00 	. 
	nop			;4824	00 	. 
	nop			;4825	00 	. 
	nop			;4826	00 	. 
	nop			;4827	00 	. 
	nop			;4828	00 	. 
	nop			;4829	00 	. 
	nop			;482a	00 	. 
	nop			;482b	00 	. 
	nop			;482c	00 	. 
	nop			;482d	00 	. 
	nop			;482e	00 	. 
	nop			;482f	00 	. 
	nop			;4830	00 	. 
	nop			;4831	00 	. 
	nop			;4832	00 	. 
	nop			;4833	00 	. 
	nop			;4834	00 	. 
	nop			;4835	00 	. 
	nop			;4836	00 	. 
	nop			;4837	00 	. 
	nop			;4838	00 	. 
	nop			;4839	00 	. 
	nop			;483a	00 	. 
	nop			;483b	00 	. 
	nop			;483c	00 	. 
	nop			;483d	00 	. 
	nop			;483e	00 	. 
	nop			;483f	00 	. 
	nop			;4840	00 	. 
	nop			;4841	00 	. 
	nop			;4842	00 	. 
	nop			;4843	00 	. 
	nop			;4844	00 	. 
	nop			;4845	00 	. 
	nop			;4846	00 	. 
	nop			;4847	00 	. 
	nop			;4848	00 	. 
	nop			;4849	00 	. 
	nop			;484a	00 	. 
	nop			;484b	00 	. 
	nop			;484c	00 	. 
	nop			;484d	00 	. 
	nop			;484e	00 	. 
	nop			;484f	00 	. 
	nop			;4850	00 	. 
	nop			;4851	00 	. 
	nop			;4852	00 	. 
	nop			;4853	00 	. 
	nop			;4854	00 	. 
	nop			;4855	00 	. 
	nop			;4856	00 	. 
	nop			;4857	00 	. 
	nop			;4858	00 	. 
	nop			;4859	00 	. 
	nop			;485a	00 	. 
	nop			;485b	00 	. 
	nop			;485c	00 	. 
	nop			;485d	00 	. 
	nop			;485e	00 	. 
	nop			;485f	00 	. 
	nop			;4860	00 	. 
	nop			;4861	00 	. 
	nop			;4862	00 	. 
	nop			;4863	00 	. 
	nop			;4864	00 	. 
	nop			;4865	00 	. 
	nop			;4866	00 	. 
	nop			;4867	00 	. 
	nop			;4868	00 	. 
	nop			;4869	00 	. 
	nop			;486a	00 	. 
	nop			;486b	00 	. 
	nop			;486c	00 	. 
	nop			;486d	00 	. 
	nop			;486e	00 	. 
	nop			;486f	00 	. 
	nop			;4870	00 	. 
	nop			;4871	00 	. 
	nop			;4872	00 	. 
	nop			;4873	00 	. 
	nop			;4874	00 	. 
	nop			;4875	00 	. 
	nop			;4876	00 	. 
	nop			;4877	00 	. 
	nop			;4878	00 	. 
	nop			;4879	00 	. 
	nop			;487a	00 	. 
	nop			;487b	00 	. 
	nop			;487c	00 	. 
	nop			;487d	00 	. 
	nop			;487e	00 	. 
	nop			;487f	00 	. 
	nop			;4880	00 	. 
	nop			;4881	00 	. 
	nop			;4882	00 	. 
	nop			;4883	00 	. 
	nop			;4884	00 	. 
	nop			;4885	00 	. 
	nop			;4886	00 	. 
	nop			;4887	00 	. 
	nop			;4888	00 	. 
	nop			;4889	00 	. 
	nop			;488a	00 	. 
	nop			;488b	00 	. 
	nop			;488c	00 	. 
	nop			;488d	00 	. 
	nop			;488e	00 	. 
	nop			;488f	00 	. 
	nop			;4890	00 	. 
	nop			;4891	00 	. 
	nop			;4892	00 	. 
	nop			;4893	00 	. 
	nop			;4894	00 	. 
	nop			;4895	00 	. 
	nop			;4896	00 	. 
	nop			;4897	00 	. 
	nop			;4898	00 	. 
	nop			;4899	00 	. 
	nop			;489a	00 	. 
	nop			;489b	00 	. 
	nop			;489c	00 	. 
	nop			;489d	00 	. 
	nop			;489e	00 	. 
	nop			;489f	00 	. 
	nop			;48a0	00 	. 
	nop			;48a1	00 	. 
	nop			;48a2	00 	. 
	nop			;48a3	00 	. 
	nop			;48a4	00 	. 
	nop			;48a5	00 	. 
	nop			;48a6	00 	. 
	nop			;48a7	00 	. 
	nop			;48a8	00 	. 
	nop			;48a9	00 	. 
	nop			;48aa	00 	. 
	nop			;48ab	00 	. 
	nop			;48ac	00 	. 
	nop			;48ad	00 	. 
	nop			;48ae	00 	. 
	nop			;48af	00 	. 
	nop			;48b0	00 	. 
	nop			;48b1	00 	. 
	nop			;48b2	00 	. 
	nop			;48b3	00 	. 
	nop			;48b4	00 	. 
	nop			;48b5	00 	. 
	nop			;48b6	00 	. 
	nop			;48b7	00 	. 
	nop			;48b8	00 	. 
	nop			;48b9	00 	. 
	nop			;48ba	00 	. 
	nop			;48bb	00 	. 
	nop			;48bc	00 	. 
	nop			;48bd	00 	. 
	nop			;48be	00 	. 
	nop			;48bf	00 	. 
	nop			;48c0	00 	. 
	nop			;48c1	00 	. 
	nop			;48c2	00 	. 
	nop			;48c3	00 	. 
	nop			;48c4	00 	. 
	nop			;48c5	00 	. 
	nop			;48c6	00 	. 
	nop			;48c7	00 	. 
	nop			;48c8	00 	. 
	nop			;48c9	00 	. 
	nop			;48ca	00 	. 
	nop			;48cb	00 	. 
	nop			;48cc	00 	. 
	nop			;48cd	00 	. 
	nop			;48ce	00 	. 
	nop			;48cf	00 	. 
	nop			;48d0	00 	. 
	nop			;48d1	00 	. 
	nop			;48d2	00 	. 
	nop			;48d3	00 	. 
	nop			;48d4	00 	. 
	nop			;48d5	00 	. 
	nop			;48d6	00 	. 
	nop			;48d7	00 	. 
	nop			;48d8	00 	. 
	nop			;48d9	00 	. 
	nop			;48da	00 	. 
	nop			;48db	00 	. 
	nop			;48dc	00 	. 
	nop			;48dd	00 	. 
	nop			;48de	00 	. 
	nop			;48df	00 	. 
	nop			;48e0	00 	. 
	nop			;48e1	00 	. 
	nop			;48e2	00 	. 
	nop			;48e3	00 	. 
	nop			;48e4	00 	. 
	nop			;48e5	00 	. 
	nop			;48e6	00 	. 
	nop			;48e7	00 	. 
	nop			;48e8	00 	. 
	nop			;48e9	00 	. 
	nop			;48ea	00 	. 
	nop			;48eb	00 	. 
	nop			;48ec	00 	. 
	nop			;48ed	00 	. 
	nop			;48ee	00 	. 
	nop			;48ef	00 	. 
	nop			;48f0	00 	. 
	nop			;48f1	00 	. 
	nop			;48f2	00 	. 
	nop			;48f3	00 	. 
	nop			;48f4	00 	. 
	nop			;48f5	00 	. 
	nop			;48f6	00 	. 
	nop			;48f7	00 	. 
	nop			;48f8	00 	. 
	nop			;48f9	00 	. 
	nop			;48fa	00 	. 
	nop			;48fb	00 	. 
	nop			;48fc	00 	. 
	nop			;48fd	00 	. 
	nop			;48fe	00 	. 
	nop			;48ff	00 	. 
	nop			;4900	00 	. 
	nop			;4901	00 	. 
	nop			;4902	00 	. 
	nop			;4903	00 	. 
	nop			;4904	00 	. 
	nop			;4905	00 	. 
	nop			;4906	00 	. 
	nop			;4907	00 	. 
	nop			;4908	00 	. 
	nop			;4909	00 	. 
	nop			;490a	00 	. 
	nop			;490b	00 	. 
	nop			;490c	00 	. 
	nop			;490d	00 	. 
	nop			;490e	00 	. 
	nop			;490f	00 	. 
	nop			;4910	00 	. 
	nop			;4911	00 	. 
	nop			;4912	00 	. 
	nop			;4913	00 	. 
	nop			;4914	00 	. 
	nop			;4915	00 	. 
	nop			;4916	00 	. 
	nop			;4917	00 	. 
	nop			;4918	00 	. 
	nop			;4919	00 	. 
	nop			;491a	00 	. 
	nop			;491b	00 	. 
	nop			;491c	00 	. 
	nop			;491d	00 	. 
	nop			;491e	00 	. 
	nop			;491f	00 	. 
	nop			;4920	00 	. 
	nop			;4921	00 	. 
	nop			;4922	00 	. 
	nop			;4923	00 	. 
	nop			;4924	00 	. 
	nop			;4925	00 	. 
	nop			;4926	00 	. 
	nop			;4927	00 	. 
	nop			;4928	00 	. 
	nop			;4929	00 	. 
	nop			;492a	00 	. 
	nop			;492b	00 	. 
	nop			;492c	00 	. 
	nop			;492d	00 	. 
	nop			;492e	00 	. 
	nop			;492f	00 	. 
	nop			;4930	00 	. 
	nop			;4931	00 	. 
	nop			;4932	00 	. 
	nop			;4933	00 	. 
	nop			;4934	00 	. 
	nop			;4935	00 	. 
	nop			;4936	00 	. 
	nop			;4937	00 	. 
	nop			;4938	00 	. 
	nop			;4939	00 	. 
	nop			;493a	00 	. 
	nop			;493b	00 	. 
	nop			;493c	00 	. 
	nop			;493d	00 	. 
	nop			;493e	00 	. 
	nop			;493f	00 	. 
	nop			;4940	00 	. 
	nop			;4941	00 	. 
	nop			;4942	00 	. 
	nop			;4943	00 	. 
	nop			;4944	00 	. 
	nop			;4945	00 	. 
	nop			;4946	00 	. 
	nop			;4947	00 	. 
	nop			;4948	00 	. 
	nop			;4949	00 	. 
	nop			;494a	00 	. 
	nop			;494b	00 	. 
	nop			;494c	00 	. 
	nop			;494d	00 	. 
	nop			;494e	00 	. 
	nop			;494f	00 	. 
	nop			;4950	00 	. 
	nop			;4951	00 	. 
	nop			;4952	00 	. 
	nop			;4953	00 	. 
	nop			;4954	00 	. 
	nop			;4955	00 	. 
	nop			;4956	00 	. 
	nop			;4957	00 	. 
	nop			;4958	00 	. 
	nop			;4959	00 	. 
	nop			;495a	00 	. 
	nop			;495b	00 	. 
	nop			;495c	00 	. 
	nop			;495d	00 	. 
	nop			;495e	00 	. 
	nop			;495f	00 	. 
	nop			;4960	00 	. 
	nop			;4961	00 	. 
	nop			;4962	00 	. 
	nop			;4963	00 	. 
	nop			;4964	00 	. 
	nop			;4965	00 	. 
	nop			;4966	00 	. 
	nop			;4967	00 	. 
	nop			;4968	00 	. 
	nop			;4969	00 	. 
	nop			;496a	00 	. 
	nop			;496b	00 	. 
	nop			;496c	00 	. 
	nop			;496d	00 	. 
	nop			;496e	00 	. 
	nop			;496f	00 	. 
	nop			;4970	00 	. 
	nop			;4971	00 	. 
	nop			;4972	00 	. 
	nop			;4973	00 	. 
	nop			;4974	00 	. 
	nop			;4975	00 	. 
	nop			;4976	00 	. 
	nop			;4977	00 	. 
	nop			;4978	00 	. 
	nop			;4979	00 	. 
	nop			;497a	00 	. 
	nop			;497b	00 	. 
	nop			;497c	00 	. 
	nop			;497d	00 	. 
	nop			;497e	00 	. 
	nop			;497f	00 	. 
	nop			;4980	00 	. 
	nop			;4981	00 	. 
	nop			;4982	00 	. 
	nop			;4983	00 	. 
	nop			;4984	00 	. 
	nop			;4985	00 	. 
	nop			;4986	00 	. 
	nop			;4987	00 	. 
	nop			;4988	00 	. 
	nop			;4989	00 	. 
	nop			;498a	00 	. 
	nop			;498b	00 	. 
	nop			;498c	00 	. 
	nop			;498d	00 	. 
	nop			;498e	00 	. 
	nop			;498f	00 	. 
	nop			;4990	00 	. 
	nop			;4991	00 	. 
	nop			;4992	00 	. 
	nop			;4993	00 	. 
	nop			;4994	00 	. 
	nop			;4995	00 	. 
	nop			;4996	00 	. 
	nop			;4997	00 	. 
	nop			;4998	00 	. 
	nop			;4999	00 	. 
	nop			;499a	00 	. 
	nop			;499b	00 	. 
	nop			;499c	00 	. 
	nop			;499d	00 	. 
	nop			;499e	00 	. 
	nop			;499f	00 	. 
	nop			;49a0	00 	. 
	nop			;49a1	00 	. 
	nop			;49a2	00 	. 
	nop			;49a3	00 	. 
	nop			;49a4	00 	. 
	nop			;49a5	00 	. 
	nop			;49a6	00 	. 
	nop			;49a7	00 	. 
	nop			;49a8	00 	. 
	nop			;49a9	00 	. 
	nop			;49aa	00 	. 
	nop			;49ab	00 	. 
	nop			;49ac	00 	. 
	nop			;49ad	00 	. 
	nop			;49ae	00 	. 
	nop			;49af	00 	. 
	nop			;49b0	00 	. 
	nop			;49b1	00 	. 
	nop			;49b2	00 	. 
	nop			;49b3	00 	. 
	nop			;49b4	00 	. 
	nop			;49b5	00 	. 
	nop			;49b6	00 	. 
	nop			;49b7	00 	. 
	nop			;49b8	00 	. 
	nop			;49b9	00 	. 
	nop			;49ba	00 	. 
	nop			;49bb	00 	. 
	nop			;49bc	00 	. 
	nop			;49bd	00 	. 
	nop			;49be	00 	. 
	nop			;49bf	00 	. 
	nop			;49c0	00 	. 
	nop			;49c1	00 	. 
	nop			;49c2	00 	. 
	nop			;49c3	00 	. 
	nop			;49c4	00 	. 
	nop			;49c5	00 	. 
	nop			;49c6	00 	. 
	nop			;49c7	00 	. 
	nop			;49c8	00 	. 
	nop			;49c9	00 	. 
	nop			;49ca	00 	. 
	nop			;49cb	00 	. 
	nop			;49cc	00 	. 
	nop			;49cd	00 	. 
	nop			;49ce	00 	. 
	nop			;49cf	00 	. 
	nop			;49d0	00 	. 
	nop			;49d1	00 	. 
	nop			;49d2	00 	. 
	nop			;49d3	00 	. 
	nop			;49d4	00 	. 
	nop			;49d5	00 	. 
	nop			;49d6	00 	. 
	nop			;49d7	00 	. 
	nop			;49d8	00 	. 
	nop			;49d9	00 	. 
	nop			;49da	00 	. 
	nop			;49db	00 	. 
	nop			;49dc	00 	. 
	nop			;49dd	00 	. 
	nop			;49de	00 	. 
	nop			;49df	00 	. 
	nop			;49e0	00 	. 
	nop			;49e1	00 	. 
	nop			;49e2	00 	. 
	nop			;49e3	00 	. 
	nop			;49e4	00 	. 
	nop			;49e5	00 	. 
	nop			;49e6	00 	. 
	nop			;49e7	00 	. 
	nop			;49e8	00 	. 
	nop			;49e9	00 	. 
	nop			;49ea	00 	. 
	nop			;49eb	00 	. 
	nop			;49ec	00 	. 
	nop			;49ed	00 	. 
	nop			;49ee	00 	. 
	nop			;49ef	00 	. 
	nop			;49f0	00 	. 
	nop			;49f1	00 	. 
	nop			;49f2	00 	. 
	nop			;49f3	00 	. 
	nop			;49f4	00 	. 
	nop			;49f5	00 	. 
	nop			;49f6	00 	. 
	nop			;49f7	00 	. 
	nop			;49f8	00 	. 
	nop			;49f9	00 	. 
	nop			;49fa	00 	. 
	nop			;49fb	00 	. 
	nop			;49fc	00 	. 
	nop			;49fd	00 	. 
	nop			;49fe	00 	. 
	nop			;49ff	00 	. 
	nop			;4a00	00 	. 
	nop			;4a01	00 	. 
	nop			;4a02	00 	. 
	nop			;4a03	00 	. 
	nop			;4a04	00 	. 
	nop			;4a05	00 	. 
	nop			;4a06	00 	. 
	nop			;4a07	00 	. 
	nop			;4a08	00 	. 
	nop			;4a09	00 	. 
	nop			;4a0a	00 	. 
	nop			;4a0b	00 	. 
	nop			;4a0c	00 	. 
	nop			;4a0d	00 	. 
	nop			;4a0e	00 	. 
	nop			;4a0f	00 	. 
	nop			;4a10	00 	. 
	nop			;4a11	00 	. 
	nop			;4a12	00 	. 
	nop			;4a13	00 	. 
	nop			;4a14	00 	. 
	nop			;4a15	00 	. 
	nop			;4a16	00 	. 
	nop			;4a17	00 	. 
	nop			;4a18	00 	. 
	nop			;4a19	00 	. 
	nop			;4a1a	00 	. 
	nop			;4a1b	00 	. 
	nop			;4a1c	00 	. 
	nop			;4a1d	00 	. 
	nop			;4a1e	00 	. 
	nop			;4a1f	00 	. 
	nop			;4a20	00 	. 
	nop			;4a21	00 	. 
	nop			;4a22	00 	. 
	nop			;4a23	00 	. 
	nop			;4a24	00 	. 
	nop			;4a25	00 	. 
	nop			;4a26	00 	. 
	nop			;4a27	00 	. 
	nop			;4a28	00 	. 
	nop			;4a29	00 	. 
	nop			;4a2a	00 	. 
	nop			;4a2b	00 	. 
	nop			;4a2c	00 	. 
	nop			;4a2d	00 	. 
	nop			;4a2e	00 	. 
	nop			;4a2f	00 	. 
	nop			;4a30	00 	. 
	nop			;4a31	00 	. 
	nop			;4a32	00 	. 
	nop			;4a33	00 	. 
	nop			;4a34	00 	. 
	nop			;4a35	00 	. 
	nop			;4a36	00 	. 
	nop			;4a37	00 	. 
	nop			;4a38	00 	. 
	nop			;4a39	00 	. 
	nop			;4a3a	00 	. 
	nop			;4a3b	00 	. 
	nop			;4a3c	00 	. 
	nop			;4a3d	00 	. 
	nop			;4a3e	00 	. 
	nop			;4a3f	00 	. 
	nop			;4a40	00 	. 
	nop			;4a41	00 	. 
	nop			;4a42	00 	. 
	nop			;4a43	00 	. 
	nop			;4a44	00 	. 
	nop			;4a45	00 	. 
	nop			;4a46	00 	. 
	nop			;4a47	00 	. 
	nop			;4a48	00 	. 
	nop			;4a49	00 	. 
	nop			;4a4a	00 	. 
	nop			;4a4b	00 	. 
	nop			;4a4c	00 	. 
	nop			;4a4d	00 	. 
	nop			;4a4e	00 	. 
	nop			;4a4f	00 	. 
	nop			;4a50	00 	. 
	nop			;4a51	00 	. 
	nop			;4a52	00 	. 
	nop			;4a53	00 	. 
	nop			;4a54	00 	. 
	nop			;4a55	00 	. 
	nop			;4a56	00 	. 
	nop			;4a57	00 	. 
	nop			;4a58	00 	. 
	nop			;4a59	00 	. 
	nop			;4a5a	00 	. 
	nop			;4a5b	00 	. 
	nop			;4a5c	00 	. 
	nop			;4a5d	00 	. 
	nop			;4a5e	00 	. 
	nop			;4a5f	00 	. 
	nop			;4a60	00 	. 
	nop			;4a61	00 	. 
	nop			;4a62	00 	. 
	nop			;4a63	00 	. 
	nop			;4a64	00 	. 
	nop			;4a65	00 	. 
	nop			;4a66	00 	. 
	nop			;4a67	00 	. 
	nop			;4a68	00 	. 
	nop			;4a69	00 	. 
	nop			;4a6a	00 	. 
	nop			;4a6b	00 	. 
	nop			;4a6c	00 	. 
	nop			;4a6d	00 	. 
	nop			;4a6e	00 	. 
	nop			;4a6f	00 	. 
	nop			;4a70	00 	. 
	nop			;4a71	00 	. 
	nop			;4a72	00 	. 
	nop			;4a73	00 	. 
	nop			;4a74	00 	. 
	nop			;4a75	00 	. 
	nop			;4a76	00 	. 
	nop			;4a77	00 	. 
	nop			;4a78	00 	. 
	nop			;4a79	00 	. 
	nop			;4a7a	00 	. 
	nop			;4a7b	00 	. 
	nop			;4a7c	00 	. 
	nop			;4a7d	00 	. 
	nop			;4a7e	00 	. 
	nop			;4a7f	00 	. 
	nop			;4a80	00 	. 
	nop			;4a81	00 	. 
	nop			;4a82	00 	. 
	nop			;4a83	00 	. 
	nop			;4a84	00 	. 
	nop			;4a85	00 	. 
	nop			;4a86	00 	. 
	nop			;4a87	00 	. 
	nop			;4a88	00 	. 
	nop			;4a89	00 	. 
	nop			;4a8a	00 	. 
	nop			;4a8b	00 	. 
	nop			;4a8c	00 	. 
	nop			;4a8d	00 	. 
	nop			;4a8e	00 	. 
	nop			;4a8f	00 	. 
	nop			;4a90	00 	. 
	nop			;4a91	00 	. 
	nop			;4a92	00 	. 
	nop			;4a93	00 	. 
	nop			;4a94	00 	. 
	nop			;4a95	00 	. 
	nop			;4a96	00 	. 
	nop			;4a97	00 	. 
	nop			;4a98	00 	. 
	nop			;4a99	00 	. 
	nop			;4a9a	00 	. 
	nop			;4a9b	00 	. 
	nop			;4a9c	00 	. 
	nop			;4a9d	00 	. 
	nop			;4a9e	00 	. 
	nop			;4a9f	00 	. 
	nop			;4aa0	00 	. 
	nop			;4aa1	00 	. 
	nop			;4aa2	00 	. 
	nop			;4aa3	00 	. 
	nop			;4aa4	00 	. 
	nop			;4aa5	00 	. 
	nop			;4aa6	00 	. 
	nop			;4aa7	00 	. 
	nop			;4aa8	00 	. 
	nop			;4aa9	00 	. 
	nop			;4aaa	00 	. 
	nop			;4aab	00 	. 
	nop			;4aac	00 	. 
	nop			;4aad	00 	. 
	nop			;4aae	00 	. 
	nop			;4aaf	00 	. 
	nop			;4ab0	00 	. 
	nop			;4ab1	00 	. 
	nop			;4ab2	00 	. 
	nop			;4ab3	00 	. 
	nop			;4ab4	00 	. 
	nop			;4ab5	00 	. 
	nop			;4ab6	00 	. 
	nop			;4ab7	00 	. 
	nop			;4ab8	00 	. 
	nop			;4ab9	00 	. 
	nop			;4aba	00 	. 
	nop			;4abb	00 	. 
	nop			;4abc	00 	. 
	nop			;4abd	00 	. 
	nop			;4abe	00 	. 
	nop			;4abf	00 	. 
	nop			;4ac0	00 	. 
	nop			;4ac1	00 	. 
	nop			;4ac2	00 	. 
	nop			;4ac3	00 	. 
	nop			;4ac4	00 	. 
	nop			;4ac5	00 	. 
	nop			;4ac6	00 	. 
	nop			;4ac7	00 	. 
	nop			;4ac8	00 	. 
	nop			;4ac9	00 	. 
	nop			;4aca	00 	. 
	nop			;4acb	00 	. 
	nop			;4acc	00 	. 
	nop			;4acd	00 	. 
	nop			;4ace	00 	. 
	nop			;4acf	00 	. 
	nop			;4ad0	00 	. 
	nop			;4ad1	00 	. 
	nop			;4ad2	00 	. 
	nop			;4ad3	00 	. 
	nop			;4ad4	00 	. 
	nop			;4ad5	00 	. 
	nop			;4ad6	00 	. 
	nop			;4ad7	00 	. 
	nop			;4ad8	00 	. 
	nop			;4ad9	00 	. 
	nop			;4ada	00 	. 
	nop			;4adb	00 	. 
	nop			;4adc	00 	. 
	nop			;4add	00 	. 
	nop			;4ade	00 	. 
	nop			;4adf	00 	. 
	nop			;4ae0	00 	. 
	nop			;4ae1	00 	. 
	nop			;4ae2	00 	. 
	nop			;4ae3	00 	. 
	nop			;4ae4	00 	. 
	nop			;4ae5	00 	. 
	nop			;4ae6	00 	. 
	nop			;4ae7	00 	. 
	nop			;4ae8	00 	. 
	nop			;4ae9	00 	. 
	nop			;4aea	00 	. 
	nop			;4aeb	00 	. 
	nop			;4aec	00 	. 
	nop			;4aed	00 	. 
	nop			;4aee	00 	. 
	nop			;4aef	00 	. 
	nop			;4af0	00 	. 
	nop			;4af1	00 	. 
	nop			;4af2	00 	. 
	nop			;4af3	00 	. 
	nop			;4af4	00 	. 
	nop			;4af5	00 	. 
	nop			;4af6	00 	. 
	nop			;4af7	00 	. 
	nop			;4af8	00 	. 
	nop			;4af9	00 	. 
	nop			;4afa	00 	. 
	nop			;4afb	00 	. 
	nop			;4afc	00 	. 
	nop			;4afd	00 	. 
	nop			;4afe	00 	. 
	nop			;4aff	00 	. 
	nop			;4b00	00 	. 
	nop			;4b01	00 	. 
	nop			;4b02	00 	. 
	nop			;4b03	00 	. 
	nop			;4b04	00 	. 
	nop			;4b05	00 	. 
	nop			;4b06	00 	. 
	nop			;4b07	00 	. 
	nop			;4b08	00 	. 
	nop			;4b09	00 	. 
	nop			;4b0a	00 	. 
	nop			;4b0b	00 	. 
	nop			;4b0c	00 	. 
	nop			;4b0d	00 	. 
	nop			;4b0e	00 	. 
	nop			;4b0f	00 	. 
	nop			;4b10	00 	. 
	nop			;4b11	00 	. 
	nop			;4b12	00 	. 
	nop			;4b13	00 	. 
	nop			;4b14	00 	. 
	nop			;4b15	00 	. 
	nop			;4b16	00 	. 
	nop			;4b17	00 	. 
	nop			;4b18	00 	. 
	nop			;4b19	00 	. 
	nop			;4b1a	00 	. 
	nop			;4b1b	00 	. 
	nop			;4b1c	00 	. 
	nop			;4b1d	00 	. 
	nop			;4b1e	00 	. 
	nop			;4b1f	00 	. 
	nop			;4b20	00 	. 
	nop			;4b21	00 	. 
	nop			;4b22	00 	. 
	nop			;4b23	00 	. 
	nop			;4b24	00 	. 
	nop			;4b25	00 	. 
	nop			;4b26	00 	. 
	nop			;4b27	00 	. 
	nop			;4b28	00 	. 
	nop			;4b29	00 	. 
	nop			;4b2a	00 	. 
	nop			;4b2b	00 	. 
	nop			;4b2c	00 	. 
	nop			;4b2d	00 	. 
	nop			;4b2e	00 	. 
	nop			;4b2f	00 	. 
	nop			;4b30	00 	. 
	nop			;4b31	00 	. 
	nop			;4b32	00 	. 
	nop			;4b33	00 	. 
	nop			;4b34	00 	. 
	nop			;4b35	00 	. 
	nop			;4b36	00 	. 
	nop			;4b37	00 	. 
	nop			;4b38	00 	. 
	nop			;4b39	00 	. 
	nop			;4b3a	00 	. 
	nop			;4b3b	00 	. 
	nop			;4b3c	00 	. 
	nop			;4b3d	00 	. 
	nop			;4b3e	00 	. 
	nop			;4b3f	00 	. 
	nop			;4b40	00 	. 
	nop			;4b41	00 	. 
	nop			;4b42	00 	. 
	nop			;4b43	00 	. 
	nop			;4b44	00 	. 
	nop			;4b45	00 	. 
	nop			;4b46	00 	. 
	nop			;4b47	00 	. 
	nop			;4b48	00 	. 
	nop			;4b49	00 	. 
	nop			;4b4a	00 	. 
	nop			;4b4b	00 	. 
	nop			;4b4c	00 	. 
	nop			;4b4d	00 	. 
	nop			;4b4e	00 	. 
	nop			;4b4f	00 	. 
	nop			;4b50	00 	. 
	nop			;4b51	00 	. 
	nop			;4b52	00 	. 
	nop			;4b53	00 	. 
	nop			;4b54	00 	. 
	nop			;4b55	00 	. 
	nop			;4b56	00 	. 
	nop			;4b57	00 	. 
	nop			;4b58	00 	. 
	nop			;4b59	00 	. 
	nop			;4b5a	00 	. 
	nop			;4b5b	00 	. 
	nop			;4b5c	00 	. 
	nop			;4b5d	00 	. 
	nop			;4b5e	00 	. 
	nop			;4b5f	00 	. 
	nop			;4b60	00 	. 
	nop			;4b61	00 	. 
	nop			;4b62	00 	. 
	nop			;4b63	00 	. 
	nop			;4b64	00 	. 
	nop			;4b65	00 	. 
	nop			;4b66	00 	. 
	nop			;4b67	00 	. 
	nop			;4b68	00 	. 
	nop			;4b69	00 	. 
	nop			;4b6a	00 	. 
	nop			;4b6b	00 	. 
	nop			;4b6c	00 	. 
	nop			;4b6d	00 	. 
	nop			;4b6e	00 	. 
	nop			;4b6f	00 	. 
	nop			;4b70	00 	. 
	nop			;4b71	00 	. 
	nop			;4b72	00 	. 
	nop			;4b73	00 	. 
	nop			;4b74	00 	. 
	nop			;4b75	00 	. 
	nop			;4b76	00 	. 
	nop			;4b77	00 	. 
	nop			;4b78	00 	. 
	nop			;4b79	00 	. 
	nop			;4b7a	00 	. 
	nop			;4b7b	00 	. 
	nop			;4b7c	00 	. 
	nop			;4b7d	00 	. 
	nop			;4b7e	00 	. 
	nop			;4b7f	00 	. 
	nop			;4b80	00 	. 
	nop			;4b81	00 	. 
	nop			;4b82	00 	. 
	nop			;4b83	00 	. 
	nop			;4b84	00 	. 
	nop			;4b85	00 	. 
	nop			;4b86	00 	. 
	nop			;4b87	00 	. 
	nop			;4b88	00 	. 
	nop			;4b89	00 	. 
	nop			;4b8a	00 	. 
	nop			;4b8b	00 	. 
	nop			;4b8c	00 	. 
	nop			;4b8d	00 	. 
	nop			;4b8e	00 	. 
	nop			;4b8f	00 	. 
	nop			;4b90	00 	. 
	nop			;4b91	00 	. 
	nop			;4b92	00 	. 
	nop			;4b93	00 	. 
	nop			;4b94	00 	. 
	nop			;4b95	00 	. 
	nop			;4b96	00 	. 
	nop			;4b97	00 	. 
	nop			;4b98	00 	. 
	nop			;4b99	00 	. 
	nop			;4b9a	00 	. 
	nop			;4b9b	00 	. 
	nop			;4b9c	00 	. 
	nop			;4b9d	00 	. 
	nop			;4b9e	00 	. 
	nop			;4b9f	00 	. 
	nop			;4ba0	00 	. 
	nop			;4ba1	00 	. 
	nop			;4ba2	00 	. 
	nop			;4ba3	00 	. 
	nop			;4ba4	00 	. 
	nop			;4ba5	00 	. 
	nop			;4ba6	00 	. 
	nop			;4ba7	00 	. 
	nop			;4ba8	00 	. 
	nop			;4ba9	00 	. 
	nop			;4baa	00 	. 
	nop			;4bab	00 	. 
	nop			;4bac	00 	. 
	nop			;4bad	00 	. 
	nop			;4bae	00 	. 
	nop			;4baf	00 	. 
	nop			;4bb0	00 	. 
	nop			;4bb1	00 	. 
	nop			;4bb2	00 	. 
	nop			;4bb3	00 	. 
	nop			;4bb4	00 	. 
	nop			;4bb5	00 	. 
	nop			;4bb6	00 	. 
	nop			;4bb7	00 	. 
	nop			;4bb8	00 	. 
	nop			;4bb9	00 	. 
	nop			;4bba	00 	. 
	nop			;4bbb	00 	. 
	nop			;4bbc	00 	. 
	nop			;4bbd	00 	. 
	nop			;4bbe	00 	. 
	nop			;4bbf	00 	. 
	nop			;4bc0	00 	. 
	nop			;4bc1	00 	. 
	nop			;4bc2	00 	. 
	nop			;4bc3	00 	. 
	nop			;4bc4	00 	. 
	nop			;4bc5	00 	. 
	nop			;4bc6	00 	. 
	nop			;4bc7	00 	. 
	nop			;4bc8	00 	. 
	nop			;4bc9	00 	. 
	nop			;4bca	00 	. 
	nop			;4bcb	00 	. 
	nop			;4bcc	00 	. 
	nop			;4bcd	00 	. 
	nop			;4bce	00 	. 
	nop			;4bcf	00 	. 
	nop			;4bd0	00 	. 
	nop			;4bd1	00 	. 
	nop			;4bd2	00 	. 
	nop			;4bd3	00 	. 
	nop			;4bd4	00 	. 
	nop			;4bd5	00 	. 
	nop			;4bd6	00 	. 
	nop			;4bd7	00 	. 
	nop			;4bd8	00 	. 
	nop			;4bd9	00 	. 
	nop			;4bda	00 	. 
	nop			;4bdb	00 	. 
	nop			;4bdc	00 	. 
	nop			;4bdd	00 	. 
	nop			;4bde	00 	. 
	nop			;4bdf	00 	. 
	nop			;4be0	00 	. 
	nop			;4be1	00 	. 
	nop			;4be2	00 	. 
	nop			;4be3	00 	. 
	nop			;4be4	00 	. 
	nop			;4be5	00 	. 
	nop			;4be6	00 	. 
	nop			;4be7	00 	. 
	nop			;4be8	00 	. 
	nop			;4be9	00 	. 
	nop			;4bea	00 	. 
	nop			;4beb	00 	. 
	nop			;4bec	00 	. 
	nop			;4bed	00 	. 
	nop			;4bee	00 	. 
	nop			;4bef	00 	. 
	nop			;4bf0	00 	. 
	nop			;4bf1	00 	. 
	nop			;4bf2	00 	. 
	nop			;4bf3	00 	. 
	nop			;4bf4	00 	. 
	nop			;4bf5	00 	. 
	nop			;4bf6	00 	. 
	nop			;4bf7	00 	. 
	nop			;4bf8	00 	. 
	nop			;4bf9	00 	. 
	nop			;4bfa	00 	. 
	nop			;4bfb	00 	. 
	nop			;4bfc	00 	. 
	nop			;4bfd	00 	. 
	nop			;4bfe	00 	. 
	nop			;4bff	00 	. 
	nop			;4c00	00 	. 
	nop			;4c01	00 	. 
	nop			;4c02	00 	. 
	nop			;4c03	00 	. 
	nop			;4c04	00 	. 
	nop			;4c05	00 	. 
	nop			;4c06	00 	. 
	nop			;4c07	00 	. 
	nop			;4c08	00 	. 
	nop			;4c09	00 	. 
	nop			;4c0a	00 	. 
	nop			;4c0b	00 	. 
	nop			;4c0c	00 	. 
	nop			;4c0d	00 	. 
	nop			;4c0e	00 	. 
	nop			;4c0f	00 	. 
	nop			;4c10	00 	. 
	nop			;4c11	00 	. 
	nop			;4c12	00 	. 
	nop			;4c13	00 	. 
	nop			;4c14	00 	. 
	nop			;4c15	00 	. 
	nop			;4c16	00 	. 
	nop			;4c17	00 	. 
	nop			;4c18	00 	. 
	nop			;4c19	00 	. 
	nop			;4c1a	00 	. 
	nop			;4c1b	00 	. 
	nop			;4c1c	00 	. 
	nop			;4c1d	00 	. 
	nop			;4c1e	00 	. 
	nop			;4c1f	00 	. 
	nop			;4c20	00 	. 
	nop			;4c21	00 	. 
	nop			;4c22	00 	. 
	nop			;4c23	00 	. 
	nop			;4c24	00 	. 
	nop			;4c25	00 	. 
	nop			;4c26	00 	. 
	nop			;4c27	00 	. 
	nop			;4c28	00 	. 
	nop			;4c29	00 	. 
	nop			;4c2a	00 	. 
	nop			;4c2b	00 	. 
	nop			;4c2c	00 	. 
	nop			;4c2d	00 	. 
	nop			;4c2e	00 	. 
	nop			;4c2f	00 	. 
	nop			;4c30	00 	. 
	nop			;4c31	00 	. 
	nop			;4c32	00 	. 
	nop			;4c33	00 	. 
	nop			;4c34	00 	. 
	nop			;4c35	00 	. 
	nop			;4c36	00 	. 
	nop			;4c37	00 	. 
	nop			;4c38	00 	. 
	nop			;4c39	00 	. 
	nop			;4c3a	00 	. 
	nop			;4c3b	00 	. 
	nop			;4c3c	00 	. 
	nop			;4c3d	00 	. 
	nop			;4c3e	00 	. 
	nop			;4c3f	00 	. 
	nop			;4c40	00 	. 
	nop			;4c41	00 	. 
	nop			;4c42	00 	. 
	nop			;4c43	00 	. 
	nop			;4c44	00 	. 
	nop			;4c45	00 	. 
	nop			;4c46	00 	. 
	nop			;4c47	00 	. 
	nop			;4c48	00 	. 
	nop			;4c49	00 	. 
	nop			;4c4a	00 	. 
	nop			;4c4b	00 	. 
	nop			;4c4c	00 	. 
	nop			;4c4d	00 	. 
	nop			;4c4e	00 	. 
	nop			;4c4f	00 	. 
	nop			;4c50	00 	. 
	nop			;4c51	00 	. 
	nop			;4c52	00 	. 
	nop			;4c53	00 	. 
	nop			;4c54	00 	. 
	nop			;4c55	00 	. 
	nop			;4c56	00 	. 
	nop			;4c57	00 	. 
	nop			;4c58	00 	. 
	nop			;4c59	00 	. 
	nop			;4c5a	00 	. 
	nop			;4c5b	00 	. 
	nop			;4c5c	00 	. 
	nop			;4c5d	00 	. 
	nop			;4c5e	00 	. 
	nop			;4c5f	00 	. 
	nop			;4c60	00 	. 
	nop			;4c61	00 	. 
	nop			;4c62	00 	. 
	nop			;4c63	00 	. 
	nop			;4c64	00 	. 
	nop			;4c65	00 	. 
	nop			;4c66	00 	. 
	nop			;4c67	00 	. 
	nop			;4c68	00 	. 
	nop			;4c69	00 	. 
	nop			;4c6a	00 	. 
	nop			;4c6b	00 	. 
	nop			;4c6c	00 	. 
	nop			;4c6d	00 	. 
	nop			;4c6e	00 	. 
	nop			;4c6f	00 	. 
	nop			;4c70	00 	. 
	nop			;4c71	00 	. 
	nop			;4c72	00 	. 
	nop			;4c73	00 	. 
	nop			;4c74	00 	. 
	nop			;4c75	00 	. 
	nop			;4c76	00 	. 
	nop			;4c77	00 	. 
	nop			;4c78	00 	. 
	nop			;4c79	00 	. 
	nop			;4c7a	00 	. 
	nop			;4c7b	00 	. 
	nop			;4c7c	00 	. 
	nop			;4c7d	00 	. 
	nop			;4c7e	00 	. 
	nop			;4c7f	00 	. 
	nop			;4c80	00 	. 
	nop			;4c81	00 	. 
	nop			;4c82	00 	. 
	nop			;4c83	00 	. 
	nop			;4c84	00 	. 
	nop			;4c85	00 	. 
	nop			;4c86	00 	. 
	nop			;4c87	00 	. 
	nop			;4c88	00 	. 
	nop			;4c89	00 	. 
	nop			;4c8a	00 	. 
	nop			;4c8b	00 	. 
	nop			;4c8c	00 	. 
	nop			;4c8d	00 	. 
	nop			;4c8e	00 	. 
	nop			;4c8f	00 	. 
	nop			;4c90	00 	. 
	nop			;4c91	00 	. 
	nop			;4c92	00 	. 
	nop			;4c93	00 	. 
	nop			;4c94	00 	. 
	nop			;4c95	00 	. 
	nop			;4c96	00 	. 
	nop			;4c97	00 	. 
	nop			;4c98	00 	. 
	nop			;4c99	00 	. 
	nop			;4c9a	00 	. 
	nop			;4c9b	00 	. 
	nop			;4c9c	00 	. 
	nop			;4c9d	00 	. 
	nop			;4c9e	00 	. 
	nop			;4c9f	00 	. 
	nop			;4ca0	00 	. 
	nop			;4ca1	00 	. 
	nop			;4ca2	00 	. 
	nop			;4ca3	00 	. 
	nop			;4ca4	00 	. 
	nop			;4ca5	00 	. 
	nop			;4ca6	00 	. 
	nop			;4ca7	00 	. 
	nop			;4ca8	00 	. 
	nop			;4ca9	00 	. 
	nop			;4caa	00 	. 
	nop			;4cab	00 	. 
	nop			;4cac	00 	. 
	nop			;4cad	00 	. 
	nop			;4cae	00 	. 
	nop			;4caf	00 	. 
	nop			;4cb0	00 	. 
	nop			;4cb1	00 	. 
	nop			;4cb2	00 	. 
	nop			;4cb3	00 	. 
	nop			;4cb4	00 	. 
	nop			;4cb5	00 	. 
	nop			;4cb6	00 	. 
	nop			;4cb7	00 	. 
	nop			;4cb8	00 	. 
	nop			;4cb9	00 	. 
	nop			;4cba	00 	. 
	nop			;4cbb	00 	. 
	nop			;4cbc	00 	. 
	nop			;4cbd	00 	. 
	nop			;4cbe	00 	. 
	nop			;4cbf	00 	. 
	nop			;4cc0	00 	. 
	nop			;4cc1	00 	. 
	nop			;4cc2	00 	. 
	nop			;4cc3	00 	. 
	nop			;4cc4	00 	. 
	nop			;4cc5	00 	. 
	nop			;4cc6	00 	. 
	nop			;4cc7	00 	. 
	nop			;4cc8	00 	. 
	nop			;4cc9	00 	. 
	nop			;4cca	00 	. 
	nop			;4ccb	00 	. 
	nop			;4ccc	00 	. 
	nop			;4ccd	00 	. 
	nop			;4cce	00 	. 
	nop			;4ccf	00 	. 
	nop			;4cd0	00 	. 
	nop			;4cd1	00 	. 
	nop			;4cd2	00 	. 
	nop			;4cd3	00 	. 
	nop			;4cd4	00 	. 
	nop			;4cd5	00 	. 
	nop			;4cd6	00 	. 
	nop			;4cd7	00 	. 
	nop			;4cd8	00 	. 
	nop			;4cd9	00 	. 
	nop			;4cda	00 	. 
	nop			;4cdb	00 	. 
	nop			;4cdc	00 	. 
	nop			;4cdd	00 	. 
	nop			;4cde	00 	. 
	nop			;4cdf	00 	. 
	nop			;4ce0	00 	. 
	nop			;4ce1	00 	. 
	nop			;4ce2	00 	. 
	nop			;4ce3	00 	. 
	nop			;4ce4	00 	. 
	nop			;4ce5	00 	. 
	nop			;4ce6	00 	. 
	nop			;4ce7	00 	. 
	nop			;4ce8	00 	. 
	nop			;4ce9	00 	. 
	nop			;4cea	00 	. 
	nop			;4ceb	00 	. 
	nop			;4cec	00 	. 
	nop			;4ced	00 	. 
	nop			;4cee	00 	. 
	nop			;4cef	00 	. 
	nop			;4cf0	00 	. 
	nop			;4cf1	00 	. 
	nop			;4cf2	00 	. 
	nop			;4cf3	00 	. 
	nop			;4cf4	00 	. 
	nop			;4cf5	00 	. 
	nop			;4cf6	00 	. 
	nop			;4cf7	00 	. 
	nop			;4cf8	00 	. 
	nop			;4cf9	00 	. 
	nop			;4cfa	00 	. 
	nop			;4cfb	00 	. 
	nop			;4cfc	00 	. 
	nop			;4cfd	00 	. 
	nop			;4cfe	00 	. 
	nop			;4cff	00 	. 
	nop			;4d00	00 	. 
	nop			;4d01	00 	. 
	nop			;4d02	00 	. 
	nop			;4d03	00 	. 
	nop			;4d04	00 	. 
	nop			;4d05	00 	. 
	nop			;4d06	00 	. 
	nop			;4d07	00 	. 
	nop			;4d08	00 	. 
	nop			;4d09	00 	. 
	nop			;4d0a	00 	. 
	nop			;4d0b	00 	. 
	nop			;4d0c	00 	. 
	nop			;4d0d	00 	. 
	nop			;4d0e	00 	. 
	nop			;4d0f	00 	. 
	nop			;4d10	00 	. 
	nop			;4d11	00 	. 
	nop			;4d12	00 	. 
	nop			;4d13	00 	. 
	nop			;4d14	00 	. 
	nop			;4d15	00 	. 
	nop			;4d16	00 	. 
	nop			;4d17	00 	. 
	nop			;4d18	00 	. 
	nop			;4d19	00 	. 
	nop			;4d1a	00 	. 
	nop			;4d1b	00 	. 
	nop			;4d1c	00 	. 
	nop			;4d1d	00 	. 
	nop			;4d1e	00 	. 
	nop			;4d1f	00 	. 
	nop			;4d20	00 	. 
	nop			;4d21	00 	. 
	nop			;4d22	00 	. 
	nop			;4d23	00 	. 
	nop			;4d24	00 	. 
	nop			;4d25	00 	. 
	nop			;4d26	00 	. 
	nop			;4d27	00 	. 
	nop			;4d28	00 	. 
	nop			;4d29	00 	. 
	nop			;4d2a	00 	. 
	nop			;4d2b	00 	. 
	nop			;4d2c	00 	. 
	nop			;4d2d	00 	. 
	nop			;4d2e	00 	. 
	nop			;4d2f	00 	. 
	nop			;4d30	00 	. 
	nop			;4d31	00 	. 
	nop			;4d32	00 	. 
	nop			;4d33	00 	. 
	nop			;4d34	00 	. 
	nop			;4d35	00 	. 
	nop			;4d36	00 	. 
	nop			;4d37	00 	. 
	nop			;4d38	00 	. 
	nop			;4d39	00 	. 
	nop			;4d3a	00 	. 
	nop			;4d3b	00 	. 
	nop			;4d3c	00 	. 
	nop			;4d3d	00 	. 
	nop			;4d3e	00 	. 
	nop			;4d3f	00 	. 
	nop			;4d40	00 	. 
	nop			;4d41	00 	. 
	nop			;4d42	00 	. 
	nop			;4d43	00 	. 
	nop			;4d44	00 	. 
	nop			;4d45	00 	. 
	nop			;4d46	00 	. 
	nop			;4d47	00 	. 
	nop			;4d48	00 	. 
	nop			;4d49	00 	. 
	nop			;4d4a	00 	. 
	nop			;4d4b	00 	. 
	nop			;4d4c	00 	. 
	nop			;4d4d	00 	. 
	nop			;4d4e	00 	. 
	nop			;4d4f	00 	. 
	nop			;4d50	00 	. 
	nop			;4d51	00 	. 
	nop			;4d52	00 	. 
	nop			;4d53	00 	. 
	nop			;4d54	00 	. 
	nop			;4d55	00 	. 
	nop			;4d56	00 	. 
	nop			;4d57	00 	. 
	nop			;4d58	00 	. 
	nop			;4d59	00 	. 
	nop			;4d5a	00 	. 
	nop			;4d5b	00 	. 
	nop			;4d5c	00 	. 
	nop			;4d5d	00 	. 
	nop			;4d5e	00 	. 
	nop			;4d5f	00 	. 
	nop			;4d60	00 	. 
	nop			;4d61	00 	. 
	nop			;4d62	00 	. 
	nop			;4d63	00 	. 
	nop			;4d64	00 	. 
	nop			;4d65	00 	. 
	nop			;4d66	00 	. 
	nop			;4d67	00 	. 
	nop			;4d68	00 	. 
	nop			;4d69	00 	. 
	nop			;4d6a	00 	. 
	nop			;4d6b	00 	. 
	nop			;4d6c	00 	. 
	nop			;4d6d	00 	. 
	nop			;4d6e	00 	. 
	nop			;4d6f	00 	. 
	nop			;4d70	00 	. 
	nop			;4d71	00 	. 
	nop			;4d72	00 	. 
	nop			;4d73	00 	. 
	nop			;4d74	00 	. 
	nop			;4d75	00 	. 
	nop			;4d76	00 	. 
	nop			;4d77	00 	. 
	nop			;4d78	00 	. 
	nop			;4d79	00 	. 
	nop			;4d7a	00 	. 
	nop			;4d7b	00 	. 
	nop			;4d7c	00 	. 
	nop			;4d7d	00 	. 
	nop			;4d7e	00 	. 
	nop			;4d7f	00 	. 
	nop			;4d80	00 	. 
	nop			;4d81	00 	. 
	nop			;4d82	00 	. 
	nop			;4d83	00 	. 
	nop			;4d84	00 	. 
	nop			;4d85	00 	. 
	nop			;4d86	00 	. 
	nop			;4d87	00 	. 
	nop			;4d88	00 	. 
	nop			;4d89	00 	. 
	nop			;4d8a	00 	. 
	nop			;4d8b	00 	. 
	nop			;4d8c	00 	. 
	nop			;4d8d	00 	. 
	nop			;4d8e	00 	. 
	nop			;4d8f	00 	. 
	nop			;4d90	00 	. 
	nop			;4d91	00 	. 
	nop			;4d92	00 	. 
	nop			;4d93	00 	. 
	nop			;4d94	00 	. 
	nop			;4d95	00 	. 
	nop			;4d96	00 	. 
	nop			;4d97	00 	. 
	nop			;4d98	00 	. 
	nop			;4d99	00 	. 
	nop			;4d9a	00 	. 
	nop			;4d9b	00 	. 
	nop			;4d9c	00 	. 
	nop			;4d9d	00 	. 
	nop			;4d9e	00 	. 
	nop			;4d9f	00 	. 
	nop			;4da0	00 	. 
	nop			;4da1	00 	. 
	nop			;4da2	00 	. 
	nop			;4da3	00 	. 
	nop			;4da4	00 	. 
	nop			;4da5	00 	. 
	nop			;4da6	00 	. 
	nop			;4da7	00 	. 
	nop			;4da8	00 	. 
	nop			;4da9	00 	. 
	nop			;4daa	00 	. 
	nop			;4dab	00 	. 
	nop			;4dac	00 	. 
	nop			;4dad	00 	. 
	nop			;4dae	00 	. 
	nop			;4daf	00 	. 
	nop			;4db0	00 	. 
	nop			;4db1	00 	. 
	nop			;4db2	00 	. 
	nop			;4db3	00 	. 
	nop			;4db4	00 	. 
	nop			;4db5	00 	. 
	nop			;4db6	00 	. 
	nop			;4db7	00 	. 
	nop			;4db8	00 	. 
	nop			;4db9	00 	. 
	nop			;4dba	00 	. 
	nop			;4dbb	00 	. 
	nop			;4dbc	00 	. 
	nop			;4dbd	00 	. 
	nop			;4dbe	00 	. 
	nop			;4dbf	00 	. 
	nop			;4dc0	00 	. 
	nop			;4dc1	00 	. 
	nop			;4dc2	00 	. 
	nop			;4dc3	00 	. 
	nop			;4dc4	00 	. 
	nop			;4dc5	00 	. 
	nop			;4dc6	00 	. 
	nop			;4dc7	00 	. 
	nop			;4dc8	00 	. 
	nop			;4dc9	00 	. 
	nop			;4dca	00 	. 
	nop			;4dcb	00 	. 
	nop			;4dcc	00 	. 
	nop			;4dcd	00 	. 
	nop			;4dce	00 	. 
	nop			;4dcf	00 	. 
	nop			;4dd0	00 	. 
	nop			;4dd1	00 	. 
	nop			;4dd2	00 	. 
	nop			;4dd3	00 	. 
	nop			;4dd4	00 	. 
	nop			;4dd5	00 	. 
	nop			;4dd6	00 	. 
	nop			;4dd7	00 	. 
	nop			;4dd8	00 	. 
	nop			;4dd9	00 	. 
	nop			;4dda	00 	. 
	nop			;4ddb	00 	. 
	nop			;4ddc	00 	. 
	nop			;4ddd	00 	. 
	nop			;4dde	00 	. 
	nop			;4ddf	00 	. 
	nop			;4de0	00 	. 
	nop			;4de1	00 	. 
	nop			;4de2	00 	. 
	nop			;4de3	00 	. 
	nop			;4de4	00 	. 
	nop			;4de5	00 	. 
	nop			;4de6	00 	. 
	nop			;4de7	00 	. 
	nop			;4de8	00 	. 
	nop			;4de9	00 	. 
	nop			;4dea	00 	. 
	nop			;4deb	00 	. 
	nop			;4dec	00 	. 
	nop			;4ded	00 	. 
	nop			;4dee	00 	. 
	nop			;4def	00 	. 
	nop			;4df0	00 	. 
	nop			;4df1	00 	. 
	nop			;4df2	00 	. 
	nop			;4df3	00 	. 
	nop			;4df4	00 	. 
	nop			;4df5	00 	. 
	nop			;4df6	00 	. 
	nop			;4df7	00 	. 
	nop			;4df8	00 	. 
	nop			;4df9	00 	. 
	nop			;4dfa	00 	. 
	nop			;4dfb	00 	. 
	nop			;4dfc	00 	. 
	nop			;4dfd	00 	. 
	nop			;4dfe	00 	. 
	nop			;4dff	00 	. 
	nop			;4e00	00 	. 
	nop			;4e01	00 	. 
	nop			;4e02	00 	. 
	nop			;4e03	00 	. 
	nop			;4e04	00 	. 
	nop			;4e05	00 	. 
	nop			;4e06	00 	. 
	nop			;4e07	00 	. 
	nop			;4e08	00 	. 
	nop			;4e09	00 	. 
	nop			;4e0a	00 	. 
	nop			;4e0b	00 	. 
	nop			;4e0c	00 	. 
	nop			;4e0d	00 	. 
	nop			;4e0e	00 	. 
	nop			;4e0f	00 	. 
	nop			;4e10	00 	. 
	nop			;4e11	00 	. 
	nop			;4e12	00 	. 
	nop			;4e13	00 	. 
	nop			;4e14	00 	. 
	nop			;4e15	00 	. 
	nop			;4e16	00 	. 
	nop			;4e17	00 	. 
	nop			;4e18	00 	. 
	nop			;4e19	00 	. 
	nop			;4e1a	00 	. 
	nop			;4e1b	00 	. 
	nop			;4e1c	00 	. 
	nop			;4e1d	00 	. 
	nop			;4e1e	00 	. 
	nop			;4e1f	00 	. 
	nop			;4e20	00 	. 
	nop			;4e21	00 	. 
	nop			;4e22	00 	. 
	nop			;4e23	00 	. 
	nop			;4e24	00 	. 
	nop			;4e25	00 	. 
	nop			;4e26	00 	. 
	nop			;4e27	00 	. 
	nop			;4e28	00 	. 
	nop			;4e29	00 	. 
	nop			;4e2a	00 	. 
	nop			;4e2b	00 	. 
	nop			;4e2c	00 	. 
	nop			;4e2d	00 	. 
	nop			;4e2e	00 	. 
	nop			;4e2f	00 	. 
	nop			;4e30	00 	. 
	nop			;4e31	00 	. 
	nop			;4e32	00 	. 
	nop			;4e33	00 	. 
	nop			;4e34	00 	. 
	nop			;4e35	00 	. 
	nop			;4e36	00 	. 
	nop			;4e37	00 	. 
	nop			;4e38	00 	. 
	nop			;4e39	00 	. 
	nop			;4e3a	00 	. 
	nop			;4e3b	00 	. 
	nop			;4e3c	00 	. 
	nop			;4e3d	00 	. 
	nop			;4e3e	00 	. 
	nop			;4e3f	00 	. 
	nop			;4e40	00 	. 
	nop			;4e41	00 	. 
	nop			;4e42	00 	. 
	nop			;4e43	00 	. 
	nop			;4e44	00 	. 
	nop			;4e45	00 	. 
	nop			;4e46	00 	. 
	nop			;4e47	00 	. 
	nop			;4e48	00 	. 
	nop			;4e49	00 	. 
	nop			;4e4a	00 	. 
	nop			;4e4b	00 	. 
	nop			;4e4c	00 	. 
	nop			;4e4d	00 	. 
	nop			;4e4e	00 	. 
	nop			;4e4f	00 	. 
	nop			;4e50	00 	. 
	nop			;4e51	00 	. 
	nop			;4e52	00 	. 
	nop			;4e53	00 	. 
	nop			;4e54	00 	. 
	nop			;4e55	00 	. 
	nop			;4e56	00 	. 
	nop			;4e57	00 	. 
	nop			;4e58	00 	. 
	nop			;4e59	00 	. 
	nop			;4e5a	00 	. 
	nop			;4e5b	00 	. 
	nop			;4e5c	00 	. 
	nop			;4e5d	00 	. 
	nop			;4e5e	00 	. 
	nop			;4e5f	00 	. 
	nop			;4e60	00 	. 
	nop			;4e61	00 	. 
	nop			;4e62	00 	. 
	nop			;4e63	00 	. 
	nop			;4e64	00 	. 
	nop			;4e65	00 	. 
	nop			;4e66	00 	. 
	nop			;4e67	00 	. 
	nop			;4e68	00 	. 
	nop			;4e69	00 	. 
	nop			;4e6a	00 	. 
	nop			;4e6b	00 	. 
	nop			;4e6c	00 	. 
	nop			;4e6d	00 	. 
	nop			;4e6e	00 	. 
	nop			;4e6f	00 	. 
	nop			;4e70	00 	. 
	nop			;4e71	00 	. 
	nop			;4e72	00 	. 
	nop			;4e73	00 	. 
	nop			;4e74	00 	. 
	nop			;4e75	00 	. 
	nop			;4e76	00 	. 
	nop			;4e77	00 	. 
	nop			;4e78	00 	. 
	nop			;4e79	00 	. 
	nop			;4e7a	00 	. 
	nop			;4e7b	00 	. 
	nop			;4e7c	00 	. 
	nop			;4e7d	00 	. 
	nop			;4e7e	00 	. 
	nop			;4e7f	00 	. 
	nop			;4e80	00 	. 
	nop			;4e81	00 	. 
	nop			;4e82	00 	. 
	nop			;4e83	00 	. 
	nop			;4e84	00 	. 
	nop			;4e85	00 	. 
	nop			;4e86	00 	. 
	nop			;4e87	00 	. 
	nop			;4e88	00 	. 
	nop			;4e89	00 	. 
	nop			;4e8a	00 	. 
	nop			;4e8b	00 	. 
	nop			;4e8c	00 	. 
	nop			;4e8d	00 	. 
	nop			;4e8e	00 	. 
	nop			;4e8f	00 	. 
	nop			;4e90	00 	. 
	nop			;4e91	00 	. 
	nop			;4e92	00 	. 
	nop			;4e93	00 	. 
	nop			;4e94	00 	. 
	nop			;4e95	00 	. 
	nop			;4e96	00 	. 
	nop			;4e97	00 	. 
	nop			;4e98	00 	. 
	nop			;4e99	00 	. 
	nop			;4e9a	00 	. 
	nop			;4e9b	00 	. 
	nop			;4e9c	00 	. 
	nop			;4e9d	00 	. 
	nop			;4e9e	00 	. 
	nop			;4e9f	00 	. 
	nop			;4ea0	00 	. 
	nop			;4ea1	00 	. 
	nop			;4ea2	00 	. 
	nop			;4ea3	00 	. 
	nop			;4ea4	00 	. 
	nop			;4ea5	00 	. 
	nop			;4ea6	00 	. 
	nop			;4ea7	00 	. 
	nop			;4ea8	00 	. 
	nop			;4ea9	00 	. 
	nop			;4eaa	00 	. 
	nop			;4eab	00 	. 
	nop			;4eac	00 	. 
	nop			;4ead	00 	. 
	nop			;4eae	00 	. 
	nop			;4eaf	00 	. 
	nop			;4eb0	00 	. 
	nop			;4eb1	00 	. 
	nop			;4eb2	00 	. 
	nop			;4eb3	00 	. 
	nop			;4eb4	00 	. 
	nop			;4eb5	00 	. 
	nop			;4eb6	00 	. 
	nop			;4eb7	00 	. 
	nop			;4eb8	00 	. 
	nop			;4eb9	00 	. 
	nop			;4eba	00 	. 
	nop			;4ebb	00 	. 
	nop			;4ebc	00 	. 
	nop			;4ebd	00 	. 
	nop			;4ebe	00 	. 
	nop			;4ebf	00 	. 
	nop			;4ec0	00 	. 
	nop			;4ec1	00 	. 
	nop			;4ec2	00 	. 
	nop			;4ec3	00 	. 
	nop			;4ec4	00 	. 
	nop			;4ec5	00 	. 
	nop			;4ec6	00 	. 
	nop			;4ec7	00 	. 
	nop			;4ec8	00 	. 
	nop			;4ec9	00 	. 
	nop			;4eca	00 	. 
	nop			;4ecb	00 	. 
	nop			;4ecc	00 	. 
	nop			;4ecd	00 	. 
	nop			;4ece	00 	. 
	nop			;4ecf	00 	. 
	nop			;4ed0	00 	. 
	nop			;4ed1	00 	. 
	nop			;4ed2	00 	. 
	nop			;4ed3	00 	. 
	nop			;4ed4	00 	. 
	nop			;4ed5	00 	. 
	nop			;4ed6	00 	. 
	nop			;4ed7	00 	. 
	nop			;4ed8	00 	. 
	nop			;4ed9	00 	. 
	nop			;4eda	00 	. 
	nop			;4edb	00 	. 
	nop			;4edc	00 	. 
	nop			;4edd	00 	. 
	nop			;4ede	00 	. 
	nop			;4edf	00 	. 
	nop			;4ee0	00 	. 
	nop			;4ee1	00 	. 
	nop			;4ee2	00 	. 
	nop			;4ee3	00 	. 
	nop			;4ee4	00 	. 
	nop			;4ee5	00 	. 
	nop			;4ee6	00 	. 
	nop			;4ee7	00 	. 
	nop			;4ee8	00 	. 
	nop			;4ee9	00 	. 
	nop			;4eea	00 	. 
	nop			;4eeb	00 	. 
	nop			;4eec	00 	. 
	nop			;4eed	00 	. 
	nop			;4eee	00 	. 
	nop			;4eef	00 	. 
	nop			;4ef0	00 	. 
	nop			;4ef1	00 	. 
	nop			;4ef2	00 	. 
	nop			;4ef3	00 	. 
	nop			;4ef4	00 	. 
	nop			;4ef5	00 	. 
	nop			;4ef6	00 	. 
	nop			;4ef7	00 	. 
	nop			;4ef8	00 	. 
	nop			;4ef9	00 	. 
	nop			;4efa	00 	. 
	nop			;4efb	00 	. 
	nop			;4efc	00 	. 
	nop			;4efd	00 	. 
	nop			;4efe	00 	. 
	nop			;4eff	00 	. 
	nop			;4f00	00 	. 
	nop			;4f01	00 	. 
	nop			;4f02	00 	. 
	nop			;4f03	00 	. 
	nop			;4f04	00 	. 
	nop			;4f05	00 	. 
	nop			;4f06	00 	. 
	nop			;4f07	00 	. 
	nop			;4f08	00 	. 
	nop			;4f09	00 	. 
	nop			;4f0a	00 	. 
	nop			;4f0b	00 	. 
	nop			;4f0c	00 	. 
	nop			;4f0d	00 	. 
	nop			;4f0e	00 	. 
	nop			;4f0f	00 	. 
	nop			;4f10	00 	. 
	nop			;4f11	00 	. 
	nop			;4f12	00 	. 
	nop			;4f13	00 	. 
	nop			;4f14	00 	. 
	nop			;4f15	00 	. 
	nop			;4f16	00 	. 
	nop			;4f17	00 	. 
	nop			;4f18	00 	. 
	nop			;4f19	00 	. 
	nop			;4f1a	00 	. 
	nop			;4f1b	00 	. 
	nop			;4f1c	00 	. 
	nop			;4f1d	00 	. 
	nop			;4f1e	00 	. 
	nop			;4f1f	00 	. 
	nop			;4f20	00 	. 
	nop			;4f21	00 	. 
	nop			;4f22	00 	. 
	nop			;4f23	00 	. 
	nop			;4f24	00 	. 
	nop			;4f25	00 	. 
	nop			;4f26	00 	. 
	nop			;4f27	00 	. 
	nop			;4f28	00 	. 
	nop			;4f29	00 	. 
	nop			;4f2a	00 	. 
	nop			;4f2b	00 	. 
	nop			;4f2c	00 	. 
	nop			;4f2d	00 	. 
	nop			;4f2e	00 	. 
	nop			;4f2f	00 	. 
	nop			;4f30	00 	. 
	nop			;4f31	00 	. 
	nop			;4f32	00 	. 
	nop			;4f33	00 	. 
	nop			;4f34	00 	. 
	nop			;4f35	00 	. 
	nop			;4f36	00 	. 
	nop			;4f37	00 	. 
	nop			;4f38	00 	. 
	nop			;4f39	00 	. 
	nop			;4f3a	00 	. 
	nop			;4f3b	00 	. 
	nop			;4f3c	00 	. 
	nop			;4f3d	00 	. 
	nop			;4f3e	00 	. 
	nop			;4f3f	00 	. 
	nop			;4f40	00 	. 
	nop			;4f41	00 	. 
	nop			;4f42	00 	. 
	nop			;4f43	00 	. 
	nop			;4f44	00 	. 
	nop			;4f45	00 	. 
	nop			;4f46	00 	. 
	nop			;4f47	00 	. 
	nop			;4f48	00 	. 
	nop			;4f49	00 	. 
	nop			;4f4a	00 	. 
	nop			;4f4b	00 	. 
	nop			;4f4c	00 	. 
	nop			;4f4d	00 	. 
	nop			;4f4e	00 	. 
	nop			;4f4f	00 	. 
	nop			;4f50	00 	. 
	nop			;4f51	00 	. 
	nop			;4f52	00 	. 
	nop			;4f53	00 	. 
	nop			;4f54	00 	. 
	nop			;4f55	00 	. 
	nop			;4f56	00 	. 
	nop			;4f57	00 	. 
	nop			;4f58	00 	. 
	nop			;4f59	00 	. 
	nop			;4f5a	00 	. 
	nop			;4f5b	00 	. 
	nop			;4f5c	00 	. 
	nop			;4f5d	00 	. 
	nop			;4f5e	00 	. 
	nop			;4f5f	00 	. 
	nop			;4f60	00 	. 
	nop			;4f61	00 	. 
	nop			;4f62	00 	. 
	nop			;4f63	00 	. 
	nop			;4f64	00 	. 
	nop			;4f65	00 	. 
	nop			;4f66	00 	. 
	nop			;4f67	00 	. 
	nop			;4f68	00 	. 
	nop			;4f69	00 	. 
	nop			;4f6a	00 	. 
	nop			;4f6b	00 	. 
	nop			;4f6c	00 	. 
	nop			;4f6d	00 	. 
	nop			;4f6e	00 	. 
	nop			;4f6f	00 	. 
	nop			;4f70	00 	. 
	nop			;4f71	00 	. 
	nop			;4f72	00 	. 
	nop			;4f73	00 	. 
	nop			;4f74	00 	. 
	nop			;4f75	00 	. 
	nop			;4f76	00 	. 
	nop			;4f77	00 	. 
	nop			;4f78	00 	. 
	nop			;4f79	00 	. 
	nop			;4f7a	00 	. 
	nop			;4f7b	00 	. 
	nop			;4f7c	00 	. 
	nop			;4f7d	00 	. 
	nop			;4f7e	00 	. 
	nop			;4f7f	00 	. 
	nop			;4f80	00 	. 
	nop			;4f81	00 	. 
	nop			;4f82	00 	. 
	nop			;4f83	00 	. 
	nop			;4f84	00 	. 
	nop			;4f85	00 	. 
	nop			;4f86	00 	. 
	nop			;4f87	00 	. 
	nop			;4f88	00 	. 
	nop			;4f89	00 	. 
	nop			;4f8a	00 	. 
	nop			;4f8b	00 	. 
	nop			;4f8c	00 	. 
	nop			;4f8d	00 	. 
	nop			;4f8e	00 	. 
	nop			;4f8f	00 	. 
	nop			;4f90	00 	. 
	nop			;4f91	00 	. 
	nop			;4f92	00 	. 
	nop			;4f93	00 	. 
	nop			;4f94	00 	. 
	nop			;4f95	00 	. 
	nop			;4f96	00 	. 
	nop			;4f97	00 	. 
	nop			;4f98	00 	. 
	nop			;4f99	00 	. 
	nop			;4f9a	00 	. 
	nop			;4f9b	00 	. 
	nop			;4f9c	00 	. 
	nop			;4f9d	00 	. 
	nop			;4f9e	00 	. 
	nop			;4f9f	00 	. 
	nop			;4fa0	00 	. 
	nop			;4fa1	00 	. 
	nop			;4fa2	00 	. 
	nop			;4fa3	00 	. 
	nop			;4fa4	00 	. 
	nop			;4fa5	00 	. 
	nop			;4fa6	00 	. 
	nop			;4fa7	00 	. 
	nop			;4fa8	00 	. 
	nop			;4fa9	00 	. 
	nop			;4faa	00 	. 
	nop			;4fab	00 	. 
	nop			;4fac	00 	. 
	nop			;4fad	00 	. 
	nop			;4fae	00 	. 
	nop			;4faf	00 	. 
	nop			;4fb0	00 	. 
	nop			;4fb1	00 	. 
	nop			;4fb2	00 	. 
	nop			;4fb3	00 	. 
	nop			;4fb4	00 	. 
	nop			;4fb5	00 	. 
	nop			;4fb6	00 	. 
	nop			;4fb7	00 	. 
	nop			;4fb8	00 	. 
	nop			;4fb9	00 	. 
	nop			;4fba	00 	. 
	nop			;4fbb	00 	. 
	nop			;4fbc	00 	. 
	nop			;4fbd	00 	. 
	nop			;4fbe	00 	. 
	nop			;4fbf	00 	. 
	nop			;4fc0	00 	. 
	nop			;4fc1	00 	. 
	nop			;4fc2	00 	. 
	nop			;4fc3	00 	. 
	nop			;4fc4	00 	. 
	nop			;4fc5	00 	. 
	nop			;4fc6	00 	. 
	nop			;4fc7	00 	. 
	nop			;4fc8	00 	. 
	nop			;4fc9	00 	. 
	nop			;4fca	00 	. 
	nop			;4fcb	00 	. 
	nop			;4fcc	00 	. 
	nop			;4fcd	00 	. 
	nop			;4fce	00 	. 
	nop			;4fcf	00 	. 
	nop			;4fd0	00 	. 
	nop			;4fd1	00 	. 
	nop			;4fd2	00 	. 
	nop			;4fd3	00 	. 
	nop			;4fd4	00 	. 
	nop			;4fd5	00 	. 
	nop			;4fd6	00 	. 
	nop			;4fd7	00 	. 
	nop			;4fd8	00 	. 
	nop			;4fd9	00 	. 
	nop			;4fda	00 	. 
	nop			;4fdb	00 	. 
	nop			;4fdc	00 	. 
	nop			;4fdd	00 	. 
	nop			;4fde	00 	. 
	nop			;4fdf	00 	. 
	nop			;4fe0	00 	. 
	nop			;4fe1	00 	. 
	nop			;4fe2	00 	. 
	nop			;4fe3	00 	. 
	nop			;4fe4	00 	. 
	nop			;4fe5	00 	. 
	nop			;4fe6	00 	. 
	nop			;4fe7	00 	. 
	nop			;4fe8	00 	. 
	nop			;4fe9	00 	. 
	nop			;4fea	00 	. 
	nop			;4feb	00 	. 
	nop			;4fec	00 	. 
	nop			;4fed	00 	. 
	nop			;4fee	00 	. 
	nop			;4fef	00 	. 
	nop			;4ff0	00 	. 
	nop			;4ff1	00 	. 
	nop			;4ff2	00 	. 
	nop			;4ff3	00 	. 
	nop			;4ff4	00 	. 
	nop			;4ff5	00 	. 
	nop			;4ff6	00 	. 
	nop			;4ff7	00 	. 
	nop			;4ff8	00 	. 
	nop			;4ff9	00 	. 
	nop			;4ffa	00 	. 
	nop			;4ffb	00 	. 
	nop			;4ffc	00 	. 
	nop			;4ffd	00 	. 
	nop			;4ffe	00 	. 
	nop			;4fff	00 	. 
	nop			;5000	00 	. 
	nop			;5001	00 	. 
	nop			;5002	00 	. 
	nop			;5003	00 	. 
	nop			;5004	00 	. 
	nop			;5005	00 	. 
	nop			;5006	00 	. 
	nop			;5007	00 	. 
	nop			;5008	00 	. 
	nop			;5009	00 	. 
	nop			;500a	00 	. 
	nop			;500b	00 	. 
	nop			;500c	00 	. 
	nop			;500d	00 	. 
	nop			;500e	00 	. 
	nop			;500f	00 	. 
	nop			;5010	00 	. 
	nop			;5011	00 	. 
	nop			;5012	00 	. 
	nop			;5013	00 	. 
	nop			;5014	00 	. 
	nop			;5015	00 	. 
	nop			;5016	00 	. 
	nop			;5017	00 	. 
	nop			;5018	00 	. 
	nop			;5019	00 	. 
	nop			;501a	00 	. 
	nop			;501b	00 	. 
	nop			;501c	00 	. 
	nop			;501d	00 	. 
	nop			;501e	00 	. 
	nop			;501f	00 	. 
	nop			;5020	00 	. 
	nop			;5021	00 	. 
	nop			;5022	00 	. 
	nop			;5023	00 	. 
	nop			;5024	00 	. 
	nop			;5025	00 	. 
	nop			;5026	00 	. 
	nop			;5027	00 	. 
	nop			;5028	00 	. 
	nop			;5029	00 	. 
	nop			;502a	00 	. 
	nop			;502b	00 	. 
	nop			;502c	00 	. 
	nop			;502d	00 	. 
	nop			;502e	00 	. 
	nop			;502f	00 	. 
	nop			;5030	00 	. 
	nop			;5031	00 	. 
	nop			;5032	00 	. 
	nop			;5033	00 	. 
	nop			;5034	00 	. 
	nop			;5035	00 	. 
	nop			;5036	00 	. 
	nop			;5037	00 	. 
	nop			;5038	00 	. 
	nop			;5039	00 	. 
	nop			;503a	00 	. 
	nop			;503b	00 	. 
	nop			;503c	00 	. 
	nop			;503d	00 	. 
	nop			;503e	00 	. 
	nop			;503f	00 	. 
	nop			;5040	00 	. 
	nop			;5041	00 	. 
	nop			;5042	00 	. 
	nop			;5043	00 	. 
	nop			;5044	00 	. 
	nop			;5045	00 	. 
	nop			;5046	00 	. 
	nop			;5047	00 	. 
	nop			;5048	00 	. 
	nop			;5049	00 	. 
	nop			;504a	00 	. 
	nop			;504b	00 	. 
	nop			;504c	00 	. 
	nop			;504d	00 	. 
	nop			;504e	00 	. 
	nop			;504f	00 	. 
	nop			;5050	00 	. 
	nop			;5051	00 	. 
	nop			;5052	00 	. 
	nop			;5053	00 	. 
	nop			;5054	00 	. 
	nop			;5055	00 	. 
	nop			;5056	00 	. 
	nop			;5057	00 	. 
	nop			;5058	00 	. 
	nop			;5059	00 	. 
	nop			;505a	00 	. 
	nop			;505b	00 	. 
	nop			;505c	00 	. 
	nop			;505d	00 	. 
	nop			;505e	00 	. 
	nop			;505f	00 	. 
	nop			;5060	00 	. 
	nop			;5061	00 	. 
	nop			;5062	00 	. 
	nop			;5063	00 	. 
	nop			;5064	00 	. 
	nop			;5065	00 	. 
	nop			;5066	00 	. 
	nop			;5067	00 	. 
	nop			;5068	00 	. 
	nop			;5069	00 	. 
	nop			;506a	00 	. 
	nop			;506b	00 	. 
	nop			;506c	00 	. 
	nop			;506d	00 	. 
	nop			;506e	00 	. 
	nop			;506f	00 	. 
	nop			;5070	00 	. 
	nop			;5071	00 	. 
	nop			;5072	00 	. 
	nop			;5073	00 	. 
	nop			;5074	00 	. 
	nop			;5075	00 	. 
	nop			;5076	00 	. 
	nop			;5077	00 	. 
	nop			;5078	00 	. 
	nop			;5079	00 	. 
	nop			;507a	00 	. 
	nop			;507b	00 	. 
	nop			;507c	00 	. 
	nop			;507d	00 	. 
	nop			;507e	00 	. 
	nop			;507f	00 	. 
	nop			;5080	00 	. 
	nop			;5081	00 	. 
	nop			;5082	00 	. 
	nop			;5083	00 	. 
	nop			;5084	00 	. 
	nop			;5085	00 	. 
	nop			;5086	00 	. 
	nop			;5087	00 	. 
	nop			;5088	00 	. 
	nop			;5089	00 	. 
	nop			;508a	00 	. 
	nop			;508b	00 	. 
	nop			;508c	00 	. 
	nop			;508d	00 	. 
	nop			;508e	00 	. 
	nop			;508f	00 	. 
	nop			;5090	00 	. 
	nop			;5091	00 	. 
	nop			;5092	00 	. 
	nop			;5093	00 	. 
	nop			;5094	00 	. 
	nop			;5095	00 	. 
	nop			;5096	00 	. 
	nop			;5097	00 	. 
	nop			;5098	00 	. 
	nop			;5099	00 	. 
	nop			;509a	00 	. 
	nop			;509b	00 	. 
	nop			;509c	00 	. 
	nop			;509d	00 	. 
	nop			;509e	00 	. 
	nop			;509f	00 	. 
	nop			;50a0	00 	. 
	nop			;50a1	00 	. 
	nop			;50a2	00 	. 
	nop			;50a3	00 	. 
	nop			;50a4	00 	. 
	nop			;50a5	00 	. 
	nop			;50a6	00 	. 
	nop			;50a7	00 	. 
	nop			;50a8	00 	. 
	nop			;50a9	00 	. 
	nop			;50aa	00 	. 
	nop			;50ab	00 	. 
	nop			;50ac	00 	. 
	nop			;50ad	00 	. 
	nop			;50ae	00 	. 
	nop			;50af	00 	. 
	nop			;50b0	00 	. 
	nop			;50b1	00 	. 
	nop			;50b2	00 	. 
	nop			;50b3	00 	. 
	nop			;50b4	00 	. 
	nop			;50b5	00 	. 
	nop			;50b6	00 	. 
	nop			;50b7	00 	. 
	nop			;50b8	00 	. 
	nop			;50b9	00 	. 
	nop			;50ba	00 	. 
	nop			;50bb	00 	. 
	nop			;50bc	00 	. 
	nop			;50bd	00 	. 
	nop			;50be	00 	. 
	nop			;50bf	00 	. 
	nop			;50c0	00 	. 
	nop			;50c1	00 	. 
	nop			;50c2	00 	. 
	nop			;50c3	00 	. 
	nop			;50c4	00 	. 
	nop			;50c5	00 	. 
	nop			;50c6	00 	. 
	nop			;50c7	00 	. 
	nop			;50c8	00 	. 
	nop			;50c9	00 	. 
	nop			;50ca	00 	. 
	nop			;50cb	00 	. 
	nop			;50cc	00 	. 
	nop			;50cd	00 	. 
	nop			;50ce	00 	. 
	nop			;50cf	00 	. 
	nop			;50d0	00 	. 
	nop			;50d1	00 	. 
	nop			;50d2	00 	. 
	nop			;50d3	00 	. 
	nop			;50d4	00 	. 
	nop			;50d5	00 	. 
	nop			;50d6	00 	. 
	nop			;50d7	00 	. 
	nop			;50d8	00 	. 
	nop			;50d9	00 	. 
	nop			;50da	00 	. 
	nop			;50db	00 	. 
	nop			;50dc	00 	. 
	nop			;50dd	00 	. 
	nop			;50de	00 	. 
	nop			;50df	00 	. 
	nop			;50e0	00 	. 
	nop			;50e1	00 	. 
	nop			;50e2	00 	. 
	nop			;50e3	00 	. 
	nop			;50e4	00 	. 
	nop			;50e5	00 	. 
	nop			;50e6	00 	. 
	nop			;50e7	00 	. 
	nop			;50e8	00 	. 
	nop			;50e9	00 	. 
	nop			;50ea	00 	. 
	nop			;50eb	00 	. 
	nop			;50ec	00 	. 
	nop			;50ed	00 	. 
	nop			;50ee	00 	. 
	nop			;50ef	00 	. 
	nop			;50f0	00 	. 
	nop			;50f1	00 	. 
	nop			;50f2	00 	. 
	nop			;50f3	00 	. 
	nop			;50f4	00 	. 
	nop			;50f5	00 	. 
	nop			;50f6	00 	. 
	nop			;50f7	00 	. 
	nop			;50f8	00 	. 
	nop			;50f9	00 	. 
	nop			;50fa	00 	. 
	nop			;50fb	00 	. 
	nop			;50fc	00 	. 
	nop			;50fd	00 	. 
	nop			;50fe	00 	. 
	nop			;50ff	00 	. 
	nop			;5100	00 	. 
	nop			;5101	00 	. 
	nop			;5102	00 	. 
	nop			;5103	00 	. 
	nop			;5104	00 	. 
	nop			;5105	00 	. 
	nop			;5106	00 	. 
	nop			;5107	00 	. 
	nop			;5108	00 	. 
	nop			;5109	00 	. 
	nop			;510a	00 	. 
	nop			;510b	00 	. 
	nop			;510c	00 	. 
	nop			;510d	00 	. 
	nop			;510e	00 	. 
	nop			;510f	00 	. 
	nop			;5110	00 	. 
	nop			;5111	00 	. 
	nop			;5112	00 	. 
	nop			;5113	00 	. 
	nop			;5114	00 	. 
	nop			;5115	00 	. 
	nop			;5116	00 	. 
	nop			;5117	00 	. 
	nop			;5118	00 	. 
	nop			;5119	00 	. 
	nop			;511a	00 	. 
	nop			;511b	00 	. 
	nop			;511c	00 	. 
	nop			;511d	00 	. 
	nop			;511e	00 	. 
	nop			;511f	00 	. 
	nop			;5120	00 	. 
	nop			;5121	00 	. 
	nop			;5122	00 	. 
	nop			;5123	00 	. 
	nop			;5124	00 	. 
	nop			;5125	00 	. 
	nop			;5126	00 	. 
	nop			;5127	00 	. 
	nop			;5128	00 	. 
	nop			;5129	00 	. 
	nop			;512a	00 	. 
	nop			;512b	00 	. 
	nop			;512c	00 	. 
	nop			;512d	00 	. 
	nop			;512e	00 	. 
	nop			;512f	00 	. 
	nop			;5130	00 	. 
	nop			;5131	00 	. 
	nop			;5132	00 	. 
	nop			;5133	00 	. 
	nop			;5134	00 	. 
	nop			;5135	00 	. 
	nop			;5136	00 	. 
	nop			;5137	00 	. 
	nop			;5138	00 	. 
	nop			;5139	00 	. 
	nop			;513a	00 	. 
	nop			;513b	00 	. 
	nop			;513c	00 	. 
	nop			;513d	00 	. 
	nop			;513e	00 	. 
	nop			;513f	00 	. 
	nop			;5140	00 	. 
	nop			;5141	00 	. 
	nop			;5142	00 	. 
	nop			;5143	00 	. 
	nop			;5144	00 	. 
	nop			;5145	00 	. 
	nop			;5146	00 	. 
	nop			;5147	00 	. 
	nop			;5148	00 	. 
	nop			;5149	00 	. 
	nop			;514a	00 	. 
	nop			;514b	00 	. 
	nop			;514c	00 	. 
	nop			;514d	00 	. 
	nop			;514e	00 	. 
	nop			;514f	00 	. 
	nop			;5150	00 	. 
	nop			;5151	00 	. 
	nop			;5152	00 	. 
	nop			;5153	00 	. 
	nop			;5154	00 	. 
	nop			;5155	00 	. 
	nop			;5156	00 	. 
	nop			;5157	00 	. 
	nop			;5158	00 	. 
	nop			;5159	00 	. 
	nop			;515a	00 	. 
	nop			;515b	00 	. 
	nop			;515c	00 	. 
	nop			;515d	00 	. 
	nop			;515e	00 	. 
	nop			;515f	00 	. 
	nop			;5160	00 	. 
	nop			;5161	00 	. 
	nop			;5162	00 	. 
	nop			;5163	00 	. 
	nop			;5164	00 	. 
	nop			;5165	00 	. 
	nop			;5166	00 	. 
	nop			;5167	00 	. 
	nop			;5168	00 	. 
	nop			;5169	00 	. 
	nop			;516a	00 	. 
	nop			;516b	00 	. 
	nop			;516c	00 	. 
	nop			;516d	00 	. 
	nop			;516e	00 	. 
	nop			;516f	00 	. 
	nop			;5170	00 	. 
	nop			;5171	00 	. 
	nop			;5172	00 	. 
	nop			;5173	00 	. 
	nop			;5174	00 	. 
	nop			;5175	00 	. 
	nop			;5176	00 	. 
	nop			;5177	00 	. 
	nop			;5178	00 	. 
	nop			;5179	00 	. 
	nop			;517a	00 	. 
	nop			;517b	00 	. 
	nop			;517c	00 	. 
	nop			;517d	00 	. 
	nop			;517e	00 	. 
	nop			;517f	00 	. 
	nop			;5180	00 	. 
	nop			;5181	00 	. 
	nop			;5182	00 	. 
	nop			;5183	00 	. 
	nop			;5184	00 	. 
	nop			;5185	00 	. 
	nop			;5186	00 	. 
	nop			;5187	00 	. 
	nop			;5188	00 	. 
	nop			;5189	00 	. 
	nop			;518a	00 	. 
	nop			;518b	00 	. 
	nop			;518c	00 	. 
	nop			;518d	00 	. 
	nop			;518e	00 	. 
	nop			;518f	00 	. 
	nop			;5190	00 	. 
	nop			;5191	00 	. 
	nop			;5192	00 	. 
	nop			;5193	00 	. 
	nop			;5194	00 	. 
	nop			;5195	00 	. 
	nop			;5196	00 	. 
	nop			;5197	00 	. 
	nop			;5198	00 	. 
	nop			;5199	00 	. 
	nop			;519a	00 	. 
	nop			;519b	00 	. 
	nop			;519c	00 	. 
	nop			;519d	00 	. 
	nop			;519e	00 	. 
	nop			;519f	00 	. 
	nop			;51a0	00 	. 
	nop			;51a1	00 	. 
	nop			;51a2	00 	. 
	nop			;51a3	00 	. 
	nop			;51a4	00 	. 
	nop			;51a5	00 	. 
	nop			;51a6	00 	. 
	nop			;51a7	00 	. 
	nop			;51a8	00 	. 
	nop			;51a9	00 	. 
	nop			;51aa	00 	. 
	nop			;51ab	00 	. 
	nop			;51ac	00 	. 
	nop			;51ad	00 	. 
	nop			;51ae	00 	. 
	nop			;51af	00 	. 
	nop			;51b0	00 	. 
	nop			;51b1	00 	. 
	nop			;51b2	00 	. 
	nop			;51b3	00 	. 
	nop			;51b4	00 	. 
	nop			;51b5	00 	. 
	nop			;51b6	00 	. 
	nop			;51b7	00 	. 
	nop			;51b8	00 	. 
	nop			;51b9	00 	. 
	nop			;51ba	00 	. 
	nop			;51bb	00 	. 
	nop			;51bc	00 	. 
	nop			;51bd	00 	. 
	nop			;51be	00 	. 
	nop			;51bf	00 	. 
	nop			;51c0	00 	. 
	nop			;51c1	00 	. 
	nop			;51c2	00 	. 
	nop			;51c3	00 	. 
	nop			;51c4	00 	. 
	nop			;51c5	00 	. 
	nop			;51c6	00 	. 
	nop			;51c7	00 	. 
	nop			;51c8	00 	. 
	nop			;51c9	00 	. 
	nop			;51ca	00 	. 
	nop			;51cb	00 	. 
	nop			;51cc	00 	. 
	nop			;51cd	00 	. 
	nop			;51ce	00 	. 
	nop			;51cf	00 	. 
	nop			;51d0	00 	. 
	nop			;51d1	00 	. 
	nop			;51d2	00 	. 
	nop			;51d3	00 	. 
	nop			;51d4	00 	. 
	nop			;51d5	00 	. 
	nop			;51d6	00 	. 
	nop			;51d7	00 	. 
	nop			;51d8	00 	. 
	nop			;51d9	00 	. 
	nop			;51da	00 	. 
	nop			;51db	00 	. 
	nop			;51dc	00 	. 
	nop			;51dd	00 	. 
	nop			;51de	00 	. 
	nop			;51df	00 	. 
	nop			;51e0	00 	. 
	nop			;51e1	00 	. 
	nop			;51e2	00 	. 
	nop			;51e3	00 	. 
	nop			;51e4	00 	. 
	nop			;51e5	00 	. 
	nop			;51e6	00 	. 
	nop			;51e7	00 	. 
	nop			;51e8	00 	. 
	nop			;51e9	00 	. 
	nop			;51ea	00 	. 
	nop			;51eb	00 	. 
	nop			;51ec	00 	. 
	nop			;51ed	00 	. 
	nop			;51ee	00 	. 
	nop			;51ef	00 	. 
	nop			;51f0	00 	. 
	nop			;51f1	00 	. 
	nop			;51f2	00 	. 
	nop			;51f3	00 	. 
	nop			;51f4	00 	. 
	nop			;51f5	00 	. 
	nop			;51f6	00 	. 
	nop			;51f7	00 	. 
	nop			;51f8	00 	. 
	nop			;51f9	00 	. 
	nop			;51fa	00 	. 
	nop			;51fb	00 	. 
	nop			;51fc	00 	. 
	nop			;51fd	00 	. 
	nop			;51fe	00 	. 
	nop			;51ff	00 	. 
	nop			;5200	00 	. 
	nop			;5201	00 	. 
	nop			;5202	00 	. 
	nop			;5203	00 	. 
	nop			;5204	00 	. 
	nop			;5205	00 	. 
	nop			;5206	00 	. 
	nop			;5207	00 	. 
	nop			;5208	00 	. 
	nop			;5209	00 	. 
	nop			;520a	00 	. 
	nop			;520b	00 	. 
	nop			;520c	00 	. 
	nop			;520d	00 	. 
	nop			;520e	00 	. 
	nop			;520f	00 	. 
	nop			;5210	00 	. 
	nop			;5211	00 	. 
	nop			;5212	00 	. 
	nop			;5213	00 	. 
	nop			;5214	00 	. 
	nop			;5215	00 	. 
	nop			;5216	00 	. 
	nop			;5217	00 	. 
	nop			;5218	00 	. 
	nop			;5219	00 	. 
	nop			;521a	00 	. 
	nop			;521b	00 	. 
	nop			;521c	00 	. 
	nop			;521d	00 	. 
	nop			;521e	00 	. 
	nop			;521f	00 	. 
	nop			;5220	00 	. 
	nop			;5221	00 	. 
	nop			;5222	00 	. 
	nop			;5223	00 	. 
	nop			;5224	00 	. 
	nop			;5225	00 	. 
	nop			;5226	00 	. 
	nop			;5227	00 	. 
	nop			;5228	00 	. 
	nop			;5229	00 	. 
	nop			;522a	00 	. 
	nop			;522b	00 	. 
	nop			;522c	00 	. 
	nop			;522d	00 	. 
	nop			;522e	00 	. 
	nop			;522f	00 	. 
	nop			;5230	00 	. 
	nop			;5231	00 	. 
	nop			;5232	00 	. 
	nop			;5233	00 	. 
	nop			;5234	00 	. 
	nop			;5235	00 	. 
	nop			;5236	00 	. 
	nop			;5237	00 	. 
	nop			;5238	00 	. 
	nop			;5239	00 	. 
	nop			;523a	00 	. 
	nop			;523b	00 	. 
	nop			;523c	00 	. 
	nop			;523d	00 	. 
	nop			;523e	00 	. 
	nop			;523f	00 	. 
	nop			;5240	00 	. 
	nop			;5241	00 	. 
	nop			;5242	00 	. 
	nop			;5243	00 	. 
	nop			;5244	00 	. 
	nop			;5245	00 	. 
	nop			;5246	00 	. 
	nop			;5247	00 	. 
	nop			;5248	00 	. 
	nop			;5249	00 	. 
	nop			;524a	00 	. 
	nop			;524b	00 	. 
	nop			;524c	00 	. 
	nop			;524d	00 	. 
	nop			;524e	00 	. 
	nop			;524f	00 	. 
	nop			;5250	00 	. 
	nop			;5251	00 	. 
	nop			;5252	00 	. 
	nop			;5253	00 	. 
	nop			;5254	00 	. 
	nop			;5255	00 	. 
	nop			;5256	00 	. 
	nop			;5257	00 	. 
	nop			;5258	00 	. 
	nop			;5259	00 	. 
	nop			;525a	00 	. 
	nop			;525b	00 	. 
	nop			;525c	00 	. 
	nop			;525d	00 	. 
	nop			;525e	00 	. 
	nop			;525f	00 	. 
	nop			;5260	00 	. 
	nop			;5261	00 	. 
	nop			;5262	00 	. 
	nop			;5263	00 	. 
	nop			;5264	00 	. 
	nop			;5265	00 	. 
	nop			;5266	00 	. 
	nop			;5267	00 	. 
	nop			;5268	00 	. 
	nop			;5269	00 	. 
	nop			;526a	00 	. 
	nop			;526b	00 	. 
	nop			;526c	00 	. 
	nop			;526d	00 	. 
	nop			;526e	00 	. 
	nop			;526f	00 	. 
	nop			;5270	00 	. 
	nop			;5271	00 	. 
	nop			;5272	00 	. 
	nop			;5273	00 	. 
	nop			;5274	00 	. 
	nop			;5275	00 	. 
	nop			;5276	00 	. 
	nop			;5277	00 	. 
	nop			;5278	00 	. 
	nop			;5279	00 	. 
	nop			;527a	00 	. 
	nop			;527b	00 	. 
	nop			;527c	00 	. 
	nop			;527d	00 	. 
	nop			;527e	00 	. 
	nop			;527f	00 	. 
	nop			;5280	00 	. 
	nop			;5281	00 	. 
	nop			;5282	00 	. 
	nop			;5283	00 	. 
	nop			;5284	00 	. 
	nop			;5285	00 	. 
	nop			;5286	00 	. 
	nop			;5287	00 	. 
	nop			;5288	00 	. 
	nop			;5289	00 	. 
	nop			;528a	00 	. 
	nop			;528b	00 	. 
	nop			;528c	00 	. 
	nop			;528d	00 	. 
	nop			;528e	00 	. 
	nop			;528f	00 	. 
	nop			;5290	00 	. 
	nop			;5291	00 	. 
	nop			;5292	00 	. 
	nop			;5293	00 	. 
	nop			;5294	00 	. 
	nop			;5295	00 	. 
	nop			;5296	00 	. 
	nop			;5297	00 	. 
	nop			;5298	00 	. 
	nop			;5299	00 	. 
	nop			;529a	00 	. 
	nop			;529b	00 	. 
	nop			;529c	00 	. 
	nop			;529d	00 	. 
	nop			;529e	00 	. 
	nop			;529f	00 	. 
	nop			;52a0	00 	. 
	nop			;52a1	00 	. 
	nop			;52a2	00 	. 
	nop			;52a3	00 	. 
	nop			;52a4	00 	. 
	nop			;52a5	00 	. 
	nop			;52a6	00 	. 
	nop			;52a7	00 	. 
	nop			;52a8	00 	. 
	nop			;52a9	00 	. 
	nop			;52aa	00 	. 
	nop			;52ab	00 	. 
	nop			;52ac	00 	. 
	nop			;52ad	00 	. 
	nop			;52ae	00 	. 
	nop			;52af	00 	. 
	nop			;52b0	00 	. 
	nop			;52b1	00 	. 
	nop			;52b2	00 	. 
	nop			;52b3	00 	. 
	nop			;52b4	00 	. 
	nop			;52b5	00 	. 
	nop			;52b6	00 	. 
	nop			;52b7	00 	. 
	nop			;52b8	00 	. 
	nop			;52b9	00 	. 
	nop			;52ba	00 	. 
	nop			;52bb	00 	. 
	nop			;52bc	00 	. 
	nop			;52bd	00 	. 
	nop			;52be	00 	. 
	nop			;52bf	00 	. 
	nop			;52c0	00 	. 
	nop			;52c1	00 	. 
	nop			;52c2	00 	. 
	nop			;52c3	00 	. 
	nop			;52c4	00 	. 
	nop			;52c5	00 	. 
	nop			;52c6	00 	. 
	nop			;52c7	00 	. 
	nop			;52c8	00 	. 
	nop			;52c9	00 	. 
	nop			;52ca	00 	. 
	nop			;52cb	00 	. 
	nop			;52cc	00 	. 
	nop			;52cd	00 	. 
	nop			;52ce	00 	. 
	nop			;52cf	00 	. 
	nop			;52d0	00 	. 
	nop			;52d1	00 	. 
	nop			;52d2	00 	. 
	nop			;52d3	00 	. 
	nop			;52d4	00 	. 
	nop			;52d5	00 	. 
	nop			;52d6	00 	. 
	nop			;52d7	00 	. 
	nop			;52d8	00 	. 
	nop			;52d9	00 	. 
	nop			;52da	00 	. 
	nop			;52db	00 	. 
	nop			;52dc	00 	. 
	nop			;52dd	00 	. 
	nop			;52de	00 	. 
	nop			;52df	00 	. 
	nop			;52e0	00 	. 
	nop			;52e1	00 	. 
	nop			;52e2	00 	. 
	nop			;52e3	00 	. 
	nop			;52e4	00 	. 
	nop			;52e5	00 	. 
	nop			;52e6	00 	. 
	nop			;52e7	00 	. 
	nop			;52e8	00 	. 
	nop			;52e9	00 	. 
	nop			;52ea	00 	. 
	nop			;52eb	00 	. 
	nop			;52ec	00 	. 
	nop			;52ed	00 	. 
	nop			;52ee	00 	. 
	nop			;52ef	00 	. 
	nop			;52f0	00 	. 
	nop			;52f1	00 	. 
	nop			;52f2	00 	. 
	nop			;52f3	00 	. 
	nop			;52f4	00 	. 
	nop			;52f5	00 	. 
	nop			;52f6	00 	. 
	nop			;52f7	00 	. 
	nop			;52f8	00 	. 
	nop			;52f9	00 	. 
	nop			;52fa	00 	. 
	nop			;52fb	00 	. 
	nop			;52fc	00 	. 
	nop			;52fd	00 	. 
	nop			;52fe	00 	. 
	nop			;52ff	00 	. 
	nop			;5300	00 	. 
	nop			;5301	00 	. 
	nop			;5302	00 	. 
	nop			;5303	00 	. 
	nop			;5304	00 	. 
	nop			;5305	00 	. 
	nop			;5306	00 	. 
	nop			;5307	00 	. 
	nop			;5308	00 	. 
	nop			;5309	00 	. 
	nop			;530a	00 	. 
	nop			;530b	00 	. 
	nop			;530c	00 	. 
	nop			;530d	00 	. 
	nop			;530e	00 	. 
	nop			;530f	00 	. 
	nop			;5310	00 	. 
	nop			;5311	00 	. 
	nop			;5312	00 	. 
	nop			;5313	00 	. 
	nop			;5314	00 	. 
	nop			;5315	00 	. 
	nop			;5316	00 	. 
	nop			;5317	00 	. 
	nop			;5318	00 	. 
	nop			;5319	00 	. 
	nop			;531a	00 	. 
	nop			;531b	00 	. 
	nop			;531c	00 	. 
	nop			;531d	00 	. 
	nop			;531e	00 	. 
	nop			;531f	00 	. 
	nop			;5320	00 	. 
	nop			;5321	00 	. 
	nop			;5322	00 	. 
	nop			;5323	00 	. 
	nop			;5324	00 	. 
	nop			;5325	00 	. 
	nop			;5326	00 	. 
	nop			;5327	00 	. 
	nop			;5328	00 	. 
	nop			;5329	00 	. 
	nop			;532a	00 	. 
	nop			;532b	00 	. 
	nop			;532c	00 	. 
	nop			;532d	00 	. 
	nop			;532e	00 	. 
	nop			;532f	00 	. 
	nop			;5330	00 	. 
	nop			;5331	00 	. 
	nop			;5332	00 	. 
	nop			;5333	00 	. 
	nop			;5334	00 	. 
	nop			;5335	00 	. 
	nop			;5336	00 	. 
	nop			;5337	00 	. 
	nop			;5338	00 	. 
	nop			;5339	00 	. 
	nop			;533a	00 	. 
	nop			;533b	00 	. 
	nop			;533c	00 	. 
	nop			;533d	00 	. 
	nop			;533e	00 	. 
	nop			;533f	00 	. 
	nop			;5340	00 	. 
	nop			;5341	00 	. 
	nop			;5342	00 	. 
	nop			;5343	00 	. 
	nop			;5344	00 	. 
	nop			;5345	00 	. 
	nop			;5346	00 	. 
	nop			;5347	00 	. 
	nop			;5348	00 	. 
	nop			;5349	00 	. 
	nop			;534a	00 	. 
	nop			;534b	00 	. 
	nop			;534c	00 	. 
	nop			;534d	00 	. 
	nop			;534e	00 	. 
	nop			;534f	00 	. 
	nop			;5350	00 	. 
	nop			;5351	00 	. 
	nop			;5352	00 	. 
	nop			;5353	00 	. 
	nop			;5354	00 	. 
	nop			;5355	00 	. 
	nop			;5356	00 	. 
	nop			;5357	00 	. 
	nop			;5358	00 	. 
	nop			;5359	00 	. 
	nop			;535a	00 	. 
	nop			;535b	00 	. 
	nop			;535c	00 	. 
	nop			;535d	00 	. 
	nop			;535e	00 	. 
	nop			;535f	00 	. 
	nop			;5360	00 	. 
	nop			;5361	00 	. 
	nop			;5362	00 	. 
	nop			;5363	00 	. 
	nop			;5364	00 	. 
	nop			;5365	00 	. 
	nop			;5366	00 	. 
	nop			;5367	00 	. 
	nop			;5368	00 	. 
	nop			;5369	00 	. 
	nop			;536a	00 	. 
	nop			;536b	00 	. 
	nop			;536c	00 	. 
	nop			;536d	00 	. 
	nop			;536e	00 	. 
	nop			;536f	00 	. 
	nop			;5370	00 	. 
	nop			;5371	00 	. 
	nop			;5372	00 	. 
	nop			;5373	00 	. 
	nop			;5374	00 	. 
	nop			;5375	00 	. 
	nop			;5376	00 	. 
	nop			;5377	00 	. 
	nop			;5378	00 	. 
	nop			;5379	00 	. 
	nop			;537a	00 	. 
	nop			;537b	00 	. 
	nop			;537c	00 	. 
	nop			;537d	00 	. 
	nop			;537e	00 	. 
	nop			;537f	00 	. 
	nop			;5380	00 	. 
	nop			;5381	00 	. 
	nop			;5382	00 	. 
	nop			;5383	00 	. 
	nop			;5384	00 	. 
	nop			;5385	00 	. 
	nop			;5386	00 	. 
	nop			;5387	00 	. 
	nop			;5388	00 	. 
	nop			;5389	00 	. 
	nop			;538a	00 	. 
	nop			;538b	00 	. 
	nop			;538c	00 	. 
	nop			;538d	00 	. 
	nop			;538e	00 	. 
	nop			;538f	00 	. 
	nop			;5390	00 	. 
	nop			;5391	00 	. 
	nop			;5392	00 	. 
	nop			;5393	00 	. 
	nop			;5394	00 	. 
	nop			;5395	00 	. 
	nop			;5396	00 	. 
	nop			;5397	00 	. 
	nop			;5398	00 	. 
	nop			;5399	00 	. 
	nop			;539a	00 	. 
	nop			;539b	00 	. 
	nop			;539c	00 	. 
	nop			;539d	00 	. 
	nop			;539e	00 	. 
	nop			;539f	00 	. 
	nop			;53a0	00 	. 
	nop			;53a1	00 	. 
	nop			;53a2	00 	. 
	nop			;53a3	00 	. 
	nop			;53a4	00 	. 
	nop			;53a5	00 	. 
	nop			;53a6	00 	. 
	nop			;53a7	00 	. 
	nop			;53a8	00 	. 
	nop			;53a9	00 	. 
	nop			;53aa	00 	. 
	nop			;53ab	00 	. 
	nop			;53ac	00 	. 
	nop			;53ad	00 	. 
	nop			;53ae	00 	. 
	nop			;53af	00 	. 
	nop			;53b0	00 	. 
	nop			;53b1	00 	. 
	nop			;53b2	00 	. 
	nop			;53b3	00 	. 
	nop			;53b4	00 	. 
	nop			;53b5	00 	. 
	nop			;53b6	00 	. 
	nop			;53b7	00 	. 
	nop			;53b8	00 	. 
	nop			;53b9	00 	. 
	nop			;53ba	00 	. 
	nop			;53bb	00 	. 
	nop			;53bc	00 	. 
	nop			;53bd	00 	. 
	nop			;53be	00 	. 
	nop			;53bf	00 	. 
	nop			;53c0	00 	. 
	nop			;53c1	00 	. 
	nop			;53c2	00 	. 
	nop			;53c3	00 	. 
	nop			;53c4	00 	. 
	nop			;53c5	00 	. 
	nop			;53c6	00 	. 
	nop			;53c7	00 	. 
	nop			;53c8	00 	. 
	nop			;53c9	00 	. 
	nop			;53ca	00 	. 
	nop			;53cb	00 	. 
	nop			;53cc	00 	. 
	nop			;53cd	00 	. 
	nop			;53ce	00 	. 
	nop			;53cf	00 	. 
	nop			;53d0	00 	. 
	nop			;53d1	00 	. 
	nop			;53d2	00 	. 
	nop			;53d3	00 	. 
	nop			;53d4	00 	. 
	nop			;53d5	00 	. 
	nop			;53d6	00 	. 
	nop			;53d7	00 	. 
	nop			;53d8	00 	. 
	nop			;53d9	00 	. 
	nop			;53da	00 	. 
	nop			;53db	00 	. 
	nop			;53dc	00 	. 
	nop			;53dd	00 	. 
	nop			;53de	00 	. 
	nop			;53df	00 	. 
	nop			;53e0	00 	. 
	nop			;53e1	00 	. 
	nop			;53e2	00 	. 
	nop			;53e3	00 	. 
	nop			;53e4	00 	. 
	nop			;53e5	00 	. 
	nop			;53e6	00 	. 
	nop			;53e7	00 	. 
	nop			;53e8	00 	. 
	nop			;53e9	00 	. 
	nop			;53ea	00 	. 
	nop			;53eb	00 	. 
	nop			;53ec	00 	. 
	nop			;53ed	00 	. 
	nop			;53ee	00 	. 
	nop			;53ef	00 	. 
	nop			;53f0	00 	. 
	nop			;53f1	00 	. 
	nop			;53f2	00 	. 
	nop			;53f3	00 	. 
	nop			;53f4	00 	. 
	nop			;53f5	00 	. 
	nop			;53f6	00 	. 
	nop			;53f7	00 	. 
	nop			;53f8	00 	. 
	nop			;53f9	00 	. 
	nop			;53fa	00 	. 
	nop			;53fb	00 	. 
	nop			;53fc	00 	. 
	nop			;53fd	00 	. 
	nop			;53fe	00 	. 
	nop			;53ff	00 	. 
	nop			;5400	00 	. 
	nop			;5401	00 	. 
	nop			;5402	00 	. 
	nop			;5403	00 	. 
	nop			;5404	00 	. 
	nop			;5405	00 	. 
	nop			;5406	00 	. 
	nop			;5407	00 	. 
	nop			;5408	00 	. 
	nop			;5409	00 	. 
	nop			;540a	00 	. 
	nop			;540b	00 	. 
	nop			;540c	00 	. 
	nop			;540d	00 	. 
	nop			;540e	00 	. 
	nop			;540f	00 	. 
	nop			;5410	00 	. 
	nop			;5411	00 	. 
	nop			;5412	00 	. 
	nop			;5413	00 	. 
	nop			;5414	00 	. 
	nop			;5415	00 	. 
	nop			;5416	00 	. 
	nop			;5417	00 	. 
	nop			;5418	00 	. 
	nop			;5419	00 	. 
	nop			;541a	00 	. 
	nop			;541b	00 	. 
	nop			;541c	00 	. 
	nop			;541d	00 	. 
	nop			;541e	00 	. 
	nop			;541f	00 	. 
	nop			;5420	00 	. 
	nop			;5421	00 	. 
	nop			;5422	00 	. 
	nop			;5423	00 	. 
	nop			;5424	00 	. 
	nop			;5425	00 	. 
	nop			;5426	00 	. 
	nop			;5427	00 	. 
	nop			;5428	00 	. 
	nop			;5429	00 	. 
	nop			;542a	00 	. 
	nop			;542b	00 	. 
	nop			;542c	00 	. 
	nop			;542d	00 	. 
	nop			;542e	00 	. 
	nop			;542f	00 	. 
	nop			;5430	00 	. 
	nop			;5431	00 	. 
	nop			;5432	00 	. 
	nop			;5433	00 	. 
	nop			;5434	00 	. 
	nop			;5435	00 	. 
	nop			;5436	00 	. 
	nop			;5437	00 	. 
	nop			;5438	00 	. 
	nop			;5439	00 	. 
	nop			;543a	00 	. 
	nop			;543b	00 	. 
	nop			;543c	00 	. 
	nop			;543d	00 	. 
	nop			;543e	00 	. 
	nop			;543f	00 	. 
	nop			;5440	00 	. 
	nop			;5441	00 	. 
	nop			;5442	00 	. 
	nop			;5443	00 	. 
	nop			;5444	00 	. 
	nop			;5445	00 	. 
	nop			;5446	00 	. 
	nop			;5447	00 	. 
	nop			;5448	00 	. 
	nop			;5449	00 	. 
	nop			;544a	00 	. 
	nop			;544b	00 	. 
	nop			;544c	00 	. 
	nop			;544d	00 	. 
	nop			;544e	00 	. 
	nop			;544f	00 	. 
	nop			;5450	00 	. 
	nop			;5451	00 	. 
	nop			;5452	00 	. 
	nop			;5453	00 	. 
	nop			;5454	00 	. 
	nop			;5455	00 	. 
	nop			;5456	00 	. 
	nop			;5457	00 	. 
	nop			;5458	00 	. 
	nop			;5459	00 	. 
	nop			;545a	00 	. 
	nop			;545b	00 	. 
	nop			;545c	00 	. 
	nop			;545d	00 	. 
	nop			;545e	00 	. 
	nop			;545f	00 	. 
	nop			;5460	00 	. 
	nop			;5461	00 	. 
	nop			;5462	00 	. 
	nop			;5463	00 	. 
	nop			;5464	00 	. 
	nop			;5465	00 	. 
	nop			;5466	00 	. 
	nop			;5467	00 	. 
	nop			;5468	00 	. 
	nop			;5469	00 	. 
	nop			;546a	00 	. 
	nop			;546b	00 	. 
	nop			;546c	00 	. 
	nop			;546d	00 	. 
	nop			;546e	00 	. 
	nop			;546f	00 	. 
	nop			;5470	00 	. 
	nop			;5471	00 	. 
	nop			;5472	00 	. 
	nop			;5473	00 	. 
	nop			;5474	00 	. 
	nop			;5475	00 	. 
	nop			;5476	00 	. 
	nop			;5477	00 	. 
	nop			;5478	00 	. 
	nop			;5479	00 	. 
	nop			;547a	00 	. 
	nop			;547b	00 	. 
	nop			;547c	00 	. 
	nop			;547d	00 	. 
	nop			;547e	00 	. 
	nop			;547f	00 	. 
	nop			;5480	00 	. 
	nop			;5481	00 	. 
	nop			;5482	00 	. 
	nop			;5483	00 	. 
	nop			;5484	00 	. 
	nop			;5485	00 	. 
	nop			;5486	00 	. 
	nop			;5487	00 	. 
	nop			;5488	00 	. 
	nop			;5489	00 	. 
	nop			;548a	00 	. 
	nop			;548b	00 	. 
	nop			;548c	00 	. 
	nop			;548d	00 	. 
	nop			;548e	00 	. 
	nop			;548f	00 	. 
	nop			;5490	00 	. 
	nop			;5491	00 	. 
	nop			;5492	00 	. 
	nop			;5493	00 	. 
	nop			;5494	00 	. 
	nop			;5495	00 	. 
	nop			;5496	00 	. 
	nop			;5497	00 	. 
	nop			;5498	00 	. 
	nop			;5499	00 	. 
	nop			;549a	00 	. 
	nop			;549b	00 	. 
	nop			;549c	00 	. 
	nop			;549d	00 	. 
	nop			;549e	00 	. 
	nop			;549f	00 	. 
	nop			;54a0	00 	. 
	nop			;54a1	00 	. 
	nop			;54a2	00 	. 
	nop			;54a3	00 	. 
	nop			;54a4	00 	. 
	nop			;54a5	00 	. 
	nop			;54a6	00 	. 
	nop			;54a7	00 	. 
	nop			;54a8	00 	. 
	nop			;54a9	00 	. 
	nop			;54aa	00 	. 
	nop			;54ab	00 	. 
	nop			;54ac	00 	. 
	nop			;54ad	00 	. 
	nop			;54ae	00 	. 
	nop			;54af	00 	. 
	nop			;54b0	00 	. 
	nop			;54b1	00 	. 
	nop			;54b2	00 	. 
	nop			;54b3	00 	. 
	nop			;54b4	00 	. 
	nop			;54b5	00 	. 
	nop			;54b6	00 	. 
	nop			;54b7	00 	. 
	nop			;54b8	00 	. 
	nop			;54b9	00 	. 
	nop			;54ba	00 	. 
	nop			;54bb	00 	. 
	nop			;54bc	00 	. 
	nop			;54bd	00 	. 
	nop			;54be	00 	. 
	nop			;54bf	00 	. 
	nop			;54c0	00 	. 
	nop			;54c1	00 	. 
	nop			;54c2	00 	. 
	nop			;54c3	00 	. 
	nop			;54c4	00 	. 
	nop			;54c5	00 	. 
	nop			;54c6	00 	. 
	nop			;54c7	00 	. 
	nop			;54c8	00 	. 
	nop			;54c9	00 	. 
	nop			;54ca	00 	. 
	nop			;54cb	00 	. 
	nop			;54cc	00 	. 
	nop			;54cd	00 	. 
	nop			;54ce	00 	. 
	nop			;54cf	00 	. 
	nop			;54d0	00 	. 
	nop			;54d1	00 	. 
	nop			;54d2	00 	. 
	nop			;54d3	00 	. 
	nop			;54d4	00 	. 
	nop			;54d5	00 	. 
	nop			;54d6	00 	. 
	nop			;54d7	00 	. 
	nop			;54d8	00 	. 
	nop			;54d9	00 	. 
	nop			;54da	00 	. 
	nop			;54db	00 	. 
	nop			;54dc	00 	. 
	nop			;54dd	00 	. 
	nop			;54de	00 	. 
	nop			;54df	00 	. 
	nop			;54e0	00 	. 
	nop			;54e1	00 	. 
	nop			;54e2	00 	. 
	nop			;54e3	00 	. 
	nop			;54e4	00 	. 
	nop			;54e5	00 	. 
	nop			;54e6	00 	. 
	nop			;54e7	00 	. 
	nop			;54e8	00 	. 
	nop			;54e9	00 	. 
	nop			;54ea	00 	. 
	nop			;54eb	00 	. 
	nop			;54ec	00 	. 
	nop			;54ed	00 	. 
	nop			;54ee	00 	. 
	nop			;54ef	00 	. 
	nop			;54f0	00 	. 
	nop			;54f1	00 	. 
	nop			;54f2	00 	. 
	nop			;54f3	00 	. 
	nop			;54f4	00 	. 
	nop			;54f5	00 	. 
	nop			;54f6	00 	. 
	nop			;54f7	00 	. 
	nop			;54f8	00 	. 
	nop			;54f9	00 	. 
	nop			;54fa	00 	. 
	nop			;54fb	00 	. 
	nop			;54fc	00 	. 
	nop			;54fd	00 	. 
	nop			;54fe	00 	. 
	nop			;54ff	00 	. 
	nop			;5500	00 	. 
	nop			;5501	00 	. 
	nop			;5502	00 	. 
	nop			;5503	00 	. 
	nop			;5504	00 	. 
	nop			;5505	00 	. 
	nop			;5506	00 	. 
	nop			;5507	00 	. 
	nop			;5508	00 	. 
	nop			;5509	00 	. 
	nop			;550a	00 	. 
	nop			;550b	00 	. 
	nop			;550c	00 	. 
	nop			;550d	00 	. 
	nop			;550e	00 	. 
	nop			;550f	00 	. 
	nop			;5510	00 	. 
	nop			;5511	00 	. 
	nop			;5512	00 	. 
	nop			;5513	00 	. 
	nop			;5514	00 	. 
	nop			;5515	00 	. 
	nop			;5516	00 	. 
	nop			;5517	00 	. 
	nop			;5518	00 	. 
	nop			;5519	00 	. 
	nop			;551a	00 	. 
	nop			;551b	00 	. 
	nop			;551c	00 	. 
	nop			;551d	00 	. 
	nop			;551e	00 	. 
	nop			;551f	00 	. 
	nop			;5520	00 	. 
	nop			;5521	00 	. 
	nop			;5522	00 	. 
	nop			;5523	00 	. 
	nop			;5524	00 	. 
	nop			;5525	00 	. 
	nop			;5526	00 	. 
	nop			;5527	00 	. 
	nop			;5528	00 	. 
	nop			;5529	00 	. 
	nop			;552a	00 	. 
	nop			;552b	00 	. 
	nop			;552c	00 	. 
	nop			;552d	00 	. 
	nop			;552e	00 	. 
	nop			;552f	00 	. 
	nop			;5530	00 	. 
	nop			;5531	00 	. 
	nop			;5532	00 	. 
	nop			;5533	00 	. 
	nop			;5534	00 	. 
	nop			;5535	00 	. 
	nop			;5536	00 	. 
	nop			;5537	00 	. 
	nop			;5538	00 	. 
	nop			;5539	00 	. 
	nop			;553a	00 	. 
	nop			;553b	00 	. 
	nop			;553c	00 	. 
	nop			;553d	00 	. 
	nop			;553e	00 	. 
	nop			;553f	00 	. 
	nop			;5540	00 	. 
	nop			;5541	00 	. 
	nop			;5542	00 	. 
	nop			;5543	00 	. 
	nop			;5544	00 	. 
	nop			;5545	00 	. 
	nop			;5546	00 	. 
	nop			;5547	00 	. 
	nop			;5548	00 	. 
	nop			;5549	00 	. 
	nop			;554a	00 	. 
	nop			;554b	00 	. 
	nop			;554c	00 	. 
	nop			;554d	00 	. 
	nop			;554e	00 	. 
	nop			;554f	00 	. 
	nop			;5550	00 	. 
	nop			;5551	00 	. 
	nop			;5552	00 	. 
	nop			;5553	00 	. 
	nop			;5554	00 	. 
	nop			;5555	00 	. 
	nop			;5556	00 	. 
	nop			;5557	00 	. 
	nop			;5558	00 	. 
	nop			;5559	00 	. 
	nop			;555a	00 	. 
	nop			;555b	00 	. 
	nop			;555c	00 	. 
	nop			;555d	00 	. 
	nop			;555e	00 	. 
	nop			;555f	00 	. 
	nop			;5560	00 	. 
	nop			;5561	00 	. 
	nop			;5562	00 	. 
	nop			;5563	00 	. 
	nop			;5564	00 	. 
	nop			;5565	00 	. 
	nop			;5566	00 	. 
	nop			;5567	00 	. 
	nop			;5568	00 	. 
	nop			;5569	00 	. 
	nop			;556a	00 	. 
	nop			;556b	00 	. 
	nop			;556c	00 	. 
	nop			;556d	00 	. 
	nop			;556e	00 	. 
	nop			;556f	00 	. 
	nop			;5570	00 	. 
	nop			;5571	00 	. 
	nop			;5572	00 	. 
	nop			;5573	00 	. 
	nop			;5574	00 	. 
	nop			;5575	00 	. 
	nop			;5576	00 	. 
	nop			;5577	00 	. 
	nop			;5578	00 	. 
	nop			;5579	00 	. 
	nop			;557a	00 	. 
	nop			;557b	00 	. 
	nop			;557c	00 	. 
	nop			;557d	00 	. 
	nop			;557e	00 	. 
	nop			;557f	00 	. 
	nop			;5580	00 	. 
	nop			;5581	00 	. 
	nop			;5582	00 	. 
	nop			;5583	00 	. 
	nop			;5584	00 	. 
	nop			;5585	00 	. 
	nop			;5586	00 	. 
	nop			;5587	00 	. 
	nop			;5588	00 	. 
	nop			;5589	00 	. 
	nop			;558a	00 	. 
	nop			;558b	00 	. 
	nop			;558c	00 	. 
	nop			;558d	00 	. 
	nop			;558e	00 	. 
	nop			;558f	00 	. 
	nop			;5590	00 	. 
	nop			;5591	00 	. 
	nop			;5592	00 	. 
	nop			;5593	00 	. 
	nop			;5594	00 	. 
	nop			;5595	00 	. 
	nop			;5596	00 	. 
	nop			;5597	00 	. 
	nop			;5598	00 	. 
	nop			;5599	00 	. 
	nop			;559a	00 	. 
	nop			;559b	00 	. 
	nop			;559c	00 	. 
	nop			;559d	00 	. 
	nop			;559e	00 	. 
	nop			;559f	00 	. 
	nop			;55a0	00 	. 
	nop			;55a1	00 	. 
	nop			;55a2	00 	. 
	nop			;55a3	00 	. 
	nop			;55a4	00 	. 
	nop			;55a5	00 	. 
	nop			;55a6	00 	. 
	nop			;55a7	00 	. 
	nop			;55a8	00 	. 
	nop			;55a9	00 	. 
	nop			;55aa	00 	. 
	nop			;55ab	00 	. 
	nop			;55ac	00 	. 
	nop			;55ad	00 	. 
	nop			;55ae	00 	. 
	nop			;55af	00 	. 
	nop			;55b0	00 	. 
	nop			;55b1	00 	. 
	nop			;55b2	00 	. 
	nop			;55b3	00 	. 
	nop			;55b4	00 	. 
	nop			;55b5	00 	. 
	nop			;55b6	00 	. 
	nop			;55b7	00 	. 
	nop			;55b8	00 	. 
	nop			;55b9	00 	. 
	nop			;55ba	00 	. 
	nop			;55bb	00 	. 
	nop			;55bc	00 	. 
	nop			;55bd	00 	. 
	nop			;55be	00 	. 
	nop			;55bf	00 	. 
	nop			;55c0	00 	. 
	nop			;55c1	00 	. 
	nop			;55c2	00 	. 
	nop			;55c3	00 	. 
	nop			;55c4	00 	. 
	nop			;55c5	00 	. 
	nop			;55c6	00 	. 
	nop			;55c7	00 	. 
	nop			;55c8	00 	. 
	nop			;55c9	00 	. 
	nop			;55ca	00 	. 
	nop			;55cb	00 	. 
	nop			;55cc	00 	. 
	nop			;55cd	00 	. 
	nop			;55ce	00 	. 
	nop			;55cf	00 	. 
	nop			;55d0	00 	. 
	nop			;55d1	00 	. 
	nop			;55d2	00 	. 
	nop			;55d3	00 	. 
	nop			;55d4	00 	. 
	nop			;55d5	00 	. 
	nop			;55d6	00 	. 
	nop			;55d7	00 	. 
	nop			;55d8	00 	. 
	nop			;55d9	00 	. 
	nop			;55da	00 	. 
	nop			;55db	00 	. 
	nop			;55dc	00 	. 
	nop			;55dd	00 	. 
	nop			;55de	00 	. 
	nop			;55df	00 	. 
	nop			;55e0	00 	. 
	nop			;55e1	00 	. 
	nop			;55e2	00 	. 
	nop			;55e3	00 	. 
	nop			;55e4	00 	. 
	nop			;55e5	00 	. 
	nop			;55e6	00 	. 
	nop			;55e7	00 	. 
	nop			;55e8	00 	. 
	nop			;55e9	00 	. 
	nop			;55ea	00 	. 
	nop			;55eb	00 	. 
	nop			;55ec	00 	. 
	nop			;55ed	00 	. 
	nop			;55ee	00 	. 
	nop			;55ef	00 	. 
	nop			;55f0	00 	. 
	nop			;55f1	00 	. 
	nop			;55f2	00 	. 
	nop			;55f3	00 	. 
	nop			;55f4	00 	. 
	nop			;55f5	00 	. 
	nop			;55f6	00 	. 
	nop			;55f7	00 	. 
	nop			;55f8	00 	. 
	nop			;55f9	00 	. 
	nop			;55fa	00 	. 
	nop			;55fb	00 	. 
	nop			;55fc	00 	. 
	nop			;55fd	00 	. 
	nop			;55fe	00 	. 
	nop			;55ff	00 	. 
	nop			;5600	00 	. 
	nop			;5601	00 	. 
	nop			;5602	00 	. 
	nop			;5603	00 	. 
	nop			;5604	00 	. 
	nop			;5605	00 	. 
	nop			;5606	00 	. 
	nop			;5607	00 	. 
	nop			;5608	00 	. 
	nop			;5609	00 	. 
	nop			;560a	00 	. 
	nop			;560b	00 	. 
	nop			;560c	00 	. 
	nop			;560d	00 	. 
	nop			;560e	00 	. 
	nop			;560f	00 	. 
	nop			;5610	00 	. 
	nop			;5611	00 	. 
	nop			;5612	00 	. 
	nop			;5613	00 	. 
	nop			;5614	00 	. 
	nop			;5615	00 	. 
	nop			;5616	00 	. 
	nop			;5617	00 	. 
	nop			;5618	00 	. 
	nop			;5619	00 	. 
	nop			;561a	00 	. 
	nop			;561b	00 	. 
	nop			;561c	00 	. 
	nop			;561d	00 	. 
	nop			;561e	00 	. 
	nop			;561f	00 	. 
	nop			;5620	00 	. 
	nop			;5621	00 	. 
	nop			;5622	00 	. 
	nop			;5623	00 	. 
	nop			;5624	00 	. 
	nop			;5625	00 	. 
	nop			;5626	00 	. 
	nop			;5627	00 	. 
	nop			;5628	00 	. 
	nop			;5629	00 	. 
	nop			;562a	00 	. 
	nop			;562b	00 	. 
	nop			;562c	00 	. 
	nop			;562d	00 	. 
	nop			;562e	00 	. 
	nop			;562f	00 	. 
	nop			;5630	00 	. 
	nop			;5631	00 	. 
	nop			;5632	00 	. 
	nop			;5633	00 	. 
	nop			;5634	00 	. 
	nop			;5635	00 	. 
	nop			;5636	00 	. 
	nop			;5637	00 	. 
	nop			;5638	00 	. 
	nop			;5639	00 	. 
	nop			;563a	00 	. 
	nop			;563b	00 	. 
	nop			;563c	00 	. 
	nop			;563d	00 	. 
	nop			;563e	00 	. 
	nop			;563f	00 	. 
	nop			;5640	00 	. 
	nop			;5641	00 	. 
	nop			;5642	00 	. 
	nop			;5643	00 	. 
	nop			;5644	00 	. 
	nop			;5645	00 	. 
	nop			;5646	00 	. 
	nop			;5647	00 	. 
	nop			;5648	00 	. 
	nop			;5649	00 	. 
	nop			;564a	00 	. 
	nop			;564b	00 	. 
	nop			;564c	00 	. 
	nop			;564d	00 	. 
	nop			;564e	00 	. 
	nop			;564f	00 	. 
	nop			;5650	00 	. 
	nop			;5651	00 	. 
	nop			;5652	00 	. 
	nop			;5653	00 	. 
	nop			;5654	00 	. 
	nop			;5655	00 	. 
	nop			;5656	00 	. 
	nop			;5657	00 	. 
	nop			;5658	00 	. 
	nop			;5659	00 	. 
	nop			;565a	00 	. 
	nop			;565b	00 	. 
	nop			;565c	00 	. 
	nop			;565d	00 	. 
	nop			;565e	00 	. 
	nop			;565f	00 	. 
	nop			;5660	00 	. 
	nop			;5661	00 	. 
	nop			;5662	00 	. 
	nop			;5663	00 	. 
	nop			;5664	00 	. 
	nop			;5665	00 	. 
	nop			;5666	00 	. 
	nop			;5667	00 	. 
	nop			;5668	00 	. 
	nop			;5669	00 	. 
	nop			;566a	00 	. 
	nop			;566b	00 	. 
	nop			;566c	00 	. 
	nop			;566d	00 	. 
	nop			;566e	00 	. 
	nop			;566f	00 	. 
	nop			;5670	00 	. 
	nop			;5671	00 	. 
	nop			;5672	00 	. 
	nop			;5673	00 	. 
	nop			;5674	00 	. 
	nop			;5675	00 	. 
	nop			;5676	00 	. 
	nop			;5677	00 	. 
	nop			;5678	00 	. 
	nop			;5679	00 	. 
	nop			;567a	00 	. 
	nop			;567b	00 	. 
	nop			;567c	00 	. 
	nop			;567d	00 	. 
	nop			;567e	00 	. 
	nop			;567f	00 	. 
	nop			;5680	00 	. 
	nop			;5681	00 	. 
	nop			;5682	00 	. 
	nop			;5683	00 	. 
	nop			;5684	00 	. 
	nop			;5685	00 	. 
	nop			;5686	00 	. 
	nop			;5687	00 	. 
	nop			;5688	00 	. 
	nop			;5689	00 	. 
	nop			;568a	00 	. 
	nop			;568b	00 	. 
	nop			;568c	00 	. 
	nop			;568d	00 	. 
	nop			;568e	00 	. 
	nop			;568f	00 	. 
	nop			;5690	00 	. 
	nop			;5691	00 	. 
	nop			;5692	00 	. 
	nop			;5693	00 	. 
	nop			;5694	00 	. 
	nop			;5695	00 	. 
	nop			;5696	00 	. 
	nop			;5697	00 	. 
	nop			;5698	00 	. 
	nop			;5699	00 	. 
	nop			;569a	00 	. 
	nop			;569b	00 	. 
	nop			;569c	00 	. 
	nop			;569d	00 	. 
	nop			;569e	00 	. 
	nop			;569f	00 	. 
	nop			;56a0	00 	. 
	nop			;56a1	00 	. 
	nop			;56a2	00 	. 
	nop			;56a3	00 	. 
	nop			;56a4	00 	. 
	nop			;56a5	00 	. 
	nop			;56a6	00 	. 
	nop			;56a7	00 	. 
	nop			;56a8	00 	. 
	nop			;56a9	00 	. 
	nop			;56aa	00 	. 
	nop			;56ab	00 	. 
	nop			;56ac	00 	. 
	nop			;56ad	00 	. 
	nop			;56ae	00 	. 
	nop			;56af	00 	. 
	nop			;56b0	00 	. 
	nop			;56b1	00 	. 
	nop			;56b2	00 	. 
	nop			;56b3	00 	. 
	nop			;56b4	00 	. 
	nop			;56b5	00 	. 
	nop			;56b6	00 	. 
	nop			;56b7	00 	. 
	nop			;56b8	00 	. 
	nop			;56b9	00 	. 
	nop			;56ba	00 	. 
	nop			;56bb	00 	. 
	nop			;56bc	00 	. 
	nop			;56bd	00 	. 
	nop			;56be	00 	. 
	nop			;56bf	00 	. 
	nop			;56c0	00 	. 
	nop			;56c1	00 	. 
	nop			;56c2	00 	. 
	nop			;56c3	00 	. 
	nop			;56c4	00 	. 
	nop			;56c5	00 	. 
	nop			;56c6	00 	. 
	nop			;56c7	00 	. 
	nop			;56c8	00 	. 
	nop			;56c9	00 	. 
	nop			;56ca	00 	. 
	nop			;56cb	00 	. 
	nop			;56cc	00 	. 
	nop			;56cd	00 	. 
	nop			;56ce	00 	. 
	nop			;56cf	00 	. 
	nop			;56d0	00 	. 
	nop			;56d1	00 	. 
	nop			;56d2	00 	. 
	nop			;56d3	00 	. 
	nop			;56d4	00 	. 
	nop			;56d5	00 	. 
	nop			;56d6	00 	. 
	nop			;56d7	00 	. 
	nop			;56d8	00 	. 
	nop			;56d9	00 	. 
	nop			;56da	00 	. 
	nop			;56db	00 	. 
	nop			;56dc	00 	. 
	nop			;56dd	00 	. 
	nop			;56de	00 	. 
	nop			;56df	00 	. 
	nop			;56e0	00 	. 
	nop			;56e1	00 	. 
	nop			;56e2	00 	. 
	nop			;56e3	00 	. 
	nop			;56e4	00 	. 
	nop			;56e5	00 	. 
	nop			;56e6	00 	. 
	nop			;56e7	00 	. 
	nop			;56e8	00 	. 
	nop			;56e9	00 	. 
	nop			;56ea	00 	. 
	nop			;56eb	00 	. 
	nop			;56ec	00 	. 
	nop			;56ed	00 	. 
	nop			;56ee	00 	. 
	nop			;56ef	00 	. 
	nop			;56f0	00 	. 
	nop			;56f1	00 	. 
	nop			;56f2	00 	. 
	nop			;56f3	00 	. 
	nop			;56f4	00 	. 
	nop			;56f5	00 	. 
	nop			;56f6	00 	. 
	nop			;56f7	00 	. 
	nop			;56f8	00 	. 
	nop			;56f9	00 	. 
	nop			;56fa	00 	. 
	nop			;56fb	00 	. 
	nop			;56fc	00 	. 
	nop			;56fd	00 	. 
	nop			;56fe	00 	. 
	nop			;56ff	00 	. 
	nop			;5700	00 	. 
	nop			;5701	00 	. 
	nop			;5702	00 	. 
	nop			;5703	00 	. 
	nop			;5704	00 	. 
	nop			;5705	00 	. 
	nop			;5706	00 	. 
	nop			;5707	00 	. 
	nop			;5708	00 	. 
	nop			;5709	00 	. 
	nop			;570a	00 	. 
	nop			;570b	00 	. 
	nop			;570c	00 	. 
	nop			;570d	00 	. 
	nop			;570e	00 	. 
	nop			;570f	00 	. 
	nop			;5710	00 	. 
	nop			;5711	00 	. 
	nop			;5712	00 	. 
	nop			;5713	00 	. 
	nop			;5714	00 	. 
	nop			;5715	00 	. 
	nop			;5716	00 	. 
	nop			;5717	00 	. 
	nop			;5718	00 	. 
	nop			;5719	00 	. 
	nop			;571a	00 	. 
	nop			;571b	00 	. 
	nop			;571c	00 	. 
	nop			;571d	00 	. 
	nop			;571e	00 	. 
	nop			;571f	00 	. 
	nop			;5720	00 	. 
	nop			;5721	00 	. 
	nop			;5722	00 	. 
	nop			;5723	00 	. 
	nop			;5724	00 	. 
	nop			;5725	00 	. 
	nop			;5726	00 	. 
	nop			;5727	00 	. 
	nop			;5728	00 	. 
	nop			;5729	00 	. 
	nop			;572a	00 	. 
	nop			;572b	00 	. 
	nop			;572c	00 	. 
	nop			;572d	00 	. 
	nop			;572e	00 	. 
	nop			;572f	00 	. 
	nop			;5730	00 	. 
	nop			;5731	00 	. 
	nop			;5732	00 	. 
	nop			;5733	00 	. 
	nop			;5734	00 	. 
	nop			;5735	00 	. 
	nop			;5736	00 	. 
	nop			;5737	00 	. 
	nop			;5738	00 	. 
	nop			;5739	00 	. 
	nop			;573a	00 	. 
	nop			;573b	00 	. 
	nop			;573c	00 	. 
	nop			;573d	00 	. 
	nop			;573e	00 	. 
	nop			;573f	00 	. 
	nop			;5740	00 	. 
	nop			;5741	00 	. 
	nop			;5742	00 	. 
	nop			;5743	00 	. 
	nop			;5744	00 	. 
	nop			;5745	00 	. 
	nop			;5746	00 	. 
	nop			;5747	00 	. 
	nop			;5748	00 	. 
	nop			;5749	00 	. 
	nop			;574a	00 	. 
	nop			;574b	00 	. 
	nop			;574c	00 	. 
	nop			;574d	00 	. 
	nop			;574e	00 	. 
	nop			;574f	00 	. 
	nop			;5750	00 	. 
	nop			;5751	00 	. 
	nop			;5752	00 	. 
	nop			;5753	00 	. 
	nop			;5754	00 	. 
	nop			;5755	00 	. 
	nop			;5756	00 	. 
	nop			;5757	00 	. 
	nop			;5758	00 	. 
	nop			;5759	00 	. 
	nop			;575a	00 	. 
	nop			;575b	00 	. 
	nop			;575c	00 	. 
	nop			;575d	00 	. 
	nop			;575e	00 	. 
	nop			;575f	00 	. 
	nop			;5760	00 	. 
	nop			;5761	00 	. 
	nop			;5762	00 	. 
	nop			;5763	00 	. 
	nop			;5764	00 	. 
	nop			;5765	00 	. 
	nop			;5766	00 	. 
	nop			;5767	00 	. 
	nop			;5768	00 	. 
	nop			;5769	00 	. 
	nop			;576a	00 	. 
	nop			;576b	00 	. 
	nop			;576c	00 	. 
	nop			;576d	00 	. 
	nop			;576e	00 	. 
	nop			;576f	00 	. 
	nop			;5770	00 	. 
	nop			;5771	00 	. 
	nop			;5772	00 	. 
	nop			;5773	00 	. 
	nop			;5774	00 	. 
	nop			;5775	00 	. 
	nop			;5776	00 	. 
	nop			;5777	00 	. 
	nop			;5778	00 	. 
	nop			;5779	00 	. 
	nop			;577a	00 	. 
	nop			;577b	00 	. 
	nop			;577c	00 	. 
	nop			;577d	00 	. 
	nop			;577e	00 	. 
	nop			;577f	00 	. 
	nop			;5780	00 	. 
	nop			;5781	00 	. 
	nop			;5782	00 	. 
	nop			;5783	00 	. 
	nop			;5784	00 	. 
	nop			;5785	00 	. 
	nop			;5786	00 	. 
	nop			;5787	00 	. 
	nop			;5788	00 	. 
	nop			;5789	00 	. 
	nop			;578a	00 	. 
	nop			;578b	00 	. 
	nop			;578c	00 	. 
	nop			;578d	00 	. 
	nop			;578e	00 	. 
	nop			;578f	00 	. 
	nop			;5790	00 	. 
	nop			;5791	00 	. 
	nop			;5792	00 	. 
	nop			;5793	00 	. 
	nop			;5794	00 	. 
	nop			;5795	00 	. 
	nop			;5796	00 	. 
	nop			;5797	00 	. 
	nop			;5798	00 	. 
	nop			;5799	00 	. 
	nop			;579a	00 	. 
	nop			;579b	00 	. 
	nop			;579c	00 	. 
	nop			;579d	00 	. 
	nop			;579e	00 	. 
	nop			;579f	00 	. 
	nop			;57a0	00 	. 
	nop			;57a1	00 	. 
	nop			;57a2	00 	. 
	nop			;57a3	00 	. 
	nop			;57a4	00 	. 
	nop			;57a5	00 	. 
	nop			;57a6	00 	. 
	nop			;57a7	00 	. 
	nop			;57a8	00 	. 
	nop			;57a9	00 	. 
	nop			;57aa	00 	. 
	nop			;57ab	00 	. 
	nop			;57ac	00 	. 
	nop			;57ad	00 	. 
	nop			;57ae	00 	. 
	nop			;57af	00 	. 
	nop			;57b0	00 	. 
	nop			;57b1	00 	. 
	nop			;57b2	00 	. 
	nop			;57b3	00 	. 
	nop			;57b4	00 	. 
	nop			;57b5	00 	. 
	nop			;57b6	00 	. 
	nop			;57b7	00 	. 
	nop			;57b8	00 	. 
	nop			;57b9	00 	. 
	nop			;57ba	00 	. 
	nop			;57bb	00 	. 
	nop			;57bc	00 	. 
	nop			;57bd	00 	. 
	nop			;57be	00 	. 
	nop			;57bf	00 	. 
	nop			;57c0	00 	. 
	nop			;57c1	00 	. 
	nop			;57c2	00 	. 
	nop			;57c3	00 	. 
	nop			;57c4	00 	. 
	nop			;57c5	00 	. 
	nop			;57c6	00 	. 
	nop			;57c7	00 	. 
	nop			;57c8	00 	. 
	nop			;57c9	00 	. 
	nop			;57ca	00 	. 
	nop			;57cb	00 	. 
	nop			;57cc	00 	. 
	nop			;57cd	00 	. 
	nop			;57ce	00 	. 
	nop			;57cf	00 	. 
	nop			;57d0	00 	. 
	nop			;57d1	00 	. 
	nop			;57d2	00 	. 
	nop			;57d3	00 	. 
	nop			;57d4	00 	. 
	nop			;57d5	00 	. 
	nop			;57d6	00 	. 
	nop			;57d7	00 	. 
	nop			;57d8	00 	. 
	nop			;57d9	00 	. 
	nop			;57da	00 	. 
	nop			;57db	00 	. 
	nop			;57dc	00 	. 
	nop			;57dd	00 	. 
	nop			;57de	00 	. 
	nop			;57df	00 	. 
	nop			;57e0	00 	. 
	nop			;57e1	00 	. 
	nop			;57e2	00 	. 
	nop			;57e3	00 	. 
	nop			;57e4	00 	. 
	nop			;57e5	00 	. 
	nop			;57e6	00 	. 
	nop			;57e7	00 	. 
	nop			;57e8	00 	. 
	nop			;57e9	00 	. 
	nop			;57ea	00 	. 
	nop			;57eb	00 	. 
	nop			;57ec	00 	. 
	nop			;57ed	00 	. 
	nop			;57ee	00 	. 
	nop			;57ef	00 	. 
	nop			;57f0	00 	. 
	nop			;57f1	00 	. 
	nop			;57f2	00 	. 
	nop			;57f3	00 	. 
	nop			;57f4	00 	. 
	nop			;57f5	00 	. 
	nop			;57f6	00 	. 
	nop			;57f7	00 	. 
	nop			;57f8	00 	. 
	nop			;57f9	00 	. 
	nop			;57fa	00 	. 
	nop			;57fb	00 	. 
	nop			;57fc	00 	. 
	nop			;57fd	00 	. 
	nop			;57fe	00 	. 
	nop			;57ff	00 	. 
	nop			;5800	00 	. 
	nop			;5801	00 	. 
	nop			;5802	00 	. 
	nop			;5803	00 	. 
	nop			;5804	00 	. 
	nop			;5805	00 	. 
	nop			;5806	00 	. 
	nop			;5807	00 	. 
	nop			;5808	00 	. 
	nop			;5809	00 	. 
	nop			;580a	00 	. 
	nop			;580b	00 	. 
	nop			;580c	00 	. 
	nop			;580d	00 	. 
	nop			;580e	00 	. 
	nop			;580f	00 	. 
	nop			;5810	00 	. 
	nop			;5811	00 	. 
	nop			;5812	00 	. 
	nop			;5813	00 	. 
	nop			;5814	00 	. 
	nop			;5815	00 	. 
	nop			;5816	00 	. 
	nop			;5817	00 	. 
	nop			;5818	00 	. 
	nop			;5819	00 	. 
	nop			;581a	00 	. 
	nop			;581b	00 	. 
	nop			;581c	00 	. 
	nop			;581d	00 	. 
	nop			;581e	00 	. 
	nop			;581f	00 	. 
	nop			;5820	00 	. 
	nop			;5821	00 	. 
	nop			;5822	00 	. 
	nop			;5823	00 	. 
	nop			;5824	00 	. 
	nop			;5825	00 	. 
	nop			;5826	00 	. 
	nop			;5827	00 	. 
	nop			;5828	00 	. 
	nop			;5829	00 	. 
	nop			;582a	00 	. 
	nop			;582b	00 	. 
	nop			;582c	00 	. 
	nop			;582d	00 	. 
	nop			;582e	00 	. 
	nop			;582f	00 	. 
	nop			;5830	00 	. 
	nop			;5831	00 	. 
	nop			;5832	00 	. 
	nop			;5833	00 	. 
	nop			;5834	00 	. 
	nop			;5835	00 	. 
	nop			;5836	00 	. 
	nop			;5837	00 	. 
	nop			;5838	00 	. 
	nop			;5839	00 	. 
	nop			;583a	00 	. 
	nop			;583b	00 	. 
	nop			;583c	00 	. 
	nop			;583d	00 	. 
	nop			;583e	00 	. 
	nop			;583f	00 	. 
	nop			;5840	00 	. 
	nop			;5841	00 	. 
	nop			;5842	00 	. 
	nop			;5843	00 	. 
	nop			;5844	00 	. 
	nop			;5845	00 	. 
	nop			;5846	00 	. 
	nop			;5847	00 	. 
	nop			;5848	00 	. 
	nop			;5849	00 	. 
	nop			;584a	00 	. 
	nop			;584b	00 	. 
	nop			;584c	00 	. 
	nop			;584d	00 	. 
	nop			;584e	00 	. 
	nop			;584f	00 	. 
	nop			;5850	00 	. 
	nop			;5851	00 	. 
	nop			;5852	00 	. 
	nop			;5853	00 	. 
	nop			;5854	00 	. 
	nop			;5855	00 	. 
	nop			;5856	00 	. 
	nop			;5857	00 	. 
	nop			;5858	00 	. 
	nop			;5859	00 	. 
	nop			;585a	00 	. 
	nop			;585b	00 	. 
	nop			;585c	00 	. 
	nop			;585d	00 	. 
	nop			;585e	00 	. 
	nop			;585f	00 	. 
	nop			;5860	00 	. 
	nop			;5861	00 	. 
	nop			;5862	00 	. 
	nop			;5863	00 	. 
	nop			;5864	00 	. 
	nop			;5865	00 	. 
	nop			;5866	00 	. 
	nop			;5867	00 	. 
	nop			;5868	00 	. 
	nop			;5869	00 	. 
	nop			;586a	00 	. 
	nop			;586b	00 	. 
	nop			;586c	00 	. 
	nop			;586d	00 	. 
	nop			;586e	00 	. 
	nop			;586f	00 	. 
	nop			;5870	00 	. 
	nop			;5871	00 	. 
	nop			;5872	00 	. 
	nop			;5873	00 	. 
	nop			;5874	00 	. 
	nop			;5875	00 	. 
	nop			;5876	00 	. 
	nop			;5877	00 	. 
	nop			;5878	00 	. 
	nop			;5879	00 	. 
	nop			;587a	00 	. 
	nop			;587b	00 	. 
	nop			;587c	00 	. 
	nop			;587d	00 	. 
	nop			;587e	00 	. 
	nop			;587f	00 	. 
	nop			;5880	00 	. 
	nop			;5881	00 	. 
	nop			;5882	00 	. 
	nop			;5883	00 	. 
	nop			;5884	00 	. 
	nop			;5885	00 	. 
	nop			;5886	00 	. 
	nop			;5887	00 	. 
	nop			;5888	00 	. 
	nop			;5889	00 	. 
	nop			;588a	00 	. 
	nop			;588b	00 	. 
	nop			;588c	00 	. 
	nop			;588d	00 	. 
	nop			;588e	00 	. 
	nop			;588f	00 	. 
	nop			;5890	00 	. 
	nop			;5891	00 	. 
	nop			;5892	00 	. 
	nop			;5893	00 	. 
	nop			;5894	00 	. 
	nop			;5895	00 	. 
	nop			;5896	00 	. 
	nop			;5897	00 	. 
	nop			;5898	00 	. 
	nop			;5899	00 	. 
	nop			;589a	00 	. 
	nop			;589b	00 	. 
	nop			;589c	00 	. 
	nop			;589d	00 	. 
	nop			;589e	00 	. 
	nop			;589f	00 	. 
	nop			;58a0	00 	. 
	nop			;58a1	00 	. 
	nop			;58a2	00 	. 
	nop			;58a3	00 	. 
	nop			;58a4	00 	. 
	nop			;58a5	00 	. 
	nop			;58a6	00 	. 
	nop			;58a7	00 	. 
	nop			;58a8	00 	. 
	nop			;58a9	00 	. 
	nop			;58aa	00 	. 
	nop			;58ab	00 	. 
	nop			;58ac	00 	. 
	nop			;58ad	00 	. 
	nop			;58ae	00 	. 
	nop			;58af	00 	. 
	nop			;58b0	00 	. 
	nop			;58b1	00 	. 
	nop			;58b2	00 	. 
	nop			;58b3	00 	. 
	nop			;58b4	00 	. 
	nop			;58b5	00 	. 
	nop			;58b6	00 	. 
	nop			;58b7	00 	. 
	nop			;58b8	00 	. 
	nop			;58b9	00 	. 
	nop			;58ba	00 	. 
	nop			;58bb	00 	. 
	nop			;58bc	00 	. 
	nop			;58bd	00 	. 
	nop			;58be	00 	. 
	nop			;58bf	00 	. 
	nop			;58c0	00 	. 
	nop			;58c1	00 	. 
	nop			;58c2	00 	. 
	nop			;58c3	00 	. 
	nop			;58c4	00 	. 
	nop			;58c5	00 	. 
	nop			;58c6	00 	. 
	nop			;58c7	00 	. 
	nop			;58c8	00 	. 
	nop			;58c9	00 	. 
	nop			;58ca	00 	. 
	nop			;58cb	00 	. 
	nop			;58cc	00 	. 
	nop			;58cd	00 	. 
	nop			;58ce	00 	. 
	nop			;58cf	00 	. 
	nop			;58d0	00 	. 
	nop			;58d1	00 	. 
	nop			;58d2	00 	. 
	nop			;58d3	00 	. 
	nop			;58d4	00 	. 
	nop			;58d5	00 	. 
	nop			;58d6	00 	. 
	nop			;58d7	00 	. 
	nop			;58d8	00 	. 
	nop			;58d9	00 	. 
	nop			;58da	00 	. 
	nop			;58db	00 	. 
	nop			;58dc	00 	. 
	nop			;58dd	00 	. 
	nop			;58de	00 	. 
	nop			;58df	00 	. 
	nop			;58e0	00 	. 
	nop			;58e1	00 	. 
	nop			;58e2	00 	. 
	nop			;58e3	00 	. 
	nop			;58e4	00 	. 
	nop			;58e5	00 	. 
	nop			;58e6	00 	. 
	nop			;58e7	00 	. 
	nop			;58e8	00 	. 
	nop			;58e9	00 	. 
	nop			;58ea	00 	. 
	nop			;58eb	00 	. 
	nop			;58ec	00 	. 
	nop			;58ed	00 	. 
	nop			;58ee	00 	. 
	nop			;58ef	00 	. 
	nop			;58f0	00 	. 
	nop			;58f1	00 	. 
	nop			;58f2	00 	. 
	nop			;58f3	00 	. 
	nop			;58f4	00 	. 
	nop			;58f5	00 	. 
	nop			;58f6	00 	. 
	nop			;58f7	00 	. 
	nop			;58f8	00 	. 
	nop			;58f9	00 	. 
	nop			;58fa	00 	. 
	nop			;58fb	00 	. 
	nop			;58fc	00 	. 
	nop			;58fd	00 	. 
	nop			;58fe	00 	. 
	nop			;58ff	00 	. 
	nop			;5900	00 	. 
	nop			;5901	00 	. 
	nop			;5902	00 	. 
	nop			;5903	00 	. 
	nop			;5904	00 	. 
	nop			;5905	00 	. 
	nop			;5906	00 	. 
	nop			;5907	00 	. 
	nop			;5908	00 	. 
	nop			;5909	00 	. 
	nop			;590a	00 	. 
	nop			;590b	00 	. 
	nop			;590c	00 	. 
	nop			;590d	00 	. 
	nop			;590e	00 	. 
	nop			;590f	00 	. 
	nop			;5910	00 	. 
	nop			;5911	00 	. 
	nop			;5912	00 	. 
	nop			;5913	00 	. 
	nop			;5914	00 	. 
	nop			;5915	00 	. 
	nop			;5916	00 	. 
	nop			;5917	00 	. 
	nop			;5918	00 	. 
	nop			;5919	00 	. 
	nop			;591a	00 	. 
	nop			;591b	00 	. 
	nop			;591c	00 	. 
	nop			;591d	00 	. 
	nop			;591e	00 	. 
	nop			;591f	00 	. 
	nop			;5920	00 	. 
	nop			;5921	00 	. 
	nop			;5922	00 	. 
	nop			;5923	00 	. 
	nop			;5924	00 	. 
	nop			;5925	00 	. 
	nop			;5926	00 	. 
	nop			;5927	00 	. 
	nop			;5928	00 	. 
	nop			;5929	00 	. 
	nop			;592a	00 	. 
	nop			;592b	00 	. 
	nop			;592c	00 	. 
	nop			;592d	00 	. 
	nop			;592e	00 	. 
	nop			;592f	00 	. 
	nop			;5930	00 	. 
	nop			;5931	00 	. 
	nop			;5932	00 	. 
	nop			;5933	00 	. 
	nop			;5934	00 	. 
	nop			;5935	00 	. 
	nop			;5936	00 	. 
	nop			;5937	00 	. 
	nop			;5938	00 	. 
	nop			;5939	00 	. 
	nop			;593a	00 	. 
	nop			;593b	00 	. 
	nop			;593c	00 	. 
	nop			;593d	00 	. 
	nop			;593e	00 	. 
	nop			;593f	00 	. 
	nop			;5940	00 	. 
	nop			;5941	00 	. 
	nop			;5942	00 	. 
	nop			;5943	00 	. 
	nop			;5944	00 	. 
	nop			;5945	00 	. 
	nop			;5946	00 	. 
	nop			;5947	00 	. 
	nop			;5948	00 	. 
	nop			;5949	00 	. 
	nop			;594a	00 	. 
	nop			;594b	00 	. 
	nop			;594c	00 	. 
	nop			;594d	00 	. 
	nop			;594e	00 	. 
	nop			;594f	00 	. 
	nop			;5950	00 	. 
	nop			;5951	00 	. 
	nop			;5952	00 	. 
	nop			;5953	00 	. 
	nop			;5954	00 	. 
	nop			;5955	00 	. 
	nop			;5956	00 	. 
	nop			;5957	00 	. 
	nop			;5958	00 	. 
	nop			;5959	00 	. 
	nop			;595a	00 	. 
	nop			;595b	00 	. 
	nop			;595c	00 	. 
	nop			;595d	00 	. 
	nop			;595e	00 	. 
	nop			;595f	00 	. 
	nop			;5960	00 	. 
	nop			;5961	00 	. 
	nop			;5962	00 	. 
	nop			;5963	00 	. 
	nop			;5964	00 	. 
	nop			;5965	00 	. 
	nop			;5966	00 	. 
	nop			;5967	00 	. 
	nop			;5968	00 	. 
	nop			;5969	00 	. 
	nop			;596a	00 	. 
	nop			;596b	00 	. 
	nop			;596c	00 	. 
	nop			;596d	00 	. 
	nop			;596e	00 	. 
	nop			;596f	00 	. 
	nop			;5970	00 	. 
	nop			;5971	00 	. 
	nop			;5972	00 	. 
	nop			;5973	00 	. 
	nop			;5974	00 	. 
	nop			;5975	00 	. 
	nop			;5976	00 	. 
	nop			;5977	00 	. 
	nop			;5978	00 	. 
	nop			;5979	00 	. 
	nop			;597a	00 	. 
	nop			;597b	00 	. 
	nop			;597c	00 	. 
	nop			;597d	00 	. 
	nop			;597e	00 	. 
	nop			;597f	00 	. 
	nop			;5980	00 	. 
	nop			;5981	00 	. 
	nop			;5982	00 	. 
	nop			;5983	00 	. 
	nop			;5984	00 	. 
	nop			;5985	00 	. 
	nop			;5986	00 	. 
	nop			;5987	00 	. 
	nop			;5988	00 	. 
	nop			;5989	00 	. 
	nop			;598a	00 	. 
	nop			;598b	00 	. 
	nop			;598c	00 	. 
	nop			;598d	00 	. 
	nop			;598e	00 	. 
	nop			;598f	00 	. 
	nop			;5990	00 	. 
	nop			;5991	00 	. 
	nop			;5992	00 	. 
	nop			;5993	00 	. 
	nop			;5994	00 	. 
	nop			;5995	00 	. 
	nop			;5996	00 	. 
	nop			;5997	00 	. 
	nop			;5998	00 	. 
	nop			;5999	00 	. 
	nop			;599a	00 	. 
	nop			;599b	00 	. 
	nop			;599c	00 	. 
	nop			;599d	00 	. 
	nop			;599e	00 	. 
	nop			;599f	00 	. 
	nop			;59a0	00 	. 
	nop			;59a1	00 	. 
	nop			;59a2	00 	. 
	nop			;59a3	00 	. 
	nop			;59a4	00 	. 
	nop			;59a5	00 	. 
	nop			;59a6	00 	. 
	nop			;59a7	00 	. 
	nop			;59a8	00 	. 
	nop			;59a9	00 	. 
	nop			;59aa	00 	. 
	nop			;59ab	00 	. 
	nop			;59ac	00 	. 
	nop			;59ad	00 	. 
	nop			;59ae	00 	. 
	nop			;59af	00 	. 
	nop			;59b0	00 	. 
	nop			;59b1	00 	. 
	nop			;59b2	00 	. 
	nop			;59b3	00 	. 
	nop			;59b4	00 	. 
	nop			;59b5	00 	. 
	nop			;59b6	00 	. 
	nop			;59b7	00 	. 
	nop			;59b8	00 	. 
	nop			;59b9	00 	. 
	nop			;59ba	00 	. 
	nop			;59bb	00 	. 
	nop			;59bc	00 	. 
	nop			;59bd	00 	. 
	nop			;59be	00 	. 
	nop			;59bf	00 	. 
	nop			;59c0	00 	. 
	nop			;59c1	00 	. 
	nop			;59c2	00 	. 
	nop			;59c3	00 	. 
	nop			;59c4	00 	. 
	nop			;59c5	00 	. 
	nop			;59c6	00 	. 
	nop			;59c7	00 	. 
	nop			;59c8	00 	. 
	nop			;59c9	00 	. 
	nop			;59ca	00 	. 
	nop			;59cb	00 	. 
	nop			;59cc	00 	. 
	nop			;59cd	00 	. 
	nop			;59ce	00 	. 
	nop			;59cf	00 	. 
	nop			;59d0	00 	. 
	nop			;59d1	00 	. 
	nop			;59d2	00 	. 
	nop			;59d3	00 	. 
	nop			;59d4	00 	. 
	nop			;59d5	00 	. 
	nop			;59d6	00 	. 
	nop			;59d7	00 	. 
	nop			;59d8	00 	. 
	nop			;59d9	00 	. 
	nop			;59da	00 	. 
	nop			;59db	00 	. 
	nop			;59dc	00 	. 
	nop			;59dd	00 	. 
	nop			;59de	00 	. 
	nop			;59df	00 	. 
	nop			;59e0	00 	. 
	nop			;59e1	00 	. 
	nop			;59e2	00 	. 
	nop			;59e3	00 	. 
	nop			;59e4	00 	. 
	nop			;59e5	00 	. 
	nop			;59e6	00 	. 
	nop			;59e7	00 	. 
	nop			;59e8	00 	. 
	nop			;59e9	00 	. 
	nop			;59ea	00 	. 
	nop			;59eb	00 	. 
	nop			;59ec	00 	. 
	nop			;59ed	00 	. 
	nop			;59ee	00 	. 
	nop			;59ef	00 	. 
	nop			;59f0	00 	. 
	nop			;59f1	00 	. 
	nop			;59f2	00 	. 
	nop			;59f3	00 	. 
	nop			;59f4	00 	. 
	nop			;59f5	00 	. 
	nop			;59f6	00 	. 
	nop			;59f7	00 	. 
	nop			;59f8	00 	. 
	nop			;59f9	00 	. 
	nop			;59fa	00 	. 
	nop			;59fb	00 	. 
	nop			;59fc	00 	. 
	nop			;59fd	00 	. 
	nop			;59fe	00 	. 
	nop			;59ff	00 	. 
	nop			;5a00	00 	. 
	nop			;5a01	00 	. 
	nop			;5a02	00 	. 
	nop			;5a03	00 	. 
	nop			;5a04	00 	. 
	nop			;5a05	00 	. 
	nop			;5a06	00 	. 
	nop			;5a07	00 	. 
	nop			;5a08	00 	. 
	nop			;5a09	00 	. 
	nop			;5a0a	00 	. 
	nop			;5a0b	00 	. 
	nop			;5a0c	00 	. 
	nop			;5a0d	00 	. 
	nop			;5a0e	00 	. 
	nop			;5a0f	00 	. 
	nop			;5a10	00 	. 
	nop			;5a11	00 	. 
	nop			;5a12	00 	. 
	nop			;5a13	00 	. 
	nop			;5a14	00 	. 
	nop			;5a15	00 	. 
	nop			;5a16	00 	. 
	nop			;5a17	00 	. 
	nop			;5a18	00 	. 
	nop			;5a19	00 	. 
	nop			;5a1a	00 	. 
	nop			;5a1b	00 	. 
	nop			;5a1c	00 	. 
	nop			;5a1d	00 	. 
	nop			;5a1e	00 	. 
	nop			;5a1f	00 	. 
	nop			;5a20	00 	. 
	nop			;5a21	00 	. 
	nop			;5a22	00 	. 
	nop			;5a23	00 	. 
	nop			;5a24	00 	. 
	nop			;5a25	00 	. 
	nop			;5a26	00 	. 
	nop			;5a27	00 	. 
	nop			;5a28	00 	. 
	nop			;5a29	00 	. 
	nop			;5a2a	00 	. 
	nop			;5a2b	00 	. 
	nop			;5a2c	00 	. 
	nop			;5a2d	00 	. 
	nop			;5a2e	00 	. 
	nop			;5a2f	00 	. 
	nop			;5a30	00 	. 
	nop			;5a31	00 	. 
	nop			;5a32	00 	. 
	nop			;5a33	00 	. 
	nop			;5a34	00 	. 
	nop			;5a35	00 	. 
	nop			;5a36	00 	. 
	nop			;5a37	00 	. 
	nop			;5a38	00 	. 
	nop			;5a39	00 	. 
	nop			;5a3a	00 	. 
	nop			;5a3b	00 	. 
	nop			;5a3c	00 	. 
	nop			;5a3d	00 	. 
	nop			;5a3e	00 	. 
	nop			;5a3f	00 	. 
	nop			;5a40	00 	. 
	nop			;5a41	00 	. 
	nop			;5a42	00 	. 
	nop			;5a43	00 	. 
	nop			;5a44	00 	. 
	nop			;5a45	00 	. 
	nop			;5a46	00 	. 
	nop			;5a47	00 	. 
	nop			;5a48	00 	. 
	nop			;5a49	00 	. 
	nop			;5a4a	00 	. 
	nop			;5a4b	00 	. 
	nop			;5a4c	00 	. 
	nop			;5a4d	00 	. 
	nop			;5a4e	00 	. 
	nop			;5a4f	00 	. 
	nop			;5a50	00 	. 
	nop			;5a51	00 	. 
	nop			;5a52	00 	. 
	nop			;5a53	00 	. 
	nop			;5a54	00 	. 
	nop			;5a55	00 	. 
	nop			;5a56	00 	. 
	nop			;5a57	00 	. 
	nop			;5a58	00 	. 
	nop			;5a59	00 	. 
	nop			;5a5a	00 	. 
	nop			;5a5b	00 	. 
	nop			;5a5c	00 	. 
	nop			;5a5d	00 	. 
	nop			;5a5e	00 	. 
	nop			;5a5f	00 	. 
	nop			;5a60	00 	. 
	nop			;5a61	00 	. 
	nop			;5a62	00 	. 
	nop			;5a63	00 	. 
	nop			;5a64	00 	. 
	nop			;5a65	00 	. 
	nop			;5a66	00 	. 
	nop			;5a67	00 	. 
	nop			;5a68	00 	. 
	nop			;5a69	00 	. 
	nop			;5a6a	00 	. 
	nop			;5a6b	00 	. 
	nop			;5a6c	00 	. 
	nop			;5a6d	00 	. 
	nop			;5a6e	00 	. 
	nop			;5a6f	00 	. 
	nop			;5a70	00 	. 
	nop			;5a71	00 	. 
	nop			;5a72	00 	. 
	nop			;5a73	00 	. 
	nop			;5a74	00 	. 
	nop			;5a75	00 	. 
	nop			;5a76	00 	. 
	nop			;5a77	00 	. 
	nop			;5a78	00 	. 
	nop			;5a79	00 	. 
	nop			;5a7a	00 	. 
	nop			;5a7b	00 	. 
	nop			;5a7c	00 	. 
	nop			;5a7d	00 	. 
	nop			;5a7e	00 	. 
	nop			;5a7f	00 	. 
	nop			;5a80	00 	. 
	nop			;5a81	00 	. 
	nop			;5a82	00 	. 
	nop			;5a83	00 	. 
	nop			;5a84	00 	. 
	nop			;5a85	00 	. 
	nop			;5a86	00 	. 
	nop			;5a87	00 	. 
	nop			;5a88	00 	. 
	nop			;5a89	00 	. 
	nop			;5a8a	00 	. 
	nop			;5a8b	00 	. 
	nop			;5a8c	00 	. 
	nop			;5a8d	00 	. 
	nop			;5a8e	00 	. 
	nop			;5a8f	00 	. 
	nop			;5a90	00 	. 
	nop			;5a91	00 	. 
	nop			;5a92	00 	. 
	nop			;5a93	00 	. 
	nop			;5a94	00 	. 
	nop			;5a95	00 	. 
	nop			;5a96	00 	. 
	nop			;5a97	00 	. 
	nop			;5a98	00 	. 
	nop			;5a99	00 	. 
	nop			;5a9a	00 	. 
	nop			;5a9b	00 	. 
	nop			;5a9c	00 	. 
	nop			;5a9d	00 	. 
	nop			;5a9e	00 	. 
	nop			;5a9f	00 	. 
	nop			;5aa0	00 	. 
	nop			;5aa1	00 	. 
	nop			;5aa2	00 	. 
	nop			;5aa3	00 	. 
	nop			;5aa4	00 	. 
	nop			;5aa5	00 	. 
	nop			;5aa6	00 	. 
	nop			;5aa7	00 	. 
	nop			;5aa8	00 	. 
	nop			;5aa9	00 	. 
	nop			;5aaa	00 	. 
	nop			;5aab	00 	. 
	nop			;5aac	00 	. 
	nop			;5aad	00 	. 
	nop			;5aae	00 	. 
	nop			;5aaf	00 	. 
	nop			;5ab0	00 	. 
	nop			;5ab1	00 	. 
	nop			;5ab2	00 	. 
	nop			;5ab3	00 	. 
	nop			;5ab4	00 	. 
	nop			;5ab5	00 	. 
	nop			;5ab6	00 	. 
	nop			;5ab7	00 	. 
	nop			;5ab8	00 	. 
	nop			;5ab9	00 	. 
	nop			;5aba	00 	. 
	nop			;5abb	00 	. 
	nop			;5abc	00 	. 
	nop			;5abd	00 	. 
	nop			;5abe	00 	. 
	nop			;5abf	00 	. 
	nop			;5ac0	00 	. 
	nop			;5ac1	00 	. 
	nop			;5ac2	00 	. 
	nop			;5ac3	00 	. 
	nop			;5ac4	00 	. 
	nop			;5ac5	00 	. 
	nop			;5ac6	00 	. 
	nop			;5ac7	00 	. 
	nop			;5ac8	00 	. 
	nop			;5ac9	00 	. 
	nop			;5aca	00 	. 
	nop			;5acb	00 	. 
	nop			;5acc	00 	. 
	nop			;5acd	00 	. 
	nop			;5ace	00 	. 
	nop			;5acf	00 	. 
	nop			;5ad0	00 	. 
	nop			;5ad1	00 	. 
	nop			;5ad2	00 	. 
	nop			;5ad3	00 	. 
	nop			;5ad4	00 	. 
	nop			;5ad5	00 	. 
	nop			;5ad6	00 	. 
	nop			;5ad7	00 	. 
	nop			;5ad8	00 	. 
	nop			;5ad9	00 	. 
	nop			;5ada	00 	. 
	nop			;5adb	00 	. 
	nop			;5adc	00 	. 
	nop			;5add	00 	. 
	nop			;5ade	00 	. 
	nop			;5adf	00 	. 
	nop			;5ae0	00 	. 
	nop			;5ae1	00 	. 
	nop			;5ae2	00 	. 
	nop			;5ae3	00 	. 
	nop			;5ae4	00 	. 
	nop			;5ae5	00 	. 
	nop			;5ae6	00 	. 
	nop			;5ae7	00 	. 
	nop			;5ae8	00 	. 
	nop			;5ae9	00 	. 
	nop			;5aea	00 	. 
	nop			;5aeb	00 	. 
	nop			;5aec	00 	. 
	nop			;5aed	00 	. 
	nop			;5aee	00 	. 
	nop			;5aef	00 	. 
	nop			;5af0	00 	. 
	nop			;5af1	00 	. 
	nop			;5af2	00 	. 
	nop			;5af3	00 	. 
	nop			;5af4	00 	. 
	nop			;5af5	00 	. 
	nop			;5af6	00 	. 
	nop			;5af7	00 	. 
	nop			;5af8	00 	. 
	nop			;5af9	00 	. 
	nop			;5afa	00 	. 
	nop			;5afb	00 	. 
	nop			;5afc	00 	. 
	nop			;5afd	00 	. 
	nop			;5afe	00 	. 
	nop			;5aff	00 	. 
	nop			;5b00	00 	. 
	nop			;5b01	00 	. 
	nop			;5b02	00 	. 
	nop			;5b03	00 	. 
	nop			;5b04	00 	. 
	nop			;5b05	00 	. 
	nop			;5b06	00 	. 
	nop			;5b07	00 	. 
	nop			;5b08	00 	. 
	nop			;5b09	00 	. 
	nop			;5b0a	00 	. 
	nop			;5b0b	00 	. 
	nop			;5b0c	00 	. 
	nop			;5b0d	00 	. 
	nop			;5b0e	00 	. 
	nop			;5b0f	00 	. 
	nop			;5b10	00 	. 
	nop			;5b11	00 	. 
	nop			;5b12	00 	. 
	nop			;5b13	00 	. 
	nop			;5b14	00 	. 
	nop			;5b15	00 	. 
	nop			;5b16	00 	. 
	nop			;5b17	00 	. 
	nop			;5b18	00 	. 
	nop			;5b19	00 	. 
	nop			;5b1a	00 	. 
	nop			;5b1b	00 	. 
	nop			;5b1c	00 	. 
	nop			;5b1d	00 	. 
	nop			;5b1e	00 	. 
	nop			;5b1f	00 	. 
	nop			;5b20	00 	. 
	nop			;5b21	00 	. 
	nop			;5b22	00 	. 
	nop			;5b23	00 	. 
	nop			;5b24	00 	. 
	nop			;5b25	00 	. 
	nop			;5b26	00 	. 
	nop			;5b27	00 	. 
	nop			;5b28	00 	. 
	nop			;5b29	00 	. 
	nop			;5b2a	00 	. 
	nop			;5b2b	00 	. 
	nop			;5b2c	00 	. 
	nop			;5b2d	00 	. 
	nop			;5b2e	00 	. 
	nop			;5b2f	00 	. 
	nop			;5b30	00 	. 
	nop			;5b31	00 	. 
	nop			;5b32	00 	. 
	nop			;5b33	00 	. 
	nop			;5b34	00 	. 
	nop			;5b35	00 	. 
	nop			;5b36	00 	. 
	nop			;5b37	00 	. 
	nop			;5b38	00 	. 
	nop			;5b39	00 	. 
	nop			;5b3a	00 	. 
	nop			;5b3b	00 	. 
	nop			;5b3c	00 	. 
	nop			;5b3d	00 	. 
	nop			;5b3e	00 	. 
	nop			;5b3f	00 	. 
	nop			;5b40	00 	. 
	nop			;5b41	00 	. 
	nop			;5b42	00 	. 
	nop			;5b43	00 	. 
	nop			;5b44	00 	. 
	nop			;5b45	00 	. 
	nop			;5b46	00 	. 
	nop			;5b47	00 	. 
	nop			;5b48	00 	. 
	nop			;5b49	00 	. 
	nop			;5b4a	00 	. 
	nop			;5b4b	00 	. 
	nop			;5b4c	00 	. 
	nop			;5b4d	00 	. 
	nop			;5b4e	00 	. 
	nop			;5b4f	00 	. 
	nop			;5b50	00 	. 
	nop			;5b51	00 	. 
	nop			;5b52	00 	. 
	nop			;5b53	00 	. 
	nop			;5b54	00 	. 
	nop			;5b55	00 	. 
	nop			;5b56	00 	. 
	nop			;5b57	00 	. 
	nop			;5b58	00 	. 
	nop			;5b59	00 	. 
	nop			;5b5a	00 	. 
	nop			;5b5b	00 	. 
	nop			;5b5c	00 	. 
	nop			;5b5d	00 	. 
	nop			;5b5e	00 	. 
	nop			;5b5f	00 	. 
	nop			;5b60	00 	. 
	nop			;5b61	00 	. 
	nop			;5b62	00 	. 
	nop			;5b63	00 	. 
	nop			;5b64	00 	. 
	nop			;5b65	00 	. 
	nop			;5b66	00 	. 
	nop			;5b67	00 	. 
	nop			;5b68	00 	. 
	nop			;5b69	00 	. 
	nop			;5b6a	00 	. 
	nop			;5b6b	00 	. 
	nop			;5b6c	00 	. 
	nop			;5b6d	00 	. 
	nop			;5b6e	00 	. 
	nop			;5b6f	00 	. 
	nop			;5b70	00 	. 
	nop			;5b71	00 	. 
	nop			;5b72	00 	. 
	nop			;5b73	00 	. 
	nop			;5b74	00 	. 
	nop			;5b75	00 	. 
	nop			;5b76	00 	. 
	nop			;5b77	00 	. 
	nop			;5b78	00 	. 
	nop			;5b79	00 	. 
	nop			;5b7a	00 	. 
	nop			;5b7b	00 	. 
	nop			;5b7c	00 	. 
	nop			;5b7d	00 	. 
	nop			;5b7e	00 	. 
	nop			;5b7f	00 	. 
	nop			;5b80	00 	. 
	nop			;5b81	00 	. 
	nop			;5b82	00 	. 
	nop			;5b83	00 	. 
	nop			;5b84	00 	. 
	nop			;5b85	00 	. 
	nop			;5b86	00 	. 
	nop			;5b87	00 	. 
	nop			;5b88	00 	. 
	nop			;5b89	00 	. 
	nop			;5b8a	00 	. 
	nop			;5b8b	00 	. 
	nop			;5b8c	00 	. 
	nop			;5b8d	00 	. 
	nop			;5b8e	00 	. 
	nop			;5b8f	00 	. 
	nop			;5b90	00 	. 
	nop			;5b91	00 	. 
	nop			;5b92	00 	. 
	nop			;5b93	00 	. 
	nop			;5b94	00 	. 
	nop			;5b95	00 	. 
	nop			;5b96	00 	. 
	nop			;5b97	00 	. 
	nop			;5b98	00 	. 
	nop			;5b99	00 	. 
	nop			;5b9a	00 	. 
	nop			;5b9b	00 	. 
	nop			;5b9c	00 	. 
	nop			;5b9d	00 	. 
	nop			;5b9e	00 	. 
	nop			;5b9f	00 	. 
	nop			;5ba0	00 	. 
	nop			;5ba1	00 	. 
	nop			;5ba2	00 	. 
	nop			;5ba3	00 	. 
	nop			;5ba4	00 	. 
	nop			;5ba5	00 	. 
	nop			;5ba6	00 	. 
	nop			;5ba7	00 	. 
	nop			;5ba8	00 	. 
	nop			;5ba9	00 	. 
	nop			;5baa	00 	. 
	nop			;5bab	00 	. 
	nop			;5bac	00 	. 
	nop			;5bad	00 	. 
	nop			;5bae	00 	. 
	nop			;5baf	00 	. 
	nop			;5bb0	00 	. 
	nop			;5bb1	00 	. 
	nop			;5bb2	00 	. 
	nop			;5bb3	00 	. 
	nop			;5bb4	00 	. 
	nop			;5bb5	00 	. 
	nop			;5bb6	00 	. 
	nop			;5bb7	00 	. 
	nop			;5bb8	00 	. 
	nop			;5bb9	00 	. 
	nop			;5bba	00 	. 
	nop			;5bbb	00 	. 
	nop			;5bbc	00 	. 
	nop			;5bbd	00 	. 
	nop			;5bbe	00 	. 
	nop			;5bbf	00 	. 
	nop			;5bc0	00 	. 
	nop			;5bc1	00 	. 
	nop			;5bc2	00 	. 
	nop			;5bc3	00 	. 
	nop			;5bc4	00 	. 
	nop			;5bc5	00 	. 
	nop			;5bc6	00 	. 
	nop			;5bc7	00 	. 
	nop			;5bc8	00 	. 
	nop			;5bc9	00 	. 
	nop			;5bca	00 	. 
	nop			;5bcb	00 	. 
	nop			;5bcc	00 	. 
	nop			;5bcd	00 	. 
	nop			;5bce	00 	. 
	nop			;5bcf	00 	. 
	nop			;5bd0	00 	. 
	nop			;5bd1	00 	. 
	nop			;5bd2	00 	. 
	nop			;5bd3	00 	. 
	nop			;5bd4	00 	. 
	nop			;5bd5	00 	. 
	nop			;5bd6	00 	. 
	nop			;5bd7	00 	. 
	nop			;5bd8	00 	. 
	nop			;5bd9	00 	. 
	nop			;5bda	00 	. 
	nop			;5bdb	00 	. 
	nop			;5bdc	00 	. 
	nop			;5bdd	00 	. 
	nop			;5bde	00 	. 
	nop			;5bdf	00 	. 
	nop			;5be0	00 	. 
	nop			;5be1	00 	. 
	nop			;5be2	00 	. 
	nop			;5be3	00 	. 
	nop			;5be4	00 	. 
	nop			;5be5	00 	. 
	nop			;5be6	00 	. 
	nop			;5be7	00 	. 
	nop			;5be8	00 	. 
	nop			;5be9	00 	. 
	nop			;5bea	00 	. 
	nop			;5beb	00 	. 
	nop			;5bec	00 	. 
	nop			;5bed	00 	. 
	nop			;5bee	00 	. 
	nop			;5bef	00 	. 
	nop			;5bf0	00 	. 
	nop			;5bf1	00 	. 
	nop			;5bf2	00 	. 
	nop			;5bf3	00 	. 
	nop			;5bf4	00 	. 
	nop			;5bf5	00 	. 
	nop			;5bf6	00 	. 
	nop			;5bf7	00 	. 
	nop			;5bf8	00 	. 
	nop			;5bf9	00 	. 
	nop			;5bfa	00 	. 
	nop			;5bfb	00 	. 
	nop			;5bfc	00 	. 
	nop			;5bfd	00 	. 
	nop			;5bfe	00 	. 
	nop			;5bff	00 	. 
	nop			;5c00	00 	. 
	nop			;5c01	00 	. 
	nop			;5c02	00 	. 
	nop			;5c03	00 	. 
	nop			;5c04	00 	. 
	nop			;5c05	00 	. 
	nop			;5c06	00 	. 
	nop			;5c07	00 	. 
	nop			;5c08	00 	. 
	nop			;5c09	00 	. 
	nop			;5c0a	00 	. 
	nop			;5c0b	00 	. 
	nop			;5c0c	00 	. 
	nop			;5c0d	00 	. 
	nop			;5c0e	00 	. 
	nop			;5c0f	00 	. 
	nop			;5c10	00 	. 
	nop			;5c11	00 	. 
	nop			;5c12	00 	. 
	nop			;5c13	00 	. 
	nop			;5c14	00 	. 
	nop			;5c15	00 	. 
	nop			;5c16	00 	. 
	nop			;5c17	00 	. 
	nop			;5c18	00 	. 
	nop			;5c19	00 	. 
	nop			;5c1a	00 	. 
	nop			;5c1b	00 	. 
	nop			;5c1c	00 	. 
	nop			;5c1d	00 	. 
	nop			;5c1e	00 	. 
	nop			;5c1f	00 	. 
	nop			;5c20	00 	. 
	nop			;5c21	00 	. 
	nop			;5c22	00 	. 
	nop			;5c23	00 	. 
	nop			;5c24	00 	. 
	nop			;5c25	00 	. 
	nop			;5c26	00 	. 
	nop			;5c27	00 	. 
	nop			;5c28	00 	. 
	nop			;5c29	00 	. 
	nop			;5c2a	00 	. 
	nop			;5c2b	00 	. 
	nop			;5c2c	00 	. 
	nop			;5c2d	00 	. 
	nop			;5c2e	00 	. 
	nop			;5c2f	00 	. 
	nop			;5c30	00 	. 
	nop			;5c31	00 	. 
	nop			;5c32	00 	. 
	nop			;5c33	00 	. 
	nop			;5c34	00 	. 
	nop			;5c35	00 	. 
	nop			;5c36	00 	. 
	nop			;5c37	00 	. 
	nop			;5c38	00 	. 
	nop			;5c39	00 	. 
	nop			;5c3a	00 	. 
	nop			;5c3b	00 	. 
	nop			;5c3c	00 	. 
	nop			;5c3d	00 	. 
	nop			;5c3e	00 	. 
	nop			;5c3f	00 	. 
	nop			;5c40	00 	. 
	nop			;5c41	00 	. 
	nop			;5c42	00 	. 
	nop			;5c43	00 	. 
	nop			;5c44	00 	. 
	nop			;5c45	00 	. 
	nop			;5c46	00 	. 
	nop			;5c47	00 	. 
	nop			;5c48	00 	. 
	nop			;5c49	00 	. 
	nop			;5c4a	00 	. 
	nop			;5c4b	00 	. 
	nop			;5c4c	00 	. 
	nop			;5c4d	00 	. 
	nop			;5c4e	00 	. 
	nop			;5c4f	00 	. 
	nop			;5c50	00 	. 
	nop			;5c51	00 	. 
	nop			;5c52	00 	. 
	nop			;5c53	00 	. 
	nop			;5c54	00 	. 
	nop			;5c55	00 	. 
	nop			;5c56	00 	. 
	nop			;5c57	00 	. 
	nop			;5c58	00 	. 
	nop			;5c59	00 	. 
	nop			;5c5a	00 	. 
	nop			;5c5b	00 	. 
	nop			;5c5c	00 	. 
	nop			;5c5d	00 	. 
	nop			;5c5e	00 	. 
	nop			;5c5f	00 	. 
	nop			;5c60	00 	. 
	nop			;5c61	00 	. 
	nop			;5c62	00 	. 
	nop			;5c63	00 	. 
	nop			;5c64	00 	. 
	nop			;5c65	00 	. 
	nop			;5c66	00 	. 
	nop			;5c67	00 	. 
	nop			;5c68	00 	. 
	nop			;5c69	00 	. 
	nop			;5c6a	00 	. 
	nop			;5c6b	00 	. 
	nop			;5c6c	00 	. 
	nop			;5c6d	00 	. 
	nop			;5c6e	00 	. 
	nop			;5c6f	00 	. 
	nop			;5c70	00 	. 
	nop			;5c71	00 	. 
	nop			;5c72	00 	. 
	nop			;5c73	00 	. 
	nop			;5c74	00 	. 
	nop			;5c75	00 	. 
	nop			;5c76	00 	. 
	nop			;5c77	00 	. 
	nop			;5c78	00 	. 
	nop			;5c79	00 	. 
	nop			;5c7a	00 	. 
	nop			;5c7b	00 	. 
	nop			;5c7c	00 	. 
	nop			;5c7d	00 	. 
	nop			;5c7e	00 	. 
	nop			;5c7f	00 	. 
	nop			;5c80	00 	. 
	nop			;5c81	00 	. 
	nop			;5c82	00 	. 
	nop			;5c83	00 	. 
	nop			;5c84	00 	. 
	nop			;5c85	00 	. 
	nop			;5c86	00 	. 
	nop			;5c87	00 	. 
	nop			;5c88	00 	. 
	nop			;5c89	00 	. 
	nop			;5c8a	00 	. 
	nop			;5c8b	00 	. 
	nop			;5c8c	00 	. 
	nop			;5c8d	00 	. 
	nop			;5c8e	00 	. 
	nop			;5c8f	00 	. 
	nop			;5c90	00 	. 
	nop			;5c91	00 	. 
	nop			;5c92	00 	. 
	nop			;5c93	00 	. 
	nop			;5c94	00 	. 
	nop			;5c95	00 	. 
	nop			;5c96	00 	. 
	nop			;5c97	00 	. 
	nop			;5c98	00 	. 
	nop			;5c99	00 	. 
	nop			;5c9a	00 	. 
	nop			;5c9b	00 	. 
	nop			;5c9c	00 	. 
	nop			;5c9d	00 	. 
	nop			;5c9e	00 	. 
	nop			;5c9f	00 	. 
	nop			;5ca0	00 	. 
	nop			;5ca1	00 	. 
	nop			;5ca2	00 	. 
	nop			;5ca3	00 	. 
	nop			;5ca4	00 	. 
	nop			;5ca5	00 	. 
	nop			;5ca6	00 	. 
	nop			;5ca7	00 	. 
	nop			;5ca8	00 	. 
	nop			;5ca9	00 	. 
	nop			;5caa	00 	. 
	nop			;5cab	00 	. 
	nop			;5cac	00 	. 
	nop			;5cad	00 	. 
	nop			;5cae	00 	. 
	nop			;5caf	00 	. 
	nop			;5cb0	00 	. 
	nop			;5cb1	00 	. 
	nop			;5cb2	00 	. 
	nop			;5cb3	00 	. 
	nop			;5cb4	00 	. 
	nop			;5cb5	00 	. 
	nop			;5cb6	00 	. 
	nop			;5cb7	00 	. 
	nop			;5cb8	00 	. 
	nop			;5cb9	00 	. 
	nop			;5cba	00 	. 
	nop			;5cbb	00 	. 
	nop			;5cbc	00 	. 
	nop			;5cbd	00 	. 
	nop			;5cbe	00 	. 
	nop			;5cbf	00 	. 
	nop			;5cc0	00 	. 
	nop			;5cc1	00 	. 
	nop			;5cc2	00 	. 
	nop			;5cc3	00 	. 
	nop			;5cc4	00 	. 
	nop			;5cc5	00 	. 
	nop			;5cc6	00 	. 
	nop			;5cc7	00 	. 
	nop			;5cc8	00 	. 
	nop			;5cc9	00 	. 
	nop			;5cca	00 	. 
	nop			;5ccb	00 	. 
	nop			;5ccc	00 	. 
	nop			;5ccd	00 	. 
	nop			;5cce	00 	. 
	nop			;5ccf	00 	. 
	nop			;5cd0	00 	. 
	nop			;5cd1	00 	. 
	nop			;5cd2	00 	. 
	nop			;5cd3	00 	. 
	nop			;5cd4	00 	. 
	nop			;5cd5	00 	. 
	nop			;5cd6	00 	. 
	nop			;5cd7	00 	. 
	nop			;5cd8	00 	. 
	nop			;5cd9	00 	. 
	nop			;5cda	00 	. 
	nop			;5cdb	00 	. 
	nop			;5cdc	00 	. 
	nop			;5cdd	00 	. 
	nop			;5cde	00 	. 
	nop			;5cdf	00 	. 
	nop			;5ce0	00 	. 
	nop			;5ce1	00 	. 
	nop			;5ce2	00 	. 
	nop			;5ce3	00 	. 
	nop			;5ce4	00 	. 
	nop			;5ce5	00 	. 
	nop			;5ce6	00 	. 
	nop			;5ce7	00 	. 
	nop			;5ce8	00 	. 
	nop			;5ce9	00 	. 
	nop			;5cea	00 	. 
	nop			;5ceb	00 	. 
	nop			;5cec	00 	. 
	nop			;5ced	00 	. 
	nop			;5cee	00 	. 
	nop			;5cef	00 	. 
	nop			;5cf0	00 	. 
	nop			;5cf1	00 	. 
	nop			;5cf2	00 	. 
	nop			;5cf3	00 	. 
	nop			;5cf4	00 	. 
	nop			;5cf5	00 	. 
	nop			;5cf6	00 	. 
	nop			;5cf7	00 	. 
	nop			;5cf8	00 	. 
	nop			;5cf9	00 	. 
	nop			;5cfa	00 	. 
	nop			;5cfb	00 	. 
	nop			;5cfc	00 	. 
	nop			;5cfd	00 	. 
	nop			;5cfe	00 	. 
	nop			;5cff	00 	. 
	nop			;5d00	00 	. 
	nop			;5d01	00 	. 
	nop			;5d02	00 	. 
	nop			;5d03	00 	. 
	nop			;5d04	00 	. 
	nop			;5d05	00 	. 
	nop			;5d06	00 	. 
	nop			;5d07	00 	. 
	nop			;5d08	00 	. 
	nop			;5d09	00 	. 
	nop			;5d0a	00 	. 
	nop			;5d0b	00 	. 
	nop			;5d0c	00 	. 
	nop			;5d0d	00 	. 
	nop			;5d0e	00 	. 
	nop			;5d0f	00 	. 
	nop			;5d10	00 	. 
	nop			;5d11	00 	. 
	nop			;5d12	00 	. 
	nop			;5d13	00 	. 
	nop			;5d14	00 	. 
	nop			;5d15	00 	. 
	nop			;5d16	00 	. 
	nop			;5d17	00 	. 
	nop			;5d18	00 	. 
	nop			;5d19	00 	. 
	nop			;5d1a	00 	. 
	nop			;5d1b	00 	. 
	nop			;5d1c	00 	. 
	nop			;5d1d	00 	. 
	nop			;5d1e	00 	. 
	nop			;5d1f	00 	. 
	nop			;5d20	00 	. 
	nop			;5d21	00 	. 
	nop			;5d22	00 	. 
	nop			;5d23	00 	. 
	nop			;5d24	00 	. 
	nop			;5d25	00 	. 
	nop			;5d26	00 	. 
	nop			;5d27	00 	. 
	nop			;5d28	00 	. 
	nop			;5d29	00 	. 
	nop			;5d2a	00 	. 
	nop			;5d2b	00 	. 
	nop			;5d2c	00 	. 
	nop			;5d2d	00 	. 
	nop			;5d2e	00 	. 
	nop			;5d2f	00 	. 
	nop			;5d30	00 	. 
	nop			;5d31	00 	. 
	nop			;5d32	00 	. 
	nop			;5d33	00 	. 
	nop			;5d34	00 	. 
	nop			;5d35	00 	. 
	nop			;5d36	00 	. 
	nop			;5d37	00 	. 
	nop			;5d38	00 	. 
	nop			;5d39	00 	. 
	nop			;5d3a	00 	. 
	nop			;5d3b	00 	. 
	nop			;5d3c	00 	. 
	nop			;5d3d	00 	. 
	nop			;5d3e	00 	. 
	nop			;5d3f	00 	. 
	nop			;5d40	00 	. 
	nop			;5d41	00 	. 
	nop			;5d42	00 	. 
	nop			;5d43	00 	. 
	nop			;5d44	00 	. 
	nop			;5d45	00 	. 
	nop			;5d46	00 	. 
	nop			;5d47	00 	. 
	nop			;5d48	00 	. 
	nop			;5d49	00 	. 
	nop			;5d4a	00 	. 
	nop			;5d4b	00 	. 
	nop			;5d4c	00 	. 
	nop			;5d4d	00 	. 
	nop			;5d4e	00 	. 
	nop			;5d4f	00 	. 
	nop			;5d50	00 	. 
	nop			;5d51	00 	. 
	nop			;5d52	00 	. 
	nop			;5d53	00 	. 
	nop			;5d54	00 	. 
	nop			;5d55	00 	. 
	nop			;5d56	00 	. 
	nop			;5d57	00 	. 
	nop			;5d58	00 	. 
	nop			;5d59	00 	. 
	nop			;5d5a	00 	. 
	nop			;5d5b	00 	. 
	nop			;5d5c	00 	. 
	nop			;5d5d	00 	. 
	nop			;5d5e	00 	. 
	nop			;5d5f	00 	. 
	nop			;5d60	00 	. 
	nop			;5d61	00 	. 
	nop			;5d62	00 	. 
	nop			;5d63	00 	. 
	nop			;5d64	00 	. 
	nop			;5d65	00 	. 
	nop			;5d66	00 	. 
	nop			;5d67	00 	. 
	nop			;5d68	00 	. 
	nop			;5d69	00 	. 
	nop			;5d6a	00 	. 
	nop			;5d6b	00 	. 
	nop			;5d6c	00 	. 
	nop			;5d6d	00 	. 
	nop			;5d6e	00 	. 
	nop			;5d6f	00 	. 
	nop			;5d70	00 	. 
	nop			;5d71	00 	. 
	nop			;5d72	00 	. 
	nop			;5d73	00 	. 
	nop			;5d74	00 	. 
	nop			;5d75	00 	. 
	nop			;5d76	00 	. 
	nop			;5d77	00 	. 
	nop			;5d78	00 	. 
	nop			;5d79	00 	. 
	nop			;5d7a	00 	. 
	nop			;5d7b	00 	. 
	nop			;5d7c	00 	. 
	nop			;5d7d	00 	. 
	nop			;5d7e	00 	. 
	nop			;5d7f	00 	. 
	nop			;5d80	00 	. 
	nop			;5d81	00 	. 
	nop			;5d82	00 	. 
	nop			;5d83	00 	. 
	nop			;5d84	00 	. 
	nop			;5d85	00 	. 
	nop			;5d86	00 	. 
	nop			;5d87	00 	. 
	nop			;5d88	00 	. 
	nop			;5d89	00 	. 
	nop			;5d8a	00 	. 
	nop			;5d8b	00 	. 
	nop			;5d8c	00 	. 
	nop			;5d8d	00 	. 
	nop			;5d8e	00 	. 
	nop			;5d8f	00 	. 
	nop			;5d90	00 	. 
	nop			;5d91	00 	. 
	nop			;5d92	00 	. 
	nop			;5d93	00 	. 
	nop			;5d94	00 	. 
	nop			;5d95	00 	. 
	nop			;5d96	00 	. 
	nop			;5d97	00 	. 
	nop			;5d98	00 	. 
	nop			;5d99	00 	. 
	nop			;5d9a	00 	. 
	nop			;5d9b	00 	. 
	nop			;5d9c	00 	. 
	nop			;5d9d	00 	. 
	nop			;5d9e	00 	. 
	nop			;5d9f	00 	. 
	nop			;5da0	00 	. 
	nop			;5da1	00 	. 
	nop			;5da2	00 	. 
	nop			;5da3	00 	. 
	nop			;5da4	00 	. 
	nop			;5da5	00 	. 
	nop			;5da6	00 	. 
	nop			;5da7	00 	. 
	nop			;5da8	00 	. 
	nop			;5da9	00 	. 
	nop			;5daa	00 	. 
	nop			;5dab	00 	. 
	nop			;5dac	00 	. 
	nop			;5dad	00 	. 
	nop			;5dae	00 	. 
	nop			;5daf	00 	. 
	nop			;5db0	00 	. 
	nop			;5db1	00 	. 
	nop			;5db2	00 	. 
	nop			;5db3	00 	. 
	nop			;5db4	00 	. 
	nop			;5db5	00 	. 
	nop			;5db6	00 	. 
	nop			;5db7	00 	. 
	nop			;5db8	00 	. 
	nop			;5db9	00 	. 
	nop			;5dba	00 	. 
	nop			;5dbb	00 	. 
	nop			;5dbc	00 	. 
	nop			;5dbd	00 	. 
	nop			;5dbe	00 	. 
	nop			;5dbf	00 	. 
	nop			;5dc0	00 	. 
	nop			;5dc1	00 	. 
	nop			;5dc2	00 	. 
	nop			;5dc3	00 	. 
	nop			;5dc4	00 	. 
	nop			;5dc5	00 	. 
	nop			;5dc6	00 	. 
	nop			;5dc7	00 	. 
	nop			;5dc8	00 	. 
	nop			;5dc9	00 	. 
	nop			;5dca	00 	. 
	nop			;5dcb	00 	. 
	nop			;5dcc	00 	. 
	nop			;5dcd	00 	. 
	nop			;5dce	00 	. 
	nop			;5dcf	00 	. 
	nop			;5dd0	00 	. 
	nop			;5dd1	00 	. 
	nop			;5dd2	00 	. 
	nop			;5dd3	00 	. 
	nop			;5dd4	00 	. 
	nop			;5dd5	00 	. 
	nop			;5dd6	00 	. 
	nop			;5dd7	00 	. 
	nop			;5dd8	00 	. 
	nop			;5dd9	00 	. 
	nop			;5dda	00 	. 
	nop			;5ddb	00 	. 
	nop			;5ddc	00 	. 
	nop			;5ddd	00 	. 
	nop			;5dde	00 	. 
	nop			;5ddf	00 	. 
	nop			;5de0	00 	. 
	nop			;5de1	00 	. 
	nop			;5de2	00 	. 
	nop			;5de3	00 	. 
	nop			;5de4	00 	. 
	nop			;5de5	00 	. 
	nop			;5de6	00 	. 
	nop			;5de7	00 	. 
	nop			;5de8	00 	. 
	nop			;5de9	00 	. 
	nop			;5dea	00 	. 
	nop			;5deb	00 	. 
	nop			;5dec	00 	. 
	nop			;5ded	00 	. 
	nop			;5dee	00 	. 
	nop			;5def	00 	. 
	nop			;5df0	00 	. 
	nop			;5df1	00 	. 
	nop			;5df2	00 	. 
	nop			;5df3	00 	. 
	nop			;5df4	00 	. 
	nop			;5df5	00 	. 
	nop			;5df6	00 	. 
	nop			;5df7	00 	. 
	nop			;5df8	00 	. 
	nop			;5df9	00 	. 
	nop			;5dfa	00 	. 
	nop			;5dfb	00 	. 
	nop			;5dfc	00 	. 
	nop			;5dfd	00 	. 
	nop			;5dfe	00 	. 
	nop			;5dff	00 	. 
	nop			;5e00	00 	. 
	nop			;5e01	00 	. 
	nop			;5e02	00 	. 
	nop			;5e03	00 	. 
	nop			;5e04	00 	. 
	nop			;5e05	00 	. 
	nop			;5e06	00 	. 
	nop			;5e07	00 	. 
	nop			;5e08	00 	. 
	nop			;5e09	00 	. 
	nop			;5e0a	00 	. 
	nop			;5e0b	00 	. 
	nop			;5e0c	00 	. 
	nop			;5e0d	00 	. 
	nop			;5e0e	00 	. 
	nop			;5e0f	00 	. 
	nop			;5e10	00 	. 
	nop			;5e11	00 	. 
	nop			;5e12	00 	. 
	nop			;5e13	00 	. 
	nop			;5e14	00 	. 
	nop			;5e15	00 	. 
	nop			;5e16	00 	. 
	nop			;5e17	00 	. 
	nop			;5e18	00 	. 
	nop			;5e19	00 	. 
	nop			;5e1a	00 	. 
	nop			;5e1b	00 	. 
	nop			;5e1c	00 	. 
	nop			;5e1d	00 	. 
	nop			;5e1e	00 	. 
	nop			;5e1f	00 	. 
	nop			;5e20	00 	. 
	nop			;5e21	00 	. 
	nop			;5e22	00 	. 
	nop			;5e23	00 	. 
	nop			;5e24	00 	. 
	nop			;5e25	00 	. 
	nop			;5e26	00 	. 
	nop			;5e27	00 	. 
	nop			;5e28	00 	. 
	nop			;5e29	00 	. 
	nop			;5e2a	00 	. 
	nop			;5e2b	00 	. 
	nop			;5e2c	00 	. 
	nop			;5e2d	00 	. 
	nop			;5e2e	00 	. 
	nop			;5e2f	00 	. 
	nop			;5e30	00 	. 
	nop			;5e31	00 	. 
	nop			;5e32	00 	. 
	nop			;5e33	00 	. 
	nop			;5e34	00 	. 
	nop			;5e35	00 	. 
	nop			;5e36	00 	. 
	nop			;5e37	00 	. 
	nop			;5e38	00 	. 
	nop			;5e39	00 	. 
	nop			;5e3a	00 	. 
	nop			;5e3b	00 	. 
	nop			;5e3c	00 	. 
	nop			;5e3d	00 	. 
	nop			;5e3e	00 	. 
	nop			;5e3f	00 	. 
	nop			;5e40	00 	. 
	nop			;5e41	00 	. 
	nop			;5e42	00 	. 
	nop			;5e43	00 	. 
	nop			;5e44	00 	. 
	nop			;5e45	00 	. 
	nop			;5e46	00 	. 
	nop			;5e47	00 	. 
	nop			;5e48	00 	. 
	nop			;5e49	00 	. 
	nop			;5e4a	00 	. 
	nop			;5e4b	00 	. 
	nop			;5e4c	00 	. 
	nop			;5e4d	00 	. 
	nop			;5e4e	00 	. 
	nop			;5e4f	00 	. 
	nop			;5e50	00 	. 
	nop			;5e51	00 	. 
	nop			;5e52	00 	. 
	nop			;5e53	00 	. 
	nop			;5e54	00 	. 
	nop			;5e55	00 	. 
	nop			;5e56	00 	. 
	nop			;5e57	00 	. 
	nop			;5e58	00 	. 
	nop			;5e59	00 	. 
	nop			;5e5a	00 	. 
	nop			;5e5b	00 	. 
	nop			;5e5c	00 	. 
	nop			;5e5d	00 	. 
	nop			;5e5e	00 	. 
	nop			;5e5f	00 	. 
	nop			;5e60	00 	. 
	nop			;5e61	00 	. 
	nop			;5e62	00 	. 
	nop			;5e63	00 	. 
	nop			;5e64	00 	. 
	nop			;5e65	00 	. 
	nop			;5e66	00 	. 
	nop			;5e67	00 	. 
	nop			;5e68	00 	. 
	nop			;5e69	00 	. 
	nop			;5e6a	00 	. 
	nop			;5e6b	00 	. 
	nop			;5e6c	00 	. 
	nop			;5e6d	00 	. 
	nop			;5e6e	00 	. 
	nop			;5e6f	00 	. 
	nop			;5e70	00 	. 
	nop			;5e71	00 	. 
	nop			;5e72	00 	. 
	nop			;5e73	00 	. 
	nop			;5e74	00 	. 
	nop			;5e75	00 	. 
	nop			;5e76	00 	. 
	nop			;5e77	00 	. 
	nop			;5e78	00 	. 
	nop			;5e79	00 	. 
	nop			;5e7a	00 	. 
	nop			;5e7b	00 	. 
	nop			;5e7c	00 	. 
	nop			;5e7d	00 	. 
	nop			;5e7e	00 	. 
	nop			;5e7f	00 	. 
	nop			;5e80	00 	. 
	nop			;5e81	00 	. 
	nop			;5e82	00 	. 
	nop			;5e83	00 	. 
	nop			;5e84	00 	. 
	nop			;5e85	00 	. 
	nop			;5e86	00 	. 
	nop			;5e87	00 	. 
	nop			;5e88	00 	. 
	nop			;5e89	00 	. 
	nop			;5e8a	00 	. 
	nop			;5e8b	00 	. 
	nop			;5e8c	00 	. 
	nop			;5e8d	00 	. 
	nop			;5e8e	00 	. 
	nop			;5e8f	00 	. 
	nop			;5e90	00 	. 
	nop			;5e91	00 	. 
	nop			;5e92	00 	. 
	nop			;5e93	00 	. 
	nop			;5e94	00 	. 
	nop			;5e95	00 	. 
	nop			;5e96	00 	. 
	nop			;5e97	00 	. 
	nop			;5e98	00 	. 
	nop			;5e99	00 	. 
	nop			;5e9a	00 	. 
	nop			;5e9b	00 	. 
	nop			;5e9c	00 	. 
	nop			;5e9d	00 	. 
	nop			;5e9e	00 	. 
	nop			;5e9f	00 	. 
	nop			;5ea0	00 	. 
	nop			;5ea1	00 	. 
	nop			;5ea2	00 	. 
	nop			;5ea3	00 	. 
	nop			;5ea4	00 	. 
	nop			;5ea5	00 	. 
	nop			;5ea6	00 	. 
	nop			;5ea7	00 	. 
	nop			;5ea8	00 	. 
	nop			;5ea9	00 	. 
	nop			;5eaa	00 	. 
	nop			;5eab	00 	. 
	nop			;5eac	00 	. 
	nop			;5ead	00 	. 
	nop			;5eae	00 	. 
	nop			;5eaf	00 	. 
	nop			;5eb0	00 	. 
	nop			;5eb1	00 	. 
	nop			;5eb2	00 	. 
	nop			;5eb3	00 	. 
	nop			;5eb4	00 	. 
	nop			;5eb5	00 	. 
	nop			;5eb6	00 	. 
	nop			;5eb7	00 	. 
	nop			;5eb8	00 	. 
	nop			;5eb9	00 	. 
	nop			;5eba	00 	. 
	nop			;5ebb	00 	. 
	nop			;5ebc	00 	. 
	nop			;5ebd	00 	. 
	nop			;5ebe	00 	. 
	nop			;5ebf	00 	. 
	nop			;5ec0	00 	. 
	nop			;5ec1	00 	. 
	nop			;5ec2	00 	. 
	nop			;5ec3	00 	. 
	nop			;5ec4	00 	. 
	nop			;5ec5	00 	. 
	nop			;5ec6	00 	. 
	nop			;5ec7	00 	. 
	nop			;5ec8	00 	. 
	nop			;5ec9	00 	. 
	nop			;5eca	00 	. 
	nop			;5ecb	00 	. 
	nop			;5ecc	00 	. 
	nop			;5ecd	00 	. 
	nop			;5ece	00 	. 
	nop			;5ecf	00 	. 
	nop			;5ed0	00 	. 
	nop			;5ed1	00 	. 
	nop			;5ed2	00 	. 
	nop			;5ed3	00 	. 
	nop			;5ed4	00 	. 
	nop			;5ed5	00 	. 
	nop			;5ed6	00 	. 
	nop			;5ed7	00 	. 
	nop			;5ed8	00 	. 
	nop			;5ed9	00 	. 
	nop			;5eda	00 	. 
	nop			;5edb	00 	. 
	nop			;5edc	00 	. 
	nop			;5edd	00 	. 
	nop			;5ede	00 	. 
	nop			;5edf	00 	. 
	nop			;5ee0	00 	. 
	nop			;5ee1	00 	. 
	nop			;5ee2	00 	. 
	nop			;5ee3	00 	. 
	nop			;5ee4	00 	. 
	nop			;5ee5	00 	. 
	nop			;5ee6	00 	. 
	nop			;5ee7	00 	. 
	nop			;5ee8	00 	. 
	nop			;5ee9	00 	. 
	nop			;5eea	00 	. 
	nop			;5eeb	00 	. 
	nop			;5eec	00 	. 
	nop			;5eed	00 	. 
	nop			;5eee	00 	. 
	nop			;5eef	00 	. 
	nop			;5ef0	00 	. 
	nop			;5ef1	00 	. 
	nop			;5ef2	00 	. 
	nop			;5ef3	00 	. 
	nop			;5ef4	00 	. 
	nop			;5ef5	00 	. 
	nop			;5ef6	00 	. 
	nop			;5ef7	00 	. 
	nop			;5ef8	00 	. 
	nop			;5ef9	00 	. 
	nop			;5efa	00 	. 
	nop			;5efb	00 	. 
	nop			;5efc	00 	. 
	nop			;5efd	00 	. 
	nop			;5efe	00 	. 
	nop			;5eff	00 	. 
	nop			;5f00	00 	. 
	nop			;5f01	00 	. 
	nop			;5f02	00 	. 
	nop			;5f03	00 	. 
	nop			;5f04	00 	. 
	nop			;5f05	00 	. 
	nop			;5f06	00 	. 
	nop			;5f07	00 	. 
	nop			;5f08	00 	. 
	nop			;5f09	00 	. 
	nop			;5f0a	00 	. 
	nop			;5f0b	00 	. 
	nop			;5f0c	00 	. 
	nop			;5f0d	00 	. 
	nop			;5f0e	00 	. 
	nop			;5f0f	00 	. 
	nop			;5f10	00 	. 
	nop			;5f11	00 	. 
	nop			;5f12	00 	. 
	nop			;5f13	00 	. 
	nop			;5f14	00 	. 
	nop			;5f15	00 	. 
	nop			;5f16	00 	. 
	nop			;5f17	00 	. 
	nop			;5f18	00 	. 
	nop			;5f19	00 	. 
	nop			;5f1a	00 	. 
	nop			;5f1b	00 	. 
	nop			;5f1c	00 	. 
	nop			;5f1d	00 	. 
	nop			;5f1e	00 	. 
	nop			;5f1f	00 	. 
	nop			;5f20	00 	. 
	nop			;5f21	00 	. 
	nop			;5f22	00 	. 
	nop			;5f23	00 	. 
	nop			;5f24	00 	. 
	nop			;5f25	00 	. 
	nop			;5f26	00 	. 
	nop			;5f27	00 	. 
	nop			;5f28	00 	. 
	nop			;5f29	00 	. 
	nop			;5f2a	00 	. 
	nop			;5f2b	00 	. 
	nop			;5f2c	00 	. 
	nop			;5f2d	00 	. 
	nop			;5f2e	00 	. 
	nop			;5f2f	00 	. 
	nop			;5f30	00 	. 
	nop			;5f31	00 	. 
	nop			;5f32	00 	. 
	nop			;5f33	00 	. 
	nop			;5f34	00 	. 
	nop			;5f35	00 	. 
	nop			;5f36	00 	. 
	nop			;5f37	00 	. 
	nop			;5f38	00 	. 
	nop			;5f39	00 	. 
	nop			;5f3a	00 	. 
	nop			;5f3b	00 	. 
	nop			;5f3c	00 	. 
	nop			;5f3d	00 	. 
	nop			;5f3e	00 	. 
	nop			;5f3f	00 	. 
	nop			;5f40	00 	. 
	nop			;5f41	00 	. 
	nop			;5f42	00 	. 
	nop			;5f43	00 	. 
	nop			;5f44	00 	. 
	nop			;5f45	00 	. 
	nop			;5f46	00 	. 
	nop			;5f47	00 	. 
	nop			;5f48	00 	. 
	nop			;5f49	00 	. 
	nop			;5f4a	00 	. 
	nop			;5f4b	00 	. 
	nop			;5f4c	00 	. 
	nop			;5f4d	00 	. 
	nop			;5f4e	00 	. 
	nop			;5f4f	00 	. 
	nop			;5f50	00 	. 
	nop			;5f51	00 	. 
	nop			;5f52	00 	. 
	nop			;5f53	00 	. 
	nop			;5f54	00 	. 
	nop			;5f55	00 	. 
	nop			;5f56	00 	. 
	nop			;5f57	00 	. 
	nop			;5f58	00 	. 
	nop			;5f59	00 	. 
	nop			;5f5a	00 	. 
	nop			;5f5b	00 	. 
	nop			;5f5c	00 	. 
	nop			;5f5d	00 	. 
	nop			;5f5e	00 	. 
	nop			;5f5f	00 	. 
	nop			;5f60	00 	. 
	nop			;5f61	00 	. 
	nop			;5f62	00 	. 
	nop			;5f63	00 	. 
	nop			;5f64	00 	. 
	nop			;5f65	00 	. 
	nop			;5f66	00 	. 
	nop			;5f67	00 	. 
	nop			;5f68	00 	. 
	nop			;5f69	00 	. 
	nop			;5f6a	00 	. 
	nop			;5f6b	00 	. 
	nop			;5f6c	00 	. 
	nop			;5f6d	00 	. 
	nop			;5f6e	00 	. 
	nop			;5f6f	00 	. 
	nop			;5f70	00 	. 
	nop			;5f71	00 	. 
	nop			;5f72	00 	. 
	nop			;5f73	00 	. 
	nop			;5f74	00 	. 
	nop			;5f75	00 	. 
	nop			;5f76	00 	. 
	nop			;5f77	00 	. 
	nop			;5f78	00 	. 
	nop			;5f79	00 	. 
	nop			;5f7a	00 	. 
	nop			;5f7b	00 	. 
	nop			;5f7c	00 	. 
	nop			;5f7d	00 	. 
	nop			;5f7e	00 	. 
	nop			;5f7f	00 	. 
	nop			;5f80	00 	. 
	nop			;5f81	00 	. 
	nop			;5f82	00 	. 
	nop			;5f83	00 	. 
	nop			;5f84	00 	. 
	nop			;5f85	00 	. 
	nop			;5f86	00 	. 
	nop			;5f87	00 	. 
	nop			;5f88	00 	. 
	nop			;5f89	00 	. 
	nop			;5f8a	00 	. 
	nop			;5f8b	00 	. 
	nop			;5f8c	00 	. 
	nop			;5f8d	00 	. 
	nop			;5f8e	00 	. 
	nop			;5f8f	00 	. 
	nop			;5f90	00 	. 
	nop			;5f91	00 	. 
	nop			;5f92	00 	. 
	nop			;5f93	00 	. 
	nop			;5f94	00 	. 
	nop			;5f95	00 	. 
	nop			;5f96	00 	. 
	nop			;5f97	00 	. 
	nop			;5f98	00 	. 
	nop			;5f99	00 	. 
	nop			;5f9a	00 	. 
	nop			;5f9b	00 	. 
	nop			;5f9c	00 	. 
	nop			;5f9d	00 	. 
	nop			;5f9e	00 	. 
	nop			;5f9f	00 	. 
	nop			;5fa0	00 	. 
	nop			;5fa1	00 	. 
	nop			;5fa2	00 	. 
	nop			;5fa3	00 	. 
	nop			;5fa4	00 	. 
	nop			;5fa5	00 	. 
	nop			;5fa6	00 	. 
	nop			;5fa7	00 	. 
	nop			;5fa8	00 	. 
	nop			;5fa9	00 	. 
	nop			;5faa	00 	. 
	nop			;5fab	00 	. 
	nop			;5fac	00 	. 
	nop			;5fad	00 	. 
	nop			;5fae	00 	. 
	nop			;5faf	00 	. 
	nop			;5fb0	00 	. 
	nop			;5fb1	00 	. 
	nop			;5fb2	00 	. 
	nop			;5fb3	00 	. 
	nop			;5fb4	00 	. 
	nop			;5fb5	00 	. 
	nop			;5fb6	00 	. 
	nop			;5fb7	00 	. 
	nop			;5fb8	00 	. 
	nop			;5fb9	00 	. 
	nop			;5fba	00 	. 
	nop			;5fbb	00 	. 
	nop			;5fbc	00 	. 
	nop			;5fbd	00 	. 
	nop			;5fbe	00 	. 
	nop			;5fbf	00 	. 
	nop			;5fc0	00 	. 
	nop			;5fc1	00 	. 
	nop			;5fc2	00 	. 
	nop			;5fc3	00 	. 
	nop			;5fc4	00 	. 
	nop			;5fc5	00 	. 
	nop			;5fc6	00 	. 
	nop			;5fc7	00 	. 
	nop			;5fc8	00 	. 
	nop			;5fc9	00 	. 
	nop			;5fca	00 	. 
	nop			;5fcb	00 	. 
	nop			;5fcc	00 	. 
	nop			;5fcd	00 	. 
	nop			;5fce	00 	. 
	nop			;5fcf	00 	. 
	nop			;5fd0	00 	. 
	nop			;5fd1	00 	. 
	nop			;5fd2	00 	. 
	nop			;5fd3	00 	. 
	nop			;5fd4	00 	. 
	nop			;5fd5	00 	. 
	nop			;5fd6	00 	. 
	nop			;5fd7	00 	. 
	nop			;5fd8	00 	. 
	nop			;5fd9	00 	. 
	nop			;5fda	00 	. 
	nop			;5fdb	00 	. 
	nop			;5fdc	00 	. 
	nop			;5fdd	00 	. 
	nop			;5fde	00 	. 
	nop			;5fdf	00 	. 
	nop			;5fe0	00 	. 
	nop			;5fe1	00 	. 
	nop			;5fe2	00 	. 
	nop			;5fe3	00 	. 
	nop			;5fe4	00 	. 
	nop			;5fe5	00 	. 
	nop			;5fe6	00 	. 
	nop			;5fe7	00 	. 
	nop			;5fe8	00 	. 
	nop			;5fe9	00 	. 
	nop			;5fea	00 	. 
	nop			;5feb	00 	. 
	nop			;5fec	00 	. 
	nop			;5fed	00 	. 
	nop			;5fee	00 	. 
	nop			;5fef	00 	. 
	nop			;5ff0	00 	. 
	nop			;5ff1	00 	. 
	nop			;5ff2	00 	. 
	nop			;5ff3	00 	. 
	nop			;5ff4	00 	. 
	nop			;5ff5	00 	. 
	nop			;5ff6	00 	. 
	nop			;5ff7	00 	. 
	nop			;5ff8	00 	. 
	nop			;5ff9	00 	. 
	nop			;5ffa	00 	. 
	nop			;5ffb	00 	. 
	nop			;5ffc	00 	. 
	nop			;5ffd	00 	. 
	nop			;5ffe	00 	. 
	nop			;5fff	00 	. 
	nop			;6000	00 	. 
	nop			;6001	00 	. 
	nop			;6002	00 	. 
	nop			;6003	00 	. 
	nop			;6004	00 	. 
	nop			;6005	00 	. 
	nop			;6006	00 	. 
	nop			;6007	00 	. 
	nop			;6008	00 	. 
	nop			;6009	00 	. 
	nop			;600a	00 	. 
	nop			;600b	00 	. 
	nop			;600c	00 	. 
	nop			;600d	00 	. 
	nop			;600e	00 	. 
	nop			;600f	00 	. 
	nop			;6010	00 	. 
	nop			;6011	00 	. 
	nop			;6012	00 	. 
	nop			;6013	00 	. 
	nop			;6014	00 	. 
	nop			;6015	00 	. 
	nop			;6016	00 	. 
	nop			;6017	00 	. 
	nop			;6018	00 	. 
	nop			;6019	00 	. 
	nop			;601a	00 	. 
	nop			;601b	00 	. 
	nop			;601c	00 	. 
	nop			;601d	00 	. 
	nop			;601e	00 	. 
	nop			;601f	00 	. 
	nop			;6020	00 	. 
	nop			;6021	00 	. 
	nop			;6022	00 	. 
	nop			;6023	00 	. 
	nop			;6024	00 	. 
	nop			;6025	00 	. 
	nop			;6026	00 	. 
	nop			;6027	00 	. 
	nop			;6028	00 	. 
	nop			;6029	00 	. 
	nop			;602a	00 	. 
	nop			;602b	00 	. 
	nop			;602c	00 	. 
	nop			;602d	00 	. 
	nop			;602e	00 	. 
	nop			;602f	00 	. 
	nop			;6030	00 	. 
	nop			;6031	00 	. 
	nop			;6032	00 	. 
	nop			;6033	00 	. 
	nop			;6034	00 	. 
	nop			;6035	00 	. 
	nop			;6036	00 	. 
	nop			;6037	00 	. 
	nop			;6038	00 	. 
	nop			;6039	00 	. 
	nop			;603a	00 	. 
	nop			;603b	00 	. 
	nop			;603c	00 	. 
	nop			;603d	00 	. 
	nop			;603e	00 	. 
	nop			;603f	00 	. 
	nop			;6040	00 	. 
	nop			;6041	00 	. 
	nop			;6042	00 	. 
	nop			;6043	00 	. 
	nop			;6044	00 	. 
	nop			;6045	00 	. 
	nop			;6046	00 	. 
	nop			;6047	00 	. 
	nop			;6048	00 	. 
	nop			;6049	00 	. 
	nop			;604a	00 	. 
	nop			;604b	00 	. 
	nop			;604c	00 	. 
	nop			;604d	00 	. 
	nop			;604e	00 	. 
	nop			;604f	00 	. 
	nop			;6050	00 	. 
	nop			;6051	00 	. 
	nop			;6052	00 	. 
	nop			;6053	00 	. 
	nop			;6054	00 	. 
	nop			;6055	00 	. 
	nop			;6056	00 	. 
	nop			;6057	00 	. 
	nop			;6058	00 	. 
	nop			;6059	00 	. 
	nop			;605a	00 	. 
	nop			;605b	00 	. 
	nop			;605c	00 	. 
	nop			;605d	00 	. 
	nop			;605e	00 	. 
	nop			;605f	00 	. 
	nop			;6060	00 	. 
	nop			;6061	00 	. 
	nop			;6062	00 	. 
	nop			;6063	00 	. 
	nop			;6064	00 	. 
	nop			;6065	00 	. 
	nop			;6066	00 	. 
	nop			;6067	00 	. 
	nop			;6068	00 	. 
	nop			;6069	00 	. 
	nop			;606a	00 	. 
	nop			;606b	00 	. 
	nop			;606c	00 	. 
	nop			;606d	00 	. 
	nop			;606e	00 	. 
	nop			;606f	00 	. 
	nop			;6070	00 	. 
	nop			;6071	00 	. 
	nop			;6072	00 	. 
	nop			;6073	00 	. 
	nop			;6074	00 	. 
	nop			;6075	00 	. 
	nop			;6076	00 	. 
	nop			;6077	00 	. 
	nop			;6078	00 	. 
	nop			;6079	00 	. 
	nop			;607a	00 	. 
	nop			;607b	00 	. 
	nop			;607c	00 	. 
	nop			;607d	00 	. 
	nop			;607e	00 	. 
	nop			;607f	00 	. 
	nop			;6080	00 	. 
	nop			;6081	00 	. 
	nop			;6082	00 	. 
	nop			;6083	00 	. 
	nop			;6084	00 	. 
	nop			;6085	00 	. 
	nop			;6086	00 	. 
	nop			;6087	00 	. 
	nop			;6088	00 	. 
	nop			;6089	00 	. 
	nop			;608a	00 	. 
	nop			;608b	00 	. 
	nop			;608c	00 	. 
	nop			;608d	00 	. 
	nop			;608e	00 	. 
	nop			;608f	00 	. 
	nop			;6090	00 	. 
	nop			;6091	00 	. 
	nop			;6092	00 	. 
	nop			;6093	00 	. 
	nop			;6094	00 	. 
	nop			;6095	00 	. 
	nop			;6096	00 	. 
	nop			;6097	00 	. 
	nop			;6098	00 	. 
	nop			;6099	00 	. 
	nop			;609a	00 	. 
	nop			;609b	00 	. 
	nop			;609c	00 	. 
	nop			;609d	00 	. 
	nop			;609e	00 	. 
	nop			;609f	00 	. 
	nop			;60a0	00 	. 
	nop			;60a1	00 	. 
	nop			;60a2	00 	. 
	nop			;60a3	00 	. 
	nop			;60a4	00 	. 
	nop			;60a5	00 	. 
	nop			;60a6	00 	. 
	nop			;60a7	00 	. 
	nop			;60a8	00 	. 
	nop			;60a9	00 	. 
	nop			;60aa	00 	. 
	nop			;60ab	00 	. 
	nop			;60ac	00 	. 
	nop			;60ad	00 	. 
	nop			;60ae	00 	. 
	nop			;60af	00 	. 
	nop			;60b0	00 	. 
	nop			;60b1	00 	. 
	nop			;60b2	00 	. 
	nop			;60b3	00 	. 
	nop			;60b4	00 	. 
	nop			;60b5	00 	. 
	nop			;60b6	00 	. 
	nop			;60b7	00 	. 
	nop			;60b8	00 	. 
	nop			;60b9	00 	. 
	nop			;60ba	00 	. 
	nop			;60bb	00 	. 
	nop			;60bc	00 	. 
	nop			;60bd	00 	. 
	nop			;60be	00 	. 
	nop			;60bf	00 	. 
	nop			;60c0	00 	. 
	nop			;60c1	00 	. 
	nop			;60c2	00 	. 
	nop			;60c3	00 	. 
	nop			;60c4	00 	. 
	nop			;60c5	00 	. 
	nop			;60c6	00 	. 
	nop			;60c7	00 	. 
	nop			;60c8	00 	. 
	nop			;60c9	00 	. 
	nop			;60ca	00 	. 
	nop			;60cb	00 	. 
	nop			;60cc	00 	. 
	nop			;60cd	00 	. 
	nop			;60ce	00 	. 
	nop			;60cf	00 	. 
	nop			;60d0	00 	. 
	nop			;60d1	00 	. 
	nop			;60d2	00 	. 
	nop			;60d3	00 	. 
	nop			;60d4	00 	. 
	nop			;60d5	00 	. 
	nop			;60d6	00 	. 
	nop			;60d7	00 	. 
	nop			;60d8	00 	. 
	nop			;60d9	00 	. 
	nop			;60da	00 	. 
	nop			;60db	00 	. 
	nop			;60dc	00 	. 
	nop			;60dd	00 	. 
	nop			;60de	00 	. 
	nop			;60df	00 	. 
	nop			;60e0	00 	. 
	nop			;60e1	00 	. 
	nop			;60e2	00 	. 
	nop			;60e3	00 	. 
	nop			;60e4	00 	. 
	nop			;60e5	00 	. 
	nop			;60e6	00 	. 
	nop			;60e7	00 	. 
	nop			;60e8	00 	. 
	nop			;60e9	00 	. 
	nop			;60ea	00 	. 
	nop			;60eb	00 	. 
	nop			;60ec	00 	. 
	nop			;60ed	00 	. 
	nop			;60ee	00 	. 
	nop			;60ef	00 	. 
	nop			;60f0	00 	. 
	nop			;60f1	00 	. 
	nop			;60f2	00 	. 
	nop			;60f3	00 	. 
	nop			;60f4	00 	. 
	nop			;60f5	00 	. 
	nop			;60f6	00 	. 
	nop			;60f7	00 	. 
	nop			;60f8	00 	. 
	nop			;60f9	00 	. 
	nop			;60fa	00 	. 
	nop			;60fb	00 	. 
	nop			;60fc	00 	. 
	nop			;60fd	00 	. 
	nop			;60fe	00 	. 
	nop			;60ff	00 	. 
	nop			;6100	00 	. 
	nop			;6101	00 	. 
	nop			;6102	00 	. 
	nop			;6103	00 	. 
	nop			;6104	00 	. 
	nop			;6105	00 	. 
	nop			;6106	00 	. 
	nop			;6107	00 	. 
	nop			;6108	00 	. 
	nop			;6109	00 	. 
	nop			;610a	00 	. 
	nop			;610b	00 	. 
	nop			;610c	00 	. 
	nop			;610d	00 	. 
	nop			;610e	00 	. 
	nop			;610f	00 	. 
	nop			;6110	00 	. 
	nop			;6111	00 	. 
	nop			;6112	00 	. 
	nop			;6113	00 	. 
	nop			;6114	00 	. 
	nop			;6115	00 	. 
	nop			;6116	00 	. 
	nop			;6117	00 	. 
	nop			;6118	00 	. 
	nop			;6119	00 	. 
	nop			;611a	00 	. 
	nop			;611b	00 	. 
	nop			;611c	00 	. 
	nop			;611d	00 	. 
	nop			;611e	00 	. 
	nop			;611f	00 	. 
	nop			;6120	00 	. 
	nop			;6121	00 	. 
	nop			;6122	00 	. 
	nop			;6123	00 	. 
	nop			;6124	00 	. 
	nop			;6125	00 	. 
	nop			;6126	00 	. 
	nop			;6127	00 	. 
	nop			;6128	00 	. 
	nop			;6129	00 	. 
	nop			;612a	00 	. 
	nop			;612b	00 	. 
	nop			;612c	00 	. 
	nop			;612d	00 	. 
	nop			;612e	00 	. 
	nop			;612f	00 	. 
	nop			;6130	00 	. 
	nop			;6131	00 	. 
	nop			;6132	00 	. 
	nop			;6133	00 	. 
	nop			;6134	00 	. 
	nop			;6135	00 	. 
	nop			;6136	00 	. 
	nop			;6137	00 	. 
	nop			;6138	00 	. 
	nop			;6139	00 	. 
	nop			;613a	00 	. 
	nop			;613b	00 	. 
	nop			;613c	00 	. 
	nop			;613d	00 	. 
	nop			;613e	00 	. 
	nop			;613f	00 	. 
	nop			;6140	00 	. 
	nop			;6141	00 	. 
	nop			;6142	00 	. 
	nop			;6143	00 	. 
	nop			;6144	00 	. 
	nop			;6145	00 	. 
	nop			;6146	00 	. 
	nop			;6147	00 	. 
	nop			;6148	00 	. 
	nop			;6149	00 	. 
	nop			;614a	00 	. 
	nop			;614b	00 	. 
	nop			;614c	00 	. 
	nop			;614d	00 	. 
	nop			;614e	00 	. 
	nop			;614f	00 	. 
	nop			;6150	00 	. 
	nop			;6151	00 	. 
	nop			;6152	00 	. 
	nop			;6153	00 	. 
	nop			;6154	00 	. 
	nop			;6155	00 	. 
	nop			;6156	00 	. 
	nop			;6157	00 	. 
	nop			;6158	00 	. 
	nop			;6159	00 	. 
	nop			;615a	00 	. 
	nop			;615b	00 	. 
	nop			;615c	00 	. 
	nop			;615d	00 	. 
	nop			;615e	00 	. 
	nop			;615f	00 	. 
	nop			;6160	00 	. 
	nop			;6161	00 	. 
	nop			;6162	00 	. 
	nop			;6163	00 	. 
	nop			;6164	00 	. 
	nop			;6165	00 	. 
	nop			;6166	00 	. 
	nop			;6167	00 	. 
	nop			;6168	00 	. 
	nop			;6169	00 	. 
	nop			;616a	00 	. 
	nop			;616b	00 	. 
	nop			;616c	00 	. 
	nop			;616d	00 	. 
	nop			;616e	00 	. 
	nop			;616f	00 	. 
	nop			;6170	00 	. 
	nop			;6171	00 	. 
	nop			;6172	00 	. 
	nop			;6173	00 	. 
	nop			;6174	00 	. 
	nop			;6175	00 	. 
	nop			;6176	00 	. 
	nop			;6177	00 	. 
	nop			;6178	00 	. 
	nop			;6179	00 	. 
	nop			;617a	00 	. 
	nop			;617b	00 	. 
	nop			;617c	00 	. 
	nop			;617d	00 	. 
	nop			;617e	00 	. 
	nop			;617f	00 	. 
	nop			;6180	00 	. 
	nop			;6181	00 	. 
	nop			;6182	00 	. 
	nop			;6183	00 	. 
	nop			;6184	00 	. 
	nop			;6185	00 	. 
	nop			;6186	00 	. 
	nop			;6187	00 	. 
	nop			;6188	00 	. 
	nop			;6189	00 	. 
	nop			;618a	00 	. 
	nop			;618b	00 	. 
	nop			;618c	00 	. 
	nop			;618d	00 	. 
	nop			;618e	00 	. 
	nop			;618f	00 	. 
	nop			;6190	00 	. 
	nop			;6191	00 	. 
	nop			;6192	00 	. 
	nop			;6193	00 	. 
	nop			;6194	00 	. 
	nop			;6195	00 	. 
	nop			;6196	00 	. 
	nop			;6197	00 	. 
	nop			;6198	00 	. 
	nop			;6199	00 	. 
	nop			;619a	00 	. 
	nop			;619b	00 	. 
	nop			;619c	00 	. 
	nop			;619d	00 	. 
	nop			;619e	00 	. 
	nop			;619f	00 	. 
	nop			;61a0	00 	. 
	nop			;61a1	00 	. 
	nop			;61a2	00 	. 
	nop			;61a3	00 	. 
	nop			;61a4	00 	. 
	nop			;61a5	00 	. 
	nop			;61a6	00 	. 
	nop			;61a7	00 	. 
	nop			;61a8	00 	. 
	nop			;61a9	00 	. 
	nop			;61aa	00 	. 
	nop			;61ab	00 	. 
	nop			;61ac	00 	. 
	nop			;61ad	00 	. 
	nop			;61ae	00 	. 
	nop			;61af	00 	. 
	nop			;61b0	00 	. 
	nop			;61b1	00 	. 
	nop			;61b2	00 	. 
	nop			;61b3	00 	. 
	nop			;61b4	00 	. 
	nop			;61b5	00 	. 
	nop			;61b6	00 	. 
	nop			;61b7	00 	. 
	nop			;61b8	00 	. 
	nop			;61b9	00 	. 
	nop			;61ba	00 	. 
	nop			;61bb	00 	. 
	nop			;61bc	00 	. 
	nop			;61bd	00 	. 
	nop			;61be	00 	. 
	nop			;61bf	00 	. 
	nop			;61c0	00 	. 
	nop			;61c1	00 	. 
	nop			;61c2	00 	. 
	nop			;61c3	00 	. 
	nop			;61c4	00 	. 
	nop			;61c5	00 	. 
	nop			;61c6	00 	. 
	nop			;61c7	00 	. 
	nop			;61c8	00 	. 
	nop			;61c9	00 	. 
	nop			;61ca	00 	. 
	nop			;61cb	00 	. 
	nop			;61cc	00 	. 
	nop			;61cd	00 	. 
	nop			;61ce	00 	. 
	nop			;61cf	00 	. 
	nop			;61d0	00 	. 
	nop			;61d1	00 	. 
	nop			;61d2	00 	. 
	nop			;61d3	00 	. 
	nop			;61d4	00 	. 
	nop			;61d5	00 	. 
	nop			;61d6	00 	. 
	nop			;61d7	00 	. 
	nop			;61d8	00 	. 
	nop			;61d9	00 	. 
	nop			;61da	00 	. 
	nop			;61db	00 	. 
	nop			;61dc	00 	. 
	nop			;61dd	00 	. 
	nop			;61de	00 	. 
	nop			;61df	00 	. 
	nop			;61e0	00 	. 
	nop			;61e1	00 	. 
	nop			;61e2	00 	. 
	nop			;61e3	00 	. 
	nop			;61e4	00 	. 
	nop			;61e5	00 	. 
	nop			;61e6	00 	. 
	nop			;61e7	00 	. 
	nop			;61e8	00 	. 
	nop			;61e9	00 	. 
	nop			;61ea	00 	. 
	nop			;61eb	00 	. 
	nop			;61ec	00 	. 
	nop			;61ed	00 	. 
	nop			;61ee	00 	. 
	nop			;61ef	00 	. 
	nop			;61f0	00 	. 
	nop			;61f1	00 	. 
	nop			;61f2	00 	. 
	nop			;61f3	00 	. 
	nop			;61f4	00 	. 
	nop			;61f5	00 	. 
	nop			;61f6	00 	. 
	nop			;61f7	00 	. 
	nop			;61f8	00 	. 
	nop			;61f9	00 	. 
	nop			;61fa	00 	. 
	nop			;61fb	00 	. 
	nop			;61fc	00 	. 
	nop			;61fd	00 	. 
	nop			;61fe	00 	. 
	nop			;61ff	00 	. 
	nop			;6200	00 	. 
	nop			;6201	00 	. 
	nop			;6202	00 	. 
	nop			;6203	00 	. 
	nop			;6204	00 	. 
	nop			;6205	00 	. 
	nop			;6206	00 	. 
	nop			;6207	00 	. 
	nop			;6208	00 	. 
	nop			;6209	00 	. 
	nop			;620a	00 	. 
	nop			;620b	00 	. 
	nop			;620c	00 	. 
	nop			;620d	00 	. 
	nop			;620e	00 	. 
	nop			;620f	00 	. 
	nop			;6210	00 	. 
	nop			;6211	00 	. 
	nop			;6212	00 	. 
	nop			;6213	00 	. 
	nop			;6214	00 	. 
	nop			;6215	00 	. 
	nop			;6216	00 	. 
	nop			;6217	00 	. 
	nop			;6218	00 	. 
	nop			;6219	00 	. 
	nop			;621a	00 	. 
	nop			;621b	00 	. 
	nop			;621c	00 	. 
	nop			;621d	00 	. 
	nop			;621e	00 	. 
	nop			;621f	00 	. 
	nop			;6220	00 	. 
	nop			;6221	00 	. 
	nop			;6222	00 	. 
	nop			;6223	00 	. 
	nop			;6224	00 	. 
	nop			;6225	00 	. 
	nop			;6226	00 	. 
	nop			;6227	00 	. 
	nop			;6228	00 	. 
	nop			;6229	00 	. 
	nop			;622a	00 	. 
	nop			;622b	00 	. 
	nop			;622c	00 	. 
	nop			;622d	00 	. 
	nop			;622e	00 	. 
	nop			;622f	00 	. 
	nop			;6230	00 	. 
	nop			;6231	00 	. 
	nop			;6232	00 	. 
	nop			;6233	00 	. 
	nop			;6234	00 	. 
	nop			;6235	00 	. 
	nop			;6236	00 	. 
	nop			;6237	00 	. 
	nop			;6238	00 	. 
	nop			;6239	00 	. 
	nop			;623a	00 	. 
	nop			;623b	00 	. 
	nop			;623c	00 	. 
	nop			;623d	00 	. 
	nop			;623e	00 	. 
	nop			;623f	00 	. 
	nop			;6240	00 	. 
	nop			;6241	00 	. 
	nop			;6242	00 	. 
	nop			;6243	00 	. 
	nop			;6244	00 	. 
	nop			;6245	00 	. 
	nop			;6246	00 	. 
	nop			;6247	00 	. 
	nop			;6248	00 	. 
	nop			;6249	00 	. 
	nop			;624a	00 	. 
	nop			;624b	00 	. 
	nop			;624c	00 	. 
	nop			;624d	00 	. 
	nop			;624e	00 	. 
	nop			;624f	00 	. 
	nop			;6250	00 	. 
	nop			;6251	00 	. 
	nop			;6252	00 	. 
	nop			;6253	00 	. 
	nop			;6254	00 	. 
	nop			;6255	00 	. 
	nop			;6256	00 	. 
	nop			;6257	00 	. 
	nop			;6258	00 	. 
	nop			;6259	00 	. 
	nop			;625a	00 	. 
	nop			;625b	00 	. 
	nop			;625c	00 	. 
	nop			;625d	00 	. 
	nop			;625e	00 	. 
	nop			;625f	00 	. 
	nop			;6260	00 	. 
	nop			;6261	00 	. 
	nop			;6262	00 	. 
	nop			;6263	00 	. 
	nop			;6264	00 	. 
	nop			;6265	00 	. 
	nop			;6266	00 	. 
	nop			;6267	00 	. 
	nop			;6268	00 	. 
	nop			;6269	00 	. 
	nop			;626a	00 	. 
	nop			;626b	00 	. 
	nop			;626c	00 	. 
	nop			;626d	00 	. 
	nop			;626e	00 	. 
	nop			;626f	00 	. 
	nop			;6270	00 	. 
	nop			;6271	00 	. 
	nop			;6272	00 	. 
	nop			;6273	00 	. 
	nop			;6274	00 	. 
	nop			;6275	00 	. 
	nop			;6276	00 	. 
	nop			;6277	00 	. 
	nop			;6278	00 	. 
	nop			;6279	00 	. 
	nop			;627a	00 	. 
	nop			;627b	00 	. 
	nop			;627c	00 	. 
	nop			;627d	00 	. 
	nop			;627e	00 	. 
	nop			;627f	00 	. 
	nop			;6280	00 	. 
	nop			;6281	00 	. 
	nop			;6282	00 	. 
	nop			;6283	00 	. 
	nop			;6284	00 	. 
	nop			;6285	00 	. 
	nop			;6286	00 	. 
	nop			;6287	00 	. 
	nop			;6288	00 	. 
	nop			;6289	00 	. 
	nop			;628a	00 	. 
	nop			;628b	00 	. 
	nop			;628c	00 	. 
	nop			;628d	00 	. 
	nop			;628e	00 	. 
	nop			;628f	00 	. 
	nop			;6290	00 	. 
	nop			;6291	00 	. 
	nop			;6292	00 	. 
	nop			;6293	00 	. 
	nop			;6294	00 	. 
	nop			;6295	00 	. 
	nop			;6296	00 	. 
	nop			;6297	00 	. 
	nop			;6298	00 	. 
	nop			;6299	00 	. 
	nop			;629a	00 	. 
	nop			;629b	00 	. 
	nop			;629c	00 	. 
	nop			;629d	00 	. 
	nop			;629e	00 	. 
	nop			;629f	00 	. 
	nop			;62a0	00 	. 
	nop			;62a1	00 	. 
	nop			;62a2	00 	. 
	nop			;62a3	00 	. 
	nop			;62a4	00 	. 
	nop			;62a5	00 	. 
	nop			;62a6	00 	. 
	nop			;62a7	00 	. 
	nop			;62a8	00 	. 
	nop			;62a9	00 	. 
	nop			;62aa	00 	. 
	nop			;62ab	00 	. 
	nop			;62ac	00 	. 
	nop			;62ad	00 	. 
	nop			;62ae	00 	. 
	nop			;62af	00 	. 
	nop			;62b0	00 	. 
	nop			;62b1	00 	. 
	nop			;62b2	00 	. 
	nop			;62b3	00 	. 
	nop			;62b4	00 	. 
	nop			;62b5	00 	. 
	nop			;62b6	00 	. 
	nop			;62b7	00 	. 
	nop			;62b8	00 	. 
	nop			;62b9	00 	. 
	nop			;62ba	00 	. 
	nop			;62bb	00 	. 
	nop			;62bc	00 	. 
	nop			;62bd	00 	. 
	nop			;62be	00 	. 
	nop			;62bf	00 	. 
	nop			;62c0	00 	. 
	nop			;62c1	00 	. 
	nop			;62c2	00 	. 
	nop			;62c3	00 	. 
	nop			;62c4	00 	. 
	nop			;62c5	00 	. 
	nop			;62c6	00 	. 
	nop			;62c7	00 	. 
	nop			;62c8	00 	. 
	nop			;62c9	00 	. 
	nop			;62ca	00 	. 
	nop			;62cb	00 	. 
	nop			;62cc	00 	. 
	nop			;62cd	00 	. 
	nop			;62ce	00 	. 
	nop			;62cf	00 	. 
	nop			;62d0	00 	. 
	nop			;62d1	00 	. 
	nop			;62d2	00 	. 
	nop			;62d3	00 	. 
	nop			;62d4	00 	. 
	nop			;62d5	00 	. 
	nop			;62d6	00 	. 
	nop			;62d7	00 	. 
	nop			;62d8	00 	. 
	nop			;62d9	00 	. 
	nop			;62da	00 	. 
	nop			;62db	00 	. 
	nop			;62dc	00 	. 
	nop			;62dd	00 	. 
	nop			;62de	00 	. 
	nop			;62df	00 	. 
	nop			;62e0	00 	. 
	nop			;62e1	00 	. 
	nop			;62e2	00 	. 
	nop			;62e3	00 	. 
	nop			;62e4	00 	. 
	nop			;62e5	00 	. 
	nop			;62e6	00 	. 
	nop			;62e7	00 	. 
	nop			;62e8	00 	. 
	nop			;62e9	00 	. 
	nop			;62ea	00 	. 
	nop			;62eb	00 	. 
	nop			;62ec	00 	. 
	nop			;62ed	00 	. 
	nop			;62ee	00 	. 
	nop			;62ef	00 	. 
	nop			;62f0	00 	. 
	nop			;62f1	00 	. 
	nop			;62f2	00 	. 
	nop			;62f3	00 	. 
	nop			;62f4	00 	. 
	nop			;62f5	00 	. 
	nop			;62f6	00 	. 
	nop			;62f7	00 	. 
	nop			;62f8	00 	. 
	nop			;62f9	00 	. 
	nop			;62fa	00 	. 
	nop			;62fb	00 	. 
	nop			;62fc	00 	. 
	nop			;62fd	00 	. 
	nop			;62fe	00 	. 
	nop			;62ff	00 	. 
	nop			;6300	00 	. 
	nop			;6301	00 	. 
	nop			;6302	00 	. 
	nop			;6303	00 	. 
	nop			;6304	00 	. 
	nop			;6305	00 	. 
	nop			;6306	00 	. 
	nop			;6307	00 	. 
	nop			;6308	00 	. 
	nop			;6309	00 	. 
	nop			;630a	00 	. 
	nop			;630b	00 	. 
	nop			;630c	00 	. 
	nop			;630d	00 	. 
	nop			;630e	00 	. 
	nop			;630f	00 	. 
	nop			;6310	00 	. 
	nop			;6311	00 	. 
	nop			;6312	00 	. 
	nop			;6313	00 	. 
	nop			;6314	00 	. 
	nop			;6315	00 	. 
	nop			;6316	00 	. 
	nop			;6317	00 	. 
	nop			;6318	00 	. 
	nop			;6319	00 	. 
	nop			;631a	00 	. 
	nop			;631b	00 	. 
	nop			;631c	00 	. 
	nop			;631d	00 	. 
	nop			;631e	00 	. 
	nop			;631f	00 	. 
	nop			;6320	00 	. 
	nop			;6321	00 	. 
	nop			;6322	00 	. 
	nop			;6323	00 	. 
	nop			;6324	00 	. 
	nop			;6325	00 	. 
	nop			;6326	00 	. 
	nop			;6327	00 	. 
	nop			;6328	00 	. 
	nop			;6329	00 	. 
	nop			;632a	00 	. 
	nop			;632b	00 	. 
	nop			;632c	00 	. 
	nop			;632d	00 	. 
	nop			;632e	00 	. 
	nop			;632f	00 	. 
	nop			;6330	00 	. 
	nop			;6331	00 	. 
	nop			;6332	00 	. 
	nop			;6333	00 	. 
	nop			;6334	00 	. 
	nop			;6335	00 	. 
	nop			;6336	00 	. 
	nop			;6337	00 	. 
	nop			;6338	00 	. 
	nop			;6339	00 	. 
	nop			;633a	00 	. 
	nop			;633b	00 	. 
	nop			;633c	00 	. 
	nop			;633d	00 	. 
	nop			;633e	00 	. 
	nop			;633f	00 	. 
	nop			;6340	00 	. 
	nop			;6341	00 	. 
	nop			;6342	00 	. 
	nop			;6343	00 	. 
	nop			;6344	00 	. 
	nop			;6345	00 	. 
	nop			;6346	00 	. 
	nop			;6347	00 	. 
	nop			;6348	00 	. 
	nop			;6349	00 	. 
	nop			;634a	00 	. 
	nop			;634b	00 	. 
	nop			;634c	00 	. 
	nop			;634d	00 	. 
	nop			;634e	00 	. 
	nop			;634f	00 	. 
	nop			;6350	00 	. 
	nop			;6351	00 	. 
	nop			;6352	00 	. 
	nop			;6353	00 	. 
	nop			;6354	00 	. 
	nop			;6355	00 	. 
	nop			;6356	00 	. 
	nop			;6357	00 	. 
	nop			;6358	00 	. 
	nop			;6359	00 	. 
	nop			;635a	00 	. 
	nop			;635b	00 	. 
	nop			;635c	00 	. 
	nop			;635d	00 	. 
	nop			;635e	00 	. 
	nop			;635f	00 	. 
	nop			;6360	00 	. 
	nop			;6361	00 	. 
	nop			;6362	00 	. 
	nop			;6363	00 	. 
	nop			;6364	00 	. 
	nop			;6365	00 	. 
	nop			;6366	00 	. 
	nop			;6367	00 	. 
	nop			;6368	00 	. 
	nop			;6369	00 	. 
	nop			;636a	00 	. 
	nop			;636b	00 	. 
	nop			;636c	00 	. 
	nop			;636d	00 	. 
	nop			;636e	00 	. 
	nop			;636f	00 	. 
	nop			;6370	00 	. 
	nop			;6371	00 	. 
	nop			;6372	00 	. 
	nop			;6373	00 	. 
	nop			;6374	00 	. 
	nop			;6375	00 	. 
	nop			;6376	00 	. 
	nop			;6377	00 	. 
	nop			;6378	00 	. 
	nop			;6379	00 	. 
	nop			;637a	00 	. 
	nop			;637b	00 	. 
	nop			;637c	00 	. 
	nop			;637d	00 	. 
	nop			;637e	00 	. 
	nop			;637f	00 	. 
	nop			;6380	00 	. 
	nop			;6381	00 	. 
	nop			;6382	00 	. 
	nop			;6383	00 	. 
	nop			;6384	00 	. 
	nop			;6385	00 	. 
	nop			;6386	00 	. 
	nop			;6387	00 	. 
	nop			;6388	00 	. 
	nop			;6389	00 	. 
	nop			;638a	00 	. 
	nop			;638b	00 	. 
	nop			;638c	00 	. 
	nop			;638d	00 	. 
	nop			;638e	00 	. 
	nop			;638f	00 	. 
	nop			;6390	00 	. 
	nop			;6391	00 	. 
	nop			;6392	00 	. 
	nop			;6393	00 	. 
	nop			;6394	00 	. 
	nop			;6395	00 	. 
	nop			;6396	00 	. 
	nop			;6397	00 	. 
	nop			;6398	00 	. 
	nop			;6399	00 	. 
	nop			;639a	00 	. 
	nop			;639b	00 	. 
	nop			;639c	00 	. 
	nop			;639d	00 	. 
	nop			;639e	00 	. 
	nop			;639f	00 	. 
	nop			;63a0	00 	. 
	nop			;63a1	00 	. 
	nop			;63a2	00 	. 
	nop			;63a3	00 	. 
	nop			;63a4	00 	. 
	nop			;63a5	00 	. 
	nop			;63a6	00 	. 
	nop			;63a7	00 	. 
	nop			;63a8	00 	. 
	nop			;63a9	00 	. 
	nop			;63aa	00 	. 
	nop			;63ab	00 	. 
	nop			;63ac	00 	. 
	nop			;63ad	00 	. 
	nop			;63ae	00 	. 
	nop			;63af	00 	. 
	nop			;63b0	00 	. 
	nop			;63b1	00 	. 
	nop			;63b2	00 	. 
	nop			;63b3	00 	. 
	nop			;63b4	00 	. 
	nop			;63b5	00 	. 
	nop			;63b6	00 	. 
	nop			;63b7	00 	. 
	nop			;63b8	00 	. 
	nop			;63b9	00 	. 
	nop			;63ba	00 	. 
	nop			;63bb	00 	. 
	nop			;63bc	00 	. 
	nop			;63bd	00 	. 
	nop			;63be	00 	. 
	nop			;63bf	00 	. 
	nop			;63c0	00 	. 
	nop			;63c1	00 	. 
	nop			;63c2	00 	. 
	nop			;63c3	00 	. 
	nop			;63c4	00 	. 
	nop			;63c5	00 	. 
	nop			;63c6	00 	. 
	nop			;63c7	00 	. 
	nop			;63c8	00 	. 
	nop			;63c9	00 	. 
	nop			;63ca	00 	. 
	nop			;63cb	00 	. 
	nop			;63cc	00 	. 
	nop			;63cd	00 	. 
	nop			;63ce	00 	. 
	nop			;63cf	00 	. 
	nop			;63d0	00 	. 
	nop			;63d1	00 	. 
	nop			;63d2	00 	. 
	nop			;63d3	00 	. 
	nop			;63d4	00 	. 
	nop			;63d5	00 	. 
	nop			;63d6	00 	. 
	nop			;63d7	00 	. 
	nop			;63d8	00 	. 
	nop			;63d9	00 	. 
	nop			;63da	00 	. 
	nop			;63db	00 	. 
	nop			;63dc	00 	. 
	nop			;63dd	00 	. 
	nop			;63de	00 	. 
	nop			;63df	00 	. 
	nop			;63e0	00 	. 
	nop			;63e1	00 	. 
	nop			;63e2	00 	. 
	nop			;63e3	00 	. 
	nop			;63e4	00 	. 
	nop			;63e5	00 	. 
	nop			;63e6	00 	. 
	nop			;63e7	00 	. 
	nop			;63e8	00 	. 
	nop			;63e9	00 	. 
	nop			;63ea	00 	. 
	nop			;63eb	00 	. 
	nop			;63ec	00 	. 
	nop			;63ed	00 	. 
	nop			;63ee	00 	. 
	nop			;63ef	00 	. 
	nop			;63f0	00 	. 
	nop			;63f1	00 	. 
	nop			;63f2	00 	. 
	nop			;63f3	00 	. 
	nop			;63f4	00 	. 
	nop			;63f5	00 	. 
	nop			;63f6	00 	. 
	nop			;63f7	00 	. 
	nop			;63f8	00 	. 
	nop			;63f9	00 	. 
	nop			;63fa	00 	. 
	nop			;63fb	00 	. 
	nop			;63fc	00 	. 
	nop			;63fd	00 	. 
	nop			;63fe	00 	. 
	nop			;63ff	00 	. 
	nop			;6400	00 	. 
	nop			;6401	00 	. 
	nop			;6402	00 	. 
	nop			;6403	00 	. 
	nop			;6404	00 	. 
	nop			;6405	00 	. 
	nop			;6406	00 	. 
	nop			;6407	00 	. 
	nop			;6408	00 	. 
	nop			;6409	00 	. 
	nop			;640a	00 	. 
	nop			;640b	00 	. 
	nop			;640c	00 	. 
	nop			;640d	00 	. 
	nop			;640e	00 	. 
	nop			;640f	00 	. 
	nop			;6410	00 	. 
	nop			;6411	00 	. 
	nop			;6412	00 	. 
	nop			;6413	00 	. 
	nop			;6414	00 	. 
	nop			;6415	00 	. 
	nop			;6416	00 	. 
	nop			;6417	00 	. 
	nop			;6418	00 	. 
	nop			;6419	00 	. 
	nop			;641a	00 	. 
	nop			;641b	00 	. 
	nop			;641c	00 	. 
	nop			;641d	00 	. 
	nop			;641e	00 	. 
	nop			;641f	00 	. 
	nop			;6420	00 	. 
	nop			;6421	00 	. 
	nop			;6422	00 	. 
	nop			;6423	00 	. 
	nop			;6424	00 	. 
	nop			;6425	00 	. 
	nop			;6426	00 	. 
	nop			;6427	00 	. 
	nop			;6428	00 	. 
	nop			;6429	00 	. 
	nop			;642a	00 	. 
	nop			;642b	00 	. 
	nop			;642c	00 	. 
	nop			;642d	00 	. 
	nop			;642e	00 	. 
	nop			;642f	00 	. 
	nop			;6430	00 	. 
	nop			;6431	00 	. 
	nop			;6432	00 	. 
	nop			;6433	00 	. 
	nop			;6434	00 	. 
	nop			;6435	00 	. 
	nop			;6436	00 	. 
	nop			;6437	00 	. 
	nop			;6438	00 	. 
	nop			;6439	00 	. 
	nop			;643a	00 	. 
	nop			;643b	00 	. 
	nop			;643c	00 	. 
	nop			;643d	00 	. 
	nop			;643e	00 	. 
	nop			;643f	00 	. 
	nop			;6440	00 	. 
	nop			;6441	00 	. 
	nop			;6442	00 	. 
	nop			;6443	00 	. 
	nop			;6444	00 	. 
	nop			;6445	00 	. 
	nop			;6446	00 	. 
	nop			;6447	00 	. 
	nop			;6448	00 	. 
	nop			;6449	00 	. 
	nop			;644a	00 	. 
	nop			;644b	00 	. 
	nop			;644c	00 	. 
	nop			;644d	00 	. 
	nop			;644e	00 	. 
	nop			;644f	00 	. 
	nop			;6450	00 	. 
	nop			;6451	00 	. 
	nop			;6452	00 	. 
	nop			;6453	00 	. 
	nop			;6454	00 	. 
	nop			;6455	00 	. 
	nop			;6456	00 	. 
	nop			;6457	00 	. 
	nop			;6458	00 	. 
	nop			;6459	00 	. 
	nop			;645a	00 	. 
	nop			;645b	00 	. 
	nop			;645c	00 	. 
	nop			;645d	00 	. 
	nop			;645e	00 	. 
	nop			;645f	00 	. 
	nop			;6460	00 	. 
	nop			;6461	00 	. 
	nop			;6462	00 	. 
	nop			;6463	00 	. 
	nop			;6464	00 	. 
	nop			;6465	00 	. 
	nop			;6466	00 	. 
	nop			;6467	00 	. 
	nop			;6468	00 	. 
	nop			;6469	00 	. 
	nop			;646a	00 	. 
	nop			;646b	00 	. 
	nop			;646c	00 	. 
	nop			;646d	00 	. 
	nop			;646e	00 	. 
	nop			;646f	00 	. 
	nop			;6470	00 	. 
	nop			;6471	00 	. 
	nop			;6472	00 	. 
	nop			;6473	00 	. 
	nop			;6474	00 	. 
	nop			;6475	00 	. 
	nop			;6476	00 	. 
	nop			;6477	00 	. 
	nop			;6478	00 	. 
	nop			;6479	00 	. 
	nop			;647a	00 	. 
	nop			;647b	00 	. 
	nop			;647c	00 	. 
	nop			;647d	00 	. 
	nop			;647e	00 	. 
	nop			;647f	00 	. 
	nop			;6480	00 	. 
	nop			;6481	00 	. 
	nop			;6482	00 	. 
	nop			;6483	00 	. 
	nop			;6484	00 	. 
	nop			;6485	00 	. 
	nop			;6486	00 	. 
	nop			;6487	00 	. 
	nop			;6488	00 	. 
	nop			;6489	00 	. 
	nop			;648a	00 	. 
	nop			;648b	00 	. 
	nop			;648c	00 	. 
	nop			;648d	00 	. 
	nop			;648e	00 	. 
	nop			;648f	00 	. 
	nop			;6490	00 	. 
	nop			;6491	00 	. 
	nop			;6492	00 	. 
	nop			;6493	00 	. 
	nop			;6494	00 	. 
	nop			;6495	00 	. 
	nop			;6496	00 	. 
	nop			;6497	00 	. 
	nop			;6498	00 	. 
	nop			;6499	00 	. 
	nop			;649a	00 	. 
	nop			;649b	00 	. 
	nop			;649c	00 	. 
	nop			;649d	00 	. 
	nop			;649e	00 	. 
	nop			;649f	00 	. 
	nop			;64a0	00 	. 
	nop			;64a1	00 	. 
	nop			;64a2	00 	. 
	nop			;64a3	00 	. 
	nop			;64a4	00 	. 
	nop			;64a5	00 	. 
	nop			;64a6	00 	. 
	nop			;64a7	00 	. 
	nop			;64a8	00 	. 
	nop			;64a9	00 	. 
	nop			;64aa	00 	. 
	nop			;64ab	00 	. 
	nop			;64ac	00 	. 
	nop			;64ad	00 	. 
	nop			;64ae	00 	. 
	nop			;64af	00 	. 
	nop			;64b0	00 	. 
	nop			;64b1	00 	. 
	nop			;64b2	00 	. 
	nop			;64b3	00 	. 
	nop			;64b4	00 	. 
	nop			;64b5	00 	. 
	nop			;64b6	00 	. 
	nop			;64b7	00 	. 
	nop			;64b8	00 	. 
	nop			;64b9	00 	. 
	nop			;64ba	00 	. 
	nop			;64bb	00 	. 
	nop			;64bc	00 	. 
	nop			;64bd	00 	. 
	nop			;64be	00 	. 
	nop			;64bf	00 	. 
	nop			;64c0	00 	. 
	nop			;64c1	00 	. 
	nop			;64c2	00 	. 
	nop			;64c3	00 	. 
	nop			;64c4	00 	. 
	nop			;64c5	00 	. 
	nop			;64c6	00 	. 
	nop			;64c7	00 	. 
	nop			;64c8	00 	. 
	nop			;64c9	00 	. 
	nop			;64ca	00 	. 
	nop			;64cb	00 	. 
	nop			;64cc	00 	. 
	nop			;64cd	00 	. 
	nop			;64ce	00 	. 
	nop			;64cf	00 	. 
	nop			;64d0	00 	. 
	nop			;64d1	00 	. 
	nop			;64d2	00 	. 
	nop			;64d3	00 	. 
	nop			;64d4	00 	. 
	nop			;64d5	00 	. 
	nop			;64d6	00 	. 
	nop			;64d7	00 	. 
	nop			;64d8	00 	. 
	nop			;64d9	00 	. 
	nop			;64da	00 	. 
	nop			;64db	00 	. 
	nop			;64dc	00 	. 
	nop			;64dd	00 	. 
	nop			;64de	00 	. 
	nop			;64df	00 	. 
	nop			;64e0	00 	. 
	nop			;64e1	00 	. 
	nop			;64e2	00 	. 
	nop			;64e3	00 	. 
	nop			;64e4	00 	. 
	nop			;64e5	00 	. 
	nop			;64e6	00 	. 
	nop			;64e7	00 	. 
	nop			;64e8	00 	. 
	nop			;64e9	00 	. 
	nop			;64ea	00 	. 
	nop			;64eb	00 	. 
	nop			;64ec	00 	. 
	nop			;64ed	00 	. 
	nop			;64ee	00 	. 
	nop			;64ef	00 	. 
	nop			;64f0	00 	. 
	nop			;64f1	00 	. 
	nop			;64f2	00 	. 
	nop			;64f3	00 	. 
	nop			;64f4	00 	. 
	nop			;64f5	00 	. 
	nop			;64f6	00 	. 
	nop			;64f7	00 	. 
	nop			;64f8	00 	. 
	nop			;64f9	00 	. 
	nop			;64fa	00 	. 
	nop			;64fb	00 	. 
	nop			;64fc	00 	. 
	nop			;64fd	00 	. 
	nop			;64fe	00 	. 
	nop			;64ff	00 	. 
	nop			;6500	00 	. 
	nop			;6501	00 	. 
	nop			;6502	00 	. 
	nop			;6503	00 	. 
	nop			;6504	00 	. 
	nop			;6505	00 	. 
	nop			;6506	00 	. 
	nop			;6507	00 	. 
	nop			;6508	00 	. 
	nop			;6509	00 	. 
	nop			;650a	00 	. 
	nop			;650b	00 	. 
	nop			;650c	00 	. 
	nop			;650d	00 	. 
	nop			;650e	00 	. 
	nop			;650f	00 	. 
	nop			;6510	00 	. 
	nop			;6511	00 	. 
	nop			;6512	00 	. 
	nop			;6513	00 	. 
	nop			;6514	00 	. 
	nop			;6515	00 	. 
	nop			;6516	00 	. 
	nop			;6517	00 	. 
	nop			;6518	00 	. 
	nop			;6519	00 	. 
	nop			;651a	00 	. 
	nop			;651b	00 	. 
	nop			;651c	00 	. 
	nop			;651d	00 	. 
	nop			;651e	00 	. 
	nop			;651f	00 	. 
	nop			;6520	00 	. 
	nop			;6521	00 	. 
	nop			;6522	00 	. 
	nop			;6523	00 	. 
	nop			;6524	00 	. 
	nop			;6525	00 	. 
	nop			;6526	00 	. 
	nop			;6527	00 	. 
	nop			;6528	00 	. 
	nop			;6529	00 	. 
	nop			;652a	00 	. 
	nop			;652b	00 	. 
	nop			;652c	00 	. 
	nop			;652d	00 	. 
	nop			;652e	00 	. 
	nop			;652f	00 	. 
	nop			;6530	00 	. 
	nop			;6531	00 	. 
	nop			;6532	00 	. 
	nop			;6533	00 	. 
	nop			;6534	00 	. 
	nop			;6535	00 	. 
	nop			;6536	00 	. 
	nop			;6537	00 	. 
	nop			;6538	00 	. 
	nop			;6539	00 	. 
	nop			;653a	00 	. 
	nop			;653b	00 	. 
	nop			;653c	00 	. 
	nop			;653d	00 	. 
	nop			;653e	00 	. 
	nop			;653f	00 	. 
	nop			;6540	00 	. 
	nop			;6541	00 	. 
	nop			;6542	00 	. 
	nop			;6543	00 	. 
	nop			;6544	00 	. 
	nop			;6545	00 	. 
	nop			;6546	00 	. 
	nop			;6547	00 	. 
	nop			;6548	00 	. 
	nop			;6549	00 	. 
	nop			;654a	00 	. 
	nop			;654b	00 	. 
	nop			;654c	00 	. 
	nop			;654d	00 	. 
	nop			;654e	00 	. 
	nop			;654f	00 	. 
	nop			;6550	00 	. 
	nop			;6551	00 	. 
	nop			;6552	00 	. 
	nop			;6553	00 	. 
	nop			;6554	00 	. 
	nop			;6555	00 	. 
	nop			;6556	00 	. 
	nop			;6557	00 	. 
	nop			;6558	00 	. 
	nop			;6559	00 	. 
	nop			;655a	00 	. 
	nop			;655b	00 	. 
	nop			;655c	00 	. 
	nop			;655d	00 	. 
	nop			;655e	00 	. 
	nop			;655f	00 	. 
	nop			;6560	00 	. 
	nop			;6561	00 	. 
	nop			;6562	00 	. 
	nop			;6563	00 	. 
	nop			;6564	00 	. 
	nop			;6565	00 	. 
	nop			;6566	00 	. 
	nop			;6567	00 	. 
	nop			;6568	00 	. 
	nop			;6569	00 	. 
	nop			;656a	00 	. 
	nop			;656b	00 	. 
	nop			;656c	00 	. 
	nop			;656d	00 	. 
	nop			;656e	00 	. 
	nop			;656f	00 	. 
	nop			;6570	00 	. 
	nop			;6571	00 	. 
	nop			;6572	00 	. 
	nop			;6573	00 	. 
	nop			;6574	00 	. 
	nop			;6575	00 	. 
	nop			;6576	00 	. 
	nop			;6577	00 	. 
	nop			;6578	00 	. 
	nop			;6579	00 	. 
	nop			;657a	00 	. 
	nop			;657b	00 	. 
	nop			;657c	00 	. 
	nop			;657d	00 	. 
	nop			;657e	00 	. 
	nop			;657f	00 	. 
	nop			;6580	00 	. 
	nop			;6581	00 	. 
	nop			;6582	00 	. 
	nop			;6583	00 	. 
	nop			;6584	00 	. 
	nop			;6585	00 	. 
	nop			;6586	00 	. 
	nop			;6587	00 	. 
	nop			;6588	00 	. 
	nop			;6589	00 	. 
	nop			;658a	00 	. 
	nop			;658b	00 	. 
	nop			;658c	00 	. 
	nop			;658d	00 	. 
	nop			;658e	00 	. 
	nop			;658f	00 	. 
	nop			;6590	00 	. 
	nop			;6591	00 	. 
	nop			;6592	00 	. 
	nop			;6593	00 	. 
	nop			;6594	00 	. 
	nop			;6595	00 	. 
	nop			;6596	00 	. 
	nop			;6597	00 	. 
	nop			;6598	00 	. 
	nop			;6599	00 	. 
	nop			;659a	00 	. 
	nop			;659b	00 	. 
	nop			;659c	00 	. 
	nop			;659d	00 	. 
	nop			;659e	00 	. 
	nop			;659f	00 	. 
	nop			;65a0	00 	. 
	nop			;65a1	00 	. 
	nop			;65a2	00 	. 
	nop			;65a3	00 	. 
	nop			;65a4	00 	. 
	nop			;65a5	00 	. 
	nop			;65a6	00 	. 
	nop			;65a7	00 	. 
	nop			;65a8	00 	. 
	nop			;65a9	00 	. 
	nop			;65aa	00 	. 
	nop			;65ab	00 	. 
	nop			;65ac	00 	. 
	nop			;65ad	00 	. 
	nop			;65ae	00 	. 
	nop			;65af	00 	. 
	nop			;65b0	00 	. 
	nop			;65b1	00 	. 
	nop			;65b2	00 	. 
	nop			;65b3	00 	. 
	nop			;65b4	00 	. 
	nop			;65b5	00 	. 
	nop			;65b6	00 	. 
	nop			;65b7	00 	. 
	nop			;65b8	00 	. 
	nop			;65b9	00 	. 
	nop			;65ba	00 	. 
	nop			;65bb	00 	. 
	nop			;65bc	00 	. 
	nop			;65bd	00 	. 
	nop			;65be	00 	. 
	nop			;65bf	00 	. 
	nop			;65c0	00 	. 
	nop			;65c1	00 	. 
	nop			;65c2	00 	. 
	nop			;65c3	00 	. 
	nop			;65c4	00 	. 
	nop			;65c5	00 	. 
	nop			;65c6	00 	. 
	nop			;65c7	00 	. 
	nop			;65c8	00 	. 
	nop			;65c9	00 	. 
	nop			;65ca	00 	. 
	nop			;65cb	00 	. 
	nop			;65cc	00 	. 
	nop			;65cd	00 	. 
	nop			;65ce	00 	. 
	nop			;65cf	00 	. 
	nop			;65d0	00 	. 
	nop			;65d1	00 	. 
	nop			;65d2	00 	. 
	nop			;65d3	00 	. 
	nop			;65d4	00 	. 
	nop			;65d5	00 	. 
	nop			;65d6	00 	. 
	nop			;65d7	00 	. 
	nop			;65d8	00 	. 
	nop			;65d9	00 	. 
	nop			;65da	00 	. 
	nop			;65db	00 	. 
	nop			;65dc	00 	. 
	nop			;65dd	00 	. 
	nop			;65de	00 	. 
	nop			;65df	00 	. 
	nop			;65e0	00 	. 
	nop			;65e1	00 	. 
	nop			;65e2	00 	. 
	nop			;65e3	00 	. 
	nop			;65e4	00 	. 
	nop			;65e5	00 	. 
	nop			;65e6	00 	. 
	nop			;65e7	00 	. 
	nop			;65e8	00 	. 
	nop			;65e9	00 	. 
	nop			;65ea	00 	. 
	nop			;65eb	00 	. 
	nop			;65ec	00 	. 
	nop			;65ed	00 	. 
	nop			;65ee	00 	. 
	nop			;65ef	00 	. 
	nop			;65f0	00 	. 
	nop			;65f1	00 	. 
	nop			;65f2	00 	. 
	nop			;65f3	00 	. 
	nop			;65f4	00 	. 
	nop			;65f5	00 	. 
	nop			;65f6	00 	. 
	nop			;65f7	00 	. 
	nop			;65f8	00 	. 
	nop			;65f9	00 	. 
	nop			;65fa	00 	. 
	nop			;65fb	00 	. 
	nop			;65fc	00 	. 
	nop			;65fd	00 	. 
	nop			;65fe	00 	. 
	nop			;65ff	00 	. 
	nop			;6600	00 	. 
	nop			;6601	00 	. 
	nop			;6602	00 	. 
	nop			;6603	00 	. 
	nop			;6604	00 	. 
	nop			;6605	00 	. 
	nop			;6606	00 	. 
	nop			;6607	00 	. 
	nop			;6608	00 	. 
	nop			;6609	00 	. 
	nop			;660a	00 	. 
	nop			;660b	00 	. 
	nop			;660c	00 	. 
	nop			;660d	00 	. 
	nop			;660e	00 	. 
	nop			;660f	00 	. 
	nop			;6610	00 	. 
	nop			;6611	00 	. 
	nop			;6612	00 	. 
	nop			;6613	00 	. 
	nop			;6614	00 	. 
	nop			;6615	00 	. 
	nop			;6616	00 	. 
	nop			;6617	00 	. 
	nop			;6618	00 	. 
	nop			;6619	00 	. 
	nop			;661a	00 	. 
	nop			;661b	00 	. 
	nop			;661c	00 	. 
	nop			;661d	00 	. 
	nop			;661e	00 	. 
	nop			;661f	00 	. 
	nop			;6620	00 	. 
	nop			;6621	00 	. 
	nop			;6622	00 	. 
	nop			;6623	00 	. 
	nop			;6624	00 	. 
	nop			;6625	00 	. 
	nop			;6626	00 	. 
	nop			;6627	00 	. 
	nop			;6628	00 	. 
	nop			;6629	00 	. 
	nop			;662a	00 	. 
	nop			;662b	00 	. 
	nop			;662c	00 	. 
	nop			;662d	00 	. 
	nop			;662e	00 	. 
	nop			;662f	00 	. 
	nop			;6630	00 	. 
	nop			;6631	00 	. 
	nop			;6632	00 	. 
	nop			;6633	00 	. 
	nop			;6634	00 	. 
	nop			;6635	00 	. 
	nop			;6636	00 	. 
	nop			;6637	00 	. 
	nop			;6638	00 	. 
	nop			;6639	00 	. 
	nop			;663a	00 	. 
	nop			;663b	00 	. 
	nop			;663c	00 	. 
	nop			;663d	00 	. 
	nop			;663e	00 	. 
	nop			;663f	00 	. 
	nop			;6640	00 	. 
	nop			;6641	00 	. 
	nop			;6642	00 	. 
	nop			;6643	00 	. 
	nop			;6644	00 	. 
	nop			;6645	00 	. 
	nop			;6646	00 	. 
	nop			;6647	00 	. 
	nop			;6648	00 	. 
	nop			;6649	00 	. 
	nop			;664a	00 	. 
	nop			;664b	00 	. 
	nop			;664c	00 	. 
	nop			;664d	00 	. 
	nop			;664e	00 	. 
	nop			;664f	00 	. 
	nop			;6650	00 	. 
	nop			;6651	00 	. 
	nop			;6652	00 	. 
	nop			;6653	00 	. 
	nop			;6654	00 	. 
	nop			;6655	00 	. 
	nop			;6656	00 	. 
	nop			;6657	00 	. 
	nop			;6658	00 	. 
	nop			;6659	00 	. 
	nop			;665a	00 	. 
	nop			;665b	00 	. 
	nop			;665c	00 	. 
	nop			;665d	00 	. 
	nop			;665e	00 	. 
	nop			;665f	00 	. 
	nop			;6660	00 	. 
	nop			;6661	00 	. 
	nop			;6662	00 	. 
	nop			;6663	00 	. 
	nop			;6664	00 	. 
	nop			;6665	00 	. 
	nop			;6666	00 	. 
	nop			;6667	00 	. 
	nop			;6668	00 	. 
	nop			;6669	00 	. 
	nop			;666a	00 	. 
	nop			;666b	00 	. 
	nop			;666c	00 	. 
	nop			;666d	00 	. 
	nop			;666e	00 	. 
	nop			;666f	00 	. 
	nop			;6670	00 	. 
	nop			;6671	00 	. 
	nop			;6672	00 	. 
	nop			;6673	00 	. 
	nop			;6674	00 	. 
	nop			;6675	00 	. 
	nop			;6676	00 	. 
	nop			;6677	00 	. 
	nop			;6678	00 	. 
	nop			;6679	00 	. 
	nop			;667a	00 	. 
	nop			;667b	00 	. 
	nop			;667c	00 	. 
	nop			;667d	00 	. 
	nop			;667e	00 	. 
	nop			;667f	00 	. 
	nop			;6680	00 	. 
	nop			;6681	00 	. 
	nop			;6682	00 	. 
	nop			;6683	00 	. 
	nop			;6684	00 	. 
	nop			;6685	00 	. 
	nop			;6686	00 	. 
	nop			;6687	00 	. 
	nop			;6688	00 	. 
	nop			;6689	00 	. 
	nop			;668a	00 	. 
	nop			;668b	00 	. 
	nop			;668c	00 	. 
	nop			;668d	00 	. 
	nop			;668e	00 	. 
	nop			;668f	00 	. 
	nop			;6690	00 	. 
	nop			;6691	00 	. 
	nop			;6692	00 	. 
	nop			;6693	00 	. 
	nop			;6694	00 	. 
	nop			;6695	00 	. 
	nop			;6696	00 	. 
	nop			;6697	00 	. 
	nop			;6698	00 	. 
	nop			;6699	00 	. 
	nop			;669a	00 	. 
	nop			;669b	00 	. 
	nop			;669c	00 	. 
	nop			;669d	00 	. 
	nop			;669e	00 	. 
	nop			;669f	00 	. 
	nop			;66a0	00 	. 
	nop			;66a1	00 	. 
	nop			;66a2	00 	. 
	nop			;66a3	00 	. 
	nop			;66a4	00 	. 
	nop			;66a5	00 	. 
	nop			;66a6	00 	. 
	nop			;66a7	00 	. 
	nop			;66a8	00 	. 
	nop			;66a9	00 	. 
	nop			;66aa	00 	. 
	nop			;66ab	00 	. 
	nop			;66ac	00 	. 
	nop			;66ad	00 	. 
	nop			;66ae	00 	. 
	nop			;66af	00 	. 
	nop			;66b0	00 	. 
	nop			;66b1	00 	. 
	nop			;66b2	00 	. 
	nop			;66b3	00 	. 
	nop			;66b4	00 	. 
	nop			;66b5	00 	. 
	nop			;66b6	00 	. 
	nop			;66b7	00 	. 
	nop			;66b8	00 	. 
	nop			;66b9	00 	. 
	nop			;66ba	00 	. 
	nop			;66bb	00 	. 
	nop			;66bc	00 	. 
	nop			;66bd	00 	. 
	nop			;66be	00 	. 
	nop			;66bf	00 	. 
	nop			;66c0	00 	. 
	nop			;66c1	00 	. 
	nop			;66c2	00 	. 
	nop			;66c3	00 	. 
	nop			;66c4	00 	. 
	nop			;66c5	00 	. 
	nop			;66c6	00 	. 
	nop			;66c7	00 	. 
	nop			;66c8	00 	. 
	nop			;66c9	00 	. 
	nop			;66ca	00 	. 
	nop			;66cb	00 	. 
	nop			;66cc	00 	. 
	nop			;66cd	00 	. 
	nop			;66ce	00 	. 
	nop			;66cf	00 	. 
	nop			;66d0	00 	. 
	nop			;66d1	00 	. 
	nop			;66d2	00 	. 
	nop			;66d3	00 	. 
	nop			;66d4	00 	. 
	nop			;66d5	00 	. 
	nop			;66d6	00 	. 
	nop			;66d7	00 	. 
	nop			;66d8	00 	. 
	nop			;66d9	00 	. 
	nop			;66da	00 	. 
	nop			;66db	00 	. 
	nop			;66dc	00 	. 
	nop			;66dd	00 	. 
	nop			;66de	00 	. 
	nop			;66df	00 	. 
	nop			;66e0	00 	. 
	nop			;66e1	00 	. 
	nop			;66e2	00 	. 
	nop			;66e3	00 	. 
	nop			;66e4	00 	. 
	nop			;66e5	00 	. 
	nop			;66e6	00 	. 
	nop			;66e7	00 	. 
	nop			;66e8	00 	. 
	nop			;66e9	00 	. 
	nop			;66ea	00 	. 
	nop			;66eb	00 	. 
	nop			;66ec	00 	. 
	nop			;66ed	00 	. 
	nop			;66ee	00 	. 
	nop			;66ef	00 	. 
	nop			;66f0	00 	. 
	nop			;66f1	00 	. 
	nop			;66f2	00 	. 
	nop			;66f3	00 	. 
	nop			;66f4	00 	. 
	nop			;66f5	00 	. 
	nop			;66f6	00 	. 
	nop			;66f7	00 	. 
	nop			;66f8	00 	. 
	nop			;66f9	00 	. 
	nop			;66fa	00 	. 
	nop			;66fb	00 	. 
	nop			;66fc	00 	. 
	nop			;66fd	00 	. 
	nop			;66fe	00 	. 
	nop			;66ff	00 	. 
	nop			;6700	00 	. 
	nop			;6701	00 	. 
	nop			;6702	00 	. 
	nop			;6703	00 	. 
	nop			;6704	00 	. 
	nop			;6705	00 	. 
	nop			;6706	00 	. 
	nop			;6707	00 	. 
	nop			;6708	00 	. 
	nop			;6709	00 	. 
	nop			;670a	00 	. 
	nop			;670b	00 	. 
	nop			;670c	00 	. 
	nop			;670d	00 	. 
	nop			;670e	00 	. 
	nop			;670f	00 	. 
	nop			;6710	00 	. 
	nop			;6711	00 	. 
	nop			;6712	00 	. 
	nop			;6713	00 	. 
	nop			;6714	00 	. 
	nop			;6715	00 	. 
	nop			;6716	00 	. 
	nop			;6717	00 	. 
	nop			;6718	00 	. 
	nop			;6719	00 	. 
	nop			;671a	00 	. 
	nop			;671b	00 	. 
	nop			;671c	00 	. 
	nop			;671d	00 	. 
	nop			;671e	00 	. 
	nop			;671f	00 	. 
	nop			;6720	00 	. 
	nop			;6721	00 	. 
	nop			;6722	00 	. 
	nop			;6723	00 	. 
	nop			;6724	00 	. 
	nop			;6725	00 	. 
	nop			;6726	00 	. 
	nop			;6727	00 	. 
	nop			;6728	00 	. 
	nop			;6729	00 	. 
	nop			;672a	00 	. 
	nop			;672b	00 	. 
	nop			;672c	00 	. 
	nop			;672d	00 	. 
	nop			;672e	00 	. 
	nop			;672f	00 	. 
	nop			;6730	00 	. 
	nop			;6731	00 	. 
	nop			;6732	00 	. 
	nop			;6733	00 	. 
	nop			;6734	00 	. 
	nop			;6735	00 	. 
	nop			;6736	00 	. 
	nop			;6737	00 	. 
	nop			;6738	00 	. 
	nop			;6739	00 	. 
	nop			;673a	00 	. 
	nop			;673b	00 	. 
	nop			;673c	00 	. 
	nop			;673d	00 	. 
	nop			;673e	00 	. 
	nop			;673f	00 	. 
	nop			;6740	00 	. 
	nop			;6741	00 	. 
	nop			;6742	00 	. 
	nop			;6743	00 	. 
	nop			;6744	00 	. 
	nop			;6745	00 	. 
	nop			;6746	00 	. 
	nop			;6747	00 	. 
	nop			;6748	00 	. 
	nop			;6749	00 	. 
	nop			;674a	00 	. 
	nop			;674b	00 	. 
	nop			;674c	00 	. 
	nop			;674d	00 	. 
	nop			;674e	00 	. 
	nop			;674f	00 	. 
	nop			;6750	00 	. 
	nop			;6751	00 	. 
	nop			;6752	00 	. 
	nop			;6753	00 	. 
	nop			;6754	00 	. 
	nop			;6755	00 	. 
	nop			;6756	00 	. 
	nop			;6757	00 	. 
	nop			;6758	00 	. 
	nop			;6759	00 	. 
	nop			;675a	00 	. 
	nop			;675b	00 	. 
	nop			;675c	00 	. 
	nop			;675d	00 	. 
	nop			;675e	00 	. 
	nop			;675f	00 	. 
	nop			;6760	00 	. 
	nop			;6761	00 	. 
	nop			;6762	00 	. 
	nop			;6763	00 	. 
	nop			;6764	00 	. 
	nop			;6765	00 	. 
	nop			;6766	00 	. 
	nop			;6767	00 	. 
	nop			;6768	00 	. 
	nop			;6769	00 	. 
	nop			;676a	00 	. 
	nop			;676b	00 	. 
	nop			;676c	00 	. 
	nop			;676d	00 	. 
	nop			;676e	00 	. 
	nop			;676f	00 	. 
	nop			;6770	00 	. 
	nop			;6771	00 	. 
	nop			;6772	00 	. 
	nop			;6773	00 	. 
	nop			;6774	00 	. 
	nop			;6775	00 	. 
	nop			;6776	00 	. 
	nop			;6777	00 	. 
	nop			;6778	00 	. 
	nop			;6779	00 	. 
	nop			;677a	00 	. 
	nop			;677b	00 	. 
	nop			;677c	00 	. 
	nop			;677d	00 	. 
	nop			;677e	00 	. 
	nop			;677f	00 	. 
	nop			;6780	00 	. 
	nop			;6781	00 	. 
	nop			;6782	00 	. 
	nop			;6783	00 	. 
	nop			;6784	00 	. 
	nop			;6785	00 	. 
	nop			;6786	00 	. 
	nop			;6787	00 	. 
	nop			;6788	00 	. 
	nop			;6789	00 	. 
	nop			;678a	00 	. 
	nop			;678b	00 	. 
	nop			;678c	00 	. 
	nop			;678d	00 	. 
	nop			;678e	00 	. 
	nop			;678f	00 	. 
	nop			;6790	00 	. 
	nop			;6791	00 	. 
	nop			;6792	00 	. 
	nop			;6793	00 	. 
	nop			;6794	00 	. 
	nop			;6795	00 	. 
	nop			;6796	00 	. 
	nop			;6797	00 	. 
	nop			;6798	00 	. 
	nop			;6799	00 	. 
	nop			;679a	00 	. 
	nop			;679b	00 	. 
	nop			;679c	00 	. 
	nop			;679d	00 	. 
	nop			;679e	00 	. 
	nop			;679f	00 	. 
	nop			;67a0	00 	. 
	nop			;67a1	00 	. 
	nop			;67a2	00 	. 
	nop			;67a3	00 	. 
	nop			;67a4	00 	. 
	nop			;67a5	00 	. 
	nop			;67a6	00 	. 
	nop			;67a7	00 	. 
	nop			;67a8	00 	. 
	nop			;67a9	00 	. 
	nop			;67aa	00 	. 
	nop			;67ab	00 	. 
	nop			;67ac	00 	. 
	nop			;67ad	00 	. 
	nop			;67ae	00 	. 
	nop			;67af	00 	. 
	nop			;67b0	00 	. 
	nop			;67b1	00 	. 
	nop			;67b2	00 	. 
	nop			;67b3	00 	. 
	nop			;67b4	00 	. 
	nop			;67b5	00 	. 
	nop			;67b6	00 	. 
	nop			;67b7	00 	. 
	nop			;67b8	00 	. 
	nop			;67b9	00 	. 
	nop			;67ba	00 	. 
	nop			;67bb	00 	. 
	nop			;67bc	00 	. 
	nop			;67bd	00 	. 
	nop			;67be	00 	. 
	nop			;67bf	00 	. 
	nop			;67c0	00 	. 
	nop			;67c1	00 	. 
	nop			;67c2	00 	. 
	nop			;67c3	00 	. 
	nop			;67c4	00 	. 
	nop			;67c5	00 	. 
	nop			;67c6	00 	. 
	nop			;67c7	00 	. 
	nop			;67c8	00 	. 
	nop			;67c9	00 	. 
	nop			;67ca	00 	. 
	nop			;67cb	00 	. 
	nop			;67cc	00 	. 
	nop			;67cd	00 	. 
	nop			;67ce	00 	. 
	nop			;67cf	00 	. 
	nop			;67d0	00 	. 
	nop			;67d1	00 	. 
	nop			;67d2	00 	. 
	nop			;67d3	00 	. 
	nop			;67d4	00 	. 
	nop			;67d5	00 	. 
	nop			;67d6	00 	. 
	nop			;67d7	00 	. 
	nop			;67d8	00 	. 
	nop			;67d9	00 	. 
	nop			;67da	00 	. 
	nop			;67db	00 	. 
	nop			;67dc	00 	. 
	nop			;67dd	00 	. 
	nop			;67de	00 	. 
	nop			;67df	00 	. 
	nop			;67e0	00 	. 
	nop			;67e1	00 	. 
	nop			;67e2	00 	. 
	nop			;67e3	00 	. 
	nop			;67e4	00 	. 
	nop			;67e5	00 	. 
	nop			;67e6	00 	. 
	nop			;67e7	00 	. 
	nop			;67e8	00 	. 
	nop			;67e9	00 	. 
	nop			;67ea	00 	. 
	nop			;67eb	00 	. 
	nop			;67ec	00 	. 
	nop			;67ed	00 	. 
	nop			;67ee	00 	. 
	nop			;67ef	00 	. 
	nop			;67f0	00 	. 
	nop			;67f1	00 	. 
	nop			;67f2	00 	. 
	nop			;67f3	00 	. 
	nop			;67f4	00 	. 
	nop			;67f5	00 	. 
	nop			;67f6	00 	. 
	nop			;67f7	00 	. 
	nop			;67f8	00 	. 
	nop			;67f9	00 	. 
	nop			;67fa	00 	. 
	nop			;67fb	00 	. 
	nop			;67fc	00 	. 
	nop			;67fd	00 	. 
	nop			;67fe	00 	. 
	nop			;67ff	00 	. 
	nop			;6800	00 	. 
	nop			;6801	00 	. 
	nop			;6802	00 	. 
	nop			;6803	00 	. 
	nop			;6804	00 	. 
	nop			;6805	00 	. 
	nop			;6806	00 	. 
	nop			;6807	00 	. 
	nop			;6808	00 	. 
	nop			;6809	00 	. 
	nop			;680a	00 	. 
	nop			;680b	00 	. 
	nop			;680c	00 	. 
	nop			;680d	00 	. 
	nop			;680e	00 	. 
	nop			;680f	00 	. 
	nop			;6810	00 	. 
	nop			;6811	00 	. 
	nop			;6812	00 	. 
	nop			;6813	00 	. 
	nop			;6814	00 	. 
	nop			;6815	00 	. 
	nop			;6816	00 	. 
	nop			;6817	00 	. 
	nop			;6818	00 	. 
	nop			;6819	00 	. 
	nop			;681a	00 	. 
	nop			;681b	00 	. 
	nop			;681c	00 	. 
	nop			;681d	00 	. 
	nop			;681e	00 	. 
	nop			;681f	00 	. 
	nop			;6820	00 	. 
	nop			;6821	00 	. 
	nop			;6822	00 	. 
	nop			;6823	00 	. 
	nop			;6824	00 	. 
	nop			;6825	00 	. 
	nop			;6826	00 	. 
	nop			;6827	00 	. 
	nop			;6828	00 	. 
	nop			;6829	00 	. 
	nop			;682a	00 	. 
	nop			;682b	00 	. 
	nop			;682c	00 	. 
	nop			;682d	00 	. 
	nop			;682e	00 	. 
	nop			;682f	00 	. 
	nop			;6830	00 	. 
	nop			;6831	00 	. 
	nop			;6832	00 	. 
	nop			;6833	00 	. 
	nop			;6834	00 	. 
	nop			;6835	00 	. 
	nop			;6836	00 	. 
	nop			;6837	00 	. 
	nop			;6838	00 	. 
	nop			;6839	00 	. 
	nop			;683a	00 	. 
	nop			;683b	00 	. 
	nop			;683c	00 	. 
	nop			;683d	00 	. 
	nop			;683e	00 	. 
	nop			;683f	00 	. 
	nop			;6840	00 	. 
	nop			;6841	00 	. 
	nop			;6842	00 	. 
	nop			;6843	00 	. 
	nop			;6844	00 	. 
	nop			;6845	00 	. 
	nop			;6846	00 	. 
	nop			;6847	00 	. 
	nop			;6848	00 	. 
	nop			;6849	00 	. 
	nop			;684a	00 	. 
	nop			;684b	00 	. 
	nop			;684c	00 	. 
	nop			;684d	00 	. 
	nop			;684e	00 	. 
	nop			;684f	00 	. 
	nop			;6850	00 	. 
	nop			;6851	00 	. 
	nop			;6852	00 	. 
	nop			;6853	00 	. 
	nop			;6854	00 	. 
	nop			;6855	00 	. 
	nop			;6856	00 	. 
	nop			;6857	00 	. 
	nop			;6858	00 	. 
	nop			;6859	00 	. 
	nop			;685a	00 	. 
	nop			;685b	00 	. 
	nop			;685c	00 	. 
	nop			;685d	00 	. 
	nop			;685e	00 	. 
	nop			;685f	00 	. 
	nop			;6860	00 	. 
	nop			;6861	00 	. 
	nop			;6862	00 	. 
	nop			;6863	00 	. 
	nop			;6864	00 	. 
	nop			;6865	00 	. 
	nop			;6866	00 	. 
	nop			;6867	00 	. 
	nop			;6868	00 	. 
	nop			;6869	00 	. 
	nop			;686a	00 	. 
	nop			;686b	00 	. 
	nop			;686c	00 	. 
	nop			;686d	00 	. 
	nop			;686e	00 	. 
	nop			;686f	00 	. 
	nop			;6870	00 	. 
	nop			;6871	00 	. 
	nop			;6872	00 	. 
	nop			;6873	00 	. 
	nop			;6874	00 	. 
	nop			;6875	00 	. 
	nop			;6876	00 	. 
	nop			;6877	00 	. 
	nop			;6878	00 	. 
	nop			;6879	00 	. 
	nop			;687a	00 	. 
	nop			;687b	00 	. 
	nop			;687c	00 	. 
	nop			;687d	00 	. 
	nop			;687e	00 	. 
	nop			;687f	00 	. 
	nop			;6880	00 	. 
	nop			;6881	00 	. 
	nop			;6882	00 	. 
	nop			;6883	00 	. 
	nop			;6884	00 	. 
	nop			;6885	00 	. 
	nop			;6886	00 	. 
	nop			;6887	00 	. 
	nop			;6888	00 	. 
	nop			;6889	00 	. 
	nop			;688a	00 	. 
	nop			;688b	00 	. 
	nop			;688c	00 	. 
	nop			;688d	00 	. 
	nop			;688e	00 	. 
	nop			;688f	00 	. 
	nop			;6890	00 	. 
	nop			;6891	00 	. 
	nop			;6892	00 	. 
	nop			;6893	00 	. 
	nop			;6894	00 	. 
	nop			;6895	00 	. 
	nop			;6896	00 	. 
	nop			;6897	00 	. 
	nop			;6898	00 	. 
	nop			;6899	00 	. 
	nop			;689a	00 	. 
	nop			;689b	00 	. 
	nop			;689c	00 	. 
	nop			;689d	00 	. 
	nop			;689e	00 	. 
	nop			;689f	00 	. 
	nop			;68a0	00 	. 
	nop			;68a1	00 	. 
	nop			;68a2	00 	. 
	nop			;68a3	00 	. 
	nop			;68a4	00 	. 
	nop			;68a5	00 	. 
	nop			;68a6	00 	. 
	nop			;68a7	00 	. 
	nop			;68a8	00 	. 
	nop			;68a9	00 	. 
	nop			;68aa	00 	. 
	nop			;68ab	00 	. 
	nop			;68ac	00 	. 
	nop			;68ad	00 	. 
	nop			;68ae	00 	. 
	nop			;68af	00 	. 
	nop			;68b0	00 	. 
	nop			;68b1	00 	. 
	nop			;68b2	00 	. 
	nop			;68b3	00 	. 
	nop			;68b4	00 	. 
	nop			;68b5	00 	. 
	nop			;68b6	00 	. 
	nop			;68b7	00 	. 
	nop			;68b8	00 	. 
	nop			;68b9	00 	. 
	nop			;68ba	00 	. 
	nop			;68bb	00 	. 
	nop			;68bc	00 	. 
	nop			;68bd	00 	. 
	nop			;68be	00 	. 
	nop			;68bf	00 	. 
	nop			;68c0	00 	. 
	nop			;68c1	00 	. 
	nop			;68c2	00 	. 
	nop			;68c3	00 	. 
	nop			;68c4	00 	. 
	nop			;68c5	00 	. 
	nop			;68c6	00 	. 
	nop			;68c7	00 	. 
	nop			;68c8	00 	. 
	nop			;68c9	00 	. 
	nop			;68ca	00 	. 
	nop			;68cb	00 	. 
	nop			;68cc	00 	. 
	nop			;68cd	00 	. 
	nop			;68ce	00 	. 
	nop			;68cf	00 	. 
	nop			;68d0	00 	. 
	nop			;68d1	00 	. 
	nop			;68d2	00 	. 
	nop			;68d3	00 	. 
	nop			;68d4	00 	. 
	nop			;68d5	00 	. 
	nop			;68d6	00 	. 
	nop			;68d7	00 	. 
	nop			;68d8	00 	. 
	nop			;68d9	00 	. 
	nop			;68da	00 	. 
	nop			;68db	00 	. 
	nop			;68dc	00 	. 
	nop			;68dd	00 	. 
	nop			;68de	00 	. 
	nop			;68df	00 	. 
	nop			;68e0	00 	. 
	nop			;68e1	00 	. 
	nop			;68e2	00 	. 
	nop			;68e3	00 	. 
	nop			;68e4	00 	. 
	nop			;68e5	00 	. 
	nop			;68e6	00 	. 
	nop			;68e7	00 	. 
	nop			;68e8	00 	. 
	nop			;68e9	00 	. 
	nop			;68ea	00 	. 
	nop			;68eb	00 	. 
	nop			;68ec	00 	. 
	nop			;68ed	00 	. 
	nop			;68ee	00 	. 
	nop			;68ef	00 	. 
	nop			;68f0	00 	. 
	nop			;68f1	00 	. 
	nop			;68f2	00 	. 
	nop			;68f3	00 	. 
	nop			;68f4	00 	. 
	nop			;68f5	00 	. 
	nop			;68f6	00 	. 
	nop			;68f7	00 	. 
	nop			;68f8	00 	. 
	nop			;68f9	00 	. 
	nop			;68fa	00 	. 
	nop			;68fb	00 	. 
	nop			;68fc	00 	. 
	nop			;68fd	00 	. 
	nop			;68fe	00 	. 
	nop			;68ff	00 	. 
	nop			;6900	00 	. 
	nop			;6901	00 	. 
	nop			;6902	00 	. 
	nop			;6903	00 	. 
	nop			;6904	00 	. 
	nop			;6905	00 	. 
	nop			;6906	00 	. 
	nop			;6907	00 	. 
	nop			;6908	00 	. 
	nop			;6909	00 	. 
	nop			;690a	00 	. 
	nop			;690b	00 	. 
	nop			;690c	00 	. 
	nop			;690d	00 	. 
	nop			;690e	00 	. 
	nop			;690f	00 	. 
	nop			;6910	00 	. 
	nop			;6911	00 	. 
	nop			;6912	00 	. 
	nop			;6913	00 	. 
	nop			;6914	00 	. 
	nop			;6915	00 	. 
	nop			;6916	00 	. 
	nop			;6917	00 	. 
	nop			;6918	00 	. 
	nop			;6919	00 	. 
	nop			;691a	00 	. 
	nop			;691b	00 	. 
	nop			;691c	00 	. 
	nop			;691d	00 	. 
	nop			;691e	00 	. 
	nop			;691f	00 	. 
	nop			;6920	00 	. 
	nop			;6921	00 	. 
	nop			;6922	00 	. 
	nop			;6923	00 	. 
	nop			;6924	00 	. 
	nop			;6925	00 	. 
	nop			;6926	00 	. 
	nop			;6927	00 	. 
	nop			;6928	00 	. 
	nop			;6929	00 	. 
	nop			;692a	00 	. 
	nop			;692b	00 	. 
	nop			;692c	00 	. 
	nop			;692d	00 	. 
	nop			;692e	00 	. 
	nop			;692f	00 	. 
	nop			;6930	00 	. 
	nop			;6931	00 	. 
	nop			;6932	00 	. 
	nop			;6933	00 	. 
	nop			;6934	00 	. 
	nop			;6935	00 	. 
	nop			;6936	00 	. 
	nop			;6937	00 	. 
	nop			;6938	00 	. 
	nop			;6939	00 	. 
	nop			;693a	00 	. 
	nop			;693b	00 	. 
	nop			;693c	00 	. 
	nop			;693d	00 	. 
	nop			;693e	00 	. 
	nop			;693f	00 	. 
	nop			;6940	00 	. 
	nop			;6941	00 	. 
	nop			;6942	00 	. 
	nop			;6943	00 	. 
	nop			;6944	00 	. 
	nop			;6945	00 	. 
	nop			;6946	00 	. 
	nop			;6947	00 	. 
	nop			;6948	00 	. 
	nop			;6949	00 	. 
	nop			;694a	00 	. 
	nop			;694b	00 	. 
	nop			;694c	00 	. 
	nop			;694d	00 	. 
	nop			;694e	00 	. 
	nop			;694f	00 	. 
	nop			;6950	00 	. 
	nop			;6951	00 	. 
	nop			;6952	00 	. 
	nop			;6953	00 	. 
	nop			;6954	00 	. 
	nop			;6955	00 	. 
	nop			;6956	00 	. 
	nop			;6957	00 	. 
	nop			;6958	00 	. 
	nop			;6959	00 	. 
	nop			;695a	00 	. 
	nop			;695b	00 	. 
	nop			;695c	00 	. 
	nop			;695d	00 	. 
	nop			;695e	00 	. 
	nop			;695f	00 	. 
	nop			;6960	00 	. 
	nop			;6961	00 	. 
	nop			;6962	00 	. 
	nop			;6963	00 	. 
	nop			;6964	00 	. 
	nop			;6965	00 	. 
	nop			;6966	00 	. 
	nop			;6967	00 	. 
	nop			;6968	00 	. 
	nop			;6969	00 	. 
	nop			;696a	00 	. 
	nop			;696b	00 	. 
	nop			;696c	00 	. 
	nop			;696d	00 	. 
	nop			;696e	00 	. 
	nop			;696f	00 	. 
	nop			;6970	00 	. 
	nop			;6971	00 	. 
	nop			;6972	00 	. 
	nop			;6973	00 	. 
	nop			;6974	00 	. 
	nop			;6975	00 	. 
	nop			;6976	00 	. 
	nop			;6977	00 	. 
	nop			;6978	00 	. 
	nop			;6979	00 	. 
	nop			;697a	00 	. 
	nop			;697b	00 	. 
	nop			;697c	00 	. 
	nop			;697d	00 	. 
	nop			;697e	00 	. 
	nop			;697f	00 	. 
	nop			;6980	00 	. 
	nop			;6981	00 	. 
	nop			;6982	00 	. 
	nop			;6983	00 	. 
	nop			;6984	00 	. 
	nop			;6985	00 	. 
	nop			;6986	00 	. 
	nop			;6987	00 	. 
	nop			;6988	00 	. 
	nop			;6989	00 	. 
	nop			;698a	00 	. 
	nop			;698b	00 	. 
	nop			;698c	00 	. 
	nop			;698d	00 	. 
	nop			;698e	00 	. 
	nop			;698f	00 	. 
	nop			;6990	00 	. 
	nop			;6991	00 	. 
	nop			;6992	00 	. 
	nop			;6993	00 	. 
	nop			;6994	00 	. 
	nop			;6995	00 	. 
	nop			;6996	00 	. 
	nop			;6997	00 	. 
	nop			;6998	00 	. 
	nop			;6999	00 	. 
	nop			;699a	00 	. 
	nop			;699b	00 	. 
	nop			;699c	00 	. 
	nop			;699d	00 	. 
	nop			;699e	00 	. 
	nop			;699f	00 	. 
	nop			;69a0	00 	. 
	nop			;69a1	00 	. 
	nop			;69a2	00 	. 
	nop			;69a3	00 	. 
	nop			;69a4	00 	. 
	nop			;69a5	00 	. 
	nop			;69a6	00 	. 
	nop			;69a7	00 	. 
	nop			;69a8	00 	. 
	nop			;69a9	00 	. 
	nop			;69aa	00 	. 
	nop			;69ab	00 	. 
	nop			;69ac	00 	. 
	nop			;69ad	00 	. 
	nop			;69ae	00 	. 
	nop			;69af	00 	. 
	nop			;69b0	00 	. 
	nop			;69b1	00 	. 
	nop			;69b2	00 	. 
	nop			;69b3	00 	. 
	nop			;69b4	00 	. 
	nop			;69b5	00 	. 
	nop			;69b6	00 	. 
	nop			;69b7	00 	. 
	nop			;69b8	00 	. 
	nop			;69b9	00 	. 
	nop			;69ba	00 	. 
	nop			;69bb	00 	. 
	nop			;69bc	00 	. 
	nop			;69bd	00 	. 
	nop			;69be	00 	. 
	nop			;69bf	00 	. 
	nop			;69c0	00 	. 
	nop			;69c1	00 	. 
	nop			;69c2	00 	. 
	nop			;69c3	00 	. 
	nop			;69c4	00 	. 
	nop			;69c5	00 	. 
	nop			;69c6	00 	. 
	nop			;69c7	00 	. 
	nop			;69c8	00 	. 
	nop			;69c9	00 	. 
	nop			;69ca	00 	. 
	nop			;69cb	00 	. 
	nop			;69cc	00 	. 
	nop			;69cd	00 	. 
	nop			;69ce	00 	. 
	nop			;69cf	00 	. 
	nop			;69d0	00 	. 
	nop			;69d1	00 	. 
	nop			;69d2	00 	. 
	nop			;69d3	00 	. 
	nop			;69d4	00 	. 
	nop			;69d5	00 	. 
	nop			;69d6	00 	. 
	nop			;69d7	00 	. 
	nop			;69d8	00 	. 
	nop			;69d9	00 	. 
	nop			;69da	00 	. 
	nop			;69db	00 	. 
	nop			;69dc	00 	. 
	nop			;69dd	00 	. 
	nop			;69de	00 	. 
	nop			;69df	00 	. 
	nop			;69e0	00 	. 
	nop			;69e1	00 	. 
	nop			;69e2	00 	. 
	nop			;69e3	00 	. 
	nop			;69e4	00 	. 
	nop			;69e5	00 	. 
	nop			;69e6	00 	. 
	nop			;69e7	00 	. 
	nop			;69e8	00 	. 
	nop			;69e9	00 	. 
	nop			;69ea	00 	. 
	nop			;69eb	00 	. 
	nop			;69ec	00 	. 
	nop			;69ed	00 	. 
	nop			;69ee	00 	. 
	nop			;69ef	00 	. 
	nop			;69f0	00 	. 
	nop			;69f1	00 	. 
	nop			;69f2	00 	. 
	nop			;69f3	00 	. 
	nop			;69f4	00 	. 
	nop			;69f5	00 	. 
	nop			;69f6	00 	. 
	nop			;69f7	00 	. 
	nop			;69f8	00 	. 
	nop			;69f9	00 	. 
	nop			;69fa	00 	. 
	nop			;69fb	00 	. 
	nop			;69fc	00 	. 
	nop			;69fd	00 	. 
	nop			;69fe	00 	. 
	nop			;69ff	00 	. 
	nop			;6a00	00 	. 
	nop			;6a01	00 	. 
	nop			;6a02	00 	. 
	nop			;6a03	00 	. 
	nop			;6a04	00 	. 
	nop			;6a05	00 	. 
	nop			;6a06	00 	. 
	nop			;6a07	00 	. 
	nop			;6a08	00 	. 
	nop			;6a09	00 	. 
	nop			;6a0a	00 	. 
	nop			;6a0b	00 	. 
	nop			;6a0c	00 	. 
	nop			;6a0d	00 	. 
	nop			;6a0e	00 	. 
	nop			;6a0f	00 	. 
	nop			;6a10	00 	. 
	nop			;6a11	00 	. 
	nop			;6a12	00 	. 
	nop			;6a13	00 	. 
	nop			;6a14	00 	. 
	nop			;6a15	00 	. 
	nop			;6a16	00 	. 
	nop			;6a17	00 	. 
	nop			;6a18	00 	. 
	nop			;6a19	00 	. 
	nop			;6a1a	00 	. 
	nop			;6a1b	00 	. 
	nop			;6a1c	00 	. 
	nop			;6a1d	00 	. 
	nop			;6a1e	00 	. 
	nop			;6a1f	00 	. 
	nop			;6a20	00 	. 
	nop			;6a21	00 	. 
	nop			;6a22	00 	. 
	nop			;6a23	00 	. 
	nop			;6a24	00 	. 
	nop			;6a25	00 	. 
	nop			;6a26	00 	. 
	nop			;6a27	00 	. 
	nop			;6a28	00 	. 
	nop			;6a29	00 	. 
	nop			;6a2a	00 	. 
	nop			;6a2b	00 	. 
	nop			;6a2c	00 	. 
	nop			;6a2d	00 	. 
	nop			;6a2e	00 	. 
	nop			;6a2f	00 	. 
	nop			;6a30	00 	. 
	nop			;6a31	00 	. 
	nop			;6a32	00 	. 
	nop			;6a33	00 	. 
	nop			;6a34	00 	. 
	nop			;6a35	00 	. 
	nop			;6a36	00 	. 
	nop			;6a37	00 	. 
	nop			;6a38	00 	. 
	nop			;6a39	00 	. 
	nop			;6a3a	00 	. 
	nop			;6a3b	00 	. 
	nop			;6a3c	00 	. 
	nop			;6a3d	00 	. 
	nop			;6a3e	00 	. 
	nop			;6a3f	00 	. 
	nop			;6a40	00 	. 
	nop			;6a41	00 	. 
	nop			;6a42	00 	. 
	nop			;6a43	00 	. 
	nop			;6a44	00 	. 
	nop			;6a45	00 	. 
	nop			;6a46	00 	. 
	nop			;6a47	00 	. 
	nop			;6a48	00 	. 
	nop			;6a49	00 	. 
	nop			;6a4a	00 	. 
	nop			;6a4b	00 	. 
	nop			;6a4c	00 	. 
	nop			;6a4d	00 	. 
	nop			;6a4e	00 	. 
	nop			;6a4f	00 	. 
	nop			;6a50	00 	. 
	nop			;6a51	00 	. 
	nop			;6a52	00 	. 
	nop			;6a53	00 	. 
	nop			;6a54	00 	. 
	nop			;6a55	00 	. 
	nop			;6a56	00 	. 
	nop			;6a57	00 	. 
	nop			;6a58	00 	. 
	nop			;6a59	00 	. 
	nop			;6a5a	00 	. 
	nop			;6a5b	00 	. 
	nop			;6a5c	00 	. 
	nop			;6a5d	00 	. 
	nop			;6a5e	00 	. 
	nop			;6a5f	00 	. 
	nop			;6a60	00 	. 
	nop			;6a61	00 	. 
	nop			;6a62	00 	. 
	nop			;6a63	00 	. 
	nop			;6a64	00 	. 
	nop			;6a65	00 	. 
	nop			;6a66	00 	. 
	nop			;6a67	00 	. 
	nop			;6a68	00 	. 
	nop			;6a69	00 	. 
	nop			;6a6a	00 	. 
	nop			;6a6b	00 	. 
	nop			;6a6c	00 	. 
	nop			;6a6d	00 	. 
	nop			;6a6e	00 	. 
	nop			;6a6f	00 	. 
	nop			;6a70	00 	. 
	nop			;6a71	00 	. 
	nop			;6a72	00 	. 
	nop			;6a73	00 	. 
	nop			;6a74	00 	. 
	nop			;6a75	00 	. 
	nop			;6a76	00 	. 
	nop			;6a77	00 	. 
	nop			;6a78	00 	. 
	nop			;6a79	00 	. 
	nop			;6a7a	00 	. 
	nop			;6a7b	00 	. 
	nop			;6a7c	00 	. 
	nop			;6a7d	00 	. 
	nop			;6a7e	00 	. 
	nop			;6a7f	00 	. 
	nop			;6a80	00 	. 
	nop			;6a81	00 	. 
	nop			;6a82	00 	. 
	nop			;6a83	00 	. 
	nop			;6a84	00 	. 
	nop			;6a85	00 	. 
	nop			;6a86	00 	. 
	nop			;6a87	00 	. 
	nop			;6a88	00 	. 
	nop			;6a89	00 	. 
	nop			;6a8a	00 	. 
	nop			;6a8b	00 	. 
	nop			;6a8c	00 	. 
	nop			;6a8d	00 	. 
	nop			;6a8e	00 	. 
	nop			;6a8f	00 	. 
	nop			;6a90	00 	. 
	nop			;6a91	00 	. 
	nop			;6a92	00 	. 
	nop			;6a93	00 	. 
	nop			;6a94	00 	. 
	nop			;6a95	00 	. 
	nop			;6a96	00 	. 
	nop			;6a97	00 	. 
	nop			;6a98	00 	. 
	nop			;6a99	00 	. 
	nop			;6a9a	00 	. 
	nop			;6a9b	00 	. 
	nop			;6a9c	00 	. 
	nop			;6a9d	00 	. 
	nop			;6a9e	00 	. 
	nop			;6a9f	00 	. 
	nop			;6aa0	00 	. 
	nop			;6aa1	00 	. 
	nop			;6aa2	00 	. 
	nop			;6aa3	00 	. 
	nop			;6aa4	00 	. 
	nop			;6aa5	00 	. 
	nop			;6aa6	00 	. 
	nop			;6aa7	00 	. 
	nop			;6aa8	00 	. 
	nop			;6aa9	00 	. 
	nop			;6aaa	00 	. 
	nop			;6aab	00 	. 
	nop			;6aac	00 	. 
	nop			;6aad	00 	. 
	nop			;6aae	00 	. 
	nop			;6aaf	00 	. 
	nop			;6ab0	00 	. 
	nop			;6ab1	00 	. 
	nop			;6ab2	00 	. 
	nop			;6ab3	00 	. 
	nop			;6ab4	00 	. 
	nop			;6ab5	00 	. 
	nop			;6ab6	00 	. 
	nop			;6ab7	00 	. 
	nop			;6ab8	00 	. 
	nop			;6ab9	00 	. 
	nop			;6aba	00 	. 
	nop			;6abb	00 	. 
	nop			;6abc	00 	. 
	nop			;6abd	00 	. 
	nop			;6abe	00 	. 
	nop			;6abf	00 	. 
	nop			;6ac0	00 	. 
	nop			;6ac1	00 	. 
	nop			;6ac2	00 	. 
	nop			;6ac3	00 	. 
	nop			;6ac4	00 	. 
	nop			;6ac5	00 	. 
	nop			;6ac6	00 	. 
	nop			;6ac7	00 	. 
	nop			;6ac8	00 	. 
	nop			;6ac9	00 	. 
	nop			;6aca	00 	. 
	nop			;6acb	00 	. 
	nop			;6acc	00 	. 
	nop			;6acd	00 	. 
	nop			;6ace	00 	. 
	nop			;6acf	00 	. 
	nop			;6ad0	00 	. 
	nop			;6ad1	00 	. 
	nop			;6ad2	00 	. 
	nop			;6ad3	00 	. 
	nop			;6ad4	00 	. 
	nop			;6ad5	00 	. 
	nop			;6ad6	00 	. 
	nop			;6ad7	00 	. 
	nop			;6ad8	00 	. 
	nop			;6ad9	00 	. 
	nop			;6ada	00 	. 
	nop			;6adb	00 	. 
	nop			;6adc	00 	. 
	nop			;6add	00 	. 
	nop			;6ade	00 	. 
	nop			;6adf	00 	. 
	nop			;6ae0	00 	. 
	nop			;6ae1	00 	. 
	nop			;6ae2	00 	. 
	nop			;6ae3	00 	. 
	nop			;6ae4	00 	. 
	nop			;6ae5	00 	. 
	nop			;6ae6	00 	. 
	nop			;6ae7	00 	. 
	nop			;6ae8	00 	. 
	nop			;6ae9	00 	. 
	nop			;6aea	00 	. 
	nop			;6aeb	00 	. 
	nop			;6aec	00 	. 
	nop			;6aed	00 	. 
	nop			;6aee	00 	. 
	nop			;6aef	00 	. 
	nop			;6af0	00 	. 
	nop			;6af1	00 	. 
	nop			;6af2	00 	. 
	nop			;6af3	00 	. 
	nop			;6af4	00 	. 
	nop			;6af5	00 	. 
	nop			;6af6	00 	. 
	nop			;6af7	00 	. 
	nop			;6af8	00 	. 
	nop			;6af9	00 	. 
	nop			;6afa	00 	. 
	nop			;6afb	00 	. 
	nop			;6afc	00 	. 
	nop			;6afd	00 	. 
	nop			;6afe	00 	. 
	nop			;6aff	00 	. 
	nop			;6b00	00 	. 
	nop			;6b01	00 	. 
	nop			;6b02	00 	. 
	nop			;6b03	00 	. 
	nop			;6b04	00 	. 
	nop			;6b05	00 	. 
	nop			;6b06	00 	. 
	nop			;6b07	00 	. 
	nop			;6b08	00 	. 
	nop			;6b09	00 	. 
	nop			;6b0a	00 	. 
	nop			;6b0b	00 	. 
	nop			;6b0c	00 	. 
	nop			;6b0d	00 	. 
	nop			;6b0e	00 	. 
	nop			;6b0f	00 	. 
	nop			;6b10	00 	. 
	nop			;6b11	00 	. 
	nop			;6b12	00 	. 
	nop			;6b13	00 	. 
	nop			;6b14	00 	. 
	nop			;6b15	00 	. 
	nop			;6b16	00 	. 
	nop			;6b17	00 	. 
	nop			;6b18	00 	. 
	nop			;6b19	00 	. 
	nop			;6b1a	00 	. 
	nop			;6b1b	00 	. 
	nop			;6b1c	00 	. 
	nop			;6b1d	00 	. 
	nop			;6b1e	00 	. 
	nop			;6b1f	00 	. 
	nop			;6b20	00 	. 
	nop			;6b21	00 	. 
	nop			;6b22	00 	. 
	nop			;6b23	00 	. 
	nop			;6b24	00 	. 
	nop			;6b25	00 	. 
	nop			;6b26	00 	. 
	nop			;6b27	00 	. 
	nop			;6b28	00 	. 
	nop			;6b29	00 	. 
	nop			;6b2a	00 	. 
	nop			;6b2b	00 	. 
	nop			;6b2c	00 	. 
	nop			;6b2d	00 	. 
	nop			;6b2e	00 	. 
	nop			;6b2f	00 	. 
	nop			;6b30	00 	. 
	nop			;6b31	00 	. 
	nop			;6b32	00 	. 
	nop			;6b33	00 	. 
	nop			;6b34	00 	. 
	nop			;6b35	00 	. 
	nop			;6b36	00 	. 
	nop			;6b37	00 	. 
	nop			;6b38	00 	. 
	nop			;6b39	00 	. 
	nop			;6b3a	00 	. 
	nop			;6b3b	00 	. 
	nop			;6b3c	00 	. 
	nop			;6b3d	00 	. 
	nop			;6b3e	00 	. 
	nop			;6b3f	00 	. 
	nop			;6b40	00 	. 
	nop			;6b41	00 	. 
	nop			;6b42	00 	. 
	nop			;6b43	00 	. 
	nop			;6b44	00 	. 
	nop			;6b45	00 	. 
	nop			;6b46	00 	. 
	nop			;6b47	00 	. 
	nop			;6b48	00 	. 
	nop			;6b49	00 	. 
	nop			;6b4a	00 	. 
	nop			;6b4b	00 	. 
	nop			;6b4c	00 	. 
	nop			;6b4d	00 	. 
	nop			;6b4e	00 	. 
	nop			;6b4f	00 	. 
	nop			;6b50	00 	. 
	nop			;6b51	00 	. 
	nop			;6b52	00 	. 
	nop			;6b53	00 	. 
	nop			;6b54	00 	. 
	nop			;6b55	00 	. 
	nop			;6b56	00 	. 
	nop			;6b57	00 	. 
	nop			;6b58	00 	. 
	nop			;6b59	00 	. 
	nop			;6b5a	00 	. 
	nop			;6b5b	00 	. 
	nop			;6b5c	00 	. 
	nop			;6b5d	00 	. 
	nop			;6b5e	00 	. 
	nop			;6b5f	00 	. 
	nop			;6b60	00 	. 
	nop			;6b61	00 	. 
	nop			;6b62	00 	. 
	nop			;6b63	00 	. 
	nop			;6b64	00 	. 
	nop			;6b65	00 	. 
	nop			;6b66	00 	. 
	nop			;6b67	00 	. 
	nop			;6b68	00 	. 
	nop			;6b69	00 	. 
	nop			;6b6a	00 	. 
	nop			;6b6b	00 	. 
	nop			;6b6c	00 	. 
	nop			;6b6d	00 	. 
	nop			;6b6e	00 	. 
	nop			;6b6f	00 	. 
	nop			;6b70	00 	. 
	nop			;6b71	00 	. 
	nop			;6b72	00 	. 
	nop			;6b73	00 	. 
	nop			;6b74	00 	. 
	nop			;6b75	00 	. 
	nop			;6b76	00 	. 
	nop			;6b77	00 	. 
	nop			;6b78	00 	. 
	nop			;6b79	00 	. 
	nop			;6b7a	00 	. 
	nop			;6b7b	00 	. 
	nop			;6b7c	00 	. 
	nop			;6b7d	00 	. 
	nop			;6b7e	00 	. 
	nop			;6b7f	00 	. 
	nop			;6b80	00 	. 
	nop			;6b81	00 	. 
	nop			;6b82	00 	. 
	nop			;6b83	00 	. 
	nop			;6b84	00 	. 
	nop			;6b85	00 	. 
	nop			;6b86	00 	. 
	nop			;6b87	00 	. 
	nop			;6b88	00 	. 
	nop			;6b89	00 	. 
	nop			;6b8a	00 	. 
	nop			;6b8b	00 	. 
	nop			;6b8c	00 	. 
	nop			;6b8d	00 	. 
	nop			;6b8e	00 	. 
	nop			;6b8f	00 	. 
	nop			;6b90	00 	. 
	nop			;6b91	00 	. 
	nop			;6b92	00 	. 
	nop			;6b93	00 	. 
	nop			;6b94	00 	. 
	nop			;6b95	00 	. 
	nop			;6b96	00 	. 
	nop			;6b97	00 	. 
	nop			;6b98	00 	. 
	nop			;6b99	00 	. 
	nop			;6b9a	00 	. 
	nop			;6b9b	00 	. 
	nop			;6b9c	00 	. 
	nop			;6b9d	00 	. 
	nop			;6b9e	00 	. 
	nop			;6b9f	00 	. 
	nop			;6ba0	00 	. 
	nop			;6ba1	00 	. 
	nop			;6ba2	00 	. 
	nop			;6ba3	00 	. 
	nop			;6ba4	00 	. 
	nop			;6ba5	00 	. 
	nop			;6ba6	00 	. 
	nop			;6ba7	00 	. 
	nop			;6ba8	00 	. 
	nop			;6ba9	00 	. 
	nop			;6baa	00 	. 
	nop			;6bab	00 	. 
	nop			;6bac	00 	. 
	nop			;6bad	00 	. 
	nop			;6bae	00 	. 
	nop			;6baf	00 	. 
	nop			;6bb0	00 	. 
	nop			;6bb1	00 	. 
	nop			;6bb2	00 	. 
	nop			;6bb3	00 	. 
	nop			;6bb4	00 	. 
	nop			;6bb5	00 	. 
	nop			;6bb6	00 	. 
	nop			;6bb7	00 	. 
	nop			;6bb8	00 	. 
	nop			;6bb9	00 	. 
	nop			;6bba	00 	. 
	nop			;6bbb	00 	. 
	nop			;6bbc	00 	. 
	nop			;6bbd	00 	. 
	nop			;6bbe	00 	. 
	nop			;6bbf	00 	. 
	nop			;6bc0	00 	. 
	nop			;6bc1	00 	. 
	nop			;6bc2	00 	. 
	nop			;6bc3	00 	. 
	nop			;6bc4	00 	. 
	nop			;6bc5	00 	. 
	nop			;6bc6	00 	. 
	nop			;6bc7	00 	. 
	nop			;6bc8	00 	. 
	nop			;6bc9	00 	. 
	nop			;6bca	00 	. 
	nop			;6bcb	00 	. 
	nop			;6bcc	00 	. 
	nop			;6bcd	00 	. 
	nop			;6bce	00 	. 
	nop			;6bcf	00 	. 
	nop			;6bd0	00 	. 
	nop			;6bd1	00 	. 
	nop			;6bd2	00 	. 
	nop			;6bd3	00 	. 
	nop			;6bd4	00 	. 
	nop			;6bd5	00 	. 
	nop			;6bd6	00 	. 
	nop			;6bd7	00 	. 
	nop			;6bd8	00 	. 
	nop			;6bd9	00 	. 
	nop			;6bda	00 	. 
	nop			;6bdb	00 	. 
	nop			;6bdc	00 	. 
	nop			;6bdd	00 	. 
	nop			;6bde	00 	. 
	nop			;6bdf	00 	. 
	nop			;6be0	00 	. 
	nop			;6be1	00 	. 
	nop			;6be2	00 	. 
	nop			;6be3	00 	. 
	nop			;6be4	00 	. 
	nop			;6be5	00 	. 
	nop			;6be6	00 	. 
	nop			;6be7	00 	. 
	nop			;6be8	00 	. 
	nop			;6be9	00 	. 
	nop			;6bea	00 	. 
	nop			;6beb	00 	. 
	nop			;6bec	00 	. 
	nop			;6bed	00 	. 
	nop			;6bee	00 	. 
	nop			;6bef	00 	. 
	nop			;6bf0	00 	. 
	nop			;6bf1	00 	. 
	nop			;6bf2	00 	. 
	nop			;6bf3	00 	. 
	nop			;6bf4	00 	. 
	nop			;6bf5	00 	. 
	nop			;6bf6	00 	. 
	nop			;6bf7	00 	. 
	nop			;6bf8	00 	. 
	nop			;6bf9	00 	. 
	nop			;6bfa	00 	. 
	nop			;6bfb	00 	. 
	nop			;6bfc	00 	. 
	nop			;6bfd	00 	. 
	nop			;6bfe	00 	. 
	nop			;6bff	00 	. 
	nop			;6c00	00 	. 
	nop			;6c01	00 	. 
	nop			;6c02	00 	. 
	nop			;6c03	00 	. 
	nop			;6c04	00 	. 
	nop			;6c05	00 	. 
	nop			;6c06	00 	. 
	nop			;6c07	00 	. 
	nop			;6c08	00 	. 
	nop			;6c09	00 	. 
	nop			;6c0a	00 	. 
	nop			;6c0b	00 	. 
	nop			;6c0c	00 	. 
	nop			;6c0d	00 	. 
	nop			;6c0e	00 	. 
	nop			;6c0f	00 	. 
	nop			;6c10	00 	. 
	nop			;6c11	00 	. 
	nop			;6c12	00 	. 
	nop			;6c13	00 	. 
	nop			;6c14	00 	. 
	nop			;6c15	00 	. 
	nop			;6c16	00 	. 
	nop			;6c17	00 	. 
	nop			;6c18	00 	. 
	nop			;6c19	00 	. 
	nop			;6c1a	00 	. 
	nop			;6c1b	00 	. 
	nop			;6c1c	00 	. 
	nop			;6c1d	00 	. 
	nop			;6c1e	00 	. 
	nop			;6c1f	00 	. 
	nop			;6c20	00 	. 
	nop			;6c21	00 	. 
	nop			;6c22	00 	. 
	nop			;6c23	00 	. 
	nop			;6c24	00 	. 
	nop			;6c25	00 	. 
	nop			;6c26	00 	. 
	nop			;6c27	00 	. 
	nop			;6c28	00 	. 
	nop			;6c29	00 	. 
	nop			;6c2a	00 	. 
	nop			;6c2b	00 	. 
	nop			;6c2c	00 	. 
	nop			;6c2d	00 	. 
	nop			;6c2e	00 	. 
	nop			;6c2f	00 	. 
	nop			;6c30	00 	. 
	nop			;6c31	00 	. 
	nop			;6c32	00 	. 
	nop			;6c33	00 	. 
	nop			;6c34	00 	. 
	nop			;6c35	00 	. 
	nop			;6c36	00 	. 
	nop			;6c37	00 	. 
	nop			;6c38	00 	. 
	nop			;6c39	00 	. 
	nop			;6c3a	00 	. 
	nop			;6c3b	00 	. 
	nop			;6c3c	00 	. 
	nop			;6c3d	00 	. 
	nop			;6c3e	00 	. 
	nop			;6c3f	00 	. 
	nop			;6c40	00 	. 
	nop			;6c41	00 	. 
	nop			;6c42	00 	. 
	nop			;6c43	00 	. 
	nop			;6c44	00 	. 
	nop			;6c45	00 	. 
	nop			;6c46	00 	. 
	nop			;6c47	00 	. 
	nop			;6c48	00 	. 
	nop			;6c49	00 	. 
	nop			;6c4a	00 	. 
	nop			;6c4b	00 	. 
	nop			;6c4c	00 	. 
	nop			;6c4d	00 	. 
	nop			;6c4e	00 	. 
	nop			;6c4f	00 	. 
	nop			;6c50	00 	. 
	nop			;6c51	00 	. 
	nop			;6c52	00 	. 
	nop			;6c53	00 	. 
	nop			;6c54	00 	. 
	nop			;6c55	00 	. 
	nop			;6c56	00 	. 
	nop			;6c57	00 	. 
	nop			;6c58	00 	. 
	nop			;6c59	00 	. 
	nop			;6c5a	00 	. 
	nop			;6c5b	00 	. 
	nop			;6c5c	00 	. 
	nop			;6c5d	00 	. 
	nop			;6c5e	00 	. 
	nop			;6c5f	00 	. 
	nop			;6c60	00 	. 
	nop			;6c61	00 	. 
	nop			;6c62	00 	. 
	nop			;6c63	00 	. 
	nop			;6c64	00 	. 
	nop			;6c65	00 	. 
	nop			;6c66	00 	. 
	nop			;6c67	00 	. 
	nop			;6c68	00 	. 
	nop			;6c69	00 	. 
	nop			;6c6a	00 	. 
	nop			;6c6b	00 	. 
	nop			;6c6c	00 	. 
	nop			;6c6d	00 	. 
	nop			;6c6e	00 	. 
	nop			;6c6f	00 	. 
	nop			;6c70	00 	. 
	nop			;6c71	00 	. 
	nop			;6c72	00 	. 
	nop			;6c73	00 	. 
	nop			;6c74	00 	. 
	nop			;6c75	00 	. 
	nop			;6c76	00 	. 
	nop			;6c77	00 	. 
	nop			;6c78	00 	. 
	nop			;6c79	00 	. 
	nop			;6c7a	00 	. 
	nop			;6c7b	00 	. 
	nop			;6c7c	00 	. 
	nop			;6c7d	00 	. 
	nop			;6c7e	00 	. 
	nop			;6c7f	00 	. 
	nop			;6c80	00 	. 
	nop			;6c81	00 	. 
	nop			;6c82	00 	. 
	nop			;6c83	00 	. 
	nop			;6c84	00 	. 
	nop			;6c85	00 	. 
	nop			;6c86	00 	. 
	nop			;6c87	00 	. 
	nop			;6c88	00 	. 
	nop			;6c89	00 	. 
	nop			;6c8a	00 	. 
	nop			;6c8b	00 	. 
	nop			;6c8c	00 	. 
	nop			;6c8d	00 	. 
	nop			;6c8e	00 	. 
	nop			;6c8f	00 	. 
	nop			;6c90	00 	. 
	nop			;6c91	00 	. 
	nop			;6c92	00 	. 
	nop			;6c93	00 	. 
	nop			;6c94	00 	. 
	nop			;6c95	00 	. 
	nop			;6c96	00 	. 
	nop			;6c97	00 	. 
	nop			;6c98	00 	. 
	nop			;6c99	00 	. 
	nop			;6c9a	00 	. 
	nop			;6c9b	00 	. 
	nop			;6c9c	00 	. 
	nop			;6c9d	00 	. 
	nop			;6c9e	00 	. 
	nop			;6c9f	00 	. 
	nop			;6ca0	00 	. 
	nop			;6ca1	00 	. 
	nop			;6ca2	00 	. 
	nop			;6ca3	00 	. 
	nop			;6ca4	00 	. 
	nop			;6ca5	00 	. 
	nop			;6ca6	00 	. 
	nop			;6ca7	00 	. 
	nop			;6ca8	00 	. 
	nop			;6ca9	00 	. 
	nop			;6caa	00 	. 
	nop			;6cab	00 	. 
	nop			;6cac	00 	. 
	nop			;6cad	00 	. 
	nop			;6cae	00 	. 
	nop			;6caf	00 	. 
	nop			;6cb0	00 	. 
	nop			;6cb1	00 	. 
	nop			;6cb2	00 	. 
	nop			;6cb3	00 	. 
	nop			;6cb4	00 	. 
	nop			;6cb5	00 	. 
	nop			;6cb6	00 	. 
	nop			;6cb7	00 	. 
	nop			;6cb8	00 	. 
	nop			;6cb9	00 	. 
	nop			;6cba	00 	. 
	nop			;6cbb	00 	. 
	nop			;6cbc	00 	. 
	nop			;6cbd	00 	. 
	nop			;6cbe	00 	. 
	nop			;6cbf	00 	. 
	nop			;6cc0	00 	. 
	nop			;6cc1	00 	. 
	nop			;6cc2	00 	. 
	nop			;6cc3	00 	. 
	nop			;6cc4	00 	. 
	nop			;6cc5	00 	. 
	nop			;6cc6	00 	. 
	nop			;6cc7	00 	. 
	nop			;6cc8	00 	. 
	nop			;6cc9	00 	. 
	nop			;6cca	00 	. 
	nop			;6ccb	00 	. 
	nop			;6ccc	00 	. 
	nop			;6ccd	00 	. 
	nop			;6cce	00 	. 
	nop			;6ccf	00 	. 
	nop			;6cd0	00 	. 
	nop			;6cd1	00 	. 
	nop			;6cd2	00 	. 
	nop			;6cd3	00 	. 
	nop			;6cd4	00 	. 
	nop			;6cd5	00 	. 
	nop			;6cd6	00 	. 
	nop			;6cd7	00 	. 
	nop			;6cd8	00 	. 
	nop			;6cd9	00 	. 
	nop			;6cda	00 	. 
	nop			;6cdb	00 	. 
	nop			;6cdc	00 	. 
	nop			;6cdd	00 	. 
	nop			;6cde	00 	. 
	nop			;6cdf	00 	. 
	nop			;6ce0	00 	. 
	nop			;6ce1	00 	. 
	nop			;6ce2	00 	. 
	nop			;6ce3	00 	. 
	nop			;6ce4	00 	. 
	nop			;6ce5	00 	. 
	nop			;6ce6	00 	. 
	nop			;6ce7	00 	. 
	nop			;6ce8	00 	. 
	nop			;6ce9	00 	. 
	nop			;6cea	00 	. 
	nop			;6ceb	00 	. 
	nop			;6cec	00 	. 
	nop			;6ced	00 	. 
	nop			;6cee	00 	. 
	nop			;6cef	00 	. 
	nop			;6cf0	00 	. 
	nop			;6cf1	00 	. 
	nop			;6cf2	00 	. 
	nop			;6cf3	00 	. 
	nop			;6cf4	00 	. 
	nop			;6cf5	00 	. 
	nop			;6cf6	00 	. 
	nop			;6cf7	00 	. 
	nop			;6cf8	00 	. 
	nop			;6cf9	00 	. 
	nop			;6cfa	00 	. 
	nop			;6cfb	00 	. 
	nop			;6cfc	00 	. 
	nop			;6cfd	00 	. 
	nop			;6cfe	00 	. 
	nop			;6cff	00 	. 
	nop			;6d00	00 	. 
	nop			;6d01	00 	. 
	nop			;6d02	00 	. 
	nop			;6d03	00 	. 
	nop			;6d04	00 	. 
	nop			;6d05	00 	. 
	nop			;6d06	00 	. 
	nop			;6d07	00 	. 
	nop			;6d08	00 	. 
	nop			;6d09	00 	. 
	nop			;6d0a	00 	. 
	nop			;6d0b	00 	. 
	nop			;6d0c	00 	. 
	nop			;6d0d	00 	. 
	nop			;6d0e	00 	. 
	nop			;6d0f	00 	. 
	nop			;6d10	00 	. 
	nop			;6d11	00 	. 
	nop			;6d12	00 	. 
	nop			;6d13	00 	. 
	nop			;6d14	00 	. 
	nop			;6d15	00 	. 
	nop			;6d16	00 	. 
	nop			;6d17	00 	. 
	nop			;6d18	00 	. 
	nop			;6d19	00 	. 
	nop			;6d1a	00 	. 
	nop			;6d1b	00 	. 
	nop			;6d1c	00 	. 
	nop			;6d1d	00 	. 
	nop			;6d1e	00 	. 
	nop			;6d1f	00 	. 
	nop			;6d20	00 	. 
	nop			;6d21	00 	. 
	nop			;6d22	00 	. 
	nop			;6d23	00 	. 
	nop			;6d24	00 	. 
	nop			;6d25	00 	. 
	nop			;6d26	00 	. 
	nop			;6d27	00 	. 
	nop			;6d28	00 	. 
	nop			;6d29	00 	. 
	nop			;6d2a	00 	. 
	nop			;6d2b	00 	. 
	nop			;6d2c	00 	. 
	nop			;6d2d	00 	. 
	nop			;6d2e	00 	. 
	nop			;6d2f	00 	. 
	nop			;6d30	00 	. 
	nop			;6d31	00 	. 
	nop			;6d32	00 	. 
	nop			;6d33	00 	. 
	nop			;6d34	00 	. 
	nop			;6d35	00 	. 
	nop			;6d36	00 	. 
	nop			;6d37	00 	. 
	nop			;6d38	00 	. 
	nop			;6d39	00 	. 
	nop			;6d3a	00 	. 
	nop			;6d3b	00 	. 
	nop			;6d3c	00 	. 
	nop			;6d3d	00 	. 
	nop			;6d3e	00 	. 
	nop			;6d3f	00 	. 
	nop			;6d40	00 	. 
	nop			;6d41	00 	. 
	nop			;6d42	00 	. 
	nop			;6d43	00 	. 
	nop			;6d44	00 	. 
	nop			;6d45	00 	. 
	nop			;6d46	00 	. 
	nop			;6d47	00 	. 
	nop			;6d48	00 	. 
	nop			;6d49	00 	. 
	nop			;6d4a	00 	. 
	nop			;6d4b	00 	. 
	nop			;6d4c	00 	. 
	nop			;6d4d	00 	. 
	nop			;6d4e	00 	. 
	nop			;6d4f	00 	. 
	nop			;6d50	00 	. 
	nop			;6d51	00 	. 
	nop			;6d52	00 	. 
	nop			;6d53	00 	. 
	nop			;6d54	00 	. 
	nop			;6d55	00 	. 
	nop			;6d56	00 	. 
	nop			;6d57	00 	. 
	nop			;6d58	00 	. 
	nop			;6d59	00 	. 
	nop			;6d5a	00 	. 
	nop			;6d5b	00 	. 
	nop			;6d5c	00 	. 
	nop			;6d5d	00 	. 
	nop			;6d5e	00 	. 
	nop			;6d5f	00 	. 
	nop			;6d60	00 	. 
	nop			;6d61	00 	. 
	nop			;6d62	00 	. 
	nop			;6d63	00 	. 
	nop			;6d64	00 	. 
	nop			;6d65	00 	. 
	nop			;6d66	00 	. 
	nop			;6d67	00 	. 
	nop			;6d68	00 	. 
	nop			;6d69	00 	. 
	nop			;6d6a	00 	. 
	nop			;6d6b	00 	. 
	nop			;6d6c	00 	. 
	nop			;6d6d	00 	. 
	nop			;6d6e	00 	. 
	nop			;6d6f	00 	. 
	nop			;6d70	00 	. 
	nop			;6d71	00 	. 
	nop			;6d72	00 	. 
	nop			;6d73	00 	. 
	nop			;6d74	00 	. 
	nop			;6d75	00 	. 
	nop			;6d76	00 	. 
	nop			;6d77	00 	. 
	nop			;6d78	00 	. 
	nop			;6d79	00 	. 
	nop			;6d7a	00 	. 
	nop			;6d7b	00 	. 
	nop			;6d7c	00 	. 
	nop			;6d7d	00 	. 
	nop			;6d7e	00 	. 
	nop			;6d7f	00 	. 
	nop			;6d80	00 	. 
	nop			;6d81	00 	. 
	nop			;6d82	00 	. 
	nop			;6d83	00 	. 
	nop			;6d84	00 	. 
	nop			;6d85	00 	. 
	nop			;6d86	00 	. 
	nop			;6d87	00 	. 
	nop			;6d88	00 	. 
	nop			;6d89	00 	. 
	nop			;6d8a	00 	. 
	nop			;6d8b	00 	. 
	nop			;6d8c	00 	. 
	nop			;6d8d	00 	. 
	nop			;6d8e	00 	. 
	nop			;6d8f	00 	. 
	nop			;6d90	00 	. 
	nop			;6d91	00 	. 
	nop			;6d92	00 	. 
	nop			;6d93	00 	. 
	nop			;6d94	00 	. 
	nop			;6d95	00 	. 
	nop			;6d96	00 	. 
	nop			;6d97	00 	. 
	nop			;6d98	00 	. 
	nop			;6d99	00 	. 
	nop			;6d9a	00 	. 
	nop			;6d9b	00 	. 
	nop			;6d9c	00 	. 
	nop			;6d9d	00 	. 
	nop			;6d9e	00 	. 
	nop			;6d9f	00 	. 
	nop			;6da0	00 	. 
	nop			;6da1	00 	. 
	nop			;6da2	00 	. 
	nop			;6da3	00 	. 
	nop			;6da4	00 	. 
	nop			;6da5	00 	. 
	nop			;6da6	00 	. 
	nop			;6da7	00 	. 
	nop			;6da8	00 	. 
	nop			;6da9	00 	. 
	nop			;6daa	00 	. 
	nop			;6dab	00 	. 
	nop			;6dac	00 	. 
	nop			;6dad	00 	. 
	nop			;6dae	00 	. 
	nop			;6daf	00 	. 
	nop			;6db0	00 	. 
	nop			;6db1	00 	. 
	nop			;6db2	00 	. 
	nop			;6db3	00 	. 
	nop			;6db4	00 	. 
	nop			;6db5	00 	. 
	nop			;6db6	00 	. 
	nop			;6db7	00 	. 
	nop			;6db8	00 	. 
	nop			;6db9	00 	. 
	nop			;6dba	00 	. 
	nop			;6dbb	00 	. 
	nop			;6dbc	00 	. 
	nop			;6dbd	00 	. 
	nop			;6dbe	00 	. 
	nop			;6dbf	00 	. 
	nop			;6dc0	00 	. 
	nop			;6dc1	00 	. 
	nop			;6dc2	00 	. 
	nop			;6dc3	00 	. 
	nop			;6dc4	00 	. 
	nop			;6dc5	00 	. 
	nop			;6dc6	00 	. 
	nop			;6dc7	00 	. 
	nop			;6dc8	00 	. 
	nop			;6dc9	00 	. 
	nop			;6dca	00 	. 
	nop			;6dcb	00 	. 
	nop			;6dcc	00 	. 
	nop			;6dcd	00 	. 
	nop			;6dce	00 	. 
	nop			;6dcf	00 	. 
	nop			;6dd0	00 	. 
	nop			;6dd1	00 	. 
	nop			;6dd2	00 	. 
	nop			;6dd3	00 	. 
	nop			;6dd4	00 	. 
	nop			;6dd5	00 	. 
	nop			;6dd6	00 	. 
	nop			;6dd7	00 	. 
	nop			;6dd8	00 	. 
	nop			;6dd9	00 	. 
	nop			;6dda	00 	. 
	nop			;6ddb	00 	. 
	nop			;6ddc	00 	. 
	nop			;6ddd	00 	. 
	nop			;6dde	00 	. 
	nop			;6ddf	00 	. 
	nop			;6de0	00 	. 
	nop			;6de1	00 	. 
	nop			;6de2	00 	. 
	nop			;6de3	00 	. 
	nop			;6de4	00 	. 
	nop			;6de5	00 	. 
	nop			;6de6	00 	. 
	nop			;6de7	00 	. 
	nop			;6de8	00 	. 
	nop			;6de9	00 	. 
	nop			;6dea	00 	. 
	nop			;6deb	00 	. 
	nop			;6dec	00 	. 
	nop			;6ded	00 	. 
	nop			;6dee	00 	. 
	nop			;6def	00 	. 
	nop			;6df0	00 	. 
	nop			;6df1	00 	. 
	nop			;6df2	00 	. 
	nop			;6df3	00 	. 
	nop			;6df4	00 	. 
	nop			;6df5	00 	. 
	nop			;6df6	00 	. 
	nop			;6df7	00 	. 
	nop			;6df8	00 	. 
	nop			;6df9	00 	. 
	nop			;6dfa	00 	. 
	nop			;6dfb	00 	. 
	nop			;6dfc	00 	. 
	nop			;6dfd	00 	. 
	nop			;6dfe	00 	. 
	nop			;6dff	00 	. 
	nop			;6e00	00 	. 
	nop			;6e01	00 	. 
	nop			;6e02	00 	. 
	nop			;6e03	00 	. 
	nop			;6e04	00 	. 
	nop			;6e05	00 	. 
	nop			;6e06	00 	. 
	nop			;6e07	00 	. 
	nop			;6e08	00 	. 
	nop			;6e09	00 	. 
	nop			;6e0a	00 	. 
	nop			;6e0b	00 	. 
	nop			;6e0c	00 	. 
	nop			;6e0d	00 	. 
	nop			;6e0e	00 	. 
	nop			;6e0f	00 	. 
	nop			;6e10	00 	. 
	nop			;6e11	00 	. 
	nop			;6e12	00 	. 
	nop			;6e13	00 	. 
	nop			;6e14	00 	. 
	nop			;6e15	00 	. 
	nop			;6e16	00 	. 
	nop			;6e17	00 	. 
	nop			;6e18	00 	. 
	nop			;6e19	00 	. 
	nop			;6e1a	00 	. 
	nop			;6e1b	00 	. 
	nop			;6e1c	00 	. 
	nop			;6e1d	00 	. 
	nop			;6e1e	00 	. 
	nop			;6e1f	00 	. 
	nop			;6e20	00 	. 
	nop			;6e21	00 	. 
	nop			;6e22	00 	. 
	nop			;6e23	00 	. 
	nop			;6e24	00 	. 
	nop			;6e25	00 	. 
	nop			;6e26	00 	. 
	nop			;6e27	00 	. 
	nop			;6e28	00 	. 
	nop			;6e29	00 	. 
	nop			;6e2a	00 	. 
	nop			;6e2b	00 	. 
	nop			;6e2c	00 	. 
	nop			;6e2d	00 	. 
	nop			;6e2e	00 	. 
	nop			;6e2f	00 	. 
	nop			;6e30	00 	. 
	nop			;6e31	00 	. 
	nop			;6e32	00 	. 
	nop			;6e33	00 	. 
	nop			;6e34	00 	. 
	nop			;6e35	00 	. 
	nop			;6e36	00 	. 
	nop			;6e37	00 	. 
	nop			;6e38	00 	. 
	nop			;6e39	00 	. 
	nop			;6e3a	00 	. 
	nop			;6e3b	00 	. 
	nop			;6e3c	00 	. 
	nop			;6e3d	00 	. 
	nop			;6e3e	00 	. 
	nop			;6e3f	00 	. 
	nop			;6e40	00 	. 
	nop			;6e41	00 	. 
	nop			;6e42	00 	. 
	nop			;6e43	00 	. 
	nop			;6e44	00 	. 
	nop			;6e45	00 	. 
	nop			;6e46	00 	. 
	nop			;6e47	00 	. 
	nop			;6e48	00 	. 
	nop			;6e49	00 	. 
	nop			;6e4a	00 	. 
	nop			;6e4b	00 	. 
	nop			;6e4c	00 	. 
	nop			;6e4d	00 	. 
	nop			;6e4e	00 	. 
	nop			;6e4f	00 	. 
	nop			;6e50	00 	. 
	nop			;6e51	00 	. 
	nop			;6e52	00 	. 
	nop			;6e53	00 	. 
	nop			;6e54	00 	. 
	nop			;6e55	00 	. 
	nop			;6e56	00 	. 
	nop			;6e57	00 	. 
	nop			;6e58	00 	. 
	nop			;6e59	00 	. 
	nop			;6e5a	00 	. 
	nop			;6e5b	00 	. 
	nop			;6e5c	00 	. 
	nop			;6e5d	00 	. 
	nop			;6e5e	00 	. 
	nop			;6e5f	00 	. 
	nop			;6e60	00 	. 
	nop			;6e61	00 	. 
	nop			;6e62	00 	. 
	nop			;6e63	00 	. 
	nop			;6e64	00 	. 
	nop			;6e65	00 	. 
	nop			;6e66	00 	. 
	nop			;6e67	00 	. 
	nop			;6e68	00 	. 
	nop			;6e69	00 	. 
	nop			;6e6a	00 	. 
	nop			;6e6b	00 	. 
	nop			;6e6c	00 	. 
	nop			;6e6d	00 	. 
	nop			;6e6e	00 	. 
	nop			;6e6f	00 	. 
	nop			;6e70	00 	. 
	nop			;6e71	00 	. 
	nop			;6e72	00 	. 
	nop			;6e73	00 	. 
	nop			;6e74	00 	. 
	nop			;6e75	00 	. 
	nop			;6e76	00 	. 
	nop			;6e77	00 	. 
	nop			;6e78	00 	. 
	nop			;6e79	00 	. 
	nop			;6e7a	00 	. 
	nop			;6e7b	00 	. 
	nop			;6e7c	00 	. 
	nop			;6e7d	00 	. 
	nop			;6e7e	00 	. 
	nop			;6e7f	00 	. 
	nop			;6e80	00 	. 
	nop			;6e81	00 	. 
	nop			;6e82	00 	. 
	nop			;6e83	00 	. 
	nop			;6e84	00 	. 
	nop			;6e85	00 	. 
	nop			;6e86	00 	. 
	nop			;6e87	00 	. 
	nop			;6e88	00 	. 
	nop			;6e89	00 	. 
	nop			;6e8a	00 	. 
	nop			;6e8b	00 	. 
	nop			;6e8c	00 	. 
	nop			;6e8d	00 	. 
	nop			;6e8e	00 	. 
	nop			;6e8f	00 	. 
	nop			;6e90	00 	. 
	nop			;6e91	00 	. 
	nop			;6e92	00 	. 
	nop			;6e93	00 	. 
	nop			;6e94	00 	. 
	nop			;6e95	00 	. 
	nop			;6e96	00 	. 
	nop			;6e97	00 	. 
	nop			;6e98	00 	. 
	nop			;6e99	00 	. 
	nop			;6e9a	00 	. 
	nop			;6e9b	00 	. 
	nop			;6e9c	00 	. 
	nop			;6e9d	00 	. 
	nop			;6e9e	00 	. 
	nop			;6e9f	00 	. 
	nop			;6ea0	00 	. 
	nop			;6ea1	00 	. 
	nop			;6ea2	00 	. 
	nop			;6ea3	00 	. 
	nop			;6ea4	00 	. 
	nop			;6ea5	00 	. 
	nop			;6ea6	00 	. 
	nop			;6ea7	00 	. 
	nop			;6ea8	00 	. 
	nop			;6ea9	00 	. 
	nop			;6eaa	00 	. 
	nop			;6eab	00 	. 
	nop			;6eac	00 	. 
	nop			;6ead	00 	. 
	nop			;6eae	00 	. 
	nop			;6eaf	00 	. 
	nop			;6eb0	00 	. 
	nop			;6eb1	00 	. 
	nop			;6eb2	00 	. 
	nop			;6eb3	00 	. 
	nop			;6eb4	00 	. 
	nop			;6eb5	00 	. 
	nop			;6eb6	00 	. 
	nop			;6eb7	00 	. 
	nop			;6eb8	00 	. 
	nop			;6eb9	00 	. 
	nop			;6eba	00 	. 
	nop			;6ebb	00 	. 
	nop			;6ebc	00 	. 
	nop			;6ebd	00 	. 
	nop			;6ebe	00 	. 
	nop			;6ebf	00 	. 
	nop			;6ec0	00 	. 
	nop			;6ec1	00 	. 
	nop			;6ec2	00 	. 
	nop			;6ec3	00 	. 
	nop			;6ec4	00 	. 
	nop			;6ec5	00 	. 
	nop			;6ec6	00 	. 
	nop			;6ec7	00 	. 
	nop			;6ec8	00 	. 
	nop			;6ec9	00 	. 
	nop			;6eca	00 	. 
	nop			;6ecb	00 	. 
	nop			;6ecc	00 	. 
	nop			;6ecd	00 	. 
	nop			;6ece	00 	. 
	nop			;6ecf	00 	. 
	nop			;6ed0	00 	. 
	nop			;6ed1	00 	. 
	nop			;6ed2	00 	. 
	nop			;6ed3	00 	. 
	nop			;6ed4	00 	. 
	nop			;6ed5	00 	. 
	nop			;6ed6	00 	. 
	nop			;6ed7	00 	. 
	nop			;6ed8	00 	. 
	nop			;6ed9	00 	. 
	nop			;6eda	00 	. 
	nop			;6edb	00 	. 
	nop			;6edc	00 	. 
	nop			;6edd	00 	. 
	nop			;6ede	00 	. 
	nop			;6edf	00 	. 
	nop			;6ee0	00 	. 
	nop			;6ee1	00 	. 
	nop			;6ee2	00 	. 
	nop			;6ee3	00 	. 
	nop			;6ee4	00 	. 
	nop			;6ee5	00 	. 
	nop			;6ee6	00 	. 
	nop			;6ee7	00 	. 
	nop			;6ee8	00 	. 
	nop			;6ee9	00 	. 
	nop			;6eea	00 	. 
	nop			;6eeb	00 	. 
	nop			;6eec	00 	. 
	nop			;6eed	00 	. 
	nop			;6eee	00 	. 
	nop			;6eef	00 	. 
	nop			;6ef0	00 	. 
	nop			;6ef1	00 	. 
	nop			;6ef2	00 	. 
	nop			;6ef3	00 	. 
	nop			;6ef4	00 	. 
	nop			;6ef5	00 	. 
	nop			;6ef6	00 	. 
	nop			;6ef7	00 	. 
	nop			;6ef8	00 	. 
	nop			;6ef9	00 	. 
	nop			;6efa	00 	. 
	nop			;6efb	00 	. 
	nop			;6efc	00 	. 
	nop			;6efd	00 	. 
	nop			;6efe	00 	. 
	nop			;6eff	00 	. 
	nop			;6f00	00 	. 
	nop			;6f01	00 	. 
	nop			;6f02	00 	. 
	nop			;6f03	00 	. 
	nop			;6f04	00 	. 
	nop			;6f05	00 	. 
	nop			;6f06	00 	. 
	nop			;6f07	00 	. 
	nop			;6f08	00 	. 
	nop			;6f09	00 	. 
	nop			;6f0a	00 	. 
	nop			;6f0b	00 	. 
	nop			;6f0c	00 	. 
	nop			;6f0d	00 	. 
	nop			;6f0e	00 	. 
	nop			;6f0f	00 	. 
	nop			;6f10	00 	. 
	nop			;6f11	00 	. 
	nop			;6f12	00 	. 
	nop			;6f13	00 	. 
	nop			;6f14	00 	. 
	nop			;6f15	00 	. 
	nop			;6f16	00 	. 
	nop			;6f17	00 	. 
	nop			;6f18	00 	. 
	nop			;6f19	00 	. 
	nop			;6f1a	00 	. 
	nop			;6f1b	00 	. 
	nop			;6f1c	00 	. 
	nop			;6f1d	00 	. 
	nop			;6f1e	00 	. 
	nop			;6f1f	00 	. 
	nop			;6f20	00 	. 
	nop			;6f21	00 	. 
	nop			;6f22	00 	. 
	nop			;6f23	00 	. 
	nop			;6f24	00 	. 
	nop			;6f25	00 	. 
	nop			;6f26	00 	. 
	nop			;6f27	00 	. 
	nop			;6f28	00 	. 
	nop			;6f29	00 	. 
	nop			;6f2a	00 	. 
	nop			;6f2b	00 	. 
	nop			;6f2c	00 	. 
	nop			;6f2d	00 	. 
	nop			;6f2e	00 	. 
	nop			;6f2f	00 	. 
	nop			;6f30	00 	. 
	nop			;6f31	00 	. 
	nop			;6f32	00 	. 
	nop			;6f33	00 	. 
	nop			;6f34	00 	. 
	nop			;6f35	00 	. 
	nop			;6f36	00 	. 
	nop			;6f37	00 	. 
	nop			;6f38	00 	. 
	nop			;6f39	00 	. 
	nop			;6f3a	00 	. 
	nop			;6f3b	00 	. 
	nop			;6f3c	00 	. 
	nop			;6f3d	00 	. 
	nop			;6f3e	00 	. 
	nop			;6f3f	00 	. 
	nop			;6f40	00 	. 
	nop			;6f41	00 	. 
	nop			;6f42	00 	. 
	nop			;6f43	00 	. 
	nop			;6f44	00 	. 
	nop			;6f45	00 	. 
	nop			;6f46	00 	. 
	nop			;6f47	00 	. 
	nop			;6f48	00 	. 
	nop			;6f49	00 	. 
	nop			;6f4a	00 	. 
	nop			;6f4b	00 	. 
	nop			;6f4c	00 	. 
	nop			;6f4d	00 	. 
	nop			;6f4e	00 	. 
	nop			;6f4f	00 	. 
	nop			;6f50	00 	. 
	nop			;6f51	00 	. 
	nop			;6f52	00 	. 
	nop			;6f53	00 	. 
	nop			;6f54	00 	. 
	nop			;6f55	00 	. 
	nop			;6f56	00 	. 
	nop			;6f57	00 	. 
	nop			;6f58	00 	. 
	nop			;6f59	00 	. 
	nop			;6f5a	00 	. 
	nop			;6f5b	00 	. 
	nop			;6f5c	00 	. 
	nop			;6f5d	00 	. 
	nop			;6f5e	00 	. 
	nop			;6f5f	00 	. 
	nop			;6f60	00 	. 
	nop			;6f61	00 	. 
	nop			;6f62	00 	. 
	nop			;6f63	00 	. 
	nop			;6f64	00 	. 
	nop			;6f65	00 	. 
	nop			;6f66	00 	. 
	nop			;6f67	00 	. 
	nop			;6f68	00 	. 
	nop			;6f69	00 	. 
	nop			;6f6a	00 	. 
	nop			;6f6b	00 	. 
	nop			;6f6c	00 	. 
	nop			;6f6d	00 	. 
	nop			;6f6e	00 	. 
	nop			;6f6f	00 	. 
	nop			;6f70	00 	. 
	nop			;6f71	00 	. 
	nop			;6f72	00 	. 
	nop			;6f73	00 	. 
	nop			;6f74	00 	. 
	nop			;6f75	00 	. 
	nop			;6f76	00 	. 
	nop			;6f77	00 	. 
	nop			;6f78	00 	. 
	nop			;6f79	00 	. 
	nop			;6f7a	00 	. 
	nop			;6f7b	00 	. 
	nop			;6f7c	00 	. 
	nop			;6f7d	00 	. 
	nop			;6f7e	00 	. 
	nop			;6f7f	00 	. 
	nop			;6f80	00 	. 
	nop			;6f81	00 	. 
	nop			;6f82	00 	. 
	nop			;6f83	00 	. 
	nop			;6f84	00 	. 
	nop			;6f85	00 	. 
	nop			;6f86	00 	. 
	nop			;6f87	00 	. 
	nop			;6f88	00 	. 
	nop			;6f89	00 	. 
	nop			;6f8a	00 	. 
	nop			;6f8b	00 	. 
	nop			;6f8c	00 	. 
	nop			;6f8d	00 	. 
	nop			;6f8e	00 	. 
	nop			;6f8f	00 	. 
	nop			;6f90	00 	. 
	nop			;6f91	00 	. 
	nop			;6f92	00 	. 
	nop			;6f93	00 	. 
	nop			;6f94	00 	. 
	nop			;6f95	00 	. 
	nop			;6f96	00 	. 
	nop			;6f97	00 	. 
	nop			;6f98	00 	. 
	nop			;6f99	00 	. 
	nop			;6f9a	00 	. 
	nop			;6f9b	00 	. 
	nop			;6f9c	00 	. 
	nop			;6f9d	00 	. 
	nop			;6f9e	00 	. 
	nop			;6f9f	00 	. 
	nop			;6fa0	00 	. 
	nop			;6fa1	00 	. 
	nop			;6fa2	00 	. 
	nop			;6fa3	00 	. 
	nop			;6fa4	00 	. 
	nop			;6fa5	00 	. 
	nop			;6fa6	00 	. 
	nop			;6fa7	00 	. 
	nop			;6fa8	00 	. 
	nop			;6fa9	00 	. 
	nop			;6faa	00 	. 
	nop			;6fab	00 	. 
	nop			;6fac	00 	. 
	nop			;6fad	00 	. 
	nop			;6fae	00 	. 
	nop			;6faf	00 	. 
	nop			;6fb0	00 	. 
	nop			;6fb1	00 	. 
	nop			;6fb2	00 	. 
	nop			;6fb3	00 	. 
	nop			;6fb4	00 	. 
	nop			;6fb5	00 	. 
	nop			;6fb6	00 	. 
	nop			;6fb7	00 	. 
	nop			;6fb8	00 	. 
	nop			;6fb9	00 	. 
	nop			;6fba	00 	. 
	nop			;6fbb	00 	. 
	nop			;6fbc	00 	. 
	nop			;6fbd	00 	. 
	nop			;6fbe	00 	. 
	nop			;6fbf	00 	. 
	nop			;6fc0	00 	. 
	nop			;6fc1	00 	. 
	nop			;6fc2	00 	. 
	nop			;6fc3	00 	. 
	nop			;6fc4	00 	. 
	nop			;6fc5	00 	. 
	nop			;6fc6	00 	. 
	nop			;6fc7	00 	. 
	nop			;6fc8	00 	. 
	nop			;6fc9	00 	. 
	nop			;6fca	00 	. 
	nop			;6fcb	00 	. 
	nop			;6fcc	00 	. 
	nop			;6fcd	00 	. 
	nop			;6fce	00 	. 
	nop			;6fcf	00 	. 
	nop			;6fd0	00 	. 
	nop			;6fd1	00 	. 
	nop			;6fd2	00 	. 
	nop			;6fd3	00 	. 
	nop			;6fd4	00 	. 
	nop			;6fd5	00 	. 
	nop			;6fd6	00 	. 
	nop			;6fd7	00 	. 
	nop			;6fd8	00 	. 
	nop			;6fd9	00 	. 
	nop			;6fda	00 	. 
	nop			;6fdb	00 	. 
	nop			;6fdc	00 	. 
	nop			;6fdd	00 	. 
	nop			;6fde	00 	. 
	nop			;6fdf	00 	. 
	nop			;6fe0	00 	. 
	nop			;6fe1	00 	. 
	nop			;6fe2	00 	. 
	nop			;6fe3	00 	. 
	nop			;6fe4	00 	. 
	nop			;6fe5	00 	. 
	nop			;6fe6	00 	. 
	nop			;6fe7	00 	. 
	nop			;6fe8	00 	. 
	nop			;6fe9	00 	. 
	nop			;6fea	00 	. 
	nop			;6feb	00 	. 
	nop			;6fec	00 	. 
	nop			;6fed	00 	. 
	nop			;6fee	00 	. 
	nop			;6fef	00 	. 
	nop			;6ff0	00 	. 
	nop			;6ff1	00 	. 
	nop			;6ff2	00 	. 
	nop			;6ff3	00 	. 
	nop			;6ff4	00 	. 
	nop			;6ff5	00 	. 
	nop			;6ff6	00 	. 
	nop			;6ff7	00 	. 
	nop			;6ff8	00 	. 
	nop			;6ff9	00 	. 
	nop			;6ffa	00 	. 
	nop			;6ffb	00 	. 
	nop			;6ffc	00 	. 
	nop			;6ffd	00 	. 
	nop			;6ffe	00 	. 
	nop			;6fff	00 	. 
	nop			;7000	00 	. 
	nop			;7001	00 	. 
	nop			;7002	00 	. 
	nop			;7003	00 	. 
	nop			;7004	00 	. 
	nop			;7005	00 	. 
	nop			;7006	00 	. 
	nop			;7007	00 	. 
	nop			;7008	00 	. 
	nop			;7009	00 	. 
	nop			;700a	00 	. 
	nop			;700b	00 	. 
	nop			;700c	00 	. 
	nop			;700d	00 	. 
	nop			;700e	00 	. 
	nop			;700f	00 	. 
	nop			;7010	00 	. 
	nop			;7011	00 	. 
	nop			;7012	00 	. 
	nop			;7013	00 	. 
	nop			;7014	00 	. 
	nop			;7015	00 	. 
	nop			;7016	00 	. 
	nop			;7017	00 	. 
	nop			;7018	00 	. 
	nop			;7019	00 	. 
	nop			;701a	00 	. 
	nop			;701b	00 	. 
	nop			;701c	00 	. 
	nop			;701d	00 	. 
	nop			;701e	00 	. 
	nop			;701f	00 	. 
	nop			;7020	00 	. 
	nop			;7021	00 	. 
	nop			;7022	00 	. 
	nop			;7023	00 	. 
	nop			;7024	00 	. 
	nop			;7025	00 	. 
	nop			;7026	00 	. 
	nop			;7027	00 	. 
	nop			;7028	00 	. 
	nop			;7029	00 	. 
	nop			;702a	00 	. 
	nop			;702b	00 	. 
	nop			;702c	00 	. 
	nop			;702d	00 	. 
	nop			;702e	00 	. 
	nop			;702f	00 	. 
	nop			;7030	00 	. 
	nop			;7031	00 	. 
	nop			;7032	00 	. 
	nop			;7033	00 	. 
	nop			;7034	00 	. 
	nop			;7035	00 	. 
	nop			;7036	00 	. 
	nop			;7037	00 	. 
	nop			;7038	00 	. 
	nop			;7039	00 	. 
	nop			;703a	00 	. 
	nop			;703b	00 	. 
	nop			;703c	00 	. 
	nop			;703d	00 	. 
	nop			;703e	00 	. 
	nop			;703f	00 	. 
	nop			;7040	00 	. 
	nop			;7041	00 	. 
	nop			;7042	00 	. 
	nop			;7043	00 	. 
	nop			;7044	00 	. 
	nop			;7045	00 	. 
	nop			;7046	00 	. 
	nop			;7047	00 	. 
	nop			;7048	00 	. 
	nop			;7049	00 	. 
	nop			;704a	00 	. 
	nop			;704b	00 	. 
	nop			;704c	00 	. 
	nop			;704d	00 	. 
	nop			;704e	00 	. 
	nop			;704f	00 	. 
	nop			;7050	00 	. 
	nop			;7051	00 	. 
	nop			;7052	00 	. 
	nop			;7053	00 	. 
	nop			;7054	00 	. 
	nop			;7055	00 	. 
	nop			;7056	00 	. 
	nop			;7057	00 	. 
	nop			;7058	00 	. 
	nop			;7059	00 	. 
	nop			;705a	00 	. 
	nop			;705b	00 	. 
	nop			;705c	00 	. 
	nop			;705d	00 	. 
	nop			;705e	00 	. 
	nop			;705f	00 	. 
	nop			;7060	00 	. 
	nop			;7061	00 	. 
	nop			;7062	00 	. 
	nop			;7063	00 	. 
	nop			;7064	00 	. 
	nop			;7065	00 	. 
	nop			;7066	00 	. 
	nop			;7067	00 	. 
	nop			;7068	00 	. 
	nop			;7069	00 	. 
	nop			;706a	00 	. 
	nop			;706b	00 	. 
	nop			;706c	00 	. 
	nop			;706d	00 	. 
	nop			;706e	00 	. 
	nop			;706f	00 	. 
	nop			;7070	00 	. 
	nop			;7071	00 	. 
	nop			;7072	00 	. 
	nop			;7073	00 	. 
	nop			;7074	00 	. 
	nop			;7075	00 	. 
	nop			;7076	00 	. 
	nop			;7077	00 	. 
	nop			;7078	00 	. 
	nop			;7079	00 	. 
	nop			;707a	00 	. 
	nop			;707b	00 	. 
	nop			;707c	00 	. 
	nop			;707d	00 	. 
	nop			;707e	00 	. 
	nop			;707f	00 	. 
	nop			;7080	00 	. 
	nop			;7081	00 	. 
	nop			;7082	00 	. 
	nop			;7083	00 	. 
	nop			;7084	00 	. 
	nop			;7085	00 	. 
	nop			;7086	00 	. 
	nop			;7087	00 	. 
	nop			;7088	00 	. 
	nop			;7089	00 	. 
	nop			;708a	00 	. 
	nop			;708b	00 	. 
	nop			;708c	00 	. 
	nop			;708d	00 	. 
	nop			;708e	00 	. 
	nop			;708f	00 	. 
	nop			;7090	00 	. 
	nop			;7091	00 	. 
	nop			;7092	00 	. 
	nop			;7093	00 	. 
	nop			;7094	00 	. 
	nop			;7095	00 	. 
	nop			;7096	00 	. 
	nop			;7097	00 	. 
	nop			;7098	00 	. 
	nop			;7099	00 	. 
	nop			;709a	00 	. 
	nop			;709b	00 	. 
	nop			;709c	00 	. 
	nop			;709d	00 	. 
	nop			;709e	00 	. 
	nop			;709f	00 	. 
	nop			;70a0	00 	. 
	nop			;70a1	00 	. 
	nop			;70a2	00 	. 
	nop			;70a3	00 	. 
	nop			;70a4	00 	. 
	nop			;70a5	00 	. 
	nop			;70a6	00 	. 
	nop			;70a7	00 	. 
	nop			;70a8	00 	. 
	nop			;70a9	00 	. 
	nop			;70aa	00 	. 
	nop			;70ab	00 	. 
	nop			;70ac	00 	. 
	nop			;70ad	00 	. 
	nop			;70ae	00 	. 
	nop			;70af	00 	. 
	nop			;70b0	00 	. 
	nop			;70b1	00 	. 
	nop			;70b2	00 	. 
	nop			;70b3	00 	. 
	nop			;70b4	00 	. 
	nop			;70b5	00 	. 
	nop			;70b6	00 	. 
	nop			;70b7	00 	. 
	nop			;70b8	00 	. 
	nop			;70b9	00 	. 
	nop			;70ba	00 	. 
	nop			;70bb	00 	. 
	nop			;70bc	00 	. 
	nop			;70bd	00 	. 
	nop			;70be	00 	. 
	nop			;70bf	00 	. 
	nop			;70c0	00 	. 
	nop			;70c1	00 	. 
	nop			;70c2	00 	. 
	nop			;70c3	00 	. 
	nop			;70c4	00 	. 
	nop			;70c5	00 	. 
	nop			;70c6	00 	. 
	nop			;70c7	00 	. 
	nop			;70c8	00 	. 
	nop			;70c9	00 	. 
	nop			;70ca	00 	. 
	nop			;70cb	00 	. 
	nop			;70cc	00 	. 
	nop			;70cd	00 	. 
	nop			;70ce	00 	. 
	nop			;70cf	00 	. 
	nop			;70d0	00 	. 
	nop			;70d1	00 	. 
	nop			;70d2	00 	. 
	nop			;70d3	00 	. 
	nop			;70d4	00 	. 
	nop			;70d5	00 	. 
	nop			;70d6	00 	. 
	nop			;70d7	00 	. 
	nop			;70d8	00 	. 
	nop			;70d9	00 	. 
	nop			;70da	00 	. 
	nop			;70db	00 	. 
	nop			;70dc	00 	. 
	nop			;70dd	00 	. 
	nop			;70de	00 	. 
	nop			;70df	00 	. 
	nop			;70e0	00 	. 
	nop			;70e1	00 	. 
	nop			;70e2	00 	. 
	nop			;70e3	00 	. 
	nop			;70e4	00 	. 
	nop			;70e5	00 	. 
	nop			;70e6	00 	. 
	nop			;70e7	00 	. 
	nop			;70e8	00 	. 
	nop			;70e9	00 	. 
	nop			;70ea	00 	. 
	nop			;70eb	00 	. 
	nop			;70ec	00 	. 
	nop			;70ed	00 	. 
	nop			;70ee	00 	. 
	nop			;70ef	00 	. 
	nop			;70f0	00 	. 
	nop			;70f1	00 	. 
	nop			;70f2	00 	. 
	nop			;70f3	00 	. 
	nop			;70f4	00 	. 
	nop			;70f5	00 	. 
	nop			;70f6	00 	. 
	nop			;70f7	00 	. 
	nop			;70f8	00 	. 
	nop			;70f9	00 	. 
	nop			;70fa	00 	. 
	nop			;70fb	00 	. 
	nop			;70fc	00 	. 
	nop			;70fd	00 	. 
	nop			;70fe	00 	. 
	nop			;70ff	00 	. 
	nop			;7100	00 	. 
	nop			;7101	00 	. 
	nop			;7102	00 	. 
	nop			;7103	00 	. 
	nop			;7104	00 	. 
	nop			;7105	00 	. 
	nop			;7106	00 	. 
	nop			;7107	00 	. 
	nop			;7108	00 	. 
	nop			;7109	00 	. 
	nop			;710a	00 	. 
	nop			;710b	00 	. 
	nop			;710c	00 	. 
	nop			;710d	00 	. 
	nop			;710e	00 	. 
	nop			;710f	00 	. 
	nop			;7110	00 	. 
	nop			;7111	00 	. 
	nop			;7112	00 	. 
	nop			;7113	00 	. 
	nop			;7114	00 	. 
	nop			;7115	00 	. 
	nop			;7116	00 	. 
	nop			;7117	00 	. 
	nop			;7118	00 	. 
	nop			;7119	00 	. 
	nop			;711a	00 	. 
	nop			;711b	00 	. 
	nop			;711c	00 	. 
	nop			;711d	00 	. 
	nop			;711e	00 	. 
	nop			;711f	00 	. 
	nop			;7120	00 	. 
	nop			;7121	00 	. 
	nop			;7122	00 	. 
	nop			;7123	00 	. 
	nop			;7124	00 	. 
	nop			;7125	00 	. 
	nop			;7126	00 	. 
	nop			;7127	00 	. 
	nop			;7128	00 	. 
	nop			;7129	00 	. 
	nop			;712a	00 	. 
	nop			;712b	00 	. 
	nop			;712c	00 	. 
	nop			;712d	00 	. 
	nop			;712e	00 	. 
	nop			;712f	00 	. 
	nop			;7130	00 	. 
	nop			;7131	00 	. 
	nop			;7132	00 	. 
	nop			;7133	00 	. 
	nop			;7134	00 	. 
	nop			;7135	00 	. 
	nop			;7136	00 	. 
	nop			;7137	00 	. 
	nop			;7138	00 	. 
	nop			;7139	00 	. 
	nop			;713a	00 	. 
	nop			;713b	00 	. 
	nop			;713c	00 	. 
	nop			;713d	00 	. 
	nop			;713e	00 	. 
	nop			;713f	00 	. 
	nop			;7140	00 	. 
	nop			;7141	00 	. 
	nop			;7142	00 	. 
	nop			;7143	00 	. 
	nop			;7144	00 	. 
	nop			;7145	00 	. 
	nop			;7146	00 	. 
	nop			;7147	00 	. 
	nop			;7148	00 	. 
	nop			;7149	00 	. 
	nop			;714a	00 	. 
	nop			;714b	00 	. 
	nop			;714c	00 	. 
	nop			;714d	00 	. 
	nop			;714e	00 	. 
	nop			;714f	00 	. 
	nop			;7150	00 	. 
	nop			;7151	00 	. 
	nop			;7152	00 	. 
	nop			;7153	00 	. 
	nop			;7154	00 	. 
	nop			;7155	00 	. 
	nop			;7156	00 	. 
	nop			;7157	00 	. 
	nop			;7158	00 	. 
	nop			;7159	00 	. 
	nop			;715a	00 	. 
	nop			;715b	00 	. 
	nop			;715c	00 	. 
	nop			;715d	00 	. 
	nop			;715e	00 	. 
	nop			;715f	00 	. 
	nop			;7160	00 	. 
	nop			;7161	00 	. 
	nop			;7162	00 	. 
	nop			;7163	00 	. 
	nop			;7164	00 	. 
	nop			;7165	00 	. 
	nop			;7166	00 	. 
	nop			;7167	00 	. 
	nop			;7168	00 	. 
	nop			;7169	00 	. 
	nop			;716a	00 	. 
	nop			;716b	00 	. 
	nop			;716c	00 	. 
	nop			;716d	00 	. 
	nop			;716e	00 	. 
	nop			;716f	00 	. 
	nop			;7170	00 	. 
	nop			;7171	00 	. 
	nop			;7172	00 	. 
	nop			;7173	00 	. 
	nop			;7174	00 	. 
	nop			;7175	00 	. 
	nop			;7176	00 	. 
	nop			;7177	00 	. 
	nop			;7178	00 	. 
	nop			;7179	00 	. 
	nop			;717a	00 	. 
	nop			;717b	00 	. 
	nop			;717c	00 	. 
	nop			;717d	00 	. 
	nop			;717e	00 	. 
	nop			;717f	00 	. 
	nop			;7180	00 	. 
	nop			;7181	00 	. 
	nop			;7182	00 	. 
	nop			;7183	00 	. 
	nop			;7184	00 	. 
	nop			;7185	00 	. 
	nop			;7186	00 	. 
	nop			;7187	00 	. 
	nop			;7188	00 	. 
	nop			;7189	00 	. 
	nop			;718a	00 	. 
	nop			;718b	00 	. 
	nop			;718c	00 	. 
	nop			;718d	00 	. 
	nop			;718e	00 	. 
	nop			;718f	00 	. 
	nop			;7190	00 	. 
	nop			;7191	00 	. 
	nop			;7192	00 	. 
	nop			;7193	00 	. 
	nop			;7194	00 	. 
	nop			;7195	00 	. 
	nop			;7196	00 	. 
	nop			;7197	00 	. 
	nop			;7198	00 	. 
	nop			;7199	00 	. 
	nop			;719a	00 	. 
	nop			;719b	00 	. 
	nop			;719c	00 	. 
	nop			;719d	00 	. 
	nop			;719e	00 	. 
	nop			;719f	00 	. 
	nop			;71a0	00 	. 
	nop			;71a1	00 	. 
	nop			;71a2	00 	. 
	nop			;71a3	00 	. 
	nop			;71a4	00 	. 
	nop			;71a5	00 	. 
	nop			;71a6	00 	. 
	nop			;71a7	00 	. 
	nop			;71a8	00 	. 
	nop			;71a9	00 	. 
	nop			;71aa	00 	. 
	nop			;71ab	00 	. 
	nop			;71ac	00 	. 
	nop			;71ad	00 	. 
	nop			;71ae	00 	. 
	nop			;71af	00 	. 
	nop			;71b0	00 	. 
	nop			;71b1	00 	. 
	nop			;71b2	00 	. 
	nop			;71b3	00 	. 
	nop			;71b4	00 	. 
	nop			;71b5	00 	. 
	nop			;71b6	00 	. 
	nop			;71b7	00 	. 
	nop			;71b8	00 	. 
	nop			;71b9	00 	. 
	nop			;71ba	00 	. 
	nop			;71bb	00 	. 
	nop			;71bc	00 	. 
	nop			;71bd	00 	. 
	nop			;71be	00 	. 
	nop			;71bf	00 	. 
	nop			;71c0	00 	. 
	nop			;71c1	00 	. 
	nop			;71c2	00 	. 
	nop			;71c3	00 	. 
	nop			;71c4	00 	. 
	nop			;71c5	00 	. 
	nop			;71c6	00 	. 
	nop			;71c7	00 	. 
	nop			;71c8	00 	. 
	nop			;71c9	00 	. 
	nop			;71ca	00 	. 
	nop			;71cb	00 	. 
	nop			;71cc	00 	. 
	nop			;71cd	00 	. 
	nop			;71ce	00 	. 
	nop			;71cf	00 	. 
	nop			;71d0	00 	. 
	nop			;71d1	00 	. 
	nop			;71d2	00 	. 
	nop			;71d3	00 	. 
	nop			;71d4	00 	. 
	nop			;71d5	00 	. 
	nop			;71d6	00 	. 
	nop			;71d7	00 	. 
	nop			;71d8	00 	. 
	nop			;71d9	00 	. 
	nop			;71da	00 	. 
	nop			;71db	00 	. 
	nop			;71dc	00 	. 
	nop			;71dd	00 	. 
	nop			;71de	00 	. 
	nop			;71df	00 	. 
	nop			;71e0	00 	. 
	nop			;71e1	00 	. 
	nop			;71e2	00 	. 
	nop			;71e3	00 	. 
	nop			;71e4	00 	. 
	nop			;71e5	00 	. 
	nop			;71e6	00 	. 
	nop			;71e7	00 	. 
	nop			;71e8	00 	. 
	nop			;71e9	00 	. 
	nop			;71ea	00 	. 
	nop			;71eb	00 	. 
	nop			;71ec	00 	. 
	nop			;71ed	00 	. 
	nop			;71ee	00 	. 
	nop			;71ef	00 	. 
	nop			;71f0	00 	. 
	nop			;71f1	00 	. 
	nop			;71f2	00 	. 
	nop			;71f3	00 	. 
	nop			;71f4	00 	. 
	nop			;71f5	00 	. 
	nop			;71f6	00 	. 
	nop			;71f7	00 	. 
	nop			;71f8	00 	. 
	nop			;71f9	00 	. 
	nop			;71fa	00 	. 
	nop			;71fb	00 	. 
	nop			;71fc	00 	. 
	nop			;71fd	00 	. 
	nop			;71fe	00 	. 
	nop			;71ff	00 	. 
	nop			;7200	00 	. 
	nop			;7201	00 	. 
	nop			;7202	00 	. 
	nop			;7203	00 	. 
	nop			;7204	00 	. 
	nop			;7205	00 	. 
	nop			;7206	00 	. 
	nop			;7207	00 	. 
	nop			;7208	00 	. 
	nop			;7209	00 	. 
	nop			;720a	00 	. 
	nop			;720b	00 	. 
	nop			;720c	00 	. 
	nop			;720d	00 	. 
	nop			;720e	00 	. 
	nop			;720f	00 	. 
	nop			;7210	00 	. 
	nop			;7211	00 	. 
	nop			;7212	00 	. 
	nop			;7213	00 	. 
	nop			;7214	00 	. 
	nop			;7215	00 	. 
	nop			;7216	00 	. 
	nop			;7217	00 	. 
	nop			;7218	00 	. 
	nop			;7219	00 	. 
	nop			;721a	00 	. 
	nop			;721b	00 	. 
	nop			;721c	00 	. 
	nop			;721d	00 	. 
	nop			;721e	00 	. 
	nop			;721f	00 	. 
	nop			;7220	00 	. 
	nop			;7221	00 	. 
	nop			;7222	00 	. 
	nop			;7223	00 	. 
	nop			;7224	00 	. 
	nop			;7225	00 	. 
	nop			;7226	00 	. 
	nop			;7227	00 	. 
	nop			;7228	00 	. 
	nop			;7229	00 	. 
	nop			;722a	00 	. 
	nop			;722b	00 	. 
	nop			;722c	00 	. 
	nop			;722d	00 	. 
	nop			;722e	00 	. 
	nop			;722f	00 	. 
	nop			;7230	00 	. 
	nop			;7231	00 	. 
	nop			;7232	00 	. 
	nop			;7233	00 	. 
	nop			;7234	00 	. 
	nop			;7235	00 	. 
	nop			;7236	00 	. 
	nop			;7237	00 	. 
	nop			;7238	00 	. 
	nop			;7239	00 	. 
	nop			;723a	00 	. 
	nop			;723b	00 	. 
	nop			;723c	00 	. 
	nop			;723d	00 	. 
	nop			;723e	00 	. 
	nop			;723f	00 	. 
	nop			;7240	00 	. 
	nop			;7241	00 	. 
	nop			;7242	00 	. 
	nop			;7243	00 	. 
	nop			;7244	00 	. 
	nop			;7245	00 	. 
	nop			;7246	00 	. 
	nop			;7247	00 	. 
	nop			;7248	00 	. 
	nop			;7249	00 	. 
	nop			;724a	00 	. 
	nop			;724b	00 	. 
	nop			;724c	00 	. 
	nop			;724d	00 	. 
	nop			;724e	00 	. 
	nop			;724f	00 	. 
	nop			;7250	00 	. 
	nop			;7251	00 	. 
	nop			;7252	00 	. 
	nop			;7253	00 	. 
	nop			;7254	00 	. 
	nop			;7255	00 	. 
	nop			;7256	00 	. 
	nop			;7257	00 	. 
	nop			;7258	00 	. 
	nop			;7259	00 	. 
	nop			;725a	00 	. 
	nop			;725b	00 	. 
	nop			;725c	00 	. 
	nop			;725d	00 	. 
	nop			;725e	00 	. 
	nop			;725f	00 	. 
	nop			;7260	00 	. 
	nop			;7261	00 	. 
	nop			;7262	00 	. 
	nop			;7263	00 	. 
	nop			;7264	00 	. 
	nop			;7265	00 	. 
	nop			;7266	00 	. 
	nop			;7267	00 	. 
	nop			;7268	00 	. 
	nop			;7269	00 	. 
	nop			;726a	00 	. 
	nop			;726b	00 	. 
	nop			;726c	00 	. 
	nop			;726d	00 	. 
	nop			;726e	00 	. 
	nop			;726f	00 	. 
	nop			;7270	00 	. 
	nop			;7271	00 	. 
	nop			;7272	00 	. 
	nop			;7273	00 	. 
	nop			;7274	00 	. 
	nop			;7275	00 	. 
	nop			;7276	00 	. 
	nop			;7277	00 	. 
	nop			;7278	00 	. 
	nop			;7279	00 	. 
	nop			;727a	00 	. 
	nop			;727b	00 	. 
	nop			;727c	00 	. 
	nop			;727d	00 	. 
	nop			;727e	00 	. 
	nop			;727f	00 	. 
	nop			;7280	00 	. 
	nop			;7281	00 	. 
	nop			;7282	00 	. 
	nop			;7283	00 	. 
	nop			;7284	00 	. 
	nop			;7285	00 	. 
	nop			;7286	00 	. 
	nop			;7287	00 	. 
	nop			;7288	00 	. 
	nop			;7289	00 	. 
	nop			;728a	00 	. 
	nop			;728b	00 	. 
	nop			;728c	00 	. 
	nop			;728d	00 	. 
	nop			;728e	00 	. 
	nop			;728f	00 	. 
	nop			;7290	00 	. 
	nop			;7291	00 	. 
	nop			;7292	00 	. 
	nop			;7293	00 	. 
	nop			;7294	00 	. 
	nop			;7295	00 	. 
	nop			;7296	00 	. 
	nop			;7297	00 	. 
	nop			;7298	00 	. 
	nop			;7299	00 	. 
	nop			;729a	00 	. 
	nop			;729b	00 	. 
	nop			;729c	00 	. 
	nop			;729d	00 	. 
	nop			;729e	00 	. 
	nop			;729f	00 	. 
	nop			;72a0	00 	. 
	nop			;72a1	00 	. 
	nop			;72a2	00 	. 
	nop			;72a3	00 	. 
	nop			;72a4	00 	. 
	nop			;72a5	00 	. 
	nop			;72a6	00 	. 
	nop			;72a7	00 	. 
	nop			;72a8	00 	. 
	nop			;72a9	00 	. 
	nop			;72aa	00 	. 
	nop			;72ab	00 	. 
	nop			;72ac	00 	. 
	nop			;72ad	00 	. 
	nop			;72ae	00 	. 
	nop			;72af	00 	. 
	nop			;72b0	00 	. 
	nop			;72b1	00 	. 
	nop			;72b2	00 	. 
	nop			;72b3	00 	. 
	nop			;72b4	00 	. 
	nop			;72b5	00 	. 
	nop			;72b6	00 	. 
	nop			;72b7	00 	. 
	nop			;72b8	00 	. 
	nop			;72b9	00 	. 
	nop			;72ba	00 	. 
	nop			;72bb	00 	. 
	nop			;72bc	00 	. 
	nop			;72bd	00 	. 
	nop			;72be	00 	. 
	nop			;72bf	00 	. 
	nop			;72c0	00 	. 
	nop			;72c1	00 	. 
	nop			;72c2	00 	. 
	nop			;72c3	00 	. 
	nop			;72c4	00 	. 
	nop			;72c5	00 	. 
	nop			;72c6	00 	. 
	nop			;72c7	00 	. 
	nop			;72c8	00 	. 
	nop			;72c9	00 	. 
	nop			;72ca	00 	. 
	nop			;72cb	00 	. 
	nop			;72cc	00 	. 
	nop			;72cd	00 	. 
	nop			;72ce	00 	. 
	nop			;72cf	00 	. 
	nop			;72d0	00 	. 
	nop			;72d1	00 	. 
	nop			;72d2	00 	. 
	nop			;72d3	00 	. 
	nop			;72d4	00 	. 
	nop			;72d5	00 	. 
	nop			;72d6	00 	. 
	nop			;72d7	00 	. 
	nop			;72d8	00 	. 
	nop			;72d9	00 	. 
	nop			;72da	00 	. 
	nop			;72db	00 	. 
	nop			;72dc	00 	. 
	nop			;72dd	00 	. 
	nop			;72de	00 	. 
	nop			;72df	00 	. 
	nop			;72e0	00 	. 
	nop			;72e1	00 	. 
	nop			;72e2	00 	. 
	nop			;72e3	00 	. 
	nop			;72e4	00 	. 
	nop			;72e5	00 	. 
	nop			;72e6	00 	. 
	nop			;72e7	00 	. 
	nop			;72e8	00 	. 
	nop			;72e9	00 	. 
	nop			;72ea	00 	. 
	nop			;72eb	00 	. 
	nop			;72ec	00 	. 
	nop			;72ed	00 	. 
	nop			;72ee	00 	. 
	nop			;72ef	00 	. 
	nop			;72f0	00 	. 
	nop			;72f1	00 	. 
	nop			;72f2	00 	. 
	nop			;72f3	00 	. 
	nop			;72f4	00 	. 
	nop			;72f5	00 	. 
	nop			;72f6	00 	. 
	nop			;72f7	00 	. 
	nop			;72f8	00 	. 
	nop			;72f9	00 	. 
	nop			;72fa	00 	. 
	nop			;72fb	00 	. 
	nop			;72fc	00 	. 
	nop			;72fd	00 	. 
	nop			;72fe	00 	. 
	nop			;72ff	00 	. 
	nop			;7300	00 	. 
	nop			;7301	00 	. 
	nop			;7302	00 	. 
	nop			;7303	00 	. 
	nop			;7304	00 	. 
	nop			;7305	00 	. 
	nop			;7306	00 	. 
	nop			;7307	00 	. 
	nop			;7308	00 	. 
	nop			;7309	00 	. 
	nop			;730a	00 	. 
	nop			;730b	00 	. 
	nop			;730c	00 	. 
	nop			;730d	00 	. 
	nop			;730e	00 	. 
	nop			;730f	00 	. 
	nop			;7310	00 	. 
	nop			;7311	00 	. 
	nop			;7312	00 	. 
	nop			;7313	00 	. 
	nop			;7314	00 	. 
	nop			;7315	00 	. 
	nop			;7316	00 	. 
	nop			;7317	00 	. 
	nop			;7318	00 	. 
	nop			;7319	00 	. 
	nop			;731a	00 	. 
	nop			;731b	00 	. 
	nop			;731c	00 	. 
	nop			;731d	00 	. 
	nop			;731e	00 	. 
	nop			;731f	00 	. 
	nop			;7320	00 	. 
	nop			;7321	00 	. 
	nop			;7322	00 	. 
	nop			;7323	00 	. 
	nop			;7324	00 	. 
	nop			;7325	00 	. 
	nop			;7326	00 	. 
	nop			;7327	00 	. 
	nop			;7328	00 	. 
	nop			;7329	00 	. 
	nop			;732a	00 	. 
	nop			;732b	00 	. 
	nop			;732c	00 	. 
	nop			;732d	00 	. 
	nop			;732e	00 	. 
	nop			;732f	00 	. 
	nop			;7330	00 	. 
	nop			;7331	00 	. 
	nop			;7332	00 	. 
	nop			;7333	00 	. 
	nop			;7334	00 	. 
	nop			;7335	00 	. 
	nop			;7336	00 	. 
	nop			;7337	00 	. 
	nop			;7338	00 	. 
	nop			;7339	00 	. 
	nop			;733a	00 	. 
	nop			;733b	00 	. 
	nop			;733c	00 	. 
	nop			;733d	00 	. 
	nop			;733e	00 	. 
	nop			;733f	00 	. 
	nop			;7340	00 	. 
	nop			;7341	00 	. 
	nop			;7342	00 	. 
	nop			;7343	00 	. 
	nop			;7344	00 	. 
	nop			;7345	00 	. 
	nop			;7346	00 	. 
	nop			;7347	00 	. 
	nop			;7348	00 	. 
	nop			;7349	00 	. 
	nop			;734a	00 	. 
	nop			;734b	00 	. 
	nop			;734c	00 	. 
	nop			;734d	00 	. 
	nop			;734e	00 	. 
	nop			;734f	00 	. 
	nop			;7350	00 	. 
	nop			;7351	00 	. 
	nop			;7352	00 	. 
	nop			;7353	00 	. 
	nop			;7354	00 	. 
	nop			;7355	00 	. 
	nop			;7356	00 	. 
	nop			;7357	00 	. 
	nop			;7358	00 	. 
	nop			;7359	00 	. 
	nop			;735a	00 	. 
	nop			;735b	00 	. 
	nop			;735c	00 	. 
	nop			;735d	00 	. 
	nop			;735e	00 	. 
	nop			;735f	00 	. 
	nop			;7360	00 	. 
	nop			;7361	00 	. 
	nop			;7362	00 	. 
	nop			;7363	00 	. 
	nop			;7364	00 	. 
	nop			;7365	00 	. 
	nop			;7366	00 	. 
	nop			;7367	00 	. 
	nop			;7368	00 	. 
	nop			;7369	00 	. 
	nop			;736a	00 	. 
	nop			;736b	00 	. 
	nop			;736c	00 	. 
	nop			;736d	00 	. 
	nop			;736e	00 	. 
	nop			;736f	00 	. 
	nop			;7370	00 	. 
	nop			;7371	00 	. 
	nop			;7372	00 	. 
	nop			;7373	00 	. 
	nop			;7374	00 	. 
	nop			;7375	00 	. 
	nop			;7376	00 	. 
	nop			;7377	00 	. 
	nop			;7378	00 	. 
	nop			;7379	00 	. 
	nop			;737a	00 	. 
	nop			;737b	00 	. 
	nop			;737c	00 	. 
	nop			;737d	00 	. 
	nop			;737e	00 	. 
	nop			;737f	00 	. 
	nop			;7380	00 	. 
	nop			;7381	00 	. 
	nop			;7382	00 	. 
	nop			;7383	00 	. 
	nop			;7384	00 	. 
	nop			;7385	00 	. 
	nop			;7386	00 	. 
	nop			;7387	00 	. 
	nop			;7388	00 	. 
	nop			;7389	00 	. 
	nop			;738a	00 	. 
	nop			;738b	00 	. 
	nop			;738c	00 	. 
	nop			;738d	00 	. 
	nop			;738e	00 	. 
	nop			;738f	00 	. 
	nop			;7390	00 	. 
	nop			;7391	00 	. 
	nop			;7392	00 	. 
	nop			;7393	00 	. 
	nop			;7394	00 	. 
	nop			;7395	00 	. 
	nop			;7396	00 	. 
	nop			;7397	00 	. 
	nop			;7398	00 	. 
	nop			;7399	00 	. 
	nop			;739a	00 	. 
	nop			;739b	00 	. 
	nop			;739c	00 	. 
	nop			;739d	00 	. 
	nop			;739e	00 	. 
	nop			;739f	00 	. 
	nop			;73a0	00 	. 
	nop			;73a1	00 	. 
	nop			;73a2	00 	. 
	nop			;73a3	00 	. 
	nop			;73a4	00 	. 
	nop			;73a5	00 	. 
	nop			;73a6	00 	. 
	nop			;73a7	00 	. 
	nop			;73a8	00 	. 
	nop			;73a9	00 	. 
	nop			;73aa	00 	. 
	nop			;73ab	00 	. 
	nop			;73ac	00 	. 
	nop			;73ad	00 	. 
	nop			;73ae	00 	. 
	nop			;73af	00 	. 
	nop			;73b0	00 	. 
	nop			;73b1	00 	. 
	nop			;73b2	00 	. 
	nop			;73b3	00 	. 
	nop			;73b4	00 	. 
	nop			;73b5	00 	. 
	nop			;73b6	00 	. 
	nop			;73b7	00 	. 
	nop			;73b8	00 	. 
	nop			;73b9	00 	. 
	nop			;73ba	00 	. 
	nop			;73bb	00 	. 
	nop			;73bc	00 	. 
	nop			;73bd	00 	. 
	nop			;73be	00 	. 
	nop			;73bf	00 	. 
	nop			;73c0	00 	. 
	nop			;73c1	00 	. 
	nop			;73c2	00 	. 
	nop			;73c3	00 	. 
	nop			;73c4	00 	. 
	nop			;73c5	00 	. 
	nop			;73c6	00 	. 
	nop			;73c7	00 	. 
	nop			;73c8	00 	. 
	nop			;73c9	00 	. 
	nop			;73ca	00 	. 
	nop			;73cb	00 	. 
	nop			;73cc	00 	. 
	nop			;73cd	00 	. 
	nop			;73ce	00 	. 
	nop			;73cf	00 	. 
	nop			;73d0	00 	. 
	nop			;73d1	00 	. 
	nop			;73d2	00 	. 
	nop			;73d3	00 	. 
	nop			;73d4	00 	. 
	nop			;73d5	00 	. 
	nop			;73d6	00 	. 
	nop			;73d7	00 	. 
	nop			;73d8	00 	. 
	nop			;73d9	00 	. 
	nop			;73da	00 	. 
	nop			;73db	00 	. 
	nop			;73dc	00 	. 
	nop			;73dd	00 	. 
	nop			;73de	00 	. 
	nop			;73df	00 	. 
	nop			;73e0	00 	. 
	nop			;73e1	00 	. 
	nop			;73e2	00 	. 
	nop			;73e3	00 	. 
	nop			;73e4	00 	. 
	nop			;73e5	00 	. 
	nop			;73e6	00 	. 
	nop			;73e7	00 	. 
	nop			;73e8	00 	. 
	nop			;73e9	00 	. 
	nop			;73ea	00 	. 
	nop			;73eb	00 	. 
	nop			;73ec	00 	. 
	nop			;73ed	00 	. 
	nop			;73ee	00 	. 
	nop			;73ef	00 	. 
	nop			;73f0	00 	. 
	nop			;73f1	00 	. 
	nop			;73f2	00 	. 
	nop			;73f3	00 	. 
	nop			;73f4	00 	. 
	nop			;73f5	00 	. 
	nop			;73f6	00 	. 
	nop			;73f7	00 	. 
	nop			;73f8	00 	. 
	nop			;73f9	00 	. 
	nop			;73fa	00 	. 
	nop			;73fb	00 	. 
	nop			;73fc	00 	. 
	nop			;73fd	00 	. 
	nop			;73fe	00 	. 
	nop			;73ff	00 	. 
	nop			;7400	00 	. 
	nop			;7401	00 	. 
	nop			;7402	00 	. 
	nop			;7403	00 	. 
	nop			;7404	00 	. 
	nop			;7405	00 	. 
	nop			;7406	00 	. 
	nop			;7407	00 	. 
	nop			;7408	00 	. 
	nop			;7409	00 	. 
	nop			;740a	00 	. 
	nop			;740b	00 	. 
	nop			;740c	00 	. 
	nop			;740d	00 	. 
	nop			;740e	00 	. 
	nop			;740f	00 	. 
	nop			;7410	00 	. 
	nop			;7411	00 	. 
	nop			;7412	00 	. 
	nop			;7413	00 	. 
	nop			;7414	00 	. 
	nop			;7415	00 	. 
	nop			;7416	00 	. 
	nop			;7417	00 	. 
	nop			;7418	00 	. 
	nop			;7419	00 	. 
	nop			;741a	00 	. 
	nop			;741b	00 	. 
	nop			;741c	00 	. 
	nop			;741d	00 	. 
	nop			;741e	00 	. 
	nop			;741f	00 	. 
	nop			;7420	00 	. 
	nop			;7421	00 	. 
	nop			;7422	00 	. 
	nop			;7423	00 	. 
	nop			;7424	00 	. 
	nop			;7425	00 	. 
	nop			;7426	00 	. 
	nop			;7427	00 	. 
	nop			;7428	00 	. 
	nop			;7429	00 	. 
	nop			;742a	00 	. 
	nop			;742b	00 	. 
	nop			;742c	00 	. 
	nop			;742d	00 	. 
	nop			;742e	00 	. 
	nop			;742f	00 	. 
	nop			;7430	00 	. 
	nop			;7431	00 	. 
	nop			;7432	00 	. 
	nop			;7433	00 	. 
	nop			;7434	00 	. 
	nop			;7435	00 	. 
	nop			;7436	00 	. 
	nop			;7437	00 	. 
	nop			;7438	00 	. 
	nop			;7439	00 	. 
	nop			;743a	00 	. 
	nop			;743b	00 	. 
	nop			;743c	00 	. 
	nop			;743d	00 	. 
	nop			;743e	00 	. 
	nop			;743f	00 	. 
	nop			;7440	00 	. 
	nop			;7441	00 	. 
	nop			;7442	00 	. 
	nop			;7443	00 	. 
	nop			;7444	00 	. 
	nop			;7445	00 	. 
	nop			;7446	00 	. 
	nop			;7447	00 	. 
	nop			;7448	00 	. 
	nop			;7449	00 	. 
	nop			;744a	00 	. 
	nop			;744b	00 	. 
	nop			;744c	00 	. 
	nop			;744d	00 	. 
	nop			;744e	00 	. 
	nop			;744f	00 	. 
	nop			;7450	00 	. 
	nop			;7451	00 	. 
	nop			;7452	00 	. 
	nop			;7453	00 	. 
	nop			;7454	00 	. 
	nop			;7455	00 	. 
	nop			;7456	00 	. 
	nop			;7457	00 	. 
	nop			;7458	00 	. 
	nop			;7459	00 	. 
	nop			;745a	00 	. 
	nop			;745b	00 	. 
	nop			;745c	00 	. 
	nop			;745d	00 	. 
	nop			;745e	00 	. 
	nop			;745f	00 	. 
	nop			;7460	00 	. 
	nop			;7461	00 	. 
	nop			;7462	00 	. 
	nop			;7463	00 	. 
	nop			;7464	00 	. 
	nop			;7465	00 	. 
	nop			;7466	00 	. 
	nop			;7467	00 	. 
	nop			;7468	00 	. 
	nop			;7469	00 	. 
	nop			;746a	00 	. 
	nop			;746b	00 	. 
	nop			;746c	00 	. 
	nop			;746d	00 	. 
	nop			;746e	00 	. 
	nop			;746f	00 	. 
	nop			;7470	00 	. 
	nop			;7471	00 	. 
	nop			;7472	00 	. 
	nop			;7473	00 	. 
	nop			;7474	00 	. 
	nop			;7475	00 	. 
	nop			;7476	00 	. 
	nop			;7477	00 	. 
	nop			;7478	00 	. 
	nop			;7479	00 	. 
	nop			;747a	00 	. 
	nop			;747b	00 	. 
	nop			;747c	00 	. 
	nop			;747d	00 	. 
	nop			;747e	00 	. 
	nop			;747f	00 	. 
	nop			;7480	00 	. 
	nop			;7481	00 	. 
	nop			;7482	00 	. 
	nop			;7483	00 	. 
	nop			;7484	00 	. 
	nop			;7485	00 	. 
	nop			;7486	00 	. 
	nop			;7487	00 	. 
	nop			;7488	00 	. 
	nop			;7489	00 	. 
	nop			;748a	00 	. 
	nop			;748b	00 	. 
	nop			;748c	00 	. 
	nop			;748d	00 	. 
	nop			;748e	00 	. 
	nop			;748f	00 	. 
	nop			;7490	00 	. 
	nop			;7491	00 	. 
	nop			;7492	00 	. 
	nop			;7493	00 	. 
	nop			;7494	00 	. 
	nop			;7495	00 	. 
	nop			;7496	00 	. 
	nop			;7497	00 	. 
	nop			;7498	00 	. 
	nop			;7499	00 	. 
	nop			;749a	00 	. 
	nop			;749b	00 	. 
	nop			;749c	00 	. 
	nop			;749d	00 	. 
	nop			;749e	00 	. 
	nop			;749f	00 	. 
	nop			;74a0	00 	. 
	nop			;74a1	00 	. 
	nop			;74a2	00 	. 
	nop			;74a3	00 	. 
	nop			;74a4	00 	. 
	nop			;74a5	00 	. 
	nop			;74a6	00 	. 
	nop			;74a7	00 	. 
	nop			;74a8	00 	. 
	nop			;74a9	00 	. 
	nop			;74aa	00 	. 
	nop			;74ab	00 	. 
	nop			;74ac	00 	. 
	nop			;74ad	00 	. 
	nop			;74ae	00 	. 
	nop			;74af	00 	. 
	nop			;74b0	00 	. 
	nop			;74b1	00 	. 
	nop			;74b2	00 	. 
	nop			;74b3	00 	. 
	nop			;74b4	00 	. 
	nop			;74b5	00 	. 
	nop			;74b6	00 	. 
	nop			;74b7	00 	. 
	nop			;74b8	00 	. 
	nop			;74b9	00 	. 
	nop			;74ba	00 	. 
	nop			;74bb	00 	. 
	nop			;74bc	00 	. 
	nop			;74bd	00 	. 
	nop			;74be	00 	. 
	nop			;74bf	00 	. 
	nop			;74c0	00 	. 
	nop			;74c1	00 	. 
	nop			;74c2	00 	. 
	nop			;74c3	00 	. 
	nop			;74c4	00 	. 
	nop			;74c5	00 	. 
	nop			;74c6	00 	. 
	nop			;74c7	00 	. 
	nop			;74c8	00 	. 
	nop			;74c9	00 	. 
	nop			;74ca	00 	. 
	nop			;74cb	00 	. 
	nop			;74cc	00 	. 
	nop			;74cd	00 	. 
	nop			;74ce	00 	. 
	nop			;74cf	00 	. 
	nop			;74d0	00 	. 
	nop			;74d1	00 	. 
	nop			;74d2	00 	. 
	nop			;74d3	00 	. 
	nop			;74d4	00 	. 
	nop			;74d5	00 	. 
	nop			;74d6	00 	. 
	nop			;74d7	00 	. 
	nop			;74d8	00 	. 
	nop			;74d9	00 	. 
	nop			;74da	00 	. 
	nop			;74db	00 	. 
	nop			;74dc	00 	. 
	nop			;74dd	00 	. 
	nop			;74de	00 	. 
	nop			;74df	00 	. 
	nop			;74e0	00 	. 
	nop			;74e1	00 	. 
	nop			;74e2	00 	. 
	nop			;74e3	00 	. 
	nop			;74e4	00 	. 
	nop			;74e5	00 	. 
	nop			;74e6	00 	. 
	nop			;74e7	00 	. 
	nop			;74e8	00 	. 
	nop			;74e9	00 	. 
	nop			;74ea	00 	. 
	nop			;74eb	00 	. 
	nop			;74ec	00 	. 
	nop			;74ed	00 	. 
	nop			;74ee	00 	. 
	nop			;74ef	00 	. 
	nop			;74f0	00 	. 
	nop			;74f1	00 	. 
	nop			;74f2	00 	. 
	nop			;74f3	00 	. 
	nop			;74f4	00 	. 
	nop			;74f5	00 	. 
	nop			;74f6	00 	. 
	nop			;74f7	00 	. 
	nop			;74f8	00 	. 
	nop			;74f9	00 	. 
	nop			;74fa	00 	. 
	nop			;74fb	00 	. 
	nop			;74fc	00 	. 
	nop			;74fd	00 	. 
	nop			;74fe	00 	. 
	nop			;74ff	00 	. 
	nop			;7500	00 	. 
	nop			;7501	00 	. 
	nop			;7502	00 	. 
	nop			;7503	00 	. 
	nop			;7504	00 	. 
	nop			;7505	00 	. 
	nop			;7506	00 	. 
	nop			;7507	00 	. 
	nop			;7508	00 	. 
	nop			;7509	00 	. 
	nop			;750a	00 	. 
	nop			;750b	00 	. 
	nop			;750c	00 	. 
	nop			;750d	00 	. 
	nop			;750e	00 	. 
	nop			;750f	00 	. 
	nop			;7510	00 	. 
	nop			;7511	00 	. 
	nop			;7512	00 	. 
	nop			;7513	00 	. 
	nop			;7514	00 	. 
	nop			;7515	00 	. 
	nop			;7516	00 	. 
	nop			;7517	00 	. 
	nop			;7518	00 	. 
	nop			;7519	00 	. 
	nop			;751a	00 	. 
	nop			;751b	00 	. 
	nop			;751c	00 	. 
	nop			;751d	00 	. 
	nop			;751e	00 	. 
	nop			;751f	00 	. 
	nop			;7520	00 	. 
	nop			;7521	00 	. 
	nop			;7522	00 	. 
	nop			;7523	00 	. 
	nop			;7524	00 	. 
	nop			;7525	00 	. 
	nop			;7526	00 	. 
	nop			;7527	00 	. 
	nop			;7528	00 	. 
	nop			;7529	00 	. 
	nop			;752a	00 	. 
	nop			;752b	00 	. 
	nop			;752c	00 	. 
	nop			;752d	00 	. 
	nop			;752e	00 	. 
	nop			;752f	00 	. 
	nop			;7530	00 	. 
	nop			;7531	00 	. 
	nop			;7532	00 	. 
	nop			;7533	00 	. 
	nop			;7534	00 	. 
	nop			;7535	00 	. 
	nop			;7536	00 	. 
	nop			;7537	00 	. 
	nop			;7538	00 	. 
	nop			;7539	00 	. 
	nop			;753a	00 	. 
	nop			;753b	00 	. 
	nop			;753c	00 	. 
	nop			;753d	00 	. 
	nop			;753e	00 	. 
	nop			;753f	00 	. 
	nop			;7540	00 	. 
	nop			;7541	00 	. 
	nop			;7542	00 	. 
	nop			;7543	00 	. 
	nop			;7544	00 	. 
	nop			;7545	00 	. 
	nop			;7546	00 	. 
	nop			;7547	00 	. 
	nop			;7548	00 	. 
	nop			;7549	00 	. 
	nop			;754a	00 	. 
	nop			;754b	00 	. 
	nop			;754c	00 	. 
	nop			;754d	00 	. 
	nop			;754e	00 	. 
	nop			;754f	00 	. 
	nop			;7550	00 	. 
	nop			;7551	00 	. 
	nop			;7552	00 	. 
	nop			;7553	00 	. 
	nop			;7554	00 	. 
	nop			;7555	00 	. 
	nop			;7556	00 	. 
	nop			;7557	00 	. 
	nop			;7558	00 	. 
	nop			;7559	00 	. 
	nop			;755a	00 	. 
	nop			;755b	00 	. 
	nop			;755c	00 	. 
	nop			;755d	00 	. 
	nop			;755e	00 	. 
	nop			;755f	00 	. 
	nop			;7560	00 	. 
	nop			;7561	00 	. 
	nop			;7562	00 	. 
	nop			;7563	00 	. 
	nop			;7564	00 	. 
	nop			;7565	00 	. 
	nop			;7566	00 	. 
	nop			;7567	00 	. 
	nop			;7568	00 	. 
	nop			;7569	00 	. 
	nop			;756a	00 	. 
	nop			;756b	00 	. 
	nop			;756c	00 	. 
	nop			;756d	00 	. 
	nop			;756e	00 	. 
	nop			;756f	00 	. 
	nop			;7570	00 	. 
	nop			;7571	00 	. 
	nop			;7572	00 	. 
	nop			;7573	00 	. 
	nop			;7574	00 	. 
	nop			;7575	00 	. 
	nop			;7576	00 	. 
	nop			;7577	00 	. 
	nop			;7578	00 	. 
	nop			;7579	00 	. 
	nop			;757a	00 	. 
	nop			;757b	00 	. 
	nop			;757c	00 	. 
	nop			;757d	00 	. 
	nop			;757e	00 	. 
	nop			;757f	00 	. 
	nop			;7580	00 	. 
	nop			;7581	00 	. 
	nop			;7582	00 	. 
	nop			;7583	00 	. 
	nop			;7584	00 	. 
	nop			;7585	00 	. 
	nop			;7586	00 	. 
	nop			;7587	00 	. 
	nop			;7588	00 	. 
	nop			;7589	00 	. 
	nop			;758a	00 	. 
	nop			;758b	00 	. 
	nop			;758c	00 	. 
	nop			;758d	00 	. 
	nop			;758e	00 	. 
	nop			;758f	00 	. 
	nop			;7590	00 	. 
	nop			;7591	00 	. 
	nop			;7592	00 	. 
	nop			;7593	00 	. 
	nop			;7594	00 	. 
	nop			;7595	00 	. 
	nop			;7596	00 	. 
	nop			;7597	00 	. 
	nop			;7598	00 	. 
	nop			;7599	00 	. 
	nop			;759a	00 	. 
	nop			;759b	00 	. 
	nop			;759c	00 	. 
	nop			;759d	00 	. 
	nop			;759e	00 	. 
	nop			;759f	00 	. 
	nop			;75a0	00 	. 
	nop			;75a1	00 	. 
	nop			;75a2	00 	. 
	nop			;75a3	00 	. 
	nop			;75a4	00 	. 
	nop			;75a5	00 	. 
	nop			;75a6	00 	. 
	nop			;75a7	00 	. 
	nop			;75a8	00 	. 
	nop			;75a9	00 	. 
	nop			;75aa	00 	. 
	nop			;75ab	00 	. 
	nop			;75ac	00 	. 
	nop			;75ad	00 	. 
	nop			;75ae	00 	. 
	nop			;75af	00 	. 
	nop			;75b0	00 	. 
	nop			;75b1	00 	. 
	nop			;75b2	00 	. 
	nop			;75b3	00 	. 
	nop			;75b4	00 	. 
	nop			;75b5	00 	. 
	nop			;75b6	00 	. 
	nop			;75b7	00 	. 
	nop			;75b8	00 	. 
	nop			;75b9	00 	. 
	nop			;75ba	00 	. 
	nop			;75bb	00 	. 
	nop			;75bc	00 	. 
	nop			;75bd	00 	. 
	nop			;75be	00 	. 
	nop			;75bf	00 	. 
	nop			;75c0	00 	. 
	nop			;75c1	00 	. 
	nop			;75c2	00 	. 
	nop			;75c3	00 	. 
	nop			;75c4	00 	. 
	nop			;75c5	00 	. 
	nop			;75c6	00 	. 
	nop			;75c7	00 	. 
	nop			;75c8	00 	. 
	nop			;75c9	00 	. 
	nop			;75ca	00 	. 
	nop			;75cb	00 	. 
	nop			;75cc	00 	. 
	nop			;75cd	00 	. 
	nop			;75ce	00 	. 
	nop			;75cf	00 	. 
	nop			;75d0	00 	. 
	nop			;75d1	00 	. 
	nop			;75d2	00 	. 
	nop			;75d3	00 	. 
	nop			;75d4	00 	. 
	nop			;75d5	00 	. 
	nop			;75d6	00 	. 
	nop			;75d7	00 	. 
	nop			;75d8	00 	. 
	nop			;75d9	00 	. 
	nop			;75da	00 	. 
	nop			;75db	00 	. 
	nop			;75dc	00 	. 
	nop			;75dd	00 	. 
	nop			;75de	00 	. 
	nop			;75df	00 	. 
	nop			;75e0	00 	. 
	nop			;75e1	00 	. 
	nop			;75e2	00 	. 
	nop			;75e3	00 	. 
	nop			;75e4	00 	. 
	nop			;75e5	00 	. 
	nop			;75e6	00 	. 
	nop			;75e7	00 	. 
	nop			;75e8	00 	. 
	nop			;75e9	00 	. 
	nop			;75ea	00 	. 
	nop			;75eb	00 	. 
	nop			;75ec	00 	. 
	nop			;75ed	00 	. 
	nop			;75ee	00 	. 
	nop			;75ef	00 	. 
	nop			;75f0	00 	. 
	nop			;75f1	00 	. 
	nop			;75f2	00 	. 
	nop			;75f3	00 	. 
	nop			;75f4	00 	. 
	nop			;75f5	00 	. 
	nop			;75f6	00 	. 
	nop			;75f7	00 	. 
	nop			;75f8	00 	. 
	nop			;75f9	00 	. 
	nop			;75fa	00 	. 
	nop			;75fb	00 	. 
	nop			;75fc	00 	. 
	nop			;75fd	00 	. 
	nop			;75fe	00 	. 
	nop			;75ff	00 	. 
	nop			;7600	00 	. 
	nop			;7601	00 	. 
	nop			;7602	00 	. 
	nop			;7603	00 	. 
	nop			;7604	00 	. 
	nop			;7605	00 	. 
	nop			;7606	00 	. 
	nop			;7607	00 	. 
	nop			;7608	00 	. 
	nop			;7609	00 	. 
	nop			;760a	00 	. 
	nop			;760b	00 	. 
	nop			;760c	00 	. 
	nop			;760d	00 	. 
	nop			;760e	00 	. 
	nop			;760f	00 	. 
	nop			;7610	00 	. 
	nop			;7611	00 	. 
	nop			;7612	00 	. 
	nop			;7613	00 	. 
	nop			;7614	00 	. 
	nop			;7615	00 	. 
	nop			;7616	00 	. 
	nop			;7617	00 	. 
	nop			;7618	00 	. 
	nop			;7619	00 	. 
	nop			;761a	00 	. 
	nop			;761b	00 	. 
	nop			;761c	00 	. 
	nop			;761d	00 	. 
	nop			;761e	00 	. 
	nop			;761f	00 	. 
	nop			;7620	00 	. 
	nop			;7621	00 	. 
	nop			;7622	00 	. 
	nop			;7623	00 	. 
	nop			;7624	00 	. 
	nop			;7625	00 	. 
	nop			;7626	00 	. 
	nop			;7627	00 	. 
	nop			;7628	00 	. 
	nop			;7629	00 	. 
	nop			;762a	00 	. 
	nop			;762b	00 	. 
	nop			;762c	00 	. 
	nop			;762d	00 	. 
	nop			;762e	00 	. 
	nop			;762f	00 	. 
	nop			;7630	00 	. 
	nop			;7631	00 	. 
	nop			;7632	00 	. 
	nop			;7633	00 	. 
	nop			;7634	00 	. 
	nop			;7635	00 	. 
	nop			;7636	00 	. 
	nop			;7637	00 	. 
	nop			;7638	00 	. 
	nop			;7639	00 	. 
	nop			;763a	00 	. 
	nop			;763b	00 	. 
	nop			;763c	00 	. 
	nop			;763d	00 	. 
	nop			;763e	00 	. 
	nop			;763f	00 	. 
	nop			;7640	00 	. 
	nop			;7641	00 	. 
	nop			;7642	00 	. 
	nop			;7643	00 	. 
	nop			;7644	00 	. 
	nop			;7645	00 	. 
	nop			;7646	00 	. 
	nop			;7647	00 	. 
	nop			;7648	00 	. 
	nop			;7649	00 	. 
	nop			;764a	00 	. 
	nop			;764b	00 	. 
	nop			;764c	00 	. 
	nop			;764d	00 	. 
	nop			;764e	00 	. 
	nop			;764f	00 	. 
	nop			;7650	00 	. 
	nop			;7651	00 	. 
	nop			;7652	00 	. 
	nop			;7653	00 	. 
	nop			;7654	00 	. 
	nop			;7655	00 	. 
	nop			;7656	00 	. 
	nop			;7657	00 	. 
	nop			;7658	00 	. 
	nop			;7659	00 	. 
	nop			;765a	00 	. 
	nop			;765b	00 	. 
	nop			;765c	00 	. 
	nop			;765d	00 	. 
	nop			;765e	00 	. 
	nop			;765f	00 	. 
	nop			;7660	00 	. 
	nop			;7661	00 	. 
	nop			;7662	00 	. 
	nop			;7663	00 	. 
	nop			;7664	00 	. 
	nop			;7665	00 	. 
	nop			;7666	00 	. 
	nop			;7667	00 	. 
	nop			;7668	00 	. 
	nop			;7669	00 	. 
	nop			;766a	00 	. 
	nop			;766b	00 	. 
	nop			;766c	00 	. 
	nop			;766d	00 	. 
	nop			;766e	00 	. 
	nop			;766f	00 	. 
	nop			;7670	00 	. 
	nop			;7671	00 	. 
	nop			;7672	00 	. 
	nop			;7673	00 	. 
	nop			;7674	00 	. 
	nop			;7675	00 	. 
	nop			;7676	00 	. 
	nop			;7677	00 	. 
	nop			;7678	00 	. 
	nop			;7679	00 	. 
	nop			;767a	00 	. 
	nop			;767b	00 	. 
	nop			;767c	00 	. 
	nop			;767d	00 	. 
	nop			;767e	00 	. 
	nop			;767f	00 	. 
	nop			;7680	00 	. 
	nop			;7681	00 	. 
	nop			;7682	00 	. 
	nop			;7683	00 	. 
	nop			;7684	00 	. 
	nop			;7685	00 	. 
	nop			;7686	00 	. 
	nop			;7687	00 	. 
	nop			;7688	00 	. 
	nop			;7689	00 	. 
	nop			;768a	00 	. 
	nop			;768b	00 	. 
	nop			;768c	00 	. 
	nop			;768d	00 	. 
	nop			;768e	00 	. 
	nop			;768f	00 	. 
	nop			;7690	00 	. 
	nop			;7691	00 	. 
	nop			;7692	00 	. 
	nop			;7693	00 	. 
	nop			;7694	00 	. 
	nop			;7695	00 	. 
	nop			;7696	00 	. 
	nop			;7697	00 	. 
	nop			;7698	00 	. 
	nop			;7699	00 	. 
	nop			;769a	00 	. 
	nop			;769b	00 	. 
	nop			;769c	00 	. 
	nop			;769d	00 	. 
	nop			;769e	00 	. 
	nop			;769f	00 	. 
	nop			;76a0	00 	. 
	nop			;76a1	00 	. 
	nop			;76a2	00 	. 
	nop			;76a3	00 	. 
	nop			;76a4	00 	. 
	nop			;76a5	00 	. 
	nop			;76a6	00 	. 
	nop			;76a7	00 	. 
	nop			;76a8	00 	. 
	nop			;76a9	00 	. 
	nop			;76aa	00 	. 
	nop			;76ab	00 	. 
	nop			;76ac	00 	. 
	nop			;76ad	00 	. 
	nop			;76ae	00 	. 
	nop			;76af	00 	. 
	nop			;76b0	00 	. 
	nop			;76b1	00 	. 
	nop			;76b2	00 	. 
	nop			;76b3	00 	. 
	nop			;76b4	00 	. 
	nop			;76b5	00 	. 
	nop			;76b6	00 	. 
	nop			;76b7	00 	. 
	nop			;76b8	00 	. 
	nop			;76b9	00 	. 
	nop			;76ba	00 	. 
	nop			;76bb	00 	. 
	nop			;76bc	00 	. 
	nop			;76bd	00 	. 
	nop			;76be	00 	. 
	nop			;76bf	00 	. 
	nop			;76c0	00 	. 
	nop			;76c1	00 	. 
	nop			;76c2	00 	. 
	nop			;76c3	00 	. 
	nop			;76c4	00 	. 
	nop			;76c5	00 	. 
	nop			;76c6	00 	. 
	nop			;76c7	00 	. 
	nop			;76c8	00 	. 
	nop			;76c9	00 	. 
	nop			;76ca	00 	. 
	nop			;76cb	00 	. 
	nop			;76cc	00 	. 
	nop			;76cd	00 	. 
	nop			;76ce	00 	. 
	nop			;76cf	00 	. 
	nop			;76d0	00 	. 
	nop			;76d1	00 	. 
	nop			;76d2	00 	. 
	nop			;76d3	00 	. 
	nop			;76d4	00 	. 
	nop			;76d5	00 	. 
	nop			;76d6	00 	. 
	nop			;76d7	00 	. 
	nop			;76d8	00 	. 
	nop			;76d9	00 	. 
	nop			;76da	00 	. 
	nop			;76db	00 	. 
	nop			;76dc	00 	. 
	nop			;76dd	00 	. 
	nop			;76de	00 	. 
	nop			;76df	00 	. 
	nop			;76e0	00 	. 
	nop			;76e1	00 	. 
	nop			;76e2	00 	. 
	nop			;76e3	00 	. 
	nop			;76e4	00 	. 
	nop			;76e5	00 	. 
	nop			;76e6	00 	. 
	nop			;76e7	00 	. 
	nop			;76e8	00 	. 
	nop			;76e9	00 	. 
	nop			;76ea	00 	. 
	nop			;76eb	00 	. 
	nop			;76ec	00 	. 
	nop			;76ed	00 	. 
	nop			;76ee	00 	. 
	nop			;76ef	00 	. 
	nop			;76f0	00 	. 
	nop			;76f1	00 	. 
	nop			;76f2	00 	. 
	nop			;76f3	00 	. 
	nop			;76f4	00 	. 
	nop			;76f5	00 	. 
	nop			;76f6	00 	. 
	nop			;76f7	00 	. 
	nop			;76f8	00 	. 
	nop			;76f9	00 	. 
	nop			;76fa	00 	. 
	nop			;76fb	00 	. 
	nop			;76fc	00 	. 
	nop			;76fd	00 	. 
	nop			;76fe	00 	. 
	nop			;76ff	00 	. 
	nop			;7700	00 	. 
	nop			;7701	00 	. 
	nop			;7702	00 	. 
	nop			;7703	00 	. 
	nop			;7704	00 	. 
	nop			;7705	00 	. 
	nop			;7706	00 	. 
	nop			;7707	00 	. 
	nop			;7708	00 	. 
	nop			;7709	00 	. 
	nop			;770a	00 	. 
	nop			;770b	00 	. 
	nop			;770c	00 	. 
	nop			;770d	00 	. 
	nop			;770e	00 	. 
	nop			;770f	00 	. 
	nop			;7710	00 	. 
	nop			;7711	00 	. 
	nop			;7712	00 	. 
	nop			;7713	00 	. 
	nop			;7714	00 	. 
	nop			;7715	00 	. 
	nop			;7716	00 	. 
	nop			;7717	00 	. 
	nop			;7718	00 	. 
	nop			;7719	00 	. 
	nop			;771a	00 	. 
	nop			;771b	00 	. 
	nop			;771c	00 	. 
	nop			;771d	00 	. 
	nop			;771e	00 	. 
	nop			;771f	00 	. 
	nop			;7720	00 	. 
	nop			;7721	00 	. 
	nop			;7722	00 	. 
	nop			;7723	00 	. 
	nop			;7724	00 	. 
	nop			;7725	00 	. 
	nop			;7726	00 	. 
	nop			;7727	00 	. 
	nop			;7728	00 	. 
	nop			;7729	00 	. 
	nop			;772a	00 	. 
	nop			;772b	00 	. 
	nop			;772c	00 	. 
	nop			;772d	00 	. 
	nop			;772e	00 	. 
	nop			;772f	00 	. 
	nop			;7730	00 	. 
	nop			;7731	00 	. 
	nop			;7732	00 	. 
	nop			;7733	00 	. 
	nop			;7734	00 	. 
	nop			;7735	00 	. 
	nop			;7736	00 	. 
	nop			;7737	00 	. 
	nop			;7738	00 	. 
	nop			;7739	00 	. 
	nop			;773a	00 	. 
	nop			;773b	00 	. 
	nop			;773c	00 	. 
	nop			;773d	00 	. 
	nop			;773e	00 	. 
	nop			;773f	00 	. 
	nop			;7740	00 	. 
	nop			;7741	00 	. 
	nop			;7742	00 	. 
	nop			;7743	00 	. 
	nop			;7744	00 	. 
	nop			;7745	00 	. 
	nop			;7746	00 	. 
	nop			;7747	00 	. 
	nop			;7748	00 	. 
	nop			;7749	00 	. 
	nop			;774a	00 	. 
	nop			;774b	00 	. 
	nop			;774c	00 	. 
	nop			;774d	00 	. 
	nop			;774e	00 	. 
	nop			;774f	00 	. 
	nop			;7750	00 	. 
	nop			;7751	00 	. 
	nop			;7752	00 	. 
	nop			;7753	00 	. 
	nop			;7754	00 	. 
	nop			;7755	00 	. 
	nop			;7756	00 	. 
	nop			;7757	00 	. 
	nop			;7758	00 	. 
	nop			;7759	00 	. 
	nop			;775a	00 	. 
	nop			;775b	00 	. 
	nop			;775c	00 	. 
	nop			;775d	00 	. 
	nop			;775e	00 	. 
	nop			;775f	00 	. 
	nop			;7760	00 	. 
	nop			;7761	00 	. 
	nop			;7762	00 	. 
	nop			;7763	00 	. 
	nop			;7764	00 	. 
	nop			;7765	00 	. 
	nop			;7766	00 	. 
	nop			;7767	00 	. 
	nop			;7768	00 	. 
	nop			;7769	00 	. 
	nop			;776a	00 	. 
	nop			;776b	00 	. 
	nop			;776c	00 	. 
	nop			;776d	00 	. 
	nop			;776e	00 	. 
	nop			;776f	00 	. 
	nop			;7770	00 	. 
	nop			;7771	00 	. 
	nop			;7772	00 	. 
	nop			;7773	00 	. 
	nop			;7774	00 	. 
	nop			;7775	00 	. 
	nop			;7776	00 	. 
	nop			;7777	00 	. 
	nop			;7778	00 	. 
	nop			;7779	00 	. 
	nop			;777a	00 	. 
	nop			;777b	00 	. 
	nop			;777c	00 	. 
	nop			;777d	00 	. 
	nop			;777e	00 	. 
	nop			;777f	00 	. 
	nop			;7780	00 	. 
	nop			;7781	00 	. 
	nop			;7782	00 	. 
	nop			;7783	00 	. 
	nop			;7784	00 	. 
	nop			;7785	00 	. 
	nop			;7786	00 	. 
	nop			;7787	00 	. 
	nop			;7788	00 	. 
	nop			;7789	00 	. 
	nop			;778a	00 	. 
	nop			;778b	00 	. 
	nop			;778c	00 	. 
	nop			;778d	00 	. 
	nop			;778e	00 	. 
	nop			;778f	00 	. 
	nop			;7790	00 	. 
	nop			;7791	00 	. 
	nop			;7792	00 	. 
	nop			;7793	00 	. 
	nop			;7794	00 	. 
	nop			;7795	00 	. 
	nop			;7796	00 	. 
	nop			;7797	00 	. 
	nop			;7798	00 	. 
	nop			;7799	00 	. 
	nop			;779a	00 	. 
	nop			;779b	00 	. 
	nop			;779c	00 	. 
	nop			;779d	00 	. 
	nop			;779e	00 	. 
	nop			;779f	00 	. 
	nop			;77a0	00 	. 
	nop			;77a1	00 	. 
	nop			;77a2	00 	. 
	nop			;77a3	00 	. 
	nop			;77a4	00 	. 
	nop			;77a5	00 	. 
	nop			;77a6	00 	. 
	nop			;77a7	00 	. 
	nop			;77a8	00 	. 
	nop			;77a9	00 	. 
	nop			;77aa	00 	. 
	nop			;77ab	00 	. 
	nop			;77ac	00 	. 
	nop			;77ad	00 	. 
	nop			;77ae	00 	. 
	nop			;77af	00 	. 
	nop			;77b0	00 	. 
	nop			;77b1	00 	. 
	nop			;77b2	00 	. 
	nop			;77b3	00 	. 
	nop			;77b4	00 	. 
	nop			;77b5	00 	. 
	nop			;77b6	00 	. 
	nop			;77b7	00 	. 
	nop			;77b8	00 	. 
	nop			;77b9	00 	. 
	nop			;77ba	00 	. 
	nop			;77bb	00 	. 
	nop			;77bc	00 	. 
	nop			;77bd	00 	. 
	nop			;77be	00 	. 
	nop			;77bf	00 	. 
	nop			;77c0	00 	. 
	nop			;77c1	00 	. 
	nop			;77c2	00 	. 
	nop			;77c3	00 	. 
	nop			;77c4	00 	. 
	nop			;77c5	00 	. 
	nop			;77c6	00 	. 
	nop			;77c7	00 	. 
	nop			;77c8	00 	. 
	nop			;77c9	00 	. 
	nop			;77ca	00 	. 
	nop			;77cb	00 	. 
	nop			;77cc	00 	. 
	nop			;77cd	00 	. 
	nop			;77ce	00 	. 
	nop			;77cf	00 	. 
	nop			;77d0	00 	. 
	nop			;77d1	00 	. 
	nop			;77d2	00 	. 
	nop			;77d3	00 	. 
	nop			;77d4	00 	. 
	nop			;77d5	00 	. 
	nop			;77d6	00 	. 
	nop			;77d7	00 	. 
	nop			;77d8	00 	. 
	nop			;77d9	00 	. 
	nop			;77da	00 	. 
	nop			;77db	00 	. 
	nop			;77dc	00 	. 
	nop			;77dd	00 	. 
	nop			;77de	00 	. 
	nop			;77df	00 	. 
	nop			;77e0	00 	. 
	nop			;77e1	00 	. 
	nop			;77e2	00 	. 
	nop			;77e3	00 	. 
	nop			;77e4	00 	. 
	nop			;77e5	00 	. 
	nop			;77e6	00 	. 
	nop			;77e7	00 	. 
	nop			;77e8	00 	. 
	nop			;77e9	00 	. 
	nop			;77ea	00 	. 
	nop			;77eb	00 	. 
	nop			;77ec	00 	. 
	nop			;77ed	00 	. 
	nop			;77ee	00 	. 
	nop			;77ef	00 	. 
	nop			;77f0	00 	. 
	nop			;77f1	00 	. 
	nop			;77f2	00 	. 
	nop			;77f3	00 	. 
	nop			;77f4	00 	. 
	nop			;77f5	00 	. 
	nop			;77f6	00 	. 
	nop			;77f7	00 	. 
	nop			;77f8	00 	. 
	nop			;77f9	00 	. 
	nop			;77fa	00 	. 
	nop			;77fb	00 	. 
	nop			;77fc	00 	. 
	nop			;77fd	00 	. 
	nop			;77fe	00 	. 
	nop			;77ff	00 	. 
	nop			;7800	00 	. 
	nop			;7801	00 	. 
	nop			;7802	00 	. 
	nop			;7803	00 	. 
	nop			;7804	00 	. 
	nop			;7805	00 	. 
	nop			;7806	00 	. 
	nop			;7807	00 	. 
	nop			;7808	00 	. 
	nop			;7809	00 	. 
	nop			;780a	00 	. 
	nop			;780b	00 	. 
	nop			;780c	00 	. 
	nop			;780d	00 	. 
	nop			;780e	00 	. 
	nop			;780f	00 	. 
	nop			;7810	00 	. 
	nop			;7811	00 	. 
	nop			;7812	00 	. 
	nop			;7813	00 	. 
	nop			;7814	00 	. 
	nop			;7815	00 	. 
	nop			;7816	00 	. 
	nop			;7817	00 	. 
	nop			;7818	00 	. 
	nop			;7819	00 	. 
	nop			;781a	00 	. 
	nop			;781b	00 	. 
	nop			;781c	00 	. 
	nop			;781d	00 	. 
	nop			;781e	00 	. 
	nop			;781f	00 	. 
	nop			;7820	00 	. 
	nop			;7821	00 	. 
	nop			;7822	00 	. 
	nop			;7823	00 	. 
	nop			;7824	00 	. 
	nop			;7825	00 	. 
	nop			;7826	00 	. 
	nop			;7827	00 	. 
	nop			;7828	00 	. 
	nop			;7829	00 	. 
	nop			;782a	00 	. 
	nop			;782b	00 	. 
	nop			;782c	00 	. 
	nop			;782d	00 	. 
	nop			;782e	00 	. 
	nop			;782f	00 	. 
	nop			;7830	00 	. 
	nop			;7831	00 	. 
	nop			;7832	00 	. 
	nop			;7833	00 	. 
	nop			;7834	00 	. 
	nop			;7835	00 	. 
	nop			;7836	00 	. 
	nop			;7837	00 	. 
	nop			;7838	00 	. 
	nop			;7839	00 	. 
	nop			;783a	00 	. 
	nop			;783b	00 	. 
	nop			;783c	00 	. 
	nop			;783d	00 	. 
	nop			;783e	00 	. 
	nop			;783f	00 	. 
	nop			;7840	00 	. 
	nop			;7841	00 	. 
	nop			;7842	00 	. 
	nop			;7843	00 	. 
	nop			;7844	00 	. 
	nop			;7845	00 	. 
	nop			;7846	00 	. 
	nop			;7847	00 	. 
	nop			;7848	00 	. 
	nop			;7849	00 	. 
	nop			;784a	00 	. 
	nop			;784b	00 	. 
	nop			;784c	00 	. 
	nop			;784d	00 	. 
	nop			;784e	00 	. 
	nop			;784f	00 	. 
	nop			;7850	00 	. 
	nop			;7851	00 	. 
	nop			;7852	00 	. 
	nop			;7853	00 	. 
	nop			;7854	00 	. 
	nop			;7855	00 	. 
	nop			;7856	00 	. 
	nop			;7857	00 	. 
	nop			;7858	00 	. 
	nop			;7859	00 	. 
	nop			;785a	00 	. 
	nop			;785b	00 	. 
	nop			;785c	00 	. 
	nop			;785d	00 	. 
	nop			;785e	00 	. 
	nop			;785f	00 	. 
	nop			;7860	00 	. 
	nop			;7861	00 	. 
	nop			;7862	00 	. 
	nop			;7863	00 	. 
	nop			;7864	00 	. 
	nop			;7865	00 	. 
	nop			;7866	00 	. 
	nop			;7867	00 	. 
	nop			;7868	00 	. 
	nop			;7869	00 	. 
	nop			;786a	00 	. 
	nop			;786b	00 	. 
	nop			;786c	00 	. 
	nop			;786d	00 	. 
	nop			;786e	00 	. 
	nop			;786f	00 	. 
	nop			;7870	00 	. 
	nop			;7871	00 	. 
	nop			;7872	00 	. 
	nop			;7873	00 	. 
	nop			;7874	00 	. 
	nop			;7875	00 	. 
	nop			;7876	00 	. 
	nop			;7877	00 	. 
	nop			;7878	00 	. 
	nop			;7879	00 	. 
	nop			;787a	00 	. 
	nop			;787b	00 	. 
	nop			;787c	00 	. 
	nop			;787d	00 	. 
	nop			;787e	00 	. 
	nop			;787f	00 	. 
	nop			;7880	00 	. 
	nop			;7881	00 	. 
	nop			;7882	00 	. 
	nop			;7883	00 	. 
	nop			;7884	00 	. 
	nop			;7885	00 	. 
	nop			;7886	00 	. 
	nop			;7887	00 	. 
	nop			;7888	00 	. 
	nop			;7889	00 	. 
	nop			;788a	00 	. 
	nop			;788b	00 	. 
	nop			;788c	00 	. 
	nop			;788d	00 	. 
	nop			;788e	00 	. 
	nop			;788f	00 	. 
	nop			;7890	00 	. 
	nop			;7891	00 	. 
	nop			;7892	00 	. 
	nop			;7893	00 	. 
	nop			;7894	00 	. 
	nop			;7895	00 	. 
	nop			;7896	00 	. 
	nop			;7897	00 	. 
	nop			;7898	00 	. 
	nop			;7899	00 	. 
	nop			;789a	00 	. 
	nop			;789b	00 	. 
	nop			;789c	00 	. 
	nop			;789d	00 	. 
	nop			;789e	00 	. 
	nop			;789f	00 	. 
	nop			;78a0	00 	. 
	nop			;78a1	00 	. 
	nop			;78a2	00 	. 
	nop			;78a3	00 	. 
	nop			;78a4	00 	. 
	nop			;78a5	00 	. 
	nop			;78a6	00 	. 
	nop			;78a7	00 	. 
	nop			;78a8	00 	. 
	nop			;78a9	00 	. 
	nop			;78aa	00 	. 
	nop			;78ab	00 	. 
	nop			;78ac	00 	. 
	nop			;78ad	00 	. 
	nop			;78ae	00 	. 
	nop			;78af	00 	. 
	nop			;78b0	00 	. 
	nop			;78b1	00 	. 
	nop			;78b2	00 	. 
	nop			;78b3	00 	. 
	nop			;78b4	00 	. 
	nop			;78b5	00 	. 
	nop			;78b6	00 	. 
	nop			;78b7	00 	. 
	nop			;78b8	00 	. 
	nop			;78b9	00 	. 
	nop			;78ba	00 	. 
	nop			;78bb	00 	. 
	nop			;78bc	00 	. 
	nop			;78bd	00 	. 
	nop			;78be	00 	. 
	nop			;78bf	00 	. 
	nop			;78c0	00 	. 
	nop			;78c1	00 	. 
	nop			;78c2	00 	. 
	nop			;78c3	00 	. 
	nop			;78c4	00 	. 
	nop			;78c5	00 	. 
	nop			;78c6	00 	. 
	nop			;78c7	00 	. 
	nop			;78c8	00 	. 
	nop			;78c9	00 	. 
	nop			;78ca	00 	. 
	nop			;78cb	00 	. 
	nop			;78cc	00 	. 
	nop			;78cd	00 	. 
	nop			;78ce	00 	. 
	nop			;78cf	00 	. 
	nop			;78d0	00 	. 
	nop			;78d1	00 	. 
	nop			;78d2	00 	. 
	nop			;78d3	00 	. 
	nop			;78d4	00 	. 
	nop			;78d5	00 	. 
	nop			;78d6	00 	. 
	nop			;78d7	00 	. 
	nop			;78d8	00 	. 
	nop			;78d9	00 	. 
	nop			;78da	00 	. 
	nop			;78db	00 	. 
	nop			;78dc	00 	. 
	nop			;78dd	00 	. 
	nop			;78de	00 	. 
	nop			;78df	00 	. 
	nop			;78e0	00 	. 
	nop			;78e1	00 	. 
	nop			;78e2	00 	. 
	nop			;78e3	00 	. 
	nop			;78e4	00 	. 
	nop			;78e5	00 	. 
	nop			;78e6	00 	. 
	nop			;78e7	00 	. 
	nop			;78e8	00 	. 
	nop			;78e9	00 	. 
	nop			;78ea	00 	. 
	nop			;78eb	00 	. 
	nop			;78ec	00 	. 
	nop			;78ed	00 	. 
	nop			;78ee	00 	. 
	nop			;78ef	00 	. 
	nop			;78f0	00 	. 
	nop			;78f1	00 	. 
	nop			;78f2	00 	. 
	nop			;78f3	00 	. 
	nop			;78f4	00 	. 
	nop			;78f5	00 	. 
	nop			;78f6	00 	. 
	nop			;78f7	00 	. 
	nop			;78f8	00 	. 
	nop			;78f9	00 	. 
	nop			;78fa	00 	. 
	nop			;78fb	00 	. 
	nop			;78fc	00 	. 
	nop			;78fd	00 	. 
	nop			;78fe	00 	. 
	nop			;78ff	00 	. 
	nop			;7900	00 	. 
	nop			;7901	00 	. 
	nop			;7902	00 	. 
	nop			;7903	00 	. 
	nop			;7904	00 	. 
	nop			;7905	00 	. 
	nop			;7906	00 	. 
	nop			;7907	00 	. 
	nop			;7908	00 	. 
	nop			;7909	00 	. 
	nop			;790a	00 	. 
	nop			;790b	00 	. 
	nop			;790c	00 	. 
	nop			;790d	00 	. 
	nop			;790e	00 	. 
	nop			;790f	00 	. 
	nop			;7910	00 	. 
	nop			;7911	00 	. 
	nop			;7912	00 	. 
	nop			;7913	00 	. 
	nop			;7914	00 	. 
	nop			;7915	00 	. 
	nop			;7916	00 	. 
	nop			;7917	00 	. 
	nop			;7918	00 	. 
	nop			;7919	00 	. 
	nop			;791a	00 	. 
	nop			;791b	00 	. 
	nop			;791c	00 	. 
	nop			;791d	00 	. 
	nop			;791e	00 	. 
	nop			;791f	00 	. 
	nop			;7920	00 	. 
	nop			;7921	00 	. 
	nop			;7922	00 	. 
	nop			;7923	00 	. 
	nop			;7924	00 	. 
	nop			;7925	00 	. 
	nop			;7926	00 	. 
	nop			;7927	00 	. 
	nop			;7928	00 	. 
	nop			;7929	00 	. 
	nop			;792a	00 	. 
	nop			;792b	00 	. 
	nop			;792c	00 	. 
	nop			;792d	00 	. 
	nop			;792e	00 	. 
	nop			;792f	00 	. 
	nop			;7930	00 	. 
	nop			;7931	00 	. 
	nop			;7932	00 	. 
	nop			;7933	00 	. 
	nop			;7934	00 	. 
	nop			;7935	00 	. 
	nop			;7936	00 	. 
	nop			;7937	00 	. 
	nop			;7938	00 	. 
	nop			;7939	00 	. 
	nop			;793a	00 	. 
	nop			;793b	00 	. 
	nop			;793c	00 	. 
	nop			;793d	00 	. 
	nop			;793e	00 	. 
	nop			;793f	00 	. 
	nop			;7940	00 	. 
	nop			;7941	00 	. 
	nop			;7942	00 	. 
	nop			;7943	00 	. 
	nop			;7944	00 	. 
	nop			;7945	00 	. 
	nop			;7946	00 	. 
	nop			;7947	00 	. 
	nop			;7948	00 	. 
	nop			;7949	00 	. 
	nop			;794a	00 	. 
	nop			;794b	00 	. 
	nop			;794c	00 	. 
	nop			;794d	00 	. 
	nop			;794e	00 	. 
	nop			;794f	00 	. 
	nop			;7950	00 	. 
	nop			;7951	00 	. 
	nop			;7952	00 	. 
	nop			;7953	00 	. 
	nop			;7954	00 	. 
	nop			;7955	00 	. 
	nop			;7956	00 	. 
	nop			;7957	00 	. 
	nop			;7958	00 	. 
	nop			;7959	00 	. 
	nop			;795a	00 	. 
	nop			;795b	00 	. 
	nop			;795c	00 	. 
	nop			;795d	00 	. 
	nop			;795e	00 	. 
	nop			;795f	00 	. 
	nop			;7960	00 	. 
	nop			;7961	00 	. 
	nop			;7962	00 	. 
	nop			;7963	00 	. 
	nop			;7964	00 	. 
	nop			;7965	00 	. 
	nop			;7966	00 	. 
	nop			;7967	00 	. 
	nop			;7968	00 	. 
	nop			;7969	00 	. 
	nop			;796a	00 	. 
	nop			;796b	00 	. 
	nop			;796c	00 	. 
	nop			;796d	00 	. 
	nop			;796e	00 	. 
	nop			;796f	00 	. 
	nop			;7970	00 	. 
	nop			;7971	00 	. 
	nop			;7972	00 	. 
	nop			;7973	00 	. 
	nop			;7974	00 	. 
	nop			;7975	00 	. 
	nop			;7976	00 	. 
	nop			;7977	00 	. 
	nop			;7978	00 	. 
	nop			;7979	00 	. 
	nop			;797a	00 	. 
	nop			;797b	00 	. 
	nop			;797c	00 	. 
	nop			;797d	00 	. 
	nop			;797e	00 	. 
	nop			;797f	00 	. 
	nop			;7980	00 	. 
	nop			;7981	00 	. 
	nop			;7982	00 	. 
	nop			;7983	00 	. 
	nop			;7984	00 	. 
	nop			;7985	00 	. 
	nop			;7986	00 	. 
	nop			;7987	00 	. 
	nop			;7988	00 	. 
	nop			;7989	00 	. 
	nop			;798a	00 	. 
	nop			;798b	00 	. 
	nop			;798c	00 	. 
	nop			;798d	00 	. 
	nop			;798e	00 	. 
	nop			;798f	00 	. 
	nop			;7990	00 	. 
	nop			;7991	00 	. 
	nop			;7992	00 	. 
	nop			;7993	00 	. 
	nop			;7994	00 	. 
	nop			;7995	00 	. 
	nop			;7996	00 	. 
	nop			;7997	00 	. 
	nop			;7998	00 	. 
	nop			;7999	00 	. 
	nop			;799a	00 	. 
	nop			;799b	00 	. 
	nop			;799c	00 	. 
	nop			;799d	00 	. 
	nop			;799e	00 	. 
	nop			;799f	00 	. 
	nop			;79a0	00 	. 
	nop			;79a1	00 	. 
	nop			;79a2	00 	. 
	nop			;79a3	00 	. 
	nop			;79a4	00 	. 
	nop			;79a5	00 	. 
	nop			;79a6	00 	. 
	nop			;79a7	00 	. 
	nop			;79a8	00 	. 
	nop			;79a9	00 	. 
	nop			;79aa	00 	. 
	nop			;79ab	00 	. 
	nop			;79ac	00 	. 
	nop			;79ad	00 	. 
	nop			;79ae	00 	. 
	nop			;79af	00 	. 
	nop			;79b0	00 	. 
	nop			;79b1	00 	. 
	nop			;79b2	00 	. 
	nop			;79b3	00 	. 
	nop			;79b4	00 	. 
	nop			;79b5	00 	. 
	nop			;79b6	00 	. 
	nop			;79b7	00 	. 
	nop			;79b8	00 	. 
	nop			;79b9	00 	. 
	nop			;79ba	00 	. 
	nop			;79bb	00 	. 
	nop			;79bc	00 	. 
	nop			;79bd	00 	. 
	nop			;79be	00 	. 
	nop			;79bf	00 	. 
	nop			;79c0	00 	. 
	nop			;79c1	00 	. 
	nop			;79c2	00 	. 
	nop			;79c3	00 	. 
	nop			;79c4	00 	. 
	nop			;79c5	00 	. 
	nop			;79c6	00 	. 
	nop			;79c7	00 	. 
	nop			;79c8	00 	. 
	nop			;79c9	00 	. 
	nop			;79ca	00 	. 
	nop			;79cb	00 	. 
	nop			;79cc	00 	. 
	nop			;79cd	00 	. 
	nop			;79ce	00 	. 
	nop			;79cf	00 	. 
	nop			;79d0	00 	. 
	nop			;79d1	00 	. 
	nop			;79d2	00 	. 
	nop			;79d3	00 	. 
	nop			;79d4	00 	. 
	nop			;79d5	00 	. 
	nop			;79d6	00 	. 
	nop			;79d7	00 	. 
	nop			;79d8	00 	. 
	nop			;79d9	00 	. 
	nop			;79da	00 	. 
	nop			;79db	00 	. 
	nop			;79dc	00 	. 
	nop			;79dd	00 	. 
	nop			;79de	00 	. 
	nop			;79df	00 	. 
	nop			;79e0	00 	. 
	nop			;79e1	00 	. 
	nop			;79e2	00 	. 
	nop			;79e3	00 	. 
	nop			;79e4	00 	. 
	nop			;79e5	00 	. 
	nop			;79e6	00 	. 
	nop			;79e7	00 	. 
	nop			;79e8	00 	. 
	nop			;79e9	00 	. 
	nop			;79ea	00 	. 
	nop			;79eb	00 	. 
	nop			;79ec	00 	. 
	nop			;79ed	00 	. 
	nop			;79ee	00 	. 
	nop			;79ef	00 	. 
	nop			;79f0	00 	. 
	nop			;79f1	00 	. 
	nop			;79f2	00 	. 
	nop			;79f3	00 	. 
	nop			;79f4	00 	. 
	nop			;79f5	00 	. 
	nop			;79f6	00 	. 
	nop			;79f7	00 	. 
	nop			;79f8	00 	. 
	nop			;79f9	00 	. 
	nop			;79fa	00 	. 
	nop			;79fb	00 	. 
	nop			;79fc	00 	. 
	nop			;79fd	00 	. 
	nop			;79fe	00 	. 
	nop			;79ff	00 	. 
	nop			;7a00	00 	. 
	nop			;7a01	00 	. 
	nop			;7a02	00 	. 
	nop			;7a03	00 	. 
	nop			;7a04	00 	. 
	nop			;7a05	00 	. 
	nop			;7a06	00 	. 
	nop			;7a07	00 	. 
	nop			;7a08	00 	. 
	nop			;7a09	00 	. 
	nop			;7a0a	00 	. 
	nop			;7a0b	00 	. 
	nop			;7a0c	00 	. 
	nop			;7a0d	00 	. 
	nop			;7a0e	00 	. 
	nop			;7a0f	00 	. 
	nop			;7a10	00 	. 
	nop			;7a11	00 	. 
	nop			;7a12	00 	. 
	nop			;7a13	00 	. 
	nop			;7a14	00 	. 
	nop			;7a15	00 	. 
	nop			;7a16	00 	. 
	nop			;7a17	00 	. 
	nop			;7a18	00 	. 
	nop			;7a19	00 	. 
	nop			;7a1a	00 	. 
	nop			;7a1b	00 	. 
	nop			;7a1c	00 	. 
	nop			;7a1d	00 	. 
	nop			;7a1e	00 	. 
	nop			;7a1f	00 	. 
	nop			;7a20	00 	. 
	nop			;7a21	00 	. 
	nop			;7a22	00 	. 
	nop			;7a23	00 	. 
	nop			;7a24	00 	. 
	nop			;7a25	00 	. 
	nop			;7a26	00 	. 
	nop			;7a27	00 	. 
	nop			;7a28	00 	. 
	nop			;7a29	00 	. 
	nop			;7a2a	00 	. 
	nop			;7a2b	00 	. 
	nop			;7a2c	00 	. 
	nop			;7a2d	00 	. 
	nop			;7a2e	00 	. 
	nop			;7a2f	00 	. 
	nop			;7a30	00 	. 
	nop			;7a31	00 	. 
	nop			;7a32	00 	. 
	nop			;7a33	00 	. 
	nop			;7a34	00 	. 
	nop			;7a35	00 	. 
	nop			;7a36	00 	. 
	nop			;7a37	00 	. 
	nop			;7a38	00 	. 
	nop			;7a39	00 	. 
	nop			;7a3a	00 	. 
	nop			;7a3b	00 	. 
	nop			;7a3c	00 	. 
	nop			;7a3d	00 	. 
	nop			;7a3e	00 	. 
	nop			;7a3f	00 	. 
	nop			;7a40	00 	. 
	nop			;7a41	00 	. 
	nop			;7a42	00 	. 
	nop			;7a43	00 	. 
	nop			;7a44	00 	. 
	nop			;7a45	00 	. 
	nop			;7a46	00 	. 
	nop			;7a47	00 	. 
	nop			;7a48	00 	. 
	nop			;7a49	00 	. 
	nop			;7a4a	00 	. 
	nop			;7a4b	00 	. 
	nop			;7a4c	00 	. 
	nop			;7a4d	00 	. 
	nop			;7a4e	00 	. 
	nop			;7a4f	00 	. 
	nop			;7a50	00 	. 
	nop			;7a51	00 	. 
	nop			;7a52	00 	. 
	nop			;7a53	00 	. 
	nop			;7a54	00 	. 
	nop			;7a55	00 	. 
	nop			;7a56	00 	. 
	nop			;7a57	00 	. 
	nop			;7a58	00 	. 
	nop			;7a59	00 	. 
	nop			;7a5a	00 	. 
	nop			;7a5b	00 	. 
	nop			;7a5c	00 	. 
	nop			;7a5d	00 	. 
	nop			;7a5e	00 	. 
	nop			;7a5f	00 	. 
	nop			;7a60	00 	. 
	nop			;7a61	00 	. 
	nop			;7a62	00 	. 
	nop			;7a63	00 	. 
	nop			;7a64	00 	. 
	nop			;7a65	00 	. 
	nop			;7a66	00 	. 
	nop			;7a67	00 	. 
	nop			;7a68	00 	. 
	nop			;7a69	00 	. 
	nop			;7a6a	00 	. 
	nop			;7a6b	00 	. 
	nop			;7a6c	00 	. 
	nop			;7a6d	00 	. 
	nop			;7a6e	00 	. 
	nop			;7a6f	00 	. 
	nop			;7a70	00 	. 
	nop			;7a71	00 	. 
	nop			;7a72	00 	. 
	nop			;7a73	00 	. 
	nop			;7a74	00 	. 
	nop			;7a75	00 	. 
	nop			;7a76	00 	. 
	nop			;7a77	00 	. 
	nop			;7a78	00 	. 
	nop			;7a79	00 	. 
	nop			;7a7a	00 	. 
	nop			;7a7b	00 	. 
	nop			;7a7c	00 	. 
	nop			;7a7d	00 	. 
	nop			;7a7e	00 	. 
	nop			;7a7f	00 	. 
	nop			;7a80	00 	. 
	nop			;7a81	00 	. 
	nop			;7a82	00 	. 
	nop			;7a83	00 	. 
	nop			;7a84	00 	. 
	nop			;7a85	00 	. 
	nop			;7a86	00 	. 
	nop			;7a87	00 	. 
	nop			;7a88	00 	. 
	nop			;7a89	00 	. 
	nop			;7a8a	00 	. 
	nop			;7a8b	00 	. 
	nop			;7a8c	00 	. 
	nop			;7a8d	00 	. 
	nop			;7a8e	00 	. 
	nop			;7a8f	00 	. 
	nop			;7a90	00 	. 
	nop			;7a91	00 	. 
	nop			;7a92	00 	. 
	nop			;7a93	00 	. 
	nop			;7a94	00 	. 
	nop			;7a95	00 	. 
	nop			;7a96	00 	. 
	nop			;7a97	00 	. 
	nop			;7a98	00 	. 
	nop			;7a99	00 	. 
	nop			;7a9a	00 	. 
	nop			;7a9b	00 	. 
	nop			;7a9c	00 	. 
	nop			;7a9d	00 	. 
	nop			;7a9e	00 	. 
	nop			;7a9f	00 	. 
	nop			;7aa0	00 	. 
	nop			;7aa1	00 	. 
	nop			;7aa2	00 	. 
	nop			;7aa3	00 	. 
	nop			;7aa4	00 	. 
	nop			;7aa5	00 	. 
	nop			;7aa6	00 	. 
	nop			;7aa7	00 	. 
	nop			;7aa8	00 	. 
	nop			;7aa9	00 	. 
	nop			;7aaa	00 	. 
	nop			;7aab	00 	. 
	nop			;7aac	00 	. 
	nop			;7aad	00 	. 
	nop			;7aae	00 	. 
	nop			;7aaf	00 	. 
	nop			;7ab0	00 	. 
	nop			;7ab1	00 	. 
	nop			;7ab2	00 	. 
	nop			;7ab3	00 	. 
	nop			;7ab4	00 	. 
	nop			;7ab5	00 	. 
	nop			;7ab6	00 	. 
	nop			;7ab7	00 	. 
	nop			;7ab8	00 	. 
	nop			;7ab9	00 	. 
	nop			;7aba	00 	. 
	nop			;7abb	00 	. 
	nop			;7abc	00 	. 
	nop			;7abd	00 	. 
	nop			;7abe	00 	. 
	nop			;7abf	00 	. 
	nop			;7ac0	00 	. 
	nop			;7ac1	00 	. 
	nop			;7ac2	00 	. 
	nop			;7ac3	00 	. 
	nop			;7ac4	00 	. 
	nop			;7ac5	00 	. 
	nop			;7ac6	00 	. 
	nop			;7ac7	00 	. 
	nop			;7ac8	00 	. 
	nop			;7ac9	00 	. 
	nop			;7aca	00 	. 
	nop			;7acb	00 	. 
	nop			;7acc	00 	. 
	nop			;7acd	00 	. 
	nop			;7ace	00 	. 
	nop			;7acf	00 	. 
	nop			;7ad0	00 	. 
	nop			;7ad1	00 	. 
	nop			;7ad2	00 	. 
	nop			;7ad3	00 	. 
	nop			;7ad4	00 	. 
	nop			;7ad5	00 	. 
	nop			;7ad6	00 	. 
	nop			;7ad7	00 	. 
	nop			;7ad8	00 	. 
	nop			;7ad9	00 	. 
	nop			;7ada	00 	. 
	nop			;7adb	00 	. 
	nop			;7adc	00 	. 
	nop			;7add	00 	. 
	nop			;7ade	00 	. 
	nop			;7adf	00 	. 
	nop			;7ae0	00 	. 
	nop			;7ae1	00 	. 
	nop			;7ae2	00 	. 
	nop			;7ae3	00 	. 
	nop			;7ae4	00 	. 
	nop			;7ae5	00 	. 
	nop			;7ae6	00 	. 
	nop			;7ae7	00 	. 
	nop			;7ae8	00 	. 
	nop			;7ae9	00 	. 
	nop			;7aea	00 	. 
	nop			;7aeb	00 	. 
	nop			;7aec	00 	. 
	nop			;7aed	00 	. 
	nop			;7aee	00 	. 
	nop			;7aef	00 	. 
	nop			;7af0	00 	. 
	nop			;7af1	00 	. 
	nop			;7af2	00 	. 
	nop			;7af3	00 	. 
	nop			;7af4	00 	. 
	nop			;7af5	00 	. 
	nop			;7af6	00 	. 
	nop			;7af7	00 	. 
	nop			;7af8	00 	. 
	nop			;7af9	00 	. 
	nop			;7afa	00 	. 
	nop			;7afb	00 	. 
	nop			;7afc	00 	. 
	nop			;7afd	00 	. 
	nop			;7afe	00 	. 
	nop			;7aff	00 	. 
	nop			;7b00	00 	. 
	nop			;7b01	00 	. 
	nop			;7b02	00 	. 
	nop			;7b03	00 	. 
	nop			;7b04	00 	. 
	nop			;7b05	00 	. 
	nop			;7b06	00 	. 
	nop			;7b07	00 	. 
	nop			;7b08	00 	. 
	nop			;7b09	00 	. 
	nop			;7b0a	00 	. 
	nop			;7b0b	00 	. 
	nop			;7b0c	00 	. 
	nop			;7b0d	00 	. 
	nop			;7b0e	00 	. 
	nop			;7b0f	00 	. 
	nop			;7b10	00 	. 
	nop			;7b11	00 	. 
	nop			;7b12	00 	. 
	nop			;7b13	00 	. 
	nop			;7b14	00 	. 
	nop			;7b15	00 	. 
	nop			;7b16	00 	. 
	nop			;7b17	00 	. 
	nop			;7b18	00 	. 
	nop			;7b19	00 	. 
	nop			;7b1a	00 	. 
	nop			;7b1b	00 	. 
	nop			;7b1c	00 	. 
	nop			;7b1d	00 	. 
	nop			;7b1e	00 	. 
	nop			;7b1f	00 	. 
	nop			;7b20	00 	. 
	nop			;7b21	00 	. 
	nop			;7b22	00 	. 
	nop			;7b23	00 	. 
	nop			;7b24	00 	. 
	nop			;7b25	00 	. 
	nop			;7b26	00 	. 
	nop			;7b27	00 	. 
	nop			;7b28	00 	. 
	nop			;7b29	00 	. 
	nop			;7b2a	00 	. 
	nop			;7b2b	00 	. 
	nop			;7b2c	00 	. 
	nop			;7b2d	00 	. 
	nop			;7b2e	00 	. 
	nop			;7b2f	00 	. 
	nop			;7b30	00 	. 
	nop			;7b31	00 	. 
	nop			;7b32	00 	. 
	nop			;7b33	00 	. 
	nop			;7b34	00 	. 
	nop			;7b35	00 	. 
	nop			;7b36	00 	. 
	nop			;7b37	00 	. 
	nop			;7b38	00 	. 
	nop			;7b39	00 	. 
	nop			;7b3a	00 	. 
	nop			;7b3b	00 	. 
	nop			;7b3c	00 	. 
	nop			;7b3d	00 	. 
	nop			;7b3e	00 	. 
	nop			;7b3f	00 	. 
	nop			;7b40	00 	. 
	nop			;7b41	00 	. 
	nop			;7b42	00 	. 
	nop			;7b43	00 	. 
	nop			;7b44	00 	. 
	nop			;7b45	00 	. 
	nop			;7b46	00 	. 
	nop			;7b47	00 	. 
	nop			;7b48	00 	. 
	nop			;7b49	00 	. 
	nop			;7b4a	00 	. 
	nop			;7b4b	00 	. 
	nop			;7b4c	00 	. 
	nop			;7b4d	00 	. 
	nop			;7b4e	00 	. 
	nop			;7b4f	00 	. 
	nop			;7b50	00 	. 
	nop			;7b51	00 	. 
	nop			;7b52	00 	. 
	nop			;7b53	00 	. 
	nop			;7b54	00 	. 
	nop			;7b55	00 	. 
	nop			;7b56	00 	. 
	nop			;7b57	00 	. 
	nop			;7b58	00 	. 
	nop			;7b59	00 	. 
	nop			;7b5a	00 	. 
	nop			;7b5b	00 	. 
	nop			;7b5c	00 	. 
	nop			;7b5d	00 	. 
	nop			;7b5e	00 	. 
	nop			;7b5f	00 	. 
	nop			;7b60	00 	. 
	nop			;7b61	00 	. 
	nop			;7b62	00 	. 
	nop			;7b63	00 	. 
	nop			;7b64	00 	. 
	nop			;7b65	00 	. 
	nop			;7b66	00 	. 
	nop			;7b67	00 	. 
	nop			;7b68	00 	. 
	nop			;7b69	00 	. 
	nop			;7b6a	00 	. 
	nop			;7b6b	00 	. 
	nop			;7b6c	00 	. 
	nop			;7b6d	00 	. 
	nop			;7b6e	00 	. 
	nop			;7b6f	00 	. 
	nop			;7b70	00 	. 
	nop			;7b71	00 	. 
	nop			;7b72	00 	. 
	nop			;7b73	00 	. 
	nop			;7b74	00 	. 
	nop			;7b75	00 	. 
	nop			;7b76	00 	. 
	nop			;7b77	00 	. 
	nop			;7b78	00 	. 
	nop			;7b79	00 	. 
	nop			;7b7a	00 	. 
	nop			;7b7b	00 	. 
	nop			;7b7c	00 	. 
	nop			;7b7d	00 	. 
	nop			;7b7e	00 	. 
	nop			;7b7f	00 	. 
	nop			;7b80	00 	. 
	nop			;7b81	00 	. 
	nop			;7b82	00 	. 
	nop			;7b83	00 	. 
	nop			;7b84	00 	. 
	nop			;7b85	00 	. 
	nop			;7b86	00 	. 
	nop			;7b87	00 	. 
	nop			;7b88	00 	. 
	nop			;7b89	00 	. 
	nop			;7b8a	00 	. 
	nop			;7b8b	00 	. 
	nop			;7b8c	00 	. 
	nop			;7b8d	00 	. 
	nop			;7b8e	00 	. 
	nop			;7b8f	00 	. 
	nop			;7b90	00 	. 
	nop			;7b91	00 	. 
	nop			;7b92	00 	. 
	nop			;7b93	00 	. 
	nop			;7b94	00 	. 
	nop			;7b95	00 	. 
	nop			;7b96	00 	. 
	nop			;7b97	00 	. 
	nop			;7b98	00 	. 
	nop			;7b99	00 	. 
	nop			;7b9a	00 	. 
	nop			;7b9b	00 	. 
	nop			;7b9c	00 	. 
	nop			;7b9d	00 	. 
	nop			;7b9e	00 	. 
	nop			;7b9f	00 	. 
	nop			;7ba0	00 	. 
	nop			;7ba1	00 	. 
	nop			;7ba2	00 	. 
	nop			;7ba3	00 	. 
	nop			;7ba4	00 	. 
	nop			;7ba5	00 	. 
	nop			;7ba6	00 	. 
	nop			;7ba7	00 	. 
	nop			;7ba8	00 	. 
	nop			;7ba9	00 	. 
	nop			;7baa	00 	. 
	nop			;7bab	00 	. 
	nop			;7bac	00 	. 
	nop			;7bad	00 	. 
	nop			;7bae	00 	. 
	nop			;7baf	00 	. 
	nop			;7bb0	00 	. 
	nop			;7bb1	00 	. 
	nop			;7bb2	00 	. 
	nop			;7bb3	00 	. 
	nop			;7bb4	00 	. 
	nop			;7bb5	00 	. 
	nop			;7bb6	00 	. 
	nop			;7bb7	00 	. 
	nop			;7bb8	00 	. 
	nop			;7bb9	00 	. 
	nop			;7bba	00 	. 
	nop			;7bbb	00 	. 
	nop			;7bbc	00 	. 
	nop			;7bbd	00 	. 
	nop			;7bbe	00 	. 
	nop			;7bbf	00 	. 
	nop			;7bc0	00 	. 
	nop			;7bc1	00 	. 
	nop			;7bc2	00 	. 
	nop			;7bc3	00 	. 
	nop			;7bc4	00 	. 
	nop			;7bc5	00 	. 
	nop			;7bc6	00 	. 
	nop			;7bc7	00 	. 
	nop			;7bc8	00 	. 
	nop			;7bc9	00 	. 
	nop			;7bca	00 	. 
	nop			;7bcb	00 	. 
	nop			;7bcc	00 	. 
	nop			;7bcd	00 	. 
	nop			;7bce	00 	. 
	nop			;7bcf	00 	. 
	nop			;7bd0	00 	. 
	nop			;7bd1	00 	. 
	nop			;7bd2	00 	. 
	nop			;7bd3	00 	. 
	nop			;7bd4	00 	. 
	nop			;7bd5	00 	. 
	nop			;7bd6	00 	. 
	nop			;7bd7	00 	. 
	nop			;7bd8	00 	. 
	nop			;7bd9	00 	. 
	nop			;7bda	00 	. 
	nop			;7bdb	00 	. 
	nop			;7bdc	00 	. 
	nop			;7bdd	00 	. 
	nop			;7bde	00 	. 
	nop			;7bdf	00 	. 
	nop			;7be0	00 	. 
	nop			;7be1	00 	. 
	nop			;7be2	00 	. 
	nop			;7be3	00 	. 
	nop			;7be4	00 	. 
	nop			;7be5	00 	. 
	nop			;7be6	00 	. 
	nop			;7be7	00 	. 
	nop			;7be8	00 	. 
	nop			;7be9	00 	. 
	nop			;7bea	00 	. 
	nop			;7beb	00 	. 
	nop			;7bec	00 	. 
	nop			;7bed	00 	. 
	nop			;7bee	00 	. 
	nop			;7bef	00 	. 
	nop			;7bf0	00 	. 
	nop			;7bf1	00 	. 
	nop			;7bf2	00 	. 
	nop			;7bf3	00 	. 
	nop			;7bf4	00 	. 
	nop			;7bf5	00 	. 
	nop			;7bf6	00 	. 
	nop			;7bf7	00 	. 
	nop			;7bf8	00 	. 
	nop			;7bf9	00 	. 
	nop			;7bfa	00 	. 
	nop			;7bfb	00 	. 
	nop			;7bfc	00 	. 
	nop			;7bfd	00 	. 
	nop			;7bfe	00 	. 
	nop			;7bff	00 	. 
	nop			;7c00	00 	. 
	nop			;7c01	00 	. 
	nop			;7c02	00 	. 
	nop			;7c03	00 	. 
	nop			;7c04	00 	. 
	nop			;7c05	00 	. 
	nop			;7c06	00 	. 
	nop			;7c07	00 	. 
	nop			;7c08	00 	. 
	nop			;7c09	00 	. 
	nop			;7c0a	00 	. 
	nop			;7c0b	00 	. 
	nop			;7c0c	00 	. 
	nop			;7c0d	00 	. 
	nop			;7c0e	00 	. 
	nop			;7c0f	00 	. 
	nop			;7c10	00 	. 
	nop			;7c11	00 	. 
	nop			;7c12	00 	. 
	nop			;7c13	00 	. 
	nop			;7c14	00 	. 
	nop			;7c15	00 	. 
	nop			;7c16	00 	. 
	nop			;7c17	00 	. 
	nop			;7c18	00 	. 
	nop			;7c19	00 	. 
	nop			;7c1a	00 	. 
	nop			;7c1b	00 	. 
	nop			;7c1c	00 	. 
	nop			;7c1d	00 	. 
	nop			;7c1e	00 	. 
	nop			;7c1f	00 	. 
	nop			;7c20	00 	. 
	nop			;7c21	00 	. 
	nop			;7c22	00 	. 
	nop			;7c23	00 	. 
	nop			;7c24	00 	. 
	nop			;7c25	00 	. 
	nop			;7c26	00 	. 
	nop			;7c27	00 	. 
	nop			;7c28	00 	. 
	nop			;7c29	00 	. 
	nop			;7c2a	00 	. 
	nop			;7c2b	00 	. 
	nop			;7c2c	00 	. 
	nop			;7c2d	00 	. 
	nop			;7c2e	00 	. 
	nop			;7c2f	00 	. 
	nop			;7c30	00 	. 
	nop			;7c31	00 	. 
	nop			;7c32	00 	. 
	nop			;7c33	00 	. 
	nop			;7c34	00 	. 
	nop			;7c35	00 	. 
	nop			;7c36	00 	. 
	nop			;7c37	00 	. 
	nop			;7c38	00 	. 
	nop			;7c39	00 	. 
	nop			;7c3a	00 	. 
	nop			;7c3b	00 	. 
	nop			;7c3c	00 	. 
	nop			;7c3d	00 	. 
	nop			;7c3e	00 	. 
	nop			;7c3f	00 	. 
	nop			;7c40	00 	. 
	nop			;7c41	00 	. 
	nop			;7c42	00 	. 
	nop			;7c43	00 	. 
	nop			;7c44	00 	. 
	nop			;7c45	00 	. 
	nop			;7c46	00 	. 
	nop			;7c47	00 	. 
	nop			;7c48	00 	. 
	nop			;7c49	00 	. 
	nop			;7c4a	00 	. 
	nop			;7c4b	00 	. 
	nop			;7c4c	00 	. 
	nop			;7c4d	00 	. 
	nop			;7c4e	00 	. 
	nop			;7c4f	00 	. 
	nop			;7c50	00 	. 
	nop			;7c51	00 	. 
	nop			;7c52	00 	. 
	nop			;7c53	00 	. 
	nop			;7c54	00 	. 
	nop			;7c55	00 	. 
	nop			;7c56	00 	. 
	nop			;7c57	00 	. 
	nop			;7c58	00 	. 
	nop			;7c59	00 	. 
	nop			;7c5a	00 	. 
	nop			;7c5b	00 	. 
	nop			;7c5c	00 	. 
	nop			;7c5d	00 	. 
	nop			;7c5e	00 	. 
	nop			;7c5f	00 	. 
	nop			;7c60	00 	. 
	nop			;7c61	00 	. 
	nop			;7c62	00 	. 
	nop			;7c63	00 	. 
	nop			;7c64	00 	. 
	nop			;7c65	00 	. 
	nop			;7c66	00 	. 
	nop			;7c67	00 	. 
	nop			;7c68	00 	. 
	nop			;7c69	00 	. 
	nop			;7c6a	00 	. 
	nop			;7c6b	00 	. 
	nop			;7c6c	00 	. 
	nop			;7c6d	00 	. 
	nop			;7c6e	00 	. 
	nop			;7c6f	00 	. 
	nop			;7c70	00 	. 
	nop			;7c71	00 	. 
	nop			;7c72	00 	. 
	nop			;7c73	00 	. 
	nop			;7c74	00 	. 
	nop			;7c75	00 	. 
	nop			;7c76	00 	. 
	nop			;7c77	00 	. 
	nop			;7c78	00 	. 
	nop			;7c79	00 	. 
	nop			;7c7a	00 	. 
	nop			;7c7b	00 	. 
	nop			;7c7c	00 	. 
	nop			;7c7d	00 	. 
	nop			;7c7e	00 	. 
	nop			;7c7f	00 	. 
	nop			;7c80	00 	. 
	nop			;7c81	00 	. 
	nop			;7c82	00 	. 
	nop			;7c83	00 	. 
	nop			;7c84	00 	. 
	nop			;7c85	00 	. 
	nop			;7c86	00 	. 
	nop			;7c87	00 	. 
	nop			;7c88	00 	. 
	nop			;7c89	00 	. 
	nop			;7c8a	00 	. 
	nop			;7c8b	00 	. 
	nop			;7c8c	00 	. 
	nop			;7c8d	00 	. 
	nop			;7c8e	00 	. 
	nop			;7c8f	00 	. 
	nop			;7c90	00 	. 
	nop			;7c91	00 	. 
	nop			;7c92	00 	. 
	nop			;7c93	00 	. 
	nop			;7c94	00 	. 
	nop			;7c95	00 	. 
	nop			;7c96	00 	. 
	nop			;7c97	00 	. 
	nop			;7c98	00 	. 
	nop			;7c99	00 	. 
	nop			;7c9a	00 	. 
	nop			;7c9b	00 	. 
	nop			;7c9c	00 	. 
	nop			;7c9d	00 	. 
	nop			;7c9e	00 	. 
	nop			;7c9f	00 	. 
	nop			;7ca0	00 	. 
	nop			;7ca1	00 	. 
	nop			;7ca2	00 	. 
	nop			;7ca3	00 	. 
	nop			;7ca4	00 	. 
	nop			;7ca5	00 	. 
	nop			;7ca6	00 	. 
	nop			;7ca7	00 	. 
	nop			;7ca8	00 	. 
	nop			;7ca9	00 	. 
	nop			;7caa	00 	. 
	nop			;7cab	00 	. 
	nop			;7cac	00 	. 
	nop			;7cad	00 	. 
	nop			;7cae	00 	. 
	nop			;7caf	00 	. 
	nop			;7cb0	00 	. 
	nop			;7cb1	00 	. 
	nop			;7cb2	00 	. 
	nop			;7cb3	00 	. 
	nop			;7cb4	00 	. 
	nop			;7cb5	00 	. 
	nop			;7cb6	00 	. 
	nop			;7cb7	00 	. 
	nop			;7cb8	00 	. 
	nop			;7cb9	00 	. 
	nop			;7cba	00 	. 
	nop			;7cbb	00 	. 
	nop			;7cbc	00 	. 
	nop			;7cbd	00 	. 
	nop			;7cbe	00 	. 
	nop			;7cbf	00 	. 
	nop			;7cc0	00 	. 
	nop			;7cc1	00 	. 
	nop			;7cc2	00 	. 
	nop			;7cc3	00 	. 
	nop			;7cc4	00 	. 
	nop			;7cc5	00 	. 
	nop			;7cc6	00 	. 
	nop			;7cc7	00 	. 
	nop			;7cc8	00 	. 
	nop			;7cc9	00 	. 
	nop			;7cca	00 	. 
	nop			;7ccb	00 	. 
	nop			;7ccc	00 	. 
	nop			;7ccd	00 	. 
	nop			;7cce	00 	. 
	nop			;7ccf	00 	. 
	nop			;7cd0	00 	. 
	nop			;7cd1	00 	. 
	nop			;7cd2	00 	. 
	nop			;7cd3	00 	. 
	nop			;7cd4	00 	. 
	nop			;7cd5	00 	. 
	nop			;7cd6	00 	. 
	nop			;7cd7	00 	. 
	nop			;7cd8	00 	. 
	nop			;7cd9	00 	. 
	nop			;7cda	00 	. 
	nop			;7cdb	00 	. 
	nop			;7cdc	00 	. 
	nop			;7cdd	00 	. 
	nop			;7cde	00 	. 
	nop			;7cdf	00 	. 
	nop			;7ce0	00 	. 
	nop			;7ce1	00 	. 
	nop			;7ce2	00 	. 
	nop			;7ce3	00 	. 
	nop			;7ce4	00 	. 
	nop			;7ce5	00 	. 
	nop			;7ce6	00 	. 
	nop			;7ce7	00 	. 
	nop			;7ce8	00 	. 
	nop			;7ce9	00 	. 
	nop			;7cea	00 	. 
	nop			;7ceb	00 	. 
	nop			;7cec	00 	. 
	nop			;7ced	00 	. 
	nop			;7cee	00 	. 
	nop			;7cef	00 	. 
	nop			;7cf0	00 	. 
	nop			;7cf1	00 	. 
	nop			;7cf2	00 	. 
	nop			;7cf3	00 	. 
	nop			;7cf4	00 	. 
	nop			;7cf5	00 	. 
	nop			;7cf6	00 	. 
	nop			;7cf7	00 	. 
	nop			;7cf8	00 	. 
	nop			;7cf9	00 	. 
	nop			;7cfa	00 	. 
	nop			;7cfb	00 	. 
	nop			;7cfc	00 	. 
	nop			;7cfd	00 	. 
	nop			;7cfe	00 	. 
	nop			;7cff	00 	. 
	nop			;7d00	00 	. 
	nop			;7d01	00 	. 
	nop			;7d02	00 	. 
	nop			;7d03	00 	. 
	nop			;7d04	00 	. 
	nop			;7d05	00 	. 
	nop			;7d06	00 	. 
	nop			;7d07	00 	. 
	nop			;7d08	00 	. 
	nop			;7d09	00 	. 
	nop			;7d0a	00 	. 
	nop			;7d0b	00 	. 
	nop			;7d0c	00 	. 
	nop			;7d0d	00 	. 
	nop			;7d0e	00 	. 
	nop			;7d0f	00 	. 
	nop			;7d10	00 	. 
	nop			;7d11	00 	. 
	nop			;7d12	00 	. 
	nop			;7d13	00 	. 
	nop			;7d14	00 	. 
	nop			;7d15	00 	. 
	nop			;7d16	00 	. 
	nop			;7d17	00 	. 
	nop			;7d18	00 	. 
	nop			;7d19	00 	. 
	nop			;7d1a	00 	. 
	nop			;7d1b	00 	. 
	nop			;7d1c	00 	. 
	nop			;7d1d	00 	. 
	nop			;7d1e	00 	. 
	nop			;7d1f	00 	. 
	nop			;7d20	00 	. 
	nop			;7d21	00 	. 
	nop			;7d22	00 	. 
	nop			;7d23	00 	. 
	nop			;7d24	00 	. 
	nop			;7d25	00 	. 
	nop			;7d26	00 	. 
	nop			;7d27	00 	. 
	nop			;7d28	00 	. 
	nop			;7d29	00 	. 
	nop			;7d2a	00 	. 
	nop			;7d2b	00 	. 
	nop			;7d2c	00 	. 
	nop			;7d2d	00 	. 
	nop			;7d2e	00 	. 
	nop			;7d2f	00 	. 
	nop			;7d30	00 	. 
	nop			;7d31	00 	. 
	nop			;7d32	00 	. 
	nop			;7d33	00 	. 
	nop			;7d34	00 	. 
	nop			;7d35	00 	. 
	nop			;7d36	00 	. 
	nop			;7d37	00 	. 
	nop			;7d38	00 	. 
	nop			;7d39	00 	. 
	nop			;7d3a	00 	. 
	nop			;7d3b	00 	. 
	nop			;7d3c	00 	. 
	nop			;7d3d	00 	. 
	nop			;7d3e	00 	. 
	nop			;7d3f	00 	. 
	nop			;7d40	00 	. 
	nop			;7d41	00 	. 
	nop			;7d42	00 	. 
	nop			;7d43	00 	. 
	nop			;7d44	00 	. 
	nop			;7d45	00 	. 
	nop			;7d46	00 	. 
	nop			;7d47	00 	. 
	nop			;7d48	00 	. 
	nop			;7d49	00 	. 
	nop			;7d4a	00 	. 
	nop			;7d4b	00 	. 
	nop			;7d4c	00 	. 
	nop			;7d4d	00 	. 
	nop			;7d4e	00 	. 
	nop			;7d4f	00 	. 
	nop			;7d50	00 	. 
	nop			;7d51	00 	. 
	nop			;7d52	00 	. 
	nop			;7d53	00 	. 
	nop			;7d54	00 	. 
	nop			;7d55	00 	. 
	nop			;7d56	00 	. 
	nop			;7d57	00 	. 
	nop			;7d58	00 	. 
	nop			;7d59	00 	. 
	nop			;7d5a	00 	. 
	nop			;7d5b	00 	. 
	nop			;7d5c	00 	. 
	nop			;7d5d	00 	. 
	nop			;7d5e	00 	. 
	nop			;7d5f	00 	. 
	nop			;7d60	00 	. 
	nop			;7d61	00 	. 
	nop			;7d62	00 	. 
	nop			;7d63	00 	. 
	nop			;7d64	00 	. 
	nop			;7d65	00 	. 
	nop			;7d66	00 	. 
	nop			;7d67	00 	. 
	nop			;7d68	00 	. 
	nop			;7d69	00 	. 
	nop			;7d6a	00 	. 
	nop			;7d6b	00 	. 
	nop			;7d6c	00 	. 
	nop			;7d6d	00 	. 
	nop			;7d6e	00 	. 
	nop			;7d6f	00 	. 
	nop			;7d70	00 	. 
	nop			;7d71	00 	. 
	nop			;7d72	00 	. 
	nop			;7d73	00 	. 
	nop			;7d74	00 	. 
	nop			;7d75	00 	. 
	nop			;7d76	00 	. 
	nop			;7d77	00 	. 
	nop			;7d78	00 	. 
	nop			;7d79	00 	. 
	nop			;7d7a	00 	. 
	nop			;7d7b	00 	. 
	nop			;7d7c	00 	. 
	nop			;7d7d	00 	. 
	nop			;7d7e	00 	. 
	nop			;7d7f	00 	. 
	nop			;7d80	00 	. 
	nop			;7d81	00 	. 
	nop			;7d82	00 	. 
	nop			;7d83	00 	. 
	nop			;7d84	00 	. 
	nop			;7d85	00 	. 
	nop			;7d86	00 	. 
	nop			;7d87	00 	. 
	nop			;7d88	00 	. 
	nop			;7d89	00 	. 
	nop			;7d8a	00 	. 
	nop			;7d8b	00 	. 
	nop			;7d8c	00 	. 
	nop			;7d8d	00 	. 
	nop			;7d8e	00 	. 
	nop			;7d8f	00 	. 
	nop			;7d90	00 	. 
	nop			;7d91	00 	. 
	nop			;7d92	00 	. 
	nop			;7d93	00 	. 
	nop			;7d94	00 	. 
	nop			;7d95	00 	. 
	nop			;7d96	00 	. 
	nop			;7d97	00 	. 
	nop			;7d98	00 	. 
	nop			;7d99	00 	. 
	nop			;7d9a	00 	. 
	nop			;7d9b	00 	. 
	nop			;7d9c	00 	. 
	nop			;7d9d	00 	. 
	nop			;7d9e	00 	. 
	nop			;7d9f	00 	. 
	nop			;7da0	00 	. 
	nop			;7da1	00 	. 
	nop			;7da2	00 	. 
	nop			;7da3	00 	. 
	nop			;7da4	00 	. 
	nop			;7da5	00 	. 
	nop			;7da6	00 	. 
	nop			;7da7	00 	. 
	nop			;7da8	00 	. 
	nop			;7da9	00 	. 
	nop			;7daa	00 	. 
	nop			;7dab	00 	. 
	nop			;7dac	00 	. 
	nop			;7dad	00 	. 
	nop			;7dae	00 	. 
	nop			;7daf	00 	. 
	nop			;7db0	00 	. 
	nop			;7db1	00 	. 
	nop			;7db2	00 	. 
	nop			;7db3	00 	. 
	nop			;7db4	00 	. 
	nop			;7db5	00 	. 
	nop			;7db6	00 	. 
	nop			;7db7	00 	. 
	nop			;7db8	00 	. 
	nop			;7db9	00 	. 
	nop			;7dba	00 	. 
	nop			;7dbb	00 	. 
	nop			;7dbc	00 	. 
	nop			;7dbd	00 	. 
	nop			;7dbe	00 	. 
	nop			;7dbf	00 	. 
	nop			;7dc0	00 	. 
	nop			;7dc1	00 	. 
	nop			;7dc2	00 	. 
	nop			;7dc3	00 	. 
	nop			;7dc4	00 	. 
	nop			;7dc5	00 	. 
	nop			;7dc6	00 	. 
	nop			;7dc7	00 	. 
	nop			;7dc8	00 	. 
	nop			;7dc9	00 	. 
	nop			;7dca	00 	. 
	nop			;7dcb	00 	. 
	nop			;7dcc	00 	. 
	nop			;7dcd	00 	. 
	nop			;7dce	00 	. 
	nop			;7dcf	00 	. 
	nop			;7dd0	00 	. 
	nop			;7dd1	00 	. 
	nop			;7dd2	00 	. 
	nop			;7dd3	00 	. 
	nop			;7dd4	00 	. 
	nop			;7dd5	00 	. 
	nop			;7dd6	00 	. 
	nop			;7dd7	00 	. 
	nop			;7dd8	00 	. 
	nop			;7dd9	00 	. 
	nop			;7dda	00 	. 
	nop			;7ddb	00 	. 
	nop			;7ddc	00 	. 
	nop			;7ddd	00 	. 
	nop			;7dde	00 	. 
	nop			;7ddf	00 	. 
	nop			;7de0	00 	. 
	nop			;7de1	00 	. 
	nop			;7de2	00 	. 
	nop			;7de3	00 	. 
	nop			;7de4	00 	. 
	nop			;7de5	00 	. 
	nop			;7de6	00 	. 
	nop			;7de7	00 	. 
	nop			;7de8	00 	. 
	nop			;7de9	00 	. 
	nop			;7dea	00 	. 
	nop			;7deb	00 	. 
	nop			;7dec	00 	. 
	nop			;7ded	00 	. 
	nop			;7dee	00 	. 
	nop			;7def	00 	. 
	nop			;7df0	00 	. 
	nop			;7df1	00 	. 
	nop			;7df2	00 	. 
	nop			;7df3	00 	. 
	nop			;7df4	00 	. 
	nop			;7df5	00 	. 
	nop			;7df6	00 	. 
	nop			;7df7	00 	. 
	nop			;7df8	00 	. 
	nop			;7df9	00 	. 
	nop			;7dfa	00 	. 
	nop			;7dfb	00 	. 
	nop			;7dfc	00 	. 
	nop			;7dfd	00 	. 
	nop			;7dfe	00 	. 
	nop			;7dff	00 	. 
	nop			;7e00	00 	. 
	nop			;7e01	00 	. 
	nop			;7e02	00 	. 
	nop			;7e03	00 	. 
	nop			;7e04	00 	. 
	nop			;7e05	00 	. 
	nop			;7e06	00 	. 
	nop			;7e07	00 	. 
	nop			;7e08	00 	. 
	nop			;7e09	00 	. 
	nop			;7e0a	00 	. 
	nop			;7e0b	00 	. 
	nop			;7e0c	00 	. 
	nop			;7e0d	00 	. 
	nop			;7e0e	00 	. 
	nop			;7e0f	00 	. 
	nop			;7e10	00 	. 
	nop			;7e11	00 	. 
	nop			;7e12	00 	. 
	nop			;7e13	00 	. 
	nop			;7e14	00 	. 
	nop			;7e15	00 	. 
	nop			;7e16	00 	. 
	nop			;7e17	00 	. 
	nop			;7e18	00 	. 
	nop			;7e19	00 	. 
	nop			;7e1a	00 	. 
	nop			;7e1b	00 	. 
	nop			;7e1c	00 	. 
	nop			;7e1d	00 	. 
	nop			;7e1e	00 	. 
	nop			;7e1f	00 	. 
	nop			;7e20	00 	. 
	nop			;7e21	00 	. 
	nop			;7e22	00 	. 
	nop			;7e23	00 	. 
	nop			;7e24	00 	. 
	nop			;7e25	00 	. 
	nop			;7e26	00 	. 
	nop			;7e27	00 	. 
	nop			;7e28	00 	. 
	nop			;7e29	00 	. 
	nop			;7e2a	00 	. 
	nop			;7e2b	00 	. 
	nop			;7e2c	00 	. 
	nop			;7e2d	00 	. 
	nop			;7e2e	00 	. 
	nop			;7e2f	00 	. 
	nop			;7e30	00 	. 
	nop			;7e31	00 	. 
	nop			;7e32	00 	. 
	nop			;7e33	00 	. 
	nop			;7e34	00 	. 
	nop			;7e35	00 	. 
	nop			;7e36	00 	. 
	nop			;7e37	00 	. 
	nop			;7e38	00 	. 
	nop			;7e39	00 	. 
	nop			;7e3a	00 	. 
	nop			;7e3b	00 	. 
	nop			;7e3c	00 	. 
	nop			;7e3d	00 	. 
	nop			;7e3e	00 	. 
	nop			;7e3f	00 	. 
	nop			;7e40	00 	. 
	nop			;7e41	00 	. 
	nop			;7e42	00 	. 
	nop			;7e43	00 	. 
	nop			;7e44	00 	. 
	nop			;7e45	00 	. 
	nop			;7e46	00 	. 
	nop			;7e47	00 	. 
	nop			;7e48	00 	. 
	nop			;7e49	00 	. 
	nop			;7e4a	00 	. 
	nop			;7e4b	00 	. 
	nop			;7e4c	00 	. 
	nop			;7e4d	00 	. 
	nop			;7e4e	00 	. 
	nop			;7e4f	00 	. 
	nop			;7e50	00 	. 
	nop			;7e51	00 	. 
	nop			;7e52	00 	. 
	nop			;7e53	00 	. 
	nop			;7e54	00 	. 
	nop			;7e55	00 	. 
	nop			;7e56	00 	. 
	nop			;7e57	00 	. 
	nop			;7e58	00 	. 
	nop			;7e59	00 	. 
	nop			;7e5a	00 	. 
	nop			;7e5b	00 	. 
	nop			;7e5c	00 	. 
	nop			;7e5d	00 	. 
	nop			;7e5e	00 	. 
	nop			;7e5f	00 	. 
	nop			;7e60	00 	. 
	nop			;7e61	00 	. 
	nop			;7e62	00 	. 
	nop			;7e63	00 	. 
	nop			;7e64	00 	. 
	nop			;7e65	00 	. 
	nop			;7e66	00 	. 
	nop			;7e67	00 	. 
	nop			;7e68	00 	. 
	nop			;7e69	00 	. 
	nop			;7e6a	00 	. 
	nop			;7e6b	00 	. 
	nop			;7e6c	00 	. 
	nop			;7e6d	00 	. 
	nop			;7e6e	00 	. 
	nop			;7e6f	00 	. 
	nop			;7e70	00 	. 
	nop			;7e71	00 	. 
	nop			;7e72	00 	. 
	nop			;7e73	00 	. 
	nop			;7e74	00 	. 
	nop			;7e75	00 	. 
	nop			;7e76	00 	. 
	nop			;7e77	00 	. 
	nop			;7e78	00 	. 
	nop			;7e79	00 	. 
	nop			;7e7a	00 	. 
	nop			;7e7b	00 	. 
	nop			;7e7c	00 	. 
	nop			;7e7d	00 	. 
	nop			;7e7e	00 	. 
	nop			;7e7f	00 	. 
	nop			;7e80	00 	. 
	nop			;7e81	00 	. 
	nop			;7e82	00 	. 
	nop			;7e83	00 	. 
	nop			;7e84	00 	. 
	nop			;7e85	00 	. 
	nop			;7e86	00 	. 
	nop			;7e87	00 	. 
	nop			;7e88	00 	. 
	nop			;7e89	00 	. 
	nop			;7e8a	00 	. 
	nop			;7e8b	00 	. 
	nop			;7e8c	00 	. 
	nop			;7e8d	00 	. 
	nop			;7e8e	00 	. 
	nop			;7e8f	00 	. 
	nop			;7e90	00 	. 
	nop			;7e91	00 	. 
	nop			;7e92	00 	. 
	nop			;7e93	00 	. 
	nop			;7e94	00 	. 
	nop			;7e95	00 	. 
	nop			;7e96	00 	. 
	nop			;7e97	00 	. 
	nop			;7e98	00 	. 
	nop			;7e99	00 	. 
	nop			;7e9a	00 	. 
	nop			;7e9b	00 	. 
	nop			;7e9c	00 	. 
	nop			;7e9d	00 	. 
	nop			;7e9e	00 	. 
	nop			;7e9f	00 	. 
	nop			;7ea0	00 	. 
	nop			;7ea1	00 	. 
	nop			;7ea2	00 	. 
	nop			;7ea3	00 	. 
	nop			;7ea4	00 	. 
	nop			;7ea5	00 	. 
	nop			;7ea6	00 	. 
	nop			;7ea7	00 	. 
	nop			;7ea8	00 	. 
	nop			;7ea9	00 	. 
	nop			;7eaa	00 	. 
	nop			;7eab	00 	. 
	nop			;7eac	00 	. 
	nop			;7ead	00 	. 
	nop			;7eae	00 	. 
	nop			;7eaf	00 	. 
	nop			;7eb0	00 	. 
	nop			;7eb1	00 	. 
	nop			;7eb2	00 	. 
	nop			;7eb3	00 	. 
	nop			;7eb4	00 	. 
	nop			;7eb5	00 	. 
	nop			;7eb6	00 	. 
	nop			;7eb7	00 	. 
	nop			;7eb8	00 	. 
	nop			;7eb9	00 	. 
	nop			;7eba	00 	. 
	nop			;7ebb	00 	. 
	nop			;7ebc	00 	. 
	nop			;7ebd	00 	. 
	nop			;7ebe	00 	. 
	nop			;7ebf	00 	. 
	nop			;7ec0	00 	. 
	nop			;7ec1	00 	. 
	nop			;7ec2	00 	. 
	nop			;7ec3	00 	. 
	nop			;7ec4	00 	. 
	nop			;7ec5	00 	. 
	nop			;7ec6	00 	. 
	nop			;7ec7	00 	. 
	nop			;7ec8	00 	. 
	nop			;7ec9	00 	. 
	nop			;7eca	00 	. 
	nop			;7ecb	00 	. 
	nop			;7ecc	00 	. 
	nop			;7ecd	00 	. 
	nop			;7ece	00 	. 
	nop			;7ecf	00 	. 
	nop			;7ed0	00 	. 
	nop			;7ed1	00 	. 
	nop			;7ed2	00 	. 
	nop			;7ed3	00 	. 
	nop			;7ed4	00 	. 
	nop			;7ed5	00 	. 
	nop			;7ed6	00 	. 
	nop			;7ed7	00 	. 
	nop			;7ed8	00 	. 
	nop			;7ed9	00 	. 
	nop			;7eda	00 	. 
	nop			;7edb	00 	. 
	nop			;7edc	00 	. 
	nop			;7edd	00 	. 
	nop			;7ede	00 	. 
	nop			;7edf	00 	. 
	nop			;7ee0	00 	. 
	nop			;7ee1	00 	. 
	nop			;7ee2	00 	. 
	nop			;7ee3	00 	. 
	nop			;7ee4	00 	. 
	nop			;7ee5	00 	. 
	nop			;7ee6	00 	. 
	nop			;7ee7	00 	. 
	nop			;7ee8	00 	. 
	nop			;7ee9	00 	. 
	nop			;7eea	00 	. 
	nop			;7eeb	00 	. 
	nop			;7eec	00 	. 
	nop			;7eed	00 	. 
	nop			;7eee	00 	. 
	nop			;7eef	00 	. 
	nop			;7ef0	00 	. 
	nop			;7ef1	00 	. 
	nop			;7ef2	00 	. 
	nop			;7ef3	00 	. 
	nop			;7ef4	00 	. 
	nop			;7ef5	00 	. 
	nop			;7ef6	00 	. 
	nop			;7ef7	00 	. 
	nop			;7ef8	00 	. 
	nop			;7ef9	00 	. 
	nop			;7efa	00 	. 
	nop			;7efb	00 	. 
	nop			;7efc	00 	. 
	nop			;7efd	00 	. 
	nop			;7efe	00 	. 
	nop			;7eff	00 	. 
	nop			;7f00	00 	. 
	nop			;7f01	00 	. 
	nop			;7f02	00 	. 
	nop			;7f03	00 	. 
	nop			;7f04	00 	. 
	nop			;7f05	00 	. 
	nop			;7f06	00 	. 
	nop			;7f07	00 	. 
	nop			;7f08	00 	. 
	nop			;7f09	00 	. 
	nop			;7f0a	00 	. 
	nop			;7f0b	00 	. 
	nop			;7f0c	00 	. 
	nop			;7f0d	00 	. 
	nop			;7f0e	00 	. 
	nop			;7f0f	00 	. 
	nop			;7f10	00 	. 
	nop			;7f11	00 	. 
	nop			;7f12	00 	. 
	nop			;7f13	00 	. 
	nop			;7f14	00 	. 
	nop			;7f15	00 	. 
	nop			;7f16	00 	. 
	nop			;7f17	00 	. 
	nop			;7f18	00 	. 
	nop			;7f19	00 	. 
	nop			;7f1a	00 	. 
	nop			;7f1b	00 	. 
	nop			;7f1c	00 	. 
	nop			;7f1d	00 	. 
	nop			;7f1e	00 	. 
	nop			;7f1f	00 	. 
	nop			;7f20	00 	. 
	nop			;7f21	00 	. 
	nop			;7f22	00 	. 
	nop			;7f23	00 	. 
	nop			;7f24	00 	. 
	nop			;7f25	00 	. 
	nop			;7f26	00 	. 
	nop			;7f27	00 	. 
	nop			;7f28	00 	. 
	nop			;7f29	00 	. 
	nop			;7f2a	00 	. 
	nop			;7f2b	00 	. 
	nop			;7f2c	00 	. 
	nop			;7f2d	00 	. 
	nop			;7f2e	00 	. 
	nop			;7f2f	00 	. 
	nop			;7f30	00 	. 
	nop			;7f31	00 	. 
	nop			;7f32	00 	. 
	nop			;7f33	00 	. 
	nop			;7f34	00 	. 
	nop			;7f35	00 	. 
	nop			;7f36	00 	. 
	nop			;7f37	00 	. 
	nop			;7f38	00 	. 
	nop			;7f39	00 	. 
	nop			;7f3a	00 	. 
	nop			;7f3b	00 	. 
	nop			;7f3c	00 	. 
	nop			;7f3d	00 	. 
	nop			;7f3e	00 	. 
	nop			;7f3f	00 	. 
	nop			;7f40	00 	. 
	nop			;7f41	00 	. 
	nop			;7f42	00 	. 
	nop			;7f43	00 	. 
	nop			;7f44	00 	. 
	nop			;7f45	00 	. 
	nop			;7f46	00 	. 
	nop			;7f47	00 	. 
	nop			;7f48	00 	. 
	nop			;7f49	00 	. 
	nop			;7f4a	00 	. 
	nop			;7f4b	00 	. 
	nop			;7f4c	00 	. 
	nop			;7f4d	00 	. 
	nop			;7f4e	00 	. 
	nop			;7f4f	00 	. 
	nop			;7f50	00 	. 
	nop			;7f51	00 	. 
	nop			;7f52	00 	. 
	nop			;7f53	00 	. 
	nop			;7f54	00 	. 
	nop			;7f55	00 	. 
	nop			;7f56	00 	. 
	nop			;7f57	00 	. 
	nop			;7f58	00 	. 
	nop			;7f59	00 	. 
	nop			;7f5a	00 	. 
	nop			;7f5b	00 	. 
	nop			;7f5c	00 	. 
	nop			;7f5d	00 	. 
	nop			;7f5e	00 	. 
	nop			;7f5f	00 	. 
	nop			;7f60	00 	. 
	nop			;7f61	00 	. 
	nop			;7f62	00 	. 
	nop			;7f63	00 	. 
	nop			;7f64	00 	. 
	nop			;7f65	00 	. 
	nop			;7f66	00 	. 
	nop			;7f67	00 	. 
	nop			;7f68	00 	. 
	nop			;7f69	00 	. 
	nop			;7f6a	00 	. 
	nop			;7f6b	00 	. 
	nop			;7f6c	00 	. 
	nop			;7f6d	00 	. 
	nop			;7f6e	00 	. 
	nop			;7f6f	00 	. 
	nop			;7f70	00 	. 
	nop			;7f71	00 	. 
	nop			;7f72	00 	. 
	nop			;7f73	00 	. 
	nop			;7f74	00 	. 
	nop			;7f75	00 	. 
	nop			;7f76	00 	. 
	nop			;7f77	00 	. 
	nop			;7f78	00 	. 
	nop			;7f79	00 	. 
	nop			;7f7a	00 	. 
	nop			;7f7b	00 	. 
	nop			;7f7c	00 	. 
	nop			;7f7d	00 	. 
	nop			;7f7e	00 	. 
	nop			;7f7f	00 	. 
	nop			;7f80	00 	. 
	nop			;7f81	00 	. 
	nop			;7f82	00 	. 
	nop			;7f83	00 	. 
	nop			;7f84	00 	. 
	nop			;7f85	00 	. 
	nop			;7f86	00 	. 
	nop			;7f87	00 	. 
	nop			;7f88	00 	. 
	nop			;7f89	00 	. 
	nop			;7f8a	00 	. 
	nop			;7f8b	00 	. 
	nop			;7f8c	00 	. 
	nop			;7f8d	00 	. 
	nop			;7f8e	00 	. 
	nop			;7f8f	00 	. 
	nop			;7f90	00 	. 
	nop			;7f91	00 	. 
	nop			;7f92	00 	. 
	nop			;7f93	00 	. 
	nop			;7f94	00 	. 
	nop			;7f95	00 	. 
	nop			;7f96	00 	. 
	nop			;7f97	00 	. 
	nop			;7f98	00 	. 
	nop			;7f99	00 	. 
	nop			;7f9a	00 	. 
	nop			;7f9b	00 	. 
	nop			;7f9c	00 	. 
	nop			;7f9d	00 	. 
	nop			;7f9e	00 	. 
	nop			;7f9f	00 	. 
	nop			;7fa0	00 	. 
	nop			;7fa1	00 	. 
	nop			;7fa2	00 	. 
	nop			;7fa3	00 	. 
	nop			;7fa4	00 	. 
	nop			;7fa5	00 	. 
	nop			;7fa6	00 	. 
	nop			;7fa7	00 	. 
	nop			;7fa8	00 	. 
	nop			;7fa9	00 	. 
	nop			;7faa	00 	. 
	nop			;7fab	00 	. 
	nop			;7fac	00 	. 
	nop			;7fad	00 	. 
	nop			;7fae	00 	. 
	nop			;7faf	00 	. 
	nop			;7fb0	00 	. 
	nop			;7fb1	00 	. 
	nop			;7fb2	00 	. 
	nop			;7fb3	00 	. 
	nop			;7fb4	00 	. 
	nop			;7fb5	00 	. 
	nop			;7fb6	00 	. 
	nop			;7fb7	00 	. 
	nop			;7fb8	00 	. 
	nop			;7fb9	00 	. 
	nop			;7fba	00 	. 
	nop			;7fbb	00 	. 
	nop			;7fbc	00 	. 
	nop			;7fbd	00 	. 
	nop			;7fbe	00 	. 
	nop			;7fbf	00 	. 
	nop			;7fc0	00 	. 
	nop			;7fc1	00 	. 
	nop			;7fc2	00 	. 
	nop			;7fc3	00 	. 
	nop			;7fc4	00 	. 
	nop			;7fc5	00 	. 
	nop			;7fc6	00 	. 
	nop			;7fc7	00 	. 
	nop			;7fc8	00 	. 
	nop			;7fc9	00 	. 
	nop			;7fca	00 	. 
	nop			;7fcb	00 	. 
	nop			;7fcc	00 	. 
	nop			;7fcd	00 	. 
	nop			;7fce	00 	. 
	nop			;7fcf	00 	. 
	nop			;7fd0	00 	. 
	nop			;7fd1	00 	. 
	nop			;7fd2	00 	. 
	nop			;7fd3	00 	. 
	nop			;7fd4	00 	. 
	nop			;7fd5	00 	. 
	nop			;7fd6	00 	. 
	nop			;7fd7	00 	. 
	nop			;7fd8	00 	. 
	nop			;7fd9	00 	. 
	nop			;7fda	00 	. 
	nop			;7fdb	00 	. 
	nop			;7fdc	00 	. 
	nop			;7fdd	00 	. 
	nop			;7fde	00 	. 
	nop			;7fdf	00 	. 
	nop			;7fe0	00 	. 
	nop			;7fe1	00 	. 
	nop			;7fe2	00 	. 
	nop			;7fe3	00 	. 
	nop			;7fe4	00 	. 
	nop			;7fe5	00 	. 
	nop			;7fe6	00 	. 
	nop			;7fe7	00 	. 
	nop			;7fe8	00 	. 
	nop			;7fe9	00 	. 
	nop			;7fea	00 	. 
	nop			;7feb	00 	. 
	nop			;7fec	00 	. 
	nop			;7fed	00 	. 
	nop			;7fee	00 	. 
	nop			;7fef	00 	. 
	nop			;7ff0	00 	. 
	nop			;7ff1	00 	. 
	nop			;7ff2	00 	. 
	nop			;7ff3	00 	. 
	nop			;7ff4	00 	. 
	nop			;7ff5	00 	. 
	nop			;7ff6	00 	. 
	nop			;7ff7	00 	. 
	nop			;7ff8	00 	. 
	nop			;7ff9	00 	. 
	nop			;7ffa	00 	. 
	nop			;7ffb	00 	. 
	nop			;7ffc	00 	. 
	nop			;7ffd	00 	. 
	nop			;7ffe	00 	. 
	nop			;7fff	00 	. 
