# GOAL DECOMPOSITION — [Objetivo Grande]

**Date:** YYYY-MM-DD
**Planner:** [name]
**Spec File:** `SPEC.md` ← [omit if not using spec-driven development]
**Status:** DRAFT → APPROVED → IN_PROGRESS → COMPLETED

---

## Original Goal

[Objetivo completo como o utilizador descreveu. Manter a linguagem original do user.]

---

## Decomposition Rationale

[Porque foi decomposto. Referenciar os critérios C1-C5 que se aplicam:]

| Criterion | Applied? | Evidence |
|-----------|----------|----------|
| C1: Múltiplas funcionalidades distintas | [Sim/Não] | [exemplo] |
| C2: 3+ componentes/arquiteturas | [Sim/Não] | [exemplo] |
| C3: 5+ ficheiros estimados | [Sim/Não] | [N ficheiros] |
| C4: Conectores de sequência | [Sim/Não] | ["primeiro X, depois Y"] |
| C5: Decisões arquiteturais | [Sim/Não] | [exemplo] |

---

## Phases

| Phase | Name | Description | Files Est. | Depends On | Parallel Group | Contract | Status |
|-------|------|-------------|------------|------------|----------------|----------|--------|
| 1 | [nome curto] | [o que faz] | N | — | G0 | `CONTRACT-phase-1.json` | PENDING |
| 2 | [nome curto] | [o que faz] | N | Phase 1 | G1 | `CONTRACT-phase-2.json` | PENDING |
| 3 | [nome curto] | [o que faz] | N | Phase 1 | G1 | `CONTRACT-phase-3.json` | PENDING |
| 4 | [nome curto] | [o que faz] | N | Phase 2, 3 | G2 | `CONTRACT-phase-4.json` | PENDING |

> **Maximum phases:** 7. If more are needed, consider splitting into separate goals.

### Dependency Graph

```
Phase 1 ──→ Phase 2 ──┐
 │                     │
 └──→ Phase 3 ────────→ Phase 4
```

### Parallel Groups

| Group | Phases | Execution | Conflict Check |
|-------|--------|-----------|----------------|
| G0 | Phase 1 | Sequential (1 sprint) | N/A |
| G1 | Phase 2, Phase 3 | Parallel (2 subagents) | File overlap: [none/list] |
| G2 | Phase 4 | Sequential (1 sprint) | N/A |

> **Rule:** Sprints in same group execute simultaneously. If file overlap detected → force sequential.
> See `references/parallel-execution.md` for conflict detection and rollback.

---

## Phase Details

### Phase 1: [Nome]
- **Goal:** [objetivo específico desta fase]
- **Input:** [o que precisa existir antes — pode ser "nada" para a primeira]
- **Output:** [o que produz — artefactos concretos]
- **Validation:** [como saber que está feito — critério testável]
- **Contract File:** `CONTRACT-phase-1.json`
- **Estimated Files:** N
- **Parallel Group:** G0

### Phase 2: [Nome]
- **Goal:** [objetivo específico desta fase]
- **Input:** [o que a fase anterior produziu]
- **Output:** [o que produz]
- **Validation:** [como saber que está feito]
- **Contract File:** `CONTRACT-phase-2.json`
- **Estimated Files:** N
- **Depends On:** Phase 1
- **Parallel Group:** G1
- **Runs In Parallel With:** Phase 3

### Phase 3: [Nome]
- **Goal:** [objetivo específico desta fase]
- **Input:** [o que a fase anterior produziu]
- **Output:** [o que produz]
- **Validation:** [como saber que está feito]
- **Contract File:** `CONTRACT-phase-3.json`
- **Estimated Files:** N
- **Depends On:** Phase 1
- **Parallel Group:** G1
- **Runs In Parallel With:** Phase 2

[Repetir para cada fase...]

---

## Questions Asked

| # | Question | User Answer | Impact on Decomposition |
|---|----------|-------------|------------------------|
| 1 | [pergunta feita ao user] | [resposta] | [mudou o que na decomposição?] |
| 2 | [pergunta feita ao user] | [resposta] | [mudou o que na decomposição?] |

---

## Risks & Assumptions

### Risks
- [Risco: o que pode correr mal entre fases]
- [Risco: dependência que pode falhar]

### Assumptions
- [Assunção: o que assumimos sobre o estado entre fases]
- [Assunção: recursos disponíveis]

---

## Execution Log

| Phase | Group | Generator | Evaluator | Result | Score | Date |
|-------|-------|----------|----------|--------|-------|------|
| 1 | G0 | [agent] | [agent] | PASS/NEEDS_WORK | [N%] | YYYY-MM-DD |
| 2 | G1 | [agent] | [agent] | PASS/NEEDS_WORK | [N%] | YYYY-MM-DD |
| 3 | G1 | [agent] | [agent] | PASS/NEEDS_WORK | [N%] | YYYY-MM-DD |
| 4 | G2 | [agent] | [agent] | PASS/NEEDS_WORK | [N%] | YYYY-MM-DD |

### Group Execution Summary

| Group | Phases | Parallel? | Started | Completed | Commit Hash |
|-------|--------|-----------|---------|-----------|-------------|
| G0 | 1 | No | HH:MM | HH:MM | [hash] |
| G1 | 2, 3 | Yes | HH:MM | HH:MM | [hash] |
| G2 | 4 | No | HH:MM | HH:MM | [hash] |

---

## Rollback Plan

Se algo falhar na Phase N:
1. [passos para reverter para estado anterior]
2. [como preservar o trabalho das fases anteriores]

---

## Sign-off

- [ ] User approved decomposition
- [ ] All contracts created and approved
- [ ] All phases executed
- [ ] Quality Log updated with phase summaries
- [ ] Harness Audit run (if 5th sprint)
