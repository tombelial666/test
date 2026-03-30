# Planned task — prompt and task-package infrastructure

**Status:** planned  
**Maturity:** review-grade planning note  
**Purpose:** capture a concrete next-step item in framework documentation so it does not stay only in chat context.

---

## Goal

Build infrastructure for **repeatable task templates** and **prompt generation workflows** that help engineers:

1. take a task input (for example PBI / bug / PR / branch / repo context),
2. run a structured analysis of the task,
3. and materialize a standard documentation bundle for the task.

This infrastructure is intended to reduce ad-hoc prompt writing and make task analysis more reproducible.

---

## Problem this planned task addresses

Today, useful task packages can be produced, but the process is still too manual:

- prompts are assembled ad hoc,
- task identity can drift if the workflow is not pinned tightly,
- documentation bundles are not always generated automatically,
- different tasks may end up with different artifact quality or layout.

The framework should provide a more stable path from **task input** -> **analysis prompts** -> **standardized task package**.

---

## Planned infrastructure scope

The planned infrastructure should support:

- **task identity pinning**
  - fixed PBI / repo / PR / branch / file focus
  - explicit out-of-scope task ids or artifact folders

- **prompt generation for task analysis**
  - first-pass task understanding
  - PR / diff review
  - second-pass audit / contradiction finding
  - regression and impact analysis
  - QA plan generation
  - test-case generation

- **standard task package generation**
  - `task-summary.md`
  - `changed-surface.md`
  - `impact-and-regression.md`
  - `open-questions.md`
  - `qa-plan.md`
  - `test-cases.md`

- **repeatable output rules**
  - stable folder naming
  - stable file naming
  - explicit trust boundaries (`code evidence`, `task text`, `inference`, `unknown`)
  - consistent evidence-first wording

- **anti-task-drift safeguards**
  - do not auto-switch tasks from unrelated workspace artifacts
  - explicit rejection of out-of-scope PBI folders
  - task confirmation block before deep analysis

---

## Expected outcome

After this planned work, the framework should make it easier to:

- generate the right prompts for task decomposition,
- reuse the same prompt skeleton for similar engineering and QA tasks,
- automatically create a coherent task folder with predictable documents,
- reduce confusion between chat-only analysis and file-based task artifacts.

---

## Suggested implementation direction

Possible implementation slices:

1. **canonical template definitions** under `aiqa/`
   - task package schema
   - prompt templates by stage
   - required metadata fields

2. **task carrier / prompt builder**
   - assemble prompts from task metadata
   - inject repository truth boundaries
   - inject anti-task-drift constraints

3. **artifact materializer**
   - create task folder
   - write/update standard markdown files
   - keep stable naming and structure

4. **quality gates**
   - ensure required files exist
   - ensure task id consistency across files
   - ensure prohibited cross-task contamination is flagged

---

## Non-goals for the first implementation slice

- full autonomous orchestration across all repos,
- automatic proof that every generated conclusion is correct,
- promotion to automation-grade without explicit validation and policy updates.

---

## Notes

This is a **planned documentation item**, not implemented framework behavior yet.

It should later be linked or folded into a broader roadmap item once the team decides where the formal backlog of planned framework tasks will live.
