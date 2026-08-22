#!/usr/bin/env bash
# Applies the four DESIGN-SYSTEM.md §8 checks to the file that was just edited.
# PostToolUse (Edit|Write). Exit 2 hands the error back to Claude.
# Only looks at the file that changed — not the whole repository.
set -uo pipefail

payload=$(cat)
file=$(printf '%s' "$payload" | jq -r '.tool_input.file_path // empty')
[ -n "$file" ] && [ -f "$file" ] || exit 0

# shellcheck source=./ds-rules.sh
. "$(dirname "${BASH_SOURCE[0]}")/ds-rules.sh"

gl_is_source "$file" || exit 0

if ! findings=$(gl_check_file "$file"); then
  printf 'UI contract violated in %s:%s\n\nSource: docs/design-system/DESIGN-SYSTEM.md §8. Fix it before moving on.\n' \
    "${file#"${CLAUDE_PROJECT_DIR:-$PWD}/"}" "$findings" >&2
  exit 2
fi
exit 0
