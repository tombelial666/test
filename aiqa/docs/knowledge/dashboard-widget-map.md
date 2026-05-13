# Карта виджетов: QA Metrics MVP + Executive

Справочник для ручной сборки дашборда в ADO, когда **Shared Queries уже есть**, а **кастомные поля** могут быть ещё не готовы. Подробные WIQL и метрики см. [ado-dashboard-setup.md](ado-dashboard-setup.md).

**Папка запросов:** `Shared Queries/QA Metrics`  
**Дашборды:** `QA Metrics MVP` (операционный), `QA Metrics Executive` (управленческий)

---

## QA Metrics MVP — порядок строк

### Строка 1 — Результат (счётчики)

| Порядок | Заголовок виджета | Тип виджета | Shared Query (имя) |
|--------:|-------------------|-------------|---------------------|
| 1 | Bugs New (MTD) | Query Count | `QA / Bugs New Confirmed This Month` |
| 2 | Features Closed (MTD) | Query Count | `QA / Features Closed This Month` |
| 3 | Legacy Opened (MTD) | Query Count | `QA / Legacy Bugs Opened This Month` |
| 4 | Legacy Closed (MTD) | Query Count | `QA / Legacy Bugs Closed This Month` |
| 5 | Legacy Backlog (Open) | Query Count | `QA / Legacy Bugs Open Backlog` |

Рядом с парой **1.1 + 1.2** держите визуально «числитель / знаменатель» для обсуждения strict Bugs per PBI (точное число — pipeline summary или скрипт).

### Строка 2 — Удержание дефектов (стадия / DRE-входные)

| Порядок | Заголовок виджета | Тип виджета | Shared Query |
|--------:|-------------------|-------------|----------------|
| 1 | Bugs by found_stage (MTD) | Chart for Work Items (Column / Bar) | `QA / All Confirmed Bugs With Stage` — **Group by:** `Custom.FoundStage` |
| 2 | Pre-prod Bugs (MTD) | Query Count | `QA / Bugs Pre-Prod This Month` |
| 3 | Prod Bugs (MTD) | Query Count | `QA / Bugs Prod This Month` |

### Строка 3 — ALM sign-off

| Порядок | Заголовок виджета | Тип виджета | Shared Query |
|--------:|-------------------|-------------|----------------|
| 1 | Closed Features w/o QA Decision | Query Count | `QA / Features Missing QA Decision` |
| 2 | Open Features w/o QA Decision | Query Count | `QA / Open Features Missing QA Decision` |
| 3 | Missing QA Decision (List) | Query Results | `QA / Features Missing QA Decision` (колонки: ID, Title, State, QA Decision) |

### Строка 4 — Распределения (после появления запросов из скрипта)

| Порядок | Заголовок виджета | Тип виджета | Shared Query | Настройка chart |
|--------:|-------------------|-------------|----------------|-----------------|
| 1 | Bugs by State (MTD) | Chart for Work Items | `QA Bugs By State This Month` | Group by: **State**, stacked bar |
| 2 | Bugs by Priority (MTD) | Chart for Work Items | `QA Bugs By Priority This Month` | Group by: **Priority**, column |
| 3 | Legacy by State | Chart for Work Items | `QA Legacy Bugs By State` | Group by: **State**, stacked bar |

Имена запросов создаются `create_ado_queries.py`; если в проекте другое имя — подставьте фактическое из UI.

### Строка 5 — Тренд и качество поставки (без WIQL)

| Порядок | Заголовок | Тип | Примечание |
|--------:|-----------|-----|------------|
| 1 | CFD или Burndown | Cumulative Flow Diagram **или** Sprint Burndown | Один виджет, чтобы не перегружать доску |
| 2 | Test Results | Test Results | Окно 7–14 дней |
| 3 | Build / Pipeline | Build History или Pipeline Status | Ветка `main` / ключевой release pipeline |

---

## QA Metrics Executive — KPI (rolling 30d)

Один ряд или две строки по 3 виджета; заголовки с суффиксом `(30d)` для отличия от MTD.

| KPI | Тип | Источник |
|-----|-----|----------|
| Prod Bugs (30d) | Query Count | Запрос с окном `@Today - 30 .. @Today` и `Custom.FoundStage = prod` (см. скрипт/дашборд exec в [ado-dashboard-setup.md](ado-dashboard-setup.md)) |
| Features Closed (30d) | Query Count | Аналог 1.2 на 30 дней |
| Legacy Backlog (Open) | Query Count | Тот же запрос, что и MVP backlog (глобальный снимок) |
| Legacy Opened (30d) | Query Count | Аналог 2.1 на 30 дней |
| Legacy Closed (30d) | Query Count | Аналог 2.2 на 30 дней |
| Legacy Aging 30d+ | Query Count | Запрос «legacy открыты старше 30 дней» (создаётся скриптом для exec) |

Точные имена shared queries для Executive синхронизируйте с выводом `create_ado_dashboard.py` / `create_ado_queries.py` после первого прогона в ADO.

---

## Чеклист перед «Edit dashboard»

- [ ] Папка `Shared Queries/QA Metrics` видна и запросы открываются без ошибки.
- [ ] Для chart по `Custom.FoundStage` включён **Analytics** (если группировка не доступна — см. [dashboard-metric-fallbacks.md](dashboard-metric-fallbacks.md)).
- [ ] У команды выбран правильный **Team** и дашборд привязан к нужному проекту.

---

## Связанные документы

- [ado-dashboard-setup.md](ado-dashboard-setup.md) — WIQL, этапы, pipeline strict summary
- [dashboard-acceptance-checklist.md](dashboard-acceptance-checklist.md) — приёмка визуального слоя
- [dashboard-metric-fallbacks.md](dashboard-metric-fallbacks.md) — поведение при пустых полях и данных
