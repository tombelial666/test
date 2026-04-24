# Legacy hotspots — bug 228299 / Leaderboard TotalCount

## Scope note

Здесь под hotspots понимаются не только "старые файлы", а места, где изменение легко дает скрытый side effect или расхождение между каналами потребления. Все пункты ниже разделены по силе evidence.

## Confirmed hotspots

### 1. Accounts-with-balances response invariants

Это confirmed hotspot, потому что:

- defect description в `README.md` прямо про несогласованность `TotalCount` и фактических строк;
- `backend-automation.cs` содержит два специальных regression checks именно на этот инвариант;
- local bugfix diff показывает, что fix реально меняет contract path между `AccountsWithBalancesService` и `RiskManager`;
- текущий код подтверждает split между "counted accounts" и "visible balances": `_accountData.GetAccountsCount(...)` считает инвентарь аккаунтов, а `RiskManager.GetBalances(...)` возвращает только `_balances.Values.Where(b => b != null)`;
- `impact-map.yaml` вводит rule-level checks для этой surface.

Практический риск:

- любая правка, которая меняет правило подсчета или исключения строк, может незаметно сломать pagination, UI и export одновременно.

### 2. BalanceAttributes and field consistency

Это confirmed hotspot, потому что `impact-map.yaml` содержит required check `balance_attributes_field_consistency`, а `test-cases.md` отдельно выносит field consistency и расхождения между root fields и `BalanceAttributes`.

Практический риск:

- исправление `TotalCount` может не затронуть связанные field-selection issues, но consumer behavior все равно изменится на UI или в export.

### 3. API/UI parity for leaderboard data

Это confirmed hotspot, потому что `impact-map.yaml` требует `accounts_balances_api_ui_parity`, а `test-cases.md` содержит явные UI vs API comparisons.

Практический риск:

- backend fix может выглядеть корректным на уровне API, но дать разъезд в отображении строк, рангов или колонок.

### 4. Rank and pagination display stability

Это confirmed hotspot как минимум на уровне review and regression attention, потому что `impact-map.yaml` содержит required check `rank_display_logic_stability`, а `test-cases.md` выделяет Rank и last-page logic отдельными проверками.

Практический риск:

- корректировка итогового набора строк может изменить display order или perceived rank semantics.

### 5. Service contract change around `GetBalances`

Это confirmed hotspot, потому что local diff показывает сигнатурное изменение `IRiskManager.GetBalances(...)` и `RiskManager.GetBalances(...)`: вместо коллекции аккаунтов теперь возвращается `BalancesResult` с `Items` и `TotalCount`.

Практический риск:

- изменение контракта между слоями легко влияет не только на UI response, но и на export path и любые другие consumers, которые ожидают прежнюю semantics collection-only result.

## Candidate hotspots

### 1. Row-building failures caused by incomplete market data

Это больше не чистый `unknown`, а `candidate hotspot` с сильным кодовым намеком: `README.md` приводит пример аккаунта с позицией без котировки, а `RiskManager` реально отдает только non-null balance entries. Значит mismatch может возникать, когда account counted by inventory не получает валидный balance object в `_balances`.

Дополнительный code-level signal:

- `RiskManager.UpdateBalances()` стартует с `null` entries для enabled accounts;
- при exception во время `_balanceProvider.GetBalance(context, 1)` запись может так и остаться `null`;
- `CalculationContext.GetSecurityQuote(...)` сам по себе ловит exception и возвращает `null`, так что quote-related failures действительно находятся рядом с observed symptom;
- но `BalanceManager.GetBalance(...)` отдельно ловит `QuoteException` на уровне конкретного balance attribute и подставляет `0`, а не роняет весь balance object.

Практический вывод:

- простая формула "no quote => whole balance becomes null" уже не выглядит достаточной;
- более вероятные остаточные варианты:
  - не `QuoteException`, а другой exception path выше или ниже `BalanceManager`;
  - partial balance/attribute set, который downstream consumer обрабатывает как невалидный;
  - отдельный path, где account entry не обновляется и остается `null`.

Практический риск:

- будущие изменения могут снова начать считать "неполные" аккаунты в `TotalCount`, даже если row-building logic осталась неявной.

### 2. Export consuming slightly different data path

Это уже сильнее, чем раньше, но все еще candidate hotspot: diff в `AccountsWithBalancesService` показывает, что export теперь тоже использует общий helper `GetAccountsWithBalances(...)`, однако нет полного downstream proof для всех export layers beyond this service-level path.

Практический риск:

- API/UI fix может не полностью закрыть export inconsistency.

### 3. Filter-specific and page-size-specific regressions

Это candidate hotspot, потому что documented checks используют page walk и page-size formulas, а ручной сценарий в `README.md` опирается на page size `5`, `50`, `100`.

Практический риск:

- исправление может работать на default path, но ломаться на фильтрах или нестандартных размерах страницы.

## Unknown

### 1. Exact ETNA internal critical path

Не полностью подтверждено даже после diff:

- на каком именно exception/data-condition `_balanceProvider.GetBalance(...)` или соседний path не дает валидный объект для конкретного аккаунта;
- есть ли дополнительные path'ы, кроме `null` в `_balances`, которые тоже могут исключать строку из выдачи.

### 2. Shared fragile modules outside visible task artifacts

Неизвестно без diff или чтения ETNA source:

- какие внутренние shared query/builders/DTO assemblers затронуты;
- использует ли та же логика другие endpoint consumers вне Leaderboard.

### 3. Release-specific side effects

По текущим артефактам неизвестно:

- какая именно сборка была на каждом стенде;
- был ли fix backported or partially deployed;
- есть ли environment-specific data conditions, маскирующие дефект.

## Critical path hints

### Confirmed hints

- Проверять не только первый ответ API, но и последнюю страницу и полный обход страниц.
- Сопоставлять metadata (`TotalCount`, links, page math) с фактическими строками `Result`.
- Не отделять UI/export regression от API fix.

### Candidate hints

- Искать datasets, где строка не строится из-за неполных данных.
- Проверять фильтры, page size и cross-channel consistency как отдельные risk multipliers.
