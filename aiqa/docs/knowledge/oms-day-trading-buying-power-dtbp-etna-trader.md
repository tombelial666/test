> **Канон aiqa.** Источник истины по структуре фреймворка — `aiqa/MANIFEST.md`. Этот файл — прикладная доменная спецификация OMS ETNA Trader (поведение кода, трассируемость для QA).

---

<context>

**Title:** Day Trading Buying Power (DTBP) — как считается в OMS ETNA Trader

**Description:**

В системе DTBP — это:

1. **Хранимое поле счёта** `Account.DayTradingBuyingPower` (`Etna.Trading.Oms.Entity.Account`).
2. **Публичный балансовый параметр** `BalanceParameter.DayTradingBuyingPower` (`"dayTradingBuyingPower"`), который в типовой конфигурации OMS строится как разность «сырого» значения с атрибута счёта и внутреннего pending по дневному трейдеру (`dayTraderPendingCash`).

Для счетов с `MarginType == DayTrader` стоимость сделок и резервирование по рабочим заявкам опираются на `DayTraderRate`, `DayTraderPendingCashHelper` и валидатор `DayTradingExcessValidator`. Часть развёртываний подключает альтернативную формулу `DayTradeBuyingPowerFormula` (сборка WhoTrades) с порогами по `OpenExcess`.

Конфигурационные файлы `Oms.AccountManager.config` в репозитории есть у Web, BalanceService, OmsService и др.; фрагменты ниже взяты из **BalanceService** как репрезентативный пример (`ETNA_TRADER/src/Etna.Trader/Etna.Trader.Services/BalanceService/config/Oms/Oms.AccountManager.config`).

</context>

<goal>

1. Зафиксировать цепочку данных: атрибут счёта → формулы в `Oms.AccountManager.config` → вычитание `dayTraderPendingCash`.
2. Описать обновление DTBP при исполнении: `TransactionHelper.CalculateDayTraderValue` и опциональный cap по `OpenExcess`.
3. Дать трассируемость **REQ → компонент → файл** для QA.
4. Явно развести основную цепочку и альтернативные формулы WhoTrades (`DayTradeBuyingPowerFormula`, `StockBuyingPowerFormula`).

</goal>

<anti_hallucinations>

- Регуляторные определения SEC/FINRA (PDT, DTBP в смысле правил рынка) **не цитируются** — только поведение кода.
- Юридически-брокерские формулировки из внешней wiki в этом ответе **не используются**; отдельный репозиторий wiki в workspace может отсутствовать или не индексироваться — проверяйте целевой клон при необходимости.
- Разные экземпляры `Oms.AccountManager.config` (Web / BalanceService / выкладка) **могут отличаться**; прод-поведение определяется **фактическим** конфигом окружения.
- Связь `GetDayBuyingPowerRate` / `buyingPowerRules` с полем `DayTraderRate` при синхронизации счёта с clearing — **отдельная** ветка загрузки; здесь зафиксирован только API `MarginManager` для дневного коэффициента margin-счетов.

</anti_hallucinations>

---

## Канон кода (кратко)

### 1) Имя параметра в API балансов

Файл: `ETNA_TRADER/src/Etna.Trading/Etna.Trading/Oms/BalanceParameter.cs`

```csharp
public const string DayTradingBuyingPower = "dayTradingBuyingPower";
```

(рядом определены и другие ключи, см. файл и комментарий «See Oms.AccountManager.config».)

### 2) Хранимое на счёте поле

Файл: `ETNA_TRADER/src/Etna.Trading/Etna.Trading/Oms/Entity/Account.cs`

- `DayTradingBuyingPower` — `[DataMember(Order = 23)]`
- `DayTrades` — `[DataMember(Order = 24)]`
- `DayTraderRate` — `[DataMember(Order = 39)]`

### 3) Публичный балансовый параметр `dayTradingBuyingPower` в конфиге OMS (пример BalanceService)

Файл: `ETNA_TRADER/src/Etna.Trader/Etna.Trader.Services/BalanceService/config/Oms/Oms.AccountManager.config`

Внутренний узел `dayTradingBuyingPowerBack` читает атрибут счёта; публичный `dayTradingBuyingPower` — `PairOperationBalanceFormula` с операцией вычитания: `first` − `second` = `dayTradingBuyingPowerBack` − `dayTraderPendingCash`.

**Смысл:** отображаемый DTBP = `Account.DayTradingBuyingPower` − `dayTraderPendingCash` (как сумма, рассчитанная формулой pending для DT).

### 4) «Pending» для DTBP: `DayTraderPendingCashBalanceFormula`

Файл: `ETNA_TRADER/src/Etna.Trading.Oms/Etna.Trading.Oms/Account/Balance/DayTraderPendingCashBalanceFormula.cs`

- Если `MarginType == DayTrader` — возвращается `_dayTraderPendingCashHelper.GetPendingCash(..., true)`.
- Иначе — `0`.

Множитель для акций в `DayTraderPendingCashHelper.GetMult` учитывает тип инструмента, цену (ниже 5), `linearDayTradingBuyingPowerMultiplier`, ступени по `GetStockInitialMarginRate` и т.д. (см. `DayTraderPendingCashHelper.cs`).

### 5) Обновление DTBP при исполнении (DayTrader)

Файл: `ETNA_TRADER/src/Etna.Trading.Oms/Etna.Trading.Oms/Account/TransactionHelper.cs`

- Перед расчётом: `executionInfo.DayTradingBuyingPower = account.DayTradingBuyingPower`.
- Для `AccountMarginType.DayTrader` вызывается `CalculateDayTraderValue`, внутри которого:
  - накапливается `cost` с использованием `GetMult` и флагов конструктора (`_dtAccountHoldOvernight`, `_debitOvernightBuyToClose`, …);
  - `transactionInfo.DayTradingBuyingPower = account.DayTradingBuyingPower - cost`;
  - при `_limitOpenDayTradingBuyingPower` и превышении: `transactionInfo.DayTradingBuyingPower = account.OpenExcess`.

### 6) Альтернативная формула WhoTrades: `DayTradeBuyingPowerFormula`

Файл: `ETNA_TRADER/src/Etna.Trading.Oms/Etna.Trading.Oms.WhoTrades/Account/Balance/DayTradeBuyingPowerFormula.cs`

Кусочно-линейно по `OpenExcess`: свыше 25000 → ×4; интервал (2000; 25000] → ×2; иначе → `openExcess`.

**Не путать** с цепочкой `Account.DayTradingBuyingPower` + `PairOperationBalanceFormula` — это другой класс; эквивалентность возможна только если так **явно** задано в конкретном `Oms.AccountManager.config`.

### 7) Дневной stock BP в сценарии WhoTrades: `StockBuyingPowerFormula`

Файл: `ETNA_TRADER/src/Etna.Trading.Oms/Etna.Trading.Oms.WhoTrades/Account/Balance/StockBuyingPowerFormula.cs`

При состоянии `EventManagerConstants.TradingBuingPowerHoursStateDay` (`EventManagerConstants.TradingBuingPowerHours` = `"day"`) значение берётся из провайдера балансов: `BalanceParameter.DayTradingBuyingPower` — то есть **привязка к DTBP через баланс-параметр**, а не дублирование формулы в UI-слое.

Константы состояний: `ETNA_TRADER/src/Etna.Trading/Etna.Trading/Oms/EventManagerConstants.cs` (в коде используется опечатка `TradingBuingPower*`).

### 8) Базовый дневной коэффициент для margin-счетов: `MarginManager.GetDayBuyingPowerRate`

Файл: `ETNA_TRADER/src/Etna.Trading.Oms/Etna.Trading.Oms/Margin/MarginManager.cs`

Правило: для Cash или без `AllowMargin` → `1`; иначе — `FindBuyingPowerRule(_buyingPowerRules, equity, account.MarginType)?.DayRate ?? 1`.

---

## Трассируемость REQ → компонент → файл

| REQ | Смысл | Где в коде |
|-----|--------|------------|
| R-DTBP-API | Ключ API `dayTradingBuyingPower` | `BalanceParameter.DayTradingBuyingPower` |
| R-DTBP-ACC | Поле счёта | `Account.DayTradingBuyingPower` |
| R-DTBP-CFG | Конфиг: back + вычитание pending | `Oms.AccountManager.config` (пример: BalanceService) |
| R-DTBP-PEND | Формула pending для DT | `DayTraderPendingCashBalanceFormula`, `DayTraderPendingCashHelper` |
| R-DTBP-EXE | Списание при исполнении | `TransactionHelper.CalculateDayTraderValue` |
| R-DTBP-CAP | Ограничение по OpenExcess | флаг `_limitOpenDayTradingBuyingPower` в `TransactionHelper` |
| R-DTBP-ALT-WT | Альтернатива по OpenExcess | `DayTradeBuyingPowerFormula` (WhoTrades) |
| R-DTBP-STK-WT | Stock BP в дневной фазе | `StockBuyingPowerFormula` + `EventManagerConstants` |
| R-DTBP-VAL | Валидация избытка DT | `DayTradingExcessValidator` |
| R-DTBP-BPRULE | Дневной rate из buying power rules | `MarginManager.GetDayBuyingPowerRate` |

---

<acceptance_criteria>

| ID | Критерий (приёмка документации) |
|----|----------------------------------|
| **A1** | Описана формула `dayTradingBuyingPower` = `Account.DayTradingBuyingPower` − `dayTraderPendingCash` (через `PairOperationBalanceFormula` и внутренние имена в конфиге) и условие нулевого pending для не‑DT (`DayTraderPendingCashBalanceFormula`). |
| **A2** | Указано, что исполнение для DT обновляет DTBP через `TransactionHelper.CalculateDayTraderValue` и опциональный cap по `OpenExcess` (`_limitOpenDayTradingBuyingPower`). |
| **A3** | Указано наличие альтернативной `DayTradeBuyingPowerFormula` (WhoTrades) и что она **не** подменяет автоматически общую цепочку без проверки целевого `Oms.AccountManager.config`. |
| **A4** | Зафиксирован разрыв: внешняя брокерская/wiki-документация в этом документе **не** смешана с выводами по коду; прод-конфиг обязателен для верификации. |

</acceptance_criteria>

<test_cases>

| TC-ID | Назначение | Идея проверки |
|-------|------------|---------------|
| **TC-DTBP-01** | Базовый DT счёт | Снимок баланса: `dayTradingBuyingPower` ≤ `dayTradingBuyingPowerBack`; при отсутствии working orders pending ≈ 0. |
| **TC-DTBP-02** | Pending | Сравнение `dayTraderPendingCash` до/после выставления заявки на DT счёте. |
| **TC-DTBP-03** | Исполнение | После fill на DT: изменение DTBP согласно `CalculateDayTraderValue` (лог OMS / тестовый harness). |
| **TC-DTBP-04** | Конфиг | Diff выбранного `Oms.AccountManager.config` с эталоном окружения — нет ли подключения `DayTradeBuyingPowerFormula` вместо стандартной цепочки для целевого параметра. |

</test_cases>

<open_questions>

1. Какой `Oms.AccountManager.config` считается эталоном для вашего окружения (Web / BalanceService / Sogo Live)?
2. Где лежит wiki относительно `DevReps` (отдельный клон `ETNA_TRADER.wiki` или иной путь) — для сверки с брокерской терминологией?
3. Нужна ли отдельная трассировка загрузки `DayTraderRate` и `DayTradingBuyingPower` с clearing (тогда уточнить файлы синхронизации счёта)?

</open_questions>

<self_reflection>

- **Трассируемость:** требования сопоставлены классам, конфигу и формулам; альтернативная ветка WhoTrades отмечена явно.
- **Анти-галлюцинации:** регуляторика и внешняя wiki не использованы как источник истины; оговорены различия конфигов.
- **Риск:** смешение `DayTradeBuyingPowerFormula` (пороги по `OpenExcess`) и основной цепочки `Account.DayTradingBuyingPower` + pending — в тексте разведено; для прод-поведения нужен целевой `Oms.AccountManager.config`.

</self_reflection>
