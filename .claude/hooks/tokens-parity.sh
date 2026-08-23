#!/usr/bin/env bash
# DESIGN-SYSTEM.md §12: tokens.css and tokens.json have to be verified against
# each other. If they diverge, tokens.css wins.
#
# Compares the SET of hex colours in the two files. That is where the real risk
# lives: someone changes a colour in one file and forgets the other.
#
# Deliberately does NOT compare numeric values. There are legitimate asymmetries
# (0ms exists only in the css, inside the prefers-reduced-motion block; the
# 640px/900px breakpoints exist only in the json) and a check that flagged those
# would be abandoned in its first week.
set -uo pipefail

# Only acts when the edited file is one of the two token files.
payload=$(cat)
file=$(printf '%s' "$payload" | jq -r '.tool_input.file_path // empty')
case "$file" in
  */docs/design-system/tokens.css|*/docs/design-system/tokens.json) ;;
  *) exit 0 ;;
esac

DIR="${CLAUDE_PROJECT_DIR:-$PWD}/docs/design-system"
CSS="$DIR/tokens.css"
JSON="$DIR/tokens.json"
[ -f "$CSS" ] && [ -f "$JSON" ] || exit 0

hexes() { rg -o '#[0-9a-fA-F]{6}\b' -- "$1" | tr 'a-f' 'A-F' | sort -u; }

only_css=$(comm -23 <(hexes "$CSS") <(hexes "$JSON"))
only_json=$(comm -13 <(hexes "$CSS") <(hexes "$JSON"))

if [ -n "$only_css" ] || [ -n "$only_json" ]; then
  {
    echo "tokens.css and tokens.json have diverged (DESIGN-SYSTEM.md §12)."
    [ -n "$only_css" ]  && { echo; echo "  only in tokens.css:";  printf '%s\n' "$only_css"  | sed 's/^/    /'; }
    [ -n "$only_json" ] && { echo; echo "  only in tokens.json:"; printf '%s\n' "$only_json" | sed 's/^/    /'; }
    echo
    echo "tokens.css wins. Align tokens.json with it."
  } >&2
  exit 2
fi
exit 0
