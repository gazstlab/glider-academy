import react from '@vitejs/plugin-react';
import { defineConfig } from 'vite';

// Pyodide needs SharedArrayBuffer, which needs `crossOriginIsolated`, which
// needs both of these headers on every response. Production is vercel.json's
// job; dev and the Playwright preview each need their own copy, and neither
// inherits from the other.
const crossOriginIsolation = {
  'Cross-Origin-Opener-Policy': 'same-origin',
  'Cross-Origin-Embedder-Policy': 'require-corp',
};

export default defineConfig({
  plugins: [react()],

  // Empty on purpose: S16 (Pyodide) and S24 fill these in. The blocks exist
  // now so neither spec has to decide the shape of the file it is editing.
  worker: {},
  optimizeDeps: {},

  // src/styles/base.css declares the three §6 breakpoints as `@custom-media`.
  // Lightning CSS — which Vite 8 uses to minify — treats that at-rule as a
  // draft and, without this flag, only *warns* and passes it through: the build
  // stays green and `@media (--gl-bp-md)` ships to dist/ matching nothing.
  // D9 (no editable canvas below 900px) would be silently un-enforced.
  css: { lightningcss: { drafts: { customMedia: true } } },

  server: { headers: { ...crossOriginIsolation } },
  preview: { headers: { ...crossOriginIsolation } },
});
