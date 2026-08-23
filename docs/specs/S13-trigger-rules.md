# S13 · evaluate the 13 trigger rules against upstream state

| | |
|---|---|
| Form | `06-feature` |
| Labels | `type/feature` `area/lab` `track/dependencies` `state/needs-verification` |
| Size | M |
| Branch | `feat/nn-trigger-rules` |

## Depends on
S12

## Unblocks
S14, S31

## Context

Trigger rules are what lesson 04 teaches, so this is the spec where being
approximately right is indistinguishable from being wrong. A rule that quietly
returns "run" when real Airflow would skip produces a grid that looks plausible
and teaches the opposite of the truth.

Two files have to be read, not one. `trigger_rule.py` says **what the rules
are**; `ti_deps/deps/trigger_rule_dep.py` says **what "done" means and what state
a blocked task lands in** — and the second is where the semantics actually live.
The enum alone will let you write something confident and wrong.

There is a version trap the skill calls out explicitly: at 3.0.0 there are twelve
rules at `utils/trigger_rule.py`; from 3.1.0 there are thirteen at
`task/trigger_rule.py`, with `ALL_DONE_MIN_ONE_SUCCESS` added. Pin the minor.

Setup and teardown rules are not implemented. They return `unsupported` and the
caller surfaces that honestly. An honest gap is recoverable; a fake
implementation of a rule the learner might try is not.

## Reading list
- `CLAUDE.md` § The rule that comes before the others
- `docs/orchestration/HANDOFF.md`
- `.claude/skills/airflow-truth/SKILL.md` — the whole procedure, and its trap 1
- `docs/design-system/DESIGN-SYSTEM.md` §3 — the state table

## Files
- `src/engine/triggerRules.ts`, `src/engine/triggerRules.test.ts` — new
- `src/engine/graph.ts` — narrow `TriggerRule` to the union
- `docs/design-system/DECISIONS.md` — one row, **D23**

## Do

1. **Verify before writing a line.** Read
   `airflow-core/src/airflow/task/trigger_rule.py @ 3.3.1` for the membership,
   and `airflow-core/src/airflow/ti_deps/deps/trigger_rule_dep.py @ 3.3.1` for
   the behaviour. Record both paths.
2. `type TriggerRule` as the exact thirteen, annotated
   `// verified: airflow-core/src/airflow/task/trigger_rule.py @ 3.3.1`.
3. `interface UpstreamCounts { total; success; failed; skipped; upstreamFailed; done }`
   and
   `evaluateTriggerRule(rule, counts): 'run' | 'skip' | 'upstream_failed' | 'wait' | 'unsupported'`.
4. A table test: every rule × the upstream mixes that distinguish it. The
   distinction that matters most for lesson 04 — a failed upstream under
   `all_success` yields `upstream_failed`, not `failed` — gets its own named case.
5. Setup/teardown rules return `unsupported`. Write **D23** recording that, with
   the reason and the discarded alternative (implementing them from the docs).

## Delivers

### Artifacts
The file list above.

### Surface
Exports `TRIGGER_RULES`, `type TriggerRule`, `interface UpstreamCounts`,
`evaluateTriggerRule()`.

### Invariants
- Exactly thirteen rules, matching 3.3.1
- Every rule carries its `# verified:` annotation
- An unimplemented rule returns `unsupported` and is never silently treated as
  `run`

### Evidence
The `/airflow-truth` transcript for both paths, and the table test.

### Debt
Setup and teardown semantics — recorded in D23, not owed to a later spec in this
queue.

## Acceptance

| Command | Expected |
|---|---|
| `pnpm test src/engine/triggerRules.test.ts` | green, every rule covered |
| `rg -c '# verified:.*trigger_rule.py @ 3.3.1' src/engine/triggerRules.ts` | ≥ 1 |
| `rg -n '\| D23 ' docs/design-system/DECISIONS.md` | one row |
| `pnpm typecheck` | clean |

## Out of scope
- The run loop, retries, propagation — S14
- Any UI
- Implementing setup/teardown rules
