# Handoff

The state of the world, as of the last audited spec.

Overwritten by each spec's implementing agent as its last act, and committed with
the work. It is not a log — it describes what is true now. Why it works that way
is in `docs/orchestration.md` §7.

Read this before starting a spec. Rewrite it before finishing one.

---

**Last audited spec:** none — the queue has not started
**Date:** —

## What exists

Nothing that runs. The repository holds a contract and no product:

| | |
|---|---|
| Design system | `docs/design-system/` — 12 sections, 10 documented components, 18 decisions |
| Tokens | `docs/design-system/tokens.css`, mirrored in `tokens.json`, parity enforced |
| Harness | 3 skills, 6 hooks, 2 agents under `.claude/` — `ds-reviewer` and `spec-auditor` |
| Pipeline | 5 workflows, 6 scripts, 5 issue forms, 27 labels under `.github/` |
| Orchestration | `docs/orchestration.md`, `docs/specs/` (34 specs), this file |
| Application | **none.** No `package.json`, no `src/`, no lockfile |

CI knows this: `preflight` sets `app=false` when `package.json` is missing, and
every application job skips itself. The `gate` job is green on an empty repository
by design.

## Surface

Nothing is exported. The first spec to publish a surface is S01.

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

## Debt

- **PR #1 is open, not merged.** Every workflow, form, label and script above
  lives on `chore/00-pipeline`. The GitHub repository still carries the nine
  default labels; `labels.yml`'s 27 have never synced. Nothing that touches
  GitHub state can run until it does
- **`main` is not a valid base for the queue yet.** It holds `.claude/`,
  `.gitattributes`, `.gitignore`, `CLAUDE.md` and `docs/` — no `.github/`, no
  `.nvmrc`, no `vercel.json`, no `README.md`. Four of S01's seven reading-list
  files are missing from it. Until PR #1 merges, branch from
  `chore/00-pipeline`, not from `main`
- **The toolchain is not installed.** `pnpm` is absent, and the local Node is 25
  against `.nvmrc`'s 22. S01 mandates `engine-strict=true`, so `pnpm install`
  will refuse to run until the shell is on Node 22 — `nvm use`, then
  `corepack enable`. Every acceptance command in the queue starts with `pnpm`
- **The `gh` token lacks `project` scope.** `gh auth refresh -s project,read:project`
  is a one-time human step, documented in `board-bootstrap.sh`
- **No issue form covers building the application.** S00 adds `06-feature.yml`
  and the `type/feature` label
- **The mockups under `docs/mockups/` are exempt from §8** and contain a Google
  Fonts link, raw hex, and a pinwheel §11 arguably forbids. S05 and S07 add
  superseded banners before anyone copies them
