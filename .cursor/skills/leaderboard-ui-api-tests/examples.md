# Leaderboard Ui Api Tests examples

## Default run

```bash
(cwd: qa/leaderboard-tests) python -m pytest -v test_smoke test_regression
```

## With explicit environment

```bash
export LB_BASE_URL=<value>
export INT2_USERNAME=<value>
export INT2_PASSWORD=<value>
(cwd: qa/leaderboard-tests) python -m pytest -v test_smoke test_regression
```

## With explicit environment (PowerShell)

```powershell
$env:LB_BASE_URL="<value>"
$env:INT2_USERNAME="<value>"
$env:INT2_PASSWORD="<value>"
(cwd: qa/leaderboard-tests) python -m pytest -v test_smoke test_regression
```
