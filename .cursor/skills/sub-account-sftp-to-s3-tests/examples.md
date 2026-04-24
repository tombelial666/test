# Sub Account Sftp To S3 Tests examples

## Default run

```bash
(cwd: aiqa/tasks/sub-account) .\\run-optimized-tc.ps1 -FunctionName \"IntegrationSftpToS3TEST\" -Region \"us-east-1\" -PayloadFile \".\\json.json\"
```

## With explicit environment

```bash
export AWS_PROFILE=<value>
export DB_SERVER=<value>
export DB_USER=<value>
export DB_PASSWORD=<value>
export TRADER_DB=<value>
export AMS_DB=<value>
(cwd: aiqa/tasks/sub-account) .\\run-optimized-tc.ps1 -FunctionName \"IntegrationSftpToS3TEST\" -Region \"us-east-1\" -PayloadFile \".\\json.json\"
```

## With explicit environment (PowerShell)

```powershell
$env:AWS_PROFILE="<value>"
$env:DB_SERVER="<value>"
$env:DB_USER="<value>"
$env:DB_PASSWORD="<value>"
$env:TRADER_DB="<value>"
$env:AMS_DB="<value>"
(cwd: aiqa/tasks/sub-account) .\\run-optimized-tc.ps1 -FunctionName \"IntegrationSftpToS3TEST\" -Region \"us-east-1\" -PayloadFile \".\\json.json\"
```
