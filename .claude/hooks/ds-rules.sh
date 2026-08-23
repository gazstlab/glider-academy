#!/usr/bin/env bash
# The four DESIGN-SYSTEM.md §8 checks, in one place.
# Sourced by .claude/hooks/ds-gate.sh (one file, on PostToolUse) and by
# .claude/skills/ds-check/ds-check.sh (the whole repository), and called by the
# `contract` job in CI.
# The same regex re-typed in each of them would be a guarantee of drift.

# True when the path is product source subject to the contract.
gl_is_source() {
  case "$1" in
    *.ts|*.tsx|*.js|*.jsx|*.mjs|*.cjs|*.css|*.scss|*.html|*.vue|*.svelte) ;;
    *) return 1 ;;
  esac
  # Docs, mockups and the agent config carry hex on purpose.
  # tokens.css is the only place where a raw value is legal.
  case "$1" in
    */docs/*|docs/*|*/.claude/*|.claude/*|*/node_modules/*|node_modules/*|*/tokens.css) return 1 ;;
  esac
  return 0
}

# Echoes a file's violations. Returns 1 if there are any.
gl_check_file() {
  local file=$1 out="" hit

  # Without ripgrep every `if hit=$(rg ...)` below exits 127 and the condition
  # goes false: the file would pass for never having been read, not for being
  # compliant. A false green is the worst failure mode a gate can have, so here
  # it turns red instead.
  if ! command -v rg >/dev/null 2>&1; then
    printf '\n  ripgrep missing — the §8 checks did not run on this file'
    return 1
  fi

  if hit=$(rg -n '#[0-9a-fA-F]{3,8}\b' -- "$file"); then
    out="${out}
  rule 1 · literal hex — use a --gl-* token from tokens.css
$(printf '%s' "$hit" | sed 's/^/    /')"
  fi

  # camelCase included: in JSX the property is spelled boxShadow.
  if hit=$(rg -n 'box-shadow|boxShadow' -- "$file" | rg -v 'gl-shadow-|gl-ring-focus'); then
    out="${out}
  rule 3 · box-shadow outside --gl-shadow-card/--gl-shadow-pop/--gl-ring-focus
$(printf '%s' "$hit" | sed 's/^/    /')"
  fi

  # camelCase, and any value >= 12px, not just 12/16/24.
  if hit=$(rg -n 'rounded-(xl|2xl|3xl)|border(-r|R)adius:\s*.{0,2}(1[2-9]|[2-9][0-9])px' -- "$file"); then
    out="${out}
  rule 4 · border-radius above 8px — the maximum is --gl-radius-card
$(printf '%s' "$hit" | sed 's/^/    /')"
  fi

  if hit=$(rg -n 'state.*gl-accent|gl-accent.*state' -- "$file"); then
    out="${out}
  rule 5 · --gl-accent used as a state colour — blue in the grid is a bug
$(printf '%s' "$hit" | sed 's/^/    /')"
  fi

  [ -z "$out" ] && return 0
  printf '%s' "$out"
  return 1
}
