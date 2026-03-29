# Step 5 — Assumptions and uncertainty (repo index + impact map)

**Status:** supporting notes for `aiqa/repo-index.yaml` and `aiqa/impact-map.yaml`. Not canonical on its own.

## Workspace layout

- Paths `ETNA_TRADER/`, `ServerlessIntegrations/`, and `qa/` follow `detailed-repositories-index.md`. If a clone omits a subtree, rules still apply logically when that path appears in a change set.
- **`ETNA_TRADER/qa/`** (tests inside the platform repo) and **`qa/`** (standalone QA repo) are **two different roots**. The index documents both; cross-impact between them is **not** fully specified in inputs — only naming and structure evidence was used.

## Linked repos conservatism

- **No `linked_repos` entry** was added between `ServerlessIntegrations` and `ETNA_TRADER`: inputs do not state a direct integration contract between these two repositories.
- **ETNA_TRADER ↔ qa** links reflect test/automation coupling implied by `Etna.*` / `Etna.Trader.*` naming in the standalone `qa/` index section and the presence of `ETNA_TRADER/qa/` in the ETNA tree description.

## Impact rules

- **`DevReps/.claude` and `DevReps/.cursor`** appear under `legacy_hotspots` for the hooks/sync rule because Step 3 documents `sync-configs.js` pushing skills to the **parent** workspace; this is not a fourth repo id in `repo-index.yaml`.
- **Contract/WebApi paths** in `etna-trader-src-to-qa-surface` are a minimal, reviewable proxy for “API surface change”; they are not a complete enumeration of all integration points.
- **ServerlessIntegrations** rule stays **intra-repo** for expansion: no cross-repo rule was added without evidence.

## aiqa canonical files

- Changes under `aiqa/**` are intentionally **not** tied to a high-value cross-repo impact rule in this first map; later steps can add `when.any_paths` for `aiqa/` if task-schema or index consumers need it.
