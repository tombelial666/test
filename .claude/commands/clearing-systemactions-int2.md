---
name: clearing-systemactions-int2
description: Execute and validate INT2 clearing system actions with safe defaults, focusing on Volant EasyToBorrow via GET/PUT /v1.0/systemactions/clearing.

---

# Clearing Systemactions Int2

## Trigger scenarios
- systemactions/clearing validation is requested
- Volant EasyToBorrow handler checks are needed
- INT2 clearing smoke or targeted integration checks are requested

## Run command
- `python qa/Tools/ClearingTester/run_volant_easy_to_borrow_int2.py`

## Required inputs
- `CLEARING_TESTER_USERNAME`
- `CLEARING_TESTER_PASSWORD`
- `CLEARING_TESTER_APP_KEY`

## Safety
- no_secrets_in_repo: True
- mutation_gating: {'flag': 'RUN_MUTATING_CLEARING_TESTS', 'enabled_value': '1'}
- default_mode: non_mutating_get_checks

## Evidence
- `aiqa/evidence/qa-suite-inventory/2026-04-25-agents-skills-v1/qa-suite-inventory.md`
- `qa/Tools/ClearingTester/README.md`
- `qa/Tools/ClearingTester/tests/test_volant_easy_to_borrow_int2.py`
