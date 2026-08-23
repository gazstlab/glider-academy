# S15 · bind a DAG run to React

| | |
|---|---|
| Form | `06-feature` |
| Labels | `type/feature` `area/lab` |
| Size | S |
| Branch | `feat/nn-use-dag-run` |

## Depends on
S14

## Unblocks
S21, S22, S25, S26, S32

## Context

The engine is deliberately React-free. This is the one module that joins them,
and it is separate so that the join can be replaced or tested without touching
the semantics.

The performance constraint is real rather than theoretical: a DAG run ticks
several times a second, and a naive `useState` re-renders every cell in the grid
on every tick. `useSyncExternalStore` over an external store lets a cell
subscribe to its own task instance, so a tick repaints the squares that changed.

## Reading list
- `CLAUDE.md`
- `docs/orchestration/HANDOFF.md`
- `docs/design-system/DESIGN-SYSTEM.md` §5.4, §7 — what actually needs to repaint

## Files
- `src/engine/store.ts`, `src/engine/useDagRun.ts` — new
- `src/engine/useDagRun.test.tsx` — new

## Do

1. `createRunStore(dag)` — an external store holding the current `DagRun` and the
   `RunEvent` buffer, with `subscribe`/`getSnapshot`, and per-task subscription
   so a cell can listen to one `TaskInstance`.
2. `useDagRun(dag)` returning
   `{ run, events, trigger(), stop(), isRunning }`. `trigger()` drives `step()`
   on a real clock; `stop()` sets the stop flag that S19 wires to the interrupt
   buffer.
3. Snapshots are stable references when nothing changed — otherwise
   `useSyncExternalStore` loops.
4. Tests with a fake executor: a full run drives states through to completion;
   subscribing to one task does not notify on an unrelated task's transition.

## Delivers

### Artifacts
The three files above.

### Surface
`src/engine/store.ts` exports `createRunStore()`. `src/engine/useDagRun.ts`
exports `useDagRun()`.

### Invariants
- `src/engine/run.ts` and `graph.ts` stay React-free; only this module bridges
- A tick does not re-render tasks that did not change
- `stop()` is safe to call when nothing is running

### Evidence
The unit run, including the selective-notification case.

### Debt
`stop()` only sets a flag. S19 makes it reach the worker.

## Acceptance

| Command | Expected |
|---|---|
| `pnpm test src/engine/useDagRun.test.tsx` | green |
| `pnpm typecheck` | clean |
| `bash .claude/skills/ds-check/ds-check.sh` | PASSED |

## Out of scope
- Pyodide — S16 to S19
- Any component
