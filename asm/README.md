# Disassembly listings

[← Back to main README](../README.md)

| Path | CPU / device | Machine | Status |
|------|--------------|---------|--------|
| [`baseline-2026-09/`](baseline-2026-09/) | 80188 (`V1 3_01.bin`) and Z80 (`V1 3_05.bin`) | IO Moon | **Authoritative.** Cross-verified against independent decoders. |
| [`pic16c57_annotated.asm`](pic16c57_annotated.asm) | PIC16C57 (IC23) | IO Moon | **Authoritative.** 150 programmed words, verified with three independent disassemblers. |
| [`superseded/80188_annotated.asm`](superseded/80188_annotated.asm) | 80188 | IO Moon | Superseded — see below. |
| [`superseded/z80_annotated.asm`](superseded/z80_annotated.asm) | Z80 | IO Moon | Superseded — see below. |
| [`sleicpin_80188_ndisasm.asm`](sleicpin_80188_ndisasm.asm) | 80188 | Sleic Pin-Ball | Raw `ndisasm` output, unannotated. |
| [`sleicpin_80188_hlil.txt`](sleicpin_80188_hlil.txt) | 80188 | Sleic Pin-Ball | HLIL export, 201 functions. |
| [`sleicpin_z80dasm.asm`](sleicpin_z80dasm.asm) | Z80 | Sleic Pin-Ball | Raw `z80dasm` output, unannotated. |

## `baseline-2026-09/` is the reference for IO Moon

The 2026-09 baseline decodes 83 regions / 29 810 instructions of the 80188 ROM
and 12 regions / 4 760 instructions of the Z80 ROM, and cross-verifies every
instruction — `dasmx86` against capstone and ndisasm for the 80188, `dasmz80`
against unidasm for the Z80 — with the disagreement resolutions written down in
[`baseline-2026-09/reports/`](baseline-2026-09/reports/). Its numbered
conclusions live in [`baseline-2026-09/findings.md`](baseline-2026-09/findings.md)
(F1–F15), which is the contract the PinMAME `SLEIC2` driver implements. Cite
findings by number, and cite listing addresses out of
`baseline-2026-09/iomoon_80188.lst` / `iomoon_z80.lst`.

## Why `superseded/` is separate

The two listings under `superseded/` were produced by an earlier pass whose raw
decode is sound — the opcodes, operands and addresses agree with the 2026-09
baseline — but whose **routine names and data/code classification are generated
labels that were never verified**, and a significant number of them are wrong.
Documented examples:

| Label in `superseded/` | What the routine actually is |
|---|---|
| `config_load_defaults` `D0C57`, `config_load_eeprom` `D0C84` | the two OKI MSM6376 trigger sequences (findings F9) |
| `config_save_eeprom` `D0CB8`, `config_validate` `D0CE0` | the OKI silence/reset path and the `/OKCS` strobe (F9) |
| `dmd_vblank_isr` `D016D` | the NMI handler for an inbound J1 byte; it touches no pixel data (F3) |
| `sound_timer_isr` `D0250` | one byte past the real vector; timer 0's handler starts at `D024F` (F3) |
| `dmd_queue_service` `D01E5` | the outbound 80188→Z80 command-queue drain (F12) |
| `cmd_queue_push` `D0138` | the push side of that same outbound command queue (F12) |
| `DA22D` "menu dispatcher" | the high-score initials-entry handler |
| `sound_play_command` `D0978` | a **non-volatile-store** write: it opens the PCS0 window, clears `5040:02B9` and closes it again. Not a sound path (F10) |
| `d0d09`–`d0db3` classified as data | the YM3812 song-select and sequencer code (F8) |

The region `D0C19`–`D0C56`, labelled configuration data, is the OKI
sample-duration table (F9), and the far-pointer table at `F5183`–`F53EF` is live
animation data rather than fill (F2).

The listings are kept because their raw instruction stream is still a usable
cross-check and because published addresses cite them. Treat every **name** in
them as a hypothesis to test against `baseline-2026-09/`, never as evidence.
