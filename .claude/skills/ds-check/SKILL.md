---
name: ds-check
description: Runs Glider's design system mechanical floor — the four DESIGN-SYSTEM.md §8 checks (hex outside tokens, box-shadow outside the tokens, border-radius above 8px, brand blue used as a state) plus the tokens.css/tokens.json parity of §12. Use before closing any task that touched UI, CSS or tokens.
allowed-tools: Bash(${CLAUDE_SKILL_DIR}/ds-check.sh:*)
---

Run:

```bash
${CLAUDE_SKILL_DIR}/ds-check.sh
```

It sweeps every tracked source file and returns the offending lines. Fix
everything it reports before saying the task is done. Do not silence a finding
by adding an exception to the script: if a rule genuinely has to be broken, the
route is `/decision`, which records the exception in `DECISIONS.md`.

The same script runs in CI, in the `contract` job, where it blocks the merge.
Running it here only saves you the round trip.

## What this check does NOT cover

The script is the mechanical floor. The §10 floor is human and stays yours:

- responsive down to 360px
- full keyboard navigation, with visible focus
- `prefers-reduced-motion` respected
- contrast 4.5:1 for text, 3:1 for glyphs and informative borders
- state never carried by colour alone
- light and dark themes checked on the same screen
- grid readable under deuteranopia and protanopia simulation
- no CLS: grid and canvas reserve height before mounting

And there are §8 rules no regex catches — a new component that did not enter
the document before the code (rule 12), an invented state that does not exist in
`airflow.utils.state` (rule 7), emoji, gradients. For a contract read in a clean
context, use the `ds-reviewer` agent. The same agent reviews every PR.
