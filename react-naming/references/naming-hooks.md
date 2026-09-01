# Naming Custom Hooks

A custom hook is a function that calls other hooks. Naming covers the **filename**, the **function name**, the **prefix**, and the **domain**.

## File name

- `<domainOrConcept>.js` starting with `use` (camelCase, lowercase first).
- File name = function name (default export).
- One hook per file.
- Lives in `src/hooks/`.

| ✅ Good | ❌ Avoid |
|---|---|
| `useFetch.js` | `use-fetch.js`, `UseFetch.js`, `useFetchHook.js` |
| `useInput.js` | `useInputForm.js` (redundant `Form`) |
| `useHttp.js` | `http.js` (no `use` prefix) |

## Function name and export

```js
// File: src/hooks/useFetch.js
export default function useFetch(url) {
  const [data, setData] = useState(null);
  // ...
  return { data };
}
```

Default export. If the hook file also exports small helpers, those are named exports — but the hook itself is the default.

## Domain prefix

When you have two hooks of the same shape over different domains, **prefix with the domain** so they are easy to scan alphabetically:

| Hook | Domain |
|---|---|
| `useFetchUser` | a single user |
| `useFetchPlaces` | a list of places |
| `useHttp` | generic HTTP wrapper (no specific resource) |

The Maximilian course uses `useFetch` for the generic HTTP wrapper (module 16) and `useInput` for the form helper (module 17). Use those exact names when you build the same thing.

## Hooks that return JSX

Avoid. A custom hook returns **state and/or callbacks**. If you find yourself returning JSX, you are building a component — make a `*.jsx` file instead.

| ❌ Wrong | ✅ Right |
|---|---|
| `useCard()` returns `<Card />` | `Card.jsx` component |
| `useFormLayout()` returns JSX | `FormLayout.jsx` component |

## When a hook needs sub-hooks

If a hook grows internal helpers, name them with the same `use*` prefix when they themselves call hooks; otherwise use plain camelCase functions:

```js
// File: src/hooks/useFetch.js
export default function useFetch(url) {
  // internal helper — not a hook, no `use` prefix
  function buildRequestOptions() { ... }
  // sub-hook — calls useState, needs the prefix
  function useLocalCache(key) { ... }
}
```

But the helper is not exported and never used outside the file, so this is fine.

## Hooks and the `tmp/` rule

A throwaway hook you write to test an idea (e.g. `useThing.js`) goes in `tmp/`, not in `src/hooks/`. The hook is not a deliverable until it has a real consumer.
