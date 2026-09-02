#!/bin/sh
# rebuild_z80.sh -- reproduce the Z80 baseline from the seed entry points.
#
# Run from the repository root (sleic-iomoon/).  With --from-seed it first
# discards everything in entries_z80.txt below the hand-derived seed block
# (reset vector, RST 08 landing, IM 1 vector, NMI vector) and rediscovers it
# from scratch; without it the run is incremental over whatever
# entries_z80.txt already holds.  Either way it iterates three discovery
# channels, in **two phases**:
#
#   phase 1 (to a fixed point)
#     growz80.py add    direct CALL/JP/JR edges out of the dasmz80 listing
#     jumptabz80.py     the five `JP (HL)` dispatches -- one 256-entry indexed
#                       command table, two smaller indexed tables, and two
#                       state-machine RAM pointer variables
#
#   phase 2 (to a fixed point, phase-1 channels still running)
#     orphanz80.py      routines nothing reaches, sitting between two decoded
#                       regions (the weakest channel; see its docstring)
#
# The phases exist because orphanz80.py decides whether a gap is code or a
# table from the data cross-references of *already decoded* code, so running
# it before the control-flow channels have converged makes its answers
# depend on discovery order.  Concretely: the stray byte at 003B is a data
# constant read by the routine at 2D8C, and 2D8C is only reached through the
# 256-entry command table -- run early, orphanz80.py has not seen that
# reference yet and mistakes 003B for code.  Letting phase 1 finish first
# makes the result independent of the order entries were discovered in.
#
# Finally it writes iomoon_z80.cmd / iomoon_z80.lst and cross-verifies the
# result against unidasm (xverify.py --arch z80).
set -e
B=asm/baseline-2026-09
T=$B/tools

if [ "$1" = "--from-seed" ]; then
    python3 - "$B/entries_z80.txt" <<'EOF'
import sys
p = sys.argv[1]
# Read fully before opening for write: open(p, "w") truncates the file the
# moment it is evaluated, so doing both in one expression loses everything.
seed = open(p).read().split("\n# --- ")[0].rstrip() + "\n"
with open(p, "w") as fh:
    fh.write(seed)
EOF
    echo "entries_z80.txt trimmed back to the seed block"
fi

pass=0
for phase in 1 2; do
    [ $phase = 1 ] && scans="jumptabz80.py" || scans="jumptabz80.py orphanz80.py"
    while [ $pass -lt 40 ]; do
        pass=$((pass + 1))
        before=$(md5sum $B/entries_z80.txt | cut -d' ' -f1)

        python3 $T/growz80.py add "r$pass" > /dev/null
        python3 $T/growz80.py emit > /dev/null

        for scan in $scans; do
            out=$(python3 $T/$scan)
            if [ -n "$out" ]; then
                {
                    printf '\n# --- pass %d: %s\n' "$pass" "$scan"
                    printf '%s\n' "$out"
                } >> $B/entries_z80.txt
            fi
        done

        after=$(md5sum $B/entries_z80.txt | cut -d' ' -f1)
        [ "$before" = "$after" ] && break
    done
    echo "phase $phase converged (cumulative pass $pass)"
done

python3 $T/growz80.py emit
python3 $T/xverify.py --arch z80 \
    --regions $B/iomoon_z80.cmd \
    --lst $B/iomoon_z80.lst \
    --bin "roms/1.3 IPDB latest/V1 3_05.bin" \
    --base 0x0000
