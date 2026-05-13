---
name: commit-task
description: Thin wrapper for commit-only mode in board workflow. Use when checks are done and user wants scoped commit without push.
argument-hint: "[task-id] [scope hint]"
user-invocable: true
---

# Commit Task (Alias)

## PURPOSE

Run only the COMMIT phase of the unified workflow.

## DELEGATION

Execute the same logic as:

`/check-commit-push-azure-task <task-id> mode=commit <scope hint>`

## RESULT FORMAT

Return:
- commit hash and title,
- committed files,
- checks executed,
- push status (`not performed`).
