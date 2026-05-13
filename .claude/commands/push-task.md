---
name: push-task
description: Thin wrapper for push-only mode in board workflow. Use when commit already exists and branch must be pushed.
argument-hint: "[task-id]"
user-invocable: true
---

# Push Task (Alias)

## PURPOSE

Run only the PUSH phase of the unified workflow.

## DELEGATION

Execute the same logic as:

`/check-commit-push-azure-task <task-id> mode=push`

## RESULT FORMAT

Return:
- pushed branch,
- remote target,
- last pushed commit hash.
