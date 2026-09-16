# The coin-pricing page, in all seven countries

[← Back to the DMD corpus overview](../README.md)

Menu record 23 — CREDITS / CREDITOS — renders the **live** coin-pricing table, which is
the only screen where a country's own denominations appear. F11: `sub_D69CC` applies the
country's preset from the seven-way table at `D5D01`, and `D664D` lets the DIP override
the stored value on every boot. The corpus ran two countries, so five of the seven sets
had never been on screen. All seven are here.

| Country | DIP | What the page draws |
|---|--:|---|
| United Kingdom | 0 | `1 OF 50 CRED:2 / 1 OF 1PD CRED:5` |
| France | 1 | `1 OF 5F CRED:3 / 1 OF 1OF CRED:7` |
| Germany | 2 | `1 OF 2DM CRED:3 / 1 OF 5DM CRED:8` |
| Italy | 3 | *(its own row)* |
| Netherlands | 4 | `1 OF 2.5 F CR:3 / 1 OF 5 F CR:7` |
| Spain | 5 | `1 DE 100 CRED:3 / 1 DE 200 CRED:7 / 1 DE 500 CRED:18` |
| Belgium | 6 | *(its own row)* |
| Portugal | 7 | `1 OF 100 CRED:3 / 1 OF 200 CRED:6` |

Spain is the one that renders in Spanish throughout — `TEST TABLERO / CREDITOS / FALTAS`
and `1 DE …` rather than `1 OF …` — which is the country byte driving the string table,
not just the coin preset.

## Why this does not move the coverage gate, and what that tells us

**It cannot.** The ROM's own strings are **templates**: `OF 5DM CRED:`, `OF 1PD CRED:`,
`DE 100 CRED:`. The live page prepends the coin count and appends the credit count, so
what is on screen is `1 OF 5DM CRED:8` — real, legible, correctly decoded, and never a
whole-field match for the stored string.

That is the same class as `LIGHT: LC` on the light-test record: a template that the live
screen always extends. It is a **matching-rule limit, not a capture gap**, and these
twenty strings should be read that way rather than as something more capturing would
recover. The coverage document's own disposition for this group is corrected to match.

## Capture

The page needs no credits and no ball: TEST opens the menu, scroll twice and select reach
record 3 (TECHNICAL, F14/F18's own path), then one scroll and select reach record 23.

The country is a saved cfg. One byte carries it — offset **2013**, the `SW40-2/3/4`
field, `0x00` United Kingdom through `0x0e` Portugal in the order `SLEIC2_COMPORTS` lists
them — so a cfg for any country is the default cfg with that byte patched. Verify it from
the store's own trailer (`scripts/nvcheck.py`, "saved DIP bank 0"), **not** from `0x1BF`:
a plain boot never writes the store, so `0x1BF` reads 0 whatever the DIP says.

```bash
cd pinmame
SDL_VIDEODRIVER=dummy SDL_AUDIODRIVER=dummy ./build/sdl3pinmame iomoont \
  -rompath ./roms -nvram_directory /tmp/nv -nosound \
  -skip_disclaimer -skip_gameinfo -skip_gamewarnings -nothrottle -ftr 6600 \
  -dmd_dump_dir ../sleic-iomoon/dmd/credits/<country> \
  -key_script ../sleic-iomoon/scripts/keyscripts/iomoon-credits.keys
```

Run against the shipping `build/sdl3pinmame` with no probe compiled in.
