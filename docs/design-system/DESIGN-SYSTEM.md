# Glider Design System

> An **implementation contract for UI and UX**, not a moodboard. Written to be
> read by AI agents (Claude Code, Copilot, Cursor) before any interface change,
> and by humans reviewing what the agent produced.
>
> **Scope: what a screen looks like and how it behaves.** Colour, type, spacing,
> components, layout, motion, UI copy, accessibility.
>
> **Out of scope: what the product is, who it serves, and why it exists.** That
> lives in `README.md`, with the working version for agents in `CLAUDE.md`. If
> this document and those disagree about the product, those win — a design system
> that also defines the business ends up being edited to win arguments about the
> business.
>
> **v2** — the visual language now descends from the Apache Airflow identity.
> See `DECISIONS.md` (D11–D18) for what was superseded and why.
>
> The document is in English, like the rest of the repository. Product copy in
> the examples stays in Portuguese, because that is what it is: product copy.

---

## 0. How to use this document (read first)

**Required reading order before writing any component:**

1. `README.md` — what the product is and who it is for. Read once; it is the
   context every rule below assumes
2. `CLAUDE.md`, at the root — the short rules and the checklist
3. this file, the section for the component you are about to touch
4. `docs/design-system/tokens.css` — the exact variable names

**If the component you need is not here:** do not invent a style. Compose it from
the primitives, or stop and propose the addition to this document first. A new
component only enters the code after it enters this file.

**If this document conflicts with the code:** this document wins.

**If a question is not about the interface, this is the wrong document.** Scope,
audience, roadmap, what a lesson should teach, whether a feature belongs — none
of that is decided here. Asking a design system to settle a product question is
how design systems acquire opinions nobody signed off on.

---

## 1. The design test

What Glider is, who it serves and what each lesson has to achieve are defined in
`README.md`. Three facts from there constrain every rule in this document, and
they are repeated here only as constraints, not as definitions:

| From the product | What it forces on the design |
|---|---|
| Transfer is the goal | Where Airflow has a convention, inherit it |
| No backend, static + WASM | The design never assumes server state or a round trip |
| Copy is pt-BR, in locale files | No string is ever authored inside a component (§9) |

**The test, applied to every visual decision:** *does this move closer to real
Airflow, or further away?*

That is the whole of it. Where Airflow has a convention, we inherit it. Where it
has a known problem — contrast, state by colour alone — we fix it while keeping
the hue identity, because recognition survives a value change and does not
survive a hue change.

The test is deliberately narrow. It settles "should this cell be a square or a
dot" and it does not settle "should this lesson exist" — the second is a product
question, and answering it here would make the design system an authority on
something it was never reviewed for.

**The glider metaphor lives in the vocabulary**, not in the paint: the name, the
tone, the track titles. No glider illustration in the UI. This one is a design
rule, and it is here because it is enforceable here.

---

## 2. Visual lineage

Three anchors, verified against the source:

1. **Brand blue `#017CEE`** — the Apache Airflow colour, whose symbol is a
   stylised pinwheel suggesting motion and cyclical scheduling.
2. **`airflow.utils.state.state_color`** — the canonical state-to-colour map, in
   CSS named colours (`green`, `lime`, `gold`, `hotpink`, `turquoise`,
   `mediumpurple`…).
3. **The Airflow 3 UI** — React + Chakra, themeable through `brand` and `gray`
   colour tokens. Our token structure mirrors that shape on purpose.

### The signature: the grid

The element Glider is remembered by is the **grid** — squares coloured by state,
row = task, column = run. It is Airflow's most recognisable visual, and here it
is the same object at three scales:

- **Home:** a row of 15 cells = the whole track, showing where you stopped
- **Track index:** rows = lessons, columns = your attempts
- **Inside the lab:** the real grid of the DAG run you just triggered

```
          run 1  run 2  run 3          ■ success    ▢ queued
extrair    ■      ■      ■             ◉ running    ✕ failed
limpar     ■      ✕      ◉             ↻ retry      ⁄ skipped
somar      ■      ▢      ▢
publicar   ⁄      ▢      ▢
```

Track progress **is** a column of that grid. There is no percentage bar anywhere
in the product.

The only ambient motion is the **`running` state pulse**. The brand pinwheel
turns slowly in the hero only, once, on page load.

---

## 3. Colour

**Always** use the semantic role (`--gl-text`, `--gl-surface`). The ramps
(`--gl-brand-*`, `--gl-gray-*`) exist for the roles to reference and must **not**
appear directly in a component.

**Light is the default** theme (as in the Airflow UI); dark is first class, not
second.

| Role | Token | Light | Dark |
|---|---|---|---|
| Background | `--gl-bg` | `#F7F9FB` | `#10161F` |
| Surface | `--gl-surface` | `#FFFFFF` | `#1B2431` |
| Raised surface | `--gl-surface-raised` | `#EDF1F5` | `#2A3646` |
| Border | `--gl-border` | `#DCE3EB` | `#2A3646` |
| Text | `--gl-text` | `#1B2431` | `#EDF1F5` |
| Secondary text | `--gl-text-muted` | `#55677E` | `#9AA8B8` |
| Accent | `--gl-accent` | `#017CEE` | `#1A8CF1` |

### Task states

Inherited from Airflow by **hue**, retuned by **value** to pass contrast. This
table is the source; do not improvise a new state.

| State | Airflow | `--gl-state-*` | Glyph |
|---|---|---|---|
| `success` | green | `success` | filled square with ✓ |
| `running` | lime | `running` | pulsing ring |
| `queued` | gray | `queued` | outlined square |
| `up_for_retry` | gold | `up-for-retry` | ↻ |
| `upstream_failed` | orange | `upstream-failed` | ↑ |
| `failed` | red | `failed` | ✕ |
| `skipped` | hotpink | `skipped` | ⁄ |
| `up_for_reschedule` | turquoise | `up-for-reschedule` | ⏱ |
| `scheduled` | tan | `scheduled` | · |
| `deferred` | mediumpurple | `deferred` | ⏸ |
| `restarting` | violet | `restarting` | ↺ |
| `removed` | lightgrey | `removed` | ▨ |
| `none` | lightblue | `none` | empty |

**Three rules that block a review:**

1. **Brand blue is never a state colour.** Blue in a grid square is a bug.
   `--gl-accent` serves the primary action and navigation, and nothing else.
2. **State = colour + glyph + accessible text.** `lime` and `green` (running and
   success) are nearly indistinguishable to colour-blind readers — it is the
   historical complaint about Airflow's UI, and exactly why the glyph is not
   optional here.
3. **No invented states.** If it is not in `airflow.utils.state`, it does not
   exist in Glider.

### Contrast

Minimum 4.5:1 for text, 3:1 for borders and glyphs that carry information. Every
state colour was tuned to pass over `--gl-surface` in its own theme.

---

## 4. Typography

| Role | Family | Where |
|---|---|---|
| Display | **Familjen Grotesk** | h1, h2, large numbers |
| Body | **Inter** | paragraphs, UI, buttons |
| Utility | **JetBrains Mono** | code, cron, durations, task IDs, labels |

Inter is a **transfer** choice, not a lazy one: it is the Airflow UI's font, and
the familiarity is the product. Personality comes from the display face, which is
geometric and mildly idiosyncratic — just enough that Glider does not read as a
fork of Airflow.

Fonts are **self-hosted** — a constraint the platform imposes on the design, not
a preference. The reason (cross-origin isolation, and what it buys the lab) is in
`CONTRIBUTING.md`. What it means here: never reference a font from a CDN, and
give every face a real fallback stack.

**Scale** — `--gl-text-2xs` … `--gl-text-4xl` (11 → 72px). `4xl` in the home hero
only.

**Labels:** mono, `--gl-text-2xs`, uppercase, `--gl-tracking-label`,
`--gl-text-muted`. They must carry real information: `LIÇÃO 04 · 12 MIN`,
`SCHEDULE @daily`.

**Numbers:** `font-variant-numeric: tabular-nums`, required on any number in a
list, table, grid or instrument.

---

## 5. Components

A fixed contract. Agents implement the contract; they do not add a new `variant`
without updating this document.

### 5.1 `Button`

| Variant | Use | Appearance |
|---|---|---|
| `primary` | One per screen. The action that runs something | `--gl-accent` background, `--gl-on-accent` text, `--gl-radius-ui` radius |
| `secondary` | Supporting actions | `--gl-surface` background, `--gl-border-strong` border |
| `ghost` | Toolbar | no border, `--gl-surface-raised` on hover |
| `danger` | Destructive lab reset only | `--gl-state-failed` border and text |

Height 32px (`sm`) or 40px (`md`). Label in sentence case, active verb, and the
same verb as the result: `Disparar DAG` → toast `DAG disparado`.

### 5.2 `StateCell`

The grid square. `--gl-cell-size`, `--gl-cell-radius` radius, filled with the
state colour and carrying the glyph from 12px upward. Below that the glyph
disappears and `title` + `aria-label` carry the state spelled out.

`running` gets a ring pulsing at `--gl-dur-pulse`. No other state animates.

### 5.3 `StateChip`

Legend and textual label. Colour + glyph + text, all three. Mono,
`--gl-text-2xs`, uppercase, `--gl-radius-ui` radius, transparent background with
a border in the state colour.

### 5.4 `GridView`

The signature. Rows = tasks, columns = runs, most recent on the right. Column
header in mono with the logical date. Hovering any cell highlights the whole row
and the whole column.

Non-negotiable requirements:
- it is a semantic `<table>`, not a sea of `<div>`s
- every cell is focusable, with an `aria-label` in the form
  `limpar · run 2026-08-22 · falhou`
- a text-list alternative exists; the grid is never the only way to read state

### 5.5 `GraphView`

Rectangular nodes, `--gl-radius-node` radius, **border** in the state colour
(this is how Airflow does it — border, not fill), `--gl-surface` background.
Edges in `--gl-border-strong`, solid.

- keyboard navigable (arrows between nodes, Enter opens the detail)
- each node is a `<button>` with an `aria-label` including the task id and the
  state spelled out

### 5.6 `TrackGrid` (progress)

Track progress is a **grid column**: 15 cells, one per lesson, coloured by their
state (`success`, `running`, `queued`). There is no percentage bar.

Fallback: `role="progressbar"` with `aria-valuenow/min/max` and the text
`Lição 4 de 15`.

### 5.7 `CodePane`

Monaco. Theme derived from the tokens — **do not use the stock `vs`/`vs-dark`**.
`--gl-surface` background, `--gl-text-muted` gutter, `--gl-accent-quiet`
selection.

### 5.8 `RunLog`

Scheduler output. Mono, `--gl-text-sm`, `--gl-leading-snug`. Timestamps in
`--gl-text-muted`, log level coloured by the state tokens. Auto-scrolls only
while the user is at the end of the buffer.

### 5.9 `Callout`

Three kinds, and only three: `note`, `warning`, `checkpoint`. 3px left border in
the kind's colour, `border-radius: 0`, no coloured background, no emoji.

### 5.10 Empty and error states

An empty screen is an invitation to act. An error says what broke and what to do,
in the interface's voice.

- ✅ `Nenhum DAG encontrado. Verifique se o arquivo está em dags/ e dispare de novo.`
- ❌ `Ops! Algo deu errado 😕`

---

## 6. Layout

- `--gl-max-width` container (1200px), `--gl-gutter` gutter
- Running text capped at `--gl-prose-width` (68ch)
- The lab uses 3 resizable panels; content uses a 12-column grid
- Breakpoints: `640` / `900` / `1200`
- **Below 900px the lab becomes read + run, with no editable canvas.** Decided
  (D9), do not reopen.

---

## 7. Motion

| Situation | Duration | Easing |
|---|---|---|
| Hover, focus | `--gl-dur-1` | `--gl-ease-out` |
| Panel entrance, popover | `--gl-dur-2` | `--gl-ease-snap` |
| Lesson transition | `--gl-dur-3` | `--gl-ease-snap` |
| `running` state pulse | `--gl-dur-pulse` | `ease-in-out`, infinite |
| Hero pinwheel turn | `--gl-dur-spin` | `linear`, **one turn only** |

Nothing else animates. No parallax, no scroll reveal, no counting up.
`prefers-reduced-motion` zeroes the durations through the tokens — do not write
your own media query.

---

## 8. Rules for AI agents

**Forbidden**
1. Literal hex, `rgb()` or `hsl()` in any file other than `tokens.css`
2. Arbitrary colour utility classes (`bg-[#017CEE]`, `text-slate-400`)
3. Spacing outside the scale (`padding: 13px`)
4. `box-shadow` outside the three tokens (`card`, `pop`, `ring-focus`)
5. `border-radius` above 8px outside `--gl-radius-pill`
6. Brand blue used as a state colour
7. A task state that does not exist in `airflow.utils.state`
8. A new component library without a recorded decision
9. Emoji in product UI; gradients in a background or a button
10. State communicated by colour alone
11. A percentage progress bar anywhere
12. Reproducing the Apache Airflow logo or a close derivative of it (see §11)
13. UI copy written inline instead of in a locale file (see §9)

**Required**
1. Every new component enters this document **before** the code
2. Every number in a list, grid or instrument uses mono + `tabular-nums`
3. Every interactive control has visible focus inherited from `:focus-visible`
4. Every state cell has a glyph and an `aria-label` with the state spelled out
5. Every decision that contradicts this document becomes a row in `DECISIONS.md`

**Before opening a PR:**

```
/ds-check
```

Runs the four checks — literal colour outside the tokens, `box-shadow` outside
the tokens, radius above 8px, brand blue as a state — across every source file,
plus the `tokens.css` ↔ `tokens.json` parity of §12 and the locale parity of §9.
It has to pass.

The patterns cover the camelCase spelling used in JSX (`boxShadow`,
`borderRadius`), which an earlier version of this block let through.

How those checks are wired — one implementation, three callers, and what happens
on a pull request — is in `docs/pipeline.md`. It is not repeated here: this
document says what the rules are, the pipeline document says how they are
enforced, and a rule that drifts from its enforcement is easier to spot when the
two are not interleaved.

---

## 9. Writing

- Sentence case in headings, buttons and labels
- An active verb that says what happens: `Disparar DAG`, not `Executar`
- The action keeps the same name from the start of the flow to the end
- **Use Airflow vocabulary, not synonyms.** `task`, `DAG run`, `data lógica`,
  `upstream`, `backfill`, `up_for_retry`. Translating those works against
  transfer, which is the point of the product. Explain on first appearance, yes;
  replace, no
- No `simplesmente`, `apenas`, `é só`. No exclamation marks, no emoji
- **All UI copy lives in `src/locales/<locale>/*.json`, never inline.** `pt-BR` is
  the source locale

That last rule is the only part of the language policy this document owns, and it
is here because it is a component-level constraint: a string typed into a `.tsx`
is a design defect the same way a raw hex is, and the reviewer catches it in the
same pass.

Which locales exist, when English is added, and how parity is enforced are
product and engineering decisions. They live in `README.md` and `CONTRIBUTING.md`.

---

## 10. Quality floor

- [ ] Responsive down to 360px
- [ ] Full keyboard navigation, with visible focus
- [ ] `prefers-reduced-motion` respected
- [ ] Contrast 4.5:1 for text, 3:1 for glyphs and informative borders
- [ ] State never communicated by colour alone
- [ ] Light and dark themes checked on the same screen
- [ ] Grid readable under deuteranopia and protanopia simulation
- [ ] No CLS: grid and canvas reserve height before mounting
- [ ] Fonts with `font-display: swap` and a system fallback

This floor is human. No script checks it, and no agent should claim it is met —
it belongs to whoever merges the PR.

---

## 11. What the interface may not draw

The trademark position — that Apache Airflow is an ASF trademark, that Glider is
not an ASF project, and what that means commercially — is stated in `README.md`
and `LICENSE-CONTENT`. This section is only the part a reviewer can check by
looking at a diff:

- **Do not draw the Airflow logo,** or a pinwheel close enough to be confused
  with it. Glider's mark is its own; the visual kinship is in the palette and the
  structure, not in the symbol
- **The footer carries the trademark notice**, from the locale files like every
  other string. Its wording is set in `README.md`, not here — one place, so a
  legal line is never edited as a design tweak
- **Copy never claims endorsement.** "labs for learning Apache Airflow", never
  "official Airflow Labs"

Inheriting state colours from an Apache-2.0 project is legitimate; reproducing
brand identity is not. That distinction is why §3 inherits hues and §11 forbids
the symbol — the same boundary, seen from two sides.

---

## 12. The files this document governs

```
docs/design-system/
├─ DESIGN-SYSTEM.md  ← this file, the narrative source for UI and UX
├─ tokens.css        ← single source of truth for the values
├─ tokens.json       ← the same values for Tailwind/Style Dictionary
└─ DECISIONS.md      ← design exceptions and changes of direction
```

Four files, and their authority stops at the interface. `DECISIONS.md` records
design decisions only: a row there settles what a component looks like, never
what the product does.

For anything outside that boundary: `README.md` for the product, `CLAUDE.md` for
the working contract agents load each session, `CONTRIBUTING.md` for the
issue-to-production flow, `docs/pipeline.md` for CI, deploy and the board.

`tokens.css` and `tokens.json` have to be generated from the same origin or
verified in CI. If they diverge, `tokens.css` wins.

`.claude/hooks/tokens-parity.sh` performs that check, on every save and in the
`contract` job. It compares the **set of hex colours**, deliberately not the
numeric values: there are legitimate asymmetries (0ms exists only in the css,
inside the `prefers-reduced-motion` block; the 640px/900px breakpoints exist only
in the json), and a check that flagged those would be abandoned in its first week.
