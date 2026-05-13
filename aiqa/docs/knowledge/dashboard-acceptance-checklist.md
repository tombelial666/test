# Приёмка визуального слоя дашбордов (MVP + Executive)

Чеклист для **после** выдачи прав и появления данных/полей. До этого момента можно использовать как **definition of done** при планировании.

См. также: [dashboard-widget-map.md](dashboard-widget-map.md), [ado-dashboard-setup.md](ado-dashboard-setup.md).

## Прогресс (без доступа к ADO UI)

Уже закрыто на стороне репозитория:

- [x] Карта виджетов — [dashboard-widget-map.md](dashboard-widget-map.md)
- [x] Fallback и риски при пустых полях — [dashboard-metric-fallbacks.md](dashboard-metric-fallbacks.md)
- [x] Ссылка из основного гайда — [ado-dashboard-setup.md](ado-dashboard-setup.md) (раздел «См. также»)

Остаётся после выдачи прав (разделы A–G ниже):

- [ ] проверки в Azure DevOps по чеклисту

---

## A. Shared Queries и доступ

- [ ] Папка `Shared Queries/QA Metrics` существует, запросы не пустые при открытии в редакторе.
- [ ] Все запросы из [dashboard-widget-map.md](dashboard-widget-map.md) находятся и выполняются без ошибки WIQL.
- [ ] У роли, которая смотрит дашборд, есть право **View work items** (минимум) на эти запросы.

---

## B. QA Metrics MVP — обязательный минимум

- [ ] **Строка 1:** пять виджетов Query Count (Bugs New, Features Closed, Legacy Opened/Closed, Legacy Backlog) — числа осмысленны, не все нули без объяснения.
- [ ] **Строка 2:** chart по found_stage + два счётчика Pre-prod / Prod (или пометка «ожидаем поля FoundStage» по [dashboard-metric-fallbacks.md](dashboard-metric-fallbacks.md)).
- [ ] **Строка 3:** два счётчика sign-off + один Query Results со списком нарушителей (drill-down по ID работает).
- [ ] Заголовки виджетов совпадают с согласованными (суффикс `(MTD)` где нужно).

---

## C. QA Metrics MVP — расширение (после скрипта запросов)

- [ ] Три chart: Bugs by State, Bugs by Priority, Legacy by State — корректная группировка и тип графика.
- [ ] Один трендовый виджет: CFD **или** Burndown — выбран и зафиксирован в регламенте команды.
- [ ] Test Results за 7–14 дней подключены к нужному build/test plan.
- [ ] Build History / Pipeline Status указывает на ключевой pipeline (main/release).

---

## D. QA Metrics Executive

- [ ] Дашборд `QA Metrics Executive` создан и отделён от MVP.
- [ ] Все KPI с меткой `(30d)` используют окно **последние 30 дней**, а не MTD.
- [ ] Legacy Aging 30d+ отображается и согласован с бизнес-интерпретацией (что считаем «aging»).

---

## E. Strict summary (pipeline, не UI)

- [ ] Pipeline `QA Metrics Strict Summary` создан из актуального YAML (см. [ado-dashboard-setup.md](ado-dashboard-setup.md)).
- [ ] Variable group `qa-metrics-strict-summary`, OAuth token для скриптов включён.
- [ ] Job `strict_summary`: в Run Summary есть markdown с **Bugs per PBI (strict linked)**.
- [ ] Job `strict_artifact_and_notify`: артефакт `qa-strict-summary` / `strict-bugs-per-pbi-summary.md` присутствует.
- [ ] Slack (если настроен): сообщение пришло, упоминания из `SLACK_USER_IDS` корректны.

---

## F. Ограничения и честность данных

- [ ] В описании дашборда (или отдельной заметке) указано: **DRE и Bugs/PBI в виджетах — пара чисел**, не формула в UI.
- [ ] Зафиксирован владелец дашборда и частота обзора (ежедневно MVP / еженедельно Executive).

---

## G. Критерий «готово к демо руководству»

- [ ] За 2 минуты можно объяснить: поток дефектов, legacy, prod vs pre-prod, дисциплину sign-off, откуда берётся strict Bugs per PBI.
- [ ] Есть один слайд или абзац «DataStatus / известные пробелы в полях» — без сюрпризов на вопросах.
