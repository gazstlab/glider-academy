# S22 · implement §5.5 GraphView with arrow-key node traversal

| | |
|---|---|
| Form | `02-component` |
| Labels | `type/component` `area/design-system` `quality/keyboard` |
| Size | M |
| Branch | `feat/nn-graphview` |

## Depends on
S03, S09, S12, S15

## Unblocks
S32

## Context

The other half of the lab's centre panel. §5.5 is specific in a way that matters:
a node's state is carried by its **border**, not its fill, over a `--gl-surface`
background — which is what keeps the graph legible beside a grid whose cells are
filled, and what keeps blue out of a state position.

Every node is a `<button>`, arrow-navigable, with the task id and the state
spelled out in its `aria-label`. A graph drawn as SVG paths with click handlers
is unreachable by keyboard and is the most common way this component gets built
wrong.

Layout is hand-rolled. §8 forbids adding a new component library without a
recorded decision, and a graph library would arrive with its own DOM, its own
focus behaviour and its own colours — three contract violations for one
convenience. A layered layout over S12's topological order is enough for the
shapes lessons produce.

## Reading list
- `CLAUDE.md` § The twelve rules
- `docs/orchestration/HANDOFF.md`
- `docs/design-system/DESIGN-SYSTEM.md` §5.5, §3, §7, §8
- `docs/specs/S12-engine-graph.md` § Delivers — `topoOrder`, `upstreamOf`

## Files
- `src/ui/GraphView.tsx`, `GraphView.module.css`, `GraphView.test.tsx` — new
- `src/ui/layout/layered.ts`, `layered.test.ts` — new
- `src/locales/pt-BR/graph.json` — new

## Do

1. `layout(g)` — assign each task a layer from `topoOrder`, order within the
   layer to reduce edge crossings, return positioned nodes and edges. Pure, no
   DOM, unit-tested on a diamond and a fan-in.
2. Nodes: `--gl-radius-node`, `--gl-surface` fill, border in the state colour,
   rendered as `<button>` elements. Edges in `--gl-border-strong`, solid.
3. Arrow keys move between nodes along the graph, Enter opens the detail. The
   `aria-label` carries the task id and the state spelled out from `states.json`.
4. Share `onSelect` with `GridView` so the detail panel has one source of truth
   about what is selected.
5. Tests: every node is a button; keyboard traversal reaches all of them; state
   is on the border and never the fill; layout is stable for the same input.

## Delivers

### Artifacts
The file list above.

### Surface
`src/ui/GraphView.tsx` exports `GraphView` and `GraphViewProps`.
`src/ui/layout/layered.ts` exports `layout(g: Graph)`.

### Invariants
- Every node is a `<button>`, keyboard reachable, with the state in its label
- State is carried by the border. The fill stays `--gl-surface`
- No graph library. Adding one needs a `DECISIONS.md` row first
- Selection is shared with `GridView`

### Evidence
The unit tests, including keyboard traversal.

### Debt
Layout is layered and vertical only. Record the graph size beyond which it stops
being readable.

## Acceptance

| Command | Expected |
|---|---|
| `pnpm test src/ui/GraphView.test.tsx src/ui/layout` | green |
| `rg -n '<button' src/ui/GraphView.tsx` | present |
| `rg -n 'fill.*gl-state' src/ui/GraphView.module.css` | no hits — border, not fill |
| `bash .claude/skills/ds-check/ds-check.sh` | PASSED |

## Out of scope
- Adding a graph or layout library
- Pan and zoom
- The detail panel — S26
