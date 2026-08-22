#!/usr/bin/env bash
# Os quatro checks do DESIGN-SYSTEM.md §8, em um lugar só.
# Sourced por .claude/hooks/ds-gate.sh (um arquivo, no PostToolUse) e por
# .claude/skills/ds-check/ds-check.sh (o repositório inteiro).
# Regex duplicada nos dois seria garantia de divergência.

# Verdadeiro se o caminho é fonte de produto sujeita ao contrato.
gl_is_source() {
  case "$1" in
    *.ts|*.tsx|*.js|*.jsx|*.mjs|*.cjs|*.css|*.scss|*.html|*.vue|*.svelte) ;;
    *) return 1 ;;
  esac
  # Documentação, mockups e a config do agente contêm hex de propósito.
  # tokens.css é o único lugar onde valor cru é legal.
  case "$1" in
    */docs/*|docs/*|*/.claude/*|.claude/*|*/node_modules/*|node_modules/*|*/tokens.css) return 1 ;;
  esac
  return 0
}

# Ecoa as violações de um arquivo. Retorna 1 se houver alguma.
gl_check_file() {
  local file=$1 out="" hit

  if hit=$(rg -n '#[0-9a-fA-F]{3,8}\b' -- "$file"); then
    out="${out}
  regra 1 · hex literal — use um token --gl-* de tokens.css
$(printf '%s' "$hit" | sed 's/^/    /')"
  fi

  # camelCase incluído: em JSX a propriedade se escreve boxShadow.
  if hit=$(rg -n 'box-shadow|boxShadow' -- "$file" | rg -v 'gl-shadow-|gl-ring-focus'); then
    out="${out}
  regra 3 · box-shadow fora de --gl-shadow-card/--gl-shadow-pop/--gl-ring-focus
$(printf '%s' "$hit" | sed 's/^/    /')"
  fi

  # camelCase e qualquer valor >= 12px, não só 12/16/24.
  if hit=$(rg -n 'rounded-(xl|2xl|3xl)|border(-r|R)adius:\s*.{0,2}(1[2-9]|[2-9][0-9])px' -- "$file"); then
    out="${out}
  regra 4 · border-radius acima de 8px — o máximo é --gl-radius-card
$(printf '%s' "$hit" | sed 's/^/    /')"
  fi

  if hit=$(rg -n 'state.*gl-accent|gl-accent.*state' -- "$file"); then
    out="${out}
  regra 5 · --gl-accent usado como cor de estado — azul no grid é bug
$(printf '%s' "$hit" | sed 's/^/    /')"
  fi

  [ -z "$out" ] && return 0
  printf '%s' "$out"
  return 1
}
