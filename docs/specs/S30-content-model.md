# S30 · the lesson content model and the checkpoint contract

| | |
|---|---|
| Form | `06-feature` |
| Labels | `type/feature` `area/content` |
| Size | S |
| Branch | `feat/nn-content-model` |

## Depends on
S03, S14

## Unblocks
S31

## Context

A lesson is prose, a starter DAG, an expected failure and a checkpoint — and the
checkpoint is the piece that makes the lab a lab rather than a sandbox. It is a
predicate over a finished `DagRun`: *did the thing the lesson is teaching
actually happen?*

Defining it as a function over the run state, rather than as a comparison of the
learner's code against a solution, is the decision worth stating. There are many
correct ways to write the same DAG, and grading the text would fail people who
were right. Grading the run grades the outcome the lesson claims to teach.

The model is defined before any lesson exists, so lesson 04 is written against a
contract rather than the contract being reverse-engineered from one lesson.

## Reading list
- `CLAUDE.md`
- `docs/orchestration/HANDOFF.md`
- `docs/specs/S14-run-loop.md` § Delivers — `DagRun`, `TaskInstance`
- `CONTRIBUTING.md` §5 — the locale layout, one file per lesson
- `docs/design-system/DESIGN-SYSTEM.md` §5.9 — checkpoint is a Callout kind

## Files
- `src/content/types.ts`, `src/content/registry.ts` — new
- `src/content/registry.test.ts` — new

## Do

1. `interface Lesson { id; track; title; estimateMin; sections: Section[]; starterCode: string; solutionCode: string; dag: DagDef; checkpoints: Checkpoint[] }`.
   `title` and `sections` hold **locale keys, not strings** — §9 applies to
   lesson prose exactly as it applies to a button.
2. `interface Checkpoint { id; assert(run: DagRun): boolean; hintKey: string }`.
   The hint is a key too, and it says what to do next rather than restating what
   failed.
3. `getLesson(id): Lesson` over a registry, throwing on an unknown id.
4. Tests: a fixture lesson resolves; an unknown id throws; a checkpoint evaluates
   against a `DagRun` built by S14's `createDagRun`.

## Delivers

### Artifacts
The three files above.

### Surface
`src/content/types.ts` exports `interface Lesson`, `interface Section`,
`interface Checkpoint`. `src/content/registry.ts` exports `getLesson()`.

### Invariants
- Prose and titles are locale keys. No lesson text lives in a `.ts` file
- A checkpoint asserts over the **run**, never over the learner's source text
- `getLesson` throws on an unknown id

### Evidence
The unit run.

### Debt
There is no track index or lesson ordering model yet — one lesson does not need
one, and inventing it now would be inventing it wrong.

## Acceptance

| Command | Expected |
|---|---|
| `pnpm test src/content` | green |
| `rg -n '"[A-Z][a-z]+ [a-z]+' src/content/*.ts` | no prose in the model |
| `pnpm typecheck` | clean |

## Out of scope
- Lesson 04 itself — S31
- A lesson-navigation screen
- Grading the learner's source text
