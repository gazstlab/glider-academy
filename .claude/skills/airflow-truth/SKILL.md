---
name: airflow-truth
description: Procedimento para conferir uma afirmação sobre o comportamento do Apache Airflow contra a fonte real antes de escrevê-la numa lição, num componente ou no código do Glider. Use sempre que estiver prestes a afirmar como o Airflow se comporta — estados, trigger rules, data lógica e cron, precedência de configuração, ciclo de vida de executor, scheduler ou triggerer.
when_to_use: Antes de escrever qualquer afirmação sobre semântica do Airflow. Também quando estiver revisando conteúdo de lição, ou quando alguém perguntar "o Airflow faz X?".
---

# Não afirme comportamento do Airflow de memória

O Glider ensina. `DECISIONS.md` D18 é explícito: ensinar errado é o pior defeito possível
neste produto. Uma afirmação plausível e falsa é pior que uma lacuna, porque o aluno leva
o erro para a produção dele.

Modelos têm memória confiante e desatualizada sobre o Airflow, e a linha 2.x → 3.x moveu
muita coisa de lugar. Exemplo real, verificado ao escrever esta skill: `TriggerRule` **não**
está em `airflow/utils/trigger_rule.py` no Airflow 3, apesar de ser o caminho que quase
todo mundo lembra. Está em `airflow-core/src/airflow/task/trigger_rule.py`.

## Alvo

**Airflow 3.x.** Última estável verificada: **3.3.1**. As tags do repositório são o número
nu, sem `v` (`3.3.1`, não `v3.3.1`).

Fixe a tag ao consultar. `main` se move e não é o que o aluno vai rodar.

## Como conferir

`gh` está autenticado neste ambiente. É o caminho mais barato:

```bash
# ler um arquivo numa tag fixa
gh api repos/apache/airflow/contents/<caminho>?ref=3.3.1 --jq '.content' | base64 -d

# achar onde algo mora, quando o caminho não é óbvio
gh api "search/code?q=filename:<arquivo>+repo:apache/airflow" --jq '.items[].path'
```

## Onde as coisas moram (caminhos verificados, Airflow 3)

| Assunto | Caminho |
|---|---|
| Estados de task e de DAG run | `airflow-core/src/airflow/utils/state.py` |
| Trigger rules | `airflow-core/src/airflow/task/trigger_rule.py` |
| Timetables, cron, data interval | `task-sdk/src/airflow/sdk/definitions/timetables/` (`_cron.py`, `_delta.py`, `interval.py`, `simple.py`, `events.py`) |
| Definição de DAG, TaskGroup, params, XCom | `task-sdk/src/airflow/sdk/definitions/` |
| Defaults de configuração | `airflow-core/src/airflow/config_templates/config.yml` |
| Scheduler, triggerer, dag-processor | `airflow-core/src/airflow/jobs/` (`scheduler_job_runner.py`, `triggerer_job_runner.py`, `dag_processor_job_runner.py`) |
| LocalExecutor e base | `airflow-core/src/airflow/executors/` |
| CeleryExecutor | `providers/celery/src/airflow/providers/celery/executors/` |
| KubernetesExecutor, KubernetesPodOperator | `providers/cncf/kubernetes/src/airflow/providers/cncf/kubernetes/` |

Repare que Celery e Kubernetes **não** estão no core no Airflow 3 — são providers. Isso é
conteúdo de lição por si só, e é o tipo de coisa que a memória erra.

Para comportamento documentado em vez de implementado, use
`https://airflow.apache.org/docs/apache-airflow/3.3.1/`, sempre com a versão na URL.

## O que NÃO é fonte de verdade

- **Sua memória.** É o motivo desta skill existir.
- **As skills `data-engineering:*` deste ambiente.** Elas operam um Airflow real, de
  alguém. São ferramenta de operação, não especificação do que o Glider ensina. Confundir
  as duas é o modo de falha mais sutil que existe aqui.
- Blog, StackOverflow, tutorial. Podem apontar o caminho; não fecham a questão.
- Documentação sem versão na URL.

## Ao escrever

Registre contra o que conferiu, ao lado da afirmação — no comentário do código, ou no
front-matter da lição:

```
# verificado: airflow-core/src/airflow/task/trigger_rule.py @ 3.3.1
```

Se não deu para verificar, **diga isso no texto** em vez de afirmar. Uma lacuna honesta é
recuperável; uma afirmação falsa com cara de certeza, não.
