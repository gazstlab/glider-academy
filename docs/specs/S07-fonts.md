# S07 · self-host the three families under COEP

| | |
|---|---|
| Form | `06-feature` |
| Labels | `type/feature` `area/pipeline` `quality/a11y` |
| Size | S |
| Branch | `feat/nn-fonts` |

## Depends on
S02

## Unblocks
S11, S16

## Context

`vercel.json` serves `Cross-Origin-Embedder-Policy: require-corp`. That is the
prerequisite for `SharedArrayBuffer`, which is the only way the stop button can
reach a hung Python run. The price, spelled out in `CONTRIBUTING.md` §7, is that
every cross-origin resource now needs CORP or CORS — so the fonts are
self-hosted, not linked.

The failure mode if they are not is precise and quiet: the page loads without its
typeface, in production, with nothing red anywhere. The lab mockup still carries
a Google Fonts `<link>`, and an agent told to match the mockup will copy it.

Raw `.woff2` files under `public/fonts/`, not an npm font package: a package adds
a lockfile edit and a bundler indirection for no benefit, and the licence files
have to be shipped anyway.

## Reading list
- `CLAUDE.md`
- `docs/orchestration/HANDOFF.md`
- `docs/design-system/DESIGN-SYSTEM.md` §4 — the three families and their roles
- `CONTRIBUTING.md` §7 — what COEP costs
- `vercel.json` — the CORP headers on `/assets/`
- `docs/design-system/DESIGN-SYSTEM.md` §10 — the CLS and `font-display` items

## Files
- `public/fonts/*.woff2` — new
- `public/fonts/LICENSE-*` — new
- `src/styles/fonts.css` — new
- `src/main.tsx` — one import
- `index.html` — preload links only
- `e2e/headers.spec.ts` — new
- `docs/mockups/glider_v2_lab_grid_airflow_aligned.html` — banner only

## Do

1. Vendor Inter (body), Familjen Grotesk (display) and JetBrains Mono (mono) as
   `.woff2`, subset to latin + latin-ext — the product is pt-BR and needs the
   accented range. Ship each licence beside the files.
2. `src/styles/fonts.css`: one `@font-face` per family and weight actually used,
   `font-display: swap`, and fallback metric overrides (`size-adjust`,
   `ascent-override`) so the swap does not shift layout — §10's no-CLS item.
3. Preload only what the first paint needs, in `index.html`. This is one of three
   specs that touch that file; add a block, do not restructure it.
4. `e2e/headers.spec.ts` asserts three things: `crossOriginIsolated` is true; the
   families are loaded (`document.fonts.check`); and — the one that actually
   holds the line — **no request during load has an origin other than the
   page's**. Fail on any.
5. Superseded banner at the top of the lab mockup, next to its Google Fonts link,
   saying it breaks under COEP and pointing at this spec.

## Delivers

### Artifacts
The file list above.

### Surface
Three self-hosted families available to `--gl-font-display`, `-body`, `-mono`.

### Invariants
- **No cross-origin request, ever.** Not fonts, not scripts, not images
- Every family has `font-display: swap` and a metric-matched fallback stack

### Evidence
The headers e2e, both browsers, including the cross-origin assertion.

### Debt
None.

## Acceptance

| Command | Expected |
|---|---|
| `pnpm test:e2e e2e/headers.spec.ts` | green — isolated, fonts loaded, zero cross-origin requests |
| `pnpm build` | fonts emitted under `dist/` |
| `rg -c 'font-display: swap' src/styles/fonts.css` | one per family |
| `rg -ni 'superseded' docs/mockups/glider_v2_lab_grid_airflow_aligned.html` | one hit |
| `bash .claude/skills/ds-check/ds-check.sh` | PASSED |

## Out of scope
- Editing `vercel.json` — the headers are already correct
- Any component or typography scale change
- Removing the mockup's Google Fonts link. A banner, not a rewrite
