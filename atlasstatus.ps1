[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$atlasEnv = if ($env:ATLAS_ENV) { $env:ATLAS_ENV } else { "dev" }
$defaultConfigPath = ".cursor/skills/atlas-status-req/atlas.$atlasEnv.local.json"
$configPath = if ($env:ATLAS_CONFIG_PATH) { $env:ATLAS_CONFIG_PATH } else { $defaultConfigPath }

if (!(Test-Path -LiteralPath $configPath)) {
    throw "Atlas config not found: $configPath. Copy .cursor/skills/atlas-status-req/atlas.env.template.json to atlas.$atlasEnv.local.json and fill secrets locally."
}

$cfg = Get-Content -LiteralPath $configPath -Raw | ConvertFrom-Json

$username     = $cfg.username
$entity       = $cfg.entity
$sharedSecret = $cfg.sharedSecret
$baseUrl      = $cfg.baseUrl
$atlasId      = $cfg.atlasId

# === Шаг 1: JWS (по JwtFactory.cs) ===
function Base64UrlEncode([byte[]]$bytes) {
    [Convert]::ToBase64String($bytes).TrimEnd('=').Replace('+','-').Replace('/','_')
}

$header = '{"cty":"JWS","alg":"HS512"}'
$body   = '{"username":"' + $username + '","entity":"' + $entity + '","datetime":"' + (Get-Date).ToUniversalTime().ToString('o') + '"}'

$hB64 = Base64UrlEncode([System.Text.Encoding]::ASCII.GetBytes($header))
$bB64 = Base64UrlEncode([System.Text.Encoding]::ASCII.GetBytes($body))

$toSign   = [System.Text.Encoding]::ASCII.GetBytes("$hB64.$bB64")
$keyBytes = [System.Text.Encoding]::ASCII.GetBytes($sharedSecret)
$hmac     = [System.Security.Cryptography.HMACSHA512]::new($keyBytes)
$sig      = Base64UrlEncode($hmac.ComputeHash($toSign))
$jws      = "$hB64.$bB64.$sig"
Write-Host '=== JWS OK ==='

# === Шаг 2: Токен от Legit API (POST /legit/api/v1/cc/token) ===
$tokenResp = Invoke-RestMethod `
    -Uri "$baseUrl/legit/api/v1/cc/token" `
    -Method POST `
    -ContentType 'application/json' `
    -Body ('{"jws":"' + $jws + '"}')

Write-Host '=== Token ===' $tokenResp.Substring(0, [Math]::Min(50, $tokenResp.Length)) '...'

# === Шаг 3: GET статус заявки в Atlas ===
$result = Invoke-RestMethod `
    -Uri "$baseUrl/atlas/api/v2/account_requests/$atlasId" `
    -Method GET `
    -Headers @{ 'Authorization' = $tokenResp; 'Accept' = 'application/json' }

Write-Host ''
Write-Host '=== Atlas Status ==='
$result | ConvertTo-Json -Depth 10
