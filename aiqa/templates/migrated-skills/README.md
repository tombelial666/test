<!-- Supporting migrated templates from legacy `.cursor/skills`. Non-canonical. -->
# Migrated Skills for AIQA

These files capture the most reusable workflow ideas from the legacy `.cursor/skills` layer and relocate them into `aiqa/` as framework-side templates.

## Status

- These files are **supporting templates**, not live runtime adapters.
- They do **not** replace `aiqa/MANIFEST.md`, `aiqa/STRUCTURE.md`, or current canonical contracts.
- They are intended to preserve useful workflow logic while the future contract/agent layer is still not implemented.

## Selected Skills

| Migrated template | Legacy source | Why kept |
|---|---|---|
| `delivery-quality.md` | `.cursor/skills/ai-settings/skill.md` | Strong reusable quality gate logic for release notes, AC, style, tests, and readiness. |
| `feature-discovery.md` | `.cursor/skills/nf/skill.md` | Good intake/discovery structure for shaping work before decomposition. |
| `task-decomposition.md` | `.cursor/skills/ct/skill.md` | Useful task-first planning and implementation package structure. |
| `qa-workflow.md` | `.cursor/skills/qa/skill.md` | Reusable QA artifact workflow for plans, test cases, coverage, and automation intent. |
| `review-workflow.md` | `.cursor/skills/sr/skill.md` | Valuable multi-pass review structure and decision logic. |
| `parallel-execution.md` | `.cursor/skills/parallelization/skill.md` | Good safety rules for splitting independent work. |
| `docs-update.md` | `.cursor/skills/udoc/skill.md` | Useful post-change documentation sync pattern. |

## Not Migrated

These were intentionally left in the legacy adapter layer for now:

- `si`: too implementation-heavy and repo-runtime-specific for the current `aiqa` foundation layer.
- `skill-creator`: already covered by built-in/system skills.
- `atlas-status-req`, `legit-api-token-jwt`, `pub-api`, `clearing-system-actions`: operational/domain-specific skills that should stay close to their active execution contexts unless they are later promoted with explicit framework scope.

## Recommended Use

Use these templates as:

- input for future `contracts/skills/` work
- reference when creating new framework-native prompts
- source material for role prompts such as `Team_Lead.md`
