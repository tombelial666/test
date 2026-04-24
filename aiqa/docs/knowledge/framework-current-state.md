# AI QA framework — current state

**Audience:** engineers who need a fast, honest map of what exists today vs what is still planned.  
**Canonical contracts:** `aiqa/MANIFEST.md`, `aiqa/STRUCTURE.md`, `aiqa/task-schema.yaml`, `aiqa/repo-index.yaml`, `aiqa/impact-map.yaml`, `aiqa/docs/policies/artifact-maturity-policy.md`.  
**This document:** **review-grade** operational summary; it does not replace those files.

---

## 1. Executive summary

The framework under `aiqa/` is a **canonical foundation** for AI-assisted QA, cross-repo impact reasoning, and structured task metadata. **Implemented now:** manifest and structure, minimal task schema, a **narrow** canonical repo index (three repo ids), a **minimal** impact map with path triggers and structured `required_checks`, an **artifact maturity policy**, Step 5.1 hard-validation evidence (bugs STEP5-001…005), and Step 5.5B **reclassification** of the former `everything/` bucket into `aiqa/docs/knowledge/`, `aiqa/docs/references/`, `aiqa/templates/`, and `aiqa/archive/everything-step-5-5b/`.

Покрытие пользовательских сценариев для Wave 1 и Wave 2 также уже оформлено: канонические skill-specs в `aiqa/skills-catalog/`, привязки агентов в `aiqa/agents/agents.yaml`, evidence-манифесты в `aiqa/evidence/`, а также синхронизированные runtime-адаптеры в `.cursor/skills/` и `.claude/skills/`.

**Not implemented yet:** runtime orchestration, generated adapter pipeline from `aiqa/` alone, CI gates that enforce the impact map, full multi-repo contract graphs, and **AMS** (or any repo outside the three indexed ids) as part of the canonical index or impact rules.

**Legacy runtime** (ETNA_TRADER hooks, sync scripts, twin `.claude`/`.cursor`, `FRAMEWORK_INDEX.md`) remains **operationally authoritative for how tools run today** per Step 3–4 governance notes, while **`aiqa/` is authoritative for framework definition and future contracts**.

---

## 2. What the framework is

Per `MANIFEST.md`, the purpose is a **canonical foundation** for AI-assisted QA, impact analysis, and regression reasoning **across repositories**, with emphasis on **cross-repo legacy impact** (not only file diffs).

Core artifacts:

| Artifact | Role |
|----------|------|
| `task-schema.yaml` | Minimal field names for a task object (not wired to IDE or ETNA hooks yet). |
| `repo-index.yaml` | Canonical list of **in-scope** repos, roots, domains, and conservative `linked_repos`. |
| `impact-map.yaml` | Rules: path/glob triggers, expansion hints, structured `required_checks`, rule-level review metadata. |
| Policies and references | Maturity vocabulary, assumptions, audit/bug closure records. |

---

## 3. What is already implemented

- **Canonical tree under `aiqa/`** with explicit boundary rules (`STRUCTURE.md`).
- **Repo index (Step 5)** for ids `ETNA_TRADER`, `ServerlessIntegrations`, `qa` only, with documented uncertainty on ETNA_TRADER ↔ standalone `qa` (`review_only`, `confidence: medium`, `workspace_index_naming`) per BUG-STEP5-001 and `step-5-assumptions.md`.
- **Impact map (Step 5 / 5.1)** with six rules, structured `required_checks` (BUG-STEP5-002), rule-level `review_mode` / `confidence` / `evidence_basis` (BUG-STEP5-003), path/glob validation against documented dev-sync trees and explicit coverage for both QA roots (BUG-STEP5-004 v2).
- **YAML parse validation** for `repo-index.yaml` and `impact-map.yaml` with `yaml.safe_load` after PyYAML install (BUG-STEP5-005) — structural trust only.
- **Artifact maturity policy** classifying `repo-index.yaml` as **review-grade** and `impact-map.yaml` as **validation-backed** (not automation-grade as a whole).
- **Governance history** (classification Step 3, coexistence plan Step 4) for the ETNA legacy adapter stack.
- **Step 5.5B execution:** former `everything/` content moved per plan; duplicate index copy removed after SHA256 parity + archive backup; `STRUCTURE.md` updated for `docs/knowledge/`, `archive/`, `templates/`.
- **Канонический слой skills/agents (Wave 1 + Wave 2):**
  - `aiqa/skills-catalog/*.yaml` задаёт нормализованные контракты скиллов для clearing INT2, leaderboard UI/API, frontoffice login guard, sub-account SFTP->S3, option-chain layout regression и leaderboard TotalCount backend regression.
  - `aiqa/agents/agents.yaml` связывает test suites с этими skill-specs и фиксирует границы применения.
  - `aiqa/scripts/generate_skills.py` вместе с `aiqa/templates/skill-render/*` генерирует синхронные адаптеры в `.cursor/skills/**` и `.claude/skills/**`.
  - `aiqa/evidence/qa-suite-inventory/...` и `aiqa/evidence/agents-skills-wave2/...` фиксируют inventory, scope lock, scorecard и tasks gap report.

---

## 4. What is intentionally not implemented yet

From `MANIFEST.md` **out of scope for this phase:**

- Runtime adapter **implementation** (generation from `aiqa/` replacing today’s sync/hooks story).
- Orchestrator logic and script automation for the full pipeline.
- Speculative artifacts not required by the approved foundation plan.

Additionally **not claimed:**

- **Automation-grade** enforcement of `impact-map.yaml` in CI.
- Complete **contract/build graph** between all workspace repos.
- **AMS** (and other repos in `detailed-repositories-index.md`) inside canonical `repo-index.yaml` / `impact-map.yaml` until explicitly scoped and evidenced.

---

## 5. Current architecture layers

| Layer | Location | Trusted as |
|-------|----------|------------|
| **Canonical** | `aiqa/` (manifest, structure, schemas, `repo-index`, `impact-map`, `docs/policies/`, canonical templates) | **Canonical** for framework definition and Step 5 contracts. |
| **Generated / legacy runtime adapters** | `ETNA_TRADER/.claude`, `.cursor`, hooks, `scripts/sync-*.js`; workspace root `DevReps/.claude/skills/**`, `.cursor/skills/**` (parent sync story) | **Operational** for tool behavior; **not** SSOT vs `aiqa/` (Step 4). |
| **Task / execution artifacts** | Task folders, test outputs, chats | Context-specific; not framework canon. |
| **Reference** | `aiqa/docs/references/*`, repo-root `detailed-repositories-index.md` | Evidence and narrative; **review-grade** unless promoted. |
| **Archive** | `aiqa/archive/everything-step-5-5b/**` | **Historical** migration and research; not canon. |
| **Migrated knowledge** | `aiqa/docs/knowledge/*` | **Supporting** design/onboarding; blockquotes mark non-canonical per migration. |
| **Local noise** | e.g. `.pytest_cache/`, personal editor state | Not inputs to canonical contracts (Step 5.5A.2 plan). |

---

## 6. Current maturity status

Use `artifact-maturity-policy.md` vocabulary:

- **`repo-index.yaml`:** **review-grade** (human evidence for links; YAML syntax validated — does not prove semantic graph).
- **`impact-map.yaml`:** **validation-backed** (parse + documented glob/tree checks + structured shape; checks are **not** universally wired as CI gates).
- **Step 5 bug reports:** **review-grade** evidence of what was run.
- **Framework as a whole:** **not automation-grade**.

---

## 7. What the framework can already be used for

- **Reviewer checklists** and discussion anchors: which repos and domains matter, which paths trigger broadened review, and what kinds of checks to consider (`required_checks`).
- **Onboarding** to the **intended** separation: canon in `aiqa/` vs legacy runtime in ETNA / root adapters.
- **Honest scoping** of MVP: three-repo index, six rules, explicit non-claims for AMS and full automation.
- **Skill-driven QA entry points:** пользователь может выбрать готовый скилл в `.cursor/skills/README.md` или `.claude/skills/README.md`, при этом источником истины остаётся `aiqa/skills-catalog/`.

---

## 8. What it cannot yet be trusted to do

- **Automatically** block merges based on impact map parity or required checks (no documented wired runners for all checks).
- **Prove** cross-repo dependencies from naming alone (`review_only` edges).
- **Replace** reading actual code, tests, and ops runbooks for ETNA, ServerlessIntegrations, and qa.
- **Cover** every path or future layout change without re-validation (BUG-004 v2 limits).
- **Гарантировать, что любая историческая цепочка коммитов пушится без блокировок**, если в старых коммитах есть секреты; push-protection может заблокировать обновление `main`, пока секрет не удалён из истории или не разблокирован мейнтейнером.

---

## 9. MVP progress and next steps

**Done (foundation track):** canonical files; index + map; maturity policy; Step 5.1 validation record; `everything/` cleanup and archive bundle; workspace-root transition dirs **documented** as legacy-runtime / local-noise (5.5A.2) without moving them in 5.5B.

**Plausible next steps** (not committed in-repo unless a later step records them):

- Wire **selected** mechanical checks to PR/CI (path glob regression, YAML schema, subset of parity checks).
- Expand `repo-index` / `impact-map` only with **new evidence** and policy promotion.
- Task Carrier / IDE integration aligned with `task-schema.yaml` and `IDE_Task_Carrier_Pipeline_V1.md` (**design knowledge**, not implemented as product).
- Eventual **AMS** (or other repos) in canonical index after agreed scope and evidence — not implied by current YAML.

---

## 10. Testing: validated vs planned

**Already validated (documented in repo):**

- **YAML parser:** `yaml.safe_load` on `repo-index.yaml` and `impact-map.yaml` (BUG-STEP5-005).
- **Path/glob vs real trees:** dev-sync tree evidence; standalone `qa/` and `ETNA_TRADER/qa/**` rule coverage (BUG-STEP5-004 v2).
- **Structured `required_checks`:** uniform fields per check (BUG-STEP5-002).
- **Rule-level review semantics:** `review_mode`, `confidence`, `evidence_basis`; no rule `auto` (BUG-STEP5-003).
- **Maturity policy:** classifications for index vs map (policy §5).
- **Cleanup execution:** Step 5.5B report for `everything/` migration.

**Planned (not implemented as standing automation):**

- **Deterministic slice tests** (pinned tree + glob regression, schema checks for checks).
- **CI wiring** for selected gates and **automation-grade** promotion per check with pinned tooling (per policy §6).

Detail: [`indexing-and-impact-strategy.md`](indexing-and-impact-strategy.md) §9.

---

## Related reading

- Onboarding and troubleshooting: [`onboarding-and-troubleshooting.md`](onboarding-and-troubleshooting.md)
- Indexing and impact: [`indexing-and-impact-strategy.md`](indexing-and-impact-strategy.md)
- Chat/workstream summary: [`../references/foundation-chat-summary.md`](../references/foundation-chat-summary.md)
