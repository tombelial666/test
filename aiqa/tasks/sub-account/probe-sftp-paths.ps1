# Probes IntegrationSftpToS3TEST with multiple SFTP Path templates.
# Uses aws lambda invoke --log-type Tail so each run's logs are isolated.
# AWS CLI writes to stderr; do not use $ErrorActionPreference = 'Stop' around aws.
$ErrorActionPreference = "Continue"
$Region = "us-east-1"
$FunctionName = "IntegrationSftpToS3TEST"
$TaskDir = $PSScriptRoot
$TemplatePath = Join-Path $TaskDir "path-probe-template.json"
$OutResponse = Join-Path $TaskDir "lambda-response-probe.json"

$paths = @(
    "downloads/AccountDocuments/Fidelity/{accountNumber}/{ignore}.pdf",
    "sftp/downloads/AccountDocuments/Fidelity/{accountNumber}/{ignore}.pdf",
    "/home/etna/sftp/downloads/AccountDocuments/Fidelity/{accountNumber}/{ignore}.pdf",
    "/downloads/AccountDocuments/Fidelity/{accountNumber}/{ignore}.pdf",
    "/sftp/downloads/AccountDocuments/Fidelity/{accountNumber}/{ignore}.pdf",
    "home/etna/sftp/downloads/AccountDocuments/Fidelity/{accountNumber}/{ignore}.pdf",
    "etna/sftp/downloads/AccountDocuments/Fidelity/{accountNumber}/{ignore}.pdf",
    "./downloads/AccountDocuments/Fidelity/{accountNumber}/{ignore}.pdf",
    "/home/etna/downloads/AccountDocuments/Fidelity/{accountNumber}/{ignore}.pdf",
    "downloads/AccountDocuments/Fidelity/{accountNumber}/{ignore}.PDF",
    "AccountDocuments/Fidelity/{accountNumber}/{ignore}.pdf",
    "downloads/AccountDocuments/{accountNumber}/{ignore}.pdf",
    "Fidelity/{accountNumber}/{ignore}.pdf"
)

$template = Get-Content -Raw -LiteralPath $TemplatePath
$utf8NoBom = New-Object System.Text.UTF8Encoding $false
$index = 0
$results = @()

foreach ($p in $paths) {
    $index++
    $payloadPath = Join-Path $TaskDir ("path-probe-{0:D2}.json" -f $index)
    $json = $template.Replace("__PATH_VARIANT__", $p.Replace("\", "\\"))
    [System.IO.File]::WriteAllText($payloadPath, $json, $utf8NoBom)

    # Windows: use file://D:/path (two slashes after file:). file:///D:/ breaks payload and LogResult is empty.
    $payloadUri = "file://" + ($payloadPath -replace "\\", "/")

    Write-Host ""
    Write-Host "=== Probe $index / $($paths.Count) ===" -ForegroundColor Cyan
    Write-Host "Path: $p"

    # stderr from aws.exe breaks ConvertFrom-Json; drop stderr
    $awsOut = aws lambda invoke --function-name $FunctionName --region $Region --cli-binary-format raw-in-base64-out --log-type Tail --payload $payloadUri $OutResponse 2>$null
    $meta = ($awsOut | Out-String).Trim() | ConvertFrom-Json

    $logText = ""
    if ($meta.LogResult) {
        $bytes = [Convert]::FromBase64String($meta.LogResult)
        $logText = [System.Text.Encoding]::UTF8.GetString($bytes)
    }

    $notExist = $logText -match "Remote path .* does not exist"
    $dirsMatch = [regex]::Match($logText, "Found (\d+) directories in base path")
    $acctsMatch = [regex]::Match($logText, "Found (\d+) accounts in directories")
    $dirCount = if ($dirsMatch.Success) { [int]$dirsMatch.Groups[1].Value } else { -1 }
    $acctCount = if ($acctsMatch.Success) { [int]$acctsMatch.Groups[1].Value } else { -1 }

    $ok = (-not $notExist) -and ($dirCount -gt 0 -or $acctCount -gt 0)

    $results += [pscustomobject]@{
        Index         = $index
        Path          = $p
        File          = Split-Path $payloadPath -Leaf
        RemoteMissing = $notExist
        DirCount      = $dirCount
        AccountCount  = $acctCount
        LikelyOK      = $ok
    }

    if ($ok) {
        Write-Host ">>> LIKELY OK: dirs=$dirCount accounts=$acctCount" -ForegroundColor Green
    } else {
        Write-Host ">>> no match (dirs=$dirCount accounts=$acctCount remoteMissing=$notExist)" -ForegroundColor Yellow
    }

    if ($logText -match "Error processing document option path") {
        Write-Host ">>> Lambda path parse error" -ForegroundColor DarkYellow
    }
}

Write-Host ""
Write-Host "=== Summary ===" -ForegroundColor Cyan
$results | Format-Table -AutoSize

$best = $results | Where-Object { $_.LikelyOK } | Select-Object -First 1
if ($best) {
    Write-Host "Use this Path in json.json:" -ForegroundColor Green
    Write-Host $best.Path
    Write-Host "Payload file:" (Join-Path $TaskDir ("path-probe-{0:D2}.json" -f $best.Index))
} else {
    Write-Host "No variant showed Found N>0 directories. Extend `$paths in probe-sftp-paths.ps1 or verify SFTP secret/host." -ForegroundColor Red
}
