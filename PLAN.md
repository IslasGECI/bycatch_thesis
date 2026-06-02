# Phase 1: Paragraph Blueprint (in place)

## Input The `##` and `###` headings and their prose in `13_methods.md` (the refactored outline).

## Output `13_methods.md` annotated in place: sentences reordered and grouped into paragraph clusters, each sentence positioned by role, and missing elements marked with `[[ instruction for the author ]]`.

## Rules
- You may move sentences freely across `###` (level 3) headings within the same `##` (level 2) heading.
- You may move sentences across `##` (level 2) headings only in Step 6 (verify flow).
- Existing `[[ ...
  ]]` placeholders are kept verbatim but moved to the correct paragraph and position.

## Actions (applied to each `##` section, then to subsections within it)

### Step 1 — Identify main ideas Read every sentence under the heading.
List the distinct main ideas present.
Each main idea will become one paragraph.

### Step 2 — Group sentences by main idea Assign each sentence to one main idea.
Move sentences so they are contiguous with their group.
Each group of contiguous sentences is one future paragraph.

### Step 3 — Classify each sentence by role Within each group, label every sentence as one of:
- Topic — states the purpose of the paragraph.
- Evidence — provides facts, examples, citations, observations, or analyses that support the topic.
- Explanation — connects the evidence to the topic and explains how the evidence supports it.
- Link — transitions from this paragraph to the next.

### Step 4 — Sort within each paragraph Reorder sentences within each group: Topic → Evidence → Explanation → Link.
If a role is missing from the group, leave a gap at that position.

### Step 5 — Insert placeholders for missing content At each gap (missing role), insert `[[ instruction for the author describing what to write ]]`.

### Step 6 — Verify logical flow
1. Read each paragraph: does the Topic → Evidence → Explanation → Link sequence make sense?
2. Read across paragraphs within the subsection: does the order of paragraphs tell a coherent story?
3. Read across `##` sections: does the overall flow of the Methods section work?
   If not, move sentences across `##` boundaries now.
4. Read the entire `13_methods.md` file for global coherence.

# Phase 2: Replace Placeholders

## Input `13_methods.md` annotated by Phase 1: sentences reordered into paragraph groups (topic → evidence → explanation → link), each group under its heading, and missing elements marked with `[[ instruction for the author ]]`.

## Output `13_methods.md` with every `[[ placeholder ]]` replaced by prose.
Existing sentences are not modified.

## Rules
- The unit of work is one `##` section.
  Both steps below are completed for a section before moving to the next.
- Only `[[ ...
  ]]` placeholders are replaced.
  No existing sentence is rewritten, reordered, or removed.
- Content is created (drafted), not edited.
  Write the placeholder replacement as prose in a single pass.
- Phase 2 converges through repeated passes.
  After all `##` sections are processed, start again from the first section if any new `[[ placeholders ]]` were added during the previous pass.
  Stop when a full pass through every `##` section produces zero new placeholders.

## Actions (applied per `##` section per pass)

### Step 1 — Replace placeholders For each `[[ instruction ]]` under the current `##` heading, write prose that fulfills the instruction.
Replace the entire `[[ ...
]]` bracket, including the brackets, with the written sentence or sentences.

### Step 2 — Verify what and why Read every method described in the section (both the original sentences and the newly written replacements).
For each one, evaluate:
- Does it explain what was done?
- Does it explain why it was done?

If a method is missing the what or the why, insert a new `[[ explain why this method was chosen ]]` (or a more specific instruction) at the appropriate position within the same paragraph.

