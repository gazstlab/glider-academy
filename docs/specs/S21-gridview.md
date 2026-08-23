# S21 · implement §5.4 GridView as a table with a text alternative

| | |
|---|---|
| Form | `02-component` |
| Labels | `type/component` `area/design-system` `quality/a11y` `quality/keyboard` |
| Size | M |
| Branch | `feat/nn-gridview` |

## Depends on
S03, S09, S15

## Unblocks
S32

## Context

The signature of the whole product. §2 calls the grid of squares the thing the
learner should recognise in a real Airflow in the first second, and §5.4 attaches
three non-negotiables to it: it is a semantic `<table>` and not divs, every cell
is focusable with an `aria-label` that spells the state out — `limpar · run
2026-08-22 · falhou` — and a text-list alternative exists.

Those are not decorations on a visual component. A grid of coloured squares is
the least accessible way to present a matrix, and the three requirements are what
make it presentable at all. §8's rule about state never being carried by colour
alone applies most sharply here, because this is where a colour-blind reader
meets `lime` next to `green`.

Progress is a grid column. There is no percentage bar in this product, and adding
one is a rule 8 violation regardless of how it looks.

## Reading list
- `CLAUDE.md` § The twelve rules
- `docs/orchestration/HANDOFF.md`
- `docs/design-system/DESIGN-SYSTEM.md` §2, §5.2, §5.4, §7, §8, §9
- `docs/design-system/DECISIONS.md` — D8, D13
- `docs/specs/S15-use-dag-run.md` § Delivers

## Files
- `src/ui/GridView.tsx`, `GridView.module.css`, `GridView.test.tsx` — new
- `src/ui/GridList.tsx`, `GridList.test.tsx` — new
- `src/locales/pt-BR/grid.json` — new

## Do

1. A real `<table>` with a `<caption>`, `scope` on every header, rows as tasks and
   columns as runs, most recent on the right. Column headers mono with the
   logical date.
2. Roving tabindex: one tab stop into the grid, arrow keys between cells, Enter
   selects. Every cell's `aria-label` is assembled from `grid.json` and
   `states.json` — task id, run date, state spelled out in pt-BR.
3. Hover highlights the whole row and column, per §5.4.
4. `GridList` — the text alternative. **Present in the DOM and reachable by a
   real control**, not a screen-reader-only afterthought and not behind a media
   query.
5. Subscribe per cell through S15's store so a tick repaints only what changed.
6. Tests: table semantics; every cell reachable and labelled; the list
   alternative renders the same data; and a run with `upstream_failed` and
   `skipped` present renders glyph plus text for both.

## Delivers

### Artifacts
The file list above.

### Surface
`src/ui/GridView.tsx` exports `GridView` and
`GridViewProps { runs: DagRun[]; taskOrder: TaskId[]; onSelect(taskId, runId): void }`.
`src/ui/GridList.tsx` exports `GridList`.

### Invariants
- A semantic `<table>`. Never divs with grid roles
- Every cell focusable, with the state spelled out in its `aria-label`
- The text alternative exists and is reachable without assistive technology
- No percentage bar. Progress is a column
- Only `running` animates

### Evidence
The unit tests, including the semantics and labelling assertions.

### Debt
Virtualisation is not implemented. Record the run count at which it would be
needed; lesson 04 shows three.

## Acceptance

| Command | Expected |
|---|---|
| `pnpm test src/ui/GridView.test.tsx src/ui/GridList.test.tsx` | green |
| `rg -n '<table' src/ui/GridView.tsx` | present |
| `pnpm lint && pnpm typecheck` | clean |
| `bash .claude/skills/ds-check/ds-check.sh` | PASSED |

## Out of scope
- `GraphView` — S22
- The detail panel — S26
- Assembling the lab — S32
