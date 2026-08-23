# S08 · implement §5.1 Button

| | |
|---|---|
| Form | `02-component` |
| Labels | `type/component` `area/design-system` |
| Size | S |
| Branch | `feat/nn-button` |

## Depends on
S02, S03

## Unblocks
S11, S26

## Context

§5.1 is fully specified — four variants, two heights, and a writing rule that is
part of the component rather than decoration: the label is sentence case with an
active verb that names the result, and the same verb comes back in the
confirmation. `Disparar DAG` produces `DAG disparado`. That pairing is S26's
toast, and it only works if the verb is fixed here.

This is the first component in the repository, so it also sets the shape every
later one follows: a `.tsx` beside a `.module.css`, copy from `useT()`, focus
from `:focus-visible` using `--gl-ring-focus`, and no value that is not a token.

## Reading list
- `CLAUDE.md` § The twelve rules, § UI writing
- `docs/orchestration/HANDOFF.md`
- `docs/design-system/DESIGN-SYSTEM.md` §5.1, §7 (hover and focus timing), §8, §9
- `docs/design-system/DECISIONS.md` — D17

## Files
- `src/ui/Button.tsx`, `src/ui/Button.module.css` — new
- `src/ui/Button.test.tsx` — new

## Do

1. `ButtonProps { variant: 'primary' | 'secondary' | 'ghost' | 'danger'; size?: 'sm' | 'md' }`,
   defaulting to `md`. Render a real `<button>`; `asChild` and link-shaped buttons
   are not in §5.1 and adding them would be a rule 12 violation on a prop.
2. Styles straight from §5.1's table: `primary` `--gl-accent` on `--gl-on-accent`;
   `secondary` `--gl-surface` with a `--gl-border-strong` border; `ghost`
   borderless, `--gl-surface-raised` on hover; `danger` bordered and lettered in
   `--gl-state-failed`. Radius `--gl-radius-ui`. Heights 32 and 40 from the space
   scale.
3. Hover and focus transition at `--gl-dur-1` / `--gl-ease-out` (§7). Nothing
   else animates. Do not write a `prefers-reduced-motion` query — the tokens
   already zero themselves.
4. Focus ring from `--gl-ring-focus` via `:focus-visible`. §8 required rule 3.
5. Tests: each variant renders, `disabled` is not focusable, and the label comes
   from `useT()` — a literal here would fail `pnpm lint` anyway, which is the
   point.

## Delivers

### Artifacts
The three files above.

### Surface
`src/ui/Button.tsx` exports `Button` and `type ButtonProps`.

### Invariants
- Exactly four variants and two sizes. A fifth needs §5.1 edited first
- `danger` is for the destructive lab reset only
- One `primary` per screen — the action that runs something

### Evidence
The unit tests, `pnpm lint`, `ds-check`.

### Debt
None.

## Acceptance

| Command | Expected |
|---|---|
| `pnpm test src/ui/Button.test.tsx` | green |
| `pnpm lint && pnpm typecheck` | clean |
| `bash .claude/skills/ds-check/ds-check.sh` | PASSED |
| `rg -n '#[0-9a-fA-F]{3,8}' src/ui/Button.module.css` | no hits |

## Out of scope
- An icon-only variant, a loading state, a link variant — none is in §5.1
- The toast — S26
- Any screen that uses the button
