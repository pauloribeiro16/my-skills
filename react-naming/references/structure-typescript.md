# Project Structure — TypeScript (module 29)

Module 29 introduces TypeScript on top of the React foundations. Most conventions carry over; the differences are **extensions** (`.ts`/`.tsx`), **types/models in their own folder**, and **`tsconfig.json`** at the root.

## Tree (module 29 finished)

```
<project>/
├── package.json
├── tsconfig.json
├── public/
│   ├── index.html         # CRA-style
│   ├── favicon.ico
│   ├── logo192.png
│   ├── logo512.png
│   ├── manifest.json
│   └── robots.txt
└── src/
    ├── react-app-env.d.ts  # CRA-specific type for asset imports
    ├── index.tsx
    ├── index.css
    ├── App.tsx
    ├── store/
    │   └── todos-context.tsx
    ├── models/
    │   └── todo.ts
    ├── components/
    │   ├── Todos.tsx
    │   ├── Todos.module.css
    │   ├── TodoItem.tsx
    │   ├── TodoItem.module.css
    │   ├── NewTodo.tsx
    │   └── NewTodo.module.css
    └── assets/
```

## Extensions

| Was (JS) | Now (TS) |
|---|---|
| `Header.jsx` | `Header.tsx` |
| `App.js` | `App.tsx` |
| `index.js` | `index.tsx` |
| `http.js` | `http.ts` |
| `useFetch.js` | `useFetch.ts` |
| `data.js` | `data.ts` |
| `todo.js` (class) | `todo.ts` |

Components: `.tsx`. Everything else: `.ts`. **Never** `.jsx` in a TS project (and never `.tsx` for a non-component).

## Models folder

`src/models/` holds **type definitions, interfaces, and classes** that are not React components:

```ts
// File: src/models/todo.ts
export default class Todo {
  constructor(public id: string, public text: string) {}
}
```

```ts
// File: src/models/event.ts
export interface Event {
  id: string;
  title: string;
  date: string;
  description: string;
}
```

Naming: **singular entity**, camelCase. The file's default export is the class, named export is the interface.

## Props typing

```tsx
// File: src/components/Todos.tsx
import Todo from '../models/todo';

interface TodosProps {
  items: Todo[];
  onAdd: (text: string) => void;
  onDelete: (id: string) => void;
}

export default function Todos({ items, onAdd, onDelete }: TodosProps) {
  // ...
}
```

The `Props` interface lives **at the top of the file** that uses it. Don't extract a shared props type unless it is used by 2+ files — at which point promote it to `src/models/`.

## State typing

```tsx
const [todos, setTodos] = useState<Todo[]>([]);           // explicit generic
const [filter, setFilter] = useState<'all' | 'done'>('all'); // union type
```

Use the generic form `<Todo[]>` when TypeScript cannot infer the shape from the initial value. Use union types for state with a known set of values — it's more precise than `string`.

## tsconfig.json

The course uses CRA's default `tsconfig.json` (strict mode enabled). Don't disable strict mode "to make errors go away" — fix the types. Two useful non-default options:

```json
{
  "compilerOptions": {
    "noUncheckedIndexedAccess": true,
    "exactOptionalPropertyTypes": true
  }
}
```

These catch the "I thought this was defined but it might be undefined" class of bugs.

## When NOT to use TypeScript

For a quick prototype or a 100-line scratch script, plain JS is fine. TypeScript pays off when the project has a clear API surface (props of components, shape of state). The course moves to TS at module 29, not earlier, for that reason.
