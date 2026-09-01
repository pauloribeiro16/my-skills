# Project Structure — Essentials (modules 03-07)

The structure used by the Vite + React 19 starter and the early projects of the course. Simple, no routing, no state library yet.

## Tree

```
<project>/
├── AGENTS.md
├── package.json
├── index.html             # <div id="root"></div>
├── vite.config.js
├── src/
│   ├── index.jsx          # entry — renders <App /> to #root
│   ├── index.css          # global stylesheet (imported by index.jsx)
│   ├── App.jsx            # root component
│   ├── components/        # one file per component, PascalCase
│   │   ├── Header.jsx
│   │   ├── TabButton.jsx
│   │   └── ...
│   ├── hooks/             # one hook per file, use* (modules 16+)
│   ├── util/              # pure helpers, no React
│   │   └── investment.js  # module 06 example
│   └── assets/            # images, fonts
│       └── react-core-concepts.png
```

## When to add each folder

| Folder | Add when… |
|---|---|
| `components/` | from day one (module 03) |
| `assets/` | from day one (the starter has 4 PNGs) |
| `util/` | first time you extract a pure function out of a component (module 06) |
| `hooks/` | first custom hook (module 16) |
| `pages/` | first route (module 21) |
| `store/` | first Context or Redux slice (module 29) |
| `models/` | first TS interface or class (module 29) |

## CSS placement

Two options the course actually uses:

**Option A — one global stylesheet (module 03 starter):**
```css
/* src/index.css */
button { ... }
.header { ... }
```

**Option B — CSS Modules per component (module 07, 21, 29):**
```css
/* src/components/Header.module.css */
.header { ... }
```
```jsx
import classes from './Header.module.css';
<header className={classes.header}>...</header>
```

**Pick one per project.** Module 03 starts with A; module 07 introduces B; modules 21+ use B exclusively. Don't mix within one project.

## Module 06 example — extracting logic to `util/`

`src/util/investment.js`:
```js
export function calculateInvestmentResults({ initialInvestment, annualInvestment, expectedReturn, duration }) {
  const annualData = [];
  let investmentValue = initialInvestment;
  for (let i = 0; i < duration; i++) {
    const interestEarnedInYear = investmentValue * (expectedReturn / 100);
    investmentValue += interestEarnedInYear + annualInvestment;
    annualData.push({ year: i + 1, interest: interestEarnedInYear, valueEndOfYear: investmentValue, annualInvestment });
  }
  return annualData;
}
```

`src/components/Results.jsx` then imports it:
```js
import { calculateInvestmentResults } from '../util/investment.js';
```

Note the **explicit `.js` extension** in the import — Vite requires it on bare relative paths. This is a course-wide convention.

## Don't

- Don't create a `src/lib/` AND `src/util/` — pick one.
- Don't put `App.jsx` inside `src/components/`.
- Don't use barrel files (`components/index.js`).
- Don't split a single component across multiple files unless it is genuinely large (>300 lines).
