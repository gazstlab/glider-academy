# Orchestration

How a queue of specs gets implemented by agents, one at a time, without the
coordinator drowning in its own context.

`CLAUDE.md` carries the summary that has to be true in every session. This file
carries the templates, the prompts and the worked example. When this file is
thinner than `CLAUDE.md`, `CLAUDE.md` wins — same rule the repository already
applies to `README.md` and the design system.

| Question | File |
|---|---|
| What the product is | `README.md` |
| What a screen looks like | `docs/design-system/DESIGN-SYSTEM.md` |
| How work gets from an issue to production | `CONTRIBUTING.md` |
| How CI, deploy and the board are wired | `docs/pipeline.md` |
| **How agents execute the queue** | this file |

This is not a second delivery process. `CONTRIBUTING.md`'s cycle — issue, branch,
PR, gate, squash, production — is unchanged. This file only says who does each
step and what they are allowed to know while doing it.

## 1 · The loop

```
main (coordinator)                          subagent (implementer)
  |                                                 |
  |-- reads docs/specs/, picks next unblocked ----->|
  |-- hands down the context packet --------------->|
  |                                                 |-- implements
  |                                                 |-- runs its own acceptance
  |                                                 |-- writes DELIVERS + HANDOFF
  |<-- returns the report --------------------------|
  |
  |-- spawns spec-auditor (clean context) ---------->  audit
  |-- spawns ds-reviewer too, if UI was touched ---->  design review
  |<-- PASS / REPAIR / BLOCKED ----------------------
  |
  PASS    -> commit, open the PR, next spec
  REPAIR  -> one round back to the same subagent, re-audit
  BLOCKED -> label state/blocked, stop the queue, escalate to the human
```

## 2 · main never implements

The coordinator reads specs, spawns agents, audits, hands off. **It does not edit
application code.**

This is not tidiness. A coordinator that implements is carrying, by the sixth
spec, five specs' worth of detail that no longer matters, and it starts answering
questions from its memory of what it built rather than from the file. That is the
same failure this repository already names as its worst one, in the rule that
comes before the others: *the certainty is the symptom, not the guarantee.*

So context is a budget, not a resource. Every subagent gets a closed packet and
no invitation to go exploring.

The coordinator may read anything it likes. It may not write outside
`docs/orchestration/HANDOFF.md` and the queue's own bookkeeping.

## 3 · The context packet

Six things. Not five, not "and also have a look around".

| # | Item | Why it is bounded |
|---|---|---|
| 1 | The spec file, verbatim | The whole task, and only the task |
| 2 | `docs/orchestration/HANDOFF.md` | The state of the world as of the last audited spec |
| 3 | The reading list — **sections, not files** | `DESIGN-SYSTEM.md §5.4` and `§6`, never "the design system" |
| 4 | The file fence | An allowlist of paths. A write outside it is an audit failure, not a judgement call |
| 5 | The acceptance commands | Verbatim, with their expected result |
| 6 | The branch name | `type/nn-slug`, per `CONTRIBUTING.md` §2 |

**`docs/orchestration/HANDOFF.md` is in every fence, always, without being
listed.** It is the one standing exception, and it exists because the protocol
orders every subagent to rewrite that file as its last act — a fence that
forbade it would make the protocol unsatisfiable.

**The fence governs tracked files.** Running the acceptance commands creates
`node_modules/`, `dist/`, `playwright-report/`, `test-results/` — all ignored,
none of them a decision anyone made. The auditor compares the fence against
`git diff --name-only`, which never sees them. If a spec's commands produce an
ignored artefact that is *not* already in `.gitignore`, that is a finding: the
gap belongs in `Debt`, not in the working tree. No spec needs to name it, and
a spec that does name it is not wrong, only redundant.

If the queue has not reached the issue-creating stage, the branch has no number
yet. The coordinator picks `type/00-slug` and says so, the way
`chore/00-pipeline` was named before there was an issue to number it after.

**The coordinator owes the subagent a clean tree.** Cut the branch, and cut it
from a commit that actually contains the spec's reading list — on a repository
mid-bootstrap, `main` may not yet carry the pipeline the spec is written against.
Handing a subagent a working tree with somebody else's uncommitted changes in it
poisons the one artefact the audit depends on: `spec-auditor` reads `git diff`,
and it cannot tell your work from the work that was already sitting there.

Item 3 is the one that gets skipped and the one that costs the most. "Read the
design system" is a 452-line instruction that an agent will skim; "read §5.4 and
§6" is an instruction it will follow. The reading list is written into the spec,
not improvised by the coordinator.

### The prompt template

```
You are implementing one spec, and only that spec.

SPEC
<the full contents of docs/specs/NNN-slug.md>

STATE OF THE WORLD
<the full contents of docs/orchestration/HANDOFF.md>

READ, IN THIS ORDER
  CLAUDE.md
  <the spec's Reading list, section by section>
Do not read further. If the spec is not executable from what is listed,
stop and say what is missing — that is a spec bug, and improvising past it
is worse than stopping.

YOU MAY WRITE ONLY THESE PATHS
  <the spec's Files fence>
A write outside this list fails the audit even when the change is correct.
If you believe the fence is wrong, stop and say so.

BRANCH
  <type/nn-slug>   — already checked out for you, from a clean tree

WHEN YOU ARE DONE
  1. Run every command under Acceptance. Paste the real output
  2. Overwrite docs/orchestration/HANDOFF.md following its own template
  3. Return the DELIVERS block, filled in — all five sections
Do not commit. Do not open a pull request. Do not close the issue.
Those belong to the coordinator, and an agent that merges its own work
has removed the only step that was checking it.
```

## 4 · The DELIVERS contract

What every spec hands the next. Five sections, all required — a spec that cannot
fill all five was scoped wrong, and that is worth discovering while writing it
rather than three specs later.

| Section | Content |
|---|---|
| **Artifacts** | Every file created or changed, exact paths |
| **Surface** | Exported symbols with signatures the next spec may build on |
| **Invariants** | What the next spec must not break, written as assertions |
| **Evidence** | Each acceptance command with its real output, pasted |
| **Debt** | What was deliberately left undone, and which spec collects it |

**Surface** is not always a list of exported symbols. For a spec that lands
configuration rather than code — a scaffold, a build step, a vendoring script —
it is the settings, versions and extension points later specs build on: the
pinned package manager, the resolved dependency versions, the port the preview
serves on, the config block a later spec is expected to fill. The test is not
"is it a signature" but "would the next spec have to go and read my files to
find this out". If it would, it belongs in `Surface`.

It is the load-bearing section, and it is where a wrong entry is most
expensive. If it names `export function step()` and the module exports `tick()`,
the next spec is built against a symbol that does not exist and fails on its
first import — three agent-hours after the mistake was made. The auditor checks
`Surface` against the diff for exactly this reason.

**Debt** is the second. An agent under a file fence that finds work it cannot do
has two silent options — exceed the fence, or leave a hole — and one honest one.
Naming the hole and the spec that collects it turns it into a handoff item.
`None` is a valid answer. Silence is not.

### Template

```markdown
## DELIVERS · S12

### Artifacts
- `src/engine/graph.ts` (new)
- `src/engine/graph.test.ts` (new)

### Surface
`src/engine/graph.ts` exports:
- `type TaskId = string`
- `interface TaskDef { id: TaskId; upstream: TaskId[]; ... }`
- `buildGraph(d: DagDef): Graph`
- `topoOrder(g: Graph): TaskId[]`
- `detectCycle(g: Graph): TaskId[] | null`

### Invariants
- `topoOrder` throws on a cyclic graph rather than returning a partial order
- `TaskDef.upstream` holds ids, never object references — the structure stays
  serialisable across the worker boundary

### Evidence
```
$ pnpm test src/engine/graph.test.ts
 ✓ src/engine/graph.test.ts (14 tests) 31ms
```

### Debt
- Setup and teardown relationships are not modelled. S13 decides whether they
  are needed; lesson 04 does not use them
```

## 5 · The audit

Two agents, disjoint jobs. The coordinator always spawns the first, and the
second whenever the spec touched UI.

| Agent | Question |
|---|---|
| `.claude/agents/spec-auditor.md` | Did this spec deliver what it promised, inside its fence, with evidence? |
| `.claude/agents/ds-reviewer.md` | Does the interface obey the design contract? |

The checklist lives in `spec-auditor.md` and is not repeated here — one contract,
one place, the same reason `review.yml` has no prompt of its own.

**When `ds-reviewer` is spawned:** whenever the diff touches anything that
renders — a component, a stylesheet, a screen, `index.html`, or product copy. Not
when it touches only configuration, engine code or tooling. When it is genuinely
unclear, spawn it: a redundant design review costs one agent round, and an
unreviewed first screen costs a contract.

**Who closes the issue:** nobody closes it by hand. The pull request says
`Closes #nn`, the squash merge closes it, and `project.yml` moves the card to
Done on `issues:closed`. That is `CONTRIBUTING.md`'s cycle, unchanged — the
coordinator opens the PR and merges it, and the issue follows.

The verdicts:

| | | |
|---|---|---|
| `PASS` | Every criterion met, with evidence | Commit, open the PR, next spec |

**Label the pull request with the spec's own labels.** `release.yml` builds the
release notes by label, so an unlabelled PR lands under *Everything else* no
matter what it did — and the labels are already written in the spec's header, so
there is nothing to decide. A `type/chore` PR is excluded from the notes on
purpose: the notes describe what the learner got, and the foundation is not
something the learner got.
| `REPAIR` | A gap in the **work**, fixable inside the fence | One round back to the same subagent |
| `BLOCKED` | A gap in the **spec**, or a decision a human owns | Stop the queue |

Sending a spec problem back as `REPAIR` produces an agent improvising outside its
fence, which is the failure the fence exists to prevent. When in doubt, block.

## 6 · Blocking rules

- **Never start a spec while the previous one is unaudited.** The queue is
  strictly sequential. Parallelism here buys a few minutes and costs the handoff,
  which is the only thing keeping spec twenty coherent with spec three
- **A subagent never closes its own issue and never merges its own PR**
- **Two failed repair rounds ends the queue.** Label `state/blocked`, write what
  is stuck, stop. An orchestrator that retries indefinitely burns a budget to
  produce the same wrong answer more confidently
- **A `tokens.css` change stops the queue by construction.** `tokens-guard.sh`
  escalates that edit to the human already; the coordinator does not work around
  a hook that exists to make it stop
- **An unverifiable Airflow claim stops the spec**, not the sentence. `CLAUDE.md`
  is explicit that an honest gap is recoverable and a false claim is not

## 7 · The state file

`docs/orchestration/HANDOFF.md`. One file, overwritten by each spec's subagent as
its last act. The subagent writes it; the **coordinator** commits it along with
the rest of the spec's work, because no subagent commits anything.

It holds the **current** state of the world, not a history: what exists, what it
exports, what must not break, what is owed. History already has three homes — the
issue thread, the squash commit and the release notes — and a fourth would drift
from all of them.

One overwritten file rather than an append-only log, deliberately. A log grows
until nobody loads it, and the moment nobody loads it the handoff has silently
stopped happening with nothing turning red. Same failure shape the pipeline
document is careful about elsewhere.

**Two lines in it are the coordinator's, not the implementer's.** `Last audited
spec` and `Verdict` record something no implementer can know — the audit has not
run when it writes the file, and an agent that fills them in is asserting that
its own work passed. The implementer leaves them alone; the coordinator sets
them when the verdict comes back.

**And the coordinator has one duty after the merge.** A spec's `Debt` may name
something that only becomes true once the branch lands — a label that syncs, a
workflow that fires. That is collected by the coordinator, not by a later spec,
and the handoff is stale until it is. S00 owed exactly this: `type/feature`
existed in `labels.yml` and not on GitHub until `labels-sync.yml` ran on the
merge.

## 8 · The spec format

Every file in `docs/specs/` carries the same eight sections, in this order.

| Section | Holds |
|---|---|
| `Depends on` / `Unblocks` | Spec ids. `Depends on` must name only earlier specs |
| `Context` | Why this exists and what it is for — three paragraphs at most |
| `Reading list` | Exact document sections. Nothing else is to be read |
| `Files` | The fence. An explicit allowlist of paths |
| `Do` | Numbered steps |
| `Delivers` | The five-section contract above, pre-filled with what is expected |
| `Acceptance` | Commands with their expected result |
| `Out of scope` | The named temptations |

Two of the eight are what make atomicity real rather than aspirational.

**`Files`** is the fence. Without an explicit list, "atomic" is a description of
intent, and intent does not survive an agent that notices something adjacent and
slightly broken.

**`Out of scope`** names the temptations so that declining them is compliance
rather than initiative. An agent that finds an obvious improvement one directory
over will take it unless told, in advance and by name, that taking it is the
error. This is also where a spec earns its reviewability: work correctly declined
is as auditable as work done.

### Template

```markdown
# S12 · the DAG graph — parse, topological order, cycle detection

| | |
|---|---|
| Form | `06-feature` |
| Labels | `type/feature` `area/lab` |
| Size | S |
| Branch | `feat/nn-engine-graph` |

## Depends on
S09

## Unblocks
S13, S17, S22

## Context
Two paragraphs. What this is for, and what the next spec does with it.

## Reading list
- `CLAUDE.md`
- `docs/orchestration/HANDOFF.md`
- `README.md` § Stack

## Files
- `src/engine/graph.ts` — new
- `src/engine/graph.test.ts` — new

## Do
1. …
2. …

## Delivers
### Artifacts …
### Surface …
### Invariants …
### Evidence …
### Debt …

## Acceptance
| Command | Expected |
|---|---|
| `pnpm test src/engine/graph.test.ts` | all green |
| `pnpm typecheck` | no errors |

## Out of scope
- Trigger rules — S13
- Anything that imports React
```

## 9 · A worked handoff

S12 finishes. The coordinator has the `DELIVERS` block above, and the auditor has
returned `PASS`. It commits, opens the PR, and builds the packet for S13:

- **The spec**: `docs/specs/S13-trigger-rules.md`, verbatim
- **The state**: `HANDOFF.md`, whose `Surface` now carries `buildGraph`,
  `topoOrder`, `detectCycle` and the `TaskDef` shape
- **The reading list**: `CLAUDE.md`; `.claude/skills/airflow-truth/SKILL.md`;
  `DESIGN-SYSTEM.md §3 Task states`. Not the whole design system, and not S12's
  source — S13 needs S12's *surface*, which it already has
- **The fence**: `src/engine/triggerRules.ts`, its test, and `DECISIONS.md`
- **The acceptance**: the test command, `pnpm typecheck`, and a check that every
  rule carries its `# verified:` annotation
- **The branch**: `feat/nn-trigger-rules`

S13's agent never reads `graph.ts`. It reads that `topoOrder` exists and what it
returns. That is the whole point: the packet is small because the previous spec
did the work of describing itself.

## 10 · Converting the queue into issues

The specs are the source. Issues are generated from them, not the other way
round, and only once the pipeline is live — `docs/pipeline.md` §3 is explicit
that labels have to exist before the first issue, because GitHub discards an
unknown label silently and the issue opens with no classification at all.

Order: merge the pipeline, enable the ruleset, sync the labels, then create the
issues from `docs/specs/` with the form and labels each spec names in its header.
A spec's issue number is what fills the `nn` in its branch name, so the branch
name in the spec header is written when the issue is created, not before.
