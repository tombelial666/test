# PBI 228126 / Feature 226956 — [AM] New routing for MNGDP

## Идентификаторы

| Поле | Значение |
|------|----------|
| Feature | 226956 |
| PBI | 228126 |
| Область | ETNA_TRADER\Platform |
| Основной файл | `ETNA_TRADER/src/Etna.Trading.Components/Etna.Trading.Messages42Apex/OrderConverter.cs` |
| Ветка (remote) | `origin/228126-New-routing-for-MNGDP` |
| Ключевой коммит (анализ) | `846a39a8ea` |
| PR (Azure DevOps) | 15533 — **не сверялся** с коммитом в этой среде; сверять вручную |

## Краткое содержание изменения

Для исходящих Apex (Instinet) ордеров с **базовым маршрутом MNGD** (`_defaultRouteId`) при сессиях **PRE/POST** в тег **57** подставляется **MNGDP**. Для **POST** и базового MNGD после `SetTradingSessionId` выполняется **принудительно `336 = 4`**. Для **базового MNGD** и **single-leg Option** задаются **`204 = 8`** и **`5729 = "VR63"`** (override логики RepCode для 204). Добавлены кейсы в `OrderTestData_Apex.json`.

## Вердикт QA

**Ready for QA with open questions** — см. `open-questions.md`.

## Источники evidence

| Что | Где |
|-----|-----|
| Дифф конвертера | `git show 846a39a8ea -- src/Etna.Trading.Components/Etna.Trading.Messages42Apex/OrderConverter.cs` в репозитории **ETNA_TRADER** |
| Дифф тестовых данных | `git show 846a39a8ea -- src/Etna.Trading.Components/Etna.Trading.ExecutionVenues.Tests/CommonTests/OrderTestData_Apex.json` |
| Базовое поведение до фичи | ветка `dev` / текущий `OrderConverter.cs` на диске |

## Связанные файлы пакета

- `qa-plan.md` — правила, scope, матрица
- `open-questions.md` — неоднозначности и ответы на analysis_requirements
- `impact-and-regression.md` — риски, регрессия, автоматизация
- `test-cases.md` — детальные тест-кейсы
