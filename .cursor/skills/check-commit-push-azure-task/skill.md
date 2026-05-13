---
name: check-commit-push-azure-task
description: End-to-end delivery workflow for Azure task items. Use when user asks to check changes, create commit, push branch, and post/update Azure Boards task notes in one run. Supports combined or split execution modes.
argument-hint: "[task-id] [mode=all|check|commit|push|board] [scope hint]"
user-invocable: true
---

# Check + Commit + Push + Azure Task

## PRIMARY OBJECTIVE

Run a repeatable release micro-flow for a board task:
1) validate local changes,
2) create clear commit(s),
3) push branch,
4) update Azure Boards task with delivery notes.

## MODES

- `mode=all` (default): full chain check -> commit -> push -> board
- `mode=check`: only pre-flight checks and scope summary
- `mode=commit`: stage+commit only (no push)
- `mode=push`: push current branch only
- `mode=board`: only post/update Azure task comment/state

## CONSTRAINTS

- Never commit/push without explicit user request.
- Never include secrets (`.env`, private keys, raw tokens).
- Do not force push unless explicitly requested.
- Use branch-safe workflow: no destructive git commands.

## WORKFLOW

### STEP 0: Resolve context

- Detect current branch and dirty state:
  - `git status --short --branch`
- Detect task id from argument; if absent, ask once.

### STEP 1: CHECK (quality + scope)

Run:

```bash
git status --short --branch
git diff --stat
git diff
git log --oneline -n 10
```

Then:
- mark files as in-scope / out-of-scope for the task,
- suggest commit split if mixed concerns are found,
- run targeted checks for touched stack (tests/lint when obvious).

### STEP 2: COMMIT

- Stage only approved scope (or all if user said "всё").
- Commit message: conventional style with clear scope.
- If pre-commit exists, run before commit:
  - `pre-commit run --files <staged-files>`
- Execute commit and show resulting hash.

### STEP 3: PUSH

- Push current branch to tracked remote.
- If no upstream branch, use:
  - `git push -u origin <branch>`
- Return branch and remote URL.

### STEP 4: AZURE BOARD UPDATE

Post concise delivery comment in task:
- what changed (2-5 bullets),
- commit hash(es),
- branch name,
- verification evidence.

Optional state update:
- move task to agreed state (`In Progress` / `Ready for Review` / `Done`).

## OUTPUT FORMAT

Always return:

```text
Task: <id>
Mode: <mode>
Check: <pass/warn/fail>
Commit: <hash or skipped>
Push: <ok/skipped>
Board update: <ok/skipped>
Next: <single best next action>
```
