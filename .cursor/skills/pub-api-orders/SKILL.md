---
name: pub-api-orders
description: Works with the ETNA Pub API for authentication and order placement. Use when the user mentions pub api, public api, Get_token, Orders_PlaceOrder, bearer token, login before orders, or wants to place stock orders through pub-api-etna-demo-ci-int-2.etnasoft.us.
---

# Pub API orders

## When to use

- Нужен workflow для **Pub API**: сначала получить токен, потом вызвать `Orders_PlaceOrder`.
- Пользователь упоминает `Get_token`, `Orders_PlaceOrder`, `Bearer`, `pub-api-etna-demo-ci-int-2.etnasoft.us`.
- Нужно быстро собрать рабочий запрос для **stock/equity** ордера через Pub API.

## Base URL

`https://pub-api-etna-demo-ci-int-2.etnasoft.us`

## Workflow

1. Сначала получить токен через login endpoint.
2. Сохранить токен как секретную переменную, не коммитить его в репозиторий.
3. Передавать токен в запросе на размещение ордера так, как требует текущая API-модель.
4. Для первых проверок использовать обычные stock/equity ордера без `Legs`.

## Auth step

Login endpoint:

`POST /api/Login/Get_token`

Перед выполнением:

- Никогда не коммитить логин, пароль, токен или client secret в repo.
- Если пользователь прислал креды в чат, использовать их только для runtime-запроса или локальной коллекции Postman.
- Если формат login body неочевиден, сначала открыть Swagger/API reference и взять точную схему оттуда.

Пример `curl`-шаблона:

```bash
curl -sS -X POST "https://pub-api-etna-demo-ci-int-2.etnasoft.us/api/Login/Get_token" ^
  -H "Content-Type: application/json" ^
  --data-raw "{\"username\":\"%PUB_API_USERNAME%\",\"password\":\"%PUB_API_PASSWORD%\",\"clientSecret\":\"%PUB_API_CLIENT_SECRET%\"}"
```

PowerShell-шаблон:

```powershell
$body = @{
  username = $env:PUB_API_USERNAME
  password = $env:PUB_API_PASSWORD
  clientSecret = $env:PUB_API_CLIENT_SECRET
} | ConvertTo-Json

$token = Invoke-RestMethod `
  -Method Post `
  -Uri "https://pub-api-etna-demo-ci-int-2.etnasoft.us/api/Login/Get_token" `
  -ContentType "application/json" `
  -Body $body
```

## Order step

Orders endpoint:

`POST /api/Orders/PlaceOrder`

Для обычного stock/equity ордера придерживаться такого минимума:

- `Symbol`
- `ClientId`
- `Type`
- `Side`
- `TimeInforce`
- `Quantity`
- `Price` для `Limit`
- `Exchange` если маршрут задаётся явно
- `ExtendedHours` только если пользователь реально тестирует PRE/POST
- `Legs: []`
- `ParentId: 0`

Базовый JSON-шаблон:

```json
{
  "Symbol": "MSFT",
  "ClientId": "CLIENT_ID",
  "ExpireDate": "2026-04-16T14:10:04.840Z",
  "Type": "Market",
  "Side": "Buy",
  "Comment": "manual test",
  "ExecInst": "None",
  "TimeInforce": "Day",
  "Quantity": 100,
  "Price": 0,
  "StopPrice": 0,
  "Exchange": "NYSE",
  "TrailingStopAmountType": "Absolute",
  "TrailingStopAmount": 0,
  "TrailingLimitAmountType": "Absolute",
  "TrailingLimitAmount": 0,
  "ExtendedHours": "REG",
  "Token": "BEARER_TOKEN_OR_API_FIELD_IF_REQUIRED",
  "ExecutionInstructions": {},
  "ValidationsToBypass": 0,
  "Legs": [],
  "ParentId": 0
}
```

Пример `curl`-шаблона:

```bash
curl -sS -X POST "https://pub-api-etna-demo-ci-int-2.etnasoft.us/api/Orders/PlaceOrder" ^
  -H "Content-Type: application/json" ^
  -H "Authorization: Bearer %PUB_API_TOKEN%" ^
  --data-raw "{\"Symbol\":\"MSFT\",\"ClientId\":\"CLIENT_ID\",\"ExpireDate\":\"2026-04-16T14:10:04.840Z\",\"Type\":\"Market\",\"Side\":\"Buy\",\"Comment\":\"manual test\",\"ExecInst\":\"None\",\"TimeInforce\":\"Day\",\"Quantity\":100,\"Price\":0,\"StopPrice\":0,\"Exchange\":\"NYSE\",\"TrailingStopAmountType\":\"Absolute\",\"TrailingStopAmount\":0,\"TrailingLimitAmountType\":\"Absolute\",\"TrailingLimitAmount\":0,\"ExtendedHours\":\"REG\",\"Token\":\"%PUB_API_TOKEN%\",\"ExecutionInstructions\":{},\"ValidationsToBypass\":0,\"Legs\":[],\"ParentId\":0}"
```

## Default operating rules

- Для первых проверок использовать **stocks/equity**, не options.
- Если это обычный stock order, `Legs` должен быть пустым массивом `[]`.
- Не сохранять реальные креды в `SKILL.md`, `examples.md`, `.http`, `.json`, Postman collection или тестовые фикстуры.
- Если API принимает токен и в `Authorization`, и в поле `Token`, сначала повторить паттерн из Swagger/референса и затем унифицировать.
- При ошибках 401/403 сначала перепроверить login response, формат токена и способ передачи токена в order request.

## Quick checklist

- [ ] Получен токен через `Get_token`
- [ ] Токен не сохранён в repo
- [ ] Для stock order `Legs` = `[]`
- [ ] Запрос на `PlaceOrder` содержит обязательные поля
- [ ] Токен передан корректно
- [ ] Ответ API сохранён как evidence без утечки секретов

## Additional resources

- Примеры запросов: [examples.md](examples.md)
