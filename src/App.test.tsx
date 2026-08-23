import { cleanup, render } from '@testing-library/react';
import { afterEach, expect, test } from 'vitest';

import App from './App';

// No setup file and no jest-dom: neither is in this spec's fence, so the
// assertions below are bare vitest matchers.
afterEach(cleanup);

test('App renders the main landmark the shell mounts into', () => {
  const { getByRole } = render(<App />);

  expect(getByRole('main').id).toBe('app');
});
