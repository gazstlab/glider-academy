# S25 · implement §5.8 RunLog

| | |
|---|---|
| Form | `02-component` |
| Labels | `type/component` `area/design-system` |
| Size | S |
| Branch | `feat/nn-runlog` |

## Depends on
S09, S15, S20

## Unblocks
S32

## Context

Scheduler output, which in a teaching product is not decoration: reading the log
to find out why a task failed is one of the skills the lab exists to build. It is
also where §5.10's rule shows up in practice — an error says what broke and what
to do.

Two behaviours from §5.8, as thickened by S20, are easy to get wrong. **Auto-scroll
only while the user is at the end of the buffer** — a log that yanks the viewport
while someone is reading the failure they scrolled up to find is actively hostile.
And the `aria-live` policy: a log that announces every line is unusable with a
screen reader, so only state transitions are announced, not every line of stdout.

## Reading list
- `CLAUDE.md`
- `docs/orchestration/HANDOFF.md`
- `docs/design-system/DESIGN-SYSTEM.md` §5.8 (as rewritten by S20), §4, §9, §10
- `docs/specs/S14-run-loop.md` § Delivers — the `RunEvent` shape

## Files
- `src/ui/RunLog.tsx`, `RunLog.module.css`, `RunLog.test.tsx` — new
- `src/locales/pt-BR/log.json` — new

## Do

1. Render `RunEvent[]` as `<pre>` lines: mono, `--gl-text-sm`,
   `--gl-leading-snug`, timestamps in `--gl-text-muted`, the level coloured from
   the state tokens per §5.8's map.
2. Auto-scroll only when the viewport is already at the end. Detect it, do not
   assume it.
3. `aria-live="polite"` on state transitions only.
4. Timestamps in mono with `tabular-nums` — §8 required rule 2 applies to a log
   as much as to a grid.
5. Virtualise above the threshold §5.8 names.
6. Tests: a scrolled-up viewport is not yanked; levels map to the right tokens;
   an error line renders its message rather than a generic string.

## Delivers

### Artifacts
The file list above.

### Surface
`src/ui/RunLog.tsx` exports `RunLog` and `RunLogProps { events: RunEvent[] }`.

### Invariants
- Auto-scroll only at the end of the buffer
- Only transitions are announced
- Every timestamp is mono with `tabular-nums`

### Evidence
The unit tests, including the scroll-position case.

### Debt
Log output arrives per task rather than streamed line by line while a task runs —
S18's debt. Record whether it is worth closing.

## Acceptance

| Command | Expected |
|---|---|
| `pnpm test src/ui/RunLog.test.tsx` | green |
| `rg -n 'tabular-nums' src/ui/RunLog.module.css` | present |
| `pnpm lint && pnpm typecheck` | clean |
| `bash .claude/skills/ds-check/ds-check.sh` | PASSED |

## Out of scope
- Filtering or search
- The panel layout — S27
