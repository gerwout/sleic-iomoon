; =============================================================================
; IO Moon Pinball - Fully Annotated 80188 CPU ROM Disassembly
; =============================================================================
;
; Machine:     SLEIC IO Moon Pinball (1996)
; Developer:   Luis Gosálbez Carrasco
; Company:     CREACIONES E INVESTIGACIONES ELECTRONICAS, S.L. (SLEIC)
; Location:    Av. Valdelaparra 3, Pol. Ind. Alcobendas, 28100 Madrid
; CPU:         Intel/AMD 80C188 (16-bit) + Z80A coprocessor (8-bit, 8MHz)
; ROM:         1MB total = 2x 27C040 (512KB each)
;              ROM1 (0x80000-0xFFFFF): Code + upper graphics
;              ROM2 (0x00000-0x7FFFF): DMD graphics data
; Display:     128x32 DMD (Dot Matrix Display), 2-plane
; Theme:       Space exploration / Jupiter mission
;
; Architecture:
;   80188 (main):  Game logic, DMD display, state machine, scoring
;   Z80 (copro):   Switch matrix scanning, lamp matrix, solenoids, sound
;   Communication: Shared RAM at segment 4000h, bus arbitration via HOLD/HLDA
;
; Memory Map:
;   4000h:0000+  Work RAM (shared 80188<->Z80)
;   4130h:0000+  Game configuration data
;   4134h:0000+  Game configuration (146 refs)
;   4137h:0000+  Game mode data (32 refs)
;   413Ch:0000+  Game state variables (920 refs) - primary shared data
;   4152h:0000+  Stack segment (SP init = 0x0205)
;   A000h:0000+  DMD controller hardware registers
;   D000h:0000+  Main program code (8532 instructions)
;   E000h:0000+  Player display code (430 instructions)
;   F000h:0000+  System code / BIOS (1491 instructions)
;   FFF0h:0000+  Boot code / reset vector
;
; Game Features: MOONLIGHT, SUNSHINE, STARWAY modes
;   3 Flippers, 5 Pop Bumpers, 5 Drop Targets, 2 Ramps, 2 Scoops
;   Jupiter ball lock, Multiball, ORBITS spelling, Monolith Messages
;   Match/Lottery system, 4-player support, Bilingual (ES/EN)
;
; Text Encoding: Custom character mapping
;   0x0A=space  0x0B='A'  0x0C='B' ... 0x18='N'  0x19='Ñ'
;   0x1A='O' ... 0x25='Z'  0x2C=','  0x2E='.'  0x2F=newline  0x00=terminator
;
; Total: ~10,458 instructions (~30KB code, ~3% of ROM)
;        ~97% is DMD graphics and data tables
; =============================================================================

; =============================================================================
; STRING REFERENCES (auto-detected, includes both ASCII and custom encoding)
; Note: Most 'strings' in ROM2 (0x00000-0x7FFFF) are actually DMD bitmap data
; Real text strings use custom encoding (see header) in ROM1 (0x80000+)
; =============================================================================
;  0278e: "!gx@?"
;  03333: ">rvG"
;  03e65: "}8!q"
;  04747: "~85||"
;  04758: "(-||"
;  04b1f: "<|xr"
;  04f0a: "`?L7"
;  06f33: "wrtq"
;  06fb6: "`lo?"
;  08014: "s 4/"
;  086e1: "<yGl"
;  09b62: "t AD"
;  09b83: "?!#_"
;  09c09: "@FN "
;  0b419: "v\p`"
;  0d8cc: "-sRE`"
;  0f0a1: "r(sx"
;  0f90b: "p0AIl"
;  142fb: "| AE"
;  14c08: " Hx="
;  14f9e: "Qm-H"
;  14fae: "Cu!("
;  152e4: "=7F@"
;  155e9: "P `?"
;  15789: "To_A "
;  2578f: "80 E"
;  26772: "07!'T"
;  2777c: "[@w<"
;  277e9: " 2@@0"
;  2898e: "8gxi"
;  28bad: "B_|?"
;  29394: "`@;$"
;  29966: "8^_G"
;  29bef: "[N<w"
;  2c3b0: "o`|*L"
;  2ec3d: "og`&"
;  2f498: ">?9`"
;  31e85: "@x|L"
;  32aa7: "p;0|"
;  35f14: "d<xq"
;  35f24: "6<|q"
;  41a85: "^o~~"
;  48822: "^o~~"
;  6479c: "djcS"
;  64fa9: "djcS"
;  657b6: "djcS"
;  65fc3: "djcS"
;  667d0: "djcS"
;  66fdd: "djcS"
;  677ea: "djcS"
;  67ff7: "djcS"
;  68804: "djcS"
;  69011: "djcS"
;  6981e: "djcS"
;  6a02b: "djcS"
;  6a838: "djcS"
;  809b6: "wxyz{|}~"
;  809ca: "%&)*9:1256-."
;  809dc: "?@cd"
;  809e2: "_`ef"
;  809ef: " !"WXstABMNGHIJKL"
;  80a06: "ijklmnopqr"
;  80a56: "STUVWXGHIJKLMNMN"
;  80a7e: "?@ABij_`abcdefgh"
;  80a97: " !"%&)*-.1256'&+*/.32769:stklmnopqr"
;  82f64: "fs0?"
;  82f74: "fs00g"
;  82f84: "f#00c"
;  83184: "f#00c"
;  84825: "gNNNN"
;  84836: "____"
;  84846: "@@@@"
;  84a25: "`@@@@"
;  84a36: "@@@@"
;  84a46: "@@@@"
;  85bb5: "@P2Ca"
;  85c02: "Y-<g"
;  85c12: "Y- d"
;  90192: "<G8 "
;  90199: "$D) "
;  901ca: "<G8 "
;  901d1: "$D) "
;  9022d: "BJB@"
;  90232: "BDB@"
;  90241: "zDz@"
;  90255: "BJB@"
;  9025a: "BDB@"
;  90269: "zDz@"
;  902a5: "@%(@9(@%"
;  902ae: "@%(@9/x"
;  902bd: "@%(@9(@%"
;  902c6: "@%(@9/x"
;  90d3f: " I)j"
;  90d4f: " I)J@"
;  90d5f: " I+J@"
;  90d7a: "@y% "
;  90d8f: "-I+O"
;  90d9f: ")I)H"
;  90daa: "A)% "
;  90daf: ")I)H"
;  90dba: "A)% "
;  90dbf: ")I)H"
;  90dca: "A)% "
;  90dcf: ")I)K"
;  90dda: "A)% "
;  90ddf: "-I)j"
;  91755: "?<|<?"
;  91765: "~<<<?"
;  91786: "<<<?"
;  917ec: "8 ~<"
;  9211e: ">g<x"
;  931c7: "<|x>"
;  931d7: "<||>"
;  931e7: "<||<"
;  935cd: "<xx>"
;  935dd: "<xx~"
;  935ed: "<x|~"
;  97eb8: "_E)J"
;  986a4: "@E,("
;  98e53: "&2_e"
;  98e60: "AAt**P"
;  98e70: "AAT+jP"
;  98e81: "AT-Z_e"
;  98e92: "V-Z@"
;  99dab: "AAh{"
;  99ddb: "AAhy"
;  9a4c0: "RA  "
;  9a4d0: "RA  "
;  9a4db: "@@H@"
;  9a4e0: "RA  "
;  9a4f0: """  "
;  9acfe: "@@Hd"
;  9ad0e: "~@H'"
;  9ae0e: "t((("
;  9ae1e: "T(((4,"
;  9ae2e: "T(((4,"
;  9ae3e: "V(((4,"
;  9ae4e: "v(((4,"
;  9ae5f: "(((4,"
;  9b01f: "888<<"
;  9b02f: "888<<"
;  9b03f: "888<<"
;  9b04f: "888<<"
;  9b05f: "888<<"
;  9b425: "888<<"
;  9b435: "888<<"
;  9b445: "888<<"
;  9b455: "888<<"
;  9b465: "888<<"
;  9bddb: "AAB""
;  9bdeb: "A@~#"
;  9bdfb: "AG~#"
;  9be0b: "AGB""
;  9be1b: "AAB""
;  9be3b: "}>B#"
;  9bfdb: "AAB""
;  9bfeb: "A@~#"
;  9bffb: "AG~#"
;  9c00b: "AGB""
;  9c01b: "AAB""
;  9c03b: "}>B#"
;  9e602: "6g6f"
;  9e612: "l766"
;  9e6f8: "`c6{"
;  9e708: "`c6{"
;  9e718: "`~6j"
;  9e728: "`f6j"
;  9e748: "`ccn"
;  9e802: "6g6f"
;  9e812: "l766"
;  9e8f8: "`c6{"
;  9e908: "`c6{"
;  9e918: "`~6j"
;  9e928: "`f6j"
;  9e948: "`ccn"
;  9ec08: "6g6f"
;  9ec18: "l766"
;  9ecfe: "`c6{"
;  9ed0e: "`c6{"
;  9ed1e: "`~6j"
;  9ed2e: "`f6j"
;  9ed4e: "`ccn"
;  a0027: "@@@@"
;  a002f: "@@@@"
;  a06ea: "8888"
;  a0760: "|888"
;  a0769: "|888"
;  a0847: "`` @"
;  a0850: "`` @"
;  a0889: "`` @"
;  a0892: "`` @"
;  a08e9: "llH$"
;  a08f2: "llH$"
;  a090a: "ll$H"
;  a0913: "ll$H"
;  a092e: "8`d8"
;  a0937: "8`d8"
;  a096d: "<~ffffff~<"
;  a0979: "<~ffffff~<"
;  a0a17: "8pf~~"
;  a0a23: "8pf~~"
;  a0a3f: "~~``|~"
;  a0a4b: "~~``|~"
;  a0a6a: "<p`|~ff~<"
;  a0a76: "<p`|~ff~<"
;  a0abd: "<~ff<<ff~<"
;  a0ac9: "<~ff<<ff~<"
;  a0ae7: "<~ff~>"
;  a0af3: "<~ff~>"
;  a0b3c: "<<4444~~f"
;  a0b48: "<<4444~~f"
;  a0b65: "|~fn||nf~|"
;  a0b71: "|~fn||nf~|"
;  a0b90: ">v````v>"
;  a0b9c: ">v````v>"
;  a0bb9: "x|lnffnl|x"
;  a0bc5: "x|lnffnl|x"
;  a0be3: "~~``xx``~~"
;  a0bef: "~~``xx``~~"
;  a0c0d: "~~``xx````"
;  a0c19: "~~``xx````"
;  a0c38: ">v``nfv>"
;  a0c44: ">v``nfv>"
;  a0c61: "ffff~~ffff"
;  a0c6d: "ffff~~ffff"
;  a0cdf: "fnlxppxlnf"
;  a0ceb: "fnlxppxlnf"
;  a0d09: "````````~~"
;  a0d15: "````````~~"
;  a0d33: "bbv~~~jjjb"
;  a0d3f: "bbv~~~jjjb"
;  a0d5d: "bbrz~~nfbb"
;  a0d69: "bbrz~~nfbb"
;  a0d88: "bbrz~~nfb"
;  a0d94: "bbrz~~nfb"
;  a0db1: "<~ffffff~<"
;  a0dbd: "<~ffffff~<"
;  a0ddb: "x|nfn|x```"
;  a0de7: "x|nfn|x```"
;  a0e05: "<~fffff|>"
;  a0e11: "<~fffff|>"
;  a0e2f: "x|nfn|xlnf"
;  a0e3b: "x|nfn|xlnf"
;  a0e59: ">~ppx<"
;  a0e65: ">~ppx<"
;  a0ead: "fffffff~~<"
;  a0eb9: "fffffff~~<"
;  a0ed7: "ffvv66>>"
;  a0ee3: "ffvv66>>"
;  a0f01: "bbjj~>>>66"
;  a0f0d: "bbjj~>>>66"
;  a0f2b: "fff<"
;  a0f31: "<fff"
;  a0f37: "fff<"
;  a0f3d: "<fff"
;  a0f55: "ffff<<"
;  a0f61: "ffff<<"
;  a0fd4: ">v```v><p"
;  a0fe0: ">v```v><p"
;  a0fff: "8p``p8"
;  a100b: "8p``p8"
;  a11a6: "8pf~<"
;  a11b2: "8pf~<"
;  a11f8: "0~~0"
;  a1204: "0~~0"
;  a1286: "$$$$"
;  a128e: "$$$$"
;  a133a: " 8$$"
;  a1342: " 8$$"
;  a13cf: "<~~~fffffff~~~<"
;  a13e2: "<<$$$$$$$$$<<"
;  a1416: "<<<<"
;  a1447: "<~~~ff"
;  a1450: "6v~~~|"
;  a145a: "<<<"""
;  a1463: "6<<<"
;  a1483: "<~~~ff"
;  a148c: "ff~~~<"
;  a1496: "<<<&&"
;  a149e: "&&<<<"
;  a14c3: ">6vf"
;  a14fb: "~~~~``|~"
;  a1504: "f~~~~<"
;  a150e: "<<<  <"
;  a1516: "$<<<<"
;  a1537: "<~~~ff`~fff~~~<"
;  a154a: "<<$$$ <$$$<<<"
;  a1573: "????36"
;  a15af: "<~~~fff<fff~~~<"
;  a15c2: "<<$$$$"
;  a15c9: "$$$$<<"
;  a15eb: "<~~~fff~"
;  a15f4: "ff~~~<"
;  a15fe: "<<$$$$<"
;  a1606: "$$$<<"
;  a1627: "<~~~fffffff~~~="
;  a163a: "<<$$$$$$$$$<<"
;  a166e: "<<<="
;  a169f: "<~~~ff"
;  a16a8: "6v~~~}"
;  a16b2: "<<$"""
;  a16bb: "2<<<"
;  a16db: "<~~~ff"
;  a16e4: "ff~~~="
;  a16ee: "<<$"""
;  a16f6: """$<<"
;  a171b: ">6vf"
;  a1753: "~~~~``|~"
;  a175c: "f~~~~="
;  a1766: "<<$  8<"
;  a176e: ""<$<<"
;  a178f: "<~~~ff`~fff~~~="
;  a17a2: "<<$"" <"""$<<"
;  a17cb: "????36"
;  a1807: "<~~~fff<fff~~~="
;  a181a: "<<$""""
;  a1821: """"$<<"
;  a1843: "<~~~fff~"
;  a184c: "ff~~~="
;  a1856: "<<$"""<"
;  a185e: """$<<"
;  a248b: "8DDD"
;  a2490: "DDD8"
;  a2497: "8DDD"
;  a249c: "DDD8"
;  a24e3: "8@@@8"
;  a24ef: "8@@@8"
;  a2534: "DDD8"
;  a2540: "DDD8"
;  a255d: "8@@@8"
;  a2569: "8@@@8"
;  a2587: "8@@@8DDD8"
;  a2593: "8@@@8DDD8"
;  a25db: "8DDD8DDD8"
;  a25e7: "8DDD8DDD8"
;  a2605: "8DDD8"
;  a2611: "8DDD8"
;  a2659: "8DDD"
;  a265e: "DDD8"
;  a2665: "8DDD"
;  a266a: "DDD8"
;  a26b1: "8@@@8"
;  a26bd: "8@@@8"
;  a2702: "DDD8"
;  a270e: "DDD8"
;  a272b: "8@@@8"
;  a2737: "8@@@8"
;  a2755: "8@@@8DDD8"
;  a2761: "8@@@8DDD8"
;  a27a9: "8DDD8DDD8"
;  a27b5: "8DDD8DDD8"
;  a27d3: "8DDD8"
;  a27df: "8DDD8"
;  a27fe: "8DDDD"
;  a2804: "DDDD8"
;  a280e: "8DDDD"
;  a2814: "DDDD8"
;  a286f: "8@@@@8"
;  a287f: "8@@@@8"
;  a28d7: "DDDD8"
;  a28e7: "DDDD8"
;  a28f6: "9999"
;  a290c: "8@@@@8"
;  a291c: "8@@@@8"
;  a2942: "8@@@@8DDDD8"
;  a2952: "8@@@@8DDDD8"
;  a29ae: "8DDDD8DDDD8"
;  a29be: "8DDDD8DDDD8"
;  a29e4: "8DDDD8"
;  a29f4: "8DDDD8"
;  a2a1a: "8DDDD"
;  a2a20: "DDDD8"
;  a2a2a: "8DDDD"
;  a2a30: "DDDD8"
;  a2a8b: "8@@@@8"
;  a2a9b: "8@@@@8"
;  a2af3: "DDDD8"
;  a2b03: "DDDD8"
;  a2b12: "9999"
;  a2b28: "8@@@@8"
;  a2b38: "8@@@@8"
;  a2b5e: "8@@@@8DDDD8"
;  a2b6e: "8@@@@8DDDD8"
;  a2bca: "8DDDD8DDDD8"
;  a2bda: "8DDDD8DDDD8"
;  a2c00: "8DDDD8"
;  a2c10: "8DDDD8"
;  a2cca: "88p`q"
;  a2eca: "<<x`y"
;  a309f: "`pppp<x"
;  a31a1: "`pp<>"
;  a33a1: "xp|>>"
;  a4d4d: "xc6n"
;  a4d5c: "3pc6ll"
;  a4d6c: "3`c6ll"
;  a4d7c: "3`c6n"
;  a5b7f: "d)h:"
;  a5bb8: "PiB"n"
;  a5c2f: "`#HFJ"
;  a6c6a: "p8`a"
;  a6c7a: "p8pa"
;  a6c8a: "p8pa"
;  a6c9a: "p8pa"
;  a6e7a: "x<xq"
;  a6e8a: "x<xq"
;  a6e9a: "x<xq"
;  a71f9: "x>??"
;  a7209: "x>??"
;  a7219: "x>??"
;  a7229: "p>??"
;  a7239: "0>??"
;  a7249: "0>??"
;  a7259: "2>??"
;  a7269: "">??"
;  a944f: "00``"
;  a9461: "00``"
;  a9590: "``````````"
;  a95a2: "``````````"
;  a95c5: "0``````````0"
;  a95d7: "0``````````0"
;  a961c: "??????????????????"
;  a9668: "````"
;  a967a: "````"
;  a9760: "???????????"
;  a97b1: "````"
;  a97c3: "````"
;  a9851: "?9p```p9"
;  a9863: "?9p```p9"
;  a9924: "?0``p?"
;  a992b: "?yp``p?"
;  a9936: "?0``p?"
;  a993d: "?yp``p?"
;  a995c: "````"
;  a996e: "````"
;  a9991: "9````p?"
;  a99a3: "9````p?"
;  a9a3d: "Dl88lD"
;  a9ab8: "~@@x"
;  a9ac2: "~@@x"
;  a9b28: "8`8D"
;  a9bed: "@8@/@9@"
;  a9c09: "@?~ "
;  a9d61: "88>?"
;  a9d8b: "(8./"
;  aa136: "BZI@"
;  aa146: "2VI0"
;  aa166: "rRFp"
;  aa1a9: "!(J%"
;  aa1b9: "-&J9"
;  aa1c7: "B(%!z%"
;  aa25a: "h@N&"
;  aa26a: "HH@ "
;  aa2e9: "!(J%"
;  aa2f9: "-&J9"
;  aa307: "B(%!z%"
;  aa3d2: "?0~>??"
;  aa3e1: "p  @`  "
;  aa3f1: "@  @@"
;  aa402: "& L@"
;  aa412: "  @@"
;  aa422: "  @C"
;  aa432: "'&NN"
;  aa61a: "%iZ@"
;  aa628: "Q"=)K"
;  aa75b: ")I%($"
;  aa76b: ".I=&'$"
;  aa77c: "y%!$"
;  aaa19: "J%)F"
;  aaa29: "J!.e"
;  aaa39: "z%)D"
;  aaa78: "g:\c"
;  aaaa3: ""JR="
;  aaae9: "0s(1"
;  aaaf8: ")@C(B"
;  aab07: "NGpd"
;  aab16: "RBAHG"
;  aab1c: "JJBN"
;  aab27: "LF0D"
;  aadf6: "BZI@"
;  aae06: "2VI0"
;  aae26: "rRFp"
;  aae69: "!(J%"
;  aae79: "-&J9"
;  aae87: "B(%!z%"
;  aafa9: "!(J%"
;  aafb9: "-&J9"
;  aafc7: "B(%!z%"
;  ab092: "?0~>??"
;  ab0c2: ">8|q"
;  ab0d2: "?8~p"
;  ab0e2: "?8~s"
;  ab2da: "%iZ@"
;  ab2e8: "Q"=)K"
;  ab41b: ")I%($"
;  ab42b: ".I=&'$"
;  ab43c: "y%!$"
;  ab6d9: "J%)F"
;  ab6e9: "J!.e"
;  ab6f9: "z%)D"
;  ab738: "g:\c"
;  ab763: ""JR="
;  ab7a9: "0s(1"
;  ab7b8: ")@C(B"
;  ab7c7: "NGpd"
;  ab7d6: "RBAHG"
;  ab7dc: "JJBN"
;  ab7e7: "LF0D"
;  ae56f: ""e6^x"
;  ae57f: "be"B@"
;  ae59f: "by"B@"
;  ae5af: "2A6B@"
;  ae5cb: "4Q0P"
;  b008f: "m-BR"
;  b0095: "U+bR"
;  b009b: "E+B^"
;  b00a1: "E)BR"
;  b00ef: "m-BR"
;  b00f5: "U+bR"
;  b00fb: "E+B^"
;  b0101: "E)BR"
;  b02ff: "ITeE"
;  b0327: "ITeE"
;  b0377: "|DDQ"
;  b039f: "|DDQ"
;  b0936: "|>8q"
;  b0946: "~~8q"
;  b0956: "~~8q"
;  b0b36: "|>8q"
;  b0b46: "~~8q"
;  b0b56: "~~8q"
;  b0d8b: "%/y#"
;  b0d9b: "%)I'"
;  b0da8: "JMX%)I-X"
;  b0db7: ")JIH%)I)H"
;  b0dc7: ")JIH%)I)H"
;  b0dd7: ")JIH%)I)H"
;  b0deb: "%)I)H"
;  b0dfb: "%)I)H"
;  b0e0b: "%)I)H"
;  b0e1b: "%)I)H"
;  b0e2b: "%)I)H"
;  b0e37: ")JIx%)I)H"
;  b0e48: "jMX%-I-X"
;  b127a: "~<p?"
;  b147a: "~?|?"
;  b1695: "8 ~<"
;  b2a11: "`|0x"
;  b2a21: "`>0x"
;  b2c11: "p|8~"
;  b2c21: "p>8~"
;  b3249: "<|x>"
;  b3259: "<||>"
;  b3269: "<||<"
;  b364f: "<xx>"
;  b365f: "<xx~"
;  b366f: "<x|~"
;  b7c38: "88~8"
;  b7e5d: "()C@PP"
;  b7eba: "PRc%"
;  b82d0: " !AB"
;  b82e0: " !AB"
;  b82f0: " !"B"
;  b8300: " !"C"
;  b8669: "()C@PP"
;  b8e75: "()C@PP"
;  b9681: "()C@PP"
;  b9ee8: "l@c`"
;  ba4fe: "( A@"
;  ba50e: "( A@"
;  ba51e: "( A@"
;  ba52e: "D B "
;  bb248: "`n<v"
;  bb258: "`fF;#2"
;  bb29a: "f33&"
;  bb448: "`n<v"
;  bb458: "`fF;#2"
;  bb49a: "f33&"
;  bbe7c: ")$|x"
;  bbeac: ")%)JR"
;  bbebc: ")%)JR"
;  bbecc: ")%)JR"
;  bbedc: ")%9JR"
;  bbeec: ")%?JR"
;  bbefc: ")% JR"
;  bbf0c: ")% JR"
;  bbf1c: ")% JR"
;  bbf2c: ")%/JR"
;  bdb47: "<`8|"
;  bdd47: "<`8|"
;  be14d: "<`8|"
;  be27e: "6g6f"
;  be28e: "l766"
;  be47e: "6g6f"
;  be48e: "l766"
;  be884: "6g6f"
;  be894: "l766"
;  d016e: "PSQRVWU"
;  d01dc: "]_^ZY[X"
;  d0250: "PSQRVWU"
;  d0328: "]_^ZY[X"
;  d0344: "PSQRVWU"
;  d03b7: "]_^ZY[X"
;  d07a9: "(C) SLEIC 1.994(C) CREACIONES E INVESTIGACIONES ELECTRONICAS..."
;  d0c19: ")1*$->$"
;  d0dfb: "C?D?E?K?L?M?S?T?U?"
;  d0e39: "@ !#a@"
;  d0e40: "C?`!c"
;  d0e50: "!!$aA"
;  d0e56: "D?a!d"
;  d0e66: ""!%aB"
;  d0e6c: "E?b!e"
;  d0e7c: "(!+aH"
;  d0e82: "K?h!k"
;  d0e92: "2!5bR"
;  d0f00: ")1,aI"
;  d0f16: "*1-aJ"
;  d0f2c: "013aP"
;  d0f46: "Q(T?q"
;  d1150: ")!,aI"
;  d1164: "*!-aJ"
;  d1178: "013aP"
;  d118e: "114aQ"
;  d164c: "C?D?E?K?L?M?S?T?U?"
;  d16bc: " q#A@"
;  d16e8: ""q%AB"
;  d1714: ")q,aI"
;  d172a: "*!-1J"
;  d1730: "M?jdme"
;  d1cc1: "  !#a@"
;  d1cd8: "!!$aA"
;  d1f01: " C D L?"
;  d1f1f: " C(D("
;  d1f35: " C,D,"
;  d1f4b: " C0D0"
;  d1f61: " C8D8"
;  d1f85: " C<D<"
;  d1f9b: " C?D?"
;  d20f6: "E?K?M?S?T?U?"
;  d210e: "!!$aA"
;  d2114: "D?a!d"
;  d2124: ""!%aB"
;  d212a: "E?b!e"
;  d213a: "2!51R"
;  d2140: "U?rdue"
;  d2292: "C?D?E?K?L?M?S?T?U?"
;  d2304: " 1#q@"
;  d230a: "C?`!c"
;  d231a: "!1$qA"
;  d2320: "D?a!d"
;  d2330: ""1%qB"
;  d2336: "E?b!e"
;  d2346: "(!+1H"
;  d234c: "K?hdke"
;  d235c: ")1,aI"
;  d2372: "*1-aJ"
;  d25b1: " C?D?E?K?L?M?S?T?U?"
;  d25f1: "!!$aA"
;  d25f7: "D?a!d"
;  d2607: ""!%aB"
;  d260d: "E?b!e"
;  d2679: "D$E%"
;  d267f: "D(E)"
;  d2685: "D,E-"
;  d268b: "D0E1"
;  d2691: "D8E9"
;  d2697: "D?E?"
;  d26b1: "!!$aA"
;  d26b7: "D?a!d"
;  d26c7: ""!%aB"
;  d26cd: "E?b!e"
;  d2739: "D$E%"
;  d273f: "D(E)"
;  d2745: "D,E-"
;  d274b: "D0E1"
;  d2751: "D8E9"
;  d2757: "D?E?"
;  d2771: "(!+1H"
;  d2777: "K?hdke"
;  d2787: ")Q,AI"
;  d279d: "*Q-AJ"
;  d29f2: "$K?L?M?"
;  d2a02: "(!+1H"
;  d2a08: "K?hdke"
;  d2a18: ")Q,AI"
;  d2a2e: "*Q-AJ"
;  d2c83: "$K?L?M?"
;  d2c96: "(!+1H"
;  d2c9c: "K?hdke"
;  d2cac: ")Q,AI"
;  d2cc2: "*Q-AJ"
;  d2f17: "$K?L?M?"
;  d2f83: "7h@Ph"
;  d353e: "@Phl"
;  d3554: "@Phl"
;  d357e: "@Php"
;  d3594: "@Php"
;  d3693: "@PhC"
;  d4172: "h<Ah"
;  d4183: "h<Ah"
;  d41dc: "h<Ah"
;  d41ed: "h<Ah"
;  d4246: "h<Ah"
;  d4257: "h<Ah"
;  d42b0: "h<Ah"
;  d42c1: "h<Ah"
;  d4319: "h<Ah"
;  d432a: "h<Ah"
;  d4382: "h<Ah"
;  d4393: "h<Ah"
;  d43eb: "h<Ah"
;  d43fc: "h<Ah"
;  d4454: "h<Ah"
;  d4465: "h<Ah"
;  d4761: "xh@Ph3"
;  d479e: ";h@PhX"
;  d4937: "@PhD"
;  d4ad9: "@Ph3"
;  d4b19: "@PhD"
;  d4c37: "@PhX"
;  d4d7c: "h@Ph,"
;  d4d90: "h@Ph"
;  d4df1: "h@Ph,"
;  d4e05: "h@Ph"
;  d4e7b: "h@Ph,"
;  d4e8f: "h@Ph"
;  d4f2f: "h@Ph,"
;  d4f43: "h@Ph"
;  d5009: "Yh@Ph,"
;  d501e: "RPh@Ph,"
;  d530d: "h<AP"
;  d533e: "h<AP"
;  d5934: "0h@Ph"
;  d594f: "%h@Ph"
;  d5992: "]h@Ph"
;  d5fda: "RPh<Ah"
;  d5fea: "h<Ah"
;  d6035: "RPh<Ah"
;  d6045: "h<Ah"
;  d646b: "@Ph<"
;  d647b: "@Ph?"
;  d648b: "@Ph>"
;  d649b: "@Ph="
;  d64ab: "@Ph@"
;  d64bb: "@PhA"
;  d64cb: "@PhB"
;  d6511: "@Ph "
;  d6523: "@Ph$"
;  d6535: "@Ph,"
;  d6547: "@Phl"
;  d6559: "@Php"
;  d656b: "@Pht"
;  d657d: "@Ph|"
;  d658f: "@Phx"
;  d65a2: "@PhC"
;  d65b0: "@PhC"
;  d65d2: "Zh@Ph("
;  d65e2: "@Ph("
;  d6712: "@Ph<"
;  d6723: "@Ph?"
;  d673a: "@PhA"
;  d683e: "@PhD"
;  d6885: "@Phi"
;  d8299: "h@Phl"
;  d82ad: "RPh@Phl"
;  d834b: "h@Ph "
;  d835f: "RPh@Ph "
;  d8525: "h@Ph "
;  d8539: "RPh@Ph "
;  d8629: "h@Ph$"
;  d863d: "RPh@Ph$"
;  d86bd: "h@Pht"
;  d86d1: "RPh@Pht"
;  d8852: "h}6h"
;  d88f9: "hr6h"
;  d8d16: "h@Ph="
;  d8d3d: "h@Ph="
;  d8da0: "h@Ph="
;  d8dbe: "RPh<Ah"
;  d8dce: "h<Ah"
;  d8ef7: "h@Ph>"
;  d8f3b: "Ph@Ph>"
;  d8f77: "Yh@Ph>"
;  d8fd8: "h@Ph>"
;  d8ff6: "RPh<Ah"
;  d9006: "h<Ah"
;  d9233: "h@Phx"
;  d9247: "RPh@Phx"
;  d9725: "\#~#"
;  d9732: "$*$F$b$U"
;  d9862: "sFj<"
;  d9886: "h@Ph|"
;  d989a: "RPh@Ph|"
;  d9d65: "YjPh"
;  d9dea: "YjPh"
;  d9e24: "hL*h"
;  da4d0: "t1h@PhB"
;  dac43: "h<Ah"
;  dac53: "h<Ah"
;  dacc6: "h<Ah"
;  dacd6: "h<Ah"
;  dad9c: "h<Ah"
;  dadac: "h<Ah"
;  dadee: "h<Ah"
;  dadfe: "h<Ah"
;  daecd: "hV h"
;  daf93: "b<r<b<b<b<b<"
;  dafd6: "h<Ah"
;  dafe7: "h<Ah"
;  db011: "hR$h"
;  db09d: "7tDj"
;  db0bb: "6t&j"
;  db0ff: "h<Ah"
;  db110: "h<Ah"
;  db140: "hT"h"
;  db204: "h<Ah"
;  db215: "h<Ah"
;  db245: "hP&h"
;  db272: "t,=""
;  db312: "h<Ah"
;  db323: "h<Ah"
;  db348: "h<Ah"
;  db359: "h<Ah"
;  db4c8: "h<Ah"
;  db4d8: "h<Ah"
;  db6a3: "h<Ah"
;  db6b3: "h<Ah"
;  db844: "h@Ph("
;  db890: "h@Ph("
;  db89e: "RPh<Ah"
;  db8b1: "h<Ah"
;  db902: "h@Ph("
;  db952: "h@Ph("
;  db964: "RPh<Ah"
;  db977: "h<Ah"
;  dbab5: "h<Ah"
;  dbace: "j~h<Ah"
;  dbbb9: "aIj&"
;  dbc02: "I%I)I-I1I5I"
;  dbdc0: "@Ph@"
;  dbe08: "@PhB"
;  dbf28: "@Ph@"
;  dbf70: "@PhB"
;  dc213: "LO?O/OYO"
;  dd71d: "h@Ph"
;  dd72d: "h@Ph"
;  dd746: "h@PP"
;  dd765: "h@PP"
;  dd78f: "h@PP"
;  dd983: "h@PP"
;  ddd5e: "w~j!"
;  ddf4c: "h<Ah\"
;  de493: "/h@Ph"
;  de4b3: "h@Ph"
;  de4bb: "h@Ph,"
;  de4d7: "h@Ph "
;  de4df: "h@Ph$"
;  de4fc: "h@Phl"
;  de504: "h@Php"
;  de50c: "h@Pht"
;  de524: "h@Ph|"
;  de52d: "h@Phx"
;  de53e: "h@PhC"
;  de553: "h@Ph<"
;  de568: "h@Ph>"
;  de57d: "h@Ph="
;  de58f: "h@Ph?"
;  de59e: "h@Ph"
;  de5b0: "h@Ph@"
;  de6a0: "h@PhA"
;  de6a8: "h@Ph("
;  de6bd: "h@PhB"
;  de6e2: "h@Ph"
;  de6eb: "h@Ph"
;  de772: "uwh@Ph<"
;  de788: "h@Ph<"
;  de7ac: "h@Ph<"
;  de7e1: "Ph@Ph<"
;  de7f7: "h@PhC"
;  de816: "h@PhC"
;  de824: "h@PhC"
;  de82d: "h@PhC"
;  de85e: "h@PhC"
;  de872: "h@Ph>"
;  de886: "h@Ph>"
;  de88f: "h@Ph>"
;  de8c4: "Ph@Ph>"
;  de8da: "h@Ph="
;  de8ee: "h@Ph="
;  de8f7: "h@Ph="
;  de92c: "Ph@Ph="
;  de950: "h@Ph?"
;  de964: "h@Ph?"
;  de96d: "h@Ph?"
;  de9a2: "Ph@Ph?"
;  de9ac: "h@Ph@"
;  de9c3: "h@Ph@"
;  dea60: "h@Ph@"
;  deaaa: "h@Ph"
;  deabb: "5|$u"
;  deaca: "-h@Ph"
;  dead9: "h@Ph"
;  deae2: "h@Ph"
;  deb14: "h@Ph"
;  deb32: "h@Ph"
;  deb47: "PRh@Ph"
;  deb5a: "Z|7u"
;  deb69: "h@Ph"
;  deb7d: "h@Ph"
;  deb8b: "h@Ph"
;  deb94: "h@Ph"
;  debc6: "h@Ph"
;  debe3: "h@Ph"
;  debec: "h@Ph"
;  debfd: "5|Zu"
;  dec05: "rSh@Ph"
;  dec1c: "RPh@Ph"
;  dec2c: "h@Ph"
;  dec41: "RPh@Ph"
;  dec51: "h@Ph"
;  dec5a: "h@Ph"
;  dec8c: "h@Ph"
;  deca9: "h@Ph"
;  decc4: "h@PhA"
;  decd8: "h@PhA"
;  dece1: "h@PhA"
;  ded16: "Ph@PhA"
;  ded20: "h@Ph("
;  ded41: "h@Ph("
;  ded4f: "h@Ph("
;  ded6e: "h@Ph("
;  ded9f: "h@Ph("
;  dedbb: "h@PhB"
;  dedcf: "h@PhB"
;  dedd8: "h@PhB"
;  dee0d: "Ph@PhB"
;  deea1: "h@PhC"
;  deebf: "h@PhC"
;  deecd: "h@PhC"
;  deeec: "h@PhC"
;  def1d: "h@PhC"
;  def32: "h@Ph<"
;  def59: "h@Ph<"
;  def62: "h@Ph<"
;  defa2: "h@Ph>"
;  defc9: "h@Ph>"
;  defd2: "h@Ph>"
;  df007: "Ph@Ph>"
;  df01d: "h@Ph="
;  df044: "h@Ph="
;  df04d: "h@Ph="
;  df082: "Ph@Ph="
;  df0a6: "h@Ph?"
;  df0cd: "h@Ph?"
;  df0d6: "h@Ph?"
;  df10b: "Ph@Ph?"
;  df115: "h@Ph@"
;  df12c: "h@Ph@"
;  df1c9: "h@Ph@"
;  df213: "h@Ph"
;  df234: "h@Ph"
;  df242: "h@Ph"
;  df24b: "h@Ph"
;  df27d: "h@Ph"
;  df298: "h@PhA"
;  df2c0: "6h@PhA"
;  df2f6: "Ph@PhA"
;  df300: "h@Ph("
;  df321: "h@Ph("
;  df32f: "h@Ph("
;  df338: "h@Ph("
;  df369: "h@Ph("
;  df37e: "h@PhB"
;  df3a6: "6h@PhB"
;  df3dc: "Ph@PhB"
;  df403: "h@Ph"
;  df41c: "wSh@Ph"
;  df433: "RPh@Ph"
;  df443: "h@Ph"
;  df458: "RPh@Ph"
;  df468: "h@Ph"
;  df471: "h@Ph"
;  df4a3: "h@Ph"
;  df4c0: "h@Ph"
;  df4c9: "h@Ph"
;  df4d7: "PRh@Ph"
;  df500: "h@Ph"
;  df514: "h@Ph"
;  df522: "h@Ph"
;  df52b: "h@Ph"
;  df55d: "h@Ph"
;  df57a: "h@Ph"
;  df59c: "=#9 "
;  df5a1: "!=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#"
;  dfbee: "w"j!"
;  dfccf: "h<Ah\"
;  dfce9: "w$j!"
;  dfd04: "uwh<Ah\"
;  dfd30: "uKh<Ah\"
;  dfd5e: "h<Ah\"
;  dfdec: "h<Ah\"
;  dfe06: "w$j!"
;  dfe5a: "h<Ah\"
;  dfebd: "h<Ah\"
;  dff1e: "h<Ah\"
;  dffac: "h<Ah\"
;  dffc6: "w$j!"
;  e001a: "h<Ah\"
;  e007d: "h<Ah\"
;  e00de: "h<Ah\"
;  e0145: "h<Ah\"
;  e015f: "w$j!"
;  e0190: "h<Ah\"
;  e0202: "h<Ah\"
;  e0242: "h<Ah\"
;  e02db: "h<Ah\"
;  e02f5: "w$j "
;  e0326: "h<Ah\"
;  e0366: "h<Ah\"
;  e03a7: "h<Ah\"
;  e0471: "w"j "
;  e06ab: "w"j "
;  e085e: "h<Ah\"
;  e0878: "w$j "
;  e0890: "u&h<Ah\"
;  e08d1: "u&h<Ah\"
;  e0902: "u&h<Ah\"
;  e0944: "u&h<Ah\"
;  e0975: "u&h<Ah\"
;  e09a6: "u&h<Ah\"
;  e09df: "6x676"
;  e0ac8: "wxj!"
;  e0aef: "w$j!"
;  e0b32: "wBj!"
;  e0b99: "<Ah\"
;  e0be7: "wZj!"
;  e0c5e: "wBj!"
;  e0c9d: "<Ah\"
;  e0ceb: "wHj!"
;  e0d12: "wNj!"
;  e0d5d: "wBj!"
;  e0d9c: "<Ah\"
;  e0dea: "wHj!"
;  e0e11: "wNj!"
;  e1082: "h<Ah\"
;  e10b4: "h<Ah\"
;  e10db: "h<Ah\"
;  e1103: "h<Ah\"
;  e112c: "h<Ah\"
;  e1155: "h<Ah\"
;  e1165: ">G>n>"
;  e1304: "h<Ah\"
;  e13a2: "h<Ah\"
;  e1484: "h<Ah\"
;  e150e: "h<Ah\"
;  e1592: "h<Ah\"
;  e15e8: "h<Ah\"
;  e15fa: "@]A@B"
;  e1600: "BNCU"
;  e1797: "h<Ah\"
;  e1835: "h<Ah\"
;  e1917: "h<Ah\"
;  e19a9: "h<Ah\"
;  e1a2d: "h<Ah\"
;  e1a85: "h<Ah\"
;  e1d6b: "h<Ah\"
;  e1dc2: "h<Ah\"
;  e1e04: "h<Ah\"
;  e1e5c: "h<Ah\"
;  e1e9f: "h<Ah\"
;  e1ef7: "h<Ah\"
;  e1f0f: "H&I{IyJ"
;  e1fcb: "MWMLMU"
;  e201e: "h<Ah\"
;  e2050: "h<Ah\"
;  e2077: "h<Ah\"
;  e209f: "h<Ah\"
;  e20c8: "h<Ah\"
;  e20f1: "h<Ah\"
;  e211a: "h<Ah\"
;  e2143: "h<Ah\"
;  e2157: "N2N[N"
;  e2333: "h<Ah\"
;  e23e3: "h<Ah\"
;  e2502: "h<Ah\"
;  e259e: "h<Ah\"
;  e2648: "h<Ah\"
;  e26c4: "h<Ah\"
;  e277c: "h<Ah\"
;  e27e6: "h<Ah\"
;  e2802: "T8UU"
;  e29d6: "h<Ah\"
;  e2a86: "h<Ah\"
;  e2ba5: "h<Ah\"
;  e2c49: "h<Ah\"
;  e2d1e: "h<Ah\"
;  e2dc4: "h<Ah\"
;  e2e84: "h<Ah\"
;  e2ee3: "h<Ah\"
;  e2ef5: "WAXaY"
;  e2f40: "w"j "
;  e302a: "h<Ah\"
;  e3081: "h<Ah\"
;  e30c3: "h<Ah\"
;  e311b: "h<Ah\"
;  e315e: "h<Ah\"
;  e31b6: "h<Ah\"
;  e31f9: "h<Ah\"
;  e3251: "h<Ah\"
;  f0854: "QWV&"
;  f0882: "QWV&"
;  f0a91: "5QVW"
;  f0b1f: "6QVW"
;  f0b6d: "6QVW"
;  f0bbd: "6QVW"
;  f0c0b: "6QVW"
;  f5138: "QWV&"


; =============================================================================
; CODE SECTION
; =============================================================================


;  XREF: fff07

; =============================================================================
; SEGMENT D000 - MAIN PROGRAM CODE (0xD0000-0xDFFFF, 64KB)
; =============================================================================
; This is the primary code segment containing:
;   - System initialization and boot sequence
;   - Display command queue management (circular buffer)
;   - DMD hardware control functions
;   - Display utility library (resource loading, animation, text)
;   - Main game loop and state machine dispatcher
;   - State handlers: attract mode, game active, special mode
;   - Scoring system and high score management
;   - Match/lottery sequence
;   - Switch event processing and dispatch
;   - Solenoid and lamp control via Z80 shared RAM
;   - Game logic: bumpers, targets, ramps, lanes, Jupiter, multiball
;   - DMD animation engine
;
; Key architectural notes:
;   - 80188 CPU communicates with Z80 coprocessor via shared RAM at segment 4000h
;   - Z80 handles: switch matrix scanning, lamp matrix, solenoids, sound
;   - 80188 handles: game logic, DMD display, state machine, scoring
;   - Bus sharing via HOLD/HLDA (RELREG ET=1)
;   - Game state machine at 413C:014F with 3 states (1/2/4)
;   - Display uses circular command queue at 4000:1158+
;
; Developer: Luis Gosálbez Carrasco, SLEIC Madrid (1994, released 1996)
; =============================================================================

; -----------------------------------------------------------------------------
; main_init (0xD0000)
; Main entry point - CPU initialization (CLI, setup SS/DS/ES, I/O config)
; -----------------------------------------------------------------------------
d0000:  fa                    main_init:           cli                      ; Disable interrupts during initialization
d0001:  b8 52 41                                   mov        ax, 4152h     ; SS = 4152h (stack segment in work RAM)
d0004:  8e d0                                      mov        ss, ax
d0006:  b8 05 02                                   mov        ax, 0205h     ; SP = 0205h (~517 bytes of stack space)
d0009:  8b e0                                      mov        sp, ax
d000b:  b8 00 40                                   mov        ax, 4000h     ; DS = 4000h (shared RAM / work RAM segment)
d000e:  8e d8                                      mov        ds, ax
d0010:  8e c0                                      mov        es, ax        ; ES = 4000h (shared RAM)
d0012:  be 41 00                                   mov        si, 0041h     ; SI -> I/O port configuration table at DS:0041
d0015:  b9 1e 00                                   mov        cx, 001eh     ; CX = 30 (number of port/value pairs to configure)

;  XREF: d001f
d0018:  2e ad                 loc_d0018:           lodsw
d001a:  8b d0                                      mov        dx, ax
d001c:  2e ad                                      lodsw
d001e:  ef                                         out        dx, ax
d001f:  e2 f7                                      loop       loc_d0018
d0021:  fa                                         cli
d0022:  9a b9 00 00 d0                             call       dmd_controller_init
d0027:  9a 1c 01 00 d0                             call       display_buffer_init
d002c:  9a fa 00 00 d0                             call       dmd_reset_pulse
d0031:  9a 00 00 00 f0                             call       system_init
d0036:  9a 2b 0b 00 d0                             call       system_init_final
d003b:  fb                                         sti
d003c:  ea 02 00 f2 d2                             jmp        main_game_loop

;  XREF: d0022

; -----------------------------------------------------------------------------
; dmd_controller_init (0xD00B9)
; Initialize DMD controller hardware registers (A000:0000/0080/0200/0300)
; -----------------------------------------------------------------------------
d00b9:  1e                    dmd_controller_init:           push       ds
d00ba:  b8 00 40                                   mov        ax, 4000h
d00bd:  8e d8                                      mov        ds, ax
d00bf:  b8 00 a0                                   mov        ax, a000h
d00c2:  8e c0                                      mov        es, ax
d00c4:  b0 80                                      mov        al, 80h
d00c6:  26 a2 00 03                                mov        es:[0300h], al ; DMD_ENABLE - DMD enable register (0x80 = enabled)
d00ca:  b0 28                                      mov        al, 28h
d00cc:  26 a2 00 00                                mov        es:[0000h], al ; DMD_CTRL1 - DMD control byte 1 (0x28 = display on)
d00d0:  a2 34 11                                   mov        [1134h], al   ; dmd_display_mode - Current DMD display mode (init: 0x28)
d00d3:  b0 00                                      mov        al, 00h
d00d5:  26 a2 80 00                                mov        es:[0080h], al ; DMD_CTRL2 - DMD control byte 2
d00d9:  a2 35 11                                   mov        [1135h], al   ; dmd_display_flags - DMD display flags
d00dc:  b0 07                                      mov        al, 07h
d00de:  26 a2 00 02                                mov        es:[0200h], al
d00e2:  a2 38 11                                   mov        [1138h], al   ; dmd_control_shadow - Shadow of DMD control register A000:0200
d00e5:  be 58 11                                   mov        si, 1158h
d00e8:  89 36 4c 11                                mov        [114ch], si   ; cmd_queue_write_ptr - Command queue write pointer (circular buffer)
d00ec:  89 36 4e 11                                mov        [114eh], si   ; cmd_queue_read_ptr - Command queue read pointer (circular buffer)
d00f0:  c6 04 00                                   mov        byte [si], 00h
d00f3:  c6 06 45 11 04                             mov        byte [1145h], 04h
d00f8:  1f                                         pop        ds
d00f9:  cb                                         retf

;  XREF: d002c

; -----------------------------------------------------------------------------
; dmd_reset_pulse (0xD00FA)
; Send reset strobe pulse to DMD controller (bit 3 toggle on A000:0200)
; -----------------------------------------------------------------------------
d00fa:  1e                    dmd_reset_pulse:           push       ds
d00fb:  06                                         push       es
d00fc:  b8 00 40                                   mov        ax, 4000h
d00ff:  8e d8                                      mov        ds, ax
d0101:  b8 00 a0                                   mov        ax, a000h
d0104:  8e c0                                      mov        es, ax
d0106:  a0 38 11                                   mov        al, [1138h]   ; dmd_control_shadow - Shadow of DMD control register A000:0200
d0109:  0c 08                                      or         al, 08h
d010b:  26 a2 00 02                                mov        es:[0200h], al ; DMD_MODE - DMD mode register (bit 3 = strobe signal)
d010f:  90                                         nop
d0110:  90                                         nop
d0111:  90                                         nop
d0112:  90                                         nop
d0113:  24 f7                                      and        al, f7h
d0115:  26 a2 00 02                                mov        es:[0200h], al ; DMD_MODE - DMD mode register (bit 3 = strobe signal)
d0119:  07                                         pop        es
d011a:  1f                                         pop        ds
d011b:  cb                                         retf

;  XREF: d0027

; -----------------------------------------------------------------------------
; display_buffer_init (0xD011C)
; Initialize display buffer pointers (4000:1150-1156, 4000:1220)
; -----------------------------------------------------------------------------
d011c:  1e                    display_buffer_init:           push       ds
d011d:  b8 00 40                                   mov        ax, 4000h
d0120:  8e d8                                      mov        ds, ax
d0122:  a3 52 11                                   mov        [1152h], ax   ; display_buf_seg1 - Display buffer segment 1
d0125:  a3 56 11                                   mov        [1156h], ax   ; display_buf_seg2 - Display buffer segment 2
d0128:  be 20 12                                   mov        si, 1220h
d012b:  89 36 54 11                                mov        [1154h], si   ; display_buf_ptr2 - Display buffer pointer 2
d012f:  89 36 50 11                                mov        [1150h], si   ; display_buf_ptr1 - Display buffer pointer 1 (current read position)
d0133:  c6 04 00                                   mov        byte [si], 00h
d0136:  1f                                         pop        ds
d0137:  cb                                         retf

;  XREF: d2f99, d3087, d30aa, d3106, d311a (+75 more)

; -----------------------------------------------------------------------------
; cmd_queue_push (0xD0138)
; Push display command byte to circular command queue (4000:1158+). 80 XREFs - most called function. CLI/STI protected. Param: [BP+06]=command byte
; -----------------------------------------------------------------------------
d0138:  fa                    cmd_queue_push:           cli
d0139:  c8 02 00 00                                enter      0002h, 00h
d013d:  8b 46 06                                   mov        ax, [bp+06h]
d0140:  32 e4                                      xor        ah, ah
d0142:  1e                                         push       ds
d0143:  bb 00 40                                   mov        bx, 4000h
d0146:  8e db                                      mov        ds, bx
d0148:  8b 36 4e 11                                mov        si, [114eh]   ; cmd_queue_read_ptr - Command queue read pointer (circular buffer)
d014c:  80 3c 00                                   cmp        byte [si], 00h
d014f:  74 0f                                      jz         loc_d0160
d0151:  46                                         inc        si
d0152:  89 36 4e 11                                mov        [114eh], si   ; cmd_queue_read_ptr - Command queue read pointer (circular buffer)

;  XREF: d016b
d0156:  88 04                 loc_d0156:           mov        [si], al
d0158:  46                                         inc        si
d0159:  c6 04 00                                   mov        byte [si], 00h
d015c:  1f                                         pop        ds
d015d:  c9                                         leave
d015e:  fb                                         sti
d015f:  cb                                         retf

;  XREF: d014f
d0160:  be 58 11              loc_d0160:           mov        si, 1158h
d0163:  89 36 4e 11                                mov        [114eh], si   ; cmd_queue_read_ptr - Command queue read pointer (circular buffer)
d0167:  89 36 4c 11                                mov        [114ch], si   ; cmd_queue_write_ptr - Command queue write pointer (circular buffer)
d016b:  eb e9                                      jmp short  loc_d0156

; -----------------------------------------------------------------------------
; dmd_vblank_isr (0xD016D)
; DMD VBLANK interrupt service routine. Toggles DMD control bits, advances
; the display buffer pointer, and re-arms the frame timer [1140h].
; -----------------------------------------------------------------------------
d016d:  9c                    dmd_vblank_isr:           pushf
d016e:  50                                         push       ax
d016f:  53                                         push       bx
d0170:  51                                         push       cx
d0171:  52                                         push       dx
d0172:  56                                         push       si
d0173:  57                                         push       di
d0174:  55                                         push       bp
d0175:  06                                         push       es
d0176:  1e                                         push       ds
d0177:  b8 00 a0                                   mov        ax, 0a000h
d017a:  8e c0                                      mov        es, ax
d017c:  b8 00 40                                   mov        ax, 4000h
d017f:  8e d8                                      mov        ds, ax
d0181:  a0 38 11                                   mov        al, [1138h]   ; dmd_control_shadow - Shadow of DMD control register A000:0200
d0184:  0c d0                                      or         al, 0d0h
d0186:  90                                         nop
d0187:  90                                         nop
d0188:  26 a2 00 02                                mov        es:[0200h], al ; DMD_MODE - DMD mode register (bit 3 = strobe signal)
d018c:  26 a0 00 01                                mov        al, es:[0100h]
d0190:  3c 32                                      cmp        al, 32h
d0192:  75 07                                      jne        loc_d019b
d0194:  fe 06 44 11                                inc        byte [1144h]
d0198:  eb 2a                                      jmp short  loc_d01c4
d019a:  90                                         nop

;  XREF: d0192
d019b:  8b 36 54 11           loc_d019b:           mov        si, [1154h]   ; display_buf_ptr2 - Display buffer pointer 2
d019f:  80 3c 00                                   cmp        byte [si], 00h
d01a2:  74 0f                                      je         loc_d01b3
d01a4:  bf e8 12                                   mov        di, 12e8h
d01a7:  3b fe                                      cmp        di, si
d01a9:  74 08                                      je         loc_d01b3
d01ab:  46                                         inc        si
d01ac:  89 36 54 11                                mov        [1154h], si   ; display_buf_ptr2 - Display buffer pointer 2
d01b0:  eb 0c                                      jmp short  loc_d01be
d01b2:  90                                         nop

;  XREF: d01a2, d01a9
d01b3:  be 20 12              loc_d01b3:           mov        si, 1220h
d01b6:  89 36 54 11                                mov        [1154h], si   ; display_buf_ptr2 - Display buffer pointer 2
d01ba:  89 36 50 11                                mov        [1150h], si   ; display_buf_ptr1 - Display buffer pointer 1 (current read position)

;  XREF: d01b0
d01be:  88 04                 loc_d01be:           mov        [si], al
d01c0:  46                                         inc        si
d01c1:  c6 04 00                                   mov        byte [si], 00h

;  XREF: d0198
d01c4:  b0 ff                 loc_d01c4:           mov        al, 0ffh
d01c6:  a2 47 11                                   mov        [1147h], al
d01c9:  a0 38 11                                   mov        al, [1138h]   ; dmd_control_shadow - Shadow of DMD control register A000:0200
d01cc:  0c 80                                      or         al, 80h
d01ce:  90                                         nop
d01cf:  90                                         nop
d01d0:  26 a2 00 02                                mov        es:[0200h], al ; DMD_MODE - DMD mode register (bit 3 = strobe signal)
d01d4:  c7 06 40 11 10 00                          mov        word [1140h], 0010h
d01da:  1f                                         pop        ds
d01db:  07                                         pop        es
d01dc:  5d                                         pop        bp
d01dd:  5f                                         pop        di
d01de:  5e                                         pop        si
d01df:  5a                                         pop        dx
d01e0:  59                                         pop        cx
d01e1:  5b                                         pop        bx
d01e2:  58                                         pop        ax
d01e3:  9d                                         popf
d01e4:  cf                                         iret

;  XREF: d0392

; -----------------------------------------------------------------------------
; dmd_queue_service (0xD01E5)
; Service the DMD display command queue: every 4th call, pull one byte from
; [114ch] and push it to the DMD controller (A000:0080 / strobe A000:0200).
; -----------------------------------------------------------------------------
d01e5:  80 3e 45 11 00        dmd_queue_service:           cmp        byte [1145h], 00h
d01ea:  74 05                                      je         loc_d01f1
d01ec:  fe 0e 45 11                                dec        byte [1145h]
d01f0:  c3                                         ret

;  XREF: d01ea
d01f1:  c6 06 45 11 03        loc_d01f1:           mov        byte [1145h], 03h
d01f6:  8b 36 4c 11                                mov        si, [114ch]
d01fa:  8a 04                                      mov        al, [si]
d01fc:  22 c0                                      and        al, al
d01fe:  75 01                                      jne        loc_d0201
d0200:  c3                                         ret

;  XREF: d01fe
d0201:  bb 00 a0              loc_d0201:           mov        bx, 0a000h
d0204:  8e c3                                      mov        es, bx
d0206:  26 f6 06 80 01 01                          test       byte es:[0180h], 01h
d020c:  75 01                                      jne        loc_d020f
d020e:  c3                                         ret

;  XREF: d020c
d020f:  26 a2 80 00           loc_d020f:           mov        es:[0080h], al ; DMD_CTRL2 - DMD control byte 2
d0213:  a0 38 11                                   mov        al, [1138h]   ; dmd_control_shadow - Shadow of DMD control register A000:0200
d0216:  0c 40                                      or         al, 40h
d0218:  26 a2 00 02                                mov        es:[0200h], al ; DMD_MODE - DMD mode register (bit 3 = strobe signal)
d021c:  a2 38 11                                   mov        [1138h], al   ; dmd_control_shadow - Shadow of DMD control register A000:0200
d021f:  c6 04 00                                   mov        byte [si], 00h
d0222:  46                                         inc        si
d0223:  89 36 4c 11                                mov        [114ch], si
d0227:  a0 38 11                                   mov        al, [1138h]   ; dmd_control_shadow - Shadow of DMD control register A000:0200
d022a:  0c 20                                      or         al, 20h
d022c:  a2 38 11                                   mov        [1138h], al   ; dmd_control_shadow - Shadow of DMD control register A000:0200
d022f:  26 a2 00 02                                mov        es:[0200h], al ; DMD_MODE - DMD mode register (bit 3 = strobe signal)
d0233:  90                                         nop
d0234:  90                                         nop
d0235:  90                                         nop
d0236:  90                                         nop
d0237:  90                                         nop
d0238:  90                                         nop
d0239:  90                                         nop
d023a:  90                                         nop
d023b:  90                                         nop
d023c:  90                                         nop
d023d:  90                                         nop
d023e:  90                                         nop
d023f:  90                                         nop
d0240:  a0 38 11                                   mov        al, [1138h]   ; dmd_control_shadow - Shadow of DMD control register A000:0200
d0243:  24 df                                      and        al, 0dfh
d0245:  24 bf                                      and        al, 0bfh
d0247:  a2 38 11                                   mov        [1138h], al   ; dmd_control_shadow - Shadow of DMD control register A000:0200
d024a:  26 a2 00 02                                mov        es:[0200h], al ; DMD_MODE - DMD mode register (bit 3 = strobe signal)
d024e:  c3                                         ret

; -----------------------------------------------------------------------------
; sound_timer_isr (0xD024F)
; Sound/music timer interrupt service routine. Dispatches the two OKI MSM6376
; voices (channel A [12FDh], channel B [1300h]), runs the per-frame FM player
; tick, then issues an end-of-interrupt to the 80188 timer (TCUCON 0FF2Ch).
; -----------------------------------------------------------------------------
d024f:  9c                    sound_timer_isr:           pushf
d0250:  50                                         push       ax
d0251:  53                                         push       bx
d0252:  51                                         push       cx
d0253:  52                                         push       dx
d0254:  56                                         push       si
d0255:  57                                         push       di
d0256:  55                                         push       bp
d0257:  06                                         push       es
d0258:  1e                                         push       ds
d0259:  b8 00 40                                   mov        ax, 4000h
d025c:  8e d8                                      mov        ds, ax
d025e:  80 3e f0 10 00                             cmp        byte [10f0h], 00h ; foreground task flag set -> call BIOS f000:114a
d0263:  74 05                                      je         loc_d026a
d0265:  9a 4a 11 00 f0                             call far   0f000h:114ah

;  XREF: d0263
d026a:  83 3e fd 12 00        loc_d026a:           cmp        word [12fdh], 0000h
d026f:  75 28                                      jne        loc_d0299
d0271:  80 3e 02 13 00                             cmp        byte [1302h], 00h ; OKI channel A: trigger pending?
d0276:  74 36                                      je         loc_d02ae
d0278:  80 3e 03 13 00                             cmp        byte [1303h], 00h
d027d:  74 0a                                      je         loc_d0289
d027f:  c6 06 03 13 00                             mov        byte [1303h], 00h
d0284:  9a 09 0d 00 d0                             call       dmd_display_enable

;  XREF: d027d
d0289:  c6 06 02 13 00        loc_d0289:           mov        byte [1302h], 00h ; OKI channel A: clear trigger
d028e:  a0 f9 12                                   mov        al, [12f9h]   ; AL = sample number [12F9h]
d0291:  9a 57 0c 00 d0                             call       config_load_defaults ; play sample (config_load_defaults dispatch table)
d0296:  eb 16                                      jmp short  loc_d02ae
d0298:  90                                         nop

;  XREF: d026f
d0299:  ff 0e fd 12           loc_d0299:           dec        word [12fdh]
d029d:  83 3e fd 12 00                             cmp        word [12fdh], 0000h
d02a2:  75 0a                                      jne        loc_d02ae
d02a4:  c6 06 fc 12 00                             mov        byte [12fch], 00h
d02a9:  80 26 04 13 0f                             and        byte [1304h], 0fh

;  XREF: d0276, d0296, d02a2
d02ae:  83 3e 00 13 00        loc_d02ae:           cmp        word [1300h], 0000h
d02b3:  75 17                                      jne        loc_d02cc
d02b5:  80 3e 02 13 00                             cmp        byte [1302h], 00h ; OKI channel B: trigger pending?
d02ba:  74 25                                      je         loc_d02e1
d02bc:  c6 06 02 13 00                             mov        byte [1302h], 00h
d02c1:  a0 f9 12                                   mov        al, [12f9h]   ; AL = sample number [12F9h]
d02c4:  9a 84 0c 00 d0                             call       config_load_eeprom ; play sample (config_load_eeprom dispatch table)
d02c9:  eb 16                                      jmp short  loc_d02e1
d02cb:  90                                         nop

;  XREF: d02b3
d02cc:  ff 0e 00 13           loc_d02cc:           dec        word [1300h]
d02d0:  83 3e 00 13 00                             cmp        word [1300h], 0000h
d02d5:  75 0a                                      jne        loc_d02e1
d02d7:  c6 06 ff 12 00                             mov        byte [12ffh], 00h
d02dc:  80 26 04 13 f0                             and        byte [1304h], 0f0h

;  XREF: d02ba, d02c9, d02d5
d02e1:  83 3e 39 11 00        loc_d02e1:           cmp        word [1139h], 0000h
d02e6:  74 04                                      je         loc_d02ec
d02e8:  ff 0e 39 11                                dec        word [1139h]

;  XREF: d02e6
d02ec:  83 3e 3b 11 00        loc_d02ec:           cmp        word [113bh], 0000h
d02f1:  74 04                                      je         loc_d02f7
d02f3:  ff 0e 3b 11                                dec        word [113bh]

;  XREF: d02f1
d02f7:  83 3e 3d 11 00        loc_d02f7:           cmp        word [113dh], 0000h
d02fc:  74 04                                      je         loc_d0302
d02fe:  ff 0e 3d 11                                dec        word [113dh]

;  XREF: d02fc
d0302:  80 3e 3f 11 09        loc_d0302:           cmp        byte [113fh], 09h ; FM frame counter 0..8 wrap
d0307:  72 08                                      jb         loc_d0311
d0309:  c6 06 3f 11 00                             mov        byte [113fh], 00h
d030e:  eb 05                                      jmp short  loc_d0315
d0310:  90                                         nop

;  XREF: d0307
d0311:  fe 06 3f 11           loc_d0311:           inc        byte [113fh]

;  XREF: d030e
d0315:  ff 0e 40 11           loc_d0315:           dec        word [1140h]  ; per-frame FM player tick countdown
d0319:  75 03                                      jne        loc_d031e
d031b:  e8 13 00                                   call       dmd_strobe_clear ; tick expired -> service music sequencer

;  XREF: d0319
d031e:  ba 2c ff              loc_d031e:           mov        dx, 0ff2ch    ; EOI to 80188 INT0 (TCUCON 0FF2Ch, clear bit0)
d0321:  ed                                         in         ax, dx
d0322:  25 fe 00                                   and        ax, 00feh
d0325:  ef                                         out        dx, ax
d0326:  1f                                         pop        ds
d0327:  07                                         pop        es
d0328:  5d                                         pop        bp
d0329:  5f                                         pop        di
d032a:  5e                                         pop        si
d032b:  5a                                         pop        dx
d032c:  59                                         pop        cx
d032d:  5b                                         pop        bx
d032e:  58                                         pop        ax
d032f:  9d                                         popf
d0330:  cf                                         iret                     ; return from timer ISR

;  XREF: d031b

; -----------------------------------------------------------------------------
; dmd_strobe_clear (0xD0331)
; Clear DMD strobe bit 7 of the control shadow [1138h] (A000:0200).
; -----------------------------------------------------------------------------
d0331:  b8 00 a0              dmd_strobe_clear:           mov        ax, 0a000h
d0334:  8e c0                                      mov        es, ax
d0336:  a0 38 11                                   mov        al, [1138h]   ; dmd_control_shadow - Shadow of DMD control register A000:0200
d0339:  24 7f                                      and        al, 7fh
d033b:  a2 38 11                                   mov        [1138h], al   ; dmd_control_shadow - Shadow of DMD control register A000:0200
d033e:  26 a2 00 02                                mov        es:[0200h], al ; DMD_MODE - DMD mode register (bit 3 = strobe signal)
d0342:  c3                                         ret

; -----------------------------------------------------------------------------
; frame_isr (0xD0343)
; Per-frame interrupt service routine. Runs the BIOS sound/display helpers,
; services the music sequencer (d000:0D1B) and the DMD queue (d000:01E5),
; then issues the timer end-of-interrupt (TCUCON 0FF2Ch).
; -----------------------------------------------------------------------------
d0343:  9c                    frame_isr:           pushf
d0344:  50                                         push       ax
d0345:  53                                         push       bx
d0346:  51                                         push       cx
d0347:  52                                         push       dx
d0348:  56                                         push       si
d0349:  57                                         push       di
d034a:  55                                         push       bp
d034b:  06                                         push       es
d034c:  1e                                         push       ds
d034d:  b8 00 40                                   mov        ax, 4000h
d0350:  8e d8                                      mov        ds, ax
d0352:  80 3e 42 11 00                             cmp        byte [1142h], 00h ; frame-busy gate [1142h]
d0357:  75 25                                      jne        loc_d037e
d0359:  c6 06 42 11 ff                             mov        byte [1142h], 0ffh
d035e:  9a eb 08 00 f0                             call far   0f000h:08ebh  ; BIOS f000:08EB (sound/display helper, undisassembled)
d0363:  80 3e f1 10 00                             cmp        byte [10f1h], 00h
d0368:  74 05                                      je         loc_d036f
d036a:  9a 03 13 00 f0                             call far   0f000h:1303h  ; BIOS f000:1303 (sound/display helper, undisassembled)

;  XREF: d0368
d036f:  80 3e dd 10 00        loc_d036f:           cmp        byte [10ddh], 00h
d0374:  74 2b                                      je         loc_d03a1
d0376:  9a 93 0f 00 f0                             call far   0f000h:0f93h  ; BIOS f000:0F93 (sound/display helper, undisassembled)
d037b:  eb 30                                      jmp short  loc_d03ad
d037d:  90                                         nop

;  XREF: d0357
d037e:  c6 06 42 11 00        loc_d037e:           mov        byte [1142h], 00h
d0383:  9a a5 08 00 f0                             call far   0f000h:08a5h  ; BIOS f000:08A5 (sound/display helper, undisassembled)
d0388:  c6 06 48 11 00                             mov        byte [1148h], 00h
d038d:  9a 1b 0d 00 d0                             call       music_sequencer ; service music sequencer (d000:0D1B)
d0392:  e8 50 fe                                   call       dmd_queue_service ; service DMD queue (d000:01E5)
d0395:  80 3e d5 10 00                             cmp        byte [10d5h], 00h
d039a:  74 05                                      je         loc_d03a1
d039c:  9a 1a 0e 00 f0                             call far   0f000h:0e1ah  ; BIOS f000:0E1A (sound/display helper, undisassembled)

;  XREF: d0374, d039a
d03a1:  80 3e e2 10 00        loc_d03a1:           cmp        byte [10e2h], 00h
d03a6:  74 05                                      je         loc_d03ad
d03a8:  9a 54 10 00 f0                             call far   0f000h:1054h  ; BIOS f000:1054 (sound/display helper, undisassembled)

;  XREF: d037b, d03a6
d03ad:  ba 2c ff              loc_d03ad:           mov        dx, 0ff2ch    ; EOI to 80188 INT (TCUCON 0FF2Ch, clear bit4)
d03b0:  ed                                         in         ax, dx
d03b1:  25 ef 00                                   and        ax, 00efh
d03b4:  ef                                         out        dx, ax
d03b5:  1f                                         pop        ds
d03b6:  07                                         pop        es
d03b7:  5d                                         pop        bp
d03b8:  5f                                         pop        di
d03b9:  5e                                         pop        si
d03ba:  5a                                         pop        dx
d03bb:  59                                         pop        cx
d03bc:  5b                                         pop        bx
d03bd:  58                                         pop        ax
d03be:  9d                                         popf
d03bf:  cf                                         iret

;  XREF: d08db, d0b24

; -----------------------------------------------------------------------------
; dmd_strobe_pulse (0xD03C0)
; Send strobe pulse to DMD (bit 3 toggle on A000:0200), same as dmd_reset_pulse but different context
; -----------------------------------------------------------------------------
d03c0:  1e                    dmd_strobe_pulse:           push       ds
d03c1:  06                                         push       es
d03c2:  b8 00 40                                   mov        ax, 4000h
d03c5:  8e d8                                      mov        ds, ax
d03c7:  b8 00 a0                                   mov        ax, a000h
d03ca:  8e c0                                      mov        es, ax
d03cc:  a0 38 11                                   mov        al, [1138h]   ; dmd_control_shadow - Shadow of DMD control register A000:0200
d03cf:  24 fe                                      and        al, feh
d03d1:  0c 02                                      or         al, 02h
d03d3:  a2 38 11                                   mov        [1138h], al   ; dmd_control_shadow - Shadow of DMD control register A000:0200
d03d6:  26 a2 00 02                                mov        es:[0200h], al ; DMD_MODE - DMD mode register (bit 3 = strobe signal)
d03da:  a0 38 11                                   mov        al, [1138h]   ; dmd_control_shadow - Shadow of DMD control register A000:0200
d03dd:  24 fb                                      and        al, fbh
d03df:  a2 38 11                                   mov        [1138h], al   ; dmd_control_shadow - Shadow of DMD control register A000:0200
d03e2:  26 a2 00 02                                mov        es:[0200h], al ; DMD_MODE - DMD mode register (bit 3 = strobe signal)
d03e6:  a0 38 11                                   mov        al, [1138h]   ; dmd_control_shadow - Shadow of DMD control register A000:0200
d03e9:  0c 04                                      or         al, 04h
d03eb:  a2 38 11                                   mov        [1138h], al   ; dmd_control_shadow - Shadow of DMD control register A000:0200
d03ee:  26 a2 00 02                                mov        es:[0200h], al
d03f2:  a0 38 11                                   mov        al, [1138h]   ; dmd_control_shadow - Shadow of DMD control register A000:0200
d03f5:  0c 01                                      or         al, 01h
d03f7:  a2 38 11                                   mov        [1138h], al   ; dmd_control_shadow - Shadow of DMD control register A000:0200
d03fa:  26 a2 00 02                                mov        es:[0200h], al
d03fe:  07                                         pop        es
d03ff:  1f                                         pop        ds
d0400:  cb                                         retf

;  XREF: d0b1b

; -----------------------------------------------------------------------------
; dmd_mode_set (0xD0401)
; Set DMD display mode/control register
; -----------------------------------------------------------------------------
d0401:  1e                    dmd_mode_set:           push       ds
d0402:  06                                         push       es
d0403:  b8 00 40                                   mov        ax, 4000h
d0406:  8e d8                                      mov        ds, ax
d0408:  b8 00 a0                                   mov        ax, a000h
d040b:  8e c0                                      mov        es, ax
d040d:  a0 38 11                                   mov        al, [1138h]   ; dmd_control_shadow - Shadow of DMD control register A000:0200
d0410:  24 fc                                      and        al, fch
d0412:  a2 38 11                                   mov        [1138h], al   ; dmd_control_shadow - Shadow of DMD control register A000:0200
d0415:  26 a2 00 02                                mov        es:[0200h], al ; DMD_MODE - DMD mode register (bit 3 = strobe signal)
d0419:  a0 38 11                                   mov        al, [1138h]   ; dmd_control_shadow - Shadow of DMD control register A000:0200
d041c:  24 fb                                      and        al, fbh
d041e:  a2 38 11                                   mov        [1138h], al   ; dmd_control_shadow - Shadow of DMD control register A000:0200
d0421:  26 a2 00 02                                mov        es:[0200h], al ; DMD_MODE - DMD mode register (bit 3 = strobe signal)
d0425:  a0 38 11                                   mov        al, [1138h]   ; dmd_control_shadow - Shadow of DMD control register A000:0200
d0428:  0c 04                                      or         al, 04h
d042a:  a2 38 11                                   mov        [1138h], al   ; dmd_control_shadow - Shadow of DMD control register A000:0200
d042d:  26 a2 00 02                                mov        es:[0200h], al
d0431:  a0 38 11                                   mov        al, [1138h]   ; dmd_control_shadow - Shadow of DMD control register A000:0200
d0434:  0c 03                                      or         al, 03h
d0436:  a2 38 11                                   mov        [1138h], al   ; dmd_control_shadow - Shadow of DMD control register A000:0200
d0439:  26 a2 00 02                                mov        es:[0200h], al
d043d:  07                                         pop        es
d043e:  1f                                         pop        ds
d043f:  cb                                         retf

;  XREF: d3559, d3599, d48fc, d4ade, d4c3c (+20 more)

; -----------------------------------------------------------------------------
; display_write_param_25refs (0xD046D)
; Display utility - write parameter to display system (25 refs)
; -----------------------------------------------------------------------------
d046d:  55                    display_write_param_25refs:           push       bp
d046e:  8b ec                                      mov        bp, sp
d0470:  06                                         push       es
d0471:  c4 76 06                                   les        si, [bp+06h]
d0474:  8b 46 0a                                   mov        ax, [bp+0ah]
d0477:  8b 5e 0c                                   mov        bx, [bp+0ch]
d047a:  e8 01 01                                   call       display_set_buffer_14refs
d047d:  26 88 04                                   mov        es:[si], al
d0480:  26 88 64 01                                mov        es:[si+01h], ah
d0484:  26 88 5c 02                                mov        es:[si+02h], bl
d0488:  26 88 7c 03                                mov        es:[si+03h], bh
d048c:  e8 10 01                                   call       display_clear_area_24refs
d048f:  07                                         pop        es
d0490:  5d                                         pop        bp
d0491:  cb                                         retf

;  XREF: d3543, d3583, d3670, d3698, d472b (+24 more)

; -----------------------------------------------------------------------------
; display_set_animation_29refs (0xD0492)
; Display utility - set animation parameters (29 refs). Called with 2 params on stack
; -----------------------------------------------------------------------------
d0492:  55                    display_set_animation_29refs:           push       bp
d0493:  8b ec                                      mov        bp, sp
d0495:  06                                         push       es
d0496:  c4 5e 06                                   les        bx, [bp+06h]
d0499:  e8 e2 00                                   call       display_set_buffer_14refs
d049c:  26 8b 57 02                                mov        dx, es:[bx+02h]
d04a0:  26 8b 07                                   mov        ax, es:[bx]
d04a3:  e8 f9 00                                   call       display_clear_area_24refs
d04a6:  07                                         pop        es
d04a7:  5d                                         pop        bp
d04a8:  cb                                         retf

;  XREF: d2fc3, d496c, d49a7, d49f0, d4a2b (+46 more)

; -----------------------------------------------------------------------------
; display_load_resource_51refs (0xD04A9)
; Display utility - load display resource (51 refs). Called with 3 params: resource_id, segment, flags
; -----------------------------------------------------------------------------
d04a9:  55                    display_load_resource_51refs:           push       bp
d04aa:  8b ec                                      mov        bp, sp
d04ac:  06                                         push       es
d04ad:  c4 5e 06                                   les        bx, [bp+06h]
d04b0:  8a 46 0a                                   mov        al, [bp+0ah]
d04b3:  e8 c8 00                                   call       display_set_buffer_14refs
d04b6:  26 88 07                                   mov        es:[bx], al
d04b9:  e8 e3 00                                   call       display_clear_area_24refs
d04bc:  07                                         pop        es
d04bd:  5d                                         pop        bp
d04be:  cb                                         retf

;  XREF: d2f2e, d2f8a, d493c, d4959, d4994 (+43 more)

; -----------------------------------------------------------------------------
; display_check_status_48refs (0xD04BF)
; Display utility - check display status/ready (48 refs). Called with 2 params, returns AL
; -----------------------------------------------------------------------------
d04bf:  55                    display_check_status_48refs:           push       bp
d04c0:  8b ec                                      mov        bp, sp
d04c2:  06                                         push       es
d04c3:  c4 5e 06                                   les        bx, [bp+06h]
d04c6:  e8 b5 00                                   call       display_set_buffer_14refs
d04c9:  26 8a 07                                   mov        al, es:[bx]
d04cc:  e8 d0 00                                   call       display_clear_area_24refs
d04cf:  07                                         pop        es
d04d0:  5d                                         pop        bp
d04d1:  cb                                         retf

;  XREF: d3664, d662b, d66ab, d80d9, da842 (+7 more)

; -----------------------------------------------------------------------------
; display_write_word_12refs (0xD04D2)
; Display utility - write word value (12 refs)
; -----------------------------------------------------------------------------
d04d2:  55                    display_write_word_12refs:           push       bp
d04d3:  06                                         push       es
d04d4:  b8 40 50                                   mov        ax, 5040h
d04d7:  8e c0                                      mov        es, ax
d04d9:  8b ec                                      mov        bp, sp
d04db:  8b 46 08                                   mov        ax, [bp+08h]
d04de:  e8 9d 00                                   call       display_set_buffer_14refs
d04e1:  26 a2 83 00                                mov        es:[0083h], al
d04e5:  26 a2 16 01                                mov        es:[0116h], al
d04e9:  26 a2 0c 02                                mov        es:[020ch], al
d04ed:  e8 af 00                                   call       display_clear_area_24refs
d04f0:  07                                         pop        es
d04f1:  5d                                         pop        bp
d04f2:  cb                                         retf

;  XREF: d6633, d66b3, da85f, da8d5, dc88c (+5 more)

; -----------------------------------------------------------------------------
; display_set_mode_10refs (0xD04F3)
; Display utility - set display mode (10 refs)
; -----------------------------------------------------------------------------
d04f3:  55                    display_set_mode_10refs:           push       bp
d04f4:  06                                         push       es
d04f5:  b8 40 50                                   mov        ax, 5040h
d04f8:  8e c0                                      mov        es, ax
d04fa:  8b ec                                      mov        bp, sp
d04fc:  8b 46 08                                   mov        ax, [bp+08h]
d04ff:  e8 7c 00                                   call       display_set_buffer_14refs
d0502:  26 a2 84 00                                mov        es:[0084h], al
d0506:  26 a2 17 01                                mov        es:[0117h], al
d050a:  26 a2 0d 02                                mov        es:[020dh], al
d050e:  e8 8e 00                                   call       display_clear_area_24refs
d0511:  07                                         pop        es
d0512:  5d                                         pop        bp
d0513:  cb                                         retf

;  XREF: d669c, d66c4, d80d1, d80df, da832 (+11 more)

; -----------------------------------------------------------------------------
; display_set_position_16refs (0xD0514)
; Display utility - set display position/offset (16 refs)
; -----------------------------------------------------------------------------
d0514:  06                    display_set_position_16refs:           push       es
d0515:  b8 40 50                                   mov        ax, 5040h
d0518:  8e c0                                      mov        es, ax
d051a:  e8 61 00                                   call       display_set_buffer_14refs
d051d:  26 a0 83 00                                mov        al, es:[0083h]
d0521:  26 3a 06 16 01                             cmp        al, es:[0116h]
d0526:  75 0e                                      jnz        loc_d0536
d0528:  26 3a 06 0c 02                             cmp        al, es:[020ch]
d052d:  75 07                                      jnz        loc_d0536
d052f:  e8 6d 00                                   call       display_clear_area_24refs
d0532:  32 e4                                      xor        ah, ah
d0534:  07                                         pop        es
d0535:  cb                                         retf

;  XREF: d0526, d052d
d0536:  33 c0                 loc_d0536:           xor        ax, ax
d0538:  26 a2 83 00                                mov        es:[0083h], al
d053c:  26 a2 16 01                                mov        es:[0116h], al
d0540:  26 a2 0c 02                                mov        es:[020ch], al
d0544:  e8 58 00                                   call       display_clear_area_24refs
d0547:  07                                         pop        es
d0548:  cb                                         retf

;  XREF: d66a2, d80e5, da84e, da8c4, dc87b (+9 more)

; -----------------------------------------------------------------------------
; display_set_segment_14refs (0xD0549)
; Display utility - set display segment (14 refs)
; -----------------------------------------------------------------------------
d0549:  06                    display_set_segment_14refs:           push       es
d054a:  b8 40 50                                   mov        ax, 5040h
d054d:  8e c0                                      mov        es, ax
d054f:  e8 2c 00                                   call       display_set_buffer_14refs
d0552:  26 a0 84 00                                mov        al, es:[0084h]
d0556:  26 3a 06 17 01                             cmp        al, es:[0117h]
d055b:  75 0e                                      jnz        loc_d056b
d055d:  26 3a 06 0d 02                             cmp        al, es:[020dh]
d0562:  75 07                                      jnz        loc_d056b
d0564:  e8 38 00                                   call       display_clear_area_24refs
d0567:  32 e4                                      xor        ah, ah
d0569:  07                                         pop        es
d056a:  cb                                         retf

;  XREF: d055b, d0562
d056b:  33 c0                 loc_d056b:           xor        ax, ax
d056d:  26 a2 84 00                                mov        es:[0084h], al
d0571:  26 a2 17 01                                mov        es:[0117h], al
d0575:  26 a2 0d 02                                mov        es:[020dh], al
d0579:  e8 23 00                                   call       display_clear_area_24refs
d057c:  07                                         pop        es
d057d:  cb                                         retf

;  XREF: d047a, d0499, d04b3, d04c6, d04de (+9 more)

; -----------------------------------------------------------------------------
; display_set_buffer_14refs (0xD057E)
; Display utility - set display buffer pointer (14 refs)
; -----------------------------------------------------------------------------
d057e:  fa                    display_set_buffer_14refs:           cli
d057f:  1e                                         push       ds
d0580:  06                                         push       es
d0581:  50                                         push       ax
d0582:  b8 00 40                                   mov        ax, 4000h
d0585:  8e d8                                      mov        ds, ax
d0587:  b8 00 a0                                   mov        ax, a000h
d058a:  8e c0                                      mov        es, ax
d058c:  a0 34 11                                   mov        al, [1134h]   ; dmd_display_mode - Current DMD display mode (init: 0x28)
d058f:  24 f7                                      and        al, f7h
d0591:  0c 10                                      or         al, 10h
d0593:  a2 34 11                                   mov        [1134h], al   ; dmd_display_mode - Current DMD display mode (init: 0x28)
d0596:  26 a2 00 00                                mov        es:[0000h], al ; DMD_CTRL1 - DMD control byte 1 (0x28 = display on)
d059a:  58                                         pop        ax
d059b:  07                                         pop        es
d059c:  1f                                         pop        ds
d059d:  fb                                         sti
d059e:  c3                                         ret

;  XREF: d048c, d04a3, d04b9, d04cc, d04ed (+19 more)

; -----------------------------------------------------------------------------
; display_clear_area_24refs (0xD059F)
; Display utility - clear display area (24 refs)
; -----------------------------------------------------------------------------
d059f:  fa                    display_clear_area_24refs:           cli
d05a0:  1e                                         push       ds
d05a1:  06                                         push       es
d05a2:  50                                         push       ax
d05a3:  b8 00 40                                   mov        ax, 4000h
d05a6:  8e d8                                      mov        ds, ax
d05a8:  b8 00 a0                                   mov        ax, a000h
d05ab:  8e c0                                      mov        es, ax
d05ad:  a0 34 11                                   mov        al, [1134h]   ; dmd_display_mode - Current DMD display mode (init: 0x28)
d05b0:  24 ef                                      and        al, efh
d05b2:  0c 08                                      or         al, 08h
d05b4:  a2 34 11                                   mov        [1134h], al   ; dmd_display_mode - Current DMD display mode (init: 0x28)
d05b7:  26 a2 00 00                                mov        es:[0000h], al ; DMD_CTRL1 - DMD control byte 1 (0x28 = display on)
d05bb:  58                                         pop        ax
d05bc:  07                                         pop        es
d05bd:  1f                                         pop        ds
d05be:  fb                                         sti
d05bf:  c3                                         ret

;  XREF: d6232, d6247

; -----------------------------------------------------------------------------
; display_flush_2refs (0xD05C0)
; Display utility - flush pending display operations (2 refs)
; -----------------------------------------------------------------------------
d05c0:  e8 bb ff              display_flush_2refs:           call       display_set_buffer_14refs
d05c3:  b8 40 50                                   mov        ax, 5040h
d05c6:  8e c0                                      mov        es, ax
d05c8:  bb 00 00                                   mov        bx, 0000h
d05cb:  be a9 07                                   mov        si, 07a9h
d05ce:  b9 0f 00                                   mov        cx, 000fh

;  XREF: d05e4
d05d1:  26 8a 07              loc_d05d1:           mov        al, es:[bx]
d05d4:  2e 8a 24                                   mov        ah, cs:[si]
d05d7:  3a c4                                      cmp        al, ah
d05d9:  74 07                                      jz         loc_d05e2
d05db:  e8 c1 ff                                   call       display_clear_area_24refs
d05de:  b8 00 00                                   mov        ax, 0000h
d05e1:  cb                                         retf

;  XREF: d05d9
d05e2:  43                    loc_d05e2:           inc        bx
d05e3:  46                                         inc        si
d05e4:  e2 eb                                      loop       loc_d05d1
d05e6:  b8 40 50                                   mov        ax, 5040h
d05e9:  8e c0                                      mov        es, ax
d05eb:  bb 47 00                                   mov        bx, 0047h
d05ee:  be b8 07                                   mov        si, 07b8h
d05f1:  b9 33 00                                   mov        cx, 0033h

;  XREF: d0607
d05f4:  26 8a 07              loc_d05f4:           mov        al, es:[bx]
d05f7:  2e 8a 24                                   mov        ah, cs:[si]
d05fa:  3a c4                                      cmp        al, ah
d05fc:  74 07                                      jz         loc_d0605
d05fe:  e8 9e ff                                   call       display_clear_area_24refs
d0601:  b8 00 00                                   mov        ax, 0000h
d0604:  cb                                         retf

;  XREF: d05fc
d0605:  43                    loc_d0605:           inc        bx
d0606:  46                                         inc        si
d0607:  e2 eb                                      loop       loc_d05f4
d0609:  b8 40 50                                   mov        ax, 5040h
d060c:  8e c0                                      mov        es, ax
d060e:  bb da 00                                   mov        bx, 00dah
d0611:  be eb 07                                   mov        si, 07ebh
d0614:  b9 20 00                                   mov        cx, 0020h

;  XREF: d062a
d0617:  26 8a 07              loc_d0617:           mov        al, es:[bx]
d061a:  2e 8a 24                                   mov        ah, cs:[si]
d061d:  3a c4                                      cmp        al, ah
d061f:  74 07                                      jz         loc_d0628
d0621:  e8 7b ff                                   call       display_clear_area_24refs
d0624:  b8 00 00                                   mov        ax, 0000h
d0627:  cb                                         retf

;  XREF: d061f
d0628:  43                    loc_d0628:           inc        bx
d0629:  46                                         inc        si
d062a:  e2 eb                                      loop       loc_d0617
d062c:  b8 40 50                                   mov        ax, 5040h
d062f:  8e c0                                      mov        es, ax
d0631:  bb 30 01                                   mov        bx, 0130h
d0634:  be 0b 08                                   mov        si, 080bh
d0637:  b9 35 00                                   mov        cx, 0035h

;  XREF: d064d
d063a:  26 8a 07              loc_d063a:           mov        al, es:[bx]
d063d:  2e 8a 24                                   mov        ah, cs:[si]
d0640:  3a c4                                      cmp        al, ah
d0642:  74 07                                      jz         loc_d064b
d0644:  e8 58 ff                                   call       display_clear_area_24refs
d0647:  b8 00 00                                   mov        ax, 0000h
d064a:  cb                                         retf

;  XREF: d0642
d064b:  43                    loc_d064b:           inc        bx
d064c:  46                                         inc        si
d064d:  e2 eb                                      loop       loc_d063a
d064f:  b8 40 50                                   mov        ax, 5040h
d0652:  8e c0                                      mov        es, ax
d0654:  bb 80 01                                   mov        bx, 0180h
d0657:  be 40 08                                   mov        si, 0840h
d065a:  b9 1a 00                                   mov        cx, 001ah

;  XREF: d0670
d065d:  26 8a 07              loc_d065d:           mov        al, es:[bx]
d0660:  2e 8a 24                                   mov        ah, cs:[si]
d0663:  3a c4                                      cmp        al, ah
d0665:  74 07                                      jz         loc_d066e
d0667:  e8 35 ff                                   call       display_clear_area_24refs
d066a:  b8 00 00                                   mov        ax, 0000h
d066d:  cb                                         retf

;  XREF: d0665
d066e:  43                    loc_d066e:           inc        bx
d066f:  46                                         inc        si
d0670:  e2 eb                                      loop       loc_d065d
d0672:  b8 40 50                                   mov        ax, 5040h
d0675:  8e c0                                      mov        es, ax
d0677:  bb d0 01                                   mov        bx, 01d0h
d067a:  be eb 07                                   mov        si, 07ebh
d067d:  b9 20 00                                   mov        cx, 0020h

;  XREF: d0693
d0680:  26 8a 07              loc_d0680:           mov        al, es:[bx]
d0683:  2e 8a 24                                   mov        ah, cs:[si]
d0686:  3a c4                                      cmp        al, ah
d0688:  74 07                                      jz         loc_d0691
d068a:  e8 12 ff                                   call       display_clear_area_24refs
d068d:  b8 00 00                                   mov        ax, 0000h
d0690:  cb                                         retf

;  XREF: d0688
d0691:  43                    loc_d0691:           inc        bx
d0692:  46                                         inc        si
d0693:  e2 eb                                      loop       loc_d0680
d0695:  b8 40 50                                   mov        ax, 5040h
d0698:  8e c0                                      mov        es, ax
d069a:  bb 7d 02                                   mov        bx, 027dh
d069d:  be 0b 08                                   mov        si, 080bh
d06a0:  b9 35 00                                   mov        cx, 0035h

;  XREF: d06b6
d06a3:  26 8a 07              loc_d06a3:           mov        al, es:[bx]
d06a6:  2e 8a 24                                   mov        ah, cs:[si]
d06a9:  3a c4                                      cmp        al, ah
d06ab:  74 07                                      jz         loc_d06b4
d06ad:  e8 ef fe                                   call       display_clear_area_24refs
d06b0:  b8 00 00                                   mov        ax, 0000h
d06b3:  cb                                         retf

;  XREF: d06ab
d06b4:  43                    loc_d06b4:           inc        bx
d06b5:  46                                         inc        si
d06b6:  e2 eb                                      loop       loc_d06a3
d06b8:  b8 40 50                                   mov        ax, 5040h
d06bb:  8e c0                                      mov        es, ax
d06bd:  bb e1 02                                   mov        bx, 02e1h
d06c0:  be 40 08                                   mov        si, 0840h
d06c3:  b9 1a 00                                   mov        cx, 001ah

;  XREF: d06d9
d06c6:  26 8a 07              loc_d06c6:           mov        al, es:[bx]
d06c9:  2e 8a 24                                   mov        ah, cs:[si]
d06cc:  3a c4                                      cmp        al, ah
d06ce:  74 07                                      jz         loc_d06d7
d06d0:  e8 cc fe                                   call       display_clear_area_24refs
d06d3:  b8 00 00                                   mov        ax, 0000h
d06d6:  cb                                         retf

;  XREF: d06ce
d06d7:  43                    loc_d06d7:           inc        bx
d06d8:  46                                         inc        si
d06d9:  e2 eb                                      loop       loc_d06c6
d06db:  e8 c1 fe                                   call       display_clear_area_24refs
d06de:  b8 01 00                                   mov        ax, 0001h
d06e1:  cb                                         retf

;  XREF: d6242

; -----------------------------------------------------------------------------
; hardware_setup_extended (0xD06E2)
; Extended hardware setup routine
; -----------------------------------------------------------------------------
d06e2:  e8 99 fe              hardware_setup_extended:           call       display_set_buffer_14refs
d06e5:  b8 40 50                                   mov        ax, 5040h
d06e8:  8e c0                                      mov        es, ax
d06ea:  bb 00 00                                   mov        bx, 0000h
d06ed:  be a9 07                                   mov        si, 07a9h
d06f0:  b9 0f 00                                   mov        cx, 000fh

;  XREF: d06fb
d06f3:  2e 8a 04              loc_d06f3:           mov        al, cs:[si]
d06f6:  26 88 07                                   mov        es:[bx], al
d06f9:  43                                         inc        bx
d06fa:  46                                         inc        si
d06fb:  e2 f6                                      loop       loc_d06f3
d06fd:  b8 40 50                                   mov        ax, 5040h
d0700:  8e c0                                      mov        es, ax
d0702:  bb 47 00                                   mov        bx, 0047h
d0705:  be b8 07                                   mov        si, 07b8h
d0708:  b9 33 00                                   mov        cx, 0033h

;  XREF: d0713
d070b:  2e 8a 04              loc_d070b:           mov        al, cs:[si]
d070e:  26 88 07                                   mov        es:[bx], al
d0711:  43                                         inc        bx
d0712:  46                                         inc        si
d0713:  e2 f6                                      loop       loc_d070b
d0715:  b8 40 50                                   mov        ax, 5040h
d0718:  8e c0                                      mov        es, ax
d071a:  bb da 00                                   mov        bx, 00dah
d071d:  be eb 07                                   mov        si, 07ebh
d0720:  b9 20 00                                   mov        cx, 0020h

;  XREF: d072b
d0723:  2e 8a 04              loc_d0723:           mov        al, cs:[si]
d0726:  26 88 07                                   mov        es:[bx], al
d0729:  43                                         inc        bx
d072a:  46                                         inc        si
d072b:  e2 f6                                      loop       loc_d0723
d072d:  b8 40 50                                   mov        ax, 5040h
d0730:  8e c0                                      mov        es, ax
d0732:  bb 30 01                                   mov        bx, 0130h
d0735:  be 0b 08                                   mov        si, 080bh
d0738:  b9 35 00                                   mov        cx, 0035h

;  XREF: d0743
d073b:  2e 8a 04              loc_d073b:           mov        al, cs:[si]
d073e:  26 88 07                                   mov        es:[bx], al
d0741:  43                                         inc        bx
d0742:  46                                         inc        si
d0743:  e2 f6                                      loop       loc_d073b
d0745:  b8 40 50                                   mov        ax, 5040h
d0748:  8e c0                                      mov        es, ax
d074a:  bb 80 01                                   mov        bx, 0180h
d074d:  be 40 08                                   mov        si, 0840h
d0750:  b9 1a 00                                   mov        cx, 001ah

;  XREF: d075b
d0753:  2e 8a 04              loc_d0753:           mov        al, cs:[si]
d0756:  26 88 07                                   mov        es:[bx], al
d0759:  43                                         inc        bx
d075a:  46                                         inc        si
d075b:  e2 f6                                      loop       loc_d0753
d075d:  b8 40 50                                   mov        ax, 5040h
d0760:  8e c0                                      mov        es, ax
d0762:  bb d0 01                                   mov        bx, 01d0h
d0765:  be eb 07                                   mov        si, 07ebh
d0768:  b9 20 00                                   mov        cx, 0020h

;  XREF: d0773
d076b:  2e 8a 04              loc_d076b:           mov        al, cs:[si]
d076e:  26 88 07                                   mov        es:[bx], al
d0771:  43                                         inc        bx
d0772:  46                                         inc        si
d0773:  e2 f6                                      loop       loc_d076b
d0775:  b8 40 50                                   mov        ax, 5040h
d0778:  8e c0                                      mov        es, ax
d077a:  bb 7d 02                                   mov        bx, 027dh
d077d:  be 0b 08                                   mov        si, 080bh
d0780:  b9 35 00                                   mov        cx, 0035h

;  XREF: d078b
d0783:  2e 8a 04              loc_d0783:           mov        al, cs:[si]
d0786:  26 88 07                                   mov        es:[bx], al
d0789:  43                                         inc        bx
d078a:  46                                         inc        si
d078b:  e2 f6                                      loop       loc_d0783
d078d:  b8 40 50                                   mov        ax, 5040h
d0790:  8e c0                                      mov        es, ax
d0792:  bb e1 02                                   mov        bx, 02e1h
d0795:  be 40 08                                   mov        si, 0840h
d0798:  b9 1a 00                                   mov        cx, 001ah

;  XREF: d07a3
d079b:  2e 8a 04              loc_d079b:           mov        al, cs:[si]
d079e:  26 88 07                                   mov        es:[bx], al
d07a1:  43                                         inc        bx
d07a2:  46                                         inc        si
d07a3:  e2 f6                                      loop       loc_d079b
d07a5:  e8 f7 fd                                   call       display_clear_area_24refs
d07a8:  cb                                         retf

;  XREF: d6256

; -----------------------------------------------------------------------------
; attract_mode_display_setup (0xD08C9)
; Setup attract mode display resources (MOONLIGHT/SUNSHINE/STARWAY)
; -----------------------------------------------------------------------------
d08c9:  0e                    attract_mode_display_setup:           push       cs
d08ca:  e8 8a 00                                   call       sound_init
d08cd:  90                                         nop
d08ce:  0e                                         push       cs
d08cf:  e8 a6 00                                   call       sound_play_command
d08d2:  90                                         nop

;  XREF: d092b
d08d3:  e8 40 02              loc_d08d3:           call       watchdog_feed
d08d6:  b9 06 00                                   mov        cx, 0006h

;  XREF: d08df
d08d9:  51                    loc_d08d9:           push       cx
d08da:  0e                                         push       cs
d08db:  e8 e2 fa                                   call       dmd_strobe_pulse
d08de:  59                                         pop        cx
d08df:  e2 f8                                      loop       loc_d08d9
d08e1:  b8 40 50                                   mov        ax, 5040h
d08e4:  8e c0                                      mov        es, ax
d08e6:  e8 95 fc                                   call       display_set_buffer_14refs
d08e9:  26 c6 06 bc 01 06                          mov        byte es:[01bch], 06h
d08ef:  26 c6 06 bd 01 00                          mov        byte es:[01bdh], 00h
d08f5:  26 c6 06 be 01 06                          mov        byte es:[01beh], 06h
d08fb:  e8 a1 fc                                   call       display_clear_area_24refs
d08fe:  cb                                         retf

;  XREF: d663b

; -----------------------------------------------------------------------------
; attract_text_display (0xD08FF)
; Display attract mode text strings
; -----------------------------------------------------------------------------
d08ff:  b8 40 50              attract_text_display:           mov        ax, 5040h
d0902:  8e c0                                      mov        es, ax
d0904:  e8 77 fc                                   call       display_set_buffer_14refs
d0907:  be bc 01                                   mov        si, 01bch
d090a:  26 8a 04                                   mov        al, es:[si]
d090d:  a2 49 11                                   mov        [1149h], al
d0910:  46                                         inc        si
d0911:  26 8a 04                                   mov        al, es:[si]
d0914:  a2 4a 11                                   mov        [114ah], al
d0917:  46                                         inc        si
d0918:  26 8a 04                                   mov        al, es:[si]
d091b:  a2 4b 11                                   mov        [114bh], al
d091e:  e8 7e fc                                   call       display_clear_area_24refs
d0921:  e8 f2 01                                   call       watchdog_feed
d0924:  a0 49 11                                   mov        al, [1149h]
d0927:  3c 65                                      cmp        al, 65h
d0929:  72 02                                      jb         loc_d092d
d092b:  eb a6                                      jmp short  loc_d08d3

;  XREF: d0929
d092d:  22 c0                 loc_d092d:           and        al, al
d092f:  74 09                                      jz         loc_d093a
d0931:  b5 00                                      mov        ch, 00h
d0933:  8a 0e 49 11                                mov        cl, [1149h]
d0937:  e8 e8 01                                   call       watchdog_check

;  XREF: d092f
d093a:  cb                    loc_d093a:           retf

;  XREF: d08ca

; -----------------------------------------------------------------------------
; sound_init (0xD0957)
; Sound system initialization
; -----------------------------------------------------------------------------
d0957:  06                    sound_init:           push       es
d0958:  b8 40 50                                   mov        ax, 5040h
d095b:  8e c0                                      mov        es, ax
d095d:  be 5a 08                                   mov        si, 085ah
d0960:  bf 0e 02                                   mov        di, 020eh
d0963:  b9 6f 00                                   mov        cx, 006fh
d0966:  e8 15 fc                                   call       display_set_buffer_14refs

;  XREF: d0971
d0969:  2e 8a 04              loc_d0969:           mov        al, cs:[si]
d096c:  26 88 05                                   mov        es:[di], al
d096f:  46                                         inc        si
d0970:  47                                         inc        di
d0971:  e2 f6                                      loop       loc_d0969
d0973:  e8 29 fc                                   call       display_clear_area_24refs
d0976:  07                                         pop        es
d0977:  cb                                         retf

;  XREF: d08cf

; -----------------------------------------------------------------------------
; sound_play_command (0xD0978)
; Send sound/music command to Z80 sound CPU via shared RAM
; -----------------------------------------------------------------------------
d0978:  06                    sound_play_command:           push       es
d0979:  b8 40 50                                   mov        ax, 5040h
d097c:  8e c0                                      mov        es, ax
d097e:  e8 fd fb                                   call       display_set_buffer_14refs
d0981:  26 c6 06 b9 02 00                          mov        byte es:[02b9h], 00h
d0987:  e8 15 fc                                   call       display_clear_area_24refs
d098a:  07                                         pop        es
d098b:  cb                                         retf

;  XREF: d08d3, d0921

; -----------------------------------------------------------------------------
; watchdog_feed (0xD0B16)
; Feed hardware watchdog timer (2 refs)
; -----------------------------------------------------------------------------
d0b16:  b9 66 00              watchdog_feed:           mov        cx, 0066h

;  XREF: d0b1f
d0b19:  51                    loc_d0b19:           push       cx
d0b1a:  0e                                         push       cs
d0b1b:  e8 e3 f8                                   call       dmd_mode_set
d0b1e:  59                                         pop        cx
d0b1f:  e2 f8                                      loop       loc_d0b19
d0b21:  c3                                         ret

;  XREF: d0937, d0b28

; -----------------------------------------------------------------------------
; watchdog_check (0xD0B22)
; Check/verify watchdog status (2 refs)
; -----------------------------------------------------------------------------
d0b22:  51                    watchdog_check:           push       cx
d0b23:  0e                                         push       cs
d0b24:  e8 99 f8                                   call       dmd_strobe_pulse
d0b27:  59                                         pop        cx
d0b28:  e2 f8                                      loop       watchdog_check
d0b2a:  c3                                         ret

;  XREF: d0036

; -----------------------------------------------------------------------------
; system_init_final (0xD0B2B)
; Final system initialization before main loop (called from boot sequence)
; -----------------------------------------------------------------------------
d0b2b:  1e                    system_init_final:           push       ds
d0b2c:  b8 00 40                                   mov        ax, 4000h
d0b2f:  8e d8                                      mov        ds, ax
d0b31:  b8 00 a0                                   mov        ax, a000h
d0b34:  c6 06 05 13 00                             mov        byte [1305h], 00h
d0b39:  c6 06 ee 12 00                             mov        byte [12eeh], 00h
d0b3e:  c6 06 02 13 00                             mov        byte [1302h], 00h
d0b43:  c6 06 03 13 00                             mov        byte [1303h], 00h
d0b48:  c6 06 04 13 00                             mov        byte [1304h], 00h
d0b4d:  c7 06 fa 12 00 00                          mov        word [12fah], 0000h
d0b53:  c7 06 fd 12 00 00                          mov        word [12fdh], 0000h
d0b59:  c7 06 00 13 00 00                          mov        word [1300h], 0000h
d0b5f:  c6 06 f9 12 00                             mov        byte [12f9h], 00h
d0b64:  c6 06 fc 12 00                             mov        byte [12fch], 00h
d0b69:  c6 06 ff 12 00                             mov        byte [12ffh], 00h
d0b6e:  1f                                         pop        ds
d0b6f:  cb                                         retf

;  XREF: d352e, d35ce, d3628, d3d39, d3d77 (+15 more)

; -----------------------------------------------------------------------------
; timer_delay (0xD0B70)
; Timer/delay utility function (20 refs) - wait for specified time
; -----------------------------------------------------------------------------
d0b70:  fa                    timer_delay:           cli
d0b71:  55                                         push       bp
d0b72:  8b ec                                      mov        bp, sp
d0b74:  8b 46 06                                   mov        ax, [bp+06h]
d0b77:  32 e4                                      xor        ah, ah
d0b79:  1e                                         push       ds
d0b7a:  50                                         push       ax
d0b7b:  b8 00 40                                   mov        ax, 4000h
d0b7e:  8e d8                                      mov        ds, ax
d0b80:  80 3e 02 13 00                             cmp        byte [1302h], 00h
d0b85:  74 04                                      jz         loc_d0b8b
d0b87:  58                                         pop        ax
d0b88:  eb 67                                      jmp short  loc_d0bf1

;  XREF: d0b85
d0b8b:  b8 00 a0              loc_d0b8b:           mov        ax, a000h
d0b8e:  8e c0                                      mov        es, ax
d0b90:  58                                         pop        ax
d0b91:  50                                         push       ax
d0b92:  3c 00                                      cmp        al, 00h
d0b94:  75 03                                      jnz        loc_d0b99
d0b96:  eb 5d                                      jmp short  loc_d0bf5

;  XREF: d0b94, d0c17
d0b99:  58                    loc_d0b99:           pop        ax
d0b9a:  50                                         push       ax
d0b9b:  a8 80                                      test       al, 80h
d0b9d:  75 03                                      jnz        loc_d0ba2
d0b9f:  eb 41                                      jmp short  loc_d0be2

;  XREF: d0b9d
d0ba2:  f6 06 fc 12 80        loc_d0ba2:           test       byte [12fch], 80h
d0ba7:  75 2d                                      jnz        loc_d0bd6
d0ba9:  f6 06 ff 12 80                             test       byte [12ffh], 80h
d0bae:  75 26                                      jnz        loc_d0bd6
d0bb0:  80 3e fd 12 00                             cmp        byte [12fdh], 00h
d0bb5:  74 0d                                      jz         loc_d0bc4
d0bb7:  80 3e 00 13 00                             cmp        byte [1300h], 00h
d0bbc:  74 0f                                      jz         loc_d0bcd
d0bbe:  e8 f7 00                                   call       config_save_eeprom
d0bc1:  eb 13                                      jmp short  loc_d0bd6

;  XREF: d0bb5, d0be7
d0bc4:  58                    loc_d0bc4:           pop        ax
d0bc5:  0e                                         push       cs
d0bc6:  e8 8e 00                                   call       config_load_defaults
d0bc9:  90                                         nop
d0bca:  eb 25                                      jmp short  loc_d0bf1

;  XREF: d0bbc, d0bee
d0bcd:  58                    loc_d0bcd:           pop        ax
d0bce:  0e                                         push       cs
d0bcf:  e8 b2 00                                   call       config_load_eeprom
d0bd2:  90                                         nop
d0bd3:  eb 1c                                      jmp short  loc_d0bf1

;  XREF: d0ba7, d0bae, d0bc1
d0bd6:  58                    loc_d0bd6:           pop        ax
d0bd7:  a2 f9 12                                   mov        [12f9h], al
d0bda:  c6 06 02 13 ff                             mov        byte [1302h], ffh
d0bdf:  eb 10                                      jmp short  loc_d0bf1

;  XREF: d0b9f
d0be2:  80 3e fd 12 00        loc_d0be2:           cmp        byte [12fdh], 00h
d0be7:  74 db                                      jz         loc_d0bc4
d0be9:  80 3e 00 13 00                             cmp        byte [1300h], 00h
d0bee:  74 dd                                      jz         loc_d0bcd
d0bf0:  58                                         pop        ax

;  XREF: d0b88, d0bca, d0bd3, d0bdf
d0bf1:  1f                    loc_d0bf1:           pop        ds
d0bf2:  5d                                         pop        bp
d0bf3:  fb                                         sti
d0bf4:  cb                                         retf

;  XREF: d0b96
d0bf5:  58                    loc_d0bf5:           pop        ax
d0bf6:  32 e4                                      xor        ah, ah
d0bf8:  a0 05 13                                   mov        al, [1305h]
d0bfb:  be 19 0c                                   mov        si, 0c19h
d0bfe:  03 f0                                      add        si, ax
d0c00:  2e 8a 04                                   mov        al, cs:[si]
d0c03:  80 3e 05 13 05                             cmp        byte [1305h], 05h
d0c08:  75 08                                      jnz        loc_d0c12
d0c0a:  c6 06 05 13 00                             mov        byte [1305h], 00h
d0c0f:  eb 05                                      jmp short  loc_d0c16

;  XREF: d0c08
d0c12:  ff 06 05 13           loc_d0c12:           inc        word [1305h]

;  XREF: d0c0f
d0c16:  50                    loc_d0c16:           push       ax
d0c17:  eb 80                                      jmp short  loc_d0b99

;  XREF: d0bc6

; -----------------------------------------------------------------------------
; config_load_defaults (0xD0C57)
; Load default configuration/factory settings
; -----------------------------------------------------------------------------
d0c57:  50                    config_load_defaults:           push       ax
d0c58:  b8 00 a0                                   mov        ax, a000h
d0c5b:  8e c0                                      mov        es, ax
d0c5d:  58                                         pop        ax
d0c5e:  be 1f 0c                                   mov        si, 0c1fh
d0c61:  32 e4                                      xor        ah, ah
d0c63:  a2 fc 12                                   mov        [12fch], al
d0c66:  0c 80                                      or         al, 80h
d0c68:  26 a2 00 03                                mov        es:[0300h], al ; DMD_ENABLE - DMD enable register (0x80 = enabled)
d0c6c:  24 7f                                      and        al, 7fh
d0c6e:  d1 e0                                      shl        ax, 1
d0c70:  2d 02 00                                   sub        ax, 0002h
d0c73:  03 f0                                      add        si, ax
d0c75:  2e 8b 04                                   mov        ax, cs:[si]
d0c78:  a3 fd 12                                   mov        [12fdh], ax
d0c7b:  e8 64 00                                   call       config_validate
d0c7e:  80 0e 04 13 f0                             or         byte [1304h], f0h
d0c83:  cb                                         retf

;  XREF: d0bcf

; -----------------------------------------------------------------------------
; config_load_eeprom (0xD0C84)
; Load configuration from EEPROM
; -----------------------------------------------------------------------------
d0c84:  50                    config_load_eeprom:           push       ax
d0c85:  b8 00 a0                                   mov        ax, a000h
d0c88:  8e c0                                      mov        es, ax
d0c8a:  58                                         pop        ax
d0c8b:  be 1f 0c                                   mov        si, 0c1fh
d0c8e:  32 e4                                      xor        ah, ah
d0c90:  a2 ff 12                                   mov        [12ffh], al
d0c93:  24 7f                                      and        al, 7fh
d0c95:  26 a2 00 03                                mov        es:[0300h], al ; DMD_ENABLE - DMD enable register (0x80 = enabled)
d0c99:  d1 e0                                      shl        ax, 1
d0c9b:  2d 02 00                                   sub        ax, 0002h
d0c9e:  03 f0                                      add        si, ax
d0ca0:  2e 8b 04                                   mov        ax, cs:[si]
d0ca3:  a3 00 13                                   mov        [1300h], ax
d0ca6:  e8 39 00                                   call       config_validate
d0ca9:  a0 ff 12                                   mov        al, [12ffh]
d0cac:  0c 80                                      or         al, 80h
d0cae:  26 a2 00 03                                mov        es:[0300h], al
d0cb2:  80 0e 04 13 0f                             or         byte [1304h], 0fh
d0cb7:  cb                                         retf

;  XREF: d0bbe

; -----------------------------------------------------------------------------
; config_save_eeprom (0xD0CB8)
; Save configuration to EEPROM
; -----------------------------------------------------------------------------
d0cb8:  b8 00 a0              config_save_eeprom:           mov        ax, a000h
d0cbb:  8e c0                                      mov        es, ax
d0cbd:  26 c6 06 00 03 00                          mov        byte es:[0300h], 00h ; DMD_ENABLE - DMD enable register (0x80 = enabled)
d0cc3:  e8 36 00                                   call       config_apply
d0cc6:  c6 06 fc 12 00                             mov        byte [12fch], 00h
d0ccb:  c6 06 ff 12 00                             mov        byte [12ffh], 00h
d0cd0:  c7 06 fd 12 01 00                          mov        word [12fdh], 0001h
d0cd6:  c7 06 00 13 01 00                          mov        word [1300h], 0001h
d0cdc:  c6 06 03 13 ff                             mov        byte [1303h], ffh
d0ce1:  c3                                         ret

;  XREF: d0c7b, d0ca6

; -----------------------------------------------------------------------------
; config_validate (0xD0CE2)
; Validate configuration data integrity (2 refs)
; -----------------------------------------------------------------------------
d0ce2:  a0 34 11              config_validate:           mov        al, [1134h] ; dmd_display_mode - Current DMD display mode (init: 0x28)
d0ce5:  24 df                                      and        al, dfh
d0ce7:  a2 34 11                                   mov        [1134h], al   ; dmd_display_mode - Current DMD display mode (init: 0x28)
d0cea:  26 a2 00 00                                mov        es:[0000h], al
d0cee:  90                                         nop
d0cef:  a0 34 11                                   mov        al, [1134h]   ; dmd_display_mode - Current DMD display mode (init: 0x28)
d0cf2:  0c 20                                      or         al, 20h
d0cf4:  a2 34 11                                   mov        [1134h], al   ; dmd_display_mode - Current DMD display mode (init: 0x28)
d0cf7:  26 a2 00 00                                mov        es:[0000h], al
d0cfb:  c3                                         ret

;  XREF: d0cc3

; -----------------------------------------------------------------------------
; config_apply (0xD0CFC)
; Apply loaded configuration to game variables
; -----------------------------------------------------------------------------
d0cfc:  a0 34 11              config_apply:           mov        al, [1134h] ; dmd_display_mode - Current DMD display mode (init: 0x28)
d0cff:  24 df                                      and        al, dfh
d0d01:  a2 34 11                                   mov        [1134h], al   ; dmd_display_mode - Current DMD display mode (init: 0x28)
d0d04:  26 a2 00 00                                mov        es:[0000h], al
d0d08:  c3                                         ret

;  XREF: d0284

; -----------------------------------------------------------------------------
; dmd_display_enable (0xD0D09)
; Set DMD display-enable bit 5 of the control byte [1134h] (A000:0000).
; -----------------------------------------------------------------------------
d0d09:  b8 00 a0              dmd_display_enable:           mov        ax, 0a000h
d0d0c:  8e c0                                      mov        es, ax
d0d0e:  a0 34 11                                   mov        al, [1134h]   ; dmd_display_mode - Current DMD display mode (init: 0x28)
d0d11:  0c 20                                      or         al, 20h
d0d13:  a2 34 11                                   mov        [1134h], al   ; dmd_display_mode - Current DMD display mode (init: 0x28)
d0d16:  26 a2 00 00                                mov        es:[0000h], al ; DMD_CTRL1 - DMD control byte 1 (0x28 = display on)
d0d1a:  cb                                         retf

;  XREF: d038d

; -----------------------------------------------------------------------------
; music_sequencer (0xD0D1B)
; Music sequencer / FM player. Walks the song byte-stream at CS:[12EAh] one
; (opcode,value) pair at a time: 0EEh=note duration, 0EFh=tempo divisor,
; 0FFh=end of song, 0DDh=jump; any other byte is written as a YM3812
; (register,data) pair via the OPL2 write primitive.
; -----------------------------------------------------------------------------
d0d1b:  1e                    music_sequencer:           push       ds      ; music sequencer entry (called from frame ISR)
d0d1c:  b8 00 40                                   mov        ax, 4000h
d0d1f:  8e d8                                      mov        ds, ax
d0d21:  80 3e ee 12 00                             cmp        byte [12eeh], 00h ; sequencer enabled? [12EEh]
d0d26:  75 02                                      jne        loc_d0d2a
d0d28:  1f                                         pop        ds
d0d29:  cb                                         retf

;  XREF: d0d26
d0d2a:  83 3e ec 12 00        loc_d0d2a:           cmp        word [12ech], 0000h ; note duration countdown [12ECh]
d0d2f:  74 06                                      je         loc_d0d37
d0d31:  ff 0e ec 12                                dec        word [12ech]
d0d35:  1f                                         pop        ds
d0d36:  cb                                         retf

;  XREF: d0d2f
d0d37:  b8 00 a0              loc_d0d37:           mov        ax, 0a000h    ; music sequencer: load (reg,val) pair from CS:[12EAh]
d0d3a:  8e c0                                      mov        es, ax
d0d3c:  8b 36 ea 12                                mov        si, [12eah]

;  XREF: d0d6f, d0d83, d0d97
d0d40:  2e 8a 24              loc_d0d40:           mov        ah, cs:[si]   ; AH = opcode/reg, AL = value; advance pointer
d0d43:  46                                         inc        si
d0d44:  2e 8a 04                                   mov        al, cs:[si]
d0d47:  46                                         inc        si
d0d48:  89 36 ea 12                                mov        [12eah], si
d0d4c:  80 fc ee                                   cmp        ah, 0eeh      ; opcode 0EEh = note duration
d0d4f:  75 03                                      jne        loc_d0d54
d0d51:  eb 1e                                      jmp short  loc_d0d71
d0d53:  90                                         nop

;  XREF: d0d4f
d0d54:  80 fc ef              loc_d0d54:           cmp        ah, 0efh      ; opcode 0EFh = set tempo divisor
d0d57:  75 03                                      jne        loc_d0d5c
d0d59:  eb 25                                      jmp short  loc_d0d80
d0d5b:  90                                         nop

;  XREF: d0d57
d0d5c:  80 fc ff              loc_d0d5c:           cmp        ah, 0ffh      ; opcode 0FFh = end of song
d0d5f:  75 03                                      jne        loc_d0d64
d0d61:  eb 22                                      jmp short  loc_d0d85
d0d63:  90                                         nop

;  XREF: d0d5f
d0d64:  80 fc dd              loc_d0d64:           cmp        ah, 0ddh      ; opcode 0DDh = jump (set pointer)
d0d67:  75 03                                      jne        loc_d0d6c
d0d69:  eb 27                                      jmp short  loc_d0d92
d0d6b:  90                                         nop

;  XREF: d0d67
d0d6c:  e8 2a 00              loc_d0d6c:           call       ym3812_write  ; default: write (reg,val) to YM3812
d0d6f:  eb cf                                      jmp short  loc_d0d40

;  XREF: d0d51
d0d71:  8a 0e ef 12           loc_d0d71:           mov        cl, [12efh]   ; note duration: duration = value * tempo[12EFh]
d0d75:  32 ed                                      xor        ch, ch
d0d77:  32 e4                                      xor        ah, ah
d0d79:  f7 e1                                      mul        cx
d0d7b:  a3 ec 12                                   mov        [12ech], ax
d0d7e:  1f                                         pop        ds
d0d7f:  cb                                         retf

;  XREF: d0d59
d0d80:  a2 ef 12              loc_d0d80:           mov        [12efh], al   ; set tempo divisor [12EFh]
d0d83:  eb bb                                      jmp short  loc_d0d40

;  XREF: d0d61
d0d85:  c6 06 ee 12 00        loc_d0d85:           mov        byte [12eeh], 00h ; end of song: stop sequencer
d0d8a:  c7 06 ec 12 00 00                          mov        word [12ech], 0000h
d0d90:  1f                                         pop        ds
d0d91:  cb                                         retf

;  XREF: d0d69
d0d92:  2e 8a 24              loc_d0d92:           mov        ah, cs:[si]   ; jump: load new pointer from CS:[si]
d0d95:  8b f0                                      mov        si, ax
d0d97:  eb a7                                      jmp short  loc_d0d40

;  XREF: d0d6c

; -----------------------------------------------------------------------------
; ym3812_write (0xD0D99)
; YM3812 (OPL2) register write primitive. Writes the register index to the
; PCS5 latch A000:0280 then the data byte to A000:0281, with the mandatory
; OPL2 inter-write settling delay after each access.
; -----------------------------------------------------------------------------
d0d99:  26 88 26 80 02        ym3812_write:           mov        es:[0280h], ah ; YM3812 register-index write (PCS5 0xA0280)
d0d9e:  e8 08 00                                   call       opl2_delay
d0da1:  26 a2 81 02                                mov        es:[0281h], al ; YM3812 register-data write (0xA0281)
d0da5:  e8 01 00                                   call       opl2_delay
d0da8:  c3                                         ret

;  XREF: d0d9e, d0da5

; -----------------------------------------------------------------------------
; opl2_delay (0xD0DA9)
; OPL2 inter-write settling delay (busy-wait, ~10 iterations).
; -----------------------------------------------------------------------------
d0da9:  50                    opl2_delay:           push       ax           ; OPL2 inter-write settling delay
d0daa:  b0 0a                                      mov        al, 0ah

;  XREF: d0db0
d0dac:  fe c8                 loc_d0dac:           dec        al
d0dae:  22 c0                                      and        al, al
d0db0:  75 fa                                      jne        loc_d0dac
d0db2:  58                                         pop        ax
d0db3:  c3                                         ret

;  XREF: d2ffc, d30e2, d381f, d3834, d3903 (+5 more)

; -----------------------------------------------------------------------------
; game_mode_set (0xD0DB4)
; Set game mode/state (10 refs). Param: mode byte on stack
; -----------------------------------------------------------------------------
d0db4:  fa                    game_mode_set:           cli
d0db5:  55                                         push       bp
d0db6:  8b ec                                      mov        bp, sp
d0db8:  8b 46 06                                   mov        ax, [bp+06h]
d0dbb:  32 e4                                      xor        ah, ah
d0dbd:  8b f0                                      mov        si, ax
d0dbf:  1e                                         push       ds
d0dc0:  b8 00 40                                   mov        ax, 4000h
d0dc3:  8e d8                                      mov        ds, ax
d0dc5:  c6 06 ee 12 00                             mov        byte [12eeh], 00h
d0dca:  d1 e6                                      shl        si, 1
d0dcc:  81 c6 e5 0d                                add        word si, 0de5h
d0dd0:  2e 8b 04                                   mov        ax, cs:[si]
d0dd3:  a3 ea 12                                   mov        [12eah], ax
d0dd6:  c7 06 ec 12 00 00                          mov        word [12ech], 0000h
d0ddc:  c6 06 ee 12 ff                             mov        byte [12eeh], ffh
d0de1:  1f                                         pop        ds
d0de2:  5d                                         pop        bp
d0de3:  fb                                         sti
d0de4:  cb                                         retf

;  XREF: d003c

; -----------------------------------------------------------------------------
; main_game_loop (0xD2F22)
; MAIN GAME LOOP entry point. Runs display, game logic, state machine dispatcher
; -----------------------------------------------------------------------------
d2f22:  1e                    main_game_loop:           push       ds
d2f23:  b8 30 41                                   mov        ax, 4130h
d2f26:  8e d8                                      mov        ds, ax
d2f28:  68 40 50                                   push       5040h
d2f2b:  68 bf 01                                   push       01bfh
d2f2e:  9a bf 04 00 d0                             call       display_check_status_48refs
d2f33:  83 c4 04                                   add        word sp, 04h
d2f36:  ba 00 40                                   mov        dx, 4000h
d2f39:  8e c2                                      mov        es, dx
d2f3b:  26 a2 01 10                                mov        es:[1001h], al
d2f3f:  9a 13 22 f2 d2                             call       game_state_update
d2f44:  9a ab 01 25 dd                             call       frame_processing_additional
d2f49:  b8 3c 41                                   mov        ax, 413ch
d2f4c:  8e c0                                      mov        es, ax
d2f4e:  26 c6 06 4f 01 00                          mov        byte es:[014fh], 00h ; game_state_var - STATE MACHINE variable: 0=init, 1=attract, 2=game_active, 4=special_mode
d2f54:  9a 8d 26 f2 d2                             call       input_poll_init

;  XREF: d2f60

; -----------------------------------------------------------------------------
; main_loop_wait_vsync (0xD2F59)
; Wait loop: polls vsync_check() until non-zero return (frame sync)
; -----------------------------------------------------------------------------
d2f59:  9a fb 2d f2 d2        main_loop_wait_vsync:           call       vsync_check
d2f5e:  0a c0                                      or         al, al
d2f60:  74 f7                                      jz         main_loop_wait_vsync
d2f62:  b8 3c 41                                   mov        ax, 413ch
d2f65:  8e c0                                      mov        es, ax
d2f67:  26 c6 06 d9 00 00                          mov        byte es:[00d9h], 00h ; game_flag_2 - General game flag 2 (checked in main loop)
d2f6d:  9a 25 2b f2 d2                             call       process_input_events
d2f72:  9a 0c 33 f2 d2                             call       default_game_logic
d2f77:  b8 3c 41                                   mov        ax, 413ch
d2f7a:  8e c0                                      mov        es, ax
d2f7c:  26 80 3e d9 00 00                          cmp        byte es:[00d9h], 00h ; game_flag_2 - General game flag 2 (checked in main loop)
d2f82:  75 37                                      jnz        main_loop_no_game_start
d2f84:  68 40 50                                   push       5040h
d2f87:  68 1d 03                                   push       031dh
d2f8a:  9a bf 04 00 d0                             call       display_check_status_48refs
d2f8f:  83 c4 04                                   add        word sp, 04h
d2f92:  0a c0                                      or         al, al
d2f94:  74 25                                      jz         main_loop_no_game_start
d2f96:  68 c0 00                                   push       00c0h
d2f99:  9a 38 01 00 d0                             call       cmd_queue_push
d2f9e:  59                                         pop        cx

;  XREF: d2fa6
d2f9f:  9a 5a 2f f2 d2        loc_d2f9f:           call       wait_for_event
d2fa4:  0a c0                                      or         al, al
d2fa6:  74 f7                                      jz         loc_d2f9f
d2fa8:  80 3e 06 00 7a                             cmp        byte [0006h], 7ah
d2fad:  74 0c                                      jz         main_loop_no_game_start
d2faf:  9a 48 25 f2 d2                             call       drop_target_bank_handler
d2fb4:  9a 03 00 25 dd                             call       game_mode_transition
d2fb9:  eb 10                                      jmp short  main_loop_frame_end

;  XREF: d2f82, d2f94, d2fad

; -----------------------------------------------------------------------------
; main_loop_no_game_start (0xD2FBB)
; Branch: no game start detected, clear display resource
; -----------------------------------------------------------------------------
d2fbb:  6a 00                 main_loop_no_game_start:           push       00h
d2fbd:  68 40 50                                   push       5040h
d2fc0:  68 1d 03                                   push       031dh
d2fc3:  9a a9 04 00 d0                             call       display_load_resource_51refs
d2fc8:  83 c4 06                                   add        word sp, 06h

;  XREF: d2fb9

; -----------------------------------------------------------------------------
; main_loop_frame_end (0xD2FCB)
; End of frame processing: input scan, display update, enter state machine
; -----------------------------------------------------------------------------
d2fcb:  9a b1 2b f2 d2        main_loop_frame_end:           call       lamp_matrix_update
d2fd0:  9a be 31 f2 d2                             call       playfield_logic_update
d2fd5:  b8 3c 41                                   mov        ax, 413ch
d2fd8:  8e c0                                      mov        es, ax
d2fda:  26 c6 06 4f 01 01                          mov        byte es:[014fh], 01h ; game_state_var - STATE MACHINE variable: 0=init, 1=attract, 2=game_active, 4=special_mode
d2fe0:  b8 3c 41                                   mov        ax, 413ch
d2fe3:  8e c0                                      mov        es, ax
d2fe5:  26 c6 06 d7 00 00                          mov        byte es:[00d7h], 00h ; game_flag_1 - General game flag 1
d2feb:  9a 01 4a 2a d7                             call       game_reset_state
d2ff0:  9a 0d 32 f2 d2                             call       multiball_logic_update
d2ff5:  9a f2 37 2a d7                             call       game_init_display
d2ffa:  6a 00                                      push       00h
d2ffc:  9a b4 0d 00 d0                             call       game_mode_set
d3001:  59                                         pop        cx

;  XREF: d3023, d302a, d3031, d3038

; -----------------------------------------------------------------------------
; state_machine_dispatch (0xD3002)
; STATE MACHINE DISPATCHER: reads game_state_var (413C:014F), dispatches to handlers. States: 1=attract, 2=game_active, 4=special_mode
; -----------------------------------------------------------------------------
d3002:  b8 3c 41              state_machine_dispatch:           mov        ax, 413ch
d3005:  8e c0                                      mov        es, ax
d3007:  26 a0 4f 01                                mov        al, es:[014fh] ; game_state_var - STATE MACHINE variable: 0=init, 1=attract, 2=game_active, 4=special_mode
d300b:  b4 00                                      mov        ah, 00h
d300d:  3d 01 00                                   cmp        ax, 0001h     ; State 1: attract mode?
d3010:  74 0c                                      jz         state_dispatch_attract
d3012:  3d 02 00                                   cmp        ax, 0002h     ; State 2: game active?
d3015:  74 0e                                      jz         state_dispatch_game
d3017:  3d 04 00                                   cmp        ax, 0004h     ; State 4: special mode?
d301a:  74 10                                      jz         state_dispatch_special
d301c:  eb 15                                      jmp short  state_dispatch_default

;  XREF: d3010

; -----------------------------------------------------------------------------
; state_dispatch_attract (0xD301E)
; Dispatch: state 1 -> attract_mode_handler
; -----------------------------------------------------------------------------
d301e:  9a 1c 01 f2 d2        state_dispatch_attract:           call       attract_mode_handler
d3023:  eb dd                                      jmp short  state_machine_dispatch

;  XREF: d3015

; -----------------------------------------------------------------------------
; state_dispatch_game (0xD3025)
; Dispatch: state 2 -> game_active_handler
; -----------------------------------------------------------------------------
d3025:  9a 5f 01 f2 d2        state_dispatch_game:           call       game_active_handler
d302a:  eb d6                                      jmp short  state_machine_dispatch

;  XREF: d301a

; -----------------------------------------------------------------------------
; state_dispatch_special (0xD302C)
; Dispatch: state 4 -> special_mode_handler
; -----------------------------------------------------------------------------
d302c:  9a 25 02 f2 d2        state_dispatch_special:           call       special_mode_handler
d3031:  eb cf                                      jmp short  state_machine_dispatch

;  XREF: d301c

; -----------------------------------------------------------------------------
; state_dispatch_default (0xD3033)
; Dispatch: unknown state -> default_game_logic
; -----------------------------------------------------------------------------
d3033:  9a 0c 33 f2 d2        state_dispatch_default:           call       default_game_logic
d3038:  eb c8                                      jmp short  state_machine_dispatch

;  XREF: d301e

; -----------------------------------------------------------------------------
; attract_mode_handler (0xD303C)
; STATE 1 HANDLER: Attract mode / idle. Checks for credit insert (413C:00D4), transitions to state 2 on coin-up
; -----------------------------------------------------------------------------
d303c:  1e                    attract_mode_handler:           push       ds
d303d:  b8 30 41                                   mov        ax, 4130h
d3040:  8e d8                                      mov        ds, ax
d3042:  b8 3c 41                                   mov        ax, 413ch
d3045:  8e c0                                      mov        es, ax
d3047:  26 c6 06 dd 00 01                          mov        byte es:[00ddh], 01h ; attract_mode_active - Set to 1 when in attract mode
d304d:  b8 3c 41                                   mov        ax, 413ch
d3050:  8e c0                                      mov        es, ax
d3052:  26 c6 06 9e 00 00                          mov        byte es:[009eh], 00h ; game_active_flag - Non-zero when game is in progress
d3058:  9a 31 03 f2 d2                             call       attract_display_update
d305d:  9a 1c 08 2a d7                             call       dmd_attract_cycle
d3062:  b8 3c 41                                   mov        ax, 413ch
d3065:  8e c0                                      mov        es, ax
d3067:  26 80 3e d4 00 00                          cmp        byte es:[00d4h], 00h ; credit_available - Non-zero when credits are available for game start
d306d:  74 0b                                      jz         loc_d307a
d306f:  b8 3c 41                                   mov        ax, 413ch
d3072:  8e c0                                      mov        es, ax
d3074:  26 c6 06 4f 01 02                          mov        byte es:[014fh], 02h ; game_state_var - STATE MACHINE variable: 0=init, 1=attract, 2=game_active, 4=special_mode

;  XREF: d306d
d307a:  b8 01 00              loc_d307a:           mov        ax, 0001h
d307d:  1f                                         pop        ds
d307e:  cb                                         retf

;  XREF: d3025

; -----------------------------------------------------------------------------
; game_active_handler (0xD307F)
; STATE 2 HANDLER: Game in progress. Manages ball serving, scoring, multiball, end-of-ball
; -----------------------------------------------------------------------------
d307f:  1e                    game_active_handler:           push       ds
d3080:  b8 30 41                                   mov        ax, 4130h
d3083:  8e d8                                      mov        ds, ax
d3085:  6a 5d                                      push       5dh
d3087:  9a 38 01 00 d0                             call       cmd_queue_push
d308c:  59                                         pop        cx
d308d:  e9 a0 00                                   jmp        loc_d3130

;  XREF: d313d
d3090:  b8 3c 41              loc_d3090:           mov        ax, 413ch
d3093:  8e c0                                      mov        es, ax
d3095:  26 80 3e d4 00 00                          cmp        byte es:[00d4h], 00h ; credit_available - Non-zero when credits are available for game start
d309b:  75 16                                      jnz        loc_d30b3
d309d:  b8 3c 41                                   mov        ax, 413ch
d30a0:  8e c0                                      mov        es, ax
d30a2:  26 c6 06 4f 01 01                          mov        byte es:[014fh], 01h ; game_state_var - STATE MACHINE variable: 0=init, 1=attract, 2=game_active, 4=special_mode
d30a8:  6a 5e                                      push       5eh
d30aa:  9a 38 01 00 d0                             call       cmd_queue_push
d30af:  59                                         pop        cx
d30b0:  e9 8d 00                                   jmp        loc_d3140

;  XREF: d309b
d30b3:  9a 89 5a 2a d7        loc_d30b3:           call       credits_display_check
d30b8:  b8 3c 41                                   mov        ax, 413ch
d30bb:  8e c0                                      mov        es, ax
d30bd:  26 c6 06 9e 00 00                          mov        byte es:[009eh], 00h ; game_active_flag - Non-zero when game is in progress
d30c3:  9a db 03 f2 d2                             call       attract_animation_cycle
d30c8:  b8 3c 41                                   mov        ax, 413ch
d30cb:  8e c0                                      mov        es, ax
d30cd:  26 80 3e 4f 01 03                          cmp        byte es:[014fh], 03h ; game_state_var - STATE MACHINE variable: 0=init, 1=attract, 2=game_active, 4=special_mode
d30d3:  75 5b                                      jnz        loc_d3130
d30d5:  b8 3c 41                                   mov        ax, 413ch
d30d8:  8e c0                                      mov        es, ax
d30da:  26 c6 06 dd 00 00                          mov        byte es:[00ddh], 00h ; attract_mode_active - Set to 1 when in attract mode
d30e0:  6a 01                                      push       01h
d30e2:  9a b4 0d 00 d0                             call       game_mode_set
d30e7:  59                                         pop        cx
d30e8:  6a 00                                      push       00h
d30ea:  9a fa 0f 00 f0                             call       rom_checksum_verify
d30ef:  59                                         pop        cx
d30f0:  68 b2 00                                   push       00b2h
d30f3:  9a 73 0f 00 f0                             call       eeprom_validate
d30f8:  59                                         pop        cx
d30f9:  b8 3c 41                                   mov        ax, 413ch
d30fc:  8e c0                                      mov        es, ax
d30fe:  26 c6 06 de 00 01                          mov        byte es:[00deh], 01h
d3104:  6a 5d                                      push       5dh
d3106:  9a 38 01 00 d0                             call       cmd_queue_push
d310b:  59                                         pop        cx
d310c:  b8 3c 41                                   mov        ax, 413ch
d310f:  8e c0                                      mov        es, ax
d3111:  26 c6 06 db 00 00                          mov        byte es:[00dbh], 00h
d3117:  68 a9 00                                   push       00a9h
d311a:  9a 38 01 00 d0                             call       cmd_queue_push
d311f:  59                                         pop        cx
d3120:  9a 37 55 2a d7                             call       dmd_game_over_display
d3125:  b8 3c 41                                   mov        ax, 413ch
d3128:  8e c0                                      mov        es, ax
d312a:  26 c6 06 de 00 00                          mov        byte es:[00deh], 00h

;  XREF: d308d, d30d3
d3130:  b8 3c 41              loc_d3130:           mov        ax, 413ch
d3133:  8e c0                                      mov        es, ax
d3135:  26 80 3e 4f 01 04                          cmp        byte es:[014fh], 04h ; game_state_var - STATE MACHINE variable: 0=init, 1=attract, 2=game_active, 4=special_mode
d313b:  74 03                                      jz         loc_d3140
d313d:  e9 50 ff                                   jmp        loc_d3090

;  XREF: d30b0, d313b
d3140:  b8 01 00              loc_d3140:           mov        ax, 0001h
d3143:  1f                                         pop        ds
d3144:  cb                                         retf

;  XREF: d302c

; -----------------------------------------------------------------------------
; special_mode_handler (0xD3145)
; STATE 4 HANDLER: Special game mode (multiball, bonus round, etc.)
; -----------------------------------------------------------------------------
d3145:  1e                    special_mode_handler:           push       ds
d3146:  b8 30 41                                   mov        ax, 4130h
d3149:  8e d8                                      mov        ds, ax
d314b:  b8 3c 41                                   mov        ax, 413ch
d314e:  8e c0                                      mov        es, ax
d3150:  26 80 3e 4f 01 04                          cmp        byte es:[014fh], 04h ; game_state_var - STATE MACHINE variable: 0=init, 1=attract, 2=game_active, 4=special_mode
d3156:  74 03                                      jz         loc_d315b
d3158:  e9 f1 00                                   jmp        loc_d324c

;  XREF: d3156
d315b:  b8 3c 41              loc_d315b:           mov        ax, 413ch
d315e:  8e c0                                      mov        es, ax
d3160:  26 c6 06 ea 00 01                          mov        byte es:[00eah], 01h
d3166:  b8 3c 41                                   mov        ax, 413ch
d3169:  8e c0                                      mov        es, ax
d316b:  26 ff 36 f2 00                             push       word es:[00f2h]
d3170:  26 ff 36 f0 00                             push       word es:[00f0h]
d3175:  68 3c 41                                   push       413ch
d3178:  68 e1 00                                   push       00e1h
d317b:  9a 20 57 2a d7                             call       score_compare_and_cap
d3180:  83 c4 08                                   add        word sp, 08h
d3183:  6a 00                                      push       00h
d3185:  68 3c 41                                   push       413ch
d3188:  68 e1 00                                   push       00e1h
d318b:  9a 07 09 00 f0                             call       dmd_frame_load
d3190:  83 c4 06                                   add        word sp, 06h
d3193:  b8 00 40                                   mov        ax, 4000h
d3196:  8e c0                                      mov        es, ax
d3198:  26 c7 06 3d 11 b0 04                       mov        word es:[113dh], 04b0h
d319f:  c6 06 11 00 00                             mov        byte [0011h], 00h
d31a4:  e9 95 00                                   jmp        loc_d323c

;  XREF: d3249
d31a7:  9a d1 07 f2 d2        loc_d31a7:           call       end_of_ball
d31ac:  9a 96 03 2a d7                             call       dmd_clear_screen
d31b1:  0b c0                                      or         ax, ax
d31b3:  74 07                                      jz         loc_d31bc
d31b5:  9a 31 08 f2 d2                             call       bonus_countdown
d31ba:  eb 05                                      jmp short  loc_d31c1

;  XREF: d31b3
d31bc:  9a 81 08 f2 d2        loc_d31bc:           call       extra_ball_check

;  XREF: d31ba
d31c1:  b8 3c 41              loc_d31c1:           mov        ax, 413ch
d31c4:  8e c0                                      mov        es, ax
d31c6:  26 80 3e eb 00 00                          cmp        byte es:[00ebh], 00h
d31cc:  74 6e                                      jz         loc_d323c
d31ce:  9a ee 08 f2 d2                             call       player_advance
d31d3:  9a 6c 07 f2 d2                             call       ball_drain_handler
d31d8:  0b c0                                      or         ax, ax
d31da:  74 07                                      jz         loc_d31e3
d31dc:  9a 7d 15 f2 d2                             call       score_display_update
d31e1:  eb 59                                      jmp short  loc_d323c

;  XREF: d31da
d31e3:  b8 3c 41              loc_d31e3:           mov        ax, 413ch
d31e6:  8e c0                                      mov        es, ax
d31e8:  26 80 3e db 00 01                          cmp        byte es:[00dbh], 01h
d31ee:  75 05                                      jnz        loc_d31f5
d31f0:  9a 36 09 f2 d2                             call       tilt_handler

;  XREF: d31ee
d31f5:  9a 00 0a f2 d2        loc_d31f5:           call       jackpot_handler
d31fa:  0b c0                                      or         ax, ax
d31fc:  74 39                                      jz         loc_d3237
d31fe:  9a a3 09 f2 d2                             call       multiball_handler
d3203:  9a ab 54 2a d7                             call       dmd_end_of_ball_display
d3208:  b8 3c 41                                   mov        ax, 413ch
d320b:  8e c0                                      mov        es, ax
d320d:  26 ff 36 f2 00                             push       word es:[00f2h]
d3212:  26 ff 36 f0 00                             push       word es:[00f0h]
d3217:  68 3c 41                                   push       413ch
d321a:  68 e1 00                                   push       00e1h
d321d:  9a 20 57 2a d7                             call       score_compare_and_cap
d3222:  83 c4 08                                   add        word sp, 08h
d3225:  6a 00                                      push       00h
d3227:  68 3c 41                                   push       413ch
d322a:  68 e1 00                                   push       00e1h
d322d:  9a 07 09 00 f0                             call       dmd_frame_load
d3232:  83 c4 06                                   add        word sp, 06h
d3235:  eb 05                                      jmp short  loc_d323c

;  XREF: d31fc
d3237:  9a d8 17 f2 d2        loc_d3237:           call       match_sequence

;  XREF: d31a4, d31cc, d31e1, d3235
d323c:  b8 3c 41              loc_d323c:           mov        ax, 413ch
d323f:  8e c0                                      mov        es, ax
d3241:  26 80 3e 4f 01 04                          cmp        byte es:[014fh], 04h ; game_state_var - STATE MACHINE variable: 0=init, 1=attract, 2=game_active, 4=special_mode
d3247:  75 03                                      jnz        loc_d324c
d3249:  e9 5b ff                                   jmp        loc_d31a7

;  XREF: d3158, d3247
d324c:  b8 01 00              loc_d324c:           mov        ax, 0001h
d324f:  1f                                         pop        ds
d3250:  cb                                         retf

;  XREF: d3058

; -----------------------------------------------------------------------------
; attract_display_update (0xD3251)
; Update attract mode display (scrolling text, high scores)
; -----------------------------------------------------------------------------
d3251:  1e                    attract_display_update:           push       ds
d3252:  b8 30 41                                   mov        ax, 4130h
d3255:  8e d8                                      mov        ds, ax
d3257:  9a c4 00 00 f0                             call       dmd_buffer_swap
d325c:  9a f1 00 00 f0                             call       dmd_buffer_clear
d3261:  b8 3c 41                                   mov        ax, 413ch
d3264:  8e c0                                      mov        es, ax
d3266:  26 c6 06 a0 00 00                          mov        byte es:[00a0h], 00h
d326c:  b8 3c 41                                   mov        ax, 413ch
d326f:  8e c0                                      mov        es, ax
d3271:  26 c6 06 df 00 00                          mov        byte es:[00dfh], 00h
d3277:  b8 00 40                                   mov        ax, 4000h
d327a:  8e c0                                      mov        es, ax
d327c:  26 80 3e 01 10 05                          cmp        byte es:[1001h], 05h ; game_status_byte - Overall game status communicated to Z80
d3282:  75 07                                      jnz        loc_d328b
d3284:  9a 60 41 00 f0                             call       font_glyph_lookup
d3289:  eb 65                                      jmp short  loc_d32f0

;  XREF: d3282
d328b:  9a 28 49 00 f0        loc_d328b:           call       string_encoding_decode
d3290:  eb 5e                                      jmp short  loc_d32f0

;  XREF: d32f7
d3292:  b8 3c 41              loc_d3292:           mov        ax, 413ch
d3295:  8e c0                                      mov        es, ax
d3297:  26 80 3e d4 00 00                          cmp        byte es:[00d4h], 00h ; credit_available - Non-zero when credits are available for game start
d329d:  75 0d                                      jnz        loc_d32ac
d329f:  b8 3c 41                                   mov        ax, 413ch
d32a2:  8e c0                                      mov        es, ax
d32a4:  26 80 3e d6 00 3f                          cmp        byte es:[00d6h], 3fh ; last_switch_code - Last switch code received from Z80
d32aa:  75 07                                      jnz        loc_d32b3

;  XREF: d329d, d32d8
d32ac:  9a f2 37 2a d7        loc_d32ac:           call       game_init_display
d32b1:  eb 46                                      jmp short  loc_d32f9

;  XREF: d32aa
d32b3:  b8 3c 41              loc_d32b3:           mov        ax, 413ch
d32b6:  8e c0                                      mov        es, ax
d32b8:  26 80 3e df 00 00                          cmp        byte es:[00dfh], 00h
d32be:  74 1a                                      jz         loc_d32da
d32c0:  b8 3c 41                                   mov        ax, 413ch
d32c3:  8e c0                                      mov        es, ax
d32c5:  26 80 3e 9e 00 00                          cmp        byte es:[009eh], 00h ; game_active_flag - Non-zero when game is in progress
d32cb:  74 0d                                      jz         loc_d32da
d32cd:  b8 3c 41                                   mov        ax, 413ch
d32d0:  8e c0                                      mov        es, ax
d32d2:  26 c6 06 df 00 00                          mov        byte es:[00dfh], 00h
d32d8:  eb d2                                      jmp short  loc_d32ac

;  XREF: d32be, d32cb
d32da:  b8 3c 41              loc_d32da:           mov        ax, 413ch
d32dd:  8e c0                                      mov        es, ax
d32df:  26 c6 06 df 00 00                          mov        byte es:[00dfh], 00h
d32e5:  b8 00 40                                   mov        ax, 4000h
d32e8:  8e c0                                      mov        es, ax
d32ea:  26 c6 06 f1 10 ff                          mov        byte es:[10f1h], ffh

;  XREF: d3289, d3290
d32f0:  9a 1c 08 2a d7        loc_d32f0:           call       dmd_attract_cycle
d32f5:  0b c0                                      or         ax, ax
d32f7:  74 99                                      jz         loc_d3292

;  XREF: d32b1
d32f9:  1f                    loc_d32f9:           pop        ds
d32fa:  cb                                         retf

;  XREF: d30c3

; -----------------------------------------------------------------------------
; attract_animation_cycle (0xD32FB)
; Cycle attract mode animations
; -----------------------------------------------------------------------------
d32fb:  1e                    attract_animation_cycle:           push       ds
d32fc:  b8 30 41                                   mov        ax, 4130h
d32ff:  8e d8                                      mov        ds, ax
d3301:  9a c4 00 00 f0                             call       dmd_buffer_swap
d3306:  9a f1 00 00 f0                             call       dmd_buffer_clear
d330b:  b8 3c 41                                   mov        ax, 413ch
d330e:  8e c0                                      mov        es, ax
d3310:  26 c6 06 a0 00 01                          mov        byte es:[00a0h], 01h
d3316:  b8 3c 41                                   mov        ax, 413ch
d3319:  8e c0                                      mov        es, ax
d331b:  26 c6 06 df 00 00                          mov        byte es:[00dfh], 00h
d3321:  b8 00 40                                   mov        ax, 4000h
d3324:  8e c0                                      mov        es, ax
d3326:  26 80 3e 01 10 05                          cmp        byte es:[1001h], 05h ; game_status_byte - Overall game status communicated to Z80
d332c:  75 07                                      jnz        loc_d3335
d332e:  9a 60 41 00 f0                             call       font_glyph_lookup
d3333:  eb 65                                      jmp short  loc_d339a

;  XREF: d332c
d3335:  9a 28 49 00 f0        loc_d3335:           call       string_encoding_decode
d333a:  eb 5e                                      jmp short  loc_d339a

;  XREF: d33a1
d333c:  b8 3c 41              loc_d333c:           mov        ax, 413ch
d333f:  8e c0                                      mov        es, ax
d3341:  26 80 3e 4f 01 03                          cmp        byte es:[014fh], 03h ; game_state_var - STATE MACHINE variable: 0=init, 1=attract, 2=game_active, 4=special_mode
d3347:  74 0d                                      jz         loc_d3356
d3349:  b8 3c 41                                   mov        ax, 413ch
d334c:  8e c0                                      mov        es, ax
d334e:  26 80 3e d6 00 3f                          cmp        byte es:[00d6h], 3fh ; last_switch_code - Last switch code received from Z80
d3354:  75 07                                      jnz        loc_d335d

;  XREF: d3347, d3382
d3356:  9a f2 37 2a d7        loc_d3356:           call       game_init_display
d335b:  eb 46                                      jmp short  loc_d33a3

;  XREF: d3354
d335d:  b8 3c 41              loc_d335d:           mov        ax, 413ch
d3360:  8e c0                                      mov        es, ax
d3362:  26 80 3e df 00 00                          cmp        byte es:[00dfh], 00h
d3368:  74 1a                                      jz         loc_d3384
d336a:  b8 3c 41                                   mov        ax, 413ch
d336d:  8e c0                                      mov        es, ax
d336f:  26 80 3e 9e 00 00                          cmp        byte es:[009eh], 00h ; game_active_flag - Non-zero when game is in progress
d3375:  74 0d                                      jz         loc_d3384
d3377:  b8 3c 41                                   mov        ax, 413ch
d337a:  8e c0                                      mov        es, ax
d337c:  26 c6 06 df 00 00                          mov        byte es:[00dfh], 00h
d3382:  eb d2                                      jmp short  loc_d3356

;  XREF: d3368, d3375
d3384:  b8 3c 41              loc_d3384:           mov        ax, 413ch
d3387:  8e c0                                      mov        es, ax
d3389:  26 c6 06 df 00 00                          mov        byte es:[00dfh], 00h
d338f:  b8 00 40                                   mov        ax, 4000h
d3392:  8e c0                                      mov        es, ax
d3394:  26 c6 06 f1 10 ff                          mov        byte es:[10f1h], ffh

;  XREF: d3333, d333a
d339a:  9a 1c 08 2a d7        loc_d339a:           call       dmd_attract_cycle
d339f:  0b c0                                      or         ax, ax
d33a1:  74 99                                      jz         loc_d333c

;  XREF: d335b
d33a3:  1f                    loc_d33a3:           pop        ds
d33a4:  cb                                         retf

;  XREF: dc7f0

; -----------------------------------------------------------------------------
; game_start_sequence (0xD33A5)
; Game start sequence: initialize player data, serve first ball
; -----------------------------------------------------------------------------
d33a5:  1e                    game_start_sequence:           push       ds
d33a6:  b8 30 41                                   mov        ax, 4130h
d33a9:  8e d8                                      mov        ds, ax
d33ab:  c7 06 0e 00 00 00                          mov        word [000eh], 0000h
d33b1:  b8 3c 41                                   mov        ax, 413ch
d33b4:  8e c0                                      mov        es, ax
d33b6:  26 c6 06 fe 00 01                          mov        byte es:[00feh], 01h
d33bc:  b8 3c 41                                   mov        ax, 413ch
d33bf:  8e c0                                      mov        es, ax
d33c1:  26 c6 06 ff 00 01                          mov        byte es:[00ffh], 01h
d33c7:  b8 3c 41                                   mov        ax, 413ch
d33ca:  8e c0                                      mov        es, ax
d33cc:  26 c6 06 fd 00 01                          mov        byte es:[00fdh], 01h
d33d2:  b8 3c 41                                   mov        ax, 413ch
d33d5:  8e c0                                      mov        es, ax
d33d7:  26 c7 06 f2 00 00 00                       mov        word es:[00f2h], 0000h
d33de:  26 c7 06 f0 00 00 00                       mov        word es:[00f0h], 0000h
d33e5:  c7 06 2f 00 00 00                          mov        word [002fh], 0000h
d33eb:  c7 06 2d 00 00 00                          mov        word [002dh], 0000h
d33f1:  b8 3c 41                                   mov        ax, 413ch
d33f4:  8e c0                                      mov        es, ax
d33f6:  26 c6 06 ee 00 00                          mov        byte es:[00eeh], 00h
d33fc:  b8 3c 41                                   mov        ax, 413ch
d33ff:  8e c0                                      mov        es, ax
d3401:  26 c6 06 ed 00 00                          mov        byte es:[00edh], 00h
d3407:  b8 3c 41                                   mov        ax, 413ch
d340a:  8e c0                                      mov        es, ax
d340c:  26 c6 06 eb 00 00                          mov        byte es:[00ebh], 00h
d3412:  b8 3c 41                                   mov        ax, 413ch
d3415:  8e c0                                      mov        es, ax
d3417:  26 c7 06 f6 00 00 00                       mov        word es:[00f6h], 0000h
d341e:  b8 3c 41                                   mov        ax, 413ch
d3421:  8e c0                                      mov        es, ax
d3423:  26 c6 06 ec 00 00                          mov        byte es:[00ech], 00h
d3429:  c6 06 3f 00 00                             mov        byte [003fh], 00h
d342e:  c6 06 3e 00 00                             mov        byte [003eh], 00h
d3433:  b8 3c 41                                   mov        ax, 413ch
d3436:  8e c0                                      mov        es, ax
d3438:  26 c6 06 fa 00 00                          mov        byte es:[00fah], 00h
d343e:  68 8c 00                                   push       008ch
d3441:  9a 38 01 00 d0                             call       cmd_queue_push
d3446:  59                                         pop        cx
d3447:  c7 06 0e 00 00 00                          mov        word [000eh], 0000h
d344d:  eb 78                                      jmp short  loc_d34c7

;  XREF: d34cc
d344f:  8b 1e 0e 00           loc_d344f:           mov        bx, [000eh]
d3453:  6b db 09                                   imul       bx, bx, 09h
d3456:  b8 3c 41                                   mov        ax, 413ch
d3459:  8e c0                                      mov        es, ax
d345b:  26 c7 87 34 00 00 00                       mov        word es:[bx+0034h], 0000h
d3462:  26 c7 87 32 00 00 00                       mov        word es:[bx+0032h], 0000h
d3469:  8b 1e 0e 00                                mov        bx, [000eh]
d346d:  6b db 09                                   imul       bx, bx, 09h
d3470:  b8 3c 41                                   mov        ax, 413ch
d3473:  8e c0                                      mov        es, ax
d3475:  26 c6 87 36 00 00                          mov        byte es:[bx+0036h], 00h
d347b:  8b 1e 0e 00                                mov        bx, [000eh]
d347f:  6b db 09                                   imul       bx, bx, 09h
d3482:  b8 3c 41                                   mov        ax, 413ch
d3485:  8e c0                                      mov        es, ax
d3487:  26 c6 87 39 00 00                          mov        byte es:[bx+0039h], 00h
d348d:  8b 1e 0e 00                                mov        bx, [000eh]
d3491:  6b db 09                                   imul       bx, bx, 09h
d3494:  b8 3c 41                                   mov        ax, 413ch
d3497:  8e c0                                      mov        es, ax
d3499:  26 c6 87 3a 00 00                          mov        byte es:[bx+003ah], 00h
d349f:  8b 1e 0e 00                                mov        bx, [000eh]
d34a3:  6b db 09                                   imul       bx, bx, 09h
d34a6:  b8 3c 41                                   mov        ax, 413ch
d34a9:  8e c0                                      mov        es, ax
d34ab:  26 c6 87 37 00 00                          mov        byte es:[bx+0037h], 00h
d34b1:  8b 1e 0e 00                                mov        bx, [000eh]
d34b5:  6b db 09                                   imul       bx, bx, 09h
d34b8:  b8 3c 41                                   mov        ax, 413ch
d34bb:  8e c0                                      mov        es, ax
d34bd:  26 c6 87 38 00 00                          mov        byte es:[bx+0038h], 00h
d34c3:  ff 06 0e 00                                inc        word [000eh]

;  XREF: d344d
d34c7:  83 3e 0e 00 04        loc_d34c7:           cmp        word [000eh], 04h
d34cc:  7c 81                                      jl         loc_d344f
d34ce:  9a c4 00 00 f0                             call       dmd_buffer_swap
d34d3:  9a f1 00 00 f0                             call       dmd_buffer_clear
d34d8:  68 8a 01                                   push       018ah
d34db:  9a 3f 0d 00 f0                             call       dmd_scroll_engine
d34e0:  59                                         pop        cx
d34e1:  68 81 01                                   push       0181h
d34e4:  9a 8e 10 00 f0                             call       cpu_peripheral_init
d34e9:  59                                         pop        cx
d34ea:  9a 47 4a 2a d7                             call       game_state_save
d34ef:  b8 01 00                                   mov        ax, 0001h
d34f2:  1f                                         pop        ds
d34f3:  cb                                         retf

;  XREF: d376c, d3975

; -----------------------------------------------------------------------------
; ball_serve (0xD34F4)
; Serve ball to plunger lane (fire ball trough eject solenoid). 2 refs
; -----------------------------------------------------------------------------
d34f4:  55                    ball_serve:           push       bp
d34f5:  8b ec                                      mov        bp, sp
d34f7:  1e                                         push       ds
d34f8:  b8 30 41                                   mov        ax, 4130h
d34fb:  8e d8                                      mov        ds, ax
d34fd:  80 3e 3e 00 00                             cmp        byte [003eh], 00h
d3502:  74 03                                      jz         loc_d3507
d3504:  e9 9d 00                                   jmp        loc_d35a4

;  XREF: d3502
d3507:  8b 46 08              loc_d3507:           mov        ax, [bp+08h]
d350a:  8b 56 06                                   mov        dx, [bp+06h]
d350d:  3b 06 3b 00                                cmp        ax, [003bh]
d3511:  7d 03                                      jge        loc_d3516
d3513:  e9 8e 00                                   jmp        loc_d35a4

;  XREF: d3511
d3516:  75 09                 loc_d3516:           jnz        loc_d3521
d3518:  3b 16 39 00                                cmp        dx, [0039h]
d351c:  73 03                                      jnb        loc_d3521
d351e:  e9 83 00                                   jmp        loc_d35a4

;  XREF: d3516, d351c
d3521:  b8 3c 41              loc_d3521:           mov        ax, 413ch
d3524:  8e c0                                      mov        es, ax
d3526:  26 fe 06 ee 00                             inc        byte es:[00eeh]
d352b:  68 9b 00                                   push       009bh
d352e:  9a 70 0b 00 d0                             call       timer_delay
d3533:  59                                         pop        cx
d3534:  68 e7 00                                   push       00e7h
d3537:  9a 38 01 00 d0                             call       cmd_queue_push
d353c:  59                                         pop        cx
d353d:  68 40 50                                   push       5040h
d3540:  68 6c 01                                   push       016ch
d3543:  9a 92 04 00 d0                             call       display_set_animation_29refs
d3548:  83 c4 04                                   add        word sp, 04h
d354b:  05 01 00                                   add        ax, 0001h
d354e:  83 d2 00                                   adc        word dx, 00h
d3551:  52                                         push       dx
d3552:  50                                         push       ax
d3553:  68 40 50                                   push       5040h
d3556:  68 6c 01                                   push       016ch
d3559:  9a 6d 04 00 d0                             call       display_write_param_25refs
d355e:  83 c4 08                                   add        word sp, 08h
d3561:  c6 06 3e 00 01                             mov        byte [003eh], 01h
d3566:  68 a0 00                                   push       00a0h
d3569:  68 00 f0                                   push       f000h
d356c:  68 38 1c                                   push       1c38h
d356f:  68 00 f0                                   push       f000h
d3572:  68 f0 1b                                   push       1bf0h
d3575:  9a 0f 38 2a d7                             call       ball_launch_display
d357a:  83 c4 0a                                   add        word sp, 0ah
d357d:  68 40 50                                   push       5040h
d3580:  68 70 01                                   push       0170h
d3583:  9a 92 04 00 d0                             call       display_set_animation_29refs
d3588:  83 c4 04                                   add        word sp, 04h
d358b:  05 01 00                                   add        ax, 0001h
d358e:  83 d2 00                                   adc        word dx, 00h
d3591:  52                                         push       dx
d3592:  50                                         push       ax
d3593:  68 40 50                                   push       5040h
d3596:  68 70 01                                   push       0170h

;  XREF: d3686
d3599:  9a 6d 04 00 d0        loc_d3599:           call       display_write_param_25refs
d359e:  83 c4 08                                   add        word sp, 08h
d35a1:  e9 e5 00                                   jmp        loc_d3689

;  XREF: d3504, d3513, d351e
d35a4:  80 3e 3f 00 00        loc_d35a4:           cmp        byte [003fh], 00h
d35a9:  75 50                                      jnz        loc_d35fb
d35ab:  8b 46 08                                   mov        ax, [bp+08h]
d35ae:  8b 56 06                                   mov        dx, [bp+06h]
d35b1:  3b 06 37 00                                cmp        ax, [0037h]
d35b5:  7c 44                                      jl         loc_d35fb
d35b7:  75 06                                      jnz        loc_d35bf
d35b9:  3b 16 35 00                                cmp        dx, [0035h]
d35bd:  72 3c                                      jb         loc_d35fb

;  XREF: d35b7
d35bf:  c7 06 18 00 00 00     loc_d35bf:           mov        word [0018h], 0000h
d35c5:  c7 06 16 00 01 00                          mov        word [0016h], 0001h
d35cb:  68 9b 00                                   push       009bh
d35ce:  9a 70 0b 00 d0                             call       timer_delay
d35d3:  59                                         pop        cx
d35d4:  68 e7 00                                   push       00e7h
d35d7:  9a 38 01 00 d0                             call       cmd_queue_push
d35dc:  59                                         pop        cx
d35dd:  68 a0 00                                   push       00a0h
d35e0:  68 00 f0                                   push       f000h
d35e3:  68 a8 1b                                   push       1ba8h
d35e6:  68 00 f0                                   push       f000h
d35e9:  68 60 1b                                   push       1b60h
d35ec:  9a 0f 38 2a d7                             call       ball_launch_display
d35f1:  83 c4 0a                                   add        word sp, 0ah
d35f4:  c6 06 3f 00 02                             mov        byte [003fh], 02h
d35f9:  eb 58                                      jmp short  loc_d3653

;  XREF: d35a9, d35b5, d35bd
d35fb:  80 3e 3f 00 02        loc_d35fb:           cmp        byte [003fh], 02h
d3600:  74 03                                      jz         loc_d3605
d3602:  e9 84 00                                   jmp        loc_d3689

;  XREF: d3600
d3605:  8b 46 08              loc_d3605:           mov        ax, [bp+08h]
d3608:  8b 56 06                                   mov        dx, [bp+06h]
d360b:  3b 06 33 00                                cmp        ax, [0033h]
d360f:  7c 78                                      jl         loc_d3689
d3611:  75 06                                      jnz        loc_d3619
d3613:  3b 16 31 00                                cmp        dx, [0031h]
d3617:  72 70                                      jb         loc_d3689

;  XREF: d3611
d3619:  c7 06 14 00 00 00     loc_d3619:           mov        word [0014h], 0000h
d361f:  c7 06 12 00 01 00                          mov        word [0012h], 0001h
d3625:  68 9b 00                                   push       009bh
d3628:  9a 70 0b 00 d0                             call       timer_delay
d362d:  59                                         pop        cx
d362e:  68 e7 00                                   push       00e7h
d3631:  9a 38 01 00 d0                             call       cmd_queue_push
d3636:  59                                         pop        cx
d3637:  68 a0 00                                   push       00a0h
d363a:  68 00 f0                                   push       f000h
d363d:  68 a8 1b                                   push       1ba8h
d3640:  68 00 f0                                   push       f000h
d3643:  68 60 1b                                   push       1b60h
d3646:  9a 0f 38 2a d7                             call       ball_launch_display
d364b:  83 c4 0a                                   add        word sp, 0ah
d364e:  c6 06 3f 00 03                             mov        byte [003fh], 03h

;  XREF: d35f9
d3653:  b8 3c 41              loc_d3653:           mov        ax, 413ch
d3656:  8e c0                                      mov        es, ax
d3658:  26 fe 06 d4 00                             inc        byte es:[00d4h] ; credit_available - Non-zero when credits are available for game start
d365d:  8e c0                                      mov        es, ax
d365f:  26 a0 d4 00                                mov        al, es:[00d4h] ; credit_available - Non-zero when credits are available for game start
d3663:  50                                         push       ax
d3664:  9a d2 04 00 d0                             call       display_write_word_12refs
d3669:  59                                         pop        cx
d366a:  68 40 50                                   push       5040h
d366d:  68 1c 01                                   push       011ch
d3670:  9a 92 04 00 d0                             call       display_set_animation_29refs
d3675:  83 c4 04                                   add        word sp, 04h
d3678:  05 01 00                                   add        ax, 0001h
d367b:  83 d2 00                                   adc        word dx, 00h
d367e:  52                                         push       dx
d367f:  50                                         push       ax
d3680:  68 40 50                                   push       5040h
d3683:  68 1c 01                                   push       011ch
d3686:  e9 10 ff                                   jmp        loc_d3599

;  XREF: d35a1, d3602, d360f, d3617
d3689:  1f                    loc_d3689:           pop        ds
d368a:  5d                                         pop        bp
d368b:  cb                                         retf

;  XREF: d31d3

; -----------------------------------------------------------------------------
; ball_drain_handler (0xD368C)
; Handle ball drain event: check for multiball, end-of-ball logic
; -----------------------------------------------------------------------------
d368c:  1e                    ball_drain_handler:           push       ds
d368d:  b8 30 41                                   mov        ax, 4130h
d3690:  8e d8                                      mov        ds, ax
d3692:  68 40 50                                   push       5040h
d3695:  68 43 00                                   push       0043h
d3698:  9a 92 04 00 d0                             call       display_set_animation_29refs
d369d:  83 c4 04                                   add        word sp, 04h
d36a0:  bb 3c 41                                   mov        bx, 413ch
d36a3:  8e c3                                      mov        es, bx
d36a5:  26 8b 1e f2 00                             mov        bx, es:[00f2h]
d36aa:  26 8b 0e f0 00                             mov        cx, es:[00f0h]
d36af:  2b 0e 2d 00                                sub        cx, [002dh]
d36b3:  1b 1e 2f 00                                sbb        bx, [002fh]
d36b7:  3b d3                                      cmp        dx, bx
d36b9:  7c 32                                      jl         loc_d36ed
d36bb:  75 04                                      jnz        loc_d36c1
d36bd:  3b c1                                      cmp        ax, cx
d36bf:  72 2c                                      jb         loc_d36ed

;  XREF: d36bb
d36c1:  b8 3c 41              loc_d36c1:           mov        ax, 413ch
d36c4:  8e c0                                      mov        es, ax
d36c6:  26 80 3e ee 00 00                          cmp        byte es:[00eeh], 00h
d36cc:  75 1f                                      jnz        loc_d36ed
d36ce:  b8 3c 41                                   mov        ax, 413ch
d36d1:  8e c0                                      mov        es, ax
d36d3:  26 80 3e ed 00 00                          cmp        byte es:[00edh], 00h
d36d9:  75 12                                      jnz        loc_d36ed
d36db:  b8 3c 41                                   mov        ax, 413ch
d36de:  8e c0                                      mov        es, ax
d36e0:  26 80 3e db 00 00                          cmp        byte es:[00dbh], 00h
d36e6:  75 05                                      jnz        loc_d36ed
d36e8:  b8 01 00                                   mov        ax, 0001h
d36eb:  eb 02                                      jmp short  loc_d36ef

;  XREF: d36b9, d36bf, d36cc, d36d9, d36e6
d36ed:  33 c0                 loc_d36ed:           xor        ax, ax

;  XREF: d36eb
d36ef:  1f                    loc_d36ef:           pop        ds
d36f0:  cb                                         retf

;  XREF: d31a7

; -----------------------------------------------------------------------------
; end_of_ball (0xD36F1)
; End of ball processing: update bonus, check extra ball, advance player
; -----------------------------------------------------------------------------
d36f1:  1e                    end_of_ball:           push       ds
d36f2:  b8 30 41                                   mov        ax, 4130h
d36f5:  8e d8                                      mov        ds, ax
d36f7:  b8 3c 41                                   mov        ax, 413ch
d36fa:  8e c0                                      mov        es, ax
d36fc:  26 80 3e f4 00 02                          cmp        byte es:[00f4h], 02h
d3702:  75 4b                                      jnz        loc_d374f
d3704:  b8 00 40                                   mov        ax, 4000h
d3707:  8e c0                                      mov        es, ax
d3709:  26 83 3e 3b 11 00                          cmp        word es:[113bh], 00h ; z80_cmd_pending - Z80 command pending flag (80188 writes, Z80 clears when done)
d370f:  75 3e                                      jnz        loc_d374f
d3711:  9a 7b 54 2a d7                             call       dmd_tilt_display
d3716:  b8 3c 41                                   mov        ax, 413ch
d3719:  8e c0                                      mov        es, ax
d371b:  26 c6 06 f4 00 00                          mov        byte es:[00f4h], 00h
d3721:  68 f1 00                                   push       00f1h
d3724:  9a 38 01 00 d0                             call       cmd_queue_push
d3729:  59                                         pop        cx
d372a:  6a 44                                      push       44h
d372c:  9a 0a 00 2a d7                             call       dmd_anim_play
d3731:  59                                         pop        cx
d3732:  b8 3c 41                                   mov        ax, 413ch
d3735:  8e c0                                      mov        es, ax
d3737:  26 c6 06 d8 00 01                          mov        byte es:[00d8h], 01h
d373d:  9a 93 3a 2a d7                             call       game_timer_utility
d3742:  6a 14                                      push       14h
d3744:  9a e8 26 f2 d2                             call       switch_read_shared_ram
d3749:  59                                         pop        cx
d374a:  9a 06 50 2a d7                             call       dmd_planet_display

;  XREF: d3702, d370f
d374f:  1f                    loc_d374f:           pop        ds
d3750:  cb                                         retf

;  XREF: d31b5

; -----------------------------------------------------------------------------
; bonus_countdown (0xD3751)
; Bonus countdown display animation
; -----------------------------------------------------------------------------
d3751:  1e                    bonus_countdown:           push       ds
d3752:  b8 30 41                                   mov        ax, 4130h
d3755:  8e d8                                      mov        ds, ax
d3757:  c6 06 11 00 01                             mov        byte [0011h], 01h
d375c:  b8 3c 41                                   mov        ax, 413ch
d375f:  8e c0                                      mov        es, ax
d3761:  26 ff 36 f2 00                             push       word es:[00f2h]
d3766:  26 ff 36 f0 00                             push       word es:[00f0h]
d376b:  0e                                         push       cs
d376c:  e8 85 fd                                   call       ball_serve
d376f:  83 c4 04                                   add        word sp, 04h
d3772:  b8 3c 41                                   mov        ax, 413ch
d3775:  8e c0                                      mov        es, ax
d3777:  26 ff 36 f2 00                             push       word es:[00f2h]
d377c:  26 ff 36 f0 00                             push       word es:[00f0h]
d3781:  68 3c 41                                   push       413ch
d3784:  68 e1 00                                   push       00e1h
d3787:  9a 20 57 2a d7                             call       score_compare_and_cap
d378c:  83 c4 08                                   add        word sp, 08h
d378f:  6a 00                                      push       00h
d3791:  68 3c 41                                   push       413ch
d3794:  68 e1 00                                   push       00e1h
d3797:  9a 07 09 00 f0                             call       dmd_frame_load
d379c:  83 c4 06                                   add        word sp, 06h
d379f:  1f                                         pop        ds
d37a0:  cb                                         retf

;  XREF: d31bc

; -----------------------------------------------------------------------------
; extra_ball_check (0xD37A1)
; Check and award extra ball if earned
; -----------------------------------------------------------------------------
d37a1:  1e                    extra_ball_check:           push       ds
d37a2:  b8 30 41                                   mov        ax, 4130h
d37a5:  8e d8                                      mov        ds, ax
d37a7:  b8 00 40                                   mov        ax, 4000h
d37aa:  8e c0                                      mov        es, ax
d37ac:  26 83 3e 3d 11 00                          cmp        word es:[113dh], 00h
d37b2:  75 58                                      jnz        loc_d380c
d37b4:  8e c0                                      mov        es, ax
d37b6:  26 c7 06 3d 11 b0 04                       mov        word es:[113dh], 04b0h
d37bd:  80 3e 11 00 00                             cmp        byte [0011h], 00h
d37c2:  75 16                                      jnz        loc_d37da
d37c4:  b8 3c 41                                   mov        ax, 413ch
d37c7:  8e c0                                      mov        es, ax
d37c9:  26 80 3e eb 00 00                          cmp        byte es:[00ebh], 00h
d37cf:  75 09                                      jnz        loc_d37da
d37d1:  68 ec 00                                   push       00ech
d37d4:  9a 38 01 00 d0                             call       cmd_queue_push
d37d9:  59                                         pop        cx

;  XREF: d37c2, d37cf
d37da:  c6 06 11 00 00        loc_d37da:           mov        byte [0011h], 00h
d37df:  b8 3c 41                                   mov        ax, 413ch
d37e2:  8e c0                                      mov        es, ax
d37e4:  26 ff 36 f2 00                             push       word es:[00f2h]
d37e9:  26 ff 36 f0 00                             push       word es:[00f0h]
d37ee:  68 3c 41                                   push       413ch
d37f1:  68 e1 00                                   push       00e1h
d37f4:  9a 20 57 2a d7                             call       score_compare_and_cap
d37f9:  83 c4 08                                   add        word sp, 08h
d37fc:  6a 00                                      push       00h
d37fe:  68 3c 41                                   push       413ch
d3801:  68 e1 00                                   push       00e1h
d3804:  9a 07 09 00 f0                             call       dmd_frame_load
d3809:  83 c4 06                                   add        word sp, 06h

;  XREF: d37b2
d380c:  1f                    loc_d380c:           pop        ds
d380d:  cb                                         retf

;  XREF: d31ce

; -----------------------------------------------------------------------------
; player_advance (0xD380E)
; Advance to next player or end game if last ball
; -----------------------------------------------------------------------------
d380e:  1e                    player_advance:           push       ds
d380f:  b8 30 41                                   mov        ax, 4130h
d3812:  8e d8                                      mov        ds, ax
d3814:  68 c8 00                                   push       00c8h
d3817:  9a 38 01 00 d0                             call       cmd_queue_push
d381c:  59                                         pop        cx
d381d:  6a 00                                      push       00h
d381f:  9a b4 0d 00 d0                             call       game_mode_set
d3824:  59                                         pop        cx

;  XREF: d3830
d3825:  b8 00 40              loc_d3825:           mov        ax, 4000h
d3828:  8e c0                                      mov        es, ax
d382a:  26 80 3e ee 12 00                          cmp        byte es:[12eeh], 00h
d3830:  75 f3                                      jnz        loc_d3825
d3832:  6a 04                                      push       04h
d3834:  9a b4 0d 00 d0                             call       game_mode_set
d3839:  59                                         pop        cx
d383a:  9a 3d 12 00 f0                             call       interrupt_handler_serial
d383f:  b8 3c 41                                   mov        ax, 413ch
d3842:  8e c0                                      mov        es, ax
d3844:  26 c6 06 dc 00 00                          mov        byte es:[00dch], 00h
d384a:  9a e5 10 00 f0                             call       interrupt_vector_setup
d384f:  9a c0 0d 00 f0                             call       dmd_credits_scroll
d3854:  1f                                         pop        ds
d3855:  cb                                         retf

;  XREF: d31f0

; -----------------------------------------------------------------------------
; tilt_handler (0xD3856)
; Handle tilt event: disable flippers, void ball scoring
; -----------------------------------------------------------------------------
d3856:  1e                    tilt_handler:           push       ds
d3857:  b8 30 41                                   mov        ax, 4130h
d385a:  8e d8                                      mov        ds, ax
d385c:  b8 3c 41                                   mov        ax, 413ch
d385f:  8e c0                                      mov        es, ax
d3861:  26 c6 06 db 00 00                          mov        byte es:[00dbh], 00h
d3867:  b8 3c 41                                   mov        ax, 413ch
d386a:  8e c0                                      mov        es, ax
d386c:  26 c6 06 fd 00 01                          mov        byte es:[00fdh], 01h
d3872:  b8 3c 41                                   mov        ax, 413ch
d3875:  8b 16 2f 00                                mov        dx, [002fh]
d3879:  8b 1e 2d 00                                mov        bx, [002dh]
d387d:  8e c0                                      mov        es, ax
d387f:  26 89 16 f2 00                             mov        es:[00f2h], dx
d3884:  26 89 1e f0 00                             mov        es:[00f0h], bx
d3889:  b8 3c 41                                   mov        ax, 413ch
d388c:  8e c0                                      mov        es, ax
d388e:  26 c6 06 ee 00 00                          mov        byte es:[00eeh], 00h
d3894:  b8 3c 41                                   mov        ax, 413ch
d3897:  8e c0                                      mov        es, ax
d3899:  26 c7 06 f6 00 00 00                       mov        word es:[00f6h], 0000h
d38a0:  b8 3c 41                                   mov        ax, 413ch
d38a3:  8e c0                                      mov        es, ax
d38a5:  26 c6 06 fc 00 00                          mov        byte es:[00fch], 00h
d38ab:  b8 3c 41                                   mov        ax, 413ch
d38ae:  8e c0                                      mov        es, ax
d38b0:  26 c6 06 fb 00 00                          mov        byte es:[00fbh], 00h
d38b6:  b8 3c 41                                   mov        ax, 413ch
d38b9:  8e c0                                      mov        es, ax
d38bb:  26 c6 06 02 01 00                          mov        byte es:[0102h], 00h
d38c1:  1f                                         pop        ds
d38c2:  cb                                         retf

;  XREF: d31fe

; -----------------------------------------------------------------------------
; multiball_handler (0xD38C3)
; Multiball mode handler: manage locked balls, multiball scoring
; -----------------------------------------------------------------------------
d38c3:  1e                    multiball_handler:           push       ds
d38c4:  b8 30 41                                   mov        ax, 4130h
d38c7:  8e d8                                      mov        ds, ax
d38c9:  9a 47 4a 2a d7                             call       game_state_save
d38ce:  b8 3c 41                                   mov        ax, 413ch
d38d1:  8e c0                                      mov        es, ax
d38d3:  26 c7 06 f6 00 00 00                       mov        word es:[00f6h], 0000h
d38da:  b8 3c 41                                   mov        ax, 413ch
d38dd:  8e c0                                      mov        es, ax
d38df:  26 c6 06 fd 00 01                          mov        byte es:[00fdh], 01h
d38e5:  9a c0 0d 00 f0                             call       dmd_credits_scroll
d38ea:  68 8a 01                                   push       018ah
d38ed:  9a 3f 0d 00 f0                             call       dmd_scroll_engine
d38f2:  59                                         pop        cx
d38f3:  68 81 01                                   push       0181h
d38f6:  9a 8e 10 00 f0                             call       cpu_peripheral_init
d38fb:  59                                         pop        cx
d38fc:  9a ae 4a 2a d7                             call       game_state_restore
d3901:  6a 00                                      push       00h
d3903:  9a b4 0d 00 d0                             call       game_mode_set
d3908:  59                                         pop        cx

;  XREF: d3914
d3909:  b8 00 40              loc_d3909:           mov        ax, 4000h
d390c:  8e c0                                      mov        es, ax
d390e:  26 80 3e ee 12 00                          cmp        byte es:[12eeh], 00h
d3914:  75 f3                                      jnz        loc_d3909
d3916:  6a 01                                      push       01h
d3918:  9a b4 0d 00 d0                             call       game_mode_set
d391d:  59                                         pop        cx
d391e:  1f                                         pop        ds
d391f:  cb                                         retf

;  XREF: d31f5

; -----------------------------------------------------------------------------
; jackpot_handler (0xD3920)
; Jackpot/Super Jackpot scoring handler
; -----------------------------------------------------------------------------
d3920:  1e                    jackpot_handler:           push       ds
d3921:  b8 30 41                                   mov        ax, 4130h
d3924:  8e d8                                      mov        ds, ax
d3926:  9a bb 0d f2 d2                             call       game_feature_handler
d392b:  b8 3c 41                                   mov        ax, 413ch
d392e:  8e c0                                      mov        es, ax
d3930:  26 a0 fe 00                                mov        al, es:[00feh]
d3934:  b4 00                                      mov        ah, 00h
d3936:  6b c0 09                                   imul       ax, ax, 09h
d3939:  ba 3c 41                                   mov        dx, 413ch
d393c:  bb 3c 41                                   mov        bx, 413ch
d393f:  8e c3                                      mov        es, bx
d3941:  26 8b 1e f2 00                             mov        bx, es:[00f2h]
d3946:  26 8b 0e f0 00                             mov        cx, es:[00f0h]
d394b:  8e c2                                      mov        es, dx
d394d:  93                                         xchg       ax, bx
d394e:  26 89 87 2b 00                             mov        es:[bx+002bh], ax
d3953:  26 89 8f 29 00                             mov        es:[bx+0029h], cx
d3958:  b8 3c 41                                   mov        ax, 413ch
d395b:  8e c0                                      mov        es, ax
d395d:  26 a0 fe 00                                mov        al, es:[00feh]
d3961:  b4 00                                      mov        ah, 00h
d3963:  6b c0 09                                   imul       ax, ax, 09h
d3966:  8b d8                                      mov        bx, ax
d3968:  8e c2                                      mov        es, dx
d396a:  26 ff b7 2b 00                             push       word es:[bx+002bh]
d396f:  26 ff b7 29 00                             push       word es:[bx+0029h]
d3974:  0e                                         push       cs
d3975:  e8 7c fb                                   call       ball_serve
d3978:  83 c4 04                                   add        word sp, 04h
d397b:  b8 3c 41                                   mov        ax, 413ch
d397e:  8e c0                                      mov        es, ax
d3980:  26 a0 fe 00                                mov        al, es:[00feh]
d3984:  b4 00                                      mov        ah, 00h
d3986:  6b c0 09                                   imul       ax, ax, 09h
d3989:  ba 3c 41                                   mov        dx, 413ch
d398c:  bb 3c 41                                   mov        bx, 413ch
d398f:  8e c3                                      mov        es, bx
d3991:  26 8a 1e ff 00                             mov        bl, es:[00ffh]
d3996:  8e c2                                      mov        es, dx
d3998:  93                                         xchg       ax, bx
d3999:  26 88 87 2d 00                             mov        es:[bx+002dh], al
d399e:  b8 3c 41                                   mov        ax, 413ch
d39a1:  8e c0                                      mov        es, ax
d39a3:  26 a0 fe 00                                mov        al, es:[00feh]
d39a7:  b4 00                                      mov        ah, 00h
d39a9:  6b c0 09                                   imul       ax, ax, 09h
d39ac:  8a 1e 3f 00                                mov        bl, [003fh]
d39b0:  8e c2                                      mov        es, dx
d39b2:  93                                         xchg       ax, bx
d39b3:  26 88 87 2e 00                             mov        es:[bx+002eh], al
d39b8:  b8 3c 41                                   mov        ax, 413ch
d39bb:  8e c0                                      mov        es, ax
d39bd:  26 a0 fe 00                                mov        al, es:[00feh]
d39c1:  b4 00                                      mov        ah, 00h
d39c3:  6b c0 09                                   imul       ax, ax, 09h
d39c6:  8a 1e 3e 00                                mov        bl, [003eh]
d39ca:  8e c2                                      mov        es, dx
d39cc:  93                                         xchg       ax, bx
d39cd:  26 88 87 2f 00                             mov        es:[bx+002fh], al
d39d2:  b8 3c 41                                   mov        ax, 413ch
d39d5:  8e c0                                      mov        es, ax
d39d7:  26 a0 fe 00                                mov        al, es:[00feh]
d39db:  b4 00                                      mov        ah, 00h
d39dd:  6b c0 09                                   imul       ax, ax, 09h
d39e0:  bb 29 00                                   mov        bx, 0029h
d39e3:  83 c3 07                                   add        word bx, 07h
d39e6:  03 c3                                      add        ax, bx
d39e8:  8b d8                                      mov        bx, ax
d39ea:  8e c2                                      mov        es, dx
d39ec:  26 80 3f 00                                cmp        byte es:[bx], 00h
d39f0:  75 20                                      jnz        loc_d3a12
d39f2:  b8 3c 41                                   mov        ax, 413ch
d39f5:  8e c0                                      mov        es, ax
d39f7:  26 a0 fe 00                                mov        al, es:[00feh]
d39fb:  b4 00                                      mov        ah, 00h
d39fd:  6b c0 09                                   imul       ax, ax, 09h
d3a00:  bb 3c 41                                   mov        bx, 413ch
d3a03:  8e c3                                      mov        es, bx
d3a05:  26 8a 1e fa 00                             mov        bl, es:[00fah]
d3a0a:  8e c2                                      mov        es, dx
d3a0c:  93                                         xchg       ax, bx
d3a0d:  26 88 87 30 00                             mov        es:[bx+0030h], al

;  XREF: d39f0
d3a12:  b8 3c 41              loc_d3a12:           mov        ax, 413ch
d3a15:  8e c0                                      mov        es, ax
d3a17:  26 80 3e fa 00 00                          cmp        byte es:[00fah], 00h
d3a1d:  75 25                                      jnz        loc_d3a44
d3a1f:  b8 3c 41                                   mov        ax, 413ch
d3a22:  8e c0                                      mov        es, ax
d3a24:  26 a0 fe 00                                mov        al, es:[00feh]
d3a28:  b4 00                                      mov        ah, 00h
d3a2a:  6b c0 09                                   imul       ax, ax, 09h
d3a2d:  ba 3c 41                                   mov        dx, 413ch
d3a30:  bb 3c 41                                   mov        bx, 413ch
d3a33:  8e c3                                      mov        es, bx
d3a35:  26 8a 1e 02 01                             mov        bl, es:[0102h]
d3a3a:  8e c2                                      mov        es, dx
d3a3c:  93                                         xchg       ax, bx
d3a3d:  26 88 87 31 00                             mov        es:[bx+0031h], al
d3a42:  eb 1b                                      jmp short  loc_d3a5f

;  XREF: d3a1d
d3a44:  b8 3c 41              loc_d3a44:           mov        ax, 413ch
d3a47:  8e c0                                      mov        es, ax
d3a49:  26 a0 fe 00                                mov        al, es:[00feh]
d3a4d:  b4 00                                      mov        ah, 00h
d3a4f:  6b c0 09                                   imul       ax, ax, 09h
d3a52:  ba 3c 41                                   mov        dx, 413ch
d3a55:  8b d8                                      mov        bx, ax
d3a57:  8e c2                                      mov        es, dx
d3a59:  26 c6 87 31 00 00                          mov        byte es:[bx+0031h], 00h

;  XREF: d3a42
d3a5f:  b8 3c 41              loc_d3a5f:           mov        ax, 413ch
d3a62:  8e c0                                      mov        es, ax
d3a64:  26 a0 fe 00                                mov        al, es:[00feh]
d3a68:  b4 00                                      mov        ah, 00h
d3a6a:  6b c0 09                                   imul       ax, ax, 09h
d3a6d:  ba 3c 41                                   mov        dx, 413ch
d3a70:  bb 29 00                                   mov        bx, 0029h
d3a73:  83 c3 04                                   add        word bx, 04h
d3a76:  03 c3                                      add        ax, bx
d3a78:  8b d8                                      mov        bx, ax
d3a7a:  8e c2                                      mov        es, dx
d3a7c:  26 8a 07                                   mov        al, es:[bx]
d3a7f:  3a 06 3d 00                                cmp        al, [003dh]
d3a83:  75 12                                      jnz        loc_d3a97
d3a85:  b8 3c 41                                   mov        ax, 413ch
d3a88:  8e c0                                      mov        es, ax
d3a8a:  26 80 3e ee 00 00                          cmp        byte es:[00eeh], 00h
d3a90:  75 05                                      jnz        loc_d3a97
d3a92:  9a 06 17 f2 d2                             call       high_score_entry

;  XREF: d3a83, d3a90
d3a97:  b8 3c 41              loc_d3a97:           mov        ax, 413ch
d3a9a:  8e c0                                      mov        es, ax
d3a9c:  26 80 3e ee 00 00                          cmp        byte es:[00eeh], 00h
d3aa2:  75 03                                      jnz        loc_d3aa7
d3aa4:  e9 d0 00                                   jmp        loc_d3b77

;  XREF: d3aa2
d3aa7:  b8 3c 41              loc_d3aa7:           mov        ax, 413ch
d3aaa:  8e c0                                      mov        es, ax
d3aac:  26 c6 06 ec 00 01                          mov        byte es:[00ech], 01h
d3ab2:  b8 3c 41                                   mov        ax, 413ch
d3ab5:  8e c0                                      mov        es, ax
d3ab7:  26 fe 0e ee 00                             dec        byte es:[00eeh]

;  XREF: d3c0a
d3abc:  b8 3c 41              loc_d3abc:           mov        ax, 413ch
d3abf:  8e c0                                      mov        es, ax
d3ac1:  26 a0 fe 00                                mov        al, es:[00feh]
d3ac5:  b4 00                                      mov        ah, 00h
d3ac7:  6b c0 09                                   imul       ax, ax, 09h
d3aca:  ba 3c 41                                   mov        dx, 413ch
d3acd:  8b d8                                      mov        bx, ax
d3acf:  8e c2                                      mov        es, dx
d3ad1:  26 8b 87 2b 00                             mov        ax, es:[bx+002bh]
d3ad6:  26 8b 97 29 00                             mov        dx, es:[bx+0029h]
d3adb:  bb 3c 41                                   mov        bx, 413ch
d3ade:  8e c3                                      mov        es, bx
d3ae0:  26 a3 f2 00                                mov        es:[00f2h], ax
d3ae4:  26 89 16 f0 00                             mov        es:[00f0h], dx
d3ae9:  b8 3c 41                                   mov        ax, 413ch
d3aec:  8e c0                                      mov        es, ax
d3aee:  26 a0 fe 00                                mov        al, es:[00feh]
d3af2:  b4 00                                      mov        ah, 00h
d3af4:  6b c0 09                                   imul       ax, ax, 09h
d3af7:  ba 3c 41                                   mov        dx, 413ch
d3afa:  8b d8                                      mov        bx, ax
d3afc:  8e c2                                      mov        es, dx
d3afe:  26 8b 87 2b 00                             mov        ax, es:[bx+002bh]
d3b03:  26 8b 97 29 00                             mov        dx, es:[bx+0029h]
d3b08:  a3 2f 00                                   mov        [002fh], ax
d3b0b:  89 16 2d 00                                mov        [002dh], dx
d3b0f:  b8 3c 41                                   mov        ax, 413ch
d3b12:  8e c0                                      mov        es, ax
d3b14:  26 c6 06 ed 00 00                          mov        byte es:[00edh], 00h
d3b1a:  b8 3c 41                                   mov        ax, 413ch
d3b1d:  8e c0                                      mov        es, ax
d3b1f:  26 a0 fe 00                                mov        al, es:[00feh]
d3b23:  b4 00                                      mov        ah, 00h
d3b25:  6b c0 09                                   imul       ax, ax, 09h
d3b28:  ba 3c 41                                   mov        dx, 413ch
d3b2b:  8b d8                                      mov        bx, ax
d3b2d:  8e c2                                      mov        es, dx
d3b2f:  26 8a 87 2e 00                             mov        al, es:[bx+002eh]
d3b34:  a2 3f 00                                   mov        [003fh], al
d3b37:  b8 3c 41                                   mov        ax, 413ch
d3b3a:  8e c0                                      mov        es, ax
d3b3c:  26 a0 fe 00                                mov        al, es:[00feh]
d3b40:  b4 00                                      mov        ah, 00h
d3b42:  6b c0 09                                   imul       ax, ax, 09h
d3b45:  8b d8                                      mov        bx, ax
d3b47:  8e c2                                      mov        es, dx
d3b49:  26 8a 87 2f 00                             mov        al, es:[bx+002fh]
d3b4e:  a2 3e 00                                   mov        [003eh], al
d3b51:  b8 3c 41                                   mov        ax, 413ch
d3b54:  8e c0                                      mov        es, ax
d3b56:  26 a0 fe 00                                mov        al, es:[00feh]
d3b5a:  b4 00                                      mov        ah, 00h
d3b5c:  6b c0 09                                   imul       ax, ax, 09h
d3b5f:  8b d8                                      mov        bx, ax
d3b61:  8e c2                                      mov        es, dx
d3b63:  26 8a 87 31 00                             mov        al, es:[bx+0031h]

;  XREF: d3cd4
d3b68:  ba 3c 41              loc_d3b68:           mov        dx, 413ch
d3b6b:  8e c2                                      mov        es, dx
d3b6d:  26 a2 02 01                                mov        es:[0102h], al
d3b71:  b8 01 00                                   mov        ax, 0001h
d3b74:  e9 62 01                                   jmp        loc_d3cd9

;  XREF: d3aa4
d3b77:  c6 06 10 00 01        loc_d3b77:           mov        byte [0010h], 01h
d3b7c:  b8 3c 41                                   mov        ax, 413ch
d3b7f:  8e c0                                      mov        es, ax
d3b81:  26 80 3e d7 00 01                          cmp        byte es:[00d7h], 01h ; game_flag_1 - General game flag 1
d3b87:  77 03                                      ja         loc_d3b8c
d3b89:  e9 c2 00                                   jmp        loc_d3c4e

;  XREF: d3b87
d3b8c:  b8 3c 41              loc_d3b8c:           mov        ax, 413ch
d3b8f:  8e c0                                      mov        es, ax
d3b91:  26 a0 fe 00                                mov        al, es:[00feh]
d3b95:  b4 00                                      mov        ah, 00h
d3b97:  ba 3c 41                                   mov        dx, 413ch
d3b9a:  8e c2                                      mov        es, dx
d3b9c:  26 8a 16 d7 00                             mov        dl, es:[00d7h] ; game_flag_1 - General game flag 1
d3ba1:  b6 00                                      mov        dh, 00h
d3ba3:  52                                         push       dx
d3ba4:  99                                         cwd
d3ba5:  5b                                         pop        bx
d3ba6:  f7 fb                                      idiv       word bx
d3ba8:  fe c2                                      inc        byte dl
d3baa:  b8 3c 41                                   mov        ax, 413ch
d3bad:  8e c0                                      mov        es, ax
d3baf:  26 88 16 fe 00                             mov        es:[00feh], dl
d3bb4:  e9 82 00                                   jmp        loc_d3c39

;  XREF: d3c48
d3bb7:  b8 3c 41              loc_d3bb7:           mov        ax, 413ch
d3bba:  8e c0                                      mov        es, ax
d3bbc:  26 a0 fe 00                                mov        al, es:[00feh]
d3bc0:  b4 00                                      mov        ah, 00h
d3bc2:  6b c0 09                                   imul       ax, ax, 09h
d3bc5:  ba 3c 41                                   mov        dx, 413ch
d3bc8:  bb 29 00                                   mov        bx, 0029h
d3bcb:  83 c3 04                                   add        word bx, 04h
d3bce:  03 c3                                      add        ax, bx
d3bd0:  8b d8                                      mov        bx, ax
d3bd2:  8e c2                                      mov        es, dx
d3bd4:  26 8a 07                                   mov        al, es:[bx]
d3bd7:  3a 06 3d 00                                cmp        al, [003dh]
d3bdb:  73 30                                      jnb        loc_d3c0d
d3bdd:  b8 3c 41                                   mov        ax, 413ch
d3be0:  8e c0                                      mov        es, ax
d3be2:  26 c6 06 ec 00 00                          mov        byte es:[00ech], 00h
d3be8:  b8 3c 41                                   mov        ax, 413ch
d3beb:  8e c0                                      mov        es, ax
d3bed:  26 a0 fe 00                                mov        al, es:[00feh]
d3bf1:  b4 00                                      mov        ah, 00h
d3bf3:  6b c0 09                                   imul       ax, ax, 09h
d3bf6:  8b d8                                      mov        bx, ax
d3bf8:  8e c2                                      mov        es, dx
d3bfa:  26 8a 87 2d 00                             mov        al, es:[bx+002dh]
d3bff:  fe c0                                      inc        byte al
d3c01:  ba 3c 41                                   mov        dx, 413ch
d3c04:  8e c2                                      mov        es, dx
d3c06:  26 a2 ff 00                                mov        es:[00ffh], al
d3c0a:  e9 af fe                                   jmp        loc_d3abc

;  XREF: d3bdb
d3c0d:  b8 3c 41              loc_d3c0d:           mov        ax, 413ch
d3c10:  8e c0                                      mov        es, ax
d3c12:  26 a0 fe 00                                mov        al, es:[00feh]
d3c16:  b4 00                                      mov        ah, 00h
d3c18:  ba 3c 41                                   mov        dx, 413ch
d3c1b:  8e c2                                      mov        es, dx
d3c1d:  26 8a 16 d7 00                             mov        dl, es:[00d7h] ; game_flag_1 - General game flag 1
d3c22:  b6 00                                      mov        dh, 00h
d3c24:  52                                         push       dx
d3c25:  99                                         cwd
d3c26:  5b                                         pop        bx
d3c27:  f7 fb                                      idiv       word bx
d3c29:  fe c2                                      inc        byte dl
d3c2b:  b8 3c 41                                   mov        ax, 413ch
d3c2e:  8e c0                                      mov        es, ax
d3c30:  26 88 16 fe 00                             mov        es:[00feh], dl
d3c35:  fe 06 10 00                                inc        byte [0010h]

;  XREF: d3bb4
d3c39:  b8 3c 41              loc_d3c39:           mov        ax, 413ch
d3c3c:  8e c0                                      mov        es, ax
d3c3e:  26 a0 d7 00                                mov        al, es:[00d7h] ; game_flag_1 - General game flag 1
d3c42:  3a 06 10 00                                cmp        al, [0010h]
d3c46:  72 03                                      jb         loc_d3c4b
d3c48:  e9 6c ff                                   jmp        loc_d3bb7

;  XREF: d3c46
d3c4b:  e9 89 00              loc_d3c4b:           jmp        loc_d3cd7

;  XREF: d3b89
d3c4e:  b8 3c 41              loc_d3c4e:           mov        ax, 413ch
d3c51:  8e c0                                      mov        es, ax
d3c53:  26 a0 36 00                                mov        al, es:[0036h]
d3c57:  3a 06 3d 00                                cmp        al, [003dh]
d3c5b:  73 7a                                      jnb        loc_d3cd7
d3c5d:  b8 3c 41                                   mov        ax, 413ch
d3c60:  8e c0                                      mov        es, ax
d3c62:  26 c6 06 ec 00 00                          mov        byte es:[00ech], 00h
d3c68:  b8 3c 41                                   mov        ax, 413ch
d3c6b:  8e c0                                      mov        es, ax
d3c6d:  26 a0 36 00                                mov        al, es:[0036h]
d3c71:  fe c0                                      inc        byte al
d3c73:  ba 3c 41                                   mov        dx, 413ch
d3c76:  8e c2                                      mov        es, dx
d3c78:  26 a2 ff 00                                mov        es:[00ffh], al
d3c7c:  b8 3c 41                                   mov        ax, 413ch
d3c7f:  8e c0                                      mov        es, ax
d3c81:  26 a1 34 00                                mov        ax, es:[0034h]
d3c85:  26 8b 16 32 00                             mov        dx, es:[0032h]
d3c8a:  bb 3c 41                                   mov        bx, 413ch
d3c8d:  8e c3                                      mov        es, bx
d3c8f:  26 a3 f2 00                                mov        es:[00f2h], ax
d3c93:  26 89 16 f0 00                             mov        es:[00f0h], dx
d3c98:  b8 3c 41                                   mov        ax, 413ch
d3c9b:  8e c0                                      mov        es, ax
d3c9d:  26 a1 34 00                                mov        ax, es:[0034h]
d3ca1:  a3 2f 00                                   mov        [002fh], ax
d3ca4:  89 16 2d 00                                mov        [002dh], dx
d3ca8:  b8 3c 41                                   mov        ax, 413ch
d3cab:  8e c0                                      mov        es, ax
d3cad:  26 c6 06 ed 00 00                          mov        byte es:[00edh], 00h
d3cb3:  b8 3c 41                                   mov        ax, 413ch
d3cb6:  8e c0                                      mov        es, ax
d3cb8:  26 a0 37 00                                mov        al, es:[0037h]
d3cbc:  a2 3f 00                                   mov        [003fh], al
d3cbf:  b8 3c 41                                   mov        ax, 413ch
d3cc2:  8e c0                                      mov        es, ax
d3cc4:  26 a0 38 00                                mov        al, es:[0038h]
d3cc8:  a2 3e 00                                   mov        [003eh], al
d3ccb:  b8 3c 41                                   mov        ax, 413ch
d3cce:  8e c0                                      mov        es, ax
d3cd0:  26 a0 3a 00                                mov        al, es:[003ah]
d3cd4:  e9 91 fe                                   jmp        loc_d3b68

;  XREF: d3c4b, d3c5b
d3cd7:  33 c0                 loc_d3cd7:           xor        ax, ax

;  XREF: d3b74
d3cd9:  1f                    loc_d3cd9:           pop        ds
d3cda:  cb                                         retf

;  XREF: d3926

; -----------------------------------------------------------------------------
; game_feature_handler (0xD3CDB)
; Game feature event handler (targets, ramps, lanes)
; -----------------------------------------------------------------------------
d3cdb:  1e                    game_feature_handler:           push       ds
d3cdc:  b8 30 41                                   mov        ax, 4130h
d3cdf:  8e d8                                      mov        ds, ax
d3ce1:  9a f2 37 2a d7                             call       game_init_display
d3ce6:  b8 3c 41                                   mov        ax, 413ch
d3ce9:  8e c0                                      mov        es, ax
d3ceb:  26 c7 06 d0 00 00 00                       mov        word es:[00d0h], 0000h
d3cf2:  26 c7 06 ce 00 00 00                       mov        word es:[00ceh], 0000h
d3cf9:  c7 06 2b 00 00 00                          mov        word [002bh], 0000h
d3cff:  c7 06 29 00 00 00                          mov        word [0029h], 0000h
d3d05:  c7 06 27 00 00 00                          mov        word [0027h], 0000h
d3d0b:  c7 06 25 00 00 00                          mov        word [0025h], 0000h
d3d11:  b8 3c 41                                   mov        ax, 413ch
d3d14:  8e c0                                      mov        es, ax
d3d16:  26 83 3e f6 00 00                          cmp        word es:[00f6h], 00h
d3d1c:  74 2e                                      jz         loc_d3d4c
d3d1e:  b8 00 40                                   mov        ax, 4000h
d3d21:  8e c0                                      mov        es, ax
d3d23:  26 80 3e 01 10 05                          cmp        byte es:[1001h], 05h ; game_status_byte - Overall game status communicated to Z80
d3d29:  75 07                                      jnz        loc_d3d32
d3d2b:  9a 0c 37 00 f0                             call       service_statistics_menu
d3d30:  eb 05                                      jmp short  loc_d3d37

;  XREF: d3d29
d3d32:  9a 17 37 00 f0        loc_d3d32:           call       service_statistics_games

;  XREF: d3d30
d3d37:  6a 09                 loc_d3d37:           push       09h
d3d39:  9a 70 0b 00 d0                             call       timer_delay
d3d3e:  59                                         pop        cx
d3d3f:  6a 14                                      push       14h
d3d41:  9a e8 26 f2 d2                             call       switch_read_shared_ram
d3d46:  59                                         pop        cx
d3d47:  9a d1 11 f2 d2                             call       score_add

;  XREF: d3d1c
d3d4c:  b8 3c 41              loc_d3d4c:           mov        ax, 413ch
d3d4f:  8e c0                                      mov        es, ax
d3d51:  26 80 3e fc 00 00                          cmp        byte es:[00fch], 00h
d3d57:  75 03                                      jnz        loc_d3d5c
d3d59:  e9 83 00                                   jmp        loc_d3ddf

;  XREF: d3d57
d3d5c:  b8 00 40              loc_d3d5c:           mov        ax, 4000h
d3d5f:  8e c0                                      mov        es, ax
d3d61:  26 80 3e 01 10 05                          cmp        byte es:[1001h], 05h ; game_status_byte - Overall game status communicated to Z80
d3d67:  75 07                                      jnz        loc_d3d70
d3d69:  9a 38 37 00 f0                             call       service_statistics_balls
d3d6e:  eb 05                                      jmp short  loc_d3d75

;  XREF: d3d67
d3d70:  9a 4e 37 00 f0        loc_d3d70:           call       service_fuse_test

;  XREF: d3d6e
d3d75:  6a 09                 loc_d3d75:           push       09h
d3d77:  9a 70 0b 00 d0                             call       timer_delay
d3d7c:  59                                         pop        cx
d3d7d:  6a 14                                      push       14h
d3d7f:  9a e8 26 f2 d2                             call       switch_read_shared_ram
d3d84:  59                                         pop        cx
d3d85:  b8 3c 41                                   mov        ax, 413ch
d3d88:  8e c0                                      mov        es, ax
d3d8a:  26 a0 fc 00                                mov        al, es:[00fch]
d3d8e:  b4 00                                      mov        ah, 00h
d3d90:  99                                         cwd
d3d91:  50                                         push       ax
d3d92:  52                                         push       dx
d3d93:  ba 01 00                                   mov        dx, 0001h
d3d96:  b8 a0 86                                   mov        ax, 86a0h
d3d99:  59                                         pop        cx
d3d9a:  5b                                         pop        bx
d3d9b:  9a b4 00 26 e3                             call       player_struct_write
d3da0:  89 16 2b 00                                mov        [002bh], dx
d3da4:  a3 29 00                                   mov        [0029h], ax
d3da7:  52                                         push       dx
d3da8:  50                                         push       ax
d3da9:  68 3c 41                                   push       413ch
d3dac:  68 e1 00                                   push       00e1h
d3daf:  9a 20 57 2a d7                             call       score_compare_and_cap
d3db4:  83 c4 08                                   add        word sp, 08h
d3db7:  68 d0 00                                   push       00d0h
d3dba:  68 3c 41                                   push       413ch
d3dbd:  68 e1 00                                   push       00e1h
d3dc0:  9a 07 09 00 f0                             call       dmd_frame_load
d3dc5:  83 c4 06                                   add        word sp, 06h
d3dc8:  6a 09                                      push       09h
d3dca:  9a 70 0b 00 d0                             call       timer_delay
d3dcf:  59                                         pop        cx
d3dd0:  6a 1e                                      push       1eh
d3dd2:  9a e8 26 f2 d2                             call       switch_read_shared_ram
d3dd7:  59                                         pop        cx
d3dd8:  9a cb 0c 00 f0                             call       dmd_resource_load
d3ddd:  eb 0c                                      jmp short  loc_d3deb

;  XREF: d3d59
d3ddf:  c7 06 2b 00 00 00     loc_d3ddf:           mov        word [002bh], 0000h
d3de5:  c7 06 29 00 00 00                          mov        word [0029h], 0000h

;  XREF: d3ddd
d3deb:  b8 3c 41              loc_d3deb:           mov        ax, 413ch
d3dee:  8e c0                                      mov        es, ax
d3df0:  26 80 3e fb 00 00                          cmp        byte es:[00fbh], 00h
d3df6:  75 03                                      jnz        loc_d3dfb
d3df8:  e9 83 00                                   jmp        loc_d3e7e

;  XREF: d3df6
d3dfb:  b8 00 40              loc_d3dfb:           mov        ax, 4000h
d3dfe:  8e c0                                      mov        es, ax
d3e00:  26 80 3e 01 10 05                          cmp        byte es:[1001h], 05h ; game_status_byte - Overall game status communicated to Z80
d3e06:  75 07                                      jnz        loc_d3e0f
d3e08:  9a 43 37 00 f0                             call       service_statistics_delete
d3e0d:  eb 05                                      jmp short  loc_d3e14

;  XREF: d3e06
d3e0f:  9a 59 37 00 f0        loc_d3e0f:           call       service_factory_reset

;  XREF: d3e0d
d3e14:  6a 09                 loc_d3e14:           push       09h
d3e16:  9a 70 0b 00 d0                             call       timer_delay
d3e1b:  59                                         pop        cx
d3e1c:  6a 14                                      push       14h
d3e1e:  9a e8 26 f2 d2                             call       switch_read_shared_ram
d3e23:  59                                         pop        cx
d3e24:  b8 3c 41                                   mov        ax, 413ch
d3e27:  8e c0                                      mov        es, ax
d3e29:  26 a0 fb 00                                mov        al, es:[00fbh]
d3e2d:  b4 00                                      mov        ah, 00h
d3e2f:  99                                         cwd
d3e30:  50                                         push       ax
d3e31:  52                                         push       dx
d3e32:  ba 01 00                                   mov        dx, 0001h
d3e35:  b8 a0 86                                   mov        ax, 86a0h
d3e38:  59                                         pop        cx
d3e39:  5b                                         pop        bx
d3e3a:  9a b4 00 26 e3                             call       player_struct_write
d3e3f:  89 16 27 00                                mov        [0027h], dx
d3e43:  a3 25 00                                   mov        [0025h], ax
d3e46:  52                                         push       dx
d3e47:  50                                         push       ax
d3e48:  68 3c 41                                   push       413ch
d3e4b:  68 e1 00                                   push       00e1h
d3e4e:  9a 20 57 2a d7                             call       score_compare_and_cap
d3e53:  83 c4 08                                   add        word sp, 08h
d3e56:  68 d0 00                                   push       00d0h
d3e59:  68 3c 41                                   push       413ch
d3e5c:  68 e1 00                                   push       00e1h
d3e5f:  9a 07 09 00 f0                             call       dmd_frame_load
d3e64:  83 c4 06                                   add        word sp, 06h
d3e67:  6a 09                                      push       09h
d3e69:  9a 70 0b 00 d0                             call       timer_delay
d3e6e:  59                                         pop        cx
d3e6f:  6a 1e                                      push       1eh
d3e71:  9a e8 26 f2 d2                             call       switch_read_shared_ram
d3e76:  59                                         pop        cx
d3e77:  9a cb 0c 00 f0                             call       dmd_resource_load
d3e7c:  eb 0c                                      jmp short  loc_d3e8a

;  XREF: d3df8
d3e7e:  c7 06 27 00 00 00     loc_d3e7e:           mov        word [0027h], 0000h
d3e84:  c7 06 25 00 00 00                          mov        word [0025h], 0000h

;  XREF: d3e7c
d3e8a:  b8 3c 41              loc_d3e8a:           mov        ax, 413ch
d3e8d:  8e c0                                      mov        es, ax
d3e8f:  26 a1 d0 00                                mov        ax, es:[00d0h]
d3e93:  26 8b 16 ce 00                             mov        dx, es:[00ceh]
d3e98:  03 16 29 00                                add        dx, [0029h]
d3e9c:  13 06 2b 00                                adc        ax, [002bh]
d3ea0:  03 16 25 00                                add        dx, [0025h]
d3ea4:  13 06 27 00                                adc        ax, [0027h]
d3ea8:  bb 3c 41                                   mov        bx, 413ch
d3eab:  8e c3                                      mov        es, bx
d3ead:  26 a3 d0 00                                mov        es:[00d0h], ax
d3eb1:  26 89 16 ce 00                             mov        es:[00ceh], dx
d3eb6:  b8 3c 41                                   mov        ax, 413ch
d3eb9:  8e c0                                      mov        es, ax
d3ebb:  26 80 3e fd 00 0a                          cmp        byte es:[00fdh], 0ah
d3ec1:  74 03                                      jz         loc_d3ec6
d3ec3:  e9 c5 00                                   jmp        loc_d3f8b

;  XREF: d3ec1
d3ec6:  b8 3c 41              loc_d3ec6:           mov        ax, 413ch
d3ec9:  8e c0                                      mov        es, ax
d3ecb:  26 a1 ce 00                                mov        ax, es:[00ceh]
d3ecf:  26 0b 06 d0 00                             or         ax, es:[00d0h]
d3ed4:  75 03                                      jnz        loc_d3ed9
d3ed6:  e9 b2 00                                   jmp        loc_d3f8b

;  XREF: d3ed4
d3ed9:  b8 3c 41              loc_d3ed9:           mov        ax, 413ch
d3edc:  8e c0                                      mov        es, ax
d3ede:  26 8b 0e d0 00                             mov        cx, es:[00d0h]
d3ee3:  26 8b 1e ce 00                             mov        bx, es:[00ceh]
d3ee8:  33 d2                                      xor        dx, dx
d3eea:  b8 0a 00                                   mov        ax, 000ah
d3eed:  9a b4 00 26 e3                             call       player_struct_write
d3ef2:  bb 3c 41                                   mov        bx, 413ch
d3ef5:  8e c3                                      mov        es, bx
d3ef7:  26 89 16 d0 00                             mov        es:[00d0h], dx
d3efc:  26 a3 ce 00                                mov        es:[00ceh], ax
d3f00:  9a d8 35 00 f0                             call       service_video_menu
d3f05:  6a 09                                      push       09h
d3f07:  9a 70 0b 00 d0                             call       timer_delay
d3f0c:  59                                         pop        cx
d3f0d:  6a 14                                      push       14h
d3f0f:  9a e8 26 f2 d2                             call       switch_read_shared_ram
d3f14:  59                                         pop        cx
d3f15:  9a c4 00 00 f0                             call       dmd_buffer_swap
d3f1a:  9a f1 00 00 f0                             call       dmd_buffer_clear
d3f1f:  b8 00 40                                   mov        ax, 4000h
d3f22:  8e c0                                      mov        es, ax
d3f24:  26 80 3e 01 10 05                          cmp        byte es:[1001h], 05h ; game_status_byte - Overall game status communicated to Z80
d3f2a:  75 07                                      jnz        loc_d3f33
d3f2c:  9a e0 36 00 f0                             call       service_match_menu
d3f31:  eb 05                                      jmp short  loc_d3f38

;  XREF: d3f2a
d3f33:  9a eb 36 00 f0        loc_d3f33:           call       service_custom_msg_menu

;  XREF: d3f31
d3f38:  6a 09                 loc_d3f38:           push       09h
d3f3a:  9a 70 0b 00 d0                             call       timer_delay
d3f3f:  59                                         pop        cx
d3f40:  6a 1e                                      push       1eh
d3f42:  9a e8 26 f2 d2                             call       switch_read_shared_ram
d3f47:  59                                         pop        cx
d3f48:  b8 3c 41                                   mov        ax, 413ch
d3f4b:  8e c0                                      mov        es, ax
d3f4d:  26 ff 36 d0 00                             push       word es:[00d0h]
d3f52:  26 ff 36 ce 00                             push       word es:[00ceh]
d3f57:  68 3c 41                                   push       413ch
d3f5a:  68 e1 00                                   push       00e1h
d3f5d:  9a 20 57 2a d7                             call       score_compare_and_cap
d3f62:  83 c4 08                                   add        word sp, 08h
d3f65:  68 d0 00                                   push       00d0h
d3f68:  68 3c 41                                   push       413ch
d3f6b:  68 e1 00                                   push       00e1h
d3f6e:  9a 07 09 00 f0                             call       dmd_frame_load
d3f73:  83 c4 06                                   add        word sp, 06h
d3f76:  6a 09                                      push       09h
d3f78:  9a 70 0b 00 d0                             call       timer_delay
d3f7d:  59                                         pop        cx
d3f7e:  6a 1e                                      push       1eh
d3f80:  9a e8 26 f2 d2                             call       switch_read_shared_ram
d3f85:  59                                         pop        cx
d3f86:  9a cb 0c 00 f0                             call       dmd_resource_load

;  XREF: d3ec3, d3ed6
d3f8b:  b8 3c 41              loc_d3f8b:           mov        ax, 413ch
d3f8e:  8e c0                                      mov        es, ax
d3f90:  26 80 3e fd 00 01                          cmp        byte es:[00fdh], 01h
d3f96:  74 03                                      jz         loc_d3f9b
d3f98:  e9 86 00                                   jmp        loc_d4021

;  XREF: d3f96
d3f9b:  b8 3c 41              loc_d3f9b:           mov        ax, 413ch
d3f9e:  8e c0                                      mov        es, ax
d3fa0:  26 a1 ce 00                                mov        ax, es:[00ceh]
d3fa4:  26 0b 06 d0 00                             or         ax, es:[00d0h]
d3fa9:  74 76                                      jz         loc_d4021
d3fab:  9a f1 00 00 f0                             call       dmd_buffer_clear
d3fb0:  9a c4 00 00 f0                             call       dmd_buffer_swap
d3fb5:  b8 00 40                                   mov        ax, 4000h
d3fb8:  8e c0                                      mov        es, ax
d3fba:  26 80 3e 01 10 05                          cmp        byte es:[1001h], 05h ; game_status_byte - Overall game status communicated to Z80
d3fc0:  75 07                                      jnz        loc_d3fc9
d3fc2:  9a e0 36 00 f0                             call       service_match_menu
d3fc7:  eb 05                                      jmp short  loc_d3fce

;  XREF: d3fc0
d3fc9:  9a eb 36 00 f0        loc_d3fc9:           call       service_custom_msg_menu

;  XREF: d3fc7
d3fce:  6a 09                 loc_d3fce:           push       09h
d3fd0:  9a 70 0b 00 d0                             call       timer_delay
d3fd5:  59                                         pop        cx
d3fd6:  6a 14                                      push       14h
d3fd8:  9a e8 26 f2 d2                             call       switch_read_shared_ram
d3fdd:  59                                         pop        cx
d3fde:  b8 3c 41                                   mov        ax, 413ch
d3fe1:  8e c0                                      mov        es, ax
d3fe3:  26 ff 36 d0 00                             push       word es:[00d0h]
d3fe8:  26 ff 36 ce 00                             push       word es:[00ceh]
d3fed:  68 3c 41                                   push       413ch
d3ff0:  68 e1 00                                   push       00e1h
d3ff3:  9a 20 57 2a d7                             call       score_compare_and_cap
d3ff8:  83 c4 08                                   add        word sp, 08h
d3ffb:  68 d0 00                                   push       00d0h
d3ffe:  68 3c 41                                   push       413ch
d4001:  68 e1 00                                   push       00e1h
d4004:  9a 07 09 00 f0                             call       dmd_frame_load
d4009:  83 c4 06                                   add        word sp, 06h
d400c:  6a 09                                      push       09h
d400e:  9a 70 0b 00 d0                             call       timer_delay
d4013:  59                                         pop        cx
d4014:  6a 1e                                      push       1eh
d4016:  9a e8 26 f2 d2                             call       switch_read_shared_ram
d401b:  59                                         pop        cx
d401c:  9a cb 0c 00 f0                             call       dmd_resource_load

;  XREF: d3f98, d3fa9
d4021:  b8 00 40              loc_d4021:           mov        ax, 4000h
d4024:  8e c0                                      mov        es, ax
d4026:  26 80 3e 01 10 05                          cmp        byte es:[1001h], 05h ; game_status_byte - Overall game status communicated to Z80
d402c:  75 07                                      jnz        loc_d4035
d402e:  9a e3 35 00 f0                             call       service_game_menu
d4033:  eb 05                                      jmp short  loc_d403a

;  XREF: d402c
d4035:  9a ee 35 00 f0        loc_d4035:           call       service_balls_menu

;  XREF: d4033
d403a:  6a 09                 loc_d403a:           push       09h
d403c:  9a 70 0b 00 d0                             call       timer_delay
d4041:  59                                         pop        cx
d4042:  6a 14                                      push       14h
d4044:  9a e8 26 f2 d2                             call       switch_read_shared_ram
d4049:  59                                         pop        cx
d404a:  b8 3c 41                                   mov        ax, 413ch
d404d:  8e c0                                      mov        es, ax
d404f:  26 a1 f2 00                                mov        ax, es:[00f2h]
d4053:  26 8b 16 f0 00                             mov        dx, es:[00f0h]
d4058:  bb 3c 41                                   mov        bx, 413ch
d405b:  8e c3                                      mov        es, bx
d405d:  26 03 16 ce 00                             add        dx, es:[00ceh]
d4062:  26 13 06 d0 00                             adc        ax, es:[00d0h]
d4067:  bb 3c 41                                   mov        bx, 413ch
d406a:  8e c3                                      mov        es, bx
d406c:  26 a3 f2 00                                mov        es:[00f2h], ax
d4070:  26 89 16 f0 00                             mov        es:[00f0h], dx
d4075:  b8 3c 41                                   mov        ax, 413ch
d4078:  8e c0                                      mov        es, ax
d407a:  26 a0 fe 00                                mov        al, es:[00feh]
d407e:  b4 00                                      mov        ah, 00h
d4080:  6b c0 09                                   imul       ax, ax, 09h
d4083:  ba 3c 41                                   mov        dx, 413ch
d4086:  8e c3                                      mov        es, bx
d4088:  26 8b 1e f2 00                             mov        bx, es:[00f2h]
d408d:  26 8b 0e f0 00                             mov        cx, es:[00f0h]
d4092:  8e c2                                      mov        es, dx
d4094:  93                                         xchg       ax, bx
d4095:  26 89 87 2b 00                             mov        es:[bx+002bh], ax
d409a:  26 89 8f 29 00                             mov        es:[bx+0029h], cx
d409f:  b8 3c 41                                   mov        ax, 413ch
d40a2:  8e c0                                      mov        es, ax
d40a4:  26 a0 fe 00                                mov        al, es:[00feh]
d40a8:  b4 00                                      mov        ah, 00h
d40aa:  6b c0 09                                   imul       ax, ax, 09h
d40ad:  8b d8                                      mov        bx, ax
d40af:  8e c2                                      mov        es, dx
d40b1:  26 ff b7 2b 00                             push       word es:[bx+002bh]
d40b6:  26 ff b7 29 00                             push       word es:[bx+0029h]
d40bb:  68 3c 41                                   push       413ch
d40be:  68 e1 00                                   push       00e1h
d40c1:  9a 20 57 2a d7                             call       score_compare_and_cap
d40c6:  83 c4 08                                   add        word sp, 08h
d40c9:  68 d0 00                                   push       00d0h
d40cc:  68 3c 41                                   push       413ch
d40cf:  68 e1 00                                   push       00e1h
d40d2:  9a 07 09 00 f0                             call       dmd_frame_load
d40d7:  83 c4 06                                   add        word sp, 06h
d40da:  6a 09                                      push       09h
d40dc:  9a 70 0b 00 d0                             call       timer_delay
d40e1:  59                                         pop        cx
d40e2:  6a 1e                                      push       1eh
d40e4:  9a e8 26 f2 d2                             call       switch_read_shared_ram
d40e9:  59                                         pop        cx
d40ea:  9a cb 0c 00 f0                             call       dmd_resource_load
d40ef:  1f                                         pop        ds
d40f0:  cb                                         retf

;  XREF: d3d47

; -----------------------------------------------------------------------------
; score_add (0xD40F1)
; Add points to current player's score
; -----------------------------------------------------------------------------
d40f1:  1e                    score_add:           push       ds
d40f2:  b8 30 41                                   mov        ax, 4130h
d40f5:  8e d8                                      mov        ds, ax
d40f7:  b8 3c 41                                   mov        ax, 413ch
d40fa:  8e c0                                      mov        es, ax
d40fc:  26 c7 06 d0 00 00 00                       mov        word es:[00d0h], 0000h
d4103:  26 c7 06 ce 00 00 00                       mov        word es:[00ceh], 0000h
d410a:  b8 3c 41                                   mov        ax, 413ch
d410d:  8e c0                                      mov        es, ax
d410f:  26 c6 06 ea 00 01                          mov        byte es:[00eah], 01h
d4115:  b8 3c 41                                   mov        ax, 413ch
d4118:  8e c0                                      mov        es, ax
d411a:  26 8b 1e f6 00                             mov        bx, es:[00f6h]
d411f:  4b                                         dec        bx
d4120:  83 fb 07                                   cmp        word bx, 07h
d4123:  76 03                                      jbe        loc_d4128
d4125:  e9 53 03                                   jmp        loc_d447b

;  XREF: d4123
d4128:  d1 e3                 loc_d4128:           shl        bx, 1
d412a:  2e ff a7 6d 15                             jmp        cs:[bx+156dh]

;  XREF: d4125
d447b:  9a cb 0c 00 f0        loc_d447b:           call       dmd_resource_load
d4480:  b8 3c 41                                   mov        ax, 413ch
d4483:  8e c0                                      mov        es, ax
d4485:  26 c6 06 ea 00 01                          mov        byte es:[00eah], 01h
d448b:  1f                                         pop        ds
d448c:  cb                                         retf

;  XREF: d31dc

; -----------------------------------------------------------------------------
; score_display_update (0xD449D)
; Update score display on DMD for all players
; -----------------------------------------------------------------------------
d449d:  1e                    score_display_update:           push       ds
d449e:  b8 30 41                                   mov        ax, 4130h
d44a1:  8e d8                                      mov        ds, ax
d44a3:  9a f2 37 2a d7                             call       game_init_display
d44a8:  b8 00 40                                   mov        ax, 4000h
d44ab:  8e c0                                      mov        es, ax
d44ad:  26 80 3e 01 10 05                          cmp        byte es:[1001h], 05h ; game_status_byte - Overall game status communicated to Z80
d44b3:  75 07                                      jnz        loc_d44bc
d44b5:  9a f6 36 00 f0                             call       service_technical_menu
d44ba:  eb 05                                      jmp short  loc_d44c1

;  XREF: d44b3
d44bc:  9a 01 37 00 f0        loc_d44bc:           call       service_board_test

;  XREF: d44ba
d44c1:  6a 64                 loc_d44c1:           push       64h
d44c3:  9a e8 26 f2 d2                             call       switch_read_shared_ram
d44c8:  59                                         pop        cx
d44c9:  b8 3c 41                                   mov        ax, 413ch
d44cc:  8e c0                                      mov        es, ax
d44ce:  26 c6 06 fd 00 01                          mov        byte es:[00fdh], 01h
d44d4:  b8 3c 41                                   mov        ax, 413ch
d44d7:  8b 16 2f 00                                mov        dx, [002fh]
d44db:  8b 1e 2d 00                                mov        bx, [002dh]
d44df:  8e c0                                      mov        es, ax
d44e1:  26 89 16 f2 00                             mov        es:[00f2h], dx
d44e6:  26 89 1e f0 00                             mov        es:[00f0h], bx
d44eb:  b8 3c 41                                   mov        ax, 413ch
d44ee:  8e c0                                      mov        es, ax
d44f0:  26 c6 06 eb 00 00                          mov        byte es:[00ebh], 00h
d44f6:  b8 3c 41                                   mov        ax, 413ch
d44f9:  8e c0                                      mov        es, ax
d44fb:  26 c7 06 f6 00 00 00                       mov        word es:[00f6h], 0000h
d4502:  b8 3c 41                                   mov        ax, 413ch
d4505:  8e c0                                      mov        es, ax
d4507:  26 c6 06 ed 00 00                          mov        byte es:[00edh], 00h
d450d:  b8 3c 41                                   mov        ax, 413ch
d4510:  8e c0                                      mov        es, ax
d4512:  26 a0 fe 00                                mov        al, es:[00feh]
d4516:  b4 00                                      mov        ah, 00h
d4518:  6b c0 09                                   imul       ax, ax, 09h
d451b:  ba 3c 41                                   mov        dx, 413ch
d451e:  8b d8                                      mov        bx, ax
d4520:  8e c2                                      mov        es, dx
d4522:  26 8a 87 2e 00                             mov        al, es:[bx+002eh]
d4527:  a2 3f 00                                   mov        [003fh], al
d452a:  b8 3c 41                                   mov        ax, 413ch
d452d:  8e c0                                      mov        es, ax
d452f:  26 a0 fe 00                                mov        al, es:[00feh]
d4533:  b4 00                                      mov        ah, 00h
d4535:  6b c0 09                                   imul       ax, ax, 09h
d4538:  8b d8                                      mov        bx, ax
d453a:  8e c2                                      mov        es, dx
d453c:  26 8a 87 2f 00                             mov        al, es:[bx+002fh]
d4541:  a2 3e 00                                   mov        [003eh], al
d4544:  9a 47 4a 2a d7                             call       game_state_save
d4549:  b8 3c 41                                   mov        ax, 413ch
d454c:  8e c0                                      mov        es, ax
d454e:  26 c6 06 ea 00 01                          mov        byte es:[00eah], 01h
d4554:  68 8a 01                                   push       018ah
d4557:  9a 3f 0d 00 f0                             call       dmd_scroll_engine
d455c:  59                                         pop        cx
d455d:  68 81 01                                   push       0181h
d4560:  9a 8e 10 00 f0                             call       cpu_peripheral_init
d4565:  59                                         pop        cx
d4566:  9a ae 4a 2a d7                             call       game_state_restore
d456b:  6a 00                                      push       00h
d456d:  9a b4 0d 00 d0                             call       game_mode_set
d4572:  59                                         pop        cx

;  XREF: d457e
d4573:  b8 00 40              loc_d4573:           mov        ax, 4000h
d4576:  8e c0                                      mov        es, ax
d4578:  26 80 3e ee 12 00                          cmp        byte es:[12eeh], 00h
d457e:  75 f3                                      jnz        loc_d4573
d4580:  6a 01                                      push       01h
d4582:  9a b4 0d 00 d0                             call       game_mode_set
d4587:  59                                         pop        cx
d4588:  9a ab 54 2a d7                             call       dmd_end_of_ball_display
d458d:  b8 3c 41                                   mov        ax, 413ch
d4590:  8e c0                                      mov        es, ax
d4592:  26 ff 36 f2 00                             push       word es:[00f2h]
d4597:  26 ff 36 f0 00                             push       word es:[00f0h]
d459c:  68 3c 41                                   push       413ch
d459f:  68 e1 00                                   push       00e1h
d45a2:  9a 20 57 2a d7                             call       score_compare_and_cap
d45a7:  83 c4 08                                   add        word sp, 08h
d45aa:  6a 00                                      push       00h
d45ac:  68 3c 41                                   push       413ch
d45af:  68 e1 00                                   push       00e1h
d45b2:  9a 07 09 00 f0                             call       dmd_frame_load
d45b7:  83 c4 06                                   add        word sp, 06h
d45ba:  1f                                         pop        ds
d45bb:  cb                                         retf

;  XREF: dc00a

; -----------------------------------------------------------------------------
; high_score_check (0xD45BC)
; Check if current score qualifies for high score table
; -----------------------------------------------------------------------------
d45bc:  1e                    high_score_check:           push       ds
d45bd:  b8 30 41                                   mov        ax, 4130h
d45c0:  8e d8                                      mov        ds, ax
d45c2:  b8 3c 41                                   mov        ax, 413ch
d45c5:  8e c0                                      mov        es, ax
d45c7:  26 a0 fe 00                                mov        al, es:[00feh]
d45cb:  b4 00                                      mov        ah, 00h
d45cd:  6b c0 09                                   imul       ax, ax, 09h
d45d0:  ba 3c 41                                   mov        dx, 413ch
d45d3:  bb 29 00                                   mov        bx, 0029h
d45d6:  83 c3 07                                   add        word bx, 07h
d45d9:  03 c3                                      add        ax, bx
d45db:  8b d8                                      mov        bx, ax
d45dd:  8e c2                                      mov        es, dx
d45df:  26 80 3f 00                                cmp        byte es:[bx], 00h
d45e3:  75 1c                                      jnz        loc_d4601
d45e5:  b8 3c 41                                   mov        ax, 413ch
d45e8:  8e c0                                      mov        es, ax
d45ea:  26 a0 ff 00                                mov        al, es:[00ffh]
d45ee:  3a 06 3d 00                                cmp        al, [003dh]
d45f2:  75 0d                                      jnz        loc_d4601
d45f4:  b8 3c 41                                   mov        ax, 413ch
d45f7:  8e c0                                      mov        es, ax
d45f9:  26 c6 06 02 01 06                          mov        byte es:[0102h], 06h
d45ff:  eb 23                                      jmp short  loc_d4624

;  XREF: d45e3, d45f2
d4601:  b8 3c 41              loc_d4601:           mov        ax, 413ch
d4604:  8e c0                                      mov        es, ax
d4606:  26 a0 fe 00                                mov        al, es:[00feh]
d460a:  b4 00                                      mov        ah, 00h
d460c:  6b c0 09                                   imul       ax, ax, 09h
d460f:  ba 3c 41                                   mov        dx, 413ch
d4612:  8b d8                                      mov        bx, ax
d4614:  8e c2                                      mov        es, dx
d4616:  26 8a 87 31 00                             mov        al, es:[bx+0031h]
d461b:  ba 3c 41                                   mov        dx, 413ch
d461e:  8e c2                                      mov        es, dx
d4620:  26 a2 02 01                                mov        es:[0102h], al

;  XREF: d45ff
d4624:  1f                    loc_d4624:           pop        ds
d4625:  cb                                         retf

;  XREF: d3a92

; -----------------------------------------------------------------------------
; high_score_entry (0xD4626)
; High score name entry mode (letter selection with flippers)
; -----------------------------------------------------------------------------
d4626:  1e                    high_score_entry:           push       ds
d4627:  b8 30 41                                   mov        ax, 4130h
d462a:  8e d8                                      mov        ds, ax
d462c:  c7 06 23 00 00 00                          mov        word [0023h], 0000h
d4632:  c7 06 21 00 00 00                          mov        word [0021h], 0000h
d4638:  9a c4 00 00 f0                             call       dmd_buffer_swap
d463d:  9a f1 00 00 f0                             call       dmd_buffer_clear
d4642:  b8 00 40                                   mov        ax, 4000h
d4645:  8e c0                                      mov        es, ax
d4647:  26 80 3e 01 10 05                          cmp        byte es:[1001h], 05h ; game_status_byte - Overall game status communicated to Z80
d464d:  75 07                                      jnz        loc_d4656
d464f:  9a f9 35 00 f0                             call       service_extra_ball_menu
d4654:  eb 05                                      jmp short  loc_d465b

;  XREF: d464d
d4656:  9a 04 36 00 f0        loc_d4656:           call       service_awards_menu

;  XREF: d4654
d465b:  b8 3c 41              loc_d465b:           mov        ax, 413ch
d465e:  8e c0                                      mov        es, ax
d4660:  26 a0 fe 00                                mov        al, es:[00feh]
d4664:  b4 00                                      mov        ah, 00h
d4666:  6b c0 09                                   imul       ax, ax, 09h
d4669:  ba 3c 41                                   mov        dx, 413ch
d466c:  8b d8                                      mov        bx, ax
d466e:  8e c2                                      mov        es, dx
d4670:  26 8b 87 2b 00                             mov        ax, es:[bx+002bh]
d4675:  26 8b 97 29 00                             mov        dx, es:[bx+0029h]
d467a:  03 16 21 00                                add        dx, [0021h]
d467e:  13 06 23 00                                adc        ax, [0023h]
d4682:  bb 3c 41                                   mov        bx, 413ch
d4685:  8e c3                                      mov        es, bx
d4687:  26 8a 1e fe 00                             mov        bl, es:[00feh]
d468c:  b7 00                                      mov        bh, 00h
d468e:  6b db 09                                   imul       bx, bx, 09h
d4691:  b9 3c 41                                   mov        cx, 413ch
d4694:  8e c1                                      mov        es, cx
d4696:  26 89 87 2b 00                             mov        es:[bx+002bh], ax
d469b:  26 89 97 29 00                             mov        es:[bx+0029h], dx
d46a0:  b8 3c 41                                   mov        ax, 413ch
d46a3:  8e c0                                      mov        es, ax
d46a5:  26 a0 fe 00                                mov        al, es:[00feh]
d46a9:  b4 00                                      mov        ah, 00h
d46ab:  6b c0 09                                   imul       ax, ax, 09h
d46ae:  ba 3c 41                                   mov        dx, 413ch
d46b1:  8b d8                                      mov        bx, ax
d46b3:  8e c2                                      mov        es, dx
d46b5:  26 ff b7 2b 00                             push       word es:[bx+002bh]
d46ba:  26 ff b7 29 00                             push       word es:[bx+0029h]
d46bf:  68 3c 41                                   push       413ch
d46c2:  68 e1 00                                   push       00e1h
d46c5:  9a 20 57 2a d7                             call       score_compare_and_cap
d46ca:  83 c4 08                                   add        word sp, 08h
d46cd:  68 d0 00                                   push       00d0h
d46d0:  68 3c 41                                   push       413ch
d46d3:  68 e1 00                                   push       00e1h
d46d6:  9a 07 09 00 f0                             call       dmd_frame_load
d46db:  83 c4 06                                   add        word sp, 06h
d46de:  6a 3c                                      push       3ch
d46e0:  9a e8 26 f2 d2                             call       switch_read_shared_ram
d46e5:  59                                         pop        cx
d46e6:  9a cb 0c 00 f0                             call       dmd_resource_load
d46eb:  b8 3c 41                                   mov        ax, 413ch
d46ee:  8e c0                                      mov        es, ax
d46f0:  26 c6 06 ea 00 01                          mov        byte es:[00eah], 01h
d46f6:  1f                                         pop        ds
d46f7:  cb                                         retf

;  XREF: d3237

; -----------------------------------------------------------------------------
; match_sequence (0xD46F8)
; MATCH/LOTTERY SEQUENCE: Display end-of-game match number animation. Calls match_animation then match_result_check
; -----------------------------------------------------------------------------
d46f8:  1e                    match_sequence:           push       ds
d46f9:  b8 30 41                                   mov        ax, 4130h
d46fc:  8e d8                                      mov        ds, ax
d46fe:  68 ab 00                                   push       00abh
d4701:  9a 38 01 00 d0                             call       cmd_queue_push
d4706:  59                                         pop        cx
d4707:  9a c4 00 00 f0                             call       dmd_buffer_swap
d470c:  9a f1 00 00 f0                             call       dmd_buffer_clear
d4711:  9a 64 19 f2 d2                             call       match_animation
d4716:  c7 06 0e 00 00 00                          mov        word [000eh], 0000h
d471c:  c7 06 0e 00 00 00                          mov        word [000eh], 0000h
d4722:  e9 b9 00                                   jmp        loc_d47de

;  XREF: d47ef
d4725:  68 40 50              loc_d4725:           push       5040h
d4728:  68 0e 02                                   push       020eh
d472b:  9a 92 04 00 d0                             call       display_set_animation_29refs
d4730:  83 c4 04                                   add        word sp, 04h
d4733:  8b 1e 0e 00                                mov        bx, [000eh]
d4737:  6b db 09                                   imul       bx, bx, 09h
d473a:  b9 3c 41                                   mov        cx, 413ch
d473d:  8e c1                                      mov        es, cx
d473f:  26 3b 97 34 00                             cmp        dx, es:[bx+0034h]
d4744:  7f 1c                                      jg         loc_d4762
d4746:  75 07                                      jnz        loc_d474f
d4748:  26 3b 87 32 00                             cmp        ax, es:[bx+0032h]
d474d:  77 13                                      ja         loc_d4762

;  XREF: d4746
d474f:  a0 0e 00              loc_d474f:           mov        al, [000eh]
d4752:  fe c0                                      inc        byte al
d4754:  50                                         push       ax
d4755:  9a 3f 2f 2a d7                             call       match_display_handler
d475a:  59                                         pop        cx
d475b:  9a ba 19 f2 d2                             call       match_result_check
d4760:  eb 78                                      jmp short  loc_d47da

;  XREF: d4744, d474d
d4762:  68 40 50              loc_d4762:           push       5040h
d4765:  68 33 02                                   push       0233h
d4768:  9a 92 04 00 d0                             call       display_set_animation_29refs
d476d:  83 c4 04                                   add        word sp, 04h
d4770:  8b 1e 0e 00                                mov        bx, [000eh]
d4774:  6b db 09                                   imul       bx, bx, 09h
d4777:  b9 3c 41                                   mov        cx, 413ch
d477a:  8e c1                                      mov        es, cx
d477c:  26 3b 97 34 00                             cmp        dx, es:[bx+0034h]
d4781:  7f 1c                                      jg         loc_d479f
d4783:  75 07                                      jnz        loc_d478c
d4785:  26 3b 87 32 00                             cmp        ax, es:[bx+0032h]
d478a:  77 13                                      ja         loc_d479f

;  XREF: d4783
d478c:  a0 0e 00              loc_d478c:           mov        al, [000eh]
d478f:  fe c0                                      inc        byte al
d4791:  50                                         push       ax
d4792:  9a 3f 2f 2a d7                             call       match_display_handler
d4797:  59                                         pop        cx
d4798:  9a 9c 1b f2 d2                             call       statistics_update
d479d:  eb 3b                                      jmp short  loc_d47da

;  XREF: d4781, d478a
d479f:  68 40 50              loc_d479f:           push       5040h
d47a2:  68 58 02                                   push       0258h
d47a5:  9a 92 04 00 d0                             call       display_set_animation_29refs
d47aa:  83 c4 04                                   add        word sp, 04h
d47ad:  8b 1e 0e 00                                mov        bx, [000eh]
d47b1:  6b db 09                                   imul       bx, bx, 09h
d47b4:  b9 3c 41                                   mov        cx, 413ch
d47b7:  8e c1                                      mov        es, cx
d47b9:  26 3b 97 34 00                             cmp        dx, es:[bx+0034h]
d47be:  7f 1a                                      jg         loc_d47da
d47c0:  75 07                                      jnz        loc_d47c9
d47c2:  26 3b 87 32 00                             cmp        ax, es:[bx+0032h]
d47c7:  77 11                                      ja         loc_d47da

;  XREF: d47c0
d47c9:  a0 0e 00              loc_d47c9:           mov        al, [000eh]
d47cc:  fe c0                                      inc        byte al
d47ce:  50                                         push       ax
d47cf:  9a 3f 2f 2a d7                             call       match_display_handler
d47d4:  59                                         pop        cx
d47d5:  9a fa 1c f2 d2                             call       credits_management

;  XREF: d4760, d479d, d47be, d47c7
d47da:  ff 06 0e 00           loc_d47da:           inc        word [000eh]

;  XREF: d4722
d47de:  b8 3c 41              loc_d47de:           mov        ax, 413ch
d47e1:  8e c0                                      mov        es, ax
d47e3:  26 a0 d7 00                                mov        al, es:[00d7h] ; game_flag_1 - General game flag 1
d47e7:  b4 00                                      mov        ah, 00h
d47e9:  3b 06 0e 00                                cmp        ax, [000eh]
d47ed:  7e 03                                      jle        loc_d47f2
d47ef:  e9 33 ff                                   jmp        loc_d4725

;  XREF: d47ed
d47f2:  9a d4 1d f2 d2        loc_d47f2:           call       coin_handler
d47f7:  b8 3c 41                                   mov        ax, 413ch     ; AX = 413Ch (game state segment for match result)
d47fa:  8e c0                                      mov        es, ax
d47fc:  26 80 3e d4 00 00                          cmp        byte es:[00d4h], 00h ; credit_available - Non-zero when credits are available for game start
d4802:  74 0d                                      jz         loc_d4811
d4804:  b8 3c 41                                   mov        ax, 413ch
d4807:  8e c0                                      mov        es, ax
d4809:  26 c6 06 4f 01 02                          mov        byte es:[014fh], 02h ; game_state_var - STATE MACHINE variable: 0=init, 1=attract, 2=game_active, 4=special_mode
d480f:  eb 0b                                      jmp short  loc_d481c

;  XREF: d4802
d4811:  b8 3c 41              loc_d4811:           mov        ax, 413ch
d4814:  8e c0                                      mov        es, ax
d4816:  26 c6 06 4f 01 01                          mov        byte es:[014fh], 01h ; game_state_var - STATE MACHINE variable: 0=init, 1=attract, 2=game_active, 4=special_mode

;  XREF: d480f
d481c:  b8 3c 41              loc_d481c:           mov        ax, 413ch
d481f:  8e c0                                      mov        es, ax
d4821:  26 c6 06 d7 00 00                          mov        byte es:[00d7h], 00h ; game_flag_1 - General game flag 1
d4827:  b8 3c 41                                   mov        ax, 413ch
d482a:  8e c0                                      mov        es, ax
d482c:  26 c6 06 eb 00 00                          mov        byte es:[00ebh], 00h
d4832:  b8 3c 41                                   mov        ax, 413ch
d4835:  8e c0                                      mov        es, ax
d4837:  26 c6 06 ec 00 00                          mov        byte es:[00ech], 00h
d483d:  b8 3c 41                                   mov        ax, 413ch
d4840:  8e c0                                      mov        es, ax
d4842:  26 c6 06 ed 00 00                          mov        byte es:[00edh], 00h
d4848:  68 c4 00                                   push       00c4h
d484b:  9a 38 01 00 d0                             call       cmd_queue_push
d4850:  59                                         pop        cx
d4851:  68 a9 00                                   push       00a9h
d4854:  9a 38 01 00 d0                             call       cmd_queue_push
d4859:  59                                         pop        cx
d485a:  6a 40                                      push       40h
d485c:  9a 0a 00 2a d7                             call       dmd_anim_play
d4861:  59                                         pop        cx
d4862:  9a f1 29 f2 d2                             call       start_button_handler
d4867:  c7 06 18 00 00 00                          mov        word [0018h], 0000h
d486d:  c7 06 16 00 00 00                          mov        word [0016h], 0000h
d4873:  c7 06 14 00 00 00                          mov        word [0014h], 0000h
d4879:  c7 06 12 00 00 00                          mov        word [0012h], 0000h
d487f:  b8 01 00                                   mov        ax, 0001h
d4882:  1f                                         pop        ds
d4883:  cb                                         retf

;  XREF: d4711

; -----------------------------------------------------------------------------
; match_animation (0xD4884)
; Match number spinning animation on DMD
; -----------------------------------------------------------------------------
d4884:  1e                    match_animation:           push       ds
d4885:  b8 30 41                                   mov        ax, 4130h
d4888:  8e d8                                      mov        ds, ax
d488a:  c7 06 0e 00 00 00                          mov        word [000eh], 0000h
d4890:  c7 06 0e 00 00 00                          mov        word [000eh], 0000h
d4896:  eb 2f                                      jmp short  loc_d48c7

;  XREF: d48d6
d4898:  8b 1e 0e 00           loc_d4898:           mov        bx, [000eh]
d489c:  6b db 09                                   imul       bx, bx, 09h
d489f:  b8 3c 41                                   mov        ax, 413ch
d48a2:  8e c0                                      mov        es, ax
d48a4:  26 ff b7 34 00                             push       word es:[bx+0034h]
d48a9:  26 ff b7 32 00                             push       word es:[bx+0032h]
d48ae:  a1 0e 00                                   mov        ax, [000eh]
d48b1:  6b c0 09                                   imul       ax, ax, 09h
d48b4:  05 0e 00                                   add        ax, 000eh
d48b7:  68 3c 41                                   push       413ch
d48ba:  50                                         push       ax
d48bb:  9a 20 57 2a d7                             call       score_compare_and_cap
d48c0:  83 c4 08                                   add        word sp, 08h
d48c3:  ff 06 0e 00                                inc        word [000eh]

;  XREF: d4896
d48c7:  b8 3c 41              loc_d48c7:           mov        ax, 413ch
d48ca:  8e c0                                      mov        es, ax
d48cc:  26 a0 d7 00                                mov        al, es:[00d7h] ; game_flag_1 - General game flag 1
d48d0:  b4 00                                      mov        ah, 00h
d48d2:  3b 06 0e 00                                cmp        ax, [000eh]
d48d6:  7f c0                                      jg         loc_d4898
d48d8:  1f                                         pop        ds
d48d9:  cb                                         retf

;  XREF: d475b

; -----------------------------------------------------------------------------
; match_result_check (0xD48DA)
; Check if match number equals player score digit, award free game
; -----------------------------------------------------------------------------
d48da:  1e                    match_result_check:           push       ds
d48db:  b8 30 41                                   mov        ax, 4130h
d48de:  8e d8                                      mov        ds, ax
d48e0:  8b 1e 0e 00                                mov        bx, [000eh]
d48e4:  6b db 09                                   imul       bx, bx, 09h
d48e7:  b8 3c 41                                   mov        ax, 413ch
d48ea:  8e c0                                      mov        es, ax
d48ec:  26 ff b7 34 00                             push       word es:[bx+0034h]
d48f1:  26 ff b7 32 00                             push       word es:[bx+0032h]
d48f6:  68 40 50                                   push       5040h
d48f9:  68 0e 02                                   push       020eh
d48fc:  9a 6d 04 00 d0                             call       display_write_param_25refs
d4901:  83 c4 08                                   add        word sp, 08h
d4904:  8b 1e 0e 00                                mov        bx, [000eh]
d4908:  6b db 09                                   imul       bx, bx, 09h
d490b:  b8 3c 41                                   mov        ax, 413ch
d490e:  8e c0                                      mov        es, ax
d4910:  26 ff b7 34 00                             push       word es:[bx+0034h]
d4915:  26 ff b7 32 00                             push       word es:[bx+0032h]
d491a:  68 3c 41                                   push       413ch
d491d:  68 e1 00                                   push       00e1h
d4920:  9a 20 57 2a d7                             call       score_compare_and_cap
d4925:  83 c4 08                                   add        word sp, 08h
d4928:  68 3c 41                                   push       413ch
d492b:  68 e1 00                                   push       00e1h
d492e:  9a 3f 27 f2 d2                             call       switch_code_lookup
d4933:  83 c4 04                                   add        word sp, 04h
d4936:  68 40 50                                   push       5040h
d4939:  68 44 02                                   push       0244h
d493c:  9a bf 04 00 d0                             call       display_check_status_48refs
d4941:  83 c4 04                                   add        word sp, 04h
d4944:  a2 07 00                                   mov        [0007h], al
d4947:  c7 06 0c 00 00 00                          mov        word [000ch], 0000h
d494d:  eb 29                                      jmp short  loc_d4978

;  XREF: d4980
d494f:  a1 0c 00              loc_d494f:           mov        ax, [000ch]
d4952:  05 44 02                                   add        ax, 0244h
d4955:  68 40 50                                   push       5040h
d4958:  50                                         push       ax
d4959:  9a bf 04 00 d0                             call       display_check_status_48refs
d495e:  83 c4 04                                   add        word sp, 04h
d4961:  50                                         push       ax
d4962:  a1 0c 00                                   mov        ax, [000ch]
d4965:  05 69 02                                   add        ax, 0269h
d4968:  68 40 50                                   push       5040h
d496b:  50                                         push       ax
d496c:  9a a9 04 00 d0                             call       display_load_resource_51refs
d4971:  83 c4 06                                   add        word sp, 06h
d4974:  ff 06 0c 00                                inc        word [000ch]

;  XREF: d494d
d4978:  a0 07 00              loc_d4978:           mov        al, [0007h]
d497b:  98                                         cbw
d497c:  3b 06 0c 00                                cmp        ax, [000ch]
d4980:  7d cd                                      jge        loc_d494f
d4982:  c7 06 0c 00 00 00                          mov        word [000ch], 0000h
d4988:  eb 29                                      jmp short  loc_d49b3

;  XREF: d49b8
d498a:  a1 0c 00              loc_d498a:           mov        ax, [000ch]
d498d:  05 37 02                                   add        ax, 0237h
d4990:  68 40 50                                   push       5040h
d4993:  50                                         push       ax
d4994:  9a bf 04 00 d0                             call       display_check_status_48refs
d4999:  83 c4 04                                   add        word sp, 04h
d499c:  50                                         push       ax
d499d:  a1 0c 00                                   mov        ax, [000ch]
d49a0:  05 5c 02                                   add        ax, 025ch
d49a3:  68 40 50                                   push       5040h
d49a6:  50                                         push       ax
d49a7:  9a a9 04 00 d0                             call       display_load_resource_51refs
d49ac:  83 c4 06                                   add        word sp, 06h
d49af:  ff 06 0c 00                                inc        word [000ch]

;  XREF: d4988
d49b3:  83 3e 0c 00 0d        loc_d49b3:           cmp        word [000ch], 0dh
d49b8:  7c d0                                      jl         loc_d498a
d49ba:  68 40 50                                   push       5040h
d49bd:  68 1f 02                                   push       021fh
d49c0:  9a bf 04 00 d0                             call       display_check_status_48refs
d49c5:  83 c4 04                                   add        word sp, 04h
d49c8:  a2 07 00                                   mov        [0007h], al
d49cb:  c7 06 0c 00 00 00                          mov        word [000ch], 0000h
d49d1:  eb 29                                      jmp short  loc_d49fc

;  XREF: d4a04
d49d3:  a1 0c 00              loc_d49d3:           mov        ax, [000ch]
d49d6:  05 1f 02                                   add        ax, 021fh
d49d9:  68 40 50                                   push       5040h
d49dc:  50                                         push       ax
d49dd:  9a bf 04 00 d0                             call       display_check_status_48refs
d49e2:  83 c4 04                                   add        word sp, 04h
d49e5:  50                                         push       ax
d49e6:  a1 0c 00                                   mov        ax, [000ch]
d49e9:  05 44 02                                   add        ax, 0244h
d49ec:  68 40 50                                   push       5040h
d49ef:  50                                         push       ax
d49f0:  9a a9 04 00 d0                             call       display_load_resource_51refs
d49f5:  83 c4 06                                   add        word sp, 06h
d49f8:  ff 06 0c 00                                inc        word [000ch]

;  XREF: d49d1
d49fc:  a0 07 00              loc_d49fc:           mov        al, [0007h]
d49ff:  98                                         cbw
d4a00:  3b 06 0c 00                                cmp        ax, [000ch]
d4a04:  7d cd                                      jge        loc_d49d3
d4a06:  c7 06 0c 00 00 00                          mov        word [000ch], 0000h
d4a0c:  eb 29                                      jmp short  loc_d4a37

;  XREF: d4a3c
d4a0e:  a1 0c 00              loc_d4a0e:           mov        ax, [000ch]
d4a11:  05 12 02                                   add        ax, 0212h
d4a14:  68 40 50                                   push       5040h
d4a17:  50                                         push       ax
d4a18:  9a bf 04 00 d0                             call       display_check_status_48refs
d4a1d:  83 c4 04                                   add        word sp, 04h
d4a20:  50                                         push       ax
d4a21:  a1 0c 00                                   mov        ax, [000ch]
d4a24:  05 37 02                                   add        ax, 0237h
d4a27:  68 40 50                                   push       5040h
d4a2a:  50                                         push       ax
d4a2b:  9a a9 04 00 d0                             call       display_load_resource_51refs
d4a30:  83 c4 06                                   add        word sp, 06h
d4a33:  ff 06 0c 00                                inc        word [000ch]

;  XREF: d4a0c
d4a37:  83 3e 0c 00 0d        loc_d4a37:           cmp        word [000ch], 0dh
d4a3c:  7c d0                                      jl         loc_d4a0e
d4a3e:  c7 06 0c 00 00 00                          mov        word [000ch], 0000h
d4a44:  eb 25                                      jmp short  loc_d4a6b

;  XREF: d4a70
d4a46:  b8 3c 41              loc_d4a46:           mov        ax, 413ch
d4a49:  8b 1e 0c 00                                mov        bx, [000ch]
d4a4d:  8e c0                                      mov        es, ax
d4a4f:  26 8a 87 00 00                             mov        al, es:[bx]
d4a54:  50                                         push       ax
d4a55:  a1 0c 00                                   mov        ax, [000ch]
d4a58:  05 12 02                                   add        ax, 0212h
d4a5b:  68 40 50                                   push       5040h
d4a5e:  50                                         push       ax
d4a5f:  9a a9 04 00 d0                             call       display_load_resource_51refs
d4a64:  83 c4 06                                   add        word sp, 06h
d4a67:  ff 06 0c 00                                inc        word [000ch]

;  XREF: d4a44
d4a6b:  83 3e 0c 00 0d        loc_d4a6b:           cmp        word [000ch], 0dh
d4a70:  7c d4                                      jl         loc_d4a46
d4a72:  b8 3c 41                                   mov        ax, 413ch
d4a75:  8e c0                                      mov        es, ax
d4a77:  26 a0 c6 00                                mov        al, es:[00c6h]
d4a7b:  a2 07 00                                   mov        [0007h], al
d4a7e:  c7 06 0c 00 00 00                          mov        word [000ch], 0000h
d4a84:  eb 25                                      jmp short  loc_d4aab

;  XREF: d4ab3
d4a86:  b8 3c 41              loc_d4a86:           mov        ax, 413ch
d4a89:  8b 1e 0c 00                                mov        bx, [000ch]
d4a8d:  8e c0                                      mov        es, ax
d4a8f:  26 8a 87 c6 00                             mov        al, es:[bx+00c6h]
d4a94:  50                                         push       ax
d4a95:  a1 0c 00                                   mov        ax, [000ch]
d4a98:  05 1f 02                                   add        ax, 021fh
d4a9b:  68 40 50                                   push       5040h
d4a9e:  50                                         push       ax
d4a9f:  9a a9 04 00 d0                             call       display_load_resource_51refs
d4aa4:  83 c4 06                                   add        word sp, 06h
d4aa7:  ff 06 0c 00                                inc        word [000ch]

;  XREF: d4a84
d4aab:  a0 07 00              loc_d4aab:           mov        al, [0007h]
d4aae:  98                                         cbw
d4aaf:  3b 06 0c 00                                cmp        ax, [000ch]
d4ab3:  7d d1                                      jge        loc_d4a86
d4ab5:  9a 37 38 f2 d2                             call       bumper_hit_handler
d4aba:  1f                                         pop        ds
d4abb:  cb                                         retf

;  XREF: d4798

; -----------------------------------------------------------------------------
; statistics_update (0xD4ABC)
; Update game statistics counters in EEPROM
; -----------------------------------------------------------------------------
d4abc:  1e                    statistics_update:           push       ds
d4abd:  b8 30 41                                   mov        ax, 4130h
d4ac0:  8e d8                                      mov        ds, ax
d4ac2:  8b 1e 0e 00                                mov        bx, [000eh]
d4ac6:  6b db 09                                   imul       bx, bx, 09h
d4ac9:  b8 3c 41                                   mov        ax, 413ch
d4acc:  8e c0                                      mov        es, ax
d4ace:  26 ff b7 34 00                             push       word es:[bx+0034h]
d4ad3:  26 ff b7 32 00                             push       word es:[bx+0032h]
d4ad8:  68 40 50                                   push       5040h
d4adb:  68 33 02                                   push       0233h
d4ade:  9a 6d 04 00 d0                             call       display_write_param_25refs
d4ae3:  83 c4 08                                   add        word sp, 08h
d4ae6:  8b 1e 0e 00                                mov        bx, [000eh]
d4aea:  6b db 09                                   imul       bx, bx, 09h
d4aed:  b8 3c 41                                   mov        ax, 413ch
d4af0:  8e c0                                      mov        es, ax
d4af2:  26 ff b7 34 00                             push       word es:[bx+0034h]
d4af7:  26 ff b7 32 00                             push       word es:[bx+0032h]
d4afc:  68 3c 41                                   push       413ch
d4aff:  68 e1 00                                   push       00e1h
d4b02:  9a 20 57 2a d7                             call       score_compare_and_cap
d4b07:  83 c4 08                                   add        word sp, 08h
d4b0a:  68 3c 41                                   push       413ch
d4b0d:  68 e1 00                                   push       00e1h
d4b10:  9a 3f 27 f2 d2                             call       switch_code_lookup
d4b15:  83 c4 04                                   add        word sp, 04h
d4b18:  68 40 50                                   push       5040h
d4b1b:  68 44 02                                   push       0244h
d4b1e:  9a bf 04 00 d0                             call       display_check_status_48refs
d4b23:  83 c4 04                                   add        word sp, 04h
d4b26:  a2 07 00                                   mov        [0007h], al
d4b29:  c7 06 0c 00 00 00                          mov        word [000ch], 0000h
d4b2f:  eb 29                                      jmp short  loc_d4b5a

;  XREF: d4b62
d4b31:  a1 0c 00              loc_d4b31:           mov        ax, [000ch]
d4b34:  05 44 02                                   add        ax, 0244h
d4b37:  68 40 50                                   push       5040h
d4b3a:  50                                         push       ax
d4b3b:  9a bf 04 00 d0                             call       display_check_status_48refs
d4b40:  83 c4 04                                   add        word sp, 04h
d4b43:  50                                         push       ax
d4b44:  a1 0c 00                                   mov        ax, [000ch]
d4b47:  05 69 02                                   add        ax, 0269h
d4b4a:  68 40 50                                   push       5040h
d4b4d:  50                                         push       ax
d4b4e:  9a a9 04 00 d0                             call       display_load_resource_51refs
d4b53:  83 c4 06                                   add        word sp, 06h
d4b56:  ff 06 0c 00                                inc        word [000ch]

;  XREF: d4b2f
d4b5a:  a0 07 00              loc_d4b5a:           mov        al, [0007h]
d4b5d:  98                                         cbw
d4b5e:  3b 06 0c 00                                cmp        ax, [000ch]
d4b62:  7d cd                                      jge        loc_d4b31
d4b64:  c7 06 0c 00 00 00                          mov        word [000ch], 0000h
d4b6a:  eb 29                                      jmp short  loc_d4b95

;  XREF: d4b9a
d4b6c:  a1 0c 00              loc_d4b6c:           mov        ax, [000ch]
d4b6f:  05 37 02                                   add        ax, 0237h
d4b72:  68 40 50                                   push       5040h
d4b75:  50                                         push       ax
d4b76:  9a bf 04 00 d0                             call       display_check_status_48refs
d4b7b:  83 c4 04                                   add        word sp, 04h
d4b7e:  50                                         push       ax
d4b7f:  a1 0c 00                                   mov        ax, [000ch]
d4b82:  05 5c 02                                   add        ax, 025ch
d4b85:  68 40 50                                   push       5040h
d4b88:  50                                         push       ax
d4b89:  9a a9 04 00 d0                             call       display_load_resource_51refs
d4b8e:  83 c4 06                                   add        word sp, 06h
d4b91:  ff 06 0c 00                                inc        word [000ch]

;  XREF: d4b6a
d4b95:  83 3e 0c 00 0d        loc_d4b95:           cmp        word [000ch], 0dh
d4b9a:  7c d0                                      jl         loc_d4b6c
d4b9c:  c7 06 0c 00 00 00                          mov        word [000ch], 0000h
d4ba2:  eb 25                                      jmp short  loc_d4bc9

;  XREF: d4bce
d4ba4:  b8 3c 41              loc_d4ba4:           mov        ax, 413ch
d4ba7:  8b 1e 0c 00                                mov        bx, [000ch]
d4bab:  8e c0                                      mov        es, ax
d4bad:  26 8a 87 00 00                             mov        al, es:[bx]
d4bb2:  50                                         push       ax
d4bb3:  a1 0c 00                                   mov        ax, [000ch]
d4bb6:  05 37 02                                   add        ax, 0237h
d4bb9:  68 40 50                                   push       5040h
d4bbc:  50                                         push       ax
d4bbd:  9a a9 04 00 d0                             call       display_load_resource_51refs
d4bc2:  83 c4 06                                   add        word sp, 06h
d4bc5:  ff 06 0c 00                                inc        word [000ch]

;  XREF: d4ba2
d4bc9:  83 3e 0c 00 0d        loc_d4bc9:           cmp        word [000ch], 0dh
d4bce:  7c d4                                      jl         loc_d4ba4
d4bd0:  b8 3c 41                                   mov        ax, 413ch
d4bd3:  8e c0                                      mov        es, ax
d4bd5:  26 a0 c6 00                                mov        al, es:[00c6h]
d4bd9:  a2 07 00                                   mov        [0007h], al
d4bdc:  c7 06 0c 00 00 00                          mov        word [000ch], 0000h
d4be2:  eb 25                                      jmp short  loc_d4c09

;  XREF: d4c11
d4be4:  b8 3c 41              loc_d4be4:           mov        ax, 413ch
d4be7:  8b 1e 0c 00                                mov        bx, [000ch]
d4beb:  8e c0                                      mov        es, ax
d4bed:  26 8a 87 c6 00                             mov        al, es:[bx+00c6h]
d4bf2:  50                                         push       ax
d4bf3:  a1 0c 00                                   mov        ax, [000ch]
d4bf6:  05 44 02                                   add        ax, 0244h
d4bf9:  68 40 50                                   push       5040h
d4bfc:  50                                         push       ax
d4bfd:  9a a9 04 00 d0                             call       display_load_resource_51refs
d4c02:  83 c4 06                                   add        word sp, 06h
d4c05:  ff 06 0c 00                                inc        word [000ch]

;  XREF: d4be2
d4c09:  a0 07 00              loc_d4c09:           mov        al, [0007h]
d4c0c:  98                                         cbw
d4c0d:  3b 06 0c 00                                cmp        ax, [000ch]
d4c11:  7d d1                                      jge        loc_d4be4
d4c13:  9a 37 38 f2 d2                             call       bumper_hit_handler
d4c18:  1f                                         pop        ds
d4c19:  cb                                         retf

;  XREF: d47d5

; -----------------------------------------------------------------------------
; credits_management (0xD4C1A)
; Credit insertion/deduction management
; -----------------------------------------------------------------------------
d4c1a:  1e                    credits_management:           push       ds
d4c1b:  b8 30 41                                   mov        ax, 4130h
d4c1e:  8e d8                                      mov        ds, ax
d4c20:  8b 1e 0e 00                                mov        bx, [000eh]
d4c24:  6b db 09                                   imul       bx, bx, 09h
d4c27:  b8 3c 41                                   mov        ax, 413ch
d4c2a:  8e c0                                      mov        es, ax
d4c2c:  26 ff b7 34 00                             push       word es:[bx+0034h]
d4c31:  26 ff b7 32 00                             push       word es:[bx+0032h]
d4c36:  68 40 50                                   push       5040h
d4c39:  68 58 02                                   push       0258h
d4c3c:  9a 6d 04 00 d0                             call       display_write_param_25refs
d4c41:  83 c4 08                                   add        word sp, 08h
d4c44:  8b 1e 0e 00                                mov        bx, [000eh]
d4c48:  6b db 09                                   imul       bx, bx, 09h
d4c4b:  b8 3c 41                                   mov        ax, 413ch
d4c4e:  8e c0                                      mov        es, ax
d4c50:  26 ff b7 34 00                             push       word es:[bx+0034h]
d4c55:  26 ff b7 32 00                             push       word es:[bx+0032h]
d4c5a:  68 3c 41                                   push       413ch
d4c5d:  68 e1 00                                   push       00e1h
d4c60:  9a 20 57 2a d7                             call       score_compare_and_cap
d4c65:  83 c4 08                                   add        word sp, 08h
d4c68:  68 3c 41                                   push       413ch
d4c6b:  68 e1 00                                   push       00e1h
d4c6e:  9a 3f 27 f2 d2                             call       switch_code_lookup
d4c73:  83 c4 04                                   add        word sp, 04h
d4c76:  c7 06 0c 00 00 00                          mov        word [000ch], 0000h
d4c7c:  eb 25                                      jmp short  loc_d4ca3

;  XREF: d4ca8
d4c7e:  b8 3c 41              loc_d4c7e:           mov        ax, 413ch
d4c81:  8b 1e 0c 00                                mov        bx, [000ch]
d4c85:  8e c0                                      mov        es, ax
d4c87:  26 8a 87 00 00                             mov        al, es:[bx]
d4c8c:  50                                         push       ax
d4c8d:  a1 0c 00                                   mov        ax, [000ch]
d4c90:  05 5c 02                                   add        ax, 025ch
d4c93:  68 40 50                                   push       5040h
d4c96:  50                                         push       ax
d4c97:  9a a9 04 00 d0                             call       display_load_resource_51refs
d4c9c:  83 c4 06                                   add        word sp, 06h
d4c9f:  ff 06 0c 00                                inc        word [000ch]

;  XREF: d4c7c
d4ca3:  83 3e 0c 00 0d        loc_d4ca3:           cmp        word [000ch], 0dh
d4ca8:  7c d4                                      jl         loc_d4c7e
d4caa:  b8 3c 41                                   mov        ax, 413ch
d4cad:  8e c0                                      mov        es, ax
d4caf:  26 a0 c6 00                                mov        al, es:[00c6h]
d4cb3:  a2 07 00                                   mov        [0007h], al
d4cb6:  c7 06 0c 00 00 00                          mov        word [000ch], 0000h
d4cbc:  eb 25                                      jmp short  loc_d4ce3

;  XREF: d4ceb
d4cbe:  b8 3c 41              loc_d4cbe:           mov        ax, 413ch
d4cc1:  8b 1e 0c 00                                mov        bx, [000ch]
d4cc5:  8e c0                                      mov        es, ax
d4cc7:  26 8a 87 c6 00                             mov        al, es:[bx+00c6h]
d4ccc:  50                                         push       ax
d4ccd:  a1 0c 00                                   mov        ax, [000ch]
d4cd0:  05 69 02                                   add        ax, 0269h
d4cd3:  68 40 50                                   push       5040h
d4cd6:  50                                         push       ax
d4cd7:  9a a9 04 00 d0                             call       display_load_resource_51refs
d4cdc:  83 c4 06                                   add        word sp, 06h
d4cdf:  ff 06 0c 00                                inc        word [000ch]

;  XREF: d4cbc
d4ce3:  a0 07 00              loc_d4ce3:           mov        al, [0007h]
d4ce6:  98                                         cbw
d4ce7:  3b 06 0c 00                                cmp        ax, [000ch]
d4ceb:  7d d1                                      jge        loc_d4cbe
d4ced:  9a 37 38 f2 d2                             call       bumper_hit_handler
d4cf2:  1f                                         pop        ds
d4cf3:  cb                                         retf

;  XREF: d47f2

; -----------------------------------------------------------------------------
; coin_handler (0xD4CF4)
; Coin acceptor event handler
; -----------------------------------------------------------------------------
d4cf4:  1e                    coin_handler:           push       ds
d4cf5:  b8 30 41                                   mov        ax, 4130h
d4cf8:  8e d8                                      mov        ds, ax
d4cfa:  b8 3c 41                                   mov        ax, 413ch
d4cfd:  8e c0                                      mov        es, ax
d4cff:  26 a0 16 00                                mov        al, es:[0016h]
d4d03:  b4 00                                      mov        ah, 00h
d4d05:  bb 0a 00                                   mov        bx, 000ah
d4d08:  99                                         cwd
d4d09:  f7 fb                                      idiv       word bx
d4d0b:  88 16 1f 00                                mov        [001fh], dl
d4d0f:  b8 3c 41                                   mov        ax, 413ch
d4d12:  8e c0                                      mov        es, ax
d4d14:  26 a0 1f 00                                mov        al, es:[001fh]
d4d18:  b4 00                                      mov        ah, 00h
d4d1a:  99                                         cwd
d4d1b:  f7 fb                                      idiv       word bx
d4d1d:  88 16 1e 00                                mov        [001eh], dl
d4d21:  b8 3c 41                                   mov        ax, 413ch
d4d24:  8e c0                                      mov        es, ax
d4d26:  26 a0 28 00                                mov        al, es:[0028h]
d4d2a:  b4 00                                      mov        ah, 00h
d4d2c:  99                                         cwd
d4d2d:  f7 fb                                      idiv       word bx
d4d2f:  88 16 1d 00                                mov        [001dh], dl
d4d33:  b8 3c 41                                   mov        ax, 413ch
d4d36:  8e c0                                      mov        es, ax
d4d38:  26 a0 31 00                                mov        al, es:[0031h]
d4d3c:  b4 00                                      mov        ah, 00h
d4d3e:  99                                         cwd
d4d3f:  f7 fb                                      idiv       word bx
d4d41:  88 16 1c 00                                mov        [001ch], dl
d4d45:  6a 09                                      push       09h
d4d47:  9a 70 0b 00 d0                             call       timer_delay
d4d4c:  59                                         pop        cx
d4d4d:  c6 06 1b 00 00                             mov        byte [001bh], 00h
d4d52:  b8 3c 41                                   mov        ax, 413ch
d4d55:  8e c0                                      mov        es, ax
d4d57:  26 a0 d7 00                                mov        al, es:[00d7h] ; game_flag_1 - General game flag 1
d4d5b:  b4 00                                      mov        ah, 00h
d4d5d:  48                                         dec        ax
d4d5e:  8b d8                                      mov        bx, ax
d4d60:  83 fb 03                                   cmp        word bx, 03h
d4d63:  76 03                                      jbe        loc_d4d68
d4d65:  e9 6a 02                                   jmp        loc_d4fd2

;  XREF: d4d63
d4d68:  d1 e3                 loc_d4d68:           shl        bx, 1
d4d6a:  2e ff a7 b4 20                             jmp        cs:[bx+20b4h]

;  XREF: d4d65
d4fd2:  1f                    loc_d4fd2:           pop        ds
d4fd3:  cb                                         retf

;  XREF: d2f3f

; -----------------------------------------------------------------------------
; game_state_update (0xD5133)
; Main game state update tick (called each frame from main loop)
; -----------------------------------------------------------------------------
d5133:  1e                    game_state_update:           push       ds
d5134:  b8 30 41                                   mov        ax, 4130h
d5137:  8e d8                                      mov        ds, ax
d5139:  b8 3c 41                                   mov        ax, 413ch
d513c:  8e c0                                      mov        es, ax
d513e:  26 c6 06 ea 00 05                          mov        byte es:[00eah], 05h
d5144:  b8 3c 41                                   mov        ax, 413ch
d5147:  8e c0                                      mov        es, ax
d5149:  26 c7 06 f2 00 00 00                       mov        word es:[00f2h], 0000h
d5150:  26 c7 06 f0 00 63 00                       mov        word es:[00f0h], 0063h
d5157:  8e c0                                      mov        es, ax
d5159:  26 ff 36 f2 00                             push       word es:[00f2h]
d515e:  26 ff 36 f0 00                             push       word es:[00f0h]
d5163:  68 3c 41                                   push       413ch
d5166:  68 e1 00                                   push       00e1h
d5169:  9a 20 57 2a d7                             call       score_compare_and_cap
d516e:  83 c4 08                                   add        word sp, 08h
d5171:  6a 00                                      push       00h
d5173:  68 3c 41                                   push       413ch
d5176:  68 e1 00                                   push       00e1h
d5179:  9a 07 09 00 f0                             call       dmd_frame_load
d517e:  83 c4 06                                   add        word sp, 06h
d5181:  9a cb 0c 00 f0                             call       dmd_resource_load
d5186:  b8 3c 41                                   mov        ax, 413ch
d5189:  8e c0                                      mov        es, ax
d518b:  26 c6 06 ff 00 01                          mov        byte es:[00ffh], 01h
d5191:  68 8a 01                                   push       018ah
d5194:  9a 3f 0d 00 f0                             call       dmd_scroll_engine
d5199:  59                                         pop        cx
d519a:  9a c0 0d 00 f0                             call       dmd_credits_scroll
d519f:  b8 3c 41                                   mov        ax, 413ch
d51a2:  8e c0                                      mov        es, ax
d51a4:  26 c6 06 fe 00 01                          mov        byte es:[00feh], 01h
d51aa:  68 81 01                                   push       0181h
d51ad:  9a 8e 10 00 f0                             call       cpu_peripheral_init
d51b2:  59                                         pop        cx
d51b3:  9a e5 10 00 f0                             call       interrupt_vector_setup
d51b8:  6a 01                                      push       01h
d51ba:  9a f5 0d 00 f0                             call       dmd_effect_flash
d51bf:  59                                         pop        cx
d51c0:  9a 96 0e 00 f0                             call       eeprom_read
d51c5:  68 b2 00                                   push       00b2h
d51c8:  9a 73 0f 00 f0                             call       eeprom_validate
d51cd:  59                                         pop        cx
d51ce:  9a de 0f 00 f0                             call       ram_test
d51d3:  6a 00                                      push       00h
d51d5:  9a 1a 11 00 f0                             call       interrupt_handler_timer
d51da:  59                                         pop        cx
d51db:  9a 3d 12 00 f0                             call       interrupt_handler_serial
d51e0:  9a f2 37 2a d7                             call       game_init_display
d51e5:  6a 0a                                      push       0ah
d51e7:  9a e8 26 f2 d2                             call       switch_read_shared_ram
d51ec:  59                                         pop        cx
d51ed:  1f                                         pop        ds
d51ee:  cb                                         retf

;  XREF: dc756

; -----------------------------------------------------------------------------
; game_end_sequence (0xD51EF)
; GAME END SEQUENCE: triggers match, transitions to attract. Contains timer at 4000:10E6 (1000 frames = 4.2s display)
; -----------------------------------------------------------------------------
d51ef:  1e                    game_end_sequence:           push       ds
d51f0:  b8 30 41                                   mov        ax, 4130h
d51f3:  8e d8                                      mov        ds, ax
d51f5:  b8 3c 41                                   mov        ax, 413ch
d51f8:  8e c0                                      mov        es, ax
d51fa:  26 c6 06 ea 00 03                          mov        byte es:[00eah], 03h
d5200:  c7 06 0e 00 00 00                          mov        word [000eh], 0000h
d5206:  e9 ab 00                                   jmp        loc_d52b4

;  XREF: d52c5
d5209:  8b 1e 0e 00           loc_d5209:           mov        bx, [000eh]
d520d:  6b db 09                                   imul       bx, bx, 09h
d5210:  b8 3c 41                                   mov        ax, 413ch
d5213:  8e c0                                      mov        es, ax
d5215:  26 ff b7 34 00                             push       word es:[bx+0034h]
d521a:  26 ff b7 32 00                             push       word es:[bx+0032h]
d521f:  a1 0e 00                                   mov        ax, [000eh]
d5222:  6b c0 09                                   imul       ax, ax, 09h
d5225:  05 0e 00                                   add        ax, 000eh
d5228:  68 3c 41                                   push       413ch
d522b:  50                                         push       ax
d522c:  9a 20 57 2a d7                             call       score_compare_and_cap
d5231:  83 c4 08                                   add        word sp, 08h
d5234:  83 3e 0e 00 02                             cmp        word [000eh], 02h
d5239:  7d 2b                                      jge        loc_d5266
d523b:  c6 06 09 00 01                             mov        byte [0009h], 01h
d5240:  a0 0e 00                                   mov        al, [000eh]
d5243:  fe c0                                      inc        byte al
d5245:  a2 0a 00                                   mov        [000ah], al
d5248:  1e                                         push       ds
d5249:  68 09 00                                   push       0009h
d524c:  a1 0e 00                                   mov        ax, [000eh]
d524f:  6b c0 09                                   imul       ax, ax, 09h
d5252:  50                                         push       ax
d5253:  6a 01                                      push       01h
d5255:  9a 01 07 00 f0                             call       dmd_text_render
d525a:  83 c4 08                                   add        word sp, 08h
d525d:  a1 0e 00                                   mov        ax, [000eh]
d5260:  6b c0 09                                   imul       ax, ax, 09h
d5263:  40                                         inc        ax
d5264:  eb 34                                      jmp short  loc_d529a

;  XREF: d5239
d5266:  c6 06 09 00 01        loc_d5266:           mov        byte [0009h], 01h
d526b:  a0 0e 00                                   mov        al, [000eh]
d526e:  fe c0                                      inc        byte al
d5270:  a2 0a 00                                   mov        [000ah], al
d5273:  1e                                         push       ds
d5274:  68 09 00                                   push       0009h
d5277:  a1 0e 00                                   mov        ax, [000eh]
d527a:  05 fe ff                                   add        ax, fffeh
d527d:  6b c0 09                                   imul       ax, ax, 09h
d5280:  05 b0 00                                   add        ax, 00b0h
d5283:  50                                         push       ax
d5284:  6a 01                                      push       01h
d5286:  9a 01 07 00 f0                             call       dmd_text_render
d528b:  83 c4 08                                   add        word sp, 08h
d528e:  a1 0e 00                                   mov        ax, [000eh]
d5291:  05 fe ff                                   add        ax, fffeh
d5294:  6b c0 09                                   imul       ax, ax, 09h
d5297:  05 b1 00                                   add        ax, 00b1h

;  XREF: d5264
d529a:  50                    loc_d529a:           push       ax
d529b:  a1 0e 00                                   mov        ax, [000eh]
d529e:  6b c0 09                                   imul       ax, ax, 09h
d52a1:  05 0e 00                                   add        ax, 000eh
d52a4:  68 3c 41                                   push       413ch
d52a7:  50                                         push       ax
d52a8:  9a 07 09 00 f0                             call       dmd_frame_load
d52ad:  83 c4 06                                   add        word sp, 06h
d52b0:  ff 06 0e 00                                inc        word [000eh]

;  XREF: d5206
d52b4:  b8 3c 41              loc_d52b4:           mov        ax, 413ch
d52b7:  8e c0                                      mov        es, ax
d52b9:  26 a0 d7 00                                mov        al, es:[00d7h] ; game_flag_1 - General game flag 1
d52bd:  b4 00                                      mov        ah, 00h
d52bf:  3b 06 0e 00                                cmp        ax, [000eh]
d52c3:  7e 03                                      jle        loc_d52c8
d52c5:  e9 41 ff                                   jmp        loc_d5209

;  XREF: d52c3
d52c8:  b8 3c 41              loc_d52c8:           mov        ax, 413ch
d52cb:  8e c0                                      mov        es, ax
d52cd:  26 c6 06 ea 00 01                          mov        byte es:[00eah], 01h
d52d3:  1f                                         pop        ds
d52d4:  cb                                         retf

;  XREF: d6251, d65c8, d65fb

; -----------------------------------------------------------------------------
; switch_event_dispatch (0xD536C)
; Dispatch switch events to appropriate handlers (3 refs)
; -----------------------------------------------------------------------------
d536c:  1e                    switch_event_dispatch:           push       ds
d536d:  b8 30 41                                   mov        ax, 4130h
d5370:  8e d8                                      mov        ds, ax
d5372:  9a f2 37 2a d7                             call       game_init_display
d5377:  b8 3c 41                                   mov        ax, 413ch
d537a:  8e c0                                      mov        es, ax
d537c:  26 c4 1e b2 00                             les        bx, es:[00b2h]
d5381:  26 ff 77 52                                push       word es:[bx+52h]
d5385:  26 ff 77 50                                push       word es:[bx+50h]
d5389:  8e c0                                      mov        es, ax
d538b:  26 8e 06 b4 00                             mov        es, es:[00b4h]
d5390:  26 ff 77 4e                                push       word es:[bx+4eh]
d5394:  6a 01                                      push       01h
d5396:  9a 01 07 00 f0                             call       dmd_text_render
d539b:  83 c4 08                                   add        word sp, 08h
d539e:  b8 3c 41                                   mov        ax, 413ch
d53a1:  8e c0                                      mov        es, ax
d53a3:  26 c4 1e b2 00                             les        bx, es:[00b2h]
d53a8:  26 ff 77 2e                                push       word es:[bx+2eh]
d53ac:  26 ff 77 2c                                push       word es:[bx+2ch]
d53b0:  8e c0                                      mov        es, ax
d53b2:  26 8e 06 b4 00                             mov        es, es:[00b4h]
d53b7:  26 ff 77 2a                                push       word es:[bx+2ah]
d53bb:  6a 01                                      push       01h
d53bd:  9a 01 07 00 f0                             call       dmd_text_render
d53c2:  83 c4 08                                   add        word sp, 08h
d53c5:  33 c0                                      xor        ax, ax
d53c7:  1f                                         pop        ds
d53c8:  cb                                         retf

;  XREF: d623f

; -----------------------------------------------------------------------------
; target_hit_handler (0xD53C9)
; Handle target hit events (drop targets, standup targets)
; -----------------------------------------------------------------------------
d53c9:  1e                    target_hit_handler:           push       ds
d53ca:  b8 30 41                                   mov        ax, 4130h
d53cd:  8e d8                                      mov        ds, ax
d53cf:  9a f2 37 2a d7                             call       game_init_display
d53d4:  b8 3c 41                                   mov        ax, 413ch
d53d7:  8e c0                                      mov        es, ax
d53d9:  26 c4 1e b2 00                             les        bx, es:[00b2h]
d53de:  26 ff 77 34                                push       word es:[bx+34h]
d53e2:  26 ff 77 32                                push       word es:[bx+32h]
d53e6:  8e c0                                      mov        es, ax
d53e8:  26 8e 06 b4 00                             mov        es, es:[00b4h]
d53ed:  26 ff 77 30                                push       word es:[bx+30h]
d53f1:  6a 01                                      push       01h
d53f3:  9a 01 07 00 f0                             call       dmd_text_render
d53f8:  83 c4 08                                   add        word sp, 08h
d53fb:  b8 3c 41                                   mov        ax, 413ch
d53fe:  8e c0                                      mov        es, ax
d5400:  26 c4 1e b2 00                             les        bx, es:[00b2h]
d5405:  26 ff 77 3a                                push       word es:[bx+3ah]
d5409:  26 ff 77 38                                push       word es:[bx+38h]
d540d:  8e c0                                      mov        es, ax
d540f:  26 8e 06 b4 00                             mov        es, es:[00b4h]
d5414:  26 ff 77 36                                push       word es:[bx+36h]
d5418:  6a 01                                      push       01h
d541a:  9a 01 07 00 f0                             call       dmd_text_render
d541f:  83 c4 08                                   add        word sp, 08h
d5422:  b8 3c 41                                   mov        ax, 413ch
d5425:  8e c0                                      mov        es, ax
d5427:  26 c4 1e b2 00                             les        bx, es:[00b2h]
d542c:  26 ff 77 40                                push       word es:[bx+40h]
d5430:  26 ff 77 3e                                push       word es:[bx+3eh]
d5434:  8e c0                                      mov        es, ax
d5436:  26 8e 06 b4 00                             mov        es, es:[00b4h]
d543b:  26 ff 77 3c                                push       word es:[bx+3ch]
d543f:  6a 01                                      push       01h
d5441:  9a 01 07 00 f0                             call       dmd_text_render
d5446:  83 c4 08                                   add        word sp, 08h

;  XREF: d5450
d5449:  9a cb 2b f2 d2        loc_d5449:           call       lamp_set
d544e:  0a c0                                      or         al, al
d5450:  74 f7                                      jz         loc_d5449
d5452:  6a 40                                      push       40h
d5454:  9a 0a 00 2a d7                             call       dmd_anim_play
d5459:  59                                         pop        cx
d545a:  9a c4 00 00 f0                             call       dmd_buffer_swap
d545f:  9a f1 00 00 f0                             call       dmd_buffer_clear
d5464:  33 c0                                      xor        ax, ax
d5466:  1f                                         pop        ds
d5467:  cb                                         retf

;  XREF: d2faf

; -----------------------------------------------------------------------------
; drop_target_bank_handler (0xD5468)
; Handle drop target bank completion
; -----------------------------------------------------------------------------
d5468:  1e                    drop_target_bank_handler:           push       ds
d5469:  b8 30 41                                   mov        ax, 4130h
d546c:  8e d8                                      mov        ds, ax
d546e:  9a f2 37 2a d7                             call       game_init_display
d5473:  b8 3c 41                                   mov        ax, 413ch
d5476:  8e c0                                      mov        es, ax
d5478:  26 c4 1e b2 00                             les        bx, es:[00b2h]
d547d:  26 ff b7 f4 00                             push       word es:[bx+00f4h]
d5482:  26 ff b7 f2 00                             push       word es:[bx+00f2h]
d5487:  8e c0                                      mov        es, ax
d5489:  26 8e 06 b4 00                             mov        es, es:[00b4h]
d548e:  26 ff b7 f0 00                             push       word es:[bx+00f0h]
d5493:  6a 01                                      push       01h
d5495:  9a 01 07 00 f0                             call       dmd_text_render
d549a:  83 c4 08                                   add        word sp, 08h
d549d:  b8 3c 41                                   mov        ax, 413ch
d54a0:  8e c0                                      mov        es, ax
d54a2:  26 c4 1e b2 00                             les        bx, es:[00b2h]
d54a7:  26 ff b7 fa 00                             push       word es:[bx+00fah]
d54ac:  26 ff b7 f8 00                             push       word es:[bx+00f8h]
d54b1:  8e c0                                      mov        es, ax
d54b3:  26 8e 06 b4 00                             mov        es, es:[00b4h]
d54b8:  26 ff b7 f6 00                             push       word es:[bx+00f6h]
d54bd:  6a 01                                      push       01h
d54bf:  9a 01 07 00 f0                             call       dmd_text_render
d54c4:  83 c4 08                                   add        word sp, 08h

;  XREF: d54ce
d54c7:  9a 3d 2c f2 d2        loc_d54c7:           call       lamp_flash
d54cc:  0a c0                                      or         al, al
d54ce:  74 f7                                      jz         loc_d54c7
d54d0:  6a 3f                                      push       3fh
d54d2:  9a 0a 00 2a d7                             call       dmd_anim_play
d54d7:  59                                         pop        cx
d54d8:  9a c4 00 00 f0                             call       dmd_buffer_swap
d54dd:  9a f1 00 00 f0                             call       dmd_buffer_clear
d54e2:  33 c0                                      xor        ax, ax
d54e4:  1f                                         pop        ds
d54e5:  cb                                         retf

;  XREF: d5a84, d5aca

; -----------------------------------------------------------------------------
; lane_completion_handler (0xD54E6)
; Handle lane completion events (ORBITS spelling). 2 refs
; -----------------------------------------------------------------------------
d54e6:  1e                    lane_completion_handler:           push       ds
d54e7:  b8 30 41                                   mov        ax, 4130h
d54ea:  8e d8                                      mov        ds, ax
d54ec:  9a f2 37 2a d7                             call       game_init_display
d54f1:  b8 3c 41                                   mov        ax, 413ch
d54f4:  8e c0                                      mov        es, ax
d54f6:  26 c4 1e b2 00                             les        bx, es:[00b2h]
d54fb:  26 ff 77 52                                push       word es:[bx+52h]
d54ff:  26 ff 77 50                                push       word es:[bx+50h]
d5503:  8e c0                                      mov        es, ax
d5505:  26 8e 06 b4 00                             mov        es, es:[00b4h]
d550a:  26 ff 77 4e                                push       word es:[bx+4eh]
d550e:  6a 01                                      push       01h
d5510:  9a 01 07 00 f0                             call       dmd_text_render
d5515:  83 c4 08                                   add        word sp, 08h
d5518:  b8 3c 41                                   mov        ax, 413ch
d551b:  8e c0                                      mov        es, ax
d551d:  26 c4 1e b2 00                             les        bx, es:[00b2h]
d5522:  26 ff 77 58                                push       word es:[bx+58h]
d5526:  26 ff 77 56                                push       word es:[bx+56h]
d552a:  8e c0                                      mov        es, ax
d552c:  26 8e 06 b4 00                             mov        es, es:[00b4h]
d5531:  26 ff 77 54                                push       word es:[bx+54h]
d5535:  6a 01                                      push       01h
d5537:  9a 01 07 00 f0                             call       dmd_text_render
d553c:  83 c4 08                                   add        word sp, 08h
d553f:  33 c0                                      xor        ax, ax
d5541:  1f                                         pop        ds
d5542:  cb                                         retf

;  XREF: d6679

; -----------------------------------------------------------------------------
; ramp_shot_handler (0xD5543)
; Handle ramp shot events (scoring, combos)
; -----------------------------------------------------------------------------
d5543:  1e                    ramp_shot_handler:           push       ds
d5544:  b8 30 41                                   mov        ax, 4130h
d5547:  8e d8                                      mov        ds, ax
d5549:  9a f2 37 2a d7                             call       game_init_display
d554e:  b8 3c 41                                   mov        ax, 413ch
d5551:  8e c0                                      mov        es, ax
d5553:  26 c4 1e b2 00                             les        bx, es:[00b2h]
d5558:  26 ff b7 00 01                             push       word es:[bx+0100h]
d555d:  26 ff b7 fe 00                             push       word es:[bx+00feh]
d5562:  8e c0                                      mov        es, ax
d5564:  26 8e 06 b4 00                             mov        es, es:[00b4h]
d5569:  26 ff b7 fc 00                             push       word es:[bx+00fch]
d556e:  6a 01                                      push       01h
d5570:  9a 01 07 00 f0                             call       dmd_text_render
d5575:  83 c4 08                                   add        word sp, 08h
d5578:  b8 3c 41                                   mov        ax, 413ch
d557b:  8e c0                                      mov        es, ax
d557d:  26 c4 1e b2 00                             les        bx, es:[00b2h]
d5582:  26 ff b7 06 01                             push       word es:[bx+0106h]
d5587:  26 ff b7 04 01                             push       word es:[bx+0104h]
d558c:  8e c0                                      mov        es, ax
d558e:  26 8e 06 b4 00                             mov        es, es:[00b4h]
d5593:  26 ff b7 02 01                             push       word es:[bx+0102h]
d5598:  6a 01                                      push       01h
d559a:  9a 01 07 00 f0                             call       dmd_text_render
d559f:  83 c4 08                                   add        word sp, 08h
d55a2:  68 c8 00                                   push       00c8h
d55a5:  9a e8 26 f2 d2                             call       switch_read_shared_ram
d55aa:  59                                         pop        cx
d55ab:  1f                                         pop        ds
d55ac:  cb                                         retf

;  XREF: d2f54

; -----------------------------------------------------------------------------
; input_poll_init (0xD55AD)
; Initialize input polling state
; -----------------------------------------------------------------------------
d55ad:  1e                    input_poll_init:           push       ds
d55ae:  b8 30 41                                   mov        ax, 4130h
d55b1:  8e d8                                      mov        ds, ax
d55b3:  9a f2 37 2a d7                             call       game_init_display
d55b8:  b8 3c 41                                   mov        ax, 413ch
d55bb:  8e c0                                      mov        es, ax
d55bd:  26 c4 1e b2 00                             les        bx, es:[00b2h]
d55c2:  26 ff 77 64                                push       word es:[bx+64h]
d55c6:  26 ff 77 62                                push       word es:[bx+62h]
d55ca:  8e c0                                      mov        es, ax
d55cc:  26 8e 06 b4 00                             mov        es, es:[00b4h]
d55d1:  26 ff 77 60                                push       word es:[bx+60h]
d55d5:  6a 01                                      push       01h
d55d7:  9a 01 07 00 f0                             call       dmd_text_render
d55dc:  83 c4 08                                   add        word sp, 08h
d55df:  b8 3c 41                                   mov        ax, 413ch
d55e2:  8e c0                                      mov        es, ax
d55e4:  26 c4 1e b2 00                             les        bx, es:[00b2h]
d55e9:  26 ff 77 6a                                push       word es:[bx+6ah]
d55ed:  26 ff 77 68                                push       word es:[bx+68h]
d55f1:  8e c0                                      mov        es, ax
d55f3:  26 8e 06 b4 00                             mov        es, es:[00b4h]
d55f8:  26 ff 77 66                                push       word es:[bx+66h]
d55fc:  6a 01                                      push       01h
d55fe:  9a 01 07 00 f0                             call       dmd_text_render
d5603:  83 c4 08                                   add        word sp, 08h
d5606:  1f                                         pop        ds
d5607:  cb                                         retf

;  XREF: d3744, d3d41, d3d7f, d3dd2, d3e1e (+32 more)

; -----------------------------------------------------------------------------
; switch_read_shared_ram (0xD5608)
; Read switch state from Z80 shared RAM (37 refs) - most used I/O function
; -----------------------------------------------------------------------------
d5608:  55                    switch_read_shared_ram:           push       bp
d5609:  8b ec                                      mov        bp, sp
d560b:  1e                                         push       ds
d560c:  b8 30 41                                   mov        ax, 4130h
d560f:  8e d8                                      mov        ds, ax
d5611:  8b 46 06                                   mov        ax, [bp+06h]
d5614:  d1 e0                                      shl        ax, 1
d5616:  ba 00 40                                   mov        dx, 4000h
d5619:  8e c2                                      mov        es, dx
d561b:  26 a3 39 11                                mov        es:[1139h], ax

;  XREF: d562a
d561f:  b8 00 40              loc_d561f:           mov        ax, 4000h
d5622:  8e c0                                      mov        es, ax
d5624:  26 83 3e 39 11 00                          cmp        word es:[1139h], 00h
d562a:  75 f3                                      jnz        loc_d561f
d562c:  1f                                         pop        ds
d562d:  5d                                         pop        bp
d562e:  cb                                         retf

;  XREF: daae0

; -----------------------------------------------------------------------------
; switch_debounce (0xD562F)
; Switch debounce/validation
; -----------------------------------------------------------------------------
d562f:  55                    switch_debounce:           push       bp
d5630:  8b ec                                      mov        bp, sp
d5632:  1e                                         push       ds
d5633:  b8 30 41                                   mov        ax, 4130h
d5636:  8e d8                                      mov        ds, ax
d5638:  8b 46 06                                   mov        ax, [bp+06h]
d563b:  d1 e0                                      shl        ax, 1
d563d:  ba 00 40                                   mov        dx, 4000h
d5640:  8e c2                                      mov        es, dx
d5642:  26 a3 39 11                                mov        es:[1139h], ax

;  XREF: d565a
d5646:  b8 00 40              loc_d5646:           mov        ax, 4000h
d5649:  8e c0                                      mov        es, ax
d564b:  26 83 3e 39 11 00                          cmp        word es:[1139h], 00h
d5651:  74 09                                      jz         loc_d565c
d5653:  9a 8b 09 2a d7                             call       switch_dispatch_table_lookup
d5658:  0b c0                                      or         ax, ax
d565a:  74 ea                                      jz         loc_d5646

;  XREF: d5651
d565c:  1f                    loc_d565c:           pop        ds
d565d:  5d                                         pop        bp
d565e:  cb                                         retf

;  XREF: d492e, d4b10, d4c6e, d5754, d57b3 (+8 more)

; -----------------------------------------------------------------------------
; switch_code_lookup (0xD565F)
; Look up switch code in handler table (13 refs)
; -----------------------------------------------------------------------------
d565f:  55                    switch_code_lookup:           push       bp
d5660:  8b ec                                      mov        bp, sp
d5662:  1e                                         push       ds
d5663:  b8 30 41                                   mov        ax, 4130h
d5666:  8e d8                                      mov        ds, ax
d5668:  c6 06 08 00 00                             mov        byte [0008h], 00h
d566d:  b8 3c 41                                   mov        ax, 413ch
d5670:  8e c0                                      mov        es, ax
d5672:  26 c6 06 00 00 0d                          mov        byte es:[0000h], 0dh
d5678:  c6 06 08 00 00                             mov        byte [0008h], 00h
d567d:  eb 20                                      jmp short  loc_d569f

;  XREF: d56a4
d567f:  a0 08 00              loc_d567f:           mov        al, [0008h]
d5682:  98                                         cbw
d5683:  ba 3c 41                                   mov        dx, 413ch
d5686:  50                                         push       ax
d5687:  a0 08 00                                   mov        al, [0008h]
d568a:  98                                         cbw
d568b:  c4 5e 06                                   les        bx, [bp+06h]
d568e:  03 d8                                      add        bx, ax
d5690:  26 8a 07                                   mov        al, es:[bx]
d5693:  8e c2                                      mov        es, dx
d5695:  5b                                         pop        bx
d5696:  26 88 87 01 00                             mov        es:[bx+0001h], al
d569b:  fe 06 08 00                                inc        byte [0008h]

;  XREF: d567d
d569f:  80 3e 08 00 03        loc_d569f:           cmp        byte [0008h], 03h
d56a4:  7c d9                                      jl         loc_d567f
d56a6:  b8 3c 41                                   mov        ax, 413ch
d56a9:  8e c0                                      mov        es, ax
d56ab:  26 c6 06 04 00 2c                          mov        byte es:[0004h], 2ch
d56b1:  c6 06 08 00 03                             mov        byte [0008h], 03h
d56b6:  eb 20                                      jmp short  loc_d56d8

;  XREF: d56dd
d56b8:  a0 08 00              loc_d56b8:           mov        al, [0008h]
d56bb:  98                                         cbw
d56bc:  ba 3c 41                                   mov        dx, 413ch
d56bf:  50                                         push       ax
d56c0:  a0 08 00                                   mov        al, [0008h]
d56c3:  98                                         cbw
d56c4:  c4 5e 06                                   les        bx, [bp+06h]
d56c7:  03 d8                                      add        bx, ax
d56c9:  26 8a 07                                   mov        al, es:[bx]
d56cc:  8e c2                                      mov        es, dx
d56ce:  5b                                         pop        bx
d56cf:  26 88 87 02 00                             mov        es:[bx+0002h], al
d56d4:  fe 06 08 00                                inc        byte [0008h]

;  XREF: d56b6
d56d8:  80 3e 08 00 06        loc_d56d8:           cmp        byte [0008h], 06h
d56dd:  7c d9                                      jl         loc_d56b8
d56df:  b8 3c 41                                   mov        ax, 413ch
d56e2:  8e c0                                      mov        es, ax
d56e4:  26 c6 06 08 00 2c                          mov        byte es:[0008h], 2ch
d56ea:  c6 06 08 00 06                             mov        byte [0008h], 06h
d56ef:  eb 20                                      jmp short  loc_d5711

;  XREF: d5716
d56f1:  a0 08 00              loc_d56f1:           mov        al, [0008h]
d56f4:  98                                         cbw
d56f5:  ba 3c 41                                   mov        dx, 413ch
d56f8:  50                                         push       ax
d56f9:  a0 08 00                                   mov        al, [0008h]
d56fc:  98                                         cbw
d56fd:  c4 5e 06                                   les        bx, [bp+06h]
d5700:  03 d8                                      add        bx, ax
d5702:  26 8a 07                                   mov        al, es:[bx]
d5705:  8e c2                                      mov        es, dx
d5707:  5b                                         pop        bx
d5708:  26 88 87 03 00                             mov        es:[bx+0003h], al
d570d:  fe 06 08 00                                inc        byte [0008h]

;  XREF: d56ef
d5711:  80 3e 08 00 09        loc_d5711:           cmp        byte [0008h], 09h
d5716:  7c d9                                      jl         loc_d56f1
d5718:  b8 3c 41                                   mov        ax, 413ch
d571b:  8e c0                                      mov        es, ax
d571d:  26 c6 06 0c 00 0a                          mov        byte es:[000ch], 0ah
d5723:  b8 01 00                                   mov        ax, 0001h
d5726:  1f                                         pop        ds
d5727:  5d                                         pop        bp
d5728:  cb                                         retf

;  XREF: d5a01, dd299

; -----------------------------------------------------------------------------
; flipper_button_handler (0xD5729)
; Handle flipper button press/release events (2 refs)
; -----------------------------------------------------------------------------
d5729:  1e                    flipper_button_handler:           push       ds
d572a:  b8 30 41                                   mov        ax, 4130h
d572d:  8e d8                                      mov        ds, ax
d572f:  68 40 50                                   push       5040h
d5732:  68 85 00                                   push       0085h
d5735:  9a 92 04 00 d0                             call       display_set_animation_29refs
d573a:  83 c4 04                                   add        word sp, 04h
d573d:  52                                         push       dx
d573e:  50                                         push       ax
d573f:  68 3c 41                                   push       413ch
d5742:  68 e1 00                                   push       00e1h
d5745:  9a 20 57 2a d7                             call       score_compare_and_cap
d574a:  83 c4 08                                   add        word sp, 08h
d574d:  68 3c 41                                   push       413ch
d5750:  68 e1 00                                   push       00e1h
d5753:  0e                                         push       cs
d5754:  e8 08 ff                                   call       switch_code_lookup
d5757:  83 c4 04                                   add        word sp, 04h
d575a:  c7 06 0c 00 00 00                          mov        word [000ch], 0000h
d5760:  eb 25                                      jmp short  loc_d5787

;  XREF: d578c
d5762:  b8 3c 41              loc_d5762:           mov        ax, 413ch
d5765:  8b 1e 0c 00                                mov        bx, [000ch]
d5769:  8e c0                                      mov        es, ax
d576b:  26 8a 87 00 00                             mov        al, es:[bx]
d5770:  50                                         push       ax
d5771:  a1 0c 00                                   mov        ax, [000ch]
d5774:  05 89 00                                   add        ax, 0089h
d5777:  68 40 50                                   push       5040h
d577a:  50                                         push       ax
d577b:  9a a9 04 00 d0                             call       display_load_resource_51refs
d5780:  83 c4 06                                   add        word sp, 06h
d5783:  ff 06 0c 00                                inc        word [000ch]

;  XREF: d5760
d5787:  83 3e 0c 00 0d        loc_d5787:           cmp        word [000ch], 0dh
d578c:  7c d4                                      jl         loc_d5762
d578e:  68 40 50                                   push       5040h
d5791:  68 96 00                                   push       0096h
d5794:  9a 92 04 00 d0                             call       display_set_animation_29refs
d5799:  83 c4 04                                   add        word sp, 04h
d579c:  52                                         push       dx
d579d:  50                                         push       ax
d579e:  68 3c 41                                   push       413ch
d57a1:  68 e1 00                                   push       00e1h
d57a4:  9a 20 57 2a d7                             call       score_compare_and_cap
d57a9:  83 c4 08                                   add        word sp, 08h
d57ac:  68 3c 41                                   push       413ch
d57af:  68 e1 00                                   push       00e1h
d57b2:  0e                                         push       cs
d57b3:  e8 a9 fe                                   call       switch_code_lookup
d57b6:  83 c4 04                                   add        word sp, 04h
d57b9:  c7 06 0c 00 00 00                          mov        word [000ch], 0000h
d57bf:  eb 25                                      jmp short  loc_d57e6

;  XREF: d57eb
d57c1:  b8 3c 41              loc_d57c1:           mov        ax, 413ch
d57c4:  8b 1e 0c 00                                mov        bx, [000ch]
d57c8:  8e c0                                      mov        es, ax
d57ca:  26 8a 87 00 00                             mov        al, es:[bx]
d57cf:  50                                         push       ax
d57d0:  a1 0c 00                                   mov        ax, [000ch]
d57d3:  05 9a 00                                   add        ax, 009ah
d57d6:  68 40 50                                   push       5040h
d57d9:  50                                         push       ax
d57da:  9a a9 04 00 d0                             call       display_load_resource_51refs
d57df:  83 c4 06                                   add        word sp, 06h
d57e2:  ff 06 0c 00                                inc        word [000ch]

;  XREF: d57bf
d57e6:  83 3e 0c 00 0d        loc_d57e6:           cmp        word [000ch], 0dh
d57eb:  7c d4                                      jl         loc_d57c1
d57ed:  68 40 50                                   push       5040h
d57f0:  68 b8 00                                   push       00b8h
d57f3:  9a 92 04 00 d0                             call       display_set_animation_29refs
d57f8:  83 c4 04                                   add        word sp, 04h
d57fb:  52                                         push       dx
d57fc:  50                                         push       ax
d57fd:  68 3c 41                                   push       413ch
d5800:  68 e1 00                                   push       00e1h
d5803:  9a 20 57 2a d7                             call       score_compare_and_cap
d5808:  83 c4 08                                   add        word sp, 08h
d580b:  68 3c 41                                   push       413ch
d580e:  68 e1 00                                   push       00e1h
d5811:  0e                                         push       cs
d5812:  e8 4a fe                                   call       switch_code_lookup
d5815:  83 c4 04                                   add        word sp, 04h
d5818:  c7 06 0c 00 00 00                          mov        word [000ch], 0000h
d581e:  eb 25                                      jmp short  loc_d5845

;  XREF: d584a
d5820:  b8 3c 41              loc_d5820:           mov        ax, 413ch
d5823:  8b 1e 0c 00                                mov        bx, [000ch]
d5827:  8e c0                                      mov        es, ax
d5829:  26 8a 87 00 00                             mov        al, es:[bx]
d582e:  50                                         push       ax
d582f:  a1 0c 00                                   mov        ax, [000ch]
d5832:  05 bc 00                                   add        ax, 00bch
d5835:  68 40 50                                   push       5040h
d5838:  50                                         push       ax
d5839:  9a a9 04 00 d0                             call       display_load_resource_51refs
d583e:  83 c4 06                                   add        word sp, 06h
d5841:  ff 06 0c 00                                inc        word [000ch]

;  XREF: d581e
d5845:  83 3e 0c 00 0d        loc_d5845:           cmp        word [000ch], 0dh
d584a:  7c d4                                      jl         loc_d5820
d584c:  68 40 50                                   push       5040h
d584f:  68 a7 00                                   push       00a7h
d5852:  9a 92 04 00 d0                             call       display_set_animation_29refs
d5857:  83 c4 04                                   add        word sp, 04h
d585a:  52                                         push       dx
d585b:  50                                         push       ax
d585c:  68 3c 41                                   push       413ch
d585f:  68 e1 00                                   push       00e1h
d5862:  9a 20 57 2a d7                             call       score_compare_and_cap
d5867:  83 c4 08                                   add        word sp, 08h
d586a:  68 3c 41                                   push       413ch
d586d:  68 e1 00                                   push       00e1h
d5870:  0e                                         push       cs
d5871:  e8 eb fd                                   call       switch_code_lookup
d5874:  83 c4 04                                   add        word sp, 04h
d5877:  c7 06 0c 00 00 00                          mov        word [000ch], 0000h
d587d:  eb 25                                      jmp short  loc_d58a4

;  XREF: d58a9
d587f:  b8 3c 41              loc_d587f:           mov        ax, 413ch
d5882:  8b 1e 0c 00                                mov        bx, [000ch]
d5886:  8e c0                                      mov        es, ax
d5888:  26 8a 87 00 00                             mov        al, es:[bx]
d588d:  50                                         push       ax
d588e:  a1 0c 00                                   mov        ax, [000ch]
d5891:  05 ab 00                                   add        ax, 00abh
d5894:  68 40 50                                   push       5040h
d5897:  50                                         push       ax
d5898:  9a a9 04 00 d0                             call       display_load_resource_51refs
d589d:  83 c4 06                                   add        word sp, 06h
d58a0:  ff 06 0c 00                                inc        word [000ch]

;  XREF: d587d
d58a4:  83 3e 0c 00 0d        loc_d58a4:           cmp        word [000ch], 0dh
d58a9:  7c d4                                      jl         loc_d587f
d58ab:  68 40 50                                   push       5040h
d58ae:  68 c9 00                                   push       00c9h
d58b1:  9a 92 04 00 d0                             call       display_set_animation_29refs
d58b6:  83 c4 04                                   add        word sp, 04h
d58b9:  52                                         push       dx
d58ba:  50                                         push       ax
d58bb:  68 3c 41                                   push       413ch
d58be:  68 e1 00                                   push       00e1h
d58c1:  9a 20 57 2a d7                             call       score_compare_and_cap
d58c6:  83 c4 08                                   add        word sp, 08h
d58c9:  68 3c 41                                   push       413ch
d58cc:  68 e1 00                                   push       00e1h
d58cf:  0e                                         push       cs
d58d0:  e8 8c fd                                   call       switch_code_lookup
d58d3:  83 c4 04                                   add        word sp, 04h
d58d6:  c7 06 0c 00 00 00                          mov        word [000ch], 0000h
d58dc:  eb 25                                      jmp short  loc_d5903

;  XREF: d5908
d58de:  b8 3c 41              loc_d58de:           mov        ax, 413ch
d58e1:  8b 1e 0c 00                                mov        bx, [000ch]
d58e5:  8e c0                                      mov        es, ax
d58e7:  26 8a 87 00 00                             mov        al, es:[bx]
d58ec:  50                                         push       ax
d58ed:  a1 0c 00                                   mov        ax, [000ch]
d58f0:  05 cd 00                                   add        ax, 00cdh
d58f3:  68 40 50                                   push       5040h
d58f6:  50                                         push       ax
d58f7:  9a a9 04 00 d0                             call       display_load_resource_51refs
d58fc:  83 c4 06                                   add        word sp, 06h
d58ff:  ff 06 0c 00                                inc        word [000ch]

;  XREF: d58dc
d5903:  83 3e 0c 00 0d        loc_d5903:           cmp        word [000ch], 0dh
d5908:  7c d4                                      jl         loc_d58de
d590a:  9a 37 38 f2 d2                             call       bumper_hit_handler
d590f:  1f                                         pop        ds
d5910:  cb                                         retf

;  XREF: d4862

; -----------------------------------------------------------------------------
; start_button_handler (0xD5911)
; Handle START button press
; -----------------------------------------------------------------------------
d5911:  1e                    start_button_handler:           push       ds
d5912:  b8 30 41                                   mov        ax, 4130h
d5915:  8e d8                                      mov        ds, ax
d5917:  83 3e 18 00 00                             cmp        word [0018h], 00h
d591c:  75 17                                      jnz        loc_d5935
d591e:  83 3e 16 00 01                             cmp        word [0016h], 01h
d5923:  75 10                                      jnz        loc_d5935
d5925:  68 40 50                                   push       5040h
d5928:  68 96 00                                   push       0096h
d592b:  9a 92 04 00 d0                             call       display_set_animation_29refs
d5930:  83 c4 04                                   add        word sp, 04h
d5933:  eb 30                                      jmp short  loc_d5965

;  XREF: d591c, d5923
d5935:  68 40 50              loc_d5935:           push       5040h
d5938:  68 a7 00                                   push       00a7h
d593b:  9a 92 04 00 d0                             call       display_set_animation_29refs
d5940:  83 c4 04                                   add        word sp, 04h
d5943:  81 fa fa 02                                cmp        word dx, 02fah
d5947:  7c 2c                                      jl         loc_d5975
d5949:  7f 05                                      jg         loc_d5950
d594b:  3d 80 f0                                   cmp        ax, f080h
d594e:  76 25                                      jbe        loc_d5975

;  XREF: d5949
d5950:  68 40 50              loc_d5950:           push       5040h
d5953:  68 a7 00                                   push       00a7h
d5956:  9a 92 04 00 d0                             call       display_set_animation_29refs
d595b:  83 c4 04                                   add        word sp, 04h
d595e:  05 80 69                                   add        ax, 6980h
d5961:  81 d2 67 ff                                adc        word dx, ff67h

;  XREF: d5933
d5965:  52                    loc_d5965:           push       dx
d5966:  50                                         push       ax
d5967:  68 40 50                                   push       5040h
d596a:  68 a7 00                                   push       00a7h
d596d:  9a 6d 04 00 d0                             call       display_write_param_25refs
d5972:  83 c4 08                                   add        word sp, 08h

;  XREF: d5947, d594e
d5975:  83 3e 14 00 00        loc_d5975:           cmp        word [0014h], 00h
d597a:  75 17                                      jnz        loc_d5993
d597c:  83 3e 12 00 01                             cmp        word [0012h], 01h
d5981:  75 10                                      jnz        loc_d5993
d5983:  68 40 50                                   push       5040h
d5986:  68 b8 00                                   push       00b8h
d5989:  9a 92 04 00 d0                             call       display_set_animation_29refs
d598e:  83 c4 04                                   add        word sp, 04h
d5991:  eb 5d                                      jmp short  loc_d59f0

;  XREF: d597a, d5981
d5993:  68 40 50              loc_d5993:           push       5040h
d5996:  68 c9 00                                   push       00c9h
d5999:  9a 92 04 00 d0                             call       display_set_animation_29refs
d599e:  83 c4 04                                   add        word sp, 04h
d59a1:  50                                         push       ax
d59a2:  52                                         push       dx
d59a3:  68 40 50                                   push       5040h
d59a6:  68 a7 00                                   push       00a7h
d59a9:  9a 92 04 00 d0                             call       display_set_animation_29refs
d59ae:  83 c4 04                                   add        word sp, 04h
d59b1:  05 00 e1                                   add        ax, e100h
d59b4:  81 d2 f5 05                                adc        word dx, 05f5h
d59b8:  5b                                         pop        bx
d59b9:  3b da                                      cmp        bx, dx
d59bb:  5a                                         pop        dx
d59bc:  7c 1d                                      jl         loc_d59db
d59be:  7f 04                                      jg         loc_d59c4
d59c0:  3b d0                                      cmp        dx, ax
d59c2:  76 17                                      jbe        loc_d59db

;  XREF: d59be
d59c4:  68 40 50              loc_d59c4:           push       5040h
d59c7:  68 c9 00                                   push       00c9h
d59ca:  9a 92 04 00 d0                             call       display_set_animation_29refs
d59cf:  83 c4 04                                   add        word sp, 04h
d59d2:  05 80 69                                   add        ax, 6980h
d59d5:  81 d2 67 ff                                adc        word dx, ff67h
d59d9:  eb 15                                      jmp short  loc_d59f0

;  XREF: d59bc, d59c2
d59db:  68 40 50              loc_d59db:           push       5040h
d59de:  68 a7 00                                   push       00a7h
d59e1:  9a 92 04 00 d0                             call       display_set_animation_29refs
d59e6:  83 c4 04                                   add        word sp, 04h
d59e9:  05 00 e1                                   add        ax, e100h
d59ec:  81 d2 f5 05                                adc        word dx, 05f5h

;  XREF: d5991, d59d9
d59f0:  52                    loc_d59f0:           push       dx
d59f1:  50                                         push       ax
d59f2:  68 40 50                                   push       5040h
d59f5:  68 c9 00                                   push       00c9h
d59f8:  9a 6d 04 00 d0                             call       display_write_param_25refs
d59fd:  83 c4 08                                   add        word sp, 08h
d5a00:  0e                                         push       cs
d5a01:  e8 25 fd                                   call       flipper_button_handler
d5a04:  68 40 50                                   push       5040h
d5a07:  68 85 00                                   push       0085h
d5a0a:  9a 92 04 00 d0                             call       display_set_animation_29refs
d5a0f:  83 c4 04                                   add        word sp, 04h
d5a12:  89 16 3b 00                                mov        [003bh], dx
d5a16:  a3 39 00                                   mov        [0039h], ax
d5a19:  68 40 50                                   push       5040h
d5a1c:  68 a7 00                                   push       00a7h
d5a1f:  9a 92 04 00 d0                             call       display_set_animation_29refs
d5a24:  83 c4 04                                   add        word sp, 04h
d5a27:  89 16 37 00                                mov        [0037h], dx
d5a2b:  a3 35 00                                   mov        [0035h], ax
d5a2e:  68 40 50                                   push       5040h
d5a31:  68 c9 00                                   push       00c9h
d5a34:  9a 92 04 00 d0                             call       display_set_animation_29refs
d5a39:  83 c4 04                                   add        word sp, 04h
d5a3c:  89 16 33 00                                mov        [0033h], dx
d5a40:  a3 31 00                                   mov        [0031h], ax
d5a43:  1f                                         pop        ds
d5a44:  cb                                         retf

;  XREF: d2f6d

; -----------------------------------------------------------------------------
; process_input_events (0xD5A45)
; Process all pending input events from Z80 (called from main loop)
; -----------------------------------------------------------------------------
d5a45:  1e                    process_input_events:           push       ds
d5a46:  b8 30 41                                   mov        ax, 4130h
d5a49:  8e d8                                      mov        ds, ax
d5a4b:  68 f9 00                                   push       00f9h
d5a4e:  9a 38 01 00 d0                             call       cmd_queue_push
d5a53:  59                                         pop        cx
d5a54:  b8 00 40                                   mov        ax, 4000h
d5a57:  8e c0                                      mov        es, ax
d5a59:  26 c7 06 3d 11 90 01                       mov        word es:[113dh], 0190h

;  XREF: d5a74
d5a60:  9a e3 2f f2 d2        loc_d5a60:           call       timer_tick_handler
d5a65:  0a c0                                      or         al, al
d5a67:  75 0d                                      jnz        loc_d5a76
d5a69:  b8 00 40                                   mov        ax, 4000h
d5a6c:  8e c0                                      mov        es, ax
d5a6e:  26 83 3e 3d 11 00                          cmp        word es:[113dh], 00h
d5a74:  75 ea                                      jnz        loc_d5a60

;  XREF: d5a67
d5a76:  b8 00 40              loc_d5a76:           mov        ax, 4000h
d5a79:  8e c0                                      mov        es, ax
d5a7b:  26 83 3e 3d 11 00                          cmp        word es:[113dh], 00h
d5a81:  75 06                                      jnz        loc_d5a89
d5a83:  0e                                         push       cs
d5a84:  e8 5f fa                                   call       lane_completion_handler

;  XREF: d5a87
d5a87:  eb fe                 loc_d5a87:           jmp short  loc_d5a87

;  XREF: d5a81
d5a89:  1f                    loc_d5a89:           pop        ds
d5a8a:  cb                                         retf

;  XREF: d6601, d6641

; -----------------------------------------------------------------------------
; solenoid_fire (0xD5A8B)
; Fire a solenoid via Z80 shared RAM command (2 refs)
; -----------------------------------------------------------------------------
d5a8b:  1e                    solenoid_fire:           push       ds
d5a8c:  b8 30 41                                   mov        ax, 4130h
d5a8f:  8e d8                                      mov        ds, ax
d5a91:  68 f9 00                                   push       00f9h
d5a94:  9a 38 01 00 d0                             call       cmd_queue_push
d5a99:  59                                         pop        cx
d5a9a:  b8 00 40                                   mov        ax, 4000h
d5a9d:  8e c0                                      mov        es, ax
d5a9f:  26 c7 06 3d 11 90 01                       mov        word es:[113dh], 0190h

;  XREF: d5aba
d5aa6:  9a 1e 2d f2 d2        loc_d5aa6:           call       solenoid_sequence
d5aab:  0a c0                                      or         al, al
d5aad:  75 0d                                      jnz        loc_d5abc
d5aaf:  b8 00 40                                   mov        ax, 4000h
d5ab2:  8e c0                                      mov        es, ax
d5ab4:  26 83 3e 3d 11 00                          cmp        word es:[113dh], 00h
d5aba:  75 ea                                      jnz        loc_d5aa6

;  XREF: d5aad
d5abc:  b8 00 40              loc_d5abc:           mov        ax, 4000h
d5abf:  8e c0                                      mov        es, ax
d5ac1:  26 83 3e 3d 11 00                          cmp        word es:[113dh], 00h
d5ac7:  75 06                                      jnz        loc_d5acf
d5ac9:  0e                                         push       cs
d5aca:  e8 19 fa                                   call       lane_completion_handler

;  XREF: d5acd
d5acd:  eb fe                 loc_d5acd:           jmp short  loc_d5acd

;  XREF: d5ac7
d5acf:  1f                    loc_d5acf:           pop        ds
d5ad0:  cb                                         retf

;  XREF: d2fcb

; -----------------------------------------------------------------------------
; lamp_matrix_update (0xD5AD1)
; Update lamp matrix state via Z80 shared RAM
; -----------------------------------------------------------------------------
d5ad1:  1e                    lamp_matrix_update:           push       ds
d5ad2:  b8 30 41                                   mov        ax, 4130h
d5ad5:  8e d8                                      mov        ds, ax
d5ad7:  68 ed 00                                   push       00edh
d5ada:  9a 38 01 00 d0                             call       cmd_queue_push
d5adf:  59                                         pop        cx

;  XREF: d5ae7
d5ae0:  9a 6d 2e f2 d2        loc_d5ae0:           call       frame_counter_update
d5ae5:  0a c0                                      or         al, al
d5ae7:  74 f7                                      jz         loc_d5ae0
d5ae9:  1f                                         pop        ds
d5aea:  cb                                         retf

;  XREF: d5449

; -----------------------------------------------------------------------------
; lamp_set (0xD5AEB)
; Set individual lamp on/off
; -----------------------------------------------------------------------------
d5aeb:  1e                    lamp_set:           push       ds
d5aec:  b8 30 41                                   mov        ax, 4130h
d5aef:  8e d8                                      mov        ds, ax
d5af1:  b8 00 40                                   mov        ax, 4000h
d5af4:  8e c0                                      mov        es, ax
d5af6:  26 a0 47 11                                mov        al, es:[1147h] ; switch_event_pending - Non-zero when Z80 has written a new switch event
d5afa:  98                                         cbw
d5afb:  0b c0                                      or         ax, ax
d5afd:  74 5a                                      jz         loc_d5b59
d5aff:  b8 00 40                                   mov        ax, 4000h
d5b02:  8e c0                                      mov        es, ax
d5b04:  26 c4 1e 50 11                             les        bx, es:[1150h] ; display_buf_ptr1 - Display buffer pointer 1 (current read position)
d5b09:  26 8a 07                                   mov        al, es:[bx]
d5b0c:  a2 06 00                                   mov        [0006h], al
d5b0f:  80 3e 06 00 00                             cmp        byte [0006h], 00h
d5b14:  75 0d                                      jnz        loc_d5b23
d5b16:  b8 00 40                                   mov        ax, 4000h
d5b19:  8e c0                                      mov        es, ax
d5b1b:  26 c6 06 47 11 00                          mov        byte es:[1147h], 00h ; switch_event_pending - Non-zero when Z80 has written a new switch event
d5b21:  eb 36                                      jmp short  loc_d5b59

;  XREF: d5b14
d5b23:  b8 00 40              loc_d5b23:           mov        ax, 4000h
d5b26:  8e c0                                      mov        es, ax
d5b28:  26 c4 1e 50 11                             les        bx, es:[1150h] ; display_buf_ptr1 - Display buffer pointer 1 (current read position)
d5b2d:  26 c6 07 00                                mov        byte es:[bx], 00h
d5b31:  8e c0                                      mov        es, ax
d5b33:  26 a1 52 11                                mov        ax, es:[1152h] ; display_buf_seg1 - Display buffer segment 1
d5b37:  26 8b 16 50 11                             mov        dx, es:[1150h] ; display_buf_ptr1 - Display buffer pointer 1 (current read position)
d5b3c:  42                                         inc        dx
d5b3d:  bb 00 40                                   mov        bx, 4000h
d5b40:  8e c3                                      mov        es, bx
d5b42:  26 a3 52 11                                mov        es:[1152h], ax ; display_buf_seg1 - Display buffer segment 1
d5b46:  26 89 16 50 11                             mov        es:[1150h], dx
d5b4b:  a0 06 00                                   mov        al, [0006h]
d5b4e:  b4 00                                      mov        ah, 00h
d5b50:  3d 40 00                                   cmp        ax, 0040h     ; Switch: Upper_Flipper_Button
d5b53:  75 04                                      jnz        loc_d5b59
d5b55:  b0 01                                      mov        al, 01h
d5b57:  eb 02                                      jmp short  loc_d5b5b

;  XREF: d5afd, d5b21, d5b53
d5b59:  b0 00                 loc_d5b59:           mov        al, 00h

;  XREF: d5b57
d5b5b:  1f                    loc_d5b5b:           pop        ds
d5b5c:  cb                                         retf

;  XREF: d54c7

; -----------------------------------------------------------------------------
; lamp_flash (0xD5B5D)
; Set lamp to flash mode
; -----------------------------------------------------------------------------
d5b5d:  1e                    lamp_flash:           push       ds
d5b5e:  b8 30 41                                   mov        ax, 4130h
d5b61:  8e d8                                      mov        ds, ax
d5b63:  b8 00 40                                   mov        ax, 4000h
d5b66:  8e c0                                      mov        es, ax
d5b68:  26 a0 47 11                                mov        al, es:[1147h] ; switch_event_pending - Non-zero when Z80 has written a new switch event
d5b6c:  98                                         cbw
d5b6d:  0b c0                                      or         ax, ax
d5b6f:  74 5a                                      jz         loc_d5bcb
d5b71:  b8 00 40                                   mov        ax, 4000h
d5b74:  8e c0                                      mov        es, ax
d5b76:  26 c4 1e 50 11                             les        bx, es:[1150h] ; display_buf_ptr1 - Display buffer pointer 1 (current read position)
d5b7b:  26 8a 07                                   mov        al, es:[bx]
d5b7e:  a2 06 00                                   mov        [0006h], al
d5b81:  80 3e 06 00 00                             cmp        byte [0006h], 00h
d5b86:  75 0d                                      jnz        loc_d5b95
d5b88:  b8 00 40                                   mov        ax, 4000h
d5b8b:  8e c0                                      mov        es, ax
d5b8d:  26 c6 06 47 11 00                          mov        byte es:[1147h], 00h ; switch_event_pending - Non-zero when Z80 has written a new switch event
d5b93:  eb 36                                      jmp short  loc_d5bcb

;  XREF: d5b86
d5b95:  b8 00 40              loc_d5b95:           mov        ax, 4000h
d5b98:  8e c0                                      mov        es, ax
d5b9a:  26 c4 1e 50 11                             les        bx, es:[1150h] ; display_buf_ptr1 - Display buffer pointer 1 (current read position)
d5b9f:  26 c6 07 00                                mov        byte es:[bx], 00h
d5ba3:  8e c0                                      mov        es, ax
d5ba5:  26 a1 52 11                                mov        ax, es:[1152h] ; display_buf_seg1 - Display buffer segment 1
d5ba9:  26 8b 16 50 11                             mov        dx, es:[1150h] ; display_buf_ptr1 - Display buffer pointer 1 (current read position)
d5bae:  42                                         inc        dx
d5baf:  bb 00 40                                   mov        bx, 4000h
d5bb2:  8e c3                                      mov        es, bx
d5bb4:  26 a3 52 11                                mov        es:[1152h], ax ; display_buf_seg1 - Display buffer segment 1
d5bb8:  26 89 16 50 11                             mov        es:[1150h], dx
d5bbd:  a0 06 00                                   mov        al, [0006h]
d5bc0:  b4 00                                      mov        ah, 00h
d5bc2:  3d 3f 00                                   cmp        ax, 003fh     ; Switch: R_Flipper_Button
d5bc5:  75 04                                      jnz        loc_d5bcb
d5bc7:  b0 01                                      mov        al, 01h
d5bc9:  eb 02                                      jmp short  loc_d5bcd

;  XREF: d5b6f, d5b93, d5bc5
d5bcb:  b0 00                 loc_d5bcb:           mov        al, 00h

;  XREF: d5bc9
d5bcd:  1f                    loc_d5bcd:           pop        ds
d5bce:  cb                                         retf

;  XREF: d5aa6

; -----------------------------------------------------------------------------
; solenoid_sequence (0xD5C3E)
; Execute solenoid firing sequence
; -----------------------------------------------------------------------------
d5c3e:  1e                    solenoid_sequence:           push       ds
d5c3f:  b8 30 41                                   mov        ax, 4130h
d5c42:  8e d8                                      mov        ds, ax
d5c44:  b8 00 40                                   mov        ax, 4000h
d5c47:  8e c0                                      mov        es, ax
d5c49:  26 a0 47 11                                mov        al, es:[1147h] ; switch_event_pending - Non-zero when Z80 has written a new switch event
d5c4d:  98                                         cbw
d5c4e:  0b c0                                      or         ax, ax
d5c50:  75 05                                      jnz        loc_d5c57

;  XREF: d5c79, d5caa
d5c52:  b0 00                 loc_d5c52:           mov        al, 00h
d5c54:  e9 a8 00                                   jmp        loc_d5cff

;  XREF: d5c50
d5c57:  b8 00 40              loc_d5c57:           mov        ax, 4000h
d5c5a:  8e c0                                      mov        es, ax
d5c5c:  26 c4 1e 50 11                             les        bx, es:[1150h] ; display_buf_ptr1 - Display buffer pointer 1 (current read position)
d5c61:  26 8a 07                                   mov        al, es:[bx]
d5c64:  a2 06 00                                   mov        [0006h], al
d5c67:  80 3e 06 00 00                             cmp        byte [0006h], 00h
d5c6c:  75 0d                                      jnz        loc_d5c7b
d5c6e:  b8 00 40                                   mov        ax, 4000h
d5c71:  8e c0                                      mov        es, ax
d5c73:  26 c6 06 47 11 00                          mov        byte es:[1147h], 00h ; switch_event_pending - Non-zero when Z80 has written a new switch event
d5c79:  eb d7                                      jmp short  loc_d5c52

;  XREF: d5c6c
d5c7b:  b8 00 40              loc_d5c7b:           mov        ax, 4000h
d5c7e:  8e c0                                      mov        es, ax
d5c80:  26 c4 1e 50 11                             les        bx, es:[1150h] ; display_buf_ptr1 - Display buffer pointer 1 (current read position)
d5c85:  26 c6 07 00                                mov        byte es:[bx], 00h
d5c89:  8e c0                                      mov        es, ax
d5c8b:  26 a1 52 11                                mov        ax, es:[1152h] ; display_buf_seg1 - Display buffer segment 1
d5c8f:  26 8b 16 50 11                             mov        dx, es:[1150h] ; display_buf_ptr1 - Display buffer pointer 1 (current read position)
d5c94:  42                                         inc        dx
d5c95:  bb 00 40                                   mov        bx, 4000h
d5c98:  8e c3                                      mov        es, bx
d5c9a:  26 a3 52 11                                mov        es:[1152h], ax ; display_buf_seg1 - Display buffer segment 1
d5c9e:  26 89 16 50 11                             mov        es:[1150h], dx
d5ca3:  80 3e 06 00 f0                             cmp        byte [0006h], f0h
d5ca8:  73 02                                      jnb        loc_d5cac
d5caa:  eb a6                                      jmp short  loc_d5c52

;  XREF: d5ca8
d5cac:  a0 06 00              loc_d5cac:           mov        al, [0006h]
d5caf:  24 0e                                      and        al, 0eh
d5cb1:  a2 06 00                                   mov        [0006h], al
d5cb4:  b4 00                                      mov        ah, 00h
d5cb6:  2d 02 00                                   sub        ax, 0002h
d5cb9:  8b d8                                      mov        bx, ax
d5cbb:  83 fb 0c                                   cmp        word bx, 0ch
d5cbe:  77 38                                      ja         loc_d5cf8
d5cc0:  d1 e3                                      shl        bx, 1
d5cc2:  2e ff a7 e1 2d                             jmp        cs:[bx+2de1h]

;  XREF: d5cbe
d5cf8:  c6 06 20 00 00        loc_d5cf8:           mov        byte [0020h], 00h
d5cfd:  b0 01                                      mov        al, 01h

;  XREF: d5c54
d5cff:  1f                    loc_d5cff:           pop        ds
d5d00:  cb                                         retf

;  XREF: d2f59

; -----------------------------------------------------------------------------
; vsync_check (0xD5D1B)
; Check for vertical sync / frame tick (returns non-zero when frame ready)
; -----------------------------------------------------------------------------
d5d1b:  1e                    vsync_check:           push       ds
d5d1c:  b8 30 41                                   mov        ax, 4130h
d5d1f:  8e d8                                      mov        ds, ax
d5d21:  b8 00 40                                   mov        ax, 4000h
d5d24:  8e c0                                      mov        es, ax
d5d26:  26 a0 47 11                                mov        al, es:[1147h] ; switch_event_pending - Non-zero when Z80 has written a new switch event
d5d2a:  98                                         cbw
d5d2b:  0b c0                                      or         ax, ax
d5d2d:  74 5a                                      jz         loc_d5d89
d5d2f:  b8 00 40                                   mov        ax, 4000h
d5d32:  8e c0                                      mov        es, ax
d5d34:  26 c4 1e 50 11                             les        bx, es:[1150h] ; display_buf_ptr1 - Display buffer pointer 1 (current read position)
d5d39:  26 8a 07                                   mov        al, es:[bx]
d5d3c:  a2 06 00                                   mov        [0006h], al
d5d3f:  80 3e 06 00 00                             cmp        byte [0006h], 00h
d5d44:  75 0d                                      jnz        loc_d5d53
d5d46:  b8 00 40                                   mov        ax, 4000h
d5d49:  8e c0                                      mov        es, ax
d5d4b:  26 c6 06 47 11 00                          mov        byte es:[1147h], 00h ; switch_event_pending - Non-zero when Z80 has written a new switch event
d5d51:  eb 36                                      jmp short  loc_d5d89

;  XREF: d5d44
d5d53:  b8 00 40              loc_d5d53:           mov        ax, 4000h
d5d56:  8e c0                                      mov        es, ax
d5d58:  26 c4 1e 50 11                             les        bx, es:[1150h] ; display_buf_ptr1 - Display buffer pointer 1 (current read position)
d5d5d:  26 c6 07 00                                mov        byte es:[bx], 00h
d5d61:  8e c0                                      mov        es, ax
d5d63:  26 a1 52 11                                mov        ax, es:[1152h] ; display_buf_seg1 - Display buffer segment 1
d5d67:  26 8b 16 50 11                             mov        dx, es:[1150h] ; display_buf_ptr1 - Display buffer pointer 1 (current read position)
d5d6c:  42                                         inc        dx
d5d6d:  bb 00 40                                   mov        bx, 4000h
d5d70:  8e c3                                      mov        es, bx
d5d72:  26 a3 52 11                                mov        es:[1152h], ax ; display_buf_seg1 - Display buffer segment 1
d5d76:  26 89 16 50 11                             mov        es:[1150h], dx
d5d7b:  a0 06 00                                   mov        al, [0006h]
d5d7e:  b4 00                                      mov        ah, 00h
d5d80:  3d 47 00                                   cmp        ax, 0047h
d5d83:  75 04                                      jnz        loc_d5d89
d5d85:  b0 01                                      mov        al, 01h
d5d87:  eb 02                                      jmp short  loc_d5d8b

;  XREF: d5d2d, d5d51, d5d83
d5d89:  b0 00                 loc_d5d89:           mov        al, 00h

;  XREF: d5d87
d5d8b:  1f                    loc_d5d8b:           pop        ds
d5d8c:  cb                                         retf

;  XREF: d5ae0

; -----------------------------------------------------------------------------
; frame_counter_update (0xD5D8D)
; Update frame counter and timing variables
; -----------------------------------------------------------------------------
d5d8d:  1e                    frame_counter_update:           push       ds
d5d8e:  b8 30 41                                   mov        ax, 4130h
d5d91:  8e d8                                      mov        ds, ax
d5d93:  b8 00 40                                   mov        ax, 4000h
d5d96:  8e c0                                      mov        es, ax
d5d98:  26 a0 47 11                                mov        al, es:[1147h] ; switch_event_pending - Non-zero when Z80 has written a new switch event
d5d9c:  98                                         cbw
d5d9d:  0b c0                                      or         ax, ax
d5d9f:  75 03                                      jnz        loc_d5da4
d5da1:  e9 d2 00                                   jmp        loc_d5e76

;  XREF: d5d9f
d5da4:  b8 00 40              loc_d5da4:           mov        ax, 4000h
d5da7:  8e c0                                      mov        es, ax
d5da9:  26 c4 1e 50 11                             les        bx, es:[1150h] ; display_buf_ptr1 - Display buffer pointer 1 (current read position)
d5dae:  26 8a 07                                   mov        al, es:[bx]
d5db1:  a2 06 00                                   mov        [0006h], al
d5db4:  80 3e 06 00 00                             cmp        byte [0006h], 00h
d5db9:  75 0e                                      jnz        loc_d5dc9
d5dbb:  b8 00 40                                   mov        ax, 4000h
d5dbe:  8e c0                                      mov        es, ax
d5dc0:  26 c6 06 47 11 00                          mov        byte es:[1147h], 00h ; switch_event_pending - Non-zero when Z80 has written a new switch event
d5dc6:  e9 ad 00                                   jmp        loc_d5e76

;  XREF: d5db9
d5dc9:  b8 00 40              loc_d5dc9:           mov        ax, 4000h
d5dcc:  8e c0                                      mov        es, ax
d5dce:  26 c4 1e 50 11                             les        bx, es:[1150h] ; display_buf_ptr1 - Display buffer pointer 1 (current read position)
d5dd3:  26 c6 07 00                                mov        byte es:[bx], 00h
d5dd7:  8e c0                                      mov        es, ax
d5dd9:  26 a1 52 11                                mov        ax, es:[1152h] ; display_buf_seg1 - Display buffer segment 1
d5ddd:  26 8b 16 50 11                             mov        dx, es:[1150h] ; display_buf_ptr1 - Display buffer pointer 1 (current read position)
d5de2:  42                                         inc        dx
d5de3:  bb 00 40                                   mov        bx, 4000h
d5de6:  8e c3                                      mov        es, bx
d5de8:  26 a3 52 11                                mov        es:[1152h], ax ; display_buf_seg1 - Display buffer segment 1
d5dec:  26 89 16 50 11                             mov        es:[1150h], dx
d5df1:  a0 06 00                                   mov        al, [0006h]
d5df4:  b4 00                                      mov        ah, 00h
d5df6:  3d 45 00                                   cmp        ax, 0045h
d5df9:  74 3f                                      jz         loc_d5e3a
d5dfb:  3d 46 00                                   cmp        ax, 0046h
d5dfe:  75 76                                      jnz        loc_d5e76
d5e00:  9a c4 00 00 f0                             call       dmd_buffer_swap
d5e05:  9a f1 00 00 f0                             call       dmd_buffer_clear
d5e0a:  b8 3c 41                                   mov        ax, 413ch
d5e0d:  8e c0                                      mov        es, ax
d5e0f:  26 c4 1e b2 00                             les        bx, es:[00b2h]
d5e14:  26 ff 77 0a                                push       word es:[bx+0ah]
d5e18:  26 ff 77 08                                push       word es:[bx+08h]
d5e1c:  8e c0                                      mov        es, ax
d5e1e:  26 8e 06 b4 00                             mov        es, es:[00b4h]
d5e23:  26 ff 77 06                                push       word es:[bx+06h]
d5e27:  6a 01                                      push       01h
d5e29:  9a 01 07 00 f0                             call       dmd_text_render
d5e2e:  83 c4 08                                   add        word sp, 08h
d5e31:  6a 32                                      push       32h
d5e33:  0e                                         push       cs
d5e34:  e8 d1 f7                                   call       switch_read_shared_ram
d5e37:  59                                         pop        cx
d5e38:  eb 3c                                      jmp short  loc_d5e76

;  XREF: d5df9
d5e3a:  9a c4 00 00 f0        loc_d5e3a:           call       dmd_buffer_swap
d5e3f:  9a f1 00 00 f0                             call       dmd_buffer_clear
d5e44:  b8 3c 41                                   mov        ax, 413ch
d5e47:  8e c0                                      mov        es, ax
d5e49:  26 c4 1e b2 00                             les        bx, es:[00b2h]
d5e4e:  26 ff 77 10                                push       word es:[bx+10h]
d5e52:  26 ff 77 0e                                push       word es:[bx+0eh]
d5e56:  8e c0                                      mov        es, ax
d5e58:  26 8e 06 b4 00                             mov        es, es:[00b4h]
d5e5d:  26 ff 77 0c                                push       word es:[bx+0ch]
d5e61:  6a 01                                      push       01h
d5e63:  9a 01 07 00 f0                             call       dmd_text_render
d5e68:  83 c4 08                                   add        word sp, 08h
d5e6b:  6a 32                                      push       32h
d5e6d:  0e                                         push       cs
d5e6e:  e8 97 f7                                   call       switch_read_shared_ram
d5e71:  59                                         pop        cx
d5e72:  b0 01                                      mov        al, 01h
d5e74:  eb 02                                      jmp short  loc_d5e78

;  XREF: d5da1, d5dc6, d5dfe, d5e38
d5e76:  b0 00                 loc_d5e76:           mov        al, 00h

;  XREF: d5e74
d5e78:  1f                    loc_d5e78:           pop        ds
d5e79:  cb                                         retf

;  XREF: d2f9f

; -----------------------------------------------------------------------------
; wait_for_event (0xD5E7A)
; Wait for game event (button press, timeout)
; -----------------------------------------------------------------------------
d5e7a:  1e                    wait_for_event:           push       ds
d5e7b:  b8 30 41                                   mov        ax, 4130h
d5e7e:  8e d8                                      mov        ds, ax
d5e80:  b8 00 40                                   mov        ax, 4000h
d5e83:  8e c0                                      mov        es, ax
d5e85:  26 a0 47 11                                mov        al, es:[1147h] ; switch_event_pending - Non-zero when Z80 has written a new switch event
d5e89:  98                                         cbw
d5e8a:  0b c0                                      or         ax, ax
d5e8c:  74 71                                      jz         loc_d5eff
d5e8e:  b8 00 40                                   mov        ax, 4000h
d5e91:  8e c0                                      mov        es, ax
d5e93:  26 c4 1e 50 11                             les        bx, es:[1150h] ; display_buf_ptr1 - Display buffer pointer 1 (current read position)
d5e98:  26 8a 07                                   mov        al, es:[bx]
d5e9b:  a2 06 00                                   mov        [0006h], al
d5e9e:  80 3e 06 00 00                             cmp        byte [0006h], 00h
d5ea3:  75 0d                                      jnz        loc_d5eb2
d5ea5:  b8 00 40                                   mov        ax, 4000h
d5ea8:  8e c0                                      mov        es, ax
d5eaa:  26 c6 06 47 11 00                          mov        byte es:[1147h], 00h ; switch_event_pending - Non-zero when Z80 has written a new switch event
d5eb0:  eb 4d                                      jmp short  loc_d5eff

;  XREF: d5ea3
d5eb2:  b8 00 40              loc_d5eb2:           mov        ax, 4000h
d5eb5:  8e c0                                      mov        es, ax
d5eb7:  26 c4 1e 50 11                             les        bx, es:[1150h] ; display_buf_ptr1 - Display buffer pointer 1 (current read position)
d5ebc:  26 c6 07 00                                mov        byte es:[bx], 00h
d5ec0:  8e c0                                      mov        es, ax
d5ec2:  26 a1 52 11                                mov        ax, es:[1152h] ; display_buf_seg1 - Display buffer segment 1
d5ec6:  26 8b 16 50 11                             mov        dx, es:[1150h] ; display_buf_ptr1 - Display buffer pointer 1 (current read position)
d5ecb:  42                                         inc        dx
d5ecc:  bb 00 40                                   mov        bx, 4000h
d5ecf:  8e c3                                      mov        es, bx
d5ed1:  26 a3 52 11                                mov        es:[1152h], ax ; display_buf_seg1 - Display buffer segment 1
d5ed5:  26 89 16 50 11                             mov        es:[1150h], dx
d5eda:  80 3e 06 00 7a                             cmp        byte [0006h], 7ah
d5edf:  75 04                                      jnz        loc_d5ee5

;  XREF: d5efd
d5ee1:  b0 01                 loc_d5ee1:           mov        al, 01h
d5ee3:  eb 1c                                      jmp short  loc_d5f01

;  XREF: d5edf
d5ee5:  80 3e 06 00 50        loc_d5ee5:           cmp        byte [0006h], 50h
d5eea:  72 13                                      jb         loc_d5eff
d5eec:  80 3e 06 00 64                             cmp        byte [0006h], 64h
d5ef1:  77 0c                                      ja         loc_d5eff
d5ef3:  a0 06 00                                   mov        al, [0006h]
d5ef6:  50                                         push       ax
d5ef7:  9a d3 3a 25 dd                             call       player_display_credits
d5efc:  59                                         pop        cx
d5efd:  eb e2                                      jmp short  loc_d5ee1

;  XREF: d5e8c, d5eb0, d5eea, d5ef1
d5eff:  b0 00                 loc_d5eff:           mov        al, 00h

;  XREF: d5ee3
d5f01:  1f                    loc_d5f01:           pop        ds
d5f02:  cb                                         retf

;  XREF: d5a60

; -----------------------------------------------------------------------------
; timer_tick_handler (0xD5F03)
; Process timer tick events
; -----------------------------------------------------------------------------
d5f03:  1e                    timer_tick_handler:           push       ds
d5f04:  b8 30 41                                   mov        ax, 4130h
d5f07:  8e d8                                      mov        ds, ax
d5f09:  b8 00 40                                   mov        ax, 4000h
d5f0c:  8e c0                                      mov        es, ax
d5f0e:  26 a0 47 11                                mov        al, es:[1147h] ; switch_event_pending - Non-zero when Z80 has written a new switch event
d5f12:  98                                         cbw
d5f13:  0b c0                                      or         ax, ax
d5f15:  75 04                                      jnz        loc_d5f1b

;  XREF: d5f3d, d5f6c
d5f17:  b0 00                 loc_d5f17:           mov        al, 00h
d5f19:  eb 7c                                      jmp short  loc_d5f97

;  XREF: d5f15
d5f1b:  b8 00 40              loc_d5f1b:           mov        ax, 4000h
d5f1e:  8e c0                                      mov        es, ax
d5f20:  26 c4 1e 50 11                             les        bx, es:[1150h] ; display_buf_ptr1 - Display buffer pointer 1 (current read position)
d5f25:  26 8a 07                                   mov        al, es:[bx]
d5f28:  a2 06 00                                   mov        [0006h], al
d5f2b:  80 3e 06 00 00                             cmp        byte [0006h], 00h
d5f30:  75 0d                                      jnz        loc_d5f3f
d5f32:  b8 00 40                                   mov        ax, 4000h
d5f35:  8e c0                                      mov        es, ax
d5f37:  26 c6 06 47 11 00                          mov        byte es:[1147h], 00h ; switch_event_pending - Non-zero when Z80 has written a new switch event
d5f3d:  eb d8                                      jmp short  loc_d5f17

;  XREF: d5f30
d5f3f:  b8 00 40              loc_d5f3f:           mov        ax, 4000h
d5f42:  8e c0                                      mov        es, ax
d5f44:  26 c4 1e 50 11                             les        bx, es:[1150h] ; display_buf_ptr1 - Display buffer pointer 1 (current read position)
d5f49:  26 c6 07 00                                mov        byte es:[bx], 00h
d5f4d:  8e c0                                      mov        es, ax
d5f4f:  26 a1 52 11                                mov        ax, es:[1152h] ; display_buf_seg1 - Display buffer segment 1
d5f53:  26 8b 16 50 11                             mov        dx, es:[1150h] ; display_buf_ptr1 - Display buffer pointer 1 (current read position)
d5f58:  42                                         inc        dx
d5f59:  bb 00 40                                   mov        bx, 4000h
d5f5c:  8e c3                                      mov        es, bx
d5f5e:  26 a3 52 11                                mov        es:[1152h], ax ; display_buf_seg1 - Display buffer segment 1
d5f62:  26 89 16 50 11                             mov        es:[1150h], dx
d5f67:  80 3e 06 00 f0                             cmp        byte [0006h], f0h
d5f6c:  72 a9                                      jb         loc_d5f17
d5f6e:  a0 06 00                                   mov        al, [0006h]
d5f71:  24 01                                      and        al, 01h
d5f73:  a2 06 00                                   mov        [0006h], al
d5f76:  80 3e 06 00 00                             cmp        byte [0006h], 00h
d5f7b:  75 0d                                      jnz        loc_d5f8a
d5f7d:  b8 3c 41                                   mov        ax, 413ch
d5f80:  8e c0                                      mov        es, ax
d5f82:  26 c6 06 d9 00 00                          mov        byte es:[00d9h], 00h ; game_flag_2 - General game flag 2 (checked in main loop)
d5f88:  eb 0b                                      jmp short  loc_d5f95

;  XREF: d5f7b
d5f8a:  b8 3c 41              loc_d5f8a:           mov        ax, 413ch
d5f8d:  8e c0                                      mov        es, ax
d5f8f:  26 c6 06 d9 00 01                          mov        byte es:[00d9h], 01h ; game_flag_2 - General game flag 2 (checked in main loop)

;  XREF: d5f88
d5f95:  b0 01                 loc_d5f95:           mov        al, 01h

;  XREF: d5f19
d5f97:  1f                    loc_d5f97:           pop        ds
d5f98:  cb                                         retf

;  XREF: d2fd0

; -----------------------------------------------------------------------------
; playfield_logic_update (0xD60DE)
; Update playfield game logic state
; -----------------------------------------------------------------------------
d60de:  1e                    playfield_logic_update:           push       ds
d60df:  b8 30 41                                   mov        ax, 4130h
d60e2:  8e d8                                      mov        ds, ax
d60e4:  68 c4 00                                   push       00c4h
d60e7:  9a 38 01 00 d0                             call       cmd_queue_push
d60ec:  59                                         pop        cx
d60ed:  68 a9 00                                   push       00a9h
d60f0:  9a 38 01 00 d0                             call       cmd_queue_push
d60f5:  59                                         pop        cx
d60f6:  68 f6 00                                   push       00f6h
d60f9:  9a 38 01 00 d0                             call       cmd_queue_push
d60fe:  59                                         pop        cx
d60ff:  68 c8 00                                   push       00c8h
d6102:  9a 38 01 00 d0                             call       cmd_queue_push
d6107:  59                                         pop        cx
d6108:  68 f4 00                                   push       00f4h
d610b:  9a 38 01 00 d0                             call       cmd_queue_push
d6110:  59                                         pop        cx
d6111:  68 c6 00                                   push       00c6h
d6114:  9a 38 01 00 d0                             call       cmd_queue_push
d6119:  59                                         pop        cx
d611a:  68 ab 00                                   push       00abh
d611d:  9a 38 01 00 d0                             call       cmd_queue_push
d6122:  59                                         pop        cx
d6123:  6a 5e                                      push       5eh
d6125:  9a 38 01 00 d0                             call       cmd_queue_push
d612a:  59                                         pop        cx
d612b:  1f                                         pop        ds
d612c:  cb                                         retf

;  XREF: d2ff0

; -----------------------------------------------------------------------------
; multiball_logic_update (0xD612D)
; Update multiball game logic
; -----------------------------------------------------------------------------
d612d:  1e                    multiball_logic_update:           push       ds
d612e:  b8 30 41                                   mov        ax, 4130h
d6131:  8e d8                                      mov        ds, ax
d6133:  c7 06 0e 00 00 00                          mov        word [000eh], 0000h
d6139:  c6 06 10 00 00                             mov        byte [0010h], 00h
d613e:  b8 3c 41                                   mov        ax, 413ch
d6141:  8e c0                                      mov        es, ax
d6143:  26 c6 06 e0 00 00                          mov        byte es:[00e0h], 00h
d6149:  b8 3c 41                                   mov        ax, 413ch
d614c:  8e c0                                      mov        es, ax
d614e:  26 c6 06 de 00 00                          mov        byte es:[00deh], 00h
d6154:  b8 3c 41                                   mov        ax, 413ch
d6157:  8e c0                                      mov        es, ax
d6159:  26 c6 06 ea 00 01                          mov        byte es:[00eah], 01h
d615f:  b8 3c 41                                   mov        ax, 413ch
d6162:  8e c0                                      mov        es, ax
d6164:  26 c6 06 fe 00 01                          mov        byte es:[00feh], 01h
d616a:  b8 3c 41                                   mov        ax, 413ch
d616d:  8e c0                                      mov        es, ax
d616f:  26 c6 06 ff 00 01                          mov        byte es:[00ffh], 01h
d6175:  b8 3c 41                                   mov        ax, 413ch
d6178:  8e c0                                      mov        es, ax
d617a:  26 c6 06 fd 00 01                          mov        byte es:[00fdh], 01h
d6180:  b8 3c 41                                   mov        ax, 413ch
d6183:  8e c0                                      mov        es, ax
d6185:  26 c7 06 f2 00 00 00                       mov        word es:[00f2h], 0000h
d618c:  26 c7 06 f0 00 00 00                       mov        word es:[00f0h], 0000h
d6193:  b8 3c 41                                   mov        ax, 413ch
d6196:  8e c0                                      mov        es, ax
d6198:  26 c6 06 ee 00 00                          mov        byte es:[00eeh], 00h
d619e:  b8 3c 41                                   mov        ax, 413ch
d61a1:  8e c0                                      mov        es, ax
d61a3:  26 c6 06 ed 00 00                          mov        byte es:[00edh], 00h
d61a9:  c7 06 18 00 00 00                          mov        word [0018h], 0000h
d61af:  c7 06 16 00 00 00                          mov        word [0016h], 0000h
d61b5:  c7 06 14 00 00 00                          mov        word [0014h], 0000h
d61bb:  c7 06 12 00 00 00                          mov        word [0012h], 0000h
d61c1:  b8 3c 41                                   mov        ax, 413ch
d61c4:  8e c0                                      mov        es, ax
d61c6:  26 c6 06 eb 00 00                          mov        byte es:[00ebh], 00h
d61cc:  b8 3c 41                                   mov        ax, 413ch
d61cf:  8e c0                                      mov        es, ax
d61d1:  26 c7 06 f6 00 00 00                       mov        word es:[00f6h], 0000h
d61d8:  b8 3c 41                                   mov        ax, 413ch
d61db:  8e c0                                      mov        es, ax
d61dd:  26 c6 06 ec 00 00                          mov        byte es:[00ech], 00h
d61e3:  c6 06 3f 00 00                             mov        byte [003fh], 00h
d61e8:  c6 06 3e 00 00                             mov        byte [003eh], 00h
d61ed:  c7 06 0e 00 00 00                          mov        word [000eh], 0000h
d61f3:  eb 13                                      jmp short  loc_d6208

;  XREF: d620d
d61f5:  b8 3c 41              loc_d61f5:           mov        ax, 413ch
d61f8:  8b 1e 0e 00                                mov        bx, [000eh]
d61fc:  8e c0                                      mov        es, ax
d61fe:  26 c6 87 e1 00 00                          mov        byte es:[bx+00e1h], 00h
d6204:  ff 06 0e 00                                inc        word [000eh]

;  XREF: d61f3
d6208:  83 3e 0e 00 08        loc_d6208:           cmp        word [000eh], 08h
d620d:  7c e6                                      jl         loc_d61f5
d620f:  b8 3c 41                                   mov        ax, 413ch
d6212:  8e c0                                      mov        es, ax
d6214:  26 c6 06 dc 00 00                          mov        byte es:[00dch], 00h
d621a:  b8 3c 41                                   mov        ax, 413ch
d621d:  8e c0                                      mov        es, ax
d621f:  26 c6 06 dd 00 00                          mov        byte es:[00ddh], 00h ; attract_mode_active - Set to 1 when in attract mode
d6225:  c6 06 1a 00 01                             mov        byte [001ah], 01h
d622a:  1f                                         pop        ds
d622b:  cb                                         retf

;  XREF: d2f72, d3033, dd2b0

; -----------------------------------------------------------------------------
; default_game_logic (0xD622C)
; Default game logic handler (3 refs, also default state dispatch)
; -----------------------------------------------------------------------------
d622c:  1e                    default_game_logic:           push       ds
d622d:  b8 30 41                                   mov        ax, 4130h
d6230:  8e d8                                      mov        ds, ax
d6232:  9a c0 05 00 d0                             call       display_flush_2refs
d6237:  0b c0                                      or         ax, ax
d6239:  74 03                                      jz         loc_d623e
d623b:  e9 fd 03                                   jmp        loc_d663b

;  XREF: d6239
d623e:  0e                    loc_d623e:           push       cs
d623f:  e8 87 f1                                   call       target_hit_handler
d6242:  9a e2 06 00 d0                             call       hardware_setup_extended
d6247:  9a c0 05 00 d0                             call       display_flush_2refs
d624c:  0b c0                                      or         ax, ax
d624e:  75 06                                      jnz        loc_d6256
d6250:  0e                                         push       cs
d6251:  e8 18 f1                                   call       switch_event_dispatch

;  XREF: d6254
d6254:  eb fe                 loc_d6254:           jmp short  loc_d6254

;  XREF: d624e
d6256:  9a c9 08 00 d0        loc_d6256:           call       attract_mode_display_setup
d625b:  68 fa 02                                   push       02fah
d625e:  68 80 f0                                   push       f080h
d6261:  68 40 50                                   push       5040h
d6264:  68 85 00                                   push       0085h
d6267:  9a 6d 04 00 d0                             call       display_write_param_25refs
d626c:  83 c4 08                                   add        word sp, 08h
d626f:  68 fa 02                                   push       02fah
d6272:  68 80 f0                                   push       f080h
d6275:  68 3c 41                                   push       413ch
d6278:  68 e1 00                                   push       00e1h
d627b:  9a 20 57 2a d7                             call       score_compare_and_cap
d6280:  83 c4 08                                   add        word sp, 08h
d6283:  68 3c 41                                   push       413ch
d6286:  68 e1 00                                   push       00e1h
d6289:  0e                                         push       cs
d628a:  e8 d2 f3                                   call       switch_code_lookup
d628d:  83 c4 04                                   add        word sp, 04h
d6290:  c7 06 0c 00 00 00                          mov        word [000ch], 0000h
d6296:  eb 25                                      jmp short  loc_d62bd

;  XREF: d62c2
d6298:  b8 3c 41              loc_d6298:           mov        ax, 413ch
d629b:  8b 1e 0c 00                                mov        bx, [000ch]
d629f:  8e c0                                      mov        es, ax
d62a1:  26 8a 87 00 00                             mov        al, es:[bx]
d62a6:  50                                         push       ax
d62a7:  a1 0c 00                                   mov        ax, [000ch]
d62aa:  05 89 00                                   add        ax, 0089h
d62ad:  68 40 50                                   push       5040h
d62b0:  50                                         push       ax
d62b1:  9a a9 04 00 d0                             call       display_load_resource_51refs
d62b6:  83 c4 06                                   add        word sp, 06h
d62b9:  ff 06 0c 00                                inc        word [000ch]

;  XREF: d6296
d62bd:  83 3e 0c 00 0d        loc_d62bd:           cmp        word [000ch], 0dh
d62c2:  7c d4                                      jl         loc_d6298
d62c4:  68 f5 05                                   push       05f5h
d62c7:  68 00 e1                                   push       e100h
d62ca:  68 40 50                                   push       5040h
d62cd:  68 96 00                                   push       0096h
d62d0:  9a 6d 04 00 d0                             call       display_write_param_25refs
d62d5:  83 c4 08                                   add        word sp, 08h
d62d8:  68 f5 05                                   push       05f5h
d62db:  68 00 e1                                   push       e100h
d62de:  68 3c 41                                   push       413ch
d62e1:  68 e1 00                                   push       00e1h
d62e4:  9a 20 57 2a d7                             call       score_compare_and_cap
d62e9:  83 c4 08                                   add        word sp, 08h
d62ec:  68 3c 41                                   push       413ch
d62ef:  68 e1 00                                   push       00e1h
d62f2:  0e                                         push       cs
d62f3:  e8 69 f3                                   call       switch_code_lookup
d62f6:  83 c4 04                                   add        word sp, 04h
d62f9:  c7 06 0c 00 00 00                          mov        word [000ch], 0000h
d62ff:  eb 25                                      jmp short  loc_d6326

;  XREF: d632b
d6301:  b8 3c 41              loc_d6301:           mov        ax, 413ch
d6304:  8b 1e 0c 00                                mov        bx, [000ch]
d6308:  8e c0                                      mov        es, ax
d630a:  26 8a 87 00 00                             mov        al, es:[bx]
d630f:  50                                         push       ax
d6310:  a1 0c 00                                   mov        ax, [000ch]
d6313:  05 9a 00                                   add        ax, 009ah
d6316:  68 40 50                                   push       5040h
d6319:  50                                         push       ax
d631a:  9a a9 04 00 d0                             call       display_load_resource_51refs
d631f:  83 c4 06                                   add        word sp, 06h
d6322:  ff 06 0c 00                                inc        word [000ch]

;  XREF: d62ff
d6326:  83 3e 0c 00 0d        loc_d6326:           cmp        word [000ch], 0dh
d632b:  7c d4                                      jl         loc_d6301
d632d:  68 e1 11                                   push       11e1h
d6330:  68 00 a3                                   push       a300h
d6333:  68 40 50                                   push       5040h
d6336:  68 b8 00                                   push       00b8h
d6339:  9a 6d 04 00 d0                             call       display_write_param_25refs
d633e:  83 c4 08                                   add        word sp, 08h
d6341:  68 e1 11                                   push       11e1h
d6344:  68 00 a3                                   push       a300h
d6347:  68 3c 41                                   push       413ch
d634a:  68 e1 00                                   push       00e1h
d634d:  9a 20 57 2a d7                             call       score_compare_and_cap
d6352:  83 c4 08                                   add        word sp, 08h
d6355:  68 3c 41                                   push       413ch
d6358:  68 e1 00                                   push       00e1h
d635b:  0e                                         push       cs
d635c:  e8 00 f3                                   call       switch_code_lookup
d635f:  83 c4 04                                   add        word sp, 04h
d6362:  c7 06 0c 00 00 00                          mov        word [000ch], 0000h
d6368:  eb 25                                      jmp short  loc_d638f

;  XREF: d6394
d636a:  b8 3c 41              loc_d636a:           mov        ax, 413ch
d636d:  8b 1e 0c 00                                mov        bx, [000ch]
d6371:  8e c0                                      mov        es, ax
d6373:  26 8a 87 00 00                             mov        al, es:[bx]
d6378:  50                                         push       ax
d6379:  a1 0c 00                                   mov        ax, [000ch]
d637c:  05 bc 00                                   add        ax, 00bch
d637f:  68 40 50                                   push       5040h
d6382:  50                                         push       ax
d6383:  9a a9 04 00 d0                             call       display_load_resource_51refs
d6388:  83 c4 06                                   add        word sp, 06h
d638b:  ff 06 0c 00                                inc        word [000ch]

;  XREF: d6368
d638f:  83 3e 0c 00 0d        loc_d638f:           cmp        word [000ch], 0dh
d6394:  7c d4                                      jl         loc_d636a
d6396:  68 f5 05                                   push       05f5h
d6399:  68 00 e1                                   push       e100h
d639c:  68 40 50                                   push       5040h
d639f:  68 a7 00                                   push       00a7h
d63a2:  9a 6d 04 00 d0                             call       display_write_param_25refs
d63a7:  83 c4 08                                   add        word sp, 08h
d63aa:  68 f5 05                                   push       05f5h
d63ad:  68 00 e1                                   push       e100h
d63b0:  68 3c 41                                   push       413ch
d63b3:  68 e1 00                                   push       00e1h
d63b6:  9a 20 57 2a d7                             call       score_compare_and_cap
d63bb:  83 c4 08                                   add        word sp, 08h
d63be:  68 3c 41                                   push       413ch
d63c1:  68 e1 00                                   push       00e1h
d63c4:  0e                                         push       cs
d63c5:  e8 97 f2                                   call       switch_code_lookup
d63c8:  83 c4 04                                   add        word sp, 04h
d63cb:  c7 06 0c 00 00 00                          mov        word [000ch], 0000h
d63d1:  eb 25                                      jmp short  loc_d63f8

;  XREF: d63fd
d63d3:  b8 3c 41              loc_d63d3:           mov        ax, 413ch
d63d6:  8b 1e 0c 00                                mov        bx, [000ch]
d63da:  8e c0                                      mov        es, ax
d63dc:  26 8a 87 00 00                             mov        al, es:[bx]
d63e1:  50                                         push       ax
d63e2:  a1 0c 00                                   mov        ax, [000ch]
d63e5:  05 ab 00                                   add        ax, 00abh
d63e8:  68 40 50                                   push       5040h
d63eb:  50                                         push       ax
d63ec:  9a a9 04 00 d0                             call       display_load_resource_51refs
d63f1:  83 c4 06                                   add        word sp, 06h
d63f4:  ff 06 0c 00                                inc        word [000ch]

;  XREF: d63d1
d63f8:  83 3e 0c 00 0d        loc_d63f8:           cmp        word [000ch], 0dh
d63fd:  7c d4                                      jl         loc_d63d3
d63ff:  68 e1 11                                   push       11e1h
d6402:  68 00 a3                                   push       a300h
d6405:  68 40 50                                   push       5040h
d6408:  68 c9 00                                   push       00c9h
d640b:  9a 6d 04 00 d0                             call       display_write_param_25refs
d6410:  83 c4 08                                   add        word sp, 08h
d6413:  68 e1 11                                   push       11e1h
d6416:  68 00 a3                                   push       a300h
d6419:  68 3c 41                                   push       413ch
d641c:  68 e1 00                                   push       00e1h
d641f:  9a 20 57 2a d7                             call       score_compare_and_cap
d6424:  83 c4 08                                   add        word sp, 08h
d6427:  68 3c 41                                   push       413ch
d642a:  68 e1 00                                   push       00e1h
d642d:  0e                                         push       cs
d642e:  e8 2e f2                                   call       switch_code_lookup
d6431:  83 c4 04                                   add        word sp, 04h
d6434:  c7 06 0c 00 00 00                          mov        word [000ch], 0000h
d643a:  eb 25                                      jmp short  loc_d6461

;  XREF: d6466
d643c:  b8 3c 41              loc_d643c:           mov        ax, 413ch
d643f:  8b 1e 0c 00                                mov        bx, [000ch]
d6443:  8e c0                                      mov        es, ax
d6445:  26 8a 87 00 00                             mov        al, es:[bx]
d644a:  50                                         push       ax
d644b:  a1 0c 00                                   mov        ax, [000ch]
d644e:  05 cd 00                                   add        ax, 00cdh
d6451:  68 40 50                                   push       5040h
d6454:  50                                         push       ax
d6455:  9a a9 04 00 d0                             call       display_load_resource_51refs
d645a:  83 c4 06                                   add        word sp, 06h
d645d:  ff 06 0c 00                                inc        word [000ch]

;  XREF: d643a
d6461:  83 3e 0c 00 0d        loc_d6461:           cmp        word [000ch], 0dh
d6466:  7c d4                                      jl         loc_d643c
d6468:  6a 03                                      push       03h
d646a:  68 40 50                                   push       5040h
d646d:  68 3c 00                                   push       003ch
d6470:  9a a9 04 00 d0                             call       display_load_resource_51refs
d6475:  83 c4 06                                   add        word sp, 06h
d6478:  6a 03                                      push       03h
d647a:  68 40 50                                   push       5040h
d647d:  68 3f 00                                   push       003fh
d6480:  9a a9 04 00 d0                             call       display_load_resource_51refs
d6485:  83 c4 06                                   add        word sp, 06h
d6488:  6a 05                                      push       05h
d648a:  68 40 50                                   push       5040h
d648d:  68 3e 00                                   push       003eh
d6490:  9a a9 04 00 d0                             call       display_load_resource_51refs
d6495:  83 c4 06                                   add        word sp, 06h
d6498:  6a 05                                      push       05h
d649a:  68 40 50                                   push       5040h
d649d:  68 3d 00                                   push       003dh
d64a0:  9a a9 04 00 d0                             call       display_load_resource_51refs
d64a5:  83 c4 06                                   add        word sp, 06h
d64a8:  6a 00                                      push       00h
d64aa:  68 40 50                                   push       5040h
d64ad:  68 40 00                                   push       0040h
d64b0:  9a a9 04 00 d0                             call       display_load_resource_51refs
d64b5:  83 c4 06                                   add        word sp, 06h
d64b8:  6a 03                                      push       03h
d64ba:  68 40 50                                   push       5040h
d64bd:  68 41 00                                   push       0041h
d64c0:  9a a9 04 00 d0                             call       display_load_resource_51refs
d64c5:  83 c4 06                                   add        word sp, 06h
d64c8:  6a 01                                      push       01h
d64ca:  68 40 50                                   push       5040h
d64cd:  68 42 00                                   push       0042h
d64d0:  9a a9 04 00 d0                             call       display_load_resource_51refs
d64d5:  83 c4 06                                   add        word sp, 06h
d64d8:  6a 00                                      push       00h
d64da:  68 40 50                                   push       5040h
d64dd:  68 1d 03                                   push       031dh
d64e0:  9a a9 04 00 d0                             call       display_load_resource_51refs
d64e5:  83 c4 06                                   add        word sp, 06h
d64e8:  6a 00                                      push       00h
d64ea:  6a 00                                      push       00h
d64ec:  68 40 50                                   push       5040h
d64ef:  68 18 01                                   push       0118h
d64f2:  9a 6d 04 00 d0                             call       display_write_param_25refs
d64f7:  83 c4 08                                   add        word sp, 08h
d64fa:  6a 00                                      push       00h
d64fc:  6a 00                                      push       00h
d64fe:  68 40 50                                   push       5040h
d6501:  68 1c 01                                   push       011ch
d6504:  9a 6d 04 00 d0                             call       display_write_param_25refs
d6509:  83 c4 08                                   add        word sp, 08h
d650c:  6a 00                                      push       00h
d650e:  6a 00                                      push       00h
d6510:  68 40 50                                   push       5040h
d6513:  68 20 01                                   push       0120h
d6516:  9a 6d 04 00 d0                             call       display_write_param_25refs
d651b:  83 c4 08                                   add        word sp, 08h
d651e:  6a 00                                      push       00h
d6520:  6a 00                                      push       00h
d6522:  68 40 50                                   push       5040h
d6525:  68 24 01                                   push       0124h
d6528:  9a 6d 04 00 d0                             call       display_write_param_25refs
d652d:  83 c4 08                                   add        word sp, 08h
d6530:  6a 00                                      push       00h
d6532:  6a 00                                      push       00h
d6534:  68 40 50                                   push       5040h
d6537:  68 2c 01                                   push       012ch
d653a:  9a 6d 04 00 d0                             call       display_write_param_25refs
d653f:  83 c4 08                                   add        word sp, 08h
d6542:  6a 00                                      push       00h
d6544:  6a 00                                      push       00h
d6546:  68 40 50                                   push       5040h
d6549:  68 6c 01                                   push       016ch
d654c:  9a 6d 04 00 d0                             call       display_write_param_25refs
d6551:  83 c4 08                                   add        word sp, 08h
d6554:  6a 00                                      push       00h
d6556:  6a 00                                      push       00h
d6558:  68 40 50                                   push       5040h
d655b:  68 70 01                                   push       0170h
d655e:  9a 6d 04 00 d0                             call       display_write_param_25refs
d6563:  83 c4 08                                   add        word sp, 08h
d6566:  6a 00                                      push       00h
d6568:  6a 00                                      push       00h
d656a:  68 40 50                                   push       5040h
d656d:  68 74 01                                   push       0174h
d6570:  9a 6d 04 00 d0                             call       display_write_param_25refs
d6575:  83 c4 08                                   add        word sp, 08h
d6578:  6a 00                                      push       00h
d657a:  6a 00                                      push       00h
d657c:  68 40 50                                   push       5040h
d657f:  68 7c 01                                   push       017ch
d6582:  9a 6d 04 00 d0                             call       display_write_param_25refs
d6587:  83 c4 08                                   add        word sp, 08h
d658a:  6a 00                                      push       00h
d658c:  6a 00                                      push       00h
d658e:  68 40 50                                   push       5040h
d6591:  68 78 01                                   push       0178h
d6594:  9a 6d 04 00 d0                             call       display_write_param_25refs
d6599:  83 c4 08                                   add        word sp, 08h
d659c:  6a 01                                      push       01h
d659e:  68 a0 86                                   push       86a0h
d65a1:  68 40 50                                   push       5040h
d65a4:  68 43 00                                   push       0043h
d65a7:  9a 6d 04 00 d0                             call       display_write_param_25refs
d65ac:  83 c4 08                                   add        word sp, 08h
d65af:  68 40 50                                   push       5040h
d65b2:  68 43 00                                   push       0043h
d65b5:  9a 92 04 00 d0                             call       display_set_animation_29refs
d65ba:  83 c4 04                                   add        word sp, 04h
d65bd:  83 fa 01                                   cmp        word dx, 01h
d65c0:  75 05                                      jnz        loc_d65c7
d65c2:  3d a0 86                                   cmp        ax, 86a0h
d65c5:  74 06                                      jz         loc_d65cd

;  XREF: d65c0
d65c7:  0e                    loc_d65c7:           push       cs
d65c8:  e8 a1 ed                                   call       switch_event_dispatch

;  XREF: d65cb
d65cb:  eb fe                 loc_d65cb:           jmp short  loc_d65cb

;  XREF: d65c5
d65cd:  68 62 02              loc_d65cd:           push       0262h
d65d0:  68 00 5a                                   push       5a00h
d65d3:  68 40 50                                   push       5040h
d65d6:  68 28 01                                   push       0128h
d65d9:  9a 6d 04 00 d0                             call       display_write_param_25refs
d65de:  83 c4 08                                   add        word sp, 08h
d65e1:  68 40 50                                   push       5040h
d65e4:  68 28 01                                   push       0128h
d65e7:  9a 92 04 00 d0                             call       display_set_animation_29refs
d65ec:  83 c4 04                                   add        word sp, 04h
d65ef:  81 fa 62 02                                cmp        word dx, 0262h
d65f3:  75 05                                      jnz        loc_d65fa
d65f5:  3d 00 5a                                   cmp        ax, 5a00h
d65f8:  74 06                                      jz         loc_d6600

;  XREF: d65f3
d65fa:  0e                    loc_d65fa:           push       cs
d65fb:  e8 6e ed                                   call       switch_event_dispatch

;  XREF: d65fe
d65fe:  eb fe                 loc_d65fe:           jmp short  loc_d65fe

;  XREF: d65f8
d6600:  0e                    loc_d6600:           push       cs
d6601:  e8 87 f4                                   call       solenoid_fire
d6604:  b8 00 40                                   mov        ax, 4000h
d6607:  8a 16 20 00                                mov        dl, [0020h]
d660b:  8e c0                                      mov        es, ax
d660d:  26 88 16 01 10                             mov        es:[1001h], dl ; game_status_byte - Overall game status communicated to Z80
d6612:  a0 20 00                                   mov        al, [0020h]
d6615:  50                                         push       ax
d6616:  68 40 50                                   push       5040h
d6619:  68 bf 01                                   push       01bfh
d661c:  9a a9 04 00 d0                             call       display_load_resource_51refs
d6621:  83 c4 06                                   add        word sp, 06h
d6624:  9a ac 3a f2 d2                             call       scoop_handler
d6629:  6a 00                                      push       00h
d662b:  9a d2 04 00 d0                             call       display_write_word_12refs
d6630:  59                                         pop        cx
d6631:  6a 00                                      push       00h
d6633:  9a f3 04 00 d0                             call       display_set_mode_10refs
d6638:  59                                         pop        cx
d6639:  eb 05                                      jmp short  loc_d6640

;  XREF: d623b
d663b:  9a ff 08 00 d0        loc_d663b:           call       attract_text_display

;  XREF: d6639
d6640:  0e                    loc_d6640:           push       cs
d6641:  e8 47 f4                                   call       solenoid_fire
d6644:  b8 00 40                                   mov        ax, 4000h
d6647:  8e c0                                      mov        es, ax
d6649:  26 a0 01 10                                mov        al, es:[1001h] ; game_status_byte - Overall game status communicated to Z80
d664d:  3a 06 20 00                                cmp        al, [0020h]
d6651:  74 29                                      jz         loc_d667c
d6653:  b8 00 40                                   mov        ax, 4000h
d6656:  8a 16 20 00                                mov        dl, [0020h]
d665a:  8e c0                                      mov        es, ax
d665c:  26 88 16 01 10                             mov        es:[1001h], dl ; game_status_byte - Overall game status communicated to Z80
d6661:  a0 20 00                                   mov        al, [0020h]
d6664:  50                                         push       ax
d6665:  68 40 50                                   push       5040h
d6668:  68 bf 01                                   push       01bfh
d666b:  9a a9 04 00 d0                             call       display_load_resource_51refs
d6670:  83 c4 06                                   add        word sp, 06h
d6673:  9a ac 3a f2 d2                             call       scoop_handler
d6678:  0e                                         push       cs
d6679:  e8 c7 ee                                   call       ramp_shot_handler

;  XREF: d6651
d667c:  9a ab 01 25 dd        loc_d667c:           call       frame_processing_additional
d6681:  9a 16 3b f2 d2                             call       jupiter_handler
d6686:  b8 3c 41                                   mov        ax, 413ch
d6689:  8e c0                                      mov        es, ax
d668b:  26 c6 06 9f 00 00                          mov        byte es:[009fh], 00h
d6691:  b8 00 40                                   mov        ax, 4000h
d6694:  8e c0                                      mov        es, ax
d6696:  26 c6 06 44 11 00                          mov        byte es:[1144h], 00h
d669c:  9a 14 05 00 d0                             call       display_set_position_16refs
d66a1:  50                                         push       ax
d66a2:  9a 49 05 00 d0                             call       display_set_segment_14refs
d66a7:  5a                                         pop        dx
d66a8:  02 d0                                      add        dl, al
d66aa:  52                                         push       dx
d66ab:  9a d2 04 00 d0                             call       display_write_word_12refs
d66b0:  59                                         pop        cx
d66b1:  6a 00                                      push       00h
d66b3:  9a f3 04 00 d0                             call       display_set_mode_10refs
d66b8:  59                                         pop        cx
d66b9:  b8 3c 41                                   mov        ax, 413ch
d66bc:  8e c0                                      mov        es, ax
d66be:  26 c6 06 d5 00 00                          mov        byte es:[00d5h], 00h
d66c4:  9a 14 05 00 d0                             call       display_set_position_16refs
d66c9:  ba 3c 41                                   mov        dx, 413ch
d66cc:  8e c2                                      mov        es, dx
d66ce:  26 a2 d4 00                                mov        es:[00d4h], al ; credit_available - Non-zero when credits are available for game start
d66d2:  68 40 50                                   push       5040h
d66d5:  68 85 00                                   push       0085h
d66d8:  9a 92 04 00 d0                             call       display_set_animation_29refs
d66dd:  83 c4 04                                   add        word sp, 04h
d66e0:  89 16 3b 00                                mov        [003bh], dx
d66e4:  a3 39 00                                   mov        [0039h], ax
d66e7:  68 40 50                                   push       5040h
d66ea:  68 a7 00                                   push       00a7h
d66ed:  9a 92 04 00 d0                             call       display_set_animation_29refs
d66f2:  83 c4 04                                   add        word sp, 04h
d66f5:  89 16 37 00                                mov        [0037h], dx
d66f9:  a3 35 00                                   mov        [0035h], ax
d66fc:  68 40 50                                   push       5040h
d66ff:  68 c9 00                                   push       00c9h
d6702:  9a 92 04 00 d0                             call       display_set_animation_29refs
d6707:  83 c4 04                                   add        word sp, 04h
d670a:  89 16 33 00                                mov        [0033h], dx
d670e:  a3 31 00                                   mov        [0031h], ax
d6711:  68 40 50                                   push       5040h
d6714:  68 3c 00                                   push       003ch
d6717:  9a bf 04 00 d0                             call       display_check_status_48refs
d671c:  83 c4 04                                   add        word sp, 04h
d671f:  a2 3d 00                                   mov        [003dh], al
d6722:  68 40 50                                   push       5040h
d6725:  68 3f 00                                   push       003fh
d6728:  9a bf 04 00 d0                             call       display_check_status_48refs
d672d:  83 c4 04                                   add        word sp, 04h
d6730:  ba 3c 41                                   mov        dx, 413ch
d6733:  8e c2                                      mov        es, dx
d6735:  26 a2 01 01                                mov        es:[0101h], al
d6739:  68 40 50                                   push       5040h
d673c:  68 41 00                                   push       0041h
d673f:  9a bf 04 00 d0                             call       display_check_status_48refs
d6744:  83 c4 04                                   add        word sp, 04h
d6747:  ba 3c 41                                   mov        dx, 413ch
d674a:  8e c2                                      mov        es, dx
d674c:  26 a2 00 01                                mov        es:[0100h], al
d6750:  9a 37 38 f2 d2                             call       bumper_hit_handler
d6755:  1f                                         pop        ds
d6756:  cb                                         retf

;  XREF: d4ab5, d4c13, d4ced, d590a, d6750

; -----------------------------------------------------------------------------
; bumper_hit_handler (0xD6757)
; Handle pop bumper hit events (5 refs) - IMPACT COUNT tracking
; -----------------------------------------------------------------------------
d6757:  1e                    bumper_hit_handler:           push       ds
d6758:  b8 30 41                                   mov        ax, 4130h
d675b:  8e d8                                      mov        ds, ax
d675d:  c7 06 0c 00 00 00                          mov        word [000ch], 0000h
d6763:  eb 24                                      jmp short  loc_d6789

;  XREF: d678e
d6765:  a1 0c 00              loc_d6765:           mov        ax, [000ch]
d6768:  05 89 00                                   add        ax, 0089h
d676b:  68 40 50                                   push       5040h
d676e:  50                                         push       ax
d676f:  9a bf 04 00 d0                             call       display_check_status_48refs
d6774:  83 c4 04                                   add        word sp, 04h
d6777:  ba 00 40                                   mov        dx, 4000h
d677a:  8b 1e 0c 00                                mov        bx, [000ch]
d677e:  8e c2                                      mov        es, dx
d6780:  26 88 87 02 10                             mov        es:[bx+1002h], al
d6785:  ff 06 0c 00                                inc        word [000ch]

;  XREF: d6763
d6789:  83 3e 0c 00 0d        loc_d6789:           cmp        word [000ch], 0dh
d678e:  7c d5                                      jl         loc_d6765
d6790:  c7 06 0c 00 00 00                          mov        word [000ch], 0000h
d6796:  eb 24                                      jmp short  loc_d67bc

;  XREF: d67c1
d6798:  a1 0c 00              loc_d6798:           mov        ax, [000ch]
d679b:  05 ab 00                                   add        ax, 00abh
d679e:  68 40 50                                   push       5040h
d67a1:  50                                         push       ax
d67a2:  9a bf 04 00 d0                             call       display_check_status_48refs
d67a7:  83 c4 04                                   add        word sp, 04h
d67aa:  ba 00 40                                   mov        dx, 4000h
d67ad:  8b 1e 0c 00                                mov        bx, [000ch]
d67b1:  8e c2                                      mov        es, dx
d67b3:  26 88 87 0f 10                             mov        es:[bx+100fh], al
d67b8:  ff 06 0c 00                                inc        word [000ch]

;  XREF: d6796
d67bc:  83 3e 0c 00 0d        loc_d67bc:           cmp        word [000ch], 0dh
d67c1:  7c d5                                      jl         loc_d6798
d67c3:  c7 06 0c 00 00 00                          mov        word [000ch], 0000h
d67c9:  eb 24                                      jmp short  loc_d67ef

;  XREF: d67f4
d67cb:  a1 0c 00              loc_d67cb:           mov        ax, [000ch]
d67ce:  05 cd 00                                   add        ax, 00cdh
d67d1:  68 40 50                                   push       5040h
d67d4:  50                                         push       ax
d67d5:  9a bf 04 00 d0                             call       display_check_status_48refs
d67da:  83 c4 04                                   add        word sp, 04h
d67dd:  ba 00 40                                   mov        dx, 4000h
d67e0:  8b 1e 0c 00                                mov        bx, [000ch]
d67e4:  8e c2                                      mov        es, dx
d67e6:  26 88 87 1c 10                             mov        es:[bx+101ch], al
d67eb:  ff 06 0c 00                                inc        word [000ch]

;  XREF: d67c9
d67ef:  83 3e 0c 00 0d        loc_d67ef:           cmp        word [000ch], 0dh
d67f4:  7c d5                                      jl         loc_d67cb
d67f6:  68 40 50                                   push       5040h
d67f9:  68 1f 02                                   push       021fh
d67fc:  9a bf 04 00 d0                             call       display_check_status_48refs
d6801:  83 c4 04                                   add        word sp, 04h
d6804:  a2 07 00                                   mov        [0007h], al
d6807:  c7 06 0c 00 00 00                          mov        word [000ch], 0000h
d680d:  eb 24                                      jmp short  loc_d6833

;  XREF: d683b
d680f:  a1 0c 00              loc_d680f:           mov        ax, [000ch]
d6812:  05 1f 02                                   add        ax, 021fh
d6815:  68 40 50                                   push       5040h
d6818:  50                                         push       ax
d6819:  9a bf 04 00 d0                             call       display_check_status_48refs
d681e:  83 c4 04                                   add        word sp, 04h
d6821:  ba 00 40                                   mov        dx, 4000h
d6824:  8b 1e 0c 00                                mov        bx, [000ch]
d6828:  8e c2                                      mov        es, dx
d682a:  26 88 87 50 10                             mov        es:[bx+1050h], al
d682f:  ff 06 0c 00                                inc        word [000ch]

;  XREF: d680d
d6833:  a0 07 00              loc_d6833:           mov        al, [0007h]
d6836:  98                                         cbw
d6837:  3b 06 0c 00                                cmp        ax, [000ch]
d683b:  7d d2                                      jge        loc_d680f
d683d:  68 40 50                                   push       5040h
d6840:  68 44 02                                   push       0244h
d6843:  9a bf 04 00 d0                             call       display_check_status_48refs
d6848:  83 c4 04                                   add        word sp, 04h
d684b:  a2 07 00                                   mov        [0007h], al
d684e:  c7 06 0c 00 00 00                          mov        word [000ch], 0000h
d6854:  eb 24                                      jmp short  loc_d687a

;  XREF: d6882
d6856:  a1 0c 00              loc_d6856:           mov        ax, [000ch]
d6859:  05 44 02                                   add        ax, 0244h
d685c:  68 40 50                                   push       5040h
d685f:  50                                         push       ax
d6860:  9a bf 04 00 d0                             call       display_check_status_48refs
d6865:  83 c4 04                                   add        word sp, 04h
d6868:  ba 00 40                                   mov        dx, 4000h
d686b:  8b 1e 0c 00                                mov        bx, [000ch]
d686f:  8e c2                                      mov        es, dx
d6871:  26 88 87 64 10                             mov        es:[bx+1064h], al
d6876:  ff 06 0c 00                                inc        word [000ch]

;  XREF: d6854
d687a:  a0 07 00              loc_d687a:           mov        al, [0007h]
d687d:  98                                         cbw
d687e:  3b 06 0c 00                                cmp        ax, [000ch]
d6882:  7d d2                                      jge        loc_d6856
d6884:  68 40 50                                   push       5040h
d6887:  68 69 02                                   push       0269h
d688a:  9a bf 04 00 d0                             call       display_check_status_48refs
d688f:  83 c4 04                                   add        word sp, 04h
d6892:  a2 07 00                                   mov        [0007h], al
d6895:  c7 06 0c 00 00 00                          mov        word [000ch], 0000h
d689b:  eb 24                                      jmp short  loc_d68c1

;  XREF: d68c9
d689d:  a1 0c 00              loc_d689d:           mov        ax, [000ch]
d68a0:  05 69 02                                   add        ax, 0269h
d68a3:  68 40 50                                   push       5040h
d68a6:  50                                         push       ax
d68a7:  9a bf 04 00 d0                             call       display_check_status_48refs
d68ac:  83 c4 04                                   add        word sp, 04h
d68af:  ba 00 40                                   mov        dx, 4000h
d68b2:  8b 1e 0c 00                                mov        bx, [000ch]
d68b6:  8e c2                                      mov        es, dx
d68b8:  26 88 87 78 10                             mov        es:[bx+1078h], al
d68bd:  ff 06 0c 00                                inc        word [000ch]

;  XREF: d689b
d68c1:  a0 07 00              loc_d68c1:           mov        al, [0007h]
d68c4:  98                                         cbw
d68c5:  3b 06 0c 00                                cmp        ax, [000ch]
d68c9:  7d d2                                      jge        loc_d689d
d68cb:  c7 06 0c 00 00 00                          mov        word [000ch], 0000h
d68d1:  eb 24                                      jmp short  loc_d68f7

;  XREF: d68fc
d68d3:  a1 0c 00              loc_d68d3:           mov        ax, [000ch]
d68d6:  05 12 02                                   add        ax, 0212h
d68d9:  68 40 50                                   push       5040h
d68dc:  50                                         push       ax
d68dd:  9a bf 04 00 d0                             call       display_check_status_48refs
d68e2:  83 c4 04                                   add        word sp, 04h
d68e5:  ba 00 40                                   mov        dx, 4000h
d68e8:  8b 1e 0c 00                                mov        bx, [000ch]
d68ec:  8e c2                                      mov        es, dx
d68ee:  26 88 87 29 10                             mov        es:[bx+1029h], al
d68f3:  ff 06 0c 00                                inc        word [000ch]

;  XREF: d68d1
d68f7:  83 3e 0c 00 0d        loc_d68f7:           cmp        word [000ch], 0dh
d68fc:  7c d5                                      jl         loc_d68d3
d68fe:  c7 06 0c 00 00 00                          mov        word [000ch], 0000h
d6904:  eb 24                                      jmp short  loc_d692a

;  XREF: d692f
d6906:  a1 0c 00              loc_d6906:           mov        ax, [000ch]
d6909:  05 37 02                                   add        ax, 0237h
d690c:  68 40 50                                   push       5040h
d690f:  50                                         push       ax
d6910:  9a bf 04 00 d0                             call       display_check_status_48refs
d6915:  83 c4 04                                   add        word sp, 04h
d6918:  ba 00 40                                   mov        dx, 4000h
d691b:  8b 1e 0c 00                                mov        bx, [000ch]
d691f:  8e c2                                      mov        es, dx
d6921:  26 88 87 36 10                             mov        es:[bx+1036h], al
d6926:  ff 06 0c 00                                inc        word [000ch]

;  XREF: d6904
d692a:  83 3e 0c 00 0d        loc_d692a:           cmp        word [000ch], 0dh
d692f:  7c d5                                      jl         loc_d6906
d6931:  c7 06 0c 00 00 00                          mov        word [000ch], 0000h
d6937:  eb 24                                      jmp short  loc_d695d

;  XREF: d6962
d6939:  a1 0c 00              loc_d6939:           mov        ax, [000ch]
d693c:  05 5c 02                                   add        ax, 025ch
d693f:  68 40 50                                   push       5040h
d6942:  50                                         push       ax
d6943:  9a bf 04 00 d0                             call       display_check_status_48refs
d6948:  83 c4 04                                   add        word sp, 04h
d694b:  ba 00 40                                   mov        dx, 4000h
d694e:  8b 1e 0c 00                                mov        bx, [000ch]
d6952:  8e c2                                      mov        es, dx
d6954:  26 88 87 43 10                             mov        es:[bx+1043h], al
d6959:  ff 06 0c 00                                inc        word [000ch]

;  XREF: d6937
d695d:  83 3e 0c 00 0d        loc_d695d:           cmp        word [000ch], 0dh
d6962:  7c d5                                      jl         loc_d6939
d6964:  c7 06 0c 00 00 00                          mov        word [000ch], 0000h
d696a:  eb 24                                      jmp short  loc_d6990

;  XREF: d6995
d696c:  a1 0c 00              loc_d696c:           mov        ax, [000ch]
d696f:  05 b9 02                                   add        ax, 02b9h
d6972:  68 40 50                                   push       5040h
d6975:  50                                         push       ax
d6976:  9a bf 04 00 d0                             call       display_check_status_48refs
d697b:  83 c4 04                                   add        word sp, 04h
d697e:  ba 00 40                                   mov        dx, 4000h
d6981:  8b 1e 0c 00                                mov        bx, [000ch]
d6985:  8e c2                                      mov        es, dx
d6987:  26 88 87 8c 10                             mov        es:[bx+108ch], al
d698c:  ff 06 0c 00                                inc        word [000ch]

;  XREF: d696a
d6990:  83 3e 0c 00 10        loc_d6990:           cmp        word [000ch], 10h
d6995:  7c d5                                      jl         loc_d696c
d6997:  c7 06 0c 00 00 00                          mov        word [000ch], 0000h
d699d:  eb 24                                      jmp short  loc_d69c3

;  XREF: d69c8
d699f:  a1 0c 00              loc_d699f:           mov        ax, [000ch]
d69a2:  05 cd 02                                   add        ax, 02cdh
d69a5:  68 40 50                                   push       5040h
d69a8:  50                                         push       ax
d69a9:  9a bf 04 00 d0                             call       display_check_status_48refs
d69ae:  83 c4 04                                   add        word sp, 04h
d69b1:  ba 00 40                                   mov        dx, 4000h
d69b4:  8b 1e 0c 00                                mov        bx, [000ch]
d69b8:  8e c2                                      mov        es, dx
d69ba:  26 88 87 9c 10                             mov        es:[bx+109ch], al
d69bf:  ff 06 0c 00                                inc        word [000ch]

;  XREF: d699d
d69c3:  83 3e 0c 00 10        loc_d69c3:           cmp        word [000ch], 10h
d69c8:  7c d5                                      jl         loc_d699f
d69ca:  1f                                         pop        ds
d69cb:  cb                                         retf

;  XREF: d6624, d6673

; -----------------------------------------------------------------------------
; scoop_handler (0xD69CC)
; Handle scoop/VUK entry events (2 refs) - MONOLITH MESSAGE awards
; -----------------------------------------------------------------------------
d69cc:  1e                    scoop_handler:           push       ds
d69cd:  b8 30 41                                   mov        ax, 4130h
d69d0:  8e d8                                      mov        ds, ax
d69d2:  b8 00 40                                   mov        ax, 4000h
d69d5:  8e c0                                      mov        es, ax
d69d7:  26 a0 01 10                                mov        al, es:[1001h] ; game_status_byte - Overall game status communicated to Z80
d69db:  98                                         cbw
d69dc:  48                                         dec        ax
d69dd:  8b d8                                      mov        bx, ax
d69df:  83 fb 06                                   cmp        word bx, 06h
d69e2:  77 38                                      ja         loc_d6a1c
d69e4:  d1 e3                                      shl        bx, 1
d69e6:  2e ff a7 08 3b                             jmp        cs:[bx+3b08h]

;  XREF: d69e2
d6a1c:  9a 16 3e f2 d2        loc_d6a1c:           call       bonus_multiplier_handler
d6a21:  9a 8e 3c f2 d2                             call       orbit_handler
d6a26:  1f                                         pop        ds
d6a27:  cb                                         retf

;  XREF: d6681

; -----------------------------------------------------------------------------
; jupiter_handler (0xD6A36)
; Handle Jupiter ball lock/release events
; -----------------------------------------------------------------------------
d6a36:  1e                    jupiter_handler:           push       ds
d6a37:  b8 30 41                                   mov        ax, 4130h
d6a3a:  8e d8                                      mov        ds, ax
d6a3c:  68 40 50                                   push       5040h
d6a3f:  68 c4 01                                   push       01c4h
d6a42:  9a bf 04 00 d0                             call       display_check_status_48refs
d6a47:  83 c4 04                                   add        word sp, 04h
d6a4a:  ba 3c 41                                   mov        dx, 413ch
d6a4d:  8e c2                                      mov        es, dx
d6a4f:  26 a2 a5 00                                mov        es:[00a5h], al
d6a53:  68 40 50                                   push       5040h
d6a56:  68 c7 01                                   push       01c7h
d6a59:  9a bf 04 00 d0                             call       display_check_status_48refs
d6a5e:  83 c4 04                                   add        word sp, 04h
d6a61:  ba 3c 41                                   mov        dx, 413ch
d6a64:  8e c2                                      mov        es, dx
d6a66:  26 a2 a6 00                                mov        es:[00a6h], al
d6a6a:  68 40 50                                   push       5040h
d6a6d:  68 ca 01                                   push       01cah
d6a70:  9a bf 04 00 d0                             call       display_check_status_48refs
d6a75:  83 c4 04                                   add        word sp, 04h
d6a78:  ba 3c 41                                   mov        dx, 413ch
d6a7b:  8e c2                                      mov        es, dx
d6a7d:  26 a2 a7 00                                mov        es:[00a7h], al
d6a81:  68 40 50                                   push       5040h
d6a84:  68 cd 01                                   push       01cdh
d6a87:  9a bf 04 00 d0                             call       display_check_status_48refs
d6a8c:  83 c4 04                                   add        word sp, 04h
d6a8f:  ba 3c 41                                   mov        dx, 413ch
d6a92:  8e c2                                      mov        es, dx
d6a94:  26 a2 a8 00                                mov        es:[00a8h], al
d6a98:  68 40 50                                   push       5040h
d6a9b:  68 c6 01                                   push       01c6h
d6a9e:  9a bf 04 00 d0                             call       display_check_status_48refs
d6aa3:  83 c4 04                                   add        word sp, 04h
d6aa6:  ba 3c 41                                   mov        dx, 413ch
d6aa9:  8e c2                                      mov        es, dx
d6aab:  26 a2 ad 00                                mov        es:[00adh], al
d6aaf:  68 40 50                                   push       5040h
d6ab2:  68 c9 01                                   push       01c9h
d6ab5:  9a bf 04 00 d0                             call       display_check_status_48refs
d6aba:  83 c4 04                                   add        word sp, 04h
d6abd:  ba 3c 41                                   mov        dx, 413ch
d6ac0:  8e c2                                      mov        es, dx
d6ac2:  26 a2 ae 00                                mov        es:[00aeh], al
d6ac6:  68 40 50                                   push       5040h
d6ac9:  68 cc 01                                   push       01cch
d6acc:  9a bf 04 00 d0                             call       display_check_status_48refs
d6ad1:  83 c4 04                                   add        word sp, 04h
d6ad4:  ba 3c 41                                   mov        dx, 413ch
d6ad7:  8e c2                                      mov        es, dx
d6ad9:  26 a2 af 00                                mov        es:[00afh], al
d6add:  68 40 50                                   push       5040h
d6ae0:  68 cf 01                                   push       01cfh
d6ae3:  9a bf 04 00 d0                             call       display_check_status_48refs
d6ae8:  83 c4 04                                   add        word sp, 04h
d6aeb:  ba 3c 41                                   mov        dx, 413ch
d6aee:  8e c2                                      mov        es, dx
d6af0:  26 a2 b0 00                                mov        es:[00b0h], al
d6af4:  68 40 50                                   push       5040h
d6af7:  68 c5 01                                   push       01c5h
d6afa:  9a bf 04 00 d0                             call       display_check_status_48refs
d6aff:  83 c4 04                                   add        word sp, 04h
d6b02:  ba 3c 41                                   mov        dx, 413ch
d6b05:  8e c2                                      mov        es, dx
d6b07:  26 a2 a9 00                                mov        es:[00a9h], al
d6b0b:  68 40 50                                   push       5040h
d6b0e:  68 c8 01                                   push       01c8h
d6b11:  9a bf 04 00 d0                             call       display_check_status_48refs
d6b16:  83 c4 04                                   add        word sp, 04h
d6b19:  ba 3c 41                                   mov        dx, 413ch
d6b1c:  8e c2                                      mov        es, dx
d6b1e:  26 a2 aa 00                                mov        es:[00aah], al
d6b22:  68 40 50                                   push       5040h
d6b25:  68 cb 01                                   push       01cbh
d6b28:  9a bf 04 00 d0                             call       display_check_status_48refs
d6b2d:  83 c4 04                                   add        word sp, 04h
d6b30:  ba 3c 41                                   mov        dx, 413ch
d6b33:  8e c2                                      mov        es, dx
d6b35:  26 a2 ab 00                                mov        es:[00abh], al
d6b39:  68 40 50                                   push       5040h
d6b3c:  68 ce 01                                   push       01ceh
d6b3f:  9a bf 04 00 d0                             call       display_check_status_48refs
d6b44:  83 c4 04                                   add        word sp, 04h
d6b47:  ba 3c 41                                   mov        dx, 413ch
d6b4a:  8e c2                                      mov        es, dx
d6b4c:  26 a2 ac 00                                mov        es:[00ach], al
d6b50:  68 40 50                                   push       5040h
d6b53:  68 c0 01                                   push       01c0h
d6b56:  9a bf 04 00 d0                             call       display_check_status_48refs
d6b5b:  83 c4 04                                   add        word sp, 04h
d6b5e:  ba 3c 41                                   mov        dx, 413ch
d6b61:  8e c2                                      mov        es, dx
d6b63:  26 a2 a4 00                                mov        es:[00a4h], al
d6b67:  68 40 50                                   push       5040h
d6b6a:  68 c1 01                                   push       01c1h
d6b6d:  9a bf 04 00 d0                             call       display_check_status_48refs
d6b72:  83 c4 04                                   add        word sp, 04h
d6b75:  ba 3c 41                                   mov        dx, 413ch
d6b78:  8e c2                                      mov        es, dx
d6b7a:  26 a2 a3 00                                mov        es:[00a3h], al
d6b7e:  68 40 50                                   push       5040h
d6b81:  68 c2 01                                   push       01c2h
d6b84:  9a bf 04 00 d0                             call       display_check_status_48refs
d6b89:  83 c4 04                                   add        word sp, 04h
d6b8c:  ba 3c 41                                   mov        dx, 413ch
d6b8f:  8e c2                                      mov        es, dx
d6b91:  26 a2 a2 00                                mov        es:[00a2h], al
d6b95:  68 40 50                                   push       5040h
d6b98:  68 c3 01                                   push       01c3h
d6b9b:  9a bf 04 00 d0                             call       display_check_status_48refs
d6ba0:  83 c4 04                                   add        word sp, 04h
d6ba3:  ba 3c 41                                   mov        dx, 413ch
d6ba6:  8e c2                                      mov        es, dx
d6ba8:  26 a2 a1 00                                mov        es:[00a1h], al
d6bac:  1f                                         pop        ds
d6bad:  cb                                         retf

;  XREF: d6a21

; -----------------------------------------------------------------------------
; orbit_handler (0xD6BAE)
; Handle orbit shot completion
; -----------------------------------------------------------------------------
d6bae:  1e                    orbit_handler:           push       ds
d6baf:  b8 30 41                                   mov        ax, 4130h
d6bb2:  8e d8                                      mov        ds, ax
d6bb4:  b8 3c 41                                   mov        ax, 413ch
d6bb7:  8e c0                                      mov        es, ax
d6bb9:  26 a0 a5 00                                mov        al, es:[00a5h]
d6bbd:  50                                         push       ax
d6bbe:  68 40 50                                   push       5040h
d6bc1:  68 c4 01                                   push       01c4h
d6bc4:  9a a9 04 00 d0                             call       display_load_resource_51refs
d6bc9:  83 c4 06                                   add        word sp, 06h
d6bcc:  b8 3c 41                                   mov        ax, 413ch
d6bcf:  8e c0                                      mov        es, ax
d6bd1:  26 a0 a6 00                                mov        al, es:[00a6h]
d6bd5:  50                                         push       ax
d6bd6:  68 40 50                                   push       5040h
d6bd9:  68 c7 01                                   push       01c7h
d6bdc:  9a a9 04 00 d0                             call       display_load_resource_51refs
d6be1:  83 c4 06                                   add        word sp, 06h
d6be4:  b8 3c 41                                   mov        ax, 413ch
d6be7:  8e c0                                      mov        es, ax
d6be9:  26 a0 a7 00                                mov        al, es:[00a7h]
d6bed:  50                                         push       ax
d6bee:  68 40 50                                   push       5040h
d6bf1:  68 ca 01                                   push       01cah
d6bf4:  9a a9 04 00 d0                             call       display_load_resource_51refs
d6bf9:  83 c4 06                                   add        word sp, 06h
d6bfc:  b8 3c 41                                   mov        ax, 413ch
d6bff:  8e c0                                      mov        es, ax
d6c01:  26 a0 a8 00                                mov        al, es:[00a8h]
d6c05:  50                                         push       ax
d6c06:  68 40 50                                   push       5040h
d6c09:  68 cd 01                                   push       01cdh
d6c0c:  9a a9 04 00 d0                             call       display_load_resource_51refs
d6c11:  83 c4 06                                   add        word sp, 06h
d6c14:  b8 3c 41                                   mov        ax, 413ch
d6c17:  8e c0                                      mov        es, ax
d6c19:  26 a0 ad 00                                mov        al, es:[00adh]
d6c1d:  50                                         push       ax
d6c1e:  68 40 50                                   push       5040h
d6c21:  68 c6 01                                   push       01c6h
d6c24:  9a a9 04 00 d0                             call       display_load_resource_51refs
d6c29:  83 c4 06                                   add        word sp, 06h
d6c2c:  b8 3c 41                                   mov        ax, 413ch
d6c2f:  8e c0                                      mov        es, ax
d6c31:  26 a0 ae 00                                mov        al, es:[00aeh]
d6c35:  50                                         push       ax
d6c36:  68 40 50                                   push       5040h
d6c39:  68 c9 01                                   push       01c9h
d6c3c:  9a a9 04 00 d0                             call       display_load_resource_51refs
d6c41:  83 c4 06                                   add        word sp, 06h
d6c44:  b8 3c 41                                   mov        ax, 413ch
d6c47:  8e c0                                      mov        es, ax
d6c49:  26 a0 af 00                                mov        al, es:[00afh]
d6c4d:  50                                         push       ax
d6c4e:  68 40 50                                   push       5040h
d6c51:  68 cc 01                                   push       01cch
d6c54:  9a a9 04 00 d0                             call       display_load_resource_51refs
d6c59:  83 c4 06                                   add        word sp, 06h
d6c5c:  b8 3c 41                                   mov        ax, 413ch
d6c5f:  8e c0                                      mov        es, ax
d6c61:  26 a0 b0 00                                mov        al, es:[00b0h]
d6c65:  50                                         push       ax
d6c66:  68 40 50                                   push       5040h
d6c69:  68 cf 01                                   push       01cfh
d6c6c:  9a a9 04 00 d0                             call       display_load_resource_51refs
d6c71:  83 c4 06                                   add        word sp, 06h
d6c74:  b8 3c 41                                   mov        ax, 413ch
d6c77:  8e c0                                      mov        es, ax
d6c79:  26 a0 a9 00                                mov        al, es:[00a9h]
d6c7d:  50                                         push       ax
d6c7e:  68 40 50                                   push       5040h
d6c81:  68 c5 01                                   push       01c5h
d6c84:  9a a9 04 00 d0                             call       display_load_resource_51refs
d6c89:  83 c4 06                                   add        word sp, 06h
d6c8c:  b8 3c 41                                   mov        ax, 413ch
d6c8f:  8e c0                                      mov        es, ax
d6c91:  26 a0 aa 00                                mov        al, es:[00aah]
d6c95:  50                                         push       ax
d6c96:  68 40 50                                   push       5040h
d6c99:  68 c8 01                                   push       01c8h
d6c9c:  9a a9 04 00 d0                             call       display_load_resource_51refs
d6ca1:  83 c4 06                                   add        word sp, 06h
d6ca4:  b8 3c 41                                   mov        ax, 413ch
d6ca7:  8e c0                                      mov        es, ax
d6ca9:  26 a0 ab 00                                mov        al, es:[00abh]
d6cad:  50                                         push       ax
d6cae:  68 40 50                                   push       5040h
d6cb1:  68 cb 01                                   push       01cbh
d6cb4:  9a a9 04 00 d0                             call       display_load_resource_51refs
d6cb9:  83 c4 06                                   add        word sp, 06h
d6cbc:  b8 3c 41                                   mov        ax, 413ch
d6cbf:  8e c0                                      mov        es, ax
d6cc1:  26 a0 ac 00                                mov        al, es:[00ach]
d6cc5:  50                                         push       ax
d6cc6:  68 40 50                                   push       5040h
d6cc9:  68 ce 01                                   push       01ceh
d6ccc:  9a a9 04 00 d0                             call       display_load_resource_51refs
d6cd1:  83 c4 06                                   add        word sp, 06h
d6cd4:  b8 3c 41                                   mov        ax, 413ch
d6cd7:  8e c0                                      mov        es, ax
d6cd9:  26 a0 a4 00                                mov        al, es:[00a4h]
d6cdd:  50                                         push       ax
d6cde:  68 40 50                                   push       5040h
d6ce1:  68 c0 01                                   push       01c0h
d6ce4:  9a a9 04 00 d0                             call       display_load_resource_51refs
d6ce9:  83 c4 06                                   add        word sp, 06h
d6cec:  b8 3c 41                                   mov        ax, 413ch
d6cef:  8e c0                                      mov        es, ax
d6cf1:  26 a0 a3 00                                mov        al, es:[00a3h]
d6cf5:  50                                         push       ax
d6cf6:  68 40 50                                   push       5040h
d6cf9:  68 c1 01                                   push       01c1h
d6cfc:  9a a9 04 00 d0                             call       display_load_resource_51refs
d6d01:  83 c4 06                                   add        word sp, 06h
d6d04:  b8 3c 41                                   mov        ax, 413ch
d6d07:  8e c0                                      mov        es, ax
d6d09:  26 a0 a2 00                                mov        al, es:[00a2h]
d6d0d:  50                                         push       ax
d6d0e:  68 40 50                                   push       5040h
d6d11:  68 c2 01                                   push       01c2h
d6d14:  9a a9 04 00 d0                             call       display_load_resource_51refs
d6d19:  83 c4 06                                   add        word sp, 06h
d6d1c:  b8 3c 41                                   mov        ax, 413ch
d6d1f:  8e c0                                      mov        es, ax
d6d21:  26 a0 a1 00                                mov        al, es:[00a1h]
d6d25:  50                                         push       ax
d6d26:  68 40 50                                   push       5040h
d6d29:  68 c3 01                                   push       01c3h
d6d2c:  9a a9 04 00 d0                             call       display_load_resource_51refs
d6d31:  83 c4 06                                   add        word sp, 06h
d6d34:  1f                                         pop        ds
d6d35:  cb                                         retf

;  XREF: d6a1c

; -----------------------------------------------------------------------------
; bonus_multiplier_handler (0xD6D36)
; Handle bonus multiplier progression
; -----------------------------------------------------------------------------
d6d36:  1e                    bonus_multiplier_handler:           push       ds
d6d37:  b8 30 41                                   mov        ax, 4130h
d6d3a:  8e d8                                      mov        ds, ax
d6d3c:  b8 3c 41                                   mov        ax, 413ch
d6d3f:  8e c0                                      mov        es, ax
d6d41:  26 c6 06 a5 00 03                          mov        byte es:[00a5h], 03h
d6d47:  b8 3c 41                                   mov        ax, 413ch
d6d4a:  8e c0                                      mov        es, ax
d6d4c:  26 c6 06 a6 00 01                          mov        byte es:[00a6h], 01h
d6d52:  b8 3c 41                                   mov        ax, 413ch
d6d55:  8e c0                                      mov        es, ax
d6d57:  26 c6 06 a7 00 01                          mov        byte es:[00a7h], 01h
d6d5d:  b8 3c 41                                   mov        ax, 413ch
d6d60:  8e c0                                      mov        es, ax
d6d62:  26 a0 a5 00                                mov        al, es:[00a5h]
d6d66:  ba 3c 41                                   mov        dx, 413ch
d6d69:  8e c2                                      mov        es, dx
d6d6b:  26 a2 ad 00                                mov        es:[00adh], al
d6d6f:  b8 3c 41                                   mov        ax, 413ch
d6d72:  8e c0                                      mov        es, ax
d6d74:  26 a0 a6 00                                mov        al, es:[00a6h]
d6d78:  98                                         cbw
d6d79:  6b c0 05                                   imul       ax, ax, 05h
d6d7c:  ba 3c 41                                   mov        dx, 413ch
d6d7f:  8e c2                                      mov        es, dx
d6d81:  26 a2 ae 00                                mov        es:[00aeh], al
d6d85:  b8 3c 41                                   mov        ax, 413ch
d6d88:  8e c0                                      mov        es, ax
d6d8a:  26 a0 a7 00                                mov        al, es:[00a7h]
d6d8e:  98                                         cbw
d6d8f:  6b c0 0a                                   imul       ax, ax, 0ah
d6d92:  ba 3c 41                                   mov        dx, 413ch
d6d95:  8e c2                                      mov        es, dx
d6d97:  26 a2 af 00                                mov        es:[00afh], al
d6d9b:  b8 3c 41                                   mov        ax, 413ch
d6d9e:  8e c0                                      mov        es, ax
d6da0:  26 c6 06 a9 00 01                          mov        byte es:[00a9h], 01h
d6da6:  b8 3c 41                                   mov        ax, 413ch
d6da9:  8e c0                                      mov        es, ax
d6dab:  26 c6 06 aa 00 02                          mov        byte es:[00aah], 02h
d6db1:  b8 3c 41                                   mov        ax, 413ch
d6db4:  8e c0                                      mov        es, ax
d6db6:  26 c6 06 ab 00 05                          mov        byte es:[00abh], 05h
d6dbc:  b8 3c 41                                   mov        ax, 413ch
d6dbf:  8e c0                                      mov        es, ax
d6dc1:  26 c6 06 a4 00 01                          mov        byte es:[00a4h], 01h
d6dc7:  b8 3c 41                                   mov        ax, 413ch
d6dca:  8e c0                                      mov        es, ax
d6dcc:  26 c6 06 a3 00 05                          mov        byte es:[00a3h], 05h
d6dd2:  b8 3c 41                                   mov        ax, 413ch
d6dd5:  8e c0                                      mov        es, ax
d6dd7:  26 c6 06 a2 00 0a                          mov        byte es:[00a2h], 0ah
d6ddd:  1f                                         pop        ds
d6dde:  cb                                         retf

;  XREF: d372c, d485c, d5454, d54d2, d806f (+23 more)

; -----------------------------------------------------------------------------
; dmd_anim_play (0xD72AA)
; Play DMD animation sequence (28 refs) - core animation function
; -----------------------------------------------------------------------------
d72aa:  c8 06 00 00           dmd_anim_play:           enter      0006h, 00h
d72ae:  1e                                         push       ds
d72af:  b8 34 41                                   mov        ax, 4134h
d72b2:  8e d8                                      mov        ds, ax
d72b4:  b8 00 40                                   mov        ax, 4000h
d72b7:  8e c0                                      mov        es, ax
d72b9:  26 a1 52 11                                mov        ax, es:[1152h] ; display_buf_seg1 - Display buffer segment 1
d72bd:  26 8b 16 50 11                             mov        dx, es:[1150h] ; display_buf_ptr1 - Display buffer pointer 1 (current read position)
d72c2:  eb 16                                      jmp short  loc_d72da

;  XREF: d72ed
d72c4:  8a 46 ff              loc_d72c4:           mov        al, [bp-01h]
d72c7:  3a 46 06                                   cmp        al, [bp+06h]
d72ca:  75 07                                      jnz        loc_d72d3
d72cc:  c4 5e fa                                   les        bx, [bp-06h]
d72cf:  26 c6 07 32                                mov        byte es:[bx], 32h

;  XREF: d72ca
d72d3:  8b 46 fc              loc_d72d3:           mov        ax, [bp-04h]
d72d6:  8b 56 fa                                   mov        dx, [bp-06h]
d72d9:  42                                         inc        dx

;  XREF: d72c2
d72da:  89 46 fc              loc_d72da:           mov        [bp-04h], ax
d72dd:  89 56 fa                                   mov        [bp-06h], dx
d72e0:  c4 5e fa                                   les        bx, [bp-06h]
d72e3:  26 8a 07                                   mov        al, es:[bx]
d72e6:  88 46 ff                                   mov        [bp-01h], al
d72e9:  80 7e ff 00                                cmp        byte [bp-01h], 00h
d72ed:  75 d5                                      jnz        loc_d72c4
d72ef:  1f                                         pop        ds
d72f0:  c9                                         leave
d72f1:  cb                                         retf

;  XREF: d7b09, dc783, dc7ac, dc808

; -----------------------------------------------------------------------------
; dmd_anim_frame_advance (0xD72F2)
; Advance DMD animation to next frame (4 refs)
; -----------------------------------------------------------------------------
d72f2:  c8 06 00 00           dmd_anim_frame_advance:           enter      0006h, 00h
d72f6:  1e                                         push       ds
d72f7:  b8 34 41                                   mov        ax, 4134h
d72fa:  8e d8                                      mov        ds, ax
d72fc:  b8 00 40                                   mov        ax, 4000h
d72ff:  8e c0                                      mov        es, ax
d7301:  26 a1 52 11                                mov        ax, es:[1152h] ; display_buf_seg1 - Display buffer segment 1
d7305:  26 8b 16 50 11                             mov        dx, es:[1150h] ; display_buf_ptr1 - Display buffer pointer 1 (current read position)
d730a:  eb 27                                      jmp short  loc_d7333

;  XREF: d7346
d730c:  80 7e ff 41           loc_d730c:           cmp        byte [bp-01h], 41h
d7310:  7c 13                                      jl         loc_d7325
d7312:  80 7e ff 58                                cmp        byte [bp-01h], 58h
d7316:  7f 0d                                      jg         loc_d7325
d7318:  b8 3c 41                                   mov        ax, 413ch
d731b:  8e c0                                      mov        es, ax
d731d:  26 80 3e d9 00 00                          cmp        byte es:[00d9h], 00h ; game_flag_2 - General game flag 2 (checked in main loop)
d7323:  74 23                                      jz         loc_d7348

;  XREF: d7310, d7316
d7325:  c4 5e fa              loc_d7325:           les        bx, [bp-06h]
d7328:  26 c6 07 32                                mov        byte es:[bx], 32h
d732c:  8b 46 fc                                   mov        ax, [bp-04h]
d732f:  8b 56 fa                                   mov        dx, [bp-06h]
d7332:  42                                         inc        dx

;  XREF: d730a
d7333:  89 46 fc              loc_d7333:           mov        [bp-04h], ax
d7336:  89 56 fa                                   mov        [bp-06h], dx
d7339:  c4 5e fa                                   les        bx, [bp-06h]
d733c:  26 8a 07                                   mov        al, es:[bx]
d733f:  88 46 ff                                   mov        [bp-01h], al
d7342:  80 7e ff 00                                cmp        byte [bp-01h], 00h
d7346:  75 c4                                      jnz        loc_d730c

;  XREF: d7323
d7348:  1f                    loc_d7348:           pop        ds
d7349:  c9                                         leave
d734a:  cb                                         retf

;  XREF: d74f0, d7627

; -----------------------------------------------------------------------------
; dmd_anim_set_callback (0xD734B)
; Set animation completion callback function (2 refs)
; -----------------------------------------------------------------------------
d734b:  1e                    dmd_anim_set_callback:           push       ds
d734c:  b8 34 41                                   mov        ax, 4134h
d734f:  8e d8                                      mov        ds, ax
d7351:  b8 3c 41                                   mov        ax, 413ch
d7354:  8e c0                                      mov        es, ax
d7356:  26 80 3e d9 00 00                          cmp        byte es:[00d9h], 00h ; game_flag_2 - General game flag 2 (checked in main loop)
d735c:  75 67                                      jnz        loc_d73c5
d735e:  b8 3c 41                                   mov        ax, 413ch
d7361:  8e c0                                      mov        es, ax
d7363:  26 80 3e d6 00 50                          cmp        byte es:[00d6h], 50h ; last_switch_code - Last switch code received from Z80
d7369:  72 14                                      jb         loc_d737f
d736b:  8e c0                                      mov        es, ax
d736d:  26 80 3e d6 00 64                          cmp        byte es:[00d6h], 64h ; last_switch_code - Last switch code received from Z80
d7373:  77 0a                                      ja         loc_d737f
d7375:  9a 4b 35 2a d7                             call       dmd_anim_get_state

;  XREF: d739b, d73c3
d737a:  b8 01 00              loc_d737a:           mov        ax, 0001h
d737d:  eb 48                                      jmp short  loc_d73c7

;  XREF: d7369, d7373
d737f:  b8 3c 41              loc_d737f:           mov        ax, 413ch
d7382:  8e c0                                      mov        es, ax
d7384:  26 80 3e d6 00 65                          cmp        byte es:[00d6h], 65h ; last_switch_code - Last switch code received from Z80
d738a:  72 11                                      jb         loc_d739d
d738c:  8e c0                                      mov        es, ax
d738e:  26 80 3e d6 00 76                          cmp        byte es:[00d6h], 76h ; last_switch_code - Last switch code received from Z80
d7394:  77 07                                      ja         loc_d739d
d7396:  9a 15 33 2a d7                             call       dmd_anim_load_frame
d739b:  eb dd                                      jmp short  loc_d737a

;  XREF: d738a, d7394
d739d:  b8 3c 41              loc_d739d:           mov        ax, 413ch
d73a0:  8e c0                                      mov        es, ax
d73a2:  26 80 3e d6 00 77                          cmp        byte es:[00d6h], 77h ; last_switch_code - Last switch code received from Z80
d73a8:  74 14                                      jz         loc_d73be
d73aa:  8e c0                                      mov        es, ax
d73ac:  26 80 3e d6 00 78                          cmp        byte es:[00d6h], 78h ; last_switch_code - Last switch code received from Z80
d73b2:  74 0a                                      jz         loc_d73be
d73b4:  8e c0                                      mov        es, ax
d73b6:  26 80 3e d6 00 79                          cmp        byte es:[00d6h], 79h ; last_switch_code - Last switch code received from Z80
d73bc:  75 07                                      jnz        loc_d73c5

;  XREF: d73a8, d73b2
d73be:  9a 44 34 2a d7        loc_d73be:           call       dmd_anim_set_timing
d73c3:  eb b5                                      jmp short  loc_d737a

;  XREF: d735c, d73bc
d73c5:  33 c0                 loc_d73c5:           xor        ax, ax

;  XREF: d737d
d73c7:  1f                    loc_d73c7:           pop        ds
d73c8:  cb                                         retf

;  XREF: d7c96

; -----------------------------------------------------------------------------
; dmd_anim_wait_complete (0xD73C9)
; Wait for current animation to complete
; -----------------------------------------------------------------------------
d73c9:  1e                    dmd_anim_wait_complete:           push       ds
d73ca:  b8 34 41                                   mov        ax, 4134h
d73cd:  8e d8                                      mov        ds, ax
d73cf:  b8 3c 41                                   mov        ax, 413ch
d73d2:  8e c0                                      mov        es, ax
d73d4:  26 80 3e d9 00 00                          cmp        byte es:[00d9h], 00h ; game_flag_2 - General game flag 2 (checked in main loop)
d73da:  75 73                                      jnz        loc_d744f
d73dc:  80 3e 14 00 50                             cmp        byte [0014h], 50h
d73e1:  72 1f                                      jb         loc_d7402
d73e3:  80 3e 14 00 64                             cmp        byte [0014h], 64h
d73e8:  77 18                                      ja         loc_d7402
d73ea:  b8 3c 41                                   mov        ax, 413ch
d73ed:  8a 16 14 00                                mov        dl, [0014h]
d73f1:  8e c0                                      mov        es, ax
d73f3:  26 88 16 d6 00                             mov        es:[00d6h], dl ; last_switch_code - Last switch code received from Z80
d73f8:  9a 4b 35 2a d7                             call       dmd_anim_get_state

;  XREF: d7423, d744d
d73fd:  b8 01 00              loc_d73fd:           mov        ax, 0001h
d7400:  eb 4f                                      jmp short  loc_d7451

;  XREF: d73e1, d73e8
d7402:  80 3e 14 00 65        loc_d7402:           cmp        byte [0014h], 65h
d7407:  72 1c                                      jb         loc_d7425
d7409:  80 3e 14 00 76                             cmp        byte [0014h], 76h
d740e:  77 15                                      ja         loc_d7425
d7410:  b8 3c 41                                   mov        ax, 413ch
d7413:  8a 16 14 00                                mov        dl, [0014h]
d7417:  8e c0                                      mov        es, ax
d7419:  26 88 16 d6 00                             mov        es:[00d6h], dl ; last_switch_code - Last switch code received from Z80
d741e:  9a 15 33 2a d7                             call       dmd_anim_load_frame
d7423:  eb d8                                      jmp short  loc_d73fd

;  XREF: d7407, d740e
d7425:  80 3e 14 00 77        loc_d7425:           cmp        byte [0014h], 77h
d742a:  74 0e                                      jz         loc_d743a
d742c:  80 3e 14 00 78                             cmp        byte [0014h], 78h
d7431:  74 07                                      jz         loc_d743a
d7433:  80 3e 14 00 79                             cmp        byte [0014h], 79h
d7438:  75 15                                      jnz        loc_d744f

;  XREF: d742a, d7431
d743a:  b8 3c 41              loc_d743a:           mov        ax, 413ch
d743d:  8a 16 14 00                                mov        dl, [0014h]
d7441:  8e c0                                      mov        es, ax
d7443:  26 88 16 d6 00                             mov        es:[00d6h], dl ; last_switch_code - Last switch code received from Z80
d7448:  9a 44 34 2a d7                             call       dmd_anim_set_timing
d744d:  eb ae                                      jmp short  loc_d73fd

;  XREF: d73da, d7438
d744f:  33 c0                 loc_d744f:           xor        ax, ax

;  XREF: d7400
d7451:  1f                    loc_d7451:           pop        ds
d7452:  cb                                         retf

;  XREF: d763d, d7a19, d7b4e, dc07c, dc0a3 (+4 more)

; -----------------------------------------------------------------------------
; dmd_score_display (0xD7453)
; Display score value on DMD (9 refs)
; -----------------------------------------------------------------------------
d7453:  1e                    dmd_score_display:           push       ds
d7454:  b8 34 41                                   mov        ax, 4134h
d7457:  8e d8                                      mov        ds, ax
d7459:  b8 00 40                                   mov        ax, 4000h
d745c:  8e c0                                      mov        es, ax
d745e:  26 a0 47 11                                mov        al, es:[1147h] ; switch_event_pending - Non-zero when Z80 has written a new switch event
d7462:  98                                         cbw
d7463:  0b c0                                      or         ax, ax
d7465:  75 05                                      jnz        loc_d746c

;  XREF: d7495, d74c5, d74f7
d7467:  33 c0                 loc_d7467:           xor        ax, ax
d7469:  e9 91 00                                   jmp        loc_d74fd

;  XREF: d7465
d746c:  b8 00 40              loc_d746c:           mov        ax, 4000h
d746f:  8e c0                                      mov        es, ax
d7471:  26 80 3e 44 11 00                          cmp        byte es:[1144h], 00h
d7477:  74 1e                                      jz         loc_d7497
d7479:  b8 3c 41                                   mov        ax, 413ch
d747c:  8e c0                                      mov        es, ax
d747e:  26 a0 d4 00                                mov        al, es:[00d4h] ; credit_available - Non-zero when credits are available for game start
d7482:  a2 34 00                                   mov        [0034h], al
d7485:  9a 6a 0d 2a d7                             call       dmd_score_format
d748a:  b8 00 40                                   mov        ax, 4000h
d748d:  8e c0                                      mov        es, ax
d748f:  26 c6 06 47 11 01                          mov        byte es:[1147h], 01h ; switch_event_pending - Non-zero when Z80 has written a new switch event
d7495:  eb d0                                      jmp short  loc_d7467

;  XREF: d7477
d7497:  b8 00 40              loc_d7497:           mov        ax, 4000h
d749a:  8e c0                                      mov        es, ax
d749c:  26 c4 1e 50 11                             les        bx, es:[1150h] ; display_buf_ptr1 - Display buffer pointer 1 (current read position)
d74a1:  26 8a 07                                   mov        al, es:[bx]
d74a4:  ba 3c 41                                   mov        dx, 413ch
d74a7:  8e c2                                      mov        es, dx
d74a9:  26 a2 d6 00                                mov        es:[00d6h], al
d74ad:  b8 3c 41                                   mov        ax, 413ch
d74b0:  8e c0                                      mov        es, ax
d74b2:  26 80 3e d6 00 00                          cmp        byte es:[00d6h], 00h ; last_switch_code - Last switch code received from Z80
d74b8:  75 0d                                      jnz        loc_d74c7
d74ba:  b8 00 40                                   mov        ax, 4000h
d74bd:  8e c0                                      mov        es, ax
d74bf:  26 c6 06 47 11 00                          mov        byte es:[1147h], 00h ; switch_event_pending - Non-zero when Z80 has written a new switch event
d74c5:  eb a0                                      jmp short  loc_d7467

;  XREF: d74b8
d74c7:  b8 00 40              loc_d74c7:           mov        ax, 4000h
d74ca:  8e c0                                      mov        es, ax
d74cc:  26 c4 1e 50 11                             les        bx, es:[1150h] ; display_buf_ptr1 - Display buffer pointer 1 (current read position)
d74d1:  26 c6 07 00                                mov        byte es:[bx], 00h
d74d5:  8e c0                                      mov        es, ax
d74d7:  26 a1 52 11                                mov        ax, es:[1152h] ; display_buf_seg1 - Display buffer segment 1
d74db:  26 8b 16 50 11                             mov        dx, es:[1150h] ; display_buf_ptr1 - Display buffer pointer 1 (current read position)
d74e0:  42                                         inc        dx
d74e1:  bb 00 40                                   mov        bx, 4000h
d74e4:  8e c3                                      mov        es, bx
d74e6:  26 a3 52 11                                mov        es:[1152h], ax ; display_buf_seg1 - Display buffer segment 1
d74ea:  26 89 16 50 11                             mov        es:[1150h], dx
d74ef:  0e                                         push       cs
d74f0:  e8 58 fe                                   call       dmd_anim_set_callback
d74f3:  0b c0                                      or         ax, ax
d74f5:  74 03                                      jz         loc_d74fa
d74f7:  e9 6d ff                                   jmp        loc_d7467

;  XREF: d74f5
d74fa:  b8 01 00              loc_d74fa:           mov        ax, 0001h

;  XREF: d7469
d74fd:  1f                    loc_d74fd:           pop        ds
d74fe:  cb                                         retf

;  XREF: d7ac3, d7b81, dc04c

; -----------------------------------------------------------------------------
; dmd_text_display (0xD74FF)
; Display text string on DMD (3 refs)
; -----------------------------------------------------------------------------
d74ff:  1e                    dmd_text_display:           push       ds
d7500:  b8 34 41                                   mov        ax, 4134h
d7503:  8e d8                                      mov        ds, ax
d7505:  b8 00 40                                   mov        ax, 4000h
d7508:  8e c0                                      mov        es, ax
d750a:  26 a0 47 11                                mov        al, es:[1147h] ; switch_event_pending - Non-zero when Z80 has written a new switch event
d750e:  98                                         cbw
d750f:  0b c0                                      or         ax, ax
d7511:  75 05                                      jnz        loc_d7518

;  XREF: d756b, d7578, d7587, d75bf, d75c7 (+2 more)
d7513:  33 c0                 loc_d7513:           xor        ax, ax
d7515:  e9 1c 01                                   jmp        loc_d7634

;  XREF: d7511
d7518:  b8 00 40              loc_d7518:           mov        ax, 4000h
d751b:  8e c0                                      mov        es, ax
d751d:  26 80 3e 44 11 00                          cmp        byte es:[1144h], 00h
d7523:  75 03                                      jnz        loc_d7528
d7525:  e9 a5 00                                   jmp        loc_d75cd

;  XREF: d7523
d7528:  b8 3c 41              loc_d7528:           mov        ax, 413ch
d752b:  8e c0                                      mov        es, ax
d752d:  26 a0 d4 00                                mov        al, es:[00d4h] ; credit_available - Non-zero when credits are available for game start
d7531:  a2 34 00                                   mov        [0034h], al
d7534:  9a 6a 0d 2a d7                             call       dmd_score_format
d7539:  b8 00 40                                   mov        ax, 4000h
d753c:  8e c0                                      mov        es, ax
d753e:  26 c6 06 47 11 01                          mov        byte es:[1147h], 01h ; switch_event_pending - Non-zero when Z80 has written a new switch event
d7544:  9a 89 5a 2a d7                             call       credits_display_check
d7549:  9a cd 36 2a d7                             call       dmd_anim_complete_check
d754e:  b8 3c 41                                   mov        ax, 413ch
d7551:  8e c0                                      mov        es, ax
d7553:  26 80 3e e0 00 00                          cmp        byte es:[00e0h], 00h
d7559:  74 05                                      jz         loc_d7560
d755b:  9a 96 0e 00 f0                             call       eeprom_read

;  XREF: d7559
d7560:  b8 3c 41              loc_d7560:           mov        ax, 413ch
d7563:  8e c0                                      mov        es, ax
d7565:  26 80 3e 4f 01 02                          cmp        byte es:[014fh], 02h ; game_state_var - STATE MACHINE variable: 0=init, 1=attract, 2=game_active, 4=special_mode
d756b:  75 a6                                      jnz        loc_d7513
d756d:  b8 3c 41                                   mov        ax, 413ch
d7570:  8e c0                                      mov        es, ax
d7572:  26 80 3e d7 00 04                          cmp        byte es:[00d7h], 04h ; game_flag_1 - General game flag 1
d7578:  73 99                                      jnb        loc_d7513
d757a:  b8 3c 41                                   mov        ax, 413ch
d757d:  8e c0                                      mov        es, ax
d757f:  26 a0 d4 00                                mov        al, es:[00d4h] ; credit_available - Non-zero when credits are available for game start
d7583:  3a 06 34 00                                cmp        al, [0034h]
d7587:  7e 8a                                      jle        loc_d7513
d7589:  b8 3c 41                                   mov        ax, 413ch
d758c:  8e c0                                      mov        es, ax
d758e:  26 80 3e d7 00 01                          cmp        byte es:[00d7h], 01h ; game_flag_1 - General game flag 1
d7594:  76 1c                                      jbe        loc_d75b2
d7596:  68 b2 00                                   push       00b2h
d7599:  9a 73 0f 00 f0                             call       eeprom_validate
d759e:  59                                         pop        cx
d759f:  6a 5d                                      push       5dh
d75a1:  9a 38 01 00 d0                             call       cmd_queue_push
d75a6:  59                                         pop        cx
d75a7:  b8 3c 41                                   mov        ax, 413ch
d75aa:  8e c0                                      mov        es, ax
d75ac:  26 c6 06 de 00 01                          mov        byte es:[00deh], 01h

;  XREF: d7594
d75b2:  b8 3c 41              loc_d75b2:           mov        ax, 413ch
d75b5:  8e c0                                      mov        es, ax
d75b7:  26 80 3e e0 00 00                          cmp        byte es:[00e0h], 00h
d75bd:  75 03                                      jnz        loc_d75c2
d75bf:  e9 51 ff                                   jmp        loc_d7513

;  XREF: d75bd
d75c2:  9a 96 0e 00 f0        loc_d75c2:           call       eeprom_read
d75c7:  e9 49 ff                                   jmp        loc_d7513

;  XREF: d7525
d75cd:  b8 00 40              loc_d75cd:           mov        ax, 4000h
d75d0:  8e c0                                      mov        es, ax
d75d2:  26 c4 1e 50 11                             les        bx, es:[1150h] ; display_buf_ptr1 - Display buffer pointer 1 (current read position)
d75d7:  26 8a 07                                   mov        al, es:[bx]
d75da:  ba 3c 41                                   mov        dx, 413ch
d75dd:  8e c2                                      mov        es, dx
d75df:  26 a2 d6 00                                mov        es:[00d6h], al
d75e3:  b8 3c 41                                   mov        ax, 413ch
d75e6:  8e c0                                      mov        es, ax
d75e8:  26 80 3e d6 00 00                          cmp        byte es:[00d6h], 00h ; last_switch_code - Last switch code received from Z80
d75ee:  75 0e                                      jnz        loc_d75fe
d75f0:  b8 00 40                                   mov        ax, 4000h
d75f3:  8e c0                                      mov        es, ax
d75f5:  26 c6 06 47 11 00                          mov        byte es:[1147h], 00h ; switch_event_pending - Non-zero when Z80 has written a new switch event
d75fb:  e9 15 ff                                   jmp        loc_d7513

;  XREF: d75ee
d75fe:  b8 00 40              loc_d75fe:           mov        ax, 4000h
d7601:  8e c0                                      mov        es, ax
d7603:  26 c4 1e 50 11                             les        bx, es:[1150h] ; display_buf_ptr1 - Display buffer pointer 1 (current read position)
d7608:  26 c6 07 00                                mov        byte es:[bx], 00h
d760c:  8e c0                                      mov        es, ax
d760e:  26 a1 52 11                                mov        ax, es:[1152h] ; display_buf_seg1 - Display buffer segment 1
d7612:  26 8b 16 50 11                             mov        dx, es:[1150h] ; display_buf_ptr1 - Display buffer pointer 1 (current read position)
d7617:  42                                         inc        dx
d7618:  bb 00 40                                   mov        bx, 4000h
d761b:  8e c3                                      mov        es, bx
d761d:  26 a3 52 11                                mov        es:[1152h], ax ; display_buf_seg1 - Display buffer segment 1
d7621:  26 89 16 50 11                             mov        es:[1150h], dx
d7626:  0e                                         push       cs
d7627:  e8 21 fd                                   call       dmd_anim_set_callback
d762a:  0b c0                                      or         ax, ax
d762c:  74 03                                      jz         loc_d7631
d762e:  e9 e2 fe                                   jmp        loc_d7513

;  XREF: d762c
d7631:  b8 01 00              loc_d7631:           mov        ax, 0001h

;  XREF: d7515
d7634:  1f                    loc_d7634:           pop        ds
d7635:  cb                                         retf

;  XREF: d31ac, d7d84

; -----------------------------------------------------------------------------
; dmd_clear_screen (0xD7636)
; Clear DMD screen/buffer (2 refs)
; -----------------------------------------------------------------------------
d7636:  1e                    dmd_clear_screen:           push       ds
d7637:  b8 34 41                                   mov        ax, 4134h
d763a:  8e d8                                      mov        ds, ax
d763c:  0e                                         push       cs
d763d:  e8 13 fe                                   call       dmd_score_display
d7640:  0b c0                                      or         ax, ax
d7642:  75 03                                      jnz        loc_d7647
d7644:  e9 7c 01                                   jmp        loc_d77c3

;  XREF: d7642
d7647:  b8 3c 41              loc_d7647:           mov        ax, 413ch
d764a:  8e c0                                      mov        es, ax
d764c:  26 a0 d6 00                                mov        al, es:[00d6h] ; last_switch_code - Last switch code received from Z80
d7650:  b4 00                                      mov        ah, 00h
d7652:  2d 0e 00                                   sub        ax, 000eh
d7655:  8b d8                                      mov        bx, ax
d7657:  83 fb 36                                   cmp        word bx, 36h
d765a:  76 03                                      jbe        loc_d765f
d765c:  e9 64 01                                   jmp        loc_d77c3

;  XREF: d765a
d765f:  d1 e3                 loc_d765f:           shl        bx, 1
d7661:  2e ff a7 27 05                             jmp        cs:[bx+0527h]

;  XREF: d7644, d765c
d77c3:  33 c0                 loc_d77c3:           xor        ax, ax
d77c5:  1f                                         pop        ds
d77c6:  cb                                         retf

;  XREF: dc7c6, dc8ed

; -----------------------------------------------------------------------------
; dmd_effect_wipe (0xD7835)
; DMD wipe/transition effect (2 refs)
; -----------------------------------------------------------------------------
d7835:  1e                    dmd_effect_wipe:           push       ds
d7836:  b8 34 41                                   mov        ax, 4134h
d7839:  8e d8                                      mov        ds, ax
d783b:  b8 3c 41                                   mov        ax, 413ch
d783e:  8e c0                                      mov        es, ax
d7840:  26 a0 d6 00                                mov        al, es:[00d6h] ; last_switch_code - Last switch code received from Z80
d7844:  b4 00                                      mov        ah, 00h
d7846:  2d 0e 00                                   sub        ax, 000eh
d7849:  8b d8                                      mov        bx, ax
d784b:  83 fb 36                                   cmp        word bx, 36h
d784e:  76 03                                      jbe        loc_d7853
d7850:  e9 4d 01                                   jmp        loc_d79a0

;  XREF: d784e
d7853:  d1 e3                 loc_d7853:           shl        bx, 1
d7855:  2e ff a7 04 07                             jmp        cs:[bx+0704h]

;  XREF: d7850
d79a0:  33 c0                 loc_d79a0:           xor        ax, ax
d79a2:  1f                                         pop        ds
d79a3:  cb                                         retf

;  XREF: dc79b

; -----------------------------------------------------------------------------
; dmd_scroll_text (0xD7A12)
; Scrolling text display on DMD
; -----------------------------------------------------------------------------
d7a12:  1e                    dmd_scroll_text:           push       ds
d7a13:  b8 34 41                                   mov        ax, 4134h
d7a16:  8e d8                                      mov        ds, ax
d7a18:  0e                                         push       cs
d7a19:  e8 37 fa                                   call       dmd_score_display
d7a1c:  0b c0                                      or         ax, ax
d7a1e:  75 02                                      jnz        loc_d7a22
d7a20:  eb 28                                      jmp short  loc_d7a4a

;  XREF: d7a1e
d7a22:  b8 3c 41              loc_d7a22:           mov        ax, 413ch
d7a25:  8e c0                                      mov        es, ax
d7a27:  26 a0 d6 00                                mov        al, es:[00d6h] ; last_switch_code - Last switch code received from Z80
d7a2b:  b4 00                                      mov        ah, 00h
d7a2d:  2d 0e 00                                   sub        ax, 000eh
d7a30:  8b d8                                      mov        bx, ax
d7a32:  83 fb 36                                   cmp        word bx, 36h
d7a35:  77 13                                      ja         loc_d7a4a
d7a37:  d1 e3                                      shl        bx, 1
d7a39:  2e ff a7 ae 07                             jmp        cs:[bx+07aeh]

;  XREF: d7a20, d7a35
d7a4a:  33 c0                 loc_d7a4a:           xor        ax, ax
d7a4c:  1f                                         pop        ds
d7a4d:  cb                                         retf

;  XREF: d305d, d32f0, d339a

; -----------------------------------------------------------------------------
; dmd_attract_cycle (0xD7ABC)
; DMD attract mode display cycle (3 refs)
; -----------------------------------------------------------------------------
d7abc:  1e                    dmd_attract_cycle:           push       ds
d7abd:  b8 34 41                                   mov        ax, 4134h
d7ac0:  8e d8                                      mov        ds, ax
d7ac2:  0e                                         push       cs
d7ac3:  e8 39 fa                                   call       dmd_text_display
d7ac6:  0b c0                                      or         ax, ax
d7ac8:  74 47                                      jz         loc_d7b11
d7aca:  b8 3c 41                                   mov        ax, 413ch
d7acd:  8e c0                                      mov        es, ax
d7acf:  26 a0 d6 00                                mov        al, es:[00d6h] ; last_switch_code - Last switch code received from Z80
d7ad3:  b4 00                                      mov        ah, 00h
d7ad5:  3d 3f 00                                   cmp        ax, 003fh     ; Switch: R_Flipper_Button
d7ad8:  74 0c                                      jz         loc_d7ae6
d7ada:  3d 40 00                                   cmp        ax, 0040h     ; Switch: Upper_Flipper_Button
d7add:  75 32                                      jnz        loc_d7b11
d7adf:  9a c6 0d 2a d7                             call       dmd_anim_sequence_play
d7ae4:  eb 2d                                      jmp short  loc_d7b13

;  XREF: d7ad8
d7ae6:  9a 03 00 25 dd        loc_d7ae6:           call       game_mode_transition
d7aeb:  b8 3c 41                                   mov        ax, 413ch
d7aee:  8e c0                                      mov        es, ax
d7af0:  26 80 3e d4 00 00                          cmp        byte es:[00d4h], 00h ; credit_available - Non-zero when credits are available for game start
d7af6:  74 08                                      jz         loc_d7b00
d7af8:  6a 5d                                      push       5dh
d7afa:  9a 38 01 00 d0                             call       cmd_queue_push
d7aff:  59                                         pop        cx

;  XREF: d7af6
d7b00:  6a 28                 loc_d7b00:           push       28h
d7b02:  9a e8 26 f2 d2                             call       switch_read_shared_ram
d7b07:  59                                         pop        cx
d7b08:  0e                                         push       cs
d7b09:  e8 e6 f7                                   call       dmd_anim_frame_advance
d7b0c:  b8 01 00                                   mov        ax, 0001h
d7b0f:  eb 02                                      jmp short  loc_d7b13

;  XREF: d7ac8, d7add
d7b11:  33 c0                 loc_d7b11:           xor        ax, ax

;  XREF: d7ae4, d7b0f
d7b13:  1f                    loc_d7b13:           pop        ds
d7b14:  cb                                         retf

;  XREF: da20a

; -----------------------------------------------------------------------------
; button_filter_accept_start (0xD7B47)
; Button filter: accepts only switches 0x40 (upper flipper), 0x41 (START), 0x42 (coin). Used in game-end wait
; -----------------------------------------------------------------------------
d7b47:  1e                    button_filter_accept_start:           push       ds
d7b48:  b8 34 41                                   mov        ax, 4134h
d7b4b:  8e d8                                      mov        ds, ax
d7b4d:  0e                                         push       cs
d7b4e:  e8 02 f9                                   call       dmd_score_display
d7b51:  0b c0                                      or         ax, ax
d7b53:  74 21                                      jz         loc_d7b76
d7b55:  b8 3c 41                                   mov        ax, 413ch
d7b58:  8e c0                                      mov        es, ax
d7b5a:  26 a0 d6 00                                mov        al, es:[00d6h] ; last_switch_code - Last switch code received from Z80
d7b5e:  b4 00                                      mov        ah, 00h
d7b60:  3d 40 00                                   cmp        ax, 0040h     ; Switch: Upper_Flipper_Button
d7b63:  74 0a                                      jz         loc_d7b6f
d7b65:  3d 41 00                                   cmp        ax, 0041h     ; Switch: START_Button
d7b68:  74 05                                      jz         loc_d7b6f
d7b6a:  3d 42 00                                   cmp        ax, 0042h     ; Switch: Coin_Input
d7b6d:  75 07                                      jnz        loc_d7b76

;  XREF: d7b63, d7b68
d7b6f:  b8 01 00              loc_d7b6f:           mov        ax, 0001h
d7b72:  eb 04                                      jmp short  loc_d7b78

;  XREF: d7b53, d7b6d
d7b76:  33 c0                 loc_d7b76:           xor        ax, ax

;  XREF: d7b72
d7b78:  1f                    loc_d7b78:           pop        ds
d7b79:  cb                                         retf

;  XREF: dc831

; -----------------------------------------------------------------------------
; dmd_anim_resource_play (0xD7B7A)
; Play DMD animation from resource ID
; -----------------------------------------------------------------------------
d7b7a:  1e                    dmd_anim_resource_play:           push       ds
d7b7b:  b8 34 41                                   mov        ax, 4134h
d7b7e:  8e d8                                      mov        ds, ax
d7b80:  0e                                         push       cs
d7b81:  e8 7b f9                                   call       dmd_text_display
d7b84:  0b c0                                      or         ax, ax
d7b86:  75 02                                      jnz        loc_d7b8a
d7b88:  eb 2f                                      jmp short  loc_d7bb9

;  XREF: d7b86
d7b8a:  b8 3c 41              loc_d7b8a:           mov        ax, 413ch
d7b8d:  8e c0                                      mov        es, ax
d7b8f:  26 a0 d6 00                                mov        al, es:[00d6h] ; last_switch_code - Last switch code received from Z80
d7b93:  b4 00                                      mov        ah, 00h
d7b95:  2d 0e 00                                   sub        ax, 000eh
d7b98:  8b d8                                      mov        bx, ax
d7b9a:  83 fb 36                                   cmp        word bx, 36h
d7b9d:  77 1a                                      ja         loc_d7bb9
d7b9f:  d1 e3                                      shl        bx, 1
d7ba1:  2e ff a7 1d 09                             jmp        cs:[bx+091dh]

;  XREF: d7b88, d7b9d
d7bb9:  33 c0                 loc_d7bb9:           xor        ax, ax
d7bbb:  1f                                         pop        ds
d7bbc:  cb                                         retf

;  XREF: d5653

; -----------------------------------------------------------------------------
; switch_dispatch_table_lookup (0xD7C2B)
; Look up switch code in dispatch table
; -----------------------------------------------------------------------------
d7c2b:  c8 02 00 00           switch_dispatch_table_lookup:           enter      0002h, 00h
d7c2f:  1e                                         push       ds
d7c30:  b8 34 41                                   mov        ax, 4134h
d7c33:  8e d8                                      mov        ds, ax
d7c35:  c6 06 14 00 00                             mov        byte [0014h], 00h
d7c3a:  b8 00 40                                   mov        ax, 4000h
d7c3d:  8e c0                                      mov        es, ax
d7c3f:  26 a0 47 11                                mov        al, es:[1147h] ; switch_event_pending - Non-zero when Z80 has written a new switch event
d7c43:  98                                         cbw
d7c44:  0b c0                                      or         ax, ax
d7c46:  75 03                                      jnz        loc_d7c4b
d7c48:  e9 3c 01                                   jmp        loc_d7d87

;  XREF: d7c46
d7c4b:  b8 00 40              loc_d7c4b:           mov        ax, 4000h
d7c4e:  8e c0                                      mov        es, ax
d7c50:  26 80 3e 44 11 00                          cmp        byte es:[1144h], 00h
d7c56:  74 18                                      jz         loc_d7c70
d7c58:  9a 6a 0d 2a d7                             call       dmd_score_format
d7c5d:  b8 00 40                                   mov        ax, 4000h
d7c60:  8e c0                                      mov        es, ax
d7c62:  26 c6 06 47 11 01                          mov        byte es:[1147h], 01h ; switch_event_pending - Non-zero when Z80 has written a new switch event
d7c68:  9a 89 5a 2a d7                             call       credits_display_check
d7c6d:  e9 17 01                                   jmp        loc_d7d87

;  XREF: d7c56
d7c70:  b8 00 40              loc_d7c70:           mov        ax, 4000h
d7c73:  8e c0                                      mov        es, ax
d7c75:  26 c4 1e 50 11                             les        bx, es:[1150h] ; display_buf_ptr1 - Display buffer pointer 1 (current read position)
d7c7a:  26 8a 07                                   mov        al, es:[bx]
d7c7d:  a2 14 00                                   mov        [0014h], al
d7c80:  80 3e 14 00 00                             cmp        byte [0014h], 00h
d7c85:  75 0e                                      jnz        loc_d7c95
d7c87:  b8 00 40                                   mov        ax, 4000h
d7c8a:  8e c0                                      mov        es, ax
d7c8c:  26 c6 06 47 11 00                          mov        byte es:[1147h], 00h ; switch_event_pending - Non-zero when Z80 has written a new switch event
d7c92:  e9 f2 00                                   jmp        loc_d7d87

;  XREF: d7c85
d7c95:  0e                    loc_d7c95:           push       cs
d7c96:  e8 30 f7                                   call       dmd_anim_wait_complete
d7c99:  0b c0                                      or         ax, ax
d7c9b:  74 06                                      jz         loc_d7ca3
d7c9d:  b8 01 00                                   mov        ax, 0001h
d7ca0:  e9 e6 00                                   jmp        loc_d7d89

;  XREF: d7c9b
d7ca3:  a0 14 00              loc_d7ca3:           mov        al, [0014h]
d7ca6:  b4 00                                      mov        ah, 00h
d7ca8:  89 46 fe                                   mov        [bp-02h], ax
d7cab:  b9 0c 00                                   mov        cx, 000ch
d7cae:  bb ec 0a                                   mov        bx, 0aech

;  XREF: d7cbc
d7cb1:  2e 8b 07              loc_d7cb1:           mov        ax, cs:[bx]
d7cb4:  3b 46 fe                                   cmp        ax, [bp-02h]
d7cb7:  74 08                                      jz         loc_d7cc1
d7cb9:  83 c3 02                                   add        word bx, 02h
d7cbc:  e2 f3                                      loop       loc_d7cb1
d7cbe:  e9 c2 00                                   jmp        loc_d7d83

;  XREF: d7cb7
d7cc1:  2e ff 67 18           loc_d7cc1:           jmp        cs:[bx+18h]

;  XREF: d7cbe
d7d83:  0e                    loc_d7d83:           push       cs
d7d84:  e8 af f8                                   call       dmd_clear_screen

;  XREF: d7c48, d7c6d, d7c92
d7d87:  33 c0                 loc_d7d87:           xor        ax, ax

;  XREF: d7ca0
d7d89:  1f                    loc_d7d89:           pop        ds
d7d8a:  c9                                         leave
d7d8b:  cb                                         retf

;  XREF: d7485, d7534, d7c58

; -----------------------------------------------------------------------------
; dmd_score_format (0xD800A)
; Format score value for DMD display (3 refs)
; -----------------------------------------------------------------------------
d800a:  1e                    dmd_score_format:           push       ds
d800b:  b8 34 41                                   mov        ax, 4134h
d800e:  8e d8                                      mov        ds, ax
d8010:  b8 3c 41                                   mov        ax, 413ch
d8013:  8e c0                                      mov        es, ax
d8015:  26 a0 d5 00                                mov        al, es:[00d5h]
d8019:  ba 00 40                                   mov        dx, 4000h
d801c:  8e c2                                      mov        es, dx
d801e:  26 02 06 44 11                             add        al, es:[1144h]
d8023:  ba 3c 41                                   mov        dx, 413ch
d8026:  8e c2                                      mov        es, dx
d8028:  26 a2 d5 00                                mov        es:[00d5h], al
d802c:  b8 00 40                                   mov        ax, 4000h
d802f:  8e c0                                      mov        es, ax
d8031:  26 c6 06 44 11 00                          mov        byte es:[1144h], 00h
d8037:  b8 3c 41                                   mov        ax, 413ch
d803a:  8e c0                                      mov        es, ax
d803c:  26 a0 d5 00                                mov        al, es:[00d5h]
d8040:  a2 35 00                                   mov        [0035h], al
d8043:  b8 00 40                                   mov        ax, 4000h
d8046:  8e c0                                      mov        es, ax
d8048:  26 80 3e 01 10 05                          cmp        byte es:[1001h], 05h ; game_status_byte - Overall game status communicated to Z80
d804e:  75 07                                      jnz        loc_d8057
d8050:  9a fe 5a 2a d7                             call       credits_award_free_game
d8055:  eb 05                                      jmp short  loc_d805c

;  XREF: d804e
d8057:  9a 9d 5d 2a d7        loc_d8057:           call       eeprom_high_score_write

;  XREF: d8055
d805c:  c6 06 35 00 00        loc_d805c:           mov        byte [0035h], 00h
d8061:  b8 01 00                                   mov        ax, 0001h
d8064:  1f                                         pop        ds
d8065:  cb                                         retf

;  XREF: d7adf, dc06e, dc106

; -----------------------------------------------------------------------------
; dmd_anim_sequence_play (0xD8066)
; Play animation sequence from ROM data (3 refs)
; -----------------------------------------------------------------------------
d8066:  1e                    dmd_anim_sequence_play:           push       ds
d8067:  b8 34 41                                   mov        ax, 4134h
d806a:  8e d8                                      mov        ds, ax
d806c:  6a 40                                      push       40h
d806e:  0e                                         push       cs
d806f:  e8 38 f2                                   call       dmd_anim_play
d8072:  59                                         pop        cx
d8073:  b8 3c 41                                   mov        ax, 413ch
d8076:  8e c0                                      mov        es, ax
d8078:  26 80 3e 4f 01 01                          cmp        byte es:[014fh], 01h ; game_state_var - STATE MACHINE variable: 0=init, 1=attract, 2=game_active, 4=special_mode
d807e:  75 0a                                      jnz        loc_d808a
d8080:  9a 75 37 2a d7                             call       dmd_anim_chain

;  XREF: d8095
d8085:  33 c0                 loc_d8085:           xor        ax, ax
d8087:  e9 c8 00                                   jmp        loc_d8152

;  XREF: d807e
d808a:  b8 3c 41              loc_d808a:           mov        ax, 413ch
d808d:  8e c0                                      mov        es, ax
d808f:  26 80 3e d7 00 04                          cmp        byte es:[00d7h], 04h ; game_flag_1 - General game flag 1
d8095:  73 ee                                      jnb        loc_d8085
d8097:  b8 3c 41                                   mov        ax, 413ch
d809a:  8e c0                                      mov        es, ax
d809c:  26 80 3e d4 00 00                          cmp        byte es:[00d4h], 00h ; credit_available - Non-zero when credits are available for game start
d80a2:  75 2d                                      jnz        loc_d80d1
d80a4:  9a de 0f 00 f0                             call       ram_test
d80a9:  b8 3c 41                                   mov        ax, 413ch
d80ac:  8e c0                                      mov        es, ax
d80ae:  26 c6 06 de 00 00                          mov        byte es:[00deh], 00h
d80b4:  6a 5e                                      push       5eh
d80b6:  9a 38 01 00 d0                             call       cmd_queue_push
d80bb:  59                                         pop        cx
d80bc:  6a 01                                      push       01h
d80be:  9a f5 0d 00 f0                             call       dmd_effect_flash
d80c3:  59                                         pop        cx
d80c4:  b8 3c 41                                   mov        ax, 413ch
d80c7:  8e c0                                      mov        es, ax
d80c9:  26 c6 06 e0 00 01                          mov        byte es:[00e0h], 01h
d80cf:  eb 7e                                      jmp short  loc_d814f

;  XREF: d80a2
d80d1:  9a 14 05 00 d0        loc_d80d1:           call       display_set_position_16refs
d80d6:  fe c8                                      dec        byte al
d80d8:  50                                         push       ax
d80d9:  9a d2 04 00 d0                             call       display_write_word_12refs
d80de:  59                                         pop        cx
d80df:  9a 14 05 00 d0                             call       display_set_position_16refs
d80e4:  50                                         push       ax
d80e5:  9a 49 05 00 d0                             call       display_set_segment_14refs
d80ea:  5a                                         pop        dx
d80eb:  02 d0                                      add        dl, al
d80ed:  b8 3c 41                                   mov        ax, 413ch
d80f0:  8e c0                                      mov        es, ax
d80f2:  26 88 16 d4 00                             mov        es:[00d4h], dl ; credit_available - Non-zero when credits are available for game start
d80f7:  b8 3c 41                                   mov        ax, 413ch
d80fa:  8e c0                                      mov        es, ax
d80fc:  26 fe 06 d7 00                             inc        byte es:[00d7h] ; game_flag_1 - General game flag 1
d8101:  b8 3c 41                                   mov        ax, 413ch
d8104:  8e c0                                      mov        es, ax
d8106:  26 80 3e d4 00 00                          cmp        byte es:[00d4h], 00h ; credit_available - Non-zero when credits are available for game start
d810c:  74 0d                                      jz         loc_d811b
d810e:  b8 3c 41                                   mov        ax, 413ch
d8111:  8e c0                                      mov        es, ax
d8113:  26 80 3e d7 00 04                          cmp        byte es:[00d7h], 04h ; game_flag_1 - General game flag 1
d8119:  75 18                                      jnz        loc_d8133

;  XREF: d810c
d811b:  9a de 0f 00 f0        loc_d811b:           call       ram_test
d8120:  b8 3c 41                                   mov        ax, 413ch
d8123:  8e c0                                      mov        es, ax
d8125:  26 c6 06 de 00 00                          mov        byte es:[00deh], 00h
d812b:  6a 5e                                      push       5eh
d812d:  9a 38 01 00 d0                             call       cmd_queue_push
d8132:  59                                         pop        cx

;  XREF: d8119
d8133:  b8 3c 41              loc_d8133:           mov        ax, 413ch
d8136:  8e c0                                      mov        es, ax
d8138:  26 80 3e d7 00 01                          cmp        byte es:[00d7h], 01h ; game_flag_1 - General game flag 1
d813e:  75 07                                      jnz        loc_d8147
d8140:  9a b4 0e 2a d7                             call       dmd_anim_helper
d8145:  eb 08                                      jmp short  loc_d814f

;  XREF: d813e
d8147:  6a 00                 loc_d8147:           push       00h
d8149:  9a fa 0f 00 f0                             call       rom_checksum_verify
d814e:  59                                         pop        cx

;  XREF: d80cf, d8145
d814f:  b8 01 00              loc_d814f:           mov        ax, 0001h

;  XREF: d8087
d8152:  1f                    loc_d8152:           pop        ds
d8153:  cb                                         retf

;  XREF: d8140

; -----------------------------------------------------------------------------
; dmd_anim_helper (0xD8154)
; Animation helper routine
; -----------------------------------------------------------------------------
d8154:  1e                    dmd_anim_helper:           push       ds
d8155:  b8 34 41                                   mov        ax, 4134h
d8158:  8e d8                                      mov        ds, ax
d815a:  b8 3c 41                                   mov        ax, 413ch
d815d:  8e c0                                      mov        es, ax
d815f:  26 c6 06 4f 01 03                          mov        byte es:[014fh], 03h ; game_state_var - STATE MACHINE variable: 0=init, 1=attract, 2=game_active, 4=special_mode
d8165:  68 40 50                                   push       5040h
d8168:  68 18 01                                   push       0118h
d816b:  9a 92 04 00 d0                             call       display_set_animation_29refs
d8170:  83 c4 04                                   add        word sp, 04h
d8173:  05 01 00                                   add        ax, 0001h
d8176:  83 d2 00                                   adc        word dx, 00h
d8179:  52                                         push       dx
d817a:  50                                         push       ax
d817b:  68 40 50                                   push       5040h
d817e:  68 18 01                                   push       0118h
d8181:  9a 6d 04 00 d0                             call       display_write_param_25refs
d8186:  83 c4 08                                   add        word sp, 08h
d8189:  9a f2 37 2a d7                             call       game_init_display
d818e:  68 81 00                                   push       0081h
d8191:  9a 70 0b 00 d0                             call       timer_delay
d8196:  59                                         pop        cx
d8197:  68 8f 00                                   push       008fh
d819a:  9a 70 0b 00 d0                             call       timer_delay
d819f:  59                                         pop        cx
d81a0:  9a 4d 17 00 f0                             call       game_end_transition_to_attract
d81a5:  68 c3 00                                   push       00c3h
d81a8:  9a 38 01 00 d0                             call       cmd_queue_push
d81ad:  59                                         pop        cx
d81ae:  68 ab 00                                   push       00abh
d81b1:  9a 38 01 00 d0                             call       cmd_queue_push
d81b6:  59                                         pop        cx
d81b7:  1f                                         pop        ds
d81b8:  cb                                         retf

;  XREF: dc2ef, dc2f3, dc2f7

; -----------------------------------------------------------------------------
; lamp_group_set (0xD92C0)
; Set lamp group state (3 refs from DC2xx)
; -----------------------------------------------------------------------------
d92c0:  1e                    lamp_group_set:           push       ds
d92c1:  b8 34 41                                   mov        ax, 4134h
d92c4:  8e d8                                      mov        ds, ax
d92c6:  80 3e 2b 00 00                             cmp        byte [002bh], 00h
d92cb:  7f 03                                      jg         loc_d92d0
d92cd:  e9 b9 00                                   jmp        loc_d9389

;  XREF: d92cb
d92d0:  a0 2b 00              loc_d92d0:           mov        al, [002bh]
d92d3:  fe c8                                      dec        byte al
d92d5:  a2 2b 00                                   mov        [002bh], al
d92d8:  80 3e 2b 00 00                             cmp        byte [002bh], 00h
d92dd:  74 03                                      jz         loc_d92e2
d92df:  e9 cb 00                                   jmp        loc_d93ad

;  XREF: d92dd
d92e2:  68 bc 00              loc_d92e2:           push       00bch
d92e5:  9a 38 01 00 d0                             call       cmd_queue_push
d92ea:  59                                         pop        cx
d92eb:  6a 1f                                      push       1fh
d92ed:  9a 94 56 2a d7                             call       game_var_indexed_write
d92f2:  59                                         pop        cx
d92f3:  6a 0f                                      push       0fh
d92f5:  9a 94 56 2a d7                             call       game_var_indexed_write
d92fa:  59                                         pop        cx
d92fb:  c6 06 22 00 00                             mov        byte [0022h], 00h
d9300:  c6 06 30 00 00                             mov        byte [0030h], 00h
d9305:  b8 3c 41                                   mov        ax, 413ch
d9308:  8e c0                                      mov        es, ax
d930a:  26 c6 06 fa 00 00                          mov        byte es:[00fah], 00h
d9310:  b8 3c 41                                   mov        ax, 413ch
d9313:  8e c0                                      mov        es, ax
d9315:  26 80 3e d8 00 00                          cmp        byte es:[00d8h], 00h
d931b:  74 08                                      jz         loc_d9325
d931d:  8e c0                                      mov        es, ax
d931f:  26 c6 06 d8 00 00                          mov        byte es:[00d8h], 00h

;  XREF: d931b
d9325:  b8 3c 41              loc_d9325:           mov        ax, 413ch
d9328:  8e c0                                      mov        es, ax
d932a:  26 c6 06 02 01 00                          mov        byte es:[0102h], 00h
d9330:  68 f2 00                                   push       00f2h
d9333:  9a 38 01 00 d0                             call       cmd_queue_push
d9338:  59                                         pop        cx
d9339:  c6 06 06 00 26                             mov        byte [0006h], 26h
d933e:  eb 15                                      jmp short  loc_d9355

;  XREF: d935a
d9340:  a0 06 00              loc_d9340:           mov        al, [0006h]
d9343:  98                                         cbw
d9344:  ba 3c 41                                   mov        dx, 413ch
d9347:  8b d8                                      mov        bx, ax
d9349:  8e c2                                      mov        es, dx
d934b:  26 c6 87 04 01 01                          mov        byte es:[bx+0104h], 01h
d9351:  fe 06 06 00                                inc        byte [0006h]

;  XREF: d933e
d9355:  80 3e 06 00 2b        loc_d9355:           cmp        byte [0006h], 2bh
d935a:  7e e4                                      jle        loc_d9340
d935c:  6a 24                                      push       24h
d935e:  9a 38 01 00 d0                             call       cmd_queue_push
d9363:  59                                         pop        cx
d9364:  6a 03                                      push       03h
d9366:  9a da 56 2a d7                             call       game_var_increment
d936b:  59                                         pop        cx
d936c:  b8 3c 41                                   mov        ax, 413ch
d936f:  8e c0                                      mov        es, ax
d9371:  26 c6 06 0d 01 01                          mov        byte es:[010dh], 01h
d9377:  8e c0                                      mov        es, ax
d9379:  26 c6 06 06 01 01                          mov        byte es:[0106h], 01h
d937f:  6a 02                                      push       02h
d9381:  9a da 56 2a d7                             call       game_var_increment
d9386:  59                                         pop        cx
d9387:  eb 24                                      jmp short  loc_d93ad

;  XREF: d92cd
d9389:  68 bc 00              loc_d9389:           push       00bch
d938c:  9a 38 01 00 d0                             call       cmd_queue_push
d9391:  59                                         pop        cx
d9392:  68 f4 00                                   push       00f4h
d9395:  9a 38 01 00 d0                             call       cmd_queue_push
d939a:  59                                         pop        cx
d939b:  6a 43                                      push       43h
d939d:  0e                                         push       cs
d939e:  e8 09 df                                   call       dmd_anim_play
d93a1:  59                                         pop        cx
d93a2:  b8 3c 41                                   mov        ax, 413ch
d93a5:  8e c0                                      mov        es, ax
d93a7:  26 c6 06 eb 00 01                          mov        byte es:[00ebh], 01h

;  XREF: d92df, d9387
d93ad:  b8 01 00              loc_d93ad:           mov        ax, 0001h
d93b0:  1f                                         pop        ds
d93b1:  cb                                         retf

;  XREF: dbe20, dbf88

; -----------------------------------------------------------------------------
; lamp_pattern_sequence (0xD95B0)
; Execute lamp pattern sequence (2 refs)
; -----------------------------------------------------------------------------
d95b0:  1e                    lamp_pattern_sequence:           push       ds
d95b1:  b8 34 41                                   mov        ax, 4134h
d95b4:  8e d8                                      mov        ds, ax
d95b6:  80 3e 2e 00 09                             cmp        byte [002eh], 09h
d95bb:  72 07                                      jb         loc_d95c4
d95bd:  c6 06 2e 00 00                             mov        byte [002eh], 00h
d95c2:  eb 0a                                      jmp short  loc_d95ce

;  XREF: d95bb
d95c4:  a0 2e 00              loc_d95c4:           mov        al, [002eh]
d95c7:  a2 2e 00                                   mov        [002eh], al
d95ca:  fe 06 2e 00                                inc        byte [002eh]

;  XREF: d95c2
d95ce:  80 3e 2e 00 02        loc_d95ce:           cmp        byte [002eh], 02h
d95d3:  75 11                                      jnz        loc_d95e6
d95d5:  b8 3c 41                                   mov        ax, 413ch
d95d8:  8e c0                                      mov        es, ax
d95da:  26 80 3e 02 01 06                          cmp        byte es:[0102h], 06h
d95e0:  73 04                                      jnb        loc_d95e6
d95e2:  fe 06 2e 00                                inc        byte [002eh]

;  XREF: d95d3, d95e0
d95e6:  a0 2e 00              loc_d95e6:           mov        al, [002eh]
d95e9:  b4 00                                      mov        ah, 00h
d95eb:  8b d8                                      mov        bx, ax
d95ed:  83 fb 09                                   cmp        word bx, 09h
d95f0:  76 03                                      jbe        loc_d95f5
d95f2:  e9 29 01                                   jmp        loc_d971e

;  XREF: d95f0
d95f5:  d1 e3                 loc_d95f5:           shl        bx, 1
d95f7:  2e ff a7 85 24                             jmp        cs:[bx+2485h]

;  XREF: d95f2
d971e:  c6 06 2d 00 00        loc_d971e:           mov        byte [002dh], 00h
d9723:  1f                                         pop        ds
d9724:  cb                                         retf

;  XREF: da1ed

; -----------------------------------------------------------------------------
; dmd_match_digit_draw (0xD9F7D)
; Draw match/lottery digit on DMD
; -----------------------------------------------------------------------------
d9f7d:  55                    dmd_match_digit_draw:           push       bp
d9f7e:  8b ec                                      mov        bp, sp
d9f80:  1e                                         push       ds
d9f81:  b8 34 41                                   mov        ax, 4134h
d9f84:  8e d8                                      mov        ds, ax
d9f86:  6a 00                                      push       00h
d9f88:  9a b4 0d 00 d0                             call       game_mode_set
d9f8d:  59                                         pop        cx

;  XREF: d9f99
d9f8e:  b8 00 40              loc_d9f8e:           mov        ax, 4000h
d9f91:  8e c0                                      mov        es, ax
d9f93:  26 80 3e ee 12 00                          cmp        byte es:[12eeh], 00h
d9f99:  75 f3                                      jnz        loc_d9f8e
d9f9b:  6a 05                                      push       05h
d9f9d:  9a b4 0d 00 d0                             call       game_mode_set
d9fa2:  59                                         pop        cx
d9fa3:  c6 06 2a 00 01                             mov        byte [002ah], 01h
d9fa8:  9a eb 17 00 f0                             call       memory_clear_range

;  XREF: d9fb8
d9fad:  b8 00 40              loc_d9fad:           mov        ax, 4000h
d9fb0:  8e c0                                      mov        es, ax
d9fb2:  26 80 3e f1 10 00                          cmp        byte es:[10f1h], 00h
d9fb8:  75 f3                                      jnz        loc_d9fad
d9fba:  9a 02 01 00 f0                             call       memory_block_copy
d9fbf:  b8 00 40                                   mov        ax, 4000h
d9fc2:  8e c0                                      mov        es, ax
d9fc4:  26 80 3e 01 10 05                          cmp        byte es:[1001h], 05h ; game_status_byte - Overall game status communicated to Z80
d9fca:  75 11                                      jnz        loc_d9fdd
d9fcc:  b8 00 30                                   mov        ax, 3000h
d9fcf:  8e c0                                      mov        es, ax
d9fd1:  26 ff 36 02 00                             push       word es:[0002h]
d9fd6:  26 ff 36 00 00                             push       word es:[0000h]
d9fdb:  eb 0f                                      jmp short  loc_d9fec

;  XREF: d9fca
d9fdd:  b8 00 10              loc_d9fdd:           mov        ax, 1000h
d9fe0:  8e c0                                      mov        es, ax
d9fe2:  26 ff 36 02 00                             push       word es:[0002h]
d9fe7:  26 ff 36 00 00                             push       word es:[0000h]

;  XREF: d9fdb
d9fec:  6a 02                 loc_d9fec:           push       02h
d9fee:  6a 11                                      push       11h
d9ff0:  9a 01 07 00 f0                             call       dmd_text_render
d9ff5:  83 c4 08                                   add        word sp, 08h
d9ff8:  8a 46 06                                   mov        al, [bp+06h]
d9ffb:  98                                         cbw
d9ffc:  48                                         dec        ax
d9ffd:  8b d8                                      mov        bx, ax
d9fff:  83 fb 03                                   cmp        word bx, 03h
da002:  76 03                                      jbe        loc_da007
da004:  e9 d3 00                                   jmp        loc_da0da

;  XREF: da002
da007:  d1 e3                 loc_da007:           shl        bx, 1
da009:  2e ff a7 f5 2e                             jmp        cs:[bx+2ef5h]

;  XREF: da004
da0da:  c6 06 05 00 0b        loc_da0da:           mov        byte [0005h], 0bh
da0df:  c6 06 04 00 00                             mov        byte [0004h], 00h
da0e4:  c6 06 00 00 00                             mov        byte [0000h], 00h
da0e9:  b8 00 40                                   mov        ax, 4000h
da0ec:  8e c0                                      mov        es, ax
da0ee:  26 c7 06 3d 11 05 00                       mov        word es:[113dh], 0005h
da0f5:  68 c8 00                                   push       00c8h
da0f8:  9a 38 01 00 d0                             call       cmd_queue_push
da0fd:  59                                         pop        cx
da0fe:  68 c5 00                                   push       00c5h
da101:  9a 38 01 00 d0                             call       cmd_queue_push
da106:  59                                         pop        cx
da107:  b8 3c 41                                   mov        ax, 413ch
da10a:  8e c0                                      mov        es, ax
da10c:  26 c6 06 c6 00 07                          mov        byte es:[00c6h], 07h
da112:  c6 06 06 00 01                             mov        byte [0006h], 01h
da117:  eb 15                                      jmp short  loc_da12e

;  XREF: da133
da119:  a0 06 00              loc_da119:           mov        al, [0006h]
da11c:  98                                         cbw
da11d:  ba 3c 41                                   mov        dx, 413ch
da120:  8b d8                                      mov        bx, ax
da122:  8e c2                                      mov        es, dx
da124:  26 c6 87 c6 00 0a                          mov        byte es:[bx+00c6h], 0ah
da12a:  fe 06 06 00                                inc        byte [0006h]

;  XREF: da117
da12e:  80 3e 06 00 08        loc_da12e:           cmp        byte [0006h], 08h
da133:  7c e4                                      jl         loc_da119
da135:  a0 04 00                                   mov        al, [0004h]
da138:  98                                         cbw
da139:  ba 3c 41                                   mov        dx, 413ch
da13c:  8a 1e 05 00                                mov        bl, [0005h]
da140:  8e c2                                      mov        es, dx
da142:  93                                         xchg       ax, bx
da143:  26 88 87 c7 00                             mov        es:[bx+00c7h], al
da148:  c6 06 01 00 01                             mov        byte [0001h], 01h
da14d:  c6 06 02 00 35                             mov        byte [0002h], 35h
da152:  1e                                         push       ds
da153:  68 01 00                                   push       0001h
da156:  a0 04 00                                   mov        al, [0004h]
da159:  98                                         cbw
da15a:  05 3a 01                                   add        ax, 013ah
da15d:  50                                         push       ax
da15e:  6a 10                                      push       10h
da160:  9a 01 07 00 f0                             call       dmd_text_render
da165:  83 c4 08                                   add        word sp, 08h
da168:  c6 06 01 00 01                             mov        byte [0001h], 01h
da16d:  a0 05 00                                   mov        al, [0005h]
da170:  a2 02 00                                   mov        [0002h], al
da173:  1e                                         push       ds
da174:  68 01 00                                   push       0001h
da177:  a0 04 00                                   mov        al, [0004h]
da17a:  98                                         cbw
da17b:  05 3a 01                                   add        ax, 013ah
da17e:  50                                         push       ax
da17f:  6a 11                                      push       11h
da181:  9a 01 07 00 f0                             call       dmd_text_render
da186:  83 c4 08                                   add        word sp, 08h
da189:  68 c2 00                                   push       00c2h
da18c:  9a 1a 11 00 f0                             call       interrupt_handler_timer
da191:  59                                         pop        cx
da192:  1f                                         pop        ds
da193:  5d                                         pop        bp
da194:  cb                                         retf

;  XREF: da418

; -----------------------------------------------------------------------------
; game_end_score_check (0xDA19D)
; Check scores at game end
; -----------------------------------------------------------------------------
da19d:  1e                    game_end_score_check:           push       ds
da19e:  b8 34 41                                   mov        ax, 4134h
da1a1:  8e d8                                      mov        ds, ax
da1a3:  6a 0a                                      push       0ah
da1a5:  9a e8 26 f2 d2                             call       switch_read_shared_ram
da1aa:  59                                         pop        cx
da1ab:  68 c6 00                                   push       00c6h
da1ae:  9a 38 01 00 d0                             call       cmd_queue_push
da1b3:  59                                         pop        cx
da1b4:  6a 41                                      push       41h
da1b6:  0e                                         push       cs
da1b7:  e8 f0 d0                                   call       dmd_anim_play
da1ba:  59                                         pop        cx
da1bb:  6a 42                                      push       42h
da1bd:  0e                                         push       cs
da1be:  e8 e9 d0                                   call       dmd_anim_play
da1c1:  59                                         pop        cx
da1c2:  6a 40                                      push       40h
da1c4:  0e                                         push       cs
da1c5:  e8 e2 d0                                   call       dmd_anim_play
da1c8:  59                                         pop        cx
da1c9:  c6 06 2a 00 00                             mov        byte [002ah], 00h
da1ce:  9a 3d 12 00 f0                             call       interrupt_handler_serial
da1d3:  9a f1 00 00 f0                             call       dmd_buffer_clear
da1d8:  9a c4 00 00 f0                             call       dmd_buffer_swap
da1dd:  1f                                         pop        ds
da1de:  cb                                         retf

;  XREF: d4755, d4792, d47cf

; -----------------------------------------------------------------------------
; match_display_handler (0xDA1DF)
; Handle match number display during match sequence (3 refs from D47xx)
; -----------------------------------------------------------------------------
da1df:  55                    match_display_handler:           push       bp
da1e0:  8b ec                                      mov        bp, sp
da1e2:  1e                                         push       ds
da1e3:  b8 34 41                                   mov        ax, 4134h
da1e6:  8e d8                                      mov        ds, ax
da1e8:  8a 46 06                                   mov        al, [bp+06h]
da1eb:  50                                         push       ax
da1ec:  0e                                         push       cs
da1ed:  e8 8d fd                                   call       dmd_match_digit_draw

;  XREF: da2ce
da1f0:  59                    loc_da1f0:           pop        cx
da1f1:  e9 19 02                                   jmp        loc_da40d

;  XREF: da20f, da21c
da1f4:  b8 00 40              loc_da1f4:           mov        ax, 4000h
da1f7:  8e c0                                      mov        es, ax
da1f9:  26 81 3e e6 10 e8 03                       cmp        word es:[10e6h], 03e8h ; game_end_timer - Game end display timer (1000 frames = 4.2 seconds at ~240Hz)
da200:  7c 07                                      jl         loc_da209
da202:  c6 06 00 00 01                             mov        byte [0000h], 01h
da207:  eb 15                                      jmp short  loc_da21e

;  XREF: da200, da414
da209:  0e                    loc_da209:           push       cs
da20a:  e8 3a d9                                   call       button_filter_accept_start
da20d:  0b c0                                      or         ax, ax
da20f:  74 e3                                      jz         loc_da1f4
da211:  b8 00 40                                   mov        ax, 4000h
da214:  8e c0                                      mov        es, ax
da216:  26 83 3e 3d 11 00                          cmp        word es:[113dh], 00h
da21c:  75 d6                                      jnz        loc_da1f4

;  XREF: da207
da21e:  80 3e 00 00 01        loc_da21e:           cmp        byte [0000h], 01h
da223:  75 03                                      jnz        loc_da228
da225:  e9 ef 01                                   jmp        loc_da417

;  XREF: da223
da228:  b8 3c 41              loc_da228:           mov        ax, 413ch
da22b:  8e c0                                      mov        es, ax
da22d:  26 a0 d6 00                                mov        al, es:[00d6h] ; last_switch_code - Last switch code received from Z80
da231:  b4 00                                      mov        ah, 00h
da233:  3d 40 00                                   cmp        ax, 0040h     ; Switch: Upper_Flipper_Button
da236:  75 03                                      jnz        loc_da23b
da238:  e9 96 00                                   jmp        loc_da2d1

;  XREF: da236
da23b:  3d 41 00              loc_da23b:           cmp        ax, 0041h     ; Switch: START_Button
da23e:  74 08                                      jz         loc_da248
da240:  3d 42 00                                   cmp        ax, 0042h     ; Switch: Coin_Input
da243:  74 45                                      jz         loc_da28a
da245:  e9 c5 01                                   jmp        loc_da40d

;  XREF: da23e
da248:  80 3e 05 00 00        loc_da248:           cmp        byte [0005h], 00h
da24d:  75 07                                      jnz        loc_da256
da24f:  c6 06 05 00 34                             mov        byte [0005h], 34h
da254:  eb 08                                      jmp short  loc_da25e

;  XREF: da24d
da256:  a0 05 00              loc_da256:           mov        al, [0005h]
da259:  fe c8                                      dec        byte al
da25b:  a2 05 00                                   mov        [0005h], al

;  XREF: da254
da25e:  a0 05 00              loc_da25e:           mov        al, [0005h]
da261:  a2 02 00                                   mov        [0002h], al
da264:  1e                                         push       ds
da265:  68 01 00                                   push       0001h
da268:  a0 04 00                                   mov        al, [0004h]
da26b:  98                                         cbw
da26c:  05 3a 01                                   add        ax, 013ah
da26f:  50                                         push       ax
da270:  6a 11                                      push       11h
da272:  9a 01 07 00 f0                             call       dmd_text_render
da277:  83 c4 08                                   add        word sp, 08h
da27a:  b8 00 40                                   mov        ax, 4000h
da27d:  8e c0                                      mov        es, ax
da27f:  26 c7 06 3d 11 05 00                       mov        word es:[113dh], 0005h
da286:  6a 41                                      push       41h
da288:  eb 40                                      jmp short  loc_da2ca

;  XREF: da243
da28a:  80 3e 05 00 34        loc_da28a:           cmp        byte [0005h], 34h
da28f:  75 07                                      jnz        loc_da298
da291:  c6 06 05 00 00                             mov        byte [0005h], 00h
da296:  eb 08                                      jmp short  loc_da2a0

;  XREF: da28f
da298:  a0 05 00              loc_da298:           mov        al, [0005h]
da29b:  fe c0                                      inc        byte al
da29d:  a2 05 00                                   mov        [0005h], al

;  XREF: da296
da2a0:  a0 05 00              loc_da2a0:           mov        al, [0005h]
da2a3:  a2 02 00                                   mov        [0002h], al
da2a6:  1e                                         push       ds
da2a7:  68 01 00                                   push       0001h
da2aa:  a0 04 00                                   mov        al, [0004h]
da2ad:  98                                         cbw
da2ae:  05 3a 01                                   add        ax, 013ah
da2b1:  50                                         push       ax
da2b2:  6a 11                                      push       11h
da2b4:  9a 01 07 00 f0                             call       dmd_text_render
da2b9:  83 c4 08                                   add        word sp, 08h
da2bc:  b8 00 40                                   mov        ax, 4000h
da2bf:  8e c0                                      mov        es, ax
da2c1:  26 c7 06 3d 11 05 00                       mov        word es:[113dh], 0005h
da2c8:  6a 42                                      push       42h

;  XREF: da288
da2ca:  0e                    loc_da2ca:           push       cs
da2cb:  e8 dc cf                                   call       dmd_anim_play
da2ce:  e9 1f ff                                   jmp        loc_da1f0

;  XREF: da238
da2d1:  6a 40                 loc_da2d1:           push       40h
da2d3:  0e                                         push       cs
da2d4:  e8 d3 cf                                   call       dmd_anim_play
da2d7:  59                                         pop        cx
da2d8:  c6 06 01 00 01                             mov        byte [0001h], 01h
da2dd:  c6 06 02 00 0a                             mov        byte [0002h], 0ah
da2e2:  1e                                         push       ds
da2e3:  68 01 00                                   push       0001h
da2e6:  a0 04 00                                   mov        al, [0004h]
da2e9:  98                                         cbw
da2ea:  05 3a 01                                   add        ax, 013ah
da2ed:  50                                         push       ax
da2ee:  6a 10                                      push       10h
da2f0:  9a 01 07 00 f0                             call       dmd_text_render
da2f5:  83 c4 08                                   add        word sp, 08h
da2f8:  80 3e 05 00 34                             cmp        byte [0005h], 34h
da2fd:  75 6f                                      jnz        loc_da36e
da2ff:  80 3e 04 00 00                             cmp        byte [0004h], 00h
da304:  7f 03                                      jg         loc_da309
da306:  e9 04 01                                   jmp        loc_da40d

;  XREF: da304
da309:  c6 06 01 00 01        loc_da309:           mov        byte [0001h], 01h
da30e:  c6 06 02 00 0a                             mov        byte [0002h], 0ah
da313:  1e                                         push       ds
da314:  68 01 00                                   push       0001h
da317:  a0 04 00                                   mov        al, [0004h]
da31a:  98                                         cbw
da31b:  05 3a 01                                   add        ax, 013ah
da31e:  50                                         push       ax
da31f:  6a 11                                      push       11h
da321:  9a 01 07 00 f0                             call       dmd_text_render
da326:  83 c4 08                                   add        word sp, 08h
da329:  fe 0e 04 00                                dec        byte [0004h]
da32d:  c6 06 05 00 34                             mov        byte [0005h], 34h
da332:  c6 06 01 00 01                             mov        byte [0001h], 01h
da337:  a0 05 00                                   mov        al, [0005h]
da33a:  a2 02 00                                   mov        [0002h], al
da33d:  1e                                         push       ds
da33e:  68 01 00                                   push       0001h
da341:  a0 04 00                                   mov        al, [0004h]
da344:  98                                         cbw
da345:  05 3a 01                                   add        ax, 013ah
da348:  50                                         push       ax
da349:  6a 11                                      push       11h
da34b:  9a 01 07 00 f0                             call       dmd_text_render
da350:  83 c4 08                                   add        word sp, 08h
da353:  c6 06 01 00 01                             mov        byte [0001h], 01h
da358:  c6 06 02 00 35                             mov        byte [0002h], 35h
da35d:  1e                                         push       ds
da35e:  68 01 00                                   push       0001h
da361:  a0 04 00                                   mov        al, [0004h]
da364:  98                                         cbw
da365:  05 3a 01                                   add        ax, 013ah
da368:  50                                         push       ax
da369:  6a 10                                      push       10h
da36b:  e9 82 00                                   jmp        loc_da3f0

;  XREF: da2fd
da36e:  a0 04 00              loc_da36e:           mov        al, [0004h]
da371:  98                                         cbw
da372:  ba 3c 41                                   mov        dx, 413ch
da375:  8a 1e 05 00                                mov        bl, [0005h]
da379:  8e c2                                      mov        es, dx
da37b:  93                                         xchg       ax, bx
da37c:  26 88 87 c7 00                             mov        es:[bx+00c7h], al
da381:  80 3e 04 00 05                             cmp        byte [0004h], 05h
da386:  75 07                                      jnz        loc_da38f
da388:  c6 06 00 00 01                             mov        byte [0000h], 01h
da38d:  eb 72                                      jmp short  loc_da401

;  XREF: da386
da38f:  c6 06 01 00 01        loc_da38f:           mov        byte [0001h], 01h
da394:  c6 06 02 00 0a                             mov        byte [0002h], 0ah
da399:  1e                                         push       ds
da39a:  68 01 00                                   push       0001h
da39d:  a0 04 00                                   mov        al, [0004h]
da3a0:  98                                         cbw
da3a1:  05 3a 01                                   add        ax, 013ah
da3a4:  50                                         push       ax
da3a5:  6a 10                                      push       10h
da3a7:  9a 01 07 00 f0                             call       dmd_text_render
da3ac:  83 c4 08                                   add        word sp, 08h
da3af:  fe 06 04 00                                inc        byte [0004h]
da3b3:  c6 06 05 00 0b                             mov        byte [0005h], 0bh
da3b8:  c6 06 01 00 01                             mov        byte [0001h], 01h
da3bd:  c6 06 02 00 35                             mov        byte [0002h], 35h
da3c2:  1e                                         push       ds
da3c3:  68 01 00                                   push       0001h
da3c6:  a0 04 00                                   mov        al, [0004h]
da3c9:  98                                         cbw
da3ca:  05 3a 01                                   add        ax, 013ah
da3cd:  50                                         push       ax
da3ce:  6a 10                                      push       10h
da3d0:  9a 01 07 00 f0                             call       dmd_text_render
da3d5:  83 c4 08                                   add        word sp, 08h
da3d8:  c6 06 01 00 01                             mov        byte [0001h], 01h
da3dd:  c6 06 02 00 0b                             mov        byte [0002h], 0bh
da3e2:  1e                                         push       ds
da3e3:  68 01 00                                   push       0001h
da3e6:  a0 04 00                                   mov        al, [0004h]
da3e9:  98                                         cbw
da3ea:  05 3a 01                                   add        ax, 013ah
da3ed:  50                                         push       ax
da3ee:  6a 11                                      push       11h

;  XREF: da36b
da3f0:  9a 01 07 00 f0        loc_da3f0:           call       dmd_text_render
da3f5:  83 c4 08                                   add        word sp, 08h
da3f8:  68 c2 00                                   push       00c2h
da3fb:  9a 1a 11 00 f0                             call       interrupt_handler_timer
da400:  59                                         pop        cx

;  XREF: da38d
da401:  b8 00 40              loc_da401:           mov        ax, 4000h
da404:  8e c0                                      mov        es, ax
da406:  26 c7 06 3d 11 05 00                       mov        word es:[113dh], 0005h

;  XREF: da1f1, da245, da306
da40d:  80 3e 00 00 00        loc_da40d:           cmp        byte [0000h], 00h
da412:  75 03                                      jnz        loc_da417
da414:  e9 f2 fd                                   jmp        loc_da209

;  XREF: da225, da412
da417:  0e                    loc_da417:           push       cs
da418:  e8 82 fd                                   call       game_end_score_check
da41b:  1f                                         pop        ds
da41c:  5d                                         pop        bp
da41d:  cb                                         retf

;  XREF: d7396, d741e

; -----------------------------------------------------------------------------
; dmd_anim_load_frame (0xDA5B5)
; Load animation frame data (2 refs)
; -----------------------------------------------------------------------------
da5b5:  1e                    dmd_anim_load_frame:           push       ds
da5b6:  b8 34 41                                   mov        ax, 4134h
da5b9:  8e d8                                      mov        ds, ax
da5bb:  b8 00 40                                   mov        ax, 4000h
da5be:  8e c0                                      mov        es, ax
da5c0:  26 80 3e f1 10 00                          cmp        byte es:[10f1h], 00h
da5c6:  74 03                                      jz         loc_da5cb
da5c8:  e9 84 00                                   jmp        loc_da64f

;  XREF: da5c6
da5cb:  b8 3c 41              loc_da5cb:           mov        ax, 413ch
da5ce:  8e c0                                      mov        es, ax
da5d0:  26 80 3e dc 00 01                          cmp        byte es:[00dch], 01h
da5d6:  75 05                                      jnz        loc_da5dd
da5d8:  9a 3d 12 00 f0                             call       interrupt_handler_serial

;  XREF: da5d6
da5dd:  b8 3c 41              loc_da5dd:           mov        ax, 413ch
da5e0:  8e c0                                      mov        es, ax
da5e2:  26 80 3e de 00 01                          cmp        byte es:[00deh], 01h
da5e8:  75 05                                      jnz        loc_da5ef
da5ea:  9a de 0f 00 f0                             call       ram_test

;  XREF: da5e8
da5ef:  6a 05                 loc_da5ef:           push       05h
da5f1:  9a e8 26 f2 d2                             call       switch_read_shared_ram
da5f6:  59                                         pop        cx
da5f7:  b8 3c 41                                   mov        ax, 413ch
da5fa:  8e c0                                      mov        es, ax
da5fc:  26 a0 d6 00                                mov        al, es:[00d6h] ; last_switch_code - Last switch code received from Z80
da600:  50                                         push       ax
da601:  9a ba 38 25 dd                             call       player_display_info
da606:  59                                         pop        cx
da607:  b8 3c 41                                   mov        ax, 413ch
da60a:  8e c0                                      mov        es, ax
da60c:  26 80 3e de 00 01                          cmp        byte es:[00deh], 01h
da612:  75 09                                      jnz        loc_da61d
da614:  68 b2 00                                   push       00b2h
da617:  9a 73 0f 00 f0                             call       eeprom_validate
da61c:  59                                         pop        cx

;  XREF: da612
da61d:  b8 3c 41              loc_da61d:           mov        ax, 413ch
da620:  8e c0                                      mov        es, ax
da622:  26 80 3e 4f 01 04                          cmp        byte es:[014fh], 04h ; game_state_var - STATE MACHINE variable: 0=init, 1=attract, 2=game_active, 4=special_mode
da628:  74 0d                                      jz         loc_da637
da62a:  8e c0                                      mov        es, ax
da62c:  26 80 3e 4f 01 03                          cmp        byte es:[014fh], 03h ; game_state_var - STATE MACHINE variable: 0=init, 1=attract, 2=game_active, 4=special_mode
da632:  74 03                                      jz         loc_da637
da634:  e9 a9 00                                   jmp        loc_da6e0

;  XREF: da628, da632
da637:  68 81 01              loc_da637:           push       0181h
da63a:  9a 8e 10 00 f0                             call       cpu_peripheral_init
da63f:  59                                         pop        cx
da640:  68 8a 01                                   push       018ah
da643:  9a 3f 0d 00 f0                             call       dmd_scroll_engine
da648:  59                                         pop        cx
da649:  e9 94 00                                   jmp        loc_da6e0

;  XREF: da5c8
da64f:  b8 00 40              loc_da64f:           mov        ax, 4000h
da652:  8e c0                                      mov        es, ax
da654:  26 c6 06 f1 10 00                          mov        byte es:[10f1h], 00h
da65a:  b8 3c 41                                   mov        ax, 413ch
da65d:  8e c0                                      mov        es, ax
da65f:  26 80 3e dc 00 01                          cmp        byte es:[00dch], 01h
da665:  75 05                                      jnz        loc_da66c
da667:  9a 3d 12 00 f0                             call       interrupt_handler_serial

;  XREF: da665
da66c:  b8 3c 41              loc_da66c:           mov        ax, 413ch
da66f:  8e c0                                      mov        es, ax
da671:  26 80 3e de 00 01                          cmp        byte es:[00deh], 01h
da677:  75 05                                      jnz        loc_da67e
da679:  9a de 0f 00 f0                             call       ram_test

;  XREF: da677
da67e:  6a 05                 loc_da67e:           push       05h
da680:  9a e8 26 f2 d2                             call       switch_read_shared_ram
da685:  59                                         pop        cx
da686:  b8 3c 41                                   mov        ax, 413ch
da689:  8e c0                                      mov        es, ax
da68b:  26 a0 d6 00                                mov        al, es:[00d6h] ; last_switch_code - Last switch code received from Z80
da68f:  50                                         push       ax
da690:  9a ba 38 25 dd                             call       player_display_info
da695:  59                                         pop        cx
da696:  b8 3c 41                                   mov        ax, 413ch
da699:  8e c0                                      mov        es, ax
da69b:  26 80 3e de 00 01                          cmp        byte es:[00deh], 01h
da6a1:  75 09                                      jnz        loc_da6ac
da6a3:  68 b2 00                                   push       00b2h
da6a6:  9a 73 0f 00 f0                             call       eeprom_validate
da6ab:  59                                         pop        cx

;  XREF: da6a1
da6ac:  b8 3c 41              loc_da6ac:           mov        ax, 413ch
da6af:  8e c0                                      mov        es, ax
da6b1:  26 80 3e 4f 01 04                          cmp        byte es:[014fh], 04h ; game_state_var - STATE MACHINE variable: 0=init, 1=attract, 2=game_active, 4=special_mode
da6b7:  74 0a                                      jz         loc_da6c3
da6b9:  8e c0                                      mov        es, ax
da6bb:  26 80 3e 4f 01 03                          cmp        byte es:[014fh], 03h ; game_state_var - STATE MACHINE variable: 0=init, 1=attract, 2=game_active, 4=special_mode
da6c1:  75 12                                      jnz        loc_da6d5

;  XREF: da6b7
da6c3:  68 81 01              loc_da6c3:           push       0181h
da6c6:  9a 8e 10 00 f0                             call       cpu_peripheral_init
da6cb:  59                                         pop        cx
da6cc:  68 8a 01                                   push       018ah
da6cf:  9a 3f 0d 00 f0                             call       dmd_scroll_engine
da6d4:  59                                         pop        cx

;  XREF: da6c1
da6d5:  b8 00 40              loc_da6d5:           mov        ax, 4000h
da6d8:  8e c0                                      mov        es, ax
da6da:  26 c6 06 f1 10 ff                          mov        byte es:[10f1h], ffh

;  XREF: da634, da649
da6e0:  33 c0                 loc_da6e0:           xor        ax, ax
da6e2:  1f                                         pop        ds
da6e3:  cb                                         retf

;  XREF: d73be, d7448

; -----------------------------------------------------------------------------
; dmd_anim_set_timing (0xDA6E4)
; Set animation frame timing (2 refs)
; -----------------------------------------------------------------------------
da6e4:  1e                    dmd_anim_set_timing:           push       ds
da6e5:  b8 34 41                                   mov        ax, 4134h
da6e8:  8e d8                                      mov        ds, ax
da6ea:  b8 00 40                                   mov        ax, 4000h
da6ed:  8e c0                                      mov        es, ax
da6ef:  26 80 3e f1 10 00                          cmp        byte es:[10f1h], 00h
da6f5:  75 5f                                      jnz        loc_da756
da6f7:  b8 3c 41                                   mov        ax, 413ch
da6fa:  8e c0                                      mov        es, ax
da6fc:  26 80 3e dc 00 01                          cmp        byte es:[00dch], 01h
da702:  75 05                                      jnz        loc_da709
da704:  9a 3d 12 00 f0                             call       interrupt_handler_serial

;  XREF: da702
da709:  b8 3c 41              loc_da709:           mov        ax, 413ch
da70c:  8e c0                                      mov        es, ax
da70e:  26 80 3e de 00 01                          cmp        byte es:[00deh], 01h
da714:  75 05                                      jnz        loc_da71b
da716:  9a de 0f 00 f0                             call       ram_test

;  XREF: da714
da71b:  6a 05                 loc_da71b:           push       05h
da71d:  9a e8 26 f2 d2                             call       switch_read_shared_ram
da722:  59                                         pop        cx
da723:  b8 3c 41                                   mov        ax, 413ch
da726:  8e c0                                      mov        es, ax
da728:  26 a0 d6 00                                mov        al, es:[00d6h] ; last_switch_code - Last switch code received from Z80
da72c:  50                                         push       ax
da72d:  9a 01 38 25 dd                             call       player_display_scores
da732:  59                                         pop        cx
da733:  b8 3c 41                                   mov        ax, 413ch
da736:  8e c0                                      mov        es, ax
da738:  26 80 3e 4f 01 04                          cmp        byte es:[014fh], 04h ; game_state_var - STATE MACHINE variable: 0=init, 1=attract, 2=game_active, 4=special_mode
da73e:  75 03                                      jnz        loc_da743
da740:  e9 92 00                                   jmp        loc_da7d5

;  XREF: da73e
da743:  8e c0                 loc_da743:           mov        es, ax
da745:  26 80 3e 4f 01 03                          cmp        byte es:[014fh], 03h ; game_state_var - STATE MACHINE variable: 0=init, 1=attract, 2=game_active, 4=special_mode
da74b:  74 03                                      jz         loc_da750
da74d:  e9 97 00                                   jmp        loc_da7e7

;  XREF: da74b
da750:  e9 82 00              loc_da750:           jmp        loc_da7d5

;  XREF: da6f5
da756:  b8 00 40              loc_da756:           mov        ax, 4000h
da759:  8e c0                                      mov        es, ax
da75b:  26 c6 06 f1 10 00                          mov        byte es:[10f1h], 00h
da761:  b8 3c 41                                   mov        ax, 413ch
da764:  8e c0                                      mov        es, ax
da766:  26 80 3e dc 00 01                          cmp        byte es:[00dch], 01h
da76c:  75 05                                      jnz        loc_da773
da76e:  9a 3d 12 00 f0                             call       interrupt_handler_serial

;  XREF: da76c
da773:  b8 3c 41              loc_da773:           mov        ax, 413ch
da776:  8e c0                                      mov        es, ax
da778:  26 80 3e de 00 01                          cmp        byte es:[00deh], 01h
da77e:  75 05                                      jnz        loc_da785
da780:  9a de 0f 00 f0                             call       ram_test

;  XREF: da77e
da785:  6a 05                 loc_da785:           push       05h
da787:  9a e8 26 f2 d2                             call       switch_read_shared_ram
da78c:  59                                         pop        cx
da78d:  b8 3c 41                                   mov        ax, 413ch
da790:  8e c0                                      mov        es, ax
da792:  26 a0 d6 00                                mov        al, es:[00d6h] ; last_switch_code - Last switch code received from Z80
da796:  50                                         push       ax
da797:  9a 01 38 25 dd                             call       player_display_scores
da79c:  59                                         pop        cx
da79d:  b8 00 40                                   mov        ax, 4000h
da7a0:  8e c0                                      mov        es, ax
da7a2:  26 c6 06 f1 10 ff                          mov        byte es:[10f1h], ffh
da7a8:  b8 3c 41                                   mov        ax, 413ch
da7ab:  8e c0                                      mov        es, ax
da7ad:  26 80 3e de 00 01                          cmp        byte es:[00deh], 01h
da7b3:  75 09                                      jnz        loc_da7be
da7b5:  68 b2 00                                   push       00b2h
da7b8:  9a 73 0f 00 f0                             call       eeprom_validate
da7bd:  59                                         pop        cx

;  XREF: da7b3
da7be:  b8 3c 41              loc_da7be:           mov        ax, 413ch
da7c1:  8e c0                                      mov        es, ax
da7c3:  26 80 3e 4f 01 04                          cmp        byte es:[014fh], 04h ; game_state_var - STATE MACHINE variable: 0=init, 1=attract, 2=game_active, 4=special_mode
da7c9:  74 0a                                      jz         loc_da7d5
da7cb:  8e c0                                      mov        es, ax
da7cd:  26 80 3e 4f 01 03                          cmp        byte es:[014fh], 03h ; game_state_var - STATE MACHINE variable: 0=init, 1=attract, 2=game_active, 4=special_mode
da7d3:  75 12                                      jnz        loc_da7e7

;  XREF: da740, da750, da7c9
da7d5:  68 81 01              loc_da7d5:           push       0181h
da7d8:  9a 8e 10 00 f0                             call       cpu_peripheral_init
da7dd:  59                                         pop        cx
da7de:  68 8a 01                                   push       018ah
da7e1:  9a 3f 0d 00 f0                             call       dmd_scroll_engine
da7e6:  59                                         pop        cx

;  XREF: da74d, da7d3
da7e7:  33 c0                 loc_da7e7:           xor        ax, ax
da7e9:  1f                                         pop        ds
da7ea:  cb                                         retf

;  XREF: d7375, d73f8

; -----------------------------------------------------------------------------
; dmd_anim_get_state (0xDA7EB)
; Get animation state/progress (2 refs)
; -----------------------------------------------------------------------------
da7eb:  1e                    dmd_anim_get_state:           push       ds
da7ec:  b8 34 41                                   mov        ax, 4134h
da7ef:  8e d8                                      mov        ds, ax
da7f1:  b8 3c 41                                   mov        ax, 413ch
da7f4:  8e c0                                      mov        es, ax
da7f6:  26 80 3e de 00 01                          cmp        byte es:[00deh], 01h
da7fc:  75 05                                      jnz        loc_da803
da7fe:  9a de 0f 00 f0                             call       ram_test

;  XREF: da7fc
da803:  b8 3c 41              loc_da803:           mov        ax, 413ch
da806:  8e c0                                      mov        es, ax
da808:  26 80 3e dc 00 01                          cmp        byte es:[00dch], 01h
da80e:  75 05                                      jnz        loc_da815
da810:  9a 3d 12 00 f0                             call       interrupt_handler_serial

;  XREF: da80e
da815:  6a 0a                 loc_da815:           push       0ah
da817:  9a e8 26 f2 d2                             call       switch_read_shared_ram
da81c:  59                                         pop        cx
da81d:  b8 00 40                                   mov        ax, 4000h
da820:  8e c0                                      mov        es, ax
da822:  26 c6 06 f1 10 00                          mov        byte es:[10f1h], 00h
da828:  9a f1 00 00 f0                             call       dmd_buffer_clear
da82d:  9a c4 00 00 f0                             call       dmd_buffer_swap
da832:  9a 14 05 00 d0                             call       display_set_position_16refs
da837:  ba 3c 41                                   mov        dx, 413ch
da83a:  8e c2                                      mov        es, dx
da83c:  26 02 06 d7 00                             add        al, es:[00d7h]
da841:  50                                         push       ax
da842:  9a d2 04 00 d0                             call       display_write_word_12refs
da847:  59                                         pop        cx
da848:  9a 14 05 00 d0                             call       display_set_position_16refs
da84d:  50                                         push       ax
da84e:  9a 49 05 00 d0                             call       display_set_segment_14refs
da853:  5a                                         pop        dx
da854:  02 d0                                      add        dl, al
da856:  52                                         push       dx
da857:  9a d2 04 00 d0                             call       display_write_word_12refs
da85c:  59                                         pop        cx
da85d:  6a 00                                      push       00h
da85f:  9a f3 04 00 d0                             call       display_set_mode_10refs
da864:  59                                         pop        cx
da865:  b8 3c 41                                   mov        ax, 413ch
da868:  8e c0                                      mov        es, ax
da86a:  26 a0 d6 00                                mov        al, es:[00d6h] ; last_switch_code - Last switch code received from Z80
da86e:  50                                         push       ax
da86f:  9a d4 39 25 dd                             call       player_display_ball_num
da874:  59                                         pop        cx
da875:  33 c0                                      xor        ax, ax
da877:  1f                                         pop        ds
da878:  cb                                         retf

;  XREF: dc0c7, dc100

; -----------------------------------------------------------------------------
; dmd_effect_transition (0xDA879)
; Execute display transition effect (2 refs)
; -----------------------------------------------------------------------------
da879:  1e                    dmd_effect_transition:           push       ds
da87a:  b8 34 41                                   mov        ax, 4134h
da87d:  8e d8                                      mov        ds, ax
da87f:  b8 3c 41                                   mov        ax, 413ch
da882:  8e c0                                      mov        es, ax
da884:  26 80 3e de 00 01                          cmp        byte es:[00deh], 01h
da88a:  75 05                                      jnz        loc_da891
da88c:  9a de 0f 00 f0                             call       ram_test

;  XREF: da88a
da891:  b8 3c 41              loc_da891:           mov        ax, 413ch
da894:  8e c0                                      mov        es, ax
da896:  26 80 3e dc 00 01                          cmp        byte es:[00dch], 01h
da89c:  75 05                                      jnz        loc_da8a3
da89e:  9a 3d 12 00 f0                             call       interrupt_handler_serial

;  XREF: da89c
da8a3:  9a f2 37 2a d7        loc_da8a3:           call       game_init_display
da8a8:  9a 14 05 00 d0                             call       display_set_position_16refs
da8ad:  ba 3c 41                                   mov        dx, 413ch
da8b0:  8e c2                                      mov        es, dx
da8b2:  26 02 06 d7 00                             add        al, es:[00d7h]
da8b7:  50                                         push       ax
da8b8:  9a d2 04 00 d0                             call       display_write_word_12refs
da8bd:  59                                         pop        cx
da8be:  9a 14 05 00 d0                             call       display_set_position_16refs
da8c3:  50                                         push       ax
da8c4:  9a 49 05 00 d0                             call       display_set_segment_14refs
da8c9:  5a                                         pop        dx
da8ca:  02 d0                                      add        dl, al
da8cc:  52                                         push       dx
da8cd:  9a d2 04 00 d0                             call       display_write_word_12refs
da8d2:  59                                         pop        cx
da8d3:  6a 00                                      push       00h
da8d5:  9a f3 04 00 d0                             call       display_set_mode_10refs
da8da:  59                                         pop        cx
da8db:  b8 3c 41                                   mov        ax, 413ch
da8de:  8e c0                                      mov        es, ax
da8e0:  26 c4 1e b2 00                             les        bx, es:[00b2h]
da8e5:  26 ff 77 04                                push       word es:[bx+04h]
da8e9:  26 ff 77 02                                push       word es:[bx+02h]
da8ed:  8e c0                                      mov        es, ax
da8ef:  26 8e 06 b4 00                             mov        es, es:[00b4h]
da8f4:  26 ff 37                                   push       word es:[bx]
da8f7:  6a 01                                      push       01h
da8f9:  9a 01 07 00 f0                             call       dmd_text_render
da8fe:  83 c4 08                                   add        word sp, 08h

;  XREF: da901
da901:  eb fe                 loc_da901:           jmp short  loc_da901

;  XREF: d7549

; -----------------------------------------------------------------------------
; dmd_anim_complete_check (0xDA96D)
; Check if animation is complete
; -----------------------------------------------------------------------------
da96d:  1e                    dmd_anim_complete_check:           push       ds
da96e:  b8 34 41                                   mov        ax, 4134h
da971:  8e d8                                      mov        ds, ax
da973:  b8 3c 41                                   mov        ax, 413ch
da976:  8e c0                                      mov        es, ax
da978:  26 a0 4f 01                                mov        al, es:[014fh] ; game_state_var - STATE MACHINE variable: 0=init, 1=attract, 2=game_active, 4=special_mode
da97c:  b4 00                                      mov        ah, 00h
da97e:  3d 03 00                                   cmp        ax, 0003h
da981:  74 0a                                      jz         loc_da98d
da983:  3d 04 00                                   cmp        ax, 0004h
da986:  75 03                                      jnz        loc_da98b
da988:  e9 88 00                                   jmp        loc_daa13

;  XREF: da986
da98b:  eb 55                 loc_da98b:           jmp short  loc_da9e2

;  XREF: da981
da98d:  9a f2 37 2a d7        loc_da98d:           call       game_init_display
da992:  b8 3c 41                                   mov        ax, 413ch
da995:  8e c0                                      mov        es, ax
da997:  26 80 3e de 00 00                          cmp        byte es:[00deh], 00h
da99d:  74 05                                      jz         loc_da9a4
da99f:  9a de 0f 00 f0                             call       ram_test

;  XREF: da99d
da9a4:  b8 00 40              loc_da9a4:           mov        ax, 4000h
da9a7:  8e c0                                      mov        es, ax
da9a9:  26 80 3e 01 10 05                          cmp        byte es:[1001h], 05h ; game_status_byte - Overall game status communicated to Z80
da9af:  75 07                                      jnz        loc_da9b8
da9b1:  9a fd 2f 00 f0                             call       service_menu_main
da9b6:  eb 05                                      jmp short  loc_da9bd

;  XREF: da9af
da9b8:  9a 07 30 00 f0        loc_da9b8:           call       service_menu_dispatch

;  XREF: da9b6
da9bd:  6a 14                 loc_da9bd:           push       14h
da9bf:  9a e8 26 f2 d2                             call       switch_read_shared_ram
da9c4:  59                                         pop        cx
da9c5:  9a 93 3a 2a d7                             call       game_timer_utility
da9ca:  b8 3c 41                                   mov        ax, 413ch
da9cd:  8e c0                                      mov        es, ax
da9cf:  26 80 3e de 00 00                          cmp        byte es:[00deh], 00h
da9d5:  74 3c                                      jz         loc_daa13
da9d7:  68 b2 00                                   push       00b2h
da9da:  9a 73 0f 00 f0                             call       eeprom_validate
da9df:  59                                         pop        cx
da9e0:  eb 31                                      jmp short  loc_daa13

;  XREF: da98b
da9e2:  9a f2 37 2a d7        loc_da9e2:           call       game_init_display
da9e7:  b8 00 40                                   mov        ax, 4000h
da9ea:  8e c0                                      mov        es, ax
da9ec:  26 80 3e 01 10 05                          cmp        byte es:[1001h], 05h ; game_status_byte - Overall game status communicated to Z80
da9f2:  75 07                                      jnz        loc_da9fb
da9f4:  9a fd 2f 00 f0                             call       service_menu_main
da9f9:  eb 05                                      jmp short  loc_daa00

;  XREF: da9f2
da9fb:  9a 07 30 00 f0        loc_da9fb:           call       service_menu_dispatch

;  XREF: da9f9
daa00:  6a 14                 loc_daa00:           push       14h
daa02:  9a e8 26 f2 d2                             call       switch_read_shared_ram
daa07:  59                                         pop        cx
daa08:  b8 3c 41                                   mov        ax, 413ch
daa0b:  8e c0                                      mov        es, ax
daa0d:  26 c6 06 df 00 01                          mov        byte es:[00dfh], 01h

;  XREF: da988, da9d5, da9e0
daa13:  1f                    loc_daa13:           pop        ds
daa14:  cb                                         retf

;  XREF: d8080

; -----------------------------------------------------------------------------
; dmd_anim_chain (0xDAA15)
; Chain next animation sequence
; -----------------------------------------------------------------------------
daa15:  1e                    dmd_anim_chain:           push       ds
daa16:  b8 34 41                                   mov        ax, 4134h
daa19:  8e d8                                      mov        ds, ax
daa1b:  b8 3c 41                                   mov        ax, 413ch
daa1e:  8e c0                                      mov        es, ax
daa20:  26 a0 4f 01                                mov        al, es:[014fh] ; game_state_var - STATE MACHINE variable: 0=init, 1=attract, 2=game_active, 4=special_mode
daa24:  b4 00                                      mov        ah, 00h
daa26:  3d 03 00                                   cmp        ax, 0003h
daa29:  74 07                                      jz         loc_daa32
daa2b:  3d 04 00                                   cmp        ax, 0004h
daa2e:  74 60                                      jz         loc_daa90
daa30:  eb 2d                                      jmp short  loc_daa5f

;  XREF: daa29
daa32:  9a f2 37 2a d7        loc_daa32:           call       game_init_display
daa37:  b8 00 40                                   mov        ax, 4000h
daa3a:  8e c0                                      mov        es, ax
daa3c:  26 80 3e 01 10 05                          cmp        byte es:[1001h], 05h ; game_status_byte - Overall game status communicated to Z80
daa42:  75 07                                      jnz        loc_daa4b
daa44:  9a c2 35 00 f0                             call       service_tilt_menu
daa49:  eb 05                                      jmp short  loc_daa50

;  XREF: daa42
daa4b:  9a cd 35 00 f0        loc_daa4b:           call       service_sound_menu

;  XREF: daa49
daa50:  6a 14                 loc_daa50:           push       14h
daa52:  9a e8 26 f2 d2                             call       switch_read_shared_ram
daa57:  59                                         pop        cx
daa58:  9a 93 3a 2a d7                             call       game_timer_utility
daa5d:  eb 31                                      jmp short  loc_daa90

;  XREF: daa30
daa5f:  9a f2 37 2a d7        loc_daa5f:           call       game_init_display
daa64:  b8 00 40                                   mov        ax, 4000h
daa67:  8e c0                                      mov        es, ax
daa69:  26 80 3e 01 10 05                          cmp        byte es:[1001h], 05h ; game_status_byte - Overall game status communicated to Z80
daa6f:  75 07                                      jnz        loc_daa78
daa71:  9a c2 35 00 f0                             call       service_tilt_menu
daa76:  eb 05                                      jmp short  loc_daa7d

;  XREF: daa6f
daa78:  9a cd 35 00 f0        loc_daa78:           call       service_sound_menu

;  XREF: daa76
daa7d:  6a 14                 loc_daa7d:           push       14h
daa7f:  9a e8 26 f2 d2                             call       switch_read_shared_ram
daa84:  59                                         pop        cx
daa85:  b8 3c 41                                   mov        ax, 413ch
daa88:  8e c0                                      mov        es, ax
daa8a:  26 c6 06 df 00 01                          mov        byte es:[00dfh], 01h

;  XREF: daa2e, daa5d
daa90:  1f                    loc_daa90:           pop        ds
daa91:  cb                                         retf

;  XREF: d2ff5, d32ac, d3356, d3ce1, d44a3 (+14 more)

; -----------------------------------------------------------------------------
; game_init_display (0xDAA92)
; Initialize game display elements
; -----------------------------------------------------------------------------
daa92:  1e                    game_init_display:           push       ds
daa93:  b8 34 41                                   mov        ax, 4134h
daa96:  8e d8                                      mov        ds, ax
daa98:  b8 00 40                                   mov        ax, 4000h
daa9b:  8e c0                                      mov        es, ax
daa9d:  26 c6 06 f1 10 00                          mov        byte es:[10f1h], 00h
daaa3:  9a c4 00 00 f0                             call       dmd_buffer_swap
daaa8:  9a f1 00 00 f0                             call       dmd_buffer_clear
daaad:  1f                                         pop        ds
daaae:  cb                                         retf

;  XREF: d3575, d35ec, d3646

; -----------------------------------------------------------------------------
; ball_launch_display (0xDAAAF)
; Ball launch/serve display animation (3 refs from ball serve area)
; -----------------------------------------------------------------------------
daaaf:  55                    ball_launch_display:           push       bp
daab0:  8b ec                                      mov        bp, sp
daab2:  1e                                         push       ds
daab3:  b8 34 41                                   mov        ax, 4134h
daab6:  8e d8                                      mov        ds, ax
daab8:  8b 46 0e                                   mov        ax, [bp+0eh]
daabb:  a3 31 00                                   mov        [0031h], ax
daabe:  c6 06 24 00 01                             mov        byte [0024h], 01h
daac3:  0e                                         push       cs
daac4:  e8 cb ff                                   call       game_init_display
daac7:  b8 00 40                                   mov        ax, 4000h
daaca:  8e c0                                      mov        es, ax
daacc:  26 80 3e 01 10 05                          cmp        byte es:[1001h], 05h ; game_status_byte - Overall game status communicated to Z80
daad2:  75 05                                      jnz        loc_daad9
daad4:  ff 5e 06                                   call far   [bp+06h]
daad7:  eb 03                                      jmp short  loc_daadc

;  XREF: daad2
daad9:  ff 5e 0a              loc_daad9:           call far   [bp+0ah]

;  XREF: daad7
daadc:  ff 36 31 00           loc_daadc:           push       word [0031h]
daae0:  9a 0f 27 f2 d2                             call       switch_debounce
daae5:  59                                         pop        cx
daae6:  b8 00 40                                   mov        ax, 4000h
daae9:  8e c0                                      mov        es, ax
daaeb:  26 c6 06 f1 10 00                          mov        byte es:[10f1h], 00h
daaf1:  9a f1 00 00 f0                             call       dmd_buffer_clear
daaf6:  9a 93 3a 2a d7                             call       game_timer_utility
daafb:  c6 06 24 00 00                             mov        byte [0024h], 00h
dab00:  1f                                         pop        ds
dab01:  5d                                         pop        bp
dab02:  cb                                         retf

;  XREF: dc7a8

; -----------------------------------------------------------------------------
; dmd_effect_handler (0xDAB03)
; DMD visual effect handler
; -----------------------------------------------------------------------------
dab03:  1e                    dmd_effect_handler:           push       ds
dab04:  b8 34 41                                   mov        ax, 4134h
dab07:  8e d8                                      mov        ds, ax
dab09:  6a 10                                      push       10h
dab0b:  6a 14                                      push       14h
dab0d:  6a 00                                      push       00h
dab0f:  9a ef 33 00 f0                             call       service_lamp_test
dab14:  83 c4 06                                   add        word sp, 06h

;  XREF: dab22
dab17:  b8 00 40              loc_dab17:           mov        ax, 4000h
dab1a:  8e c0                                      mov        es, ax
dab1c:  26 80 3e 33 11 00                          cmp        byte es:[1133h], 00h
dab22:  75 f3                                      jnz        loc_dab17
dab24:  1f                                         pop        ds
dab25:  cb                                         retf

;  XREF: d373d, da9c5, daa58, daaf6

; -----------------------------------------------------------------------------
; game_timer_utility (0xDAD33)
; Game timer utility function (4 refs)
; -----------------------------------------------------------------------------
dad33:  1e                    game_timer_utility:           push       ds
dad34:  b8 34 41                                   mov        ax, 4134h
dad37:  8e d8                                      mov        ds, ax
dad39:  9a 9c 17 00 f0                             call       display_test_pattern
dad3e:  68 8a 01                                   push       018ah
dad41:  9a 3f 0d 00 f0                             call       dmd_scroll_engine
dad46:  59                                         pop        cx
dad47:  68 81 01                                   push       0181h
dad4a:  9a 8e 10 00 f0                             call       cpu_peripheral_init
dad4f:  59                                         pop        cx
dad50:  1f                                         pop        ds
dad51:  cb                                         retf

;  XREF: dbe04, dbf6c

; -----------------------------------------------------------------------------
; lamp_chase_update (0xDBB4B)
; Update lamp chase/sequence pattern (2 refs)
; -----------------------------------------------------------------------------
dbb4b:  1e                    lamp_chase_update:           push       ds
dbb4c:  b8 34 41                                   mov        ax, 4134h
dbb4f:  8e d8                                      mov        ds, ax
dbb51:  6a 12                                      push       12h
dbb53:  9a 5e 56 2a d7                             call       game_var_indexed_read
dbb58:  59                                         pop        cx
dbb59:  6a 06                                      push       06h
dbb5b:  9a 5e 56 2a d7                             call       game_var_indexed_read
dbb60:  59                                         pop        cx
dbb61:  6a 10                                      push       10h
dbb63:  9a 5e 56 2a d7                             call       game_var_indexed_read
dbb68:  59                                         pop        cx
dbb69:  6a 11                                      push       11h
dbb6b:  9a 5e 56 2a d7                             call       game_var_indexed_read
dbb70:  59                                         pop        cx
dbb71:  6a 0b                                      push       0bh
dbb73:  9a 5e 56 2a d7                             call       game_var_indexed_read
dbb78:  59                                         pop        cx
dbb79:  1f                                         pop        ds
dbb7a:  cb                                         retf

;  XREF: dc010

; -----------------------------------------------------------------------------
; lamp_state_write (0xDBC0D)
; Write lamp state to Z80 shared RAM
; -----------------------------------------------------------------------------
dbc0d:  1e                    lamp_state_write:           push       ds
dbc0e:  b8 34 41                                   mov        ax, 4134h
dbc11:  8e d8                                      mov        ds, ax
dbc13:  b8 3c 41                                   mov        ax, 413ch
dbc16:  8e c0                                      mov        es, ax
dbc18:  26 80 3e 02 01 00                          cmp        byte es:[0102h], 00h
dbc1e:  74 73                                      jz         loc_dbc93
dbc20:  6a 1e                                      push       1eh
dbc22:  9a da 56 2a d7                             call       game_var_increment
dbc27:  59                                         pop        cx
dbc28:  6a 03                                      push       03h
dbc2a:  9a 94 56 2a d7                             call       game_var_indexed_write
dbc2f:  59                                         pop        cx
dbc30:  b8 3c 41                                   mov        ax, 413ch
dbc33:  8e c0                                      mov        es, ax
dbc35:  26 a0 02 01                                mov        al, es:[0102h]
dbc39:  b4 00                                      mov        ah, 00h
dbc3b:  48                                         dec        ax
dbc3c:  8b d8                                      mov        bx, ax
dbc3e:  83 fb 05                                   cmp        word bx, 05h
dbc41:  77 50                                      ja         loc_dbc93
dbc43:  d1 e3                                      shl        bx, 1
dbc45:  2e ff a7 f5 49                             jmp        cs:[bx+49f5h]

;  XREF: dbc1e, dbc41
dbc93:  1f                    loc_dbc93:           pop        ds
dbc94:  cb                                         retf

;  XREF: d2feb, dc7ed

; -----------------------------------------------------------------------------
; game_reset_state (0xDBCA1)
; Reset game state variables for new game
; -----------------------------------------------------------------------------
dbca1:  1e                    game_reset_state:           push       ds
dbca2:  b8 34 41                                   mov        ax, 4134h
dbca5:  8e d8                                      mov        ds, ax
dbca7:  b8 3c 41                                   mov        ax, 413ch
dbcaa:  8e c0                                      mov        es, ax
dbcac:  26 c6 06 d6 00 00                          mov        byte es:[00d6h], 00h ; last_switch_code - Last switch code received from Z80
dbcb2:  b8 3c 41                                   mov        ax, 413ch
dbcb5:  8e c0                                      mov        es, ax
dbcb7:  26 c6 06 03 01 00                          mov        byte es:[0103h], 00h
dbcbd:  c6 06 06 00 00                             mov        byte [0006h], 00h
dbcc2:  eb 15                                      jmp short  loc_dbcd9

;  XREF: dbcde
dbcc4:  a0 06 00              loc_dbcc4:           mov        al, [0006h]
dbcc7:  98                                         cbw
dbcc8:  ba 3c 41                                   mov        dx, 413ch
dbccb:  8b d8                                      mov        bx, ax
dbccd:  8e c2                                      mov        es, dx
dbccf:  26 c6 87 04 01 01                          mov        byte es:[bx+0104h], 01h
dbcd5:  fe 06 06 00                                inc        byte [0006h]

;  XREF: dbcc2
dbcd9:  80 3e 06 00 4b        loc_dbcd9:           cmp        byte [0006h], 4bh
dbcde:  7c e4                                      jl         loc_dbcc4
dbce0:  c6 06 2a 00 00                             mov        byte [002ah], 00h
dbce5:  1f                                         pop        ds
dbce6:  cb                                         retf

;  XREF: d34ea, d38c9, d4544

; -----------------------------------------------------------------------------
; game_state_save (0xDBCE7)
; Save current game state (3 refs: ball serve, multiball, high score)
; -----------------------------------------------------------------------------
dbce7:  1e                    game_state_save:           push       ds
dbce8:  b8 34 41                                   mov        ax, 4134h
dbceb:  8e d8                                      mov        ds, ax
dbced:  b8 3c 41                                   mov        ax, 413ch
dbcf0:  8e c0                                      mov        es, ax
dbcf2:  26 c6 06 03 01 00                          mov        byte es:[0103h], 00h
dbcf8:  c6 06 06 00 00                             mov        byte [0006h], 00h
dbcfd:  eb 15                                      jmp short  loc_dbd14

;  XREF: dbd19
dbcff:  a0 06 00              loc_dbcff:           mov        al, [0006h]
dbd02:  98                                         cbw
dbd03:  ba 3c 41                                   mov        dx, 413ch
dbd06:  8b d8                                      mov        bx, ax
dbd08:  8e c2                                      mov        es, dx
dbd0a:  26 c6 87 04 01 01                          mov        byte es:[bx+0104h], 01h
dbd10:  fe 06 06 00                                inc        byte [0006h]

;  XREF: dbcfd
dbd14:  80 3e 06 00 4b        loc_dbd14:           cmp        byte [0006h], 4bh
dbd19:  7c e4                                      jl         loc_dbcff
dbd1b:  68 ab 00                                   push       00abh
dbd1e:  9a 38 01 00 d0                             call       cmd_queue_push
dbd23:  59                                         pop        cx
dbd24:  1f                                         pop        ds
dbd25:  cb                                         retf

;  XREF: dc7e9

; -----------------------------------------------------------------------------
; solenoid_state_write (0xDBD26)
; Write solenoid state to Z80 shared RAM
; -----------------------------------------------------------------------------
dbd26:  1e                    solenoid_state_write:           push       ds
dbd27:  b8 34 41                                   mov        ax, 4134h
dbd2a:  8e d8                                      mov        ds, ax
dbd2c:  68 db 00                                   push       00dbh
dbd2f:  9a 38 01 00 d0                             call       cmd_queue_push
dbd34:  59                                         pop        cx
dbd35:  68 c7 00                                   push       00c7h
dbd38:  9a 38 01 00 d0                             call       cmd_queue_push
dbd3d:  59                                         pop        cx
dbd3e:  b8 3c 41                                   mov        ax, 413ch
dbd41:  8e c0                                      mov        es, ax
dbd43:  26 c6 06 03 01 00                          mov        byte es:[0103h], 00h
dbd49:  b8 01 00                                   mov        ax, 0001h
dbd4c:  1f                                         pop        ds
dbd4d:  cb                                         retf

;  XREF: d38fc, d4566

; -----------------------------------------------------------------------------
; game_state_restore (0xDBD4E)
; Restore saved game state (2 refs)
; -----------------------------------------------------------------------------
dbd4e:  1e                    game_state_restore:           push       ds
dbd4f:  b8 34 41                                   mov        ax, 4134h
dbd52:  8e d8                                      mov        ds, ax
dbd54:  68 db 00                                   push       00dbh
dbd57:  9a 38 01 00 d0                             call       cmd_queue_push
dbd5c:  59                                         pop        cx
dbd5d:  b8 3c 41                                   mov        ax, 413ch
dbd60:  8e c0                                      mov        es, ax
dbd62:  26 c6 06 03 01 00                          mov        byte es:[0103h], 00h
dbd68:  1f                                         pop        ds
dbd69:  cb                                         retf

;  XREF: dc7ff

; -----------------------------------------------------------------------------
; solenoid_pulse_write (0xDBD6A)
; Write solenoid pulse command to Z80
; -----------------------------------------------------------------------------
dbd6a:  1e                    solenoid_pulse_write:           push       ds
dbd6b:  b8 34 41                                   mov        ax, 4134h
dbd6e:  8e d8                                      mov        ds, ax
dbd70:  c6 06 06 00 2c                             mov        byte [0006h], 2ch
dbd75:  eb 15                                      jmp short  loc_dbd8c

;  XREF: dbd91
dbd77:  a0 06 00              loc_dbd77:           mov        al, [0006h]
dbd7a:  98                                         cbw
dbd7b:  ba 3c 41                                   mov        dx, 413ch
dbd7e:  8b d8                                      mov        bx, ax
dbd80:  8e c2                                      mov        es, dx
dbd82:  26 c6 87 04 01 00                          mov        byte es:[bx+0104h], 00h
dbd88:  fe 06 06 00                                inc        byte [0006h]

;  XREF: dbd75
dbd8c:  80 3e 06 00 30        loc_dbd8c:           cmp        byte [0006h], 30h
dbd91:  7e e4                                      jle        loc_dbd77
dbd93:  b8 3c 41                                   mov        ax, 413ch
dbd96:  8e c0                                      mov        es, ax
dbd98:  26 c6 06 05 01 00                          mov        byte es:[0105h], 00h
dbd9e:  8e c0                                      mov        es, ax
dbda0:  26 c6 06 06 01 00                          mov        byte es:[0106h], 00h
dbda6:  8e c0                                      mov        es, ax
dbda8:  26 c6 06 07 01 00                          mov        byte es:[0107h], 00h
dbdae:  8e c0                                      mov        es, ax
dbdb0:  26 c6 06 21 01 00                          mov        byte es:[0121h], 00h
dbdb6:  68 a5 00                                   push       00a5h
dbdb9:  9a 38 01 00 d0                             call       cmd_queue_push
dbdbe:  59                                         pop        cx
dbdbf:  68 40 50                                   push       5040h
dbdc2:  68 40 00                                   push       0040h
dbdc5:  9a bf 04 00 d0                             call       display_check_status_48refs
dbdca:  83 c4 04                                   add        word sp, 04h
dbdcd:  0a c0                                      or         al, al
dbdcf:  75 1a                                      jnz        loc_dbdeb
dbdd1:  b8 3c 41                                   mov        ax, 413ch
dbdd4:  8e c0                                      mov        es, ax
dbdd6:  26 80 3e ec 00 01                          cmp        byte es:[00ech], 01h
dbddc:  75 0d                                      jnz        loc_dbdeb
dbdde:  b8 3c 41                                   mov        ax, 413ch
dbde1:  8e c0                                      mov        es, ax
dbde3:  26 c6 06 da 00 00                          mov        byte es:[00dah], 00h
dbde9:  eb 0b                                      jmp short  loc_dbdf6

;  XREF: dbdcf, dbddc
dbdeb:  b8 3c 41              loc_dbdeb:           mov        ax, 413ch
dbdee:  8e c0                                      mov        es, ax
dbdf0:  26 c6 06 da 00 01                          mov        byte es:[00dah], 01h

;  XREF: dbde9
dbdf6:  b8 3c 41              loc_dbdf6:           mov        ax, 413ch
dbdf9:  8e c0                                      mov        es, ax
dbdfb:  26 80 3e da 00 00                          cmp        byte es:[00dah], 00h
dbe01:  75 04                                      jnz        loc_dbe07
dbe03:  0e                                         push       cs
dbe04:  e8 44 fd                                   call       lamp_chase_update

;  XREF: dbe01
dbe07:  68 40 50              loc_dbe07:           push       5040h
dbe0a:  68 42 00                                   push       0042h
dbe0d:  9a bf 04 00 d0                             call       display_check_status_48refs
dbe12:  83 c4 04                                   add        word sp, 04h
dbe15:  04 ff                                      add        al, ffh
dbe17:  a2 33 00                                   mov        [0033h], al
dbe1a:  c6 06 2e 00 09                             mov        byte [002eh], 09h
dbe1f:  0e                                         push       cs
dbe20:  e8 8d d7                                   call       lamp_pattern_sequence
dbe23:  c6 06 26 00 00                             mov        byte [0026h], 00h
dbe28:  c6 06 29 00 00                             mov        byte [0029h], 00h
dbe2d:  c6 06 28 00 00                             mov        byte [0028h], 00h
dbe32:  c6 06 27 00 00                             mov        byte [0027h], 00h
dbe37:  c6 06 2b 00 00                             mov        byte [002bh], 00h
dbe3c:  c6 06 2c 00 00                             mov        byte [002ch], 00h
dbe41:  c6 06 25 00 00                             mov        byte [0025h], 00h
dbe46:  c6 06 30 00 00                             mov        byte [0030h], 00h
dbe4b:  b8 3c 41                                   mov        ax, 413ch
dbe4e:  8e c0                                      mov        es, ax
dbe50:  26 c6 06 fc 00 00                          mov        byte es:[00fch], 00h
dbe56:  b8 3c 41                                   mov        ax, 413ch
dbe59:  8e c0                                      mov        es, ax
dbe5b:  26 c6 06 fb 00 00                          mov        byte es:[00fbh], 00h
dbe61:  b8 3c 41                                   mov        ax, 413ch
dbe64:  8e c0                                      mov        es, ax
dbe66:  26 c6 06 03 01 00                          mov        byte es:[0103h], 00h
dbe6c:  c6 06 23 00 00                             mov        byte [0023h], 00h
dbe71:  b8 3c 41                                   mov        ax, 413ch
dbe74:  8e c0                                      mov        es, ax
dbe76:  26 c6 06 02 01 00                          mov        byte es:[0102h], 00h
dbe7c:  b8 3c 41                                   mov        ax, 413ch
dbe7f:  8e c0                                      mov        es, ax
dbe81:  26 c6 06 f4 00 00                          mov        byte es:[00f4h], 00h
dbe87:  c6 06 22 00 00                             mov        byte [0022h], 00h
dbe8c:  b8 3c 41                                   mov        ax, 413ch
dbe8f:  8e c0                                      mov        es, ax
dbe91:  26 c6 06 d8 00 00                          mov        byte es:[00d8h], 00h
dbe97:  b8 3c 41                                   mov        ax, 413ch
dbe9a:  8e c0                                      mov        es, ax
dbe9c:  26 c6 06 fa 00 00                          mov        byte es:[00fah], 00h
dbea2:  b8 3c 41                                   mov        ax, 413ch
dbea5:  8e c0                                      mov        es, ax
dbea7:  26 c6 06 bc 00 00                          mov        byte es:[00bch], 00h
dbead:  68 e4 00                                   push       00e4h
dbeb0:  9a 38 01 00 d0                             call       cmd_queue_push
dbeb5:  59                                         pop        cx
dbeb6:  68 f2 00                                   push       00f2h
dbeb9:  9a 38 01 00 d0                             call       cmd_queue_push
dbebe:  59                                         pop        cx
dbebf:  68 e8 00                                   push       00e8h
dbec2:  9a 38 01 00 d0                             call       cmd_queue_push
dbec7:  59                                         pop        cx
dbec8:  6a 38                                      push       38h
dbeca:  9a da 56 2a d7                             call       game_var_increment
dbecf:  59                                         pop        cx
dbed0:  1f                                         pop        ds
dbed1:  cb                                         retf

;  XREF: dc765

; -----------------------------------------------------------------------------
; hardware_io_write (0xDBED2)
; Write to hardware I/O via Z80 shared RAM
; -----------------------------------------------------------------------------
dbed2:  1e                    hardware_io_write:           push       ds
dbed3:  b8 34 41                                   mov        ax, 4134h
dbed6:  8e d8                                      mov        ds, ax
dbed8:  c6 06 06 00 2c                             mov        byte [0006h], 2ch
dbedd:  eb 15                                      jmp short  loc_dbef4

;  XREF: dbef9
dbedf:  a0 06 00              loc_dbedf:           mov        al, [0006h]
dbee2:  98                                         cbw
dbee3:  ba 3c 41                                   mov        dx, 413ch
dbee6:  8b d8                                      mov        bx, ax
dbee8:  8e c2                                      mov        es, dx
dbeea:  26 c6 87 04 01 00                          mov        byte es:[bx+0104h], 00h
dbef0:  fe 06 06 00                                inc        byte [0006h]

;  XREF: dbedd
dbef4:  80 3e 06 00 30        loc_dbef4:           cmp        byte [0006h], 30h
dbef9:  7e e4                                      jle        loc_dbedf
dbefb:  b8 3c 41                                   mov        ax, 413ch
dbefe:  8e c0                                      mov        es, ax
dbf00:  26 c6 06 05 01 00                          mov        byte es:[0105h], 00h
dbf06:  8e c0                                      mov        es, ax
dbf08:  26 c6 06 06 01 00                          mov        byte es:[0106h], 00h
dbf0e:  8e c0                                      mov        es, ax
dbf10:  26 c6 06 07 01 00                          mov        byte es:[0107h], 00h
dbf16:  8e c0                                      mov        es, ax
dbf18:  26 c6 06 21 01 00                          mov        byte es:[0121h], 00h
dbf1e:  68 a5 00                                   push       00a5h
dbf21:  9a 38 01 00 d0                             call       cmd_queue_push
dbf26:  59                                         pop        cx
dbf27:  68 40 50                                   push       5040h
dbf2a:  68 40 00                                   push       0040h
dbf2d:  9a bf 04 00 d0                             call       display_check_status_48refs
dbf32:  83 c4 04                                   add        word sp, 04h
dbf35:  0a c0                                      or         al, al
dbf37:  75 1a                                      jnz        loc_dbf53
dbf39:  b8 3c 41                                   mov        ax, 413ch
dbf3c:  8e c0                                      mov        es, ax
dbf3e:  26 80 3e ec 00 01                          cmp        byte es:[00ech], 01h
dbf44:  75 0d                                      jnz        loc_dbf53
dbf46:  b8 3c 41                                   mov        ax, 413ch
dbf49:  8e c0                                      mov        es, ax
dbf4b:  26 c6 06 da 00 00                          mov        byte es:[00dah], 00h
dbf51:  eb 0b                                      jmp short  loc_dbf5e

;  XREF: dbf37, dbf44
dbf53:  b8 3c 41              loc_dbf53:           mov        ax, 413ch
dbf56:  8e c0                                      mov        es, ax
dbf58:  26 c6 06 da 00 01                          mov        byte es:[00dah], 01h

;  XREF: dbf51
dbf5e:  b8 3c 41              loc_dbf5e:           mov        ax, 413ch
dbf61:  8e c0                                      mov        es, ax
dbf63:  26 80 3e da 00 00                          cmp        byte es:[00dah], 00h
dbf69:  75 04                                      jnz        loc_dbf6f
dbf6b:  0e                                         push       cs
dbf6c:  e8 dc fb                                   call       lamp_chase_update

;  XREF: dbf69
dbf6f:  68 40 50              loc_dbf6f:           push       5040h
dbf72:  68 42 00                                   push       0042h
dbf75:  9a bf 04 00 d0                             call       display_check_status_48refs
dbf7a:  83 c4 04                                   add        word sp, 04h
dbf7d:  04 ff                                      add        al, ffh
dbf7f:  a2 33 00                                   mov        [0033h], al
dbf82:  c6 06 2e 00 09                             mov        byte [002eh], 09h
dbf87:  0e                                         push       cs
dbf88:  e8 25 d6                                   call       lamp_pattern_sequence
dbf8b:  c6 06 26 00 00                             mov        byte [0026h], 00h
dbf90:  c6 06 29 00 00                             mov        byte [0029h], 00h
dbf95:  c6 06 28 00 00                             mov        byte [0028h], 00h
dbf9a:  c6 06 27 00 00                             mov        byte [0027h], 00h
dbf9f:  c6 06 2b 00 00                             mov        byte [002bh], 00h
dbfa4:  c6 06 2c 00 00                             mov        byte [002ch], 00h
dbfa9:  c6 06 25 00 00                             mov        byte [0025h], 00h
dbfae:  c6 06 30 00 00                             mov        byte [0030h], 00h
dbfb3:  b8 3c 41                                   mov        ax, 413ch
dbfb6:  8e c0                                      mov        es, ax
dbfb8:  26 c6 06 fc 00 00                          mov        byte es:[00fch], 00h
dbfbe:  b8 3c 41                                   mov        ax, 413ch
dbfc1:  8e c0                                      mov        es, ax
dbfc3:  26 c6 06 fb 00 00                          mov        byte es:[00fbh], 00h
dbfc9:  b8 3c 41                                   mov        ax, 413ch
dbfcc:  8e c0                                      mov        es, ax
dbfce:  26 c6 06 03 01 00                          mov        byte es:[0103h], 00h
dbfd4:  c6 06 23 00 00                             mov        byte [0023h], 00h
dbfd9:  b8 3c 41                                   mov        ax, 413ch
dbfdc:  8e c0                                      mov        es, ax
dbfde:  26 c6 06 f4 00 00                          mov        byte es:[00f4h], 00h
dbfe4:  c6 06 22 00 00                             mov        byte [0022h], 00h
dbfe9:  b8 3c 41                                   mov        ax, 413ch
dbfec:  8e c0                                      mov        es, ax
dbfee:  26 c6 06 d8 00 00                          mov        byte es:[00d8h], 00h
dbff4:  b8 3c 41                                   mov        ax, 413ch
dbff7:  8e c0                                      mov        es, ax
dbff9:  26 c6 06 fa 00 00                          mov        byte es:[00fah], 00h
dbfff:  b8 3c 41                                   mov        ax, 413ch
dc002:  8e c0                                      mov        es, ax
dc004:  26 c6 06 bc 00 00                          mov        byte es:[00bch], 00h
dc00a:  9a 9c 16 f2 d2                             call       high_score_check
dc00f:  0e                                         push       cs
dc010:  e8 fa fb                                   call       lamp_state_write
dc013:  b8 3c 41                                   mov        ax, 413ch
dc016:  8e c0                                      mov        es, ax
dc018:  26 80 3e 02 01 06                          cmp        byte es:[0102h], 06h
dc01e:  74 09                                      jz         loc_dc029
dc020:  68 f2 00                                   push       00f2h
dc023:  9a 38 01 00 d0                             call       cmd_queue_push
dc028:  59                                         pop        cx

;  XREF: dc01e
dc029:  68 e4 00              loc_dc029:           push       00e4h
dc02c:  9a 38 01 00 d0                             call       cmd_queue_push
dc031:  59                                         pop        cx
dc032:  68 e8 00                                   push       00e8h
dc035:  9a 38 01 00 d0                             call       cmd_queue_push
dc03a:  59                                         pop        cx
dc03b:  6a 38                                      push       38h
dc03d:  9a da 56 2a d7                             call       game_var_increment
dc042:  59                                         pop        cx
dc043:  1f                                         pop        ds
dc044:  cb                                         retf

;  XREF: dc57b

; -----------------------------------------------------------------------------
; dmd_multiball_display (0xDC045)
; Multiball mode display handler
; -----------------------------------------------------------------------------
dc045:  1e                    dmd_multiball_display:           push       ds
dc046:  b8 34 41                                   mov        ax, 4134h
dc049:  8e d8                                      mov        ds, ax
dc04b:  0e                                         push       cs
dc04c:  e8 b0 b4                                   call       dmd_text_display
dc04f:  0b c0                                      or         ax, ax
dc051:  74 1e                                      jz         loc_dc071
dc053:  b8 3c 41                                   mov        ax, 413ch
dc056:  8e c0                                      mov        es, ax
dc058:  26 a0 d6 00                                mov        al, es:[00d6h] ; last_switch_code - Last switch code received from Z80
dc05c:  b4 00                                      mov        ah, 00h
dc05e:  3d 40 00                                   cmp        ax, 0040h     ; Switch: Upper_Flipper_Button
dc061:  74 0a                                      jz         loc_dc06d
dc063:  3d 45 00                                   cmp        ax, 0045h
dc066:  75 09                                      jnz        loc_dc071
dc068:  b8 01 00                                   mov        ax, 0001h
dc06b:  eb 06                                      jmp short  loc_dc073

;  XREF: dc061
dc06d:  0e                    loc_dc06d:           push       cs
dc06e:  e8 f5 bf                                   call       dmd_anim_sequence_play

;  XREF: dc051, dc066
dc071:  33 c0                 loc_dc071:           xor        ax, ax

;  XREF: dc06b
dc073:  1f                    loc_dc073:           pop        ds
dc074:  cb                                         retf

;  XREF: dc508

; -----------------------------------------------------------------------------
; dmd_bonus_display (0xDC075)
; Bonus round display handler
; -----------------------------------------------------------------------------
dc075:  1e                    dmd_bonus_display:           push       ds
dc076:  b8 34 41                                   mov        ax, 4134h
dc079:  8e d8                                      mov        ds, ax
dc07b:  0e                                         push       cs
dc07c:  e8 d4 b3                                   call       dmd_score_display
dc07f:  0b c0                                      or         ax, ax
dc081:  74 15                                      jz         loc_dc098
dc083:  b8 3c 41                                   mov        ax, 413ch
dc086:  8e c0                                      mov        es, ax
dc088:  26 a0 d6 00                                mov        al, es:[00d6h] ; last_switch_code - Last switch code received from Z80
dc08c:  b4 00                                      mov        ah, 00h
dc08e:  3d 45 00                                   cmp        ax, 0045h
dc091:  75 05                                      jnz        loc_dc098
dc093:  b8 01 00                                   mov        ax, 0001h
dc096:  eb 02                                      jmp short  loc_dc09a

;  XREF: dc081, dc091
dc098:  33 c0                 loc_dc098:           xor        ax, ax

;  XREF: dc096
dc09a:  1f                    loc_dc09a:           pop        ds
dc09b:  cb                                         retf

;  XREF: dc48e

; -----------------------------------------------------------------------------
; dmd_special_display (0xDC09C)
; SPECIAL award display handler
; -----------------------------------------------------------------------------
dc09c:  1e                    dmd_special_display:           push       ds
dc09d:  b8 34 41                                   mov        ax, 4134h
dc0a0:  8e d8                                      mov        ds, ax
dc0a2:  0e                                         push       cs
dc0a3:  e8 ad b3                                   call       dmd_score_display
dc0a6:  0b c0                                      or         ax, ax
dc0a8:  74 22                                      jz         loc_dc0cc
dc0aa:  b8 3c 41                                   mov        ax, 413ch
dc0ad:  8e c0                                      mov        es, ax
dc0af:  26 a0 d6 00                                mov        al, es:[00d6h] ; last_switch_code - Last switch code received from Z80
dc0b3:  b4 00                                      mov        ah, 00h
dc0b5:  3d 45 00                                   cmp        ax, 0045h
dc0b8:  74 07                                      jz         loc_dc0c1
dc0ba:  3d 4a 00                                   cmp        ax, 004ah
dc0bd:  74 07                                      jz         loc_dc0c6
dc0bf:  eb 0b                                      jmp short  loc_dc0cc

;  XREF: dc0b8, dc0ca
dc0c1:  b8 01 00              loc_dc0c1:           mov        ax, 0001h
dc0c4:  eb 08                                      jmp short  loc_dc0ce

;  XREF: dc0bd
dc0c6:  0e                    loc_dc0c6:           push       cs
dc0c7:  e8 af e7                                   call       dmd_effect_transition
dc0ca:  eb f5                                      jmp short  loc_dc0c1

;  XREF: dc0a8, dc0bf
dc0cc:  33 c0                 loc_dc0cc:           xor        ax, ax

;  XREF: dc0c4
dc0ce:  1f                    loc_dc0ce:           pop        ds
dc0cf:  cb                                         retf

;  XREF: dc4a7

; -----------------------------------------------------------------------------
; dmd_jackpot_display (0xDC0D0)
; Jackpot display handler
; -----------------------------------------------------------------------------
dc0d0:  1e                    dmd_jackpot_display:           push       ds
dc0d1:  b8 34 41                                   mov        ax, 4134h
dc0d4:  8e d8                                      mov        ds, ax
dc0d6:  0e                                         push       cs
dc0d7:  e8 79 b3                                   call       dmd_score_display
dc0da:  0b c0                                      or         ax, ax
dc0dc:  74 2b                                      jz         loc_dc109
dc0de:  b8 3c 41                                   mov        ax, 413ch
dc0e1:  8e c0                                      mov        es, ax
dc0e3:  26 a0 d6 00                                mov        al, es:[00d6h] ; last_switch_code - Last switch code received from Z80
dc0e7:  b4 00                                      mov        ah, 00h
dc0e9:  3d 40 00                                   cmp        ax, 0040h     ; Switch: Upper_Flipper_Button
dc0ec:  74 17                                      jz         loc_dc105
dc0ee:  3d 45 00                                   cmp        ax, 0045h
dc0f1:  74 07                                      jz         loc_dc0fa
dc0f3:  3d 4a 00                                   cmp        ax, 004ah
dc0f6:  74 07                                      jz         loc_dc0ff
dc0f8:  eb 0f                                      jmp short  loc_dc109

;  XREF: dc0f1, dc103
dc0fa:  b8 01 00              loc_dc0fa:           mov        ax, 0001h
dc0fd:  eb 0c                                      jmp short  loc_dc10b

;  XREF: dc0f6
dc0ff:  0e                    loc_dc0ff:           push       cs
dc100:  e8 76 e7                                   call       dmd_effect_transition
dc103:  eb f5                                      jmp short  loc_dc0fa

;  XREF: dc0ec
dc105:  0e                    loc_dc105:           push       cs
dc106:  e8 5d bf                                   call       dmd_anim_sequence_play

;  XREF: dc0dc, dc0f8
dc109:  33 c0                 loc_dc109:           xor        ax, ax

;  XREF: dc0fd
dc10b:  1f                    loc_dc10b:           pop        ds
dc10c:  cb                                         retf

;  XREF: dc44f

; -----------------------------------------------------------------------------
; dmd_extra_ball_display (0xDC10D)
; Extra ball display handler
; -----------------------------------------------------------------------------
dc10d:  c8 02 00 00           dmd_extra_ball_display:           enter      0002h, 00h
dc111:  1e                                         push       ds
dc112:  b8 34 41                                   mov        ax, 4134h
dc115:  8e d8                                      mov        ds, ax
dc117:  0e                                         push       cs
dc118:  e8 38 b3                                   call       dmd_score_display
dc11b:  0b c0                                      or         ax, ax
dc11d:  75 02                                      jnz        loc_dc121
dc11f:  eb 5e                                      jmp short  loc_dc17f

;  XREF: dc11d
dc121:  b8 3c 41              loc_dc121:           mov        ax, 413ch
dc124:  8e c0                                      mov        es, ax
dc126:  26 a0 d6 00                                mov        al, es:[00d6h] ; last_switch_code - Last switch code received from Z80
dc12a:  b4 00                                      mov        ah, 00h
dc12c:  89 46 fe                                   mov        [bp-02h], ax
dc12f:  b9 04 00                                   mov        cx, 0004h
dc132:  bb e4 4e                                   mov        bx, 4ee4h

;  XREF: dc140
dc135:  2e 8b 07              loc_dc135:           mov        ax, cs:[bx]
dc138:  3b 46 fe                                   cmp        ax, [bp-02h]
dc13b:  74 07                                      jz         loc_dc144
dc13d:  83 c3 02                                   add        word bx, 02h
dc140:  e2 f3                                      loop       loc_dc135
dc142:  eb 3b                                      jmp short  loc_dc17f

;  XREF: dc13b
dc144:  2e ff 67 08           loc_dc144:           jmp        cs:[bx+08h]

;  XREF: dc11f, dc142
dc17f:  33 c0                 loc_dc17f:           xor        ax, ax
dc181:  1f                                         pop        ds
dc182:  c9                                         leave
dc183:  cb                                         retf

;  XREF: dc346

; -----------------------------------------------------------------------------
; dmd_mode_display_1 (0xDC194)
; Game mode display handler 1
; -----------------------------------------------------------------------------
dc194:  c8 02 00 00           dmd_mode_display_1:           enter      0002h, 00h
dc198:  1e                                         push       ds
dc199:  b8 34 41                                   mov        ax, 4134h
dc19c:  8e d8                                      mov        ds, ax
dc19e:  0e                                         push       cs
dc19f:  e8 b1 b2                                   call       dmd_score_display
dc1a2:  0b c0                                      or         ax, ax
dc1a4:  75 02                                      jnz        loc_dc1a8
dc1a6:  eb 5e                                      jmp short  loc_dc206

;  XREF: dc1a4
dc1a8:  b8 3c 41              loc_dc1a8:           mov        ax, 413ch
dc1ab:  8e c0                                      mov        es, ax
dc1ad:  26 a0 d6 00                                mov        al, es:[00d6h] ; last_switch_code - Last switch code received from Z80
dc1b1:  b4 00                                      mov        ah, 00h
dc1b3:  89 46 fe                                   mov        [bp-02h], ax
dc1b6:  b9 04 00                                   mov        cx, 0004h
dc1b9:  bb 6b 4f                                   mov        bx, 4f6bh

;  XREF: dc1c7
dc1bc:  2e 8b 07              loc_dc1bc:           mov        ax, cs:[bx]
dc1bf:  3b 46 fe                                   cmp        ax, [bp-02h]
dc1c2:  74 07                                      jz         loc_dc1cb
dc1c4:  83 c3 02                                   add        word bx, 02h
dc1c7:  e2 f3                                      loop       loc_dc1bc
dc1c9:  eb 3b                                      jmp short  loc_dc206

;  XREF: dc1c2
dc1cb:  2e ff 67 08           loc_dc1cb:           jmp        cs:[bx+08h]

;  XREF: dc1a6, dc1c9
dc206:  33 c0                 loc_dc206:           xor        ax, ax
dc208:  1f                                         pop        ds
dc209:  c9                                         leave
dc20a:  cb                                         retf

;  XREF: dc3d0

; -----------------------------------------------------------------------------
; dmd_mode_display_2 (0xDC21B)
; Game mode display handler 2
; -----------------------------------------------------------------------------
dc21b:  1e                    dmd_mode_display_2:           push       ds
dc21c:  b8 34 41                                   mov        ax, 4134h
dc21f:  8e d8                                      mov        ds, ax
dc221:  0e                                         push       cs
dc222:  e8 2e b2                                   call       dmd_score_display
dc225:  0b c0                                      or         ax, ax
dc227:  75 02                                      jnz        loc_dc22b
dc229:  eb 59                                      jmp short  loc_dc284

;  XREF: dc227
dc22b:  b8 3c 41              loc_dc22b:           mov        ax, 413ch
dc22e:  8e c0                                      mov        es, ax
dc230:  26 a0 d6 00                                mov        al, es:[00d6h] ; last_switch_code - Last switch code received from Z80
dc234:  b4 00                                      mov        ah, 00h
dc236:  2d 3b 00                                   sub        ax, 003bh
dc239:  8b d8                                      mov        bx, ax
dc23b:  83 fb 0e                                   cmp        word bx, 0eh
dc23e:  77 44                                      ja         loc_dc284
dc240:  d1 e3                                      shl        bx, 1
dc242:  2e ff a7 e8 4f                             jmp        cs:[bx+4fe8h]

;  XREF: dc229, dc23e
dc284:  33 c0                 loc_dc284:           xor        ax, ax
dc286:  1f                                         pop        ds
dc287:  cb                                         retf

;  XREF: d374a

; -----------------------------------------------------------------------------
; dmd_planet_display (0xDC2A6)
; Planet/Jupiter feature display
; -----------------------------------------------------------------------------
dc2a6:  1e                    dmd_planet_display:           push       ds
dc2a7:  b8 34 41                                   mov        ax, 4134h
dc2aa:  8e d8                                      mov        ds, ax
dc2ac:  6a 0a                                      push       0ah
dc2ae:  9a e8 26 f2 d2                             call       switch_read_shared_ram
dc2b3:  59                                         pop        cx
dc2b4:  6a 3d                                      push       3dh
dc2b6:  0e                                         push       cs
dc2b7:  e8 f0 af                                   call       dmd_anim_play
dc2ba:  59                                         pop        cx
dc2bb:  6a 3c                                      push       3ch
dc2bd:  0e                                         push       cs
dc2be:  e8 e9 af                                   call       dmd_anim_play
dc2c1:  59                                         pop        cx
dc2c2:  6a 3b                                      push       3bh
dc2c4:  0e                                         push       cs
dc2c5:  e8 e2 af                                   call       dmd_anim_play
dc2c8:  59                                         pop        cx
dc2c9:  6a 49                                      push       49h
dc2cb:  0e                                         push       cs
dc2cc:  e8 db af                                   call       dmd_anim_play
dc2cf:  59                                         pop        cx
dc2d0:  9a e6 50 2a d7                             call       dmd_target_display
dc2d5:  b8 3c 41                                   mov        ax, 413ch
dc2d8:  8e c0                                      mov        es, ax
dc2da:  26 a0 f8 00                                mov        al, es:[00f8h]
dc2de:  98                                         cbw
dc2df:  3d 01 00                                   cmp        ax, 0001h
dc2e2:  74 12                                      jz         loc_dc2f6
dc2e4:  3d 02 00                                   cmp        ax, 0002h
dc2e7:  74 09                                      jz         loc_dc2f2
dc2e9:  3d 03 00                                   cmp        ax, 0003h
dc2ec:  75 0c                                      jnz        loc_dc2fa
dc2ee:  0e                                         push       cs
dc2ef:  e8 ce cf                                   call       lamp_group_set

;  XREF: dc2e7
dc2f2:  0e                    loc_dc2f2:           push       cs
dc2f3:  e8 ca cf                                   call       lamp_group_set

;  XREF: dc2e2
dc2f6:  0e                    loc_dc2f6:           push       cs
dc2f7:  e8 c6 cf                                   call       lamp_group_set

;  XREF: dc2ec
dc2fa:  1f                    loc_dc2fa:           pop        ds
dc2fb:  cb                                         retf

;  XREF: dc4d4, dc547

; -----------------------------------------------------------------------------
; dmd_orbit_display (0xDC2FC)
; ORBITS display handler (2 refs)
; -----------------------------------------------------------------------------
dc2fc:  1e                    dmd_orbit_display:           push       ds
dc2fd:  b8 34 41                                   mov        ax, 4134h
dc300:  8e d8                                      mov        ds, ax
dc302:  6a 3d                                      push       3dh
dc304:  0e                                         push       cs
dc305:  e8 a2 af                                   call       dmd_anim_play
dc308:  59                                         pop        cx
dc309:  6a 3c                                      push       3ch
dc30b:  0e                                         push       cs
dc30c:  e8 9b af                                   call       dmd_anim_play
dc30f:  59                                         pop        cx
dc310:  6a 3b                                      push       3bh
dc312:  0e                                         push       cs
dc313:  e8 94 af                                   call       dmd_anim_play
dc316:  59                                         pop        cx
dc317:  6a 49                                      push       49h
dc319:  0e                                         push       cs
dc31a:  e8 8d af                                   call       dmd_anim_play
dc31d:  59                                         pop        cx
dc31e:  c6 06 08 00 00                             mov        byte [0008h], 00h
dc323:  b8 3c 41                                   mov        ax, 413ch
dc326:  8e c0                                      mov        es, ax
dc328:  26 c6 06 b7 00 00                          mov        byte es:[00b7h], 00h
dc32e:  eb 4d                                      jmp short  loc_dc37d

;  XREF: dc382
dc330:  b8 00 40              loc_dc330:           mov        ax, 4000h
dc333:  8e c0                                      mov        es, ax
dc335:  26 c7 06 39 11 96 00                       mov        word es:[1139h], 0096h
dc33c:  68 eb 00                                   push       00ebh
dc33f:  9a 38 01 00 d0                             call       cmd_queue_push
dc344:  59                                         pop        cx

;  XREF: dc358
dc345:  0e                    loc_dc345:           push       cs
dc346:  e8 4b fe                                   call       dmd_mode_display_1
dc349:  0b c0                                      or         ax, ax
dc34b:  75 0d                                      jnz        loc_dc35a
dc34d:  b8 00 40                                   mov        ax, 4000h
dc350:  8e c0                                      mov        es, ax
dc352:  26 83 3e 39 11 00                          cmp        word es:[1139h], 00h
dc358:  75 eb                                      jnz        loc_dc345

;  XREF: dc34b
dc35a:  b8 00 40              loc_dc35a:           mov        ax, 4000h
dc35d:  8e c0                                      mov        es, ax
dc35f:  26 83 3e 39 11 00                          cmp        word es:[1139h], 00h
dc365:  75 07                                      jnz        loc_dc36e
dc367:  c6 06 08 00 00                             mov        byte [0008h], 00h
dc36c:  eb 05                                      jmp short  loc_dc373

;  XREF: dc365
dc36e:  c6 06 08 00 01        loc_dc36e:           mov        byte [0008h], 01h

;  XREF: dc36c
dc373:  b8 3c 41              loc_dc373:           mov        ax, 413ch
dc376:  8e c0                                      mov        es, ax
dc378:  26 fe 06 b7 00                             inc        byte es:[00b7h]

;  XREF: dc32e
dc37d:  80 3e 08 00 00        loc_dc37d:           cmp        byte [0008h], 00h
dc382:  74 ac                                      jz         loc_dc330
dc384:  1f                                         pop        ds
dc385:  cb                                         retf

;  XREF: dc2d0

; -----------------------------------------------------------------------------
; dmd_target_display (0xDC386)
; Drop target display handler
; -----------------------------------------------------------------------------
dc386:  1e                    dmd_target_display:           push       ds
dc387:  b8 34 41                                   mov        ax, 4134h
dc38a:  8e d8                                      mov        ds, ax
dc38c:  6a 3d                                      push       3dh
dc38e:  0e                                         push       cs
dc38f:  e8 18 af                                   call       dmd_anim_play
dc392:  59                                         pop        cx
dc393:  6a 3c                                      push       3ch
dc395:  0e                                         push       cs
dc396:  e8 11 af                                   call       dmd_anim_play
dc399:  59                                         pop        cx
dc39a:  6a 3b                                      push       3bh
dc39c:  0e                                         push       cs
dc39d:  e8 0a af                                   call       dmd_anim_play
dc3a0:  59                                         pop        cx
dc3a1:  6a 49                                      push       49h
dc3a3:  0e                                         push       cs
dc3a4:  e8 03 af                                   call       dmd_anim_play
dc3a7:  59                                         pop        cx
dc3a8:  c6 06 08 00 00                             mov        byte [0008h], 00h
dc3ad:  b8 3c 41                                   mov        ax, 413ch
dc3b0:  8e c0                                      mov        es, ax
dc3b2:  26 c6 06 b7 00 00                          mov        byte es:[00b7h], 00h
dc3b8:  eb 4d                                      jmp short  loc_dc407

;  XREF: dc40c
dc3ba:  b8 00 40              loc_dc3ba:           mov        ax, 4000h
dc3bd:  8e c0                                      mov        es, ax
dc3bf:  26 c7 06 39 11 96 00                       mov        word es:[1139h], 0096h
dc3c6:  68 eb 00                                   push       00ebh
dc3c9:  9a 38 01 00 d0                             call       cmd_queue_push
dc3ce:  59                                         pop        cx

;  XREF: dc3e2
dc3cf:  0e                    loc_dc3cf:           push       cs
dc3d0:  e8 48 fe                                   call       dmd_mode_display_2
dc3d3:  0b c0                                      or         ax, ax
dc3d5:  75 0d                                      jnz        loc_dc3e4
dc3d7:  b8 00 40                                   mov        ax, 4000h
dc3da:  8e c0                                      mov        es, ax
dc3dc:  26 83 3e 39 11 00                          cmp        word es:[1139h], 00h
dc3e2:  75 eb                                      jnz        loc_dc3cf

;  XREF: dc3d5
dc3e4:  b8 00 40              loc_dc3e4:           mov        ax, 4000h
dc3e7:  8e c0                                      mov        es, ax
dc3e9:  26 83 3e 39 11 00                          cmp        word es:[1139h], 00h
dc3ef:  75 07                                      jnz        loc_dc3f8
dc3f1:  c6 06 08 00 00                             mov        byte [0008h], 00h
dc3f6:  eb 05                                      jmp short  loc_dc3fd

;  XREF: dc3ef
dc3f8:  c6 06 08 00 01        loc_dc3f8:           mov        byte [0008h], 01h

;  XREF: dc3f6
dc3fd:  b8 3c 41              loc_dc3fd:           mov        ax, 413ch
dc400:  8e c0                                      mov        es, ax
dc402:  26 fe 06 b7 00                             inc        byte es:[00b7h]

;  XREF: dc3b8
dc407:  80 3e 08 00 00        loc_dc407:           cmp        byte [0008h], 00h
dc40c:  74 ac                                      jz         loc_dc3ba
dc40e:  1f                                         pop        ds
dc40f:  cb                                         retf

;  XREF: dc4d0, dc543

; -----------------------------------------------------------------------------
; dmd_ramp_display (0xDC410)
; Ramp shot display handler (2 refs)
; -----------------------------------------------------------------------------
dc410:  1e                    dmd_ramp_display:           push       ds
dc411:  b8 34 41                                   mov        ax, 4134h
dc414:  8e d8                                      mov        ds, ax
dc416:  6a 3a                                      push       3ah
dc418:  0e                                         push       cs
dc419:  e8 8e ae                                   call       dmd_anim_play
dc41c:  59                                         pop        cx
dc41d:  6a 39                                      push       39h
dc41f:  0e                                         push       cs
dc420:  e8 87 ae                                   call       dmd_anim_play
dc423:  59                                         pop        cx
dc424:  6a 38                                      push       38h
dc426:  0e                                         push       cs
dc427:  e8 80 ae                                   call       dmd_anim_play
dc42a:  59                                         pop        cx
dc42b:  6a 48                                      push       48h
dc42d:  0e                                         push       cs
dc42e:  e8 79 ae                                   call       dmd_anim_play
dc431:  59                                         pop        cx

;  XREF: dc46e
dc432:  c6 06 08 00 00        loc_dc432:           mov        byte [0008h], 00h
dc437:  eb 3c                                      jmp short  loc_dc475

;  XREF: dc47a
dc439:  b8 00 40              loc_dc439:           mov        ax, 4000h
dc43c:  8e c0                                      mov        es, ax
dc43e:  26 c7 06 39 11 96 00                       mov        word es:[1139h], 0096h
dc445:  68 ea 00                                   push       00eah
dc448:  9a 38 01 00 d0                             call       cmd_queue_push
dc44d:  59                                         pop        cx

;  XREF: dc461
dc44e:  0e                    loc_dc44e:           push       cs
dc44f:  e8 bb fc                                   call       dmd_extra_ball_display
dc452:  0b c0                                      or         ax, ax
dc454:  75 0d                                      jnz        loc_dc463
dc456:  b8 00 40                                   mov        ax, 4000h
dc459:  8e c0                                      mov        es, ax
dc45b:  26 83 3e 39 11 00                          cmp        word es:[1139h], 00h
dc461:  75 eb                                      jnz        loc_dc44e

;  XREF: dc454
dc463:  b8 00 40              loc_dc463:           mov        ax, 4000h
dc466:  8e c0                                      mov        es, ax
dc468:  26 83 3e 39 11 00                          cmp        word es:[1139h], 00h
dc46e:  74 c2                                      jz         loc_dc432
dc470:  c6 06 08 00 01                             mov        byte [0008h], 01h

;  XREF: dc437
dc475:  80 3e 08 00 00        loc_dc475:           cmp        byte [0008h], 00h
dc47a:  74 bd                                      jz         loc_dc439
dc47c:  1f                                         pop        ds
dc47d:  cb                                         retf

;  XREF: dc523

; -----------------------------------------------------------------------------
; dmd_lane_display (0xDC47E)
; Lane completion display handler
; -----------------------------------------------------------------------------
dc47e:  1e                    dmd_lane_display:           push       ds
dc47f:  b8 34 41                                   mov        ax, 4134h
dc482:  8e d8                                      mov        ds, ax
dc484:  68 e9 00                                   push       00e9h
dc487:  9a 38 01 00 d0                             call       cmd_queue_push
dc48c:  59                                         pop        cx

;  XREF: dc493
dc48d:  0e                    loc_dc48d:           push       cs
dc48e:  e8 0b fc                                   call       dmd_special_display
dc491:  0b c0                                      or         ax, ax
dc493:  74 f8                                      jz         loc_dc48d
dc495:  1f                                         pop        ds
dc496:  cb                                         retf

;  XREF: dc596

; -----------------------------------------------------------------------------
; dmd_bumper_display (0xDC497)
; Bumper hit display handler
; -----------------------------------------------------------------------------
dc497:  1e                    dmd_bumper_display:           push       ds
dc498:  b8 34 41                                   mov        ax, 4134h
dc49b:  8e d8                                      mov        ds, ax
dc49d:  68 e9 00                                   push       00e9h
dc4a0:  9a 38 01 00 d0                             call       cmd_queue_push
dc4a5:  59                                         pop        cx

;  XREF: dc4ac
dc4a6:  0e                    loc_dc4a6:           push       cs
dc4a7:  e8 26 fc                                   call       dmd_jackpot_display
dc4aa:  0b c0                                      or         ax, ax
dc4ac:  74 f8                                      jz         loc_dc4a6
dc4ae:  1f                                         pop        ds
dc4af:  cb                                         retf

;  XREF: dc76e

; -----------------------------------------------------------------------------
; dmd_scoop_display (0xDC4C9)
; Scoop entry display handler
; -----------------------------------------------------------------------------
dc4c9:  1e                    dmd_scoop_display:           push       ds
dc4ca:  b8 34 41                                   mov        ax, 4134h
dc4cd:  8e d8                                      mov        ds, ax
dc4cf:  0e                                         push       cs
dc4d0:  e8 3d ff                                   call       dmd_ramp_display
dc4d3:  0e                                         push       cs
dc4d4:  e8 25 fe                                   call       dmd_orbit_display
dc4d7:  b8 3c 41                                   mov        ax, 413ch
dc4da:  8e c0                                      mov        es, ax
dc4dc:  26 80 3e f9 00 00                          cmp        byte es:[00f9h], 00h
dc4e2:  74 1a                                      jz         loc_dc4fe
dc4e4:  8e c0                                      mov        es, ax
dc4e6:  26 a0 f9 00                                mov        al, es:[00f9h]
dc4ea:  98                                         cbw
dc4eb:  ba 3c 41                                   mov        dx, 413ch
dc4ee:  8e c2                                      mov        es, dx
dc4f0:  50                                         push       ax
dc4f1:  26 a0 f8 00                                mov        al, es:[00f8h]
dc4f5:  98                                         cbw
dc4f6:  5a                                         pop        dx
dc4f7:  03 d0                                      add        dx, ax
dc4f9:  83 fa 03                                   cmp        word dx, 03h
dc4fc:  7d 24                                      jge        loc_dc522

;  XREF: dc4e2
dc4fe:  68 ef 00              loc_dc4fe:           push       00efh
dc501:  9a 38 01 00 d0                             call       cmd_queue_push
dc506:  59                                         pop        cx

;  XREF: dc50d
dc507:  0e                    loc_dc507:           push       cs
dc508:  e8 6a fb                                   call       dmd_bonus_display
dc50b:  0b c0                                      or         ax, ax
dc50d:  74 f8                                      jz         loc_dc507
dc50f:  b8 3c 41                                   mov        ax, 413ch
dc512:  8e c0                                      mov        es, ax
dc514:  26 c6 06 f9 00 03                          mov        byte es:[00f9h], 03h
dc51a:  6a 0a                                      push       0ah
dc51c:  9a e8 26 f2 d2                             call       switch_read_shared_ram
dc521:  59                                         pop        cx

;  XREF: dc4fc
dc522:  0e                    loc_dc522:           push       cs
dc523:  e8 58 ff                                   call       dmd_lane_display
dc526:  b8 3c 41                                   mov        ax, 413ch
dc529:  8e c0                                      mov        es, ax
dc52b:  26 a0 f9 00                                mov        al, es:[00f9h]
dc52f:  fe c8                                      dec        byte al
dc531:  ba 3c 41                                   mov        dx, 413ch
dc534:  8e c2                                      mov        es, dx
dc536:  26 a2 f9 00                                mov        es:[00f9h], al
dc53a:  1f                                         pop        ds
dc53b:  cb                                         retf

;  XREF: dc80c

; -----------------------------------------------------------------------------
; dmd_monolith_display (0xDC53C)
; Monolith message display handler
; -----------------------------------------------------------------------------
dc53c:  1e                    dmd_monolith_display:           push       ds
dc53d:  b8 34 41                                   mov        ax, 4134h
dc540:  8e d8                                      mov        ds, ax
dc542:  0e                                         push       cs
dc543:  e8 ca fe                                   call       dmd_ramp_display
dc546:  0e                                         push       cs
dc547:  e8 b2 fd                                   call       dmd_orbit_display
dc54a:  b8 3c 41                                   mov        ax, 413ch
dc54d:  8e c0                                      mov        es, ax
dc54f:  26 80 3e f9 00 00                          cmp        byte es:[00f9h], 00h
dc555:  74 1a                                      jz         loc_dc571
dc557:  8e c0                                      mov        es, ax
dc559:  26 a0 f9 00                                mov        al, es:[00f9h]
dc55d:  98                                         cbw
dc55e:  ba 3c 41                                   mov        dx, 413ch
dc561:  8e c2                                      mov        es, dx
dc563:  50                                         push       ax
dc564:  26 a0 f8 00                                mov        al, es:[00f8h]
dc568:  98                                         cbw
dc569:  5a                                         pop        dx
dc56a:  03 d0                                      add        dx, ax
dc56c:  83 fa 03                                   cmp        word dx, 03h
dc56f:  74 24                                      jz         loc_dc595

;  XREF: dc555
dc571:  68 ef 00              loc_dc571:           push       00efh
dc574:  9a 38 01 00 d0                             call       cmd_queue_push
dc579:  59                                         pop        cx

;  XREF: dc580
dc57a:  0e                    loc_dc57a:           push       cs
dc57b:  e8 c7 fa                                   call       dmd_multiball_display
dc57e:  0b c0                                      or         ax, ax
dc580:  74 f8                                      jz         loc_dc57a
dc582:  b8 3c 41                                   mov        ax, 413ch
dc585:  8e c0                                      mov        es, ax
dc587:  26 c6 06 f9 00 03                          mov        byte es:[00f9h], 03h
dc58d:  6a 0a                                      push       0ah
dc58f:  9a e8 26 f2 d2                             call       switch_read_shared_ram
dc594:  59                                         pop        cx

;  XREF: dc56f
dc595:  0e                    loc_dc595:           push       cs
dc596:  e8 fe fe                                   call       dmd_bumper_display
dc599:  b8 3c 41                                   mov        ax, 413ch
dc59c:  8e c0                                      mov        es, ax
dc59e:  26 a0 f9 00                                mov        al, es:[00f9h]
dc5a2:  fe c8                                      dec        byte al
dc5a4:  ba 3c 41                                   mov        dx, 413ch
dc5a7:  8e c2                                      mov        es, dx
dc5a9:  26 a2 f9 00                                mov        es:[00f9h], al
dc5ad:  1f                                         pop        ds
dc5ae:  cb                                         retf

;  XREF: d3711

; -----------------------------------------------------------------------------
; dmd_tilt_display (0xDC71B)
; Tilt warning display handler
; -----------------------------------------------------------------------------
dc71b:  1e                    dmd_tilt_display:           push       ds
dc71c:  b8 34 41                                   mov        ax, 4134h
dc71f:  8e d8                                      mov        ds, ax
dc721:  68 ee 00                                   push       00eeh
dc724:  9a 38 01 00 d0                             call       cmd_queue_push
dc729:  59                                         pop        cx
dc72a:  fe 06 26 00                                inc        byte [0026h]
dc72e:  fe 0e 30 00                                dec        byte [0030h]
dc732:  c6 06 22 00 01                             mov        byte [0022h], 01h
dc737:  6a 14                                      push       14h
dc739:  9a e8 26 f2 d2                             call       switch_read_shared_ram
dc73e:  59                                         pop        cx
dc73f:  6a 44                                      push       44h
dc741:  0e                                         push       cs
dc742:  e8 65 ab                                   call       dmd_anim_play
dc745:  59                                         pop        cx
dc746:  b8 01 00                                   mov        ax, 0001h
dc749:  1f                                         pop        ds
dc74a:  cb                                         retf

;  XREF: d3203, d4588

; -----------------------------------------------------------------------------
; dmd_end_of_ball_display (0xDC74B)
; End of ball display (2 refs)
; -----------------------------------------------------------------------------
dc74b:  1e                    dmd_end_of_ball_display:           push       ds
dc74c:  b8 34 41                                   mov        ax, 4134h
dc74f:  8e d8                                      mov        ds, ax
dc751:  9a 4d 17 00 f0                             call       game_end_transition_to_attract
dc756:  9a cf 22 f2 d2                             call       game_end_sequence
dc75b:  68 c7 00                                   push       00c7h
dc75e:  9a 38 01 00 d0                             call       cmd_queue_push
dc763:  59                                         pop        cx
dc764:  0e                                         push       cs
dc765:  e8 6a f7                                   call       hardware_io_write
dc768:  c6 06 24 00 01                             mov        byte [0024h], 01h
dc76d:  0e                                         push       cs
dc76e:  e8 58 fd                                   call       dmd_scoop_display
dc771:  6a 14                                      push       14h
dc773:  9a e8 26 f2 d2                             call       switch_read_shared_ram
dc778:  59                                         pop        cx
dc779:  68 f3 00                                   push       00f3h
dc77c:  9a 38 01 00 d0                             call       cmd_queue_push
dc781:  59                                         pop        cx
dc782:  0e                                         push       cs
dc783:  e8 6c ab                                   call       dmd_anim_frame_advance
dc786:  68 b3 00                                   push       00b3h
dc789:  9a 38 01 00 d0                             call       cmd_queue_push
dc78e:  59                                         pop        cx
dc78f:  b8 3c 41                                   mov        ax, 413ch
dc792:  8e c0                                      mov        es, ax
dc794:  26 c6 06 eb 00 00                          mov        byte es:[00ebh], 00h

;  XREF: dc7a0
dc79a:  0e                    loc_dc79a:           push       cs
dc79b:  e8 74 b2                                   call       dmd_scroll_text
dc79e:  0b c0                                      or         ax, ax
dc7a0:  74 f8                                      jz         loc_dc79a
dc7a2:  c6 06 24 00 00                             mov        byte [0024h], 00h
dc7a7:  0e                                         push       cs
dc7a8:  e8 58 e3                                   call       dmd_effect_handler
dc7ab:  0e                                         push       cs
dc7ac:  e8 43 ab                                   call       dmd_anim_frame_advance
dc7af:  68 c7 00                                   push       00c7h
dc7b2:  9a 38 01 00 d0                             call       cmd_queue_push
dc7b7:  59                                         pop        cx
dc7b8:  b8 3c 41                                   mov        ax, 413ch
dc7bb:  8e c0                                      mov        es, ax
dc7bd:  26 80 3e eb 00 01                          cmp        byte es:[00ebh], 01h
dc7c3:  74 10                                      jz         loc_dc7d5
dc7c5:  0e                                         push       cs
dc7c6:  e8 6c b0                                   call       dmd_effect_wipe
dc7c9:  b8 00 40                                   mov        ax, 4000h
dc7cc:  8e c0                                      mov        es, ax
dc7ce:  26 c7 06 3d 11 b0 04                       mov        word es:[113dh], 04b0h

;  XREF: dc7c3
dc7d5:  1f                    loc_dc7d5:           pop        ds
dc7d6:  cb                                         retf

;  XREF: d3120

; -----------------------------------------------------------------------------
; dmd_game_over_display (0xDC7D7)
; Game over display handler
; -----------------------------------------------------------------------------
dc7d7:  1e                    dmd_game_over_display:           push       ds
dc7d8:  b8 34 41                                   mov        ax, 4134h
dc7db:  8e d8                                      mov        ds, ax
dc7dd:  b8 3c 41                                   mov        ax, 413ch
dc7e0:  8e c0                                      mov        es, ax
dc7e2:  26 c6 06 eb 00 00                          mov        byte es:[00ebh], 00h
dc7e8:  0e                                         push       cs
dc7e9:  e8 3a f5                                   call       solenoid_state_write
dc7ec:  0e                                         push       cs
dc7ed:  e8 b1 f4                                   call       game_reset_state
dc7f0:  9a 85 04 f2 d2                             call       game_start_sequence
dc7f5:  68 c7 00                                   push       00c7h
dc7f8:  9a 38 01 00 d0                             call       cmd_queue_push
dc7fd:  59                                         pop        cx
dc7fe:  0e                                         push       cs
dc7ff:  e8 68 f5                                   call       solenoid_pulse_write
dc802:  c6 06 24 00 01                             mov        byte [0024h], 01h
dc807:  0e                                         push       cs
dc808:  e8 e7 aa                                   call       dmd_anim_frame_advance
dc80b:  0e                                         push       cs
dc80c:  e8 2d fd                                   call       dmd_monolith_display
dc80f:  6a 14                                      push       14h
dc811:  9a e8 26 f2 d2                             call       switch_read_shared_ram
dc816:  59                                         pop        cx
dc817:  68 f3 00                                   push       00f3h
dc81a:  9a 38 01 00 d0                             call       cmd_queue_push
dc81f:  59                                         pop        cx
dc820:  68 b3 00                                   push       00b3h
dc823:  9a 38 01 00 d0                             call       cmd_queue_push
dc828:  59                                         pop        cx

;  XREF: dc843
dc829:  c6 06 09 00 00        loc_dc829:           mov        byte [0009h], 00h
dc82e:  eb 1a                                      jmp short  loc_dc84a

;  XREF: dc836, dc84f
dc830:  0e                    loc_dc830:           push       cs
dc831:  e8 46 b3                                   call       dmd_anim_resource_play
dc834:  0b c0                                      or         ax, ax
dc836:  74 f8                                      jz         loc_dc830
dc838:  b8 3c 41                                   mov        ax, 413ch
dc83b:  8e c0                                      mov        es, ax
dc83d:  26 80 3e d6 00 40                          cmp        byte es:[00d6h], 40h ; last_switch_code - Last switch code received from Z80
dc843:  74 e4                                      jz         loc_dc829
dc845:  c6 06 09 00 01                             mov        byte [0009h], 01h

;  XREF: dc82e
dc84a:  80 3e 09 00 01        loc_dc84a:           cmp        byte [0009h], 01h
dc84f:  75 df                                      jnz        loc_dc830
dc851:  c6 06 24 00 00                             mov        byte [0024h], 00h
dc856:  68 c7 00                                   push       00c7h
dc859:  9a 38 01 00 d0                             call       cmd_queue_push
dc85e:  59                                         pop        cx
dc85f:  b8 3c 41                                   mov        ax, 413ch
dc862:  8e c0                                      mov        es, ax
dc864:  26 c6 06 4f 01 04                          mov        byte es:[014fh], 04h ; game_state_var - STATE MACHINE variable: 0=init, 1=attract, 2=game_active, 4=special_mode
dc86a:  b8 00 40                                   mov        ax, 4000h
dc86d:  8e c0                                      mov        es, ax
dc86f:  26 c6 06 44 11 00                          mov        byte es:[1144h], 00h
dc875:  9a 14 05 00 d0                             call       display_set_position_16refs
dc87a:  50                                         push       ax
dc87b:  9a 49 05 00 d0                             call       display_set_segment_14refs
dc880:  5a                                         pop        dx
dc881:  02 d0                                      add        dl, al
dc883:  52                                         push       dx
dc884:  9a d2 04 00 d0                             call       display_write_word_12refs
dc889:  59                                         pop        cx
dc88a:  6a 00                                      push       00h
dc88c:  9a f3 04 00 d0                             call       display_set_mode_10refs
dc891:  59                                         pop        cx
dc892:  b8 3c 41                                   mov        ax, 413ch
dc895:  8e c0                                      mov        es, ax
dc897:  26 c6 06 d5 00 00                          mov        byte es:[00d5h], 00h
dc89d:  b8 3c 41                                   mov        ax, 413ch
dc8a0:  8e c0                                      mov        es, ax
dc8a2:  26 80 3e de 00 01                          cmp        byte es:[00deh], 01h
dc8a8:  75 05                                      jnz        loc_dc8af
dc8aa:  9a de 0f 00 f0                             call       ram_test

;  XREF: dc8a8
dc8af:  6a 5e                 loc_dc8af:           push       5eh
dc8b1:  9a 38 01 00 d0                             call       cmd_queue_push
dc8b6:  59                                         pop        cx
dc8b7:  b8 3c 41                                   mov        ax, 413ch
dc8ba:  8e c0                                      mov        es, ax
dc8bc:  26 c6 06 de 00 00                          mov        byte es:[00deh], 00h
dc8c2:  b8 3c 41                                   mov        ax, 413ch
dc8c5:  8e c0                                      mov        es, ax
dc8c7:  26 80 3e e0 00 01                          cmp        byte es:[00e0h], 01h
dc8cd:  75 10                                      jnz        loc_dc8df
dc8cf:  9a 96 0e 00 f0                             call       eeprom_read
dc8d4:  b8 3c 41                                   mov        ax, 413ch
dc8d7:  8e c0                                      mov        es, ax
dc8d9:  26 c6 06 e0 00 00                          mov        byte es:[00e0h], 00h

;  XREF: dc8cd
dc8df:  b8 3c 41              loc_dc8df:           mov        ax, 413ch
dc8e2:  8e c0                                      mov        es, ax
dc8e4:  26 80 3e eb 00 01                          cmp        byte es:[00ebh], 01h
dc8ea:  74 10                                      jz         loc_dc8fc
dc8ec:  0e                                         push       cs
dc8ed:  e8 45 af                                   call       dmd_effect_wipe
dc8f0:  b8 00 40                                   mov        ax, 4000h
dc8f3:  8e c0                                      mov        es, ax
dc8f5:  26 c7 06 3d 11 b0 04                       mov        word es:[113dh], 04b0h

;  XREF: dc8ea
dc8fc:  1f                    loc_dc8fc:           pop        ds
dc8fd:  cb                                         retf

;  XREF: dbb53, dbb5b, dbb63, dbb6b, dbb73

; -----------------------------------------------------------------------------
; game_var_indexed_read (0xDC8FE)
; Read indexed game variable from player structure (5 refs)
; -----------------------------------------------------------------------------
dc8fe:  55                    game_var_indexed_read:           push       bp
dc8ff:  8b ec                                      mov        bp, sp
dc901:  1e                                         push       ds
dc902:  b8 34 41                                   mov        ax, 4134h
dc905:  8e d8                                      mov        ds, ax
dc907:  8a 46 06                                   mov        al, [bp+06h]
dc90a:  98                                         cbw
dc90b:  ba 3c 41                                   mov        dx, 413ch
dc90e:  8b d8                                      mov        bx, ax
dc910:  8e c2                                      mov        es, dx
dc912:  26 c6 87 04 01 02                          mov        byte es:[bx+0104h], 02h
dc918:  8a 46 06                                   mov        al, [bp+06h]
dc91b:  98                                         cbw
dc91c:  d1 e0                                      shl        ax, 1
dc91e:  ba 00 00                                   mov        dx, 0000h
dc921:  8b d8                                      mov        bx, ax
dc923:  8e c2                                      mov        es, dx
dc925:  26 8a 87 43 0a                             mov        al, es:[bx+0a43h]
dc92a:  50                                         push       ax
dc92b:  9a 38 01 00 d0                             call       cmd_queue_push
dc930:  59                                         pop        cx
dc931:  1f                                         pop        ds
dc932:  5d                                         pop        bp
dc933:  cb                                         retf

;  XREF: d92ed, d92f5, dbc2a

; -----------------------------------------------------------------------------
; game_var_indexed_write (0xDC934)
; Write indexed game variable to player structure (3 refs)
; -----------------------------------------------------------------------------
dc934:  55                    game_var_indexed_write:           push       bp
dc935:  8b ec                                      mov        bp, sp
dc937:  1e                                         push       ds
dc938:  b8 34 41                                   mov        ax, 4134h
dc93b:  8e d8                                      mov        ds, ax
dc93d:  8a 46 06                                   mov        al, [bp+06h]
dc940:  98                                         cbw
dc941:  ba 3c 41                                   mov        dx, 413ch
dc944:  8b d8                                      mov        bx, ax
dc946:  8e c2                                      mov        es, dx
dc948:  26 80 bf 04 01 02                          cmp        byte es:[bx+0104h], 02h
dc94e:  74 27                                      jz         loc_dc977
dc950:  8a 46 06                                   mov        al, [bp+06h]
dc953:  98                                         cbw
dc954:  8b d8                                      mov        bx, ax
dc956:  8e c2                                      mov        es, dx
dc958:  26 c6 87 04 01 01                          mov        byte es:[bx+0104h], 01h
dc95e:  8a 46 06                                   mov        al, [bp+06h]
dc961:  98                                         cbw
dc962:  d1 e0                                      shl        ax, 1
dc964:  ba 00 00                                   mov        dx, 0000h
dc967:  8b d8                                      mov        bx, ax
dc969:  8e c2                                      mov        es, dx
dc96b:  26 8a 87 43 0a                             mov        al, es:[bx+0a43h]
dc970:  50                                         push       ax
dc971:  9a 38 01 00 d0                             call       cmd_queue_push
dc976:  59                                         pop        cx

;  XREF: dc94e
dc977:  1f                    loc_dc977:           pop        ds
dc978:  5d                                         pop        bp
dc979:  cb                                         retf

;  XREF: d9366, d9381, dbc22, dbeca, dc03d

; -----------------------------------------------------------------------------
; game_var_increment (0xDC97A)
; Increment game variable/counter (5 refs)
; -----------------------------------------------------------------------------
dc97a:  55                    game_var_increment:           push       bp
dc97b:  8b ec                                      mov        bp, sp
dc97d:  1e                                         push       ds
dc97e:  b8 34 41                                   mov        ax, 4134h
dc981:  8e d8                                      mov        ds, ax
dc983:  8a 46 06                                   mov        al, [bp+06h]
dc986:  98                                         cbw
dc987:  ba 3c 41                                   mov        dx, 413ch
dc98a:  8b d8                                      mov        bx, ax
dc98c:  8e c2                                      mov        es, dx
dc98e:  26 80 bf 04 01 02                          cmp        byte es:[bx+0104h], 02h
dc994:  74 27                                      jz         loc_dc9bd
dc996:  8a 46 06                                   mov        al, [bp+06h]
dc999:  98                                         cbw
dc99a:  8b d8                                      mov        bx, ax
dc99c:  8e c2                                      mov        es, dx
dc99e:  26 c6 87 04 01 00                          mov        byte es:[bx+0104h], 00h
dc9a4:  8a 46 06                                   mov        al, [bp+06h]
dc9a7:  98                                         cbw
dc9a8:  d1 e0                                      shl        ax, 1
dc9aa:  ba 00 00                                   mov        dx, 0000h
dc9ad:  8b d8                                      mov        bx, ax
dc9af:  8e c2                                      mov        es, dx
dc9b1:  26 8a 87 42 0a                             mov        al, es:[bx+0a42h]
dc9b6:  50                                         push       ax
dc9b7:  9a 38 01 00 d0                             call       cmd_queue_push
dc9bc:  59                                         pop        cx

;  XREF: dc994
dc9bd:  1f                    loc_dc9bd:           pop        ds
dc9be:  5d                                         pop        bp
dc9bf:  cb                                         retf

;  XREF: d317b, d321d, d3787, d37f4, d3daf (+22 more)

; -----------------------------------------------------------------------------
; score_compare_and_cap (0xDC9C0)
; Compare score against limit (999,999,999) and cap if exceeded (27+ refs - core scoring function)
; -----------------------------------------------------------------------------
dc9c0:  c8 08 00 00           score_compare_and_cap:           enter      0008h, 00h
dc9c4:  1e                                         push       ds
dc9c5:  b8 34 41                                   mov        ax, 4134h
dc9c8:  8e d8                                      mov        ds, ax
dc9ca:  c7 46 fe 00 00                             mov        word [bp-02h], 0000h
dc9cf:  81 7e 0c 9a 3b                             cmp        word [bp+0ch], 3b9ah
dc9d4:  7c 15                                      jl         loc_dc9eb
dc9d6:  7f 07                                      jg         loc_dc9df
dc9d8:  81 7e 0a ff c9                             cmp        word [bp+0ah], c9ffh
dc9dd:  76 0c                                      jbe        loc_dc9eb

;  XREF: dc9d6
dc9df:  c7 46 fa 9a 3b        loc_dc9df:           mov        word [bp-06h], 3b9ah
dc9e4:  c7 46 f8 ff c9                             mov        word [bp-08h], c9ffh
dc9e9:  eb 0c                                      jmp short  loc_dc9f7

;  XREF: dc9d4, dc9dd
dc9eb:  8b 46 0c              loc_dc9eb:           mov        ax, [bp+0ch]
dc9ee:  8b 56 0a                                   mov        dx, [bp+0ah]
dc9f1:  89 46 fa                                   mov        [bp-06h], ax
dc9f4:  89 56 f8                                   mov        [bp-08h], dx

;  XREF: dc9e9
dc9f7:  c7 46 fc 00 00        loc_dc9f7:           mov        word [bp-04h], 0000h
dc9fc:  eb 0d                                      jmp short  loc_dca0b

;  XREF: dca0f
dc9fe:  c4 5e 06              loc_dc9fe:           les        bx, [bp+06h]
dca01:  03 5e fc                                   add        bx, [bp-04h]
dca04:  26 c6 07 00                                mov        byte es:[bx], 00h
dca08:  ff 46 fc                                   inc        word [bp-04h]

;  XREF: dc9fc
dca0b:  83 7e fc 08           loc_dca0b:           cmp        word [bp-04h], 08h
dca0f:  7e ed                                      jle        loc_dc9fe
dca11:  c7 46 fc 00 00                             mov        word [bp-04h], 0000h
dca16:  eb 0b                                      jmp short  loc_dca23

;  XREF: dca27
dca18:  8b 5e fc              loc_dca18:           mov        bx, [bp-04h]
dca1b:  c6 87 0b 00 00                             mov        byte [bx+000bh], 00h
dca20:  ff 46 fc                                   inc        word [bp-04h]

;  XREF: dca16
dca23:  83 7e fc 08           loc_dca23:           cmp        word [bp-04h], 08h
dca27:  7e ef                                      jle        loc_dca18
dca29:  8b 46 0a                                   mov        ax, [bp+0ah]
dca2c:  0b 46 0c                                   or         ax, [bp+0ch]
dca2f:  74 5a                                      jz         loc_dca8b

;  XREF: dca62
dca31:  6a 00                 loc_dca31:           push       00h
dca33:  6a 0a                                      push       0ah
dca35:  ff 76 fa                                   push       word [bp-06h]
dca38:  ff 76 f8                                   push       word [bp-08h]
dca3b:  9a 18 00 26 e3                             call       player_struct_read_word
dca40:  8b 5e fe                                   mov        bx, [bp-02h]
dca43:  88 87 0b 00                                mov        [bx+000bh], al
dca47:  6a 00                                      push       00h
dca49:  6a 0a                                      push       0ah
dca4b:  ff 76 fa                                   push       word [bp-06h]
dca4e:  ff 76 f8                                   push       word [bp-08h]
dca51:  9a 09 00 26 e3                             call       player_struct_read_byte
dca56:  89 56 fa                                   mov        [bp-06h], dx
dca59:  89 46 f8                                   mov        [bp-08h], ax
dca5c:  ff 46 fe                                   inc        word [bp-02h]
dca5f:  0b 46 fa                                   or         ax, [bp-06h]
dca62:  75 cd                                      jnz        loc_dca31
dca64:  c7 46 fc 08 00                             mov        word [bp-04h], 0008h
dca69:  eb 1a                                      jmp short  loc_dca85

;  XREF: dca89
dca6b:  8b 5e fc              loc_dca6b:           mov        bx, [bp-04h]
dca6e:  8a 87 0b 00                                mov        al, [bx+000bh]
dca72:  bb 09 00                                   mov        bx, 0009h
dca75:  2b 5e fc                                   sub        bx, [bp-04h]
dca78:  8e 46 08                                   mov        es, [bp+08h]
dca7b:  03 5e 06                                   add        bx, [bp+06h]
dca7e:  26 88 47 ff                                mov        es:[bx-01h], al
dca82:  ff 4e fc                                   dec        word [bp-04h]

;  XREF: dca69
dca85:  83 7e fc 00           loc_dca85:           cmp        word [bp-04h], 00h
dca89:  7d e0                                      jge        loc_dca6b

;  XREF: dca2f
dca8b:  b8 01 00              loc_dca8b:           mov        ax, 0001h
dca8e:  1f                                         pop        ds
dca8f:  c9                                         leave
dca90:  cb                                         retf

;  XREF: d30b3, d7544, d7c68

; -----------------------------------------------------------------------------
; credits_display_check (0xDCD29)
; Check credit count and update display (3 refs)
; -----------------------------------------------------------------------------
dcd29:  1e                    credits_display_check:           push       ds
dcd2a:  b8 34 41                                   mov        ax, 4134h
dcd2d:  8e d8                                      mov        ds, ax
dcd2f:  b8 3c 41                                   mov        ax, 413ch
dcd32:  8e c0                                      mov        es, ax
dcd34:  26 80 3e d4 00 63                          cmp        byte es:[00d4h], 63h ; credit_available - Non-zero when credits are available for game start
dcd3a:  7e 10                                      jle        loc_dcd4c
dcd3c:  6a 00                                      push       00h
dcd3e:  9a f3 04 00 d0                             call       display_set_mode_10refs
dcd43:  59                                         pop        cx
dcd44:  6a 00                                      push       00h
dcd46:  9a d2 04 00 d0                             call       display_write_word_12refs
dcd4b:  59                                         pop        cx

;  XREF: dcd3a
dcd4c:  9a 49 05 00 d0        loc_dcd4c:           call       display_set_segment_14refs
dcd51:  50                                         push       ax
dcd52:  9a 14 05 00 d0                             call       display_set_position_16refs
dcd57:  5a                                         pop        dx
dcd58:  02 d0                                      add        dl, al
dcd5a:  b8 3c 41                                   mov        ax, 413ch
dcd5d:  8e c0                                      mov        es, ax
dcd5f:  26 88 16 d4 00                             mov        es:[00d4h], dl ; credit_available - Non-zero when credits are available for game start
dcd64:  8e c0                                      mov        es, ax
dcd66:  26 a0 d4 00                                mov        al, es:[00d4h] ; credit_available - Non-zero when credits are available for game start
dcd6a:  a2 0a 00                                   mov        [000ah], al
dcd6d:  b4 00                                      mov        ah, 00h
dcd6f:  bb 0a 00                                   mov        bx, 000ah
dcd72:  99                                         cwd
dcd73:  f7 fb                                      idiv       word bx
dcd75:  b8 3c 41                                   mov        ax, 413ch
dcd78:  8e c0                                      mov        es, ax
dcd7a:  26 88 16 d2 00                             mov        es:[00d2h], dl
dcd7f:  a0 0a 00                                   mov        al, [000ah]
dcd82:  b4 00                                      mov        ah, 00h
dcd84:  99                                         cwd
dcd85:  f7 fb                                      idiv       word bx
dcd87:  a2 0a 00                                   mov        [000ah], al
dcd8a:  b4 00                                      mov        ah, 00h
dcd8c:  99                                         cwd
dcd8d:  f7 fb                                      idiv       word bx
dcd8f:  b8 3c 41                                   mov        ax, 413ch
dcd92:  8e c0                                      mov        es, ax
dcd94:  26 88 16 d3 00                             mov        es:[00d3h], dl
dcd99:  b8 01 00                                   mov        ax, 0001h
dcd9c:  1f                                         pop        ds
dcd9d:  cb                                         retf

;  XREF: d8050

; -----------------------------------------------------------------------------
; credits_award_free_game (0xDCD9E)
; Award free game from credit system
; -----------------------------------------------------------------------------
dcd9e:  1e                    credits_award_free_game:           push       ds
dcd9f:  b8 34 41                                   mov        ax, 4134h
dcda2:  8e d8                                      mov        ds, ax
dcda4:  c6 06 36 00 00                             mov        byte [0036h], 00h
dcda9:  a0 35 00                                   mov        al, [0035h]
dcdac:  98                                         cbw
dcdad:  ba 3c 41                                   mov        dx, 413ch
dcdb0:  8e c2                                      mov        es, dx
dcdb2:  50                                         push       ax
dcdb3:  26 a0 b0 00                                mov        al, es:[00b0h]
dcdb7:  98                                         cbw
dcdb8:  8b d8                                      mov        bx, ax
dcdba:  58                                         pop        ax
dcdbb:  99                                         cwd
dcdbc:  f7 fb                                      idiv       word bx
dcdbe:  0b c0                                      or         ax, ax
dcdc0:  74 70                                      jz         loc_dce32
dcdc2:  a0 35 00                                   mov        al, [0035h]
dcdc5:  98                                         cbw
dcdc6:  ba 3c 41                                   mov        dx, 413ch
dcdc9:  8e c2                                      mov        es, dx
dcdcb:  50                                         push       ax
dcdcc:  26 a0 b0 00                                mov        al, es:[00b0h]
dcdd0:  98                                         cbw
dcdd1:  8b d8                                      mov        bx, ax
dcdd3:  58                                         pop        ax
dcdd4:  99                                         cwd
dcdd5:  f7 fb                                      idiv       word bx
dcdd7:  ba 3c 41                                   mov        dx, 413ch
dcdda:  8e c2                                      mov        es, dx
dcddc:  50                                         push       ax
dcddd:  26 a0 ac 00                                mov        al, es:[00ach]
dcde1:  98                                         cbw
dcde2:  5a                                         pop        dx
dcde3:  f7 ea                                      imul       word dx
dcde5:  50                                         push       ax
dcde6:  9a 0b 5d 2a d7                             call       eeprom_stat_update
dcdeb:  59                                         pop        cx
dcdec:  0b c0                                      or         ax, ax
dcdee:  74 1f                                      jz         loc_dce0f
dcdf0:  a0 35 00                                   mov        al, [0035h]
dcdf3:  98                                         cbw
dcdf4:  ba 3c 41                                   mov        dx, 413ch
dcdf7:  8e c2                                      mov        es, dx
dcdf9:  50                                         push       ax
dcdfa:  26 a0 b0 00                                mov        al, es:[00b0h]
dcdfe:  98                                         cbw
dcdff:  8b d8                                      mov        bx, ax
dce01:  58                                         pop        ax
dce02:  99                                         cwd
dce03:  f7 fb                                      idiv       word bx
dce05:  b8 3c 41                                   mov        ax, 413ch
dce08:  8e c0                                      mov        es, ax
dce0a:  26 88 16 d5 00                             mov        es:[00d5h], dl

;  XREF: dcdee
dce0f:  a0 35 00              loc_dce0f:           mov        al, [0035h]
dce12:  98                                         cbw
dce13:  ba 3c 41                                   mov        dx, 413ch
dce16:  8e c2                                      mov        es, dx
dce18:  50                                         push       ax
dce19:  26 a0 b0 00                                mov        al, es:[00b0h]
dce1d:  98                                         cbw
dce1e:  8b d8                                      mov        bx, ax
dce20:  58                                         pop        ax
dce21:  99                                         cwd
dce22:  f7 fb                                      idiv       word bx
dce24:  88 16 35 00                                mov        [0035h], dl
dce28:  80 3e 35 00 00                             cmp        byte [0035h], 00h
dce2d:  75 03                                      jnz        loc_dce32
dce2f:  e9 75 01                                   jmp        loc_dcfa7

;  XREF: dcdc0, dce2d
dce32:  a0 35 00              loc_dce32:           mov        al, [0035h]
dce35:  98                                         cbw
dce36:  ba 3c 41                                   mov        dx, 413ch
dce39:  8e c2                                      mov        es, dx
dce3b:  50                                         push       ax
dce3c:  26 a0 af 00                                mov        al, es:[00afh]
dce40:  98                                         cbw
dce41:  8b d8                                      mov        bx, ax
dce43:  58                                         pop        ax
dce44:  99                                         cwd
dce45:  f7 fb                                      idiv       word bx
dce47:  0b c0                                      or         ax, ax
dce49:  74 70                                      jz         loc_dcebb
dce4b:  a0 35 00                                   mov        al, [0035h]
dce4e:  98                                         cbw
dce4f:  ba 3c 41                                   mov        dx, 413ch
dce52:  8e c2                                      mov        es, dx
dce54:  50                                         push       ax
dce55:  26 a0 af 00                                mov        al, es:[00afh]
dce59:  98                                         cbw
dce5a:  8b d8                                      mov        bx, ax
dce5c:  58                                         pop        ax
dce5d:  99                                         cwd
dce5e:  f7 fb                                      idiv       word bx
dce60:  ba 3c 41                                   mov        dx, 413ch
dce63:  8e c2                                      mov        es, dx
dce65:  50                                         push       ax
dce66:  26 a0 ab 00                                mov        al, es:[00abh]
dce6a:  98                                         cbw
dce6b:  5a                                         pop        dx
dce6c:  f7 ea                                      imul       word dx
dce6e:  50                                         push       ax
dce6f:  9a 0b 5d 2a d7                             call       eeprom_stat_update
dce74:  59                                         pop        cx
dce75:  0b c0                                      or         ax, ax
dce77:  74 1f                                      jz         loc_dce98
dce79:  a0 35 00                                   mov        al, [0035h]
dce7c:  98                                         cbw
dce7d:  ba 3c 41                                   mov        dx, 413ch
dce80:  8e c2                                      mov        es, dx
dce82:  50                                         push       ax
dce83:  26 a0 af 00                                mov        al, es:[00afh]
dce87:  98                                         cbw
dce88:  8b d8                                      mov        bx, ax
dce8a:  58                                         pop        ax
dce8b:  99                                         cwd
dce8c:  f7 fb                                      idiv       word bx
dce8e:  b8 3c 41                                   mov        ax, 413ch
dce91:  8e c0                                      mov        es, ax
dce93:  26 88 16 d5 00                             mov        es:[00d5h], dl

;  XREF: dce77
dce98:  a0 35 00              loc_dce98:           mov        al, [0035h]
dce9b:  98                                         cbw
dce9c:  ba 3c 41                                   mov        dx, 413ch
dce9f:  8e c2                                      mov        es, dx
dcea1:  50                                         push       ax
dcea2:  26 a0 af 00                                mov        al, es:[00afh]
dcea6:  98                                         cbw
dcea7:  8b d8                                      mov        bx, ax
dcea9:  58                                         pop        ax
dceaa:  99                                         cwd
dceab:  f7 fb                                      idiv       word bx
dcead:  88 16 35 00                                mov        [0035h], dl
dceb1:  80 3e 35 00 00                             cmp        byte [0035h], 00h
dceb6:  75 03                                      jnz        loc_dcebb
dceb8:  e9 ec 00                                   jmp        loc_dcfa7

;  XREF: dce49, dceb6
dcebb:  a0 35 00              loc_dcebb:           mov        al, [0035h]
dcebe:  98                                         cbw
dcebf:  ba 3c 41                                   mov        dx, 413ch
dcec2:  8e c2                                      mov        es, dx
dcec4:  50                                         push       ax
dcec5:  26 a0 ae 00                                mov        al, es:[00aeh]
dcec9:  98                                         cbw
dceca:  8b d8                                      mov        bx, ax
dcecc:  58                                         pop        ax
dcecd:  99                                         cwd
dcece:  f7 fb                                      idiv       word bx
dced0:  0b c0                                      or         ax, ax
dced2:  74 6d                                      jz         loc_dcf41
dced4:  a0 35 00                                   mov        al, [0035h]
dced7:  98                                         cbw
dced8:  ba 3c 41                                   mov        dx, 413ch
dcedb:  8e c2                                      mov        es, dx
dcedd:  50                                         push       ax
dcede:  26 a0 ae 00                                mov        al, es:[00aeh]
dcee2:  98                                         cbw
dcee3:  8b d8                                      mov        bx, ax
dcee5:  58                                         pop        ax
dcee6:  99                                         cwd
dcee7:  f7 fb                                      idiv       word bx
dcee9:  ba 3c 41                                   mov        dx, 413ch
dceec:  8e c2                                      mov        es, dx
dceee:  50                                         push       ax
dceef:  26 a0 aa 00                                mov        al, es:[00aah]
dcef3:  98                                         cbw
dcef4:  5a                                         pop        dx
dcef5:  f7 ea                                      imul       word dx
dcef7:  50                                         push       ax
dcef8:  9a 0b 5d 2a d7                             call       eeprom_stat_update
dcefd:  59                                         pop        cx
dcefe:  0b c0                                      or         ax, ax
dcf00:  74 1f                                      jz         loc_dcf21
dcf02:  a0 35 00                                   mov        al, [0035h]
dcf05:  98                                         cbw
dcf06:  ba 3c 41                                   mov        dx, 413ch
dcf09:  8e c2                                      mov        es, dx
dcf0b:  50                                         push       ax
dcf0c:  26 a0 ae 00                                mov        al, es:[00aeh]
dcf10:  98                                         cbw
dcf11:  8b d8                                      mov        bx, ax
dcf13:  58                                         pop        ax
dcf14:  99                                         cwd
dcf15:  f7 fb                                      idiv       word bx
dcf17:  b8 3c 41                                   mov        ax, 413ch
dcf1a:  8e c0                                      mov        es, ax
dcf1c:  26 88 16 d5 00                             mov        es:[00d5h], dl

;  XREF: dcf00
dcf21:  a0 35 00              loc_dcf21:           mov        al, [0035h]
dcf24:  98                                         cbw
dcf25:  ba 3c 41                                   mov        dx, 413ch
dcf28:  8e c2                                      mov        es, dx
dcf2a:  50                                         push       ax
dcf2b:  26 a0 ae 00                                mov        al, es:[00aeh]
dcf2f:  98                                         cbw
dcf30:  8b d8                                      mov        bx, ax
dcf32:  58                                         pop        ax
dcf33:  99                                         cwd
dcf34:  f7 fb                                      idiv       word bx
dcf36:  88 16 35 00                                mov        [0035h], dl
dcf3a:  80 3e 35 00 00                             cmp        byte [0035h], 00h
dcf3f:  74 66                                      jz         loc_dcfa7

;  XREF: dced2
dcf41:  a0 35 00              loc_dcf41:           mov        al, [0035h]
dcf44:  98                                         cbw
dcf45:  ba 3c 41                                   mov        dx, 413ch
dcf48:  8e c2                                      mov        es, dx
dcf4a:  50                                         push       ax
dcf4b:  26 a0 ad 00                                mov        al, es:[00adh]
dcf4f:  98                                         cbw
dcf50:  8b d8                                      mov        bx, ax
dcf52:  58                                         pop        ax
dcf53:  99                                         cwd
dcf54:  f7 fb                                      idiv       word bx
dcf56:  0b c0                                      or         ax, ax
dcf58:  74 4d                                      jz         loc_dcfa7
dcf5a:  a0 35 00                                   mov        al, [0035h]
dcf5d:  98                                         cbw
dcf5e:  ba 3c 41                                   mov        dx, 413ch
dcf61:  8e c2                                      mov        es, dx
dcf63:  50                                         push       ax
dcf64:  26 a0 ad 00                                mov        al, es:[00adh]
dcf68:  98                                         cbw
dcf69:  8b d8                                      mov        bx, ax
dcf6b:  58                                         pop        ax
dcf6c:  99                                         cwd
dcf6d:  f7 fb                                      idiv       word bx
dcf6f:  ba 3c 41                                   mov        dx, 413ch
dcf72:  8e c2                                      mov        es, dx
dcf74:  50                                         push       ax
dcf75:  26 a0 a9 00                                mov        al, es:[00a9h]
dcf79:  98                                         cbw
dcf7a:  5a                                         pop        dx
dcf7b:  f7 ea                                      imul       word dx
dcf7d:  50                                         push       ax
dcf7e:  9a 0b 5d 2a d7                             call       eeprom_stat_update
dcf83:  59                                         pop        cx
dcf84:  0b c0                                      or         ax, ax
dcf86:  74 1f                                      jz         loc_dcfa7
dcf88:  a0 35 00                                   mov        al, [0035h]
dcf8b:  98                                         cbw
dcf8c:  ba 3c 41                                   mov        dx, 413ch
dcf8f:  8e c2                                      mov        es, dx
dcf91:  50                                         push       ax
dcf92:  26 a0 ad 00                                mov        al, es:[00adh]
dcf96:  98                                         cbw
dcf97:  8b d8                                      mov        bx, ax
dcf99:  58                                         pop        ax
dcf9a:  99                                         cwd
dcf9b:  f7 fb                                      idiv       word bx
dcf9d:  b8 3c 41                                   mov        ax, 413ch
dcfa0:  8e c0                                      mov        es, ax
dcfa2:  26 88 16 d5 00                             mov        es:[00d5h], dl

;  XREF: dce2f, dceb8, dcf3f, dcf58, dcf86
dcfa7:  33 c0                 loc_dcfa7:           xor        ax, ax
dcfa9:  1f                                         pop        ds
dcfaa:  cb                                         retf

;  XREF: dcde6, dce6f, dcef8, dcf7e

; -----------------------------------------------------------------------------
; eeprom_stat_update (0xDCFAB)
; Update EEPROM statistics counter (4 refs)
; -----------------------------------------------------------------------------
dcfab:  55                    eeprom_stat_update:           push       bp
dcfac:  8b ec                                      mov        bp, sp
dcfae:  1e                                         push       ds
dcfaf:  b8 34 41                                   mov        ax, 4134h
dcfb2:  8e d8                                      mov        ds, ax
dcfb4:  a0 36 00                                   mov        al, [0036h]
dcfb7:  02 46 06                                   add        al, [bp+06h]
dcfba:  a2 36 00                                   mov        [0036h], al
dcfbd:  9a 49 05 00 d0                             call       display_set_segment_14refs
dcfc2:  3a 06 36 00                                cmp        al, [0036h]
dcfc6:  7d 12                                      jge        loc_dcfda
dcfc8:  6a 0a                                      push       0ah
dcfca:  9a 70 0b 00 d0                             call       timer_delay
dcfcf:  59                                         pop        cx
dcfd0:  a0 36 00                                   mov        al, [0036h]
dcfd3:  50                                         push       ax
dcfd4:  9a f3 04 00 d0                             call       display_set_mode_10refs
dcfd9:  59                                         pop        cx

;  XREF: dcfc6
dcfda:  9a 49 05 00 d0        loc_dcfda:           call       display_set_segment_14refs
dcfdf:  ba 3c 41                                   mov        dx, 413ch
dcfe2:  8e c2                                      mov        es, dx
dcfe4:  26 3a 06 ac 00                             cmp        al, es:[00ach]
dcfe9:  7c 35                                      jl         loc_dd020
dcfeb:  9a 14 05 00 d0                             call       display_set_position_16refs
dcff0:  50                                         push       ax
dcff1:  9a 49 05 00 d0                             call       display_set_segment_14refs
dcff6:  5a                                         pop        dx
dcff7:  02 d0                                      add        dl, al
dcff9:  52                                         push       dx
dcffa:  9a d2 04 00 d0                             call       display_write_word_12refs
dcfff:  59                                         pop        cx
dd000:  6a 00                                      push       00h
dd002:  9a f3 04 00 d0                             call       display_set_mode_10refs
dd007:  59                                         pop        cx
dd008:  c6 06 36 00 00                             mov        byte [0036h], 00h
dd00d:  9a 14 05 00 d0                             call       display_set_position_16refs
dd012:  ba 3c 41                                   mov        dx, 413ch
dd015:  8e c2                                      mov        es, dx
dd017:  26 a2 d4 00                                mov        es:[00d4h], al
dd01b:  b8 01 00                                   mov        ax, 0001h
dd01e:  eb 1a                                      jmp short  loc_dd03a

;  XREF: dcfe9
dd020:  9a 14 05 00 d0        loc_dd020:           call       display_set_position_16refs
dd025:  50                                         push       ax
dd026:  9a 49 05 00 d0                             call       display_set_segment_14refs
dd02b:  5a                                         pop        dx
dd02c:  02 d0                                      add        dl, al
dd02e:  b8 3c 41                                   mov        ax, 413ch
dd031:  8e c0                                      mov        es, ax
dd033:  26 88 16 d4 00                             mov        es:[00d4h], dl ; credit_available - Non-zero when credits are available for game start
dd038:  33 c0                                      xor        ax, ax

;  XREF: dd01e
dd03a:  1f                    loc_dd03a:           pop        ds
dd03b:  5d                                         pop        bp
dd03c:  cb                                         retf

;  XREF: d8057

; -----------------------------------------------------------------------------
; eeprom_high_score_write (0xDD03D)
; Write high score entry to EEPROM
; -----------------------------------------------------------------------------
dd03d:  1e                    eeprom_high_score_write:           push       ds
dd03e:  b8 34 41                                   mov        ax, 4134h
dd041:  8e d8                                      mov        ds, ax
dd043:  c6 06 36 00 00                             mov        byte [0036h], 00h
dd048:  a0 35 00                                   mov        al, [0035h]
dd04b:  98                                         cbw
dd04c:  ba 3c 41                                   mov        dx, 413ch
dd04f:  8e c2                                      mov        es, dx
dd051:  50                                         push       ax
dd052:  26 a0 af 00                                mov        al, es:[00afh]
dd056:  98                                         cbw
dd057:  8b d8                                      mov        bx, ax
dd059:  58                                         pop        ax
dd05a:  99                                         cwd
dd05b:  f7 fb                                      idiv       word bx
dd05d:  0b c0                                      or         ax, ax
dd05f:  74 70                                      jz         loc_dd0d1
dd061:  a0 35 00                                   mov        al, [0035h]
dd064:  98                                         cbw
dd065:  ba 3c 41                                   mov        dx, 413ch
dd068:  8e c2                                      mov        es, dx
dd06a:  50                                         push       ax
dd06b:  26 a0 af 00                                mov        al, es:[00afh]
dd06f:  98                                         cbw
dd070:  8b d8                                      mov        bx, ax
dd072:  58                                         pop        ax
dd073:  99                                         cwd
dd074:  f7 fb                                      idiv       word bx
dd076:  ba 3c 41                                   mov        dx, 413ch
dd079:  8e c2                                      mov        es, dx
dd07b:  50                                         push       ax
dd07c:  26 a0 ab 00                                mov        al, es:[00abh]
dd080:  98                                         cbw
dd081:  5a                                         pop        dx
dd082:  f7 ea                                      imul       word dx
dd084:  50                                         push       ax
dd085:  9a 21 5f 2a d7                             call       dmd_high_score_display
dd08a:  59                                         pop        cx
dd08b:  0b c0                                      or         ax, ax
dd08d:  74 1f                                      jz         loc_dd0ae
dd08f:  a0 35 00                                   mov        al, [0035h]
dd092:  98                                         cbw
dd093:  ba 3c 41                                   mov        dx, 413ch
dd096:  8e c2                                      mov        es, dx
dd098:  50                                         push       ax
dd099:  26 a0 af 00                                mov        al, es:[00afh]
dd09d:  98                                         cbw
dd09e:  8b d8                                      mov        bx, ax
dd0a0:  58                                         pop        ax
dd0a1:  99                                         cwd
dd0a2:  f7 fb                                      idiv       word bx
dd0a4:  b8 3c 41                                   mov        ax, 413ch
dd0a7:  8e c0                                      mov        es, ax
dd0a9:  26 88 16 d5 00                             mov        es:[00d5h], dl

;  XREF: dd08d
dd0ae:  a0 35 00              loc_dd0ae:           mov        al, [0035h]
dd0b1:  98                                         cbw
dd0b2:  ba 3c 41                                   mov        dx, 413ch
dd0b5:  8e c2                                      mov        es, dx
dd0b7:  50                                         push       ax
dd0b8:  26 a0 af 00                                mov        al, es:[00afh]
dd0bc:  98                                         cbw
dd0bd:  8b d8                                      mov        bx, ax
dd0bf:  58                                         pop        ax
dd0c0:  99                                         cwd
dd0c1:  f7 fb                                      idiv       word bx
dd0c3:  88 16 35 00                                mov        [0035h], dl
dd0c7:  80 3e 35 00 00                             cmp        byte [0035h], 00h
dd0cc:  75 03                                      jnz        loc_dd0d1
dd0ce:  e9 ec 00                                   jmp        loc_dd1bd

;  XREF: dd05f, dd0cc
dd0d1:  a0 35 00              loc_dd0d1:           mov        al, [0035h]
dd0d4:  98                                         cbw
dd0d5:  ba 3c 41                                   mov        dx, 413ch
dd0d8:  8e c2                                      mov        es, dx
dd0da:  50                                         push       ax
dd0db:  26 a0 ae 00                                mov        al, es:[00aeh]
dd0df:  98                                         cbw
dd0e0:  8b d8                                      mov        bx, ax
dd0e2:  58                                         pop        ax
dd0e3:  99                                         cwd
dd0e4:  f7 fb                                      idiv       word bx
dd0e6:  0b c0                                      or         ax, ax
dd0e8:  74 6d                                      jz         loc_dd157
dd0ea:  a0 35 00                                   mov        al, [0035h]
dd0ed:  98                                         cbw
dd0ee:  ba 3c 41                                   mov        dx, 413ch
dd0f1:  8e c2                                      mov        es, dx
dd0f3:  50                                         push       ax
dd0f4:  26 a0 ae 00                                mov        al, es:[00aeh]
dd0f8:  98                                         cbw
dd0f9:  8b d8                                      mov        bx, ax
dd0fb:  58                                         pop        ax
dd0fc:  99                                         cwd
dd0fd:  f7 fb                                      idiv       word bx
dd0ff:  ba 3c 41                                   mov        dx, 413ch
dd102:  8e c2                                      mov        es, dx
dd104:  50                                         push       ax
dd105:  26 a0 aa 00                                mov        al, es:[00aah]
dd109:  98                                         cbw
dd10a:  5a                                         pop        dx
dd10b:  f7 ea                                      imul       word dx
dd10d:  50                                         push       ax
dd10e:  9a 21 5f 2a d7                             call       dmd_high_score_display
dd113:  59                                         pop        cx
dd114:  0b c0                                      or         ax, ax
dd116:  74 1f                                      jz         loc_dd137
dd118:  a0 35 00                                   mov        al, [0035h]
dd11b:  98                                         cbw
dd11c:  ba 3c 41                                   mov        dx, 413ch
dd11f:  8e c2                                      mov        es, dx
dd121:  50                                         push       ax
dd122:  26 a0 ae 00                                mov        al, es:[00aeh]
dd126:  98                                         cbw
dd127:  8b d8                                      mov        bx, ax
dd129:  58                                         pop        ax
dd12a:  99                                         cwd
dd12b:  f7 fb                                      idiv       word bx
dd12d:  b8 3c 41                                   mov        ax, 413ch
dd130:  8e c0                                      mov        es, ax
dd132:  26 88 16 d5 00                             mov        es:[00d5h], dl

;  XREF: dd116
dd137:  a0 35 00              loc_dd137:           mov        al, [0035h]
dd13a:  98                                         cbw
dd13b:  ba 3c 41                                   mov        dx, 413ch
dd13e:  8e c2                                      mov        es, dx
dd140:  50                                         push       ax
dd141:  26 a0 ae 00                                mov        al, es:[00aeh]
dd145:  98                                         cbw
dd146:  8b d8                                      mov        bx, ax
dd148:  58                                         pop        ax
dd149:  99                                         cwd
dd14a:  f7 fb                                      idiv       word bx
dd14c:  88 16 35 00                                mov        [0035h], dl
dd150:  80 3e 35 00 00                             cmp        byte [0035h], 00h
dd155:  74 66                                      jz         loc_dd1bd

;  XREF: dd0e8
dd157:  a0 35 00              loc_dd157:           mov        al, [0035h]
dd15a:  98                                         cbw
dd15b:  ba 3c 41                                   mov        dx, 413ch
dd15e:  8e c2                                      mov        es, dx
dd160:  50                                         push       ax
dd161:  26 a0 ad 00                                mov        al, es:[00adh]
dd165:  98                                         cbw
dd166:  8b d8                                      mov        bx, ax
dd168:  58                                         pop        ax
dd169:  99                                         cwd
dd16a:  f7 fb                                      idiv       word bx
dd16c:  0b c0                                      or         ax, ax
dd16e:  74 4d                                      jz         loc_dd1bd
dd170:  a0 35 00                                   mov        al, [0035h]
dd173:  98                                         cbw
dd174:  ba 3c 41                                   mov        dx, 413ch
dd177:  8e c2                                      mov        es, dx
dd179:  50                                         push       ax
dd17a:  26 a0 ad 00                                mov        al, es:[00adh]
dd17e:  98                                         cbw
dd17f:  8b d8                                      mov        bx, ax
dd181:  58                                         pop        ax
dd182:  99                                         cwd
dd183:  f7 fb                                      idiv       word bx
dd185:  ba 3c 41                                   mov        dx, 413ch
dd188:  8e c2                                      mov        es, dx
dd18a:  50                                         push       ax
dd18b:  26 a0 a9 00                                mov        al, es:[00a9h]
dd18f:  98                                         cbw
dd190:  5a                                         pop        dx
dd191:  f7 ea                                      imul       word dx
dd193:  50                                         push       ax
dd194:  9a 21 5f 2a d7                             call       dmd_high_score_display
dd199:  59                                         pop        cx
dd19a:  0b c0                                      or         ax, ax
dd19c:  74 1f                                      jz         loc_dd1bd
dd19e:  a0 35 00                                   mov        al, [0035h]
dd1a1:  98                                         cbw
dd1a2:  ba 3c 41                                   mov        dx, 413ch
dd1a5:  8e c2                                      mov        es, dx
dd1a7:  50                                         push       ax
dd1a8:  26 a0 ad 00                                mov        al, es:[00adh]
dd1ac:  98                                         cbw
dd1ad:  8b d8                                      mov        bx, ax
dd1af:  58                                         pop        ax
dd1b0:  99                                         cwd
dd1b1:  f7 fb                                      idiv       word bx
dd1b3:  b8 3c 41                                   mov        ax, 413ch
dd1b6:  8e c0                                      mov        es, ax
dd1b8:  26 88 16 d5 00                             mov        es:[00d5h], dl

;  XREF: dd0ce, dd155, dd16e, dd19c
dd1bd:  33 c0                 loc_dd1bd:           xor        ax, ax
dd1bf:  1f                                         pop        ds
dd1c0:  cb                                         retf

;  XREF: dd085, dd10e, dd194

; -----------------------------------------------------------------------------
; dmd_high_score_display (0xDD1C1)
; Display high score table entry (3 refs)
; -----------------------------------------------------------------------------
dd1c1:  55                    dmd_high_score_display:           push       bp
dd1c2:  8b ec                                      mov        bp, sp
dd1c4:  1e                                         push       ds
dd1c5:  b8 34 41                                   mov        ax, 4134h
dd1c8:  8e d8                                      mov        ds, ax
dd1ca:  a0 36 00                                   mov        al, [0036h]
dd1cd:  02 46 06                                   add        al, [bp+06h]
dd1d0:  a2 36 00                                   mov        [0036h], al
dd1d3:  9a 49 05 00 d0                             call       display_set_segment_14refs
dd1d8:  3a 06 36 00                                cmp        al, [0036h]
dd1dc:  7d 12                                      jge        loc_dd1f0
dd1de:  6a 0a                                      push       0ah
dd1e0:  9a 70 0b 00 d0                             call       timer_delay
dd1e5:  59                                         pop        cx
dd1e6:  a0 36 00                                   mov        al, [0036h]
dd1e9:  50                                         push       ax
dd1ea:  9a f3 04 00 d0                             call       display_set_mode_10refs
dd1ef:  59                                         pop        cx

;  XREF: dd1dc
dd1f0:  9a 49 05 00 d0        loc_dd1f0:           call       display_set_segment_14refs
dd1f5:  ba 3c 41                                   mov        dx, 413ch
dd1f8:  8e c2                                      mov        es, dx
dd1fa:  26 3a 06 ab 00                             cmp        al, es:[00abh]
dd1ff:  7c 35                                      jl         loc_dd236
dd201:  9a 14 05 00 d0                             call       display_set_position_16refs
dd206:  50                                         push       ax
dd207:  9a 49 05 00 d0                             call       display_set_segment_14refs
dd20c:  5a                                         pop        dx
dd20d:  02 d0                                      add        dl, al
dd20f:  52                                         push       dx
dd210:  9a d2 04 00 d0                             call       display_write_word_12refs
dd215:  59                                         pop        cx
dd216:  6a 00                                      push       00h
dd218:  9a f3 04 00 d0                             call       display_set_mode_10refs
dd21d:  59                                         pop        cx
dd21e:  c6 06 36 00 00                             mov        byte [0036h], 00h
dd223:  9a 14 05 00 d0                             call       display_set_position_16refs
dd228:  ba 3c 41                                   mov        dx, 413ch
dd22b:  8e c2                                      mov        es, dx
dd22d:  26 a2 d4 00                                mov        es:[00d4h], al
dd231:  b8 01 00                                   mov        ax, 0001h
dd234:  eb 1a                                      jmp short  loc_dd250

;  XREF: dd1ff
dd236:  9a 14 05 00 d0        loc_dd236:           call       display_set_position_16refs
dd23b:  50                                         push       ax
dd23c:  9a 49 05 00 d0                             call       display_set_segment_14refs
dd241:  5a                                         pop        dx
dd242:  02 d0                                      add        dl, al
dd244:  b8 3c 41                                   mov        ax, 413ch
dd247:  8e c0                                      mov        es, ax
dd249:  26 88 16 d4 00                             mov        es:[00d4h], dl ; credit_available - Non-zero when credits are available for game start
dd24e:  33 c0                                      xor        ax, ax

;  XREF: dd234
dd250:  1f                    loc_dd250:           pop        ds
dd251:  5d                                         pop        bp
dd252:  cb                                         retf

;  XREF: d2fb4, d7ae6

; -----------------------------------------------------------------------------
; game_mode_transition (0xDD253)
; Handle game mode transitions
; -----------------------------------------------------------------------------
dd253:  1e                    game_mode_transition:           push       ds
dd254:  b8 37 41                                   mov        ax, 4137h
dd257:  8e d8                                      mov        ds, ax
dd259:  9a ab 01 25 dd                             call       frame_processing_additional
dd25e:  b8 3c 41                                   mov        ax, 413ch
dd261:  8e c0                                      mov        es, ax
dd263:  26 c7 06 5a 01 00 00                       mov        word es:[015ah], 0000h ; current_player_index - Current player index (0-3, used for player struct offset)
dd26a:  c6 06 25 00 00                             mov        byte [0025h], 00h
dd26f:  c6 06 26 00 ff                             mov        byte [0026h], ffh
dd274:  68 f7 00                                   push       00f7h
dd277:  9a 38 01 00 d0                             call       cmd_queue_push
dd27c:  59                                         pop        cx
dd27d:  b8 00 40                                   mov        ax, 4000h
dd280:  8e c0                                      mov        es, ax
dd282:  26 c6 06 f1 10 00                          mov        byte es:[10f1h], 00h
dd288:  b8 00 40                                   mov        ax, 4000h
dd28b:  8e c0                                      mov        es, ax
dd28d:  26 c7 06 3d 11 14 00                       mov        word es:[113dh], 0014h
dd294:  9a 96 00 25 dd                             call       dmd_credits_display
dd299:  9a 09 28 f2 d2                             call       flipper_button_handler
dd29e:  68 f8 00                                   push       00f8h
dd2a1:  9a 38 01 00 d0                             call       cmd_queue_push
dd2a6:  59                                         pop        cx
dd2a7:  68 c4 00                                   push       00c4h
dd2aa:  9a 38 01 00 d0                             call       cmd_queue_push
dd2af:  59                                         pop        cx
dd2b0:  9a 0c 33 f2 d2                             call       default_game_logic
dd2b5:  68 a9 00                                   push       00a9h
dd2b8:  9a 38 01 00 d0                             call       cmd_queue_push
dd2bd:  59                                         pop        cx
dd2be:  68 c4 00                                   push       00c4h
dd2c1:  9a 38 01 00 d0                             call       cmd_queue_push
dd2c6:  59                                         pop        cx
dd2c7:  68 f6 00                                   push       00f6h
dd2ca:  9a 38 01 00 d0                             call       cmd_queue_push
dd2cf:  59                                         pop        cx
dd2d0:  68 c8 00                                   push       00c8h
dd2d3:  9a 38 01 00 d0                             call       cmd_queue_push
dd2d8:  59                                         pop        cx
dd2d9:  68 f4 00                                   push       00f4h
dd2dc:  9a 38 01 00 d0                             call       cmd_queue_push
dd2e1:  59                                         pop        cx
dd2e2:  33 c0                                      xor        ax, ax
dd2e4:  1f                                         pop        ds
dd2e5:  cb                                         retf

;  XREF: dd294

; -----------------------------------------------------------------------------
; dmd_credits_display (0xDD2E6)
; Display credits/free play text on DMD
; -----------------------------------------------------------------------------
dd2e6:  1e                    dmd_credits_display:           push       ds
dd2e7:  b8 37 41                                   mov        ax, 4137h
dd2ea:  8e d8                                      mov        ds, ax

;  XREF: dd304
dd2ec:  b8 3c 41              loc_dd2ec:           mov        ax, 413ch
dd2ef:  8e c0                                      mov        es, ax
dd2f1:  26 a1 5a 01                                mov        ax, es:[015ah] ; current_player_index - Current player index (0-3, used for player struct offset)
dd2f5:  6b c0 2e                                   imul       ax, ax, 2eh
dd2f8:  c4 1e 4b 00                                les        bx, [004bh]
dd2fc:  03 d8                                      add        bx, ax
dd2fe:  26 8b 1f                                   mov        bx, es:[bx]
dd301:  83 fb 0d                                   cmp        word bx, 0dh
dd304:  77 e6                                      ja         loc_dd2ec
dd306:  d1 e3                                      shl        bx, 1
dd308:  2e ff a7 8f 01                             jmp        cs:[bx+018fh]

;  XREF: d2f44, d667c, dd259

; -----------------------------------------------------------------------------
; frame_processing_additional (0xDD3FB)
; Additional per-frame processing (called from main loop)
; -----------------------------------------------------------------------------
dd3fb:  1e                    frame_processing_additional:           push       ds
dd3fc:  b8 37 41                                   mov        ax, 4137h
dd3ff:  8e d8                                      mov        ds, ax
dd401:  b8 00 40                                   mov        ax, 4000h
dd404:  8e c0                                      mov        es, ax
dd406:  26 80 3e 01 10 05                          cmp        byte es:[1001h], 05h ; game_status_byte - Overall game status communicated to Z80
dd40c:  75 39                                      jnz        loc_dd447
dd40e:  c7 06 4d 00 00 00                          mov        word [004dh], 0000h
dd414:  c7 06 4b 00 08 0d                          mov        word [004bh], 0d08h
dd41a:  c7 06 45 00 00 00                          mov        word [0045h], 0000h
dd420:  c7 06 43 00 96 15                          mov        word [0043h], 1596h
dd426:  c7 06 49 00 00 00                          mov        word [0049h], 0000h
dd42c:  c7 06 47 00 38 14                          mov        word [0047h], 1438h
dd432:  b8 3c 41                                   mov        ax, 413ch
dd435:  8e c0                                      mov        es, ax
dd437:  26 c7 06 b4 00 00 00                       mov        word es:[00b4h], 0000h
dd43e:  26 c7 06 b2 00 7c 16                       mov        word es:[00b2h], 167ch
dd445:  eb 37                                      jmp short  loc_dd47e

;  XREF: dd40c
dd447:  c7 06 4d 00 00 00     loc_dd447:           mov        word [004dh], 0000h
dd44d:  c7 06 4b 00 00 01                          mov        word [004bh], 0100h
dd453:  c7 06 45 00 00 00                          mov        word [0045h], 0000h
dd459:  c7 06 43 00 f6 0a                          mov        word [0043h], 0af6h
dd45f:  c7 06 49 00 00 00                          mov        word [0049h], 0000h
dd465:  c7 06 47 00 30 08                          mov        word [0047h], 0830h
dd46b:  b8 3c 41                                   mov        ax, 413ch
dd46e:  8e c0                                      mov        es, ax
dd470:  26 c7 06 b4 00 00 00                       mov        word es:[00b4h], 0000h
dd477:  26 c7 06 b2 00 dc 0b                       mov        word es:[00b2h], 0bdch

;  XREF: dd445
dd47e:  1f                    loc_dd47e:           pop        ds
dd47f:  cb                                         retf

;  XREF: e0a5b, e0b04, e0b14, e0c1e, e0c40 (+1 more)

; -----------------------------------------------------------------------------
; player_dmd_buffer_swap_clear (0xDE3CD)
; Swap and clear DMD buffer for player display (6+ refs, accesses seg 4137h)
; -----------------------------------------------------------------------------
de3cd:  1e                    player_dmd_buffer_swap_clear:           push       ds
de3ce:  b8 37 41                                   mov        ax, 4137h
de3d1:  8e d8                                      mov        ds, ax
de3d3:  9a c4 00 00 f0                             call       dmd_buffer_swap
de3d8:  9a f1 00 00 f0                             call       dmd_buffer_clear
de3dd:  1f                                         pop        ds
de3de:  cb                                         retf

;  XREF: e0b95, e0c99, e0d98

; -----------------------------------------------------------------------------
; player_score_digit_render (0xDF61B)
; Render individual score digits for player display (3 refs)
; -----------------------------------------------------------------------------
df61b:  c8 06 00 00           player_score_digit_render:           enter      0006h, 00h
df61f:  1e                                         push       ds
df620:  b8 37 41                                   mov        ax, 4137h
df623:  8e d8                                      mov        ds, ax
df625:  c6 46 ff 00                                mov        byte [bp-01h], 00h
df629:  c6 06 18 00 00                             mov        byte [0018h], 00h
df62e:  eb 15                                      jmp short  loc_df645

;  XREF: df64a
df630:  a0 18 00              loc_df630:           mov        al, [0018h]
df633:  98                                         cbw
df634:  ba 3c 41                                   mov        dx, 413ch
df637:  8b d8                                      mov        bx, ax
df639:  8e c2                                      mov        es, dx
df63b:  26 c6 87 5c 01 00                          mov        byte es:[bx+015ch], 00h
df641:  fe 06 18 00                                inc        byte [0018h]

;  XREF: df62e
df645:  80 3e 18 00 08        loc_df645:           cmp        byte [0018h], 08h
df64a:  7e e4                                      jle        loc_df630
df64c:  c6 06 18 00 00                             mov        byte [0018h], 00h
df651:  eb 0f                                      jmp short  loc_df662

;  XREF: df667
df653:  a0 18 00              loc_df653:           mov        al, [0018h]
df656:  98                                         cbw
df657:  8b d8                                      mov        bx, ax
df659:  c6 87 1c 00 00                             mov        byte [bx+001ch], 00h
df65e:  fe 06 18 00                                inc        byte [0018h]

;  XREF: df651
df662:  80 3e 18 00 08        loc_df662:           cmp        byte [0018h], 08h
df667:  7e ea                                      jle        loc_df653
df669:  b8 3c 41                                   mov        ax, 413ch
df66c:  8e c0                                      mov        es, ax
df66e:  26 a1 54 01                                mov        ax, es:[0154h]
df672:  26 8b 16 52 01                             mov        dx, es:[0152h]
df677:  89 46 fc                                   mov        [bp-04h], ax
df67a:  89 56 fa                                   mov        [bp-06h], dx

;  XREF: df6b3
df67d:  6a 00                 loc_df67d:           push       00h
df67f:  6a 0a                                      push       0ah
df681:  ff 76 fc                                   push       word [bp-04h]
df684:  ff 76 fa                                   push       word [bp-06h]
df687:  9a 18 00 26 e3                             call       player_struct_read_word
df68c:  50                                         push       ax
df68d:  8a 46 ff                                   mov        al, [bp-01h]
df690:  98                                         cbw
df691:  8b d8                                      mov        bx, ax
df693:  58                                         pop        ax
df694:  88 87 1c 00                                mov        [bx+001ch], al
df698:  6a 00                                      push       00h
df69a:  6a 0a                                      push       0ah
df69c:  ff 76 fc                                   push       word [bp-04h]
df69f:  ff 76 fa                                   push       word [bp-06h]
df6a2:  9a 09 00 26 e3                             call       player_struct_read_byte
df6a7:  89 56 fc                                   mov        [bp-04h], dx
df6aa:  89 46 fa                                   mov        [bp-06h], ax
df6ad:  fe 46 ff                                   inc        byte [bp-01h]
df6b0:  0b 46 fc                                   or         ax, [bp-04h]
df6b3:  75 c8                                      jnz        loc_df67d
df6b5:  c6 06 18 00 08                             mov        byte [0018h], 08h
df6ba:  eb 23                                      jmp short  loc_df6df

;  XREF: df6e4
df6bc:  a0 18 00              loc_df6bc:           mov        al, [0018h]
df6bf:  98                                         cbw
df6c0:  8b d8                                      mov        bx, ax
df6c2:  8a 87 1c 00                                mov        al, [bx+001ch]
df6c6:  50                                         push       ax
df6c7:  a0 18 00                                   mov        al, [0018h]
df6ca:  98                                         cbw
df6cb:  bb 09 00                                   mov        bx, 0009h
df6ce:  2b d8                                      sub        bx, ax
df6d0:  b8 3c 41                                   mov        ax, 413ch
df6d3:  8e c0                                      mov        es, ax
df6d5:  58                                         pop        ax
df6d6:  26 88 87 5c 01                             mov        es:[bx+015ch], al
df6db:  fe 0e 18 00                                dec        byte [0018h]

;  XREF: df6ba
df6df:  80 3e 18 00 00        loc_df6df:           cmp        byte [0018h], 00h
df6e4:  7d d6                                      jge        loc_df6bc
df6e6:  b8 3c 41                                   mov        ax, 413ch
df6e9:  8a 56 ff                                   mov        dl, [bp-01h]
df6ec:  8e c0                                      mov        es, ax
df6ee:  26 88 16 5c 01                             mov        es:[015ch], dl
df6f3:  80 7e ff 09                                cmp        byte [bp-01h], 09h
df6f7:  74 65                                      jz         loc_df75e
df6f9:  c6 06 18 00 00                             mov        byte [0018h], 00h
df6fe:  eb 29                                      jmp short  loc_df729

;  XREF: df72f
df700:  8a 46 ff              loc_df700:           mov        al, [bp-01h]
df703:  98                                         cbw
df704:  bb 09 00                                   mov        bx, 0009h
df707:  2b d8                                      sub        bx, ax
df709:  a0 18 00                                   mov        al, [0018h]
df70c:  98                                         cbw
df70d:  03 d8                                      add        bx, ax
df70f:  b8 3c 41                                   mov        ax, 413ch
df712:  8e c0                                      mov        es, ax
df714:  26 8a 87 5d 01                             mov        al, es:[bx+015dh]
df719:  50                                         push       ax
df71a:  a0 18 00                                   mov        al, [0018h]
df71d:  98                                         cbw
df71e:  8b d8                                      mov        bx, ax
df720:  58                                         pop        ax
df721:  88 87 1c 00                                mov        [bx+001ch], al
df725:  fe 06 18 00                                inc        byte [0018h]

;  XREF: df6fe
df729:  a0 18 00              loc_df729:           mov        al, [0018h]
df72c:  3a 46 ff                                   cmp        al, [bp-01h]
df72f:  7c cf                                      jl         loc_df700
df731:  c6 06 18 00 00                             mov        byte [0018h], 00h
df736:  eb 1e                                      jmp short  loc_df756

;  XREF: df75c
df738:  a0 18 00              loc_df738:           mov        al, [0018h]
df73b:  98                                         cbw
df73c:  ba 3c 41                                   mov        dx, 413ch
df73f:  50                                         push       ax
df740:  a0 18 00                                   mov        al, [0018h]
df743:  98                                         cbw
df744:  8b d8                                      mov        bx, ax
df746:  8a 87 1c 00                                mov        al, [bx+001ch]
df74a:  8e c2                                      mov        es, dx
df74c:  5b                                         pop        bx
df74d:  26 88 87 5d 01                             mov        es:[bx+015dh], al
df752:  fe 06 18 00                                inc        byte [0018h]

;  XREF: df736
df756:  a0 18 00              loc_df756:           mov        al, [0018h]
df759:  3a 46 ff                                   cmp        al, [bp-01h]
df75c:  7c da                                      jl         loc_df738

;  XREF: df6f7
df75e:  b8 01 00              loc_df75e:           mov        ax, 0001h
df761:  1f                                         pop        ds
df762:  c9                                         leave
df763:  cb                                         retf

;  XREF: e0aff, e0c19

; =============================================================================
; SEGMENT E000 - PLAYER DISPLAY CODE (0xE0000-0xE2FFF, 12KB active)
; =============================================================================
; Contains player-specific display routines:
;   - Score display for 4-player support
;   - Player data structure access (stride = 0x2E = 46 bytes per player)
;   - Player struct fields: +0x0C/+0x14/+0x1C = score values
;   - Player index from 413C:015A
;   - Far pointer to player data at DS:[0x4B]
;   - Z80 synchronization (writes to 4000:113B, polls until cleared)
;
; This segment references segment 413C (player data) 920 times - 
; the most heavily accessed memory region in the entire ROM.
;
; Jump table at E000:3045 provides 4 entries (one per player).
; =============================================================================

; -----------------------------------------------------------------------------
; player_wait_for_z80 (0xE0A2B)
; Wait for Z80 to process command (writes to 4000:113B, polls until zero)
; -----------------------------------------------------------------------------
e0a2b:  55                    player_wait_for_z80:           push       bp
e0a2c:  8b ec                                      mov        bp, sp
e0a2e:  1e                                         push       ds
e0a2f:  b8 37 41                                   mov        ax, 4137h
e0a32:  8e d8                                      mov        ds, ax
e0a34:  b8 00 40                                   mov        ax, 4000h
e0a37:  8b 56 06                                   mov        dx, [bp+06h]
e0a3a:  8e c0                                      mov        es, ax
e0a3c:  26 89 16 3b 11                             mov        es:[113bh], dx ; z80_cmd_pending - Z80 command pending flag (80188 writes, Z80 clears when done)

;  XREF: e0a4c
e0a41:  b8 00 40              loc_e0a41:           mov        ax, 4000h
e0a44:  8e c0                                      mov        es, ax
e0a46:  26 83 3e 3b 11 00                          cmp        word es:[113bh], 00h ; z80_cmd_pending - Z80 command pending flag (80188 writes, Z80 clears when done)
e0a4c:  75 f3                                      jnz        loc_e0a41
e0a4e:  1f                                         pop        ds
e0a4f:  5d                                         pop        bp
e0a50:  cb                                         retf

;  XREF: da72d, da797

; -----------------------------------------------------------------------------
; player_display_scores (0xE0A51)
; Display player scores on DMD (accesses 413C player structures)
; -----------------------------------------------------------------------------
e0a51:  55                    player_display_scores:           push       bp
e0a52:  8b ec                                      mov        bp, sp
e0a54:  1e                                         push       ds
e0a55:  b8 37 41                                   mov        ax, 4137h
e0a58:  8e d8                                      mov        ds, ax
e0a5a:  0e                                         push       cs
e0a5b:  e8 6f d9                                   call       player_dmd_buffer_swap_clear
e0a5e:  8a 46 06                                   mov        al, [bp+06h]
e0a61:  b4 00                                      mov        ah, 00h
e0a63:  3d 77 00                                   cmp        ax, 0077h
e0a66:  74 07                                      jz         loc_e0a6f
e0a68:  3d 78 00                                   cmp        ax, 0078h
e0a6b:  74 21                                      jz         loc_e0a8e
e0a6d:  eb 3e                                      jmp short  loc_e0aad

;  XREF: e0a66
e0a6f:  b8 3c 41              loc_e0a6f:           mov        ax, 413ch
e0a72:  8e c0                                      mov        es, ax
e0a74:  26 c4 1e b2 00                             les        bx, es:[00b2h]
e0a79:  26 ff 77 70                                push       word es:[bx+70h]
e0a7d:  26 ff 77 6e                                push       word es:[bx+6eh]
e0a81:  8e c0                                      mov        es, ax
e0a83:  26 8e 06 b4 00                             mov        es, es:[00b4h]
e0a88:  26 ff 77 6c                                push       word es:[bx+6ch]
e0a8c:  eb 3c                                      jmp short  loc_e0aca

;  XREF: e0a6b
e0a8e:  b8 3c 41              loc_e0a8e:           mov        ax, 413ch
e0a91:  8e c0                                      mov        es, ax
e0a93:  26 c4 1e b2 00                             les        bx, es:[00b2h]
e0a98:  26 ff 77 76                                push       word es:[bx+76h]
e0a9c:  26 ff 77 74                                push       word es:[bx+74h]
e0aa0:  8e c0                                      mov        es, ax
e0aa2:  26 8e 06 b4 00                             mov        es, es:[00b4h]
e0aa7:  26 ff 77 72                                push       word es:[bx+72h]
e0aab:  eb 1d                                      jmp short  loc_e0aca

;  XREF: e0a6d
e0aad:  b8 3c 41              loc_e0aad:           mov        ax, 413ch
e0ab0:  8e c0                                      mov        es, ax
e0ab2:  26 c4 1e b2 00                             les        bx, es:[00b2h]
e0ab7:  26 ff 77 7c                                push       word es:[bx+7ch]
e0abb:  26 ff 77 7a                                push       word es:[bx+7ah]
e0abf:  8e c0                                      mov        es, ax
e0ac1:  26 8e 06 b4 00                             mov        es, es:[00b4h]
e0ac6:  26 ff 77 78                                push       word es:[bx+78h]

;  XREF: e0a8c, e0aab
e0aca:  6a 21                 loc_e0aca:           push       21h
e0acc:  9a 01 07 00 f0                             call       dmd_text_render
e0ad1:  83 c4 08                                   add        word sp, 08h
e0ad4:  b8 3c 41                                   mov        ax, 413ch
e0ad7:  8e c0                                      mov        es, ax
e0ad9:  26 c4 1e b2 00                             les        bx, es:[00b2h]
e0ade:  26 ff 77 28                                push       word es:[bx+28h]
e0ae2:  26 ff 77 26                                push       word es:[bx+26h]
e0ae6:  8e c0                                      mov        es, ax
e0ae8:  26 8e 06 b4 00                             mov        es, es:[00b4h]
e0aed:  26 ff 77 24                                push       word es:[bx+24h]
e0af1:  6a 21                                      push       21h
e0af3:  9a 01 07 00 f0                             call       dmd_text_render
e0af8:  83 c4 08                                   add        word sp, 08h
e0afb:  68 2c 01                                   push       012ch
e0afe:  0e                                         push       cs
e0aff:  e8 29 ff                                   call       player_wait_for_z80
e0b02:  59                                         pop        cx
e0b03:  0e                                         push       cs
e0b04:  e8 c6 d8                                   call       player_dmd_buffer_swap_clear
e0b07:  1f                                         pop        ds
e0b08:  5d                                         pop        bp
e0b09:  cb                                         retf

;  XREF: da601, da690

; -----------------------------------------------------------------------------
; player_display_info (0xE0B0A)
; Display player info/status on DMD
; -----------------------------------------------------------------------------
e0b0a:  55                    player_display_info:           push       bp
e0b0b:  8b ec                                      mov        bp, sp
e0b0d:  1e                                         push       ds
e0b0e:  b8 37 41                                   mov        ax, 4137h
e0b11:  8e d8                                      mov        ds, ax
e0b13:  0e                                         push       cs
e0b14:  e8 b6 d8                                   call       player_dmd_buffer_swap_clear
e0b17:  b8 3c 41                                   mov        ax, 413ch
e0b1a:  8e c0                                      mov        es, ax
e0b1c:  26 c4 1e b2 00                             les        bx, es:[00b2h]
e0b21:  26 ff 77 46                                push       word es:[bx+46h]
e0b25:  26 ff 77 44                                push       word es:[bx+44h]
e0b29:  8e c0                                      mov        es, ax
e0b2b:  26 8e 06 b4 00                             mov        es, es:[00b4h]
e0b30:  26 ff 77 42                                push       word es:[bx+42h]
e0b34:  6a 21                                      push       21h
e0b36:  9a 01 07 00 f0                             call       dmd_text_render
e0b3b:  83 c4 08                                   add        word sp, 08h
e0b3e:  8a 46 06                                   mov        al, [bp+06h]
e0b41:  04 9c                                      add        al, 9ch
e0b43:  a2 16 00                                   mov        [0016h], al
e0b46:  98                                         cbw
e0b47:  3d 01 00                                   cmp        ax, 0001h
e0b4a:  74 22                                      jz         loc_e0b6e
e0b4c:  3d 02 00                                   cmp        ax, 0002h
e0b4f:  74 07                                      jz         loc_e0b58
e0b51:  3d 03 00                                   cmp        ax, 0003h
e0b54:  74 09                                      jz         loc_e0b5f
e0b56:  eb 0e                                      jmp short  loc_e0b66

;  XREF: e0b4f
e0b58:  a0 16 00              loc_e0b58:           mov        al, [0016h]
e0b5b:  fe c0                                      inc        byte al
e0b5d:  eb 0c                                      jmp short  loc_e0b6b

;  XREF: e0b54
e0b5f:  a0 16 00              loc_e0b5f:           mov        al, [0016h]
e0b62:  04 02                                      add        al, 02h
e0b64:  eb 05                                      jmp short  loc_e0b6b

;  XREF: e0b56
e0b66:  a0 16 00              loc_e0b66:           mov        al, [0016h]
e0b69:  04 03                                      add        al, 03h

;  XREF: e0b5d, e0b64
e0b6b:  a2 16 00              loc_e0b6b:           mov        [0016h], al

;  XREF: e0b4a
e0b6e:  b8 3c 41              loc_e0b6e:           mov        ax, 413ch
e0b71:  8e c0                                      mov        es, ax
e0b73:  26 c7 06 54 01 00 00                       mov        word es:[0154h], 0000h
e0b7a:  26 c7 06 52 01 00 00                       mov        word es:[0152h], 0000h
e0b81:  a0 16 00                                   mov        al, [0016h]
e0b84:  98                                         cbw
e0b85:  99                                         cwd
e0b86:  bb 3c 41                                   mov        bx, 413ch
e0b89:  8e c3                                      mov        es, bx
e0b8b:  26 89 16 54 01                             mov        es:[0154h], dx
e0b90:  26 a3 52 01                                mov        es:[0152h], ax
e0b94:  0e                                         push       cs
e0b95:  e8 83 ea                                   call       player_score_digit_render
e0b98:  68 3c 41                                   push       413ch
e0b9b:  68 5c 01                                   push       015ch
e0b9e:  6a 0e                                      push       0eh
e0ba0:  6a 21                                      push       21h
e0ba2:  9a 01 07 00 f0                             call       dmd_text_render
e0ba7:  83 c4 08                                   add        word sp, 08h
e0baa:  a0 16 00                                   mov        al, [0016h]
e0bad:  98                                         cbw
e0bae:  6b c0 0a                                   imul       ax, ax, 0ah
e0bb1:  c4 1e 43 00                                les        bx, [0043h]
e0bb5:  03 d8                                      add        bx, ax
e0bb7:  26 ff 77 04                                push       word es:[bx+04h]
e0bbb:  26 ff 77 02                                push       word es:[bx+02h]
e0bbf:  68 80 00                                   push       0080h
e0bc2:  6a 21                                      push       21h
e0bc4:  9a 01 07 00 f0                             call       dmd_text_render
e0bc9:  83 c4 08                                   add        word sp, 08h
e0bcc:  b8 3c 41                                   mov        ax, 413ch
e0bcf:  8e c0                                      mov        es, ax
e0bd1:  26 c4 1e b2 00                             les        bx, es:[00b2h]
e0bd6:  26 ff 77 5e                                push       word es:[bx+5eh]
e0bda:  26 ff 77 5c                                push       word es:[bx+5ch]
e0bde:  8e c0                                      mov        es, ax
e0be0:  26 8e 06 b4 00                             mov        es, es:[00b4h]
e0be5:  26 ff 77 5a                                push       word es:[bx+5ah]
e0be9:  6a 21                                      push       21h
e0beb:  9a 01 07 00 f0                             call       dmd_text_render
e0bf0:  83 c4 08                                   add        word sp, 08h
e0bf3:  a0 16 00                                   mov        al, [0016h]
e0bf6:  98                                         cbw
e0bf7:  6b c0 0a                                   imul       ax, ax, 0ah
e0bfa:  c4 1e 43 00                                les        bx, [0043h]
e0bfe:  03 d8                                      add        bx, ax
e0c00:  26 ff 77 08                                push       word es:[bx+08h]
e0c04:  26 ff 77 06                                push       word es:[bx+06h]
e0c08:  68 80 01                                   push       0180h
e0c0b:  6a 21                                      push       21h
e0c0d:  9a 01 07 00 f0                             call       dmd_text_render
e0c12:  83 c4 08                                   add        word sp, 08h
e0c15:  68 2c 01                                   push       012ch
e0c18:  0e                                         push       cs
e0c19:  e8 0f fe                                   call       player_wait_for_z80
e0c1c:  59                                         pop        cx
e0c1d:  0e                                         push       cs
e0c1e:  e8 ac d7                                   call       player_dmd_buffer_swap_clear
e0c21:  1f                                         pop        ds
e0c22:  5d                                         pop        bp
e0c23:  cb                                         retf

;  XREF: da86f

; -----------------------------------------------------------------------------
; player_display_ball_num (0xE0C24)
; Display current ball number
; -----------------------------------------------------------------------------
e0c24:  55                    player_display_ball_num:           push       bp
e0c25:  8b ec                                      mov        bp, sp
e0c27:  1e                                         push       ds
e0c28:  b8 37 41                                   mov        ax, 4137h
e0c2b:  8e d8                                      mov        ds, ax
e0c2d:  8a 46 06                                   mov        al, [bp+06h]
e0c30:  50                                         push       ax
e0c31:  68 40 50                                   push       5040h
e0c34:  68 1d 03                                   push       031dh
e0c37:  9a a9 04 00 d0                             call       display_load_resource_51refs
e0c3c:  83 c4 06                                   add        word sp, 06h
e0c3f:  0e                                         push       cs
e0c40:  e8 8a d7                                   call       player_dmd_buffer_swap_clear
e0c43:  b8 3c 41                                   mov        ax, 413ch
e0c46:  8e c0                                      mov        es, ax
e0c48:  26 c4 1e b2 00                             les        bx, es:[00b2h]
e0c4d:  26 ff 77 46                                push       word es:[bx+46h]
e0c51:  26 ff 77 44                                push       word es:[bx+44h]
e0c55:  8e c0                                      mov        es, ax
e0c57:  26 8e 06 b4 00                             mov        es, es:[00b4h]
e0c5c:  26 ff 77 42                                push       word es:[bx+42h]
e0c60:  6a 21                                      push       21h
e0c62:  9a 01 07 00 f0                             call       dmd_text_render
e0c67:  83 c4 08                                   add        word sp, 08h
e0c6a:  8a 46 06                                   mov        al, [bp+06h]
e0c6d:  04 b1                                      add        al, b1h
e0c6f:  a2 16 00                                   mov        [0016h], al
e0c72:  b8 3c 41                                   mov        ax, 413ch
e0c75:  8e c0                                      mov        es, ax
e0c77:  26 c7 06 54 01 00 00                       mov        word es:[0154h], 0000h
e0c7e:  26 c7 06 52 01 00 00                       mov        word es:[0152h], 0000h
e0c85:  a0 16 00                                   mov        al, [0016h]
e0c88:  98                                         cbw
e0c89:  99                                         cwd
e0c8a:  bb 3c 41                                   mov        bx, 413ch
e0c8d:  8e c3                                      mov        es, bx
e0c8f:  26 89 16 54 01                             mov        es:[0154h], dx
e0c94:  26 a3 52 01                                mov        es:[0152h], ax
e0c98:  0e                                         push       cs
e0c99:  e8 7f e9                                   call       player_score_digit_render
e0c9c:  68 3c 41                                   push       413ch
e0c9f:  68 5c 01                                   push       015ch
e0ca2:  6a 0e                                      push       0eh
e0ca4:  6a 21                                      push       21h
e0ca6:  9a 01 07 00 f0                             call       dmd_text_render
e0cab:  83 c4 08                                   add        word sp, 08h
e0cae:  a0 16 00                                   mov        al, [0016h]
e0cb1:  98                                         cbw
e0cb2:  6b c0 0a                                   imul       ax, ax, 0ah
e0cb5:  c4 1e 43 00                                les        bx, [0043h]
e0cb9:  03 d8                                      add        bx, ax
e0cbb:  26 ff 77 04                                push       word es:[bx+04h]
e0cbf:  26 ff 77 02                                push       word es:[bx+02h]
e0cc3:  68 80 00                                   push       0080h
e0cc6:  6a 21                                      push       21h
e0cc8:  9a 01 07 00 f0                             call       dmd_text_render
e0ccd:  83 c4 08                                   add        word sp, 08h
e0cd0:  b8 3c 41                                   mov        ax, 413ch
e0cd3:  8e c0                                      mov        es, ax
e0cd5:  26 c4 1e b2 00                             les        bx, es:[00b2h]
e0cda:  26 ff 77 4c                                push       word es:[bx+4ch]
e0cde:  26 ff 77 4a                                push       word es:[bx+4ah]
e0ce2:  8e c0                                      mov        es, ax
e0ce4:  26 8e 06 b4 00                             mov        es, es:[00b4h]
e0ce9:  26 ff 77 48                                push       word es:[bx+48h]
e0ced:  6a 21                                      push       21h
e0cef:  9a 01 07 00 f0                             call       dmd_text_render
e0cf4:  83 c4 08                                   add        word sp, 08h
e0cf7:  b8 3c 41                                   mov        ax, 413ch
e0cfa:  8e c0                                      mov        es, ax
e0cfc:  26 c4 1e b2 00                             les        bx, es:[00b2h]
e0d01:  26 ff 77 52                                push       word es:[bx+52h]
e0d05:  26 ff 77 50                                push       word es:[bx+50h]
e0d09:  8e c0                                      mov        es, ax
e0d0b:  26 8e 06 b4 00                             mov        es, es:[00b4h]
e0d10:  26 ff 77 4e                                push       word es:[bx+4eh]
e0d14:  6a 21                                      push       21h
e0d16:  9a 01 07 00 f0                             call       dmd_text_render
e0d1b:  83 c4 08                                   add        word sp, 08h

;  XREF: e0d1e
e0d1e:  eb fe                 loc_e0d1e:           jmp short  loc_e0d1e

;  XREF: d5ef7

; -----------------------------------------------------------------------------
; player_display_credits (0xE0D23)
; Display credits/free play indicator
; -----------------------------------------------------------------------------
e0d23:  55                    player_display_credits:           push       bp
e0d24:  8b ec                                      mov        bp, sp
e0d26:  1e                                         push       ds
e0d27:  b8 37 41                                   mov        ax, 4137h
e0d2a:  8e d8                                      mov        ds, ax
e0d2c:  8a 46 06                                   mov        al, [bp+06h]
e0d2f:  50                                         push       ax
e0d30:  68 40 50                                   push       5040h
e0d33:  68 1d 03                                   push       031dh
e0d36:  9a a9 04 00 d0                             call       display_load_resource_51refs
e0d3b:  83 c4 06                                   add        word sp, 06h
e0d3e:  0e                                         push       cs
e0d3f:  e8 8b d6                                   call       player_dmd_buffer_swap_clear
e0d42:  b8 3c 41                                   mov        ax, 413ch
e0d45:  8e c0                                      mov        es, ax
e0d47:  26 c4 1e b2 00                             les        bx, es:[00b2h]
e0d4c:  26 ff 77 46                                push       word es:[bx+46h]
e0d50:  26 ff 77 44                                push       word es:[bx+44h]
e0d54:  8e c0                                      mov        es, ax
e0d56:  26 8e 06 b4 00                             mov        es, es:[00b4h]
e0d5b:  26 ff 77 42                                push       word es:[bx+42h]
e0d5f:  6a 21                                      push       21h
e0d61:  9a 01 07 00 f0                             call       dmd_text_render
e0d66:  83 c4 08                                   add        word sp, 08h
e0d69:  8a 46 06                                   mov        al, [bp+06h]
e0d6c:  04 b1                                      add        al, b1h
e0d6e:  a2 16 00                                   mov        [0016h], al
e0d71:  b8 3c 41                                   mov        ax, 413ch
e0d74:  8e c0                                      mov        es, ax
e0d76:  26 c7 06 54 01 00 00                       mov        word es:[0154h], 0000h
e0d7d:  26 c7 06 52 01 00 00                       mov        word es:[0152h], 0000h
e0d84:  a0 16 00                                   mov        al, [0016h]
e0d87:  98                                         cbw
e0d88:  99                                         cwd
e0d89:  bb 3c 41                                   mov        bx, 413ch
e0d8c:  8e c3                                      mov        es, bx
e0d8e:  26 89 16 54 01                             mov        es:[0154h], dx
e0d93:  26 a3 52 01                                mov        es:[0152h], ax
e0d97:  0e                                         push       cs
e0d98:  e8 80 e8                                   call       player_score_digit_render
e0d9b:  68 3c 41                                   push       413ch
e0d9e:  68 5c 01                                   push       015ch
e0da1:  6a 0e                                      push       0eh
e0da3:  6a 21                                      push       21h
e0da5:  9a 01 07 00 f0                             call       dmd_text_render
e0daa:  83 c4 08                                   add        word sp, 08h
e0dad:  a0 16 00                                   mov        al, [0016h]
e0db0:  98                                         cbw
e0db1:  6b c0 0a                                   imul       ax, ax, 0ah
e0db4:  c4 1e 43 00                                les        bx, [0043h]
e0db8:  03 d8                                      add        bx, ax
e0dba:  26 ff 77 04                                push       word es:[bx+04h]
e0dbe:  26 ff 77 02                                push       word es:[bx+02h]
e0dc2:  68 80 00                                   push       0080h
e0dc5:  6a 21                                      push       21h
e0dc7:  9a 01 07 00 f0                             call       dmd_text_render
e0dcc:  83 c4 08                                   add        word sp, 08h
e0dcf:  b8 3c 41                                   mov        ax, 413ch
e0dd2:  8e c0                                      mov        es, ax
e0dd4:  26 c4 1e b2 00                             les        bx, es:[00b2h]
e0dd9:  26 ff 77 4c                                push       word es:[bx+4ch]
e0ddd:  26 ff 77 4a                                push       word es:[bx+4ah]
e0de1:  8e c0                                      mov        es, ax
e0de3:  26 8e 06 b4 00                             mov        es, es:[00b4h]
e0de8:  26 ff 77 48                                push       word es:[bx+48h]
e0dec:  6a 21                                      push       21h
e0dee:  9a 01 07 00 f0                             call       dmd_text_render
e0df3:  83 c4 08                                   add        word sp, 08h
e0df6:  b8 3c 41                                   mov        ax, 413ch
e0df9:  8e c0                                      mov        es, ax
e0dfb:  26 c4 1e b2 00                             les        bx, es:[00b2h]
e0e00:  26 ff 77 52                                push       word es:[bx+52h]
e0e04:  26 ff 77 50                                push       word es:[bx+50h]
e0e08:  8e c0                                      mov        es, ax
e0e0a:  26 8e 06 b4 00                             mov        es, es:[00b4h]
e0e0f:  26 ff 77 4e                                push       word es:[bx+4eh]
e0e13:  6a 21                                      push       21h
e0e15:  9a 01 07 00 f0                             call       dmd_text_render
e0e1a:  83 c4 08                                   add        word sp, 08h
e0e1d:  68 c8 00                                   push       00c8h
e0e20:  9a e8 26 f2 d2                             call       switch_read_shared_ram
e0e25:  59                                         pop        cx
e0e26:  1f                                         pop        ds
e0e27:  5d                                         pop        bp
e0e28:  cb                                         retf

;  XREF: dca51, df6a2

; -----------------------------------------------------------------------------
; player_struct_read_byte (0xE3269)
; Read byte from player data structure
; -----------------------------------------------------------------------------
e3269:  33 c9                 player_struct_read_byte:           xor        cx, cx
e326b:  eb 16                                      jmp short  loc_e3283

;  XREF: dca3b, df687

; -----------------------------------------------------------------------------
; player_struct_read_word (0xE3278)
; Read word from player data structure
; -----------------------------------------------------------------------------
e3278:  b9 02 00              player_struct_read_word:           mov        cx, 0002h
e327b:  eb 06                                      jmp short  loc_e3283

;  XREF: e326b, e327b
e3283:  55                    loc_e3283:           push       bp
e3284:  56                                         push       si
e3285:  57                                         push       di
e3286:  8b ec                                      mov        bp, sp
e3288:  8b f9                                      mov        di, cx
e328a:  8b 46 0a                                   mov        ax, [bp+0ah]
e328d:  8b 56 0c                                   mov        dx, [bp+0ch]
e3290:  8b 5e 0e                                   mov        bx, [bp+0eh]
e3293:  8b 4e 10                                   mov        cx, [bp+10h]
e3296:  0b c9                                      or         cx, cx
e3298:  75 08                                      jnz        loc_e32a2
e329a:  0b d2                                      or         dx, dx
e329c:  74 69                                      jz         loc_e3307
e329e:  0b db                                      or         bx, bx
e32a0:  74 65                                      jz         loc_e3307

;  XREF: e3298
e32a2:  f7 c7 01 00           loc_e32a2:           test       word di, 0001h
e32a6:  75 1c                                      jnz        loc_e32c4
e32a8:  0b d2                                      or         dx, dx
e32aa:  79 0a                                      jns        loc_e32b6
e32ac:  f7 da                                      neg        word dx
e32ae:  f7 d8                                      neg        word ax
e32b0:  83 da 00                                   sbb        word dx, 00h
e32b3:  83 cf 0c                                   or         word di, 0ch

;  XREF: e32aa
e32b6:  0b c9                 loc_e32b6:           or         cx, cx
e32b8:  79 0a                                      jns        loc_e32c4
e32ba:  f7 d9                                      neg        word cx
e32bc:  f7 db                                      neg        word bx
e32be:  83 d9 00                                   sbb        word cx, 00h
e32c1:  83 f7 04                                   xor        word di, 04h

;  XREF: e32a6, e32b8
e32c4:  8b e9                 loc_e32c4:           mov        bp, cx
e32c6:  b9 20 00                                   mov        cx, 0020h
e32c9:  57                                         push       di
e32ca:  33 ff                                      xor        di, di
e32cc:  33 f6                                      xor        si, si

;  XREF: e32e5
e32ce:  d1 e0                 loc_e32ce:           shl        ax, 1
e32d0:  d1 d2                                      rcl        dx, 1
e32d2:  d1 d6                                      rcl        si, 1
e32d4:  d1 d7                                      rcl        di, 1
e32d6:  3b fd                                      cmp        di, bp
e32d8:  72 0b                                      jb         loc_e32e5
e32da:  77 04                                      ja         loc_e32e0
e32dc:  3b f3                                      cmp        si, bx
e32de:  72 05                                      jb         loc_e32e5

;  XREF: e32da
e32e0:  2b f3                 loc_e32e0:           sub        si, bx
e32e2:  1b fd                                      sbb        di, bp
e32e4:  40                                         inc        ax

;  XREF: e32d8, e32de
e32e5:  e2 e7                 loc_e32e5:           loop       loc_e32ce
e32e7:  5b                                         pop        bx
e32e8:  f7 c3 02 00                                test       word bx, 0002h
e32ec:  74 06                                      jz         loc_e32f4
e32ee:  8b c6                                      mov        ax, si
e32f0:  8b d7                                      mov        dx, di
e32f2:  d1 eb                                      shr        bx, 1

;  XREF: e32ec
e32f4:  f7 c3 04 00           loc_e32f4:           test       word bx, 0004h
e32f8:  74 07                                      jz         loc_e3301
e32fa:  f7 da                                      neg        word dx
e32fc:  f7 d8                                      neg        word ax
e32fe:  83 da 00                                   sbb        word dx, 00h

;  XREF: e32f8, e3312
e3301:  5f                    loc_e3301:           pop        di
e3302:  5e                                         pop        si
e3303:  5d                                         pop        bp
e3304:  ca 08 00                                   retf       0008h

;  XREF: e329c, e32a0
e3307:  f7 f3                 loc_e3307:           div        word bx
e3309:  f7 c7 02 00                                test       word di, 0002h
e330d:  74 01                                      jz         loc_e3310
e330f:  92                                         xchg       ax, dx

;  XREF: e330d
e3310:  33 d2                 loc_e3310:           xor        dx, dx
e3312:  eb ed                                      jmp short  loc_e3301

;  XREF: d3d9b, d3e3a, d3eed

; -----------------------------------------------------------------------------
; player_struct_write (0xE3314)
; Write to player data structure
; -----------------------------------------------------------------------------
e3314:  56                    player_struct_write:           push       si
e3315:  96                                         xchg       ax, si
e3316:  92                                         xchg       ax, dx
e3317:  85 c0                                      test       ax, ax
e3319:  74 02                                      jz         loc_e331d
e331b:  f7 e3                                      mul        word bx

;  XREF: e3319
e331d:  e3 05                 loc_e331d:           jcxz       loc_e3324
e331f:  91                                         xchg       ax, cx
e3320:  f7 e6                                      mul        word si
e3322:  03 c1                                      add        ax, cx

;  XREF: e331d
e3324:  96                    loc_e3324:           xchg       ax, si
e3325:  f7 e3                                      mul        word bx
e3327:  03 d6                                      add        dx, si
e3329:  5e                                         pop        si
e332a:  cb                                         retf

;  XREF: d0031

; =============================================================================
; SEGMENT F000 - SYSTEM CODE & BIOS (0xF0000-0xFFFFF, 64KB)
; =============================================================================
; Low-level system code including:
;   - DMD buffer management (swap, clear, copy)
;   - Pixel/line/rectangle drawing primitives
;   - Bitmap/sprite rendering engine
;   - Font system (glyph lookup, string measurement, text rendering)
;   - Text encoding: custom mapping A=0x0B..Z=0x25, Ñ=0x19, space=0x0A
;   - DMD animation engine (frame loading, transitions, callbacks)
;   - EEPROM read/write/validate routines
;   - RAM self-test and ROM checksum verification
;   - 80188 peripheral initialization
;   - Interrupt handlers (timer, serial)
;   - Service menu system (bilingual Spanish/English):
;     AJUSTE/ADJUSTMENT > SONIDO/SOUND, VIDEO, JUEGO/GAME, TECNICO/TECHNICAL
;     TEST TABLERO/BOARD TEST > BOBINAS/SOLENOIDS, LUCES/LIGHTS, CONTACTOS/SWITCHES
;   - Font glyph lookup and text encoding decoder
;   - Copyright display (SLEIC 1994)
;
; Text encoding system (custom character mapping):
;   0x0A = space, 0x0B = 'A', 0x0C = 'B', ..., 0x18 = 'N', 0x19 = 'Ñ'
;   0x1A = 'O', ..., 0x25 = 'Z', 0x2C = comma, 0x2E = period
;   0x2F = newline, 0x00 = string terminator
; =============================================================================

; -----------------------------------------------------------------------------
; system_init (0xF0000)
; System initialization (called from boot, before main loop)
; -----------------------------------------------------------------------------
f0000:  1e                    system_init:           push       ds
f0001:  b8 00 40                                   mov        ax, 4000h
f0004:  8e d8                                      mov        ds, ax
f0006:  0e                                         push       cs
f0007:  e8 ba 00                                   call       dmd_buffer_swap
f000a:  90                                         nop
f000b:  0e                                         push       cs
f000c:  e8 e2 00                                   call       dmd_buffer_clear
f000f:  90                                         nop
f0010:  0e                                         push       cs
f0011:  e8 ff 00                                   call       dmd_pixel_set
f0014:  90                                         nop
f0015:  0e                                         push       cs
f0016:  e8 0b 01                                   call       dmd_pixel_clear
f0019:  90                                         nop
f001a:  c6 06 00 10 ff                             mov        byte [1000h], ffh
f001f:  c6 06 f0 10 00                             mov        byte [10f0h], 00h
f0024:  c6 06 d5 10 00                             mov        byte [10d5h], 00h
f0029:  c6 06 dd 10 00                             mov        byte [10ddh], 00h
f002e:  c6 06 f1 10 00                             mov        byte [10f1h], 00h
f0033:  c6 06 42 11 00                             mov        byte [1142h], 00h
f0038:  c6 06 33 11 00                             mov        byte [1133h], 00h
f003d:  c6 06 d9 10 00                             mov        byte [10d9h], 00h
f0042:  c6 06 48 11 00                             mov        byte [1148h], 00h
f0047:  c6 06 e2 10 00                             mov        byte [10e2h], 00h
f004c:  c6 06 e5 10 00                             mov        byte [10e5h], 00h
f0051:  c6 06 d0 10 00                             mov        byte [10d0h], 00h
f0056:  c7 06 ca 10 00 00                          mov        word [10cah], 0000h
f005c:  c7 06 ce 10 00 00                          mov        word [10ceh], 0000h
f0062:  c7 06 d1 10 00 00                          mov        word [10d1h], 0000h
f0068:  c7 06 d7 10 00 00                          mov        word [10d7h], 0000h
f006e:  c7 06 da 10 00 00                          mov        word [10dah], 0000h
f0074:  c7 06 df 10 00 00                          mov        word [10dfh], 0000h
f007a:  c7 06 e3 10 00 00                          mov        word [10e3h], 0000h
f0080:  c7 06 ec 10 00 00                          mov        word [10ech], 0000h
f0086:  c7 06 fc 10 00 00                          mov        word [10fch], 0000h
f008c:  c7 06 02 11 01 00                          mov        word [1102h], 0001h
f0092:  c7 06 04 11 01 00                          mov        word [1104h], 0001h
f0098:  c7 06 06 11 01 00                          mov        word [1106h], 0001h
f009e:  1f                                         pop        ds
f009f:  cb                                         retf

;  XREF: f1757, f17a6

; -----------------------------------------------------------------------------
; dmd_buffer_select (0xF00A0)
; Select active DMD display buffer (2 refs)
; -----------------------------------------------------------------------------
f00a0:  55                    dmd_buffer_select:           push       bp
f00a1:  8b ec                                      mov        bp, sp
f00a3:  1e                                         push       ds
f00a4:  b8 00 40                                   mov        ax, 4000h
f00a7:  8e d8                                      mov        ds, ax
f00a9:  b8 00 a0                                   mov        ax, a000h
f00ac:  8e c0                                      mov        es, ax
f00ae:  8a 46 06                                   mov        al, [bp+06h]
f00b1:  80 26 34 11 f8                             and        byte [1134h], f8h ; dmd_display_mode - Current DMD display mode (init: 0x28)
f00b6:  0a 06 34 11                                or         al, [1134h]   ; dmd_display_mode - Current DMD display mode (init: 0x28)
f00ba:  26 a2 00 00                                mov        es:[0000h], al ; DMD_CTRL1 - DMD control byte 1 (0x28 = display on)
f00be:  a2 34 11                                   mov        [1134h], al   ; dmd_display_mode - Current DMD display mode (init: 0x28)
f00c1:  1f                                         pop        ds
f00c2:  5d                                         pop        bp
f00c3:  cb                                         retf

;  XREF: d3257, d3301, d34ce, d3f15, d3fb0 (+12 more)

; -----------------------------------------------------------------------------
; dmd_buffer_swap (0xF00C4)
; Swap/select DMD display buffer
; -----------------------------------------------------------------------------
f00c4:  b8 00 40              dmd_buffer_swap:           mov        ax, 4000h
f00c7:  8e c0                                      mov        es, ax
f00c9:  b9 00 04                                   mov        cx, 0400h
f00cc:  32 c0                                      xor        al, al
f00ce:  bf 00 00                                   mov        di, 0000h

;  XREF: f00d2
f00d1:  aa                    loc_f00d1:           stosb
f00d2:  e2 fd                                      loop       loc_f00d1
f00d4:  b9 00 02                                   mov        cx, 0200h
f00d7:  b0 ff                                      mov        al, ffh
f00d9:  bf 00 04                                   mov        di, 0400h

;  XREF: f00dd
f00dc:  aa                    loc_f00dc:           stosb
f00dd:  e2 fd                                      loop       loc_f00dc
f00df:  cb                                         retf

;  XREF: d325c, d3306, d34d3, d3f1a, d3fab (+13 more)

; -----------------------------------------------------------------------------
; dmd_buffer_clear (0xF00F1)
; Clear active DMD buffer
; -----------------------------------------------------------------------------
f00f1:  b8 00 40              dmd_buffer_clear:           mov        ax, 4000h
f00f4:  8e c0                                      mov        es, ax
f00f6:  b9 00 04                                   mov        cx, 0400h
f00f9:  32 c0                                      xor        al, al
f00fb:  bf 00 06                                   mov        di, 0600h

;  XREF: f00ff
f00fe:  aa                    loc_f00fe:           stosb
f00ff:  e2 fd                                      loop       loc_f00fe
f0101:  cb                                         retf

;  XREF: d9fba

; -----------------------------------------------------------------------------
; memory_block_copy (0xF0102)
; Block memory copy routine
; -----------------------------------------------------------------------------
f0102:  b8 00 40              memory_block_copy:           mov        ax, 4000h
f0105:  8e c0                                      mov        es, ax
f0107:  b9 00 02                                   mov        cx, 0200h
f010a:  32 c0                                      xor        al, al
f010c:  bf 00 06                                   mov        di, 0600h

;  XREF: f0110
f010f:  aa                    loc_f010f:           stosb
f0110:  e2 fd                                      loop       loc_f010f
f0112:  cb                                         retf

;  XREF: f0011

; -----------------------------------------------------------------------------
; dmd_pixel_set (0xF0113)
; Set individual pixel in DMD buffer
; -----------------------------------------------------------------------------
f0113:  b8 00 70              dmd_pixel_set:           mov        ax, 7000h
f0116:  8e c0                                      mov        es, ax
f0118:  b9 00 04                                   mov        cx, 0400h
f011b:  32 c0                                      xor        al, al
f011d:  bf 00 00                                   mov        di, 0000h

;  XREF: f0121
f0120:  aa                    loc_f0120:           stosb
f0121:  e2 fd                                      loop       loc_f0120
f0123:  cb                                         retf

;  XREF: f0016

; -----------------------------------------------------------------------------
; dmd_pixel_clear (0xF0124)
; Clear individual pixel in DMD buffer
; -----------------------------------------------------------------------------
f0124:  b8 00 70              dmd_pixel_clear:           mov        ax, 7000h
f0127:  8e c0                                      mov        es, ax
f0129:  b9 00 04                                   mov        cx, 0400h
f012c:  32 c0                                      xor        al, al
f012e:  bf 00 00                                   mov        di, 0000h

;  XREF: f0132
f0131:  aa                    loc_f0131:           stosb
f0132:  e2 fd                                      loop       loc_f0131
f0134:  cb                                         retf

;  XREF: f075c, f07aa, f07f8, f0f49, f0f6b (+1 more)

; -----------------------------------------------------------------------------
; dmd_line_draw (0xF0135)
; Draw horizontal/vertical line in DMD buffer
; -----------------------------------------------------------------------------
f0135:  1e                    dmd_line_draw:           push       ds
f0136:  b8 00 40                                   mov        ax, 4000h
f0139:  8e d8                                      mov        ds, ax
f013b:  26 8b 04                                   mov        ax, es:[si]
f013e:  a3 ae 10                                   mov        [10aeh], ax
f0141:  46                                         inc        si
f0142:  46                                         inc        si
f0143:  26 8b 04                                   mov        ax, es:[si]
f0146:  a3 b0 10                                   mov        [10b0h], ax
f0149:  46                                         inc        si
f014a:  46                                         inc        si
f014b:  26 8b 04                                   mov        ax, es:[si]
f014e:  a3 b2 10                                   mov        [10b2h], ax
f0151:  46                                         inc        si
f0152:  46                                         inc        si
f0153:  89 36 ac 10                                mov        [10ach], si
f0157:  89 3e b4 10                                mov        [10b4h], di
f015b:  1f                                         pop        ds
f015c:  c3                                         ret

;  XREF: f0f4c, f0f6e, f376e

; -----------------------------------------------------------------------------
; dmd_rect_draw (0xF015D)
; Draw rectangle in DMD buffer
; -----------------------------------------------------------------------------
f015d:  1e                    dmd_rect_draw:           push       ds
f015e:  b8 00 40                                   mov        ax, 4000h
f0161:  8e d8                                      mov        ds, ax
f0163:  8b 36 ac 10                                mov        si, [10ach]
f0167:  8b 2e b2 10                                mov        bp, [10b2h]
f016b:  bf 00 06                                   mov        di, 0600h
f016e:  03 3e b4 10                                add        di, [10b4h]
f0172:  bb 00 02                                   mov        bx, 0200h
f0175:  8b 0e ae 10                                mov        cx, [10aeh]

;  XREF: f0192
f0179:  51                    loc_f0179:           push       cx
f017a:  57                                         push       di
f017b:  8b 0e b0 10                                mov        cx, [10b0h]

;  XREF: f018b
f017f:  26 8a 04              loc_f017f:           mov        al, es:[si]
f0182:  88 05                                      mov        [di], al
f0184:  26 8a 02                                   mov        al, es:[bp+si]
f0187:  88 01                                      mov        [bx+di], al
f0189:  46                                         inc        si
f018a:  47                                         inc        di
f018b:  e2 f2                                      loop       loc_f017f
f018d:  5f                                         pop        di
f018e:  83 c7 10                                   add        word di, 10h
f0191:  59                                         pop        cx
f0192:  e2 e5                                      loop       loc_f0179
f0194:  1f                                         pop        ds
f0195:  c3                                         ret

;  XREF: f075f, f07ad, f0807

; -----------------------------------------------------------------------------
; dmd_rect_fill (0xF0196)
; Fill rectangle in DMD buffer
; -----------------------------------------------------------------------------
f0196:  1e                    dmd_rect_fill:           push       ds
f0197:  b8 00 40                                   mov        ax, 4000h
f019a:  8e d8                                      mov        ds, ax
f019c:  8b 36 ac 10                                mov        si, [10ach]
f01a0:  bf 00 08                                   mov        di, 0800h
f01a3:  03 3e b4 10                                add        di, [10b4h]
f01a7:  8b 0e ae 10                                mov        cx, [10aeh]

;  XREF: f01bf
f01ab:  51                    loc_f01ab:           push       cx
f01ac:  57                                         push       di
f01ad:  8b 0e b0 10                                mov        cx, [10b0h]

;  XREF: f01b8
f01b1:  26 8a 04              loc_f01b1:           mov        al, es:[si]
f01b4:  88 05                                      mov        [di], al
f01b6:  46                                         inc        si
f01b7:  47                                         inc        di
f01b8:  e2 f7                                      loop       loc_f01b1
f01ba:  5f                                         pop        di
f01bb:  83 c7 10                                   add        word di, 10h
f01be:  59                                         pop        cx
f01bf:  e2 ea                                      loop       loc_f01ab
f01c1:  1f                                         pop        ds
f01c2:  c3                                         ret

;  XREF: f0783, f07d1, f082b, f0ab3, f0afb (+14 more)

; -----------------------------------------------------------------------------
; dmd_bitmap_draw (0xF01C3)
; Draw bitmap/sprite to DMD buffer
; -----------------------------------------------------------------------------
f01c3:  26 8b 04              dmd_bitmap_draw:           mov        ax, es:[si]
f01c6:  a3 b8 10                                   mov        [10b8h], ax
f01c9:  46                                         inc        si
f01ca:  46                                         inc        si
f01cb:  26 8b 04                                   mov        ax, es:[si]
f01ce:  a3 ba 10                                   mov        [10bah], ax
f01d1:  46                                         inc        si
f01d2:  46                                         inc        si
f01d3:  26 8b 04                                   mov        ax, es:[si]
f01d6:  a3 bc 10                                   mov        [10bch], ax
f01d9:  46                                         inc        si
f01da:  46                                         inc        si
f01db:  89 36 b6 10                                mov        [10b6h], si
f01df:  89 3e be 10                                mov        [10beh], di
f01e3:  c3                                         ret

;  XREF: f0eb9, f0fed

; -----------------------------------------------------------------------------
; dmd_bitmap_draw_masked (0xF01E4)
; Draw masked bitmap to DMD buffer
; -----------------------------------------------------------------------------
f01e4:  26 8b 04              dmd_bitmap_draw_masked:           mov        ax, es:[si]
f01e7:  a3 c2 10                                   mov        [10c2h], ax
f01ea:  46                                         inc        si
f01eb:  46                                         inc        si
f01ec:  26 8b 04                                   mov        ax, es:[si]
f01ef:  a3 c4 10                                   mov        [10c4h], ax
f01f2:  46                                         inc        si
f01f3:  46                                         inc        si
f01f4:  26 8b 04                                   mov        ax, es:[si]
f01f7:  a3 c6 10                                   mov        [10c6h], ax
f01fa:  46                                         inc        si
f01fb:  46                                         inc        si
f01fc:  89 36 c0 10                                mov        [10c0h], si
f0200:  89 3e c8 10                                mov        [10c8h], di
f0204:  c3                                         ret

;  XREF: f0786, f07d4, f083a, f0b4f, f0b9d (+10 more)

; -----------------------------------------------------------------------------
; dmd_buffer_copy (0xF0205)
; Copy between DMD buffers
; -----------------------------------------------------------------------------
f0205:  8b 36 b6 10           dmd_buffer_copy:           mov        si, [10b6h]
f0209:  8b 2e bc 10                                mov        bp, [10bch]
f020d:  bf 00 00                                   mov        di, 0000h
f0210:  03 3e be 10                                add        di, [10beh]
f0214:  bb 00 02                                   mov        bx, 0200h
f0217:  8b 0e b8 10                                mov        cx, [10b8h]

;  XREF: f0234
f021b:  51                    loc_f021b:           push       cx
f021c:  57                                         push       di
f021d:  8b 0e ba 10                                mov        cx, [10bah]

;  XREF: f022d
f0221:  26 8a 04              loc_f0221:           mov        al, es:[si]
f0224:  88 05                                      mov        [di], al
f0226:  26 8a 02                                   mov        al, es:[bp+si]
f0229:  88 01                                      mov        [bx+di], al
f022b:  46                                         inc        si
f022c:  47                                         inc        di
f022d:  e2 f2                                      loop       loc_f0221
f022f:  5f                                         pop        di
f0230:  83 c7 10                                   add        word di, 10h
f0233:  59                                         pop        cx
f0234:  e2 e5                                      loop       loc_f021b
f0236:  8b 36 b6 10                                mov        si, [10b6h]
f023a:  8b 2e bc 10                                mov        bp, [10bch]
f023e:  bf 00 04                                   mov        di, 0400h
f0241:  03 3e be 10                                add        di, [10beh]
f0245:  03 f5                                      add        si, bp
f0247:  03 f5                                      add        si, bp
f0249:  8b 0e b8 10                                mov        cx, [10b8h]

;  XREF: f0261
f024d:  51                    loc_f024d:           push       cx
f024e:  57                                         push       di
f024f:  8b 0e ba 10                                mov        cx, [10bah]

;  XREF: f025a
f0253:  26 8a 04              loc_f0253:           mov        al, es:[si]
f0256:  88 05                                      mov        [di], al
f0258:  46                                         inc        si
f0259:  47                                         inc        di
f025a:  e2 f7                                      loop       loc_f0253
f025c:  5f                                         pop        di
f025d:  83 c7 10                                   add        word di, 10h
f0260:  59                                         pop        cx
f0261:  e2 ea                                      loop       loc_f024d
f0263:  c3                                         ret

;  XREF: f0ab6, f0afe

; -----------------------------------------------------------------------------
; dmd_font_init (0xF0264)
; Initialize font system
; -----------------------------------------------------------------------------
f0264:  8b 36 b6 10           dmd_font_init:           mov        si, [10b6h]
f0268:  8b 2e bc 10                                mov        bp, [10bch]
f026c:  bf 00 00                                   mov        di, 0000h
f026f:  03 3e be 10                                add        di, [10beh]
f0273:  bb 00 02                                   mov        bx, 0200h
f0276:  8b 0e b8 10                                mov        cx, [10b8h]

;  XREF: f0293
f027a:  51                    loc_f027a:           push       cx
f027b:  57                                         push       di
f027c:  8b 0e ba 10                                mov        cx, [10bah]

;  XREF: f028c
f0280:  26 8a 04              loc_f0280:           mov        al, es:[si]
f0283:  08 05                                      or         [di], al
f0285:  26 8a 02                                   mov        al, es:[bp+si]
f0288:  08 01                                      or         [bx+di], al
f028a:  46                                         inc        si
f028b:  47                                         inc        di
f028c:  e2 f2                                      loop       loc_f0280
f028e:  5f                                         pop        di
f028f:  83 c7 10                                   add        word di, 10h
f0292:  59                                         pop        cx
f0293:  e2 e5                                      loop       loc_f027a
f0295:  8b 36 b6 10                                mov        si, [10b6h]
f0299:  8b 2e bc 10                                mov        bp, [10bch]
f029d:  bf 00 04                                   mov        di, 0400h
f02a0:  03 3e be 10                                add        di, [10beh]
f02a4:  03 f5                                      add        si, bp
f02a6:  03 f5                                      add        si, bp
f02a8:  8b 0e b8 10                                mov        cx, [10b8h]

;  XREF: f02c0
f02ac:  51                    loc_f02ac:           push       cx
f02ad:  57                                         push       di
f02ae:  8b 0e ba 10                                mov        cx, [10bah]

;  XREF: f02b9
f02b2:  26 8a 04              loc_f02b2:           mov        al, es:[si]
f02b5:  20 05                                      and        [di], al
f02b7:  46                                         inc        si
f02b8:  47                                         inc        di
f02b9:  e2 f7                                      loop       loc_f02b2
f02bb:  5f                                         pop        di
f02bc:  83 c7 10                                   add        word di, 10h
f02bf:  59                                         pop        cx
f02c0:  e2 ea                                      loop       loc_f02ac
f02c2:  c3                                         ret

;  XREF: f1763, f17b2, f17fa, f389c

; -----------------------------------------------------------------------------
; dmd_char_draw (0xF0348)
; Draw single character glyph to DMD
; -----------------------------------------------------------------------------
f0348:  26 8b 04              dmd_char_draw:           mov        ax, es:[si]
f034b:  a3 02 11                                   mov        [1102h], ax
f034e:  46                                         inc        si
f034f:  46                                         inc        si
f0350:  26 8b 04                                   mov        ax, es:[si]
f0353:  a3 04 11                                   mov        [1104h], ax
f0356:  46                                         inc        si
f0357:  46                                         inc        si
f0358:  26 8b 04                                   mov        ax, es:[si]
f035b:  a3 06 11                                   mov        [1106h], ax
f035e:  46                                         inc        si
f035f:  46                                         inc        si
f0360:  89 36 fe 10                                mov        [10feh], si
f0364:  8c 06 00 11                                mov        [1100h], es
f0368:  89 3e fc 10                                mov        [10fch], di
f036c:  c3                                         ret

;  XREF: f0d3a, f0df0, f1115, f1262

; -----------------------------------------------------------------------------
; dmd_string_measure (0xF04E6)
; Measure string width in pixels
; -----------------------------------------------------------------------------
f04e6:  bf 00 00              dmd_string_measure:           mov        di, 0000h
f04e9:  03 3e be 10                                add        di, [10beh]
f04ed:  bb 00 02                                   mov        bx, 0200h
f04f0:  8b 0e b8 10                                mov        cx, [10b8h]

;  XREF: f0509
f04f4:  51                    loc_f04f4:           push       cx
f04f5:  57                                         push       di
f04f6:  8b 0e ba 10                                mov        cx, [10bah]

;  XREF: f0502
f04fa:  32 c0                 loc_f04fa:           xor        al, al
f04fc:  88 05                                      mov        [di], al
f04fe:  88 01                                      mov        [bx+di], al
f0500:  46                                         inc        si
f0501:  47                                         inc        di
f0502:  e2 f6                                      loop       loc_f04fa
f0504:  5f                                         pop        di
f0505:  83 c7 10                                   add        word di, 10h
f0508:  59                                         pop        cx
f0509:  e2 e9                                      loop       loc_f04f4
f050b:  bf 00 04                                   mov        di, 0400h
f050e:  03 3e be 10                                add        di, [10beh]
f0512:  8b 0e b8 10                                mov        cx, [10b8h]

;  XREF: f0528
f0516:  51                    loc_f0516:           push       cx
f0517:  57                                         push       di
f0518:  8b 0e ba 10                                mov        cx, [10bah]

;  XREF: f0521
f051c:  c6 05 ff              loc_f051c:           mov        byte [di], ffh
f051f:  46                                         inc        si
f0520:  47                                         inc        di
f0521:  e2 f9                                      loop       loc_f051c
f0523:  5f                                         pop        di
f0524:  83 c7 10                                   add        word di, 10h
f0527:  59                                         pop        cx
f0528:  e2 ec                                      loop       loc_f0516
f052a:  c3                                         ret

;  XREF: f0ebc, f0ff0

; -----------------------------------------------------------------------------
; dmd_string_draw_centered (0xF0564)
; Draw string centered on DMD
; -----------------------------------------------------------------------------
f0564:  bf 00 00              dmd_string_draw_centered:           mov        di, 0000h
f0567:  03 3e c8 10                                add        di, [10c8h]
f056b:  bb 00 02                                   mov        bx, 0200h
f056e:  8b 0e c2 10                                mov        cx, [10c2h]

;  XREF: f0587
f0572:  51                    loc_f0572:           push       cx
f0573:  57                                         push       di
f0574:  8b 0e c4 10                                mov        cx, [10c4h]

;  XREF: f0580
f0578:  32 c0                 loc_f0578:           xor        al, al
f057a:  88 05                                      mov        [di], al
f057c:  88 01                                      mov        [bx+di], al
f057e:  46                                         inc        si
f057f:  47                                         inc        di
f0580:  e2 f6                                      loop       loc_f0578
f0582:  5f                                         pop        di
f0583:  83 c7 10                                   add        word di, 10h
f0586:  59                                         pop        cx
f0587:  e2 e9                                      loop       loc_f0572
f0589:  bf 00 04                                   mov        di, 0400h
f058c:  03 3e c8 10                                add        di, [10c8h]
f0590:  8b 0e c2 10                                mov        cx, [10c2h]

;  XREF: f05a6
f0594:  51                    loc_f0594:           push       cx
f0595:  57                                         push       di
f0596:  8b 0e c4 10                                mov        cx, [10c4h]

;  XREF: f059f
f059a:  c6 05 ff              loc_f059a:           mov        byte [di], ffh
f059d:  46                                         inc        si
f059e:  47                                         inc        di
f059f:  e2 f9                                      loop       loc_f059a
f05a1:  5f                                         pop        di
f05a2:  83 c7 10                                   add        word di, 10h
f05a5:  59                                         pop        cx
f05a6:  e2 ec                                      loop       loc_f0594
f05a8:  c3                                         ret

;  XREF: d5255, d5286, d5396, d53bd, d53f3 (+41 more)

; -----------------------------------------------------------------------------
; dmd_text_render (0xF0701)
; MAIN TEXT RENDER FUNCTION: Render text string to DMD. Params: font_type, Y_position, string_offset, string_segment (all pushed on stack). Font type 1 = large font with Ñ at index 25
; -----------------------------------------------------------------------------
f0701:  55                    dmd_text_render:           push       bp
f0702:  8b ec                                      mov        bp, sp
f0704:  06                                         push       es
f0705:  c4 76 0a                                   les        si, [bp+0ah]
f0708:  8b 7e 08                                   mov        di, [bp+08h]
f070b:  8b 5e 06                                   mov        bx, [bp+06h]
f070e:  26 8a 0c                                   mov        cl, es:[si]
f0711:  32 ff                                      xor        bh, bh
f0713:  32 ed                                      xor        ch, ch
f0715:  46                                         inc        si
f0716:  1e                                         push       ds
f0717:  b8 00 40                                   mov        ax, 4000h
f071a:  8e d8                                      mov        ds, ax
f071c:  83 fb 00                                   cmp        word bx, 00h
f071f:  75 03                                      jnz        loc_f0724
f0721:  eb 24                                      jmp short  loc_f0747

;  XREF: f071f
f0724:  83 fb 01              loc_f0724:           cmp        word bx, 01h
f0727:  75 03                                      jnz        loc_f072c
f0729:  eb 43                                      jmp short  loc_f076e

;  XREF: f0727
f072c:  83 fb 10              loc_f072c:           cmp        word bx, 10h
f072f:  75 03                                      jnz        loc_f0734
f0731:  eb 62                                      jmp short  loc_f0795

;  XREF: f072f
f0734:  83 fb 11              loc_f0734:           cmp        word bx, 11h
f0737:  75 03                                      jnz        loc_f073c
f0739:  e9 80 00                                   jmp        loc_f07bc

;  XREF: f0737
f073c:  83 fb 20              loc_f073c:           cmp        word bx, 20h
f073f:  75 03                                      jnz        loc_f0744
f0741:  e9 9f 00                                   jmp        loc_f07e3

;  XREF: f073f
f0744:  e9 cf 00              loc_f0744:           jmp        loc_f0816

;  XREF: f0721, f0768
f0747:  06                    loc_f0747:           push       es
f0748:  51                                         push       cx
f0749:  57                                         push       di
f074a:  56                                         push       si
f074b:  26 8a 04                                   mov        al, es:[si]
f074e:  32 e4                                      xor        ah, ah
f0750:  2e c4 36 eb 52                             les        si, cs:[52ebh]
f0755:  ba 21 00                                   mov        dx, 0021h
f0758:  f7 e2                                      mul        word dx
f075a:  03 f0                                      add        si, ax
f075c:  e8 d6 f9                                   call       dmd_line_draw
f075f:  e8 34 fa                                   call       dmd_rect_fill
f0762:  5e                                         pop        si
f0763:  5f                                         pop        di
f0764:  59                                         pop        cx
f0765:  07                                         pop        es
f0766:  47                                         inc        di
f0767:  46                                         inc        si
f0768:  e2 dd                                      loop       loc_f0747
f076a:  1f                                         pop        ds
f076b:  07                                         pop        es
f076c:  5d                                         pop        bp
f076d:  cb                                         retf

;  XREF: f0729, f078f
f076e:  06                    loc_f076e:           push       es
f076f:  51                                         push       cx
f0770:  57                                         push       di
f0771:  56                                         push       si
f0772:  26 8a 04                                   mov        al, es:[si]
f0775:  32 e4                                      xor        ah, ah
f0777:  2e c4 36 eb 52                             les        si, cs:[52ebh]
f077c:  ba 21 00                                   mov        dx, 0021h
f077f:  f7 e2                                      mul        word dx
f0781:  03 f0                                      add        si, ax
f0783:  e8 3d fa                                   call       dmd_bitmap_draw
f0786:  e8 7c fa                                   call       dmd_buffer_copy
f0789:  5e                                         pop        si
f078a:  5f                                         pop        di
f078b:  59                                         pop        cx
f078c:  07                                         pop        es
f078d:  47                                         inc        di
f078e:  46                                         inc        si
f078f:  e2 dd                                      loop       loc_f076e
f0791:  1f                                         pop        ds
f0792:  07                                         pop        es
f0793:  5d                                         pop        bp
f0794:  cb                                         retf

;  XREF: f0731, f07b6
f0795:  06                    loc_f0795:           push       es
f0796:  51                                         push       cx
f0797:  57                                         push       di
f0798:  56                                         push       si
f0799:  26 8a 04                                   mov        al, es:[si]
f079c:  32 e4                                      xor        ah, ah
f079e:  2e c4 36 e7 52                             les        si, cs:[52e7h]
f07a3:  ba 2a 00                                   mov        dx, 002ah
f07a6:  f7 e2                                      mul        word dx
f07a8:  03 f0                                      add        si, ax
f07aa:  e8 88 f9                                   call       dmd_line_draw
f07ad:  e8 e6 f9                                   call       dmd_rect_fill
f07b0:  5e                                         pop        si
f07b1:  5f                                         pop        di
f07b2:  59                                         pop        cx
f07b3:  07                                         pop        es
f07b4:  47                                         inc        di
f07b5:  46                                         inc        si
f07b6:  e2 dd                                      loop       loc_f0795
f07b8:  1f                                         pop        ds
f07b9:  07                                         pop        es
f07ba:  5d                                         pop        bp
f07bb:  cb                                         retf

;  XREF: f0739, f07dd
f07bc:  06                    loc_f07bc:           push       es
f07bd:  51                                         push       cx
f07be:  57                                         push       di
f07bf:  56                                         push       si
f07c0:  26 8a 04                                   mov        al, es:[si]
f07c3:  32 e4                                      xor        ah, ah
f07c5:  2e c4 36 e7 52                             les        si, cs:[52e7h]
f07ca:  ba 2a 00                                   mov        dx, 002ah
f07cd:  f7 e2                                      mul        word dx
f07cf:  03 f0                                      add        si, ax
f07d1:  e8 ef f9                                   call       dmd_bitmap_draw
f07d4:  e8 2e fa                                   call       dmd_buffer_copy
f07d7:  5e                                         pop        si
f07d8:  5f                                         pop        di
f07d9:  59                                         pop        cx
f07da:  07                                         pop        es
f07db:  47                                         inc        di
f07dc:  46                                         inc        si
f07dd:  e2 dd                                      loop       loc_f07bc
f07df:  1f                                         pop        ds
f07e0:  07                                         pop        es
f07e1:  5d                                         pop        bp
f07e2:  cb                                         retf

;  XREF: f0741, f0810
f07e3:  06                    loc_f07e3:           push       es
f07e4:  51                                         push       cx
f07e5:  57                                         push       di
f07e6:  56                                         push       si
f07e7:  26 8a 04                                   mov        al, es:[si]
f07ea:  32 e4                                      xor        ah, ah
f07ec:  2e c4 36 eb 52                             les        si, cs:[52ebh]
f07f1:  ba 21 00                                   mov        dx, 0021h
f07f4:  f7 e2                                      mul        word dx
f07f6:  03 f0                                      add        si, ax
f07f8:  e8 3a f9                                   call       dmd_line_draw
f07fb:  a1 b0 10                                   mov        ax, [10b0h]
f07fe:  01 06 ac 10                                add        [10ach], ax
f0802:  83 2e ae 10 01                             sub        word [10aeh], 01h
f0807:  e8 8c f9                                   call       dmd_rect_fill
f080a:  5e                                         pop        si
f080b:  5f                                         pop        di
f080c:  59                                         pop        cx
f080d:  07                                         pop        es
f080e:  47                                         inc        di
f080f:  46                                         inc        si
f0810:  e2 d1                                      loop       loc_f07e3
f0812:  1f                                         pop        ds
f0813:  07                                         pop        es
f0814:  5d                                         pop        bp
f0815:  cb                                         retf

;  XREF: f0744, f0843
f0816:  06                    loc_f0816:           push       es
f0817:  51                                         push       cx
f0818:  57                                         push       di
f0819:  56                                         push       si
f081a:  26 8a 04                                   mov        al, es:[si]
f081d:  32 e4                                      xor        ah, ah
f081f:  2e c4 36 eb 52                             les        si, cs:[52ebh]
f0824:  ba 21 00                                   mov        dx, 0021h
f0827:  f7 e2                                      mul        word dx
f0829:  03 f0                                      add        si, ax
f082b:  e8 95 f9                                   call       dmd_bitmap_draw
f082e:  a1 ba 10                                   mov        ax, [10bah]
f0831:  01 06 b6 10                                add        [10b6h], ax
f0835:  83 2e b8 10 01                             sub        word [10b8h], 01h
f083a:  e8 c8 f9                                   call       dmd_buffer_copy
f083d:  5e                                         pop        si
f083e:  5f                                         pop        di
f083f:  59                                         pop        cx
f0840:  07                                         pop        es
f0841:  47                                         inc        di
f0842:  46                                         inc        si
f0843:  e2 d1                                      loop       loc_f0816
f0845:  1f                                         pop        ds
f0846:  07                                         pop        es
f0847:  5d                                         pop        bp
f0848:  cb                                         retf

;  XREF: d318b, d322d, d3797, d3804, d3dc0 (+8 more)

; -----------------------------------------------------------------------------
; dmd_frame_load (0xF0907)
; Load DMD frame from ROM data
; -----------------------------------------------------------------------------
f0907:  55                    dmd_frame_load:           push       bp
f0908:  8b ec                                      mov        bp, sp
f090a:  c4 76 06                                   les        si, [bp+06h]
f090d:  8b 7e 0a                                   mov        di, [bp+0ah]
f0910:  1e                                         push       ds
f0911:  b8 00 40                                   mov        ax, 4000h
f0914:  8e d8                                      mov        ds, ax
f0916:  89 3e ca 10                                mov        [10cah], di
f091a:  c6 06 cc 10 00                             mov        byte [10cch], 00h
f091f:  26 a0 ea 00                                mov        al, es:[00eah]
f0923:  22 c0                                      and        al, al
f0925:  74 17                                      jz         loc_f093e
f0927:  3c 01                                      cmp        al, 01h
f0929:  74 22                                      jz         loc_f094d
f092b:  3c 02                                      cmp        al, 02h
f092d:  74 15                                      jz         loc_f0944
f092f:  3c 03                                      cmp        al, 03h
f0931:  74 14                                      jz         loc_f0947
f0933:  3c 04                                      cmp        al, 04h
f0935:  74 0a                                      jz         loc_f0941
f0937:  3c 05                                      cmp        al, 05h
f0939:  74 0f                                      jz         loc_f094a
f093b:  eb 0a                                      jmp short  loc_f0947

;  XREF: f0925
f093e:  e9 ce 01              loc_f093e:           jmp        loc_f0b0f

;  XREF: f0935
f0941:  e9 b7 02              loc_f0941:           jmp        loc_f0bfb

;  XREF: f092d
f0944:  e9 16 02              loc_f0944:           jmp        loc_f0b5d

;  XREF: f0931, f093b
f0947:  e9 2f 01              loc_f0947:           jmp        loc_f0a79

;  XREF: f0939
f094a:  e9 60 02              loc_f094a:           jmp        loc_f0bad

;  XREF: f0929
f094d:  eb 01                 loc_f094d:           jmp short  loc_f0950

;  XREF: f094d
f0950:  83 c7 0f              loc_f0950:           add        word di, 0fh
f0953:  81 c7 00 00                                add        word di, 0000h
f0957:  b9 09 00                                   mov        cx, 0009h

;  XREF: f0961
f095a:  26 80 3c 00           loc_f095a:           cmp        byte es:[si], 00h
f095e:  75 1b                                      jnz        loc_f097b
f0960:  46                                         inc        si
f0961:  e2 f7                                      loop       loc_f095a
f0963:  2e c4 36 bb 52                             les        si, cs:[52bbh]
f0968:  33 c0                                      xor        ax, ax
f096a:  ba 6c 00                                   mov        dx, 006ch
f096d:  f7 e2                                      mul        word dx
f096f:  03 f0                                      add        si, ax
f0971:  e8 07 03                                   call       dmd_anim_callback_exec
f0974:  4f                                         dec        di
f0975:  e8 03 03                                   call       dmd_anim_callback_exec
f0978:  1f                                         pop        ds
f0979:  5d                                         pop        bp
f097a:  cb                                         retf

;  XREF: f095e
f097b:  4e                    loc_f097b:           dec        si
f097c:  03 f1                                      add        si, cx
f097e:  bd 00 00                                   mov        bp, 0000h
f0981:  c6 06 cd 10 00                             mov        byte [10cdh], 00h

;  XREF: f0990
f0986:  80 3e cd 10 00        loc_f0986:           cmp        byte [10cdh], 00h
f098b:  74 1d                                      jz         loc_f09aa
f098d:  eb 7f                                      jmp short  loc_f0a0e

;  XREF: f09df, f09f9, f0a44, f0a62
f0990:  e2 f4                 loc_f0990:           loop       loc_f0986
f0992:  2e c4 36 c7 52                             les        si, cs:[52c7h]
f0997:  80 3e cd 10 00                             cmp        byte [10cdh], 00h
f099c:  75 06                                      jnz        loc_f09a4
f099e:  e8 da 02                                   call       dmd_anim_callback_exec
f09a1:  1f                                         pop        ds
f09a2:  5d                                         pop        bp
f09a3:  cb                                         retf

;  XREF: f099c
f09a4:  e8 a2 02              loc_f09a4:           call       dmd_anim_engine_tick
f09a7:  1f                                         pop        ds
f09a8:  5d                                         pop        bp
f09a9:  cb                                         retf

;  XREF: f098b
f09aa:  83 fd 03              loc_f09aa:           cmp        word bp, 03h
f09ad:  74 4c                                      jz         loc_f09fb
f09af:  83 fd 06                                   cmp        word bp, 06h
f09b2:  74 47                                      jz         loc_f09fb

;  XREF: f0a76
f09b4:  26 8a 04              loc_f09b4:           mov        al, es:[si]
f09b7:  3c 01                                      cmp        al, 01h
f09b9:  74 26                                      jz         loc_f09e1
f09bb:  c6 06 cd 10 01                             mov        byte [10cdh], 01h
f09c0:  51                                         push       cx
f09c1:  56                                         push       si
f09c2:  55                                         push       bp
f09c3:  06                                         push       es
f09c4:  2e c4 36 bb 52                             les        si, cs:[52bbh]
f09c9:  32 e4                                      xor        ah, ah
f09cb:  ba 6c 00                                   mov        dx, 006ch
f09ce:  f7 e2                                      mul        word dx
f09d0:  03 f0                                      add        si, ax
f09d2:  e8 a6 02                                   call       dmd_anim_callback_exec
f09d5:  4f                                         dec        di
f09d6:  e8 a2 02                                   call       dmd_anim_callback_exec
f09d9:  07                                         pop        es
f09da:  5d                                         pop        bp
f09db:  5e                                         pop        si
f09dc:  59                                         pop        cx
f09dd:  4e                                         dec        si
f09de:  45                                         inc        bp
f09df:  eb af                                      jmp short  loc_f0990

;  XREF: f09b9
f09e1:  c6 06 cd 10 00        loc_f09e1:           mov        byte [10cdh], 00h
f09e6:  51                                         push       cx
f09e7:  56                                         push       si
f09e8:  55                                         push       bp
f09e9:  06                                         push       es
f09ea:  2e c4 36 c3 52                             les        si, cs:[52c3h]
f09ef:  e8 89 02                                   call       dmd_anim_callback_exec
f09f2:  07                                         pop        es
f09f3:  5d                                         pop        bp
f09f4:  5e                                         pop        si
f09f5:  59                                         pop        cx
f09f6:  4e                                         dec        si
f09f7:  4f                                         dec        di
f09f8:  45                                         inc        bp
f09f9:  eb 95                                      jmp short  loc_f0990

;  XREF: f09ad, f09b2
f09fb:  51                    loc_f09fb:           push       cx
f09fc:  56                                         push       si
f09fd:  55                                         push       bp
f09fe:  06                                         push       es
f09ff:  2e c4 36 cf 52                             les        si, cs:[52cfh]
f0a04:  e8 74 02                                   call       dmd_anim_callback_exec
f0a07:  07                                         pop        es
f0a08:  5d                                         pop        bp
f0a09:  5e                                         pop        si
f0a0a:  59                                         pop        cx
f0a0b:  eb 0b                                      jmp short  loc_f0a18

;  XREF: f098d
f0a0e:  83 fd 03              loc_f0a0e:           cmp        word bp, 03h
f0a11:  74 52                                      jz         loc_f0a65
f0a13:  83 fd 06                                   cmp        word bp, 06h
f0a16:  74 4d                                      jz         loc_f0a65

;  XREF: f0a0b
f0a18:  26 8a 04              loc_f0a18:           mov        al, es:[si]
f0a1b:  3c 01                                      cmp        al, 01h
f0a1d:  74 28                                      jz         loc_f0a47
f0a1f:  c6 06 cd 10 00                             mov        byte [10cdh], 00h
f0a24:  51                                         push       cx
f0a25:  56                                         push       si
f0a26:  55                                         push       bp
f0a27:  06                                         push       es
f0a28:  2e c4 36 bf 52                             les        si, cs:[52bfh]
f0a2d:  32 e4                                      xor        ah, ah
f0a2f:  ba 6c 00                                   mov        dx, 006ch
f0a32:  f7 e2                                      mul        word dx
f0a34:  03 f0                                      add        si, ax
f0a36:  e8 10 02                                   call       dmd_anim_engine_tick
f0a39:  4f                                         dec        di
f0a3a:  e8 3e 02                                   call       dmd_anim_callback_exec
f0a3d:  07                                         pop        es
f0a3e:  5d                                         pop        bp
f0a3f:  5e                                         pop        si
f0a40:  59                                         pop        cx
f0a41:  4e                                         dec        si
f0a42:  4f                                         dec        di
f0a43:  45                                         inc        bp
f0a44:  e9 49 ff                                   jmp        loc_f0990

;  XREF: f0a1d
f0a47:  c6 06 cd 10 01        loc_f0a47:           mov        byte [10cdh], 01h
f0a4c:  51                                         push       cx
f0a4d:  56                                         push       si
f0a4e:  55                                         push       bp
f0a4f:  06                                         push       es
f0a50:  2e c4 36 cb 52                             les        si, cs:[52cbh]
f0a55:  e8 f1 01                                   call       dmd_anim_engine_tick
f0a58:  4f                                         dec        di
f0a59:  e8 1f 02                                   call       dmd_anim_callback_exec
f0a5c:  07                                         pop        es
f0a5d:  5d                                         pop        bp
f0a5e:  5e                                         pop        si
f0a5f:  59                                         pop        cx
f0a60:  4e                                         dec        si
f0a61:  45                                         inc        bp
f0a62:  e9 2b ff                                   jmp        loc_f0990

;  XREF: f0a11, f0a16
f0a65:  51                    loc_f0a65:           push       cx
f0a66:  56                                         push       si
f0a67:  55                                         push       bp
f0a68:  06                                         push       es
f0a69:  2e c4 36 d3 52                             les        si, cs:[52d3h]
f0a6e:  e8 d8 01                                   call       dmd_anim_engine_tick
f0a71:  4f                                         dec        di
f0a72:  07                                         pop        es
f0a73:  5d                                         pop        bp
f0a74:  5e                                         pop        si
f0a75:  59                                         pop        cx
f0a76:  e9 3b ff                                   jmp        loc_f09b4

;  XREF: f0947
f0a79:  e8 31 02              loc_f0a79:           call       dmd_transition_execute
f0a7c:  c6 06 cd 10 00                             mov        byte [10cdh], 00h
f0a81:  b9 09 00                                   mov        cx, 0009h

;  XREF: f0add
f0a84:  26 8a 04              loc_f0a84:           mov        al, es:[si]
f0a87:  83 f9 01                                   cmp        word cx, 01h
f0a8a:  74 06                                      jz         loc_f0a92
f0a8c:  08 06 cc 10                                or         [10cch], al
f0a90:  74 35                                      jz         loc_f0ac7

;  XREF: f0a8a
f0a92:  51                    loc_f0a92:           push       cx
f0a93:  56                                         push       si
f0a94:  57                                         push       di
f0a95:  06                                         push       es
f0a96:  80 3e cd 10 00                             cmp        byte [10cdh], 00h
f0a9b:  75 08                                      jnz        loc_f0aa5
f0a9d:  2e c4 36 fb 52                             les        si, cs:[52fbh]
f0aa2:  eb 06                                      jmp short  loc_f0aaa

;  XREF: f0a9b
f0aa5:  2e c4 36 ff 52        loc_f0aa5:           les        si, cs:[52ffh]

;  XREF: f0aa2
f0aaa:  32 e4                 loc_f0aaa:           xor        ah, ah
f0aac:  ba 1e 00                                   mov        dx, 001eh
f0aaf:  f7 e2                                      mul        word dx
f0ab1:  03 f0                                      add        si, ax
f0ab3:  e8 0d f7                                   call       dmd_bitmap_draw
f0ab6:  e8 ab f7                                   call       dmd_font_init
f0ab9:  07                                         pop        es
f0aba:  5f                                         pop        di
f0abb:  5e                                         pop        si
f0abc:  59                                         pop        cx
f0abd:  83 f9 07                                   cmp        word cx, 07h
f0ac0:  74 20                                      jz         loc_f0ae2
f0ac2:  83 f9 04                                   cmp        word cx, 04h
f0ac5:  74 1b                                      jz         loc_f0ae2

;  XREF: f0a90
f0ac7:  80 3e cd 10 00        loc_f0ac7:           cmp        byte [10cdh], 00h
f0acc:  74 09                                      jz         loc_f0ad7
f0ace:  c6 06 cd 10 00                             mov        byte [10cdh], 00h
f0ad3:  47                                         inc        di
f0ad4:  eb 06                                      jmp short  loc_f0adc

;  XREF: f0acc
f0ad7:  c6 06 cd 10 ff        loc_f0ad7:           mov        byte [10cdh], ffh

;  XREF: f0ad4, f0b0a, f0b0d
f0adc:  46                    loc_f0adc:           inc        si
f0add:  e2 a5                                      loop       loc_f0a84
f0adf:  1f                                         pop        ds
f0ae0:  5d                                         pop        bp
f0ae1:  cb                                         retf

;  XREF: f0ac0, f0ac5
f0ae2:  51                    loc_f0ae2:           push       cx
f0ae3:  56                                         push       si
f0ae4:  06                                         push       es
f0ae5:  80 3e cd 10 00                             cmp        byte [10cdh], 00h
f0aea:  74 09                                      jz         loc_f0af5
f0aec:  47                                         inc        di
f0aed:  2e c4 36 03 53                             les        si, cs:[5303h]
f0af2:  eb 06                                      jmp short  loc_f0afa

;  XREF: f0aea
f0af5:  2e c4 36 07 53        loc_f0af5:           les        si, cs:[5307h]

;  XREF: f0af2
f0afa:  57                    loc_f0afa:           push       di
f0afb:  e8 c5 f6                                   call       dmd_bitmap_draw
f0afe:  e8 63 f7                                   call       dmd_font_init
f0b01:  5f                                         pop        di
f0b02:  07                                         pop        es
f0b03:  5e                                         pop        si
f0b04:  59                                         pop        cx
f0b05:  80 3e cd 10 00                             cmp        byte [10cdh], 00h
f0b0a:  75 d0                                      jnz        loc_f0adc
f0b0c:  47                                         inc        di
f0b0d:  eb cd                                      jmp short  loc_f0adc

;  XREF: f093e
f0b0f:  b9 09 00              loc_f0b0f:           mov        cx, 0009h

;  XREF: f0b58
f0b12:  26 8a 04              loc_f0b12:           mov        al, es:[si]
f0b15:  83 f9 01                                   cmp        word cx, 01h
f0b18:  74 06                                      jz         loc_f0b20
f0b1a:  08 06 cc 10                                or         [10cch], al
f0b1e:  74 36                                      jz         loc_f0b56

;  XREF: f0b18
f0b20:  51                    loc_f0b20:           push       cx
f0b21:  56                                         push       si
f0b22:  57                                         push       di
f0b23:  06                                         push       es
f0b24:  83 f9 07                                   cmp        word cx, 07h
f0b27:  75 08                                      jnz        loc_f0b31
f0b29:  2e c4 36 f3 52                             les        si, cs:[52f3h]
f0b2e:  eb 13                                      jmp short  loc_f0b43

;  XREF: f0b27
f0b31:  83 f9 04              loc_f0b31:           cmp        word cx, 04h
f0b34:  75 08                                      jnz        loc_f0b3e
f0b36:  2e c4 36 f3 52                             les        si, cs:[52f3h]
f0b3b:  eb 06                                      jmp short  loc_f0b43

;  XREF: f0b34
f0b3e:  2e c4 36 ef 52        loc_f0b3e:           les        si, cs:[52efh]

;  XREF: f0b2e, f0b3b
f0b43:  32 e4                 loc_f0b43:           xor        ah, ah
f0b45:  ba 3c 00                                   mov        dx, 003ch
f0b48:  f7 e2                                      mul        word dx
f0b4a:  03 f0                                      add        si, ax
f0b4c:  e8 74 f6                                   call       dmd_bitmap_draw
f0b4f:  e8 b3 f6                                   call       dmd_buffer_copy
f0b52:  07                                         pop        es
f0b53:  5f                                         pop        di
f0b54:  5e                                         pop        si
f0b55:  59                                         pop        cx

;  XREF: f0b1e
f0b56:  47                    loc_f0b56:           inc        di
f0b57:  46                                         inc        si
f0b58:  e2 b8                                      loop       loc_f0b12
f0b5a:  1f                                         pop        ds
f0b5b:  5d                                         pop        bp
f0b5c:  cb                                         retf

;  XREF: f0944
f0b5d:  b9 09 00              loc_f0b5d:           mov        cx, 0009h

;  XREF: f0ba8
f0b60:  26 8a 04              loc_f0b60:           mov        al, es:[si]
f0b63:  83 f9 01                                   cmp        word cx, 01h
f0b66:  74 06                                      jz         loc_f0b6e
f0b68:  08 06 cc 10                                or         [10cch], al
f0b6c:  74 36                                      jz         loc_f0ba4

;  XREF: f0b66
f0b6e:  51                    loc_f0b6e:           push       cx
f0b6f:  56                                         push       si
f0b70:  57                                         push       di
f0b71:  06                                         push       es
f0b72:  83 f9 07                                   cmp        word cx, 07h
f0b75:  75 08                                      jnz        loc_f0b7f
f0b77:  2e c4 36 17 53                             les        si, cs:[5317h]
f0b7c:  eb 13                                      jmp short  loc_f0b91

;  XREF: f0b75
f0b7f:  83 f9 04              loc_f0b7f:           cmp        word cx, 04h
f0b82:  75 08                                      jnz        loc_f0b8c
f0b84:  2e c4 36 17 53                             les        si, cs:[5317h]
f0b89:  eb 06                                      jmp short  loc_f0b91

;  XREF: f0b82
f0b8c:  2e c4 36 13 53        loc_f0b8c:           les        si, cs:[5313h]

;  XREF: f0b7c, f0b89
f0b91:  32 e4                 loc_f0b91:           xor        ah, ah
f0b93:  ba 90 00                                   mov        dx, 0090h
f0b96:  f7 e2                                      mul        word dx
f0b98:  03 f0                                      add        si, ax
f0b9a:  e8 26 f6                                   call       dmd_bitmap_draw
f0b9d:  e8 65 f6                                   call       dmd_buffer_copy
f0ba0:  07                                         pop        es
f0ba1:  5f                                         pop        di
f0ba2:  5e                                         pop        si
f0ba3:  59                                         pop        cx

;  XREF: f0b6c
f0ba4:  83 c7 02              loc_f0ba4:           add        word di, 02h
f0ba7:  46                                         inc        si
f0ba8:  e2 b6                                      loop       loc_f0b60
f0baa:  1f                                         pop        ds
f0bab:  5d                                         pop        bp
f0bac:  cb                                         retf

;  XREF: f094a
f0bad:  b9 09 00              loc_f0bad:           mov        cx, 0009h

;  XREF: f0bf6
f0bb0:  26 8a 04              loc_f0bb0:           mov        al, es:[si]
f0bb3:  83 f9 01                                   cmp        word cx, 01h
f0bb6:  74 06                                      jz         loc_f0bbe
f0bb8:  08 06 cc 10                                or         [10cch], al
f0bbc:  74 36                                      jz         loc_f0bf4

;  XREF: f0bb6
f0bbe:  51                    loc_f0bbe:           push       cx
f0bbf:  56                                         push       si
f0bc0:  57                                         push       di
f0bc1:  06                                         push       es
f0bc2:  83 f9 07                                   cmp        word cx, 07h
f0bc5:  75 08                                      jnz        loc_f0bcf
f0bc7:  2e c4 36 df 52                             les        si, cs:[52dfh]
f0bcc:  eb 13                                      jmp short  loc_f0be1

;  XREF: f0bc5
f0bcf:  83 f9 04              loc_f0bcf:           cmp        word cx, 04h
f0bd2:  75 08                                      jnz        loc_f0bdc
f0bd4:  2e c4 36 df 52                             les        si, cs:[52dfh]
f0bd9:  eb 06                                      jmp short  loc_f0be1

;  XREF: f0bd2
f0bdc:  2e c4 36 db 52        loc_f0bdc:           les        si, cs:[52dbh]

;  XREF: f0bcc, f0bd9
f0be1:  32 e4                 loc_f0be1:           xor        ah, ah
f0be3:  ba 2a 00                                   mov        dx, 002ah
f0be6:  f7 e2                                      mul        word dx
f0be8:  03 f0                                      add        si, ax
f0bea:  e8 d6 f5                                   call       dmd_bitmap_draw
f0bed:  e8 15 f6                                   call       dmd_buffer_copy
f0bf0:  07                                         pop        es
f0bf1:  5f                                         pop        di
f0bf2:  5e                                         pop        si
f0bf3:  59                                         pop        cx

;  XREF: f0bbc
f0bf4:  47                    loc_f0bf4:           inc        di
f0bf5:  46                                         inc        si
f0bf6:  e2 b8                                      loop       loc_f0bb0
f0bf8:  1f                                         pop        ds
f0bf9:  5d                                         pop        bp
f0bfa:  cb                                         retf

;  XREF: f0941
f0bfb:  b9 09 00              loc_f0bfb:           mov        cx, 0009h

;  XREF: f0c44
f0bfe:  26 8a 04              loc_f0bfe:           mov        al, es:[si]
f0c01:  83 f9 01                                   cmp        word cx, 01h
f0c04:  74 06                                      jz         loc_f0c0c
f0c06:  08 06 cc 10                                or         [10cch], al
f0c0a:  74 36                                      jz         loc_f0c42

;  XREF: f0c04
f0c0c:  51                    loc_f0c0c:           push       cx
f0c0d:  56                                         push       si
f0c0e:  57                                         push       di
f0c0f:  06                                         push       es
f0c10:  83 f9 07                                   cmp        word cx, 07h
f0c13:  75 08                                      jnz        loc_f0c1d
f0c15:  2e c4 36 f3 52                             les        si, cs:[52f3h]
f0c1a:  eb 13                                      jmp short  loc_f0c2f

;  XREF: f0c13
f0c1d:  83 f9 04              loc_f0c1d:           cmp        word cx, 04h
f0c20:  75 08                                      jnz        loc_f0c2a
f0c22:  2e c4 36 f3 52                             les        si, cs:[52f3h]
f0c27:  eb 06                                      jmp short  loc_f0c2f

;  XREF: f0c20
f0c2a:  2e c4 36 ef 52        loc_f0c2a:           les        si, cs:[52efh]

;  XREF: f0c1a, f0c27
f0c2f:  32 e4                 loc_f0c2f:           xor        ah, ah
f0c31:  ba 3c 00                                   mov        dx, 003ch
f0c34:  f7 e2                                      mul        word dx
f0c36:  03 f0                                      add        si, ax
f0c38:  e8 88 f5                                   call       dmd_bitmap_draw
f0c3b:  e8 c7 f5                                   call       dmd_buffer_copy
f0c3e:  07                                         pop        es
f0c3f:  5f                                         pop        di
f0c40:  5e                                         pop        si
f0c41:  59                                         pop        cx

;  XREF: f0c0a
f0c42:  47                    loc_f0c42:           inc        di
f0c43:  46                                         inc        si
f0c44:  e2 b8                                      loop       loc_f0bfe
f0c46:  1f                                         pop        ds
f0c47:  5d                                         pop        bp
f0c48:  cb                                         retf

;  XREF: f09a4, f0a36, f0a55, f0a6e

; -----------------------------------------------------------------------------
; dmd_anim_engine_tick (0xF0C49)
; Animation engine tick (advance frame timers)
; -----------------------------------------------------------------------------
f0c49:  bd 12 00              dmd_anim_engine_tick:           mov        bp, 0012h
f0c4c:  bb 00 02                                   mov        bx, 0200h
f0c4f:  b9 12 00                                   mov        cx, 0012h
f0c52:  57                                         push       di

;  XREF: f0c61
f0c53:  26 8a 04              loc_f0c53:           mov        al, es:[si]
f0c56:  08 05                                      or         [di], al
f0c58:  26 8a 02                                   mov        al, es:[bp+si]
f0c5b:  08 01                                      or         [bx+di], al
f0c5d:  46                                         inc        si
f0c5e:  83 c7 10                                   add        word di, 10h
f0c61:  e2 f0                                      loop       loc_f0c53
f0c63:  5f                                         pop        di
f0c64:  57                                         push       di
f0c65:  03 fb                                      add        di, bx
f0c67:  03 fb                                      add        di, bx
f0c69:  03 f5                                      add        si, bp
f0c6b:  b9 12 00                                   mov        cx, 0012h

;  XREF: f0c77
f0c6e:  26 8a 04              loc_f0c6e:           mov        al, es:[si]
f0c71:  20 05                                      and        [di], al
f0c73:  46                                         inc        si
f0c74:  83 c7 10                                   add        word di, 10h
f0c77:  e2 f5                                      loop       loc_f0c6e
f0c79:  5f                                         pop        di
f0c7a:  c3                                         ret

;  XREF: f0971, f0975, f099e, f09d2, f09d6 (+4 more)

; -----------------------------------------------------------------------------
; dmd_anim_callback_exec (0xF0C7B)
; Execute animation completion callback
; -----------------------------------------------------------------------------
f0c7b:  bd 12 00              dmd_anim_callback_exec:           mov        bp, 0012h
f0c7e:  bb 00 02                                   mov        bx, 0200h
f0c81:  b9 12 00                                   mov        cx, 0012h
f0c84:  57                                         push       di

;  XREF: f0c93
f0c85:  26 8a 04              loc_f0c85:           mov        al, es:[si]
f0c88:  88 05                                      mov        [di], al
f0c8a:  26 8a 02                                   mov        al, es:[bp+si]
f0c8d:  88 01                                      mov        [bx+di], al
f0c8f:  46                                         inc        si
f0c90:  83 c7 10                                   add        word di, 10h
f0c93:  e2 f0                                      loop       loc_f0c85
f0c95:  5f                                         pop        di
f0c96:  57                                         push       di
f0c97:  03 fb                                      add        di, bx
f0c99:  03 fb                                      add        di, bx
f0c9b:  03 f5                                      add        si, bp
f0c9d:  b9 12 00                                   mov        cx, 0012h

;  XREF: f0ca9
f0ca0:  26 8a 04              loc_f0ca0:           mov        al, es:[si]
f0ca3:  88 05                                      mov        [di], al
f0ca5:  46                                         inc        si
f0ca6:  83 c7 10                                   add        word di, 10h
f0ca9:  e2 f5                                      loop       loc_f0ca0
f0cab:  5f                                         pop        di
f0cac:  c3                                         ret

;  XREF: f0a79

; -----------------------------------------------------------------------------
; dmd_transition_execute (0xF0CAD)
; Execute display transition effect
; -----------------------------------------------------------------------------
f0cad:  51                    dmd_transition_execute:           push       cx
f0cae:  56                                         push       si
f0caf:  57                                         push       di
f0cb0:  06                                         push       es
f0cb1:  b9 06 00                                   mov        cx, 0006h

;  XREF: f0cc4
f0cb4:  51                    loc_f0cb4:           push       cx
f0cb5:  57                                         push       di
f0cb6:  2e c4 36 0b 53                             les        si, cs:[530bh]
f0cbb:  e8 05 f5                                   call       dmd_bitmap_draw
f0cbe:  e8 44 f5                                   call       dmd_buffer_copy
f0cc1:  5f                                         pop        di
f0cc2:  47                                         inc        di
f0cc3:  59                                         pop        cx
f0cc4:  e2 ee                                      loop       loc_f0cb4
f0cc6:  07                                         pop        es
f0cc7:  5f                                         pop        di
f0cc8:  5e                                         pop        si
f0cc9:  59                                         pop        cx
f0cca:  c3                                         ret

;  XREF: d3dd8, d3e77, d3f86, d401c, d40ea (+3 more)

; -----------------------------------------------------------------------------
; dmd_resource_load (0xF0CCB)
; Load DMD resource by ID
; -----------------------------------------------------------------------------
f0ccb:  1e                    dmd_resource_load:           push       ds
f0ccc:  b8 3c 41                                   mov        ax, 413ch
f0ccf:  8e c0                                      mov        es, ax
f0cd1:  26 a0 ea 00                                mov        al, es:[00eah]
f0cd5:  22 c0                                      and        al, al
f0cd7:  74 17                                      jz         loc_f0cf0
f0cd9:  3c 01                                      cmp        al, 01h
f0cdb:  74 1c                                      jz         loc_f0cf9
f0cdd:  3c 02                                      cmp        al, 02h
f0cdf:  74 21                                      jz         loc_f0d02
f0ce1:  3c 03                                      cmp        al, 03h
f0ce3:  74 26                                      jz         loc_f0d0b
f0ce5:  3c 04                                      cmp        al, 04h
f0ce7:  74 34                                      jz         loc_f0d1d
f0ce9:  3c 05                                      cmp        al, 05h
f0ceb:  74 27                                      jz         loc_f0d14
f0ced:  eb 1c                                      jmp short  loc_f0d0b

;  XREF: f0cd7
f0cf0:  b8 12 00              loc_f0cf0:           mov        ax, 0012h
f0cf3:  bb 09 00                                   mov        bx, 0009h
f0cf6:  eb 2e                                      jmp short  loc_f0d26

;  XREF: f0cdb
f0cf9:  b8 12 00              loc_f0cf9:           mov        ax, 0012h
f0cfc:  bb 10 00                                   mov        bx, 0010h
f0cff:  eb 25                                      jmp short  loc_f0d26

;  XREF: f0cdf
f0d02:  b8 18 00              loc_f0d02:           mov        ax, 0018h
f0d05:  bb 10 00                                   mov        bx, 0010h
f0d08:  eb 1c                                      jmp short  loc_f0d26

;  XREF: f0ce3, f0ced
f0d0b:  b8 08 00              loc_f0d0b:           mov        ax, 0008h
f0d0e:  bb 06 00                                   mov        bx, 0006h
f0d11:  eb 13                                      jmp short  loc_f0d26

;  XREF: f0ceb
f0d14:  b8 0c 00              loc_f0d14:           mov        ax, 000ch
f0d17:  bb 09 00                                   mov        bx, 0009h
f0d1a:  eb 0a                                      jmp short  loc_f0d26

;  XREF: f0ce7
f0d1d:  b8 12 00              loc_f0d1d:           mov        ax, 0012h
f0d20:  bb 09 00                                   mov        bx, 0009h
f0d23:  eb 01                                      jmp short  loc_f0d26

;  XREF: f0cf6, f0cff, f0d08, f0d11, f0d1a (+1 more)
f0d26:  50                    loc_f0d26:           push       ax
f0d27:  b8 00 40                                   mov        ax, 4000h
f0d2a:  8e d8                                      mov        ds, ax
f0d2c:  58                                         pop        ax
f0d2d:  a3 b8 10                                   mov        [10b8h], ax
f0d30:  89 1e ba 10                                mov        [10bah], bx
f0d34:  a1 ca 10                                   mov        ax, [10cah]
f0d37:  a3 be 10                                   mov        [10beh], ax
f0d3a:  e8 a9 f7                                   call       dmd_string_measure
f0d3d:  1f                                         pop        ds
f0d3e:  cb                                         retf

;  XREF: d34db, d38ed, d4557, d5194, da643 (+3 more)

; -----------------------------------------------------------------------------
; dmd_scroll_engine (0xF0D3F)
; Scrolling display engine
; -----------------------------------------------------------------------------
f0d3f:  55                    dmd_scroll_engine:           push       bp
f0d40:  8b ec                                      mov        bp, sp
f0d42:  8b 7e 06                                   mov        di, [bp+06h]
f0d45:  1e                                         push       ds
f0d46:  b8 00 40                                   mov        ax, 4000h
f0d49:  8e d8                                      mov        ds, ax
f0d4b:  89 3e ce 10                                mov        [10ceh], di
f0d4f:  c6 06 d0 10 ff                             mov        byte [10d0h], ffh
f0d54:  b8 3c 41                                   mov        ax, 413ch
f0d57:  8e c0                                      mov        es, ax
f0d59:  26 80 3e ec 00 00                          cmp        byte es:[00ech], 00h
f0d5f:  75 42                                      jnz        loc_f0da3
f0d61:  80 3e 01 10 05                             cmp        byte [1001h], 05h ; game_status_byte - Overall game status communicated to Z80
f0d66:  75 08                                      jnz        loc_f0d70
f0d68:  2e c4 36 63 53                             les        si, cs:[5363h]
f0d6d:  eb 06                                      jmp short  loc_f0d75

;  XREF: f0d66
f0d70:  2e c4 36 2f 52        loc_f0d70:           les        si, cs:[522fh]

;  XREF: f0d6d
f0d75:  e8 4b f4              loc_f0d75:           call       dmd_bitmap_draw
f0d78:  e8 8a f4                                   call       dmd_buffer_copy
f0d7b:  8b 3e be 10                                mov        di, [10beh]
f0d7f:  03 3e ba 10                                add        di, [10bah]
f0d83:  b8 3c 41                                   mov        ax, 413ch
f0d86:  8e c0                                      mov        es, ax
f0d88:  26 a0 ff 00                                mov        al, es:[00ffh]
f0d8c:  32 e4                                      xor        ah, ah
f0d8e:  ba 1e 00                                   mov        dx, 001eh
f0d91:  f7 e2                                      mul        word dx
f0d93:  2e c4 36 1b 53                             les        si, cs:[531bh]
f0d98:  03 f0                                      add        si, ax
f0d9a:  e8 26 f4                                   call       dmd_bitmap_draw
f0d9d:  e8 65 f4                                   call       dmd_buffer_copy
f0da0:  1f                                         pop        ds
f0da1:  5d                                         pop        bp
f0da2:  cb                                         retf

;  XREF: f0d5f
f0da3:  80 3e 01 10 05        loc_f0da3:           cmp        byte [1001h], 05h ; game_status_byte - Overall game status communicated to Z80
f0da8:  75 08                                      jnz        loc_f0db2
f0daa:  2e c4 36 67 53                             les        si, cs:[5367h]
f0daf:  eb 06                                      jmp short  loc_f0db7

;  XREF: f0da8
f0db2:  2e c4 36 33 52        loc_f0db2:           les        si, cs:[5233h]

;  XREF: f0daf
f0db7:  e8 09 f4              loc_f0db7:           call       dmd_bitmap_draw
f0dba:  e8 48 f4                                   call       dmd_buffer_copy
f0dbd:  1f                                         pop        ds
f0dbe:  5d                                         pop        bp
f0dbf:  cb                                         retf

;  XREF: d384f, d38e5, d519a

; -----------------------------------------------------------------------------
; dmd_credits_scroll (0xF0DC0)
; Scrolling credits display
; -----------------------------------------------------------------------------
f0dc0:  1e                    dmd_credits_scroll:           push       ds
f0dc1:  b8 00 40                                   mov        ax, 4000h
f0dc4:  8e d8                                      mov        ds, ax
f0dc6:  c6 06 d0 10 00                             mov        byte [10d0h], 00h
f0dcb:  80 3e 01 10 05                             cmp        byte [1001h], 05h ; game_status_byte - Overall game status communicated to Z80
f0dd0:  75 08                                      jnz        loc_f0dda
f0dd2:  2e c4 36 67 53                             les        si, cs:[5367h]
f0dd7:  eb 06                                      jmp short  loc_f0ddf

;  XREF: f0dd0
f0dda:  2e c4 36 33 52        loc_f0dda:           les        si, cs:[5233h]

;  XREF: f0dd7
f0ddf:  8b 3e ce 10           loc_f0ddf:           mov        di, [10ceh]
f0de3:  e8 dd f3                                   call       dmd_bitmap_draw
f0de6:  83 06 ba 10 01                             add        word [10bah], 01h
f0deb:  83 06 bc 10 08                             add        word [10bch], 08h
f0df0:  e8 f3 f6                                   call       dmd_string_measure
f0df3:  1f                                         pop        ds
f0df4:  cb                                         retf

;  XREF: d51ba, d80be

; -----------------------------------------------------------------------------
; dmd_effect_flash (0xF0DF5)
; Flash/blink display effect
; -----------------------------------------------------------------------------
f0df5:  8b ec                 dmd_effect_flash:           mov        bp, sp
f0df7:  8b 7e 04                                   mov        di, [bp+04h]
f0dfa:  1e                                         push       ds
f0dfb:  b8 00 40                                   mov        ax, 4000h
f0dfe:  8e d8                                      mov        ds, ax
f0e00:  89 3e d1 10                                mov        [10d1h], di
f0e04:  c6 06 d3 10 04                             mov        byte [10d3h], 04h
f0e09:  c6 06 d4 10 00                             mov        byte [10d4h], 00h
f0e0e:  c6 06 d5 10 ff                             mov        byte [10d5h], ffh
f0e13:  c6 06 d6 10 06                             mov        byte [10d6h], 06h
f0e18:  1f                                         pop        ds
f0e19:  cb                                         retf

;  XREF: d51c0, d755b, d75c2, dc8cf

; -----------------------------------------------------------------------------
; eeprom_read (0xF0E96)
; Read data from EEPROM
; -----------------------------------------------------------------------------
f0e96:  1e                    eeprom_read:           push       ds
f0e97:  b8 00 40                                   mov        ax, 4000h
f0e9a:  8e d8                                      mov        ds, ax
f0e9c:  80 3e 01 10 05                             cmp        byte [1001h], 05h ; game_status_byte - Overall game status communicated to Z80
f0ea1:  75 08                                      jnz        loc_f0eab
f0ea3:  2e c4 36 6b 53                             les        si, cs:[536bh]
f0ea8:  eb 06                                      jmp short  loc_f0eb0

;  XREF: f0ea1
f0eab:  2e c4 36 37 52        loc_f0eab:           les        si, cs:[5237h]

;  XREF: f0ea8
f0eb0:  8b 3e d1 10           loc_f0eb0:           mov        di, [10d1h]
f0eb4:  c6 06 d5 10 00                             mov        byte [10d5h], 00h
f0eb9:  e8 28 f3                                   call       dmd_bitmap_draw_masked
f0ebc:  e8 a5 f6                                   call       dmd_string_draw_centered
f0ebf:  1f                                         pop        ds
f0ec0:  cb                                         retf

;  XREF: f3003, f300d

; -----------------------------------------------------------------------------
; eeprom_write (0xF0F29)
; Write data to EEPROM
; -----------------------------------------------------------------------------
f0f29:  1e                    eeprom_write:           push       ds
f0f2a:  b8 00 40                                   mov        ax, 4000h
f0f2d:  8e d8                                      mov        ds, ax
f0f2f:  b8 3c 41                                   mov        ax, 413ch
f0f32:  8e c0                                      mov        es, ax
f0f34:  26 a0 d3 00                                mov        al, es:[00d3h]
f0f38:  32 e4                                      xor        ah, ah
f0f3a:  2e c4 36 ef 52                             les        si, cs:[52efh]
f0f3f:  ba 3c 00                                   mov        dx, 003ch
f0f42:  f7 e2                                      mul        word dx
f0f44:  03 f0                                      add        si, ax
f0f46:  bf e7 00                                   mov        di, 00e7h
f0f49:  e8 e9 f1                                   call       dmd_line_draw
f0f4c:  e8 0e f2                                   call       dmd_rect_draw
f0f4f:  8b 3e b4 10                                mov        di, [10b4h]
f0f53:  47                                         inc        di
f0f54:  b8 3c 41                                   mov        ax, 413ch
f0f57:  8e c0                                      mov        es, ax
f0f59:  26 a0 d2 00                                mov        al, es:[00d2h]
f0f5d:  32 e4                                      xor        ah, ah
f0f5f:  2e c4 36 ef 52                             les        si, cs:[52efh]
f0f64:  ba 3c 00                                   mov        dx, 003ch
f0f67:  f7 e2                                      mul        word dx
f0f69:  03 f0                                      add        si, ax
f0f6b:  e8 c7 f1                                   call       dmd_line_draw
f0f6e:  e8 ec f1                                   call       dmd_rect_draw
f0f71:  1f                                         pop        ds
f0f72:  cb                                         retf

;  XREF: d30f3, d51c8, d7599, da617, da6a6 (+2 more)

; -----------------------------------------------------------------------------
; eeprom_validate (0xF0F73)
; Validate EEPROM data checksum
; -----------------------------------------------------------------------------
f0f73:  8b ec                 eeprom_validate:           mov        bp, sp
f0f75:  8b 7e 04                                   mov        di, [bp+04h]
f0f78:  1e                                         push       ds
f0f79:  b8 00 40                                   mov        ax, 4000h
f0f7c:  8e d8                                      mov        ds, ax
f0f7e:  89 3e da 10                                mov        [10dah], di
f0f82:  c6 06 dc 10 05                             mov        byte [10dch], 05h
f0f87:  c6 06 de 10 00                             mov        byte [10deh], 00h
f0f8c:  c6 06 dd 10 ff                             mov        byte [10ddh], ffh
f0f91:  1f                                         pop        ds
f0f92:  cb                                         retf

;  XREF: d51ce, d80a4, d811b, da5ea, da679 (+6 more)

; -----------------------------------------------------------------------------
; ram_test (0xF0FDE)
; RAM self-test (boot diagnostic)
; -----------------------------------------------------------------------------
f0fde:  1e                    ram_test:           push       ds
f0fdf:  b8 00 40                                   mov        ax, 4000h
f0fe2:  8e d8                                      mov        ds, ax
f0fe4:  2e c4 36 6f 53                             les        si, cs:[536fh]
f0fe9:  8b 3e da 10                                mov        di, [10dah]
f0fed:  e8 f4 f1                                   call       dmd_bitmap_draw_masked
f0ff0:  e8 71 f5                                   call       dmd_string_draw_centered
f0ff3:  c6 06 dd 10 00                             mov        byte [10ddh], 00h
f0ff8:  1f                                         pop        ds
f0ff9:  cb                                         retf

;  XREF: d30ea, d8149

; -----------------------------------------------------------------------------
; rom_checksum_verify (0xF0FFA)
; ROM checksum verification
; -----------------------------------------------------------------------------
f0ffa:  8b ec                 rom_checksum_verify:           mov        bp, sp
f0ffc:  8b 7e 04                                   mov        di, [bp+04h]
f0fff:  1e                                         push       ds
f1000:  b8 00 40                                   mov        ax, 4000h
f1003:  8e d8                                      mov        ds, ax
f1005:  89 3e df 10                                mov        [10dfh], di
f1009:  c6 06 e1 10 1e                             mov        byte [10e1h], 1eh
f100e:  80 3e 01 10 05                             cmp        byte [1001h], 05h ; game_status_byte - Overall game status communicated to Z80
f1013:  75 08                                      jnz        loc_f101d
f1015:  2e c4 36 73 53                             les        si, cs:[5373h]
f101a:  eb 06                                      jmp short  loc_f1022

;  XREF: f1013
f101d:  2e c4 36 3b 52        loc_f101d:           les        si, cs:[523bh]

;  XREF: f101a
f1022:  e8 9e f1              loc_f1022:           call       dmd_bitmap_draw
f1025:  e8 dd f1                                   call       dmd_buffer_copy
f1028:  8b 3e be 10                                mov        di, [10beh]
f102c:  03 3e ba 10                                add        di, [10bah]
f1030:  b8 3c 41                                   mov        ax, 413ch
f1033:  8e c0                                      mov        es, ax
f1035:  26 a0 d7 00                                mov        al, es:[00d7h] ; game_flag_1 - General game flag 1
f1039:  32 e4                                      xor        ah, ah
f103b:  ba 1e 00                                   mov        dx, 001eh
f103e:  2e c4 36 1b 53                             les        si, cs:[531bh]
f1043:  f7 e2                                      mul        word dx
f1045:  03 f0                                      add        si, ax
f1047:  e8 79 f1                                   call       dmd_bitmap_draw
f104a:  e8 b8 f1                                   call       dmd_buffer_copy
f104d:  c6 06 e2 10 ff                             mov        byte [10e2h], ffh
f1052:  1f                                         pop        ds
f1053:  cb                                         retf

;  XREF: d34e4, d38f6, d4560, d51ad, da63a (+3 more)

; -----------------------------------------------------------------------------
; cpu_peripheral_init (0xF108E)
; 80188 peripheral control block initialization
; -----------------------------------------------------------------------------
f108e:  55                    cpu_peripheral_init:           push       bp
f108f:  8b ec                                      mov        bp, sp
f1091:  8b 7e 06                                   mov        di, [bp+06h]
f1094:  1e                                         push       ds
f1095:  b8 00 40                                   mov        ax, 4000h
f1098:  8e d8                                      mov        ds, ax
f109a:  89 3e e3 10                                mov        [10e3h], di
f109e:  c6 06 e5 10 ff                             mov        byte [10e5h], ffh
f10a3:  80 3e 01 10 05                             cmp        byte [1001h], 05h ; game_status_byte - Overall game status communicated to Z80
f10a8:  75 08                                      jnz        loc_f10b2
f10aa:  2e c4 36 77 53                             les        si, cs:[5377h]
f10af:  eb 06                                      jmp short  loc_f10b7

;  XREF: f10a8
f10b2:  2e c4 36 3f 52        loc_f10b2:           les        si, cs:[523fh]

;  XREF: f10af
f10b7:  e8 09 f1              loc_f10b7:           call       dmd_bitmap_draw
f10ba:  e8 48 f1                                   call       dmd_buffer_copy
f10bd:  8b 3e be 10                                mov        di, [10beh]
f10c1:  03 3e ba 10                                add        di, [10bah]
f10c5:  b8 3c 41                                   mov        ax, 413ch
f10c8:  8e c0                                      mov        es, ax
f10ca:  26 a0 fe 00                                mov        al, es:[00feh]
f10ce:  32 e4                                      xor        ah, ah
f10d0:  ba 1e 00                                   mov        dx, 001eh
f10d3:  2e c4 36 1b 53                             les        si, cs:[531bh]
f10d8:  f7 e2                                      mul        word dx
f10da:  03 f0                                      add        si, ax
f10dc:  e8 e4 f0                                   call       dmd_bitmap_draw
f10df:  e8 23 f1                                   call       dmd_buffer_copy
f10e2:  1f                                         pop        ds
f10e3:  5d                                         pop        bp
f10e4:  cb                                         retf

;  XREF: d384a, d51b3

; -----------------------------------------------------------------------------
; interrupt_vector_setup (0xF10E5)
; Setup interrupt vector table
; -----------------------------------------------------------------------------
f10e5:  1e                    interrupt_vector_setup:           push       ds
f10e6:  b8 00 40                                   mov        ax, 4000h
f10e9:  8e d8                                      mov        ds, ax
f10eb:  c6 06 e5 10 00                             mov        byte [10e5h], 00h
f10f0:  8b 3e e3 10                                mov        di, [10e3h]
f10f4:  80 3e 01 10 05                             cmp        byte [1001h], 05h ; game_status_byte - Overall game status communicated to Z80
f10f9:  75 08                                      jnz        loc_f1103
f10fb:  2e c4 36 77 53                             les        si, cs:[5377h]
f1100:  eb 06                                      jmp short  loc_f1108

;  XREF: f10f9
f1103:  2e c4 36 3f 52        loc_f1103:           les        si, cs:[523fh]

;  XREF: f1100
f1108:  e8 b8 f0              loc_f1108:           call       dmd_bitmap_draw
f110b:  83 06 ba 10 01                             add        word [10bah], 01h
f1110:  83 06 bc 10 08                             add        word [10bch], 08h
f1115:  e8 ce f3                                   call       dmd_string_measure
f1118:  1f                                         pop        ds
f1119:  cb                                         retf

;  XREF: d51d5, da18c, da3fb

; -----------------------------------------------------------------------------
; interrupt_handler_timer (0xF111A)
; Timer interrupt handler
; -----------------------------------------------------------------------------
f111a:  8b ec                 interrupt_handler_timer:           mov        bp, sp
f111c:  8b 7e 04                                   mov        di, [bp+04h]
f111f:  1e                                         push       ds
f1120:  b8 00 40                                   mov        ax, 4000h
f1123:  8e d8                                      mov        ds, ax
f1125:  89 3e ec 10                                mov        [10ech], di
f1129:  c7 06 e6 10 00 00                          mov        word [10e6h], 0000h ; game_end_timer - Game end display timer (1000 frames = 4.2 seconds at ~240Hz)
f112f:  c6 06 e8 10 00                             mov        byte [10e8h], 00h
f1134:  c6 06 e9 10 00                             mov        byte [10e9h], 00h
f1139:  c6 06 ea 10 00                             mov        byte [10eah], 00h
f113e:  c6 06 eb 10 00                             mov        byte [10ebh], 00h
f1143:  c6 06 f0 10 ff                             mov        byte [10f0h], ffh
f1148:  1f                                         pop        ds
f1149:  cb                                         retf

;  XREF: d383a, d51db, da1ce, da5d8, da667 (+4 more)

; -----------------------------------------------------------------------------
; interrupt_handler_serial (0xF123D)
; Serial/communication interrupt handler
; -----------------------------------------------------------------------------
f123d:  1e                    interrupt_handler_serial:           push       ds
f123e:  b8 00 40                                   mov        ax, 4000h
f1241:  8e d8                                      mov        ds, ax
f1243:  c6 06 f0 10 00                             mov        byte [10f0h], 00h
f1248:  8b 3e ec 10                                mov        di, [10ech]
f124c:  89 3e be 10                                mov        [10beh], di
f1250:  c7 06 b8 10 0e 00                          mov        word [10b8h], 000eh
f1256:  c7 06 ba 10 05 00                          mov        word [10bah], 0005h
f125c:  c7 06 bc 10 46 00                          mov        word [10bch], 0046h
f1262:  e8 81 f2                                   call       dmd_string_measure
f1265:  1f                                         pop        ds
f1266:  cb                                         retf

;  XREF: d81a0, dc751

; -----------------------------------------------------------------------------
; game_end_transition_to_attract (0xF174D)
; Transition from game-end to attract mode (original call target at D5122)
; -----------------------------------------------------------------------------
f174d:  fa                    game_end_transition_to_attract:           cli
f174e:  1e                                         push       ds
f174f:  b8 00 40                                   mov        ax, 4000h
f1752:  8e d8                                      mov        ds, ax
f1754:  6a 00                                      push       00h
f1756:  0e                                         push       cs
f1757:  e8 46 e9                                   call       dmd_buffer_select
f175a:  58                                         pop        ax
f175b:  2e c4 36 0d 13                             les        si, cs:[130dh]
f1760:  bf 00 00                                   mov        di, 0000h
f1763:  e8 e2 eb                                   call       dmd_char_draw
f1766:  83 06 fe 10 00                             add        word [10feh], 00h
f176b:  c7 06 f2 10 01 00                          mov        word [10f2h], 0001h
f1771:  c7 06 f4 10 00 00                          mov        word [10f4h], 0000h
f1777:  c7 06 0a 11 3f 00                          mov        word [110ah], 003fh
f177d:  c7 06 08 11 01 00                          mov        word [1108h], 0001h
f1783:  c7 06 f6 10 f5 2c                          mov        word [10f6h], 2cf5h
f1789:  c7 06 f8 10 9c 17                          mov        word [10f8h], 179ch
f178f:  c6 06 33 11 00                             mov        byte [1133h], 00h
f1794:  c6 06 f1 10 ff                             mov        byte [10f1h], ffh
f1799:  1f                                         pop        ds
f179a:  fb                                         sti
f179b:  cb                                         retf

;  XREF: dad39

; -----------------------------------------------------------------------------
; display_test_pattern (0xF179C)
; Display test pattern on DMD (service menu)
; -----------------------------------------------------------------------------
f179c:  fa                    display_test_pattern:           cli
f179d:  1e                                         push       ds
f179e:  b8 00 40                                   mov        ax, 4000h
f17a1:  8e d8                                      mov        ds, ax
f17a3:  6a 01                                      push       01h
f17a5:  0e                                         push       cs
f17a6:  e8 f7 e8                                   call       dmd_buffer_select
f17a9:  58                                         pop        ax
f17aa:  2e c4 36 15 13                             les        si, cs:[1315h]
f17af:  bf 00 00                                   mov        di, 0000h
f17b2:  e8 93 eb                                   call       dmd_char_draw
f17b5:  83 06 fe 10 00                             add        word [10feh], 00h
f17ba:  c7 06 f2 10 06 00                          mov        word [10f2h], 0006h
f17c0:  c7 06 f4 10 00 00                          mov        word [10f4h], 0000h
f17c6:  c7 06 0a 11 18 00                          mov        word [110ah], 0018h
f17cc:  c7 06 08 11 01 00                          mov        word [1108h], 0001h
f17d2:  c7 06 f6 10 f5 2c                          mov        word [10f6h], 2cf5h
f17d8:  c7 06 f8 10 9c 17                          mov        word [10f8h], 179ch
f17de:  c6 06 33 11 00                             mov        byte [1133h], 00h
f17e3:  c6 06 f1 10 ff                             mov        byte [10f1h], ffh
f17e8:  1f                                         pop        ds
f17e9:  fb                                         sti
f17ea:  cb                                         retf

;  XREF: d9fa8

; -----------------------------------------------------------------------------
; memory_clear_range (0xF17EB)
; Clear memory range (memset 0)
; -----------------------------------------------------------------------------
f17eb:  fa                    memory_clear_range:           cli
f17ec:  1e                                         push       ds
f17ed:  b8 00 40                                   mov        ax, 4000h
f17f0:  8e d8                                      mov        ds, ax
f17f2:  2e c4 36 47 53                             les        si, cs:[5347h]
f17f7:  bf 00 00                                   mov        di, 0000h
f17fa:  e8 4b eb                                   call       dmd_char_draw
f17fd:  83 06 fe 10 00                             add        word [10feh], 00h
f1802:  c7 06 f2 10 02 00                          mov        word [10f2h], 0002h
f1808:  c7 06 f4 10 00 00                          mov        word [10f4h], 0000h
f180e:  c7 06 0a 11 05 00                          mov        word [110ah], 0005h
f1814:  c7 06 08 11 01 00                          mov        word [1108h], 0001h
f181a:  c7 06 f6 10 f5 2c                          mov        word [10f6h], 2cf5h
f1820:  c7 06 f8 10 7c 2c                          mov        word [10f8h], 2c7ch
f1826:  c6 06 33 11 00                             mov        byte [1133h], 00h
f182b:  c6 06 f1 10 ff                             mov        byte [10f1h], ffh
f1830:  1f                                         pop        ds
f1831:  fb                                         sti
f1832:  cb                                         retf

;  XREF: da9b1, da9f4

; -----------------------------------------------------------------------------
; service_menu_main (0xF2FFD)
; Service menu main entry
; -----------------------------------------------------------------------------
f2ffd:  0e                    service_menu_main:           push       cs
f2ffe:  e8 ab 05                                   call       service_switch_test
f3001:  90                                         nop
f3002:  0e                                         push       cs
f3003:  e8 23 df                                   call       eeprom_write
f3006:  cb                                         retf

;  XREF: da9b8, da9fb

; -----------------------------------------------------------------------------
; service_menu_dispatch (0xF3007)
; Service menu item dispatcher
; -----------------------------------------------------------------------------
f3007:  0e                    service_menu_dispatch:           push       cs
f3008:  e8 ac 05                                   call       service_credits_menu
f300b:  90                                         nop
f300c:  0e                                         push       cs
f300d:  e8 19 df                                   call       eeprom_write
f3010:  cb                                         retf

;  XREF: f3419

; -----------------------------------------------------------------------------
; service_solenoid_test (0xF3371)
; Service menu: solenoid test
; -----------------------------------------------------------------------------
f3371:  b9 17 00              service_solenoid_test:           mov        cx, 0017h
f3374:  be f1 10                                   mov        si, 10f1h
f3377:  bf 1c 11                                   mov        di, 111ch
f337a:  b8 00 40                                   mov        ax, 4000h
f337d:  8e c0                                      mov        es, ax

;  XREF: f3381
f337f:  ac                    loc_f337f:           lodsb
f3380:  aa                                         stosb
f3381:  e2 fc                                      loop       loc_f337f
f3383:  c3                                         ret

;  XREF: dab0f

; -----------------------------------------------------------------------------
; service_lamp_test (0xF33EF)
; Service menu: lamp test
; -----------------------------------------------------------------------------
f33ef:  fa                    service_lamp_test:           cli
f33f0:  55                                         push       bp
f33f1:  8b ec                                      mov        bp, sp
f33f3:  8b 7e 06                                   mov        di, [bp+06h]
f33f6:  8b 5e 08                                   mov        bx, [bp+08h]
f33f9:  8b 56 0a                                   mov        dx, [bp+0ah]
f33fc:  1e                                         push       ds
f33fd:  b8 00 40                                   mov        ax, 4000h
f3400:  8e d8                                      mov        ds, ax
f3402:  89 3e be 10                                mov        [10beh], di
f3406:  32 ff                                      xor        bh, bh
f3408:  89 1e b8 10                                mov        [10b8h], bx
f340c:  32 f6                                      xor        dh, dh
f340e:  89 16 ba 10                                mov        [10bah], dx
f3412:  80 3e 33 11 00                             cmp        byte [1133h], 00h
f3417:  75 03                                      jnz        loc_f341c
f3419:  e8 55 ff                                   call       service_solenoid_test

;  XREF: f3417
f341c:  a1 b8 10              loc_f341c:           mov        ax, [10b8h]
f341f:  a3 02 11                                   mov        [1102h], ax
f3422:  a1 ba 10                                   mov        ax, [10bah]
f3425:  a3 04 11                                   mov        [1104h], ax
f3428:  a1 be 10                                   mov        ax, [10beh]
f342b:  a3 fc 10                                   mov        [10fch], ax
f342e:  c7 06 f2 10 00 00                          mov        word [10f2h], 0000h
f3434:  c7 06 f4 10 00 00                          mov        word [10f4h], 0000h
f343a:  c7 06 0a 11 08 00                          mov        word [110ah], 0008h
f3440:  c7 06 f6 10 a9 05                          mov        word [10f6h], 05a9h
f3446:  c7 06 f8 10 84 33                          mov        word [10f8h], 3384h
f344c:  c6 06 f1 10 ff                             mov        byte [10f1h], ffh
f3451:  c6 06 33 11 ff                             mov        byte [1133h], ffh
f3456:  1f                                         pop        ds
f3457:  5d                                         pop        bp
f3458:  fb                                         sti
f3459:  cb                                         retf

;  XREF: f2ffe

; -----------------------------------------------------------------------------
; service_switch_test (0xF35AC)
; Service menu: switch/contact test
; -----------------------------------------------------------------------------
f35ac:  2e c4 36 8f 53        service_switch_test:           les        si, cs:[538fh]
f35b1:  bf 03 00                                   mov        di, 0003h
f35b4:  e9 ad 01                                   jmp        loc_f3764

;  XREF: f3008

; -----------------------------------------------------------------------------
; service_credits_menu (0xF35B7)
; Service menu: credits/pricing
; -----------------------------------------------------------------------------
f35b7:  2e c4 36 57 52        service_credits_menu:           les        si, cs:[5257h]
f35bc:  bf 03 00                                   mov        di, 0003h
f35bf:  e9 a2 01                                   jmp        loc_f3764

;  XREF: daa44, daa71

; -----------------------------------------------------------------------------
; service_tilt_menu (0xF35C2)
; Service menu: tilt settings
; -----------------------------------------------------------------------------
f35c2:  2e c4 36 93 53        service_tilt_menu:           les        si, cs:[5393h]
f35c7:  bf 00 00                                   mov        di, 0000h
f35ca:  e9 97 01                                   jmp        loc_f3764

;  XREF: daa4b, daa78

; -----------------------------------------------------------------------------
; service_sound_menu (0xF35CD)
; Service menu: sound/volume settings
; -----------------------------------------------------------------------------
f35cd:  2e c4 36 5b 52        service_sound_menu:           les        si, cs:[525bh]
f35d2:  bf 00 00                                   mov        di, 0000h
f35d5:  e9 8c 01                                   jmp        loc_f3764

;  XREF: d3f00

; -----------------------------------------------------------------------------
; service_video_menu (0xF35D8)
; Service menu: video/display settings
; -----------------------------------------------------------------------------
f35d8:  2e c4 36 a7 51        service_video_menu:           les        si, cs:[51a7h]
f35dd:  bf 00 00                                   mov        di, 0000h
f35e0:  e9 81 01                                   jmp        loc_f3764

;  XREF: d402e

; -----------------------------------------------------------------------------
; service_game_menu (0xF35E3)
; Service menu: game settings (balls, specials, extra balls)
; -----------------------------------------------------------------------------
f35e3:  2e c4 36 7b 53        service_game_menu:           les        si, cs:[537bh]
f35e8:  bf 00 00                                   mov        di, 0000h
f35eb:  e9 76 01                                   jmp        loc_f3764

;  XREF: d4035

; -----------------------------------------------------------------------------
; service_balls_menu (0xF35EE)
; Service menu: ball count settings
; -----------------------------------------------------------------------------
f35ee:  2e c4 36 43 52        service_balls_menu:           les        si, cs:[5243h]
f35f3:  bf 00 00                                   mov        di, 0000h
f35f6:  e9 6b 01                                   jmp        loc_f3764

;  XREF: d464f

; -----------------------------------------------------------------------------
; service_extra_ball_menu (0xF35F9)
; Service menu: extra ball settings
; -----------------------------------------------------------------------------
f35f9:  2e c4 36 7f 53        service_extra_ball_menu:           les        si, cs:[537fh]
f35fe:  bf 00 00                                   mov        di, 0000h
f3601:  e9 60 01                                   jmp        loc_f3764

;  XREF: d4656

; -----------------------------------------------------------------------------
; service_awards_menu (0xF3604)
; Service menu: awards/specials settings
; -----------------------------------------------------------------------------
f3604:  2e c4 36 47 52        service_awards_menu:           les        si, cs:[5247h]
f3609:  bf 00 00                                   mov        di, 0000h
f360c:  e9 55 01                                   jmp        loc_f3764

;  XREF: d3f2c, d3fc2

; -----------------------------------------------------------------------------
; service_match_menu (0xF36E0)
; Service menu: match/lottery settings
; -----------------------------------------------------------------------------
f36e0:  2e c4 36 a3 53        service_match_menu:           les        si, cs:[53a3h]
f36e5:  bf 00 00                                   mov        di, 0000h
f36e8:  eb 7a                                      jmp short  loc_f3764

;  XREF: d3f33, d3fc9

; -----------------------------------------------------------------------------
; service_custom_msg_menu (0xF36EB)
; Service menu: custom message/advertising settings
; -----------------------------------------------------------------------------
f36eb:  2e c4 36 6b 52        service_custom_msg_menu:           les        si, cs:[526bh]
f36f0:  bf 00 00                                   mov        di, 0000h
f36f3:  eb 6f                                      jmp short  loc_f3764

;  XREF: d44b5

; -----------------------------------------------------------------------------
; service_technical_menu (0xF36F6)
; Service menu: technical test menu
; -----------------------------------------------------------------------------
f36f6:  2e c4 36 ab 53        service_technical_menu:           les        si, cs:[53abh]
f36fb:  bf 00 00                                   mov        di, 0000h
f36fe:  eb 64                                      jmp short  loc_f3764

;  XREF: d44bc

; -----------------------------------------------------------------------------
; service_board_test (0xF3701)
; Service menu: board test submenu
; -----------------------------------------------------------------------------
f3701:  2e c4 36 73 52        service_board_test:           les        si, cs:[5273h]
f3706:  bf 00 00                                   mov        di, 0000h
f3709:  eb 59                                      jmp short  loc_f3764

;  XREF: d3d2b

; -----------------------------------------------------------------------------
; service_statistics_menu (0xF370C)
; Service menu: statistics display
; -----------------------------------------------------------------------------
f370c:  2e c4 36 9b 53        service_statistics_menu:           les        si, cs:[539bh]
f3711:  bf 00 00                                   mov        di, 0000h
f3714:  eb 4e                                      jmp short  loc_f3764

;  XREF: d3d32

; -----------------------------------------------------------------------------
; service_statistics_games (0xF3717)
; Service menu: game count statistics
; -----------------------------------------------------------------------------
f3717:  2e c4 36 63 52        service_statistics_games:           les        si, cs:[5263h]
f371c:  bf 00 00                                   mov        di, 0000h
f371f:  eb 43                                      jmp short  loc_f3764

;  XREF: d3d69

; -----------------------------------------------------------------------------
; service_statistics_balls (0xF3738)
; Service menu: extra ball statistics
; -----------------------------------------------------------------------------
f3738:  2e c4 36 97 53        service_statistics_balls:           les        si, cs:[5397h]
f373d:  bf 00 00                                   mov        di, 0000h
f3740:  eb 22                                      jmp short  loc_f3764

;  XREF: d3e08

; -----------------------------------------------------------------------------
; service_statistics_delete (0xF3743)
; Service menu: delete/reset statistics
; -----------------------------------------------------------------------------
f3743:  2e c4 36 9f 53        service_statistics_delete:           les        si, cs:[539fh]
f3748:  bf 00 00                                   mov        di, 0000h
f374b:  eb 17                                      jmp short  loc_f3764

;  XREF: d3d70

; -----------------------------------------------------------------------------
; service_fuse_test (0xF374E)
; Service menu: fuse test
; -----------------------------------------------------------------------------
f374e:  2e c4 36 5f 52        service_fuse_test:           les        si, cs:[525fh]
f3753:  bf 00 00                                   mov        di, 0000h
f3756:  eb 0c                                      jmp short  loc_f3764

;  XREF: d3e0f

; -----------------------------------------------------------------------------
; service_factory_reset (0xF3759)
; Service menu: factory reset all
; -----------------------------------------------------------------------------
f3759:  2e c4 36 67 52        service_factory_reset:           les        si, cs:[5267h]
f375e:  bf 00 00                                   mov        di, 0000h
f3761:  eb 01                                      jmp short  loc_f3764

;  XREF: f35b4, f35bf, f35ca, f35d5, f35e0 (+14 more)
f3764:  1e                    loc_f3764:           push       ds
f3765:  55                                         push       bp
f3766:  b8 00 40                                   mov        ax, 4000h
f3769:  8e d8                                      mov        ds, ax
f376b:  e8 c7 c9                                   call       dmd_line_draw
f376e:  e8 ec c9                                   call       dmd_rect_draw
f3771:  5d                                         pop        bp
f3772:  1f                                         pop        ds
f3773:  cb                                         retf

;  XREF: f4173, f493b

; -----------------------------------------------------------------------------
; service_country_select (0xF3882)
; Service menu: country/region settings
; -----------------------------------------------------------------------------
f3882:  b8 3c 41              service_country_select:           mov        ax, 413ch
f3885:  8e c0                                      mov        es, ax
f3887:  26 c6 06 9e 00 ff                          mov        byte es:[009eh], ffh ; game_active_flag - Non-zero when game is in progress
f388d:  fa                                         cli
f388e:  1e                                         push       ds
f388f:  b8 00 40                                   mov        ax, 4000h
f3892:  8e d8                                      mov        ds, ax
f3894:  2e c4 36 57 53                             les        si, cs:[5357h]
f3899:  bf 00 00                                   mov        di, 0000h
f389c:  e8 a9 ca                                   call       dmd_char_draw
f389f:  83 06 fe 10 00                             add        word [10feh], 00h
f38a4:  c7 06 f2 10 00 00                          mov        word [10f2h], 0000h
f38aa:  c7 06 f4 10 00 00                          mov        word [10f4h], 0000h
f38b0:  c7 06 0a 11 01 00                          mov        word [110ah], 0001h
f38b6:  c7 06 08 11 01 00                          mov        word [1108h], 0001h
f38bc:  c7 06 f6 10 a2 2d                          mov        word [10f6h], 2da2h
f38c2:  c7 06 f8 10 d5 38                          mov        word [10f8h], 38d5h
f38c8:  c6 06 33 11 00                             mov        byte [1133h], 00h
f38cd:  c6 06 f1 10 ff                             mov        byte [10f1h], ffh
f38d2:  1f                                         pop        ds
f38d3:  fb                                         sti
f38d4:  cb                                         retf

;  XREF: d3284, d332e

; -----------------------------------------------------------------------------
; font_glyph_lookup (0xF4160)
; Look up font glyph data by character code
; -----------------------------------------------------------------------------
f4160:  e8 b1 0f              font_glyph_lookup:           call       copyright_display
f4163:  fa                                         cli
f4164:  1e                                         push       ds
f4165:  b8 00 40                                   mov        ax, 4000h
f4168:  8e d8                                      mov        ds, ax
f416a:  c7 06 fa 10 77 41                          mov        word [10fah], 4177h
f4170:  1f                                         pop        ds
f4171:  fb                                         sti
f4172:  0e                                         push       cs
f4173:  e8 0c f7                                   call       service_country_select
f4176:  cb                                         retf

;  XREF: d328b, d3335

; -----------------------------------------------------------------------------
; string_encoding_decode (0xF4928)
; Decode custom text encoding (A=0x0B..Z=0x25, Ñ=0x19)
; -----------------------------------------------------------------------------
f4928:  e8 e9 07              string_encoding_decode:           call       copyright_display
f492b:  fa                                         cli
f492c:  1e                                         push       ds
f492d:  b8 00 40                                   mov        ax, 4000h
f4930:  8e d8                                      mov        ds, ax
f4932:  c7 06 fa 10 3f 49                          mov        word [10fah], 493fh
f4938:  1f                                         pop        ds
f4939:  fb                                         sti
f493a:  0e                                         push       cs
f493b:  e8 44 ef                                   call       service_country_select
f493e:  cb                                         retf

;  XREF: f4160, f4928

; -----------------------------------------------------------------------------
; copyright_display (0xF5114)
; Display copyright string (SLEIC 1994, Luis Gosalbez)
; -----------------------------------------------------------------------------
f5114:  c6 06 f1 10 00        copyright_display:           mov        byte [10f1h], 00h
f5119:  0e                                         push       cs
f511a:  e8 a7 af                                   call       dmd_buffer_swap
f511d:  0e                                         push       cs
f511e:  e8 d0 af                                   call       dmd_buffer_clear
f5121:  c3                                         ret

;  XREF: ffff0

; =============================================================================
; BOOT CODE & RESET VECTOR (0xFFF00-0xFFFFF, 256 bytes)
; =============================================================================
; CPU reset enters at 0xFFFF0 (JMP FAR to 0xFFF00).
; Boot code at 0xFFF00 configures the 80188 RELREG register:
;   RELREG = C03Ch: ET=1 (escape mode for Z80 bus sharing),
;   PCB base relocated to FC00h.
; Then jumps to main_init at D000:0000.
;
; 80188 Peripheral Control Block registers configured during boot:
;   RELREG (FFA0h) = C03Ch - Z80 bus sharing enabled
;   UMCS   (FFA2h) = 3FFCh - Upper memory F0000h, 3 wait states
;   LMCS   (FFA4h) = A03Ch - Lower memory 00000h, 3 wait states
;   PACS   (FFA6h) = 41FCh - Peripheral I/O 4000h base
;   MMCS   (FFA8h) = A0FCh - Mid memory A0000h (DMD hardware)
; =============================================================================

; -----------------------------------------------------------------------------
; boot_entry_relreg (0xFFF00)
; CPU BOOT: Configure 80188 RELREG=C03Ch (ET=1 for Z80 bus sharing), then JMP to main_init
; -----------------------------------------------------------------------------
fff00:  ba a0 ff              boot_entry_relreg:         mov        dx, ffa0h
fff03:  b8 3c c0                                   mov        ax, c03ch
fff06:  ef                                         out        dx, ax
fff07:  ea 00 00 00 d0                             jmp        main_init


; -----------------------------------------------------------------------------
; reset_vector (0xFFFF0)
; CPU RESET VECTOR: JMP FAR to boot_entry_relreg
; -----------------------------------------------------------------------------
ffff0:  ea 00 00 f0 ff        reset_vector:         jmp        boot_entry_relreg
