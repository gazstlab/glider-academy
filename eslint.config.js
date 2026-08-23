import reactHooks from 'eslint-plugin-react-hooks';
import tseslint from 'typescript-eslint';

export default tseslint.config(
  {
    ignores: ['dist/**', 'node_modules/**', 'playwright-report/**', 'test-results/**'],
  },
  tseslint.configs.recommended,
  {
    files: ['**/*.{ts,tsx}'],
    // `configs.flat` is the flat-config namespace; the top-level
    // `configs['recommended-latest']` is still eslintrc-shaped and ESLint 10
    // rejects it outright.
    ...reactHooks.configs.flat['recommended-latest'],
  },
);
