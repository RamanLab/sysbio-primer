"""Run every Python example (or those under the given paths).

Usage:  python tools/run_examples.py [examples/10-cbm ...]
Each example folder holds an example.yml and one <name>.py script.
"""
import os
import subprocess
import sys
import time
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def example_dirs(paths):
    roots = [Path(p) for p in paths] or [ROOT / "examples"]
    found = []
    for r in roots:
        found += [p.parent for p in sorted(Path(r).resolve().rglob("example.yml"))]
    return found


def main(paths):
    env = dict(os.environ, CI=os.environ.get("CI", "1"), MPLBACKEND="Agg")
    failures = []
    for d in example_dirs(paths):
        scripts = sorted(d.glob("*.py"))
        if len(scripts) != 1:
            failures.append(f"{d}: expected exactly one .py file")
            continue
        t0 = time.time()
        proc = subprocess.run([sys.executable, str(scripts[0])], env=env,
                              capture_output=True, text=True)
        status = "ok" if proc.returncode == 0 else "FAILED"
        print(f"[{status}] {scripts[0].relative_to(ROOT)} ({time.time() - t0:.1f} s)")
        if proc.returncode != 0:
            print(proc.stdout[-2000:], proc.stderr[-4000:], sep="\n")
            failures.append(str(scripts[0]))
    if failures:
        sys.exit(f"{len(failures)} example(s) failed")


if __name__ == "__main__":
    main(sys.argv[1:])
