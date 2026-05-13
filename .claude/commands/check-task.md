---
name: check-task
description: Thin wrapper for task pre-flight checks. Use when user wants only check/analysis before commit-push-board flow.
argument-hint: "[task-id] [scope hint]"
user-invocable: true
---

# Check Task (Alias)

## PURPOSE

Run only the CHECK phase of the unified workflow.

## DELEGATION

Execute the same logic as:

`/check-commit-push-azure-task <task-id> mode=check <scope hint>`

## RESULT FORMAT

Return:
- in-scope vs out-of-scope files,
- risks and missing checks,
- recommended commit split (if needed),
- ready/not-ready decision.
