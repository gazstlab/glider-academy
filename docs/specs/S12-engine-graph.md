# S12 · the DAG graph — parse, topological order, cycle detection

| | |
|---|---|
| Form | `06-feature` |
| Labels | `type/feature` `area/lab` |
| Size | S |
| Branch | `feat/nn-engine-graph` |

## Depends on
S09

## Unblocks
S13, S17, S22

## Context

The first piece of the engine. Airflow's semantics live in TypeScript in this
product — Python only parses the learner's file and executes their callables —
and this is the layer everything else sits on: the structure, the ordering, and
the refusal to run a graph that is not one.

The decision behind that split is worth carrying: with the scheduler in
TypeScript, every trigger rule and every retry path is unit-testable in
milliseconds with a fake executor and no WebAssembly. In Python it would cost a
Pyodide boot per case and would end up untested — which, for a product whose
worst defect is teaching something false, is not a trade available to us.

`DagDef` is the boundary type. S17's Python shim serialises to exactly this
shape, so it has to stay plain data — ids, not object references — and survive a
`structuredClone` across the worker boundary.

## Reading list
- `CLAUDE.md`
- `docs/orchestration/HANDOFF.md`
- `README.md` § Stack
- `docs/design-system/DESIGN-SYSTEM.md` §2 — the grid the structure feeds

## Files
- `src/engine/graph.ts`, `src/engine/graph.test.ts` — new

## Do

1. `interface TaskDef { id: TaskId; upstream: TaskId[]; triggerRule: TriggerRule; retries: number; retryDelayMs: number }`
   and `interface DagDef { dagId: string; schedule: string | null; tasks: TaskDef[] }`.
   `TriggerRule` is a bare string here; S13 narrows it. Plain data only.
2. `buildGraph(d)`, `topoOrder(g)`, `detectCycle(g)`, `downstreamOf(g, id)`,
   `upstreamOf(g, id)`.
3. `topoOrder` **throws** on a cycle rather than returning a partial order. A
   partial order renders as a grid that looks fine and is wrong, which is the
   failure mode this product cannot ship.
4. `detectCycle` returns the participating ids, so the lab can eventually name
   them in an error rather than saying something broke.
5. Tests: a diamond, a chain, a fan-out, a fan-in, a self-loop, a two-node cycle,
   an isolated task, an empty DAG, and an `upstream` id that does not exist.

## Delivers

### Artifacts
`src/engine/graph.ts`, `src/engine/graph.test.ts`.

### Surface
Exports `type TaskId`, `interface TaskDef`, `interface DagDef`, `interface Graph`,
`buildGraph()`, `topoOrder()`, `detectCycle()`, `downstreamOf()`, `upstreamOf()`.

### Invariants
- `topoOrder` throws on a cyclic graph
- `TaskDef.upstream` holds ids, never references — `DagDef` stays
  `structuredClone`-safe across the worker boundary
- Nothing in `src/engine/` imports React

### Evidence
The unit run.

### Debt
Setup and teardown relationships are not modelled. S13 decides whether they are
needed; lesson 04 does not use them.

## Acceptance

| Command | Expected |
|---|---|
| `pnpm test src/engine/graph.test.ts` | green, all nine shapes |
| `pnpm typecheck` | clean |
| `rg -n "from 'react'" src/engine/` | no hits |
| `bash .claude/skills/ds-check/ds-check.sh` | PASSED |

## Out of scope
- Trigger rules — S13
- Task state or execution — S14
- Anything that imports React or touches the DOM
