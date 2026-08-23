# S32 · assemble the lab screen and close the loop

| | |
|---|---|
| Form | `06-feature` |
| Labels | `type/feature` `area/lab` |
| Size | M |
| Branch | `feat/nn-lab-assembly` |

## Depends on
S11, S15, S18, S19, S21, S22, S24, S25, S26, S27, S31

## Unblocks
S33

## Context

Every part exists. This spec wires them into the thing the product actually is:
the learner opens lesson 04, reads why a task can be blocked rather than broken,
writes the DAG, presses `Disparar DAG`, watches the grid go red and orange, reads
the log, fixes it, and watches it go green.

**This spec touches no component internals.** It is assembly and nothing else. If
it needs to open a component and change how that component works, that
component's spec was not finished — and the honest response is to say so rather
than to patch it from here, because a fix made during assembly is a fix made
without the context that produced the component.

It is also where the whole queue is proved. One Playwright journey, end to end,
is worth more than every unit test that came before it, because it is the only
thing that has ever run all of the parts together.

## Reading list
- `CLAUDE.md`
- `docs/orchestration/HANDOFF.md` — **all of it; this is where the Surface matters**
- `docs/design-system/DESIGN-SYSTEM.md` §6, §5.15
- `docs/design-system/DECISIONS.md` — D9

## Files
- `src/screens/Lab.tsx` — fill in
- `src/screens/Lab.test.tsx` — new
- `src/locales/pt-BR/lab.json` — screen-level keys only
- `e2e/lab.spec.ts` — new

## Do

1. Compose: `Header` · `TrackGrid` · `Panel(CodePane | GridView + GraphView |
   RunLog)` · `TaskDetailPanel` · `Toast` · `Footer`.
2. Wire `useDagRun` with `pyodideExecutor`. The trigger button runs; the stop
   button interrupts through S19's buffer.
3. Selection is shared: a cell in the grid and a node in the graph drive the same
   detail panel.
4. Load the lesson through `getLesson('04')`; render its prose; evaluate its
   checkpoint after each run and show the result as a `checkpoint` Callout.
5. Below 900px, the read + run layout from S27. Not a smaller editor.
6. `e2e/lab.spec.ts` — **one journey, both browsers, against the built preview**:
   open `/licao/04`; the runtime reaches ready; trigger; `limpar` goes `failed`
   and `somar` goes `upstream_failed`; the log names the failure; fix the code;
   trigger again; every task reaches `success`; the toast appears; the checkpoint
   passes.

## Delivers

### Artifacts
The file list above.

### Surface
`src/screens/Lab.tsx` renders the lab. No new exported API.

### Invariants
- **No component internals were modified.** `git diff` touches `src/ui/` only if
  a spec is being reopened, and that is a finding
- Grid and graph share one selection
- Below 900px there is no editable canvas
- The full journey passes in chromium and firefox from `dist/`

### Evidence
The lab e2e in both browsers, with the intermediate states visible in the output.

### Debt
Whatever the journey exposes that is not worth fixing here — record each item and
the spec that would collect it.

## Acceptance

| Command | Expected |
|---|---|
| `pnpm test:e2e e2e/lab.spec.ts` | green in chromium and firefox, from `dist/` |
| `git diff --name-only main...HEAD -- src/ui/ src/engine/ src/runtime/` | empty |
| `pnpm lint && pnpm typecheck && pnpm build` | clean |
| `bash .claude/skills/ds-check/ds-check.sh` | PASSED |

## Out of scope
- Changing any component. If one is wrong, that is a new issue against its spec
- A second lesson
- Performance work not required to make the journey pass
