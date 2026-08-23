# S19 · stop a hung run through the SharedArrayBuffer interrupt buffer

| | |
|---|---|
| Form | `06-feature` |
| Labels | `type/feature` `area/lab` |
| Size | M |
| Branch | `feat/nn-interrupt` |

## Depends on
S16

## Unblocks
S32

## Context

The reason COEP is on at all. `CONTRIBUTING.md` §7 is explicit: without
`SharedArrayBuffer` the UI cannot interrupt a Python run that hung, and the stop
button has no way to reach the worker. A learner writing `while True: pass` is
not an edge case in a teaching product — it is Tuesday.

Four things have to hold simultaneously, and **three of them are checked by
nothing**: `vercel.json`'s headers in production (smoke-tested), Vite's
`server.headers` in dev (nothing), `preview.headers` under Playwright (nothing),
and `setInterruptBuffer` actually firing (nothing). When `SharedArrayBuffer` is
`undefined`, the symptom is an unrelated TypeError deep inside worker
initialisation, months away from the configuration that caused it.

So the mitigation is a refusal, not a fallback: if the page is not cross-origin
isolated, the runtime does not start and the UI renders the §5.10 error state
naming the missing header. A degraded lab that silently cannot be stopped is
worse than one that says why.

One honest limit for the copy: `setInterruptBuffer` interrupts Python bytecode,
not a hung JavaScript await. The button's guarantee is narrower than a learner
will assume, and §9 says an error — and a promise — says what is actually true.

## Reading list
- `CLAUDE.md`
- `docs/orchestration/HANDOFF.md`
- `CONTRIBUTING.md` §7 — what COEP costs and why
- `vercel.json`, `vite.config.ts` — all three header configurations
- `docs/design-system/DESIGN-SYSTEM.md` §5.10, §9

## Files
- `src/runtime/interrupt.ts`, `src/runtime/interrupt.test.ts` — new
- `src/runtime/worker.ts`, `src/runtime/client.ts` — wire the buffer and the guard
- `src/locales/pt-BR/lab.json` — the isolation error copy
- `e2e/interrupt.spec.ts` — new

## Do

1. `createInterruptBuffer(): Uint8Array` over a `SharedArrayBuffer`, and
   `interrupt(buf)` writing `2` — SIGINT. Hand it to `pyodide.setInterruptBuffer`
   at boot and clear it before each task.
2. The boot guard: if `!crossOriginIsolated`, refuse to start and surface a typed
   failure. Do not fall back to a non-shared buffer.
3. The error copy in `lab.json`, per §5.10 and §9: what broke and what to do, no
   `simplesmente`, no exclamation mark. It names the missing header.
4. Wire `stop()` from S15's store through to `interrupt()`.
5. `e2e/interrupt.spec.ts`: run a task containing `while True: pass`, press stop,
   assert the task lands `failed` and the UI is responsive — **in both browsers,
   against the built preview.**

## Delivers

### Artifacts
The file list above.

### Surface
`src/runtime/interrupt.ts` exports `createInterruptBuffer()` and `interrupt()`.

### Invariants
- **No `crossOriginIsolated`, no runtime.** Never a silent degraded mode
- The interrupt buffer is cleared before every task
- The copy does not promise that stop cancels anything other than running Python

### Evidence
The interrupt e2e in both browsers, and the refusal path shown deliberately.

### Debt
A worker hung in JavaScript rather than Python is not interruptible.
`dispose()` and a worker restart are the fallback — record whether S32 needs to
expose that.

## Acceptance

| Command | Expected |
|---|---|
| `pnpm test:e2e e2e/interrupt.spec.ts` | green in chromium and firefox, from `dist/` |
| `pnpm test src/runtime/interrupt.test.ts` | green, including the refusal |
| `rg -n 'crossOriginIsolated' src/runtime/` | the guard is present |
| `bash .claude/skills/ds-check/ds-check.sh` | PASSED |

## Out of scope
- Editing `vercel.json`
- Any component — the error state is copy plus the existing §5.10 pattern
- A JavaScript-level watchdog
