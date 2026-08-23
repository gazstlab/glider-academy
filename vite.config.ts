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

  server: { headers: { ...crossOriginIsolation } },
  preview: { headers: { ...crossOriginIsolation } },
});
