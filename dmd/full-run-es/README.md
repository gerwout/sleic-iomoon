# The full game in one run — Spanish

[← Back to the DMD corpus overview](../README.md)

[`../full-run/`](../full-run/README.md)'s walk at **country 5**, which selects the
Spanish string and menu tables (F11: `D3277`, `D8048`, `DD406`). **396 distinct
screens, 308 of them new to the corpus.**

The key script is the *same file*. It presses no key that depends on the text on
screen, so the walk is language-neutral and only the cfg differs.

## How the country is set

There is no command-line DIP option in this build, so the country comes from a
saved MAME cfg: `scripts/keyscripts/iomoon-spain.cfg`, which the runner copies to
`<cfgdir>/iomoon.cfg` before the run. That cfg is the default one with a single
byte changed — offset `0x7DD`, `8` (country 4, Netherlands) → `10` (country 5,
Spain), which is the byte the known-good `iomoont-spain.cfg` also differs in.

**This walk needs `nvram: seed`**, i.e. two runs against one store, keeping the
second. `D664D` applies the DIP at boot, but on a store the firmware has not
written yet the first run is spent seeding defaults and the panel is still
English. After the second the store reads country 5 and the DMD reads `BOLAS OK`
and `ESPERANDO / CPU 8 BITS` instead of `BALLS OK` and `WAITING FOR / 8 BITS CPU`.

## Changing the country inside one run does not work

Worth recording so nobody repeats it. The only lever is MAME's own menu, and a key
script cannot drive it: nine combinations of DOWN counts into `TAB` → Dip Switches
→ SW40-2/3/4 Country → `RIGHT` left the country byte in the written cfg unchanged
at 8 every time. The script itself keeps running — marks after the `TAB` are still
written — and key injection sits at the bottom of the input system
(`internal_code_pressed`, `input.c`), so the UI ought to see the presses. What is
not established is why `input_ui_pressed`'s edge detection does not act on them.

`KEYCODE_F3` (soft reset) **does** work from a key script, and the dump continues
in the same file, so a single-run language switch becomes possible the moment that
edge case is understood.

## Capture

```bash
python3 scripts/run_walks.py iomoon --only full-run-es --in-place
```
