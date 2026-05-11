# AI QA Framework (`aiqa/`)

Canonical foundation for AI-assisted QA, cross-repo impact reasoning, and structured task execution across the DevReps workspace.

---

## Use the framework

**→ [`QUICK_START.md`](QUICK_START.md) — start here for daily work**

Copy-paste prompts, skill activation table, workflow entrypoints for: test plans, test cases, release notes, code review, RCA, impact analysis, automation, pre-commit checks.

**→ [`ACTIVATION_CONTRACT.md`](ACTIVATION_CONTRACT.md) — behavioral rules for AI models**

Context loading order, document trust hierarchy, what to skip, artifact quality standards, hallucination guards. Apply at the start of any framework-assisted task.

---

## Current state — what's built vs planned

**→ [`docs/knowledge/framework-current-state.md`](docs/knowledge/framework-current-state.md)**

Read this before any architecture doc. It tells you what is actually implemented today.

**Implemented:**
- Skills catalog: 8 skill specs in `aiqa/skills-catalog/`, runtime adapters in `.cursor/skills/` and `.claude/skills/`
- Agent bindings: `aiqa/agents/agents.yaml`
- Impact map with 6 rules and structured required_checks: `aiqa/impact-map.yaml`
- Canonical repo index (3 repos): `aiqa/repo-index.yaml`
- Artifact maturity policy: `aiqa/docs/policies/artifact-maturity-policy.md`
- Secrets policy: `aiqa/docs/policies/secrets-and-sensitive-config-policy.md`

**Not implemented (design phase only):**
- Task Carrier / Task Bundle runtime pipeline
- Orchestrator and CI-wired gates
- Automation-grade impact map enforcement

---

## Skills and agents

| Location | What it is |
|---|---|
| `.cursor/skills/README.md` | Full skill catalog — **start here to invoke skills in Cursor** |
| `.claude/skills/README.md` | Same catalog — **start here to invoke skills in Claude** |
| `aiqa/skills-catalog/*.yaml` | Canonical skill contracts (source of truth for adapter generation) |
| `aiqa/agents/agents.yaml` | Agent-to-suite bindings |

See `.cursor/skills/README.md` for the full skill list with invocation instructions.

---

## Canonical contracts

| File | Role |
|---|---|
| `MANIFEST.md` | Framework purpose and canonical truth boundary |
| `STRUCTURE.md` | Layer definitions: canonical / adapters / artifacts / archive |
| `task-schema.yaml` | Minimal task field names |
| `repo-index.yaml` | In-scope repos: ETNA_TRADER, ServerlessIntegrations, qa |
| `impact-map.yaml` | Path triggers, expansion hints, required_checks |

---

## Context boundaries — what to read for what

| If you need to… | Read |
|---|---|
| Do actual QA work | `QUICK_START.md` |
| Understand model behavior rules | `ACTIVATION_CONTRACT.md` |
| Know what's implemented vs planned | `docs/knowledge/framework-current-state.md` |
| Onboard to the workspace | `docs/knowledge/onboarding-and-troubleshooting.md` |
| Understand impact / indexing strategy | `docs/knowledge/indexing-and-impact-strategy.md` |
| Check trust levels of artifacts | `docs/policies/artifact-maturity-policy.md` |
| Understand framework structure theory | `MANIFEST.md`, `STRUCTURE.md` |

**Do not read by default:**
- `archive/` — historical migration bundle, not runtime guidance
- `docs/knowledge/AI_QA_Framework_V1_Architecture.md` — target-state design, not implemented system
- `docs/knowledge/IDE_Task_Carrier_Pipeline_V1.md` — pilot design doc, not running system
- `docs/references/` — step audit logs and migration plans, reference only

---

## Evidence and history

Step 5 bug records: `docs/references/bug-step5-001-*.md` through `bug-step5-005-*.md`  
Step 5.5B migration: `docs/references/everything-reclassification-execution-step-5-5b.md`  
Archive: `archive/everything-step-5-5b/` — preserved historical bundle, not canonical
