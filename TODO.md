# Issue #12: 📝 Escribir la sección de Métodos

Podemos empezar a escribir el primer borrador de la sección de:

- [Métodos](https://github.com/IslasGECI/bycatch_thesis/blob/develop/13_methods.md)

## Materials

### Site description

#### Guadalupe Island

#### Feeding areas

#### Time period

### Study species or system

### Ethical considerations and permits

- [ ] Required: specify permit IDs or agencies more precisely

### Data collection

- [ ] Clarify:
    - deployment protocol (duration, recovery)

## Experimental design

### Specific questions

#### Core areas used by Laysan albatrosses

#### Overlap of core areas with ANPs

- [ ] Define units:
    - proportion of area?
    - proportion of UD?
- [ ] Explain ecological meaning of overlap
- [ ] Justify why this metric answers your second question

### Studies that support your methodology

- [ ] Expand beyond a single citation
- [ ] Explain:
    - what part of the method comes from track2KBA
- [ ] Describe:
    - how your implementation follows or deviates from it
- [ ] Cite KDE foundational methods if needed

## Data analysis

### Data processing

- [ ] Describe full preprocessing pipeline:
    - filtering steps:
      - near-colony points (if removed)
      - incomplete trips
- [ ] Describe temporal handling:
    - resampling or consistency checks
- [ ] Specify **projection**
    - equal-area CRS used for KDE
- [ ] Explain handling of:
    - multi-year data
    - unequal sampling effort
- [ ] Explicitly list track2KBA steps used:
    - tripSplit (if used)
    - projectTracks
    - estSpaceUse
- [ ] Ensure consistency with Results:
    - ARS method
    - 50% UD

### Statistical analyses

- [ ] Either:
    - describe statistical tests used
    - OR explicitly state no inferential statistics were used
- [ ] Justify choice:
    - why spatial metrics are sufficient (if applicable)

### Limitations and assumptions

- [ ] Expand limitations:
    - spatial bias (colony-based sampling)
    - device limitations
    - temporal gaps
- [ ] Add **methodological assumptions**:
    - KDE assumptions (smoothing, independence)
    - representativeness assumptions
- [ ] Explain how limitations affect interpretation

## Cross-section fixes (apply across multiple sections)

- [ ] Add **“why” statements** at the beginning of each subsection
- [ ] Ensure all methods in Results are described in Methods:
    - ARS
    - representativeness
    - potential sites
- [ ] Remove fishing-related language (title and text)
- [ ] Fix inconsistencies:
    - number of individuals
- [ ] Ensure consistency in number of individuals (align with Experimental design)
- [ ] Ensure reproducibility:
    - all parameters specified
    - all steps described
- [ ] Fix missing information:
    - replace "XXX"

## Final validation (after edits)

- [ ] Can a reader reproduce KDE?
- [ ] Can a reader reproduce overlap index?
- [ ] Are all parameters defined?
- [ ] Does every subsection answer both:
    - what was done
    - why it was done?
