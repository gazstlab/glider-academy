import { StrictMode } from 'react';
import { createRoot } from 'react-dom/client';

import App from './App';
// Tokens first, then everything written against them. Order is the cascade:
// equal-specificity declarations are settled by the later import, so the file
// that defines the values has to be the first one in.
import './tokens';
import './styles/base.css';

createRoot(document.getElementById('root')!).render(
  <StrictMode>
    <App />
  </StrictMode>,
);
