# Wave 2 scorecard (12x12)

Scale: 0..12, where 12 = strong automation-grade execution confidence for the scoped work.

## Delta table

| Criterion | Before Wave 2 | After Wave 2 | Delta | Notes |
|---|---:|---:|---:|---|
| 1. SoT preservation | 10 | 11 | +1 | Added canonical specs/agents for missing domains under `aiqa/`. |
| 2. Anti-hallucination | 9 | 10 | +1 | New skills include explicit evidence basis and out-of-scope boundaries. |
| 3. On-demand coverage | 8 | 10 | +2 | Added coverage for `sub-account`, `option-chain`, and backend totalcount regression. |
| 4. Reproducibility | 9 | 10 | +1 | Added runnable definitions and inventory evidence for wave2 targets. |
| 5. Traceability | 10 | 11 | +1 | Every new skill points to concrete `aiqa/tasks` and evidence artifacts. |
| 6. Legacy hotspot handling | 8 | 9 | +1 | Option-chain and sub-account hotspots now explicitly represented. |
| 7. Dependency map clarity | 8 | 9 | +1 | Better cross-linking between task packages and generated adapters. |
| 8. Validation strength | 8 | 9 | +1 | Generator enhanced; new specs follow strict safety/input contracts. |
| 9. CI enforceability | 7 | 8 | +1 | Consistency improved via generation-first pattern; full CI gates still next step. |
| 10. Human review ergonomics | 10 | 11 | +1 | Scope-lock, scorecard, and tasks gap reports added in a single wave2 evidence pack. |
| 11. Scalability | 9 | 10 | +1 | Catalog+generator now handles additional domains with minimal manual duplication. |
| 12. Time-to-value | 10 | 11 | +1 | New agents/skills are immediately usable for current high-priority tasks. |

## Summary

- Average before: 8.83
- Average after: 9.83
- Net improvement: +1.00

## Residual risks

- CI still does not fully enforce catalog/schema/generation parity as a hard gate.
- Option-chain remains manual-first (`review-grade`) until automation implementation is added.
- Sub-account workflow depends on environment access and strict secret/PII discipline.
