# Task 228135 — RQD EasyToBorrow (Volant) в Octopus

QA-пакет в рамках [`aiqa/MANIFEST.md`](../../MANIFEST.md).

Бизнес-контекст: файлы ETB от RQD попадают в SODData; в коде включение и параметры завязаны на **Volant** (`CM.Volant.*`) и флаг **`CM.Volant.EasyToBorrow`**.

## Артефакты

| Файл | Назначение |
|------|------------|
| [`task.yaml`](task.yaml) | Метаданные по [`task-schema.yaml`](../../task-schema.yaml): id, repos, domains, evidence, unknowns |
| [`short-summary.md`](short-summary.md) | Краткое резюме задачи, diff stat, бизнес-смысл, main takeaway по `setOthersFalse` |
| [`dependency-map.md`](dependency-map.md) | Карта зависимостей: provider -> handler -> `AllowShort` updates -> task-level indexed artifacts |
| [`legacy-hotspots.md`](legacy-hotspots.md) | Legacy-риск по shared `EasyToBorrowHandler`, Octopus config, overridden securities, evidence drift |
| [`risk-based-qa-plan.md`](risk-based-qa-plan.md) | План проверок по рискам: wiring, backward compatibility, opt-out mode, clearing-firm branch |
| [`ai-review-test-design.md`](ai-review-test-design.md) | AI review покрытия: code paths, test completeness, remaining gaps |
| [`evidence-notes.md`](evidence-notes.md) | Primary evidence: PR, branch diff, changed files, observed limits of local checkout |
| [`framework-rule-open-questions.md`](framework-rule-open-questions.md) | Только доказательные OPEN questions, которые нельзя закрыть текущим evidence |
| [`test-cases-comprehensive.md`](test-cases-comprehensive.md) | Полный набор test cases и traceability Requirement/Risk -> TC |
| [`retest-runbook.md`](retest-runbook.md) | Единый INT2 runbook: preflight, payload preparation, discovery/full run, expected results |
| [`acceptance-criteria.md`](acceptance-criteria.md) | Явные product acceptance criteria и testing completion criteria |
| [`test-execution-summary.md`](test-execution-summary.md) | Фактический статус execution evidence, что закрыто automation, что остаётся manual |
| [`qa/Tools/ClearingTester/run_volant_easy_to_borrow_int2.py`](../../../qa/Tools/ClearingTester/run_volant_easy_to_borrow_int2.py) | Atomic INT2 test runner for `GET/PUT /systemactions/clearing` |
| [`qa/Tools/ClearingTester/tests/test_volant_easy_to_borrow_int2.py`](../../../qa/Tools/ClearingTester/tests/test_volant_easy_to_borrow_int2.py) | Atomic `unittest` cases for Volant EasyToBorrow action discovery and execution |
| [`qa/Tools/ClearingTester/payloads/volant_easy_to_borrow_int2.template.json`](../../../qa/Tools/ClearingTester/payloads/volant_easy_to_borrow_int2.template.json) | Safe payload template for local INT2 execution |
| [`../228135-RQD-EasyToBorrow-Handler-in-Octopus.txt`](../228135-RQD-EasyToBorrow-Handler-in-Octopus.txt) | Таблица: config keys ↔ Octopus tenant variables ↔ комментарии |

## Репозитории и ссылки

| Роль | Путь / ссылка |
|------|----------------|
| Код | `ETNA_TRADER`, ветка `feature/228135-rqd-easy-to-borrow` |
| PR | [PR 15578](https://dev.azure.com/etnasoft/ETNA_TRADER/_git/19afa09e-4f75-4f60-ad0c-b3357693c4ef/pullrequest/15578) |

## Кодовые якоря (diff относительно `dev`)

- `ETNA_TRADER/src/Etna.Trader/Etna.Trader.Services/OmsService/config/Oms/Oms.ClearingManager.Octopus.config` — провайдер **Volant EasyToBorrow**, handler с `setOthersFalse`, расписание
- `ETNA_TRADER/src/Etna.Trading.Components/Etna.Trading.Oms.Clearing/StartOfDay/Handlers/EasyToBorrowHandler.cs` — логика `setOthersFalse` и обновление `AllowShort`
- `ETNA_TRADER/src/Etna.Trading.Components/Etna.Trading.Oms.Clearing.Tests/StartOfDay/JsonData/Cor/Integration/AdditionalSecurityData/CorSodETBTest.json` — регрессия по флагу

## Task-level indexing

Для этой задачи пакет документов используется как **task-level index**. В него включены:

- PR `15578`
- diff `origin/dev...origin/feature/228135-rqd-easy-to-borrow`
- mapping artifact `228135-RQD-EasyToBorrow-Handler-in-Octopus.txt`
- code anchors в `Oms.ClearingManager.Octopus.config`, `EasyToBorrowHandler.cs`, `CorSodETBTest.json`
- execution artifacts: `retest-runbook.md`, `acceptance-criteria.md`, `test-execution-summary.md`

Важно: текущих данных **недостаточно** для расширения canonical `repo-index.yaml` или `impact-map.yaml`, поэтому индексация ограничена уровнем этой task-папки.

## Кратко о поведении

- **`setOthersFalse: true`** (в Octopus для Volant ETB задано явно): для бумаг **не** в файле shortable сбрасывается — как классический полный снимок ETB.
- **`setOthersFalse: false`**: бумаги **вне** файла **не** переводятся в non-shortable только из-за отсутствия в файле (см. второй сценарий в `CorSodETBTest.json`).

## Важно перед тестами

Локальный `ETNA_TRADER` может быть не на ветке PR — выполнить `git fetch` и сверку с `origin/feature/228135-rqd-easy-to-borrow` и Azure DevOps **PR 15578**.

## Automation helper

Для API smoke / targeted integration runnable automation перенесена в `qa/Tools/ClearingTester`.

Новая реализация:

- использует обычный `POST /api/token` на `pub-api-etna-demo-ci-int-2.etnasoft.us` с `username/password/Et-App-Key`;
- выполняет `systemactions/clearing` через `priv-api-etna-demo-ci-int-2.etnasoft.us/api/v1.0/systemactions/clearing`;
- использует атомарные `unittest` tests в `qa/Tools/ClearingTester/tests/test_volant_easy_to_borrow_int2.py`;
- держит безопасный payload template в `qa/Tools/ClearingTester/payloads/volant_easy_to_borrow_int2.template.json`.

Пример запуска:

```bash
python qa/Tools/ClearingTester/run_volant_easy_to_borrow_int2.py
```

Важно: template JSON намеренно хранится **без реальных секретов**. Перед запуском подставить реальные значения локально или использовать отдельный некоммитимый payload-файл через `CLEARING_TESTER_PAYLOAD`.

## Рекомендуемые проверки

1. Сборка и тесты `Etna.Trading.Oms.Clearing.Tests` (в т.ч. обновлённый JSON Cor ETB).
2. На стенде с Octopus: при включённом `CM.Volant.EasyToBorrow` — успешная загрузка файла, срабатывание по расписанию, ожидаемые `AllowShort` в БД/мастере бумаг.
3. Регрессия других потоков **EasyToBorrowHandler** (COR/Velocity и т.д.) при дефолтном `setOthersFalse` без изменений в их конфигах.

## Testing completion criteria

- INT2 automation path is green for discovery and execution via `systemactions/clearing`.
- Product and QA acceptance are documented explicitly in `acceptance-criteria.md`.
- Execution evidence is captured in `test-execution-summary.md`.
- Remaining environment/manual gaps are documented, not implied.
