---
name: codebase-architecture
description: "Expert guidance for codebase architecture: refactoring, modular boundaries, clean architecture, deep modules. Use when improving code structure or evaluating tech debt."
---

Surface architectural friction and propose **deepening opportunities** — refactors that turn shallow modules into deep ones. The aim is testability, maintainability, and navigability.

## When to Use

- A module's interface is nearly as complex as its implementation (shallow).
- Understanding one concept requires bouncing between many small modules.
- Pure functions were extracted "for testability" but the real bugs hide in callers.
- Tightly-coupled modules leak across their seams.
- Tech debt is accumulating and you need a structured pass.

## When NOT to Use

- Trivial renames or single-line cleanups — just edit.
- The user has a specific design in mind and only wants implementation → `feature-dev`.
- Bug-hunting, not structure → diagnose first with the project's tooling.
- Greenfield design where no module exists yet — wait until something is concrete.

## Hard Rules

1. **Depth is a property of the interface, not the implementation** — a deep module hides complexity behind a small interface; a shallow one has an interface nearly as complex as its implementation.
2. **Apply the deletion test to suspected shallow modules** — if complexity vanishes when you delete it, the module was a pass-through; if complexity reappears across N callers, it was earning its keep.
3. **The interface is the test surface** — if you need to test *past* the interface, the module is probably the wrong shape.
4. **Wait for two adapters before introducing a port** — one adapter is hypothetical seam; two (typically production + test) is real seam. Indirection without justification is overhead.
5. **Use the project's vocabulary exactly** — call a "module" a "module", not a "component" or "service" — because consistent language is the whole point of a glossary.
6. **Record load-bearing rejections as ADRs** — when the user rejects a candidate with a non-obvious reason, write an ADR so future reviews do not re-suggest it.
7. **Propose candidates first, design interfaces after the user picks one** — proposing interfaces too early is the most common pitfall.

## Examples

Candidate card format (one per deepening):

```
Title:      <short name>
Files:      <which files/modules>
Problem:    <why the current architecture causes friction>
Solution:   <what changes, in plain English>
Benefits:   <locality, leverage>
Before/After: <visual diagram>
Strength:   Strong / Worth exploring / Speculative
```

Top recommendation goes at the end.

## Quick Start

1. Read the project's domain glossary and any ADRs first.
2. Explore the codebase noting friction points (see Process below).
3. Present candidates as a structured report.
4. Enter the **grilling loop** with the user to refine.

## Core Principles

- **Depth is a property of the interface, not the implementation.** A deep module hides complexity behind a small interface. A shallow module has an interface nearly as complex as its implementation.
- **The deletion test.** Imagine deleting a module. If complexity vanishes, the module was a pass-through. If complexity reappears across N callers, it was earning its keep.
- **The interface is the test surface.** Callers and tests cross the same seam. If you need to test *past* the interface, the module is probably the wrong shape.
- **One adapter = hypothetical seam. Two adapters = real seam.** Don't introduce a port unless at least two adapters are justified (typically production + test).

## Process

### 1. Orient

Read the project's domain glossary (`CONTEXT.md`, glossary files) and any ADRs in `docs/adr/`. The domain language gives names to good seams; ADRs record decisions not to re-litigate.

### 2. Explore

Walk the codebase and note where you experience friction:

- Where does understanding one concept require bouncing between many small modules?
- Where are modules **shallow** — interface nearly as complex as the implementation?
- Where have pure functions been extracted just for testability, but the real bugs hide in how they're called (no **locality**)?
- Where do tightly-coupled modules leak across their seams?
- Which parts are untested or hard to test through their current interface?

Apply the **deletion test** to anything you suspect is shallow.

### 3. Report

Present candidates using the card format above. End with a **Top recommendation** section.

### 4. Grilling Loop

Once the user picks a candidate, walk the design tree with them:

- **Naming a deepened module after a concept not in the glossary?** Add the term to the glossary.
- **Sharpening a fuzzy term?** Update the glossary right there.
- **User rejects with a load-bearing reason?** Offer to record an ADR so future reviews don't re-suggest it.
- **Want to explore alternative interfaces?** See `references/INTERFACE-DESIGN.md`.

Side effects happen inline as decisions crystallize.

## References

Load these files when you reach the relevant stage:

| File | When to read |
|------|-------------|
| `references/LANGUAGE.md` | Before making any suggestion. Contains the precise vocabulary (Module, Seam, Depth, Leverage, Locality). Use these terms exactly. |
| `references/DEEPENING.md` | When evaluating a deepening candidate. Classifies dependencies and guides testing strategy. |
| `references/INTERFACE-DESIGN.md` | When the user wants to explore alternative interfaces. Spawns parallel sub-agents with different design constraints. |
