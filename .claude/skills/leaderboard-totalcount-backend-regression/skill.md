---
name: leaderboard-totalcount-backend-regression
description: Validate backend totalcount invariants for leaderboard responses and detect regressions where TotalCount diverges from effective paged data.

---

# Leaderboard Totalcount Backend Regression

## Trigger scenarios
- bug-228299 regression checks are requested
- post-fix validation for accounts-with-balances totalcount logic is needed
- release checks require leaderboard paging consistency

## Run command
- `dotnet test backend-automation.csproj --filter \"FullyQualifiedName~TotalCount\"`

## Required inputs
- `ETNA_ACCOUNTS_URL`
- `ETNA_TOKEN_URL`
- `ETNA_APP_KEY`
- `ETNA_USERNAME`
- `ETNA_PASSWORD`

## Safety
- no_secrets_in_repo: True
- regression_flag_required_for_strict_mode: ETNA_LB_TOTALCOUNT_REGRESSION
- allow_pre_fix_expected_failures: True

## Evidence
- `aiqa/tasks/bug-228299-leaderboard-totalcount/README.md`
- `aiqa/tasks/bug-228299-leaderboard-totalcount/task.yaml`
- `aiqa/tasks/leaderboard smoke and regression/backend-automation.cs`
- `aiqa/tasks/leaderboard smoke and regression/test-cases.md`
