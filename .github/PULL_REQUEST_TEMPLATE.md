Closes #

## What changes

<!-- One or two sentences. The "why" lives in the issue; this is the "what". -->

## How to check it

<!-- The exact steps for the reviewer to see it working. If there is no way to
     check it by hand, say which test covers it. -->

---

## Before requesting review

- [ ] `/ds-check` passes
- [ ] Issue linked above with `Closes #`

### Quality floor (§10) — what no script catches

Tick only what applies and delete the rest. An item left unticked and undeleted
reads to the reviewer as not checked, which is exactly how it should read.

- [ ] Readable and operable at 360px
- [ ] Walked the whole screen by keyboard, focus visible at every step
- [ ] `prefers-reduced-motion` respected
- [ ] Contrast 4.5:1 for text, 3:1 for glyphs and informative borders
- [ ] No state carried by colour alone — colour **and** glyph **and** accessible text
- [ ] Opened light and dark on the same screen and compared
- [ ] Grid still readable under deuteranopia and protanopia simulation
- [ ] No CLS: grid and canvas reserve height before mounting
- [ ] Numbers in lists, grids and instruments use mono and `tabular-nums`

### Contract

- [ ] A new component entered `DESIGN-SYSTEM.md` **before** this code (rule 12)
- [ ] No state outside `airflow.utils.state` (rule 7, D18)
- [ ] Progress is a grid column; there is no percentage bar (rule 8)
- [ ] No emoji, no gradient, no new component library (rule 11)
- [ ] Nothing resembling the Airflow logo; footer carries the ASF notice (§11)
- [ ] Writing per §9: sentence case, active verb, Airflow vocabulary, no
      "simply", no exclamation marks

### Copy and locales

- [ ] No UI copy in this PR
- [ ] All UI copy lives in locale files under `src/locales/`, never inline (§9)
- [ ] `pt-BR` is complete. If an `en` file was touched, it is complete too —
      CI enforces key parity and will not accept a half-translated locale

### Airflow claims

- [ ] There are none in this PR
- [ ] All were checked against the source, and the check is recorded next to
      the claim (`# verified: path @ tag`)

If one could not be verified, the text says so instead of asserting it. An
honest gap is recoverable; a false claim wearing the face of certainty is not.

### Design system exception

- [ ] This PR contradicts no rule
- [ ] It does, and the line is already in `DECISIONS.md`, written by `/decision`

Without that line the exception is a bug — and review will treat it as one.
