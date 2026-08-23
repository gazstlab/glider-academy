# Handoff

The state of the world, as of the last audited spec.

Overwritten by each spec's implementing agent as its last act, and committed with
the work. It is not a log — it describes what is true now. Why it works that way
is in `docs/orchestration.md` §7.

Read this before starting a spec. Rewrite it before finishing one.

---

**Last audited spec:** S01 — scaffold the Vite skeleton the five CI scripts call
**Verdict:** PASS — `spec-auditor` and `ds-reviewer`, both in clean context
**Date:** 2026-08-23

**The queue** is issues #6 to #38, filed through the forms. #5 (S00) is closed and
#6 (S01) is this spec. S01 unblocks **#7 (S02)**, **#8 (S03)**, **#9 (S04)** and
**#21 (S16)**; #7 is the next one. There are no spec files in the repository — see
`docs/orchestration.md` §10.

## What exists

An application that builds, tests and deploys, and renders nothing:

| | |
|---|---|
| Design system | `docs/design-system/` — 12 sections, 10 documented components, 18 decisions |
| Tokens | `docs/design-system/tokens.css`, mirrored in `tokens.json`, parity enforced |
| Harness | 3 skills, 6 hooks, 2 agents under `.claude/` — `ds-reviewer` and `spec-auditor` |
| Pipeline | 5 workflows, 6 scripts, 6 issue forms, 28 labels under `.github/` |
| Orchestration | `docs/orchestration.md`, this file. The queue is the open issues |
| Application | `package.json`, `pnpm-lock.yaml`, `src/`, `e2e/` — Vite · React 19 · TypeScript 6 |

**CI's application jobs are now live.** `preflight` sets `app=true` because
`package.json` exists, and `lint`, `tests`, `e2e` and `build` stop skipping
themselves and start counting toward `gate`. From this spec on, a branch that
breaks any of the five scripts cannot merge. The `preview` deploy job also
becomes eligible — and will fail on missing `VERCEL_*` secrets (see Debt).

**The toolchain is installed** — S00 listed its absence as debt and it is now
closed. `node -v` is **v22.23.2** (Homebrew `node@22`, linked as the default),
matching `.nvmrc`'s `22`; `pnpm -v` is **11.22.0**, obtained through
`corepack enable`. `nvm` is not on this machine and is not needed. Do not try to
change the Node version.

`src/` holds three files and one type reference. `src/App.tsx` renders
`<main id="app" />` and **contains no strings at all**, so §9 cannot be violated
before S03 lands the locale loader.

Every dependency the queue will need is already in the lockfile, including ones
nothing imports yet (`pyodide`, `monaco-editor`, `react-router-dom`,
`@axe-core/playwright`). `pnpm-lock.yaml` does not auto-merge; five specs each
adding one dependency is the worst conflict class in this build-out, and landing
them together removes it. **Do not add a dependency unless your spec says to.**

The `main` ruleset is active: `gate` is a required check, squash is the only
merge method, history is linear, and `bypass_actors` is empty.

## Surface

This spec's surface is configuration, not symbols.

**Toolchain, pinned.** `packageManager` is the exact string **`pnpm@11.22.0`** —
not a range, because `pnpm/action-setup` reads it and a range fails at setup
before any job runs. `engines.node` is `"22"`, the major in `.nvmrc`, and
`.npmrc` carries `engine-strict=true` and nothing else, so that major is enforced
rather than advisory.

**The six scripts**, verbatim:

| Script | Command |
|---|---|
| `build` | `vite build` |
| `preview` | `vite preview` |
| `lint` | `eslint .` |
| `typecheck` | `tsc --noEmit -p tsconfig.json && tsc --noEmit -p tsconfig.node.json` |
| `test` | `vitest run` |
| `test:e2e` | `playwright test` |

`typecheck` is two invocations on purpose: a bare `tsc --noEmit` reads
`tsconfig.json` only, and `tsconfig.node.json` — which covers `e2e/` and the four
config files — would never be opened. `build` does not run `tsc`; `typecheck`
already does, and duplicating it makes two CI jobs fail for one cause.

**Resolved versions.** Every one of these is in the lockfile now:

| dependencies | | devDependencies | |
|---|---|---|---|
| `monaco-editor` | 0.56.0 | `@axe-core/playwright` | 4.13.0 |
| `pyodide` | 314.0.5 | `@playwright/test` | 1.62.1 |
| `react` | 19.2.8 | `@testing-library/react` | 16.3.2 |
| `react-dom` | 19.2.8 | `@types/node` | 26.2.0 |
| `react-router-dom` | 7.18.2 | `@types/react` | 19.2.18 |
| | | `@types/react-dom` | 19.2.4 |
| | | `@vitejs/plugin-react` | 6.1.0 |
| | | `eslint` | 10.9.0 |
| | | `eslint-plugin-react-hooks` | 7.1.1 |
| | | `jsdom` | 30.0.1 |
| | | `typescript` | 6.0.3 |
| | | `typescript-eslint` | 8.67.0 |
| | | `vite` | 8.2.2 |
| | | `vitest` | 4.1.11 |

The three `@types/*` packages are not in #6's dependency list. They are not a
widening of it: React 19 ships no bundled types, so `strict` + `jsx: react-jsx`
does not typecheck without them, and `tsconfig.node.json`'s mandated Node types
are `@types/node` by definition.

**Code.**

- `src/App.tsx` default-exports `App`, rendering `<main id="app" />`. No props,
  no children, no text
- `src/main.tsx` mounts into the DOM id **`root`**, which `index.html` declares as
  `<div id="root"></div>`. The entry `index.html` points at is **`/src/main.tsx`**
- `index.html` is `lang="pt-BR"` with `<title>Glider</title>` and no other string
- `src/App.test.tsx` uses bare vitest matchers. There is no setup file and no
  `jest-dom`

**`vite.config.ts`** — the react plugin, plus `worker: {}` and
`optimizeDeps: {}`, deliberately empty for S16 and S24 to fill. A local
`crossOriginIsolation` object carrying `Cross-Origin-Opener-Policy: same-origin`
and `Cross-Origin-Embedder-Policy: require-corp` is spread into **both**
`server.headers` and `preview.headers`. Neither inherits from the other, and
`vercel.json` covers production and is not editable by a product spec.

**`playwright.config.ts`** — `testDir: './e2e'`; `webServer.command` is
`pnpm build && pnpm preview` against **`http://localhost:4173`** (port 4173, Vite's
preview default, pinned here so nothing downstream guesses it); `baseURL` is the
same URL; projects are named **`chromium`** and **`firefox`**; reporter is
`html` with `open: 'never'`.

**`vitest.config.ts`** — the react plugin, `environment: 'jsdom'`,
`include: ['src/**/*.{test,spec}.{ts,tsx}']` and
`exclude: ['e2e/**', 'node_modules/**', 'dist/**']`. `e2e/` is kept out twice, by
both keys: Vitest's default include matches `**/*.spec.ts`, so without this
`pnpm test` collects `e2e/smoke.spec.ts`, imports `@playwright/test` outside a
Playwright runner, and fails for a reason nothing in that file explains.

**`tsconfig.json`** covers `src` only — `strict`, `moduleResolution: "bundler"`,
`jsx: "react-jsx"`, `noEmit`. **`tsconfig.node.json`** covers `e2e`,
`eslint.config.js`, `playwright.config.ts`, `vite.config.ts` and
`vitest.config.ts` under `types: ["node"]`, with `allowJs`/`checkJs` for the
ESLint config and `DOM` in `lib` for the `crossOriginIsolated` assertion inside
`page.evaluate`. **No project references** — two explicit `-p` invocations are
legible in a way a reference graph is not.

**`eslint.config.js`** is flat config: `tseslint.config(...)` with an `ignores`
block, `tseslint.configs.recommended`, and
`reactHooks.configs.flat['recommended-latest']` over `**/*.{ts,tsx}`. Note the
`.flat` namespace — the top-level `configs['recommended-latest']` is still
eslintrc-shaped and ESLint 10 rejects it outright.

## Invariants

The ones that hold now, and that no spec may break without a row in
`DECISIONS.md`:

- **All five scripts CI asserts exist and pass.** Removing or breaking one turns
  `preflight` red for everyone on the next pull request
- **`crossOriginIsolated` is true in the built preview, in both browsers.**
  `e2e/smoke.spec.ts` is the guard, and it is the cheapest one there is over three
  separate header configurations
- **No literal string is rendered anywhere in `src/`** until S03 lands the locale
  loader. `index.html`'s `<title>Glider</title>` is the single fixed exception
- **No hex-shaped DOM id or SVG fragment id anywhere in `src/`.** `ds-rules.sh`
  rule 1 matches `#[0-9a-fA-F]{3,8}\b`, so `#app` and `#root` are fine and `#add`
  or `#face` would be reported as a literal colour. The convention starts here
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
  declared in `.github/labels.yml`. `check-labels.sh` enforces it
- `blank_issues_enabled` stays `false` in `.github/ISSUE_TEMPLATE/config.yml`

## Debt

- **There is no `dev` script.** `README.md` § Running it documents `pnpm dev`,
  and #6 fixes the script list at six with `preview` named as the only permitted
  sixth. Following the spec literally leaves the README describing a command that
  does not exist. `vite` is installed and `pnpm exec vite` works; adding
  `"dev": "vite"` is a one-line fix, and it needs a spec or a coordinator decision
  rather than an agent's improvisation
- **TypeScript is 6.0.3, not the 7.0.2 that npm calls latest.** `typescript-eslint`
  8.67.0 — the latest release — refuses to load against the TS 7 API and exits
  `pnpm lint` with a hard error; its peer range is `>=4.8.4 <6.1.0`, and
  `typescript-eslint` issue #10940 tracks support. The TS 7 upgrade is blocked on
  that release, not on anything in this repository. Dependabot will keep proposing
  it; the bump must not merge until `typescript-eslint` ships TS 7 support
- **Playwright browsers are machine state, not a file.** A clean checkout needs
  `pnpm exec playwright install --with-deps chromium firefox` before
  `pnpm test:e2e`. CI's `e2e` job already runs it; a local agent must run it once
- **`ripgrep` was missing on this machine** and every `Edit`/`Write` hook failed
  closed with *"ripgrep missing — the §8 checks did not run on this file"*.
  Installed via `brew install ripgrep` (15.2.0), which is what `README.md`
  § Running it prescribes. `jq` was already present
- **`index.html`'s `<title>Glider</title>` is a literal string.** S03 decides
  whether it moves to a locale file or stays as a proper noun
- **No test setup file and no `jest-dom`.** Neither is in #6's fence. The first
  spec needing richer matchers than bare vitest adds both, and adds
  `test.setupFiles` to `vitest.config.ts`
- **`@axe-core/playwright` is installed and imported by nobody** until S33
- **No tokens, no fonts, no router, no components:** S02, S07, S04
- **`public/pyodide/` does not exist.** It is already in `.gitignore`; S16 creates
  and populates it
- **No secret is configured.** `PROJECTS_TOKEN` is absent, so the board workflow
  stands down on every issue and PR. `ANTHROPIC_API_KEY` is absent, so the
  contract review does not run. The `VERCEL_*` three are absent — and now that
  `app=true`, the `preview` job is eligible on every pull request and **will fail
  on them** — a red X on every PR from this spec on. It does **not** take `gate`
  down: `preview` declares `needs: [gate, preflight]` and is not among `gate`'s
  own `needs`, so it runs after the gate has already resolved, and the `main`
  ruleset requires `gate` alone. Merges are not blocked; the signal is. All are
  one-time human steps in `docs/pipeline.md`
- **The board itself was never created.** `board-bootstrap.sh` has not been run,
  and the local `gh` token lacks `project` scope
  (`gh auth refresh -s project,read:project` is the one-time human step)
- **The npm Dependabot interval is temporary.** `dependabot.yml` carries
  `interval: monthly` and keeps `day: monday` for when **#38** puts it back to
  weekly. It now has a `package.json` to act on for the first time
- **`python3` has no `yaml` module** on this machine, and `yq` is not installed.
  Any spec whose acceptance parses YAML needs a venv with `PyYAML`, or
  `ruby -ryaml`
- **The mockups under `docs/mockups/` are exempt from §8** and contain a Google
  Fonts link, raw hex, and a pinwheel §11 arguably forbids. #10 and #12 add
  superseded banners before anyone copies them
