# S02 · consume tokens.css at runtime without copying it

| | |
|---|---|
| Form | `06-feature` |
| Labels | `type/feature` `area/design-system` |
| Size | S |
| Branch | `feat/nn-tokens-bridge` |

## Depends on
S01

## Unblocks
S04, S07, S08, S09, S24

## Context

The application needs the custom properties in
`docs/design-system/tokens.css` at runtime. It must not copy them. §12 makes that
file the single source of design values, `tokens-guard.sh` escalates any edit to
it to a human, and `tokens-parity.sh` keeps `tokens.json` in step — a third copy
under `src/` would drift silently and defeat all three.

So `src/tokens/index.ts` imports the file across the `docs/` boundary. The
tradeoff is real and worth stating: `pnpm build` now depends on a path under
`docs/`, and moving that file breaks the build. That is the correct failure mode
— loud, immediate, at the moment of the change — against a copy that rots
quietly and is discovered by a learner. It needs a row in `DECISIONS.md` because
it is surprising, and surprising is exactly what a decisions log is for.

The second job here is a reading helper. Several later specs need a token's
*computed value* rather than a `var()` reference — S24 most of all, because
Monaco's `defineTheme` takes literal hex and §8 rule 1 forbids literal hex
anywhere in `src/`.

## Reading list
- `CLAUDE.md`
- `docs/orchestration/HANDOFF.md`
- `docs/design-system/DESIGN-SYSTEM.md` §3, §4, §6, §12
- `docs/design-system/tokens.css` — read it, do not edit it
- `.claude/skills/decision/SKILL.md`

## Files
- `src/tokens/index.ts` — new
- `src/styles/base.css` — new
- `src/main.tsx` — add two imports
- `e2e/tokens.spec.ts` — new
- `docs/design-system/DECISIONS.md` — one row, **D22**

## Do

1. `src/tokens/index.ts` imports `../../docs/design-system/tokens.css` and
   exports `cssVar(name)` returning `var(--gl-<name>)` and `readToken(name)`
   returning the computed value from `getComputedStyle(document.documentElement)`.
2. `src/styles/base.css` — the layout primitives §6 defines and nothing else:
   `.gl-container` (`--gl-max-width`, `--gl-gutter`), `.gl-prose` (68ch via
   `--gl-prose-width`), `.gl-nums` (mono + `tabular-nums`, which §8 required rule
   2 makes non-optional for any number in a list, grid or instrument), and the
   640/900/1200 breakpoints as custom media.
3. Import both from `src/main.tsx`, tokens first.
4. `e2e/tokens.spec.ts` asserts roughly twenty named properties resolve non-empty
   under `:root` **and** under `:root[data-theme="dark"]` — every semantic role,
   every `--gl-state-*`, the radius and motion scales.
5. Write **D22** with `/decision`: *tokens.css is imported from `docs/`, never
   copied into `src/`*. Reason: one source, and a move breaks the build loudly.
   Discarded: a generated copy under `src/styles/`.

## Delivers

### Artifacts
The file list above.

### Surface
`src/tokens/index.ts` exports `cssVar(name: string): string` and
`readToken(name: string): string`.

### Invariants
- No `--gl-*` value is ever written literally in `src/`. `readToken` is the only
  way to get a computed one
- `--gl-radius-pill` is always used as a token: `ds-rules.sh` rule 4 rejects a
  literal `999px`, even though §8 permits the pill shape
- `base.css` holds layout primitives only. Component styles live with components

### Evidence
The e2e run, both themes.

### Debt
None.

## Acceptance

| Command | Expected |
|---|---|
| `pnpm build` | resolves the `docs/` import |
| `pnpm test:e2e e2e/tokens.spec.ts` | green — every property resolves, both themes |
| `pnpm lint && pnpm typecheck` | clean |
| `bash .claude/skills/ds-check/ds-check.sh` | PASSED |
| `rg -n '\| D22 ' docs/design-system/DECISIONS.md` | one row |

## Out of scope
- **Editing `tokens.css` or `tokens.json`.** A token change is a human decision
  and the hook will stop you
- Any component
- A theme switch — S11 owns it. This spec only proves both themes resolve
