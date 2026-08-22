#!/usr/bin/env bash
# A header configured in vercel.json and not actually served is the classic
# silent failure of this stack. Nothing turns red: the page loads, and only
# Pyodide fails to initialise — months later, in production, for a learner.
#
# COOP + COEP are the prerequisite for SharedArrayBuffer, and without
# SharedArrayBuffer the UI cannot interrupt a Python run that hung in the lab.
# The stop button sits on the screen and never reaches the worker.
#
# Usage: smoke-headers.sh <url>
set -uo pipefail

url=${1:-}
[ -n "$url" ] || { echo "usage: smoke-headers.sh <url>" >&2; exit 1; }

echo "Checking headers on $url"
response=$(curl -sSL --max-time 30 -D - -o /dev/null "$url" 2>&1) || {
  echo "::error::could not reach $url" >&2
  printf '%s\n' "$response" >&2
  exit 1
}

failures=0
expect() {
  local header=$1 expected=$2 actual
  actual=$(printf '%s' "$response" | rg -i "^$header:" | tail -1 | sed 's/^[^:]*: *//' | tr -d '\r')
  if [ "$(printf '%s' "$actual" | tr 'A-Z' 'a-z')" = "$expected" ]; then
    printf '  ok      %-32s %s\n' "$header" "$actual"
  else
    printf '  FAILED  %-32s expected "%s", got "%s"\n' "$header" "$expected" "${actual:-absent}" >&2
    failures=$((failures + 1))
  fi
}

expect 'cross-origin-opener-policy'   'same-origin'
expect 'cross-origin-embedder-policy' 'require-corp'
expect 'x-content-type-options'       'nosniff'

if [ "$failures" -gt 0 ]; then
  echo "::error::$failures header(s) from vercel.json did not reach the response. The lab will not be able to interrupt execution." >&2
  exit 1
fi
echo "Cross-origin isolation headers are being served."
