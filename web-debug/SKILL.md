---
name: web-debug
description: "Use when something in a browser is wrong — a page errors on load, JS doesn't initialise, layout breaks, charts don't render, clicks do nothing. Routes by reproducibility: static file → Playwright headless; interactive / visual → Browser Use control-browser (main agent only). Trigger phrases: page broken, chart not rendering, console error, layout off, click does nothing, debug this page, why isn't X showing up."
---

Single skill, two backends. **The split exists because of the browser-use plugin restriction**: `control-browser` and the `node_repl` MCP are main-agent-only (enforced at the tool level — subagents don't have the tool even if they read this skill). Playwright, by contrast, any agent can run via Bash.

## When to Use

- A page errors on load, shows a blank screen, or fails to render charts/SVGs.
- A click does nothing, or a control that should be there is missing.
- Console errors or failed network requests need investigation.
- Layout is broken in a way the user has screenshotted.

## When NOT to Use

- Aesthetic / design issues without functional breakage → `frontend-design` or `web-frontend` agent.
- Verifying that a working app stays working → `webapp-testing`.
- Black-box user-flow validation (planning P0-P3, action→observation) → `web-gui-tester`.
- Backend or non-browser bugs → diagnose in the project's own tooling.

## Hard Rules

1. **Read the error before guessing the cause** — console errors are the first signal; DOM checks (`locator(...).count()`) confirm rendering.
2. **Screenshot before AND after a fix** to keep evidence, because the user can re-trigger the bug faster than you can describe it.
3. **Wait for `networkidle` (or `load` + fixed timeout) before inspecting** on dynamic apps, otherwise you see the pre-JS state.
4. **Put probe scripts under `<project>/tmp/`** — they are scratch, not deliverables. Do not leave `.py` files in the project root.
5. **Document environment failure modes** (CDN unreachable, chart library absent) instead of "fixing" them by inlining code — the bug is in the environment, not the page.
6. **If you cannot use `control-browser` (subagent context), fall back to Playwright** — never block waiting for a tool you do not have.
7. **Report the final state to whoever delegated** (user or subagent) — what you ran, what you saw, what you changed, what remains.

## Examples

Routing decision (use this before doing anything else):

| Symptom | Use |
|---|---|
| Static `.html` file, reproducible, no auth | **Playwright headless** — fast, scriptable, screenshots |
| Needs eyes / interaction / auth / multi-tab / extensions | **Browser Use `control-browser`** in the main agent |
| Server-backed app (needs lifecycle) | **Playwright + `webapp-testing`** for `with_server.py` |

Inline probe (write to `<project>/tmp/probe.py`, do not commit):

```python
from playwright.sync_api import sync_playwright

errors = []
failed_requests = []
with sync_playwright() as p:
    browser = p.chromium.launch()
    page = browser.new_page()
    page.on("pageerror", lambda e: errors.append(("pageerror", str(e))))
    page.on("console", lambda m: m.type == "error" and errors.append(("console", m.text)))
    page.on("requestfailed", lambda r: failed_requests.append((r.url, r.failure)))
    page.goto("file://<abs-path>", wait_until="networkidle", timeout=30000)
    page.wait_for_timeout(500)
    print("title:", page.title())
    print("canvases:", page.locator("canvas").count())
    print("svgs:", page.locator("svg").count())
    print("errors:", errors)
    print("failed_requests:", failed_requests[:10])
    browser.close()
```

Loop: run → read errors → fix one thing → re-run.

## React-specific debugging

When the page is a React app (most cases in this workspace), the generic browser probe above still applies, plus:

1. **Read the error before guessing the cause** — React's error messages are precise: "Objects are not valid as a React child", "Each child in a list should have a unique key prop", "Cannot read properties of undefined". The fix is usually one stack frame above where the message points.
2. **Check React DevTools (browser extension)** before console.logging state — DevTools shows the current state and props of every component in the tree without modifying code.
3. **`console.log` in `useEffect` to trace lifecycle** — a one-line `useEffect(() => { console.log('mount', props) }, [])` at the top of a component shows when it mounts and with what props. Remove the log when done.
4. **Strict Mode (dev only) intentionally double-invokes effects** — if you see effects fire twice in dev, that is by design, not a bug. Effects must be idempotent.
5. **Wrap fallible components in an Error Boundary** — a single top-level `<ErrorBoundary>` around `<App />` turns an uncaught render error into a visible fallback instead of a blank page.
6. **Common React error patterns**:
   - "Each child in a list should have a unique key prop" → add `key={item.id}` in the `.map()`.
   - "Cannot read property 'X' of undefined" → usually a state initial value that is `undefined` before the first render. Use `useState(() => initialValue)` or a non-null default.
   - "Too many re-renders" → a state update inside the render body. Move it into an effect or an event handler.
   - "Objects are not valid as a React child" → you are rendering an object directly. Render a property: `obj.name` not `obj`.
7. **Loader/action errors in React Router** — module 21+ projects use loaders. If a loader throws, the route's `errorElement` renders. Check the network tab for the failing request, then the loader's `throw new Response(...)` call.
8. **State changes that do not re-render** — the value being mutated instead of replaced. React detects reference changes, not deep equality. Use a new array/object, not `.push()` or property assignment.

For naming, structure, and conventions when reading the code under debug, load `react-naming`.

## Playwright loop (most common case)

Write a Playwright probe to `tmp/`, run it, and read the output. Report findings; do not "fix" by guessing.

## Browser Use loop (interactive case)

`control-browser` is the skill; it bootstraps a fresh node kernel each call and uses `domSnapshot()` as the primary read. **You must be in the main agent.** Workflow:

1. Pick a tab (`agent.browsers.list()`).
2. `domSnapshot()` — read what's there, not screenshot (cheaper).
3. Screenshot only when vision matters.
4. If you need to click or type, use the browser tool calls; reload between fixes.

## Pointers

- `webapp-testing` — Playwright with `scripts/with_server.py` for apps that need a live backend.
- `web-gui-tester` — black-box methodology: planning P0-P3, action→observation with code+visual cross-validation, final report. Use when validating user flows end-to-end, not when debugging one page.
- `frontend-design` — load when the issue is aesthetic, not functional.

## Failure modes worth knowing

- **CDN unreachable from the test environment** → `requestfailed` for jsdelivr / cdn.datatables / googleapis. The page appears empty even though the HTML is fine. Document this; do not "fix" by inlining libraries.
- **Charts render but to zero size** → usually a flex/grid issue with a parent. `locator("canvas").bounding_box()` to confirm.
- **`wait_until="networkidle"` times out** → either CDN hangs or a script has a long-running poll. Fall back to `wait_until="load"` + a fixed `wait_for_timeout`.
