# Load smoke playbook (JMeter + SQL Server snapshots)

**Purpose:** a repeatable, non-prod load smoke with evidence: JMeter `.jtl/.log` + SQL Server **before/after** snapshots + markdown delta summary.

This is intended for **regression triage**, not for proving production performance/SLOs.

## 1) Minimal run (recommended default)

Use the orchestrator that captures DB snapshots and runs the JMeter token-guard load:

- Script: `tasks/run_db_metrics_228370.ps1`
- JMX: `tasks/etna_token_guard_228370.jmx`
- Output: `tasks/db-metrics-228370/`

### Required inputs (env)

- `SQL_USER`, `SQL_PASS`
- `ET_APP_KEY`, `VALID_USERNAME`, `WRONG_PASSWORD`

### Run command (example)

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tasks/run_db_metrics_228370.ps1 `
  -TrustServerCertificate `
  -BaselineSeconds 120 -LoadSeconds 180 `
  -JmeterThreads 25 -JmeterRampUpSeconds 5 -JmeterLoops 120 `
  -JmeterDistinctLoginAttempts 300 -JmeterMinRateLimitHits 50
```

### Artifacts to attach

- `before_*.csv`, `after_*.csv`
- `load_*.jtl`, `jmeter_*.log`
- `summary_*.md`

## 2) PASS/FAIL (smoke-grade)

- **JMeter:** `Err: 0%` and teardown row `OK (hits>=MIN_RATE_LIMIT_HITS)`
- **DB:** interpret `summary_*.md` deltas with coarse thresholds:
  - CPU avg during load window \(<= 75%\) (coarse guide)
  - `Batch Requests/sec` does not collapse to 0
  - `LCK_M_*` waits delta \(<= 5s\) and \(<= 20%\) of total waits delta

## 3) Notes on existing “temporarly” JMeter inventories

There are many historical JMeter plans under:

- `D:\Reps\temporarly\Jmeter\...`
- `D:\Reps\temporarly\Tradier scripts\...`

**Important:** many of those plans contain inline credentials (`dbPass`, `adminPass`, `appKey`). Treat them as **sensitive** and do not copy into versioned repo content. Prefer:

- passing secrets via `-J...` properties at runtime, or
- using a local `.properties` file that is never committed.

## 4) “50% flow” convention (Tradier plans)

Some Tradier plans use multiple thread groups named like:

- `50%flow`, `25%flow`, `rest%flow`

This is usually **not** CPU percentage control; it is a scenario authoring convention (thread group mix).
Treat “50%” as “enable only the 50%flow group” unless the plan documents a different meaning.

