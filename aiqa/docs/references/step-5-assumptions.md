# Step 5 — Assumptions and uncertainty (repo index + impact map)

**Status:** supporting notes for `aiqa/repo-index.yaml` and `aiqa/impact-map.yaml`. Not canonical on its own.

**Maturity:** how far reviewers may trust these artifacts (vs. what CI enforces) is defined in [`artifact-maturity-policy.md`](../policies/artifact-maturity-policy.md) — Step 5 outputs are **not** all automation-grade.

## Workspace layout

- Paths `ETNA_TRADER/`, `ServerlessIntegrations/`, and `qa/` follow `detailed-repositories-index.md`. If a clone omits a subtree, rules still apply logically when that path appears in a change set.
- **`ETNA_TRADER/qa/`** (tests inside the platform repo) and **`qa/`** (standalone QA repo) are **two different roots**. The index documents both; cross-impact between them is **not** fully specified in inputs — only naming and structure evidence was used.

## Linked repos conservatism

- **No `linked_repos` entry** was added between `ServerlessIntegrations` and `ETNA_TRADER`: inputs do not state a direct integration contract between these two repositories.
- **ETNA_TRADER ↔ qa** (standalone `qa/` repo id) entries are **partly inferred**: `confidence: medium`, `evidence_basis: [workspace_index_naming]`, `review_only: true` in `repo-index.yaml`. They reflect naming and workspace inventory from `detailed-repositories-index.md`, not a verified dependency or contract map. **`ETNA_TRADER/qa/`** and **`qa/`** remain two distinct roots; the in-tree path alone does not prove linkage to the standalone repo.

## `linked_repos` uncertainty fields (Step 5.1 / BUG-STEP5-001)

- **`confidence`**: `high` — index or primary artifact states the relationship explicitly; `medium` — relationship is reasonable from naming/layout but not proven by cited build or API contracts in inputs.
- **`evidence_basis`**: short tags for automation (`workspace_index_naming`, etc.); extend only when new evidence types are agreed.
- **`review_only`**: when true, consumers must not treat the edge as a hard automated dependency without further verification.

## Impact rules

- **`DevReps/.claude` and `DevReps/.cursor`** appear under `legacy_hotspots` for the hooks/sync rule because Step 3 documents `sync-configs.js` pushing skills to the **parent** workspace; this is not a fourth repo id in `repo-index.yaml`.
- **Contract/WebApi paths** in `etna-trader-src-to-qa-surface` are a minimal, reviewable proxy for “API surface change”; they are not a complete enumeration of all integration points.
- **ServerlessIntegrations** rule stays **intra-repo** for expansion: no cross-repo rule was added without evidence.

## aiqa canonical files

- Changes under `aiqa/**` are intentionally **not** tied to a high-value cross-repo impact rule in this first map; later steps can add `when.any_paths` for `aiqa/` if task-schema or index consumers need it.
