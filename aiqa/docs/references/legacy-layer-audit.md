# Legacy AI Layer Audit (Draft)

## Scope

- Repository scope audited: `D:/DevReps`
- Folders audited only: `.claude/`, `.cursor/`, `_aux/`
- Audit mode: inventory-only (no migration, no deletion, no rewrites)

## Short Summary

- In audited scope, only `.claude/skills/**` and `.cursor/skills/**` are present; `_aux/` is missing at repo root.
- No `hooks.json`, no `.cursor/rules/**`, and no root `scripts/` folder were found in `D:/DevReps`.
- Skill files are largely mirrored between `.claude` and `.cursor`, suggesting adapter/wrapper layering.
- Multiple docs mention hook/sync automation (`hooks.json`, `scripts/sync-*.js`), but these artifacts are not present in this audited scope.

## Critical Findings

- **CRITICAL:** `/.claude/skills/README.md` and `/.cursor/skills/README.md` define the active command/skill workflow surface (`/nf`, `/ct`, `/si`, `/qa`, `/sr`, etc.). Deletion is unsafe.
- **CRITICAL:** All files under `/.claude/skills/**/skill.md` and `/.cursor/skills/**/skill.md` may directly affect generation behavior and task routing.
- **CRITICAL:** Documentation references to hook/sync behavior exist, but concrete hook/sync artifacts are absent in this scope. This is a governance/integrity risk, not a deletion signal.

## Audit Table

| Path | Type | Purpose | Still used? | Referenced from | Truth or wrapper? | Reusable or task-specific? | Proposed action | Confidence | Notes |
|------|------|---------|-------------|-----------------|-------------------|----------------------------|-----------------|------------|-------|
| `.claude/` | folder | Legacy Claude-facing AI layer | yes | `.claude/skills/README.md`, `everything/docs`, `detailed-repositories-index.md` | truth-candidate | reusable | keep-adapter | high | **CRITICAL**: repo-wide AI behavior surface. |
| `.cursor/` | folder | Cursor-facing AI adapter layer | yes | `.cursor/skills/README.md`, `everything/docs`, `deep-research-report-AI-TOOLS.md` | wrapper-candidate | reusable | keep-adapter | high | **CRITICAL**: likely runtime adapter for IDE agent behavior. |
| `_aux/` | folder | Auxiliary artifacts (expected legacy temp/docs/scripts) | no (missing) | none found in audited scope | unknown | unknown | unknown | high | Not present at `D:/DevReps/_aux`. |
| `.claude/hooks.json` | hook/config | Hook entrypoint for sync automation | unknown | Mentioned in `detailed-repositories-index.md` and `everything/docs` only | wrapper | reusable | unknown | medium | File not found in audited scope; **CRITICAL if appears later**. |
| `.cursor/hooks.json` | hook/config | Hook entrypoint for Cursor-side sync | unknown | Mentioned in `everything/docs` and `deep-research-report-AI-TOOLS.md` | wrapper | reusable | unknown | medium | File not found in audited scope; **CRITICAL if appears later**. |
| `.cursor/rules/...` | rule | Tool-specific rules | unknown | Mentioned in `everything/docs` only | wrapper or truth-candidate | reusable | unknown | low | Folder/files not found in audited scope. |
| `.claude/skills/README.md` | skills-index | Canonical skill catalog + workflow map | yes | self, mirrored by `.cursor/skills/README.md` | truth-candidate | reusable | keep-adapter | high | **CRITICAL**: references command workflow and agent coupling. |
| `.cursor/skills/README.md` | skills-index | Cursor mirror of skills catalog | yes | self + references to `.claude` agent path | wrapper | reusable | keep-adapter | high | **CRITICAL**: operational adapter/documented entrypoint. |
| `.claude/skills/skill-creator/skill.md` | prompt/skill | Skill authoring workflow and structure rules | yes | `.claude/skills/README.md`, `.cursor/skills/skill-creator/skill.md` | truth-candidate | reusable | keep-adapter | high | **CRITICAL**: affects future skill generation conventions. |
| `.cursor/skills/skill-creator/skill.md` | prompt/skill | Cursor copy of skill-authoring workflow | yes | `.cursor/skills/README.md` | wrapper | reusable | keep-adapter | high | **CRITICAL**: runtime copy; do not delete blindly. |
| `.claude/skills/udoc/skill.md` | prompt/skill | Doc/changelog update workflow; references sync scripts | yes | `.claude/skills/README.md` | truth-candidate | reusable | keep-adapter | medium | **CRITICAL**: contains sync expectations (`scripts/sync-docs.js`). |
| `.cursor/skills/udoc/skill.md` | prompt/skill | Cursor copy of docs workflow skill | yes | `.cursor/skills/README.md` | wrapper | reusable | keep-adapter | medium | **CRITICAL**: same operational implications as `.claude` variant. |
| `.claude/skills/{nf,ct,si,qa,sr,parallelization,ai-settings,atlas-status-req,legit-api-token-jwt}/skill.md` | prompt/skill set | Core implementation, QA, and operational workflows | yes | `.claude/skills/README.md`, intra-skill cross-links | truth-candidate | reusable | keep-adapter | medium | **CRITICAL**: command behavior layer; classify per-file in next pass if needed. |
| `.cursor/skills/{nf,ct,si,qa,sr,parallelization,ai-settings,atlas-status-req,legit-api-token-jwt}/{skill.md|SKILL.md}` | prompt/skill set | Cursor-adapted mirror of skill set | yes | `.cursor/skills/README.md`, intra-skill cross-links | wrapper | reusable | keep-adapter | medium | **CRITICAL**: mirrored runtime behavior; mixed `skill.md`/`SKILL.md` casing should be reviewed manually. |
| `scripts/sync-configs.js` (root) | script | Config sync automation target | unknown (missing) | Mentioned in `everything/docs`, `deep-research-report-AI-TOOLS.md`, `detailed-repositories-index.md` | wrapper | reusable | unknown | medium | Not found in audited scope. |
| `scripts/sync-docs.js` (root) | script | Docs sync automation target | unknown (missing) | Mentioned in `everything/docs`, `.*/udoc/skill.md` | wrapper | reusable | unknown | medium | Not found in audited scope. |

## Files Requiring Manual Review

- `detailed-repositories-index.md` (references `.claude/hooks.json` and sync scripts not present in this scope)
- `everything/docs` (contains operational claims about hooks/sync and `.cursor/rules/`)
- `everything/AI-frame-docs/ai-framework-documentation.md` (declares sync model and canonical locations)
- `everything/AI-frame-docs/deep-research-report-AI-TOOLS.md` (architectural assumptions about hook automation)
- Cross-repo overlap check: `D:/DevReps` vs `D:/DevReps/ETNA_TRADER` for duplicated `.claude/.cursor/_aux` layers
- Case-sensitivity consistency: `SKILL.md` vs `skill.md` in `.cursor/skills/**`

## Explicit Stop Conditions

- Stop before any migration to `aiqa` contracts or structure changes.
- Stop before any delete/move/archive action in `.claude/`, `.cursor/`, or `_aux/`.
- Stop before normalizing casing, deduplicating mirrored skill files, or editing skill contents.
- Stop before creating/fixing hooks or sync scripts.
- Next step requires explicit approval for: deep per-file canonical mapping and migration plan.
