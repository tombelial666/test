# BUG-STEP5-004 — проверка путей и глобов в `impact-map.yaml`

**Тип работ:** только валидация и фиксация доказательств (Step 5.1 hard validation).  
**Источники:** `aiqa/impact-map.yaml`, `aiqa/repo-index.yaml`, `aiqa/docs/references/step-5-assumptions.md`.  
**Примечание:** файл `aiqa/docs/references/step-5-1-hard-validation-backlog.md` в рабочей копии отсутствует (поиск по репозиторию — 0 файлов); согласование с бэклогом с диска не выполнялось.

---

## 1. Summary

По фактическому дереву `ETNA_TRADER`, `qa/` и `ETNA_TRADER/qa/`:

- Паттерн **`ETNA_TRADER/src/**/Contracts/**/*.cs`** в правиле `etna-trader-src-to-qa-surface` **не соответствовал** реальным корням C#-контрактов: в `src` нет сегмента пути `Contracts/` как отдельной папки; проекты называются `Etna.Trader.*.Contracts` и `Etna.Trader.Contracts.*`. Поиск `**/Contracts/**/*.cs` под `ETNA_TRADER` для `.cs` давал **0 файлов** в ожидаемых контрактных библиотеках.
- Паттерн **`ETNA_TRADER/src/**/Etna.Trader.WebApi.*/**`** покрывает основной кластер WebApi под `src/Etna.Trader/`, но **не покрывает** отдельный проект **`Etna.Trading.TradeStation.WebApi`** (`ETNA_TRADER/src/Customization/TradeStation/Etna.Trading.TradeStation.WebApi/`).
- Правило **`standalone-qa-fixtures-to-trader`** перечисляет три корня под автономным `qa/`; остальные одноимённые/смежные QA-корни **не входят** в триггеры — это сознательно узкий срез или пробел (см. ниже).
- Каталог **`ETNA_TRADER/qa/`** (тесты внутри платформенного репозитория) **ни в одном** `when.any_paths` текущей карты не фигурирует; связь с автономным `qa/` через триггеры не моделируется.

В `impact-map.yaml` внесены **минимальные правки** только там, где расхождение с деревом было однозначно доказано см. раздел 5 и дифф в репозитории.

---

## 2. Tree evidence reviewed

### 2.1 C#-контракты (`ETNA_TRADER/src`)

Под `ETNA_TRADER/src/Etna.Trader/` обнаружены **ровно восемь** каталогов проектов с `Contracts` в имени (все с `.csproj`):

| Путь от корня репозитория |
|---------------------------|
| `ETNA_TRADER/src/Etna.Trader/Etna.Trader.AccountManagement.Contracts/` |
| `ETNA_TRADER/src/Etna.Trader/Etna.Trader.ClickAcceptor.Contracts/` |
| `ETNA_TRADER/src/Etna.Trader/Etna.Trader.Contracts.BatchesManager/` |
| `ETNA_TRADER/src/Etna.Trader/Etna.Trader.Contracts.Common/` |
| `ETNA_TRADER/src/Etna.Trader/Etna.Trader.Contracts.ExternalApi/` |
| `ETNA_TRADER/src/Etna.Trader/Etna.Trader.Contracts.Rebalancer/` |
| `ETNA_TRADER/src/Etna.Trader/Etna.Trader.Contracts.TradeUp/` |
| `ETNA_TRADER/src/Etna.Trader/Etna.Trader.Keycloak.Contracts/` |

Пример реального файла DTO: `ETNA_TRADER/src/Etna.Trader/Etna.Trader.Keycloak.Contracts/dtos/UserDto.cs`.

Дополнительно: под `ETNA_TRADER/frontend/ACAT/src/services/contracts/` есть TypeScript-файлы (`index.ts`, `common.ts`, …) — они **не** попадают под паттерн `**/*.cs` и в правило `etna-trader-src-to-qa-surface` по текущей формулировке не входят.

### 2.2 WebApi-проекты (`ETNA_TRADER/src`)

По поиску `**/*WebApi*.csproj` под `ETNA_TRADER/src` — **8** проектов:

**Семь** с префиксом `Etna.Trader.WebApi.*` (все под `ETNA_TRADER/src/Etna.Trader/`):

- `Etna.Trader.WebApi.Controllers`
- `Etna.Trader.WebApi.Core`
- `Etna.Trader.WebApi.Customization`
- `Etna.Trader.WebApi.Host`
- `Etna.Trader.WebApi.Quote.Host`
- `Etna.Trader.WebApi.Security.Host`
- `Etna.Trader.WebApi.Tests`

**Один** с другим именем:

- `ETNA_TRADER/src/Customization/TradeStation/Etna.Trading.TradeStation.WebApi/Etna.Trading.TradeStation.WebApi.csproj`

### 2.3 Автономный корень `qa/` (DevReps)

Прямые дочерние каталоги `qa/` (PowerShell `Get-ChildItem -Directory`):

`.nuget`, `AI-framework-4-myMommy`, `Etna.QA.SpecFlow.Examples`, `Etna.QA.TestAutomation.Examples`, `Etna.QA.TestAutomation.Framework`, `Etna.TestIntegration.Activities`, `Etna.TestIntegration.WebService`, `Etna.TestIntegrationApp`, `Etna.Trader.DailyCheckResults`, `Etna.Trader.WebService`, `Etna_QA_BackendTests_Models`, `Etna_QA_BackendTests_WebApi`, `Etna_QA_UITests_RA`, `Tools`.

Из них в `standalone-qa-fixtures-to-trader` явно указаны только:

- `qa/Etna_QA_BackendTests_WebApi/**`
- `qa/Etna_QA_BackendTests_Models/**`
- `qa/Etna.Trader.WebService/**`

### 2.4 Внутренний QA под `ETNA_TRADER/qa/`

Прямые дочерние каталоги `ETNA_TRADER/qa/` включают, среди прочего, `Etna.Trader.*.Tests`, `Etna.BackEnd.Tests`, `TradingTestsForWebServices`, `lib`, `JmeterScripts`, `StressTests` и т.д. — **ни один** путь `ETNA_TRADER/qa/**` не присутствует в `when.any_paths` текущей карты.

---

## 3. Current pattern vs real tree comparison

| Rule ID | Pattern | Сопоставление с деревом |
|---------|---------|-------------------------|
| `etna-trader-src-to-qa-surface` | `ETNA_TRADER/src/**/Etna.Trader.WebApi.*/**` | Совпадает с семью проектами под `Etna.Trader`; **не** совпадало с `Etna.Trading.TradeStation.WebApi` до добавления отдельной строки. |
| `etna-trader-src-to-qa-surface` | (было) `ETNA_TRADER/src/**/Contracts/**/*.cs` | **Не** совпадало с реальными путями контрактных проектов (нет сегмента `/Contracts/`). |
| `etna-trader-src-to-qa-surface` | (стало) `ETNA_TRADER/src/**/*Contracts*/**/*.cs` | Покрывает все 8 каталогов из §2.1; других каталогов `*Contracts*` под `src` не найдено. |
| `standalone-qa-fixtures-to-trader` | Три префикса под `qa/` | Пути **существуют** и соответствуют ожидаемым корням; относительно полного списка QA-корней (§2.3) — **узко**. |
| *(отсутствует в карте)* | — | `ETNA_TRADER/qa/**` не покрыт триггерами для cross-impact с автономным `qa/`. |

---

## 4. Findings per target area

### 4.1 Contracts

| Вердикт | Обоснование |
|---------|-------------|
| **Исправлено (было некорректно)** | Старый glob ожидал вложенную папку `Contracts`, которой в C#-дереве для этих проектов нет; контрактный код лежит в папках с суффиксом/вставкой `Contracts` в **имени** проекта. |
| **Консервативно / неполно (осознанно)** | TypeScript-«contracts» в `frontend/.../contracts/` и возможные другие не-`src` поверхности не входят в текущие `any_paths`. Согласуется с `step-5-assumptions.md`: перечисление не претендует на полноту всех точек интеграции. |

### 4.2 WebApi

| Вердикт | Обоснование |
|---------|-------------|
| **Подтверждено** для `Etna.Trader.WebApi.*` | Все семь основных проектов лежат под `ETNA_TRADER/src/Etna.Trader/Etna.Trader.WebApi.*/`. |
| **Исправлено (было слишком узко)** | `Etna.Trading.TradeStation.WebApi` не удовлетворял `Etna.Trader.WebApi.*`; добавлен явный префикс. |
| **Не слишком широко** | Добавление одной известной папки не расширяет срабатывание на произвольные `*WebApi*` вне перечня (альтернатива `**/*WebApi*/**` была бы шире и не использовалась). |

### 4.3 QA roots

**Автономный `qa/` (правило `standalone-qa-fixtures-to-trader`):**

| Вердикт | Обоснование |
|---------|-------------|
| **Подтверждено** для трёх перечисленных путей | `qa/Etna_QA_BackendTests_WebApi`, `qa/Etna_QA_BackendTests_Models`, `qa/Etna.Trader.WebService` присутствуют на диске. |
| **Слишком узко** относительно полного набора Etna-связанных корней на верхнем уровне `qa/` | Не охватывает, например, `Etna.QA.*`, `Etna.TestIntegration.*`, `Etna.Trader.DailyCheckResults`, `Etna_QA_UITests_RA`, `Tools/**` (в т.ч. FIX-инструменты с `Etna.Trader.*`). Это не ошибка glob для перечисленных строк, а **ограниченность набора** триггеров. |

**`ETNA_TRADER/qa/`:**

| Вердикт | Обоснование |
|---------|-------------|
| **Явно неполно / вне scope текущих триггеров** | Ни одно правило в `impact-map.yaml` не содержит `ETNA_TRADER/qa/**`. Изменения только там не активируют `etna-trader-src-to-qa-surface` (оно смотрит на `ETNA_TRADER/src/...`). |

---

## 5. Recommended corrections

Уже применено в `aiqa/impact-map.yaml` (минимальный дифф):

1. **Контракты:** заменить `ETNA_TRADER/src/**/Contracts/**/*.cs` на **`ETNA_TRADER/src/**/*Contracts*/**/*.cs`** — одна строка, покрывает все восемь наблюдённых контрактных корней без ложных совпадений по другим каталогам под `src`.
2. **WebApi:** добавить **`ETNA_TRADER/src/**/Etna.Trading.TradeStation.WebApi/**`** — покрывает единственный обнаруженный WebApi-проект вне префикса `Etna.Trader.WebApi.*`.

Опционально на будущее (не вносилось, чтобы не расширять scope без запроса):

- Дополнительные `any_paths` под `qa/` для остальных Etna-корней из §2.3, если политика impact — «любое изменение автономного QA, связанного с Etna».
- Отдельное правило или строки для **`ETNA_TRADER/qa/**`**, если нужна симметрия с автономным `qa/` (сейчас это дыра относительно «двух корней QA», описанных в `repo-index.yaml` / assumptions).

---

## 6. Go / No-Go for closing BUG-STEP5-004

**Go**, при условии принятия следующего:

- Паттерны по **Contracts** и **WebApi** в `etna-trader-src-to-qa-surface` приведены в соответствие с доказательствами по дереву (§2–§3).
- Область **QA roots** явно зафиксирована как **консервативно неполная**: три автономных пути подтверждены; остальные корни `qa/` и весь **`ETNA_TRADER/qa/`** не входят в триггеры — это задокументировано как ограничение карты, а не как подтверждённое полное покрытие.

Если для закрытия бага требуется **полное** покрытие всех QA-корней триггерами — до добавления путей или отдельного правила под `ETNA_TRADER/qa/**` статус оставался бы **No-Go**; по текущим входным ограничениям («минимальная карта», assumptions) достаточно явной маркировки **conservative/incomplete** для QA roots.
