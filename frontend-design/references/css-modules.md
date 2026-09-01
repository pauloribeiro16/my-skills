# CSS Modules per component

One `<Component>.module.css` per component, imported as `classes` and
applied via `className={classes.<token>}`. This is the pattern the
course adopts from module 07 onwards (replacing the single global
`src/index.css` of the module 03 starter).

Copied from the Maximilian Schwarzmüller course, module 07,
05-styled-cmp-creating-reusable-cmp.

## Good — from the course

```css
/* File: src/components/Header.module.css */
/* Source: m07, 05-styled-cmp-creating-reusable-cmp */
.header { display: flex; flex-direction: column; align-items: center; }
.header img { object-fit: contain; width: 11rem; height: 11rem; }
.paragraph { text-align: center; color: #a39191; margin: 0; }
```

```jsx
// File: src/components/Header.jsx
import classes from './Header.module.css';

export default function Header() {
  return (
    <header className={classes.header}>
      <p className={classes.paragraph}>A community of artists.</p>
    </header>
  );
}
```

## Bad — global classnames that collide

```css
/* ❌ File: src/components/Header.css (no .module) */
.header { ... }
.paragraph { ... }
```

```jsx
// File: src/components/Header.jsx
import './Header.css';
export default function Header() {
  return (
    <header className="header">
      <p className="paragraph">A community of artists.</p>
    </header>
  );
}
```

Without `.module.css`, the class name `header` is **global** and collides
with any other component that happens to use `class="header"`. CSS
Modules scope the class to the file.

## Picking the right option

| Use | When |
|---|---|
| One global `src/index.css` (m03) | Starter, single-page demo, no component reuse |
| `<Name>.module.css` per component (m07+) | 3+ components, or where components are reused |

Pick **one** per project and stay consistent.

See: `react-naming/references/structure-essentials.md`.
