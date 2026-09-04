#!/usr/bin/env python3
"""strptr.py -- find the DMD text strings that scanptr.py's pushptr channel
mistakes for code entry points.

Bike Race draws text with a four-argument far call:

    PUSH  <seg>          far pointer to the string ...
    PUSH  <off>          ... in two pushes
    PUSH  <position>     DMD position
    PUSH  <attr>         attribute / mode
    CALL  <text drawer>  F000:06C5 in the parent set, F000:0682 in V4.1
    ADD   SP, 8

The far pointer is data.  grow.py's pushptr scan cannot tell that apart from
a far pointer pushed for an indirect call, so it seeds each string as a code
entry point; the strings then decode as garbage and the cross-verifier
flags them.  This script recovers the real list from the listing so the
strings can be excluded from entries.txt and classified as data instead.

    python3 strptr.py            # print the string addresses, one per line
    python3 strptr.py --drop     # rewrite entries.txt without them
"""
import os, re, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import grow

CALLF = re.compile(r"^\s{4}([0-9A-F]+):\s{4}(?:[0-9A-F]{2} )+\s*CALL\s+0([0-9A-F]{4}):0([0-9A-F]{4})")
PUSH_IMM = re.compile(r"^\s{4}([0-9A-F]+):\s{4}(?:[0-9A-F]{2} )+\s*PUSH\s+([0-9A-F]+)\s*$")

def scan(lines):
    """Yield (call_target, ptr_linear, push_site) for every four-push far call
    whose first two pushes form an adjacent far pointer."""
    pushes = []
    for line in lines:
        m = PUSH_IMM.match(line)
        if m:
            pushes.append((int(m.group(1), 16), int(m.group(2), 16)))
            if len(pushes) > 4:
                pushes.pop(0)
            continue
        m = CALLF.match(line)
        if m and len(pushes) == 4:
            (a_seg, seg), (a_off, off), _, _ = pushes
            if a_off == a_seg + 3:                    # the two halves are adjacent
                tgt = (int(m.group(2), 16) << 4) + int(m.group(3), 16)
                yield tgt, (seg << 4) + off, a_seg
        pushes = []


def find():
    """The text drawer is not at the same address in the two ROMs (F000:06C5
    in the parent, F000:0682 in V4.1), so identify it by shape instead: it is
    the four-push far-call target used far more often than any other."""
    lines = open(grow.LST).read().splitlines()
    hits = list(scan(lines))
    if not hits:
        return {}
    counts = {}
    for tgt, _, _ in hits:
        counts[tgt] = counts.get(tgt, 0) + 1
    drawer = max(counts, key=counts.get)
    found = {}
    for tgt, lin, site in hits:
        if tgt == drawer and grow.CODE_LO <= lin < grow.CODE_HI:
            found.setdefault(lin, []).append(site)
    return found

def main():
    found = find()
    if "--drop" not in sys.argv:
        for lin, sites in sorted(found.items()):
            print("%05X  # DMD string, %d draw site(s), first %05X"
                  % (lin, len(sites), sites[0]))
        return
    keep, dropped = [], 0
    for raw in open(grow.ENTRIES):
        line = raw.split("#")[0].strip()
        if line:
            addr = int(line.split()[0], 16)
            if addr in found:
                dropped += 1
                continue
        keep.append(raw)
    open(grow.ENTRIES, "w").writelines(keep)
    print("dropped %d string pointers from %s" % (dropped, grow.ENTRIES))

main()
