# Run report — Phase 2 Structural Scientific Editor

File: papers/first-paper/12_introduction.md
Sections processed: Introduction

## Sentence counts

- In: 88 prose sentences
- Out: 83 prose sentences
- Removed: audience sentence (moved to comment), citation-scaffold block (4 lines)

## Completions inserted

- None (0). Closed-form completions were not required in Steps 1-2.

## Placeholders created

- `[[ question ]]`: none yet.
- `XXX`: none.

## Labels proposed

| Label | Source span | Qualifier status |
|-------|-------------|------------------|
| ## Opening: the stakes | structural | neutral |
| ## Challenge: the gap | structural | neutral |
| ## Policy context and stakeholders | structural | neutral |
| ## The question | structural | neutral |
| ## Concepts | structural | neutral |
| ## The method in principle | structural | neutral |
| ## The gap restated for this study | structural | neutral |
| ## Action: this study | structural | neutral |
| ## Resolution: significance | structural | neutral |
| 24 main-idea HTML-comment labels | structural | neutral |
| <!-- the audience: ... --> | new label | neutral |

Notes: `##` subsection headings are editing labels only; the author should rename
or remove them before the manuscript build (mustache concatenation). The audience
main idea replaces the removed prose sentence.

## Gaps reported (flag, don't resolve)

- Step 1: OCAR Challenge cannot be supplied as a single <=15-word statement —
  the ordering distributes it across four subsections; compression is author work.
- Step 1: OCAR Opening hook (first sentence) cannot be supplied — author work.
- Step 2: grouping of k1 requires a bridge — the concept list names core area but
  its definition now lives in the sibling k2 group; author work.
- Step 2: R2 requires the "Also, it provides..." (source 90) antecedent to stay
  in-group with source 89; author work.
- Site label: sentence source 41 (audience) removed from prose and carried as a
  comment; if the author wants it as prose again, it must be re-added.

## Ambiguities left unresolved

- Source 14 begins with a bare citation as subject
  ("@phillips2024incidental concludes that...").
- Source 112 "Their trophic level tells us..." — antecedent depends on the
  b2 paragraph contact.
- Source 90 "Also, it provides information..." — "it" requires the antecedent
  in the R2 group.

## Step 3 — classify and sort within paragraphs

### Completions inserted

- None (0). Closed-form completions were not required in Steps 1-3.

### Placeholders created (Step 3)

`[[ question ]]` inserted (3) — author must supply the missing role's content:

- After concepts definitions (k1): [[ why are these concept definitions necessary for the core-area question? ]]
- After breeding-cycle behavior (k3): [[ why does the nest-based foraging behavior matter for the core-area analysis? ]]
- After the novelty claims (A2): [[ how does being first change what the results allow? ]]

### Reorders applied (Topic -> Evidence -> Explanation -> Link)

| Paragraph | Order |
|-----------|-------|
| Opening b1 | 3, 1, 2 |
| Opening b2 | 4, 5, 6, 9, 7, 8, 10 |
| Policy p1 | 17, 16, 18 |
| Concepts k3 | 36, 34, 35, 31, 32, 33 |
| Gap g1 | 45, 47, 48, 46, 49 |
| Gap g2 | 51, 50, 52 |
| Action A1 | 53, 54, 56, 55 |
| Action A2 | 58, 57, 59 |
| Action A4 | 65, 63, 64, 66, 67 |
| Action A5 | 69, 68 |
| Resolution R1 | 72, 70, 71 |
| Resolution R2 | 76, 73, 74, 75 |
| Resolution R4 | 83, 82 |

(Source numbering matches Step 2 ledger in git; the regrouped text is the
record of record.)

### Broken connectors (author work — text moved, connectors not repaired)

- p1: "This group" (s17) now opens the paragraph; the trilateral group is
  introduced only afterwards.
- A2: "We also" (s57) dangles after s58.
- R2: "Also, it provides..." (s73) dangles after s76.
- k3: "they make foraging trips" (s34) relies on the subject established in s36.

### Schimel mini-story disagreements reported

- Single/two-sentence paragraphs cannot carry a full arc: b3, c2, c3, q1,
  q2, m1, m2, A5, R4. Author decides to merge or accept the truncated arc.
- p3 (21, 22): two parallel facts in one paragraph.
- k3: encyclopedic exposition, not an argument; roles fuzzy.
- g2: "However" (s51) was broken by topic-first order per author instruction.

## Duplicates flagged (deletion deferred to later steps)

- 54 ~ 7 + 8
- 105 ~ 35
- 57 ~ 4
- 70 ~ 55
- 23 / 24 ~ 75 ~ 77 / 78
- 90 ~ 91
- 103 reports a result inside the Introduction; flagged for the final check.