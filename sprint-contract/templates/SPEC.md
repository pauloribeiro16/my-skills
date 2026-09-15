# SPEC — [Feature Name]

**Spec ID:** SP-YYYY-NN
**Date:** YYYY-MM-DD
**Author:** [name]
**Status:** DRAFT → REVIEWED → ANCHORED
**Level:** spec-first | spec-anchored | spec-as-source

---

## Context

### Problem Statement
[What problem does this feature solve? Why now?]

### Current State
[What exists today? What are the limitations?]

### Target State
[What will exist after this feature? How is it better?]

---

## Requirements

### Functional Requirements

| # | Requirement | Priority | Rationale |
|---|-------------|----------|-----------|
| FR-1 | [must do] | MUST | [why] |
| FR-2 | [must do] | MUST | [why] |
| FR-3 | [nice to have] | SHOULD | [why] |
| FR-4 | [optional] | NICE | [why] |

### Non-Functional Requirements

| # | Requirement | Priority | Rationale |
|---|-------------|----------|-----------|
| NFR-1 | [performance, security, etc.] | MUST | [why] |
| NFR-2 | [scalability, reliability] | SHOULD | [why] |

### Constraints

- [What cannot change?]
- [What dependencies exist?]
- [What is out of scope?]

---

## Architecture Decisions

### Decision 1: [Title]

- **Context:** [what situation]
- **Options:** [option A] vs [option B] vs [option C]
- **Decision:** [chosen option]
- **Rationale:** [why this choice]
- **Consequences:** [what this means for implementation]

### Decision 2: [Title]

- **Context:** [what situation]
- **Options:** [option A] vs [option B]
- **Decision:** [chosen option]
- **Rationale:** [why this choice]
- **Consequences:** [what this means for implementation]

[Add more decisions as needed]

---

## Data Model

### Entities

```
[Entity Name]
├── field: type (description)
├── field: type (description)
└── field: type (description)
```

### Relationships

```
[Entity A] ──1:N──→ [Entity B]
[Entity B] ──N:1──→ [Entity C]
```

### Schema Changes

| Entity | Change | Migration Required |
|--------|--------|--------------------|
| [entity] | [add/modify/remove field] | Yes/No |

---

## API / Interface Design

### Endpoints / Functions

| Method | Path / Function | Description | Input | Output |
|--------|----------------|-------------|-------|--------|
| [GET] | [/api/resource] | [description] | [params] | [response] |
| [POST] | [/api/resource] | [description] | [body] | [response] |

### Data Contracts

```python
# Input schema
class FeatureInput:
    field: str
    value: int

# Output schema  
class FeatureOutput:
    result: str
    metadata: dict
```

---

## Implementation Plan

### Phase Overview

| Phase | Name | Scope | Depends On |
|-------|------|-------|------------|
| 1 | [foundation] | [what] | — |
| 2 | [core] | [what] | Phase 1 |
| 3 | [integration] | [what] | Phase 1, 2 |

> This plan feeds into GOAL_DECOMPOSITION.md for detailed sprint contracts.

### File Changes

| File | Action | Phase | Description |
|------|--------|-------|-------------|
| `path/to/file.py` | create | 1 | [what it does] |
| `path/to/file2.py` | modify | 2 | [what changes] |

---

## Acceptance Criteria

### High-Level Criteria

| # | Criterion | Test Method |
|---|-----------|-------------|
| AC-1 | [what must be true] | [how to verify] |
| AC-2 | [what must be true] | [how to verify] |
| AC-3 | [what must be true] | [how to verify] |

### Edge Cases

| # | Edge Case | Expected Behavior |
|---|-----------|-------------------|
| EC-1 | [scenario] | [what should happen] |
| EC-2 | [scenario] | [what should happen] |

### Error Scenarios

| # | Error | Expected Behavior |
|---|-------|-------------------|
| ES-1 | [error condition] | [how it's handled] |
| ES-2 | [error condition] | [how it's handled] |

---

## Testing Strategy

| Level | What to Test | Method |
|-------|-------------|--------|
| Unit | Individual functions | pytest |
| Integration | Component interaction | pytest + mock |
| E2E | Full feature flow | Manual / automated |

---

## Open Questions

| # | Question | Answer | Impact |
|---|----------|--------|--------|
| Q1 | [unresolved question] | [pending] | [what it affects] |

---

## References

- [Related documentation]
- [Related specs]
- [External resources]

---

## Sign-off

- [ ] Requirements reviewed
- [ ] Architecture decisions approved
- [ ] Acceptance criteria validated
- [ ] Ready for contract generation
