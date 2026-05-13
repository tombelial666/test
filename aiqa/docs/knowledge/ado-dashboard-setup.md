# ADO Dashboard: Operational + Executive

**Проект:** etnasoft / ETNA_TRADER  
**Тип:** Azure DevOps встроенные дашборды (Operational + Executive)  
**Поля:** `Custom.FoundStage`, `Custom.BugType`, `Custom.QaDecision` (создать по [alm-required-fields.md](alm-required-fields.md))

---

## Как это работает

Система состоит из двух дашбордов в Azure DevOps:

- `QA Metrics MVP` (операционный): контроль текущего месяца (`MTD`).
- `QA Metrics Executive` (управленческий): KPI за последние 30 дней (`rolling 30d`).

Источник данных один: Work Items в проекте `ETNA_TRADER` + Shared Queries в папке `Shared Queries/QA Metrics`.

Поток данных:

1. Скрипт `create_ado_queries.py` создаёт/обновляет WIQL-запросы (идемпотентно: существующие не дублируются).
2. Скрипт `create_ado_dashboard.py` создаёт/обновляет дашборды и добавляет виджеты `Query Count` и `Query Results` по этим запросам.
3. Для chart/trend/test/CI виджетов используется ручная настройка в UI (это осознанно, т.к. такие виджеты удобнее и стабильнее конфигурировать через интерфейс).

Что считается автоматически:

- MTD-метрики: через `@StartOfMonth .. @Today`.
- 30-day KPI: через `@Today - 30 .. @Today`.
- Legacy, escaped defects, sign-off нарушения: через фильтры по `Custom.*` полям.

Что НЕ считается автоматически в самом дашборде:

- Формульные коэффициенты (`Bugs per PBI`, `DRE`) как одно вычисляемое число в виджете.
- Для них используется пара счётчиков + расчёт на обзоре (или внешний BI/скрипт).

Автоматизация строгого `Bugs per PBI`:

- Скрипт `test/aiqa/scripts/publish_strict_bugs_per_pbi_summary.py` считает метрику в strict-режиме
  и публикует markdown summary в run pipeline через `##vso[task.uploadsummary]`.
- Готовый pipeline-шаблон: `test/aiqa/scripts/azure-pipelines-qa-metrics-strict-summary.yml`.
- В pipeline используется дефолтный `$(System.AccessToken)` (без отдельного `ADO_PAT`).
- Для webhook-переменных используется variable group `qa-metrics-strict-summary`.

Ожидаемый операционный цикл:

- Ежедневно: смотреть MVP-дашборд (поток, дефекты, sign-off).
- Еженедельно: смотреть executive-дашборд (динамика риска и backlog).
- Ежемесячно: сверять тренд и корректировать цели по legacy/quality gates.

## См. также (визуализация и приёмка)

- [dashboard-widget-map.md](dashboard-widget-map.md) — карта виджетов MVP / Executive
- [dashboard-acceptance-checklist.md](dashboard-acceptance-checklist.md) — чеклист приёмки дашборда и pipeline
- [dashboard-metric-fallbacks.md](dashboard-metric-fallbacks.md) — fallback при неполных полях и данных

---

## План завершения всех настроек

Ниже план именно по оставшимся шагам до полностью рабочего контура.

### Этап 1 — Подключить автоматический strict summary в ADO Pipeline

1. Создать pipeline из файла:
   - `test/aiqa/scripts/azure-pipelines-qa-metrics-strict-summary.yml`
2. Создать variable group `qa-metrics-strict-summary` и добавить ключи:
   - `SLACK_WEBHOOK_URL` (secret, опционально)
   - `SLACK_USER_IDS` (опционально)
3. Включить для pipeline доступ к OAuth token (`Allow scripts to access OAuth token`), чтобы работал `$(System.AccessToken)`.
4. Запустить первый прогон вручную.
5. Проверить результат:
   - открыть `Run Summary`;
   - убедиться, что появился markdown с `Bugs per PBI (strict linked)`.

### Этап 2 — Расширить pipeline вторым job (artifact + уведомления)

Добавить второй job в этот же pipeline:

- публиковать тот же markdown как pipeline artifact;
- отправлять короткий статус в Slack (значение strict-метрики + период + DataStatus).
- добавить переменные через variable group `qa-metrics-strict-summary`:
  - `SLACK_WEBHOOK_URL`
  - `SLACK_USER_IDS` (опционально, CSV из Slack user ID, например: `U01AAA,U02BBB,U03CCC`)

Рекомендуемый формат сообщения:

- `QA strict summary: Bugs per PBI = X.XX (N/D), period YYYY-MM-DD..YYYY-MM-DD, status OK|NO_DATA`

Если webhook не задан, job не падает: artifact всё равно публикуется, в лог пишется `No webhook configured; skip notification.`

Для Slack-упоминаний используется формат `<@USER_ID>`.
Если задать `SLACK_USER_IDS`, уведомление будет отправлено с mention'ами указанных пользователей.

### Этап 3 — Довести визуальный слой MVP-дашборда

Вручную через UI добавить (если ещё не добавлено):

- `Chart for Work Items`: `Bugs by State (MTD)`;
- `Chart for Work Items`: `Bugs by Priority (MTD)`;
- `Chart for Work Items`: `Legacy by State`;
- один трендовый виджет: `CFD` или `Burndown`;
- `Test Results` и `Build/Pipeline Status`.

### Этап 4 — Проверка обязательных ALM-полей

Проверить, что поля существуют и заполнение дисциплинировано:

- `Custom.FoundStage` (Bug),
- `Custom.BugType` (Bug),
- `Custom.QaDecision` (Feature),
- явная связь Bug→Feature/Epic (`System.Parent`).

Для контроля использовать:

- `test/aiqa/scripts/check_bug_fields.py`

### Этап 5 — Приёмка и рабочий регламент

После включения всех пунктов:

- зафиксировать владельца дашборда (QA lead);
- согласовать частоту обзора (ежедневно MVP, еженедельно Executive);
- зафиксировать пороги эскалации (рост prod bugs, рост legacy aging, падение sign-off дисциплины).

---

## Предварительно: создать Shared Queries

**Project Settings → Boards → Queries → Shared Queries** → создать папку `QA Metrics`.

Базовые и расширенные запросы создаются скриптом:

```bash
ADO_PAT=<token> python test/aiqa/scripts/create_ado_queries.py
```

Если нужно только посмотреть, что будет создано:

```bash
ADO_PAT=<token> python test/aiqa/scripts/create_ado_queries.py --dry-run
```

---

## Метрика 1: Баги на PBI (Трек A)

Карточка: два числа рядом — `Bugs New (linked) / Closed Features`.
Ключевое правило: баг считается в числителе только если есть явная planning-связь
с Feature (через `System.Parent`; при вашем контракте это эквивалент `primary_planning_ref`).

### Запрос 1.1 — Confirmed bugs (BugType=New)

**Тип:** Flat list · **Имя:** `QA / Bugs New Confirmed This Month`

```wiql
SELECT [System.Id]
FROM WorkItems
WHERE [System.WorkItemType] = 'Bug'
  AND [Custom.BugType] = 'New'
  AND [System.Parent] <> ''
  AND [System.State] IN ('Approved', 'QA', 'Code Review', 'Committed', 'Completed', 'Done')
  AND [System.CreatedDate] >= @StartOfMonth
  AND [System.CreatedDate] <= @Today
ORDER BY [System.Id]
```

**Виджет:** `Query Count` → выбрать этот запрос → заголовок: `Bugs New (MTD)`.

### Запрос 1.2 — Closed Features this month

**Тип:** Flat list · **Имя:** `QA / Features Closed This Month`

```wiql
SELECT [System.Id]
FROM WorkItems
WHERE [System.WorkItemType] = 'Feature'
  AND [System.State] IN ('Completed', 'Done')
  AND [System.ChangedDate] >= @StartOfMonth
  AND [System.ChangedDate] <= @Today
ORDER BY [System.Id]
```

**Виджет:** `Query Count` → выбрать этот запрос → заголовок: `Features Closed (MTD)`.

> Разместить два виджета рядом.  
> Для строгого расчёта используйте скрипт `collect_q1_metrics.py`: он считает только `BugType=New`,
> у которых `System.Parent` попадает в множество закрытых Features за период.

---

## Метрика 2: Легаси — открыто vs закрыто (Трек B)

### Запрос 2.1 — Legacy bugs opened this month

**Имя:** `QA / Legacy Bugs Opened This Month`

```wiql
SELECT [System.Id]
FROM WorkItems
WHERE [System.WorkItemType] = 'Bug'
  AND [Custom.BugType] = 'Legacy'
  AND [System.CreatedDate] >= @StartOfMonth
  AND [System.CreatedDate] <= @Today
ORDER BY [System.Id]
```

**Виджет:** `Query Count` → заголовок: `Legacy Opened (MTD)`.

### Запрос 2.2 — Legacy bugs closed this month

**Имя:** `QA / Legacy Bugs Closed This Month`

```wiql
SELECT [System.Id]
FROM WorkItems
WHERE [System.WorkItemType] = 'Bug'
  AND [Custom.BugType] = 'Legacy'
  AND [System.State] IN ('Completed', 'Done')
  AND [System.ChangedDate] >= @StartOfMonth
  AND [System.ChangedDate] <= @Today
ORDER BY [System.Id]
```

**Виджет:** `Query Count` → заголовок: `Legacy Closed (MTD)`.

### Запрос 2.3 — Legacy backlog (все открытые)

**Имя:** `QA / Legacy Bugs Open Backlog`

```wiql
SELECT [System.Id]
FROM WorkItems
WHERE [System.WorkItemType] = 'Bug'
  AND [Custom.BugType] = 'Legacy'
  AND [System.State] NOT IN ('Completed', 'Done', 'Removed')
ORDER BY [System.Id]
```

**Виджет:** `Query Count` → заголовок: `Legacy Backlog (Open)`.

> Три виджета в ряд: `Opened | Closed | Total backlog`. Net delta = Opened − Closed.

---

## Метрика 3: Баги, пойманные до прода (stacked bar)

### Запрос 3.1 — Все confirmed bugs с found_stage

**Имя:** `QA / All Confirmed Bugs With Stage`

```wiql
SELECT [System.Id], [Custom.FoundStage]
FROM WorkItems
WHERE [System.WorkItemType] = 'Bug'
  AND [System.State] IN ('Approved', 'QA', 'Code Review', 'Committed', 'Completed', 'Done')
  AND [System.CreatedDate] >= @StartOfMonth
  AND [System.CreatedDate] <= @Today
ORDER BY [System.Id]
```

**Виджет:** `Chart for Work Items` → выбрать запрос → `Group by: Custom.FoundStage` → тип: `Bar` или `Column`.

> Столбцы: dev / qa / preprod / prod. Визуально сразу видно split до прода vs прод.

### Запрос 3.2 — Pre-prod bugs (числитель DRE)

**Имя:** `QA / Bugs Pre-Prod This Month`

```wiql
SELECT [System.Id]
FROM WorkItems
WHERE [System.WorkItemType] = 'Bug'
  AND [System.State] IN ('Approved', 'QA', 'Code Review', 'Committed', 'Completed', 'Done')
  AND [Custom.FoundStage] IN ('dev', 'qa', 'preprod')
  AND [System.CreatedDate] >= @StartOfMonth
  AND [System.CreatedDate] <= @Today
ORDER BY [System.Id]
```

**Виджет:** `Query Count` → заголовок: `Pre-prod Bugs (MTD)`.

### Запрос 3.3 — Prod bugs (escaped defects)

**Имя:** `QA / Bugs Prod This Month`

```wiql
SELECT [System.Id]
FROM WorkItems
WHERE [System.WorkItemType] = 'Bug'
  AND [System.State] IN ('Approved', 'QA', 'Code Review', 'Committed', 'Completed', 'Done')
  AND [Custom.FoundStage] = 'prod'
  AND [System.CreatedDate] >= @StartOfMonth
  AND [System.CreatedDate] <= @Today
ORDER BY [System.Id]
```

**Виджет:** `Query Count` → заголовок: `Prod Bugs (MTD)`.

---

## Метрика 4: DRE — Defect Removal Efficiency

Использует запросы **3.2** и **3.3**.

> DRE = Pre-prod / (Pre-prod + Prod). Два виджета рядом.  
> При обзоре: DRE = Pre-prod count / (Pre-prod + Prod count) × 100%.

**Опция автоматического отображения** — через скрипт `collect_q1_metrics.py`:

```bash
ADO_PAT=<token> python collect_q1_metrics.py --since 2026-05-01 --until 2026-05-12
```

Выводит DRE числом — можно вставить в комментарий на дашборде вручную раз в неделю.

---

## Метрика 5: Дисциплина ALM sign-off

### Запрос 5.1 — Все закрытые Features (знаменатель)

Уже создан: **1.2** (`QA / Features Closed This Month`).

### Запрос 5.2 — Закрытые Features БЕЗ qa_decision (нарушители)

**Имя:** `QA / Features Missing QA Decision`

```wiql
SELECT [System.Id], [System.Title], [Custom.QaDecision]
FROM WorkItems
WHERE [System.WorkItemType] = 'Feature'
  AND [System.State] IN ('Completed', 'Done')
  AND [Custom.QaDecision] = ''
  AND [System.ChangedDate] >= @StartOfMonth
  AND [System.ChangedDate] <= @Today
ORDER BY [System.ChangedDate] DESC
```

**Виджет 5.2a:** `Query Count` → заголовок: `Closed Features w/o QA Decision`.

**Виджет 5.2b:** `Query Results` → выбрать запрос 5.2 → показывать колонки: `ID`, `Title`, `State`, `QA Decision` → заголовок: `Missing QA Decision (List)`.

> Виджет 5.2b — это сам список нарушителей, видимый на дашборде. Drill-down по ID.

### Запрос 5.3 — Все открытые Features без qa_decision (превентивно)

**Имя:** `QA / Open Features Missing QA Decision`

```wiql
SELECT [System.Id], [System.Title]
FROM WorkItems
WHERE [System.WorkItemType] = 'Feature'
  AND [System.State] NOT IN ('Completed', 'Done', 'Removed')
  AND [Custom.QaDecision] = ''
ORDER BY [System.ChangedDate] DESC
```

**Виджет:** `Query Count` → заголовок: `Open Features w/o QA Decision`.

---

## Структура Operational-дашборда

### Строка 1 — Результат

| Виджет | Тип | Запрос |
|--------|-----|--------|
| Bugs New (MTD) | Query Count | 1.1 |
| Features Closed (MTD) | Query Count | 1.2 |
| Legacy Opened (MTD) | Query Count | 2.1 |
| Legacy Closed (MTD) | Query Count | 2.2 |
| Legacy Backlog (Open) | Query Count | 2.3 |

### Строка 2 — Удержание дефектов

| Виджет | Тип | Запрос |
|--------|-----|--------|
| Bugs by found_stage | Chart for Work Items (Column) | 3.1 |
| Pre-prod Bugs (MTD) | Query Count | 3.2 |
| Prod Bugs (MTD) | Query Count | 3.3 |

### Строка 3 — ALM sign-off

| Виджет | Тип | Запрос |
|--------|-----|--------|
| Closed Features w/o QA Decision | Query Count | 5.2 |
| Open Features w/o QA Decision | Query Count | 5.3 |
| Missing QA Decision (List) | Query Results | 5.2 |

---

## Добавить chart-виджеты (State/Priority)

Новые запросы для распределений создаются автоматически скриптом `create_ado_queries.py`:

- `QA Bugs By State This Month`
- `QA Bugs By Priority This Month`
- `QA Legacy Bugs By State`

Для каждого запроса добавьте `Chart for Work Items`:

1. `Add Widget` → `Chart for Work Items`
2. `Configure` → выбрать соответствующий query
3. Настроить:
   - Bugs by State: `Group By = State`, тип `Stacked bar`
   - Bugs by Priority: `Group By = Priority`, тип `Column`
   - Legacy by State: `Group By = State`, тип `Stacked bar`

Рекомендованные заголовки:
- `Bugs by State (MTD)`
- `Bugs by Priority (MTD)`
- `Legacy by State`

---

## Добавить тренды (CFD/Burndown)

Для ключевой доски команды добавьте один трендовый виджет:

- `Cumulative Flow Diagram` для поиска узких мест в QA-потоке, или
- `Sprint Burndown` для контроля предсказуемости спринта.

Рекомендуется начать с одного виджета (CFD), чтобы не перегружать экран.

---

## Добавить тесты и CI

В Operational-дашборд добавьте ещё 2 виджета:

- `Test Results` (за последние 7/14 дней)
- `Build History` или `Pipeline Status` для ключевого пайплайна (`main`/`release`)

Это даёт быстрый сигнал по регрессиям и стабильности перед релизом.

---

## Executive-дашборд (4–6 KPI)

Используйте отдельный дашборд: `QA Metrics Executive`.

Он создаётся тем же скриптом:

```bash
ADO_PAT=<token> python test/aiqa/scripts/create_ado_dashboard.py --team "QA" --dashboard exec
```

Виджеты KPI (rolling 30 days):

- `Prod Bugs (30d)`
- `Features Closed (30d)`
- `Legacy Backlog (Open)`
- `Legacy Opened (30d)`
- `Legacy Closed (30d)`
- `Legacy Aging 30d+`

Скрипт создаёт и Operational, и Executive дашборды:

```bash
ADO_PAT=<token> python test/aiqa/scripts/create_ado_dashboard.py --team "QA" --dashboard all
```

---

## Как создать дашборды в ADO

1. **Dashboards** → `+ New Dashboard` → имя: `QA Metrics MVP`
2. **Edit** → добавить виджеты (`Add Widget`)
3. Для `Query Count`:
   - Widget: `Query Results` / `Query Count` из каталога
   - Configure → выбрать Shared Query
4. Для `Chart for Work Items`:
   - Widget: `Chart for Work Items`
   - Configure → выбрать запрос → настроить Group By и Chart type
5. Для `Query Results`:
   - Widget: `Query Results`
   - Configure → выбрать запрос → выбрать колонки

---

## Ограничения встроенного дашборда

| Что нужно | Ограничение | Обходной путь |
|-----------|-------------|---------------|
| Ratio (Bugs/PBI, DRE) | Нет widget-а с формулой | Два Query Count рядом + ручной расчёт при обзоре |
| Trend line за 3–6 месяцев | Нет из коробки без Analytics Views | Пока: ежемесячный snapshot в таблицу; позже — Analytics + Power BI |
| Group by `Custom.FoundStage` | Может потребовать включения Analytics | Project Settings → Analytics → Enable |
| Drill-down в список | Query Results widget поддерживает | Настроить Query Results для каждой метрики |

---

## Включить Analytics (если отключено)

`Project Settings` → `General` → `Overview` → `Analytics` → Enable.

После включения Analytics:
- кастомные поля `Custom.*` доступны для группировки в `Chart for Work Items`
- появляются виджеты `Analytics` (Burnup, CFD, Velocity)

---

## @StartOfMonth в WIQL

`@StartOfMonth` — встроенная макро ADO WIQL, возвращает первый день текущего месяца.  
Если не поддерживается в вашей версии ADO → заменить фиксированной датой: `'2026-05-01'`.

Также доступно: `@Today - 30` для последних 30 дней.
