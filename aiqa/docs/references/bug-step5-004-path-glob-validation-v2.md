# BUG-STEP5-004 v2 — валидация путей и закрытие (Step 5.1 hard validation)

**Рабочая копия канона:** `D:\DevReps` (`aiqa/`).  
**Свежие деревья (доказательства):** `D:\DevReps_devsync\ETNA_TRADER`, `D:\DevReps_devsync\qa` — файлы в клонах **не** менялись.

**Связанные канонические файлы:** `aiqa/impact-map.yaml`, `aiqa/repo-index.yaml`, `aiqa/docs/references/step-5-assumptions.md`.  
**Файл** `aiqa/docs/references/step-5-1-hard-validation-backlog.md` **отсутствует** в workspace (как в BUG-STEP5-005).

Предшествующие заметки: `aiqa/docs/references/bug-step5-004-path-glob-validation.md` (v1).

---

## 1. Summary

Проверено **текущее** состояние `impact-map.yaml` в `D:\DevReps\aiqa\` и сопоставлено с **фактическими** деревьями из **dev-sync** клонов. Паттерны **Contracts** и **WebApi** в правиле `etna-trader-src-to-qa-surface` признаны **соответствующими** наблюдаемым путям (включая переименование контрактного проекта Keycloak в dev-sync).

**Обязательное закрытие по двум корням QA выполнено в YAML:**

- **Автономный `qa/`** — правило `standalone-qa-fixtures-to-trader` переведено на **явные глобы** `qa/Etna.*/**`, `qa/Etna_*/**`, `qa/Tools/**` плюс **закодированная политика исключений** (комментарий к правилу и строки `required_checks`).
- **`ETNA_TRADER/qa/`** — добавлено отдельное правило **`etna-trader-inrepo-qa-cross-surface`** с триггером **`ETNA_TRADER/qa/**`**.

Дополнительно обновлены формулировки `required_checks` в `etna-trader-src-to-qa-surface`, чтобы явно упоминать оба QA-корня при поиске затронутых поверхностей.

---

## 2. Current impact-map state reviewed

До правок v2 в каноне уже было:

- `etna-trader-src-to-qa-surface`:  
  `ETNA_TRADER/src/**/Etna.Trader.WebApi.*/**`,  
  `ETNA_TRADER/src/**/Etna.Trading.TradeStation.WebApi/**`,  
  `ETNA_TRADER/src/**/*Contracts*/**/*.cs`
- `standalone-qa-fixtures-to-trader`: три **конкретных** префикса (`Etna_QA_BackendTests_WebApi`, `Etna_QA_BackendTests_Models`, `Etna.Trader.WebService`).
- **Отсутствовало** любое правило с `ETNA_TRADER/qa/**`.

---

## 3. Fresh tree evidence reviewed

Команды: PowerShell `Get-ChildItem` по каталогам dev-sync (без обращения к `$_` в сломанном виде).

### 3.1 `ETNA_TRADER/qa/` — верхний уровень (`D:\DevReps_devsync\ETNA_TRADER\qa`)

```
.nuget
CertificationTests
Etna.BackEnd.Tests
Etna.Common.Integration.Tests
Etna.MarketData.Tests
Etna.TestUtils
Etna.TimeSeries.Tests
Etna.Trader.BackEnd.Tests
Etna.Trader.Backoffice.Tests
Etna.Trader.Db.Tests
Etna.Trader.FrontOffice.Tests
Etna.Trader.GatewayCertificationTests
Etna.Trader.MarketScanner.Tests
Etna.Trader.MarketScannerPerformance.Test
Etna.Trader.Mobile.Tests
Etna.Trader.Oms.IOrderProcessor.Tests
Etna.Trader.OmsWebService.Tests
Etna.Trader.PageObjects
Etna.Trader.ReportsDeliveryTests
Etna.Trader.Sandbox
Etna.Trader.Sandbox.Base
Etna.Trader.Sandbox.Express
Etna.Trader.Security.Tests
Etna.Trader.TestExecutorService
Etna.Trader.Tests.Common
Etna.Trader.Tests.Utils
Etna.Trader.TimeSeries.SplitMerge
Etna.Trader.XmlTransformator
Etna.Trading.Oms.Dal.Test
Etna.Trading.Oms.Data
Etna.Trading.Oms.Data.Test
Etna.Trading.Oms.Integration.Tests
JmeterScripts
lib
StressTests
TimeSeriesTest
TradingTestCases
TradingTestsForFrontOffice
TradingTestsForWebServices
```

### 3.2 Автономный `qa/` — верхний уровень (`D:\DevReps_devsync\qa`)

```
.nuget
Etna.QA.SpecFlow.Examples
Etna.QA.TestAutomation.Examples
Etna.QA.TestAutomation.Framework
Etna.TestIntegration.Activities
Etna.TestIntegration.WebService
Etna.TestIntegrationApp
Etna.Trader.DailyCheckResults
Etna.Trader.WebService
Etna_QA_BackendTests_Models
Etna_QA_BackendTests_WebApi
Etna_QA_UITests_RA
Tools
```

Подкаталоги `qa/Tools`:

```
AccountCreating
ClearingTester
FIX
FrontEndRegistrationLauncher
WebsocketLoadTesting
```

### 3.3 C#-контракты — `D:\DevReps_devsync\ETNA_TRADER\src\Etna.Trader` (папки с `Contracts` в имени)

```
Etna.Trader.AccountManagement.Contracts
Etna.Trader.ClickAcceptor.Contracts
Etna.Trader.Contracts.BatchesManager
Etna.Trader.Contracts.Common
Etna.Trader.Contracts.ExternalApi
Etna.Trader.Contracts.Keycloak
Etna.Trader.Contracts.Rebalancer
Etna.Trader.Contracts.TradeUp
```

*Замечание:* в основном workspace v1 фигурировал `Etna.Trader.Keycloak.Contracts`; в **dev-sync** — **`Etna.Trader.Contracts.Keycloak`**. Оба варианта покрываются глобом `**/*Contracts*/**/*.cs`.

### 3.4 WebApi — `*WebApi*.csproj` под `D:\DevReps_devsync\ETNA_TRADER\src` (относительные пути)

```
ETNA_TRADER/src/Customization/TradeStation/Etna.Trading.TradeStation.WebApi/Etna.Trading.TradeStation.WebApi.csproj
ETNA_TRADER/src/Etna.Trader/Etna.Trader.WebApi.Controllers/Etna.Trader.WebApi.Controllers.csproj
ETNA_TRADER/src/Etna.Trader/Etna.Trader.WebApi.Core/Etna.Trader.WebApi.Core.csproj
ETNA_TRADER/src/Etna.Trader/Etna.Trader.WebApi.Customization/Etna.Trader.WebApi.Customization.csproj
ETNA_TRADER/src/Etna.Trader/Etna.Trader.WebApi.Host/Etna.Trader.WebApi.Host.csproj
ETNA_TRADER/src/Etna.Trader/Etna.Trader.WebApi.Quote.Host/Etna.Trader.WebApi.Quote.Host.csproj
ETNA_TRADER/src/Etna.Trader/Etna.Trader.WebApi.Security.Host/Etna.Trader.WebApi.Security.Host.csproj
ETNA_TRADER/src/Etna.Trader/Etna.Trader.WebApi.Tests/Etna.Trader.WebApi.Tests.csproj
```

---

## 4. Current pattern vs real tree comparison

| Область | Паттерн в карте (после v2) | Сопоставление с dev-sync |
|--------|----------------------------|---------------------------|
| Contracts | `ETNA_TRADER/src/**/*Contracts*/**/*.cs` | **Подтверждено** — все 8 папок из §3.3 содержат подстроку `Contracts` в имени сегмента. |
| WebApi | `.../Etna.Trader.WebApi.*/**` + `.../Etna.Trading.TradeStation.WebApi/**` | **Подтверждено** — совпадает со списком §3.4. |
| Standalone `qa/` | `qa/Etna.*/**`, `qa/Etna_*/**`, `qa/Tools/**` | **Подтверждено** — все перечисленные в §3.2 каталоги, кроме `.nuget`, покрываются; `.nuget` **намеренно вне scope** (см. §7). |
| `ETNA_TRADER/qa/` | `ETNA_TRADER/qa/**` (правило `etna-trader-inrepo-qa-cross-surface`) | **Подтверждено / добавлено** — единый триггер на весь корень in-repo QA, включая все подпапки из §3.1. |

---

## 5. Findings per target area

### 5.1 Contracts

| Классификация | Комментарий |
|---------------|-------------|
| **confirmed** | Глоб `*Contracts*` устойчив к смене порядка слов в имени проекта Keycloak между клонами. |
| **intentionally narrow** | Только `*.cs` под `src`; TS/прочие контракты вне этого правила (как и в v1 / assumptions). |

### 5.2 WebApi

| Классификация | Комментарий |
|---------------|-------------|
| **confirmed** | Все восемь `.csproj` из dev-sync попадают под существующие два паттерна. |
| **remaining limitation** | Другие HTTP-хосты без `WebApi` в имени проекта **не** входят в эти триггеры (намеренный узкий прокси «WebApi по имени проекта»). |

### 5.3 Standalone `qa/`

| Классификация | Комментарий |
|---------------|-------------|
| **was too narrow** (v1) | Три фиксированных пути не покрывали `Etna.QA.*`, `Etna.TestIntegration.*`, `Etna_QA_UITests_RA`, `Tools`, и т.д. |
| **corrected** (v2) | Политика **закодирована в карте**: три глоба + комментарий + `required_checks` с явным исключением `.nuget`. |

### 5.4 `ETNA_TRADER/qa/`

| Классификация | Комментарий |
|---------------|-------------|
| **was missing** | Триггеров не было. |
| **corrected** (v2) | Правило `etna-trader-inrepo-qa-cross-surface` с `ETNA_TRADER/qa/**`; расширение на оба репозитория `ETNA_TRADER` и `qa`. |

---

## 6. YAML corrections applied

**Файл:** `aiqa/impact-map.yaml`

| Изменение | Тип |
|-----------|-----|
| `etna-trader-src-to-qa-surface` — текст проверки: grep по **standalone `qa/` и `ETNA_TRADER/qa/`** | уточнение |
| `standalone-qa-fixtures-to-trader` — замена трёх путей на `qa/Etna.*/**`, `qa/Etna_*/**`, `qa/Tools/**`; комментарий scope; доп. домены; обновлённые `required_checks` | **новая политика + покрытие** |
| Новое правило `etna-trader-inrepo-qa-cross-surface` с `ETNA_TRADER/qa/**` | **обязательное закрытие пробела** |

---

## 7. Remaining intentional limitations

1. **`qa/.nuget/**`** — не входит в триггеры standalone-правила; это **намеренно** (кэш NuGet, не сценарии тестов). Закреплено в комментарии и в `required_checks`.
2. **Поддеревья автономного `qa/` без префикса `Etna` / `Etna_` и не под `Tools`** — в **dev-sync** таких нет (кроме `.nuget`); если появятся (например, сторонний harness), они **вне** текущих глобов до явного расширения карты.
3. **`ETNA_TRADER/qa/.nuget/**`** — технически попадает под `ETNA_TRADER/qa/**`; при срабатывании по изменениям только restore-кэша ревьюер может отметить как шум — отдельный узкий паттерн не вводился, чтобы не дробить единый активный корень QA.
4. **WebApi** — триггеры не претендуют на все HTTP-сервисы решения, только на перечисленные по имени проекта (согласуется с `step-5-assumptions.md`).

---

## 8. Go / No-Go for closing BUG-STEP5-004

**Go.**

- Contracts и WebApi **подтверждены** по dev-sync (§3–§5).
- Оба QA-корня **явно обработаны в `aiqa/impact-map.yaml`**: автономный `qa/` (глобы + закодированная политика) и **`ETNA_TRADER/qa/**`** (отдельное правило).
- Отчёт содержит **конкретные списки** с путей dev-sync (§3).
- Оставшиеся ограничения **явно названы** и отделены от случайных пробелов (§7).
