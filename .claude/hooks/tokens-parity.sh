#!/usr/bin/env bash
# DESIGN-SYSTEM.md §12: tokens.css e tokens.json precisam ser verificados.
# Se divergirem, tokens.css vence.
#
# Compara o CONJUNTO de cores hex dos dois arquivos. É onde mora o risco
# real: alguém muda uma cor num arquivo e esquece o outro.
#
# Deliberadamente NÃO compara valores numéricos. Há assimetrias legítimas
# (0ms só existe no css, no bloco de prefers-reduced-motion; os breakpoints
# 640px/900px só existem no json) e um check que acusa isso seria abandonado
# na primeira semana.
set -uo pipefail

# Só age quando o arquivo editado for um dos dois arquivos de token.
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
    echo "tokens.css e tokens.json divergiram (DESIGN-SYSTEM.md §12)."
    [ -n "$only_css" ]  && { echo; echo "  só em tokens.css:";  printf '%s\n' "$only_css"  | sed 's/^/    /'; }
    [ -n "$only_json" ] && { echo; echo "  só em tokens.json:"; printf '%s\n' "$only_json" | sed 's/^/    /'; }
    echo
    echo "tokens.css vence. Alinhe tokens.json com ele."
  } >&2
  exit 2
fi
exit 0
