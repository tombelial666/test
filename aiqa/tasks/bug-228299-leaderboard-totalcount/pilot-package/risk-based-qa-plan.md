# Risk-based QA plan — bug 228299 / Leaderboard TotalCount

## Testing scope

### In scope

- `accounts-with-balances` API contract around `TotalCount`, `Result`, pagination links and page math;
- Leaderboard UI table row count and pagination behavior;
- export consistency for the same filtered dataset;
- filters, sorting and page-size-sensitive scenarios;
- pub API vs web-facing API consistency where the same data contract is expected;
- negative and edge behavior around auth, invalid pagination and unstable data.

### Out of scope for this pilot

- full ETNA internal unit coverage;
- performance/load claims;
- hidden consumers not evidenced in current workspace;
- claiming automation-grade gating for the whole flow.

## High-risk checks

### HR-1. Last page invariant

- Check that last-page row count matches `TotalCount - pageSize * (lastPage - 1)`.
- Evidence basis: `backend-automation.cs`, `README.md`, `test-cases.md`.

### HR-2. Full pagination walk

- Sum `Result.length` across all pages and compare with `TotalCount`.
- Evidence basis: `backend-automation.cs`, run report dated 2026-04-11.

### HR-3. Missing-data scenario

- Reproduce or approximate the documented case where one account cannot produce a visible row because of missing quote data.
- Evidence basis: `README.md`.

### HR-4. UI/API parity

- Compare visible rows, page count and selected fields against the exact API response that fed the page.
- Evidence basis: `impact-map.yaml`, `test-cases.md`.

### HR-5. Export parity

- Validate that export does not imply a different total or dataset than UI/API for the same filter.
- Evidence basis: `README.md`, `test-cases.md`.

## Regression scope

- default first page;
- last page;
- full walk across all pages;
- filtered dataset by clearing account;
- multiple page sizes, especially values already documented in artifacts: `5`, `50`, `100`;
- sorting paths that can reshuffle visible rows;
- field consistency checks around `BalanceAttributes`.

## Negative and edge cases

- expired or missing auth token;
- invalid `pageNumber` and page-size boundary values;
- empty result set;
- large dataset with multiple pages;
- dataset containing at least one account that is counted but not rendered;
- ambiguous field source cases where root fields and `BalanceAttributes` disagree.

## Integration checks

- compare `public/v1` and `api/v1` responses for the same params when possible;
- compare API response with UI table for the exact captured request;
- compare UI/export output for the same filter and sort state.

## Manual checks that are required

- The documented repro with a clearing-account prefix and one "broken" account lacking quote data.
- UI pagination sanity on first page, last page and single-page post-fix case.
- Export verification on the same dataset used for UI/API comparison.
- Observation and recording of any discrepancy in Rank or Account Value display semantics.

Эти проверки нельзя честно считать закрытыми только за счет одного passing API regression run.

## Checks available now vs later

### Available now

- `TotalCount_LastPage_ResultCount_MatchesFormula_DefaultFilter`
- `TotalCount_FullPagination_SumOfResultEqualsTotalCount`

Они уже существуют в `backend-automation.cs` и имеют documented passing run in `totalcount-run-report.md`.

### Good candidates for later automation

- filter-specific full-walk checks;
- export parity check;
- targeted dataset setup for missing-quote scenario;
- field-consistency assertions for `BalanceAttributes` vs displayed values;
- cross-channel comparison between web and pub API under the same parameters.

## Traceability

| Requirement or risk | Checks |
|---|---|
| `TotalCount` must match actual number of returned rows | HR-1, HR-2, TC-LB-03, NUnit full-walk |
| Pagination must remain consistent after the fix | HR-1, last-page manual check, TC-LB-04 |
| UI must not show fewer or more rows than the backing response | HR-4, TC-LB-05 |
| Export must stay aligned with the corrected dataset | HR-5, manual export comparison, TC-LB-13 |
| Missing-quote accounts must not silently reintroduce mismatch | HR-3, documented manual repro from `README.md` |
| Field mapping drift can mask or confuse the fix | field-consistency review, TC-LB-16, TC-LB-18 |
| Rank or ordering logic can shift when row counts change | rank stability review, TC-LB-17, sorting regression |
| One passing run does not prove all environments are fixed | repeat targeted run on the intended deployed build, manual repro on a representative dataset |

## Exit posture for this pilot

Этот pilot можно считать убедительным, если:

- last-page and full-walk invariants pass on the intended build;
- manual broken-data scenario either passes or gives a reproducible defect record;
- UI/API/export parity does not produce a contradictory dataset picture;
- remaining unknowns are explicitly documented instead of silently assumed closed.
