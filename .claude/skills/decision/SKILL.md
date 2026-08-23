---
name: decision
description: Records a design decision in docs/design-system/DECISIONS.md, in the table's format, numbered and dated. Use when contradicting a design system rule, when changing direction, or when locking in an architectural choice the code alone does not explain.
argument-hint: [what was decided]
disable-model-invocation: true
allowed-tools: Bash(${CLAUDE_SKILL_DIR}/add.sh:*) Read
---

`CLAUDE.md` is explicit: an exception without a line in `DECISIONS.md` is a bug.
This skill writes the line.

## Before writing

Read `docs/design-system/DECISIONS.md`. If the new decision **supersedes** an
earlier one, the file's convention is to mark that in the decision cell itself —
see D11, D12, D13, D16 and D17, which use `**Supersedes Dx**`. Do not delete the
old row: the history of why the direction changed is half the file's value.

## Writing

```bash
${CLAUDE_SKILL_DIR}/add.sh "<decision>" "<reason>" "<discarded>"
```

The `Dnn` number and the date are automatic. All three fields are required.

Each one has a job, and the third is the one people skip:

- **decision** — what now holds, in one line. If it supersedes another, start
  with `**Supersedes Dx** · `
- **reason** — why, tied to the product. `because it looks better` is not a
  reason; `because transfer is the product and this moves closer to real
  Airflow` is
- **discarded** — the alternative inside the system you considered and refused.
  Without it the row is useless six months from now: whoever reads it will not
  know whether the obvious option was evaluated or never crossed anyone's mind

After writing, confirm the table still renders (the row has exactly four cells)
and read the line back out loud. If it does not convince you, the decision
probably is not ripe yet.
