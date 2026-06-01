# Phase 1: Answer the Worksheet
Input:
    • TODO.md — the worksheet questionnaire.
        ◦ Each unchecked checkbox (with its indented sub-bullets) is one question.
        ◦ Headings in TODO.md correspond to same-named headings in `papers/first-paper/13_methods.md`.
        ◦ If a heading exists in TODO.md but not in `13_methods.md`, no questions under it have been answered yet.
        ◦ If a heading exists in `13_methods.md` but not in TODO.md, all its questions were answered and the heading was deleted from TODO.md.
        ◦ The meta-headings `## Cross-section fixes` and `## Final validation` are task-management categories, not manuscript sections.
Output:
    • `papers/first-paper/13_methods.md` — the completed worksheet.
        ◦ Answers are written as prose at the corresponding section in `13_methods.md`.
        ◦ Once a question is answered, the checkbox (and its sub-bullets, if any) is deleted from TODO.md.
        ◦ The heading remains in TODO.md until all its child checkboxes are removed.
Actions:
    1. Conduct multiple rounds, top-to-bottom through TODO.md.
    2. In each round, attempt to answer exactly one question.
       — If the question can be answered now, write the answer into `13_methods.md` at the corresponding section, then delete the checkbox (and its sub-bullets) from TODO.md.
       — If the question cannot be answered yet (e.g., a dependency is missing), skip it.
    3. Each answer must:
        a. Be a complete sentence or set of sentences.
        b. Answer both what was done and why it was done.
    4. Unit of completion:
        — Question with sub-bullets: all sub-bullets must be addressed before deleting the checkbox.
        — Question without sub-bullets: delete the checkbox once its answer is written.
    5. After finishing a round, start a new round. Continue until a complete round passes with zero questions answered.
    6. Phase 1 ends when a full round produces no answered questions, even if some TODO.md questions remain unanswered.

Turn-by-turn interaction protocol:
    a. The agent asks exactly one question from TODO.md, quoting the checkbox text as written.
    b. The user answers in English, Spanish, or Spanglish.
    c. The agent translates the answer into proper English:
        — Fix grammar and spelling only.
        — Add no words beyond what is minimally necessary to form a correct English sentence.
        — Generate no new content.
    d. The agent writes the corrected answer into the corresponding section of `papers/first-paper/13_methods.md`.
    e. The agent evaluates whether the answer actually answered the question:
        — If yes: delete the checkbox (and its sub-bullets, if any) from TODO.md.
        — If no: keep the answer in 13_methods.md anyway, notify the user why it missed, and offer to commit-and-skip or try again.
    f. Commit both `TODO.md` and `13_methods.md`.
    g. Report back and offer to undo the commit or move to the next question.

# Phase 2: Build Outline
Input:
    • `13_methods.md` with answers from the worksheet.
Output:
    • A hierarchical outline with `##` and `###` manuscript headings.
Actions:
    1. Write all standard headings (L2 and L3) from the Reference list into `13_methods.md`, alongside the existing worksheet headings.
    2. For each answer, decide which standard heading it best belongs under and move it there. Place answers under the most specific matching L3; if no L3 matches, place directly under the L2.
    3. After all answers are moved, delete every heading that has no content under it — both worksheet headings that lost their answers and standard headings that received none.
    4. Order surviving headings in the standard sequence. Within each L2, order surviving L3 sub-subsections logically.
Rules:
    1. Every answer belongs under exactly one heading.
    2. No duplication — each answer appears once in the outline.
    3. An L3 heading must always have a parent L2 heading.
    4. A heading survives only if it has at least one answer beneath it.
Reference — standard headings for Methods sections:

```
## Study Area / Study System / Site Description
### Climate, topography, land use, oceanographic context
### Geographic location and coordinates
### Habitat characteristics and environmental conditions
### Justification for site selection

## Study Species / Organism Information
### Target species identification
### Selection criteria / source of individuals
### Handling procedures

## Materials

## Experimental Design
### Overall approach (observational, experimental, comparative)
### Sampling design (randomized, stratified, systematic, opportunistic)
### Sampling units
### Temporal and spatial scale
### Temporal scope (duration, seasons, frequency)

## Data Collection / Field Methods
### Equipment and tools used
### Measured variables
### Observational procedures / protocols
### Sample sizes
### Sampling techniques
### Specific field methods and protocols
### Timing, preservation, and processing steps

## Data Analysis
### Derivation of secondary variables
### Filtering, cleaning, smoothing, outlier removal
### Interpolation and resampling
### Preprocessing and transformations
### Treatment of missing values

## Ethical Considerations / Permits / Approvals
### Animal care protocols
### Collection permits and site permissions
### Ethical approval numbers
### Institutional approvals

## Measurements and Variables
### Predictor / explanatory / independent variables
### Response / dependent variables
### Units of measurement

## Statistical Analysis / Modeling
### Definitions of key analytical terms
### Model specification
### Parameter selection
### Software packages and versions
```

# Phase 3: Review Flow
Input:
    • Initial hierarchical outline.
Output:
    • Reordered outline with logical flow.
Actions:
    1. Verify that information flows in the standard order:
         Materials → Experimental design → Data analysis
    2. Within Materials, review subsection order (e.g., site before species, species before data collection).
    3. Within Experimental design, review order (questions before supporting methodology).
    4. Within Data analysis, review order (processing before analyses, assumptions last).
    5. Reorder headings as needed. Update indentation to reflect new parent-child relationships.
Rule:
    1. Reordering changes sequence only — it does not split or merge sections.

# Phase 4: Refactor the Outline
Input:
    • Reordered outline.
Output:
    • Refactored outline with section boundaries adjusted.
Actions:
    1. Split: if an L2 subsection contains too many distinct topics, promote some L3s to new L2s.
    2. Merge: if two L2 subsections are too thin, merge them under one L2.
    3. Promote: if an L3 has grown to deserve its own L2 subsection, change `###` to `##`.
    4. Demote: if an L2 is a single narrow topic, change `##` to `###` and nest it under a broader L2.
    5. Rename: adjust heading names to be more precise.
    6. Remove structural artifacts introduced during Phase 2 (e.g., placeholder headings that survived the cleanup).
    7. Allow the final section structure — the one particular to your paper — to emerge from the content.

# Phase 5: Design Paragraphs
Input:
    • Refactored outline with content under each heading.
Output:
    • Paragraph-level blueprint for each subsection.
Actions:
    1. Within each heading, read the responses assigned to it.
    2. Identify the main ideas in those responses.
    3. Identify information that supports each main idea.
    4. Decide paragraph boundaries:
        — One main idea per paragraph.
        — Separate main ideas go into separate paragraphs.
    5. For each paragraph, plan:
        a. Topic sentence — states the purpose of the paragraph.
        b. Supporting sentences — develop the topic sentence.
        c. Transition sentence — connects to the next paragraph.
    6. Plan transitions between adjacent paragraphs and between subsections.

# Phase 6: Draft
Input:
    • Paragraph-level blueprint.
Output:
    • Methods section prose in `13_methods.md`.
Actions:
    1. Write the topic sentence that states the paragraph's purpose.
    2. Write supporting sentences below the idea they support.
    3. Keep main ideas in separate paragraphs. Do not worry if paragraphs are only 1–2 sentences.
    4. After each subsection, review:
        — Is each main idea in its own paragraph?
        — Have all supporting sentences been assigned to a paragraph?
        — Does the logical flow between paragraphs work?
    5. Rearrange paragraphs within a subsection if the flow is wrong.
    6. Add missing information to ensure each main idea is fully supported.
    7. Write without editing — get everything on the page first.
    8. After all subsections are drafted:
        — Eliminate redundancy.
        — Introduce analyses by name, not by Objective or heading.
        — Ensure every method explains both what was done and why.
