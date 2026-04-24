<!-- Supporting migrated template from `.cursor/skills/ai-settings/skill.md`. Non-canonical. -->
# Delivery Quality

## Purpose

Provide a reusable quality workflow for delivery artifacts around a change, task, branch, or review package.

## Use When

- release notes are needed
- acceptance criteria need cleanup
- task outputs need style or structure review
- test opportunities should be identified
- commit / PR / handoff readiness must be checked

## Modes

1. `RELEASE_NOTES`
2. `ACCEPTANCE_CRITERIA`
3. `REPO_STYLE_ALIGNMENT`
4. `UNIT_TEST_OPPORTUNITIES`
5. `PRE_COMMIT_CHECK`

## Default Workflow

1. Read the actual task package, diff, or changed artifacts first.
2. Separate facts from assumptions.
3. State what changed, why it matters, and what could regress.
4. Call out legacy impact and newer-code impact separately when relevant.
5. Prefer repository terminology and nearby patterns over generic advice.

## Output Shape

For each mode, return structured output that is ready to paste into a task, PR, or review doc.

### Release Notes

- change type
- affected areas
- short summary
- operational / regression note

### Acceptance Criteria

- scope
- involved components
- numbered observable criteria
- legacy impact
- newer-code impact
- open questions

### Repo Style Alignment

- observed local patterns
- deviations found
- minimal patch strategy

### Unit Test Opportunities

- highest-value quick wins
- target files / symbols
- suggested scenarios
- what is not suitable for pure unit tests

### Pre-Commit Check

- change summary
- required before commit
- ready / not ready
- why
- recommended commit message

## AIQA Constraints

- Do not claim automation that is not implemented in `aiqa/`.
- Treat `aiqa/` as canonical truth and task folders as context-specific execution evidence.
- Use artifact maturity vocabulary when judging confidence: `review-grade`, `validation-backed`, `automation-grade`.
