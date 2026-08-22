#!/usr/bin/env bash
# Anexa uma linha em docs/design-system/DECISIONS.md.
# Uso: add.sh "<decisão>" "<motivo>" "<descartado>"
set -euo pipefail
cd "${CLAUDE_PROJECT_DIR:-$PWD}"
F=docs/design-system/DECISIONS.md

[ $# -eq 3 ] || { echo 'uso: add.sh "<decisão>" "<motivo>" "<descartado>"' >&2; exit 1; }
for i in 1 2 3; do
  [ -n "${!i//[[:space:]]/}" ] || { echo "os três campos são obrigatórios; o $i veio vazio" >&2; exit 1; }
done

n=$(rg -o '\| D([0-9]+) ' "$F" -r '$1' | sort -n | tail -1)
next="D$(( ${n:-0} + 1 ))"
date=$(date +%F)

printf '| %s | %s · %s | %s | %s |\n' "$date" "$next" "$1" "$2" "$3" >> "$F"
echo "$next registrado em $F:"
tail -1 "$F"
