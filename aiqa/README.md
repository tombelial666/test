# AI QA framework (`aiqa/`)

Canonical foundation for AI-assisted QA, cross-repo impact reasoning, and structured task metadata for the DevReps workspace slice described in `repo-index.yaml`.

## Start here

| Document | Purpose |
|----------|---------|
| [`MANIFEST.md`](MANIFEST.md) | Purpose, canonical truth boundary, out-of-scope for this phase. |
| [`STRUCTURE.md`](STRUCTURE.md) | Layers: canonical vs adapters vs task artifacts vs reference/archive. |
| [`docs/policies/artifact-maturity-policy.md`](docs/policies/artifact-maturity-policy.md) | **review-grade** vs **validation-backed** vs **automation-grade** for Step 5 artifacts. |
| [`docs/knowledge/framework-current-state.md`](docs/knowledge/framework-current-state.md) | **Current state:** implemented vs planned, trust boundaries, MVP and next steps. |
| [`docs/knowledge/onboarding-and-troubleshooting.md`](docs/knowledge/onboarding-and-troubleshooting.md) | Workspace map, safe rules, troubleshooting (including `.claude`/`.cursor`, `everything/` archive, AMS scope). |
| [`docs/knowledge/indexing-and-impact-strategy.md`](docs/knowledge/indexing-and-impact-strategy.md) | Indexing scope, impact vs diff, ETNA strategy, AMS gating, testing validated vs planned. |

## Canonical contracts (machine-oriented)

- [`task-schema.yaml`](task-schema.yaml) — minimal task field names.
- [`repo-index.yaml`](repo-index.yaml) — in-scope repos: `ETNA_TRADER`, `ServerlessIntegrations`, `qa`.
- [`impact-map.yaml`](impact-map.yaml) — path triggers, expansion hints, structured `required_checks`.

## Evidence and history

- Step 5 assumptions: [`docs/references/step-5-assumptions.md`](docs/references/step-5-assumptions.md)
- Step 5.1 bugs: [`docs/references/bug-step5-001-inferred-repo-links.md`](docs/references/bug-step5-001-inferred-repo-links.md) … [`bug-step5-005-yaml-validation.md`](docs/references/bug-step5-005-yaml-validation.md)
- `everything/` migration: [`docs/references/everything-reclassification-execution-step-5-5b.md`](docs/references/everything-reclassification-execution-step-5-5b.md) — archive at [`archive/everything-step-5-5b/`](archive/everything-step-5-5b/)
- This documentation refresh summary: [`docs/references/foundation-chat-summary.md`](docs/references/foundation-chat-summary.md)

## Templates

- [`templates/AI_Settings.md`](templates/AI_Settings.md), [`templates/I-AM.txt`](templates/I-AM.txt) — operational prompts (non-canonical policy; see preambles in files).
