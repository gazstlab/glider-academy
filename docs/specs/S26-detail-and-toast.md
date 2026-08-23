# S26 · implement TaskDetailPanel and Toast

| | |
|---|---|
| Form | `02-component` |
| Labels | `type/component` `area/design-system` |
| Size | S |
| Branch | `feat/nn-detail-toast` |

## Depends on
S08, S15, S20

## Unblocks
S32

## Context

The two small pieces that close the lab's feedback loop. §5.16 is the panel the
mockup shows — `TASK · limpar`, `Tentativa 2 de 3`, operator, retries, duration.
§5.17 is the toast, and it exists for one reason that §5.1 already stated: the
button's verb comes back as the result. `Disparar DAG` produces `DAG disparado`.

That pairing is the whole of §9's writing rule made visible, and it is why the
toast is not a generic notification component. It never carries an action the
screen does not already offer, and it never says something happened in different
words from the ones that made it happen.

## Reading list
- `CLAUDE.md` § UI writing
- `docs/orchestration/HANDOFF.md`
- `docs/design-system/DESIGN-SYSTEM.md` §5.16, §5.17 (both from S20), §5.1, §4, §9
- `docs/specs/S15-use-dag-run.md` § Delivers

## Files
- `src/ui/TaskDetailPanel.tsx` + module + test — new
- `src/ui/Toast.tsx`, `src/ui/useToast.ts` + module + test — new
- `src/locales/pt-BR/lab.json` — the panel labels and the toast strings

## Do

1. `TaskDetailPanel` per §5.16: the label grammar from §4, every number mono with
   `tabular-nums`, and the state carried as colour **and** glyph **and** text —
   reuse `StateChip`, do not restyle a square.
2. `Toast` per §5.17: `role="status"`, the duration and position the section
   fixes, dismissible, stacking rule honoured.
3. `useToast()` — a queue, not a singleton.
4. The strings in `lab.json`, with the verb pairing explicit: whatever key the
   trigger button uses, the toast key is its result form.
5. Tests: the panel renders every field with `tabular-nums`; the toast has
   `role="status"` and dismisses; the toast's text is the button's verb in result
   form.

## Delivers

### Artifacts
The file list above.

### Surface
`src/ui/TaskDetailPanel.tsx` exports `TaskDetailPanel`. `src/ui/Toast.tsx`
exports `Toast`; `src/ui/useToast.ts` exports `useToast()`.

### Invariants
- The toast's verb is the button's verb, in result form
- A toast never carries an action the screen does not already offer
- Every number is mono with `tabular-nums`
- State is never colour alone

### Evidence
The unit tests, including the verb-pairing assertion.

### Debt
None.

## Acceptance

| Command | Expected |
|---|---|
| `pnpm test src/ui/TaskDetailPanel.test.tsx src/ui/Toast.test.tsx` | green |
| `rg -n 'role="status"' src/ui/Toast.tsx` | present |
| `pnpm lint && pnpm typecheck` | clean |
| `bash .claude/skills/ds-check/ds-check.sh` | PASSED |

## Out of scope
- A generic notification system, or toast variants beyond §5.17
- The panel layout — S27
