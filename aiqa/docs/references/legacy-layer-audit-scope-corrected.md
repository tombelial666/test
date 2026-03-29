# Legacy AI Layer Audit (Scope-Corrected)

## Actual Audited Root Path

- Audited root: `D:/DevReps/ETNA_TRADER`
- Audit mode: inventory-only
- No cleanup, migration, archive moves, or rewrites were allowed

## Tree Snapshot Summary

- `.claude/`: about 49 files
- `.cursor/`: about 49 files
- `_aux/`: one file (`BuildAll.bat`)
- `scripts/`: 3 files

## Critical Artifacts Found

- `.claude/hooks.json`
- `.cursor/hooks.json`
- synchronization scripts under `scripts/`
- mirrored rules and skills under `.claude/` and `.cursor/`
- `FRAMEWORK_INDEX.md`

## Mismatch Table

| Artifact mentioned in docs | Actually present? | Observed reality | Mismatch type | Severity | Notes |
|---|---|---|---|---|---|
| `_ai-tools-export/` | no | Not found at expected ETNA_TRADER root location | CRITICAL MISMATCH | critical | Mentioned by framework docs but not aligned with current root layout |
| hooks path from `FRAMEWORK_INDEX.md` | partially | Real hook path observed as `ETNA_TRADER/.claude/hooks.json` | CRITICAL MISMATCH | critical | Documentation path and filesystem path are not aligned |
| Atlas-related skill entry | no | Referenced in index, not found in audited `.claude/skills/` tree summary | CRITICAL MISMATCH | critical | Must not be reconciled automatically |
| Legit-related skill entry | no | Referenced in index, not found in audited `.claude/skills/` tree summary | CRITICAL MISMATCH | critical | Must not be reconciled automatically |
| root `README.md` | no | Root README not found during scope-corrected audit | expected artifact missing | high | Increases governance ambiguity |

## Conflict Table

| Conflict | Description | Risk | Action now |
|---|---|---|---|
| Canon declaration vs working tree | `aiqa/` is declared canonical, but legacy AI layers still exist in working tree | Split-brain truth | Record only |
| `.claude/` vs `.cursor/` | Mirrored layers may both be interpreted as active operational surfaces | Duplicate behavior surface | Record only |
| `FRAMEWORK_INDEX.md` vs filesystem | Index describes artifacts and paths that do not fully match the audited tree | Governance mismatch | Record only |
| `FRAMEWORK_INDEX.md` vs skills README(s) | Skill inventory in index and actual skills layer are not fully aligned | Wrong migration target selection | Record only |

## Critical Mismatches

- `FRAMEWORK_INDEX.md` references `_ai-tools-export/`, but this is not aligned with the audited ETNA_TRADER root
- `FRAMEWORK_INDEX.md` hook path does not match the observed `.claude/hooks.json` location
- `FRAMEWORK_INDEX.md` references Atlas-related skill content not confirmed in the audited skills tree
- `FRAMEWORK_INDEX.md` references Legit-related skill content not confirmed in the audited skills tree
- root `README.md` is absent in the audited scope

## Stop Conditions

Do not proceed to cleanup, migration, archive, or deletion while any of the following remains unresolved:

1. `FRAMEWORK_INDEX.md` does not match the actual filesystem
2. active hook paths are ambiguous or inconsistently documented
3. skill inventory differs between docs and actual skills directories
4. root governance documents are incomplete or missing
5. truth-layer vs wrapper-layer ownership is still ambiguous

## Final Recommendation

- Safe to proceed to decision review: **no**
- Safe to proceed to cleanup: **no**
- Safe to proceed to migration/archive/delete: **no**
