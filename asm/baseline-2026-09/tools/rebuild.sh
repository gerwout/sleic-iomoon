#!/bin/sh
# rebuild.sh -- reproduce the whole baseline from the seed entry points.
#
# Run from the repository root (sleic-iomoon/).  With --from-seed it first
# discards everything in entries.txt below the hand-derived seed block
# (reset path, IVT vectors, main entry) and rediscovers it from scratch;
# without it the run is incremental over whatever entries.txt already holds.
# Either way it iterates these discovery channels to a joint fixed point:
#
#   grow.py add       direct CALL/JMP edges out of the dasmx86 listing
#   jumptab.py        "JMP CS:W[BX+disp]" handler tables
#   scanptr.py        far pointers pushed on the stack, the two animation
#                     dispatch variables [4000:10F6]/[10F8], and a routine
#                     prologue signature for what neither reaches
#
# then writes iomoon_80188.cmd / iomoon_80188.lst and cross-checks the
# result against capstone.
set -e
B=asm/baseline-2026-09
T=$B/tools

if [ "$1" = "--from-seed" ]; then
    python3 - "$B/entries.txt" <<'EOF'
import sys
p = sys.argv[1]
# Read fully before opening for write: open(p, "w") truncates the file the
# moment it is evaluated, so doing both in one expression loses everything.
seed = open(p).read().split("\n# --- ")[0].rstrip() + "\n"
with open(p, "w") as fh:
    fh.write(seed)
EOF
    echo "entries.txt trimmed back to the seed block"
fi

pass=0
while [ $pass -lt 25 ]; do
    pass=$((pass + 1))
    before=$(md5sum $B/entries.txt | cut -d' ' -f1)

    python3 $T/grow.py add "r$pass" > /dev/null
    python3 $T/grow.py emit > /dev/null

    for scan in "jumptab.py" "scanptr.py pushptr" "scanptr.py dispatch" \
                "scanptr.py prologue"; do
        # shellcheck disable=SC2086
        out=$(python3 $T/$scan)
        if [ -n "$out" ]; then
            {
                printf '\n# --- pass %d: %s\n' "$pass" "$scan"
                printf '%s\n' "$out"
            } >> $B/entries.txt
        fi
    done

    after=$(md5sum $B/entries.txt | cut -d' ' -f1)
    [ "$before" = "$after" ] && break
done

echo "converged after $pass passes"
python3 $T/grow.py emit
python3 $T/crosscheck.py
