; z80dasm 1.1.6
; command line: z80dasm --origin=0 --address --labels --source bkio07.bin

	org	00000h

l0000h:
	nop			;0000	00 	. 
l0001h:
	nop			;0001	00 	. 
l0002h:
	di			;0002	f3 	. 
l0003h:
	nop			;0003	00 	. 
l0004h:
	nop			;0004	00 	. 
l0005h:
	di			;0005	f3 	. 
	nop			;0006	00 	. 
	nop			;0007	00 	. 
l0008h:
	di			;0008	f3 	. 
	jp l0100h		;0009	c3 00 01 	. . . 
	nop			;000c	00 	. 
	jp l0100h		;000d	c3 00 01 	. . . 
l0010h:
	nop			;0010	00 	. 
	jp l0100h		;0011	c3 00 01 	. . . 
	rst 38h			;0014	ff 	. 
	rst 38h			;0015	ff 	. 
	rst 38h			;0016	ff 	. 
	rst 38h			;0017	ff 	. 
l0018h:
	rst 38h			;0018	ff 	. 
	rst 38h			;0019	ff 	. 
	rst 38h			;001a	ff 	. 
	rst 38h			;001b	ff 	. 
	rst 38h			;001c	ff 	. 
	rst 38h			;001d	ff 	. 
	rst 38h			;001e	ff 	. 
	rst 38h			;001f	ff 	. 
	rst 38h			;0020	ff 	. 
	rst 38h			;0021	ff 	. 
	rst 38h			;0022	ff 	. 
	rst 38h			;0023	ff 	. 
	rst 38h			;0024	ff 	. 
	rst 38h			;0025	ff 	. 
	rst 38h			;0026	ff 	. 
	rst 38h			;0027	ff 	. 
	rst 38h			;0028	ff 	. 
	rst 38h			;0029	ff 	. 
	rst 38h			;002a	ff 	. 
	rst 38h			;002b	ff 	. 
	rst 38h			;002c	ff 	. 
	rst 38h			;002d	ff 	. 
	rst 38h			;002e	ff 	. 
	rst 38h			;002f	ff 	. 
l0030h:
	rst 38h			;0030	ff 	. 
	rst 38h			;0031	ff 	. 
	rst 38h			;0032	ff 	. 
	rst 38h			;0033	ff 	. 
	rst 38h			;0034	ff 	. 
	rst 38h			;0035	ff 	. 
	rst 38h			;0036	ff 	. 
	rst 38h			;0037	ff 	. 
	jp l061fh		;0038	c3 1f 06 	. . . 
l003bh:
	ld bc,0ffffh		;003b	01 ff ff 	. . . 
	rst 38h			;003e	ff 	. 
	rst 38h			;003f	ff 	. 
l0040h:
	rst 38h			;0040	ff 	. 
l0041h:
	rst 38h			;0041	ff 	. 
l0042h:
	rst 38h			;0042	ff 	. 
l0043h:
	rst 38h			;0043	ff 	. 
	rst 38h			;0044	ff 	. 
	rst 38h			;0045	ff 	. 
	rst 38h			;0046	ff 	. 
	rst 38h			;0047	ff 	. 
l0048h:
	rst 38h			;0048	ff 	. 
	rst 38h			;0049	ff 	. 
	rst 38h			;004a	ff 	. 
	rst 38h			;004b	ff 	. 
	rst 38h			;004c	ff 	. 
	rst 38h			;004d	ff 	. 
	rst 38h			;004e	ff 	. 
	rst 38h			;004f	ff 	. 
l0050h:
	rst 38h			;0050	ff 	. 
l0051h:
	rst 38h			;0051	ff 	. 
l0052h:
	rst 38h			;0052	ff 	. 
	rst 38h			;0053	ff 	. 
	rst 38h			;0054	ff 	. 
	rst 38h			;0055	ff 	. 
	rst 38h			;0056	ff 	. 
	rst 38h			;0057	ff 	. 
	rst 38h			;0058	ff 	. 
	rst 38h			;0059	ff 	. 
	rst 38h			;005a	ff 	. 
	rst 38h			;005b	ff 	. 
	rst 38h			;005c	ff 	. 
	rst 38h			;005d	ff 	. 
	rst 38h			;005e	ff 	. 
	rst 38h			;005f	ff 	. 
l0060h:
	rst 38h			;0060	ff 	. 
	rst 38h			;0061	ff 	. 
	rst 38h			;0062	ff 	. 
	rst 38h			;0063	ff 	. 
l0064h:
	rst 38h			;0064	ff 	. 
	rst 38h			;0065	ff 	. 
	ex af,af'			;0066	08 	. 
	exx			;0067	d9 	. 
	ld hl,(0c070h)		;0068	2a 70 c0 	* p . 
	ld a,(hl)			;006b	7e 	~ 
	and a			;006c	a7 	. 
	jp z,l0092h		;006d	ca 92 00 	. . . 
	inc hl			;0070	23 	# 
	ld (0c070h),hl		;0071	22 70 c0 	" p . 
l0074h:
	ld a,(0c001h)		;0074	3a 01 c0 	: . . 
	or 012h		;0077	f6 12 	. . 
	ld (0c001h),a		;0079	32 01 c0 	2 . . 
	out (081h),a		;007c	d3 81 	. . 
	in a,(000h)		;007e	db 00 	. . 
l0080h:
	ld (hl),a			;0080	77 	w 
	inc hl			;0081	23 	# 
	ld (hl),000h		;0082	36 00 	6 . 
	ld a,(0c001h)		;0084	3a 01 c0 	: . . 
	and 0edh		;0087	e6 ed 	. . 
	ld (0c001h),a		;0089	32 01 c0 	2 . . 
	out (081h),a		;008c	d3 81 	. . 
	exx			;008e	d9 	. 
	ex af,af'			;008f	08 	. 
	retn		;0090	ed 45 	. E 
l0092h:
	ld hl,0c072h		;0092	21 72 c0 	! r . 
	ld (0c06eh),hl		;0095	22 6e c0 	" n . 
	ld (0c070h),hl		;0098	22 70 c0 	" p . 
	jp l0074h		;009b	c3 74 00 	. t . 
	ld a,(0c001h)		;009e	3a 01 c0 	: . . 
	or 002h		;00a1	f6 02 	. . 
	ld (0c001h),a		;00a3	32 01 c0 	2 . . 
	out (081h),a		;00a6	d3 81 	. . 
	ret			;00a8	c9 	. 
sub_00a9h:
	ld a,(0c001h)		;00a9	3a 01 c0 	: . . 
	and 0fdh		;00ac	e6 fd 	. . 
	ld (0c001h),a		;00ae	32 01 c0 	2 . . 
	out (081h),a		;00b1	d3 81 	. . 
	ret			;00b3	c9 	. 
	rst 38h			;00b4	ff 	. 
	rst 38h			;00b5	ff 	. 
	rst 38h			;00b6	ff 	. 
	rst 38h			;00b7	ff 	. 
	rst 38h			;00b8	ff 	. 
	rst 38h			;00b9	ff 	. 
	rst 38h			;00ba	ff 	. 
	rst 38h			;00bb	ff 	. 
	rst 38h			;00bc	ff 	. 
	rst 38h			;00bd	ff 	. 
	rst 38h			;00be	ff 	. 
	rst 38h			;00bf	ff 	. 
	rst 38h			;00c0	ff 	. 
	rst 38h			;00c1	ff 	. 
	rst 38h			;00c2	ff 	. 
	rst 38h			;00c3	ff 	. 
	rst 38h			;00c4	ff 	. 
	rst 38h			;00c5	ff 	. 
	rst 38h			;00c6	ff 	. 
	rst 38h			;00c7	ff 	. 
l00c8h:
	rst 38h			;00c8	ff 	. 
	rst 38h			;00c9	ff 	. 
	rst 38h			;00ca	ff 	. 
	rst 38h			;00cb	ff 	. 
	rst 38h			;00cc	ff 	. 
	rst 38h			;00cd	ff 	. 
	rst 38h			;00ce	ff 	. 
	rst 38h			;00cf	ff 	. 
	rst 38h			;00d0	ff 	. 
	rst 38h			;00d1	ff 	. 
	rst 38h			;00d2	ff 	. 
	rst 38h			;00d3	ff 	. 
	rst 38h			;00d4	ff 	. 
	rst 38h			;00d5	ff 	. 
	rst 38h			;00d6	ff 	. 
	rst 38h			;00d7	ff 	. 
	rst 38h			;00d8	ff 	. 
	rst 38h			;00d9	ff 	. 
	rst 38h			;00da	ff 	. 
	rst 38h			;00db	ff 	. 
	rst 38h			;00dc	ff 	. 
	rst 38h			;00dd	ff 	. 
	rst 38h			;00de	ff 	. 
	rst 38h			;00df	ff 	. 
	rst 38h			;00e0	ff 	. 
	rst 38h			;00e1	ff 	. 
	rst 38h			;00e2	ff 	. 
	rst 38h			;00e3	ff 	. 
	rst 38h			;00e4	ff 	. 
	rst 38h			;00e5	ff 	. 
	rst 38h			;00e6	ff 	. 
	rst 38h			;00e7	ff 	. 
	rst 38h			;00e8	ff 	. 
	rst 38h			;00e9	ff 	. 
	rst 38h			;00ea	ff 	. 
	rst 38h			;00eb	ff 	. 
	rst 38h			;00ec	ff 	. 
	rst 38h			;00ed	ff 	. 
	rst 38h			;00ee	ff 	. 
	rst 38h			;00ef	ff 	. 
	rst 38h			;00f0	ff 	. 
	rst 38h			;00f1	ff 	. 
	rst 38h			;00f2	ff 	. 
	rst 38h			;00f3	ff 	. 
	rst 38h			;00f4	ff 	. 
	rst 38h			;00f5	ff 	. 
	rst 38h			;00f6	ff 	. 
	rst 38h			;00f7	ff 	. 
	rst 38h			;00f8	ff 	. 
	rst 38h			;00f9	ff 	. 
	rst 38h			;00fa	ff 	. 
	rst 38h			;00fb	ff 	. 
	rst 38h			;00fc	ff 	. 
	rst 38h			;00fd	ff 	. 
	rst 38h			;00fe	ff 	. 
	rst 38h			;00ff	ff 	. 
l0100h:
	di			;0100	f3 	. 
	im 1		;0101	ed 56 	. V 
	ld sp,0c7ffh		;0103	31 ff c7 	1 . . 
	call sub_0133h		;0106	cd 33 01 	. 3 . 
	call sub_016ah		;0109	cd 6a 01 	. j . 
	ei			;010c	fb 	. 
	in a,(004h)		;010d	db 04 	. . 
	bit 7,a		;010f	cb 7f 	.  
	jp z,l29aeh		;0111	ca ae 29 	. . ) 
	in a,(004h)		;0114	db 04 	. . 
	bit 6,a		;0116	cb 77 	. w 
	jp z,l29bfh		;0118	ca bf 29 	. . ) 
	in a,(004h)		;011b	db 04 	. . 
	bit 5,a		;011d	cb 6f 	. o 
	call z,sub_2b30h		;011f	cc 30 2b 	. 0 + 
	call sub_3335h		;0122	cd 35 33 	. 5 3 
	ld a,05fh		;0125	3e 5f 	> _ 
	ld (0c0feh),a		;0127	32 fe c0 	2 . . 
	call sub_0afah		;012a	cd fa 0a 	. . . 
	jp l0be2h		;012d	c3 e2 0b 	. . . 
	jp l0be2h		;0130	c3 e2 0b 	. . . 
sub_0133h:
	ld a,0ffh		;0133	3e ff 	> . 
	ld (0c005h),a		;0135	32 05 c0 	2 . . 
	out (085h),a		;0138	d3 85 	. . 
	ld (0c006h),a		;013a	32 06 c0 	2 . . 
	out (086h),a		;013d	d3 86 	. . 
	ld a,000h		;013f	3e 00 	> . 
	ld (0c007h),a		;0141	32 07 c0 	2 . . 
l0144h:
	out (087h),a		;0144	d3 87 	. . 
	ld a,000h		;0146	3e 00 	> . 
	ld (0c003h),a		;0148	32 03 c0 	2 . . 
	out (083h),a		;014b	d3 83 	. . 
	ld a,000h		;014d	3e 00 	> . 
	ld (0c004h),a		;014f	32 04 c0 	2 . . 
	out (084h),a		;0152	d3 84 	. . 
	ld a,000h		;0154	3e 00 	> . 
	ld (0c000h),a		;0156	32 00 c0 	2 . . 
	out (080h),a		;0159	d3 80 	. . 
	ld a,000h		;015b	3e 00 	> . 
	ld (0c001h),a		;015d	32 01 c0 	2 . . 
	out (081h),a		;0160	d3 81 	. . 
	ld a,000h		;0162	3e 00 	> . 
	ld (0c002h),a		;0164	32 02 c0 	2 . . 
	out (082h),a		;0167	d3 82 	. . 
	ret			;0169	c9 	. 
sub_016ah:
	ld hl,0c008h		;016a	21 08 c0 	! . . 
	ld b,0a8h		;016d	06 a8 	. . 
l016fh:
	ld (hl),000h		;016f	36 00 	6 . 
	inc hl			;0171	23 	# 
	djnz l016fh		;0172	10 fb 	. . 
	ld hl,l2bbdh		;0174	21 bd 2b 	! . + 
	ld (0c0e2h),hl		;0177	22 e2 c0 	" . . 
	ld hl,l3101h		;017a	21 01 31 	! . 1 
	ld (0c119h),hl		;017d	22 19 c1 	" . . 
	ld hl,0c072h		;0180	21 72 c0 	! r . 
	ld (0c06eh),hl		;0183	22 6e c0 	" n . 
	ld (0c070h),hl		;0186	22 70 c0 	" p . 
	ld (hl),000h		;0189	36 00 	6 . 
	ld hl,l0000h		;018b	21 00 00 	! . . 
	ld (0c033h),hl		;018e	22 33 c0 	" 3 . 
	ld (0c036h),hl		;0191	22 36 c0 	" 6 . 
	ld (0c028h),hl		;0194	22 28 c0 	" ( . 
	ld (0c026h),hl		;0197	22 26 c0 	" & . 
	ld (0c02ah),hl		;019a	22 2a c0 	" * . 
	ld (0c02ch),hl		;019d	22 2c c0 	" , . 
	xor a			;01a0	af 	. 
	ld (0c035h),a		;01a1	32 35 c0 	2 5 . 
	ld (0c038h),a		;01a4	32 38 c0 	2 8 . 
	ld (0c02eh),a		;01a7	32 2e c0 	2 . . 
	ld (0c039h),a		;01aa	32 39 c0 	2 9 . 
	ld (0c03ah),a		;01ad	32 3a c0 	2 : . 
	ld (0c0fdh),a		;01b0	32 fd c0 	2 . . 
	ld (0c101h),a		;01b3	32 01 c1 	2 . . 
	ld (0c102h),a		;01b6	32 02 c1 	2 . . 
	ld (0c103h),a		;01b9	32 03 c1 	2 . . 
	ld (0c104h),a		;01bc	32 04 c1 	2 . . 
	ld (0c105h),a		;01bf	32 05 c1 	2 . . 
	ld (0c106h),a		;01c2	32 06 c1 	2 . . 
	ld (0c107h),a		;01c5	32 07 c1 	2 . . 
	ld (0c108h),a		;01c8	32 08 c1 	2 . . 
	ld (0c111h),a		;01cb	32 11 c1 	2 . . 
	ld (0c112h),a		;01ce	32 12 c1 	2 . . 
	ld (0c113h),a		;01d1	32 13 c1 	2 . . 
	ld (0c114h),a		;01d4	32 14 c1 	2 . . 
	ld (0c115h),a		;01d7	32 15 c1 	2 . . 
	ld (0c116h),a		;01da	32 16 c1 	2 . . 
	ld (0c117h),a		;01dd	32 17 c1 	2 . . 
	ld (0c118h),a		;01e0	32 18 c1 	2 . . 
	ld (0c014h),a		;01e3	32 14 c0 	2 . . 
	ld (0c015h),a		;01e6	32 15 c0 	2 . . 
	ld (0c016h),a		;01e9	32 16 c0 	2 . . 
	ld (0c017h),a		;01ec	32 17 c0 	2 . . 
	ld (0c05dh),a		;01ef	32 5d c0 	2 ] . 
	ld (0c03bh),a		;01f2	32 3b c0 	2 ; . 
	ld (0c03ch),a		;01f5	32 3c c0 	2 < . 
	ld (0c067h),a		;01f8	32 67 c0 	2 g . 
	ld (0c068h),a		;01fb	32 68 c0 	2 h . 
	ld (0c06ah),a		;01fe	32 6a c0 	2 j . 
l0201h:
	ld (0c128h),a		;0201	32 28 c1 	2 ( . 
	ld (0c03ah),a		;0204	32 3a c0 	2 : . 
	ld (0c030h),a		;0207	32 30 c0 	2 0 . 
	ld (0c11eh),a		;020a	32 1e c1 	2 . . 
	ld (0c123h),a		;020d	32 23 c1 	2 # . 
l0210h:
	ld (0c11bh),a		;0210	32 1b c1 	2 . . 
	ld (0c124h),a		;0213	32 24 c1 	2 $ . 
	ld (0c03fh),a		;0216	32 3f c0 	2 ? . 
	ld (0c040h),a		;0219	32 40 c0 	2 @ . 
	ld (0c041h),a		;021c	32 41 c0 	2 A . 
	ld (0c042h),a		;021f	32 42 c0 	2 B . 
	ld (0c043h),a		;0222	32 43 c0 	2 C . 
	ld (0c044h),a		;0225	32 44 c0 	2 D . 
	ld (0c045h),a		;0228	32 45 c0 	2 E . 
	ld (0c046h),a		;022b	32 46 c0 	2 F . 
	ld (0c047h),a		;022e	32 47 c0 	2 G . 
	ld (0c048h),a		;0231	32 48 c0 	2 H . 
	ld (0c049h),a		;0234	32 49 c0 	2 I . 
	ld (0c04ah),a		;0237	32 4a c0 	2 J . 
	ld (0c04bh),a		;023a	32 4b c0 	2 K . 
	ld (0c04ch),a		;023d	32 4c c0 	2 L . 
l0240h:
	ld (0c04dh),a		;0240	32 4d c0 	2 M . 
	ld (0c04eh),a		;0243	32 4e c0 	2 N . 
	ld (0c04fh),a		;0246	32 4f c0 	2 O . 
	ld (0c050h),a		;0249	32 50 c0 	2 P . 
	ld (0c051h),a		;024c	32 51 c0 	2 Q . 
	ld (0c052h),a		;024f	32 52 c0 	2 R . 
	ld (0c053h),a		;0252	32 53 c0 	2 S . 
	ld (0c054h),a		;0255	32 54 c0 	2 T . 
l0258h:
	ld (0c055h),a		;0258	32 55 c0 	2 U . 
	ld (0c056h),a		;025b	32 56 c0 	2 V . 
	ld (0c03eh),a		;025e	32 3e c0 	2 > . 
	ld (0c05bh),a		;0261	32 5b c0 	2 [ . 
	ld (0c05ch),a		;0264	32 5c c0 	2 \ . 
	ld (0c05eh),a		;0267	32 5e c0 	2 ^ . 
	ld (0c05fh),a		;026a	32 5f c0 	2 _ . 
	ld (0c057h),a		;026d	32 57 c0 	2 W . 
	ld (0c058h),a		;0270	32 58 c0 	2 X . 
	ld (0c059h),a		;0273	32 59 c0 	2 Y . 
	ld (0c05ah),a		;0276	32 5a c0 	2 Z . 
	ld (0c061h),a		;0279	32 61 c0 	2 a . 
	ld (0c062h),a		;027c	32 62 c0 	2 b . 
	ld (0c065h),a		;027f	32 65 c0 	2 e . 
	ld (0c066h),a		;0282	32 66 c0 	2 f . 
	ld (0c0e5h),a		;0285	32 e5 c0 	2 . . 
l0288h:
	ld (0c0e7h),a		;0288	32 e7 c0 	2 . . 
	ld (0c0e9h),a		;028b	32 e9 c0 	2 . . 
	ld (0c0ebh),a		;028e	32 eb c0 	2 . . 
	ld (0c0edh),a		;0291	32 ed c0 	2 . . 
	ld (0c0efh),a		;0294	32 ef c0 	2 . . 
	ld (0c0f1h),a		;0297	32 f1 c0 	2 . . 
	ld (0c0f3h),a		;029a	32 f3 c0 	2 . . 
	ld (0c0f5h),a		;029d	32 f5 c0 	2 . . 
	ld (0c0e4h),a		;02a0	32 e4 c0 	2 . . 
	ld (0c0e6h),a		;02a3	32 e6 c0 	2 . . 
	ld (0c0e8h),a		;02a6	32 e8 c0 	2 . . 
	ld (0c0eah),a		;02a9	32 ea c0 	2 . . 
	ld (0c0ech),a		;02ac	32 ec c0 	2 . . 
	ld (0c0eeh),a		;02af	32 ee c0 	2 . . 
	ld (0c0f0h),a		;02b2	32 f0 c0 	2 . . 
	ld (0c0f2h),a		;02b5	32 f2 c0 	2 . . 
	ld (0c0f4h),a		;02b8	32 f4 c0 	2 . . 
	ld (0c069h),a		;02bb	32 69 c0 	2 i . 
	ld (0c06bh),a		;02be	32 6b c0 	2 k . 
	ld (0c06ch),a		;02c1	32 6c c0 	2 l . 
	ld (0c06dh),a		;02c4	32 6d c0 	2 m . 
	ld a,00ah		;02c7	3e 0a 	> . 
	ld (0c031h),a		;02c9	32 31 c0 	2 1 . 
	ld a,002h		;02cc	3e 02 	> . 
	ld (0c0fbh),a		;02ce	32 fb c0 	2 . . 
	ld a,0ffh		;02d1	3e ff 	> . 
	ld (0c0d7h),a		;02d3	32 d7 c0 	2 . . 
	ld (0c0d8h),a		;02d6	32 d8 c0 	2 . . 
	ld (0c0d9h),a		;02d9	32 d9 c0 	2 . . 
	ld (0c0dah),a		;02dc	32 da c0 	2 . . 
	ld (0c0dbh),a		;02df	32 db c0 	2 . . 
	ld (0c0dch),a		;02e2	32 dc c0 	2 . . 
	ld (0c0ddh),a		;02e5	32 dd c0 	2 . . 
	ld (0c0deh),a		;02e8	32 de c0 	2 . . 
	ld (0c0dfh),a		;02eb	32 df c0 	2 . . 
	ld (0c063h),a		;02ee	32 63 c0 	2 c . 
	ld (0c109h),a		;02f1	32 09 c1 	2 . . 
	ld (0c10ah),a		;02f4	32 0a c1 	2 . . 
	ld (0c10bh),a		;02f7	32 0b c1 	2 . . 
	ld (0c10ch),a		;02fa	32 0c c1 	2 . . 
	ld (0c10dh),a		;02fd	32 0d c1 	2 . . 
	ld (0c10eh),a		;0300	32 0e c1 	2 . . 
	ld (0c10fh),a		;0303	32 0f c1 	2 . . 
	ld (0c110h),a		;0306	32 10 c1 	2 . . 
	ld (0c122h),a		;0309	32 22 c1 	2 " . 
	ret			;030c	c9 	. 
l030dh:
	jr z,$+1		;030d	28 ff 	( . 
l030fh:
	inc d			;030f	14 	. 
l0310h:
	inc d			;0310	14 	. 
l0311h:
	ld a,(bc)			;0311	0a 	. 
l0312h:
	ld e,00ch		;0312	1e 0c 	. . 
l0314h:
	ld e,008h		;0314	1e 08 	. . 
l0316h:
	ex af,af'			;0316	08 	. 
sub_0317h:
	di			;0317	f3 	. 
	ld a,0ffh		;0318	3e ff 	> . 
	ld (0c00ch),a		;031a	32 0c c0 	2 . . 
	ld a,(0c006h)		;031d	3a 06 c0 	: . . 
l0320h:
	and 0feh		;0320	e6 fe 	. . 
	ld (0c006h),a		;0322	32 06 c0 	2 . . 
	out (086h),a		;0325	d3 86 	. . 
	ld a,(l030fh)		;0327	3a 0f 03 	: . . 
	ld (0c01ah),a		;032a	32 1a c0 	2 . . 
	xor a			;032d	af 	. 
	ld (0c043h),a		;032e	32 43 c0 	2 C . 
	ld (0c04fh),a		;0331	32 4f c0 	2 O . 
	ei			;0334	fb 	. 
	ret			;0335	c9 	. 
	di			;0336	f3 	. 
	ld a,0ffh		;0337	3e ff 	> . 
	ld (0c00dh),a		;0339	32 0d c0 	2 . . 
	ld a,(0c006h)		;033c	3a 06 c0 	: . . 
	and 0fdh		;033f	e6 fd 	. . 
	ld (0c006h),a		;0341	32 06 c0 	2 . . 
	out (086h),a		;0344	d3 86 	. . 
	ld a,(l030dh+1)		;0346	3a 0e 03 	: . . 
	ld (0c01bh),a		;0349	32 1b c0 	2 . . 
	xor a			;034c	af 	. 
	ld (0c044h),a		;034d	32 44 c0 	2 D . 
	ld (0c050h),a		;0350	32 50 c0 	2 P . 
	ei			;0353	fb 	. 
	ret			;0354	c9 	. 
sub_0355h:
	di			;0355	f3 	. 
	ld a,0ffh		;0356	3e ff 	> . 
	ld (0c00eh),a		;0358	32 0e c0 	2 . . 
	ld a,(0c006h)		;035b	3a 06 c0 	: . . 
	and 0fbh		;035e	e6 fb 	. . 
	ld (0c006h),a		;0360	32 06 c0 	2 . . 
	out (086h),a		;0363	d3 86 	. . 
	ld a,(l0310h)		;0365	3a 10 03 	: . . 
	ld (0c01ch),a		;0368	32 1c c0 	2 . . 
	xor a			;036b	af 	. 
	ld (0c045h),a		;036c	32 45 c0 	2 E . 
	ld (0c051h),a		;036f	32 51 c0 	2 Q . 
	ei			;0372	fb 	. 
	ret			;0373	c9 	. 
sub_0374h:
	di			;0374	f3 	. 
	ld a,0ffh		;0375	3e ff 	> . 
	ld (0c00fh),a		;0377	32 0f c0 	2 . . 
	ld a,(0c006h)		;037a	3a 06 c0 	: . . 
	and 0f7h		;037d	e6 f7 	. . 
	ld (0c006h),a		;037f	32 06 c0 	2 . . 
	out (086h),a		;0382	d3 86 	. . 
	ld a,(l0310h)		;0384	3a 10 03 	: . . 
	ld (0c01dh),a		;0387	32 1d c0 	2 . . 
	xor a			;038a	af 	. 
	ld (0c046h),a		;038b	32 46 c0 	2 F . 
	ld (0c052h),a		;038e	32 52 c0 	2 R . 
	ei			;0391	fb 	. 
	ret			;0392	c9 	. 
sub_0393h:
	di			;0393	f3 	. 
	ld a,0ffh		;0394	3e ff 	> . 
	ld (0c010h),a		;0396	32 10 c0 	2 . . 
	ld a,(0c006h)		;0399	3a 06 c0 	: . . 
	and 0efh		;039c	e6 ef 	. . 
	ld (0c006h),a		;039e	32 06 c0 	2 . . 
	out (086h),a		;03a1	d3 86 	. . 
	ld a,(l0311h)		;03a3	3a 11 03 	: . . 
	ld (0c01eh),a		;03a6	32 1e c0 	2 . . 
	xor a			;03a9	af 	. 
	ld (0c047h),a		;03aa	32 47 c0 	2 G . 
	ld (0c053h),a		;03ad	32 53 c0 	2 S . 
	ei			;03b0	fb 	. 
	ret			;03b1	c9 	. 
sub_03b2h:
	di			;03b2	f3 	. 
	ld a,0ffh		;03b3	3e ff 	> . 
	ld (0c011h),a		;03b5	32 11 c0 	2 . . 
	ld a,(0c006h)		;03b8	3a 06 c0 	: . . 
	and 0dfh		;03bb	e6 df 	. . 
	ld (0c006h),a		;03bd	32 06 c0 	2 . . 
	out (086h),a		;03c0	d3 86 	. . 
	ld a,(l0312h)		;03c2	3a 12 03 	: . . 
	ld (0c01fh),a		;03c5	32 1f c0 	2 . . 
	xor a			;03c8	af 	. 
	ld (0c048h),a		;03c9	32 48 c0 	2 H . 
	ld (0c054h),a		;03cc	32 54 c0 	2 T . 
	ei			;03cf	fb 	. 
	ret			;03d0	c9 	. 
sub_03d1h:
	di			;03d1	f3 	. 
	ld a,0ffh		;03d2	3e ff 	> . 
	ld (0c012h),a		;03d4	32 12 c0 	2 . . 
	ld a,(0c006h)		;03d7	3a 06 c0 	: . . 
	and 0bfh		;03da	e6 bf 	. . 
	ld (0c006h),a		;03dc	32 06 c0 	2 . . 
	out (086h),a		;03df	d3 86 	. . 
	ld a,(l0312h+1)		;03e1	3a 13 03 	: . . 
	ld (0c020h),a		;03e4	32 20 c0 	2   . 
	xor a			;03e7	af 	. 
	ld (0c049h),a		;03e8	32 49 c0 	2 I . 
	ld (0c055h),a		;03eb	32 55 c0 	2 U . 
	ei			;03ee	fb 	. 
	ret			;03ef	c9 	. 
sub_03f0h:
	di			;03f0	f3 	. 
	ld a,0ffh		;03f1	3e ff 	> . 
	ld (0c013h),a		;03f3	32 13 c0 	2 . . 
	ld a,(0c006h)		;03f6	3a 06 c0 	: . . 
	and 07fh		;03f9	e6 7f 	.  
	ld (0c006h),a		;03fb	32 06 c0 	2 . . 
	out (086h),a		;03fe	d3 86 	. . 
sub_0400h:
	ld a,(l0314h)		;0400	3a 14 03 	: . . 
	ld (0c021h),a		;0403	32 21 c0 	2 ! . 
	xor a			;0406	af 	. 
	ld (0c04ah),a		;0407	32 4a c0 	2 J . 
	ld (0c056h),a		;040a	32 56 c0 	2 V . 
	ei			;040d	fb 	. 
	ret			;040e	c9 	. 
sub_040fh:
	di			;040f	f3 	. 
	ld a,0ffh		;0410	3e ff 	> . 
	ld (0c010h),a		;0412	32 10 c0 	2 . . 
	ld a,(0c006h)		;0415	3a 06 c0 	: . . 
	and 0efh		;0418	e6 ef 	. . 
	ld (0c006h),a		;041a	32 06 c0 	2 . . 
	out (086h),a		;041d	d3 86 	. . 
	ld a,(l0314h+1)		;041f	3a 15 03 	: . . 
	ld (0c01eh),a		;0422	32 1e c0 	2 . . 
	xor a			;0425	af 	. 
	ld (0c047h),a		;0426	32 47 c0 	2 G . 
	ld (0c053h),a		;0429	32 53 c0 	2 S . 
	ei			;042c	fb 	. 
	ret			;042d	c9 	. 
sub_042eh:
	di			;042e	f3 	. 
	ld a,0ffh		;042f	3e ff 	> . 
	ld (0c011h),a		;0431	32 11 c0 	2 . . 
	ld a,(0c006h)		;0434	3a 06 c0 	: . . 
	and 0dfh		;0437	e6 df 	. . 
	ld (0c006h),a		;0439	32 06 c0 	2 . . 
	out (086h),a		;043c	d3 86 	. . 
	ld a,(l0316h)		;043e	3a 16 03 	: . . 
	ld (0c01fh),a		;0441	32 1f c0 	2 . . 
	xor a			;0444	af 	. 
	ld (0c048h),a		;0445	32 48 c0 	2 H . 
	ld (0c054h),a		;0448	32 54 c0 	2 T . 
	ei			;044b	fb 	. 
	ret			;044c	c9 	. 
	di			;044d	f3 	. 
	xor a			;044e	af 	. 
	ld (0c00dh),a		;044f	32 0d c0 	2 . . 
	ld (0c044h),a		;0452	32 44 c0 	2 D . 
	ld (0c050h),a		;0455	32 50 c0 	2 P . 
	ld a,(0c006h)		;0458	3a 06 c0 	: . . 
	or 002h		;045b	f6 02 	. . 
	ld (0c006h),a		;045d	32 06 c0 	2 . . 
	out (086h),a		;0460	d3 86 	. . 
	ei			;0462	fb 	. 
	ret			;0463	c9 	. 
l0464h:
	inc d			;0464	14 	. 
	dec b			;0465	05 	. 
sub_0466h:
	di			;0466	f3 	. 
	ld a,0ffh		;0467	3e ff 	> . 
	ld (0c008h),a		;0469	32 08 c0 	2 . . 
	ld a,(0c005h)		;046c	3a 05 c0 	: . . 
	or 002h		;046f	f6 02 	. . 
	and 0feh		;0471	e6 fe 	. . 
	ld (0c005h),a		;0473	32 05 c0 	2 . . 
	out (085h),a		;0476	d3 85 	. . 
	ld a,(l030dh)		;0478	3a 0d 03 	: . . 
	ld (0c018h),a		;047b	32 18 c0 	2 . . 
	xor a			;047e	af 	. 
	ld (0c03fh),a		;047f	32 3f c0 	2 ? . 
	ld (0c04bh),a		;0482	32 4b c0 	2 K . 
	ld (0c040h),a		;0485	32 40 c0 	2 @ . 
	ld (0c04ch),a		;0488	32 4c c0 	2 L . 
	ld (0c057h),a		;048b	32 57 c0 	2 W . 
	ld (0c00ah),a		;048e	32 0a c0 	2 . . 
	ei			;0491	fb 	. 
	ret			;0492	c9 	. 
sub_0493h:
	di			;0493	f3 	. 
	ld a,0ffh		;0494	3e ff 	> . 
	ld (0c009h),a		;0496	32 09 c0 	2 . . 
	ld a,(0c005h)		;0499	3a 05 c0 	: . . 
	or 008h		;049c	f6 08 	. . 
	and 0fbh		;049e	e6 fb 	. . 
	ld (0c005h),a		;04a0	32 05 c0 	2 . . 
	out (085h),a		;04a3	d3 85 	. . 
	ld a,(l030dh)		;04a5	3a 0d 03 	: . . 
	ld (0c019h),a		;04a8	32 19 c0 	2 . . 
	xor a			;04ab	af 	. 
	ld (0c041h),a		;04ac	32 41 c0 	2 A . 
	ld (0c04dh),a		;04af	32 4d c0 	2 M . 
	ld (0c042h),a		;04b2	32 42 c0 	2 B . 
	ld (0c04eh),a		;04b5	32 4e c0 	2 N . 
	ld (0c057h),a		;04b8	32 57 c0 	2 W . 
	ld (0c00bh),a		;04bb	32 0b c0 	2 . . 
	ei			;04be	fb 	. 
	ret			;04bf	c9 	. 
sub_04c0h:
	di			;04c0	f3 	. 
	ld a,0ffh		;04c1	3e ff 	> . 
	ld (0c00ah),a		;04c3	32 0a c0 	2 . . 
	ld a,(0c005h)		;04c6	3a 05 c0 	: . . 
	or 001h		;04c9	f6 01 	. . 
	and 0fdh		;04cb	e6 fd 	. . 
	ld (0c005h),a		;04cd	32 05 c0 	2 . . 
	out (085h),a		;04d0	d3 85 	. . 
	xor a			;04d2	af 	. 
	ld (0c03fh),a		;04d3	32 3f c0 	2 ? . 
	ld (0c04bh),a		;04d6	32 4b c0 	2 K . 
	ld (0c040h),a		;04d9	32 40 c0 	2 @ . 
	ld (0c04ch),a		;04dc	32 4c c0 	2 L . 
	ld (0c008h),a		;04df	32 08 c0 	2 . . 
	ld hl,(l0464h)		;04e2	2a 64 04 	* d . 
	ld (0c026h),hl		;04e5	22 26 c0 	" & . 
	ei			;04e8	fb 	. 
	ret			;04e9	c9 	. 
sub_04eah:
	di			;04ea	f3 	. 
	ld a,0ffh		;04eb	3e ff 	> . 
	ld (0c00bh),a		;04ed	32 0b c0 	2 . . 
	ld a,(0c005h)		;04f0	3a 05 c0 	: . . 
	or 004h		;04f3	f6 04 	. . 
	and 0f7h		;04f5	e6 f7 	. . 
	ld (0c005h),a		;04f7	32 05 c0 	2 . . 
	out (085h),a		;04fa	d3 85 	. . 
	xor a			;04fc	af 	. 
	ld (0c041h),a		;04fd	32 41 c0 	2 A . 
	ld (0c04dh),a		;0500	32 4d c0 	2 M . 
	ld (0c042h),a		;0503	32 42 c0 	2 B . 
	ld (0c04eh),a		;0506	32 4e c0 	2 N . 
	ld (0c009h),a		;0509	32 09 c0 	2 . . 
	ld hl,(l0464h)		;050c	2a 64 04 	* d . 
	ld (0c028h),hl		;050f	22 28 c0 	" ( . 
	ei			;0512	fb 	. 
	ret			;0513	c9 	. 
l0514h:
	di			;0514	f3 	. 
	xor a			;0515	af 	. 
	ld (0c008h),a		;0516	32 08 c0 	2 . . 
	ld (0c00ah),a		;0519	32 0a c0 	2 . . 
	ld (0c03fh),a		;051c	32 3f c0 	2 ? . 
	ld (0c04bh),a		;051f	32 4b c0 	2 K . 
	ld (0c040h),a		;0522	32 40 c0 	2 @ . 
	ld (0c04ch),a		;0525	32 4c c0 	2 L . 
	ld (0c057h),a		;0528	32 57 c0 	2 W . 
	ld a,(0c005h)		;052b	3a 05 c0 	: . . 
	or 002h		;052e	f6 02 	. . 
	or 001h		;0530	f6 01 	. . 
	ld (0c005h),a		;0532	32 05 c0 	2 . . 
	out (085h),a		;0535	d3 85 	. . 
	ei			;0537	fb 	. 
	ret			;0538	c9 	. 
sub_0539h:
	di			;0539	f3 	. 
	xor a			;053a	af 	. 
	ld (0c00bh),a		;053b	32 0b c0 	2 . . 
	ld (0c009h),a		;053e	32 09 c0 	2 . . 
	ld (0c041h),a		;0541	32 41 c0 	2 A . 
	ld (0c04dh),a		;0544	32 4d c0 	2 M . 
	ld (0c042h),a		;0547	32 42 c0 	2 B . 
	ld (0c04eh),a		;054a	32 4e c0 	2 N . 
	ld (0c058h),a		;054d	32 58 c0 	2 X . 
	ld a,(0c005h)		;0550	3a 05 c0 	: . . 
	or 008h		;0553	f6 08 	. . 
	or 004h		;0555	f6 04 	. . 
	ld (0c005h),a		;0557	32 05 c0 	2 . . 
	out (085h),a		;055a	d3 85 	. . 
	ei			;055c	fb 	. 
	ret			;055d	c9 	. 
l055eh:
	inc c			;055e	0c 	. 
sub_055fh:
	di			;055f	f3 	. 
	ld a,0ffh		;0560	3e ff 	> . 
	ld (0c014h),a		;0562	32 14 c0 	2 . . 
	ld a,(0c005h)		;0565	3a 05 c0 	: . . 
	and 0efh		;0568	e6 ef 	. . 
	ld (0c005h),a		;056a	32 05 c0 	2 . . 
	out (085h),a		;056d	d3 85 	. . 
	ld a,(l055eh)		;056f	3a 5e 05 	: ^ . 
	ld (0c022h),a		;0572	32 22 c0 	2 " . 
	ei			;0575	fb 	. 
	ret			;0576	c9 	. 
sub_0577h:
	di			;0577	f3 	. 
	ld a,0ffh		;0578	3e ff 	> . 
	ld (0c015h),a		;057a	32 15 c0 	2 . . 
	ld a,(0c005h)		;057d	3a 05 c0 	: . . 
	and 0dfh		;0580	e6 df 	. . 
	ld (0c005h),a		;0582	32 05 c0 	2 . . 
	out (085h),a		;0585	d3 85 	. . 
	ld a,(l055eh)		;0587	3a 5e 05 	: ^ . 
	ld (0c023h),a		;058a	32 23 c0 	2 # . 
	ei			;058d	fb 	. 
	ret			;058e	c9 	. 
sub_058fh:
	di			;058f	f3 	. 
	ld a,0ffh		;0590	3e ff 	> . 
	ld (0c016h),a		;0592	32 16 c0 	2 . . 
	ld a,(0c005h)		;0595	3a 05 c0 	: . . 
	and 0bfh		;0598	e6 bf 	. . 
	ld (0c005h),a		;059a	32 05 c0 	2 . . 
	out (085h),a		;059d	d3 85 	. . 
	ld a,(l055eh)		;059f	3a 5e 05 	: ^ . 
	ld (0c024h),a		;05a2	32 24 c0 	2 $ . 
	ei			;05a5	fb 	. 
	ret			;05a6	c9 	. 
sub_05a7h:
	di			;05a7	f3 	. 
	ld a,0ffh		;05a8	3e ff 	> . 
	ld (0c017h),a		;05aa	32 17 c0 	2 . . 
	ld a,(0c005h)		;05ad	3a 05 c0 	: . . 
	and 07fh		;05b0	e6 7f 	.  
	ld (0c005h),a		;05b2	32 05 c0 	2 . . 
	out (085h),a		;05b5	d3 85 	. . 
	ld a,(l055eh)		;05b7	3a 5e 05 	: ^ . 
	ld (0c025h),a		;05ba	32 25 c0 	2 % . 
	ei			;05bd	fb 	. 
	ret			;05be	c9 	. 
	ld a,(0c005h)		;05bf	3a 05 c0 	: . . 
	and 0efh		;05c2	e6 ef 	. . 
	ld (0c005h),a		;05c4	32 05 c0 	2 . . 
	out (085h),a		;05c7	d3 85 	. . 
	ret			;05c9	c9 	. 
	ld a,(0c005h)		;05ca	3a 05 c0 	: . . 
	and 0dfh		;05cd	e6 df 	. . 
	ld (0c005h),a		;05cf	32 05 c0 	2 . . 
	out (085h),a		;05d2	d3 85 	. . 
	ret			;05d4	c9 	. 
	ld a,(0c005h)		;05d5	3a 05 c0 	: . . 
	and 0bfh		;05d8	e6 bf 	. . 
	ld (0c005h),a		;05da	32 05 c0 	2 . . 
	out (085h),a		;05dd	d3 85 	. . 
	ret			;05df	c9 	. 
	ld a,(0c005h)		;05e0	3a 05 c0 	: . . 
	and 07fh		;05e3	e6 7f 	.  
	ld (0c005h),a		;05e5	32 05 c0 	2 . . 
	out (085h),a		;05e8	d3 85 	. . 
	ret			;05ea	c9 	. 
sub_05ebh:
	ld a,(0c005h)		;05eb	3a 05 c0 	: . . 
	or 010h		;05ee	f6 10 	. . 
	ld (0c005h),a		;05f0	32 05 c0 	2 . . 
	out (085h),a		;05f3	d3 85 	. . 
	ret			;05f5	c9 	. 
sub_05f6h:
	ld a,(0c005h)		;05f6	3a 05 c0 	: . . 
	or 020h		;05f9	f6 20 	.   
	ld (0c005h),a		;05fb	32 05 c0 	2 . . 
	out (085h),a		;05fe	d3 85 	. . 
l0600h:
	ret			;0600	c9 	. 
sub_0601h:
	ld a,(0c005h)		;0601	3a 05 c0 	: . . 
l0604h:
	or 040h		;0604	f6 40 	. @ 
l0606h:
	ld (0c005h),a		;0606	32 05 c0 	2 . . 
	out (085h),a		;0609	d3 85 	. . 
	ret			;060b	c9 	. 
sub_060ch:
	ld a,(0c005h)		;060c	3a 05 c0 	: . . 
	or 080h		;060f	f6 80 	. . 
	ld (0c005h),a		;0611	32 05 c0 	2 . . 
	out (085h),a		;0614	d3 85 	. . 
	ret			;0616	c9 	. 
	call sub_3386h		;0617	cd 86 33 	. . 3 
	ret			;061a	c9 	. 
	call sub_33c0h		;061b	cd c0 33 	. . 3 
	ret			;061e	c9 	. 
l061fh:
	di			;061f	f3 	. 
	push af			;0620	f5 	. 
	push bc			;0621	c5 	. 
	push de			;0622	d5 	. 
	push hl			;0623	e5 	. 
	call sub_30f0h		;0624	cd f0 30 	. . 0 
	call sub_2fffh		;0627	cd ff 2f 	. . / 
	call sub_2b9eh		;062a	cd 9e 2b 	. . + 
	ld a,(0c039h)		;062d	3a 39 c0 	: 9 . 
	cp 0a5h		;0630	fe a5 	. . 
	call z,l0ac2h+1		;0632	cc c3 0a 	. . . 
	call sub_00a9h		;0635	cd a9 00 	. . . 
	ld a,(0c030h)		;0638	3a 30 c0 	: 0 . 
	and a			;063b	a7 	. 
	jp nz,l0816h		;063c	c2 16 08 	. . . 
	ld a,0ffh		;063f	3e ff 	> . 
	ld (0c030h),a		;0641	32 30 c0 	2 0 . 
	ld a,(0c007h)		;0644	3a 07 c0 	: . . 
	and 0f0h		;0647	e6 f0 	. . 
	or 000h		;0649	f6 00 	. . 
	ld (0c007h),a		;064b	32 07 c0 	2 . . 
	out (087h),a		;064e	d3 87 	. . 
	ld a,(0c008h)		;0650	3a 08 c0 	: . . 
	and a			;0653	a7 	. 
	jp nz,l066ch		;0654	c2 6c 06 	. l . 
	ld a,(0c05dh)		;0657	3a 5d c0 	: ] . 
	and a			;065a	a7 	. 
	jp nz,l0697h		;065b	c2 97 06 	. . . 
	in a,(001h)		;065e	db 01 	. . 
	bit 5,a		;0660	cb 6f 	. o 
	jp nz,l0697h		;0662	c2 97 06 	. . . 
	ld hl,0c03fh		;0665	21 3f c0 	! ? . 
	inc (hl)			;0668	34 	4 
	jp l069bh		;0669	c3 9b 06 	. . . 
l066ch:
	ld hl,0c018h		;066c	21 18 c0 	! . . 
	dec (hl)			;066f	35 	5 
	jp z,l0688h		;0670	ca 88 06 	. . . 
	ld a,(0c05dh)		;0673	3a 5d c0 	: ] . 
	and a			;0676	a7 	. 
	jp nz,l0690h		;0677	c2 90 06 	. . . 
	in a,(001h)		;067a	db 01 	. . 
	bit 5,a		;067c	cb 6f 	. o 
	jp z,l0690h		;067e	ca 90 06 	. . . 
	ld hl,0c04bh		;0681	21 4b c0 	! K . 
	inc (hl)			;0684	34 	4 
	jp l069bh		;0685	c3 9b 06 	. . . 
l0688h:
	ld a,0ffh		;0688	3e ff 	> . 
	ld (0c057h),a		;068a	32 57 c0 	2 W . 
	call sub_04c0h		;068d	cd c0 04 	. . . 
l0690h:
	xor a			;0690	af 	. 
	ld (0c04bh),a		;0691	32 4b c0 	2 K . 
	jp l069bh		;0694	c3 9b 06 	. . . 
l0697h:
	xor a			;0697	af 	. 
	ld (0c03fh),a		;0698	32 3f c0 	2 ? . 
l069bh:
	ld a,(0c007h)		;069b	3a 07 c0 	: . . 
	and 0f0h		;069e	e6 f0 	. . 
	or 001h		;06a0	f6 01 	. . 
	ld (0c007h),a		;06a2	32 07 c0 	2 . . 
	out (087h),a		;06a5	d3 87 	. . 
	ld a,(0c00ah)		;06a7	3a 0a c0 	: . . 
	and a			;06aa	a7 	. 
	jp z,l06cah		;06ab	ca ca 06 	. . . 
	ld a,(0c05dh)		;06ae	3a 5d c0 	: ] . 
	and a			;06b1	a7 	. 
	jp nz,l06c3h		;06b2	c2 c3 06 	. . . 
	in a,(001h)		;06b5	db 01 	. . 
	bit 5,a		;06b7	cb 6f 	. o 
	jp z,l06c3h		;06b9	ca c3 06 	. . . 
	ld hl,0c04ch		;06bc	21 4c c0 	! L . 
	inc (hl)			;06bf	34 	4 
	jp l06e3h		;06c0	c3 e3 06 	. . . 
l06c3h:
	xor a			;06c3	af 	. 
	ld (0c04ch),a		;06c4	32 4c c0 	2 L . 
	jp l06e3h		;06c7	c3 e3 06 	. . . 
l06cah:
	ld a,(0c05dh)		;06ca	3a 5d c0 	: ] . 
	and a			;06cd	a7 	. 
	jp nz,l06dfh		;06ce	c2 df 06 	. . . 
	in a,(001h)		;06d1	db 01 	. . 
	bit 5,a		;06d3	cb 6f 	. o 
	jp nz,l06dfh		;06d5	c2 df 06 	. . . 
	ld hl,0c040h		;06d8	21 40 c0 	! @ . 
	inc (hl)			;06db	34 	4 
	jp l06e3h		;06dc	c3 e3 06 	. . . 
l06dfh:
	xor a			;06df	af 	. 
	ld (0c040h),a		;06e0	32 40 c0 	2 @ . 
l06e3h:
	ld a,(0c007h)		;06e3	3a 07 c0 	: . . 
	and 0f0h		;06e6	e6 f0 	. . 
	or 002h		;06e8	f6 02 	. . 
	ld (0c007h),a		;06ea	32 07 c0 	2 . . 
	out (087h),a		;06ed	d3 87 	. . 
	ld a,(0c009h)		;06ef	3a 09 c0 	: . . 
	and a			;06f2	a7 	. 
	jp nz,l070bh		;06f3	c2 0b 07 	. . . 
	ld a,(0c05dh)		;06f6	3a 5d c0 	: ] . 
	and a			;06f9	a7 	. 
	jp nz,l0736h		;06fa	c2 36 07 	. 6 . 
	in a,(001h)		;06fd	db 01 	. . 
	bit 5,a		;06ff	cb 6f 	. o 
	jp nz,l0736h		;0701	c2 36 07 	. 6 . 
	ld hl,0c041h		;0704	21 41 c0 	! A . 
	inc (hl)			;0707	34 	4 
	jp l073ah		;0708	c3 3a 07 	. : . 
l070bh:
	ld hl,0c019h		;070b	21 19 c0 	! . . 
	dec (hl)			;070e	35 	5 
	jp z,l0727h		;070f	ca 27 07 	. ' . 
	ld a,(0c05dh)		;0712	3a 5d c0 	: ] . 
	and a			;0715	a7 	. 
	jp nz,l072fh		;0716	c2 2f 07 	. / . 
	in a,(001h)		;0719	db 01 	. . 
	bit 5,a		;071b	cb 6f 	. o 
	jp z,l072fh		;071d	ca 2f 07 	. / . 
	ld hl,0c04dh		;0720	21 4d c0 	! M . 
sub_0723h:
	inc (hl)			;0723	34 	4 
	jp l073ah		;0724	c3 3a 07 	. : . 
l0727h:
	ld a,0ffh		;0727	3e ff 	> . 
	ld (0c058h),a		;0729	32 58 c0 	2 X . 
	call sub_04eah		;072c	cd ea 04 	. . . 
l072fh:
	xor a			;072f	af 	. 
	ld (0c04dh),a		;0730	32 4d c0 	2 M . 
	jp l073ah		;0733	c3 3a 07 	. : . 
l0736h:
	xor a			;0736	af 	. 
	ld (0c041h),a		;0737	32 41 c0 	2 A . 
l073ah:
	ld a,(0c007h)		;073a	3a 07 c0 	: . . 
	and 0f0h		;073d	e6 f0 	. . 
	or 003h		;073f	f6 03 	. . 
	ld (0c007h),a		;0741	32 07 c0 	2 . . 
	out (087h),a		;0744	d3 87 	. . 
	ld a,(0c00bh)		;0746	3a 0b c0 	: . . 
	and a			;0749	a7 	. 
	jp z,l0769h		;074a	ca 69 07 	. i . 
	ld a,(0c05dh)		;074d	3a 5d c0 	: ] . 
	and a			;0750	a7 	. 
	jp nz,l0762h		;0751	c2 62 07 	. b . 
	in a,(001h)		;0754	db 01 	. . 
	bit 5,a		;0756	cb 6f 	. o 
	jp z,l0762h		;0758	ca 62 07 	. b . 
	ld hl,0c04eh		;075b	21 4e c0 	! N . 
	inc (hl)			;075e	34 	4 
	jp l0782h		;075f	c3 82 07 	. . . 
l0762h:
	xor a			;0762	af 	. 
	ld (0c04eh),a		;0763	32 4e c0 	2 N . 
	jp l0782h		;0766	c3 82 07 	. . . 
l0769h:
	ld a,(0c05dh)		;0769	3a 5d c0 	: ] . 
	and a			;076c	a7 	. 
	jp nz,l077eh		;076d	c2 7e 07 	. ~ . 
	in a,(001h)		;0770	db 01 	. . 
	bit 5,a		;0772	cb 6f 	. o 
	jp nz,l077eh		;0774	c2 7e 07 	. ~ . 
	ld hl,0c042h		;0777	21 42 c0 	! B . 
	inc (hl)			;077a	34 	4 
	jp l0782h		;077b	c3 82 07 	. . . 
l077eh:
	xor a			;077e	af 	. 
	ld (0c042h),a		;077f	32 42 c0 	2 B . 
l0782h:
	ld a,(0c007h)		;0782	3a 07 c0 	: . . 
	and 0f0h		;0785	e6 f0 	. . 
	or 008h		;0787	f6 08 	. . 
	ld (0c007h),a		;0789	32 07 c0 	2 . . 
	out (087h),a		;078c	d3 87 	. . 
	ld a,(0c00ch)		;078e	3a 0c c0 	: . . 
	and a			;0791	a7 	. 
	jp nz,l07a3h		;0792	c2 a3 07 	. . . 
	in a,(001h)		;0795	db 01 	. . 
	bit 5,a		;0797	cb 6f 	. o 
	jp nz,l07d0h		;0799	c2 d0 07 	. . . 
	ld hl,0c043h		;079c	21 43 c0 	! C . 
	inc (hl)			;079f	34 	4 
	jp l07d4h		;07a0	c3 d4 07 	. . . 
l07a3h:
	ld hl,0c01ah		;07a3	21 1a c0 	! . . 
	dec (hl)			;07a6	35 	5 
	jp z,l07b8h		;07a7	ca b8 07 	. . . 
	in a,(001h)		;07aa	db 01 	. . 
	bit 5,a		;07ac	cb 6f 	. o 
	jp z,l07c9h		;07ae	ca c9 07 	. . . 
	ld hl,0c04fh		;07b1	21 4f c0 	! O . 
	inc (hl)			;07b4	34 	4 
	jp l07d4h		;07b5	c3 d4 07 	. . . 
l07b8h:
	xor a			;07b8	af 	. 
	ld (0c00ch),a		;07b9	32 0c c0 	2 . . 
	ld (0c043h),a		;07bc	32 43 c0 	2 C . 
	ld a,(0c006h)		;07bf	3a 06 c0 	: . . 
	or 001h		;07c2	f6 01 	. . 
	ld (0c006h),a		;07c4	32 06 c0 	2 . . 
	out (086h),a		;07c7	d3 86 	. . 
l07c9h:
	xor a			;07c9	af 	. 
	ld (0c04fh),a		;07ca	32 4f c0 	2 O . 
	jp l07d4h		;07cd	c3 d4 07 	. . . 
l07d0h:
	xor a			;07d0	af 	. 
	ld (0c043h),a		;07d1	32 43 c0 	2 C . 
l07d4h:
	ld a,(0c014h)		;07d4	3a 14 c0 	: . . 
	and a			;07d7	a7 	. 
	jp z,l07f0h		;07d8	ca f0 07 	. . . 
	ld hl,0c022h		;07db	21 22 c0 	! " . 
	dec (hl)			;07de	35 	5 
	jp nz,l07f0h		;07df	c2 f0 07 	. . . 
	xor a			;07e2	af 	. 
	ld (0c014h),a		;07e3	32 14 c0 	2 . . 
	ld a,(0c005h)		;07e6	3a 05 c0 	: . . 
	or 010h		;07e9	f6 10 	. . 
	ld (0c005h),a		;07eb	32 05 c0 	2 . . 
	out (085h),a		;07ee	d3 85 	. . 
l07f0h:
	ld a,(0c015h)		;07f0	3a 15 c0 	: . . 
	and a			;07f3	a7 	. 
	jp z,l080ch		;07f4	ca 0c 08 	. . . 
	ld hl,0c023h		;07f7	21 23 c0 	! # . 
	dec (hl)			;07fa	35 	5 
	jp nz,l080ch		;07fb	c2 0c 08 	. . . 
	xor a			;07fe	af 	. 
	ld (0c015h),a		;07ff	32 15 c0 	2 . . 
l0802h:
	ld a,(0c005h)		;0802	3a 05 c0 	: . . 
	or 020h		;0805	f6 20 	.   
	ld (0c005h),a		;0807	32 05 c0 	2 . . 
	out (085h),a		;080a	d3 85 	. . 
l080ch:
	call sub_0a48h		;080c	cd 48 0a 	. H . 
	pop hl			;080f	e1 	. 
	pop de			;0810	d1 	. 
	pop bc			;0811	c1 	. 
	pop af			;0812	f1 	. 
	ei			;0813	fb 	. 
	reti		;0814	ed 4d 	. M 
l0816h:
	xor a			;0816	af 	. 
	ld (0c030h),a		;0817	32 30 c0 	2 0 . 
	ld a,(0c007h)		;081a	3a 07 c0 	: . . 
	and 0f0h		;081d	e6 f0 	. . 
	or 00ah		;081f	f6 0a 	. . 
	ld (0c007h),a		;0821	32 07 c0 	2 . . 
	out (087h),a		;0824	d3 87 	. . 
	ld a,(0c00eh)		;0826	3a 0e c0 	: . . 
	and a			;0829	a7 	. 
	jp nz,l083bh		;082a	c2 3b 08 	. ; . 
	in a,(001h)		;082d	db 01 	. . 
	bit 5,a		;082f	cb 6f 	. o 
	jp nz,l0868h		;0831	c2 68 08 	. h . 
	ld hl,0c045h		;0834	21 45 c0 	! E . 
	inc (hl)			;0837	34 	4 
	jp l086ch		;0838	c3 6c 08 	. l . 
l083bh:
	ld hl,0c01ch		;083b	21 1c c0 	! . . 
	dec (hl)			;083e	35 	5 
	jp z,l0850h		;083f	ca 50 08 	. P . 
	in a,(001h)		;0842	db 01 	. . 
	bit 5,a		;0844	cb 6f 	. o 
	jp z,l0861h		;0846	ca 61 08 	. a . 
	ld hl,0c051h		;0849	21 51 c0 	! Q . 
	inc (hl)			;084c	34 	4 
	jp l086ch		;084d	c3 6c 08 	. l . 
l0850h:
	xor a			;0850	af 	. 
	ld (0c00eh),a		;0851	32 0e c0 	2 . . 
	ld (0c045h),a		;0854	32 45 c0 	2 E . 
	ld a,(0c006h)		;0857	3a 06 c0 	: . . 
	or 004h		;085a	f6 04 	. . 
	ld (0c006h),a		;085c	32 06 c0 	2 . . 
	out (086h),a		;085f	d3 86 	. . 
l0861h:
	xor a			;0861	af 	. 
	ld (0c051h),a		;0862	32 51 c0 	2 Q . 
	jp l086ch		;0865	c3 6c 08 	. l . 
l0868h:
	xor a			;0868	af 	. 
	ld (0c045h),a		;0869	32 45 c0 	2 E . 
l086ch:
	ld a,(0c007h)		;086c	3a 07 c0 	: . . 
	and 0f0h		;086f	e6 f0 	. . 
	or 00bh		;0871	f6 0b 	. . 
	ld (0c007h),a		;0873	32 07 c0 	2 . . 
	out (087h),a		;0876	d3 87 	. . 
	ld a,(0c00fh)		;0878	3a 0f c0 	: . . 
	and a			;087b	a7 	. 
	jp nz,l088dh		;087c	c2 8d 08 	. . . 
	in a,(001h)		;087f	db 01 	. . 
	bit 5,a		;0881	cb 6f 	. o 
	jp nz,l08bah		;0883	c2 ba 08 	. . . 
	ld hl,0c046h		;0886	21 46 c0 	! F . 
	inc (hl)			;0889	34 	4 
	jp l08beh		;088a	c3 be 08 	. . . 
l088dh:
	ld hl,0c01dh		;088d	21 1d c0 	! . . 
	dec (hl)			;0890	35 	5 
	jp z,l08a2h		;0891	ca a2 08 	. . . 
	in a,(001h)		;0894	db 01 	. . 
	bit 5,a		;0896	cb 6f 	. o 
	jp z,l08b3h		;0898	ca b3 08 	. . . 
	ld hl,0c052h		;089b	21 52 c0 	! R . 
	inc (hl)			;089e	34 	4 
	jp l08beh		;089f	c3 be 08 	. . . 
l08a2h:
	xor a			;08a2	af 	. 
	ld (0c00fh),a		;08a3	32 0f c0 	2 . . 
	ld (0c046h),a		;08a6	32 46 c0 	2 F . 
	ld a,(0c006h)		;08a9	3a 06 c0 	: . . 
	or 008h		;08ac	f6 08 	. . 
	ld (0c006h),a		;08ae	32 06 c0 	2 . . 
	out (086h),a		;08b1	d3 86 	. . 
l08b3h:
	xor a			;08b3	af 	. 
	ld (0c052h),a		;08b4	32 52 c0 	2 R . 
	jp l08beh		;08b7	c3 be 08 	. . . 
l08bah:
	xor a			;08ba	af 	. 
	ld (0c046h),a		;08bb	32 46 c0 	2 F . 
l08beh:
	ld a,(0c007h)		;08be	3a 07 c0 	: . . 
	and 0f0h		;08c1	e6 f0 	. . 
	or 00ch		;08c3	f6 0c 	. . 
	ld (0c007h),a		;08c5	32 07 c0 	2 . . 
	out (087h),a		;08c8	d3 87 	. . 
	ld a,(0c010h)		;08ca	3a 10 c0 	: . . 
	and a			;08cd	a7 	. 
	jp nz,l08dfh		;08ce	c2 df 08 	. . . 
	in a,(001h)		;08d1	db 01 	. . 
	bit 5,a		;08d3	cb 6f 	. o 
	jp nz,l090ch		;08d5	c2 0c 09 	. . . 
	ld hl,0c047h		;08d8	21 47 c0 	! G . 
	inc (hl)			;08db	34 	4 
	jp l0910h		;08dc	c3 10 09 	. . . 
l08dfh:
	ld hl,0c01eh		;08df	21 1e c0 	! . . 
	dec (hl)			;08e2	35 	5 
	jp z,l08f4h		;08e3	ca f4 08 	. . . 
	in a,(001h)		;08e6	db 01 	. . 
	bit 5,a		;08e8	cb 6f 	. o 
	jp z,l0905h		;08ea	ca 05 09 	. . . 
	ld hl,0c053h		;08ed	21 53 c0 	! S . 
	inc (hl)			;08f0	34 	4 
	jp l0910h		;08f1	c3 10 09 	. . . 
l08f4h:
	xor a			;08f4	af 	. 
	ld (0c010h),a		;08f5	32 10 c0 	2 . . 
	ld (0c047h),a		;08f8	32 47 c0 	2 G . 
	ld a,(0c006h)		;08fb	3a 06 c0 	: . . 
	or 010h		;08fe	f6 10 	. . 
	ld (0c006h),a		;0900	32 06 c0 	2 . . 
	out (086h),a		;0903	d3 86 	. . 
l0905h:
	xor a			;0905	af 	. 
	ld (0c053h),a		;0906	32 53 c0 	2 S . 
	jp l0910h		;0909	c3 10 09 	. . . 
l090ch:
	xor a			;090c	af 	. 
	ld (0c047h),a		;090d	32 47 c0 	2 G . 
l0910h:
	ld a,(0c007h)		;0910	3a 07 c0 	: . . 
	and 0f0h		;0913	e6 f0 	. . 
	or 00dh		;0915	f6 0d 	. . 
	ld (0c007h),a		;0917	32 07 c0 	2 . . 
	out (087h),a		;091a	d3 87 	. . 
	ld a,(0c011h)		;091c	3a 11 c0 	: . . 
	and a			;091f	a7 	. 
	jp nz,l0931h		;0920	c2 31 09 	. 1 . 
	in a,(001h)		;0923	db 01 	. . 
	bit 5,a		;0925	cb 6f 	. o 
	jp nz,l095eh		;0927	c2 5e 09 	. ^ . 
	ld hl,0c048h		;092a	21 48 c0 	! H . 
	inc (hl)			;092d	34 	4 
	jp l0962h		;092e	c3 62 09 	. b . 
l0931h:
	ld hl,0c01fh		;0931	21 1f c0 	! . . 
	dec (hl)			;0934	35 	5 
	jp z,l0946h		;0935	ca 46 09 	. F . 
	in a,(001h)		;0938	db 01 	. . 
	bit 5,a		;093a	cb 6f 	. o 
	jp z,l0957h		;093c	ca 57 09 	. W . 
	ld hl,0c054h		;093f	21 54 c0 	! T . 
	inc (hl)			;0942	34 	4 
	jp l0962h		;0943	c3 62 09 	. b . 
l0946h:
	xor a			;0946	af 	. 
	ld (0c011h),a		;0947	32 11 c0 	2 . . 
	ld (0c048h),a		;094a	32 48 c0 	2 H . 
	ld a,(0c006h)		;094d	3a 06 c0 	: . . 
	or 020h		;0950	f6 20 	.   
	ld (0c006h),a		;0952	32 06 c0 	2 . . 
	out (086h),a		;0955	d3 86 	. . 
l0957h:
	xor a			;0957	af 	. 
	ld (0c054h),a		;0958	32 54 c0 	2 T . 
	jp l0962h		;095b	c3 62 09 	. b . 
l095eh:
	xor a			;095e	af 	. 
	ld (0c048h),a		;095f	32 48 c0 	2 H . 
l0962h:
	ld a,(0c007h)		;0962	3a 07 c0 	: . . 
	and 0f0h		;0965	e6 f0 	. . 
	or 00eh		;0967	f6 0e 	. . 
	ld (0c007h),a		;0969	32 07 c0 	2 . . 
	out (087h),a		;096c	d3 87 	. . 
	ld a,(0c012h)		;096e	3a 12 c0 	: . . 
	and a			;0971	a7 	. 
	jp nz,l0983h		;0972	c2 83 09 	. . . 
	in a,(001h)		;0975	db 01 	. . 
	bit 5,a		;0977	cb 6f 	. o 
	jp nz,l09b0h		;0979	c2 b0 09 	. . . 
	ld hl,0c049h		;097c	21 49 c0 	! I . 
	inc (hl)			;097f	34 	4 
	jp l09b4h		;0980	c3 b4 09 	. . . 
l0983h:
	ld hl,0c020h		;0983	21 20 c0 	!   . 
	dec (hl)			;0986	35 	5 
	jp z,l0998h		;0987	ca 98 09 	. . . 
	in a,(001h)		;098a	db 01 	. . 
	bit 5,a		;098c	cb 6f 	. o 
	jp z,l09a9h		;098e	ca a9 09 	. . . 
	ld hl,0c055h		;0991	21 55 c0 	! U . 
	inc (hl)			;0994	34 	4 
	jp l09b4h		;0995	c3 b4 09 	. . . 
l0998h:
	xor a			;0998	af 	. 
	ld (0c012h),a		;0999	32 12 c0 	2 . . 
	ld (0c049h),a		;099c	32 49 c0 	2 I . 
	ld a,(0c006h)		;099f	3a 06 c0 	: . . 
	or 040h		;09a2	f6 40 	. @ 
	ld (0c006h),a		;09a4	32 06 c0 	2 . . 
	out (086h),a		;09a7	d3 86 	. . 
l09a9h:
	xor a			;09a9	af 	. 
	ld (0c055h),a		;09aa	32 55 c0 	2 U . 
	jp l09b4h		;09ad	c3 b4 09 	. . . 
l09b0h:
	xor a			;09b0	af 	. 
	ld (0c049h),a		;09b1	32 49 c0 	2 I . 
l09b4h:
	ld a,(0c007h)		;09b4	3a 07 c0 	: . . 
	and 0f0h		;09b7	e6 f0 	. . 
	or 00fh		;09b9	f6 0f 	. . 
	ld (0c007h),a		;09bb	32 07 c0 	2 . . 
	out (087h),a		;09be	d3 87 	. . 
	ld a,(0c013h)		;09c0	3a 13 c0 	: . . 
	and a			;09c3	a7 	. 
	jp nz,l09d5h		;09c4	c2 d5 09 	. . . 
	in a,(001h)		;09c7	db 01 	. . 
	bit 5,a		;09c9	cb 6f 	. o 
	jp nz,l0a02h		;09cb	c2 02 0a 	. . . 
	ld hl,0c04ah		;09ce	21 4a c0 	! J . 
	inc (hl)			;09d1	34 	4 
	jp l0a06h		;09d2	c3 06 0a 	. . . 
l09d5h:
	ld hl,0c021h		;09d5	21 21 c0 	! ! . 
	dec (hl)			;09d8	35 	5 
	jp z,l09eah		;09d9	ca ea 09 	. . . 
	in a,(001h)		;09dc	db 01 	. . 
	bit 5,a		;09de	cb 6f 	. o 
	jp z,l09fbh		;09e0	ca fb 09 	. . . 
	ld hl,0c056h		;09e3	21 56 c0 	! V . 
	inc (hl)			;09e6	34 	4 
	jp l0a06h		;09e7	c3 06 0a 	. . . 
l09eah:
	xor a			;09ea	af 	. 
	ld (0c013h),a		;09eb	32 13 c0 	2 . . 
	ld (0c04ah),a		;09ee	32 4a c0 	2 J . 
	ld a,(0c006h)		;09f1	3a 06 c0 	: . . 
	or 080h		;09f4	f6 80 	. . 
	ld (0c006h),a		;09f6	32 06 c0 	2 . . 
	out (086h),a		;09f9	d3 86 	. . 
l09fbh:
	xor a			;09fb	af 	. 
	ld (0c056h),a		;09fc	32 56 c0 	2 V . 
	jp l0a06h		;09ff	c3 06 0a 	. . . 
l0a02h:
	xor a			;0a02	af 	. 
	ld (0c04ah),a		;0a03	32 4a c0 	2 J . 
l0a06h:
	ld a,(0c016h)		;0a06	3a 16 c0 	: . . 
	and a			;0a09	a7 	. 
	jp z,l0a22h		;0a0a	ca 22 0a 	. " . 
	ld hl,0c024h		;0a0d	21 24 c0 	! $ . 
	dec (hl)			;0a10	35 	5 
	jp nz,l0a22h		;0a11	c2 22 0a 	. " . 
	xor a			;0a14	af 	. 
	ld (0c016h),a		;0a15	32 16 c0 	2 . . 
	ld a,(0c005h)		;0a18	3a 05 c0 	: . . 
	or 040h		;0a1b	f6 40 	. @ 
	ld (0c005h),a		;0a1d	32 05 c0 	2 . . 
	out (085h),a		;0a20	d3 85 	. . 
l0a22h:
	ld a,(0c017h)		;0a22	3a 17 c0 	: . . 
	and a			;0a25	a7 	. 
	jp z,l0a3eh		;0a26	ca 3e 0a 	. > . 
	ld hl,0c025h		;0a29	21 25 c0 	! % . 
	dec (hl)			;0a2c	35 	5 
	jp nz,l0a3eh		;0a2d	c2 3e 0a 	. > . 
	xor a			;0a30	af 	. 
	ld (0c017h),a		;0a31	32 17 c0 	2 . . 
	ld a,(0c005h)		;0a34	3a 05 c0 	: . . 
	or 080h		;0a37	f6 80 	. . 
	ld (0c005h),a		;0a39	32 05 c0 	2 . . 
	out (085h),a		;0a3c	d3 85 	. . 
l0a3eh:
	call sub_0a67h		;0a3e	cd 67 0a 	. g . 
	pop hl			;0a41	e1 	. 
	pop de			;0a42	d1 	. 
	pop bc			;0a43	c1 	. 
	pop af			;0a44	f1 	. 
	ei			;0a45	fb 	. 
	reti		;0a46	ed 4d 	. M 
sub_0a48h:
	ld hl,0c031h		;0a48	21 31 c0 	! 1 . 
	dec (hl)			;0a4b	35 	5 
	ret nz			;0a4c	c0 	. 
	ld (hl),030h		;0a4d	36 30 	6 0 
	ld a,(0c001h)		;0a4f	3a 01 c0 	: . . 
	bit 3,a		;0a52	cb 5f 	. _ 
	jp z,l0a5fh		;0a54	ca 5f 0a 	. _ . 
	res 3,a		;0a57	cb 9f 	. . 
	ld (0c001h),a		;0a59	32 01 c0 	2 . . 
	out (081h),a		;0a5c	d3 81 	. . 
	ret			;0a5e	c9 	. 
l0a5fh:
	set 3,a		;0a5f	cb df 	. . 
	ld (0c001h),a		;0a61	32 01 c0 	2 . . 
	out (081h),a		;0a64	d3 81 	. . 
	ret			;0a66	c9 	. 
sub_0a67h:
	ld hl,(0c033h)		;0a67	2a 33 c0 	* 3 . 
	ld de,l0000h		;0a6a	11 00 00 	. . . 
	xor a			;0a6d	af 	. 
	sbc hl,de		;0a6e	ed 52 	. R 
	jp z,l0a7ah		;0a70	ca 7a 0a 	. z . 
	dec hl			;0a73	2b 	+ 
	ld (0c033h),hl		;0a74	22 33 c0 	" 3 . 
	jp l0a7dh		;0a77	c3 7d 0a 	. } . 
l0a7ah:
	ld (0c035h),a		;0a7a	32 35 c0 	2 5 . 
l0a7dh:
	ld hl,(0c036h)		;0a7d	2a 36 c0 	* 6 . 
	ld de,l0000h		;0a80	11 00 00 	. . . 
	xor a			;0a83	af 	. 
	sbc hl,de		;0a84	ed 52 	. R 
	jp z,l0a90h		;0a86	ca 90 0a 	. . . 
	dec hl			;0a89	2b 	+ 
	ld (0c036h),hl		;0a8a	22 36 c0 	" 6 . 
	jp l0a93h		;0a8d	c3 93 0a 	. . . 
l0a90h:
	ld (0c038h),a		;0a90	32 38 c0 	2 8 . 
l0a93h:
	ld hl,(0c02ah)		;0a93	2a 2a c0 	* * . 
	ld de,l0000h		;0a96	11 00 00 	. . . 
	xor a			;0a99	af 	. 
	sbc hl,de		;0a9a	ed 52 	. R 
	jp z,l0aa3h		;0a9c	ca a3 0a 	. . . 
	dec hl			;0a9f	2b 	+ 
	ld (0c02ah),hl		;0aa0	22 2a c0 	" * . 
l0aa3h:
	ld hl,(0c02ch)		;0aa3	2a 2c c0 	* , . 
	ld de,l0000h		;0aa6	11 00 00 	. . . 
	xor a			;0aa9	af 	. 
	sbc hl,de		;0aaa	ed 52 	. R 
	jp z,l0ab3h		;0aac	ca b3 0a 	. . . 
	dec hl			;0aaf	2b 	+ 
	ld (0c02ch),hl		;0ab0	22 2c c0 	" , . 
l0ab3h:
	ld hl,0c061h		;0ab3	21 61 c0 	! a . 
	ld a,(hl)			;0ab6	7e 	~ 
	and a			;0ab7	a7 	. 
	jp z,l0abch		;0ab8	ca bc 0a 	. . . 
	dec (hl)			;0abb	35 	5 
l0abch:
	inc hl			;0abc	23 	# 
	ld a,(hl)			;0abd	7e 	~ 
	and a			;0abe	a7 	. 
	ret z			;0abf	c8 	. 
	dec (hl)			;0ac0	35 	5 
	ret			;0ac1	c9 	. 
l0ac2h:
	ld (0df3ah),a		;0ac2	32 3a df 	2 : . 
	ret nz			;0ac5	c0 	. 
	bit 5,a		;0ac6	cb 6f 	. o 
	jp z,l0ad2h		;0ac8	ca d2 0a 	. . . 
	ld a,(l0ac2h)		;0acb	3a c2 0a 	: . . 
	ld (0c032h),a		;0ace	32 32 c0 	2 2 . 
	ret			;0ad1	c9 	. 
l0ad2h:
	ld a,(0c032h)		;0ad2	3a 32 c0 	: 2 . 
	and a			;0ad5	a7 	. 
	jp z,l0adeh		;0ad6	ca de 0a 	. . . 
	dec a			;0ad9	3d 	= 
	ld (0c032h),a		;0ada	32 32 c0 	2 2 . 
	ret			;0add	c9 	. 
l0adeh:
	ld a,020h		;0ade	3e 20 	>   
	call sub_30aah		;0ae0	cd aa 30 	. . 0 
	ld a,(0c05bh)		;0ae3	3a 5b c0 	: [ . 
	and a			;0ae6	a7 	. 
	jp nz,l0af2h		;0ae7	c2 f2 0a 	. . . 
	ld a,037h		;0aea	3e 37 	> 7 
	ld (0c0feh),a		;0aec	32 fe c0 	2 . . 
	jp sub_0afah		;0aef	c3 fa 0a 	. . . 
l0af2h:
	ld a,039h		;0af2	3e 39 	> 9 
	ld (0c0feh),a		;0af4	32 fe c0 	2 . . 
	jp sub_0afah		;0af7	c3 fa 0a 	. . . 
sub_0afah:
	di			;0afa	f3 	. 
	ld a,(0c001h)		;0afb	3a 01 c0 	: . . 
	or 002h		;0afe	f6 02 	. . 
	out (081h),a		;0b00	d3 81 	. . 
	ld a,(0c0feh)		;0b02	3a fe c0 	: . . 
	out (080h),a		;0b05	d3 80 	. . 
	ld a,(0c001h)		;0b07	3a 01 c0 	: . . 
	or 004h		;0b0a	f6 04 	. . 
	out (081h),a		;0b0c	d3 81 	. . 
	ld (0c001h),a		;0b0e	32 01 c0 	2 . . 
	ld a,(0c001h)		;0b11	3a 01 c0 	: . . 
	and 0fbh		;0b14	e6 fb 	. . 
	ld (0c001h),a		;0b16	32 01 c0 	2 . . 
	out (081h),a		;0b19	d3 81 	. . 
	ei			;0b1b	fb 	. 
	ret			;0b1c	c9 	. 
	in a,(004h)		;0b1d	db 04 	. . 
	bit 4,a		;0b1f	cb 67 	. g 
	jp z,l0b93h		;0b21	ca 93 0b 	. . . 
	call sub_277ch		;0b24	cd 7c 27 	. | ' 
	call sub_0bcfh		;0b27	cd cf 0b 	. . . 
	call sub_0b31h		;0b2a	cd 31 0b 	. 1 . 
	call sub_27b5h		;0b2d	cd b5 27 	. . ' 
	ret			;0b30	c9 	. 
sub_0b31h:
	in a,(004h)		;0b31	db 04 	. . 
	bit 4,a		;0b33	cb 67 	. g 
	jp z,l0b93h		;0b35	ca 93 0b 	. . . 
	xor a			;0b38	af 	. 
	ld (0c066h),a		;0b39	32 66 c0 	2 f . 
	call sub_2bfdh		;0b3c	cd fd 2b 	. . + 
	call sub_0edeh		;0b3f	cd de 0e 	. . . 
	call sub_2ff3h		;0b42	cd f3 2f 	. . / 
	ld a,(0c0dbh)		;0b45	3a db c0 	: . . 
	ld (0c063h),a		;0b48	32 63 c0 	2 c . 
	ld a,(0c063h)		;0b4b	3a 63 c0 	: c . 
	or 0dfh		;0b4e	f6 df 	. . 
	cp 0dfh		;0b50	fe df 	. . 
	jp z,l0b93h		;0b52	ca 93 0b 	. . . 
	ld a,(0c063h)		;0b55	3a 63 c0 	: c . 
	or 07fh		;0b58	f6 7f 	.  
	cp 07fh		;0b5a	fe 7f 	.  
	jp z,l0b93h		;0b5c	ca 93 0b 	. . . 
	ld a,(0c063h)		;0b5f	3a 63 c0 	: c . 
	or 0fbh		;0b62	f6 fb 	. . 
	cp 0fbh		;0b64	fe fb 	. . 
	jp z,l0ba5h		;0b66	ca a5 0b 	. . . 
	ld a,001h		;0b69	3e 01 	> . 
	ld (0c066h),a		;0b6b	32 66 c0 	2 f . 
	call sub_0bb0h		;0b6e	cd b0 0b 	. . . 
l0b71h:
	ld a,(0c066h)		;0b71	3a 66 c0 	: f . 
	cp 001h		;0b74	fe 01 	. . 
	jp z,l0b7ch		;0b76	ca 7c 0b 	. | . 
	jp l0b87h		;0b79	c3 87 0b 	. . . 
l0b7ch:
	ld a,05bh		;0b7c	3e 5b 	> [ 
	ld (0c0feh),a		;0b7e	32 fe c0 	2 . . 
	call sub_0afah		;0b81	cd fa 0a 	. . . 
	jp l0b87h		;0b84	c3 87 0b 	. . . 
l0b87h:
	ld hl,l0514h		;0b87	21 14 05 	! . . 
	ld (0c033h),hl		;0b8a	22 33 c0 	" 3 . 
	call sub_0bd5h		;0b8d	cd d5 0b 	. . . 
	jp sub_0b31h		;0b90	c3 31 0b 	. 1 . 
l0b93h:
	xor a			;0b93	af 	. 
	ld (0c03bh),a		;0b94	32 3b c0 	2 ; . 
	ld (0c067h),a		;0b97	32 67 c0 	2 g . 
	ld (0c068h),a		;0b9a	32 68 c0 	2 h . 
	ld a,05dh		;0b9d	3e 5d 	> ] 
	ld (0c0feh),a		;0b9f	32 fe c0 	2 . . 
	jp sub_0afah		;0ba2	c3 fa 0a 	. . . 
l0ba5h:
	call sub_0bb0h		;0ba5	cd b0 0b 	. . . 
	ld a,001h		;0ba8	3e 01 	> . 
	ld (0c066h),a		;0baa	32 66 c0 	2 f . 
	jp l0b71h		;0bad	c3 71 0b 	. q . 
sub_0bb0h:
	call sub_0393h		;0bb0	cd 93 03 	. . . 
	call sub_0bcfh		;0bb3	cd cf 0b 	. . . 
	call sub_03b2h		;0bb6	cd b2 03 	. . . 
	call sub_0bcfh		;0bb9	cd cf 0b 	. . . 
	call sub_0355h		;0bbc	cd 55 03 	. U . 
	call sub_0bcfh		;0bbf	cd cf 0b 	. . . 
	call sub_0374h		;0bc2	cd 74 03 	. t . 
	call sub_0bcfh		;0bc5	cd cf 0b 	. . . 
	call sub_0317h		;0bc8	cd 17 03 	. . . 
	call sub_0bcfh		;0bcb	cd cf 0b 	. . . 
	ret			;0bce	c9 	. 
sub_0bcfh:
	ld hl,l0064h		;0bcf	21 64 00 	! d . 
	ld (0c033h),hl		;0bd2	22 33 c0 	" 3 . 
sub_0bd5h:
	ld a,0ffh		;0bd5	3e ff 	> . 
	ld (0c035h),a		;0bd7	32 35 c0 	2 5 . 
l0bdah:
	ld a,(0c035h)		;0bda	3a 35 c0 	: 5 . 
	and a			;0bdd	a7 	. 
	jp nz,l0bdah		;0bde	c2 da 0b 	. . . 
	ret			;0be1	c9 	. 
l0be2h:
	call sub_2bach		;0be2	cd ac 2b 	. . + 
	call sub_0c0ch		;0be5	cd 0c 0c 	. . . 
	call sub_0d2fh		;0be8	cd 2f 0d 	. / . 
	call sub_10ffh		;0beb	cd ff 10 	. . . 
	ld a,(0c0dfh)		;0bee	3a df c0 	: . . 
	or 08ch		;0bf1	f6 8c 	. . 
	cp 0ffh		;0bf3	fe ff 	. . 
	call nz,sub_0dcbh		;0bf5	c4 cb 0d 	. . . 
	ld a,(0c03eh)		;0bf8	3a 3e c0 	: > . 
	and a			;0bfb	a7 	. 
	jp nz,l0be2h		;0bfc	c2 e2 0b 	. . . 
	ld a,(0c11bh)		;0bff	3a 1b c1 	: . . 
	and a			;0c02	a7 	. 
	jp nz,l0be2h		;0c03	c2 e2 0b 	. . . 
	call sub_3401h		;0c06	cd 01 34 	. . 4 
	jp l0be2h		;0c09	c3 e2 0b 	. . . 
sub_0c0ch:
	in a,(003h)		;0c0c	db 03 	. . 
	bit 3,a		;0c0e	cb 5f 	. _ 
	call z,sub_0e30h		;0c10	cc 30 0e 	. 0 . 
	ld a,(0c00ah)		;0c13	3a 0a c0 	: . . 
	ld hl,0c008h		;0c16	21 08 c0 	! . . 
	or (hl)			;0c19	b6 	. 
	jp z,l0c24h		;0c1a	ca 24 0c 	. $ . 
	in a,(003h)		;0c1d	db 03 	. . 
	bit 3,a		;0c1f	cb 5f 	. _ 
	call nz,l0514h		;0c21	c4 14 05 	. . . 
l0c24h:
	in a,(003h)		;0c24	db 03 	. . 
	bit 2,a		;0c26	cb 57 	. W 
	call z,sub_0e76h		;0c28	cc 76 0e 	. v . 
	ld a,(0c00bh)		;0c2b	3a 0b c0 	: . . 
	ld hl,0c009h		;0c2e	21 09 c0 	! . . 
	or (hl)			;0c31	b6 	. 
	jp z,l0c3ch		;0c32	ca 3c 0c 	. < . 
	in a,(003h)		;0c35	db 03 	. . 
	bit 2,a		;0c37	cb 57 	. W 
	call nz,sub_0539h		;0c39	c4 39 05 	. 9 . 
l0c3ch:
	ld a,(0c05dh)		;0c3c	3a 5d c0 	: ] . 
	and a			;0c3f	a7 	. 
	call z,l0514h		;0c40	cc 14 05 	. . . 
	ld a,(0c05dh)		;0c43	3a 5d c0 	: ] . 
	and a			;0c46	a7 	. 
	call z,sub_0539h		;0c47	cc 39 05 	. 9 . 
	ret			;0c4a	c9 	. 
	ld a,007h		;0c4b	3e 07 	> . 
	ld (0c0feh),a		;0c4d	32 fe c0 	2 . . 
	call sub_0afah		;0c50	cd fa 0a 	. . . 
l0c53h:
	in a,(003h)		;0c53	db 03 	. . 
	bit 3,a		;0c55	cb 5f 	. _ 
	jp nz,l0ca7h		;0c57	c2 a7 0c 	. . . 
	call sub_2bach		;0c5a	cd ac 2b 	. . + 
	call sub_0d2fh		;0c5d	cd 2f 0d 	. / . 
	call sub_10ffh		;0c60	cd ff 10 	. . . 
	ld a,(0c0dfh)		;0c63	3a df c0 	: . . 
	or 080h		;0c66	f6 80 	. . 
	cp 0ffh		;0c68	fe ff 	. . 
	call nz,sub_0dcbh		;0c6a	c4 cb 0d 	. . . 
	in a,(003h)		;0c6d	db 03 	. . 
	bit 3,a		;0c6f	cb 5f 	. _ 
	call z,sub_0e30h		;0c71	cc 30 0e 	. 0 . 
	in a,(003h)		;0c74	db 03 	. . 
	bit 2,a		;0c76	cb 57 	. W 
	call z,sub_0e76h		;0c78	cc 76 0e 	. v . 
	ld a,(0c00bh)		;0c7b	3a 0b c0 	: . . 
	ld hl,0c009h		;0c7e	21 09 c0 	! . . 
	or (hl)			;0c81	b6 	. 
	jp z,l0c8ch		;0c82	ca 8c 0c 	. . . 
	in a,(003h)		;0c85	db 03 	. . 
	bit 2,a		;0c87	cb 57 	. W 
	call nz,sub_0539h		;0c89	c4 39 05 	. 9 . 
l0c8ch:
	ld hl,l0000h		;0c8c	21 00 00 	! . . 
	ld (0c028h),hl		;0c8f	22 28 c0 	" ( . 
	xor a			;0c92	af 	. 
	ld (0c05fh),a		;0c93	32 5f c0 	2 _ . 
	ld a,(0c05dh)		;0c96	3a 5d c0 	: ] . 
	and a			;0c99	a7 	. 
	call z,l0514h		;0c9a	cc 14 05 	. . . 
	ld a,(0c05dh)		;0c9d	3a 5d c0 	: ] . 
	and a			;0ca0	a7 	. 
	call z,sub_0539h		;0ca1	cc 39 05 	. 9 . 
	jp l0c53h		;0ca4	c3 53 0c 	. S . 
l0ca7h:
	ld a,025h		;0ca7	3e 25 	> % 
	ld (0c0feh),a		;0ca9	32 fe c0 	2 . . 
	call sub_0afah		;0cac	cd fa 0a 	. . . 
	call l0514h		;0caf	cd 14 05 	. . . 
	xor a			;0cb2	af 	. 
	ld (0c05eh),a		;0cb3	32 5e c0 	2 ^ . 
	ld hl,l0000h		;0cb6	21 00 00 	! . . 
	ld (0c026h),hl		;0cb9	22 26 c0 	" & . 
	ret			;0cbc	c9 	. 
	ld a,007h		;0cbd	3e 07 	> . 
	ld (0c0feh),a		;0cbf	32 fe c0 	2 . . 
	call sub_0afah		;0cc2	cd fa 0a 	. . . 
l0cc5h:
	in a,(003h)		;0cc5	db 03 	. . 
	bit 2,a		;0cc7	cb 57 	. W 
	jp nz,l0d19h		;0cc9	c2 19 0d 	. . . 
	call sub_2bach		;0ccc	cd ac 2b 	. . + 
	call sub_0d2fh		;0ccf	cd 2f 0d 	. / . 
	call sub_10ffh		;0cd2	cd ff 10 	. . . 
	ld a,(0c0dfh)		;0cd5	3a df c0 	: . . 
	or 080h		;0cd8	f6 80 	. . 
	cp 0ffh		;0cda	fe ff 	. . 
	call nz,sub_0dcbh		;0cdc	c4 cb 0d 	. . . 
	in a,(003h)		;0cdf	db 03 	. . 
	bit 2,a		;0ce1	cb 57 	. W 
	call z,sub_0e76h		;0ce3	cc 76 0e 	. v . 
	in a,(003h)		;0ce6	db 03 	. . 
	bit 3,a		;0ce8	cb 5f 	. _ 
	call z,sub_0e30h		;0cea	cc 30 0e 	. 0 . 
	ld a,(0c00ah)		;0ced	3a 0a c0 	: . . 
	ld hl,0c008h		;0cf0	21 08 c0 	! . . 
	or (hl)			;0cf3	b6 	. 
	jp z,l0cfeh		;0cf4	ca fe 0c 	. . . 
	in a,(003h)		;0cf7	db 03 	. . 
	bit 3,a		;0cf9	cb 5f 	. _ 
	call nz,l0514h		;0cfb	c4 14 05 	. . . 
l0cfeh:
	ld hl,l0000h		;0cfe	21 00 00 	! . . 
	ld (0c026h),hl		;0d01	22 26 c0 	" & . 
	xor a			;0d04	af 	. 
	ld (0c05eh),a		;0d05	32 5e c0 	2 ^ . 
	ld a,(0c05dh)		;0d08	3a 5d c0 	: ] . 
	and a			;0d0b	a7 	. 
	call z,l0514h		;0d0c	cc 14 05 	. . . 
	ld a,(0c05dh)		;0d0f	3a 5d c0 	: ] . 
	and a			;0d12	a7 	. 
	call z,sub_0539h		;0d13	cc 39 05 	. 9 . 
	jp l0cc5h		;0d16	c3 c5 0c 	. . . 
l0d19h:
	ld a,025h		;0d19	3e 25 	> % 
	ld (0c0feh),a		;0d1b	32 fe c0 	2 . . 
	call sub_0afah		;0d1e	cd fa 0a 	. . . 
	call sub_0539h		;0d21	cd 39 05 	. 9 . 
	xor a			;0d24	af 	. 
	ld (0c05fh),a		;0d25	32 5f c0 	2 _ . 
	ld hl,l0000h		;0d28	21 00 00 	! . . 
	ld (0c028h),hl		;0d2b	22 28 c0 	" ( . 
	ret			;0d2e	c9 	. 
sub_0d2fh:
	in a,(004h)		;0d2f	db 04 	. . 
	bit 0,a		;0d31	cb 47 	. G 
	ret nz			;0d33	c0 	. 
	ld a,(0c03eh)		;0d34	3a 3e c0 	: > . 
	and a			;0d37	a7 	. 
	ret z			;0d38	c8 	. 
	ld hl,0c03fh		;0d39	21 3f c0 	! ? . 
	ld de,l0db1h		;0d3c	11 b1 0d 	. . . 
	ld b,00ch		;0d3f	06 0c 	. . 
	ld a,0f0h		;0d41	3e f0 	> . 
l0d43h:
	cp (hl)			;0d43	be 	. 
	jp c,l0d90h		;0d44	da 90 0d 	. . . 
	inc hl			;0d47	23 	# 
	inc de			;0d48	13 	. 
	djnz l0d43h		;0d49	10 f8 	. . 
	ld b,00ch		;0d4b	06 0c 	. . 
	ld a,008h		;0d4d	3e 08 	> . 
l0d4fh:
	cp (hl)			;0d4f	be 	. 
	jp c,l0da2h		;0d50	da a2 0d 	. . . 
	inc hl			;0d53	23 	# 
	inc de			;0d54	13 	. 
	djnz l0d4fh		;0d55	10 f8 	. . 
	ld a,(0c06dh)		;0d57	3a 6d c0 	: m . 
	and a			;0d5a	a7 	. 
	ret nz			;0d5b	c0 	. 
	ld a,(0c057h)		;0d5c	3a 57 c0 	: W . 
	and a			;0d5f	a7 	. 
	jp z,l0d78h		;0d60	ca 78 0d 	. x . 
	ld a,(0c059h)		;0d63	3a 59 c0 	: Y . 
	and a			;0d66	a7 	. 
	jp nz,l0d78h		;0d67	c2 78 0d 	. x . 
	ld a,0ffh		;0d6a	3e ff 	> . 
	ld (0c059h),a		;0d6c	32 59 c0 	2 Y . 
	ld a,(l0dc9h)		;0d6f	3a c9 0d 	: . . 
	ld (0c0feh),a		;0d72	32 fe c0 	2 . . 
	jp sub_0afah		;0d75	c3 fa 0a 	. . . 
l0d78h:
	ld a,(0c058h)		;0d78	3a 58 c0 	: X . 
	and a			;0d7b	a7 	. 
	ret z			;0d7c	c8 	. 
	ld a,(0c05ah)		;0d7d	3a 5a c0 	: Z . 
	and a			;0d80	a7 	. 
	ret nz			;0d81	c0 	. 
	ld a,0ffh		;0d82	3e ff 	> . 
	ld (0c05ah),a		;0d84	32 5a c0 	2 Z . 
	ld a,(l0dcah)		;0d87	3a ca 0d 	: . . 
	ld (0c0feh),a		;0d8a	32 fe c0 	2 . . 
	jp sub_0afah		;0d8d	c3 fa 0a 	. . . 
l0d90h:
	ld a,(de)			;0d90	1a 	. 
	ld (0c03ah),a		;0d91	32 3a c0 	2 : . 
	ld (hl),000h		;0d94	36 00 	6 . 
	call sub_27b5h		;0d96	cd b5 27 	. . ' 
	ld a,(0c03ah)		;0d99	3a 3a c0 	: : . 
	ld (0c0feh),a		;0d9c	32 fe c0 	2 . . 
	jp sub_0afah		;0d9f	c3 fa 0a 	. . . 
l0da2h:
	ld a,(de)			;0da2	1a 	. 
	ld (0c03ah),a		;0da3	32 3a c0 	2 : . 
	ld (hl),000h		;0da6	36 00 	6 . 
	ld a,(0c03ah)		;0da8	3a 3a c0 	: : . 
	ld (0c0feh),a		;0dab	32 fe c0 	2 . . 
	jp sub_0afah		;0dae	c3 fa 0a 	. . . 
l0db1h:
	ld b,c			;0db1	41 	A 
	ld b,d			;0db2	42 	B 
	ld b,e			;0db3	43 	C 
	ld b,h			;0db4	44 	D 
	ld c,h			;0db5	4c 	L 
	ld b,a			;0db6	47 	G 
	ld c,d			;0db7	4a 	J 
	ld c,e			;0db8	4b 	K 
	ld c,c			;0db9	49 	I 
	ld b,l			;0dba	45 	E 
	ld b,(hl)			;0dbb	46 	F 
	ld c,b			;0dbc	48 	H 
	ld c,l			;0dbd	4d 	M 
	ld c,(hl)			;0dbe	4e 	N 
	ld c,a			;0dbf	4f 	O 
	ld d,b			;0dc0	50 	P 
	ld e,b			;0dc1	58 	X 
	ld d,e			;0dc2	53 	S 
	ld d,(hl)			;0dc3	56 	V 
	ld d,a			;0dc4	57 	W 
	ld d,l			;0dc5	55 	U 
	ld d,c			;0dc6	51 	Q 
	ld d,d			;0dc7	52 	R 
	ld d,h			;0dc8	54 	T 
l0dc9h:
	ld e,c			;0dc9	59 	Y 
l0dcah:
	ld e,d			;0dca	5a 	Z 
sub_0dcbh:
	ld a,(0c0dfh)		;0dcb	3a df c0 	: . . 
	bit 0,a		;0dce	cb 47 	. G 
	call z,sub_0dech		;0dd0	cc ec 0d 	. . . 
	ld a,(0c0dfh)		;0dd3	3a df c0 	: . . 
	bit 1,a		;0dd6	cb 4f 	. O 
	call z,sub_0e09h		;0dd8	cc 09 0e 	. . . 
	ld a,(0c0dfh)		;0ddb	3a df c0 	: . . 
	bit 4,a		;0dde	cb 67 	. g 
	call z,sub_0e16h		;0de0	cc 16 0e 	. . . 
	ld a,(0c0dfh)		;0de3	3a df c0 	: . . 
	bit 6,a		;0de6	cb 77 	. w 
	call z,sub_0e23h		;0de8	cc 23 0e 	. # . 
	ret			;0deb	c9 	. 
sub_0dech:
	ld a,001h		;0dec	3e 01 	> . 
	call sub_30aah		;0dee	cd aa 30 	. . 0 
	ld a,(0c038h)		;0df1	3a 38 c0 	: 8 . 
	and a			;0df4	a7 	. 
	ret nz			;0df5	c0 	. 
	ld hl,00bb8h		;0df6	21 b8 0b 	! . . 
	ld (0c036h),hl		;0df9	22 36 c0 	" 6 . 
	ld a,0ffh		;0dfc	3e ff 	> . 
	ld (0c038h),a		;0dfe	32 38 c0 	2 8 . 
	ld a,032h		;0e01	3e 32 	> 2 
	ld (0c0feh),a		;0e03	32 fe c0 	2 . . 
	jp sub_0afah		;0e06	c3 fa 0a 	. . . 
sub_0e09h:
	ld a,002h		;0e09	3e 02 	> . 
	call sub_30aah		;0e0b	cd aa 30 	. . 0 
	ld a,033h		;0e0e	3e 33 	> 3 
	ld (0c0feh),a		;0e10	32 fe c0 	2 . . 
	jp sub_0afah		;0e13	c3 fa 0a 	. . . 
sub_0e16h:
	ld a,010h		;0e16	3e 10 	> . 
	call sub_30aah		;0e18	cd aa 30 	. . 0 
	ld a,036h		;0e1b	3e 36 	> 6 
	ld (0c0feh),a		;0e1d	32 fe c0 	2 . . 
	jp sub_0afah		;0e20	c3 fa 0a 	. . . 
sub_0e23h:
	ld a,040h		;0e23	3e 40 	> @ 
	call sub_30aah		;0e25	cd aa 30 	. . 0 
	ld a,038h		;0e28	3e 38 	> 8 
	ld (0c0feh),a		;0e2a	32 fe c0 	2 . . 
	jp sub_0afah		;0e2d	c3 fa 0a 	. . . 
sub_0e30h:
	ld a,(0c05bh)		;0e30	3a 5b c0 	: [ . 
	and a			;0e33	a7 	. 
	jp nz,l0e64h		;0e34	c2 64 0e 	. d . 
	ld a,(0c05ch)		;0e37	3a 5c c0 	: \ . 
	and a			;0e3a	a7 	. 
	jp nz,l0e64h		;0e3b	c2 64 0e 	. d . 
	ld a,(0c05dh)		;0e3e	3a 5d c0 	: ] . 
	and a			;0e41	a7 	. 
	ret z			;0e42	c8 	. 
	ld a,(0c0dah)		;0e43	3a da c0 	: . . 
	bit 3,a		;0e46	cb 5f 	. _ 
	jp z,l0e5bh		;0e48	ca 5b 0e 	. [ . 
	ld a,(0c057h)		;0e4b	3a 57 c0 	: W . 
	and a			;0e4e	a7 	. 
	jp nz,l0e5bh		;0e4f	c2 5b 0e 	. [ . 
	ld a,(0c008h)		;0e52	3a 08 c0 	: . . 
	and a			;0e55	a7 	. 
	ret nz			;0e56	c0 	. 
	call sub_0466h		;0e57	cd 66 04 	. f . 
	ret			;0e5a	c9 	. 
l0e5bh:
	ld a,(0c00ah)		;0e5b	3a 0a c0 	: . . 
	and a			;0e5e	a7 	. 
	ret nz			;0e5f	c0 	. 
	call sub_04c0h		;0e60	cd c0 04 	. . . 
	ret			;0e63	c9 	. 
l0e64h:
	ld a,(0c061h)		;0e64	3a 61 c0 	: a . 
	and a			;0e67	a7 	. 
	ret nz			;0e68	c0 	. 
	ld a,00ah		;0e69	3e 0a 	> . 
	ld (0c061h),a		;0e6b	32 61 c0 	2 a . 
	ld a,035h		;0e6e	3e 35 	> 5 
	ld (0c0feh),a		;0e70	32 fe c0 	2 . . 
	jp sub_0afah		;0e73	c3 fa 0a 	. . . 
sub_0e76h:
	ld a,(0c05bh)		;0e76	3a 5b c0 	: [ . 
	and a			;0e79	a7 	. 
	jp nz,l0eaah		;0e7a	c2 aa 0e 	. . . 
	ld a,(0c05ch)		;0e7d	3a 5c c0 	: \ . 
	and a			;0e80	a7 	. 
	jp nz,l0eaah		;0e81	c2 aa 0e 	. . . 
	ld a,(0c05dh)		;0e84	3a 5d c0 	: ] . 
	and a			;0e87	a7 	. 
	ret z			;0e88	c8 	. 
	ld a,(0c0dah)		;0e89	3a da c0 	: . . 
	bit 4,a		;0e8c	cb 67 	. g 
	jp z,l0ea1h		;0e8e	ca a1 0e 	. . . 
	ld a,(0c058h)		;0e91	3a 58 c0 	: X . 
	and a			;0e94	a7 	. 
	jp nz,l0ea1h		;0e95	c2 a1 0e 	. . . 
	ld a,(0c009h)		;0e98	3a 09 c0 	: . . 
	and a			;0e9b	a7 	. 
	ret nz			;0e9c	c0 	. 
	call sub_0493h		;0e9d	cd 93 04 	. . . 
	ret			;0ea0	c9 	. 
l0ea1h:
	ld a,(0c00bh)		;0ea1	3a 0b c0 	: . . 
	and a			;0ea4	a7 	. 
	ret nz			;0ea5	c0 	. 
	call sub_04eah		;0ea6	cd ea 04 	. . . 
	ret			;0ea9	c9 	. 
l0eaah:
	ld a,(0c062h)		;0eaa	3a 62 c0 	: b . 
	and a			;0ead	a7 	. 
	ret nz			;0eae	c0 	. 
	ld a,00ah		;0eaf	3e 0a 	> . 
	ld (0c062h),a		;0eb1	32 62 c0 	2 b . 
	ld a,034h		;0eb4	3e 34 	> 4 
	ld (0c0feh),a		;0eb6	32 fe c0 	2 . . 
	jp sub_0afah		;0eb9	c3 fa 0a 	. . . 
	xor a			;0ebc	af 	. 
	ld (0c0fdh),a		;0ebd	32 fd c0 	2 . . 
	ld hl,(0c0ffh)		;0ec0	2a ff c0 	* . . 
	jp (hl)			;0ec3	e9 	. 
l0ec4h:
	xor a			;0ec4	af 	. 
	ld (0c0fdh),a		;0ec5	32 fd c0 	2 . . 
	ret			;0ec8	c9 	. 
sub_0ec9h:
	ld a,(0c064h)		;0ec9	3a 64 c0 	: d . 
	and a			;0ecc	a7 	. 
	jp z,l0ed5h		;0ecd	ca d5 0e 	. . . 
	dec a			;0ed0	3d 	= 
	ld (0c064h),a		;0ed1	32 64 c0 	2 d . 
	ret			;0ed4	c9 	. 
l0ed5h:
	ld a,064h		;0ed5	3e 64 	> d 
	ld (0c064h),a		;0ed7	32 64 c0 	2 d . 
	call sub_2bach		;0eda	cd ac 2b 	. . + 
	ret			;0edd	c9 	. 
sub_0edeh:
	ld hl,0000ah		;0ede	21 0a 00 	! . . 
	ld (0c033h),hl		;0ee1	22 33 c0 	" 3 . 
	ld a,0ffh		;0ee4	3e ff 	> . 
	ld (0c035h),a		;0ee6	32 35 c0 	2 5 . 
l0ee9h:
	ld a,(0c035h)		;0ee9	3a 35 c0 	: 5 . 
	and a			;0eec	a7 	. 
	jp nz,l0ee9h		;0eed	c2 e9 0e 	. . . 
	ret			;0ef0	c9 	. 
l0ef1h:
	ld a,001h		;0ef1	3e 01 	> . 
	call sub_3055h		;0ef3	cd 55 30 	. U 0 
	jp sub_0afah		;0ef6	c3 fa 0a 	. . . 
l0ef9h:
	ld a,002h		;0ef9	3e 02 	> . 
	call sub_3055h		;0efb	cd 55 30 	. U 0 
	ld a,(0c035h)		;0efe	3a 35 c0 	: 5 . 
	and a			;0f01	a7 	. 
	ret nz			;0f02	c0 	. 
	ld hl,l0258h		;0f03	21 58 02 	! X . 
	ld (0c033h),hl		;0f06	22 33 c0 	" 3 . 
	ld a,0ffh		;0f09	3e ff 	> . 
	ld (0c035h),a		;0f0b	32 35 c0 	2 5 . 
	jp sub_0afah		;0f0e	c3 fa 0a 	. . . 
l0f11h:
	ld a,004h		;0f11	3e 04 	> . 
	call sub_3055h		;0f13	cd 55 30 	. U 0 
	ld a,(0c035h)		;0f16	3a 35 c0 	: 5 . 
	and a			;0f19	a7 	. 
	ret nz			;0f1a	c0 	. 
	ld hl,l0258h		;0f1b	21 58 02 	! X . 
	ld (0c033h),hl		;0f1e	22 33 c0 	" 3 . 
	ld a,0ffh		;0f21	3e ff 	> . 
	ld (0c035h),a		;0f23	32 35 c0 	2 5 . 
	jp sub_0afah		;0f26	c3 fa 0a 	. . . 
l0f29h:
	ld a,008h		;0f29	3e 08 	> . 
	call sub_3055h		;0f2b	cd 55 30 	. U 0 
	jp sub_0afah		;0f2e	c3 fa 0a 	. . . 
l0f31h:
	ld a,004h		;0f31	3e 04 	> . 
	call sub_3066h		;0f33	cd 66 30 	. f 0 
	jp sub_0afah		;0f36	c3 fa 0a 	. . . 
l0f39h:
	ld a,010h		;0f39	3e 10 	> . 
	call sub_3055h		;0f3b	cd 55 30 	. U 0 
	ld a,(0c05bh)		;0f3e	3a 5b c0 	: [ . 
	and a			;0f41	a7 	. 
	jp nz,l0f48h		;0f42	c2 48 0f 	. H . 
	call sub_0577h		;0f45	cd 77 05 	. w . 
l0f48h:
	jp sub_0afah		;0f48	c3 fa 0a 	. . . 
l0f4bh:
	ld a,020h		;0f4b	3e 20 	>   
	call sub_3055h		;0f4d	cd 55 30 	. U 0 
	ld a,(0c05bh)		;0f50	3a 5b c0 	: [ . 
	and a			;0f53	a7 	. 
	jp nz,l0f5ah		;0f54	c2 5a 0f 	. Z . 
	call sub_0577h		;0f57	cd 77 05 	. w . 
l0f5ah:
	jp sub_0afah		;0f5a	c3 fa 0a 	. . . 
l0f5dh:
	ld a,040h		;0f5d	3e 40 	> @ 
	call sub_3055h		;0f5f	cd 55 30 	. U 0 
	ld a,(0c05bh)		;0f62	3a 5b c0 	: [ . 
	and a			;0f65	a7 	. 
	jp nz,l0f6ch		;0f66	c2 6c 0f 	. l . 
	call sub_0577h		;0f69	cd 77 05 	. w . 
l0f6ch:
	jp sub_0afah		;0f6c	c3 fa 0a 	. . . 
l0f6fh:
	ld a,080h		;0f6f	3e 80 	> . 
	call sub_3055h		;0f71	cd 55 30 	. U 0 
	ld a,(0c05bh)		;0f74	3a 5b c0 	: [ . 
	and a			;0f77	a7 	. 
	jp nz,l0f7eh		;0f78	c2 7e 0f 	. ~ . 
	call sub_0577h		;0f7b	cd 77 05 	. w . 
l0f7eh:
	jp sub_0afah		;0f7e	c3 fa 0a 	. . . 
l0f81h:
	ld a,001h		;0f81	3e 01 	> . 
	call sub_3088h		;0f83	cd 88 30 	. . 0 
	ld a,(0c035h)		;0f86	3a 35 c0 	: 5 . 
	and a			;0f89	a7 	. 
	ret nz			;0f8a	c0 	. 
	ld hl,l00c8h		;0f8b	21 c8 00 	! . . 
	ld (0c033h),hl		;0f8e	22 33 c0 	" 3 . 
	ld a,0ffh		;0f91	3e ff 	> . 
	ld (0c035h),a		;0f93	32 35 c0 	2 5 . 
	ld a,(0c069h)		;0f96	3a 69 c0 	: i . 
	and a			;0f99	a7 	. 
	call nz,sub_03b2h		;0f9a	c4 b2 03 	. . . 
	jp sub_0afah		;0f9d	c3 fa 0a 	. . . 
l0fa0h:
	ld a,002h		;0fa0	3e 02 	> . 
	call sub_3088h		;0fa2	cd 88 30 	. . 0 
	jp sub_0afah		;0fa5	c3 fa 0a 	. . . 
l0fa8h:
	ld a,004h		;0fa8	3e 04 	> . 
	call sub_3088h		;0faa	cd 88 30 	. . 0 
	jp sub_0afah		;0fad	c3 fa 0a 	. . . 
l0fb0h:
	ld a,020h		;0fb0	3e 20 	>   
	call sub_3088h		;0fb2	cd 88 30 	. . 0 
	jp sub_0afah		;0fb5	c3 fa 0a 	. . . 
l0fb8h:
	ld a,040h		;0fb8	3e 40 	> @ 
	call sub_3088h		;0fba	cd 88 30 	. . 0 
	jp sub_0afah		;0fbd	c3 fa 0a 	. . . 
l0fc0h:
	ld a,080h		;0fc0	3e 80 	> . 
	call sub_3088h		;0fc2	cd 88 30 	. . 0 
	jp sub_0afah		;0fc5	c3 fa 0a 	. . . 
l0fc8h:
	ld a,002h		;0fc8	3e 02 	> . 
	call sub_3066h		;0fca	cd 66 30 	. f 0 
	jp sub_0afah		;0fcd	c3 fa 0a 	. . . 
l0fd0h:
	ld a,008h		;0fd0	3e 08 	> . 
	call sub_3066h		;0fd2	cd 66 30 	. f 0 
	jp sub_0afah		;0fd5	c3 fa 0a 	. . . 
l0fd8h:
	ld a,010h		;0fd8	3e 10 	> . 
	call sub_3066h		;0fda	cd 66 30 	. f 0 
	jp sub_0afah		;0fdd	c3 fa 0a 	. . . 
l0fe0h:
	ld a,020h		;0fe0	3e 20 	>   
	call sub_3066h		;0fe2	cd 66 30 	. f 0 
	jp sub_0afah		;0fe5	c3 fa 0a 	. . . 
l0fe8h:
	ld a,040h		;0fe8	3e 40 	> @ 
	call sub_3066h		;0fea	cd 66 30 	. f 0 
	jp sub_0afah		;0fed	c3 fa 0a 	. . . 
l0ff0h:
	ld a,080h		;0ff0	3e 80 	> . 
	call sub_3066h		;0ff2	cd 66 30 	. f 0 
	jp sub_0afah		;0ff5	c3 fa 0a 	. . . 
l0ff8h:
	ld a,040h		;0ff8	3e 40 	> @ 
	call sub_3077h		;0ffa	cd 77 30 	. w 0 
	jp sub_0afah		;0ffd	c3 fa 0a 	. . . 
l1000h:
	ld a,008h		;1000	3e 08 	> . 
	call sub_3077h		;1002	cd 77 30 	. w 0 
	jp sub_0afah		;1005	c3 fa 0a 	. . . 
l1008h:
	ld a,008h		;1008	3e 08 	> . 
	call sub_3099h		;100a	cd 99 30 	. . 0 
	jp sub_0afah		;100d	c3 fa 0a 	. . . 
l1010h:
	ld a,010h		;1010	3e 10 	> . 
	call sub_3099h		;1012	cd 99 30 	. . 0 
	jp sub_0afah		;1015	c3 fa 0a 	. . . 
l1018h:
	ld a,002h		;1018	3e 02 	> . 
	call sub_3099h		;101a	cd 99 30 	. . 0 
	jp sub_0afah		;101d	c3 fa 0a 	. . . 
l1020h:
	ld a,010h		;1020	3e 10 	> . 
l1022h:
	call sub_3077h		;1022	cd 77 30 	. w 0 
	ld a,(0c05bh)		;1025	3a 5b c0 	: [ . 
	and a			;1028	a7 	. 
	jp nz,l102fh		;1029	c2 2f 10 	. / . 
	call sub_0577h		;102c	cd 77 05 	. w . 
l102fh:
	jp sub_0afah		;102f	c3 fa 0a 	. . . 
l1032h:
	ld a,001h		;1032	3e 01 	> . 
	call sub_3099h		;1034	cd 99 30 	. . 0 
	jp sub_0afah		;1037	c3 fa 0a 	. . . 
l103ah:
	ld a,002h		;103a	3e 02 	> . 
	call sub_3077h		;103c	cd 77 30 	. w 0 
	ld a,(0c05bh)		;103f	3a 5b c0 	: [ . 
	and a			;1042	a7 	. 
	jp nz,l1059h		;1043	c2 59 10 	. Y . 
	ld a,(0c00eh)		;1046	3a 0e c0 	: . . 
	and a			;1049	a7 	. 
	ret nz			;104a	c0 	. 
	ld a,(0c03dh)		;104b	3a 3d c0 	: = . 
	and a			;104e	a7 	. 
	ret z			;104f	c8 	. 
	call sub_0355h		;1050	cd 55 03 	. U . 
	call sub_32e4h		;1053	cd e4 32 	. . 2 
	call sub_0577h		;1056	cd 77 05 	. w . 
l1059h:
	jp sub_0afah		;1059	c3 fa 0a 	. . . 
l105ch:
	ld a,004h		;105c	3e 04 	> . 
	call sub_3077h		;105e	cd 77 30 	. w 0 
	ld a,(0c05bh)		;1061	3a 5b c0 	: [ . 
	and a			;1064	a7 	. 
	jp nz,l107bh		;1065	c2 7b 10 	. { . 
	ld a,(0c00fh)		;1068	3a 0f c0 	: . . 
	and a			;106b	a7 	. 
	ret nz			;106c	c0 	. 
	ld a,(0c03dh)		;106d	3a 3d c0 	: = . 
	and a			;1070	a7 	. 
	ret z			;1071	c8 	. 
	call sub_0374h		;1072	cd 74 03 	. t . 
	call sub_32e4h		;1075	cd e4 32 	. . 2 
	call sub_055fh		;1078	cd 5f 05 	. _ . 
l107bh:
	jp sub_0afah		;107b	c3 fa 0a 	. . . 
l107eh:
	ld a,080h		;107e	3e 80 	> . 
	call sub_3077h		;1080	cd 77 30 	. w 0 
	ld a,(0c05bh)		;1083	3a 5b c0 	: [ . 
	and a			;1086	a7 	. 
	jp nz,l108dh		;1087	c2 8d 10 	. . . 
	call sub_055fh		;108a	cd 5f 05 	. _ . 
l108dh:
	jp sub_0afah		;108d	c3 fa 0a 	. . . 
l1090h:
	ld a,004h		;1090	3e 04 	> . 
	call sub_3099h		;1092	cd 99 30 	. . 0 
	jp sub_0afah		;1095	c3 fa 0a 	. . . 
l1098h:
	ld a,(0c05bh)		;1098	3a 5b c0 	: [ . 
	and a			;109b	a7 	. 
	ret z			;109c	c8 	. 
	ld a,008h		;109d	3e 08 	> . 
	call sub_3088h		;109f	cd 88 30 	. . 0 
	jp sub_0afah		;10a2	c3 fa 0a 	. . . 
l10a5h:
	ld a,(0c05bh)		;10a5	3a 5b c0 	: [ . 
	and a			;10a8	a7 	. 
	ret z			;10a9	c8 	. 
	ld a,010h		;10aa	3e 10 	> . 
	call sub_3088h		;10ac	cd 88 30 	. . 0 
	jp sub_0afah		;10af	c3 fa 0a 	. . . 
l10b2h:
	ld a,(0c05bh)		;10b2	3a 5b c0 	: [ . 
	and a			;10b5	a7 	. 
	jp nz,l10d2h		;10b6	c2 d2 10 	. . . 
	ld a,(0c03bh)		;10b9	3a 3b c0 	: ; . 
	and a			;10bc	a7 	. 
	ret z			;10bd	c8 	. 
	ld hl,(0c02ah)		;10be	2a 2a c0 	* * . 
	ld de,l0000h		;10c1	11 00 00 	. . . 
	xor a			;10c4	af 	. 
	sbc hl,de		;10c5	ed 52 	. R 
	ret nz			;10c7	c0 	. 
	call sub_0afah		;10c8	cd fa 0a 	. . . 
	ld hl,001f4h		;10cb	21 f4 01 	! . . 
	ld (0c02ah),hl		;10ce	22 2a c0 	" * . 
	ret			;10d1	c9 	. 
l10d2h:
	ld a,020h		;10d2	3e 20 	>   
	call sub_3099h		;10d4	cd 99 30 	. . 0 
	jp sub_0afah		;10d7	c3 fa 0a 	. . . 
l10dah:
	ld a,(0c05bh)		;10da	3a 5b c0 	: [ . 
	and a			;10dd	a7 	. 
	jp nz,l10e2h		;10de	c2 e2 10 	. . . 
	ret			;10e1	c9 	. 
l10e2h:
	ld a,040h		;10e2	3e 40 	> @ 
	call sub_3099h		;10e4	cd 99 30 	. . 0 
	jp sub_0afah		;10e7	c3 fa 0a 	. . . 
l10eah:
	ld a,080h		;10ea	3e 80 	> . 
	call sub_3099h		;10ec	cd 99 30 	. . 0 
	ld a,0ffh		;10ef	3e ff 	> . 
	ld (0c068h),a		;10f1	32 68 c0 	2 h . 
	jp sub_0afah		;10f4	c3 fa 0a 	. . . 
l10f7h:
	ld a,001h		;10f7	3e 01 	> . 
	call sub_3066h		;10f9	cd 66 30 	. f 0 
	jp sub_0afah		;10fc	c3 fa 0a 	. . . 
sub_10ffh:
	ld hl,(0c06eh)		;10ff	2a 6e c0 	* n . 
	ld a,(hl)			;1102	7e 	~ 
	and a			;1103	a7 	. 
	ret z			;1104	c8 	. 
	ld (hl),000h		;1105	36 00 	6 . 
	inc hl			;1107	23 	# 
	ld (0c06eh),hl		;1108	22 6e c0 	" n . 
	ld hl,l2000h		;110b	21 00 20 	! .   
	ld d,000h		;110e	16 00 	. . 
	ld e,a			;1110	5f 	_ 
	sla e		;1111	cb 23 	. # 
	jp nc,l1118h		;1113	d2 18 11 	. . . 
	ld d,001h		;1116	16 01 	. . 
l1118h:
	add hl,de			;1118	19 	. 
	ld e,(hl)			;1119	5e 	^ 
	inc hl			;111a	23 	# 
	ld d,(hl)			;111b	56 	V 
	ex de,hl			;111c	eb 	. 
	jp (hl)			;111d	e9 	. 
	rst 38h			;111e	ff 	. 
	rst 38h			;111f	ff 	. 
	rst 38h			;1120	ff 	. 
	rst 38h			;1121	ff 	. 
	rst 38h			;1122	ff 	. 
	rst 38h			;1123	ff 	. 
	rst 38h			;1124	ff 	. 
	rst 38h			;1125	ff 	. 
	rst 38h			;1126	ff 	. 
	rst 38h			;1127	ff 	. 
	rst 38h			;1128	ff 	. 
	rst 38h			;1129	ff 	. 
	rst 38h			;112a	ff 	. 
	rst 38h			;112b	ff 	. 
	rst 38h			;112c	ff 	. 
	rst 38h			;112d	ff 	. 
	rst 38h			;112e	ff 	. 
	rst 38h			;112f	ff 	. 
	rst 38h			;1130	ff 	. 
	rst 38h			;1131	ff 	. 
	rst 38h			;1132	ff 	. 
	rst 38h			;1133	ff 	. 
	rst 38h			;1134	ff 	. 
	rst 38h			;1135	ff 	. 
	rst 38h			;1136	ff 	. 
	rst 38h			;1137	ff 	. 
	rst 38h			;1138	ff 	. 
	rst 38h			;1139	ff 	. 
	rst 38h			;113a	ff 	. 
	rst 38h			;113b	ff 	. 
	rst 38h			;113c	ff 	. 
	rst 38h			;113d	ff 	. 
	rst 38h			;113e	ff 	. 
	rst 38h			;113f	ff 	. 
l1140h:
	rst 38h			;1140	ff 	. 
	rst 38h			;1141	ff 	. 
	rst 38h			;1142	ff 	. 
	rst 38h			;1143	ff 	. 
	rst 38h			;1144	ff 	. 
	rst 38h			;1145	ff 	. 
	rst 38h			;1146	ff 	. 
	rst 38h			;1147	ff 	. 
	rst 38h			;1148	ff 	. 
	rst 38h			;1149	ff 	. 
	rst 38h			;114a	ff 	. 
	rst 38h			;114b	ff 	. 
	rst 38h			;114c	ff 	. 
	rst 38h			;114d	ff 	. 
	rst 38h			;114e	ff 	. 
	rst 38h			;114f	ff 	. 
	rst 38h			;1150	ff 	. 
	rst 38h			;1151	ff 	. 
	rst 38h			;1152	ff 	. 
	rst 38h			;1153	ff 	. 
	rst 38h			;1154	ff 	. 
	rst 38h			;1155	ff 	. 
	rst 38h			;1156	ff 	. 
	rst 38h			;1157	ff 	. 
	rst 38h			;1158	ff 	. 
	rst 38h			;1159	ff 	. 
	rst 38h			;115a	ff 	. 
	rst 38h			;115b	ff 	. 
	rst 38h			;115c	ff 	. 
	rst 38h			;115d	ff 	. 
	rst 38h			;115e	ff 	. 
	rst 38h			;115f	ff 	. 
	rst 38h			;1160	ff 	. 
	rst 38h			;1161	ff 	. 
	rst 38h			;1162	ff 	. 
	rst 38h			;1163	ff 	. 
	rst 38h			;1164	ff 	. 
	rst 38h			;1165	ff 	. 
	rst 38h			;1166	ff 	. 
	rst 38h			;1167	ff 	. 
	rst 38h			;1168	ff 	. 
	rst 38h			;1169	ff 	. 
	rst 38h			;116a	ff 	. 
	rst 38h			;116b	ff 	. 
	rst 38h			;116c	ff 	. 
	rst 38h			;116d	ff 	. 
	rst 38h			;116e	ff 	. 
	rst 38h			;116f	ff 	. 
	rst 38h			;1170	ff 	. 
	rst 38h			;1171	ff 	. 
	rst 38h			;1172	ff 	. 
	rst 38h			;1173	ff 	. 
	rst 38h			;1174	ff 	. 
	rst 38h			;1175	ff 	. 
	rst 38h			;1176	ff 	. 
	rst 38h			;1177	ff 	. 
	rst 38h			;1178	ff 	. 
	rst 38h			;1179	ff 	. 
	rst 38h			;117a	ff 	. 
	rst 38h			;117b	ff 	. 
	rst 38h			;117c	ff 	. 
	rst 38h			;117d	ff 	. 
	rst 38h			;117e	ff 	. 
	rst 38h			;117f	ff 	. 
	rst 38h			;1180	ff 	. 
	rst 38h			;1181	ff 	. 
	rst 38h			;1182	ff 	. 
	rst 38h			;1183	ff 	. 
	rst 38h			;1184	ff 	. 
	rst 38h			;1185	ff 	. 
	rst 38h			;1186	ff 	. 
	rst 38h			;1187	ff 	. 
	rst 38h			;1188	ff 	. 
	rst 38h			;1189	ff 	. 
	rst 38h			;118a	ff 	. 
	rst 38h			;118b	ff 	. 
	rst 38h			;118c	ff 	. 
	rst 38h			;118d	ff 	. 
	rst 38h			;118e	ff 	. 
	rst 38h			;118f	ff 	. 
	rst 38h			;1190	ff 	. 
	rst 38h			;1191	ff 	. 
	rst 38h			;1192	ff 	. 
	rst 38h			;1193	ff 	. 
	rst 38h			;1194	ff 	. 
	rst 38h			;1195	ff 	. 
	rst 38h			;1196	ff 	. 
	rst 38h			;1197	ff 	. 
	rst 38h			;1198	ff 	. 
	rst 38h			;1199	ff 	. 
	rst 38h			;119a	ff 	. 
	rst 38h			;119b	ff 	. 
	rst 38h			;119c	ff 	. 
	rst 38h			;119d	ff 	. 
	rst 38h			;119e	ff 	. 
	rst 38h			;119f	ff 	. 
	rst 38h			;11a0	ff 	. 
	rst 38h			;11a1	ff 	. 
	rst 38h			;11a2	ff 	. 
	rst 38h			;11a3	ff 	. 
	rst 38h			;11a4	ff 	. 
	rst 38h			;11a5	ff 	. 
	rst 38h			;11a6	ff 	. 
	rst 38h			;11a7	ff 	. 
	rst 38h			;11a8	ff 	. 
	rst 38h			;11a9	ff 	. 
	rst 38h			;11aa	ff 	. 
	rst 38h			;11ab	ff 	. 
	rst 38h			;11ac	ff 	. 
	rst 38h			;11ad	ff 	. 
	rst 38h			;11ae	ff 	. 
	rst 38h			;11af	ff 	. 
	rst 38h			;11b0	ff 	. 
	rst 38h			;11b1	ff 	. 
	rst 38h			;11b2	ff 	. 
	rst 38h			;11b3	ff 	. 
	rst 38h			;11b4	ff 	. 
	rst 38h			;11b5	ff 	. 
	rst 38h			;11b6	ff 	. 
	rst 38h			;11b7	ff 	. 
	rst 38h			;11b8	ff 	. 
	rst 38h			;11b9	ff 	. 
	rst 38h			;11ba	ff 	. 
	rst 38h			;11bb	ff 	. 
	rst 38h			;11bc	ff 	. 
	rst 38h			;11bd	ff 	. 
	rst 38h			;11be	ff 	. 
	rst 38h			;11bf	ff 	. 
	rst 38h			;11c0	ff 	. 
	rst 38h			;11c1	ff 	. 
	rst 38h			;11c2	ff 	. 
	rst 38h			;11c3	ff 	. 
	rst 38h			;11c4	ff 	. 
	rst 38h			;11c5	ff 	. 
	rst 38h			;11c6	ff 	. 
	rst 38h			;11c7	ff 	. 
	rst 38h			;11c8	ff 	. 
	rst 38h			;11c9	ff 	. 
	rst 38h			;11ca	ff 	. 
	rst 38h			;11cb	ff 	. 
	rst 38h			;11cc	ff 	. 
	rst 38h			;11cd	ff 	. 
	rst 38h			;11ce	ff 	. 
	rst 38h			;11cf	ff 	. 
	rst 38h			;11d0	ff 	. 
	rst 38h			;11d1	ff 	. 
	rst 38h			;11d2	ff 	. 
	rst 38h			;11d3	ff 	. 
	rst 38h			;11d4	ff 	. 
	rst 38h			;11d5	ff 	. 
	rst 38h			;11d6	ff 	. 
	rst 38h			;11d7	ff 	. 
	rst 38h			;11d8	ff 	. 
	rst 38h			;11d9	ff 	. 
	rst 38h			;11da	ff 	. 
	rst 38h			;11db	ff 	. 
	rst 38h			;11dc	ff 	. 
	rst 38h			;11dd	ff 	. 
	rst 38h			;11de	ff 	. 
	rst 38h			;11df	ff 	. 
	rst 38h			;11e0	ff 	. 
	rst 38h			;11e1	ff 	. 
	rst 38h			;11e2	ff 	. 
	rst 38h			;11e3	ff 	. 
	rst 38h			;11e4	ff 	. 
	rst 38h			;11e5	ff 	. 
	rst 38h			;11e6	ff 	. 
	rst 38h			;11e7	ff 	. 
	rst 38h			;11e8	ff 	. 
	rst 38h			;11e9	ff 	. 
	rst 38h			;11ea	ff 	. 
	rst 38h			;11eb	ff 	. 
	rst 38h			;11ec	ff 	. 
	rst 38h			;11ed	ff 	. 
	rst 38h			;11ee	ff 	. 
	rst 38h			;11ef	ff 	. 
	rst 38h			;11f0	ff 	. 
	rst 38h			;11f1	ff 	. 
	rst 38h			;11f2	ff 	. 
	rst 38h			;11f3	ff 	. 
	rst 38h			;11f4	ff 	. 
	rst 38h			;11f5	ff 	. 
	rst 38h			;11f6	ff 	. 
	rst 38h			;11f7	ff 	. 
	rst 38h			;11f8	ff 	. 
	rst 38h			;11f9	ff 	. 
	rst 38h			;11fa	ff 	. 
	rst 38h			;11fb	ff 	. 
	rst 38h			;11fc	ff 	. 
	rst 38h			;11fd	ff 	. 
	rst 38h			;11fe	ff 	. 
	rst 38h			;11ff	ff 	. 
	rst 38h			;1200	ff 	. 
	rst 38h			;1201	ff 	. 
	rst 38h			;1202	ff 	. 
	rst 38h			;1203	ff 	. 
	rst 38h			;1204	ff 	. 
l1205h:
	rst 38h			;1205	ff 	. 
	rst 38h			;1206	ff 	. 
	rst 38h			;1207	ff 	. 
	rst 38h			;1208	ff 	. 
	rst 38h			;1209	ff 	. 
	rst 38h			;120a	ff 	. 
	rst 38h			;120b	ff 	. 
	rst 38h			;120c	ff 	. 
	rst 38h			;120d	ff 	. 
	rst 38h			;120e	ff 	. 
	rst 38h			;120f	ff 	. 
	rst 38h			;1210	ff 	. 
	rst 38h			;1211	ff 	. 
	rst 38h			;1212	ff 	. 
	rst 38h			;1213	ff 	. 
	rst 38h			;1214	ff 	. 
	rst 38h			;1215	ff 	. 
	rst 38h			;1216	ff 	. 
	rst 38h			;1217	ff 	. 
	rst 38h			;1218	ff 	. 
	rst 38h			;1219	ff 	. 
	rst 38h			;121a	ff 	. 
	rst 38h			;121b	ff 	. 
	rst 38h			;121c	ff 	. 
	rst 38h			;121d	ff 	. 
	rst 38h			;121e	ff 	. 
	rst 38h			;121f	ff 	. 
	rst 38h			;1220	ff 	. 
	rst 38h			;1221	ff 	. 
	rst 38h			;1222	ff 	. 
	rst 38h			;1223	ff 	. 
	rst 38h			;1224	ff 	. 
	rst 38h			;1225	ff 	. 
	rst 38h			;1226	ff 	. 
	rst 38h			;1227	ff 	. 
	rst 38h			;1228	ff 	. 
	rst 38h			;1229	ff 	. 
	rst 38h			;122a	ff 	. 
	rst 38h			;122b	ff 	. 
	rst 38h			;122c	ff 	. 
	rst 38h			;122d	ff 	. 
	rst 38h			;122e	ff 	. 
	rst 38h			;122f	ff 	. 
	rst 38h			;1230	ff 	. 
	rst 38h			;1231	ff 	. 
	rst 38h			;1232	ff 	. 
	rst 38h			;1233	ff 	. 
	rst 38h			;1234	ff 	. 
	rst 38h			;1235	ff 	. 
	rst 38h			;1236	ff 	. 
	rst 38h			;1237	ff 	. 
	rst 38h			;1238	ff 	. 
	rst 38h			;1239	ff 	. 
	rst 38h			;123a	ff 	. 
	rst 38h			;123b	ff 	. 
	rst 38h			;123c	ff 	. 
	rst 38h			;123d	ff 	. 
	rst 38h			;123e	ff 	. 
	rst 38h			;123f	ff 	. 
	rst 38h			;1240	ff 	. 
	rst 38h			;1241	ff 	. 
	rst 38h			;1242	ff 	. 
	rst 38h			;1243	ff 	. 
	rst 38h			;1244	ff 	. 
	rst 38h			;1245	ff 	. 
	rst 38h			;1246	ff 	. 
	rst 38h			;1247	ff 	. 
	rst 38h			;1248	ff 	. 
	rst 38h			;1249	ff 	. 
	rst 38h			;124a	ff 	. 
	rst 38h			;124b	ff 	. 
	rst 38h			;124c	ff 	. 
	rst 38h			;124d	ff 	. 
	rst 38h			;124e	ff 	. 
	rst 38h			;124f	ff 	. 
	rst 38h			;1250	ff 	. 
	rst 38h			;1251	ff 	. 
	rst 38h			;1252	ff 	. 
	rst 38h			;1253	ff 	. 
	rst 38h			;1254	ff 	. 
	rst 38h			;1255	ff 	. 
	rst 38h			;1256	ff 	. 
	rst 38h			;1257	ff 	. 
	rst 38h			;1258	ff 	. 
	rst 38h			;1259	ff 	. 
	rst 38h			;125a	ff 	. 
	rst 38h			;125b	ff 	. 
	rst 38h			;125c	ff 	. 
	rst 38h			;125d	ff 	. 
	rst 38h			;125e	ff 	. 
	rst 38h			;125f	ff 	. 
	rst 38h			;1260	ff 	. 
	rst 38h			;1261	ff 	. 
	rst 38h			;1262	ff 	. 
	rst 38h			;1263	ff 	. 
	rst 38h			;1264	ff 	. 
	rst 38h			;1265	ff 	. 
	rst 38h			;1266	ff 	. 
	rst 38h			;1267	ff 	. 
	rst 38h			;1268	ff 	. 
	rst 38h			;1269	ff 	. 
	rst 38h			;126a	ff 	. 
	rst 38h			;126b	ff 	. 
	rst 38h			;126c	ff 	. 
	rst 38h			;126d	ff 	. 
	rst 38h			;126e	ff 	. 
	rst 38h			;126f	ff 	. 
	rst 38h			;1270	ff 	. 
	rst 38h			;1271	ff 	. 
	rst 38h			;1272	ff 	. 
	rst 38h			;1273	ff 	. 
	rst 38h			;1274	ff 	. 
	rst 38h			;1275	ff 	. 
	rst 38h			;1276	ff 	. 
	rst 38h			;1277	ff 	. 
	rst 38h			;1278	ff 	. 
	rst 38h			;1279	ff 	. 
	rst 38h			;127a	ff 	. 
	rst 38h			;127b	ff 	. 
	rst 38h			;127c	ff 	. 
	rst 38h			;127d	ff 	. 
	rst 38h			;127e	ff 	. 
	rst 38h			;127f	ff 	. 
	rst 38h			;1280	ff 	. 
	rst 38h			;1281	ff 	. 
	rst 38h			;1282	ff 	. 
	rst 38h			;1283	ff 	. 
	rst 38h			;1284	ff 	. 
	rst 38h			;1285	ff 	. 
	rst 38h			;1286	ff 	. 
	rst 38h			;1287	ff 	. 
	rst 38h			;1288	ff 	. 
	rst 38h			;1289	ff 	. 
	rst 38h			;128a	ff 	. 
	rst 38h			;128b	ff 	. 
	rst 38h			;128c	ff 	. 
	rst 38h			;128d	ff 	. 
	rst 38h			;128e	ff 	. 
	rst 38h			;128f	ff 	. 
	rst 38h			;1290	ff 	. 
	rst 38h			;1291	ff 	. 
	rst 38h			;1292	ff 	. 
	rst 38h			;1293	ff 	. 
	rst 38h			;1294	ff 	. 
	rst 38h			;1295	ff 	. 
	rst 38h			;1296	ff 	. 
	rst 38h			;1297	ff 	. 
	rst 38h			;1298	ff 	. 
	rst 38h			;1299	ff 	. 
	rst 38h			;129a	ff 	. 
	rst 38h			;129b	ff 	. 
	rst 38h			;129c	ff 	. 
	rst 38h			;129d	ff 	. 
	rst 38h			;129e	ff 	. 
	rst 38h			;129f	ff 	. 
	rst 38h			;12a0	ff 	. 
	rst 38h			;12a1	ff 	. 
	rst 38h			;12a2	ff 	. 
	rst 38h			;12a3	ff 	. 
	rst 38h			;12a4	ff 	. 
	rst 38h			;12a5	ff 	. 
	rst 38h			;12a6	ff 	. 
	rst 38h			;12a7	ff 	. 
	rst 38h			;12a8	ff 	. 
	rst 38h			;12a9	ff 	. 
	rst 38h			;12aa	ff 	. 
	rst 38h			;12ab	ff 	. 
	rst 38h			;12ac	ff 	. 
	rst 38h			;12ad	ff 	. 
	rst 38h			;12ae	ff 	. 
	rst 38h			;12af	ff 	. 
	rst 38h			;12b0	ff 	. 
	rst 38h			;12b1	ff 	. 
	rst 38h			;12b2	ff 	. 
	rst 38h			;12b3	ff 	. 
	rst 38h			;12b4	ff 	. 
	rst 38h			;12b5	ff 	. 
	rst 38h			;12b6	ff 	. 
	rst 38h			;12b7	ff 	. 
	rst 38h			;12b8	ff 	. 
	rst 38h			;12b9	ff 	. 
	rst 38h			;12ba	ff 	. 
	rst 38h			;12bb	ff 	. 
	rst 38h			;12bc	ff 	. 
	rst 38h			;12bd	ff 	. 
	rst 38h			;12be	ff 	. 
	rst 38h			;12bf	ff 	. 
	rst 38h			;12c0	ff 	. 
	rst 38h			;12c1	ff 	. 
	rst 38h			;12c2	ff 	. 
	rst 38h			;12c3	ff 	. 
	rst 38h			;12c4	ff 	. 
	rst 38h			;12c5	ff 	. 
	rst 38h			;12c6	ff 	. 
	rst 38h			;12c7	ff 	. 
	rst 38h			;12c8	ff 	. 
	rst 38h			;12c9	ff 	. 
	rst 38h			;12ca	ff 	. 
	rst 38h			;12cb	ff 	. 
	rst 38h			;12cc	ff 	. 
	rst 38h			;12cd	ff 	. 
	rst 38h			;12ce	ff 	. 
	rst 38h			;12cf	ff 	. 
	rst 38h			;12d0	ff 	. 
	rst 38h			;12d1	ff 	. 
	rst 38h			;12d2	ff 	. 
	rst 38h			;12d3	ff 	. 
	rst 38h			;12d4	ff 	. 
	rst 38h			;12d5	ff 	. 
	rst 38h			;12d6	ff 	. 
	rst 38h			;12d7	ff 	. 
	rst 38h			;12d8	ff 	. 
	rst 38h			;12d9	ff 	. 
	rst 38h			;12da	ff 	. 
	rst 38h			;12db	ff 	. 
	rst 38h			;12dc	ff 	. 
	rst 38h			;12dd	ff 	. 
	rst 38h			;12de	ff 	. 
	rst 38h			;12df	ff 	. 
	rst 38h			;12e0	ff 	. 
	rst 38h			;12e1	ff 	. 
	rst 38h			;12e2	ff 	. 
	rst 38h			;12e3	ff 	. 
	rst 38h			;12e4	ff 	. 
	rst 38h			;12e5	ff 	. 
	rst 38h			;12e6	ff 	. 
	rst 38h			;12e7	ff 	. 
	rst 38h			;12e8	ff 	. 
	rst 38h			;12e9	ff 	. 
	rst 38h			;12ea	ff 	. 
	rst 38h			;12eb	ff 	. 
	rst 38h			;12ec	ff 	. 
	rst 38h			;12ed	ff 	. 
	rst 38h			;12ee	ff 	. 
	rst 38h			;12ef	ff 	. 
	rst 38h			;12f0	ff 	. 
	rst 38h			;12f1	ff 	. 
	rst 38h			;12f2	ff 	. 
	rst 38h			;12f3	ff 	. 
	rst 38h			;12f4	ff 	. 
	rst 38h			;12f5	ff 	. 
	rst 38h			;12f6	ff 	. 
	rst 38h			;12f7	ff 	. 
	rst 38h			;12f8	ff 	. 
	rst 38h			;12f9	ff 	. 
	rst 38h			;12fa	ff 	. 
	rst 38h			;12fb	ff 	. 
	rst 38h			;12fc	ff 	. 
	rst 38h			;12fd	ff 	. 
	rst 38h			;12fe	ff 	. 
	rst 38h			;12ff	ff 	. 
	rst 38h			;1300	ff 	. 
	rst 38h			;1301	ff 	. 
	rst 38h			;1302	ff 	. 
	rst 38h			;1303	ff 	. 
	rst 38h			;1304	ff 	. 
	rst 38h			;1305	ff 	. 
	rst 38h			;1306	ff 	. 
	rst 38h			;1307	ff 	. 
	rst 38h			;1308	ff 	. 
	rst 38h			;1309	ff 	. 
	rst 38h			;130a	ff 	. 
	rst 38h			;130b	ff 	. 
	rst 38h			;130c	ff 	. 
	rst 38h			;130d	ff 	. 
	rst 38h			;130e	ff 	. 
	rst 38h			;130f	ff 	. 
	rst 38h			;1310	ff 	. 
	rst 38h			;1311	ff 	. 
	rst 38h			;1312	ff 	. 
	rst 38h			;1313	ff 	. 
	rst 38h			;1314	ff 	. 
	rst 38h			;1315	ff 	. 
	rst 38h			;1316	ff 	. 
	rst 38h			;1317	ff 	. 
	rst 38h			;1318	ff 	. 
	rst 38h			;1319	ff 	. 
	rst 38h			;131a	ff 	. 
	rst 38h			;131b	ff 	. 
	rst 38h			;131c	ff 	. 
	rst 38h			;131d	ff 	. 
	rst 38h			;131e	ff 	. 
	rst 38h			;131f	ff 	. 
	rst 38h			;1320	ff 	. 
	rst 38h			;1321	ff 	. 
	rst 38h			;1322	ff 	. 
	rst 38h			;1323	ff 	. 
	rst 38h			;1324	ff 	. 
	rst 38h			;1325	ff 	. 
	rst 38h			;1326	ff 	. 
	rst 38h			;1327	ff 	. 
	rst 38h			;1328	ff 	. 
	rst 38h			;1329	ff 	. 
	rst 38h			;132a	ff 	. 
	rst 38h			;132b	ff 	. 
	rst 38h			;132c	ff 	. 
	rst 38h			;132d	ff 	. 
	rst 38h			;132e	ff 	. 
	rst 38h			;132f	ff 	. 
	rst 38h			;1330	ff 	. 
	rst 38h			;1331	ff 	. 
	rst 38h			;1332	ff 	. 
	rst 38h			;1333	ff 	. 
	rst 38h			;1334	ff 	. 
	rst 38h			;1335	ff 	. 
	rst 38h			;1336	ff 	. 
	rst 38h			;1337	ff 	. 
	rst 38h			;1338	ff 	. 
	rst 38h			;1339	ff 	. 
	rst 38h			;133a	ff 	. 
	rst 38h			;133b	ff 	. 
	rst 38h			;133c	ff 	. 
	rst 38h			;133d	ff 	. 
	rst 38h			;133e	ff 	. 
	rst 38h			;133f	ff 	. 
	rst 38h			;1340	ff 	. 
	rst 38h			;1341	ff 	. 
	rst 38h			;1342	ff 	. 
	rst 38h			;1343	ff 	. 
	rst 38h			;1344	ff 	. 
	rst 38h			;1345	ff 	. 
	rst 38h			;1346	ff 	. 
	rst 38h			;1347	ff 	. 
	rst 38h			;1348	ff 	. 
	rst 38h			;1349	ff 	. 
	rst 38h			;134a	ff 	. 
	rst 38h			;134b	ff 	. 
	rst 38h			;134c	ff 	. 
	rst 38h			;134d	ff 	. 
	rst 38h			;134e	ff 	. 
	rst 38h			;134f	ff 	. 
	rst 38h			;1350	ff 	. 
	rst 38h			;1351	ff 	. 
	rst 38h			;1352	ff 	. 
	rst 38h			;1353	ff 	. 
	rst 38h			;1354	ff 	. 
	rst 38h			;1355	ff 	. 
	rst 38h			;1356	ff 	. 
	rst 38h			;1357	ff 	. 
	rst 38h			;1358	ff 	. 
	rst 38h			;1359	ff 	. 
	rst 38h			;135a	ff 	. 
	rst 38h			;135b	ff 	. 
	rst 38h			;135c	ff 	. 
	rst 38h			;135d	ff 	. 
	rst 38h			;135e	ff 	. 
	rst 38h			;135f	ff 	. 
	rst 38h			;1360	ff 	. 
	rst 38h			;1361	ff 	. 
	rst 38h			;1362	ff 	. 
	rst 38h			;1363	ff 	. 
	rst 38h			;1364	ff 	. 
	rst 38h			;1365	ff 	. 
	rst 38h			;1366	ff 	. 
	rst 38h			;1367	ff 	. 
	rst 38h			;1368	ff 	. 
	rst 38h			;1369	ff 	. 
	rst 38h			;136a	ff 	. 
	rst 38h			;136b	ff 	. 
	rst 38h			;136c	ff 	. 
	rst 38h			;136d	ff 	. 
	rst 38h			;136e	ff 	. 
	rst 38h			;136f	ff 	. 
	rst 38h			;1370	ff 	. 
	rst 38h			;1371	ff 	. 
	rst 38h			;1372	ff 	. 
	rst 38h			;1373	ff 	. 
	rst 38h			;1374	ff 	. 
	rst 38h			;1375	ff 	. 
	rst 38h			;1376	ff 	. 
	rst 38h			;1377	ff 	. 
	rst 38h			;1378	ff 	. 
	rst 38h			;1379	ff 	. 
	rst 38h			;137a	ff 	. 
	rst 38h			;137b	ff 	. 
	rst 38h			;137c	ff 	. 
	rst 38h			;137d	ff 	. 
	rst 38h			;137e	ff 	. 
	rst 38h			;137f	ff 	. 
	rst 38h			;1380	ff 	. 
	rst 38h			;1381	ff 	. 
	rst 38h			;1382	ff 	. 
	rst 38h			;1383	ff 	. 
	rst 38h			;1384	ff 	. 
	rst 38h			;1385	ff 	. 
	rst 38h			;1386	ff 	. 
	rst 38h			;1387	ff 	. 
	rst 38h			;1388	ff 	. 
	rst 38h			;1389	ff 	. 
	rst 38h			;138a	ff 	. 
	rst 38h			;138b	ff 	. 
	rst 38h			;138c	ff 	. 
	rst 38h			;138d	ff 	. 
	rst 38h			;138e	ff 	. 
	rst 38h			;138f	ff 	. 
	rst 38h			;1390	ff 	. 
	rst 38h			;1391	ff 	. 
	rst 38h			;1392	ff 	. 
	rst 38h			;1393	ff 	. 
	rst 38h			;1394	ff 	. 
	rst 38h			;1395	ff 	. 
	rst 38h			;1396	ff 	. 
	rst 38h			;1397	ff 	. 
	rst 38h			;1398	ff 	. 
	rst 38h			;1399	ff 	. 
	rst 38h			;139a	ff 	. 
	rst 38h			;139b	ff 	. 
	rst 38h			;139c	ff 	. 
	rst 38h			;139d	ff 	. 
	rst 38h			;139e	ff 	. 
	rst 38h			;139f	ff 	. 
	rst 38h			;13a0	ff 	. 
	rst 38h			;13a1	ff 	. 
	rst 38h			;13a2	ff 	. 
	rst 38h			;13a3	ff 	. 
	rst 38h			;13a4	ff 	. 
	rst 38h			;13a5	ff 	. 
	rst 38h			;13a6	ff 	. 
	rst 38h			;13a7	ff 	. 
	rst 38h			;13a8	ff 	. 
	rst 38h			;13a9	ff 	. 
	rst 38h			;13aa	ff 	. 
	rst 38h			;13ab	ff 	. 
	rst 38h			;13ac	ff 	. 
	rst 38h			;13ad	ff 	. 
	rst 38h			;13ae	ff 	. 
	rst 38h			;13af	ff 	. 
	rst 38h			;13b0	ff 	. 
	rst 38h			;13b1	ff 	. 
	rst 38h			;13b2	ff 	. 
	rst 38h			;13b3	ff 	. 
	rst 38h			;13b4	ff 	. 
	rst 38h			;13b5	ff 	. 
	rst 38h			;13b6	ff 	. 
	rst 38h			;13b7	ff 	. 
	rst 38h			;13b8	ff 	. 
	rst 38h			;13b9	ff 	. 
	rst 38h			;13ba	ff 	. 
	rst 38h			;13bb	ff 	. 
	rst 38h			;13bc	ff 	. 
	rst 38h			;13bd	ff 	. 
	rst 38h			;13be	ff 	. 
	rst 38h			;13bf	ff 	. 
	rst 38h			;13c0	ff 	. 
	rst 38h			;13c1	ff 	. 
	rst 38h			;13c2	ff 	. 
	rst 38h			;13c3	ff 	. 
	rst 38h			;13c4	ff 	. 
	rst 38h			;13c5	ff 	. 
	rst 38h			;13c6	ff 	. 
	rst 38h			;13c7	ff 	. 
	rst 38h			;13c8	ff 	. 
	rst 38h			;13c9	ff 	. 
	rst 38h			;13ca	ff 	. 
	rst 38h			;13cb	ff 	. 
	rst 38h			;13cc	ff 	. 
	rst 38h			;13cd	ff 	. 
	rst 38h			;13ce	ff 	. 
	rst 38h			;13cf	ff 	. 
	rst 38h			;13d0	ff 	. 
	rst 38h			;13d1	ff 	. 
	rst 38h			;13d2	ff 	. 
	rst 38h			;13d3	ff 	. 
	rst 38h			;13d4	ff 	. 
	rst 38h			;13d5	ff 	. 
	rst 38h			;13d6	ff 	. 
	rst 38h			;13d7	ff 	. 
	rst 38h			;13d8	ff 	. 
	rst 38h			;13d9	ff 	. 
	rst 38h			;13da	ff 	. 
	rst 38h			;13db	ff 	. 
	rst 38h			;13dc	ff 	. 
	rst 38h			;13dd	ff 	. 
	rst 38h			;13de	ff 	. 
	rst 38h			;13df	ff 	. 
	rst 38h			;13e0	ff 	. 
	rst 38h			;13e1	ff 	. 
	rst 38h			;13e2	ff 	. 
	rst 38h			;13e3	ff 	. 
	rst 38h			;13e4	ff 	. 
	rst 38h			;13e5	ff 	. 
	rst 38h			;13e6	ff 	. 
	rst 38h			;13e7	ff 	. 
	rst 38h			;13e8	ff 	. 
	rst 38h			;13e9	ff 	. 
	rst 38h			;13ea	ff 	. 
	rst 38h			;13eb	ff 	. 
	rst 38h			;13ec	ff 	. 
	rst 38h			;13ed	ff 	. 
	rst 38h			;13ee	ff 	. 
	rst 38h			;13ef	ff 	. 
	rst 38h			;13f0	ff 	. 
	rst 38h			;13f1	ff 	. 
	rst 38h			;13f2	ff 	. 
	rst 38h			;13f3	ff 	. 
	rst 38h			;13f4	ff 	. 
	rst 38h			;13f5	ff 	. 
	rst 38h			;13f6	ff 	. 
	rst 38h			;13f7	ff 	. 
	rst 38h			;13f8	ff 	. 
	rst 38h			;13f9	ff 	. 
	rst 38h			;13fa	ff 	. 
	rst 38h			;13fb	ff 	. 
	rst 38h			;13fc	ff 	. 
	rst 38h			;13fd	ff 	. 
	rst 38h			;13fe	ff 	. 
	rst 38h			;13ff	ff 	. 
	rst 38h			;1400	ff 	. 
	rst 38h			;1401	ff 	. 
	rst 38h			;1402	ff 	. 
	rst 38h			;1403	ff 	. 
	rst 38h			;1404	ff 	. 
	rst 38h			;1405	ff 	. 
	rst 38h			;1406	ff 	. 
	rst 38h			;1407	ff 	. 
	rst 38h			;1408	ff 	. 
	rst 38h			;1409	ff 	. 
	rst 38h			;140a	ff 	. 
	rst 38h			;140b	ff 	. 
	rst 38h			;140c	ff 	. 
	rst 38h			;140d	ff 	. 
	rst 38h			;140e	ff 	. 
	rst 38h			;140f	ff 	. 
	rst 38h			;1410	ff 	. 
	rst 38h			;1411	ff 	. 
	rst 38h			;1412	ff 	. 
	rst 38h			;1413	ff 	. 
	rst 38h			;1414	ff 	. 
	rst 38h			;1415	ff 	. 
	rst 38h			;1416	ff 	. 
	rst 38h			;1417	ff 	. 
	rst 38h			;1418	ff 	. 
	rst 38h			;1419	ff 	. 
	rst 38h			;141a	ff 	. 
	rst 38h			;141b	ff 	. 
	rst 38h			;141c	ff 	. 
	rst 38h			;141d	ff 	. 
	rst 38h			;141e	ff 	. 
	rst 38h			;141f	ff 	. 
	rst 38h			;1420	ff 	. 
	rst 38h			;1421	ff 	. 
	rst 38h			;1422	ff 	. 
	rst 38h			;1423	ff 	. 
	rst 38h			;1424	ff 	. 
	rst 38h			;1425	ff 	. 
	rst 38h			;1426	ff 	. 
	rst 38h			;1427	ff 	. 
	rst 38h			;1428	ff 	. 
	rst 38h			;1429	ff 	. 
	rst 38h			;142a	ff 	. 
	rst 38h			;142b	ff 	. 
	rst 38h			;142c	ff 	. 
	rst 38h			;142d	ff 	. 
	rst 38h			;142e	ff 	. 
	rst 38h			;142f	ff 	. 
	rst 38h			;1430	ff 	. 
	rst 38h			;1431	ff 	. 
	rst 38h			;1432	ff 	. 
	rst 38h			;1433	ff 	. 
	rst 38h			;1434	ff 	. 
	rst 38h			;1435	ff 	. 
	rst 38h			;1436	ff 	. 
	rst 38h			;1437	ff 	. 
	rst 38h			;1438	ff 	. 
	rst 38h			;1439	ff 	. 
	rst 38h			;143a	ff 	. 
	rst 38h			;143b	ff 	. 
	rst 38h			;143c	ff 	. 
	rst 38h			;143d	ff 	. 
	rst 38h			;143e	ff 	. 
	rst 38h			;143f	ff 	. 
	rst 38h			;1440	ff 	. 
	rst 38h			;1441	ff 	. 
	rst 38h			;1442	ff 	. 
	rst 38h			;1443	ff 	. 
	rst 38h			;1444	ff 	. 
	rst 38h			;1445	ff 	. 
	rst 38h			;1446	ff 	. 
	rst 38h			;1447	ff 	. 
	rst 38h			;1448	ff 	. 
	rst 38h			;1449	ff 	. 
	rst 38h			;144a	ff 	. 
	rst 38h			;144b	ff 	. 
	rst 38h			;144c	ff 	. 
	rst 38h			;144d	ff 	. 
	rst 38h			;144e	ff 	. 
	rst 38h			;144f	ff 	. 
	rst 38h			;1450	ff 	. 
	rst 38h			;1451	ff 	. 
	rst 38h			;1452	ff 	. 
	rst 38h			;1453	ff 	. 
	rst 38h			;1454	ff 	. 
	rst 38h			;1455	ff 	. 
	rst 38h			;1456	ff 	. 
	rst 38h			;1457	ff 	. 
	rst 38h			;1458	ff 	. 
	rst 38h			;1459	ff 	. 
	rst 38h			;145a	ff 	. 
	rst 38h			;145b	ff 	. 
	rst 38h			;145c	ff 	. 
	rst 38h			;145d	ff 	. 
	rst 38h			;145e	ff 	. 
	rst 38h			;145f	ff 	. 
	rst 38h			;1460	ff 	. 
	rst 38h			;1461	ff 	. 
	rst 38h			;1462	ff 	. 
	rst 38h			;1463	ff 	. 
	rst 38h			;1464	ff 	. 
	rst 38h			;1465	ff 	. 
	rst 38h			;1466	ff 	. 
	rst 38h			;1467	ff 	. 
	rst 38h			;1468	ff 	. 
	rst 38h			;1469	ff 	. 
	rst 38h			;146a	ff 	. 
	rst 38h			;146b	ff 	. 
	rst 38h			;146c	ff 	. 
	rst 38h			;146d	ff 	. 
	rst 38h			;146e	ff 	. 
	rst 38h			;146f	ff 	. 
	rst 38h			;1470	ff 	. 
	rst 38h			;1471	ff 	. 
	rst 38h			;1472	ff 	. 
	rst 38h			;1473	ff 	. 
	rst 38h			;1474	ff 	. 
	rst 38h			;1475	ff 	. 
	rst 38h			;1476	ff 	. 
	rst 38h			;1477	ff 	. 
	rst 38h			;1478	ff 	. 
	rst 38h			;1479	ff 	. 
	rst 38h			;147a	ff 	. 
	rst 38h			;147b	ff 	. 
	rst 38h			;147c	ff 	. 
	rst 38h			;147d	ff 	. 
	rst 38h			;147e	ff 	. 
	rst 38h			;147f	ff 	. 
	rst 38h			;1480	ff 	. 
	rst 38h			;1481	ff 	. 
	rst 38h			;1482	ff 	. 
	rst 38h			;1483	ff 	. 
	rst 38h			;1484	ff 	. 
	rst 38h			;1485	ff 	. 
	rst 38h			;1486	ff 	. 
	rst 38h			;1487	ff 	. 
	rst 38h			;1488	ff 	. 
	rst 38h			;1489	ff 	. 
	rst 38h			;148a	ff 	. 
	rst 38h			;148b	ff 	. 
	rst 38h			;148c	ff 	. 
	rst 38h			;148d	ff 	. 
	rst 38h			;148e	ff 	. 
	rst 38h			;148f	ff 	. 
	rst 38h			;1490	ff 	. 
	rst 38h			;1491	ff 	. 
	rst 38h			;1492	ff 	. 
	rst 38h			;1493	ff 	. 
	rst 38h			;1494	ff 	. 
	rst 38h			;1495	ff 	. 
	rst 38h			;1496	ff 	. 
	rst 38h			;1497	ff 	. 
	rst 38h			;1498	ff 	. 
	rst 38h			;1499	ff 	. 
	rst 38h			;149a	ff 	. 
	rst 38h			;149b	ff 	. 
	rst 38h			;149c	ff 	. 
	rst 38h			;149d	ff 	. 
	rst 38h			;149e	ff 	. 
	rst 38h			;149f	ff 	. 
	rst 38h			;14a0	ff 	. 
	rst 38h			;14a1	ff 	. 
	rst 38h			;14a2	ff 	. 
	rst 38h			;14a3	ff 	. 
	rst 38h			;14a4	ff 	. 
	rst 38h			;14a5	ff 	. 
	rst 38h			;14a6	ff 	. 
	rst 38h			;14a7	ff 	. 
	rst 38h			;14a8	ff 	. 
	rst 38h			;14a9	ff 	. 
	rst 38h			;14aa	ff 	. 
	rst 38h			;14ab	ff 	. 
	rst 38h			;14ac	ff 	. 
	rst 38h			;14ad	ff 	. 
	rst 38h			;14ae	ff 	. 
	rst 38h			;14af	ff 	. 
	rst 38h			;14b0	ff 	. 
	rst 38h			;14b1	ff 	. 
	rst 38h			;14b2	ff 	. 
	rst 38h			;14b3	ff 	. 
	rst 38h			;14b4	ff 	. 
	rst 38h			;14b5	ff 	. 
	rst 38h			;14b6	ff 	. 
	rst 38h			;14b7	ff 	. 
	rst 38h			;14b8	ff 	. 
	rst 38h			;14b9	ff 	. 
	rst 38h			;14ba	ff 	. 
	rst 38h			;14bb	ff 	. 
	rst 38h			;14bc	ff 	. 
	rst 38h			;14bd	ff 	. 
	rst 38h			;14be	ff 	. 
	rst 38h			;14bf	ff 	. 
	rst 38h			;14c0	ff 	. 
	rst 38h			;14c1	ff 	. 
	rst 38h			;14c2	ff 	. 
	rst 38h			;14c3	ff 	. 
	rst 38h			;14c4	ff 	. 
	rst 38h			;14c5	ff 	. 
	rst 38h			;14c6	ff 	. 
	rst 38h			;14c7	ff 	. 
	rst 38h			;14c8	ff 	. 
	rst 38h			;14c9	ff 	. 
	rst 38h			;14ca	ff 	. 
	rst 38h			;14cb	ff 	. 
	rst 38h			;14cc	ff 	. 
	rst 38h			;14cd	ff 	. 
	rst 38h			;14ce	ff 	. 
	rst 38h			;14cf	ff 	. 
	rst 38h			;14d0	ff 	. 
	rst 38h			;14d1	ff 	. 
	rst 38h			;14d2	ff 	. 
	rst 38h			;14d3	ff 	. 
	rst 38h			;14d4	ff 	. 
	rst 38h			;14d5	ff 	. 
	rst 38h			;14d6	ff 	. 
	rst 38h			;14d7	ff 	. 
	rst 38h			;14d8	ff 	. 
	rst 38h			;14d9	ff 	. 
	rst 38h			;14da	ff 	. 
	rst 38h			;14db	ff 	. 
	rst 38h			;14dc	ff 	. 
	rst 38h			;14dd	ff 	. 
	rst 38h			;14de	ff 	. 
	rst 38h			;14df	ff 	. 
	rst 38h			;14e0	ff 	. 
	rst 38h			;14e1	ff 	. 
	rst 38h			;14e2	ff 	. 
	rst 38h			;14e3	ff 	. 
	rst 38h			;14e4	ff 	. 
	rst 38h			;14e5	ff 	. 
	rst 38h			;14e6	ff 	. 
	rst 38h			;14e7	ff 	. 
	rst 38h			;14e8	ff 	. 
	rst 38h			;14e9	ff 	. 
	rst 38h			;14ea	ff 	. 
	rst 38h			;14eb	ff 	. 
	rst 38h			;14ec	ff 	. 
	rst 38h			;14ed	ff 	. 
	rst 38h			;14ee	ff 	. 
	rst 38h			;14ef	ff 	. 
	rst 38h			;14f0	ff 	. 
	rst 38h			;14f1	ff 	. 
	rst 38h			;14f2	ff 	. 
	rst 38h			;14f3	ff 	. 
	rst 38h			;14f4	ff 	. 
	rst 38h			;14f5	ff 	. 
	rst 38h			;14f6	ff 	. 
	rst 38h			;14f7	ff 	. 
	rst 38h			;14f8	ff 	. 
	rst 38h			;14f9	ff 	. 
	rst 38h			;14fa	ff 	. 
	rst 38h			;14fb	ff 	. 
	rst 38h			;14fc	ff 	. 
	rst 38h			;14fd	ff 	. 
	rst 38h			;14fe	ff 	. 
	rst 38h			;14ff	ff 	. 
	rst 38h			;1500	ff 	. 
	rst 38h			;1501	ff 	. 
	rst 38h			;1502	ff 	. 
	rst 38h			;1503	ff 	. 
	rst 38h			;1504	ff 	. 
	rst 38h			;1505	ff 	. 
	rst 38h			;1506	ff 	. 
	rst 38h			;1507	ff 	. 
	rst 38h			;1508	ff 	. 
	rst 38h			;1509	ff 	. 
	rst 38h			;150a	ff 	. 
	rst 38h			;150b	ff 	. 
	rst 38h			;150c	ff 	. 
	rst 38h			;150d	ff 	. 
	rst 38h			;150e	ff 	. 
	rst 38h			;150f	ff 	. 
	rst 38h			;1510	ff 	. 
	rst 38h			;1511	ff 	. 
	rst 38h			;1512	ff 	. 
	rst 38h			;1513	ff 	. 
	rst 38h			;1514	ff 	. 
	rst 38h			;1515	ff 	. 
	rst 38h			;1516	ff 	. 
	rst 38h			;1517	ff 	. 
	rst 38h			;1518	ff 	. 
	rst 38h			;1519	ff 	. 
	rst 38h			;151a	ff 	. 
	rst 38h			;151b	ff 	. 
	rst 38h			;151c	ff 	. 
	rst 38h			;151d	ff 	. 
	rst 38h			;151e	ff 	. 
	rst 38h			;151f	ff 	. 
	rst 38h			;1520	ff 	. 
	rst 38h			;1521	ff 	. 
	rst 38h			;1522	ff 	. 
	rst 38h			;1523	ff 	. 
	rst 38h			;1524	ff 	. 
	rst 38h			;1525	ff 	. 
	rst 38h			;1526	ff 	. 
	rst 38h			;1527	ff 	. 
	rst 38h			;1528	ff 	. 
	rst 38h			;1529	ff 	. 
	rst 38h			;152a	ff 	. 
	rst 38h			;152b	ff 	. 
	rst 38h			;152c	ff 	. 
	rst 38h			;152d	ff 	. 
	rst 38h			;152e	ff 	. 
	rst 38h			;152f	ff 	. 
	rst 38h			;1530	ff 	. 
	rst 38h			;1531	ff 	. 
	rst 38h			;1532	ff 	. 
	rst 38h			;1533	ff 	. 
	rst 38h			;1534	ff 	. 
	rst 38h			;1535	ff 	. 
	rst 38h			;1536	ff 	. 
	rst 38h			;1537	ff 	. 
	rst 38h			;1538	ff 	. 
	rst 38h			;1539	ff 	. 
	rst 38h			;153a	ff 	. 
	rst 38h			;153b	ff 	. 
	rst 38h			;153c	ff 	. 
	rst 38h			;153d	ff 	. 
	rst 38h			;153e	ff 	. 
	rst 38h			;153f	ff 	. 
	rst 38h			;1540	ff 	. 
	rst 38h			;1541	ff 	. 
	rst 38h			;1542	ff 	. 
	rst 38h			;1543	ff 	. 
	rst 38h			;1544	ff 	. 
	rst 38h			;1545	ff 	. 
	rst 38h			;1546	ff 	. 
	rst 38h			;1547	ff 	. 
	rst 38h			;1548	ff 	. 
	rst 38h			;1549	ff 	. 
	rst 38h			;154a	ff 	. 
	rst 38h			;154b	ff 	. 
	rst 38h			;154c	ff 	. 
	rst 38h			;154d	ff 	. 
	rst 38h			;154e	ff 	. 
	rst 38h			;154f	ff 	. 
	rst 38h			;1550	ff 	. 
	rst 38h			;1551	ff 	. 
	rst 38h			;1552	ff 	. 
	rst 38h			;1553	ff 	. 
	rst 38h			;1554	ff 	. 
	rst 38h			;1555	ff 	. 
	rst 38h			;1556	ff 	. 
	rst 38h			;1557	ff 	. 
	rst 38h			;1558	ff 	. 
	rst 38h			;1559	ff 	. 
	rst 38h			;155a	ff 	. 
	rst 38h			;155b	ff 	. 
	rst 38h			;155c	ff 	. 
	rst 38h			;155d	ff 	. 
	rst 38h			;155e	ff 	. 
	rst 38h			;155f	ff 	. 
	rst 38h			;1560	ff 	. 
	rst 38h			;1561	ff 	. 
	rst 38h			;1562	ff 	. 
	rst 38h			;1563	ff 	. 
	rst 38h			;1564	ff 	. 
	rst 38h			;1565	ff 	. 
	rst 38h			;1566	ff 	. 
	rst 38h			;1567	ff 	. 
	rst 38h			;1568	ff 	. 
	rst 38h			;1569	ff 	. 
	rst 38h			;156a	ff 	. 
	rst 38h			;156b	ff 	. 
	rst 38h			;156c	ff 	. 
	rst 38h			;156d	ff 	. 
	rst 38h			;156e	ff 	. 
	rst 38h			;156f	ff 	. 
	rst 38h			;1570	ff 	. 
	rst 38h			;1571	ff 	. 
	rst 38h			;1572	ff 	. 
	rst 38h			;1573	ff 	. 
	rst 38h			;1574	ff 	. 
	rst 38h			;1575	ff 	. 
	rst 38h			;1576	ff 	. 
	rst 38h			;1577	ff 	. 
	rst 38h			;1578	ff 	. 
	rst 38h			;1579	ff 	. 
	rst 38h			;157a	ff 	. 
	rst 38h			;157b	ff 	. 
	rst 38h			;157c	ff 	. 
	rst 38h			;157d	ff 	. 
	rst 38h			;157e	ff 	. 
	rst 38h			;157f	ff 	. 
	rst 38h			;1580	ff 	. 
	rst 38h			;1581	ff 	. 
	rst 38h			;1582	ff 	. 
	rst 38h			;1583	ff 	. 
	rst 38h			;1584	ff 	. 
	rst 38h			;1585	ff 	. 
	rst 38h			;1586	ff 	. 
	rst 38h			;1587	ff 	. 
	rst 38h			;1588	ff 	. 
	rst 38h			;1589	ff 	. 
	rst 38h			;158a	ff 	. 
	rst 38h			;158b	ff 	. 
	rst 38h			;158c	ff 	. 
	rst 38h			;158d	ff 	. 
	rst 38h			;158e	ff 	. 
	rst 38h			;158f	ff 	. 
	rst 38h			;1590	ff 	. 
	rst 38h			;1591	ff 	. 
	rst 38h			;1592	ff 	. 
	rst 38h			;1593	ff 	. 
	rst 38h			;1594	ff 	. 
	rst 38h			;1595	ff 	. 
	rst 38h			;1596	ff 	. 
	rst 38h			;1597	ff 	. 
	rst 38h			;1598	ff 	. 
	rst 38h			;1599	ff 	. 
	rst 38h			;159a	ff 	. 
	rst 38h			;159b	ff 	. 
	rst 38h			;159c	ff 	. 
	rst 38h			;159d	ff 	. 
	rst 38h			;159e	ff 	. 
	rst 38h			;159f	ff 	. 
	rst 38h			;15a0	ff 	. 
	rst 38h			;15a1	ff 	. 
	rst 38h			;15a2	ff 	. 
	rst 38h			;15a3	ff 	. 
	rst 38h			;15a4	ff 	. 
	rst 38h			;15a5	ff 	. 
	rst 38h			;15a6	ff 	. 
	rst 38h			;15a7	ff 	. 
	rst 38h			;15a8	ff 	. 
	rst 38h			;15a9	ff 	. 
	rst 38h			;15aa	ff 	. 
	rst 38h			;15ab	ff 	. 
	rst 38h			;15ac	ff 	. 
	rst 38h			;15ad	ff 	. 
	rst 38h			;15ae	ff 	. 
	rst 38h			;15af	ff 	. 
	rst 38h			;15b0	ff 	. 
	rst 38h			;15b1	ff 	. 
	rst 38h			;15b2	ff 	. 
	rst 38h			;15b3	ff 	. 
	rst 38h			;15b4	ff 	. 
	rst 38h			;15b5	ff 	. 
	rst 38h			;15b6	ff 	. 
	rst 38h			;15b7	ff 	. 
	rst 38h			;15b8	ff 	. 
	rst 38h			;15b9	ff 	. 
	rst 38h			;15ba	ff 	. 
	rst 38h			;15bb	ff 	. 
	rst 38h			;15bc	ff 	. 
	rst 38h			;15bd	ff 	. 
	rst 38h			;15be	ff 	. 
	rst 38h			;15bf	ff 	. 
	rst 38h			;15c0	ff 	. 
	rst 38h			;15c1	ff 	. 
	rst 38h			;15c2	ff 	. 
	rst 38h			;15c3	ff 	. 
	rst 38h			;15c4	ff 	. 
	rst 38h			;15c5	ff 	. 
	rst 38h			;15c6	ff 	. 
	rst 38h			;15c7	ff 	. 
	rst 38h			;15c8	ff 	. 
	rst 38h			;15c9	ff 	. 
	rst 38h			;15ca	ff 	. 
	rst 38h			;15cb	ff 	. 
	rst 38h			;15cc	ff 	. 
	rst 38h			;15cd	ff 	. 
	rst 38h			;15ce	ff 	. 
	rst 38h			;15cf	ff 	. 
	rst 38h			;15d0	ff 	. 
	rst 38h			;15d1	ff 	. 
	rst 38h			;15d2	ff 	. 
	rst 38h			;15d3	ff 	. 
	rst 38h			;15d4	ff 	. 
	rst 38h			;15d5	ff 	. 
	rst 38h			;15d6	ff 	. 
	rst 38h			;15d7	ff 	. 
	rst 38h			;15d8	ff 	. 
	rst 38h			;15d9	ff 	. 
	rst 38h			;15da	ff 	. 
	rst 38h			;15db	ff 	. 
	rst 38h			;15dc	ff 	. 
	rst 38h			;15dd	ff 	. 
	rst 38h			;15de	ff 	. 
	rst 38h			;15df	ff 	. 
	rst 38h			;15e0	ff 	. 
	rst 38h			;15e1	ff 	. 
	rst 38h			;15e2	ff 	. 
	rst 38h			;15e3	ff 	. 
	rst 38h			;15e4	ff 	. 
	rst 38h			;15e5	ff 	. 
	rst 38h			;15e6	ff 	. 
	rst 38h			;15e7	ff 	. 
	rst 38h			;15e8	ff 	. 
	rst 38h			;15e9	ff 	. 
	rst 38h			;15ea	ff 	. 
	rst 38h			;15eb	ff 	. 
	rst 38h			;15ec	ff 	. 
	rst 38h			;15ed	ff 	. 
	rst 38h			;15ee	ff 	. 
	rst 38h			;15ef	ff 	. 
	rst 38h			;15f0	ff 	. 
	rst 38h			;15f1	ff 	. 
	rst 38h			;15f2	ff 	. 
	rst 38h			;15f3	ff 	. 
	rst 38h			;15f4	ff 	. 
	rst 38h			;15f5	ff 	. 
	rst 38h			;15f6	ff 	. 
	rst 38h			;15f7	ff 	. 
	rst 38h			;15f8	ff 	. 
	rst 38h			;15f9	ff 	. 
	rst 38h			;15fa	ff 	. 
	rst 38h			;15fb	ff 	. 
	rst 38h			;15fc	ff 	. 
	rst 38h			;15fd	ff 	. 
	rst 38h			;15fe	ff 	. 
	rst 38h			;15ff	ff 	. 
	rst 38h			;1600	ff 	. 
	rst 38h			;1601	ff 	. 
	rst 38h			;1602	ff 	. 
	rst 38h			;1603	ff 	. 
	rst 38h			;1604	ff 	. 
	rst 38h			;1605	ff 	. 
	rst 38h			;1606	ff 	. 
	rst 38h			;1607	ff 	. 
	rst 38h			;1608	ff 	. 
	rst 38h			;1609	ff 	. 
	rst 38h			;160a	ff 	. 
	rst 38h			;160b	ff 	. 
	rst 38h			;160c	ff 	. 
	rst 38h			;160d	ff 	. 
	rst 38h			;160e	ff 	. 
	rst 38h			;160f	ff 	. 
	rst 38h			;1610	ff 	. 
	rst 38h			;1611	ff 	. 
	rst 38h			;1612	ff 	. 
	rst 38h			;1613	ff 	. 
	rst 38h			;1614	ff 	. 
	rst 38h			;1615	ff 	. 
	rst 38h			;1616	ff 	. 
	rst 38h			;1617	ff 	. 
	rst 38h			;1618	ff 	. 
	rst 38h			;1619	ff 	. 
	rst 38h			;161a	ff 	. 
	rst 38h			;161b	ff 	. 
	rst 38h			;161c	ff 	. 
	rst 38h			;161d	ff 	. 
	rst 38h			;161e	ff 	. 
	rst 38h			;161f	ff 	. 
	rst 38h			;1620	ff 	. 
	rst 38h			;1621	ff 	. 
	rst 38h			;1622	ff 	. 
	rst 38h			;1623	ff 	. 
	rst 38h			;1624	ff 	. 
	rst 38h			;1625	ff 	. 
	rst 38h			;1626	ff 	. 
	rst 38h			;1627	ff 	. 
	rst 38h			;1628	ff 	. 
	rst 38h			;1629	ff 	. 
	rst 38h			;162a	ff 	. 
	rst 38h			;162b	ff 	. 
	rst 38h			;162c	ff 	. 
	rst 38h			;162d	ff 	. 
	rst 38h			;162e	ff 	. 
	rst 38h			;162f	ff 	. 
	rst 38h			;1630	ff 	. 
	rst 38h			;1631	ff 	. 
	rst 38h			;1632	ff 	. 
	rst 38h			;1633	ff 	. 
	rst 38h			;1634	ff 	. 
	rst 38h			;1635	ff 	. 
	rst 38h			;1636	ff 	. 
	rst 38h			;1637	ff 	. 
	rst 38h			;1638	ff 	. 
	rst 38h			;1639	ff 	. 
	rst 38h			;163a	ff 	. 
	rst 38h			;163b	ff 	. 
	rst 38h			;163c	ff 	. 
	rst 38h			;163d	ff 	. 
	rst 38h			;163e	ff 	. 
	rst 38h			;163f	ff 	. 
	rst 38h			;1640	ff 	. 
	rst 38h			;1641	ff 	. 
	rst 38h			;1642	ff 	. 
	rst 38h			;1643	ff 	. 
	rst 38h			;1644	ff 	. 
	rst 38h			;1645	ff 	. 
	rst 38h			;1646	ff 	. 
	rst 38h			;1647	ff 	. 
	rst 38h			;1648	ff 	. 
	rst 38h			;1649	ff 	. 
	rst 38h			;164a	ff 	. 
	rst 38h			;164b	ff 	. 
	rst 38h			;164c	ff 	. 
	rst 38h			;164d	ff 	. 
	rst 38h			;164e	ff 	. 
	rst 38h			;164f	ff 	. 
	rst 38h			;1650	ff 	. 
	rst 38h			;1651	ff 	. 
	rst 38h			;1652	ff 	. 
	rst 38h			;1653	ff 	. 
	rst 38h			;1654	ff 	. 
	rst 38h			;1655	ff 	. 
	rst 38h			;1656	ff 	. 
	rst 38h			;1657	ff 	. 
	rst 38h			;1658	ff 	. 
	rst 38h			;1659	ff 	. 
	rst 38h			;165a	ff 	. 
	rst 38h			;165b	ff 	. 
	rst 38h			;165c	ff 	. 
	rst 38h			;165d	ff 	. 
	rst 38h			;165e	ff 	. 
	rst 38h			;165f	ff 	. 
	rst 38h			;1660	ff 	. 
	rst 38h			;1661	ff 	. 
	rst 38h			;1662	ff 	. 
	rst 38h			;1663	ff 	. 
	rst 38h			;1664	ff 	. 
	rst 38h			;1665	ff 	. 
	rst 38h			;1666	ff 	. 
	rst 38h			;1667	ff 	. 
	rst 38h			;1668	ff 	. 
	rst 38h			;1669	ff 	. 
	rst 38h			;166a	ff 	. 
	rst 38h			;166b	ff 	. 
	rst 38h			;166c	ff 	. 
	rst 38h			;166d	ff 	. 
	rst 38h			;166e	ff 	. 
	rst 38h			;166f	ff 	. 
	rst 38h			;1670	ff 	. 
	rst 38h			;1671	ff 	. 
	rst 38h			;1672	ff 	. 
	rst 38h			;1673	ff 	. 
	rst 38h			;1674	ff 	. 
	rst 38h			;1675	ff 	. 
	rst 38h			;1676	ff 	. 
	rst 38h			;1677	ff 	. 
	rst 38h			;1678	ff 	. 
	rst 38h			;1679	ff 	. 
	rst 38h			;167a	ff 	. 
	rst 38h			;167b	ff 	. 
	rst 38h			;167c	ff 	. 
	rst 38h			;167d	ff 	. 
	rst 38h			;167e	ff 	. 
	rst 38h			;167f	ff 	. 
	rst 38h			;1680	ff 	. 
	rst 38h			;1681	ff 	. 
	rst 38h			;1682	ff 	. 
	rst 38h			;1683	ff 	. 
	rst 38h			;1684	ff 	. 
	rst 38h			;1685	ff 	. 
	rst 38h			;1686	ff 	. 
	rst 38h			;1687	ff 	. 
	rst 38h			;1688	ff 	. 
	rst 38h			;1689	ff 	. 
	rst 38h			;168a	ff 	. 
	rst 38h			;168b	ff 	. 
	rst 38h			;168c	ff 	. 
	rst 38h			;168d	ff 	. 
	rst 38h			;168e	ff 	. 
	rst 38h			;168f	ff 	. 
	rst 38h			;1690	ff 	. 
	rst 38h			;1691	ff 	. 
	rst 38h			;1692	ff 	. 
	rst 38h			;1693	ff 	. 
	rst 38h			;1694	ff 	. 
	rst 38h			;1695	ff 	. 
	rst 38h			;1696	ff 	. 
	rst 38h			;1697	ff 	. 
	rst 38h			;1698	ff 	. 
	rst 38h			;1699	ff 	. 
	rst 38h			;169a	ff 	. 
	rst 38h			;169b	ff 	. 
	rst 38h			;169c	ff 	. 
	rst 38h			;169d	ff 	. 
	rst 38h			;169e	ff 	. 
	rst 38h			;169f	ff 	. 
	rst 38h			;16a0	ff 	. 
	rst 38h			;16a1	ff 	. 
	rst 38h			;16a2	ff 	. 
	rst 38h			;16a3	ff 	. 
	rst 38h			;16a4	ff 	. 
	rst 38h			;16a5	ff 	. 
	rst 38h			;16a6	ff 	. 
	rst 38h			;16a7	ff 	. 
	rst 38h			;16a8	ff 	. 
	rst 38h			;16a9	ff 	. 
	rst 38h			;16aa	ff 	. 
	rst 38h			;16ab	ff 	. 
	rst 38h			;16ac	ff 	. 
	rst 38h			;16ad	ff 	. 
	rst 38h			;16ae	ff 	. 
	rst 38h			;16af	ff 	. 
	rst 38h			;16b0	ff 	. 
	rst 38h			;16b1	ff 	. 
	rst 38h			;16b2	ff 	. 
	rst 38h			;16b3	ff 	. 
	rst 38h			;16b4	ff 	. 
	rst 38h			;16b5	ff 	. 
	rst 38h			;16b6	ff 	. 
	rst 38h			;16b7	ff 	. 
	rst 38h			;16b8	ff 	. 
	rst 38h			;16b9	ff 	. 
	rst 38h			;16ba	ff 	. 
	rst 38h			;16bb	ff 	. 
	rst 38h			;16bc	ff 	. 
	rst 38h			;16bd	ff 	. 
	rst 38h			;16be	ff 	. 
	rst 38h			;16bf	ff 	. 
	rst 38h			;16c0	ff 	. 
	rst 38h			;16c1	ff 	. 
	rst 38h			;16c2	ff 	. 
	rst 38h			;16c3	ff 	. 
	rst 38h			;16c4	ff 	. 
	rst 38h			;16c5	ff 	. 
	rst 38h			;16c6	ff 	. 
	rst 38h			;16c7	ff 	. 
	rst 38h			;16c8	ff 	. 
	rst 38h			;16c9	ff 	. 
	rst 38h			;16ca	ff 	. 
	rst 38h			;16cb	ff 	. 
	rst 38h			;16cc	ff 	. 
	rst 38h			;16cd	ff 	. 
	rst 38h			;16ce	ff 	. 
	rst 38h			;16cf	ff 	. 
	rst 38h			;16d0	ff 	. 
	rst 38h			;16d1	ff 	. 
	rst 38h			;16d2	ff 	. 
	rst 38h			;16d3	ff 	. 
	rst 38h			;16d4	ff 	. 
	rst 38h			;16d5	ff 	. 
	rst 38h			;16d6	ff 	. 
	rst 38h			;16d7	ff 	. 
	rst 38h			;16d8	ff 	. 
	rst 38h			;16d9	ff 	. 
	rst 38h			;16da	ff 	. 
	rst 38h			;16db	ff 	. 
	rst 38h			;16dc	ff 	. 
	rst 38h			;16dd	ff 	. 
	rst 38h			;16de	ff 	. 
	rst 38h			;16df	ff 	. 
	rst 38h			;16e0	ff 	. 
	rst 38h			;16e1	ff 	. 
	rst 38h			;16e2	ff 	. 
	rst 38h			;16e3	ff 	. 
	rst 38h			;16e4	ff 	. 
	rst 38h			;16e5	ff 	. 
	rst 38h			;16e6	ff 	. 
	rst 38h			;16e7	ff 	. 
	rst 38h			;16e8	ff 	. 
	rst 38h			;16e9	ff 	. 
	rst 38h			;16ea	ff 	. 
	rst 38h			;16eb	ff 	. 
	rst 38h			;16ec	ff 	. 
	rst 38h			;16ed	ff 	. 
	rst 38h			;16ee	ff 	. 
	rst 38h			;16ef	ff 	. 
	rst 38h			;16f0	ff 	. 
	rst 38h			;16f1	ff 	. 
	rst 38h			;16f2	ff 	. 
	rst 38h			;16f3	ff 	. 
	rst 38h			;16f4	ff 	. 
	rst 38h			;16f5	ff 	. 
	rst 38h			;16f6	ff 	. 
	rst 38h			;16f7	ff 	. 
	rst 38h			;16f8	ff 	. 
	rst 38h			;16f9	ff 	. 
	rst 38h			;16fa	ff 	. 
	rst 38h			;16fb	ff 	. 
	rst 38h			;16fc	ff 	. 
	rst 38h			;16fd	ff 	. 
	rst 38h			;16fe	ff 	. 
	rst 38h			;16ff	ff 	. 
	rst 38h			;1700	ff 	. 
	rst 38h			;1701	ff 	. 
	rst 38h			;1702	ff 	. 
	rst 38h			;1703	ff 	. 
	rst 38h			;1704	ff 	. 
	rst 38h			;1705	ff 	. 
	rst 38h			;1706	ff 	. 
	rst 38h			;1707	ff 	. 
	rst 38h			;1708	ff 	. 
	rst 38h			;1709	ff 	. 
	rst 38h			;170a	ff 	. 
	rst 38h			;170b	ff 	. 
	rst 38h			;170c	ff 	. 
	rst 38h			;170d	ff 	. 
	rst 38h			;170e	ff 	. 
	rst 38h			;170f	ff 	. 
	rst 38h			;1710	ff 	. 
	rst 38h			;1711	ff 	. 
	rst 38h			;1712	ff 	. 
	rst 38h			;1713	ff 	. 
	rst 38h			;1714	ff 	. 
	rst 38h			;1715	ff 	. 
	rst 38h			;1716	ff 	. 
	rst 38h			;1717	ff 	. 
	rst 38h			;1718	ff 	. 
	rst 38h			;1719	ff 	. 
	rst 38h			;171a	ff 	. 
	rst 38h			;171b	ff 	. 
	rst 38h			;171c	ff 	. 
	rst 38h			;171d	ff 	. 
	rst 38h			;171e	ff 	. 
	rst 38h			;171f	ff 	. 
	rst 38h			;1720	ff 	. 
	rst 38h			;1721	ff 	. 
	rst 38h			;1722	ff 	. 
	rst 38h			;1723	ff 	. 
	rst 38h			;1724	ff 	. 
	rst 38h			;1725	ff 	. 
	rst 38h			;1726	ff 	. 
	rst 38h			;1727	ff 	. 
	rst 38h			;1728	ff 	. 
	rst 38h			;1729	ff 	. 
	rst 38h			;172a	ff 	. 
	rst 38h			;172b	ff 	. 
	rst 38h			;172c	ff 	. 
	rst 38h			;172d	ff 	. 
	rst 38h			;172e	ff 	. 
	rst 38h			;172f	ff 	. 
	rst 38h			;1730	ff 	. 
	rst 38h			;1731	ff 	. 
	rst 38h			;1732	ff 	. 
	rst 38h			;1733	ff 	. 
	rst 38h			;1734	ff 	. 
	rst 38h			;1735	ff 	. 
	rst 38h			;1736	ff 	. 
	rst 38h			;1737	ff 	. 
	rst 38h			;1738	ff 	. 
	rst 38h			;1739	ff 	. 
	rst 38h			;173a	ff 	. 
	rst 38h			;173b	ff 	. 
	rst 38h			;173c	ff 	. 
	rst 38h			;173d	ff 	. 
	rst 38h			;173e	ff 	. 
	rst 38h			;173f	ff 	. 
	rst 38h			;1740	ff 	. 
	rst 38h			;1741	ff 	. 
	rst 38h			;1742	ff 	. 
	rst 38h			;1743	ff 	. 
	rst 38h			;1744	ff 	. 
	rst 38h			;1745	ff 	. 
	rst 38h			;1746	ff 	. 
	rst 38h			;1747	ff 	. 
	rst 38h			;1748	ff 	. 
	rst 38h			;1749	ff 	. 
	rst 38h			;174a	ff 	. 
	rst 38h			;174b	ff 	. 
	rst 38h			;174c	ff 	. 
	rst 38h			;174d	ff 	. 
	rst 38h			;174e	ff 	. 
	rst 38h			;174f	ff 	. 
	rst 38h			;1750	ff 	. 
	rst 38h			;1751	ff 	. 
	rst 38h			;1752	ff 	. 
	rst 38h			;1753	ff 	. 
	rst 38h			;1754	ff 	. 
	rst 38h			;1755	ff 	. 
	rst 38h			;1756	ff 	. 
	rst 38h			;1757	ff 	. 
	rst 38h			;1758	ff 	. 
	rst 38h			;1759	ff 	. 
	rst 38h			;175a	ff 	. 
	rst 38h			;175b	ff 	. 
	rst 38h			;175c	ff 	. 
	rst 38h			;175d	ff 	. 
	rst 38h			;175e	ff 	. 
	rst 38h			;175f	ff 	. 
	rst 38h			;1760	ff 	. 
	rst 38h			;1761	ff 	. 
	rst 38h			;1762	ff 	. 
	rst 38h			;1763	ff 	. 
	rst 38h			;1764	ff 	. 
	rst 38h			;1765	ff 	. 
	rst 38h			;1766	ff 	. 
	rst 38h			;1767	ff 	. 
	rst 38h			;1768	ff 	. 
	rst 38h			;1769	ff 	. 
	rst 38h			;176a	ff 	. 
	rst 38h			;176b	ff 	. 
	rst 38h			;176c	ff 	. 
	rst 38h			;176d	ff 	. 
	rst 38h			;176e	ff 	. 
	rst 38h			;176f	ff 	. 
	rst 38h			;1770	ff 	. 
	rst 38h			;1771	ff 	. 
	rst 38h			;1772	ff 	. 
	rst 38h			;1773	ff 	. 
	rst 38h			;1774	ff 	. 
	rst 38h			;1775	ff 	. 
	rst 38h			;1776	ff 	. 
	rst 38h			;1777	ff 	. 
	rst 38h			;1778	ff 	. 
	rst 38h			;1779	ff 	. 
	rst 38h			;177a	ff 	. 
	rst 38h			;177b	ff 	. 
	rst 38h			;177c	ff 	. 
	rst 38h			;177d	ff 	. 
	rst 38h			;177e	ff 	. 
	rst 38h			;177f	ff 	. 
	rst 38h			;1780	ff 	. 
	rst 38h			;1781	ff 	. 
	rst 38h			;1782	ff 	. 
	rst 38h			;1783	ff 	. 
	rst 38h			;1784	ff 	. 
	rst 38h			;1785	ff 	. 
	rst 38h			;1786	ff 	. 
	rst 38h			;1787	ff 	. 
	rst 38h			;1788	ff 	. 
	rst 38h			;1789	ff 	. 
	rst 38h			;178a	ff 	. 
	rst 38h			;178b	ff 	. 
	rst 38h			;178c	ff 	. 
	rst 38h			;178d	ff 	. 
	rst 38h			;178e	ff 	. 
	rst 38h			;178f	ff 	. 
	rst 38h			;1790	ff 	. 
	rst 38h			;1791	ff 	. 
	rst 38h			;1792	ff 	. 
	rst 38h			;1793	ff 	. 
	rst 38h			;1794	ff 	. 
	rst 38h			;1795	ff 	. 
	rst 38h			;1796	ff 	. 
	rst 38h			;1797	ff 	. 
	rst 38h			;1798	ff 	. 
	rst 38h			;1799	ff 	. 
	rst 38h			;179a	ff 	. 
	rst 38h			;179b	ff 	. 
	rst 38h			;179c	ff 	. 
	rst 38h			;179d	ff 	. 
	rst 38h			;179e	ff 	. 
	rst 38h			;179f	ff 	. 
	rst 38h			;17a0	ff 	. 
	rst 38h			;17a1	ff 	. 
	rst 38h			;17a2	ff 	. 
	rst 38h			;17a3	ff 	. 
	rst 38h			;17a4	ff 	. 
	rst 38h			;17a5	ff 	. 
	rst 38h			;17a6	ff 	. 
	rst 38h			;17a7	ff 	. 
	rst 38h			;17a8	ff 	. 
	rst 38h			;17a9	ff 	. 
	rst 38h			;17aa	ff 	. 
	rst 38h			;17ab	ff 	. 
	rst 38h			;17ac	ff 	. 
	rst 38h			;17ad	ff 	. 
	rst 38h			;17ae	ff 	. 
	rst 38h			;17af	ff 	. 
	rst 38h			;17b0	ff 	. 
	rst 38h			;17b1	ff 	. 
	rst 38h			;17b2	ff 	. 
	rst 38h			;17b3	ff 	. 
	rst 38h			;17b4	ff 	. 
	rst 38h			;17b5	ff 	. 
	rst 38h			;17b6	ff 	. 
	rst 38h			;17b7	ff 	. 
	rst 38h			;17b8	ff 	. 
	rst 38h			;17b9	ff 	. 
	rst 38h			;17ba	ff 	. 
	rst 38h			;17bb	ff 	. 
	rst 38h			;17bc	ff 	. 
	rst 38h			;17bd	ff 	. 
	rst 38h			;17be	ff 	. 
	rst 38h			;17bf	ff 	. 
	rst 38h			;17c0	ff 	. 
	rst 38h			;17c1	ff 	. 
	rst 38h			;17c2	ff 	. 
	rst 38h			;17c3	ff 	. 
	rst 38h			;17c4	ff 	. 
	rst 38h			;17c5	ff 	. 
	rst 38h			;17c6	ff 	. 
	rst 38h			;17c7	ff 	. 
	rst 38h			;17c8	ff 	. 
	rst 38h			;17c9	ff 	. 
	rst 38h			;17ca	ff 	. 
	rst 38h			;17cb	ff 	. 
	rst 38h			;17cc	ff 	. 
	rst 38h			;17cd	ff 	. 
	rst 38h			;17ce	ff 	. 
	rst 38h			;17cf	ff 	. 
	rst 38h			;17d0	ff 	. 
	rst 38h			;17d1	ff 	. 
	rst 38h			;17d2	ff 	. 
	rst 38h			;17d3	ff 	. 
	rst 38h			;17d4	ff 	. 
	rst 38h			;17d5	ff 	. 
	rst 38h			;17d6	ff 	. 
	rst 38h			;17d7	ff 	. 
	rst 38h			;17d8	ff 	. 
	rst 38h			;17d9	ff 	. 
	rst 38h			;17da	ff 	. 
	rst 38h			;17db	ff 	. 
	rst 38h			;17dc	ff 	. 
	rst 38h			;17dd	ff 	. 
	rst 38h			;17de	ff 	. 
	rst 38h			;17df	ff 	. 
	rst 38h			;17e0	ff 	. 
	rst 38h			;17e1	ff 	. 
	rst 38h			;17e2	ff 	. 
	rst 38h			;17e3	ff 	. 
	rst 38h			;17e4	ff 	. 
	rst 38h			;17e5	ff 	. 
	rst 38h			;17e6	ff 	. 
	rst 38h			;17e7	ff 	. 
	rst 38h			;17e8	ff 	. 
	rst 38h			;17e9	ff 	. 
	rst 38h			;17ea	ff 	. 
	rst 38h			;17eb	ff 	. 
	rst 38h			;17ec	ff 	. 
	rst 38h			;17ed	ff 	. 
	rst 38h			;17ee	ff 	. 
	rst 38h			;17ef	ff 	. 
	rst 38h			;17f0	ff 	. 
	rst 38h			;17f1	ff 	. 
	rst 38h			;17f2	ff 	. 
	rst 38h			;17f3	ff 	. 
	rst 38h			;17f4	ff 	. 
	rst 38h			;17f5	ff 	. 
	rst 38h			;17f6	ff 	. 
	rst 38h			;17f7	ff 	. 
	rst 38h			;17f8	ff 	. 
	rst 38h			;17f9	ff 	. 
	rst 38h			;17fa	ff 	. 
	rst 38h			;17fb	ff 	. 
	rst 38h			;17fc	ff 	. 
	rst 38h			;17fd	ff 	. 
	rst 38h			;17fe	ff 	. 
	rst 38h			;17ff	ff 	. 
l1800h:
	rst 38h			;1800	ff 	. 
	rst 38h			;1801	ff 	. 
	rst 38h			;1802	ff 	. 
	rst 38h			;1803	ff 	. 
	rst 38h			;1804	ff 	. 
	rst 38h			;1805	ff 	. 
	rst 38h			;1806	ff 	. 
	rst 38h			;1807	ff 	. 
	rst 38h			;1808	ff 	. 
	rst 38h			;1809	ff 	. 
	rst 38h			;180a	ff 	. 
	rst 38h			;180b	ff 	. 
	rst 38h			;180c	ff 	. 
	rst 38h			;180d	ff 	. 
	rst 38h			;180e	ff 	. 
	rst 38h			;180f	ff 	. 
	rst 38h			;1810	ff 	. 
	rst 38h			;1811	ff 	. 
	rst 38h			;1812	ff 	. 
	rst 38h			;1813	ff 	. 
	rst 38h			;1814	ff 	. 
	rst 38h			;1815	ff 	. 
	rst 38h			;1816	ff 	. 
	rst 38h			;1817	ff 	. 
	rst 38h			;1818	ff 	. 
	rst 38h			;1819	ff 	. 
	rst 38h			;181a	ff 	. 
	rst 38h			;181b	ff 	. 
	rst 38h			;181c	ff 	. 
	rst 38h			;181d	ff 	. 
	rst 38h			;181e	ff 	. 
	rst 38h			;181f	ff 	. 
	rst 38h			;1820	ff 	. 
	rst 38h			;1821	ff 	. 
	rst 38h			;1822	ff 	. 
	rst 38h			;1823	ff 	. 
	rst 38h			;1824	ff 	. 
	rst 38h			;1825	ff 	. 
	rst 38h			;1826	ff 	. 
	rst 38h			;1827	ff 	. 
	rst 38h			;1828	ff 	. 
	rst 38h			;1829	ff 	. 
	rst 38h			;182a	ff 	. 
	rst 38h			;182b	ff 	. 
	rst 38h			;182c	ff 	. 
	rst 38h			;182d	ff 	. 
	rst 38h			;182e	ff 	. 
	rst 38h			;182f	ff 	. 
	rst 38h			;1830	ff 	. 
	rst 38h			;1831	ff 	. 
	rst 38h			;1832	ff 	. 
	rst 38h			;1833	ff 	. 
	rst 38h			;1834	ff 	. 
	rst 38h			;1835	ff 	. 
	rst 38h			;1836	ff 	. 
	rst 38h			;1837	ff 	. 
	rst 38h			;1838	ff 	. 
	rst 38h			;1839	ff 	. 
	rst 38h			;183a	ff 	. 
	rst 38h			;183b	ff 	. 
	rst 38h			;183c	ff 	. 
	rst 38h			;183d	ff 	. 
	rst 38h			;183e	ff 	. 
	rst 38h			;183f	ff 	. 
	rst 38h			;1840	ff 	. 
	rst 38h			;1841	ff 	. 
	rst 38h			;1842	ff 	. 
	rst 38h			;1843	ff 	. 
	rst 38h			;1844	ff 	. 
	rst 38h			;1845	ff 	. 
	rst 38h			;1846	ff 	. 
	rst 38h			;1847	ff 	. 
	rst 38h			;1848	ff 	. 
	rst 38h			;1849	ff 	. 
	rst 38h			;184a	ff 	. 
	rst 38h			;184b	ff 	. 
	rst 38h			;184c	ff 	. 
	rst 38h			;184d	ff 	. 
	rst 38h			;184e	ff 	. 
	rst 38h			;184f	ff 	. 
	rst 38h			;1850	ff 	. 
	rst 38h			;1851	ff 	. 
	rst 38h			;1852	ff 	. 
	rst 38h			;1853	ff 	. 
	rst 38h			;1854	ff 	. 
	rst 38h			;1855	ff 	. 
	rst 38h			;1856	ff 	. 
	rst 38h			;1857	ff 	. 
	rst 38h			;1858	ff 	. 
	rst 38h			;1859	ff 	. 
	rst 38h			;185a	ff 	. 
	rst 38h			;185b	ff 	. 
	rst 38h			;185c	ff 	. 
	rst 38h			;185d	ff 	. 
	rst 38h			;185e	ff 	. 
	rst 38h			;185f	ff 	. 
	rst 38h			;1860	ff 	. 
	rst 38h			;1861	ff 	. 
	rst 38h			;1862	ff 	. 
	rst 38h			;1863	ff 	. 
	rst 38h			;1864	ff 	. 
	rst 38h			;1865	ff 	. 
	rst 38h			;1866	ff 	. 
	rst 38h			;1867	ff 	. 
	rst 38h			;1868	ff 	. 
	rst 38h			;1869	ff 	. 
	rst 38h			;186a	ff 	. 
	rst 38h			;186b	ff 	. 
	rst 38h			;186c	ff 	. 
	rst 38h			;186d	ff 	. 
	rst 38h			;186e	ff 	. 
	rst 38h			;186f	ff 	. 
	rst 38h			;1870	ff 	. 
	rst 38h			;1871	ff 	. 
	rst 38h			;1872	ff 	. 
	rst 38h			;1873	ff 	. 
	rst 38h			;1874	ff 	. 
	rst 38h			;1875	ff 	. 
	rst 38h			;1876	ff 	. 
	rst 38h			;1877	ff 	. 
	rst 38h			;1878	ff 	. 
	rst 38h			;1879	ff 	. 
	rst 38h			;187a	ff 	. 
	rst 38h			;187b	ff 	. 
	rst 38h			;187c	ff 	. 
	rst 38h			;187d	ff 	. 
	rst 38h			;187e	ff 	. 
	rst 38h			;187f	ff 	. 
	rst 38h			;1880	ff 	. 
	rst 38h			;1881	ff 	. 
	rst 38h			;1882	ff 	. 
	rst 38h			;1883	ff 	. 
	rst 38h			;1884	ff 	. 
	rst 38h			;1885	ff 	. 
	rst 38h			;1886	ff 	. 
	rst 38h			;1887	ff 	. 
	rst 38h			;1888	ff 	. 
	rst 38h			;1889	ff 	. 
	rst 38h			;188a	ff 	. 
	rst 38h			;188b	ff 	. 
	rst 38h			;188c	ff 	. 
	rst 38h			;188d	ff 	. 
	rst 38h			;188e	ff 	. 
	rst 38h			;188f	ff 	. 
	rst 38h			;1890	ff 	. 
	rst 38h			;1891	ff 	. 
	rst 38h			;1892	ff 	. 
	rst 38h			;1893	ff 	. 
	rst 38h			;1894	ff 	. 
	rst 38h			;1895	ff 	. 
	rst 38h			;1896	ff 	. 
	rst 38h			;1897	ff 	. 
	rst 38h			;1898	ff 	. 
	rst 38h			;1899	ff 	. 
	rst 38h			;189a	ff 	. 
	rst 38h			;189b	ff 	. 
	rst 38h			;189c	ff 	. 
	rst 38h			;189d	ff 	. 
	rst 38h			;189e	ff 	. 
	rst 38h			;189f	ff 	. 
	rst 38h			;18a0	ff 	. 
	rst 38h			;18a1	ff 	. 
	rst 38h			;18a2	ff 	. 
	rst 38h			;18a3	ff 	. 
	rst 38h			;18a4	ff 	. 
	rst 38h			;18a5	ff 	. 
	rst 38h			;18a6	ff 	. 
	rst 38h			;18a7	ff 	. 
	rst 38h			;18a8	ff 	. 
	rst 38h			;18a9	ff 	. 
	rst 38h			;18aa	ff 	. 
	rst 38h			;18ab	ff 	. 
	rst 38h			;18ac	ff 	. 
	rst 38h			;18ad	ff 	. 
	rst 38h			;18ae	ff 	. 
	rst 38h			;18af	ff 	. 
	rst 38h			;18b0	ff 	. 
	rst 38h			;18b1	ff 	. 
	rst 38h			;18b2	ff 	. 
	rst 38h			;18b3	ff 	. 
	rst 38h			;18b4	ff 	. 
	rst 38h			;18b5	ff 	. 
	rst 38h			;18b6	ff 	. 
	rst 38h			;18b7	ff 	. 
	rst 38h			;18b8	ff 	. 
	rst 38h			;18b9	ff 	. 
	rst 38h			;18ba	ff 	. 
	rst 38h			;18bb	ff 	. 
	rst 38h			;18bc	ff 	. 
	rst 38h			;18bd	ff 	. 
	rst 38h			;18be	ff 	. 
	rst 38h			;18bf	ff 	. 
	rst 38h			;18c0	ff 	. 
	rst 38h			;18c1	ff 	. 
	rst 38h			;18c2	ff 	. 
	rst 38h			;18c3	ff 	. 
	rst 38h			;18c4	ff 	. 
	rst 38h			;18c5	ff 	. 
	rst 38h			;18c6	ff 	. 
	rst 38h			;18c7	ff 	. 
	rst 38h			;18c8	ff 	. 
	rst 38h			;18c9	ff 	. 
	rst 38h			;18ca	ff 	. 
	rst 38h			;18cb	ff 	. 
	rst 38h			;18cc	ff 	. 
	rst 38h			;18cd	ff 	. 
	rst 38h			;18ce	ff 	. 
	rst 38h			;18cf	ff 	. 
	rst 38h			;18d0	ff 	. 
	rst 38h			;18d1	ff 	. 
	rst 38h			;18d2	ff 	. 
	rst 38h			;18d3	ff 	. 
	rst 38h			;18d4	ff 	. 
	rst 38h			;18d5	ff 	. 
	rst 38h			;18d6	ff 	. 
	rst 38h			;18d7	ff 	. 
	rst 38h			;18d8	ff 	. 
	rst 38h			;18d9	ff 	. 
	rst 38h			;18da	ff 	. 
	rst 38h			;18db	ff 	. 
	rst 38h			;18dc	ff 	. 
	rst 38h			;18dd	ff 	. 
	rst 38h			;18de	ff 	. 
	rst 38h			;18df	ff 	. 
	rst 38h			;18e0	ff 	. 
	rst 38h			;18e1	ff 	. 
	rst 38h			;18e2	ff 	. 
	rst 38h			;18e3	ff 	. 
	rst 38h			;18e4	ff 	. 
	rst 38h			;18e5	ff 	. 
	rst 38h			;18e6	ff 	. 
	rst 38h			;18e7	ff 	. 
	rst 38h			;18e8	ff 	. 
	rst 38h			;18e9	ff 	. 
	rst 38h			;18ea	ff 	. 
	rst 38h			;18eb	ff 	. 
	rst 38h			;18ec	ff 	. 
	rst 38h			;18ed	ff 	. 
	rst 38h			;18ee	ff 	. 
	rst 38h			;18ef	ff 	. 
	rst 38h			;18f0	ff 	. 
	rst 38h			;18f1	ff 	. 
	rst 38h			;18f2	ff 	. 
	rst 38h			;18f3	ff 	. 
	rst 38h			;18f4	ff 	. 
	rst 38h			;18f5	ff 	. 
	rst 38h			;18f6	ff 	. 
	rst 38h			;18f7	ff 	. 
	rst 38h			;18f8	ff 	. 
	rst 38h			;18f9	ff 	. 
	rst 38h			;18fa	ff 	. 
	rst 38h			;18fb	ff 	. 
	rst 38h			;18fc	ff 	. 
	rst 38h			;18fd	ff 	. 
	rst 38h			;18fe	ff 	. 
	rst 38h			;18ff	ff 	. 
	rst 38h			;1900	ff 	. 
	rst 38h			;1901	ff 	. 
	rst 38h			;1902	ff 	. 
	rst 38h			;1903	ff 	. 
	rst 38h			;1904	ff 	. 
	rst 38h			;1905	ff 	. 
	rst 38h			;1906	ff 	. 
	rst 38h			;1907	ff 	. 
	rst 38h			;1908	ff 	. 
	rst 38h			;1909	ff 	. 
	rst 38h			;190a	ff 	. 
	rst 38h			;190b	ff 	. 
	rst 38h			;190c	ff 	. 
	rst 38h			;190d	ff 	. 
	rst 38h			;190e	ff 	. 
	rst 38h			;190f	ff 	. 
	rst 38h			;1910	ff 	. 
	rst 38h			;1911	ff 	. 
	rst 38h			;1912	ff 	. 
	rst 38h			;1913	ff 	. 
	rst 38h			;1914	ff 	. 
	rst 38h			;1915	ff 	. 
	rst 38h			;1916	ff 	. 
	rst 38h			;1917	ff 	. 
	rst 38h			;1918	ff 	. 
	rst 38h			;1919	ff 	. 
	rst 38h			;191a	ff 	. 
	rst 38h			;191b	ff 	. 
	rst 38h			;191c	ff 	. 
	rst 38h			;191d	ff 	. 
	rst 38h			;191e	ff 	. 
	rst 38h			;191f	ff 	. 
	rst 38h			;1920	ff 	. 
	rst 38h			;1921	ff 	. 
	rst 38h			;1922	ff 	. 
	rst 38h			;1923	ff 	. 
	rst 38h			;1924	ff 	. 
	rst 38h			;1925	ff 	. 
	rst 38h			;1926	ff 	. 
	rst 38h			;1927	ff 	. 
	rst 38h			;1928	ff 	. 
	rst 38h			;1929	ff 	. 
	rst 38h			;192a	ff 	. 
	rst 38h			;192b	ff 	. 
	rst 38h			;192c	ff 	. 
	rst 38h			;192d	ff 	. 
	rst 38h			;192e	ff 	. 
	rst 38h			;192f	ff 	. 
	rst 38h			;1930	ff 	. 
	rst 38h			;1931	ff 	. 
	rst 38h			;1932	ff 	. 
	rst 38h			;1933	ff 	. 
	rst 38h			;1934	ff 	. 
	rst 38h			;1935	ff 	. 
	rst 38h			;1936	ff 	. 
	rst 38h			;1937	ff 	. 
	rst 38h			;1938	ff 	. 
	rst 38h			;1939	ff 	. 
	rst 38h			;193a	ff 	. 
	rst 38h			;193b	ff 	. 
	rst 38h			;193c	ff 	. 
	rst 38h			;193d	ff 	. 
	rst 38h			;193e	ff 	. 
	rst 38h			;193f	ff 	. 
	rst 38h			;1940	ff 	. 
	rst 38h			;1941	ff 	. 
	rst 38h			;1942	ff 	. 
	rst 38h			;1943	ff 	. 
	rst 38h			;1944	ff 	. 
	rst 38h			;1945	ff 	. 
	rst 38h			;1946	ff 	. 
	rst 38h			;1947	ff 	. 
	rst 38h			;1948	ff 	. 
	rst 38h			;1949	ff 	. 
	rst 38h			;194a	ff 	. 
	rst 38h			;194b	ff 	. 
	rst 38h			;194c	ff 	. 
	rst 38h			;194d	ff 	. 
	rst 38h			;194e	ff 	. 
	rst 38h			;194f	ff 	. 
	rst 38h			;1950	ff 	. 
	rst 38h			;1951	ff 	. 
	rst 38h			;1952	ff 	. 
	rst 38h			;1953	ff 	. 
	rst 38h			;1954	ff 	. 
	rst 38h			;1955	ff 	. 
	rst 38h			;1956	ff 	. 
	rst 38h			;1957	ff 	. 
	rst 38h			;1958	ff 	. 
	rst 38h			;1959	ff 	. 
	rst 38h			;195a	ff 	. 
	rst 38h			;195b	ff 	. 
	rst 38h			;195c	ff 	. 
	rst 38h			;195d	ff 	. 
	rst 38h			;195e	ff 	. 
	rst 38h			;195f	ff 	. 
	rst 38h			;1960	ff 	. 
	rst 38h			;1961	ff 	. 
	rst 38h			;1962	ff 	. 
	rst 38h			;1963	ff 	. 
	rst 38h			;1964	ff 	. 
	rst 38h			;1965	ff 	. 
	rst 38h			;1966	ff 	. 
	rst 38h			;1967	ff 	. 
	rst 38h			;1968	ff 	. 
	rst 38h			;1969	ff 	. 
	rst 38h			;196a	ff 	. 
	rst 38h			;196b	ff 	. 
	rst 38h			;196c	ff 	. 
	rst 38h			;196d	ff 	. 
	rst 38h			;196e	ff 	. 
	rst 38h			;196f	ff 	. 
	rst 38h			;1970	ff 	. 
	rst 38h			;1971	ff 	. 
	rst 38h			;1972	ff 	. 
	rst 38h			;1973	ff 	. 
	rst 38h			;1974	ff 	. 
	rst 38h			;1975	ff 	. 
	rst 38h			;1976	ff 	. 
	rst 38h			;1977	ff 	. 
	rst 38h			;1978	ff 	. 
	rst 38h			;1979	ff 	. 
	rst 38h			;197a	ff 	. 
	rst 38h			;197b	ff 	. 
	rst 38h			;197c	ff 	. 
	rst 38h			;197d	ff 	. 
	rst 38h			;197e	ff 	. 
	rst 38h			;197f	ff 	. 
	rst 38h			;1980	ff 	. 
	rst 38h			;1981	ff 	. 
	rst 38h			;1982	ff 	. 
	rst 38h			;1983	ff 	. 
	rst 38h			;1984	ff 	. 
	rst 38h			;1985	ff 	. 
	rst 38h			;1986	ff 	. 
	rst 38h			;1987	ff 	. 
	rst 38h			;1988	ff 	. 
	rst 38h			;1989	ff 	. 
	rst 38h			;198a	ff 	. 
	rst 38h			;198b	ff 	. 
	rst 38h			;198c	ff 	. 
	rst 38h			;198d	ff 	. 
	rst 38h			;198e	ff 	. 
	rst 38h			;198f	ff 	. 
	rst 38h			;1990	ff 	. 
	rst 38h			;1991	ff 	. 
	rst 38h			;1992	ff 	. 
	rst 38h			;1993	ff 	. 
	rst 38h			;1994	ff 	. 
	rst 38h			;1995	ff 	. 
	rst 38h			;1996	ff 	. 
	rst 38h			;1997	ff 	. 
	rst 38h			;1998	ff 	. 
	rst 38h			;1999	ff 	. 
	rst 38h			;199a	ff 	. 
	rst 38h			;199b	ff 	. 
	rst 38h			;199c	ff 	. 
	rst 38h			;199d	ff 	. 
	rst 38h			;199e	ff 	. 
	rst 38h			;199f	ff 	. 
	rst 38h			;19a0	ff 	. 
	rst 38h			;19a1	ff 	. 
	rst 38h			;19a2	ff 	. 
	rst 38h			;19a3	ff 	. 
	rst 38h			;19a4	ff 	. 
	rst 38h			;19a5	ff 	. 
	rst 38h			;19a6	ff 	. 
	rst 38h			;19a7	ff 	. 
	rst 38h			;19a8	ff 	. 
	rst 38h			;19a9	ff 	. 
	rst 38h			;19aa	ff 	. 
	rst 38h			;19ab	ff 	. 
	rst 38h			;19ac	ff 	. 
	rst 38h			;19ad	ff 	. 
	rst 38h			;19ae	ff 	. 
	rst 38h			;19af	ff 	. 
	rst 38h			;19b0	ff 	. 
	rst 38h			;19b1	ff 	. 
	rst 38h			;19b2	ff 	. 
	rst 38h			;19b3	ff 	. 
	rst 38h			;19b4	ff 	. 
	rst 38h			;19b5	ff 	. 
	rst 38h			;19b6	ff 	. 
	rst 38h			;19b7	ff 	. 
	rst 38h			;19b8	ff 	. 
	rst 38h			;19b9	ff 	. 
	rst 38h			;19ba	ff 	. 
	rst 38h			;19bb	ff 	. 
	rst 38h			;19bc	ff 	. 
	rst 38h			;19bd	ff 	. 
	rst 38h			;19be	ff 	. 
	rst 38h			;19bf	ff 	. 
	rst 38h			;19c0	ff 	. 
	rst 38h			;19c1	ff 	. 
	rst 38h			;19c2	ff 	. 
	rst 38h			;19c3	ff 	. 
	rst 38h			;19c4	ff 	. 
	rst 38h			;19c5	ff 	. 
	rst 38h			;19c6	ff 	. 
	rst 38h			;19c7	ff 	. 
	rst 38h			;19c8	ff 	. 
	rst 38h			;19c9	ff 	. 
	rst 38h			;19ca	ff 	. 
	rst 38h			;19cb	ff 	. 
	rst 38h			;19cc	ff 	. 
	rst 38h			;19cd	ff 	. 
	rst 38h			;19ce	ff 	. 
	rst 38h			;19cf	ff 	. 
	rst 38h			;19d0	ff 	. 
	rst 38h			;19d1	ff 	. 
	rst 38h			;19d2	ff 	. 
	rst 38h			;19d3	ff 	. 
	rst 38h			;19d4	ff 	. 
	rst 38h			;19d5	ff 	. 
	rst 38h			;19d6	ff 	. 
	rst 38h			;19d7	ff 	. 
	rst 38h			;19d8	ff 	. 
	rst 38h			;19d9	ff 	. 
	rst 38h			;19da	ff 	. 
	rst 38h			;19db	ff 	. 
	rst 38h			;19dc	ff 	. 
	rst 38h			;19dd	ff 	. 
	rst 38h			;19de	ff 	. 
	rst 38h			;19df	ff 	. 
	rst 38h			;19e0	ff 	. 
	rst 38h			;19e1	ff 	. 
	rst 38h			;19e2	ff 	. 
	rst 38h			;19e3	ff 	. 
	rst 38h			;19e4	ff 	. 
	rst 38h			;19e5	ff 	. 
	rst 38h			;19e6	ff 	. 
	rst 38h			;19e7	ff 	. 
	rst 38h			;19e8	ff 	. 
	rst 38h			;19e9	ff 	. 
	rst 38h			;19ea	ff 	. 
	rst 38h			;19eb	ff 	. 
	rst 38h			;19ec	ff 	. 
	rst 38h			;19ed	ff 	. 
	rst 38h			;19ee	ff 	. 
	rst 38h			;19ef	ff 	. 
	rst 38h			;19f0	ff 	. 
	rst 38h			;19f1	ff 	. 
	rst 38h			;19f2	ff 	. 
	rst 38h			;19f3	ff 	. 
	rst 38h			;19f4	ff 	. 
	rst 38h			;19f5	ff 	. 
	rst 38h			;19f6	ff 	. 
	rst 38h			;19f7	ff 	. 
	rst 38h			;19f8	ff 	. 
	rst 38h			;19f9	ff 	. 
	rst 38h			;19fa	ff 	. 
	rst 38h			;19fb	ff 	. 
	rst 38h			;19fc	ff 	. 
	rst 38h			;19fd	ff 	. 
	rst 38h			;19fe	ff 	. 
	rst 38h			;19ff	ff 	. 
	rst 38h			;1a00	ff 	. 
	rst 38h			;1a01	ff 	. 
	rst 38h			;1a02	ff 	. 
	rst 38h			;1a03	ff 	. 
	rst 38h			;1a04	ff 	. 
	rst 38h			;1a05	ff 	. 
	rst 38h			;1a06	ff 	. 
	rst 38h			;1a07	ff 	. 
	rst 38h			;1a08	ff 	. 
	rst 38h			;1a09	ff 	. 
	rst 38h			;1a0a	ff 	. 
	rst 38h			;1a0b	ff 	. 
	rst 38h			;1a0c	ff 	. 
	rst 38h			;1a0d	ff 	. 
	rst 38h			;1a0e	ff 	. 
	rst 38h			;1a0f	ff 	. 
	rst 38h			;1a10	ff 	. 
	rst 38h			;1a11	ff 	. 
	rst 38h			;1a12	ff 	. 
	rst 38h			;1a13	ff 	. 
	rst 38h			;1a14	ff 	. 
	rst 38h			;1a15	ff 	. 
	rst 38h			;1a16	ff 	. 
	rst 38h			;1a17	ff 	. 
	rst 38h			;1a18	ff 	. 
	rst 38h			;1a19	ff 	. 
	rst 38h			;1a1a	ff 	. 
	rst 38h			;1a1b	ff 	. 
	rst 38h			;1a1c	ff 	. 
	rst 38h			;1a1d	ff 	. 
	rst 38h			;1a1e	ff 	. 
	rst 38h			;1a1f	ff 	. 
	rst 38h			;1a20	ff 	. 
	rst 38h			;1a21	ff 	. 
	rst 38h			;1a22	ff 	. 
	rst 38h			;1a23	ff 	. 
	rst 38h			;1a24	ff 	. 
	rst 38h			;1a25	ff 	. 
	rst 38h			;1a26	ff 	. 
	rst 38h			;1a27	ff 	. 
	rst 38h			;1a28	ff 	. 
	rst 38h			;1a29	ff 	. 
	rst 38h			;1a2a	ff 	. 
	rst 38h			;1a2b	ff 	. 
	rst 38h			;1a2c	ff 	. 
	rst 38h			;1a2d	ff 	. 
	rst 38h			;1a2e	ff 	. 
	rst 38h			;1a2f	ff 	. 
	rst 38h			;1a30	ff 	. 
	rst 38h			;1a31	ff 	. 
	rst 38h			;1a32	ff 	. 
	rst 38h			;1a33	ff 	. 
	rst 38h			;1a34	ff 	. 
	rst 38h			;1a35	ff 	. 
	rst 38h			;1a36	ff 	. 
	rst 38h			;1a37	ff 	. 
	rst 38h			;1a38	ff 	. 
	rst 38h			;1a39	ff 	. 
	rst 38h			;1a3a	ff 	. 
	rst 38h			;1a3b	ff 	. 
	rst 38h			;1a3c	ff 	. 
	rst 38h			;1a3d	ff 	. 
	rst 38h			;1a3e	ff 	. 
	rst 38h			;1a3f	ff 	. 
	rst 38h			;1a40	ff 	. 
	rst 38h			;1a41	ff 	. 
	rst 38h			;1a42	ff 	. 
	rst 38h			;1a43	ff 	. 
	rst 38h			;1a44	ff 	. 
	rst 38h			;1a45	ff 	. 
	rst 38h			;1a46	ff 	. 
	rst 38h			;1a47	ff 	. 
	rst 38h			;1a48	ff 	. 
	rst 38h			;1a49	ff 	. 
	rst 38h			;1a4a	ff 	. 
	rst 38h			;1a4b	ff 	. 
	rst 38h			;1a4c	ff 	. 
	rst 38h			;1a4d	ff 	. 
	rst 38h			;1a4e	ff 	. 
	rst 38h			;1a4f	ff 	. 
	rst 38h			;1a50	ff 	. 
	rst 38h			;1a51	ff 	. 
	rst 38h			;1a52	ff 	. 
	rst 38h			;1a53	ff 	. 
	rst 38h			;1a54	ff 	. 
	rst 38h			;1a55	ff 	. 
	rst 38h			;1a56	ff 	. 
	rst 38h			;1a57	ff 	. 
	rst 38h			;1a58	ff 	. 
	rst 38h			;1a59	ff 	. 
	rst 38h			;1a5a	ff 	. 
	rst 38h			;1a5b	ff 	. 
	rst 38h			;1a5c	ff 	. 
	rst 38h			;1a5d	ff 	. 
	rst 38h			;1a5e	ff 	. 
	rst 38h			;1a5f	ff 	. 
	rst 38h			;1a60	ff 	. 
	rst 38h			;1a61	ff 	. 
	rst 38h			;1a62	ff 	. 
	rst 38h			;1a63	ff 	. 
	rst 38h			;1a64	ff 	. 
	rst 38h			;1a65	ff 	. 
	rst 38h			;1a66	ff 	. 
	rst 38h			;1a67	ff 	. 
	rst 38h			;1a68	ff 	. 
	rst 38h			;1a69	ff 	. 
	rst 38h			;1a6a	ff 	. 
	rst 38h			;1a6b	ff 	. 
	rst 38h			;1a6c	ff 	. 
	rst 38h			;1a6d	ff 	. 
	rst 38h			;1a6e	ff 	. 
	rst 38h			;1a6f	ff 	. 
	rst 38h			;1a70	ff 	. 
	rst 38h			;1a71	ff 	. 
	rst 38h			;1a72	ff 	. 
	rst 38h			;1a73	ff 	. 
	rst 38h			;1a74	ff 	. 
	rst 38h			;1a75	ff 	. 
	rst 38h			;1a76	ff 	. 
	rst 38h			;1a77	ff 	. 
	rst 38h			;1a78	ff 	. 
	rst 38h			;1a79	ff 	. 
	rst 38h			;1a7a	ff 	. 
	rst 38h			;1a7b	ff 	. 
	rst 38h			;1a7c	ff 	. 
	rst 38h			;1a7d	ff 	. 
	rst 38h			;1a7e	ff 	. 
	rst 38h			;1a7f	ff 	. 
	rst 38h			;1a80	ff 	. 
	rst 38h			;1a81	ff 	. 
	rst 38h			;1a82	ff 	. 
	rst 38h			;1a83	ff 	. 
	rst 38h			;1a84	ff 	. 
	rst 38h			;1a85	ff 	. 
	rst 38h			;1a86	ff 	. 
	rst 38h			;1a87	ff 	. 
	rst 38h			;1a88	ff 	. 
	rst 38h			;1a89	ff 	. 
	rst 38h			;1a8a	ff 	. 
	rst 38h			;1a8b	ff 	. 
	rst 38h			;1a8c	ff 	. 
	rst 38h			;1a8d	ff 	. 
	rst 38h			;1a8e	ff 	. 
	rst 38h			;1a8f	ff 	. 
	rst 38h			;1a90	ff 	. 
	rst 38h			;1a91	ff 	. 
	rst 38h			;1a92	ff 	. 
	rst 38h			;1a93	ff 	. 
	rst 38h			;1a94	ff 	. 
	rst 38h			;1a95	ff 	. 
	rst 38h			;1a96	ff 	. 
	rst 38h			;1a97	ff 	. 
	rst 38h			;1a98	ff 	. 
	rst 38h			;1a99	ff 	. 
	rst 38h			;1a9a	ff 	. 
	rst 38h			;1a9b	ff 	. 
	rst 38h			;1a9c	ff 	. 
	rst 38h			;1a9d	ff 	. 
	rst 38h			;1a9e	ff 	. 
	rst 38h			;1a9f	ff 	. 
	rst 38h			;1aa0	ff 	. 
	rst 38h			;1aa1	ff 	. 
	rst 38h			;1aa2	ff 	. 
	rst 38h			;1aa3	ff 	. 
	rst 38h			;1aa4	ff 	. 
	rst 38h			;1aa5	ff 	. 
	rst 38h			;1aa6	ff 	. 
	rst 38h			;1aa7	ff 	. 
	rst 38h			;1aa8	ff 	. 
	rst 38h			;1aa9	ff 	. 
	rst 38h			;1aaa	ff 	. 
	rst 38h			;1aab	ff 	. 
	rst 38h			;1aac	ff 	. 
	rst 38h			;1aad	ff 	. 
	rst 38h			;1aae	ff 	. 
	rst 38h			;1aaf	ff 	. 
	rst 38h			;1ab0	ff 	. 
	rst 38h			;1ab1	ff 	. 
	rst 38h			;1ab2	ff 	. 
	rst 38h			;1ab3	ff 	. 
	rst 38h			;1ab4	ff 	. 
	rst 38h			;1ab5	ff 	. 
	rst 38h			;1ab6	ff 	. 
	rst 38h			;1ab7	ff 	. 
	rst 38h			;1ab8	ff 	. 
	rst 38h			;1ab9	ff 	. 
	rst 38h			;1aba	ff 	. 
	rst 38h			;1abb	ff 	. 
	rst 38h			;1abc	ff 	. 
	rst 38h			;1abd	ff 	. 
	rst 38h			;1abe	ff 	. 
	rst 38h			;1abf	ff 	. 
	rst 38h			;1ac0	ff 	. 
	rst 38h			;1ac1	ff 	. 
	rst 38h			;1ac2	ff 	. 
	rst 38h			;1ac3	ff 	. 
	rst 38h			;1ac4	ff 	. 
	rst 38h			;1ac5	ff 	. 
	rst 38h			;1ac6	ff 	. 
	rst 38h			;1ac7	ff 	. 
	rst 38h			;1ac8	ff 	. 
	rst 38h			;1ac9	ff 	. 
	rst 38h			;1aca	ff 	. 
	rst 38h			;1acb	ff 	. 
	rst 38h			;1acc	ff 	. 
	rst 38h			;1acd	ff 	. 
	rst 38h			;1ace	ff 	. 
	rst 38h			;1acf	ff 	. 
	rst 38h			;1ad0	ff 	. 
	rst 38h			;1ad1	ff 	. 
	rst 38h			;1ad2	ff 	. 
	rst 38h			;1ad3	ff 	. 
	rst 38h			;1ad4	ff 	. 
	rst 38h			;1ad5	ff 	. 
	rst 38h			;1ad6	ff 	. 
	rst 38h			;1ad7	ff 	. 
	rst 38h			;1ad8	ff 	. 
	rst 38h			;1ad9	ff 	. 
	rst 38h			;1ada	ff 	. 
	rst 38h			;1adb	ff 	. 
	rst 38h			;1adc	ff 	. 
	rst 38h			;1add	ff 	. 
	rst 38h			;1ade	ff 	. 
	rst 38h			;1adf	ff 	. 
	rst 38h			;1ae0	ff 	. 
	rst 38h			;1ae1	ff 	. 
	rst 38h			;1ae2	ff 	. 
	rst 38h			;1ae3	ff 	. 
	rst 38h			;1ae4	ff 	. 
	rst 38h			;1ae5	ff 	. 
	rst 38h			;1ae6	ff 	. 
	rst 38h			;1ae7	ff 	. 
	rst 38h			;1ae8	ff 	. 
	rst 38h			;1ae9	ff 	. 
	rst 38h			;1aea	ff 	. 
	rst 38h			;1aeb	ff 	. 
	rst 38h			;1aec	ff 	. 
	rst 38h			;1aed	ff 	. 
	rst 38h			;1aee	ff 	. 
	rst 38h			;1aef	ff 	. 
	rst 38h			;1af0	ff 	. 
	rst 38h			;1af1	ff 	. 
	rst 38h			;1af2	ff 	. 
	rst 38h			;1af3	ff 	. 
	rst 38h			;1af4	ff 	. 
	rst 38h			;1af5	ff 	. 
	rst 38h			;1af6	ff 	. 
	rst 38h			;1af7	ff 	. 
	rst 38h			;1af8	ff 	. 
	rst 38h			;1af9	ff 	. 
	rst 38h			;1afa	ff 	. 
	rst 38h			;1afb	ff 	. 
	rst 38h			;1afc	ff 	. 
	rst 38h			;1afd	ff 	. 
	rst 38h			;1afe	ff 	. 
	rst 38h			;1aff	ff 	. 
	rst 38h			;1b00	ff 	. 
	rst 38h			;1b01	ff 	. 
	rst 38h			;1b02	ff 	. 
	rst 38h			;1b03	ff 	. 
	rst 38h			;1b04	ff 	. 
	rst 38h			;1b05	ff 	. 
	rst 38h			;1b06	ff 	. 
	rst 38h			;1b07	ff 	. 
	rst 38h			;1b08	ff 	. 
	rst 38h			;1b09	ff 	. 
	rst 38h			;1b0a	ff 	. 
	rst 38h			;1b0b	ff 	. 
	rst 38h			;1b0c	ff 	. 
	rst 38h			;1b0d	ff 	. 
	rst 38h			;1b0e	ff 	. 
	rst 38h			;1b0f	ff 	. 
	rst 38h			;1b10	ff 	. 
	rst 38h			;1b11	ff 	. 
	rst 38h			;1b12	ff 	. 
	rst 38h			;1b13	ff 	. 
	rst 38h			;1b14	ff 	. 
	rst 38h			;1b15	ff 	. 
	rst 38h			;1b16	ff 	. 
	rst 38h			;1b17	ff 	. 
	rst 38h			;1b18	ff 	. 
	rst 38h			;1b19	ff 	. 
	rst 38h			;1b1a	ff 	. 
	rst 38h			;1b1b	ff 	. 
	rst 38h			;1b1c	ff 	. 
	rst 38h			;1b1d	ff 	. 
	rst 38h			;1b1e	ff 	. 
	rst 38h			;1b1f	ff 	. 
	rst 38h			;1b20	ff 	. 
	rst 38h			;1b21	ff 	. 
	rst 38h			;1b22	ff 	. 
	rst 38h			;1b23	ff 	. 
	rst 38h			;1b24	ff 	. 
	rst 38h			;1b25	ff 	. 
	rst 38h			;1b26	ff 	. 
	rst 38h			;1b27	ff 	. 
	rst 38h			;1b28	ff 	. 
	rst 38h			;1b29	ff 	. 
	rst 38h			;1b2a	ff 	. 
	rst 38h			;1b2b	ff 	. 
	rst 38h			;1b2c	ff 	. 
	rst 38h			;1b2d	ff 	. 
	rst 38h			;1b2e	ff 	. 
	rst 38h			;1b2f	ff 	. 
	rst 38h			;1b30	ff 	. 
	rst 38h			;1b31	ff 	. 
	rst 38h			;1b32	ff 	. 
	rst 38h			;1b33	ff 	. 
	rst 38h			;1b34	ff 	. 
	rst 38h			;1b35	ff 	. 
	rst 38h			;1b36	ff 	. 
	rst 38h			;1b37	ff 	. 
	rst 38h			;1b38	ff 	. 
	rst 38h			;1b39	ff 	. 
	rst 38h			;1b3a	ff 	. 
	rst 38h			;1b3b	ff 	. 
	rst 38h			;1b3c	ff 	. 
	rst 38h			;1b3d	ff 	. 
	rst 38h			;1b3e	ff 	. 
	rst 38h			;1b3f	ff 	. 
	rst 38h			;1b40	ff 	. 
	rst 38h			;1b41	ff 	. 
	rst 38h			;1b42	ff 	. 
	rst 38h			;1b43	ff 	. 
	rst 38h			;1b44	ff 	. 
	rst 38h			;1b45	ff 	. 
	rst 38h			;1b46	ff 	. 
	rst 38h			;1b47	ff 	. 
	rst 38h			;1b48	ff 	. 
	rst 38h			;1b49	ff 	. 
	rst 38h			;1b4a	ff 	. 
	rst 38h			;1b4b	ff 	. 
	rst 38h			;1b4c	ff 	. 
	rst 38h			;1b4d	ff 	. 
	rst 38h			;1b4e	ff 	. 
	rst 38h			;1b4f	ff 	. 
	rst 38h			;1b50	ff 	. 
	rst 38h			;1b51	ff 	. 
	rst 38h			;1b52	ff 	. 
	rst 38h			;1b53	ff 	. 
	rst 38h			;1b54	ff 	. 
	rst 38h			;1b55	ff 	. 
	rst 38h			;1b56	ff 	. 
	rst 38h			;1b57	ff 	. 
	rst 38h			;1b58	ff 	. 
	rst 38h			;1b59	ff 	. 
	rst 38h			;1b5a	ff 	. 
	rst 38h			;1b5b	ff 	. 
	rst 38h			;1b5c	ff 	. 
	rst 38h			;1b5d	ff 	. 
	rst 38h			;1b5e	ff 	. 
	rst 38h			;1b5f	ff 	. 
	rst 38h			;1b60	ff 	. 
	rst 38h			;1b61	ff 	. 
	rst 38h			;1b62	ff 	. 
	rst 38h			;1b63	ff 	. 
	rst 38h			;1b64	ff 	. 
	rst 38h			;1b65	ff 	. 
	rst 38h			;1b66	ff 	. 
	rst 38h			;1b67	ff 	. 
	rst 38h			;1b68	ff 	. 
	rst 38h			;1b69	ff 	. 
	rst 38h			;1b6a	ff 	. 
	rst 38h			;1b6b	ff 	. 
	rst 38h			;1b6c	ff 	. 
	rst 38h			;1b6d	ff 	. 
	rst 38h			;1b6e	ff 	. 
	rst 38h			;1b6f	ff 	. 
	rst 38h			;1b70	ff 	. 
	rst 38h			;1b71	ff 	. 
	rst 38h			;1b72	ff 	. 
	rst 38h			;1b73	ff 	. 
	rst 38h			;1b74	ff 	. 
	rst 38h			;1b75	ff 	. 
	rst 38h			;1b76	ff 	. 
	rst 38h			;1b77	ff 	. 
	rst 38h			;1b78	ff 	. 
	rst 38h			;1b79	ff 	. 
	rst 38h			;1b7a	ff 	. 
	rst 38h			;1b7b	ff 	. 
	rst 38h			;1b7c	ff 	. 
	rst 38h			;1b7d	ff 	. 
	rst 38h			;1b7e	ff 	. 
	rst 38h			;1b7f	ff 	. 
	rst 38h			;1b80	ff 	. 
	rst 38h			;1b81	ff 	. 
	rst 38h			;1b82	ff 	. 
	rst 38h			;1b83	ff 	. 
	rst 38h			;1b84	ff 	. 
	rst 38h			;1b85	ff 	. 
	rst 38h			;1b86	ff 	. 
	rst 38h			;1b87	ff 	. 
	rst 38h			;1b88	ff 	. 
	rst 38h			;1b89	ff 	. 
	rst 38h			;1b8a	ff 	. 
	rst 38h			;1b8b	ff 	. 
	rst 38h			;1b8c	ff 	. 
	rst 38h			;1b8d	ff 	. 
	rst 38h			;1b8e	ff 	. 
	rst 38h			;1b8f	ff 	. 
	rst 38h			;1b90	ff 	. 
	rst 38h			;1b91	ff 	. 
	rst 38h			;1b92	ff 	. 
	rst 38h			;1b93	ff 	. 
	rst 38h			;1b94	ff 	. 
	rst 38h			;1b95	ff 	. 
	rst 38h			;1b96	ff 	. 
	rst 38h			;1b97	ff 	. 
	rst 38h			;1b98	ff 	. 
	rst 38h			;1b99	ff 	. 
	rst 38h			;1b9a	ff 	. 
	rst 38h			;1b9b	ff 	. 
	rst 38h			;1b9c	ff 	. 
	rst 38h			;1b9d	ff 	. 
	rst 38h			;1b9e	ff 	. 
	rst 38h			;1b9f	ff 	. 
	rst 38h			;1ba0	ff 	. 
	rst 38h			;1ba1	ff 	. 
	rst 38h			;1ba2	ff 	. 
	rst 38h			;1ba3	ff 	. 
	rst 38h			;1ba4	ff 	. 
	rst 38h			;1ba5	ff 	. 
	rst 38h			;1ba6	ff 	. 
	rst 38h			;1ba7	ff 	. 
	rst 38h			;1ba8	ff 	. 
	rst 38h			;1ba9	ff 	. 
	rst 38h			;1baa	ff 	. 
	rst 38h			;1bab	ff 	. 
	rst 38h			;1bac	ff 	. 
	rst 38h			;1bad	ff 	. 
	rst 38h			;1bae	ff 	. 
	rst 38h			;1baf	ff 	. 
	rst 38h			;1bb0	ff 	. 
	rst 38h			;1bb1	ff 	. 
	rst 38h			;1bb2	ff 	. 
	rst 38h			;1bb3	ff 	. 
	rst 38h			;1bb4	ff 	. 
	rst 38h			;1bb5	ff 	. 
	rst 38h			;1bb6	ff 	. 
	rst 38h			;1bb7	ff 	. 
	rst 38h			;1bb8	ff 	. 
	rst 38h			;1bb9	ff 	. 
	rst 38h			;1bba	ff 	. 
	rst 38h			;1bbb	ff 	. 
	rst 38h			;1bbc	ff 	. 
	rst 38h			;1bbd	ff 	. 
	rst 38h			;1bbe	ff 	. 
	rst 38h			;1bbf	ff 	. 
	rst 38h			;1bc0	ff 	. 
	rst 38h			;1bc1	ff 	. 
	rst 38h			;1bc2	ff 	. 
	rst 38h			;1bc3	ff 	. 
	rst 38h			;1bc4	ff 	. 
	rst 38h			;1bc5	ff 	. 
	rst 38h			;1bc6	ff 	. 
	rst 38h			;1bc7	ff 	. 
	rst 38h			;1bc8	ff 	. 
	rst 38h			;1bc9	ff 	. 
	rst 38h			;1bca	ff 	. 
	rst 38h			;1bcb	ff 	. 
	rst 38h			;1bcc	ff 	. 
	rst 38h			;1bcd	ff 	. 
	rst 38h			;1bce	ff 	. 
	rst 38h			;1bcf	ff 	. 
	rst 38h			;1bd0	ff 	. 
	rst 38h			;1bd1	ff 	. 
	rst 38h			;1bd2	ff 	. 
	rst 38h			;1bd3	ff 	. 
	rst 38h			;1bd4	ff 	. 
	rst 38h			;1bd5	ff 	. 
	rst 38h			;1bd6	ff 	. 
	rst 38h			;1bd7	ff 	. 
	rst 38h			;1bd8	ff 	. 
	rst 38h			;1bd9	ff 	. 
	rst 38h			;1bda	ff 	. 
	rst 38h			;1bdb	ff 	. 
	rst 38h			;1bdc	ff 	. 
	rst 38h			;1bdd	ff 	. 
	rst 38h			;1bde	ff 	. 
	rst 38h			;1bdf	ff 	. 
	rst 38h			;1be0	ff 	. 
	rst 38h			;1be1	ff 	. 
	rst 38h			;1be2	ff 	. 
	rst 38h			;1be3	ff 	. 
	rst 38h			;1be4	ff 	. 
	rst 38h			;1be5	ff 	. 
	rst 38h			;1be6	ff 	. 
	rst 38h			;1be7	ff 	. 
	rst 38h			;1be8	ff 	. 
	rst 38h			;1be9	ff 	. 
	rst 38h			;1bea	ff 	. 
	rst 38h			;1beb	ff 	. 
	rst 38h			;1bec	ff 	. 
	rst 38h			;1bed	ff 	. 
	rst 38h			;1bee	ff 	. 
	rst 38h			;1bef	ff 	. 
	rst 38h			;1bf0	ff 	. 
	rst 38h			;1bf1	ff 	. 
	rst 38h			;1bf2	ff 	. 
	rst 38h			;1bf3	ff 	. 
	rst 38h			;1bf4	ff 	. 
	rst 38h			;1bf5	ff 	. 
	rst 38h			;1bf6	ff 	. 
	rst 38h			;1bf7	ff 	. 
	rst 38h			;1bf8	ff 	. 
	rst 38h			;1bf9	ff 	. 
	rst 38h			;1bfa	ff 	. 
	rst 38h			;1bfb	ff 	. 
	rst 38h			;1bfc	ff 	. 
	rst 38h			;1bfd	ff 	. 
	rst 38h			;1bfe	ff 	. 
	rst 38h			;1bff	ff 	. 
	rst 38h			;1c00	ff 	. 
	rst 38h			;1c01	ff 	. 
	rst 38h			;1c02	ff 	. 
	rst 38h			;1c03	ff 	. 
	rst 38h			;1c04	ff 	. 
	rst 38h			;1c05	ff 	. 
	rst 38h			;1c06	ff 	. 
	rst 38h			;1c07	ff 	. 
	rst 38h			;1c08	ff 	. 
	rst 38h			;1c09	ff 	. 
	rst 38h			;1c0a	ff 	. 
	rst 38h			;1c0b	ff 	. 
	rst 38h			;1c0c	ff 	. 
	rst 38h			;1c0d	ff 	. 
	rst 38h			;1c0e	ff 	. 
	rst 38h			;1c0f	ff 	. 
	rst 38h			;1c10	ff 	. 
	rst 38h			;1c11	ff 	. 
	rst 38h			;1c12	ff 	. 
	rst 38h			;1c13	ff 	. 
	rst 38h			;1c14	ff 	. 
	rst 38h			;1c15	ff 	. 
	rst 38h			;1c16	ff 	. 
	rst 38h			;1c17	ff 	. 
	rst 38h			;1c18	ff 	. 
	rst 38h			;1c19	ff 	. 
	rst 38h			;1c1a	ff 	. 
	rst 38h			;1c1b	ff 	. 
	rst 38h			;1c1c	ff 	. 
	rst 38h			;1c1d	ff 	. 
	rst 38h			;1c1e	ff 	. 
	rst 38h			;1c1f	ff 	. 
	rst 38h			;1c20	ff 	. 
	rst 38h			;1c21	ff 	. 
	rst 38h			;1c22	ff 	. 
	rst 38h			;1c23	ff 	. 
	rst 38h			;1c24	ff 	. 
	rst 38h			;1c25	ff 	. 
	rst 38h			;1c26	ff 	. 
	rst 38h			;1c27	ff 	. 
	rst 38h			;1c28	ff 	. 
	rst 38h			;1c29	ff 	. 
	rst 38h			;1c2a	ff 	. 
	rst 38h			;1c2b	ff 	. 
	rst 38h			;1c2c	ff 	. 
	rst 38h			;1c2d	ff 	. 
	rst 38h			;1c2e	ff 	. 
	rst 38h			;1c2f	ff 	. 
	rst 38h			;1c30	ff 	. 
	rst 38h			;1c31	ff 	. 
	rst 38h			;1c32	ff 	. 
	rst 38h			;1c33	ff 	. 
	rst 38h			;1c34	ff 	. 
	rst 38h			;1c35	ff 	. 
	rst 38h			;1c36	ff 	. 
	rst 38h			;1c37	ff 	. 
	rst 38h			;1c38	ff 	. 
	rst 38h			;1c39	ff 	. 
	rst 38h			;1c3a	ff 	. 
	rst 38h			;1c3b	ff 	. 
	rst 38h			;1c3c	ff 	. 
	rst 38h			;1c3d	ff 	. 
	rst 38h			;1c3e	ff 	. 
	rst 38h			;1c3f	ff 	. 
	rst 38h			;1c40	ff 	. 
	rst 38h			;1c41	ff 	. 
	rst 38h			;1c42	ff 	. 
	rst 38h			;1c43	ff 	. 
	rst 38h			;1c44	ff 	. 
	rst 38h			;1c45	ff 	. 
	rst 38h			;1c46	ff 	. 
	rst 38h			;1c47	ff 	. 
	rst 38h			;1c48	ff 	. 
	rst 38h			;1c49	ff 	. 
	rst 38h			;1c4a	ff 	. 
	rst 38h			;1c4b	ff 	. 
	rst 38h			;1c4c	ff 	. 
	rst 38h			;1c4d	ff 	. 
	rst 38h			;1c4e	ff 	. 
	rst 38h			;1c4f	ff 	. 
	rst 38h			;1c50	ff 	. 
	rst 38h			;1c51	ff 	. 
	rst 38h			;1c52	ff 	. 
	rst 38h			;1c53	ff 	. 
	rst 38h			;1c54	ff 	. 
	rst 38h			;1c55	ff 	. 
	rst 38h			;1c56	ff 	. 
	rst 38h			;1c57	ff 	. 
	rst 38h			;1c58	ff 	. 
	rst 38h			;1c59	ff 	. 
	rst 38h			;1c5a	ff 	. 
	rst 38h			;1c5b	ff 	. 
	rst 38h			;1c5c	ff 	. 
	rst 38h			;1c5d	ff 	. 
	rst 38h			;1c5e	ff 	. 
	rst 38h			;1c5f	ff 	. 
	rst 38h			;1c60	ff 	. 
	rst 38h			;1c61	ff 	. 
	rst 38h			;1c62	ff 	. 
	rst 38h			;1c63	ff 	. 
	rst 38h			;1c64	ff 	. 
	rst 38h			;1c65	ff 	. 
	rst 38h			;1c66	ff 	. 
	rst 38h			;1c67	ff 	. 
	rst 38h			;1c68	ff 	. 
	rst 38h			;1c69	ff 	. 
	rst 38h			;1c6a	ff 	. 
	rst 38h			;1c6b	ff 	. 
	rst 38h			;1c6c	ff 	. 
	rst 38h			;1c6d	ff 	. 
	rst 38h			;1c6e	ff 	. 
	rst 38h			;1c6f	ff 	. 
	rst 38h			;1c70	ff 	. 
	rst 38h			;1c71	ff 	. 
	rst 38h			;1c72	ff 	. 
	rst 38h			;1c73	ff 	. 
	rst 38h			;1c74	ff 	. 
	rst 38h			;1c75	ff 	. 
	rst 38h			;1c76	ff 	. 
	rst 38h			;1c77	ff 	. 
	rst 38h			;1c78	ff 	. 
	rst 38h			;1c79	ff 	. 
	rst 38h			;1c7a	ff 	. 
	rst 38h			;1c7b	ff 	. 
	rst 38h			;1c7c	ff 	. 
	rst 38h			;1c7d	ff 	. 
	rst 38h			;1c7e	ff 	. 
	rst 38h			;1c7f	ff 	. 
	rst 38h			;1c80	ff 	. 
	rst 38h			;1c81	ff 	. 
	rst 38h			;1c82	ff 	. 
	rst 38h			;1c83	ff 	. 
	rst 38h			;1c84	ff 	. 
	rst 38h			;1c85	ff 	. 
	rst 38h			;1c86	ff 	. 
	rst 38h			;1c87	ff 	. 
	rst 38h			;1c88	ff 	. 
	rst 38h			;1c89	ff 	. 
	rst 38h			;1c8a	ff 	. 
	rst 38h			;1c8b	ff 	. 
	rst 38h			;1c8c	ff 	. 
	rst 38h			;1c8d	ff 	. 
	rst 38h			;1c8e	ff 	. 
	rst 38h			;1c8f	ff 	. 
	rst 38h			;1c90	ff 	. 
	rst 38h			;1c91	ff 	. 
	rst 38h			;1c92	ff 	. 
	rst 38h			;1c93	ff 	. 
	rst 38h			;1c94	ff 	. 
	rst 38h			;1c95	ff 	. 
	rst 38h			;1c96	ff 	. 
	rst 38h			;1c97	ff 	. 
	rst 38h			;1c98	ff 	. 
	rst 38h			;1c99	ff 	. 
	rst 38h			;1c9a	ff 	. 
	rst 38h			;1c9b	ff 	. 
	rst 38h			;1c9c	ff 	. 
	rst 38h			;1c9d	ff 	. 
	rst 38h			;1c9e	ff 	. 
	rst 38h			;1c9f	ff 	. 
	rst 38h			;1ca0	ff 	. 
	rst 38h			;1ca1	ff 	. 
	rst 38h			;1ca2	ff 	. 
	rst 38h			;1ca3	ff 	. 
	rst 38h			;1ca4	ff 	. 
	rst 38h			;1ca5	ff 	. 
	rst 38h			;1ca6	ff 	. 
	rst 38h			;1ca7	ff 	. 
	rst 38h			;1ca8	ff 	. 
	rst 38h			;1ca9	ff 	. 
	rst 38h			;1caa	ff 	. 
	rst 38h			;1cab	ff 	. 
	rst 38h			;1cac	ff 	. 
	rst 38h			;1cad	ff 	. 
	rst 38h			;1cae	ff 	. 
	rst 38h			;1caf	ff 	. 
	rst 38h			;1cb0	ff 	. 
	rst 38h			;1cb1	ff 	. 
	rst 38h			;1cb2	ff 	. 
	rst 38h			;1cb3	ff 	. 
	rst 38h			;1cb4	ff 	. 
	rst 38h			;1cb5	ff 	. 
	rst 38h			;1cb6	ff 	. 
	rst 38h			;1cb7	ff 	. 
	rst 38h			;1cb8	ff 	. 
	rst 38h			;1cb9	ff 	. 
	rst 38h			;1cba	ff 	. 
	rst 38h			;1cbb	ff 	. 
	rst 38h			;1cbc	ff 	. 
	rst 38h			;1cbd	ff 	. 
	rst 38h			;1cbe	ff 	. 
	rst 38h			;1cbf	ff 	. 
	rst 38h			;1cc0	ff 	. 
	rst 38h			;1cc1	ff 	. 
	rst 38h			;1cc2	ff 	. 
	rst 38h			;1cc3	ff 	. 
	rst 38h			;1cc4	ff 	. 
	rst 38h			;1cc5	ff 	. 
	rst 38h			;1cc6	ff 	. 
	rst 38h			;1cc7	ff 	. 
	rst 38h			;1cc8	ff 	. 
	rst 38h			;1cc9	ff 	. 
	rst 38h			;1cca	ff 	. 
	rst 38h			;1ccb	ff 	. 
	rst 38h			;1ccc	ff 	. 
	rst 38h			;1ccd	ff 	. 
	rst 38h			;1cce	ff 	. 
	rst 38h			;1ccf	ff 	. 
	rst 38h			;1cd0	ff 	. 
	rst 38h			;1cd1	ff 	. 
	rst 38h			;1cd2	ff 	. 
	rst 38h			;1cd3	ff 	. 
	rst 38h			;1cd4	ff 	. 
	rst 38h			;1cd5	ff 	. 
	rst 38h			;1cd6	ff 	. 
	rst 38h			;1cd7	ff 	. 
	rst 38h			;1cd8	ff 	. 
	rst 38h			;1cd9	ff 	. 
	rst 38h			;1cda	ff 	. 
	rst 38h			;1cdb	ff 	. 
	rst 38h			;1cdc	ff 	. 
	rst 38h			;1cdd	ff 	. 
	rst 38h			;1cde	ff 	. 
	rst 38h			;1cdf	ff 	. 
	rst 38h			;1ce0	ff 	. 
	rst 38h			;1ce1	ff 	. 
	rst 38h			;1ce2	ff 	. 
	rst 38h			;1ce3	ff 	. 
	rst 38h			;1ce4	ff 	. 
	rst 38h			;1ce5	ff 	. 
	rst 38h			;1ce6	ff 	. 
	rst 38h			;1ce7	ff 	. 
	rst 38h			;1ce8	ff 	. 
	rst 38h			;1ce9	ff 	. 
	rst 38h			;1cea	ff 	. 
	rst 38h			;1ceb	ff 	. 
	rst 38h			;1cec	ff 	. 
	rst 38h			;1ced	ff 	. 
	rst 38h			;1cee	ff 	. 
	rst 38h			;1cef	ff 	. 
	rst 38h			;1cf0	ff 	. 
	rst 38h			;1cf1	ff 	. 
	rst 38h			;1cf2	ff 	. 
	rst 38h			;1cf3	ff 	. 
	rst 38h			;1cf4	ff 	. 
	rst 38h			;1cf5	ff 	. 
	rst 38h			;1cf6	ff 	. 
	rst 38h			;1cf7	ff 	. 
	rst 38h			;1cf8	ff 	. 
	rst 38h			;1cf9	ff 	. 
	rst 38h			;1cfa	ff 	. 
	rst 38h			;1cfb	ff 	. 
	rst 38h			;1cfc	ff 	. 
	rst 38h			;1cfd	ff 	. 
	rst 38h			;1cfe	ff 	. 
	rst 38h			;1cff	ff 	. 
	rst 38h			;1d00	ff 	. 
	rst 38h			;1d01	ff 	. 
	rst 38h			;1d02	ff 	. 
	rst 38h			;1d03	ff 	. 
	rst 38h			;1d04	ff 	. 
	rst 38h			;1d05	ff 	. 
	rst 38h			;1d06	ff 	. 
	rst 38h			;1d07	ff 	. 
	rst 38h			;1d08	ff 	. 
	rst 38h			;1d09	ff 	. 
	rst 38h			;1d0a	ff 	. 
	rst 38h			;1d0b	ff 	. 
	rst 38h			;1d0c	ff 	. 
	rst 38h			;1d0d	ff 	. 
	rst 38h			;1d0e	ff 	. 
	rst 38h			;1d0f	ff 	. 
	rst 38h			;1d10	ff 	. 
	rst 38h			;1d11	ff 	. 
	rst 38h			;1d12	ff 	. 
	rst 38h			;1d13	ff 	. 
	rst 38h			;1d14	ff 	. 
	rst 38h			;1d15	ff 	. 
	rst 38h			;1d16	ff 	. 
	rst 38h			;1d17	ff 	. 
	rst 38h			;1d18	ff 	. 
	rst 38h			;1d19	ff 	. 
	rst 38h			;1d1a	ff 	. 
	rst 38h			;1d1b	ff 	. 
	rst 38h			;1d1c	ff 	. 
	rst 38h			;1d1d	ff 	. 
	rst 38h			;1d1e	ff 	. 
	rst 38h			;1d1f	ff 	. 
	rst 38h			;1d20	ff 	. 
	rst 38h			;1d21	ff 	. 
	rst 38h			;1d22	ff 	. 
	rst 38h			;1d23	ff 	. 
	rst 38h			;1d24	ff 	. 
	rst 38h			;1d25	ff 	. 
	rst 38h			;1d26	ff 	. 
	rst 38h			;1d27	ff 	. 
	rst 38h			;1d28	ff 	. 
	rst 38h			;1d29	ff 	. 
	rst 38h			;1d2a	ff 	. 
	rst 38h			;1d2b	ff 	. 
	rst 38h			;1d2c	ff 	. 
	rst 38h			;1d2d	ff 	. 
	rst 38h			;1d2e	ff 	. 
	rst 38h			;1d2f	ff 	. 
	rst 38h			;1d30	ff 	. 
	rst 38h			;1d31	ff 	. 
	rst 38h			;1d32	ff 	. 
	rst 38h			;1d33	ff 	. 
	rst 38h			;1d34	ff 	. 
	rst 38h			;1d35	ff 	. 
	rst 38h			;1d36	ff 	. 
	rst 38h			;1d37	ff 	. 
	rst 38h			;1d38	ff 	. 
	rst 38h			;1d39	ff 	. 
	rst 38h			;1d3a	ff 	. 
	rst 38h			;1d3b	ff 	. 
	rst 38h			;1d3c	ff 	. 
	rst 38h			;1d3d	ff 	. 
	rst 38h			;1d3e	ff 	. 
	rst 38h			;1d3f	ff 	. 
	rst 38h			;1d40	ff 	. 
	rst 38h			;1d41	ff 	. 
	rst 38h			;1d42	ff 	. 
	rst 38h			;1d43	ff 	. 
	rst 38h			;1d44	ff 	. 
	rst 38h			;1d45	ff 	. 
	rst 38h			;1d46	ff 	. 
	rst 38h			;1d47	ff 	. 
	rst 38h			;1d48	ff 	. 
	rst 38h			;1d49	ff 	. 
	rst 38h			;1d4a	ff 	. 
	rst 38h			;1d4b	ff 	. 
	rst 38h			;1d4c	ff 	. 
	rst 38h			;1d4d	ff 	. 
	rst 38h			;1d4e	ff 	. 
	rst 38h			;1d4f	ff 	. 
	rst 38h			;1d50	ff 	. 
	rst 38h			;1d51	ff 	. 
	rst 38h			;1d52	ff 	. 
	rst 38h			;1d53	ff 	. 
	rst 38h			;1d54	ff 	. 
	rst 38h			;1d55	ff 	. 
	rst 38h			;1d56	ff 	. 
	rst 38h			;1d57	ff 	. 
	rst 38h			;1d58	ff 	. 
	rst 38h			;1d59	ff 	. 
	rst 38h			;1d5a	ff 	. 
	rst 38h			;1d5b	ff 	. 
	rst 38h			;1d5c	ff 	. 
	rst 38h			;1d5d	ff 	. 
	rst 38h			;1d5e	ff 	. 
	rst 38h			;1d5f	ff 	. 
	rst 38h			;1d60	ff 	. 
	rst 38h			;1d61	ff 	. 
	rst 38h			;1d62	ff 	. 
	rst 38h			;1d63	ff 	. 
	rst 38h			;1d64	ff 	. 
	rst 38h			;1d65	ff 	. 
	rst 38h			;1d66	ff 	. 
	rst 38h			;1d67	ff 	. 
	rst 38h			;1d68	ff 	. 
	rst 38h			;1d69	ff 	. 
	rst 38h			;1d6a	ff 	. 
	rst 38h			;1d6b	ff 	. 
	rst 38h			;1d6c	ff 	. 
	rst 38h			;1d6d	ff 	. 
	rst 38h			;1d6e	ff 	. 
	rst 38h			;1d6f	ff 	. 
	rst 38h			;1d70	ff 	. 
	rst 38h			;1d71	ff 	. 
	rst 38h			;1d72	ff 	. 
	rst 38h			;1d73	ff 	. 
	rst 38h			;1d74	ff 	. 
	rst 38h			;1d75	ff 	. 
	rst 38h			;1d76	ff 	. 
	rst 38h			;1d77	ff 	. 
	rst 38h			;1d78	ff 	. 
	rst 38h			;1d79	ff 	. 
	rst 38h			;1d7a	ff 	. 
	rst 38h			;1d7b	ff 	. 
	rst 38h			;1d7c	ff 	. 
	rst 38h			;1d7d	ff 	. 
	rst 38h			;1d7e	ff 	. 
	rst 38h			;1d7f	ff 	. 
	rst 38h			;1d80	ff 	. 
	rst 38h			;1d81	ff 	. 
	rst 38h			;1d82	ff 	. 
	rst 38h			;1d83	ff 	. 
	rst 38h			;1d84	ff 	. 
	rst 38h			;1d85	ff 	. 
	rst 38h			;1d86	ff 	. 
	rst 38h			;1d87	ff 	. 
	rst 38h			;1d88	ff 	. 
	rst 38h			;1d89	ff 	. 
	rst 38h			;1d8a	ff 	. 
	rst 38h			;1d8b	ff 	. 
	rst 38h			;1d8c	ff 	. 
	rst 38h			;1d8d	ff 	. 
	rst 38h			;1d8e	ff 	. 
	rst 38h			;1d8f	ff 	. 
	rst 38h			;1d90	ff 	. 
	rst 38h			;1d91	ff 	. 
	rst 38h			;1d92	ff 	. 
	rst 38h			;1d93	ff 	. 
	rst 38h			;1d94	ff 	. 
	rst 38h			;1d95	ff 	. 
	rst 38h			;1d96	ff 	. 
	rst 38h			;1d97	ff 	. 
	rst 38h			;1d98	ff 	. 
	rst 38h			;1d99	ff 	. 
	rst 38h			;1d9a	ff 	. 
	rst 38h			;1d9b	ff 	. 
	rst 38h			;1d9c	ff 	. 
	rst 38h			;1d9d	ff 	. 
	rst 38h			;1d9e	ff 	. 
	rst 38h			;1d9f	ff 	. 
	rst 38h			;1da0	ff 	. 
	rst 38h			;1da1	ff 	. 
	rst 38h			;1da2	ff 	. 
	rst 38h			;1da3	ff 	. 
	rst 38h			;1da4	ff 	. 
	rst 38h			;1da5	ff 	. 
	rst 38h			;1da6	ff 	. 
	rst 38h			;1da7	ff 	. 
	rst 38h			;1da8	ff 	. 
	rst 38h			;1da9	ff 	. 
	rst 38h			;1daa	ff 	. 
	rst 38h			;1dab	ff 	. 
	rst 38h			;1dac	ff 	. 
	rst 38h			;1dad	ff 	. 
	rst 38h			;1dae	ff 	. 
	rst 38h			;1daf	ff 	. 
	rst 38h			;1db0	ff 	. 
	rst 38h			;1db1	ff 	. 
	rst 38h			;1db2	ff 	. 
	rst 38h			;1db3	ff 	. 
	rst 38h			;1db4	ff 	. 
	rst 38h			;1db5	ff 	. 
	rst 38h			;1db6	ff 	. 
	rst 38h			;1db7	ff 	. 
	rst 38h			;1db8	ff 	. 
	rst 38h			;1db9	ff 	. 
	rst 38h			;1dba	ff 	. 
	rst 38h			;1dbb	ff 	. 
	rst 38h			;1dbc	ff 	. 
	rst 38h			;1dbd	ff 	. 
	rst 38h			;1dbe	ff 	. 
	rst 38h			;1dbf	ff 	. 
	rst 38h			;1dc0	ff 	. 
	rst 38h			;1dc1	ff 	. 
	rst 38h			;1dc2	ff 	. 
	rst 38h			;1dc3	ff 	. 
	rst 38h			;1dc4	ff 	. 
	rst 38h			;1dc5	ff 	. 
	rst 38h			;1dc6	ff 	. 
	rst 38h			;1dc7	ff 	. 
	rst 38h			;1dc8	ff 	. 
	rst 38h			;1dc9	ff 	. 
	rst 38h			;1dca	ff 	. 
	rst 38h			;1dcb	ff 	. 
	rst 38h			;1dcc	ff 	. 
	rst 38h			;1dcd	ff 	. 
	rst 38h			;1dce	ff 	. 
	rst 38h			;1dcf	ff 	. 
	rst 38h			;1dd0	ff 	. 
	rst 38h			;1dd1	ff 	. 
	rst 38h			;1dd2	ff 	. 
	rst 38h			;1dd3	ff 	. 
	rst 38h			;1dd4	ff 	. 
	rst 38h			;1dd5	ff 	. 
	rst 38h			;1dd6	ff 	. 
	rst 38h			;1dd7	ff 	. 
	rst 38h			;1dd8	ff 	. 
	rst 38h			;1dd9	ff 	. 
	rst 38h			;1dda	ff 	. 
	rst 38h			;1ddb	ff 	. 
	rst 38h			;1ddc	ff 	. 
	rst 38h			;1ddd	ff 	. 
	rst 38h			;1dde	ff 	. 
	rst 38h			;1ddf	ff 	. 
	rst 38h			;1de0	ff 	. 
	rst 38h			;1de1	ff 	. 
	rst 38h			;1de2	ff 	. 
	rst 38h			;1de3	ff 	. 
	rst 38h			;1de4	ff 	. 
	rst 38h			;1de5	ff 	. 
	rst 38h			;1de6	ff 	. 
	rst 38h			;1de7	ff 	. 
	rst 38h			;1de8	ff 	. 
	rst 38h			;1de9	ff 	. 
	rst 38h			;1dea	ff 	. 
	rst 38h			;1deb	ff 	. 
	rst 38h			;1dec	ff 	. 
	rst 38h			;1ded	ff 	. 
	rst 38h			;1dee	ff 	. 
	rst 38h			;1def	ff 	. 
	rst 38h			;1df0	ff 	. 
	rst 38h			;1df1	ff 	. 
	rst 38h			;1df2	ff 	. 
	rst 38h			;1df3	ff 	. 
	rst 38h			;1df4	ff 	. 
	rst 38h			;1df5	ff 	. 
	rst 38h			;1df6	ff 	. 
	rst 38h			;1df7	ff 	. 
	rst 38h			;1df8	ff 	. 
	rst 38h			;1df9	ff 	. 
	rst 38h			;1dfa	ff 	. 
	rst 38h			;1dfb	ff 	. 
	rst 38h			;1dfc	ff 	. 
	rst 38h			;1dfd	ff 	. 
	rst 38h			;1dfe	ff 	. 
	rst 38h			;1dff	ff 	. 
	rst 38h			;1e00	ff 	. 
	rst 38h			;1e01	ff 	. 
	rst 38h			;1e02	ff 	. 
	rst 38h			;1e03	ff 	. 
	rst 38h			;1e04	ff 	. 
	rst 38h			;1e05	ff 	. 
	rst 38h			;1e06	ff 	. 
	rst 38h			;1e07	ff 	. 
	rst 38h			;1e08	ff 	. 
	rst 38h			;1e09	ff 	. 
	rst 38h			;1e0a	ff 	. 
	rst 38h			;1e0b	ff 	. 
	rst 38h			;1e0c	ff 	. 
	rst 38h			;1e0d	ff 	. 
	rst 38h			;1e0e	ff 	. 
	rst 38h			;1e0f	ff 	. 
	rst 38h			;1e10	ff 	. 
	rst 38h			;1e11	ff 	. 
	rst 38h			;1e12	ff 	. 
	rst 38h			;1e13	ff 	. 
	rst 38h			;1e14	ff 	. 
	rst 38h			;1e15	ff 	. 
	rst 38h			;1e16	ff 	. 
	rst 38h			;1e17	ff 	. 
	rst 38h			;1e18	ff 	. 
	rst 38h			;1e19	ff 	. 
	rst 38h			;1e1a	ff 	. 
	rst 38h			;1e1b	ff 	. 
	rst 38h			;1e1c	ff 	. 
	rst 38h			;1e1d	ff 	. 
	rst 38h			;1e1e	ff 	. 
	rst 38h			;1e1f	ff 	. 
	rst 38h			;1e20	ff 	. 
	rst 38h			;1e21	ff 	. 
	rst 38h			;1e22	ff 	. 
	rst 38h			;1e23	ff 	. 
	rst 38h			;1e24	ff 	. 
	rst 38h			;1e25	ff 	. 
	rst 38h			;1e26	ff 	. 
	rst 38h			;1e27	ff 	. 
	rst 38h			;1e28	ff 	. 
	rst 38h			;1e29	ff 	. 
	rst 38h			;1e2a	ff 	. 
	rst 38h			;1e2b	ff 	. 
	rst 38h			;1e2c	ff 	. 
	rst 38h			;1e2d	ff 	. 
	rst 38h			;1e2e	ff 	. 
	rst 38h			;1e2f	ff 	. 
	rst 38h			;1e30	ff 	. 
	rst 38h			;1e31	ff 	. 
	rst 38h			;1e32	ff 	. 
	rst 38h			;1e33	ff 	. 
	rst 38h			;1e34	ff 	. 
	rst 38h			;1e35	ff 	. 
	rst 38h			;1e36	ff 	. 
	rst 38h			;1e37	ff 	. 
	rst 38h			;1e38	ff 	. 
	rst 38h			;1e39	ff 	. 
	rst 38h			;1e3a	ff 	. 
	rst 38h			;1e3b	ff 	. 
	rst 38h			;1e3c	ff 	. 
	rst 38h			;1e3d	ff 	. 
	rst 38h			;1e3e	ff 	. 
	rst 38h			;1e3f	ff 	. 
	rst 38h			;1e40	ff 	. 
	rst 38h			;1e41	ff 	. 
	rst 38h			;1e42	ff 	. 
	rst 38h			;1e43	ff 	. 
	rst 38h			;1e44	ff 	. 
	rst 38h			;1e45	ff 	. 
	rst 38h			;1e46	ff 	. 
	rst 38h			;1e47	ff 	. 
	rst 38h			;1e48	ff 	. 
	rst 38h			;1e49	ff 	. 
	rst 38h			;1e4a	ff 	. 
	rst 38h			;1e4b	ff 	. 
	rst 38h			;1e4c	ff 	. 
	rst 38h			;1e4d	ff 	. 
	rst 38h			;1e4e	ff 	. 
	rst 38h			;1e4f	ff 	. 
	rst 38h			;1e50	ff 	. 
	rst 38h			;1e51	ff 	. 
	rst 38h			;1e52	ff 	. 
	rst 38h			;1e53	ff 	. 
	rst 38h			;1e54	ff 	. 
	rst 38h			;1e55	ff 	. 
	rst 38h			;1e56	ff 	. 
	rst 38h			;1e57	ff 	. 
	rst 38h			;1e58	ff 	. 
	rst 38h			;1e59	ff 	. 
	rst 38h			;1e5a	ff 	. 
	rst 38h			;1e5b	ff 	. 
	rst 38h			;1e5c	ff 	. 
	rst 38h			;1e5d	ff 	. 
	rst 38h			;1e5e	ff 	. 
	rst 38h			;1e5f	ff 	. 
	rst 38h			;1e60	ff 	. 
	rst 38h			;1e61	ff 	. 
	rst 38h			;1e62	ff 	. 
	rst 38h			;1e63	ff 	. 
	rst 38h			;1e64	ff 	. 
	rst 38h			;1e65	ff 	. 
	rst 38h			;1e66	ff 	. 
	rst 38h			;1e67	ff 	. 
	rst 38h			;1e68	ff 	. 
	rst 38h			;1e69	ff 	. 
	rst 38h			;1e6a	ff 	. 
	rst 38h			;1e6b	ff 	. 
	rst 38h			;1e6c	ff 	. 
	rst 38h			;1e6d	ff 	. 
	rst 38h			;1e6e	ff 	. 
	rst 38h			;1e6f	ff 	. 
	rst 38h			;1e70	ff 	. 
	rst 38h			;1e71	ff 	. 
	rst 38h			;1e72	ff 	. 
	rst 38h			;1e73	ff 	. 
	rst 38h			;1e74	ff 	. 
	rst 38h			;1e75	ff 	. 
	rst 38h			;1e76	ff 	. 
	rst 38h			;1e77	ff 	. 
	rst 38h			;1e78	ff 	. 
	rst 38h			;1e79	ff 	. 
	rst 38h			;1e7a	ff 	. 
	rst 38h			;1e7b	ff 	. 
	rst 38h			;1e7c	ff 	. 
	rst 38h			;1e7d	ff 	. 
	rst 38h			;1e7e	ff 	. 
	rst 38h			;1e7f	ff 	. 
	rst 38h			;1e80	ff 	. 
	rst 38h			;1e81	ff 	. 
	rst 38h			;1e82	ff 	. 
	rst 38h			;1e83	ff 	. 
	rst 38h			;1e84	ff 	. 
	rst 38h			;1e85	ff 	. 
	rst 38h			;1e86	ff 	. 
	rst 38h			;1e87	ff 	. 
	rst 38h			;1e88	ff 	. 
	rst 38h			;1e89	ff 	. 
	rst 38h			;1e8a	ff 	. 
	rst 38h			;1e8b	ff 	. 
	rst 38h			;1e8c	ff 	. 
	rst 38h			;1e8d	ff 	. 
	rst 38h			;1e8e	ff 	. 
	rst 38h			;1e8f	ff 	. 
	rst 38h			;1e90	ff 	. 
	rst 38h			;1e91	ff 	. 
	rst 38h			;1e92	ff 	. 
	rst 38h			;1e93	ff 	. 
	rst 38h			;1e94	ff 	. 
	rst 38h			;1e95	ff 	. 
	rst 38h			;1e96	ff 	. 
	rst 38h			;1e97	ff 	. 
	rst 38h			;1e98	ff 	. 
	rst 38h			;1e99	ff 	. 
	rst 38h			;1e9a	ff 	. 
	rst 38h			;1e9b	ff 	. 
	rst 38h			;1e9c	ff 	. 
	rst 38h			;1e9d	ff 	. 
	rst 38h			;1e9e	ff 	. 
	rst 38h			;1e9f	ff 	. 
	rst 38h			;1ea0	ff 	. 
	rst 38h			;1ea1	ff 	. 
	rst 38h			;1ea2	ff 	. 
	rst 38h			;1ea3	ff 	. 
	rst 38h			;1ea4	ff 	. 
	rst 38h			;1ea5	ff 	. 
	rst 38h			;1ea6	ff 	. 
	rst 38h			;1ea7	ff 	. 
	rst 38h			;1ea8	ff 	. 
	rst 38h			;1ea9	ff 	. 
	rst 38h			;1eaa	ff 	. 
	rst 38h			;1eab	ff 	. 
	rst 38h			;1eac	ff 	. 
	rst 38h			;1ead	ff 	. 
	rst 38h			;1eae	ff 	. 
	rst 38h			;1eaf	ff 	. 
	rst 38h			;1eb0	ff 	. 
	rst 38h			;1eb1	ff 	. 
	rst 38h			;1eb2	ff 	. 
	rst 38h			;1eb3	ff 	. 
	rst 38h			;1eb4	ff 	. 
	rst 38h			;1eb5	ff 	. 
	rst 38h			;1eb6	ff 	. 
	rst 38h			;1eb7	ff 	. 
	rst 38h			;1eb8	ff 	. 
	rst 38h			;1eb9	ff 	. 
	rst 38h			;1eba	ff 	. 
	rst 38h			;1ebb	ff 	. 
	rst 38h			;1ebc	ff 	. 
	rst 38h			;1ebd	ff 	. 
	rst 38h			;1ebe	ff 	. 
	rst 38h			;1ebf	ff 	. 
	rst 38h			;1ec0	ff 	. 
	rst 38h			;1ec1	ff 	. 
	rst 38h			;1ec2	ff 	. 
	rst 38h			;1ec3	ff 	. 
	rst 38h			;1ec4	ff 	. 
	rst 38h			;1ec5	ff 	. 
	rst 38h			;1ec6	ff 	. 
	rst 38h			;1ec7	ff 	. 
	rst 38h			;1ec8	ff 	. 
	rst 38h			;1ec9	ff 	. 
	rst 38h			;1eca	ff 	. 
	rst 38h			;1ecb	ff 	. 
	rst 38h			;1ecc	ff 	. 
	rst 38h			;1ecd	ff 	. 
	rst 38h			;1ece	ff 	. 
	rst 38h			;1ecf	ff 	. 
	rst 38h			;1ed0	ff 	. 
	rst 38h			;1ed1	ff 	. 
	rst 38h			;1ed2	ff 	. 
	rst 38h			;1ed3	ff 	. 
	rst 38h			;1ed4	ff 	. 
	rst 38h			;1ed5	ff 	. 
	rst 38h			;1ed6	ff 	. 
	rst 38h			;1ed7	ff 	. 
	rst 38h			;1ed8	ff 	. 
	rst 38h			;1ed9	ff 	. 
	rst 38h			;1eda	ff 	. 
	rst 38h			;1edb	ff 	. 
	rst 38h			;1edc	ff 	. 
	rst 38h			;1edd	ff 	. 
	rst 38h			;1ede	ff 	. 
	rst 38h			;1edf	ff 	. 
	rst 38h			;1ee0	ff 	. 
	rst 38h			;1ee1	ff 	. 
	rst 38h			;1ee2	ff 	. 
	rst 38h			;1ee3	ff 	. 
	rst 38h			;1ee4	ff 	. 
	rst 38h			;1ee5	ff 	. 
	rst 38h			;1ee6	ff 	. 
	rst 38h			;1ee7	ff 	. 
	rst 38h			;1ee8	ff 	. 
	rst 38h			;1ee9	ff 	. 
	rst 38h			;1eea	ff 	. 
	rst 38h			;1eeb	ff 	. 
	rst 38h			;1eec	ff 	. 
	rst 38h			;1eed	ff 	. 
	rst 38h			;1eee	ff 	. 
	rst 38h			;1eef	ff 	. 
	rst 38h			;1ef0	ff 	. 
	rst 38h			;1ef1	ff 	. 
	rst 38h			;1ef2	ff 	. 
	rst 38h			;1ef3	ff 	. 
	rst 38h			;1ef4	ff 	. 
	rst 38h			;1ef5	ff 	. 
	rst 38h			;1ef6	ff 	. 
	rst 38h			;1ef7	ff 	. 
	rst 38h			;1ef8	ff 	. 
	rst 38h			;1ef9	ff 	. 
	rst 38h			;1efa	ff 	. 
	rst 38h			;1efb	ff 	. 
	rst 38h			;1efc	ff 	. 
	rst 38h			;1efd	ff 	. 
	rst 38h			;1efe	ff 	. 
	rst 38h			;1eff	ff 	. 
	rst 38h			;1f00	ff 	. 
	rst 38h			;1f01	ff 	. 
	rst 38h			;1f02	ff 	. 
	rst 38h			;1f03	ff 	. 
	rst 38h			;1f04	ff 	. 
	rst 38h			;1f05	ff 	. 
	rst 38h			;1f06	ff 	. 
	rst 38h			;1f07	ff 	. 
	rst 38h			;1f08	ff 	. 
	rst 38h			;1f09	ff 	. 
	rst 38h			;1f0a	ff 	. 
	rst 38h			;1f0b	ff 	. 
	rst 38h			;1f0c	ff 	. 
	rst 38h			;1f0d	ff 	. 
	rst 38h			;1f0e	ff 	. 
	rst 38h			;1f0f	ff 	. 
	rst 38h			;1f10	ff 	. 
	rst 38h			;1f11	ff 	. 
	rst 38h			;1f12	ff 	. 
	rst 38h			;1f13	ff 	. 
	rst 38h			;1f14	ff 	. 
	rst 38h			;1f15	ff 	. 
	rst 38h			;1f16	ff 	. 
	rst 38h			;1f17	ff 	. 
	rst 38h			;1f18	ff 	. 
	rst 38h			;1f19	ff 	. 
	rst 38h			;1f1a	ff 	. 
	rst 38h			;1f1b	ff 	. 
	rst 38h			;1f1c	ff 	. 
	rst 38h			;1f1d	ff 	. 
	rst 38h			;1f1e	ff 	. 
	rst 38h			;1f1f	ff 	. 
	rst 38h			;1f20	ff 	. 
	rst 38h			;1f21	ff 	. 
	rst 38h			;1f22	ff 	. 
	rst 38h			;1f23	ff 	. 
	rst 38h			;1f24	ff 	. 
	rst 38h			;1f25	ff 	. 
	rst 38h			;1f26	ff 	. 
	rst 38h			;1f27	ff 	. 
	rst 38h			;1f28	ff 	. 
	rst 38h			;1f29	ff 	. 
	rst 38h			;1f2a	ff 	. 
	rst 38h			;1f2b	ff 	. 
	rst 38h			;1f2c	ff 	. 
	rst 38h			;1f2d	ff 	. 
	rst 38h			;1f2e	ff 	. 
	rst 38h			;1f2f	ff 	. 
	rst 38h			;1f30	ff 	. 
	rst 38h			;1f31	ff 	. 
	rst 38h			;1f32	ff 	. 
	rst 38h			;1f33	ff 	. 
	rst 38h			;1f34	ff 	. 
	rst 38h			;1f35	ff 	. 
	rst 38h			;1f36	ff 	. 
	rst 38h			;1f37	ff 	. 
	rst 38h			;1f38	ff 	. 
	rst 38h			;1f39	ff 	. 
	rst 38h			;1f3a	ff 	. 
	rst 38h			;1f3b	ff 	. 
	rst 38h			;1f3c	ff 	. 
	rst 38h			;1f3d	ff 	. 
	rst 38h			;1f3e	ff 	. 
	rst 38h			;1f3f	ff 	. 
	rst 38h			;1f40	ff 	. 
	rst 38h			;1f41	ff 	. 
	rst 38h			;1f42	ff 	. 
	rst 38h			;1f43	ff 	. 
	rst 38h			;1f44	ff 	. 
	rst 38h			;1f45	ff 	. 
	rst 38h			;1f46	ff 	. 
	rst 38h			;1f47	ff 	. 
	rst 38h			;1f48	ff 	. 
	rst 38h			;1f49	ff 	. 
	rst 38h			;1f4a	ff 	. 
	rst 38h			;1f4b	ff 	. 
	rst 38h			;1f4c	ff 	. 
	rst 38h			;1f4d	ff 	. 
	rst 38h			;1f4e	ff 	. 
	rst 38h			;1f4f	ff 	. 
	rst 38h			;1f50	ff 	. 
	rst 38h			;1f51	ff 	. 
	rst 38h			;1f52	ff 	. 
	rst 38h			;1f53	ff 	. 
	rst 38h			;1f54	ff 	. 
	rst 38h			;1f55	ff 	. 
	rst 38h			;1f56	ff 	. 
	rst 38h			;1f57	ff 	. 
	rst 38h			;1f58	ff 	. 
	rst 38h			;1f59	ff 	. 
	rst 38h			;1f5a	ff 	. 
	rst 38h			;1f5b	ff 	. 
	rst 38h			;1f5c	ff 	. 
	rst 38h			;1f5d	ff 	. 
	rst 38h			;1f5e	ff 	. 
	rst 38h			;1f5f	ff 	. 
	rst 38h			;1f60	ff 	. 
	rst 38h			;1f61	ff 	. 
	rst 38h			;1f62	ff 	. 
	rst 38h			;1f63	ff 	. 
	rst 38h			;1f64	ff 	. 
	rst 38h			;1f65	ff 	. 
	rst 38h			;1f66	ff 	. 
	rst 38h			;1f67	ff 	. 
	rst 38h			;1f68	ff 	. 
	rst 38h			;1f69	ff 	. 
	rst 38h			;1f6a	ff 	. 
	rst 38h			;1f6b	ff 	. 
	rst 38h			;1f6c	ff 	. 
	rst 38h			;1f6d	ff 	. 
	rst 38h			;1f6e	ff 	. 
	rst 38h			;1f6f	ff 	. 
	rst 38h			;1f70	ff 	. 
	rst 38h			;1f71	ff 	. 
	rst 38h			;1f72	ff 	. 
	rst 38h			;1f73	ff 	. 
	rst 38h			;1f74	ff 	. 
	rst 38h			;1f75	ff 	. 
	rst 38h			;1f76	ff 	. 
	rst 38h			;1f77	ff 	. 
	rst 38h			;1f78	ff 	. 
	rst 38h			;1f79	ff 	. 
	rst 38h			;1f7a	ff 	. 
	rst 38h			;1f7b	ff 	. 
	rst 38h			;1f7c	ff 	. 
	rst 38h			;1f7d	ff 	. 
	rst 38h			;1f7e	ff 	. 
	rst 38h			;1f7f	ff 	. 
	rst 38h			;1f80	ff 	. 
	rst 38h			;1f81	ff 	. 
	rst 38h			;1f82	ff 	. 
	rst 38h			;1f83	ff 	. 
	rst 38h			;1f84	ff 	. 
	rst 38h			;1f85	ff 	. 
	rst 38h			;1f86	ff 	. 
	rst 38h			;1f87	ff 	. 
	rst 38h			;1f88	ff 	. 
	rst 38h			;1f89	ff 	. 
	rst 38h			;1f8a	ff 	. 
	rst 38h			;1f8b	ff 	. 
	rst 38h			;1f8c	ff 	. 
	rst 38h			;1f8d	ff 	. 
	rst 38h			;1f8e	ff 	. 
	rst 38h			;1f8f	ff 	. 
	rst 38h			;1f90	ff 	. 
	rst 38h			;1f91	ff 	. 
	rst 38h			;1f92	ff 	. 
	rst 38h			;1f93	ff 	. 
	rst 38h			;1f94	ff 	. 
	rst 38h			;1f95	ff 	. 
	rst 38h			;1f96	ff 	. 
	rst 38h			;1f97	ff 	. 
	rst 38h			;1f98	ff 	. 
	rst 38h			;1f99	ff 	. 
	rst 38h			;1f9a	ff 	. 
	rst 38h			;1f9b	ff 	. 
	rst 38h			;1f9c	ff 	. 
	rst 38h			;1f9d	ff 	. 
	rst 38h			;1f9e	ff 	. 
	rst 38h			;1f9f	ff 	. 
	rst 38h			;1fa0	ff 	. 
	rst 38h			;1fa1	ff 	. 
	rst 38h			;1fa2	ff 	. 
	rst 38h			;1fa3	ff 	. 
	rst 38h			;1fa4	ff 	. 
	rst 38h			;1fa5	ff 	. 
	rst 38h			;1fa6	ff 	. 
	rst 38h			;1fa7	ff 	. 
	rst 38h			;1fa8	ff 	. 
	rst 38h			;1fa9	ff 	. 
	rst 38h			;1faa	ff 	. 
	rst 38h			;1fab	ff 	. 
	rst 38h			;1fac	ff 	. 
	rst 38h			;1fad	ff 	. 
	rst 38h			;1fae	ff 	. 
	rst 38h			;1faf	ff 	. 
	rst 38h			;1fb0	ff 	. 
	rst 38h			;1fb1	ff 	. 
	rst 38h			;1fb2	ff 	. 
	rst 38h			;1fb3	ff 	. 
	rst 38h			;1fb4	ff 	. 
	rst 38h			;1fb5	ff 	. 
	rst 38h			;1fb6	ff 	. 
	rst 38h			;1fb7	ff 	. 
	rst 38h			;1fb8	ff 	. 
	rst 38h			;1fb9	ff 	. 
	rst 38h			;1fba	ff 	. 
	rst 38h			;1fbb	ff 	. 
	rst 38h			;1fbc	ff 	. 
	rst 38h			;1fbd	ff 	. 
	rst 38h			;1fbe	ff 	. 
	rst 38h			;1fbf	ff 	. 
	rst 38h			;1fc0	ff 	. 
	rst 38h			;1fc1	ff 	. 
	rst 38h			;1fc2	ff 	. 
	rst 38h			;1fc3	ff 	. 
	rst 38h			;1fc4	ff 	. 
	rst 38h			;1fc5	ff 	. 
	rst 38h			;1fc6	ff 	. 
	rst 38h			;1fc7	ff 	. 
	rst 38h			;1fc8	ff 	. 
	rst 38h			;1fc9	ff 	. 
	rst 38h			;1fca	ff 	. 
	rst 38h			;1fcb	ff 	. 
	rst 38h			;1fcc	ff 	. 
	rst 38h			;1fcd	ff 	. 
	rst 38h			;1fce	ff 	. 
	rst 38h			;1fcf	ff 	. 
	rst 38h			;1fd0	ff 	. 
	rst 38h			;1fd1	ff 	. 
	rst 38h			;1fd2	ff 	. 
	rst 38h			;1fd3	ff 	. 
	rst 38h			;1fd4	ff 	. 
	rst 38h			;1fd5	ff 	. 
	rst 38h			;1fd6	ff 	. 
	rst 38h			;1fd7	ff 	. 
	rst 38h			;1fd8	ff 	. 
	rst 38h			;1fd9	ff 	. 
	rst 38h			;1fda	ff 	. 
	rst 38h			;1fdb	ff 	. 
	rst 38h			;1fdc	ff 	. 
	rst 38h			;1fdd	ff 	. 
	rst 38h			;1fde	ff 	. 
	rst 38h			;1fdf	ff 	. 
	rst 38h			;1fe0	ff 	. 
	rst 38h			;1fe1	ff 	. 
	rst 38h			;1fe2	ff 	. 
	rst 38h			;1fe3	ff 	. 
	rst 38h			;1fe4	ff 	. 
	rst 38h			;1fe5	ff 	. 
	rst 38h			;1fe6	ff 	. 
	rst 38h			;1fe7	ff 	. 
	rst 38h			;1fe8	ff 	. 
	rst 38h			;1fe9	ff 	. 
	rst 38h			;1fea	ff 	. 
	rst 38h			;1feb	ff 	. 
	rst 38h			;1fec	ff 	. 
	rst 38h			;1fed	ff 	. 
	rst 38h			;1fee	ff 	. 
	rst 38h			;1fef	ff 	. 
	rst 38h			;1ff0	ff 	. 
	rst 38h			;1ff1	ff 	. 
	rst 38h			;1ff2	ff 	. 
	rst 38h			;1ff3	ff 	. 
	rst 38h			;1ff4	ff 	. 
	rst 38h			;1ff5	ff 	. 
	rst 38h			;1ff6	ff 	. 
	rst 38h			;1ff7	ff 	. 
	rst 38h			;1ff8	ff 	. 
	rst 38h			;1ff9	ff 	. 
	rst 38h			;1ffa	ff 	. 
	rst 38h			;1ffb	ff 	. 
	rst 38h			;1ffc	ff 	. 
	rst 38h			;1ffd	ff 	. 
	rst 38h			;1ffe	ff 	. 
	rst 38h			;1fff	ff 	. 
l2000h:
	ld (bc),a			;2000	02 	. 
	ld (02203h),hl		;2001	22 03 22 	" . " 
	ld c,022h		;2004	0e 22 	. " 
	add hl,de			;2006	19 	. 
	ld (l2224h),hl		;2007	22 24 22 	" $ " 
	cpl			;200a	2f 	/ 
	ld (l223ah),hl		;200b	22 3a 22 	" : " 
	ld b,l			;200e	45 	E 
	ld (l2250h),hl		;200f	22 50 22 	" P " 
	ld e,e			;2012	5b 	[ 
	ld (l2266h),hl		;2013	22 66 22 	" f " 
	ld (hl),c			;2016	71 	q 
	ld (l227ch),hl		;2017	22 7c 22 	" | " 
	add a,a			;201a	87 	. 
	ld (l2292h),hl		;201b	22 92 22 	" . " 
	sbc a,l			;201e	9d 	. 
	ld (l22a8h),hl		;201f	22 a8 22 	" . " 
	or e			;2022	b3 	. 
	ld (l22beh),hl		;2023	22 be 22 	" . " 
	ret			;2026	c9 	. 
	ld (l22d4h),hl		;2027	22 d4 22 	" . " 
	rst 18h			;202a	df 	. 
	ld (l22e5h),hl		;202b	22 e5 22 	" . " 
	ex de,hl			;202e	eb 	. 
	ld (l22f1h),hl		;202f	22 f1 22 	" . " 
	rst 30h			;2032	f7 	. 
	ld (l22fdh),hl		;2033	22 fd 22 	" . " 
	inc bc			;2036	03 	. 
	inc hl			;2037	23 	# 
	add hl,bc			;2038	09 	. 
	inc hl			;2039	23 	# 
	rrca			;203a	0f 	. 
	inc hl			;203b	23 	# 
	ld a,(de)			;203c	1a 	. 
	inc hl			;203d	23 	# 
	dec h			;203e	25 	% 
	inc hl			;203f	23 	# 
	dec hl			;2040	2b 	+ 
	inc hl			;2041	23 	# 
	ld sp,l3c23h		;2042	31 23 3c 	1 # < 
	inc hl			;2045	23 	# 
	ld b,a			;2046	47 	G 
	inc hl			;2047	23 	# 
	ld c,l			;2048	4d 	M 
	inc hl			;2049	23 	# 
	ld d,e			;204a	53 	S 
	inc hl			;204b	23 	# 
	ld e,(hl)			;204c	5e 	^ 
	inc hl			;204d	23 	# 
	ld l,c			;204e	69 	i 
	inc hl			;204f	23 	# 
	ld l,a			;2050	6f 	o 
	inc hl			;2051	23 	# 
	ld (hl),l			;2052	75 	u 
	inc hl			;2053	23 	# 
	add a,b			;2054	80 	. 
	inc hl			;2055	23 	# 
	adc a,e			;2056	8b 	. 
	inc hl			;2057	23 	# 
	sub c			;2058	91 	. 
	inc hl			;2059	23 	# 
	sub a			;205a	97 	. 
	inc hl			;205b	23 	# 
	and d			;205c	a2 	. 
	inc hl			;205d	23 	# 
	xor l			;205e	ad 	. 
	inc hl			;205f	23 	# 
	or e			;2060	b3 	. 
	inc hl			;2061	23 	# 
	cp c			;2062	b9 	. 
	inc hl			;2063	23 	# 
	call nz,0cf23h		;2064	c4 23 cf 	. # . 
	inc hl			;2067	23 	# 
	push de			;2068	d5 	. 
	inc hl			;2069	23 	# 
	in a,(023h)		;206a	db 23 	. # 
	and 023h		;206c	e6 23 	. # 
	pop af			;206e	f1 	. 
	inc hl			;206f	23 	# 
	call m,sub_0723h		;2070	fc 23 07 	. # . 
	inc h			;2073	24 	$ 
	ld (de),a			;2074	12 	. 
	inc h			;2075	24 	$ 
	dec e			;2076	1d 	. 
	inc h			;2077	24 	$ 
	jr z,l209eh		;2078	28 24 	( $ 
	inc sp			;207a	33 	3 
	inc h			;207b	24 	$ 
	ld a,024h		;207c	3e 24 	> $ 
	ld c,c			;207e	49 	I 
	inc h			;207f	24 	$ 
	ld d,h			;2080	54 	T 
	inc h			;2081	24 	$ 
	ld e,a			;2082	5f 	_ 
	inc h			;2083	24 	$ 
	ld l,d			;2084	6a 	j 
	inc h			;2085	24 	$ 
	ld (hl),l			;2086	75 	u 
	inc h			;2087	24 	$ 
	add a,b			;2088	80 	. 
	inc h			;2089	24 	$ 
	adc a,e			;208a	8b 	. 
	inc h			;208b	24 	$ 
	sub (hl)			;208c	96 	. 
	inc h			;208d	24 	$ 
	and c			;208e	a1 	. 
	inc h			;208f	24 	$ 
	or c			;2090	b1 	. 
	inc h			;2091	24 	$ 
	ret nz			;2092	c0 	. 
	inc h			;2093	24 	$ 
	sla h		;2094	cb 24 	. $ 
	sub 024h		;2096	d6 24 	. $ 
	pop hl			;2098	e1 	. 
	inc h			;2099	24 	$ 
	call pe,0f224h		;209a	ec 24 f2 	. $ . 
	inc h			;209d	24 	$ 
l209eh:
	ret m			;209e	f8 	. 
	inc h			;209f	24 	$ 
	cp 024h		;20a0	fe 24 	. $ 
	inc b			;20a2	04 	. 
	dec h			;20a3	25 	% 
	ld a,(bc)			;20a4	0a 	. 
	dec h			;20a5	25 	% 
	djnz l20cdh		;20a6	10 25 	. % 
	ld d,025h		;20a8	16 25 	. % 
	ld e,a			;20aa	5f 	_ 
	dec b			;20ab	05 	. 
	ld (hl),a			;20ac	77 	w 
	dec b			;20ad	05 	. 
	adc a,a			;20ae	8f 	. 
	dec b			;20af	05 	. 
	and a			;20b0	a7 	. 
	dec b			;20b1	05 	. 
	rla			;20b2	17 	. 
	ld b,01bh		;20b3	06 1b 	. . 
	ld b,002h		;20b5	06 02 	. . 
	ld (02202h),hl		;20b7	22 02 22 	" . " 
	inc e			;20ba	1c 	. 
	dec h			;20bb	25 	% 
	inc h			;20bc	24 	$ 
	dec h			;20bd	25 	% 
	inc l			;20be	2c 	, 
	dec h			;20bf	25 	% 
	inc (hl)			;20c0	34 	4 
	dec h			;20c1	25 	% 
	inc a			;20c2	3c 	< 
	dec h			;20c3	25 	% 
	ld b,h			;20c4	44 	D 
	dec h			;20c5	25 	% 
	ld c,h			;20c6	4c 	L 
	dec h			;20c7	25 	% 
	ld d,h			;20c8	54 	T 
l20c9h:
	dec h			;20c9	25 	% 
	ld e,h			;20ca	5c 	\ 
	dec h			;20cb	25 	% 
	ld h,h			;20cc	64 	d 
l20cdh:
	dec h			;20cd	25 	% 
	ld l,h			;20ce	6c 	l 
	dec h			;20cf	25 	% 
	ld (hl),h			;20d0	74 	t 
	dec h			;20d1	25 	% 
	ld a,h			;20d2	7c 	| 
	dec h			;20d3	25 	% 
	add a,h			;20d4	84 	. 
	dec h			;20d5	25 	% 
	adc a,h			;20d6	8c 	. 
	dec h			;20d7	25 	% 
	sub h			;20d8	94 	. 
	dec h			;20d9	25 	% 
	sbc a,h			;20da	9c 	. 
l20dbh:
	dec h			;20db	25 	% 
	and h			;20dc	a4 	. 
	dec h			;20dd	25 	% 
	xor h			;20de	ac 	. 
	dec h			;20df	25 	% 
	cp c			;20e0	b9 	. 
	dec h			;20e1	25 	% 
	add a,025h		;20e2	c6 25 	. % 
	push af			;20e4	f5 	. 
	dec h			;20e5	25 	% 
l20e6h:
	inc h			;20e6	24 	$ 
	ld h,02ah		;20e7	26 2a 	& * 
	ld h,030h		;20e9	26 30 	& 0 
	ld h,03bh		;20eb	26 3b 	& ; 
	ld h,046h		;20ed	26 46 	& F 
	ld h,04ch		;20ef	26 4c 	& L 
	ld h,052h		;20f1	26 52 	& R 
	ld h,058h		;20f3	26 58 	& X 
	ld h,05eh		;20f5	26 5e 	& ^ 
	ld h,064h		;20f7	26 64 	& d 
	ld h,002h		;20f9	26 02 	& . 
	ld (02202h),hl		;20fb	22 02 22 	" . " 
	ld (bc),a			;20fe	02 	. 
	ld (02202h),hl		;20ff	22 02 22 	" . " 
	ld l,d			;2102	6a 	j 
	ld h,07dh		;2103	26 7d 	& } 
	ld h,0b8h		;2105	26 b8 	& . 
	ld h,002h		;2107	26 02 	& . 
	ld (l2690h),hl		;2109	22 90 26 	" . & 
	ld (bc),a			;210c	02 	. 
	ld (l3278h),hl		;210d	22 78 32 	" x 2 
	sub e			;2110	93 	. 
	ld (l32aeh),a		;2111	32 ae 32 	2 . 2 
	ret			;2114	c9 	. 
	ld (sub_32e4h),a		;2115	32 e4 32 	2 . 2 
	rst 38h			;2118	ff 	. 
	ld (l331ah),a		;2119	32 1a 33 	2 . 3 
	dec (hl)			;211c	35 	5 
	inc sp			;211d	33 	3 
	ld d,b			;211e	50 	P 
	inc sp			;211f	33 	3 
	ld l,e			;2120	6b 	k 
	inc sp			;2121	33 	3 
	ld (bc),a			;2122	02 	. 
	ld (02202h),hl		;2123	22 02 22 	" . " 
	sbc a,031h		;2126	de 31 	. 1 
	ld (bc),a			;2128	02 	. 
	ld (sub_277ch),hl		;2129	22 7c 27 	" | ' 
	or l			;212c	b5 	. 
	daa			;212d	27 	' 
	out (027h),a		;212e	d3 27 	. ' 
	pop af			;2130	f1 	. 
	ld h,00eh		;2131	26 0e 	& . 
	jr z,$+23		;2133	28 15 	( . 
	jr z,$+45		;2135	28 2b 	( + 
	jr z,l216bh		;2137	28 32 	( 2 
	jr z,l219eh		;2139	28 63 	( c 
	jr z,l21a4h		;213b	28 67 	( g 
	jr z,l2163h		;213d	28 24 	( $ 
	jr z,$+4		;213f	28 02 	( . 
	ld (l286bh),hl		;2141	22 6b 28 	" k ( 
	add a,h			;2144	84 	. 
	jr z,$+121		;2145	28 77 	( w 
	jr z,l20c9h		;2147	28 80 	( . 
	jr z,l20dbh		;2149	28 90 	( . 
	jr z,l20e6h		;214b	28 99 	( . 
	jr z,l2191h		;214d	28 42 	( B 
	jr z,$+74		;214f	28 48 	( H 
	jr z,l21abh		;2151	28 58 	( X 
	jr z,$+96		;2153	28 5e 	( ^ 
	jr z,l2170h		;2155	28 19 	( . 
	jr z,l2178h		;2157	28 1f 	( . 
	jr z,$+4		;2159	28 02 	( . 
	ld (02202h),hl		;215b	22 02 22 	" . " 
	ld c,l			;215e	4d 	M 
	jr z,l21b4h		;215f	28 53 	( S 
	jr z,$+4		;2161	28 02 	( . 
l2163h:
	ld (02202h),hl		;2163	22 02 22 	" . " 
	call c,0e627h		;2166	dc 27 e6 	. ' . 
	daa			;2169	27 	' 
	ex de,hl			;216a	eb 	. 
l216bh:
	daa			;216b	27 	' 
	pop af			;216c	f1 	. 
	daa			;216d	27 	' 
	or 027h		;216e	f6 27 	. ' 
l2170h:
	call m,00227h		;2170	fc 27 02 	. ' . 
	jr z,$+10		;2173	28 08 	( . 
	jr z,l218ch		;2175	28 15 	( . 
	add hl,hl			;2177	29 	) 
l2178h:
	dec e			;2178	1d 	. 
	add hl,hl			;2179	29 	) 
	ld (bc),a			;217a	02 	. 
	ld (02202h),hl		;217b	22 02 22 	" . " 
	ld (bc),a			;217e	02 	. 
	ld (02202h),hl		;217f	22 02 22 	" . " 
	dec l			;2182	2d 	- 
	add hl,hl			;2183	29 	) 
	ld c,b			;2184	48 	H 
	add hl,hl			;2185	29 	) 
	jr nc,$+45		;2186	30 2b 	0 + 
	ld (bc),a			;2188	02 	. 
	ld (02202h),hl		;2189	22 02 22 	" . " 
l218ch:
	ld (bc),a			;218c	02 	. 
	ld (02202h),hl		;218d	22 02 22 	" . " 
	ld (bc),a			;2190	02 	. 
l2191h:
	ld (sub_0b31h),hl		;2191	22 31 0b 	" 1 . 
	ld (bc),a			;2194	02 	. 
	ld (sub_0317h),hl		;2195	22 17 03 	" . . 
	ld (hl),003h		;2198	36 03 	6 . 
	ld d,l			;219a	55 	U 
	inc bc			;219b	03 	. 
	ld (hl),h			;219c	74 	t 
	inc bc			;219d	03 	. 
l219eh:
	sub e			;219e	93 	. 
	inc bc			;219f	03 	. 
	or d			;21a0	b2 	. 
	inc bc			;21a1	03 	. 
	pop de			;21a2	d1 	. 
	inc bc			;21a3	03 	. 
l21a4h:
	ret p			;21a4	f0 	. 
	inc bc			;21a5	03 	. 
	ld c,l			;21a6	4d 	M 
	inc b			;21a7	04 	. 
	inc hl			;21a8	23 	# 
	add hl,hl			;21a9	29 	) 
	dec e			;21aa	1d 	. 
l21abh:
	dec bc			;21ab	0b 	. 
	ld (bc),a			;21ac	02 	. 
	ld (02202h),hl		;21ad	22 02 22 	" . " 
	ld (bc),a			;21b0	02 	. 
	ld (02202h),hl		;21b1	22 02 22 	" . " 
l21b4h:
	ld (bc),a			;21b4	02 	. 
	ld (02202h),hl		;21b5	22 02 22 	" . " 
	ld (bc),a			;21b8	02 	. 
	ld (02202h),hl		;21b9	22 02 22 	" . " 
	ld (bc),a			;21bc	02 	. 
	ld (02202h),hl		;21bd	22 02 22 	" . " 
	ld (bc),a			;21c0	02 	. 
	ld (02202h),hl		;21c1	22 02 22 	" . " 
	ld (bc),a			;21c4	02 	. 
	ld (02202h),hl		;21c5	22 02 22 	" . " 
	ld (bc),a			;21c8	02 	. 
l21c9h:
	ld (02202h),hl		;21c9	22 02 22 	" . " 
	ld (bc),a			;21cc	02 	. 
	ld (02202h),hl		;21cd	22 02 22 	" . " 
	ld (bc),a			;21d0	02 	. 
	ld (02202h),hl		;21d1	22 02 22 	" . " 
	ld (bc),a			;21d4	02 	. 
	ld (02202h),hl		;21d5	22 02 22 	" . " 
	ld (bc),a			;21d8	02 	. 
	ld (02202h),hl		;21d9	22 02 22 	" . " 
	ld (bc),a			;21dc	02 	. 
	ld (02202h),hl		;21dd	22 02 22 	" . " 
	ld (bc),a			;21e0	02 	. 
	ld (02202h),hl		;21e1	22 02 22 	" . " 
	ld (bc),a			;21e4	02 	. 
	ld (02202h),hl		;21e5	22 02 22 	" . " 
	ld (bc),a			;21e8	02 	. 
	ld (02202h),hl		;21e9	22 02 22 	" . " 
	ld (bc),a			;21ec	02 	. 
	ld (02202h),hl		;21ed	22 02 22 	" . " 
	ld (bc),a			;21f0	02 	. 
	ld (02202h),hl		;21f1	22 02 22 	" . " 
	ld (bc),a			;21f4	02 	. 
	ld (02202h),hl		;21f5	22 02 22 	" . " 
	ld (bc),a			;21f8	02 	. 
	ld (02202h),hl		;21f9	22 02 22 	" . " 
	ld (bc),a			;21fc	02 	. 
	ld (02202h),hl		;21fd	22 02 22 	" . " 
	ld (bc),a			;2200	02 	. 
	ld (l21c9h),hl		;2201	22 c9 21 	" . ! 
	add hl,bc			;2204	09 	. 
	pop bc			;2205	c1 	. 
	res 4,(hl)		;2206	cb a6 	. . 
	ld hl,0c101h		;2208	21 01 c1 	! . . 
	set 4,(hl)		;220b	cb e6 	. . 
	ret			;220d	c9 	. 
sub_220eh:
	ld hl,0c109h		;220e	21 09 c1 	! . . 
	set 4,(hl)		;2211	cb e6 	. . 
	ld hl,0c101h		;2213	21 01 c1 	! . . 
	res 4,(hl)		;2216	cb a6 	. . 
	ret			;2218	c9 	. 
sub_2219h:
	ld hl,0c10ah		;2219	21 0a c1 	! . . 
	res 4,(hl)		;221c	cb a6 	. . 
	ld hl,0c102h		;221e	21 02 c1 	! . . 
	set 4,(hl)		;2221	cb e6 	. . 
	ret			;2223	c9 	. 
l2224h:
	ld hl,0c10ah		;2224	21 0a c1 	! . . 
	set 4,(hl)		;2227	cb e6 	. . 
	ld hl,0c102h		;2229	21 02 c1 	! . . 
	res 4,(hl)		;222c	cb a6 	. . 
	ret			;222e	c9 	. 
sub_222fh:
	ld hl,0c10bh		;222f	21 0b c1 	! . . 
	res 4,(hl)		;2232	cb a6 	. . 
	ld hl,0c103h		;2234	21 03 c1 	! . . 
	set 4,(hl)		;2237	cb e6 	. . 
	ret			;2239	c9 	. 
l223ah:
	ld hl,0c10bh		;223a	21 0b c1 	! . . 
	set 4,(hl)		;223d	cb e6 	. . 
	ld hl,0c103h		;223f	21 03 c1 	! . . 
	res 4,(hl)		;2242	cb a6 	. . 
	ret			;2244	c9 	. 
sub_2245h:
	ld hl,0c10ch		;2245	21 0c c1 	! . . 
	res 4,(hl)		;2248	cb a6 	. . 
	ld hl,0c104h		;224a	21 04 c1 	! . . 
	set 4,(hl)		;224d	cb e6 	. . 
	ret			;224f	c9 	. 
l2250h:
	ld hl,0c10ch		;2250	21 0c c1 	! . . 
	set 4,(hl)		;2253	cb e6 	. . 
	ld hl,0c104h		;2255	21 04 c1 	! . . 
	res 4,(hl)		;2258	cb a6 	. . 
	ret			;225a	c9 	. 
sub_225bh:
	ld hl,0c10eh		;225b	21 0e c1 	! . . 
	res 5,(hl)		;225e	cb ae 	. . 
	ld hl,0c106h		;2260	21 06 c1 	! . . 
	set 5,(hl)		;2263	cb ee 	. . 
	ret			;2265	c9 	. 
l2266h:
	ld hl,0c10eh		;2266	21 0e c1 	! . . 
	set 5,(hl)		;2269	cb ee 	. . 
	ld hl,0c106h		;226b	21 06 c1 	! . . 
	res 5,(hl)		;226e	cb ae 	. . 
	ret			;2270	c9 	. 
sub_2271h:
	ld hl,0c10dh		;2271	21 0d c1 	! . . 
	res 4,(hl)		;2274	cb a6 	. . 
	ld hl,0c105h		;2276	21 05 c1 	! . . 
	set 4,(hl)		;2279	cb e6 	. . 
	ret			;227b	c9 	. 
l227ch:
	ld hl,0c10dh		;227c	21 0d c1 	! . . 
	set 4,(hl)		;227f	cb e6 	. . 
	ld hl,0c105h		;2281	21 05 c1 	! . . 
	res 4,(hl)		;2284	cb a6 	. . 
	ret			;2286	c9 	. 
sub_2287h:
	ld hl,0c10eh		;2287	21 0e c1 	! . . 
	res 4,(hl)		;228a	cb a6 	. . 
	ld hl,0c106h		;228c	21 06 c1 	! . . 
	set 4,(hl)		;228f	cb e6 	. . 
	ret			;2291	c9 	. 
l2292h:
	ld hl,0c10eh		;2292	21 0e c1 	! . . 
	set 4,(hl)		;2295	cb e6 	. . 
	ld hl,0c106h		;2297	21 06 c1 	! . . 
	res 4,(hl)		;229a	cb a6 	. . 
	ret			;229c	c9 	. 
sub_229dh:
	ld hl,0c10fh		;229d	21 0f c1 	! . . 
	res 4,(hl)		;22a0	cb a6 	. . 
	ld hl,0c107h		;22a2	21 07 c1 	! . . 
	set 4,(hl)		;22a5	cb e6 	. . 
	ret			;22a7	c9 	. 
l22a8h:
	ld hl,0c10fh		;22a8	21 0f c1 	! . . 
	set 4,(hl)		;22ab	cb e6 	. . 
	ld hl,0c107h		;22ad	21 07 c1 	! . . 
	res 4,(hl)		;22b0	cb a6 	. . 
	ret			;22b2	c9 	. 
sub_22b3h:
	ld hl,0c110h		;22b3	21 10 c1 	! . . 
	res 4,(hl)		;22b6	cb a6 	. . 
	ld hl,0c108h		;22b8	21 08 c1 	! . . 
	set 4,(hl)		;22bb	cb e6 	. . 
	ret			;22bd	c9 	. 
l22beh:
	ld hl,0c110h		;22be	21 10 c1 	! . . 
	set 4,(hl)		;22c1	cb e6 	. . 
	ld hl,0c108h		;22c3	21 08 c1 	! . . 
	res 4,(hl)		;22c6	cb a6 	. . 
	ret			;22c8	c9 	. 
sub_22c9h:
	ld hl,0c10fh		;22c9	21 0f c1 	! . . 
	res 6,(hl)		;22cc	cb b6 	. . 
	ld hl,0c107h		;22ce	21 07 c1 	! . . 
	set 6,(hl)		;22d1	cb f6 	. . 
	ret			;22d3	c9 	. 
l22d4h:
	ld hl,0c10fh		;22d4	21 0f c1 	! . . 
	set 6,(hl)		;22d7	cb f6 	. . 
	ld hl,0c107h		;22d9	21 07 c1 	! . . 
	res 6,(hl)		;22dc	cb b6 	. . 
	ret			;22de	c9 	. 
sub_22dfh:
	ld hl,0c107h		;22df	21 07 c1 	! . . 
	set 0,(hl)		;22e2	cb c6 	. . 
	ret			;22e4	c9 	. 
l22e5h:
	ld hl,0c107h		;22e5	21 07 c1 	! . . 
	res 0,(hl)		;22e8	cb 86 	. . 
	ret			;22ea	c9 	. 
sub_22ebh:
	ld hl,0c104h		;22eb	21 04 c1 	! . . 
	set 1,(hl)		;22ee	cb ce 	. . 
	ret			;22f0	c9 	. 
l22f1h:
	ld hl,0c104h		;22f1	21 04 c1 	! . . 
	res 1,(hl)		;22f4	cb 8e 	. . 
	ret			;22f6	c9 	. 
sub_22f7h:
	ld hl,0c103h		;22f7	21 03 c1 	! . . 
	set 1,(hl)		;22fa	cb ce 	. . 
	ret			;22fc	c9 	. 
l22fdh:
	ld hl,0c103h		;22fd	21 03 c1 	! . . 
	res 1,(hl)		;2300	cb 8e 	. . 
	ret			;2302	c9 	. 
sub_2303h:
	ld hl,0c102h		;2303	21 02 c1 	! . . 
	set 1,(hl)		;2306	cb ce 	. . 
	ret			;2308	c9 	. 
sub_2309h:
	ld hl,0c102h		;2309	21 02 c1 	! . . 
	res 1,(hl)		;230c	cb 8e 	. . 
	ret			;230e	c9 	. 
sub_230fh:
	ld hl,0c10bh		;230f	21 0b c1 	! . . 
	res 7,(hl)		;2312	cb be 	. . 
	ld hl,0c103h		;2314	21 03 c1 	! . . 
	set 7,(hl)		;2317	cb fe 	. . 
	ret			;2319	c9 	. 
sub_231ah:
	ld hl,0c10bh		;231a	21 0b c1 	! . . 
	set 7,(hl)		;231d	cb fe 	. . 
	ld hl,0c103h		;231f	21 03 c1 	! . . 
	res 7,(hl)		;2322	cb be 	. . 
	ret			;2324	c9 	. 
sub_2325h:
	ld hl,0c108h		;2325	21 08 c1 	! . . 
	set 0,(hl)		;2328	cb c6 	. . 
	ret			;232a	c9 	. 
sub_232bh:
	ld hl,0c108h		;232b	21 08 c1 	! . . 
	res 0,(hl)		;232e	cb 86 	. . 
	ret			;2330	c9 	. 
sub_2331h:
	ld hl,0c10dh		;2331	21 0d c1 	! . . 
	res 5,(hl)		;2334	cb ae 	. . 
	ld hl,0c105h		;2336	21 05 c1 	! . . 
	set 5,(hl)		;2339	cb ee 	. . 
	ret			;233b	c9 	. 
sub_233ch:
	ld hl,0c10dh		;233c	21 0d c1 	! . . 
	set 5,(hl)		;233f	cb ee 	. . 
	ld hl,0c105h		;2341	21 05 c1 	! . . 
	res 5,(hl)		;2344	cb ae 	. . 
	ret			;2346	c9 	. 
sub_2347h:
	ld hl,0c102h		;2347	21 02 c1 	! . . 
	set 0,(hl)		;234a	cb c6 	. . 
	ret			;234c	c9 	. 
sub_234dh:
	ld hl,0c102h		;234d	21 02 c1 	! . . 
	res 0,(hl)		;2350	cb 86 	. . 
	ret			;2352	c9 	. 
sub_2353h:
	ld hl,0c10ch		;2353	21 0c c1 	! . . 
	res 5,(hl)		;2356	cb ae 	. . 
	ld hl,0c104h		;2358	21 04 c1 	! . . 
	set 5,(hl)		;235b	cb ee 	. . 
	ret			;235d	c9 	. 
sub_235eh:
	ld hl,0c10ch		;235e	21 0c c1 	! . . 
	set 5,(hl)		;2361	cb ee 	. . 
	ld hl,0c104h		;2363	21 04 c1 	! . . 
	res 5,(hl)		;2366	cb ae 	. . 
	ret			;2368	c9 	. 
sub_2369h:
	ld hl,0c103h		;2369	21 03 c1 	! . . 
	set 0,(hl)		;236c	cb c6 	. . 
	ret			;236e	c9 	. 
sub_236fh:
	ld hl,0c103h		;236f	21 03 c1 	! . . 
	res 0,(hl)		;2372	cb 86 	. . 
	ret			;2374	c9 	. 
sub_2375h:
	ld hl,0c10bh		;2375	21 0b c1 	! . . 
	res 5,(hl)		;2378	cb ae 	. . 
	ld hl,0c103h		;237a	21 03 c1 	! . . 
	set 5,(hl)		;237d	cb ee 	. . 
	ret			;237f	c9 	. 
sub_2380h:
	ld hl,0c10bh		;2380	21 0b c1 	! . . 
	set 5,(hl)		;2383	cb ee 	. . 
	ld hl,0c103h		;2385	21 03 c1 	! . . 
	res 5,(hl)		;2388	cb ae 	. . 
	ret			;238a	c9 	. 
sub_238bh:
	ld hl,0c104h		;238b	21 04 c1 	! . . 
	set 0,(hl)		;238e	cb c6 	. . 
	ret			;2390	c9 	. 
sub_2391h:
	ld hl,0c104h		;2391	21 04 c1 	! . . 
	res 0,(hl)		;2394	cb 86 	. . 
	ret			;2396	c9 	. 
sub_2397h:
	ld hl,0c10ah		;2397	21 0a c1 	! . . 
	res 5,(hl)		;239a	cb ae 	. . 
	ld hl,0c102h		;239c	21 02 c1 	! . . 
	set 5,(hl)		;239f	cb ee 	. . 
	ret			;23a1	c9 	. 
sub_23a2h:
	ld hl,0c10ah		;23a2	21 0a c1 	! . . 
	set 5,(hl)		;23a5	cb ee 	. . 
	ld hl,0c102h		;23a7	21 02 c1 	! . . 
	res 5,(hl)		;23aa	cb ae 	. . 
	ret			;23ac	c9 	. 
sub_23adh:
	ld hl,0c105h		;23ad	21 05 c1 	! . . 
	set 0,(hl)		;23b0	cb c6 	. . 
	ret			;23b2	c9 	. 
sub_23b3h:
	ld hl,0c105h		;23b3	21 05 c1 	! . . 
	res 0,(hl)		;23b6	cb 86 	. . 
	ret			;23b8	c9 	. 
sub_23b9h:
	ld hl,0c109h		;23b9	21 09 c1 	! . . 
	res 5,(hl)		;23bc	cb ae 	. . 
	ld hl,0c101h		;23be	21 01 c1 	! . . 
	set 5,(hl)		;23c1	cb ee 	. . 
	ret			;23c3	c9 	. 
sub_23c4h:
	ld hl,0c109h		;23c4	21 09 c1 	! . . 
	set 5,(hl)		;23c7	cb ee 	. . 
	ld hl,0c101h		;23c9	21 01 c1 	! . . 
	res 5,(hl)		;23cc	cb ae 	. . 
	ret			;23ce	c9 	. 
sub_23cfh:
	ld hl,0c106h		;23cf	21 06 c1 	! . . 
	set 0,(hl)		;23d2	cb c6 	. . 
	ret			;23d4	c9 	. 
sub_23d5h:
	ld hl,0c106h		;23d5	21 06 c1 	! . . 
	res 0,(hl)		;23d8	cb 86 	. . 
	ret			;23da	c9 	. 
sub_23dbh:
	ld hl,0c10fh		;23db	21 0f c1 	! . . 
	res 5,(hl)		;23de	cb ae 	. . 
	ld hl,0c107h		;23e0	21 07 c1 	! . . 
	set 5,(hl)		;23e3	cb ee 	. . 
	ret			;23e5	c9 	. 
sub_23e6h:
	ld hl,0c10fh		;23e6	21 0f c1 	! . . 
	set 5,(hl)		;23e9	cb ee 	. . 
	ld hl,0c107h		;23eb	21 07 c1 	! . . 
	res 5,(hl)		;23ee	cb ae 	. . 
	ret			;23f0	c9 	. 
sub_23f1h:
	ld hl,0c10eh		;23f1	21 0e c1 	! . . 
	res 6,(hl)		;23f4	cb b6 	. . 
	ld hl,0c106h		;23f6	21 06 c1 	! . . 
	set 6,(hl)		;23f9	cb f6 	. . 
	ret			;23fb	c9 	. 
sub_23fch:
	ld hl,0c10eh		;23fc	21 0e c1 	! . . 
	set 6,(hl)		;23ff	cb f6 	. . 
	ld hl,0c106h		;2401	21 06 c1 	! . . 
	res 6,(hl)		;2404	cb b6 	. . 
	ret			;2406	c9 	. 
sub_2407h:
	ld hl,0c109h		;2407	21 09 c1 	! . . 
	res 6,(hl)		;240a	cb b6 	. . 
	ld hl,0c101h		;240c	21 01 c1 	! . . 
	set 6,(hl)		;240f	cb f6 	. . 
	ret			;2411	c9 	. 
sub_2412h:
	ld hl,0c109h		;2412	21 09 c1 	! . . 
	set 6,(hl)		;2415	cb f6 	. . 
	ld hl,0c101h		;2417	21 01 c1 	! . . 
	res 6,(hl)		;241a	cb b6 	. . 
	ret			;241c	c9 	. 
sub_241dh:
	ld hl,0c110h		;241d	21 10 c1 	! . . 
	res 7,(hl)		;2420	cb be 	. . 
	ld hl,0c108h		;2422	21 08 c1 	! . . 
	set 7,(hl)		;2425	cb fe 	. . 
	ret			;2427	c9 	. 
sub_2428h:
	ld hl,0c110h		;2428	21 10 c1 	! . . 
	set 7,(hl)		;242b	cb fe 	. . 
	ld hl,0c108h		;242d	21 08 c1 	! . . 
	res 7,(hl)		;2430	cb be 	. . 
	ret			;2432	c9 	. 
sub_2433h:
	ld hl,0c10ch		;2433	21 0c c1 	! . . 
	res 7,(hl)		;2436	cb be 	. . 
	ld hl,0c104h		;2438	21 04 c1 	! . . 
	set 7,(hl)		;243b	cb fe 	. . 
	ret			;243d	c9 	. 
sub_243eh:
	ld hl,0c10ch		;243e	21 0c c1 	! . . 
	set 7,(hl)		;2441	cb fe 	. . 
	ld hl,0c104h		;2443	21 04 c1 	! . . 
	res 7,(hl)		;2446	cb be 	. . 
	ret			;2448	c9 	. 
sub_2449h:
	ld hl,0c10bh		;2449	21 0b c1 	! . . 
	res 6,(hl)		;244c	cb b6 	. . 
	ld hl,0c103h		;244e	21 03 c1 	! . . 
	set 6,(hl)		;2451	cb f6 	. . 
	ret			;2453	c9 	. 
sub_2454h:
	ld hl,0c10bh		;2454	21 0b c1 	! . . 
	set 6,(hl)		;2457	cb f6 	. . 
	ld hl,0c103h		;2459	21 03 c1 	! . . 
	res 6,(hl)		;245c	cb b6 	. . 
	ret			;245e	c9 	. 
sub_245fh:
	ld hl,0c110h		;245f	21 10 c1 	! . . 
	res 5,(hl)		;2462	cb ae 	. . 
	ld hl,0c108h		;2464	21 08 c1 	! . . 
	set 5,(hl)		;2467	cb ee 	. . 
	ret			;2469	c9 	. 
sub_246ah:
	ld hl,0c110h		;246a	21 10 c1 	! . . 
	set 5,(hl)		;246d	cb ee 	. . 
	ld hl,0c108h		;246f	21 08 c1 	! . . 
	res 5,(hl)		;2472	cb ae 	. . 
	ret			;2474	c9 	. 
sub_2475h:
	ld hl,0c109h		;2475	21 09 c1 	! . . 
	res 0,(hl)		;2478	cb 86 	. . 
	ld hl,0c101h		;247a	21 01 c1 	! . . 
	set 0,(hl)		;247d	cb c6 	. . 
	ret			;247f	c9 	. 
sub_2480h:
	ld hl,0c109h		;2480	21 09 c1 	! . . 
	set 0,(hl)		;2483	cb c6 	. . 
	ld hl,0c101h		;2485	21 01 c1 	! . . 
	res 0,(hl)		;2488	cb 86 	. . 
	ret			;248a	c9 	. 
sub_248bh:
	ld hl,0c110h		;248b	21 10 c1 	! . . 
	res 6,(hl)		;248e	cb b6 	. . 
	ld hl,0c108h		;2490	21 08 c1 	! . . 
	set 6,(hl)		;2493	cb f6 	. . 
	ret			;2495	c9 	. 
sub_2496h:
	ld hl,0c110h		;2496	21 10 c1 	! . . 
	set 6,(hl)		;2499	cb f6 	. . 
	ld hl,0c108h		;249b	21 08 c1 	! . . 
	res 6,(hl)		;249e	cb b6 	. . 
	ret			;24a0	c9 	. 
sub_24a1h:
	ld hl,0c109h		;24a1	21 09 c1 	! . . 
	res 7,(hl)		;24a4	cb be 	. . 
	ld hl,0c101h		;24a6	21 01 c1 	! . . 
	set 7,(hl)		;24a9	cb fe 	. . 
	ld a,0ffh		;24ab	3e ff 	> . 
	ld (0c129h),a		;24ad	32 29 c1 	2 ) . 
	ret			;24b0	c9 	. 
sub_24b1h:
	ld hl,0c109h		;24b1	21 09 c1 	! . . 
	set 7,(hl)		;24b4	cb fe 	. . 
	ld hl,0c101h		;24b6	21 01 c1 	! . . 
	res 7,(hl)		;24b9	cb be 	. . 
	xor a			;24bb	af 	. 
	ld (0c129h),a		;24bc	32 29 c1 	2 ) . 
	ret			;24bf	c9 	. 
sub_24c0h:
	ld hl,0c10ah		;24c0	21 0a c1 	! . . 
	res 7,(hl)		;24c3	cb be 	. . 
	ld hl,0c102h		;24c5	21 02 c1 	! . . 
	set 7,(hl)		;24c8	cb fe 	. . 
	ret			;24ca	c9 	. 
sub_24cbh:
	ld hl,0c10ah		;24cb	21 0a c1 	! . . 
	set 7,(hl)		;24ce	cb fe 	. . 
	ld hl,0c102h		;24d0	21 02 c1 	! . . 
	res 7,(hl)		;24d3	cb be 	. . 
	ret			;24d5	c9 	. 
sub_24d6h:
	ld hl,0c10ch		;24d6	21 0c c1 	! . . 
	res 6,(hl)		;24d9	cb b6 	. . 
	ld hl,0c104h		;24db	21 04 c1 	! . . 
	set 6,(hl)		;24de	cb f6 	. . 
	ret			;24e0	c9 	. 
sub_24e1h:
	ld hl,0c10ch		;24e1	21 0c c1 	! . . 
	set 6,(hl)		;24e4	cb f6 	. . 
	ld hl,0c104h		;24e6	21 04 c1 	! . . 
	res 6,(hl)		;24e9	cb b6 	. . 
	ret			;24eb	c9 	. 
sub_24ech:
	ld hl,0c104h		;24ec	21 04 c1 	! . . 
	set 3,(hl)		;24ef	cb de 	. . 
	ret			;24f1	c9 	. 
sub_24f2h:
	ld hl,0c104h		;24f2	21 04 c1 	! . . 
	res 3,(hl)		;24f5	cb 9e 	. . 
	ret			;24f7	c9 	. 
sub_24f8h:
	ld hl,0c103h		;24f8	21 03 c1 	! . . 
	set 3,(hl)		;24fb	cb de 	. . 
	ret			;24fd	c9 	. 
sub_24feh:
	ld hl,0c103h		;24fe	21 03 c1 	! . . 
	res 3,(hl)		;2501	cb 9e 	. . 
	ret			;2503	c9 	. 
sub_2504h:
	ld hl,0c106h		;2504	21 06 c1 	! . . 
	set 3,(hl)		;2507	cb de 	. . 
	ret			;2509	c9 	. 
sub_250ah:
	ld hl,0c106h		;250a	21 06 c1 	! . . 
	res 3,(hl)		;250d	cb 9e 	. . 
	ret			;250f	c9 	. 
sub_2510h:
	ld hl,0c105h		;2510	21 05 c1 	! . . 
	set 3,(hl)		;2513	cb de 	. . 
	ret			;2515	c9 	. 
sub_2516h:
	ld hl,0c105h		;2516	21 05 c1 	! . . 
	res 3,(hl)		;2519	cb 9e 	. . 
	ret			;251b	c9 	. 
sub_251ch:
	di			;251c	f3 	. 
	ld hl,0c101h		;251d	21 01 c1 	! . . 
	set 2,(hl)		;2520	cb d6 	. . 
	ei			;2522	fb 	. 
	ret			;2523	c9 	. 
sub_2524h:
	di			;2524	f3 	. 
	ld hl,0c101h		;2525	21 01 c1 	! . . 
	res 2,(hl)		;2528	cb 96 	. . 
	ei			;252a	fb 	. 
	ret			;252b	c9 	. 
sub_252ch:
	di			;252c	f3 	. 
	ld hl,0c102h		;252d	21 02 c1 	! . . 
	set 2,(hl)		;2530	cb d6 	. . 
	ei			;2532	fb 	. 
	ret			;2533	c9 	. 
sub_2534h:
	di			;2534	f3 	. 
	ld hl,0c102h		;2535	21 02 c1 	! . . 
	res 2,(hl)		;2538	cb 96 	. . 
	ei			;253a	fb 	. 
	ret			;253b	c9 	. 
sub_253ch:
	di			;253c	f3 	. 
	ld hl,0c103h		;253d	21 03 c1 	! . . 
	set 2,(hl)		;2540	cb d6 	. . 
	ei			;2542	fb 	. 
	ret			;2543	c9 	. 
sub_2544h:
	di			;2544	f3 	. 
	ld hl,0c103h		;2545	21 03 c1 	! . . 
	res 2,(hl)		;2548	cb 96 	. . 
	ei			;254a	fb 	. 
	ret			;254b	c9 	. 
sub_254ch:
	di			;254c	f3 	. 
	ld hl,0c104h		;254d	21 04 c1 	! . . 
	set 2,(hl)		;2550	cb d6 	. . 
	ei			;2552	fb 	. 
	ret			;2553	c9 	. 
sub_2554h:
	di			;2554	f3 	. 
	ld hl,0c104h		;2555	21 04 c1 	! . . 
	res 2,(hl)		;2558	cb 96 	. . 
	ei			;255a	fb 	. 
	ret			;255b	c9 	. 
sub_255ch:
	di			;255c	f3 	. 
	ld hl,0c105h		;255d	21 05 c1 	! . . 
	set 2,(hl)		;2560	cb d6 	. . 
	ei			;2562	fb 	. 
	ret			;2563	c9 	. 
sub_2564h:
	di			;2564	f3 	. 
	ld hl,0c105h		;2565	21 05 c1 	! . . 
	res 2,(hl)		;2568	cb 96 	. . 
	ei			;256a	fb 	. 
	ret			;256b	c9 	. 
sub_256ch:
	di			;256c	f3 	. 
	ld hl,0c106h		;256d	21 06 c1 	! . . 
	set 2,(hl)		;2570	cb d6 	. . 
	ei			;2572	fb 	. 
	ret			;2573	c9 	. 
sub_2574h:
	di			;2574	f3 	. 
	ld hl,0c106h		;2575	21 06 c1 	! . . 
	res 2,(hl)		;2578	cb 96 	. . 
	ei			;257a	fb 	. 
	ret			;257b	c9 	. 
sub_257ch:
	di			;257c	f3 	. 
	ld hl,0c107h		;257d	21 07 c1 	! . . 
	set 2,(hl)		;2580	cb d6 	. . 
	ei			;2582	fb 	. 
	ret			;2583	c9 	. 
sub_2584h:
	di			;2584	f3 	. 
	ld hl,0c107h		;2585	21 07 c1 	! . . 
	res 2,(hl)		;2588	cb 96 	. . 
	ei			;258a	fb 	. 
	ret			;258b	c9 	. 
sub_258ch:
	di			;258c	f3 	. 
	ld hl,0c108h		;258d	21 08 c1 	! . . 
	set 2,(hl)		;2590	cb d6 	. . 
	ei			;2592	fb 	. 
	ret			;2593	c9 	. 
sub_2594h:
	di			;2594	f3 	. 
	ld hl,0c108h		;2595	21 08 c1 	! . . 
	res 2,(hl)		;2598	cb 96 	. . 
	ei			;259a	fb 	. 
	ret			;259b	c9 	. 
sub_259ch:
	di			;259c	f3 	. 
	ld hl,0c101h		;259d	21 01 c1 	! . . 
	set 3,(hl)		;25a0	cb de 	. . 
	ei			;25a2	fb 	. 
	ret			;25a3	c9 	. 
sub_25a4h:
	di			;25a4	f3 	. 
	ld hl,0c101h		;25a5	21 01 c1 	! . . 
	res 3,(hl)		;25a8	cb 9e 	. . 
	ei			;25aa	fb 	. 
	ret			;25ab	c9 	. 
sub_25ach:
	di			;25ac	f3 	. 
	ld hl,0c10ah		;25ad	21 0a c1 	! . . 
	res 3,(hl)		;25b0	cb 9e 	. . 
	ld hl,0c102h		;25b2	21 02 c1 	! . . 
	set 3,(hl)		;25b5	cb de 	. . 
	ei			;25b7	fb 	. 
	ret			;25b8	c9 	. 
sub_25b9h:
	di			;25b9	f3 	. 
	ld hl,0c10ah		;25ba	21 0a c1 	! . . 
	set 3,(hl)		;25bd	cb de 	. . 
	ld hl,0c102h		;25bf	21 02 c1 	! . . 
	res 3,(hl)		;25c2	cb 9e 	. . 
	ei			;25c4	fb 	. 
	ret			;25c5	c9 	. 
	di			;25c6	f3 	. 
	ld b,008h		;25c7	06 08 	. . 
	ld hl,0c101h		;25c9	21 01 c1 	! . . 
l25cch:
	ld a,004h		;25cc	3e 04 	> . 
	or (hl)			;25ce	b6 	. 
	ld (hl),a			;25cf	77 	w 
	inc hl			;25d0	23 	# 
	djnz l25cch		;25d1	10 f9 	. . 
	ld b,008h		;25d3	06 08 	. . 
	ld hl,0c109h		;25d5	21 09 c1 	! . . 
l25d8h:
	ld a,004h		;25d8	3e 04 	> . 
	or (hl)			;25da	b6 	. 
	ld (hl),a			;25db	77 	w 
	inc hl			;25dc	23 	# 
	djnz l25d8h		;25dd	10 f9 	. . 
	ld hl,0c101h		;25df	21 01 c1 	! . . 
	set 3,(hl)		;25e2	cb de 	. . 
	ld hl,0c102h		;25e4	21 02 c1 	! . . 
	set 3,(hl)		;25e7	cb de 	. . 
	ld hl,0c109h		;25e9	21 09 c1 	! . . 
	set 3,(hl)		;25ec	cb de 	. . 
	ld hl,0c10ah		;25ee	21 0a c1 	! . . 
	res 3,(hl)		;25f1	cb 9e 	. . 
	ei			;25f3	fb 	. 
	ret			;25f4	c9 	. 
	di			;25f5	f3 	. 
	ld b,008h		;25f6	06 08 	. . 
	ld hl,0c101h		;25f8	21 01 c1 	! . . 
l25fbh:
	ld a,0fbh		;25fb	3e fb 	> . 
	and (hl)			;25fd	a6 	. 
	ld (hl),a			;25fe	77 	w 
	inc hl			;25ff	23 	# 
	djnz l25fbh		;2600	10 f9 	. . 
	ld b,008h		;2602	06 08 	. . 
	ld hl,0c109h		;2604	21 09 c1 	! . . 
l2607h:
	ld a,004h		;2607	3e 04 	> . 
	or (hl)			;2609	b6 	. 
	ld (hl),a			;260a	77 	w 
	inc hl			;260b	23 	# 
	djnz l2607h		;260c	10 f9 	. . 
	ld hl,0c101h		;260e	21 01 c1 	! . . 
	res 3,(hl)		;2611	cb 9e 	. . 
	ld hl,0c102h		;2613	21 02 c1 	! . . 
	res 3,(hl)		;2616	cb 9e 	. . 
	ld hl,0c109h		;2618	21 09 c1 	! . . 
	set 3,(hl)		;261b	cb de 	. . 
	ld hl,0c10ah		;261d	21 0a c1 	! . . 
	set 3,(hl)		;2620	cb de 	. . 
	ei			;2622	fb 	. 
	ret			;2623	c9 	. 
sub_2624h:
	ld hl,0c101h		;2624	21 01 c1 	! . . 
	set 1,(hl)		;2627	cb ce 	. . 
	ret			;2629	c9 	. 
sub_262ah:
	ld hl,0c101h		;262a	21 01 c1 	! . . 
	res 1,(hl)		;262d	cb 8e 	. . 
	ret			;262f	c9 	. 
sub_2630h:
	ld hl,0c10dh		;2630	21 0d c1 	! . . 
	res 1,(hl)		;2633	cb 8e 	. . 
	ld hl,0c105h		;2635	21 05 c1 	! . . 
	set 1,(hl)		;2638	cb ce 	. . 
	ret			;263a	c9 	. 
sub_263bh:
	ld hl,0c10dh		;263b	21 0d c1 	! . . 
	set 7,(hl)		;263e	cb fe 	. . 
	ld hl,0c105h		;2640	21 05 c1 	! . . 
	res 1,(hl)		;2643	cb 8e 	. . 
	ret			;2645	c9 	. 
sub_2646h:
	ld hl,0c106h		;2646	21 06 c1 	! . . 
	set 1,(hl)		;2649	cb ce 	. . 
	ret			;264b	c9 	. 
sub_264ch:
	ld hl,0c106h		;264c	21 06 c1 	! . . 
	res 1,(hl)		;264f	cb 8e 	. . 
	ret			;2651	c9 	. 
sub_2652h:
	ld hl,0c107h		;2652	21 07 c1 	! . . 
	set 1,(hl)		;2655	cb ce 	. . 
	ret			;2657	c9 	. 
sub_2658h:
	ld hl,0c107h		;2658	21 07 c1 	! . . 
	res 1,(hl)		;265b	cb 8e 	. . 
	ret			;265d	c9 	. 
sub_265eh:
	ld hl,0c108h		;265e	21 08 c1 	! . . 
	set 1,(hl)		;2661	cb ce 	. . 
	ret			;2663	c9 	. 
sub_2664h:
	ld hl,0c108h		;2664	21 08 c1 	! . . 
	res 1,(hl)		;2667	cb 8e 	. . 
	ret			;2669	c9 	. 
sub_266ah:
	di			;266a	f3 	. 
	ld a,(0c007h)		;266b	3a 07 c0 	: . . 
	or 020h		;266e	f6 20 	.   
	ld (0c007h),a		;2670	32 07 c0 	2 . . 
	out (087h),a		;2673	d3 87 	. . 
	ei			;2675	fb 	. 
	call sub_24ech		;2676	cd ec 24 	. . $ 
	call sub_24f8h		;2679	cd f8 24 	. . $ 
	ret			;267c	c9 	. 
sub_267dh:
	di			;267d	f3 	. 
	ld a,(0c007h)		;267e	3a 07 c0 	: . . 
	and 0dfh		;2681	e6 df 	. . 
	ld (0c007h),a		;2683	32 07 c0 	2 . . 
	out (087h),a		;2686	d3 87 	. . 
	ei			;2688	fb 	. 
	call sub_24f2h		;2689	cd f2 24 	. . $ 
	call sub_24feh		;268c	cd fe 24 	. . $ 
	ret			;268f	c9 	. 
l2690h:
	call sub_267dh		;2690	cd 7d 26 	. } & 
	call sub_26a6h		;2693	cd a6 26 	. . & 
	call sub_266ah		;2696	cd 6a 26 	. j & 
	call sub_26a6h		;2699	cd a6 26 	. . & 
	call sub_267dh		;269c	cd 7d 26 	. } & 
	call sub_26a6h		;269f	cd a6 26 	. . & 
	call sub_266ah		;26a2	cd 6a 26 	. j & 
	ret			;26a5	c9 	. 
sub_26a6h:
	ld hl,l003bh+1		;26a6	21 3c 00 	! < . 
	ld (0c033h),hl		;26a9	22 33 c0 	" 3 . 
	ld a,0ffh		;26ac	3e ff 	> . 
	ld (0c035h),a		;26ae	32 35 c0 	2 5 . 
l26b1h:
	ld a,(0c035h)		;26b1	3a 35 c0 	: 5 . 
	and a			;26b4	a7 	. 
	jr nz,l26b1h		;26b5	20 fa 	  . 
	ret			;26b7	c9 	. 
sub_26b8h:
	di			;26b8	f3 	. 
	ld a,(0c101h)		;26b9	3a 01 c1 	: . . 
	and 080h		;26bc	e6 80 	. . 
	ld b,008h		;26be	06 08 	. . 
	ld hl,0c109h		;26c0	21 09 c1 	! . . 
l26c3h:
	ld (hl),0ffh		;26c3	36 ff 	6 . 
	inc hl			;26c5	23 	# 
	djnz l26c3h		;26c6	10 fb 	. . 
	cpl			;26c8	2f 	/ 
	ld hl,0c109h		;26c9	21 09 c1 	! . . 
	and (hl)			;26cc	a6 	. 
	ld (hl),a			;26cd	77 	w 
	ld b,008h		;26ce	06 08 	. . 
	ld hl,0c101h		;26d0	21 01 c1 	! . . 
l26d3h:
	ld (hl),000h		;26d3	36 00 	6 . 
	inc hl			;26d5	23 	# 
	djnz l26d3h		;26d6	10 fb 	. . 
	cpl			;26d8	2f 	/ 
	ld hl,0c101h		;26d9	21 01 c1 	! . . 
	or (hl)			;26dc	b6 	. 
	ld (hl),a			;26dd	77 	w 
	xor a			;26de	af 	. 
	ld (0c11bh),a		;26df	32 1b c1 	2 . . 
	ld a,(0c05bh)		;26e2	3a 5b c0 	: [ . 
	and a			;26e5	a7 	. 
	jp nz,l26efh		;26e6	c2 ef 26 	. . & 
	call sub_24ech		;26e9	cd ec 24 	. . $ 
	call sub_24f8h		;26ec	cd f8 24 	. . $ 
l26efh:
	ei			;26ef	fb 	. 
	ret			;26f0	c9 	. 
l26f1h:
	ld a,0ffh		;26f1	3e ff 	> . 
	ld (0c06ch),a		;26f3	32 6c c0 	2 l . 
	in a,(004h)		;26f6	db 04 	. . 
	bit 4,a		;26f8	cb 67 	. g 
	ret z			;26fa	c8 	. 
	xor a			;26fb	af 	. 
	ld (0c02fh),a		;26fc	32 2f c0 	2 / . 
	call sub_2bfdh		;26ff	cd fd 2b 	. . + 
	call sub_0edeh		;2702	cd de 0e 	. . . 
	call sub_2ff3h		;2705	cd f3 2f 	. . / 
	ld a,(0c0dbh)		;2708	3a db c0 	: . . 
	ld (0c063h),a		;270b	32 63 c0 	2 c . 
	ld a,(0c063h)		;270e	3a 63 c0 	: c . 
	or 0dfh		;2711	f6 df 	. . 
	cp 0dfh		;2713	fe df 	. . 
	jp nz,l2766h		;2715	c2 66 27 	. f ' 
	call sub_03d1h		;2718	cd d1 03 	. . . 
	call sub_0bd5h		;271b	cd d5 0b 	. . . 
	jp l2721h		;271e	c3 21 27 	. ! ' 
l2721h:
	ld hl,l0258h		;2721	21 58 02 	! X . 
	ld (0c033h),hl		;2724	22 33 c0 	" 3 . 
	ld a,0ffh		;2727	3e ff 	> . 
	ld (0c035h),a		;2729	32 35 c0 	2 5 . 
	ld (0c06dh),a		;272c	32 6d c0 	2 m . 
	xor a			;272f	af 	. 
	ld (0c0fah),a		;2730	32 fa c0 	2 . . 
	ld (0c068h),a		;2733	32 68 c0 	2 h . 
	call sub_27f6h		;2736	cd f6 27 	. . ' 
	ld (0c064h),a		;2739	32 64 c0 	2 d . 
l273ch:
	call sub_0d2fh		;273c	cd 2f 0d 	. / . 
	call sub_0c0ch		;273f	cd 0c 0c 	. . . 
	call sub_0ec9h		;2742	cd c9 0e 	. . . 
	ld a,(0c0fah)		;2745	3a fa c0 	: . . 
	and a			;2748	a7 	. 
	jp z,l273ch		;2749	ca 3c 27 	. < ' 
	ld a,(0c068h)		;274c	3a 68 c0 	: h . 
	and a			;274f	a7 	. 
	jp nz,l2766h		;2750	c2 66 27 	. f ' 
	ld a,(0c035h)		;2753	3a 35 c0 	: 5 . 
	and a			;2756	a7 	. 
	jp nz,l273ch		;2757	c2 3c 27 	. < ' 
	ld hl,l0064h		;275a	21 64 00 	! d . 
	ld (0c033h),hl		;275d	22 33 c0 	" 3 . 
	call sub_0bd5h		;2760	cd d5 0b 	. . . 
	jp l26f1h		;2763	c3 f1 26 	. . & 
l2766h:
	ld hl,001f4h		;2766	21 f4 01 	! . . 
	ld (0c02ah),a		;2769	32 2a c0 	2 * . 
	ld a,0ffh		;276c	3e ff 	> . 
	ld (0c03bh),a		;276e	32 3b c0 	2 ; . 
	xor a			;2771	af 	. 
	ld (0c06dh),a		;2772	32 6d c0 	2 m . 
	ld (0c057h),a		;2775	32 57 c0 	2 W . 
	ld (0c058h),a		;2778	32 58 c0 	2 X . 
	ret			;277b	c9 	. 
sub_277ch:
	di			;277c	f3 	. 
	ld a,(0c007h)		;277d	3a 07 c0 	: . . 
	or 010h		;2780	f6 10 	. . 
	ld (0c007h),a		;2782	32 07 c0 	2 . . 
	out (087h),a		;2785	d3 87 	. . 
	ei			;2787	fb 	. 
	ld hl,0012ch		;2788	21 2c 01 	! , . 
	ld (0c033h),hl		;278b	22 33 c0 	" 3 . 
	ld a,0ffh		;278e	3e ff 	> . 
	ld (0c035h),a		;2790	32 35 c0 	2 5 . 
l2793h:
	ld a,(0c035h)		;2793	3a 35 c0 	: 5 . 
	and a			;2796	a7 	. 
	jp nz,l2793h		;2797	c2 93 27 	. . ' 
	di			;279a	f3 	. 
	ld hl,0c03fh		;279b	21 3f c0 	! ? . 
	ld b,01ch		;279e	06 1c 	. . 
l27a0h:
	ld (hl),000h		;27a0	36 00 	6 . 
	inc hl			;27a2	23 	# 
	djnz l27a0h		;27a3	10 fb 	. . 
	ei			;27a5	fb 	. 
	ld a,0ffh		;27a6	3e ff 	> . 
	ld (0c03eh),a		;27a8	32 3e c0 	2 > . 
	xor a			;27ab	af 	. 
	ld (0c11bh),a		;27ac	32 1b c1 	2 . . 
	ld a,0ffh		;27af	3e ff 	> . 
	ld (0c03dh),a		;27b1	32 3d c0 	2 = . 
	ret			;27b4	c9 	. 
sub_27b5h:
	di			;27b5	f3 	. 
	xor a			;27b6	af 	. 
	ld (0c03eh),a		;27b7	32 3e c0 	2 > . 
	ld (0c03dh),a		;27ba	32 3d c0 	2 = . 
	ld a,(0c007h)		;27bd	3a 07 c0 	: . . 
	and 0efh		;27c0	e6 ef 	. . 
	ld (0c007h),a		;27c2	32 07 c0 	2 . . 
	out (087h),a		;27c5	d3 87 	. . 
	ld a,(0c05bh)		;27c7	3a 5b c0 	: [ . 
	and a			;27ca	a7 	. 
	jp nz,l27d1h		;27cb	c2 d1 27 	. . ' 
	call sub_3335h		;27ce	cd 35 33 	. 5 3 
l27d1h:
	ei			;27d1	fb 	. 
	ret			;27d2	c9 	. 
	ld hl,001f4h		;27d3	21 f4 01 	! . . 
	ld (0c02ah),hl		;27d6	22 2a c0 	" * . 
	call sub_03d1h		;27d9	cd d1 03 	. . . 
	ld a,0ffh		;27dc	3e ff 	> . 
	ld (0c03bh),a		;27de	32 3b c0 	2 ; . 
	xor a			;27e1	af 	. 
	ld (0c067h),a		;27e2	32 67 c0 	2 g . 
	ret			;27e5	c9 	. 
	xor a			;27e6	af 	. 
	ld (0c03bh),a		;27e7	32 3b c0 	2 ; . 
	ret			;27ea	c9 	. 
	ld a,0ffh		;27eb	3e ff 	> . 
	ld (0c03ch),a		;27ed	32 3c c0 	2 < . 
	ret			;27f0	c9 	. 
	xor a			;27f1	af 	. 
	ld (0c03ch),a		;27f2	32 3c c0 	2 < . 
	ret			;27f5	c9 	. 
sub_27f6h:
	ld a,07fh		;27f6	3e 7f 	>  
	call sub_30e4h		;27f8	cd e4 30 	. . 0 
	ret			;27fb	c9 	. 
	ld a,080h		;27fc	3e 80 	> . 
	call sub_3099h		;27fe	cd 99 30 	. . 0 
	ret			;2801	c9 	. 
	ld a,0fbh		;2802	3e fb 	> . 
	call sub_30e4h		;2804	cd e4 30 	. . 0 
	ret			;2807	c9 	. 
	ld a,004h		;2808	3e 04 	> . 
	call sub_3099h		;280a	cd 99 30 	. . 0 
	ret			;280d	c9 	. 
sub_280eh:
	call sub_0393h		;280e	cd 93 03 	. . . 
	call sub_058fh		;2811	cd 8f 05 	. . . 
	ret			;2814	c9 	. 
sub_2815h:
	call sub_03b2h		;2815	cd b2 03 	. . . 
	ret			;2818	c9 	. 
	ld a,0ffh		;2819	3e ff 	> . 
	ld (0c069h),a		;281b	32 69 c0 	2 i . 
	ret			;281e	c9 	. 
	xor a			;281f	af 	. 
	ld (0c069h),a		;2820	32 69 c0 	2 i . 
	ret			;2823	c9 	. 
	call sub_040fh		;2824	cd 0f 04 	. . . 
	call sub_042eh		;2827	cd 2e 04 	. . . 
	ret			;282a	c9 	. 
sub_282bh:
	call sub_0317h		;282b	cd 17 03 	. . . 
	call sub_05a7h		;282e	cd a7 05 	. . . 
	ret			;2831	c9 	. 
sub_2832h:
	call sub_03f0h		;2832	cd f0 03 	. . . 
	call sub_055fh		;2835	cd 5f 05 	. _ . 
	call sub_0577h		;2838	cd 77 05 	. w . 
	call sub_058fh		;283b	cd 8f 05 	. . . 
	call sub_05a7h		;283e	cd a7 05 	. . . 
	ret			;2841	c9 	. 
	ld a,0ffh		;2842	3e ff 	> . 
	ld (0c05dh),a		;2844	32 5d c0 	2 ] . 
	ret			;2847	c9 	. 
	xor a			;2848	af 	. 
	ld (0c05dh),a		;2849	32 5d c0 	2 ] . 
	ret			;284c	c9 	. 
	ld a,0ffh		;284d	3e ff 	> . 
	ld (0c05ch),a		;284f	32 5c c0 	2 \ . 
	ret			;2852	c9 	. 
	xor a			;2853	af 	. 
	ld (0c05ch),a		;2854	32 5c c0 	2 \ . 
	ret			;2857	c9 	. 
	ld a,0ffh		;2858	3e ff 	> . 
	ld (0c03dh),a		;285a	32 3d c0 	2 = . 
	ret			;285d	c9 	. 
	xor a			;285e	af 	. 
	ld (0c03dh),a		;285f	32 3d c0 	2 = . 
	ret			;2862	c9 	. 
sub_2863h:
	call sub_0355h		;2863	cd 55 03 	. U . 
	ret			;2866	c9 	. 
sub_2867h:
	call sub_0374h		;2867	cd 74 03 	. t . 
	ret			;286a	c9 	. 
l286bh:
	ld a,(0c05bh)		;286b	3a 5b c0 	: [ . 
	and a			;286e	a7 	. 
	ret z			;286f	c8 	. 
	call sub_0466h		;2870	cd 66 04 	. f . 
	call sub_289dh		;2873	cd 9d 28 	. . ( 
	ret			;2876	c9 	. 
	ld a,(0c05bh)		;2877	3a 5b c0 	: [ . 
	and a			;287a	a7 	. 
	ret z			;287b	c8 	. 
	call sub_04c0h		;287c	cd c0 04 	. . . 
	ret			;287f	c9 	. 
	call l0514h		;2880	cd 14 05 	. . . 
	ret			;2883	c9 	. 
	ld a,(0c05bh)		;2884	3a 5b c0 	: [ . 
	and a			;2887	a7 	. 
	ret z			;2888	c8 	. 
	call sub_0493h		;2889	cd 93 04 	. . . 
	call sub_28d9h		;288c	cd d9 28 	. . ( 
	ret			;288f	c9 	. 
	ld a,(0c05bh)		;2890	3a 5b c0 	: [ . 
	and a			;2893	a7 	. 
	ret z			;2894	c8 	. 
	call sub_04eah		;2895	cd ea 04 	. . . 
	ret			;2898	c9 	. 
	call sub_0539h		;2899	cd 39 05 	. 9 . 
	ret			;289c	c9 	. 
sub_289dh:
	ld hl,l0064h		;289d	21 64 00 	! d . 
	ld (0c033h),hl		;28a0	22 33 c0 	" 3 . 
	ld a,0ffh		;28a3	3e ff 	> . 
	ld (0c035h),a		;28a5	32 35 c0 	2 5 . 
l28a8h:
	call sub_2bedh		;28a8	cd ed 2b 	. . + 
	call sub_2fe7h		;28ab	cd e7 2f 	. . / 
	ld a,(0c0dah)		;28ae	3a da c0 	: . . 
	bit 3,a		;28b1	cb 5f 	. _ 
	jp z,l28c0h		;28b3	ca c0 28 	. . ( 
	call sub_0d2fh		;28b6	cd 2f 0d 	. / . 
	ld a,(0c035h)		;28b9	3a 35 c0 	: 5 . 
	and a			;28bc	a7 	. 
	jp nz,l28a8h		;28bd	c2 a8 28 	. . ( 
l28c0h:
	call sub_04c0h		;28c0	cd c0 04 	. . . 
	ld hl,l0064h		;28c3	21 64 00 	! d . 
	ld (0c033h),hl		;28c6	22 33 c0 	" 3 . 
	ld a,0ffh		;28c9	3e ff 	> . 
	ld (0c035h),a		;28cb	32 35 c0 	2 5 . 
l28ceh:
	call sub_0d2fh		;28ce	cd 2f 0d 	. / . 
	ld a,(0c035h)		;28d1	3a 35 c0 	: 5 . 
	and a			;28d4	a7 	. 
	jp nz,l28ceh		;28d5	c2 ce 28 	. . ( 
	ret			;28d8	c9 	. 
sub_28d9h:
	ld hl,l0064h		;28d9	21 64 00 	! d . 
	ld (0c033h),hl		;28dc	22 33 c0 	" 3 . 
	ld a,0ffh		;28df	3e ff 	> . 
	ld (0c035h),a		;28e1	32 35 c0 	2 5 . 
l28e4h:
	call sub_2bedh		;28e4	cd ed 2b 	. . + 
	call sub_2fe7h		;28e7	cd e7 2f 	. . / 
	ld a,(0c0dah)		;28ea	3a da c0 	: . . 
	bit 4,a		;28ed	cb 67 	. g 
	jp z,l28fch		;28ef	ca fc 28 	. . ( 
	call sub_0d2fh		;28f2	cd 2f 0d 	. / . 
	ld a,(0c035h)		;28f5	3a 35 c0 	: 5 . 
	and a			;28f8	a7 	. 
	jp nz,l28e4h		;28f9	c2 e4 28 	. . ( 
l28fch:
	call sub_04eah		;28fc	cd ea 04 	. . . 
	ld hl,l0064h		;28ff	21 64 00 	! d . 
	ld (0c033h),hl		;2902	22 33 c0 	" 3 . 
	ld a,0ffh		;2905	3e ff 	> . 
	ld (0c035h),a		;2907	32 35 c0 	2 5 . 
l290ah:
	call sub_0d2fh		;290a	cd 2f 0d 	. / . 
	ld a,(0c035h)		;290d	3a 35 c0 	: 5 . 
	and a			;2910	a7 	. 
	jp nz,l290ah		;2911	c2 0a 29 	. . ) 
	ret			;2914	c9 	. 
	ld a,(l003bh)		;2915	3a 3b 00 	: ; . 
	or 0f0h		;2918	f6 f0 	. . 
	jp sub_0afah		;291a	c3 fa 0a 	. . . 
	ld a,0a5h		;291d	3e a5 	> . 
	ld (0c039h),a		;291f	32 39 c0 	2 9 . 
	ret			;2922	c9 	. 
	in a,(004h)		;2923	db 04 	. . 
	or 0f0h		;2925	f6 f0 	. . 
	ld (0c0feh),a		;2927	32 fe c0 	2 . . 
	jp sub_0afah		;292a	c3 fa 0a 	. . . 
	pop hl			;292d	e1 	. 
	ld a,0ffh		;292e	3e ff 	> . 
	ld (0c05bh),a		;2930	32 5b c0 	2 [ . 
	call sub_31deh		;2933	cd de 31 	. . 1 
	call sub_267dh		;2936	cd 7d 26 	. } & 
	call sub_26b8h		;2939	cd b8 26 	. . & 
	call sub_24f2h		;293c	cd f2 24 	. . $ 
	call sub_24feh		;293f	cd fe 24 	. . $ 
	call sub_24b1h		;2942	cd b1 24 	. . $ 
	jp l2950h		;2945	c3 50 29 	. P ) 
	xor a			;2948	af 	. 
	ld (0c05bh),a		;2949	32 5b c0 	2 [ . 
	di			;294c	f3 	. 
	jp l0100h		;294d	c3 00 01 	. . . 
l2950h:
	ld a,0ffh		;2950	3e ff 	> . 
	ld (0c035h),a		;2952	32 35 c0 	2 5 . 
	ld hl,l0001h		;2955	21 01 00 	! . . 
	ld (0c033h),hl		;2958	22 33 c0 	" 3 . 
l295bh:
	call sub_297fh		;295b	cd 7f 29 	.  ) 
	call sub_0d2fh		;295e	cd 2f 0d 	. / . 
	call sub_10ffh		;2961	cd ff 10 	. . . 
	in a,(003h)		;2964	db 03 	. . 
	bit 2,a		;2966	cb 57 	. W 
	call z,sub_0e76h		;2968	cc 76 0e 	. v . 
	in a,(003h)		;296b	db 03 	. . 
	bit 3,a		;296d	cb 5f 	. _ 
	call z,sub_0e30h		;296f	cc 30 0e 	. 0 . 
	ld a,(0c0dfh)		;2972	3a df c0 	: . . 
	or 0ech		;2975	f6 ec 	. . 
	cp 0ffh		;2977	fe ff 	. . 
	call nz,sub_0dcbh		;2979	c4 cb 0d 	. . . 
	jp l295bh		;297c	c3 5b 29 	. [ ) 
sub_297fh:
	ld a,(0c035h)		;297f	3a 35 c0 	: 5 . 
	and a			;2982	a7 	. 
	ret nz			;2983	c0 	. 
	call sub_2bach		;2984	cd ac 2b 	. . + 
	ld a,0ffh		;2987	3e ff 	> . 
	ld (0c035h),a		;2989	32 35 c0 	2 5 . 
	ld hl,l0001h		;298c	21 01 00 	! . . 
	ld (0c033h),hl		;298f	22 33 c0 	" 3 . 
	ret			;2992	c9 	. 
sub_2993h:
	ld a,05fh		;2993	3e 5f 	> _ 
	ld (0c0feh),a		;2995	32 fe c0 	2 . . 
	call sub_0afah		;2998	cd fa 0a 	. . . 
	ld hl,00190h		;299b	21 90 01 	! . . 
	ld (0c033h),hl		;299e	22 33 c0 	" 3 . 
	ld a,0ffh		;29a1	3e ff 	> . 
	ld (0c035h),a		;29a3	32 35 c0 	2 5 . 
l29a6h:
	ld a,(0c035h)		;29a6	3a 35 c0 	: 5 . 
	and a			;29a9	a7 	. 
	jp nz,l29a6h		;29aa	c2 a6 29 	. . ) 
	ret			;29ad	c9 	. 
l29aeh:
	call sub_336bh		;29ae	cd 6b 33 	. k 3 
l29b1h:
	in a,(004h)		;29b1	db 04 	. . 
	bit 7,a		;29b3	cb 7f 	.  
	jp z,l29b1h		;29b5	ca b1 29 	. . ) 
	di			;29b8	f3 	. 
	call sub_31deh		;29b9	cd de 31 	. . 1 
	jp l0100h		;29bc	c3 00 01 	. . . 
l29bfh:
	call sub_2475h		;29bf	cd 75 24 	. u $ 
	call sub_2347h		;29c2	cd 47 23 	. G # 
	call sub_2369h		;29c5	cd 69 23 	. i # 
	call sub_238bh		;29c8	cd 8b 23 	. . # 
	call sub_23adh		;29cb	cd ad 23 	. . # 
	call sub_23cfh		;29ce	cd cf 23 	. . # 
	call sub_22dfh		;29d1	cd df 22 	. . " 
	call sub_2325h		;29d4	cd 25 23 	. % # 
	call sub_2993h		;29d7	cd 93 29 	. . ) 
	call sub_2480h		;29da	cd 80 24 	. . $ 
	call sub_234dh		;29dd	cd 4d 23 	. M # 
	call sub_236fh		;29e0	cd 6f 23 	. o # 
	call sub_2391h		;29e3	cd 91 23 	. . # 
	call sub_23b3h		;29e6	cd b3 23 	. . # 
	call sub_23d5h		;29e9	cd d5 23 	. . # 
	call l22e5h		;29ec	cd e5 22 	. . " 
	call sub_232bh		;29ef	cd 2b 23 	. + # 
	call sub_2624h		;29f2	cd 24 26 	. $ & 
	call sub_2303h		;29f5	cd 03 23 	. . # 
	call sub_22f7h		;29f8	cd f7 22 	. . " 
	call sub_22ebh		;29fb	cd eb 22 	. . " 
	call sub_2630h		;29fe	cd 30 26 	. 0 & 
	call sub_2646h		;2a01	cd 46 26 	. F & 
	call sub_2652h		;2a04	cd 52 26 	. R & 
	call sub_265eh		;2a07	cd 5e 26 	. ^ & 
	call sub_2993h		;2a0a	cd 93 29 	. . ) 
	call sub_262ah		;2a0d	cd 2a 26 	. * & 
	call sub_2309h		;2a10	cd 09 23 	. . # 
	call l22fdh		;2a13	cd fd 22 	. . " 
	call l22f1h		;2a16	cd f1 22 	. . " 
	call sub_263bh		;2a19	cd 3b 26 	. ; & 
	call sub_264ch		;2a1c	cd 4c 26 	. L & 
	call sub_2658h		;2a1f	cd 58 26 	. X & 
	call sub_2664h		;2a22	cd 64 26 	. d & 
	call sub_251ch		;2a25	cd 1c 25 	. . % 
	call sub_252ch		;2a28	cd 2c 25 	. , % 
	call sub_253ch		;2a2b	cd 3c 25 	. < % 
	call sub_254ch		;2a2e	cd 4c 25 	. L % 
	call sub_255ch		;2a31	cd 5c 25 	. \ % 
	call sub_256ch		;2a34	cd 6c 25 	. l % 
	call sub_257ch		;2a37	cd 7c 25 	. | % 
	call sub_258ch		;2a3a	cd 8c 25 	. . % 
	call sub_2993h		;2a3d	cd 93 29 	. . ) 
	call sub_2524h		;2a40	cd 24 25 	. $ % 
	call sub_2534h		;2a43	cd 34 25 	. 4 % 
	call sub_2544h		;2a46	cd 44 25 	. D % 
	call sub_2554h		;2a49	cd 54 25 	. T % 
	call sub_2564h		;2a4c	cd 64 25 	. d % 
	call sub_2574h		;2a4f	cd 74 25 	. t % 
	call sub_2584h		;2a52	cd 84 25 	. . % 
	call sub_2594h		;2a55	cd 94 25 	. . % 
	call sub_259ch		;2a58	cd 9c 25 	. . % 
	call sub_25ach		;2a5b	cd ac 25 	. . % 
	call sub_24f8h		;2a5e	cd f8 24 	. . $ 
	call sub_24ech		;2a61	cd ec 24 	. . $ 
	call sub_2504h		;2a64	cd 04 25 	. . % 
	call sub_2510h		;2a67	cd 10 25 	. . % 
	call sub_2993h		;2a6a	cd 93 29 	. . ) 
	call sub_25a4h		;2a6d	cd a4 25 	. . % 
	call sub_25b9h		;2a70	cd b9 25 	. . % 
	call sub_24feh		;2a73	cd fe 24 	. . $ 
	call sub_24f2h		;2a76	cd f2 24 	. . $ 
	call sub_250ah		;2a79	cd 0a 25 	. . % 
	call sub_2516h		;2a7c	cd 16 25 	. . % 
	call 02203h		;2a7f	cd 03 22 	. . " 
	call sub_2219h		;2a82	cd 19 22 	. . " 
	call sub_222fh		;2a85	cd 2f 22 	. / " 
	call sub_2245h		;2a88	cd 45 22 	. E " 
	call sub_2271h		;2a8b	cd 71 22 	. q " 
	call sub_2287h		;2a8e	cd 87 22 	. . " 
	call sub_229dh		;2a91	cd 9d 22 	. . " 
	call sub_22b3h		;2a94	cd b3 22 	. . " 
	call sub_2993h		;2a97	cd 93 29 	. . ) 
	call sub_220eh		;2a9a	cd 0e 22 	. . " 
	call l2224h		;2a9d	cd 24 22 	. $ " 
	call l223ah		;2aa0	cd 3a 22 	. : " 
	call l2250h		;2aa3	cd 50 22 	. P " 
	call l227ch		;2aa6	cd 7c 22 	. | " 
	call l2292h		;2aa9	cd 92 22 	. . " 
	call l22a8h		;2aac	cd a8 22 	. . " 
	call l22beh		;2aaf	cd be 22 	. . " 
	call sub_23b9h		;2ab2	cd b9 23 	. . # 
	call sub_2397h		;2ab5	cd 97 23 	. . # 
	call sub_2375h		;2ab8	cd 75 23 	. u # 
	call sub_2353h		;2abb	cd 53 23 	. S # 
	call sub_2331h		;2abe	cd 31 23 	. 1 # 
	call sub_225bh		;2ac1	cd 5b 22 	. [ " 
	call sub_23dbh		;2ac4	cd db 23 	. . # 
	call sub_245fh		;2ac7	cd 5f 24 	. _ $ 
	call sub_2993h		;2aca	cd 93 29 	. . ) 
	call sub_23c4h		;2acd	cd c4 23 	. . # 
	call sub_23a2h		;2ad0	cd a2 23 	. . # 
	call sub_2380h		;2ad3	cd 80 23 	. . # 
	call sub_235eh		;2ad6	cd 5e 23 	. ^ # 
	call sub_233ch		;2ad9	cd 3c 23 	. < # 
	call l2266h		;2adc	cd 66 22 	. f " 
	call sub_23e6h		;2adf	cd e6 23 	. . # 
	call sub_246ah		;2ae2	cd 6a 24 	. j $ 
	call sub_2407h		;2ae5	cd 07 24 	. . $ 
	call sub_2449h		;2ae8	cd 49 24 	. I $ 
	call sub_24d6h		;2aeb	cd d6 24 	. . $ 
	call sub_23f1h		;2aee	cd f1 23 	. . # 
	call sub_22c9h		;2af1	cd c9 22 	. . " 
	call sub_248bh		;2af4	cd 8b 24 	. . $ 
	call sub_2993h		;2af7	cd 93 29 	. . ) 
	call sub_2412h		;2afa	cd 12 24 	. . $ 
	call sub_2454h		;2afd	cd 54 24 	. T $ 
	call sub_24e1h		;2b00	cd e1 24 	. . $ 
	call sub_23fch		;2b03	cd fc 23 	. . # 
	call l22d4h		;2b06	cd d4 22 	. . " 
	call sub_2496h		;2b09	cd 96 24 	. . $ 
	call sub_24a1h		;2b0c	cd a1 24 	. . $ 
	call sub_24c0h		;2b0f	cd c0 24 	. . $ 
	call sub_230fh		;2b12	cd 0f 23 	. . # 
	call sub_2433h		;2b15	cd 33 24 	. 3 $ 
	call sub_241dh		;2b18	cd 1d 24 	. . $ 
	call sub_2993h		;2b1b	cd 93 29 	. . ) 
	call sub_24b1h		;2b1e	cd b1 24 	. . $ 
	call sub_24cbh		;2b21	cd cb 24 	. . $ 
	call sub_231ah		;2b24	cd 1a 23 	. . # 
	call sub_243eh		;2b27	cd 3e 24 	. > $ 
	call sub_2428h		;2b2a	cd 28 24 	. ( $ 
	jp l29bfh		;2b2d	c3 bf 29 	. . ) 
sub_2b30h:
	call sub_2b88h		;2b30	cd 88 2b 	. . + 
	call sub_2b88h		;2b33	cd 88 2b 	. . + 
	call sub_277ch		;2b36	cd 7c 27 	. | ' 
	call sub_2b88h		;2b39	cd 88 2b 	. . + 
	call sub_2863h		;2b3c	cd 63 28 	. c ( 
	call sub_2b88h		;2b3f	cd 88 2b 	. . + 
	call sub_2867h		;2b42	cd 67 28 	. g ( 
	call sub_2b88h		;2b45	cd 88 2b 	. . + 
	call sub_282bh		;2b48	cd 2b 28 	. + ( 
	call sub_2b88h		;2b4b	cd 88 2b 	. . + 
	call sub_280eh		;2b4e	cd 0e 28 	. . ( 
	call sub_2b88h		;2b51	cd 88 2b 	. . + 
	call sub_2815h		;2b54	cd 15 28 	. . ( 
	call sub_2b88h		;2b57	cd 88 2b 	. . + 
	call sub_2832h		;2b5a	cd 32 28 	. 2 ( 
	call sub_2b88h		;2b5d	cd 88 2b 	. . + 
	call sub_0466h		;2b60	cd 66 04 	. f . 
	call sub_289dh		;2b63	cd 9d 28 	. . ( 
	call l0514h		;2b66	cd 14 05 	. . . 
	call sub_2b88h		;2b69	cd 88 2b 	. . + 
	call sub_0493h		;2b6c	cd 93 04 	. . . 
	call sub_28d9h		;2b6f	cd d9 28 	. . ( 
	call sub_0539h		;2b72	cd 39 05 	. 9 . 
	call sub_2b88h		;2b75	cd 88 2b 	. . + 
	call sub_27b5h		;2b78	cd b5 27 	. . ' 
	di			;2b7b	f3 	. 
	xor a			;2b7c	af 	. 
	ld (0c0feh),a		;2b7d	32 fe c0 	2 . . 
	ld hl,02202h		;2b80	21 02 22 	! . " 
	ld (0c0ffh),hl		;2b83	22 ff c0 	" . . 
	ei			;2b86	fb 	. 
	ret			;2b87	c9 	. 
sub_2b88h:
	ld hl,l00c8h		;2b88	21 c8 00 	! . . 
	ld (0c033h),hl		;2b8b	22 33 c0 	" 3 . 
	ld a,0ffh		;2b8e	3e ff 	> . 
	ld (0c035h),a		;2b90	32 35 c0 	2 5 . 
l2b93h:
	ld a,(0c035h)		;2b93	3a 35 c0 	: 5 . 
	and a			;2b96	a7 	. 
	ret z			;2b97	c8 	. 
	call sub_0d2fh		;2b98	cd 2f 0d 	. / . 
	jp l2b93h		;2b9b	c3 93 2b 	. . + 
sub_2b9eh:
	in a,(003h)		;2b9e	db 03 	. . 
	ld hl,0c0f4h		;2ba0	21 f4 c0 	! . . 
	cpl			;2ba3	2f 	/ 
	ld (hl),a			;2ba4	77 	w 
	cpl			;2ba5	2f 	/ 
	inc hl			;2ba6	23 	# 
	or (hl)			;2ba7	b6 	. 
	ld (0c0dfh),a		;2ba8	32 df c0 	2 . . 
	ret			;2bab	c9 	. 
sub_2bach:
	in a,(003h)		;2bac	db 03 	. . 
	ld hl,0c0f4h		;2bae	21 f4 c0 	! . . 
	cpl			;2bb1	2f 	/ 
	ld (hl),a			;2bb2	77 	w 
	cpl			;2bb3	2f 	/ 
	inc hl			;2bb4	23 	# 
	or (hl)			;2bb5	b6 	. 
	ld (0c0dfh),a		;2bb6	32 df c0 	2 . . 
	ld hl,(0c0e2h)		;2bb9	2a e2 c0 	* . . 
	jp (hl)			;2bbc	e9 	. 
l2bbdh:
	ld a,001h		;2bbd	3e 01 	> . 
	out (082h),a		;2bbf	d3 82 	. . 
	ld hl,l2c0dh		;2bc1	21 0d 2c 	! . , 
	ld (0c0e2h),hl		;2bc4	22 e2 c0 	" . . 
	ld a,001h		;2bc7	3e 01 	> . 
	ld (0c0fbh),a		;2bc9	32 fb c0 	2 . . 
	ret			;2bcc	c9 	. 
	ld a,002h		;2bcd	3e 02 	> . 
	out (082h),a		;2bcf	d3 82 	. . 
	ld hl,l2c40h		;2bd1	21 40 2c 	! @ , 
	ld (0c0e2h),hl		;2bd4	22 e2 c0 	" . . 
	ld a,001h		;2bd7	3e 01 	> . 
	ld (0c0fbh),a		;2bd9	32 fb c0 	2 . . 
	ret			;2bdc	c9 	. 
	ld a,004h		;2bdd	3e 04 	> . 
	out (082h),a		;2bdf	d3 82 	. . 
	ld hl,l2c73h		;2be1	21 73 2c 	! s , 
	ld (0c0e2h),hl		;2be4	22 e2 c0 	" . . 
	ld a,001h		;2be7	3e 01 	> . 
	ld (0c0fbh),a		;2be9	32 fb c0 	2 . . 
	ret			;2bec	c9 	. 
sub_2bedh:
	ld a,008h		;2bed	3e 08 	> . 
	out (082h),a		;2bef	d3 82 	. . 
	ld hl,l2ca6h		;2bf1	21 a6 2c 	! . , 
	ld (0c0e2h),hl		;2bf4	22 e2 c0 	" . . 
	ld a,001h		;2bf7	3e 01 	> . 
	ld (0c0fbh),a		;2bf9	32 fb c0 	2 . . 
	ret			;2bfc	c9 	. 
sub_2bfdh:
	ld a,010h		;2bfd	3e 10 	> . 
	out (082h),a		;2bff	d3 82 	. . 
	ld hl,l2cd9h		;2c01	21 d9 2c 	! . , 
	ld (0c0e2h),hl		;2c04	22 e2 c0 	" . . 
	ld a,001h		;2c07	3e 01 	> . 
	ld (0c0fbh),a		;2c09	32 fb c0 	2 . . 
	ret			;2c0c	c9 	. 
l2c0dh:
	ld a,(0c0fbh)		;2c0d	3a fb c0 	: . . 
	and a			;2c10	a7 	. 
	jp z,l2c19h		;2c11	ca 19 2c 	. . , 
	dec a			;2c14	3d 	= 
	ld (0c0fbh),a		;2c15	32 fb c0 	2 . . 
	ret			;2c18	c9 	. 
l2c19h:
	ld a,001h		;2c19	3e 01 	> . 
	ld (0c0fbh),a		;2c1b	32 fb c0 	2 . . 
	ld a,0ffh		;2c1e	3e ff 	> . 
	ld (0c0f6h),a		;2c20	32 f6 c0 	2 . . 
	in a,(002h)		;2c23	db 02 	. . 
	ld hl,0c0e4h		;2c25	21 e4 c0 	! . . 
	cpl			;2c28	2f 	/ 
	ld (hl),a			;2c29	77 	w 
	cpl			;2c2a	2f 	/ 
	inc hl			;2c2b	23 	# 
	or (hl)			;2c2c	b6 	. 
	ld (0c0d7h),a		;2c2d	32 d7 c0 	2 . . 
	cp 0ffh		;2c30	fe ff 	. . 
	call nz,sub_2d0ch		;2c32	c4 0c 2d 	. . - 
	ld a,002h		;2c35	3e 02 	> . 
	out (082h),a		;2c37	d3 82 	. . 
	ld hl,l2c40h		;2c39	21 40 2c 	! @ , 
	ld (0c0e2h),hl		;2c3c	22 e2 c0 	" . . 
	ret			;2c3f	c9 	. 
l2c40h:
	ld a,(0c0fbh)		;2c40	3a fb c0 	: . . 
	and a			;2c43	a7 	. 
	jp z,l2c4ch		;2c44	ca 4c 2c 	. L , 
	dec a			;2c47	3d 	= 
	ld (0c0fbh),a		;2c48	32 fb c0 	2 . . 
	ret			;2c4b	c9 	. 
l2c4ch:
	ld a,001h		;2c4c	3e 01 	> . 
	ld (0c0fbh),a		;2c4e	32 fb c0 	2 . . 
	ld a,0ffh		;2c51	3e ff 	> . 
	ld (0c0f7h),a		;2c53	32 f7 c0 	2 . . 
	in a,(002h)		;2c56	db 02 	. . 
	ld hl,0c0e6h		;2c58	21 e6 c0 	! . . 
	cpl			;2c5b	2f 	/ 
	ld (hl),a			;2c5c	77 	w 
	cpl			;2c5d	2f 	/ 
	inc hl			;2c5e	23 	# 
	or (hl)			;2c5f	b6 	. 
	ld (0c0d8h),a		;2c60	32 d8 c0 	2 . . 
	cp 0ffh		;2c63	fe ff 	. . 
	call nz,sub_2d57h		;2c65	c4 57 2d 	. W - 
	ld a,004h		;2c68	3e 04 	> . 
	out (082h),a		;2c6a	d3 82 	. . 
	ld hl,l2c73h		;2c6c	21 73 2c 	! s , 
	ld (0c0e2h),hl		;2c6f	22 e2 c0 	" . . 
	ret			;2c72	c9 	. 
l2c73h:
	ld a,(0c0fbh)		;2c73	3a fb c0 	: . . 
	and a			;2c76	a7 	. 
	jp z,l2c7fh		;2c77	ca 7f 2c 	.  , 
	dec a			;2c7a	3d 	= 
	ld (0c0fbh),a		;2c7b	32 fb c0 	2 . . 
	ret			;2c7e	c9 	. 
l2c7fh:
	ld a,001h		;2c7f	3e 01 	> . 
	ld (0c0fbh),a		;2c81	32 fb c0 	2 . . 
	ld a,0ffh		;2c84	3e ff 	> . 
	ld (0c0f8h),a		;2c86	32 f8 c0 	2 . . 
	in a,(002h)		;2c89	db 02 	. . 
	ld hl,0c0e8h		;2c8b	21 e8 c0 	! . . 
	cpl			;2c8e	2f 	/ 
	ld (hl),a			;2c8f	77 	w 
	cpl			;2c90	2f 	/ 
	inc hl			;2c91	23 	# 
	or (hl)			;2c92	b6 	. 
	ld (0c0d9h),a		;2c93	32 d9 c0 	2 . . 
	cp 0ffh		;2c96	fe ff 	. . 
	call nz,sub_2da2h		;2c98	c4 a2 2d 	. . - 
	ld a,008h		;2c9b	3e 08 	> . 
	out (082h),a		;2c9d	d3 82 	. . 
	ld hl,l2ca6h		;2c9f	21 a6 2c 	! . , 
	ld (0c0e2h),hl		;2ca2	22 e2 c0 	" . . 
	ret			;2ca5	c9 	. 
l2ca6h:
	ld a,(0c0fbh)		;2ca6	3a fb c0 	: . . 
	and a			;2ca9	a7 	. 
	jp z,l2cb2h		;2caa	ca b2 2c 	. . , 
	dec a			;2cad	3d 	= 
	ld (0c0fbh),a		;2cae	32 fb c0 	2 . . 
	ret			;2cb1	c9 	. 
l2cb2h:
	ld a,001h		;2cb2	3e 01 	> . 
	ld (0c0fbh),a		;2cb4	32 fb c0 	2 . . 
	ld a,0ffh		;2cb7	3e ff 	> . 
	ld (0c0f9h),a		;2cb9	32 f9 c0 	2 . . 
	in a,(002h)		;2cbc	db 02 	. . 
	ld hl,0c0eah		;2cbe	21 ea c0 	! . . 
	cpl			;2cc1	2f 	/ 
	ld (hl),a			;2cc2	77 	w 
	cpl			;2cc3	2f 	/ 
	inc hl			;2cc4	23 	# 
	or (hl)			;2cc5	b6 	. 
	ld (0c0dah),a		;2cc6	32 da c0 	2 . . 
	cp 0ffh		;2cc9	fe ff 	. . 
	call nz,sub_2dedh		;2ccb	c4 ed 2d 	. . - 
	ld a,010h		;2cce	3e 10 	> . 
	out (082h),a		;2cd0	d3 82 	. . 
	ld hl,l2cd9h		;2cd2	21 d9 2c 	! . , 
	ld (0c0e2h),hl		;2cd5	22 e2 c0 	" . . 
	ret			;2cd8	c9 	. 
l2cd9h:
	ld a,(0c0fbh)		;2cd9	3a fb c0 	: . . 
	and a			;2cdc	a7 	. 
	jp z,l2ce5h		;2cdd	ca e5 2c 	. . , 
	dec a			;2ce0	3d 	= 
	ld (0c0fbh),a		;2ce1	32 fb c0 	2 . . 
	ret			;2ce4	c9 	. 
l2ce5h:
	ld a,001h		;2ce5	3e 01 	> . 
	ld (0c0fbh),a		;2ce7	32 fb c0 	2 . . 
	ld a,0ffh		;2cea	3e ff 	> . 
	ld (0c0fah),a		;2cec	32 fa c0 	2 . . 
	in a,(002h)		;2cef	db 02 	. . 
	ld hl,0c0ech		;2cf1	21 ec c0 	! . . 
	cpl			;2cf4	2f 	/ 
	ld (hl),a			;2cf5	77 	w 
	cpl			;2cf6	2f 	/ 
	inc hl			;2cf7	23 	# 
	or (hl)			;2cf8	b6 	. 
	ld (0c0dbh),a		;2cf9	32 db c0 	2 . . 
	cp 0ffh		;2cfc	fe ff 	. . 
	call nz,sub_2e38h		;2cfe	c4 38 2e 	. 8 . 
	ld a,001h		;2d01	3e 01 	> . 
	out (082h),a		;2d03	d3 82 	. . 
	ld hl,l2c0dh		;2d05	21 0d 2c 	! . , 
	ld (0c0e2h),hl		;2d08	22 e2 c0 	" . . 
	ret			;2d0b	c9 	. 
sub_2d0ch:
	ld a,(0c0d7h)		;2d0c	3a d7 c0 	: . . 
	bit 0,a		;2d0f	cb 47 	. G 
	call z,sub_2e83h		;2d11	cc 83 2e 	. . . 
	ld a,(0c0d7h)		;2d14	3a d7 c0 	: . . 
	bit 1,a		;2d17	cb 4f 	. O 
	call z,sub_2e8bh		;2d19	cc 8b 2e 	. . . 
	ld a,(0c0d7h)		;2d1c	3a d7 c0 	: . . 
	bit 2,a		;2d1f	cb 57 	. W 
	call z,sub_2e93h		;2d21	cc 93 2e 	. . . 
	ld a,(0c0d7h)		;2d24	3a d7 c0 	: . . 
	bit 3,a		;2d27	cb 5f 	. _ 
	call z,sub_2e9bh		;2d29	cc 9b 2e 	. . . 
	ld a,(0c0d7h)		;2d2c	3a d7 c0 	: . . 
	bit 4,a		;2d2f	cb 67 	. g 
	call z,sub_2ea3h		;2d31	cc a3 2e 	. . . 
	ld a,(0c0d7h)		;2d34	3a d7 c0 	: . . 
	bit 5,a		;2d37	cb 6f 	. o 
	call z,sub_2eabh		;2d39	cc ab 2e 	. . . 
	ld a,(0c0d7h)		;2d3c	3a d7 c0 	: . . 
	bit 6,a		;2d3f	cb 77 	. w 
	call z,sub_2eb3h		;2d41	cc b3 2e 	. . . 
	ld a,(0c0d7h)		;2d44	3a d7 c0 	: . . 
	bit 7,a		;2d47	cb 7f 	.  
	jp z,l2ebbh		;2d49	ca bb 2e 	. . . 
	ld hl,l0ec4h		;2d4c	21 c4 0e 	! . . 
	ld (0c0ffh),hl		;2d4f	22 ff c0 	" . . 
	xor a			;2d52	af 	. 
	ld (0c0fdh),a		;2d53	32 fd c0 	2 . . 
	ret			;2d56	c9 	. 
sub_2d57h:
	ld a,(0c0d8h)		;2d57	3a d8 c0 	: . . 
	bit 0,a		;2d5a	cb 47 	. G 
	call z,sub_2ec3h		;2d5c	cc c3 2e 	. . . 
	ld a,(0c0d8h)		;2d5f	3a d8 c0 	: . . 
	bit 1,a		;2d62	cb 4f 	. O 
	call z,sub_2ecbh		;2d64	cc cb 2e 	. . . 
	ld a,(0c0d8h)		;2d67	3a d8 c0 	: . . 
	bit 2,a		;2d6a	cb 57 	. W 
	call z,sub_2ed3h		;2d6c	cc d3 2e 	. . . 
	ld a,(0c0d8h)		;2d6f	3a d8 c0 	: . . 
	bit 3,a		;2d72	cb 5f 	. _ 
	call z,sub_2edbh		;2d74	cc db 2e 	. . . 
	ld a,(0c0d8h)		;2d77	3a d8 c0 	: . . 
	bit 4,a		;2d7a	cb 67 	. g 
	call z,sub_2ee3h		;2d7c	cc e3 2e 	. . . 
	ld a,(0c0d8h)		;2d7f	3a d8 c0 	: . . 
	bit 5,a		;2d82	cb 6f 	. o 
	call z,sub_2eebh		;2d84	cc eb 2e 	. . . 
	ld a,(0c0d8h)		;2d87	3a d8 c0 	: . . 
	bit 6,a		;2d8a	cb 77 	. w 
	call z,sub_2ef3h		;2d8c	cc f3 2e 	. . . 
	ld a,(0c0d8h)		;2d8f	3a d8 c0 	: . . 
	bit 7,a		;2d92	cb 7f 	.  
	jp z,l2efbh		;2d94	ca fb 2e 	. . . 
	ld hl,l0ec4h		;2d97	21 c4 0e 	! . . 
	ld (0c0ffh),hl		;2d9a	22 ff c0 	" . . 
	xor a			;2d9d	af 	. 
	ld (0c0fdh),a		;2d9e	32 fd c0 	2 . . 
	ret			;2da1	c9 	. 
sub_2da2h:
	ld a,(0c0d9h)		;2da2	3a d9 c0 	: . . 
	bit 0,a		;2da5	cb 47 	. G 
	call z,sub_2f03h		;2da7	cc 03 2f 	. . / 
	ld a,(0c0d9h)		;2daa	3a d9 c0 	: . . 
	bit 1,a		;2dad	cb 4f 	. O 
	call z,sub_2f0bh		;2daf	cc 0b 2f 	. . / 
	ld a,(0c0d9h)		;2db2	3a d9 c0 	: . . 
	bit 2,a		;2db5	cb 57 	. W 
	call z,sub_2f13h		;2db7	cc 13 2f 	. . / 
	ld a,(0c0d9h)		;2dba	3a d9 c0 	: . . 
	bit 3,a		;2dbd	cb 5f 	. _ 
	call z,sub_2f1bh		;2dbf	cc 1b 2f 	. . / 
	ld a,(0c0d9h)		;2dc2	3a d9 c0 	: . . 
	bit 4,a		;2dc5	cb 67 	. g 
	call z,sub_2f23h		;2dc7	cc 23 2f 	. # / 
	ld a,(0c0d9h)		;2dca	3a d9 c0 	: . . 
	bit 5,a		;2dcd	cb 6f 	. o 
	call z,sub_2f2bh		;2dcf	cc 2b 2f 	. + / 
	ld a,(0c0d9h)		;2dd2	3a d9 c0 	: . . 
	bit 6,a		;2dd5	cb 77 	. w 
	call z,sub_2f33h		;2dd7	cc 33 2f 	. 3 / 
	ld a,(0c0d9h)		;2dda	3a d9 c0 	: . . 
	bit 7,a		;2ddd	cb 7f 	.  
	jp z,l2f3bh		;2ddf	ca 3b 2f 	. ; / 
	ld hl,l0ec4h		;2de2	21 c4 0e 	! . . 
	ld (0c0ffh),hl		;2de5	22 ff c0 	" . . 
	xor a			;2de8	af 	. 
	ld (0c0fdh),a		;2de9	32 fd c0 	2 . . 
	ret			;2dec	c9 	. 
sub_2dedh:
	ld a,(0c0dah)		;2ded	3a da c0 	: . . 
	bit 0,a		;2df0	cb 47 	. G 
	call z,sub_2f43h		;2df2	cc 43 2f 	. C / 
	ld a,(0c0dah)		;2df5	3a da c0 	: . . 
	bit 1,a		;2df8	cb 4f 	. O 
	call z,sub_2f4bh		;2dfa	cc 4b 2f 	. K / 
	ld a,(0c0dah)		;2dfd	3a da c0 	: . . 
	bit 2,a		;2e00	cb 57 	. W 
	call z,sub_2f53h		;2e02	cc 53 2f 	. S / 
	ld a,(0c0dah)		;2e05	3a da c0 	: . . 
	bit 3,a		;2e08	cb 5f 	. _ 
	call z,sub_2f5bh		;2e0a	cc 5b 2f 	. [ / 
	ld a,(0c0dah)		;2e0d	3a da c0 	: . . 
	bit 4,a		;2e10	cb 67 	. g 
	call z,sub_2f63h		;2e12	cc 63 2f 	. c / 
	ld a,(0c0dah)		;2e15	3a da c0 	: . . 
	bit 5,a		;2e18	cb 6f 	. o 
	call z,sub_2f6bh		;2e1a	cc 6b 2f 	. k / 
	ld a,(0c0dah)		;2e1d	3a da c0 	: . . 
	bit 6,a		;2e20	cb 77 	. w 
	call z,sub_2f73h		;2e22	cc 73 2f 	. s / 
	ld a,(0c0dah)		;2e25	3a da c0 	: . . 
	bit 7,a		;2e28	cb 7f 	.  
	jp z,l2f7bh		;2e2a	ca 7b 2f 	. { / 
	ld hl,l0ec4h		;2e2d	21 c4 0e 	! . . 
	ld (0c0ffh),hl		;2e30	22 ff c0 	" . . 
	xor a			;2e33	af 	. 
	ld (0c0fdh),a		;2e34	32 fd c0 	2 . . 
	ret			;2e37	c9 	. 
sub_2e38h:
	ld a,(0c0dbh)		;2e38	3a db c0 	: . . 
	bit 0,a		;2e3b	cb 47 	. G 
	call z,sub_2f83h		;2e3d	cc 83 2f 	. . / 
	ld a,(0c0dbh)		;2e40	3a db c0 	: . . 
	bit 1,a		;2e43	cb 4f 	. O 
	call z,sub_2f8bh		;2e45	cc 8b 2f 	. . / 
	ld a,(0c0dbh)		;2e48	3a db c0 	: . . 
	bit 2,a		;2e4b	cb 57 	. W 
	call z,sub_2f93h		;2e4d	cc 93 2f 	. . / 
	ld a,(0c0dbh)		;2e50	3a db c0 	: . . 
	bit 3,a		;2e53	cb 5f 	. _ 
	call z,sub_2f9bh		;2e55	cc 9b 2f 	. . / 
	ld a,(0c0dbh)		;2e58	3a db c0 	: . . 
	bit 4,a		;2e5b	cb 67 	. g 
	call z,sub_2fa3h		;2e5d	cc a3 2f 	. . / 
	ld a,(0c0dbh)		;2e60	3a db c0 	: . . 
	bit 5,a		;2e63	cb 6f 	. o 
	call z,sub_2fabh		;2e65	cc ab 2f 	. . / 
	ld a,(0c0dbh)		;2e68	3a db c0 	: . . 
	bit 6,a		;2e6b	cb 77 	. w 
	call z,sub_2fb3h		;2e6d	cc b3 2f 	. . / 
	ld a,(0c0dbh)		;2e70	3a db c0 	: . . 
	bit 7,a		;2e73	cb 7f 	.  
	jp z,l2fbbh		;2e75	ca bb 2f 	. . / 
	ld hl,l0ec4h		;2e78	21 c4 0e 	! . . 
	ld (0c0ffh),hl		;2e7b	22 ff c0 	" . . 
	xor a			;2e7e	af 	. 
	ld (0c0fdh),a		;2e7f	32 fd c0 	2 . . 
	ret			;2e82	c9 	. 
sub_2e83h:
	ld a,00ah		;2e83	3e 0a 	> . 
	ld (0c0feh),a		;2e85	32 fe c0 	2 . . 
	jp l0ef1h		;2e88	c3 f1 0e 	. . . 
sub_2e8bh:
	ld a,00bh		;2e8b	3e 0b 	> . 
	ld (0c0feh),a		;2e8d	32 fe c0 	2 . . 
	jp l0ef9h		;2e90	c3 f9 0e 	. . . 
sub_2e93h:
	ld a,00ch		;2e93	3e 0c 	> . 
	ld (0c0feh),a		;2e95	32 fe c0 	2 . . 
	jp l0f11h		;2e98	c3 11 0f 	. . . 
sub_2e9bh:
	ld a,00dh		;2e9b	3e 0d 	> . 
	ld (0c0feh),a		;2e9d	32 fe c0 	2 . . 
	jp l0f29h		;2ea0	c3 29 0f 	. ) . 
sub_2ea3h:
	ld a,00eh		;2ea3	3e 0e 	> . 
	ld (0c0feh),a		;2ea5	32 fe c0 	2 . . 
	jp l0f39h		;2ea8	c3 39 0f 	. 9 . 
sub_2eabh:
	ld a,00fh		;2eab	3e 0f 	> . 
	ld (0c0feh),a		;2ead	32 fe c0 	2 . . 
	jp l0f4bh		;2eb0	c3 4b 0f 	. K . 
sub_2eb3h:
	ld a,010h		;2eb3	3e 10 	> . 
	ld (0c0feh),a		;2eb5	32 fe c0 	2 . . 
	jp l0f5dh		;2eb8	c3 5d 0f 	. ] . 
l2ebbh:
	ld a,011h		;2ebb	3e 11 	> . 
	ld (0c0feh),a		;2ebd	32 fe c0 	2 . . 
	jp l0f6fh		;2ec0	c3 6f 0f 	. o . 
sub_2ec3h:
	ld a,012h		;2ec3	3e 12 	> . 
	ld (0c0feh),a		;2ec5	32 fe c0 	2 . . 
	jp l10f7h		;2ec8	c3 f7 10 	. . . 
sub_2ecbh:
	ld a,013h		;2ecb	3e 13 	> . 
	ld (0c0feh),a		;2ecd	32 fe c0 	2 . . 
	jp l0fc8h		;2ed0	c3 c8 0f 	. . . 
sub_2ed3h:
	ld a,014h		;2ed3	3e 14 	> . 
	ld (0c0feh),a		;2ed5	32 fe c0 	2 . . 
	jp l0f31h		;2ed8	c3 31 0f 	. 1 . 
sub_2edbh:
	ld a,015h		;2edb	3e 15 	> . 
	ld (0c0feh),a		;2edd	32 fe c0 	2 . . 
	jp l0fd0h		;2ee0	c3 d0 0f 	. . . 
sub_2ee3h:
	ld a,016h		;2ee3	3e 16 	> . 
	ld (0c0feh),a		;2ee5	32 fe c0 	2 . . 
	jp l0fd8h		;2ee8	c3 d8 0f 	. . . 
sub_2eebh:
	ld a,017h		;2eeb	3e 17 	> . 
	ld (0c0feh),a		;2eed	32 fe c0 	2 . . 
	jp l0fe0h		;2ef0	c3 e0 0f 	. . . 
sub_2ef3h:
	ld a,018h		;2ef3	3e 18 	> . 
	ld (0c0feh),a		;2ef5	32 fe c0 	2 . . 
	jp l0fe8h		;2ef8	c3 e8 0f 	. . . 
l2efbh:
	ld a,019h		;2efb	3e 19 	> . 
	ld (0c0feh),a		;2efd	32 fe c0 	2 . . 
	jp l0ff0h		;2f00	c3 f0 0f 	. . . 
sub_2f03h:
	ld a,01ah		;2f03	3e 1a 	> . 
	ld (0c0feh),a		;2f05	32 fe c0 	2 . . 
	jp l0ec4h		;2f08	c3 c4 0e 	. . . 
sub_2f0bh:
	ld a,01bh		;2f0b	3e 1b 	> . 
	ld (0c0feh),a		;2f0d	32 fe c0 	2 . . 
	jp l103ah		;2f10	c3 3a 10 	. : . 
sub_2f13h:
	ld a,01ch		;2f13	3e 1c 	> . 
	ld (0c0feh),a		;2f15	32 fe c0 	2 . . 
	jp l105ch		;2f18	c3 5c 10 	. \ . 
sub_2f1bh:
	ld a,01dh		;2f1b	3e 1d 	> . 
	ld (0c0feh),a		;2f1d	32 fe c0 	2 . . 
	jp l1000h		;2f20	c3 00 10 	. . . 
sub_2f23h:
	ld a,01eh		;2f23	3e 1e 	> . 
	ld (0c0feh),a		;2f25	32 fe c0 	2 . . 
	jp l1020h		;2f28	c3 20 10 	.   . 
sub_2f2bh:
	ld a,01fh		;2f2b	3e 1f 	> . 
	ld (0c0feh),a		;2f2d	32 fe c0 	2 . . 
	jp l0ec4h		;2f30	c3 c4 0e 	. . . 
sub_2f33h:
	ld a,020h		;2f33	3e 20 	>   
	ld (0c0feh),a		;2f35	32 fe c0 	2 . . 
	jp l0ff8h		;2f38	c3 f8 0f 	. . . 
l2f3bh:
	ld a,021h		;2f3b	3e 21 	> ! 
	ld (0c0feh),a		;2f3d	32 fe c0 	2 . . 
	jp l107eh		;2f40	c3 7e 10 	. ~ . 
sub_2f43h:
	ld a,022h		;2f43	3e 22 	> " 
	ld (0c0feh),a		;2f45	32 fe c0 	2 . . 
	jp l0f81h		;2f48	c3 81 0f 	. . . 
sub_2f4bh:
	ld a,023h		;2f4b	3e 23 	> # 
	ld (0c0feh),a		;2f4d	32 fe c0 	2 . . 
	jp l0fa0h		;2f50	c3 a0 0f 	. . . 
sub_2f53h:
	ld a,024h		;2f53	3e 24 	> $ 
	ld (0c0feh),a		;2f55	32 fe c0 	2 . . 
	jp l0fa8h		;2f58	c3 a8 0f 	. . . 
sub_2f5bh:
	ld a,025h		;2f5b	3e 25 	> % 
	ld (0c0feh),a		;2f5d	32 fe c0 	2 . . 
	jp l1098h		;2f60	c3 98 10 	. . . 
sub_2f63h:
	ld a,026h		;2f63	3e 26 	> & 
	ld (0c0feh),a		;2f65	32 fe c0 	2 . . 
	jp l10a5h		;2f68	c3 a5 10 	. . . 
sub_2f6bh:
	ld a,027h		;2f6b	3e 27 	> ' 
	ld (0c0feh),a		;2f6d	32 fe c0 	2 . . 
	jp l0fb0h		;2f70	c3 b0 0f 	. . . 
sub_2f73h:
	ld a,028h		;2f73	3e 28 	> ( 
	ld (0c0feh),a		;2f75	32 fe c0 	2 . . 
	jp l0fb8h		;2f78	c3 b8 0f 	. . . 
l2f7bh:
	ld a,029h		;2f7b	3e 29 	> ) 
	ld (0c0feh),a		;2f7d	32 fe c0 	2 . . 
	jp l0fc0h		;2f80	c3 c0 0f 	. . . 
sub_2f83h:
	ld a,02ah		;2f83	3e 2a 	> * 
	ld (0c0feh),a		;2f85	32 fe c0 	2 . . 
	jp l1032h		;2f88	c3 32 10 	. 2 . 
sub_2f8bh:
	ld a,02bh		;2f8b	3e 2b 	> + 
	ld (0c0feh),a		;2f8d	32 fe c0 	2 . . 
	jp l1018h		;2f90	c3 18 10 	. . . 
sub_2f93h:
	ld a,02ch		;2f93	3e 2c 	> , 
	ld (0c0feh),a		;2f95	32 fe c0 	2 . . 
	jp l1090h		;2f98	c3 90 10 	. . . 
sub_2f9bh:
	ld a,02dh		;2f9b	3e 2d 	> - 
	ld (0c0feh),a		;2f9d	32 fe c0 	2 . . 
	jp l1008h		;2fa0	c3 08 10 	. . . 
sub_2fa3h:
	ld a,02eh		;2fa3	3e 2e 	> . 
	ld (0c0feh),a		;2fa5	32 fe c0 	2 . . 
	jp l1010h		;2fa8	c3 10 10 	. . . 
sub_2fabh:
	ld a,02fh		;2fab	3e 2f 	> / 
	ld (0c0feh),a		;2fad	32 fe c0 	2 . . 
	jp l10b2h		;2fb0	c3 b2 10 	. . . 
sub_2fb3h:
	ld a,030h		;2fb3	3e 30 	> 0 
	ld (0c0feh),a		;2fb5	32 fe c0 	2 . . 
	jp l10dah		;2fb8	c3 da 10 	. . . 
l2fbbh:
	ld a,031h		;2fbb	3e 31 	> 1 
	ld (0c0feh),a		;2fbd	32 fe c0 	2 . . 
	jp l10eah		;2fc0	c3 ea 10 	. . . 
	ld hl,l2bbdh		;2fc3	21 bd 2b 	! . + 
	ld (0c0e2h),hl		;2fc6	22 e2 c0 	" . . 
	in a,(002h)		;2fc9	db 02 	. . 
	ld (0c0d7h),a		;2fcb	32 d7 c0 	2 . . 
	ret			;2fce	c9 	. 
	ld hl,l2bbdh		;2fcf	21 bd 2b 	! . + 
	ld (0c0e2h),hl		;2fd2	22 e2 c0 	" . . 
	in a,(002h)		;2fd5	db 02 	. . 
	ld (0c0d8h),a		;2fd7	32 d8 c0 	2 . . 
	ret			;2fda	c9 	. 
	ld hl,l2bbdh		;2fdb	21 bd 2b 	! . + 
	ld (0c0e2h),hl		;2fde	22 e2 c0 	" . . 
	in a,(002h)		;2fe1	db 02 	. . 
	ld (0c0d9h),a		;2fe3	32 d9 c0 	2 . . 
	ret			;2fe6	c9 	. 
sub_2fe7h:
	ld hl,l2bbdh		;2fe7	21 bd 2b 	! . + 
	ld (0c0e2h),hl		;2fea	22 e2 c0 	" . . 
	in a,(002h)		;2fed	db 02 	. . 
	ld (0c0dah),a		;2fef	32 da c0 	2 . . 
	ret			;2ff2	c9 	. 
sub_2ff3h:
	ld hl,l2bbdh		;2ff3	21 bd 2b 	! . + 
	ld (0c0e2h),hl		;2ff6	22 e2 c0 	" . . 
	in a,(002h)		;2ff9	db 02 	. . 
	ld (0c0dbh),a		;2ffb	32 db c0 	2 . . 
	ret			;2ffe	c9 	. 
sub_2fffh:
	ld a,(0c0fch)		;2fff	3a fc c0 	: . . 
	and a			;3002	a7 	. 
	jp z,l300bh		;3003	ca 0b 30 	. . 0 
	dec a			;3006	3d 	= 
	ld (0c0fch),a		;3007	32 fc c0 	2 . . 
	ret			;300a	c9 	. 
l300bh:
	ld a,(0c0e4h)		;300b	3a e4 c0 	: . . 
	ld hl,0c0e5h		;300e	21 e5 c0 	! . . 
	and (hl)			;3011	a6 	. 
	ld (hl),a			;3012	77 	w 
	ld a,(0c0e6h)		;3013	3a e6 c0 	: . . 
	ld hl,0c0e7h		;3016	21 e7 c0 	! . . 
	and (hl)			;3019	a6 	. 
	ld (hl),a			;301a	77 	w 
	ld a,(0c0e8h)		;301b	3a e8 c0 	: . . 
	ld hl,0c0e9h		;301e	21 e9 c0 	! . . 
	and (hl)			;3021	a6 	. 
	ld (hl),a			;3022	77 	w 
	ld a,(0c0eah)		;3023	3a ea c0 	: . . 
	ld hl,0c0ebh		;3026	21 eb c0 	! . . 
	and (hl)			;3029	a6 	. 
	ld (hl),a			;302a	77 	w 
	ld a,(0c0ech)		;302b	3a ec c0 	: . . 
	ld hl,0c0edh		;302e	21 ed c0 	! . . 
	and (hl)			;3031	a6 	. 
	ld (hl),a			;3032	77 	w 
	ld a,(0c0f4h)		;3033	3a f4 c0 	: . . 
	ld hl,0c0f5h		;3036	21 f5 c0 	! . . 
	and (hl)			;3039	a6 	. 
	ld (hl),a			;303a	77 	w 
	ret			;303b	c9 	. 
l303ch:
	rst 38h			;303c	ff 	. 
l303dh:
	inc d			;303d	14 	. 
l303eh:
	inc d			;303e	14 	. 
l303fh:
	inc d			;303f	14 	. 
l3040h:
	inc d			;3040	14 	. 
l3041h:
	inc d			;3041	14 	. 
l3042h:
	ld e,014h		;3042	1e 14 	. . 
	ld hl,0c0e5h		;3044	21 e5 c0 	! . . 
	or (hl)			;3047	b6 	. 
	ld (hl),a			;3048	77 	w 
	ld hl,0c0d7h		;3049	21 d7 c0 	! . . 
	or (hl)			;304c	b6 	. 
	ld (hl),a			;304d	77 	w 
	ld a,(l303ch)		;304e	3a 3c 30 	: < 0 
	ld (0c0fch),a		;3051	32 fc c0 	2 . . 
	ret			;3054	c9 	. 
sub_3055h:
	ld hl,0c0e5h		;3055	21 e5 c0 	! . . 
	or (hl)			;3058	b6 	. 
	ld (hl),a			;3059	77 	w 
	ld hl,0c0d7h		;305a	21 d7 c0 	! . . 
	or (hl)			;305d	b6 	. 
	ld (hl),a			;305e	77 	w 
	ld a,(l303dh)		;305f	3a 3d 30 	: = 0 
	ld (0c0fch),a		;3062	32 fc c0 	2 . . 
	ret			;3065	c9 	. 
sub_3066h:
	ld hl,0c0e7h		;3066	21 e7 c0 	! . . 
	or (hl)			;3069	b6 	. 
	ld (hl),a			;306a	77 	w 
	ld hl,0c0d8h		;306b	21 d8 c0 	! . . 
	or (hl)			;306e	b6 	. 
	ld (hl),a			;306f	77 	w 
	ld a,(l303eh)		;3070	3a 3e 30 	: > 0 
	ld (0c0fch),a		;3073	32 fc c0 	2 . . 
	ret			;3076	c9 	. 
sub_3077h:
	ld hl,0c0e9h		;3077	21 e9 c0 	! . . 
	or (hl)			;307a	b6 	. 
	ld (hl),a			;307b	77 	w 
	ld hl,0c0d9h		;307c	21 d9 c0 	! . . 
	or (hl)			;307f	b6 	. 
	ld (hl),a			;3080	77 	w 
	ld a,(l303fh)		;3081	3a 3f 30 	: ? 0 
	ld (0c0fch),a		;3084	32 fc c0 	2 . . 
	ret			;3087	c9 	. 
sub_3088h:
	ld hl,0c0ebh		;3088	21 eb c0 	! . . 
	or (hl)			;308b	b6 	. 
	ld (hl),a			;308c	77 	w 
	ld hl,0c0dah		;308d	21 da c0 	! . . 
	or (hl)			;3090	b6 	. 
	ld (hl),a			;3091	77 	w 
	ld a,(l3040h)		;3092	3a 40 30 	: @ 0 
	ld (0c0fch),a		;3095	32 fc c0 	2 . . 
	ret			;3098	c9 	. 
sub_3099h:
	ld hl,0c0edh		;3099	21 ed c0 	! . . 
	or (hl)			;309c	b6 	. 
	ld (hl),a			;309d	77 	w 
	ld hl,0c0dbh		;309e	21 db c0 	! . . 
	or (hl)			;30a1	b6 	. 
	ld (hl),a			;30a2	77 	w 
	ld a,(l3041h)		;30a3	3a 41 30 	: A 0 
	ld (0c0fch),a		;30a6	32 fc c0 	2 . . 
	ret			;30a9	c9 	. 
sub_30aah:
	ld hl,0c0f5h		;30aa	21 f5 c0 	! . . 
	or (hl)			;30ad	b6 	. 
	ld (hl),a			;30ae	77 	w 
	ld hl,0c0dfh		;30af	21 df c0 	! . . 
	or (hl)			;30b2	b6 	. 
	ld (hl),a			;30b3	77 	w 
	ld a,(l3042h)		;30b4	3a 42 30 	: B 0 
	ld (0c0fch),a		;30b7	32 fc c0 	2 . . 
	ret			;30ba	c9 	. 
	ld hl,0c0f5h		;30bb	21 f5 c0 	! . . 
	or (hl)			;30be	b6 	. 
	ld (hl),a			;30bf	77 	w 
	ld hl,0c0dfh		;30c0	21 df c0 	! . . 
	or (hl)			;30c3	b6 	. 
	ld (hl),a			;30c4	77 	w 
	ld a,(l3042h+1)		;30c5	3a 43 30 	: C 0 
	ld (0c0fch),a		;30c8	32 fc c0 	2 . . 
	ret			;30cb	c9 	. 
	ld hl,0c0e5h		;30cc	21 e5 c0 	! . . 
	and (hl)			;30cf	a6 	. 
	ld (hl),a			;30d0	77 	w 
	ret			;30d1	c9 	. 
	ld hl,0c0e7h		;30d2	21 e7 c0 	! . . 
	and (hl)			;30d5	a6 	. 
	ld (hl),a			;30d6	77 	w 
	ret			;30d7	c9 	. 
	ld hl,0c0e9h		;30d8	21 e9 c0 	! . . 
	and (hl)			;30db	a6 	. 
	ld (hl),a			;30dc	77 	w 
	ret			;30dd	c9 	. 
	ld hl,0c0ebh		;30de	21 eb c0 	! . . 
	and (hl)			;30e1	a6 	. 
	ld (hl),a			;30e2	77 	w 
	ret			;30e3	c9 	. 
sub_30e4h:
	ld hl,0c0edh		;30e4	21 ed c0 	! . . 
	and (hl)			;30e7	a6 	. 
	ld (hl),a			;30e8	77 	w 
	ret			;30e9	c9 	. 
	ld hl,0c0f5h		;30ea	21 f5 c0 	! . . 
	and (hl)			;30ed	a6 	. 
	ld (hl),a			;30ee	77 	w 
	ret			;30ef	c9 	. 
sub_30f0h:
	ld a,(0c124h)		;30f0	3a 24 c1 	: $ . 
	and a			;30f3	a7 	. 
	call nz,sub_3395h		;30f4	c4 95 33 	. . 3 
	call sub_3181h		;30f7	cd 81 31 	. . 1 
	call sub_31e4h		;30fa	cd e4 31 	. . 1 
	ld hl,(0c119h)		;30fd	2a 19 c1 	* . . 
	jp (hl)			;3100	e9 	. 
l3101h:
	ld hl,l3111h		;3101	21 11 31 	! . 1 
	ld (0c119h),hl		;3104	22 19 c1 	" . . 
	ld a,(0c111h)		;3107	3a 11 c1 	: . . 
	out (084h),a		;310a	d3 84 	. . 
	ld a,001h		;310c	3e 01 	> . 
	out (083h),a		;310e	d3 83 	. . 
	ret			;3110	c9 	. 
l3111h:
	ld hl,l3121h		;3111	21 21 31 	! ! 1 
	ld (0c119h),hl		;3114	22 19 c1 	" . . 
	ld a,(0c112h)		;3117	3a 12 c1 	: . . 
	out (084h),a		;311a	d3 84 	. . 
	ld a,002h		;311c	3e 02 	> . 
	out (083h),a		;311e	d3 83 	. . 
	ret			;3120	c9 	. 
l3121h:
	ld hl,l3131h		;3121	21 31 31 	! 1 1 
	ld (0c119h),hl		;3124	22 19 c1 	" . . 
	ld a,(0c113h)		;3127	3a 13 c1 	: . . 
	out (084h),a		;312a	d3 84 	. . 
	ld a,004h		;312c	3e 04 	> . 
	out (083h),a		;312e	d3 83 	. . 
	ret			;3130	c9 	. 
l3131h:
	ld hl,l3141h		;3131	21 41 31 	! A 1 
	ld (0c119h),hl		;3134	22 19 c1 	" . . 
	ld a,(0c114h)		;3137	3a 14 c1 	: . . 
	out (084h),a		;313a	d3 84 	. . 
	ld a,008h		;313c	3e 08 	> . 
	out (083h),a		;313e	d3 83 	. . 
	ret			;3140	c9 	. 
l3141h:
	ld hl,l3151h		;3141	21 51 31 	! Q 1 
	ld (0c119h),hl		;3144	22 19 c1 	" . . 
	ld a,(0c115h)		;3147	3a 15 c1 	: . . 
	out (084h),a		;314a	d3 84 	. . 
	ld a,010h		;314c	3e 10 	> . 
	out (083h),a		;314e	d3 83 	. . 
	ret			;3150	c9 	. 
l3151h:
	ld hl,l3161h		;3151	21 61 31 	! a 1 
	ld (0c119h),hl		;3154	22 19 c1 	" . . 
	ld a,(0c116h)		;3157	3a 16 c1 	: . . 
	out (084h),a		;315a	d3 84 	. . 
	ld a,020h		;315c	3e 20 	>   
	out (083h),a		;315e	d3 83 	. . 
	ret			;3160	c9 	. 
l3161h:
	ld hl,l3171h		;3161	21 71 31 	! q 1 
	ld (0c119h),hl		;3164	22 19 c1 	" . . 
	ld a,(0c117h)		;3167	3a 17 c1 	: . . 
	out (084h),a		;316a	d3 84 	. . 
	ld a,040h		;316c	3e 40 	> @ 
	out (083h),a		;316e	d3 83 	. . 
	ret			;3170	c9 	. 
l3171h:
	ld hl,l3101h		;3171	21 01 31 	! . 1 
	ld (0c119h),hl		;3174	22 19 c1 	" . . 
	ld a,(0c118h)		;3177	3a 18 c1 	: . . 
	out (084h),a		;317a	d3 84 	. . 
	ld a,080h		;317c	3e 80 	> . 
	out (083h),a		;317e	d3 83 	. . 
	ret			;3180	c9 	. 
sub_3181h:
	ld a,(0c11bh)		;3181	3a 1b c1 	: . . 
	and a			;3184	a7 	. 
	ret z			;3185	c8 	. 
	ld a,(0c11fh)		;3186	3a 1f c1 	: . . 
	dec a			;3189	3d 	= 
	ld (0c11fh),a		;318a	32 1f c1 	2 . . 
	jp nz,l31aeh		;318d	c2 ae 31 	. . 1 
	ld a,(0c11ch)		;3190	3a 1c c1 	: . . 
	ld (0c11fh),a		;3193	32 1f c1 	2 . . 
	ld a,(0c11dh)		;3196	3a 1d c1 	: . . 
	dec a			;3199	3d 	= 
	ld (0c11dh),a		;319a	32 1d c1 	2 . . 
	jp z,l31ceh		;319d	ca ce 31 	. . 1 
	ld hl,(0c120h)		;31a0	2a 20 c1 	*   . 
	ld de,0c111h		;31a3	11 11 c1 	. . . 
	ld bc,l0008h		;31a6	01 08 00 	. . . 
	ldir		;31a9	ed b0 	. . 
	ld (0c120h),hl		;31ab	22 20 c1 	"   . 
l31aeh:
	ld a,(0c129h)		;31ae	3a 29 c1 	: ) . 
	and a			;31b1	a7 	. 
	jp nz,l31bbh		;31b2	c2 bb 31 	. . 1 
	ld hl,0c111h		;31b5	21 11 c1 	! . . 
	res 7,(hl)		;31b8	cb be 	. . 
	ret			;31ba	c9 	. 
l31bbh:
	ld a,(0c123h)		;31bb	3a 23 c1 	: # . 
	and a			;31be	a7 	. 
	jp nz,l31c8h		;31bf	c2 c8 31 	. . 1 
	ld hl,0c111h		;31c2	21 11 c1 	! . . 
	res 7,(hl)		;31c5	cb be 	. . 
	ret			;31c7	c9 	. 
l31c8h:
	ld hl,0c111h		;31c8	21 11 c1 	! . . 
	set 7,(hl)		;31cb	cb fe 	. . 
	ret			;31cd	c9 	. 
l31ceh:
	xor a			;31ce	af 	. 
	ld (0c11bh),a		;31cf	32 1b c1 	2 . . 
	ld hl,0c101h		;31d2	21 01 c1 	! . . 
	ld de,0c111h		;31d5	11 11 c1 	. . . 
	ld bc,l0008h		;31d8	01 08 00 	. . . 
	ldir		;31db	ed b0 	. . 
	ret			;31dd	c9 	. 
sub_31deh:
	di			;31de	f3 	. 
	call l31ceh		;31df	cd ce 31 	. . 1 
	ei			;31e2	fb 	. 
	ret			;31e3	c9 	. 
sub_31e4h:
	ld a,(0c11bh)		;31e4	3a 1b c1 	: . . 
	and a			;31e7	a7 	. 
	jp nz,l3248h		;31e8	c2 48 32 	. H 2 
	ld hl,0c122h		;31eb	21 22 c1 	! " . 
	dec (hl)			;31ee	35 	5 
	ret nz			;31ef	c0 	. 
	ld (hl),04bh		;31f0	36 4b 	6 K 
	ld a,(0c123h)		;31f2	3a 23 c1 	: # . 
	and a			;31f5	a7 	. 
	jp z,l3237h		;31f6	ca 37 32 	. 7 2 
	xor a			;31f9	af 	. 
	ld (0c123h),a		;31fa	32 23 c1 	2 # . 
	ld bc,0c101h		;31fd	01 01 c1 	. . . 
	ld hl,0c109h		;3200	21 09 c1 	! . . 
	ld de,0c111h		;3203	11 11 c1 	. . . 
	ld a,(bc)			;3206	0a 	. 
	and (hl)			;3207	a6 	. 
	ld (de),a			;3208	12 	. 
	inc bc			;3209	03 	. 
	inc hl			;320a	23 	# 
	inc de			;320b	13 	. 
	ld a,(bc)			;320c	0a 	. 
	and (hl)			;320d	a6 	. 
	ld (de),a			;320e	12 	. 
	inc bc			;320f	03 	. 
	inc hl			;3210	23 	# 
	inc de			;3211	13 	. 
	ld a,(bc)			;3212	0a 	. 
	and (hl)			;3213	a6 	. 
	ld (de),a			;3214	12 	. 
	inc bc			;3215	03 	. 
	inc hl			;3216	23 	# 
	inc de			;3217	13 	. 
	ld a,(bc)			;3218	0a 	. 
	and (hl)			;3219	a6 	. 
	ld (de),a			;321a	12 	. 
	inc bc			;321b	03 	. 
	inc hl			;321c	23 	# 
	inc de			;321d	13 	. 
	ld a,(bc)			;321e	0a 	. 
	and (hl)			;321f	a6 	. 
	ld (de),a			;3220	12 	. 
	inc bc			;3221	03 	. 
	inc hl			;3222	23 	# 
	inc de			;3223	13 	. 
	ld a,(bc)			;3224	0a 	. 
	and (hl)			;3225	a6 	. 
	ld (de),a			;3226	12 	. 
	inc bc			;3227	03 	. 
	inc hl			;3228	23 	# 
	inc de			;3229	13 	. 
	ld a,(bc)			;322a	0a 	. 
	and (hl)			;322b	a6 	. 
	ld (de),a			;322c	12 	. 
	inc bc			;322d	03 	. 
	inc hl			;322e	23 	# 
	inc de			;322f	13 	. 
	ld a,(bc)			;3230	0a 	. 
	and (hl)			;3231	a6 	. 
	ld (de),a			;3232	12 	. 
	inc bc			;3233	03 	. 
	inc hl			;3234	23 	# 
	inc de			;3235	13 	. 
	ret			;3236	c9 	. 
l3237h:
	ld a,0ffh		;3237	3e ff 	> . 
	ld (0c123h),a		;3239	32 23 c1 	2 # . 
	ld hl,0c101h		;323c	21 01 c1 	! . . 
	ld de,0c111h		;323f	11 11 c1 	. . . 
	ld bc,l0008h		;3242	01 08 00 	. . . 
	ldir		;3245	ed b0 	. . 
	ret			;3247	c9 	. 
l3248h:
	ld hl,0c122h		;3248	21 22 c1 	! " . 
	dec (hl)			;324b	35 	5 
	ret nz			;324c	c0 	. 
	ld (hl),04bh		;324d	36 4b 	6 K 
	ld a,(0c123h)		;324f	3a 23 c1 	: # . 
	and a			;3252	a7 	. 
	jp z,l3260h		;3253	ca 60 32 	. ` 2 
	xor a			;3256	af 	. 
	ld (0c123h),a		;3257	32 23 c1 	2 # . 
	ld hl,0c111h		;325a	21 11 c1 	! . . 
	res 7,(hl)		;325d	cb be 	. . 
	ret			;325f	c9 	. 
l3260h:
	ld a,0ffh		;3260	3e ff 	> . 
	ld (0c123h),a		;3262	32 23 c1 	2 # . 
	ld a,(0c129h)		;3265	3a 29 c1 	: ) . 
	and a			;3268	a7 	. 
	jp nz,l3272h		;3269	c2 72 32 	. r 2 
	ld hl,0c111h		;326c	21 11 c1 	! . . 
	res 7,(hl)		;326f	cb be 	. . 
	ret			;3271	c9 	. 
l3272h:
	ld hl,0c111h		;3272	21 11 c1 	! . . 
	set 7,(hl)		;3275	cb fe 	. . 
	ret			;3277	c9 	. 
l3278h:
	di			;3278	f3 	. 
	ld hl,l347fh		;3279	21 7f 34 	!  4 
	ld a,(hl)			;327c	7e 	~ 
	ld (0c11dh),a		;327d	32 1d c1 	2 . . 
	inc hl			;3280	23 	# 
	ld a,(hl)			;3281	7e 	~ 
	ld (0c11ch),a		;3282	32 1c c1 	2 . . 
	ld (0c11fh),a		;3285	32 1f c1 	2 . . 
	inc hl			;3288	23 	# 
	ld (0c120h),hl		;3289	22 20 c1 	"   . 
	ld a,0ffh		;328c	3e ff 	> . 
	ld (0c11bh),a		;328e	32 1b c1 	2 . . 
	ei			;3291	fb 	. 
	ret			;3292	c9 	. 
l3293h:
	di			;3293	f3 	. 
	ld hl,l3641h		;3294	21 41 36 	! A 6 
	ld a,(hl)			;3297	7e 	~ 
	ld (0c11dh),a		;3298	32 1d c1 	2 . . 
	inc hl			;329b	23 	# 
	ld a,(hl)			;329c	7e 	~ 
	ld (0c11ch),a		;329d	32 1c c1 	2 . . 
	ld (0c11fh),a		;32a0	32 1f c1 	2 . . 
	inc hl			;32a3	23 	# 
	ld (0c120h),hl		;32a4	22 20 c1 	"   . 
	ld a,0ffh		;32a7	3e ff 	> . 
	ld (0c11bh),a		;32a9	32 1b c1 	2 . . 
	ei			;32ac	fb 	. 
	ret			;32ad	c9 	. 
l32aeh:
	di			;32ae	f3 	. 
	ld hl,l38ddh		;32af	21 dd 38 	! . 8 
	ld a,(hl)			;32b2	7e 	~ 
	ld (0c11dh),a		;32b3	32 1d c1 	2 . . 
	inc hl			;32b6	23 	# 
	ld a,(hl)			;32b7	7e 	~ 
	ld (0c11ch),a		;32b8	32 1c c1 	2 . . 
	ld (0c11fh),a		;32bb	32 1f c1 	2 . . 
	inc hl			;32be	23 	# 
	ld (0c120h),hl		;32bf	22 20 c1 	"   . 
	ld a,0ffh		;32c2	3e ff 	> . 
	ld (0c11bh),a		;32c4	32 1b c1 	2 . . 
	ei			;32c7	fb 	. 
	ret			;32c8	c9 	. 
l32c9h:
	di			;32c9	f3 	. 
	ld hl,l37f3h		;32ca	21 f3 37 	! . 7 
	ld a,(hl)			;32cd	7e 	~ 
	ld (0c11dh),a		;32ce	32 1d c1 	2 . . 
	inc hl			;32d1	23 	# 
	ld a,(hl)			;32d2	7e 	~ 
	ld (0c11ch),a		;32d3	32 1c c1 	2 . . 
	ld (0c11fh),a		;32d6	32 1f c1 	2 . . 
	inc hl			;32d9	23 	# 
	ld (0c120h),hl		;32da	22 20 c1 	"   . 
	ld a,0ffh		;32dd	3e ff 	> . 
	ld (0c11bh),a		;32df	32 1b c1 	2 . . 
	ei			;32e2	fb 	. 
	ret			;32e3	c9 	. 
sub_32e4h:
	di			;32e4	f3 	. 
	ld hl,l39bfh		;32e5	21 bf 39 	! . 9 
	ld a,(hl)			;32e8	7e 	~ 
	ld (0c11dh),a		;32e9	32 1d c1 	2 . . 
	inc hl			;32ec	23 	# 
	ld a,(hl)			;32ed	7e 	~ 
	ld (0c11ch),a		;32ee	32 1c c1 	2 . . 
	ld (0c11fh),a		;32f1	32 1f c1 	2 . . 
	inc hl			;32f4	23 	# 
	ld (0c120h),hl		;32f5	22 20 c1 	"   . 
	ld a,0ffh		;32f8	3e ff 	> . 
	ld (0c11bh),a		;32fa	32 1b c1 	2 . . 
	ei			;32fd	fb 	. 
	ret			;32fe	c9 	. 
	di			;32ff	f3 	. 
	ld hl,l3b01h		;3300	21 01 3b 	! . ; 
	ld a,(hl)			;3303	7e 	~ 
	ld (0c11dh),a		;3304	32 1d c1 	2 . . 
	inc hl			;3307	23 	# 
	ld a,(hl)			;3308	7e 	~ 
	ld (0c11ch),a		;3309	32 1c c1 	2 . . 
	ld (0c11fh),a		;330c	32 1f c1 	2 . . 
	inc hl			;330f	23 	# 
	ld (0c120h),hl		;3310	22 20 c1 	"   . 
	ld a,0ffh		;3313	3e ff 	> . 
	ld (0c11bh),a		;3315	32 1b c1 	2 . . 
	ei			;3318	fb 	. 
	ret			;3319	c9 	. 
l331ah:
	di			;331a	f3 	. 
	ld hl,l3c13h		;331b	21 13 3c 	! . < 
	ld a,(hl)			;331e	7e 	~ 
	ld (0c11dh),a		;331f	32 1d c1 	2 . . 
	inc hl			;3322	23 	# 
	ld a,(hl)			;3323	7e 	~ 
	ld (0c11ch),a		;3324	32 1c c1 	2 . . 
	ld (0c11fh),a		;3327	32 1f c1 	2 . . 
	inc hl			;332a	23 	# 
	ld (0c120h),hl		;332b	22 20 c1 	"   . 
	ld a,0ffh		;332e	3e ff 	> . 
	ld (0c11bh),a		;3330	32 1b c1 	2 . . 
	ei			;3333	fb 	. 
	ret			;3334	c9 	. 
sub_3335h:
	di			;3335	f3 	. 
	ld hl,l3c4dh		;3336	21 4d 3c 	! M < 
	ld a,(hl)			;3339	7e 	~ 
	ld (0c11dh),a		;333a	32 1d c1 	2 . . 
	inc hl			;333d	23 	# 
	ld a,(hl)			;333e	7e 	~ 
	ld (0c11ch),a		;333f	32 1c c1 	2 . . 
	ld (0c11fh),a		;3342	32 1f c1 	2 . . 
	inc hl			;3345	23 	# 
	ld (0c120h),hl		;3346	22 20 c1 	"   . 
	ld a,0ffh		;3349	3e ff 	> . 
	ld (0c11bh),a		;334b	32 1b c1 	2 . . 
	ei			;334e	fb 	. 
	ret			;334f	c9 	. 
	di			;3350	f3 	. 
	ld hl,l3f5fh		;3351	21 5f 3f 	! _ ? 
	ld a,(hl)			;3354	7e 	~ 
	ld (0c11dh),a		;3355	32 1d c1 	2 . . 
	inc hl			;3358	23 	# 
	ld a,(hl)			;3359	7e 	~ 
	ld (0c11ch),a		;335a	32 1c c1 	2 . . 
	ld (0c11fh),a		;335d	32 1f c1 	2 . . 
	inc hl			;3360	23 	# 
	ld (0c120h),hl		;3361	22 20 c1 	"   . 
	ld a,0ffh		;3364	3e ff 	> . 
	ld (0c11bh),a		;3366	32 1b c1 	2 . . 
	ei			;3369	fb 	. 
	ret			;336a	c9 	. 
sub_336bh:
	di			;336b	f3 	. 
	ld hl,04281h		;336c	21 81 42 	! . B 
	ld a,(hl)			;336f	7e 	~ 
	ld (0c11dh),a		;3370	32 1d c1 	2 . . 
	inc hl			;3373	23 	# 
	ld a,(hl)			;3374	7e 	~ 
	ld (0c11ch),a		;3375	32 1c c1 	2 . . 
	ld (0c11fh),a		;3378	32 1f c1 	2 . . 
	inc hl			;337b	23 	# 
	ld (0c120h),hl		;337c	22 20 c1 	"   . 
	ld a,0ffh		;337f	3e ff 	> . 
	ld (0c11bh),a		;3381	32 1b c1 	2 . . 
	ei			;3384	fb 	. 
	ret			;3385	c9 	. 
sub_3386h:
	xor a			;3386	af 	. 
	ld (0c127h),a		;3387	32 27 c1 	2 ' . 
	ld a,001h		;338a	3e 01 	> . 
	ld (0c126h),a		;338c	32 26 c1 	2 & . 
	ld a,0ffh		;338f	3e ff 	> . 
	ld (0c124h),a		;3391	32 24 c1 	2 $ . 
	ret			;3394	c9 	. 
sub_3395h:
	ld a,(0c126h)		;3395	3a 26 c1 	: & . 
	dec a			;3398	3d 	= 
	ld (0c126h),a		;3399	32 26 c1 	2 & . 
	ret nz			;339c	c0 	. 
	ld a,032h		;339d	3e 32 	> 2 
	ld (0c126h),a		;339f	32 26 c1 	2 & . 
	ld a,(0c127h)		;33a2	3a 27 c1 	: ' . 
	cp 017h		;33a5	fe 17 	. . 
	jp c,l33aeh		;33a7	da ae 33 	. . 3 
	xor a			;33aa	af 	. 
	jp l33afh		;33ab	c3 af 33 	. . 3 
l33aeh:
	inc a			;33ae	3c 	< 
l33afh:
	ld (0c127h),a		;33af	32 27 c1 	2 ' . 
	ld hl,l33d1h		;33b2	21 d1 33 	! . 3 
	sla a		;33b5	cb 27 	. ' 
	ld e,a			;33b7	5f 	_ 
	ld d,000h		;33b8	16 00 	. . 
	add hl,de			;33ba	19 	. 
	ld e,(hl)			;33bb	5e 	^ 
	inc hl			;33bc	23 	# 
	ld d,(hl)			;33bd	56 	V 
	ex de,hl			;33be	eb 	. 
	jp (hl)			;33bf	e9 	. 
sub_33c0h:
	xor a			;33c0	af 	. 
	ld (0c124h),a		;33c1	32 24 c1 	2 $ . 
	call sub_05ebh		;33c4	cd eb 05 	. . . 
	call sub_05f6h		;33c7	cd f6 05 	. . . 
	call sub_0601h		;33ca	cd 01 06 	. . . 
	call sub_060ch		;33cd	cd 0c 06 	. . . 
	ret			;33d0	c9 	. 
l33d1h:
	cp a			;33d1	bf 	. 
	dec b			;33d2	05 	. 
	ex de,hl			;33d3	eb 	. 
	dec b			;33d4	05 	. 
	jp z,0f605h		;33d5	ca 05 f6 	. . . 
	dec b			;33d8	05 	. 
	push de			;33d9	d5 	. 
	dec b			;33da	05 	. 
	ld bc,0e006h		;33db	01 06 e0 	. . . 
	dec b			;33de	05 	. 
	inc c			;33df	0c 	. 
	ld b,0cah		;33e0	06 ca 	. . 
	dec b			;33e2	05 	. 
	or 005h		;33e3	f6 05 	. . 
	ret po			;33e5	e0 	. 
	dec b			;33e6	05 	. 
	inc c			;33e7	0c 	. 
	ld b,0bfh		;33e8	06 bf 	. . 
	dec b			;33ea	05 	. 
	ex de,hl			;33eb	eb 	. 
	dec b			;33ec	05 	. 
	push de			;33ed	d5 	. 
	dec b			;33ee	05 	. 
	ld bc,0e006h		;33ef	01 06 e0 	. . . 
	dec b			;33f2	05 	. 
	inc c			;33f3	0c 	. 
	ld b,0bfh		;33f4	06 bf 	. . 
	dec b			;33f6	05 	. 
	ex de,hl			;33f7	eb 	. 
	dec b			;33f8	05 	. 
	push de			;33f9	d5 	. 
	dec b			;33fa	05 	. 
	ld bc,0ca06h		;33fb	01 06 ca 	. . . 
	dec b			;33fe	05 	. 
	or 005h		;33ff	f6 05 	. . 
sub_3401h:
	ld a,(0c11eh)		;3401	3a 1e c1 	: . . 
	cp 02fh		;3404	fe 2f 	. / 
	jp c,l340dh		;3406	da 0d 34 	. . 4 
	xor a			;3409	af 	. 
	jp l340eh		;340a	c3 0e 34 	. . 4 
l340dh:
	inc a			;340d	3c 	< 
l340eh:
	ld (0c11eh),a		;340e	32 1e c1 	2 . . 
	ld hl,l341fh		;3411	21 1f 34 	! . 4 
	sla a		;3414	cb 27 	. ' 
	ld e,a			;3416	5f 	_ 
	ld d,000h		;3417	16 00 	. . 
	add hl,de			;3419	19 	. 
	ld e,(hl)			;341a	5e 	^ 
	inc hl			;341b	23 	# 
	ld d,(hl)			;341c	56 	V 
	ex de,hl			;341d	eb 	. 
	jp (hl)			;341e	e9 	. 
l341fh:
	dec (hl)			;341f	35 	5 
	inc sp			;3420	33 	3 
	ld a,b			;3421	78 	x 
	ld (l3293h),a		;3422	32 93 32 	2 . 2 
	ld d,b			;3425	50 	P 
	inc sp			;3426	33 	3 
	sub e			;3427	93 	. 
	ld (l3278h),a		;3428	32 78 32 	2 x 2 
	xor (hl)			;342b	ae 	. 
	ld (l32aeh),a		;342c	32 ae 32 	2 . 2 
	ld l,e			;342f	6b 	k 
	inc sp			;3430	33 	3 
	ret			;3431	c9 	. 
	ld (l32aeh),a		;3432	32 ae 32 	2 . 2 
	ld a,(de)			;3435	1a 	. 
	inc sp			;3436	33 	3 
	ld d,b			;3437	50 	P 
	inc sp			;3438	33 	3 
	ret			;3439	c9 	. 
	ld (l32aeh),a		;343a	32 ae 32 	2 . 2 
	call po,0ff32h		;343d	e4 32 ff 	. 2 . 
	ld (sub_336bh),a		;3440	32 6b 33 	2 k 3 
	dec (hl)			;3443	35 	5 
	inc sp			;3444	33 	3 
	ld a,(de)			;3445	1a 	. 
	inc sp			;3446	33 	3 
	ld d,b			;3447	50 	P 
	inc sp			;3448	33 	3 
	ld a,(de)			;3449	1a 	. 
	inc sp			;344a	33 	3 
	ld l,e			;344b	6b 	k 
	inc sp			;344c	33 	3 
	dec (hl)			;344d	35 	5 
	inc sp			;344e	33 	3 
	ld a,b			;344f	78 	x 
	ld (l3293h),a		;3450	32 93 32 	2 . 2 
	xor (hl)			;3453	ae 	. 
	ld (l32c9h),a		;3454	32 c9 32 	2 . 2 
	ld l,e			;3457	6b 	k 
	inc sp			;3458	33 	3 
	ld a,(de)			;3459	1a 	. 
	inc sp			;345a	33 	3 
	ret			;345b	c9 	. 
	ld (l32aeh),a		;345c	32 ae 32 	2 . 2 
	sub e			;345f	93 	. 
	ld (l3278h),a		;3460	32 78 32 	2 x 2 
	ld l,e			;3463	6b 	k 
	inc sp			;3464	33 	3 
	ld a,(de)			;3465	1a 	. 
	inc sp			;3466	33 	3 
	ld d,b			;3467	50 	P 
	inc sp			;3468	33 	3 
	ld a,(de)			;3469	1a 	. 
	inc sp			;346a	33 	3 
	ld a,b			;346b	78 	x 
	ld (l3293h),a		;346c	32 93 32 	2 . 2 
	ld a,(de)			;346f	1a 	. 
	inc sp			;3470	33 	3 
	ld l,e			;3471	6b 	k 
	inc sp			;3472	33 	3 
	ld a,b			;3473	78 	x 
	ld (l32aeh),a		;3474	32 ae 32 	2 . 2 
	sub e			;3477	93 	. 
	ld (l32c9h),a		;3478	32 c9 32 	2 . 2 
	dec (hl)			;347b	35 	5 
	inc sp			;347c	33 	3 
	ld l,e			;347d	6b 	k 
	inc sp			;347e	33 	3 
l347fh:
	jr c,l348ch		;347f	38 0b 	8 . 
	nop			;3481	00 	. 
	nop			;3482	00 	. 
	nop			;3483	00 	. 
	nop			;3484	00 	. 
	nop			;3485	00 	. 
	nop			;3486	00 	. 
	nop			;3487	00 	. 
	add a,b			;3488	80 	. 
	nop			;3489	00 	. 
	nop			;348a	00 	. 
	nop			;348b	00 	. 
l348ch:
	nop			;348c	00 	. 
	inc b			;348d	04 	. 
	ld (bc),a			;348e	02 	. 
	ld (bc),a			;348f	02 	. 
	add a,b			;3490	80 	. 
	nop			;3491	00 	. 
	nop			;3492	00 	. 
	nop			;3493	00 	. 
	ld bc,l0606h		;3494	01 06 06 	. . . 
	ld (bc),a			;3497	02 	. 
	add a,b			;3498	80 	. 
	nop			;3499	00 	. 
	nop			;349a	00 	. 
	nop			;349b	00 	. 
	rlca			;349c	07 	. 
	ld b,006h		;349d	06 06 	. . 
	ld b,080h		;349f	06 80 	. . 
	nop			;34a1	00 	. 
	nop			;34a2	00 	. 
	ld b,007h		;34a3	06 07 	. . 
	ld b,006h		;34a5	06 06 	. . 
	add a,(hl)			;34a7	86 	. 
	add a,(hl)			;34a8	86 	. 
	inc b			;34a9	04 	. 
	ld b,006h		;34aa	06 06 	. . 
	rlca			;34ac	07 	. 
	ld b,006h		;34ad	06 06 	. . 
	add a,(hl)			;34af	86 	. 
	add a,(hl)			;34b0	86 	. 
	ld b,006h		;34b1	06 06 	. . 
	ld b,007h		;34b3	06 07 	. . 
	ld b,086h		;34b5	06 86 	. . 
	add a,(hl)			;34b7	86 	. 
	add a,(hl)			;34b8	86 	. 
	ld c,006h		;34b9	0e 06 	. . 
	ld b,007h		;34bb	06 07 	. . 
	ld b,086h		;34bd	06 86 	. . 
	add a,(hl)			;34bf	86 	. 
	add a,(hl)			;34c0	86 	. 
	ld c,00eh		;34c1	0e 0e 	. . 
	ld b,007h		;34c3	06 07 	. . 
	rlca			;34c5	07 	. 
	add a,(hl)			;34c6	86 	. 
	add a,(hl)			;34c7	86 	. 
	add a,(hl)			;34c8	86 	. 
	ld c,00eh		;34c9	0e 0e 	. . 
	ld c,087h		;34cb	0e 87 	. . 
	rlca			;34cd	07 	. 
	add a,(hl)			;34ce	86 	. 
	add a,(hl)			;34cf	86 	. 
	add a,(hl)			;34d0	86 	. 
	rrca			;34d1	0f 	. 
	ld c,08eh		;34d2	0e 8e 	. . 
	add a,a			;34d4	87 	. 
	rlca			;34d5	07 	. 
	add a,(hl)			;34d6	86 	. 
	add a,(hl)			;34d7	86 	. 
	add a,(hl)			;34d8	86 	. 
	adc a,a			;34d9	8f 	. 
	ld c,08eh		;34da	0e 8e 	. . 
	adc a,a			;34dc	8f 	. 
	rlca			;34dd	07 	. 
	add a,(hl)			;34de	86 	. 
	add a,(hl)			;34df	86 	. 
	add a,(hl)			;34e0	86 	. 
	adc a,a			;34e1	8f 	. 
	ld c,08eh		;34e2	0e 8e 	. . 
	adc a,a			;34e4	8f 	. 
	rrca			;34e5	0f 	. 
	add a,(hl)			;34e6	86 	. 
	add a,(hl)			;34e7	86 	. 
	add a,(hl)			;34e8	86 	. 
	adc a,a			;34e9	8f 	. 
	ld c,08eh		;34ea	0e 8e 	. . 
	adc a,a			;34ec	8f 	. 
	rrca			;34ed	0f 	. 
	adc a,(hl)			;34ee	8e 	. 
	add a,(hl)			;34ef	86 	. 
	add a,(hl)			;34f0	86 	. 
	adc a,a			;34f1	8f 	. 
	ld c,08eh		;34f2	0e 8e 	. . 
	adc a,a			;34f4	8f 	. 
	rrca			;34f5	0f 	. 
	adc a,(hl)			;34f6	8e 	. 
	adc a,(hl)			;34f7	8e 	. 
	add a,(hl)			;34f8	86 	. 
	adc a,a			;34f9	8f 	. 
	ld c,08eh		;34fa	0e 8e 	. . 
	adc a,a			;34fc	8f 	. 
	rrca			;34fd	0f 	. 
	adc a,(hl)			;34fe	8e 	. 
	adc a,(hl)			;34ff	8e 	. 
	adc a,09fh		;3500	ce 9f 	. . 
	ld c,08eh		;3502	0e 8e 	. . 
	adc a,a			;3504	8f 	. 
	rrca			;3505	0f 	. 
	adc a,(hl)			;3506	8e 	. 
	adc a,(hl)			;3507	8e 	. 
	adc a,0dfh		;3508	ce df 	. . 
	ld c,08eh		;350a	0e 8e 	. . 
	adc a,a			;350c	8f 	. 
	rrca			;350d	0f 	. 
	adc a,(hl)			;350e	8e 	. 
	adc a,0ceh		;350f	ce ce 	. . 
	rst 18h			;3511	df 	. 
	ld e,(hl)			;3512	5e 	^ 
	sbc a,(hl)			;3513	9e 	. 
	adc a,a			;3514	8f 	. 
	rra			;3515	1f 	. 
	adc a,(hl)			;3516	8e 	. 
	adc a,0ceh		;3517	ce ce 	. . 
	rst 18h			;3519	df 	. 
	ld e,(hl)			;351a	5e 	^ 
	sbc a,08fh		;351b	de 8f 	. . 
	rra			;351d	1f 	. 
	adc a,(hl)			;351e	8e 	. 
	adc a,0ceh		;351f	ce ce 	. . 
	rst 18h			;3521	df 	. 
	ld e,(hl)			;3522	5e 	^ 
	sbc a,0cfh		;3523	de cf 	. . 
	rra			;3525	1f 	. 
	adc a,(hl)			;3526	8e 	. 
	adc a,0ceh		;3527	ce ce 	. . 
	rst 18h			;3529	df 	. 
	ld e,(hl)			;352a	5e 	^ 
	sbc a,0cfh		;352b	de cf 	. . 
	ld e,a			;352d	5f 	_ 
	sbc a,(hl)			;352e	9e 	. 
	adc a,0ceh		;352f	ce ce 	. . 
	rst 18h			;3531	df 	. 
	ld e,(hl)			;3532	5e 	^ 
	sbc a,0dfh		;3533	de df 	. . 
	ld e,a			;3535	5f 	_ 
	sbc a,(hl)			;3536	9e 	. 
	adc a,0eeh		;3537	ce ee 	. . 
	rst 18h			;3539	df 	. 
	ld e,(hl)			;353a	5e 	^ 
	sbc a,0dfh		;353b	de df 	. . 
	ld e,a			;353d	5f 	_ 
	sbc a,0ceh		;353e	de ce 	. . 
	xor 0dfh		;3540	ee df 	. . 
	ld e,(hl)			;3542	5e 	^ 
	sbc a,0dfh		;3543	de df 	. . 
	ld e,a			;3545	5f 	_ 
	sbc a,0eeh		;3546	de ee 	. . 
	xor 0dfh		;3548	ee df 	. . 
	ld e,(hl)			;354a	5e 	^ 
	sbc a,0dfh		;354b	de df 	. . 
	ld e,a			;354d	5f 	_ 
	cp 0eeh		;354e	fe ee 	. . 
	xor 0dfh		;3550	ee df 	. . 
	ld e,(hl)			;3552	5e 	^ 
	sbc a,0dfh		;3553	de df 	. . 
	ld a,a			;3555	7f 	 
	cp 0eeh		;3556	fe ee 	. . 
	xor 0ffh		;3558	ee ff 	. . 
	ld a,(hl)			;355a	7e 	~ 
	cp 0ffh		;355b	fe ff 	. . 
	ld a,a			;355d	7f 	 
	cp 0eeh		;355e	fe ee 	. . 
	xor 0ffh		;3560	ee ff 	. . 
	ld a,(hl)			;3562	7e 	~ 
	cp 0ffh		;3563	fe ff 	. . 
	ld a,a			;3565	7f 	 
	cp 0eeh		;3566	fe ee 	. . 
	ld l,(hl)			;3568	6e 	n 
	rst 38h			;3569	ff 	. 
	ld a,(hl)			;356a	7e 	~ 
	cp 0ffh		;356b	fe ff 	. . 
	ld a,e			;356d	7b 	{ 
	call m,sub_6eech		;356e	fc ec 6e 	. . n 
	rst 38h			;3571	ff 	. 
	ld a,(hl)			;3572	7e 	~ 
	cp 0feh		;3573	fe fe 	. . 
	ld a,c			;3575	79 	y 
	ret m			;3576	f8 	. 
	call pe,0ff6eh		;3577	ec 6e ff 	. n . 
	ld a,(hl)			;357a	7e 	~ 
	cp 0f8h		;357b	fe f8 	. . 
	ld a,c			;357d	79 	y 
	ret m			;357e	f8 	. 
	ret pe			;357f	e8 	. 
	ld l,(hl)			;3580	6e 	n 
	rst 38h			;3581	ff 	. 
	ld a,(hl)			;3582	7e 	~ 
	ret m			;3583	f8 	. 
	ret m			;3584	f8 	. 
	ld a,c			;3585	79 	y 
	ret m			;3586	f8 	. 
	ld l,b			;3587	68 	h 
	ld l,b			;3588	68 	h 
	ei			;3589	fb 	. 
	ld a,b			;358a	78 	x 
	ret m			;358b	f8 	. 
	ret m			;358c	f8 	. 
	ld a,c			;358d	79 	y 
	ret m			;358e	f8 	. 
	ld l,b			;358f	68 	h 
	ld l,b			;3590	68 	h 
	ld sp,hl			;3591	f9 	. 
	ld a,b			;3592	78 	x 
	ret m			;3593	f8 	. 
	ret m			;3594	f8 	. 
	ld a,c			;3595	79 	y 
	ld a,b			;3596	78 	x 
	ld l,b			;3597	68 	h 
	ld l,b			;3598	68 	h 
	pop af			;3599	f1 	. 
	ld a,b			;359a	78 	x 
	ret m			;359b	f8 	. 
	ret m			;359c	f8 	. 
	ld a,c			;359d	79 	y 
	ld a,b			;359e	78 	x 
	ld l,b			;359f	68 	h 
	ld l,b			;35a0	68 	h 
	pop af			;35a1	f1 	. 
	ld (hl),b			;35a2	70 	p 
	ret m			;35a3	f8 	. 
	ret m			;35a4	f8 	. 
	ld a,b			;35a5	78 	x 
	ld a,b			;35a6	78 	x 
	ld l,b			;35a7	68 	h 
	ld l,b			;35a8	68 	h 
	pop af			;35a9	f1 	. 
	ld (hl),b			;35aa	70 	p 
	ret p			;35ab	f0 	. 
	ld a,b			;35ac	78 	x 
	ld a,b			;35ad	78 	x 
	ld a,b			;35ae	78 	x 
	ld l,b			;35af	68 	h 
	ld l,b			;35b0	68 	h 
	ret p			;35b1	f0 	. 
	ld (hl),b			;35b2	70 	p 
	ld (hl),b			;35b3	70 	p 
	ld a,b			;35b4	78 	x 
	ld a,b			;35b5	78 	x 
	ld a,b			;35b6	78 	x 
	ld l,b			;35b7	68 	h 
	ld l,b			;35b8	68 	h 
	ld (hl),b			;35b9	70 	p 
	ld (hl),b			;35ba	70 	p 
	ld (hl),b			;35bb	70 	p 
	ld (hl),b			;35bc	70 	p 
	ld a,b			;35bd	78 	x 
	ld a,b			;35be	78 	x 
	ld l,b			;35bf	68 	h 
	ld l,b			;35c0	68 	h 
	ld (hl),b			;35c1	70 	p 
	ld (hl),b			;35c2	70 	p 
	ld (hl),b			;35c3	70 	p 
	ld (hl),b			;35c4	70 	p 
	ld (hl),b			;35c5	70 	p 
	ld a,b			;35c6	78 	x 
	ld l,b			;35c7	68 	h 
	ld l,b			;35c8	68 	h 
	ld (hl),b			;35c9	70 	p 
	ld (hl),b			;35ca	70 	p 
	ld (hl),b			;35cb	70 	p 
	ld (hl),b			;35cc	70 	p 
	ld (hl),b			;35cd	70 	p 
	ld (hl),b			;35ce	70 	p 
	ld l,b			;35cf	68 	h 
	ld l,b			;35d0	68 	h 
	ld (hl),b			;35d1	70 	p 
	ld (hl),b			;35d2	70 	p 
	ld (hl),b			;35d3	70 	p 
	ld (hl),b			;35d4	70 	p 
	ld (hl),b			;35d5	70 	p 
	ld (hl),b			;35d6	70 	p 
	ld h,b			;35d7	60 	` 
	ld l,b			;35d8	68 	h 
	ld (hl),b			;35d9	70 	p 
	ld (hl),b			;35da	70 	p 
	ld (hl),b			;35db	70 	p 
	ld (hl),b			;35dc	70 	p 
	ld (hl),b			;35dd	70 	p 
	ld (hl),b			;35de	70 	p 
	ld h,b			;35df	60 	` 
	jr nz,$+98		;35e0	20 60 	  ` 
	ld (hl),b			;35e2	70 	p 
	ld (hl),b			;35e3	70 	p 
	ld (hl),b			;35e4	70 	p 
	ld (hl),b			;35e5	70 	p 
	ld (hl),b			;35e6	70 	p 
	ld h,b			;35e7	60 	` 
	jr nz,$+34		;35e8	20 20 	    
	ld (hl),b			;35ea	70 	p 
	ld (hl),b			;35eb	70 	p 
	ld (hl),b			;35ec	70 	p 
	ld (hl),b			;35ed	70 	p 
	ld (hl),b			;35ee	70 	p 
	jr nz,l3611h		;35ef	20 20 	    
	jr nz,l3613h		;35f1	20 20 	    
	ld h,b			;35f3	60 	` 
	ld (hl),b			;35f4	70 	p 
	ld h,b			;35f5	60 	` 
	ld (hl),b			;35f6	70 	p 
	jr nz,l3619h		;35f7	20 20 	    
	jr nz,l361bh		;35f9	20 20 	    
	jr nz,l366dh		;35fb	20 70 	  p 
	ld h,b			;35fd	60 	` 
	ld (hl),b			;35fe	70 	p 
	jr nz,l3621h		;35ff	20 20 	    
	jr nz,l3623h		;3601	20 20 	    
	jr nz,l3635h		;3603	20 30 	  0 
	ld h,b			;3605	60 	` 
	ld (hl),b			;3606	70 	p 
	jr nz,l3629h		;3607	20 20 	    
	jr nz,l362bh		;3609	20 20 	    
	jr nz,l363dh		;360b	20 30 	  0 
	jr nz,l366fh		;360d	20 60 	  ` 
	jr nz,l3631h		;360f	20 20 	    
l3611h:
	jr nz,l3633h		;3611	20 20 	    
l3613h:
	jr nz,l3635h		;3613	20 20 	    
	jr nz,l3677h		;3615	20 60 	  ` 
	jr nz,l3619h		;3617	20 00 	  . 
l3619h:
	jr nz,l363bh		;3619	20 20 	    
l361bh:
	jr nz,l363dh		;361b	20 20 	    
	jr nz,l363fh		;361d	20 20 	    
	jr nz,l3621h		;361f	20 00 	  . 
l3621h:
	jr nz,l3643h		;3621	20 20 	    
l3623h:
	jr nz,l3645h		;3623	20 20 	    
	jr nz,l3647h		;3625	20 20 	    
	nop			;3627	00 	. 
	nop			;3628	00 	. 
l3629h:
	jr nz,l364bh		;3629	20 20 	    
l362bh:
	jr nz,l364dh		;362b	20 20 	    
	jr nz,l362fh		;362d	20 00 	  . 
l362fh:
	nop			;362f	00 	. 
	nop			;3630	00 	. 
l3631h:
	jr nz,l3653h		;3631	20 20 	    
l3633h:
	jr nz,l3655h		;3633	20 20 	    
l3635h:
	nop			;3635	00 	. 
	nop			;3636	00 	. 
	nop			;3637	00 	. 
	nop			;3638	00 	. 
	nop			;3639	00 	. 
	nop			;363a	00 	. 
l363bh:
	nop			;363b	00 	. 
	nop			;363c	00 	. 
l363dh:
	nop			;363d	00 	. 
	nop			;363e	00 	. 
l363fh:
	nop			;363f	00 	. 
	nop			;3640	00 	. 
l3641h:
	ld (hl),00bh		;3641	36 0b 	6 . 
l3643h:
	jr nz,l3665h		;3643	20 20 	    
l3645h:
	jr nz,l3667h		;3645	20 20 	    
l3647h:
	nop			;3647	00 	. 
	nop			;3648	00 	. 
	nop			;3649	00 	. 
	nop			;364a	00 	. 
l364bh:
	jr nz,l366dh		;364b	20 20 	    
l364dh:
	jr nz,l366fh		;364d	20 20 	    
	jr nz,l3651h		;364f	20 00 	  . 
l3651h:
	nop			;3651	00 	. 
	nop			;3652	00 	. 
l3653h:
	jr nz,l3675h		;3653	20 20 	    
l3655h:
	jr nz,l3677h		;3655	20 20 	    
	jr nz,l3679h		;3657	20 20 	    
	nop			;3659	00 	. 
	nop			;365a	00 	. 
	jr nz,l367dh		;365b	20 20 	    
	jr nz,l367fh		;365d	20 20 	    
	jr nz,l3681h		;365f	20 20 	    
	jr nz,l3663h		;3661	20 00 	  . 
l3663h:
	jr nz,l3685h		;3663	20 20 	    
l3665h:
	jr nz,l3697h		;3665	20 30 	  0 
l3667h:
	jr nz,l36c9h		;3667	20 60 	  ` 
	jr nz,l368bh		;3669	20 20 	    
	jr nz,l368dh		;366b	20 20 	    
l366dh:
	jr nc,l369fh		;366d	30 30 	0 0 
l366fh:
	ld h,b			;366f	60 	` 
	ld (hl),b			;3670	70 	p 
	jr nz,$+34		;3671	20 20 	    
	jr nz,l3695h		;3673	20 20 	    
l3675h:
	jr nc,l36e7h		;3675	30 70 	0 p 
l3677h:
	ld h,b			;3677	60 	` 
	ld (hl),b			;3678	70 	p 
l3679h:
	jr nz,$+34		;3679	20 20 	    
	jr nz,l369dh		;367b	20 20 	    
l367dh:
	ld (hl),b			;367d	70 	p 
	ld (hl),b			;367e	70 	p 
l367fh:
	ld (hl),b			;367f	70 	p 
	ld (hl),b			;3680	70 	p 
l3681h:
	jr nz,$+34		;3681	20 20 	    
	jr nz,l36f5h		;3683	20 70 	  p 
l3685h:
	ld (hl),b			;3685	70 	p 
	ld (hl),b			;3686	70 	p 
	ld (hl),b			;3687	70 	p 
	ld (hl),b			;3688	70 	p 
	jr nz,l36abh		;3689	20 20 	    
l368bh:
	ld h,b			;368b	60 	` 
	ld (hl),b			;368c	70 	p 
l368dh:
	ld (hl),b			;368d	70 	p 
	ld (hl),b			;368e	70 	p 
	ld (hl),b			;368f	70 	p 
	ld (hl),b			;3690	70 	p 
	ld h,b			;3691	60 	` 
	jr nz,l3704h		;3692	20 70 	  p 
	ld (hl),b			;3694	70 	p 
l3695h:
	ld (hl),b			;3695	70 	p 
	ld (hl),b			;3696	70 	p 
l3697h:
	ld (hl),b			;3697	70 	p 
	ld (hl),b			;3698	70 	p 
	ld h,b			;3699	60 	` 
	jr nz,l370ch		;369a	20 70 	  p 
	ld (hl),b			;369c	70 	p 
l369dh:
	ld (hl),b			;369d	70 	p 
	ld (hl),b			;369e	70 	p 
l369fh:
	ld (hl),b			;369f	70 	p 
	ld (hl),b			;36a0	70 	p 
	ld h,b			;36a1	60 	` 
	jr z,l3714h		;36a2	28 70 	( p 
	ld (hl),b			;36a4	70 	p 
	ld (hl),b			;36a5	70 	p 
	ld (hl),b			;36a6	70 	p 
	ld (hl),b			;36a7	70 	p 
	ld (hl),b			;36a8	70 	p 
	ld l,b			;36a9	68 	h 
	ld l,b			;36aa	68 	h 
l36abh:
	ld (hl),b			;36ab	70 	p 
	ld (hl),b			;36ac	70 	p 
	ld (hl),b			;36ad	70 	p 
	ld (hl),b			;36ae	70 	p 
	ld (hl),b			;36af	70 	p 
	ld a,b			;36b0	78 	x 
	ld l,b			;36b1	68 	h 
	ld l,b			;36b2	68 	h 
	ld (hl),b			;36b3	70 	p 
	ld (hl),b			;36b4	70 	p 
	ld (hl),b			;36b5	70 	p 
	ld (hl),b			;36b6	70 	p 
	ld a,b			;36b7	78 	x 
	ld a,b			;36b8	78 	x 
	ld l,b			;36b9	68 	h 
	ld l,b			;36ba	68 	h 
	pop af			;36bb	f1 	. 
	ld (hl),b			;36bc	70 	p 
	ld (hl),b			;36bd	70 	p 
	ld a,b			;36be	78 	x 
	ld a,b			;36bf	78 	x 
	ld a,b			;36c0	78 	x 
	ld l,b			;36c1	68 	h 
	ld l,b			;36c2	68 	h 
	pop af			;36c3	f1 	. 
	ld (hl),b			;36c4	70 	p 
	ret m			;36c5	f8 	. 
	ld a,b			;36c6	78 	x 
	ld a,b			;36c7	78 	x 
	ld a,b			;36c8	78 	x 
l36c9h:
	ld l,b			;36c9	68 	h 
	ld l,b			;36ca	68 	h 
	pop af			;36cb	f1 	. 
	ld (hl),b			;36cc	70 	p 
	ret m			;36cd	f8 	. 
	ret m			;36ce	f8 	. 
	ld a,b			;36cf	78 	x 
	ld a,b			;36d0	78 	x 
	ld l,b			;36d1	68 	h 
	ld l,b			;36d2	68 	h 
	pop af			;36d3	f1 	. 
	ld a,b			;36d4	78 	x 
	ret m			;36d5	f8 	. 
	ret m			;36d6	f8 	. 
	ld a,c			;36d7	79 	y 
	ld a,b			;36d8	78 	x 
	ld l,b			;36d9	68 	h 
	ld l,b			;36da	68 	h 
	ld sp,hl			;36db	f9 	. 
	ld a,b			;36dc	78 	x 
	ret m			;36dd	f8 	. 
	ret m			;36de	f8 	. 
	ld a,c			;36df	79 	y 
	ld a,b			;36e0	78 	x 
	ld l,b			;36e1	68 	h 
	ld l,b			;36e2	68 	h 
	ei			;36e3	fb 	. 
	ld a,b			;36e4	78 	x 
	ret m			;36e5	f8 	. 
	ret m			;36e6	f8 	. 
l36e7h:
	ld a,c			;36e7	79 	y 
	ret m			;36e8	f8 	. 
	ld l,b			;36e9	68 	h 
	ld l,b			;36ea	68 	h 
	rst 38h			;36eb	ff 	. 
	ld a,(hl)			;36ec	7e 	~ 
	ret m			;36ed	f8 	. 
	ret m			;36ee	f8 	. 
	ld a,c			;36ef	79 	y 
	ret m			;36f0	f8 	. 
	ld l,b			;36f1	68 	h 
	ld l,d			;36f2	6a 	j 
	rst 38h			;36f3	ff 	. 
	ld a,(hl)			;36f4	7e 	~ 
l36f5h:
	cp 0f8h		;36f5	fe f8 	. . 
	ld a,c			;36f7	79 	y 
	ret m			;36f8	f8 	. 
	ret pe			;36f9	e8 	. 
	ld l,(hl)			;36fa	6e 	n 
	rst 38h			;36fb	ff 	. 
	ld a,(hl)			;36fc	7e 	~ 
	cp 0feh		;36fd	fe fe 	. . 
	ld a,c			;36ff	79 	y 
	ret m			;3700	f8 	. 
	call pe,0ff6eh		;3701	ec 6e ff 	. n . 
l3704h:
	ld a,(hl)			;3704	7e 	~ 
	cp 0ffh		;3705	fe ff 	. . 
	ld a,e			;3707	7b 	{ 
	call m,sub_6eech		;3708	fc ec 6e 	. . n 
	rst 38h			;370b	ff 	. 
l370ch:
	ld a,(hl)			;370c	7e 	~ 
	cp 0ffh		;370d	fe ff 	. . 
	ld a,a			;370f	7f 	 
	cp 0eeh		;3710	fe ee 	. . 
	ld l,(hl)			;3712	6e 	n 
	rst 38h			;3713	ff 	. 
l3714h:
	ld a,(hl)			;3714	7e 	~ 
	cp 0ffh		;3715	fe ff 	. . 
	ld a,a			;3717	7f 	 
	cp 0eeh		;3718	fe ee 	. . 
	xor 0dfh		;371a	ee df 	. . 
	ld e,(hl)			;371c	5e 	^ 
	sbc a,0dfh		;371d	de df 	. . 
	ld a,a			;371f	7f 	 
	cp 0eeh		;3720	fe ee 	. . 
	xor 0dfh		;3722	ee df 	. . 
	ld e,(hl)			;3724	5e 	^ 
	sbc a,0dfh		;3725	de df 	. . 
	ld e,a			;3727	5f 	_ 
	cp 0eeh		;3728	fe ee 	. . 
	xor 0dfh		;372a	ee df 	. . 
	ld e,(hl)			;372c	5e 	^ 
	sbc a,0dfh		;372d	de df 	. . 
	ld e,a			;372f	5f 	_ 
	sbc a,0eeh		;3730	de ee 	. . 
	xor 0dfh		;3732	ee df 	. . 
	ld e,(hl)			;3734	5e 	^ 
	sbc a,0dfh		;3735	de df 	. . 
	ld e,a			;3737	5f 	_ 
	sbc a,0ceh		;3738	de ce 	. . 
	xor 0dfh		;373a	ee df 	. . 
	ld e,(hl)			;373c	5e 	^ 
	sbc a,0cfh		;373d	de cf 	. . 
	ld e,a			;373f	5f 	_ 
	sbc a,(hl)			;3740	9e 	. 
	adc a,0ceh		;3741	ce ce 	. . 
	rst 18h			;3743	df 	. 
	ld e,(hl)			;3744	5e 	^ 
	adc a,0cfh		;3745	ce cf 	. . 
	rra			;3747	1f 	. 
	adc a,(hl)			;3748	8e 	. 
	adc a,0ceh		;3749	ce ce 	. . 
	rst 18h			;374b	df 	. 
	ld e,(hl)			;374c	5e 	^ 
	adc a,08fh		;374d	ce 8f 	. . 
	rra			;374f	1f 	. 
	adc a,(hl)			;3750	8e 	. 
	adc a,0ceh		;3751	ce ce 	. . 
	rst 18h			;3753	df 	. 
	ld e,(hl)			;3754	5e 	^ 
	adc a,(hl)			;3755	8e 	. 
	adc a,a			;3756	8f 	. 
	rrca			;3757	0f 	. 
	adc a,(hl)			;3758	8e 	. 
	adc a,0ceh		;3759	ce ce 	. . 
	rst 18h			;375b	df 	. 
	ld c,08eh		;375c	0e 8e 	. . 
	adc a,a			;375e	8f 	. 
	rrca			;375f	0f 	. 
	adc a,(hl)			;3760	8e 	. 
	adc a,0ceh		;3761	ce ce 	. . 
	sbc a,a			;3763	9f 	. 
	ld c,08eh		;3764	0e 8e 	. . 
	adc a,a			;3766	8f 	. 
	rrca			;3767	0f 	. 
	adc a,(hl)			;3768	8e 	. 
	adc a,(hl)			;3769	8e 	. 
	adc a,08fh		;376a	ce 8f 	. . 
	ld c,08eh		;376c	0e 8e 	. . 
	adc a,a			;376e	8f 	. 
	rrca			;376f	0f 	. 
	adc a,(hl)			;3770	8e 	. 
	adc a,(hl)			;3771	8e 	. 
	adc a,08fh		;3772	ce 8f 	. . 
	ld c,08eh		;3774	0e 8e 	. . 
	adc a,a			;3776	8f 	. 
	rrca			;3777	0f 	. 
	adc a,(hl)			;3778	8e 	. 
	adc a,(hl)			;3779	8e 	. 
	add a,08fh		;377a	c6 8f 	. . 
	ld c,08eh		;377c	0e 8e 	. . 
	adc a,a			;377e	8f 	. 
	rrca			;377f	0f 	. 
	adc a,(hl)			;3780	8e 	. 
	add a,(hl)			;3781	86 	. 
	add a,(hl)			;3782	86 	. 
	adc a,a			;3783	8f 	. 
	ld c,08eh		;3784	0e 8e 	. . 
	adc a,a			;3786	8f 	. 
	rrca			;3787	0f 	. 
	add a,(hl)			;3788	86 	. 
	add a,(hl)			;3789	86 	. 
	add a,(hl)			;378a	86 	. 
	adc a,a			;378b	8f 	. 
	ld c,08eh		;378c	0e 8e 	. . 
	adc a,a			;378e	8f 	. 
	rlca			;378f	07 	. 
	add a,(hl)			;3790	86 	. 
	add a,(hl)			;3791	86 	. 
	add a,(hl)			;3792	86 	. 
	ld c,00eh		;3793	0e 0e 	. . 
	adc a,(hl)			;3795	8e 	. 
	add a,a			;3796	87 	. 
	rlca			;3797	07 	. 
	add a,(hl)			;3798	86 	. 
	add a,(hl)			;3799	86 	. 
	add a,(hl)			;379a	86 	. 
	ld c,00eh		;379b	0e 0e 	. . 
	ld b,087h		;379d	06 87 	. . 
	rlca			;379f	07 	. 
	add a,(hl)			;37a0	86 	. 
	add a,(hl)			;37a1	86 	. 
	add a,(hl)			;37a2	86 	. 
	ld c,00eh		;37a3	0e 0e 	. . 
	ld b,007h		;37a5	06 07 	. . 
	rlca			;37a7	07 	. 
	add a,(hl)			;37a8	86 	. 
	add a,(hl)			;37a9	86 	. 
	add a,(hl)			;37aa	86 	. 
	ld c,006h		;37ab	0e 06 	. . 
	ld b,007h		;37ad	06 07 	. . 
	ld b,086h		;37af	06 86 	. . 
	add a,(hl)			;37b1	86 	. 
	add a,(hl)			;37b2	86 	. 
	ld b,006h		;37b3	06 06 	. . 
	ld b,007h		;37b5	06 07 	. . 
	ld b,086h		;37b7	06 86 	. . 
	add a,(hl)			;37b9	86 	. 
	add a,(hl)			;37ba	86 	. 
	inc b			;37bb	04 	. 
	ld b,006h		;37bc	06 06 	. . 
	rlca			;37be	07 	. 
	ld b,006h		;37bf	06 06 	. . 
	add a,(hl)			;37c1	86 	. 
	add a,(hl)			;37c2	86 	. 
	nop			;37c3	00 	. 
	nop			;37c4	00 	. 
	ld b,007h		;37c5	06 07 	. . 
	ld b,006h		;37c7	06 06 	. . 
	add a,(hl)			;37c9	86 	. 
	add a,h			;37ca	84 	. 
	nop			;37cb	00 	. 
	nop			;37cc	00 	. 
	nop			;37cd	00 	. 
	rlca			;37ce	07 	. 
	ld b,006h		;37cf	06 06 	. . 
	ld b,080h		;37d1	06 80 	. . 
	nop			;37d3	00 	. 
	nop			;37d4	00 	. 
	nop			;37d5	00 	. 
	ld bc,l0606h		;37d6	01 06 06 	. . . 
	ld (bc),a			;37d9	02 	. 
	add a,b			;37da	80 	. 
	nop			;37db	00 	. 
	nop			;37dc	00 	. 
	nop			;37dd	00 	. 
	nop			;37de	00 	. 
	inc b			;37df	04 	. 
	ld (bc),a			;37e0	02 	. 
	ld (bc),a			;37e1	02 	. 
	add a,b			;37e2	80 	. 
	nop			;37e3	00 	. 
	nop			;37e4	00 	. 
	nop			;37e5	00 	. 
	nop			;37e6	00 	. 
	nop			;37e7	00 	. 
	nop			;37e8	00 	. 
	nop			;37e9	00 	. 
	add a,b			;37ea	80 	. 
	nop			;37eb	00 	. 
	nop			;37ec	00 	. 
	nop			;37ed	00 	. 
	nop			;37ee	00 	. 
	nop			;37ef	00 	. 
	nop			;37f0	00 	. 
	nop			;37f1	00 	. 
	nop			;37f2	00 	. 
l37f3h:
	dec e			;37f3	1d 	. 
	jr l37f6h		;37f4	18 00 	. . 
l37f6h:
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
	jr nz,l3806h		;3804	20 00 	  . 
l3806h:
	nop			;3806	00 	. 
	nop			;3807	00 	. 
	nop			;3808	00 	. 
	nop			;3809	00 	. 
	nop			;380a	00 	. 
	jr nz,l382fh		;380b	20 22 	  " 
	ld b,b			;380d	40 	@ 
	nop			;380e	00 	. 
	nop			;380f	00 	. 
	nop			;3810	00 	. 
	ld bc,02020h		;3811	01 20 20 	.     
	ld (l4041h),hl		;3814	22 41 40 	" A @ 
	nop			;3817	00 	. 
	nop			;3818	00 	. 
	ld bc,02020h		;3819	01 20 20 	.     
	ld h,d			;381c	62 	b 
	ld b,c			;381d	41 	A 
	ld b,b			;381e	40 	@ 
	ld b,b			;381f	40 	@ 
	nop			;3820	00 	. 
	ld hl,l6020h		;3821	21 20 60 	!   ` 
	ld h,d			;3824	62 	b 
	ld b,c			;3825	41 	A 
	ld b,b			;3826	40 	@ 
	ld b,b			;3827	40 	@ 
	ld b,b			;3828	40 	@ 
	ld hl,l6020h		;3829	21 20 60 	!   ` 
	ld h,d			;382c	62 	b 
	ld e,c			;382d	59 	Y 
	ld e,b			;382e	58 	X 
l382fh:
	ld c,b			;382f	48 	H 
	ld c,b			;3830	48 	H 
	ld l,c			;3831	69 	i 
	jr z,l389ch		;3832	28 68 	( h 
	ld l,d			;3834	6a 	j 
	ld e,l			;3835	5d 	] 
	ld e,b			;3836	58 	X 
	ld c,b			;3837	48 	H 
	ld c,b			;3838	48 	H 
	ld l,l			;3839	6d 	m 
	ld l,h			;383a	6c 	l 
	ld l,h			;383b	6c 	l 
	ld l,(hl)			;383c	6e 	n 
	ld e,a			;383d	5f 	_ 
	ld e,h			;383e	5c 	\ 
	ld e,h			;383f	5c 	\ 
	ld l,l			;3840	6d 	m 
	ld l,l			;3841	6d 	m 
	ld l,h			;3842	6c 	l 
	ld l,(hl)			;3843	6e 	n 
	xor 0dfh		;3844	ee df 	. . 
	ld e,(hl)			;3846	5e 	^ 
	ld a,(hl)			;3847	7e 	~ 
	ld l,a			;3848	6f 	o 
	ld l,a			;3849	6f 	o 
	ld l,(hl)			;384a	6e 	n 
l384bh:
	ld l,(hl)			;384b	6e 	n 
	xor 0dfh		;384c	ee df 	. . 
	ld a,(hl)			;384e	7e 	~ 
	ld a,(hl)			;384f	7e 	~ 
	ld a,a			;3850	7f 	 
	ld a,a			;3851	7f 	 
	ld a,(hl)			;3852	7e 	~ 
	ld l,(hl)			;3853	6e 	n 
	xor 0dfh		;3854	ee df 	. . 
	ld a,(hl)			;3856	7e 	~ 
	cp 07fh		;3857	fe 7f 	.  
	ld a,a			;3859	7f 	 
	ld a,(hl)			;385a	7e 	~ 
	ld l,(hl)			;385b	6e 	n 
	xor 0ffh		;385c	ee ff 	. . 
	ld a,(hl)			;385e	7e 	~ 
	cp 0ffh		;385f	fe ff 	. . 
	ld a,a			;3861	7f 	 
	cp 06eh		;3862	fe 6e 	. n 
	xor 0ffh		;3864	ee ff 	. . 
	ld a,(hl)			;3866	7e 	~ 
	cp 0ffh		;3867	fe ff 	. . 
	ld a,a			;3869	7f 	 
	cp 0eeh		;386a	fe ee 	. . 
	xor 0ffh		;386c	ee ff 	. . 
	ld a,(hl)			;386e	7e 	~ 
	cp 0ffh		;386f	fe ff 	. . 
	ld a,a			;3871	7f 	 
	cp 0eeh		;3872	fe ee 	. . 
	adc a,0ffh		;3874	ce ff 	. . 
	ld a,(hl)			;3876	7e 	~ 
	cp 0ffh		;3877	fe ff 	. . 
	ld a,a			;3879	7f 	 
	cp 0ceh		;387a	fe ce 	. . 
	call z,sub_7ebfh		;387c	cc bf 7e 	. . ~ 
	cp 0ffh		;387f	fe ff 	. . 
	ld a,(hl)			;3881	7e 	~ 
	sbc a,0ceh		;3882	de ce 	. . 
	call z,sub_3ebeh		;3884	cc be 3e 	. . > 
	cp 0ffh		;3887	fe ff 	. . 
	ld a,(hl)			;3889	7e 	~ 
	sbc a,0ceh		;388a	de ce 	. . 
	adc a,h			;388c	8c 	. 
	cp (hl)			;388d	be 	. 
	ld a,0beh		;388e	3e be 	> . 
	rst 38h			;3890	ff 	. 
	ld e,(hl)			;3891	5e 	^ 
	sbc a,08eh		;3892	de 8e 	. . 
	adc a,h			;3894	8c 	. 
	cp (hl)			;3895	be 	. 
	ld a,0beh		;3896	3e be 	> . 
	cp a			;3898	bf 	. 
	ld e,(hl)			;3899	5e 	^ 
	sbc a,08eh		;389a	de 8e 	. . 
l389ch:
	adc a,h			;389c	8c 	. 
	and (hl)			;389d	a6 	. 
	ld h,0b6h		;389e	26 b6 	& . 
	or a			;38a0	b7 	. 
	ld d,0d6h		;38a1	16 d6 	. . 
	add a,(hl)			;38a3	86 	. 
	add a,h			;38a4	84 	. 
	and d			;38a5	a2 	. 
	ld h,0b6h		;38a6	26 b6 	& . 
	or a			;38a8	b7 	. 
	ld (de),a			;38a9	12 	. 
	sub d			;38aa	92 	. 
	add a,d			;38ab	82 	. 
	add a,b			;38ac	80 	. 
	and b			;38ad	a0 	. 
	ld (092a2h),hl		;38ae	22 a2 92 	" . . 
	ld (de),a			;38b1	12 	. 
	sub d			;38b2	92 	. 
	add a,b			;38b3	80 	. 
	nop			;38b4	00 	. 
	jr nz,l38d7h		;38b5	20 20 	    
	add a,b			;38b7	80 	. 
	sub b			;38b8	90 	. 
	djnz l384bh		;38b9	10 90 	. . 
	add a,b			;38bb	80 	. 
	nop			;38bc	00 	. 
	jr nz,l38bfh		;38bd	20 00 	  . 
l38bfh:
	add a,b			;38bf	80 	. 
	add a,b			;38c0	80 	. 
	nop			;38c1	00 	. 
	add a,b			;38c2	80 	. 
	add a,b			;38c3	80 	. 
	nop			;38c4	00 	. 
	jr nz,l38c7h		;38c5	20 00 	  . 
l38c7h:
	nop			;38c7	00 	. 
l38c8h:
	add a,b			;38c8	80 	. 
	nop			;38c9	00 	. 
	add a,b			;38ca	80 	. 
	add a,b			;38cb	80 	. 
	nop			;38cc	00 	. 
	nop			;38cd	00 	. 
	nop			;38ce	00 	. 
	nop			;38cf	00 	. 
	nop			;38d0	00 	. 
	nop			;38d1	00 	. 
	nop			;38d2	00 	. 
	add a,b			;38d3	80 	. 
	nop			;38d4	00 	. 
	nop			;38d5	00 	. 
	nop			;38d6	00 	. 
l38d7h:
	nop			;38d7	00 	. 
	nop			;38d8	00 	. 
	nop			;38d9	00 	. 
	nop			;38da	00 	. 
	nop			;38db	00 	. 
	nop			;38dc	00 	. 
l38ddh:
	inc e			;38dd	1c 	. 
	jr l38e0h		;38de	18 00 	. . 
l38e0h:
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
	jr nz,l38f0h		;38ee	20 00 	  . 
l38f0h:
	nop			;38f0	00 	. 
	nop			;38f1	00 	. 
	nop			;38f2	00 	. 
	nop			;38f3	00 	. 
	nop			;38f4	00 	. 
	jr nz,l3919h		;38f5	20 22 	  " 
	ld b,b			;38f7	40 	@ 
	nop			;38f8	00 	. 
	nop			;38f9	00 	. 
	nop			;38fa	00 	. 
	ld bc,02020h		;38fb	01 20 20 	.     
	ld (l4041h),hl		;38fe	22 41 40 	" A @ 
	nop			;3901	00 	. 
	nop			;3902	00 	. 
	ld bc,02020h		;3903	01 20 20 	.     
	ld h,d			;3906	62 	b 
	ld b,c			;3907	41 	A 
	ld b,b			;3908	40 	@ 
	ld b,b			;3909	40 	@ 
	nop			;390a	00 	. 
	ld hl,l6020h		;390b	21 20 60 	!   ` 
	ld h,d			;390e	62 	b 
	ld b,c			;390f	41 	A 
	ld b,b			;3910	40 	@ 
	ld b,b			;3911	40 	@ 
	ld b,b			;3912	40 	@ 
	ld hl,l6020h		;3913	21 20 60 	!   ` 
	ld h,d			;3916	62 	b 
	ld e,c			;3917	59 	Y 
	ld e,b			;3918	58 	X 
l3919h:
	ld c,b			;3919	48 	H 
	ld c,b			;391a	48 	H 
	ld l,c			;391b	69 	i 
	jr z,l3986h		;391c	28 68 	( h 
	ld l,d			;391e	6a 	j 
	ld e,l			;391f	5d 	] 
	ld e,b			;3920	58 	X 
	ld c,b			;3921	48 	H 
	ld c,b			;3922	48 	H 
	ld l,l			;3923	6d 	m 
	ld l,h			;3924	6c 	l 
	ld l,h			;3925	6c 	l 
	ld l,(hl)			;3926	6e 	n 
	ld e,a			;3927	5f 	_ 
	ld e,h			;3928	5c 	\ 
	ld e,h			;3929	5c 	\ 
	ld l,l			;392a	6d 	m 
	ld l,l			;392b	6d 	m 
	ld l,h			;392c	6c 	l 
	ld l,(hl)			;392d	6e 	n 
	xor 0dfh		;392e	ee df 	. . 
	ld e,(hl)			;3930	5e 	^ 
	ld a,(hl)			;3931	7e 	~ 
	ld l,a			;3932	6f 	o 
	ld l,a			;3933	6f 	o 
	ld l,(hl)			;3934	6e 	n 
	ld l,(hl)			;3935	6e 	n 
	xor 0dfh		;3936	ee df 	. . 
	ld a,(hl)			;3938	7e 	~ 
	ld a,(hl)			;3939	7e 	~ 
	ld a,a			;393a	7f 	 
	ld a,a			;393b	7f 	 
	ld a,(hl)			;393c	7e 	~ 
	ld l,(hl)			;393d	6e 	n 
	xor 0dfh		;393e	ee df 	. . 
	ld a,(hl)			;3940	7e 	~ 
	cp 07fh		;3941	fe 7f 	.  
	ld a,a			;3943	7f 	 
	ld a,(hl)			;3944	7e 	~ 
	ld l,(hl)			;3945	6e 	n 
	xor 0ffh		;3946	ee ff 	. . 
	ld a,(hl)			;3948	7e 	~ 
	cp 0ffh		;3949	fe ff 	. . 
	ld a,a			;394b	7f 	 
	cp 06eh		;394c	fe 6e 	. n 
	xor 0ffh		;394e	ee ff 	. . 
	ld a,(hl)			;3950	7e 	~ 
	cp 0ffh		;3951	fe ff 	. . 
	ld a,a			;3953	7f 	 
	cp 0eeh		;3954	fe ee 	. . 
	xor 0ffh		;3956	ee ff 	. . 
	ld a,(hl)			;3958	7e 	~ 
	cp 0ffh		;3959	fe ff 	. . 
	ld a,a			;395b	7f 	 
	cp 06eh		;395c	fe 6e 	. n 
	xor 0dfh		;395e	ee df 	. . 
	ld a,(hl)			;3960	7e 	~ 
	cp 07fh		;3961	fe 7f 	.  
	ld a,a			;3963	7f 	 
	ld a,(hl)			;3964	7e 	~ 
	ld l,(hl)			;3965	6e 	n 
	xor 0dfh		;3966	ee df 	. . 
	ld e,(hl)			;3968	5e 	^ 
	cp 06fh		;3969	fe 6f 	. o 
	ld l,a			;396b	6f 	o 
	ld l,(hl)			;396c	6e 	n 
	ld l,(hl)			;396d	6e 	n 
	xor 05fh		;396e	ee 5f 	. _ 
	ld e,h			;3970	5c 	\ 
	call c,sub_6d6dh		;3971	dc 6d 6d 	. m m 
	ld l,h			;3974	6c 	l 
	ld l,(hl)			;3975	6e 	n 
	xor 05dh		;3976	ee 5d 	. ] 
	ld e,b			;3978	58 	X 
	ret z			;3979	c8 	. 
	ld c,b			;397a	48 	H 
	ld l,l			;397b	6d 	m 
l397ch:
	ld l,h			;397c	6c 	l 
	ld l,h			;397d	6c 	l 
	ld l,(hl)			;397e	6e 	n 
	ld e,c			;397f	59 	Y 
	ld e,b			;3980	58 	X 
	ret z			;3981	c8 	. 
	ld c,b			;3982	48 	H 
	ld l,c			;3983	69 	i 
	jr z,l39eeh		;3984	28 68 	( h 
l3986h:
	ld l,d			;3986	6a 	j 
	ld b,c			;3987	41 	A 
	ld b,b			;3988	40 	@ 
	ret nz			;3989	c0 	. 
	ld b,b			;398a	40 	@ 
	ld hl,l6020h		;398b	21 20 60 	!   ` 
	ld h,d			;398e	62 	b 
	ld b,c			;398f	41 	A 
	ld b,b			;3990	40 	@ 
	ret nz			;3991	c0 	. 
	nop			;3992	00 	. 
	ld hl,l6020h		;3993	21 20 60 	!   ` 
	ld h,d			;3996	62 	b 
	ld b,c			;3997	41 	A 
	ld b,b			;3998	40 	@ 
	add a,b			;3999	80 	. 
	nop			;399a	00 	. 
	ld bc,02020h		;399b	01 20 20 	.     
	ld h,d			;399e	62 	b 
	ld b,b			;399f	40 	@ 
	nop			;39a0	00 	. 
	add a,b			;39a1	80 	. 
	nop			;39a2	00 	. 
	ld bc,02020h		;39a3	01 20 20 	.     
	ld (l0000h),hl		;39a6	22 00 00 	" . . 
	add a,b			;39a9	80 	. 
	nop			;39aa	00 	. 
	nop			;39ab	00 	. 
	nop			;39ac	00 	. 
	jr nz,l39d1h		;39ad	20 22 	  " 
	nop			;39af	00 	. 
	nop			;39b0	00 	. 
	add a,b			;39b1	80 	. 
	nop			;39b2	00 	. 
	nop			;39b3	00 	. 
	nop			;39b4	00 	. 
	nop			;39b5	00 	. 
	jr nz,l39b8h		;39b6	20 00 	  . 
l39b8h:
	nop			;39b8	00 	. 
	add a,b			;39b9	80 	. 
	nop			;39ba	00 	. 
	nop			;39bb	00 	. 
	nop			;39bc	00 	. 
	nop			;39bd	00 	. 
	nop			;39be	00 	. 
l39bfh:
	jr z,l39cch		;39bf	28 0b 	( . 
	nop			;39c1	00 	. 
	nop			;39c2	00 	. 
	nop			;39c3	00 	. 
l39c4h:
	jr nc,l39c6h		;39c4	30 00 	0 . 
l39c6h:
	nop			;39c6	00 	. 
	nop			;39c7	00 	. 
	nop			;39c8	00 	. 
	nop			;39c9	00 	. 
	nop			;39ca	00 	. 
	nop			;39cb	00 	. 
l39cch:
	jr nc,l39ceh		;39cc	30 00 	0 . 
l39ceh:
	djnz l39d0h		;39ce	10 00 	. . 
l39d0h:
	nop			;39d0	00 	. 
l39d1h:
	nop			;39d1	00 	. 
l39d2h:
	nop			;39d2	00 	. 
	nop			;39d3	00 	. 
	jr nc,l39e6h		;39d4	30 10 	0 . 
	djnz l39d8h		;39d6	10 00 	. . 
l39d8h:
	nop			;39d8	00 	. 
	nop			;39d9	00 	. 
	nop			;39da	00 	. 
	djnz $-78		;39db	10 b0 	. . 
	jr nc,l3a2fh		;39dd	30 50 	0 P 
	nop			;39df	00 	. 
	nop			;39e0	00 	. 
	nop			;39e1	00 	. 
	nop			;39e2	00 	. 
	sub b			;39e3	90 	. 
	or b			;39e4	b0 	. 
	ld (hl),b			;39e5	70 	p 
l39e6h:
	ld (hl),b			;39e6	70 	p 
	nop			;39e7	00 	. 
	nop			;39e8	00 	. 
	add a,b			;39e9	80 	. 
	djnz l397ch		;39ea	10 90 	. . 
	ret p			;39ec	f0 	. 
	ld (hl),b			;39ed	70 	p 
l39eeh:
	ld (hl),b			;39ee	70 	p 
	jr nz,l39f1h		;39ef	20 00 	  . 
l39f1h:
	sub b			;39f1	90 	. 
	djnz l39c4h		;39f2	10 d0 	. . 
	ret p			;39f4	f0 	. 
	ld (hl),b			;39f5	70 	p 
	ret p			;39f6	f0 	. 
	and b			;39f7	a0 	. 
	nop			;39f8	00 	. 
	sub b			;39f9	90 	. 
	ld d,b			;39fa	50 	P 
	ret nc			;39fb	d0 	. 
	ret p			;39fc	f0 	. 
	ld (hl),b			;39fd	70 	p 
	ret p			;39fe	f0 	. 
	ret po			;39ff	e0 	. 
	jr z,l39d2h		;3a00	28 d0 	( . 
	ld d,b			;3a02	50 	P 
	ret nc			;3a03	d0 	. 
	ret p			;3a04	f0 	. 
	ld (hl),b			;3a05	70 	p 
	ret m			;3a06	f8 	. 
	ret po			;3a07	e0 	. 
	ld l,b			;3a08	68 	h 
	ret nc			;3a09	d0 	. 
	ld d,b			;3a0a	50 	P 
	ret nc			;3a0b	d0 	. 
	ret p			;3a0c	f0 	. 
	ld a,b			;3a0d	78 	x 
	ret m			;3a0e	f8 	. 
	ret po			;3a0f	e0 	. 
	ld l,b			;3a10	68 	h 
	ret nc			;3a11	d0 	. 
	ld d,b			;3a12	50 	P 
	ret nc			;3a13	d0 	. 
	ret m			;3a14	f8 	. 
	ld a,b			;3a15	78 	x 
	ret m			;3a16	f8 	. 
	ret po			;3a17	e0 	. 
	ld l,b			;3a18	68 	h 
	ret nc			;3a19	d0 	. 
	ld d,b			;3a1a	50 	P 
	ret c			;3a1b	d8 	. 
	ret m			;3a1c	f8 	. 
	ld a,b			;3a1d	78 	x 
	ret m			;3a1e	f8 	. 
	ret po			;3a1f	e0 	. 
	ld l,b			;3a20	68 	h 
	out (05ah),a		;3a21	d3 5a 	. Z 
	ret c			;3a23	d8 	. 
	ret m			;3a24	f8 	. 
	ld a,b			;3a25	78 	x 
	ret m			;3a26	f8 	. 
	ret po			;3a27	e0 	. 
	ld l,b			;3a28	68 	h 
	in a,(05eh)		;3a29	db 5e 	. ^ 
	jp c,l78f8h		;3a2b	da f8 78 	. . x 
	ret m			;3a2e	f8 	. 
l3a2fh:
	ret po			;3a2f	e0 	. 
	ld l,b			;3a30	68 	h 
	rst 18h			;3a31	df 	. 
	ld e,(hl)			;3a32	5e 	^ 
	sbc a,0fah		;3a33	de fa 	. . 
	ld a,c			;3a35	79 	y 
	ret m			;3a36	f8 	. 
	ret po			;3a37	e0 	. 
	ld l,b			;3a38	68 	h 
	rst 18h			;3a39	df 	. 
	ld e,(hl)			;3a3a	5e 	^ 
	sbc a,0feh		;3a3b	de fe 	. . 
	ld a,e			;3a3d	7b 	{ 
	ret m			;3a3e	f8 	. 
	ret po			;3a3f	e0 	. 
	ld l,h			;3a40	6c 	l 
	rst 18h			;3a41	df 	. 
	ld e,(hl)			;3a42	5e 	^ 
	sbc a,0ffh		;3a43	de ff 	. . 
	ld a,e			;3a45	7b 	{ 
	jp m,l6ce4h		;3a46	fa e4 6c 	. . l 
	rst 18h			;3a49	df 	. 
	ld e,(hl)			;3a4a	5e 	^ 
	sbc a,0ffh		;3a4b	de ff 	. . 
	ld a,e			;3a4d	7b 	{ 
	cp 0e6h		;3a4e	fe e6 	. . 
	ld l,h			;3a50	6c 	l 
	rst 18h			;3a51	df 	. 
	ld e,(hl)			;3a52	5e 	^ 
	sbc a,0ffh		;3a53	de ff 	. . 
	ld a,a			;3a55	7f 	 
	cp 0e6h		;3a56	fe e6 	. . 
	ld l,(hl)			;3a58	6e 	n 
	rst 18h			;3a59	df 	. 
	ld e,(hl)			;3a5a	5e 	^ 
	sbc a,0ffh		;3a5b	de ff 	. . 
	ld a,a			;3a5d	7f 	 
	cp 0e6h		;3a5e	fe e6 	. . 
	xor 0dfh		;3a60	ee df 	. . 
	ld e,(hl)			;3a62	5e 	^ 
	sbc a,0cfh		;3a63	de cf 	. . 
	ld a,a			;3a65	7f 	 
	cp 0e6h		;3a66	fe e6 	. . 
	xor 0dfh		;3a68	ee df 	. . 
	ld e,(hl)			;3a6a	5e 	^ 
	sbc a,0cfh		;3a6b	de cf 	. . 
	ld a,a			;3a6d	7f 	 
	xor 0e6h		;3a6e	ee e6 	. . 
	xor 0dfh		;3a70	ee df 	. . 
	ld e,(hl)			;3a72	5e 	^ 
	sbc a,0cfh		;3a73	de cf 	. . 
	ld l,a			;3a75	6f 	o 
	xor 0e6h		;3a76	ee e6 	. . 
	xor 0dfh		;3a78	ee df 	. . 
	ld e,(hl)			;3a7a	5e 	^ 
	adc a,04fh		;3a7b	ce 4f 	. O 
	ld c,a			;3a7d	4f 	O 
	xor (hl)			;3a7e	ae 	. 
	and 0eeh		;3a7f	e6 ee 	. . 
	rst 18h			;3a81	df 	. 
	ld e,(hl)			;3a82	5e 	^ 
	ld c,(hl)			;3a83	4e 	N 
	ld c,a			;3a84	4f 	O 
	rrca			;3a85	0f 	. 
	adc a,(hl)			;3a86	8e 	. 
	and 0eeh		;3a87	e6 ee 	. . 
	ld e,a			;3a89	5f 	_ 
	ld c,(hl)			;3a8a	4e 	N 
	ld c,(hl)			;3a8b	4e 	N 
	rrca			;3a8c	0f 	. 
	rrca			;3a8d	0f 	. 
	adc a,(hl)			;3a8e	8e 	. 
	add a,0eeh		;3a8f	c6 ee 	. . 
	ld c,a			;3a91	4f 	O 
	ld c,(hl)			;3a92	4e 	N 
	ld c,00fh		;3a93	0e 0f 	. . 
	rrca			;3a95	0f 	. 
	ld c,046h		;3a96	0e 46 	. F 
	xor 04fh		;3a98	ee 4f 	. O 
	ld c,00eh		;3a9a	0e 0e 	. . 
	rrca			;3a9c	0f 	. 
	rrca			;3a9d	0f 	. 
	ld c,006h		;3a9e	0e 06 	. . 
	add a,00fh		;3aa0	c6 0f 	. . 
	ld c,00eh		;3aa2	0e 0e 	. . 
	rrca			;3aa4	0f 	. 
	rrca			;3aa5	0f 	. 
	ld b,006h		;3aa6	06 06 	. . 
	add a,(hl)			;3aa8	86 	. 
	rrca			;3aa9	0f 	. 
	ld c,00eh		;3aaa	0e 0e 	. . 
	rrca			;3aac	0f 	. 
	rlca			;3aad	07 	. 
	ld b,006h		;3aae	06 06 	. . 
	add a,(hl)			;3ab0	86 	. 
	rrca			;3ab1	0f 	. 
	ld c,00eh		;3ab2	0e 0e 	. . 
	rlca			;3ab4	07 	. 
	rlca			;3ab5	07 	. 
	ld b,006h		;3ab6	06 06 	. . 
	add a,(hl)			;3ab8	86 	. 
	rrca			;3ab9	0f 	. 
	ld c,006h		;3aba	0e 06 	. . 
	rlca			;3abc	07 	. 
	rlca			;3abd	07 	. 
	ld b,006h		;3abe	06 06 	. . 
	add a,(hl)			;3ac0	86 	. 
	inc c			;3ac1	0c 	. 
	inc b			;3ac2	04 	. 
	ld b,007h		;3ac3	06 07 	. . 
	rlca			;3ac5	07 	. 
	ld b,006h		;3ac6	06 06 	. . 
	add a,(hl)			;3ac8	86 	. 
	inc b			;3ac9	04 	. 
	nop			;3aca	00 	. 
	inc b			;3acb	04 	. 
	rlca			;3acc	07 	. 
	rlca			;3acd	07 	. 
	ld b,006h		;3ace	06 06 	. . 
	add a,(hl)			;3ad0	86 	. 
	nop			;3ad1	00 	. 
	nop			;3ad2	00 	. 
	nop			;3ad3	00 	. 
	dec b			;3ad4	05 	. 
	ld b,006h		;3ad5	06 06 	. . 
	ld b,086h		;3ad7	06 86 	. . 
	nop			;3ad9	00 	. 
	nop			;3ada	00 	. 
	nop			;3adb	00 	. 
	ld bc,l0604h		;3adc	01 04 06 	. . . 
	ld b,082h		;3adf	06 82 	. . 
	nop			;3ae1	00 	. 
	nop			;3ae2	00 	. 
	nop			;3ae3	00 	. 
	nop			;3ae4	00 	. 
	inc b			;3ae5	04 	. 
	inc b			;3ae6	04 	. 
	ld (bc),a			;3ae7	02 	. 
	add a,d			;3ae8	82 	. 
	nop			;3ae9	00 	. 
	nop			;3aea	00 	. 
	nop			;3aeb	00 	. 
	nop			;3aec	00 	. 
	inc b			;3aed	04 	. 
	nop			;3aee	00 	. 
	nop			;3aef	00 	. 
	add a,d			;3af0	82 	. 
	nop			;3af1	00 	. 
	nop			;3af2	00 	. 
	nop			;3af3	00 	. 
	nop			;3af4	00 	. 
	nop			;3af5	00 	. 
	nop			;3af6	00 	. 
	nop			;3af7	00 	. 
	add a,b			;3af8	80 	. 
	nop			;3af9	00 	. 
	nop			;3afa	00 	. 
	nop			;3afb	00 	. 
	nop			;3afc	00 	. 
	nop			;3afd	00 	. 
	nop			;3afe	00 	. 
	nop			;3aff	00 	. 
	nop			;3b00	00 	. 
l3b01h:
	ld (0100bh),hl		;3b01	22 0b 10 	" . . 
	nop			;3b04	00 	. 
	djnz l3b17h		;3b05	10 10 	. . 
	nop			;3b07	00 	. 
	nop			;3b08	00 	. 
	nop			;3b09	00 	. 
	ld b,b			;3b0a	40 	@ 
	djnz l3b0dh		;3b0b	10 00 	. . 
l3b0dh:
	djnz $+18		;3b0d	10 10 	. . 
	nop			;3b0f	00 	. 
	djnz l3b12h		;3b10	10 00 	. . 
l3b12h:
	ld c,b			;3b12	48 	H 
	djnz l3b15h		;3b13	10 00 	. . 
l3b15h:
	djnz $+18		;3b15	10 10 	. . 
l3b17h:
	djnz $+18		;3b17	10 10 	. . 
	ex af,af'			;3b19	08 	. 
	ld c,b			;3b1a	48 	H 
	ld de,l1000h		;3b1b	11 00 10 	. . . 
	djnz l3b30h		;3b1e	10 10 	. . 
	jr l3b2ah		;3b20	18 08 	. . 
	ld c,b			;3b22	48 	H 
	ld de,l1000h		;3b23	11 00 10 	. . . 
	djnz l3b40h		;3b26	10 18 	. . 
	jr l3b32h		;3b28	18 08 	. . 
l3b2ah:
	ld c,b			;3b2a	48 	H 
	ld de,l1000h		;3b2b	11 00 10 	. . . 
	jr $+27		;3b2e	18 19 	. . 
l3b30h:
	jr l3b3ah		;3b30	18 08 	. . 
l3b32h:
	ld c,b			;3b32	48 	H 
	ld de,l1800h		;3b33	11 00 18 	. . . 
	jr $+27		;3b36	18 19 	. . 
	jr l3b42h		;3b38	18 08 	. . 
l3b3ah:
	ld c,b			;3b3a	48 	H 
	sub c			;3b3b	91 	. 
	ex af,af'			;3b3c	08 	. 
	jr l3b57h		;3b3d	18 18 	. . 
	add hl,de			;3b3f	19 	. 
l3b40h:
	jr l3b4ah		;3b40	18 08 	. . 
l3b42h:
	ld c,d			;3b42	4a 	J 
	sbc a,c			;3b43	99 	. 
	ex af,af'			;3b44	08 	. 
	jr l3b5fh		;3b45	18 18 	. . 
	add hl,de			;3b47	19 	. 
	jr l3b52h		;3b48	18 08 	. . 
l3b4ah:
	ld c,d			;3b4a	4a 	J 
	sbc a,a			;3b4b	9f 	. 
	ex af,af'			;3b4c	08 	. 
	sbc a,b			;3b4d	98 	. 
	jr l3b69h		;3b4e	18 19 	. . 
	jr l3b5ah		;3b50	18 08 	. . 
l3b52h:
	ld c,d			;3b52	4a 	J 
	sbc a,a			;3b53	9f 	. 
	inc c			;3b54	0c 	. 
	sbc a,b			;3b55	98 	. 
	sbc a,b			;3b56	98 	. 
l3b57h:
	add hl,de			;3b57	19 	. 
	jr l3b62h		;3b58	18 08 	. . 
l3b5ah:
	ld c,(hl)			;3b5a	4e 	N 
	sbc a,a			;3b5b	9f 	. 
	ld c,09ch		;3b5c	0e 9c 	. . 
	sbc a,b			;3b5e	98 	. 
l3b5fh:
	add hl,de			;3b5f	19 	. 
	jr l3b6eh		;3b60	18 0c 	. . 
l3b62h:
	ld c,(hl)			;3b62	4e 	N 
	sbc a,a			;3b63	9f 	. 
	ld c,09eh		;3b64	0e 9e 	. . 
	sbc a,h			;3b66	9c 	. 
	add hl,de			;3b67	19 	. 
	inc e			;3b68	1c 	. 
l3b69h:
	inc c			;3b69	0c 	. 
	ld c,(hl)			;3b6a	4e 	N 
	sbc a,a			;3b6b	9f 	. 
	ld c,09eh		;3b6c	0e 9e 	. . 
l3b6eh:
	sbc a,a			;3b6e	9f 	. 
	dec e			;3b6f	1d 	. 
	sbc a,h			;3b70	9c 	. 
	inc c			;3b71	0c 	. 
	ld c,(hl)			;3b72	4e 	N 
	sbc a,a			;3b73	9f 	. 
	ld c,09eh		;3b74	0e 9e 	. . 
	sbc a,a			;3b76	9f 	. 
	rra			;3b77	1f 	. 
	sbc a,h			;3b78	9c 	. 
	ld c,04eh		;3b79	0e 4e 	. N 
	sbc a,a			;3b7b	9f 	. 
	ld c,09eh		;3b7c	0e 9e 	. . 
	sbc a,a			;3b7e	9f 	. 
	rra			;3b7f	1f 	. 
	sbc a,(hl)			;3b80	9e 	. 
	adc a,(hl)			;3b81	8e 	. 
	ld c,(hl)			;3b82	4e 	N 
	sbc a,a			;3b83	9f 	. 
	ld c,09eh		;3b84	0e 9e 	. . 
	sbc a,a			;3b86	9f 	. 
	rra			;3b87	1f 	. 
	sbc a,(hl)			;3b88	9e 	. 
	adc a,(hl)			;3b89	8e 	. 
	adc a,08fh		;3b8a	ce 8f 	. . 
	ld c,08eh		;3b8c	0e 8e 	. . 
	adc a,a			;3b8e	8f 	. 
	rra			;3b8f	1f 	. 
	sbc a,(hl)			;3b90	9e 	. 
	adc a,(hl)			;3b91	8e 	. 
	adc a,(hl)			;3b92	8e 	. 
	adc a,a			;3b93	8f 	. 
	ld c,08eh		;3b94	0e 8e 	. . 
	adc a,a			;3b96	8f 	. 
	rra			;3b97	1f 	. 
	adc a,(hl)			;3b98	8e 	. 
	adc a,(hl)			;3b99	8e 	. 
	add a,(hl)			;3b9a	86 	. 
	adc a,a			;3b9b	8f 	. 
	ld c,08eh		;3b9c	0e 8e 	. . 
	adc a,a			;3b9e	8f 	. 
	rrca			;3b9f	0f 	. 
	adc a,(hl)			;3ba0	8e 	. 
	add a,(hl)			;3ba1	86 	. 
	add a,(hl)			;3ba2	86 	. 
	adc a,(hl)			;3ba3	8e 	. 
	ld c,08eh		;3ba4	0e 8e 	. . 
	adc a,a			;3ba6	8f 	. 
	rrca			;3ba7	0f 	. 
	add a,(hl)			;3ba8	86 	. 
	add a,(hl)			;3ba9	86 	. 
	add a,(hl)			;3baa	86 	. 
	adc a,(hl)			;3bab	8e 	. 
	ld c,08eh		;3bac	0e 8e 	. . 
	adc a,a			;3bae	8f 	. 
	rlca			;3baf	07 	. 
	add a,(hl)			;3bb0	86 	. 
	add a,(hl)			;3bb1	86 	. 
	add a,(hl)			;3bb2	86 	. 
	adc a,(hl)			;3bb3	8e 	. 
	ld c,08eh		;3bb4	0e 8e 	. . 
	add a,a			;3bb6	87 	. 
	ld b,086h		;3bb7	06 86 	. . 
	add a,(hl)			;3bb9	86 	. 
	add a,(hl)			;3bba	86 	. 
	adc a,(hl)			;3bbb	8e 	. 
	ld c,086h		;3bbc	0e 86 	. . 
	add a,a			;3bbe	87 	. 
	ld b,086h		;3bbf	06 86 	. . 
	add a,(hl)			;3bc1	86 	. 
	add a,(hl)			;3bc2	86 	. 
	ld c,006h		;3bc3	0e 06 	. . 
	add a,(hl)			;3bc5	86 	. 
	add a,a			;3bc6	87 	. 
	ld b,086h		;3bc7	06 86 	. . 
	add a,(hl)			;3bc9	86 	. 
	add a,h			;3bca	84 	. 
	ld b,006h		;3bcb	06 06 	. . 
	add a,(hl)			;3bcd	86 	. 
	add a,a			;3bce	87 	. 
	ld b,086h		;3bcf	06 86 	. . 
	add a,(hl)			;3bd1	86 	. 
	add a,h			;3bd2	84 	. 
	nop			;3bd3	00 	. 
	ld b,006h		;3bd4	06 06 	. . 
	add a,a			;3bd6	87 	. 
	ld b,086h		;3bd7	06 86 	. . 
	add a,(hl)			;3bd9	86 	. 
	add a,h			;3bda	84 	. 
	nop			;3bdb	00 	. 
	ld (bc),a			;3bdc	02 	. 
	ld b,007h		;3bdd	06 07 	. . 
	ld b,086h		;3bdf	06 86 	. . 
	add a,(hl)			;3be1	86 	. 
	add a,b			;3be2	80 	. 
	nop			;3be3	00 	. 
	nop			;3be4	00 	. 
	ld (bc),a			;3be5	02 	. 
	rlca			;3be6	07 	. 
	ld b,086h		;3be7	06 86 	. . 
	add a,d			;3be9	82 	. 
	add a,b			;3bea	80 	. 
	nop			;3beb	00 	. 
	nop			;3bec	00 	. 
	nop			;3bed	00 	. 
	inc bc			;3bee	03 	. 
	ld b,082h		;3bef	06 82 	. . 
	add a,d			;3bf1	82 	. 
	add a,b			;3bf2	80 	. 
	nop			;3bf3	00 	. 
	nop			;3bf4	00 	. 
	nop			;3bf5	00 	. 
	nop			;3bf6	00 	. 
	ld (bc),a			;3bf7	02 	. 
	ld (bc),a			;3bf8	02 	. 
	add a,d			;3bf9	82 	. 
	add a,b			;3bfa	80 	. 
	nop			;3bfb	00 	. 
	nop			;3bfc	00 	. 
	nop			;3bfd	00 	. 
	nop			;3bfe	00 	. 
	nop			;3bff	00 	. 
	ld (bc),a			;3c00	02 	. 
	add a,b			;3c01	80 	. 
	add a,b			;3c02	80 	. 
	nop			;3c03	00 	. 
	nop			;3c04	00 	. 
	nop			;3c05	00 	. 
	nop			;3c06	00 	. 
	nop			;3c07	00 	. 
	nop			;3c08	00 	. 
	nop			;3c09	00 	. 
	add a,b			;3c0a	80 	. 
	nop			;3c0b	00 	. 
	nop			;3c0c	00 	. 
	nop			;3c0d	00 	. 
	nop			;3c0e	00 	. 
	nop			;3c0f	00 	. 
	nop			;3c10	00 	. 
	nop			;3c11	00 	. 
	nop			;3c12	00 	. 
l3c13h:
	rlca			;3c13	07 	. 
	ld (hl),b			;3c14	70 	p 
	nop			;3c15	00 	. 
	nop			;3c16	00 	. 
	nop			;3c17	00 	. 
	nop			;3c18	00 	. 
	nop			;3c19	00 	. 
	nop			;3c1a	00 	. 
	nop			;3c1b	00 	. 
	nop			;3c1c	00 	. 
	rst 38h			;3c1d	ff 	. 
	rst 38h			;3c1e	ff 	. 
	rst 38h			;3c1f	ff 	. 
	rst 38h			;3c20	ff 	. 
	rst 38h			;3c21	ff 	. 
	rst 38h			;3c22	ff 	. 
l3c23h:
	rst 38h			;3c23	ff 	. 
	rst 38h			;3c24	ff 	. 
	nop			;3c25	00 	. 
	nop			;3c26	00 	. 
	nop			;3c27	00 	. 
	nop			;3c28	00 	. 
	nop			;3c29	00 	. 
	nop			;3c2a	00 	. 
	nop			;3c2b	00 	. 
	nop			;3c2c	00 	. 
	rst 38h			;3c2d	ff 	. 
	rst 38h			;3c2e	ff 	. 
	rst 38h			;3c2f	ff 	. 
	rst 38h			;3c30	ff 	. 
	rst 38h			;3c31	ff 	. 
	rst 38h			;3c32	ff 	. 
	rst 38h			;3c33	ff 	. 
	rst 38h			;3c34	ff 	. 
	nop			;3c35	00 	. 
	nop			;3c36	00 	. 
	nop			;3c37	00 	. 
	nop			;3c38	00 	. 
	nop			;3c39	00 	. 
	nop			;3c3a	00 	. 
	nop			;3c3b	00 	. 
	nop			;3c3c	00 	. 
	rst 38h			;3c3d	ff 	. 
	rst 38h			;3c3e	ff 	. 
l3c3fh:
	rst 38h			;3c3f	ff 	. 
	rst 38h			;3c40	ff 	. 
	rst 38h			;3c41	ff 	. 
	rst 38h			;3c42	ff 	. 
	rst 38h			;3c43	ff 	. 
	rst 38h			;3c44	ff 	. 
	nop			;3c45	00 	. 
	nop			;3c46	00 	. 
	nop			;3c47	00 	. 
	nop			;3c48	00 	. 
	nop			;3c49	00 	. 
	nop			;3c4a	00 	. 
	nop			;3c4b	00 	. 
	nop			;3c4c	00 	. 
l3c4dh:
	ld h,d			;3c4d	62 	b 
	ld a,b			;3c4e	78 	x 
	add a,b			;3c4f	80 	. 
	add hl,hl			;3c50	29 	) 
	nop			;3c51	00 	. 
	inc b			;3c52	04 	. 
	ld (bc),a			;3c53	02 	. 
	nop			;3c54	00 	. 
	nop			;3c55	00 	. 
	ex af,af'			;3c56	08 	. 
	nop			;3c57	00 	. 
	nop			;3c58	00 	. 
	and d			;3c59	a2 	. 
	nop			;3c5a	00 	. 
	ld d,c			;3c5b	51 	Q 
	add a,b			;3c5c	80 	. 
	nop			;3c5d	00 	. 
	ld bc,l0042h		;3c5e	01 42 00 	. B . 
	ld b,000h		;3c61	06 00 	. . 
	jr nz,l3c65h		;3c63	20 00 	  . 
l3c65h:
	add a,h			;3c65	84 	. 
	nop			;3c66	00 	. 
	sub b			;3c67	90 	. 
	jr nc,l3c6eh		;3c68	30 04 	0 . 
	ld b,b			;3c6a	40 	@ 
	nop			;3c6b	00 	. 
	ld b,000h		;3c6c	06 00 	. . 
l3c6eh:
	nop			;3c6e	00 	. 
	nop			;3c6f	00 	. 
	nop			;3c70	00 	. 
	jr nz,$+10		;3c71	20 08 	  . 
	nop			;3c73	00 	. 
	ex af,af'			;3c74	08 	. 
	jr c,l3c77h		;3c75	38 00 	8 . 
l3c77h:
	inc b			;3c77	04 	. 
	ld (bc),a			;3c78	02 	. 
	ld (00808h),hl		;3c79	22 08 08 	" . . 
	nop			;3c7c	00 	. 
	nop			;3c7d	00 	. 
	nop			;3c7e	00 	. 
	ret z			;3c7f	c8 	. 
	jr nz,l3c86h		;3c80	20 04 	  . 
	add a,d			;3c82	82 	. 
	ld (bc),a			;3c83	02 	. 
	nop			;3c84	00 	. 
	nop			;3c85	00 	. 
l3c86h:
	nop			;3c86	00 	. 
	nop			;3c87	00 	. 
	ld b,b			;3c88	40 	@ 
	nop			;3c89	00 	. 
	and b			;3c8a	a0 	. 
	add a,b			;3c8b	80 	. 
	add a,b			;3c8c	80 	. 
	inc c			;3c8d	0c 	. 
	nop			;3c8e	00 	. 
	inc c			;3c8f	0c 	. 
	call nz,sub_0400h		;3c90	c4 00 04 	. . . 
	nop			;3c93	00 	. 
	ld bc,l0010h		;3c94	01 10 00 	. . . 
	add a,b			;3c97	80 	. 
	jr nz,l3c9ah		;3c98	20 00 	  . 
l3c9ah:
	ex af,af'			;3c9a	08 	. 
	inc b			;3c9b	04 	. 
	ld (bc),a			;3c9c	02 	. 
	jr nc,l3ca1h		;3c9d	30 02 	0 . 
	inc b			;3c9f	04 	. 
	nop			;3ca0	00 	. 
l3ca1h:
	jr nz,l3ca4h		;3ca1	20 01 	  . 
	ld a,(bc)			;3ca3	0a 	. 
l3ca4h:
	add a,b			;3ca4	80 	. 
	nop			;3ca5	00 	. 
	ld (bc),a			;3ca6	02 	. 
	jr nz,l3cebh		;3ca7	20 42 	  B 
	djnz $+4		;3ca9	10 02 	. . 
	ld bc,08000h		;3cab	01 00 80 	. . . 
	nop			;3cae	00 	. 
	ld c,d			;3caf	4a 	J 
	inc b			;3cb0	04 	. 
	ld (bc),a			;3cb1	02 	. 
	nop			;3cb2	00 	. 
	djnz l3cd5h		;3cb3	10 20 	.   
	jr nz,l3cb7h		;3cb5	20 00 	  . 
l3cb7h:
	ld (bc),a			;3cb7	02 	. 
	nop			;3cb8	00 	. 
	ld b,h			;3cb9	44 	D 
	jr nz,l3cbch		;3cba	20 00 	  . 
l3cbch:
	jr nz,l3c3fh		;3cbc	20 81 	  . 
	nop			;3cbe	00 	. 
	jr l3cc3h		;3cbf	18 02 	. . 
	ld b,h			;3cc1	44 	D 
	ld (bc),a			;3cc2	02 	. 
l3cc3h:
	nop			;3cc3	00 	. 
	ld (bc),a			;3cc4	02 	. 
	nop			;3cc5	00 	. 
	ld bc,l0100h		;3cc6	01 00 01 	. . . 
	ld b,h			;3cc9	44 	D 
	ld c,b			;3cca	48 	H 
	nop			;3ccb	00 	. 
	add a,b			;3ccc	80 	. 
	inc c			;3ccd	0c 	. 
	nop			;3cce	00 	. 
	ld (bc),a			;3ccf	02 	. 
	add a,b			;3cd0	80 	. 
	add a,b			;3cd1	80 	. 
	ld (bc),a			;3cd2	02 	. 
	add a,b			;3cd3	80 	. 
	ld b,h			;3cd4	44 	D 
l3cd5h:
	ld (bc),a			;3cd5	02 	. 
	nop			;3cd6	00 	. 
	nop			;3cd7	00 	. 
	ld (bc),a			;3cd8	02 	. 
	add a,b			;3cd9	80 	. 
	jr z,l3cdch		;3cda	28 00 	( . 
l3cdch:
	ld (bc),a			;3cdc	02 	. 
	jr nc,l3cdfh		;3cdd	30 00 	0 . 
l3cdfh:
	jr nz,l3ce1h		;3cdf	20 00 	  . 
l3ce1h:
	ld h,d			;3ce1	62 	b 
	djnz l3d24h		;3ce2	10 40 	. @ 
	dec b			;3ce4	05 	. 
	nop			;3ce5	00 	. 
	nop			;3ce6	00 	. 
	nop			;3ce7	00 	. 
	jr nc,l3cfch		;3ce8	30 12 	0 . 
	nop			;3cea	00 	. 
l3cebh:
	add a,b			;3ceb	80 	. 
	ld (bc),a			;3cec	02 	. 
	jr nz,l3cefh		;3ced	20 00 	  . 
l3cefh:
	ld (bc),a			;3cef	02 	. 
	nop			;3cf0	00 	. 
	ld b,h			;3cf1	44 	D 
	ld (bc),a			;3cf2	02 	. 
	inc b			;3cf3	04 	. 
	inc b			;3cf4	04 	. 
	dec b			;3cf5	05 	. 
	nop			;3cf6	00 	. 
	nop			;3cf7	00 	. 
	inc b			;3cf8	04 	. 
	nop			;3cf9	00 	. 
	ld c,024h		;3cfa	0e 24 	. $ 
l3cfch:
	nop			;3cfc	00 	. 
	jr nz,l3d00h		;3cfd	20 01 	  . 
	nop			;3cff	00 	. 
l3d00h:
	ld b,b			;3d00	40 	@ 
	inc bc			;3d01	03 	. 
	djnz l3d04h		;3d02	10 00 	. . 
l3d04h:
	ld b,b			;3d04	40 	@ 
	ld e,b			;3d05	58 	X 
	nop			;3d06	00 	. 
	inc b			;3d07	04 	. 
	ex af,af'			;3d08	08 	. 
	inc b			;3d09	04 	. 
	nop			;3d0a	00 	. 
	ld b,c			;3d0b	41 	A 
	jr nz,l3d0eh		;3d0c	20 00 	  . 
l3d0eh:
	inc bc			;3d0e	03 	. 
	add a,b			;3d0f	80 	. 
	ld c,b			;3d10	48 	H 
	ld bc,l0802h		;3d11	01 02 08 	. . . 
	nop			;3d14	00 	. 
	sub b			;3d15	90 	. 
	nop			;3d16	00 	. 
	ld b,b			;3d17	40 	@ 
	nop			;3d18	00 	. 
	ld b,h			;3d19	44 	D 
	ld bc,l1205h		;3d1a	01 05 12 	. . . 
	nop			;3d1d	00 	. 
	nop			;3d1e	00 	. 
	ex af,af'			;3d1f	08 	. 
	ld b,b			;3d20	40 	@ 
	ld b,b			;3d21	40 	@ 
	dec b			;3d22	05 	. 
	nop			;3d23	00 	. 
l3d24h:
	nop			;3d24	00 	. 
	ld b,d			;3d25	42 	B 
	ld (bc),a			;3d26	02 	. 
	nop			;3d27	00 	. 
	djnz $+66		;3d28	10 40 	. @ 
	ld (l1000h),hl		;3d2a	22 00 10 	" . . 
	add a,b			;3d2d	80 	. 
	ld (bc),a			;3d2e	02 	. 
	nop			;3d2f	00 	. 
	nop			;3d30	00 	. 
	ld a,(bc)			;3d31	0a 	. 
	ex af,af'			;3d32	08 	. 
	ld (de),a			;3d33	12 	. 
	and b			;3d34	a0 	. 
	jr nz,l3d37h		;3d35	20 00 	  . 
l3d37h:
	nop			;3d37	00 	. 
	nop			;3d38	00 	. 
	ld c,b			;3d39	48 	H 
	nop			;3d3a	00 	. 
	jr nz,l3d42h		;3d3b	20 05 	  . 
	sub b			;3d3d	90 	. 
	nop			;3d3e	00 	. 
	nop			;3d3f	00 	. 
	inc b			;3d40	04 	. 
	ex af,af'			;3d41	08 	. 
l3d42h:
	add a,d			;3d42	82 	. 
	xor b			;3d43	a8 	. 
	ld b,b			;3d44	40 	@ 
	nop			;3d45	00 	. 
	nop			;3d46	00 	. 
	ld d,b			;3d47	50 	P 
	ld h,b			;3d48	60 	` 
	ld b,b			;3d49	40 	@ 
	jr nz,l3d4ch		;3d4a	20 00 	  . 
l3d4ch:
	nop			;3d4c	00 	. 
	ld b,b			;3d4d	40 	@ 
	nop			;3d4e	00 	. 
	ld b,b			;3d4f	40 	@ 
	ld b,008h		;3d50	06 08 	. . 
	ld bc,l0002h		;3d52	01 02 00 	. . . 
	jr nc,l3d57h		;3d55	30 00 	0 . 
l3d57h:
	ld b,b			;3d57	40 	@ 
	add a,h			;3d58	84 	. 
	nop			;3d59	00 	. 
	nop			;3d5a	00 	. 
	nop			;3d5b	00 	. 
	ld c,b			;3d5c	48 	H 
	inc b			;3d5d	04 	. 
	ld (bc),a			;3d5e	02 	. 
	nop			;3d5f	00 	. 
	ret nz			;3d60	c0 	. 
	inc (hl)			;3d61	34 	4 
	ld hl,l0000h		;3d62	21 00 00 	! . . 
	nop			;3d65	00 	. 
	inc b			;3d66	04 	. 
	ld (bc),a			;3d67	02 	. 
	ld bc,l0043h		;3d68	01 43 00 	. C . 
	ld bc,l0100h		;3d6b	01 00 01 	. . . 
	ld (bc),a			;3d6e	02 	. 
	nop			;3d6f	00 	. 
	ex af,af'			;3d70	08 	. 
	add a,h			;3d71	84 	. 
	ld bc,l0003h		;3d72	01 03 00 	. . . 
	jr z,l3d77h		;3d75	28 00 	( . 
l3d77h:
	nop			;3d77	00 	. 
	add a,c			;3d78	81 	. 
	nop			;3d79	00 	. 
	ld b,c			;3d7a	41 	A 
	nop			;3d7b	00 	. 
	inc bc			;3d7c	03 	. 
	inc b			;3d7d	04 	. 
	nop			;3d7e	00 	. 
	ld b,b			;3d7f	40 	@ 
	ld e,l			;3d80	5d 	] 
	nop			;3d81	00 	. 
	ld b,b			;3d82	40 	@ 
	djnz l3d85h		;3d83	10 00 	. . 
l3d85h:
	nop			;3d85	00 	. 
	nop			;3d86	00 	. 
	nop			;3d87	00 	. 
	ld b,h			;3d88	44 	D 
	nop			;3d89	00 	. 
	nop			;3d8a	00 	. 
	ret nz			;3d8b	c0 	. 
	jr nz,$+114		;3d8c	20 70 	  p 
	nop			;3d8e	00 	. 
	ex af,af'			;3d8f	08 	. 
	ld (bc),a			;3d90	02 	. 
	nop			;3d91	00 	. 
	ld c,b			;3d92	48 	H 
	and d			;3d93	a2 	. 
	nop			;3d94	00 	. 
	nop			;3d95	00 	. 
	nop			;3d96	00 	. 
	inc h			;3d97	24 	$ 
	ld b,b			;3d98	40 	@ 
	nop			;3d99	00 	. 
	ex af,af'			;3d9a	08 	. 
	djnz l3dddh		;3d9b	10 40 	. @ 
	jr nz,l3da7h		;3d9d	20 08 	  . 
	ld (de),a			;3d9f	12 	. 
	nop			;3da0	00 	. 
	ld b,h			;3da1	44 	D 
	ld b,c			;3da2	41 	A 
	djnz l3da5h		;3da3	10 00 	. . 
l3da5h:
	nop			;3da5	00 	. 
	nop			;3da6	00 	. 
l3da7h:
	nop			;3da7	00 	. 
	dec b			;3da8	05 	. 
	jr nz,l3dcbh		;3da9	20 20 	    
	ld (bc),a			;3dab	02 	. 
	ld b,d			;3dac	42 	B 
	nop			;3dad	00 	. 
	ex af,af'			;3dae	08 	. 
	nop			;3daf	00 	. 
	jr nz,l3db2h		;3db0	20 00 	  . 
l3db2h:
	jr nz,l3dd4h		;3db2	20 20 	    
	jr z,l3dd6h		;3db4	28 20 	(   
	ld b,044h		;3db6	06 44 	. D 
	ld b,d			;3db8	42 	B 
	nop			;3db9	00 	. 
	djnz l3dbch		;3dba	10 00 	. . 
l3dbch:
	nop			;3dbc	00 	. 
	and b			;3dbd	a0 	. 
	nop			;3dbe	00 	. 
	inc b			;3dbf	04 	. 
	inc b			;3dc0	04 	. 
	ld bc,l0008h		;3dc1	01 08 00 	. . . 
	ld b,b			;3dc4	40 	@ 
	add a,b			;3dc5	80 	. 
	inc c			;3dc6	0c 	. 
	add a,b			;3dc7	80 	. 
	inc h			;3dc8	24 	$ 
	ld b,b			;3dc9	40 	@ 
	ld b,c			;3dca	41 	A 
l3dcbh:
	ld b,b			;3dcb	40 	@ 
	ex af,af'			;3dcc	08 	. 
	nop			;3dcd	00 	. 
	nop			;3dce	00 	. 
	sub b			;3dcf	90 	. 
	nop			;3dd0	00 	. 
	ld b,001h		;3dd1	06 01 	. . 
	nop			;3dd3	00 	. 
l3dd4h:
	ld (bc),a			;3dd4	02 	. 
	ex af,af'			;3dd5	08 	. 
l3dd6h:
	ex af,af'			;3dd6	08 	. 
	nop			;3dd7	00 	. 
	ld h,(hl)			;3dd8	66 	f 
	nop			;3dd9	00 	. 
	nop			;3dda	00 	. 
	ex af,af'			;3ddb	08 	. 
	inc b			;3ddc	04 	. 
l3dddh:
	ld b,c			;3ddd	41 	A 
	nop			;3dde	00 	. 
	jr l3e01h		;3ddf	18 20 	.   
	nop			;3de1	00 	. 
	ld b,b			;3de2	40 	@ 
	ld (bc),a			;3de3	02 	. 
	sub b			;3de4	90 	. 
	nop			;3de5	00 	. 
	nop			;3de6	00 	. 
	nop			;3de7	00 	. 
	nop			;3de8	00 	. 
	jr z,l3dech		;3de9	28 01 	( . 
	nop			;3deb	00 	. 
l3dech:
	nop			;3dec	00 	. 
	ld c,004h		;3ded	0e 04 	. . 
	nop			;3def	00 	. 
	ld b,h			;3df0	44 	D 
	nop			;3df1	00 	. 
	ex af,af'			;3df2	08 	. 
	ex af,af'			;3df3	08 	. 
	djnz l3e01h		;3df4	10 0b 	. . 
	nop			;3df6	00 	. 
	nop			;3df7	00 	. 
	djnz $+38		;3df8	10 24 	. $ 
	ld bc,l0004h		;3dfa	01 04 00 	. . . 
	djnz l3e07h		;3dfd	10 08 	. . 
	ld (bc),a			;3dff	02 	. 
	ld (de),a			;3e00	12 	. 
l3e01h:
	ld b,b			;3e01	40 	@ 
	ld (bc),a			;3e02	02 	. 
	jr nz,l3e07h		;3e03	20 02 	  . 
	nop			;3e05	00 	. 
	inc b			;3e06	04 	. 
l3e07h:
	ld (bc),a			;3e07	02 	. 
	ex af,af'			;3e08	08 	. 
	inc bc			;3e09	03 	. 
	nop			;3e0a	00 	. 
l3e0bh:
	nop			;3e0b	00 	. 
	inc b			;3e0c	04 	. 
	add a,b			;3e0d	80 	. 
	ld (bc),a			;3e0e	02 	. 
	ld (bc),a			;3e0f	02 	. 
	inc b			;3e10	04 	. 
	ex af,af'			;3e11	08 	. 
	ld bc,l0018h		;3e12	01 18 00 	. . . 
l3e15h:
	jr nz,$+6		;3e15	20 04 	  . 
	ld b,b			;3e17	40 	@ 
	add a,c			;3e18	81 	. 
	ld (bc),a			;3e19	02 	. 
	djnz l3e1ch		;3e1a	10 00 	. . 
l3e1ch:
	ld (bc),a			;3e1c	02 	. 
	jr nz,l3e1fh		;3e1d	20 00 	  . 
l3e1fh:
	adc a,b			;3e1f	88 	. 
	ld bc,l0000h		;3e20	01 00 00 	. . . 
	nop			;3e23	00 	. 
	ex af,af'			;3e24	08 	. 
	inc a			;3e25	3c 	< 
	nop			;3e26	00 	. 
	nop			;3e27	00 	. 
	ld bc,02104h		;3e28	01 04 21 	. . ! 
	nop			;3e2b	00 	. 
	jr nz,l3e3fh		;3e2c	20 11 	  . 
	inc b			;3e2e	04 	. 
	nop			;3e2f	00 	. 
	inc b			;3e30	04 	. 
	nop			;3e31	00 	. 
	jr z,l3e45h		;3e32	28 11 	( . 
	add a,b			;3e34	80 	. 
	add a,b			;3e35	80 	. 
	nop			;3e36	00 	. 
	inc b			;3e37	04 	. 
	nop			;3e38	00 	. 
	nop			;3e39	00 	. 
	ld de,08148h		;3e3a	11 48 81 	. H . 
	djnz l3e3fh		;3e3d	10 00 	. . 
l3e3fh:
	add a,b			;3e3f	80 	. 
	nop			;3e40	00 	. 
	inc h			;3e41	24 	$ 
	nop			;3e42	00 	. 
	ld h,b			;3e43	60 	` 
	nop			;3e44	00 	. 
l3e45h:
	jr l3e47h		;3e45	18 00 	. . 
l3e47h:
	ex af,af'			;3e47	08 	. 
	ld (bc),a			;3e48	02 	. 
	inc b			;3e49	04 	. 
	nop			;3e4a	00 	. 
	add a,b			;3e4b	80 	. 
	ld b,b			;3e4c	40 	@ 
	ld (de),a			;3e4d	12 	. 
	ld (bc),a			;3e4e	02 	. 
	add a,b			;3e4f	80 	. 
	djnz l3e92h		;3e50	10 40 	. @ 
	inc b			;3e52	04 	. 
	ex af,af'			;3e53	08 	. 
	inc c			;3e54	0c 	. 
	nop			;3e55	00 	. 
	ld (bc),a			;3e56	02 	. 
	djnz $+4		;3e57	10 02 	. . 
	nop			;3e59	00 	. 
	ld hl,sub_2fffh+1		;3e5a	21 00 30 	! . 0 
	ld b,b			;3e5d	40 	@ 
	ex af,af'			;3e5e	08 	. 
	sbc a,b			;3e5f	98 	. 
	add a,b			;3e60	80 	. 
	nop			;3e61	00 	. 
	add a,h			;3e62	84 	. 
	nop			;3e63	00 	. 
	jr nz,l3e68h		;3e64	20 02 	  . 
	nop			;3e66	00 	. 
	ld (bc),a			;3e67	02 	. 
l3e68h:
	ld (bc),a			;3e68	02 	. 
	nop			;3e69	00 	. 
	inc b			;3e6a	04 	. 
	inc bc			;3e6b	03 	. 
	nop			;3e6c	00 	. 
	ret nz			;3e6d	c0 	. 
	nop			;3e6e	00 	. 
	djnz $-122		;3e6f	10 84 	. . 
	ex af,af'			;3e71	08 	. 
	inc c			;3e72	0c 	. 
	inc b			;3e73	04 	. 
	nop			;3e74	00 	. 
	ex af,af'			;3e75	08 	. 
	nop			;3e76	00 	. 
	nop			;3e77	00 	. 
	nop			;3e78	00 	. 
	ld h,b			;3e79	60 	` 
	ld b,b			;3e7a	40 	@ 
l3e7bh:
	inc bc			;3e7b	03 	. 
	and h			;3e7c	a4 	. 
	nop			;3e7d	00 	. 
	nop			;3e7e	00 	. 
	nop			;3e7f	00 	. 
	inc b			;3e80	04 	. 
	inc h			;3e81	24 	$ 
	ex af,af'			;3e82	08 	. 
	nop			;3e83	00 	. 
	ld b,b			;3e84	40 	@ 
	ld (bc),a			;3e85	02 	. 
	ex af,af'			;3e86	08 	. 
	inc c			;3e87	0c 	. 
	jr nz,l3e0bh		;3e88	20 81 	  . 
	nop			;3e8a	00 	. 
	djnz l3e8dh		;3e8b	10 00 	. . 
l3e8dh:
	nop			;3e8d	00 	. 
	nop			;3e8e	00 	. 
	inc b			;3e8f	04 	. 
	ex af,af'			;3e90	08 	. 
	ld b,h			;3e91	44 	D 
l3e92h:
	ex af,af'			;3e92	08 	. 
	djnz l3e15h		;3e93	10 80 	. . 
	inc b			;3e95	04 	. 
	nop			;3e96	00 	. 
	djnz l3ea9h		;3e97	10 10 	. . 
	nop			;3e99	00 	. 
	and d			;3e9a	a2 	. 
	ld b,004h		;3e9b	06 04 	. . 
	nop			;3e9d	00 	. 
	nop			;3e9e	00 	. 
	ld d,b			;3e9f	50 	P 
	ld bc,l0041h		;3ea0	01 41 00 	. A . 
	nop			;3ea3	00 	. 
	inc b			;3ea4	04 	. 
	nop			;3ea5	00 	. 
	dec b			;3ea6	05 	. 
	nop			;3ea7	00 	. 
	ld b,d			;3ea8	42 	B 
l3ea9h:
	adc a,b			;3ea9	88 	. 
	jr nc,l3each		;3eaa	30 00 	0 . 
l3each:
	ld b,b			;3eac	40 	@ 
	djnz l3eafh		;3ead	10 00 	. . 
l3eafh:
	nop			;3eaf	00 	. 
	ld b,b			;3eb0	40 	@ 
	ld b,b			;3eb1	40 	@ 
	add a,b			;3eb2	80 	. 
	djnz l3ec5h		;3eb3	10 10 	. . 
	jp nz,0a000h		;3eb5	c2 00 a0 	. . . 
	nop			;3eb8	00 	. 
	nop			;3eb9	00 	. 
	jr sub_3ebeh		;3eba	18 02 	. . 
	ld c,b			;3ebc	48 	H 
	add a,b			;3ebd	80 	. 
sub_3ebeh:
	nop			;3ebe	00 	. 
	nop			;3ebf	00 	. 
	nop			;3ec0	00 	. 
	ld (bc),a			;3ec1	02 	. 
	add a,b			;3ec2	80 	. 
	ex af,af'			;3ec3	08 	. 
	nop			;3ec4	00 	. 
l3ec5h:
	inc de			;3ec5	13 	. 
	ex af,af'			;3ec6	08 	. 
	ld b,b			;3ec7	40 	@ 
	ld b,b			;3ec8	40 	@ 
l3ec9h:
	nop			;3ec9	00 	. 
	add a,b			;3eca	80 	. 
	djnz l3ef9h		;3ecb	10 2c 	. , 
	ld (bc),a			;3ecd	02 	. 
	nop			;3ece	00 	. 
	nop			;3ecf	00 	. 
	ld (00800h),a		;3ed0	32 00 08 	2 . . 
	nop			;3ed3	00 	. 
	ld (bc),a			;3ed4	02 	. 
	ex af,af'			;3ed5	08 	. 
	inc b			;3ed6	04 	. 
	nop			;3ed7	00 	. 
	ld b,b			;3ed8	40 	@ 
	ld c,b			;3ed9	48 	H 
	ld b,b			;3eda	40 	@ 
	jr l3ee9h		;3edb	18 0c 	. . 
	nop			;3edd	00 	. 
	nop			;3ede	00 	. 
	nop			;3edf	00 	. 
	ld b,b			;3ee0	40 	@ 
	djnz l3f2ch		;3ee1	10 49 	. I 
	ld (bc),a			;3ee3	02 	. 
	nop			;3ee4	00 	. 
	nop			;3ee5	00 	. 
	inc c			;3ee6	0c 	. 
	inc b			;3ee7	04 	. 
	ex af,af'			;3ee8	08 	. 
l3ee9h:
	ld bc,l1000h		;3ee9	01 00 10 	. . . 
	ld (de),a			;3eec	12 	. 
	djnz l3eefh		;3eed	10 00 	. . 
l3eefh:
	ld a,(bc)			;3eef	0a 	. 
	nop			;3ef0	00 	. 
	ld b,b			;3ef1	40 	@ 
	inc b			;3ef2	04 	. 
	add a,d			;3ef3	82 	. 
	nop			;3ef4	00 	. 
	add a,b			;3ef5	80 	. 
	nop			;3ef6	00 	. 
	djnz l3e7bh		;3ef7	10 82 	. . 
l3ef9h:
	ex af,af'			;3ef9	08 	. 
	ld bc,l0005h		;3efa	01 05 00 	. . . 
	nop			;3efd	00 	. 
	ld bc,08024h		;3efe	01 24 80 	. $ . 
	nop			;3f01	00 	. 
	ld bc,00c00h		;3f02	01 00 0c 	. . . 
	nop			;3f05	00 	. 
	dec b			;3f06	05 	. 
	nop			;3f07	00 	. 
	djnz l3f0ah		;3f08	10 00 	. . 
l3f0ah:
	jr nz,l3f0ch		;3f0a	20 00 	  . 
l3f0ch:
	adc a,d			;3f0c	8a 	. 
	ex af,af'			;3f0d	08 	. 
	ld (bc),a			;3f0e	02 	. 
	add a,b			;3f0f	80 	. 
	inc d			;3f10	14 	. 
	jr nz,l3f73h		;3f11	20 60 	  ` 
	jr nz,l3f19h		;3f13	20 04 	  . 
	nop			;3f15	00 	. 
	nop			;3f16	00 	. 
	djnz l3f39h		;3f17	10 20 	.   
l3f19h:
	jr nz,l3f1bh		;3f19	20 00 	  . 
l3f1bh:
	jr nc,$+18		;3f1b	30 10 	0 . 
	jr l3f1fh		;3f1d	18 00 	. . 
l3f1fh:
	jr nz,l3f2bh		;3f1f	20 0a 	  . 
	jr nz,l3f24h		;3f21	20 01 	  . 
	nop			;3f23	00 	. 
l3f24h:
	djnz l3f2eh		;3f24	10 08 	. . 
	nop			;3f26	00 	. 
	ld b,b			;3f27	40 	@ 
	add a,b			;3f28	80 	. 
	nop			;3f29	00 	. 
	rla			;3f2a	17 	. 
l3f2bh:
	nop			;3f2b	00 	. 
l3f2ch:
	djnz l3f2eh		;3f2c	10 00 	. . 
l3f2eh:
	ld (bc),a			;3f2e	02 	. 
	ld (de),a			;3f2f	12 	. 
	jr nz,l3f32h		;3f30	20 00 	  . 
l3f32h:
	nop			;3f32	00 	. 
	inc b			;3f33	04 	. 
	ld de,l0080h		;3f34	11 80 00 	. . . 
	inc b			;3f37	04 	. 
	ld b,c			;3f38	41 	A 
l3f39h:
	ld (bc),a			;3f39	02 	. 
	ld (bc),a			;3f3a	02 	. 
	ex af,af'			;3f3b	08 	. 
	jr z,l3f3eh		;3f3c	28 00 	( . 
l3f3eh:
	nop			;3f3e	00 	. 
	nop			;3f3f	00 	. 
	ld bc,00416h		;3f40	01 16 04 	. . . 
	ld bc,l4040h		;3f43	01 40 40 	. @ @ 
	nop			;3f46	00 	. 
	djnz l3ec9h		;3f47	10 80 	. . 
	djnz l3f4bh		;3f49	10 00 	. . 
l3f4bh:
	nop			;3f4b	00 	. 
	ld h,b			;3f4c	60 	` 
	add a,h			;3f4d	84 	. 
	nop			;3f4e	00 	. 
	adc a,b			;3f4f	88 	. 
	ld b,b			;3f50	40 	@ 
	nop			;3f51	00 	. 
	ld b,000h		;3f52	06 00 	. . 
	add a,b			;3f54	80 	. 
	ld bc,02402h		;3f55	01 02 24 	. . $ 
	nop			;3f58	00 	. 
	jr nz,l3f9bh		;3f59	20 40 	  @ 
	ld b,c			;3f5b	41 	A 
	ld (bc),a			;3f5c	02 	. 
	nop			;3f5d	00 	. 
	nop			;3f5e	00 	. 
l3f5fh:
	ld h,h			;3f5f	64 	d 
	ld h,h			;3f60	64 	d 
	inc b			;3f61	04 	. 
	jr l3f64h		;3f62	18 00 	. . 
l3f64h:
	djnz l3f66h		;3f64	10 00 	. . 
l3f66h:
	add hl,hl			;3f66	29 	) 
l3f67h:
	ex af,af'			;3f67	08 	. 
	nop			;3f68	00 	. 
l3f69h:
	ld b,b			;3f69	40 	@ 
	nop			;3f6a	00 	. 
	nop			;3f6b	00 	. 
	ld (de),a			;3f6c	12 	. 
	nop			;3f6d	00 	. 
	add hl,hl			;3f6e	29 	) 
	nop			;3f6f	00 	. 
	inc bc			;3f70	03 	. 
	add a,b			;3f71	80 	. 
	nop			;3f72	00 	. 
l3f73h:
	inc b			;3f73	04 	. 
	nop			;3f74	00 	. 
	ret nz			;3f75	c0 	. 
	jr nz,l3f7ah		;3f76	20 02 	  . 
	inc b			;3f78	04 	. 
	nop			;3f79	00 	. 
l3f7ah:
	add a,b			;3f7a	80 	. 
	nop			;3f7b	00 	. 
	ld a,(bc)			;3f7c	0a 	. 
	inc b			;3f7d	04 	. 
	jr nz,l3f88h		;3f7e	20 08 	  . 
	add hl,bc			;3f80	09 	. 
	nop			;3f81	00 	. 
	ld hl,l0040h		;3f82	21 40 00 	! @ . 
	add a,c			;3f85	81 	. 
	inc b			;3f86	04 	. 
	and b			;3f87	a0 	. 
l3f88h:
	nop			;3f88	00 	. 
	and b			;3f89	a0 	. 
	jr nz,l3fcch		;3f8a	20 40 	  @ 
	nop			;3f8c	00 	. 
	ld d,b			;3f8d	50 	P 
	inc c			;3f8e	0c 	. 
	nop			;3f8f	00 	. 
	nop			;3f90	00 	. 
	ld h,b			;3f91	60 	` 
	dec c			;3f92	0d 	. 
	ld c,b			;3f93	48 	H 
	nop			;3f94	00 	. 
	nop			;3f95	00 	. 
	nop			;3f96	00 	. 
	add a,b			;3f97	80 	. 
	nop			;3f98	00 	. 
	nop			;3f99	00 	. 
	ld d,b			;3f9a	50 	P 
l3f9bh:
	nop			;3f9b	00 	. 
	ld (bc),a			;3f9c	02 	. 
	jr nz,$+7		;3f9d	20 05 	  . 
	inc c			;3f9f	0c 	. 
	nop			;3fa0	00 	. 
	ld b,010h		;3fa1	06 10 	. . 
	jr l3fa5h		;3fa3	18 00 	. . 
l3fa5h:
	ld bc,l0000h		;3fa5	01 00 00 	. . . 
	ld (bc),a			;3fa8	02 	. 
	ld (bc),a			;3fa9	02 	. 
	nop			;3faa	00 	. 
	ret nz			;3fab	c0 	. 
	jr nz,l3fc7h		;3fac	20 19 	  . 
	nop			;3fae	00 	. 
	inc b			;3faf	04 	. 
	nop			;3fb0	00 	. 
	ld b,b			;3fb1	40 	@ 
	nop			;3fb2	00 	. 
	add a,d			;3fb3	82 	. 
	inc b			;3fb4	04 	. 
	ld (bc),a			;3fb5	02 	. 
	djnz $+26		;3fb6	10 18 	. . 
	nop			;3fb8	00 	. 
	ld b,b			;3fb9	40 	@ 
	nop			;3fba	00 	. 
	ex af,af'			;3fbb	08 	. 
	ld bc,l0030h		;3fbc	01 30 00 	. 0 . 
	ld b,b			;3fbf	40 	@ 
	inc c			;3fc0	0c 	. 
	nop			;3fc1	00 	. 
	inc b			;3fc2	04 	. 
	nop			;3fc3	00 	. 
	ld b,b			;3fc4	40 	@ 
	jr nz,l3f69h		;3fc5	20 a2 	  . 
l3fc7h:
	ex af,af'			;3fc7	08 	. 
	inc b			;3fc8	04 	. 
	ld (l40c0h),hl		;3fc9	22 c0 40 	" . @ 
l3fcch:
	nop			;3fcc	00 	. 
	inc b			;3fcd	04 	. 
	ld (l0000h),hl		;3fce	22 00 00 	" . . 
	ld b,h			;3fd1	44 	D 
	djnz l3fdch		;3fd2	10 08 	. . 
	nop			;3fd4	00 	. 
	nop			;3fd5	00 	. 
	ld (de),a			;3fd6	12 	. 
	ld b,c			;3fd7	41 	A 
	nop			;3fd8	00 	. 
	nop			;3fd9	00 	. 
	djnz l3fdch		;3fda	10 00 	. . 
l3fdch:
	nop			;3fdc	00 	. 
	ld e,c			;3fdd	59 	Y 
	djnz l4010h		;3fde	10 30 	. 0 
	nop			;3fe0	00 	. 
	jr nz,$+20		;3fe1	20 12 	  . 
	nop			;3fe3	00 	. 
	add a,h			;3fe4	84 	. 
	djnz l3f67h		;3fe5	10 80 	. . 
	nop			;3fe7	00 	. 
	nop			;3fe8	00 	. 
	jr nz,l3fffh		;3fe9	20 14 	  . 
	jr nz,l3fedh		;3feb	20 00 	  . 
l3fedh:
	ld (de),a			;3fed	12 	. 
	add a,b			;3fee	80 	. 
	ld (bc),a			;3fef	02 	. 
	nop			;3ff0	00 	. 
	jr nc,l4005h		;3ff1	30 12 	0 . 
	nop			;3ff3	00 	. 
	jr nz,l3ff6h		;3ff4	20 00 	  . 
l3ff6h:
	ld bc,l0201h+1		;3ff6	01 02 02 	. . . 
	add a,b			;3ff9	80 	. 
	nop			;3ffa	00 	. 
	ld (l0802h),hl		;3ffb	22 02 08 	" . . 
	nop			;3ffe	00 	. 
l3fffh:
	jr l4001h		;3fff	18 00 	. . 
l4001h:
	nop			;4001	00 	. 
	nop			;4002	00 	. 
	ex af,af'			;4003	08 	. 
	nop			;4004	00 	. 
l4005h:
	and b			;4005	a0 	. 
	dec b			;4006	05 	. 
	jr z,l4009h		;4007	28 00 	( . 
l4009h:
	nop			;4009	00 	. 
	nop			;400a	00 	. 
	add a,b			;400b	80 	. 
	inc de			;400c	13 	. 
	sub b			;400d	90 	. 
	jr nz,l4010h		;400e	20 00 	  . 
l4010h:
	nop			;4010	00 	. 
	ld b,b			;4011	40 	@ 
	ex af,af'			;4012	08 	. 
	nop			;4013	00 	. 
	inc bc			;4014	03 	. 
	add a,b			;4015	80 	. 
	ld (bc),a			;4016	02 	. 
	nop			;4017	00 	. 
	add hl,bc			;4018	09 	. 
	jr nz,$+10		;4019	20 08 	  . 
	add a,b			;401b	80 	. 
	nop			;401c	00 	. 
	dec l			;401d	2d 	- 
	nop			;401e	00 	. 
	inc b			;401f	04 	. 
l4020h:
	nop			;4020	00 	. 
	nop			;4021	00 	. 
	ld bc,00200h		;4022	01 00 02 	. . . 
	nop			;4025	00 	. 
	jr z,l4034h		;4026	28 0c 	( . 
	ex af,af'			;4028	08 	. 
	nop			;4029	00 	. 
	add a,d			;402a	82 	. 
	nop			;402b	00 	. 
	and b			;402c	a0 	. 
	ld b,b			;402d	40 	@ 
	nop			;402e	00 	. 
	jr nz,$+12		;402f	20 0a 	  . 
	ex af,af'			;4031	08 	. 
	nop			;4032	00 	. 
	ld b,h			;4033	44 	D 
l4034h:
	djnz l4037h		;4034	10 01 	. . 
	inc bc			;4036	03 	. 
l4037h:
	ld b,b			;4037	40 	@ 
	nop			;4038	00 	. 
	nop			;4039	00 	. 
	jr nz,l4075h		;403a	20 39 	  9 
	ld d,b			;403c	50 	P 
	nop			;403d	00 	. 
	nop			;403e	00 	. 
	nop			;403f	00 	. 
l4040h:
	inc b			;4040	04 	. 
l4041h:
	ex af,af'			;4041	08 	. 
	ld (bc),a			;4042	02 	. 
	ld bc,l1000h		;4043	01 00 10 	. . . 
	nop			;4046	00 	. 
	jr nz,l404fh		;4047	20 06 	  . 
	nop			;4049	00 	. 
	inc d			;404a	14 	. 
	ex af,af'			;404b	08 	. 
	jr c,l404eh		;404c	38 00 	8 . 
l404eh:
	inc b			;404e	04 	. 
l404fh:
	jr nz,l4051h		;404f	20 00 	  . 
l4051h:
	ex af,af'			;4051	08 	. 
	nop			;4052	00 	. 
	ld bc,sub_0400h		;4053	01 00 04 	. . . 
	nop			;4056	00 	. 
	inc h			;4057	24 	$ 
	ld a,(bc)			;4058	0a 	. 
	nop			;4059	00 	. 
	nop			;405a	00 	. 
	djnz l408dh		;405b	10 30 	. 0 
	nop			;405d	00 	. 
	nop			;405e	00 	. 
	ld b,e			;405f	43 	C 
	ld bc,02800h		;4060	01 00 28 	. . ( 
	jr nz,$+22		;4063	20 14 	  . 
	nop			;4065	00 	. 
	add a,b			;4066	80 	. 
	ld b,b			;4067	40 	@ 
	nop			;4068	00 	. 
	ld (l0004h),a		;4069	32 04 00 	2 . . 
	nop			;406c	00 	. 
	ld bc,l0048h		;406d	01 48 00 	. H . 
	nop			;4070	00 	. 
	nop			;4071	00 	. 
	ex af,af'			;4072	08 	. 
	djnz l4005h		;4073	10 90 	. . 
l4075h:
	inc b			;4075	04 	. 
	ex af,af'			;4076	08 	. 
	ld bc,sub_0400h+1		;4077	01 01 04 	. . . 
	ld (bc),a			;407a	02 	. 
	ld hl,(l0000h)		;407b	2a 00 00 	* . . 
	add a,b			;407e	80 	. 
	dec b			;407f	05 	. 
	nop			;4080	00 	. 
	nop			;4081	00 	. 
	nop			;4082	00 	. 
	nop			;4083	00 	. 
	ret po			;4084	e0 	. 
	add a,l			;4085	85 	. 
l4086h:
	ld bc,l0040h		;4086	01 40 00 	. @ . 
	or d			;4089	b2 	. 
	ld bc,l0000h		;408a	01 00 00 	. . . 
l408dh:
	nop			;408d	00 	. 
	ld b,c			;408e	41 	A 
	nop			;408f	00 	. 
	ld (bc),a			;4090	02 	. 
	ld (bc),a			;4091	02 	. 
	ld b,b			;4092	40 	@ 
	nop			;4093	00 	. 
	nop			;4094	00 	. 
	ld c,h			;4095	4c 	L 
l4096h:
	jr nz,l40b0h		;4096	20 18 	  . 
	nop			;4098	00 	. 
	nop			;4099	00 	. 
	djnz l40a4h		;409a	10 08 	. . 
	nop			;409c	00 	. 
	ld b,e			;409d	43 	C 
	ex af,af'			;409e	08 	. 
	jr nz,l40a1h		;409f	20 00 	  . 
l40a1h:
	nop			;40a1	00 	. 
	dec d			;40a2	15 	. 
	ld a,(bc)			;40a3	0a 	. 
l40a4h:
	nop			;40a4	00 	. 
	ld (bc),a			;40a5	02 	. 
	djnz l40a8h		;40a6	10 00 	. . 
l40a8h:
	nop			;40a8	00 	. 
	nop			;40a9	00 	. 
	nop			;40aa	00 	. 
	ld b,e			;40ab	43 	C 
	ld (de),a			;40ac	12 	. 
	nop			;40ad	00 	. 
	ld (bc),a			;40ae	02 	. 
	ld b,b			;40af	40 	@ 
l40b0h:
	nop			;40b0	00 	. 
	djnz l4117h		;40b1	10 64 	. d 
	nop			;40b3	00 	. 
	ld b,010h		;40b4	06 10 	. . 
	inc b			;40b6	04 	. 
	nop			;40b7	00 	. 
	nop			;40b8	00 	. 
	nop			;40b9	00 	. 
	nop			;40ba	00 	. 
	ld (bc),a			;40bb	02 	. 
	ld b,b			;40bc	40 	@ 
	adc a,b			;40bd	88 	. 
	ld (bc),a			;40be	02 	. 
	inc bc			;40bf	03 	. 
l40c0h:
	nop			;40c0	00 	. 
	nop			;40c1	00 	. 
	inc d			;40c2	14 	. 
	djnz l40c5h		;40c3	10 00 	. . 
l40c5h:
	ex af,af'			;40c5	08 	. 
	ld b,b			;40c6	40 	@ 
	jr nc,l40c9h		;40c7	30 00 	0 . 
l40c9h:
	djnz l40cbh		;40c9	10 00 	. . 
l40cbh:
	inc b			;40cb	04 	. 
	ld c,b			;40cc	48 	H 
	ld (bc),a			;40cd	02 	. 
	sub b			;40ce	90 	. 
	add a,b			;40cf	80 	. 
	nop			;40d0	00 	. 
	and b			;40d1	a0 	. 
	ld b,b			;40d2	40 	@ 
	nop			;40d3	00 	. 
	nop			;40d4	00 	. 
	ld b,040h		;40d5	06 40 	. @ 
	nop			;40d7	00 	. 
	ex af,af'			;40d8	08 	. 
	nop			;40d9	00 	. 
	nop			;40da	00 	. 
	inc h			;40db	24 	$ 
	ld b,b			;40dc	40 	@ 
	nop			;40dd	00 	. 
	djnz l4128h		;40de	10 48 	. H 
	ld bc,l3fffh+1		;40e0	01 00 40 	. . @ 
	dec c			;40e3	0d 	. 
	ld de,l0201h		;40e4	11 01 02 	. . . 
	nop			;40e7	00 	. 
	nop			;40e8	00 	. 
	nop			;40e9	00 	. 
	rlca			;40ea	07 	. 
	nop			;40eb	00 	. 
	ld b,b			;40ec	40 	@ 
	ld bc,l0051h		;40ed	01 51 00 	. Q . 
	nop			;40f0	00 	. 
	jr l40f3h		;40f1	18 00 	. . 
l40f3h:
	ex af,af'			;40f3	08 	. 
	jr nz,l4086h		;40f4	20 90 	  . 
	djnz l4100h		;40f6	10 08 	. . 
	nop			;40f8	00 	. 
	jr nz,l4105h		;40f9	20 0a 	  . 
	nop			;40fb	00 	. 
	jr z,l410eh		;40fc	28 10 	( . 
	add a,b			;40fe	80 	. 
	inc b			;40ff	04 	. 
l4100h:
	nop			;4100	00 	. 
	djnz l4103h		;4101	10 00 	. . 
l4103h:
	ld a,(bc)			;4103	0a 	. 
	ex af,af'			;4104	08 	. 
l4105h:
	nop			;4105	00 	. 
	nop			;4106	00 	. 
	ld d,b			;4107	50 	P 
	ld (bc),a			;4108	02 	. 
	adc a,b			;4109	88 	. 
	ld (bc),a			;410a	02 	. 
	nop			;410b	00 	. 
	nop			;410c	00 	. 
	pop bc			;410d	c1 	. 
l410eh:
	djnz l4150h		;410e	10 40 	. @ 
	nop			;4110	00 	. 
	nop			;4111	00 	. 
	inc bc			;4112	03 	. 
	jr nz,l4096h		;4113	20 81 	  . 
	ld b,h			;4115	44 	D 
	ld b,b			;4116	40 	@ 
l4117h:
	nop			;4117	00 	. 
	nop			;4118	00 	. 
	inc d			;4119	14 	. 
	nop			;411a	00 	. 
	nop			;411b	00 	. 
	adc a,b			;411c	88 	. 
	djnz $-62		;411d	10 c0 	. . 
	inc b			;411f	04 	. 
	nop			;4120	00 	. 
	nop			;4121	00 	. 
	jr nz,l4128h		;4122	20 04 	  . 
	dec b			;4124	05 	. 
	nop			;4125	00 	. 
	djnz l4132h		;4126	10 0a 	. . 
l4128h:
	nop			;4128	00 	. 
	ld (bc),a			;4129	02 	. 
	ld bc,l3fffh+1		;412a	01 00 40 	. . @ 
	ld hl,(00408h)		;412d	2a 08 04 	* . . 
	nop			;4130	00 	. 
	nop			;4131	00 	. 
l4132h:
	ld c,b			;4132	48 	H 
	nop			;4133	00 	. 
	nop			;4134	00 	. 
	jr nz,l4138h		;4135	20 01 	  . 
	inc b			;4137	04 	. 
l4138h:
	ld (bc),a			;4138	02 	. 
	nop			;4139	00 	. 
	ld b,b			;413a	40 	@ 
	nop			;413b	00 	. 
	inc b			;413c	04 	. 
	ld bc,l0320h		;413d	01 20 03 	.   . 
	inc bc			;4140	03 	. 
	add a,b			;4141	80 	. 
	ex af,af'			;4142	08 	. 
	ld c,b			;4143	48 	H 
	nop			;4144	00 	. 
	jr nz,l4147h		;4145	20 00 	  . 
l4147h:
	ld b,h			;4147	44 	D 
	nop			;4148	00 	. 
	add a,b			;4149	80 	. 
	nop			;414a	00 	. 
	nop			;414b	00 	. 
	ld (bc),a			;414c	02 	. 
	ld (de),a			;414d	12 	. 
	ex af,af'			;414e	08 	. 
	ld d,d			;414f	52 	R 
l4150h:
	nop			;4150	00 	. 
	nop			;4151	00 	. 
	inc b			;4152	04 	. 
	inc b			;4153	04 	. 
	add a,b			;4154	80 	. 
	nop			;4155	00 	. 
	nop			;4156	00 	. 
	ld hl,(l0004h)		;4157	2a 04 00 	* . . 
	adc a,h			;415a	8c 	. 
	djnz l415dh		;415b	10 00 	. . 
l415dh:
	nop			;415d	00 	. 
	ld bc,l0144h		;415e	01 44 01 	. D . 
	ld b,h			;4161	44 	D 
	ld a,(bc)			;4162	0a 	. 
	nop			;4163	00 	. 
	nop			;4164	00 	. 
	nop			;4165	00 	. 
	nop			;4166	00 	. 
	ld c,c			;4167	49 	I 
	nop			;4168	00 	. 
	inc b			;4169	04 	. 
	nop			;416a	00 	. 
	add a,b			;416b	80 	. 
	sbc a,c			;416c	99 	. 
	nop			;416d	00 	. 
	nop			;416e	00 	. 
	nop			;416f	00 	. 
	ex af,af'			;4170	08 	. 
	ld d,h			;4171	54 	T 
	jr nz,l4174h		;4172	20 00 	  . 
l4174h:
	nop			;4174	00 	. 
	ex af,af'			;4175	08 	. 
	ld b,b			;4176	40 	@ 
l4177h:
	nop			;4177	00 	. 
	ld (bc),a			;4178	02 	. 
	djnz l4183h		;4179	10 08 	. . 
	nop			;417b	00 	. 
	djnz l419eh		;417c	10 20 	.   
	ld h,b			;417e	60 	` 
	ld bc,00800h		;417f	01 00 08 	. . . 
	nop			;4182	00 	. 
l4183h:
	sbc a,b			;4183	98 	. 
	nop			;4184	00 	. 
	nop			;4185	00 	. 
	nop			;4186	00 	. 
	jr l418dh		;4187	18 04 	. . 
	jr z,l418fh		;4189	28 04 	( . 
	inc d			;418b	14 	. 
	nop			;418c	00 	. 
l418dh:
	nop			;418d	00 	. 
	nop			;418e	00 	. 
l418fh:
	ld d,b			;418f	50 	P 
	nop			;4190	00 	. 
	nop			;4191	00 	. 
	nop			;4192	00 	. 
	and b			;4193	a0 	. 
	ld b,c			;4194	41 	A 
	djnz l4197h		;4195	10 00 	. . 
l4197h:
	ex af,af'			;4197	08 	. 
	nop			;4198	00 	. 
	ld b,d			;4199	42 	B 
	nop			;419a	00 	. 
	ex af,af'			;419b	08 	. 
	ld (bc),a			;419c	02 	. 
	ld b,h			;419d	44 	D 
l419eh:
	nop			;419e	00 	. 
	nop			;419f	00 	. 
	ld bc,l0000h		;41a0	01 00 00 	. . . 
	nop			;41a3	00 	. 
	nop			;41a4	00 	. 
	or b			;41a5	b0 	. 
	add a,b			;41a6	80 	. 
	ld h,d			;41a7	62 	b 
	nop			;41a8	00 	. 
	ex af,af'			;41a9	08 	. 
	nop			;41aa	00 	. 
	ld bc,l0050h		;41ab	01 50 00 	. P . 
	inc h			;41ae	24 	$ 
	djnz l41b3h		;41af	10 02 	. . 
	ret po			;41b1	e0 	. 
	nop			;41b2	00 	. 
l41b3h:
	sub b			;41b3	90 	. 
	inc b			;41b4	04 	. 
	nop			;41b5	00 	. 
	ld bc,l0010h		;41b6	01 10 00 	. . . 
	djnz $+6		;41b9	10 04 	. . 
	nop			;41bb	00 	. 
	ld c,c			;41bc	49 	I 
	ld b,b			;41bd	40 	@ 
	jr nz,l41c0h		;41be	20 00 	  . 
l41c0h:
	ex af,af'			;41c0	08 	. 
	ld e,d			;41c1	5a 	Z 
	ld (bc),a			;41c2	02 	. 
	ld bc,l0000h		;41c3	01 00 00 	. . . 
	djnz l41cah		;41c6	10 02 	. . 
	nop			;41c8	00 	. 
	ld (bc),a			;41c9	02 	. 
l41cah:
	add a,b			;41ca	80 	. 
	nop			;41cb	00 	. 
	inc b			;41cc	04 	. 
	inc bc			;41cd	03 	. 
	nop			;41ce	00 	. 
	add hl,bc			;41cf	09 	. 
	inc b			;41d0	04 	. 
	ld (de),a			;41d1	12 	. 
	nop			;41d2	00 	. 
	nop			;41d3	00 	. 
	dec h			;41d4	25 	% 
	nop			;41d5	00 	. 
	djnz $+20		;41d6	10 12 	. . 
	nop			;41d8	00 	. 
	ex af,af'			;41d9	08 	. 
	nop			;41da	00 	. 
	ld (bc),a			;41db	02 	. 
	ld b,h			;41dc	44 	D 
	inc b			;41dd	04 	. 
	ld (l0001h),hl		;41de	22 01 00 	" . . 
	djnz l41f5h		;41e1	10 12 	. . 
	jr nz,l41efh		;41e3	20 0a 	  . 
	add a,b			;41e5	80 	. 
	add a,b			;41e6	80 	. 
	nop			;41e7	00 	. 
	nop			;41e8	00 	. 
	jr nz,l41f5h		;41e9	20 0a 	  . 
	inc b			;41eb	04 	. 
l41ech:
	ld bc,00801h		;41ec	01 01 08 	. . . 
l41efh:
	nop			;41ef	00 	. 
	nop			;41f0	00 	. 
	add a,d			;41f1	82 	. 
	nop			;41f2	00 	. 
	ex af,af'			;41f3	08 	. 
	add a,d			;41f4	82 	. 
l41f5h:
	jr nz,l4177h		;41f5	20 80 	  . 
	nop			;41f7	00 	. 
	nop			;41f8	00 	. 
	djnz $+66		;41f9	10 40 	. @ 
	nop			;41fb	00 	. 
	jr nz,l423eh		;41fc	20 40 	  @ 
	inc b			;41fe	04 	. 
	nop			;41ff	00 	. 
	inc bc			;4200	03 	. 
	ret nz			;4201	c0 	. 
	nop			;4202	00 	. 
	ld (bc),a			;4203	02 	. 
	ld b,c			;4204	41 	A 
	jr z,l4207h		;4205	28 00 	( . 
l4207h:
	ld b,b			;4207	40 	@ 
	nop			;4208	00 	. 
	nop			;4209	00 	. 
	nop			;420a	00 	. 
	ld (bc),a			;420b	02 	. 
	djnz l422eh		;420c	10 20 	.   
	jr nc,$+6		;420e	30 04 	0 . 
	ex af,af'			;4210	08 	. 
	add a,h			;4211	84 	. 
l4212h:
	nop			;4212	00 	. 
	ld (08000h),hl		;4213	22 00 80 	" . . 
	ld (bc),a			;4216	02 	. 
	ld de,sub_0400h		;4217	11 00 04 	. . . 
	inc b			;421a	04 	. 
	sbc a,b			;421b	98 	. 
	ld bc,l0000h		;421c	01 00 00 	. . . 
	nop			;421f	00 	. 
	add hl,bc			;4220	09 	. 
	nop			;4221	00 	. 
	nop			;4222	00 	. 
	inc b			;4223	04 	. 
	ld hl,(00700h)		;4224	2a 00 07 	* . . 
	ld b,b			;4227	40 	@ 
	nop			;4228	00 	. 
	ex af,af'			;4229	08 	. 
	add a,b			;422a	80 	. 
	ld (bc),a			;422b	02 	. 
	nop			;422c	00 	. 
	inc bc			;422d	03 	. 
l422eh:
	djnz l4238h		;422e	10 08 	. . 
	nop			;4230	00 	. 
	add a,b			;4231	80 	. 
	jr nz,l4274h		;4232	20 40 	  @ 
	ld bc,l0002h		;4234	01 02 00 	. . . 
	ld b,h			;4237	44 	D 
l4238h:
	ex af,af'			;4238	08 	. 
	ld b,b			;4239	40 	@ 
	ld (l0052h),hl		;423a	22 52 00 	" R . 
	nop			;423d	00 	. 
l423eh:
	nop			;423e	00 	. 
	inc b			;423f	04 	. 
	nop			;4240	00 	. 
	inc b			;4241	04 	. 
	inc b			;4242	04 	. 
	inc b			;4243	04 	. 
	jr nz,l4246h		;4244	20 00 	  . 
l4246h:
	djnz l4288h		;4246	10 40 	. @ 
	inc b			;4248	04 	. 
	djnz $+34		;4249	10 20 	.   
	ld bc,l0080h		;424b	01 80 00 	. . . 
	sub b			;424e	90 	. 
	ld b,b			;424f	40 	@ 
	ld bc,l4020h		;4250	01 20 40 	.   @ 
	jr nz,l4265h		;4253	20 10 	  . 
	ld b,h			;4255	44 	D 
	nop			;4256	00 	. 
	inc c			;4257	0c 	. 
	nop			;4258	00 	. 
	adc a,d			;4259	8a 	. 
	nop			;425a	00 	. 
	ld hl,sub_0400h		;425b	21 00 04 	! . . 
	ex af,af'			;425e	08 	. 
	add a,b			;425f	80 	. 
	nop			;4260	00 	. 
	inc h			;4261	24 	$ 
	nop			;4262	00 	. 
	ld (bc),a			;4263	02 	. 
	add a,b			;4264	80 	. 
l4265h:
	nop			;4265	00 	. 
	ld a,(bc)			;4266	0a 	. 
	and b			;4267	a0 	. 
	nop			;4268	00 	. 
	inc d			;4269	14 	. 
	jr nz,l41ech		;426a	20 80 	  . 
	nop			;426c	00 	. 
	nop			;426d	00 	. 
	djnz l42c0h		;426e	10 50 	. P 
	inc b			;4270	04 	. 
	nop			;4271	00 	. 
	nop			;4272	00 	. 
	inc b			;4273	04 	. 
l4274h:
	ex af,af'			;4274	08 	. 
	nop			;4275	00 	. 
	call nz,00280h		;4276	c4 80 02 	. . . 
	nop			;4279	00 	. 
	jr nz,l427ch		;427a	20 00 	  . 
l427ch:
	ld bc,08003h		;427c	01 03 80 	. . . 
	add a,h			;427f	84 	. 
	ld bc,l38c8h		;4280	01 c8 38 	. . 8 
	add a,b			;4283	80 	. 
	add a,b			;4284	80 	. 
	nop			;4285	00 	. 
	nop			;4286	00 	. 
	ex af,af'			;4287	08 	. 
l4288h:
	djnz l4212h		;4288	10 88 	. . 
	nop			;428a	00 	. 
	inc b			;428b	04 	. 
	nop			;428c	00 	. 
	ex af,af'			;428d	08 	. 
	ld bc,l3040h		;428e	01 40 30 	. @ 0 
	ex af,af'			;4291	08 	. 
	inc b			;4292	04 	. 
	ld (bc),a			;4293	02 	. 
	jr nz,l4296h		;4294	20 00 	  . 
l4296h:
	ex af,af'			;4296	08 	. 
	add a,h			;4297	84 	. 
	jr nz,l429ah		;4298	20 00 	  . 
l429ah:
	ex af,af'			;429a	08 	. 
	ld (de),a			;429b	12 	. 
	ld hl,l0040h		;429c	21 40 00 	! @ . 
	nop			;429f	00 	. 
	ld b,000h		;42a0	06 00 	. . 
	inc b			;42a2	04 	. 
	ld b,b			;42a3	40 	@ 
	nop			;42a4	00 	. 
	ld b,b			;42a5	40 	@ 
	nop			;42a6	00 	. 
	nop			;42a7	00 	. 
	jr z,$+4		;42a8	28 02 	( . 
	add hl,bc			;42aa	09 	. 
	jr nz,l42bfh		;42ab	20 12 	  . 
	nop			;42ad	00 	. 
	inc b			;42ae	04 	. 
	nop			;42af	00 	. 
	ld bc,l080ch		;42b0	01 0c 08 	. . . 
	nop			;42b3	00 	. 
	ld bc,sub_0400h		;42b4	01 00 04 	. . . 
	ex af,af'			;42b7	08 	. 
	nop			;42b8	00 	. 
	ld h,b			;42b9	60 	` 
	nop			;42ba	00 	. 
	nop			;42bb	00 	. 
	inc b			;42bc	04 	. 
	ld h,b			;42bd	60 	` 
	ld h,b			;42be	60 	` 
l42bfh:
	and b			;42bf	a0 	. 
l42c0h:
	nop			;42c0	00 	. 
	nop			;42c1	00 	. 
	ld (bc),a			;42c2	02 	. 
	ex af,af'			;42c3	08 	. 
	nop			;42c4	00 	. 
	nop			;42c5	00 	. 
	nop			;42c6	00 	. 
	jr z,l4309h		;42c7	28 40 	( @ 
	ld (de),a			;42c9	12 	. 
	nop			;42ca	00 	. 
	ld (bc),a			;42cb	02 	. 
	ld (bc),a			;42cc	02 	. 
	nop			;42cd	00 	. 
	ex af,af'			;42ce	08 	. 
	nop			;42cf	00 	. 
	inc b			;42d0	04 	. 
	add hl,bc			;42d1	09 	. 
	ld bc,00208h		;42d2	01 08 02 	. . . 
	ld d,b			;42d5	50 	P 
	ld b,b			;42d6	40 	@ 
	nop			;42d7	00 	. 
	nop			;42d8	00 	. 
	adc a,b			;42d9	88 	. 
	nop			;42da	00 	. 
	nop			;42db	00 	. 
	ld b,b			;42dc	40 	@ 
	ret nz			;42dd	c0 	. 
	inc b			;42de	04 	. 
	add hl,bc			;42df	09 	. 
	ret nz			;42e0	c0 	. 
	nop			;42e1	00 	. 
	nop			;42e2	00 	. 
	nop			;42e3	00 	. 
	nop			;42e4	00 	. 
	ld b,b			;42e5	40 	@ 
	ld (bc),a			;42e6	02 	. 
	inc bc			;42e7	03 	. 
	ld b,b			;42e8	40 	@ 
	ld a,(bc)			;42e9	0a 	. 
	ex af,af'			;42ea	08 	. 
	jr nz,l42edh		;42eb	20 00 	  . 
l42edh:
	inc h			;42ed	24 	$ 
	nop			;42ee	00 	. 
	djnz l4331h		;42ef	10 40 	. @ 
	nop			;42f1	00 	. 
	ld a,(bc)			;42f2	0a 	. 
	djnz l4335h		;42f3	10 40 	. @ 
	ld (bc),a			;42f5	02 	. 
	nop			;42f6	00 	. 
	add a,h			;42f7	84 	. 
	ex af,af'			;42f8	08 	. 
	add a,b			;42f9	80 	. 
	nop			;42fa	00 	. 
	nop			;42fb	00 	. 
	ex af,af'			;42fc	08 	. 
	ld bc,02002h		;42fd	01 02 20 	. .   
	nop			;4300	00 	. 
	jr nz,l4310h		;4301	20 0d 	  . 
	ld b,b			;4303	40 	@ 
	inc b			;4304	04 	. 
	ld b,b			;4305	40 	@ 
	inc b			;4306	04 	. 
	nop			;4307	00 	. 
	add a,d			;4308	82 	. 
l4309h:
	djnz l430bh		;4309	10 00 	. . 
l430bh:
	djnz l430dh		;430b	10 00 	. . 
l430dh:
	ld h,b			;430d	60 	` 
	and b			;430e	a0 	. 
	nop			;430f	00 	. 
l4310h:
	ld b,d			;4310	42 	B 
	add a,b			;4311	80 	. 
	nop			;4312	00 	. 
	add a,b			;4313	80 	. 
	nop			;4314	00 	. 
	ld (hl),c			;4315	71 	q 
	nop			;4316	00 	. 
	ld (bc),a			;4317	02 	. 
	add a,b			;4318	80 	. 
	ld bc,00200h		;4319	01 00 02 	. . . 
	nop			;431c	00 	. 
	add a,b			;431d	80 	. 
	ld (bc),a			;431e	02 	. 
	djnz l432fh		;431f	10 0e 	. . 
	nop			;4321	00 	. 
	ld (bc),a			;4322	02 	. 
	sub (hl)			;4323	96 	. 
	ld (de),a			;4324	12 	. 
	ld bc,08000h		;4325	01 00 80 	. . . 
	nop			;4328	00 	. 
	nop			;4329	00 	. 
	nop			;432a	00 	. 
	nop			;432b	00 	. 
	nop			;432c	00 	. 
	nop			;432d	00 	. 
	nop			;432e	00 	. 
l432fh:
	sbc a,(hl)			;432f	9e 	. 
	nop			;4330	00 	. 
l4331h:
	ld de,08800h		;4331	11 00 88 	. . . 
	inc h			;4334	24 	$ 
l4335h:
	add hl,bc			;4335	09 	. 
	inc b			;4336	04 	. 
	jr nz,l4339h		;4337	20 00 	  . 
l4339h:
	nop			;4339	00 	. 
	nop			;433a	00 	. 
	add a,h			;433b	84 	. 
	ld (l0240h),hl		;433c	22 40 02 	" @ . 
	nop			;433f	00 	. 
	add a,b			;4340	80 	. 
	nop			;4341	00 	. 
	nop			;4342	00 	. 
	inc h			;4343	24 	$ 
	nop			;4344	00 	. 
	ld hl,l0600h		;4345	21 00 06 	! . . 
	jr l434ah		;4348	18 00 	. . 
l434ah:
	nop			;434a	00 	. 
	nop			;434b	00 	. 
	nop			;434c	00 	. 
	ld bc,l6022h		;434d	01 22 60 	. " ` 
	nop			;4350	00 	. 
	ld de,l0600h		;4351	11 00 06 	. . . 
	nop			;4354	00 	. 
	ld bc,00200h		;4355	01 00 02 	. . . 
	ld (bc),a			;4358	02 	. 
	ld a,(bc)			;4359	0a 	. 
	ex af,af'			;435a	08 	. 
	ld b,b			;435b	40 	@ 
	jr nz,$+10		;435c	20 08 	  . 
	nop			;435e	00 	. 
	adc a,h			;435f	8c 	. 
	ld (bc),a			;4360	02 	. 
	ld (bc),a			;4361	02 	. 
	nop			;4362	00 	. 
	inc b			;4363	04 	. 
	nop			;4364	00 	. 
	ld bc,04030h		;4365	01 30 40 	. 0 @ 
	ld d,b			;4368	50 	P 
	djnz l436bh		;4369	10 00 	. . 
l436bh:
	ld (08420h),a		;436b	32 20 84 	2   . 
	ex af,af'			;436e	08 	. 
	nop			;436f	00 	. 
	nop			;4370	00 	. 
	inc b			;4371	04 	. 
	nop			;4372	00 	. 
	inc b			;4373	04 	. 
	ld b,h			;4374	44 	D 
	nop			;4375	00 	. 
	nop			;4376	00 	. 
	ld b,l			;4377	45 	E 
	ld bc,00800h		;4378	01 00 08 	. . . 
	nop			;437b	00 	. 
	nop			;437c	00 	. 
	nop			;437d	00 	. 
	ld h,d			;437e	62 	b 
	add a,b			;437f	80 	. 
	jr z,$+19		;4380	28 11 	( . 
	nop			;4382	00 	. 
	nop			;4383	00 	. 
	ld b,b			;4384	40 	@ 
	ld b,c			;4385	41 	A 
	ex af,af'			;4386	08 	. 
	jr nz,l4399h		;4387	20 10 	  . 
	ex af,af'			;4389	08 	. 
	nop			;438a	00 	. 
	add a,d			;438b	82 	. 
	ld (bc),a			;438c	02 	. 
	nop			;438d	00 	. 
	ld h,b			;438e	60 	` 
	ld b,000h		;438f	06 00 	. . 
	ld bc,l1000h		;4391	01 00 10 	. . . 
	nop			;4394	00 	. 
	nop			;4395	00 	. 
	add hl,de			;4396	19 	. 
	nop			;4397	00 	. 
	add a,c			;4398	81 	. 
l4399h:
	nop			;4399	00 	. 
	inc b			;439a	04 	. 
	djnz l439dh		;439b	10 00 	. . 
l439dh:
	ld de,l1022h		;439d	11 22 10 	. " . 
	nop			;43a0	00 	. 
	nop			;43a1	00 	. 
	nop			;43a2	00 	. 
	inc b			;43a3	04 	. 
	add a,b			;43a4	80 	. 
	nop			;43a5	00 	. 
	ld b,b			;43a6	40 	@ 
	ld bc,l0010h		;43a7	01 10 00 	. . . 
	ld (bc),a			;43aa	02 	. 
	nop			;43ab	00 	. 
	inc d			;43ac	14 	. 
	jr nz,l43c0h		;43ad	20 11 	  . 
	nop			;43af	00 	. 
	nop			;43b0	00 	. 
	sbc a,b			;43b1	98 	. 
	nop			;43b2	00 	. 
	ld b,b			;43b3	40 	@ 
	nop			;43b4	00 	. 
	jr nz,l43b7h		;43b5	20 00 	  . 
l43b7h:
	and b			;43b7	a0 	. 
	ld c,h			;43b8	4c 	L 
	ld b,b			;43b9	40 	@ 
	nop			;43ba	00 	. 
	ld b,b			;43bb	40 	@ 
	nop			;43bc	00 	. 
	ld bc,l0000h		;43bd	01 00 00 	. . . 
l43c0h:
	ld (hl),h			;43c0	74 	t 
	add a,b			;43c1	80 	. 
	nop			;43c2	00 	. 
	ld h,b			;43c3	60 	` 
	djnz l43cah		;43c4	10 04 	. . 
	nop			;43c6	00 	. 
	ld bc,l0100h		;43c7	01 00 01 	. . . 
l43cah:
	ld (bc),a			;43ca	02 	. 
	ld (bc),a			;43cb	02 	. 
	ld c,b			;43cc	48 	H 
	adc a,b			;43cd	88 	. 
	djnz l43f0h		;43ce	10 20 	.   
	ex af,af'			;43d0	08 	. 
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
	rst 38h			;43db	ff 	. 
	rst 38h			;43dc	ff 	. 
	rst 38h			;43dd	ff 	. 
	rst 38h			;43de	ff 	. 
	rst 38h			;43df	ff 	. 
	rst 38h			;43e0	ff 	. 
	rst 38h			;43e1	ff 	. 
	rst 38h			;43e2	ff 	. 
	nop			;43e3	00 	. 
	nop			;43e4	00 	. 
	nop			;43e5	00 	. 
	nop			;43e6	00 	. 
	nop			;43e7	00 	. 
	nop			;43e8	00 	. 
	nop			;43e9	00 	. 
	nop			;43ea	00 	. 
	rst 38h			;43eb	ff 	. 
	rst 38h			;43ec	ff 	. 
	rst 38h			;43ed	ff 	. 
	rst 38h			;43ee	ff 	. 
	rst 38h			;43ef	ff 	. 
l43f0h:
	rst 38h			;43f0	ff 	. 
	rst 38h			;43f1	ff 	. 
	rst 38h			;43f2	ff 	. 
	nop			;43f3	00 	. 
	nop			;43f4	00 	. 
	nop			;43f5	00 	. 
	nop			;43f6	00 	. 
	nop			;43f7	00 	. 
	nop			;43f8	00 	. 
	nop			;43f9	00 	. 
	nop			;43fa	00 	. 
	rst 38h			;43fb	ff 	. 
	rst 38h			;43fc	ff 	. 
	rst 38h			;43fd	ff 	. 
	rst 38h			;43fe	ff 	. 
l43ffh:
	rst 38h			;43ff	ff 	. 
	rst 38h			;4400	ff 	. 
	rst 38h			;4401	ff 	. 
	rst 38h			;4402	ff 	. 
	nop			;4403	00 	. 
	nop			;4404	00 	. 
	nop			;4405	00 	. 
	nop			;4406	00 	. 
	nop			;4407	00 	. 
	nop			;4408	00 	. 
	nop			;4409	00 	. 
	nop			;440a	00 	. 
	nop			;440b	00 	. 
	adc a,c			;440c	89 	. 
	ld (l0001h),hl		;440d	22 01 00 	" . . 
	jr nz,l4412h		;4410	20 00 	  . 
l4412h:
	nop			;4412	00 	. 
	add a,b			;4413	80 	. 
	nop			;4414	00 	. 
	nop			;4415	00 	. 
	nop			;4416	00 	. 
	ex af,af'			;4417	08 	. 
	nop			;4418	00 	. 
	add a,b			;4419	80 	. 
	dec bc			;441a	0b 	. 
	ex af,af'			;441b	08 	. 
	jr nc,l445eh		;441c	30 40 	0 @ 
	nop			;441e	00 	. 
	inc h			;441f	24 	$ 
	djnz $+18		;4420	10 10 	. . 
	nop			;4422	00 	. 
	ld c,b			;4423	48 	H 
	ld h,b			;4424	60 	` 
	ld (bc),a			;4425	02 	. 
	nop			;4426	00 	. 
	nop			;4427	00 	. 
	add a,c			;4428	81 	. 
	ld (bc),a			;4429	02 	. 
	nop			;442a	00 	. 
	nop			;442b	00 	. 
	adc a,b			;442c	88 	. 
	nop			;442d	00 	. 
	nop			;442e	00 	. 
	jr z,l4431h		;442f	28 00 	( . 
l4431h:
	ld de,l0008h		;4431	11 08 00 	. . . 
	ex af,af'			;4434	08 	. 
	djnz l4457h		;4435	10 20 	.   
	ld h,h			;4437	64 	d 
	nop			;4438	00 	. 
	ld hl,00200h		;4439	21 00 02 	! . . 
	nop			;443c	00 	. 
	add a,h			;443d	84 	. 
	add a,b			;443e	80 	. 
	jr nz,l4455h		;443f	20 14 	  . 
	jr nz,l4443h		;4441	20 00 	  . 
l4443h:
	add a,b			;4443	80 	. 
	nop			;4444	00 	. 
l4445h:
	jr nz,l444ch		;4445	20 05 	  . 
	nop			;4447	00 	. 
	ld b,d			;4448	42 	B 
	inc h			;4449	24 	$ 
	nop			;444a	00 	. 
	add a,b			;444b	80 	. 
l444ch:
	inc b			;444c	04 	. 
	ld b,(hl)			;444d	46 	F 
	add hl,bc			;444e	09 	. 
	nop			;444f	00 	. 
	nop			;4450	00 	. 
	nop			;4451	00 	. 
	inc b			;4452	04 	. 
	ld (bc),a			;4453	02 	. 
	inc bc			;4454	03 	. 
l4455h:
	ld (bc),a			;4455	02 	. 
	ld b,b			;4456	40 	@ 
l4457h:
	jr nc,l4459h		;4457	30 00 	0 . 
l4459h:
	nop			;4459	00 	. 
	ex af,af'			;445a	08 	. 
	nop			;445b	00 	. 
	ret nz			;445c	c0 	. 
	ld d,b			;445d	50 	P 
l445eh:
	nop			;445e	00 	. 
	nop			;445f	00 	. 
	nop			;4460	00 	. 
	adc a,h			;4461	8c 	. 
	nop			;4462	00 	. 
	inc b			;4463	04 	. 
	nop			;4464	00 	. 
	ld hl,l0004h		;4465	21 04 00 	! . . 
	nop			;4468	00 	. 
	add a,b			;4469	80 	. 
	ld bc,l0210h		;446a	01 10 02 	. . . 
	nop			;446d	00 	. 
	jr nz,l4474h		;446e	20 04 	  . 
	ld b,b			;4470	40 	@ 
	inc b			;4471	04 	. 
	inc b			;4472	04 	. 
	add a,b			;4473	80 	. 
l4474h:
	inc b			;4474	04 	. 
	add a,b			;4475	80 	. 
	ld bc,02220h		;4476	01 20 22 	.   " 
	nop			;4479	00 	. 
	nop			;447a	00 	. 
	inc b			;447b	04 	. 
	nop			;447c	00 	. 
	djnz l43ffh		;447d	10 80 	. . 
	ld (00121h),hl		;447f	22 21 01 	" ! . 
	nop			;4482	00 	. 
	nop			;4483	00 	. 
	nop			;4484	00 	. 
	ld bc,l0288h		;4485	01 88 02 	. . . 
	sub b			;4488	90 	. 
	jr z,l448bh		;4489	28 00 	( . 
l448bh:
	nop			;448b	00 	. 
	ld b,b			;448c	40 	@ 
	jr nz,l449fh		;448d	20 10 	  . 
	adc a,b			;448f	88 	. 
	ex af,af'			;4490	08 	. 
	add a,b			;4491	80 	. 
	nop			;4492	00 	. 
	nop			;4493	00 	. 
	ld b,b			;4494	40 	@ 
	nop			;4495	00 	. 
	inc b			;4496	04 	. 
	inc b			;4497	04 	. 
	add a,b			;4498	80 	. 
	ld (bc),a			;4499	02 	. 
	rlca			;449a	07 	. 
	ld b,b			;449b	40 	@ 
	ex af,af'			;449c	08 	. 
	add a,b			;449d	80 	. 
	adc a,b			;449e	88 	. 
l449fh:
	ld b,b			;449f	40 	@ 
	ld bc,l0000h		;44a0	01 00 00 	. . . 
	nop			;44a3	00 	. 
	djnz l44b6h		;44a4	10 10 	. . 
	jr nc,l44a8h		;44a6	30 00 	0 . 
l44a8h:
	ld b,h			;44a8	44 	D 
	nop			;44a9	00 	. 
	ld bc,04030h		;44aa	01 30 40 	. 0 @ 
	jr nz,l44cfh		;44ad	20 20 	    
	ld b,b			;44af	40 	@ 
	inc b			;44b0	04 	. 
	jr nz,l44b3h		;44b1	20 00 	  . 
l44b3h:
	and b			;44b3	a0 	. 
	nop			;44b4	00 	. 
	inc b			;44b5	04 	. 
l44b6h:
	djnz l44b8h		;44b6	10 00 	. . 
l44b8h:
	add hl,bc			;44b8	09 	. 
	djnz l44bbh		;44b9	10 00 	. . 
l44bbh:
	nop			;44bb	00 	. 
	nop			;44bc	00 	. 
	ret nz			;44bd	c0 	. 
	inc b			;44be	04 	. 
	ld e,h			;44bf	5c 	\ 
	ld b,b			;44c0	40 	@ 
	nop			;44c1	00 	. 
	nop			;44c2	00 	. 
	djnz l4445h		;44c3	10 80 	. . 
	djnz l44ebh		;44c5	10 24 	. $ 
	ex af,af'			;44c7	08 	. 
	nop			;44c8	00 	. 
	ld (de),a			;44c9	12 	. 
	nop			;44ca	00 	. 
	inc h			;44cb	24 	$ 
	nop			;44cc	00 	. 
	add a,b			;44cd	80 	. 
	ld b,b			;44ce	40 	@ 
l44cfh:
	jr nz,l44d1h		;44cf	20 00 	  . 
l44d1h:
	jr nc,l44d4h		;44d1	30 01 	0 . 
	inc b			;44d3	04 	. 
l44d4h:
	ld b,b			;44d4	40 	@ 
	jr z,l44d9h		;44d5	28 02 	( . 
	nop			;44d7	00 	. 
	nop			;44d8	00 	. 
l44d9h:
	ld bc,l0002h		;44d9	01 02 00 	. . . 
	sub b			;44dc	90 	. 
	sub b			;44dd	90 	. 
	nop			;44de	00 	. 
	ld b,b			;44df	40 	@ 
	nop			;44e0	00 	. 
	jr nc,l44e3h		;44e1	30 00 	0 . 
l44e3h:
	inc e			;44e3	1c 	. 
	nop			;44e4	00 	. 
	ld b,b			;44e5	40 	@ 
	ld d,b			;44e6	50 	P 
	ex af,af'			;44e7	08 	. 
	ld (bc),a			;44e8	02 	. 
	nop			;44e9	00 	. 
	nop			;44ea	00 	. 
l44ebh:
	nop			;44eb	00 	. 
	inc b			;44ec	04 	. 
	nop			;44ed	00 	. 
	djnz l44f0h		;44ee	10 00 	. . 
l44f0h:
	ret z			;44f0	c8 	. 
	inc b			;44f1	04 	. 
	ld (bc),a			;44f2	02 	. 
	add a,b			;44f3	80 	. 
	nop			;44f4	00 	. 
	ld b,b			;44f5	40 	@ 
	ld bc,l1140h		;44f6	01 40 11 	. @ . 
	ld (bc),a			;44f9	02 	. 
	nop			;44fa	00 	. 
	nop			;44fb	00 	. 
	inc e			;44fc	1c 	. 
	nop			;44fd	00 	. 
	ld (bc),a			;44fe	02 	. 
	add a,b			;44ff	80 	. 
	ld b,b			;4500	40 	@ 
	nop			;4501	00 	. 
	inc b			;4502	04 	. 
	nop			;4503	00 	. 
	nop			;4504	00 	. 
	jr nz,$+50		;4505	20 30 	  0 
	ld de,00808h		;4507	11 08 08 	. . . 
	nop			;450a	00 	. 
	ld c,b			;450b	48 	H 
	and b			;450c	a0 	. 
	nop			;450d	00 	. 
	djnz l4510h		;450e	10 00 	. . 
l4510h:
	nop			;4510	00 	. 
	djnz l4513h		;4511	10 00 	. . 
l4513h:
	jr z,l4515h		;4513	28 00 	( . 
l4515h:
	ld b,044h		;4515	06 44 	. D 
	ld bc,l1000h		;4517	01 00 10 	. . . 
	nop			;451a	00 	. 
	ld a,(bc)			;451b	0a 	. 
	ex af,af'			;451c	08 	. 
	call nz,l0001h		;451d	c4 01 00 	. . . 
	djnz l4522h		;4520	10 00 	. . 
l4522h:
	nop			;4522	00 	. 
	ld h,b			;4523	60 	` 
	nop			;4524	00 	. 
	ld hl,l2000h		;4525	21 00 20 	! .   
	nop			;4528	00 	. 
	ld bc,00409h		;4529	01 09 04 	. . . 
	ld b,c			;452c	41 	A 
	inc c			;452d	0c 	. 
	ld a,(bc)			;452e	0a 	. 
	nop			;452f	00 	. 
	nop			;4530	00 	. 
	ex af,af'			;4531	08 	. 
l4532h:
	nop			;4532	00 	. 
	nop			;4533	00 	. 
	inc b			;4534	04 	. 
	ld de,08200h		;4535	11 00 82 	. . . 
	inc d			;4538	14 	. 
	nop			;4539	00 	. 
	inc b			;453a	04 	. 
	nop			;453b	00 	. 
	ld (bc),a			;453c	02 	. 
	ex af,af'			;453d	08 	. 
	ld c,b			;453e	48 	H 
	nop			;453f	00 	. 
	ld b,b			;4540	40 	@ 
	nop			;4541	00 	. 
	ld bc,l0004h		;4542	01 04 00 	. . . 
	dec b			;4545	05 	. 
	jr nz,l458ch		;4546	20 44 	  D 
	inc b			;4548	04 	. 
	nop			;4549	00 	. 
	ex af,af'			;454a	08 	. 
	ld b,b			;454b	40 	@ 
	ret nz			;454c	c0 	. 
	jr nc,l4553h		;454d	30 04 	0 . 
	nop			;454f	00 	. 
	ld (bc),a			;4550	02 	. 
	nop			;4551	00 	. 
	nop			;4552	00 	. 
l4553h:
	ex af,af'			;4553	08 	. 
	nop			;4554	00 	. 
	ex af,af'			;4555	08 	. 
	ex af,af'			;4556	08 	. 
	ld b,d			;4557	42 	B 
	nop			;4558	00 	. 
	djnz l455bh		;4559	10 00 	. . 
l455bh:
	nop			;455b	00 	. 
	nop			;455c	00 	. 
	inc d			;455d	14 	. 
	ld h,d			;455e	62 	b 
	nop			;455f	00 	. 
	nop			;4560	00 	. 
	sbc a,b			;4561	98 	. 
	nop			;4562	00 	. 
	nop			;4563	00 	. 
	nop			;4564	00 	. 
	nop			;4565	00 	. 
	nop			;4566	00 	. 
	nop			;4567	00 	. 
	nop			;4568	00 	. 
	nop			;4569	00 	. 
	nop			;456a	00 	. 
	rst 38h			;456b	ff 	. 
	rst 38h			;456c	ff 	. 
	rst 38h			;456d	ff 	. 
	rst 38h			;456e	ff 	. 
	rst 38h			;456f	ff 	. 
	rst 38h			;4570	ff 	. 
	rst 38h			;4571	ff 	. 
	rst 38h			;4572	ff 	. 
	nop			;4573	00 	. 
	nop			;4574	00 	. 
	nop			;4575	00 	. 
	nop			;4576	00 	. 
	nop			;4577	00 	. 
	nop			;4578	00 	. 
	nop			;4579	00 	. 
	nop			;457a	00 	. 
	rst 38h			;457b	ff 	. 
	rst 38h			;457c	ff 	. 
	rst 38h			;457d	ff 	. 
	rst 38h			;457e	ff 	. 
	rst 38h			;457f	ff 	. 
	rst 38h			;4580	ff 	. 
	rst 38h			;4581	ff 	. 
	rst 38h			;4582	ff 	. 
	nop			;4583	00 	. 
	nop			;4584	00 	. 
	nop			;4585	00 	. 
	nop			;4586	00 	. 
	nop			;4587	00 	. 
	nop			;4588	00 	. 
	nop			;4589	00 	. 
	nop			;458a	00 	. 
	rst 38h			;458b	ff 	. 
l458ch:
	rst 38h			;458c	ff 	. 
	rst 38h			;458d	ff 	. 
	rst 38h			;458e	ff 	. 
	rst 38h			;458f	ff 	. 
	rst 38h			;4590	ff 	. 
	rst 38h			;4591	ff 	. 
	rst 38h			;4592	ff 	. 
	nop			;4593	00 	. 
	nop			;4594	00 	. 
	nop			;4595	00 	. 
	nop			;4596	00 	. 
	nop			;4597	00 	. 
	nop			;4598	00 	. 
	nop			;4599	00 	. 
	nop			;459a	00 	. 
	ld b,b			;459b	40 	@ 
	ld b,b			;459c	40 	@ 
	add a,b			;459d	80 	. 
	sub b			;459e	90 	. 
	nop			;459f	00 	. 
	ld bc,l0000h		;45a0	01 00 00 	. . . 
	add a,b			;45a3	80 	. 
	add a,b			;45a4	80 	. 
	nop			;45a5	00 	. 
	nop			;45a6	00 	. 
	ex af,af'			;45a7	08 	. 
	djnz l4532h		;45a8	10 88 	. . 
	nop			;45aa	00 	. 
	inc b			;45ab	04 	. 
	nop			;45ac	00 	. 
	ex af,af'			;45ad	08 	. 
	ld bc,l3040h		;45ae	01 40 30 	. @ 0 
	ex af,af'			;45b1	08 	. 
	inc b			;45b2	04 	. 
	ld (bc),a			;45b3	02 	. 
	jr nz,l45b6h		;45b4	20 00 	  . 
l45b6h:
	ex af,af'			;45b6	08 	. 
	add a,h			;45b7	84 	. 
	jr nz,l45bah		;45b8	20 00 	  . 
l45bah:
	ex af,af'			;45ba	08 	. 
	ld (de),a			;45bb	12 	. 
	ld hl,l0040h		;45bc	21 40 00 	! @ . 
	nop			;45bf	00 	. 
	ld b,000h		;45c0	06 00 	. . 
	inc b			;45c2	04 	. 
	ld b,b			;45c3	40 	@ 
	nop			;45c4	00 	. 
	ld b,b			;45c5	40 	@ 
	nop			;45c6	00 	. 
	nop			;45c7	00 	. 
	jr z,$+4		;45c8	28 02 	( . 
	add hl,bc			;45ca	09 	. 
	jr nz,l45dfh		;45cb	20 12 	  . 
	nop			;45cd	00 	. 
	inc b			;45ce	04 	. 
	nop			;45cf	00 	. 
	ld bc,l080ch		;45d0	01 0c 08 	. . . 
	nop			;45d3	00 	. 
	ld bc,sub_0400h		;45d4	01 00 04 	. . . 
	ex af,af'			;45d7	08 	. 
	nop			;45d8	00 	. 
	ld h,b			;45d9	60 	` 
	nop			;45da	00 	. 
	nop			;45db	00 	. 
	inc b			;45dc	04 	. 
	ld h,b			;45dd	60 	` 
	ld h,b			;45de	60 	` 
l45dfh:
	and b			;45df	a0 	. 
	nop			;45e0	00 	. 
	nop			;45e1	00 	. 
	ld (bc),a			;45e2	02 	. 
	ex af,af'			;45e3	08 	. 
	nop			;45e4	00 	. 
	nop			;45e5	00 	. 
	nop			;45e6	00 	. 
	jr z,l4629h		;45e7	28 40 	( @ 
	ld (de),a			;45e9	12 	. 
	nop			;45ea	00 	. 
	ld (bc),a			;45eb	02 	. 
	ld (bc),a			;45ec	02 	. 
	nop			;45ed	00 	. 
	ex af,af'			;45ee	08 	. 
	nop			;45ef	00 	. 
	inc b			;45f0	04 	. 
	add hl,bc			;45f1	09 	. 
	ld bc,00208h		;45f2	01 08 02 	. . . 
	ld d,b			;45f5	50 	P 
	ld b,b			;45f6	40 	@ 
	nop			;45f7	00 	. 
	nop			;45f8	00 	. 
	adc a,b			;45f9	88 	. 
	nop			;45fa	00 	. 
	nop			;45fb	00 	. 
	ld b,b			;45fc	40 	@ 
	ret nz			;45fd	c0 	. 
	inc b			;45fe	04 	. 
	add hl,bc			;45ff	09 	. 
	ret nz			;4600	c0 	. 
	nop			;4601	00 	. 
	nop			;4602	00 	. 
	nop			;4603	00 	. 
	nop			;4604	00 	. 
	ld b,b			;4605	40 	@ 
	ld (bc),a			;4606	02 	. 
	inc bc			;4607	03 	. 
	ld b,b			;4608	40 	@ 
	ld a,(bc)			;4609	0a 	. 
	ex af,af'			;460a	08 	. 
	jr nz,l460dh		;460b	20 00 	  . 
l460dh:
	inc h			;460d	24 	$ 
	nop			;460e	00 	. 
	djnz l4651h		;460f	10 40 	. @ 
	nop			;4611	00 	. 
	ld a,(bc)			;4612	0a 	. 
	djnz l4655h		;4613	10 40 	. @ 
	ld (bc),a			;4615	02 	. 
	nop			;4616	00 	. 
	add a,h			;4617	84 	. 
	ex af,af'			;4618	08 	. 
	add a,b			;4619	80 	. 
	nop			;461a	00 	. 
	nop			;461b	00 	. 
	ex af,af'			;461c	08 	. 
	ld bc,02002h		;461d	01 02 20 	. .   
	nop			;4620	00 	. 
	jr nz,l4630h		;4621	20 0d 	  . 
	ld b,b			;4623	40 	@ 
	inc b			;4624	04 	. 
	ld b,b			;4625	40 	@ 
	inc b			;4626	04 	. 
	nop			;4627	00 	. 
	add a,d			;4628	82 	. 
l4629h:
	djnz l462bh		;4629	10 00 	. . 
l462bh:
	djnz l462dh		;462b	10 00 	. . 
l462dh:
	ld h,b			;462d	60 	` 
	and b			;462e	a0 	. 
	nop			;462f	00 	. 
l4630h:
	ld b,d			;4630	42 	B 
	add a,b			;4631	80 	. 
	nop			;4632	00 	. 
	add a,b			;4633	80 	. 
	nop			;4634	00 	. 
	ld (hl),c			;4635	71 	q 
	nop			;4636	00 	. 
	ld (bc),a			;4637	02 	. 
	add a,b			;4638	80 	. 
	ld bc,00200h		;4639	01 00 02 	. . . 
	nop			;463c	00 	. 
	add a,b			;463d	80 	. 
	ld (bc),a			;463e	02 	. 
	djnz l464fh		;463f	10 0e 	. . 
	nop			;4641	00 	. 
	ld (bc),a			;4642	02 	. 
	sub (hl)			;4643	96 	. 
	ld (de),a			;4644	12 	. 
	ld bc,08000h		;4645	01 00 80 	. . . 
	nop			;4648	00 	. 
	nop			;4649	00 	. 
	nop			;464a	00 	. 
	nop			;464b	00 	. 
	nop			;464c	00 	. 
	nop			;464d	00 	. 
	nop			;464e	00 	. 
l464fh:
	sbc a,(hl)			;464f	9e 	. 
	nop			;4650	00 	. 
l4651h:
	ld de,08800h		;4651	11 00 88 	. . . 
	inc h			;4654	24 	$ 
l4655h:
	add hl,bc			;4655	09 	. 
	inc b			;4656	04 	. 
	jr nz,l4659h		;4657	20 00 	  . 
l4659h:
	nop			;4659	00 	. 
	nop			;465a	00 	. 
	add a,h			;465b	84 	. 
	ld (l0240h),hl		;465c	22 40 02 	" @ . 
	nop			;465f	00 	. 
	add a,b			;4660	80 	. 
	nop			;4661	00 	. 
	nop			;4662	00 	. 
	inc h			;4663	24 	$ 
	nop			;4664	00 	. 
	ld hl,l0600h		;4665	21 00 06 	! . . 
	jr l466ah		;4668	18 00 	. . 
l466ah:
	nop			;466a	00 	. 
	nop			;466b	00 	. 
	nop			;466c	00 	. 
	ld bc,l6022h		;466d	01 22 60 	. " ` 
	nop			;4670	00 	. 
	ld de,l0600h		;4671	11 00 06 	. . . 
	nop			;4674	00 	. 
	ld bc,00200h		;4675	01 00 02 	. . . 
	ld (bc),a			;4678	02 	. 
	ld a,(bc)			;4679	0a 	. 
	ex af,af'			;467a	08 	. 
	ld b,b			;467b	40 	@ 
	jr nz,$+10		;467c	20 08 	  . 
	nop			;467e	00 	. 
	adc a,h			;467f	8c 	. 
	ld (bc),a			;4680	02 	. 
	ld (bc),a			;4681	02 	. 
	nop			;4682	00 	. 
	inc b			;4683	04 	. 
	nop			;4684	00 	. 
	ld bc,04030h		;4685	01 30 40 	. 0 @ 
	ld d,b			;4688	50 	P 
	djnz l468bh		;4689	10 00 	. . 
l468bh:
	ld (08420h),a		;468b	32 20 84 	2   . 
	ex af,af'			;468e	08 	. 
	nop			;468f	00 	. 
	nop			;4690	00 	. 
	inc b			;4691	04 	. 
	nop			;4692	00 	. 
	inc b			;4693	04 	. 
	ld b,h			;4694	44 	D 
	nop			;4695	00 	. 
	nop			;4696	00 	. 
	ld b,l			;4697	45 	E 
	ld bc,00800h		;4698	01 00 08 	. . . 
	nop			;469b	00 	. 
	nop			;469c	00 	. 
	nop			;469d	00 	. 
	ld h,d			;469e	62 	b 
	add a,b			;469f	80 	. 
	jr z,$+19		;46a0	28 11 	( . 
	nop			;46a2	00 	. 
	nop			;46a3	00 	. 
	ld b,b			;46a4	40 	@ 
	ld b,c			;46a5	41 	A 
	ex af,af'			;46a6	08 	. 
	jr nz,l46b9h		;46a7	20 10 	  . 
	ex af,af'			;46a9	08 	. 
	nop			;46aa	00 	. 
	add a,d			;46ab	82 	. 
	ld (bc),a			;46ac	02 	. 
	nop			;46ad	00 	. 
	ld h,b			;46ae	60 	` 
	ld b,000h		;46af	06 00 	. . 
	ld bc,l1000h		;46b1	01 00 10 	. . . 
	nop			;46b4	00 	. 
	nop			;46b5	00 	. 
	add hl,de			;46b6	19 	. 
	nop			;46b7	00 	. 
	add a,c			;46b8	81 	. 
l46b9h:
	nop			;46b9	00 	. 
	inc b			;46ba	04 	. 
	djnz l46bdh		;46bb	10 00 	. . 
l46bdh:
	ld de,l1022h		;46bd	11 22 10 	. " . 
	nop			;46c0	00 	. 
	nop			;46c1	00 	. 
	nop			;46c2	00 	. 
	inc b			;46c3	04 	. 
	add a,b			;46c4	80 	. 
	nop			;46c5	00 	. 
	ld b,b			;46c6	40 	@ 
	ld bc,l0010h		;46c7	01 10 00 	. . . 
	ld (bc),a			;46ca	02 	. 
	nop			;46cb	00 	. 
	inc d			;46cc	14 	. 
	jr nz,l46e0h		;46cd	20 11 	  . 
	nop			;46cf	00 	. 
	nop			;46d0	00 	. 
	sbc a,b			;46d1	98 	. 
	nop			;46d2	00 	. 
	ld b,b			;46d3	40 	@ 
	nop			;46d4	00 	. 
	jr nz,l46d7h		;46d5	20 00 	  . 
l46d7h:
	and b			;46d7	a0 	. 
	ld c,h			;46d8	4c 	L 
	ld b,b			;46d9	40 	@ 
	nop			;46da	00 	. 
	ld b,b			;46db	40 	@ 
	nop			;46dc	00 	. 
	ld bc,l0000h		;46dd	01 00 00 	. . . 
l46e0h:
	ld (hl),h			;46e0	74 	t 
	add a,b			;46e1	80 	. 
	nop			;46e2	00 	. 
	ld h,b			;46e3	60 	` 
	djnz l46eah		;46e4	10 04 	. . 
	nop			;46e6	00 	. 
	ld bc,l0100h		;46e7	01 00 01 	. . . 
l46eah:
	ld (bc),a			;46ea	02 	. 
	ld (bc),a			;46eb	02 	. 
	ld c,b			;46ec	48 	H 
	adc a,b			;46ed	88 	. 
	djnz l4710h		;46ee	10 20 	.   
	ex af,af'			;46f0	08 	. 
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
	rst 38h			;46fb	ff 	. 
	rst 38h			;46fc	ff 	. 
	rst 38h			;46fd	ff 	. 
	rst 38h			;46fe	ff 	. 
	rst 38h			;46ff	ff 	. 
	rst 38h			;4700	ff 	. 
	rst 38h			;4701	ff 	. 
	rst 38h			;4702	ff 	. 
	nop			;4703	00 	. 
	nop			;4704	00 	. 
	nop			;4705	00 	. 
	nop			;4706	00 	. 
	nop			;4707	00 	. 
	nop			;4708	00 	. 
	nop			;4709	00 	. 
	nop			;470a	00 	. 
	rst 38h			;470b	ff 	. 
	rst 38h			;470c	ff 	. 
	rst 38h			;470d	ff 	. 
	rst 38h			;470e	ff 	. 
	rst 38h			;470f	ff 	. 
l4710h:
	rst 38h			;4710	ff 	. 
	rst 38h			;4711	ff 	. 
	rst 38h			;4712	ff 	. 
	nop			;4713	00 	. 
	nop			;4714	00 	. 
	nop			;4715	00 	. 
	nop			;4716	00 	. 
	nop			;4717	00 	. 
	nop			;4718	00 	. 
	nop			;4719	00 	. 
	nop			;471a	00 	. 
	rst 38h			;471b	ff 	. 
	rst 38h			;471c	ff 	. 
	rst 38h			;471d	ff 	. 
	rst 38h			;471e	ff 	. 
l471fh:
	rst 38h			;471f	ff 	. 
	rst 38h			;4720	ff 	. 
	rst 38h			;4721	ff 	. 
	rst 38h			;4722	ff 	. 
	nop			;4723	00 	. 
	nop			;4724	00 	. 
	nop			;4725	00 	. 
	nop			;4726	00 	. 
	nop			;4727	00 	. 
	nop			;4728	00 	. 
	nop			;4729	00 	. 
	nop			;472a	00 	. 
	nop			;472b	00 	. 
	adc a,c			;472c	89 	. 
	ld (l0001h),hl		;472d	22 01 00 	" . . 
	jr nz,l4732h		;4730	20 00 	  . 
l4732h:
	nop			;4732	00 	. 
	add a,b			;4733	80 	. 
	nop			;4734	00 	. 
	nop			;4735	00 	. 
	nop			;4736	00 	. 
	ex af,af'			;4737	08 	. 
	nop			;4738	00 	. 
	add a,b			;4739	80 	. 
	dec bc			;473a	0b 	. 
	ex af,af'			;473b	08 	. 
	jr nc,l477eh		;473c	30 40 	0 @ 
	nop			;473e	00 	. 
	inc h			;473f	24 	$ 
	djnz $+18		;4740	10 10 	. . 
	nop			;4742	00 	. 
	ld c,b			;4743	48 	H 
	ld h,b			;4744	60 	` 
	ld (bc),a			;4745	02 	. 
	nop			;4746	00 	. 
	nop			;4747	00 	. 
	add a,c			;4748	81 	. 
	ld (bc),a			;4749	02 	. 
	nop			;474a	00 	. 
	nop			;474b	00 	. 
	adc a,b			;474c	88 	. 
	nop			;474d	00 	. 
	nop			;474e	00 	. 
	jr z,l4751h		;474f	28 00 	( . 
l4751h:
	ld de,l0008h		;4751	11 08 00 	. . . 
	ex af,af'			;4754	08 	. 
	djnz l4777h		;4755	10 20 	.   
	ld h,h			;4757	64 	d 
	nop			;4758	00 	. 
	ld hl,00200h		;4759	21 00 02 	! . . 
	nop			;475c	00 	. 
	add a,h			;475d	84 	. 
	add a,b			;475e	80 	. 
	jr nz,l4775h		;475f	20 14 	  . 
	jr nz,l4763h		;4761	20 00 	  . 
l4763h:
	add a,b			;4763	80 	. 
	nop			;4764	00 	. 
l4765h:
	jr nz,l476ch		;4765	20 05 	  . 
	nop			;4767	00 	. 
	ld b,d			;4768	42 	B 
	inc h			;4769	24 	$ 
	nop			;476a	00 	. 
	add a,b			;476b	80 	. 
l476ch:
	inc b			;476c	04 	. 
	ld b,(hl)			;476d	46 	F 
	add hl,bc			;476e	09 	. 
	nop			;476f	00 	. 
	nop			;4770	00 	. 
	nop			;4771	00 	. 
	inc b			;4772	04 	. 
	ld (bc),a			;4773	02 	. 
	inc bc			;4774	03 	. 
l4775h:
	ld (bc),a			;4775	02 	. 
	ld b,b			;4776	40 	@ 
l4777h:
	jr nc,l4779h		;4777	30 00 	0 . 
l4779h:
	nop			;4779	00 	. 
	ex af,af'			;477a	08 	. 
	nop			;477b	00 	. 
	ret nz			;477c	c0 	. 
	ld d,b			;477d	50 	P 
l477eh:
	nop			;477e	00 	. 
	nop			;477f	00 	. 
	nop			;4780	00 	. 
	adc a,h			;4781	8c 	. 
	nop			;4782	00 	. 
	inc b			;4783	04 	. 
	nop			;4784	00 	. 
	ld hl,l0004h		;4785	21 04 00 	! . . 
	nop			;4788	00 	. 
	add a,b			;4789	80 	. 
	ld bc,l0210h		;478a	01 10 02 	. . . 
	nop			;478d	00 	. 
	jr nz,l4794h		;478e	20 04 	  . 
	ld b,b			;4790	40 	@ 
	inc b			;4791	04 	. 
	inc b			;4792	04 	. 
	add a,b			;4793	80 	. 
l4794h:
	inc b			;4794	04 	. 
	add a,b			;4795	80 	. 
	ld bc,02220h		;4796	01 20 22 	.   " 
	nop			;4799	00 	. 
	nop			;479a	00 	. 
	inc b			;479b	04 	. 
	nop			;479c	00 	. 
	djnz l471fh		;479d	10 80 	. . 
	ld (00121h),hl		;479f	22 21 01 	" ! . 
	nop			;47a2	00 	. 
	nop			;47a3	00 	. 
	nop			;47a4	00 	. 
	ld bc,l0288h		;47a5	01 88 02 	. . . 
	sub b			;47a8	90 	. 
	jr z,l47abh		;47a9	28 00 	( . 
l47abh:
	nop			;47ab	00 	. 
	ld b,b			;47ac	40 	@ 
	jr nz,l47bfh		;47ad	20 10 	  . 
	adc a,b			;47af	88 	. 
	ex af,af'			;47b0	08 	. 
	add a,b			;47b1	80 	. 
	nop			;47b2	00 	. 
	nop			;47b3	00 	. 
	ld b,b			;47b4	40 	@ 
	nop			;47b5	00 	. 
	inc b			;47b6	04 	. 
	inc b			;47b7	04 	. 
	add a,b			;47b8	80 	. 
	ld (bc),a			;47b9	02 	. 
	rlca			;47ba	07 	. 
	ld b,b			;47bb	40 	@ 
	ex af,af'			;47bc	08 	. 
	add a,b			;47bd	80 	. 
	adc a,b			;47be	88 	. 
l47bfh:
	ld b,b			;47bf	40 	@ 
	ld bc,l0000h		;47c0	01 00 00 	. . . 
	nop			;47c3	00 	. 
	djnz l47d6h		;47c4	10 10 	. . 
	jr nc,l47c8h		;47c6	30 00 	0 . 
l47c8h:
	ld b,h			;47c8	44 	D 
	nop			;47c9	00 	. 
	ld bc,04030h		;47ca	01 30 40 	. 0 @ 
	jr nz,l47efh		;47cd	20 20 	    
	ld b,b			;47cf	40 	@ 
	inc b			;47d0	04 	. 
	jr nz,l47d3h		;47d1	20 00 	  . 
l47d3h:
	and b			;47d3	a0 	. 
	nop			;47d4	00 	. 
	inc b			;47d5	04 	. 
l47d6h:
	djnz l47d8h		;47d6	10 00 	. . 
l47d8h:
	add hl,bc			;47d8	09 	. 
	djnz l47dbh		;47d9	10 00 	. . 
l47dbh:
	nop			;47db	00 	. 
	nop			;47dc	00 	. 
	ret nz			;47dd	c0 	. 
	inc b			;47de	04 	. 
	ld e,h			;47df	5c 	\ 
	ld b,b			;47e0	40 	@ 
	nop			;47e1	00 	. 
	nop			;47e2	00 	. 
	djnz l4765h		;47e3	10 80 	. . 
	djnz l480bh		;47e5	10 24 	. $ 
	ex af,af'			;47e7	08 	. 
	nop			;47e8	00 	. 
	ld (de),a			;47e9	12 	. 
	nop			;47ea	00 	. 
	inc h			;47eb	24 	$ 
	nop			;47ec	00 	. 
	add a,b			;47ed	80 	. 
	ld b,b			;47ee	40 	@ 
l47efh:
	jr nz,l47f1h		;47ef	20 00 	  . 
l47f1h:
	jr nc,l47f4h		;47f1	30 01 	0 . 
	inc b			;47f3	04 	. 
l47f4h:
	ld b,b			;47f4	40 	@ 
	jr z,l47f9h		;47f5	28 02 	( . 
	nop			;47f7	00 	. 
	nop			;47f8	00 	. 
l47f9h:
	ld bc,l0002h		;47f9	01 02 00 	. . . 
	sub b			;47fc	90 	. 
	sub b			;47fd	90 	. 
	nop			;47fe	00 	. 
	ld b,b			;47ff	40 	@ 
	nop			;4800	00 	. 
	jr nc,l4803h		;4801	30 00 	0 . 
l4803h:
	inc e			;4803	1c 	. 
	nop			;4804	00 	. 
	ld b,b			;4805	40 	@ 
	ld d,b			;4806	50 	P 
	ex af,af'			;4807	08 	. 
	ld (bc),a			;4808	02 	. 
	nop			;4809	00 	. 
	nop			;480a	00 	. 
l480bh:
	nop			;480b	00 	. 
	inc b			;480c	04 	. 
	nop			;480d	00 	. 
	djnz l4810h		;480e	10 00 	. . 
l4810h:
	ret z			;4810	c8 	. 
	inc b			;4811	04 	. 
	ld (bc),a			;4812	02 	. 
	add a,b			;4813	80 	. 
	nop			;4814	00 	. 
	ld b,b			;4815	40 	@ 
	ld bc,l1140h		;4816	01 40 11 	. @ . 
	ld (bc),a			;4819	02 	. 
	nop			;481a	00 	. 
	nop			;481b	00 	. 
	inc e			;481c	1c 	. 
	nop			;481d	00 	. 
	ld (bc),a			;481e	02 	. 
	add a,b			;481f	80 	. 
	ld b,b			;4820	40 	@ 
	nop			;4821	00 	. 
	inc b			;4822	04 	. 
	nop			;4823	00 	. 
	nop			;4824	00 	. 
	jr nz,$+50		;4825	20 30 	  0 
	ld de,00808h		;4827	11 08 08 	. . . 
	nop			;482a	00 	. 
	ld c,b			;482b	48 	H 
	and b			;482c	a0 	. 
	nop			;482d	00 	. 
	djnz l4830h		;482e	10 00 	. . 
l4830h:
	nop			;4830	00 	. 
	djnz l4833h		;4831	10 00 	. . 
l4833h:
	jr z,l4835h		;4833	28 00 	( . 
l4835h:
	ld b,044h		;4835	06 44 	. D 
	ld bc,l1000h		;4837	01 00 10 	. . . 
	nop			;483a	00 	. 
	ld a,(bc)			;483b	0a 	. 
	ex af,af'			;483c	08 	. 
	call nz,l0001h		;483d	c4 01 00 	. . . 
	djnz l4842h		;4840	10 00 	. . 
l4842h:
	nop			;4842	00 	. 
	ld h,b			;4843	60 	` 
	nop			;4844	00 	. 
	ld hl,l2000h		;4845	21 00 20 	! .   
	nop			;4848	00 	. 
	ld bc,00409h		;4849	01 09 04 	. . . 
	ld b,c			;484c	41 	A 
	inc c			;484d	0c 	. 
	ld a,(bc)			;484e	0a 	. 
	nop			;484f	00 	. 
	nop			;4850	00 	. 
	ex af,af'			;4851	08 	. 
	nop			;4852	00 	. 
	nop			;4853	00 	. 
	inc b			;4854	04 	. 
	ld de,08200h		;4855	11 00 82 	. . . 
	inc d			;4858	14 	. 
	nop			;4859	00 	. 
	inc b			;485a	04 	. 
	nop			;485b	00 	. 
	ld (bc),a			;485c	02 	. 
	ex af,af'			;485d	08 	. 
	ld c,b			;485e	48 	H 
	nop			;485f	00 	. 
	ld b,b			;4860	40 	@ 
	nop			;4861	00 	. 
	ld bc,l0004h		;4862	01 04 00 	. . . 
	dec b			;4865	05 	. 
	jr nz,l48ach		;4866	20 44 	  D 
	inc b			;4868	04 	. 
	nop			;4869	00 	. 
	ex af,af'			;486a	08 	. 
	ld b,b			;486b	40 	@ 
	ret nz			;486c	c0 	. 
	jr nc,l4873h		;486d	30 04 	0 . 
	nop			;486f	00 	. 
	ld (bc),a			;4870	02 	. 
	nop			;4871	00 	. 
	nop			;4872	00 	. 
l4873h:
	ex af,af'			;4873	08 	. 
	nop			;4874	00 	. 
	ex af,af'			;4875	08 	. 
	ex af,af'			;4876	08 	. 
	ld b,d			;4877	42 	B 
	nop			;4878	00 	. 
	djnz l487bh		;4879	10 00 	. . 
l487bh:
	nop			;487b	00 	. 
	nop			;487c	00 	. 
	inc d			;487d	14 	. 
	ld h,d			;487e	62 	b 
	nop			;487f	00 	. 
	nop			;4880	00 	. 
	sbc a,b			;4881	98 	. 
	nop			;4882	00 	. 
	inc b			;4883	04 	. 
	nop			;4884	00 	. 
	nop			;4885	00 	. 
	ld bc,l0060h		;4886	01 60 00 	. ` . 
	add a,b			;4889	80 	. 
	ex af,af'			;488a	08 	. 
	nop			;488b	00 	. 
	nop			;488c	00 	. 
	nop			;488d	00 	. 
	nop			;488e	00 	. 
	nop			;488f	00 	. 
	nop			;4890	00 	. 
	nop			;4891	00 	. 
	nop			;4892	00 	. 
	rst 38h			;4893	ff 	. 
	rst 38h			;4894	ff 	. 
	rst 38h			;4895	ff 	. 
	rst 38h			;4896	ff 	. 
	rst 38h			;4897	ff 	. 
	rst 38h			;4898	ff 	. 
	rst 38h			;4899	ff 	. 
	rst 38h			;489a	ff 	. 
	nop			;489b	00 	. 
	nop			;489c	00 	. 
	nop			;489d	00 	. 
	nop			;489e	00 	. 
	nop			;489f	00 	. 
	nop			;48a0	00 	. 
	nop			;48a1	00 	. 
	nop			;48a2	00 	. 
	rst 38h			;48a3	ff 	. 
	rst 38h			;48a4	ff 	. 
	rst 38h			;48a5	ff 	. 
	rst 38h			;48a6	ff 	. 
	rst 38h			;48a7	ff 	. 
	rst 38h			;48a8	ff 	. 
	rst 38h			;48a9	ff 	. 
	rst 38h			;48aa	ff 	. 
	nop			;48ab	00 	. 
l48ach:
	nop			;48ac	00 	. 
	nop			;48ad	00 	. 
	nop			;48ae	00 	. 
	nop			;48af	00 	. 
	nop			;48b0	00 	. 
	nop			;48b1	00 	. 
	nop			;48b2	00 	. 
	rst 38h			;48b3	ff 	. 
	rst 38h			;48b4	ff 	. 
	rst 38h			;48b5	ff 	. 
	rst 38h			;48b6	ff 	. 
	rst 38h			;48b7	ff 	. 
	rst 38h			;48b8	ff 	. 
	rst 38h			;48b9	ff 	. 
	rst 38h			;48ba	ff 	. 
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
	rst 38h			;48cb	ff 	. 
	rst 38h			;48cc	ff 	. 
	rst 38h			;48cd	ff 	. 
	rst 38h			;48ce	ff 	. 
	rst 38h			;48cf	ff 	. 
	rst 38h			;48d0	ff 	. 
	rst 38h			;48d1	ff 	. 
	rst 38h			;48d2	ff 	. 
	rst 38h			;48d3	ff 	. 
	rst 38h			;48d4	ff 	. 
	rst 38h			;48d5	ff 	. 
	rst 38h			;48d6	ff 	. 
	rst 38h			;48d7	ff 	. 
	rst 38h			;48d8	ff 	. 
	rst 38h			;48d9	ff 	. 
	rst 38h			;48da	ff 	. 
	rst 38h			;48db	ff 	. 
	rst 38h			;48dc	ff 	. 
	rst 38h			;48dd	ff 	. 
	rst 38h			;48de	ff 	. 
	rst 38h			;48df	ff 	. 
	rst 38h			;48e0	ff 	. 
	rst 38h			;48e1	ff 	. 
	rst 38h			;48e2	ff 	. 
	rst 38h			;48e3	ff 	. 
	rst 38h			;48e4	ff 	. 
	rst 38h			;48e5	ff 	. 
	rst 38h			;48e6	ff 	. 
	rst 38h			;48e7	ff 	. 
	rst 38h			;48e8	ff 	. 
	rst 38h			;48e9	ff 	. 
	rst 38h			;48ea	ff 	. 
	rst 38h			;48eb	ff 	. 
	rst 38h			;48ec	ff 	. 
	rst 38h			;48ed	ff 	. 
	rst 38h			;48ee	ff 	. 
	rst 38h			;48ef	ff 	. 
	rst 38h			;48f0	ff 	. 
	rst 38h			;48f1	ff 	. 
	rst 38h			;48f2	ff 	. 
	rst 38h			;48f3	ff 	. 
	rst 38h			;48f4	ff 	. 
	rst 38h			;48f5	ff 	. 
	rst 38h			;48f6	ff 	. 
	rst 38h			;48f7	ff 	. 
	rst 38h			;48f8	ff 	. 
	rst 38h			;48f9	ff 	. 
	rst 38h			;48fa	ff 	. 
	rst 38h			;48fb	ff 	. 
	rst 38h			;48fc	ff 	. 
	rst 38h			;48fd	ff 	. 
	rst 38h			;48fe	ff 	. 
	rst 38h			;48ff	ff 	. 
	rst 38h			;4900	ff 	. 
	rst 38h			;4901	ff 	. 
	rst 38h			;4902	ff 	. 
	rst 38h			;4903	ff 	. 
	rst 38h			;4904	ff 	. 
	rst 38h			;4905	ff 	. 
	rst 38h			;4906	ff 	. 
	rst 38h			;4907	ff 	. 
	rst 38h			;4908	ff 	. 
	rst 38h			;4909	ff 	. 
	rst 38h			;490a	ff 	. 
	rst 38h			;490b	ff 	. 
	rst 38h			;490c	ff 	. 
	rst 38h			;490d	ff 	. 
	rst 38h			;490e	ff 	. 
	rst 38h			;490f	ff 	. 
	rst 38h			;4910	ff 	. 
	rst 38h			;4911	ff 	. 
	rst 38h			;4912	ff 	. 
	rst 38h			;4913	ff 	. 
	rst 38h			;4914	ff 	. 
	rst 38h			;4915	ff 	. 
	rst 38h			;4916	ff 	. 
	rst 38h			;4917	ff 	. 
	rst 38h			;4918	ff 	. 
	rst 38h			;4919	ff 	. 
	rst 38h			;491a	ff 	. 
	rst 38h			;491b	ff 	. 
	rst 38h			;491c	ff 	. 
	rst 38h			;491d	ff 	. 
	rst 38h			;491e	ff 	. 
	rst 38h			;491f	ff 	. 
	rst 38h			;4920	ff 	. 
	rst 38h			;4921	ff 	. 
	rst 38h			;4922	ff 	. 
	rst 38h			;4923	ff 	. 
	rst 38h			;4924	ff 	. 
	rst 38h			;4925	ff 	. 
	rst 38h			;4926	ff 	. 
	rst 38h			;4927	ff 	. 
	rst 38h			;4928	ff 	. 
	rst 38h			;4929	ff 	. 
	rst 38h			;492a	ff 	. 
	rst 38h			;492b	ff 	. 
	rst 38h			;492c	ff 	. 
	rst 38h			;492d	ff 	. 
	rst 38h			;492e	ff 	. 
	rst 38h			;492f	ff 	. 
	rst 38h			;4930	ff 	. 
	rst 38h			;4931	ff 	. 
	rst 38h			;4932	ff 	. 
	rst 38h			;4933	ff 	. 
	rst 38h			;4934	ff 	. 
	rst 38h			;4935	ff 	. 
	rst 38h			;4936	ff 	. 
	rst 38h			;4937	ff 	. 
	rst 38h			;4938	ff 	. 
	rst 38h			;4939	ff 	. 
	rst 38h			;493a	ff 	. 
	rst 38h			;493b	ff 	. 
	rst 38h			;493c	ff 	. 
	rst 38h			;493d	ff 	. 
	rst 38h			;493e	ff 	. 
	rst 38h			;493f	ff 	. 
	rst 38h			;4940	ff 	. 
	rst 38h			;4941	ff 	. 
	rst 38h			;4942	ff 	. 
	rst 38h			;4943	ff 	. 
	rst 38h			;4944	ff 	. 
	rst 38h			;4945	ff 	. 
	rst 38h			;4946	ff 	. 
	rst 38h			;4947	ff 	. 
	rst 38h			;4948	ff 	. 
	rst 38h			;4949	ff 	. 
	rst 38h			;494a	ff 	. 
	rst 38h			;494b	ff 	. 
	rst 38h			;494c	ff 	. 
	rst 38h			;494d	ff 	. 
	rst 38h			;494e	ff 	. 
	rst 38h			;494f	ff 	. 
	rst 38h			;4950	ff 	. 
	rst 38h			;4951	ff 	. 
	rst 38h			;4952	ff 	. 
	rst 38h			;4953	ff 	. 
	rst 38h			;4954	ff 	. 
	rst 38h			;4955	ff 	. 
	rst 38h			;4956	ff 	. 
	rst 38h			;4957	ff 	. 
	rst 38h			;4958	ff 	. 
	rst 38h			;4959	ff 	. 
	rst 38h			;495a	ff 	. 
	rst 38h			;495b	ff 	. 
	rst 38h			;495c	ff 	. 
	rst 38h			;495d	ff 	. 
	rst 38h			;495e	ff 	. 
	rst 38h			;495f	ff 	. 
	rst 38h			;4960	ff 	. 
	rst 38h			;4961	ff 	. 
	rst 38h			;4962	ff 	. 
	rst 38h			;4963	ff 	. 
	rst 38h			;4964	ff 	. 
	rst 38h			;4965	ff 	. 
	rst 38h			;4966	ff 	. 
	rst 38h			;4967	ff 	. 
	rst 38h			;4968	ff 	. 
	rst 38h			;4969	ff 	. 
	rst 38h			;496a	ff 	. 
	rst 38h			;496b	ff 	. 
	rst 38h			;496c	ff 	. 
	rst 38h			;496d	ff 	. 
	rst 38h			;496e	ff 	. 
	rst 38h			;496f	ff 	. 
	rst 38h			;4970	ff 	. 
	rst 38h			;4971	ff 	. 
	rst 38h			;4972	ff 	. 
	rst 38h			;4973	ff 	. 
	rst 38h			;4974	ff 	. 
	rst 38h			;4975	ff 	. 
	rst 38h			;4976	ff 	. 
	rst 38h			;4977	ff 	. 
	rst 38h			;4978	ff 	. 
	rst 38h			;4979	ff 	. 
	rst 38h			;497a	ff 	. 
	rst 38h			;497b	ff 	. 
	rst 38h			;497c	ff 	. 
	rst 38h			;497d	ff 	. 
	rst 38h			;497e	ff 	. 
	rst 38h			;497f	ff 	. 
	rst 38h			;4980	ff 	. 
	rst 38h			;4981	ff 	. 
	rst 38h			;4982	ff 	. 
	rst 38h			;4983	ff 	. 
	rst 38h			;4984	ff 	. 
	rst 38h			;4985	ff 	. 
	rst 38h			;4986	ff 	. 
	rst 38h			;4987	ff 	. 
	rst 38h			;4988	ff 	. 
	rst 38h			;4989	ff 	. 
	rst 38h			;498a	ff 	. 
	rst 38h			;498b	ff 	. 
	rst 38h			;498c	ff 	. 
	rst 38h			;498d	ff 	. 
	rst 38h			;498e	ff 	. 
	rst 38h			;498f	ff 	. 
	rst 38h			;4990	ff 	. 
	rst 38h			;4991	ff 	. 
	rst 38h			;4992	ff 	. 
	rst 38h			;4993	ff 	. 
	rst 38h			;4994	ff 	. 
	rst 38h			;4995	ff 	. 
	rst 38h			;4996	ff 	. 
	rst 38h			;4997	ff 	. 
	rst 38h			;4998	ff 	. 
	rst 38h			;4999	ff 	. 
	rst 38h			;499a	ff 	. 
	rst 38h			;499b	ff 	. 
	rst 38h			;499c	ff 	. 
	rst 38h			;499d	ff 	. 
	rst 38h			;499e	ff 	. 
	rst 38h			;499f	ff 	. 
	rst 38h			;49a0	ff 	. 
	rst 38h			;49a1	ff 	. 
	rst 38h			;49a2	ff 	. 
	rst 38h			;49a3	ff 	. 
	rst 38h			;49a4	ff 	. 
	rst 38h			;49a5	ff 	. 
	rst 38h			;49a6	ff 	. 
	rst 38h			;49a7	ff 	. 
	rst 38h			;49a8	ff 	. 
	rst 38h			;49a9	ff 	. 
	rst 38h			;49aa	ff 	. 
	rst 38h			;49ab	ff 	. 
	rst 38h			;49ac	ff 	. 
	rst 38h			;49ad	ff 	. 
	rst 38h			;49ae	ff 	. 
	rst 38h			;49af	ff 	. 
	rst 38h			;49b0	ff 	. 
	rst 38h			;49b1	ff 	. 
	rst 38h			;49b2	ff 	. 
	rst 38h			;49b3	ff 	. 
	rst 38h			;49b4	ff 	. 
	rst 38h			;49b5	ff 	. 
	rst 38h			;49b6	ff 	. 
	rst 38h			;49b7	ff 	. 
	rst 38h			;49b8	ff 	. 
	rst 38h			;49b9	ff 	. 
	rst 38h			;49ba	ff 	. 
	rst 38h			;49bb	ff 	. 
	rst 38h			;49bc	ff 	. 
	rst 38h			;49bd	ff 	. 
	rst 38h			;49be	ff 	. 
	rst 38h			;49bf	ff 	. 
	rst 38h			;49c0	ff 	. 
	rst 38h			;49c1	ff 	. 
	rst 38h			;49c2	ff 	. 
	rst 38h			;49c3	ff 	. 
	rst 38h			;49c4	ff 	. 
	rst 38h			;49c5	ff 	. 
	rst 38h			;49c6	ff 	. 
	rst 38h			;49c7	ff 	. 
	rst 38h			;49c8	ff 	. 
	rst 38h			;49c9	ff 	. 
	rst 38h			;49ca	ff 	. 
	rst 38h			;49cb	ff 	. 
	rst 38h			;49cc	ff 	. 
	rst 38h			;49cd	ff 	. 
	rst 38h			;49ce	ff 	. 
	rst 38h			;49cf	ff 	. 
	rst 38h			;49d0	ff 	. 
	rst 38h			;49d1	ff 	. 
	rst 38h			;49d2	ff 	. 
	rst 38h			;49d3	ff 	. 
	rst 38h			;49d4	ff 	. 
	rst 38h			;49d5	ff 	. 
	rst 38h			;49d6	ff 	. 
	rst 38h			;49d7	ff 	. 
	rst 38h			;49d8	ff 	. 
	rst 38h			;49d9	ff 	. 
	rst 38h			;49da	ff 	. 
	rst 38h			;49db	ff 	. 
	rst 38h			;49dc	ff 	. 
	rst 38h			;49dd	ff 	. 
	rst 38h			;49de	ff 	. 
	rst 38h			;49df	ff 	. 
	rst 38h			;49e0	ff 	. 
	rst 38h			;49e1	ff 	. 
	rst 38h			;49e2	ff 	. 
	rst 38h			;49e3	ff 	. 
	rst 38h			;49e4	ff 	. 
	rst 38h			;49e5	ff 	. 
	rst 38h			;49e6	ff 	. 
	rst 38h			;49e7	ff 	. 
	rst 38h			;49e8	ff 	. 
	rst 38h			;49e9	ff 	. 
	rst 38h			;49ea	ff 	. 
	rst 38h			;49eb	ff 	. 
	rst 38h			;49ec	ff 	. 
	rst 38h			;49ed	ff 	. 
	rst 38h			;49ee	ff 	. 
	rst 38h			;49ef	ff 	. 
	rst 38h			;49f0	ff 	. 
	rst 38h			;49f1	ff 	. 
	rst 38h			;49f2	ff 	. 
	rst 38h			;49f3	ff 	. 
	rst 38h			;49f4	ff 	. 
	rst 38h			;49f5	ff 	. 
	rst 38h			;49f6	ff 	. 
	rst 38h			;49f7	ff 	. 
	rst 38h			;49f8	ff 	. 
	rst 38h			;49f9	ff 	. 
	rst 38h			;49fa	ff 	. 
	rst 38h			;49fb	ff 	. 
	rst 38h			;49fc	ff 	. 
	rst 38h			;49fd	ff 	. 
	rst 38h			;49fe	ff 	. 
	rst 38h			;49ff	ff 	. 
	rst 38h			;4a00	ff 	. 
	rst 38h			;4a01	ff 	. 
	rst 38h			;4a02	ff 	. 
	rst 38h			;4a03	ff 	. 
	rst 38h			;4a04	ff 	. 
	rst 38h			;4a05	ff 	. 
	rst 38h			;4a06	ff 	. 
	rst 38h			;4a07	ff 	. 
	rst 38h			;4a08	ff 	. 
	rst 38h			;4a09	ff 	. 
	rst 38h			;4a0a	ff 	. 
	rst 38h			;4a0b	ff 	. 
	rst 38h			;4a0c	ff 	. 
	rst 38h			;4a0d	ff 	. 
	rst 38h			;4a0e	ff 	. 
	rst 38h			;4a0f	ff 	. 
	rst 38h			;4a10	ff 	. 
	rst 38h			;4a11	ff 	. 
	rst 38h			;4a12	ff 	. 
	rst 38h			;4a13	ff 	. 
	rst 38h			;4a14	ff 	. 
	rst 38h			;4a15	ff 	. 
	rst 38h			;4a16	ff 	. 
	rst 38h			;4a17	ff 	. 
	rst 38h			;4a18	ff 	. 
	rst 38h			;4a19	ff 	. 
	rst 38h			;4a1a	ff 	. 
	rst 38h			;4a1b	ff 	. 
	rst 38h			;4a1c	ff 	. 
	rst 38h			;4a1d	ff 	. 
	rst 38h			;4a1e	ff 	. 
	rst 38h			;4a1f	ff 	. 
	rst 38h			;4a20	ff 	. 
	rst 38h			;4a21	ff 	. 
	rst 38h			;4a22	ff 	. 
	rst 38h			;4a23	ff 	. 
	rst 38h			;4a24	ff 	. 
	rst 38h			;4a25	ff 	. 
	rst 38h			;4a26	ff 	. 
	rst 38h			;4a27	ff 	. 
	rst 38h			;4a28	ff 	. 
	rst 38h			;4a29	ff 	. 
	rst 38h			;4a2a	ff 	. 
	rst 38h			;4a2b	ff 	. 
	rst 38h			;4a2c	ff 	. 
	rst 38h			;4a2d	ff 	. 
	rst 38h			;4a2e	ff 	. 
	rst 38h			;4a2f	ff 	. 
	rst 38h			;4a30	ff 	. 
	rst 38h			;4a31	ff 	. 
	rst 38h			;4a32	ff 	. 
	rst 38h			;4a33	ff 	. 
	rst 38h			;4a34	ff 	. 
	rst 38h			;4a35	ff 	. 
	rst 38h			;4a36	ff 	. 
	rst 38h			;4a37	ff 	. 
	rst 38h			;4a38	ff 	. 
	rst 38h			;4a39	ff 	. 
	rst 38h			;4a3a	ff 	. 
	rst 38h			;4a3b	ff 	. 
	rst 38h			;4a3c	ff 	. 
	rst 38h			;4a3d	ff 	. 
	rst 38h			;4a3e	ff 	. 
	rst 38h			;4a3f	ff 	. 
	rst 38h			;4a40	ff 	. 
	rst 38h			;4a41	ff 	. 
	rst 38h			;4a42	ff 	. 
	rst 38h			;4a43	ff 	. 
	rst 38h			;4a44	ff 	. 
	rst 38h			;4a45	ff 	. 
	rst 38h			;4a46	ff 	. 
	rst 38h			;4a47	ff 	. 
	rst 38h			;4a48	ff 	. 
	rst 38h			;4a49	ff 	. 
	rst 38h			;4a4a	ff 	. 
	rst 38h			;4a4b	ff 	. 
	rst 38h			;4a4c	ff 	. 
	rst 38h			;4a4d	ff 	. 
	rst 38h			;4a4e	ff 	. 
	rst 38h			;4a4f	ff 	. 
	rst 38h			;4a50	ff 	. 
	rst 38h			;4a51	ff 	. 
	rst 38h			;4a52	ff 	. 
	rst 38h			;4a53	ff 	. 
	rst 38h			;4a54	ff 	. 
	rst 38h			;4a55	ff 	. 
	rst 38h			;4a56	ff 	. 
	rst 38h			;4a57	ff 	. 
	rst 38h			;4a58	ff 	. 
	rst 38h			;4a59	ff 	. 
	rst 38h			;4a5a	ff 	. 
	rst 38h			;4a5b	ff 	. 
	rst 38h			;4a5c	ff 	. 
	rst 38h			;4a5d	ff 	. 
	rst 38h			;4a5e	ff 	. 
	rst 38h			;4a5f	ff 	. 
	rst 38h			;4a60	ff 	. 
	rst 38h			;4a61	ff 	. 
	rst 38h			;4a62	ff 	. 
	rst 38h			;4a63	ff 	. 
	rst 38h			;4a64	ff 	. 
	rst 38h			;4a65	ff 	. 
	rst 38h			;4a66	ff 	. 
	rst 38h			;4a67	ff 	. 
	rst 38h			;4a68	ff 	. 
	rst 38h			;4a69	ff 	. 
	rst 38h			;4a6a	ff 	. 
	rst 38h			;4a6b	ff 	. 
	rst 38h			;4a6c	ff 	. 
	rst 38h			;4a6d	ff 	. 
	rst 38h			;4a6e	ff 	. 
	rst 38h			;4a6f	ff 	. 
	rst 38h			;4a70	ff 	. 
	rst 38h			;4a71	ff 	. 
	rst 38h			;4a72	ff 	. 
	rst 38h			;4a73	ff 	. 
	rst 38h			;4a74	ff 	. 
	rst 38h			;4a75	ff 	. 
	rst 38h			;4a76	ff 	. 
	rst 38h			;4a77	ff 	. 
	rst 38h			;4a78	ff 	. 
	rst 38h			;4a79	ff 	. 
	rst 38h			;4a7a	ff 	. 
	rst 38h			;4a7b	ff 	. 
	rst 38h			;4a7c	ff 	. 
	rst 38h			;4a7d	ff 	. 
	rst 38h			;4a7e	ff 	. 
	rst 38h			;4a7f	ff 	. 
	rst 38h			;4a80	ff 	. 
	rst 38h			;4a81	ff 	. 
	rst 38h			;4a82	ff 	. 
	rst 38h			;4a83	ff 	. 
	rst 38h			;4a84	ff 	. 
	rst 38h			;4a85	ff 	. 
	rst 38h			;4a86	ff 	. 
	rst 38h			;4a87	ff 	. 
	rst 38h			;4a88	ff 	. 
	rst 38h			;4a89	ff 	. 
	rst 38h			;4a8a	ff 	. 
	rst 38h			;4a8b	ff 	. 
	rst 38h			;4a8c	ff 	. 
	rst 38h			;4a8d	ff 	. 
	rst 38h			;4a8e	ff 	. 
	rst 38h			;4a8f	ff 	. 
	rst 38h			;4a90	ff 	. 
	rst 38h			;4a91	ff 	. 
	rst 38h			;4a92	ff 	. 
	rst 38h			;4a93	ff 	. 
	rst 38h			;4a94	ff 	. 
	rst 38h			;4a95	ff 	. 
	rst 38h			;4a96	ff 	. 
	rst 38h			;4a97	ff 	. 
	rst 38h			;4a98	ff 	. 
	rst 38h			;4a99	ff 	. 
	rst 38h			;4a9a	ff 	. 
	rst 38h			;4a9b	ff 	. 
	rst 38h			;4a9c	ff 	. 
	rst 38h			;4a9d	ff 	. 
	rst 38h			;4a9e	ff 	. 
	rst 38h			;4a9f	ff 	. 
	rst 38h			;4aa0	ff 	. 
	rst 38h			;4aa1	ff 	. 
	rst 38h			;4aa2	ff 	. 
	rst 38h			;4aa3	ff 	. 
	rst 38h			;4aa4	ff 	. 
	rst 38h			;4aa5	ff 	. 
	rst 38h			;4aa6	ff 	. 
	rst 38h			;4aa7	ff 	. 
	rst 38h			;4aa8	ff 	. 
	rst 38h			;4aa9	ff 	. 
	rst 38h			;4aaa	ff 	. 
	rst 38h			;4aab	ff 	. 
	rst 38h			;4aac	ff 	. 
	rst 38h			;4aad	ff 	. 
	rst 38h			;4aae	ff 	. 
	rst 38h			;4aaf	ff 	. 
	rst 38h			;4ab0	ff 	. 
	rst 38h			;4ab1	ff 	. 
	rst 38h			;4ab2	ff 	. 
	rst 38h			;4ab3	ff 	. 
	rst 38h			;4ab4	ff 	. 
	rst 38h			;4ab5	ff 	. 
	rst 38h			;4ab6	ff 	. 
	rst 38h			;4ab7	ff 	. 
	rst 38h			;4ab8	ff 	. 
	rst 38h			;4ab9	ff 	. 
	rst 38h			;4aba	ff 	. 
	rst 38h			;4abb	ff 	. 
	rst 38h			;4abc	ff 	. 
	rst 38h			;4abd	ff 	. 
	rst 38h			;4abe	ff 	. 
	rst 38h			;4abf	ff 	. 
	rst 38h			;4ac0	ff 	. 
	rst 38h			;4ac1	ff 	. 
	rst 38h			;4ac2	ff 	. 
	rst 38h			;4ac3	ff 	. 
	rst 38h			;4ac4	ff 	. 
	rst 38h			;4ac5	ff 	. 
	rst 38h			;4ac6	ff 	. 
	rst 38h			;4ac7	ff 	. 
	rst 38h			;4ac8	ff 	. 
	rst 38h			;4ac9	ff 	. 
	rst 38h			;4aca	ff 	. 
	rst 38h			;4acb	ff 	. 
	rst 38h			;4acc	ff 	. 
	rst 38h			;4acd	ff 	. 
	rst 38h			;4ace	ff 	. 
	rst 38h			;4acf	ff 	. 
	rst 38h			;4ad0	ff 	. 
	rst 38h			;4ad1	ff 	. 
	rst 38h			;4ad2	ff 	. 
	rst 38h			;4ad3	ff 	. 
	rst 38h			;4ad4	ff 	. 
	rst 38h			;4ad5	ff 	. 
	rst 38h			;4ad6	ff 	. 
	rst 38h			;4ad7	ff 	. 
	rst 38h			;4ad8	ff 	. 
	rst 38h			;4ad9	ff 	. 
	rst 38h			;4ada	ff 	. 
	rst 38h			;4adb	ff 	. 
	rst 38h			;4adc	ff 	. 
	rst 38h			;4add	ff 	. 
	rst 38h			;4ade	ff 	. 
	rst 38h			;4adf	ff 	. 
	rst 38h			;4ae0	ff 	. 
	rst 38h			;4ae1	ff 	. 
	rst 38h			;4ae2	ff 	. 
	rst 38h			;4ae3	ff 	. 
	rst 38h			;4ae4	ff 	. 
	rst 38h			;4ae5	ff 	. 
	rst 38h			;4ae6	ff 	. 
	rst 38h			;4ae7	ff 	. 
	rst 38h			;4ae8	ff 	. 
	rst 38h			;4ae9	ff 	. 
	rst 38h			;4aea	ff 	. 
	rst 38h			;4aeb	ff 	. 
	rst 38h			;4aec	ff 	. 
	rst 38h			;4aed	ff 	. 
	rst 38h			;4aee	ff 	. 
	rst 38h			;4aef	ff 	. 
	rst 38h			;4af0	ff 	. 
	rst 38h			;4af1	ff 	. 
	rst 38h			;4af2	ff 	. 
	rst 38h			;4af3	ff 	. 
	rst 38h			;4af4	ff 	. 
	rst 38h			;4af5	ff 	. 
	rst 38h			;4af6	ff 	. 
	rst 38h			;4af7	ff 	. 
	rst 38h			;4af8	ff 	. 
	rst 38h			;4af9	ff 	. 
	rst 38h			;4afa	ff 	. 
	rst 38h			;4afb	ff 	. 
	rst 38h			;4afc	ff 	. 
	rst 38h			;4afd	ff 	. 
	rst 38h			;4afe	ff 	. 
	rst 38h			;4aff	ff 	. 
	rst 38h			;4b00	ff 	. 
	rst 38h			;4b01	ff 	. 
	rst 38h			;4b02	ff 	. 
	rst 38h			;4b03	ff 	. 
	rst 38h			;4b04	ff 	. 
	rst 38h			;4b05	ff 	. 
	rst 38h			;4b06	ff 	. 
	rst 38h			;4b07	ff 	. 
	rst 38h			;4b08	ff 	. 
	rst 38h			;4b09	ff 	. 
	rst 38h			;4b0a	ff 	. 
	rst 38h			;4b0b	ff 	. 
	rst 38h			;4b0c	ff 	. 
	rst 38h			;4b0d	ff 	. 
	rst 38h			;4b0e	ff 	. 
	rst 38h			;4b0f	ff 	. 
	rst 38h			;4b10	ff 	. 
	rst 38h			;4b11	ff 	. 
	rst 38h			;4b12	ff 	. 
	rst 38h			;4b13	ff 	. 
	rst 38h			;4b14	ff 	. 
	rst 38h			;4b15	ff 	. 
	rst 38h			;4b16	ff 	. 
	rst 38h			;4b17	ff 	. 
	rst 38h			;4b18	ff 	. 
	rst 38h			;4b19	ff 	. 
	rst 38h			;4b1a	ff 	. 
	rst 38h			;4b1b	ff 	. 
	rst 38h			;4b1c	ff 	. 
	rst 38h			;4b1d	ff 	. 
	rst 38h			;4b1e	ff 	. 
	rst 38h			;4b1f	ff 	. 
	rst 38h			;4b20	ff 	. 
	rst 38h			;4b21	ff 	. 
	rst 38h			;4b22	ff 	. 
	rst 38h			;4b23	ff 	. 
	rst 38h			;4b24	ff 	. 
	rst 38h			;4b25	ff 	. 
	rst 38h			;4b26	ff 	. 
	rst 38h			;4b27	ff 	. 
	rst 38h			;4b28	ff 	. 
	rst 38h			;4b29	ff 	. 
	rst 38h			;4b2a	ff 	. 
	rst 38h			;4b2b	ff 	. 
	rst 38h			;4b2c	ff 	. 
	rst 38h			;4b2d	ff 	. 
	rst 38h			;4b2e	ff 	. 
	rst 38h			;4b2f	ff 	. 
	rst 38h			;4b30	ff 	. 
	rst 38h			;4b31	ff 	. 
	rst 38h			;4b32	ff 	. 
	rst 38h			;4b33	ff 	. 
	rst 38h			;4b34	ff 	. 
	rst 38h			;4b35	ff 	. 
	rst 38h			;4b36	ff 	. 
	rst 38h			;4b37	ff 	. 
	rst 38h			;4b38	ff 	. 
	rst 38h			;4b39	ff 	. 
	rst 38h			;4b3a	ff 	. 
	rst 38h			;4b3b	ff 	. 
	rst 38h			;4b3c	ff 	. 
	rst 38h			;4b3d	ff 	. 
	rst 38h			;4b3e	ff 	. 
	rst 38h			;4b3f	ff 	. 
	rst 38h			;4b40	ff 	. 
	rst 38h			;4b41	ff 	. 
	rst 38h			;4b42	ff 	. 
	rst 38h			;4b43	ff 	. 
	rst 38h			;4b44	ff 	. 
	rst 38h			;4b45	ff 	. 
	rst 38h			;4b46	ff 	. 
	rst 38h			;4b47	ff 	. 
	rst 38h			;4b48	ff 	. 
	rst 38h			;4b49	ff 	. 
	rst 38h			;4b4a	ff 	. 
	rst 38h			;4b4b	ff 	. 
	rst 38h			;4b4c	ff 	. 
	rst 38h			;4b4d	ff 	. 
	rst 38h			;4b4e	ff 	. 
	rst 38h			;4b4f	ff 	. 
	rst 38h			;4b50	ff 	. 
	rst 38h			;4b51	ff 	. 
	rst 38h			;4b52	ff 	. 
	rst 38h			;4b53	ff 	. 
	rst 38h			;4b54	ff 	. 
	rst 38h			;4b55	ff 	. 
	rst 38h			;4b56	ff 	. 
	rst 38h			;4b57	ff 	. 
	rst 38h			;4b58	ff 	. 
	rst 38h			;4b59	ff 	. 
	rst 38h			;4b5a	ff 	. 
	rst 38h			;4b5b	ff 	. 
	rst 38h			;4b5c	ff 	. 
	rst 38h			;4b5d	ff 	. 
	rst 38h			;4b5e	ff 	. 
	rst 38h			;4b5f	ff 	. 
	rst 38h			;4b60	ff 	. 
	rst 38h			;4b61	ff 	. 
	rst 38h			;4b62	ff 	. 
	rst 38h			;4b63	ff 	. 
	rst 38h			;4b64	ff 	. 
	rst 38h			;4b65	ff 	. 
	rst 38h			;4b66	ff 	. 
	rst 38h			;4b67	ff 	. 
	rst 38h			;4b68	ff 	. 
	rst 38h			;4b69	ff 	. 
	rst 38h			;4b6a	ff 	. 
	rst 38h			;4b6b	ff 	. 
	rst 38h			;4b6c	ff 	. 
	rst 38h			;4b6d	ff 	. 
	rst 38h			;4b6e	ff 	. 
	rst 38h			;4b6f	ff 	. 
	rst 38h			;4b70	ff 	. 
	rst 38h			;4b71	ff 	. 
	rst 38h			;4b72	ff 	. 
	rst 38h			;4b73	ff 	. 
	rst 38h			;4b74	ff 	. 
	rst 38h			;4b75	ff 	. 
	rst 38h			;4b76	ff 	. 
	rst 38h			;4b77	ff 	. 
	rst 38h			;4b78	ff 	. 
	rst 38h			;4b79	ff 	. 
	rst 38h			;4b7a	ff 	. 
	rst 38h			;4b7b	ff 	. 
	rst 38h			;4b7c	ff 	. 
	rst 38h			;4b7d	ff 	. 
	rst 38h			;4b7e	ff 	. 
	rst 38h			;4b7f	ff 	. 
	rst 38h			;4b80	ff 	. 
	rst 38h			;4b81	ff 	. 
	rst 38h			;4b82	ff 	. 
	rst 38h			;4b83	ff 	. 
	rst 38h			;4b84	ff 	. 
	rst 38h			;4b85	ff 	. 
	rst 38h			;4b86	ff 	. 
	rst 38h			;4b87	ff 	. 
	rst 38h			;4b88	ff 	. 
	rst 38h			;4b89	ff 	. 
	rst 38h			;4b8a	ff 	. 
	rst 38h			;4b8b	ff 	. 
	rst 38h			;4b8c	ff 	. 
	rst 38h			;4b8d	ff 	. 
	rst 38h			;4b8e	ff 	. 
	rst 38h			;4b8f	ff 	. 
	rst 38h			;4b90	ff 	. 
	rst 38h			;4b91	ff 	. 
	rst 38h			;4b92	ff 	. 
	rst 38h			;4b93	ff 	. 
	rst 38h			;4b94	ff 	. 
	rst 38h			;4b95	ff 	. 
	rst 38h			;4b96	ff 	. 
	rst 38h			;4b97	ff 	. 
	rst 38h			;4b98	ff 	. 
	rst 38h			;4b99	ff 	. 
	rst 38h			;4b9a	ff 	. 
	rst 38h			;4b9b	ff 	. 
	rst 38h			;4b9c	ff 	. 
	rst 38h			;4b9d	ff 	. 
	rst 38h			;4b9e	ff 	. 
	rst 38h			;4b9f	ff 	. 
	rst 38h			;4ba0	ff 	. 
	rst 38h			;4ba1	ff 	. 
	rst 38h			;4ba2	ff 	. 
	rst 38h			;4ba3	ff 	. 
	rst 38h			;4ba4	ff 	. 
	rst 38h			;4ba5	ff 	. 
	rst 38h			;4ba6	ff 	. 
	rst 38h			;4ba7	ff 	. 
	rst 38h			;4ba8	ff 	. 
	rst 38h			;4ba9	ff 	. 
	rst 38h			;4baa	ff 	. 
	rst 38h			;4bab	ff 	. 
	rst 38h			;4bac	ff 	. 
	rst 38h			;4bad	ff 	. 
	rst 38h			;4bae	ff 	. 
	rst 38h			;4baf	ff 	. 
	rst 38h			;4bb0	ff 	. 
	rst 38h			;4bb1	ff 	. 
	rst 38h			;4bb2	ff 	. 
	rst 38h			;4bb3	ff 	. 
	rst 38h			;4bb4	ff 	. 
	rst 38h			;4bb5	ff 	. 
	rst 38h			;4bb6	ff 	. 
	rst 38h			;4bb7	ff 	. 
	rst 38h			;4bb8	ff 	. 
	rst 38h			;4bb9	ff 	. 
	rst 38h			;4bba	ff 	. 
	rst 38h			;4bbb	ff 	. 
	rst 38h			;4bbc	ff 	. 
	rst 38h			;4bbd	ff 	. 
	rst 38h			;4bbe	ff 	. 
	rst 38h			;4bbf	ff 	. 
	rst 38h			;4bc0	ff 	. 
	rst 38h			;4bc1	ff 	. 
	rst 38h			;4bc2	ff 	. 
	rst 38h			;4bc3	ff 	. 
	rst 38h			;4bc4	ff 	. 
	rst 38h			;4bc5	ff 	. 
	rst 38h			;4bc6	ff 	. 
	rst 38h			;4bc7	ff 	. 
	rst 38h			;4bc8	ff 	. 
	rst 38h			;4bc9	ff 	. 
	rst 38h			;4bca	ff 	. 
	rst 38h			;4bcb	ff 	. 
	rst 38h			;4bcc	ff 	. 
	rst 38h			;4bcd	ff 	. 
	rst 38h			;4bce	ff 	. 
	rst 38h			;4bcf	ff 	. 
	rst 38h			;4bd0	ff 	. 
	rst 38h			;4bd1	ff 	. 
	rst 38h			;4bd2	ff 	. 
	rst 38h			;4bd3	ff 	. 
	rst 38h			;4bd4	ff 	. 
	rst 38h			;4bd5	ff 	. 
	rst 38h			;4bd6	ff 	. 
	rst 38h			;4bd7	ff 	. 
	rst 38h			;4bd8	ff 	. 
	rst 38h			;4bd9	ff 	. 
	rst 38h			;4bda	ff 	. 
	rst 38h			;4bdb	ff 	. 
	rst 38h			;4bdc	ff 	. 
	rst 38h			;4bdd	ff 	. 
	rst 38h			;4bde	ff 	. 
	rst 38h			;4bdf	ff 	. 
	rst 38h			;4be0	ff 	. 
	rst 38h			;4be1	ff 	. 
	rst 38h			;4be2	ff 	. 
	rst 38h			;4be3	ff 	. 
	rst 38h			;4be4	ff 	. 
	rst 38h			;4be5	ff 	. 
	rst 38h			;4be6	ff 	. 
	rst 38h			;4be7	ff 	. 
	rst 38h			;4be8	ff 	. 
	rst 38h			;4be9	ff 	. 
	rst 38h			;4bea	ff 	. 
	rst 38h			;4beb	ff 	. 
	rst 38h			;4bec	ff 	. 
	rst 38h			;4bed	ff 	. 
	rst 38h			;4bee	ff 	. 
	rst 38h			;4bef	ff 	. 
	rst 38h			;4bf0	ff 	. 
	rst 38h			;4bf1	ff 	. 
	rst 38h			;4bf2	ff 	. 
	rst 38h			;4bf3	ff 	. 
	rst 38h			;4bf4	ff 	. 
	rst 38h			;4bf5	ff 	. 
	rst 38h			;4bf6	ff 	. 
	rst 38h			;4bf7	ff 	. 
	rst 38h			;4bf8	ff 	. 
	rst 38h			;4bf9	ff 	. 
	rst 38h			;4bfa	ff 	. 
	rst 38h			;4bfb	ff 	. 
	rst 38h			;4bfc	ff 	. 
	rst 38h			;4bfd	ff 	. 
	rst 38h			;4bfe	ff 	. 
	rst 38h			;4bff	ff 	. 
	rst 38h			;4c00	ff 	. 
	rst 38h			;4c01	ff 	. 
	rst 38h			;4c02	ff 	. 
	rst 38h			;4c03	ff 	. 
	rst 38h			;4c04	ff 	. 
	rst 38h			;4c05	ff 	. 
	rst 38h			;4c06	ff 	. 
	rst 38h			;4c07	ff 	. 
	rst 38h			;4c08	ff 	. 
	rst 38h			;4c09	ff 	. 
	rst 38h			;4c0a	ff 	. 
	rst 38h			;4c0b	ff 	. 
	rst 38h			;4c0c	ff 	. 
	rst 38h			;4c0d	ff 	. 
	rst 38h			;4c0e	ff 	. 
	rst 38h			;4c0f	ff 	. 
	rst 38h			;4c10	ff 	. 
	rst 38h			;4c11	ff 	. 
	rst 38h			;4c12	ff 	. 
	rst 38h			;4c13	ff 	. 
	rst 38h			;4c14	ff 	. 
	rst 38h			;4c15	ff 	. 
	rst 38h			;4c16	ff 	. 
	rst 38h			;4c17	ff 	. 
	rst 38h			;4c18	ff 	. 
	rst 38h			;4c19	ff 	. 
	rst 38h			;4c1a	ff 	. 
	rst 38h			;4c1b	ff 	. 
	rst 38h			;4c1c	ff 	. 
	rst 38h			;4c1d	ff 	. 
	rst 38h			;4c1e	ff 	. 
	rst 38h			;4c1f	ff 	. 
	rst 38h			;4c20	ff 	. 
	rst 38h			;4c21	ff 	. 
	rst 38h			;4c22	ff 	. 
	rst 38h			;4c23	ff 	. 
	rst 38h			;4c24	ff 	. 
	rst 38h			;4c25	ff 	. 
	rst 38h			;4c26	ff 	. 
	rst 38h			;4c27	ff 	. 
	rst 38h			;4c28	ff 	. 
	rst 38h			;4c29	ff 	. 
	rst 38h			;4c2a	ff 	. 
	rst 38h			;4c2b	ff 	. 
	rst 38h			;4c2c	ff 	. 
	rst 38h			;4c2d	ff 	. 
	rst 38h			;4c2e	ff 	. 
	rst 38h			;4c2f	ff 	. 
	rst 38h			;4c30	ff 	. 
	rst 38h			;4c31	ff 	. 
	rst 38h			;4c32	ff 	. 
	rst 38h			;4c33	ff 	. 
	rst 38h			;4c34	ff 	. 
	rst 38h			;4c35	ff 	. 
	rst 38h			;4c36	ff 	. 
	rst 38h			;4c37	ff 	. 
	rst 38h			;4c38	ff 	. 
	rst 38h			;4c39	ff 	. 
	rst 38h			;4c3a	ff 	. 
	rst 38h			;4c3b	ff 	. 
	rst 38h			;4c3c	ff 	. 
	rst 38h			;4c3d	ff 	. 
	rst 38h			;4c3e	ff 	. 
	rst 38h			;4c3f	ff 	. 
	rst 38h			;4c40	ff 	. 
	rst 38h			;4c41	ff 	. 
	rst 38h			;4c42	ff 	. 
	rst 38h			;4c43	ff 	. 
	rst 38h			;4c44	ff 	. 
	rst 38h			;4c45	ff 	. 
	rst 38h			;4c46	ff 	. 
	rst 38h			;4c47	ff 	. 
	rst 38h			;4c48	ff 	. 
	rst 38h			;4c49	ff 	. 
	rst 38h			;4c4a	ff 	. 
	rst 38h			;4c4b	ff 	. 
	rst 38h			;4c4c	ff 	. 
	rst 38h			;4c4d	ff 	. 
	rst 38h			;4c4e	ff 	. 
	rst 38h			;4c4f	ff 	. 
	rst 38h			;4c50	ff 	. 
	rst 38h			;4c51	ff 	. 
	rst 38h			;4c52	ff 	. 
	rst 38h			;4c53	ff 	. 
	rst 38h			;4c54	ff 	. 
	rst 38h			;4c55	ff 	. 
	rst 38h			;4c56	ff 	. 
	rst 38h			;4c57	ff 	. 
	rst 38h			;4c58	ff 	. 
	rst 38h			;4c59	ff 	. 
	rst 38h			;4c5a	ff 	. 
	rst 38h			;4c5b	ff 	. 
	rst 38h			;4c5c	ff 	. 
	rst 38h			;4c5d	ff 	. 
	rst 38h			;4c5e	ff 	. 
	rst 38h			;4c5f	ff 	. 
	rst 38h			;4c60	ff 	. 
	rst 38h			;4c61	ff 	. 
	rst 38h			;4c62	ff 	. 
	rst 38h			;4c63	ff 	. 
	rst 38h			;4c64	ff 	. 
	rst 38h			;4c65	ff 	. 
	rst 38h			;4c66	ff 	. 
	rst 38h			;4c67	ff 	. 
	rst 38h			;4c68	ff 	. 
	rst 38h			;4c69	ff 	. 
	rst 38h			;4c6a	ff 	. 
	rst 38h			;4c6b	ff 	. 
	rst 38h			;4c6c	ff 	. 
	rst 38h			;4c6d	ff 	. 
	rst 38h			;4c6e	ff 	. 
	rst 38h			;4c6f	ff 	. 
	rst 38h			;4c70	ff 	. 
	rst 38h			;4c71	ff 	. 
	rst 38h			;4c72	ff 	. 
	rst 38h			;4c73	ff 	. 
	rst 38h			;4c74	ff 	. 
	rst 38h			;4c75	ff 	. 
	rst 38h			;4c76	ff 	. 
	rst 38h			;4c77	ff 	. 
	rst 38h			;4c78	ff 	. 
	rst 38h			;4c79	ff 	. 
	rst 38h			;4c7a	ff 	. 
	rst 38h			;4c7b	ff 	. 
	rst 38h			;4c7c	ff 	. 
	rst 38h			;4c7d	ff 	. 
	rst 38h			;4c7e	ff 	. 
	rst 38h			;4c7f	ff 	. 
	rst 38h			;4c80	ff 	. 
	rst 38h			;4c81	ff 	. 
	rst 38h			;4c82	ff 	. 
	rst 38h			;4c83	ff 	. 
	rst 38h			;4c84	ff 	. 
	rst 38h			;4c85	ff 	. 
	rst 38h			;4c86	ff 	. 
	rst 38h			;4c87	ff 	. 
	rst 38h			;4c88	ff 	. 
	rst 38h			;4c89	ff 	. 
	rst 38h			;4c8a	ff 	. 
	rst 38h			;4c8b	ff 	. 
	rst 38h			;4c8c	ff 	. 
	rst 38h			;4c8d	ff 	. 
	rst 38h			;4c8e	ff 	. 
	rst 38h			;4c8f	ff 	. 
	rst 38h			;4c90	ff 	. 
	rst 38h			;4c91	ff 	. 
	rst 38h			;4c92	ff 	. 
	rst 38h			;4c93	ff 	. 
	rst 38h			;4c94	ff 	. 
	rst 38h			;4c95	ff 	. 
	rst 38h			;4c96	ff 	. 
	rst 38h			;4c97	ff 	. 
	rst 38h			;4c98	ff 	. 
	rst 38h			;4c99	ff 	. 
	rst 38h			;4c9a	ff 	. 
	rst 38h			;4c9b	ff 	. 
	rst 38h			;4c9c	ff 	. 
	rst 38h			;4c9d	ff 	. 
	rst 38h			;4c9e	ff 	. 
	rst 38h			;4c9f	ff 	. 
	rst 38h			;4ca0	ff 	. 
	rst 38h			;4ca1	ff 	. 
	rst 38h			;4ca2	ff 	. 
	rst 38h			;4ca3	ff 	. 
	rst 38h			;4ca4	ff 	. 
	rst 38h			;4ca5	ff 	. 
	rst 38h			;4ca6	ff 	. 
	rst 38h			;4ca7	ff 	. 
	rst 38h			;4ca8	ff 	. 
	rst 38h			;4ca9	ff 	. 
	rst 38h			;4caa	ff 	. 
	rst 38h			;4cab	ff 	. 
	rst 38h			;4cac	ff 	. 
	rst 38h			;4cad	ff 	. 
	rst 38h			;4cae	ff 	. 
	rst 38h			;4caf	ff 	. 
	rst 38h			;4cb0	ff 	. 
	rst 38h			;4cb1	ff 	. 
	rst 38h			;4cb2	ff 	. 
	rst 38h			;4cb3	ff 	. 
	rst 38h			;4cb4	ff 	. 
	rst 38h			;4cb5	ff 	. 
	rst 38h			;4cb6	ff 	. 
	rst 38h			;4cb7	ff 	. 
	rst 38h			;4cb8	ff 	. 
	rst 38h			;4cb9	ff 	. 
	rst 38h			;4cba	ff 	. 
	rst 38h			;4cbb	ff 	. 
	rst 38h			;4cbc	ff 	. 
	rst 38h			;4cbd	ff 	. 
	rst 38h			;4cbe	ff 	. 
	rst 38h			;4cbf	ff 	. 
	rst 38h			;4cc0	ff 	. 
	rst 38h			;4cc1	ff 	. 
	rst 38h			;4cc2	ff 	. 
	rst 38h			;4cc3	ff 	. 
	rst 38h			;4cc4	ff 	. 
	rst 38h			;4cc5	ff 	. 
	rst 38h			;4cc6	ff 	. 
	rst 38h			;4cc7	ff 	. 
	rst 38h			;4cc8	ff 	. 
	rst 38h			;4cc9	ff 	. 
	rst 38h			;4cca	ff 	. 
	rst 38h			;4ccb	ff 	. 
	rst 38h			;4ccc	ff 	. 
	rst 38h			;4ccd	ff 	. 
	rst 38h			;4cce	ff 	. 
	rst 38h			;4ccf	ff 	. 
	rst 38h			;4cd0	ff 	. 
	rst 38h			;4cd1	ff 	. 
	rst 38h			;4cd2	ff 	. 
	rst 38h			;4cd3	ff 	. 
	rst 38h			;4cd4	ff 	. 
	rst 38h			;4cd5	ff 	. 
	rst 38h			;4cd6	ff 	. 
	rst 38h			;4cd7	ff 	. 
	rst 38h			;4cd8	ff 	. 
	rst 38h			;4cd9	ff 	. 
	rst 38h			;4cda	ff 	. 
	rst 38h			;4cdb	ff 	. 
	rst 38h			;4cdc	ff 	. 
	rst 38h			;4cdd	ff 	. 
	rst 38h			;4cde	ff 	. 
	rst 38h			;4cdf	ff 	. 
	rst 38h			;4ce0	ff 	. 
	rst 38h			;4ce1	ff 	. 
	rst 38h			;4ce2	ff 	. 
	rst 38h			;4ce3	ff 	. 
	rst 38h			;4ce4	ff 	. 
	rst 38h			;4ce5	ff 	. 
	rst 38h			;4ce6	ff 	. 
	rst 38h			;4ce7	ff 	. 
	rst 38h			;4ce8	ff 	. 
	rst 38h			;4ce9	ff 	. 
	rst 38h			;4cea	ff 	. 
	rst 38h			;4ceb	ff 	. 
	rst 38h			;4cec	ff 	. 
	rst 38h			;4ced	ff 	. 
	rst 38h			;4cee	ff 	. 
	rst 38h			;4cef	ff 	. 
	rst 38h			;4cf0	ff 	. 
	rst 38h			;4cf1	ff 	. 
	rst 38h			;4cf2	ff 	. 
	rst 38h			;4cf3	ff 	. 
	rst 38h			;4cf4	ff 	. 
	rst 38h			;4cf5	ff 	. 
	rst 38h			;4cf6	ff 	. 
	rst 38h			;4cf7	ff 	. 
	rst 38h			;4cf8	ff 	. 
	rst 38h			;4cf9	ff 	. 
	rst 38h			;4cfa	ff 	. 
	rst 38h			;4cfb	ff 	. 
	rst 38h			;4cfc	ff 	. 
	rst 38h			;4cfd	ff 	. 
	rst 38h			;4cfe	ff 	. 
	rst 38h			;4cff	ff 	. 
	rst 38h			;4d00	ff 	. 
	rst 38h			;4d01	ff 	. 
	rst 38h			;4d02	ff 	. 
	rst 38h			;4d03	ff 	. 
	rst 38h			;4d04	ff 	. 
	rst 38h			;4d05	ff 	. 
	rst 38h			;4d06	ff 	. 
	rst 38h			;4d07	ff 	. 
	rst 38h			;4d08	ff 	. 
	rst 38h			;4d09	ff 	. 
	rst 38h			;4d0a	ff 	. 
	rst 38h			;4d0b	ff 	. 
	rst 38h			;4d0c	ff 	. 
	rst 38h			;4d0d	ff 	. 
	rst 38h			;4d0e	ff 	. 
	rst 38h			;4d0f	ff 	. 
	rst 38h			;4d10	ff 	. 
	rst 38h			;4d11	ff 	. 
	rst 38h			;4d12	ff 	. 
	rst 38h			;4d13	ff 	. 
	rst 38h			;4d14	ff 	. 
	rst 38h			;4d15	ff 	. 
	rst 38h			;4d16	ff 	. 
	rst 38h			;4d17	ff 	. 
	rst 38h			;4d18	ff 	. 
	rst 38h			;4d19	ff 	. 
	rst 38h			;4d1a	ff 	. 
	rst 38h			;4d1b	ff 	. 
	rst 38h			;4d1c	ff 	. 
	rst 38h			;4d1d	ff 	. 
	rst 38h			;4d1e	ff 	. 
	rst 38h			;4d1f	ff 	. 
	rst 38h			;4d20	ff 	. 
	rst 38h			;4d21	ff 	. 
	rst 38h			;4d22	ff 	. 
	rst 38h			;4d23	ff 	. 
	rst 38h			;4d24	ff 	. 
	rst 38h			;4d25	ff 	. 
	rst 38h			;4d26	ff 	. 
	rst 38h			;4d27	ff 	. 
	rst 38h			;4d28	ff 	. 
	rst 38h			;4d29	ff 	. 
	rst 38h			;4d2a	ff 	. 
	rst 38h			;4d2b	ff 	. 
	rst 38h			;4d2c	ff 	. 
	rst 38h			;4d2d	ff 	. 
	rst 38h			;4d2e	ff 	. 
	rst 38h			;4d2f	ff 	. 
	rst 38h			;4d30	ff 	. 
	rst 38h			;4d31	ff 	. 
	rst 38h			;4d32	ff 	. 
	rst 38h			;4d33	ff 	. 
	rst 38h			;4d34	ff 	. 
	rst 38h			;4d35	ff 	. 
	rst 38h			;4d36	ff 	. 
	rst 38h			;4d37	ff 	. 
	rst 38h			;4d38	ff 	. 
	rst 38h			;4d39	ff 	. 
	rst 38h			;4d3a	ff 	. 
	rst 38h			;4d3b	ff 	. 
	rst 38h			;4d3c	ff 	. 
	rst 38h			;4d3d	ff 	. 
	rst 38h			;4d3e	ff 	. 
	rst 38h			;4d3f	ff 	. 
	rst 38h			;4d40	ff 	. 
	rst 38h			;4d41	ff 	. 
	rst 38h			;4d42	ff 	. 
	rst 38h			;4d43	ff 	. 
	rst 38h			;4d44	ff 	. 
	rst 38h			;4d45	ff 	. 
	rst 38h			;4d46	ff 	. 
	rst 38h			;4d47	ff 	. 
	rst 38h			;4d48	ff 	. 
	rst 38h			;4d49	ff 	. 
	rst 38h			;4d4a	ff 	. 
	rst 38h			;4d4b	ff 	. 
	rst 38h			;4d4c	ff 	. 
	rst 38h			;4d4d	ff 	. 
	rst 38h			;4d4e	ff 	. 
	rst 38h			;4d4f	ff 	. 
	rst 38h			;4d50	ff 	. 
	rst 38h			;4d51	ff 	. 
	rst 38h			;4d52	ff 	. 
	rst 38h			;4d53	ff 	. 
	rst 38h			;4d54	ff 	. 
	rst 38h			;4d55	ff 	. 
	rst 38h			;4d56	ff 	. 
	rst 38h			;4d57	ff 	. 
	rst 38h			;4d58	ff 	. 
	rst 38h			;4d59	ff 	. 
	rst 38h			;4d5a	ff 	. 
	rst 38h			;4d5b	ff 	. 
	rst 38h			;4d5c	ff 	. 
	rst 38h			;4d5d	ff 	. 
	rst 38h			;4d5e	ff 	. 
	rst 38h			;4d5f	ff 	. 
	rst 38h			;4d60	ff 	. 
	rst 38h			;4d61	ff 	. 
	rst 38h			;4d62	ff 	. 
	rst 38h			;4d63	ff 	. 
	rst 38h			;4d64	ff 	. 
	rst 38h			;4d65	ff 	. 
	rst 38h			;4d66	ff 	. 
	rst 38h			;4d67	ff 	. 
	rst 38h			;4d68	ff 	. 
	rst 38h			;4d69	ff 	. 
	rst 38h			;4d6a	ff 	. 
	rst 38h			;4d6b	ff 	. 
	rst 38h			;4d6c	ff 	. 
	rst 38h			;4d6d	ff 	. 
	rst 38h			;4d6e	ff 	. 
	rst 38h			;4d6f	ff 	. 
	rst 38h			;4d70	ff 	. 
	rst 38h			;4d71	ff 	. 
	rst 38h			;4d72	ff 	. 
	rst 38h			;4d73	ff 	. 
	rst 38h			;4d74	ff 	. 
	rst 38h			;4d75	ff 	. 
	rst 38h			;4d76	ff 	. 
	rst 38h			;4d77	ff 	. 
	rst 38h			;4d78	ff 	. 
	rst 38h			;4d79	ff 	. 
	rst 38h			;4d7a	ff 	. 
	rst 38h			;4d7b	ff 	. 
	rst 38h			;4d7c	ff 	. 
	rst 38h			;4d7d	ff 	. 
	rst 38h			;4d7e	ff 	. 
	rst 38h			;4d7f	ff 	. 
	rst 38h			;4d80	ff 	. 
	rst 38h			;4d81	ff 	. 
	rst 38h			;4d82	ff 	. 
	rst 38h			;4d83	ff 	. 
	rst 38h			;4d84	ff 	. 
	rst 38h			;4d85	ff 	. 
	rst 38h			;4d86	ff 	. 
	rst 38h			;4d87	ff 	. 
	rst 38h			;4d88	ff 	. 
	rst 38h			;4d89	ff 	. 
	rst 38h			;4d8a	ff 	. 
	rst 38h			;4d8b	ff 	. 
	rst 38h			;4d8c	ff 	. 
	rst 38h			;4d8d	ff 	. 
	rst 38h			;4d8e	ff 	. 
	rst 38h			;4d8f	ff 	. 
	rst 38h			;4d90	ff 	. 
	rst 38h			;4d91	ff 	. 
	rst 38h			;4d92	ff 	. 
	rst 38h			;4d93	ff 	. 
	rst 38h			;4d94	ff 	. 
	rst 38h			;4d95	ff 	. 
	rst 38h			;4d96	ff 	. 
	rst 38h			;4d97	ff 	. 
	rst 38h			;4d98	ff 	. 
	rst 38h			;4d99	ff 	. 
	rst 38h			;4d9a	ff 	. 
	rst 38h			;4d9b	ff 	. 
	rst 38h			;4d9c	ff 	. 
	rst 38h			;4d9d	ff 	. 
	rst 38h			;4d9e	ff 	. 
	rst 38h			;4d9f	ff 	. 
	rst 38h			;4da0	ff 	. 
	rst 38h			;4da1	ff 	. 
	rst 38h			;4da2	ff 	. 
	rst 38h			;4da3	ff 	. 
	rst 38h			;4da4	ff 	. 
	rst 38h			;4da5	ff 	. 
	rst 38h			;4da6	ff 	. 
	rst 38h			;4da7	ff 	. 
	rst 38h			;4da8	ff 	. 
	rst 38h			;4da9	ff 	. 
	rst 38h			;4daa	ff 	. 
	rst 38h			;4dab	ff 	. 
	rst 38h			;4dac	ff 	. 
	rst 38h			;4dad	ff 	. 
	rst 38h			;4dae	ff 	. 
	rst 38h			;4daf	ff 	. 
	rst 38h			;4db0	ff 	. 
	rst 38h			;4db1	ff 	. 
	rst 38h			;4db2	ff 	. 
	rst 38h			;4db3	ff 	. 
	rst 38h			;4db4	ff 	. 
	rst 38h			;4db5	ff 	. 
	rst 38h			;4db6	ff 	. 
	rst 38h			;4db7	ff 	. 
	rst 38h			;4db8	ff 	. 
	rst 38h			;4db9	ff 	. 
	rst 38h			;4dba	ff 	. 
	rst 38h			;4dbb	ff 	. 
	rst 38h			;4dbc	ff 	. 
	rst 38h			;4dbd	ff 	. 
	rst 38h			;4dbe	ff 	. 
	rst 38h			;4dbf	ff 	. 
	rst 38h			;4dc0	ff 	. 
	rst 38h			;4dc1	ff 	. 
	rst 38h			;4dc2	ff 	. 
	rst 38h			;4dc3	ff 	. 
	rst 38h			;4dc4	ff 	. 
	rst 38h			;4dc5	ff 	. 
	rst 38h			;4dc6	ff 	. 
	rst 38h			;4dc7	ff 	. 
	rst 38h			;4dc8	ff 	. 
	rst 38h			;4dc9	ff 	. 
	rst 38h			;4dca	ff 	. 
	rst 38h			;4dcb	ff 	. 
	rst 38h			;4dcc	ff 	. 
	rst 38h			;4dcd	ff 	. 
	rst 38h			;4dce	ff 	. 
	rst 38h			;4dcf	ff 	. 
	rst 38h			;4dd0	ff 	. 
	rst 38h			;4dd1	ff 	. 
	rst 38h			;4dd2	ff 	. 
	rst 38h			;4dd3	ff 	. 
	rst 38h			;4dd4	ff 	. 
	rst 38h			;4dd5	ff 	. 
	rst 38h			;4dd6	ff 	. 
	rst 38h			;4dd7	ff 	. 
	rst 38h			;4dd8	ff 	. 
	rst 38h			;4dd9	ff 	. 
	rst 38h			;4dda	ff 	. 
	rst 38h			;4ddb	ff 	. 
	rst 38h			;4ddc	ff 	. 
	rst 38h			;4ddd	ff 	. 
	rst 38h			;4dde	ff 	. 
	rst 38h			;4ddf	ff 	. 
	rst 38h			;4de0	ff 	. 
	rst 38h			;4de1	ff 	. 
	rst 38h			;4de2	ff 	. 
	rst 38h			;4de3	ff 	. 
	rst 38h			;4de4	ff 	. 
	rst 38h			;4de5	ff 	. 
	rst 38h			;4de6	ff 	. 
	rst 38h			;4de7	ff 	. 
	rst 38h			;4de8	ff 	. 
	rst 38h			;4de9	ff 	. 
	rst 38h			;4dea	ff 	. 
	rst 38h			;4deb	ff 	. 
	rst 38h			;4dec	ff 	. 
	rst 38h			;4ded	ff 	. 
	rst 38h			;4dee	ff 	. 
	rst 38h			;4def	ff 	. 
	rst 38h			;4df0	ff 	. 
	rst 38h			;4df1	ff 	. 
	rst 38h			;4df2	ff 	. 
	rst 38h			;4df3	ff 	. 
	rst 38h			;4df4	ff 	. 
	rst 38h			;4df5	ff 	. 
	rst 38h			;4df6	ff 	. 
	rst 38h			;4df7	ff 	. 
	rst 38h			;4df8	ff 	. 
	rst 38h			;4df9	ff 	. 
	rst 38h			;4dfa	ff 	. 
	rst 38h			;4dfb	ff 	. 
	rst 38h			;4dfc	ff 	. 
	rst 38h			;4dfd	ff 	. 
	rst 38h			;4dfe	ff 	. 
	rst 38h			;4dff	ff 	. 
	rst 38h			;4e00	ff 	. 
	rst 38h			;4e01	ff 	. 
	rst 38h			;4e02	ff 	. 
	rst 38h			;4e03	ff 	. 
	rst 38h			;4e04	ff 	. 
	rst 38h			;4e05	ff 	. 
	rst 38h			;4e06	ff 	. 
	rst 38h			;4e07	ff 	. 
	rst 38h			;4e08	ff 	. 
	rst 38h			;4e09	ff 	. 
	rst 38h			;4e0a	ff 	. 
	rst 38h			;4e0b	ff 	. 
	rst 38h			;4e0c	ff 	. 
	rst 38h			;4e0d	ff 	. 
	rst 38h			;4e0e	ff 	. 
	rst 38h			;4e0f	ff 	. 
	rst 38h			;4e10	ff 	. 
	rst 38h			;4e11	ff 	. 
	rst 38h			;4e12	ff 	. 
	rst 38h			;4e13	ff 	. 
	rst 38h			;4e14	ff 	. 
	rst 38h			;4e15	ff 	. 
	rst 38h			;4e16	ff 	. 
	rst 38h			;4e17	ff 	. 
	rst 38h			;4e18	ff 	. 
	rst 38h			;4e19	ff 	. 
	rst 38h			;4e1a	ff 	. 
	rst 38h			;4e1b	ff 	. 
	rst 38h			;4e1c	ff 	. 
	rst 38h			;4e1d	ff 	. 
	rst 38h			;4e1e	ff 	. 
	rst 38h			;4e1f	ff 	. 
	rst 38h			;4e20	ff 	. 
	rst 38h			;4e21	ff 	. 
	rst 38h			;4e22	ff 	. 
	rst 38h			;4e23	ff 	. 
	rst 38h			;4e24	ff 	. 
	rst 38h			;4e25	ff 	. 
	rst 38h			;4e26	ff 	. 
	rst 38h			;4e27	ff 	. 
	rst 38h			;4e28	ff 	. 
	rst 38h			;4e29	ff 	. 
	rst 38h			;4e2a	ff 	. 
	rst 38h			;4e2b	ff 	. 
	rst 38h			;4e2c	ff 	. 
	rst 38h			;4e2d	ff 	. 
	rst 38h			;4e2e	ff 	. 
	rst 38h			;4e2f	ff 	. 
	rst 38h			;4e30	ff 	. 
	rst 38h			;4e31	ff 	. 
	rst 38h			;4e32	ff 	. 
	rst 38h			;4e33	ff 	. 
	rst 38h			;4e34	ff 	. 
	rst 38h			;4e35	ff 	. 
	rst 38h			;4e36	ff 	. 
	rst 38h			;4e37	ff 	. 
	rst 38h			;4e38	ff 	. 
	rst 38h			;4e39	ff 	. 
	rst 38h			;4e3a	ff 	. 
	rst 38h			;4e3b	ff 	. 
	rst 38h			;4e3c	ff 	. 
	rst 38h			;4e3d	ff 	. 
	rst 38h			;4e3e	ff 	. 
	rst 38h			;4e3f	ff 	. 
	rst 38h			;4e40	ff 	. 
	rst 38h			;4e41	ff 	. 
	rst 38h			;4e42	ff 	. 
	rst 38h			;4e43	ff 	. 
	rst 38h			;4e44	ff 	. 
	rst 38h			;4e45	ff 	. 
	rst 38h			;4e46	ff 	. 
	rst 38h			;4e47	ff 	. 
	rst 38h			;4e48	ff 	. 
	rst 38h			;4e49	ff 	. 
	rst 38h			;4e4a	ff 	. 
	rst 38h			;4e4b	ff 	. 
	rst 38h			;4e4c	ff 	. 
	rst 38h			;4e4d	ff 	. 
	rst 38h			;4e4e	ff 	. 
	rst 38h			;4e4f	ff 	. 
	rst 38h			;4e50	ff 	. 
	rst 38h			;4e51	ff 	. 
	rst 38h			;4e52	ff 	. 
	rst 38h			;4e53	ff 	. 
	rst 38h			;4e54	ff 	. 
	rst 38h			;4e55	ff 	. 
	rst 38h			;4e56	ff 	. 
	rst 38h			;4e57	ff 	. 
	rst 38h			;4e58	ff 	. 
	rst 38h			;4e59	ff 	. 
	rst 38h			;4e5a	ff 	. 
	rst 38h			;4e5b	ff 	. 
	rst 38h			;4e5c	ff 	. 
	rst 38h			;4e5d	ff 	. 
	rst 38h			;4e5e	ff 	. 
	rst 38h			;4e5f	ff 	. 
	rst 38h			;4e60	ff 	. 
	rst 38h			;4e61	ff 	. 
	rst 38h			;4e62	ff 	. 
	rst 38h			;4e63	ff 	. 
	rst 38h			;4e64	ff 	. 
	rst 38h			;4e65	ff 	. 
	rst 38h			;4e66	ff 	. 
	rst 38h			;4e67	ff 	. 
	rst 38h			;4e68	ff 	. 
	rst 38h			;4e69	ff 	. 
	rst 38h			;4e6a	ff 	. 
	rst 38h			;4e6b	ff 	. 
	rst 38h			;4e6c	ff 	. 
	rst 38h			;4e6d	ff 	. 
	rst 38h			;4e6e	ff 	. 
	rst 38h			;4e6f	ff 	. 
	rst 38h			;4e70	ff 	. 
	rst 38h			;4e71	ff 	. 
	rst 38h			;4e72	ff 	. 
	rst 38h			;4e73	ff 	. 
	rst 38h			;4e74	ff 	. 
	rst 38h			;4e75	ff 	. 
	rst 38h			;4e76	ff 	. 
	rst 38h			;4e77	ff 	. 
	rst 38h			;4e78	ff 	. 
	rst 38h			;4e79	ff 	. 
	rst 38h			;4e7a	ff 	. 
	rst 38h			;4e7b	ff 	. 
	rst 38h			;4e7c	ff 	. 
	rst 38h			;4e7d	ff 	. 
	rst 38h			;4e7e	ff 	. 
	rst 38h			;4e7f	ff 	. 
	rst 38h			;4e80	ff 	. 
	rst 38h			;4e81	ff 	. 
	rst 38h			;4e82	ff 	. 
	rst 38h			;4e83	ff 	. 
	rst 38h			;4e84	ff 	. 
	rst 38h			;4e85	ff 	. 
	rst 38h			;4e86	ff 	. 
	rst 38h			;4e87	ff 	. 
	rst 38h			;4e88	ff 	. 
	rst 38h			;4e89	ff 	. 
	rst 38h			;4e8a	ff 	. 
	rst 38h			;4e8b	ff 	. 
	rst 38h			;4e8c	ff 	. 
	rst 38h			;4e8d	ff 	. 
	rst 38h			;4e8e	ff 	. 
	rst 38h			;4e8f	ff 	. 
	rst 38h			;4e90	ff 	. 
	rst 38h			;4e91	ff 	. 
	rst 38h			;4e92	ff 	. 
	rst 38h			;4e93	ff 	. 
	rst 38h			;4e94	ff 	. 
	rst 38h			;4e95	ff 	. 
	rst 38h			;4e96	ff 	. 
	rst 38h			;4e97	ff 	. 
	rst 38h			;4e98	ff 	. 
	rst 38h			;4e99	ff 	. 
	rst 38h			;4e9a	ff 	. 
	rst 38h			;4e9b	ff 	. 
	rst 38h			;4e9c	ff 	. 
	rst 38h			;4e9d	ff 	. 
	rst 38h			;4e9e	ff 	. 
	rst 38h			;4e9f	ff 	. 
	rst 38h			;4ea0	ff 	. 
	rst 38h			;4ea1	ff 	. 
	rst 38h			;4ea2	ff 	. 
	rst 38h			;4ea3	ff 	. 
	rst 38h			;4ea4	ff 	. 
	rst 38h			;4ea5	ff 	. 
	rst 38h			;4ea6	ff 	. 
	rst 38h			;4ea7	ff 	. 
	rst 38h			;4ea8	ff 	. 
	rst 38h			;4ea9	ff 	. 
	rst 38h			;4eaa	ff 	. 
	rst 38h			;4eab	ff 	. 
	rst 38h			;4eac	ff 	. 
	rst 38h			;4ead	ff 	. 
	rst 38h			;4eae	ff 	. 
	rst 38h			;4eaf	ff 	. 
	rst 38h			;4eb0	ff 	. 
	rst 38h			;4eb1	ff 	. 
	rst 38h			;4eb2	ff 	. 
	rst 38h			;4eb3	ff 	. 
	rst 38h			;4eb4	ff 	. 
	rst 38h			;4eb5	ff 	. 
	rst 38h			;4eb6	ff 	. 
	rst 38h			;4eb7	ff 	. 
	rst 38h			;4eb8	ff 	. 
	rst 38h			;4eb9	ff 	. 
	rst 38h			;4eba	ff 	. 
	rst 38h			;4ebb	ff 	. 
	rst 38h			;4ebc	ff 	. 
	rst 38h			;4ebd	ff 	. 
	rst 38h			;4ebe	ff 	. 
	rst 38h			;4ebf	ff 	. 
	rst 38h			;4ec0	ff 	. 
	rst 38h			;4ec1	ff 	. 
	rst 38h			;4ec2	ff 	. 
	rst 38h			;4ec3	ff 	. 
	rst 38h			;4ec4	ff 	. 
	rst 38h			;4ec5	ff 	. 
	rst 38h			;4ec6	ff 	. 
	rst 38h			;4ec7	ff 	. 
	rst 38h			;4ec8	ff 	. 
	rst 38h			;4ec9	ff 	. 
	rst 38h			;4eca	ff 	. 
	rst 38h			;4ecb	ff 	. 
	rst 38h			;4ecc	ff 	. 
	rst 38h			;4ecd	ff 	. 
	rst 38h			;4ece	ff 	. 
	rst 38h			;4ecf	ff 	. 
	rst 38h			;4ed0	ff 	. 
	rst 38h			;4ed1	ff 	. 
	rst 38h			;4ed2	ff 	. 
	rst 38h			;4ed3	ff 	. 
	rst 38h			;4ed4	ff 	. 
	rst 38h			;4ed5	ff 	. 
	rst 38h			;4ed6	ff 	. 
	rst 38h			;4ed7	ff 	. 
	rst 38h			;4ed8	ff 	. 
	rst 38h			;4ed9	ff 	. 
	rst 38h			;4eda	ff 	. 
	rst 38h			;4edb	ff 	. 
	rst 38h			;4edc	ff 	. 
	rst 38h			;4edd	ff 	. 
	rst 38h			;4ede	ff 	. 
	rst 38h			;4edf	ff 	. 
	rst 38h			;4ee0	ff 	. 
	rst 38h			;4ee1	ff 	. 
	rst 38h			;4ee2	ff 	. 
	rst 38h			;4ee3	ff 	. 
	rst 38h			;4ee4	ff 	. 
	rst 38h			;4ee5	ff 	. 
	rst 38h			;4ee6	ff 	. 
	rst 38h			;4ee7	ff 	. 
	rst 38h			;4ee8	ff 	. 
	rst 38h			;4ee9	ff 	. 
	rst 38h			;4eea	ff 	. 
	rst 38h			;4eeb	ff 	. 
	rst 38h			;4eec	ff 	. 
	rst 38h			;4eed	ff 	. 
	rst 38h			;4eee	ff 	. 
	rst 38h			;4eef	ff 	. 
	rst 38h			;4ef0	ff 	. 
	rst 38h			;4ef1	ff 	. 
	rst 38h			;4ef2	ff 	. 
	rst 38h			;4ef3	ff 	. 
	rst 38h			;4ef4	ff 	. 
	rst 38h			;4ef5	ff 	. 
	rst 38h			;4ef6	ff 	. 
	rst 38h			;4ef7	ff 	. 
	rst 38h			;4ef8	ff 	. 
	rst 38h			;4ef9	ff 	. 
	rst 38h			;4efa	ff 	. 
	rst 38h			;4efb	ff 	. 
	rst 38h			;4efc	ff 	. 
	rst 38h			;4efd	ff 	. 
	rst 38h			;4efe	ff 	. 
	rst 38h			;4eff	ff 	. 
	rst 38h			;4f00	ff 	. 
	rst 38h			;4f01	ff 	. 
	rst 38h			;4f02	ff 	. 
	rst 38h			;4f03	ff 	. 
	rst 38h			;4f04	ff 	. 
	rst 38h			;4f05	ff 	. 
	rst 38h			;4f06	ff 	. 
	rst 38h			;4f07	ff 	. 
	rst 38h			;4f08	ff 	. 
	rst 38h			;4f09	ff 	. 
	rst 38h			;4f0a	ff 	. 
	rst 38h			;4f0b	ff 	. 
	rst 38h			;4f0c	ff 	. 
	rst 38h			;4f0d	ff 	. 
	rst 38h			;4f0e	ff 	. 
	rst 38h			;4f0f	ff 	. 
	rst 38h			;4f10	ff 	. 
	rst 38h			;4f11	ff 	. 
	rst 38h			;4f12	ff 	. 
	rst 38h			;4f13	ff 	. 
	rst 38h			;4f14	ff 	. 
	rst 38h			;4f15	ff 	. 
	rst 38h			;4f16	ff 	. 
	rst 38h			;4f17	ff 	. 
	rst 38h			;4f18	ff 	. 
	rst 38h			;4f19	ff 	. 
	rst 38h			;4f1a	ff 	. 
	rst 38h			;4f1b	ff 	. 
	rst 38h			;4f1c	ff 	. 
	rst 38h			;4f1d	ff 	. 
	rst 38h			;4f1e	ff 	. 
	rst 38h			;4f1f	ff 	. 
	rst 38h			;4f20	ff 	. 
	rst 38h			;4f21	ff 	. 
	rst 38h			;4f22	ff 	. 
	rst 38h			;4f23	ff 	. 
	rst 38h			;4f24	ff 	. 
	rst 38h			;4f25	ff 	. 
	rst 38h			;4f26	ff 	. 
	rst 38h			;4f27	ff 	. 
	rst 38h			;4f28	ff 	. 
	rst 38h			;4f29	ff 	. 
	rst 38h			;4f2a	ff 	. 
	rst 38h			;4f2b	ff 	. 
	rst 38h			;4f2c	ff 	. 
	rst 38h			;4f2d	ff 	. 
	rst 38h			;4f2e	ff 	. 
	rst 38h			;4f2f	ff 	. 
	rst 38h			;4f30	ff 	. 
	rst 38h			;4f31	ff 	. 
	rst 38h			;4f32	ff 	. 
	rst 38h			;4f33	ff 	. 
	rst 38h			;4f34	ff 	. 
	rst 38h			;4f35	ff 	. 
	rst 38h			;4f36	ff 	. 
	rst 38h			;4f37	ff 	. 
	rst 38h			;4f38	ff 	. 
	rst 38h			;4f39	ff 	. 
	rst 38h			;4f3a	ff 	. 
	rst 38h			;4f3b	ff 	. 
	rst 38h			;4f3c	ff 	. 
	rst 38h			;4f3d	ff 	. 
	rst 38h			;4f3e	ff 	. 
	rst 38h			;4f3f	ff 	. 
	rst 38h			;4f40	ff 	. 
	rst 38h			;4f41	ff 	. 
	rst 38h			;4f42	ff 	. 
	rst 38h			;4f43	ff 	. 
	rst 38h			;4f44	ff 	. 
	rst 38h			;4f45	ff 	. 
	rst 38h			;4f46	ff 	. 
	rst 38h			;4f47	ff 	. 
	rst 38h			;4f48	ff 	. 
	rst 38h			;4f49	ff 	. 
	rst 38h			;4f4a	ff 	. 
	rst 38h			;4f4b	ff 	. 
	rst 38h			;4f4c	ff 	. 
	rst 38h			;4f4d	ff 	. 
	rst 38h			;4f4e	ff 	. 
	rst 38h			;4f4f	ff 	. 
	rst 38h			;4f50	ff 	. 
	rst 38h			;4f51	ff 	. 
	rst 38h			;4f52	ff 	. 
	rst 38h			;4f53	ff 	. 
	rst 38h			;4f54	ff 	. 
	rst 38h			;4f55	ff 	. 
	rst 38h			;4f56	ff 	. 
	rst 38h			;4f57	ff 	. 
	rst 38h			;4f58	ff 	. 
	rst 38h			;4f59	ff 	. 
	rst 38h			;4f5a	ff 	. 
	rst 38h			;4f5b	ff 	. 
	rst 38h			;4f5c	ff 	. 
	rst 38h			;4f5d	ff 	. 
	rst 38h			;4f5e	ff 	. 
	rst 38h			;4f5f	ff 	. 
	rst 38h			;4f60	ff 	. 
	rst 38h			;4f61	ff 	. 
	rst 38h			;4f62	ff 	. 
	rst 38h			;4f63	ff 	. 
	rst 38h			;4f64	ff 	. 
	rst 38h			;4f65	ff 	. 
	rst 38h			;4f66	ff 	. 
	rst 38h			;4f67	ff 	. 
	rst 38h			;4f68	ff 	. 
	rst 38h			;4f69	ff 	. 
	rst 38h			;4f6a	ff 	. 
	rst 38h			;4f6b	ff 	. 
	rst 38h			;4f6c	ff 	. 
	rst 38h			;4f6d	ff 	. 
	rst 38h			;4f6e	ff 	. 
	rst 38h			;4f6f	ff 	. 
	rst 38h			;4f70	ff 	. 
	rst 38h			;4f71	ff 	. 
	rst 38h			;4f72	ff 	. 
	rst 38h			;4f73	ff 	. 
	rst 38h			;4f74	ff 	. 
	rst 38h			;4f75	ff 	. 
	rst 38h			;4f76	ff 	. 
	rst 38h			;4f77	ff 	. 
	rst 38h			;4f78	ff 	. 
	rst 38h			;4f79	ff 	. 
	rst 38h			;4f7a	ff 	. 
	rst 38h			;4f7b	ff 	. 
	rst 38h			;4f7c	ff 	. 
	rst 38h			;4f7d	ff 	. 
	rst 38h			;4f7e	ff 	. 
	rst 38h			;4f7f	ff 	. 
	rst 38h			;4f80	ff 	. 
	rst 38h			;4f81	ff 	. 
	rst 38h			;4f82	ff 	. 
	rst 38h			;4f83	ff 	. 
	rst 38h			;4f84	ff 	. 
	rst 38h			;4f85	ff 	. 
	rst 38h			;4f86	ff 	. 
	rst 38h			;4f87	ff 	. 
	rst 38h			;4f88	ff 	. 
	rst 38h			;4f89	ff 	. 
	rst 38h			;4f8a	ff 	. 
	rst 38h			;4f8b	ff 	. 
	rst 38h			;4f8c	ff 	. 
	rst 38h			;4f8d	ff 	. 
	rst 38h			;4f8e	ff 	. 
	rst 38h			;4f8f	ff 	. 
	rst 38h			;4f90	ff 	. 
	rst 38h			;4f91	ff 	. 
	rst 38h			;4f92	ff 	. 
	rst 38h			;4f93	ff 	. 
	rst 38h			;4f94	ff 	. 
	rst 38h			;4f95	ff 	. 
	rst 38h			;4f96	ff 	. 
	rst 38h			;4f97	ff 	. 
	rst 38h			;4f98	ff 	. 
	rst 38h			;4f99	ff 	. 
	rst 38h			;4f9a	ff 	. 
	rst 38h			;4f9b	ff 	. 
	rst 38h			;4f9c	ff 	. 
	rst 38h			;4f9d	ff 	. 
	rst 38h			;4f9e	ff 	. 
	rst 38h			;4f9f	ff 	. 
	rst 38h			;4fa0	ff 	. 
	rst 38h			;4fa1	ff 	. 
	rst 38h			;4fa2	ff 	. 
	rst 38h			;4fa3	ff 	. 
	rst 38h			;4fa4	ff 	. 
	rst 38h			;4fa5	ff 	. 
	rst 38h			;4fa6	ff 	. 
	rst 38h			;4fa7	ff 	. 
	rst 38h			;4fa8	ff 	. 
	rst 38h			;4fa9	ff 	. 
	rst 38h			;4faa	ff 	. 
	rst 38h			;4fab	ff 	. 
	rst 38h			;4fac	ff 	. 
	rst 38h			;4fad	ff 	. 
	rst 38h			;4fae	ff 	. 
	rst 38h			;4faf	ff 	. 
	rst 38h			;4fb0	ff 	. 
	rst 38h			;4fb1	ff 	. 
	rst 38h			;4fb2	ff 	. 
	rst 38h			;4fb3	ff 	. 
	rst 38h			;4fb4	ff 	. 
	rst 38h			;4fb5	ff 	. 
	rst 38h			;4fb6	ff 	. 
	rst 38h			;4fb7	ff 	. 
	rst 38h			;4fb8	ff 	. 
	rst 38h			;4fb9	ff 	. 
	rst 38h			;4fba	ff 	. 
	rst 38h			;4fbb	ff 	. 
	rst 38h			;4fbc	ff 	. 
	rst 38h			;4fbd	ff 	. 
	rst 38h			;4fbe	ff 	. 
	rst 38h			;4fbf	ff 	. 
	rst 38h			;4fc0	ff 	. 
	rst 38h			;4fc1	ff 	. 
	rst 38h			;4fc2	ff 	. 
	rst 38h			;4fc3	ff 	. 
	rst 38h			;4fc4	ff 	. 
	rst 38h			;4fc5	ff 	. 
	rst 38h			;4fc6	ff 	. 
	rst 38h			;4fc7	ff 	. 
	rst 38h			;4fc8	ff 	. 
	rst 38h			;4fc9	ff 	. 
	rst 38h			;4fca	ff 	. 
	rst 38h			;4fcb	ff 	. 
	rst 38h			;4fcc	ff 	. 
	rst 38h			;4fcd	ff 	. 
	rst 38h			;4fce	ff 	. 
	rst 38h			;4fcf	ff 	. 
	rst 38h			;4fd0	ff 	. 
	rst 38h			;4fd1	ff 	. 
	rst 38h			;4fd2	ff 	. 
	rst 38h			;4fd3	ff 	. 
	rst 38h			;4fd4	ff 	. 
	rst 38h			;4fd5	ff 	. 
	rst 38h			;4fd6	ff 	. 
	rst 38h			;4fd7	ff 	. 
	rst 38h			;4fd8	ff 	. 
	rst 38h			;4fd9	ff 	. 
	rst 38h			;4fda	ff 	. 
	rst 38h			;4fdb	ff 	. 
	rst 38h			;4fdc	ff 	. 
	rst 38h			;4fdd	ff 	. 
	rst 38h			;4fde	ff 	. 
	rst 38h			;4fdf	ff 	. 
	rst 38h			;4fe0	ff 	. 
	rst 38h			;4fe1	ff 	. 
	rst 38h			;4fe2	ff 	. 
	rst 38h			;4fe3	ff 	. 
	rst 38h			;4fe4	ff 	. 
	rst 38h			;4fe5	ff 	. 
	rst 38h			;4fe6	ff 	. 
	rst 38h			;4fe7	ff 	. 
	rst 38h			;4fe8	ff 	. 
	rst 38h			;4fe9	ff 	. 
	rst 38h			;4fea	ff 	. 
	rst 38h			;4feb	ff 	. 
	rst 38h			;4fec	ff 	. 
	rst 38h			;4fed	ff 	. 
	rst 38h			;4fee	ff 	. 
	rst 38h			;4fef	ff 	. 
	rst 38h			;4ff0	ff 	. 
	rst 38h			;4ff1	ff 	. 
	rst 38h			;4ff2	ff 	. 
	rst 38h			;4ff3	ff 	. 
	rst 38h			;4ff4	ff 	. 
	rst 38h			;4ff5	ff 	. 
	rst 38h			;4ff6	ff 	. 
	rst 38h			;4ff7	ff 	. 
	rst 38h			;4ff8	ff 	. 
	rst 38h			;4ff9	ff 	. 
	rst 38h			;4ffa	ff 	. 
	rst 38h			;4ffb	ff 	. 
	rst 38h			;4ffc	ff 	. 
	rst 38h			;4ffd	ff 	. 
	rst 38h			;4ffe	ff 	. 
	rst 38h			;4fff	ff 	. 
	rst 38h			;5000	ff 	. 
	rst 38h			;5001	ff 	. 
	rst 38h			;5002	ff 	. 
	rst 38h			;5003	ff 	. 
	rst 38h			;5004	ff 	. 
	rst 38h			;5005	ff 	. 
	rst 38h			;5006	ff 	. 
	rst 38h			;5007	ff 	. 
	rst 38h			;5008	ff 	. 
	rst 38h			;5009	ff 	. 
	rst 38h			;500a	ff 	. 
	rst 38h			;500b	ff 	. 
	rst 38h			;500c	ff 	. 
	rst 38h			;500d	ff 	. 
	rst 38h			;500e	ff 	. 
	rst 38h			;500f	ff 	. 
	rst 38h			;5010	ff 	. 
	rst 38h			;5011	ff 	. 
	rst 38h			;5012	ff 	. 
	rst 38h			;5013	ff 	. 
	rst 38h			;5014	ff 	. 
	rst 38h			;5015	ff 	. 
	rst 38h			;5016	ff 	. 
	rst 38h			;5017	ff 	. 
	rst 38h			;5018	ff 	. 
	rst 38h			;5019	ff 	. 
	rst 38h			;501a	ff 	. 
	rst 38h			;501b	ff 	. 
	rst 38h			;501c	ff 	. 
	rst 38h			;501d	ff 	. 
	rst 38h			;501e	ff 	. 
	rst 38h			;501f	ff 	. 
	rst 38h			;5020	ff 	. 
	rst 38h			;5021	ff 	. 
	rst 38h			;5022	ff 	. 
	rst 38h			;5023	ff 	. 
	rst 38h			;5024	ff 	. 
	rst 38h			;5025	ff 	. 
	rst 38h			;5026	ff 	. 
	rst 38h			;5027	ff 	. 
	rst 38h			;5028	ff 	. 
	rst 38h			;5029	ff 	. 
	rst 38h			;502a	ff 	. 
	rst 38h			;502b	ff 	. 
	rst 38h			;502c	ff 	. 
	rst 38h			;502d	ff 	. 
	rst 38h			;502e	ff 	. 
	rst 38h			;502f	ff 	. 
	rst 38h			;5030	ff 	. 
	rst 38h			;5031	ff 	. 
	rst 38h			;5032	ff 	. 
	rst 38h			;5033	ff 	. 
	rst 38h			;5034	ff 	. 
	rst 38h			;5035	ff 	. 
	rst 38h			;5036	ff 	. 
	rst 38h			;5037	ff 	. 
	rst 38h			;5038	ff 	. 
	rst 38h			;5039	ff 	. 
	rst 38h			;503a	ff 	. 
	rst 38h			;503b	ff 	. 
	rst 38h			;503c	ff 	. 
	rst 38h			;503d	ff 	. 
	rst 38h			;503e	ff 	. 
	rst 38h			;503f	ff 	. 
	rst 38h			;5040	ff 	. 
	rst 38h			;5041	ff 	. 
	rst 38h			;5042	ff 	. 
	rst 38h			;5043	ff 	. 
	rst 38h			;5044	ff 	. 
	rst 38h			;5045	ff 	. 
	rst 38h			;5046	ff 	. 
	rst 38h			;5047	ff 	. 
	rst 38h			;5048	ff 	. 
	rst 38h			;5049	ff 	. 
	rst 38h			;504a	ff 	. 
	rst 38h			;504b	ff 	. 
	rst 38h			;504c	ff 	. 
	rst 38h			;504d	ff 	. 
	rst 38h			;504e	ff 	. 
	rst 38h			;504f	ff 	. 
	rst 38h			;5050	ff 	. 
	rst 38h			;5051	ff 	. 
	rst 38h			;5052	ff 	. 
	rst 38h			;5053	ff 	. 
	rst 38h			;5054	ff 	. 
	rst 38h			;5055	ff 	. 
	rst 38h			;5056	ff 	. 
	rst 38h			;5057	ff 	. 
	rst 38h			;5058	ff 	. 
	rst 38h			;5059	ff 	. 
	rst 38h			;505a	ff 	. 
	rst 38h			;505b	ff 	. 
	rst 38h			;505c	ff 	. 
	rst 38h			;505d	ff 	. 
	rst 38h			;505e	ff 	. 
	rst 38h			;505f	ff 	. 
	rst 38h			;5060	ff 	. 
	rst 38h			;5061	ff 	. 
	rst 38h			;5062	ff 	. 
	rst 38h			;5063	ff 	. 
	rst 38h			;5064	ff 	. 
	rst 38h			;5065	ff 	. 
	rst 38h			;5066	ff 	. 
	rst 38h			;5067	ff 	. 
	rst 38h			;5068	ff 	. 
	rst 38h			;5069	ff 	. 
	rst 38h			;506a	ff 	. 
	rst 38h			;506b	ff 	. 
	rst 38h			;506c	ff 	. 
	rst 38h			;506d	ff 	. 
	rst 38h			;506e	ff 	. 
	rst 38h			;506f	ff 	. 
	rst 38h			;5070	ff 	. 
	rst 38h			;5071	ff 	. 
	rst 38h			;5072	ff 	. 
	rst 38h			;5073	ff 	. 
	rst 38h			;5074	ff 	. 
	rst 38h			;5075	ff 	. 
	rst 38h			;5076	ff 	. 
	rst 38h			;5077	ff 	. 
	rst 38h			;5078	ff 	. 
	rst 38h			;5079	ff 	. 
	rst 38h			;507a	ff 	. 
	rst 38h			;507b	ff 	. 
	rst 38h			;507c	ff 	. 
	rst 38h			;507d	ff 	. 
	rst 38h			;507e	ff 	. 
	rst 38h			;507f	ff 	. 
	rst 38h			;5080	ff 	. 
	rst 38h			;5081	ff 	. 
	rst 38h			;5082	ff 	. 
	rst 38h			;5083	ff 	. 
	rst 38h			;5084	ff 	. 
	rst 38h			;5085	ff 	. 
	rst 38h			;5086	ff 	. 
	rst 38h			;5087	ff 	. 
	rst 38h			;5088	ff 	. 
	rst 38h			;5089	ff 	. 
	rst 38h			;508a	ff 	. 
	rst 38h			;508b	ff 	. 
	rst 38h			;508c	ff 	. 
	rst 38h			;508d	ff 	. 
	rst 38h			;508e	ff 	. 
	rst 38h			;508f	ff 	. 
	rst 38h			;5090	ff 	. 
	rst 38h			;5091	ff 	. 
	rst 38h			;5092	ff 	. 
	rst 38h			;5093	ff 	. 
	rst 38h			;5094	ff 	. 
	rst 38h			;5095	ff 	. 
	rst 38h			;5096	ff 	. 
	rst 38h			;5097	ff 	. 
	rst 38h			;5098	ff 	. 
	rst 38h			;5099	ff 	. 
	rst 38h			;509a	ff 	. 
	rst 38h			;509b	ff 	. 
	rst 38h			;509c	ff 	. 
	rst 38h			;509d	ff 	. 
	rst 38h			;509e	ff 	. 
	rst 38h			;509f	ff 	. 
	rst 38h			;50a0	ff 	. 
	rst 38h			;50a1	ff 	. 
	rst 38h			;50a2	ff 	. 
	rst 38h			;50a3	ff 	. 
	rst 38h			;50a4	ff 	. 
	rst 38h			;50a5	ff 	. 
	rst 38h			;50a6	ff 	. 
	rst 38h			;50a7	ff 	. 
	rst 38h			;50a8	ff 	. 
	rst 38h			;50a9	ff 	. 
	rst 38h			;50aa	ff 	. 
	rst 38h			;50ab	ff 	. 
	rst 38h			;50ac	ff 	. 
	rst 38h			;50ad	ff 	. 
	rst 38h			;50ae	ff 	. 
	rst 38h			;50af	ff 	. 
	rst 38h			;50b0	ff 	. 
	rst 38h			;50b1	ff 	. 
	rst 38h			;50b2	ff 	. 
	rst 38h			;50b3	ff 	. 
	rst 38h			;50b4	ff 	. 
	rst 38h			;50b5	ff 	. 
	rst 38h			;50b6	ff 	. 
	rst 38h			;50b7	ff 	. 
	rst 38h			;50b8	ff 	. 
	rst 38h			;50b9	ff 	. 
	rst 38h			;50ba	ff 	. 
	rst 38h			;50bb	ff 	. 
	rst 38h			;50bc	ff 	. 
	rst 38h			;50bd	ff 	. 
	rst 38h			;50be	ff 	. 
	rst 38h			;50bf	ff 	. 
	rst 38h			;50c0	ff 	. 
	rst 38h			;50c1	ff 	. 
	rst 38h			;50c2	ff 	. 
	rst 38h			;50c3	ff 	. 
	rst 38h			;50c4	ff 	. 
	rst 38h			;50c5	ff 	. 
	rst 38h			;50c6	ff 	. 
	rst 38h			;50c7	ff 	. 
	rst 38h			;50c8	ff 	. 
	rst 38h			;50c9	ff 	. 
	rst 38h			;50ca	ff 	. 
	rst 38h			;50cb	ff 	. 
	rst 38h			;50cc	ff 	. 
	rst 38h			;50cd	ff 	. 
	rst 38h			;50ce	ff 	. 
	rst 38h			;50cf	ff 	. 
	rst 38h			;50d0	ff 	. 
	rst 38h			;50d1	ff 	. 
	rst 38h			;50d2	ff 	. 
	rst 38h			;50d3	ff 	. 
	rst 38h			;50d4	ff 	. 
	rst 38h			;50d5	ff 	. 
	rst 38h			;50d6	ff 	. 
	rst 38h			;50d7	ff 	. 
	rst 38h			;50d8	ff 	. 
	rst 38h			;50d9	ff 	. 
	rst 38h			;50da	ff 	. 
	rst 38h			;50db	ff 	. 
	rst 38h			;50dc	ff 	. 
	rst 38h			;50dd	ff 	. 
	rst 38h			;50de	ff 	. 
	rst 38h			;50df	ff 	. 
	rst 38h			;50e0	ff 	. 
	rst 38h			;50e1	ff 	. 
	rst 38h			;50e2	ff 	. 
	rst 38h			;50e3	ff 	. 
	rst 38h			;50e4	ff 	. 
	rst 38h			;50e5	ff 	. 
	rst 38h			;50e6	ff 	. 
	rst 38h			;50e7	ff 	. 
	rst 38h			;50e8	ff 	. 
	rst 38h			;50e9	ff 	. 
	rst 38h			;50ea	ff 	. 
	rst 38h			;50eb	ff 	. 
	rst 38h			;50ec	ff 	. 
	rst 38h			;50ed	ff 	. 
	rst 38h			;50ee	ff 	. 
	rst 38h			;50ef	ff 	. 
	rst 38h			;50f0	ff 	. 
	rst 38h			;50f1	ff 	. 
	rst 38h			;50f2	ff 	. 
	rst 38h			;50f3	ff 	. 
	rst 38h			;50f4	ff 	. 
	rst 38h			;50f5	ff 	. 
	rst 38h			;50f6	ff 	. 
	rst 38h			;50f7	ff 	. 
	rst 38h			;50f8	ff 	. 
	rst 38h			;50f9	ff 	. 
	rst 38h			;50fa	ff 	. 
	rst 38h			;50fb	ff 	. 
	rst 38h			;50fc	ff 	. 
	rst 38h			;50fd	ff 	. 
	rst 38h			;50fe	ff 	. 
	rst 38h			;50ff	ff 	. 
	rst 38h			;5100	ff 	. 
	rst 38h			;5101	ff 	. 
	rst 38h			;5102	ff 	. 
	rst 38h			;5103	ff 	. 
	rst 38h			;5104	ff 	. 
	rst 38h			;5105	ff 	. 
	rst 38h			;5106	ff 	. 
	rst 38h			;5107	ff 	. 
	rst 38h			;5108	ff 	. 
	rst 38h			;5109	ff 	. 
	rst 38h			;510a	ff 	. 
	rst 38h			;510b	ff 	. 
	rst 38h			;510c	ff 	. 
	rst 38h			;510d	ff 	. 
	rst 38h			;510e	ff 	. 
	rst 38h			;510f	ff 	. 
	rst 38h			;5110	ff 	. 
	rst 38h			;5111	ff 	. 
	rst 38h			;5112	ff 	. 
	rst 38h			;5113	ff 	. 
	rst 38h			;5114	ff 	. 
	rst 38h			;5115	ff 	. 
	rst 38h			;5116	ff 	. 
	rst 38h			;5117	ff 	. 
	rst 38h			;5118	ff 	. 
	rst 38h			;5119	ff 	. 
	rst 38h			;511a	ff 	. 
	rst 38h			;511b	ff 	. 
	rst 38h			;511c	ff 	. 
	rst 38h			;511d	ff 	. 
	rst 38h			;511e	ff 	. 
	rst 38h			;511f	ff 	. 
	rst 38h			;5120	ff 	. 
	rst 38h			;5121	ff 	. 
	rst 38h			;5122	ff 	. 
	rst 38h			;5123	ff 	. 
	rst 38h			;5124	ff 	. 
	rst 38h			;5125	ff 	. 
	rst 38h			;5126	ff 	. 
	rst 38h			;5127	ff 	. 
	rst 38h			;5128	ff 	. 
	rst 38h			;5129	ff 	. 
	rst 38h			;512a	ff 	. 
	rst 38h			;512b	ff 	. 
	rst 38h			;512c	ff 	. 
	rst 38h			;512d	ff 	. 
	rst 38h			;512e	ff 	. 
	rst 38h			;512f	ff 	. 
	rst 38h			;5130	ff 	. 
	rst 38h			;5131	ff 	. 
	rst 38h			;5132	ff 	. 
	rst 38h			;5133	ff 	. 
	rst 38h			;5134	ff 	. 
	rst 38h			;5135	ff 	. 
	rst 38h			;5136	ff 	. 
	rst 38h			;5137	ff 	. 
	rst 38h			;5138	ff 	. 
	rst 38h			;5139	ff 	. 
	rst 38h			;513a	ff 	. 
	rst 38h			;513b	ff 	. 
	rst 38h			;513c	ff 	. 
	rst 38h			;513d	ff 	. 
	rst 38h			;513e	ff 	. 
	rst 38h			;513f	ff 	. 
	rst 38h			;5140	ff 	. 
	rst 38h			;5141	ff 	. 
	rst 38h			;5142	ff 	. 
	rst 38h			;5143	ff 	. 
	rst 38h			;5144	ff 	. 
	rst 38h			;5145	ff 	. 
	rst 38h			;5146	ff 	. 
	rst 38h			;5147	ff 	. 
	rst 38h			;5148	ff 	. 
	rst 38h			;5149	ff 	. 
	rst 38h			;514a	ff 	. 
	rst 38h			;514b	ff 	. 
	rst 38h			;514c	ff 	. 
	rst 38h			;514d	ff 	. 
	rst 38h			;514e	ff 	. 
	rst 38h			;514f	ff 	. 
	rst 38h			;5150	ff 	. 
	rst 38h			;5151	ff 	. 
	rst 38h			;5152	ff 	. 
	rst 38h			;5153	ff 	. 
	rst 38h			;5154	ff 	. 
	rst 38h			;5155	ff 	. 
	rst 38h			;5156	ff 	. 
	rst 38h			;5157	ff 	. 
	rst 38h			;5158	ff 	. 
	rst 38h			;5159	ff 	. 
	rst 38h			;515a	ff 	. 
	rst 38h			;515b	ff 	. 
	rst 38h			;515c	ff 	. 
	rst 38h			;515d	ff 	. 
	rst 38h			;515e	ff 	. 
	rst 38h			;515f	ff 	. 
	rst 38h			;5160	ff 	. 
	rst 38h			;5161	ff 	. 
	rst 38h			;5162	ff 	. 
	rst 38h			;5163	ff 	. 
	rst 38h			;5164	ff 	. 
	rst 38h			;5165	ff 	. 
	rst 38h			;5166	ff 	. 
	rst 38h			;5167	ff 	. 
	rst 38h			;5168	ff 	. 
	rst 38h			;5169	ff 	. 
	rst 38h			;516a	ff 	. 
	rst 38h			;516b	ff 	. 
	rst 38h			;516c	ff 	. 
	rst 38h			;516d	ff 	. 
	rst 38h			;516e	ff 	. 
	rst 38h			;516f	ff 	. 
	rst 38h			;5170	ff 	. 
	rst 38h			;5171	ff 	. 
	rst 38h			;5172	ff 	. 
	rst 38h			;5173	ff 	. 
	rst 38h			;5174	ff 	. 
	rst 38h			;5175	ff 	. 
	rst 38h			;5176	ff 	. 
	rst 38h			;5177	ff 	. 
	rst 38h			;5178	ff 	. 
	rst 38h			;5179	ff 	. 
	rst 38h			;517a	ff 	. 
	rst 38h			;517b	ff 	. 
	rst 38h			;517c	ff 	. 
	rst 38h			;517d	ff 	. 
	rst 38h			;517e	ff 	. 
	rst 38h			;517f	ff 	. 
	rst 38h			;5180	ff 	. 
	rst 38h			;5181	ff 	. 
	rst 38h			;5182	ff 	. 
	rst 38h			;5183	ff 	. 
	rst 38h			;5184	ff 	. 
	rst 38h			;5185	ff 	. 
	rst 38h			;5186	ff 	. 
	rst 38h			;5187	ff 	. 
	rst 38h			;5188	ff 	. 
	rst 38h			;5189	ff 	. 
	rst 38h			;518a	ff 	. 
	rst 38h			;518b	ff 	. 
	rst 38h			;518c	ff 	. 
	rst 38h			;518d	ff 	. 
	rst 38h			;518e	ff 	. 
	rst 38h			;518f	ff 	. 
	rst 38h			;5190	ff 	. 
	rst 38h			;5191	ff 	. 
	rst 38h			;5192	ff 	. 
	rst 38h			;5193	ff 	. 
	rst 38h			;5194	ff 	. 
	rst 38h			;5195	ff 	. 
	rst 38h			;5196	ff 	. 
	rst 38h			;5197	ff 	. 
	rst 38h			;5198	ff 	. 
	rst 38h			;5199	ff 	. 
	rst 38h			;519a	ff 	. 
	rst 38h			;519b	ff 	. 
	rst 38h			;519c	ff 	. 
	rst 38h			;519d	ff 	. 
	rst 38h			;519e	ff 	. 
	rst 38h			;519f	ff 	. 
	rst 38h			;51a0	ff 	. 
	rst 38h			;51a1	ff 	. 
	rst 38h			;51a2	ff 	. 
	rst 38h			;51a3	ff 	. 
	rst 38h			;51a4	ff 	. 
	rst 38h			;51a5	ff 	. 
	rst 38h			;51a6	ff 	. 
	rst 38h			;51a7	ff 	. 
	rst 38h			;51a8	ff 	. 
	rst 38h			;51a9	ff 	. 
	rst 38h			;51aa	ff 	. 
	rst 38h			;51ab	ff 	. 
	rst 38h			;51ac	ff 	. 
	rst 38h			;51ad	ff 	. 
	rst 38h			;51ae	ff 	. 
	rst 38h			;51af	ff 	. 
	rst 38h			;51b0	ff 	. 
	rst 38h			;51b1	ff 	. 
	rst 38h			;51b2	ff 	. 
	rst 38h			;51b3	ff 	. 
	rst 38h			;51b4	ff 	. 
	rst 38h			;51b5	ff 	. 
	rst 38h			;51b6	ff 	. 
	rst 38h			;51b7	ff 	. 
	rst 38h			;51b8	ff 	. 
	rst 38h			;51b9	ff 	. 
	rst 38h			;51ba	ff 	. 
	rst 38h			;51bb	ff 	. 
	rst 38h			;51bc	ff 	. 
	rst 38h			;51bd	ff 	. 
	rst 38h			;51be	ff 	. 
	rst 38h			;51bf	ff 	. 
	rst 38h			;51c0	ff 	. 
	rst 38h			;51c1	ff 	. 
	rst 38h			;51c2	ff 	. 
	rst 38h			;51c3	ff 	. 
	rst 38h			;51c4	ff 	. 
	rst 38h			;51c5	ff 	. 
	rst 38h			;51c6	ff 	. 
	rst 38h			;51c7	ff 	. 
	rst 38h			;51c8	ff 	. 
	rst 38h			;51c9	ff 	. 
	rst 38h			;51ca	ff 	. 
	rst 38h			;51cb	ff 	. 
	rst 38h			;51cc	ff 	. 
	rst 38h			;51cd	ff 	. 
	rst 38h			;51ce	ff 	. 
	rst 38h			;51cf	ff 	. 
	rst 38h			;51d0	ff 	. 
	rst 38h			;51d1	ff 	. 
	rst 38h			;51d2	ff 	. 
	rst 38h			;51d3	ff 	. 
	rst 38h			;51d4	ff 	. 
	rst 38h			;51d5	ff 	. 
	rst 38h			;51d6	ff 	. 
	rst 38h			;51d7	ff 	. 
	rst 38h			;51d8	ff 	. 
	rst 38h			;51d9	ff 	. 
	rst 38h			;51da	ff 	. 
	rst 38h			;51db	ff 	. 
	rst 38h			;51dc	ff 	. 
	rst 38h			;51dd	ff 	. 
	rst 38h			;51de	ff 	. 
	rst 38h			;51df	ff 	. 
	rst 38h			;51e0	ff 	. 
	rst 38h			;51e1	ff 	. 
	rst 38h			;51e2	ff 	. 
	rst 38h			;51e3	ff 	. 
	rst 38h			;51e4	ff 	. 
	rst 38h			;51e5	ff 	. 
	rst 38h			;51e6	ff 	. 
	rst 38h			;51e7	ff 	. 
	rst 38h			;51e8	ff 	. 
	rst 38h			;51e9	ff 	. 
	rst 38h			;51ea	ff 	. 
	rst 38h			;51eb	ff 	. 
	rst 38h			;51ec	ff 	. 
	rst 38h			;51ed	ff 	. 
	rst 38h			;51ee	ff 	. 
	rst 38h			;51ef	ff 	. 
	rst 38h			;51f0	ff 	. 
	rst 38h			;51f1	ff 	. 
	rst 38h			;51f2	ff 	. 
	rst 38h			;51f3	ff 	. 
	rst 38h			;51f4	ff 	. 
	rst 38h			;51f5	ff 	. 
	rst 38h			;51f6	ff 	. 
	rst 38h			;51f7	ff 	. 
	rst 38h			;51f8	ff 	. 
	rst 38h			;51f9	ff 	. 
	rst 38h			;51fa	ff 	. 
	rst 38h			;51fb	ff 	. 
	rst 38h			;51fc	ff 	. 
	rst 38h			;51fd	ff 	. 
	rst 38h			;51fe	ff 	. 
	rst 38h			;51ff	ff 	. 
	rst 38h			;5200	ff 	. 
	rst 38h			;5201	ff 	. 
	rst 38h			;5202	ff 	. 
	rst 38h			;5203	ff 	. 
	rst 38h			;5204	ff 	. 
	rst 38h			;5205	ff 	. 
	rst 38h			;5206	ff 	. 
	rst 38h			;5207	ff 	. 
	rst 38h			;5208	ff 	. 
	rst 38h			;5209	ff 	. 
	rst 38h			;520a	ff 	. 
	rst 38h			;520b	ff 	. 
	rst 38h			;520c	ff 	. 
	rst 38h			;520d	ff 	. 
	rst 38h			;520e	ff 	. 
	rst 38h			;520f	ff 	. 
	rst 38h			;5210	ff 	. 
	rst 38h			;5211	ff 	. 
	rst 38h			;5212	ff 	. 
	rst 38h			;5213	ff 	. 
	rst 38h			;5214	ff 	. 
	rst 38h			;5215	ff 	. 
	rst 38h			;5216	ff 	. 
	rst 38h			;5217	ff 	. 
	rst 38h			;5218	ff 	. 
	rst 38h			;5219	ff 	. 
	rst 38h			;521a	ff 	. 
	rst 38h			;521b	ff 	. 
	rst 38h			;521c	ff 	. 
	rst 38h			;521d	ff 	. 
	rst 38h			;521e	ff 	. 
	rst 38h			;521f	ff 	. 
	rst 38h			;5220	ff 	. 
	rst 38h			;5221	ff 	. 
	rst 38h			;5222	ff 	. 
	rst 38h			;5223	ff 	. 
	rst 38h			;5224	ff 	. 
	rst 38h			;5225	ff 	. 
	rst 38h			;5226	ff 	. 
	rst 38h			;5227	ff 	. 
	rst 38h			;5228	ff 	. 
	rst 38h			;5229	ff 	. 
	rst 38h			;522a	ff 	. 
	rst 38h			;522b	ff 	. 
	rst 38h			;522c	ff 	. 
	rst 38h			;522d	ff 	. 
	rst 38h			;522e	ff 	. 
	rst 38h			;522f	ff 	. 
	rst 38h			;5230	ff 	. 
	rst 38h			;5231	ff 	. 
	rst 38h			;5232	ff 	. 
	rst 38h			;5233	ff 	. 
	rst 38h			;5234	ff 	. 
	rst 38h			;5235	ff 	. 
	rst 38h			;5236	ff 	. 
	rst 38h			;5237	ff 	. 
	rst 38h			;5238	ff 	. 
	rst 38h			;5239	ff 	. 
	rst 38h			;523a	ff 	. 
	rst 38h			;523b	ff 	. 
	rst 38h			;523c	ff 	. 
	rst 38h			;523d	ff 	. 
	rst 38h			;523e	ff 	. 
	rst 38h			;523f	ff 	. 
	rst 38h			;5240	ff 	. 
	rst 38h			;5241	ff 	. 
	rst 38h			;5242	ff 	. 
	rst 38h			;5243	ff 	. 
	rst 38h			;5244	ff 	. 
	rst 38h			;5245	ff 	. 
	rst 38h			;5246	ff 	. 
	rst 38h			;5247	ff 	. 
	rst 38h			;5248	ff 	. 
	rst 38h			;5249	ff 	. 
	rst 38h			;524a	ff 	. 
	rst 38h			;524b	ff 	. 
	rst 38h			;524c	ff 	. 
	rst 38h			;524d	ff 	. 
	rst 38h			;524e	ff 	. 
	rst 38h			;524f	ff 	. 
	rst 38h			;5250	ff 	. 
	rst 38h			;5251	ff 	. 
	rst 38h			;5252	ff 	. 
	rst 38h			;5253	ff 	. 
	rst 38h			;5254	ff 	. 
	rst 38h			;5255	ff 	. 
	rst 38h			;5256	ff 	. 
	rst 38h			;5257	ff 	. 
	rst 38h			;5258	ff 	. 
	rst 38h			;5259	ff 	. 
	rst 38h			;525a	ff 	. 
	rst 38h			;525b	ff 	. 
	rst 38h			;525c	ff 	. 
	rst 38h			;525d	ff 	. 
	rst 38h			;525e	ff 	. 
	rst 38h			;525f	ff 	. 
	rst 38h			;5260	ff 	. 
	rst 38h			;5261	ff 	. 
	rst 38h			;5262	ff 	. 
	rst 38h			;5263	ff 	. 
	rst 38h			;5264	ff 	. 
	rst 38h			;5265	ff 	. 
	rst 38h			;5266	ff 	. 
	rst 38h			;5267	ff 	. 
	rst 38h			;5268	ff 	. 
	rst 38h			;5269	ff 	. 
	rst 38h			;526a	ff 	. 
	rst 38h			;526b	ff 	. 
	rst 38h			;526c	ff 	. 
	rst 38h			;526d	ff 	. 
	rst 38h			;526e	ff 	. 
	rst 38h			;526f	ff 	. 
	rst 38h			;5270	ff 	. 
	rst 38h			;5271	ff 	. 
	rst 38h			;5272	ff 	. 
	rst 38h			;5273	ff 	. 
	rst 38h			;5274	ff 	. 
	rst 38h			;5275	ff 	. 
	rst 38h			;5276	ff 	. 
	rst 38h			;5277	ff 	. 
	rst 38h			;5278	ff 	. 
	rst 38h			;5279	ff 	. 
	rst 38h			;527a	ff 	. 
	rst 38h			;527b	ff 	. 
	rst 38h			;527c	ff 	. 
	rst 38h			;527d	ff 	. 
	rst 38h			;527e	ff 	. 
	rst 38h			;527f	ff 	. 
	rst 38h			;5280	ff 	. 
	rst 38h			;5281	ff 	. 
	rst 38h			;5282	ff 	. 
	rst 38h			;5283	ff 	. 
	rst 38h			;5284	ff 	. 
	rst 38h			;5285	ff 	. 
	rst 38h			;5286	ff 	. 
	rst 38h			;5287	ff 	. 
	rst 38h			;5288	ff 	. 
	rst 38h			;5289	ff 	. 
	rst 38h			;528a	ff 	. 
	rst 38h			;528b	ff 	. 
	rst 38h			;528c	ff 	. 
	rst 38h			;528d	ff 	. 
	rst 38h			;528e	ff 	. 
	rst 38h			;528f	ff 	. 
	rst 38h			;5290	ff 	. 
	rst 38h			;5291	ff 	. 
	rst 38h			;5292	ff 	. 
	rst 38h			;5293	ff 	. 
	rst 38h			;5294	ff 	. 
	rst 38h			;5295	ff 	. 
	rst 38h			;5296	ff 	. 
	rst 38h			;5297	ff 	. 
	rst 38h			;5298	ff 	. 
	rst 38h			;5299	ff 	. 
	rst 38h			;529a	ff 	. 
	rst 38h			;529b	ff 	. 
	rst 38h			;529c	ff 	. 
	rst 38h			;529d	ff 	. 
	rst 38h			;529e	ff 	. 
	rst 38h			;529f	ff 	. 
	rst 38h			;52a0	ff 	. 
	rst 38h			;52a1	ff 	. 
	rst 38h			;52a2	ff 	. 
	rst 38h			;52a3	ff 	. 
	rst 38h			;52a4	ff 	. 
	rst 38h			;52a5	ff 	. 
	rst 38h			;52a6	ff 	. 
	rst 38h			;52a7	ff 	. 
	rst 38h			;52a8	ff 	. 
	rst 38h			;52a9	ff 	. 
	rst 38h			;52aa	ff 	. 
	rst 38h			;52ab	ff 	. 
	rst 38h			;52ac	ff 	. 
	rst 38h			;52ad	ff 	. 
	rst 38h			;52ae	ff 	. 
	rst 38h			;52af	ff 	. 
	rst 38h			;52b0	ff 	. 
	rst 38h			;52b1	ff 	. 
	rst 38h			;52b2	ff 	. 
	rst 38h			;52b3	ff 	. 
	rst 38h			;52b4	ff 	. 
	rst 38h			;52b5	ff 	. 
	rst 38h			;52b6	ff 	. 
	rst 38h			;52b7	ff 	. 
	rst 38h			;52b8	ff 	. 
	rst 38h			;52b9	ff 	. 
	rst 38h			;52ba	ff 	. 
	rst 38h			;52bb	ff 	. 
	rst 38h			;52bc	ff 	. 
	rst 38h			;52bd	ff 	. 
	rst 38h			;52be	ff 	. 
	rst 38h			;52bf	ff 	. 
	rst 38h			;52c0	ff 	. 
	rst 38h			;52c1	ff 	. 
	rst 38h			;52c2	ff 	. 
	rst 38h			;52c3	ff 	. 
	rst 38h			;52c4	ff 	. 
	rst 38h			;52c5	ff 	. 
	rst 38h			;52c6	ff 	. 
	rst 38h			;52c7	ff 	. 
	rst 38h			;52c8	ff 	. 
	rst 38h			;52c9	ff 	. 
	rst 38h			;52ca	ff 	. 
	rst 38h			;52cb	ff 	. 
	rst 38h			;52cc	ff 	. 
	rst 38h			;52cd	ff 	. 
	rst 38h			;52ce	ff 	. 
	rst 38h			;52cf	ff 	. 
	rst 38h			;52d0	ff 	. 
	rst 38h			;52d1	ff 	. 
	rst 38h			;52d2	ff 	. 
	rst 38h			;52d3	ff 	. 
	rst 38h			;52d4	ff 	. 
	rst 38h			;52d5	ff 	. 
	rst 38h			;52d6	ff 	. 
	rst 38h			;52d7	ff 	. 
	rst 38h			;52d8	ff 	. 
	rst 38h			;52d9	ff 	. 
	rst 38h			;52da	ff 	. 
	rst 38h			;52db	ff 	. 
	rst 38h			;52dc	ff 	. 
	rst 38h			;52dd	ff 	. 
	rst 38h			;52de	ff 	. 
	rst 38h			;52df	ff 	. 
	rst 38h			;52e0	ff 	. 
	rst 38h			;52e1	ff 	. 
	rst 38h			;52e2	ff 	. 
	rst 38h			;52e3	ff 	. 
	rst 38h			;52e4	ff 	. 
	rst 38h			;52e5	ff 	. 
	rst 38h			;52e6	ff 	. 
	rst 38h			;52e7	ff 	. 
	rst 38h			;52e8	ff 	. 
	rst 38h			;52e9	ff 	. 
	rst 38h			;52ea	ff 	. 
	rst 38h			;52eb	ff 	. 
	rst 38h			;52ec	ff 	. 
	rst 38h			;52ed	ff 	. 
	rst 38h			;52ee	ff 	. 
	rst 38h			;52ef	ff 	. 
	rst 38h			;52f0	ff 	. 
	rst 38h			;52f1	ff 	. 
	rst 38h			;52f2	ff 	. 
	rst 38h			;52f3	ff 	. 
	rst 38h			;52f4	ff 	. 
	rst 38h			;52f5	ff 	. 
	rst 38h			;52f6	ff 	. 
	rst 38h			;52f7	ff 	. 
	rst 38h			;52f8	ff 	. 
	rst 38h			;52f9	ff 	. 
	rst 38h			;52fa	ff 	. 
	rst 38h			;52fb	ff 	. 
	rst 38h			;52fc	ff 	. 
	rst 38h			;52fd	ff 	. 
	rst 38h			;52fe	ff 	. 
	rst 38h			;52ff	ff 	. 
	rst 38h			;5300	ff 	. 
	rst 38h			;5301	ff 	. 
	rst 38h			;5302	ff 	. 
	rst 38h			;5303	ff 	. 
	rst 38h			;5304	ff 	. 
	rst 38h			;5305	ff 	. 
	rst 38h			;5306	ff 	. 
	rst 38h			;5307	ff 	. 
	rst 38h			;5308	ff 	. 
	rst 38h			;5309	ff 	. 
	rst 38h			;530a	ff 	. 
	rst 38h			;530b	ff 	. 
	rst 38h			;530c	ff 	. 
	rst 38h			;530d	ff 	. 
	rst 38h			;530e	ff 	. 
	rst 38h			;530f	ff 	. 
	rst 38h			;5310	ff 	. 
	rst 38h			;5311	ff 	. 
	rst 38h			;5312	ff 	. 
	rst 38h			;5313	ff 	. 
	rst 38h			;5314	ff 	. 
	rst 38h			;5315	ff 	. 
	rst 38h			;5316	ff 	. 
	rst 38h			;5317	ff 	. 
	rst 38h			;5318	ff 	. 
	rst 38h			;5319	ff 	. 
	rst 38h			;531a	ff 	. 
	rst 38h			;531b	ff 	. 
	rst 38h			;531c	ff 	. 
	rst 38h			;531d	ff 	. 
	rst 38h			;531e	ff 	. 
	rst 38h			;531f	ff 	. 
	rst 38h			;5320	ff 	. 
	rst 38h			;5321	ff 	. 
	rst 38h			;5322	ff 	. 
	rst 38h			;5323	ff 	. 
	rst 38h			;5324	ff 	. 
	rst 38h			;5325	ff 	. 
	rst 38h			;5326	ff 	. 
	rst 38h			;5327	ff 	. 
	rst 38h			;5328	ff 	. 
	rst 38h			;5329	ff 	. 
	rst 38h			;532a	ff 	. 
	rst 38h			;532b	ff 	. 
	rst 38h			;532c	ff 	. 
	rst 38h			;532d	ff 	. 
	rst 38h			;532e	ff 	. 
	rst 38h			;532f	ff 	. 
	rst 38h			;5330	ff 	. 
	rst 38h			;5331	ff 	. 
	rst 38h			;5332	ff 	. 
	rst 38h			;5333	ff 	. 
	rst 38h			;5334	ff 	. 
	rst 38h			;5335	ff 	. 
	rst 38h			;5336	ff 	. 
	rst 38h			;5337	ff 	. 
	rst 38h			;5338	ff 	. 
	rst 38h			;5339	ff 	. 
	rst 38h			;533a	ff 	. 
	rst 38h			;533b	ff 	. 
	rst 38h			;533c	ff 	. 
	rst 38h			;533d	ff 	. 
	rst 38h			;533e	ff 	. 
	rst 38h			;533f	ff 	. 
	rst 38h			;5340	ff 	. 
	rst 38h			;5341	ff 	. 
	rst 38h			;5342	ff 	. 
	rst 38h			;5343	ff 	. 
	rst 38h			;5344	ff 	. 
	rst 38h			;5345	ff 	. 
	rst 38h			;5346	ff 	. 
	rst 38h			;5347	ff 	. 
	rst 38h			;5348	ff 	. 
	rst 38h			;5349	ff 	. 
	rst 38h			;534a	ff 	. 
	rst 38h			;534b	ff 	. 
	rst 38h			;534c	ff 	. 
	rst 38h			;534d	ff 	. 
	rst 38h			;534e	ff 	. 
	rst 38h			;534f	ff 	. 
	rst 38h			;5350	ff 	. 
	rst 38h			;5351	ff 	. 
	rst 38h			;5352	ff 	. 
	rst 38h			;5353	ff 	. 
	rst 38h			;5354	ff 	. 
	rst 38h			;5355	ff 	. 
	rst 38h			;5356	ff 	. 
	rst 38h			;5357	ff 	. 
	rst 38h			;5358	ff 	. 
	rst 38h			;5359	ff 	. 
	rst 38h			;535a	ff 	. 
	rst 38h			;535b	ff 	. 
	rst 38h			;535c	ff 	. 
	rst 38h			;535d	ff 	. 
	rst 38h			;535e	ff 	. 
	rst 38h			;535f	ff 	. 
	rst 38h			;5360	ff 	. 
	rst 38h			;5361	ff 	. 
	rst 38h			;5362	ff 	. 
	rst 38h			;5363	ff 	. 
	rst 38h			;5364	ff 	. 
	rst 38h			;5365	ff 	. 
	rst 38h			;5366	ff 	. 
	rst 38h			;5367	ff 	. 
	rst 38h			;5368	ff 	. 
	rst 38h			;5369	ff 	. 
	rst 38h			;536a	ff 	. 
	rst 38h			;536b	ff 	. 
	rst 38h			;536c	ff 	. 
	rst 38h			;536d	ff 	. 
	rst 38h			;536e	ff 	. 
	rst 38h			;536f	ff 	. 
	rst 38h			;5370	ff 	. 
	rst 38h			;5371	ff 	. 
	rst 38h			;5372	ff 	. 
	rst 38h			;5373	ff 	. 
	rst 38h			;5374	ff 	. 
	rst 38h			;5375	ff 	. 
	rst 38h			;5376	ff 	. 
	rst 38h			;5377	ff 	. 
	rst 38h			;5378	ff 	. 
	rst 38h			;5379	ff 	. 
	rst 38h			;537a	ff 	. 
	rst 38h			;537b	ff 	. 
	rst 38h			;537c	ff 	. 
	rst 38h			;537d	ff 	. 
	rst 38h			;537e	ff 	. 
	rst 38h			;537f	ff 	. 
	rst 38h			;5380	ff 	. 
	rst 38h			;5381	ff 	. 
	rst 38h			;5382	ff 	. 
	rst 38h			;5383	ff 	. 
	rst 38h			;5384	ff 	. 
	rst 38h			;5385	ff 	. 
	rst 38h			;5386	ff 	. 
	rst 38h			;5387	ff 	. 
	rst 38h			;5388	ff 	. 
	rst 38h			;5389	ff 	. 
	rst 38h			;538a	ff 	. 
	rst 38h			;538b	ff 	. 
	rst 38h			;538c	ff 	. 
	rst 38h			;538d	ff 	. 
	rst 38h			;538e	ff 	. 
	rst 38h			;538f	ff 	. 
	rst 38h			;5390	ff 	. 
	rst 38h			;5391	ff 	. 
	rst 38h			;5392	ff 	. 
	rst 38h			;5393	ff 	. 
	rst 38h			;5394	ff 	. 
	rst 38h			;5395	ff 	. 
	rst 38h			;5396	ff 	. 
	rst 38h			;5397	ff 	. 
	rst 38h			;5398	ff 	. 
	rst 38h			;5399	ff 	. 
	rst 38h			;539a	ff 	. 
	rst 38h			;539b	ff 	. 
	rst 38h			;539c	ff 	. 
	rst 38h			;539d	ff 	. 
	rst 38h			;539e	ff 	. 
	rst 38h			;539f	ff 	. 
	rst 38h			;53a0	ff 	. 
	rst 38h			;53a1	ff 	. 
	rst 38h			;53a2	ff 	. 
	rst 38h			;53a3	ff 	. 
	rst 38h			;53a4	ff 	. 
	rst 38h			;53a5	ff 	. 
	rst 38h			;53a6	ff 	. 
	rst 38h			;53a7	ff 	. 
	rst 38h			;53a8	ff 	. 
	rst 38h			;53a9	ff 	. 
	rst 38h			;53aa	ff 	. 
	rst 38h			;53ab	ff 	. 
	rst 38h			;53ac	ff 	. 
	rst 38h			;53ad	ff 	. 
	rst 38h			;53ae	ff 	. 
	rst 38h			;53af	ff 	. 
	rst 38h			;53b0	ff 	. 
	rst 38h			;53b1	ff 	. 
	rst 38h			;53b2	ff 	. 
	rst 38h			;53b3	ff 	. 
	rst 38h			;53b4	ff 	. 
	rst 38h			;53b5	ff 	. 
	rst 38h			;53b6	ff 	. 
	rst 38h			;53b7	ff 	. 
	rst 38h			;53b8	ff 	. 
	rst 38h			;53b9	ff 	. 
	rst 38h			;53ba	ff 	. 
	rst 38h			;53bb	ff 	. 
	rst 38h			;53bc	ff 	. 
	rst 38h			;53bd	ff 	. 
	rst 38h			;53be	ff 	. 
	rst 38h			;53bf	ff 	. 
	rst 38h			;53c0	ff 	. 
	rst 38h			;53c1	ff 	. 
	rst 38h			;53c2	ff 	. 
	rst 38h			;53c3	ff 	. 
	rst 38h			;53c4	ff 	. 
	rst 38h			;53c5	ff 	. 
	rst 38h			;53c6	ff 	. 
	rst 38h			;53c7	ff 	. 
	rst 38h			;53c8	ff 	. 
	rst 38h			;53c9	ff 	. 
	rst 38h			;53ca	ff 	. 
	rst 38h			;53cb	ff 	. 
	rst 38h			;53cc	ff 	. 
	rst 38h			;53cd	ff 	. 
	rst 38h			;53ce	ff 	. 
	rst 38h			;53cf	ff 	. 
	rst 38h			;53d0	ff 	. 
	rst 38h			;53d1	ff 	. 
	rst 38h			;53d2	ff 	. 
	rst 38h			;53d3	ff 	. 
	rst 38h			;53d4	ff 	. 
	rst 38h			;53d5	ff 	. 
	rst 38h			;53d6	ff 	. 
	rst 38h			;53d7	ff 	. 
	rst 38h			;53d8	ff 	. 
	rst 38h			;53d9	ff 	. 
	rst 38h			;53da	ff 	. 
	rst 38h			;53db	ff 	. 
	rst 38h			;53dc	ff 	. 
	rst 38h			;53dd	ff 	. 
	rst 38h			;53de	ff 	. 
	rst 38h			;53df	ff 	. 
	rst 38h			;53e0	ff 	. 
	rst 38h			;53e1	ff 	. 
	rst 38h			;53e2	ff 	. 
	rst 38h			;53e3	ff 	. 
	rst 38h			;53e4	ff 	. 
	rst 38h			;53e5	ff 	. 
	rst 38h			;53e6	ff 	. 
	rst 38h			;53e7	ff 	. 
	rst 38h			;53e8	ff 	. 
	rst 38h			;53e9	ff 	. 
	rst 38h			;53ea	ff 	. 
	rst 38h			;53eb	ff 	. 
	rst 38h			;53ec	ff 	. 
	rst 38h			;53ed	ff 	. 
	rst 38h			;53ee	ff 	. 
	rst 38h			;53ef	ff 	. 
	rst 38h			;53f0	ff 	. 
	rst 38h			;53f1	ff 	. 
	rst 38h			;53f2	ff 	. 
	rst 38h			;53f3	ff 	. 
	rst 38h			;53f4	ff 	. 
	rst 38h			;53f5	ff 	. 
	rst 38h			;53f6	ff 	. 
	rst 38h			;53f7	ff 	. 
	rst 38h			;53f8	ff 	. 
	rst 38h			;53f9	ff 	. 
	rst 38h			;53fa	ff 	. 
	rst 38h			;53fb	ff 	. 
	rst 38h			;53fc	ff 	. 
	rst 38h			;53fd	ff 	. 
	rst 38h			;53fe	ff 	. 
	rst 38h			;53ff	ff 	. 
	rst 38h			;5400	ff 	. 
	rst 38h			;5401	ff 	. 
	rst 38h			;5402	ff 	. 
	rst 38h			;5403	ff 	. 
	rst 38h			;5404	ff 	. 
	rst 38h			;5405	ff 	. 
	rst 38h			;5406	ff 	. 
	rst 38h			;5407	ff 	. 
	rst 38h			;5408	ff 	. 
	rst 38h			;5409	ff 	. 
	rst 38h			;540a	ff 	. 
	rst 38h			;540b	ff 	. 
	rst 38h			;540c	ff 	. 
	rst 38h			;540d	ff 	. 
	rst 38h			;540e	ff 	. 
	rst 38h			;540f	ff 	. 
	rst 38h			;5410	ff 	. 
	rst 38h			;5411	ff 	. 
	rst 38h			;5412	ff 	. 
	rst 38h			;5413	ff 	. 
	rst 38h			;5414	ff 	. 
	rst 38h			;5415	ff 	. 
	rst 38h			;5416	ff 	. 
	rst 38h			;5417	ff 	. 
	rst 38h			;5418	ff 	. 
	rst 38h			;5419	ff 	. 
	rst 38h			;541a	ff 	. 
	rst 38h			;541b	ff 	. 
	rst 38h			;541c	ff 	. 
	rst 38h			;541d	ff 	. 
	rst 38h			;541e	ff 	. 
	rst 38h			;541f	ff 	. 
	rst 38h			;5420	ff 	. 
	rst 38h			;5421	ff 	. 
	rst 38h			;5422	ff 	. 
	rst 38h			;5423	ff 	. 
	rst 38h			;5424	ff 	. 
	rst 38h			;5425	ff 	. 
	rst 38h			;5426	ff 	. 
	rst 38h			;5427	ff 	. 
	rst 38h			;5428	ff 	. 
	rst 38h			;5429	ff 	. 
	rst 38h			;542a	ff 	. 
	rst 38h			;542b	ff 	. 
	rst 38h			;542c	ff 	. 
	rst 38h			;542d	ff 	. 
	rst 38h			;542e	ff 	. 
	rst 38h			;542f	ff 	. 
	rst 38h			;5430	ff 	. 
	rst 38h			;5431	ff 	. 
	rst 38h			;5432	ff 	. 
	rst 38h			;5433	ff 	. 
	rst 38h			;5434	ff 	. 
	rst 38h			;5435	ff 	. 
	rst 38h			;5436	ff 	. 
	rst 38h			;5437	ff 	. 
	rst 38h			;5438	ff 	. 
	rst 38h			;5439	ff 	. 
	rst 38h			;543a	ff 	. 
	rst 38h			;543b	ff 	. 
	rst 38h			;543c	ff 	. 
	rst 38h			;543d	ff 	. 
	rst 38h			;543e	ff 	. 
	rst 38h			;543f	ff 	. 
	rst 38h			;5440	ff 	. 
	rst 38h			;5441	ff 	. 
	rst 38h			;5442	ff 	. 
	rst 38h			;5443	ff 	. 
	rst 38h			;5444	ff 	. 
	rst 38h			;5445	ff 	. 
	rst 38h			;5446	ff 	. 
	rst 38h			;5447	ff 	. 
	rst 38h			;5448	ff 	. 
	rst 38h			;5449	ff 	. 
	rst 38h			;544a	ff 	. 
	rst 38h			;544b	ff 	. 
	rst 38h			;544c	ff 	. 
	rst 38h			;544d	ff 	. 
	rst 38h			;544e	ff 	. 
	rst 38h			;544f	ff 	. 
	rst 38h			;5450	ff 	. 
	rst 38h			;5451	ff 	. 
	rst 38h			;5452	ff 	. 
	rst 38h			;5453	ff 	. 
	rst 38h			;5454	ff 	. 
	rst 38h			;5455	ff 	. 
	rst 38h			;5456	ff 	. 
	rst 38h			;5457	ff 	. 
	rst 38h			;5458	ff 	. 
	rst 38h			;5459	ff 	. 
	rst 38h			;545a	ff 	. 
	rst 38h			;545b	ff 	. 
	rst 38h			;545c	ff 	. 
	rst 38h			;545d	ff 	. 
	rst 38h			;545e	ff 	. 
	rst 38h			;545f	ff 	. 
	rst 38h			;5460	ff 	. 
	rst 38h			;5461	ff 	. 
	rst 38h			;5462	ff 	. 
	rst 38h			;5463	ff 	. 
	rst 38h			;5464	ff 	. 
	rst 38h			;5465	ff 	. 
	rst 38h			;5466	ff 	. 
	rst 38h			;5467	ff 	. 
	rst 38h			;5468	ff 	. 
	rst 38h			;5469	ff 	. 
	rst 38h			;546a	ff 	. 
	rst 38h			;546b	ff 	. 
	rst 38h			;546c	ff 	. 
	rst 38h			;546d	ff 	. 
	rst 38h			;546e	ff 	. 
	rst 38h			;546f	ff 	. 
	rst 38h			;5470	ff 	. 
	rst 38h			;5471	ff 	. 
	rst 38h			;5472	ff 	. 
	rst 38h			;5473	ff 	. 
	rst 38h			;5474	ff 	. 
	rst 38h			;5475	ff 	. 
	rst 38h			;5476	ff 	. 
	rst 38h			;5477	ff 	. 
	rst 38h			;5478	ff 	. 
	rst 38h			;5479	ff 	. 
	rst 38h			;547a	ff 	. 
	rst 38h			;547b	ff 	. 
	rst 38h			;547c	ff 	. 
	rst 38h			;547d	ff 	. 
	rst 38h			;547e	ff 	. 
	rst 38h			;547f	ff 	. 
	rst 38h			;5480	ff 	. 
	rst 38h			;5481	ff 	. 
	rst 38h			;5482	ff 	. 
	rst 38h			;5483	ff 	. 
	rst 38h			;5484	ff 	. 
	rst 38h			;5485	ff 	. 
	rst 38h			;5486	ff 	. 
	rst 38h			;5487	ff 	. 
	rst 38h			;5488	ff 	. 
	rst 38h			;5489	ff 	. 
	rst 38h			;548a	ff 	. 
	rst 38h			;548b	ff 	. 
	rst 38h			;548c	ff 	. 
	rst 38h			;548d	ff 	. 
	rst 38h			;548e	ff 	. 
	rst 38h			;548f	ff 	. 
	rst 38h			;5490	ff 	. 
	rst 38h			;5491	ff 	. 
	rst 38h			;5492	ff 	. 
	rst 38h			;5493	ff 	. 
	rst 38h			;5494	ff 	. 
	rst 38h			;5495	ff 	. 
	rst 38h			;5496	ff 	. 
	rst 38h			;5497	ff 	. 
	rst 38h			;5498	ff 	. 
	rst 38h			;5499	ff 	. 
	rst 38h			;549a	ff 	. 
	rst 38h			;549b	ff 	. 
	rst 38h			;549c	ff 	. 
	rst 38h			;549d	ff 	. 
	rst 38h			;549e	ff 	. 
	rst 38h			;549f	ff 	. 
	rst 38h			;54a0	ff 	. 
	rst 38h			;54a1	ff 	. 
	rst 38h			;54a2	ff 	. 
	rst 38h			;54a3	ff 	. 
	rst 38h			;54a4	ff 	. 
	rst 38h			;54a5	ff 	. 
	rst 38h			;54a6	ff 	. 
	rst 38h			;54a7	ff 	. 
	rst 38h			;54a8	ff 	. 
	rst 38h			;54a9	ff 	. 
	rst 38h			;54aa	ff 	. 
	rst 38h			;54ab	ff 	. 
	rst 38h			;54ac	ff 	. 
	rst 38h			;54ad	ff 	. 
	rst 38h			;54ae	ff 	. 
	rst 38h			;54af	ff 	. 
	rst 38h			;54b0	ff 	. 
	rst 38h			;54b1	ff 	. 
	rst 38h			;54b2	ff 	. 
	rst 38h			;54b3	ff 	. 
	rst 38h			;54b4	ff 	. 
	rst 38h			;54b5	ff 	. 
	rst 38h			;54b6	ff 	. 
	rst 38h			;54b7	ff 	. 
	rst 38h			;54b8	ff 	. 
	rst 38h			;54b9	ff 	. 
	rst 38h			;54ba	ff 	. 
	rst 38h			;54bb	ff 	. 
	rst 38h			;54bc	ff 	. 
	rst 38h			;54bd	ff 	. 
	rst 38h			;54be	ff 	. 
	rst 38h			;54bf	ff 	. 
	rst 38h			;54c0	ff 	. 
	rst 38h			;54c1	ff 	. 
	rst 38h			;54c2	ff 	. 
	rst 38h			;54c3	ff 	. 
	rst 38h			;54c4	ff 	. 
	rst 38h			;54c5	ff 	. 
	rst 38h			;54c6	ff 	. 
	rst 38h			;54c7	ff 	. 
	rst 38h			;54c8	ff 	. 
	rst 38h			;54c9	ff 	. 
	rst 38h			;54ca	ff 	. 
	rst 38h			;54cb	ff 	. 
	rst 38h			;54cc	ff 	. 
	rst 38h			;54cd	ff 	. 
	rst 38h			;54ce	ff 	. 
	rst 38h			;54cf	ff 	. 
	rst 38h			;54d0	ff 	. 
	rst 38h			;54d1	ff 	. 
	rst 38h			;54d2	ff 	. 
	rst 38h			;54d3	ff 	. 
	rst 38h			;54d4	ff 	. 
	rst 38h			;54d5	ff 	. 
	rst 38h			;54d6	ff 	. 
	rst 38h			;54d7	ff 	. 
	rst 38h			;54d8	ff 	. 
	rst 38h			;54d9	ff 	. 
	rst 38h			;54da	ff 	. 
	rst 38h			;54db	ff 	. 
	rst 38h			;54dc	ff 	. 
	rst 38h			;54dd	ff 	. 
	rst 38h			;54de	ff 	. 
	rst 38h			;54df	ff 	. 
	rst 38h			;54e0	ff 	. 
	rst 38h			;54e1	ff 	. 
	rst 38h			;54e2	ff 	. 
	rst 38h			;54e3	ff 	. 
	rst 38h			;54e4	ff 	. 
	rst 38h			;54e5	ff 	. 
	rst 38h			;54e6	ff 	. 
	rst 38h			;54e7	ff 	. 
	rst 38h			;54e8	ff 	. 
	rst 38h			;54e9	ff 	. 
	rst 38h			;54ea	ff 	. 
	rst 38h			;54eb	ff 	. 
	rst 38h			;54ec	ff 	. 
	rst 38h			;54ed	ff 	. 
	rst 38h			;54ee	ff 	. 
	rst 38h			;54ef	ff 	. 
	rst 38h			;54f0	ff 	. 
	rst 38h			;54f1	ff 	. 
	rst 38h			;54f2	ff 	. 
	rst 38h			;54f3	ff 	. 
	rst 38h			;54f4	ff 	. 
	rst 38h			;54f5	ff 	. 
	rst 38h			;54f6	ff 	. 
	rst 38h			;54f7	ff 	. 
	rst 38h			;54f8	ff 	. 
	rst 38h			;54f9	ff 	. 
	rst 38h			;54fa	ff 	. 
	rst 38h			;54fb	ff 	. 
	rst 38h			;54fc	ff 	. 
	rst 38h			;54fd	ff 	. 
	rst 38h			;54fe	ff 	. 
	rst 38h			;54ff	ff 	. 
	rst 38h			;5500	ff 	. 
	rst 38h			;5501	ff 	. 
	rst 38h			;5502	ff 	. 
	rst 38h			;5503	ff 	. 
	rst 38h			;5504	ff 	. 
	rst 38h			;5505	ff 	. 
	rst 38h			;5506	ff 	. 
	rst 38h			;5507	ff 	. 
	rst 38h			;5508	ff 	. 
	rst 38h			;5509	ff 	. 
	rst 38h			;550a	ff 	. 
	rst 38h			;550b	ff 	. 
	rst 38h			;550c	ff 	. 
	rst 38h			;550d	ff 	. 
	rst 38h			;550e	ff 	. 
	rst 38h			;550f	ff 	. 
	rst 38h			;5510	ff 	. 
	rst 38h			;5511	ff 	. 
	rst 38h			;5512	ff 	. 
	rst 38h			;5513	ff 	. 
	rst 38h			;5514	ff 	. 
	rst 38h			;5515	ff 	. 
	rst 38h			;5516	ff 	. 
	rst 38h			;5517	ff 	. 
	rst 38h			;5518	ff 	. 
	rst 38h			;5519	ff 	. 
	rst 38h			;551a	ff 	. 
	rst 38h			;551b	ff 	. 
	rst 38h			;551c	ff 	. 
	rst 38h			;551d	ff 	. 
	rst 38h			;551e	ff 	. 
	rst 38h			;551f	ff 	. 
	rst 38h			;5520	ff 	. 
	rst 38h			;5521	ff 	. 
	rst 38h			;5522	ff 	. 
	rst 38h			;5523	ff 	. 
	rst 38h			;5524	ff 	. 
	rst 38h			;5525	ff 	. 
	rst 38h			;5526	ff 	. 
	rst 38h			;5527	ff 	. 
	rst 38h			;5528	ff 	. 
	rst 38h			;5529	ff 	. 
	rst 38h			;552a	ff 	. 
	rst 38h			;552b	ff 	. 
	rst 38h			;552c	ff 	. 
	rst 38h			;552d	ff 	. 
	rst 38h			;552e	ff 	. 
	rst 38h			;552f	ff 	. 
	rst 38h			;5530	ff 	. 
	rst 38h			;5531	ff 	. 
	rst 38h			;5532	ff 	. 
	rst 38h			;5533	ff 	. 
	rst 38h			;5534	ff 	. 
	rst 38h			;5535	ff 	. 
	rst 38h			;5536	ff 	. 
	rst 38h			;5537	ff 	. 
	rst 38h			;5538	ff 	. 
	rst 38h			;5539	ff 	. 
	rst 38h			;553a	ff 	. 
	rst 38h			;553b	ff 	. 
	rst 38h			;553c	ff 	. 
	rst 38h			;553d	ff 	. 
	rst 38h			;553e	ff 	. 
	rst 38h			;553f	ff 	. 
	rst 38h			;5540	ff 	. 
	rst 38h			;5541	ff 	. 
	rst 38h			;5542	ff 	. 
	rst 38h			;5543	ff 	. 
	rst 38h			;5544	ff 	. 
	rst 38h			;5545	ff 	. 
	rst 38h			;5546	ff 	. 
	rst 38h			;5547	ff 	. 
	rst 38h			;5548	ff 	. 
	rst 38h			;5549	ff 	. 
	rst 38h			;554a	ff 	. 
	rst 38h			;554b	ff 	. 
	rst 38h			;554c	ff 	. 
	rst 38h			;554d	ff 	. 
	rst 38h			;554e	ff 	. 
	rst 38h			;554f	ff 	. 
	rst 38h			;5550	ff 	. 
	rst 38h			;5551	ff 	. 
	rst 38h			;5552	ff 	. 
	rst 38h			;5553	ff 	. 
	rst 38h			;5554	ff 	. 
	rst 38h			;5555	ff 	. 
	rst 38h			;5556	ff 	. 
	rst 38h			;5557	ff 	. 
	rst 38h			;5558	ff 	. 
	rst 38h			;5559	ff 	. 
	rst 38h			;555a	ff 	. 
	rst 38h			;555b	ff 	. 
	rst 38h			;555c	ff 	. 
	rst 38h			;555d	ff 	. 
	rst 38h			;555e	ff 	. 
	rst 38h			;555f	ff 	. 
	rst 38h			;5560	ff 	. 
	rst 38h			;5561	ff 	. 
	rst 38h			;5562	ff 	. 
	rst 38h			;5563	ff 	. 
	rst 38h			;5564	ff 	. 
	rst 38h			;5565	ff 	. 
	rst 38h			;5566	ff 	. 
	rst 38h			;5567	ff 	. 
	rst 38h			;5568	ff 	. 
	rst 38h			;5569	ff 	. 
	rst 38h			;556a	ff 	. 
	rst 38h			;556b	ff 	. 
	rst 38h			;556c	ff 	. 
	rst 38h			;556d	ff 	. 
	rst 38h			;556e	ff 	. 
	rst 38h			;556f	ff 	. 
	rst 38h			;5570	ff 	. 
	rst 38h			;5571	ff 	. 
	rst 38h			;5572	ff 	. 
	rst 38h			;5573	ff 	. 
	rst 38h			;5574	ff 	. 
	rst 38h			;5575	ff 	. 
	rst 38h			;5576	ff 	. 
	rst 38h			;5577	ff 	. 
	rst 38h			;5578	ff 	. 
	rst 38h			;5579	ff 	. 
	rst 38h			;557a	ff 	. 
	rst 38h			;557b	ff 	. 
	rst 38h			;557c	ff 	. 
	rst 38h			;557d	ff 	. 
	rst 38h			;557e	ff 	. 
	rst 38h			;557f	ff 	. 
	rst 38h			;5580	ff 	. 
	rst 38h			;5581	ff 	. 
	rst 38h			;5582	ff 	. 
	rst 38h			;5583	ff 	. 
	rst 38h			;5584	ff 	. 
	rst 38h			;5585	ff 	. 
	rst 38h			;5586	ff 	. 
	rst 38h			;5587	ff 	. 
	rst 38h			;5588	ff 	. 
	rst 38h			;5589	ff 	. 
	rst 38h			;558a	ff 	. 
	rst 38h			;558b	ff 	. 
	rst 38h			;558c	ff 	. 
	rst 38h			;558d	ff 	. 
	rst 38h			;558e	ff 	. 
	rst 38h			;558f	ff 	. 
	rst 38h			;5590	ff 	. 
	rst 38h			;5591	ff 	. 
	rst 38h			;5592	ff 	. 
	rst 38h			;5593	ff 	. 
	rst 38h			;5594	ff 	. 
	rst 38h			;5595	ff 	. 
	rst 38h			;5596	ff 	. 
	rst 38h			;5597	ff 	. 
	rst 38h			;5598	ff 	. 
	rst 38h			;5599	ff 	. 
	rst 38h			;559a	ff 	. 
	rst 38h			;559b	ff 	. 
	rst 38h			;559c	ff 	. 
	rst 38h			;559d	ff 	. 
	rst 38h			;559e	ff 	. 
	rst 38h			;559f	ff 	. 
	rst 38h			;55a0	ff 	. 
	rst 38h			;55a1	ff 	. 
	rst 38h			;55a2	ff 	. 
	rst 38h			;55a3	ff 	. 
	rst 38h			;55a4	ff 	. 
	rst 38h			;55a5	ff 	. 
	rst 38h			;55a6	ff 	. 
	rst 38h			;55a7	ff 	. 
	rst 38h			;55a8	ff 	. 
	rst 38h			;55a9	ff 	. 
	rst 38h			;55aa	ff 	. 
	rst 38h			;55ab	ff 	. 
	rst 38h			;55ac	ff 	. 
	rst 38h			;55ad	ff 	. 
	rst 38h			;55ae	ff 	. 
	rst 38h			;55af	ff 	. 
	rst 38h			;55b0	ff 	. 
	rst 38h			;55b1	ff 	. 
	rst 38h			;55b2	ff 	. 
	rst 38h			;55b3	ff 	. 
	rst 38h			;55b4	ff 	. 
	rst 38h			;55b5	ff 	. 
	rst 38h			;55b6	ff 	. 
	rst 38h			;55b7	ff 	. 
	rst 38h			;55b8	ff 	. 
	rst 38h			;55b9	ff 	. 
	rst 38h			;55ba	ff 	. 
	rst 38h			;55bb	ff 	. 
	rst 38h			;55bc	ff 	. 
	rst 38h			;55bd	ff 	. 
	rst 38h			;55be	ff 	. 
	rst 38h			;55bf	ff 	. 
	rst 38h			;55c0	ff 	. 
	rst 38h			;55c1	ff 	. 
	rst 38h			;55c2	ff 	. 
	rst 38h			;55c3	ff 	. 
	rst 38h			;55c4	ff 	. 
	rst 38h			;55c5	ff 	. 
	rst 38h			;55c6	ff 	. 
	rst 38h			;55c7	ff 	. 
	rst 38h			;55c8	ff 	. 
	rst 38h			;55c9	ff 	. 
	rst 38h			;55ca	ff 	. 
	rst 38h			;55cb	ff 	. 
	rst 38h			;55cc	ff 	. 
	rst 38h			;55cd	ff 	. 
	rst 38h			;55ce	ff 	. 
	rst 38h			;55cf	ff 	. 
	rst 38h			;55d0	ff 	. 
	rst 38h			;55d1	ff 	. 
	rst 38h			;55d2	ff 	. 
	rst 38h			;55d3	ff 	. 
	rst 38h			;55d4	ff 	. 
	rst 38h			;55d5	ff 	. 
	rst 38h			;55d6	ff 	. 
	rst 38h			;55d7	ff 	. 
	rst 38h			;55d8	ff 	. 
	rst 38h			;55d9	ff 	. 
	rst 38h			;55da	ff 	. 
	rst 38h			;55db	ff 	. 
	rst 38h			;55dc	ff 	. 
	rst 38h			;55dd	ff 	. 
	rst 38h			;55de	ff 	. 
	rst 38h			;55df	ff 	. 
	rst 38h			;55e0	ff 	. 
	rst 38h			;55e1	ff 	. 
	rst 38h			;55e2	ff 	. 
	rst 38h			;55e3	ff 	. 
	rst 38h			;55e4	ff 	. 
	rst 38h			;55e5	ff 	. 
	rst 38h			;55e6	ff 	. 
	rst 38h			;55e7	ff 	. 
	rst 38h			;55e8	ff 	. 
	rst 38h			;55e9	ff 	. 
	rst 38h			;55ea	ff 	. 
	rst 38h			;55eb	ff 	. 
	rst 38h			;55ec	ff 	. 
	rst 38h			;55ed	ff 	. 
	rst 38h			;55ee	ff 	. 
	rst 38h			;55ef	ff 	. 
	rst 38h			;55f0	ff 	. 
	rst 38h			;55f1	ff 	. 
	rst 38h			;55f2	ff 	. 
	rst 38h			;55f3	ff 	. 
	rst 38h			;55f4	ff 	. 
	rst 38h			;55f5	ff 	. 
	rst 38h			;55f6	ff 	. 
	rst 38h			;55f7	ff 	. 
	rst 38h			;55f8	ff 	. 
	rst 38h			;55f9	ff 	. 
	rst 38h			;55fa	ff 	. 
	rst 38h			;55fb	ff 	. 
	rst 38h			;55fc	ff 	. 
	rst 38h			;55fd	ff 	. 
	rst 38h			;55fe	ff 	. 
	rst 38h			;55ff	ff 	. 
	rst 38h			;5600	ff 	. 
	rst 38h			;5601	ff 	. 
	rst 38h			;5602	ff 	. 
	rst 38h			;5603	ff 	. 
	rst 38h			;5604	ff 	. 
	rst 38h			;5605	ff 	. 
	rst 38h			;5606	ff 	. 
	rst 38h			;5607	ff 	. 
	rst 38h			;5608	ff 	. 
	rst 38h			;5609	ff 	. 
	rst 38h			;560a	ff 	. 
	rst 38h			;560b	ff 	. 
	rst 38h			;560c	ff 	. 
	rst 38h			;560d	ff 	. 
	rst 38h			;560e	ff 	. 
	rst 38h			;560f	ff 	. 
	rst 38h			;5610	ff 	. 
	rst 38h			;5611	ff 	. 
	rst 38h			;5612	ff 	. 
	rst 38h			;5613	ff 	. 
	rst 38h			;5614	ff 	. 
	rst 38h			;5615	ff 	. 
	rst 38h			;5616	ff 	. 
	rst 38h			;5617	ff 	. 
	rst 38h			;5618	ff 	. 
	rst 38h			;5619	ff 	. 
	rst 38h			;561a	ff 	. 
	rst 38h			;561b	ff 	. 
	rst 38h			;561c	ff 	. 
	rst 38h			;561d	ff 	. 
	rst 38h			;561e	ff 	. 
	rst 38h			;561f	ff 	. 
	rst 38h			;5620	ff 	. 
	rst 38h			;5621	ff 	. 
	rst 38h			;5622	ff 	. 
	rst 38h			;5623	ff 	. 
	rst 38h			;5624	ff 	. 
	rst 38h			;5625	ff 	. 
	rst 38h			;5626	ff 	. 
	rst 38h			;5627	ff 	. 
	rst 38h			;5628	ff 	. 
	rst 38h			;5629	ff 	. 
	rst 38h			;562a	ff 	. 
	rst 38h			;562b	ff 	. 
	rst 38h			;562c	ff 	. 
	rst 38h			;562d	ff 	. 
	rst 38h			;562e	ff 	. 
	rst 38h			;562f	ff 	. 
	rst 38h			;5630	ff 	. 
	rst 38h			;5631	ff 	. 
	rst 38h			;5632	ff 	. 
	rst 38h			;5633	ff 	. 
	rst 38h			;5634	ff 	. 
	rst 38h			;5635	ff 	. 
	rst 38h			;5636	ff 	. 
	rst 38h			;5637	ff 	. 
	rst 38h			;5638	ff 	. 
	rst 38h			;5639	ff 	. 
	rst 38h			;563a	ff 	. 
	rst 38h			;563b	ff 	. 
	rst 38h			;563c	ff 	. 
	rst 38h			;563d	ff 	. 
	rst 38h			;563e	ff 	. 
	rst 38h			;563f	ff 	. 
	rst 38h			;5640	ff 	. 
	rst 38h			;5641	ff 	. 
	rst 38h			;5642	ff 	. 
	rst 38h			;5643	ff 	. 
	rst 38h			;5644	ff 	. 
	rst 38h			;5645	ff 	. 
	rst 38h			;5646	ff 	. 
	rst 38h			;5647	ff 	. 
	rst 38h			;5648	ff 	. 
	rst 38h			;5649	ff 	. 
	rst 38h			;564a	ff 	. 
	rst 38h			;564b	ff 	. 
	rst 38h			;564c	ff 	. 
	rst 38h			;564d	ff 	. 
	rst 38h			;564e	ff 	. 
	rst 38h			;564f	ff 	. 
	rst 38h			;5650	ff 	. 
	rst 38h			;5651	ff 	. 
	rst 38h			;5652	ff 	. 
	rst 38h			;5653	ff 	. 
	rst 38h			;5654	ff 	. 
	rst 38h			;5655	ff 	. 
	rst 38h			;5656	ff 	. 
	rst 38h			;5657	ff 	. 
	rst 38h			;5658	ff 	. 
	rst 38h			;5659	ff 	. 
	rst 38h			;565a	ff 	. 
	rst 38h			;565b	ff 	. 
	rst 38h			;565c	ff 	. 
	rst 38h			;565d	ff 	. 
	rst 38h			;565e	ff 	. 
	rst 38h			;565f	ff 	. 
	rst 38h			;5660	ff 	. 
	rst 38h			;5661	ff 	. 
	rst 38h			;5662	ff 	. 
	rst 38h			;5663	ff 	. 
	rst 38h			;5664	ff 	. 
	rst 38h			;5665	ff 	. 
	rst 38h			;5666	ff 	. 
	rst 38h			;5667	ff 	. 
	rst 38h			;5668	ff 	. 
	rst 38h			;5669	ff 	. 
	rst 38h			;566a	ff 	. 
	rst 38h			;566b	ff 	. 
	rst 38h			;566c	ff 	. 
	rst 38h			;566d	ff 	. 
	rst 38h			;566e	ff 	. 
	rst 38h			;566f	ff 	. 
	rst 38h			;5670	ff 	. 
	rst 38h			;5671	ff 	. 
	rst 38h			;5672	ff 	. 
	rst 38h			;5673	ff 	. 
	rst 38h			;5674	ff 	. 
	rst 38h			;5675	ff 	. 
	rst 38h			;5676	ff 	. 
	rst 38h			;5677	ff 	. 
	rst 38h			;5678	ff 	. 
	rst 38h			;5679	ff 	. 
	rst 38h			;567a	ff 	. 
	rst 38h			;567b	ff 	. 
	rst 38h			;567c	ff 	. 
	rst 38h			;567d	ff 	. 
	rst 38h			;567e	ff 	. 
	rst 38h			;567f	ff 	. 
	rst 38h			;5680	ff 	. 
	rst 38h			;5681	ff 	. 
	rst 38h			;5682	ff 	. 
	rst 38h			;5683	ff 	. 
	rst 38h			;5684	ff 	. 
	rst 38h			;5685	ff 	. 
	rst 38h			;5686	ff 	. 
	rst 38h			;5687	ff 	. 
	rst 38h			;5688	ff 	. 
	rst 38h			;5689	ff 	. 
	rst 38h			;568a	ff 	. 
	rst 38h			;568b	ff 	. 
	rst 38h			;568c	ff 	. 
	rst 38h			;568d	ff 	. 
	rst 38h			;568e	ff 	. 
	rst 38h			;568f	ff 	. 
	rst 38h			;5690	ff 	. 
	rst 38h			;5691	ff 	. 
	rst 38h			;5692	ff 	. 
	rst 38h			;5693	ff 	. 
	rst 38h			;5694	ff 	. 
	rst 38h			;5695	ff 	. 
	rst 38h			;5696	ff 	. 
	rst 38h			;5697	ff 	. 
	rst 38h			;5698	ff 	. 
	rst 38h			;5699	ff 	. 
	rst 38h			;569a	ff 	. 
	rst 38h			;569b	ff 	. 
	rst 38h			;569c	ff 	. 
	rst 38h			;569d	ff 	. 
	rst 38h			;569e	ff 	. 
	rst 38h			;569f	ff 	. 
	rst 38h			;56a0	ff 	. 
	rst 38h			;56a1	ff 	. 
	rst 38h			;56a2	ff 	. 
	rst 38h			;56a3	ff 	. 
	rst 38h			;56a4	ff 	. 
	rst 38h			;56a5	ff 	. 
	rst 38h			;56a6	ff 	. 
	rst 38h			;56a7	ff 	. 
	rst 38h			;56a8	ff 	. 
	rst 38h			;56a9	ff 	. 
	rst 38h			;56aa	ff 	. 
	rst 38h			;56ab	ff 	. 
	rst 38h			;56ac	ff 	. 
	rst 38h			;56ad	ff 	. 
	rst 38h			;56ae	ff 	. 
	rst 38h			;56af	ff 	. 
	rst 38h			;56b0	ff 	. 
	rst 38h			;56b1	ff 	. 
	rst 38h			;56b2	ff 	. 
	rst 38h			;56b3	ff 	. 
	rst 38h			;56b4	ff 	. 
	rst 38h			;56b5	ff 	. 
	rst 38h			;56b6	ff 	. 
	rst 38h			;56b7	ff 	. 
	rst 38h			;56b8	ff 	. 
	rst 38h			;56b9	ff 	. 
	rst 38h			;56ba	ff 	. 
	rst 38h			;56bb	ff 	. 
	rst 38h			;56bc	ff 	. 
	rst 38h			;56bd	ff 	. 
	rst 38h			;56be	ff 	. 
	rst 38h			;56bf	ff 	. 
	rst 38h			;56c0	ff 	. 
	rst 38h			;56c1	ff 	. 
	rst 38h			;56c2	ff 	. 
	rst 38h			;56c3	ff 	. 
	rst 38h			;56c4	ff 	. 
	rst 38h			;56c5	ff 	. 
	rst 38h			;56c6	ff 	. 
	rst 38h			;56c7	ff 	. 
	rst 38h			;56c8	ff 	. 
	rst 38h			;56c9	ff 	. 
	rst 38h			;56ca	ff 	. 
	rst 38h			;56cb	ff 	. 
	rst 38h			;56cc	ff 	. 
	rst 38h			;56cd	ff 	. 
	rst 38h			;56ce	ff 	. 
	rst 38h			;56cf	ff 	. 
	rst 38h			;56d0	ff 	. 
	rst 38h			;56d1	ff 	. 
	rst 38h			;56d2	ff 	. 
	rst 38h			;56d3	ff 	. 
	rst 38h			;56d4	ff 	. 
	rst 38h			;56d5	ff 	. 
	rst 38h			;56d6	ff 	. 
	rst 38h			;56d7	ff 	. 
	rst 38h			;56d8	ff 	. 
	rst 38h			;56d9	ff 	. 
	rst 38h			;56da	ff 	. 
	rst 38h			;56db	ff 	. 
	rst 38h			;56dc	ff 	. 
	rst 38h			;56dd	ff 	. 
	rst 38h			;56de	ff 	. 
	rst 38h			;56df	ff 	. 
	rst 38h			;56e0	ff 	. 
	rst 38h			;56e1	ff 	. 
	rst 38h			;56e2	ff 	. 
	rst 38h			;56e3	ff 	. 
	rst 38h			;56e4	ff 	. 
	rst 38h			;56e5	ff 	. 
	rst 38h			;56e6	ff 	. 
	rst 38h			;56e7	ff 	. 
	rst 38h			;56e8	ff 	. 
	rst 38h			;56e9	ff 	. 
	rst 38h			;56ea	ff 	. 
	rst 38h			;56eb	ff 	. 
	rst 38h			;56ec	ff 	. 
	rst 38h			;56ed	ff 	. 
	rst 38h			;56ee	ff 	. 
	rst 38h			;56ef	ff 	. 
	rst 38h			;56f0	ff 	. 
	rst 38h			;56f1	ff 	. 
	rst 38h			;56f2	ff 	. 
	rst 38h			;56f3	ff 	. 
	rst 38h			;56f4	ff 	. 
	rst 38h			;56f5	ff 	. 
	rst 38h			;56f6	ff 	. 
	rst 38h			;56f7	ff 	. 
	rst 38h			;56f8	ff 	. 
	rst 38h			;56f9	ff 	. 
	rst 38h			;56fa	ff 	. 
	rst 38h			;56fb	ff 	. 
	rst 38h			;56fc	ff 	. 
	rst 38h			;56fd	ff 	. 
	rst 38h			;56fe	ff 	. 
	rst 38h			;56ff	ff 	. 
	rst 38h			;5700	ff 	. 
	rst 38h			;5701	ff 	. 
	rst 38h			;5702	ff 	. 
	rst 38h			;5703	ff 	. 
	rst 38h			;5704	ff 	. 
	rst 38h			;5705	ff 	. 
	rst 38h			;5706	ff 	. 
	rst 38h			;5707	ff 	. 
	rst 38h			;5708	ff 	. 
	rst 38h			;5709	ff 	. 
	rst 38h			;570a	ff 	. 
	rst 38h			;570b	ff 	. 
	rst 38h			;570c	ff 	. 
	rst 38h			;570d	ff 	. 
	rst 38h			;570e	ff 	. 
	rst 38h			;570f	ff 	. 
	rst 38h			;5710	ff 	. 
	rst 38h			;5711	ff 	. 
	rst 38h			;5712	ff 	. 
	rst 38h			;5713	ff 	. 
	rst 38h			;5714	ff 	. 
	rst 38h			;5715	ff 	. 
	rst 38h			;5716	ff 	. 
	rst 38h			;5717	ff 	. 
	rst 38h			;5718	ff 	. 
	rst 38h			;5719	ff 	. 
	rst 38h			;571a	ff 	. 
	rst 38h			;571b	ff 	. 
	rst 38h			;571c	ff 	. 
	rst 38h			;571d	ff 	. 
	rst 38h			;571e	ff 	. 
	rst 38h			;571f	ff 	. 
	rst 38h			;5720	ff 	. 
	rst 38h			;5721	ff 	. 
	rst 38h			;5722	ff 	. 
	rst 38h			;5723	ff 	. 
	rst 38h			;5724	ff 	. 
	rst 38h			;5725	ff 	. 
	rst 38h			;5726	ff 	. 
	rst 38h			;5727	ff 	. 
	rst 38h			;5728	ff 	. 
	rst 38h			;5729	ff 	. 
	rst 38h			;572a	ff 	. 
	rst 38h			;572b	ff 	. 
	rst 38h			;572c	ff 	. 
	rst 38h			;572d	ff 	. 
	rst 38h			;572e	ff 	. 
	rst 38h			;572f	ff 	. 
	rst 38h			;5730	ff 	. 
	rst 38h			;5731	ff 	. 
	rst 38h			;5732	ff 	. 
	rst 38h			;5733	ff 	. 
	rst 38h			;5734	ff 	. 
	rst 38h			;5735	ff 	. 
	rst 38h			;5736	ff 	. 
	rst 38h			;5737	ff 	. 
	rst 38h			;5738	ff 	. 
	rst 38h			;5739	ff 	. 
	rst 38h			;573a	ff 	. 
	rst 38h			;573b	ff 	. 
	rst 38h			;573c	ff 	. 
	rst 38h			;573d	ff 	. 
	rst 38h			;573e	ff 	. 
	rst 38h			;573f	ff 	. 
	rst 38h			;5740	ff 	. 
	rst 38h			;5741	ff 	. 
	rst 38h			;5742	ff 	. 
	rst 38h			;5743	ff 	. 
	rst 38h			;5744	ff 	. 
	rst 38h			;5745	ff 	. 
	rst 38h			;5746	ff 	. 
	rst 38h			;5747	ff 	. 
	rst 38h			;5748	ff 	. 
	rst 38h			;5749	ff 	. 
	rst 38h			;574a	ff 	. 
	rst 38h			;574b	ff 	. 
	rst 38h			;574c	ff 	. 
	rst 38h			;574d	ff 	. 
	rst 38h			;574e	ff 	. 
	rst 38h			;574f	ff 	. 
	rst 38h			;5750	ff 	. 
	rst 38h			;5751	ff 	. 
	rst 38h			;5752	ff 	. 
	rst 38h			;5753	ff 	. 
	rst 38h			;5754	ff 	. 
	rst 38h			;5755	ff 	. 
	rst 38h			;5756	ff 	. 
	rst 38h			;5757	ff 	. 
	rst 38h			;5758	ff 	. 
	rst 38h			;5759	ff 	. 
	rst 38h			;575a	ff 	. 
	rst 38h			;575b	ff 	. 
	rst 38h			;575c	ff 	. 
	rst 38h			;575d	ff 	. 
	rst 38h			;575e	ff 	. 
	rst 38h			;575f	ff 	. 
	rst 38h			;5760	ff 	. 
	rst 38h			;5761	ff 	. 
	rst 38h			;5762	ff 	. 
	rst 38h			;5763	ff 	. 
	rst 38h			;5764	ff 	. 
	rst 38h			;5765	ff 	. 
	rst 38h			;5766	ff 	. 
	rst 38h			;5767	ff 	. 
	rst 38h			;5768	ff 	. 
	rst 38h			;5769	ff 	. 
	rst 38h			;576a	ff 	. 
	rst 38h			;576b	ff 	. 
	rst 38h			;576c	ff 	. 
	rst 38h			;576d	ff 	. 
	rst 38h			;576e	ff 	. 
	rst 38h			;576f	ff 	. 
	rst 38h			;5770	ff 	. 
	rst 38h			;5771	ff 	. 
	rst 38h			;5772	ff 	. 
	rst 38h			;5773	ff 	. 
	rst 38h			;5774	ff 	. 
	rst 38h			;5775	ff 	. 
	rst 38h			;5776	ff 	. 
	rst 38h			;5777	ff 	. 
	rst 38h			;5778	ff 	. 
	rst 38h			;5779	ff 	. 
	rst 38h			;577a	ff 	. 
	rst 38h			;577b	ff 	. 
	rst 38h			;577c	ff 	. 
	rst 38h			;577d	ff 	. 
	rst 38h			;577e	ff 	. 
	rst 38h			;577f	ff 	. 
	rst 38h			;5780	ff 	. 
	rst 38h			;5781	ff 	. 
	rst 38h			;5782	ff 	. 
	rst 38h			;5783	ff 	. 
	rst 38h			;5784	ff 	. 
	rst 38h			;5785	ff 	. 
	rst 38h			;5786	ff 	. 
	rst 38h			;5787	ff 	. 
	rst 38h			;5788	ff 	. 
	rst 38h			;5789	ff 	. 
	rst 38h			;578a	ff 	. 
	rst 38h			;578b	ff 	. 
	rst 38h			;578c	ff 	. 
	rst 38h			;578d	ff 	. 
	rst 38h			;578e	ff 	. 
	rst 38h			;578f	ff 	. 
	rst 38h			;5790	ff 	. 
	rst 38h			;5791	ff 	. 
	rst 38h			;5792	ff 	. 
	rst 38h			;5793	ff 	. 
	rst 38h			;5794	ff 	. 
	rst 38h			;5795	ff 	. 
	rst 38h			;5796	ff 	. 
	rst 38h			;5797	ff 	. 
	rst 38h			;5798	ff 	. 
	rst 38h			;5799	ff 	. 
	rst 38h			;579a	ff 	. 
	rst 38h			;579b	ff 	. 
	rst 38h			;579c	ff 	. 
	rst 38h			;579d	ff 	. 
	rst 38h			;579e	ff 	. 
	rst 38h			;579f	ff 	. 
	rst 38h			;57a0	ff 	. 
	rst 38h			;57a1	ff 	. 
	rst 38h			;57a2	ff 	. 
	rst 38h			;57a3	ff 	. 
	rst 38h			;57a4	ff 	. 
	rst 38h			;57a5	ff 	. 
	rst 38h			;57a6	ff 	. 
	rst 38h			;57a7	ff 	. 
	rst 38h			;57a8	ff 	. 
	rst 38h			;57a9	ff 	. 
	rst 38h			;57aa	ff 	. 
	rst 38h			;57ab	ff 	. 
	rst 38h			;57ac	ff 	. 
	rst 38h			;57ad	ff 	. 
	rst 38h			;57ae	ff 	. 
	rst 38h			;57af	ff 	. 
	rst 38h			;57b0	ff 	. 
	rst 38h			;57b1	ff 	. 
	rst 38h			;57b2	ff 	. 
	rst 38h			;57b3	ff 	. 
	rst 38h			;57b4	ff 	. 
	rst 38h			;57b5	ff 	. 
	rst 38h			;57b6	ff 	. 
	rst 38h			;57b7	ff 	. 
	rst 38h			;57b8	ff 	. 
	rst 38h			;57b9	ff 	. 
	rst 38h			;57ba	ff 	. 
	rst 38h			;57bb	ff 	. 
	rst 38h			;57bc	ff 	. 
	rst 38h			;57bd	ff 	. 
	rst 38h			;57be	ff 	. 
	rst 38h			;57bf	ff 	. 
	rst 38h			;57c0	ff 	. 
	rst 38h			;57c1	ff 	. 
	rst 38h			;57c2	ff 	. 
	rst 38h			;57c3	ff 	. 
	rst 38h			;57c4	ff 	. 
	rst 38h			;57c5	ff 	. 
	rst 38h			;57c6	ff 	. 
	rst 38h			;57c7	ff 	. 
	rst 38h			;57c8	ff 	. 
	rst 38h			;57c9	ff 	. 
	rst 38h			;57ca	ff 	. 
	rst 38h			;57cb	ff 	. 
	rst 38h			;57cc	ff 	. 
	rst 38h			;57cd	ff 	. 
	rst 38h			;57ce	ff 	. 
	rst 38h			;57cf	ff 	. 
	rst 38h			;57d0	ff 	. 
	rst 38h			;57d1	ff 	. 
	rst 38h			;57d2	ff 	. 
	rst 38h			;57d3	ff 	. 
	rst 38h			;57d4	ff 	. 
	rst 38h			;57d5	ff 	. 
	rst 38h			;57d6	ff 	. 
	rst 38h			;57d7	ff 	. 
	rst 38h			;57d8	ff 	. 
	rst 38h			;57d9	ff 	. 
	rst 38h			;57da	ff 	. 
	rst 38h			;57db	ff 	. 
	rst 38h			;57dc	ff 	. 
	rst 38h			;57dd	ff 	. 
	rst 38h			;57de	ff 	. 
	rst 38h			;57df	ff 	. 
	rst 38h			;57e0	ff 	. 
	rst 38h			;57e1	ff 	. 
	rst 38h			;57e2	ff 	. 
	rst 38h			;57e3	ff 	. 
	rst 38h			;57e4	ff 	. 
	rst 38h			;57e5	ff 	. 
	rst 38h			;57e6	ff 	. 
	rst 38h			;57e7	ff 	. 
	rst 38h			;57e8	ff 	. 
	rst 38h			;57e9	ff 	. 
	rst 38h			;57ea	ff 	. 
	rst 38h			;57eb	ff 	. 
	rst 38h			;57ec	ff 	. 
	rst 38h			;57ed	ff 	. 
	rst 38h			;57ee	ff 	. 
	rst 38h			;57ef	ff 	. 
	rst 38h			;57f0	ff 	. 
	rst 38h			;57f1	ff 	. 
	rst 38h			;57f2	ff 	. 
	rst 38h			;57f3	ff 	. 
	rst 38h			;57f4	ff 	. 
	rst 38h			;57f5	ff 	. 
	rst 38h			;57f6	ff 	. 
	rst 38h			;57f7	ff 	. 
	rst 38h			;57f8	ff 	. 
	rst 38h			;57f9	ff 	. 
	rst 38h			;57fa	ff 	. 
	rst 38h			;57fb	ff 	. 
	rst 38h			;57fc	ff 	. 
	rst 38h			;57fd	ff 	. 
	rst 38h			;57fe	ff 	. 
	rst 38h			;57ff	ff 	. 
	rst 38h			;5800	ff 	. 
	rst 38h			;5801	ff 	. 
	rst 38h			;5802	ff 	. 
	rst 38h			;5803	ff 	. 
	rst 38h			;5804	ff 	. 
	rst 38h			;5805	ff 	. 
	rst 38h			;5806	ff 	. 
	rst 38h			;5807	ff 	. 
	rst 38h			;5808	ff 	. 
	rst 38h			;5809	ff 	. 
	rst 38h			;580a	ff 	. 
	rst 38h			;580b	ff 	. 
	rst 38h			;580c	ff 	. 
	rst 38h			;580d	ff 	. 
	rst 38h			;580e	ff 	. 
	rst 38h			;580f	ff 	. 
	rst 38h			;5810	ff 	. 
	rst 38h			;5811	ff 	. 
	rst 38h			;5812	ff 	. 
	rst 38h			;5813	ff 	. 
	rst 38h			;5814	ff 	. 
	rst 38h			;5815	ff 	. 
	rst 38h			;5816	ff 	. 
	rst 38h			;5817	ff 	. 
	rst 38h			;5818	ff 	. 
	rst 38h			;5819	ff 	. 
	rst 38h			;581a	ff 	. 
	rst 38h			;581b	ff 	. 
	rst 38h			;581c	ff 	. 
	rst 38h			;581d	ff 	. 
	rst 38h			;581e	ff 	. 
	rst 38h			;581f	ff 	. 
	rst 38h			;5820	ff 	. 
	rst 38h			;5821	ff 	. 
	rst 38h			;5822	ff 	. 
	rst 38h			;5823	ff 	. 
	rst 38h			;5824	ff 	. 
	rst 38h			;5825	ff 	. 
	rst 38h			;5826	ff 	. 
	rst 38h			;5827	ff 	. 
	rst 38h			;5828	ff 	. 
	rst 38h			;5829	ff 	. 
	rst 38h			;582a	ff 	. 
	rst 38h			;582b	ff 	. 
	rst 38h			;582c	ff 	. 
	rst 38h			;582d	ff 	. 
	rst 38h			;582e	ff 	. 
	rst 38h			;582f	ff 	. 
	rst 38h			;5830	ff 	. 
	rst 38h			;5831	ff 	. 
	rst 38h			;5832	ff 	. 
	rst 38h			;5833	ff 	. 
	rst 38h			;5834	ff 	. 
	rst 38h			;5835	ff 	. 
	rst 38h			;5836	ff 	. 
	rst 38h			;5837	ff 	. 
	rst 38h			;5838	ff 	. 
	rst 38h			;5839	ff 	. 
	rst 38h			;583a	ff 	. 
	rst 38h			;583b	ff 	. 
	rst 38h			;583c	ff 	. 
	rst 38h			;583d	ff 	. 
	rst 38h			;583e	ff 	. 
	rst 38h			;583f	ff 	. 
	rst 38h			;5840	ff 	. 
	rst 38h			;5841	ff 	. 
	rst 38h			;5842	ff 	. 
	rst 38h			;5843	ff 	. 
	rst 38h			;5844	ff 	. 
	rst 38h			;5845	ff 	. 
	rst 38h			;5846	ff 	. 
	rst 38h			;5847	ff 	. 
	rst 38h			;5848	ff 	. 
	rst 38h			;5849	ff 	. 
	rst 38h			;584a	ff 	. 
	rst 38h			;584b	ff 	. 
	rst 38h			;584c	ff 	. 
	rst 38h			;584d	ff 	. 
	rst 38h			;584e	ff 	. 
	rst 38h			;584f	ff 	. 
	rst 38h			;5850	ff 	. 
	rst 38h			;5851	ff 	. 
	rst 38h			;5852	ff 	. 
	rst 38h			;5853	ff 	. 
	rst 38h			;5854	ff 	. 
	rst 38h			;5855	ff 	. 
	rst 38h			;5856	ff 	. 
	rst 38h			;5857	ff 	. 
	rst 38h			;5858	ff 	. 
	rst 38h			;5859	ff 	. 
	rst 38h			;585a	ff 	. 
	rst 38h			;585b	ff 	. 
	rst 38h			;585c	ff 	. 
	rst 38h			;585d	ff 	. 
	rst 38h			;585e	ff 	. 
	rst 38h			;585f	ff 	. 
	rst 38h			;5860	ff 	. 
	rst 38h			;5861	ff 	. 
	rst 38h			;5862	ff 	. 
	rst 38h			;5863	ff 	. 
	rst 38h			;5864	ff 	. 
	rst 38h			;5865	ff 	. 
	rst 38h			;5866	ff 	. 
	rst 38h			;5867	ff 	. 
	rst 38h			;5868	ff 	. 
	rst 38h			;5869	ff 	. 
	rst 38h			;586a	ff 	. 
	rst 38h			;586b	ff 	. 
	rst 38h			;586c	ff 	. 
	rst 38h			;586d	ff 	. 
	rst 38h			;586e	ff 	. 
	rst 38h			;586f	ff 	. 
	rst 38h			;5870	ff 	. 
	rst 38h			;5871	ff 	. 
	rst 38h			;5872	ff 	. 
	rst 38h			;5873	ff 	. 
	rst 38h			;5874	ff 	. 
	rst 38h			;5875	ff 	. 
	rst 38h			;5876	ff 	. 
	rst 38h			;5877	ff 	. 
	rst 38h			;5878	ff 	. 
	rst 38h			;5879	ff 	. 
	rst 38h			;587a	ff 	. 
	rst 38h			;587b	ff 	. 
	rst 38h			;587c	ff 	. 
	rst 38h			;587d	ff 	. 
	rst 38h			;587e	ff 	. 
	rst 38h			;587f	ff 	. 
	rst 38h			;5880	ff 	. 
	rst 38h			;5881	ff 	. 
	rst 38h			;5882	ff 	. 
	rst 38h			;5883	ff 	. 
	rst 38h			;5884	ff 	. 
	rst 38h			;5885	ff 	. 
	rst 38h			;5886	ff 	. 
	rst 38h			;5887	ff 	. 
	rst 38h			;5888	ff 	. 
	rst 38h			;5889	ff 	. 
	rst 38h			;588a	ff 	. 
	rst 38h			;588b	ff 	. 
	rst 38h			;588c	ff 	. 
	rst 38h			;588d	ff 	. 
	rst 38h			;588e	ff 	. 
	rst 38h			;588f	ff 	. 
	rst 38h			;5890	ff 	. 
	rst 38h			;5891	ff 	. 
	rst 38h			;5892	ff 	. 
	rst 38h			;5893	ff 	. 
	rst 38h			;5894	ff 	. 
	rst 38h			;5895	ff 	. 
	rst 38h			;5896	ff 	. 
	rst 38h			;5897	ff 	. 
	rst 38h			;5898	ff 	. 
	rst 38h			;5899	ff 	. 
	rst 38h			;589a	ff 	. 
	rst 38h			;589b	ff 	. 
	rst 38h			;589c	ff 	. 
	rst 38h			;589d	ff 	. 
	rst 38h			;589e	ff 	. 
	rst 38h			;589f	ff 	. 
	rst 38h			;58a0	ff 	. 
	rst 38h			;58a1	ff 	. 
	rst 38h			;58a2	ff 	. 
	rst 38h			;58a3	ff 	. 
	rst 38h			;58a4	ff 	. 
	rst 38h			;58a5	ff 	. 
	rst 38h			;58a6	ff 	. 
	rst 38h			;58a7	ff 	. 
	rst 38h			;58a8	ff 	. 
	rst 38h			;58a9	ff 	. 
	rst 38h			;58aa	ff 	. 
	rst 38h			;58ab	ff 	. 
	rst 38h			;58ac	ff 	. 
	rst 38h			;58ad	ff 	. 
	rst 38h			;58ae	ff 	. 
	rst 38h			;58af	ff 	. 
	rst 38h			;58b0	ff 	. 
	rst 38h			;58b1	ff 	. 
	rst 38h			;58b2	ff 	. 
	rst 38h			;58b3	ff 	. 
	rst 38h			;58b4	ff 	. 
	rst 38h			;58b5	ff 	. 
	rst 38h			;58b6	ff 	. 
	rst 38h			;58b7	ff 	. 
	rst 38h			;58b8	ff 	. 
	rst 38h			;58b9	ff 	. 
	rst 38h			;58ba	ff 	. 
	rst 38h			;58bb	ff 	. 
	rst 38h			;58bc	ff 	. 
	rst 38h			;58bd	ff 	. 
	rst 38h			;58be	ff 	. 
	rst 38h			;58bf	ff 	. 
	rst 38h			;58c0	ff 	. 
	rst 38h			;58c1	ff 	. 
	rst 38h			;58c2	ff 	. 
	rst 38h			;58c3	ff 	. 
	rst 38h			;58c4	ff 	. 
	rst 38h			;58c5	ff 	. 
	rst 38h			;58c6	ff 	. 
	rst 38h			;58c7	ff 	. 
	rst 38h			;58c8	ff 	. 
	rst 38h			;58c9	ff 	. 
	rst 38h			;58ca	ff 	. 
	rst 38h			;58cb	ff 	. 
	rst 38h			;58cc	ff 	. 
	rst 38h			;58cd	ff 	. 
	rst 38h			;58ce	ff 	. 
	rst 38h			;58cf	ff 	. 
	rst 38h			;58d0	ff 	. 
	rst 38h			;58d1	ff 	. 
	rst 38h			;58d2	ff 	. 
	rst 38h			;58d3	ff 	. 
	rst 38h			;58d4	ff 	. 
	rst 38h			;58d5	ff 	. 
	rst 38h			;58d6	ff 	. 
	rst 38h			;58d7	ff 	. 
	rst 38h			;58d8	ff 	. 
	rst 38h			;58d9	ff 	. 
	rst 38h			;58da	ff 	. 
	rst 38h			;58db	ff 	. 
	rst 38h			;58dc	ff 	. 
	rst 38h			;58dd	ff 	. 
	rst 38h			;58de	ff 	. 
	rst 38h			;58df	ff 	. 
	rst 38h			;58e0	ff 	. 
	rst 38h			;58e1	ff 	. 
	rst 38h			;58e2	ff 	. 
	rst 38h			;58e3	ff 	. 
	rst 38h			;58e4	ff 	. 
	rst 38h			;58e5	ff 	. 
	rst 38h			;58e6	ff 	. 
	rst 38h			;58e7	ff 	. 
	rst 38h			;58e8	ff 	. 
	rst 38h			;58e9	ff 	. 
	rst 38h			;58ea	ff 	. 
	rst 38h			;58eb	ff 	. 
	rst 38h			;58ec	ff 	. 
	rst 38h			;58ed	ff 	. 
	rst 38h			;58ee	ff 	. 
	rst 38h			;58ef	ff 	. 
	rst 38h			;58f0	ff 	. 
	rst 38h			;58f1	ff 	. 
	rst 38h			;58f2	ff 	. 
	rst 38h			;58f3	ff 	. 
	rst 38h			;58f4	ff 	. 
	rst 38h			;58f5	ff 	. 
	rst 38h			;58f6	ff 	. 
	rst 38h			;58f7	ff 	. 
	rst 38h			;58f8	ff 	. 
	rst 38h			;58f9	ff 	. 
	rst 38h			;58fa	ff 	. 
	rst 38h			;58fb	ff 	. 
	rst 38h			;58fc	ff 	. 
	rst 38h			;58fd	ff 	. 
	rst 38h			;58fe	ff 	. 
	rst 38h			;58ff	ff 	. 
	rst 38h			;5900	ff 	. 
	rst 38h			;5901	ff 	. 
	rst 38h			;5902	ff 	. 
	rst 38h			;5903	ff 	. 
	rst 38h			;5904	ff 	. 
	rst 38h			;5905	ff 	. 
	rst 38h			;5906	ff 	. 
	rst 38h			;5907	ff 	. 
	rst 38h			;5908	ff 	. 
	rst 38h			;5909	ff 	. 
	rst 38h			;590a	ff 	. 
	rst 38h			;590b	ff 	. 
	rst 38h			;590c	ff 	. 
	rst 38h			;590d	ff 	. 
	rst 38h			;590e	ff 	. 
	rst 38h			;590f	ff 	. 
	rst 38h			;5910	ff 	. 
	rst 38h			;5911	ff 	. 
	rst 38h			;5912	ff 	. 
	rst 38h			;5913	ff 	. 
	rst 38h			;5914	ff 	. 
	rst 38h			;5915	ff 	. 
	rst 38h			;5916	ff 	. 
	rst 38h			;5917	ff 	. 
	rst 38h			;5918	ff 	. 
	rst 38h			;5919	ff 	. 
	rst 38h			;591a	ff 	. 
	rst 38h			;591b	ff 	. 
	rst 38h			;591c	ff 	. 
	rst 38h			;591d	ff 	. 
	rst 38h			;591e	ff 	. 
	rst 38h			;591f	ff 	. 
	rst 38h			;5920	ff 	. 
	rst 38h			;5921	ff 	. 
	rst 38h			;5922	ff 	. 
	rst 38h			;5923	ff 	. 
	rst 38h			;5924	ff 	. 
	rst 38h			;5925	ff 	. 
	rst 38h			;5926	ff 	. 
	rst 38h			;5927	ff 	. 
	rst 38h			;5928	ff 	. 
	rst 38h			;5929	ff 	. 
	rst 38h			;592a	ff 	. 
	rst 38h			;592b	ff 	. 
	rst 38h			;592c	ff 	. 
	rst 38h			;592d	ff 	. 
	rst 38h			;592e	ff 	. 
	rst 38h			;592f	ff 	. 
	rst 38h			;5930	ff 	. 
	rst 38h			;5931	ff 	. 
	rst 38h			;5932	ff 	. 
	rst 38h			;5933	ff 	. 
	rst 38h			;5934	ff 	. 
	rst 38h			;5935	ff 	. 
	rst 38h			;5936	ff 	. 
	rst 38h			;5937	ff 	. 
	rst 38h			;5938	ff 	. 
	rst 38h			;5939	ff 	. 
	rst 38h			;593a	ff 	. 
	rst 38h			;593b	ff 	. 
	rst 38h			;593c	ff 	. 
	rst 38h			;593d	ff 	. 
	rst 38h			;593e	ff 	. 
	rst 38h			;593f	ff 	. 
	rst 38h			;5940	ff 	. 
	rst 38h			;5941	ff 	. 
	rst 38h			;5942	ff 	. 
	rst 38h			;5943	ff 	. 
	rst 38h			;5944	ff 	. 
	rst 38h			;5945	ff 	. 
	rst 38h			;5946	ff 	. 
	rst 38h			;5947	ff 	. 
	rst 38h			;5948	ff 	. 
	rst 38h			;5949	ff 	. 
	rst 38h			;594a	ff 	. 
	rst 38h			;594b	ff 	. 
	rst 38h			;594c	ff 	. 
	rst 38h			;594d	ff 	. 
	rst 38h			;594e	ff 	. 
	rst 38h			;594f	ff 	. 
	rst 38h			;5950	ff 	. 
	rst 38h			;5951	ff 	. 
	rst 38h			;5952	ff 	. 
	rst 38h			;5953	ff 	. 
	rst 38h			;5954	ff 	. 
	rst 38h			;5955	ff 	. 
	rst 38h			;5956	ff 	. 
	rst 38h			;5957	ff 	. 
	rst 38h			;5958	ff 	. 
	rst 38h			;5959	ff 	. 
	rst 38h			;595a	ff 	. 
	rst 38h			;595b	ff 	. 
	rst 38h			;595c	ff 	. 
	rst 38h			;595d	ff 	. 
	rst 38h			;595e	ff 	. 
	rst 38h			;595f	ff 	. 
	rst 38h			;5960	ff 	. 
	rst 38h			;5961	ff 	. 
	rst 38h			;5962	ff 	. 
	rst 38h			;5963	ff 	. 
	rst 38h			;5964	ff 	. 
	rst 38h			;5965	ff 	. 
	rst 38h			;5966	ff 	. 
	rst 38h			;5967	ff 	. 
	rst 38h			;5968	ff 	. 
	rst 38h			;5969	ff 	. 
	rst 38h			;596a	ff 	. 
	rst 38h			;596b	ff 	. 
	rst 38h			;596c	ff 	. 
	rst 38h			;596d	ff 	. 
	rst 38h			;596e	ff 	. 
	rst 38h			;596f	ff 	. 
	rst 38h			;5970	ff 	. 
	rst 38h			;5971	ff 	. 
	rst 38h			;5972	ff 	. 
	rst 38h			;5973	ff 	. 
	rst 38h			;5974	ff 	. 
	rst 38h			;5975	ff 	. 
	rst 38h			;5976	ff 	. 
	rst 38h			;5977	ff 	. 
	rst 38h			;5978	ff 	. 
	rst 38h			;5979	ff 	. 
	rst 38h			;597a	ff 	. 
	rst 38h			;597b	ff 	. 
	rst 38h			;597c	ff 	. 
	rst 38h			;597d	ff 	. 
	rst 38h			;597e	ff 	. 
	rst 38h			;597f	ff 	. 
	rst 38h			;5980	ff 	. 
	rst 38h			;5981	ff 	. 
	rst 38h			;5982	ff 	. 
	rst 38h			;5983	ff 	. 
	rst 38h			;5984	ff 	. 
	rst 38h			;5985	ff 	. 
	rst 38h			;5986	ff 	. 
	rst 38h			;5987	ff 	. 
	rst 38h			;5988	ff 	. 
	rst 38h			;5989	ff 	. 
	rst 38h			;598a	ff 	. 
	rst 38h			;598b	ff 	. 
	rst 38h			;598c	ff 	. 
	rst 38h			;598d	ff 	. 
	rst 38h			;598e	ff 	. 
	rst 38h			;598f	ff 	. 
	rst 38h			;5990	ff 	. 
	rst 38h			;5991	ff 	. 
	rst 38h			;5992	ff 	. 
	rst 38h			;5993	ff 	. 
	rst 38h			;5994	ff 	. 
	rst 38h			;5995	ff 	. 
	rst 38h			;5996	ff 	. 
	rst 38h			;5997	ff 	. 
	rst 38h			;5998	ff 	. 
	rst 38h			;5999	ff 	. 
	rst 38h			;599a	ff 	. 
	rst 38h			;599b	ff 	. 
	rst 38h			;599c	ff 	. 
	rst 38h			;599d	ff 	. 
	rst 38h			;599e	ff 	. 
	rst 38h			;599f	ff 	. 
	rst 38h			;59a0	ff 	. 
	rst 38h			;59a1	ff 	. 
	rst 38h			;59a2	ff 	. 
	rst 38h			;59a3	ff 	. 
	rst 38h			;59a4	ff 	. 
	rst 38h			;59a5	ff 	. 
	rst 38h			;59a6	ff 	. 
	rst 38h			;59a7	ff 	. 
	rst 38h			;59a8	ff 	. 
	rst 38h			;59a9	ff 	. 
	rst 38h			;59aa	ff 	. 
	rst 38h			;59ab	ff 	. 
	rst 38h			;59ac	ff 	. 
	rst 38h			;59ad	ff 	. 
	rst 38h			;59ae	ff 	. 
	rst 38h			;59af	ff 	. 
	rst 38h			;59b0	ff 	. 
	rst 38h			;59b1	ff 	. 
	rst 38h			;59b2	ff 	. 
	rst 38h			;59b3	ff 	. 
	rst 38h			;59b4	ff 	. 
	rst 38h			;59b5	ff 	. 
	rst 38h			;59b6	ff 	. 
	rst 38h			;59b7	ff 	. 
	rst 38h			;59b8	ff 	. 
	rst 38h			;59b9	ff 	. 
	rst 38h			;59ba	ff 	. 
	rst 38h			;59bb	ff 	. 
	rst 38h			;59bc	ff 	. 
	rst 38h			;59bd	ff 	. 
	rst 38h			;59be	ff 	. 
	rst 38h			;59bf	ff 	. 
	rst 38h			;59c0	ff 	. 
	rst 38h			;59c1	ff 	. 
	rst 38h			;59c2	ff 	. 
	rst 38h			;59c3	ff 	. 
	rst 38h			;59c4	ff 	. 
	rst 38h			;59c5	ff 	. 
	rst 38h			;59c6	ff 	. 
	rst 38h			;59c7	ff 	. 
	rst 38h			;59c8	ff 	. 
	rst 38h			;59c9	ff 	. 
	rst 38h			;59ca	ff 	. 
	rst 38h			;59cb	ff 	. 
	rst 38h			;59cc	ff 	. 
	rst 38h			;59cd	ff 	. 
	rst 38h			;59ce	ff 	. 
	rst 38h			;59cf	ff 	. 
	rst 38h			;59d0	ff 	. 
	rst 38h			;59d1	ff 	. 
	rst 38h			;59d2	ff 	. 
	rst 38h			;59d3	ff 	. 
	rst 38h			;59d4	ff 	. 
	rst 38h			;59d5	ff 	. 
	rst 38h			;59d6	ff 	. 
	rst 38h			;59d7	ff 	. 
	rst 38h			;59d8	ff 	. 
	rst 38h			;59d9	ff 	. 
	rst 38h			;59da	ff 	. 
	rst 38h			;59db	ff 	. 
	rst 38h			;59dc	ff 	. 
	rst 38h			;59dd	ff 	. 
	rst 38h			;59de	ff 	. 
	rst 38h			;59df	ff 	. 
	rst 38h			;59e0	ff 	. 
	rst 38h			;59e1	ff 	. 
	rst 38h			;59e2	ff 	. 
	rst 38h			;59e3	ff 	. 
	rst 38h			;59e4	ff 	. 
	rst 38h			;59e5	ff 	. 
	rst 38h			;59e6	ff 	. 
	rst 38h			;59e7	ff 	. 
	rst 38h			;59e8	ff 	. 
	rst 38h			;59e9	ff 	. 
	rst 38h			;59ea	ff 	. 
	rst 38h			;59eb	ff 	. 
	rst 38h			;59ec	ff 	. 
	rst 38h			;59ed	ff 	. 
	rst 38h			;59ee	ff 	. 
	rst 38h			;59ef	ff 	. 
	rst 38h			;59f0	ff 	. 
	rst 38h			;59f1	ff 	. 
	rst 38h			;59f2	ff 	. 
	rst 38h			;59f3	ff 	. 
	rst 38h			;59f4	ff 	. 
	rst 38h			;59f5	ff 	. 
	rst 38h			;59f6	ff 	. 
	rst 38h			;59f7	ff 	. 
	rst 38h			;59f8	ff 	. 
	rst 38h			;59f9	ff 	. 
	rst 38h			;59fa	ff 	. 
	rst 38h			;59fb	ff 	. 
	rst 38h			;59fc	ff 	. 
	rst 38h			;59fd	ff 	. 
	rst 38h			;59fe	ff 	. 
	rst 38h			;59ff	ff 	. 
	rst 38h			;5a00	ff 	. 
	rst 38h			;5a01	ff 	. 
	rst 38h			;5a02	ff 	. 
	rst 38h			;5a03	ff 	. 
	rst 38h			;5a04	ff 	. 
	rst 38h			;5a05	ff 	. 
	rst 38h			;5a06	ff 	. 
	rst 38h			;5a07	ff 	. 
	rst 38h			;5a08	ff 	. 
	rst 38h			;5a09	ff 	. 
	rst 38h			;5a0a	ff 	. 
	rst 38h			;5a0b	ff 	. 
	rst 38h			;5a0c	ff 	. 
	rst 38h			;5a0d	ff 	. 
	rst 38h			;5a0e	ff 	. 
	rst 38h			;5a0f	ff 	. 
	rst 38h			;5a10	ff 	. 
	rst 38h			;5a11	ff 	. 
	rst 38h			;5a12	ff 	. 
	rst 38h			;5a13	ff 	. 
	rst 38h			;5a14	ff 	. 
	rst 38h			;5a15	ff 	. 
	rst 38h			;5a16	ff 	. 
	rst 38h			;5a17	ff 	. 
	rst 38h			;5a18	ff 	. 
	rst 38h			;5a19	ff 	. 
	rst 38h			;5a1a	ff 	. 
	rst 38h			;5a1b	ff 	. 
	rst 38h			;5a1c	ff 	. 
	rst 38h			;5a1d	ff 	. 
	rst 38h			;5a1e	ff 	. 
	rst 38h			;5a1f	ff 	. 
	rst 38h			;5a20	ff 	. 
	rst 38h			;5a21	ff 	. 
	rst 38h			;5a22	ff 	. 
	rst 38h			;5a23	ff 	. 
	rst 38h			;5a24	ff 	. 
	rst 38h			;5a25	ff 	. 
	rst 38h			;5a26	ff 	. 
	rst 38h			;5a27	ff 	. 
	rst 38h			;5a28	ff 	. 
	rst 38h			;5a29	ff 	. 
	rst 38h			;5a2a	ff 	. 
	rst 38h			;5a2b	ff 	. 
	rst 38h			;5a2c	ff 	. 
	rst 38h			;5a2d	ff 	. 
	rst 38h			;5a2e	ff 	. 
	rst 38h			;5a2f	ff 	. 
	rst 38h			;5a30	ff 	. 
	rst 38h			;5a31	ff 	. 
	rst 38h			;5a32	ff 	. 
	rst 38h			;5a33	ff 	. 
	rst 38h			;5a34	ff 	. 
	rst 38h			;5a35	ff 	. 
	rst 38h			;5a36	ff 	. 
	rst 38h			;5a37	ff 	. 
	rst 38h			;5a38	ff 	. 
	rst 38h			;5a39	ff 	. 
	rst 38h			;5a3a	ff 	. 
	rst 38h			;5a3b	ff 	. 
	rst 38h			;5a3c	ff 	. 
	rst 38h			;5a3d	ff 	. 
	rst 38h			;5a3e	ff 	. 
	rst 38h			;5a3f	ff 	. 
	rst 38h			;5a40	ff 	. 
	rst 38h			;5a41	ff 	. 
	rst 38h			;5a42	ff 	. 
	rst 38h			;5a43	ff 	. 
	rst 38h			;5a44	ff 	. 
	rst 38h			;5a45	ff 	. 
	rst 38h			;5a46	ff 	. 
	rst 38h			;5a47	ff 	. 
	rst 38h			;5a48	ff 	. 
	rst 38h			;5a49	ff 	. 
	rst 38h			;5a4a	ff 	. 
	rst 38h			;5a4b	ff 	. 
	rst 38h			;5a4c	ff 	. 
	rst 38h			;5a4d	ff 	. 
	rst 38h			;5a4e	ff 	. 
	rst 38h			;5a4f	ff 	. 
	rst 38h			;5a50	ff 	. 
	rst 38h			;5a51	ff 	. 
	rst 38h			;5a52	ff 	. 
	rst 38h			;5a53	ff 	. 
	rst 38h			;5a54	ff 	. 
	rst 38h			;5a55	ff 	. 
	rst 38h			;5a56	ff 	. 
	rst 38h			;5a57	ff 	. 
	rst 38h			;5a58	ff 	. 
	rst 38h			;5a59	ff 	. 
	rst 38h			;5a5a	ff 	. 
	rst 38h			;5a5b	ff 	. 
	rst 38h			;5a5c	ff 	. 
	rst 38h			;5a5d	ff 	. 
	rst 38h			;5a5e	ff 	. 
	rst 38h			;5a5f	ff 	. 
	rst 38h			;5a60	ff 	. 
	rst 38h			;5a61	ff 	. 
	rst 38h			;5a62	ff 	. 
	rst 38h			;5a63	ff 	. 
	rst 38h			;5a64	ff 	. 
	rst 38h			;5a65	ff 	. 
	rst 38h			;5a66	ff 	. 
	rst 38h			;5a67	ff 	. 
	rst 38h			;5a68	ff 	. 
	rst 38h			;5a69	ff 	. 
	rst 38h			;5a6a	ff 	. 
	rst 38h			;5a6b	ff 	. 
	rst 38h			;5a6c	ff 	. 
	rst 38h			;5a6d	ff 	. 
	rst 38h			;5a6e	ff 	. 
	rst 38h			;5a6f	ff 	. 
	rst 38h			;5a70	ff 	. 
	rst 38h			;5a71	ff 	. 
	rst 38h			;5a72	ff 	. 
	rst 38h			;5a73	ff 	. 
	rst 38h			;5a74	ff 	. 
	rst 38h			;5a75	ff 	. 
	rst 38h			;5a76	ff 	. 
	rst 38h			;5a77	ff 	. 
	rst 38h			;5a78	ff 	. 
	rst 38h			;5a79	ff 	. 
	rst 38h			;5a7a	ff 	. 
	rst 38h			;5a7b	ff 	. 
	rst 38h			;5a7c	ff 	. 
	rst 38h			;5a7d	ff 	. 
	rst 38h			;5a7e	ff 	. 
	rst 38h			;5a7f	ff 	. 
	rst 38h			;5a80	ff 	. 
	rst 38h			;5a81	ff 	. 
	rst 38h			;5a82	ff 	. 
	rst 38h			;5a83	ff 	. 
	rst 38h			;5a84	ff 	. 
	rst 38h			;5a85	ff 	. 
	rst 38h			;5a86	ff 	. 
	rst 38h			;5a87	ff 	. 
	rst 38h			;5a88	ff 	. 
	rst 38h			;5a89	ff 	. 
	rst 38h			;5a8a	ff 	. 
	rst 38h			;5a8b	ff 	. 
	rst 38h			;5a8c	ff 	. 
	rst 38h			;5a8d	ff 	. 
	rst 38h			;5a8e	ff 	. 
	rst 38h			;5a8f	ff 	. 
	rst 38h			;5a90	ff 	. 
	rst 38h			;5a91	ff 	. 
	rst 38h			;5a92	ff 	. 
	rst 38h			;5a93	ff 	. 
	rst 38h			;5a94	ff 	. 
	rst 38h			;5a95	ff 	. 
	rst 38h			;5a96	ff 	. 
	rst 38h			;5a97	ff 	. 
	rst 38h			;5a98	ff 	. 
	rst 38h			;5a99	ff 	. 
	rst 38h			;5a9a	ff 	. 
	rst 38h			;5a9b	ff 	. 
	rst 38h			;5a9c	ff 	. 
	rst 38h			;5a9d	ff 	. 
	rst 38h			;5a9e	ff 	. 
	rst 38h			;5a9f	ff 	. 
	rst 38h			;5aa0	ff 	. 
	rst 38h			;5aa1	ff 	. 
	rst 38h			;5aa2	ff 	. 
	rst 38h			;5aa3	ff 	. 
	rst 38h			;5aa4	ff 	. 
	rst 38h			;5aa5	ff 	. 
	rst 38h			;5aa6	ff 	. 
	rst 38h			;5aa7	ff 	. 
	rst 38h			;5aa8	ff 	. 
	rst 38h			;5aa9	ff 	. 
	rst 38h			;5aaa	ff 	. 
	rst 38h			;5aab	ff 	. 
	rst 38h			;5aac	ff 	. 
	rst 38h			;5aad	ff 	. 
	rst 38h			;5aae	ff 	. 
	rst 38h			;5aaf	ff 	. 
	rst 38h			;5ab0	ff 	. 
	rst 38h			;5ab1	ff 	. 
	rst 38h			;5ab2	ff 	. 
	rst 38h			;5ab3	ff 	. 
	rst 38h			;5ab4	ff 	. 
	rst 38h			;5ab5	ff 	. 
	rst 38h			;5ab6	ff 	. 
	rst 38h			;5ab7	ff 	. 
	rst 38h			;5ab8	ff 	. 
	rst 38h			;5ab9	ff 	. 
	rst 38h			;5aba	ff 	. 
	rst 38h			;5abb	ff 	. 
	rst 38h			;5abc	ff 	. 
	rst 38h			;5abd	ff 	. 
	rst 38h			;5abe	ff 	. 
	rst 38h			;5abf	ff 	. 
	rst 38h			;5ac0	ff 	. 
	rst 38h			;5ac1	ff 	. 
	rst 38h			;5ac2	ff 	. 
	rst 38h			;5ac3	ff 	. 
	rst 38h			;5ac4	ff 	. 
	rst 38h			;5ac5	ff 	. 
	rst 38h			;5ac6	ff 	. 
	rst 38h			;5ac7	ff 	. 
	rst 38h			;5ac8	ff 	. 
	rst 38h			;5ac9	ff 	. 
	rst 38h			;5aca	ff 	. 
	rst 38h			;5acb	ff 	. 
	rst 38h			;5acc	ff 	. 
	rst 38h			;5acd	ff 	. 
	rst 38h			;5ace	ff 	. 
	rst 38h			;5acf	ff 	. 
	rst 38h			;5ad0	ff 	. 
	rst 38h			;5ad1	ff 	. 
	rst 38h			;5ad2	ff 	. 
	rst 38h			;5ad3	ff 	. 
	rst 38h			;5ad4	ff 	. 
	rst 38h			;5ad5	ff 	. 
	rst 38h			;5ad6	ff 	. 
	rst 38h			;5ad7	ff 	. 
	rst 38h			;5ad8	ff 	. 
	rst 38h			;5ad9	ff 	. 
	rst 38h			;5ada	ff 	. 
	rst 38h			;5adb	ff 	. 
	rst 38h			;5adc	ff 	. 
	rst 38h			;5add	ff 	. 
	rst 38h			;5ade	ff 	. 
	rst 38h			;5adf	ff 	. 
	rst 38h			;5ae0	ff 	. 
	rst 38h			;5ae1	ff 	. 
	rst 38h			;5ae2	ff 	. 
	rst 38h			;5ae3	ff 	. 
	rst 38h			;5ae4	ff 	. 
	rst 38h			;5ae5	ff 	. 
	rst 38h			;5ae6	ff 	. 
	rst 38h			;5ae7	ff 	. 
	rst 38h			;5ae8	ff 	. 
	rst 38h			;5ae9	ff 	. 
	rst 38h			;5aea	ff 	. 
	rst 38h			;5aeb	ff 	. 
	rst 38h			;5aec	ff 	. 
	rst 38h			;5aed	ff 	. 
	rst 38h			;5aee	ff 	. 
	rst 38h			;5aef	ff 	. 
	rst 38h			;5af0	ff 	. 
	rst 38h			;5af1	ff 	. 
	rst 38h			;5af2	ff 	. 
	rst 38h			;5af3	ff 	. 
	rst 38h			;5af4	ff 	. 
	rst 38h			;5af5	ff 	. 
	rst 38h			;5af6	ff 	. 
	rst 38h			;5af7	ff 	. 
	rst 38h			;5af8	ff 	. 
	rst 38h			;5af9	ff 	. 
	rst 38h			;5afa	ff 	. 
	rst 38h			;5afb	ff 	. 
	rst 38h			;5afc	ff 	. 
	rst 38h			;5afd	ff 	. 
	rst 38h			;5afe	ff 	. 
	rst 38h			;5aff	ff 	. 
	rst 38h			;5b00	ff 	. 
	rst 38h			;5b01	ff 	. 
	rst 38h			;5b02	ff 	. 
	rst 38h			;5b03	ff 	. 
	rst 38h			;5b04	ff 	. 
	rst 38h			;5b05	ff 	. 
	rst 38h			;5b06	ff 	. 
	rst 38h			;5b07	ff 	. 
	rst 38h			;5b08	ff 	. 
	rst 38h			;5b09	ff 	. 
	rst 38h			;5b0a	ff 	. 
	rst 38h			;5b0b	ff 	. 
	rst 38h			;5b0c	ff 	. 
	rst 38h			;5b0d	ff 	. 
	rst 38h			;5b0e	ff 	. 
	rst 38h			;5b0f	ff 	. 
	rst 38h			;5b10	ff 	. 
	rst 38h			;5b11	ff 	. 
	rst 38h			;5b12	ff 	. 
	rst 38h			;5b13	ff 	. 
	rst 38h			;5b14	ff 	. 
	rst 38h			;5b15	ff 	. 
	rst 38h			;5b16	ff 	. 
	rst 38h			;5b17	ff 	. 
	rst 38h			;5b18	ff 	. 
	rst 38h			;5b19	ff 	. 
	rst 38h			;5b1a	ff 	. 
	rst 38h			;5b1b	ff 	. 
	rst 38h			;5b1c	ff 	. 
	rst 38h			;5b1d	ff 	. 
	rst 38h			;5b1e	ff 	. 
	rst 38h			;5b1f	ff 	. 
	rst 38h			;5b20	ff 	. 
	rst 38h			;5b21	ff 	. 
	rst 38h			;5b22	ff 	. 
	rst 38h			;5b23	ff 	. 
	rst 38h			;5b24	ff 	. 
	rst 38h			;5b25	ff 	. 
	rst 38h			;5b26	ff 	. 
	rst 38h			;5b27	ff 	. 
	rst 38h			;5b28	ff 	. 
	rst 38h			;5b29	ff 	. 
	rst 38h			;5b2a	ff 	. 
	rst 38h			;5b2b	ff 	. 
	rst 38h			;5b2c	ff 	. 
	rst 38h			;5b2d	ff 	. 
	rst 38h			;5b2e	ff 	. 
	rst 38h			;5b2f	ff 	. 
	rst 38h			;5b30	ff 	. 
	rst 38h			;5b31	ff 	. 
	rst 38h			;5b32	ff 	. 
	rst 38h			;5b33	ff 	. 
	rst 38h			;5b34	ff 	. 
	rst 38h			;5b35	ff 	. 
	rst 38h			;5b36	ff 	. 
	rst 38h			;5b37	ff 	. 
	rst 38h			;5b38	ff 	. 
	rst 38h			;5b39	ff 	. 
	rst 38h			;5b3a	ff 	. 
	rst 38h			;5b3b	ff 	. 
	rst 38h			;5b3c	ff 	. 
	rst 38h			;5b3d	ff 	. 
	rst 38h			;5b3e	ff 	. 
	rst 38h			;5b3f	ff 	. 
	rst 38h			;5b40	ff 	. 
	rst 38h			;5b41	ff 	. 
	rst 38h			;5b42	ff 	. 
	rst 38h			;5b43	ff 	. 
	rst 38h			;5b44	ff 	. 
	rst 38h			;5b45	ff 	. 
	rst 38h			;5b46	ff 	. 
	rst 38h			;5b47	ff 	. 
	rst 38h			;5b48	ff 	. 
	rst 38h			;5b49	ff 	. 
	rst 38h			;5b4a	ff 	. 
	rst 38h			;5b4b	ff 	. 
	rst 38h			;5b4c	ff 	. 
	rst 38h			;5b4d	ff 	. 
	rst 38h			;5b4e	ff 	. 
	rst 38h			;5b4f	ff 	. 
	rst 38h			;5b50	ff 	. 
	rst 38h			;5b51	ff 	. 
	rst 38h			;5b52	ff 	. 
	rst 38h			;5b53	ff 	. 
	rst 38h			;5b54	ff 	. 
	rst 38h			;5b55	ff 	. 
	rst 38h			;5b56	ff 	. 
	rst 38h			;5b57	ff 	. 
	rst 38h			;5b58	ff 	. 
	rst 38h			;5b59	ff 	. 
	rst 38h			;5b5a	ff 	. 
	rst 38h			;5b5b	ff 	. 
	rst 38h			;5b5c	ff 	. 
	rst 38h			;5b5d	ff 	. 
	rst 38h			;5b5e	ff 	. 
	rst 38h			;5b5f	ff 	. 
	rst 38h			;5b60	ff 	. 
	rst 38h			;5b61	ff 	. 
	rst 38h			;5b62	ff 	. 
	rst 38h			;5b63	ff 	. 
	rst 38h			;5b64	ff 	. 
	rst 38h			;5b65	ff 	. 
	rst 38h			;5b66	ff 	. 
	rst 38h			;5b67	ff 	. 
	rst 38h			;5b68	ff 	. 
	rst 38h			;5b69	ff 	. 
	rst 38h			;5b6a	ff 	. 
	rst 38h			;5b6b	ff 	. 
	rst 38h			;5b6c	ff 	. 
	rst 38h			;5b6d	ff 	. 
	rst 38h			;5b6e	ff 	. 
	rst 38h			;5b6f	ff 	. 
	rst 38h			;5b70	ff 	. 
	rst 38h			;5b71	ff 	. 
	rst 38h			;5b72	ff 	. 
	rst 38h			;5b73	ff 	. 
	rst 38h			;5b74	ff 	. 
	rst 38h			;5b75	ff 	. 
	rst 38h			;5b76	ff 	. 
	rst 38h			;5b77	ff 	. 
	rst 38h			;5b78	ff 	. 
	rst 38h			;5b79	ff 	. 
	rst 38h			;5b7a	ff 	. 
	rst 38h			;5b7b	ff 	. 
	rst 38h			;5b7c	ff 	. 
	rst 38h			;5b7d	ff 	. 
	rst 38h			;5b7e	ff 	. 
	rst 38h			;5b7f	ff 	. 
	rst 38h			;5b80	ff 	. 
	rst 38h			;5b81	ff 	. 
	rst 38h			;5b82	ff 	. 
	rst 38h			;5b83	ff 	. 
	rst 38h			;5b84	ff 	. 
	rst 38h			;5b85	ff 	. 
	rst 38h			;5b86	ff 	. 
	rst 38h			;5b87	ff 	. 
	rst 38h			;5b88	ff 	. 
	rst 38h			;5b89	ff 	. 
	rst 38h			;5b8a	ff 	. 
	rst 38h			;5b8b	ff 	. 
	rst 38h			;5b8c	ff 	. 
	rst 38h			;5b8d	ff 	. 
	rst 38h			;5b8e	ff 	. 
	rst 38h			;5b8f	ff 	. 
	rst 38h			;5b90	ff 	. 
	rst 38h			;5b91	ff 	. 
	rst 38h			;5b92	ff 	. 
	rst 38h			;5b93	ff 	. 
	rst 38h			;5b94	ff 	. 
	rst 38h			;5b95	ff 	. 
	rst 38h			;5b96	ff 	. 
	rst 38h			;5b97	ff 	. 
	rst 38h			;5b98	ff 	. 
	rst 38h			;5b99	ff 	. 
	rst 38h			;5b9a	ff 	. 
	rst 38h			;5b9b	ff 	. 
	rst 38h			;5b9c	ff 	. 
	rst 38h			;5b9d	ff 	. 
	rst 38h			;5b9e	ff 	. 
	rst 38h			;5b9f	ff 	. 
	rst 38h			;5ba0	ff 	. 
	rst 38h			;5ba1	ff 	. 
	rst 38h			;5ba2	ff 	. 
	rst 38h			;5ba3	ff 	. 
	rst 38h			;5ba4	ff 	. 
	rst 38h			;5ba5	ff 	. 
	rst 38h			;5ba6	ff 	. 
	rst 38h			;5ba7	ff 	. 
	rst 38h			;5ba8	ff 	. 
	rst 38h			;5ba9	ff 	. 
	rst 38h			;5baa	ff 	. 
	rst 38h			;5bab	ff 	. 
	rst 38h			;5bac	ff 	. 
	rst 38h			;5bad	ff 	. 
	rst 38h			;5bae	ff 	. 
	rst 38h			;5baf	ff 	. 
	rst 38h			;5bb0	ff 	. 
	rst 38h			;5bb1	ff 	. 
	rst 38h			;5bb2	ff 	. 
	rst 38h			;5bb3	ff 	. 
	rst 38h			;5bb4	ff 	. 
	rst 38h			;5bb5	ff 	. 
	rst 38h			;5bb6	ff 	. 
	rst 38h			;5bb7	ff 	. 
	rst 38h			;5bb8	ff 	. 
	rst 38h			;5bb9	ff 	. 
	rst 38h			;5bba	ff 	. 
	rst 38h			;5bbb	ff 	. 
	rst 38h			;5bbc	ff 	. 
	rst 38h			;5bbd	ff 	. 
	rst 38h			;5bbe	ff 	. 
	rst 38h			;5bbf	ff 	. 
	rst 38h			;5bc0	ff 	. 
	rst 38h			;5bc1	ff 	. 
	rst 38h			;5bc2	ff 	. 
	rst 38h			;5bc3	ff 	. 
	rst 38h			;5bc4	ff 	. 
	rst 38h			;5bc5	ff 	. 
	rst 38h			;5bc6	ff 	. 
	rst 38h			;5bc7	ff 	. 
	rst 38h			;5bc8	ff 	. 
	rst 38h			;5bc9	ff 	. 
	rst 38h			;5bca	ff 	. 
	rst 38h			;5bcb	ff 	. 
	rst 38h			;5bcc	ff 	. 
	rst 38h			;5bcd	ff 	. 
	rst 38h			;5bce	ff 	. 
	rst 38h			;5bcf	ff 	. 
	rst 38h			;5bd0	ff 	. 
	rst 38h			;5bd1	ff 	. 
	rst 38h			;5bd2	ff 	. 
	rst 38h			;5bd3	ff 	. 
	rst 38h			;5bd4	ff 	. 
	rst 38h			;5bd5	ff 	. 
	rst 38h			;5bd6	ff 	. 
	rst 38h			;5bd7	ff 	. 
	rst 38h			;5bd8	ff 	. 
	rst 38h			;5bd9	ff 	. 
	rst 38h			;5bda	ff 	. 
	rst 38h			;5bdb	ff 	. 
	rst 38h			;5bdc	ff 	. 
	rst 38h			;5bdd	ff 	. 
	rst 38h			;5bde	ff 	. 
	rst 38h			;5bdf	ff 	. 
	rst 38h			;5be0	ff 	. 
	rst 38h			;5be1	ff 	. 
	rst 38h			;5be2	ff 	. 
	rst 38h			;5be3	ff 	. 
	rst 38h			;5be4	ff 	. 
	rst 38h			;5be5	ff 	. 
	rst 38h			;5be6	ff 	. 
	rst 38h			;5be7	ff 	. 
	rst 38h			;5be8	ff 	. 
	rst 38h			;5be9	ff 	. 
	rst 38h			;5bea	ff 	. 
	rst 38h			;5beb	ff 	. 
	rst 38h			;5bec	ff 	. 
	rst 38h			;5bed	ff 	. 
	rst 38h			;5bee	ff 	. 
	rst 38h			;5bef	ff 	. 
	rst 38h			;5bf0	ff 	. 
	rst 38h			;5bf1	ff 	. 
	rst 38h			;5bf2	ff 	. 
	rst 38h			;5bf3	ff 	. 
	rst 38h			;5bf4	ff 	. 
	rst 38h			;5bf5	ff 	. 
	rst 38h			;5bf6	ff 	. 
	rst 38h			;5bf7	ff 	. 
	rst 38h			;5bf8	ff 	. 
	rst 38h			;5bf9	ff 	. 
	rst 38h			;5bfa	ff 	. 
	rst 38h			;5bfb	ff 	. 
	rst 38h			;5bfc	ff 	. 
	rst 38h			;5bfd	ff 	. 
	rst 38h			;5bfe	ff 	. 
	rst 38h			;5bff	ff 	. 
	rst 38h			;5c00	ff 	. 
	rst 38h			;5c01	ff 	. 
	rst 38h			;5c02	ff 	. 
	rst 38h			;5c03	ff 	. 
	rst 38h			;5c04	ff 	. 
	rst 38h			;5c05	ff 	. 
	rst 38h			;5c06	ff 	. 
	rst 38h			;5c07	ff 	. 
	rst 38h			;5c08	ff 	. 
	rst 38h			;5c09	ff 	. 
	rst 38h			;5c0a	ff 	. 
	rst 38h			;5c0b	ff 	. 
	rst 38h			;5c0c	ff 	. 
	rst 38h			;5c0d	ff 	. 
	rst 38h			;5c0e	ff 	. 
	rst 38h			;5c0f	ff 	. 
	rst 38h			;5c10	ff 	. 
	rst 38h			;5c11	ff 	. 
	rst 38h			;5c12	ff 	. 
	rst 38h			;5c13	ff 	. 
	rst 38h			;5c14	ff 	. 
	rst 38h			;5c15	ff 	. 
	rst 38h			;5c16	ff 	. 
	rst 38h			;5c17	ff 	. 
	rst 38h			;5c18	ff 	. 
	rst 38h			;5c19	ff 	. 
	rst 38h			;5c1a	ff 	. 
	rst 38h			;5c1b	ff 	. 
	rst 38h			;5c1c	ff 	. 
	rst 38h			;5c1d	ff 	. 
	rst 38h			;5c1e	ff 	. 
	rst 38h			;5c1f	ff 	. 
	rst 38h			;5c20	ff 	. 
	rst 38h			;5c21	ff 	. 
	rst 38h			;5c22	ff 	. 
	rst 38h			;5c23	ff 	. 
	rst 38h			;5c24	ff 	. 
	rst 38h			;5c25	ff 	. 
	rst 38h			;5c26	ff 	. 
	rst 38h			;5c27	ff 	. 
	rst 38h			;5c28	ff 	. 
	rst 38h			;5c29	ff 	. 
	rst 38h			;5c2a	ff 	. 
	rst 38h			;5c2b	ff 	. 
	rst 38h			;5c2c	ff 	. 
	rst 38h			;5c2d	ff 	. 
	rst 38h			;5c2e	ff 	. 
	rst 38h			;5c2f	ff 	. 
	rst 38h			;5c30	ff 	. 
	rst 38h			;5c31	ff 	. 
	rst 38h			;5c32	ff 	. 
	rst 38h			;5c33	ff 	. 
	rst 38h			;5c34	ff 	. 
	rst 38h			;5c35	ff 	. 
	rst 38h			;5c36	ff 	. 
	rst 38h			;5c37	ff 	. 
	rst 38h			;5c38	ff 	. 
	rst 38h			;5c39	ff 	. 
	rst 38h			;5c3a	ff 	. 
	rst 38h			;5c3b	ff 	. 
	rst 38h			;5c3c	ff 	. 
	rst 38h			;5c3d	ff 	. 
	rst 38h			;5c3e	ff 	. 
	rst 38h			;5c3f	ff 	. 
	rst 38h			;5c40	ff 	. 
	rst 38h			;5c41	ff 	. 
	rst 38h			;5c42	ff 	. 
	rst 38h			;5c43	ff 	. 
	rst 38h			;5c44	ff 	. 
	rst 38h			;5c45	ff 	. 
	rst 38h			;5c46	ff 	. 
	rst 38h			;5c47	ff 	. 
	rst 38h			;5c48	ff 	. 
	rst 38h			;5c49	ff 	. 
	rst 38h			;5c4a	ff 	. 
	rst 38h			;5c4b	ff 	. 
	rst 38h			;5c4c	ff 	. 
	rst 38h			;5c4d	ff 	. 
	rst 38h			;5c4e	ff 	. 
	rst 38h			;5c4f	ff 	. 
	rst 38h			;5c50	ff 	. 
	rst 38h			;5c51	ff 	. 
	rst 38h			;5c52	ff 	. 
	rst 38h			;5c53	ff 	. 
	rst 38h			;5c54	ff 	. 
	rst 38h			;5c55	ff 	. 
	rst 38h			;5c56	ff 	. 
	rst 38h			;5c57	ff 	. 
	rst 38h			;5c58	ff 	. 
	rst 38h			;5c59	ff 	. 
	rst 38h			;5c5a	ff 	. 
	rst 38h			;5c5b	ff 	. 
	rst 38h			;5c5c	ff 	. 
	rst 38h			;5c5d	ff 	. 
	rst 38h			;5c5e	ff 	. 
	rst 38h			;5c5f	ff 	. 
	rst 38h			;5c60	ff 	. 
	rst 38h			;5c61	ff 	. 
	rst 38h			;5c62	ff 	. 
	rst 38h			;5c63	ff 	. 
	rst 38h			;5c64	ff 	. 
	rst 38h			;5c65	ff 	. 
	rst 38h			;5c66	ff 	. 
	rst 38h			;5c67	ff 	. 
	rst 38h			;5c68	ff 	. 
	rst 38h			;5c69	ff 	. 
	rst 38h			;5c6a	ff 	. 
	rst 38h			;5c6b	ff 	. 
	rst 38h			;5c6c	ff 	. 
	rst 38h			;5c6d	ff 	. 
	rst 38h			;5c6e	ff 	. 
	rst 38h			;5c6f	ff 	. 
	rst 38h			;5c70	ff 	. 
	rst 38h			;5c71	ff 	. 
	rst 38h			;5c72	ff 	. 
	rst 38h			;5c73	ff 	. 
	rst 38h			;5c74	ff 	. 
	rst 38h			;5c75	ff 	. 
	rst 38h			;5c76	ff 	. 
	rst 38h			;5c77	ff 	. 
	rst 38h			;5c78	ff 	. 
	rst 38h			;5c79	ff 	. 
	rst 38h			;5c7a	ff 	. 
	rst 38h			;5c7b	ff 	. 
	rst 38h			;5c7c	ff 	. 
	rst 38h			;5c7d	ff 	. 
	rst 38h			;5c7e	ff 	. 
	rst 38h			;5c7f	ff 	. 
	rst 38h			;5c80	ff 	. 
	rst 38h			;5c81	ff 	. 
	rst 38h			;5c82	ff 	. 
	rst 38h			;5c83	ff 	. 
	rst 38h			;5c84	ff 	. 
	rst 38h			;5c85	ff 	. 
	rst 38h			;5c86	ff 	. 
	rst 38h			;5c87	ff 	. 
	rst 38h			;5c88	ff 	. 
	rst 38h			;5c89	ff 	. 
	rst 38h			;5c8a	ff 	. 
	rst 38h			;5c8b	ff 	. 
	rst 38h			;5c8c	ff 	. 
	rst 38h			;5c8d	ff 	. 
	rst 38h			;5c8e	ff 	. 
	rst 38h			;5c8f	ff 	. 
	rst 38h			;5c90	ff 	. 
	rst 38h			;5c91	ff 	. 
	rst 38h			;5c92	ff 	. 
	rst 38h			;5c93	ff 	. 
	rst 38h			;5c94	ff 	. 
	rst 38h			;5c95	ff 	. 
	rst 38h			;5c96	ff 	. 
	rst 38h			;5c97	ff 	. 
	rst 38h			;5c98	ff 	. 
	rst 38h			;5c99	ff 	. 
	rst 38h			;5c9a	ff 	. 
	rst 38h			;5c9b	ff 	. 
	rst 38h			;5c9c	ff 	. 
	rst 38h			;5c9d	ff 	. 
	rst 38h			;5c9e	ff 	. 
	rst 38h			;5c9f	ff 	. 
	rst 38h			;5ca0	ff 	. 
	rst 38h			;5ca1	ff 	. 
	rst 38h			;5ca2	ff 	. 
	rst 38h			;5ca3	ff 	. 
	rst 38h			;5ca4	ff 	. 
	rst 38h			;5ca5	ff 	. 
	rst 38h			;5ca6	ff 	. 
	rst 38h			;5ca7	ff 	. 
	rst 38h			;5ca8	ff 	. 
	rst 38h			;5ca9	ff 	. 
	rst 38h			;5caa	ff 	. 
	rst 38h			;5cab	ff 	. 
	rst 38h			;5cac	ff 	. 
	rst 38h			;5cad	ff 	. 
	rst 38h			;5cae	ff 	. 
	rst 38h			;5caf	ff 	. 
	rst 38h			;5cb0	ff 	. 
	rst 38h			;5cb1	ff 	. 
	rst 38h			;5cb2	ff 	. 
	rst 38h			;5cb3	ff 	. 
	rst 38h			;5cb4	ff 	. 
	rst 38h			;5cb5	ff 	. 
	rst 38h			;5cb6	ff 	. 
	rst 38h			;5cb7	ff 	. 
	rst 38h			;5cb8	ff 	. 
	rst 38h			;5cb9	ff 	. 
	rst 38h			;5cba	ff 	. 
	rst 38h			;5cbb	ff 	. 
	rst 38h			;5cbc	ff 	. 
	rst 38h			;5cbd	ff 	. 
	rst 38h			;5cbe	ff 	. 
	rst 38h			;5cbf	ff 	. 
	rst 38h			;5cc0	ff 	. 
	rst 38h			;5cc1	ff 	. 
	rst 38h			;5cc2	ff 	. 
	rst 38h			;5cc3	ff 	. 
	rst 38h			;5cc4	ff 	. 
	rst 38h			;5cc5	ff 	. 
	rst 38h			;5cc6	ff 	. 
	rst 38h			;5cc7	ff 	. 
	rst 38h			;5cc8	ff 	. 
	rst 38h			;5cc9	ff 	. 
	rst 38h			;5cca	ff 	. 
	rst 38h			;5ccb	ff 	. 
	rst 38h			;5ccc	ff 	. 
	rst 38h			;5ccd	ff 	. 
	rst 38h			;5cce	ff 	. 
	rst 38h			;5ccf	ff 	. 
	rst 38h			;5cd0	ff 	. 
	rst 38h			;5cd1	ff 	. 
	rst 38h			;5cd2	ff 	. 
	rst 38h			;5cd3	ff 	. 
	rst 38h			;5cd4	ff 	. 
	rst 38h			;5cd5	ff 	. 
	rst 38h			;5cd6	ff 	. 
	rst 38h			;5cd7	ff 	. 
	rst 38h			;5cd8	ff 	. 
	rst 38h			;5cd9	ff 	. 
	rst 38h			;5cda	ff 	. 
	rst 38h			;5cdb	ff 	. 
	rst 38h			;5cdc	ff 	. 
	rst 38h			;5cdd	ff 	. 
	rst 38h			;5cde	ff 	. 
	rst 38h			;5cdf	ff 	. 
	rst 38h			;5ce0	ff 	. 
	rst 38h			;5ce1	ff 	. 
	rst 38h			;5ce2	ff 	. 
	rst 38h			;5ce3	ff 	. 
	rst 38h			;5ce4	ff 	. 
	rst 38h			;5ce5	ff 	. 
	rst 38h			;5ce6	ff 	. 
	rst 38h			;5ce7	ff 	. 
	rst 38h			;5ce8	ff 	. 
	rst 38h			;5ce9	ff 	. 
	rst 38h			;5cea	ff 	. 
	rst 38h			;5ceb	ff 	. 
	rst 38h			;5cec	ff 	. 
	rst 38h			;5ced	ff 	. 
	rst 38h			;5cee	ff 	. 
	rst 38h			;5cef	ff 	. 
	rst 38h			;5cf0	ff 	. 
	rst 38h			;5cf1	ff 	. 
	rst 38h			;5cf2	ff 	. 
	rst 38h			;5cf3	ff 	. 
	rst 38h			;5cf4	ff 	. 
	rst 38h			;5cf5	ff 	. 
	rst 38h			;5cf6	ff 	. 
	rst 38h			;5cf7	ff 	. 
	rst 38h			;5cf8	ff 	. 
	rst 38h			;5cf9	ff 	. 
	rst 38h			;5cfa	ff 	. 
	rst 38h			;5cfb	ff 	. 
	rst 38h			;5cfc	ff 	. 
	rst 38h			;5cfd	ff 	. 
	rst 38h			;5cfe	ff 	. 
	rst 38h			;5cff	ff 	. 
	rst 38h			;5d00	ff 	. 
	rst 38h			;5d01	ff 	. 
	rst 38h			;5d02	ff 	. 
	rst 38h			;5d03	ff 	. 
	rst 38h			;5d04	ff 	. 
	rst 38h			;5d05	ff 	. 
	rst 38h			;5d06	ff 	. 
	rst 38h			;5d07	ff 	. 
	rst 38h			;5d08	ff 	. 
	rst 38h			;5d09	ff 	. 
	rst 38h			;5d0a	ff 	. 
	rst 38h			;5d0b	ff 	. 
	rst 38h			;5d0c	ff 	. 
	rst 38h			;5d0d	ff 	. 
	rst 38h			;5d0e	ff 	. 
	rst 38h			;5d0f	ff 	. 
	rst 38h			;5d10	ff 	. 
	rst 38h			;5d11	ff 	. 
	rst 38h			;5d12	ff 	. 
	rst 38h			;5d13	ff 	. 
	rst 38h			;5d14	ff 	. 
	rst 38h			;5d15	ff 	. 
	rst 38h			;5d16	ff 	. 
	rst 38h			;5d17	ff 	. 
	rst 38h			;5d18	ff 	. 
	rst 38h			;5d19	ff 	. 
	rst 38h			;5d1a	ff 	. 
	rst 38h			;5d1b	ff 	. 
	rst 38h			;5d1c	ff 	. 
	rst 38h			;5d1d	ff 	. 
	rst 38h			;5d1e	ff 	. 
	rst 38h			;5d1f	ff 	. 
	rst 38h			;5d20	ff 	. 
	rst 38h			;5d21	ff 	. 
	rst 38h			;5d22	ff 	. 
	rst 38h			;5d23	ff 	. 
	rst 38h			;5d24	ff 	. 
	rst 38h			;5d25	ff 	. 
	rst 38h			;5d26	ff 	. 
	rst 38h			;5d27	ff 	. 
	rst 38h			;5d28	ff 	. 
	rst 38h			;5d29	ff 	. 
	rst 38h			;5d2a	ff 	. 
	rst 38h			;5d2b	ff 	. 
	rst 38h			;5d2c	ff 	. 
	rst 38h			;5d2d	ff 	. 
	rst 38h			;5d2e	ff 	. 
	rst 38h			;5d2f	ff 	. 
	rst 38h			;5d30	ff 	. 
	rst 38h			;5d31	ff 	. 
	rst 38h			;5d32	ff 	. 
	rst 38h			;5d33	ff 	. 
	rst 38h			;5d34	ff 	. 
	rst 38h			;5d35	ff 	. 
	rst 38h			;5d36	ff 	. 
	rst 38h			;5d37	ff 	. 
	rst 38h			;5d38	ff 	. 
	rst 38h			;5d39	ff 	. 
	rst 38h			;5d3a	ff 	. 
	rst 38h			;5d3b	ff 	. 
	rst 38h			;5d3c	ff 	. 
	rst 38h			;5d3d	ff 	. 
	rst 38h			;5d3e	ff 	. 
	rst 38h			;5d3f	ff 	. 
	rst 38h			;5d40	ff 	. 
	rst 38h			;5d41	ff 	. 
	rst 38h			;5d42	ff 	. 
	rst 38h			;5d43	ff 	. 
	rst 38h			;5d44	ff 	. 
	rst 38h			;5d45	ff 	. 
	rst 38h			;5d46	ff 	. 
	rst 38h			;5d47	ff 	. 
	rst 38h			;5d48	ff 	. 
	rst 38h			;5d49	ff 	. 
	rst 38h			;5d4a	ff 	. 
	rst 38h			;5d4b	ff 	. 
	rst 38h			;5d4c	ff 	. 
	rst 38h			;5d4d	ff 	. 
	rst 38h			;5d4e	ff 	. 
	rst 38h			;5d4f	ff 	. 
	rst 38h			;5d50	ff 	. 
	rst 38h			;5d51	ff 	. 
	rst 38h			;5d52	ff 	. 
	rst 38h			;5d53	ff 	. 
	rst 38h			;5d54	ff 	. 
	rst 38h			;5d55	ff 	. 
	rst 38h			;5d56	ff 	. 
	rst 38h			;5d57	ff 	. 
	rst 38h			;5d58	ff 	. 
	rst 38h			;5d59	ff 	. 
	rst 38h			;5d5a	ff 	. 
	rst 38h			;5d5b	ff 	. 
	rst 38h			;5d5c	ff 	. 
	rst 38h			;5d5d	ff 	. 
	rst 38h			;5d5e	ff 	. 
	rst 38h			;5d5f	ff 	. 
	rst 38h			;5d60	ff 	. 
	rst 38h			;5d61	ff 	. 
	rst 38h			;5d62	ff 	. 
	rst 38h			;5d63	ff 	. 
	rst 38h			;5d64	ff 	. 
	rst 38h			;5d65	ff 	. 
	rst 38h			;5d66	ff 	. 
	rst 38h			;5d67	ff 	. 
	rst 38h			;5d68	ff 	. 
	rst 38h			;5d69	ff 	. 
	rst 38h			;5d6a	ff 	. 
	rst 38h			;5d6b	ff 	. 
	rst 38h			;5d6c	ff 	. 
	rst 38h			;5d6d	ff 	. 
	rst 38h			;5d6e	ff 	. 
	rst 38h			;5d6f	ff 	. 
	rst 38h			;5d70	ff 	. 
	rst 38h			;5d71	ff 	. 
	rst 38h			;5d72	ff 	. 
	rst 38h			;5d73	ff 	. 
	rst 38h			;5d74	ff 	. 
	rst 38h			;5d75	ff 	. 
	rst 38h			;5d76	ff 	. 
	rst 38h			;5d77	ff 	. 
	rst 38h			;5d78	ff 	. 
	rst 38h			;5d79	ff 	. 
	rst 38h			;5d7a	ff 	. 
	rst 38h			;5d7b	ff 	. 
	rst 38h			;5d7c	ff 	. 
	rst 38h			;5d7d	ff 	. 
	rst 38h			;5d7e	ff 	. 
	rst 38h			;5d7f	ff 	. 
	rst 38h			;5d80	ff 	. 
	rst 38h			;5d81	ff 	. 
	rst 38h			;5d82	ff 	. 
	rst 38h			;5d83	ff 	. 
	rst 38h			;5d84	ff 	. 
	rst 38h			;5d85	ff 	. 
	rst 38h			;5d86	ff 	. 
	rst 38h			;5d87	ff 	. 
	rst 38h			;5d88	ff 	. 
	rst 38h			;5d89	ff 	. 
	rst 38h			;5d8a	ff 	. 
	rst 38h			;5d8b	ff 	. 
	rst 38h			;5d8c	ff 	. 
	rst 38h			;5d8d	ff 	. 
	rst 38h			;5d8e	ff 	. 
	rst 38h			;5d8f	ff 	. 
	rst 38h			;5d90	ff 	. 
	rst 38h			;5d91	ff 	. 
	rst 38h			;5d92	ff 	. 
	rst 38h			;5d93	ff 	. 
	rst 38h			;5d94	ff 	. 
	rst 38h			;5d95	ff 	. 
	rst 38h			;5d96	ff 	. 
	rst 38h			;5d97	ff 	. 
	rst 38h			;5d98	ff 	. 
	rst 38h			;5d99	ff 	. 
	rst 38h			;5d9a	ff 	. 
	rst 38h			;5d9b	ff 	. 
	rst 38h			;5d9c	ff 	. 
	rst 38h			;5d9d	ff 	. 
	rst 38h			;5d9e	ff 	. 
	rst 38h			;5d9f	ff 	. 
	rst 38h			;5da0	ff 	. 
	rst 38h			;5da1	ff 	. 
	rst 38h			;5da2	ff 	. 
	rst 38h			;5da3	ff 	. 
	rst 38h			;5da4	ff 	. 
	rst 38h			;5da5	ff 	. 
	rst 38h			;5da6	ff 	. 
	rst 38h			;5da7	ff 	. 
	rst 38h			;5da8	ff 	. 
	rst 38h			;5da9	ff 	. 
	rst 38h			;5daa	ff 	. 
	rst 38h			;5dab	ff 	. 
	rst 38h			;5dac	ff 	. 
	rst 38h			;5dad	ff 	. 
	rst 38h			;5dae	ff 	. 
	rst 38h			;5daf	ff 	. 
	rst 38h			;5db0	ff 	. 
	rst 38h			;5db1	ff 	. 
	rst 38h			;5db2	ff 	. 
	rst 38h			;5db3	ff 	. 
	rst 38h			;5db4	ff 	. 
	rst 38h			;5db5	ff 	. 
	rst 38h			;5db6	ff 	. 
	rst 38h			;5db7	ff 	. 
	rst 38h			;5db8	ff 	. 
	rst 38h			;5db9	ff 	. 
	rst 38h			;5dba	ff 	. 
	rst 38h			;5dbb	ff 	. 
	rst 38h			;5dbc	ff 	. 
	rst 38h			;5dbd	ff 	. 
	rst 38h			;5dbe	ff 	. 
	rst 38h			;5dbf	ff 	. 
	rst 38h			;5dc0	ff 	. 
	rst 38h			;5dc1	ff 	. 
	rst 38h			;5dc2	ff 	. 
	rst 38h			;5dc3	ff 	. 
	rst 38h			;5dc4	ff 	. 
	rst 38h			;5dc5	ff 	. 
	rst 38h			;5dc6	ff 	. 
	rst 38h			;5dc7	ff 	. 
	rst 38h			;5dc8	ff 	. 
	rst 38h			;5dc9	ff 	. 
	rst 38h			;5dca	ff 	. 
	rst 38h			;5dcb	ff 	. 
	rst 38h			;5dcc	ff 	. 
	rst 38h			;5dcd	ff 	. 
	rst 38h			;5dce	ff 	. 
	rst 38h			;5dcf	ff 	. 
	rst 38h			;5dd0	ff 	. 
	rst 38h			;5dd1	ff 	. 
	rst 38h			;5dd2	ff 	. 
	rst 38h			;5dd3	ff 	. 
	rst 38h			;5dd4	ff 	. 
	rst 38h			;5dd5	ff 	. 
	rst 38h			;5dd6	ff 	. 
	rst 38h			;5dd7	ff 	. 
	rst 38h			;5dd8	ff 	. 
	rst 38h			;5dd9	ff 	. 
	rst 38h			;5dda	ff 	. 
	rst 38h			;5ddb	ff 	. 
	rst 38h			;5ddc	ff 	. 
	rst 38h			;5ddd	ff 	. 
	rst 38h			;5dde	ff 	. 
	rst 38h			;5ddf	ff 	. 
	rst 38h			;5de0	ff 	. 
	rst 38h			;5de1	ff 	. 
	rst 38h			;5de2	ff 	. 
	rst 38h			;5de3	ff 	. 
	rst 38h			;5de4	ff 	. 
	rst 38h			;5de5	ff 	. 
	rst 38h			;5de6	ff 	. 
	rst 38h			;5de7	ff 	. 
	rst 38h			;5de8	ff 	. 
	rst 38h			;5de9	ff 	. 
	rst 38h			;5dea	ff 	. 
	rst 38h			;5deb	ff 	. 
	rst 38h			;5dec	ff 	. 
	rst 38h			;5ded	ff 	. 
	rst 38h			;5dee	ff 	. 
	rst 38h			;5def	ff 	. 
	rst 38h			;5df0	ff 	. 
	rst 38h			;5df1	ff 	. 
	rst 38h			;5df2	ff 	. 
	rst 38h			;5df3	ff 	. 
	rst 38h			;5df4	ff 	. 
	rst 38h			;5df5	ff 	. 
	rst 38h			;5df6	ff 	. 
	rst 38h			;5df7	ff 	. 
	rst 38h			;5df8	ff 	. 
	rst 38h			;5df9	ff 	. 
	rst 38h			;5dfa	ff 	. 
	rst 38h			;5dfb	ff 	. 
	rst 38h			;5dfc	ff 	. 
	rst 38h			;5dfd	ff 	. 
	rst 38h			;5dfe	ff 	. 
	rst 38h			;5dff	ff 	. 
	rst 38h			;5e00	ff 	. 
	rst 38h			;5e01	ff 	. 
	rst 38h			;5e02	ff 	. 
	rst 38h			;5e03	ff 	. 
	rst 38h			;5e04	ff 	. 
	rst 38h			;5e05	ff 	. 
	rst 38h			;5e06	ff 	. 
	rst 38h			;5e07	ff 	. 
	rst 38h			;5e08	ff 	. 
	rst 38h			;5e09	ff 	. 
	rst 38h			;5e0a	ff 	. 
	rst 38h			;5e0b	ff 	. 
	rst 38h			;5e0c	ff 	. 
	rst 38h			;5e0d	ff 	. 
	rst 38h			;5e0e	ff 	. 
	rst 38h			;5e0f	ff 	. 
	rst 38h			;5e10	ff 	. 
	rst 38h			;5e11	ff 	. 
	rst 38h			;5e12	ff 	. 
	rst 38h			;5e13	ff 	. 
	rst 38h			;5e14	ff 	. 
	rst 38h			;5e15	ff 	. 
	rst 38h			;5e16	ff 	. 
	rst 38h			;5e17	ff 	. 
	rst 38h			;5e18	ff 	. 
	rst 38h			;5e19	ff 	. 
	rst 38h			;5e1a	ff 	. 
	rst 38h			;5e1b	ff 	. 
	rst 38h			;5e1c	ff 	. 
	rst 38h			;5e1d	ff 	. 
	rst 38h			;5e1e	ff 	. 
	rst 38h			;5e1f	ff 	. 
	rst 38h			;5e20	ff 	. 
	rst 38h			;5e21	ff 	. 
	rst 38h			;5e22	ff 	. 
	rst 38h			;5e23	ff 	. 
	rst 38h			;5e24	ff 	. 
	rst 38h			;5e25	ff 	. 
	rst 38h			;5e26	ff 	. 
	rst 38h			;5e27	ff 	. 
	rst 38h			;5e28	ff 	. 
	rst 38h			;5e29	ff 	. 
	rst 38h			;5e2a	ff 	. 
	rst 38h			;5e2b	ff 	. 
	rst 38h			;5e2c	ff 	. 
	rst 38h			;5e2d	ff 	. 
	rst 38h			;5e2e	ff 	. 
	rst 38h			;5e2f	ff 	. 
	rst 38h			;5e30	ff 	. 
	rst 38h			;5e31	ff 	. 
	rst 38h			;5e32	ff 	. 
	rst 38h			;5e33	ff 	. 
	rst 38h			;5e34	ff 	. 
	rst 38h			;5e35	ff 	. 
	rst 38h			;5e36	ff 	. 
	rst 38h			;5e37	ff 	. 
	rst 38h			;5e38	ff 	. 
	rst 38h			;5e39	ff 	. 
	rst 38h			;5e3a	ff 	. 
	rst 38h			;5e3b	ff 	. 
	rst 38h			;5e3c	ff 	. 
	rst 38h			;5e3d	ff 	. 
	rst 38h			;5e3e	ff 	. 
	rst 38h			;5e3f	ff 	. 
	rst 38h			;5e40	ff 	. 
	rst 38h			;5e41	ff 	. 
	rst 38h			;5e42	ff 	. 
	rst 38h			;5e43	ff 	. 
	rst 38h			;5e44	ff 	. 
	rst 38h			;5e45	ff 	. 
	rst 38h			;5e46	ff 	. 
	rst 38h			;5e47	ff 	. 
	rst 38h			;5e48	ff 	. 
	rst 38h			;5e49	ff 	. 
	rst 38h			;5e4a	ff 	. 
	rst 38h			;5e4b	ff 	. 
	rst 38h			;5e4c	ff 	. 
	rst 38h			;5e4d	ff 	. 
	rst 38h			;5e4e	ff 	. 
	rst 38h			;5e4f	ff 	. 
	rst 38h			;5e50	ff 	. 
	rst 38h			;5e51	ff 	. 
	rst 38h			;5e52	ff 	. 
	rst 38h			;5e53	ff 	. 
	rst 38h			;5e54	ff 	. 
	rst 38h			;5e55	ff 	. 
	rst 38h			;5e56	ff 	. 
	rst 38h			;5e57	ff 	. 
	rst 38h			;5e58	ff 	. 
	rst 38h			;5e59	ff 	. 
	rst 38h			;5e5a	ff 	. 
	rst 38h			;5e5b	ff 	. 
	rst 38h			;5e5c	ff 	. 
	rst 38h			;5e5d	ff 	. 
	rst 38h			;5e5e	ff 	. 
	rst 38h			;5e5f	ff 	. 
	rst 38h			;5e60	ff 	. 
	rst 38h			;5e61	ff 	. 
	rst 38h			;5e62	ff 	. 
	rst 38h			;5e63	ff 	. 
	rst 38h			;5e64	ff 	. 
	rst 38h			;5e65	ff 	. 
	rst 38h			;5e66	ff 	. 
	rst 38h			;5e67	ff 	. 
	rst 38h			;5e68	ff 	. 
	rst 38h			;5e69	ff 	. 
	rst 38h			;5e6a	ff 	. 
	rst 38h			;5e6b	ff 	. 
	rst 38h			;5e6c	ff 	. 
	rst 38h			;5e6d	ff 	. 
	rst 38h			;5e6e	ff 	. 
	rst 38h			;5e6f	ff 	. 
	rst 38h			;5e70	ff 	. 
	rst 38h			;5e71	ff 	. 
	rst 38h			;5e72	ff 	. 
	rst 38h			;5e73	ff 	. 
	rst 38h			;5e74	ff 	. 
	rst 38h			;5e75	ff 	. 
	rst 38h			;5e76	ff 	. 
	rst 38h			;5e77	ff 	. 
	rst 38h			;5e78	ff 	. 
	rst 38h			;5e79	ff 	. 
	rst 38h			;5e7a	ff 	. 
	rst 38h			;5e7b	ff 	. 
	rst 38h			;5e7c	ff 	. 
	rst 38h			;5e7d	ff 	. 
	rst 38h			;5e7e	ff 	. 
	rst 38h			;5e7f	ff 	. 
	rst 38h			;5e80	ff 	. 
	rst 38h			;5e81	ff 	. 
	rst 38h			;5e82	ff 	. 
	rst 38h			;5e83	ff 	. 
	rst 38h			;5e84	ff 	. 
	rst 38h			;5e85	ff 	. 
	rst 38h			;5e86	ff 	. 
	rst 38h			;5e87	ff 	. 
	rst 38h			;5e88	ff 	. 
	rst 38h			;5e89	ff 	. 
	rst 38h			;5e8a	ff 	. 
	rst 38h			;5e8b	ff 	. 
	rst 38h			;5e8c	ff 	. 
	rst 38h			;5e8d	ff 	. 
	rst 38h			;5e8e	ff 	. 
	rst 38h			;5e8f	ff 	. 
	rst 38h			;5e90	ff 	. 
	rst 38h			;5e91	ff 	. 
	rst 38h			;5e92	ff 	. 
	rst 38h			;5e93	ff 	. 
	rst 38h			;5e94	ff 	. 
	rst 38h			;5e95	ff 	. 
	rst 38h			;5e96	ff 	. 
	rst 38h			;5e97	ff 	. 
	rst 38h			;5e98	ff 	. 
	rst 38h			;5e99	ff 	. 
	rst 38h			;5e9a	ff 	. 
	rst 38h			;5e9b	ff 	. 
	rst 38h			;5e9c	ff 	. 
	rst 38h			;5e9d	ff 	. 
	rst 38h			;5e9e	ff 	. 
	rst 38h			;5e9f	ff 	. 
	rst 38h			;5ea0	ff 	. 
	rst 38h			;5ea1	ff 	. 
	rst 38h			;5ea2	ff 	. 
	rst 38h			;5ea3	ff 	. 
	rst 38h			;5ea4	ff 	. 
	rst 38h			;5ea5	ff 	. 
	rst 38h			;5ea6	ff 	. 
	rst 38h			;5ea7	ff 	. 
	rst 38h			;5ea8	ff 	. 
	rst 38h			;5ea9	ff 	. 
	rst 38h			;5eaa	ff 	. 
	rst 38h			;5eab	ff 	. 
	rst 38h			;5eac	ff 	. 
	rst 38h			;5ead	ff 	. 
	rst 38h			;5eae	ff 	. 
	rst 38h			;5eaf	ff 	. 
	rst 38h			;5eb0	ff 	. 
	rst 38h			;5eb1	ff 	. 
	rst 38h			;5eb2	ff 	. 
	rst 38h			;5eb3	ff 	. 
	rst 38h			;5eb4	ff 	. 
	rst 38h			;5eb5	ff 	. 
	rst 38h			;5eb6	ff 	. 
	rst 38h			;5eb7	ff 	. 
	rst 38h			;5eb8	ff 	. 
	rst 38h			;5eb9	ff 	. 
	rst 38h			;5eba	ff 	. 
	rst 38h			;5ebb	ff 	. 
	rst 38h			;5ebc	ff 	. 
	rst 38h			;5ebd	ff 	. 
	rst 38h			;5ebe	ff 	. 
	rst 38h			;5ebf	ff 	. 
	rst 38h			;5ec0	ff 	. 
	rst 38h			;5ec1	ff 	. 
	rst 38h			;5ec2	ff 	. 
	rst 38h			;5ec3	ff 	. 
	rst 38h			;5ec4	ff 	. 
	rst 38h			;5ec5	ff 	. 
	rst 38h			;5ec6	ff 	. 
	rst 38h			;5ec7	ff 	. 
	rst 38h			;5ec8	ff 	. 
	rst 38h			;5ec9	ff 	. 
	rst 38h			;5eca	ff 	. 
	rst 38h			;5ecb	ff 	. 
	rst 38h			;5ecc	ff 	. 
	rst 38h			;5ecd	ff 	. 
	rst 38h			;5ece	ff 	. 
	rst 38h			;5ecf	ff 	. 
	rst 38h			;5ed0	ff 	. 
	rst 38h			;5ed1	ff 	. 
	rst 38h			;5ed2	ff 	. 
	rst 38h			;5ed3	ff 	. 
	rst 38h			;5ed4	ff 	. 
	rst 38h			;5ed5	ff 	. 
	rst 38h			;5ed6	ff 	. 
	rst 38h			;5ed7	ff 	. 
	rst 38h			;5ed8	ff 	. 
	rst 38h			;5ed9	ff 	. 
	rst 38h			;5eda	ff 	. 
	rst 38h			;5edb	ff 	. 
	rst 38h			;5edc	ff 	. 
	rst 38h			;5edd	ff 	. 
	rst 38h			;5ede	ff 	. 
	rst 38h			;5edf	ff 	. 
	rst 38h			;5ee0	ff 	. 
	rst 38h			;5ee1	ff 	. 
	rst 38h			;5ee2	ff 	. 
	rst 38h			;5ee3	ff 	. 
	rst 38h			;5ee4	ff 	. 
	rst 38h			;5ee5	ff 	. 
	rst 38h			;5ee6	ff 	. 
	rst 38h			;5ee7	ff 	. 
	rst 38h			;5ee8	ff 	. 
	rst 38h			;5ee9	ff 	. 
	rst 38h			;5eea	ff 	. 
	rst 38h			;5eeb	ff 	. 
	rst 38h			;5eec	ff 	. 
	rst 38h			;5eed	ff 	. 
	rst 38h			;5eee	ff 	. 
	rst 38h			;5eef	ff 	. 
	rst 38h			;5ef0	ff 	. 
	rst 38h			;5ef1	ff 	. 
	rst 38h			;5ef2	ff 	. 
	rst 38h			;5ef3	ff 	. 
	rst 38h			;5ef4	ff 	. 
	rst 38h			;5ef5	ff 	. 
	rst 38h			;5ef6	ff 	. 
	rst 38h			;5ef7	ff 	. 
	rst 38h			;5ef8	ff 	. 
	rst 38h			;5ef9	ff 	. 
	rst 38h			;5efa	ff 	. 
	rst 38h			;5efb	ff 	. 
	rst 38h			;5efc	ff 	. 
	rst 38h			;5efd	ff 	. 
	rst 38h			;5efe	ff 	. 
	rst 38h			;5eff	ff 	. 
	rst 38h			;5f00	ff 	. 
	rst 38h			;5f01	ff 	. 
	rst 38h			;5f02	ff 	. 
	rst 38h			;5f03	ff 	. 
	rst 38h			;5f04	ff 	. 
	rst 38h			;5f05	ff 	. 
	rst 38h			;5f06	ff 	. 
	rst 38h			;5f07	ff 	. 
	rst 38h			;5f08	ff 	. 
	rst 38h			;5f09	ff 	. 
	rst 38h			;5f0a	ff 	. 
	rst 38h			;5f0b	ff 	. 
	rst 38h			;5f0c	ff 	. 
	rst 38h			;5f0d	ff 	. 
	rst 38h			;5f0e	ff 	. 
	rst 38h			;5f0f	ff 	. 
	rst 38h			;5f10	ff 	. 
	rst 38h			;5f11	ff 	. 
	rst 38h			;5f12	ff 	. 
	rst 38h			;5f13	ff 	. 
	rst 38h			;5f14	ff 	. 
	rst 38h			;5f15	ff 	. 
	rst 38h			;5f16	ff 	. 
	rst 38h			;5f17	ff 	. 
	rst 38h			;5f18	ff 	. 
	rst 38h			;5f19	ff 	. 
	rst 38h			;5f1a	ff 	. 
	rst 38h			;5f1b	ff 	. 
	rst 38h			;5f1c	ff 	. 
	rst 38h			;5f1d	ff 	. 
	rst 38h			;5f1e	ff 	. 
	rst 38h			;5f1f	ff 	. 
	rst 38h			;5f20	ff 	. 
	rst 38h			;5f21	ff 	. 
	rst 38h			;5f22	ff 	. 
	rst 38h			;5f23	ff 	. 
	rst 38h			;5f24	ff 	. 
	rst 38h			;5f25	ff 	. 
	rst 38h			;5f26	ff 	. 
	rst 38h			;5f27	ff 	. 
	rst 38h			;5f28	ff 	. 
	rst 38h			;5f29	ff 	. 
	rst 38h			;5f2a	ff 	. 
	rst 38h			;5f2b	ff 	. 
	rst 38h			;5f2c	ff 	. 
	rst 38h			;5f2d	ff 	. 
	rst 38h			;5f2e	ff 	. 
	rst 38h			;5f2f	ff 	. 
	rst 38h			;5f30	ff 	. 
	rst 38h			;5f31	ff 	. 
	rst 38h			;5f32	ff 	. 
	rst 38h			;5f33	ff 	. 
	rst 38h			;5f34	ff 	. 
	rst 38h			;5f35	ff 	. 
	rst 38h			;5f36	ff 	. 
	rst 38h			;5f37	ff 	. 
	rst 38h			;5f38	ff 	. 
	rst 38h			;5f39	ff 	. 
	rst 38h			;5f3a	ff 	. 
	rst 38h			;5f3b	ff 	. 
	rst 38h			;5f3c	ff 	. 
	rst 38h			;5f3d	ff 	. 
	rst 38h			;5f3e	ff 	. 
	rst 38h			;5f3f	ff 	. 
	rst 38h			;5f40	ff 	. 
	rst 38h			;5f41	ff 	. 
	rst 38h			;5f42	ff 	. 
	rst 38h			;5f43	ff 	. 
	rst 38h			;5f44	ff 	. 
	rst 38h			;5f45	ff 	. 
	rst 38h			;5f46	ff 	. 
	rst 38h			;5f47	ff 	. 
	rst 38h			;5f48	ff 	. 
	rst 38h			;5f49	ff 	. 
	rst 38h			;5f4a	ff 	. 
	rst 38h			;5f4b	ff 	. 
	rst 38h			;5f4c	ff 	. 
	rst 38h			;5f4d	ff 	. 
	rst 38h			;5f4e	ff 	. 
	rst 38h			;5f4f	ff 	. 
	rst 38h			;5f50	ff 	. 
	rst 38h			;5f51	ff 	. 
	rst 38h			;5f52	ff 	. 
	rst 38h			;5f53	ff 	. 
	rst 38h			;5f54	ff 	. 
	rst 38h			;5f55	ff 	. 
	rst 38h			;5f56	ff 	. 
	rst 38h			;5f57	ff 	. 
	rst 38h			;5f58	ff 	. 
	rst 38h			;5f59	ff 	. 
	rst 38h			;5f5a	ff 	. 
	rst 38h			;5f5b	ff 	. 
	rst 38h			;5f5c	ff 	. 
	rst 38h			;5f5d	ff 	. 
	rst 38h			;5f5e	ff 	. 
	rst 38h			;5f5f	ff 	. 
	rst 38h			;5f60	ff 	. 
	rst 38h			;5f61	ff 	. 
	rst 38h			;5f62	ff 	. 
	rst 38h			;5f63	ff 	. 
	rst 38h			;5f64	ff 	. 
	rst 38h			;5f65	ff 	. 
	rst 38h			;5f66	ff 	. 
	rst 38h			;5f67	ff 	. 
	rst 38h			;5f68	ff 	. 
	rst 38h			;5f69	ff 	. 
	rst 38h			;5f6a	ff 	. 
	rst 38h			;5f6b	ff 	. 
	rst 38h			;5f6c	ff 	. 
	rst 38h			;5f6d	ff 	. 
	rst 38h			;5f6e	ff 	. 
	rst 38h			;5f6f	ff 	. 
	rst 38h			;5f70	ff 	. 
	rst 38h			;5f71	ff 	. 
	rst 38h			;5f72	ff 	. 
	rst 38h			;5f73	ff 	. 
	rst 38h			;5f74	ff 	. 
	rst 38h			;5f75	ff 	. 
	rst 38h			;5f76	ff 	. 
	rst 38h			;5f77	ff 	. 
	rst 38h			;5f78	ff 	. 
	rst 38h			;5f79	ff 	. 
	rst 38h			;5f7a	ff 	. 
	rst 38h			;5f7b	ff 	. 
	rst 38h			;5f7c	ff 	. 
	rst 38h			;5f7d	ff 	. 
	rst 38h			;5f7e	ff 	. 
	rst 38h			;5f7f	ff 	. 
	rst 38h			;5f80	ff 	. 
	rst 38h			;5f81	ff 	. 
	rst 38h			;5f82	ff 	. 
	rst 38h			;5f83	ff 	. 
	rst 38h			;5f84	ff 	. 
	rst 38h			;5f85	ff 	. 
	rst 38h			;5f86	ff 	. 
	rst 38h			;5f87	ff 	. 
	rst 38h			;5f88	ff 	. 
	rst 38h			;5f89	ff 	. 
	rst 38h			;5f8a	ff 	. 
	rst 38h			;5f8b	ff 	. 
	rst 38h			;5f8c	ff 	. 
	rst 38h			;5f8d	ff 	. 
	rst 38h			;5f8e	ff 	. 
	rst 38h			;5f8f	ff 	. 
	rst 38h			;5f90	ff 	. 
	rst 38h			;5f91	ff 	. 
	rst 38h			;5f92	ff 	. 
	rst 38h			;5f93	ff 	. 
	rst 38h			;5f94	ff 	. 
	rst 38h			;5f95	ff 	. 
	rst 38h			;5f96	ff 	. 
	rst 38h			;5f97	ff 	. 
	rst 38h			;5f98	ff 	. 
	rst 38h			;5f99	ff 	. 
	rst 38h			;5f9a	ff 	. 
	rst 38h			;5f9b	ff 	. 
	rst 38h			;5f9c	ff 	. 
	rst 38h			;5f9d	ff 	. 
	rst 38h			;5f9e	ff 	. 
	rst 38h			;5f9f	ff 	. 
	rst 38h			;5fa0	ff 	. 
	rst 38h			;5fa1	ff 	. 
	rst 38h			;5fa2	ff 	. 
	rst 38h			;5fa3	ff 	. 
	rst 38h			;5fa4	ff 	. 
	rst 38h			;5fa5	ff 	. 
	rst 38h			;5fa6	ff 	. 
	rst 38h			;5fa7	ff 	. 
	rst 38h			;5fa8	ff 	. 
	rst 38h			;5fa9	ff 	. 
	rst 38h			;5faa	ff 	. 
	rst 38h			;5fab	ff 	. 
	rst 38h			;5fac	ff 	. 
	rst 38h			;5fad	ff 	. 
	rst 38h			;5fae	ff 	. 
	rst 38h			;5faf	ff 	. 
	rst 38h			;5fb0	ff 	. 
	rst 38h			;5fb1	ff 	. 
	rst 38h			;5fb2	ff 	. 
	rst 38h			;5fb3	ff 	. 
	rst 38h			;5fb4	ff 	. 
	rst 38h			;5fb5	ff 	. 
	rst 38h			;5fb6	ff 	. 
	rst 38h			;5fb7	ff 	. 
	rst 38h			;5fb8	ff 	. 
	rst 38h			;5fb9	ff 	. 
	rst 38h			;5fba	ff 	. 
	rst 38h			;5fbb	ff 	. 
	rst 38h			;5fbc	ff 	. 
	rst 38h			;5fbd	ff 	. 
	rst 38h			;5fbe	ff 	. 
	rst 38h			;5fbf	ff 	. 
	rst 38h			;5fc0	ff 	. 
	rst 38h			;5fc1	ff 	. 
	rst 38h			;5fc2	ff 	. 
	rst 38h			;5fc3	ff 	. 
	rst 38h			;5fc4	ff 	. 
	rst 38h			;5fc5	ff 	. 
	rst 38h			;5fc6	ff 	. 
	rst 38h			;5fc7	ff 	. 
	rst 38h			;5fc8	ff 	. 
	rst 38h			;5fc9	ff 	. 
	rst 38h			;5fca	ff 	. 
	rst 38h			;5fcb	ff 	. 
	rst 38h			;5fcc	ff 	. 
	rst 38h			;5fcd	ff 	. 
	rst 38h			;5fce	ff 	. 
	rst 38h			;5fcf	ff 	. 
	rst 38h			;5fd0	ff 	. 
	rst 38h			;5fd1	ff 	. 
	rst 38h			;5fd2	ff 	. 
	rst 38h			;5fd3	ff 	. 
	rst 38h			;5fd4	ff 	. 
	rst 38h			;5fd5	ff 	. 
	rst 38h			;5fd6	ff 	. 
	rst 38h			;5fd7	ff 	. 
	rst 38h			;5fd8	ff 	. 
	rst 38h			;5fd9	ff 	. 
	rst 38h			;5fda	ff 	. 
	rst 38h			;5fdb	ff 	. 
	rst 38h			;5fdc	ff 	. 
	rst 38h			;5fdd	ff 	. 
	rst 38h			;5fde	ff 	. 
	rst 38h			;5fdf	ff 	. 
	rst 38h			;5fe0	ff 	. 
	rst 38h			;5fe1	ff 	. 
	rst 38h			;5fe2	ff 	. 
	rst 38h			;5fe3	ff 	. 
	rst 38h			;5fe4	ff 	. 
	rst 38h			;5fe5	ff 	. 
	rst 38h			;5fe6	ff 	. 
	rst 38h			;5fe7	ff 	. 
	rst 38h			;5fe8	ff 	. 
	rst 38h			;5fe9	ff 	. 
	rst 38h			;5fea	ff 	. 
	rst 38h			;5feb	ff 	. 
	rst 38h			;5fec	ff 	. 
	rst 38h			;5fed	ff 	. 
	rst 38h			;5fee	ff 	. 
	rst 38h			;5fef	ff 	. 
	rst 38h			;5ff0	ff 	. 
	rst 38h			;5ff1	ff 	. 
	rst 38h			;5ff2	ff 	. 
	rst 38h			;5ff3	ff 	. 
	rst 38h			;5ff4	ff 	. 
	rst 38h			;5ff5	ff 	. 
	rst 38h			;5ff6	ff 	. 
	rst 38h			;5ff7	ff 	. 
	rst 38h			;5ff8	ff 	. 
	rst 38h			;5ff9	ff 	. 
	rst 38h			;5ffa	ff 	. 
	rst 38h			;5ffb	ff 	. 
	rst 38h			;5ffc	ff 	. 
	rst 38h			;5ffd	ff 	. 
	rst 38h			;5ffe	ff 	. 
	rst 38h			;5fff	ff 	. 
	rst 38h			;6000	ff 	. 
	rst 38h			;6001	ff 	. 
	rst 38h			;6002	ff 	. 
	rst 38h			;6003	ff 	. 
	rst 38h			;6004	ff 	. 
	rst 38h			;6005	ff 	. 
	rst 38h			;6006	ff 	. 
	rst 38h			;6007	ff 	. 
	rst 38h			;6008	ff 	. 
	rst 38h			;6009	ff 	. 
	rst 38h			;600a	ff 	. 
	rst 38h			;600b	ff 	. 
	rst 38h			;600c	ff 	. 
	rst 38h			;600d	ff 	. 
	rst 38h			;600e	ff 	. 
	rst 38h			;600f	ff 	. 
	rst 38h			;6010	ff 	. 
	rst 38h			;6011	ff 	. 
	rst 38h			;6012	ff 	. 
	rst 38h			;6013	ff 	. 
	rst 38h			;6014	ff 	. 
	rst 38h			;6015	ff 	. 
	rst 38h			;6016	ff 	. 
	rst 38h			;6017	ff 	. 
	rst 38h			;6018	ff 	. 
	rst 38h			;6019	ff 	. 
	rst 38h			;601a	ff 	. 
	rst 38h			;601b	ff 	. 
	rst 38h			;601c	ff 	. 
	rst 38h			;601d	ff 	. 
	rst 38h			;601e	ff 	. 
	rst 38h			;601f	ff 	. 
l6020h:
	rst 38h			;6020	ff 	. 
	rst 38h			;6021	ff 	. 
l6022h:
	rst 38h			;6022	ff 	. 
	rst 38h			;6023	ff 	. 
	rst 38h			;6024	ff 	. 
	rst 38h			;6025	ff 	. 
	rst 38h			;6026	ff 	. 
	rst 38h			;6027	ff 	. 
	rst 38h			;6028	ff 	. 
	rst 38h			;6029	ff 	. 
	rst 38h			;602a	ff 	. 
	rst 38h			;602b	ff 	. 
	rst 38h			;602c	ff 	. 
	rst 38h			;602d	ff 	. 
	rst 38h			;602e	ff 	. 
	rst 38h			;602f	ff 	. 
	rst 38h			;6030	ff 	. 
	rst 38h			;6031	ff 	. 
	rst 38h			;6032	ff 	. 
	rst 38h			;6033	ff 	. 
	rst 38h			;6034	ff 	. 
	rst 38h			;6035	ff 	. 
	rst 38h			;6036	ff 	. 
	rst 38h			;6037	ff 	. 
	rst 38h			;6038	ff 	. 
	rst 38h			;6039	ff 	. 
	rst 38h			;603a	ff 	. 
	rst 38h			;603b	ff 	. 
	rst 38h			;603c	ff 	. 
	rst 38h			;603d	ff 	. 
	rst 38h			;603e	ff 	. 
	rst 38h			;603f	ff 	. 
	rst 38h			;6040	ff 	. 
	rst 38h			;6041	ff 	. 
	rst 38h			;6042	ff 	. 
	rst 38h			;6043	ff 	. 
	rst 38h			;6044	ff 	. 
	rst 38h			;6045	ff 	. 
	rst 38h			;6046	ff 	. 
	rst 38h			;6047	ff 	. 
	rst 38h			;6048	ff 	. 
	rst 38h			;6049	ff 	. 
	rst 38h			;604a	ff 	. 
	rst 38h			;604b	ff 	. 
	rst 38h			;604c	ff 	. 
	rst 38h			;604d	ff 	. 
	rst 38h			;604e	ff 	. 
	rst 38h			;604f	ff 	. 
	rst 38h			;6050	ff 	. 
	rst 38h			;6051	ff 	. 
	rst 38h			;6052	ff 	. 
	rst 38h			;6053	ff 	. 
	rst 38h			;6054	ff 	. 
	rst 38h			;6055	ff 	. 
	rst 38h			;6056	ff 	. 
	rst 38h			;6057	ff 	. 
	rst 38h			;6058	ff 	. 
	rst 38h			;6059	ff 	. 
	rst 38h			;605a	ff 	. 
	rst 38h			;605b	ff 	. 
	rst 38h			;605c	ff 	. 
	rst 38h			;605d	ff 	. 
	rst 38h			;605e	ff 	. 
	rst 38h			;605f	ff 	. 
	rst 38h			;6060	ff 	. 
	rst 38h			;6061	ff 	. 
	rst 38h			;6062	ff 	. 
	rst 38h			;6063	ff 	. 
	rst 38h			;6064	ff 	. 
	rst 38h			;6065	ff 	. 
	rst 38h			;6066	ff 	. 
	rst 38h			;6067	ff 	. 
	rst 38h			;6068	ff 	. 
	rst 38h			;6069	ff 	. 
	rst 38h			;606a	ff 	. 
	rst 38h			;606b	ff 	. 
	rst 38h			;606c	ff 	. 
	rst 38h			;606d	ff 	. 
	rst 38h			;606e	ff 	. 
	rst 38h			;606f	ff 	. 
	rst 38h			;6070	ff 	. 
	rst 38h			;6071	ff 	. 
	rst 38h			;6072	ff 	. 
	rst 38h			;6073	ff 	. 
	rst 38h			;6074	ff 	. 
	rst 38h			;6075	ff 	. 
	rst 38h			;6076	ff 	. 
	rst 38h			;6077	ff 	. 
	rst 38h			;6078	ff 	. 
	rst 38h			;6079	ff 	. 
	rst 38h			;607a	ff 	. 
	rst 38h			;607b	ff 	. 
	rst 38h			;607c	ff 	. 
	rst 38h			;607d	ff 	. 
	rst 38h			;607e	ff 	. 
	rst 38h			;607f	ff 	. 
	rst 38h			;6080	ff 	. 
	rst 38h			;6081	ff 	. 
	rst 38h			;6082	ff 	. 
	rst 38h			;6083	ff 	. 
	rst 38h			;6084	ff 	. 
	rst 38h			;6085	ff 	. 
	rst 38h			;6086	ff 	. 
	rst 38h			;6087	ff 	. 
	rst 38h			;6088	ff 	. 
	rst 38h			;6089	ff 	. 
	rst 38h			;608a	ff 	. 
	rst 38h			;608b	ff 	. 
	rst 38h			;608c	ff 	. 
	rst 38h			;608d	ff 	. 
	rst 38h			;608e	ff 	. 
	rst 38h			;608f	ff 	. 
	rst 38h			;6090	ff 	. 
	rst 38h			;6091	ff 	. 
	rst 38h			;6092	ff 	. 
	rst 38h			;6093	ff 	. 
	rst 38h			;6094	ff 	. 
	rst 38h			;6095	ff 	. 
	rst 38h			;6096	ff 	. 
	rst 38h			;6097	ff 	. 
	rst 38h			;6098	ff 	. 
	rst 38h			;6099	ff 	. 
	rst 38h			;609a	ff 	. 
	rst 38h			;609b	ff 	. 
	rst 38h			;609c	ff 	. 
	rst 38h			;609d	ff 	. 
	rst 38h			;609e	ff 	. 
	rst 38h			;609f	ff 	. 
	rst 38h			;60a0	ff 	. 
	rst 38h			;60a1	ff 	. 
	rst 38h			;60a2	ff 	. 
	rst 38h			;60a3	ff 	. 
	rst 38h			;60a4	ff 	. 
	rst 38h			;60a5	ff 	. 
	rst 38h			;60a6	ff 	. 
	rst 38h			;60a7	ff 	. 
	rst 38h			;60a8	ff 	. 
	rst 38h			;60a9	ff 	. 
	rst 38h			;60aa	ff 	. 
	rst 38h			;60ab	ff 	. 
	rst 38h			;60ac	ff 	. 
	rst 38h			;60ad	ff 	. 
	rst 38h			;60ae	ff 	. 
	rst 38h			;60af	ff 	. 
	rst 38h			;60b0	ff 	. 
	rst 38h			;60b1	ff 	. 
	rst 38h			;60b2	ff 	. 
	rst 38h			;60b3	ff 	. 
	rst 38h			;60b4	ff 	. 
	rst 38h			;60b5	ff 	. 
	rst 38h			;60b6	ff 	. 
	rst 38h			;60b7	ff 	. 
	rst 38h			;60b8	ff 	. 
	rst 38h			;60b9	ff 	. 
	rst 38h			;60ba	ff 	. 
	rst 38h			;60bb	ff 	. 
	rst 38h			;60bc	ff 	. 
	rst 38h			;60bd	ff 	. 
	rst 38h			;60be	ff 	. 
	rst 38h			;60bf	ff 	. 
	rst 38h			;60c0	ff 	. 
	rst 38h			;60c1	ff 	. 
	rst 38h			;60c2	ff 	. 
	rst 38h			;60c3	ff 	. 
	rst 38h			;60c4	ff 	. 
	rst 38h			;60c5	ff 	. 
	rst 38h			;60c6	ff 	. 
	rst 38h			;60c7	ff 	. 
	rst 38h			;60c8	ff 	. 
	rst 38h			;60c9	ff 	. 
	rst 38h			;60ca	ff 	. 
	rst 38h			;60cb	ff 	. 
	rst 38h			;60cc	ff 	. 
	rst 38h			;60cd	ff 	. 
	rst 38h			;60ce	ff 	. 
	rst 38h			;60cf	ff 	. 
	rst 38h			;60d0	ff 	. 
	rst 38h			;60d1	ff 	. 
	rst 38h			;60d2	ff 	. 
	rst 38h			;60d3	ff 	. 
	rst 38h			;60d4	ff 	. 
	rst 38h			;60d5	ff 	. 
	rst 38h			;60d6	ff 	. 
	rst 38h			;60d7	ff 	. 
	rst 38h			;60d8	ff 	. 
	rst 38h			;60d9	ff 	. 
	rst 38h			;60da	ff 	. 
	rst 38h			;60db	ff 	. 
	rst 38h			;60dc	ff 	. 
	rst 38h			;60dd	ff 	. 
	rst 38h			;60de	ff 	. 
	rst 38h			;60df	ff 	. 
	rst 38h			;60e0	ff 	. 
	rst 38h			;60e1	ff 	. 
	rst 38h			;60e2	ff 	. 
	rst 38h			;60e3	ff 	. 
	rst 38h			;60e4	ff 	. 
	rst 38h			;60e5	ff 	. 
	rst 38h			;60e6	ff 	. 
	rst 38h			;60e7	ff 	. 
	rst 38h			;60e8	ff 	. 
	rst 38h			;60e9	ff 	. 
	rst 38h			;60ea	ff 	. 
	rst 38h			;60eb	ff 	. 
	rst 38h			;60ec	ff 	. 
	rst 38h			;60ed	ff 	. 
	rst 38h			;60ee	ff 	. 
	rst 38h			;60ef	ff 	. 
	rst 38h			;60f0	ff 	. 
	rst 38h			;60f1	ff 	. 
	rst 38h			;60f2	ff 	. 
	rst 38h			;60f3	ff 	. 
	rst 38h			;60f4	ff 	. 
	rst 38h			;60f5	ff 	. 
	rst 38h			;60f6	ff 	. 
	rst 38h			;60f7	ff 	. 
	rst 38h			;60f8	ff 	. 
	rst 38h			;60f9	ff 	. 
	rst 38h			;60fa	ff 	. 
	rst 38h			;60fb	ff 	. 
	rst 38h			;60fc	ff 	. 
	rst 38h			;60fd	ff 	. 
	rst 38h			;60fe	ff 	. 
	rst 38h			;60ff	ff 	. 
	rst 38h			;6100	ff 	. 
	rst 38h			;6101	ff 	. 
	rst 38h			;6102	ff 	. 
	rst 38h			;6103	ff 	. 
	rst 38h			;6104	ff 	. 
	rst 38h			;6105	ff 	. 
	rst 38h			;6106	ff 	. 
	rst 38h			;6107	ff 	. 
	rst 38h			;6108	ff 	. 
	rst 38h			;6109	ff 	. 
	rst 38h			;610a	ff 	. 
	rst 38h			;610b	ff 	. 
	rst 38h			;610c	ff 	. 
	rst 38h			;610d	ff 	. 
	rst 38h			;610e	ff 	. 
	rst 38h			;610f	ff 	. 
	rst 38h			;6110	ff 	. 
	rst 38h			;6111	ff 	. 
	rst 38h			;6112	ff 	. 
	rst 38h			;6113	ff 	. 
	rst 38h			;6114	ff 	. 
	rst 38h			;6115	ff 	. 
	rst 38h			;6116	ff 	. 
	rst 38h			;6117	ff 	. 
	rst 38h			;6118	ff 	. 
	rst 38h			;6119	ff 	. 
	rst 38h			;611a	ff 	. 
	rst 38h			;611b	ff 	. 
	rst 38h			;611c	ff 	. 
	rst 38h			;611d	ff 	. 
	rst 38h			;611e	ff 	. 
	rst 38h			;611f	ff 	. 
	rst 38h			;6120	ff 	. 
	rst 38h			;6121	ff 	. 
	rst 38h			;6122	ff 	. 
	rst 38h			;6123	ff 	. 
	rst 38h			;6124	ff 	. 
	rst 38h			;6125	ff 	. 
	rst 38h			;6126	ff 	. 
	rst 38h			;6127	ff 	. 
	rst 38h			;6128	ff 	. 
	rst 38h			;6129	ff 	. 
	rst 38h			;612a	ff 	. 
	rst 38h			;612b	ff 	. 
	rst 38h			;612c	ff 	. 
	rst 38h			;612d	ff 	. 
	rst 38h			;612e	ff 	. 
	rst 38h			;612f	ff 	. 
	rst 38h			;6130	ff 	. 
	rst 38h			;6131	ff 	. 
	rst 38h			;6132	ff 	. 
	rst 38h			;6133	ff 	. 
	rst 38h			;6134	ff 	. 
	rst 38h			;6135	ff 	. 
	rst 38h			;6136	ff 	. 
	rst 38h			;6137	ff 	. 
	rst 38h			;6138	ff 	. 
	rst 38h			;6139	ff 	. 
	rst 38h			;613a	ff 	. 
	rst 38h			;613b	ff 	. 
	rst 38h			;613c	ff 	. 
	rst 38h			;613d	ff 	. 
	rst 38h			;613e	ff 	. 
	rst 38h			;613f	ff 	. 
	rst 38h			;6140	ff 	. 
	rst 38h			;6141	ff 	. 
	rst 38h			;6142	ff 	. 
	rst 38h			;6143	ff 	. 
	rst 38h			;6144	ff 	. 
	rst 38h			;6145	ff 	. 
	rst 38h			;6146	ff 	. 
	rst 38h			;6147	ff 	. 
	rst 38h			;6148	ff 	. 
	rst 38h			;6149	ff 	. 
	rst 38h			;614a	ff 	. 
	rst 38h			;614b	ff 	. 
	rst 38h			;614c	ff 	. 
	rst 38h			;614d	ff 	. 
	rst 38h			;614e	ff 	. 
	rst 38h			;614f	ff 	. 
	rst 38h			;6150	ff 	. 
	rst 38h			;6151	ff 	. 
	rst 38h			;6152	ff 	. 
	rst 38h			;6153	ff 	. 
	rst 38h			;6154	ff 	. 
	rst 38h			;6155	ff 	. 
	rst 38h			;6156	ff 	. 
	rst 38h			;6157	ff 	. 
	rst 38h			;6158	ff 	. 
	rst 38h			;6159	ff 	. 
	rst 38h			;615a	ff 	. 
	rst 38h			;615b	ff 	. 
	rst 38h			;615c	ff 	. 
	rst 38h			;615d	ff 	. 
	rst 38h			;615e	ff 	. 
	rst 38h			;615f	ff 	. 
	rst 38h			;6160	ff 	. 
	rst 38h			;6161	ff 	. 
	rst 38h			;6162	ff 	. 
	rst 38h			;6163	ff 	. 
	rst 38h			;6164	ff 	. 
	rst 38h			;6165	ff 	. 
	rst 38h			;6166	ff 	. 
	rst 38h			;6167	ff 	. 
	rst 38h			;6168	ff 	. 
	rst 38h			;6169	ff 	. 
	rst 38h			;616a	ff 	. 
	rst 38h			;616b	ff 	. 
	rst 38h			;616c	ff 	. 
	rst 38h			;616d	ff 	. 
	rst 38h			;616e	ff 	. 
	rst 38h			;616f	ff 	. 
	rst 38h			;6170	ff 	. 
	rst 38h			;6171	ff 	. 
	rst 38h			;6172	ff 	. 
	rst 38h			;6173	ff 	. 
	rst 38h			;6174	ff 	. 
	rst 38h			;6175	ff 	. 
	rst 38h			;6176	ff 	. 
	rst 38h			;6177	ff 	. 
	rst 38h			;6178	ff 	. 
	rst 38h			;6179	ff 	. 
	rst 38h			;617a	ff 	. 
	rst 38h			;617b	ff 	. 
	rst 38h			;617c	ff 	. 
	rst 38h			;617d	ff 	. 
	rst 38h			;617e	ff 	. 
	rst 38h			;617f	ff 	. 
	rst 38h			;6180	ff 	. 
	rst 38h			;6181	ff 	. 
	rst 38h			;6182	ff 	. 
	rst 38h			;6183	ff 	. 
	rst 38h			;6184	ff 	. 
	rst 38h			;6185	ff 	. 
	rst 38h			;6186	ff 	. 
	rst 38h			;6187	ff 	. 
	rst 38h			;6188	ff 	. 
	rst 38h			;6189	ff 	. 
	rst 38h			;618a	ff 	. 
	rst 38h			;618b	ff 	. 
	rst 38h			;618c	ff 	. 
	rst 38h			;618d	ff 	. 
	rst 38h			;618e	ff 	. 
	rst 38h			;618f	ff 	. 
	rst 38h			;6190	ff 	. 
	rst 38h			;6191	ff 	. 
	rst 38h			;6192	ff 	. 
	rst 38h			;6193	ff 	. 
	rst 38h			;6194	ff 	. 
	rst 38h			;6195	ff 	. 
	rst 38h			;6196	ff 	. 
	rst 38h			;6197	ff 	. 
	rst 38h			;6198	ff 	. 
	rst 38h			;6199	ff 	. 
	rst 38h			;619a	ff 	. 
	rst 38h			;619b	ff 	. 
	rst 38h			;619c	ff 	. 
	rst 38h			;619d	ff 	. 
	rst 38h			;619e	ff 	. 
	rst 38h			;619f	ff 	. 
	rst 38h			;61a0	ff 	. 
	rst 38h			;61a1	ff 	. 
	rst 38h			;61a2	ff 	. 
	rst 38h			;61a3	ff 	. 
	rst 38h			;61a4	ff 	. 
	rst 38h			;61a5	ff 	. 
	rst 38h			;61a6	ff 	. 
	rst 38h			;61a7	ff 	. 
	rst 38h			;61a8	ff 	. 
	rst 38h			;61a9	ff 	. 
	rst 38h			;61aa	ff 	. 
	rst 38h			;61ab	ff 	. 
	rst 38h			;61ac	ff 	. 
	rst 38h			;61ad	ff 	. 
	rst 38h			;61ae	ff 	. 
	rst 38h			;61af	ff 	. 
	rst 38h			;61b0	ff 	. 
	rst 38h			;61b1	ff 	. 
	rst 38h			;61b2	ff 	. 
	rst 38h			;61b3	ff 	. 
	rst 38h			;61b4	ff 	. 
	rst 38h			;61b5	ff 	. 
	rst 38h			;61b6	ff 	. 
	rst 38h			;61b7	ff 	. 
	rst 38h			;61b8	ff 	. 
	rst 38h			;61b9	ff 	. 
	rst 38h			;61ba	ff 	. 
	rst 38h			;61bb	ff 	. 
	rst 38h			;61bc	ff 	. 
	rst 38h			;61bd	ff 	. 
	rst 38h			;61be	ff 	. 
	rst 38h			;61bf	ff 	. 
	rst 38h			;61c0	ff 	. 
	rst 38h			;61c1	ff 	. 
	rst 38h			;61c2	ff 	. 
	rst 38h			;61c3	ff 	. 
	rst 38h			;61c4	ff 	. 
	rst 38h			;61c5	ff 	. 
	rst 38h			;61c6	ff 	. 
	rst 38h			;61c7	ff 	. 
	rst 38h			;61c8	ff 	. 
	rst 38h			;61c9	ff 	. 
	rst 38h			;61ca	ff 	. 
	rst 38h			;61cb	ff 	. 
	rst 38h			;61cc	ff 	. 
	rst 38h			;61cd	ff 	. 
	rst 38h			;61ce	ff 	. 
	rst 38h			;61cf	ff 	. 
	rst 38h			;61d0	ff 	. 
	rst 38h			;61d1	ff 	. 
	rst 38h			;61d2	ff 	. 
	rst 38h			;61d3	ff 	. 
	rst 38h			;61d4	ff 	. 
	rst 38h			;61d5	ff 	. 
	rst 38h			;61d6	ff 	. 
	rst 38h			;61d7	ff 	. 
	rst 38h			;61d8	ff 	. 
	rst 38h			;61d9	ff 	. 
	rst 38h			;61da	ff 	. 
	rst 38h			;61db	ff 	. 
	rst 38h			;61dc	ff 	. 
	rst 38h			;61dd	ff 	. 
	rst 38h			;61de	ff 	. 
	rst 38h			;61df	ff 	. 
	rst 38h			;61e0	ff 	. 
	rst 38h			;61e1	ff 	. 
	rst 38h			;61e2	ff 	. 
	rst 38h			;61e3	ff 	. 
	rst 38h			;61e4	ff 	. 
	rst 38h			;61e5	ff 	. 
	rst 38h			;61e6	ff 	. 
	rst 38h			;61e7	ff 	. 
	rst 38h			;61e8	ff 	. 
	rst 38h			;61e9	ff 	. 
	rst 38h			;61ea	ff 	. 
	rst 38h			;61eb	ff 	. 
	rst 38h			;61ec	ff 	. 
	rst 38h			;61ed	ff 	. 
	rst 38h			;61ee	ff 	. 
	rst 38h			;61ef	ff 	. 
	rst 38h			;61f0	ff 	. 
	rst 38h			;61f1	ff 	. 
	rst 38h			;61f2	ff 	. 
	rst 38h			;61f3	ff 	. 
	rst 38h			;61f4	ff 	. 
	rst 38h			;61f5	ff 	. 
	rst 38h			;61f6	ff 	. 
	rst 38h			;61f7	ff 	. 
	rst 38h			;61f8	ff 	. 
	rst 38h			;61f9	ff 	. 
	rst 38h			;61fa	ff 	. 
	rst 38h			;61fb	ff 	. 
	rst 38h			;61fc	ff 	. 
	rst 38h			;61fd	ff 	. 
	rst 38h			;61fe	ff 	. 
	rst 38h			;61ff	ff 	. 
	rst 38h			;6200	ff 	. 
	rst 38h			;6201	ff 	. 
	rst 38h			;6202	ff 	. 
	rst 38h			;6203	ff 	. 
	rst 38h			;6204	ff 	. 
	rst 38h			;6205	ff 	. 
	rst 38h			;6206	ff 	. 
	rst 38h			;6207	ff 	. 
	rst 38h			;6208	ff 	. 
	rst 38h			;6209	ff 	. 
	rst 38h			;620a	ff 	. 
	rst 38h			;620b	ff 	. 
	rst 38h			;620c	ff 	. 
	rst 38h			;620d	ff 	. 
	rst 38h			;620e	ff 	. 
	rst 38h			;620f	ff 	. 
	rst 38h			;6210	ff 	. 
	rst 38h			;6211	ff 	. 
	rst 38h			;6212	ff 	. 
	rst 38h			;6213	ff 	. 
	rst 38h			;6214	ff 	. 
	rst 38h			;6215	ff 	. 
	rst 38h			;6216	ff 	. 
	rst 38h			;6217	ff 	. 
	rst 38h			;6218	ff 	. 
	rst 38h			;6219	ff 	. 
	rst 38h			;621a	ff 	. 
	rst 38h			;621b	ff 	. 
	rst 38h			;621c	ff 	. 
	rst 38h			;621d	ff 	. 
	rst 38h			;621e	ff 	. 
	rst 38h			;621f	ff 	. 
	rst 38h			;6220	ff 	. 
	rst 38h			;6221	ff 	. 
	rst 38h			;6222	ff 	. 
	rst 38h			;6223	ff 	. 
	rst 38h			;6224	ff 	. 
	rst 38h			;6225	ff 	. 
	rst 38h			;6226	ff 	. 
	rst 38h			;6227	ff 	. 
	rst 38h			;6228	ff 	. 
	rst 38h			;6229	ff 	. 
	rst 38h			;622a	ff 	. 
	rst 38h			;622b	ff 	. 
	rst 38h			;622c	ff 	. 
	rst 38h			;622d	ff 	. 
	rst 38h			;622e	ff 	. 
	rst 38h			;622f	ff 	. 
	rst 38h			;6230	ff 	. 
	rst 38h			;6231	ff 	. 
	rst 38h			;6232	ff 	. 
	rst 38h			;6233	ff 	. 
	rst 38h			;6234	ff 	. 
	rst 38h			;6235	ff 	. 
	rst 38h			;6236	ff 	. 
	rst 38h			;6237	ff 	. 
	rst 38h			;6238	ff 	. 
	rst 38h			;6239	ff 	. 
	rst 38h			;623a	ff 	. 
	rst 38h			;623b	ff 	. 
	rst 38h			;623c	ff 	. 
	rst 38h			;623d	ff 	. 
	rst 38h			;623e	ff 	. 
	rst 38h			;623f	ff 	. 
	rst 38h			;6240	ff 	. 
	rst 38h			;6241	ff 	. 
	rst 38h			;6242	ff 	. 
	rst 38h			;6243	ff 	. 
	rst 38h			;6244	ff 	. 
	rst 38h			;6245	ff 	. 
	rst 38h			;6246	ff 	. 
	rst 38h			;6247	ff 	. 
	rst 38h			;6248	ff 	. 
	rst 38h			;6249	ff 	. 
	rst 38h			;624a	ff 	. 
	rst 38h			;624b	ff 	. 
	rst 38h			;624c	ff 	. 
	rst 38h			;624d	ff 	. 
	rst 38h			;624e	ff 	. 
	rst 38h			;624f	ff 	. 
	rst 38h			;6250	ff 	. 
	rst 38h			;6251	ff 	. 
	rst 38h			;6252	ff 	. 
	rst 38h			;6253	ff 	. 
	rst 38h			;6254	ff 	. 
	rst 38h			;6255	ff 	. 
	rst 38h			;6256	ff 	. 
	rst 38h			;6257	ff 	. 
	rst 38h			;6258	ff 	. 
	rst 38h			;6259	ff 	. 
	rst 38h			;625a	ff 	. 
	rst 38h			;625b	ff 	. 
	rst 38h			;625c	ff 	. 
	rst 38h			;625d	ff 	. 
	rst 38h			;625e	ff 	. 
	rst 38h			;625f	ff 	. 
	rst 38h			;6260	ff 	. 
	rst 38h			;6261	ff 	. 
	rst 38h			;6262	ff 	. 
	rst 38h			;6263	ff 	. 
	rst 38h			;6264	ff 	. 
	rst 38h			;6265	ff 	. 
	rst 38h			;6266	ff 	. 
	rst 38h			;6267	ff 	. 
	rst 38h			;6268	ff 	. 
	rst 38h			;6269	ff 	. 
	rst 38h			;626a	ff 	. 
	rst 38h			;626b	ff 	. 
	rst 38h			;626c	ff 	. 
	rst 38h			;626d	ff 	. 
	rst 38h			;626e	ff 	. 
	rst 38h			;626f	ff 	. 
	rst 38h			;6270	ff 	. 
	rst 38h			;6271	ff 	. 
	rst 38h			;6272	ff 	. 
	rst 38h			;6273	ff 	. 
	rst 38h			;6274	ff 	. 
	rst 38h			;6275	ff 	. 
	rst 38h			;6276	ff 	. 
	rst 38h			;6277	ff 	. 
	rst 38h			;6278	ff 	. 
	rst 38h			;6279	ff 	. 
	rst 38h			;627a	ff 	. 
	rst 38h			;627b	ff 	. 
	rst 38h			;627c	ff 	. 
	rst 38h			;627d	ff 	. 
	rst 38h			;627e	ff 	. 
	rst 38h			;627f	ff 	. 
	rst 38h			;6280	ff 	. 
	rst 38h			;6281	ff 	. 
	rst 38h			;6282	ff 	. 
	rst 38h			;6283	ff 	. 
	rst 38h			;6284	ff 	. 
	rst 38h			;6285	ff 	. 
	rst 38h			;6286	ff 	. 
	rst 38h			;6287	ff 	. 
	rst 38h			;6288	ff 	. 
	rst 38h			;6289	ff 	. 
	rst 38h			;628a	ff 	. 
	rst 38h			;628b	ff 	. 
	rst 38h			;628c	ff 	. 
	rst 38h			;628d	ff 	. 
	rst 38h			;628e	ff 	. 
	rst 38h			;628f	ff 	. 
	rst 38h			;6290	ff 	. 
	rst 38h			;6291	ff 	. 
	rst 38h			;6292	ff 	. 
	rst 38h			;6293	ff 	. 
	rst 38h			;6294	ff 	. 
	rst 38h			;6295	ff 	. 
	rst 38h			;6296	ff 	. 
	rst 38h			;6297	ff 	. 
	rst 38h			;6298	ff 	. 
	rst 38h			;6299	ff 	. 
	rst 38h			;629a	ff 	. 
	rst 38h			;629b	ff 	. 
	rst 38h			;629c	ff 	. 
	rst 38h			;629d	ff 	. 
	rst 38h			;629e	ff 	. 
	rst 38h			;629f	ff 	. 
	rst 38h			;62a0	ff 	. 
	rst 38h			;62a1	ff 	. 
	rst 38h			;62a2	ff 	. 
	rst 38h			;62a3	ff 	. 
	rst 38h			;62a4	ff 	. 
	rst 38h			;62a5	ff 	. 
	rst 38h			;62a6	ff 	. 
	rst 38h			;62a7	ff 	. 
	rst 38h			;62a8	ff 	. 
	rst 38h			;62a9	ff 	. 
	rst 38h			;62aa	ff 	. 
	rst 38h			;62ab	ff 	. 
	rst 38h			;62ac	ff 	. 
	rst 38h			;62ad	ff 	. 
	rst 38h			;62ae	ff 	. 
	rst 38h			;62af	ff 	. 
	rst 38h			;62b0	ff 	. 
	rst 38h			;62b1	ff 	. 
	rst 38h			;62b2	ff 	. 
	rst 38h			;62b3	ff 	. 
	rst 38h			;62b4	ff 	. 
	rst 38h			;62b5	ff 	. 
	rst 38h			;62b6	ff 	. 
	rst 38h			;62b7	ff 	. 
	rst 38h			;62b8	ff 	. 
	rst 38h			;62b9	ff 	. 
	rst 38h			;62ba	ff 	. 
	rst 38h			;62bb	ff 	. 
	rst 38h			;62bc	ff 	. 
	rst 38h			;62bd	ff 	. 
	rst 38h			;62be	ff 	. 
	rst 38h			;62bf	ff 	. 
	rst 38h			;62c0	ff 	. 
	rst 38h			;62c1	ff 	. 
	rst 38h			;62c2	ff 	. 
	rst 38h			;62c3	ff 	. 
	rst 38h			;62c4	ff 	. 
	rst 38h			;62c5	ff 	. 
	rst 38h			;62c6	ff 	. 
	rst 38h			;62c7	ff 	. 
	rst 38h			;62c8	ff 	. 
	rst 38h			;62c9	ff 	. 
	rst 38h			;62ca	ff 	. 
	rst 38h			;62cb	ff 	. 
	rst 38h			;62cc	ff 	. 
	rst 38h			;62cd	ff 	. 
	rst 38h			;62ce	ff 	. 
	rst 38h			;62cf	ff 	. 
	rst 38h			;62d0	ff 	. 
	rst 38h			;62d1	ff 	. 
	rst 38h			;62d2	ff 	. 
	rst 38h			;62d3	ff 	. 
	rst 38h			;62d4	ff 	. 
	rst 38h			;62d5	ff 	. 
	rst 38h			;62d6	ff 	. 
	rst 38h			;62d7	ff 	. 
	rst 38h			;62d8	ff 	. 
	rst 38h			;62d9	ff 	. 
	rst 38h			;62da	ff 	. 
	rst 38h			;62db	ff 	. 
	rst 38h			;62dc	ff 	. 
	rst 38h			;62dd	ff 	. 
	rst 38h			;62de	ff 	. 
	rst 38h			;62df	ff 	. 
	rst 38h			;62e0	ff 	. 
	rst 38h			;62e1	ff 	. 
	rst 38h			;62e2	ff 	. 
	rst 38h			;62e3	ff 	. 
	rst 38h			;62e4	ff 	. 
	rst 38h			;62e5	ff 	. 
	rst 38h			;62e6	ff 	. 
	rst 38h			;62e7	ff 	. 
	rst 38h			;62e8	ff 	. 
	rst 38h			;62e9	ff 	. 
	rst 38h			;62ea	ff 	. 
	rst 38h			;62eb	ff 	. 
	rst 38h			;62ec	ff 	. 
	rst 38h			;62ed	ff 	. 
	rst 38h			;62ee	ff 	. 
	rst 38h			;62ef	ff 	. 
	rst 38h			;62f0	ff 	. 
	rst 38h			;62f1	ff 	. 
	rst 38h			;62f2	ff 	. 
	rst 38h			;62f3	ff 	. 
	rst 38h			;62f4	ff 	. 
	rst 38h			;62f5	ff 	. 
	rst 38h			;62f6	ff 	. 
	rst 38h			;62f7	ff 	. 
	rst 38h			;62f8	ff 	. 
	rst 38h			;62f9	ff 	. 
	rst 38h			;62fa	ff 	. 
	rst 38h			;62fb	ff 	. 
	rst 38h			;62fc	ff 	. 
	rst 38h			;62fd	ff 	. 
	rst 38h			;62fe	ff 	. 
	rst 38h			;62ff	ff 	. 
	rst 38h			;6300	ff 	. 
	rst 38h			;6301	ff 	. 
	rst 38h			;6302	ff 	. 
	rst 38h			;6303	ff 	. 
	rst 38h			;6304	ff 	. 
	rst 38h			;6305	ff 	. 
	rst 38h			;6306	ff 	. 
	rst 38h			;6307	ff 	. 
	rst 38h			;6308	ff 	. 
	rst 38h			;6309	ff 	. 
	rst 38h			;630a	ff 	. 
	rst 38h			;630b	ff 	. 
	rst 38h			;630c	ff 	. 
	rst 38h			;630d	ff 	. 
	rst 38h			;630e	ff 	. 
	rst 38h			;630f	ff 	. 
	rst 38h			;6310	ff 	. 
	rst 38h			;6311	ff 	. 
	rst 38h			;6312	ff 	. 
	rst 38h			;6313	ff 	. 
	rst 38h			;6314	ff 	. 
	rst 38h			;6315	ff 	. 
	rst 38h			;6316	ff 	. 
	rst 38h			;6317	ff 	. 
	rst 38h			;6318	ff 	. 
	rst 38h			;6319	ff 	. 
	rst 38h			;631a	ff 	. 
	rst 38h			;631b	ff 	. 
	rst 38h			;631c	ff 	. 
	rst 38h			;631d	ff 	. 
	rst 38h			;631e	ff 	. 
	rst 38h			;631f	ff 	. 
	rst 38h			;6320	ff 	. 
	rst 38h			;6321	ff 	. 
	rst 38h			;6322	ff 	. 
	rst 38h			;6323	ff 	. 
	rst 38h			;6324	ff 	. 
	rst 38h			;6325	ff 	. 
	rst 38h			;6326	ff 	. 
	rst 38h			;6327	ff 	. 
	rst 38h			;6328	ff 	. 
	rst 38h			;6329	ff 	. 
	rst 38h			;632a	ff 	. 
	rst 38h			;632b	ff 	. 
	rst 38h			;632c	ff 	. 
	rst 38h			;632d	ff 	. 
	rst 38h			;632e	ff 	. 
	rst 38h			;632f	ff 	. 
	rst 38h			;6330	ff 	. 
	rst 38h			;6331	ff 	. 
	rst 38h			;6332	ff 	. 
	rst 38h			;6333	ff 	. 
	rst 38h			;6334	ff 	. 
	rst 38h			;6335	ff 	. 
	rst 38h			;6336	ff 	. 
	rst 38h			;6337	ff 	. 
	rst 38h			;6338	ff 	. 
	rst 38h			;6339	ff 	. 
	rst 38h			;633a	ff 	. 
	rst 38h			;633b	ff 	. 
	rst 38h			;633c	ff 	. 
	rst 38h			;633d	ff 	. 
	rst 38h			;633e	ff 	. 
	rst 38h			;633f	ff 	. 
	rst 38h			;6340	ff 	. 
	rst 38h			;6341	ff 	. 
	rst 38h			;6342	ff 	. 
	rst 38h			;6343	ff 	. 
	rst 38h			;6344	ff 	. 
	rst 38h			;6345	ff 	. 
	rst 38h			;6346	ff 	. 
	rst 38h			;6347	ff 	. 
	rst 38h			;6348	ff 	. 
	rst 38h			;6349	ff 	. 
	rst 38h			;634a	ff 	. 
	rst 38h			;634b	ff 	. 
	rst 38h			;634c	ff 	. 
	rst 38h			;634d	ff 	. 
	rst 38h			;634e	ff 	. 
	rst 38h			;634f	ff 	. 
	rst 38h			;6350	ff 	. 
	rst 38h			;6351	ff 	. 
	rst 38h			;6352	ff 	. 
	rst 38h			;6353	ff 	. 
	rst 38h			;6354	ff 	. 
	rst 38h			;6355	ff 	. 
	rst 38h			;6356	ff 	. 
	rst 38h			;6357	ff 	. 
	rst 38h			;6358	ff 	. 
	rst 38h			;6359	ff 	. 
	rst 38h			;635a	ff 	. 
	rst 38h			;635b	ff 	. 
	rst 38h			;635c	ff 	. 
	rst 38h			;635d	ff 	. 
	rst 38h			;635e	ff 	. 
	rst 38h			;635f	ff 	. 
	rst 38h			;6360	ff 	. 
	rst 38h			;6361	ff 	. 
	rst 38h			;6362	ff 	. 
	rst 38h			;6363	ff 	. 
	rst 38h			;6364	ff 	. 
	rst 38h			;6365	ff 	. 
	rst 38h			;6366	ff 	. 
	rst 38h			;6367	ff 	. 
	rst 38h			;6368	ff 	. 
	rst 38h			;6369	ff 	. 
	rst 38h			;636a	ff 	. 
	rst 38h			;636b	ff 	. 
	rst 38h			;636c	ff 	. 
	rst 38h			;636d	ff 	. 
	rst 38h			;636e	ff 	. 
	rst 38h			;636f	ff 	. 
	rst 38h			;6370	ff 	. 
	rst 38h			;6371	ff 	. 
	rst 38h			;6372	ff 	. 
	rst 38h			;6373	ff 	. 
	rst 38h			;6374	ff 	. 
	rst 38h			;6375	ff 	. 
	rst 38h			;6376	ff 	. 
	rst 38h			;6377	ff 	. 
	rst 38h			;6378	ff 	. 
	rst 38h			;6379	ff 	. 
	rst 38h			;637a	ff 	. 
	rst 38h			;637b	ff 	. 
	rst 38h			;637c	ff 	. 
	rst 38h			;637d	ff 	. 
	rst 38h			;637e	ff 	. 
	rst 38h			;637f	ff 	. 
	rst 38h			;6380	ff 	. 
	rst 38h			;6381	ff 	. 
	rst 38h			;6382	ff 	. 
	rst 38h			;6383	ff 	. 
	rst 38h			;6384	ff 	. 
	rst 38h			;6385	ff 	. 
	rst 38h			;6386	ff 	. 
	rst 38h			;6387	ff 	. 
	rst 38h			;6388	ff 	. 
	rst 38h			;6389	ff 	. 
	rst 38h			;638a	ff 	. 
	rst 38h			;638b	ff 	. 
	rst 38h			;638c	ff 	. 
	rst 38h			;638d	ff 	. 
	rst 38h			;638e	ff 	. 
	rst 38h			;638f	ff 	. 
	rst 38h			;6390	ff 	. 
	rst 38h			;6391	ff 	. 
	rst 38h			;6392	ff 	. 
	rst 38h			;6393	ff 	. 
	rst 38h			;6394	ff 	. 
	rst 38h			;6395	ff 	. 
	rst 38h			;6396	ff 	. 
	rst 38h			;6397	ff 	. 
	rst 38h			;6398	ff 	. 
	rst 38h			;6399	ff 	. 
	rst 38h			;639a	ff 	. 
	rst 38h			;639b	ff 	. 
	rst 38h			;639c	ff 	. 
	rst 38h			;639d	ff 	. 
	rst 38h			;639e	ff 	. 
	rst 38h			;639f	ff 	. 
	rst 38h			;63a0	ff 	. 
	rst 38h			;63a1	ff 	. 
	rst 38h			;63a2	ff 	. 
	rst 38h			;63a3	ff 	. 
	rst 38h			;63a4	ff 	. 
	rst 38h			;63a5	ff 	. 
	rst 38h			;63a6	ff 	. 
	rst 38h			;63a7	ff 	. 
	rst 38h			;63a8	ff 	. 
	rst 38h			;63a9	ff 	. 
	rst 38h			;63aa	ff 	. 
	rst 38h			;63ab	ff 	. 
	rst 38h			;63ac	ff 	. 
	rst 38h			;63ad	ff 	. 
	rst 38h			;63ae	ff 	. 
	rst 38h			;63af	ff 	. 
	rst 38h			;63b0	ff 	. 
	rst 38h			;63b1	ff 	. 
	rst 38h			;63b2	ff 	. 
	rst 38h			;63b3	ff 	. 
	rst 38h			;63b4	ff 	. 
	rst 38h			;63b5	ff 	. 
	rst 38h			;63b6	ff 	. 
	rst 38h			;63b7	ff 	. 
	rst 38h			;63b8	ff 	. 
	rst 38h			;63b9	ff 	. 
	rst 38h			;63ba	ff 	. 
	rst 38h			;63bb	ff 	. 
	rst 38h			;63bc	ff 	. 
	rst 38h			;63bd	ff 	. 
	rst 38h			;63be	ff 	. 
	rst 38h			;63bf	ff 	. 
	rst 38h			;63c0	ff 	. 
	rst 38h			;63c1	ff 	. 
	rst 38h			;63c2	ff 	. 
	rst 38h			;63c3	ff 	. 
	rst 38h			;63c4	ff 	. 
	rst 38h			;63c5	ff 	. 
	rst 38h			;63c6	ff 	. 
	rst 38h			;63c7	ff 	. 
	rst 38h			;63c8	ff 	. 
	rst 38h			;63c9	ff 	. 
	rst 38h			;63ca	ff 	. 
	rst 38h			;63cb	ff 	. 
	rst 38h			;63cc	ff 	. 
	rst 38h			;63cd	ff 	. 
	rst 38h			;63ce	ff 	. 
	rst 38h			;63cf	ff 	. 
	rst 38h			;63d0	ff 	. 
	rst 38h			;63d1	ff 	. 
	rst 38h			;63d2	ff 	. 
	rst 38h			;63d3	ff 	. 
	rst 38h			;63d4	ff 	. 
	rst 38h			;63d5	ff 	. 
	rst 38h			;63d6	ff 	. 
	rst 38h			;63d7	ff 	. 
	rst 38h			;63d8	ff 	. 
	rst 38h			;63d9	ff 	. 
	rst 38h			;63da	ff 	. 
	rst 38h			;63db	ff 	. 
	rst 38h			;63dc	ff 	. 
	rst 38h			;63dd	ff 	. 
	rst 38h			;63de	ff 	. 
	rst 38h			;63df	ff 	. 
	rst 38h			;63e0	ff 	. 
	rst 38h			;63e1	ff 	. 
	rst 38h			;63e2	ff 	. 
	rst 38h			;63e3	ff 	. 
	rst 38h			;63e4	ff 	. 
	rst 38h			;63e5	ff 	. 
	rst 38h			;63e6	ff 	. 
	rst 38h			;63e7	ff 	. 
	rst 38h			;63e8	ff 	. 
	rst 38h			;63e9	ff 	. 
	rst 38h			;63ea	ff 	. 
	rst 38h			;63eb	ff 	. 
	rst 38h			;63ec	ff 	. 
	rst 38h			;63ed	ff 	. 
	rst 38h			;63ee	ff 	. 
	rst 38h			;63ef	ff 	. 
	rst 38h			;63f0	ff 	. 
	rst 38h			;63f1	ff 	. 
	rst 38h			;63f2	ff 	. 
	rst 38h			;63f3	ff 	. 
	rst 38h			;63f4	ff 	. 
	rst 38h			;63f5	ff 	. 
	rst 38h			;63f6	ff 	. 
	rst 38h			;63f7	ff 	. 
	rst 38h			;63f8	ff 	. 
	rst 38h			;63f9	ff 	. 
	rst 38h			;63fa	ff 	. 
	rst 38h			;63fb	ff 	. 
	rst 38h			;63fc	ff 	. 
	rst 38h			;63fd	ff 	. 
	rst 38h			;63fe	ff 	. 
	rst 38h			;63ff	ff 	. 
	rst 38h			;6400	ff 	. 
	rst 38h			;6401	ff 	. 
	rst 38h			;6402	ff 	. 
	rst 38h			;6403	ff 	. 
	rst 38h			;6404	ff 	. 
	rst 38h			;6405	ff 	. 
	rst 38h			;6406	ff 	. 
	rst 38h			;6407	ff 	. 
	rst 38h			;6408	ff 	. 
	rst 38h			;6409	ff 	. 
	rst 38h			;640a	ff 	. 
	rst 38h			;640b	ff 	. 
	rst 38h			;640c	ff 	. 
	rst 38h			;640d	ff 	. 
	rst 38h			;640e	ff 	. 
	rst 38h			;640f	ff 	. 
	rst 38h			;6410	ff 	. 
	rst 38h			;6411	ff 	. 
	rst 38h			;6412	ff 	. 
	rst 38h			;6413	ff 	. 
	rst 38h			;6414	ff 	. 
	rst 38h			;6415	ff 	. 
	rst 38h			;6416	ff 	. 
	rst 38h			;6417	ff 	. 
	rst 38h			;6418	ff 	. 
	rst 38h			;6419	ff 	. 
	rst 38h			;641a	ff 	. 
	rst 38h			;641b	ff 	. 
	rst 38h			;641c	ff 	. 
	rst 38h			;641d	ff 	. 
	rst 38h			;641e	ff 	. 
	rst 38h			;641f	ff 	. 
	rst 38h			;6420	ff 	. 
	rst 38h			;6421	ff 	. 
	rst 38h			;6422	ff 	. 
	rst 38h			;6423	ff 	. 
	rst 38h			;6424	ff 	. 
	rst 38h			;6425	ff 	. 
	rst 38h			;6426	ff 	. 
	rst 38h			;6427	ff 	. 
	rst 38h			;6428	ff 	. 
	rst 38h			;6429	ff 	. 
	rst 38h			;642a	ff 	. 
	rst 38h			;642b	ff 	. 
	rst 38h			;642c	ff 	. 
	rst 38h			;642d	ff 	. 
	rst 38h			;642e	ff 	. 
	rst 38h			;642f	ff 	. 
	rst 38h			;6430	ff 	. 
	rst 38h			;6431	ff 	. 
	rst 38h			;6432	ff 	. 
	rst 38h			;6433	ff 	. 
	rst 38h			;6434	ff 	. 
	rst 38h			;6435	ff 	. 
	rst 38h			;6436	ff 	. 
	rst 38h			;6437	ff 	. 
	rst 38h			;6438	ff 	. 
	rst 38h			;6439	ff 	. 
	rst 38h			;643a	ff 	. 
	rst 38h			;643b	ff 	. 
	rst 38h			;643c	ff 	. 
	rst 38h			;643d	ff 	. 
	rst 38h			;643e	ff 	. 
	rst 38h			;643f	ff 	. 
	rst 38h			;6440	ff 	. 
	rst 38h			;6441	ff 	. 
	rst 38h			;6442	ff 	. 
	rst 38h			;6443	ff 	. 
	rst 38h			;6444	ff 	. 
	rst 38h			;6445	ff 	. 
	rst 38h			;6446	ff 	. 
	rst 38h			;6447	ff 	. 
	rst 38h			;6448	ff 	. 
	rst 38h			;6449	ff 	. 
	rst 38h			;644a	ff 	. 
	rst 38h			;644b	ff 	. 
	rst 38h			;644c	ff 	. 
	rst 38h			;644d	ff 	. 
	rst 38h			;644e	ff 	. 
	rst 38h			;644f	ff 	. 
	rst 38h			;6450	ff 	. 
	rst 38h			;6451	ff 	. 
	rst 38h			;6452	ff 	. 
	rst 38h			;6453	ff 	. 
	rst 38h			;6454	ff 	. 
	rst 38h			;6455	ff 	. 
	rst 38h			;6456	ff 	. 
	rst 38h			;6457	ff 	. 
	rst 38h			;6458	ff 	. 
	rst 38h			;6459	ff 	. 
	rst 38h			;645a	ff 	. 
	rst 38h			;645b	ff 	. 
	rst 38h			;645c	ff 	. 
	rst 38h			;645d	ff 	. 
	rst 38h			;645e	ff 	. 
	rst 38h			;645f	ff 	. 
	rst 38h			;6460	ff 	. 
	rst 38h			;6461	ff 	. 
	rst 38h			;6462	ff 	. 
	rst 38h			;6463	ff 	. 
	rst 38h			;6464	ff 	. 
	rst 38h			;6465	ff 	. 
	rst 38h			;6466	ff 	. 
	rst 38h			;6467	ff 	. 
	rst 38h			;6468	ff 	. 
	rst 38h			;6469	ff 	. 
	rst 38h			;646a	ff 	. 
	rst 38h			;646b	ff 	. 
	rst 38h			;646c	ff 	. 
	rst 38h			;646d	ff 	. 
	rst 38h			;646e	ff 	. 
	rst 38h			;646f	ff 	. 
	rst 38h			;6470	ff 	. 
	rst 38h			;6471	ff 	. 
	rst 38h			;6472	ff 	. 
	rst 38h			;6473	ff 	. 
	rst 38h			;6474	ff 	. 
	rst 38h			;6475	ff 	. 
	rst 38h			;6476	ff 	. 
	rst 38h			;6477	ff 	. 
	rst 38h			;6478	ff 	. 
	rst 38h			;6479	ff 	. 
	rst 38h			;647a	ff 	. 
	rst 38h			;647b	ff 	. 
	rst 38h			;647c	ff 	. 
	rst 38h			;647d	ff 	. 
	rst 38h			;647e	ff 	. 
	rst 38h			;647f	ff 	. 
	rst 38h			;6480	ff 	. 
	rst 38h			;6481	ff 	. 
	rst 38h			;6482	ff 	. 
	rst 38h			;6483	ff 	. 
	rst 38h			;6484	ff 	. 
	rst 38h			;6485	ff 	. 
	rst 38h			;6486	ff 	. 
	rst 38h			;6487	ff 	. 
	rst 38h			;6488	ff 	. 
	rst 38h			;6489	ff 	. 
	rst 38h			;648a	ff 	. 
	rst 38h			;648b	ff 	. 
	rst 38h			;648c	ff 	. 
	rst 38h			;648d	ff 	. 
	rst 38h			;648e	ff 	. 
	rst 38h			;648f	ff 	. 
	rst 38h			;6490	ff 	. 
	rst 38h			;6491	ff 	. 
	rst 38h			;6492	ff 	. 
	rst 38h			;6493	ff 	. 
	rst 38h			;6494	ff 	. 
	rst 38h			;6495	ff 	. 
	rst 38h			;6496	ff 	. 
	rst 38h			;6497	ff 	. 
	rst 38h			;6498	ff 	. 
	rst 38h			;6499	ff 	. 
	rst 38h			;649a	ff 	. 
	rst 38h			;649b	ff 	. 
	rst 38h			;649c	ff 	. 
	rst 38h			;649d	ff 	. 
	rst 38h			;649e	ff 	. 
	rst 38h			;649f	ff 	. 
	rst 38h			;64a0	ff 	. 
	rst 38h			;64a1	ff 	. 
	rst 38h			;64a2	ff 	. 
	rst 38h			;64a3	ff 	. 
	rst 38h			;64a4	ff 	. 
	rst 38h			;64a5	ff 	. 
	rst 38h			;64a6	ff 	. 
	rst 38h			;64a7	ff 	. 
	rst 38h			;64a8	ff 	. 
	rst 38h			;64a9	ff 	. 
	rst 38h			;64aa	ff 	. 
	rst 38h			;64ab	ff 	. 
	rst 38h			;64ac	ff 	. 
	rst 38h			;64ad	ff 	. 
	rst 38h			;64ae	ff 	. 
	rst 38h			;64af	ff 	. 
	rst 38h			;64b0	ff 	. 
	rst 38h			;64b1	ff 	. 
	rst 38h			;64b2	ff 	. 
	rst 38h			;64b3	ff 	. 
	rst 38h			;64b4	ff 	. 
	rst 38h			;64b5	ff 	. 
	rst 38h			;64b6	ff 	. 
	rst 38h			;64b7	ff 	. 
	rst 38h			;64b8	ff 	. 
	rst 38h			;64b9	ff 	. 
	rst 38h			;64ba	ff 	. 
	rst 38h			;64bb	ff 	. 
	rst 38h			;64bc	ff 	. 
	rst 38h			;64bd	ff 	. 
	rst 38h			;64be	ff 	. 
	rst 38h			;64bf	ff 	. 
	rst 38h			;64c0	ff 	. 
	rst 38h			;64c1	ff 	. 
	rst 38h			;64c2	ff 	. 
	rst 38h			;64c3	ff 	. 
	rst 38h			;64c4	ff 	. 
	rst 38h			;64c5	ff 	. 
	rst 38h			;64c6	ff 	. 
	rst 38h			;64c7	ff 	. 
	rst 38h			;64c8	ff 	. 
	rst 38h			;64c9	ff 	. 
	rst 38h			;64ca	ff 	. 
	rst 38h			;64cb	ff 	. 
	rst 38h			;64cc	ff 	. 
	rst 38h			;64cd	ff 	. 
	rst 38h			;64ce	ff 	. 
	rst 38h			;64cf	ff 	. 
	rst 38h			;64d0	ff 	. 
	rst 38h			;64d1	ff 	. 
	rst 38h			;64d2	ff 	. 
	rst 38h			;64d3	ff 	. 
	rst 38h			;64d4	ff 	. 
	rst 38h			;64d5	ff 	. 
	rst 38h			;64d6	ff 	. 
	rst 38h			;64d7	ff 	. 
	rst 38h			;64d8	ff 	. 
	rst 38h			;64d9	ff 	. 
	rst 38h			;64da	ff 	. 
	rst 38h			;64db	ff 	. 
	rst 38h			;64dc	ff 	. 
	rst 38h			;64dd	ff 	. 
	rst 38h			;64de	ff 	. 
	rst 38h			;64df	ff 	. 
	rst 38h			;64e0	ff 	. 
	rst 38h			;64e1	ff 	. 
	rst 38h			;64e2	ff 	. 
	rst 38h			;64e3	ff 	. 
	rst 38h			;64e4	ff 	. 
	rst 38h			;64e5	ff 	. 
	rst 38h			;64e6	ff 	. 
	rst 38h			;64e7	ff 	. 
	rst 38h			;64e8	ff 	. 
	rst 38h			;64e9	ff 	. 
	rst 38h			;64ea	ff 	. 
	rst 38h			;64eb	ff 	. 
	rst 38h			;64ec	ff 	. 
	rst 38h			;64ed	ff 	. 
	rst 38h			;64ee	ff 	. 
	rst 38h			;64ef	ff 	. 
	rst 38h			;64f0	ff 	. 
	rst 38h			;64f1	ff 	. 
	rst 38h			;64f2	ff 	. 
	rst 38h			;64f3	ff 	. 
	rst 38h			;64f4	ff 	. 
	rst 38h			;64f5	ff 	. 
	rst 38h			;64f6	ff 	. 
	rst 38h			;64f7	ff 	. 
	rst 38h			;64f8	ff 	. 
	rst 38h			;64f9	ff 	. 
	rst 38h			;64fa	ff 	. 
	rst 38h			;64fb	ff 	. 
	rst 38h			;64fc	ff 	. 
	rst 38h			;64fd	ff 	. 
	rst 38h			;64fe	ff 	. 
	rst 38h			;64ff	ff 	. 
	rst 38h			;6500	ff 	. 
	rst 38h			;6501	ff 	. 
	rst 38h			;6502	ff 	. 
	rst 38h			;6503	ff 	. 
	rst 38h			;6504	ff 	. 
	rst 38h			;6505	ff 	. 
	rst 38h			;6506	ff 	. 
	rst 38h			;6507	ff 	. 
	rst 38h			;6508	ff 	. 
	rst 38h			;6509	ff 	. 
	rst 38h			;650a	ff 	. 
	rst 38h			;650b	ff 	. 
	rst 38h			;650c	ff 	. 
	rst 38h			;650d	ff 	. 
	rst 38h			;650e	ff 	. 
	rst 38h			;650f	ff 	. 
	rst 38h			;6510	ff 	. 
	rst 38h			;6511	ff 	. 
	rst 38h			;6512	ff 	. 
	rst 38h			;6513	ff 	. 
	rst 38h			;6514	ff 	. 
	rst 38h			;6515	ff 	. 
	rst 38h			;6516	ff 	. 
	rst 38h			;6517	ff 	. 
	rst 38h			;6518	ff 	. 
	rst 38h			;6519	ff 	. 
	rst 38h			;651a	ff 	. 
	rst 38h			;651b	ff 	. 
	rst 38h			;651c	ff 	. 
	rst 38h			;651d	ff 	. 
	rst 38h			;651e	ff 	. 
	rst 38h			;651f	ff 	. 
	rst 38h			;6520	ff 	. 
	rst 38h			;6521	ff 	. 
	rst 38h			;6522	ff 	. 
	rst 38h			;6523	ff 	. 
	rst 38h			;6524	ff 	. 
	rst 38h			;6525	ff 	. 
	rst 38h			;6526	ff 	. 
	rst 38h			;6527	ff 	. 
	rst 38h			;6528	ff 	. 
	rst 38h			;6529	ff 	. 
	rst 38h			;652a	ff 	. 
	rst 38h			;652b	ff 	. 
	rst 38h			;652c	ff 	. 
	rst 38h			;652d	ff 	. 
	rst 38h			;652e	ff 	. 
	rst 38h			;652f	ff 	. 
	rst 38h			;6530	ff 	. 
	rst 38h			;6531	ff 	. 
	rst 38h			;6532	ff 	. 
	rst 38h			;6533	ff 	. 
	rst 38h			;6534	ff 	. 
	rst 38h			;6535	ff 	. 
	rst 38h			;6536	ff 	. 
	rst 38h			;6537	ff 	. 
	rst 38h			;6538	ff 	. 
	rst 38h			;6539	ff 	. 
	rst 38h			;653a	ff 	. 
	rst 38h			;653b	ff 	. 
	rst 38h			;653c	ff 	. 
	rst 38h			;653d	ff 	. 
	rst 38h			;653e	ff 	. 
	rst 38h			;653f	ff 	. 
	rst 38h			;6540	ff 	. 
	rst 38h			;6541	ff 	. 
	rst 38h			;6542	ff 	. 
	rst 38h			;6543	ff 	. 
	rst 38h			;6544	ff 	. 
	rst 38h			;6545	ff 	. 
	rst 38h			;6546	ff 	. 
	rst 38h			;6547	ff 	. 
	rst 38h			;6548	ff 	. 
	rst 38h			;6549	ff 	. 
	rst 38h			;654a	ff 	. 
	rst 38h			;654b	ff 	. 
	rst 38h			;654c	ff 	. 
	rst 38h			;654d	ff 	. 
	rst 38h			;654e	ff 	. 
	rst 38h			;654f	ff 	. 
	rst 38h			;6550	ff 	. 
	rst 38h			;6551	ff 	. 
	rst 38h			;6552	ff 	. 
	rst 38h			;6553	ff 	. 
	rst 38h			;6554	ff 	. 
	rst 38h			;6555	ff 	. 
	rst 38h			;6556	ff 	. 
	rst 38h			;6557	ff 	. 
	rst 38h			;6558	ff 	. 
	rst 38h			;6559	ff 	. 
	rst 38h			;655a	ff 	. 
	rst 38h			;655b	ff 	. 
	rst 38h			;655c	ff 	. 
	rst 38h			;655d	ff 	. 
	rst 38h			;655e	ff 	. 
	rst 38h			;655f	ff 	. 
	rst 38h			;6560	ff 	. 
	rst 38h			;6561	ff 	. 
	rst 38h			;6562	ff 	. 
	rst 38h			;6563	ff 	. 
	rst 38h			;6564	ff 	. 
	rst 38h			;6565	ff 	. 
	rst 38h			;6566	ff 	. 
	rst 38h			;6567	ff 	. 
	rst 38h			;6568	ff 	. 
	rst 38h			;6569	ff 	. 
	rst 38h			;656a	ff 	. 
	rst 38h			;656b	ff 	. 
	rst 38h			;656c	ff 	. 
	rst 38h			;656d	ff 	. 
	rst 38h			;656e	ff 	. 
	rst 38h			;656f	ff 	. 
	rst 38h			;6570	ff 	. 
	rst 38h			;6571	ff 	. 
	rst 38h			;6572	ff 	. 
	rst 38h			;6573	ff 	. 
	rst 38h			;6574	ff 	. 
	rst 38h			;6575	ff 	. 
	rst 38h			;6576	ff 	. 
	rst 38h			;6577	ff 	. 
	rst 38h			;6578	ff 	. 
	rst 38h			;6579	ff 	. 
	rst 38h			;657a	ff 	. 
	rst 38h			;657b	ff 	. 
	rst 38h			;657c	ff 	. 
	rst 38h			;657d	ff 	. 
	rst 38h			;657e	ff 	. 
	rst 38h			;657f	ff 	. 
	rst 38h			;6580	ff 	. 
	rst 38h			;6581	ff 	. 
	rst 38h			;6582	ff 	. 
	rst 38h			;6583	ff 	. 
	rst 38h			;6584	ff 	. 
	rst 38h			;6585	ff 	. 
	rst 38h			;6586	ff 	. 
	rst 38h			;6587	ff 	. 
	rst 38h			;6588	ff 	. 
	rst 38h			;6589	ff 	. 
	rst 38h			;658a	ff 	. 
	rst 38h			;658b	ff 	. 
	rst 38h			;658c	ff 	. 
	rst 38h			;658d	ff 	. 
	rst 38h			;658e	ff 	. 
	rst 38h			;658f	ff 	. 
	rst 38h			;6590	ff 	. 
	rst 38h			;6591	ff 	. 
	rst 38h			;6592	ff 	. 
	rst 38h			;6593	ff 	. 
	rst 38h			;6594	ff 	. 
	rst 38h			;6595	ff 	. 
	rst 38h			;6596	ff 	. 
	rst 38h			;6597	ff 	. 
	rst 38h			;6598	ff 	. 
	rst 38h			;6599	ff 	. 
	rst 38h			;659a	ff 	. 
	rst 38h			;659b	ff 	. 
	rst 38h			;659c	ff 	. 
	rst 38h			;659d	ff 	. 
	rst 38h			;659e	ff 	. 
	rst 38h			;659f	ff 	. 
	rst 38h			;65a0	ff 	. 
	rst 38h			;65a1	ff 	. 
	rst 38h			;65a2	ff 	. 
	rst 38h			;65a3	ff 	. 
	rst 38h			;65a4	ff 	. 
	rst 38h			;65a5	ff 	. 
	rst 38h			;65a6	ff 	. 
	rst 38h			;65a7	ff 	. 
	rst 38h			;65a8	ff 	. 
	rst 38h			;65a9	ff 	. 
	rst 38h			;65aa	ff 	. 
	rst 38h			;65ab	ff 	. 
	rst 38h			;65ac	ff 	. 
	rst 38h			;65ad	ff 	. 
	rst 38h			;65ae	ff 	. 
	rst 38h			;65af	ff 	. 
	rst 38h			;65b0	ff 	. 
	rst 38h			;65b1	ff 	. 
	rst 38h			;65b2	ff 	. 
	rst 38h			;65b3	ff 	. 
	rst 38h			;65b4	ff 	. 
	rst 38h			;65b5	ff 	. 
	rst 38h			;65b6	ff 	. 
	rst 38h			;65b7	ff 	. 
	rst 38h			;65b8	ff 	. 
	rst 38h			;65b9	ff 	. 
	rst 38h			;65ba	ff 	. 
	rst 38h			;65bb	ff 	. 
	rst 38h			;65bc	ff 	. 
	rst 38h			;65bd	ff 	. 
	rst 38h			;65be	ff 	. 
	rst 38h			;65bf	ff 	. 
	rst 38h			;65c0	ff 	. 
	rst 38h			;65c1	ff 	. 
	rst 38h			;65c2	ff 	. 
	rst 38h			;65c3	ff 	. 
	rst 38h			;65c4	ff 	. 
	rst 38h			;65c5	ff 	. 
	rst 38h			;65c6	ff 	. 
	rst 38h			;65c7	ff 	. 
	rst 38h			;65c8	ff 	. 
	rst 38h			;65c9	ff 	. 
	rst 38h			;65ca	ff 	. 
	rst 38h			;65cb	ff 	. 
	rst 38h			;65cc	ff 	. 
	rst 38h			;65cd	ff 	. 
	rst 38h			;65ce	ff 	. 
	rst 38h			;65cf	ff 	. 
	rst 38h			;65d0	ff 	. 
	rst 38h			;65d1	ff 	. 
	rst 38h			;65d2	ff 	. 
	rst 38h			;65d3	ff 	. 
	rst 38h			;65d4	ff 	. 
	rst 38h			;65d5	ff 	. 
	rst 38h			;65d6	ff 	. 
	rst 38h			;65d7	ff 	. 
	rst 38h			;65d8	ff 	. 
	rst 38h			;65d9	ff 	. 
	rst 38h			;65da	ff 	. 
	rst 38h			;65db	ff 	. 
	rst 38h			;65dc	ff 	. 
	rst 38h			;65dd	ff 	. 
	rst 38h			;65de	ff 	. 
	rst 38h			;65df	ff 	. 
	rst 38h			;65e0	ff 	. 
	rst 38h			;65e1	ff 	. 
	rst 38h			;65e2	ff 	. 
	rst 38h			;65e3	ff 	. 
	rst 38h			;65e4	ff 	. 
	rst 38h			;65e5	ff 	. 
	rst 38h			;65e6	ff 	. 
	rst 38h			;65e7	ff 	. 
	rst 38h			;65e8	ff 	. 
	rst 38h			;65e9	ff 	. 
	rst 38h			;65ea	ff 	. 
	rst 38h			;65eb	ff 	. 
	rst 38h			;65ec	ff 	. 
	rst 38h			;65ed	ff 	. 
	rst 38h			;65ee	ff 	. 
	rst 38h			;65ef	ff 	. 
	rst 38h			;65f0	ff 	. 
	rst 38h			;65f1	ff 	. 
	rst 38h			;65f2	ff 	. 
	rst 38h			;65f3	ff 	. 
	rst 38h			;65f4	ff 	. 
	rst 38h			;65f5	ff 	. 
	rst 38h			;65f6	ff 	. 
	rst 38h			;65f7	ff 	. 
	rst 38h			;65f8	ff 	. 
	rst 38h			;65f9	ff 	. 
	rst 38h			;65fa	ff 	. 
	rst 38h			;65fb	ff 	. 
	rst 38h			;65fc	ff 	. 
	rst 38h			;65fd	ff 	. 
	rst 38h			;65fe	ff 	. 
	rst 38h			;65ff	ff 	. 
	rst 38h			;6600	ff 	. 
	rst 38h			;6601	ff 	. 
	rst 38h			;6602	ff 	. 
	rst 38h			;6603	ff 	. 
	rst 38h			;6604	ff 	. 
	rst 38h			;6605	ff 	. 
	rst 38h			;6606	ff 	. 
	rst 38h			;6607	ff 	. 
	rst 38h			;6608	ff 	. 
	rst 38h			;6609	ff 	. 
	rst 38h			;660a	ff 	. 
	rst 38h			;660b	ff 	. 
	rst 38h			;660c	ff 	. 
	rst 38h			;660d	ff 	. 
	rst 38h			;660e	ff 	. 
	rst 38h			;660f	ff 	. 
	rst 38h			;6610	ff 	. 
	rst 38h			;6611	ff 	. 
	rst 38h			;6612	ff 	. 
	rst 38h			;6613	ff 	. 
	rst 38h			;6614	ff 	. 
	rst 38h			;6615	ff 	. 
	rst 38h			;6616	ff 	. 
	rst 38h			;6617	ff 	. 
	rst 38h			;6618	ff 	. 
	rst 38h			;6619	ff 	. 
	rst 38h			;661a	ff 	. 
	rst 38h			;661b	ff 	. 
	rst 38h			;661c	ff 	. 
	rst 38h			;661d	ff 	. 
	rst 38h			;661e	ff 	. 
	rst 38h			;661f	ff 	. 
	rst 38h			;6620	ff 	. 
	rst 38h			;6621	ff 	. 
	rst 38h			;6622	ff 	. 
	rst 38h			;6623	ff 	. 
	rst 38h			;6624	ff 	. 
	rst 38h			;6625	ff 	. 
	rst 38h			;6626	ff 	. 
	rst 38h			;6627	ff 	. 
	rst 38h			;6628	ff 	. 
	rst 38h			;6629	ff 	. 
	rst 38h			;662a	ff 	. 
	rst 38h			;662b	ff 	. 
	rst 38h			;662c	ff 	. 
	rst 38h			;662d	ff 	. 
	rst 38h			;662e	ff 	. 
	rst 38h			;662f	ff 	. 
	rst 38h			;6630	ff 	. 
	rst 38h			;6631	ff 	. 
	rst 38h			;6632	ff 	. 
	rst 38h			;6633	ff 	. 
	rst 38h			;6634	ff 	. 
	rst 38h			;6635	ff 	. 
	rst 38h			;6636	ff 	. 
	rst 38h			;6637	ff 	. 
	rst 38h			;6638	ff 	. 
	rst 38h			;6639	ff 	. 
	rst 38h			;663a	ff 	. 
	rst 38h			;663b	ff 	. 
	rst 38h			;663c	ff 	. 
	rst 38h			;663d	ff 	. 
	rst 38h			;663e	ff 	. 
	rst 38h			;663f	ff 	. 
	rst 38h			;6640	ff 	. 
	rst 38h			;6641	ff 	. 
	rst 38h			;6642	ff 	. 
	rst 38h			;6643	ff 	. 
	rst 38h			;6644	ff 	. 
	rst 38h			;6645	ff 	. 
	rst 38h			;6646	ff 	. 
	rst 38h			;6647	ff 	. 
	rst 38h			;6648	ff 	. 
	rst 38h			;6649	ff 	. 
	rst 38h			;664a	ff 	. 
	rst 38h			;664b	ff 	. 
	rst 38h			;664c	ff 	. 
	rst 38h			;664d	ff 	. 
	rst 38h			;664e	ff 	. 
	rst 38h			;664f	ff 	. 
	rst 38h			;6650	ff 	. 
	rst 38h			;6651	ff 	. 
	rst 38h			;6652	ff 	. 
	rst 38h			;6653	ff 	. 
	rst 38h			;6654	ff 	. 
	rst 38h			;6655	ff 	. 
	rst 38h			;6656	ff 	. 
	rst 38h			;6657	ff 	. 
	rst 38h			;6658	ff 	. 
	rst 38h			;6659	ff 	. 
	rst 38h			;665a	ff 	. 
	rst 38h			;665b	ff 	. 
	rst 38h			;665c	ff 	. 
	rst 38h			;665d	ff 	. 
	rst 38h			;665e	ff 	. 
	rst 38h			;665f	ff 	. 
	rst 38h			;6660	ff 	. 
	rst 38h			;6661	ff 	. 
	rst 38h			;6662	ff 	. 
	rst 38h			;6663	ff 	. 
	rst 38h			;6664	ff 	. 
	rst 38h			;6665	ff 	. 
	rst 38h			;6666	ff 	. 
	rst 38h			;6667	ff 	. 
	rst 38h			;6668	ff 	. 
	rst 38h			;6669	ff 	. 
	rst 38h			;666a	ff 	. 
	rst 38h			;666b	ff 	. 
	rst 38h			;666c	ff 	. 
	rst 38h			;666d	ff 	. 
	rst 38h			;666e	ff 	. 
	rst 38h			;666f	ff 	. 
	rst 38h			;6670	ff 	. 
	rst 38h			;6671	ff 	. 
	rst 38h			;6672	ff 	. 
	rst 38h			;6673	ff 	. 
	rst 38h			;6674	ff 	. 
	rst 38h			;6675	ff 	. 
	rst 38h			;6676	ff 	. 
	rst 38h			;6677	ff 	. 
	rst 38h			;6678	ff 	. 
	rst 38h			;6679	ff 	. 
	rst 38h			;667a	ff 	. 
	rst 38h			;667b	ff 	. 
	rst 38h			;667c	ff 	. 
	rst 38h			;667d	ff 	. 
	rst 38h			;667e	ff 	. 
	rst 38h			;667f	ff 	. 
	rst 38h			;6680	ff 	. 
	rst 38h			;6681	ff 	. 
	rst 38h			;6682	ff 	. 
	rst 38h			;6683	ff 	. 
	rst 38h			;6684	ff 	. 
	rst 38h			;6685	ff 	. 
	rst 38h			;6686	ff 	. 
	rst 38h			;6687	ff 	. 
	rst 38h			;6688	ff 	. 
	rst 38h			;6689	ff 	. 
	rst 38h			;668a	ff 	. 
	rst 38h			;668b	ff 	. 
	rst 38h			;668c	ff 	. 
	rst 38h			;668d	ff 	. 
	rst 38h			;668e	ff 	. 
	rst 38h			;668f	ff 	. 
	rst 38h			;6690	ff 	. 
	rst 38h			;6691	ff 	. 
	rst 38h			;6692	ff 	. 
	rst 38h			;6693	ff 	. 
	rst 38h			;6694	ff 	. 
	rst 38h			;6695	ff 	. 
	rst 38h			;6696	ff 	. 
	rst 38h			;6697	ff 	. 
	rst 38h			;6698	ff 	. 
	rst 38h			;6699	ff 	. 
	rst 38h			;669a	ff 	. 
	rst 38h			;669b	ff 	. 
	rst 38h			;669c	ff 	. 
	rst 38h			;669d	ff 	. 
	rst 38h			;669e	ff 	. 
	rst 38h			;669f	ff 	. 
	rst 38h			;66a0	ff 	. 
	rst 38h			;66a1	ff 	. 
	rst 38h			;66a2	ff 	. 
	rst 38h			;66a3	ff 	. 
	rst 38h			;66a4	ff 	. 
	rst 38h			;66a5	ff 	. 
	rst 38h			;66a6	ff 	. 
	rst 38h			;66a7	ff 	. 
	rst 38h			;66a8	ff 	. 
	rst 38h			;66a9	ff 	. 
	rst 38h			;66aa	ff 	. 
	rst 38h			;66ab	ff 	. 
	rst 38h			;66ac	ff 	. 
	rst 38h			;66ad	ff 	. 
	rst 38h			;66ae	ff 	. 
	rst 38h			;66af	ff 	. 
	rst 38h			;66b0	ff 	. 
	rst 38h			;66b1	ff 	. 
	rst 38h			;66b2	ff 	. 
	rst 38h			;66b3	ff 	. 
	rst 38h			;66b4	ff 	. 
	rst 38h			;66b5	ff 	. 
	rst 38h			;66b6	ff 	. 
	rst 38h			;66b7	ff 	. 
	rst 38h			;66b8	ff 	. 
	rst 38h			;66b9	ff 	. 
	rst 38h			;66ba	ff 	. 
	rst 38h			;66bb	ff 	. 
	rst 38h			;66bc	ff 	. 
	rst 38h			;66bd	ff 	. 
	rst 38h			;66be	ff 	. 
	rst 38h			;66bf	ff 	. 
	rst 38h			;66c0	ff 	. 
	rst 38h			;66c1	ff 	. 
	rst 38h			;66c2	ff 	. 
	rst 38h			;66c3	ff 	. 
	rst 38h			;66c4	ff 	. 
	rst 38h			;66c5	ff 	. 
	rst 38h			;66c6	ff 	. 
	rst 38h			;66c7	ff 	. 
	rst 38h			;66c8	ff 	. 
	rst 38h			;66c9	ff 	. 
	rst 38h			;66ca	ff 	. 
	rst 38h			;66cb	ff 	. 
	rst 38h			;66cc	ff 	. 
	rst 38h			;66cd	ff 	. 
	rst 38h			;66ce	ff 	. 
	rst 38h			;66cf	ff 	. 
	rst 38h			;66d0	ff 	. 
	rst 38h			;66d1	ff 	. 
	rst 38h			;66d2	ff 	. 
	rst 38h			;66d3	ff 	. 
	rst 38h			;66d4	ff 	. 
	rst 38h			;66d5	ff 	. 
	rst 38h			;66d6	ff 	. 
	rst 38h			;66d7	ff 	. 
	rst 38h			;66d8	ff 	. 
	rst 38h			;66d9	ff 	. 
	rst 38h			;66da	ff 	. 
	rst 38h			;66db	ff 	. 
	rst 38h			;66dc	ff 	. 
	rst 38h			;66dd	ff 	. 
	rst 38h			;66de	ff 	. 
	rst 38h			;66df	ff 	. 
	rst 38h			;66e0	ff 	. 
	rst 38h			;66e1	ff 	. 
	rst 38h			;66e2	ff 	. 
	rst 38h			;66e3	ff 	. 
	rst 38h			;66e4	ff 	. 
	rst 38h			;66e5	ff 	. 
	rst 38h			;66e6	ff 	. 
	rst 38h			;66e7	ff 	. 
	rst 38h			;66e8	ff 	. 
	rst 38h			;66e9	ff 	. 
	rst 38h			;66ea	ff 	. 
	rst 38h			;66eb	ff 	. 
	rst 38h			;66ec	ff 	. 
	rst 38h			;66ed	ff 	. 
	rst 38h			;66ee	ff 	. 
	rst 38h			;66ef	ff 	. 
	rst 38h			;66f0	ff 	. 
	rst 38h			;66f1	ff 	. 
	rst 38h			;66f2	ff 	. 
	rst 38h			;66f3	ff 	. 
	rst 38h			;66f4	ff 	. 
	rst 38h			;66f5	ff 	. 
	rst 38h			;66f6	ff 	. 
	rst 38h			;66f7	ff 	. 
	rst 38h			;66f8	ff 	. 
	rst 38h			;66f9	ff 	. 
	rst 38h			;66fa	ff 	. 
	rst 38h			;66fb	ff 	. 
	rst 38h			;66fc	ff 	. 
	rst 38h			;66fd	ff 	. 
	rst 38h			;66fe	ff 	. 
	rst 38h			;66ff	ff 	. 
	rst 38h			;6700	ff 	. 
	rst 38h			;6701	ff 	. 
	rst 38h			;6702	ff 	. 
	rst 38h			;6703	ff 	. 
	rst 38h			;6704	ff 	. 
	rst 38h			;6705	ff 	. 
	rst 38h			;6706	ff 	. 
	rst 38h			;6707	ff 	. 
	rst 38h			;6708	ff 	. 
	rst 38h			;6709	ff 	. 
	rst 38h			;670a	ff 	. 
	rst 38h			;670b	ff 	. 
	rst 38h			;670c	ff 	. 
	rst 38h			;670d	ff 	. 
	rst 38h			;670e	ff 	. 
	rst 38h			;670f	ff 	. 
	rst 38h			;6710	ff 	. 
	rst 38h			;6711	ff 	. 
	rst 38h			;6712	ff 	. 
	rst 38h			;6713	ff 	. 
	rst 38h			;6714	ff 	. 
	rst 38h			;6715	ff 	. 
	rst 38h			;6716	ff 	. 
	rst 38h			;6717	ff 	. 
	rst 38h			;6718	ff 	. 
	rst 38h			;6719	ff 	. 
	rst 38h			;671a	ff 	. 
	rst 38h			;671b	ff 	. 
	rst 38h			;671c	ff 	. 
	rst 38h			;671d	ff 	. 
	rst 38h			;671e	ff 	. 
	rst 38h			;671f	ff 	. 
	rst 38h			;6720	ff 	. 
	rst 38h			;6721	ff 	. 
	rst 38h			;6722	ff 	. 
	rst 38h			;6723	ff 	. 
	rst 38h			;6724	ff 	. 
	rst 38h			;6725	ff 	. 
	rst 38h			;6726	ff 	. 
	rst 38h			;6727	ff 	. 
	rst 38h			;6728	ff 	. 
	rst 38h			;6729	ff 	. 
	rst 38h			;672a	ff 	. 
	rst 38h			;672b	ff 	. 
	rst 38h			;672c	ff 	. 
	rst 38h			;672d	ff 	. 
	rst 38h			;672e	ff 	. 
	rst 38h			;672f	ff 	. 
	rst 38h			;6730	ff 	. 
	rst 38h			;6731	ff 	. 
	rst 38h			;6732	ff 	. 
	rst 38h			;6733	ff 	. 
	rst 38h			;6734	ff 	. 
	rst 38h			;6735	ff 	. 
	rst 38h			;6736	ff 	. 
	rst 38h			;6737	ff 	. 
	rst 38h			;6738	ff 	. 
	rst 38h			;6739	ff 	. 
	rst 38h			;673a	ff 	. 
	rst 38h			;673b	ff 	. 
	rst 38h			;673c	ff 	. 
	rst 38h			;673d	ff 	. 
	rst 38h			;673e	ff 	. 
	rst 38h			;673f	ff 	. 
	rst 38h			;6740	ff 	. 
	rst 38h			;6741	ff 	. 
	rst 38h			;6742	ff 	. 
	rst 38h			;6743	ff 	. 
	rst 38h			;6744	ff 	. 
	rst 38h			;6745	ff 	. 
	rst 38h			;6746	ff 	. 
	rst 38h			;6747	ff 	. 
	rst 38h			;6748	ff 	. 
	rst 38h			;6749	ff 	. 
	rst 38h			;674a	ff 	. 
	rst 38h			;674b	ff 	. 
	rst 38h			;674c	ff 	. 
	rst 38h			;674d	ff 	. 
	rst 38h			;674e	ff 	. 
	rst 38h			;674f	ff 	. 
	rst 38h			;6750	ff 	. 
	rst 38h			;6751	ff 	. 
	rst 38h			;6752	ff 	. 
	rst 38h			;6753	ff 	. 
	rst 38h			;6754	ff 	. 
	rst 38h			;6755	ff 	. 
	rst 38h			;6756	ff 	. 
	rst 38h			;6757	ff 	. 
	rst 38h			;6758	ff 	. 
	rst 38h			;6759	ff 	. 
	rst 38h			;675a	ff 	. 
	rst 38h			;675b	ff 	. 
	rst 38h			;675c	ff 	. 
	rst 38h			;675d	ff 	. 
	rst 38h			;675e	ff 	. 
	rst 38h			;675f	ff 	. 
	rst 38h			;6760	ff 	. 
	rst 38h			;6761	ff 	. 
	rst 38h			;6762	ff 	. 
	rst 38h			;6763	ff 	. 
	rst 38h			;6764	ff 	. 
	rst 38h			;6765	ff 	. 
	rst 38h			;6766	ff 	. 
	rst 38h			;6767	ff 	. 
	rst 38h			;6768	ff 	. 
	rst 38h			;6769	ff 	. 
	rst 38h			;676a	ff 	. 
	rst 38h			;676b	ff 	. 
	rst 38h			;676c	ff 	. 
	rst 38h			;676d	ff 	. 
	rst 38h			;676e	ff 	. 
	rst 38h			;676f	ff 	. 
	rst 38h			;6770	ff 	. 
	rst 38h			;6771	ff 	. 
	rst 38h			;6772	ff 	. 
	rst 38h			;6773	ff 	. 
	rst 38h			;6774	ff 	. 
	rst 38h			;6775	ff 	. 
	rst 38h			;6776	ff 	. 
	rst 38h			;6777	ff 	. 
	rst 38h			;6778	ff 	. 
	rst 38h			;6779	ff 	. 
	rst 38h			;677a	ff 	. 
	rst 38h			;677b	ff 	. 
	rst 38h			;677c	ff 	. 
	rst 38h			;677d	ff 	. 
	rst 38h			;677e	ff 	. 
	rst 38h			;677f	ff 	. 
	rst 38h			;6780	ff 	. 
	rst 38h			;6781	ff 	. 
	rst 38h			;6782	ff 	. 
	rst 38h			;6783	ff 	. 
	rst 38h			;6784	ff 	. 
	rst 38h			;6785	ff 	. 
	rst 38h			;6786	ff 	. 
	rst 38h			;6787	ff 	. 
	rst 38h			;6788	ff 	. 
	rst 38h			;6789	ff 	. 
	rst 38h			;678a	ff 	. 
	rst 38h			;678b	ff 	. 
	rst 38h			;678c	ff 	. 
	rst 38h			;678d	ff 	. 
	rst 38h			;678e	ff 	. 
	rst 38h			;678f	ff 	. 
	rst 38h			;6790	ff 	. 
	rst 38h			;6791	ff 	. 
	rst 38h			;6792	ff 	. 
	rst 38h			;6793	ff 	. 
	rst 38h			;6794	ff 	. 
	rst 38h			;6795	ff 	. 
	rst 38h			;6796	ff 	. 
	rst 38h			;6797	ff 	. 
	rst 38h			;6798	ff 	. 
	rst 38h			;6799	ff 	. 
	rst 38h			;679a	ff 	. 
	rst 38h			;679b	ff 	. 
	rst 38h			;679c	ff 	. 
	rst 38h			;679d	ff 	. 
	rst 38h			;679e	ff 	. 
	rst 38h			;679f	ff 	. 
	rst 38h			;67a0	ff 	. 
	rst 38h			;67a1	ff 	. 
	rst 38h			;67a2	ff 	. 
	rst 38h			;67a3	ff 	. 
	rst 38h			;67a4	ff 	. 
	rst 38h			;67a5	ff 	. 
	rst 38h			;67a6	ff 	. 
	rst 38h			;67a7	ff 	. 
	rst 38h			;67a8	ff 	. 
	rst 38h			;67a9	ff 	. 
	rst 38h			;67aa	ff 	. 
	rst 38h			;67ab	ff 	. 
	rst 38h			;67ac	ff 	. 
	rst 38h			;67ad	ff 	. 
	rst 38h			;67ae	ff 	. 
	rst 38h			;67af	ff 	. 
	rst 38h			;67b0	ff 	. 
	rst 38h			;67b1	ff 	. 
	rst 38h			;67b2	ff 	. 
	rst 38h			;67b3	ff 	. 
	rst 38h			;67b4	ff 	. 
	rst 38h			;67b5	ff 	. 
	rst 38h			;67b6	ff 	. 
	rst 38h			;67b7	ff 	. 
	rst 38h			;67b8	ff 	. 
	rst 38h			;67b9	ff 	. 
	rst 38h			;67ba	ff 	. 
	rst 38h			;67bb	ff 	. 
	rst 38h			;67bc	ff 	. 
	rst 38h			;67bd	ff 	. 
	rst 38h			;67be	ff 	. 
	rst 38h			;67bf	ff 	. 
	rst 38h			;67c0	ff 	. 
	rst 38h			;67c1	ff 	. 
	rst 38h			;67c2	ff 	. 
	rst 38h			;67c3	ff 	. 
	rst 38h			;67c4	ff 	. 
	rst 38h			;67c5	ff 	. 
	rst 38h			;67c6	ff 	. 
	rst 38h			;67c7	ff 	. 
	rst 38h			;67c8	ff 	. 
	rst 38h			;67c9	ff 	. 
	rst 38h			;67ca	ff 	. 
	rst 38h			;67cb	ff 	. 
	rst 38h			;67cc	ff 	. 
	rst 38h			;67cd	ff 	. 
	rst 38h			;67ce	ff 	. 
	rst 38h			;67cf	ff 	. 
	rst 38h			;67d0	ff 	. 
	rst 38h			;67d1	ff 	. 
	rst 38h			;67d2	ff 	. 
	rst 38h			;67d3	ff 	. 
	rst 38h			;67d4	ff 	. 
	rst 38h			;67d5	ff 	. 
	rst 38h			;67d6	ff 	. 
	rst 38h			;67d7	ff 	. 
	rst 38h			;67d8	ff 	. 
	rst 38h			;67d9	ff 	. 
	rst 38h			;67da	ff 	. 
	rst 38h			;67db	ff 	. 
	rst 38h			;67dc	ff 	. 
	rst 38h			;67dd	ff 	. 
	rst 38h			;67de	ff 	. 
	rst 38h			;67df	ff 	. 
	rst 38h			;67e0	ff 	. 
	rst 38h			;67e1	ff 	. 
	rst 38h			;67e2	ff 	. 
	rst 38h			;67e3	ff 	. 
	rst 38h			;67e4	ff 	. 
	rst 38h			;67e5	ff 	. 
	rst 38h			;67e6	ff 	. 
	rst 38h			;67e7	ff 	. 
	rst 38h			;67e8	ff 	. 
	rst 38h			;67e9	ff 	. 
	rst 38h			;67ea	ff 	. 
	rst 38h			;67eb	ff 	. 
	rst 38h			;67ec	ff 	. 
	rst 38h			;67ed	ff 	. 
	rst 38h			;67ee	ff 	. 
	rst 38h			;67ef	ff 	. 
	rst 38h			;67f0	ff 	. 
	rst 38h			;67f1	ff 	. 
	rst 38h			;67f2	ff 	. 
	rst 38h			;67f3	ff 	. 
	rst 38h			;67f4	ff 	. 
	rst 38h			;67f5	ff 	. 
	rst 38h			;67f6	ff 	. 
	rst 38h			;67f7	ff 	. 
	rst 38h			;67f8	ff 	. 
	rst 38h			;67f9	ff 	. 
	rst 38h			;67fa	ff 	. 
	rst 38h			;67fb	ff 	. 
	rst 38h			;67fc	ff 	. 
	rst 38h			;67fd	ff 	. 
	rst 38h			;67fe	ff 	. 
	rst 38h			;67ff	ff 	. 
	rst 38h			;6800	ff 	. 
	rst 38h			;6801	ff 	. 
	rst 38h			;6802	ff 	. 
	rst 38h			;6803	ff 	. 
	rst 38h			;6804	ff 	. 
	rst 38h			;6805	ff 	. 
	rst 38h			;6806	ff 	. 
	rst 38h			;6807	ff 	. 
	rst 38h			;6808	ff 	. 
	rst 38h			;6809	ff 	. 
	rst 38h			;680a	ff 	. 
	rst 38h			;680b	ff 	. 
	rst 38h			;680c	ff 	. 
	rst 38h			;680d	ff 	. 
	rst 38h			;680e	ff 	. 
	rst 38h			;680f	ff 	. 
	rst 38h			;6810	ff 	. 
	rst 38h			;6811	ff 	. 
	rst 38h			;6812	ff 	. 
	rst 38h			;6813	ff 	. 
	rst 38h			;6814	ff 	. 
	rst 38h			;6815	ff 	. 
	rst 38h			;6816	ff 	. 
	rst 38h			;6817	ff 	. 
	rst 38h			;6818	ff 	. 
	rst 38h			;6819	ff 	. 
	rst 38h			;681a	ff 	. 
	rst 38h			;681b	ff 	. 
	rst 38h			;681c	ff 	. 
	rst 38h			;681d	ff 	. 
	rst 38h			;681e	ff 	. 
	rst 38h			;681f	ff 	. 
	rst 38h			;6820	ff 	. 
	rst 38h			;6821	ff 	. 
	rst 38h			;6822	ff 	. 
	rst 38h			;6823	ff 	. 
	rst 38h			;6824	ff 	. 
	rst 38h			;6825	ff 	. 
	rst 38h			;6826	ff 	. 
	rst 38h			;6827	ff 	. 
	rst 38h			;6828	ff 	. 
	rst 38h			;6829	ff 	. 
	rst 38h			;682a	ff 	. 
	rst 38h			;682b	ff 	. 
	rst 38h			;682c	ff 	. 
	rst 38h			;682d	ff 	. 
	rst 38h			;682e	ff 	. 
	rst 38h			;682f	ff 	. 
	rst 38h			;6830	ff 	. 
	rst 38h			;6831	ff 	. 
	rst 38h			;6832	ff 	. 
	rst 38h			;6833	ff 	. 
	rst 38h			;6834	ff 	. 
	rst 38h			;6835	ff 	. 
	rst 38h			;6836	ff 	. 
	rst 38h			;6837	ff 	. 
	rst 38h			;6838	ff 	. 
	rst 38h			;6839	ff 	. 
	rst 38h			;683a	ff 	. 
	rst 38h			;683b	ff 	. 
	rst 38h			;683c	ff 	. 
	rst 38h			;683d	ff 	. 
	rst 38h			;683e	ff 	. 
	rst 38h			;683f	ff 	. 
	rst 38h			;6840	ff 	. 
	rst 38h			;6841	ff 	. 
	rst 38h			;6842	ff 	. 
	rst 38h			;6843	ff 	. 
	rst 38h			;6844	ff 	. 
	rst 38h			;6845	ff 	. 
	rst 38h			;6846	ff 	. 
	rst 38h			;6847	ff 	. 
	rst 38h			;6848	ff 	. 
	rst 38h			;6849	ff 	. 
	rst 38h			;684a	ff 	. 
	rst 38h			;684b	ff 	. 
	rst 38h			;684c	ff 	. 
	rst 38h			;684d	ff 	. 
	rst 38h			;684e	ff 	. 
	rst 38h			;684f	ff 	. 
	rst 38h			;6850	ff 	. 
	rst 38h			;6851	ff 	. 
	rst 38h			;6852	ff 	. 
	rst 38h			;6853	ff 	. 
	rst 38h			;6854	ff 	. 
	rst 38h			;6855	ff 	. 
	rst 38h			;6856	ff 	. 
	rst 38h			;6857	ff 	. 
	rst 38h			;6858	ff 	. 
	rst 38h			;6859	ff 	. 
	rst 38h			;685a	ff 	. 
	rst 38h			;685b	ff 	. 
	rst 38h			;685c	ff 	. 
	rst 38h			;685d	ff 	. 
	rst 38h			;685e	ff 	. 
	rst 38h			;685f	ff 	. 
	rst 38h			;6860	ff 	. 
	rst 38h			;6861	ff 	. 
	rst 38h			;6862	ff 	. 
	rst 38h			;6863	ff 	. 
	rst 38h			;6864	ff 	. 
	rst 38h			;6865	ff 	. 
	rst 38h			;6866	ff 	. 
	rst 38h			;6867	ff 	. 
	rst 38h			;6868	ff 	. 
	rst 38h			;6869	ff 	. 
	rst 38h			;686a	ff 	. 
	rst 38h			;686b	ff 	. 
	rst 38h			;686c	ff 	. 
	rst 38h			;686d	ff 	. 
	rst 38h			;686e	ff 	. 
	rst 38h			;686f	ff 	. 
	rst 38h			;6870	ff 	. 
	rst 38h			;6871	ff 	. 
	rst 38h			;6872	ff 	. 
	rst 38h			;6873	ff 	. 
	rst 38h			;6874	ff 	. 
	rst 38h			;6875	ff 	. 
	rst 38h			;6876	ff 	. 
	rst 38h			;6877	ff 	. 
	rst 38h			;6878	ff 	. 
	rst 38h			;6879	ff 	. 
	rst 38h			;687a	ff 	. 
	rst 38h			;687b	ff 	. 
	rst 38h			;687c	ff 	. 
	rst 38h			;687d	ff 	. 
	rst 38h			;687e	ff 	. 
	rst 38h			;687f	ff 	. 
	rst 38h			;6880	ff 	. 
	rst 38h			;6881	ff 	. 
	rst 38h			;6882	ff 	. 
	rst 38h			;6883	ff 	. 
	rst 38h			;6884	ff 	. 
	rst 38h			;6885	ff 	. 
	rst 38h			;6886	ff 	. 
	rst 38h			;6887	ff 	. 
	rst 38h			;6888	ff 	. 
	rst 38h			;6889	ff 	. 
	rst 38h			;688a	ff 	. 
	rst 38h			;688b	ff 	. 
	rst 38h			;688c	ff 	. 
	rst 38h			;688d	ff 	. 
	rst 38h			;688e	ff 	. 
	rst 38h			;688f	ff 	. 
	rst 38h			;6890	ff 	. 
	rst 38h			;6891	ff 	. 
	rst 38h			;6892	ff 	. 
	rst 38h			;6893	ff 	. 
	rst 38h			;6894	ff 	. 
	rst 38h			;6895	ff 	. 
	rst 38h			;6896	ff 	. 
	rst 38h			;6897	ff 	. 
	rst 38h			;6898	ff 	. 
	rst 38h			;6899	ff 	. 
	rst 38h			;689a	ff 	. 
	rst 38h			;689b	ff 	. 
	rst 38h			;689c	ff 	. 
	rst 38h			;689d	ff 	. 
	rst 38h			;689e	ff 	. 
	rst 38h			;689f	ff 	. 
	rst 38h			;68a0	ff 	. 
	rst 38h			;68a1	ff 	. 
	rst 38h			;68a2	ff 	. 
	rst 38h			;68a3	ff 	. 
	rst 38h			;68a4	ff 	. 
	rst 38h			;68a5	ff 	. 
	rst 38h			;68a6	ff 	. 
	rst 38h			;68a7	ff 	. 
	rst 38h			;68a8	ff 	. 
	rst 38h			;68a9	ff 	. 
	rst 38h			;68aa	ff 	. 
	rst 38h			;68ab	ff 	. 
	rst 38h			;68ac	ff 	. 
	rst 38h			;68ad	ff 	. 
	rst 38h			;68ae	ff 	. 
	rst 38h			;68af	ff 	. 
	rst 38h			;68b0	ff 	. 
	rst 38h			;68b1	ff 	. 
	rst 38h			;68b2	ff 	. 
	rst 38h			;68b3	ff 	. 
	rst 38h			;68b4	ff 	. 
	rst 38h			;68b5	ff 	. 
	rst 38h			;68b6	ff 	. 
	rst 38h			;68b7	ff 	. 
	rst 38h			;68b8	ff 	. 
	rst 38h			;68b9	ff 	. 
	rst 38h			;68ba	ff 	. 
	rst 38h			;68bb	ff 	. 
	rst 38h			;68bc	ff 	. 
	rst 38h			;68bd	ff 	. 
	rst 38h			;68be	ff 	. 
	rst 38h			;68bf	ff 	. 
	rst 38h			;68c0	ff 	. 
	rst 38h			;68c1	ff 	. 
	rst 38h			;68c2	ff 	. 
	rst 38h			;68c3	ff 	. 
	rst 38h			;68c4	ff 	. 
	rst 38h			;68c5	ff 	. 
	rst 38h			;68c6	ff 	. 
	rst 38h			;68c7	ff 	. 
	rst 38h			;68c8	ff 	. 
	rst 38h			;68c9	ff 	. 
	rst 38h			;68ca	ff 	. 
	rst 38h			;68cb	ff 	. 
	rst 38h			;68cc	ff 	. 
	rst 38h			;68cd	ff 	. 
	rst 38h			;68ce	ff 	. 
	rst 38h			;68cf	ff 	. 
	rst 38h			;68d0	ff 	. 
	rst 38h			;68d1	ff 	. 
	rst 38h			;68d2	ff 	. 
	rst 38h			;68d3	ff 	. 
	rst 38h			;68d4	ff 	. 
	rst 38h			;68d5	ff 	. 
	rst 38h			;68d6	ff 	. 
	rst 38h			;68d7	ff 	. 
	rst 38h			;68d8	ff 	. 
	rst 38h			;68d9	ff 	. 
	rst 38h			;68da	ff 	. 
	rst 38h			;68db	ff 	. 
	rst 38h			;68dc	ff 	. 
	rst 38h			;68dd	ff 	. 
	rst 38h			;68de	ff 	. 
	rst 38h			;68df	ff 	. 
	rst 38h			;68e0	ff 	. 
	rst 38h			;68e1	ff 	. 
	rst 38h			;68e2	ff 	. 
	rst 38h			;68e3	ff 	. 
	rst 38h			;68e4	ff 	. 
	rst 38h			;68e5	ff 	. 
	rst 38h			;68e6	ff 	. 
	rst 38h			;68e7	ff 	. 
	rst 38h			;68e8	ff 	. 
	rst 38h			;68e9	ff 	. 
	rst 38h			;68ea	ff 	. 
	rst 38h			;68eb	ff 	. 
	rst 38h			;68ec	ff 	. 
	rst 38h			;68ed	ff 	. 
	rst 38h			;68ee	ff 	. 
	rst 38h			;68ef	ff 	. 
	rst 38h			;68f0	ff 	. 
	rst 38h			;68f1	ff 	. 
	rst 38h			;68f2	ff 	. 
	rst 38h			;68f3	ff 	. 
	rst 38h			;68f4	ff 	. 
	rst 38h			;68f5	ff 	. 
	rst 38h			;68f6	ff 	. 
	rst 38h			;68f7	ff 	. 
	rst 38h			;68f8	ff 	. 
	rst 38h			;68f9	ff 	. 
	rst 38h			;68fa	ff 	. 
	rst 38h			;68fb	ff 	. 
	rst 38h			;68fc	ff 	. 
	rst 38h			;68fd	ff 	. 
	rst 38h			;68fe	ff 	. 
	rst 38h			;68ff	ff 	. 
	rst 38h			;6900	ff 	. 
	rst 38h			;6901	ff 	. 
	rst 38h			;6902	ff 	. 
	rst 38h			;6903	ff 	. 
	rst 38h			;6904	ff 	. 
	rst 38h			;6905	ff 	. 
	rst 38h			;6906	ff 	. 
	rst 38h			;6907	ff 	. 
	rst 38h			;6908	ff 	. 
	rst 38h			;6909	ff 	. 
	rst 38h			;690a	ff 	. 
	rst 38h			;690b	ff 	. 
	rst 38h			;690c	ff 	. 
	rst 38h			;690d	ff 	. 
	rst 38h			;690e	ff 	. 
	rst 38h			;690f	ff 	. 
	rst 38h			;6910	ff 	. 
	rst 38h			;6911	ff 	. 
	rst 38h			;6912	ff 	. 
	rst 38h			;6913	ff 	. 
	rst 38h			;6914	ff 	. 
	rst 38h			;6915	ff 	. 
	rst 38h			;6916	ff 	. 
	rst 38h			;6917	ff 	. 
	rst 38h			;6918	ff 	. 
	rst 38h			;6919	ff 	. 
	rst 38h			;691a	ff 	. 
	rst 38h			;691b	ff 	. 
	rst 38h			;691c	ff 	. 
	rst 38h			;691d	ff 	. 
	rst 38h			;691e	ff 	. 
	rst 38h			;691f	ff 	. 
	rst 38h			;6920	ff 	. 
	rst 38h			;6921	ff 	. 
	rst 38h			;6922	ff 	. 
	rst 38h			;6923	ff 	. 
	rst 38h			;6924	ff 	. 
	rst 38h			;6925	ff 	. 
	rst 38h			;6926	ff 	. 
	rst 38h			;6927	ff 	. 
	rst 38h			;6928	ff 	. 
	rst 38h			;6929	ff 	. 
	rst 38h			;692a	ff 	. 
	rst 38h			;692b	ff 	. 
	rst 38h			;692c	ff 	. 
	rst 38h			;692d	ff 	. 
	rst 38h			;692e	ff 	. 
	rst 38h			;692f	ff 	. 
	rst 38h			;6930	ff 	. 
	rst 38h			;6931	ff 	. 
	rst 38h			;6932	ff 	. 
	rst 38h			;6933	ff 	. 
	rst 38h			;6934	ff 	. 
	rst 38h			;6935	ff 	. 
	rst 38h			;6936	ff 	. 
	rst 38h			;6937	ff 	. 
	rst 38h			;6938	ff 	. 
	rst 38h			;6939	ff 	. 
	rst 38h			;693a	ff 	. 
	rst 38h			;693b	ff 	. 
	rst 38h			;693c	ff 	. 
	rst 38h			;693d	ff 	. 
	rst 38h			;693e	ff 	. 
	rst 38h			;693f	ff 	. 
	rst 38h			;6940	ff 	. 
	rst 38h			;6941	ff 	. 
	rst 38h			;6942	ff 	. 
	rst 38h			;6943	ff 	. 
	rst 38h			;6944	ff 	. 
	rst 38h			;6945	ff 	. 
	rst 38h			;6946	ff 	. 
	rst 38h			;6947	ff 	. 
	rst 38h			;6948	ff 	. 
	rst 38h			;6949	ff 	. 
	rst 38h			;694a	ff 	. 
	rst 38h			;694b	ff 	. 
	rst 38h			;694c	ff 	. 
	rst 38h			;694d	ff 	. 
	rst 38h			;694e	ff 	. 
	rst 38h			;694f	ff 	. 
	rst 38h			;6950	ff 	. 
	rst 38h			;6951	ff 	. 
	rst 38h			;6952	ff 	. 
	rst 38h			;6953	ff 	. 
	rst 38h			;6954	ff 	. 
	rst 38h			;6955	ff 	. 
	rst 38h			;6956	ff 	. 
	rst 38h			;6957	ff 	. 
	rst 38h			;6958	ff 	. 
	rst 38h			;6959	ff 	. 
	rst 38h			;695a	ff 	. 
	rst 38h			;695b	ff 	. 
	rst 38h			;695c	ff 	. 
	rst 38h			;695d	ff 	. 
	rst 38h			;695e	ff 	. 
	rst 38h			;695f	ff 	. 
	rst 38h			;6960	ff 	. 
	rst 38h			;6961	ff 	. 
	rst 38h			;6962	ff 	. 
	rst 38h			;6963	ff 	. 
	rst 38h			;6964	ff 	. 
	rst 38h			;6965	ff 	. 
	rst 38h			;6966	ff 	. 
	rst 38h			;6967	ff 	. 
	rst 38h			;6968	ff 	. 
	rst 38h			;6969	ff 	. 
	rst 38h			;696a	ff 	. 
	rst 38h			;696b	ff 	. 
	rst 38h			;696c	ff 	. 
	rst 38h			;696d	ff 	. 
	rst 38h			;696e	ff 	. 
	rst 38h			;696f	ff 	. 
	rst 38h			;6970	ff 	. 
	rst 38h			;6971	ff 	. 
	rst 38h			;6972	ff 	. 
	rst 38h			;6973	ff 	. 
	rst 38h			;6974	ff 	. 
	rst 38h			;6975	ff 	. 
	rst 38h			;6976	ff 	. 
	rst 38h			;6977	ff 	. 
	rst 38h			;6978	ff 	. 
	rst 38h			;6979	ff 	. 
	rst 38h			;697a	ff 	. 
	rst 38h			;697b	ff 	. 
	rst 38h			;697c	ff 	. 
	rst 38h			;697d	ff 	. 
	rst 38h			;697e	ff 	. 
	rst 38h			;697f	ff 	. 
	rst 38h			;6980	ff 	. 
	rst 38h			;6981	ff 	. 
	rst 38h			;6982	ff 	. 
	rst 38h			;6983	ff 	. 
	rst 38h			;6984	ff 	. 
	rst 38h			;6985	ff 	. 
	rst 38h			;6986	ff 	. 
	rst 38h			;6987	ff 	. 
	rst 38h			;6988	ff 	. 
	rst 38h			;6989	ff 	. 
	rst 38h			;698a	ff 	. 
	rst 38h			;698b	ff 	. 
	rst 38h			;698c	ff 	. 
	rst 38h			;698d	ff 	. 
	rst 38h			;698e	ff 	. 
	rst 38h			;698f	ff 	. 
	rst 38h			;6990	ff 	. 
	rst 38h			;6991	ff 	. 
	rst 38h			;6992	ff 	. 
	rst 38h			;6993	ff 	. 
	rst 38h			;6994	ff 	. 
	rst 38h			;6995	ff 	. 
	rst 38h			;6996	ff 	. 
	rst 38h			;6997	ff 	. 
	rst 38h			;6998	ff 	. 
	rst 38h			;6999	ff 	. 
	rst 38h			;699a	ff 	. 
	rst 38h			;699b	ff 	. 
	rst 38h			;699c	ff 	. 
	rst 38h			;699d	ff 	. 
	rst 38h			;699e	ff 	. 
	rst 38h			;699f	ff 	. 
	rst 38h			;69a0	ff 	. 
	rst 38h			;69a1	ff 	. 
	rst 38h			;69a2	ff 	. 
	rst 38h			;69a3	ff 	. 
	rst 38h			;69a4	ff 	. 
	rst 38h			;69a5	ff 	. 
	rst 38h			;69a6	ff 	. 
	rst 38h			;69a7	ff 	. 
	rst 38h			;69a8	ff 	. 
	rst 38h			;69a9	ff 	. 
	rst 38h			;69aa	ff 	. 
	rst 38h			;69ab	ff 	. 
	rst 38h			;69ac	ff 	. 
	rst 38h			;69ad	ff 	. 
	rst 38h			;69ae	ff 	. 
	rst 38h			;69af	ff 	. 
	rst 38h			;69b0	ff 	. 
	rst 38h			;69b1	ff 	. 
	rst 38h			;69b2	ff 	. 
	rst 38h			;69b3	ff 	. 
	rst 38h			;69b4	ff 	. 
	rst 38h			;69b5	ff 	. 
	rst 38h			;69b6	ff 	. 
	rst 38h			;69b7	ff 	. 
	rst 38h			;69b8	ff 	. 
	rst 38h			;69b9	ff 	. 
	rst 38h			;69ba	ff 	. 
	rst 38h			;69bb	ff 	. 
	rst 38h			;69bc	ff 	. 
	rst 38h			;69bd	ff 	. 
	rst 38h			;69be	ff 	. 
	rst 38h			;69bf	ff 	. 
	rst 38h			;69c0	ff 	. 
	rst 38h			;69c1	ff 	. 
	rst 38h			;69c2	ff 	. 
	rst 38h			;69c3	ff 	. 
	rst 38h			;69c4	ff 	. 
	rst 38h			;69c5	ff 	. 
	rst 38h			;69c6	ff 	. 
	rst 38h			;69c7	ff 	. 
	rst 38h			;69c8	ff 	. 
	rst 38h			;69c9	ff 	. 
	rst 38h			;69ca	ff 	. 
	rst 38h			;69cb	ff 	. 
	rst 38h			;69cc	ff 	. 
	rst 38h			;69cd	ff 	. 
	rst 38h			;69ce	ff 	. 
	rst 38h			;69cf	ff 	. 
	rst 38h			;69d0	ff 	. 
	rst 38h			;69d1	ff 	. 
	rst 38h			;69d2	ff 	. 
	rst 38h			;69d3	ff 	. 
	rst 38h			;69d4	ff 	. 
	rst 38h			;69d5	ff 	. 
	rst 38h			;69d6	ff 	. 
	rst 38h			;69d7	ff 	. 
	rst 38h			;69d8	ff 	. 
	rst 38h			;69d9	ff 	. 
	rst 38h			;69da	ff 	. 
	rst 38h			;69db	ff 	. 
	rst 38h			;69dc	ff 	. 
	rst 38h			;69dd	ff 	. 
	rst 38h			;69de	ff 	. 
	rst 38h			;69df	ff 	. 
	rst 38h			;69e0	ff 	. 
	rst 38h			;69e1	ff 	. 
	rst 38h			;69e2	ff 	. 
	rst 38h			;69e3	ff 	. 
	rst 38h			;69e4	ff 	. 
	rst 38h			;69e5	ff 	. 
	rst 38h			;69e6	ff 	. 
	rst 38h			;69e7	ff 	. 
	rst 38h			;69e8	ff 	. 
	rst 38h			;69e9	ff 	. 
	rst 38h			;69ea	ff 	. 
	rst 38h			;69eb	ff 	. 
	rst 38h			;69ec	ff 	. 
	rst 38h			;69ed	ff 	. 
	rst 38h			;69ee	ff 	. 
	rst 38h			;69ef	ff 	. 
	rst 38h			;69f0	ff 	. 
	rst 38h			;69f1	ff 	. 
	rst 38h			;69f2	ff 	. 
	rst 38h			;69f3	ff 	. 
	rst 38h			;69f4	ff 	. 
	rst 38h			;69f5	ff 	. 
	rst 38h			;69f6	ff 	. 
	rst 38h			;69f7	ff 	. 
	rst 38h			;69f8	ff 	. 
	rst 38h			;69f9	ff 	. 
	rst 38h			;69fa	ff 	. 
	rst 38h			;69fb	ff 	. 
	rst 38h			;69fc	ff 	. 
	rst 38h			;69fd	ff 	. 
	rst 38h			;69fe	ff 	. 
	rst 38h			;69ff	ff 	. 
	rst 38h			;6a00	ff 	. 
	rst 38h			;6a01	ff 	. 
	rst 38h			;6a02	ff 	. 
	rst 38h			;6a03	ff 	. 
	rst 38h			;6a04	ff 	. 
	rst 38h			;6a05	ff 	. 
	rst 38h			;6a06	ff 	. 
	rst 38h			;6a07	ff 	. 
	rst 38h			;6a08	ff 	. 
	rst 38h			;6a09	ff 	. 
	rst 38h			;6a0a	ff 	. 
	rst 38h			;6a0b	ff 	. 
	rst 38h			;6a0c	ff 	. 
	rst 38h			;6a0d	ff 	. 
	rst 38h			;6a0e	ff 	. 
	rst 38h			;6a0f	ff 	. 
	rst 38h			;6a10	ff 	. 
	rst 38h			;6a11	ff 	. 
	rst 38h			;6a12	ff 	. 
	rst 38h			;6a13	ff 	. 
	rst 38h			;6a14	ff 	. 
	rst 38h			;6a15	ff 	. 
	rst 38h			;6a16	ff 	. 
	rst 38h			;6a17	ff 	. 
	rst 38h			;6a18	ff 	. 
	rst 38h			;6a19	ff 	. 
	rst 38h			;6a1a	ff 	. 
	rst 38h			;6a1b	ff 	. 
	rst 38h			;6a1c	ff 	. 
	rst 38h			;6a1d	ff 	. 
	rst 38h			;6a1e	ff 	. 
	rst 38h			;6a1f	ff 	. 
	rst 38h			;6a20	ff 	. 
	rst 38h			;6a21	ff 	. 
	rst 38h			;6a22	ff 	. 
	rst 38h			;6a23	ff 	. 
	rst 38h			;6a24	ff 	. 
	rst 38h			;6a25	ff 	. 
	rst 38h			;6a26	ff 	. 
	rst 38h			;6a27	ff 	. 
	rst 38h			;6a28	ff 	. 
	rst 38h			;6a29	ff 	. 
	rst 38h			;6a2a	ff 	. 
	rst 38h			;6a2b	ff 	. 
	rst 38h			;6a2c	ff 	. 
	rst 38h			;6a2d	ff 	. 
	rst 38h			;6a2e	ff 	. 
	rst 38h			;6a2f	ff 	. 
	rst 38h			;6a30	ff 	. 
	rst 38h			;6a31	ff 	. 
	rst 38h			;6a32	ff 	. 
	rst 38h			;6a33	ff 	. 
	rst 38h			;6a34	ff 	. 
	rst 38h			;6a35	ff 	. 
	rst 38h			;6a36	ff 	. 
	rst 38h			;6a37	ff 	. 
	rst 38h			;6a38	ff 	. 
	rst 38h			;6a39	ff 	. 
	rst 38h			;6a3a	ff 	. 
	rst 38h			;6a3b	ff 	. 
	rst 38h			;6a3c	ff 	. 
	rst 38h			;6a3d	ff 	. 
	rst 38h			;6a3e	ff 	. 
	rst 38h			;6a3f	ff 	. 
	rst 38h			;6a40	ff 	. 
	rst 38h			;6a41	ff 	. 
	rst 38h			;6a42	ff 	. 
	rst 38h			;6a43	ff 	. 
	rst 38h			;6a44	ff 	. 
	rst 38h			;6a45	ff 	. 
	rst 38h			;6a46	ff 	. 
	rst 38h			;6a47	ff 	. 
	rst 38h			;6a48	ff 	. 
	rst 38h			;6a49	ff 	. 
	rst 38h			;6a4a	ff 	. 
	rst 38h			;6a4b	ff 	. 
	rst 38h			;6a4c	ff 	. 
	rst 38h			;6a4d	ff 	. 
	rst 38h			;6a4e	ff 	. 
	rst 38h			;6a4f	ff 	. 
	rst 38h			;6a50	ff 	. 
	rst 38h			;6a51	ff 	. 
	rst 38h			;6a52	ff 	. 
	rst 38h			;6a53	ff 	. 
	rst 38h			;6a54	ff 	. 
	rst 38h			;6a55	ff 	. 
	rst 38h			;6a56	ff 	. 
	rst 38h			;6a57	ff 	. 
	rst 38h			;6a58	ff 	. 
	rst 38h			;6a59	ff 	. 
	rst 38h			;6a5a	ff 	. 
	rst 38h			;6a5b	ff 	. 
	rst 38h			;6a5c	ff 	. 
	rst 38h			;6a5d	ff 	. 
	rst 38h			;6a5e	ff 	. 
	rst 38h			;6a5f	ff 	. 
	rst 38h			;6a60	ff 	. 
	rst 38h			;6a61	ff 	. 
	rst 38h			;6a62	ff 	. 
	rst 38h			;6a63	ff 	. 
	rst 38h			;6a64	ff 	. 
	rst 38h			;6a65	ff 	. 
	rst 38h			;6a66	ff 	. 
	rst 38h			;6a67	ff 	. 
	rst 38h			;6a68	ff 	. 
	rst 38h			;6a69	ff 	. 
	rst 38h			;6a6a	ff 	. 
	rst 38h			;6a6b	ff 	. 
	rst 38h			;6a6c	ff 	. 
	rst 38h			;6a6d	ff 	. 
	rst 38h			;6a6e	ff 	. 
	rst 38h			;6a6f	ff 	. 
	rst 38h			;6a70	ff 	. 
	rst 38h			;6a71	ff 	. 
	rst 38h			;6a72	ff 	. 
	rst 38h			;6a73	ff 	. 
	rst 38h			;6a74	ff 	. 
	rst 38h			;6a75	ff 	. 
	rst 38h			;6a76	ff 	. 
	rst 38h			;6a77	ff 	. 
	rst 38h			;6a78	ff 	. 
	rst 38h			;6a79	ff 	. 
	rst 38h			;6a7a	ff 	. 
	rst 38h			;6a7b	ff 	. 
	rst 38h			;6a7c	ff 	. 
	rst 38h			;6a7d	ff 	. 
	rst 38h			;6a7e	ff 	. 
	rst 38h			;6a7f	ff 	. 
	rst 38h			;6a80	ff 	. 
	rst 38h			;6a81	ff 	. 
	rst 38h			;6a82	ff 	. 
	rst 38h			;6a83	ff 	. 
	rst 38h			;6a84	ff 	. 
	rst 38h			;6a85	ff 	. 
	rst 38h			;6a86	ff 	. 
	rst 38h			;6a87	ff 	. 
	rst 38h			;6a88	ff 	. 
	rst 38h			;6a89	ff 	. 
	rst 38h			;6a8a	ff 	. 
	rst 38h			;6a8b	ff 	. 
	rst 38h			;6a8c	ff 	. 
	rst 38h			;6a8d	ff 	. 
	rst 38h			;6a8e	ff 	. 
	rst 38h			;6a8f	ff 	. 
	rst 38h			;6a90	ff 	. 
	rst 38h			;6a91	ff 	. 
	rst 38h			;6a92	ff 	. 
	rst 38h			;6a93	ff 	. 
	rst 38h			;6a94	ff 	. 
	rst 38h			;6a95	ff 	. 
	rst 38h			;6a96	ff 	. 
	rst 38h			;6a97	ff 	. 
	rst 38h			;6a98	ff 	. 
	rst 38h			;6a99	ff 	. 
	rst 38h			;6a9a	ff 	. 
	rst 38h			;6a9b	ff 	. 
	rst 38h			;6a9c	ff 	. 
	rst 38h			;6a9d	ff 	. 
	rst 38h			;6a9e	ff 	. 
	rst 38h			;6a9f	ff 	. 
	rst 38h			;6aa0	ff 	. 
	rst 38h			;6aa1	ff 	. 
	rst 38h			;6aa2	ff 	. 
	rst 38h			;6aa3	ff 	. 
	rst 38h			;6aa4	ff 	. 
	rst 38h			;6aa5	ff 	. 
	rst 38h			;6aa6	ff 	. 
	rst 38h			;6aa7	ff 	. 
	rst 38h			;6aa8	ff 	. 
	rst 38h			;6aa9	ff 	. 
	rst 38h			;6aaa	ff 	. 
	rst 38h			;6aab	ff 	. 
	rst 38h			;6aac	ff 	. 
	rst 38h			;6aad	ff 	. 
	rst 38h			;6aae	ff 	. 
	rst 38h			;6aaf	ff 	. 
	rst 38h			;6ab0	ff 	. 
	rst 38h			;6ab1	ff 	. 
	rst 38h			;6ab2	ff 	. 
	rst 38h			;6ab3	ff 	. 
	rst 38h			;6ab4	ff 	. 
	rst 38h			;6ab5	ff 	. 
	rst 38h			;6ab6	ff 	. 
	rst 38h			;6ab7	ff 	. 
	rst 38h			;6ab8	ff 	. 
	rst 38h			;6ab9	ff 	. 
	rst 38h			;6aba	ff 	. 
	rst 38h			;6abb	ff 	. 
	rst 38h			;6abc	ff 	. 
	rst 38h			;6abd	ff 	. 
	rst 38h			;6abe	ff 	. 
	rst 38h			;6abf	ff 	. 
	rst 38h			;6ac0	ff 	. 
	rst 38h			;6ac1	ff 	. 
	rst 38h			;6ac2	ff 	. 
	rst 38h			;6ac3	ff 	. 
	rst 38h			;6ac4	ff 	. 
	rst 38h			;6ac5	ff 	. 
	rst 38h			;6ac6	ff 	. 
	rst 38h			;6ac7	ff 	. 
	rst 38h			;6ac8	ff 	. 
	rst 38h			;6ac9	ff 	. 
	rst 38h			;6aca	ff 	. 
	rst 38h			;6acb	ff 	. 
	rst 38h			;6acc	ff 	. 
	rst 38h			;6acd	ff 	. 
	rst 38h			;6ace	ff 	. 
	rst 38h			;6acf	ff 	. 
	rst 38h			;6ad0	ff 	. 
	rst 38h			;6ad1	ff 	. 
	rst 38h			;6ad2	ff 	. 
	rst 38h			;6ad3	ff 	. 
	rst 38h			;6ad4	ff 	. 
	rst 38h			;6ad5	ff 	. 
	rst 38h			;6ad6	ff 	. 
	rst 38h			;6ad7	ff 	. 
	rst 38h			;6ad8	ff 	. 
	rst 38h			;6ad9	ff 	. 
	rst 38h			;6ada	ff 	. 
	rst 38h			;6adb	ff 	. 
	rst 38h			;6adc	ff 	. 
	rst 38h			;6add	ff 	. 
	rst 38h			;6ade	ff 	. 
	rst 38h			;6adf	ff 	. 
	rst 38h			;6ae0	ff 	. 
	rst 38h			;6ae1	ff 	. 
	rst 38h			;6ae2	ff 	. 
	rst 38h			;6ae3	ff 	. 
	rst 38h			;6ae4	ff 	. 
	rst 38h			;6ae5	ff 	. 
	rst 38h			;6ae6	ff 	. 
	rst 38h			;6ae7	ff 	. 
	rst 38h			;6ae8	ff 	. 
	rst 38h			;6ae9	ff 	. 
	rst 38h			;6aea	ff 	. 
	rst 38h			;6aeb	ff 	. 
	rst 38h			;6aec	ff 	. 
	rst 38h			;6aed	ff 	. 
	rst 38h			;6aee	ff 	. 
	rst 38h			;6aef	ff 	. 
	rst 38h			;6af0	ff 	. 
	rst 38h			;6af1	ff 	. 
	rst 38h			;6af2	ff 	. 
	rst 38h			;6af3	ff 	. 
	rst 38h			;6af4	ff 	. 
	rst 38h			;6af5	ff 	. 
	rst 38h			;6af6	ff 	. 
	rst 38h			;6af7	ff 	. 
	rst 38h			;6af8	ff 	. 
	rst 38h			;6af9	ff 	. 
	rst 38h			;6afa	ff 	. 
	rst 38h			;6afb	ff 	. 
	rst 38h			;6afc	ff 	. 
	rst 38h			;6afd	ff 	. 
	rst 38h			;6afe	ff 	. 
	rst 38h			;6aff	ff 	. 
	rst 38h			;6b00	ff 	. 
	rst 38h			;6b01	ff 	. 
	rst 38h			;6b02	ff 	. 
	rst 38h			;6b03	ff 	. 
	rst 38h			;6b04	ff 	. 
	rst 38h			;6b05	ff 	. 
	rst 38h			;6b06	ff 	. 
	rst 38h			;6b07	ff 	. 
	rst 38h			;6b08	ff 	. 
	rst 38h			;6b09	ff 	. 
	rst 38h			;6b0a	ff 	. 
	rst 38h			;6b0b	ff 	. 
	rst 38h			;6b0c	ff 	. 
	rst 38h			;6b0d	ff 	. 
	rst 38h			;6b0e	ff 	. 
	rst 38h			;6b0f	ff 	. 
	rst 38h			;6b10	ff 	. 
	rst 38h			;6b11	ff 	. 
	rst 38h			;6b12	ff 	. 
	rst 38h			;6b13	ff 	. 
	rst 38h			;6b14	ff 	. 
	rst 38h			;6b15	ff 	. 
	rst 38h			;6b16	ff 	. 
	rst 38h			;6b17	ff 	. 
	rst 38h			;6b18	ff 	. 
	rst 38h			;6b19	ff 	. 
	rst 38h			;6b1a	ff 	. 
	rst 38h			;6b1b	ff 	. 
	rst 38h			;6b1c	ff 	. 
	rst 38h			;6b1d	ff 	. 
	rst 38h			;6b1e	ff 	. 
	rst 38h			;6b1f	ff 	. 
	rst 38h			;6b20	ff 	. 
	rst 38h			;6b21	ff 	. 
	rst 38h			;6b22	ff 	. 
	rst 38h			;6b23	ff 	. 
	rst 38h			;6b24	ff 	. 
	rst 38h			;6b25	ff 	. 
	rst 38h			;6b26	ff 	. 
	rst 38h			;6b27	ff 	. 
	rst 38h			;6b28	ff 	. 
	rst 38h			;6b29	ff 	. 
	rst 38h			;6b2a	ff 	. 
	rst 38h			;6b2b	ff 	. 
	rst 38h			;6b2c	ff 	. 
	rst 38h			;6b2d	ff 	. 
	rst 38h			;6b2e	ff 	. 
	rst 38h			;6b2f	ff 	. 
	rst 38h			;6b30	ff 	. 
	rst 38h			;6b31	ff 	. 
	rst 38h			;6b32	ff 	. 
	rst 38h			;6b33	ff 	. 
	rst 38h			;6b34	ff 	. 
	rst 38h			;6b35	ff 	. 
	rst 38h			;6b36	ff 	. 
	rst 38h			;6b37	ff 	. 
	rst 38h			;6b38	ff 	. 
	rst 38h			;6b39	ff 	. 
	rst 38h			;6b3a	ff 	. 
	rst 38h			;6b3b	ff 	. 
	rst 38h			;6b3c	ff 	. 
	rst 38h			;6b3d	ff 	. 
	rst 38h			;6b3e	ff 	. 
	rst 38h			;6b3f	ff 	. 
	rst 38h			;6b40	ff 	. 
	rst 38h			;6b41	ff 	. 
	rst 38h			;6b42	ff 	. 
	rst 38h			;6b43	ff 	. 
	rst 38h			;6b44	ff 	. 
	rst 38h			;6b45	ff 	. 
	rst 38h			;6b46	ff 	. 
	rst 38h			;6b47	ff 	. 
	rst 38h			;6b48	ff 	. 
	rst 38h			;6b49	ff 	. 
	rst 38h			;6b4a	ff 	. 
	rst 38h			;6b4b	ff 	. 
	rst 38h			;6b4c	ff 	. 
	rst 38h			;6b4d	ff 	. 
	rst 38h			;6b4e	ff 	. 
	rst 38h			;6b4f	ff 	. 
	rst 38h			;6b50	ff 	. 
	rst 38h			;6b51	ff 	. 
	rst 38h			;6b52	ff 	. 
	rst 38h			;6b53	ff 	. 
	rst 38h			;6b54	ff 	. 
	rst 38h			;6b55	ff 	. 
	rst 38h			;6b56	ff 	. 
	rst 38h			;6b57	ff 	. 
	rst 38h			;6b58	ff 	. 
	rst 38h			;6b59	ff 	. 
	rst 38h			;6b5a	ff 	. 
	rst 38h			;6b5b	ff 	. 
	rst 38h			;6b5c	ff 	. 
	rst 38h			;6b5d	ff 	. 
	rst 38h			;6b5e	ff 	. 
	rst 38h			;6b5f	ff 	. 
	rst 38h			;6b60	ff 	. 
	rst 38h			;6b61	ff 	. 
	rst 38h			;6b62	ff 	. 
	rst 38h			;6b63	ff 	. 
	rst 38h			;6b64	ff 	. 
	rst 38h			;6b65	ff 	. 
	rst 38h			;6b66	ff 	. 
	rst 38h			;6b67	ff 	. 
	rst 38h			;6b68	ff 	. 
	rst 38h			;6b69	ff 	. 
	rst 38h			;6b6a	ff 	. 
	rst 38h			;6b6b	ff 	. 
	rst 38h			;6b6c	ff 	. 
	rst 38h			;6b6d	ff 	. 
	rst 38h			;6b6e	ff 	. 
	rst 38h			;6b6f	ff 	. 
	rst 38h			;6b70	ff 	. 
	rst 38h			;6b71	ff 	. 
	rst 38h			;6b72	ff 	. 
	rst 38h			;6b73	ff 	. 
	rst 38h			;6b74	ff 	. 
	rst 38h			;6b75	ff 	. 
	rst 38h			;6b76	ff 	. 
	rst 38h			;6b77	ff 	. 
	rst 38h			;6b78	ff 	. 
	rst 38h			;6b79	ff 	. 
	rst 38h			;6b7a	ff 	. 
	rst 38h			;6b7b	ff 	. 
	rst 38h			;6b7c	ff 	. 
	rst 38h			;6b7d	ff 	. 
	rst 38h			;6b7e	ff 	. 
	rst 38h			;6b7f	ff 	. 
	rst 38h			;6b80	ff 	. 
	rst 38h			;6b81	ff 	. 
	rst 38h			;6b82	ff 	. 
	rst 38h			;6b83	ff 	. 
	rst 38h			;6b84	ff 	. 
	rst 38h			;6b85	ff 	. 
	rst 38h			;6b86	ff 	. 
	rst 38h			;6b87	ff 	. 
	rst 38h			;6b88	ff 	. 
	rst 38h			;6b89	ff 	. 
	rst 38h			;6b8a	ff 	. 
	rst 38h			;6b8b	ff 	. 
	rst 38h			;6b8c	ff 	. 
	rst 38h			;6b8d	ff 	. 
	rst 38h			;6b8e	ff 	. 
	rst 38h			;6b8f	ff 	. 
	rst 38h			;6b90	ff 	. 
	rst 38h			;6b91	ff 	. 
	rst 38h			;6b92	ff 	. 
	rst 38h			;6b93	ff 	. 
	rst 38h			;6b94	ff 	. 
	rst 38h			;6b95	ff 	. 
	rst 38h			;6b96	ff 	. 
	rst 38h			;6b97	ff 	. 
	rst 38h			;6b98	ff 	. 
	rst 38h			;6b99	ff 	. 
	rst 38h			;6b9a	ff 	. 
	rst 38h			;6b9b	ff 	. 
	rst 38h			;6b9c	ff 	. 
	rst 38h			;6b9d	ff 	. 
	rst 38h			;6b9e	ff 	. 
	rst 38h			;6b9f	ff 	. 
	rst 38h			;6ba0	ff 	. 
	rst 38h			;6ba1	ff 	. 
	rst 38h			;6ba2	ff 	. 
	rst 38h			;6ba3	ff 	. 
	rst 38h			;6ba4	ff 	. 
	rst 38h			;6ba5	ff 	. 
	rst 38h			;6ba6	ff 	. 
	rst 38h			;6ba7	ff 	. 
	rst 38h			;6ba8	ff 	. 
	rst 38h			;6ba9	ff 	. 
	rst 38h			;6baa	ff 	. 
	rst 38h			;6bab	ff 	. 
	rst 38h			;6bac	ff 	. 
	rst 38h			;6bad	ff 	. 
	rst 38h			;6bae	ff 	. 
	rst 38h			;6baf	ff 	. 
	rst 38h			;6bb0	ff 	. 
	rst 38h			;6bb1	ff 	. 
	rst 38h			;6bb2	ff 	. 
	rst 38h			;6bb3	ff 	. 
	rst 38h			;6bb4	ff 	. 
	rst 38h			;6bb5	ff 	. 
	rst 38h			;6bb6	ff 	. 
	rst 38h			;6bb7	ff 	. 
	rst 38h			;6bb8	ff 	. 
	rst 38h			;6bb9	ff 	. 
	rst 38h			;6bba	ff 	. 
	rst 38h			;6bbb	ff 	. 
	rst 38h			;6bbc	ff 	. 
	rst 38h			;6bbd	ff 	. 
	rst 38h			;6bbe	ff 	. 
	rst 38h			;6bbf	ff 	. 
	rst 38h			;6bc0	ff 	. 
	rst 38h			;6bc1	ff 	. 
	rst 38h			;6bc2	ff 	. 
	rst 38h			;6bc3	ff 	. 
	rst 38h			;6bc4	ff 	. 
	rst 38h			;6bc5	ff 	. 
	rst 38h			;6bc6	ff 	. 
	rst 38h			;6bc7	ff 	. 
	rst 38h			;6bc8	ff 	. 
	rst 38h			;6bc9	ff 	. 
	rst 38h			;6bca	ff 	. 
	rst 38h			;6bcb	ff 	. 
	rst 38h			;6bcc	ff 	. 
	rst 38h			;6bcd	ff 	. 
	rst 38h			;6bce	ff 	. 
	rst 38h			;6bcf	ff 	. 
	rst 38h			;6bd0	ff 	. 
	rst 38h			;6bd1	ff 	. 
	rst 38h			;6bd2	ff 	. 
	rst 38h			;6bd3	ff 	. 
	rst 38h			;6bd4	ff 	. 
	rst 38h			;6bd5	ff 	. 
	rst 38h			;6bd6	ff 	. 
	rst 38h			;6bd7	ff 	. 
	rst 38h			;6bd8	ff 	. 
	rst 38h			;6bd9	ff 	. 
	rst 38h			;6bda	ff 	. 
	rst 38h			;6bdb	ff 	. 
	rst 38h			;6bdc	ff 	. 
	rst 38h			;6bdd	ff 	. 
	rst 38h			;6bde	ff 	. 
	rst 38h			;6bdf	ff 	. 
	rst 38h			;6be0	ff 	. 
	rst 38h			;6be1	ff 	. 
	rst 38h			;6be2	ff 	. 
	rst 38h			;6be3	ff 	. 
	rst 38h			;6be4	ff 	. 
	rst 38h			;6be5	ff 	. 
	rst 38h			;6be6	ff 	. 
	rst 38h			;6be7	ff 	. 
	rst 38h			;6be8	ff 	. 
	rst 38h			;6be9	ff 	. 
	rst 38h			;6bea	ff 	. 
	rst 38h			;6beb	ff 	. 
	rst 38h			;6bec	ff 	. 
	rst 38h			;6bed	ff 	. 
	rst 38h			;6bee	ff 	. 
	rst 38h			;6bef	ff 	. 
	rst 38h			;6bf0	ff 	. 
	rst 38h			;6bf1	ff 	. 
	rst 38h			;6bf2	ff 	. 
	rst 38h			;6bf3	ff 	. 
	rst 38h			;6bf4	ff 	. 
	rst 38h			;6bf5	ff 	. 
	rst 38h			;6bf6	ff 	. 
	rst 38h			;6bf7	ff 	. 
	rst 38h			;6bf8	ff 	. 
	rst 38h			;6bf9	ff 	. 
	rst 38h			;6bfa	ff 	. 
	rst 38h			;6bfb	ff 	. 
	rst 38h			;6bfc	ff 	. 
	rst 38h			;6bfd	ff 	. 
	rst 38h			;6bfe	ff 	. 
	rst 38h			;6bff	ff 	. 
	rst 38h			;6c00	ff 	. 
	rst 38h			;6c01	ff 	. 
	rst 38h			;6c02	ff 	. 
	rst 38h			;6c03	ff 	. 
	rst 38h			;6c04	ff 	. 
	rst 38h			;6c05	ff 	. 
	rst 38h			;6c06	ff 	. 
	rst 38h			;6c07	ff 	. 
	rst 38h			;6c08	ff 	. 
	rst 38h			;6c09	ff 	. 
	rst 38h			;6c0a	ff 	. 
	rst 38h			;6c0b	ff 	. 
	rst 38h			;6c0c	ff 	. 
	rst 38h			;6c0d	ff 	. 
	rst 38h			;6c0e	ff 	. 
	rst 38h			;6c0f	ff 	. 
	rst 38h			;6c10	ff 	. 
	rst 38h			;6c11	ff 	. 
	rst 38h			;6c12	ff 	. 
	rst 38h			;6c13	ff 	. 
	rst 38h			;6c14	ff 	. 
	rst 38h			;6c15	ff 	. 
	rst 38h			;6c16	ff 	. 
	rst 38h			;6c17	ff 	. 
	rst 38h			;6c18	ff 	. 
	rst 38h			;6c19	ff 	. 
	rst 38h			;6c1a	ff 	. 
	rst 38h			;6c1b	ff 	. 
	rst 38h			;6c1c	ff 	. 
	rst 38h			;6c1d	ff 	. 
	rst 38h			;6c1e	ff 	. 
	rst 38h			;6c1f	ff 	. 
	rst 38h			;6c20	ff 	. 
	rst 38h			;6c21	ff 	. 
	rst 38h			;6c22	ff 	. 
	rst 38h			;6c23	ff 	. 
	rst 38h			;6c24	ff 	. 
	rst 38h			;6c25	ff 	. 
	rst 38h			;6c26	ff 	. 
	rst 38h			;6c27	ff 	. 
	rst 38h			;6c28	ff 	. 
	rst 38h			;6c29	ff 	. 
	rst 38h			;6c2a	ff 	. 
	rst 38h			;6c2b	ff 	. 
	rst 38h			;6c2c	ff 	. 
	rst 38h			;6c2d	ff 	. 
	rst 38h			;6c2e	ff 	. 
	rst 38h			;6c2f	ff 	. 
	rst 38h			;6c30	ff 	. 
	rst 38h			;6c31	ff 	. 
	rst 38h			;6c32	ff 	. 
	rst 38h			;6c33	ff 	. 
	rst 38h			;6c34	ff 	. 
	rst 38h			;6c35	ff 	. 
	rst 38h			;6c36	ff 	. 
	rst 38h			;6c37	ff 	. 
	rst 38h			;6c38	ff 	. 
	rst 38h			;6c39	ff 	. 
	rst 38h			;6c3a	ff 	. 
	rst 38h			;6c3b	ff 	. 
	rst 38h			;6c3c	ff 	. 
	rst 38h			;6c3d	ff 	. 
	rst 38h			;6c3e	ff 	. 
	rst 38h			;6c3f	ff 	. 
	rst 38h			;6c40	ff 	. 
	rst 38h			;6c41	ff 	. 
	rst 38h			;6c42	ff 	. 
	rst 38h			;6c43	ff 	. 
	rst 38h			;6c44	ff 	. 
	rst 38h			;6c45	ff 	. 
	rst 38h			;6c46	ff 	. 
	rst 38h			;6c47	ff 	. 
	rst 38h			;6c48	ff 	. 
	rst 38h			;6c49	ff 	. 
	rst 38h			;6c4a	ff 	. 
	rst 38h			;6c4b	ff 	. 
	rst 38h			;6c4c	ff 	. 
	rst 38h			;6c4d	ff 	. 
	rst 38h			;6c4e	ff 	. 
	rst 38h			;6c4f	ff 	. 
	rst 38h			;6c50	ff 	. 
	rst 38h			;6c51	ff 	. 
	rst 38h			;6c52	ff 	. 
	rst 38h			;6c53	ff 	. 
	rst 38h			;6c54	ff 	. 
	rst 38h			;6c55	ff 	. 
	rst 38h			;6c56	ff 	. 
	rst 38h			;6c57	ff 	. 
	rst 38h			;6c58	ff 	. 
	rst 38h			;6c59	ff 	. 
	rst 38h			;6c5a	ff 	. 
	rst 38h			;6c5b	ff 	. 
	rst 38h			;6c5c	ff 	. 
	rst 38h			;6c5d	ff 	. 
	rst 38h			;6c5e	ff 	. 
	rst 38h			;6c5f	ff 	. 
	rst 38h			;6c60	ff 	. 
	rst 38h			;6c61	ff 	. 
	rst 38h			;6c62	ff 	. 
	rst 38h			;6c63	ff 	. 
	rst 38h			;6c64	ff 	. 
	rst 38h			;6c65	ff 	. 
	rst 38h			;6c66	ff 	. 
	rst 38h			;6c67	ff 	. 
	rst 38h			;6c68	ff 	. 
	rst 38h			;6c69	ff 	. 
	rst 38h			;6c6a	ff 	. 
	rst 38h			;6c6b	ff 	. 
	rst 38h			;6c6c	ff 	. 
	rst 38h			;6c6d	ff 	. 
	rst 38h			;6c6e	ff 	. 
	rst 38h			;6c6f	ff 	. 
	rst 38h			;6c70	ff 	. 
	rst 38h			;6c71	ff 	. 
	rst 38h			;6c72	ff 	. 
	rst 38h			;6c73	ff 	. 
	rst 38h			;6c74	ff 	. 
	rst 38h			;6c75	ff 	. 
	rst 38h			;6c76	ff 	. 
	rst 38h			;6c77	ff 	. 
	rst 38h			;6c78	ff 	. 
	rst 38h			;6c79	ff 	. 
	rst 38h			;6c7a	ff 	. 
	rst 38h			;6c7b	ff 	. 
	rst 38h			;6c7c	ff 	. 
	rst 38h			;6c7d	ff 	. 
	rst 38h			;6c7e	ff 	. 
	rst 38h			;6c7f	ff 	. 
	rst 38h			;6c80	ff 	. 
	rst 38h			;6c81	ff 	. 
	rst 38h			;6c82	ff 	. 
	rst 38h			;6c83	ff 	. 
	rst 38h			;6c84	ff 	. 
	rst 38h			;6c85	ff 	. 
	rst 38h			;6c86	ff 	. 
	rst 38h			;6c87	ff 	. 
	rst 38h			;6c88	ff 	. 
	rst 38h			;6c89	ff 	. 
	rst 38h			;6c8a	ff 	. 
	rst 38h			;6c8b	ff 	. 
	rst 38h			;6c8c	ff 	. 
	rst 38h			;6c8d	ff 	. 
	rst 38h			;6c8e	ff 	. 
	rst 38h			;6c8f	ff 	. 
	rst 38h			;6c90	ff 	. 
	rst 38h			;6c91	ff 	. 
	rst 38h			;6c92	ff 	. 
	rst 38h			;6c93	ff 	. 
	rst 38h			;6c94	ff 	. 
	rst 38h			;6c95	ff 	. 
	rst 38h			;6c96	ff 	. 
	rst 38h			;6c97	ff 	. 
	rst 38h			;6c98	ff 	. 
	rst 38h			;6c99	ff 	. 
	rst 38h			;6c9a	ff 	. 
	rst 38h			;6c9b	ff 	. 
	rst 38h			;6c9c	ff 	. 
	rst 38h			;6c9d	ff 	. 
	rst 38h			;6c9e	ff 	. 
	rst 38h			;6c9f	ff 	. 
	rst 38h			;6ca0	ff 	. 
	rst 38h			;6ca1	ff 	. 
	rst 38h			;6ca2	ff 	. 
	rst 38h			;6ca3	ff 	. 
	rst 38h			;6ca4	ff 	. 
	rst 38h			;6ca5	ff 	. 
	rst 38h			;6ca6	ff 	. 
	rst 38h			;6ca7	ff 	. 
	rst 38h			;6ca8	ff 	. 
	rst 38h			;6ca9	ff 	. 
	rst 38h			;6caa	ff 	. 
	rst 38h			;6cab	ff 	. 
	rst 38h			;6cac	ff 	. 
	rst 38h			;6cad	ff 	. 
	rst 38h			;6cae	ff 	. 
	rst 38h			;6caf	ff 	. 
	rst 38h			;6cb0	ff 	. 
	rst 38h			;6cb1	ff 	. 
	rst 38h			;6cb2	ff 	. 
	rst 38h			;6cb3	ff 	. 
	rst 38h			;6cb4	ff 	. 
	rst 38h			;6cb5	ff 	. 
	rst 38h			;6cb6	ff 	. 
	rst 38h			;6cb7	ff 	. 
	rst 38h			;6cb8	ff 	. 
	rst 38h			;6cb9	ff 	. 
	rst 38h			;6cba	ff 	. 
	rst 38h			;6cbb	ff 	. 
	rst 38h			;6cbc	ff 	. 
	rst 38h			;6cbd	ff 	. 
	rst 38h			;6cbe	ff 	. 
	rst 38h			;6cbf	ff 	. 
	rst 38h			;6cc0	ff 	. 
	rst 38h			;6cc1	ff 	. 
	rst 38h			;6cc2	ff 	. 
	rst 38h			;6cc3	ff 	. 
	rst 38h			;6cc4	ff 	. 
	rst 38h			;6cc5	ff 	. 
	rst 38h			;6cc6	ff 	. 
	rst 38h			;6cc7	ff 	. 
	rst 38h			;6cc8	ff 	. 
	rst 38h			;6cc9	ff 	. 
	rst 38h			;6cca	ff 	. 
	rst 38h			;6ccb	ff 	. 
	rst 38h			;6ccc	ff 	. 
	rst 38h			;6ccd	ff 	. 
	rst 38h			;6cce	ff 	. 
	rst 38h			;6ccf	ff 	. 
	rst 38h			;6cd0	ff 	. 
	rst 38h			;6cd1	ff 	. 
	rst 38h			;6cd2	ff 	. 
	rst 38h			;6cd3	ff 	. 
	rst 38h			;6cd4	ff 	. 
	rst 38h			;6cd5	ff 	. 
	rst 38h			;6cd6	ff 	. 
	rst 38h			;6cd7	ff 	. 
	rst 38h			;6cd8	ff 	. 
	rst 38h			;6cd9	ff 	. 
	rst 38h			;6cda	ff 	. 
	rst 38h			;6cdb	ff 	. 
	rst 38h			;6cdc	ff 	. 
	rst 38h			;6cdd	ff 	. 
	rst 38h			;6cde	ff 	. 
	rst 38h			;6cdf	ff 	. 
	rst 38h			;6ce0	ff 	. 
	rst 38h			;6ce1	ff 	. 
	rst 38h			;6ce2	ff 	. 
	rst 38h			;6ce3	ff 	. 
l6ce4h:
	rst 38h			;6ce4	ff 	. 
	rst 38h			;6ce5	ff 	. 
	rst 38h			;6ce6	ff 	. 
	rst 38h			;6ce7	ff 	. 
	rst 38h			;6ce8	ff 	. 
	rst 38h			;6ce9	ff 	. 
	rst 38h			;6cea	ff 	. 
	rst 38h			;6ceb	ff 	. 
	rst 38h			;6cec	ff 	. 
	rst 38h			;6ced	ff 	. 
	rst 38h			;6cee	ff 	. 
	rst 38h			;6cef	ff 	. 
	rst 38h			;6cf0	ff 	. 
	rst 38h			;6cf1	ff 	. 
	rst 38h			;6cf2	ff 	. 
	rst 38h			;6cf3	ff 	. 
	rst 38h			;6cf4	ff 	. 
	rst 38h			;6cf5	ff 	. 
	rst 38h			;6cf6	ff 	. 
	rst 38h			;6cf7	ff 	. 
	rst 38h			;6cf8	ff 	. 
	rst 38h			;6cf9	ff 	. 
	rst 38h			;6cfa	ff 	. 
	rst 38h			;6cfb	ff 	. 
	rst 38h			;6cfc	ff 	. 
	rst 38h			;6cfd	ff 	. 
	rst 38h			;6cfe	ff 	. 
	rst 38h			;6cff	ff 	. 
	rst 38h			;6d00	ff 	. 
	rst 38h			;6d01	ff 	. 
	rst 38h			;6d02	ff 	. 
	rst 38h			;6d03	ff 	. 
	rst 38h			;6d04	ff 	. 
	rst 38h			;6d05	ff 	. 
	rst 38h			;6d06	ff 	. 
	rst 38h			;6d07	ff 	. 
	rst 38h			;6d08	ff 	. 
	rst 38h			;6d09	ff 	. 
	rst 38h			;6d0a	ff 	. 
	rst 38h			;6d0b	ff 	. 
	rst 38h			;6d0c	ff 	. 
	rst 38h			;6d0d	ff 	. 
	rst 38h			;6d0e	ff 	. 
	rst 38h			;6d0f	ff 	. 
	rst 38h			;6d10	ff 	. 
	rst 38h			;6d11	ff 	. 
	rst 38h			;6d12	ff 	. 
	rst 38h			;6d13	ff 	. 
	rst 38h			;6d14	ff 	. 
	rst 38h			;6d15	ff 	. 
	rst 38h			;6d16	ff 	. 
	rst 38h			;6d17	ff 	. 
	rst 38h			;6d18	ff 	. 
	rst 38h			;6d19	ff 	. 
	rst 38h			;6d1a	ff 	. 
	rst 38h			;6d1b	ff 	. 
	rst 38h			;6d1c	ff 	. 
	rst 38h			;6d1d	ff 	. 
	rst 38h			;6d1e	ff 	. 
	rst 38h			;6d1f	ff 	. 
	rst 38h			;6d20	ff 	. 
	rst 38h			;6d21	ff 	. 
	rst 38h			;6d22	ff 	. 
	rst 38h			;6d23	ff 	. 
	rst 38h			;6d24	ff 	. 
	rst 38h			;6d25	ff 	. 
	rst 38h			;6d26	ff 	. 
	rst 38h			;6d27	ff 	. 
	rst 38h			;6d28	ff 	. 
	rst 38h			;6d29	ff 	. 
	rst 38h			;6d2a	ff 	. 
	rst 38h			;6d2b	ff 	. 
	rst 38h			;6d2c	ff 	. 
	rst 38h			;6d2d	ff 	. 
	rst 38h			;6d2e	ff 	. 
	rst 38h			;6d2f	ff 	. 
	rst 38h			;6d30	ff 	. 
	rst 38h			;6d31	ff 	. 
	rst 38h			;6d32	ff 	. 
	rst 38h			;6d33	ff 	. 
	rst 38h			;6d34	ff 	. 
	rst 38h			;6d35	ff 	. 
	rst 38h			;6d36	ff 	. 
	rst 38h			;6d37	ff 	. 
	rst 38h			;6d38	ff 	. 
	rst 38h			;6d39	ff 	. 
	rst 38h			;6d3a	ff 	. 
	rst 38h			;6d3b	ff 	. 
	rst 38h			;6d3c	ff 	. 
	rst 38h			;6d3d	ff 	. 
	rst 38h			;6d3e	ff 	. 
	rst 38h			;6d3f	ff 	. 
	rst 38h			;6d40	ff 	. 
	rst 38h			;6d41	ff 	. 
	rst 38h			;6d42	ff 	. 
	rst 38h			;6d43	ff 	. 
	rst 38h			;6d44	ff 	. 
	rst 38h			;6d45	ff 	. 
	rst 38h			;6d46	ff 	. 
	rst 38h			;6d47	ff 	. 
	rst 38h			;6d48	ff 	. 
	rst 38h			;6d49	ff 	. 
	rst 38h			;6d4a	ff 	. 
	rst 38h			;6d4b	ff 	. 
	rst 38h			;6d4c	ff 	. 
	rst 38h			;6d4d	ff 	. 
	rst 38h			;6d4e	ff 	. 
	rst 38h			;6d4f	ff 	. 
	rst 38h			;6d50	ff 	. 
	rst 38h			;6d51	ff 	. 
	rst 38h			;6d52	ff 	. 
	rst 38h			;6d53	ff 	. 
	rst 38h			;6d54	ff 	. 
	rst 38h			;6d55	ff 	. 
	rst 38h			;6d56	ff 	. 
	rst 38h			;6d57	ff 	. 
	rst 38h			;6d58	ff 	. 
	rst 38h			;6d59	ff 	. 
	rst 38h			;6d5a	ff 	. 
	rst 38h			;6d5b	ff 	. 
	rst 38h			;6d5c	ff 	. 
	rst 38h			;6d5d	ff 	. 
	rst 38h			;6d5e	ff 	. 
	rst 38h			;6d5f	ff 	. 
	rst 38h			;6d60	ff 	. 
	rst 38h			;6d61	ff 	. 
	rst 38h			;6d62	ff 	. 
	rst 38h			;6d63	ff 	. 
	rst 38h			;6d64	ff 	. 
	rst 38h			;6d65	ff 	. 
	rst 38h			;6d66	ff 	. 
	rst 38h			;6d67	ff 	. 
	rst 38h			;6d68	ff 	. 
	rst 38h			;6d69	ff 	. 
	rst 38h			;6d6a	ff 	. 
	rst 38h			;6d6b	ff 	. 
	rst 38h			;6d6c	ff 	. 
sub_6d6dh:
	rst 38h			;6d6d	ff 	. 
	rst 38h			;6d6e	ff 	. 
	rst 38h			;6d6f	ff 	. 
	rst 38h			;6d70	ff 	. 
	rst 38h			;6d71	ff 	. 
	rst 38h			;6d72	ff 	. 
	rst 38h			;6d73	ff 	. 
	rst 38h			;6d74	ff 	. 
	rst 38h			;6d75	ff 	. 
	rst 38h			;6d76	ff 	. 
	rst 38h			;6d77	ff 	. 
	rst 38h			;6d78	ff 	. 
	rst 38h			;6d79	ff 	. 
	rst 38h			;6d7a	ff 	. 
	rst 38h			;6d7b	ff 	. 
	rst 38h			;6d7c	ff 	. 
	rst 38h			;6d7d	ff 	. 
	rst 38h			;6d7e	ff 	. 
	rst 38h			;6d7f	ff 	. 
	rst 38h			;6d80	ff 	. 
	rst 38h			;6d81	ff 	. 
	rst 38h			;6d82	ff 	. 
	rst 38h			;6d83	ff 	. 
	rst 38h			;6d84	ff 	. 
	rst 38h			;6d85	ff 	. 
	rst 38h			;6d86	ff 	. 
	rst 38h			;6d87	ff 	. 
	rst 38h			;6d88	ff 	. 
	rst 38h			;6d89	ff 	. 
	rst 38h			;6d8a	ff 	. 
	rst 38h			;6d8b	ff 	. 
	rst 38h			;6d8c	ff 	. 
	rst 38h			;6d8d	ff 	. 
	rst 38h			;6d8e	ff 	. 
	rst 38h			;6d8f	ff 	. 
	rst 38h			;6d90	ff 	. 
	rst 38h			;6d91	ff 	. 
	rst 38h			;6d92	ff 	. 
	rst 38h			;6d93	ff 	. 
	rst 38h			;6d94	ff 	. 
	rst 38h			;6d95	ff 	. 
	rst 38h			;6d96	ff 	. 
	rst 38h			;6d97	ff 	. 
	rst 38h			;6d98	ff 	. 
	rst 38h			;6d99	ff 	. 
	rst 38h			;6d9a	ff 	. 
	rst 38h			;6d9b	ff 	. 
	rst 38h			;6d9c	ff 	. 
	rst 38h			;6d9d	ff 	. 
	rst 38h			;6d9e	ff 	. 
	rst 38h			;6d9f	ff 	. 
	rst 38h			;6da0	ff 	. 
	rst 38h			;6da1	ff 	. 
	rst 38h			;6da2	ff 	. 
	rst 38h			;6da3	ff 	. 
	rst 38h			;6da4	ff 	. 
	rst 38h			;6da5	ff 	. 
	rst 38h			;6da6	ff 	. 
	rst 38h			;6da7	ff 	. 
	rst 38h			;6da8	ff 	. 
	rst 38h			;6da9	ff 	. 
	rst 38h			;6daa	ff 	. 
	rst 38h			;6dab	ff 	. 
	rst 38h			;6dac	ff 	. 
	rst 38h			;6dad	ff 	. 
	rst 38h			;6dae	ff 	. 
	rst 38h			;6daf	ff 	. 
	rst 38h			;6db0	ff 	. 
	rst 38h			;6db1	ff 	. 
	rst 38h			;6db2	ff 	. 
	rst 38h			;6db3	ff 	. 
	rst 38h			;6db4	ff 	. 
	rst 38h			;6db5	ff 	. 
	rst 38h			;6db6	ff 	. 
	rst 38h			;6db7	ff 	. 
	rst 38h			;6db8	ff 	. 
	rst 38h			;6db9	ff 	. 
	rst 38h			;6dba	ff 	. 
	rst 38h			;6dbb	ff 	. 
	rst 38h			;6dbc	ff 	. 
	rst 38h			;6dbd	ff 	. 
	rst 38h			;6dbe	ff 	. 
	rst 38h			;6dbf	ff 	. 
	rst 38h			;6dc0	ff 	. 
	rst 38h			;6dc1	ff 	. 
	rst 38h			;6dc2	ff 	. 
	rst 38h			;6dc3	ff 	. 
	rst 38h			;6dc4	ff 	. 
	rst 38h			;6dc5	ff 	. 
	rst 38h			;6dc6	ff 	. 
	rst 38h			;6dc7	ff 	. 
	rst 38h			;6dc8	ff 	. 
	rst 38h			;6dc9	ff 	. 
	rst 38h			;6dca	ff 	. 
	rst 38h			;6dcb	ff 	. 
	rst 38h			;6dcc	ff 	. 
	rst 38h			;6dcd	ff 	. 
	rst 38h			;6dce	ff 	. 
	rst 38h			;6dcf	ff 	. 
	rst 38h			;6dd0	ff 	. 
	rst 38h			;6dd1	ff 	. 
	rst 38h			;6dd2	ff 	. 
	rst 38h			;6dd3	ff 	. 
	rst 38h			;6dd4	ff 	. 
	rst 38h			;6dd5	ff 	. 
	rst 38h			;6dd6	ff 	. 
	rst 38h			;6dd7	ff 	. 
	rst 38h			;6dd8	ff 	. 
	rst 38h			;6dd9	ff 	. 
	rst 38h			;6dda	ff 	. 
	rst 38h			;6ddb	ff 	. 
	rst 38h			;6ddc	ff 	. 
	rst 38h			;6ddd	ff 	. 
	rst 38h			;6dde	ff 	. 
	rst 38h			;6ddf	ff 	. 
	rst 38h			;6de0	ff 	. 
	rst 38h			;6de1	ff 	. 
	rst 38h			;6de2	ff 	. 
	rst 38h			;6de3	ff 	. 
	rst 38h			;6de4	ff 	. 
	rst 38h			;6de5	ff 	. 
	rst 38h			;6de6	ff 	. 
	rst 38h			;6de7	ff 	. 
	rst 38h			;6de8	ff 	. 
	rst 38h			;6de9	ff 	. 
	rst 38h			;6dea	ff 	. 
	rst 38h			;6deb	ff 	. 
	rst 38h			;6dec	ff 	. 
	rst 38h			;6ded	ff 	. 
	rst 38h			;6dee	ff 	. 
	rst 38h			;6def	ff 	. 
	rst 38h			;6df0	ff 	. 
	rst 38h			;6df1	ff 	. 
	rst 38h			;6df2	ff 	. 
	rst 38h			;6df3	ff 	. 
	rst 38h			;6df4	ff 	. 
	rst 38h			;6df5	ff 	. 
	rst 38h			;6df6	ff 	. 
	rst 38h			;6df7	ff 	. 
	rst 38h			;6df8	ff 	. 
	rst 38h			;6df9	ff 	. 
	rst 38h			;6dfa	ff 	. 
	rst 38h			;6dfb	ff 	. 
	rst 38h			;6dfc	ff 	. 
	rst 38h			;6dfd	ff 	. 
	rst 38h			;6dfe	ff 	. 
	rst 38h			;6dff	ff 	. 
	rst 38h			;6e00	ff 	. 
	rst 38h			;6e01	ff 	. 
	rst 38h			;6e02	ff 	. 
	rst 38h			;6e03	ff 	. 
	rst 38h			;6e04	ff 	. 
	rst 38h			;6e05	ff 	. 
	rst 38h			;6e06	ff 	. 
	rst 38h			;6e07	ff 	. 
	rst 38h			;6e08	ff 	. 
	rst 38h			;6e09	ff 	. 
	rst 38h			;6e0a	ff 	. 
	rst 38h			;6e0b	ff 	. 
	rst 38h			;6e0c	ff 	. 
	rst 38h			;6e0d	ff 	. 
	rst 38h			;6e0e	ff 	. 
	rst 38h			;6e0f	ff 	. 
	rst 38h			;6e10	ff 	. 
	rst 38h			;6e11	ff 	. 
	rst 38h			;6e12	ff 	. 
	rst 38h			;6e13	ff 	. 
	rst 38h			;6e14	ff 	. 
	rst 38h			;6e15	ff 	. 
	rst 38h			;6e16	ff 	. 
	rst 38h			;6e17	ff 	. 
	rst 38h			;6e18	ff 	. 
	rst 38h			;6e19	ff 	. 
	rst 38h			;6e1a	ff 	. 
	rst 38h			;6e1b	ff 	. 
	rst 38h			;6e1c	ff 	. 
	rst 38h			;6e1d	ff 	. 
	rst 38h			;6e1e	ff 	. 
	rst 38h			;6e1f	ff 	. 
	rst 38h			;6e20	ff 	. 
	rst 38h			;6e21	ff 	. 
	rst 38h			;6e22	ff 	. 
	rst 38h			;6e23	ff 	. 
	rst 38h			;6e24	ff 	. 
	rst 38h			;6e25	ff 	. 
	rst 38h			;6e26	ff 	. 
	rst 38h			;6e27	ff 	. 
	rst 38h			;6e28	ff 	. 
	rst 38h			;6e29	ff 	. 
	rst 38h			;6e2a	ff 	. 
	rst 38h			;6e2b	ff 	. 
	rst 38h			;6e2c	ff 	. 
	rst 38h			;6e2d	ff 	. 
	rst 38h			;6e2e	ff 	. 
	rst 38h			;6e2f	ff 	. 
	rst 38h			;6e30	ff 	. 
	rst 38h			;6e31	ff 	. 
	rst 38h			;6e32	ff 	. 
	rst 38h			;6e33	ff 	. 
	rst 38h			;6e34	ff 	. 
	rst 38h			;6e35	ff 	. 
	rst 38h			;6e36	ff 	. 
	rst 38h			;6e37	ff 	. 
	rst 38h			;6e38	ff 	. 
	rst 38h			;6e39	ff 	. 
	rst 38h			;6e3a	ff 	. 
	rst 38h			;6e3b	ff 	. 
	rst 38h			;6e3c	ff 	. 
	rst 38h			;6e3d	ff 	. 
	rst 38h			;6e3e	ff 	. 
	rst 38h			;6e3f	ff 	. 
	rst 38h			;6e40	ff 	. 
	rst 38h			;6e41	ff 	. 
	rst 38h			;6e42	ff 	. 
	rst 38h			;6e43	ff 	. 
	rst 38h			;6e44	ff 	. 
	rst 38h			;6e45	ff 	. 
	rst 38h			;6e46	ff 	. 
	rst 38h			;6e47	ff 	. 
	rst 38h			;6e48	ff 	. 
	rst 38h			;6e49	ff 	. 
	rst 38h			;6e4a	ff 	. 
	rst 38h			;6e4b	ff 	. 
	rst 38h			;6e4c	ff 	. 
	rst 38h			;6e4d	ff 	. 
	rst 38h			;6e4e	ff 	. 
	rst 38h			;6e4f	ff 	. 
	rst 38h			;6e50	ff 	. 
	rst 38h			;6e51	ff 	. 
	rst 38h			;6e52	ff 	. 
	rst 38h			;6e53	ff 	. 
	rst 38h			;6e54	ff 	. 
	rst 38h			;6e55	ff 	. 
	rst 38h			;6e56	ff 	. 
	rst 38h			;6e57	ff 	. 
	rst 38h			;6e58	ff 	. 
	rst 38h			;6e59	ff 	. 
	rst 38h			;6e5a	ff 	. 
	rst 38h			;6e5b	ff 	. 
	rst 38h			;6e5c	ff 	. 
	rst 38h			;6e5d	ff 	. 
	rst 38h			;6e5e	ff 	. 
	rst 38h			;6e5f	ff 	. 
	rst 38h			;6e60	ff 	. 
	rst 38h			;6e61	ff 	. 
	rst 38h			;6e62	ff 	. 
	rst 38h			;6e63	ff 	. 
	rst 38h			;6e64	ff 	. 
	rst 38h			;6e65	ff 	. 
	rst 38h			;6e66	ff 	. 
	rst 38h			;6e67	ff 	. 
	rst 38h			;6e68	ff 	. 
	rst 38h			;6e69	ff 	. 
	rst 38h			;6e6a	ff 	. 
	rst 38h			;6e6b	ff 	. 
	rst 38h			;6e6c	ff 	. 
	rst 38h			;6e6d	ff 	. 
	rst 38h			;6e6e	ff 	. 
	rst 38h			;6e6f	ff 	. 
	rst 38h			;6e70	ff 	. 
	rst 38h			;6e71	ff 	. 
	rst 38h			;6e72	ff 	. 
	rst 38h			;6e73	ff 	. 
	rst 38h			;6e74	ff 	. 
	rst 38h			;6e75	ff 	. 
	rst 38h			;6e76	ff 	. 
	rst 38h			;6e77	ff 	. 
	rst 38h			;6e78	ff 	. 
	rst 38h			;6e79	ff 	. 
	rst 38h			;6e7a	ff 	. 
	rst 38h			;6e7b	ff 	. 
	rst 38h			;6e7c	ff 	. 
	rst 38h			;6e7d	ff 	. 
	rst 38h			;6e7e	ff 	. 
	rst 38h			;6e7f	ff 	. 
	rst 38h			;6e80	ff 	. 
	rst 38h			;6e81	ff 	. 
	rst 38h			;6e82	ff 	. 
	rst 38h			;6e83	ff 	. 
	rst 38h			;6e84	ff 	. 
	rst 38h			;6e85	ff 	. 
	rst 38h			;6e86	ff 	. 
	rst 38h			;6e87	ff 	. 
	rst 38h			;6e88	ff 	. 
	rst 38h			;6e89	ff 	. 
	rst 38h			;6e8a	ff 	. 
	rst 38h			;6e8b	ff 	. 
	rst 38h			;6e8c	ff 	. 
	rst 38h			;6e8d	ff 	. 
	rst 38h			;6e8e	ff 	. 
	rst 38h			;6e8f	ff 	. 
	rst 38h			;6e90	ff 	. 
	rst 38h			;6e91	ff 	. 
	rst 38h			;6e92	ff 	. 
	rst 38h			;6e93	ff 	. 
	rst 38h			;6e94	ff 	. 
	rst 38h			;6e95	ff 	. 
	rst 38h			;6e96	ff 	. 
	rst 38h			;6e97	ff 	. 
	rst 38h			;6e98	ff 	. 
	rst 38h			;6e99	ff 	. 
	rst 38h			;6e9a	ff 	. 
	rst 38h			;6e9b	ff 	. 
	rst 38h			;6e9c	ff 	. 
	rst 38h			;6e9d	ff 	. 
	rst 38h			;6e9e	ff 	. 
	rst 38h			;6e9f	ff 	. 
	rst 38h			;6ea0	ff 	. 
	rst 38h			;6ea1	ff 	. 
	rst 38h			;6ea2	ff 	. 
	rst 38h			;6ea3	ff 	. 
	rst 38h			;6ea4	ff 	. 
	rst 38h			;6ea5	ff 	. 
	rst 38h			;6ea6	ff 	. 
	rst 38h			;6ea7	ff 	. 
	rst 38h			;6ea8	ff 	. 
	rst 38h			;6ea9	ff 	. 
	rst 38h			;6eaa	ff 	. 
	rst 38h			;6eab	ff 	. 
	rst 38h			;6eac	ff 	. 
	rst 38h			;6ead	ff 	. 
	rst 38h			;6eae	ff 	. 
	rst 38h			;6eaf	ff 	. 
	rst 38h			;6eb0	ff 	. 
	rst 38h			;6eb1	ff 	. 
	rst 38h			;6eb2	ff 	. 
	rst 38h			;6eb3	ff 	. 
	rst 38h			;6eb4	ff 	. 
	rst 38h			;6eb5	ff 	. 
	rst 38h			;6eb6	ff 	. 
	rst 38h			;6eb7	ff 	. 
	rst 38h			;6eb8	ff 	. 
	rst 38h			;6eb9	ff 	. 
	rst 38h			;6eba	ff 	. 
	rst 38h			;6ebb	ff 	. 
	rst 38h			;6ebc	ff 	. 
	rst 38h			;6ebd	ff 	. 
	rst 38h			;6ebe	ff 	. 
	rst 38h			;6ebf	ff 	. 
	rst 38h			;6ec0	ff 	. 
	rst 38h			;6ec1	ff 	. 
	rst 38h			;6ec2	ff 	. 
	rst 38h			;6ec3	ff 	. 
	rst 38h			;6ec4	ff 	. 
	rst 38h			;6ec5	ff 	. 
	rst 38h			;6ec6	ff 	. 
	rst 38h			;6ec7	ff 	. 
	rst 38h			;6ec8	ff 	. 
	rst 38h			;6ec9	ff 	. 
	rst 38h			;6eca	ff 	. 
	rst 38h			;6ecb	ff 	. 
	rst 38h			;6ecc	ff 	. 
	rst 38h			;6ecd	ff 	. 
	rst 38h			;6ece	ff 	. 
	rst 38h			;6ecf	ff 	. 
	rst 38h			;6ed0	ff 	. 
	rst 38h			;6ed1	ff 	. 
	rst 38h			;6ed2	ff 	. 
	rst 38h			;6ed3	ff 	. 
	rst 38h			;6ed4	ff 	. 
	rst 38h			;6ed5	ff 	. 
	rst 38h			;6ed6	ff 	. 
	rst 38h			;6ed7	ff 	. 
	rst 38h			;6ed8	ff 	. 
	rst 38h			;6ed9	ff 	. 
	rst 38h			;6eda	ff 	. 
	rst 38h			;6edb	ff 	. 
	rst 38h			;6edc	ff 	. 
	rst 38h			;6edd	ff 	. 
	rst 38h			;6ede	ff 	. 
	rst 38h			;6edf	ff 	. 
	rst 38h			;6ee0	ff 	. 
	rst 38h			;6ee1	ff 	. 
	rst 38h			;6ee2	ff 	. 
	rst 38h			;6ee3	ff 	. 
	rst 38h			;6ee4	ff 	. 
	rst 38h			;6ee5	ff 	. 
	rst 38h			;6ee6	ff 	. 
	rst 38h			;6ee7	ff 	. 
	rst 38h			;6ee8	ff 	. 
	rst 38h			;6ee9	ff 	. 
	rst 38h			;6eea	ff 	. 
	rst 38h			;6eeb	ff 	. 
sub_6eech:
	rst 38h			;6eec	ff 	. 
	rst 38h			;6eed	ff 	. 
	rst 38h			;6eee	ff 	. 
	rst 38h			;6eef	ff 	. 
	rst 38h			;6ef0	ff 	. 
	rst 38h			;6ef1	ff 	. 
	rst 38h			;6ef2	ff 	. 
	rst 38h			;6ef3	ff 	. 
	rst 38h			;6ef4	ff 	. 
	rst 38h			;6ef5	ff 	. 
	rst 38h			;6ef6	ff 	. 
	rst 38h			;6ef7	ff 	. 
	rst 38h			;6ef8	ff 	. 
	rst 38h			;6ef9	ff 	. 
	rst 38h			;6efa	ff 	. 
	rst 38h			;6efb	ff 	. 
	rst 38h			;6efc	ff 	. 
	rst 38h			;6efd	ff 	. 
	rst 38h			;6efe	ff 	. 
	rst 38h			;6eff	ff 	. 
	rst 38h			;6f00	ff 	. 
	rst 38h			;6f01	ff 	. 
	rst 38h			;6f02	ff 	. 
	rst 38h			;6f03	ff 	. 
	rst 38h			;6f04	ff 	. 
	rst 38h			;6f05	ff 	. 
	rst 38h			;6f06	ff 	. 
	rst 38h			;6f07	ff 	. 
	rst 38h			;6f08	ff 	. 
	rst 38h			;6f09	ff 	. 
	rst 38h			;6f0a	ff 	. 
	rst 38h			;6f0b	ff 	. 
	rst 38h			;6f0c	ff 	. 
	rst 38h			;6f0d	ff 	. 
	rst 38h			;6f0e	ff 	. 
	rst 38h			;6f0f	ff 	. 
	rst 38h			;6f10	ff 	. 
	rst 38h			;6f11	ff 	. 
	rst 38h			;6f12	ff 	. 
	rst 38h			;6f13	ff 	. 
	rst 38h			;6f14	ff 	. 
	rst 38h			;6f15	ff 	. 
	rst 38h			;6f16	ff 	. 
	rst 38h			;6f17	ff 	. 
	rst 38h			;6f18	ff 	. 
	rst 38h			;6f19	ff 	. 
	rst 38h			;6f1a	ff 	. 
	rst 38h			;6f1b	ff 	. 
	rst 38h			;6f1c	ff 	. 
	rst 38h			;6f1d	ff 	. 
	rst 38h			;6f1e	ff 	. 
	rst 38h			;6f1f	ff 	. 
	rst 38h			;6f20	ff 	. 
	rst 38h			;6f21	ff 	. 
	rst 38h			;6f22	ff 	. 
	rst 38h			;6f23	ff 	. 
	rst 38h			;6f24	ff 	. 
	rst 38h			;6f25	ff 	. 
	rst 38h			;6f26	ff 	. 
	rst 38h			;6f27	ff 	. 
	rst 38h			;6f28	ff 	. 
	rst 38h			;6f29	ff 	. 
	rst 38h			;6f2a	ff 	. 
	rst 38h			;6f2b	ff 	. 
	rst 38h			;6f2c	ff 	. 
	rst 38h			;6f2d	ff 	. 
	rst 38h			;6f2e	ff 	. 
	rst 38h			;6f2f	ff 	. 
	rst 38h			;6f30	ff 	. 
	rst 38h			;6f31	ff 	. 
	rst 38h			;6f32	ff 	. 
	rst 38h			;6f33	ff 	. 
	rst 38h			;6f34	ff 	. 
	rst 38h			;6f35	ff 	. 
	rst 38h			;6f36	ff 	. 
	rst 38h			;6f37	ff 	. 
	rst 38h			;6f38	ff 	. 
	rst 38h			;6f39	ff 	. 
	rst 38h			;6f3a	ff 	. 
	rst 38h			;6f3b	ff 	. 
	rst 38h			;6f3c	ff 	. 
	rst 38h			;6f3d	ff 	. 
	rst 38h			;6f3e	ff 	. 
	rst 38h			;6f3f	ff 	. 
	rst 38h			;6f40	ff 	. 
	rst 38h			;6f41	ff 	. 
	rst 38h			;6f42	ff 	. 
	rst 38h			;6f43	ff 	. 
	rst 38h			;6f44	ff 	. 
	rst 38h			;6f45	ff 	. 
	rst 38h			;6f46	ff 	. 
	rst 38h			;6f47	ff 	. 
	rst 38h			;6f48	ff 	. 
	rst 38h			;6f49	ff 	. 
	rst 38h			;6f4a	ff 	. 
	rst 38h			;6f4b	ff 	. 
	rst 38h			;6f4c	ff 	. 
	rst 38h			;6f4d	ff 	. 
	rst 38h			;6f4e	ff 	. 
	rst 38h			;6f4f	ff 	. 
	rst 38h			;6f50	ff 	. 
	rst 38h			;6f51	ff 	. 
	rst 38h			;6f52	ff 	. 
	rst 38h			;6f53	ff 	. 
	rst 38h			;6f54	ff 	. 
	rst 38h			;6f55	ff 	. 
	rst 38h			;6f56	ff 	. 
	rst 38h			;6f57	ff 	. 
	rst 38h			;6f58	ff 	. 
	rst 38h			;6f59	ff 	. 
	rst 38h			;6f5a	ff 	. 
	rst 38h			;6f5b	ff 	. 
	rst 38h			;6f5c	ff 	. 
	rst 38h			;6f5d	ff 	. 
	rst 38h			;6f5e	ff 	. 
	rst 38h			;6f5f	ff 	. 
	rst 38h			;6f60	ff 	. 
	rst 38h			;6f61	ff 	. 
	rst 38h			;6f62	ff 	. 
	rst 38h			;6f63	ff 	. 
	rst 38h			;6f64	ff 	. 
	rst 38h			;6f65	ff 	. 
	rst 38h			;6f66	ff 	. 
	rst 38h			;6f67	ff 	. 
	rst 38h			;6f68	ff 	. 
	rst 38h			;6f69	ff 	. 
	rst 38h			;6f6a	ff 	. 
	rst 38h			;6f6b	ff 	. 
	rst 38h			;6f6c	ff 	. 
	rst 38h			;6f6d	ff 	. 
	rst 38h			;6f6e	ff 	. 
	rst 38h			;6f6f	ff 	. 
	rst 38h			;6f70	ff 	. 
	rst 38h			;6f71	ff 	. 
	rst 38h			;6f72	ff 	. 
	rst 38h			;6f73	ff 	. 
	rst 38h			;6f74	ff 	. 
	rst 38h			;6f75	ff 	. 
	rst 38h			;6f76	ff 	. 
	rst 38h			;6f77	ff 	. 
	rst 38h			;6f78	ff 	. 
	rst 38h			;6f79	ff 	. 
	rst 38h			;6f7a	ff 	. 
	rst 38h			;6f7b	ff 	. 
	rst 38h			;6f7c	ff 	. 
	rst 38h			;6f7d	ff 	. 
	rst 38h			;6f7e	ff 	. 
	rst 38h			;6f7f	ff 	. 
	rst 38h			;6f80	ff 	. 
	rst 38h			;6f81	ff 	. 
	rst 38h			;6f82	ff 	. 
	rst 38h			;6f83	ff 	. 
	rst 38h			;6f84	ff 	. 
	rst 38h			;6f85	ff 	. 
	rst 38h			;6f86	ff 	. 
	rst 38h			;6f87	ff 	. 
	rst 38h			;6f88	ff 	. 
	rst 38h			;6f89	ff 	. 
	rst 38h			;6f8a	ff 	. 
	rst 38h			;6f8b	ff 	. 
	rst 38h			;6f8c	ff 	. 
	rst 38h			;6f8d	ff 	. 
	rst 38h			;6f8e	ff 	. 
	rst 38h			;6f8f	ff 	. 
	rst 38h			;6f90	ff 	. 
	rst 38h			;6f91	ff 	. 
	rst 38h			;6f92	ff 	. 
	rst 38h			;6f93	ff 	. 
	rst 38h			;6f94	ff 	. 
	rst 38h			;6f95	ff 	. 
	rst 38h			;6f96	ff 	. 
	rst 38h			;6f97	ff 	. 
	rst 38h			;6f98	ff 	. 
	rst 38h			;6f99	ff 	. 
	rst 38h			;6f9a	ff 	. 
	rst 38h			;6f9b	ff 	. 
	rst 38h			;6f9c	ff 	. 
	rst 38h			;6f9d	ff 	. 
	rst 38h			;6f9e	ff 	. 
	rst 38h			;6f9f	ff 	. 
	rst 38h			;6fa0	ff 	. 
	rst 38h			;6fa1	ff 	. 
	rst 38h			;6fa2	ff 	. 
	rst 38h			;6fa3	ff 	. 
	rst 38h			;6fa4	ff 	. 
	rst 38h			;6fa5	ff 	. 
	rst 38h			;6fa6	ff 	. 
	rst 38h			;6fa7	ff 	. 
	rst 38h			;6fa8	ff 	. 
	rst 38h			;6fa9	ff 	. 
	rst 38h			;6faa	ff 	. 
	rst 38h			;6fab	ff 	. 
	rst 38h			;6fac	ff 	. 
	rst 38h			;6fad	ff 	. 
	rst 38h			;6fae	ff 	. 
	rst 38h			;6faf	ff 	. 
	rst 38h			;6fb0	ff 	. 
	rst 38h			;6fb1	ff 	. 
	rst 38h			;6fb2	ff 	. 
	rst 38h			;6fb3	ff 	. 
	rst 38h			;6fb4	ff 	. 
	rst 38h			;6fb5	ff 	. 
	rst 38h			;6fb6	ff 	. 
	rst 38h			;6fb7	ff 	. 
	rst 38h			;6fb8	ff 	. 
	rst 38h			;6fb9	ff 	. 
	rst 38h			;6fba	ff 	. 
	rst 38h			;6fbb	ff 	. 
	rst 38h			;6fbc	ff 	. 
	rst 38h			;6fbd	ff 	. 
	rst 38h			;6fbe	ff 	. 
	rst 38h			;6fbf	ff 	. 
	rst 38h			;6fc0	ff 	. 
	rst 38h			;6fc1	ff 	. 
	rst 38h			;6fc2	ff 	. 
	rst 38h			;6fc3	ff 	. 
	rst 38h			;6fc4	ff 	. 
	rst 38h			;6fc5	ff 	. 
	rst 38h			;6fc6	ff 	. 
	rst 38h			;6fc7	ff 	. 
	rst 38h			;6fc8	ff 	. 
	rst 38h			;6fc9	ff 	. 
	rst 38h			;6fca	ff 	. 
	rst 38h			;6fcb	ff 	. 
	rst 38h			;6fcc	ff 	. 
	rst 38h			;6fcd	ff 	. 
	rst 38h			;6fce	ff 	. 
	rst 38h			;6fcf	ff 	. 
	rst 38h			;6fd0	ff 	. 
	rst 38h			;6fd1	ff 	. 
	rst 38h			;6fd2	ff 	. 
	rst 38h			;6fd3	ff 	. 
	rst 38h			;6fd4	ff 	. 
	rst 38h			;6fd5	ff 	. 
	rst 38h			;6fd6	ff 	. 
	rst 38h			;6fd7	ff 	. 
	rst 38h			;6fd8	ff 	. 
	rst 38h			;6fd9	ff 	. 
	rst 38h			;6fda	ff 	. 
	rst 38h			;6fdb	ff 	. 
	rst 38h			;6fdc	ff 	. 
	rst 38h			;6fdd	ff 	. 
	rst 38h			;6fde	ff 	. 
	rst 38h			;6fdf	ff 	. 
	rst 38h			;6fe0	ff 	. 
	rst 38h			;6fe1	ff 	. 
	rst 38h			;6fe2	ff 	. 
	rst 38h			;6fe3	ff 	. 
	rst 38h			;6fe4	ff 	. 
	rst 38h			;6fe5	ff 	. 
	rst 38h			;6fe6	ff 	. 
	rst 38h			;6fe7	ff 	. 
	rst 38h			;6fe8	ff 	. 
	rst 38h			;6fe9	ff 	. 
	rst 38h			;6fea	ff 	. 
	rst 38h			;6feb	ff 	. 
	rst 38h			;6fec	ff 	. 
	rst 38h			;6fed	ff 	. 
	rst 38h			;6fee	ff 	. 
	rst 38h			;6fef	ff 	. 
	rst 38h			;6ff0	ff 	. 
	rst 38h			;6ff1	ff 	. 
	rst 38h			;6ff2	ff 	. 
	rst 38h			;6ff3	ff 	. 
	rst 38h			;6ff4	ff 	. 
	rst 38h			;6ff5	ff 	. 
	rst 38h			;6ff6	ff 	. 
	rst 38h			;6ff7	ff 	. 
	rst 38h			;6ff8	ff 	. 
	rst 38h			;6ff9	ff 	. 
	rst 38h			;6ffa	ff 	. 
	rst 38h			;6ffb	ff 	. 
	rst 38h			;6ffc	ff 	. 
	rst 38h			;6ffd	ff 	. 
	rst 38h			;6ffe	ff 	. 
	rst 38h			;6fff	ff 	. 
	rst 38h			;7000	ff 	. 
	rst 38h			;7001	ff 	. 
	rst 38h			;7002	ff 	. 
	rst 38h			;7003	ff 	. 
	rst 38h			;7004	ff 	. 
	rst 38h			;7005	ff 	. 
	rst 38h			;7006	ff 	. 
	rst 38h			;7007	ff 	. 
	rst 38h			;7008	ff 	. 
	rst 38h			;7009	ff 	. 
	rst 38h			;700a	ff 	. 
	rst 38h			;700b	ff 	. 
	rst 38h			;700c	ff 	. 
	rst 38h			;700d	ff 	. 
	rst 38h			;700e	ff 	. 
	rst 38h			;700f	ff 	. 
	rst 38h			;7010	ff 	. 
	rst 38h			;7011	ff 	. 
	rst 38h			;7012	ff 	. 
	rst 38h			;7013	ff 	. 
	rst 38h			;7014	ff 	. 
	rst 38h			;7015	ff 	. 
	rst 38h			;7016	ff 	. 
	rst 38h			;7017	ff 	. 
	rst 38h			;7018	ff 	. 
	rst 38h			;7019	ff 	. 
	rst 38h			;701a	ff 	. 
	rst 38h			;701b	ff 	. 
	rst 38h			;701c	ff 	. 
	rst 38h			;701d	ff 	. 
	rst 38h			;701e	ff 	. 
	rst 38h			;701f	ff 	. 
	rst 38h			;7020	ff 	. 
	rst 38h			;7021	ff 	. 
	rst 38h			;7022	ff 	. 
	rst 38h			;7023	ff 	. 
	rst 38h			;7024	ff 	. 
	rst 38h			;7025	ff 	. 
	rst 38h			;7026	ff 	. 
	rst 38h			;7027	ff 	. 
	rst 38h			;7028	ff 	. 
	rst 38h			;7029	ff 	. 
	rst 38h			;702a	ff 	. 
	rst 38h			;702b	ff 	. 
	rst 38h			;702c	ff 	. 
	rst 38h			;702d	ff 	. 
	rst 38h			;702e	ff 	. 
	rst 38h			;702f	ff 	. 
	rst 38h			;7030	ff 	. 
	rst 38h			;7031	ff 	. 
	rst 38h			;7032	ff 	. 
	rst 38h			;7033	ff 	. 
	rst 38h			;7034	ff 	. 
	rst 38h			;7035	ff 	. 
	rst 38h			;7036	ff 	. 
	rst 38h			;7037	ff 	. 
	rst 38h			;7038	ff 	. 
	rst 38h			;7039	ff 	. 
	rst 38h			;703a	ff 	. 
	rst 38h			;703b	ff 	. 
	rst 38h			;703c	ff 	. 
	rst 38h			;703d	ff 	. 
	rst 38h			;703e	ff 	. 
	rst 38h			;703f	ff 	. 
	rst 38h			;7040	ff 	. 
	rst 38h			;7041	ff 	. 
	rst 38h			;7042	ff 	. 
	rst 38h			;7043	ff 	. 
	rst 38h			;7044	ff 	. 
	rst 38h			;7045	ff 	. 
	rst 38h			;7046	ff 	. 
	rst 38h			;7047	ff 	. 
	rst 38h			;7048	ff 	. 
	rst 38h			;7049	ff 	. 
	rst 38h			;704a	ff 	. 
	rst 38h			;704b	ff 	. 
	rst 38h			;704c	ff 	. 
	rst 38h			;704d	ff 	. 
	rst 38h			;704e	ff 	. 
	rst 38h			;704f	ff 	. 
	rst 38h			;7050	ff 	. 
	rst 38h			;7051	ff 	. 
	rst 38h			;7052	ff 	. 
	rst 38h			;7053	ff 	. 
	rst 38h			;7054	ff 	. 
	rst 38h			;7055	ff 	. 
	rst 38h			;7056	ff 	. 
	rst 38h			;7057	ff 	. 
	rst 38h			;7058	ff 	. 
	rst 38h			;7059	ff 	. 
	rst 38h			;705a	ff 	. 
	rst 38h			;705b	ff 	. 
	rst 38h			;705c	ff 	. 
	rst 38h			;705d	ff 	. 
	rst 38h			;705e	ff 	. 
	rst 38h			;705f	ff 	. 
	rst 38h			;7060	ff 	. 
	rst 38h			;7061	ff 	. 
	rst 38h			;7062	ff 	. 
	rst 38h			;7063	ff 	. 
	rst 38h			;7064	ff 	. 
	rst 38h			;7065	ff 	. 
	rst 38h			;7066	ff 	. 
	rst 38h			;7067	ff 	. 
	rst 38h			;7068	ff 	. 
	rst 38h			;7069	ff 	. 
	rst 38h			;706a	ff 	. 
	rst 38h			;706b	ff 	. 
	rst 38h			;706c	ff 	. 
	rst 38h			;706d	ff 	. 
	rst 38h			;706e	ff 	. 
	rst 38h			;706f	ff 	. 
	rst 38h			;7070	ff 	. 
	rst 38h			;7071	ff 	. 
	rst 38h			;7072	ff 	. 
	rst 38h			;7073	ff 	. 
	rst 38h			;7074	ff 	. 
	rst 38h			;7075	ff 	. 
	rst 38h			;7076	ff 	. 
	rst 38h			;7077	ff 	. 
	rst 38h			;7078	ff 	. 
	rst 38h			;7079	ff 	. 
	rst 38h			;707a	ff 	. 
	rst 38h			;707b	ff 	. 
	rst 38h			;707c	ff 	. 
	rst 38h			;707d	ff 	. 
	rst 38h			;707e	ff 	. 
	rst 38h			;707f	ff 	. 
	rst 38h			;7080	ff 	. 
	rst 38h			;7081	ff 	. 
	rst 38h			;7082	ff 	. 
	rst 38h			;7083	ff 	. 
	rst 38h			;7084	ff 	. 
	rst 38h			;7085	ff 	. 
	rst 38h			;7086	ff 	. 
	rst 38h			;7087	ff 	. 
	rst 38h			;7088	ff 	. 
	rst 38h			;7089	ff 	. 
	rst 38h			;708a	ff 	. 
	rst 38h			;708b	ff 	. 
	rst 38h			;708c	ff 	. 
	rst 38h			;708d	ff 	. 
	rst 38h			;708e	ff 	. 
	rst 38h			;708f	ff 	. 
	rst 38h			;7090	ff 	. 
	rst 38h			;7091	ff 	. 
	rst 38h			;7092	ff 	. 
	rst 38h			;7093	ff 	. 
	rst 38h			;7094	ff 	. 
	rst 38h			;7095	ff 	. 
	rst 38h			;7096	ff 	. 
	rst 38h			;7097	ff 	. 
	rst 38h			;7098	ff 	. 
	rst 38h			;7099	ff 	. 
	rst 38h			;709a	ff 	. 
	rst 38h			;709b	ff 	. 
	rst 38h			;709c	ff 	. 
	rst 38h			;709d	ff 	. 
	rst 38h			;709e	ff 	. 
	rst 38h			;709f	ff 	. 
	rst 38h			;70a0	ff 	. 
	rst 38h			;70a1	ff 	. 
	rst 38h			;70a2	ff 	. 
	rst 38h			;70a3	ff 	. 
	rst 38h			;70a4	ff 	. 
	rst 38h			;70a5	ff 	. 
	rst 38h			;70a6	ff 	. 
	rst 38h			;70a7	ff 	. 
	rst 38h			;70a8	ff 	. 
	rst 38h			;70a9	ff 	. 
	rst 38h			;70aa	ff 	. 
	rst 38h			;70ab	ff 	. 
	rst 38h			;70ac	ff 	. 
	rst 38h			;70ad	ff 	. 
	rst 38h			;70ae	ff 	. 
	rst 38h			;70af	ff 	. 
	rst 38h			;70b0	ff 	. 
	rst 38h			;70b1	ff 	. 
	rst 38h			;70b2	ff 	. 
	rst 38h			;70b3	ff 	. 
	rst 38h			;70b4	ff 	. 
	rst 38h			;70b5	ff 	. 
	rst 38h			;70b6	ff 	. 
	rst 38h			;70b7	ff 	. 
	rst 38h			;70b8	ff 	. 
	rst 38h			;70b9	ff 	. 
	rst 38h			;70ba	ff 	. 
	rst 38h			;70bb	ff 	. 
	rst 38h			;70bc	ff 	. 
	rst 38h			;70bd	ff 	. 
	rst 38h			;70be	ff 	. 
	rst 38h			;70bf	ff 	. 
	rst 38h			;70c0	ff 	. 
	rst 38h			;70c1	ff 	. 
	rst 38h			;70c2	ff 	. 
	rst 38h			;70c3	ff 	. 
	rst 38h			;70c4	ff 	. 
	rst 38h			;70c5	ff 	. 
	rst 38h			;70c6	ff 	. 
	rst 38h			;70c7	ff 	. 
	rst 38h			;70c8	ff 	. 
	rst 38h			;70c9	ff 	. 
	rst 38h			;70ca	ff 	. 
	rst 38h			;70cb	ff 	. 
	rst 38h			;70cc	ff 	. 
	rst 38h			;70cd	ff 	. 
	rst 38h			;70ce	ff 	. 
	rst 38h			;70cf	ff 	. 
	rst 38h			;70d0	ff 	. 
	rst 38h			;70d1	ff 	. 
	rst 38h			;70d2	ff 	. 
	rst 38h			;70d3	ff 	. 
	rst 38h			;70d4	ff 	. 
	rst 38h			;70d5	ff 	. 
	rst 38h			;70d6	ff 	. 
	rst 38h			;70d7	ff 	. 
	rst 38h			;70d8	ff 	. 
	rst 38h			;70d9	ff 	. 
	rst 38h			;70da	ff 	. 
	rst 38h			;70db	ff 	. 
	rst 38h			;70dc	ff 	. 
	rst 38h			;70dd	ff 	. 
	rst 38h			;70de	ff 	. 
	rst 38h			;70df	ff 	. 
	rst 38h			;70e0	ff 	. 
	rst 38h			;70e1	ff 	. 
	rst 38h			;70e2	ff 	. 
	rst 38h			;70e3	ff 	. 
	rst 38h			;70e4	ff 	. 
	rst 38h			;70e5	ff 	. 
	rst 38h			;70e6	ff 	. 
	rst 38h			;70e7	ff 	. 
	rst 38h			;70e8	ff 	. 
	rst 38h			;70e9	ff 	. 
	rst 38h			;70ea	ff 	. 
	rst 38h			;70eb	ff 	. 
	rst 38h			;70ec	ff 	. 
	rst 38h			;70ed	ff 	. 
	rst 38h			;70ee	ff 	. 
	rst 38h			;70ef	ff 	. 
	rst 38h			;70f0	ff 	. 
	rst 38h			;70f1	ff 	. 
	rst 38h			;70f2	ff 	. 
	rst 38h			;70f3	ff 	. 
	rst 38h			;70f4	ff 	. 
	rst 38h			;70f5	ff 	. 
	rst 38h			;70f6	ff 	. 
	rst 38h			;70f7	ff 	. 
	rst 38h			;70f8	ff 	. 
	rst 38h			;70f9	ff 	. 
	rst 38h			;70fa	ff 	. 
	rst 38h			;70fb	ff 	. 
	rst 38h			;70fc	ff 	. 
	rst 38h			;70fd	ff 	. 
	rst 38h			;70fe	ff 	. 
	rst 38h			;70ff	ff 	. 
	rst 38h			;7100	ff 	. 
	rst 38h			;7101	ff 	. 
	rst 38h			;7102	ff 	. 
	rst 38h			;7103	ff 	. 
	rst 38h			;7104	ff 	. 
	rst 38h			;7105	ff 	. 
	rst 38h			;7106	ff 	. 
	rst 38h			;7107	ff 	. 
	rst 38h			;7108	ff 	. 
	rst 38h			;7109	ff 	. 
	rst 38h			;710a	ff 	. 
	rst 38h			;710b	ff 	. 
	rst 38h			;710c	ff 	. 
	rst 38h			;710d	ff 	. 
	rst 38h			;710e	ff 	. 
	rst 38h			;710f	ff 	. 
	rst 38h			;7110	ff 	. 
	rst 38h			;7111	ff 	. 
	rst 38h			;7112	ff 	. 
	rst 38h			;7113	ff 	. 
	rst 38h			;7114	ff 	. 
	rst 38h			;7115	ff 	. 
	rst 38h			;7116	ff 	. 
	rst 38h			;7117	ff 	. 
	rst 38h			;7118	ff 	. 
	rst 38h			;7119	ff 	. 
	rst 38h			;711a	ff 	. 
	rst 38h			;711b	ff 	. 
	rst 38h			;711c	ff 	. 
	rst 38h			;711d	ff 	. 
	rst 38h			;711e	ff 	. 
	rst 38h			;711f	ff 	. 
	rst 38h			;7120	ff 	. 
	rst 38h			;7121	ff 	. 
	rst 38h			;7122	ff 	. 
	rst 38h			;7123	ff 	. 
	rst 38h			;7124	ff 	. 
	rst 38h			;7125	ff 	. 
	rst 38h			;7126	ff 	. 
	rst 38h			;7127	ff 	. 
	rst 38h			;7128	ff 	. 
	rst 38h			;7129	ff 	. 
	rst 38h			;712a	ff 	. 
	rst 38h			;712b	ff 	. 
	rst 38h			;712c	ff 	. 
	rst 38h			;712d	ff 	. 
	rst 38h			;712e	ff 	. 
	rst 38h			;712f	ff 	. 
	rst 38h			;7130	ff 	. 
	rst 38h			;7131	ff 	. 
	rst 38h			;7132	ff 	. 
	rst 38h			;7133	ff 	. 
	rst 38h			;7134	ff 	. 
	rst 38h			;7135	ff 	. 
	rst 38h			;7136	ff 	. 
	rst 38h			;7137	ff 	. 
	rst 38h			;7138	ff 	. 
	rst 38h			;7139	ff 	. 
	rst 38h			;713a	ff 	. 
	rst 38h			;713b	ff 	. 
	rst 38h			;713c	ff 	. 
	rst 38h			;713d	ff 	. 
	rst 38h			;713e	ff 	. 
	rst 38h			;713f	ff 	. 
	rst 38h			;7140	ff 	. 
	rst 38h			;7141	ff 	. 
	rst 38h			;7142	ff 	. 
	rst 38h			;7143	ff 	. 
	rst 38h			;7144	ff 	. 
	rst 38h			;7145	ff 	. 
	rst 38h			;7146	ff 	. 
	rst 38h			;7147	ff 	. 
	rst 38h			;7148	ff 	. 
	rst 38h			;7149	ff 	. 
	rst 38h			;714a	ff 	. 
	rst 38h			;714b	ff 	. 
	rst 38h			;714c	ff 	. 
	rst 38h			;714d	ff 	. 
	rst 38h			;714e	ff 	. 
	rst 38h			;714f	ff 	. 
	rst 38h			;7150	ff 	. 
	rst 38h			;7151	ff 	. 
	rst 38h			;7152	ff 	. 
	rst 38h			;7153	ff 	. 
	rst 38h			;7154	ff 	. 
	rst 38h			;7155	ff 	. 
	rst 38h			;7156	ff 	. 
	rst 38h			;7157	ff 	. 
	rst 38h			;7158	ff 	. 
	rst 38h			;7159	ff 	. 
	rst 38h			;715a	ff 	. 
	rst 38h			;715b	ff 	. 
	rst 38h			;715c	ff 	. 
	rst 38h			;715d	ff 	. 
	rst 38h			;715e	ff 	. 
	rst 38h			;715f	ff 	. 
	rst 38h			;7160	ff 	. 
	rst 38h			;7161	ff 	. 
	rst 38h			;7162	ff 	. 
	rst 38h			;7163	ff 	. 
	rst 38h			;7164	ff 	. 
	rst 38h			;7165	ff 	. 
	rst 38h			;7166	ff 	. 
	rst 38h			;7167	ff 	. 
	rst 38h			;7168	ff 	. 
	rst 38h			;7169	ff 	. 
	rst 38h			;716a	ff 	. 
	rst 38h			;716b	ff 	. 
	rst 38h			;716c	ff 	. 
	rst 38h			;716d	ff 	. 
	rst 38h			;716e	ff 	. 
	rst 38h			;716f	ff 	. 
	rst 38h			;7170	ff 	. 
	rst 38h			;7171	ff 	. 
	rst 38h			;7172	ff 	. 
	rst 38h			;7173	ff 	. 
	rst 38h			;7174	ff 	. 
	rst 38h			;7175	ff 	. 
	rst 38h			;7176	ff 	. 
	rst 38h			;7177	ff 	. 
	rst 38h			;7178	ff 	. 
	rst 38h			;7179	ff 	. 
	rst 38h			;717a	ff 	. 
	rst 38h			;717b	ff 	. 
	rst 38h			;717c	ff 	. 
	rst 38h			;717d	ff 	. 
	rst 38h			;717e	ff 	. 
	rst 38h			;717f	ff 	. 
	rst 38h			;7180	ff 	. 
	rst 38h			;7181	ff 	. 
	rst 38h			;7182	ff 	. 
	rst 38h			;7183	ff 	. 
	rst 38h			;7184	ff 	. 
	rst 38h			;7185	ff 	. 
	rst 38h			;7186	ff 	. 
	rst 38h			;7187	ff 	. 
	rst 38h			;7188	ff 	. 
	rst 38h			;7189	ff 	. 
	rst 38h			;718a	ff 	. 
	rst 38h			;718b	ff 	. 
	rst 38h			;718c	ff 	. 
	rst 38h			;718d	ff 	. 
	rst 38h			;718e	ff 	. 
	rst 38h			;718f	ff 	. 
	rst 38h			;7190	ff 	. 
	rst 38h			;7191	ff 	. 
	rst 38h			;7192	ff 	. 
	rst 38h			;7193	ff 	. 
	rst 38h			;7194	ff 	. 
	rst 38h			;7195	ff 	. 
	rst 38h			;7196	ff 	. 
	rst 38h			;7197	ff 	. 
	rst 38h			;7198	ff 	. 
	rst 38h			;7199	ff 	. 
	rst 38h			;719a	ff 	. 
	rst 38h			;719b	ff 	. 
	rst 38h			;719c	ff 	. 
	rst 38h			;719d	ff 	. 
	rst 38h			;719e	ff 	. 
	rst 38h			;719f	ff 	. 
	rst 38h			;71a0	ff 	. 
	rst 38h			;71a1	ff 	. 
	rst 38h			;71a2	ff 	. 
	rst 38h			;71a3	ff 	. 
	rst 38h			;71a4	ff 	. 
	rst 38h			;71a5	ff 	. 
	rst 38h			;71a6	ff 	. 
	rst 38h			;71a7	ff 	. 
	rst 38h			;71a8	ff 	. 
	rst 38h			;71a9	ff 	. 
	rst 38h			;71aa	ff 	. 
	rst 38h			;71ab	ff 	. 
	rst 38h			;71ac	ff 	. 
	rst 38h			;71ad	ff 	. 
	rst 38h			;71ae	ff 	. 
	rst 38h			;71af	ff 	. 
	rst 38h			;71b0	ff 	. 
	rst 38h			;71b1	ff 	. 
	rst 38h			;71b2	ff 	. 
	rst 38h			;71b3	ff 	. 
	rst 38h			;71b4	ff 	. 
	rst 38h			;71b5	ff 	. 
	rst 38h			;71b6	ff 	. 
	rst 38h			;71b7	ff 	. 
	rst 38h			;71b8	ff 	. 
	rst 38h			;71b9	ff 	. 
	rst 38h			;71ba	ff 	. 
	rst 38h			;71bb	ff 	. 
	rst 38h			;71bc	ff 	. 
	rst 38h			;71bd	ff 	. 
	rst 38h			;71be	ff 	. 
	rst 38h			;71bf	ff 	. 
	rst 38h			;71c0	ff 	. 
	rst 38h			;71c1	ff 	. 
	rst 38h			;71c2	ff 	. 
	rst 38h			;71c3	ff 	. 
	rst 38h			;71c4	ff 	. 
	rst 38h			;71c5	ff 	. 
	rst 38h			;71c6	ff 	. 
	rst 38h			;71c7	ff 	. 
	rst 38h			;71c8	ff 	. 
	rst 38h			;71c9	ff 	. 
	rst 38h			;71ca	ff 	. 
	rst 38h			;71cb	ff 	. 
	rst 38h			;71cc	ff 	. 
	rst 38h			;71cd	ff 	. 
	rst 38h			;71ce	ff 	. 
	rst 38h			;71cf	ff 	. 
	rst 38h			;71d0	ff 	. 
	rst 38h			;71d1	ff 	. 
	rst 38h			;71d2	ff 	. 
	rst 38h			;71d3	ff 	. 
	rst 38h			;71d4	ff 	. 
	rst 38h			;71d5	ff 	. 
	rst 38h			;71d6	ff 	. 
	rst 38h			;71d7	ff 	. 
	rst 38h			;71d8	ff 	. 
	rst 38h			;71d9	ff 	. 
	rst 38h			;71da	ff 	. 
	rst 38h			;71db	ff 	. 
	rst 38h			;71dc	ff 	. 
	rst 38h			;71dd	ff 	. 
	rst 38h			;71de	ff 	. 
	rst 38h			;71df	ff 	. 
	rst 38h			;71e0	ff 	. 
	rst 38h			;71e1	ff 	. 
	rst 38h			;71e2	ff 	. 
	rst 38h			;71e3	ff 	. 
	rst 38h			;71e4	ff 	. 
	rst 38h			;71e5	ff 	. 
	rst 38h			;71e6	ff 	. 
	rst 38h			;71e7	ff 	. 
	rst 38h			;71e8	ff 	. 
	rst 38h			;71e9	ff 	. 
	rst 38h			;71ea	ff 	. 
	rst 38h			;71eb	ff 	. 
	rst 38h			;71ec	ff 	. 
	rst 38h			;71ed	ff 	. 
	rst 38h			;71ee	ff 	. 
	rst 38h			;71ef	ff 	. 
	rst 38h			;71f0	ff 	. 
	rst 38h			;71f1	ff 	. 
	rst 38h			;71f2	ff 	. 
	rst 38h			;71f3	ff 	. 
	rst 38h			;71f4	ff 	. 
	rst 38h			;71f5	ff 	. 
	rst 38h			;71f6	ff 	. 
	rst 38h			;71f7	ff 	. 
	rst 38h			;71f8	ff 	. 
	rst 38h			;71f9	ff 	. 
	rst 38h			;71fa	ff 	. 
	rst 38h			;71fb	ff 	. 
	rst 38h			;71fc	ff 	. 
	rst 38h			;71fd	ff 	. 
	rst 38h			;71fe	ff 	. 
	rst 38h			;71ff	ff 	. 
	rst 38h			;7200	ff 	. 
	rst 38h			;7201	ff 	. 
	rst 38h			;7202	ff 	. 
	rst 38h			;7203	ff 	. 
	rst 38h			;7204	ff 	. 
	rst 38h			;7205	ff 	. 
	rst 38h			;7206	ff 	. 
	rst 38h			;7207	ff 	. 
	rst 38h			;7208	ff 	. 
	rst 38h			;7209	ff 	. 
	rst 38h			;720a	ff 	. 
	rst 38h			;720b	ff 	. 
	rst 38h			;720c	ff 	. 
	rst 38h			;720d	ff 	. 
	rst 38h			;720e	ff 	. 
	rst 38h			;720f	ff 	. 
	rst 38h			;7210	ff 	. 
	rst 38h			;7211	ff 	. 
	rst 38h			;7212	ff 	. 
	rst 38h			;7213	ff 	. 
	rst 38h			;7214	ff 	. 
	rst 38h			;7215	ff 	. 
	rst 38h			;7216	ff 	. 
	rst 38h			;7217	ff 	. 
	rst 38h			;7218	ff 	. 
	rst 38h			;7219	ff 	. 
	rst 38h			;721a	ff 	. 
	rst 38h			;721b	ff 	. 
	rst 38h			;721c	ff 	. 
	rst 38h			;721d	ff 	. 
	rst 38h			;721e	ff 	. 
	rst 38h			;721f	ff 	. 
	rst 38h			;7220	ff 	. 
	rst 38h			;7221	ff 	. 
	rst 38h			;7222	ff 	. 
	rst 38h			;7223	ff 	. 
	rst 38h			;7224	ff 	. 
	rst 38h			;7225	ff 	. 
	rst 38h			;7226	ff 	. 
	rst 38h			;7227	ff 	. 
	rst 38h			;7228	ff 	. 
	rst 38h			;7229	ff 	. 
	rst 38h			;722a	ff 	. 
	rst 38h			;722b	ff 	. 
	rst 38h			;722c	ff 	. 
	rst 38h			;722d	ff 	. 
	rst 38h			;722e	ff 	. 
	rst 38h			;722f	ff 	. 
	rst 38h			;7230	ff 	. 
	rst 38h			;7231	ff 	. 
	rst 38h			;7232	ff 	. 
	rst 38h			;7233	ff 	. 
	rst 38h			;7234	ff 	. 
	rst 38h			;7235	ff 	. 
	rst 38h			;7236	ff 	. 
	rst 38h			;7237	ff 	. 
	rst 38h			;7238	ff 	. 
	rst 38h			;7239	ff 	. 
	rst 38h			;723a	ff 	. 
	rst 38h			;723b	ff 	. 
	rst 38h			;723c	ff 	. 
	rst 38h			;723d	ff 	. 
	rst 38h			;723e	ff 	. 
	rst 38h			;723f	ff 	. 
	rst 38h			;7240	ff 	. 
	rst 38h			;7241	ff 	. 
	rst 38h			;7242	ff 	. 
	rst 38h			;7243	ff 	. 
	rst 38h			;7244	ff 	. 
	rst 38h			;7245	ff 	. 
	rst 38h			;7246	ff 	. 
	rst 38h			;7247	ff 	. 
	rst 38h			;7248	ff 	. 
	rst 38h			;7249	ff 	. 
	rst 38h			;724a	ff 	. 
	rst 38h			;724b	ff 	. 
	rst 38h			;724c	ff 	. 
	rst 38h			;724d	ff 	. 
	rst 38h			;724e	ff 	. 
	rst 38h			;724f	ff 	. 
	rst 38h			;7250	ff 	. 
	rst 38h			;7251	ff 	. 
	rst 38h			;7252	ff 	. 
	rst 38h			;7253	ff 	. 
	rst 38h			;7254	ff 	. 
	rst 38h			;7255	ff 	. 
	rst 38h			;7256	ff 	. 
	rst 38h			;7257	ff 	. 
	rst 38h			;7258	ff 	. 
	rst 38h			;7259	ff 	. 
	rst 38h			;725a	ff 	. 
	rst 38h			;725b	ff 	. 
	rst 38h			;725c	ff 	. 
	rst 38h			;725d	ff 	. 
	rst 38h			;725e	ff 	. 
	rst 38h			;725f	ff 	. 
	rst 38h			;7260	ff 	. 
	rst 38h			;7261	ff 	. 
	rst 38h			;7262	ff 	. 
	rst 38h			;7263	ff 	. 
	rst 38h			;7264	ff 	. 
	rst 38h			;7265	ff 	. 
	rst 38h			;7266	ff 	. 
	rst 38h			;7267	ff 	. 
	rst 38h			;7268	ff 	. 
	rst 38h			;7269	ff 	. 
	rst 38h			;726a	ff 	. 
	rst 38h			;726b	ff 	. 
	rst 38h			;726c	ff 	. 
	rst 38h			;726d	ff 	. 
	rst 38h			;726e	ff 	. 
	rst 38h			;726f	ff 	. 
	rst 38h			;7270	ff 	. 
	rst 38h			;7271	ff 	. 
	rst 38h			;7272	ff 	. 
	rst 38h			;7273	ff 	. 
	rst 38h			;7274	ff 	. 
	rst 38h			;7275	ff 	. 
	rst 38h			;7276	ff 	. 
	rst 38h			;7277	ff 	. 
	rst 38h			;7278	ff 	. 
	rst 38h			;7279	ff 	. 
	rst 38h			;727a	ff 	. 
	rst 38h			;727b	ff 	. 
	rst 38h			;727c	ff 	. 
	rst 38h			;727d	ff 	. 
	rst 38h			;727e	ff 	. 
	rst 38h			;727f	ff 	. 
	rst 38h			;7280	ff 	. 
	rst 38h			;7281	ff 	. 
	rst 38h			;7282	ff 	. 
	rst 38h			;7283	ff 	. 
	rst 38h			;7284	ff 	. 
	rst 38h			;7285	ff 	. 
	rst 38h			;7286	ff 	. 
	rst 38h			;7287	ff 	. 
	rst 38h			;7288	ff 	. 
	rst 38h			;7289	ff 	. 
	rst 38h			;728a	ff 	. 
	rst 38h			;728b	ff 	. 
	rst 38h			;728c	ff 	. 
	rst 38h			;728d	ff 	. 
	rst 38h			;728e	ff 	. 
	rst 38h			;728f	ff 	. 
	rst 38h			;7290	ff 	. 
	rst 38h			;7291	ff 	. 
	rst 38h			;7292	ff 	. 
	rst 38h			;7293	ff 	. 
	rst 38h			;7294	ff 	. 
	rst 38h			;7295	ff 	. 
	rst 38h			;7296	ff 	. 
	rst 38h			;7297	ff 	. 
	rst 38h			;7298	ff 	. 
	rst 38h			;7299	ff 	. 
	rst 38h			;729a	ff 	. 
	rst 38h			;729b	ff 	. 
	rst 38h			;729c	ff 	. 
	rst 38h			;729d	ff 	. 
	rst 38h			;729e	ff 	. 
	rst 38h			;729f	ff 	. 
	rst 38h			;72a0	ff 	. 
	rst 38h			;72a1	ff 	. 
	rst 38h			;72a2	ff 	. 
	rst 38h			;72a3	ff 	. 
	rst 38h			;72a4	ff 	. 
	rst 38h			;72a5	ff 	. 
	rst 38h			;72a6	ff 	. 
	rst 38h			;72a7	ff 	. 
	rst 38h			;72a8	ff 	. 
	rst 38h			;72a9	ff 	. 
	rst 38h			;72aa	ff 	. 
	rst 38h			;72ab	ff 	. 
	rst 38h			;72ac	ff 	. 
	rst 38h			;72ad	ff 	. 
	rst 38h			;72ae	ff 	. 
	rst 38h			;72af	ff 	. 
	rst 38h			;72b0	ff 	. 
	rst 38h			;72b1	ff 	. 
	rst 38h			;72b2	ff 	. 
	rst 38h			;72b3	ff 	. 
	rst 38h			;72b4	ff 	. 
	rst 38h			;72b5	ff 	. 
	rst 38h			;72b6	ff 	. 
	rst 38h			;72b7	ff 	. 
	rst 38h			;72b8	ff 	. 
	rst 38h			;72b9	ff 	. 
	rst 38h			;72ba	ff 	. 
	rst 38h			;72bb	ff 	. 
	rst 38h			;72bc	ff 	. 
	rst 38h			;72bd	ff 	. 
	rst 38h			;72be	ff 	. 
	rst 38h			;72bf	ff 	. 
	rst 38h			;72c0	ff 	. 
	rst 38h			;72c1	ff 	. 
	rst 38h			;72c2	ff 	. 
	rst 38h			;72c3	ff 	. 
	rst 38h			;72c4	ff 	. 
	rst 38h			;72c5	ff 	. 
	rst 38h			;72c6	ff 	. 
	rst 38h			;72c7	ff 	. 
	rst 38h			;72c8	ff 	. 
	rst 38h			;72c9	ff 	. 
	rst 38h			;72ca	ff 	. 
	rst 38h			;72cb	ff 	. 
	rst 38h			;72cc	ff 	. 
	rst 38h			;72cd	ff 	. 
	rst 38h			;72ce	ff 	. 
	rst 38h			;72cf	ff 	. 
	rst 38h			;72d0	ff 	. 
	rst 38h			;72d1	ff 	. 
	rst 38h			;72d2	ff 	. 
	rst 38h			;72d3	ff 	. 
	rst 38h			;72d4	ff 	. 
	rst 38h			;72d5	ff 	. 
	rst 38h			;72d6	ff 	. 
	rst 38h			;72d7	ff 	. 
	rst 38h			;72d8	ff 	. 
	rst 38h			;72d9	ff 	. 
	rst 38h			;72da	ff 	. 
	rst 38h			;72db	ff 	. 
	rst 38h			;72dc	ff 	. 
	rst 38h			;72dd	ff 	. 
	rst 38h			;72de	ff 	. 
	rst 38h			;72df	ff 	. 
	rst 38h			;72e0	ff 	. 
	rst 38h			;72e1	ff 	. 
	rst 38h			;72e2	ff 	. 
	rst 38h			;72e3	ff 	. 
	rst 38h			;72e4	ff 	. 
	rst 38h			;72e5	ff 	. 
	rst 38h			;72e6	ff 	. 
	rst 38h			;72e7	ff 	. 
	rst 38h			;72e8	ff 	. 
	rst 38h			;72e9	ff 	. 
	rst 38h			;72ea	ff 	. 
	rst 38h			;72eb	ff 	. 
	rst 38h			;72ec	ff 	. 
	rst 38h			;72ed	ff 	. 
	rst 38h			;72ee	ff 	. 
	rst 38h			;72ef	ff 	. 
	rst 38h			;72f0	ff 	. 
	rst 38h			;72f1	ff 	. 
	rst 38h			;72f2	ff 	. 
	rst 38h			;72f3	ff 	. 
	rst 38h			;72f4	ff 	. 
	rst 38h			;72f5	ff 	. 
	rst 38h			;72f6	ff 	. 
	rst 38h			;72f7	ff 	. 
	rst 38h			;72f8	ff 	. 
	rst 38h			;72f9	ff 	. 
	rst 38h			;72fa	ff 	. 
	rst 38h			;72fb	ff 	. 
	rst 38h			;72fc	ff 	. 
	rst 38h			;72fd	ff 	. 
	rst 38h			;72fe	ff 	. 
	rst 38h			;72ff	ff 	. 
	rst 38h			;7300	ff 	. 
	rst 38h			;7301	ff 	. 
	rst 38h			;7302	ff 	. 
	rst 38h			;7303	ff 	. 
	rst 38h			;7304	ff 	. 
	rst 38h			;7305	ff 	. 
	rst 38h			;7306	ff 	. 
	rst 38h			;7307	ff 	. 
	rst 38h			;7308	ff 	. 
	rst 38h			;7309	ff 	. 
	rst 38h			;730a	ff 	. 
	rst 38h			;730b	ff 	. 
	rst 38h			;730c	ff 	. 
	rst 38h			;730d	ff 	. 
	rst 38h			;730e	ff 	. 
	rst 38h			;730f	ff 	. 
	rst 38h			;7310	ff 	. 
	rst 38h			;7311	ff 	. 
	rst 38h			;7312	ff 	. 
	rst 38h			;7313	ff 	. 
	rst 38h			;7314	ff 	. 
	rst 38h			;7315	ff 	. 
	rst 38h			;7316	ff 	. 
	rst 38h			;7317	ff 	. 
	rst 38h			;7318	ff 	. 
	rst 38h			;7319	ff 	. 
	rst 38h			;731a	ff 	. 
	rst 38h			;731b	ff 	. 
	rst 38h			;731c	ff 	. 
	rst 38h			;731d	ff 	. 
	rst 38h			;731e	ff 	. 
	rst 38h			;731f	ff 	. 
	rst 38h			;7320	ff 	. 
	rst 38h			;7321	ff 	. 
	rst 38h			;7322	ff 	. 
	rst 38h			;7323	ff 	. 
	rst 38h			;7324	ff 	. 
	rst 38h			;7325	ff 	. 
	rst 38h			;7326	ff 	. 
	rst 38h			;7327	ff 	. 
	rst 38h			;7328	ff 	. 
	rst 38h			;7329	ff 	. 
	rst 38h			;732a	ff 	. 
	rst 38h			;732b	ff 	. 
	rst 38h			;732c	ff 	. 
	rst 38h			;732d	ff 	. 
	rst 38h			;732e	ff 	. 
	rst 38h			;732f	ff 	. 
	rst 38h			;7330	ff 	. 
	rst 38h			;7331	ff 	. 
	rst 38h			;7332	ff 	. 
	rst 38h			;7333	ff 	. 
	rst 38h			;7334	ff 	. 
	rst 38h			;7335	ff 	. 
	rst 38h			;7336	ff 	. 
	rst 38h			;7337	ff 	. 
	rst 38h			;7338	ff 	. 
	rst 38h			;7339	ff 	. 
	rst 38h			;733a	ff 	. 
	rst 38h			;733b	ff 	. 
	rst 38h			;733c	ff 	. 
	rst 38h			;733d	ff 	. 
	rst 38h			;733e	ff 	. 
	rst 38h			;733f	ff 	. 
	rst 38h			;7340	ff 	. 
	rst 38h			;7341	ff 	. 
	rst 38h			;7342	ff 	. 
	rst 38h			;7343	ff 	. 
	rst 38h			;7344	ff 	. 
	rst 38h			;7345	ff 	. 
	rst 38h			;7346	ff 	. 
	rst 38h			;7347	ff 	. 
	rst 38h			;7348	ff 	. 
	rst 38h			;7349	ff 	. 
	rst 38h			;734a	ff 	. 
	rst 38h			;734b	ff 	. 
	rst 38h			;734c	ff 	. 
	rst 38h			;734d	ff 	. 
	rst 38h			;734e	ff 	. 
	rst 38h			;734f	ff 	. 
	rst 38h			;7350	ff 	. 
	rst 38h			;7351	ff 	. 
	rst 38h			;7352	ff 	. 
	rst 38h			;7353	ff 	. 
	rst 38h			;7354	ff 	. 
	rst 38h			;7355	ff 	. 
	rst 38h			;7356	ff 	. 
	rst 38h			;7357	ff 	. 
	rst 38h			;7358	ff 	. 
	rst 38h			;7359	ff 	. 
	rst 38h			;735a	ff 	. 
	rst 38h			;735b	ff 	. 
	rst 38h			;735c	ff 	. 
	rst 38h			;735d	ff 	. 
	rst 38h			;735e	ff 	. 
	rst 38h			;735f	ff 	. 
	rst 38h			;7360	ff 	. 
	rst 38h			;7361	ff 	. 
	rst 38h			;7362	ff 	. 
	rst 38h			;7363	ff 	. 
	rst 38h			;7364	ff 	. 
	rst 38h			;7365	ff 	. 
	rst 38h			;7366	ff 	. 
	rst 38h			;7367	ff 	. 
	rst 38h			;7368	ff 	. 
	rst 38h			;7369	ff 	. 
	rst 38h			;736a	ff 	. 
	rst 38h			;736b	ff 	. 
	rst 38h			;736c	ff 	. 
	rst 38h			;736d	ff 	. 
	rst 38h			;736e	ff 	. 
	rst 38h			;736f	ff 	. 
	rst 38h			;7370	ff 	. 
	rst 38h			;7371	ff 	. 
	rst 38h			;7372	ff 	. 
	rst 38h			;7373	ff 	. 
	rst 38h			;7374	ff 	. 
	rst 38h			;7375	ff 	. 
	rst 38h			;7376	ff 	. 
	rst 38h			;7377	ff 	. 
	rst 38h			;7378	ff 	. 
	rst 38h			;7379	ff 	. 
	rst 38h			;737a	ff 	. 
	rst 38h			;737b	ff 	. 
	rst 38h			;737c	ff 	. 
	rst 38h			;737d	ff 	. 
	rst 38h			;737e	ff 	. 
	rst 38h			;737f	ff 	. 
	rst 38h			;7380	ff 	. 
	rst 38h			;7381	ff 	. 
	rst 38h			;7382	ff 	. 
	rst 38h			;7383	ff 	. 
	rst 38h			;7384	ff 	. 
	rst 38h			;7385	ff 	. 
	rst 38h			;7386	ff 	. 
	rst 38h			;7387	ff 	. 
	rst 38h			;7388	ff 	. 
	rst 38h			;7389	ff 	. 
	rst 38h			;738a	ff 	. 
	rst 38h			;738b	ff 	. 
	rst 38h			;738c	ff 	. 
	rst 38h			;738d	ff 	. 
	rst 38h			;738e	ff 	. 
	rst 38h			;738f	ff 	. 
	rst 38h			;7390	ff 	. 
	rst 38h			;7391	ff 	. 
	rst 38h			;7392	ff 	. 
	rst 38h			;7393	ff 	. 
	rst 38h			;7394	ff 	. 
	rst 38h			;7395	ff 	. 
	rst 38h			;7396	ff 	. 
	rst 38h			;7397	ff 	. 
	rst 38h			;7398	ff 	. 
	rst 38h			;7399	ff 	. 
	rst 38h			;739a	ff 	. 
	rst 38h			;739b	ff 	. 
	rst 38h			;739c	ff 	. 
	rst 38h			;739d	ff 	. 
	rst 38h			;739e	ff 	. 
	rst 38h			;739f	ff 	. 
	rst 38h			;73a0	ff 	. 
	rst 38h			;73a1	ff 	. 
	rst 38h			;73a2	ff 	. 
	rst 38h			;73a3	ff 	. 
	rst 38h			;73a4	ff 	. 
	rst 38h			;73a5	ff 	. 
	rst 38h			;73a6	ff 	. 
	rst 38h			;73a7	ff 	. 
	rst 38h			;73a8	ff 	. 
	rst 38h			;73a9	ff 	. 
	rst 38h			;73aa	ff 	. 
	rst 38h			;73ab	ff 	. 
	rst 38h			;73ac	ff 	. 
	rst 38h			;73ad	ff 	. 
	rst 38h			;73ae	ff 	. 
	rst 38h			;73af	ff 	. 
	rst 38h			;73b0	ff 	. 
	rst 38h			;73b1	ff 	. 
	rst 38h			;73b2	ff 	. 
	rst 38h			;73b3	ff 	. 
	rst 38h			;73b4	ff 	. 
	rst 38h			;73b5	ff 	. 
	rst 38h			;73b6	ff 	. 
	rst 38h			;73b7	ff 	. 
	rst 38h			;73b8	ff 	. 
	rst 38h			;73b9	ff 	. 
	rst 38h			;73ba	ff 	. 
	rst 38h			;73bb	ff 	. 
	rst 38h			;73bc	ff 	. 
	rst 38h			;73bd	ff 	. 
	rst 38h			;73be	ff 	. 
	rst 38h			;73bf	ff 	. 
	rst 38h			;73c0	ff 	. 
	rst 38h			;73c1	ff 	. 
	rst 38h			;73c2	ff 	. 
	rst 38h			;73c3	ff 	. 
	rst 38h			;73c4	ff 	. 
	rst 38h			;73c5	ff 	. 
	rst 38h			;73c6	ff 	. 
	rst 38h			;73c7	ff 	. 
	rst 38h			;73c8	ff 	. 
	rst 38h			;73c9	ff 	. 
	rst 38h			;73ca	ff 	. 
	rst 38h			;73cb	ff 	. 
	rst 38h			;73cc	ff 	. 
	rst 38h			;73cd	ff 	. 
	rst 38h			;73ce	ff 	. 
	rst 38h			;73cf	ff 	. 
	rst 38h			;73d0	ff 	. 
	rst 38h			;73d1	ff 	. 
	rst 38h			;73d2	ff 	. 
	rst 38h			;73d3	ff 	. 
	rst 38h			;73d4	ff 	. 
	rst 38h			;73d5	ff 	. 
	rst 38h			;73d6	ff 	. 
	rst 38h			;73d7	ff 	. 
	rst 38h			;73d8	ff 	. 
	rst 38h			;73d9	ff 	. 
	rst 38h			;73da	ff 	. 
	rst 38h			;73db	ff 	. 
	rst 38h			;73dc	ff 	. 
	rst 38h			;73dd	ff 	. 
	rst 38h			;73de	ff 	. 
	rst 38h			;73df	ff 	. 
	rst 38h			;73e0	ff 	. 
	rst 38h			;73e1	ff 	. 
	rst 38h			;73e2	ff 	. 
	rst 38h			;73e3	ff 	. 
	rst 38h			;73e4	ff 	. 
	rst 38h			;73e5	ff 	. 
	rst 38h			;73e6	ff 	. 
	rst 38h			;73e7	ff 	. 
	rst 38h			;73e8	ff 	. 
	rst 38h			;73e9	ff 	. 
	rst 38h			;73ea	ff 	. 
	rst 38h			;73eb	ff 	. 
	rst 38h			;73ec	ff 	. 
	rst 38h			;73ed	ff 	. 
	rst 38h			;73ee	ff 	. 
	rst 38h			;73ef	ff 	. 
	rst 38h			;73f0	ff 	. 
	rst 38h			;73f1	ff 	. 
	rst 38h			;73f2	ff 	. 
	rst 38h			;73f3	ff 	. 
	rst 38h			;73f4	ff 	. 
	rst 38h			;73f5	ff 	. 
	rst 38h			;73f6	ff 	. 
	rst 38h			;73f7	ff 	. 
	rst 38h			;73f8	ff 	. 
	rst 38h			;73f9	ff 	. 
	rst 38h			;73fa	ff 	. 
	rst 38h			;73fb	ff 	. 
	rst 38h			;73fc	ff 	. 
	rst 38h			;73fd	ff 	. 
	rst 38h			;73fe	ff 	. 
	rst 38h			;73ff	ff 	. 
	rst 38h			;7400	ff 	. 
	rst 38h			;7401	ff 	. 
	rst 38h			;7402	ff 	. 
	rst 38h			;7403	ff 	. 
	rst 38h			;7404	ff 	. 
	rst 38h			;7405	ff 	. 
	rst 38h			;7406	ff 	. 
	rst 38h			;7407	ff 	. 
	rst 38h			;7408	ff 	. 
	rst 38h			;7409	ff 	. 
	rst 38h			;740a	ff 	. 
	rst 38h			;740b	ff 	. 
	rst 38h			;740c	ff 	. 
	rst 38h			;740d	ff 	. 
	rst 38h			;740e	ff 	. 
	rst 38h			;740f	ff 	. 
	rst 38h			;7410	ff 	. 
	rst 38h			;7411	ff 	. 
	rst 38h			;7412	ff 	. 
	rst 38h			;7413	ff 	. 
	rst 38h			;7414	ff 	. 
	rst 38h			;7415	ff 	. 
	rst 38h			;7416	ff 	. 
	rst 38h			;7417	ff 	. 
	rst 38h			;7418	ff 	. 
	rst 38h			;7419	ff 	. 
	rst 38h			;741a	ff 	. 
	rst 38h			;741b	ff 	. 
	rst 38h			;741c	ff 	. 
	rst 38h			;741d	ff 	. 
	rst 38h			;741e	ff 	. 
	rst 38h			;741f	ff 	. 
	rst 38h			;7420	ff 	. 
	rst 38h			;7421	ff 	. 
	rst 38h			;7422	ff 	. 
	rst 38h			;7423	ff 	. 
	rst 38h			;7424	ff 	. 
	rst 38h			;7425	ff 	. 
	rst 38h			;7426	ff 	. 
	rst 38h			;7427	ff 	. 
	rst 38h			;7428	ff 	. 
	rst 38h			;7429	ff 	. 
	rst 38h			;742a	ff 	. 
	rst 38h			;742b	ff 	. 
	rst 38h			;742c	ff 	. 
	rst 38h			;742d	ff 	. 
	rst 38h			;742e	ff 	. 
	rst 38h			;742f	ff 	. 
	rst 38h			;7430	ff 	. 
	rst 38h			;7431	ff 	. 
	rst 38h			;7432	ff 	. 
	rst 38h			;7433	ff 	. 
	rst 38h			;7434	ff 	. 
	rst 38h			;7435	ff 	. 
	rst 38h			;7436	ff 	. 
	rst 38h			;7437	ff 	. 
	rst 38h			;7438	ff 	. 
	rst 38h			;7439	ff 	. 
	rst 38h			;743a	ff 	. 
	rst 38h			;743b	ff 	. 
	rst 38h			;743c	ff 	. 
	rst 38h			;743d	ff 	. 
	rst 38h			;743e	ff 	. 
	rst 38h			;743f	ff 	. 
	rst 38h			;7440	ff 	. 
	rst 38h			;7441	ff 	. 
	rst 38h			;7442	ff 	. 
	rst 38h			;7443	ff 	. 
	rst 38h			;7444	ff 	. 
	rst 38h			;7445	ff 	. 
	rst 38h			;7446	ff 	. 
	rst 38h			;7447	ff 	. 
	rst 38h			;7448	ff 	. 
	rst 38h			;7449	ff 	. 
	rst 38h			;744a	ff 	. 
	rst 38h			;744b	ff 	. 
	rst 38h			;744c	ff 	. 
	rst 38h			;744d	ff 	. 
	rst 38h			;744e	ff 	. 
	rst 38h			;744f	ff 	. 
	rst 38h			;7450	ff 	. 
	rst 38h			;7451	ff 	. 
	rst 38h			;7452	ff 	. 
	rst 38h			;7453	ff 	. 
	rst 38h			;7454	ff 	. 
	rst 38h			;7455	ff 	. 
	rst 38h			;7456	ff 	. 
	rst 38h			;7457	ff 	. 
	rst 38h			;7458	ff 	. 
	rst 38h			;7459	ff 	. 
	rst 38h			;745a	ff 	. 
	rst 38h			;745b	ff 	. 
	rst 38h			;745c	ff 	. 
	rst 38h			;745d	ff 	. 
	rst 38h			;745e	ff 	. 
	rst 38h			;745f	ff 	. 
	rst 38h			;7460	ff 	. 
	rst 38h			;7461	ff 	. 
	rst 38h			;7462	ff 	. 
	rst 38h			;7463	ff 	. 
	rst 38h			;7464	ff 	. 
	rst 38h			;7465	ff 	. 
	rst 38h			;7466	ff 	. 
	rst 38h			;7467	ff 	. 
	rst 38h			;7468	ff 	. 
	rst 38h			;7469	ff 	. 
	rst 38h			;746a	ff 	. 
	rst 38h			;746b	ff 	. 
	rst 38h			;746c	ff 	. 
	rst 38h			;746d	ff 	. 
	rst 38h			;746e	ff 	. 
	rst 38h			;746f	ff 	. 
	rst 38h			;7470	ff 	. 
	rst 38h			;7471	ff 	. 
	rst 38h			;7472	ff 	. 
	rst 38h			;7473	ff 	. 
	rst 38h			;7474	ff 	. 
	rst 38h			;7475	ff 	. 
	rst 38h			;7476	ff 	. 
	rst 38h			;7477	ff 	. 
	rst 38h			;7478	ff 	. 
	rst 38h			;7479	ff 	. 
	rst 38h			;747a	ff 	. 
	rst 38h			;747b	ff 	. 
	rst 38h			;747c	ff 	. 
	rst 38h			;747d	ff 	. 
	rst 38h			;747e	ff 	. 
	rst 38h			;747f	ff 	. 
	rst 38h			;7480	ff 	. 
	rst 38h			;7481	ff 	. 
	rst 38h			;7482	ff 	. 
	rst 38h			;7483	ff 	. 
	rst 38h			;7484	ff 	. 
	rst 38h			;7485	ff 	. 
	rst 38h			;7486	ff 	. 
	rst 38h			;7487	ff 	. 
	rst 38h			;7488	ff 	. 
	rst 38h			;7489	ff 	. 
	rst 38h			;748a	ff 	. 
	rst 38h			;748b	ff 	. 
	rst 38h			;748c	ff 	. 
	rst 38h			;748d	ff 	. 
	rst 38h			;748e	ff 	. 
	rst 38h			;748f	ff 	. 
	rst 38h			;7490	ff 	. 
	rst 38h			;7491	ff 	. 
	rst 38h			;7492	ff 	. 
	rst 38h			;7493	ff 	. 
	rst 38h			;7494	ff 	. 
	rst 38h			;7495	ff 	. 
	rst 38h			;7496	ff 	. 
	rst 38h			;7497	ff 	. 
	rst 38h			;7498	ff 	. 
	rst 38h			;7499	ff 	. 
	rst 38h			;749a	ff 	. 
	rst 38h			;749b	ff 	. 
	rst 38h			;749c	ff 	. 
	rst 38h			;749d	ff 	. 
	rst 38h			;749e	ff 	. 
	rst 38h			;749f	ff 	. 
	rst 38h			;74a0	ff 	. 
	rst 38h			;74a1	ff 	. 
	rst 38h			;74a2	ff 	. 
	rst 38h			;74a3	ff 	. 
	rst 38h			;74a4	ff 	. 
	rst 38h			;74a5	ff 	. 
	rst 38h			;74a6	ff 	. 
	rst 38h			;74a7	ff 	. 
	rst 38h			;74a8	ff 	. 
	rst 38h			;74a9	ff 	. 
	rst 38h			;74aa	ff 	. 
	rst 38h			;74ab	ff 	. 
	rst 38h			;74ac	ff 	. 
	rst 38h			;74ad	ff 	. 
	rst 38h			;74ae	ff 	. 
	rst 38h			;74af	ff 	. 
	rst 38h			;74b0	ff 	. 
	rst 38h			;74b1	ff 	. 
	rst 38h			;74b2	ff 	. 
	rst 38h			;74b3	ff 	. 
	rst 38h			;74b4	ff 	. 
	rst 38h			;74b5	ff 	. 
	rst 38h			;74b6	ff 	. 
	rst 38h			;74b7	ff 	. 
	rst 38h			;74b8	ff 	. 
	rst 38h			;74b9	ff 	. 
	rst 38h			;74ba	ff 	. 
	rst 38h			;74bb	ff 	. 
	rst 38h			;74bc	ff 	. 
	rst 38h			;74bd	ff 	. 
	rst 38h			;74be	ff 	. 
	rst 38h			;74bf	ff 	. 
	rst 38h			;74c0	ff 	. 
	rst 38h			;74c1	ff 	. 
	rst 38h			;74c2	ff 	. 
	rst 38h			;74c3	ff 	. 
	rst 38h			;74c4	ff 	. 
	rst 38h			;74c5	ff 	. 
	rst 38h			;74c6	ff 	. 
	rst 38h			;74c7	ff 	. 
	rst 38h			;74c8	ff 	. 
	rst 38h			;74c9	ff 	. 
	rst 38h			;74ca	ff 	. 
	rst 38h			;74cb	ff 	. 
	rst 38h			;74cc	ff 	. 
	rst 38h			;74cd	ff 	. 
	rst 38h			;74ce	ff 	. 
	rst 38h			;74cf	ff 	. 
	rst 38h			;74d0	ff 	. 
	rst 38h			;74d1	ff 	. 
	rst 38h			;74d2	ff 	. 
	rst 38h			;74d3	ff 	. 
	rst 38h			;74d4	ff 	. 
	rst 38h			;74d5	ff 	. 
	rst 38h			;74d6	ff 	. 
	rst 38h			;74d7	ff 	. 
	rst 38h			;74d8	ff 	. 
	rst 38h			;74d9	ff 	. 
	rst 38h			;74da	ff 	. 
	rst 38h			;74db	ff 	. 
	rst 38h			;74dc	ff 	. 
	rst 38h			;74dd	ff 	. 
	rst 38h			;74de	ff 	. 
	rst 38h			;74df	ff 	. 
	rst 38h			;74e0	ff 	. 
	rst 38h			;74e1	ff 	. 
	rst 38h			;74e2	ff 	. 
	rst 38h			;74e3	ff 	. 
	rst 38h			;74e4	ff 	. 
	rst 38h			;74e5	ff 	. 
	rst 38h			;74e6	ff 	. 
	rst 38h			;74e7	ff 	. 
	rst 38h			;74e8	ff 	. 
	rst 38h			;74e9	ff 	. 
	rst 38h			;74ea	ff 	. 
	rst 38h			;74eb	ff 	. 
	rst 38h			;74ec	ff 	. 
	rst 38h			;74ed	ff 	. 
	rst 38h			;74ee	ff 	. 
	rst 38h			;74ef	ff 	. 
	rst 38h			;74f0	ff 	. 
	rst 38h			;74f1	ff 	. 
	rst 38h			;74f2	ff 	. 
	rst 38h			;74f3	ff 	. 
	rst 38h			;74f4	ff 	. 
	rst 38h			;74f5	ff 	. 
	rst 38h			;74f6	ff 	. 
	rst 38h			;74f7	ff 	. 
	rst 38h			;74f8	ff 	. 
	rst 38h			;74f9	ff 	. 
	rst 38h			;74fa	ff 	. 
	rst 38h			;74fb	ff 	. 
	rst 38h			;74fc	ff 	. 
	rst 38h			;74fd	ff 	. 
	rst 38h			;74fe	ff 	. 
	rst 38h			;74ff	ff 	. 
	rst 38h			;7500	ff 	. 
	rst 38h			;7501	ff 	. 
	rst 38h			;7502	ff 	. 
	rst 38h			;7503	ff 	. 
	rst 38h			;7504	ff 	. 
	rst 38h			;7505	ff 	. 
	rst 38h			;7506	ff 	. 
	rst 38h			;7507	ff 	. 
	rst 38h			;7508	ff 	. 
	rst 38h			;7509	ff 	. 
	rst 38h			;750a	ff 	. 
	rst 38h			;750b	ff 	. 
	rst 38h			;750c	ff 	. 
	rst 38h			;750d	ff 	. 
	rst 38h			;750e	ff 	. 
	rst 38h			;750f	ff 	. 
	rst 38h			;7510	ff 	. 
	rst 38h			;7511	ff 	. 
	rst 38h			;7512	ff 	. 
	rst 38h			;7513	ff 	. 
	rst 38h			;7514	ff 	. 
	rst 38h			;7515	ff 	. 
	rst 38h			;7516	ff 	. 
	rst 38h			;7517	ff 	. 
	rst 38h			;7518	ff 	. 
	rst 38h			;7519	ff 	. 
	rst 38h			;751a	ff 	. 
	rst 38h			;751b	ff 	. 
	rst 38h			;751c	ff 	. 
	rst 38h			;751d	ff 	. 
	rst 38h			;751e	ff 	. 
	rst 38h			;751f	ff 	. 
	rst 38h			;7520	ff 	. 
	rst 38h			;7521	ff 	. 
	rst 38h			;7522	ff 	. 
	rst 38h			;7523	ff 	. 
	rst 38h			;7524	ff 	. 
	rst 38h			;7525	ff 	. 
	rst 38h			;7526	ff 	. 
	rst 38h			;7527	ff 	. 
	rst 38h			;7528	ff 	. 
	rst 38h			;7529	ff 	. 
	rst 38h			;752a	ff 	. 
	rst 38h			;752b	ff 	. 
	rst 38h			;752c	ff 	. 
	rst 38h			;752d	ff 	. 
	rst 38h			;752e	ff 	. 
	rst 38h			;752f	ff 	. 
	rst 38h			;7530	ff 	. 
	rst 38h			;7531	ff 	. 
	rst 38h			;7532	ff 	. 
	rst 38h			;7533	ff 	. 
	rst 38h			;7534	ff 	. 
	rst 38h			;7535	ff 	. 
	rst 38h			;7536	ff 	. 
	rst 38h			;7537	ff 	. 
	rst 38h			;7538	ff 	. 
	rst 38h			;7539	ff 	. 
	rst 38h			;753a	ff 	. 
	rst 38h			;753b	ff 	. 
	rst 38h			;753c	ff 	. 
	rst 38h			;753d	ff 	. 
	rst 38h			;753e	ff 	. 
	rst 38h			;753f	ff 	. 
	rst 38h			;7540	ff 	. 
	rst 38h			;7541	ff 	. 
	rst 38h			;7542	ff 	. 
	rst 38h			;7543	ff 	. 
	rst 38h			;7544	ff 	. 
	rst 38h			;7545	ff 	. 
	rst 38h			;7546	ff 	. 
	rst 38h			;7547	ff 	. 
	rst 38h			;7548	ff 	. 
	rst 38h			;7549	ff 	. 
	rst 38h			;754a	ff 	. 
	rst 38h			;754b	ff 	. 
	rst 38h			;754c	ff 	. 
	rst 38h			;754d	ff 	. 
	rst 38h			;754e	ff 	. 
	rst 38h			;754f	ff 	. 
	rst 38h			;7550	ff 	. 
	rst 38h			;7551	ff 	. 
	rst 38h			;7552	ff 	. 
	rst 38h			;7553	ff 	. 
	rst 38h			;7554	ff 	. 
	rst 38h			;7555	ff 	. 
	rst 38h			;7556	ff 	. 
	rst 38h			;7557	ff 	. 
	rst 38h			;7558	ff 	. 
	rst 38h			;7559	ff 	. 
	rst 38h			;755a	ff 	. 
	rst 38h			;755b	ff 	. 
	rst 38h			;755c	ff 	. 
	rst 38h			;755d	ff 	. 
	rst 38h			;755e	ff 	. 
	rst 38h			;755f	ff 	. 
	rst 38h			;7560	ff 	. 
	rst 38h			;7561	ff 	. 
	rst 38h			;7562	ff 	. 
	rst 38h			;7563	ff 	. 
	rst 38h			;7564	ff 	. 
	rst 38h			;7565	ff 	. 
	rst 38h			;7566	ff 	. 
	rst 38h			;7567	ff 	. 
	rst 38h			;7568	ff 	. 
	rst 38h			;7569	ff 	. 
	rst 38h			;756a	ff 	. 
	rst 38h			;756b	ff 	. 
	rst 38h			;756c	ff 	. 
	rst 38h			;756d	ff 	. 
	rst 38h			;756e	ff 	. 
	rst 38h			;756f	ff 	. 
	rst 38h			;7570	ff 	. 
	rst 38h			;7571	ff 	. 
	rst 38h			;7572	ff 	. 
	rst 38h			;7573	ff 	. 
	rst 38h			;7574	ff 	. 
	rst 38h			;7575	ff 	. 
	rst 38h			;7576	ff 	. 
	rst 38h			;7577	ff 	. 
	rst 38h			;7578	ff 	. 
	rst 38h			;7579	ff 	. 
	rst 38h			;757a	ff 	. 
	rst 38h			;757b	ff 	. 
	rst 38h			;757c	ff 	. 
	rst 38h			;757d	ff 	. 
	rst 38h			;757e	ff 	. 
	rst 38h			;757f	ff 	. 
	rst 38h			;7580	ff 	. 
	rst 38h			;7581	ff 	. 
	rst 38h			;7582	ff 	. 
	rst 38h			;7583	ff 	. 
	rst 38h			;7584	ff 	. 
	rst 38h			;7585	ff 	. 
	rst 38h			;7586	ff 	. 
	rst 38h			;7587	ff 	. 
	rst 38h			;7588	ff 	. 
	rst 38h			;7589	ff 	. 
	rst 38h			;758a	ff 	. 
	rst 38h			;758b	ff 	. 
	rst 38h			;758c	ff 	. 
	rst 38h			;758d	ff 	. 
	rst 38h			;758e	ff 	. 
	rst 38h			;758f	ff 	. 
	rst 38h			;7590	ff 	. 
	rst 38h			;7591	ff 	. 
	rst 38h			;7592	ff 	. 
	rst 38h			;7593	ff 	. 
	rst 38h			;7594	ff 	. 
	rst 38h			;7595	ff 	. 
	rst 38h			;7596	ff 	. 
	rst 38h			;7597	ff 	. 
	rst 38h			;7598	ff 	. 
	rst 38h			;7599	ff 	. 
	rst 38h			;759a	ff 	. 
	rst 38h			;759b	ff 	. 
	rst 38h			;759c	ff 	. 
	rst 38h			;759d	ff 	. 
	rst 38h			;759e	ff 	. 
	rst 38h			;759f	ff 	. 
	rst 38h			;75a0	ff 	. 
	rst 38h			;75a1	ff 	. 
	rst 38h			;75a2	ff 	. 
	rst 38h			;75a3	ff 	. 
	rst 38h			;75a4	ff 	. 
	rst 38h			;75a5	ff 	. 
	rst 38h			;75a6	ff 	. 
	rst 38h			;75a7	ff 	. 
	rst 38h			;75a8	ff 	. 
	rst 38h			;75a9	ff 	. 
	rst 38h			;75aa	ff 	. 
	rst 38h			;75ab	ff 	. 
	rst 38h			;75ac	ff 	. 
	rst 38h			;75ad	ff 	. 
	rst 38h			;75ae	ff 	. 
	rst 38h			;75af	ff 	. 
	rst 38h			;75b0	ff 	. 
	rst 38h			;75b1	ff 	. 
	rst 38h			;75b2	ff 	. 
	rst 38h			;75b3	ff 	. 
	rst 38h			;75b4	ff 	. 
	rst 38h			;75b5	ff 	. 
	rst 38h			;75b6	ff 	. 
	rst 38h			;75b7	ff 	. 
	rst 38h			;75b8	ff 	. 
	rst 38h			;75b9	ff 	. 
	rst 38h			;75ba	ff 	. 
	rst 38h			;75bb	ff 	. 
	rst 38h			;75bc	ff 	. 
	rst 38h			;75bd	ff 	. 
	rst 38h			;75be	ff 	. 
	rst 38h			;75bf	ff 	. 
	rst 38h			;75c0	ff 	. 
	rst 38h			;75c1	ff 	. 
	rst 38h			;75c2	ff 	. 
	rst 38h			;75c3	ff 	. 
	rst 38h			;75c4	ff 	. 
	rst 38h			;75c5	ff 	. 
	rst 38h			;75c6	ff 	. 
	rst 38h			;75c7	ff 	. 
	rst 38h			;75c8	ff 	. 
	rst 38h			;75c9	ff 	. 
	rst 38h			;75ca	ff 	. 
	rst 38h			;75cb	ff 	. 
	rst 38h			;75cc	ff 	. 
	rst 38h			;75cd	ff 	. 
	rst 38h			;75ce	ff 	. 
	rst 38h			;75cf	ff 	. 
	rst 38h			;75d0	ff 	. 
	rst 38h			;75d1	ff 	. 
	rst 38h			;75d2	ff 	. 
	rst 38h			;75d3	ff 	. 
	rst 38h			;75d4	ff 	. 
	rst 38h			;75d5	ff 	. 
	rst 38h			;75d6	ff 	. 
	rst 38h			;75d7	ff 	. 
	rst 38h			;75d8	ff 	. 
	rst 38h			;75d9	ff 	. 
	rst 38h			;75da	ff 	. 
	rst 38h			;75db	ff 	. 
	rst 38h			;75dc	ff 	. 
	rst 38h			;75dd	ff 	. 
	rst 38h			;75de	ff 	. 
	rst 38h			;75df	ff 	. 
	rst 38h			;75e0	ff 	. 
	rst 38h			;75e1	ff 	. 
	rst 38h			;75e2	ff 	. 
	rst 38h			;75e3	ff 	. 
	rst 38h			;75e4	ff 	. 
	rst 38h			;75e5	ff 	. 
	rst 38h			;75e6	ff 	. 
	rst 38h			;75e7	ff 	. 
	rst 38h			;75e8	ff 	. 
	rst 38h			;75e9	ff 	. 
	rst 38h			;75ea	ff 	. 
	rst 38h			;75eb	ff 	. 
	rst 38h			;75ec	ff 	. 
	rst 38h			;75ed	ff 	. 
	rst 38h			;75ee	ff 	. 
	rst 38h			;75ef	ff 	. 
	rst 38h			;75f0	ff 	. 
	rst 38h			;75f1	ff 	. 
	rst 38h			;75f2	ff 	. 
	rst 38h			;75f3	ff 	. 
	rst 38h			;75f4	ff 	. 
	rst 38h			;75f5	ff 	. 
	rst 38h			;75f6	ff 	. 
	rst 38h			;75f7	ff 	. 
	rst 38h			;75f8	ff 	. 
	rst 38h			;75f9	ff 	. 
	rst 38h			;75fa	ff 	. 
	rst 38h			;75fb	ff 	. 
	rst 38h			;75fc	ff 	. 
	rst 38h			;75fd	ff 	. 
	rst 38h			;75fe	ff 	. 
	rst 38h			;75ff	ff 	. 
	rst 38h			;7600	ff 	. 
	rst 38h			;7601	ff 	. 
	rst 38h			;7602	ff 	. 
	rst 38h			;7603	ff 	. 
	rst 38h			;7604	ff 	. 
	rst 38h			;7605	ff 	. 
	rst 38h			;7606	ff 	. 
	rst 38h			;7607	ff 	. 
	rst 38h			;7608	ff 	. 
	rst 38h			;7609	ff 	. 
	rst 38h			;760a	ff 	. 
	rst 38h			;760b	ff 	. 
	rst 38h			;760c	ff 	. 
	rst 38h			;760d	ff 	. 
	rst 38h			;760e	ff 	. 
	rst 38h			;760f	ff 	. 
	rst 38h			;7610	ff 	. 
	rst 38h			;7611	ff 	. 
	rst 38h			;7612	ff 	. 
	rst 38h			;7613	ff 	. 
	rst 38h			;7614	ff 	. 
	rst 38h			;7615	ff 	. 
	rst 38h			;7616	ff 	. 
	rst 38h			;7617	ff 	. 
	rst 38h			;7618	ff 	. 
	rst 38h			;7619	ff 	. 
	rst 38h			;761a	ff 	. 
	rst 38h			;761b	ff 	. 
	rst 38h			;761c	ff 	. 
	rst 38h			;761d	ff 	. 
	rst 38h			;761e	ff 	. 
	rst 38h			;761f	ff 	. 
	rst 38h			;7620	ff 	. 
	rst 38h			;7621	ff 	. 
	rst 38h			;7622	ff 	. 
	rst 38h			;7623	ff 	. 
	rst 38h			;7624	ff 	. 
	rst 38h			;7625	ff 	. 
	rst 38h			;7626	ff 	. 
	rst 38h			;7627	ff 	. 
	rst 38h			;7628	ff 	. 
	rst 38h			;7629	ff 	. 
	rst 38h			;762a	ff 	. 
	rst 38h			;762b	ff 	. 
	rst 38h			;762c	ff 	. 
	rst 38h			;762d	ff 	. 
	rst 38h			;762e	ff 	. 
	rst 38h			;762f	ff 	. 
	rst 38h			;7630	ff 	. 
	rst 38h			;7631	ff 	. 
	rst 38h			;7632	ff 	. 
	rst 38h			;7633	ff 	. 
	rst 38h			;7634	ff 	. 
	rst 38h			;7635	ff 	. 
	rst 38h			;7636	ff 	. 
	rst 38h			;7637	ff 	. 
	rst 38h			;7638	ff 	. 
	rst 38h			;7639	ff 	. 
	rst 38h			;763a	ff 	. 
	rst 38h			;763b	ff 	. 
	rst 38h			;763c	ff 	. 
	rst 38h			;763d	ff 	. 
	rst 38h			;763e	ff 	. 
	rst 38h			;763f	ff 	. 
	rst 38h			;7640	ff 	. 
	rst 38h			;7641	ff 	. 
	rst 38h			;7642	ff 	. 
	rst 38h			;7643	ff 	. 
	rst 38h			;7644	ff 	. 
	rst 38h			;7645	ff 	. 
	rst 38h			;7646	ff 	. 
	rst 38h			;7647	ff 	. 
	rst 38h			;7648	ff 	. 
	rst 38h			;7649	ff 	. 
	rst 38h			;764a	ff 	. 
	rst 38h			;764b	ff 	. 
	rst 38h			;764c	ff 	. 
	rst 38h			;764d	ff 	. 
	rst 38h			;764e	ff 	. 
	rst 38h			;764f	ff 	. 
	rst 38h			;7650	ff 	. 
	rst 38h			;7651	ff 	. 
	rst 38h			;7652	ff 	. 
	rst 38h			;7653	ff 	. 
	rst 38h			;7654	ff 	. 
	rst 38h			;7655	ff 	. 
	rst 38h			;7656	ff 	. 
	rst 38h			;7657	ff 	. 
	rst 38h			;7658	ff 	. 
	rst 38h			;7659	ff 	. 
	rst 38h			;765a	ff 	. 
	rst 38h			;765b	ff 	. 
	rst 38h			;765c	ff 	. 
	rst 38h			;765d	ff 	. 
	rst 38h			;765e	ff 	. 
	rst 38h			;765f	ff 	. 
	rst 38h			;7660	ff 	. 
	rst 38h			;7661	ff 	. 
	rst 38h			;7662	ff 	. 
	rst 38h			;7663	ff 	. 
	rst 38h			;7664	ff 	. 
	rst 38h			;7665	ff 	. 
	rst 38h			;7666	ff 	. 
	rst 38h			;7667	ff 	. 
	rst 38h			;7668	ff 	. 
	rst 38h			;7669	ff 	. 
	rst 38h			;766a	ff 	. 
	rst 38h			;766b	ff 	. 
	rst 38h			;766c	ff 	. 
	rst 38h			;766d	ff 	. 
	rst 38h			;766e	ff 	. 
	rst 38h			;766f	ff 	. 
	rst 38h			;7670	ff 	. 
	rst 38h			;7671	ff 	. 
	rst 38h			;7672	ff 	. 
	rst 38h			;7673	ff 	. 
	rst 38h			;7674	ff 	. 
	rst 38h			;7675	ff 	. 
	rst 38h			;7676	ff 	. 
	rst 38h			;7677	ff 	. 
	rst 38h			;7678	ff 	. 
	rst 38h			;7679	ff 	. 
	rst 38h			;767a	ff 	. 
	rst 38h			;767b	ff 	. 
	rst 38h			;767c	ff 	. 
	rst 38h			;767d	ff 	. 
	rst 38h			;767e	ff 	. 
	rst 38h			;767f	ff 	. 
	rst 38h			;7680	ff 	. 
	rst 38h			;7681	ff 	. 
	rst 38h			;7682	ff 	. 
	rst 38h			;7683	ff 	. 
	rst 38h			;7684	ff 	. 
	rst 38h			;7685	ff 	. 
	rst 38h			;7686	ff 	. 
	rst 38h			;7687	ff 	. 
	rst 38h			;7688	ff 	. 
	rst 38h			;7689	ff 	. 
	rst 38h			;768a	ff 	. 
	rst 38h			;768b	ff 	. 
	rst 38h			;768c	ff 	. 
	rst 38h			;768d	ff 	. 
	rst 38h			;768e	ff 	. 
	rst 38h			;768f	ff 	. 
	rst 38h			;7690	ff 	. 
	rst 38h			;7691	ff 	. 
	rst 38h			;7692	ff 	. 
	rst 38h			;7693	ff 	. 
	rst 38h			;7694	ff 	. 
	rst 38h			;7695	ff 	. 
	rst 38h			;7696	ff 	. 
	rst 38h			;7697	ff 	. 
	rst 38h			;7698	ff 	. 
	rst 38h			;7699	ff 	. 
	rst 38h			;769a	ff 	. 
	rst 38h			;769b	ff 	. 
	rst 38h			;769c	ff 	. 
	rst 38h			;769d	ff 	. 
	rst 38h			;769e	ff 	. 
	rst 38h			;769f	ff 	. 
	rst 38h			;76a0	ff 	. 
	rst 38h			;76a1	ff 	. 
	rst 38h			;76a2	ff 	. 
	rst 38h			;76a3	ff 	. 
	rst 38h			;76a4	ff 	. 
	rst 38h			;76a5	ff 	. 
	rst 38h			;76a6	ff 	. 
	rst 38h			;76a7	ff 	. 
	rst 38h			;76a8	ff 	. 
	rst 38h			;76a9	ff 	. 
	rst 38h			;76aa	ff 	. 
	rst 38h			;76ab	ff 	. 
	rst 38h			;76ac	ff 	. 
	rst 38h			;76ad	ff 	. 
	rst 38h			;76ae	ff 	. 
	rst 38h			;76af	ff 	. 
	rst 38h			;76b0	ff 	. 
	rst 38h			;76b1	ff 	. 
	rst 38h			;76b2	ff 	. 
	rst 38h			;76b3	ff 	. 
	rst 38h			;76b4	ff 	. 
	rst 38h			;76b5	ff 	. 
	rst 38h			;76b6	ff 	. 
	rst 38h			;76b7	ff 	. 
	rst 38h			;76b8	ff 	. 
	rst 38h			;76b9	ff 	. 
	rst 38h			;76ba	ff 	. 
	rst 38h			;76bb	ff 	. 
	rst 38h			;76bc	ff 	. 
	rst 38h			;76bd	ff 	. 
	rst 38h			;76be	ff 	. 
	rst 38h			;76bf	ff 	. 
	rst 38h			;76c0	ff 	. 
	rst 38h			;76c1	ff 	. 
	rst 38h			;76c2	ff 	. 
	rst 38h			;76c3	ff 	. 
	rst 38h			;76c4	ff 	. 
	rst 38h			;76c5	ff 	. 
	rst 38h			;76c6	ff 	. 
	rst 38h			;76c7	ff 	. 
	rst 38h			;76c8	ff 	. 
	rst 38h			;76c9	ff 	. 
	rst 38h			;76ca	ff 	. 
	rst 38h			;76cb	ff 	. 
	rst 38h			;76cc	ff 	. 
	rst 38h			;76cd	ff 	. 
	rst 38h			;76ce	ff 	. 
	rst 38h			;76cf	ff 	. 
	rst 38h			;76d0	ff 	. 
	rst 38h			;76d1	ff 	. 
	rst 38h			;76d2	ff 	. 
	rst 38h			;76d3	ff 	. 
	rst 38h			;76d4	ff 	. 
	rst 38h			;76d5	ff 	. 
	rst 38h			;76d6	ff 	. 
	rst 38h			;76d7	ff 	. 
	rst 38h			;76d8	ff 	. 
	rst 38h			;76d9	ff 	. 
	rst 38h			;76da	ff 	. 
	rst 38h			;76db	ff 	. 
	rst 38h			;76dc	ff 	. 
	rst 38h			;76dd	ff 	. 
	rst 38h			;76de	ff 	. 
	rst 38h			;76df	ff 	. 
	rst 38h			;76e0	ff 	. 
	rst 38h			;76e1	ff 	. 
	rst 38h			;76e2	ff 	. 
	rst 38h			;76e3	ff 	. 
	rst 38h			;76e4	ff 	. 
	rst 38h			;76e5	ff 	. 
	rst 38h			;76e6	ff 	. 
	rst 38h			;76e7	ff 	. 
	rst 38h			;76e8	ff 	. 
	rst 38h			;76e9	ff 	. 
	rst 38h			;76ea	ff 	. 
	rst 38h			;76eb	ff 	. 
	rst 38h			;76ec	ff 	. 
	rst 38h			;76ed	ff 	. 
	rst 38h			;76ee	ff 	. 
	rst 38h			;76ef	ff 	. 
	rst 38h			;76f0	ff 	. 
	rst 38h			;76f1	ff 	. 
	rst 38h			;76f2	ff 	. 
	rst 38h			;76f3	ff 	. 
	rst 38h			;76f4	ff 	. 
	rst 38h			;76f5	ff 	. 
	rst 38h			;76f6	ff 	. 
	rst 38h			;76f7	ff 	. 
	rst 38h			;76f8	ff 	. 
	rst 38h			;76f9	ff 	. 
	rst 38h			;76fa	ff 	. 
	rst 38h			;76fb	ff 	. 
	rst 38h			;76fc	ff 	. 
	rst 38h			;76fd	ff 	. 
	rst 38h			;76fe	ff 	. 
	rst 38h			;76ff	ff 	. 
	rst 38h			;7700	ff 	. 
	rst 38h			;7701	ff 	. 
	rst 38h			;7702	ff 	. 
	rst 38h			;7703	ff 	. 
	rst 38h			;7704	ff 	. 
	rst 38h			;7705	ff 	. 
	rst 38h			;7706	ff 	. 
	rst 38h			;7707	ff 	. 
	rst 38h			;7708	ff 	. 
	rst 38h			;7709	ff 	. 
	rst 38h			;770a	ff 	. 
	rst 38h			;770b	ff 	. 
	rst 38h			;770c	ff 	. 
	rst 38h			;770d	ff 	. 
	rst 38h			;770e	ff 	. 
	rst 38h			;770f	ff 	. 
	rst 38h			;7710	ff 	. 
	rst 38h			;7711	ff 	. 
	rst 38h			;7712	ff 	. 
	rst 38h			;7713	ff 	. 
	rst 38h			;7714	ff 	. 
	rst 38h			;7715	ff 	. 
	rst 38h			;7716	ff 	. 
	rst 38h			;7717	ff 	. 
	rst 38h			;7718	ff 	. 
	rst 38h			;7719	ff 	. 
	rst 38h			;771a	ff 	. 
	rst 38h			;771b	ff 	. 
	rst 38h			;771c	ff 	. 
	rst 38h			;771d	ff 	. 
	rst 38h			;771e	ff 	. 
	rst 38h			;771f	ff 	. 
	rst 38h			;7720	ff 	. 
	rst 38h			;7721	ff 	. 
	rst 38h			;7722	ff 	. 
	rst 38h			;7723	ff 	. 
	rst 38h			;7724	ff 	. 
	rst 38h			;7725	ff 	. 
	rst 38h			;7726	ff 	. 
	rst 38h			;7727	ff 	. 
	rst 38h			;7728	ff 	. 
	rst 38h			;7729	ff 	. 
	rst 38h			;772a	ff 	. 
	rst 38h			;772b	ff 	. 
	rst 38h			;772c	ff 	. 
	rst 38h			;772d	ff 	. 
	rst 38h			;772e	ff 	. 
	rst 38h			;772f	ff 	. 
	rst 38h			;7730	ff 	. 
	rst 38h			;7731	ff 	. 
	rst 38h			;7732	ff 	. 
	rst 38h			;7733	ff 	. 
	rst 38h			;7734	ff 	. 
	rst 38h			;7735	ff 	. 
	rst 38h			;7736	ff 	. 
	rst 38h			;7737	ff 	. 
	rst 38h			;7738	ff 	. 
	rst 38h			;7739	ff 	. 
	rst 38h			;773a	ff 	. 
	rst 38h			;773b	ff 	. 
	rst 38h			;773c	ff 	. 
	rst 38h			;773d	ff 	. 
	rst 38h			;773e	ff 	. 
	rst 38h			;773f	ff 	. 
	rst 38h			;7740	ff 	. 
	rst 38h			;7741	ff 	. 
	rst 38h			;7742	ff 	. 
	rst 38h			;7743	ff 	. 
	rst 38h			;7744	ff 	. 
	rst 38h			;7745	ff 	. 
	rst 38h			;7746	ff 	. 
	rst 38h			;7747	ff 	. 
	rst 38h			;7748	ff 	. 
	rst 38h			;7749	ff 	. 
	rst 38h			;774a	ff 	. 
	rst 38h			;774b	ff 	. 
	rst 38h			;774c	ff 	. 
	rst 38h			;774d	ff 	. 
	rst 38h			;774e	ff 	. 
	rst 38h			;774f	ff 	. 
	rst 38h			;7750	ff 	. 
	rst 38h			;7751	ff 	. 
	rst 38h			;7752	ff 	. 
	rst 38h			;7753	ff 	. 
	rst 38h			;7754	ff 	. 
	rst 38h			;7755	ff 	. 
	rst 38h			;7756	ff 	. 
	rst 38h			;7757	ff 	. 
	rst 38h			;7758	ff 	. 
	rst 38h			;7759	ff 	. 
	rst 38h			;775a	ff 	. 
	rst 38h			;775b	ff 	. 
	rst 38h			;775c	ff 	. 
	rst 38h			;775d	ff 	. 
	rst 38h			;775e	ff 	. 
	rst 38h			;775f	ff 	. 
	rst 38h			;7760	ff 	. 
	rst 38h			;7761	ff 	. 
	rst 38h			;7762	ff 	. 
	rst 38h			;7763	ff 	. 
	rst 38h			;7764	ff 	. 
	rst 38h			;7765	ff 	. 
	rst 38h			;7766	ff 	. 
	rst 38h			;7767	ff 	. 
	rst 38h			;7768	ff 	. 
	rst 38h			;7769	ff 	. 
	rst 38h			;776a	ff 	. 
	rst 38h			;776b	ff 	. 
	rst 38h			;776c	ff 	. 
	rst 38h			;776d	ff 	. 
	rst 38h			;776e	ff 	. 
	rst 38h			;776f	ff 	. 
	rst 38h			;7770	ff 	. 
	rst 38h			;7771	ff 	. 
	rst 38h			;7772	ff 	. 
	rst 38h			;7773	ff 	. 
	rst 38h			;7774	ff 	. 
	rst 38h			;7775	ff 	. 
	rst 38h			;7776	ff 	. 
	rst 38h			;7777	ff 	. 
	rst 38h			;7778	ff 	. 
	rst 38h			;7779	ff 	. 
	rst 38h			;777a	ff 	. 
	rst 38h			;777b	ff 	. 
	rst 38h			;777c	ff 	. 
	rst 38h			;777d	ff 	. 
	rst 38h			;777e	ff 	. 
	rst 38h			;777f	ff 	. 
	rst 38h			;7780	ff 	. 
	rst 38h			;7781	ff 	. 
	rst 38h			;7782	ff 	. 
	rst 38h			;7783	ff 	. 
	rst 38h			;7784	ff 	. 
	rst 38h			;7785	ff 	. 
	rst 38h			;7786	ff 	. 
	rst 38h			;7787	ff 	. 
	rst 38h			;7788	ff 	. 
	rst 38h			;7789	ff 	. 
	rst 38h			;778a	ff 	. 
	rst 38h			;778b	ff 	. 
	rst 38h			;778c	ff 	. 
	rst 38h			;778d	ff 	. 
	rst 38h			;778e	ff 	. 
	rst 38h			;778f	ff 	. 
	rst 38h			;7790	ff 	. 
	rst 38h			;7791	ff 	. 
	rst 38h			;7792	ff 	. 
	rst 38h			;7793	ff 	. 
	rst 38h			;7794	ff 	. 
	rst 38h			;7795	ff 	. 
	rst 38h			;7796	ff 	. 
	rst 38h			;7797	ff 	. 
	rst 38h			;7798	ff 	. 
	rst 38h			;7799	ff 	. 
	rst 38h			;779a	ff 	. 
	rst 38h			;779b	ff 	. 
	rst 38h			;779c	ff 	. 
	rst 38h			;779d	ff 	. 
	rst 38h			;779e	ff 	. 
	rst 38h			;779f	ff 	. 
	rst 38h			;77a0	ff 	. 
	rst 38h			;77a1	ff 	. 
	rst 38h			;77a2	ff 	. 
	rst 38h			;77a3	ff 	. 
	rst 38h			;77a4	ff 	. 
	rst 38h			;77a5	ff 	. 
	rst 38h			;77a6	ff 	. 
	rst 38h			;77a7	ff 	. 
	rst 38h			;77a8	ff 	. 
	rst 38h			;77a9	ff 	. 
	rst 38h			;77aa	ff 	. 
	rst 38h			;77ab	ff 	. 
	rst 38h			;77ac	ff 	. 
	rst 38h			;77ad	ff 	. 
	rst 38h			;77ae	ff 	. 
	rst 38h			;77af	ff 	. 
	rst 38h			;77b0	ff 	. 
	rst 38h			;77b1	ff 	. 
	rst 38h			;77b2	ff 	. 
	rst 38h			;77b3	ff 	. 
	rst 38h			;77b4	ff 	. 
	rst 38h			;77b5	ff 	. 
	rst 38h			;77b6	ff 	. 
	rst 38h			;77b7	ff 	. 
	rst 38h			;77b8	ff 	. 
	rst 38h			;77b9	ff 	. 
	rst 38h			;77ba	ff 	. 
	rst 38h			;77bb	ff 	. 
	rst 38h			;77bc	ff 	. 
	rst 38h			;77bd	ff 	. 
	rst 38h			;77be	ff 	. 
	rst 38h			;77bf	ff 	. 
	rst 38h			;77c0	ff 	. 
	rst 38h			;77c1	ff 	. 
	rst 38h			;77c2	ff 	. 
	rst 38h			;77c3	ff 	. 
	rst 38h			;77c4	ff 	. 
	rst 38h			;77c5	ff 	. 
	rst 38h			;77c6	ff 	. 
	rst 38h			;77c7	ff 	. 
	rst 38h			;77c8	ff 	. 
	rst 38h			;77c9	ff 	. 
	rst 38h			;77ca	ff 	. 
	rst 38h			;77cb	ff 	. 
	rst 38h			;77cc	ff 	. 
	rst 38h			;77cd	ff 	. 
	rst 38h			;77ce	ff 	. 
	rst 38h			;77cf	ff 	. 
	rst 38h			;77d0	ff 	. 
	rst 38h			;77d1	ff 	. 
	rst 38h			;77d2	ff 	. 
	rst 38h			;77d3	ff 	. 
	rst 38h			;77d4	ff 	. 
	rst 38h			;77d5	ff 	. 
	rst 38h			;77d6	ff 	. 
	rst 38h			;77d7	ff 	. 
	rst 38h			;77d8	ff 	. 
	rst 38h			;77d9	ff 	. 
	rst 38h			;77da	ff 	. 
	rst 38h			;77db	ff 	. 
	rst 38h			;77dc	ff 	. 
	rst 38h			;77dd	ff 	. 
	rst 38h			;77de	ff 	. 
	rst 38h			;77df	ff 	. 
	rst 38h			;77e0	ff 	. 
	rst 38h			;77e1	ff 	. 
	rst 38h			;77e2	ff 	. 
	rst 38h			;77e3	ff 	. 
	rst 38h			;77e4	ff 	. 
	rst 38h			;77e5	ff 	. 
	rst 38h			;77e6	ff 	. 
	rst 38h			;77e7	ff 	. 
	rst 38h			;77e8	ff 	. 
	rst 38h			;77e9	ff 	. 
	rst 38h			;77ea	ff 	. 
	rst 38h			;77eb	ff 	. 
	rst 38h			;77ec	ff 	. 
	rst 38h			;77ed	ff 	. 
	rst 38h			;77ee	ff 	. 
	rst 38h			;77ef	ff 	. 
	rst 38h			;77f0	ff 	. 
	rst 38h			;77f1	ff 	. 
	rst 38h			;77f2	ff 	. 
	rst 38h			;77f3	ff 	. 
	rst 38h			;77f4	ff 	. 
	rst 38h			;77f5	ff 	. 
	rst 38h			;77f6	ff 	. 
	rst 38h			;77f7	ff 	. 
	rst 38h			;77f8	ff 	. 
	rst 38h			;77f9	ff 	. 
	rst 38h			;77fa	ff 	. 
	rst 38h			;77fb	ff 	. 
	rst 38h			;77fc	ff 	. 
	rst 38h			;77fd	ff 	. 
	rst 38h			;77fe	ff 	. 
	rst 38h			;77ff	ff 	. 
	rst 38h			;7800	ff 	. 
	rst 38h			;7801	ff 	. 
	rst 38h			;7802	ff 	. 
	rst 38h			;7803	ff 	. 
	rst 38h			;7804	ff 	. 
	rst 38h			;7805	ff 	. 
	rst 38h			;7806	ff 	. 
	rst 38h			;7807	ff 	. 
	rst 38h			;7808	ff 	. 
	rst 38h			;7809	ff 	. 
	rst 38h			;780a	ff 	. 
	rst 38h			;780b	ff 	. 
	rst 38h			;780c	ff 	. 
	rst 38h			;780d	ff 	. 
	rst 38h			;780e	ff 	. 
	rst 38h			;780f	ff 	. 
	rst 38h			;7810	ff 	. 
	rst 38h			;7811	ff 	. 
	rst 38h			;7812	ff 	. 
	rst 38h			;7813	ff 	. 
	rst 38h			;7814	ff 	. 
	rst 38h			;7815	ff 	. 
	rst 38h			;7816	ff 	. 
	rst 38h			;7817	ff 	. 
	rst 38h			;7818	ff 	. 
	rst 38h			;7819	ff 	. 
	rst 38h			;781a	ff 	. 
	rst 38h			;781b	ff 	. 
	rst 38h			;781c	ff 	. 
	rst 38h			;781d	ff 	. 
	rst 38h			;781e	ff 	. 
	rst 38h			;781f	ff 	. 
	rst 38h			;7820	ff 	. 
	rst 38h			;7821	ff 	. 
	rst 38h			;7822	ff 	. 
	rst 38h			;7823	ff 	. 
	rst 38h			;7824	ff 	. 
	rst 38h			;7825	ff 	. 
	rst 38h			;7826	ff 	. 
	rst 38h			;7827	ff 	. 
	rst 38h			;7828	ff 	. 
	rst 38h			;7829	ff 	. 
	rst 38h			;782a	ff 	. 
	rst 38h			;782b	ff 	. 
	rst 38h			;782c	ff 	. 
	rst 38h			;782d	ff 	. 
	rst 38h			;782e	ff 	. 
	rst 38h			;782f	ff 	. 
	rst 38h			;7830	ff 	. 
	rst 38h			;7831	ff 	. 
	rst 38h			;7832	ff 	. 
	rst 38h			;7833	ff 	. 
	rst 38h			;7834	ff 	. 
	rst 38h			;7835	ff 	. 
	rst 38h			;7836	ff 	. 
	rst 38h			;7837	ff 	. 
	rst 38h			;7838	ff 	. 
	rst 38h			;7839	ff 	. 
	rst 38h			;783a	ff 	. 
	rst 38h			;783b	ff 	. 
	rst 38h			;783c	ff 	. 
	rst 38h			;783d	ff 	. 
	rst 38h			;783e	ff 	. 
	rst 38h			;783f	ff 	. 
	rst 38h			;7840	ff 	. 
	rst 38h			;7841	ff 	. 
	rst 38h			;7842	ff 	. 
	rst 38h			;7843	ff 	. 
	rst 38h			;7844	ff 	. 
	rst 38h			;7845	ff 	. 
	rst 38h			;7846	ff 	. 
	rst 38h			;7847	ff 	. 
	rst 38h			;7848	ff 	. 
	rst 38h			;7849	ff 	. 
	rst 38h			;784a	ff 	. 
	rst 38h			;784b	ff 	. 
	rst 38h			;784c	ff 	. 
	rst 38h			;784d	ff 	. 
	rst 38h			;784e	ff 	. 
	rst 38h			;784f	ff 	. 
	rst 38h			;7850	ff 	. 
	rst 38h			;7851	ff 	. 
	rst 38h			;7852	ff 	. 
	rst 38h			;7853	ff 	. 
	rst 38h			;7854	ff 	. 
	rst 38h			;7855	ff 	. 
	rst 38h			;7856	ff 	. 
	rst 38h			;7857	ff 	. 
	rst 38h			;7858	ff 	. 
	rst 38h			;7859	ff 	. 
	rst 38h			;785a	ff 	. 
	rst 38h			;785b	ff 	. 
	rst 38h			;785c	ff 	. 
	rst 38h			;785d	ff 	. 
	rst 38h			;785e	ff 	. 
	rst 38h			;785f	ff 	. 
	rst 38h			;7860	ff 	. 
	rst 38h			;7861	ff 	. 
	rst 38h			;7862	ff 	. 
	rst 38h			;7863	ff 	. 
	rst 38h			;7864	ff 	. 
	rst 38h			;7865	ff 	. 
	rst 38h			;7866	ff 	. 
	rst 38h			;7867	ff 	. 
	rst 38h			;7868	ff 	. 
	rst 38h			;7869	ff 	. 
	rst 38h			;786a	ff 	. 
	rst 38h			;786b	ff 	. 
	rst 38h			;786c	ff 	. 
	rst 38h			;786d	ff 	. 
	rst 38h			;786e	ff 	. 
	rst 38h			;786f	ff 	. 
	rst 38h			;7870	ff 	. 
	rst 38h			;7871	ff 	. 
	rst 38h			;7872	ff 	. 
	rst 38h			;7873	ff 	. 
	rst 38h			;7874	ff 	. 
	rst 38h			;7875	ff 	. 
	rst 38h			;7876	ff 	. 
	rst 38h			;7877	ff 	. 
	rst 38h			;7878	ff 	. 
	rst 38h			;7879	ff 	. 
	rst 38h			;787a	ff 	. 
	rst 38h			;787b	ff 	. 
	rst 38h			;787c	ff 	. 
	rst 38h			;787d	ff 	. 
	rst 38h			;787e	ff 	. 
	rst 38h			;787f	ff 	. 
	rst 38h			;7880	ff 	. 
	rst 38h			;7881	ff 	. 
	rst 38h			;7882	ff 	. 
	rst 38h			;7883	ff 	. 
	rst 38h			;7884	ff 	. 
	rst 38h			;7885	ff 	. 
	rst 38h			;7886	ff 	. 
	rst 38h			;7887	ff 	. 
	rst 38h			;7888	ff 	. 
	rst 38h			;7889	ff 	. 
	rst 38h			;788a	ff 	. 
	rst 38h			;788b	ff 	. 
	rst 38h			;788c	ff 	. 
	rst 38h			;788d	ff 	. 
	rst 38h			;788e	ff 	. 
	rst 38h			;788f	ff 	. 
	rst 38h			;7890	ff 	. 
	rst 38h			;7891	ff 	. 
	rst 38h			;7892	ff 	. 
	rst 38h			;7893	ff 	. 
	rst 38h			;7894	ff 	. 
	rst 38h			;7895	ff 	. 
	rst 38h			;7896	ff 	. 
	rst 38h			;7897	ff 	. 
	rst 38h			;7898	ff 	. 
	rst 38h			;7899	ff 	. 
	rst 38h			;789a	ff 	. 
	rst 38h			;789b	ff 	. 
	rst 38h			;789c	ff 	. 
	rst 38h			;789d	ff 	. 
	rst 38h			;789e	ff 	. 
	rst 38h			;789f	ff 	. 
	rst 38h			;78a0	ff 	. 
	rst 38h			;78a1	ff 	. 
	rst 38h			;78a2	ff 	. 
	rst 38h			;78a3	ff 	. 
	rst 38h			;78a4	ff 	. 
	rst 38h			;78a5	ff 	. 
	rst 38h			;78a6	ff 	. 
	rst 38h			;78a7	ff 	. 
	rst 38h			;78a8	ff 	. 
	rst 38h			;78a9	ff 	. 
	rst 38h			;78aa	ff 	. 
	rst 38h			;78ab	ff 	. 
	rst 38h			;78ac	ff 	. 
	rst 38h			;78ad	ff 	. 
	rst 38h			;78ae	ff 	. 
	rst 38h			;78af	ff 	. 
	rst 38h			;78b0	ff 	. 
	rst 38h			;78b1	ff 	. 
	rst 38h			;78b2	ff 	. 
	rst 38h			;78b3	ff 	. 
	rst 38h			;78b4	ff 	. 
	rst 38h			;78b5	ff 	. 
	rst 38h			;78b6	ff 	. 
	rst 38h			;78b7	ff 	. 
	rst 38h			;78b8	ff 	. 
	rst 38h			;78b9	ff 	. 
	rst 38h			;78ba	ff 	. 
	rst 38h			;78bb	ff 	. 
	rst 38h			;78bc	ff 	. 
	rst 38h			;78bd	ff 	. 
	rst 38h			;78be	ff 	. 
	rst 38h			;78bf	ff 	. 
	rst 38h			;78c0	ff 	. 
	rst 38h			;78c1	ff 	. 
	rst 38h			;78c2	ff 	. 
	rst 38h			;78c3	ff 	. 
	rst 38h			;78c4	ff 	. 
	rst 38h			;78c5	ff 	. 
	rst 38h			;78c6	ff 	. 
	rst 38h			;78c7	ff 	. 
	rst 38h			;78c8	ff 	. 
	rst 38h			;78c9	ff 	. 
	rst 38h			;78ca	ff 	. 
	rst 38h			;78cb	ff 	. 
	rst 38h			;78cc	ff 	. 
	rst 38h			;78cd	ff 	. 
	rst 38h			;78ce	ff 	. 
	rst 38h			;78cf	ff 	. 
	rst 38h			;78d0	ff 	. 
	rst 38h			;78d1	ff 	. 
	rst 38h			;78d2	ff 	. 
	rst 38h			;78d3	ff 	. 
	rst 38h			;78d4	ff 	. 
	rst 38h			;78d5	ff 	. 
	rst 38h			;78d6	ff 	. 
	rst 38h			;78d7	ff 	. 
	rst 38h			;78d8	ff 	. 
	rst 38h			;78d9	ff 	. 
	rst 38h			;78da	ff 	. 
	rst 38h			;78db	ff 	. 
	rst 38h			;78dc	ff 	. 
	rst 38h			;78dd	ff 	. 
	rst 38h			;78de	ff 	. 
	rst 38h			;78df	ff 	. 
	rst 38h			;78e0	ff 	. 
	rst 38h			;78e1	ff 	. 
	rst 38h			;78e2	ff 	. 
	rst 38h			;78e3	ff 	. 
	rst 38h			;78e4	ff 	. 
	rst 38h			;78e5	ff 	. 
	rst 38h			;78e6	ff 	. 
	rst 38h			;78e7	ff 	. 
	rst 38h			;78e8	ff 	. 
	rst 38h			;78e9	ff 	. 
	rst 38h			;78ea	ff 	. 
	rst 38h			;78eb	ff 	. 
	rst 38h			;78ec	ff 	. 
	rst 38h			;78ed	ff 	. 
	rst 38h			;78ee	ff 	. 
	rst 38h			;78ef	ff 	. 
	rst 38h			;78f0	ff 	. 
	rst 38h			;78f1	ff 	. 
	rst 38h			;78f2	ff 	. 
	rst 38h			;78f3	ff 	. 
	rst 38h			;78f4	ff 	. 
	rst 38h			;78f5	ff 	. 
	rst 38h			;78f6	ff 	. 
	rst 38h			;78f7	ff 	. 
l78f8h:
	rst 38h			;78f8	ff 	. 
	rst 38h			;78f9	ff 	. 
	rst 38h			;78fa	ff 	. 
	rst 38h			;78fb	ff 	. 
	rst 38h			;78fc	ff 	. 
	rst 38h			;78fd	ff 	. 
	rst 38h			;78fe	ff 	. 
	rst 38h			;78ff	ff 	. 
	rst 38h			;7900	ff 	. 
	rst 38h			;7901	ff 	. 
	rst 38h			;7902	ff 	. 
	rst 38h			;7903	ff 	. 
	rst 38h			;7904	ff 	. 
	rst 38h			;7905	ff 	. 
	rst 38h			;7906	ff 	. 
	rst 38h			;7907	ff 	. 
	rst 38h			;7908	ff 	. 
	rst 38h			;7909	ff 	. 
	rst 38h			;790a	ff 	. 
	rst 38h			;790b	ff 	. 
	rst 38h			;790c	ff 	. 
	rst 38h			;790d	ff 	. 
	rst 38h			;790e	ff 	. 
	rst 38h			;790f	ff 	. 
	rst 38h			;7910	ff 	. 
	rst 38h			;7911	ff 	. 
	rst 38h			;7912	ff 	. 
	rst 38h			;7913	ff 	. 
	rst 38h			;7914	ff 	. 
	rst 38h			;7915	ff 	. 
	rst 38h			;7916	ff 	. 
	rst 38h			;7917	ff 	. 
	rst 38h			;7918	ff 	. 
	rst 38h			;7919	ff 	. 
	rst 38h			;791a	ff 	. 
	rst 38h			;791b	ff 	. 
	rst 38h			;791c	ff 	. 
	rst 38h			;791d	ff 	. 
	rst 38h			;791e	ff 	. 
	rst 38h			;791f	ff 	. 
	rst 38h			;7920	ff 	. 
	rst 38h			;7921	ff 	. 
	rst 38h			;7922	ff 	. 
	rst 38h			;7923	ff 	. 
	rst 38h			;7924	ff 	. 
	rst 38h			;7925	ff 	. 
	rst 38h			;7926	ff 	. 
	rst 38h			;7927	ff 	. 
	rst 38h			;7928	ff 	. 
	rst 38h			;7929	ff 	. 
	rst 38h			;792a	ff 	. 
	rst 38h			;792b	ff 	. 
	rst 38h			;792c	ff 	. 
	rst 38h			;792d	ff 	. 
	rst 38h			;792e	ff 	. 
	rst 38h			;792f	ff 	. 
	rst 38h			;7930	ff 	. 
	rst 38h			;7931	ff 	. 
	rst 38h			;7932	ff 	. 
	rst 38h			;7933	ff 	. 
	rst 38h			;7934	ff 	. 
	rst 38h			;7935	ff 	. 
	rst 38h			;7936	ff 	. 
	rst 38h			;7937	ff 	. 
	rst 38h			;7938	ff 	. 
	rst 38h			;7939	ff 	. 
	rst 38h			;793a	ff 	. 
	rst 38h			;793b	ff 	. 
	rst 38h			;793c	ff 	. 
	rst 38h			;793d	ff 	. 
	rst 38h			;793e	ff 	. 
	rst 38h			;793f	ff 	. 
	rst 38h			;7940	ff 	. 
	rst 38h			;7941	ff 	. 
	rst 38h			;7942	ff 	. 
	rst 38h			;7943	ff 	. 
	rst 38h			;7944	ff 	. 
	rst 38h			;7945	ff 	. 
	rst 38h			;7946	ff 	. 
	rst 38h			;7947	ff 	. 
	rst 38h			;7948	ff 	. 
	rst 38h			;7949	ff 	. 
	rst 38h			;794a	ff 	. 
	rst 38h			;794b	ff 	. 
	rst 38h			;794c	ff 	. 
	rst 38h			;794d	ff 	. 
	rst 38h			;794e	ff 	. 
	rst 38h			;794f	ff 	. 
	rst 38h			;7950	ff 	. 
	rst 38h			;7951	ff 	. 
	rst 38h			;7952	ff 	. 
	rst 38h			;7953	ff 	. 
	rst 38h			;7954	ff 	. 
	rst 38h			;7955	ff 	. 
	rst 38h			;7956	ff 	. 
	rst 38h			;7957	ff 	. 
	rst 38h			;7958	ff 	. 
	rst 38h			;7959	ff 	. 
	rst 38h			;795a	ff 	. 
	rst 38h			;795b	ff 	. 
	rst 38h			;795c	ff 	. 
	rst 38h			;795d	ff 	. 
	rst 38h			;795e	ff 	. 
	rst 38h			;795f	ff 	. 
	rst 38h			;7960	ff 	. 
	rst 38h			;7961	ff 	. 
	rst 38h			;7962	ff 	. 
	rst 38h			;7963	ff 	. 
	rst 38h			;7964	ff 	. 
	rst 38h			;7965	ff 	. 
	rst 38h			;7966	ff 	. 
	rst 38h			;7967	ff 	. 
	rst 38h			;7968	ff 	. 
	rst 38h			;7969	ff 	. 
	rst 38h			;796a	ff 	. 
	rst 38h			;796b	ff 	. 
	rst 38h			;796c	ff 	. 
	rst 38h			;796d	ff 	. 
	rst 38h			;796e	ff 	. 
	rst 38h			;796f	ff 	. 
	rst 38h			;7970	ff 	. 
	rst 38h			;7971	ff 	. 
	rst 38h			;7972	ff 	. 
	rst 38h			;7973	ff 	. 
	rst 38h			;7974	ff 	. 
	rst 38h			;7975	ff 	. 
	rst 38h			;7976	ff 	. 
	rst 38h			;7977	ff 	. 
	rst 38h			;7978	ff 	. 
	rst 38h			;7979	ff 	. 
	rst 38h			;797a	ff 	. 
	rst 38h			;797b	ff 	. 
	rst 38h			;797c	ff 	. 
	rst 38h			;797d	ff 	. 
	rst 38h			;797e	ff 	. 
	rst 38h			;797f	ff 	. 
	rst 38h			;7980	ff 	. 
	rst 38h			;7981	ff 	. 
	rst 38h			;7982	ff 	. 
	rst 38h			;7983	ff 	. 
	rst 38h			;7984	ff 	. 
	rst 38h			;7985	ff 	. 
	rst 38h			;7986	ff 	. 
	rst 38h			;7987	ff 	. 
	rst 38h			;7988	ff 	. 
	rst 38h			;7989	ff 	. 
	rst 38h			;798a	ff 	. 
	rst 38h			;798b	ff 	. 
	rst 38h			;798c	ff 	. 
	rst 38h			;798d	ff 	. 
	rst 38h			;798e	ff 	. 
	rst 38h			;798f	ff 	. 
	rst 38h			;7990	ff 	. 
	rst 38h			;7991	ff 	. 
	rst 38h			;7992	ff 	. 
	rst 38h			;7993	ff 	. 
	rst 38h			;7994	ff 	. 
	rst 38h			;7995	ff 	. 
	rst 38h			;7996	ff 	. 
	rst 38h			;7997	ff 	. 
	rst 38h			;7998	ff 	. 
	rst 38h			;7999	ff 	. 
	rst 38h			;799a	ff 	. 
	rst 38h			;799b	ff 	. 
	rst 38h			;799c	ff 	. 
	rst 38h			;799d	ff 	. 
	rst 38h			;799e	ff 	. 
	rst 38h			;799f	ff 	. 
	rst 38h			;79a0	ff 	. 
	rst 38h			;79a1	ff 	. 
	rst 38h			;79a2	ff 	. 
	rst 38h			;79a3	ff 	. 
	rst 38h			;79a4	ff 	. 
	rst 38h			;79a5	ff 	. 
	rst 38h			;79a6	ff 	. 
	rst 38h			;79a7	ff 	. 
	rst 38h			;79a8	ff 	. 
	rst 38h			;79a9	ff 	. 
	rst 38h			;79aa	ff 	. 
	rst 38h			;79ab	ff 	. 
	rst 38h			;79ac	ff 	. 
	rst 38h			;79ad	ff 	. 
	rst 38h			;79ae	ff 	. 
	rst 38h			;79af	ff 	. 
	rst 38h			;79b0	ff 	. 
	rst 38h			;79b1	ff 	. 
	rst 38h			;79b2	ff 	. 
	rst 38h			;79b3	ff 	. 
	rst 38h			;79b4	ff 	. 
	rst 38h			;79b5	ff 	. 
	rst 38h			;79b6	ff 	. 
	rst 38h			;79b7	ff 	. 
	rst 38h			;79b8	ff 	. 
	rst 38h			;79b9	ff 	. 
	rst 38h			;79ba	ff 	. 
	rst 38h			;79bb	ff 	. 
	rst 38h			;79bc	ff 	. 
	rst 38h			;79bd	ff 	. 
	rst 38h			;79be	ff 	. 
	rst 38h			;79bf	ff 	. 
	rst 38h			;79c0	ff 	. 
	rst 38h			;79c1	ff 	. 
	rst 38h			;79c2	ff 	. 
	rst 38h			;79c3	ff 	. 
	rst 38h			;79c4	ff 	. 
	rst 38h			;79c5	ff 	. 
	rst 38h			;79c6	ff 	. 
	rst 38h			;79c7	ff 	. 
	rst 38h			;79c8	ff 	. 
	rst 38h			;79c9	ff 	. 
	rst 38h			;79ca	ff 	. 
	rst 38h			;79cb	ff 	. 
	rst 38h			;79cc	ff 	. 
	rst 38h			;79cd	ff 	. 
	rst 38h			;79ce	ff 	. 
	rst 38h			;79cf	ff 	. 
	rst 38h			;79d0	ff 	. 
	rst 38h			;79d1	ff 	. 
	rst 38h			;79d2	ff 	. 
	rst 38h			;79d3	ff 	. 
	rst 38h			;79d4	ff 	. 
	rst 38h			;79d5	ff 	. 
	rst 38h			;79d6	ff 	. 
	rst 38h			;79d7	ff 	. 
	rst 38h			;79d8	ff 	. 
	rst 38h			;79d9	ff 	. 
	rst 38h			;79da	ff 	. 
	rst 38h			;79db	ff 	. 
	rst 38h			;79dc	ff 	. 
	rst 38h			;79dd	ff 	. 
	rst 38h			;79de	ff 	. 
	rst 38h			;79df	ff 	. 
	rst 38h			;79e0	ff 	. 
	rst 38h			;79e1	ff 	. 
	rst 38h			;79e2	ff 	. 
	rst 38h			;79e3	ff 	. 
	rst 38h			;79e4	ff 	. 
	rst 38h			;79e5	ff 	. 
	rst 38h			;79e6	ff 	. 
	rst 38h			;79e7	ff 	. 
	rst 38h			;79e8	ff 	. 
	rst 38h			;79e9	ff 	. 
	rst 38h			;79ea	ff 	. 
	rst 38h			;79eb	ff 	. 
	rst 38h			;79ec	ff 	. 
	rst 38h			;79ed	ff 	. 
	rst 38h			;79ee	ff 	. 
	rst 38h			;79ef	ff 	. 
	rst 38h			;79f0	ff 	. 
	rst 38h			;79f1	ff 	. 
	rst 38h			;79f2	ff 	. 
	rst 38h			;79f3	ff 	. 
	rst 38h			;79f4	ff 	. 
	rst 38h			;79f5	ff 	. 
	rst 38h			;79f6	ff 	. 
	rst 38h			;79f7	ff 	. 
	rst 38h			;79f8	ff 	. 
	rst 38h			;79f9	ff 	. 
	rst 38h			;79fa	ff 	. 
	rst 38h			;79fb	ff 	. 
	rst 38h			;79fc	ff 	. 
	rst 38h			;79fd	ff 	. 
	rst 38h			;79fe	ff 	. 
	rst 38h			;79ff	ff 	. 
	rst 38h			;7a00	ff 	. 
	rst 38h			;7a01	ff 	. 
	rst 38h			;7a02	ff 	. 
	rst 38h			;7a03	ff 	. 
	rst 38h			;7a04	ff 	. 
	rst 38h			;7a05	ff 	. 
	rst 38h			;7a06	ff 	. 
	rst 38h			;7a07	ff 	. 
	rst 38h			;7a08	ff 	. 
	rst 38h			;7a09	ff 	. 
	rst 38h			;7a0a	ff 	. 
	rst 38h			;7a0b	ff 	. 
	rst 38h			;7a0c	ff 	. 
	rst 38h			;7a0d	ff 	. 
	rst 38h			;7a0e	ff 	. 
	rst 38h			;7a0f	ff 	. 
	rst 38h			;7a10	ff 	. 
	rst 38h			;7a11	ff 	. 
	rst 38h			;7a12	ff 	. 
	rst 38h			;7a13	ff 	. 
	rst 38h			;7a14	ff 	. 
	rst 38h			;7a15	ff 	. 
	rst 38h			;7a16	ff 	. 
	rst 38h			;7a17	ff 	. 
	rst 38h			;7a18	ff 	. 
	rst 38h			;7a19	ff 	. 
	rst 38h			;7a1a	ff 	. 
	rst 38h			;7a1b	ff 	. 
	rst 38h			;7a1c	ff 	. 
	rst 38h			;7a1d	ff 	. 
	rst 38h			;7a1e	ff 	. 
	rst 38h			;7a1f	ff 	. 
	rst 38h			;7a20	ff 	. 
	rst 38h			;7a21	ff 	. 
	rst 38h			;7a22	ff 	. 
	rst 38h			;7a23	ff 	. 
	rst 38h			;7a24	ff 	. 
	rst 38h			;7a25	ff 	. 
	rst 38h			;7a26	ff 	. 
	rst 38h			;7a27	ff 	. 
	rst 38h			;7a28	ff 	. 
	rst 38h			;7a29	ff 	. 
	rst 38h			;7a2a	ff 	. 
	rst 38h			;7a2b	ff 	. 
	rst 38h			;7a2c	ff 	. 
	rst 38h			;7a2d	ff 	. 
	rst 38h			;7a2e	ff 	. 
	rst 38h			;7a2f	ff 	. 
	rst 38h			;7a30	ff 	. 
	rst 38h			;7a31	ff 	. 
	rst 38h			;7a32	ff 	. 
	rst 38h			;7a33	ff 	. 
	rst 38h			;7a34	ff 	. 
	rst 38h			;7a35	ff 	. 
	rst 38h			;7a36	ff 	. 
	rst 38h			;7a37	ff 	. 
	rst 38h			;7a38	ff 	. 
	rst 38h			;7a39	ff 	. 
	rst 38h			;7a3a	ff 	. 
	rst 38h			;7a3b	ff 	. 
	rst 38h			;7a3c	ff 	. 
	rst 38h			;7a3d	ff 	. 
	rst 38h			;7a3e	ff 	. 
	rst 38h			;7a3f	ff 	. 
	rst 38h			;7a40	ff 	. 
	rst 38h			;7a41	ff 	. 
	rst 38h			;7a42	ff 	. 
	rst 38h			;7a43	ff 	. 
	rst 38h			;7a44	ff 	. 
	rst 38h			;7a45	ff 	. 
	rst 38h			;7a46	ff 	. 
	rst 38h			;7a47	ff 	. 
	rst 38h			;7a48	ff 	. 
	rst 38h			;7a49	ff 	. 
	rst 38h			;7a4a	ff 	. 
	rst 38h			;7a4b	ff 	. 
	rst 38h			;7a4c	ff 	. 
	rst 38h			;7a4d	ff 	. 
	rst 38h			;7a4e	ff 	. 
	rst 38h			;7a4f	ff 	. 
	rst 38h			;7a50	ff 	. 
	rst 38h			;7a51	ff 	. 
	rst 38h			;7a52	ff 	. 
	rst 38h			;7a53	ff 	. 
	rst 38h			;7a54	ff 	. 
	rst 38h			;7a55	ff 	. 
	rst 38h			;7a56	ff 	. 
	rst 38h			;7a57	ff 	. 
	rst 38h			;7a58	ff 	. 
	rst 38h			;7a59	ff 	. 
	rst 38h			;7a5a	ff 	. 
	rst 38h			;7a5b	ff 	. 
	rst 38h			;7a5c	ff 	. 
	rst 38h			;7a5d	ff 	. 
	rst 38h			;7a5e	ff 	. 
	rst 38h			;7a5f	ff 	. 
	rst 38h			;7a60	ff 	. 
	rst 38h			;7a61	ff 	. 
	rst 38h			;7a62	ff 	. 
	rst 38h			;7a63	ff 	. 
	rst 38h			;7a64	ff 	. 
	rst 38h			;7a65	ff 	. 
	rst 38h			;7a66	ff 	. 
	rst 38h			;7a67	ff 	. 
	rst 38h			;7a68	ff 	. 
	rst 38h			;7a69	ff 	. 
	rst 38h			;7a6a	ff 	. 
	rst 38h			;7a6b	ff 	. 
	rst 38h			;7a6c	ff 	. 
	rst 38h			;7a6d	ff 	. 
	rst 38h			;7a6e	ff 	. 
	rst 38h			;7a6f	ff 	. 
	rst 38h			;7a70	ff 	. 
	rst 38h			;7a71	ff 	. 
	rst 38h			;7a72	ff 	. 
	rst 38h			;7a73	ff 	. 
	rst 38h			;7a74	ff 	. 
	rst 38h			;7a75	ff 	. 
	rst 38h			;7a76	ff 	. 
	rst 38h			;7a77	ff 	. 
	rst 38h			;7a78	ff 	. 
	rst 38h			;7a79	ff 	. 
	rst 38h			;7a7a	ff 	. 
	rst 38h			;7a7b	ff 	. 
	rst 38h			;7a7c	ff 	. 
	rst 38h			;7a7d	ff 	. 
	rst 38h			;7a7e	ff 	. 
	rst 38h			;7a7f	ff 	. 
	rst 38h			;7a80	ff 	. 
	rst 38h			;7a81	ff 	. 
	rst 38h			;7a82	ff 	. 
	rst 38h			;7a83	ff 	. 
	rst 38h			;7a84	ff 	. 
	rst 38h			;7a85	ff 	. 
	rst 38h			;7a86	ff 	. 
	rst 38h			;7a87	ff 	. 
	rst 38h			;7a88	ff 	. 
	rst 38h			;7a89	ff 	. 
	rst 38h			;7a8a	ff 	. 
	rst 38h			;7a8b	ff 	. 
	rst 38h			;7a8c	ff 	. 
	rst 38h			;7a8d	ff 	. 
	rst 38h			;7a8e	ff 	. 
	rst 38h			;7a8f	ff 	. 
	rst 38h			;7a90	ff 	. 
	rst 38h			;7a91	ff 	. 
	rst 38h			;7a92	ff 	. 
	rst 38h			;7a93	ff 	. 
	rst 38h			;7a94	ff 	. 
	rst 38h			;7a95	ff 	. 
	rst 38h			;7a96	ff 	. 
	rst 38h			;7a97	ff 	. 
	rst 38h			;7a98	ff 	. 
	rst 38h			;7a99	ff 	. 
	rst 38h			;7a9a	ff 	. 
	rst 38h			;7a9b	ff 	. 
	rst 38h			;7a9c	ff 	. 
	rst 38h			;7a9d	ff 	. 
	rst 38h			;7a9e	ff 	. 
	rst 38h			;7a9f	ff 	. 
	rst 38h			;7aa0	ff 	. 
	rst 38h			;7aa1	ff 	. 
	rst 38h			;7aa2	ff 	. 
	rst 38h			;7aa3	ff 	. 
	rst 38h			;7aa4	ff 	. 
	rst 38h			;7aa5	ff 	. 
	rst 38h			;7aa6	ff 	. 
	rst 38h			;7aa7	ff 	. 
	rst 38h			;7aa8	ff 	. 
	rst 38h			;7aa9	ff 	. 
	rst 38h			;7aaa	ff 	. 
	rst 38h			;7aab	ff 	. 
	rst 38h			;7aac	ff 	. 
	rst 38h			;7aad	ff 	. 
	rst 38h			;7aae	ff 	. 
	rst 38h			;7aaf	ff 	. 
	rst 38h			;7ab0	ff 	. 
	rst 38h			;7ab1	ff 	. 
	rst 38h			;7ab2	ff 	. 
	rst 38h			;7ab3	ff 	. 
	rst 38h			;7ab4	ff 	. 
	rst 38h			;7ab5	ff 	. 
	rst 38h			;7ab6	ff 	. 
	rst 38h			;7ab7	ff 	. 
	rst 38h			;7ab8	ff 	. 
	rst 38h			;7ab9	ff 	. 
	rst 38h			;7aba	ff 	. 
	rst 38h			;7abb	ff 	. 
	rst 38h			;7abc	ff 	. 
	rst 38h			;7abd	ff 	. 
	rst 38h			;7abe	ff 	. 
	rst 38h			;7abf	ff 	. 
	rst 38h			;7ac0	ff 	. 
	rst 38h			;7ac1	ff 	. 
	rst 38h			;7ac2	ff 	. 
	rst 38h			;7ac3	ff 	. 
	rst 38h			;7ac4	ff 	. 
	rst 38h			;7ac5	ff 	. 
	rst 38h			;7ac6	ff 	. 
	rst 38h			;7ac7	ff 	. 
	rst 38h			;7ac8	ff 	. 
	rst 38h			;7ac9	ff 	. 
	rst 38h			;7aca	ff 	. 
	rst 38h			;7acb	ff 	. 
	rst 38h			;7acc	ff 	. 
	rst 38h			;7acd	ff 	. 
	rst 38h			;7ace	ff 	. 
	rst 38h			;7acf	ff 	. 
	rst 38h			;7ad0	ff 	. 
	rst 38h			;7ad1	ff 	. 
	rst 38h			;7ad2	ff 	. 
	rst 38h			;7ad3	ff 	. 
	rst 38h			;7ad4	ff 	. 
	rst 38h			;7ad5	ff 	. 
	rst 38h			;7ad6	ff 	. 
	rst 38h			;7ad7	ff 	. 
	rst 38h			;7ad8	ff 	. 
	rst 38h			;7ad9	ff 	. 
	rst 38h			;7ada	ff 	. 
	rst 38h			;7adb	ff 	. 
	rst 38h			;7adc	ff 	. 
	rst 38h			;7add	ff 	. 
	rst 38h			;7ade	ff 	. 
	rst 38h			;7adf	ff 	. 
	rst 38h			;7ae0	ff 	. 
	rst 38h			;7ae1	ff 	. 
	rst 38h			;7ae2	ff 	. 
	rst 38h			;7ae3	ff 	. 
	rst 38h			;7ae4	ff 	. 
	rst 38h			;7ae5	ff 	. 
	rst 38h			;7ae6	ff 	. 
	rst 38h			;7ae7	ff 	. 
	rst 38h			;7ae8	ff 	. 
	rst 38h			;7ae9	ff 	. 
	rst 38h			;7aea	ff 	. 
	rst 38h			;7aeb	ff 	. 
	rst 38h			;7aec	ff 	. 
	rst 38h			;7aed	ff 	. 
	rst 38h			;7aee	ff 	. 
	rst 38h			;7aef	ff 	. 
	rst 38h			;7af0	ff 	. 
	rst 38h			;7af1	ff 	. 
	rst 38h			;7af2	ff 	. 
	rst 38h			;7af3	ff 	. 
	rst 38h			;7af4	ff 	. 
	rst 38h			;7af5	ff 	. 
	rst 38h			;7af6	ff 	. 
	rst 38h			;7af7	ff 	. 
	rst 38h			;7af8	ff 	. 
	rst 38h			;7af9	ff 	. 
	rst 38h			;7afa	ff 	. 
	rst 38h			;7afb	ff 	. 
	rst 38h			;7afc	ff 	. 
	rst 38h			;7afd	ff 	. 
	rst 38h			;7afe	ff 	. 
	rst 38h			;7aff	ff 	. 
	rst 38h			;7b00	ff 	. 
	rst 38h			;7b01	ff 	. 
	rst 38h			;7b02	ff 	. 
	rst 38h			;7b03	ff 	. 
	rst 38h			;7b04	ff 	. 
	rst 38h			;7b05	ff 	. 
	rst 38h			;7b06	ff 	. 
	rst 38h			;7b07	ff 	. 
	rst 38h			;7b08	ff 	. 
	rst 38h			;7b09	ff 	. 
	rst 38h			;7b0a	ff 	. 
	rst 38h			;7b0b	ff 	. 
	rst 38h			;7b0c	ff 	. 
	rst 38h			;7b0d	ff 	. 
	rst 38h			;7b0e	ff 	. 
	rst 38h			;7b0f	ff 	. 
	rst 38h			;7b10	ff 	. 
	rst 38h			;7b11	ff 	. 
	rst 38h			;7b12	ff 	. 
	rst 38h			;7b13	ff 	. 
	rst 38h			;7b14	ff 	. 
	rst 38h			;7b15	ff 	. 
	rst 38h			;7b16	ff 	. 
	rst 38h			;7b17	ff 	. 
	rst 38h			;7b18	ff 	. 
	rst 38h			;7b19	ff 	. 
	rst 38h			;7b1a	ff 	. 
	rst 38h			;7b1b	ff 	. 
	rst 38h			;7b1c	ff 	. 
	rst 38h			;7b1d	ff 	. 
	rst 38h			;7b1e	ff 	. 
	rst 38h			;7b1f	ff 	. 
	rst 38h			;7b20	ff 	. 
	rst 38h			;7b21	ff 	. 
	rst 38h			;7b22	ff 	. 
	rst 38h			;7b23	ff 	. 
	rst 38h			;7b24	ff 	. 
	rst 38h			;7b25	ff 	. 
	rst 38h			;7b26	ff 	. 
	rst 38h			;7b27	ff 	. 
	rst 38h			;7b28	ff 	. 
	rst 38h			;7b29	ff 	. 
	rst 38h			;7b2a	ff 	. 
	rst 38h			;7b2b	ff 	. 
	rst 38h			;7b2c	ff 	. 
	rst 38h			;7b2d	ff 	. 
	rst 38h			;7b2e	ff 	. 
	rst 38h			;7b2f	ff 	. 
	rst 38h			;7b30	ff 	. 
	rst 38h			;7b31	ff 	. 
	rst 38h			;7b32	ff 	. 
	rst 38h			;7b33	ff 	. 
	rst 38h			;7b34	ff 	. 
	rst 38h			;7b35	ff 	. 
	rst 38h			;7b36	ff 	. 
	rst 38h			;7b37	ff 	. 
	rst 38h			;7b38	ff 	. 
	rst 38h			;7b39	ff 	. 
	rst 38h			;7b3a	ff 	. 
	rst 38h			;7b3b	ff 	. 
	rst 38h			;7b3c	ff 	. 
	rst 38h			;7b3d	ff 	. 
	rst 38h			;7b3e	ff 	. 
	rst 38h			;7b3f	ff 	. 
	rst 38h			;7b40	ff 	. 
	rst 38h			;7b41	ff 	. 
	rst 38h			;7b42	ff 	. 
	rst 38h			;7b43	ff 	. 
	rst 38h			;7b44	ff 	. 
	rst 38h			;7b45	ff 	. 
	rst 38h			;7b46	ff 	. 
	rst 38h			;7b47	ff 	. 
	rst 38h			;7b48	ff 	. 
	rst 38h			;7b49	ff 	. 
	rst 38h			;7b4a	ff 	. 
	rst 38h			;7b4b	ff 	. 
	rst 38h			;7b4c	ff 	. 
	rst 38h			;7b4d	ff 	. 
	rst 38h			;7b4e	ff 	. 
	rst 38h			;7b4f	ff 	. 
	rst 38h			;7b50	ff 	. 
	rst 38h			;7b51	ff 	. 
	rst 38h			;7b52	ff 	. 
	rst 38h			;7b53	ff 	. 
	rst 38h			;7b54	ff 	. 
	rst 38h			;7b55	ff 	. 
	rst 38h			;7b56	ff 	. 
	rst 38h			;7b57	ff 	. 
	rst 38h			;7b58	ff 	. 
	rst 38h			;7b59	ff 	. 
	rst 38h			;7b5a	ff 	. 
	rst 38h			;7b5b	ff 	. 
	rst 38h			;7b5c	ff 	. 
	rst 38h			;7b5d	ff 	. 
	rst 38h			;7b5e	ff 	. 
	rst 38h			;7b5f	ff 	. 
	rst 38h			;7b60	ff 	. 
	rst 38h			;7b61	ff 	. 
	rst 38h			;7b62	ff 	. 
	rst 38h			;7b63	ff 	. 
	rst 38h			;7b64	ff 	. 
	rst 38h			;7b65	ff 	. 
	rst 38h			;7b66	ff 	. 
	rst 38h			;7b67	ff 	. 
	rst 38h			;7b68	ff 	. 
	rst 38h			;7b69	ff 	. 
	rst 38h			;7b6a	ff 	. 
	rst 38h			;7b6b	ff 	. 
	rst 38h			;7b6c	ff 	. 
	rst 38h			;7b6d	ff 	. 
	rst 38h			;7b6e	ff 	. 
	rst 38h			;7b6f	ff 	. 
	rst 38h			;7b70	ff 	. 
	rst 38h			;7b71	ff 	. 
	rst 38h			;7b72	ff 	. 
	rst 38h			;7b73	ff 	. 
	rst 38h			;7b74	ff 	. 
	rst 38h			;7b75	ff 	. 
	rst 38h			;7b76	ff 	. 
	rst 38h			;7b77	ff 	. 
	rst 38h			;7b78	ff 	. 
	rst 38h			;7b79	ff 	. 
	rst 38h			;7b7a	ff 	. 
	rst 38h			;7b7b	ff 	. 
	rst 38h			;7b7c	ff 	. 
	rst 38h			;7b7d	ff 	. 
	rst 38h			;7b7e	ff 	. 
	rst 38h			;7b7f	ff 	. 
	rst 38h			;7b80	ff 	. 
	rst 38h			;7b81	ff 	. 
	rst 38h			;7b82	ff 	. 
	rst 38h			;7b83	ff 	. 
	rst 38h			;7b84	ff 	. 
	rst 38h			;7b85	ff 	. 
	rst 38h			;7b86	ff 	. 
	rst 38h			;7b87	ff 	. 
	rst 38h			;7b88	ff 	. 
	rst 38h			;7b89	ff 	. 
	rst 38h			;7b8a	ff 	. 
	rst 38h			;7b8b	ff 	. 
	rst 38h			;7b8c	ff 	. 
	rst 38h			;7b8d	ff 	. 
	rst 38h			;7b8e	ff 	. 
	rst 38h			;7b8f	ff 	. 
	rst 38h			;7b90	ff 	. 
	rst 38h			;7b91	ff 	. 
	rst 38h			;7b92	ff 	. 
	rst 38h			;7b93	ff 	. 
	rst 38h			;7b94	ff 	. 
	rst 38h			;7b95	ff 	. 
	rst 38h			;7b96	ff 	. 
	rst 38h			;7b97	ff 	. 
	rst 38h			;7b98	ff 	. 
	rst 38h			;7b99	ff 	. 
	rst 38h			;7b9a	ff 	. 
	rst 38h			;7b9b	ff 	. 
	rst 38h			;7b9c	ff 	. 
	rst 38h			;7b9d	ff 	. 
	rst 38h			;7b9e	ff 	. 
	rst 38h			;7b9f	ff 	. 
	rst 38h			;7ba0	ff 	. 
	rst 38h			;7ba1	ff 	. 
	rst 38h			;7ba2	ff 	. 
	rst 38h			;7ba3	ff 	. 
	rst 38h			;7ba4	ff 	. 
	rst 38h			;7ba5	ff 	. 
	rst 38h			;7ba6	ff 	. 
	rst 38h			;7ba7	ff 	. 
	rst 38h			;7ba8	ff 	. 
	rst 38h			;7ba9	ff 	. 
	rst 38h			;7baa	ff 	. 
	rst 38h			;7bab	ff 	. 
	rst 38h			;7bac	ff 	. 
	rst 38h			;7bad	ff 	. 
	rst 38h			;7bae	ff 	. 
	rst 38h			;7baf	ff 	. 
	rst 38h			;7bb0	ff 	. 
	rst 38h			;7bb1	ff 	. 
	rst 38h			;7bb2	ff 	. 
	rst 38h			;7bb3	ff 	. 
	rst 38h			;7bb4	ff 	. 
	rst 38h			;7bb5	ff 	. 
	rst 38h			;7bb6	ff 	. 
	rst 38h			;7bb7	ff 	. 
	rst 38h			;7bb8	ff 	. 
	rst 38h			;7bb9	ff 	. 
	rst 38h			;7bba	ff 	. 
	rst 38h			;7bbb	ff 	. 
	rst 38h			;7bbc	ff 	. 
	rst 38h			;7bbd	ff 	. 
	rst 38h			;7bbe	ff 	. 
	rst 38h			;7bbf	ff 	. 
	rst 38h			;7bc0	ff 	. 
	rst 38h			;7bc1	ff 	. 
	rst 38h			;7bc2	ff 	. 
	rst 38h			;7bc3	ff 	. 
	rst 38h			;7bc4	ff 	. 
	rst 38h			;7bc5	ff 	. 
	rst 38h			;7bc6	ff 	. 
	rst 38h			;7bc7	ff 	. 
	rst 38h			;7bc8	ff 	. 
	rst 38h			;7bc9	ff 	. 
	rst 38h			;7bca	ff 	. 
	rst 38h			;7bcb	ff 	. 
	rst 38h			;7bcc	ff 	. 
	rst 38h			;7bcd	ff 	. 
	rst 38h			;7bce	ff 	. 
	rst 38h			;7bcf	ff 	. 
	rst 38h			;7bd0	ff 	. 
	rst 38h			;7bd1	ff 	. 
	rst 38h			;7bd2	ff 	. 
	rst 38h			;7bd3	ff 	. 
	rst 38h			;7bd4	ff 	. 
	rst 38h			;7bd5	ff 	. 
	rst 38h			;7bd6	ff 	. 
	rst 38h			;7bd7	ff 	. 
	rst 38h			;7bd8	ff 	. 
	rst 38h			;7bd9	ff 	. 
	rst 38h			;7bda	ff 	. 
	rst 38h			;7bdb	ff 	. 
	rst 38h			;7bdc	ff 	. 
	rst 38h			;7bdd	ff 	. 
	rst 38h			;7bde	ff 	. 
	rst 38h			;7bdf	ff 	. 
	rst 38h			;7be0	ff 	. 
	rst 38h			;7be1	ff 	. 
	rst 38h			;7be2	ff 	. 
	rst 38h			;7be3	ff 	. 
	rst 38h			;7be4	ff 	. 
	rst 38h			;7be5	ff 	. 
	rst 38h			;7be6	ff 	. 
	rst 38h			;7be7	ff 	. 
	rst 38h			;7be8	ff 	. 
	rst 38h			;7be9	ff 	. 
	rst 38h			;7bea	ff 	. 
	rst 38h			;7beb	ff 	. 
	rst 38h			;7bec	ff 	. 
	rst 38h			;7bed	ff 	. 
	rst 38h			;7bee	ff 	. 
	rst 38h			;7bef	ff 	. 
	rst 38h			;7bf0	ff 	. 
	rst 38h			;7bf1	ff 	. 
	rst 38h			;7bf2	ff 	. 
	rst 38h			;7bf3	ff 	. 
	rst 38h			;7bf4	ff 	. 
	rst 38h			;7bf5	ff 	. 
	rst 38h			;7bf6	ff 	. 
	rst 38h			;7bf7	ff 	. 
	rst 38h			;7bf8	ff 	. 
	rst 38h			;7bf9	ff 	. 
	rst 38h			;7bfa	ff 	. 
	rst 38h			;7bfb	ff 	. 
	rst 38h			;7bfc	ff 	. 
	rst 38h			;7bfd	ff 	. 
	rst 38h			;7bfe	ff 	. 
	rst 38h			;7bff	ff 	. 
	rst 38h			;7c00	ff 	. 
	rst 38h			;7c01	ff 	. 
	rst 38h			;7c02	ff 	. 
	rst 38h			;7c03	ff 	. 
	rst 38h			;7c04	ff 	. 
	rst 38h			;7c05	ff 	. 
	rst 38h			;7c06	ff 	. 
	rst 38h			;7c07	ff 	. 
	rst 38h			;7c08	ff 	. 
	rst 38h			;7c09	ff 	. 
	rst 38h			;7c0a	ff 	. 
	rst 38h			;7c0b	ff 	. 
	rst 38h			;7c0c	ff 	. 
	rst 38h			;7c0d	ff 	. 
	rst 38h			;7c0e	ff 	. 
	rst 38h			;7c0f	ff 	. 
	rst 38h			;7c10	ff 	. 
	rst 38h			;7c11	ff 	. 
	rst 38h			;7c12	ff 	. 
	rst 38h			;7c13	ff 	. 
	rst 38h			;7c14	ff 	. 
	rst 38h			;7c15	ff 	. 
	rst 38h			;7c16	ff 	. 
	rst 38h			;7c17	ff 	. 
	rst 38h			;7c18	ff 	. 
	rst 38h			;7c19	ff 	. 
	rst 38h			;7c1a	ff 	. 
	rst 38h			;7c1b	ff 	. 
	rst 38h			;7c1c	ff 	. 
	rst 38h			;7c1d	ff 	. 
	rst 38h			;7c1e	ff 	. 
	rst 38h			;7c1f	ff 	. 
	rst 38h			;7c20	ff 	. 
	rst 38h			;7c21	ff 	. 
	rst 38h			;7c22	ff 	. 
	rst 38h			;7c23	ff 	. 
	rst 38h			;7c24	ff 	. 
	rst 38h			;7c25	ff 	. 
	rst 38h			;7c26	ff 	. 
	rst 38h			;7c27	ff 	. 
	rst 38h			;7c28	ff 	. 
	rst 38h			;7c29	ff 	. 
	rst 38h			;7c2a	ff 	. 
	rst 38h			;7c2b	ff 	. 
	rst 38h			;7c2c	ff 	. 
	rst 38h			;7c2d	ff 	. 
	rst 38h			;7c2e	ff 	. 
	rst 38h			;7c2f	ff 	. 
	rst 38h			;7c30	ff 	. 
	rst 38h			;7c31	ff 	. 
	rst 38h			;7c32	ff 	. 
	rst 38h			;7c33	ff 	. 
	rst 38h			;7c34	ff 	. 
	rst 38h			;7c35	ff 	. 
	rst 38h			;7c36	ff 	. 
	rst 38h			;7c37	ff 	. 
	rst 38h			;7c38	ff 	. 
	rst 38h			;7c39	ff 	. 
	rst 38h			;7c3a	ff 	. 
	rst 38h			;7c3b	ff 	. 
	rst 38h			;7c3c	ff 	. 
	rst 38h			;7c3d	ff 	. 
	rst 38h			;7c3e	ff 	. 
	rst 38h			;7c3f	ff 	. 
	rst 38h			;7c40	ff 	. 
	rst 38h			;7c41	ff 	. 
	rst 38h			;7c42	ff 	. 
	rst 38h			;7c43	ff 	. 
	rst 38h			;7c44	ff 	. 
	rst 38h			;7c45	ff 	. 
	rst 38h			;7c46	ff 	. 
	rst 38h			;7c47	ff 	. 
	rst 38h			;7c48	ff 	. 
	rst 38h			;7c49	ff 	. 
	rst 38h			;7c4a	ff 	. 
	rst 38h			;7c4b	ff 	. 
	rst 38h			;7c4c	ff 	. 
	rst 38h			;7c4d	ff 	. 
	rst 38h			;7c4e	ff 	. 
	rst 38h			;7c4f	ff 	. 
	rst 38h			;7c50	ff 	. 
	rst 38h			;7c51	ff 	. 
	rst 38h			;7c52	ff 	. 
	rst 38h			;7c53	ff 	. 
	rst 38h			;7c54	ff 	. 
	rst 38h			;7c55	ff 	. 
	rst 38h			;7c56	ff 	. 
	rst 38h			;7c57	ff 	. 
	rst 38h			;7c58	ff 	. 
	rst 38h			;7c59	ff 	. 
	rst 38h			;7c5a	ff 	. 
	rst 38h			;7c5b	ff 	. 
	rst 38h			;7c5c	ff 	. 
	rst 38h			;7c5d	ff 	. 
	rst 38h			;7c5e	ff 	. 
	rst 38h			;7c5f	ff 	. 
	rst 38h			;7c60	ff 	. 
	rst 38h			;7c61	ff 	. 
	rst 38h			;7c62	ff 	. 
	rst 38h			;7c63	ff 	. 
	rst 38h			;7c64	ff 	. 
	rst 38h			;7c65	ff 	. 
	rst 38h			;7c66	ff 	. 
	rst 38h			;7c67	ff 	. 
	rst 38h			;7c68	ff 	. 
	rst 38h			;7c69	ff 	. 
	rst 38h			;7c6a	ff 	. 
	rst 38h			;7c6b	ff 	. 
	rst 38h			;7c6c	ff 	. 
	rst 38h			;7c6d	ff 	. 
	rst 38h			;7c6e	ff 	. 
	rst 38h			;7c6f	ff 	. 
	rst 38h			;7c70	ff 	. 
	rst 38h			;7c71	ff 	. 
	rst 38h			;7c72	ff 	. 
	rst 38h			;7c73	ff 	. 
	rst 38h			;7c74	ff 	. 
	rst 38h			;7c75	ff 	. 
	rst 38h			;7c76	ff 	. 
	rst 38h			;7c77	ff 	. 
	rst 38h			;7c78	ff 	. 
	rst 38h			;7c79	ff 	. 
	rst 38h			;7c7a	ff 	. 
	rst 38h			;7c7b	ff 	. 
	rst 38h			;7c7c	ff 	. 
	rst 38h			;7c7d	ff 	. 
	rst 38h			;7c7e	ff 	. 
	rst 38h			;7c7f	ff 	. 
	rst 38h			;7c80	ff 	. 
	rst 38h			;7c81	ff 	. 
	rst 38h			;7c82	ff 	. 
	rst 38h			;7c83	ff 	. 
	rst 38h			;7c84	ff 	. 
	rst 38h			;7c85	ff 	. 
	rst 38h			;7c86	ff 	. 
	rst 38h			;7c87	ff 	. 
	rst 38h			;7c88	ff 	. 
	rst 38h			;7c89	ff 	. 
	rst 38h			;7c8a	ff 	. 
	rst 38h			;7c8b	ff 	. 
	rst 38h			;7c8c	ff 	. 
	rst 38h			;7c8d	ff 	. 
	rst 38h			;7c8e	ff 	. 
	rst 38h			;7c8f	ff 	. 
	rst 38h			;7c90	ff 	. 
	rst 38h			;7c91	ff 	. 
	rst 38h			;7c92	ff 	. 
	rst 38h			;7c93	ff 	. 
	rst 38h			;7c94	ff 	. 
	rst 38h			;7c95	ff 	. 
	rst 38h			;7c96	ff 	. 
	rst 38h			;7c97	ff 	. 
	rst 38h			;7c98	ff 	. 
	rst 38h			;7c99	ff 	. 
	rst 38h			;7c9a	ff 	. 
	rst 38h			;7c9b	ff 	. 
	rst 38h			;7c9c	ff 	. 
	rst 38h			;7c9d	ff 	. 
	rst 38h			;7c9e	ff 	. 
	rst 38h			;7c9f	ff 	. 
	rst 38h			;7ca0	ff 	. 
	rst 38h			;7ca1	ff 	. 
	rst 38h			;7ca2	ff 	. 
	rst 38h			;7ca3	ff 	. 
	rst 38h			;7ca4	ff 	. 
	rst 38h			;7ca5	ff 	. 
	rst 38h			;7ca6	ff 	. 
	rst 38h			;7ca7	ff 	. 
	rst 38h			;7ca8	ff 	. 
	rst 38h			;7ca9	ff 	. 
	rst 38h			;7caa	ff 	. 
	rst 38h			;7cab	ff 	. 
	rst 38h			;7cac	ff 	. 
	rst 38h			;7cad	ff 	. 
	rst 38h			;7cae	ff 	. 
	rst 38h			;7caf	ff 	. 
	rst 38h			;7cb0	ff 	. 
	rst 38h			;7cb1	ff 	. 
	rst 38h			;7cb2	ff 	. 
	rst 38h			;7cb3	ff 	. 
	rst 38h			;7cb4	ff 	. 
	rst 38h			;7cb5	ff 	. 
	rst 38h			;7cb6	ff 	. 
	rst 38h			;7cb7	ff 	. 
	rst 38h			;7cb8	ff 	. 
	rst 38h			;7cb9	ff 	. 
	rst 38h			;7cba	ff 	. 
	rst 38h			;7cbb	ff 	. 
	rst 38h			;7cbc	ff 	. 
	rst 38h			;7cbd	ff 	. 
	rst 38h			;7cbe	ff 	. 
	rst 38h			;7cbf	ff 	. 
	rst 38h			;7cc0	ff 	. 
	rst 38h			;7cc1	ff 	. 
	rst 38h			;7cc2	ff 	. 
	rst 38h			;7cc3	ff 	. 
	rst 38h			;7cc4	ff 	. 
	rst 38h			;7cc5	ff 	. 
	rst 38h			;7cc6	ff 	. 
	rst 38h			;7cc7	ff 	. 
	rst 38h			;7cc8	ff 	. 
	rst 38h			;7cc9	ff 	. 
	rst 38h			;7cca	ff 	. 
	rst 38h			;7ccb	ff 	. 
	rst 38h			;7ccc	ff 	. 
	rst 38h			;7ccd	ff 	. 
	rst 38h			;7cce	ff 	. 
	rst 38h			;7ccf	ff 	. 
	rst 38h			;7cd0	ff 	. 
	rst 38h			;7cd1	ff 	. 
	rst 38h			;7cd2	ff 	. 
	rst 38h			;7cd3	ff 	. 
	rst 38h			;7cd4	ff 	. 
	rst 38h			;7cd5	ff 	. 
	rst 38h			;7cd6	ff 	. 
	rst 38h			;7cd7	ff 	. 
	rst 38h			;7cd8	ff 	. 
	rst 38h			;7cd9	ff 	. 
	rst 38h			;7cda	ff 	. 
	rst 38h			;7cdb	ff 	. 
	rst 38h			;7cdc	ff 	. 
	rst 38h			;7cdd	ff 	. 
	rst 38h			;7cde	ff 	. 
	rst 38h			;7cdf	ff 	. 
	rst 38h			;7ce0	ff 	. 
	rst 38h			;7ce1	ff 	. 
	rst 38h			;7ce2	ff 	. 
	rst 38h			;7ce3	ff 	. 
	rst 38h			;7ce4	ff 	. 
	rst 38h			;7ce5	ff 	. 
	rst 38h			;7ce6	ff 	. 
	rst 38h			;7ce7	ff 	. 
	rst 38h			;7ce8	ff 	. 
	rst 38h			;7ce9	ff 	. 
	rst 38h			;7cea	ff 	. 
	rst 38h			;7ceb	ff 	. 
	rst 38h			;7cec	ff 	. 
	rst 38h			;7ced	ff 	. 
	rst 38h			;7cee	ff 	. 
	rst 38h			;7cef	ff 	. 
	rst 38h			;7cf0	ff 	. 
	rst 38h			;7cf1	ff 	. 
	rst 38h			;7cf2	ff 	. 
	rst 38h			;7cf3	ff 	. 
	rst 38h			;7cf4	ff 	. 
	rst 38h			;7cf5	ff 	. 
	rst 38h			;7cf6	ff 	. 
	rst 38h			;7cf7	ff 	. 
	rst 38h			;7cf8	ff 	. 
	rst 38h			;7cf9	ff 	. 
	rst 38h			;7cfa	ff 	. 
	rst 38h			;7cfb	ff 	. 
	rst 38h			;7cfc	ff 	. 
	rst 38h			;7cfd	ff 	. 
	rst 38h			;7cfe	ff 	. 
	rst 38h			;7cff	ff 	. 
	rst 38h			;7d00	ff 	. 
	rst 38h			;7d01	ff 	. 
	rst 38h			;7d02	ff 	. 
	rst 38h			;7d03	ff 	. 
	rst 38h			;7d04	ff 	. 
	rst 38h			;7d05	ff 	. 
	rst 38h			;7d06	ff 	. 
	rst 38h			;7d07	ff 	. 
	rst 38h			;7d08	ff 	. 
	rst 38h			;7d09	ff 	. 
	rst 38h			;7d0a	ff 	. 
	rst 38h			;7d0b	ff 	. 
	rst 38h			;7d0c	ff 	. 
	rst 38h			;7d0d	ff 	. 
	rst 38h			;7d0e	ff 	. 
	rst 38h			;7d0f	ff 	. 
	rst 38h			;7d10	ff 	. 
	rst 38h			;7d11	ff 	. 
	rst 38h			;7d12	ff 	. 
	rst 38h			;7d13	ff 	. 
	rst 38h			;7d14	ff 	. 
	rst 38h			;7d15	ff 	. 
	rst 38h			;7d16	ff 	. 
	rst 38h			;7d17	ff 	. 
	rst 38h			;7d18	ff 	. 
	rst 38h			;7d19	ff 	. 
	rst 38h			;7d1a	ff 	. 
	rst 38h			;7d1b	ff 	. 
	rst 38h			;7d1c	ff 	. 
	rst 38h			;7d1d	ff 	. 
	rst 38h			;7d1e	ff 	. 
	rst 38h			;7d1f	ff 	. 
	rst 38h			;7d20	ff 	. 
	rst 38h			;7d21	ff 	. 
	rst 38h			;7d22	ff 	. 
	rst 38h			;7d23	ff 	. 
	rst 38h			;7d24	ff 	. 
	rst 38h			;7d25	ff 	. 
	rst 38h			;7d26	ff 	. 
	rst 38h			;7d27	ff 	. 
	rst 38h			;7d28	ff 	. 
	rst 38h			;7d29	ff 	. 
	rst 38h			;7d2a	ff 	. 
	rst 38h			;7d2b	ff 	. 
	rst 38h			;7d2c	ff 	. 
	rst 38h			;7d2d	ff 	. 
	rst 38h			;7d2e	ff 	. 
	rst 38h			;7d2f	ff 	. 
	rst 38h			;7d30	ff 	. 
	rst 38h			;7d31	ff 	. 
	rst 38h			;7d32	ff 	. 
	rst 38h			;7d33	ff 	. 
	rst 38h			;7d34	ff 	. 
	rst 38h			;7d35	ff 	. 
	rst 38h			;7d36	ff 	. 
	rst 38h			;7d37	ff 	. 
	rst 38h			;7d38	ff 	. 
	rst 38h			;7d39	ff 	. 
	rst 38h			;7d3a	ff 	. 
	rst 38h			;7d3b	ff 	. 
	rst 38h			;7d3c	ff 	. 
	rst 38h			;7d3d	ff 	. 
	rst 38h			;7d3e	ff 	. 
	rst 38h			;7d3f	ff 	. 
	rst 38h			;7d40	ff 	. 
	rst 38h			;7d41	ff 	. 
	rst 38h			;7d42	ff 	. 
	rst 38h			;7d43	ff 	. 
	rst 38h			;7d44	ff 	. 
	rst 38h			;7d45	ff 	. 
	rst 38h			;7d46	ff 	. 
	rst 38h			;7d47	ff 	. 
	rst 38h			;7d48	ff 	. 
	rst 38h			;7d49	ff 	. 
	rst 38h			;7d4a	ff 	. 
	rst 38h			;7d4b	ff 	. 
	rst 38h			;7d4c	ff 	. 
	rst 38h			;7d4d	ff 	. 
	rst 38h			;7d4e	ff 	. 
	rst 38h			;7d4f	ff 	. 
	rst 38h			;7d50	ff 	. 
	rst 38h			;7d51	ff 	. 
	rst 38h			;7d52	ff 	. 
	rst 38h			;7d53	ff 	. 
	rst 38h			;7d54	ff 	. 
	rst 38h			;7d55	ff 	. 
	rst 38h			;7d56	ff 	. 
	rst 38h			;7d57	ff 	. 
	rst 38h			;7d58	ff 	. 
	rst 38h			;7d59	ff 	. 
	rst 38h			;7d5a	ff 	. 
	rst 38h			;7d5b	ff 	. 
	rst 38h			;7d5c	ff 	. 
	rst 38h			;7d5d	ff 	. 
	rst 38h			;7d5e	ff 	. 
	rst 38h			;7d5f	ff 	. 
	rst 38h			;7d60	ff 	. 
	rst 38h			;7d61	ff 	. 
	rst 38h			;7d62	ff 	. 
	rst 38h			;7d63	ff 	. 
	rst 38h			;7d64	ff 	. 
	rst 38h			;7d65	ff 	. 
	rst 38h			;7d66	ff 	. 
	rst 38h			;7d67	ff 	. 
	rst 38h			;7d68	ff 	. 
	rst 38h			;7d69	ff 	. 
	rst 38h			;7d6a	ff 	. 
	rst 38h			;7d6b	ff 	. 
	rst 38h			;7d6c	ff 	. 
	rst 38h			;7d6d	ff 	. 
	rst 38h			;7d6e	ff 	. 
	rst 38h			;7d6f	ff 	. 
	rst 38h			;7d70	ff 	. 
	rst 38h			;7d71	ff 	. 
	rst 38h			;7d72	ff 	. 
	rst 38h			;7d73	ff 	. 
	rst 38h			;7d74	ff 	. 
	rst 38h			;7d75	ff 	. 
	rst 38h			;7d76	ff 	. 
	rst 38h			;7d77	ff 	. 
	rst 38h			;7d78	ff 	. 
	rst 38h			;7d79	ff 	. 
	rst 38h			;7d7a	ff 	. 
	rst 38h			;7d7b	ff 	. 
	rst 38h			;7d7c	ff 	. 
	rst 38h			;7d7d	ff 	. 
	rst 38h			;7d7e	ff 	. 
	rst 38h			;7d7f	ff 	. 
	rst 38h			;7d80	ff 	. 
	rst 38h			;7d81	ff 	. 
	rst 38h			;7d82	ff 	. 
	rst 38h			;7d83	ff 	. 
	rst 38h			;7d84	ff 	. 
	rst 38h			;7d85	ff 	. 
	rst 38h			;7d86	ff 	. 
	rst 38h			;7d87	ff 	. 
	rst 38h			;7d88	ff 	. 
	rst 38h			;7d89	ff 	. 
	rst 38h			;7d8a	ff 	. 
	rst 38h			;7d8b	ff 	. 
	rst 38h			;7d8c	ff 	. 
	rst 38h			;7d8d	ff 	. 
	rst 38h			;7d8e	ff 	. 
	rst 38h			;7d8f	ff 	. 
	rst 38h			;7d90	ff 	. 
	rst 38h			;7d91	ff 	. 
	rst 38h			;7d92	ff 	. 
	rst 38h			;7d93	ff 	. 
	rst 38h			;7d94	ff 	. 
	rst 38h			;7d95	ff 	. 
	rst 38h			;7d96	ff 	. 
	rst 38h			;7d97	ff 	. 
	rst 38h			;7d98	ff 	. 
	rst 38h			;7d99	ff 	. 
	rst 38h			;7d9a	ff 	. 
	rst 38h			;7d9b	ff 	. 
	rst 38h			;7d9c	ff 	. 
	rst 38h			;7d9d	ff 	. 
	rst 38h			;7d9e	ff 	. 
	rst 38h			;7d9f	ff 	. 
	rst 38h			;7da0	ff 	. 
	rst 38h			;7da1	ff 	. 
	rst 38h			;7da2	ff 	. 
	rst 38h			;7da3	ff 	. 
	rst 38h			;7da4	ff 	. 
	rst 38h			;7da5	ff 	. 
	rst 38h			;7da6	ff 	. 
	rst 38h			;7da7	ff 	. 
	rst 38h			;7da8	ff 	. 
	rst 38h			;7da9	ff 	. 
	rst 38h			;7daa	ff 	. 
	rst 38h			;7dab	ff 	. 
	rst 38h			;7dac	ff 	. 
	rst 38h			;7dad	ff 	. 
	rst 38h			;7dae	ff 	. 
	rst 38h			;7daf	ff 	. 
	rst 38h			;7db0	ff 	. 
	rst 38h			;7db1	ff 	. 
	rst 38h			;7db2	ff 	. 
	rst 38h			;7db3	ff 	. 
	rst 38h			;7db4	ff 	. 
	rst 38h			;7db5	ff 	. 
	rst 38h			;7db6	ff 	. 
	rst 38h			;7db7	ff 	. 
	rst 38h			;7db8	ff 	. 
	rst 38h			;7db9	ff 	. 
	rst 38h			;7dba	ff 	. 
	rst 38h			;7dbb	ff 	. 
	rst 38h			;7dbc	ff 	. 
	rst 38h			;7dbd	ff 	. 
	rst 38h			;7dbe	ff 	. 
	rst 38h			;7dbf	ff 	. 
	rst 38h			;7dc0	ff 	. 
	rst 38h			;7dc1	ff 	. 
	rst 38h			;7dc2	ff 	. 
	rst 38h			;7dc3	ff 	. 
	rst 38h			;7dc4	ff 	. 
	rst 38h			;7dc5	ff 	. 
	rst 38h			;7dc6	ff 	. 
	rst 38h			;7dc7	ff 	. 
	rst 38h			;7dc8	ff 	. 
	rst 38h			;7dc9	ff 	. 
	rst 38h			;7dca	ff 	. 
	rst 38h			;7dcb	ff 	. 
	rst 38h			;7dcc	ff 	. 
	rst 38h			;7dcd	ff 	. 
	rst 38h			;7dce	ff 	. 
	rst 38h			;7dcf	ff 	. 
	rst 38h			;7dd0	ff 	. 
	rst 38h			;7dd1	ff 	. 
	rst 38h			;7dd2	ff 	. 
	rst 38h			;7dd3	ff 	. 
	rst 38h			;7dd4	ff 	. 
	rst 38h			;7dd5	ff 	. 
	rst 38h			;7dd6	ff 	. 
	rst 38h			;7dd7	ff 	. 
	rst 38h			;7dd8	ff 	. 
	rst 38h			;7dd9	ff 	. 
	rst 38h			;7dda	ff 	. 
	rst 38h			;7ddb	ff 	. 
	rst 38h			;7ddc	ff 	. 
	rst 38h			;7ddd	ff 	. 
	rst 38h			;7dde	ff 	. 
	rst 38h			;7ddf	ff 	. 
	rst 38h			;7de0	ff 	. 
	rst 38h			;7de1	ff 	. 
	rst 38h			;7de2	ff 	. 
	rst 38h			;7de3	ff 	. 
	rst 38h			;7de4	ff 	. 
	rst 38h			;7de5	ff 	. 
	rst 38h			;7de6	ff 	. 
	rst 38h			;7de7	ff 	. 
	rst 38h			;7de8	ff 	. 
	rst 38h			;7de9	ff 	. 
	rst 38h			;7dea	ff 	. 
	rst 38h			;7deb	ff 	. 
	rst 38h			;7dec	ff 	. 
	rst 38h			;7ded	ff 	. 
	rst 38h			;7dee	ff 	. 
	rst 38h			;7def	ff 	. 
	rst 38h			;7df0	ff 	. 
	rst 38h			;7df1	ff 	. 
	rst 38h			;7df2	ff 	. 
	rst 38h			;7df3	ff 	. 
	rst 38h			;7df4	ff 	. 
	rst 38h			;7df5	ff 	. 
	rst 38h			;7df6	ff 	. 
	rst 38h			;7df7	ff 	. 
	rst 38h			;7df8	ff 	. 
	rst 38h			;7df9	ff 	. 
	rst 38h			;7dfa	ff 	. 
	rst 38h			;7dfb	ff 	. 
	rst 38h			;7dfc	ff 	. 
	rst 38h			;7dfd	ff 	. 
	rst 38h			;7dfe	ff 	. 
	rst 38h			;7dff	ff 	. 
	rst 38h			;7e00	ff 	. 
	rst 38h			;7e01	ff 	. 
	rst 38h			;7e02	ff 	. 
	rst 38h			;7e03	ff 	. 
	rst 38h			;7e04	ff 	. 
	rst 38h			;7e05	ff 	. 
	rst 38h			;7e06	ff 	. 
	rst 38h			;7e07	ff 	. 
	rst 38h			;7e08	ff 	. 
	rst 38h			;7e09	ff 	. 
	rst 38h			;7e0a	ff 	. 
	rst 38h			;7e0b	ff 	. 
	rst 38h			;7e0c	ff 	. 
	rst 38h			;7e0d	ff 	. 
	rst 38h			;7e0e	ff 	. 
	rst 38h			;7e0f	ff 	. 
	rst 38h			;7e10	ff 	. 
	rst 38h			;7e11	ff 	. 
	rst 38h			;7e12	ff 	. 
	rst 38h			;7e13	ff 	. 
	rst 38h			;7e14	ff 	. 
	rst 38h			;7e15	ff 	. 
	rst 38h			;7e16	ff 	. 
	rst 38h			;7e17	ff 	. 
	rst 38h			;7e18	ff 	. 
	rst 38h			;7e19	ff 	. 
	rst 38h			;7e1a	ff 	. 
	rst 38h			;7e1b	ff 	. 
	rst 38h			;7e1c	ff 	. 
	rst 38h			;7e1d	ff 	. 
	rst 38h			;7e1e	ff 	. 
	rst 38h			;7e1f	ff 	. 
	rst 38h			;7e20	ff 	. 
	rst 38h			;7e21	ff 	. 
	rst 38h			;7e22	ff 	. 
	rst 38h			;7e23	ff 	. 
	rst 38h			;7e24	ff 	. 
	rst 38h			;7e25	ff 	. 
	rst 38h			;7e26	ff 	. 
	rst 38h			;7e27	ff 	. 
	rst 38h			;7e28	ff 	. 
	rst 38h			;7e29	ff 	. 
	rst 38h			;7e2a	ff 	. 
	rst 38h			;7e2b	ff 	. 
	rst 38h			;7e2c	ff 	. 
	rst 38h			;7e2d	ff 	. 
	rst 38h			;7e2e	ff 	. 
	rst 38h			;7e2f	ff 	. 
	rst 38h			;7e30	ff 	. 
	rst 38h			;7e31	ff 	. 
	rst 38h			;7e32	ff 	. 
	rst 38h			;7e33	ff 	. 
	rst 38h			;7e34	ff 	. 
	rst 38h			;7e35	ff 	. 
	rst 38h			;7e36	ff 	. 
	rst 38h			;7e37	ff 	. 
	rst 38h			;7e38	ff 	. 
	rst 38h			;7e39	ff 	. 
	rst 38h			;7e3a	ff 	. 
	rst 38h			;7e3b	ff 	. 
	rst 38h			;7e3c	ff 	. 
	rst 38h			;7e3d	ff 	. 
	rst 38h			;7e3e	ff 	. 
	rst 38h			;7e3f	ff 	. 
	rst 38h			;7e40	ff 	. 
	rst 38h			;7e41	ff 	. 
	rst 38h			;7e42	ff 	. 
	rst 38h			;7e43	ff 	. 
	rst 38h			;7e44	ff 	. 
	rst 38h			;7e45	ff 	. 
	rst 38h			;7e46	ff 	. 
	rst 38h			;7e47	ff 	. 
	rst 38h			;7e48	ff 	. 
	rst 38h			;7e49	ff 	. 
	rst 38h			;7e4a	ff 	. 
	rst 38h			;7e4b	ff 	. 
	rst 38h			;7e4c	ff 	. 
	rst 38h			;7e4d	ff 	. 
	rst 38h			;7e4e	ff 	. 
	rst 38h			;7e4f	ff 	. 
	rst 38h			;7e50	ff 	. 
	rst 38h			;7e51	ff 	. 
	rst 38h			;7e52	ff 	. 
	rst 38h			;7e53	ff 	. 
	rst 38h			;7e54	ff 	. 
	rst 38h			;7e55	ff 	. 
	rst 38h			;7e56	ff 	. 
	rst 38h			;7e57	ff 	. 
	rst 38h			;7e58	ff 	. 
	rst 38h			;7e59	ff 	. 
	rst 38h			;7e5a	ff 	. 
	rst 38h			;7e5b	ff 	. 
	rst 38h			;7e5c	ff 	. 
	rst 38h			;7e5d	ff 	. 
	rst 38h			;7e5e	ff 	. 
	rst 38h			;7e5f	ff 	. 
	rst 38h			;7e60	ff 	. 
	rst 38h			;7e61	ff 	. 
	rst 38h			;7e62	ff 	. 
	rst 38h			;7e63	ff 	. 
	rst 38h			;7e64	ff 	. 
	rst 38h			;7e65	ff 	. 
	rst 38h			;7e66	ff 	. 
	rst 38h			;7e67	ff 	. 
	rst 38h			;7e68	ff 	. 
	rst 38h			;7e69	ff 	. 
	rst 38h			;7e6a	ff 	. 
	rst 38h			;7e6b	ff 	. 
	rst 38h			;7e6c	ff 	. 
	rst 38h			;7e6d	ff 	. 
	rst 38h			;7e6e	ff 	. 
	rst 38h			;7e6f	ff 	. 
	rst 38h			;7e70	ff 	. 
	rst 38h			;7e71	ff 	. 
	rst 38h			;7e72	ff 	. 
	rst 38h			;7e73	ff 	. 
	rst 38h			;7e74	ff 	. 
	rst 38h			;7e75	ff 	. 
	rst 38h			;7e76	ff 	. 
	rst 38h			;7e77	ff 	. 
	rst 38h			;7e78	ff 	. 
	rst 38h			;7e79	ff 	. 
	rst 38h			;7e7a	ff 	. 
	rst 38h			;7e7b	ff 	. 
	rst 38h			;7e7c	ff 	. 
	rst 38h			;7e7d	ff 	. 
	rst 38h			;7e7e	ff 	. 
	rst 38h			;7e7f	ff 	. 
	rst 38h			;7e80	ff 	. 
	rst 38h			;7e81	ff 	. 
	rst 38h			;7e82	ff 	. 
	rst 38h			;7e83	ff 	. 
	rst 38h			;7e84	ff 	. 
	rst 38h			;7e85	ff 	. 
	rst 38h			;7e86	ff 	. 
	rst 38h			;7e87	ff 	. 
	rst 38h			;7e88	ff 	. 
	rst 38h			;7e89	ff 	. 
	rst 38h			;7e8a	ff 	. 
	rst 38h			;7e8b	ff 	. 
	rst 38h			;7e8c	ff 	. 
	rst 38h			;7e8d	ff 	. 
	rst 38h			;7e8e	ff 	. 
	rst 38h			;7e8f	ff 	. 
	rst 38h			;7e90	ff 	. 
	rst 38h			;7e91	ff 	. 
	rst 38h			;7e92	ff 	. 
	rst 38h			;7e93	ff 	. 
	rst 38h			;7e94	ff 	. 
	rst 38h			;7e95	ff 	. 
	rst 38h			;7e96	ff 	. 
	rst 38h			;7e97	ff 	. 
	rst 38h			;7e98	ff 	. 
	rst 38h			;7e99	ff 	. 
	rst 38h			;7e9a	ff 	. 
	rst 38h			;7e9b	ff 	. 
	rst 38h			;7e9c	ff 	. 
	rst 38h			;7e9d	ff 	. 
	rst 38h			;7e9e	ff 	. 
	rst 38h			;7e9f	ff 	. 
	rst 38h			;7ea0	ff 	. 
	rst 38h			;7ea1	ff 	. 
	rst 38h			;7ea2	ff 	. 
	rst 38h			;7ea3	ff 	. 
	rst 38h			;7ea4	ff 	. 
	rst 38h			;7ea5	ff 	. 
	rst 38h			;7ea6	ff 	. 
	rst 38h			;7ea7	ff 	. 
	rst 38h			;7ea8	ff 	. 
	rst 38h			;7ea9	ff 	. 
	rst 38h			;7eaa	ff 	. 
	rst 38h			;7eab	ff 	. 
	rst 38h			;7eac	ff 	. 
	rst 38h			;7ead	ff 	. 
	rst 38h			;7eae	ff 	. 
	rst 38h			;7eaf	ff 	. 
	rst 38h			;7eb0	ff 	. 
	rst 38h			;7eb1	ff 	. 
	rst 38h			;7eb2	ff 	. 
	rst 38h			;7eb3	ff 	. 
	rst 38h			;7eb4	ff 	. 
	rst 38h			;7eb5	ff 	. 
	rst 38h			;7eb6	ff 	. 
	rst 38h			;7eb7	ff 	. 
	rst 38h			;7eb8	ff 	. 
	rst 38h			;7eb9	ff 	. 
	rst 38h			;7eba	ff 	. 
	rst 38h			;7ebb	ff 	. 
	rst 38h			;7ebc	ff 	. 
	rst 38h			;7ebd	ff 	. 
	rst 38h			;7ebe	ff 	. 
sub_7ebfh:
	rst 38h			;7ebf	ff 	. 
	rst 38h			;7ec0	ff 	. 
	rst 38h			;7ec1	ff 	. 
	rst 38h			;7ec2	ff 	. 
	rst 38h			;7ec3	ff 	. 
	rst 38h			;7ec4	ff 	. 
	rst 38h			;7ec5	ff 	. 
	rst 38h			;7ec6	ff 	. 
	rst 38h			;7ec7	ff 	. 
	rst 38h			;7ec8	ff 	. 
	rst 38h			;7ec9	ff 	. 
	rst 38h			;7eca	ff 	. 
	rst 38h			;7ecb	ff 	. 
	rst 38h			;7ecc	ff 	. 
	rst 38h			;7ecd	ff 	. 
	rst 38h			;7ece	ff 	. 
	rst 38h			;7ecf	ff 	. 
	rst 38h			;7ed0	ff 	. 
	rst 38h			;7ed1	ff 	. 
	rst 38h			;7ed2	ff 	. 
	rst 38h			;7ed3	ff 	. 
	rst 38h			;7ed4	ff 	. 
	rst 38h			;7ed5	ff 	. 
	rst 38h			;7ed6	ff 	. 
	rst 38h			;7ed7	ff 	. 
	rst 38h			;7ed8	ff 	. 
	rst 38h			;7ed9	ff 	. 
	rst 38h			;7eda	ff 	. 
	rst 38h			;7edb	ff 	. 
	rst 38h			;7edc	ff 	. 
	rst 38h			;7edd	ff 	. 
	rst 38h			;7ede	ff 	. 
	rst 38h			;7edf	ff 	. 
	rst 38h			;7ee0	ff 	. 
	rst 38h			;7ee1	ff 	. 
	rst 38h			;7ee2	ff 	. 
	rst 38h			;7ee3	ff 	. 
	rst 38h			;7ee4	ff 	. 
	rst 38h			;7ee5	ff 	. 
	rst 38h			;7ee6	ff 	. 
	rst 38h			;7ee7	ff 	. 
	rst 38h			;7ee8	ff 	. 
	rst 38h			;7ee9	ff 	. 
	rst 38h			;7eea	ff 	. 
	rst 38h			;7eeb	ff 	. 
	rst 38h			;7eec	ff 	. 
	rst 38h			;7eed	ff 	. 
	rst 38h			;7eee	ff 	. 
	rst 38h			;7eef	ff 	. 
	rst 38h			;7ef0	ff 	. 
	rst 38h			;7ef1	ff 	. 
	rst 38h			;7ef2	ff 	. 
	rst 38h			;7ef3	ff 	. 
	rst 38h			;7ef4	ff 	. 
	rst 38h			;7ef5	ff 	. 
	rst 38h			;7ef6	ff 	. 
	rst 38h			;7ef7	ff 	. 
	rst 38h			;7ef8	ff 	. 
	rst 38h			;7ef9	ff 	. 
	rst 38h			;7efa	ff 	. 
	rst 38h			;7efb	ff 	. 
	rst 38h			;7efc	ff 	. 
	rst 38h			;7efd	ff 	. 
	rst 38h			;7efe	ff 	. 
	rst 38h			;7eff	ff 	. 
	rst 38h			;7f00	ff 	. 
	rst 38h			;7f01	ff 	. 
	rst 38h			;7f02	ff 	. 
	rst 38h			;7f03	ff 	. 
	rst 38h			;7f04	ff 	. 
	rst 38h			;7f05	ff 	. 
	rst 38h			;7f06	ff 	. 
	rst 38h			;7f07	ff 	. 
	rst 38h			;7f08	ff 	. 
	rst 38h			;7f09	ff 	. 
	rst 38h			;7f0a	ff 	. 
	rst 38h			;7f0b	ff 	. 
	rst 38h			;7f0c	ff 	. 
	rst 38h			;7f0d	ff 	. 
	rst 38h			;7f0e	ff 	. 
	rst 38h			;7f0f	ff 	. 
	rst 38h			;7f10	ff 	. 
	rst 38h			;7f11	ff 	. 
	rst 38h			;7f12	ff 	. 
	rst 38h			;7f13	ff 	. 
	rst 38h			;7f14	ff 	. 
	rst 38h			;7f15	ff 	. 
	rst 38h			;7f16	ff 	. 
	rst 38h			;7f17	ff 	. 
	rst 38h			;7f18	ff 	. 
	rst 38h			;7f19	ff 	. 
	rst 38h			;7f1a	ff 	. 
	rst 38h			;7f1b	ff 	. 
	rst 38h			;7f1c	ff 	. 
	rst 38h			;7f1d	ff 	. 
	rst 38h			;7f1e	ff 	. 
	rst 38h			;7f1f	ff 	. 
	rst 38h			;7f20	ff 	. 
	rst 38h			;7f21	ff 	. 
	rst 38h			;7f22	ff 	. 
	rst 38h			;7f23	ff 	. 
	rst 38h			;7f24	ff 	. 
	rst 38h			;7f25	ff 	. 
	rst 38h			;7f26	ff 	. 
	rst 38h			;7f27	ff 	. 
	rst 38h			;7f28	ff 	. 
	rst 38h			;7f29	ff 	. 
	rst 38h			;7f2a	ff 	. 
	rst 38h			;7f2b	ff 	. 
	rst 38h			;7f2c	ff 	. 
	rst 38h			;7f2d	ff 	. 
	rst 38h			;7f2e	ff 	. 
	rst 38h			;7f2f	ff 	. 
	rst 38h			;7f30	ff 	. 
	rst 38h			;7f31	ff 	. 
	rst 38h			;7f32	ff 	. 
	rst 38h			;7f33	ff 	. 
	rst 38h			;7f34	ff 	. 
	rst 38h			;7f35	ff 	. 
	rst 38h			;7f36	ff 	. 
	rst 38h			;7f37	ff 	. 
	rst 38h			;7f38	ff 	. 
	rst 38h			;7f39	ff 	. 
	rst 38h			;7f3a	ff 	. 
	rst 38h			;7f3b	ff 	. 
	rst 38h			;7f3c	ff 	. 
	rst 38h			;7f3d	ff 	. 
	rst 38h			;7f3e	ff 	. 
	rst 38h			;7f3f	ff 	. 
	rst 38h			;7f40	ff 	. 
	rst 38h			;7f41	ff 	. 
	rst 38h			;7f42	ff 	. 
	rst 38h			;7f43	ff 	. 
	rst 38h			;7f44	ff 	. 
	rst 38h			;7f45	ff 	. 
	rst 38h			;7f46	ff 	. 
	rst 38h			;7f47	ff 	. 
	rst 38h			;7f48	ff 	. 
	rst 38h			;7f49	ff 	. 
	rst 38h			;7f4a	ff 	. 
	rst 38h			;7f4b	ff 	. 
	rst 38h			;7f4c	ff 	. 
	rst 38h			;7f4d	ff 	. 
	rst 38h			;7f4e	ff 	. 
	rst 38h			;7f4f	ff 	. 
	rst 38h			;7f50	ff 	. 
	rst 38h			;7f51	ff 	. 
	rst 38h			;7f52	ff 	. 
	rst 38h			;7f53	ff 	. 
	rst 38h			;7f54	ff 	. 
	rst 38h			;7f55	ff 	. 
	rst 38h			;7f56	ff 	. 
	rst 38h			;7f57	ff 	. 
	rst 38h			;7f58	ff 	. 
	rst 38h			;7f59	ff 	. 
	rst 38h			;7f5a	ff 	. 
	rst 38h			;7f5b	ff 	. 
	rst 38h			;7f5c	ff 	. 
	rst 38h			;7f5d	ff 	. 
	rst 38h			;7f5e	ff 	. 
	rst 38h			;7f5f	ff 	. 
	rst 38h			;7f60	ff 	. 
	rst 38h			;7f61	ff 	. 
	rst 38h			;7f62	ff 	. 
	rst 38h			;7f63	ff 	. 
	rst 38h			;7f64	ff 	. 
	rst 38h			;7f65	ff 	. 
	rst 38h			;7f66	ff 	. 
	rst 38h			;7f67	ff 	. 
	rst 38h			;7f68	ff 	. 
	rst 38h			;7f69	ff 	. 
	rst 38h			;7f6a	ff 	. 
	rst 38h			;7f6b	ff 	. 
	rst 38h			;7f6c	ff 	. 
	rst 38h			;7f6d	ff 	. 
	rst 38h			;7f6e	ff 	. 
	rst 38h			;7f6f	ff 	. 
	rst 38h			;7f70	ff 	. 
	rst 38h			;7f71	ff 	. 
	rst 38h			;7f72	ff 	. 
	rst 38h			;7f73	ff 	. 
	rst 38h			;7f74	ff 	. 
	rst 38h			;7f75	ff 	. 
	rst 38h			;7f76	ff 	. 
	rst 38h			;7f77	ff 	. 
	rst 38h			;7f78	ff 	. 
	rst 38h			;7f79	ff 	. 
	rst 38h			;7f7a	ff 	. 
	rst 38h			;7f7b	ff 	. 
	rst 38h			;7f7c	ff 	. 
	rst 38h			;7f7d	ff 	. 
	rst 38h			;7f7e	ff 	. 
	rst 38h			;7f7f	ff 	. 
	rst 38h			;7f80	ff 	. 
	rst 38h			;7f81	ff 	. 
	rst 38h			;7f82	ff 	. 
	rst 38h			;7f83	ff 	. 
	rst 38h			;7f84	ff 	. 
	rst 38h			;7f85	ff 	. 
	rst 38h			;7f86	ff 	. 
	rst 38h			;7f87	ff 	. 
	rst 38h			;7f88	ff 	. 
	rst 38h			;7f89	ff 	. 
	rst 38h			;7f8a	ff 	. 
	rst 38h			;7f8b	ff 	. 
	rst 38h			;7f8c	ff 	. 
	rst 38h			;7f8d	ff 	. 
	rst 38h			;7f8e	ff 	. 
	rst 38h			;7f8f	ff 	. 
	rst 38h			;7f90	ff 	. 
	rst 38h			;7f91	ff 	. 
	rst 38h			;7f92	ff 	. 
	rst 38h			;7f93	ff 	. 
	rst 38h			;7f94	ff 	. 
	rst 38h			;7f95	ff 	. 
	rst 38h			;7f96	ff 	. 
	rst 38h			;7f97	ff 	. 
	rst 38h			;7f98	ff 	. 
	rst 38h			;7f99	ff 	. 
	rst 38h			;7f9a	ff 	. 
	rst 38h			;7f9b	ff 	. 
	rst 38h			;7f9c	ff 	. 
	rst 38h			;7f9d	ff 	. 
	rst 38h			;7f9e	ff 	. 
	rst 38h			;7f9f	ff 	. 
	rst 38h			;7fa0	ff 	. 
	rst 38h			;7fa1	ff 	. 
	rst 38h			;7fa2	ff 	. 
	rst 38h			;7fa3	ff 	. 
	rst 38h			;7fa4	ff 	. 
	rst 38h			;7fa5	ff 	. 
	rst 38h			;7fa6	ff 	. 
	rst 38h			;7fa7	ff 	. 
	rst 38h			;7fa8	ff 	. 
	rst 38h			;7fa9	ff 	. 
	rst 38h			;7faa	ff 	. 
	rst 38h			;7fab	ff 	. 
	rst 38h			;7fac	ff 	. 
	rst 38h			;7fad	ff 	. 
	rst 38h			;7fae	ff 	. 
	rst 38h			;7faf	ff 	. 
	rst 38h			;7fb0	ff 	. 
	rst 38h			;7fb1	ff 	. 
	rst 38h			;7fb2	ff 	. 
	rst 38h			;7fb3	ff 	. 
	rst 38h			;7fb4	ff 	. 
	rst 38h			;7fb5	ff 	. 
	rst 38h			;7fb6	ff 	. 
	rst 38h			;7fb7	ff 	. 
	rst 38h			;7fb8	ff 	. 
	rst 38h			;7fb9	ff 	. 
	rst 38h			;7fba	ff 	. 
	rst 38h			;7fbb	ff 	. 
	rst 38h			;7fbc	ff 	. 
	rst 38h			;7fbd	ff 	. 
	rst 38h			;7fbe	ff 	. 
	rst 38h			;7fbf	ff 	. 
	rst 38h			;7fc0	ff 	. 
	rst 38h			;7fc1	ff 	. 
	rst 38h			;7fc2	ff 	. 
	rst 38h			;7fc3	ff 	. 
	rst 38h			;7fc4	ff 	. 
	rst 38h			;7fc5	ff 	. 
	rst 38h			;7fc6	ff 	. 
	rst 38h			;7fc7	ff 	. 
	rst 38h			;7fc8	ff 	. 
	rst 38h			;7fc9	ff 	. 
	rst 38h			;7fca	ff 	. 
	rst 38h			;7fcb	ff 	. 
	rst 38h			;7fcc	ff 	. 
	rst 38h			;7fcd	ff 	. 
	rst 38h			;7fce	ff 	. 
	rst 38h			;7fcf	ff 	. 
	rst 38h			;7fd0	ff 	. 
	rst 38h			;7fd1	ff 	. 
	rst 38h			;7fd2	ff 	. 
	rst 38h			;7fd3	ff 	. 
	rst 38h			;7fd4	ff 	. 
	rst 38h			;7fd5	ff 	. 
	rst 38h			;7fd6	ff 	. 
	rst 38h			;7fd7	ff 	. 
	rst 38h			;7fd8	ff 	. 
	rst 38h			;7fd9	ff 	. 
	rst 38h			;7fda	ff 	. 
	rst 38h			;7fdb	ff 	. 
	rst 38h			;7fdc	ff 	. 
	rst 38h			;7fdd	ff 	. 
	rst 38h			;7fde	ff 	. 
	rst 38h			;7fdf	ff 	. 
	rst 38h			;7fe0	ff 	. 
	rst 38h			;7fe1	ff 	. 
	rst 38h			;7fe2	ff 	. 
	rst 38h			;7fe3	ff 	. 
	rst 38h			;7fe4	ff 	. 
	rst 38h			;7fe5	ff 	. 
	rst 38h			;7fe6	ff 	. 
	rst 38h			;7fe7	ff 	. 
	rst 38h			;7fe8	ff 	. 
	rst 38h			;7fe9	ff 	. 
	rst 38h			;7fea	ff 	. 
	rst 38h			;7feb	ff 	. 
	rst 38h			;7fec	ff 	. 
	rst 38h			;7fed	ff 	. 
	rst 38h			;7fee	ff 	. 
	rst 38h			;7fef	ff 	. 
	rst 38h			;7ff0	ff 	. 
	rst 38h			;7ff1	ff 	. 
	rst 38h			;7ff2	ff 	. 
	rst 38h			;7ff3	ff 	. 
	rst 38h			;7ff4	ff 	. 
	rst 38h			;7ff5	ff 	. 
	rst 38h			;7ff6	ff 	. 
	rst 38h			;7ff7	ff 	. 
	rst 38h			;7ff8	ff 	. 
	rst 38h			;7ff9	ff 	. 
	rst 38h			;7ffa	ff 	. 
	rst 38h			;7ffb	ff 	. 
	rst 38h			;7ffc	ff 	. 
	rst 38h			;7ffd	ff 	. 
	rst 38h			;7ffe	ff 	. 
	rst 38h			;7fff	ff 	. 
