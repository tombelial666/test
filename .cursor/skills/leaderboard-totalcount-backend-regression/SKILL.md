---
name: leaderboard-totalcount-backend-regression
description: Validate backend totalcount invariants for leaderboard responses and detect regressions where TotalCount diverges from effective paged data.

---

# Leaderboard Totalcount Backend Regression

## When to use
- bug-228299 regression checks are requested
- post-fix validation for accounts-with-balances totalcount logic is needed
- release checks require leaderboard paging consistency

## Out of scope
- replacing UI smoke suite
- forcing failure on environments that intentionally run pre-fix versions

## Run
- `(cwd: aiqa/tasks/leaderboard smoke and regression) dotnet test backend-automation.csproj --filter \"FullyQualifiedName~TotalCount\"`

## Inputs
**Required env**
- `ETNA_ACCOUNTS_URL`
- `ETNA_TOKEN_URL`
- `ETNA_APP_KEY`
- `ETNA_USERNAME`
- `ETNA_PASSWORD`

**Optional env**
- `ETNA_LB_PAGE_SIZE`
- `ETNA_LB_FILTER`
- `ETNA_LB_FULL_WALK`
- `ETNA_LB_TOTALCOUNT_REGRESSION`

**Optional CLI**
- n/a

## Endpoints
- `GET {ETNA_ACCOUNTS_URL}/accounts-with-balances`
- `POST {ETNA_TOKEN_URL}`

## Safety
- no_secrets_in_repo: True
- regression_flag_required_for_strict_mode: ETNA_LB_TOTALCOUNT_REGRESSION
- allow_pre_fix_expected_failures: True

## Evidence basis
- `aiqa/tasks/bug-228299-leaderboard-totalcount/README.md`
- `aiqa/tasks/bug-228299-leaderboard-totalcount/task.yaml`
- `aiqa/tasks/leaderboard smoke and regression/backend-automation.cs`
- `aiqa/tasks/leaderboard smoke and regression/test-cases.md`

## Source spec
- `aiqa/skills-catalog/leaderboard-totalcount-backend-regression.yaml`
