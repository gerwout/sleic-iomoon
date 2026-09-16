# The Spanish menu tree, walked whole

[← Back to the DMD corpus overview](../README.md)

[`es-menu/`](../es-menu/README.md) showed the Spanish service menu is capturable at all —
F19's country re-derivation is on the **exit** path, so a walk that opens the menu once
and navigates with select, scroll and *back* keeps its country. That walk covered three
branches; this one covers the tree, the same way. **51 distinct screens**, and the store
still reads **country 5** at the end.

## The result is a negative, and it is worth having

Beyond the root and its first child — `SONIDO/VIDEO / JUEGO / TECNICO` and
`VOLUMEN / PUBLICIDAD`, already in `es-menu/` — **every deeper record draws F21's
procedural depth bar**, the growing `AA`, `AAA`, `AAAA` run, and no item text:

```
branch-1-item-2,AA
branch-1-item-3,AAA
...
branch-1-item-12,AAAAAAAAAAA8A
```

That is exactly what the **English** walk shows at the same depth (`dmd/en/`, and
`docs/iomoon_dmd_screens.md`'s own Coverage section). So the 164 menu strings the
coverage gate still misses are **not language-gated** and not a Spanish capture gap:
they are F21's bar and F20's pre-rendered images, in both languages equally. The gate
does not move, and that is the finding rather than a shortfall.

F21 also explains the growth: the bar's column count `4000:1149` is incremented by every
**scroll** and decremented by every **back**, and is never reset per record, so a walk
that descends by scrolling makes it longer as it goes.

## The walk

Mechanical rather than tree-shaped, because it does not need to know the shape: for each
of the root's items, enter it, step through its own items in turn — select, dwell, back —
and back out to the root before the next. A record that does not exist under a given
parent simply redraws the parent, which costs a scene and nothing else.

TEST is pressed exactly once, to open. That is the whole point: pressing it again would
exit, and exiting is what F19 punishes.

## Capture

Requires `scripts/keyscripts/iomoont-spain.cfg` copied to `<cfg dir>/iomoont.cfg` first.

```bash
cd pinmame
SDL_VIDEODRIVER=dummy SDL_AUDIODRIVER=dummy ./build/sdl3pinmame iomoont \
  -rompath ./roms -nvram_directory /tmp/nv -nosound \
  -skip_disclaimer -skip_gameinfo -skip_gamewarnings -nothrottle -ftr 39000 \
  -dmd_dump_dir ../sleic-iomoon/dmd/es-menu-full \
  -key_script ../sleic-iomoon/scripts/keyscripts/iomoon-es-menu-full.keys
```

Run against the shipping `build/sdl3pinmame` with no probe compiled in.
