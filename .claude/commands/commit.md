---
name: commit
description: Create clean local git commits with safe staging and clear conventional messages. Use when user asks "/commit", "сделай коммит", "commit changes", or wants to package current work into one or more commits.
argument-hint: "[optional intent, e.g. fix pipeline vars]"
user-invocable: true
---

# Commit Changes — Safe Workflow

## PRIMARY OBJECTIVE

Create a reliable local commit that matches repository style and includes only relevant changes.

## CONSTRAINTS

- Do not commit unless user explicitly requested commit action.
- Do not push unless user explicitly requested push.
- Do not change git config.
- Do not include secrets (`.env`, tokens, credentials, private keys).
- Do not use destructive git commands.

## WORKFLOW

### STEP 1: Inspect repository state

Run and review:

```bash
git status --short --branch
git diff --stat
git diff
git log --oneline -n 10
```

If there are no changes, stop and report "nothing to commit".

### STEP 2: Define commit scope

If user provided a scope/intent, stage only matching files.
If not provided, stage all relevant tracked/untracked files except obvious generated junk and secrets.

Never include unrelated large refactors in the same commit.

### STEP 3: Validate before commit

Run quick checks relevant to changed area when obvious:
- Python: targeted pytest or at least syntax check for changed scripts
- Frontend: lint/typecheck for changed package
- Docs-only change: no tests required
- If repo has pre-commit configured: run `pre-commit run --files <staged-files>` before `git commit`

If checks fail, fix or report clearly before committing.

### STEP 4: Build commit message

Follow conventional style:

- `feat(scope): ...` for new behavior
- `fix(scope): ...` for bug fix
- `refactor(scope): ...` for internal restructure
- `docs(scope): ...` for documentation only
- `test(scope): ...` for tests only
- `chore(scope): ...` for maintenance

Message rules:
- Subject in imperative mood, <= 72 chars when possible
- Body explains why and impact (1-3 bullets or short paragraph)

### STEP 5: Commit

Use explicit staging and commit:

```bash
git add <files>
git commit -m "<type(scope): subject>" -m "<why/impact>"
git status --short --branch
```

Pre-commit hooks run automatically during `git commit`.
If hooks modify files, stage updates and re-run commit.

## OUTPUT FORMAT TO USER

Always report:
- Commit hash and title
- Files included
- Checks run and result
- Whether push is pending

Template:

```text
Committed: <hash> <title>
Files: <n> changed (<key paths>)
Checks: <what was run> -> <pass/fail>
Push: not performed
```
