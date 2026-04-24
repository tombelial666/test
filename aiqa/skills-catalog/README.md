# Skills catalog

Canonical skill definitions live here.

## Workflow

1. Update `*.yaml` skill specs in this directory.
2. Run:
   - `python aiqa/scripts/generate_skills.py`
3. Commit generated outputs in:
   - `.cursor/skills/**`
   - `.claude/skills/**`

## Rule

- Do not edit generated adapter skills manually as a primary path.
- If emergency hotfix is applied in `.cursor/.claude`, backport the same change to this catalog immediately.
