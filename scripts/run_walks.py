#!/usr/bin/env python3
"""Run a machine's DMD walks from a manifest: capture, split, report.

The manifest (walks/<machine>.json) records what each walk needs -- ROM set, key
script, frame budget, NVRAM handling, a saved cfg for a DIP, whether it needs a
probe build -- so a walk is reproduced by name instead of by copying a command out
of a README.

  python3 scripts/run_walks.py iomoon --list
  python3 scripts/run_walks.py iomoon --only full-run
  python3 scripts/run_walks.py iomoon --only multiball-end --check
  python3 scripts/run_walks.py iomoon --only full-run --in-place

By default output goes to a scratch directory and the committed corpus is left
alone; --in-place writes into it.

NVRAM handling is the thing most likely to cost a capture. `seed` runs the walk
twice against one store and keeps the second, because a machine that has not
written its store yet spends the first boot seeding defaults -- on Io Moon that is
SETTING DEFAULT VALUES, on WPC it is FACTORY SETTINGS RESTORED, and either way the
walk captures a static screen and nothing else.
"""
import argparse, json, os, shutil, subprocess, sys, time

HERE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))   # repo root
def _find_pinmame():
    """pinmame sits inside this directory in one layout and beside it in the other."""
    env = os.environ.get("PINMAME_DIR")
    if env:
        return env
    for c in (os.path.join(HERE, "pinmame"), os.path.join(os.path.dirname(HERE), "pinmame")):
        if os.path.isdir(c):
            return c
    return os.path.join(os.path.dirname(HERE), "pinmame")


PINMAME = _find_pinmame()


def log(msg, *a):
    try:
        print(msg % a if a else msg, flush=True)
    except BrokenPipeError:            # piping into head is not an error
        sys.exit(0)


def load(machine):
    path = os.path.join(HERE, "walks", "%s.json" % machine)
    if not os.path.exists(path):
        sys.exit("no manifest at %s" % path)
    m = json.load(open(path))
    d = m.get("defaults", {})
    for w in m["walks"]:
        for k, v in d.items():
            w.setdefault(k, v)
    return m


def binary(args):
    b = args.probe_binary or os.path.join(PINMAME, "build", "sdl3pinmame")
    if not os.path.exists(b):
        sys.exit("no binary at %s -- build it first" % b)
    return b


def capture(walk, args, outdir):
    """Run the walk once. Returns the dump path, or None."""
    keys = os.path.join(HERE, walk["keyscript_dir"], walk["keys"])
    if not os.path.exists(keys):
        log("    ! key script missing: %s", keys)
        return None
    nvdir = os.path.join(args.scratch, "nv-%s" % walk["name"])
    dumpdir = os.path.join(outdir, "raw")
    os.makedirs(nvdir, exist_ok=True)
    os.makedirs(dumpdir, exist_ok=True)

    if walk.get("nvram") == "fresh":
        shutil.rmtree(nvdir, ignore_errors=True)
        os.makedirs(nvdir)

    # A saved cfg is the only way to set a DIP in this build.
    if walk.get("cfg"):
        cfgdir = os.path.expanduser(args.cfg_dir)
        os.makedirs(cfgdir, exist_ok=True)
        src = os.path.join(HERE, walk["keyscript_dir"], walk["cfg"])
        if not os.path.exists(src):
            log("    ! cfg missing: %s", src)
            return None
        shutil.copyfile(src, os.path.join(cfgdir, "%s.cfg" % walk["set"]))
        log("    cfg  %s -> %s/%s.cfg", walk["cfg"], cfgdir, walk["set"])

    runs = 2 if walk.get("nvram", "seed") == "seed" else 1
    env = dict(os.environ, SDL_VIDEODRIVER="dummy", SDL_AUDIODRIVER="dummy")
    dump = os.path.join(dumpdir, "%s.txt" % walk["set"])
    for i in range(1, runs + 1):
        cmd = [binary(args), walk["set"],
               "-rompath", args.rompath, "-nvram_directory", nvdir,
               "-nosound", "-skip_disclaimer", "-skip_gameinfo",
               "-skip_gamewarnings", "-nothrottle",
               "-ftr", str(walk["frames"]),
               "-dmd_dump_dir", dumpdir, "-key_script", keys]
        if args.dry_run:
            log("    would run: %s", " ".join(cmd))
            return None
        if os.path.exists(dump):
            os.remove(dump)                      # keep only the run we keep
        t = time.time()
        r = subprocess.run(cmd, capture_output=True, text=True, env=env,
                           timeout=args.timeout)
        n = frames(dump)
        tag = "seed" if (runs == 2 and i == 1) else "keep"
        log("    run %d/%d (%s)  %5.1fs  %d frames", i, runs, tag, time.time() - t, n)
        if r.returncode != 0 and n == 0:
            log("    ! pinmame exited %d", r.returncode)
            sys.stderr.write((r.stdout or "")[-400:] + (r.stderr or "")[-400:])
            return None
    return dump


def frames(dump):
    if not os.path.exists(dump):
        return 0
    with open(dump) as fh:
        return sum(1 for ln in fh if ln.startswith("0x"))


def split(walk, args, dump, outdir):
    keys = os.path.join(HERE, walk["keyscript_dir"], walk["keys"])
    marks_src = keys + ".marks"
    marks = os.path.join(os.path.dirname(dump), "%s.marks" % walk["set"])
    if os.path.exists(marks_src):
        shutil.copyfile(marks_src, marks)
    splitter = next((os.path.join(HERE, d, "dmd_dump_split.py")
                     for d in ("tools", "scripts")
                     if os.path.exists(os.path.join(HERE, d, "dmd_dump_split.py"))), None)
    if not splitter:
        log("    ! dmd_dump_split.py not found in tools/ or scripts/")
        return "no splitter"
    cmd = [sys.executable, splitter,
           dump, "--out", outdir]
    if os.path.exists(marks):
        cmd += ["--marks", marks]
    rom = os.path.join(PINMAME, walk.get("split_rom", ""))
    if walk.get("split_rom") and os.path.exists(rom):
        cmd += ["--rom", rom]
    r = subprocess.run(cmd, capture_output=True, text=True)
    out = (r.stdout + r.stderr).strip().splitlines()
    summary = out[-1] if out else "(no output)"
    log("    split: %s", summary)
    return summary


def check(walk, outdir):
    """Compare a fresh split against the committed corpus, if there is one."""
    ref = os.path.join(HERE, walk["corpus_dir"], walk["out"], "screens.csv")
    new = os.path.join(outdir, "screens.csv")
    if not os.path.exists(ref):
        log("    check: no committed corpus to compare against")
        return None
    a = sum(1 for _ in open(ref)) - 1
    b = sum(1 for _ in open(new)) - 1
    verdict = "MATCH" if a == b else "DIFFERS"
    log("    check: committed %d scenes, this run %d -> %s", a, b, verdict)
    return verdict


def main():
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("machine")
    ap.add_argument("--list", action="store_true")
    ap.add_argument("--only", help="comma-separated walk names")
    ap.add_argument("--skip", help="comma-separated walk names to skip")
    ap.add_argument("--in-place", action="store_true",
                    help="write into the committed corpus instead of scratch")
    ap.add_argument("--check", action="store_true",
                    help="compare the split against the committed corpus")
    ap.add_argument("--dry-run", action="store_true")
    ap.add_argument("--rompath", default=os.path.join(PINMAME, "roms"))
    ap.add_argument("--scratch", default="/tmp/walks")
    ap.add_argument("--cfg-dir", default="~/.sdl3pinmame/cfg")
    ap.add_argument("--probe-binary", help="a -DDEBUG_SLEIC build, for probe walks")
    ap.add_argument("--timeout", type=int, default=3600)
    a = ap.parse_args()

    m = load(a.machine)
    walks = m["walks"]
    if a.only:
        want = [s.strip() for s in a.only.split(",")]
        walks = [w for w in walks if w["name"] in want]
        missing = set(want) - {w["name"] for w in walks}
        if missing:
            sys.exit("no such walk(s): %s" % ", ".join(sorted(missing)))
    if a.skip:
        no = {s.strip() for s in a.skip.split(",")}
        walks = [w for w in walks if w["name"] not in no]

    if a.list:
        log("%-17s %-9s %-8s %7s  %s", "walk", "set", "nvram", "frames", "needs")
        for w in m["walks"]:
            needs = " ".join(filter(None, [
                "cfg:" + w["cfg"] if w.get("cfg") else "",
                "PROBE" if w.get("probe") else ""]))
            log("%-17s %-9s %-8s %7d  %s", w["name"], w["set"],
                w.get("nvram", "seed"), w["frames"], needs)
        return

    os.makedirs(a.scratch, exist_ok=True)
    results = []
    for w in walks:
        log("\n== %s  (%s, %d frames)", w["name"], w["set"], w["frames"])
        if w.get("desc"):
            log("   %s", w["desc"])
        if w.get("probe") and not a.probe_binary:
            log("    SKIPPED -- needs a -DDEBUG_SLEIC build; pass --probe-binary")
            results.append((w["name"], "skipped (probe)"))
            continue
        outdir = (os.path.join(HERE, w["corpus_dir"], w["out"]) if a.in_place
                  else os.path.join(a.scratch, w["name"]))
        os.makedirs(outdir, exist_ok=True)
        dump = capture(w, a, outdir)
        if not dump:
            results.append((w["name"], "no capture"))
            continue
        n = frames(dump)
        if n == 0:
            log("    ! no frames captured -- does this machine have a DMD, and did"
                " the store need seeding?")
            results.append((w["name"], "0 frames"))
            continue
        summary = split(w, a, dump, outdir)
        if a.check:
            check(w, outdir)
        results.append((w["name"], summary))

    log("\n%s", "=" * 62)
    for name, res in results:
        log("%-18s %s", name, res)


if __name__ == "__main__":
    main()
