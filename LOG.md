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

## Step 4 — verify logical flow within paragraphs

### Placeholders created (Step 4)

`[[ ]]` note inserted in p1 after the dangling subject:

- p1: [[ This group lacks an antecedent; name the group before this sentence. ]]

Remaining broken connectors (A2 "We also", R2 "Also, it", k3 "they") carry no
in-text note yet; awaiting the one-at-a-time resolution order.

Step 4 broken-connector notes placed:

- p1: [[ This group lacks an antecedent; name the group before this sentence. ]]
- A2: [[ We also dangles after the preceding "This study" sentence; rephrase or merge with it. ]]
- R2: [[ Also, it dangles after the paragraph opener and duplicates the 30x30 mention; revise. ]]
- k3: no note needed — after the s36-first reorder, "they" (s34) has the
  albatrosses of s36 as antecedent; the connector resolved itself.
- p3: kept as one paragraph (both facts name institutional actors over the
  species); split deferred to the final cross-section sweep.

Step 4 deferred items (moved to the final cross-section check):

- b1: topic sentence restates the two evidence stats (duplicate 54 ~ 7 + 8).
- b2: two near-identical umbrella statements in one paragraph.
- k3: paragraph closes on encyclopedic biology facts; explanation role is
  covered by the [[ ]] prompt at the paragraph end.

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

## Final check — logical flow across paragraphs

Section arc: Opening -> Challenge -> Policy -> Question -> Concepts -> Method ->
Gap restated -> Action -> Resolution. Story, not chronology; funnel
general -> specific; no ordering defect found beyond the issues below.

### Issue 1 — the Challenge is asserted twice (resolved: keep both)

- Challenge (lines 25-32) states the general gap; Gap restated (lines 94-98)
  narrows it to the Laysan albatross / Mexican Pacific before Action.
- Decision A: keep both as the deliberate general -> specific funnel.
- Registered duplicate: line 95 ~ line 25 ("It is unknown to what extent the
  Mexican protected areas cover the Laysan albatross core area" duplicates
  "whether these areas are protected by existing MPAs") — for the deletion sweep.

### Issue 2 — Resolution pre-states the result (resolved: intentional foreshadowing)

- Line 156 reads as a finding ("Our results suggest that the existing protected
  areas do not adequately cover...") and duplicates the hypothesis (132-133).
- Author confirms this is deliberate foreshadowing. Keep as-is; the lexical
  overlap with the hypothesis is accepted. No duplicate registered.
- Note for the author: if the wording is revised, keeping it in expect/foreshadow
  tense preserves the intent.

### Issue 3 — repeated "This study..." openers (resolved: keep + flag)

- Six sentences open with "This study" (107, 108, 113, 137, 138, 149) plus two
  mid-sentence (125, 126).
- Registered near-duplicate for rephrase sweep: line 138 ~ line 149 ("This study
  provides empirical evidence..." ~ "This study provides the scientific base...").
- Registered overlap: line 113 novelty claim ~ lines 107-109.
- Not deleted: line 149 carries the antecedent for "the results" at line 150.

### Issue 4 — umbrella-species idea recurs across four subsections (resolved: keep + flag)

- Asserted Opening b2 (10-12), defined Concepts (60), re-applied Method (89-90),
  re-applied hypothesis (133), echoed Resolution (138).
- Registered rephrase candidate: lines 89-90 ~ line 133.
- b2 double-assertion already deferred from Step 4.

### Issue 5 — missing main idea: empty audience paragraph (resolved: delete)

- Decision B: deleted the comment-only audience placeholder (former lines 21-22).
- The audience ("who cares") main idea is now absent from the section; the author
  must re-add it as prose if wanted.

### Issue 6 — OCAR at section scale (resolved: accept)

- Opening supplies O; Challenge + Gap restated supply C; Question, Concepts,
  Method, Action supply A; Resolution supplies R (complete).
- Decision A: accept the what-we-ask -> what-we-mean -> how-we-measure ->
  what-we-do ladder. Action is the heaviest cluster by design.
- Outstanding: the section's Challenge still cannot be given as a single
  <=15-word statement (already logged as a Step 1 gap); author work.

### Final check — result

- Story, not data chronology; funnel general -> specific is intact.
- No ordering defect beyond the issues above.
- Deletion/rephrase sweep now holds: line 95 ~ 25; lines 138 ~ 149; lines 113 ~
  107-109; lines 89-90 ~ 133; plus the Step 4 deferred b1/b2 and the b2 double
  assertion.
- Structural change made this phase: deleted the empty audience placeholder.
- Phase complete.