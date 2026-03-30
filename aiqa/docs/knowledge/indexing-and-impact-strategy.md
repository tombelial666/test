# Indexing and impact analysis strategy

**Purpose:** Explain **why** indexing exists, what is **in scope** today, and how **impact reasoning** relates to diffs, tests, and future automation — without overstating coverage.  
**Canonical inputs:** `aiqa/repo-index.yaml`, `aiqa/impact-map.yaml`, `aiqa/docs/policies/artifact-maturity-policy.md`, `aiqa/docs/references/step-5-assumptions.md`.

---

## 1. Why indexing exists

Cross-repo QA needs a **shared vocabulary**: which **repos** exist in the framework’s first slice, where their **roots** are, what **domains** are relevant, and which **paths** should widen review when touched. Without a small canonical index, every task reinvents the same guesses.

The **killer feature** (per `MANIFEST.md`) is **legacy impact reasoning**, not flat diff listing — the index and map are **stepping stones** toward consistent human and (later) machine reasoning.

---

## 2. Why full indexing is not required for every MVP step

Full workspace indexing (every solution, every contract edge) is **expensive** and **evidence-hungry**. The approved MVP slice **deliberately** limits `repo-index.yaml` to **three** repository ids so that:

- Rules and validations can be **closed** with documented evidence (Step 5.1 bugs).
- Reviewers are not misled into believing the graph is **complete** for the whole monorepo.

Expand the index only when **scope and evidence** are explicit (policy §6).

---

## 3. Current indexing scope

| Artifact | Scope |
|----------|--------|
| `repo-index.yaml` | **ETNA_TRADER**, **ServerlessIntegrations**, **qa** (standalone root). Two QA locations: `qa/` and `ETNA_TRADER/qa/` documented as **distinct** roots. |
| `impact-map.yaml` | Six rules covering ETNA hooks/sync and twin skills, ETNA src surfaces → QA, standalone `qa/` subtrees, in-repo `ETNA_TRADER/qa/**`, ServerlessIntegrations shared core. |
| `detailed-repositories-index.md` (repo root) | **Broader narrative index** (includes AMS and others) used as **Step 5 evidence** and exploration aid — **not** equivalent to canonical `repo-index.yaml` scope. |

---

## 4. Current limitations

- **Repo graph:** Only **declared** edges in YAML; ETNA ↔ standalone `qa` is **`review_only`** / naming-based (BUG-001).
- **Triggers:** Globs are **minimal proxies** (e.g. WebApi/Contracts paths do not enumerate every integration point — `step-5-assumptions.md`).
- **Layout drift:** Path validation was against **documented** dev-sync trees (BUG-004 v2); **re-validate** when trees move.
- **No AMS** in canonical index or impact map — do not use the framework YAML to claim AMS coverage.

---

## 5. Why impact analysis needs more than diff alone

A **diff** answers “what lines changed,” not:

- Which **consumers** (tests, other repos) encode assumptions about those surfaces.
- Whether **twin** adapter files stayed in **parity**.
- Whether **sync scripts** will propagate changes safely to **parent** workspace skills.

`impact-map.yaml` encodes **when** to broaden attention and **what kinds of checks** to run or review (`required_checks`). It is a **structured checklist and trigger set**, not a proof of impact.

---

## 6. ETNA_TRADER indexing strategy (as implemented)

- **Legacy AI adapter chain:** hooks, `sync-configs.js` / `sync-docs.js`, twin `.claude`/`.cursor` — high sensitivity; rules `etna-hooks-sync-chain`, `etna-twin-skill-layer`.
- **API / contract proxies:** glob patterns under `ETNA_TRADER/src/**` for WebApi and `*Contracts*` — rule `etna-trader-src-to-qa-surface` expands to **qa** for review (not proven exhaustive).
- **Parent DevReps:** `legacy_hotspots` include `DevReps/.claude/skills/**` and `.cursor/skills/**` because sync can write there (`step-5-assumptions.md`).

Operational discovery still uses **ETNA** `FRAMEWORK_INDEX.md` and skills README — coexistence with `aiqa/` (Step 4).

---

## 7. How to expand indexing next

1. **Amend `repo-index.yaml`** with new `repos` entries — add `linked_repos` only with agreed **evidence_basis** and confidence (BUG-001 pattern).
2. **Add impact rules** with new `when.any_paths` — run **path/tree validation** and record evidence (BUG-004 style).
3. **Update `step-5-assumptions.md`** and, if needed, **artifact maturity policy** classifications when claims change.
4. Avoid **silent** promotion to automation-grade (policy §6).

---

## 8. What is needed before AMS can be treated as in-scope

- **Explicit product decision** to include AMS in the framework slice.
- **repo-index.yaml** entry: roots, domains, `linked_repos` backed by more than naming if automation-grade edges are ever claimed.
- **impact-map.yaml** rules driven by **real AMS paths** and validated against a **named tree snapshot**.
- **Evidence record** (bug report or policy appendix) for validation commands and scope — same bar as Step 5.1.

Until then, **AMS** remains documented in **`detailed-repositories-index.md`** for humans but **not** in canonical impact reasoning YAML.

---

## 9. How indexing ties into testing and future deterministic pipeline slices

### Already tested / validated (documented)

- **YAML:** `yaml.safe_load` on both canonical YAML files (BUG-STEP5-005).
- **Path/glob:** Impact map triggers checked against **documented** dev-sync trees; standalone `qa/` and `ETNA_TRADER/qa/**` coverage closed (BUG-STEP5-004 v2).
- **Structured `required_checks`:** Uniform object shape (BUG-STEP5-002).
- **Rule-level semantics:** `review_mode`, `confidence`, `evidence_basis`; no rule-level `auto` (BUG-STEP5-003).
- **Maturity policy:** Explicit levels for `repo-index` vs `impact-map` (policy §5).
- **Cleanup:** Step 5.5B execution report for `everything/` migration.

### Planned / not implemented

- **Deterministic slice tests:** e.g. golden-file or CI job that re-runs glob matching against a pinned tree, schema checks for `required_checks`, parity checks for selected twin files.
- **CI / automation-grade path:** wire **specific** checks as merge gates; pin tooling (Python/PyYAML, etc.) per BUG-005 lessons; narrow promotion per check (policy §6), not whole-map hand-waving.

**Task Carrier / IDE:** `task-schema.yaml` and `IDE_Task_Carrier_Pipeline_V1.md` describe a **future** unified task artifact — **design knowledge**, not a shipped pipeline.

---

## Related reading

- [`framework-current-state.md`](framework-current-state.md)
- [`onboarding-and-troubleshooting.md`](onboarding-and-troubleshooting.md)
- [`../policies/artifact-maturity-policy.md`](../policies/artifact-maturity-policy.md)
