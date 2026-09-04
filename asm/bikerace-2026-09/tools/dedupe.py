#!/usr/bin/env python3
"""dedupe.py -- keep entries.txt stable between growth passes.

Two things make the file churn, and either one stops rebuild.sh's md5
fixed-point test from ever firing:

  * grow.py's `add` appends every candidate it finds whether or not the address
    is already listed, tagging it with the pass name.  Keep the first mention of
    each address -- it carries the evidence comment from when it was found.

  * scanptr.py's pushptr channel re-emits the far pointers that notcode.txt has
    already ruled out as text rather than code, once per pass, forever.  grow.py
    filters them when it reads the file, so they change nothing except its
    checksum.  Drop them here instead.

    python3 dedupe.py <entries.txt> [notcode.txt]
"""
import os
import sys

path = sys.argv[1]
notcode_path = sys.argv[2] if len(sys.argv) > 2 else os.path.join(
    os.path.dirname(path), "notcode.txt")

excluded = set()
if os.path.exists(notcode_path):
    for raw in open(notcode_path):
        line = raw.split("#")[0].strip()
        if line:
            excluded.add(int(line.split()[0], 16))

seen, out = set(), []
for raw in open(path):
    key = raw.split("#")[0].strip().split()
    if key:
        addr = int(key[0], 16)
        if addr in seen or addr in excluded:
            continue
        seen.add(addr)
    out.append(raw)
open(path, "w").writelines(out)
