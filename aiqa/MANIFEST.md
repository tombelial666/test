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

## Out of Scope for This Phase

- Runtime adapter implementation
- Orchestrator logic
- Script automation
- Speculative artifacts not required by the approved foundation plan

## Implementation Order

1. Establish canonical foundation files and folder boundaries under `aiqa/`.
2. Define and stabilize canonical indexing artifacts (e.g., repo index and impact map) in later steps.
3. Add deterministic pipeline logic only after canonical data contracts are finalized.
4. Build generated runtime adapters after canonical layer is stable.
