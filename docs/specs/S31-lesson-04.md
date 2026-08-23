# S31 · lesson 04 — dependencies and execution order, end to end

| | |
|---|---|
| Form | `01-lesson` |
| Labels | `type/lesson` `area/content` `track/dependencies` `state/needs-verification` |
| Size | M |
| Branch | `feat/nn-lesson-04` |

## Depends on
S13, S17, S30

## Unblocks
S32

## Context

The one complete lesson, and the thing all the foundation was for. Its transfer
claim: **a learner who finishes it and opens a real Airflow recognises the grid,
reads `upstream_failed` on a downstream task, and knows why it is not `failed`.**

That distinction is the lesson. `limpar` fails; `somar` and `publicar` do not
run, and they do not show `failed` either — they show `upstream_failed`, because
`all_success` is the default trigger rule and a failed upstream blocks rather
than fails. It is one line in the engine and the entire teaching point, which is
why S13 and S14 both carry `state/needs-verification` and why this spec does too.

The lesson deliberately contains a failure the learner is meant to see. The
starter DAG runs, `limpar` raises, the grid goes red and orange, and the log says
why. That is the product.

Every claim is checked against the source at 3.3.1 and the check is recorded next
to the claim. `/airflow-truth` exists for this and the certainty is the symptom.

## Reading list
- `CLAUDE.md` § The rule that comes before the others, § UI writing
- `docs/orchestration/HANDOFF.md`
- `.claude/skills/airflow-truth/SKILL.md`
- `README.md` § Transfer is the goal, § Teaching wrong is the worst defect
- `docs/design-system/DESIGN-SYSTEM.md` §5.9, §9
- `docs/specs/S30-content-model.md` § Delivers
- `.github/ISSUE_TEMPLATE/01-lesson.yml` — the closing contract this spec must meet

## Files
- `src/content/lessons/lesson-04.ts` — new
- `src/content/lessons/lesson-04.test.ts` — new
- `src/locales/pt-BR/lesson-04.json` — new

## Do

1. **Verify and annotate each claim** before writing prose around it:
   - `all_success` is the default trigger rule
   - `>>` sets downstream
   - a failed upstream puts a downstream task in `upstream_failed`, not `failed`
   - a skipped upstream under `all_success` skips the downstream
   Each gets `# verified: <path> @ 3.3.1` beside it. If one cannot be verified,
   **say so in the text instead of asserting it** — an honest gap is recoverable.
2. The starter DAG: four tasks — `extrair`, `limpar`, `somar`, `publicar` — with
   the dependency shape the mockup shows. `limpar` raises.
3. Prose in `lesson-04.json`, to §9: sentence case, active verbs, Airflow
   vocabulary kept as-is and explained on first use — `task`, `DAG run`, `data
   lógica`, `upstream`, `upstream_failed`. No `simplesmente`, no exclamation
   marks, no emoji.
4. A `checkpoint` Callout at the end, and a `Checkpoint` asserting over the run:
   the learner has made `publicar` reach `success` by fixing or handling the
   failure.
5. Tests: the DAG parses through S17's shim; a run against it produces exactly
   the expected state per task; the checkpoint fails before the fix and passes
   after.

## Delivers

### Artifacts
The three files above.

### Surface
`src/content/lessons/lesson-04.ts` exports the `Lesson` and registers it.

### Invariants
- Every Airflow claim carries `# verified: <path> @ 3.3.1`
- No state outside `airflow.utils.state` appears in the prose or the run
- All prose in `lesson-04.json`. No string in the `.ts`
- Airflow vocabulary is not translated

### Evidence
The `/airflow-truth` transcript per claim, and the lesson tests showing the exact
state per task.

### Debt
Lessons 01–03 and 05–15 do not exist. The track shows fourteen `queued` cells,
which is honest.

## Acceptance

| Command | Expected |
|---|---|
| `pnpm test src/content/lessons/lesson-04.test.ts` | green — expected state per task |
| `rg -c '# verified:.*@ 3.3.1' src/content/lessons/lesson-04.ts` | one per claim |
| `bash .github/scripts/check-locales.sh` | green |
| `rg -n 'simplesmente\|apenas\|é só\|!' src/locales/pt-BR/lesson-04.json` | no §9 violations |
| `bash .claude/skills/ds-check/ds-check.sh` | PASSED |

## Out of scope
- Any other lesson
- An `en` translation
- Any claim about scheduling, backfill or executors — other tracks, other lessons
