# Naming Components

A component is a function that returns JSX. Naming covers the **filename**, the **export**, the **function name**, and the **props it receives**.

## File name

- `PascalCase`, **no suffix** (`Header.jsx`, not `HeaderComponent.jsx`).
- File name = function name = export default name.
- One component per file (single default export).
- Extension matches language: `.jsx` for JavaScript, `.tsx` for TypeScript.

| ✅ Good | ❌ Avoid |
|---|---|
| `Header.jsx` | `header.jsx` |
| `TabButton.jsx` | `tabButton.jsx`, `tab-button.jsx` |
| `AvailablePlaces.jsx` | `AvailablePlacesComponent.jsx`, `AvailablePlaces.js` |
| `UserInput.jsx` | `UserInputCmp.jsx` |

## Function name and export

```jsx
// File: src/components/Player.jsx
export default function Player({ name, symbol, isActive, onSelect }) {
  return (
    <li>
      <button onClick={() => onSelect()}>{name}</button>
    </li>
  );
}
```

Default export only — no named exports for the component itself. Internal helpers stay in the same file but are not exported.

## When the component name needs a qualifier

If two components in the same file would share a root word, **split the file**. Don't append `-Form`, `-Modal`, `-Card` as a suffix unless the qualifier is a separate concept:

| ✅ Good | ❌ Avoid |
|---|---|
| `Login.jsx`, `Signup.jsx` (two files) | `AuthForms.jsx` containing both |
| `AvailablePlaces.jsx`, `DeleteConfirmation.jsx` | `Modal.jsx` with branched props |

## Container / wrapper components

- `Page` or `Layout` for top-level route views (module 21: `src/pages/Root.js`, `EventsRoot.js`).
- `MainNavigation`, `EventsNavigation` for navigation chrome.
- Avoid generic names (`Wrapper`, `Container`) — name by what it wraps.

## Component names that are React-internal

| Pattern | When |
|---|---|
| `ErrorBoundary` | Top-level fallback (module 29 patterns) |
| `Root`, `EventsRoot` | Route layout wrapper (module 21) |
| `NewEvent`, `EditEvent` | Page views; verb-prefix is fine for actions |
| `Results`, `Header`, `Footer` | Pure presentational; name by what is rendered |

## JSX self-naming

In JSX, the component name **must start with a capital** to be recognised as a component, not a DOM tag:

```jsx
<Player />        // ✅ recognised as React component
<player />        // ❌ treated as <player> HTML tag
<header />        // lowercase: native HTML tag
<Header />        // uppercase: your component
```
