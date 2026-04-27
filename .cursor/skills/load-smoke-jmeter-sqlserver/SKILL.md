---
name: load-smoke-jmeter-sqlserver
description: Run a non-prod load smoke using JMeter and capture SQL Server before/after snapshots (perf counters + waits), producing a markdown delta summary for quick regression triage.

---

# Load Smoke Jmeter Sqlserver

## When to use
- need a quick, repeatable load smoke with DB evidence (before/after)
- validate rate-limits / login guard / token endpoints under burst load
- investigate “DB pressure” changes with a minimal metrics bundle

## Out of scope
- production load testing
- long-running soak tests without explicit approval
- claiming performance SLO compliance (this is smoke + evidence)

## Run
- `(cwd: .) powershell -NoProfile -ExecutionPolicy Bypass -File tasks/run_db_metrics_228370.ps1 -TrustServerCertificate -BaselineSeconds 120 -LoadSeconds 180 -JmeterThreads 25 -JmeterRampUpSeconds 5 -JmeterLoops 120 -JmeterDistinctLoginAttempts 300 -JmeterMinRateLimitHits 50`

## Inputs
**Required env**
- `SQL_USER`
- `SQL_PASS`
- `ET_APP_KEY`
- `VALID_USERNAME`
- `WRONG_PASSWORD`

**Optional env**
- `SQL_SERVER`
- `SQL_DATABASE`
- `SQL_PORT`

**Optional CLI**
- n/a

## Endpoints
- n/a

## Safety
- no_secrets_in_repo: True
- non_prod_only: True
- burst_tests_are_opt_in: True

## Evidence basis
- `tasks/run_db_metrics_228370.ps1`
- `tasks/db_metrics_228370.sql`
- `tasks/summarize_db_metrics_228370.py`
- `tasks/etna_token_guard_228370.jmx`

## Source spec
- `aiqa/skills-catalog/load-smoke-jmeter-sqlserver.yaml`
