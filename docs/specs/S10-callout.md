# S10 · implement §5.9 Callout with a named token per kind

| | |
|---|---|
| Form | `02-component` |
| Labels | `type/component` `area/design-system` |
| Size | S |
| Branch | `feat/nn-callout` |

## Depends on
S06, S09

## Unblocks
S31

## Context

§5.9 is a closed set — `note`, `warning`, `checkpoint`, a 3px left border in the
kind's colour, no radius, no coloured background, no emoji. It is fully specified
except for one gap: **the per-kind colours are never named.** An implementer has
to invent three token references, which is exactly the drift rule 12 exists to
stop.

So this spec closes the gap in the document and then implements against it. That
means touching `tokens.css` to add three aliases — and `tokens-guard.sh` will
escalate that edit to the human. **That is the hook working, not failing.** Do
not route around it; stop and ask.

The aliases are defined as `var()` references to values that already exist, so
the hex *set* in `tokens.css` does not change and `tokens-parity.sh` stays green
without `tokens.json` being touched at all.

## Reading list
- `CLAUDE.md` § The twelve rules, § If you need to break a rule
- `docs/orchestration/HANDOFF.md`
- `docs/design-system/DESIGN-SYSTEM.md` §5.9, §3, §8, §12
- `docs/design-system/tokens.css` — the state and semantic blocks
- `.claude/hooks/tokens-parity.sh` — why the hex set matters and the values do not
- `.claude/skills/decision/SKILL.md`

## Files
- `docs/design-system/DESIGN-SYSTEM.md` — §5.9, the kind→token map
- `docs/design-system/tokens.css` — three aliases (**escalates to the human**)
- `docs/design-system/DECISIONS.md` — one row, **D21**
- `src/ui/Callout.tsx`, `src/ui/Callout.module.css`, `src/ui/Callout.test.tsx` — new
- `src/locales/pt-BR/common.json` — the three kind labels

## Do

1. Add three aliases to `tokens.css`: `--gl-callout-note`,
   `--gl-callout-warning`, `--gl-callout-checkpoint`, each defined as `var(...)`
   of an existing value — no new hex. Expect the escalation prompt and wait for
   it.
2. Write the kind→token map into §5.9 so the next implementer does not guess.
3. Write **D21** with `/decision`: three callout aliases added; reason — §5.9
   named the kinds and not the colours; discarded — hard-coding a state token per
   kind at the call site.
4. `CalloutProps { kind: 'note' | 'warning' | 'checkpoint' }`. 3px left border,
   `border-radius: 0`, transparent background. The kind label comes from
   `common.json`, and each callout carries an accessible name so the kind is not
   conveyed by the border colour alone.
5. No emoji, no icon set. §8 forbids the first and §5.9 does not define the
   second.

## Delivers

### Artifacts
The file list above.

### Surface
`src/ui/Callout.tsx` exports `Callout` and `type CalloutProps`.

### Invariants
- Exactly three kinds. A fourth needs §5.9 edited first
- The hex set in `tokens.css` is unchanged — parity holds untouched

### Evidence
The parity check, the unit tests, and the human approval of the token edit.

### Debt
None.

## Acceptance

| Command | Expected |
|---|---|
| `bash .claude/skills/ds-check/ds-check.sh` | PASSED, including §12 parity |
| `pnpm test src/ui/Callout.test.tsx` | green |
| `rg -c '#[0-9a-fA-F]{6}' docs/design-system/tokens.css` | unchanged from before the spec |
| `rg -n '\| D21 ' docs/design-system/DECISIONS.md` | one row |

## Out of scope
- Any new hex value. If a kind needs a colour that does not exist, that is
  `BLOCKED`
- Lesson prose that uses callouts — S31
