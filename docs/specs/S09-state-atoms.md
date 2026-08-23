# S09 · implement StateCell and StateChip over the verified state set

| | |
|---|---|
| Form | `02-component` |
| Labels | `type/component` `area/design-system` `state/needs-verification` |
| Size | M |
| Branch | `feat/nn-state-atoms` |

## Depends on
S02, S03

## Unblocks
S10, S12, S21, S22, S23, S25

## Context

Everything the product shows is built from one square. §5.2 `StateCell` and §5.3
`StateChip` are the two atoms; the grid, the graph, the track and the log all
colour themselves from the same set.

That set has to be right before any of them exist, and there is a discrepancy to
settle first. §3 and `tokens.css` list thirteen states. `TaskInstanceState` at
3.3.1 also has thirteen — **but not the same thirteen**. The enum carries
`AWAITING_INPUT` (human-in-the-loop) and has no `none` member; the source
comments say the scheduler uses Python `None`. Glider effectively swapped one for
the other, and nothing records that. D18 says no state outside
`airflow.utils.state` may exist here.

Resolve it, do not paper over it. Either a `DECISIONS.md` row fixing Glider's set
with the source cited, or — if the check shows §3 is simply wrong — a
`type/content-error` issue, which is critical by definition. Do not silently pick
one: this is the exact defect class `README.md` ranks worst.

The other half is the accessibility contract. §3, D8 and §8 all say the same
thing three ways: colour **and** glyph **and** accessible text. `lime` and
`green` are nearly identical to a colour-blind reader, which is the historical
complaint about Airflow's own UI and the reason the glyph is not optional.

## Reading list
- `CLAUDE.md` § The rule that comes before the others
- `docs/orchestration/HANDOFF.md`
- `docs/design-system/DESIGN-SYSTEM.md` §3 (all of it), §5.2, §5.3, §7, §8
- `docs/design-system/DECISIONS.md` — D8, D14, D15, D18
- `.claude/skills/airflow-truth/SKILL.md` — the procedure, and use it
- `.claude/hooks/ds-selftest.sh`

## Files
- `src/engine/types.ts` — new
- `src/ui/StateCell.tsx`, `src/ui/StateChip.tsx`, `src/ui/glyphs.tsx` + modules — new
- `src/ui/*.test.tsx` — new
- `src/locales/pt-BR/states.json` — new
- `docs/design-system/DECISIONS.md` — one row, **D20**
- `.claude/hooks/ds-selftest.sh` — one `accepts` case

## Do

1. **Verify first.** Read `airflow-core/src/airflow/utils/state.py @ 3.3.1`
   through `/airflow-truth`. List `TaskInstanceState` exactly. Compare against §3
   and `tokens.css`.
2. Resolve the discrepancy and write **D20** naming Glider's set, citing the
   path and tag. If §3 is wrong rather than deliberately narrowed, stop and open
   a `type/content-error` issue instead — that is a `BLOCKED` verdict, not a
   judgement call for this spec.
3. `src/engine/types.ts`: `type TaskState`, `const TASK_STATES`,
   `const TERMINAL_STATES`, `stateToken(s)`, `stateGlyph(s)`. Annotate the state
   list `// verified: airflow-core/src/airflow/utils/state.py @ 3.3.1`.
4. `glyphs.tsx` — the §2 legend as SVG paths: ■ success, ▢ queued, ◉ running,
   ✕ failed, ↻ retry, ⁄ skipped, ↑ upstream_failed, and the rest.
5. `StateCell` per §5.2: `--gl-cell-size`, `--gl-cell-radius`, filled with the
   state colour, glyph from 12px upward, and below 12px the glyph goes and
   `title` + `aria-label` spell the state out. `running` gets a ring pulsing at
   `--gl-dur-pulse`; **nothing else animates**.
6. `StateChip` per §5.3: mono, `--gl-text-2xs`, uppercase, `--gl-radius-ui`,
   transparent background, border in the state colour, colour + glyph + text.
7. `states.json` holds the pt-BR readable phrase per state. The Airflow token is
   never translated — `up_for_retry` stays `up_for_retry`; the phrase beside it
   (`falhou`, `pulada`) is what gets written.
8. Add an `accepts` case to `ds-selftest.sh` proving rule 5
   (`state.*gl-accent|gl-accent.*state`) tolerates a line that legitimately
   mentions both — a legend pairing a state name with `--gl-accent` as a border.
   Do **not** widen the regex: that is a "Loosens" change and needs its own
   harness issue with the written reason the form demands.

## Delivers

### Artifacts
The file list above.

### Surface
`src/engine/types.ts` exports `TaskState`, `TASK_STATES`, `TERMINAL_STATES`,
`stateToken()`, `stateGlyph()`. `src/ui/` exports `StateCell`, `StateChip`.

### Invariants
- No state outside the verified set. Adding one needs §3 edited and a new row
- Every state renders colour **and** glyph **and** accessible text
- Brand blue is never a state colour (D15)
- Only `running` animates

### Evidence
The `/airflow-truth` transcript, the unit tests, `ds-selftest.sh` with the new
case.

### Debt
`awaiting_input` is out of scope for the lab and, depending on step 2, may be out
of Glider's set entirely — D20 records which.

## Acceptance

| Command | Expected |
|---|---|
| `bash .claude/hooks/ds-selftest.sh` | all cases green, including the new `accepts` |
| `pnpm test src/ui src/engine` | green |
| `rg -n '# verified:.*state.py @ 3.3.1' src/engine/types.ts` | one hit |
| `rg -n '\| D20 ' docs/design-system/DECISIONS.md` | one row |
| `bash .claude/skills/ds-check/ds-check.sh` | PASSED |

## Out of scope
- `GridView`, `GraphView`, `TrackGrid` — S21, S22, S23
- Trigger rules — S13
- Editing `tokens.css`. If the resolved set needs a token that does not exist,
  that is `BLOCKED`
