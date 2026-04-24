# Evidence notes — bug 228299 / Leaderboard TotalCount

## Sources used

| Source | What it supports | Strength |
|---|---|---|
| `aiqa/repo-index.yaml` | `ETNA_TRADER` is inside current canonical scope; general ETNA <-> qa edge is only medium-confidence and review-only | strong for scope, weak for task-specific cross-repo claims |
| `aiqa/impact-map.yaml` | explicit rule `leaderboard-accounts-balances-surface`; confirmed path families; confirmed required checks for field consistency, rank stability and API/UI parity | strong |
| `aiqa/docs/knowledge/framework-current-state.md` | honest current-state limits; framework is not automation-grade as a whole | strong |
| `aiqa/docs/policies/artifact-maturity-policy.md` | how far current claims may go; why passing checks do not justify broader automation claims | strong |
| `aiqa/docs/knowledge/indexing-and-impact-strategy.md` | current indexing scope is intentionally narrow; impact map is a trigger/checklist layer, not proof of full graph | strong |
| `aiqa/tasks/bug-228299-leaderboard-totalcount/task.yaml` | touched domains and explicit evidence/unknowns for the task | strong |
| `aiqa/tasks/bug-228299-leaderboard-totalcount/README.md` | defect description, manual repro, affected consumers, regression interpretation | strong |
| local git diff `origin/dev...origin/bugfix/228299-leaderboard-invalid-total-count` in `ETNA_TRADER` | direct PR 15607 change surface; confirms affected service and risk-manager files | strong |
| current ETNA code in `AccountsWithBalancesController`, `AccountsWithBalancesService`, `AccountsWithBalancesExt`, `RiskManager` | confirms route, report path, mapper chain, and the original split between account count and non-null balance rows | strong |
| current ETNA code in `BalanceManager`, `AccountManager`, `CalculationContext` | narrows quote/balance failure semantics: `QuoteException` is zero-filled per attribute; generic exceptions may still return `null` higher in the chain | strong |
| user-provided screenshots from bug and discussion | confirms no-quote repro, before/after fix behavior, and author discussion that weakens the simple `GetBalance -> null` hypothesis | medium |
| `aiqa/tasks/leaderboard smoke and regression/backend-automation.cs` | real NUnit checks for last-page and full-walk invariants | strong |
| `aiqa/tasks/leaderboard smoke and regression/test-cases.md` | regression surface and manual/API/UI parity checks | strong |
| `aiqa/tasks/leaderboard smoke and regression/TestResults/totalcount-run-report.md` | one documented runtime pass for the two TotalCount checks | strong for that run only |
| `aiqa/tasks/leaderboard smoke and regression/test-plan-leaderboard.md` | supplementary context about intended regression scope | weak |
| `aiqa/tasks/leaderboard smoke and regression/execution-report-leaderboard.md` | explicitly simulated report with contradictory/assumption-heavy statements | weak, not used for strong claims |

## Evidence-backed conclusions

### Strong evidence

- The selected task is inside the current canonical scope.
- The framework already has an explicit impact rule for leaderboard/accounts-balances changes.
- PR 15607 directly changes `AccountsWithBalancesService`, `RiskManager`, `IRiskManager` and introduces `BalancesResult`, so the pilot now has code-level evidence for a substantial part of the internal fix path.
- The original mismatch mechanism is strongly supported by code: total count came from `_accountData.GetAccountsCount(...)`, while returned rows came from `RiskManager.GetBalances(...)`, which filtered to non-null `_balances` entries.
- The balance-population path now has stronger evidence: `RiskManager.UpdateBalances()` initializes entries as `null`, writes `_balanceProvider.GetBalance(context, 1)` into them, and logs exceptions instead of failing the whole surface; `AccountManager.GetBalance(int, currency)` also catches exceptions and returns `null`; `CalculationContext.GetSecurityQuote(...)` catches exceptions and returns `null`.
- `BalanceManager.GetBalance(...)` catches `QuoteException` per attribute and writes `0`, which means a pure quote miss does not automatically prove that the whole balance object disappears.
- Export path is now directly evidenced from controller to report model and CSV map.
- The bug affects more than one consumer: API contract, UI pagination and export are all named in task artifacts.
- Two concrete invariants were encoded in automation and were documented as passed on one run.
- The framework can support dependency mapping and risk-based planning here without inventing extra scope.

### Weak evidence

- The exact failing condition that leaves a specific balance entry null or otherwise invalid on the repro dataset.
- A direct proof that the documented missing-quote scenario is the exact exception source for the failing account.
- A direct proof whether the broken row came from generic exception, stale null entry, or downstream handling of partial attributes after quote fallback.
- Any claim that this bug has a confirmed cross-repo dependency beyond ETNA-only impact rule expansion.
- Any assumption that generic leaderboard materials automatically prove this specific fix end to end.

### Needs validation

- Whether the 2026-04-11 passing run used the same build that will be validated for release or demo.
- Repeatability of the fix on a dataset with a guaranteed missing-quote account.
- Whether Rank and field-source behavior changed together with the TotalCount fix or are independent issues.

## Notes on excluded or down-weighted evidence

- `execution-report-leaderboard.md` was not treated as a trustworthy source for this pilot because it is explicitly simulated and mixes unsupported claims with contradictions.
- `test-plan-leaderboard.md` was used only as a weak contextual artifact because parts of it speak in planning language and include assumptions beyond what canonical current-state docs prove.

## Bottom line

Для этого pilot strongest evidence находится в связке:

- canonical scope and impact files;
- existing task package for `bug-228299`;
- concrete regression code;
- concrete run report for the two key invariants.

Все более широкие архитектурные или cross-repo выводы были намеренно ослаблены до `weak`, `inferred` or `needs validation`.
