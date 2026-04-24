<!-- Supporting migrated template from `.cursor/skills/ct/skill.md`. Non-canonical. -->
# Task Decomposition

## Purpose

Turn a grounded request into an implementation-ready task package with explicit scope, affected areas, testing intent, and delivery sequencing.

## Use When

- discovery is complete enough to plan implementation
- the team needs a task package, not just a summary
- work spans multiple layers or repositories
- review and testing need to be designed before coding

## Workflow

1. Validate the request and all available pre-work.
2. Gather code and architecture context for impacted areas.
3. Write the task package with test intent before implementation details.
4. Split the work if it is too broad for one safe execution path.
5. Mark assumptions, dependencies, and blockers explicitly.

## Required Sections

- primary objective
- scope and non-goals
- impacted repos / modules / artifacts
- implementation steps
- validation or test plan
- dependencies
- risks and assumptions
- open questions

## Packaging Rules

- Prefer a complete task package in the task folder, not a single thin summary.
- Index useful supporting artifacts at the task level first.
- Promote anything into canonical framework docs only with reusable evidence.

## AIQA Constraints

- Respect current truth boundaries from `aiqa/MANIFEST.md` and `aiqa/STRUCTURE.md`.
- Do not pretend the future orchestrator / contracts layer already exists.
- If maturity is only `review-grade`, say so in the task package.
