# S29 · implement the home screen

| | |
|---|---|
| Form | `02-component` |
| Labels | `type/component` `area/design-system` |
| Size | M |
| Branch | `feat/nn-home` |

## Depends on
S05, S11, S23, S28

## Unblocks
S33

## Context

The first screen anyone sees, and the first place the signature appears: §2's
"a row of 15 cells = the whole track, showing where you stopped". The home is
where the product makes its claim, so §9's writing rules are doing visible work
here — sentence case, an active verb naming the result, no `simplesmente`, no
exclamation mark, and no forced enthusiasm. The tone is a flight instructor.

All of the copy is pt-BR and all of it comes from `home.json`. There is one
primary button on the screen — the one that starts the lesson.

## Reading list
- `CLAUDE.md` § The product, § UI writing, § Branding
- `docs/orchestration/HANDOFF.md`
- `docs/design-system/DESIGN-SYSTEM.md` §5.18, §5.19 (from S28), §2, §4, §6, §7, §9
- `README.md` § What this is, § Transfer is the goal
- `docs/mockups/glider_v2_home_hero_airflow_aligned.html` — **and its banner**

## Files
- `src/screens/Home.tsx` — fill in
- `src/ui/Hero.tsx`, `src/ui/TrackCard.tsx` + modules + tests — new
- `src/locales/pt-BR/home.json` — new

## Do

1. `Hero` per §5.18. `BrandMark` turns once on load, at `--gl-dur-spin`, hero
   only. Do not write a `prefers-reduced-motion` query: the tokens zero
   themselves, and §7 says so explicitly.
2. `TrackCard` per §5.19, containing `TrackGrid` from S23 and reading real
   progress from its store.
3. Copy in `home.json`, written to §9. The headline claims something specific and
   technical. The primary button's verb is the one that comes back if there is a
   confirmation.
4. `Footer` from S11, carrying the ASF notice.
5. Tests: one primary button; the grid reflects stored progress; no percentage
   bar; the pinwheel animation is bound to the token and not to a literal
   duration.

## Delivers

### Artifacts
The file list above.

### Surface
`src/ui/Hero.tsx` exports `Hero`; `src/ui/TrackCard.tsx` exports `TrackCard`.
`src/screens/Home.tsx` renders the home.

### Invariants
- Exactly one primary button on the screen
- The only motion is the hero's single turn
- No emoji, no gradient, no percentage bar
- All copy from `home.json`

### Evidence
The unit tests and a rendered screenshot at 360, 900 and 1200 attached to the PR.

### Debt
`Referência` and `Sobre` still have no screens — S11's debt, unchanged.

## Acceptance

| Command | Expected |
|---|---|
| `pnpm test src/ui/Hero.test.tsx src/ui/TrackCard.test.tsx` | green |
| `pnpm lint && pnpm typecheck && pnpm build` | clean |
| `rg -n 'simplesmente\|apenas\|!' src/locales/pt-BR/home.json` | no §9 violations |
| `bash .claude/skills/ds-check/ds-check.sh` | PASSED |

## Out of scope
- The track index screen
- The lab — S32
- Any second animation
