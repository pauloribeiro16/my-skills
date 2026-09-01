# Project Structure — State Management (Context, Redux)

When the project grows past a few `useState` calls, the course moves state out of components and into either React Context (module 29) or Redux (modules 19-20). This file describes the conventions for **where the state lives** and **how it is named**.

## Context (module 29)

```
src/
├── store/
│   └── todos-context.tsx  # createContext + provider + custom hook
├── models/
│   └── todo.ts            # type/model definitions
└── components/
    ├── Todos.tsx          # consumes the context
    ├── TodoItem.tsx
    └── NewTodo.tsx
```

### The context file shape

```jsx
// File: src/store/todos-context.tsx
import { createContext, useState } from 'react';
import Todo from '../models/todo';

interface TodosContextValue {
  items: Todo[];
  addTodo: (text: string) => void;
  removeTodo: (id: string) => void;
}

export const TodosContext = createContext<TodosContextValue>({ items: [] });

export default function TodosContextProvider({ children }) {
  const [todos, setTodos] = useState([]);
  // ...
  return <TodosContext.Provider value={...}>{children}</TodosContext.Provider>;
}
```

Naming:
- Folder `src/store/`, file `<domain>-context.<ext>`.
- The exported context is `PascalCase` (`TodosContext`).
- The provider component is `PascalCaseProvider` (`TodosContextProvider`) and is the default export.
- Consumers call `useContext(TodosContext)` directly, or import a custom `use<Domain>()` hook from the same file.

## Redux (modules 19-20)

The course uses **classic Redux** with `@reduxjs/toolkit`. Structure (inferred from the resource repo for `19 Redux Basics`):

```
src/
├── store/
│   ├── index.js           # configureStore, exports the root reducer
│   └── <slice>.js         # one file per slice (counter-slice.js, etc.)
└── components/
    └── Counter.js         # uses useSelector / useDispatch
```

Slice naming: `<feature>-slice.js` (`counter-slice.js`, `cart-slice.js`).

## Model / type files (TypeScript, module 29)

```
src/
└── models/
    └── todo.ts
```

```ts
// File: src/models/todo.ts
export default class Todo {
  constructor(public id: string, public text: string) {}
}
```

Naming: singular entity, camelCase (`todo.ts`, `user.ts`, `event.ts`). The file exports the **class** (or interface, or type alias) as the default.

## Constants vs state

If the value never changes after the app boots, it is a **constant** — put it in `src/data/` (module 03) or `src/util/`, **not** in the store. The store is for runtime state only.

| Constant | State |
|---|---|
| `CORE_CONCEPTS` (module 03) | `currentTab` |
| `EXAMPLES` (module 03) | `userInput` (form draft) |
| `WINNING_COMBINATIONS` (module 04) | `activePlayer` (game state) |
