# Backlog item — prompt and task-package infrastructure

**Type:** framework / infrastructure  
**Status:** planned  
**Priority:** high  
**Related note:** `aiqa/docs/knowledge/planned-task-prompt-and-task-package-infra.md`

---

## Title

Build infrastructure for prompt generation and standardized task-package creation.

## Problem

Task analysis is still too manual:

- prompts are assembled ad hoc,
- task identity can drift,
- analysis may stay only in chat instead of becoming files,
- documentation packages are not created consistently.

## Goal

Create a reusable framework layer that takes task metadata as input and helps generate:

1. analysis prompts for different task stages,
2. anti-task-drift constraints,
3. a predictable documentation bundle for the task.

## Input examples

- PBI / ticket id
- repo name
- PR number
- branch name
- task summary
- focus files / paths
- explicit out-of-scope tasks or artifact folders

## Expected outputs

- `task-summary.md`
- `changed-surface.md`
- `impact-and-regression.md`
- `open-questions.md`
- `qa-plan.md`
- `test-cases.md`

## Acceptance criteria

1. A canonical template exists for a task package and defines required files and minimum metadata.
2. A prompt template set exists for at least these stages:
   - first-pass task understanding
   - PR / diff review
   - second-pass audit
   - regression / impact analysis
   - QA plan generation
   - test-case generation
3. The flow supports explicit task identity pinning:
   - ticket id
   - repo
   - PR
   - branch
   - forbidden unrelated task ids / folders
4. The flow includes anti-task-drift rules so unrelated workspace artifacts are ignored.
5. The infrastructure can materialize a standard task package folder with stable file names.
6. Generated files explicitly distinguish:
   - code evidence
   - task text
   - inference
   - unknown
7. The first implementation slice is documented as review-grade or validation-backed only, without claiming automation-grade behavior prematurely.

## Suggested implementation slices

### Slice 1 — canonical definitions
- define task package template
- define prompt template catalog
- define required metadata fields

### Slice 2 — prompt builder
- generate prompts from task metadata
- inject truth boundaries
- inject anti-task-drift guardrails

### Slice 3 — artifact materializer
- create task folder
- write standard markdown files
- keep naming and structure stable

### Slice 4 — quality checks
- verify required files exist
- verify task id consistency across files
- detect cross-task contamination

## Non-goals

- full autonomous orchestration across all repositories
- automatic proof of business correctness for all generated conclusions
- claiming CI-grade or automation-grade maturity before explicit validation

## Definition of done for first backlog slice

- canonical planning docs exist under `aiqa/`
- one documented task-package standard is agreed
- one documented prompt set is agreed
- anti-task-drift rules are written down
- expected file bundle and naming are fixed

## Notes

This backlog item is intentionally short and implementation-oriented so it can be copied into an external tracker with minimal edits.
