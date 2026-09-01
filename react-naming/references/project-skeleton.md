# Project Skeleton — one-glance tree

The full structure once the course has introduced everything. Use this when starting a project from scratch and you want to scaffold all the folders at once.

```
<project>/
├── AGENTS.md                       # project-specific
├── package.json
├── index.html
├── tsconfig.json                   # only if TypeScript (module 29)
├── vite.config.js                  # only if Vite
├── vitest.config.js                # only if tests (module 28)
├── public/                         # only if CRA-style (modules 21, 22, 28, 29)
│   ├── index.html
│   ├── favicon.ico
│   └── manifest.json
├── src/
│   ├── index.jsx / index.tsx       # entry — renders <App /> to #root
│   ├── index.css                   # global stylesheet
│   ├── App.jsx / App.tsx           # root component
│   ├── components/                 # one file per component, PascalCase
│   │   ├── Header.jsx
│   │   ├── MainNavigation.jsx
│   │   └── ...
│   ├── hooks/                      # one hook per file, use*
│   │   ├── useFetch.js
│   │   └── useInput.js
│   ├── util/                       # pure helpers (or `lib/` — pick one)
│   │   ├── http.js
│   │   ├── validation.js
│   │   └── format.js
│   ├── pages/                      # route views (module 21+)
│   │   ├── Root.jsx
│   │   ├── Home.jsx
│   │   └── Error.jsx
│   ├── store/                      # Context or Redux (modules 19, 29)
│   │   └── todos-context.tsx
│   ├── models/                     # TS types/classes (module 29)
│   │   └── todo.ts
│   ├── data/                       # static constants
│   │   └── data.js
│   ├── assets/                     # images, fonts
│   └── setupTests.js               # only if Vitest (module 28)
```

## What to create on day one

For a fresh project matching the course's Vite + React starter:

```bash
mkdir -p src/components src/hooks src/util src/assets
touch src/index.jsx src/index.css src/App.jsx
```

For a Vite + TS project (module 29), also:

```bash
mkdir -p src/store src/models
touch src/react-app-env.d.ts
```

For a project with routing (module 21), also:

```bash
mkdir -p src/pages
```

For a project with tests (module 28), also:

```bash
touch src/setupTests.js
```

## Folder growth checklist

When you find yourself about to write:

| You are about to… | Create |
|---|---|
| Add a fifth component | `src/components/` (you should have had this from day 1) |
| Write a `fetch()` call inside a component | `src/util/http.js` |
| Duplicate a hook logic | Extract to `src/hooks/use<Name>.js` |
| Add a route | `src/pages/<Route>.jsx` and update the router |
| Add Context | `src/store/<domain>-context.tsx` |
| Define a TS class | `src/models/<entity>.ts` |
| Add a constant | `src/data/<domain>.js` (or co-locate if single-use) |
| Add a test | Co-locate as `<Name>.test.js` next to the file |
| Add CSS for one component | `src/components/<Name>.module.css` (or add to global `index.css`) |

## What NOT to create

- `src/constants/` — use `src/data/` or co-locate.
- `src/types/` — use `src/models/`.
- `src/services/` — use `src/util/http.js` (or split into `api/`, `auth/` etc. only if the surface is large).
- `src/common/` — vague; name by concern.
- `src/shared/` — same.
- `src/misc/`, `src/utils/`, `src/helpers/` — pick `util/` (singular) and commit.

## Course progression at a glance

| Module | Adds |
|---|---|
| 02 | (no React yet) |
| 03 | `components/`, `assets/` |
| 04 | `public/` (when on CRA) |
| 06 | `util/` |
| 07 | CSS Modules per component |
| 15 | `src/http.js` (fetch wrapper) |
| 16 | `hooks/` |
| 17 | `util/validation.js` + form input hook |
| 19-20 | `store/` (Redux) |
| 21 | `pages/` |
| 28 | `setupTests.js` + co-located `*.test.js` |
| 29 | `models/` + `store/` (Context) + `.tsx`/`.ts` |
