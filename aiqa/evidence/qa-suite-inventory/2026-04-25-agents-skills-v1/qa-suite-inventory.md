# QA suite inventory (agents+skills baseline)

## Source suites

### 1) `qa/Tools/ClearingTester`

- Primary docs/runners:
  - `qa/Tools/ClearingTester/README.md`
  - `qa/Tools/ClearingTester/run_volant_easy_to_borrow_int2.py`
  - `qa/Tools/ClearingTester/tests/test_volant_easy_to_borrow_int2.py`
  - `qa/Tools/ClearingTester/systemactions/auth.py`
  - `qa/Tools/ClearingTester/systemactions/client.py`
  - `qa/Tools/ClearingTester/payloads/volant_easy_to_borrow_int2.template.json`
- Required env vars:
  - `CLEARING_TESTER_USERNAME`
  - `CLEARING_TESTER_PASSWORD`
  - `CLEARING_TESTER_APP_KEY`
- Optional env vars:
  - `CLEARING_TESTER_TOKEN_URL`
  - `CLEARING_TESTER_BASE_URL`
  - `CLEARING_TESTER_ROUTE`
  - `CLEARING_TESTER_PAYLOAD`
  - `CLEARING_TESTER_TOKEN`
  - `RUN_MUTATING_CLEARING_TESTS`
- Endpoints:
  - `POST https://pub-api-etna-demo-ci-int-2.etnasoft.us/api/token`
  - `GET https://priv-api-etna-demo-ci-int-2.etnasoft.us/api/v1.0/systemactions/clearing`
  - `PUT https://priv-api-etna-demo-ci-int-2.etnasoft.us/api/v1.0/systemactions/clearing`
- Mutation gating:
  - PUT execution test is skipped unless `RUN_MUTATING_CLEARING_TESTS=1`.

### 2) `qa/leaderboard-tests`

- Primary docs/runners:
  - `qa/leaderboard-tests/conftest.py`
  - `qa/leaderboard-tests/model/pages/leaderboard_page.py`
  - `qa/leaderboard-tests/test_smoke/test_leaderboard_smoke.py`
  - `qa/leaderboard-tests/test_regression/*.py`
- Framework/tooling:
  - `pytest`
  - `playwright`
- CLI options:
  - `--lb-base-url`
  - `--lb-username`
  - `--lb-password`
  - `--lb-priv-api-url`
  - `--lb-app-key`
- Env vars (expected):
  - `LB_BASE_URL`
  - `INT2_USERNAME`
  - `INT2_PASSWORD`
  - `LB_PRIV_API_URL`
  - `LB_APP_KEY`
- Endpoints/surfaces:
  - UI base URL (default INT2 host)
  - API path observed by tests: `public/v1/accounts-with-balances`
- Risk note:
  - `conftest.py` currently has default login/password literals and must be sanitized.

### 3) `qa/frontoffice_login_guard`

- Primary docs/runners:
  - `qa/frontoffice_login_guard/test_frontoffice_login_guard.py`
  - `qa/frontoffice_login_guard/conftest.py`
- Framework/tooling:
  - `pytest`
  - `requests`
- Core env vars:
  - `FO_BASE_URL`
  - `FO_LOGON_PATH`
  - `FO_EXTERNAL_LOGON_PATH`
  - `FO_EXTERNAL_COMPANY_ID`
  - `FO_USERNAME`
  - `FO_PASSWORD`
- Additional env vars (rate/burst/strict/replay):
  - `FO_EXPECTED_RETRY_AFTER`
  - `FO_BURST_ATTEMPTS`
  - `FO_BURST_LOGIN`
  - `FO_BURST_WRONG_PASSWORD`
  - `FO_EXTERNAL_VALID_USERNAME`
  - `FO_EXTERNAL_VALID_PASSWORD`
  - `FO_EXTERNAL_LOGON_EXTRA_JSON`
  - `FO_GUARD07_*`
- Endpoints:
  - `GET /User/LogOn`
  - `POST /User/LogOn`
  - `POST /User/ExternalLogOn?companyId=...`
- Assertions:
  - no unexpected `500` for unknown logins
  - rate limit behavior (`429` + `Retry-After`)
  - optional strict Bloom-precheck mode (`401`)

## Harvested inventory from repositories

### `ETNA_TRADER`

- FrontOffice login and external login are present in deployment/web/user layers:
  - `src/Etna.Web/Etna.Web.User/Controllers/UserControllerBase.cs`
  - login URLs in web/deployment configs (`/User/LogOn`, `/User/ExternalLogOn`)
- Bloom precheck and login rate limit implementation:
  - `src/Etna.Web/Etna.Web/ActionAttributes/LoginUserExistencePrecheckAttribute.cs`
  - `src/Etna.Web/Etna.Web/ActionAttributes/LoginRateLimitAttribute.cs`
  - `src/Etna.Web/Etna.Web/User/UserLoginBloomFilter.cs`
  - `src/Etna.Web/Etna.Web/User/UserManager.cs`
- Leaderboard surfaces:
  - `src/Etna.Trader/Etna.Trader.Web/src/scripts/API/AccountWithBalancesService.js`
  - `src/Etna.Trader/Etna.Trader.WebApi.Customization/AccountsWithBalances/AccountsWithBalancesController.cs`
  - `src/Etna.Trader/Etna.Trader.WebApi.Customization/AccountsWithBalances/InternalAccountsWithBalancesController.cs`
  - `src/Etna.Trader/Etna.Trader.Web/Widgets/Leaderboard/**`

### `ServerlessIntegrations`

- JotForm ingestion surfaces:
  - `IntegrationJotFormToS3/**`
  - `IntegrationReportCAISToS3/**`
  - `IntegrationLambdaBase/JotForm/JotformAPIClient.cs`
- SftpToS3 surfaces:
  - `IntegrationSftpToS3/**`
  - `IntegrationSftpToS3/DOCUMENTATION.md`
  - `IntegrationSftpToS3.Tests/BaseClearingAccountNumberConvertersTests.cs`
- Scope note:
  - these are supplemental inventory inputs for skills/evidence, not direct triggers for immediate skill execution in the first wave.

## Evidence basis

- Source readouts: suite files above plus harvested grep results from `ETNA_TRADER` and `ServerlessIntegrations`.
- Confidence:
  - high for directly parsed suite config/endpoints
  - medium for inferred related surfaces outside direct suite files
