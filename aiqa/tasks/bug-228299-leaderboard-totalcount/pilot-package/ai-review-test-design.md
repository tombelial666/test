# AI review and test design — bug 228299 / Leaderboard TotalCount

## Review questions the framework should ask

### Response construction

- Где и на каком шаге формируется `TotalCount`?
- Где и на каком шаге формируется массив `Result`?
- Используют ли `TotalCount` и `Result` один и тот же eligibility/filtering rule set?
- Что происходит с аккаунтом, для которого строка Leaderboard не может быть построена?
- Все ли consumers уже переведены на новый `BalancesResult`, а не на старую collection-only semantics?
- Может ли account считаться через `_accountData.GetAccountsCount(...)`, но не попасть в `Result`, потому что `RiskManager` отдает только non-null `_balances` entries?
- Может ли quote/calculation path вернуть `null` без hard-fail, оставив account visible in inventory but invisible in balances result?
- Если `BalanceManager` ловит `QuoteException` и zero-fills конкретный атрибут, то какой другой path все же исключает account row целиком?

### Consumer consistency

- Используют ли UI pagination, export и API одну и ту же фактическую выборку?
- Может ли fix закрыть API mismatch, но оставить divergence в UI or export?
- Есть ли отдельная display logic for Rank or Account Value, которая зависит от полного набора строк?

### Deployment and evidence

- На каком именно build or environment был получен passing run?
- Достаточно ли representative dataset использовался для проверки missing-data scenario?
- Есть ли evidence именно для filter-specific and page-size-sensitive paths, а не только для default run?

## Test design hints the framework should produce

- Если endpoint возвращает и `TotalCount`, и `Result`, всегда проектировать инварианты "last page formula" и "full walk sum".
- Если balance generation зависит от quote/calculation path, явно спрашивать, где exceptions проглатываются и где `null` считается допустимым промежуточным результатом.
- Если code path differentiates `QuoteException -> 0` from generic exception -> `null`/stale entry, тест-дизайн должен покрывать оба сценария отдельно.
- Если баг описывает выпадение части строк из `Result`, проектировать dataset с одним намеренно проблемным элементом.
- Если UI и export упомянуты как consumers, не ограничиваться backend-only verification.
- Если canonical impact rule уже содержит `required_checks`, переносить их в checklist, а не изобретать новую структуру с нуля.
- Если `BalanceAttributes` выделены в impact rule, включать explicit field-consistency checks.

## Missing artifacts that reduce confidence

- exact failing condition inside `_balanceProvider.GetBalance(...)` or adjacent code that leaves a specific `_balances[id]` entry invalid for the repro dataset;
- evidence showing whether the repro path is a generic exception, a stale `null` entry, or a partial attribute-set problem after quote handling;
- representative test-data recipe that reliably reproduces the missing-quote condition;
- build-to-environment mapping for the run that passed on 2026-04-11.

## Assumptions that must not be made without evidence

- Нельзя считать, что один passing run доказывает полное исправление во всех environments.
- Нельзя считать, что UI and export automatically fixed just because API invariants passed once.
- Нельзя утверждать полную internal dependency chain внутри ETNA только по одному service/risk-manager diff.
- Нельзя объявлять task fully cross-repo, если task-specific impact rule не расширяет ее за пределы `ETNA_TRADER`.
- Нельзя трактовать general `ETNA_TRADER` <-> `qa` edge из `repo-index.yaml` как proof of this specific bug's repository dependency.

## Reusable follow-up prompts and framework rules

### Reusable prompts

- "Show where `TotalCount` is computed and where rows are filtered out before `Result` is returned."
- "List all consumers that rely on the same dataset shape: API, UI, export, pagination, rank display."
- "For every endpoint returning `TotalCount` plus paged `Result`, derive last-page and full-walk invariants."
- "Mark which links are confirmed by code or artifacts and which are only inferred from symptoms."
- "If a consumer mismatch is mentioned, separate API fix evidence from UI/export evidence."

### Candidate framework rules

- For paged APIs with `TotalCount`, auto-suggest invariant checks before generic smoke tests.
- When `impact-map.yaml` already has task-relevant `required_checks`, generate QA prompts from them directly.
- Force explicit `unknown` markers when task artifacts mention a symptom but not the internal producer chain.
- Treat simulated or assumption-heavy execution reports as weak evidence unless backed by real run artifacts.
