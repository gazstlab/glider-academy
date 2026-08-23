# S14 · the run loop — retries, propagation and DAG run state

| | |
|---|---|
| Form | `06-feature` |
| Labels | `type/feature` `area/lab` `track/retries` `state/needs-verification` |
| Size | M |
| Branch | `feat/nn-run-loop` |

## Depends on
S13

## Unblocks
S15, S18, S30

## Context

The scheduler. This is the riskiest correctness surface in the product: state ×
trigger rule × retries remaining × upstream mix is combinatorial, and the output
is a grid of coloured squares that looks entirely plausible in almost every wrong
configuration. `upstream_failed` versus `failed` on a downstream task is one line
of code and the whole of lesson 04.

Two design choices are what make it testable at all, and neither is optional.
**The clock is injected** — `step(run, now, exec)` takes the time rather than
reading it — so a retry delay is a number in a test instead of a `setTimeout`.
And **execution is behind an interface**: `TaskExecutor` is supplied by the
caller, so the entire semantics layer is unit-tested with a fake and no Pyodide.
S18 later supplies the real one and this module does not change.

## Reading list
- `CLAUDE.md` § The rule that comes before the others
- `docs/orchestration/HANDOFF.md`
- `.claude/skills/airflow-truth/SKILL.md`
- `docs/design-system/DESIGN-SYSTEM.md` §3 — the states, §5.4 — what the grid shows

## Files
- `src/engine/run.ts`, `src/engine/run.test.ts` — new

## Do

1. Verify, and annotate, the semantics you are about to encode: what `retries`
   and `retry_delay` mean; that a task with retries left goes to `up_for_retry`
   and not `failed`; that a downstream of a failed task is `upstream_failed`;
   that a downstream of a skipped task under `all_success` is `skipped`; and when
   a DAG run itself is `failed` versus `success`.
2. `interface TaskInstance { taskId; state: TaskState; tryNumber; maxTries; startedAt; endedAt }`,
   `interface DagRun { runId; logicalDate; state: DagRunState; tis: Record<TaskId, TaskInstance> }`,
   `type RunEvent`, `type TaskExecutor = (ti: TaskInstance) => Promise<'success' | 'failed' | 'skipped'>`.
3. `createDagRun(dag, logicalDate)` and
   `step(run, now, exec): Promise<{ run: DagRun; events: RunEvent[] }>`. `step`
   is pure with respect to time: same inputs, same outputs.
4. Emit a `RunEvent` for every state transition and every log line. S25's RunLog
   and S21's GridView both read from this stream, so it is the only place
   ordering is decided.
5. Tests, with a fake executor and a hand-advanced clock: a happy chain; one
   failure with two retries succeeding on the third; retries exhausted;
   `upstream_failed` propagation two levels deep; skip propagation; a fan-in
   under `one_success`; and a DAG run that ends `failed` with a `success` task in
   it.

## Delivers

### Artifacts
`src/engine/run.ts`, `src/engine/run.test.ts`.

### Surface
Exports `interface TaskInstance`, `interface DagRun`, `type DagRunState`,
`type RunEvent`, `type TaskExecutor`, `createDagRun()`, `step()`.

### Invariants
- **No timers anywhere in `src/engine/`.** The clock is a parameter
- A task with retries remaining is `up_for_retry`, never `failed`
- A downstream of a failed task is `upstream_failed`, never `failed`
- Every transition emits exactly one `RunEvent`
- Nothing in `src/engine/` imports React or Pyodide

### Evidence
The unit run, with the named propagation cases visible in the output.

### Debt
`up_for_reschedule`, `deferred` and `restarting` are not produced by this loop —
no sensor and no trigger exists yet. They remain valid states in the type.

## Acceptance

| Command | Expected |
|---|---|
| `pnpm test src/engine/run.test.ts` | green, all seven scenarios |
| `rg -n 'setTimeout\|Date\.now' src/engine/` | no hits |
| `rg -c '# verified:' src/engine/run.ts` | ≥ 1 per encoded claim |
| `pnpm typecheck` | clean |

## Out of scope
- Pyodide, or any real execution — S18 supplies the executor
- React bindings — S15
- Any UI
