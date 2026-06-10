---
name: codebase-architecture
description: "Expert guidance for codebase architecture: refactoring, modular boundaries, clean architecture, deep modules. Use when improving code structure or evaluating tech debt."
---

# Codebase Architecture

Surface architectural friction and propose **deepening opportunities** -- refactors that turn shallow modules into deep ones. The aim is testability, maintainability, and AI-navigability.

## Quick Start

1. Read the project's domain glossary and any ADRs first
2. Explore the codebase noting friction points (see [Process](#process) below)
3. Present candidates as a structured report
4. Enter the **grilling loop** with the user to refine

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
- Where are modules **shallow** -- interface nearly as complex as the implementation?
- Where have pure functions been extracted just for testability, but the real bugs hide in how they're called (no **locality**)?
- Where do tightly-coupled modules leak across their seams?
- Which parts are untested or hard to test through their current interface?

Apply the **deletion test** to anything you suspect is shallow.

### 3. Report

Present candidates in a structured format (one per card):

- **Title** -- short name for the deepening
- **Files** -- which files/modules are involved
- **Problem** -- why the current architecture causes friction
- **Solution** -- what changes, in plain English
- **Benefits** -- in terms of **locality** and **leverage**
- **Before / After** -- visual diagram of the change
- **Recommendation strength** -- Strong / Worth exploring / Speculative

End with a **Top recommendation** section.

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

## Common Pitfalls

- **Proposing interfaces too early.** Explore and present candidates first. Only design interfaces after the user picks a candidate.
- **Using wrong vocabulary.** Don't say "component" or "service" when you mean "module." Consistent language is the whole point.
- **Introducing ports for single adapters.** A seam with one adapter is just indirection. Wait for a second adapter to justify it.
- **Over-engineering.** Not every shallow module needs deepening. Focus on modules where shallowness causes measurable friction.
