# Phase 0: Answer the Worksheet
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
    6. Phase 0 ends when a full round produces no answered questions, even if some TODO.md questions remain unanswered.

# Phase 1: Extract
Input:
    • Completed worksheet.
Output:
    • A flat list of statements.
Actions:
    1. Collect every answer from the worksheet.
    2. Split answers into sentences where necessary.
    3. Ignore the worksheet categories from this point onward.

# Phase 2: Classify
Input:
    • List of sentences.
Output:
    • Sentences assigned to containers.
Containers:
    • Shared methods
        ◦ Study area
        ◦ Data sources
        ◦ Data preparation
    • Objective 1
    • Objective 2
    • Objective 3
    • Unassigned
Rules:
    1. Every sentence gets exactly one home.
    2. No duplication.
    3. Information shared across Objectives is promoted to Shared Methods.
    4. Information belongs where it is produced, not where it is later consumed.

# Phase 3: Build the Dependency Structure
Input:
    • Classified sentences.
Output:
    • Hierarchical outline.
Actions:
    1. Identify analyses within each Objective.
    2. Determine dependencies among analyses.
    3. Order analyses by dependency.
    4. Within each analysis, arrange information according to analytical workflow:
        ◦ Inputs
        ◦ Processing
        ◦ Models/calculations
        ◦ Outputs
        ◦ Evaluation/assumptions
Result:
    • A hierarchical outline.

# Phase 4: Refactor the Outline
Input:
    • Hierarchical outline.
Output:
    • Manuscript-oriented outline.
Actions:
    1. Review shared-methods sections.
    2. Split, merge, rename, promote, or demote sections.
    3. Allow the final section structure to emerge from the content.
    4. Remove structural artifacts introduced during classification.
Result:
    • A manuscript outline.

# Phase 5: Design Paragraphs
Input:
    • Manuscript outline.
Output:
    • Paragraph-level outline.
Actions:
    1. Decide paragraph boundaries.
    2. Decide sentence order within paragraphs.
    3. Add transitions between analyses and sections.
Result:
    • A paragraph-level blueprint.

# Phase 6: Draft
Input:
    • Paragraph-level outline.
Output:
    • Methods section prose.
Actions:
    1. Convert bullets into prose.
    2. Introduce analyses, not Objectives.
    3. Explain what was done and why each method was required.
    4. Eliminate redundancy.
