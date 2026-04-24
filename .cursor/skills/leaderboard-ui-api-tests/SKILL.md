---
name: leaderboard-ui-api-tests
description: Run and interpret leaderboard UI/API smoke and regression checks built on Playwright + pytest, including API response capture for accounts-with-balances.

---

# Leaderboard Ui Api Tests

## When to use
- leaderboard widget validation is requested
- UI/API parity and regression checks are requested for leaderboard
- smoke coverage of leaderboard flows is needed

## Out of scope
- hardcoded credentials in code or docs
- unsupported production load/stress execution

## Run
- `(cwd: qa/leaderboard-tests) python -m pytest -v test_smoke test_regression`

## Inputs
**Required env**
- `LB_BASE_URL`
- `INT2_USERNAME`
- `INT2_PASSWORD`

**Optional env**
- `LB_PRIV_API_URL`
- `LB_APP_KEY`

**Optional CLI**
- `--lb-base-url`
- `--lb-username`
- `--lb-password`
- `--lb-priv-api-url`
- `--lb-app-key`

## Endpoints
- `GET {LB_BASE_URL}/public/v1/accounts-with-balances`

## Safety
- no_secrets_in_repo: True
- no_default_password_literals: True
- require_explicit_credentials: True

## Evidence basis
- `aiqa/evidence/qa-suite-inventory/2026-04-25-agents-skills-v1/qa-suite-inventory.md`
- `qa/leaderboard-tests/conftest.py`
- `qa/leaderboard-tests/model/pages/leaderboard_page.py`
- `ETNA_TRADER/src/Etna.Trader/Etna.Trader.Web/src/scripts/API/AccountWithBalancesService.js`
- `ETNA_TRADER/src/Etna.Trader/Etna.Trader.WebApi.Customization/AccountsWithBalances/AccountsWithBalancesController.cs`

## Source spec
- `aiqa/skills-catalog/leaderboard-ui-api-tests.yaml`
