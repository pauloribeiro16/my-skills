# Naming Files and Folders

Conventions for the project tree outside of components and hooks. Covers utility modules, data files, CSS, assets, and folder names.

## File extensions

| What | Extension |
|---|---|
| React components (JS) | `.jsx` |
| React components (TS) | `.tsx` |
| Hooks | `.js` / `.ts` |
| Lib / util / pure functions | `.js` / `.ts` |
| Global styles | `.css` |
| Component-scoped styles | `<Component>.module.css` |
| Type definitions | `.d.ts` |
| Tests | `*.test.js` / `*.test.jsx` (module 28) |

**Never** `.jsx` for a non-component (no JSX in the file) and **never** `.js` for a file that returns JSX.

## Folders (kebab-case, plural)

The Maximilian course consistently uses **plural folder names**:

| Folder | What goes here |
|---|---|
| `src/components/` | All reusable components (PascalCase filenames) |
| `src/hooks/` | Custom hooks (`use*.js`) |
| `src/util/` (or `src/lib/`) | Pure helpers, no React |
| `src/assets/` | Images, fonts, static media |
| `src/pages/` (module 21+) | Route views |
| `src/store/` (module 29) | Redux / Context providers |
| `src/models/` (module 29) | TypeScript types / classes |
| `src/data/` | Hard-coded data (e.g. `data.js`) |
| `public/` (Vite-less / CRA) | Static assets served at root |

**Pick one of `util/` or `lib/` and stay with it.** The course uses `util/` in modules 06, 17, 22.

## Filenames inside `src/`

| Kind | Pattern | Example |
|---|---|---|
| Component | `PascalCase.jsx` | `TabButton.jsx` |
| Hook | `camelCase, use*` | `useFetch.js` |
| Util / pure function | `camelCase, verb-led` | `formatDate.js`, `validateEmail.js`, `http.js` |
| Module of constants | `camelCase, plural or domain` | `data.js`, `winning-combinations.js` |
| Page | `PascalCase.js` | `EventsRoot.js`, `EventDetail.js` |
| Model / type | `camelCase, singular` | `todo.ts` |
| Test | co-located `*.test.js` | `Greeting.test.js` |
| CSS module | `<Component>.module.css` | `Header.module.css` |
| Global CSS | `index.css` | `src/index.css` |

## Singular vs plural

| Plural | Singular |
|---|---|
| `components/`, `hooks/`, `assets/`, `pages/` (collections of files) | `data/` (a single domain of constants) |
| Folder = "a bucket of Xs" | Folder = "the X" |

Don't be inconsistent: if `components/` is plural, `hooks/` should be too. Don't write `component/` or `hook/`.

## `index.js` vs `main.jsx`

The course uses both interchangeably:

- Vite default: `src/main.jsx`
- Course custom: `src/index.jsx`
- CRA: `src/index.js` (older)

**Pick one per project, document in the workspace AGENTS.md, and don't change mid-project.**

## `App.jsx` placement

`App.jsx` lives at `src/App.jsx` — not inside `src/components/`. It is the root component, and putting it in `components/` makes the project feel like a library.

## Re-export barrels (avoid)

The course does **not** use `index.js` re-export files (`export { Player } from './Player'`). Import directly:

```js
// ✅ direct import
import Player from './components/Player.jsx';
// ❌ barrel import (not in the course)
import { Player } from './components/';
```

This keeps grep/refactor tools honest — every consumer of `Player` shows up in `grep` results.
