---
name: webapp-testing
description: "Toolkit for interacting with and testing local web applications using Playwright. Supports verifying frontend functionality, debugging UI behavior, capturing browser screenshots, and viewing browser logs. Language-agnostic: the harness runs on Python + Playwright but drives apps written in any framework."
license: Complete terms in LICENSE.txt
---

Tests local web applications by writing native Python Playwright scripts. The test harness is Python + Playwright; the **app under test can be anything** (React, Vite, Next, plain HTML, etc.).

## When to Use

- Verifying a local dev server actually serves the expected UI.
- Driving end-to-end interactions against a page (clicks, form fills, navigation).
- Capturing screenshots, console logs, or network failures for diagnosis.
- Cross-checking a fix before handing control back to the user.

## When NOT to Use

- A page errors on load → `web-debug` (this skill expects a working page).
- Aesthetic / visual quality → `frontend-design` or `web-frontend` agent.
- Unit-testing pure functions → write those in the project's own test runner.
- Production/CI workflows → this skill is local-dev-only.

## Hard Rules

1. **Run scripts with `--help` first** to see usage; do not read the source until you have tried running the script and found the defaults insufficient — these scripts are large and pollute context when ingested.
2. **Use bundled scripts as black boxes** — `scripts/with_server.py` exists to be called, not read.
3. **Always launch chromium in headless mode** — this is a dev tool, not a user-facing browser.
4. **Always close the browser when done** — `browser.close()` (or `with sync_playwright()` block).
5. **Wait for `page.wait_for_load_state('networkidle')`** before inspecting the DOM on dynamic apps — otherwise you see the pre-JS state.
6. **Put ad-hoc verification scripts under `<project>/tmp/`**, never in the project's `tests/` or root. Scratch does not become a deliverable.
7. **Use descriptive selectors** — `text=`, `role=`, CSS, or IDs — because position-based selectors break the moment layout shifts.

## Examples

Single-server automation:

```bash
python scripts/with_server.py --server "npm run dev" --port 5173 \
  -- python your_automation.py
```

Minimal script body:

```python
from playwright.sync_api import sync_playwright

with sync_playwright() as p:
    browser = p.chromium.launch(headless=True)
    page = browser.new_page()
    page.goto('http://localhost:5173')
    page.wait_for_load_state('networkidle')
    # ... your automation logic
    browser.close()
```

Reconnaissance-then-action (server already running):

```python
page.goto(url); page.wait_for_load_state('networkidle')
page.screenshot(path='/tmp/inspect.png', full_page=True)
content = page.content()
page.locator('button').all()
# then act on discovered selectors
```

## Decision Tree: Choosing Your Approach

```
User task → Is it static HTML?
    ├─ Yes → Read HTML file directly to identify selectors
    │         ├─ Success → Write Playwright script using selectors
    │         └─ Fails/Incomplete → Treat as dynamic (below)
    │
    └─ No (dynamic webapp) → Is the server already running?
        ├─ No → Run: python scripts/with_server.py --help
        │        Then use the helper + write simplified Playwright script
        │
        └─ Yes → Reconnaissance-then-action:
            1. Navigate and wait for networkidle
            2. Take screenshot or inspect DOM
            3. Identify selectors from rendered state
            4. Execute actions with discovered selectors
```

## Best Practices

- Use `sync_playwright()` for synchronous scripts.
- Add appropriate waits: `page.wait_for_selector()` or `page.wait_for_timeout()`.
- Report what was run, what passed, and what was skipped — never claim success without having run it.
- Clean up `tmp/` after the task — no leftover scratch files.

## References

- `examples/element_discovery.py` — discovering buttons, links, inputs.
- `examples/static_html_automation.py` — `file://` URLs for local HTML.
- `examples/console_logging.py` — capturing console logs during automation.
- `scripts/with_server.py` — server lifecycle helper (run `--help` first).
