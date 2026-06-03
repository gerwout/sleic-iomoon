#!/usr/bin/env python3
"""
dmd_logic_decode.py -- reconstruct IO Moon DMD frames + measure timing from a
Saleae logic-analyzer capture of the PIC->plasma-panel signals.

The capture (`logicanalyzer/iomoon_128x32.sal`) records the six DMD control
signals the IC23 PIC drives out to the 128x32 plasma display:

    ch0 DE      display enable  (active period / frame gate)
    ch1 RDATA   row-select serial data
    ch2 RCLK    row clock       (shifts RDATA -> selects the active row)
    ch3 COLLAT  column latch    (latches the 128-bit column shift reg to the row)
    ch4 DOTCLK  dot clock       (clocks SDATA into the column shift register)
    ch5 SDATA   column serial pixel data

Pipeline:
  1. Saleae's saved `.sal` is the proprietary *v2 compressed* format. Re-export it
     to the *documented v0 transition-time* binary first (see sal_export.py, or
     File > Export Data > Binary in Logic 2). That yields one file per channel:
     digital_0.bin .. digital_5.bin, each:
         char[8] "<SALEAE>"
         int32   version        (0)
         int32   type           (0 = digital)
         uint32  initial_state   (0/1 level before the first transition)
         double  begin_time, end_time
         uint64  num_transitions
         double  transition_times[num_transitions]   (seconds; level toggles each one)
  2. This script parses those, measures the signal periods (-> frame rate, row
     rate, dot clock), and reconstructs each scanned 128x32 sub-frame by walking
     the events in time order:
         DOTCLK active edge  -> sample SDATA, shift into the 128-bit column reg
         COLLAT active edge  -> latch the column reg into the current row
         RCLK   active edge  -> advance the row-select (shift RDATA in)
         DE / 32-row wrap    -> emit a finished 128x32 frame
  3. Frames are written as PGM (+ PNG if Pillow is present) and an ASCII preview.

Edge polarity and the RCLK/COLLAT ordering are config knobs (--cfg) because the
exact convention must be confirmed against a known ROM frame; `--selftest` proves
the shift/latch engine round-trips a synthetic frame for the default config.

Usage:
    python3 dmd_logic_decode.py --selftest
    python3 dmd_logic_decode.py --indir <dir-with-digital_N.bin> --out frames/
"""
import argparse, struct, os, sys

W, H = 128, 32                      # DMD geometry
CH = {'DE':0,'RDATA':1,'RCLK':2,'COLLAT':3,'DOTCLK':4,'SDATA':5}


# ---------------------------------------------------------------- binary parse
def load_v0(path):
    """Parse one documented-v0 Saleae digital export file -> (init, t0, t1, times[])."""
    d = open(path, 'rb').read()
    if d[:8] != b'<SALEAE>':
        raise ValueError(f'{path}: not a <SALEAE> export (got {d[:8]!r}). '
                         'Re-export from Logic 2 as Binary -- the saved .sal is the '
                         'undocumented v2 format this script cannot read directly.')
    ver, typ = struct.unpack_from('<ii', d, 8)
    if ver != 0:
        raise ValueError(f'{path}: version {ver}, expected 0 (use the Binary *export*, '
                         'not the raw .sal). See module docstring.')
    init, = struct.unpack_from('<I', d, 16)
    t0, t1 = struct.unpack_from('<dd', d, 20)
    n, = struct.unpack_from('<Q', d, 36)
    times = struct.unpack_from('<%dd' % n, d, 44)
    return init, t0, t1, times


def to_edges(init, times):
    """Transition times -> list of (time, new_level). Level toggles each transition."""
    lvl = init
    out = []
    for t in times:
        lvl ^= 1
        out.append((t, lvl))
    return out


# ---------------------------------------------------------------- timing
def measure(name, init, t0, t1, times):
    dur = t1 - t0
    n = len(times)
    if n < 4:
        return f'{name:7s}: {n} transitions over {dur:.4f}s (idle/near-constant)'
    # period between successive rising edges (every other transition starting from a rise)
    # find first rising edge index
    lvl = init
    rises = []
    for t in times:
        lvl ^= 1
        if lvl == 1:
            rises.append(t)
    if len(rises) >= 3:
        periods = [rises[i+1]-rises[i] for i in range(len(rises)-1)]
        periods.sort()
        med = periods[len(periods)//2]
        freq = 1.0/med if med > 0 else 0
        return (f'{name:7s}: {n:>9d} transitions, {len(rises):>8d} pulses, '
                f'median period {med*1e6:8.2f} us  => {freq:10.1f} Hz')
    return f'{name:7s}: {n} transitions over {dur:.4f}s'


# ---------------------------------------------------------------- reconstruct
def reconstruct(chan, cfg, max_frames=None):
    """chan: dict name->(init,t0,t1,times). Returns list of 32x128 sub-frames (0/1)."""
    # merge all relevant channels into one time-ordered event stream
    streams = {}
    levels = {}
    for nm in ('DE','RDATA','RCLK','COLLAT','DOTCLK','SDATA'):
        init,_,_,times = chan[nm]
        streams[nm] = to_edges(init, times)
        levels[nm] = init
    events = []
    for nm, ed in streams.items():
        for (t, lvl) in ed:
            events.append((t, nm, lvl))
    events.sort(key=lambda e: e[0])

    dot_edge   = cfg['dotclk_edge']     # 1 = rising
    coll_edge  = cfg['collat_edge']
    rclk_edge  = cfg['rclk_edge']
    de_edge    = cfg['de_edge']
    msb_first  = cfg['msb_first']
    invert     = cfg['invert']

    frames = []
    col = []                # bits shifted in this row
    frame = [[0]*W for _ in range(H)]
    row = 0
    cur = dict(levels)

    def emit():
        nonlocal frame, row
        if any(any(r) for r in frame):
            frames.append([r[:] for r in frame])
        frame = [[0]*W for _ in range(H)]
        row = 0

    for (t, nm, lvl) in events:
        prev = cur[nm]; cur[nm] = lvl
        rose = (prev == 0 and lvl == 1)
        fell = (prev == 1 and lvl == 0)
        edge = rose if 1 else fell
        def act(want): return rose if want == 1 else fell
        if nm == 'DOTCLK' and act(dot_edge):
            b = cur['SDATA'] ^ (1 if invert else 0)
            col.append(b)
        elif nm == 'COLLAT' and act(coll_edge):
            bits = col[-W:] if len(col) >= W else col + [0]*(W-len(col))
            if not msb_first:
                bits = bits[::-1]
            if 0 <= row < H:
                frame[row] = bits[:W]
            col = []
        elif nm == 'RCLK' and act(rclk_edge):
            row += 1
            if row >= H:
                emit()
        elif nm == 'DE' and act(de_edge):
            if row > 0:
                emit()
        if max_frames and len(frames) >= max_frames:
            break
    return frames


# ---------------------------------------------------------------- output
def ascii_frame(fr):
    return '\n'.join(''.join('#' if px else ' ' for px in r) for r in fr)

def write_pgm(fr, path):
    with open(path, 'wb') as f:
        f.write(b'P5\n%d %d\n255\n' % (W, H))
        f.write(bytes(255 if px else 0 for r in fr for px in r))

def write_png(frames, outdir):
    try:
        from PIL import Image
    except Exception:
        return False
    for i, fr in enumerate(frames):
        im = Image.new('L', (W, H))
        im.putdata([255 if px else 0 for r in fr for px in r])
        im.resize((W*4, H*4)).save(os.path.join(outdir, f'frame_{i:04d}.png'))
    return True


# ---------------------------------------------------------------- self test
def selftest():
    """Synthesize transitions for a known frame and verify round-trip with default cfg."""
    import random
    random.seed(1)
    target = [[random.randint(0,1) for _ in range(W)] for _ in range(H)]
    # build event streams. Convention: per row -> 128 DOTCLK rising edges (sample SDATA),
    # then a COLLAT rising edge (latch), then an RCLK rising edge (advance row).
    t = 0.0; dt = 1e-6
    sig = {nm: [] for nm in CH}          # transition time lists
    lvl = {nm: 0 for nm in CH}
    def toggle(nm, when):
        sig[nm].append(when); lvl[nm] ^= 1
    def set_level(nm, want, when):
        if lvl[nm] != want: toggle(nm, when)
    for r in range(H):
        for c in range(W):
            set_level('SDATA', target[r][c], t); t += dt          # data valid
            set_level('DOTCLK', 1, t); t += dt                    # rising edge -> sample
            set_level('DOTCLK', 0, t); t += dt
        set_level('COLLAT', 1, t); t += dt                        # latch row
        set_level('COLLAT', 0, t); t += dt
        set_level('RCLK', 1, t); t += dt                          # advance row
        set_level('RCLK', 0, t); t += dt
    toggle('DE', t)                                               # frame boundary
    chan = {nm: (0, 0.0, t, tuple(sig[nm])) for nm in CH}
    cfg = default_cfg()
    frames = reconstruct(chan, cfg, max_frames=4)
    ok = frames and frames[0] == target
    print('SELFTEST:', 'PASS' if ok else 'FAIL',
          f'(reconstructed {len(frames)} frame(s); first matches target: {ok})')
    return 0 if ok else 1


def default_cfg():
    return dict(dotclk_edge=1, collat_edge=1, rclk_edge=1, de_edge=1,
                msb_first=True, invert=False)


def main():
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument('--selftest', action='store_true', help='validate the engine, no data needed')
    ap.add_argument('--indir', help='dir with documented-v0 digital_N.bin export files')
    ap.add_argument('--out', default='dmd_frames', help='output dir for frames')
    ap.add_argument('--max', type=int, default=200, help='max frames to emit')
    ap.add_argument('--cfg', default='', help='override e.g. invert=1,msb_first=0,rclk_edge=0')
    args = ap.parse_args()

    if args.selftest:
        sys.exit(selftest())

    if not args.indir:
        ap.error('give --indir (a Binary *export* dir) or --selftest. '
                 'The raw .sal is the v2 format; re-export to Binary first (see sal_export.py).')

    cfg = default_cfg()
    for kv in filter(None, args.cfg.split(',')):
        k, v = kv.split('='); cfg[k] = (v in ('1','true','True')) if k in ('msb_first','invert') else int(v)

    chan = {}
    for nm, idx in CH.items():
        p = os.path.join(args.indir, f'digital_{idx}.bin')
        if not os.path.exists(p):
            p = os.path.join(args.indir, f'digital-{idx}.bin')
        chan[nm] = load_v0(p)

    print('=== signal timing ===')
    for nm in ('DE','RCLK','COLLAT','DOTCLK','SDATA','RDATA'):
        print(measure(nm, *chan[nm]))
    de_init, de_t0, de_t1, de_times = chan['DE']
    print(f'\ncapture duration: {de_t1-de_t0:.3f} s')

    os.makedirs(args.out, exist_ok=True)
    frames = reconstruct(chan, cfg, max_frames=args.max)
    print(f'\nreconstructed {len(frames)} frames -> {args.out}/')
    for i, fr in enumerate(frames):
        write_pgm(fr, os.path.join(args.out, f'frame_{i:04d}.pgm'))
    if write_png(frames, args.out):
        print('  (PNGs written via Pillow)')
    if frames:
        print('\n--- first frame preview ---')
        print(ascii_frame(frames[0]))


if __name__ == '__main__':
    main()
