## 228370 — Evidence package (attach to Azure)

This file lists the artifacts you can attach to the PR / work item as proof of the runs.
Do **not** attach secrets (passwords, AppKey, SQL password).

### 1) MVC (FrontOffice) — pytest

- **Suite**: `qa/frontoffice_login_guard/test_frontoffice_login_guard.py`
- **Command**:

```powershell
cd d:\DevReps\qa\frontoffice_login_guard
python -m pytest -v -m "integration and not optional_creds"
```

- **Expected outcome**: `8 passed, 1 deselected`

### 2) WebApi `/api/token` (Pub API host) — pytest

- **Suite**: `qa/webapi_token_guard/test_webapi_token_guard.py`
- **Command**:

```powershell
cd d:\DevReps\qa\webapi_token_guard
$env:WA_BASE_URL="https://pub-api-etna-demo-ci-int-2.etnasoft.us/api"
$env:WA_TOKEN_PATH="/token"
$env:WA_USERNAME="admin"
$env:WA_PASSWORD="***"
$env:WA_APP_KEY="***"
python -m pytest -v -m integration
```

- **Expected outcome**: `4 passed`

### 3) Load smoke + DB snapshots (automated)

#### 3.1 JMeter plan

- **JMX**: `D:\Reps\temporarly\Jmeter\Jmeter\etna_token_guard_228370.jmx`
- **JTL proof**: the output `.jtl` contains a teardown row like `OK (hits=...)` (proof that rate-limit was observed).

Latest “normal load” run:

- `D:\DevReps\tasks\db-metrics-228370\load_20260427_201028.jtl`
  - contains `OK (hits=2921)` with `MIN_RATE_LIMIT_HITS=50`
- `D:\DevReps\tasks\db-metrics-228370\jmeter_20260427_201028.log`

#### 3.2 DB snapshots + summary

Orchestrator:

- `D:\DevReps\tasks\run_db_metrics_228370.ps1`
  - uses `D:\DevReps\tasks\db_metrics_228370.sql` and `D:\DevReps\tasks\summarize_db_metrics_228370.py`

Output folder:

- `D:\DevReps\tasks\db-metrics-228370\`

Inside:

- `before_*.csv`
- `after_*.csv`
- `load_*.jtl`
- `jmeter_*.log`
- `summary_*.md` (delta perf counters + delta waits)

Latest “normal load” artifacts:

- `D:\DevReps\tasks\db-metrics-228370\before_20260427_201028.csv`
- `D:\DevReps\tasks\db-metrics-228370\after_20260427_201028.csv`
- `D:\DevReps\tasks\db-metrics-228370\summary_20260427_201028.md`

