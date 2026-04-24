<!-- Supporting migrated template from `.cursor/skills/qa/skill.md`. Non-canonical. -->
# QA Workflow

## Purpose

Produce QA deliverables for a task package: test plan, test cases, coverage view, automation intent, and execution notes.

## Use When

- a task needs QA planning
- test cases must be formalized
- coverage gaps should be reviewed
- automation opportunities should be identified
- evidence needs to be packaged in the task folder

## Modes

1. Full package
2. Test cases only
3. Automation outline
4. Test architecture
5. Coverage review

## Workflow

1. Read the task package and available requirements first.
2. Identify the requested QA mode.
3. Reuse existing repo and test patterns before inventing new structure.
4. Keep traceability from requirement to test artifact.
5. Save outputs inside the task folder.

## Quality Checks

- every test case maps to a requirement or acceptance criterion
- expected results are observable
- negative cases are present where risk warrants them
- open questions are explicit
- any pseudocode is clearly marked

## Typical Outputs

- `qa-plan.md`
- `test-cases.md`
- `coverage-review.md`
- `test-architecture.md`
- `test-execution-summary.md`

## AIQA Constraints

- Be honest about what is planned vs actually executed.
- Separate proposed automation from tested automation.
- Keep evidence in the task folder unless there is a clear reason to promote it.
