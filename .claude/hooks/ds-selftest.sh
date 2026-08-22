#!/usr/bin/env bash
# Tests the tester.
#
# Today `gl_is_source` excludes docs/ and .claude/, and there is no src/. So
# `/ds-check` sweeps zero source files and prints "ok". A gate that only knows
# how to pass is not a gate: a regex broken by an edit would stay green forever.
#
# Here every §8 rule is exercised against a case it MUST reject and one it MUST
# accept. The fixtures are born in mktemp and die at the end: a violating .css
# committed to the repository would be swept by ds-check.sh itself and leave CI
# red forever.
set -uo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
. "$root/.claude/hooks/ds-rules.sh"

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

failures=0
cases=0

# rejects <name> <content> — gl_check_file has to return 1
rejects() {
  local name=$1 content=$2 file="$tmp/case.css"
  cases=$((cases + 1))
  printf '%s\n' "$content" > "$file"
  if gl_check_file "$file" >/dev/null 2>&1; then
    printf '  FAILED  %s\n          slipped through: %s\n' "$name" "$content" >&2
    failures=$((failures + 1))
  else
    printf '  ok      %s\n' "$name"
  fi
}

# accepts <name> <content> — gl_check_file has to return 0
accepts() {
  local name=$1 content=$2 file="$tmp/case.css" output
  cases=$((cases + 1))
  printf '%s\n' "$content" > "$file"
  if output=$(gl_check_file "$file" 2>&1); then
    printf '  ok      %s\n' "$name"
  else
    printf '  FAILED  %s\n          false positive on: %s%s\n' "$name" "$content" "$output" >&2
    failures=$((failures + 1))
  fi
}

# source <name> <path> <expected yes|no>
source_check() {
  local name=$1 path=$2 expected=$3 actual
  cases=$((cases + 1))
  if gl_is_source "$path"; then actual=yes; else actual=no; fi
  if [ "$actual" = "$expected" ]; then
    printf '  ok      %s\n' "$name"
  else
    printf '  FAILED  %s\n          %s: expected %s, got %s\n' "$name" "$path" "$expected" "$actual" >&2
    failures=$((failures + 1))
  fi
}

echo "== what §8 has to reject =="
rejects 'rule 1 · six-digit hex'      'a{color:#017CEE}'
rejects 'rule 1 · three-digit hex'    'a{color:#fff}'
rejects 'rule 3 · raw box-shadow'     'a{box-shadow:0 2px 8px black}'
rejects 'rule 3 · boxShadow in JSX'   'const s={boxShadow:"0 2px 8px black"}'
rejects 'rule 4 · radius 16px'        'a{border-radius:16px}'
rejects 'rule 4 · borderRadius JSX'   'const s={borderRadius:"12px"}'
rejects 'rule 4 · rounded-2xl'        '<div className="rounded-2xl" />'
rejects 'rule 5 · blue as state'      '.state-running{color:var(--gl-accent)}'

echo
echo "== what §8 has to accept =="
accepts 'colour token'    'a{color:var(--gl-fg-default)}'
accepts 'shadow token'    'a{box-shadow:var(--gl-shadow-card)}'
accepts 'focus token'     'a:focus-visible{box-shadow:var(--gl-ring-focus)}'
accepts 'radius at cap'   'a{border-radius:8px}'
accepts 'radius token'    'a{border-radius:var(--gl-radius-card)}'

echo
echo "== who is subject to the contract =="
source_check 'src/ is source'          'src/components/GridView.tsx'   yes
source_check 'product css is source'   'src/styles/grid.css'           yes
source_check 'tokens.css is exempt'    'docs/design-system/tokens.css' no
source_check 'docs/ is exempt'         'docs/mockups/hero.html'        no
source_check '.claude/ is exempt'      '.claude/agents/ds-reviewer.md' no
source_check 'markdown is not source'  'README.md'                     no

echo
if [ "$failures" -eq 0 ]; then
  echo "PASSED · $cases cases, the gate knows how to reject and how to accept"
  exit 0
fi
echo "FAILED · $failures of $cases cases. ds-rules.sh is not doing what it says." >&2
exit 1
