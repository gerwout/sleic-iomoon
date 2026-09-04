#!/bin/sh
# rebuild.sh -- grow one Bike Race 80188 code ROM to a fixed point, then
# cross-verify it.  Run from the repository root (sleic-iomoon/).
#
#     BK_SET=parent sh asm/bikerace-2026-09/tools/rebuild.sh
#     BK_SET=v41    sh asm/bikerace-2026-09/tools/rebuild.sh
#
# Discovery channels, iterated to a joint fixed point, exactly as the IO Moon
# baseline does:
#   grow.py add   direct CALL/JMP edges out of the dasmx86 listing
#   jumptab.py    "JMP CS:W[BX+disp]" handler tables
#   scanptr.py    far pointers pushed on the stack, and a routine-prologue
#                 signature for whatever neither of those reaches
#
# pushptr cannot tell a far pointer-to-text from a far pointer-to-routine, so
# after each convergence the two data channels below re-classify what it got
# wrong, into notcode.txt, and the loop is run again until that file settles:
#
#   strptr.py     far pointers consumed by the four-argument text drawer
#   glyphblk.py   entries sitting inside an all-glyph (<= 0x2F) text block
set -e
: "${BK_SET:=v41}"
export BK_SET
B=asm/bikerace-2026-09/$BK_SET
T=asm/bikerace-2026-09/tools

outer=0
while [ $outer -lt 5 ]; do
    outer=$((outer + 1))
    nc_before=$(md5sum $B/notcode.txt 2>/dev/null | cut -d' ' -f1)

pass=0
while [ $pass -lt 25 ]; do
    pass=$((pass + 1))
    before=$(md5sum $B/entries.txt | cut -d' ' -f1)

    python3 $T/grow.py add "r$pass" > /dev/null
    # grow.py appends unconditionally, so an address already known is re-added
    # under the new pass name.  Left alone that changes the file on every pass
    # and the md5 fixed-point test below can never fire.  Keep the first mention
    # of each address; it carries the evidence comment from when it was found.
    python3 $T/dedupe.py $B/entries.txt $B/notcode.txt
    python3 $T/grow.py emit > /dev/null

    for scan in "jumptab.py" "scanptr.py pushptr" "scanptr.py prologue"; do
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

    python3 $T/strptr.py   >> $B/notcode.txt
    python3 $T/glyphblk.py --notcode >> $B/notcode.txt
    sort -u -k1,1 -o $B/notcode.txt $B/notcode.txt
    nc_after=$(md5sum $B/notcode.txt | cut -d' ' -f1)
    echo "  outer pass $outer: inner converged after $pass, notcode has $(grep -c . $B/notcode.txt) entries"
    [ "$nc_before" = "$nc_after" ] && break
done

echo "BK_SET=$BK_SET converged"
python3 $T/grow.py emit
