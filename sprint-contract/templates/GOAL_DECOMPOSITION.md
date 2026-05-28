# GOAL DECOMPOSITION — [Objetivo Grande]

**Date:** YYYY-MM-DD
**Planner:** [name]
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

| Phase | Name | Description | Files Est. | Depends On | Contract | Status |
|-------|------|-------------|------------|------------|----------|--------|
| 1 | [nome curto] | [o que faz] | N | — | `CONTRACT-phase-1.md` | PENDING |
| 2 | [nome curto] | [o que faz] | N | Phase 1 | `CONTRACT-phase-2.md` | PENDING |
| 3 | [nome curto] | [o que faz] | N | Phase 2 | `CONTRACT-phase-3.md` | PENDING |

> **Maximum phases:** 7. If more are needed, consider splitting into separate goals.

---

## Phase Details

### Phase 1: [Nome]
- **Goal:** [objetivo específico desta fase]
- **Input:** [o que precisa existir antes — pode ser "nada" para a primeira]
- **Output:** [o que produz — artefactos concretos]
- **Validation:** [como saber que está feito — critério testável]
- **Contract File:** `CONTRACT-phase-1.md`
- **Estimated Files:** N

### Phase 2: [Nome]
- **Goal:** [objetivo específico desta fase]
- **Input:** [o que a fase anterior produziu]
- **Output:** [o que produz]
- **Validation:** [como saber que está feito]
- **Contract File:** `CONTRACT-phase-2.md`
- **Estimated Files:** N
- **Depends On:** Phase 1

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

| Phase | Executor | Reviewer | Result | Score | Date |
|-------|----------|----------|--------|-------|------|
| 1 | [agent] | [agent] | PASS/FAIL | [N%] | YYYY-MM-DD |
| 2 | [agent] | [agent] | PASS/FAIL | [N%] | YYYY-MM-DD |

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
