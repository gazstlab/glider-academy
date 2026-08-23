# S01 · scaffold the Vite skeleton the five CI scripts call

| | |
|---|---|
| Form | `06-feature` |
| Labels | `type/feature` `area/pipeline` |
| Size | M |
| Branch | `feat/nn-scaffold` |

## Depends on
S00

## Unblocks
S02, S03, S04, S16

## Context

`ci.yml`'s `preflight` job asserts that the instant `package.json` exists, it
defines all five of `lint`, `typecheck`, `test`, `test:e2e` and `build`. The
`lint`, `tests`, `e2e` and `build` jobs then stop skipping themselves and start
counting toward `gate`, which is the only required check on `main`. A scaffold
that lands `build` but not `test:e2e` turns the pipeline red for everyone on the
next pull request.

So this spec is irreducibly a full sitting, and it is bounded not by size but by
an exhaustive file list: no components, no tokens, no router, no product copy.
`src/App.tsx` renders an empty landmark and contains no strings at all, so §9
cannot be violated before the locale loader exists.

It also lands every dependency the queue will need, including ones nothing
imports yet. `pnpm-lock.yaml` does not auto-merge; five specs adding a dependency
at five different times is the worst conflict class in this build-out, and one
line of explanation here removes it entirely.

## Reading list
- `CLAUDE.md`
- `docs/orchestration/HANDOFF.md`
- `README.md` § Stack, § Running it
- `.github/workflows/ci.yml` — the `preflight` and `gate` jobs
- `vercel.json`
- `.gitignore`
- `.nvmrc`

## Files
- `package.json`, `pnpm-lock.yaml`, `.npmrc`
- `tsconfig.json`, `tsconfig.node.json`
- `vite.config.ts`
- `eslint.config.js`
- `vitest.config.ts`
- `playwright.config.ts`
- `index.html`
- `src/main.tsx`, `src/App.tsx`, `src/App.test.tsx`, `src/vite-env.d.ts`
- `e2e/smoke.spec.ts`

## Do

1. `package.json` targeting the Node version in `.nvmrc` — read it, do not assume
   it — and a `"packageManager"` field pinning the **exact** pnpm version, not a
   range. Without it `pnpm/action-setup` fails at setup and every application job
   dies before running anything. Pin what `pnpm --version` resolves to, and
   record that exact string in `Surface`: every later spec inherits it, and a
   version nobody wrote down is a version that drifts.
2. The five scripts CI asserts, each doing real work: `lint` (eslint),
   `typecheck`, `test` (`vitest run`), `test:e2e` (`playwright test`), `build`
   (`vite build`). A **sixth**, `preview`, is permitted and needed — Playwright's
   `webServer` calls it. `preflight` asserts the five exist; it does not forbid
   a sixth.
   `typecheck` is **two invocations**, not one:
   `tsc --noEmit -p tsconfig.json && tsc --noEmit -p tsconfig.node.json`. A bare
   `tsc --noEmit` reads `tsconfig.json` and nothing else, which would leave the
   second config a file this spec creates and the toolchain never opens — and the
   acceptance row below asserts `e2e/` and the config files are covered.
   Also set `"type": "module"`. Without it, `eslint.config.js` — flat config,
   written with `import` — dies with a syntax error that reads like an ESLint
   bug rather than a packaging one.
   Keep `tsc` out of `build`: `typecheck` already runs it, and having `build`
   repeat it makes two CI jobs fail together for one cause.
3. Dependencies, all of them now: `react`, `react-dom`, `react-router-dom`,
   `pyodide`, `monaco-editor`; dev: `vite`, `@vitejs/plugin-react`, `typescript`,
   `typescript-eslint`, `eslint`, `eslint-plugin-react-hooks`, `vitest`, `jsdom`,
   `@testing-library/react`, `@playwright/test`, `@axe-core/playwright`.
   Record every **resolved** version in `Surface` — the anti-conflict argument
   for landing them all here fails if S16 cannot tell which `pyodide` is in the
   lockfile. Explain the batching in `Debt`, for the coordinator to carry into
   the PR body; you do not open the PR yourself.
4. `.npmrc`: `engine-strict=true`, so the Node version in `.nvmrc` is enforced
   rather than advisory. Nothing else — an empty `.npmrc` satisfies the fence and
   silently enforces nothing.
   Set `engines.node` to the **major** in `.nvmrc`, as `"22"` and not `">=22"`:
   a range with `engine-strict` on enforces nothing that matters, and CI pins the
   same major through `.nvmrc`. Work under that major — `nvm use` — and get pnpm
   from `corepack enable`, so the version you pin in step 1 is the version the
   lockfile was resolved by. If your shell is on another major, switching is part
   of the work, not a reason to relax the setting.
5. `tsconfig.json` for the application — `strict`, `moduleResolution: "bundler"`,
   `jsx: "react-jsx"`, `noEmit`, including `src/` only. `tsconfig.node.json`
   covers `e2e/` and the config files, under Node types. Step 2's second
   invocation is what reaches it.
   **No project references.** They would require `tsc -b`, and two explicit `-p`
   invocations are legible in a way a reference graph is not — an agent reading
   the script can see exactly what is typechecked.
6. `vite.config.ts` with the react plugin and — pre-written now so S16 and S24
   only fill in values — empty `worker`, `optimizeDeps` and, critically, both
   `server.headers` **and** `preview.headers` carrying
   `Cross-Origin-Opener-Policy: same-origin` and
   `Cross-Origin-Embedder-Policy: require-corp`. Dev and the Playwright preview
   each need their own; `vercel.json` covers production and is not yours to edit.
7. `vitest.config.ts`: `environment: 'jsdom'`, and — the step that is easy to
   miss and expensive to debug — **`exclude` must cover `e2e/`**. Vitest's
   default include matches `**/*.spec.ts`, so without it `pnpm test` collects
   `e2e/smoke.spec.ts`, imports `@playwright/test` outside a Playwright runner,
   and fails the "1 test green" acceptance for a reason nothing else in this
   spec would explain.
8. `playwright.config.ts` with `webServer` running `pnpm build && pnpm preview`,
   `url: 'http://localhost:4173'` — Vite's preview default, pinned here so that
   nothing downstream has to guess it — and projects chromium and firefox. Browsers come from `pnpm exec playwright install --with-deps chromium
   firefox` — machine state, not a file. CI's `e2e` job already runs it; run it
   locally to produce your evidence and note it in `Debt`.
9. `index.html`: the mount point, `lang="pt-BR"`, and `<title>Glider</title>` —
   that exact string, and no other. A product name is a proper noun rather than
   copy, which is why it is nameable here and why the spec fixes it instead of
   leaving you to invent one. Anything longer would be a tagline, and a tagline
   is copy: it belongs in a locale file and therefore in S03. Record the title in
   `Debt` so S03 decides whether it stays.
10. `src/App.tsx` renders `<main id="app" />` and nothing else. No text.
11. `src/App.test.tsx` asserts the landmark renders, using bare vitest matchers —
    no `jest-dom`, no setup file, neither is in the fence. `e2e/smoke.spec.ts`
    asserts `#app` exists **and `crossOriginIsolated === true`** — the cheapest
    possible guard on the three separate header configurations, and it belongs in
    the first spec rather than the COEP one.

## Delivers

### Artifacts
The file list above.

### Surface
This spec's surface is configuration, not symbols. Record the **values**, so the
next spec never has to open your files to find them:
- The exact `packageManager` string, and the resolved version of every dependency
- The six `package.json` scripts, with their exact command strings
- `src/App.tsx` default-exports `App`, rendering `<main id="app" />`
- The DOM id `src/main.tsx` mounts into, and the entry `index.html` points at
- `vite.config.ts` — the empty `worker` / `optimizeDeps` blocks S16 and S24 fill,
  and the COOP/COEP pairs in both `server.headers` and `preview.headers`
- `playwright.config.ts` — the `webServer` command, the preview URL and port, and
  the project names
- `vitest.config.ts` — the `environment`, and the `exclude` keeping `e2e/` out

### Invariants
- All five scripts exist and pass. Removing one turns `preflight` red
- `crossOriginIsolated` is true in the built preview, in both browsers
- No literal string is rendered anywhere in `src/` until S03 lands the loader
- **No hex-shaped DOM id or SVG fragment id anywhere in `src/`.** `ds-rules.sh`
  rule 1 matches `#[0-9a-fA-F]{3,8}\b`, so `#app` is fine and `#add` or `#face`
  would be reported as a literal colour. The convention starts here because this
  is the spec that writes the first id

### Evidence
Every command in the Acceptance table, with its real output.

### Debt
- `public/pyodide/` is already gitignored — the entry is in `.gitignore`, which
  is outside this fence. S16 creates and populates it
- No tokens, no fonts, no router: S02, S07, S04
- `index.html`'s `<title>` is a literal string. S03 moves it to a locale file
- No test setup file and no `jest-dom`. The first spec needing richer matchers
  adds both
- `@axe-core/playwright` is installed and imported by nobody until S33
- Playwright browsers are machine state. A clean checkout needs
  `pnpm exec playwright install` before `pnpm test:e2e`

## Acceptance

`--frozen-lockfile` cannot be the first command on the spec that creates the
lockfile. Run `pnpm install` once to generate it; the frozen run below is the
re-run that proves it is complete, which is what CI does.

| Command | Expected |
|---|---|
| `pnpm install`, then `pnpm install --frozen-lockfile` | the second resolves with no change to the lockfile |
| `pnpm lint` | no errors |
| `pnpm typecheck` | no errors, and **both** configs invoked — `e2e/` and the config files are covered |
| `pnpm test` | 1 test green, and **`e2e/` not collected** |
| `pnpm build` | `dist/` produced |
| `pnpm test:e2e` | green in chromium and firefox, `crossOriginIsolated` true |
| `bash .claude/skills/ds-check/ds-check.sh` | PASSED |

## Out of scope
- Any component, token, style or route
- Any product copy, in any language. `<title>Glider</title>` is the single
  exception, fixed verbatim in `Do` 9 — a product name, not a line of copy
- Pyodide, Monaco or fonts — declared as dependencies, imported by nobody
- Touching `vercel.json` or any workflow
