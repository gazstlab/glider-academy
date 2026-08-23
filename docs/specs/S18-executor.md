# S18 · execute a task callable and stream its log

| | |
|---|---|
| Form | `06-feature` |
| Labels | `type/feature` `area/lab` |
| Size | S |
| Branch | `feat/nn-executor` |

## Depends on
S14, S17

## Unblocks
S32

## Context

The join between the two halves. S14 defined `TaskExecutor` and tested the whole
scheduler against a fake one; this spec supplies the real one. **The engine does
not change** — that was the point of injecting the interface, and if this spec
finds itself editing `src/engine/`, something upstream was wrong.

The mapping from a Python exception to a task state is a semantic claim like any
other and gets verified: `AirflowSkipException` produces `skipped`, and any other
exception produces `failed`.

## Reading list
- `CLAUDE.md`
- `docs/orchestration/HANDOFF.md`
- `docs/specs/S14-run-loop.md` § Delivers — the `TaskExecutor` and `RunEvent` shapes
- `docs/design-system/DESIGN-SYSTEM.md` §5.8 — what RunLog will render
- `.claude/skills/airflow-truth/SKILL.md`

## Files
- `src/runtime/executor.ts`, `src/runtime/executor.test.ts` — new
- `src/runtime/client.ts` — implement `runTask`
- `src/runtime/worker.ts` — stdout/stderr capture

## Do

1. Capture stdout and stderr per task in the worker and emit them as
   `RunEvent { kind: 'log' }` with a level and a timestamp, so RunLog and the
   grid read one ordered stream.
2. `pyodideExecutor(rt: PythonRuntime): TaskExecutor` — satisfies S14's interface
   exactly.
3. Verify and annotate the exception mapping. On `failed`, carry the last
   traceback frame in the event: §5.10 says an error names what broke and what to
   do, and a bare "failed" names neither.
4. Tests: a callable that prints and returns; one that raises; one that raises
   `AirflowSkipException`; and a run driven end to end through `step()` with the
   real executor, asserting the same states the fake produced in S14.

## Delivers

### Artifacts
The file list above.

### Surface
`src/runtime/executor.ts` exports `pyodideExecutor()`.
`src/runtime/client.ts` — `runTask` resolves.

### Invariants
- **`src/engine/` is not modified by this spec**
- Every task's output is attributed to that task — no interleaving between tasks
- `AirflowSkipException` → `skipped`; any other exception → `failed` with a frame

### Evidence
The executor tests, including the end-to-end run matching S14's expectations.

### Debt
Log output is buffered per task rather than streamed line by line while a task
runs. S25 records whether RunLog needs finer granularity.

## Acceptance

| Command | Expected |
|---|---|
| `pnpm test src/runtime/executor.test.ts` | green |
| `git diff --name-only main...HEAD -- src/engine/` | empty |
| `rg -c '# verified:' src/runtime/executor.ts` | ≥ 1 |
| `pnpm typecheck` | clean |

## Out of scope
- Editing `src/engine/`. If it seems necessary, that is `BLOCKED`
- Interruption — S19
- Any UI
