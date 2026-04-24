# Onboarding and troubleshooting — AI QA framework

**Who this is for:** engineers joining the DevReps workspace or touching `aiqa/`, ETNA Trader legacy AI layer, or standalone `qa/`.  
**Canonical first:** `aiqa/MANIFEST.md`, `aiqa/STRUCTURE.md`, then this guide.

---

## 1. Who this is for

- Developers and QA working **across** `ETNA_TRADER`, `ServerlessIntegrations`, and standalone `qa/`.
- Anyone editing **canonical** framework files under `aiqa/`.
- Anyone confused by **two QA roots** (`qa/` vs `ETNA_TRADER/qa/`) or twin `.claude`/`.cursor` trees.

---

## 2. How to open and understand the workspace

1. Open the **workspace root** your team uses (often the monorepo root containing `aiqa/`, `ETNA_TRADER/`, etc.).
2. Read **`aiqa/MANIFEST.md`** — purpose and “canonical truth under `aiqa/`”.
3. Read **`aiqa/STRUCTURE.md`** — layers: canonical vs adapters vs task artifacts vs reference/archive.
4. Skim **`aiqa/docs/knowledge/framework-current-state.md`** — what exists today vs not.

**ETNA day-to-day:** After canon, if you need hook/sync behavior or skill discovery, use **`ETNA_TRADER/FRAMEWORK_INDEX.md`** and **`.claude`/`.cursor` skills README** with the understanding they may **diverge** from filesystem and from `aiqa/` (Step 3–4).

---

## 3. Where canonical truth lives

| Need | Location |
|------|----------|
| Framework purpose and boundaries | `aiqa/MANIFEST.md`, `aiqa/STRUCTURE.md` |
| Task field names (minimal) | `aiqa/task-schema.yaml` |
| Which repos are in scope for the index | `aiqa/repo-index.yaml` |
| Impact triggers and suggested checks | `aiqa/impact-map.yaml` |
| How to talk about trust levels | `aiqa/docs/policies/artifact-maturity-policy.md` |
| How to handle secrets/sensitive configs | `aiqa/docs/policies/secrets-and-sensitive-config-policy.md` |
| Assumptions and uncertainty | `aiqa/docs/references/step-5-assumptions.md` |

---

## 4. What the root `.claude/` and `.cursor/` trees are

At **DevReps workspace root**, `.claude/` and `.cursor/` hold **mirrored skills** used by tooling. Per `STRUCTURE.md` and Step 5.5A.2:

- They are **generated / legacy runtime adapter** material, **not** canonical framework definitions.
- They are still **governance-relevant**: `impact-map.yaml` lists **`DevReps/.claude/skills/**` and `DevReps/.cursor/skills/**` as `legacy_hotspots`** for the hooks/sync chain rule, tied to **`ETNA_TRADER/scripts/sync-configs.js`** pushing skills to the parent workspace (`step-5-assumptions.md`).

**ETNA_TRADER** has its **own** `.claude`/`.cursor` (hooks, skills, sync scripts) — parity-sensitive; see impact rules `etna-hooks-sync-chain` and `etna-twin-skill-layer`.

---

## 5. What archive means

**`aiqa/archive/everything-step-5-5b/`** preserves files moved from the former **`everything/`** transition bucket (Step 5.5B). Contents include research exports, handoff/progress logs, and the extensionless `docs` narrative file.

- **Not canonical.**
- **Use** for history, rationale, and audit — not for “what we enforce today.”

See `aiqa/archive/everything-step-5-5b/README.md`.

---

## 6. How to tell: canonical vs reference vs archive vs local noise

| Signal | Likely classification |
|--------|------------------------|
| Path under `aiqa/` + listed in `STRUCTURE.md` as canonical | **Canonical** (definitions, policies, YAML contracts). |
| Under `aiqa/docs/references/` or leading blockquote “non-canonical reference” | **Reference** — supporting evidence, examples, migrated docs. |
| Under `aiqa/docs/knowledge/` with migration blockquote | **Knowledge** — design/onboarding; **not** policy until promoted. |
| Under `aiqa/archive/**` | **Archive** — historical. |
| `.pytest_cache/`, stray local settings | **Local noise** — not framework input. |
| `ETNA_TRADER/FRAMEWORK_INDEX.md`, hooks, sync scripts | **Legacy runtime / operational** — authoritative for **how tools run**, not SSOT vs `aiqa/` for framework meaning (Step 4). |

**When docs disagree:** Prefer **`aiqa/`** canonical files, then **accepted execution/bug reports** (`bug-step5-*.md`, `everything-reclassification-execution-step-5-5b.md`), then **archive** as background only.

---

## 7. Common mistakes

- Treating **`repo-index.yaml`** as a **complete** workspace inventory (it lists **three** ids; `detailed-repositories-index.md` is broader and **not** all in canonical scope).
- Assuming **`linked_repos`** with `review_only: true` is a **proven** build graph.
- Editing **only** `.claude` or **only** `.cursor` under twin layers without parity review.
- Using **`everything/`** as a bucket — **removed**; use `aiqa/` paths from Step 5.5B report.
- Claiming **CI enforces** the impact map — **not implemented** as automation-grade (`artifact-maturity-policy.md`).

---

## 8. Troubleshooting scenarios

### Как запускать новые QA-агенты/скиллы?

Используй runtime-адаптеры из `.cursor/skills/README.md` или `.claude/skills/README.md`, но помни, что канон находится в `aiqa/skills-catalog/*.yaml` и `aiqa/agents/agents.yaml`.

Текущие ключевые скиллы:

- `clearing-systemactions-int2`
- `leaderboard-ui-api-tests`
- `frontoffice-login-guard`
- `sub-account-sftp-to-s3-tests`
- `option-chain-layout-regression`
- `leaderboard-totalcount-backend-regression`

Если содержимое адаптеров и канона расходится, источником истины считается `aiqa/`; адаптеры нужно регенерировать через `aiqa/scripts/generate_skills.py`.

### Why is `.cursor` / `.claude` not canonical?

By design (`MANIFEST.md`, `STRUCTURE.md`): canonical contracts live under **`aiqa/`**. Adapter trees are **rebuildable / operational** and may duplicate content; they must not redefine framework policy.

### Why did `everything/` exist?

It was a **transition bucket** for prompts, progress docs, and research before canonical `aiqa/` layout and Step 5.5 migration (see `everything-reclassification-plan-step-5-5a.md`).

### Why was `everything/` dismantled?

To **end split locations**, preserve history in **`aiqa/archive/`**, promote durable knowledge into **`docs/knowledge/`**, references into **`docs/references/`**, templates into **`templates/`**, and remove a redundant index copy after **SHA256 parity** (Step 5.5B execution report).

### What is archive vs knowledge vs reference?

- **Archive:** frozen historical bundle (`aiqa/archive/everything-step-5-5b/`).
- **Knowledge:** operational/design docs under `aiqa/docs/knowledge/` — supporting, often with “non-canonical” preamble.
- **Reference:** `aiqa/docs/references/` — evidence, examples, step reports, migrated long references.

### Why is `repo-index.yaml` not automation-grade?

Per **artifact maturity policy:** links are **human-evidence**-driven; ETNA ↔ standalone `qa` is **inferred** with `review_only: true`. YAML **parse** validation does not prove semantic correctness (BUG-001, BUG-005).

### Why is `impact-map.yaml` only validation-backed?

**Parses**; key globs were checked against **documented** trees; **structured** checks exist — but **`required_checks` are not** all wired as mandatory automated gates; no `auto` rule mode (BUG-002, BUG-003, policy §5).

### Why can’t we treat every repo as fully indexed yet?

Canonical **`repo-index.yaml`** intentionally scopes **three** repos. Others (e.g. **AMS** in `detailed-repositories-index.md`) are **out of canonical index scope** until explicitly added with evidence and map updates.

### Why is AMS not yet ready for the same level of impact reasoning?

**Not in** `repo-index.yaml` or `impact-map.yaml`. Skills at workspace root may mention Atlas/Legit workflows; that is **not** the same as canonical cross-repo impact rules for AMS. Treat AMS impact as **ordinary engineering analysis** until scoped.

### What should I trust first when docs disagree?

1. **`aiqa/`** canonical files (MANIFEST, STRUCTURE, YAML, policies).  
2. **Step 5 / 5.5 execution and bug reports.**  
3. **Archive / old handoff** — context only, especially where paths cite `C:/Reps/...` or other stale topology (`HANDOFF.md` in archive).

### Push в `main` блокируется GitHub secret protection. Что делать?

Если push падает с `GH013` и `Push cannot contain secrets`:

1. Смотри точный hash коммита и путь к файлу, которые вернул GitHub.
2. Выбирай один из двух безопасных путей:
   - **Предпочтительно:** удалить секрет из истории и пушить уже очищенную цепочку коммитов.
   - **Временное исключение:** мейнтейнер может явно разблокировать детект по ссылке из ошибки GitHub.
3. После очистки/разблокировки повторить `git push origin main`.

`force push` в `main` использовать только по явному согласованию.

---

## 9. Safe working rules

1. **Change `aiqa/` YAML** only with awareness of **maturity policy** — do not imply CI enforcement without wiring.
2. **Twin layers:** plan **.claude / .cursor** parity for ETNA and be cautious with **parent DevReps** skills paths when changing sync behavior.
3. **Two QA roots:** when touching tests, know whether you are in **`qa/`** or **`ETNA_TRADER/qa/`** — impact map has **different** rules (`standalone-qa-fixtures-to-trader` vs `etna-trader-inrepo-qa-cross-surface`).
4. **Promote knowledge to policy** only with an **evidence trail** (same standard as policy §6).
5. Prefer **`framework-current-state.md`** and **`indexing-and-impact-strategy.md`** when explaining the project to a colleague.
6. **Sensitive files (`*.json`, `*.env*`, auth scripts):** use template + local ignored config; never commit real secrets; if leakage happened, remediate history before push.

---

## See also

- [`framework-current-state.md`](framework-current-state.md)
- [`indexing-and-impact-strategy.md`](indexing-and-impact-strategy.md)
- [`../policies/artifact-maturity-policy.md`](../policies/artifact-maturity-policy.md)
- [`../policies/secrets-and-sensitive-config-policy.md`](../policies/secrets-and-sensitive-config-policy.md)
