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

# Run report — Phase 2 Structural Scientific Editor (Methods)

File: papers/first-paper/13_methods.md
Sections processed: Methods (Study Area, Study Species, Study Design/Time period,
Field Methods, Data Processing, Data Analysis/Core areas/Overlap, Ethical
Considerations, Methodological Considerations).

## Sentence counts

- In: 113 prose sentences (frozen source, commit db758d6~1).
- Out: 110 prose sentences.
- Removed (3, all approved in Step 4):
  - G4 "These three islands are breeding grounds for the Laysan albatross."
    (duplicate of the Study Area opening; Issue 3, option A).
  - G5 "We can analyze the foraging trips ... covered by the existing protected
    areas." (duplicate of G6 topic; Issue 4, option A).
  - G18 "We applied this methodology to identify the core areas used by the
    Laysan albatross." (duplicate of its own topic; Issue 11, option A).

## Paragraph counts

- Original: 34 prose paragraphs.
- After the first Step 1 pass: 39 groups.
- After the Step 1 redo (consolidation, option C): 28 groups.
- Stubs removed: 11 of 12. G28 (breeding-season restriction) kept as its own
  paragraph by author decision; the methods->ethics merge was rejected.

## Completions inserted

- None (0). Closed-form completions were not required in Steps 1-4.

## Placeholders created

`[[ question ]]`: 26 created this phase; 5 pre-existing markers carried verbatim.

Carried verbatim (pre-existing):

- L20 [[ reference ]]
- L106 [[ Explain how the tape is attached. Is there a standard protocol? ]]
- L107 [[ Explanation: why was Tesa tape chosen for attaching the GPS loggers? ]]
- L122 [[ Add description of GPS used in San Benedicto ]]
- L261 [[ Add specific permit IDs or agencies if possible ]]

Created (26):

- L10 [[ How does the coverage question narrow to specific islands? ]]
- L12 [[ How does the scope and question lead into the island profiles? ]]
- L21 [[ Why do these island attributes matter for the core-area analysis? ]]
- L33 [[ Why does the Clarion profile matter for the core-area analysis? ]]
- L44 [[ Why does the San Benedicto profile matter for the core-area analysis? ]]
- L52 [[ Why is the individual trip the appropriate unit for KDE? ]]
- L58 [[ How does the long time series connect to the representativeness analysis? ]]
- L70 [[ How does grouping the years relate to the breeding-season restriction? ]]
- L81 [[ What do these deployment date ranges show? ]]
- L91 [[ How many individuals were tagged at each colony, including San Benedicto? ]]
- L95 [[ How does the tagging effort connect to the GPS devices used? ]]
- L104 [[ How does the recording frequency connect to the attachment method? ]]
- L123 [[ How do the device differences affect comparability across years and islands? ]]
- L151 [[ What should the reader see in the per-season tracking effort? ]]
- L154 [[ What do the per-season tables show about the effort split across colonies? ]]
- L160 [[ What does the trip count imply for the analysis? ]]
- L169 [[ How do these filters prepare the tracks for KDE? ]]
- L182 [[ Which function yields the core areas used later? ]]
- L186 [[ What check confirms the raw data were homogeneous? ]]
- L195 [[ Which pipeline step yields the final core-area surface? ]]
- L204 [[ How do these variables feed the identification procedure? ]]
- L213 [[ Why is representativeness assessed before fixing the core areas? ]]
- L214 [[ How does the unit of analysis carry into the pooled core-area estimate? ]]
- L224 [[ How does the pooled density connect to the representativeness check? ]]
- L240 [[ How do these variables feed the overlap index? ]]
- L251 [[ How does the index translate into the protection-coverage statement? ]]

`XXX`: L159, three occurrences (Guadalupe/Clarion/San Benedicto trip counts).
Pre-existing, retained.

## Labels proposed

28 main-idea HTML comments (structural, neutral):

- study scope, marine-coverage question, and candidate islands
- Guadalupe Island profile
- Clarion Island profile
- San Benedicto: secondary colony, low reproductive success, and the three
  breeding grounds
- tracking, trip segmentation, and KDE
- core-area/MPA target, focal colonies, and long time series
- 12-year dataset and representativeness
- breeding-season coverage and deployment window
- deployment date ranges per colony
- tagging effort and a posteriori representativeness
- GPS devices: accuracy, frequency, and attachment
- device models by year and island
- individuals tracked per season
- tracking effort concentration across colonies
- sampled individuals and trips
- track2KBA workflow and filters
- track2KBA functions used
- no resampling under uniform frequency
- pipeline summary and Beal justification
- variables: GPS locations to core areas
- core-area identification, overlap procedure, and unit of analysis
- core-area definition, KDE rationale, ARS scale
- representativeness method
- variables: core areas and MPAs to overlap index
- overlap index definition, properties, and interpretation
- permits and institutions
- no harm and capture procedure
- breeding-season-only restriction

Pre-existing structural labels retained: `**Measurements and Variables**`,
`**Analysis**`, and the `### Clarion Island` / `### San Benedicto` headings.

## Reorders applied

- Step 3: G2 coverage question (question before definition); G25 overlap index
  (calculation before source citation).
- Step 3: G4 explanation prompt to paragraph end; G5 unit prompt before the Link;
  G18 application before justification; G22 KDE rationale after the pooled
  density.
- Step 4: G20 unit-of-analysis sentence moved beside the trip-splitting step;
  G26 permit statements reordered general -> specific.
- Final check: G21 (sampled individuals and trips) moved from Data Analysis into
  Field Methods, after G14; the Field Methods closing Link retained with G21.

## Merges applied (Step 1 redo, option C)

- study scope -> coverage question
- candidate nesting islands -> coverage question
- low reproductive success -> San Benedicto profile
- three islands as breeding grounds -> San Benedicto profile (later deleted)
- tracking during the breeding season -> trip segmentation and KDE
- core-area/MPA target -> focal colonies and long time series
- breeding-season-only coverage -> deployment window
- sampling effort -> tagging effort
- GPS attachment method -> GPS accuracy and frequency
- foraging-trip unit -> core-area identification procedure
- protection-coverage interpretation -> overlap index definition

Rejected merge: breeding-season restriction -> ethics paragraph; G28 kept.

## Gaps reported (flag, don't resolve)

- OCAR Challenge: no explicit <=15-word statement in Methods; it belongs to the
  Introduction.
- OCAR Resolution: absent in Methods by design.
- Story vs chronology: Study Area profiles and the device-model list read as
  inventory rather than argument.
- Missing connectives (author work): G1 coverage -> islands; G4 Clarion
  cross-reference under the San Benedicto profile; G10 counts -> sampling design;
  G12 topic -> Guadalupe list and Guadalupe -> Clarion list; G20 overlap -> unit
  of analysis.
- Fragments (author work): Guadalupe model lines; Clarion model lines;
  "Source: Kernohan et al. (2001); White & Garrott (1990)."; institution list.
- Table-only / caption groups without a prose topic: deployment dates; track2KBA
  functions list; per-season tables.
- Single-sentence paragraph: G28 (accepted).

## Duplicates registered

- G26 near-duplicate permit statements (general requirement ~ study performed
  under permits), kept and reordered.
- G4 recap deleted (duplicate of G1).
- G5 sentence deleted (duplicate of G6).
- G18 sentence deleted (duplicate of its topic).

## Ambiguities left unresolved

- Device model entries are fragments; year spans are not full sentences.
- "the previous tables" in G21 depends on the per-season tables, now in Field
  Methods.
- Mixed present/past tense in the identification procedure, representativeness
  method, and capture procedure.

## Commits

- db758d6 Step 1 main-idea labels.
- 15e166f Step 2 grouping.
- a7ede83 Step 1 redo: consolidate to 28 groups.
- c72d347 Step 3 classify and sort.
- fe17089 Step 4 tighten and flag.

Methods phase complete.