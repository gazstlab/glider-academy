# Glider's contract — read this before touching any screen

You are working on **Glider** (glider.academy): data orchestration labs that run
entirely in the browser, with no backend.

| Question | Answered in |
|---|---|
| What the product is, who it serves, why | `README.md` — the source of truth |
| What a screen looks like and how it behaves | `docs/design-system/DESIGN-SYSTEM.md` — UI and UX only |
| Exact design values | `docs/design-system/tokens.css` |
| How work moves from issue to production | `CONTRIBUTING.md`, `docs/pipeline.md` |
| How agents execute the queue of specs | `docs/orchestration.md` |

This file is the executable summary of the first two. When it is thinner than
they are, they win — but the split above holds in both directions: do not ask the
design system what the product should do, and do not ask the README what a border
radius should be.

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

## The product, in one paragraph

Interactive labs where a data analyst or engineer writes a DAG, triggers it, and
watches the grid change state — learning scheduling, dependencies, retries and
backfill by running them, not by reading about them. Tone of a flight instructor:
direct, technical, no forced enthusiasm. No backend; nothing assumes server state.

**Transfer is the goal.** Someone who finishes Glider and opens a real Airflow
should recognise the screen in the first second.

## The design, in one sentence

The visual language descends from the Apache Airflow UI — brand blue `#017CEE`,
state colours inherited from `airflow.utils.state`, and the grid of squares as
the signature. The test for every **design** decision: *does this move closer to
real Airflow, or further away?* That test settles interface questions and not
product ones.

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
is in palette and structure, not in the symbol. The footer always carries the ASF
trademark notice, from the locale files like every other string — its wording is
set in `README.md`, so a legal line is never edited as a design tweak.

## Orchestration

Implementation runs as a queue. `docs/specs/` holds one file per spec; each is
sized so that a single agent, holding only that spec's context, can finish it.
**One at a time, strictly sequential.** The full protocol — prompt templates,
the audit checklist, the spec format — is `docs/orchestration.md`.

**main coordinates and does not implement.** It reads specs, spawns agents,
audits, hands off. A coordinator that implements is carrying five specs of dead
detail by the sixth one and starts answering from memory of what it built — the
same failure the rule above names. Context is a budget, not a resource.

**Each spec goes to one subagent, with a closed packet of six things:** the spec
verbatim; `docs/orchestration/HANDOFF.md`; a reading list of document
*sections*, not files; the file fence; the acceptance commands; the branch name.
Nothing else, and never "read the repository and figure it out".

**Every spec hands the next five things** — `Artifacts`, `Surface`,
`Invariants`, `Evidence`, `Debt`. A spec that cannot fill all five was scoped
wrong. `Surface` is checked against the diff: a symbol named there that the code
does not export breaks the next spec on its first import. `Debt` is how work an
agent could not do inside its fence becomes a handoff item instead of a hole.

**Nothing counts until it is audited, and never by the agent that did it.**
`spec-auditor` asks whether the spec was delivered — evidence, fence, handoff.
`ds-reviewer` asks whether the interface obeys the contract, and is spawned as
well whenever UI was touched. Verdicts are `PASS`, `REPAIR` (a gap in the work,
one round back to the same agent) and `BLOCKED` (a gap in the spec, or a human
decision — stop the queue).

**What stops the queue:** two failed repair rounds; any `tokens.css` change,
which `tokens-guard.sh` escalates by construction; an Airflow claim that could
not be verified. A subagent never closes its own issue and never merges its own
PR.

**`docs/orchestration/HANDOFF.md`** is the state of the world — one file,
overwritten each spec, not a log. Read it before starting; rewrite it before
finishing.

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
| agent `spec-auditor` | reads a finished spec against what it promised: acceptance evidence, the file fence, the `Surface` block, the handoff. Never run by the agent that did the work |
| `hooks/ds-selftest.sh` | proves the checks know how to reject. A new check without a case here is a check that only knows how to pass |

`ds-reviewer` is also what reviews the PR: the review workflow has no prompt of
its own, it tells the agent to read that file. One contract, one place — which is
why `spec-auditor` audits completion and leaves the design contract alone.

Hooks apply on their own, on every `Edit`/`Write`: the §8 checks on the saved
file, token parity, and escalation to the user on any change to `tokens.css`.

The issue-to-production flow lives in `CONTRIBUTING.md`. How CI, deploy, the
board and the rulesets are wired lives in `docs/pipeline.md`. How the queue of
specs is executed lives in `docs/orchestration.md`.

## If you need to break a rule

Use `/decision`. The row needs a date, what was broken, why, and which
alternative inside the system was discarded. Without that row, the exception is
a bug.
