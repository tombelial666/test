# Bug 228296 — Adjust tags for Coda venue

QA-пакет в рамках [`aiqa/MANIFEST.md`](../../MANIFEST.md) и шаблона [`templates/task-handoff-and-impact-prompt.md`](../../templates/task-handoff-and-impact-prompt.md).

## Артефакты (обязательный набор по разбору задачи)

| Файл | Назначение |
|------|------------|
| [`task.yaml`](task.yaml) | Метаданные задачи по [`task-schema.yaml`](../../task-schema.yaml): id, repos, domains, evidence, unknowns |
| [`requirements-from-discussion.md`](requirements-from-discussion.md) | Финальные бизнес-правила: legacy vs new Coda mode, таблицы Tag59/Tag100, разрешение конфликтов в discussion |
| [`handoff-and-impact.md`](handoff-and-impact.md) | Полный handoff: executive summary, changed surface, AC, impact, open questions, QA plan, test cases (ссылка), automation, readiness, targeted indexing |
| [`pr-15539-short-test-plan.md`](pr-15539-short-test-plan.md) | Детальные TC (TC-15539-01…06), traceability Req→TC, entry/exit критерии |

## Репозитории

| Роль | Путь / ссылка |
|------|----------------|
| Код (enterprise) | `ETNA_TRADER`, ветка `feature/adjust-fix-tags-for-coda-venue` |
| Документация (wiki) | `ETNA_TRADER.wiki` — PR в workspace: `D:\DevReps\ETNA_TRADER.wiki` (сверка с продуктовым описанием и operational notes) |

## Кодовые якоря для проверки (ожидаемые)

- `ETNA_TRADER/src/Etna.Trading.Connectivity/ExecutionVenueIntegration/Etna.Trading.ExecutionVenue.PDQ/PDQOrderConvertor.cs`
- `ETNA_TRADER/src/Etna.Trading/Etna.Trading/Settings/SettingKeys.cs`

## Важно

Локальный checkout `ETNA_TRADER` может не совпадать с PR — перед исполнением тестов выполнить сверку с `origin/feature/adjust-fix-tags-for-coda-venue` и Azure DevOps **PR 15539**.
