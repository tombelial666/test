# Retest runbook — Task 228135 / Volant EasyToBorrow on INT2

## Purpose

Единый пошаговый runbook для повторяемого прогона `Volant EasyToBorrow` на `INT2` через `systemactions/clearing`.

Этот runbook покрывает:

- preflight для auth и payload;
- discovery-only прогон;
- полный прогон с `PUT /systemactions/clearing`;
- что фиксировать как evidence;
- что остаётся вне automation и требует manual / environment follow-up.

## Environment

### Token host

- `https://pub-api-etna-demo-ci-int-2.etnasoft.us/api/token`

### Clearing action host

- `https://priv-api-etna-demo-ci-int-2.etnasoft.us/api/v1.0/systemactions/clearing`

### Runner

- `d:/DevReps/qa/Tools/ClearingTester/run_volant_easy_to_borrow_int2.py`

### Atomic tests

- `d:/DevReps/qa/Tools/ClearingTester/tests/test_volant_easy_to_borrow_int2.py`

### Payload template

- `d:/DevReps/qa/Tools/ClearingTester/payloads/volant_easy_to_borrow_int2.template.json`

## Preflight

Before running:

1. Confirm task context against PR `15578` and branch `feature/228135-rqd-easy-to-borrow`.
2. Confirm the target action name is `Volant EasyToBorrow`.
3. Prepare auth variables:
   - `CLEARING_TESTER_USERNAME`
   - `CLEARING_TESTER_PASSWORD`
   - `CLEARING_TESTER_APP_KEY`
4. Prepare a **local**, non-committed payload copy from `volant_easy_to_borrow_int2.template.json`.
5. Replace placeholders in the local payload:
   - `uri`
   - `username`
   - `password`
   - `exactDate`
   - if needed, file path and header mode

## Local payload preparation

Recommended approach:

1. Copy `volant_easy_to_borrow_int2.template.json` to a local temp path outside the repo or to a gitignored local path.
2. Fill real values there.
3. Export:

```powershell
$env:CLEARING_TESTER_PAYLOAD = "D:\\local\\volant_easy_to_borrow_int2.local.json"
```

Do not commit the local payload file.

## Discovery-only run

Use this when you want to validate:

- token flow;
- host/path correctness;
- action existence;
- action not disabled;
- provider and handler parameter shape.

```powershell
$env:CLEARING_TESTER_USERNAME = "..."
$env:CLEARING_TESTER_PASSWORD = "..."
$env:CLEARING_TESTER_APP_KEY = "..."
$env:CLEARING_TESTER_BASE_URL = "https://priv-api-etna-demo-ci-int-2.etnasoft.us/api"

python d:\DevReps\qa\Tools\ClearingTester\run_volant_easy_to_borrow_int2.py
```

Expected:

- `test_01` .. `test_08` are green;
- `test_09` is skipped;
- suite ends with `OK (skipped=1)` or equivalent.

## Full run with PUT

Use this only when the payload has real values and mutation is intended:

```powershell
$env:CLEARING_TESTER_USERNAME = "..."
$env:CLEARING_TESTER_PASSWORD = "..."
$env:CLEARING_TESTER_APP_KEY = "..."
$env:CLEARING_TESTER_BASE_URL = "https://priv-api-etna-demo-ci-int-2.etnasoft.us/api"
$env:CLEARING_TESTER_PAYLOAD = "D:\\local\\volant_easy_to_borrow_int2.local.json"
$env:RUN_MUTATING_CLEARING_TESTS = "1"

python d:\DevReps\qa\Tools\ClearingTester\run_volant_easy_to_borrow_int2.py
```

Expected:

- all `test_01` .. `test_09` are green;
- `test_09_execute_action_returns_requested_action_name` passes;
- suite ends with `OK`.

## Evidence to capture

Capture and store at minimum:

1. Runner command used.
2. Date/time of run.
3. Whether the run was discovery-only or full mutation-enabled.
4. Final unittest summary:
   - total tests
   - skipped tests
   - overall status
5. Target hosts used:
   - token host
   - clearing host

Do not store:

- real password;
- real app key;
- committed payload with secrets.

## What automation proves

- INT2 auth via `/api/token` works for this flow;
- `Volant EasyToBorrow` exists in `systemactions/clearing`;
- action is not disabled on INT2;
- expected handler names are present;
- expected parameter keys are exposed;
- full `PUT` invocation path can return the requested action name.

## What automation does not prove

- resulting `AllowShort` values in DB;
- real file download success from SFTP;
- correct processing of actual RQD file contents;
- overridden securities final state;
- Octopus schedule/timezone behavior.

## Required manual follow-up

These items remain manual / environment validation:

- TC-228135-04: clearing-firm / overridden securities behavior;
- TC-228135-05: header handling against the actual RQD file;
- TC-228135-06: schedule and timezone behavior;
- recommended DB / log verification after the PUT run.

## Stop conditions

Stop and investigate if:

- token request fails;
- action is missing from `GET /systemactions/clearing`;
- action becomes `Disabled=true`;
- `PUT` returns error/conflict;
- response shape changes and breaks parameter discovery.
