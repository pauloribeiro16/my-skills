# Component filename

File: `src/components/Header.jsx`, `src/components/TabButton.jsx`. File
name = component name. PascalCase, no suffix (`Header.jsx`, never
`HeaderComponent.jsx`).

Copied from the Maximilian Schwarzmüller course, modules 03, 04, 06.

## Good — from the course

```jsx
// File: src/components/Header.jsx
// Source: m03, 07-storing-cmp-in-files
import reactImg from '../assets/react-core-concepts.png';

export default function Header() {
  return (
    <header>
      <img src={reactImg} alt="Stylized atom" />
      <h1>React Essentials</h1>
    </header>
  );
}
```

```jsx
// File: src/components/TabButton.jsx
// Source: m03, 18-outputting-list-data
export default function TabButton({ children, onSelect, isSelected }) {
  return (
    <li>
      <button className={isSelected ? 'active' : undefined} onClick={onSelect}>
        {children}
      </button>
    </li>
  );
}
```

## Bad — not in the course

```jsx
// ❌ kebab in filename, or filename ≠ export
// File: src/components/header.jsx
export default function SiteHeader() { ... }   // filename ≠ export
// File: src/components/tab-button.jsx
export default function TabButton() { ... }    // same problem
// File: src/components/HeaderComponent.jsx    // redundant "Component" suffix
export default function Header() { ... }
```

## Why

The course uses the file as a stable identifier. `Header.jsx` makes
`grep -r "Header"` show every consumer (because they import the default
export by name) and every file. A `header.jsx` filename that exports
`SiteHeader` breaks both searches.

See: `react-naming/references/naming-components.md`.
