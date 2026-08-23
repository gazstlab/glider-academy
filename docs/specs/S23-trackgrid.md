# S23 · implement §5.6 TrackGrid and persist progress

| | |
|---|---|
| Form | `02-component` |
| Labels | `type/component` `area/design-system` |
| Size | S |
| Branch | `feat/nn-trackgrid` |

## Depends on
S03, S09

## Unblocks
S29, S32

## Context

The third scale of the signature (§2): the same grid, one cell per lesson,
showing where the learner stopped. Fifteen cells, coloured by state.

The rule attached to it is the one people break by reflex. §8 rule 8 and D13:
**progress is a grid column, and a percentage bar does not exist in this
product.** The fallback for assistive technology is a `role="progressbar"` with
`aria-valuenow`/`min`/`max` plus the text `Lição 4 de 15` — which is a semantic
fallback, not a visual one, and does not license drawing a bar.

Progress is per-browser and per-device. There is no backend, so nothing about it
can be assumed to exist, survive, or be shareable.

## Reading list
- `CLAUDE.md`
- `docs/orchestration/HANDOFF.md`
- `docs/design-system/DESIGN-SYSTEM.md` §2, §5.6, §8
- `docs/design-system/DECISIONS.md` — D7, D13
- `README.md` § What this is — the no-backend constraint

## Files
- `src/ui/TrackGrid.tsx`, `TrackGrid.module.css`, `TrackGrid.test.tsx` — new
- `src/progress/store.ts`, `store.test.ts` — new
- `src/locales/pt-BR/common.json` — the progress strings

## Do

1. `src/progress/store.ts`: `getProgress()`, `setLessonState(id, state)`, over a
   **versioned** `localStorage` key, every read and write in `try/catch`. A
   private window, cleared site data or a browser blocking storage must render a
   correct empty track, not an error.
2. `TrackGrid` — 15 cells built from `StateCell`, coloured `success`, `running`
   or `queued`. The `role="progressbar"` fallback with `Lição 4 de 15` from a
   locale file.
3. `04 / 15` beside it in mono with `tabular-nums`, per §4 and §8 required rule 2.
4. Tests: fifteen cells; the fallback carries the right values; a storage read
   that throws still renders; and no element with a percentage width appears.

## Delivers

### Artifacts
The file list above.

### Surface
`src/ui/TrackGrid.tsx` exports `TrackGrid`. `src/progress/store.ts` exports
`getProgress()`, `setLessonState()`.

### Invariants
- **No percentage bar.** Progress is a grid column
- Storage failure degrades to an empty track, never to an error
- The key is versioned, so a shape change does not crash an old browser

### Evidence
The unit tests, including the throwing-storage case.

### Debt
Progress does not sync anywhere. There is no backend by design — this is a
constraint, not debt, and is recorded so nobody schedules it.

## Acceptance

| Command | Expected |
|---|---|
| `pnpm test src/ui/TrackGrid.test.tsx src/progress` | green |
| `rg -n 'width:\s*\d+%' src/ui/TrackGrid.module.css` | no hits |
| `pnpm lint && pnpm typecheck` | clean |
| `bash .claude/skills/ds-check/ds-check.sh` | PASSED |

## Out of scope
- The track index screen
- Any percentage anywhere
- Lesson content — S30, S31
