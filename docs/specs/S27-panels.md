# S27 · the three resizable panels and the D9 collapse below 900px

| | |
|---|---|
| Form | `02-component` |
| Labels | `type/component` `area/design-system` `quality/responsive` |
| Size | M |
| Branch | `feat/nn-panels` |

## Depends on
S20, S24

## Unblocks
S32

## Context

§6 says the lab uses three resizable panels, and D9 — marked do not reopen — says
that below 900px the lab becomes read + run, with no editable canvas. §5.15, from
S20, turns both into a component contract.

A splitter is one of the standard ways a screen becomes keyboard-inaccessible: a
mouse-only drag handle is invisible to §10's second item. So the splitter is a
`role="separator"` with `aria-valuenow`, resizable by arrow keys, with a visible
focus ring like every other control.

The collapse is not a smaller layout. It is a different one — the editor is gone,
not shrunk — and treating it as a breakpoint tweak is how D9 gets quietly
reopened.

## Reading list
- `CLAUDE.md`
- `docs/orchestration/HANDOFF.md`
- `docs/design-system/DESIGN-SYSTEM.md` §5.15 (from S20), §6, §10
- `docs/design-system/DECISIONS.md` — **D9, and read the wording**

## Files
- `src/ui/Panel.tsx`, `src/ui/Splitter.tsx` + modules + tests — new
- `src/ui/usePanelSizes.ts` — new
- `src/locales/pt-BR/lab.json` — splitter accessible names

## Do

1. `Panel` — a three-pane layout with minimum widths from §5.15, sizes persisted
   through a versioned key with `try/catch` around storage.
2. `Splitter` — `role="separator"`, `aria-valuenow`/`min`/`max`, arrow keys move
   it, Home and End snap, visible `:focus-visible` ring. An accessible name from
   `lab.json` saying which two panels it divides.
3. Below 900px: render the read + run layout. The editable canvas is not present
   in the DOM — `CodePane` in read-only mode plus the run controls.
4. Down to 360px, per §10's first item.
5. Tests: keyboard resize changes `aria-valuenow`; sizes persist; below 900px no
   editable canvas is in the DOM; nothing overflows horizontally at 360px.

## Delivers

### Artifacts
The file list above.

### Surface
`src/ui/Panel.tsx` exports `Panel`; `src/ui/Splitter.tsx` exports `Splitter`;
`src/ui/usePanelSizes.ts` exports `usePanelSizes()`.

### Invariants
- **Below 900px there is no editable canvas.** D9, do not reopen
- The splitter is fully keyboard operable with a visible focus ring
- Storage failure falls back to default sizes, never to an error
- No horizontal page scroll at 360px

### Evidence
The unit tests plus a viewport-sized render at 360, 900 and 1200.

### Debt
Panel sizes are per browser. There is no backend.

## Acceptance

| Command | Expected |
|---|---|
| `pnpm test src/ui/Panel.test.tsx src/ui/Splitter.test.tsx` | green |
| `rg -n 'role="separator"' src/ui/Splitter.tsx` | present |
| `pnpm lint && pnpm typecheck` | clean |
| `bash .claude/skills/ds-check/ds-check.sh` | PASSED |

## Out of scope
- Reopening D9 in any form, including "a small editor" below 900px
- Assembling the lab — S32
