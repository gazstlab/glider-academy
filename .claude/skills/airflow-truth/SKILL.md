---
name: airflow-truth
description: Checks a claim about Apache Airflow's behaviour against the real source code before it becomes a Glider lesson, component or line of code. Use whenever you are about to state how Airflow behaves — states, trigger rules, logical date and cron, configuration precedence, executor lifecycle, scheduler, triggerer, what is core and what is a provider, or where a symbol lives. Use it even when you are certain: the certainty is the symptom, not the guarantee.
when_to_use: Before writing any claim about Airflow semantics in a lesson, component, code or answer. Also when reviewing lesson content, and whenever someone asks "does Airflow do X?".
allowed-tools: Bash(gh api:*)
---

# Never state Airflow behaviour from memory

Glider teaches. `DECISIONS.md` D18 is explicit: teaching something false is the
worst defect this product can have, because the learner carries the error into
their own production. A plausible false claim is worse than a gap.

Three traps, all of them hit for real while writing and testing this skill. All
three were made by a confident model — including the one that wrote this file.

## Trap 1 · "Airflow 3" is not an answer

`TriggerRule` changed homes **inside** the 3.x line, and its contents changed
with it:

| Tag | Path | Rules |
|---|---|---|
| `3.0.0` | `airflow-core/src/airflow/utils/trigger_rule.py` | 12 |
| `3.1.0`+ | `airflow-core/src/airflow/task/trigger_rule.py` | 13 (`ALL_DONE_MIN_ONE_SUCCESS` enters) |

Anyone answering "Airflow 3 has 13 trigger rules" is right from 3.1 onward and
wrong on 3.0. **Pin the minor, not the major**, and say in the lesson which
version the fact holds from.

## Trap 2 · A file moved ≠ the import broke

Two cases that look identical and behave in opposite ways:

| Old import | Old file still exists? | Resolves in 3.3.1? | Why |
|---|---|---|---|
| `from airflow.utils.trigger_rule import TriggerRule` | no | **yes**, with a `DeprecationWarning` | `airflow/utils/__init__.py` maps `"trigger_rule": {"*": "airflow.task.trigger_rule"}` via `add_deprecated_classes` |
| `from airflow.executors.celery_executor import CeleryExecutor` | no | **no**, `ImportError` | `airflow/executors/__init__.py` has no shim |

You cannot infer one from the other. The answer lives in the package's
`__init__.py`, case by case. Teaching the deprecated path produces people who
write code that warns; teaching that it broke produces people who migrate
urgently for no reason. Both are wrong, in different directions.

## Trap 3 · In Airflow 3 the same concept exists twice, and one copy is hollow

The most treacherous one, and the one that matters most to Glider. Airflow 3
split authoring (Task SDK) from execution (core). Timetables exist **in both
trees, with the same class names** — and it is easy to conclude they "moved to
the task-sdk". The surface moved; the algorithm did not.

| | `task-sdk/.../definitions/timetables/` | `airflow-core/src/airflow/timetables/` |
|---|---|---|
| Role | the declarative surface a DAG author writes | the algorithm |
| `_cron.py` | ~2 KB: `CronMixin` with `expression`, `timezone`, `validate()`, presets | ~8 KB: `_get_next`/`_get_prev`, `_align_to_next`/`_align_to_prev`, DST |
| `base.py` | **does not exist** | `DataInterval`, `TimeRestriction`, `DagRunInfo`, `next_dagrun_info` |
| Class bodies | `class CronDataIntervalTimetable(CronMixin, BaseTimetable): ...` | the real implementation |

The SDK's `BaseTimetable` has only `validate()` and attributes — no
`next_dagrun_info`. And `class DataInterval` is defined in **exactly one file in
the whole repository**: `airflow-core/src/airflow/timetables/base.py`.

The practical consequence, and it is the opposite of what intuition suggests:
**anything that needs to compute when the next run happens wants the core
tree**, even when it is interpreting the learner's DAG. The SDK tree only exists
to mirror the API the learner imports and writes.

The general lesson: when you think a concept "moved packages" in Airflow 3,
check whether it does not exist in both — and, if it does, **which of the two
holds the code**. File size and the presence of `base.py` give it away fast.

## Target

**Airflow 3.x.** The repository's tags are the bare number, with no `v`. To find
the current stable instead of trusting a number written here:

```bash
gh api "repos/apache/airflow/releases?per_page=30" \
  --jq '[.[]|select(.prerelease==false)|.tag_name|select(test("^3\\."))][0]'
```

## How to check, cheaply

`gh` is authenticated and pre-approved in this skill. Ask for the **raw** file
and filter, instead of dumping the whole file into context:

```bash
gh api "repos/apache/airflow/contents/<path>?ref=<tag>" \
  -H "Accept: application/vnd.github.raw" | rg '<pattern>'
```

The `Accept: application/vnd.github.raw` header avoids the contents API's
base64. Example — which trigger rules actually exist:

```bash
gh api "repos/apache/airflow/contents/airflow-core/src/airflow/task/trigger_rule.py?ref=3.3.1" \
  -H "Accept: application/vnd.github.raw" | rg '^\s+[A-Z_]+ = '
```

Thirteen lines instead of a file. Verifying has to be cheap, otherwise you skip
it — and skipping is what this skill exists to prevent.

When the path is not obvious, or to check whether a symbol lives in more than
one place:

```bash
gh api "search/code?q=filename:<file>+repo:apache/airflow" --jq '.items[].path'
```

**Shell warning:** in zsh, `path` is tied to `$PATH`. A loop using
`for path in ...` destroys `PATH` and every command starts failing silently,
which looks like "the file does not exist". Use another variable name.

## Where things live (verified at 3.3.1)

| Subject | Path |
|---|---|
| Task and DAG run states | `airflow-core/src/airflow/utils/state.py` |
| Trigger rules | `airflow-core/src/airflow/task/trigger_rule.py` (3.1+; see Trap 1) |
| Trigger rule semantics | `airflow-core/src/airflow/ti_deps/deps/trigger_rule_dep.py` — this is what actually decides |
| Timetables, cron, data interval | **both sides**, see Trap 3 |
| DAG, TaskGroup, params, XCom (authoring) | `task-sdk/src/airflow/sdk/definitions/` |
| Configuration defaults | `airflow-core/src/airflow/config_templates/config.yml` |
| Scheduler, triggerer, dag-processor | `airflow-core/src/airflow/jobs/` |
| LocalExecutor and base | `airflow-core/src/airflow/executors/` |
| CeleryExecutor | `providers/celery/src/airflow/providers/celery/executors/` |
| KubernetesExecutor, KubernetesPodOperator | `providers/cncf/kubernetes/src/airflow/providers/cncf/kubernetes/` |

Celery and Kubernetes are **not** in core — they are providers. But the **alias**
stays in core: `executor_constants.py` lists `CORE_EXECUTOR_NAMES` and
`executor_loader.py` maps the short name to the provider module. So
`AIRFLOW__CORE__EXECUTOR: CeleryExecutor` is still correct, and concluding "it
became a provider, therefore I need the dotted path" is being wrong in the other
direction. The summary that fits in a lesson: **code in the provider, name in
the core.**

If a path 404s, it moved between versions. Find it with `search/code` and **fix
this table**: a skill that lies about where the truth lives is worse than no
skill at all.

For behaviour that is documented rather than implemented:
`https://airflow.apache.org/docs/apache-airflow/<version>/`, always with the
version in the URL.

## What is NOT a source of truth

- **Your memory.** It is the reason this skill exists.
- **The `data-engineering:*` skills in this environment.** They operate somebody's
  real Airflow. They are an operations tool, not a specification of what Glider
  teaches.
- Blogs, tutorials, StackOverflow. They point the way; they do not settle it.
- Documentation without a version in the URL. And note that Airflow's own docs
  still use `airflow.utils.trigger_rule` in `faq.rst` — not even the official
  example is an arbiter.

## When writing

Record what you checked against, next to the claim:

```
# verified: airflow-core/src/airflow/task/trigger_rule.py @ 3.3.1
```

This is not paperwork: it is what makes it possible to re-verify in bulk when
Glider moves its target version, instead of re-reading everything.

If you could not verify it, **say so in the text** instead of asserting it. An
honest gap is recoverable; a false claim wearing the face of certainty is not.
