# Sleic upstream PR plan (Bike Race + Sleic Pin-Ball)

Status: agreed 2026-08-31. Not yet executed. IO Moon explicitly out of scope.

Kept outside the `pinmame` repo on purpose: planning artifacts must not appear in
pinmame git history.

## Goal

Split the 12 local commits on `pin-ball` into two upstream PRs against
`vpinball/pinmame`, following the precedent of the accepted #614 (`feature/i8085-core-fixes`)
+ #615 (`feature/rfranco-superstar-driver`) pair: one cross-cutting CPU-core fix,
then one driver PR.

## Scope

In scope: `bikerace`, `bikerac2` (SLEIC3), `sleicpin` (SLEIC1), and the i86 core fix.

Out of scope: **Io Moon (SLEIC2)**. Confirmed clean — `pin-ball` contains zero IO Moon
driver work (all of it lives on the separate local `sleic` branch). `SLEIC2` stays an
untouched stub flagged `GAME_NOT_WORKING`.

## PR structure

**Decision (2026-08-31): TWO PRs.** Both games ship together in one driver PR.

| PR | Branch | Content | Size |
|---|---|---|---|
| 1 | `feature/i86-change-pc-20bit` | `CHANGE_PC` -> `change_pc20` in `src/cpu/i86/i86.{c,h}` | 4 lines, 2 files |
| 2 | `feature/sleic-bike-race-and-pin-ball` | SLEIC3 (`bikerace`, `bikerac2`) + SLEIC1 (`sleicpin`), flips `sleicpin` to working | 761 ins / 28 del, 3 files |

Rationale for combining rather than splitting per game:

- Both games live in the single file `src/wpc/sleic.c` and share the `SLEIC_*` platform
  code, so a per-game split would have to be *stacked* (Pin-Ball on top of Bike Race)
  rather than independent. That buys sequential merges without independent reviewability.
- Size is well within this contributor's accepted precedent: #615 (rfranco) was
  **1479 insertions across 29 files** in a single PR. The combined Sleic PR is
  **761 insertions across 3 files** -- about half.
- Commits stay grouped inside the PR (Bike Race commits first, then Pin-Ball), so a
  reviewer can still read it game by game.

Split sizes, if this is ever reversed: Bike Race 458 ins / 28 del; Pin-Ball 306 ins / 3 del.

### PR 1 — i86 core fix

`src/cpu/i86/i86.c` uses `AMASK = 0xfffff` and 20-bit accessors (`cpu_readmem20`)
throughout, but `CHANGE_PC` alone called `change_pc16`. Four call sites.

Affects four drivers that instantiate the i86 family: `sleic.c` (I188), `gts80.c` (I86),
`mephisto.c` (I88), `bingo.c` (I186). All are declared 20-bit in `cpuintrf.c`.

**Regression testing required** on `gts80`, `mephisto`, `bingo` before submitting.

### PR 2, part A — Bike Race (SLEIC3)

Source commits: `ed060114` (minus the i86 hunks), `e552ef8c`, `e8bb8658`.

Note `e8bb8658` is chronologically last but is SLEIC3 content (the embedded factory
NVRAM rationale), so it belongs here, not with Pin-Ball.

Carries the shared platform code both games use: `SLEIC_irq_i80188`,
`SLEIC_80188_writemem`, `sleic_submit_dmd_frame`, `SWITCH_UPDATE(SLEIC)`, `sleic_periph_*`.

### PR 2, part B — Sleic Pin-Ball (SLEIC1)

Source commits: `62fdf0dd`, `abb28434`, `4e0b2a8d`, `2cdf9ec7`, `e030902a`, `af2b0b8c`,
`73d723f7`, plus the `GAME_NOT_WORKING` flip.

Creates `sleic1_periph_w`, `NVRAM_HANDLER(SLEIC1)`, `SWITCH_UPDATE(SLEIC1)`,
`sleic1_z80_read/write`, `SLEIC1_80188_*` and `SLEIC1_Z80_*` maps.

PR body follows the #615 pattern: a concrete list of what actually works, each item
verified before submission.

## Merge order

**PR 1 -> PR 2.** Determined empirically, not assumed.

Experiment: reverted `change_pc20` -> `change_pc16`, rebuilt only the i86 objects,
re-ran both games headless for 600 frames with `SLEIC_DMD_DUMP`.

| Game | With fix | Without fix |
|---|---|---|
| `bikerace` | 2690 frames / 2605 non-blank / 6 unique | identical |
| `sleicpin` | 2689 / 2076 / 7 | **SIGSEGV (139)**, 8 frames, all blank |

- PR 1 before PR 2 is **mandatory**: Pin-Ball crashes without the i86 fix, so the
  combined driver PR cannot stand on its own.
- Within PR 2, the Bike Race commits must precede the Pin-Ball commits: Pin-Ball's code
  builds on the shared platform the Bike Race commit introduces.
- The commit message of `ed060114` credits Bike Race for motivating the i86 fix; the
  evidence says Pin-Ball. PR 1's message must be rewritten accordingly.

Caveat: the above is 600 frames of attract, not gameplay. It does not prove Bike Race
is independent of the fix on deeper code paths.

## History rewrite (required before any PR)

`pin-ball` was never pushed to origin, so rewriting is safe.

1. **Strip Claude attribution** from 11 of 12 commits (`Co-Authored-By: Claude Opus 4.8`).
2. **Normalize author** to `Gerwout van der Veen <gerwoutvdveen@gmail.com>` (currently `gerwout`).
3. **Drop the two `docs/superpowers/` commits from history entirely** (`064ab0b4`, `16e5ea4d`).
   Files preserved at `sleic-iomoon/docs/planning-archive/`. Also move the two untracked
   `docs/superpowers/plans/2026-06-07-*` files out of the working tree.
4. **Extract the i86 hunks** out of `ed060114` into PR 1's branch.
5. **Fix the cross-repo reference** in `sleic.c` (a comment points at
   `sleic-iomoon/research/bikerace_disasm/bikerace_nvram.md`, unreachable for upstream readers).

## Verification gates

Per-game review, evidence prepared first, then user spot-checks interactively. One game
at a time, in order: `bikerace`, `bikerac2`, `sleicpin`.

Objective signals available headless: `SLEIC_DMD_DUMP=<prefix>` writes one 128x32 P5 PGM
per submitted DMD frame; frame count / non-blank count / unique count discriminate a
working boot from a crash or a blank display.

Backup tags: `backup/pin-ball-prerebase-20260831`, plus a fresh tag before the rewrite.
