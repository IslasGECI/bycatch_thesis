# Phase 1: Paragraph Blueprint (in place)

## Input
The `##` and `###` headings and their prose in `13_methods.md` (the refactored outline).

## Output
`13_methods.md` annotated in place: sentences reordered and grouped into paragraph clusters, each sentence positioned by role, and missing elements marked with `[[ instruction for the author ]]`.

## Rules
- You may move sentences freely across `###` (level 3) headings within the same `##` (level 2) heading.
- You may move sentences across `##` (level 2) headings only in Step 6 (verify flow).
- Existing `[[ ... ]]` placeholders are kept verbatim but moved to the correct paragraph and position.

## Actions (applied to each `##` section, then to subsections within it)

### Step 1 — Identify main ideas
Read every sentence under the heading. List the distinct main ideas present. Each main idea will become one paragraph.

### Step 2 — Group sentences by main idea
Assign each sentence to one main idea. Move sentences so they are contiguous with their group. Each group of contiguous sentences is one future paragraph.

### Step 3 — Classify each sentence by role
Within each group, label every sentence as one of:
- Topic — states the purpose of the paragraph.
- Evidence — provides facts, examples, citations, observations, or analyses that support the topic.
- Explanation — connects the evidence to the topic and explains how the evidence supports it.
- Link — transitions from this paragraph to the next.

### Step 4 — Sort within each paragraph
Reorder sentences within each group: Topic → Evidence → Explanation → Link.
If a role is missing from the group, leave a gap at that position.

### Step 5 — Insert placeholders for missing content
At each gap (missing role), insert `[[ instruction for the author describing what to write ]]`.

### Step 6 — Verify logical flow
1. Read each paragraph: does the Topic → Evidence → Explanation → Link sequence make sense?
2. Read across paragraphs within the subsection: does the order of paragraphs tell a coherent story?
3. Read across `##` sections: does the overall flow of the Methods section work? If not, move sentences across `##` boundaries now.
4. Read the entire `13_methods.md` file for global coherence.

# Phase 2: Draft
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
