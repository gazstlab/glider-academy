# S17 · the Python airflow shim that turns a lesson DAG into JSON

| | |
|---|---|
| Form | `06-feature` |
| Labels | `type/feature` `area/lab` `state/needs-verification` |
| Size | M |
| Branch | `feat/nn-airflow-shim` |

## Depends on
S12, S16

## Unblocks
S18, S31

## Context

**This is the riskiest spec in the queue**, and the risk is not that it fails. It
is that it passes while teaching a false API.

If the shim accepts `from airflow.operators.python import PythonOperator` because
that is what Airflow 2 looked like, the learner writes it, sees a green grid, and
memorises an import path that does not exist at 3.3.1. Transfer — the stated
point of the entire product, the reason we inherit ugly state colours and refuse
to translate `up_for_retry` — inverts. `README.md` names this defect class as the
worst one there is, and this is the file where it would happen.

The reorganisation between Airflow 2 and 3 is exactly the kind memory gets wrong:
`airflow.sdk` is new, several operators moved to `providers/standard`, and being
confident about any of it is the symptom rather than the guarantee.

So the shim is minimal and loud. It implements what lesson 04 needs, and anything
else raises `GliderUnsupportedError` naming the symbol. A silent no-op would be
the same defect wearing a different face.

## Reading list
- `CLAUDE.md` § The rule that comes before the others
- `docs/orchestration/HANDOFF.md`
- `.claude/skills/airflow-truth/SKILL.md` — the whole file, including the traps
- `docs/specs/S12-engine-graph.md` § Delivers — the `DagDef` shape to emit
- `README.md` § Teaching wrong is the worst defect

## Files
- `python/glider_airflow/__init__.py`, `dag.py`, `operators.py`, `exceptions.py`,
  `serialize.py` — new
- `src/runtime/worker.ts` — mount the package into Pyodide's filesystem
- `src/runtime/client.ts` — implement `parseDag`
- `src/runtime/parseDag.test.ts` — new

## Do

1. **Verify each of these before writing it.** What `airflow.sdk` exports at
   3.3.1 — `DAG` is there; check `dag`, `task`, `chain`. Where `PythonOperator`
   and `EmptyOperator` live at 3.3.1: core or `providers/standard`. Whether
   `>>` and `<<` are on `BaseOperator` and what they return. Record every path
   and tag.
2. Implement the smallest surface lesson 04 needs, matching the verified import
   paths exactly. Annotate every symbol `# verified: <path> @ 3.3.1`.
3. `exceptions.py`: `GliderUnsupportedError`, raised by name for anything not
   implemented, with a message saying which lesson covers it or that it is not
   covered. `__getattr__` at module level so an unknown import raises rather than
   returning `None`.
4. `serialize.py` emits exactly S12's `DagDef` — same field names, same types,
   ids not references.
5. Wire `parseDag(src)` in the client. Tests run through the worker: a valid
   lesson-04 DAG serialises to the expected `DagDef`; an Airflow 2 import path
   raises `GliderUnsupportedError`; a syntax error surfaces the Python message
   rather than a generic failure.

There is no `pytest` among the five CI scripts and adding one would break the
`preflight` contract. The Python is tested through the worker, from Vitest.

## Delivers

### Artifacts
The file list above.

### Surface
`python/glider_airflow/` — the verified import surface.
`src/runtime/client.ts` — `parseDag(src: string): Promise<DagDef>` now resolves.

### Invariants
- Every symbol carries `# verified: <path> @ 3.3.1`
- **An unimplemented symbol raises. Never a silent no-op, never `None`**
- The import paths are the 3.3.1 paths. An Airflow 2 path is an error, not an alias
- `serialize.py` output validates against S12's `DagDef`

### Evidence
The `/airflow-truth` transcript for every symbol, and the worker tests.

### Debt
Everything not in lesson 04 — sensors, task groups, XCom, timetables — raises.
Each is owed to the lesson that introduces it, not to this queue.

## Acceptance

| Command | Expected |
|---|---|
| `pnpm test src/runtime/parseDag.test.ts` | green, including the raise cases |
| `rg -c '# verified:' python/glider_airflow/` | one per public symbol |
| `rg -n 'airflow.operators.python' python/ src/` | no hits except as a rejected path in a test |
| `pnpm build && pnpm test:e2e e2e/runtime.spec.ts` | still ready from `dist/` |

## Out of scope
- Executing a task callable — S18
- The interrupt buffer — S19
- Any symbol lesson 04 does not use. Breadth here is how the false-API risk
  arrives
