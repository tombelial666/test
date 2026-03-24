[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$username     = 'atlas_etna'
$entity       = 'correspondent_etna.wiai'
$sharedSecret = 'pbuAaPnhbxWsUoL.iQ390aNXIh8rJ+wcUMPlnk9YIGjCLRm7.DF1dS+qYl.Y9aFh+i9'
$baseUrl      = 'https://sogowebapiserver-qa.azurewebsites.net'
$atlasId      = '991fa870-290a-4148-8d24-d6d2c8c11ee5'

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
