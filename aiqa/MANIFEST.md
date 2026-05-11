# AI QA Framework Manifest

## Purpose

This framework defines a canonical foundation for AI-assisted QA, impact analysis, and regression reasoning across repositories.

## Killer Feature

The core value is cross-repo legacy impact reasoning, not simple diff listing.  
The framework must help explain likely side effects, risk surfaces, and regression vectors across historical and active code areas.

## Canonical Truth

Canonical truth lives only under `aiqa/`.

- `aiqa/` contains framework definitions and canonical documentation.
- `.cursor/` and `.claude/` are generated adapter layers, not source of truth.
- External/reference repositories are inspiration or diagnostics, not production dependencies.

## Implementation Status

**Implemented (canonical layer + adapters):**
- Canonical foundation: `aiqa/MANIFEST.md`, `aiqa/STRUCTURE.md`, `aiqa/task-schema.yaml`, `aiqa/repo-index.yaml`, `aiqa/impact-map.yaml`, `aiqa/docs/policies/`
- Skills catalog: `aiqa/skills-catalog/*.yaml` — 8 skill specs
- Agent bindings: `aiqa/agents/agents.yaml`
- Runtime adapters: `.cursor/skills/` and `.claude/skills/` (generated from canonical; see `aiqa/scripts/generate_skills.py`)
- Artifact maturity policy and secrets policy

**Not yet implemented (design phase only):**
- Task Carrier / Task Bundle runtime pipeline (see `aiqa/docs/knowledge/DEV_ONBOARDING.md` — pilot design)
- Orchestrator logic and script automation for the full pipeline
- CI-wired enforcement of impact map gates (map is validation-backed, not automation-grade)
- Speculative artifacts not required by the approved foundation plan

**Quick activation:** Read `aiqa/QUICK_START.md` first.

## Implementation Order

1. Establish canonical foundation files and folder boundaries under `aiqa/`. ✓ Done
2. Define and stabilize canonical indexing artifacts (`repo-index.yaml`, `impact-map.yaml`). ✓ Done
3. Build skills catalog and generate runtime adapters. ✓ Done
4. Add deterministic pipeline logic and CI wiring. → Next phase
