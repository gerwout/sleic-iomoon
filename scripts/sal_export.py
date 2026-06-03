#!/usr/bin/env python3
"""
sal_export.py -- re-export a Saleae `.sal` capture to the documented v0 binary
format that `dmd_logic_decode.py` can read.

The saved `.sal` is Saleae's proprietary *v2 compressed* format (not parseable
standalone). The Logic 2 automation API re-exports it to the documented
transition-time binary (one `digital_N.bin` per channel), which is stable and
parseable.

REQUIREMENTS:
  * Logic 2 must be RUNNING with the automation server enabled
    (Logic 2 > Preferences > Automation > "Enable automation server", port 10430),
    reachable from this machine (run Logic 2 here, or SSH-forward 10430).
  * pip install logic2-automation   (already installed in this env)

USAGE:
    python3 sal_export.py --sal ../logicanalyzer/iomoon_128x32.sal --out ./export
then:
    python3 dmd_logic_decode.py --indir ./export --out ./frames

If you'd rather not use the automation server, do the same export from the GUI:
    File > Export Data > select all 6 digital channels > format "Binary" > export
which produces the same digital_N.bin files.
"""
import argparse, os, sys


def main():
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument('--sal', required=True, help='absolute or relative path to the .sal file')
    ap.add_argument('--out', required=True, help='output directory for digital_N.bin')
    ap.add_argument('--port', type=int, default=10430)
    ap.add_argument('--channels', default='0,1,2,3,4,5', help='digital channels to export')
    args = ap.parse_args()

    sal = os.path.abspath(args.sal)
    out = os.path.abspath(args.out)
    chans = [int(c) for c in args.channels.split(',')]
    os.makedirs(out, exist_ok=True)

    try:
        from saleae import automation
    except ImportError:
        sys.exit('logic2-automation not installed: pip install --break-system-packages logic2-automation')

    try:
        manager = automation.Manager.connect(port=args.port, connect_timeout_seconds=10)
    except Exception as e:
        sys.exit(f'Could not connect to Logic 2 on port {args.port}: {e}\n'
                 'Start Logic 2 and enable the automation server (Preferences > Automation), '
                 'or do the export from the GUI (File > Export Data > Binary).')

    print(f'connected to Logic 2; loading {sal}')
    capture = manager.load_capture(sal)
    print(f'exporting digital channels {chans} -> {out}')
    capture.export_raw_data_binary(directory_path=out, digital_channels=chans)
    capture.close()
    manager.close()
    print('done. Files:')
    for f in sorted(os.listdir(out)):
        print('  ', f, os.path.getsize(os.path.join(out, f)), 'bytes')
    print('\nnext: python3 dmd_logic_decode.py --indir', out, '--out ./frames')


if __name__ == '__main__':
    main()
