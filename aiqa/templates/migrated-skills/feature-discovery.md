<!-- Supporting migrated template from `.cursor/skills/nf/skill.md`. Non-canonical. -->
# Feature Discovery

## Purpose

Shape a request before decomposition by clarifying intent, scope boundaries, assumptions, risks, and success criteria.

## Use When

- the request is still fuzzy
- the team needs discovery before tasking
- requirements, constraints, or impacted areas are unclear
- a feature may touch multiple repos or workflows

## Workflow

1. Gather existing context from task docs, related notes, and nearby code.
2. Ask targeted clarifying questions instead of guessing behavior.
3. Explore impacted areas in parallel when the scope is broad.
4. Challenge assumptions once the first design picture is visible.
5. Write a discovery artifact only after the scope is grounded.

## Discovery Checklist

- problem statement is explicit
- user or business goal is identified
- in-scope and out-of-scope are separated
- success criteria are observable
- affected repos / services / modules are listed
- risks and open questions are visible

## Suggested Output

- feature summary
- business / operational context
- impacted areas
- acceptance criteria draft
- risks
- open questions
- out-of-scope

## AIQA Constraints

- Prefer task-centric reasoning over repo-centric narration.
- If framework coverage is uncertain, say so explicitly.
- Do not convert supporting knowledge into canonical truth without evidence.
