# The full game in one run

[← Back to the DMD corpus overview](../README.md)

A complete three-ball game covering the branches that matter, plus the service
menu, in a single pass. **387 distinct screens, 256 of them new to the corpus.**

Every other walk captures one area. This one is the worked example of a *whole
game*, and it is the walk to copy when starting a new machine.

| Ball | What it covers | Why it has to be that ball |
|---|---|---|
| 1 | general play, ORBITS ×6, two Jupiter locks, **Multiball**, the Jackpot (40,050,001) and Superjackpot (80,000,000), then draining out of the mode | the drop bank resets only at ball start (§3.3.6) and selects between the two lock modes (§3.3.7) — **standing** gives Multiball |
| 2 | ORBITS again, the five drop targets, the inner target → **Special Drop Probe**, two locks → **Wonderful Thing** (the Black Hole branch), Ramp 2, lane 8 | the bank comes back up at ball start, so this ball flattens it — **flat** gives Wonderful Thing rather than Multiball |
| 3 | the **Monolith** armed at lane 6 and cashed at scoop 1, twice, then both shooters for the Lagrange pair | the Monolith cycle runs continuously, so the award is whatever is lit at the instant the scoop takes it (§3.3.3) |

Afterwards the game ends and the walk opens the **service menu**.

ORBITS is spelled twice because the firmware clears the letter count
`[413C:0102]` when Multiball ends — see [`../multiball-end/`](../multiball-end/README.md).

## Driving it

Most of the lock sequences are shepherding, for the reason **F22** gives: the
Multiball start is a chain of blocking waits, the simulator's keys act on one ball
at a time, and `sub_DC6AC` waits for a released ball to report at a **scoop**
(`sub_DC675` accepts codes `0x21`/`0x22` and nothing else) while re-issuing `0xEE`
every five seconds forever. A lane will not answer it.

An extra ball falls out of the walk — the jackpots take the score past the
threshold — and `PLAYER EXTRA BALL` then stands on the panel for a long stretch of
play. That is the firmware, not a stall; play scores normally underneath it.

## Capture

```bash
python3 scripts/run_walks.py iomoon --only full-run --in-place
```

The manifest (`walks/iomoon.json`) carries the ROM set, frame budget and NVRAM
handling; `scripts/run_walks.py` does the run and the split. The Spanish twin of
this walk is [`../full-run-es/`](../full-run-es/README.md).
