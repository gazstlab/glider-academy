import { expect, test } from '@playwright/test';

// tokens.css lives under docs/ and reaches the bundle only because
// src/tokens/index.ts imports it across that boundary (D22). This asserts the
// bridge in the artefact that ships: the built preview, in a real browser,
// with every role resolving in both themes.
//
// It reads names, never values. §8 rule 1 forbids a literal hex anywhere in
// src/ or e2e/, and a test that hard-coded the palette would have to be edited
// every time a value is retuned — which is exactly the copy this spec exists
// to avoid.

/** Every semantic role — §3's table plus the ones the shadows depend on. */
const ROLES = [
  'bg',
  'surface',
  'surface-raised',
  'border',
  'border-strong',
  'text',
  'text-muted',
  'accent',
  'accent-hover',
  'accent-quiet',
  'on-accent',
  'focus',
] as const;

/**
 * Glider's task-state colours: the twelve members of `TaskInstanceState`, plus
 * `none` — which is not an enum member at all but `State.NONE`, whose value is
 * Python `None`, the absence of a state.
 *
 * Exact as of 3.2.2. At 3.3.1 the enum gains a thirteenth member,
 * `AWAITING_INPUT` (a task parked for human input, HITL), which Glider does not
 * draw; whether it should is #14's call, not this file's.
 *
 * # verified: airflow-core/src/airflow/utils/state.py @ 3.3.1 (and @ 3.2.2)
 */
const STATES = [
  'state-none',
  'state-scheduled',
  'state-queued',
  'state-running',
  'state-success',
  'state-failed',
  'state-up-for-retry',
  'state-up-for-reschedule',
  'state-upstream-failed',
  'state-skipped',
  'state-deferred',
  'state-restarting',
  'state-removed',
] as const;

/** The shape scale. `pill` included: §8 rule 4 rejects the literal it stands for. */
const RADII = ['radius-cell', 'radius-node', 'radius-ui', 'radius-card', 'radius-pill'] as const;

/** The motion scale — §7's durations and easings. */
const MOTION = [
  'ease-out',
  'ease-snap',
  'dur-1',
  'dur-2',
  'dur-3',
  'dur-pulse',
  'dur-spin',
] as const;

const TOKENS = [...ROLES, ...STATES, ...RADII, ...MOTION];

/**
 * The roles the dark block redefines. Asserting these *change* is what proves
 * `:root[data-theme="dark"]` was applied at all — every token stays non-empty
 * under an attribute that matched nothing, by inheriting from `:root`.
 */
const THEMED = ['bg', 'surface', 'text', 'accent', 'state-failed'] as const;

function readAll(names: readonly string[]) {
  return (page: import('@playwright/test').Page) =>
    page.evaluate((tokenNames: readonly string[]) => {
      const computed = getComputedStyle(document.documentElement);
      return Object.fromEntries(
        tokenNames.map((name) => [name, computed.getPropertyValue(`--gl-${name}`).trim()]),
      );
    }, names);
}

test.describe('design tokens resolve at runtime', () => {
  test('light — the default theme, every token', async ({ page }) => {
    await page.goto('/');

    const values = await readAll(TOKENS)(page);

    for (const name of TOKENS) {
      expect(values[name], `--gl-${name} did not resolve under :root`).not.toBe('');
    }
  });

  test('dark — every token, and the roles actually change', async ({ page }) => {
    await page.goto('/');

    const light = await readAll(THEMED)(page);

    await page.evaluate(() => document.documentElement.setAttribute('data-theme', 'dark'));

    const values = await readAll(TOKENS)(page);

    for (const name of TOKENS) {
      expect(
        values[name],
        `--gl-${name} did not resolve under :root[data-theme="dark"]`,
      ).not.toBe('');
    }

    // Without this loop the assertions above pass under a typo'd attribute —
    // every token inherits from :root and stays non-empty. This is the only
    // part of the dark half that is capable of failing.
    for (const name of THEMED) {
      expect(
        values[name],
        `--gl-${name} is identical in both themes — the dark block did not apply`,
      ).not.toBe(light[name]);
    }
  });

  // main.tsx imports two stylesheets, and every assertion above would still
  // pass if only tokens.css had arrived. These are computed values that only
  // base.css can produce: with it missing, max-width is `none` and
  // font-variant-numeric is `normal`.
  test('base.css loaded — its primitives compute', async ({ page }) => {
    await page.goto('/');

    const measured = await page.evaluate(() => {
      const probe = document.createElement('div');
      probe.className = 'gl-container gl-nums';
      document.body.append(probe);

      const style = getComputedStyle(probe);
      const result = {
        maxWidth: style.maxWidth,
        numerics: style.fontVariantNumeric,
        // The token the cap is written against, for comparison — asserting a
        // literal 1200px here would be a second copy of a design value.
        cap: getComputedStyle(document.documentElement).getPropertyValue('--gl-max-width').trim(),
      };

      probe.remove();
      return result;
    });

    expect(measured.maxWidth, '.gl-container did not cap at --gl-max-width').toBe(measured.cap);
    expect(measured.numerics, '.gl-nums did not request tabular figures').toBe('tabular-nums');
  });
});

// The three §6 breakpoints are declared as `@custom-media`, which Lightning CSS
// treats as a draft: without `css.lightningcss.drafts.customMedia` in
// vite.config.ts it emits a *warning*, the build stays green, and the
// declarations ship to dist/ verbatim while any `@media (--gl-bp-md)` written
// against them matches nothing, forever, with nothing red. D9 — no editable
// canvas below 900px, marked do not reopen — would be silently un-enforced.
//
// So the flag is not trusted, it is checked, against the stylesheet the preview
// actually serves. Removing that line from vite.config.ts turns this red: the
// build emits the three declarations into dist/ unresolved.
test('the breakpoints compile — nothing unresolved reaches dist/', async ({ page }) => {
  await page.goto('/');

  const href = await page.locator('link[rel="stylesheet"]').first().getAttribute('href');
  expect(href, 'the built page serves no stylesheet').not.toBeNull();

  const css = await (await page.request.get(href!)).text();

  expect(css, '@custom-media shipped undigested — the customMedia draft is off').not.toContain(
    '@custom-media',
  );
  expect(css, 'a @media (--gl-bp-*) query shipped unresolved and will never match').not.toContain(
    '@media (--gl-bp-',
  );
});
