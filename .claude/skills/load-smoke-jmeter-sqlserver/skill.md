---
name: load-smoke-jmeter-sqlserver
description: Run a non-prod load smoke using JMeter and capture SQL Server before/after snapshots (perf counters + waits), producing a markdown delta summary for quick regression triage.

---

# Load Smoke Jmeter Sqlserver

## Trigger scenarios
- need a quick, repeatable load smoke with DB evidence (before/after)
- validate rate-limits / login guard / token endpoints under burst load
- investigate “DB pressure” changes with a minimal metrics bundle

## Run command
- `powershell -NoProfile -ExecutionPolicy Bypass -File tasks/run_db_metrics_228370.ps1 -TrustServerCertificate -BaselineSeconds 120 -LoadSeconds 180 -JmeterThreads 25 -JmeterRampUpSeconds 5 -JmeterLoops 120 -JmeterDistinctLoginAttempts 300 -JmeterMinRateLimitHits 50
`

## Required inputs
- `SQL_USER`
- `SQL_PASS`
- `ET_APP_KEY`
- `VALID_USERNAME`
- `WRONG_PASSWORD`

## Safety
- no_secrets_in_repo: True
- non_prod_only: True
- burst_tests_are_opt_in: True

## Evidence
- `tasks/run_db_metrics_228370.ps1`
- `tasks/db_metrics_228370.sql`
- `tasks/summarize_db_metrics_228370.py`
- `tasks/etna_token_guard_228370.jmx`
