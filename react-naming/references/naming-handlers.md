# Naming Event Handlers: `handle*` vs `on*`

The single most-confused convention in React: the same event has two names depending on **which side of the prop you are on**.

## The rule

- **`onXxx`** (PascalCase, capital O) is the **prop name** the parent passes to the child.
- **`handleXxx`** (camelCase, capital H) is the **internal function** the child defines to react to that prop.

The parent's prop wiring IS the local handler:

```jsx
// Parent (App.jsx)
<Player onSelect={(p) => selectPlayer(p)} />      // ← prop name

// Child (Player.jsx)
export default function Player({ onSelect }) {    // ← receives `onSelect`
  function handleSelect() { onSelect(/* ... */); }  // ← internal `handleSelect`
  return <button onClick={handleSelect}>Pick</button>;  // ← native onClick, native handler
}
```

## Examples from the course

| Module | Prop (`on*`) | Internal (`handle*`) |
|---|---|---|
| 03 React Essentials | `onSelect` | `handleSelect` |
| 04 Essentials Deep Dive | `onChange`, `onClick` | `handleChange`, `handleEditClick` |
| 06 Debugging | `onChange` | `handleChange` |
| 17 Forms | `onSubmit`, `onBlur` | `handleSubmit`, `handleEmailBlur` |

## Why the convention exists

- The `on*` prop is **the API of the component** (what the parent can subscribe to). It is part of the public surface.
- The `handle*` function is **the internal glue** between that prop and the side effects. It is private.
- When you see `onClick` in a JSX prop, you know it is something the parent passed (or a native DOM event). When you see `handleClick` in a function body, you know it is local logic.

## Common mistakes

| ❌ Wrong | Why | ✅ Right |
|---|---|---|
| `<button onClick={clickHandler}>` | mixing the two styles | `<button onClick={handleClick}>` |
| `function onClick() { ... }` | function names mirror prop names | `function handleClick() { ... }` |
| `onClick={onClickHandler}` | double prefix | `onClick={handleClick}` |
| `<Player onClick={...} />` | wrong prop name | `<Player onSelect={...} />` (semantic, not just `onClick`) |

## Naming the prop to match the domain

Don't reuse `onClick` for everything. The prop name should describe the **event in the child's domain**:

| Component | Prop | Meaning |
|---|---|---|
| `Player` | `onSelect` | "this player was picked" |
| `TabButton` | `onSelect` | "this tab was activated" |
| `DeleteConfirmation` | `onConfirm` / `onCancel` | "user confirmed / cancelled deletion" |
| `Modal` | `onClose` | "user wants to close" |
| `Form` | `onSubmit` | "form was submitted" |

This is the same rule as native DOM events (`onClick`, `onChange`, `onSubmit`) — extend it to your domain.

## When there is no parent prop

For the **root component** of a feature (e.g. `App.jsx`), the handlers are just `handle*` — there is no incoming prop. The naming still applies: `function handleSelectPlayer(player) { ... }`.
