# Glider

Data orchestration labs that run entirely in the browser.

You write a DAG, trigger it, watch the grid change state, and understand what
happened. No Airflow install, no Docker, no backend: Python runs in
WebAssembly, in your tab.

**glider.academy**

## What this is

| | |
|---|---|
| **Product** | Interactive data orchestration labs, running entirely in the browser |
| **Audience** | Data analysts and engineers who already write SQL and Python, and are about to learn scheduling, dependencies, retries and backfill |
| **Each screen's job** | Get the person to run a DAG and understand what happened — not to read about it |
| **Tone** | Flight instructor: direct, technical, no forced enthusiasm, no emoji |
| **Constraint** | No backend. Static + WASM. Nothing assumes server state |

This table is the source of truth for what Glider is. Everything else in the
repository is downstream of it: the design system decides what a screen looks
like, the pipeline decides how it ships, and neither of them gets to redefine the
product.

## Transfer is the goal

Someone who finishes Glider and opens a real Airflow should recognise the screen
in the first second.

That is the point of the whole thing, and it has consequences that look strange
without it. We inherit Airflow's state colours instead of picking nicer ones. We
keep its vocabulary — `task`, `DAG run`, `up_for_retry` — instead of translating
to something friendlier. We show a grid of coloured squares instead of a progress
bar. Each of those is worse in isolation and correct in aggregate, because what
the learner is building is recognition of a specific tool, not a general feeling
of having learned something.

Where Airflow has a known problem — contrast, state carried by colour alone — we
fix it while keeping the hue. Recognition survives a value change; it does not
survive a hue change.

## Teaching wrong is the worst defect

A broken screen is something people see. A false claim is something they believe,
and then carry into their own production.

So every claim about Airflow semantics — states, trigger rules, logical date,
config precedence, what is core and what is a provider — is checked against the
source at a pinned tag before it becomes prose, and the check is recorded next to
the claim. The procedure is in `.claude/skills/airflow-truth/`. Use it even when
you are sure: the certainty is the symptom, not the guarantee.

The corollary is a rule that looks pedantic and is not: no invented task states.
If it is not in `airflow.utils.state`, it does not exist here — a state made up
for teaching convenience teaches something false about the tool.

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

That last one is the rule above, restated where you will trip over it.

## Documents

Each one owns a different question, and none of them answers another's.

| File | Owns |
|---|---|
| **`README.md`** | **What the product is, who it serves, why it exists** |
| `CLAUDE.md` | The same, compressed into a working contract agents load every session |
| `CONTRIBUTING.md` | Issue to production: branches, commits, locales, who reviews what |
| `docs/pipeline.md` | How CI, deploy, the board and the rulesets are wired |
| `docs/design-system/DESIGN-SYSTEM.md` | What a screen looks like and how it behaves — UI and UX only |
| `docs/design-system/tokens.css` | Single source of truth for every design value |
| `docs/design-system/DECISIONS.md` | Design exceptions and changes of direction, dated |

The design system is deliberately not on the hook for product questions. A design
document that also defines scope and audience gets edited to win arguments about
scope and audience, and the visual contract erodes underneath.

## Trademark

Apache Airflow is a registered trademark of the Apache Software Foundation.
Glider is **not** an ASF project and does not suggest endorsement.

Inheriting state colours from an Apache-2.0 project is legitimate use;
reproducing brand identity is not. Before any commercial use, read the ASF
trademark policy.

The product footer renders this notice, from the locale files like every other
string. This is the wording:

> Apache Airflow é marca registrada da Apache Software Foundation. Este projeto
> não é afiliado à ASF.

It is set here rather than in the design system so that a legal line is never
edited as a design tweak.

## Licence

Code under MIT (`LICENSE`). Teaching content under CC BY-SA 4.0
(`LICENSE-CONTENT`).

---

Apache Airflow is a registered trademark of the Apache Software Foundation.
This project is not affiliated with the ASF.
