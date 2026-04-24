---
name: pub-api
description: Works with the ETNA Pub API for authentication and order flows. Use when the user mentions pub api, public api, Get_token, Orders_PlaceOrder, bearer token, login before orders, or wants to call pub-api-etna-demo-ci-int-2.etnasoft.us.
---

# Pub API

## When to use

- Нужен workflow для **Pub API**: login, bearer token, order/API calls.
- Пользователь упоминает `Get_token`, `Orders_PlaceOrder`, `Bearer`, `pub-api-etna-demo-ci-int-2.etnasoft.us`.
- Нужно быстро собрать рабочий запрос для **stock/equity** или related Pub API flows.

## Default flow

1. Получить токен через `POST /api/token`.
2. Не коммитить логин, пароль, `Et-App-Key` или токен.
3. Для первых проверок использовать минимальный stock/equity request.
4. При 401/403 сначала перепроверить фактический login response и способ передачи токена.

## Endpoints

- `POST /api/token`
- `POST /api/Orders/PlaceOrder`

## Rules

- Для stock order `Legs` должен быть `[]`.
- Следовать фактическому Swagger/contract, если токен нужно передавать и в `Authorization`, и в body field `Token`.
- Секреты держать только в env/local runtime artifacts.
- Для `/api/token` использовать заголовки `username`, `password`, `Et-App-Key`, а не JSON body с `clientSecret`, если окружение работает именно так.

## Additional resources

- Примеры запросов: [examples.md](examples.md)
