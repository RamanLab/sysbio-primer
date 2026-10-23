"""Check every example's results.

For each example folder (one with an example.yml):
  * Python results must match the values under `expected:` (from the book).
  * MATLAB results, if present, must match `expected:` too.
  * MATLAB and Python results must agree on the keys listed under `compare:`.
Numbers are compared with the example's `tolerance:` (rtol/atol); JSON null
(NaN, e.g. an infeasible LP) only matches null.

Usage:  python tests/compare.py [--require-matlab] [examples/...]
"""
import json
import math
import sys
from pathlib import Path

import yaml

ROOT = Path(__file__).resolve().parents[1]


def mismatches(a, b, rtol, atol, path="$"):
    """List the places where a and b differ, recursively."""
    if isinstance(b, dict):
        if not isinstance(a, dict):
            return [f"{path}: expected a mapping"]
        out = []
        for k in b:
            if k not in a:
                out.append(f"{path}.{k}: missing")
            else:
                out += mismatches(a[k], b[k], rtol, atol, f"{path}.{k}")
        return out
    if isinstance(b, list):
        if not isinstance(a, list) or len(a) != len(b):
            return [f"{path}: expected a list of length {len(b)}"]
        out = []
        for i, (x, y) in enumerate(zip(a, b)):
            out += mismatches(x, y, rtol, atol, f"{path}[{i}]")
        return out
    if a is None or b is None:
        return [] if a is None and b is None else [f"{path}: {a} vs {b}"]
    if isinstance(b, (int, float)) and isinstance(a, (int, float)):
        ok = math.isclose(a, b, rel_tol=rtol, abs_tol=atol)
        return [] if ok else [f"{path}: {a!r} vs {b!r}"]
    return [] if a == b else [f"{path}: {a!r} vs {b!r}"]


def check(example, require_matlab):
    meta = yaml.safe_load((example / "example.yml").read_text())
    tol = meta.get("tolerance", {})
    rtol, atol = tol.get("rtol", 1e-6), tol.get("atol", 1e-9)
    name = example.relative_to(ROOT)
    problems = []

    results = {}
    for lang in ("python", "matlab"):
        f = example / "out" / lang / "results.json"
        if f.exists():
            results[lang] = json.loads(f.read_text())
    if "python" not in results:
        problems.append("no Python results")
    if "matlab" not in results and require_matlab:
        problems.append("no MATLAB results")

    for lang, res in results.items():
        for m in mismatches(res, meta.get("expected", {}), rtol, atol):
            problems.append(f"{lang} vs book: {m}")
    if len(results) == 2:
        keys = meta.get("compare", list(results["python"]))
        py = {k: results["python"].get(k) for k in keys}
        ml = {k: results["matlab"].get(k) for k in keys}
        for m in mismatches(ml, py, rtol, atol):
            problems.append(f"matlab vs python: {m}")

    langs = " + ".join(sorted(results)) or "none"
    print(f"[{'ok' if not problems else 'FAILED'}] {name} ({langs})")
    for p in problems[:20]:
        print(f"    {p}")
    return not problems


def main(args):
    require_matlab = "--require-matlab" in args
    paths = [Path(a) for a in args if not a.startswith("--")] or [ROOT / "examples"]
    examples = [p.parent for r in paths for p in sorted(r.resolve().rglob("example.yml"))]
    ok = [check(e, require_matlab) for e in examples]
    if not all(ok):
        sys.exit(f"{ok.count(False)} of {len(ok)} example(s) failed")


if __name__ == "__main__":
    main(sys.argv[1:])
