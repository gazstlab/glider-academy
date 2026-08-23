# S28 · document the home — Hero and TrackCard

| | |
|---|---|
| Form | `02-component` |
| Labels | `type/component` `area/design-system` |
| Size | S |
| Branch | `docs/nn-doc-home` |

## Depends on
S20

## Unblocks
S29

## Context

The last two undocumented components, and the last doc-first spec in the queue.
The home mockup shows both: a hero with an eyebrow label, a display headline and
two buttons, and a track card carrying the fifteen-cell grid with its rows and
captions.

§4 already says `4xl` exists for the home hero only, and §7 already fixes the
pinwheel's single turn — so the hero is half-specified across two sections and
absent as a component. That is precisely the state rule 12 exists to catch:
enough written that an implementer feels covered, not enough that two
implementers would agree.

Sections 5.18 Hero and 5.19 TrackCard, reserved since S06.

## Reading list
- `CLAUDE.md`
- `docs/design-system/DESIGN-SYSTEM.md` §2, §4, §5 (for depth), §5.6, §6, §7
- `docs/design-system/DECISIONS.md` — D13, D19
- `docs/mockups/glider_v2_home_hero_airflow_aligned.html` — **read its superseded banner first**

## Files
- `docs/design-system/DESIGN-SYSTEM.md` — new §5.18, §5.19

## Do

1. **§5.18 `Hero`** — the eyebrow label per §4's label rule (mono, `2xs`,
   uppercase, carrying real information), the `4xl` headline with its measure and
   tracking, the sub-paragraph capped at `--gl-prose-width`, and exactly one
   primary button beside one secondary per §5.1. State the `BrandMark` binding:
   one turn, on load, hero only, `--gl-dur-spin`, and nothing at all under
   reduced motion — through the token, not a hand-written media query.
2. **§5.19 `TrackCard`** — the card that holds a track's grid: header row with
   the track label and its `15 LIÇÕES · ~3H20` counts in mono with
   `tabular-nums`, the grid rows with their captions, and how the active row is
   distinguished without relying on colour.
3. Both sections say plainly that copy comes from a locale file, and name the
   keys rather than writing the strings.

## Delivers

### Artifacts
`DESIGN-SYSTEM.md` with §5.18 and §5.19.

### Surface
§5.18 and §5.19 exist and are implementable.

### Invariants
- The pinwheel turn is hero-only, one turn, and it is `BrandMark` as §5.13
  defines it — not the mockup's SVG
- `4xl` stays home-hero-only

### Evidence
The two new sections.

### Debt
None. S29 implements both.

## Acceptance

| Command | Expected |
|---|---|
| `rg -n '### 5.1[89]' docs/design-system/DESIGN-SYSTEM.md` | two hits |
| `bash .claude/skills/ds-check/ds-check.sh` | PASSED |

## Out of scope
- Any code
- A track index screen section
- Editing `tokens.css`
