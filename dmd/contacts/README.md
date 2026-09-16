# The contact names, on the machine's own switch test

[← Back to the DMD corpus overview](../README.md)

The CONTACTOS / SWITCH TEST page with contacts actually closing — the only place the
firmware's own contact names render. **Both languages, and the single biggest coverage
gain the corpus has had: 93 strings move from missing to present, taking the gate from
399 missing to 306.**

Each of the 44 fitted matrix positions gets its own mark and its own scene, so
`screens.csv` reads as a table of the machine's own names:

```
contact-c0b0,CON: C6 / OUTHOLE 1          contact-c0b0,CON: C6 / SALIDA BOLAS 1
contact-c0b3,CON: C9 / BALL OUT           contact-c0b3,CON: C9 / BOLA FUERA
contact-c0b6,CON: C11 / L.C.FLIPPER       contact-c0b6,CON: C11 / C. FLIPPER IZQ.
contact-c1b7,CON: C12 / LANE 1            contact-c1b7,CON: C12 / PASILLO 1
```

**C21 confirms F16 from the other side.** Column 1 bit 1 — code `0x13`, RAMP 1 EXIT — is
the one position in the walk that draws no name, which is what F16 says: the contact is
named in the firmware's table but its per-bit Z80 dispatcher is a bare `RET`, and §2.1.1
lists it unconnected. Every other fitted position names itself.

## Why no previous walk got these

Two obstacles, one of them not obvious.

The service menu needs **no credits**, so reaching the page is just TEST and eight
navigation presses — F14's tree puts record 32 (record 26's child) at scroll, scroll,
select, select, scroll, scroll, select, select.

The obstacle is that **inside the menu there is no ball in play**, and the simulator's
shot keys act on the current ball only while it is on the playfield, so they do nothing
there. `Del` toggles PinMAME's own "Switch/Simulator" bit (`SIM_PORTS`), which hands the
keyboard to the driver's matrix test keys instead (`iomoon_pf_keys`, `src/wpc/sleic.c`),
and those close a matrix position directly with no ball involved. That is what makes the
page testable at all.

The key-to-position map: column 0 is `QWERYUIO`, column 1 `ASDFGHJK`, column 2 `ZXCVBNML`,
column 3 the numeric keypad `0`-`7`, column 4 `0 2 3 4 6 8 - 9`, and column 5's four
fitted positions `=` and keypad `8 9 -`. Column 5's other four positions do not exist on
the machine (F16).

## Capture

`en/` runs at the country default (4, Netherlands, English); `es/` is the same script with
`scripts/keyscripts/iomoont-spain.cfg` copied to `<cfg dir>/iomoont.cfg` first, the same
way `dmd/es/` selects the country — `scripts/nvcheck.py` reads country 5 from the store it
writes.

```bash
cd pinmame
SDL_VIDEODRIVER=dummy SDL_AUDIODRIVER=dummy ./build/sdl3pinmame iomoont \
  -rompath ./roms -nvram_directory /tmp/nv -nosound \
  -skip_disclaimer -skip_gameinfo -skip_gamewarnings -nothrottle -ftr 9800 \
  -dmd_dump_dir ../sleic-iomoon/dmd/contacts/en \
  -key_script ../sleic-iomoon/scripts/keyscripts/iomoon-switchtest.keys

cd ../sleic-iomoon
cp scripts/keyscripts/iomoon-switchtest.keys.marks dmd/contacts/en/iomoont.marks
python3 scripts/dmd_dump_split.py dmd/contacts/en/iomoont.txt \
        --out dmd/contacts/en --marks dmd/contacts/en/iomoont.marks \
        --rom ../pinmame/roms/iomoon/v1_3_01.bin
```

Run against the shipping `build/sdl3pinmame` with no probe compiled in.

## Two cabinet inputs, and the four that cannot come this way

Cabinet inputs are not matrix positions, so the driver's matrix keys do not reach them —
but `CORE_PORTS`' own cabinet keys stay live through the `Del` toggle, and two of the six
do not navigate the menu. Both are captured here:

```
cabinet-coin,CON: C3 / COINS INPUT        cabinet-coin,CON: C3 / MONEDERO
cabinet-tilt,CON: C20 / PLUMB TILT        cabinet-tilt,CON: C20 / PENDULO DE FALTA
```

The other four — `TEST BUTTON`, `START BUTTON`, `L. FLIPPER`, `R. FLIPPER` and their
Spanish counterparts — **are** the menu's own navigation keys (F14: `0x3F` exit, `0x40`
back, `0x41` scroll, `0x42` select), so pressing one here moves the menu rather than
naming a contact. On the machine they render on this same page; reaching them in
emulation wants a probe that asserts the cabinet bits directly, the way `dmd/faults/`
does, rather than a key.
