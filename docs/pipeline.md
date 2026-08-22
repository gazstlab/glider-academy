# The pipeline

What runs on its own lives in `.github/`. This file is the rest: the steps a
person performs once, in the right order, and the ones that cannot be
version-controlled because GitHub does not read them from any file.

## Why the pipeline exists

Glider's contract is strong and, until now, ran on exactly one machine. The
hooks fire on `Edit`/`Write` inside a Claude Code session; `/ds-check` depends on
somebody remembering. A commit made outside a session lands without passing
through anything.

The pipeline moves the contract from local discipline to a remote gate — without
duplicating the implementation. `ds-rules.sh` remains the single source of the
§8 checks, and now has three callers instead of two.

## Activation order

Order matters, and getting it wrong locks the repository.

### 1 · Merge the pipeline

The ruleset requires the `gate` check. `gate` only exists after CI has run once.
Enabling the protection first leaves every PR waiting on a check that will never
report.

### 2 · Enable the main ruleset

```bash
bash .github/scripts/ruleset.sh --dry-run   # inspect what will be created
bash .github/scripts/ruleset.sh
```

### 3 · Sync the labels

The workflow runs on its own on the first push touching `.github/labels.yml`.
To avoid waiting:

```bash
gh workflow run labels-sync.yml
```

Labels have to exist **before** the first issue: a label referenced by a form
but missing from the repository is discarded silently by GitHub, and the issue
opens with no classification at all.

### 4 · Vercel

```bash
gh secret set VERCEL_TOKEN      --repo gazstlab/glider-academy
gh secret set VERCEL_ORG_ID     --repo gazstlab/glider-academy
gh secret set VERCEL_PROJECT_ID --repo gazstlab/glider-academy
```

`ORG_ID` and `PROJECT_ID` come from running `vercel link` in the project, in
`.vercel/project.json`.

**In the Vercel dashboard, confirm the Git integration is off.** `vercel.json`
already carries `"github": { "enabled": false }`, but check anyway: with it on,
Vercel deploys on push, in parallel with CI, and the preview goes up even with
CI red. The gate becomes decoration without anything turning red.

### 5 · Contract review

```bash
gh secret set ANTHROPIC_API_KEY --repo gazstlab/glider-academy
```

### 6 · Board

Projects v2 cannot be configured from a file — there is no `board.yml` GitHub
reads. The bootstrap script is as close as it gets.

```bash
gh auth refresh -s project,read:project
bash .github/scripts/board-bootstrap.sh
```

The script prints the project number. Confirm it matches `PROJECT_NUMBER` in
`.github/workflows/project.yml`.

Then the token the workflow uses. **The runner's `GITHUB_TOKEN` cannot reach
Projects v2** — the number one cause of "the workflow went green and the card
did not move". Create a fine-grained PAT with Projects read/write:

```bash
gh secret set PROJECTS_TOKEN --repo gazstlab/glider-academy
```

## Who blocks what

| Layer | What it catches | Blocks merge? |
|---|---|---|
| Local hook (`Edit`/`Write`) | the four §8 checks on the saved file | yes, immediately |
| Job `contract` | the same checks across the repository, the selftest, locale parity, token parity, labels | **yes** |
| Job `shell` | shellcheck and actionlint — the harness and the pipeline itself | **yes** |
| Application jobs | lint, types, tests, e2e, axe, build | **yes**, once there is an application |
| Job `gate` | aggregates all of the above. The only required check in the ruleset | **yes** |
| Contract review | rule 12, invented state, §5.4/§5.5, §9, §11 | no, comments |
| You | the §10 floor, `tokens.css`, the line in `DECISIONS.md` | yes, you are the one merging |

## Four traps this pipeline disarms on purpose

**A skipped job counts as success.** A required check pointing straight at
`tests` switches itself off the day that job is skipped by a condition or by a
typo in an `if:`. That is why the only required check is `gate`, which
explicitly distinguishes "skipped because there is no application yet" from
"skipped because a dependency fell".

**A check that only knows how to pass.** Today `gl_is_source` excludes `docs/`
and `.claude/`, and there is no `src/` — so `/ds-check` sweeps zero files and
prints "ok". `ds-selftest.sh` exercises every §8 rule against a case it must
reject. A new check without a case there is a check nobody knows works.

**A missing tool turns green.** The checks are `if hit=$(rg ...)`. Without
ripgrep the command exits 127, the condition is false, and the file passes for
never having been read. `preflight.sh` refuses up front, and `gl_check_file`
fails rather than passes when it cannot find `rg`.

**A half-translated locale.** Missing keys fall back silently. Nothing errors;
the learner just gets a screen in two languages. `check-locales.sh` compares key
sets in both directions and fails on any drift, so a locale is either absent or
complete.

All four have the same shape: the failure looks like success. It is the one
failure mode a gate cannot have, because nobody investigates a green check.

## When something gets stuck

| Symptom | Likely cause |
|---|---|
| PR will not merge, `gate` pending forever | ruleset enabled before CI existed on main |
| Issue opens with no labels | `labels.yml` not synced yet |
| Card does not move, workflow green | `PROJECTS_TOKEN` missing, or a column renamed in the browser |
| `Resource not accessible` on the board | token without the `project` scope |
| Preview goes up with CI red | Vercel's Git integration switched back on in the dashboard |
| Pyodide fails to initialise in production | COOP/COEP not served — see the smoke job |
| CI fails on locale parity | an `en` file was started and left incomplete. Finish it or remove it |
