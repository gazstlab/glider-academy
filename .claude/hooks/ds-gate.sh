#!/usr/bin/env bash
# Aplica os quatro checks do DESIGN-SYSTEM.md §8 no arquivo recém-editado.
# PostToolUse (Edit|Write). Exit 2 devolve o erro ao Claude.
# Só olha o arquivo que mudou — não o repositório inteiro.
set -uo pipefail

payload=$(cat)
file=$(printf '%s' "$payload" | jq -r '.tool_input.file_path // empty')
[ -n "$file" ] && [ -f "$file" ] || exit 0

# shellcheck source=./ds-rules.sh
. "$(dirname "${BASH_SOURCE[0]}")/ds-rules.sh"

gl_is_source "$file" || exit 0

if ! findings=$(gl_check_file "$file"); then
  printf 'Contrato de UI violado em %s:%s\n\nFonte: docs/design-system/DESIGN-SYSTEM.md §8. Corrija antes de seguir.\n' \
    "${file#"${CLAUDE_PROJECT_DIR:-$PWD}/"}" "$findings" >&2
  exit 2
fi
exit 0
