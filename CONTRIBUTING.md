# How we work here

This file is about the **flow**. The product rules live in `CLAUDE.md` and in
`docs/design-system/DESIGN-SYSTEM.md`, and are not repeated here — a duplicated
document is a document that drifts.

## Language

| | |
|---|---|
| Repository | English. Code, comments, file names, docs, issues, PRs, labels, commit messages |
| Product | Portuguese (pt-BR). Lesson copy, UI strings, error messages — all of it in `src/locales/` |

The split is not arbitrary. Engineering artefacts are read by tooling, by agents
and by anyone who lands on the repository; product copy is read by Brazilian
data engineers. Each one gets the language of its audience.

It is also a check you can run by eye: because the repository is entirely
English, Portuguese appearing inside a component is copy that escaped the locale
files, which is a §9 violation regardless of how it reads.

## The cycle

```
issue (form)  →  branch  →  PR  →  gate + review  →  squash into main  →  production
```

There is no staging step. `main` goes to production on every merge, and every PR
gets its own preview. If something cannot go to production, it cannot be merged.

## 1 · Issue before code

Every task starts as an issue, opened through one of the forms. Blank issues are
off on purpose: the required fields exist to force the question people skip.

| Form | When |
|---|---|
| Lesson or lab | New content. Requires listing the Airflow claims that need checking |
| UI component | New UI. Requires pointing at the `DESIGN-SYSTEM.md` section where the component is **already** documented |
| Bug | Something broken. Requires theme, viewport, keyboard and locale |
| Content error | Glider taught something false. Critical severity by definition |
| Harness or pipeline | Hook, skill, agent, workflow |

The component form asks for the document section because rule 12 is the most
expensive violation in the system: a component that reaches the code before it
reaches the document is what makes a design system rot. If the section does not
exist yet, the PR that writes it comes before the PR that implements it.

## 2 · Branch

```
type/nn-slug
```

`nn` is the issue number. `feat/42-gridview-keyboard`, `fix/57-skipped-contrast`.
Keep it short: if it lives longer than a few days, the issue was too big.

## 3 · Commit

Conventional Commits with a scope, in English:

```
feat(gridview): keyboard navigation cell by cell
fix(a11y): skipped state contrast in the light theme
docs(ds): document StateChip before implementing it
chore(pipeline): pin actions by sha
```

Merges are **squash**, and the squash title becomes a line in the release notes.
Write the title for whoever reads the changelog, not for whoever wrote the code.

## 4 · Before opening the PR

```bash
/ds-check
```

And the §10 floor, which no script catches: 360px, keyboard, visible focus,
`prefers-reduced-motion`, contrast, light and dark on the same screen, and the
grid still readable under colour-blindness simulation.

If you contradicted a design system rule, the exception needs a line in
`DECISIONS.md`, written by `/decision`. Without that line the exception is a bug
— and review will treat it as one.

## 5 · Copy and locales

UI copy never goes inline. It lives in `src/locales/<locale>/*.json`, and
`pt-BR` is the source locale.

```
src/locales/
├─ pt-BR/          ← the source. Always complete
│  ├─ lab.json
│  └─ lesson-07.json
└─ en/             ← optional. If it exists, it is complete
   ├─ lab.json
   └─ lesson-07.json
```

CI compares key sets between locales and fails on any drift, in either
direction. A missing key is copy the reader will not see; an orphan key is copy
nobody can reach, and usually the trace of a rename that landed on one side only.

This is deliberately not "translate everything now". English is an expansion the
product can take when it is ready. The rule is narrower and firmer: **whatever
you start, you finish.** A half-translated locale falls back silently, and the
learner gets a screen in two languages with no error anywhere — the one failure
mode a teaching product cannot afford.

Airflow vocabulary is not translated in either locale. `task`, `DAG run`,
`upstream`, `backfill`, `up_for_retry` stay as they are, explained on first use.
Translating them works against transfer, which is the whole point of the product.

## 6 · Who reviews what

One person cannot review everything with real attention, so review is split by
who can actually do each part well.

| Layer | What it catches | Blocks merge? |
|---|---|---|
| Local hook | the four §8 checks, on the file you just saved | yes, immediately |
| CI gate | the same checks across the repository, locale parity, token parity, lint, types, tests, a11y, build | **yes** |
| Claude on the PR | component outside the document, invented state, state by colour alone, `GridView`/`GraphView` semantics, §9 writing, §11 branding | no, comments |
| You | the §10 floor, `tokens.css`, the line in `DECISIONS.md` | yes, you are the one merging |

Claude's review does not block, deliberately. An agent comment as a required
check locks the repository on the first false positive, and a gate people learn
to ignore stops being a gate. The mechanical layer is what blocks.

That review has no prompt of its own: it tells the agent to read
`.claude/agents/ds-reviewer.md` and follow it. It is the same review you run
locally, and the contract lives in one place.

## 7 · Deploy

Deploys run from GitHub Actions, after the gate, and **not** from Vercel's Git
integration. The native integration deploys on push, in parallel with CI: the
preview would go up even with CI red, which turns the gate into decoration. It
is switched off in version control — `"github": { "enabled": false }` in
`vercel.json` — not just by a click in a dashboard. If someone switches it back
on, the gate stops meaning anything without a single thing turning red.

### What COEP costs

`vercel.json` serves `Cross-Origin-Embedder-Policy: require-corp`. That is not
decorative security: it is the prerequisite for `SharedArrayBuffer`, and without
`SharedArrayBuffer` the UI cannot interrupt a Python run that hung in the lab —
the stop button would have no way to reach the worker.

The price is that **every cross-origin resource now needs CORP or CORS**. In
practice, for this project: **fonts are self-hosted**. Inter and Familjen
Grotesk from Google's CDN would need `crossorigin` on every tag and would depend
on a third party's headers — and the failure mode is the page loading without
its typeface, in production, with nothing red anywhere.

A smoke job after each deploy checks that both headers actually reached the
response. A header configured but not served is the classic silent failure of
this stack: it shows up as Pyodide failing to initialise, months later.

## 8 · Airflow claims

The rule that comes before the others, and the easiest one to break without
noticing, because breaking it feels like knowing the answer.

Every claim about Airflow semantics — states, trigger rules, logical date,
config precedence, core versus provider, where a symbol lives — is checked
against the source at a pinned tag, and the check is recorded next to the claim:

```python
# verified: airflow-core/src/airflow/task/trigger_rule.py @ 3.3.1
```

The procedure lives in `.claude/skills/airflow-truth/`. Use it even when you are
sure: the certainty is the symptom, not the guarantee.

If you could not verify it, say so in the text instead of asserting it. An
honest gap is recoverable; a false claim wearing the face of certainty is not.
