# The Spanish service menu

[← Back to the DMD corpus overview](../README.md)

`dmd/es/` has no service-menu tree, on the reading that **F19** makes a Spanish menu
capture impossible. It does not. **40 distinct screens, 23 new to the corpus, and the
first five Spanish menu strings the coverage gate has ever seen on screen.**

## What F19 actually blocks

F19 is about menu **exit**. Exiting queues `0xF8`, which reboots the Z80 (`2DD9: DI /
JP boot`), and the rebooting Z80's own `0xFF` state announcement wins the race against
the real `0xF9` DIP reply — `sub_D5C3E` accepts any byte `>= 0xF0`, and
`(0xFF AND 0x0E) - 2` decodes to country 7, whatever country was running.

A walk that opens the menu **once** and never exits and re-enters never runs that path.
This capture does exactly that — it navigates with select, scroll and **back**, never
TEST — and the machine stays on its DIP country throughout: `scripts/nvcheck.py` reads
**country 5 (Spain)** from the store this run wrote, and the records render in Spanish.

Two more things worth knowing about the flip, both measured:

- It reproduces on the **corrected** Z80 timing (4 MHz, IRQ 488.28 Hz), so it is not an
  artefact of the two constants the driver used to carry. A run that opens and exits the
  menu takes the store's country byte from 4 to 7; a run that does not touch the menu
  leaves it at 4.
- It is **session-only**. A power cycle puts it back: the same store, booted again
  without a menu visit, reads country 4 again, because `D664D` lets the DIP override the
  stored value on every boot (F11).

## What is on screen

| Mark | Decoded text |
|---|---|
| `open-menu` | `SONIDO/VIDEO / JUEGO / TECNICO` — the root record's three items |
| `svc-root`, `svc-branch-1-*` | `VOLUMEN / PUBLICIDAD` — record 1's two items |
| deeper records | the `h=12` tile-bar level indicator (`AA`, `AAA`, `AA8`, `--`), which is **F21**'s procedural depth bar, not text |

That is the same depth the English walk reaches: only the root and its first child settle
to legible static item text, and everything below shows the bar. The Spanish side now
matches it record for record.

`BOLAS OK` at boot is Spanish too; the two screens before it — `WAITING FOR / 8 BITS
CPU` and `SETTING / DEFAULT VALUES / PRESS START` — are drawn before the country is
applied and are English in both languages.

## Coverage

Five tier-1 strings move from missing to present, the first Spanish menu strings in the
corpus: `SONIDO/VIDEO`, `JUEGO`, `TECNICO` (record 0) and `VOLUMEN`, `PUBLICIDAD`
(record 1). The gate goes from 404 missing to **399**.

## Capture

Needs `scripts/keyscripts/iomoont-spain.cfg` copied to `<cfg dir>/iomoont.cfg` first —
the same way `dmd/es/` selects the country, a saved cfg rather than a live DIP sequence.

```bash
cp sleic-iomoon/scripts/keyscripts/iomoont-spain.cfg ~/.sdl3pinmame/cfg/iomoont.cfg

cd pinmame
SDL_VIDEODRIVER=dummy SDL_AUDIODRIVER=dummy ./build/sdl3pinmame iomoont \
  -rompath ./roms -nvram_directory /tmp/nv -nosound \
  -skip_disclaimer -skip_gameinfo -skip_gamewarnings -nothrottle -ftr 13700 \
  -dmd_dump_dir ../sleic-iomoon/dmd/es-menu \
  -key_script ../sleic-iomoon/scripts/keyscripts/iomoon-es-menu.keys

cd ../sleic-iomoon
cp scripts/keyscripts/iomoon-es-menu.keys.marks dmd/es-menu/iomoont.marks
python3 scripts/dmd_dump_split.py dmd/es-menu/iomoont.txt \
        --out dmd/es-menu --marks dmd/es-menu/iomoont.marks \
        --rom ../pinmame/roms/iomoon/v1_3_01.bin
```

## What this does not settle

The walk reaches three root branches and a few records under each, not all 38. The
remaining Spanish records are reachable the same way — one entry, `back` rather than
TEST between branches — and the limit on what they will show is F21's bar and F20's
pre-rendered images, exactly as on the English side, not the country.
