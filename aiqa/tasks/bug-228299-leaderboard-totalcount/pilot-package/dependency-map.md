# Dependency map — bug 228299 / Leaderboard TotalCount

## Scope note

Этот dependency map ограничен тем, что подтверждается файлами в workspace. Он не пытается восстановить полный внутренний ETNA call graph без прямого diff или code-level evidence.

## Confirmed links

### 1. Canonical framework links

- `aiqa/repo-index.yaml` подтверждает, что `ETNA_TRADER` находится в current canonical scope.
- `aiqa/impact-map.yaml` содержит правило `leaderboard-accounts-balances-surface`.
- Это правило явно связывает change surface с путями:
  - `ETNA_TRADER/src/**/Leaderboard*/**`
  - `ETNA_TRADER/src/**/AccountsWithBalances*/**`
  - `ETNA_TRADER/src/**/*BalanceAttributes*/**`

### 2. Task-level links

- `aiqa/tasks/bug-228299-leaderboard-totalcount/task.yaml` фиксирует touched domains: `accounts_balances`, `leaderboard_ui`.
- `aiqa/tasks/bug-228299-leaderboard-totalcount/README.md` подтверждает bug class:
  - `TotalCount` мог быть больше фактического числа возвращаемых строк;
  - проблема проявлялась в UI, pagination и export;
  - один из documented triggers: аккаунт с позицией без котировки.
- Local git diff `origin/dev...origin/bugfix/228299-leaderboard-invalid-total-count` подтверждает прямой changed surface PR 15607:
  - `src/Etna.Trader/Etna.Trader.WebApi.Customization/AccountsWithBalances/AccountsWithBalancesService.cs`
  - `src/Etna.Trading.Oms/Etna.Trading.Oms/Account/RiskManager.cs`
  - `src/Etna.Trading/Etna.Trading/Oms/BalancesResult.cs`
  - `src/Etna.Trading/Etna.Trading/Oms/Components/IRiskManager.cs`
  - `src/Customization/TradeStation/Etna.Trading.TradeStation.WebApi/TradeStationAccountsService.cs`
  - `src/Customization/TradeStation/Etna.Trading.TradeStation/Oms/BalancesResult.cs`

## Code anchors

Подтвержденные якоря, которые теперь можно использовать как task-level mini-index:

- `ETNA_TRADER/src/Etna.Trader/Etna.Trader.WebApi.Customization/AccountsWithBalances/AccountsWithBalancesController.cs`
- `ETNA_TRADER/src/Etna.Trader/Etna.Trader.WebApi.Customization/AccountsWithBalances/InternalAccountsWithBalancesController.cs`
- `ETNA_TRADER/src/Etna.Trader/Etna.Trader.WebApi.Customization/AccountsWithBalances/AccountsWithBalancesService.cs`
- `ETNA_TRADER/src/Etna.Trader/Etna.Trader.WebApi.Customization/AccountsWithBalances/AccountsWithBalancesExt.cs`
- `ETNA_TRADER/src/Etna.Trader/Etna.Trader.WebApi.Customization/AccountsWithBalances/Entities/AccountWithBalancesResource.cs`
- `ETNA_TRADER/src/Etna.Trader/Etna.Trader.WebApi.Customization/AccountsWithBalances/Entities/Map/AccountWithBalancesReportModel.cs`
- `ETNA_TRADER/src/Etna.Trader/Etna.Trader.WebApi.Customization/AccountsWithBalances/Entities/Map/ClassMapAccountWithBalances.cs`
- `ETNA_TRADER/src/Etna.Trading.Oms/Etna.Trading.Oms/Account/RiskManager.cs`
- `ETNA_TRADER/src/Etna.Trading/Etna.Trading/Oms/Components/IRiskManager.cs`
- `ETNA_TRADER/src/Etna.Trading/Etna.Trading/Oms/BalancesResult.cs`

### 3. Test and evidence links

- `aiqa/tasks/leaderboard smoke and regression/backend-automation.cs` содержит два прямых инварианта для этой задачи:
  - размер последней страницы должен совпадать с формулой от `TotalCount` и `pageSize`;
  - сумма длин `Result` по всем страницам должна совпадать с `TotalCount`.
- `aiqa/tasks/leaderboard smoke and regression/test-cases.md` подтверждает, что consumer surface включает:
  - web UI Leaderboard;
  - `GET /public/v1/accounts-with-balances`;
  - `GET /api/v1/accounts-with-balances`;
  - pagination, filters, sorting, export, auto refresh.
- `aiqa/tasks/leaderboard smoke and regression/TestResults/totalcount-run-report.md` дает runtime evidence, что оба NUnit checks были пройдены на одном documented прогоне.

## Change surface

### Confirmed

- API response contract around `TotalCount` and `Result`.
- `AccountsWithBalancesService` now returns `balancesResult.TotalCount` instead of the earlier count path and uses a shared helper `GetAccountsWithBalances(...)`.
- `RiskManager.GetBalances(...)` changed from returning only `ICollection<AccountWithBalance>` to returning `BalancesResult` with both `Items` and `TotalCount`.
- `BalancesResult` was introduced in `Etna.Trading.Oms` as an explicit transport object for paged balance results.
- Export path is now code-level visible:
  - `AccountsWithBalancesController.GetAccountsWithBalance(...)` uses `isReport=true` to call `GetAccountsWithBalanceReport(...)`;
  - `AccountsWithBalancesService.GetAccountsWithBalanceReport(...)` uses the same helper path as normal retrieval in the bugfix diff;
  - export rows are mapped via `AccountsWithBalancesExt.Map(this AccountWithBalance awb, IList<IUserWithAccountId> users)` into `AccountWithBalancesReportModel`;
  - CSV schema is defined by `ClassMapAccountWithBalances`.
- The original mismatch path is now largely confirmed by current code plus diff:
  - `AccountsWithBalancesService` counted accounts via `_accountData.GetAccountsCount(filter)`;
  - it then fetched visible rows through `_riskManager.GetBalances(...)`;
  - `RiskManager.GetBalances(...)` filtered `_balances.Values.Where(b => b != null)`, so counted accounts with `null` balance entries would not appear in the returned collection.
- The upstream balance-population path is now partially visible in code:
  - `RiskManager.UpdateBalances()` initializes enabled accounts with `_balances[id] = null`;
  - then tries `_balances[id] = new AccountWithBalance { Account = context.Account, Balance = _balanceProvider.GetBalance(context, 1), Rank = rank }`;
  - on exception it logs `failed to get balance for account ...` and leaves the prior value untouched;
  - `AccountManager.GetBalance(int accountId, string currency)` catches exceptions and returns `null`;
  - `CalculationContext.GetSecurityQuote(...)` catches exceptions from `_accountManager.GetSecurityQuote(security, false)` and returns `null`;
  - `BalanceManager.GetBalance(...)` catches `QuoteException` per attribute and writes `0` into the resulting `BalanceInfo`, instead of dropping the full balance object.
- Pagination semantics for last page and full page walk.
- Consumers that rely on the same data contract:
  - Leaderboard UI table;
  - pagination controls;
  - export;
  - regression automation checks.
- Data consistency around `BalanceAttributes` and related displayed fields, потому что это прямо отражено и в rule-level checks, и в regression materials.

### Inferred

- Exact business/data condition that caused a given `_balances[id]` entry to remain `null` on the failing dataset.
- Whether the repro path is really a generic exception/stale null path, or a downstream failure caused by partial attributes after quote fallback.
- Whether every historical mismatch variant came from the same `null`-balance path.
- Full downstream set of all services consuming the same `BalancesResult` semantics.

Эти связи все еще нельзя считать полностью доказанными по diff alone, хотя часть internal chain теперь видна напрямую.

## Upstream and downstream effects

### Upstream inputs

- Dataset composition: наличие аккаунтов, для которых строка Leaderboard не строится.
- Page parameters: `pageNumber`, `pageSize`, `filter`, `propertyName`, `isAscending`.
- Field/value shape returned by accounts-with-balances API.
- Internal balance aggregation coming from `RiskManager.GetBalances(...)`.

### Downstream effects

- UI row count may diverge from page metadata.
- Last-page pagination may become inconsistent.
- Export may use a different implied total than the visible data.
- Regression checks fail when `TotalCount` and actual rows drift apart.

## Cross-repo links

### Confirmed

- Для этой конкретной зоны canonical `impact-map.yaml` расширяет review только внутри `ETNA_TRADER`. В `expand.repos` для `leaderboard-accounts-balances-surface` нет `qa`.

### Inferred or general-only

- `aiqa/repo-index.yaml` содержит общий edge `ETNA_TRADER` <-> `qa` с `confidence: medium` и `review_only: true`, но это не является task-specific доказательством cross-repo dependency именно для bug 228299.
- Наличие regression artifacts в `aiqa/tasks/...` не доказывает canonical cross-repo coupling; это task artifact layer, а не framework proof of repository dependency.

## Summary

### Confirmed

- `ETNA_TRADER` in scope.
- Explicit leaderboard/accounts-balances impact rule exists.
- Concrete PR change surface is visible in the local bugfix branch diff.
- Internal producer chain is partially confirmed: WebApi customization service -> `IRiskManager`/`RiskManager` -> `BalancesResult`.
- The previous mismatch mechanism is mostly code-confirmed: count came from account inventory, while returned rows came from non-null `_balances` entries.
- Bug affects API contract consistency and visible consumers.
- There are real checks and real run evidence for the key invariants.

### Inferred

- Internal row-building failure path that caused dropped accounts.
- Broader repo-to-repo impact beyond the current ETNA-only rule.

### Unknown

- Whether any additional hidden consumers beyond UI/export depend on the same invariant.
