---
name: ds-check
description: Roda o piso mecânico do design system do Glider — os quatro checks do DESIGN-SYSTEM.md §8 (hex fora de tokens, box-shadow fora dos tokens, border-radius acima de 8px, azul de marca usado como estado) e a paridade tokens.css/tokens.json do §12. Use antes de encerrar qualquer tarefa que tenha tocado em UI, CSS ou tokens.
allowed-tools: Bash(${CLAUDE_SKILL_DIR}/ds-check.sh)
---

Rode:

```bash
${CLAUDE_SKILL_DIR}/ds-check.sh
```

Ele varre todos os arquivos de fonte versionados e devolve as linhas ofensoras.
Corrija tudo o que aparecer antes de dizer que a tarefa acabou. Não silencie um
achado adicionando exceção no script: se a regra precisa mesmo ser contrariada,
o caminho é `/decision`, que registra a exceção em `DECISIONS.md`.

## O que este check NÃO cobre

O script é o piso mecânico. O piso do §10 é humano e continua sendo seu:

- responsivo até 360px
- navegação completa por teclado, com foco visível
- `prefers-reduced-motion` respeitado
- contraste 4.5:1 em texto, 3:1 em glifos e bordas informativas
- estado nunca comunicado só por cor
- tema claro e escuro verificados na mesma tela
- grid legível em simulação de deuteranopia e protanopia
- sem CLS: grid e canvas reservam altura antes de montar

E há regras do §8 que nenhum regex pega — componente novo que não entrou no
documento antes do código (regra 12), estado inventado que não existe em
`airflow.utils.state` (regra 7), emoji, gradiente. Para uma leitura de contrato
em contexto limpo, use o agente `ds-reviewer`.
