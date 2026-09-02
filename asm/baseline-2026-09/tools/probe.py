#!/usr/bin/env python3
"""probe.py -- run dasmx86 over a single linear window of the IO Moon ROM1 image.

Ad-hoc helper used while building the baseline command file: it writes a
throw-away dasmxx command list for one [start, start+len) window and runs
dasmx86 on it, so a candidate entry point can be inspected without touching
the real command file.

    python3 probe.py <linear-start-hex> <length-hex> [<segment-hex>]

Addresses are FLAT/LINEAR 80188 addresses.  ROM1 occupies 0x80000-0xFFFFF,
so file offset = linear - 0x80000.  The optional third argument is the x86
segment register value in force for that code (e.g. D2F2); it is passed to
dasmx86 as a 'g' command so that intra-segment near branches resolve to the
right flat address.  It defaults to (linear >> 4) & 0xF000, i.e. the
64K-aligned segment containing the window.
"""
import os
import subprocess
import sys
import tempfile

ROM = os.environ.get(
    "IOMOON_ROM1",
    os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", "..",
                 "roms", "1.3 IPDB latest", "V1 3_01.bin"))
ROM = os.path.abspath(ROM)
DASM = os.path.expanduser("~/iomoon/tools/dasmxx/src/dasmx86")
ROM1_BASE = 0x80000


def run(start, length, seg, extra=()):
    with tempfile.NamedTemporaryFile("w", suffix=".dx86", delete=False) as fh:
        fh.write("f%s\n" % ROM)
        fh.write(">%X\n" % (start - ROM1_BASE))
        fh.write("g%X\n" % (seg << 4))
        for line in extra:
            fh.write(line + "\n")
        fh.write("c%X\n" % start)
        fh.write("e%X\n" % (start + length))
        name = fh.name
    try:
        return subprocess.run([DASM, name], check=False)
    finally:
        os.unlink(name)


def main():
    start = int(sys.argv[1], 16)
    length = int(sys.argv[2], 16)
    seg = int(sys.argv[3], 16) if len(sys.argv) > 3 else (start >> 4) & 0xF000
    run(start, length, seg)


if __name__ == "__main__":
    main()
