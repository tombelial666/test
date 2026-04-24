# Docs consistency pipeline report (2026-04-25)

## Scope

- Canonical contract inputs:
  - `aiqa/MANIFEST.md`
  - `aiqa/STRUCTURE.md`
  - `aiqa/repo-index.yaml`
  - `aiqa/impact-map.yaml`
  - `aiqa/docs/policies/artifact-maturity-policy.md`
- Reviewed corpus:
  - `aiqa/docs/**/*.md`

## Pipeline checks and results

1. **Canonical contract alignment** - PASS
   - Canonical source-of-truth boundary remains consistent: `aiqa/` is canonical; `.cursor/.claude` are adapters.
   - `repo-index.yaml` scope remains 3 repos (`ETNA_TRADER`, `ServerlessIntegrations`, `qa`).
2. **Markdown links existence** - PASS
   - Files scanned: 32 markdown files.
   - Broken local links found: 0.
3. **Stale path scan (`test/aiqa`)** - PASS
   - Matches in `aiqa/docs/**`: 0.
4. **YAML parse validation** - PASS
   - Parsed files: `repo-index.yaml`, `impact-map.yaml`, `task-schema.yaml`, and all `aiqa/skills-catalog/*.yaml`.
   - Parse errors: 0/9.
5. **Claim consistency scan** - WARN -> RESOLVED
   - Issue class: design docs could be misread as "already implemented" for Task Carrier/orchestrator.
   - Resolution: explicit status-alignment notes added to:
     - `aiqa/docs/knowledge/DEV_ONBOARDING.md`
     - `aiqa/docs/knowledge/IDE_Task_Carrier_Pipeline_V1.md`
     - `aiqa/docs/knowledge/AI_QA_Framework_V1_Architecture.md`

## Changes made in this run

- Added status-alignment disclaimers to high-risk knowledge docs to prevent contradiction with:
  - `aiqa/docs/knowledge/framework-current-state.md`
  - `aiqa/docs/policies/artifact-maturity-policy.md`

## Residual risk

- Knowledge docs still include target-state architecture and should remain labeled as non-canonical design.
- Mixed RU/EN wording across docs is a style issue, not a canonical contradiction.

## Verdict

**PASS with mitigations applied.**  
Current `aiqa` documentation set is consistent with canonical boundaries and maturity claims for practical team use.
