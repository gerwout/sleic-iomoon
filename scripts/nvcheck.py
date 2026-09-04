#!/usr/bin/env python3
"""
nvcheck.py -- decode a PinMAME Io Moon NVRAM file against the documented
segment-5040 offsets (findings F10 and F11).

The driver backs the whole non-volatile window with one array
(`iomoon_nvram[]`, base `IOMOON_NVRAM_BASE` 0x50400, size 0x2000), which
PinMAME saves through `core_nvram()` (`src/wpc/core.c`).  That gives the
on-disk layout:

    0x0000-0x1FFF   the segment-5040 store        (offsets below are into this)
    0x2000-0x2027   mech positions                (mech_nv)
    0x2028-0x202D   the six saved DIP banks       (bank 0 = SW40)

so a file is 8238 bytes.  Offsets inside the store, from the findings:

    0x03C   balls per game
    0x042   tilt warnings
    0x043   short-ball replay threshold (dword)
    0x083   credits, triplicated at 0x083 / 0x116 / 0x20C
    0x084   sub-credit remainder, triplicated at 0x084 / 0x117 / 0x20D
    0x085   five 17-byte high-score records
    0x118   audits (dword), and 0x11C
    0x1BF   country byte
    0x1C4   pricing table, 12 bytes

The credits triple is the one to watch: the firmware majority-compares the
three copies and zeroes ALL of them on a mismatch, so two-out-of-three is a
loss, not a rounding error.

Usage:
    python3 scripts/nvcheck.py [path/to/iomoon.nv]

With no argument the usual PinMAME locations are tried.  A store that is
entirely zero means the firmware never wrote it -- which is normal for a
short run that only ever reached attract, and a real fault for one that
banked a credit.
"""

import os
import sys

DEFAULT_PATHS = [
    "~/.pinmame/nvram/iomoon.nv",    # sdl3pinmame
    "~/.xpinmame/nvram/iomoon.nv",   # older xpinmame builds
]

COUNTRIES = ["United Kingdom", "France (ROM coins = NL)", "Germany", "Italy",
             "Netherlands", "Spain", "Belgium", "Portugal"]

STORE_LEN = 0x2000
DIP_OFF = 0x28  # into the trailer


def find_default():
    for p in DEFAULT_PATHS:
        p = os.path.expanduser(p)
        if os.path.exists(p):
            return p
    return None


def country_name(c):
    return COUNTRIES[c] if 0 <= c < len(COUNTRIES) else "out of range"


def main():
    if len(sys.argv) > 1:
        path = os.path.expanduser(sys.argv[1])
    else:
        path = find_default()
        if path is None:
            sys.exit("no NVRAM file found in %s -- pass one as an argument"
                     % " or ".join(DEFAULT_PATHS))

    with open(path, "rb") as fh:
        data = fh.read()

    store, trailer = data[:STORE_LEN], data[STORE_LEN:]

    def u32(off):
        return int.from_bytes(store[off:off + 4], "little")

    def hexs(a, b):
        return " ".join("%02X" % x for x in store[a:b])

    print("file             %s (%d bytes)" % (path, len(data)))
    if len(store) < STORE_LEN:
        print("                 *** SHORT FILE: %d bytes of store, expected %d ***"
              % (len(store), STORE_LEN))
        return 1

    nonzero = sum(1 for b in store if b)
    print("store            %d / %d bytes non-zero" % (nonzero, STORE_LEN))
    if nonzero == 0:
        print("                 *** EMPTY -- the firmware never wrote the store ***")
    print()

    print("-- country and coinage (F11) --")
    country = store[0x1BF]
    print("0x1BF country    %d  (%s)" % (country, country_name(country)))
    print("0x1C4 pricing    %s" % hexs(0x1C4, 0x1D0))
    print()

    print("-- game settings (F10) --")
    print("0x03C balls/game %d" % store[0x3C])
    print("0x042 tilt warns %d" % store[0x42])
    print("0x043 replay thr %d" % u32(0x43))
    print()

    print("-- credits (triplicated; a mismatch zeroes all three) --")
    triple = [store[0x83], store[0x116], store[0x20C]]
    remain = [store[0x84], store[0x117], store[0x20D]]
    print("0x083/0x116/0x20C  %-12s %s"
          % (triple, "agree" if len(set(triple)) == 1 else "*** MISMATCH ***"))
    print("0x084/0x117/0x20D  %-12s %s"
          % (remain, "agree" if len(set(remain)) == 1 else "*** MISMATCH ***"))
    print()

    print("-- high scores: five 17-byte records from 0x085 --")
    for i in range(5):
        off = 0x85 + i * 17
        print("  rec%d @0x%03X  %s" % (i, off, hexs(off, off + 17)))
    print()

    print("-- audits --")
    print("0x118 %-10d 0x11C %d" % (u32(0x118), u32(0x11C)))
    print()

    print("-- saved DIP bank 0 (SW40) --")
    if len(trailer) > DIP_OFF:
        dip = trailer[DIP_OFF]
        print("0x2028 = 0x%02X    SW40-1 %s, country %d (%s), SW40-5 %s"
              % (dip,
                 "Off" if dip & 0x01 else "On",
                 (dip >> 1) & 7, country_name((dip >> 1) & 7),
                 "Off (normal play)" if dip & 0x10 else "On (service)"))
        if nonzero and (dip >> 1) & 7 != country:
            print("                 note: the DIP overrides the stored country on every")
            print("                 boot (D664D), so a difference here is transient")
    else:
        print("(trailer is %d bytes, shorter than expected)" % len(trailer))

    return 0


if __name__ == "__main__":
    sys.exit(main())
