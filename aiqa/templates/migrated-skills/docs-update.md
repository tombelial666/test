<!-- Supporting migrated template from `.cursor/skills/udoc/skill.md`. Non-canonical. -->
# Documentation Update

## Purpose

Synchronize supporting documentation after a task is implemented, reviewed, or reclassified.

## Use When

- implementation changed behavior or architecture
- task artifacts revealed reusable framework knowledge
- changelog, knowledge docs, or task summaries are stale

## Workflow

1. Resolve the task path or source artifact.
2. Read the task package and implementation summary.
3. Update only the docs that are actually affected.
4. Keep framework docs and task docs clearly separated.
5. Produce a short summary of documentation changes.

## Typical Targets

- task `README.md`
- task evidence / execution summary docs
- `aiqa/docs/knowledge/`
- `aiqa/docs/references/`
- reusable templates under `aiqa/templates/`

## AIQA Constraints

- Do not promote task-specific observations to canonical knowledge without reusable evidence.
- Preserve historical context in references or archive when it should not become framework truth.
