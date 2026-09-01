---
name: agent-orchestration
description: Orchestration playbook for AEGIS multi-phase agent work — evaluation cycles (deterministic checker before LLM judge, digest-first reporting), architecture decisions (one branch per contract, stable spec pins, failure attribution before blaming the model), and validation gates (tests + CI before commit, human spot-checks on weakest verdicts). Use when orchestrating, planning contracts, evaluating model outputs, scoring runs, validating changes, or reporting pipeline status.
license: Internal AEGIS-KG practice; distilled from CORR-105/CORR-106 sessions (2026-08/09).
---

# Agent Orchestration

The operating cycle for AEGIS-KG work, distilled from the CORR-105
(evaluation framework) and CORR-106 (transformers provider) sessions.
Three layers: **Evaluate**, **Architect**, **Validate**. Each section
states the rule, the why, and the failure it prevents.

## Layer 1 — Evaluate

Source of truth for the protocol: `execution/reports/EVAL_PROTOCOL.md`
(rubric v1: 5 criteria per spec, fixed versioned weights) and
`execution/reports/model_matrix.md` (scorecard + changelog).

1. **Deterministic checker before any judge.** Run
   `scripts/eval/generate_report.py --run-dir <dir> --preproc preproc_out
   --output-{dir,md,json} ... --use-parser-gate` first. Parse rates,
   field counts, activation counts are free and objective; the LLM judge
   only scores what the checker cannot.
2. **Judge pass, rubric v1.** Per spec × model, every score cell carries
   **what** is evaluated, **how** it was measured, the **measured
   numbers**, and the **why** (justification + evidence quote with file
   location). A bare PASS/FAIL is not an acceptable cell.
3. **Anti-bias rules:** anti-verbosity (length never earns points —
   specificity per 100 chars), evidence-only quotes (if the judge cannot
   quote it, it outputs NO EVIDENCE), judge family ≠ student family.
4. **Digest-first reporting:** the human reads ≤1 page per spec (with a
   PT TL;DR at the top); raws stay in the results mirror for audit.
   Flag the 2–3 lowest-confidence verdicts for human spot-check (P7).
5. **Status reports are state-only.** When asked "como está a pipeline":
   done / in-flight / open tracks. No unsolicited recommendations — end
   with open tracks and let the user pick.
6. **Update the matrix + changelog, then commit**, so the next cycle
   starts from the recorded state, not from memory.

## Layer 2 — Architect

1. **One branch per contract; phases are commits**, never separate
   branches. Commit each phase so a failed later phase leaves the
   earlier ones useful.
2. **Stable pins.** `Methodology-main/` specs are a fixed reference —
   evaluate models against the spec; never adapt the spec to a model.
   Parser-side tolerance is fine; spec-side edits are a separate
   decision the user owns.
3. **Failure attribution before blame.** When a stage produces empty or
   unparseable output, determine whether the failure is the model's
   capability or the plumbing (parser shape, executor field names,
   provider wiring). Evidence: qwen3.5 and qwen3.8 both scored 2.2 on
   P1C-01 — the blocker was the parser shape, not the models. Fixing
   plumbing first can make two "weak" models viable.
4. **Docs-first for protocols.** Write and commit the protocol
   (CONTRACT + EVAL_PROTOCOL) before applying it, so retroactive scores
   are comparable.
5. **Small reversible steps on remote infra.** Scout (30 min) before
   run-all (8h); one variable per resubmission; read the log before
   resubmitting anything.

## Layer 3 — Validate

1. **Tests before commit** (repo Always-rule); new behaviour gets a new
   test; stdlib-only tests preferred so they run in minimal venvs.
2. **CI gates before every commit:** `bash .hooks/ci-frameworks.sh`,
   relevant pytest files, `ruff check` on touched files. Report failures
   verbatim, never silently re-run.
3. **Never push without explicit user OK.**
4. **Human spot-check (P7)** on the weakest AI-generated verdicts — mark
   them, don't hide them.
5. **Record environment for reproducibility:** judge model + version,
   commit SHA, Ollama version, JOB IDs, walltime. A score without its
   environment is not comparable.
6. **Memory discipline:** persist user feedback (what/why/how-to-apply)
   when it recurs; check for an existing memory before writing a new one.

## Failure Catalogue (prevented by this cycle)

| Failure | Prevented by |
|---|---|
| 120k-token raws the human cannot read | Digest-first (L1.4) |
| "PASS" cells that mean nothing | What/how/measured/why cells (L1.2) |
| Schema-valid but empty content scored as OK | Deterministic checker before judge (L1.1) |
| Judge rewarding the longest output | Anti-verbosity criterion (L1.3) |
| Blaming a model for a parser bug | Failure attribution (L2.3) |
| Spec drift to fit a weak model | Stable pin (L2.2) |
| Silent push of unvalidated work | No-push-without-OK (L3.3) |
| Scores not comparable across runs | Environment recording (L3.5) + fixed weights (L1.2) |
