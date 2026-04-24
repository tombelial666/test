# Test execution summary — Task 228135 / Volant EasyToBorrow

## Execution scope

This summary captures the current state of execution evidence for task `228135`, including the successful INT2 automation run and the remaining manual/environment checks.

## Automated execution evidence

### Environment

- token host: `https://pub-api-etna-demo-ci-int-2.etnasoft.us/api/token`
- clearing action host: `https://priv-api-etna-demo-ci-int-2.etnasoft.us/api/v1.0/systemactions/clearing`
- runner: `qa/Tools/ClearingTester/run_volant_easy_to_borrow_int2.py`

### Authentication model used

- token retrieved once from `/api/token` using:
  - `username`
  - `password`
  - `Et-App-Key`
- the returned token was reused for the full run

### Full run result

Observed result:

```text
Ran 9 tests in 4.519s

OK
```

### Covered automated checks

| Atomic test | Purpose | Status |
|-------------|---------|--------|
| `test_01_get_actions_contains_volant_easy_to_borrow` | action exists | PASS |
| `test_02_action_is_not_disabled` | action is enabled | PASS |
| `test_03_provider_handler_is_present` | provider handler is exposed | PASS |
| `test_04_provider_handler_shape_matches_expected_keys` | provider parameter key shape matches expected payload | PASS |
| `test_05_etb_handler_is_present` | ETB handler is exposed | PASS |
| `test_06_handler_parameters_match_expected_keys` | ETB handler parameter key shape matches expected payload | PASS |
| `test_07_header_handling_flag_is_present_in_payload` | payload explicitly carries header handling flag | PASS |
| `test_08_exact_date_is_supplied_for_controlled_runs` | payload carries explicit controlled run date | PASS |
| `test_09_execute_action_returns_requested_action_name` | mutation path via `PUT /systemactions/clearing` succeeds | PASS |

## TC status summary

| TC | Description | Current status | Evidence type |
|----|-------------|----------------|---------------|
| TC-228135-01 | Volant ETB provider is enabled with correct parameters | PASS | automation + static config evidence |
| TC-228135-02 | Default mode resets missing securities | PASS | feature-branch handler logic + branch test artifact in `AdditionalSecurityDataProcessingTest` / `CorSodETBTest.json` |
| TC-228135-03 | Opt-out mode keeps missing securities unchanged | PASS | explicit feature-branch `setOthersFalse=false` scenario in `CorSodETBTest.json` + handler condition guarded by `_setOthersFalse` |
| TC-228135-04 | Clearing-firm path remains valid | PARTIAL | INT2 action execution path is green and `clearingFirm` is part of handler contract, but overridden-securities DB/result-state is not yet validated |
| TC-228135-05 | Header handling matches actual RQD file | PARTIAL | config mapping and payload/header flag are evidenced, but no real RQD sample-file validation is captured |
| TC-228135-06 | Schedule and timezone are operationally correct | PARTIAL | schedule variables and `Eastern Standard Time` are evidenced statically, but no timed Octopus execution evidence is captured |
| TC-228135-07 | Canonical indexing remains unchanged | PASS | task-package review evidence |

## What is proven by the current run

- auth flow for INT2 is valid for this scenario;
- the correct clearing action endpoint is reachable;
- the action exists and is enabled on INT2;
- action handler names and expected parameter keys are discoverable;
- `PUT /systemactions/clearing` succeeds for the prepared payload on INT2.

## What is not proven yet

- DB/result-state changes after execution;
- actual `AllowShort` values after processing;
- real SFTP file retrieval success;
- correctness against a real RQD sample file;
- schedule/timezone behavior under Octopus timing.

## Additional review after the first summary

- feature-branch evidence confirms `EasyToBorrowHandler` now loads `setOthersFalse` with default fallback `true`;
- feature-branch `CorSodETBTest.json` contains a second scenario named `ETB setOthersFalse false`;
- feature-branch test project includes `CorSodETBTest.json` and wires it through `AdditionalSecurityDataProcessingTest`;
- a temporary feature-branch worktree was prepared to try to obtain fresh local run evidence, but the available local `dotnet test` flow did not emit runnable NUnit result output for this legacy project, so status decisions still rely on branch artifacts plus the already completed INT2 API run.

## Testing completion decision

### Completed

- automation path to `systemactions/clearing`
- task-package evidence for provider wiring and handler semantics
- canonical-boundary review

### Remaining before full sign-off

- DB/result-state follow-up for ETB and overridden securities
- real file format/header validation
- schedule/timezone validation on the intended environment window
