#!/usr/bin/env bash
# tokens.css é a fonte única de verdade de todo valor do design system.
# Mudar um token muda o produto inteiro — é decisão humana, sempre.
# Roda em PreToolUse (Edit|Write) e escala para o usuário.
set -uo pipefail

payload=$(cat)
file=$(printf '%s' "$payload" | jq -r '.tool_input.file_path // empty')

case "$file" in
  */docs/design-system/tokens.css)
    jq -n '{
      hookSpecificOutput: {
        hookEventName: "PreToolUse",
        permissionDecision: "escalate",
        permissionDecisionReason:
          "tokens.css é a fonte única de verdade do design system. Mudança de token precisa de aprovação humana e de uma linha em DECISIONS.md (/decision)."
      }
    }'
    ;;
  *) exit 0 ;;
esac
