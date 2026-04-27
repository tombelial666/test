param(
  [string]$SqlServer = "db.ci-int-2.demo.etna.projects.etna.etnasoft.com",
  [string]$Database = "etna_trader.ci-int-2.demo.etna",
  [int]$SqlPort = 1433,
  [int]$BaselineSeconds = 120,
  [int]$LoadSeconds = 120,
  [int]$JmeterThreads = 10,
  [int]$JmeterRampUpSeconds = 2,
  [int]$JmeterLoops = 50,
  [int]$JmeterDistinctLoginAttempts = 120,
  [int]$JmeterMinRateLimitHits = 10,
  [string]$JMeterBin = "D:\Reps\temporarly\Jmeter\Jmeter\apache-jmeter-5.6.3\bin\jmeter.bat",
  [string]$JmxPath = "D:\Reps\temporarly\Jmeter\Jmeter\etna_token_guard_228370.jmx",
  [string]$OutDir = "D:\DevReps\tasks\db-metrics-228370",
  [switch]$TrustServerCertificate
)

$ErrorActionPreference = "Stop"

function Require-Env([string]$Name) {
  $v = [Environment]::GetEnvironmentVariable($Name)
  if ([string]::IsNullOrWhiteSpace($v)) {
    throw "Missing env var: $Name"
  }
  return $v
}

function Run-SqlcmdCli([string[]]$SqlcmdArgs) {
  # NOTE: do not name the parameter $Args (PowerShell automatic variable)
  & sqlcmd @SqlcmdArgs
  if ($LASTEXITCODE -ne 0) {
    throw "sqlcmd failed with exit code $LASTEXITCODE"
  }
}

$sqlUser = Require-Env "SQL_USER"
$sqlPass = Require-Env "SQL_PASS"

$etAppKey = Require-Env "ET_APP_KEY"
$validUser = Require-Env "VALID_USERNAME"
$wrongPass = Require-Env "WRONG_PASSWORD"

New-Item -ItemType Directory -Force -Path $OutDir | Out-Null

$ts = Get-Date -Format "yyyyMMdd_HHmmss"
$before = Join-Path $OutDir "before_$ts.txt"
$after  = Join-Path $OutDir "after_$ts.txt"
$beforeCsv = Join-Path $OutDir "before_$ts.csv"
$afterCsv  = Join-Path $OutDir "after_$ts.csv"
$jtl    = Join-Path $OutDir "load_$ts.jtl"
$jmeterLog = Join-Path $OutDir "jmeter_$ts.log"
$summaryMd = Join-Path $OutDir "summary_$ts.md"

Write-Host "OutDir: $OutDir"
Write-Host "Baseline: $BaselineSeconds sec, Load: $LoadSeconds sec"
Write-Host "JMeter: threads=$JmeterThreads rampUp=$JmeterRampUpSeconds loops=$JmeterLoops distinct=$JmeterDistinctLoginAttempts minRateLimitHits=$JmeterMinRateLimitHits"
Write-Host "SqlServer: $SqlServer"
Write-Host "Database:  $Database"

$serverForSqlcmd = $SqlServer
# Force TCP by default to avoid Named Pipes fallbacks/timeouts.
if ($serverForSqlcmd -notmatch '^(tcp:|np:)' ) {
  if ($serverForSqlcmd -match ',') {
    $serverForSqlcmd = "tcp:$serverForSqlcmd"
  } else {
    $serverForSqlcmd = "tcp:$serverForSqlcmd,$SqlPort"
  }
}
Write-Host "Sqlcmd -S: $serverForSqlcmd"

$trustArgs = @()
if ($TrustServerCertificate) {
  # Trust server certificate (avoids ODBC 18 chain errors on internal PKI).
  $trustArgs += @("-C")
}

Write-Host "1) Baseline snapshot..."
Run-SqlcmdCli ( @(
  "-S", $serverForSqlcmd,
  "-U", $sqlUser,
  "-P", $sqlPass,
  "-d", $Database,
  "-i", "D:\DevReps\tasks\db_metrics_228370.sql",
  "-o", $beforeCsv,
  "-l", "15",
  "-r", "1",
  "-W",
  "-s", ","
) + $trustArgs )

Write-Host "2) Idle baseline window ($BaselineSeconds sec)..."
Start-Sleep -Seconds $BaselineSeconds

Write-Host "3) Start load (JMeter) for ~${LoadSeconds}s..."
if (!(Test-Path $JMeterBin)) { throw "JMeter not found: $JMeterBin" }
if (!(Test-Path $JmxPath)) { throw "JMX not found: $JmxPath" }

$jArgs = @(
  "-n",
  "-t", $JmxPath,
  "-JET_APP_KEY=$etAppKey",
  "-JVALID_USERNAME=$validUser",
  "-JWRONG_PASSWORD=$wrongPass",
  "-JTHREADS=$JmeterThreads",
  "-JRAMP_UP=$JmeterRampUpSeconds",
  "-JLOOPS=$JmeterLoops",
  "-JDISTINCT_LOGIN_ATTEMPTS=$JmeterDistinctLoginAttempts",
  "-JREQUIRE_RATE_LIMIT=1",
  "-JMIN_RATE_LIMIT_HITS=$JmeterMinRateLimitHits",
  "-JEXPECT_PER_IP_DISABLED=0",
  "-l", $jtl,
  "-j", $jmeterLog
)

$p = Start-Process -FilePath $JMeterBin -ArgumentList $jArgs -NoNewWindow -PassThru
Start-Sleep -Seconds $LoadSeconds
if (!$p.HasExited) {
  Write-Host "Stopping JMeter (pid=$($p.Id))..."
  Stop-Process -Id $p.Id -Force
}

Write-Host "4) After snapshot..."
Run-SqlcmdCli ( @(
  "-S", $serverForSqlcmd,
  "-U", $sqlUser,
  "-P", $sqlPass,
  "-d", $Database,
  "-i", "D:\DevReps\tasks\db_metrics_228370.sql",
  "-o", $afterCsv,
  "-l", "15",
  "-r", "1",
  "-W",
  "-s", ","
) + $trustArgs )

Write-Host "5) Build markdown summary..."
python "D:\DevReps\tasks\summarize_db_metrics_228370.py" $beforeCsv $afterCsv $summaryMd

Write-Host "Done."
Write-Host "Baseline snapshot: $beforeCsv"
Write-Host "After snapshot:    $afterCsv"
Write-Host "JMeter results:    $jtl"
Write-Host "JMeter log:        $jmeterLog"
Write-Host "Summary markdown:  $summaryMd"

