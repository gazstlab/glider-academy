# S33 · the axe suite and the §10 floor a script can reach

| | |
|---|---|
| Form | `06-feature` |
| Labels | `type/feature` `area/lab` `quality/a11y` |
| Size | M |
| Branch | `feat/nn-a11y-suite` |

## Depends on
S32

## Unblocks
Nothing. This is the last spec in the queue.

## Context

§10 is explicit that the quality floor is human: *"No script checks it, and no
agent should claim it is met — it belongs to whoever merges the PR."* That stays
true, and this spec does not change it.

What it does is take the part a script *can* reach and put it in CI, so the human
review starts from a higher floor and spends its attention on the parts that
genuinely need eyes — contrast judgement, colour-blindness simulation, whether
the grid still reads. Automation covers roughly half the checklist honestly and
none of it dishonestly.

The distinction matters enough to write into the suite's own header comment, so
that nobody later reads a green axe run as §10 being satisfied.

## Reading list
- `CLAUDE.md` § Before finishing a task
- `docs/orchestration/HANDOFF.md`
- `docs/design-system/DESIGN-SYSTEM.md` §10 — all nine items, and its closing line
- `docs/design-system/DESIGN-SYSTEM.md` §7 — what may animate
- `.claude/agents/ds-reviewer.md` § What not to look for

## Files
- `e2e/a11y.spec.ts`, `e2e/keyboard.spec.ts`, `e2e/motion.spec.ts` — new
- `.github/dependabot.yml` — npm back to `weekly`

## Do

1. `a11y.spec.ts` — axe across home, track and lab × light and dark × 360, 900
   and 1200. Zero violations at serious and critical. Header comment stating what
   this does **not** cover.
2. `keyboard.spec.ts` — a full keyboard walk of the lab: every control reachable,
   focus visible at every stop, no trap, the grid's roving tabindex behaves, the
   splitter resizes by arrow key, and the graph traverses.
3. `motion.spec.ts` — with reduced motion emulated, assert nothing animates. With
   it off, assert the `running` pulse and the hero's single turn are the only
   animations present. §7 says nothing else animates; this is what holds that.
4. Restore `dependabot.yml`'s npm interval to `weekly` — S00 set it monthly for
   the duration of the build-out, and the build-out ends here.
5. Update `HANDOFF.md` to describe a repository that now has a running product.

## Delivers

### Artifacts
The file list above.

### Surface
No API. The `e2e` suite grows by three files, all inside `pnpm test:e2e` and
therefore inside `gate`.

### Invariants
- Zero serious or critical axe violations on any screen, in either theme, at any
  of the three widths
- Under reduced motion, nothing animates
- **A green suite is not a met §10 floor**, and the suite says so in its own
  header

### Evidence
All three suites, both browsers, and the list of §10 items still owed to a human.

### Debt
The §10 items no script reaches: contrast judgement beyond axe's threshold,
deuteranopia and protanopia simulation, and whether the grid still reads under
them. They belong to whoever merges, permanently.

## Acceptance

| Command | Expected |
|---|---|
| `pnpm test:e2e` | the whole suite green in chromium and firefox |
| `pnpm test:e2e e2e/a11y.spec.ts` | zero serious/critical across 3 screens × 2 themes × 3 widths |
| `rg -n 'weekly' .github/dependabot.yml` | npm restored |
| `bash .claude/skills/ds-check/ds-check.sh` | PASSED |

## Out of scope
- Claiming the §10 floor is met
- Fixing components. A violation found here opens an issue against that
  component's spec
