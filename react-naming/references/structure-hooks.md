# Project Structure — Custom Hooks (module 16)

Introduced in module 16 and used in modules 17, 22, 29. The course treats custom hooks as **the** mechanism for sharing stateful logic across components.

## Folder

```
src/
└── hooks/
    ├── useFetch.js
    ├── useInput.js
    └── ...
```

One hook per file. File name = hook name. Default export.

## Anatomy of a hook

```js
// File: src/hooks/useFetch.js
import { useState, useEffect } from 'react';

export default function useFetch(fetchFn, initialValue) {
  const [data, setData] = useState(initialValue);
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState(null);

  useEffect(() => {
    async function fetchData() {
      setIsLoading(true);
      try {
        const result = await fetchFn();
        setData(result);
      } catch (err) {
        setError(err);
      } finally {
        setIsLoading(false);
      }
    }
    fetchData();
  }, [fetchFn]);

  return { data, isLoading, error, setData };
}
```

## What a hook can return

- An **object** of state values and setters (most common for fetch-style hooks).
- A **tuple** of values (less common in the course, but fine for simple cases).
- A single **state value** when the hook is a thin wrapper around `useState`.

The course convention is **return an object** when there are 2+ values, so consumers destructure by name.

## When to write a hook

Write a hook when:

1. **Two or more components need the same stateful logic** (e.g. `useFetch` for any data-loading component).
2. **A single component has too much logic in `useEffect`** — extract into a hook to make the component read top-down.
3. **You want to swap the implementation** (e.g. mock `useFetch` in tests).

Don't write a hook when:

- The logic is purely presentational — keep it in the component.
- The hook would only be called from one place — it's not yet a hook, it's a refactor candidate.

## Hooks that wrap form input (module 17)

```js
// File: src/hooks/useInput.js
import { useState } from 'react';

export default function useInput(defaultValue, validationFn) {
  const [value, setValue] = useState(defaultValue);
  const [didEdit, setDidEdit] = useState(false);

  const valueIsValid = validationFn(value);
  const hasError = didEdit && !valueIsValid;

  function handleChange(event) {
    setValue(event.target.value);
    setDidEdit(false);
  }
  function handleBlur() {
    setDidEdit(true);
  }

  return {
    value,
    handleChange,
    handleBlur,
    hasError,
  };
}
```

Returns an object whose keys are the props an `<Input>` component needs. The component then forwards them: `<Input {...inputProps} />`. This is the **module 17 pattern** for generic input handling.

## Naming the file vs the hook

They match. `useFetch.js` exports `useFetch`. The component that uses it is named whatever the user calls it — there is no "Fetch" component. This separation keeps hooks free of UI concerns.
