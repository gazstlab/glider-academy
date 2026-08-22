---
name: decision
description: Registra uma decisão de design em docs/design-system/DECISIONS.md, no formato da tabela, numerada e datada. Use ao contrariar uma regra do design system, ao mudar de rumo, ou ao fixar uma escolha de arquitetura que o código sozinho não explica.
argument-hint: [o que foi decidido]
disable-model-invocation: true
allowed-tools: Bash(${CLAUDE_SKILL_DIR}/add.sh:*) Read
---

`CLAUDE.md` é claro: exceção sem linha em `DECISIONS.md` é bug. Esta skill escreve a linha.

## Antes de escrever

Leia `docs/design-system/DECISIONS.md`. Se a decisão nova **substitui** uma anterior, a
convenção do arquivo é marcar isso na própria célula da decisão — veja D11, D12, D13, D16,
D17, que usam `**Substitui Dx**`. Não apague a linha antiga: o histórico de por que o rumo
mudou é metade do valor do arquivo.

## Escrever

```bash
${CLAUDE_SKILL_DIR}/add.sh "<decisão>" "<motivo>" "<descartado>"
```

O número `Dnn` e a data saem automáticos. Os três campos são obrigatórios.

Cada um tem um trabalho, e o terceiro é o que costuma ser pulado:

- **decisão** — o que passa a valer, em uma linha. Se substitui outra, comece com
  `**Substitui Dx** · `
- **motivo** — por que, ligado ao produto. `porque fica melhor` não é motivo; `porque
  transferência é o produto e isso aproxima do Airflow real` é
- **descartado** — a alternativa dentro do sistema que você considerou e recusou. Sem ela
  a linha não serve para nada daqui a seis meses: quem ler não vai saber se a opção óbvia
  foi avaliada ou nem passou pela cabeça de ninguém

Depois de escrever, confirme que a tabela continua renderizando (a linha tem exatamente
quatro células) e leia a linha de volta em voz alta. Se ela não convence você, a decisão
provavelmente ainda não está madura.
