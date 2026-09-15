---
name: academic-evaluation
description: "Review, critique, and check a research article draft against referee criteria. Use when reviewing, evaluating, or strengthening a manuscript before submission. Trigger phrases: review this draft, check this manuscript, is this paper good enough, what would a referee say, find weaknesses, peer review, critique the introduction/methods/results/discussion, deal with reviewer comments, respond to referees, handle rejection."
---

# Academic Evaluation

Framework for **reviewing, critiquing, and strengthening** a research article
draft before submission, and for responding to editors and referees
afterwards. Distilled from Cargill & O'Connor, *Writing Scientific Research
Articles: Strategy and Steps* (2009), Ch. 3, 13–15, 17.

> **Progressive disclosure:** SKILL.md gives the 13 referee criteria, the
> seven reviewer-comment categories, and the topic index. Detailed checklists
> and response guides live in `references/`. Annotated review fragments live
> in `examples/`.

## When to Activate

Activate this skill when **any** of the following is true:

- The user says "review", "check", "evaluate", "critique", "is this good",
  "what's wrong with", or "strengthen" in connection with a manuscript or a
  section.
- The user wants to know what a **referee** would say, or to **pre-review** a
  draft before submission.
- The user is responding to editor/referee comments, deciding how to handle
  "revise and resubmit", or recovering from rejection.
- The user asks to categorise reviewer comments or write a response letter.

**Do NOT activate** for drafting new text — that is the `academic-writing`
skill. This skill is for *judging or defending* text that already exists.

## The 13 Referee Criteria

These are the questions referees typically answer when reviewing a science
manuscript (Cargill Fig. 3.1 / 13.2). For each, the table shows where the
referee looks for evidence.

| # | Criterion | Look in |
|---|-----------|---------|
| 1 | Is the contribution **new**? | Introduction (Stages 2–4), Discussion |
| 2 | Is the contribution **significant**? | Introduction (Stage 3 gap, Stage 5 value), Discussion (implications) |
| 3 | Is it **suitable** for this journal? | Whole paper vs. journal scope/aims |
| 4 | Is the **organization** acceptable? | Whole paper — AIMRaD coherence |
| 5 | Do the **methods** and treatment of results conform to acceptable scientific standards? | Methods, Results |
| 6 | Are all **conclusions** firmly based in the data presented? | Discussion vs. Results |
| 7 | Is the **length** satisfactory? | Whole paper vs. journal limits |
| 8 | Are all **illustrations** required? | Figures/tables vs. story |
| 9 | Are all the **figures and tables** necessary? | Figures/tables vs. text duplication |
| 10 | Are figure **legends** and table **titles** adequate? | Each legend/title — stand-alone test |
| 11 | Do the **title and Abstract** clearly indicate the content? | Title, Abstract |
| 12 | Are the **references** up to date, complete, and correctly abbreviated? | Reference list, in-text citations |
| 13 | Is the paper **excellent, good, or poor**? | Overall |

The standard recommendation options a referee ticks:

- Accept without alteration
- Accept after minor revision
- Review again after major revision
- Reject

## Seven Categories of Reviewer Comment

When responding to comments, first sort each one into a category (Cargill
Ch. 14). The category determines the response strategy — see
`references/response-strategies.md`.

1. The **aims** of the study are not clear.
2. The **theoretical premise** or "school of thought" is challenged.
3. The **experimental design or analysis methods** are challenged.
4. You are asked to **supply additional data**.
5. You are asked to **remove** information or discussion.
6. The **conclusions** are considered incorrect, weak, or too strong.
7. **Unspecific negative** comments ("poorly designed", "badly organised",
   "English is poor").

## Four Rules of Thumb for Responding

1. It is rare that the referee is completely right and the author completely
   wrong — or vice versa.
2. The object is to **accommodate** the referee's comments without
   compromising the paper's message (story).
3. Always show the editor you are doing everything possible to **improve** the
   manuscript.
4. Rejection and criticism do **not** automatically mean the science is bad or
   the writing poor — consider other journals, additional work, or rewriting.

## Topic Index — Read on Demand

| Task | File |
|------|------|
| Apply the full 13-criteria referee framework to a draft | `references/referee-criteria.md` |
| Run a 22-point pre-review checklist before submission | `references/pre-review-checklist.md` |
| Check a specific section (Intro/Methods/Results/Discussion/Title/Abstract) | `references/section-checks.md` |
| Categorise and rate common English errors (EAL authors) | `references/common-errors.md` |
| Understand what reviewers and editors do, and the five practices of successful authors | `references/reviewer-perspective.md` |
| Respond to reviewer/editor comments (response types, response letter) | `references/response-strategies.md` |
| Handle rejection or decide between options after a negative decision | `references/rejection-handling.md` |
| See what an evaluator flags in a real annotated article | `examples/reviewed-peas.md` |

## Quick Reference

### Referee's report — typical structure

A referee report usually has: a recommendation tick-box list (above), then a
narrative covering the strongest points first, then specific section-by-
section comments, then minor points ("other queries pencilled on the
manuscript").

### The two most powerful tools for responding

- **Citing the published literature** — published work is already vetted;
  compare/contrast findings to support your argument.
- **Improving manuscript structure** — revise headings, topic sentences, and
  section flow (the techniques in `academic-writing`).

### Red flags that usually trigger rejection

- Aims not stated or not matched by methods/results
- Methods insufficient for reproducibility or credibility
- Conclusions not supported by data (over-claiming)
- Poor language/structure that prevents review
- Out of scope for the journal
- Clear scientific flaws

## Stop Conditions

Stop and ask the user if:

- The target journal is unknown — "suitability" (criterion 3) cannot be
  judged without it.
- The user wants a judgement on novelty or scientific validity in a domain you
  cannot verify — flag the limit rather than guessing.
- A reviewer comment is ambiguous — do not assume the category; ask the user
  what the referee most likely meant.
- The user asks you to defend something that the data do not support — propose
  a hedged reformulation instead.

## Coordination with Other Skills

- **`academic-writing`** — invoke when the review surfaces sections that need
  re-drafting. This skill identifies the problem; the writing skill produces
  the fix.
- **`doc-coauthoring`** — invoke when the response involves tracked changes
  across co-authors.

## Use When

Use this skill whenever the task is to **judge, review, or defend** a
manuscript — running a pre-review checklist, predicting referee objections,
categorising reviewer comments, writing a response letter, or deciding what to
do after a rejection. For **drafting or rewriting** sections, use
`academic-writing` instead.
