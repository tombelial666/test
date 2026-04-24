<!-- Supporting migrated template from `.cursor/skills/sr/skill.md`. Non-canonical. -->
# Review Workflow

## Purpose

Run a structured review before merge or handoff, focusing on correctness, risks, test evidence, documentation impact, and merge readiness.

## Use When

- a task is ready for review
- a branch or PR needs a disciplined review pass
- a task package needs a review-grade conclusion

## Review Layers

1. Quality gate / basic validation
2. Approach and architecture fit
3. Security and risk review
4. Performance review when the change justifies it
5. Consolidated decision

## Workflow

1. Confirm the task has enough implementation evidence to review.
2. Reuse existing quality-gate evidence when still valid.
3. Review by concern area instead of mixing all findings together.
4. Consolidate issues into `critical`, `major`, `minor`, `info`.
5. End with a clear decision: approved, needs fixes, or blocked.

## Review Output

- reviewer note
- consolidated issues
- decision
- remaining risks
- next action

## AIQA Constraints

- Findings must be grounded in visible evidence.
- Do not claim a standing quality gate if one was not actually run.
- Distinguish framework-definition issues from task-execution issues.
