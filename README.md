# Computational Systems Biology in MATLAB and Python

An open primer on computational systems biology, with every worked example in both MATLAB and Python. It accompanies the book *An Introduction to Computational Systems Biology: Systems-Level Modelling of Cellular Networks* (Karthik Raman, CRC Press, 2021) and the course BT5240 at IIT Madras.

**Read it online:** <https://ramanlab.github.io/sysbio-primer> (a PDF version is linked from the site).

## Layout

```
chapters/            the text, one Quarto (.qmd) file per chapter
examples/<topic>/<example>/
    <name>.m         MATLAB version
    <name>.py        Python version
    example.yml      book reference, toolboxes needed, what to compare, expected values
    out/matlab/      figures + results.json written by the MATLAB script
    out/python/      figures + results.json written by the Python script
data/                shared models and datasets
matlab/+sbp/         small MATLAB helpers (save results and figures)
python/sbp/          the same helpers for Python
tests/compare.py     checks the results: Python vs MATLAB vs book
tools/               scripts to run all examples, and Quarto filters
```

## Running the examples

See the [Getting started](chapters/getting-started.qmd) chapter. In short:

```bash
pip install -r requirements.txt && pip install -e .
python tools/run_examples.py          # run every Python example
python tests/compare.py               # check the results
```

In MATLAB, from the repository folder: `addpath tools; run_examples` (run `initCobraToolbox` first for the constraint-based examples).

## Building the site

```bash
quarto preview          # live preview while editing
quarto render           # website and PDF, into _book/
```

The site uses the committed outputs under `examples/**/out/`, so building it needs neither MATLAB nor Python packages. On a machine without MATLAB, the MATLAB figures that have not been generated yet are replaced by a short note.

## Checks

On every push, GitHub Actions ([`check.yml`](.github/workflows/check.yml)) runs all examples in both languages and runs `tests/compare.py`, which checks that

* each language reproduces the values listed under `expected:` in `example.yml` (taken from the book where available), and
* MATLAB and Python agree, within the example's tolerance, on the quantities listed under `compare:`.

MATLAB runs in CI free of charge because this repository is public. To pull the figures from the latest CI run into your working copy, use `tools/fetch_ci_outputs.sh matlab`. Pushes to `main` also rebuild and publish the site ([`publish.yml`](.github/workflows/publish.yml)).

See [CONTRIBUTING.md](CONTRIBUTING.md) for how to add an example.

## Licence

Text: [CC BY 4.0](LICENSE-TEXT.md). Code: [MIT](LICENSE). The *E. coli* core model in `data/` is from BiGG Models; see [data/README.md](data/README.md).
