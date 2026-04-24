$ErrorActionPreference = "Stop"

$base = "https://pub-api-etna-demo-ci-int-2.etnasoft.us/api"
$appKey = $env:PUB_API_APP_KEY
$username = $env:PUB_API_USERNAME
$password = $env:PUB_API_PASSWORD
$accountId = 37

# Required only for option flows (TC-04/05/06/08).
$optionSymbol = $env:PUB_API_OPTION_SYMBOL

# Retest flags
# Set to $true for the cases you want to run.
$runTC01 = $true
$runTC02 = $true
$runTC03 = $true
$runTC04 = $true
$runTC05 = $true
$runTC06 = $true
$runTC07 = $true
$runTC08 = $true
$runTC09 = $true
$runTC10 = $true

function Require-Value {
  param(
    [string]$name,
    [string]$value,
    [switch]$secret
  )

  if ($value -and $value -notmatch "^REPLACE_WITH_") {
    return $value
  }

  if ($secret) {
    $secure = Read-Host "$name" -AsSecureString
    $bstr = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($secure)
    try { return [Runtime.InteropServices.Marshal]::PtrToStringBSTR($bstr) }
    finally { [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr) }
  }

  return Read-Host "$name"
}

$appKey = Require-Value -name "Et-App-Key (PUB_API_APP_KEY)" -value $appKey
$username = Require-Value -name "Username (PUB_API_USERNAME)" -value $username
$password = Require-Value -name "Password (PUB_API_PASSWORD)" -value $password -secret

if (-not $optionSymbol -or $optionSymbol -match "^REPLACE_WITH_") {
  $optionSymbol = "REPLACE_WITH_REAL_OPTION_SYMBOL"
}

$optionCasesEnabled = $runTC04 -or $runTC05 -or $runTC06 -or $runTC08
if ($optionCasesEnabled -and ($optionSymbol -eq "REPLACE_WITH_REAL_OPTION_SYMBOL")) {
  throw "Option cases enabled, but PUB_API_OPTION_SYMBOL is not set."
}

$loginHeaders = @{
  Username = $username
  Password = $password
  "Et-App-Key" = $appKey
}

Write-Host "Logging in..." -ForegroundColor Yellow
$login = $null
try {
  $login = Invoke-RestMethod -Method Post -Uri "$base/token" -Headers $loginHeaders
}
catch {
  if ($_.Exception.Response -and $_.Exception.Response.StatusCode.value__ -eq 401) {
    throw "401 Unauthorized на $base/token. Проверьте Et-App-Key/username/password. Рекомендуется задать env: PUB_API_APP_KEY, PUB_API_USERNAME, PUB_API_PASSWORD."
  }
  throw
}
$token = $login.Token

if (-not $token) {
  throw "Login failed: token is empty"
}

$headers = @{
  Authorization = "Bearer $token"
  "Et-App-Key"  = $appKey
}

function New-EquityOrder {
  param(
    [string]$clientId,
    [string]$comment,
    [string]$extendedHours,
    [string]$exchange = "NGS"
  )

  @{
    Symbol = "MSFT"
    ClientId = $clientId
    ExpireDate = (Get-Date).ToUniversalTime().AddMinutes(30).ToString("o")
    Type = "Market"
    Side = "Buy"
    Comment = $comment
    ExecInst = "None"
    TimeInForce = "Day"
    Quantity = 1
    Price = 0
    StopPrice = 0
    Exchange = $exchange
    TrailingStopAmountType = "Absolute"
    TrailingStopAmount = 0
    TrailingLimitAmountType = "Absolute"
    TrailingLimitAmount = 0
    ExtendedHours = $extendedHours
    Token = $token
    ExecutionInstructions = @{}
    ValidationsToBypass = 0
    Legs = @()
    ParentId = 0
  }
}

function New-OptionOrder {
  param(
    [string]$clientId,
    [string]$comment,
    [string]$exchange = "OPRAC",
    [string]$extendedHours = ""
  )

  @{
    Symbol = $optionSymbol
    ClientId = $clientId
    ExpireDate = (Get-Date).ToUniversalTime().AddMinutes(30).ToString("o")
    Type = "Market"
    Side = "Buy"
    Comment = $comment
    ExecInst = "None"
    TimeInForce = "Day"
    Quantity = 1
    Price = 0
    StopPrice = 0
    Exchange = $exchange
    TrailingStopAmountType = "Absolute"
    TrailingStopAmount = 0
    TrailingLimitAmountType = "Absolute"
    TrailingLimitAmount = 0
    ExtendedHours = $extendedHours
    Token = $token
    ExecutionInstructions = @{}
    ValidationsToBypass = 0
    Legs = @()
    ParentId = 0
  }
}

function Invoke-CreateOrder {
  param(
    [string]$testCase,
    [hashtable]$body
  )

  Write-Host ""
  Write-Host "=== $testCase ===" -ForegroundColor Cyan

  $json = $body | ConvertTo-Json -Depth 12

  try {
    $response = Invoke-RestMethod `
      -Method Post `
      -Uri "$base/v2.0/accounts/$accountId/syncorders" `
      -Headers $headers `
      -ContentType "application/json" `
      -Body $json

    [pscustomobject]@{
      TestCase = $testCase
      ClientId = $body.ClientId
      Status = "SUCCESS"
      Response = $response
    }
  }
  catch {
    $respText = $null
    if ($_.Exception.Response) {
      try {
        $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
        $respText = $reader.ReadToEnd()
      } catch {}
    }

    [pscustomobject]@{
      TestCase = $testCase
      ClientId = $body.ClientId
      Status = "ERROR"
      Message = $_.Exception.Message
      Response = $respText
    }
  }
}

function Invoke-ModifyOrder {
  param(
    [int]$orderId,
    [string]$origClientId
  )

  $body = @{
    Symbol = $optionSymbol
    ClientId = ("TC22812605-" + [guid]::NewGuid().ToString("N").Substring(0,8))
    OrigClientId = $origClientId
    ExpireDate = (Get-Date).ToUniversalTime().AddMinutes(30).ToString("o")
    Type = "Limit"
    Side = "Buy"
    Comment = "TC-228126-05 OPTION MODIFY"
    ExecInst = "None"
    TimeInForce = "Day"
    Quantity = 1
    Price = 1.00
    StopPrice = 0
    Exchange = "NGS"
    TrailingStopAmountType = "Absolute"
    TrailingStopAmount = 0
    TrailingLimitAmountType = "Absolute"
    TrailingLimitAmount = 0
    ExtendedHours = ""
    Token = $token
    ExecutionInstructions = @{}
    ValidationsToBypass = 0
    Legs = @()
    ParentId = 0
  }

  $json = $body | ConvertTo-Json -Depth 12

  Write-Host ""
  Write-Host "=== TC-228126-05 ===" -ForegroundColor Cyan

  try {
    $response = Invoke-RestMethod `
      -Method Put `
      -Uri "$base/v2.0/accounts/$accountId/syncorders/$orderId" `
      -Headers $headers `
      -ContentType "application/json" `
      -Body $json

    [pscustomobject]@{
      TestCase = "TC-228126-05"
      ClientId = $body.ClientId
      Status = "SUCCESS"
      Response = $response
    }
  }
  catch {
    $respText = $null
    if ($_.Exception.Response) {
      try {
        $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
        $respText = $reader.ReadToEnd()
      } catch {}
    }

    [pscustomobject]@{
      TestCase = "TC-228126-05"
      ClientId = $body.ClientId
      Status = "ERROR"
      Message = $_.Exception.Message
      Response = $respText
    }
  }
}

Write-Host ""
Write-Host "Wave 1: equity/session retest" -ForegroundColor Green

$wave1 = @()

if ($runTC01) {
  $wave1 += @{ Name = "TC-228126-01"; Body = (New-EquityOrder -clientId ("TC22812601-" + [guid]::NewGuid().ToString("N").Substring(0,8)) -comment "TC-228126-01 PRE" -extendedHours "PRE") }
}
if ($runTC02) {
  $wave1 += @{ Name = "TC-228126-02"; Body = (New-EquityOrder -clientId ("TC22812602-" + [guid]::NewGuid().ToString("N").Substring(0,8)) -comment "TC-228126-02 POST" -extendedHours "POST") }
}
if ($runTC03) {
  $wave1 += @{ Name = "TC-228126-03"; Body = (New-EquityOrder -clientId ("TC22812603-" + [guid]::NewGuid().ToString("N").Substring(0,8)) -comment "TC-228126-03 REG" -extendedHours "REG") }
}
if ($runTC07) {
  $wave1 += @{ Name = "TC-228126-07"; Body = (New-EquityOrder -clientId ("TC22812607-" + [guid]::NewGuid().ToString("N").Substring(0,8)) -comment "TC-228126-07 EQUITY REG" -extendedHours "REG") }
}
if ($runTC09) {
  $wave1 += @{ Name = "TC-228126-09"; Body = (New-EquityOrder -clientId ("TC22812609-" + [guid]::NewGuid().ToString("N").Substring(0,8)) -comment "TC-228126-09 EXPLICIT MNGD PRE" -extendedHours "PRE" -exchange "MNGD") }
}
if ($runTC10) {
  $wave1 += @{ Name = "TC-228126-10"; Body = (New-EquityOrder -clientId ("TC22812610-" + [guid]::NewGuid().ToString("N").Substring(0,8)) -comment "TC-228126-10 INVALID EXT HOURS" -extendedHours "INVALID_VALUE") }
}

$wave1Results = foreach ($test in $wave1) {
  Invoke-CreateOrder -testCase $test.Name -body $test.Body
}

Write-Host ""
Write-Host "Wave 2: option retest" -ForegroundColor Green
Write-Host "Option cases use PUB_API_OPTION_SYMBOL and TC-05 depends on TC-04." -ForegroundColor Yellow

$wave2Results = @()
$tc04 = $null

if ($runTC04) {
  $tc04 = Invoke-CreateOrder -testCase "TC-228126-04" -body (New-OptionOrder -clientId ("TC22812604-" + [guid]::NewGuid().ToString("N").Substring(0,8)) -comment "TC-228126-04 OPTION")
  $wave2Results += $tc04
}

if ($runTC05) {
  if ($tc04 -and $tc04.Status -eq "SUCCESS" -and $tc04.Response.Id) {
    $tc05 = Invoke-ModifyOrder -orderId $tc04.Response.Id -origClientId $tc04.Response.ClientId
    $wave2Results += $tc05
  }
  else {
    Write-Host "Skipping TC-228126-05 because TC-228126-04 is disabled or did not return a usable order id." -ForegroundColor Yellow
  }
}

if ($runTC06) {
  $tc06 = Invoke-CreateOrder -testCase "TC-228126-06" -body (New-OptionOrder -clientId ("TC22812606-" + [guid]::NewGuid().ToString("N").Substring(0,8)) -comment "TC-228126-06 QUIK OPTION" -exchange "QUIK")
  $wave2Results += $tc06
}

if ($runTC08) {
  $tc08 = Invoke-CreateOrder -testCase "TC-228126-08" -body (New-OptionOrder -clientId ("TC22812608-" + [guid]::NewGuid().ToString("N").Substring(0,8)) -comment "TC-228126-08 OPTION FIRM REPCODE")
  $wave2Results += $tc08
}

Write-Host ""
Write-Host "=== SUMMARY ===" -ForegroundColor Green
@($wave1Results + $wave2Results) | Select-Object TestCase, ClientId, Status, Message
