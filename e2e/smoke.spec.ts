import { expect, test } from '@playwright/test';

// Three separate header configurations carry COOP/COEP — vite.config.ts's
// server and preview blocks, and vercel.json for production. This asserts the
// one the built preview serves, which is the one CI exercises.
test('the shell mounts and the page is cross-origin isolated', async ({ page }) => {
  await page.goto('/');

  await expect(page.locator('#app')).toBeAttached();
  expect(await page.evaluate(() => crossOriginIsolated)).toBe(true);
});
