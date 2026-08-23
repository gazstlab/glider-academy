# S24 · implement §5.7 CodePane with a theme derived from the tokens

| | |
|---|---|
| Form | `02-component` |
| Labels | `type/component` `area/design-system` |
| Size | M |
| Branch | `feat/nn-codepane` |

## Depends on
S02, S03, S20

## Unblocks
S27, S32

## Context

Where the learner writes the DAG. §5.7, thickened by S20, says the theme is
derived from the tokens and that the stock `vs`/`vs-dark` are not to be used —
a Monaco in default colours next to a token-built interface is the most visible
possible contract violation.

There is a hard constraint behind that, and it decides the shape of the module
rather than merely suggesting it: **Monaco's `defineTheme` takes literal hex and
will not accept a `var()`**, while §8 rule 1 forbids literal hex anywhere in
`src/`. Both are non-negotiable, so the theme is constructed at runtime from
`readToken()` and re-registered whenever the theme changes. This is not a
workaround discovered halfway through; it is the design.

Monaco's workers must be same-origin under COEP — the `?worker` import, never a
CDN.

## Reading list
- `CLAUDE.md` § The twelve rules
- `docs/orchestration/HANDOFF.md`
- `docs/design-system/DESIGN-SYSTEM.md` §5.7 (as rewritten by S20), §4, §8
- `docs/design-system/DECISIONS.md` — D9
- `docs/specs/S02-tokens-bridge.md` § Delivers — `readToken()`
- `CONTRIBUTING.md` §7

## Files
- `src/ui/CodePane.tsx`, `CodePane.module.css`, `CodePane.test.tsx` — new
- `src/ui/monacoTheme.ts`, `monacoTheme.test.ts` — new
- `vite.config.ts` — fill the `worker` / `optimizeDeps` values S01 reserved
- `src/locales/pt-BR/lab.json` — the pane's labels

## Do

1. `buildMonacoTheme(): editor.IStandaloneThemeData` — reads every colour through
   `readToken()`. **No hex literal in the source.** Background `--gl-surface`,
   gutter `--gl-text-muted`, selection `--gl-accent-quiet`, mono family from
   `--gl-font-mono`.
2. Re-register the theme on theme change, subscribing to `useTheme()`. A switch
   to dark with a light editor still on screen is the failure this prevents.
3. Wire the editor worker via `monaco-editor/esm/vs/editor/editor.worker?worker`,
   same-origin.
4. Below 900px the pane is **read-only** — D9, marked do not reopen. Not a
   smaller editor: no editable canvas.
5. Accessible name from `lab.json`; keyboard escape from the editor's tab trap so
   the pane does not swallow focus.
6. Tests: the theme object contains no `var(` and no empty value; it is rebuilt
   on theme change; the pane is read-only below 900px.

## Delivers

### Artifacts
The file list above.

### Surface
`src/ui/CodePane.tsx` exports `CodePane` and `CodePaneProps`.
`src/ui/monacoTheme.ts` exports `buildMonacoTheme()`.

### Invariants
- **No literal hex in `src/`.** Every Monaco colour comes from `readToken()`
- The theme is re-derived on every theme change
- Monaco's workers are same-origin
- Below 900px, read-only. No editable canvas
- No hex-shaped identifiers in `src/` — `ds-rules.sh` rule 1 matches
  `url(#a1b2c3)` as readily as a colour

### Evidence
The unit tests and a build showing the worker bundled locally.

### Debt
Python syntax highlighting is Monaco's built-in. No language server, no
completion — record which spec would want them.

## Acceptance

| Command | Expected |
|---|---|
| `pnpm test src/ui/CodePane.test.tsx src/ui/monacoTheme.test.ts` | green |
| `bash .claude/skills/ds-check/ds-check.sh` | PASSED — no hex in `src/` |
| `rg -n 'cdn\|jsdelivr\|unpkg' src/ui/` | no hits |
| `pnpm build` | worker emitted under `dist/assets/` |

## Out of scope
- The panel layout — S27
- Running the code — S18 already does
- A language server or completion
