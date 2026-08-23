#!/usr/bin/env bash
# The design system's mechanical floor, across the whole repository.
# The four §8 checks plus the tokens.css <-> tokens.json parity of §12.
set -uo pipefail
cd "${CLAUDE_PROJECT_DIR:-$PWD}" || exit 1

# Without rg/jq the checks below would pass for being unable to search.
bash .claude/hooks/preflight.sh || exit 1

. .claude/hooks/ds-rules.sh

status=0
files=0

echo "== §0 · the gate knows how to reject =="
if selftest=$(bash .claude/hooks/ds-selftest.sh 2>&1); then
  printf '  ok · %s\n' "$(printf '%s' "$selftest" | tail -1)"
else
  printf '%s\n' "$selftest"
  status=1
fi

echo
echo "== §8 · UI contract =="
while IFS= read -r f; do
  gl_is_source "$f" || continue
  files=$((files + 1))
  if ! findings=$(gl_check_file "$f"); then
    printf '\n%s:%s\n' "$f" "$findings"
    status=1
  fi
done < <(git ls-files --cached --others --exclude-standard 2>/dev/null \
         || find . -type f -not -path './.git/*' -not -path './node_modules/*')
[ "$status" -eq 0 ] && echo "  ok · $files source files, no violations"

echo
echo "== §12 · token parity =="
if bash .claude/hooks/tokens-parity.sh <<< '{"tool_input":{"file_path":"docs/design-system/tokens.css"}}'; then
  echo "  ok · tokens.css and tokens.json agree"
else
  status=1
fi

echo
if [ "$status" -eq 0 ]; then
  echo "PASSED. What is left is the §10 floor, which is human: 360px, keyboard,"
  echo "visible focus, reduced-motion, contrast, light and dark on the same"
  echo "screen, and the grid readable under colour-blindness simulation."
else
  echo "FAILED. Fix this before calling the task done."
fi
exit "$status"
