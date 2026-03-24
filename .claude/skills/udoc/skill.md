---
name: udoc
description: Update documentation and generate changelog from a completed ETNA_TRADER task implementation
argument-hint: "[task-path]"
user-invocable: true
disable-model-invocation: true
---

# Update Documentation (UDOC) — ETNA_TRADER

## PRIMARY OBJECTIVE

Generate documentation updates and changelog entries from a completed task implementation in ETNA_TRADER.

## CONTEXT

Use when:
- Task implementation is complete (before or after PR/merge)
- Documentation needs updating to reflect code changes
- Changelog entry needed for the release

## WORKFLOW

### STEP 1: Resolve Task Path

1. Parse `$ARGUMENTS` for a task directory path
2. If not provided — **Ask**: "Which task to update docs for? Provide task directory path (e.g., `tasks/task-2026-03-19-feature-name/`)."
3. Validate: find `tech-decomposition-*.md` inside the task directory
4. If not found — error with available task directories under `tasks/`

### STEP 2: Update Documentation (docs-updater agent)

Call **docs-updater** agent:

```
Task: "Update documentation based on task implementation"
Prompt: "Review the task document at [TASK_DOCUMENT_PATH] and update all relevant ETNA_TRADER documentation files based on the implemented changes.

Check and update as needed:
- docs/architecture.md — if new layer patterns or services introduced
- docs/adr/ — if an Architecture Decision Record was drafted
- docs/api/ — if new endpoints or request/response shapes added
- db/README.md — if DB schema objects were added or modified
- CLAUDE.md / AGENTS.md — if top-level architecture overview changed (run node scripts/sync-docs.js --fix after)
- .claude/rules/ — if a new coding pattern was established that should be captured

Return a summary of what documentation was updated."
```

Capture the summary of documentation changes.

### STEP 3: Generate Changelog (changelog-generator agent)

Call **changelog-generator** agent:

```
Task: "Generate changelog entry for completed task"
Prompt: "Generate a changelog entry based on the task document at [TASK_DOCUMENT_PATH] and documentation updates: [DOCS_UPDATES_SUMMARY].

Include:
- The main feature or fix implemented
- Any API endpoint changes (new routes, modified request/response shapes)
- Any DB schema changes
- Any documentation changes

Use ETNA_TRADER path conventions:
- Backend: src/Etna.Trader.*, src/Etna.Trading.*, src/Etna.Common.*
- Tests: qa/<Project>.Tests/
- Frontend: frontend/ACAT/src/features/
- DB: db/Etna.Trader.Database/"
```

Capture the changelog entry.

### STEP 4: Commit (Optional)

1. Show user what changed:
   - `git diff --stat` for modified files
   - Brief summary from both agents
2. **Ask**: "Commit these documentation and changelog updates?"
3. If approved:
   ```bash
   git add docs/ db/README.md CLAUDE.md AGENTS.md
   git commit -m "docs: update documentation and changelog for [feature]"
   ```
4. If on a feature branch, ask whether to push

### STEP 5: Summary

Report to user:

```
Documentation updated!

**Docs**: [list of updated files]
**Changelog**: docs/changelogs/YYYY-MM-DD/changelog.md
**Committed**: Yes/No
```

## ERROR HANDLING

- **Task not found**: List available task directories under `tasks/`
- **No changes detected**: Inform user, suggest checking if docs are already up to date
- **Agent fails**: Report which agent failed, suggest running manually
- **sync-docs.js fails**: Verify `scripts/sync-docs.js` exists; if not, manually ensure CLAUDE.md and AGENTS.md are identical

## SUCCESS CRITERIA

- [ ] Task document found and analyzed
- [ ] Documentation updated for affected files
- [ ] Changelog entry created in `docs/changelogs/YYYY-MM-DD/`
- [ ] User informed of all changes
- [ ] Changes committed only with user approval
