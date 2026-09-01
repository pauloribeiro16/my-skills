# No barrel files

The course never uses `components/index.js` re-exports. Import directly
from the file.

Copied from the Maximilian Schwarzmüller course, modules 03, 04.

## Good — from the course

```jsx
// File: src/App.jsx
// Source: m03, 07-storing-cmp-in-files
import Header from './components/Header.jsx';
import CoreConcept from './components/CoreConcept.jsx';

function App() {
  return (
    <div>
      <Header />
      <CoreConcept
        title={CORE_CONCEPTS[0].title}
        description={CORE_CONCEPTS[0].description}
        image={CORE_CONCEPTS[0].image}
      />
    </div>
  );
}
```

The imports declare the path to the file. No `components/index.js`
intermediary.

## Bad — not in the course

```js
// ❌ File: src/components/index.js (barrel re-export)
export { default as Header } from './Header.jsx';
export { default as CoreConcept } from './CoreConcept.jsx';
```

```jsx
// Then in App.jsx:
import { Header, CoreConcept } from './components/';
```

## Why the course avoids them

- `grep -r "Header"` no longer shows App.jsx as a consumer — the import
  in App.jsx says only `Header` from `'./components/'`, not the file
  path.
- Renaming `Header.jsx` to `SiteHeader.jsx` leaves the import in
  `components/index.js` referencing `./Header.jsx` — a silent stale path
  that only breaks at runtime.
- Barrel files encourage "pull everything from one place", which works
  against the deliberate structure the course builds.

See: `react-naming/references/naming-files-folders.md`.
