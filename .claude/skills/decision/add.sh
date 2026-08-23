#!/usr/bin/env bash
# Appends a row to docs/design-system/DECISIONS.md.
# Usage: add.sh "<decision>" "<reason>" "<discarded>"
set -euo pipefail
cd "${CLAUDE_PROJECT_DIR:-$PWD}"
F=docs/design-system/DECISIONS.md

[ $# -eq 3 ] || { echo 'usage: add.sh "<decision>" "<reason>" "<discarded>"' >&2; exit 1; }
for i in 1 2 3; do
  [ -n "${!i//[[:space:]]/}" ] || { echo "all three fields are required; number $i came in empty" >&2; exit 1; }
done

n=$(rg -o '\| D([0-9]+) ' "$F" -r '$1' | sort -n | tail -1)
next="D$(( ${n:-0} + 1 ))"
date=$(date +%F)

printf '| %s | %s · %s | %s | %s |\n' "$date" "$next" "$1" "$2" "$3" >> "$F"
echo "$next recorded in $F:"
tail -1 "$F"
