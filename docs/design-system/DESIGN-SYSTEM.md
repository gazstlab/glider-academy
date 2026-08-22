# Glider Design System

> **glider.academy** — laboratórios de orquestração de dados que rodam no navegador.
> Este documento é um **contrato de implementação**, não um moodboard. Ele é escrito
> para ser lido por agentes de IA (Claude Code, Copilot, Cursor) antes de qualquer
> alteração de UI, e por humanos revisando o que o agente produziu.
>
> **v2** — a linguagem visual agora descende da identidade do Apache Airflow.
> Ver `DECISIONS.md` (D11–D18) para o que foi substituído e por quê.

---

## 0. Como usar este documento (leia primeiro)

**Ordem de leitura obrigatória antes de escrever qualquer componente:**

1. `CLAUDE.md`, na raiz — as regras curtas e o checklist
2. este arquivo, seção do componente que você vai tocar
3. `docs/design-system/tokens.css` — nomes exatos das variáveis

**Se o componente que você precisa não existe aqui:** não invente estilo. Componha a
partir dos primitivos, ou pare e proponha a adição neste documento primeiro. Um
componente novo só entra no código depois de entrar aqui.

**Se este documento conflitar com o código:** este documento vence.

---

## 1. O que estamos construindo

| | |
|---|---|
| **Produto** | Laboratórios interativos de orquestração de dados, rodando inteiros no navegador |
| **Público** | Analistas e engenheiros de dados que já escrevem SQL/Python e vão aprender agendamento, dependências, retries e backfill |
| **Trabalho de cada tela** | Fazer a pessoa executar um DAG e entender o que aconteceu — não ler sobre isso |
| **Tom** | Instrutor de voo: direto, técnico, sem entusiasmo forçado, sem emoji |
| **Restrição** | Sem backend. Tudo estático + WASM. O design nunca assume estado de servidor |

**O princípio que rege a v2 — transferência.** Quem termina o Glider e abre um Airflow
real precisa reconhecer a tela no primeiro segundo. Cada decisão visual é avaliada por
uma pergunta só: *isso aproxima ou afasta do Airflow de verdade?* Onde o Airflow tem
convenção, herdamos. Onde ele tem problema conhecido (contraste, estado só por cor),
corrigimos mantendo a identidade de matiz.

**A metáfora do planador vive no vocabulário**, não na pintura: nome, tom, títulos das
trilhas. Nenhuma ilustração de planador na UI.

---

## 2. Linhagem visual

Três âncoras verificadas na fonte:

1. **Azul de marca `#017CEE`** — a cor do Apache Airflow, cujo símbolo é um cata-vento
   estilizado que sugere movimento e agendamento cíclico.
2. **`airflow.utils.state.state_color`** — o mapa canônico de estado para cor, em cores
   nomeadas de CSS (`green`, `lime`, `gold`, `hotpink`, `turquoise`, `mediumpurple`…).
3. **A UI do Airflow 3** — React + Chakra, temável por tokens de cor `brand` e `gray`.
   Nossa estrutura de tokens espelha essa forma de propósito.

### A assinatura: a grade

O elemento pelo qual o Glider é lembrado é o **grid** — quadrados coloridos por estado,
linha = task, coluna = run. É o visual mais reconhecível do Airflow, e aqui ele é o mesmo
objeto em três escalas:

- **Home:** uma linha de 15 células = a trilha inteira, mostrando onde você parou
- **Índice da trilha:** linhas = lições, colunas = suas tentativas
- **Dentro do lab:** o grid de verdade do DAG run que você acabou de disparar

```
          run 1  run 2  run 3          ■ success    ▢ queued
extrair    ■      ■      ■             ◉ running    ✕ failed
limpar     ■      ✕      ◉             ↻ retry      ⁄ skipped
somar      ■      ▢      ▢
publicar   ⁄      ▢      ▢
```

O progresso na trilha **é** uma coluna desse grid. Não existe barra de porcentagem em
lugar nenhum do produto.

O único movimento ambiente é o **pulso do estado `running`**. O cata-vento da marca gira
devagar apenas no hero, uma vez, na carga da página.

---

## 3. Cor

Use **sempre** o papel semântico (`--gl-text`, `--gl-surface`). As rampas
(`--gl-brand-*`, `--gl-gray-*`) existem para os papéis referenciarem e **não** devem
aparecer direto num componente.

Tema **claro é o padrão** (como na UI do Airflow); escuro é primeira classe, não segunda.

| Papel | Token | Claro | Escuro |
|---|---|---|---|
| Fundo | `--gl-bg` | `#F7F9FB` | `#10161F` |
| Superfície | `--gl-surface` | `#FFFFFF` | `#1B2431` |
| Superfície elevada | `--gl-surface-raised` | `#EDF1F5` | `#2A3646` |
| Borda | `--gl-border` | `#DCE3EB` | `#2A3646` |
| Texto | `--gl-text` | `#1B2431` | `#EDF1F5` |
| Texto secundário | `--gl-text-muted` | `#55677E` | `#9AA8B8` |
| Acento | `--gl-accent` | `#017CEE` | `#1A8CF1` |

### Estados de task

Herdados do Airflow por **matiz**, retunados por **valor** para passar em contraste.
A tabela é a fonte; não improvise um estado novo.

| Estado | Airflow | `--gl-state-*` | Glifo |
|---|---|---|---|
| `success` | green | `success` | quadrado cheio com ✓ |
| `running` | lime | `running` | anel pulsando |
| `queued` | gray | `queued` | quadrado vazado |
| `up_for_retry` | gold | `up-for-retry` | ↻ |
| `upstream_failed` | orange | `upstream-failed` | ↑ |
| `failed` | red | `failed` | ✕ |
| `skipped` | hotpink | `skipped` | ⁄ |
| `up_for_reschedule` | turquoise | `up-for-reschedule` | ⏱ |
| `scheduled` | tan | `scheduled` | · |
| `deferred` | mediumpurple | `deferred` | ⏸ |
| `restarting` | violet | `restarting` | ↺ |
| `removed` | lightgrey | `removed` | ▨ |
| `none` | lightblue | `none` | vazio |

**Três regras bloqueantes em review:**

1. **O azul de marca nunca é cor de estado.** Azul num quadrado do grid é bug. `--gl-accent`
   serve à ação primária e à navegação, e a nada mais.
2. **Estado = cor + glifo + texto acessível.** `lime` e `green` (running e success) são
   quase indistinguíveis para daltônicos — é a queixa histórica da UI do Airflow, e é
   exatamente por isso que o glifo não é opcional aqui.
3. **Nenhum estado inventado.** Se não está em `airflow.utils.state`, não existe no Glider.

### Contraste

Mínimo 4.5:1 para texto, 3:1 para bordas e glifos que carregam informação. Toda cor de
estado foi tunada para passar sobre `--gl-surface` no seu tema.

---

## 4. Tipografia

| Papel | Família | Onde |
|---|---|---|
| Display | **Familjen Grotesk** | h1, h2, números grandes |
| Corpo | **Inter** | parágrafos, UI, botões |
| Utilitária | **JetBrains Mono** | código, cron, durações, IDs de task, etiquetas |

Inter é escolha de **transferência**, não de preguiça: é a fonte da UI do Airflow, e a
familiaridade é o produto. A personalidade fica por conta do display, que é geométrico e
levemente idiossincrático — o suficiente para o Glider não parecer um fork do Airflow.

**Escala** — `--gl-text-2xs` … `--gl-text-4xl` (11 → 72px). `4xl` só no hero da home.

**Etiquetas:** mono, `--gl-text-2xs`, caixa alta, `--gl-tracking-label`, `--gl-text-muted`.
Devem carregar informação real: `LIÇÃO 04 · 12 MIN`, `SCHEDULE @daily`.

**Números:** `font-variant-numeric: tabular-nums` obrigatório em qualquer número em lista,
tabela, grid ou instrumento.

---

## 5. Componentes

Contrato fixo. Agentes implementam o contrato; não adicionam `variant` novo sem
atualizar este documento.

### 5.1 `Button`

| Variante | Uso | Aparência |
|---|---|---|
| `primary` | Uma por tela. A ação que executa algo | fundo `--gl-accent`, texto `--gl-on-accent`, raio `--gl-radius-ui` |
| `secondary` | Ações de apoio | fundo `--gl-surface`, borda `--gl-border-strong` |
| `ghost` | Barra de ferramentas | sem borda, hover `--gl-surface-raised` |
| `danger` | Só reset destrutivo do lab | borda e texto `--gl-state-failed` |

Altura 32px (`sm`) ou 40px (`md`). Label em sentence case, verbo ativo, e o mesmo verbo do
resultado: `Disparar DAG` → toast `DAG disparado`.

### 5.2 `StateCell`

O quadrado do grid. `--gl-cell-size`, raio `--gl-cell-radius`, preenchido com a cor do
estado e com o glifo dentro a partir de 12px. Abaixo disso o glifo some e o `title` +
`aria-label` carregam o estado por extenso.

`running` recebe um anel que pulsa em `--gl-dur-pulse`. Nenhum outro estado anima.

### 5.3 `StateChip`

Legenda e rótulo textual. Cor + glifo + texto, os três. Mono, `--gl-text-2xs`, caixa alta,
raio `--gl-radius-ui`, fundo transparente com borda na cor do estado.

### 5.4 `GridView`

A assinatura. Linhas = tasks, colunas = runs, mais recente à direita. Cabeçalho de coluna
em mono com a data lógica. Hover em qualquer célula destaca a linha e a coluna inteiras.

Requisitos não negociáveis:
- é uma `<table>` semântica, não um mar de `<div>`
- cada célula é focável, com `aria-label` no formato `limpar · run 2026-08-22 · falhou`
- existe alternância para lista textual; o grid nunca é a única forma de ler o estado

### 5.5 `GraphView`

Nós retangulares, raio `--gl-radius-node`, **borda** na cor do estado (é assim que o
Airflow faz — borda, não preenchimento), fundo `--gl-surface`. Arestas em
`--gl-border-strong`, sólidas.

- navegável por teclado (setas entre nós, Enter abre detalhe)
- cada nó é um `<button>` com `aria-label` incluindo id da task e estado por extenso

### 5.6 `TrackGrid` (progresso)

Progresso na trilha é uma **coluna do grid**: 15 células, uma por lição, coloridas pelo
seu estado (`success`, `running`, `queued`). Não existe barra de porcentagem.

Fallback: `role="progressbar"` com `aria-valuenow/min/max` e texto `Lição 4 de 15`.

### 5.7 `CodePane`

Monaco. Tema derivado dos tokens — **não usar `vs`/`vs-dark` de fábrica**. Fundo
`--gl-surface`, gutter `--gl-text-muted`, seleção `--gl-accent-quiet`.

### 5.8 `RunLog`

Saída do scheduler. Mono, `--gl-text-sm`, `--gl-leading-snug`. Timestamps em
`--gl-text-muted`, nível de log colorido pelos tokens de estado. Rola sozinho apenas
enquanto o usuário está no fim do buffer.

### 5.9 `Callout`

Três tipos, e só três: `note`, `warning`, `checkpoint`. Borda esquerda 3px na cor do tipo,
`border-radius: 0`, sem fundo colorido, sem emoji.

### 5.10 Estados vazios e de erro

Tela vazia é convite à ação. Erro diz o que quebrou e o que fazer, na voz da interface.

- ✅ `Nenhum DAG encontrado. Verifique se o arquivo está em dags/ e dispare de novo.`
- ❌ `Ops! Algo deu errado 😕`

---

## 6. Layout

- Container `--gl-max-width` (1200px), gutter `--gl-gutter`
- Texto corrido limitado a `--gl-prose-width` (68ch)
- O lab usa 3 painéis redimensionáveis; o conteúdo usa grid de 12 colunas
- Breakpoints: `640` / `900` / `1200`
- **Abaixo de 900px o lab vira leitura + execução, sem canvas editável.** Decisão tomada
  (D9), não reabra.

---

## 7. Movimento

| Situação | Duração | Easing |
|---|---|---|
| Hover, foco | `--gl-dur-1` | `--gl-ease-out` |
| Entrada de painel, popover | `--gl-dur-2` | `--gl-ease-snap` |
| Transição de lição | `--gl-dur-3` | `--gl-ease-snap` |
| Pulso do estado `running` | `--gl-dur-pulse` | `ease-in-out`, infinito |
| Giro do cata-vento no hero | `--gl-dur-spin` | `linear`, **uma volta só** |

Nada mais anima. Sem parallax, sem reveal no scroll, sem contador subindo.
`prefers-reduced-motion` zera as durações via tokens — não escreva media query própria.

---

## 8. Regras para agentes de IA

**Proibido**
1. Hex, `rgb()`, `hsl()` literal em qualquer arquivo que não seja `tokens.css`
2. Classe utilitária de cor arbitrária (`bg-[#017CEE]`, `text-slate-400`)
3. Espaçamento fora da escala (`padding: 13px`)
4. `box-shadow` fora dos três tokens (`card`, `pop`, `ring-focus`)
5. `border-radius` acima de 8px fora de `--gl-radius-pill`
6. Azul de marca usado como cor de estado
7. Estado de task que não exista em `airflow.utils.state`
8. Biblioteca de componentes nova sem decisão registrada
9. Emoji em UI de produto; gradiente em fundo ou botão
10. Estado comunicado só por cor
11. Barra de progresso percentual em qualquer lugar
12. Reprodução do logo do Apache Airflow ou de derivado próximo dele (ver §11)

**Obrigatório**
1. Todo componente novo entra neste documento **antes** do código
2. Todo número em lista, grid ou instrumento usa mono + `tabular-nums`
3. Todo controle interativo tem foco visível herdado de `:focus-visible`
4. Toda célula de estado tem glifo e `aria-label` com o estado por extenso
5. Toda decisão que contrarie este documento vira uma linha em `DECISIONS.md`

**Antes de abrir PR:**

```
/ds-check
```

Roda os quatro checks — cor literal fora dos tokens, `box-shadow` fora dos tokens, raio
acima de 8px, azul de marca como estado — em todo arquivo de fonte, mais a paridade
`tokens.css` ↔ `tokens.json` desta seção §12. Precisa passar.

A implementação é uma só, em `.claude/hooks/ds-rules.sh`, e um hook a aplica a cada arquivo
salvo. Os padrões cobrem também a grafia camelCase do JSX (`boxShadow`, `borderRadius`), que
a versão anterior deste bloco deixava passar.

---

## 9. Escrita

- Sentence case em títulos, botões e labels
- Verbo ativo dizendo o que acontece: `Disparar DAG`, não `Executar`
- O nome da ação é o mesmo do começo ao fim do fluxo
- **Use o vocabulário do Airflow, não sinônimos.** `task`, `DAG run`, `data logica`,
  `upstream`, `backfill`, `up_for_retry`. Traduzir esses termos afasta da transferência,
  que é o ponto do produto. Explicar na primeira aparição, sim; substituir, não
- Sem `simplesmente`, `apenas`, `é só`. Sem exclamação, sem emoji
- PT-BR e EN em paridade; texto de UI em arquivos de locale, nunca inline

---

## 10. Piso de qualidade

- [ ] Responsivo até 360px
- [ ] Navegação completa por teclado, com foco visível
- [ ] `prefers-reduced-motion` respeitado
- [ ] Contraste 4.5:1 em texto, 3:1 em glifos e bordas informativas
- [ ] Estado nunca comunicado só por cor
- [ ] Tema claro e escuro verificados na mesma tela
- [ ] Grid legível em simulação de deuteranopia e protanopia
- [ ] Sem CLS: grid e canvas reservam altura antes de montar
- [ ] Fontes com `font-display: swap` e fallback de sistema

---

## 11. Marca e uso do nome Airflow

Apache Airflow é marca da Apache Software Foundation. O Glider **não é** um projeto da
ASF e não pode sugerir endosso.

- Não use o logo do Airflow nem um cata-vento próximo o bastante para confundir. A marca
  do Glider é própria; o parentesco visual está na paleta e na estrutura, não no símbolo
- Descreva como "laboratórios para aprender Apache Airflow", nunca "Airflow Labs oficial"
- Inclua no rodapé: *Apache Airflow é marca registrada da Apache Software Foundation.
  Este projeto não é afiliado à ASF.*
- Herdar cores de estado de um projeto Apache-2.0 é uso legítimo; reproduzir identidade
  de marca é outra coisa. Antes de qualquer uso comercial, leia a política de marcas da ASF

---

## 12. Arquivos

```
CLAUDE.md               ← na RAIZ. Contrato curto, carregado em toda sessão
docs/design-system/
├─ DESIGN-SYSTEM.md   ← este arquivo, a fonte narrativa
├─ tokens.css         ← fonte única de verdade dos valores
├─ tokens.json        ← mesmos valores para Tailwind/Style Dictionary
└─ DECISIONS.md       ← registro de exceções e mudanças de rumo
```

`tokens.css` e `tokens.json` precisam ser gerados da mesma origem ou verificados em CI.
Se divergirem, `tokens.css` vence.
