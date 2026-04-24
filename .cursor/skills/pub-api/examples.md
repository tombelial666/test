# Pub API examples

## PowerShell: login then place order

```powershell
$base = "https://pub-api-etna-demo-ci-int-2.etnasoft.us"

$loginResponse = Invoke-RestMethod `
  -Method Post `
  -Uri "$base/api/token" `
  -Headers @{
    username = $env:PUB_API_USERNAME
    password = $env:PUB_API_PASSWORD
    "Et-App-Key" = $env:PUB_API_APP_KEY
  }

$token = if ($loginResponse -is [string]) { $loginResponse } else { $loginResponse.token }

$orderBody = @{
  Symbol = "MSFT"
  ClientId = "CLIENT_ID"
  ExpireDate = "2026-04-16T14:10:04.840Z"
  Type = "Market"
  Side = "Buy"
  Comment = "manual test"
  ExecInst = "None"
  TimeInforce = "Day"
  Quantity = 100
  Price = 0
  StopPrice = 0
  Exchange = "NYSE"
  TrailingStopAmountType = "Absolute"
  TrailingStopAmount = 0
  TrailingLimitAmountType = "Absolute"
  TrailingLimitAmount = 0
  ExtendedHours = "REG"
  Token = $token
  ExecutionInstructions = @{}
  ValidationsToBypass = 0
  Legs = @()
  ParentId = 0
} | ConvertTo-Json -Depth 5

Invoke-RestMethod `
  -Method Post `
  -Uri "$base/api/Orders/PlaceOrder" `
  -Headers @{ Authorization = "Bearer $token" } `
  -ContentType "application/json" `
  -Body $orderBody
```
