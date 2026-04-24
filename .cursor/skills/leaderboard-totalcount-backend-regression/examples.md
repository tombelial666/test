# Leaderboard Totalcount Backend Regression examples

## Default run

```bash
(cwd: aiqa/tasks/leaderboard smoke and regression) dotnet test backend-automation.csproj --filter \"FullyQualifiedName~TotalCount\"
```

## With explicit environment

```bash
export ETNA_ACCOUNTS_URL=<value>
export ETNA_TOKEN_URL=<value>
export ETNA_APP_KEY=<value>
export ETNA_USERNAME=<value>
export ETNA_PASSWORD=<value>
(cwd: aiqa/tasks/leaderboard smoke and regression) dotnet test backend-automation.csproj --filter \"FullyQualifiedName~TotalCount\"
```

## With explicit environment (PowerShell)

```powershell
$env:ETNA_ACCOUNTS_URL="<value>"
$env:ETNA_TOKEN_URL="<value>"
$env:ETNA_APP_KEY="<value>"
$env:ETNA_USERNAME="<value>"
$env:ETNA_PASSWORD="<value>"
(cwd: aiqa/tasks/leaderboard smoke and regression) dotnet test backend-automation.csproj --filter \"FullyQualifiedName~TotalCount\"
```
