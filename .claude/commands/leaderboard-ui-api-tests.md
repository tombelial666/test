---
name: leaderboard-ui-api-tests
description: Run and interpret leaderboard UI/API smoke and regression checks built on Playwright + pytest, including API response capture for accounts-with-balances.

---

# Leaderboard Ui Api Tests

## Trigger scenarios
- leaderboard widget validation is requested
- UI/API parity and regression checks are requested for leaderboard
- smoke coverage of leaderboard flows is needed

## Run command
- `python -m pytest -v test_smoke test_regression`

## Required inputs
- `LB_BASE_URL`
- `INT2_USERNAME`
- `INT2_PASSWORD`

## Safety
- no_secrets_in_repo: True
- no_default_password_literals: True
- require_explicit_credentials: True

## Evidence
- `aiqa/evidence/qa-suite-inventory/2026-04-25-agents-skills-v1/qa-suite-inventory.md`
- `qa/leaderboard-tests/conftest.py`
- `qa/leaderboard-tests/model/pages/leaderboard_page.py`
- `ETNA_TRADER/src/Etna.Trader/Etna.Trader.Web/src/scripts/API/AccountWithBalancesService.js`
- `ETNA_TRADER/src/Etna.Trader/Etna.Trader.WebApi.Customization/AccountsWithBalances/AccountsWithBalancesController.cs`
