// The bridge between the design system's single source of values and the
// application that has to render them.
//
// The import crosses the `docs/` boundary on purpose. DESIGN-SYSTEM.md §12
// makes `docs/design-system/tokens.css` the one place a raw design value may
// exist: `tokens-guard.sh` escalates any edit of it to a human, and
// `tokens-parity.sh` keeps `tokens.json` in step with it. A generated copy
// under `src/` would be a third origin that neither hook watches, and it would
// rot quietly until a learner saw the wrong colour.
//
// The cost is that `pnpm build` now depends on a path under `docs/`, so moving
// that file breaks the build. That is the intended failure mode — loud,
// immediate, at the moment of the change. Recorded as D22.
import '../../docs/design-system/tokens.css';

/**
 * A `var()` reference to a design token, for anything the browser resolves:
 * inline styles, a CSS custom property assignment, a `style` attribute.
 *
 * Takes the token name **without** the `--gl-` prefix — `cssVar('accent')`
 * returns `var(--gl-accent)`. Prefer plain CSS in a stylesheet; this exists for
 * the values that can only be set from TypeScript.
 */
export function cssVar(name: string): string {
  return `var(--gl-${name})`;
}

/**
 * The **computed** value of a design token in the theme that is active right
 * now — `readToken('state-failed')` returns the literal colour the current
 * `data-theme` resolves to.
 *
 * This is the only sanctioned way to obtain a literal design value inside
 * `src/`: §8 rule 1 forbids writing one, and some consumers cannot take a
 * `var()` reference at all (Monaco's `defineTheme` wants literal hex, a canvas
 * 2D context wants a colour string).
 *
 * Reads from `document.documentElement`, which is where both `:root` and
 * `:root[data-theme="dark"]` apply, so the answer follows the theme without the
 * caller tracking it. It is a live read, not a cached one — call it again after
 * the theme changes.
 */
export function readToken(name: string): string {
  return getComputedStyle(document.documentElement)
    .getPropertyValue(`--gl-${name}`)
    .trim();
}
