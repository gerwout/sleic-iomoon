# IO Moon PinMAME driver — design spec

Date: 2026-09-02
Status: approved-pending-review
Owner goal: **IO Moon fully playable with correct sound in PinMAME; drop
`GAME_NOT_WORKING`; submit upstream as a PR** (like the merged Bike Race /
Sleic Pin-Ball work).

## 1. Context

- Upstream `vpinball/pinmame` master (`9b497714`) now contains the merged
  SLEIC driver: Bike Race (SLEIC3) and Sleic Pin-Ball (SLEIC1) are playable;
  IO Moon (SLEIC2) is a stub flagged `GAME_NOT_WORKING`.
- The earlier IO Moon experiment (LMCS ROM banking, three-interrupt model,
  J1 latch, a **fake** DMD-marker state machine) lives only on the local
  `sleic` branch, based on a months-old master. It got IO Moon to boot,
  animate and take some input, but sound had severe errors, switch delivery
  was unreliable (markers crowded out switch bytes), and the service menu
  would not stay open.
- The blocking unknown is now resolved: the **IC23 PIC16C57 dump** was
  recovered (2026-09-02), verified, and disassembled
  (`asm/pic16c57_annotated.asm`, three disassemblers in agreement). The PIC
  is a pure raster sequencer: it reads no commands and touches no pixel
  data; its only observable effect on the 80188 is the marker cadence.
- The two PALs (IC7, IC8) are locked and remain undumped.

## 2. Goals

1. IO Moon playable end-to-end in PinMAME: coins, start, flippers,
   gameplay, service menu, YM3812 FM music and OKI MSM6376 speech/FX.
2. A **fresh, self-contained disassembly baseline** of the IO Moon ROMs
   (80188 + Z80), built with dasmxx and cross-verified, replacing reliance
   on the old annotated listings and derived docs.
3. Replace the fake marker machine with a **behavioral cadence model**
   derived from the real PIC program (approach A, chosen by the owner).
4. Upstream-quality result: clean commits on a new branch off master, no
   debug scaffolding, PR after owner sign-off.

## 3. Non-goals / explicit decisions

- **No PAL dumps required.** Both JEDECs are judged nice-to-have for
  emulation: both CPUs' firmware is fully dumped, so every address either
  CPU uses — and what it expects back — is recoverable from the ROMs. The
  PALs are combinational glue with no hidden decisions. Dumping IC7 via
  dupico is a *named contingency*, triggered only if a specific decode
  ambiguity (most plausibly OKI `/OKCS` gating) survives a clean
  reimplementation and blocks progress.
- **No PIC16C5x CPU core** (approach B rejected): PinMAME's MAME-0.76 base
  has no such core, and the PIC's pins drive the plasma panel, not the
  80188 — the 0xA0100 marker bytes are synthesized by board glue either
  way, so a real core adds cost without observable gain.
- **Old disassemblies and derived docs are hypotheses, not sources.** The
  only trusted prior artifact is the PIC disassembly. Every fact the driver
  relies on (chip-select map, marker byte values, switch codes, port roles,
  ISR structure) must be re-confirmed with an address citation into the new
  baseline. `iomoon_fm_extract.py` is used **only to locate** sound code
  and tables in the ROM — its rendered audio is known to be off, so it is
  not a correctness oracle.
- **No copying from the `sleic` branch without confirmation.** Each ported
  subsystem must first be re-derived/confirmed from the new baseline; code
  is then either adopted, rewritten, or dropped.
- Bike Race and Sleic Pin-Ball must not regress (they only recently merged
  upstream). IO Moon has the only PIC — SLEIC1/SLEIC3 keep their existing
  I8039 display path untouched.

## 4. Deliverables

| Repo | Deliverable |
|------|-------------|
| `pinmame` | Branch `io-moon` off master `9b497714`; upstream-quality commits; PR after owner sign-off |
| `sleic-iomoon` | `asm/baseline-2026-09/` — dasmxx command files, generated listings, cross-verification script + report, method README |
| `sleic-iomoon` | Updated docs where the new baseline corrects old claims |

Planning documents, debug traces and scratch tooling stay out of the
`pinmame` branch.

## 5. Disassembly baseline (phase 0)

Tooling:

- Build **dasmxx** (github.com/nejohnson/dasmxx) from source.
  `dasm86` for the 80188 ROM (`V1 3_01.bin`), `dasm80` for the Z80 ROM
  (`V1 3_05.bin`). Command-file-driven: code/data regions, labels and
  comments grow iteratively from the reset vector (`FFFF0h`) and the IVT
  outward, and on the Z80 side from `0x0000` and its interrupt entry.
- **80186/188 opcode gap**: dasm86 covers 8086/8088 only. Pre-scan the
  code regions for 186-class opcodes (`0x60–0x6F` PUSHA/POPA/BOUND/
  INS/OUTS/PUSH-imm/IMUL-imm, `0xC0/0xC1` shift-by-imm, `0xC8/0xC9`
  ENTER/LEAVE). If the firmware uses them, patch dasm86's opcode table
  locally (mechanical addition) before trusting its output.
- **Second opinions (required, automated)**: a comparison script decodes
  every accepted code region with **capstone in 16-bit x86 mode** (full
  186 support) and **ndisasm -b16**, and diffs the instruction streams
  against dasm86's. Disagreements are resolved by hand and recorded in the
  verification report. The same script covers dasm80 vs MAME `unidasm`
  (`-arch z80`, already installed) on the Z80 side.
- Optional cross-check: dasmxx's PIC disassembler as a fourth opinion on
  the (already 3-tool-verified) IC23 listing.

Exit criteria for phase 0: reset paths, IVT + all live ISRs, the main
loop, and the subsystem entry points (DMD, switch handling, sound
sequencer, OKI trigger, NVRAM access, Z80 I/O ports) identified in the new
baseline with clean cross-verification.

## 6. Driver architecture (all changes SLEIC2-gated)

Work proceeds in this order; each step is confirmed against the new
baseline before any `sleic` branch code is adopted:

1. **Memory map**: LMCS ROM banking (re-confirm the PCS0 bit semantics
   that switch segment `0000h` between graphics ROM frames and fonts),
   MMCS work RAM at `0x40000`, UMCS ROM window, 28C64A NVRAM mapped and
   wired to PinMAME's core NVRAM handling.
2. **Interrupt model**: re-derive the NMI (DMD vblank), timer 0 and INT0
   sources and vectors from the new disassembly; valid IVT at physical 0;
   keep the confirmed 977 Hz Z80 periodic IRQ.
3. **J1 byte-port**, both directions: Z80→80188 inbound latch at PCS2
   (`0xA0100`) with data-valid handshake; the 80188→Z80 reverse path
   re-derived from the new Z80 disassembly.
4. **Marker cadence generator (new code — the heart of this design)**:
   a frame clock at the wire rate (~145 Hz; two bitplane scans + inter-
   frame gap, per the PIC program structure and the measured wire
   protocol) emits: plane-0 marker → plane-1 marker (mid-frame) → vsync
   marker across the ≥100 µs gap. Marker byte values (`0x47`/`0x45`/
   `0x46` hypothesized) are re-confirmed from the firmware's own compare
   instructions. **Arbitration rule**: marker bytes and Z80 switch bytes
   share the one latch; the model must guarantee switch codes are never
   dropped (the old fake machine's failure). The exact interleaving
   contract is re-derived from the firmware's NMI dequeue logic.
5. **DMD**: keep master's 2-bitplane submit path; feed upstream's
   per-machine grey weighting the PIC's measured 200:30 (MSB:LSB) row-hold
   ratio.
6. **Lamps / solenoids / switch matrix**: mappings re-derived from the
   fresh Z80 disassembly into `coreGlobals`.
7. **Sound**: YM3812 at PCS5, OKI MSM6376 control latch at PCS6 with the
   PCS0-bit strobe, implemented in the style of master's proven SLEIC1/
   SLEIC3 handlers; sequencer and sound-timer tick rates re-derived from
   the ISR chain in the new baseline. The emulator executes the real
   firmware, so the YM register stream is generated by the ROM itself —
   the failure modes are wiring and tick rate, both owner-audible.
8. **Service menu & input polish** once the cadence holds the menu open.

## 7. Verification

Automated / headless (using master's current headless support; clean
rebuild + `~/.xpinmame/nvram/iomoon.nv` wipe before every comparison run):

- Boot-to-main-loop trace on every phase; the three merged games
  (`bikerace`, `bikerac2`, `sleicpin`) must boot headless identically as a
  regression gate.
- DMD frame captures diffed against frames decoded straight from the ROMs.
- **Switch-injection probe**: every cabinet switch code injected repeatedly
  must reach the firmware's switch handler reliably — the regression test
  for the marker/switch crowding bug.
- NVRAM persistence and credits behavior (the old credit-runaway bug).
- YM3812 write-stream sanity: registers/rates plausible, track changes on
  game events.

Owner (ground truth = the real IO Moon machine), at four checkpoints:

1. Attract mode + language select (DMD content, timing).
2. Coin + start: sounds and music start.
3. Gameplay: music transitions, speech/FX identity and pitch/tempo.
4. Service menu: opens, holds, navigates.

## 8. Risks

- **Marker byte contract wrong** → menu/input misbehave again. Mitigated:
  values and dequeue order re-derived from firmware compares, plus the
  switch-injection regression probe.
- **dasm86 opcode gaps** → silent misdecoding. Mitigated: 186 pre-scan +
  capstone/ndisasm cross-verification of every accepted region.
- **OKI latch bit split ambiguous without IC7** → wrong samples/banks.
  Mitigated: per-sample duration table + owner A/B; dupico on IC7 as the
  named contingency.
- **Timing constants (PIC crystal unknown)** → cadence rate off. Mitigated:
  wire-protocol measurements (~145 Hz frame, ≥100 µs gap) bound the model;
  rates are single constants, tunable against owner checkpoint 1.
