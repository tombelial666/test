# Foundation documentation refresh — workstream summary

**Purpose:** Record what this documentation pass was for, what it adds, and how it relates to already-completed foundation work.  
**Status:** **review-grade** narrative of the refresh; canonical facts remain in `aiqa/MANIFEST.md`, `STRUCTURE.md`, YAML, and bug/step reports.

---

## 1. Summary of this workstream

A **deep, current-state documentation refresh** was requested so teammates can see **what is implemented**, what is **transitional**, how indexing and impact reasoning **actually** work today, how **`everything/`** was retired into archive and knowledge, and how to **onboard** and **troubleshoot** without treating non-canonical trees as SSOT.

This change set **adds and updates markdown under `aiqa/docs/`** (and `aiqa/README.md` where missing). It does **not** change canonical YAML contracts unless a separate task requires it.

---

## 2. Key decisions made (this pass)

- **Single reader order:** For framework **definition and boundaries**, `aiqa/MANIFEST.md` and `aiqa/STRUCTURE.md` first; for **day-to-day ETNA tool behavior**, legacy ETNA docs and hooks/sync remain relevant (Step 4 coexistence), clearly labeled as non-canonical vs `aiqa/`.
- **Explicit non-claims:** No statement that the framework is **automation-grade**, that **AMS** is in canonical index scope, or that **every** repo is fully indexed.
- **English** for new repo docs (per team style for canonical knowledge paths); historical archive may remain mixed-language.

---

## 3. What changed in the repo (this pass)

| Addition / update | Role |
|-------------------|------|
| `aiqa/docs/knowledge/framework-current-state.md` | Consolidated current-state narrative. |
| `aiqa/docs/knowledge/onboarding-and-troubleshooting.md` | Workspace map, trust order, troubleshooting topics. |
| `aiqa/docs/knowledge/indexing-and-impact-strategy.md` | Honest indexing and impact model + testing forward path. |
| `aiqa/docs/references/foundation-chat-summary.md` | This file. |
| `aiqa/README.md` | Entry point linking to canon and new guides. |

*(If your clone shows only these files as new, that is expected for a doc-only refresh.)*

---

## 4. What was validated (prior steps — evidence in repo)

- **BUG-STEP5-001:** Inferred `linked_repos` encoded with `confidence`, `evidence_basis`, `review_only`.
- **BUG-STEP5-002:** Structured `required_checks` objects across all impact rules.
- **BUG-STEP5-003:** Rule-level `review_mode`, `confidence`, `evidence_basis`; no rule-level `auto`.
- **BUG-STEP5-004 v2:** Path/glob alignment to dev-sync trees; standalone `qa/` and `ETNA_TRADER/qa/**` rules.
- **BUG-STEP5-005:** PyYAML `safe_load` on both canonical YAML files (environment documented in bug).

---

## 5. What was cleaned up (prior step — execution report)

- **Step 5.5B** (`everything-reclassification-execution-step-5-5b.md`): All 14 files under former `everything/` relocated to `aiqa/docs/knowledge/`, `aiqa/docs/references/`, `aiqa/templates/`, or `aiqa/archive/everything-step-5-5b/`; redundant `detailed-repositories-indexCOPY.md` removed after SHA256 match and archive copy; workspace-root `.claude`/`.cursor`/`.pytest_cache`/`.vscode` **untouched** by design.

---

## 6. Current status at end of this chat

- **Canonical foundation** under `aiqa/` matches the accepted branch narrative: manifest, structure, task schema, repo index (three repos), impact map (six rules), maturity policy, Step 5.1 evidence, Step 5.5B migration complete.
- **Transitional:** ETNA legacy adapter stack; workspace-root `.claude`/`.cursor` skills trees; any path not yet in `impact-map.yaml`.
- **Documentation:** New knowledge and reference pages give a **single place** for current state, onboarding, troubleshooting, and indexing strategy — still **review-grade** prose layered on top of canonical files.
