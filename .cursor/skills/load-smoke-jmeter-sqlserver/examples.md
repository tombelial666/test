# Load Smoke Jmeter Sqlserver examples

## Default run

```bash
(cwd: .) powershell -NoProfile -ExecutionPolicy Bypass -File tasks/run_db_metrics_228370.ps1 -TrustServerCertificate -BaselineSeconds 120 -LoadSeconds 180 -JmeterThreads 25 -JmeterRampUpSeconds 5 -JmeterLoops 120 -JmeterDistinctLoginAttempts 300 -JmeterMinRateLimitHits 50
```

## With explicit environment

```bash
export SQL_USER=<value>
export SQL_PASS=<value>
export ET_APP_KEY=<value>
export VALID_USERNAME=<value>
export WRONG_PASSWORD=<value>
(cwd: .) powershell -NoProfile -ExecutionPolicy Bypass -File tasks/run_db_metrics_228370.ps1 -TrustServerCertificate -BaselineSeconds 120 -LoadSeconds 180 -JmeterThreads 25 -JmeterRampUpSeconds 5 -JmeterLoops 120 -JmeterDistinctLoginAttempts 300 -JmeterMinRateLimitHits 50
```

## With explicit environment (PowerShell)

```powershell
$env:SQL_USER="<value>"
$env:SQL_PASS="<value>"
$env:ET_APP_KEY="<value>"
$env:VALID_USERNAME="<value>"
$env:WRONG_PASSWORD="<value>"
(cwd: .) powershell -NoProfile -ExecutionPolicy Bypass -File tasks/run_db_metrics_228370.ps1 -TrustServerCertificate -BaselineSeconds 120 -LoadSeconds 180 -JmeterThreads 25 -JmeterRampUpSeconds 5 -JmeterLoops 120 -JmeterDistinctLoginAttempts 300 -JmeterMinRateLimitHits 50
```
