---
name: board-update
description: Thin wrapper for Azure Boards update-only mode. Use when code is already pushed and task comment/state must be updated.
argument-hint: "[task-id] [state optional]"
user-invocable: true
---

# Board Update (Alias)

## PURPOSE

Run only the BOARD UPDATE phase of the unified workflow.

## DELEGATION

Execute the same logic as:

`/check-commit-push-azure-task <task-id> mode=board [state]`

## RESULT FORMAT

Return:
- task id,
- comment summary posted,
- state change result (if requested),
- linkability status to branch/commit.
