# Handoff

The state of the world, as of the last audited spec.

Overwritten by each spec's implementing agent as its last act, and committed with
the work. It is not a log — it describes what is true now. Why it works that way
is in `docs/orchestration.md` §7.

Read this before starting a spec. Rewrite it before finishing one.

---

**Last audited spec:** S00 — the issue form the queue needs before it can start
**Date:** 2026-08-23

## What exists

Nothing that runs. The repository holds a contract and no product:

| | |
|---|---|
| Design system | `docs/design-system/` — 12 sections, 10 documented components, 18 decisions |
| Tokens | `docs/design-system/tokens.css`, mirrored in `tokens.json`, parity enforced |
| Harness | 3 skills, 6 hooks, 2 agents under `.claude/` — `ds-reviewer` and `spec-auditor` |
| Pipeline | 5 workflows, 6 scripts, **6** issue forms, **28** labels under `.github/` |
| Orchestration | `docs/orchestration.md`, `docs/specs/` (34 specs), this file |
| Application | **none.** No `package.json`, no `src/`, no lockfile |

CI knows this: `preflight` sets `app=false` when `package.json` is missing, and
every application job skips itself. The `gate` job is green on an empty repository
by design.

`main` carries the full pipeline — PR #1 merged, and PR #2 added
`docs/orchestration.md`, this file and the 34 specs. Branch the queue from
`main`.

## Surface

No code is exported. The queue gains two identifiers that every product spec's
header references:

- Issue form `06-feature` — `.github/ISSUE_TEMPLATE/06-feature.yml`, titled
  `New feature`, auto-applying `type/feature`, with nine fields mirroring the
  eight spec sections of `docs/orchestration.md` §8: `depends`, `context`,
  `reading`, `files`, `do`, `surface`, `acceptance`, `scope` (all required) and
  an optional `contract` checkbox group
- Label `type/feature`, colour `1F6FEB`, *Product code: runtime, engine, screens,
  build* — declared in `.github/labels.yml`, in the `type` block after
  `type/component`

`05-harness` keeps its dropdown unchanged. Runtime, engine, screen and build work
files as `06-feature`; hooks, skills, agents, CI, deploy and board work stays on
`05-harness`.

Dependabot's `npm` ecosystem is on a **monthly** interval, not weekly. Any spec
that lands `package.json` inherits that cadence.

## Invariants

The ones that hold before any code exists, and that no spec may break without a
row in `DECISIONS.md`:

- `docs/design-system/tokens.css` is the single source of design values. Editing
  it escalates to a human — that is `tokens-guard.sh` working, not failing
- The four §8 checks run on every save of a source file outside `docs/` and
  `.claude/`. `ds-selftest.sh` proves they can still reject
- `pt-BR` is the source locale. A locale that exists is complete
- No task state outside `airflow.utils.state` (D18). No Airflow claim without
  `# verified: <path> @ <tag>`
- Below 900px the lab has no editable canvas (D9, marked do not reopen)
- Every namespaced label referenced under `.github/ISSUE_TEMPLATE/`,
  `.github/workflows/`, `.github/dependabot.yml` or `.github/release.yml` is
  declared in `.github/labels.yml`. `check-labels.sh` enforces it; GitHub drops an
  undeclared label silently, so nothing else would
- `blank_issues_enabled` stays `false` in `.github/ISSUE_TEMPLATE/config.yml`

## Debt

- **No issues exist yet.** Nothing in `docs/specs/` has been filed. Until a spec
  has an issue number, its branch takes `00` — `docs/orchestration.md` §3. What
  is live on GitHub is one form and one label behind this branch: `gh label list`
  returns the 27 labels of `labels.yml` plus GitHub's 9 defaults, and
  `origin/main` carries five forms plus `config.yml`. `06-feature.yml` and
  `type/feature` are files on this branch and nothing more until it merges
- **`type/feature` is declared but unsynced.** It lands on GitHub the next time
  `labels-sync.yml` runs on a push touching `.github/labels.yml`, or on
  `gh workflow run labels-sync.yml`. Filing a `06-feature` issue before that
  opens it with no classification at all — `docs/pipeline.md`, activation order
  step 3
- **The npm interval is temporary.** `dependabot.yml` carries `interval: monthly`
  and keeps `day: monday` for when **S33** puts it back to weekly. Five weekly
  dependency PRs, each running Playwright on two browsers against a strict gate,
  is not a cost worth paying across a thirty-four spec build-out
- **The toolchain is not installed.** `pnpm` is absent, and the local Node is 25
  against `.nvmrc`'s 22. S01 mandates `engine-strict=true`, so `pnpm install`
  will refuse to run until the shell is on Node 22 — `nvm use`, then
  `corepack enable`. Every acceptance command in the queue starts with `pnpm`
- **`python3` has no `yaml` module** on this machine, and `yq` is not installed.
  Any spec whose acceptance parses YAML needs a venv with `PyYAML`, or `ruby
  -ryaml`. Nothing in the repository depends on it; only the acceptance commands do
- **The `gh` token lacks `project` scope.** `gh auth refresh -s project,read:project`
  is a one-time human step, documented in `board-bootstrap.sh`
- **The mockups under `docs/mockups/` are exempt from §8** and contain a Google
  Fonts link, raw hex, and a pinwheel §11 arguably forbids. S05 and S07 add
  superseded banners before anyone copies them
