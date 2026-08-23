# S20 · document the lab furniture — Panel, TaskDetailPanel, Toast

| | |
|---|---|
| Form | `02-component` |
| Labels | `type/component` `area/design-system` |
| Size | M |
| Branch | `docs/nn-doc-lab-furniture` |

## Depends on
S06

## Unblocks
S24, S25, S26, S27, S28

## Context

The lab screen needs five things the design system does not describe well enough
to build from. Three have no section at all — the resizable panels §6 mentions in
one clause, the task detail card that appears in the lab mockup, and the toast
§5.1 implies when it says `Disparar DAG` produces `DAG disparado`. Two exist but
are sketches: §5.7 `CodePane` is three sentences about Monaco, and §5.8 `RunLog`
is four about a log.

A thin section is worse than a missing one, because it looks like a contract
while leaving every real decision to the implementer. Rule 12 is satisfied by the
letter and defeated in substance. So this spec writes three and thickens two.

Section numbers, pre-assigned across the queue: 5.15 Panel, 5.16 TaskDetailPanel,
5.17 Toast.

## Reading list
- `CLAUDE.md`
- `docs/design-system/DESIGN-SYSTEM.md` §5 (all, for depth), §6, §7, §9, §10
- `docs/design-system/DECISIONS.md` — D9, D13, D17
- `docs/mockups/glider_v2_lab_grid_airflow_aligned.html` — the detail card and log

## Files
- `docs/design-system/DESIGN-SYSTEM.md` — new §5.15, §5.16, §5.17; rewrite §5.7, §5.8

## Do

1. **§5.15 `Panel` / `Splitter`** — the three lab panels, minimum widths,
   persistence, and the keyboard contract: the splitter is a `role="separator"`
   with `aria-valuenow`, resizable by arrow keys. State the D9 rule in the
   section itself, because that is where an implementer will look: below 900px
   the lab is read + run, with no editable canvas, and it is marked do not
   reopen.
2. **§5.16 `TaskDetailPanel`** — the fields the mockup shows (`TASK · limpar`,
   `Tentativa 2 de 3`, `operator`, `retries`, `duração`), the label grammar from
   §4, and `tabular-nums` on every number. Where the state appears and how it
   carries glyph and text as well as colour.
3. **§5.17 `Toast`** — `role="status"`, duration, position, stacking, the one
   rule that gives it a reason to exist: the verb in the toast is the verb from
   the button. It never carries an action the screen does not already offer.
4. **Thicken §5.7 `CodePane`**: the token→Monaco mapping named token by token,
   gutter, selection, read-only regions, re-derivation on theme switch, and the
   sub-900px mode. Say explicitly that the theme is built from token values at
   runtime, because Monaco takes literal hex and §8 rule 1 forbids literal hex in
   `src/` — the implementer needs to know that is a constraint and not a choice.
5. **Thicken §5.8 `RunLog`**: line grammar, the level→state-token map, the
   auto-scroll rule (only while the user is at the end of the buffer), a
   virtualisation threshold, and the `aria-live` policy — a log that announces
   every line is unusable with a screen reader.

## Delivers

### Artifacts
`DESIGN-SYSTEM.md` with three new sections and two rewritten.

### Surface
§5.7, §5.8, §5.15, §5.16, §5.17 all implementable.

### Invariants
- D9 is restated in §5.15 where an implementer will find it
- Section numbers 5.18 and 5.19 remain reserved for S28

### Evidence
The diff of §5.

### Debt
None.

## Acceptance

| Command | Expected |
|---|---|
| `rg -n '### 5.1[567]' docs/design-system/DESIGN-SYSTEM.md` | three hits |
| `rg -n -A20 '### 5.7' docs/design-system/DESIGN-SYSTEM.md` | substantially longer than before |
| `bash .claude/skills/ds-check/ds-check.sh` | PASSED |

## Out of scope
- Any code
- §5.18, §5.19 — S28
- Editing `tokens.css`
