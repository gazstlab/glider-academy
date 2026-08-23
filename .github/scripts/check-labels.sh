#!/usr/bin/env bash
# A label referenced by an issue form or by dependabot that does not exist in
# .github/labels.yml is dropped silently by GitHub: the issue opens without it
# and nothing turns red. Since the board and the release notes are driven by
# labels, the effect is a card that never moves and nobody knows why.
#
# The namespaces (type/, track/, area/, quality/, state/, severity/) exist for
# classification, but also to make this sweep possible without a YAML parser.
set -uo pipefail
cd "${CLAUDE_PROJECT_DIR:-$PWD}" || exit 1

declared=$(rg -o '^- name: "([^"]+)"' -r '$1' .github/labels.yml | sort -u)
referenced=$(rg --no-filename -o '"((type|track|area|quality|state|severity)/[a-z0-9-]+)"' -r '$1' \
  .github/ISSUE_TEMPLATE/ .github/dependabot.yml .github/workflows/ .github/release.yml 2>/dev/null | sort -u)

orphans=$(comm -13 <(printf '%s\n' "$declared") <(printf '%s\n' "$referenced"))

if [ -n "$orphans" ]; then
  {
    echo "Labels referenced but missing from .github/labels.yml:"
    printf '%s\n' "$orphans" | sed 's/^/  /'
    echo
    echo "GitHub drops these silently. Declare them in labels.yml or fix the reference."
  } >&2
  exit 1
fi

n_ref=$(printf '%s\n' "$referenced" | rg -c '\S' || echo 0)
n_dec=$(printf '%s\n' "$declared" | rg -c '\S' || echo 0)
echo "  ok · $n_ref labels referenced, all among the $n_dec declared"
