# S11 · implement Header, Footer, BrandMark and the theme switch

| | |
|---|---|
| Form | `02-component` |
| Labels | `type/component` `area/design-system` `quality/theme` |
| Size | M |
| Branch | `feat/nn-shell` |

## Depends on
S03, S05, S06, S07, S08

## Unblocks
S29, S32

## Context

The frame every screen sits in: §5.11 Header, §5.12 Footer, §5.13 BrandMark,
§5.14 ThemeSwitch — all four documented by S05 and S06, none implemented.

Two things here are easy to get subtly wrong and expensive to notice.

The **theme has to be applied before first paint.** React mounting and then
setting `data-theme` gives every dark-theme visitor a white flash on every load.
That needs a small inline script in `index.html`, which is the third and last
spec to touch that file.

The **footer wording is legal text, not copy.** §11 puts it in `README.md`
specifically so a legal line is never edited as a design tweak. It is read from
`common.json`, which S03 seeded from the README character for character, and the
test compares against the README rather than against a fixture — a fixture would
just record the drift.

## Reading list
- `CLAUDE.md` § Branding
- `docs/orchestration/HANDOFF.md`
- `docs/design-system/DESIGN-SYSTEM.md` §5.11, §5.12, §5.13, §5.14, §3, §6, §11
- `docs/design-system/DECISIONS.md` — D12, D19
- `README.md` § Trademark

## Files
- `src/ui/Header.tsx`, `Footer.tsx`, `BrandMark.tsx`, `ThemeSwitch.tsx` + modules — new
- `src/theme/useTheme.ts` — new
- `src/ui/*.test.tsx` — new
- `src/locales/pt-BR/common.json` — nav and switch keys
- `index.html` — the pre-paint script
- `src/App.tsx` — mount the shell around the router
- `e2e/shell.spec.ts` — new

## Do

1. `useTheme()` returning `{ theme, setTheme }`, persisting to a versioned
   `localStorage` key, and honouring the system default when nothing is stored —
   §3's three states, not two.
2. The pre-paint script in `index.html`: read the key, stamp `data-theme` on the
   root, wrapped in `try/catch` so a browser blocking site data still renders.
3. `BrandMark` exactly as §5.13 describes. **Not a pinwheel.** `aria-hidden`;
   the wordmark carries the accessible name.
4. `Header` per §5.11, `Footer` per §5.12. All strings from `useT()`.
5. `ThemeSwitch` per §5.14: a real control with an accessible name, keyboard
   operable, visible focus.
6. `e2e/shell.spec.ts`: toggle persists across reload; **no flash of the wrong
   theme on a cold load with dark stored**; and the footer's text equals the
   README's wording.

## Delivers

### Artifacts
The file list above.

### Surface
`src/ui/` exports `Header`, `Footer`, `BrandMark`, `ThemeSwitch`.
`src/theme/useTheme.ts` exports `useTheme()`.

### Invariants
- No pinwheel anywhere in `src/`
- The theme is stamped before first paint, and the switch works in both directions
- The footer notice is read from `common.json` and matches `README.md` exactly

### Evidence
The shell e2e, both browsers, both themes.

### Debt
Navigation targets `Referência` and `Sobre` have no screens yet. They render as
disabled or route to Home — record which, and which spec collects them.

## Acceptance

| Command | Expected |
|---|---|
| `pnpm test:e2e e2e/shell.spec.ts` | green — persistence, no flash, footer matches |
| `pnpm test src/ui src/theme` | green |
| `pnpm lint && pnpm typecheck && pnpm build` | clean |
| `bash .claude/skills/ds-check/ds-check.sh` | PASSED |

## Out of scope
- Home or Lab content — S29, S32
- A `Referência` or `Sobre` screen
- Editing the footer wording. If it looks wrong, that is a README issue
