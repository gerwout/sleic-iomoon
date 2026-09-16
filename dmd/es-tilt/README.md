# The Spanish tilt warnings

[← Back to the DMD corpus overview](../README.md)

`ATENCION / UNA FALTA` and `ATENCION / DOS FALTAS` — the Spanish counterparts of
`dmd/faults/tilt`'s `WARNING / ONE TILT` and `WARNING / TWO TILTS`. **152 distinct
screens**, and three tier-3 Spanish strings move from missing to present.

## No probe, but the store has to be prepared

`sub_D9EBB`, the tilt contact's handler (F5 code `0x3E`), tests the per-ball warning
budget `[4134:0033]`, reloaded at each ball start from NVRAM `0x42` minus one (F10). The
factory default `0x42 = 1` gives a **zero** budget, so the first tilt goes straight to a
full tilt and neither warning is ever drawn. The byte has to read 3 before the run.

**And the store has to be one the firmware has actually written.** Patching a brand-new
`.nv` does nothing: it is all zero, the firmware's signature check fails and it rewrites
the factory value. What works is boot once *far enough to bank a credit* — that is what
writes the store — then patch `0x42` and run without wiping the directory.
`scripts/nvcheck.py` shows the difference plainly: `*** EMPTY ***` against
`448 / 8192 bytes non-zero`.

The two warnings also need **room between them**. At roughly 700 frames apart only the
first is drawn; at 1500 apart both are. The three tilt presses here are at 7910, 9410 and
10910, the third going to the full tilt.

## Capture

Country 5 comes from `scripts/keyscripts/iomoont-spain.cfg` copied to
`<cfg dir>/iomoont.cfg`. Six coins buy the credit.

```bash
cd pinmame
# 1. boot once against a fresh directory, far enough to bank a credit
# 2. python3 -c "d=bytearray(open(P,'rb').read()); d[0x42]=3; open(P,'wb').write(bytes(d))"
# 3. then, without wiping that directory:
SDL_VIDEODRIVER=dummy SDL_AUDIODRIVER=dummy ./build/sdl3pinmame iomoont \
  -rompath ./roms -nvram_directory /tmp/nv -nosound \
  -skip_disclaimer -skip_gameinfo -skip_gamewarnings -nothrottle -ftr 12500 \
  -dmd_dump_dir ../sleic-iomoon/dmd/es-tilt \
  -key_script ../sleic-iomoon/scripts/keyscripts/iomoon-es-tilt.keys
```

Run against the shipping `build/sdl3pinmame` with no probe compiled in.

## The rest of the Spanish fault set

Four of its strings are already captured elsewhere, by
[`solenoid-test/`](../solenoid-test/README.md): `EN CORTO`, `IMPOSIBLE SEGUIR`,
`CORTADOS O` and `SEPARADO O ROTO`. What is still missing needs the per-fault probes
`dmd/faults/README.md` documents, re-run under this cfg: `FALLO EEPROM`,
`FALLO MEM. CPU8`, `ERROR SAL. BOLAS`, `FALTAN BOLAS` and `FALLO BOBINA` (the last being
the Spanish `SOLENOID FAIL`, which shares that string's own row-0 clipping problem).

`ESPERANDO`, `CPU 8 BITS`, `ESTABLECIENDO`, `VALORES FABRICA` and `PULSE START` are a
different case and may not be reachable in Spanish at all: those screens are drawn before
the country is applied, and this capture shows them in **English** even under the Spanish
cfg.
