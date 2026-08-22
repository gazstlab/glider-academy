# Contrato do Glider — leia antes de tocar em qualquer tela

Você está trabalhando no **Glider** (glider.academy): laboratórios de orquestração de
dados que rodam inteiros no navegador, sem backend.

Fonte de verdade completa: `docs/design-system/DESIGN-SYSTEM.md`.
Valores: `docs/design-system/tokens.css`. Este arquivo é o resumo executável.

## A regra que vem antes das outras

**Não afirme comportamento do Airflow de memória.** Confira na fonte antes de escrever em
lição, componente ou código — `/airflow-truth` tem o procedimento e os caminhos. Alvo: 3.x.

O Glider ensina. Uma afirmação plausível e falsa é pior que uma lacuna, porque o aluno leva
o erro para a produção dele. `DECISIONS.md` D18 diz o mesmo sobre estados; vale para toda a
semântica: trigger rules, data lógica, precedência de config, ciclo de vida de executor.

## Em uma frase

A linguagem visual descende da UI do Apache Airflow — azul de marca `#017CEE`, cores de
estado herdadas de `airflow.utils.state`, e o grid de quadrados como assinatura. O
critério de toda decisão: *isso aproxima ou afasta do Airflow de verdade?*

## As doze regras

1. Nenhum hex fora de `tokens.css`. Use `--gl-*` semântico, nunca as rampas cruas.
2. Espaçamento só da escala `--gl-space-*`.
3. Sombra só dos tokens `--gl-shadow-card`, `--gl-shadow-pop`, `--gl-ring-focus`.
4. `border-radius` máximo 8px (`--gl-radius-card`), 2px nas células do grid.
5. **O azul de marca nunca é cor de estado.** Azul num quadrado do grid é bug.
6. Estado de task = cor **e** glifo **e** texto acessível. Nunca só cor.
7. Nenhum estado inventado: se não está em `airflow.utils.state`, não existe aqui.
8. Progresso é coluna do grid. Barra de porcentagem não existe no produto.
9. Número em lista, grid ou instrumento: mono + `tabular-nums`.
10. Anima só o pulso do `running` (e o cata-vento do hero, uma volta na carga).
11. Sem emoji, sem gradiente, sem biblioteca de componentes nova.
12. Componente que não está no design system entra no documento **antes** do código.

## Escrita de UI

Sentence case. Verbo ativo que diz o resultado (`Disparar DAG` → `DAG disparado`).
**Use o vocabulário do Airflow** — task, DAG run, data lógica, upstream, backfill,
up_for_retry. Explique na primeira aparição; não substitua por sinônimo.
Erro explica o que quebrou e o que fazer. Sem "simplesmente", sem exclamação.

## Marca

Não reproduza o logo do Apache Airflow nem um cata-vento próximo dele. O parentesco é de
paleta e estrutura, não de símbolo. Rodapé sempre com o aviso de marca da ASF.

## Antes de terminar a tarefa

```
/ds-check
```

Roda os quatro checks do §8 no repositório inteiro mais a paridade
`tokens.css` ↔ `tokens.json` do §12. Um hook já aplica os mesmos checks a cada arquivo
salvo, então isso aqui é a rede — se o hook bloqueou, você já sabe.

Depois confira o piso: 360px, teclado, foco visível, reduced-motion, contraste, tema
claro e escuro na mesma tela, e o grid legível em simulação de daltonismo.

## O que existe em `.claude/`

| | |
|---|---|
| `/ds-check` | os quatro checks do §8 + paridade de tokens. Antes de encerrar tarefa de UI |
| `/airflow-truth` | como conferir uma afirmação sobre o Airflow contra a fonte |
| `/decision` | escreve a linha em `DECISIONS.md`, numerada e datada |
| agente `ds-reviewer` | lê um diff de UI contra o contrato, em contexto limpo. O que regex não pega: componente fora do documento, estado inventado, estado só por cor |

Hooks aplicam sozinhos, a cada `Edit`/`Write`: os checks do §8 no arquivo salvo, a paridade
de tokens, e escalada para o usuário em qualquer alteração de `tokens.css`.

## Se precisar contrariar alguma regra

Use `/decision`. A linha precisa de data, o que foi quebrado, por quê, e qual alternativa
dentro do sistema foi descartada. Sem essa linha, a exceção é bug.
