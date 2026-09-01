---
name: feature-dev
description: "Systematic feature development workflow with 7 phases: Discovery, Codebase Exploration, Clarifying Questions, Architecture Design, Implementation, Quality Review, and Summary. Trigger phrases: develop a feature, add new feature, implement feature, build feature, create feature workflow."
---

A structured 7-phase workflow for building features that integrate seamlessly with your codebase. Skip a phase only when the user explicitly approves; each one prevents a specific class of wasted work.

## When to Use

- Building new features that touch multiple files.
- Features requiring architectural decisions or design choices.
- Complex integrations with existing code.
- Features where requirements are initially unclear.
- You need systematic exploration before implementation.

## When NOT to Use

- Trivial bug fixes, single-line changes, or well-defined simple tasks.
- Urgent hotfixes where the cost of process is worse than the cost of a wrong call.
- Pure refactors with no behaviour change → `codebase-architecture` first.
- Greenfield exploration without a target user → just explore, no workflow needed.

## Hard Rules

1. **Wait for explicit approval** before starting implementation, even when the design looks obvious — silent assumptions are how features get built wrong.
2. **Do not skip phases even if the request seems clear** — each phase exists to surface a specific class of risk.
3. **Wait for answers in Phase 3 before designing** — clarifying questions prevent implementing the wrong thing.
4. **Implement one criterion at a time** in Phase 5, and after each one run a quick syntax/type check — partial progress is easier to diagnose than a half-broken tree.
5. **Follow the workspace AGENTS.md conventions strictly** — file locations, naming, boundaries — because consistency outlasts the feature.
6. **Report issues with confidence ≥ 80 only** in Phase 6, to filter out speculative noise from subagent reviewers.
7. **Fix what the user agrees to fix** — present review findings and ask, do not auto-fix; the user owns the trade-off.
8. **Ad-hoc verification scripts go in `tmp/`**, not in the project tree, even during Phase 5.

## Examples

Full workflow invocation:

```
/feature-dev Add user authentication with OAuth
```

Let the workflow guide through all 7 phases. Manual agent call:

```
"Launch code-explorer to trace how authentication works"
"Launch code-architect to design the caching layer"
"Launch code-reviewer to check my recent changes"
```

Phase 4 — present 3 options:

```
Approach 1: Minimal Changes
- Extend existing AuthService with OAuth methods
- Add new OAuth routes to existing auth router
Pros: Fast, low risk
Cons: Couples OAuth to existing auth

Approach 2: Clean Architecture
- New OAuthService with dedicated interface
- Separate OAuth router and middleware
Pros: Clean separation, testable
Cons: More files, more refactoring

Recommendation: Approach 3 (Pragmatic Balance)
```

## The 7-Phase Workflow

```
Phase 1: Discovery       → Clarify what needs to be built
Phase 2: Explore         → Understand the codebase deeply
Phase 3: Clarify         → Ask questions, resolve ambiguities
Phase 4: Design          → Architecture approaches (3 options)
Phase 5: Implement       → Build following approved design
Phase 6: Review          → Quality review with agents
Phase 7: Summary         → Document what was done
```

## Phase 1: Discovery

**Goal**: Understand what needs to be built before touching code.

**Actions**:
1. Clarify the feature request if it's vague.
2. Ask what problem you're solving.
3. Identify constraints and requirements.
4. Summarize understanding and confirm with user.

**Example**:
```
User: /feature-dev Add caching
You: Let me understand what you need...
  - What should be cached? (API responses, computed values, etc.)
  - What are your performance requirements?
  - Do you have a preferred caching solution?
```

## Phase 2: Codebase Exploration

**Goal**: Build deep understanding of existing code and patterns.

**Actions**:
1. Launch `code-explorer` agents to analyze relevant areas (2-3 in parallel).
2. Each agent explores different aspects:
   - Find similar features and trace implementation.
   - Map architecture and abstractions.
   - Analyze current implementation of related features.
3. Read all identified files.
4. Present comprehensive summary of findings.

**Key files identified in this phase become the input for Phase 3.**

## Phase 3: Clarifying Questions

**Goal**: Fill gaps and resolve all ambiguities before designing.

**Actions**:
1. Review codebase findings and feature request.
2. Identify underspecified aspects:
   - Edge cases
   - Error handling requirements
   - Integration points
   - Backward compatibility needs
   - Performance constraints
3. Present questions in organized list.
4. **Wait for answers before proceeding.**

This phase prevents implementing the wrong thing.

## Phase 4: Architecture Design

**Goal**: Design multiple implementation approaches and choose the best fit.

**Actions**:
1. Launch `code-architect` agents with different focuses (2-3 in parallel):
   - **Minimal changes**: Smallest change, maximum reuse.
   - **Clean architecture**: Maintainability, elegant abstractions.
   - **Pragmatic balance**: Speed + quality.
2. Review all approaches.
3. Present comparison with trade-offs and recommendation.
4. **Ask which approach the user prefers.**

Output uses the format shown in the Examples section.

## Phase 5: Implementation

**Goal**: Build the feature following the chosen architecture.

**Actions**:
1. **Wait for explicit approval** before starting.
2. Read all relevant files identified in previous phases.
3. Implement following chosen architecture.
4. Follow workspace AGENTS.md conventions strictly.
5. Implement **one criterion at a time**.
6. After each criterion: run a syntax check
   - TypeScript: `npx tsc --noEmit`
   - JavaScript: `node --check src/<file>.js`
7. Report exactly what was created/modified.

## Phase 6: Quality Review

**Goal**: Ensure code is simple, DRY, elegant, and functionally correct.

**Actions**:
1. Launch `code-reviewer` agents in parallel (3 agents):
   - **Simplicity/DRY/Elegance**: Code quality and maintainability.
   - **Bugs/Correctness**: Functional correctness and logic errors.
   - **Conventions/Abstractions**: Project standards and patterns.
2. Consolidate findings.
3. Identify highest severity issues.
4. Present findings and ask what to do:
   - Fix now
   - Fix later
   - Proceed as-is

**Confidence scoring**: Report issues with confidence level (0-100). Only report issues ≥80 confidence to filter false positives.

## Phase 7: Summary

**Goal**: Document what was accomplished for future reference.

**Output**:
```
Feature Complete: <feature name>

What was built:
- <bullet of what was built>

Key decisions:
- <architectural decisions made>

Files modified:
- <file> — <action>
- <file> — <action>

Suggested next steps:
- <next step>
```

## Agents Used

### code-explorer

Deeply analyzes existing codebase by tracing execution paths.

**Focus**: Entry points, call chains, data flow, architecture layers, dependencies, implementation details.

**Output**: Entry points with file:line references, step-by-step flow, key components.

### code-architect

Designs feature architectures and implementation blueprints.

**Focus**: Codebase patterns, architecture decisions, component design, implementation roadmap.

**Output**: Architecture decision with rationale, complete component design, implementation map.

### code-reviewer

Reviews code for bugs, quality issues, and project conventions.

**Focus**: AGENTS.md compliance, bug detection, code quality, confidence-based filtering (≥80).

**Output**: Critical issues (75-100), important issues (50-74), specific fixes with file:line.

## Best Practices

1. **Be specific in the feature request** — more detail = fewer clarifying questions in Phase 3.
2. **Trust the process** — each phase builds on the previous.
3. **Review agent outputs** — agents provide valuable codebase insights you would miss.
4. **Do not skip phases** — each one exists because a skipped phase has bitten us before.
5. **Use it for learning** — Phase 2 teaches you about your own codebase; lean into that.
