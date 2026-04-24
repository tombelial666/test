---
name: clearing-systemactions-int2
description: Execute and validate INT2 clearing system actions with safe defaults, focusing on Volant EasyToBorrow via GET/PUT /v1.0/systemactions/clearing.

---

# Clearing Systemactions Int2

## When to use
- systemactions/clearing validation is requested
- Volant EasyToBorrow handler checks are needed
- INT2 clearing smoke or targeted integration checks are requested

## Out of scope
- production environment mutation
- canonical repo-index/impact-map auto updates

## Run
- `(cwd: qa/Tools/ClearingTester) python qa/Tools/ClearingTester/run_volant_easy_to_borrow_int2.py`

## Inputs
**Required env**
- `CLEARING_TESTER_USERNAME`
- `CLEARING_TESTER_PASSWORD`
- `CLEARING_TESTER_APP_KEY`

**Optional env**
- `CLEARING_TESTER_TOKEN_URL`
- `CLEARING_TESTER_BASE_URL`
- `CLEARING_TESTER_ROUTE`
- `CLEARING_TESTER_PAYLOAD`
- `CLEARING_TESTER_TOKEN`
- `RUN_MUTATING_CLEARING_TESTS`

**Optional CLI**
- n/a

## Endpoints
- `POST https://pub-api-etna-demo-ci-int-2.etnasoft.us/api/token`
- `GET https://priv-api-etna-demo-ci-int-2.etnasoft.us/api/v1.0/systemactions/clearing`
- `PUT https://priv-api-etna-demo-ci-int-2.etnasoft.us/api/v1.0/systemactions/clearing`

## Safety
- no_secrets_in_repo: True
- mutation_gating: {'flag': 'RUN_MUTATING_CLEARING_TESTS', 'enabled_value': '1'}
- default_mode: non_mutating_get_checks

## Evidence basis
- `aiqa/evidence/qa-suite-inventory/2026-04-25-agents-skills-v1/qa-suite-inventory.md`
- `qa/Tools/ClearingTester/README.md`
- `qa/Tools/ClearingTester/tests/test_volant_easy_to_borrow_int2.py`

## Source spec
- `aiqa/skills-catalog/clearing-systemactions-int2.yaml`
