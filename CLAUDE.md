# Glider's contract — read this before touching any screen

You are working on **Glider** (glider.academy): data orchestration labs that run
entirely in the browser, with no backend.

Full source of truth: `docs/design-system/DESIGN-SYSTEM.md`.
Values: `docs/design-system/tokens.css`. This file is the executable summary.

## Language

The repository is in English: code, comments, file names, docs, issues, PRs,
labels, commit messages. The **product** is in Portuguese (pt-BR): lesson copy,
UI strings, error messages — and all of it lives in locale files under
`src/locales/`, never inline (§9).

`pt-BR` is the source locale. English is a supported expansion, and CI enforces
key parity: a locale that exists must be complete. A half-translated one falls
back silently, which is the one failure mode a teaching product cannot afford.

Airflow vocabulary is not translated in any locale. `task`, `DAG run`,
`upstream`, `backfill`, `up_for_retry` stay as they are.

## The rule that comes before the others

**Never state Airflow behaviour from memory.** Check the source before writing it
into a lesson, a component or code — `/airflow-truth` has the procedure and the
paths. Target: 3.x.

Glider teaches. A plausible false claim is worse than a gap, because the learner
carries the error into their own production. `DECISIONS.md` D18 says the same
about states; it holds for all semantics: trigger rules, logical date, config
precedence, executor lifecycle.

## In one sentence

The visual language descends from the Apache Airflow UI — brand blue `#017CEE`,
state colours inherited from `airflow.utils.state`, and the grid of squares as
the signature. The test for every decision: *does this move closer to real
Airflow, or further away?*

## The twelve rules

1. No hex outside `tokens.css`. Use semantic `--gl-*`, never the raw ramps.
2. Spacing only from the `--gl-space-*` scale.
3. Shadows only from the `--gl-shadow-card`, `--gl-shadow-pop`, `--gl-ring-focus` tokens.
4. `border-radius` capped at 8px (`--gl-radius-card`), 2px on grid cells.
5. **Brand blue is never a state colour.** Blue in a grid square is a bug.
6. Task state = colour **and** glyph **and** accessible text. Never colour alone.
7. No invented states: if it is not in `airflow.utils.state`, it does not exist here.
8. Progress is a grid column. A percentage bar does not exist in this product.
9. A number in a list, grid or instrument: mono + `tabular-nums`.
10. Animate only the `running` pulse (and the hero pinwheel, one turn on load).
11. No emoji, no gradients, no new component library.
12. A component not in the design system enters the document **before** the code.

## UI writing

Sentence case. An active verb that names the result (`Disparar DAG` → `DAG
disparado`). **Use Airflow vocabulary** — task, DAG run, data lógica, upstream,
backfill, up_for_retry. Explain on first appearance; do not swap for a synonym.
An error says what broke and what to do about it. No "simplesmente", no
exclamation marks.

All of it in locale files. Copy inline in a component is a §9 violation, and it
is also what makes the English expansion expensive later.

## Branding

Do not reproduce the Apache Airflow logo, or a pinwheel close to it. The kinship
is in palette and structure, not in the symbol. The footer always carries the
ASF trademark notice.

## Before finishing a task

```
/ds-check
```

Runs the four §8 checks across the whole repository, plus the
`tokens.css` ↔ `tokens.json` parity of §12. A hook already applies the same
checks to every file you save, so this is the safety net — if the hook blocked
you, you already know.

The same script runs in CI, in the `contract` job, and **blocks the merge**. It
is not a second implementation: the hook, the skill and CI all call
`.claude/hooks/ds-rules.sh`, and the same regex in a fourth place would be a
guarantee of drift. Running it early only saves the round trip.

Then check the floor: 360px, keyboard, visible focus, reduced-motion, contrast,
light and dark on the same screen, and the grid readable under colour-blindness
simulation.

## What lives in `.claude/`

| | |
|---|---|
| `/ds-check` | the four §8 checks + token parity. Before closing any UI task |
| `/airflow-truth` | how to check an Airflow claim against the source |
| `/decision` | writes the row in `DECISIONS.md`, numbered and dated |
| agent `ds-reviewer` | reads a UI diff against the contract, in a clean context. What regex misses: component outside the document, invented state, state by colour alone |
| `hooks/ds-selftest.sh` | proves the checks know how to reject. A new check without a case here is a check that only knows how to pass |

`ds-reviewer` is also what reviews the PR: the review workflow has no prompt of
its own, it tells the agent to read that file. One contract, one place.

Hooks apply on their own, on every `Edit`/`Write`: the §8 checks on the saved
file, token parity, and escalation to the user on any change to `tokens.css`.

The issue-to-production flow lives in `CONTRIBUTING.md`. How CI, deploy, the
board and the rulesets are wired lives in `docs/pipeline.md`.

## If you need to break a rule

Use `/decision`. The row needs a date, what was broken, why, and which
alternative inside the system was discarded. Without that row, the exception is
a bug.
