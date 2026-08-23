# S06 · document the chrome — Header, Footer, ThemeSwitch

| | |
|---|---|
| Form | `02-component` |
| Labels | `type/component` `area/design-system` |
| Size | S |
| Branch | `docs/nn-doc-chrome` |

## Depends on
S05

## Unblocks
S10, S11, S20

## Context

Every screen sits in the same frame, and none of it is documented. The header
appears in both mockups, the footer's wording is fixed in `README.md` and §11,
and the theme switch is implied by §3's "light is default, dark is first class"
and by `:root[data-theme="dark"]` — but §5 has no section for any of the three.
Rule 12 blocks S11 until they exist.

Doc specs are batched by screen cluster rather than one per component: rule 12's
cost is code before doc, not one pull request per section, and ten separate doc
specs would serialise into ten rebases on one region of one file.

Section numbers are pre-assigned across the whole queue so two agents cannot
claim the same one: 5.11 Header, 5.12 Footer, 5.13 BrandMark (S05), 5.14
ThemeSwitch, 5.15 Panel, 5.16 TaskDetailPanel, 5.17 Toast (S20), 5.18 Hero, 5.19
TrackCard (S28).

## Reading list
- `CLAUDE.md`
- `docs/design-system/DESIGN-SYSTEM.md` §0, §3, §4, §5 (the existing ten, for
  voice and depth), §6, §11
- `docs/design-system/DECISIONS.md` — D12, D19
- `docs/mockups/` — both files, for what the chrome actually contains
- `README.md` § Trademark

## Files
- `docs/design-system/DESIGN-SYSTEM.md` — new §5.11, §5.12, §5.14

## Do

1. **§5.11 `Header`** — height, the container it sits in, the wordmark plus
   `BrandMark`, the nav (`Trilhas`, `Referência`, `Sobre`), the bottom hairline
   in `--gl-border`, focus order, and what it does under 640px. Copy comes from a
   locale file; name the keys, do not write the strings here.
2. **§5.12 `Footer`** — the ASF trademark notice, `--gl-text-muted`, mono,
   `--gl-text-2xs`. State plainly that the wording is set in `README.md`, is read
   from `common.json`, and is not a design surface: a diff that edits it inline
   is two violations, not one.
3. **§5.14 `ThemeSwitch`** — a real control with an accessible name, not an icon
   alone; the three states it must handle (light, dark, and the system default
   where nothing is stamped); persistence; and the requirement that the choice is
   applied before first paint. State that it sets `data-theme` on the root, which
   is the contract `tokens.css` already implements.
4. Match the depth of §5.1–§5.6, not §5.7. A thin section is a section an
   implementer has to invent from, which is the rot rule 12 exists to prevent.

## Delivers

### Artifacts
`DESIGN-SYSTEM.md` with three new sections.

### Surface
§5.11, §5.12, §5.14 exist and are implementable.

### Invariants
- Section numbers 5.11–5.19 are reserved as listed above
- No component copy is written into the design system; only key names

### Evidence
The three new sections.

### Debt
None. S11 implements all three.

## Acceptance

| Command | Expected |
|---|---|
| `rg -n '### 5.1[124]' docs/design-system/DESIGN-SYSTEM.md` | three hits |
| `bash .claude/skills/ds-check/ds-check.sh` | PASSED |

## Out of scope
- Any code
- §5.13 (S05), §5.15–§5.17 (S20), §5.18–§5.19 (S28)
- Touching `tokens.css`
