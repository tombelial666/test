# BUG-STEP5-003 — Rule-level review semantics in `impact-map.yaml`

**Scope:** Step 5.1 hard validation — canonical hardening for rule-level review semantics.  
**Artifacts touched:** `aiqa/impact-map.yaml` (metadata only); this report.

---

## 1. Summary

Для всех шести правил в `aiqa/impact-map.yaml` добавлены явные поля уровня правила: `review_mode`, `confidence` и `evidence_basis`. Они не дублируют и не заменяют существующие `required_checks` с собственными `mode`/`type`; они описывают **правило целиком** (зрелость обзора и силу основания для границ правила и триггеров). Ни одно правило не помечено как `auto`; `high` confidence использовано только там, где границы правила опираются на узко заданные пути внутри одного репозитория без выведенных межрепозиторных связей.

---

## 2. Current rule-level semantics review

**До изменений:** у правил были только `id`, `when`, `expand`, `legacy_hotspots` (где применимо) и структурированные `required_checks` с полями `mode` на уровне проверки (`manual` / `semi_auto`). На уровне правила не было единого способа ответить, насколько **само правило** (триггеры, расширение, намерение) опирается на доказательную базу и насколько оно рассчитано на ручной гейтинг.

**После сверки с входами** (`step-5-assumptions.md`, BUG-STEP5-001/002/004-v2):

- Связи **ETNA_TRADER ↔ standalone `qa/`** и пересечение двух корней QA в assumptions описаны как частично выведенные или не полностью специфицированные; таким правилам нельзя ставить `high` confidence только из-за полуавтоматических проверок.
- Правила с **явными глобами** и политикой области (standalone `qa/`) естественно помечаются `path_tree_validation` без заявления полной автоматизации.
- Правила **hooks/sync** и **legacy hotspots** опираются на legacy- и governance-артефакты — уместны `legacy_audit_docs` и `manual_governance_review`.
- **ServerlessIntegrations** остаётся внутрирепозиторным с узкими корневыми путями по индексу — единственный устойчивый кандидат на `high` confidence границ правила.

---

## 3. Metadata schema chosen

Для каждого правила поля задаются **сразу после** `id`:

| Поле | Тип | Назначение |
|------|-----|------------|
| `review_mode` | `manual` \| `semi_auto` \| `auto` | Ожидаемая зрелость обзора **правила в целом** (не отдельной проверки). |
| `confidence` | `high` \| `medium` \| `low` | Насколько **границы правила и логика триггеров** подкреплены текущими доказательствами. |
| `evidence_basis` | список коротких тегов | Повторно используемые метки источника доверия (лексика согласована с Step 5.1 / `repo-index`). |

`required_checks` и их `mode` / `blocking` / `type` **не менялись** — совместимость с BUG-STEP5-002 сохранена.

---

## 4. Rule-by-rule changes

| `id` правила | `review_mode` | `confidence` | `evidence_basis` | Обоснование (кратко) |
|--------------|---------------|--------------|------------------|----------------------|
| `etna-hooks-sync-chain` | `semi_auto` | `medium` | `legacy_audit_docs`, `manual_governance_review` | Sync/hooks и parent DevReps задокументированы в legacy-аудите; парность AGENTS/CLAUDE и итог — с ручным контролем. |
| `etna-twin-skill-layer` | `semi_auto` | `medium` | `workspace_index_naming`, `path_tree_validation` | Паритет .claude/.cursor и инвентарь частично автоматизируемы; границы по дереву workspace. |
| `etna-trader-src-to-qa-surface` | `semi_auto` | `medium` | `workspace_index_naming`, `path_tree_validation`, `legacy_audit_docs` | Глобы контрактов/WebApi — обзорный прокси (assumptions); расширение на `qa` не утверждено как полностью доказанное контрактами — не `high`. |
| `standalone-qa-fixtures-to-trader` | `manual` | `medium` | `path_tree_validation`, `workspace_index_naming` | Явные триггеры (BUG-004 v2); преобладают ручные `required_checks` и политика области. |
| `etna-trader-inrepo-qa-cross-surface` | `manual` | `medium` | `workspace_index_naming`, `manual_governance_review` | Два QA-корня; дрейф и карта поверхностей — в основном ручной impact review. |
| `serverless-shared-core` | `semi_auto` | `high` | `path_tree_validation`, `workspace_index_naming` | Только `ServerlessIntegrations`; узкие пути базы/контрактов; assumptions не вводят сомнительных межрепозиторных рёбер. |

---

## 5. Why the new semantics are safer

- **Разделение уровней:** видно отличие режима отдельной проверки (`required_checks[].mode`) от режима доверия к правилу как единице политики (`review_mode`).
- **Без завышения автоматизации:** `auto` не используется; `semi_auto` — там, где есть полуавтоматические проверки, но человек остаётся в контуре.
- **Калибровка confidence:** `high` только у внутрирепозиторного правила с узкой привязкой к путям; для ETNA ↔ QA и прокси-путей API — `medium`, в духе `step-5-assumptions.md` и BUG-STEP5-001.
- **Прослеживаемость:** теги `evidence_basis` дают короткий аудитный след без разрастания политики в YAML.

---

## 6. Go / No-Go for closing BUG-STEP5-003

**Go.** Критерии приёмки выполнены:

- У каждого правила в `aiqa/impact-map.yaml` есть явные `review_mode`, `confidence` и `evidence_basis`.
- Структура одинакова для всех правил и читаема для диффов.
- Уверенность и зрелость автоматизации не завышены относительно описанных в проекте оснований.
- YAML остаётся синтаксически валидным (проверка парсером).
- Карта по-прежнему пригодна для человеческого ревью; `required_checks` сохранены без изменений семантики.

**BUG-STEP5-003** можно закрывать при условии финального ревью владельцем процесса Step 5.1.
