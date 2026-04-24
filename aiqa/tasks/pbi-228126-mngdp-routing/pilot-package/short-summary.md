# Pilot summary — PBI 228126 / MNGDP Routing

## Что это за задача

Задача `pbi-228126-mngdp-routing` описывает фичу маршрутизации ордеров для торговой сессии PRE/POST при маршруте MNGD (default). Основной эффект: для Apex (Instinet) ордеров с базовым маршрутом MNGD (*_defaultRouteId*) в сессиях PRE или POST тег 57 переопределяется на MNGDP вместо MNGD. Дополнительно для POST сессии устанавливается Tag 336 = 4, а для опционов добавляются Tag 204 = 8 и Tag 5729 = "VR63".

## Почему выбрана

Эта задача подходит как pilot для QA структуризации по трем причинам:

- она **уже разобрана в существующем package** и имеет явные артефакты: `task-summary.md`, `qa-plan.md`, `test-cases.md`, `open-questions.md` и git diff конвертера;
- она находится внутри текущего **canonical scope framework ETNA_TRADER** и затрагивает критический модуль `OrderConverter.cs`;
- по ней уже есть **tangible evidence**: конкретный коммит `846a39a8ea`, дифф тестовых данных в `OrderTestData_Apex.json`, и матрица тест-кейсов с открытыми вопросами.

## Почему это хороший pilot

Эта задача позволяет показать framework как практический инструмент для QA структуризации:

- можно построить **доказуемый change surface** из явных правил маршрутизации и тегов;
- можно **честно отделить confirmed зависимости** (PRE/POST + MNGD → MNGDP) от **inferred** (ALL + MNGD → MNGDP?) и **unknown** (multileg option behavior);
- можно **вывести risk-based QA план** из уже составленной test matrix и выделить high-risk checks;
- можно показать **AI review/test-design prompts**, которые опираются на evidence (коммит, код, цитаты), а не на догадки.

## Какие зоны затронуты

**Подтвержденные зоны**:

- `ETNA_TRADER/src/Etna.Trading.Components/Etna.Trading.Messages42Apex/OrderConverter.cs` — основной файл изменений;
- `GetRouteId()` / `GetBaseRouteId()` — логика определения маршрута;
- `SetTradingSessionId()` — логика установки Tag 336;
- RepCode логика для `204` и `5729` при опционах;
- Unit-тесты в `OrderTestData_Apex.json` с кейсами для `MngdPreExtendedHoursNewOrder`, `MngdPostExtendedHoursNewOrder`, `MngdOptionNewOrder`.

**Границы пилота**:

- QUIK логика НЕ изменяется и входит в регрессию;
- другие конвертеры (Serenity) НЕ затронуты;
- E2E тестирование требует согласованной dev среды.

## Связанные артефакты

| Артефакт | Статус | Ссылка |
|----------|--------|--------|
| Коммит основной | confirmed | `846a39a8ea` в ветке `228126-New-routing-for-MNGDP` |
| Дифф конвертера | confirmed | `git show 846a39a8ea -- OrderConverter.cs` |
| Дифф тестов | confirmed | `git show 846a39a8ea -- OrderTestData_Apex.json` |
| Test matrix | confirmed | `qa-plan.md` § 6 |
| Open questions | identified | `open-questions.md` |
| Impact / Regression | mapped | `impact-and-regression.md` |
| Test cases | drafted | `test-cases.md` |
