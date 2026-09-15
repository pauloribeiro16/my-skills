# Spec-Driven Development Reference

Spec-first approach integrated into the sprint-contract workflow.

## What is Spec-Driven Development (SDD)?

A structured approach where a specification is written **before** any code, serving as the source of truth for requirements, architecture decisions, and acceptance criteria. The spec drives both contract creation and implementation.

### Levels of SDD

| Level | Description | When to Use |
|-------|-------------|-------------|
| **spec-first** | Spec written before contract, used to generate criteria | Default for sprint-contract |
| **spec-anchored** | Spec kept alive after implementation, updated with changes | Mature features, ongoing evolution |
| **spec-as-source** | Spec is the only file humans edit, AI generates code from it | Experimental, high-trust workflows |

**This skill uses spec-first as default.** Spec is written once, contracts are derived from it, but the spec is not updated after implementation starts.

## When to Use SDD

| Situation | Use SDD? | Why |
|-----------|----------|-----|
| New feature, unclear requirements | **YES** | Forces deep thinking about what to build |
| Complex architecture (3+ components) | **YES** | Documents decisions before coding |
| Simple bugfix | NO | Overhead not justified |
| Refactoring with clear scope | NO | Contract is sufficient |
| Multi-sprint pipeline | **YES** | Spec aligns all sprints to same vision |
| User says "spec-first" | **YES** | Explicit request |

## SDD Workflow

```
1. RECEIVE GOAL from user
         │
         ▼
2. WRITE SPEC (Phase 0.5)
   ├── Context: problem, current state, target state
   ├── Requirements: functional + non-functional
   ├── Architecture decisions: options considered, chosen approach
   ├── Data model: entities, relationships
   ├── API design: endpoints, functions, contracts
   ├── Acceptance criteria: high-level + edge cases
   └── File changes: which files, which phase
         │
         ▼
3. USER REVIEWS SPEC
   ├── Max 2 revision rounds
   └── User approves spec
         │
         ▼
4. GENERATE CONTRACTS FROM SPEC
   ├── Each phase in spec → one CONTRACT.json
   ├── Acceptance criteria → contract criteria (MUST/SHOULD/NICE)
   ├── File changes → contract "Files to Change"
   └── Architecture decisions → contract "Risks" section
         │
         ▼
5. BUILD DEPENDENCY GRAPH
   ├── Map phase dependencies from spec
   ├── Assign parallel groups
   └── Check file conflicts
         │
         ▼
6. EXECUTE (parallel groups)
   ├── Sprints in same group → parallel subagents
   ├── Commit per group
   └── Validate after each group
```

## Spec → Contract Mapping

| Spec Section | Contract Section | How |
|--------------|-----------------|-----|
| Requirements (MUST) | Output Criteria (MUST) | Each requirement becomes a criterion |
| Requirements (SHOULD) | Output Criteria (SHOULD) | Nice-to-have features |
| Acceptance Criteria | Validation Commands | AC → testable validation |
| Architecture Decisions | Risks | Decisions create risks |
| File Changes | Files to Change | Direct mapping |
| Edge Cases | Outcome Criteria | Edge case behavior → system state |
| Error Scenarios | Outcome Criteria | Error handling → system state |

### Example Mapping

```
Spec:                    Contract:
  FR-1: "User can         C1 (MUST): "User can create account
        create account            and receive confirmation email"
        with email confirmation"  Validation: python -c "..."

  EC-1: "Duplicate email   C3 (SHOULD): "Duplicate email returns
        returns 409"              409, no account created"
                                  Validation: python -c "..."
```

## Spec Template

Copy from: `templates/SPEC.md`

### Key Sections

1. **Context** — Why this exists (problem + current + target state)
2. **Requirements** — What must be built (MUST/SHOULD/NICE)
3. **Architecture Decisions** — How it will be built (options + rationale)
4. **Data Model** — What data structures are needed
5. **API Design** — What interfaces are exposed
6. **Acceptance Criteria** — How to verify it works
7. **Implementation Plan** — Phases and file changes

## Spec Quality Checklist

Before approving spec, verify:

- [ ] Every MUST requirement has a testable acceptance criterion
- [ ] Architecture decisions include rationale (not just "we chose X")
- [ ] File changes map to specific phases
- [ ] Edge cases are documented
- [ ] Error scenarios are documented
- [ ] No ambiguity — each requirement is binary (done/not done)
- [ ] Out of scope is explicitly stated

## Benefits

| Benefit | Description |
|---------|-------------|
| **Clarity** | Forces deep thinking before coding |
| **Alignment** | All sprints work toward same spec |
| **Traceability** | Every code change traces back to a requirement |
| **Quality** | Less rework, fewer surprises |
| **Parallel execution** | Spec defines clear boundaries for parallel sprints |
| **Onboarding** | New context (human or AI) can read spec to understand feature |

## Anti-Patterns

| Anti-Pattern | Problem | Fix |
|--------------|---------|-----|
| Spec-once | Spec written, never revisited | At minimum, review spec before final commit |
| Spec-as-contract | Spec contains testable criteria | Keep spec high-level, contracts have testable criteria |
| Spec creep | Spec keeps growing during implementation | Lock spec after approval, create new spec for changes |
| No spec | Skipping straight to contracts | Use spec for any feature with 3+ files or architectural decisions |

## Integration with Parallel Execution

Spec defines which phases are independent:

```
Spec: Phase 1 (foundation), Phase 2 (auth), Phase 3 (dashboard), Phase 4 (tests)

Dependencies from spec:
  Phase 2 needs Phase 1 (auth needs DB schema)
  Phase 3 needs Phase 1 (dashboard needs DB schema)
  Phase 3 does NOT need Phase 2 (dashboard independent of auth)
  Phase 4 needs Phase 2, Phase 3 (tests need all features)

Parallel groups:
  G0: [Phase 1]
  G1: [Phase 2, Phase 3]  ← parallel
  G2: [Phase 4]
```

## References

- Original article: [Using spec-driven development with Claude Code](https://heeki.medium.com/using-spec-driven-development-with-claude-code-4a1ebe5d9f29)
- Three levels: [Exploring the use of gen AI for software development](https://martinfowler.com/articles/exploring-gen-ai/sdd-3-tools.html) by Birgitta Böckeler
- Template: `templates/SPEC.md`
- Parallel execution: `references/parallel-execution.md`
