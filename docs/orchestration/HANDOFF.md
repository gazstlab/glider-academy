# Handoff

The state of the world, as of the last audited spec.

Overwritten by each spec's implementing agent as its last act, and committed with
the work. It is not a log — it describes what is true now. Why it works that way
is in `docs/orchestration.md` §7.

Read this before starting a spec. Rewrite it before finishing one.

---

**Last audited spec:** S02 — consume tokens.css at runtime without copying it
**Verdict:** BLOCKED on first submission, PASS on re-audit after the spec was
amended and one repair round ran. `spec-auditor` and `ds-reviewer`, both in clean
context, both reproducing the mutations rather than reading the evidence
**Date:** 2026-08-23

**The queue** is issues #6 to #38, filed through the forms. #5 (S00) and #6 (S01)
are closed. **#7 (S02) is this spec** — implemented and repaired once, not yet
re-audited. S02 unblocks **#9 (S04)**, **#12 (S07)**, **#13 (S08)**, **#14 (S09)**
and **#29 (S24)**; **#8 (S03)** is the next one, and was already unblocked by S01.
There are no spec files in the repository — see `docs/orchestration.md` §10.

**#7's fence was amended mid-flight**, on 2026-08-23, to add `vite.config.ts` for
one line. The precedent matters more than the line: a `Do` step that the fence
made undeliverable is a spec bug, and the fix was to widen the fence, not to
improvise a substitute. See the first entry under Debt for what the substitute
would have cost.

## What exists

An application that builds, tests and deploys, carries the full token set at
runtime, and still renders nothing:

| | |
|---|---|
| Design system | `docs/design-system/` — 12 sections, 10 documented components, 19 decisions |
| Tokens | `docs/design-system/tokens.css`, mirrored in `tokens.json`, parity enforced |
| Harness | 3 skills, 6 hooks, 2 agents under `.claude/` — `ds-reviewer` and `spec-auditor` |
| Pipeline | 5 workflows, 6 scripts, 6 issue forms, 28 labels under `.github/` |
| Orchestration | `docs/orchestration.md`, this file. The queue is the open issues |
| Application | `package.json`, `pnpm-lock.yaml`, `src/`, `e2e/` — Vite · React 19 · TypeScript 6 |
| Tokens at runtime | `src/tokens/index.ts` imports `tokens.css` across the `docs/` boundary (**D22**) |
| Layout primitives | `src/styles/base.css` — `.gl-container`, `.gl-prose`, `.gl-nums`, three `@custom-media` breakpoints |

**CI's application jobs are live.** `preflight` sets `app=true` because
`package.json` exists, so `lint`, `tests`, `e2e` and `build` count toward `gate`:
a branch that breaks any of the five scripts cannot merge. The `preview` deploy
job is also eligible, and fails on missing `VERCEL_*` secrets (see Debt).

**The toolchain is installed.** `node -v` is **v22.23.2** (Homebrew `node@22`,
linked as the default), matching `.nvmrc`'s `22`; `pnpm -v` is **11.22.0**,
obtained through `corepack enable`. `nvm` is not on this machine and is not
needed. Do not try to change the Node version.

`src/` holds six files and one type reference. `src/App.tsx` renders
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

### Code — S02

**`src/tokens/index.ts`** is the only bridge between the design system's values
and the running application. It exports exactly two functions:

| | |
|---|---|
| `cssVar(name: string): string` | returns `var(--gl-<name>)` — a reference the browser resolves |
| `readToken(name: string): string` | returns the **computed** value of `--gl-<name>` in the theme active right now |

Both take the token name **without** the `--gl-` prefix: `cssVar('accent')`,
`readToken('state-failed')`. `readToken` reads from `document.documentElement`,
where both `:root` and `:root[data-theme="dark"]` apply, so the answer follows
the theme without the caller tracking it; it is a live read, so call it again
after the theme changes. It is the only sanctioned way to obtain a literal design
value inside `src/` — §8 rule 1 forbids writing one, and S24's Monaco
`defineTheme` cannot take a `var()` reference.

The module's side effect is `import '../../docs/design-system/tokens.css'`. That
is the whole point of the file and it is recorded as **D22**.

**`src/styles/base.css`** holds §6's layout primitives and nothing else.
Component styles live with their component.

| Class | What it is |
|---|---|
| `.gl-container` | `--gl-max-width` cap, `--gl-gutter` inline padding, `border-box` so the gutter is inside the cap |
| `.gl-prose` | `--gl-prose-width` (68ch) cap on running text |
| `.gl-nums` | `--gl-font-mono` + `tabular-nums` — required on any number in a list, grid or instrument |

**The three §6 breakpoints are `@custom-media`, and that is how you use them:**

```css
@custom-media --gl-bp-sm (min-width: 640px);
@custom-media --gl-bp-md (min-width: 900px);   /* D9 */
@custom-media --gl-bp-lg (min-width: 1200px);
```

Write `@media (--gl-bp-md) { ... }`. Lightning CSS compiles it at build time to a
real width query. There is no `--gl-bp-*` custom property and there must not be
one: a custom property is inert inside a media query — both `@media (--gl-bp-md)`
and `min-width: var(--gl-bp-md)` parse and never match — and a spelling that
fails silently next to one that works is a trap, not a convenience.

**`src/main.tsx`** imports `./tokens` then `./styles/base.css`, in that order,
above the existing render call. Nothing else in it changed.

**`vite.config.ts`** gained exactly one key, `css: { lightningcss: { drafts: {
customMedia: true } } }`. Without it Lightning CSS — which Vite 8 uses to minify
even when the transformer is PostCSS — treats `@custom-media` as an unknown
at-rule, **warns**, and passes the declarations through to `dist/` verbatim.
The build stays green either way; that is what makes it dangerous. `worker: {}`
and `optimizeDeps: {}` are still empty and still belong to S16 and S24.

**`e2e/tokens.spec.ts`** — four tests, chromium and firefox, against the built
preview:

1. all 37 named properties (12 semantic roles, 13 state colours, 5 radii, 7
   motion values) resolve non-empty under `:root`
2. the same 37 under `:root[data-theme="dark"]`, **plus** five roles that must
   *differ* between the themes. That second loop is the load-bearing one: the
   audit set `data-theme="darkk"` and all 37 non-empty assertions still passed,
   because every token inherits from `:root`. Do not remove it
3. `base.css` loaded — a probe element takes `.gl-container gl-nums` and its
   computed `max-width` must equal `--gl-max-width` while `font-variant-numeric`
   must be `tabular-nums`. Both are values only `base.css` can produce; with the
   import dropped they are `none` and `normal`
4. the breakpoints compile — the stylesheet the preview serves must contain
   neither `@custom-media` nor `@media (--gl-bp-`, the two spellings that ship
   unresolved. Deleting the `vite.config.ts` line turns this red

The spec reads names and never values: a hard-coded palette would be both a §8
rule 1 violation and the copy this spec exists to avoid.

**Tests 3 and 4 were both verified by mutation**, not by passing. What is *not*
asserted, and is worth knowing: no test proves a `@media (--gl-bp-md)` reference
compiles to a width query, because nothing references one yet — unused
`@custom-media` declarations are consumed and emit nothing. The first spec to
write a responsive rule gets that half for free and should assert it.

### Configuration — S01, unchanged

**Toolchain, pinned.** `packageManager` is the exact string **`pnpm@11.22.0`** —
not a range, because `pnpm/action-setup` reads it and a range fails at setup
before any job runs. `engines.node` is `"22"`, the major in `.nvmrc`, and
`.npmrc` carries `engine-strict=true` and nothing else.

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

**Resolved versions.** Every one of these is in the lockfile:

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

Lightning CSS 1.33.0 is not listed because nothing declares it: it is a direct
dependency of `vite` and is what minifies CSS in Vite 8. That is why a
`css.lightningcss` key works with no dependency added.

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

**`vite.config.ts`** — the react plugin; `worker: {}` and `optimizeDeps: {}`
deliberately empty for S16 and S24; the `css` key above. A local
`crossOriginIsolation` object carrying `Cross-Origin-Opener-Policy: same-origin`
and `Cross-Origin-Embedder-Policy: require-corp` is spread into **both**
`server.headers` and `preview.headers`. Neither inherits from the other, and
`vercel.json` covers production and is not editable by a product spec. The CSS
transformer is still Vite's default, PostCSS, and there is no `postcss.config.js`.

**`playwright.config.ts`** — `testDir: './e2e'`; `webServer.command` is
`pnpm build && pnpm preview` against **`http://localhost:4173`** (port 4173, Vite's
preview default, pinned here so nothing downstream guesses it); `baseURL` is the
same URL; projects are named **`chromium`** and **`firefox`**; reporter is
`html` with `open: 'never'`. Because `webServer` rebuilds, an e2e test may assert
against `dist/` — `e2e/tokens.spec.ts` does, by fetching the stylesheet the
preview serves rather than guessing a hashed filename.

**`vitest.config.ts`** — the react plugin, `environment: 'jsdom'`,
`include: ['src/**/*.{test,spec}.{ts,tsx}']` and
`exclude: ['e2e/**', 'node_modules/**', 'dist/**']`. `e2e/` is kept out twice, by
both keys: Vitest's default include matches `**/*.spec.ts`, so without this
`pnpm test` collects the Playwright specs, imports `@playwright/test` outside a
Playwright runner, and fails for a reason nothing in those files explains.

**`tsconfig.json`** covers `src` only — `strict`, `moduleResolution: "bundler"`,
`jsx: "react-jsx"`, `noEmit`. The CSS side-effect import in `src/tokens/index.ts`
typechecks under `noUncheckedSideEffectImports` because `src/vite-env.d.ts`
references `vite/client`, whose `*.css` ambient module is path-independent — the
file sitting outside `include` does not matter. **`tsconfig.node.json`** covers
`e2e`, `eslint.config.js`, `playwright.config.ts`, `vite.config.ts` and
`vitest.config.ts` under `types: ["node"]`, with `allowJs`/`checkJs` for the
ESLint config and `DOM` in `lib` — which is also what lets `page.evaluate` call
`getComputedStyle`. **No project references** — two explicit `-p` invocations are
legible in a way a reference graph is not.

**`eslint.config.js`** is flat config: `tseslint.config(...)` with an `ignores`
block, `tseslint.configs.recommended`, and
`reactHooks.configs.flat['recommended-latest']` over `**/*.{ts,tsx}`. Note the
`.flat` namespace — the top-level `configs['recommended-latest']` is still
eslintrc-shaped and ESLint 10 rejects it outright.

## Invariants

The ones that hold now, and that no spec may break without a row in
`DECISIONS.md`:

- **`docs/design-system/tokens.css` reaches the browser through exactly one
  import**, the one in `src/tokens/index.ts`. There is no copy of it under
  `src/`, and there must not be one (**D22**)
- **`pnpm build` depends on a path under `docs/`.** Moving or renaming
  `tokens.css` breaks the build. That is the designed failure mode, not an
  accident — loud and immediate, against a copy that rots quietly
- **No `--gl-*` value is ever written literally in `src/`.** `readToken` is the
  only way to obtain a computed one. §8 rule 1's regex catches hex; it does not
  catch a duration or a radius, and the rule still applies
- **`--gl-radius-pill` is always used as a token.** `ds-rules.sh` rule 4 rejects
  a literal `999px` even though §8 permits the pill shape
- **A breakpoint is `@media (--gl-bp-*)`, never a custom property.** The
  `customMedia` line in `vite.config.ts` is what makes that compile, and
  `e2e/tokens.spec.ts` fails if either unresolved spelling reaches `dist/`.
  D9 — no editable canvas below 900px, do not reopen — is the invariant this
  protects: a silently non-matching query un-enforces it with nothing red
- **`base.css` holds layout primitives only.** Component styles live with their
  component. It also carries no reset: nothing normalises margins or
  `box-sizing` globally yet, and the first spec that needs one adds it there
- **All five scripts CI asserts exist and pass.** Removing or breaking one turns
  `preflight` red for everyone on the next pull request
- **`crossOriginIsolated` is true in the built preview, in both browsers.**
  `e2e/smoke.spec.ts` is the guard, and it is the cheapest one there is over three
  separate header configurations
- **No literal string is rendered anywhere in `src/`** until S03 lands the locale
  loader. `index.html`'s `<title>Glider</title>` is the single fixed exception
- **No hex-shaped DOM id or SVG fragment id anywhere in `src/`.** `ds-rules.sh`
  rule 1 matches `#[0-9a-fA-F]{3,8}\b`, so `#app` and `#root` are fine and `#add`
  or `#face` would be reported as a literal colour
- Editing `tokens.css` escalates to a human — that is `tokens-guard.sh` working,
  not failing. `tokens.json` moves with it or `tokens-parity.sh` turns red
- The four §8 checks run on every save of a source file outside `docs/` and
  `.claude/`. `ds-selftest.sh` proves they can still reject
- `pt-BR` is the source locale. A locale that exists is complete
- No task state outside `airflow.utils.state` (D18). No Airflow claim without
  `# verified: <path> @ <tag>` — **including in a code comment or a test**, which
  is where this round found one missing
- Below 900px the lab has no editable canvas (D9, marked do not reopen)
- Every namespaced label referenced under `.github/ISSUE_TEMPLATE/`,
  `.github/workflows/`, `.github/dependabot.yml` or `.github/release.yml` is
  declared in `.github/labels.yml`. `check-labels.sh` enforces it
- `blank_issues_enabled` stays `false` in `.github/ISSUE_TEMPLATE/config.yml`

## Debt

New in S02:

- **Glider draws twelve task states; `TaskInstanceState` has thirteen at 3.3.1.**
  Verified at `airflow-core/src/airflow/utils/state.py` @ 3.3.1 and @ 3.2.2: the
  enum has twelve members through 3.2 and gains `AWAITING_INPUT` — a task parked
  for human input, HITL — at 3.3. Glider's thirteenth `--gl-state-*` is `none`,
  which is not an enum member at all but `State.NONE`, whose value is `None`.
  So the token set is exact against 3.2 and one short against 3.3.1. Nothing was
  added and no decision row was written: the state set is a human decision, and
  the colour would have to enter `tokens.css`, which is escalated by
  construction. **Collector: S09 (#14), "implement StateCell and StateChip over
  the verified state set"** — the spec that has to enumerate the states anyway,
  and the right place to rule on whether Glider covers `AWAITING_INPUT`
- **The three breakpoint values exist in two places** — `src/styles/base.css`
  (`@custom-media`) and `docs/design-system/tokens.json` (`layout.breakpoints`) —
  and nothing checks that they agree. `tokens-parity.sh` compares the set of
  **hex colours** by design (§12), so a breakpoint drift is invisible to it, and
  `tokens.css` carries no breakpoints at all, so there is no third place to move
  them to. Closing this means editing `tokens.css`/`tokens.json`, which is
  human-escalated by construction — hence no decision row here. **Collector: S27
  (#32), "the three resizable panels and the D9 collapse below 900px"** — the
  first spec whose correctness actually depends on the two agreeing
- **`/decision`'s `add.sh` auto-numbers and knows nothing about reservations.**
  It computes the next number from the file's highest row; the coordinator
  pre-assigns. S02 was assigned **D22**, the script returned `D19`, and the row
  was written with the script and then renumbered by hand. D19, D20 and D21 stay
  reserved for **#10**, **#14** and **#15**, which will each renumber the same
  way, and the next `add.sh` call now returns `D23`. **Collector: S05 (#10)** —
  the next spec holding a reserved number, and the point at which the coordinator
  either teaches the script about reservations or accepts the hand-renumber as
  the standing practice

Closed this round: `@custom-media` was carried as debt in the first pass, when
`vite.config.ts` sat outside the fence. The fence was amended and it is now
delivered — no debt, no decision row, nothing owed.

Carried forward:

- **There is no `dev` script.** `README.md` § Running it documents `pnpm dev`,
  and #6 fixed the script list at six with `preview` named as the only permitted
  sixth. Following the spec literally leaves the README describing a command that
  does not exist. `vite` is installed and `pnpm exec vite` works; adding
  `"dev": "vite"` is a one-line fix, and it needs a spec or a coordinator decision
- **TypeScript is 6.0.3, not the 7.0.2 that npm calls latest.** `typescript-eslint`
  8.67.0 — the latest release — refuses to load against the TS 7 API and exits
  `pnpm lint` with a hard error; its peer range is `>=4.8.4 <6.1.0`, and
  `typescript-eslint` issue #10940 tracks support. The TS 7 upgrade is blocked on
  that release, not on anything in this repository. Dependabot will keep proposing
  it; the bump must not merge until `typescript-eslint` ships TS 7 support
- **Playwright browsers are machine state, not a file.** They are installed on
  this machine — `pnpm test:e2e` runs chromium and firefox green. A clean
  checkout still needs `pnpm exec playwright install --with-deps chromium firefox`
  first. CI's `e2e` job already runs it
- **`ripgrep` is required by every `Edit`/`Write` hook**, which fails closed with
  *"ripgrep missing — the §8 checks did not run on this file"* without it.
  Installed here via `brew install ripgrep` (15.2.0), which is what `README.md`
  § Running it prescribes. `jq` is present
- **`index.html`'s `<title>Glider</title>` is a literal string.** S03 decides
  whether it moves to a locale file or stays as a proper noun
- **No test setup file and no `jest-dom`.** The first spec needing richer matchers
  than bare vitest adds both, and adds `test.setupFiles` to `vitest.config.ts`
- **`@axe-core/playwright` is installed and imported by nobody** until S33
- **No fonts, no router, no components:** S07, S04. Tokens are done (S02), but
  `--gl-font-display`, `--gl-font-body` and `--gl-font-mono` currently fall
  through to their fallback stacks — nothing self-hosts a face yet
- **`public/pyodide/` does not exist.** It is already in `.gitignore`; S16 creates
  and populates it
- **No secret is configured.** `PROJECTS_TOKEN` is absent, so the board workflow
  stands down on every issue and PR. `ANTHROPIC_API_KEY` is absent, so the
  contract review does not run. The `VERCEL_*` three are absent — and since
  `app=true`, the `preview` job is eligible on every pull request and **will fail
  on them**. It does **not** take `gate` down: `preview` declares
  `needs: [gate, preflight]` and is not among `gate`'s own `needs`, so it runs
  after the gate has resolved, and the `main` ruleset requires `gate` alone.
  Merges are not blocked; the signal is. All are one-time human steps in
  `docs/pipeline.md`
- **The board itself was never created.** `board-bootstrap.sh` has not been run,
  and the local `gh` token lacks `project` scope
  (`gh auth refresh -s project,read:project` is the one-time human step)
- **The npm Dependabot interval is temporary.** `dependabot.yml` carries
  `interval: monthly` and keeps `day: monday` for when **#38** puts it back to
  weekly
- **`python3` has no `yaml` module** on this machine, and `yq` is not installed.
  Any spec whose acceptance parses YAML needs a venv with `PyYAML`, or
  `ruby -ryaml`
- **The mockups under `docs/mockups/` are exempt from §8** and contain a Google
  Fonts link, raw hex, and a pinwheel §11 arguably forbids. #10 and #12 add
  superseded banners before anyone copies them
