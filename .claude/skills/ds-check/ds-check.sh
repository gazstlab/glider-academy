#!/usr/bin/env bash
# Piso mecânico do design system, no repositório inteiro.
# Os quatro checks do §8 + a paridade tokens.css <-> tokens.json do §12.
set -uo pipefail
cd "${CLAUDE_PROJECT_DIR:-$PWD}" || exit 1
. .claude/hooks/ds-rules.sh

status=0
files=0
echo "== §8 · contrato de UI =="
while IFS= read -r f; do
  gl_is_source "$f" || continue
  files=$((files + 1))
  if ! findings=$(gl_check_file "$f"); then
    printf '\n%s:%s\n' "$f" "$findings"
    status=1
  fi
done < <(git ls-files --cached --others --exclude-standard 2>/dev/null \
         || find . -type f -not -path './.git/*' -not -path './node_modules/*')
[ "$status" -eq 0 ] && echo "  ok · $files arquivos de fonte, nenhuma violação"

echo
echo "== §12 · paridade de tokens =="
if bash .claude/hooks/tokens-parity.sh <<< '{"tool_input":{"file_path":"docs/design-system/tokens.css"}}'; then
  echo "  ok · tokens.css e tokens.json batem"
else
  status=1
fi

echo
if [ "$status" -eq 0 ]; then
  echo "PASSOU. Falta o piso do §10, que é humano: 360px, teclado, foco"
  echo "visível, reduced-motion, contraste, claro e escuro na mesma tela,"
  echo "e o grid legível em simulação de daltonismo."
else
  echo "FALHOU. Corrija antes de encerrar a tarefa."
fi
exit "$status"
