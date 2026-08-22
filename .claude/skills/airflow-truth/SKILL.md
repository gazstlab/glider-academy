---
name: airflow-truth
description: Confere uma afirmação sobre o comportamento do Apache Airflow contra o código-fonte real antes de ela virar lição, componente ou código do Glider. Use sempre que estiver prestes a dizer como o Airflow se comporta — estados, trigger rules, data lógica e cron, precedência de configuração, ciclo de vida de executor, scheduler, triggerer, o que é core e o que é provider, ou onde um símbolo mora. Use inclusive quando tiver certeza: a certeza é o sintoma, não a garantia.
when_to_use: Antes de escrever qualquer afirmação sobre semântica do Airflow em lição, componente, código ou resposta. Também ao revisar conteúdo de lição, e quando alguém perguntar "o Airflow faz X?".
allowed-tools: Bash(gh api:*)
---

# Não afirme comportamento do Airflow de memória

O Glider ensina. `DECISIONS.md` D18 é explícito: ensinar errado é o pior defeito possível
neste produto. Uma afirmação plausível e falsa é pior que uma lacuna, porque o aluno leva
o erro para a produção dele.

Três armadilhas, todas encontradas de verdade ao escrever e testar esta skill. As três
foram cometidas por um modelo confiante — inclusive o que escreveu este arquivo.

## Armadilha 1 · "Airflow 3" não é uma resposta

`TriggerRule` mudou de casa **dentro** da linha 3.x, e o conteúdo mudou junto:

| Tag | Caminho | Regras |
|---|---|---|
| `3.0.0` | `airflow-core/src/airflow/utils/trigger_rule.py` | 12 |
| `3.1.0`+ | `airflow-core/src/airflow/task/trigger_rule.py` | 13 (entra `ALL_DONE_MIN_ONE_SUCCESS`) |

Quem responde "no Airflow 3 são 13 trigger rules" acerta a partir de 3.1 e erra no 3.0.
**Fixe a minor, não a major**, e diga na lição a partir de qual versão o fato vale.

## Armadilha 2 · Arquivo mudou de lugar ≠ import quebrou

Dois casos que parecem idênticos e se comportam ao contrário:

| Import antigo | Arquivo antigo existe? | Resolve em 3.3.1? | Por quê |
|---|---|---|---|
| `from airflow.utils.trigger_rule import TriggerRule` | não | **sim**, com `DeprecationWarning` | `airflow/utils/__init__.py` mapeia `"trigger_rule": {"*": "airflow.task.trigger_rule"}` via `add_deprecated_classes` |
| `from airflow.executors.celery_executor import CeleryExecutor` | não | **não**, `ImportError` | `airflow/executors/__init__.py` não tem shim |

Não dá para inferir um do outro. A resposta mora no `__init__.py` do pacote, caso a caso.
Ensinar o caminho depreciado forma gente que escreve código com warning; ensinar que ele
quebrou forma gente que migra com urgência sem motivo. Os dois erram, de formas diferentes.

## Armadilha 3 · No Airflow 3 o mesmo conceito existe duas vezes, e uma delas é oca

A mais traiçoeira, e a que mais importa para o Glider. O Airflow 3 separou autoria (Task
SDK) de execução (core). Timetables existem **nas duas árvores, com os mesmos nomes de
classe** — e é fácil concluir que "mudaram para o task-sdk". Mudou a superfície; o
algoritmo não saiu do lugar.

| | `task-sdk/.../definitions/timetables/` | `airflow-core/src/airflow/timetables/` |
|---|---|---|
| Papel | superfície declarativa que o autor de DAG escreve | o algoritmo |
| `_cron.py` | ~2 KB: `CronMixin` com `expression`, `timezone`, `validate()`, presets | ~8 KB: `_get_next`/`_get_prev`, `_align_to_next`/`_align_to_prev`, DST |
| `base.py` | **não existe** | `DataInterval`, `TimeRestriction`, `DagRunInfo`, `next_dagrun_info` |
| Corpo das classes | `class CronDataIntervalTimetable(CronMixin, BaseTimetable): ...` | implementação real |

`BaseTimetable` do SDK tem só `validate()` e atributos — nenhum `next_dagrun_info`. E
`class DataInterval` é definida em **um único arquivo do repositório inteiro**:
`airflow-core/src/airflow/timetables/base.py`.

Consequência prática, e é o oposto do que a intuição sugere: **qualquer coisa que precise
calcular quando o próximo run acontece quer a árvore do core**, mesmo que esteja
interpretando o DAG do aluno. A árvore do SDK só serve para espelhar a API que o aluno
importa e escreve.

A lição geral: quando achar que um conceito "mudou de pacote" no Airflow 3, verifique se
ele não existe nos dois — e, se existir, **qual dos dois tem o código**. Tamanho de arquivo
e presença de `base.py` entregam rápido.

## Alvo

**Airflow 3.x.** As tags do repositório são o número nu, sem `v`. Para descobrir a estável
atual em vez de confiar num número escrito aqui:

```bash
gh api "repos/apache/airflow/releases?per_page=30" \
  --jq '[.[]|select(.prerelease==false)|.tag_name|select(test("^3\\."))][0]'
```

## Como conferir, barato

`gh` está autenticado e pré-aprovado nesta skill. Peça o arquivo **cru** e filtre, em vez de
despejar o arquivo inteiro no contexto:

```bash
gh api "repos/apache/airflow/contents/<caminho>?ref=<tag>" \
  -H "Accept: application/vnd.github.raw" | rg '<padrão>'
```

O `Accept: application/vnd.github.raw` evita o base64 da API de conteúdo. Exemplo — quais
trigger rules existem de fato:

```bash
gh api "repos/apache/airflow/contents/airflow-core/src/airflow/task/trigger_rule.py?ref=3.3.1" \
  -H "Accept: application/vnd.github.raw" | rg '^\s+[A-Z_]+ = '
```

Treze linhas em vez de um arquivo. Verificar tem de ser barato, senão você pula — e pular é
o que esta skill existe para impedir.

Quando o caminho não for óbvio, ou para checar se o símbolo existe em mais de um lugar:

```bash
gh api "search/code?q=filename:<arquivo>+repo:apache/airflow" --jq '.items[].path'
```

**Cuidado com o shell:** em zsh, `path` é ligado a `$PATH`. Um laço com `for path in ...`
destrói o `PATH` e todos os comandos passam a falhar em silêncio, o que parece "o arquivo
não existe". Use outro nome de variável.

## Onde as coisas moram (verificado em 3.3.1)

| Assunto | Caminho |
|---|---|
| Estados de task e de DAG run | `airflow-core/src/airflow/utils/state.py` |
| Trigger rules | `airflow-core/src/airflow/task/trigger_rule.py` (3.1+; ver Armadilha 1) |
| Semântica de trigger rule | `airflow-core/src/airflow/ti_deps/deps/trigger_rule_dep.py` — é quem decide de fato |
| Timetables, cron, data interval | **os dois lados**, ver Armadilha 3 |
| DAG, TaskGroup, params, XCom (autoria) | `task-sdk/src/airflow/sdk/definitions/` |
| Defaults de configuração | `airflow-core/src/airflow/config_templates/config.yml` |
| Scheduler, triggerer, dag-processor | `airflow-core/src/airflow/jobs/` |
| LocalExecutor e base | `airflow-core/src/airflow/executors/` |
| CeleryExecutor | `providers/celery/src/airflow/providers/celery/executors/` |
| KubernetesExecutor, KubernetesPodOperator | `providers/cncf/kubernetes/src/airflow/providers/cncf/kubernetes/` |

Celery e Kubernetes **não** estão no core — são providers. Mas o **alias** continua no core:
`executor_constants.py` lista `CORE_EXECUTOR_NAMES` e `executor_loader.py` mapeia o nome curto
para o módulo do provider. Então `AIRFLOW__CORE__EXECUTOR: CeleryExecutor` continua certo, e
concluir "virou provider, logo preciso do caminho pontilhado" é errar para o outro lado.
Resumo que cabe numa lição: **código no provider, nome no core.**

Se um caminho der 404, ele mudou entre versões. Ache com `search/code` e **corrija esta
tabela**: skill que mente sobre onde a verdade mora é pior que skill nenhuma.

Para comportamento documentado em vez de implementado:
`https://airflow.apache.org/docs/apache-airflow/<versão>/`, sempre com a versão na URL.

## O que NÃO é fonte de verdade

- **Sua memória.** É o motivo desta skill existir.
- **As skills `data-engineering:*` deste ambiente.** Operam um Airflow real, de alguém. São
  ferramenta de operação, não especificação do que o Glider ensina.
- Blog, tutorial, StackOverflow. Apontam o caminho; não fecham a questão.
- Documentação sem versão na URL. E note que a doc oficial do próprio Airflow ainda usa
  `airflow.utils.trigger_rule` em `faq.rst` — nem o exemplo oficial é árbitro.

## Ao escrever

Registre contra o que conferiu, ao lado da afirmação:

```
# verificado: airflow-core/src/airflow/task/trigger_rule.py @ 3.3.1
```

Não é burocracia: é o que permite re-verificar em bloco quando o Glider subir de versão-alvo,
em vez de reler tudo.

Se não deu para verificar, **diga isso no texto** em vez de afirmar. Uma lacuna honesta é
recuperável; uma afirmação falsa com cara de certeza, não.
