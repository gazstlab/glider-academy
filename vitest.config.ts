import react from '@vitejs/plugin-react';
import { defineConfig } from 'vitest/config';

export default defineConfig({
  plugins: [react()],
  test: {
    environment: 'jsdom',
    include: ['src/**/*.{test,spec}.{ts,tsx}'],
    // Vitest's default include matches `**/*.spec.ts`, which collects
    // e2e/smoke.spec.ts, imports @playwright/test outside a Playwright runner
    // and fails for a reason nothing in the file explains. Excluded twice —
    // by include and by exclude — so neither edit alone reopens it.
    exclude: ['e2e/**', 'node_modules/**', 'dist/**'],
  },
});
