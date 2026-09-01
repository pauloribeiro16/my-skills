---
name: react-naming
description: "Reference for naming and folder structure in React/TypeScript projects. Distilled from the Maximilian Schwarzmüller React course (modules 02-29). Use when naming a new component, hook, handler, lib function, or organising src/. Trigger phrases: name this component, what should I call this hook, handle vs on, where do I put, src structure, react conventions."
---

Single source of truth for React naming and folder structure in this workspace. Distilled from the Maximilian Schwarzmüller React course (modules 02-29). **Progressive disclosure**: this file carries the routing table and the headline rules; details live in `references/` and load on demand.

## When to Use

- Naming a new component, hook, handler prop, or lib function.
- Deciding where a file lives in `src/` (components, hooks, util, store, pages…).
- Choosing between `handle*` and `on*` for an event handler.
- Picking an extension (`.js` vs `.jsx` vs `.ts` vs `.tsx`).
- Reviewing whether a new file's name matches the project's existing pattern.

## When NOT to Use

- Generic code style (indentation, quotes) → AGENTS.md §5 in the workspace.
- General architecture (refactoring, deep modules) → `codebase-architecture`.
- Build/test/lint commands → workspace AGENTS.md §4 / §6.
- Aesthetic/design choices → `frontend-design`.

## Hard Rules

1. **Component file = component name** (`Header.jsx` exports `Header`). One file per component, PascalCase, in `src/components/`.
2. **Event props are `onXxx`** (PascalCase, capital O): `onClick`, `onChange`, `onSubmit`, `onSelect`, `onBlur`.
3. **Internal handlers are `handleXxx`** (camelCase): `handleClick`, `handleSubmit`, `handleEmailBlur`. The parent's `on*` prop is wired to the local `handle*` function.
4. **Custom hooks start with `use`** and live in `src/hooks/`. One hook per file, file name = hook name (`useFetch.js`).
5. **Lib/helpers are verbs or actions in camelCase**: `formatDate.js`, `validateEmail.js`, `http.js`. They live in `src/util/` (or `src/lib/` — pick one per project and stay consistent).
6. **Vite + React 19 (modules 03-17): `.jsx` for components, `.js` for everything else.** Entry is `src/main.jsx` or `src/index.jsx`.
7. **CSS lives next to the component** in `src/components/<Name>.module.css` (CSS Modules, modules 07/21/29) OR in a single global `src/index.css` (module 03 starter). Pick one per project.
8. **TypeScript modules (29): `.tsx` for components, `.ts` for everything else, types in `src/models/<entity>.ts`.**

## Routing table

Load the matching reference before writing a name. Each reference is short and self-contained.

| If you are… | Read first… |
|---|---|
| Naming a new component | `references/naming-components.md` |
| Naming a custom hook | `references/naming-hooks.md` |
| Picking `handle*` vs `on*` for an event | `references/naming-handlers.md` |
| Choosing a filename / folder name | `references/naming-files-folders.md` |
| Organising `src/` for an Essentials project (modules 3-7) | `references/structure-essentials.md` |
| Adding global state (Redux/Context) | `references/structure-state.md` |
| Adding routing (module 21) | `references/structure-routing.md` |
| Adding tests (module 28) | `references/structure-testing.md` |
| Starting a TypeScript project (module 29) | `references/structure-typescript.md` |
| Wanting the full project skeleton (one-glance tree) | `references/project-skeleton.md` |

## Module map (where each pattern is established)

| Module | Pattern it introduces |
|---|---|
| 02 JS Refresher | Plain JS, no bundler, no React yet |
| 03 React Essentials | Vite + `.jsx` + `src/components/` + one global `index.css` |
| 04 Essentials Deep Dive | `public/` folder, props forwarding, two-way binding |
| 05 Essentials Practice | Same as 04, polished |
| 06 Debugging | `src/util/<domain>.js` for pure logic |
| 07 Styling | CSS Modules per-component (`<Name>.module.css`) |
| 15 HTTP Requests | `src/http.js` for fetch wrapper |
| 16 Custom Hooks | `src/hooks/use<Name>.js` |
| 17 Forms User Input | `src/util/validation.js` + custom input hook |
| 21 Routing | `src/pages/<Route>.js` + per-page components |
| 22 Authentication | Same as 21 + `src/util/auth.js` |
| 28 Testing | `src/components/<Name>.test.js` co-located |
| 29 React TypeScript | `.tsx` + `src/models/<entity>.ts` + `src/store/` |

## Examples

```jsx
// Component — file = component name, PascalCase
// File: src/components/Player.jsx
export default function Player({ name, onSelect, isActive }) { ... }
```

```jsx
// Custom hook — use* prefix, src/hooks/
// File: src/hooks/useFetch.js
export default function useFetch(url) { ... }
```

```jsx
// Event prop = on* (parent → child); internal handler = handle* (child internal)
<button onClick={handleClick}>...</button>          // in Header.jsx
<Player onSelect={(p) => selectPlayer(p)} />        // in App.jsx
function handleClick() { /* internal */ }
```

## Anti-patterns (from the course)

Three recurring mistakes the Maximilian course flags explicitly. Each one
becomes a runtime error or silent no-op — load `web-debug` if you hit the
symptom.

### Setting state directly (m03, 14-managing-state)

```jsx
// ❌ Assignment doesn't trigger a re-render
let count = 0;
count = 5;                  // React doesn't notice the change
```

```jsx
// ✅
const [count, setCount] = useState(0);
setCount(5);                // triggers a re-render
```

### Mutating then setting (m04, 12-updating-state-immutably)

```jsx
// ❌ Same reference → React skips the update
const next = current;
next.push(newItem);
setItems(next);             // React sees the same array
```

```jsx
// ✅
setItems([...current, newItem]);   // new reference, new identity
```

If the runtime check fails: load `web-debug` for the React error patterns.

### Input sem onChange (m04, 10-two-way-binding)

```jsx
// ❌ Read-only field; React warns "value without onChange"
<input value={playerName} />
```

```jsx
// ✅
<input
  value={playerName}
  onChange={(e) => setPlayerName(e.target.value)}
/>
```

If the warning fires: load `web-debug` for the React-specific debugging checklist.

## Best Practices

- **Name by concept, not by type.** `Player.jsx` (what) beats `PlayerComponent.jsx` (redundant suffix).
- **Domain prefix for hooks of the same shape:** `useFetchUser`, `useFetchPlaces` — the domain comes first.
- **One concern per file.** Split a hook that does both fetching and caching into two files.
- **Don't change established names across modules.** If a hook is `useFetch` in module 16, keep it `useFetch` in module 21.
