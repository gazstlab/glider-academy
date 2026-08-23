#!/usr/bin/env bash
# The §8 checks are `if hit=$(rg ...)`. Without ripgrep the command exits 127,
# `hit` stays empty, the condition is false, and the check PASSES without having
# looked at anything. The same goes for `jq` in the token parity check.
#
# On the machine of whoever wrote this both always exist, so the hole never
# shows up. On a runner it shows up as green CI that verifies nothing — the
# worst failure mode a gate can have.
set -uo pipefail

missing=()
for bin in rg jq; do
  command -v "$bin" >/dev/null 2>&1 || missing+=("$bin")
done

if [ ${#missing[@]} -gt 0 ]; then
  {
    echo "preflight: ${missing[*]} not found on PATH."
    echo
    echo "Without them the DESIGN-SYSTEM.md §8 checks would go falsely green:"
    echo "they would pass for being unable to search, not for finding nothing."
    echo
    echo "  macOS:  brew install ripgrep jq"
    echo "  Debian: apt-get install -y ripgrep jq"
  } >&2
  exit 1
fi
exit 0
