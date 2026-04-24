# Universal runner for optimized TC-02 ... TC-07 checks.
# No secrets are hardcoded here: pass DB/API credentials via parameters.

param(
    [string]$FunctionName = "IntegrationSftpToS3TEST",
    [string]$Region = "us-east-1",
    [string]$PayloadFile = ".\\json.json",
    [string]$LambdaResponseFile = ".\\lambda-response.json",
    [string]$LogSince = "5m",

    [string]$DbServer = "",
    [string]$DbUser = "",
    [string]$DbPassword = "",
    [string]$TraderDb = "etna_trader.ci-int-2.demo.etna",
    [string]$AmsDb = "et.ams.ci-int-2.demo.etna",

    [string]$AccountE = "ACF0005E",
    [string]$AccountF = "ACF0005F",
    [string]$BaseAccount = "ACF0005",

    [switch]$SkipInvoke,
    [switch]$SkipLogs,
    [switch]$SkipSql
)

$ErrorActionPreference = "Stop"

function Step([string]$msg) {
    Write-Host ""
    Write-Host "=== $msg ===" -ForegroundColor Cyan
}

function Ensure-File([string]$path) {
    if (-not (Test-Path -LiteralPath $path)) {
        throw "File not found: $path"
    }
}

function Sql-Run([string]$db, [string]$query) {
    if ([string]::IsNullOrWhiteSpace($DbServer) -or [string]::IsNullOrWhiteSpace($DbUser) -or [string]::IsNullOrWhiteSpace($DbPassword)) {
        throw "DB params are required for SQL checks: -DbServer -DbUser -DbPassword"
    }

    sqlcmd `
        -S $DbServer `
        -d $db `
        -U $DbUser `
        -P $DbPassword `
        -N -C -W -s "|" `
        -Q $query
}

Step "Context"
Write-Host ("UTC: " + (Get-Date).ToUniversalTime().ToString("o"))
aws sts get-caller-identity

if (-not $SkipInvoke) {
    Step "Lambda Invoke"
    Ensure-File $PayloadFile
    aws lambda invoke `
      --function-name $FunctionName `
      --region $Region `
      --cli-binary-format raw-in-base64-out `
      --payload ("file://" + ((Resolve-Path $PayloadFile).Path -replace "\\","/")) `
      $LambdaResponseFile
    Write-Host "Lambda response saved to: $LambdaResponseFile"
}

if (-not $SkipLogs) {
    Step "CloudWatch Tail"
    aws logs tail "/aws/lambda/$FunctionName" `
      --region $Region `
      --since $LogSince `
      --format short
}

if (-not $SkipSql) {
    Step "SQL Check #1 Account guard (E/F provider)"
    $q1 = @"
SELECT a.Id, a.ClearingAccount, a.ClearingFirm, a.Status
FROM dbo.Account a
WHERE a.ClearingAccount IN ('$AccountE', '$AccountF')
ORDER BY a.ClearingAccount;
"@
    Sql-Run -db $TraderDb -query $q1

    Step "SQL Check #2 AMS docs by base/type=1"
    $q2 = @"
SELECT TOP 20 ClearingAccountNumber, BaseClearingAccountNumber, Type, GeneratedForDate, Path, CreatedAt
FROM dbo.S3AccountDocumentInfos
WHERE BaseClearingAccountNumber = '$BaseAccount'
  AND Type = 1
ORDER BY CreatedAt DESC;
"@
    Sql-Run -db $AmsDb -query $q2
}

Step "Done"
Write-Host "Optimized checks completed."
