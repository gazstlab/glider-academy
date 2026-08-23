# S05 · settle the Glider mark and retire the pinwheel derivative

| | |
|---|---|
| Form | `02-component` |
| Labels | `type/component` `area/design-system` `state/needs-decision` |
| Size | S |
| Branch | `docs/nn-brand-mark` |

## Depends on
Nothing. **Start this beside S01, on day one.**

## Unblocks
S06, S11, S29

## Context

`docs/mockups/glider_v2_home_hero_airflow_aligned.html` carries a three-blade
pinwheel SVG in the brand ramp as the Glider mark. §11 forbids reproducing the
Apache Airflow logo *or a pinwheel close to it*: the kinship with Airflow is in
palette and structure, not in the symbol. A three-blade pinwheel in blue is
close enough that the question has to be settled before anything renders it.

It is settled here, in the document, before code — and it is scheduled first
because it has zero code dependencies and blocks three specs. Left until the
shell is being built, it becomes an aesthetic and trademark decision taken under
time pressure, which is how a mark nobody defends ends up shipping.

The design system has no `BrandMark` section at all, so rule 12 blocks S11
regardless of what the mark turns out to be.

## Reading list
- `CLAUDE.md` § Branding
- `docs/design-system/DESIGN-SYSTEM.md` §0, §2, §7 (the hero turn), §11
- `docs/design-system/DECISIONS.md` — D10, D11, D13
- `README.md` § Trademark
- `docs/mockups/glider_v2_home_hero_airflow_aligned.html`
- `.claude/skills/decision/SKILL.md`

## Files
- `docs/design-system/DESIGN-SYSTEM.md` — new **§5.13 `BrandMark`**
- `docs/design-system/DECISIONS.md` — one row, **D19**
- `docs/mockups/glider_v2_home_hero_airflow_aligned.html` — banner only

## Do

1. Decide the mark, and write the decision down rather than drawing it here. The
   constraint set: not a pinwheel, not rotationally symmetric in three blades,
   legible at 17px, works as a single flat shape in `currentColor`. D10 already
   says the glider metaphor lives in the vocabulary and not in illustration —
   whatever is chosen has to survive that, so a literal aeroplane is out.
2. Write §5.13 `BrandMark`: what it is, sizes, the `aria-hidden` policy (the
   wordmark carries the accessible name; the mark is decorative), the
   `currentColor` rule, and the binding to §7's single hero turn at
   `--gl-dur-spin` — one turn, on load, hero only, nowhere else.
3. Write **D19** with `/decision`: what was broken or changed, why, and the
   discarded alternative — the three-blade pinwheel, discarded on §11 rather
   than on taste.
4. Put a one-line superseded banner at the top of the home mockup pointing at
   §5.13. The mockups are outside `gl_is_source`, so no check will ever catch an
   agent copying that SVG verbatim; the banner is the only thing that will.

## Delivers

### Artifacts
The three files above.

### Surface
`DESIGN-SYSTEM.md §5.13 BrandMark` exists and is implementable. No code.

### Invariants
- No pinwheel is drawn anywhere in `src/`
- The mark never carries the accessible name; the wordmark does
- The hero turn stays one turn, on load, hero only

### Evidence
The new section and the D19 row.

### Debt
None. S11 implements it.

## Acceptance

| Command | Expected |
|---|---|
| `rg -n '### 5.13' docs/design-system/DESIGN-SYSTEM.md` | one hit |
| `rg -n '\| D19 ' docs/design-system/DECISIONS.md` | one row naming the discarded alternative |
| `rg -ni 'superseded' docs/mockups/glider_v2_home_hero_airflow_aligned.html` | one hit |
| `bash .claude/skills/ds-check/ds-check.sh` | PASSED |

## Out of scope
- Any code. This spec writes documentation
- §5.11, §5.12, §5.14 — S06 owns them
- Rewriting the mockup's SVG. A banner, not a redraw
