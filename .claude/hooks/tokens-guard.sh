#!/usr/bin/env bash
# tokens.css is the single source of truth for every design system value.
# Changing a token changes the whole product — that is always a human decision.
# Runs on PreToolUse (Edit|Write) and escalates to the user.
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
          "tokens.css is the single source of truth for the design system. A token change needs human approval and a line in DECISIONS.md (/decision)."
      }
    }'
    ;;
  *) exit 0 ;;
esac
