# Glider

Data orchestration labs that run entirely in the browser.

You write a DAG, trigger it, watch the grid change state, and understand what
happened. No Airflow install, no Docker, no backend: Python runs in
WebAssembly, in your tab.

**glider.academy**

## Who it is for

Data analysts and engineers who already write SQL and Python and are about to
learn scheduling, dependencies, retries and backfill.

The principle behind the product is **transfer**: someone who finishes Glider
and opens a real Airflow should recognise the screen in the first second. Every
design decision answers one question — does this move us closer to real Airflow,
or further away?

## Language

Two languages, two jobs, and they do not mix.

| | |
|---|---|
| **Product** | Portuguese (pt-BR). Lessons, UI copy, error messages |
| **Repository** | English. Code, comments, file names, docs, issues, PRs, labels, commits |

The product ships in Portuguese because that is who it is for. English is a
supported expansion, not an afterthought: all UI copy lives in locale files
under `src/locales/`, never inline, and CI enforces key parity between locales.
Adding `en` means adding files next to the `pt-BR` ones — no code changes.

A locale that exists must be complete. A half-translated one fails silently at
runtime, which is the single failure mode a teaching product cannot afford.

Because the split is that clean, Portuguese found inside a component is a
finding on its own: it is copy that escaped the locale files.

## Stack

| | |
|---|---|
| Interface | Vite · React · TypeScript |
| Execution | Pyodide (CPython on WebAssembly) |
| Tests | Vitest · Playwright · axe |
| Deploy | Vercel, static, no application server |

## Running it

```bash
pnpm install
pnpm dev
```

The design system hooks need `ripgrep` and `jq`:

```bash
brew install ripgrep jq          # macOS
apt-get install -y ripgrep jq    # Debian
```

Check the environment before picking up your first task:

```bash
bash .claude/hooks/preflight.sh
bash .claude/skills/ds-check/ds-check.sh
```

## Contributing

Read `CONTRIBUTING.md`. In one line: open an issue through a form, work on a
short branch, run `/ds-check` before the PR, and never state Airflow behaviour
from memory.

That last one is not style. Glider teaches, and a plausible false claim is worse
than a gap, because the learner carries the error into their own production.
Every claim about Airflow semantics is checked against the source at a pinned
tag — the procedure lives in `.claude/skills/airflow-truth/`.

## Documents

| File | What it is |
|---|---|
| `CLAUDE.md` | The short contract. Applies to people and to agents |
| `CONTRIBUTING.md` | Issue to production: branches, commits, who reviews what |
| `docs/pipeline.md` | How CI, deploy, the board and the rulesets are wired |
| `docs/design-system/DESIGN-SYSTEM.md` | The narrative source for the design system |
| `docs/design-system/tokens.css` | Single source of truth for every value |
| `docs/design-system/DECISIONS.md` | Every exception to the rules, dated and justified |

## Licence

Code under MIT (`LICENSE`). Teaching content under CC BY-SA 4.0
(`LICENSE-CONTENT`).

---

Apache Airflow is a registered trademark of the Apache Software Foundation.
This project is not affiliated with the ASF.
