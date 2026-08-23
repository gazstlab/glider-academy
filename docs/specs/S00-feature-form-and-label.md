# S00 · the issue form the queue needs before it can start

| | |
|---|---|
| Form | `05-harness` |
| Labels | `type/chore` `area/pipeline` |
| Size | S |
| Branch | `chore/nn-feature-form` |

## Depends on
Nothing. This is the first spec.

## Unblocks
Every spec whose form is `06-feature` — S01, S02, S03, S04, S07, S12, S13, S14,
S15, S16, S17, S18, S19, S30, S32, S33.

## Context

Thirteen of the specs in this queue build the product itself, and none of the
five existing issue forms describes that work. `05-harness` comes closest and is
wrong: its `target` dropdown is Hook / Skill / Agent / CI workflow / Deploy /
Board / CLAUDE.md — all infrastructure. Filing the Pyodide runtime under it would
make `type/chore` + `area/harness` mean two unrelated things and would put the
whole foundation in the wrong column of the board.

The new form is not just a label carrier. It mirrors the eight sections of a spec
file, so an issue opened through it carries the atomicity contract in its own
structure rather than by convention — the same move `02-component.yml` already
makes when it requires the `DESIGN-SYSTEM.md` section number before the code.

The label has to land in the same pull request or earlier: `check-labels.sh`
sweeps `.github/ISSUE_TEMPLATE/` for anything matching
`(type|track|area|quality|state)/[a-z0-9-]+` and fails on a label that is
referenced but not declared in `labels.yml`.

## Reading list
- `CLAUDE.md`
- `docs/orchestration.md` §8 — the spec format the form mirrors
- `.github/ISSUE_TEMPLATE/05-harness.yml` and `02-component.yml` — the house voice
- `.github/labels.yml` — the five `type/*` rows
- `.github/scripts/check-labels.sh`
- `docs/pipeline.md` §3

## Files
- `.github/ISSUE_TEMPLATE/06-feature.yml` — new
- `.github/labels.yml` — add one row
- `.github/dependabot.yml` — change the npm interval

## Do

1. Add to `labels.yml`, in the `type` block, after `type/component`:
   `type/feature`, colour `1F6FEB`, description
   `Product code: runtime, engine, screens, build`.
2. Write `.github/ISSUE_TEMPLATE/06-feature.yml`:
   - `name: New feature`, `description: Product code — runtime, engine, screens or build`
   - `title: "[feature] "`, `labels: ["type/feature"]`
   - Fields, all required unless noted:

     | id | type | label |
     |---|---|---|
     | `depends` | input | Specs this depends on |
     | `context` | textarea | What this is for, and what the next spec does with it |
     | `reading` | textarea | Reading list — document sections, not files |
     | `files` | textarea | Files this may write. Anything outside is out of bounds |
     | `do` | textarea | Steps |
     | `surface` | textarea | What it exports for the next spec — paths and signatures |
     | `acceptance` | textarea | Commands and their expected result |
     | `scope` | textarea | Out of scope |
     | `contract` | checkboxes (optional) | `No UI copy inline — it lives in src/locales (§9)`; `No Airflow claim without # verified: <path> @ <tag>`; `No component in code that is not already in DESIGN-SYSTEM.md §5` |

   - A leading `markdown` block saying the fence is a contract, not a suggestion,
     and pointing at `docs/orchestration.md`.
3. In `dependabot.yml`, change the `npm` ecosystem `schedule.interval` from
   `weekly` to `monthly`, with a comment naming S33 as when it goes back. The
   moment `package.json` lands, five weekly PRs each run Playwright on two
   browsers, against a strict gate, during a thirty-four spec build-out.

## Delivers

### Artifacts
- `.github/ISSUE_TEMPLATE/06-feature.yml`
- `.github/labels.yml` — one row added
- `.github/dependabot.yml` — one interval changed

### Surface
No code. The queue gains a form id (`06-feature`) and a label (`type/feature`)
that every later spec header references.

### Invariants
- Every namespaced label referenced anywhere under `.github/ISSUE_TEMPLATE/`,
  `workflows/`, `dependabot.yml` or `release.yml` is declared in `labels.yml`
- `blank_issues_enabled` stays `false`

### Evidence
`check-labels.sh` and `actionlint` output.

### Debt
The label does not exist on GitHub until PR #1 merges and `labels-sync.yml` runs.
That is `docs/pipeline.md` §3's activation order, not this spec's job.

## Acceptance

| Command | Expected |
|---|---|
| `bash .github/scripts/check-labels.sh` | green — `type/feature` now declared |
| `yq '.' .github/ISSUE_TEMPLATE/06-feature.yml` (or `python3 -c "import yaml,sys;yaml.safe_load(open('.github/ISSUE_TEMPLATE/06-feature.yml'))"`) | parses |
| `rg -c 'monthly' .github/dependabot.yml` | ≥ 1 |
| `bash .claude/skills/ds-check/ds-check.sh` | PASSED |

## Out of scope
- Creating any issue. Issues come after PR #1 merges and the labels sync
- Touching the board, the ruleset, or any workflow
- Widening `05-harness.yml`'s dropdown — the point is that runtime work leaves it
