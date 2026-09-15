---
name: academic-writing
description: "Draft, structure, and improve each section of a scientific research article (Introduction, Methods, Results, Discussion, Title, Abstract). Use when drafting, writing, or revising manuscript sections. Trigger phrases: draft the introduction, write the methods, how to write results, structure the discussion, improve the title, write the abstract, what tense to use, choose a target journal, prepare a manuscript for submission."
---

# Academic Writing

Guidance for drafting, structuring, and revising each section of a scientific
research article that follows the **AIMRaD** convention (Abstract,
Introduction, Materials and methods, Results, and Discussion). Distilled from
Cargill & O'Connor, *Writing Scientific Research Articles: Strategy and Steps*
(2009), generalised for computer-science, cybersecurity, and regulatory
papers.

> **Progressive disclosure:** SKILL.md (this file) gives the triggers, the
> non-negotiable principles, and the topic index. Detailed guidance for each
> section lives in `references/`. Annotated example fragments live in
> `examples/`. Load only what the current task needs.

## When to Activate

Activate this skill when **any** of the following is true:

- The user says "draft", "write", "structure", "how to write", "improve", or
  "revise" in connection with a manuscript section (introduction, methods,
  results, discussion, title, abstract, summary).
- The user asks what verb tense to use, how to design a figure/table, how to
  cite, how to choose a target journal, or how to prepare a manuscript.
- The user is turning a set of results into a paper, ordering figures/tables,
  or writing a take-home message.
- The user asks about sentence templates, noun phrases, article use
  (a/an/the), or `which` vs `that`.

**Do NOT activate** for reviewing or critiquing an existing draft — that is
the `academic-evaluation` skill. This skill is for *producing* text.

## Core Principles (Non-Negotiable)

These apply to **every** section being drafted.

| # | Principle | Why |
|---|-----------|-----|
| 1 | **Results drive the paper.** Decide the results "story" and take-home message before writing any other section. Every figure/table must support that story. | The whole article is governed by the Results. |
| 2 | **Write Stages 4 → 3 → 1 → 2 of the Introduction.** Draft the aim (Stage 4) first, then the gap (3), then the setting (1), then the literature foundation (2). | Stage 4 is easiest and anchors everything. |
| 3 | **Old information before new information.** Begin each sentence with what the reader already knows; end with the new point. | This is the single biggest driver of flow in English. |
| 4 | **Subject + verb within the first 7–9 words.** Never write "top-heavy" sentences with a long subject and a short passive verb at the end. | Readers cannot parse a verb they have not yet reached. |
| 5 | **Tables and figures must stand alone.** A reader must understand a table/figure from its title/legend alone, without the article text. | Referees check "Are all illustrations required?" and "Are legends adequate?" |
| 6 | **Match claim strength to evidence strength.** Choose verbs (`demonstrate` > `indicate` > `appears` > `suggests`) and modal verbs (`will` > `may`) to match how firmly the data support the claim. | Over-claiming is a top reason for rejection. |
| 7 | **No commentary in Results.** Report what was observed; interpret only in the Discussion. No "surprisingly", "interestingly". | Separation of observation from interpretation. |

## Topic Index — Read on Demand

Load the reference that matches the current task.

| Task | File |
|------|------|
| Understand the AIMRaD hourglass and its variations (AIRDaM, AIM(RaD)C) | `references/article-structure.md` |
| Draft the Introduction (5 stages, gap signal words, citation styles) | `references/introduction.md` |
| Draft the Methods (purpose, organisation, passive vs active, top-heavy fix) | `references/methods.md` |
| Draft the Results (figure/table/text choice, tense, results sentences) | `references/results.md` |
| Draft the Discussion (structure, information elements, claim strength) | `references/discussion.md` |
| Write or revise the Title (4 strategies, noun-phrase ambiguity) | `references/title.md` |
| Write the Abstract/Summary (B/P/M/R/C elements, word limit) | `references/abstract.md` |
| Select a target journal (scope, audience, impact factor caveats) | `references/journal-selection.md` |
| Prepare and edit a manuscript (14-step process, 22-point pre-review checklist) | `references/manuscript-process.md` |
| Re-use language safely (sentence templates, noun-phrase shells) | `references/sentence-templates.md` |
| Use English articles (a/an/the) and `which` vs `that` correctly | `references/english-articles.md` |
| Study an annotated real article to see the principles in action | `examples/kaiser-2003-annotated.md`, `examples/britton-simmons-2008-annotated.md` |

## Quick Reference

### Verb tense by section

| Section | Typical tense | Example |
|---------|---------------|---------|
| Introduction — general truth | Present | "Cybersecurity is a growing field." |
| Introduction — prior work | Past or present perfect | "Smith et al. showed…" / "Several studies have investigated…" |
| Introduction — gap | Present perfect | "It has not yet been established whether…" |
| Introduction — aim | Past | "We aimed to evaluate…" |
| Methods | Past (passive or active) | "Models were run via Ollama." |
| Results | Past for the study; present for the document/always-true | "The model achieved 86.96%." / "Table 1 shows…" |
| Discussion — claims | Present (strong) or modal (weak) | "demonstrate that… regulate…" / "suggests that… may be…" |

### Citation styles (Introduction Stages 2–3)

| Style | Use when | Example |
|-------|----------|---------|
| Information-prominent | Default — the fact matters, not who said it | "…since the development of synthetic fibres (Smith 2000)." |
| Author-prominent | You agree, or you want to flag upcoming contrast | "As Smith (2000) pointed out, …" / "Smith (2000) argued that …. However, Jones et al. (2004) found that …." |
| Weak author-prominent | Topic sentence opening a new sub-argument | "Several authors have reported that … (Smith 2000, Wilson 2003, Nguyen 2005)." |

### Introduction Stage 4 sentence templates

```
The objectives of this study were to: (1) determine [NP];
(2) analyse [NP]; (3) evaluate [NP]; and (4) discuss [NP].

As part of a long-term research effort aimed at [NP1],
this paper presents [NP2].
```

### Claim-strength ladder (Discussion)

```
Strong   demonstrate / show / establish  … + present tense
         indicate … + present / future
         appear to … + present
Weak     suggest … + modal (may / could)
```

## Stop Conditions

Stop and ask the user if:

- The target journal is unknown — formatting, length, and structure all depend
  on it.
- The results "story" or take-home message is not agreed with co-authors — do
  not draft other sections until it is.
- The claim strength the user wants conflicts with what the data support —
  flag the over- or under-claim rather than silently complying.
- A section the user asks to write depends on results that are not finalised.
- The discipline's convention is unclear (e.g., combined vs separate Results
  and Discussion) — check a sample article from the target journal first.

## Coordination with Other Skills

- **`academic-evaluation`** — invoke when the task shifts from drafting to
  reviewing or critiquing a draft against referee criteria.
- **`doc-coauthoring`** — invoke for the broader co-authoring workflow
  (track changes, comments, revision rounds).
- **`internal-comms`** — not relevant; this skill is for manuscript content.

## Use When

Use this skill whenever the task is to **produce or improve** the text of a
research article — drafting a section, choosing a structure, refining a title,
writing an abstract, selecting a journal, or preparing a manuscript for
submission. For **reviewing or critiquing** a finished draft, use
`academic-evaluation` instead.
