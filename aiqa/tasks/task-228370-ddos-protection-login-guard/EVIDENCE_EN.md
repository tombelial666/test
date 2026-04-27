## Evidence — 228370 DDoS protection (MVC + WebApi)

Goal: show which items from `ETNA_TRADER/TESTPLAN_228370_DDOS_PROTECTION.md` are automated and were actually executed.

### MVC (FrontOffice)

Suite: `qa/frontoffice_login_guard/test_frontoffice_login_guard.py`

Run (example):

```powershell
cd d:\DevReps\qa\frontoffice_login_guard
python -m pytest -q -m "integration and not optional_creds"
```

Observed result:

- `8 passed, 1 deselected`
- output includes a hint for optional `TC-FO-GUARD-07` (enable via `FO_GUARD07_ENABLE=1`).

Coverage (pytest-cov):

```powershell
cd d:\DevReps\qa
python -m pytest -q frontoffice_login_guard -m "integration and not optional_creds" --cov=frontoffice_login_guard --cov-report=term-missing
```

Observed (key):

- `frontoffice_login_guard/test_frontoffice_login_guard.py`: **75%**

Test plan items covered:

- **MVC-RL-01**: `429` + `Retry-After` (burst) — `TestTcFoGuard03RateLimitLogOn`
- **MVC-BLOOM-01**: non-existing login → not `500` (optionally strict `401`) — `TestTcFoGuard05BloomPrecheck`
- **MVC-EXT-01**: `ExternalLogOn` without per-IP false-positive — `TestTcFoGuard04ExternalLogOnNoPerIp`
- **XFF (MVC practical)**: rotating `X-Forwarded-For` does not bypass limits — `TestTcFoGuard09XForwardedForSpoofingDoesNotBypass`

### WebApi `/token` (Pub API host)

Suite: `qa/webapi_token_guard/test_webapi_token_guard.py`

Swagger confirms endpoint:

- host: `pub-api-etna-demo-ci-int-2.etnasoft.us`
- basePath: `/api`
- path: `POST /token` (headers: `Username`, `Password`, `Et-App-Key`)

Run (example):

```powershell
cd d:\DevReps\qa\webapi_token_guard
$env:WA_BASE_URL="https://pub-api-etna-demo-ci-int-2.etnasoft.us/api"
$env:WA_TOKEN_PATH="/token"
$env:WA_USERNAME="admin"
$env:WA_PASSWORD="***"
$env:WA_APP_KEY="***"
python -m pytest -v -m integration
```

Observed result:

- `4 passed`

Coverage (pytest-cov):

```powershell
cd d:\DevReps\qa
python -m pytest -q webapi_token_guard -m integration --cov=webapi_token_guard --cov-report=term-missing
```

Observed (key):

- `webapi_token_guard/test_webapi_token_guard.py`: **91%**

Test plan items covered:

- **API-RL-01**: perIp+login rate limit — `TestWaTokenGuard03RateLimitPerIpLogin`
- **API-BLOOM-01**: non-existing login → invalid credentials (not `500`) — `TestWaTokenGuard02BloomPrecheck`
- **API-XFF-01 (practical)**: rotating `X-Forwarded-For` does not bypass limits — `TestWaTokenGuard04XffSpoofingDoesNotBypass`

### Load smoke (JMeter)

JMeter plan: `D:\Reps\temporarly\Jmeter\Jmeter\etna_token_guard_228370.jmx`

Rate-limit observation proof:

- `D:\DevReps\tasks\db-metrics-228370\load_20260427_201028.jtl` contains teardown row `OK (hits=2921)` with `MIN_RATE_LIMIT_HITS=50`

### Load smoke + DB snapshots (sqlcmd) — executed

Orchestration:

- `D:\DevReps\tasks\run_db_metrics_228370.ps1`
- `D:\DevReps\tasks\db_metrics_228370.sql`
- `D:\DevReps\tasks\summarize_db_metrics_228370.py`

Output artifacts (latest “normal load” run):

- `D:\DevReps\tasks\db-metrics-228370\before_20260427_201028.csv`
- `D:\DevReps\tasks\db-metrics-228370\after_20260427_201028.csv`
- `D:\DevReps\tasks\db-metrics-228370\load_20260427_201028.jtl`
- `D:\DevReps\tasks\db-metrics-228370\jmeter_20260427_201028.log`
- `D:\DevReps\tasks\db-metrics-228370\summary_20260427_201028.md` (delta perf counters + delta waits)

### Items not closed as “executed” in the plan

- **API-RL-02** (perIp burst with distinct logins): no dedicated pytest case; executed via JMeter (TG3 “distinct usernames”) and included in `load_*.jtl`.
- **API-RL-03** (`EnablePerIpRateLimit=false`): **not required (stakeholder decision)** — intentionally not validated on the stand; the flag is currently not exposed via configuration (code-only switch).

### Load profile and PASS/FAIL criteria (baseline “average hospital”)

Default “normal load” profile (orchestrator CLI):

- baseline idle window: `BaselineSeconds=120`
- load window: `LoadSeconds=180`
- JMeter: `THREADS=25`, `RAMP_UP=5`, `LOOPS=120`, `DISTINCT_LOGIN_ATTEMPTS=300`, `REQUIRE_RATE_LIMIT=1`, `MIN_RATE_LIMIT_HITS=50`

PASS/FAIL:

- **JMeter**: `Err: 0%` and teardown row `OK (hits>=MIN_RATE_LIMIT_HITS)`
- **DB (summary_*.md)**:
  - **CPU**: `Processor(_Total)\% Processor Time` avg during load window **<= 75%**
  - **QPS**: `SQLServer:SQL Statistics\Batch Requests/sec` does not collapse to 0 (no hard minimum; stands differ)
  - **Lock waits**: total `LCK_M_%` deltas **<= 5 seconds** and **<= 20%** of total delta waits (otherwise investigate)

### Coverage

Coverage % was measured for Python suites (see above). .NET coverage is expected to be available in CI.

