# Project Structure — Routing (module 21)

`react-router-dom` is added in module 21. The course uses the **`createBrowserRouter` + `RouterProvider`** API (introduced in React Router 6.4) with **loaders** for data fetching.

## Tree (module 21 finished)

```
<project>/
├── package.json
├── index.html
├── public/
│   ├── index.html         # CRA-style; module 21 still on CRA
│   ├── favicon.ico
│   ├── logo192.png
│   ├── logo512.png
│   ├── manifest.json
│   └── robots.txt
└── src/
    ├── index.js           # entry
    ├── index.css
    ├── App.js             # router definition
    ├── pages/             # route views
    │   ├── Root.js        # layout wrapper (always rendered)
    │   ├── Home.js
    │   ├── EventsRoot.js  # nested layout for /events
    │   ├── Events.js
    │   ├── EventDetail.js
    │   ├── NewEvent.js
    │   ├── EditEvent.js
    │   └── Error.js       # errorElement for any route
    └── components/        # reusable UI (no routing)
        ├── MainNavigation.js
        ├── EventsNavigation.js
        ├── EventsList.js
        ├── EventItem.js
        ├── EventForm.js
        └── PageContent.js
```

> Note: module 21 still uses CRA (`public/index.html`, `.js` not `.jsx`). The conventions for **naming and folder layout** carry over to Vite-based projects (modules 22+).

## Naming rules

### Pages vs components

| Pages (`src/pages/`) | Components (`src/components/`) |
|---|---|
| Match a route | Reused across multiple pages |
| Render the page's main content | Render a piece of UI (button, list, nav) |
| Imported only by the router | Imported by pages and other components |
| `PascalCase.js`, **one route per file** | `PascalCase.js`, one component per file |

### Layout / wrapper pages

`Root.js` and `EventsRoot.js` are **layout routes** — they wrap a nested router with shared chrome (header, footer, error boundary). They render `<Outlet />` for the child route.

```jsx
// File: src/pages/EventsRoot.js
import { Outlet } from 'react-router-dom';
import EventsNavigation from '../components/EventsNavigation';

export default function EventsRootLayout() {
  return (
    <>
      <EventsNavigation />
      <Outlet />
    </>
  );
}
```

### Error route

`Error.js` is the convention for the `errorElement` of any route. It receives `useRouteError()` to inspect the error.

```jsx
// File: src/pages/Error.js
import { useRouteError } from 'react-router-dom';
import PageContent from '../components/PageContent';

export default function ErrorPage() {
  const error = useRouteError();
  return <PageContent title="An error occurred"><p>{error.statusText || error.message}</p></PageContent>;
}
```

### Loaders

Loaders are exported from the **page file** alongside the component:

```js
// File: src/pages/Events.js
import { useLoaderData } from 'react-router-dom';
import EventsList from '../components/EventsList';

export default function EventsPage() {
  const events = useLoaderData();
  return <EventsList events={events} />;
}

export async function loader() {
  const response = await fetch('http://localhost:8080/events');
  return response.json();
}
```

The router picks the loader by name: `loader: EventsPage.loader` would be wrong — it's `loader: () => import('./pages/Events').then(m => m.loader)`, or just `{ path: 'events', element: <Events />, loader: eventsLoader }` with a named import.

## What goes in `components/` vs `pages/` in a routing project

| File | Folder | Why |
|---|---|---|
| `MainNavigation.js` | components/ | Used by `Root.js` layout |
| `EventsList.js` | components/ | Used by `Events.js` page |
| `EventsRoot.js` | pages/ | A layout route — wraps `<Outlet />` |
| `Error.js` | pages/ | An errorElement — only the router renders it |

If a file is referenced **only** by the router, it's a page. If it's referenced **by** a page, it's a component.
