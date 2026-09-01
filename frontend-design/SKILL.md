---
name: frontend-design
description: "Create distinctive, production-grade frontend interfaces with high design quality. Use when the user asks to build web components, pages, artifacts, posters, or applications (websites, landing pages, dashboards, React components, HTML/CSS layouts, or when styling any web UI). Generates creative, polished code and UI design that avoids generic AI aesthetics."
license: Complete terms in LICENSE.txt
---

Guides creation of distinctive, production-grade frontend interfaces that avoid generic "AI slop" aesthetics. Implement real working code with exceptional attention to aesthetic details and creative choices.

## When to Use

- Building any web UI: pages, components, dashboards, landing sites, posters.
- Restyling or beautifying an existing interface.
- React component work where visual quality matters (`.jsx`/`.tsx` in this workspace).
- The user asks for design quality, polish, or a distinctive look.

## When NOT to Use

- The page is functionally broken — load `web-debug` instead.
- Driving or testing an app end-to-end — load `webapp-testing`.
- Black-box validation of user flows — load `web-gui-tester`.
- Small text/content tweaks — just edit directly.

## Hard Rules

1. **Commit to one clear aesthetic direction before coding.** Brutalist, editorial, playful, refined-minimal — the differentiator is intentionality, not intensity.
2. **Match implementation complexity to the aesthetic vision.** Maximalist designs need elaborate motion and layered detail; minimalism needs precision in spacing, typography, and subtle detail.
3. **Avoid generic AI aesthetics** — overused fonts (Inter, Roboto, Arial, system stacks), purple-gradient-on-white, cookie-cutter layouts — because they make every output feel interchangeable.
4. **Pair a distinctive display font with a refined body font**, and define colours/theme as CSS variables for consistency, because the same palette reused across pages reads as a system.
5. **Concentrate motion on high-impact moments** — one orchestrated page load with staggered reveals beats scattered micro-interactions, which read as noise.
6. **Work inside the project's stack, never around it.** In this workspace: React components in `.jsx`/`.tsx`, dependencies managed by npm, structure defined in the workspace AGENTS.md §2, scratch under `tmp/`. TypeScript types stay correct.
7. **Vary choices across generations** — do not converge on the same font, palette, or layout family every time, because repetition is how the work starts to look like a template.

## Examples

Theme tokens instead of defaults:

```css
:root {
  --font-display: 'Fraunces', serif;
  --font-body: 'Public Sans', sans-serif;
  --bg: #101418;
  --ink: #e8e3d8;
  --accent: #e0b64d;
}
```

Staggered reveal on load:

```css
.card { animation: rise .5s both; }
.card:nth-child(2) { animation-delay: .08s; }
.card:nth-child(3) { animation-delay: .16s; }
@keyframes rise { from { opacity: 0; translate: 0 12px; } }
```

Handler convention — the most common React pattern in this workspace
(copied from m03, 18-outputting-list-data). The parent's `onXxx` prop
wires to the child's internal `handleXxx`:

```jsx
// ✅ Parent (App.jsx)
function handleSelect(selectedButton) {
  setSelectedTopic(selectedButton);
}
<TabButton onSelect={() => handleSelect('components')}>Components</TabButton>

// ✅ Child (TabButton.jsx)
export default function TabButton({ children, onSelect, isSelected }) {
  return (
    <li>
      <button className={isSelected ? 'active' : undefined} onClick={onSelect}>
        {children}
      </button>
    </li>
  );
}

// ❌ Mixing the two styles
<button onClick={onClick}>           // confusing: prop name = handler name?
<button onClick={clickHandler}>      // wrong prefix
<button onClick={() => onClick()}>   // double-wrap when not needed
```

See: `react-naming/references/naming-handlers.md`.

## React patterns (load on demand)

For React/TypeScript work in this workspace, examples follow the
Maximilian Schwarzmüller course conventions. Load the relevant reference
before writing a new component:

| If you are… | Read… |
|---|---|
| Picking a component filename | `references/component-filename.md` |
| Writing imports (no barrel files) | `references/no-barrel-imports.md` |
| Wiring component-scoped CSS | `references/css-modules.md` |

For the full table of React/TypeScript conventions (hooks, handlers,
state, routing, testing, TypeScript), load `react-naming`.

## Design Thinking

Before coding, understand the context:

- **Purpose**: What problem does this interface solve? Who uses it?
- **Tone**: Pick an extreme and commit — brutally minimal, maximalist, retro-futuristic, organic, luxury, playful, editorial, industrial. Use these for inspiration, then design one direction true to the brief.
- **Constraints**: Technical requirements (framework, performance, accessibility).
- **Differentiation**: What makes this unforgettable — the one thing someone will remember?

Then implement working code (HTML/CSS/JS, React, TypeScript) that is production-grade, visually striking, cohesive in point-of-view, and meticulously refined.

## Frontend Aesthetics Guidelines

- **Typography**: distinctive over safe; avoid generic families; unexpected, characterful pairings.
- **Color & Theme**: commit to a cohesive aesthetic; dominant colours with sharp accents outperform timid, evenly distributed palettes.
- **Motion**: CSS-only first for static HTML; Motion library for React when available; scroll-triggered and hover surprises welcome.
- **Spatial composition**: unexpected layouts, asymmetry, overlap, diagonal flow, grid-breaking elements; generous negative space or controlled density.
- **Backgrounds & details**: atmosphere over flat colour — gradient meshes, noise, geometric patterns, layered transparency, dramatic shadows, custom cursors, grain.

Interpret creatively and make unexpected choices that feel genuinely designed for the context. No two outputs should look alike.
