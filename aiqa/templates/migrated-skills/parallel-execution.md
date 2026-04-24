<!-- Supporting migrated template from `.cursor/skills/parallelization/skill.md`. Non-canonical. -->
# Parallel Execution

## Purpose

Split independent work into parallel streams without creating unnecessary merge risk.

## Use When

- work items touch separate files or domains
- outputs can be merged by one orchestrating owner
- shared task docs can stay under a single owner

## Do Not Use When

- multiple streams must edit the same contract or shared file
- sequencing matters more than speed
- integration risk is higher than parallelism benefit

## Workflow

1. Identify independent work items.
2. Define narrow scope for each worker.
3. Keep shared task docs orchestrator-owned.
4. Merge outputs only after each worker returns a clear summary.
5. Run final validation after consolidation.

## Worker Rules

- one scoped work item per worker
- no hidden scope expansion
- no git writes unless explicitly approved
- return implementation notes, risks, and what remains

## AIQA Constraints

- Use parallelism to reduce execution time, not to hide ambiguity.
- The orchestrator remains responsible for the final task package, evidence notes, and readiness summary.
