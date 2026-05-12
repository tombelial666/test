# tasks/

Task working directories for ETNA_TRADER features, bugs, and incidents.

---

## Convention

```
tasks/
  _template/
    task.yaml               ← copy this to start a new task

  task-[YYYY-MM-DD]-[feature]/
    task.yaml               ← context for AI skills
    tech-decomposition-[feature].md    ← /ct writes this
    test-plan-[feature].md             ← /qa writes this
    test-cases-[feature].md            ← /qa writes this
    coverage-review-[feature].md       ← /qa writes this
    Code Review - [feature].md         ← /sr writes this

  rca-[YYYY-MM-DD]-[short-name]/
    task.yaml               ← context for /rca
    rca-report.md           ← /rca writes this
```

---

## Start a new task

```bash
cp -r tasks/_template tasks/task-$(date +%Y-%m-%d)-[feature-name]
```

Fill `task.yaml` — minimum required fields before running `/qa`:
- `task.id`
- `task.area`
- `intent.goal`
- `intent.done_definition` (at least 2 items)
- `scope.qa_root` (`qa/` or `ETNA_TRADER/qa/`)

---

## How AI skills use task.yaml

| Skill | Uses from task.yaml |
|---|---|
| `/qa` | `intent.done_definition`, `scope`, `context.discovered_in_dev.code_paths` |
| `/impact` | `task.touched_repos`, `context.discovered_in_dev.code_paths` |
| `/rca` | `context.qa_evidence`, `context.discovered_in_dev.hypotheses` |
| `/ai-settings` | `task.id`, `task.title` for release notes header |
| `/sr` | task directory path |

---

## Rules

- Never commit real credentials, tokens, or connection strings in task files
- Log files and SQL results: store paths, not full content if it contains PII
- `task.yaml` is context for AI — the more you fill in, the better the artifacts
