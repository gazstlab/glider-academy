# The queue

One file per spec, sized so that a single agent holding only that spec's context
can finish it. **Executed strictly in order, one at a time.** How — the context
packet, the audit, the handoff — is `docs/orchestration.md`.

The specs are the source. Issues are generated from them once the pipeline is
live, because `docs/pipeline.md` §3 is explicit that labels have to exist before
the first issue: GitHub discards an unknown label silently and the issue opens
with no classification at all.

Scope of this queue: **the foundation plus one complete lab, end to end.** Not
the full curriculum.

| id | title | form | size | depends on |
|---|---|---|---|---|
| S00 | the issue form the queue needs before it can start | `05-harness` | S | — |
| **Phase 0 — the skeleton CI can see** |||||
| S01 | scaffold the Vite skeleton the five CI scripts call | `06-feature` | M | S00 |
| S02 | consume tokens.css at runtime without copying it | `06-feature` | S | S01 |
| S03 | load pt-BR from locale files and make inline copy fail lint | `06-feature` | S | S01 |
| S04 | route home, track and lab and reserve their layout | `06-feature` | S | S01, S02 |
| **Phase 1 — the contract catches up to the screens** |||||
| S05 | settle the Glider mark and retire the pinwheel derivative | `02-component` | S | — |
| S06 | document the chrome — Header, Footer, ThemeSwitch | `02-component` | S | S05 |
| S07 | self-host the three families under COEP | `06-feature` | S | S02 |
| S08 | implement §5.1 Button | `02-component` | S | S02, S03 |
| S09 | implement StateCell and StateChip over the verified state set | `02-component` | M | S02, S03 |
| S10 | implement §5.9 Callout with a named token per kind | `02-component` | S | S06, S09 |
| S11 | implement Header, Footer, BrandMark and the theme switch | `02-component` | M | S03, S05, S06, S07, S08 |
| **Phase 2 — Airflow semantics, in TypeScript, testable** |||||
| S12 | the DAG graph — parse, topological order, cycle detection | `06-feature` | S | S09 |
| S13 | evaluate the 13 trigger rules against upstream state | `06-feature` | M | S12 |
| S14 | the run loop — retries, propagation and DAG run state | `06-feature` | M | S13 |
| S15 | bind a DAG run to React | `06-feature` | S | S14 |
| **Phase 3 — Python in the tab** |||||
| S16 | boot Pyodide in a worker and vendor its assets | `06-feature` | M | S01, S07 |
| S17 | the Python airflow shim that turns a lesson DAG into JSON | `06-feature` | M | S12, S16 |
| S18 | execute a task callable and stream its log | `06-feature` | S | S14, S17 |
| S19 | stop a hung run through the SharedArrayBuffer interrupt buffer | `06-feature` | M | S16 |
| **Phase 4 — the signature** |||||
| S20 | document the lab furniture — Panel, TaskDetailPanel, Toast | `02-component` | M | S06 |
| S21 | implement §5.4 GridView as a table with a text alternative | `02-component` | M | S03, S09, S15 |
| S22 | implement §5.5 GraphView with arrow-key node traversal | `02-component` | M | S03, S09, S12, S15 |
| S23 | implement §5.6 TrackGrid and persist progress | `02-component` | S | S03, S09 |
| S24 | implement §5.7 CodePane with a theme derived from the tokens | `02-component` | M | S02, S03, S20 |
| S25 | implement §5.8 RunLog | `02-component` | S | S09, S15, S20 |
| S26 | implement TaskDetailPanel and Toast | `02-component` | S | S08, S15, S20 |
| S27 | the three resizable panels and the D9 collapse below 900px | `02-component` | M | S20, S24 |
| **Phase 5 — the home and the lesson** |||||
| S28 | document the home — Hero and TrackCard | `02-component` | S | S20 |
| S29 | implement the home screen | `02-component` | M | S05, S11, S23, S28 |
| S30 | the lesson content model and the checkpoint contract | `06-feature` | S | S03, S14 |
| S31 | lesson 04 — dependencies and execution order, end to end | `01-lesson` | M | S13, S17, S30 |
| **Phase 6 — close the loop** |||||
| S32 | assemble the lab screen and close the loop | `06-feature` | M | S11, S15, S18, S19, S21, S22, S24, S25, S26, S27, S31 |
| S33 | the axe suite and the §10 floor a script can reach | `06-feature` | M | S32 |

No spec is sized **L**. An L is a spec that was not decomposed.

## The critical path

```
S01 → S02 → S09 → S12 → S13 → S14 → S15 → S21 → S32 → S33
```

Ten hops, three of them M with a verification burden. A second chain carries more
risk than length: `S01 → S07 → S16 → S17 → S18 → S32`, where S17 is the spec in
which "looks right" and "is right" diverge silently.

**S05 starts on day one, beside S01.** It has no code dependencies, needs a human
aesthetic and trademark judgement, and blocks S06 → S11 → S29.

## Numbers assigned in advance

So that two specs never claim the same one.

| `DESIGN-SYSTEM.md` §5 | | `DECISIONS.md` | |
|---|---|---|---|
| 5.11 `Header` | S06 | **D19** the Glider mark | S05 |
| 5.12 `Footer` | S06 | **D20** Glider's task-state set | S09 |
| 5.13 `BrandMark` | S05 | **D21** the callout kind tokens | S10 |
| 5.14 `ThemeSwitch` | S06 | **D22** tokens imported from `docs/` | S02 |
| 5.15 `Panel` | S20 | **D23** unsupported trigger rules | S13 |
| 5.16 `TaskDetailPanel` | S20 | | |
| 5.17 `Toast` | S20 | | |
| 5.18 `Hero` | S28 | | |
| 5.19 `TrackCard` | S28 | | |

## Files more than one spec touches

Strictly sequential execution makes these audit checks rather than scheduling
constraints — but they are why every spec carries a `Files` fence.

| File | Specs |
|---|---|
| `DESIGN-SYSTEM.md` §5 | S05, S06, S10, S20, S28 |
| `DECISIONS.md` | S02, S05, S09, S10, S13 |
| `tokens.css` | **S10 only** — and it escalates to a human by design |
| `index.html` | S01, S07, S11 — one block each, no restructuring |
| `vite.config.ts` | S01 writes the blocks; S16 and S24 fill in values |
| `dependabot.yml` | S00 sets npm monthly, S33 restores weekly |

`package.json` and `pnpm-lock.yaml` are touched by S01 only: every dependency the
queue needs is declared there, including ones nothing imports yet, because a
lockfile does not auto-merge. Locale files are split one per copy-owning surface
for the same reason — without it, eleven specs would edit `lab.json`.
