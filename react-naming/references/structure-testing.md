# Project Structure — Testing (module 28)

The course uses **Vitest** (in the Vite-style starter) and **React Testing Library**. Tests are **co-located** with the file they test, named `*.test.js(x)`.

## Tree (module 28, Vite variant)

```
<project>/
├── package.json
├── vite.config.js
├── vitest.config.js       # OR configured in vite.config.js
├── src/
│   ├── setupTests.js      # runs before every test (registers @testing-library/jest-dom)
│   ├── index.js
│   ├── index.css
│   ├── App.js
│   └── components/
│       ├── Greeting.js
│       ├── Greeting.test.js      # ← co-located
│       ├── Async.js
│       ├── Async.test.js
│       ├── Output.js
│       └── ...
```

> Module 28 has both `01-starting-project` (CRA + Jest) and `01-starting-project-vite` (Vite + Vitest). The naming convention is identical — only the runner changes.

## File naming

| Tested file | Test file |
|---|---|
| `Greeting.js` | `Greeting.test.js` |
| `Player.jsx` | `Player.test.jsx` |
| `useFetch.js` | `useFetch.test.js` (custom hook test) |

**Co-located**, not in a separate `__tests__/` folder. This keeps related files next to each other in the editor.

## `setupTests.js`

A single global setup file is referenced from `vitest.config.js`:

```js
// File: src/setupTests.js
import '@testing-library/jest-dom/vitest';
```

This registers the `toBeInTheDocument()` matcher globally so every test file can use it without importing.

## What to test, what not to

| ✅ Test | ❌ Don't test |
|---|---|
| Conditional rendering (does X show when state is Y?) | Implementation details (state variable names) |
| Event handling (does the callback fire when I click?) | Styles (use snapshot tests only if you must) |
| Async flows (does data load and render?) | Third-party libraries (they have their own tests) |
| Custom hooks (useFetch returns data after success) | Private helper functions (test via the public API) |

## Imports in tests

```js
import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import Greeting from './Greeting';
```

No need to import from `vitest` for the basic matchers — `@testing-library/jest-dom` adds the DOM ones, and Vitest exposes `describe/it/expect` globally when `globals: true` in the config.

## When tests need fixtures

Co-located test fixtures go next to the test:

```
components/
├── Greeting.js
├── Greeting.test.js
└── Greeting.fixtures.js   # only if Greeting.test.js is too crowded
```

Don't share fixtures across modules in a `__fixtures__/` folder — that re-creates the cross-cutting coupling tests are supposed to avoid.
