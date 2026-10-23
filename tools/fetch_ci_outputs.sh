#!/usr/bin/env bash
# Copy the outputs (figures and results.json) of the latest successful CI run
# into the working tree, so they can be committed and shown on the website.
# Useful when you cannot run MATLAB yourself. Needs the GitHub CLI (gh).
#
# Usage:  tools/fetch_ci_outputs.sh [matlab|python]   (default: matlab)
set -euo pipefail
lang="${1:-matlab}"
run_id=$(gh run list --workflow check.yml --branch main --status success \
         --limit 1 --json databaseId --jq '.[0].databaseId')
tmp=$(mktemp -d)
gh run download "$run_id" --name "out-$lang" --dir "$tmp"
tar xzf "$tmp/out-$lang.tgz"
rm -rf "$tmp"
echo "Updated examples/**/out/$lang from CI run $run_id; review with git status."
