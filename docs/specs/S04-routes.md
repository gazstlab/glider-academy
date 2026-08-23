# S04 · route home, track and lab and reserve their layout

| | |
|---|---|
| Form | `06-feature` |
| Labels | `type/feature` `area/lab` |
| Size | S |
| Branch | `feat/nn-routes` |

## Depends on
S01, S02

## Unblocks
S11, S29, S32

## Context

Three screens exist in the design system as scales of one signature — the home
row of fifteen cells, the track index, and the lab's real grid (§2). This spec
makes them addressable and nothing more: three routed landmarks with their height
reserved, so that the components landing later drop into a layout that already
holds its shape.

Reserving height now rather than later is the §10 no-CLS item, and it is far
cheaper to get right in an empty file than to retrofit under a mounted Monaco and
a Pyodide boot.

`vercel.json` rewrites every path to `index.html`. That rewrite is untested, and
a deep link is exactly what a learner shares.

## Reading list
- `CLAUDE.md`
- `docs/orchestration/HANDOFF.md`
- `docs/design-system/DESIGN-SYSTEM.md` §2 — the three scales, §6 — layout
- `vercel.json` — the `rewrites` block

## Files
- `src/routes.tsx` — new
- `src/screens/Home.tsx`, `src/screens/Track.tsx`, `src/screens/Lab.tsx` — new
- `src/App.tsx` — mount the router
- `e2e/routing.spec.ts` — new

## Do

1. `src/routes.tsx` with `/` → Home, `/trilha` → Track, `/licao/:id` → Lab.
   Paths are product-facing and therefore pt-BR, like every other product string.
2. Each screen is a `<main>` landmark with `min-height` reserved from the
   `--gl-space-*` scale and `.gl-container` applied. No copy — S03's ESLint rule
   forbids a literal in `src/screens/**`, and the copy for these screens does not
   exist yet.
3. `e2e/routing.spec.ts` loads `/licao/04` **directly**, not by clicking through,
   and asserts the landmark renders — that is the assertion that proves the
   Vercel rewrite and the Vite preview agree.

## Delivers

### Artifacts
The file list above.

### Surface
`src/routes.tsx` exports the router. `src/screens/{Home,Track,Lab}.tsx` each
default-export a component.

### Invariants
- Every screen is a `<main>` landmark with height reserved before mount
- Route paths are pt-BR and stable — a shared link must not break

### Evidence
The routing e2e, both browsers.

### Debt
The screens are empty. S29 fills Home, S32 fills Lab, Track waits for a later
round.

## Acceptance

| Command | Expected |
|---|---|
| `pnpm test:e2e e2e/routing.spec.ts` | green — `/licao/04` resolves on a cold load |
| `pnpm lint && pnpm typecheck && pnpm build` | clean |
| `bash .claude/skills/ds-check/ds-check.sh` | PASSED |

## Out of scope
- Any component, header, footer or navigation
- Any copy
- Progress, lesson data or state — S23 and S30
