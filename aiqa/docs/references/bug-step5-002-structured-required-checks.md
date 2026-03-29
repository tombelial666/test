# BUG-STEP5-002 — Structured `required_checks` (`impact-map.yaml`)

**Step:** 5.1 hard validation (canonical hardening).  
**Scope:** `aiqa/impact-map.yaml` only (this report is supporting documentation).

---

## 1. Summary

Все шесть правил в `aiqa/impact-map.yaml` переведены с **простых строк** в списке `required_checks` на **единый минимальный объектный формат**: `id`, `type`, `mode`, `blocking`, `description`. Смысл исходных формулировок сохранён в `description`; триггеры `when`, `expand`, `legacy_hotspots` не менялись. Значения `mode` заданы **консервативно** (преимущественно `manual` или `semi_auto`); `auto` не используется, так как в канонических входах Step 5 нет доказательств полностью автоматизированного контура для этих проверок.

---

## 2. Current required_checks review

До изменения каждое правило содержало **2–3 пункта** только как однострочный prose:

| Rule id | Было пунктов | Характер проверок |
|---------|----------------|-------------------|
| `etna-hooks-sync-chain` | 3 | паритет hooks, безопасность sync, согласованность AGENTS/CLAUDE |
| `etna-twin-skill-layer` | 2 | паритет skill-путей, ручной обзор README vs индекс |
| `etna-trader-src-to-qa-surface` | 2 | grep/маппинг контрактов в QA, целевые автотесты |
| `standalone-qa-fixtures-to-trader` | 3 | напоминание о scope, маппинг фикстур, среда vs деплой |
| `etna-trader-inrepo-qa-cross-surface` | 2 | кросс-поверхность с standalone `qa/`, маппинг к `src` |
| `serverless-shared-core` | 2 | юнит-тесты базы/контрактов, smoke solution |

Ни один пункт не был размечен для машинного потребления (тип, блокирующесть, зрелость автоматизации).

---

## 3. Structured schema chosen

Для **каждого** элемента `required_checks`:

| Поле | Назначение |
|------|------------|
| `id` | Стабильный уникальный идентификатор проверки в пределах файла (snake_case). |
| `type` | Короткий переиспользуемый тип: `parity_check`, `config_review`, `impact_review`, `targeted_test`, `build_smoke`. |
| `mode` | `manual` \| `semi_auto` \| `auto` — отражает **текущую** зрелость; без завышения. |
| `blocking` | `true`, если провал должен **снижать доверие к изменению** и останавливать «зелёный» исход ревью по этому правилу; иначе `false`. |
| `description` | Исходная человекочитаемая формулировка (с минимальными правками только для ясности, без смены намерения). |

Схема **намеренно плоская** — без вложенных объектов, без большого таксономического дерева, чтобы диффы и ручной обзор оставались простыми.

**Использование `type` в этом файле:**

- `parity_check` — сравнение пар (.claude / .cursor, пути skills).
- `config_review` — политика scope, среда/конфиг, согласованность пар документов.
- `impact_review` — трассировка контрактов, маппинг фикстур/тестов к `src`, кросс-проверка между корнями `qa/` и `ETNA_TRADER/qa/`.
- `targeted_test` — запуск/планирование тестов, dry-run sync.
- `build_smoke` — smoke-сборка solution и обзор зависимых проектов.

---

## 4. Rule-by-rule changes

### `etna-hooks-sync-chain`

| `id` | `type` | `mode` | `blocking` | Примечание |
|------|--------|--------|------------|------------|
| `hooks_json_claude_cursor_parity` | parity_check | semi_auto | true | Дифф hooks — часто инструментально, решение — человек. |
| `sync_scripts_twin_trees_safety` | targeted_test | semi_auto | true | Dry-run/ветка — не полностью стандартизированный CI в map. |
| `agents_claude_paired_after_sync_docs` | config_review | manual | true | Явная ручная сверка после sync-docs. |

### `etna-twin-skill-layer`

| `id` | `type` | `mode` | `blocking` | Примечание |
|------|--------|--------|------------|------------|
| `twin_skill_paths_claude_cursor_parity` | parity_check | semi_auto | true | Как в исходнике: diff путей. |
| `skills_readme_framework_index_inventory` | impact_review | manual | false | Исходный текст помечал «(manual)»; дрейф инвентаря — важен, но не единственный критичный стоппер как паритет путей. |

### `etna-trader-src-to-qa-surface`

| `id` | `type` | `mode` | `blocking` | Примечание |
|------|--------|--------|------------|------------|
| `contract_dto_qa_bindings_trace` | impact_review | semi_auto | true | grep/поиск — semi_auto; интерпретация — человек. |
| `targeted_api_ui_automation_surface` | targeted_test | manual | true | Команды репо-специфичны — без заявления `auto`. |

### `standalone-qa-fixtures-to-trader`

| `id` | `type` | `mode` | `blocking` | Примечание |
|------|--------|--------|------------|------------|
| `standalone_qa_scope_policy` | config_review | manual | false | Напоминание о закодированной политике триггеров; не отдельный исполняемый гейт. |
| `fixtures_models_trader_src_overlap` | impact_review | manual | true | Как в исходной смысловой нагрузке. |
| `qa_env_matches_etna_deployment` | config_review | manual | true | Среда vs допущения деплоя. |

### `etna-trader-inrepo-qa-cross-surface`

| `id` | `type` | `mode` | `blocking` | Примечание |
|------|--------|--------|------------|------------|
| `standalone_qa_shared_scenarios_drift` | impact_review | manual | true | Согласовано с `step-5-assumptions.md`: два корня `qa/`. |
| `inrepo_qa_assertions_trader_src_map` | impact_review | manual | true | Маппинг к WebApi/contracts. |

### `serverless-shared-core`

| `id` | `type` | `mode` | `blocking` | Примечание |
|------|--------|--------|------------|------------|
| `integration_lambda_base_unit_tests` | targeted_test | semi_auto | true | Тесты обычно запускаются из CLI/CI, но map не фиксирует единый auto-контур. |
| `integration_reports_sln_smoke_build` | build_smoke | semi_auto | true | Сборка + список проектов — типично semi_auto. |

---

## 5. Why the new structure is safer

1. **Машинная обработка:** скрипты и валидаторы могут проверять наличие обязательных полей, уникальность `id`, допустимые значения `type`/`mode`, и отчитываться о `blocking` без парсинга свободного текста.
2. **Честная зрелость:** поле `mode` отделяет «что должно быть сделано» от завышенных ожиданий автоматизации; отсутствие `auto` соответствует отсутствию жёстких доказательств в Step 5 inputs.
3. **Явная критичность:** `blocking` кодирует, какие проверки считаются **стоппером доверия** к изменению, а какие — уточняющими (например, scope policy, инвентарный drift README).
4. **Сохранение смысла для людей:** `description` остаётся основным текстом для ревью; структура дополняет, а не заменяет смысл.
5. **Диффопригодность:** плоский объект на элемент списка даёт предсказуемые изменения при добавлении полей в будущем.

---

## 6. Go / No-Go for closing BUG-STEP5-002

**Go** — при соблюдении всех критериев приёмки:

- Каждое правило использует **только** структурированные объекты в `required_checks` (строковых элементов списка нет).
- Схема полей **одинакова** для всех проверок: `id`, `type`, `mode`, `blocking`, `description`.
- Тексты `description` сохраняют исходный смысл; YAML **парсится** валидно (`yaml.safe_load` проверен локально).
- `mode` не заявляет более высокую автоматизацию, чем подтверждается контекстом Step 5.

Если позже появится задокументированный CI-контур для отдельных проверок, допустимо точечно повысить `mode` для соответствующих `id` **с отдельной ссылкой на доказательства** — вне закрытия BUG-STEP5-002.
